create procedure "informix".bloqueo_cta_pba( pempresa     char(3),
                                         pcuenta      char(20),
                                         pmonto       money(14,2),                          
                                         pcodbloq     char(2),
                                         popbloq      integer,
                                         pfechabloq   char(10),
                                         pusuario     char(8),
                                         pclave       char(5),
										 pAreaSolic   CHAR(2),
										 pCodArea     CHAR(1),
										 pTipoBloq    CHAR(2),
										 pCodTipoBloq CHAR(1) )
returning char(5), char(5);

    define cod_ret                  char(3);
    define cta_w,x_cta              char (20);
    define suc_w                    char (4);
    define usu_w                    char (5);
    define prod_w                   char (4);
    define banca_w                  char (3);
    define v_long_cta               char (2);
    define mov, status_w            char (1);
    define status2_w                char (1);
    define sdoc_w                   money (14,2);
    define sdod_w                   money (14,2);
    define sdoa_w                   money (14,2);
    define fecha_w                  date;
    define hora_w                   char(15);
    define edo_cta_w                char (1);
    define v_cal_int_chq            char (1);
    define v_folio                  char (16);
    define folio2                   char(8);
    define longitud                 smallint;
    define v_transacc, v_clave      char(4);
    define v_mesdia                 char(4);
    define vmonto_cong              money(14,2);
    define vsdoxdesbloq,vimporte    money(14,2);
    define vrowid                   integer;
    define vfecha                   date;
    define vmaxsec                  smallint;
    define vnum_tarjeta             char(16);

    let cod_ret = "000";
    let v_clave = "0000";
    
    -- // Verifica recepcion completa de datos
    if pfechabloq = "" or pcuenta = "" or pmonto = "" or popbloq ="" or pcodbloq = "" or pusuario = "" then
        let cod_ret = 110;
        return cod_ret, v_clave;
    end if;
    
    let x_cta = pcuenta;
    
    select cuenta, sucursal, producto, status_cta, sdo_cong, sdo_actual, sdo_actual - sdo_cong - sdo_retenido
      into cta_w, suc_w, prod_w, status_w, sdoc_w, sdoa_w, sdod_w
      from sc_maechq
     where empresa = pempresa 
       and cuenta = pcuenta;

    --- SET DEBUG FILE TO "/dbexportb/vlv/bloqueo_cta.out";
    --- TRACE ON
	   
    -- // Verifica el Saldo a Congelar de la Cuenta
    if pmonto > sdoa_w - sdoc_w and pcodbloq <> "00" then
        let cod_ret = "162";
        return cod_ret, v_clave;
    end if

    -- // Verifica el Saldo a desbloquear de la Cuenta
    if  pmonto > sdoc_w and pcodbloq = "00" then
        let cod_ret = "163";
        return cod_ret, v_clave;
    end if

    -- // Verifica existencia de la Cuenta
    if cta_w is null then
    
        let cod_ret = 100;
        return cod_ret, v_clave;
        
    elif status_w = "1" then -- // Verifica si la cuenta esta activa y no esta bloqueada
    
        if pcodbloq = "00" then
            let cod_ret = "302";
            return cod_ret, v_clave;
        end if
    
    elif status_w in ("2","6","7") then -- // Verifica que la cuenta no este cancelada
    
        let cod_ret = 200;
        return cod_ret, v_clave;
    
    elif status_w = "3" then -- // Verifica que la cuenta no haya sido bloqueada previamente
    
        if pcodbloq != "00" then
        
            if pmonto >  sdoa_w - sdoc_w then
                let cod_ret = 303;
                return cod_ret, v_clave;
            end if
            
        end if
        
    end if

    select fecha_hoy 
      into fecha_w 
      from sc_fechas 
     where empresa = pempresa;

    let hora_w = current hour to fraction;

    -- // Asigna un folio
    let folio2  = hora_w[1,2] || hora_w[4,5] || hora_w[7,8] || hora_w[10,11];
    let v_folio = trim(pusuario)||folio2;

    -- // Asigna el Status con el que quedara la Cuenta, de acuerdo al cod. recibido
    if pcodbloq = "00" then
        let status2_w = "1";
        let mov = "D";
        let vmonto_cong = pmonto * -1;
        let v_transacc = "3354";
        
        if pmonto = sdoc_w then
            let status2_w = "1";
        else
            let status2_w = "3";
        end if
    else
        let status2_w = "3";
        let mov = "B";
        let vmonto_cong = pmonto;
        let v_transacc = "3353";
    end if

    let v_mesdia = month(fecha_w) || day(fecha_w);
    let hora_w = hora_w[4,5] || hora_w[7,8];
    
    if pcodbloq = "00" then
        let v_clave = pclave;
    else
        let v_clave = v_mesdia + hora_w;
    end if

    select max(secuencia) 
      into vmaxsec
      from sc_tarjeta
     where empresa = pempresa 
       and cuenta = pcuenta 
       and tipo_tarjeta = "T";

    select num_tarjeta 
      into vnum_tarjeta
      from sc_tarjeta
     where empresa = pempresa 
       and cuenta = pcuenta 
       and secuencia = vmaxsec;

    insert into sc_histbloq 
    (empresa, cuenta, tipo_mov, motivo, opcion, importe, usuario, fecha, hora, clave, 
     status_blo, folio_suc, referencia, cve_area, cod_area, cve_tipobloq, cod_tipobloq)
    values 
    (pempresa, pcuenta, mov, pcodbloq, popbloq, pmonto, pusuario, fecha_w, current hour to fraction, v_clave, 
     mov, v_folio, "", pAreaSolic, pCodArea, pTipoBloq, pCodTipoBloq);
    
    insert into sc_movdia values
    (0, v_folio, suc_w, pusuario, fecha_w, fecha_w, current hour to fraction, v_transacc, suc_w, prod_w, 
     pempresa, pcuenta, " ", 0, pmonto, 0, 0, 0, 0, " ", " ", sdod_w, "0000", " ", 0, vnum_tarjeta, " ", "");

	---- // INSERT NUEVOS // ----
	-- // Guarda un historial de los bloqueos 
	IF pcodbloq != "00" THEN
    
        INSERT INTO sc_ctabloqueo
        (cuenta, clave, opcion, cve_area, cod_area, cve_tipobloq, cod_tipobloq)  
        VALUES 
        (pcuenta, pcodbloq, popbloq, pAreaSolic, pCodArea, pTipoBloq, pCodTipoBloq);

        INSERT INTO sc_ctabloqueohist
        (cuenta, clave, opcion)
        VALUES 
        (pcuenta, pcodbloq, popbloq);
        
	 ELSE  
        
        DELETE FROM bdicheq:sc_ctabloqueo 
         WHERE cuenta = pcuenta;
         
	END IF
	---- // INSERT NUEVOS // ----
    
    update sc_maechq
       set fec_cancelac = fecha_w,
           status_cta = status2_w,
           motivo = pcodbloq,
           sdo_cong = sdo_cong + vmonto_cong,
           fecha_proceso = fecha_w
     where empresa = pempresa 
       and cuenta = pcuenta;
       
    if pcodbloq = "00" then
        if pclave <>  "" and pclave <> " " then
            update sc_histbloq
               set status_blo = mov
             where empresa = pempresa 
               and cuenta = pcuenta
               and clave = pclave 
               and tipo_mov = "B";
        else
            let vsdoxdesbloq = pmonto;
            
            foreach
                select rowid,importe,fecha
                  into vrowid, vimporte,vfecha
                  from sc_histbloq
                 where empresa = pempresa 
                   and cuenta = pcuenta 
                   and tipo_mov = "B" 
                   and status_blo = "B"
                 order by fecha
                 
                if vimporte > vsdoxdesbloq then
                    let vimporte = vimporte - vsdoxdesbloq;
                else
                    let vimporte = vimporte;
                end if
                
                update sc_histbloq
                   set status_blo = mov,
                       importe = vimporte
                 where rowid = vrowid;
                 
                let vsdoxdesbloq = vsdoxdesbloq - vimporte;
                
                if vsdoxdesbloq = 0 then
                    exit foreach;
                end if
            end foreach
        end if
    end if
    
    let cod_ret = "000";
    
    return cod_ret, v_clave;
    
end procedure

DOCUMENT
'DESCRIPCION: Realiza el Bloqueo de cuentas si no estan bloqueadas',
'AUTOR: Valentín López',
'FECHA: Septiembre 2010',
'VERSION: 20100929.0101';

create procedure "informix".conciliadebito_pba(pempresa char(3),
                                           pnum_tarjeta char(16),
                                           psucursal char(4),
                                           pusuario char(8),
                                           ptipomov char(1),
                                           ptransacc char(4),
                                           pfoliosuc char(16),
                                           pmonto_tot money(14,2),
                                           pdivisa char(2),
                                           preferencia char(40),
                                           pfolioori char(16),
                                           pvRfcComer char (20),
                                           pvRef23 char(23))
    
returning char(5),char(1);

    -- // Variables Globales Conciliacion intercar
    DEFINE GLOBAL vg_estatus    VARCHAR(5)  DEFAULT " ";
    DEFINE GLOBAL vgrfc_comer   VARCHAR(20) DEFAULT " ";
    DEFINE GLOBAL vgreferencia  VARCHAR(40) DEFAULT " ";

    define vcodret char(5);
    define vsqlerr integer;
    define vbandera char(1);
    define vcuenta char(20);
    define vtranret char(4);
    define vfecapli date;
    define vsdodisp money(14,2);
    define vmtoapli money(14,2);
    define vTranResp CHAR(4);
    define vTipoTran char(2);
    define vt_status_cta char(1);
    
    --- set debug file to "/informixuc7/perifericos/conciliadebito.out";
    --- trace on;

    begin
    
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret, vbandera;
        end if
    end exception;

    let vcodret = "000";
    let vbandera = "E";
    let vsqlerr = 0;
    let vcuenta = "";
    let vtranret = "";
    let vfecapli = "";
    let vsdodisp = 0;
    let vmtoapli = 0;
    let vTranResp = "";
    let vTipoTran = "";
    LET vt_status_cta = "";

    -- // Busca la cuenta en base al No. tarjet
    select tar.cuenta, mae.status_cta 
      into vcuenta, vt_status_cta
      from sc_tarjeta tar, 
           sc_maechq mae
     WHERE tar.empresa = pempresa 
       AND num_tarjeta = pnum_tarjeta
       AND tar.empresa = mae.empresa
       AND tar.cuenta = mae.cuenta;

    if vcuenta is null OR vcuenta = "" then
        let vcodret = "111";
        let vbandera = "E";
        return vcodret, vbandera;
    end if

    LET vTranResp = ptransacc;

    -- // busca el tipo_tran en si_transaccc (20)
    SELECT NVL(tranlibprot, "0000"), tipo_tran
      INTO ptransacc, vTipoTran
      FROM bdinteg:si_transacc
     WHERE empresa = pempresa
       AND numero = ptransacc
       AND sistema = "01";

    -- // Si es de Cargo
    if ptipomov = "C" then
        if vTipoTran  in ("00", "01", "02") and vg_estatus <> "3" then
            let vbandera = "C";
            return vcodret, vbandera;
        end if;

        IF ptransacc = "0000" OR ptransacc = " " THEN
            LET ptransacc = vTranResp;
        END IF

        -- // Realiza un desbloqueo parcial si es necesario, para realizar el cargo correspondiente
        IF vt_status_cta = "3" THEN 
            UPDATE sc_maechq 
               SET status_cta = "1"
             WHERE empresa = pempresa
               AND cuenta = vcuenta;
        END IF

        -- // Realiza el cargo de la transaccion en cheques...
        LET preferencia = vgrfc_comer || preferencia;
		
        call cargo_ref_pos(pempresa, psucursal, pusuario, ptransacc, ptransacc, pfoliosuc, 
                       vcuenta, 0, pmonto_tot, pdivisa, preferencia, pnum_tarjeta,"", pvRef23)
        returning vcodret, vtranret, vfecapli, vsdodisp, vmtoapli;

        -- // Devuelve el bloqueo original
        IF vt_status_cta = "3" THEN 
            UPDATE sc_maechq 
               SET status_cta = "3"
             WHERE empresa = pempresa
               AND cuenta = vcuenta;
        END IF

        if vcodret <> "000" and vcodret <> "400" then
            let vbandera = "E";
            return vcodret, vbandera;
        elif vcodret = "400" then
            let vbandera = "0";
            return vcodret, vbandera;
        else
            let vbandera = "C";
            return vcodret, vbandera;
        end if
    end if
    
    -- // Si es de Abono
    if ptipomov = "A" then
        --LET ptransacc = "0813";
		LET ptransacc = vTranResp;
        LET preferencia = vgrfc_comer || preferencia;
        
        call abono_ref_pos(pempresa, psucursal, pusuario, ptransacc, ptransacc, pfoliosuc, vcuenta, 0, 
                       pmonto_tot, pmonto_tot, 0, 0, 0, pdivisa, preferencia, pnum_tarjeta, "", pvRef23)
        returning vcodret;
        
        if vcodret <> "000" then
            let vbandera = "E";
            return vcodret, vbandera;
        else
            let vbandera = "C";
            return vcodret, vbandera;
        end if
    end if

    -- // si es de reversion
    if ptipomov = "R" then
        call reversiontd(pempresa, psucursal, pusuario, pfolioori, "A", vcuenta, ptransacc)
        returning vcodret;
        
        if vcodret <> "000" then
            let vbandera = "E";
            return vcodret, vbandera;
        else
            let vbandera = "C";
            return vcodret, vbandera;
        end if
    end if
    
    return vcodret, vbandera;
    
    end
    
end procedure;