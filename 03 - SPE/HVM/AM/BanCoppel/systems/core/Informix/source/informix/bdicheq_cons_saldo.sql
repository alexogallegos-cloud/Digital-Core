create procedure "informix".cons_saldo(pcuenta char(20))

returning char(5),money(16,2),char(1);

    define vcodret    char(5);
    define vsqlerr    integer;
    define vcuenta    char(20);
    define vsdodisp   money(16,2);
    define vstatuscta char(1);
    define vmotivo    char(2);
    define vcargo     char(1);
    define vabono     char(1);

    let vcodret    = "000";
    let vcuenta    = "";
    let vsdodisp   =  0;
    let vstatuscta = " ";
    
    begin
    
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret,vsdodisp,vstatuscta;
        end if
    end exception;
    
    set isolation to dirty read;
    set lock mode to wait 3;

    --- // Valida que la Cuenta no sea Blanco
    if pcuenta = " " then
        let vcodret = "110";
        return vcodret,vsdodisp,vstatuscta;
    end if

    --- // Valida que Exista la Cuenta de Cheques
    --RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. EEAP
    select cuenta, sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc + saldo_sbc), status_cta, motivo
      into vcuenta, vsdodisp, vstatuscta, vmotivo
      from sc_maechq
     where cuenta = pcuenta;
     
    if vcuenta is null or vcuenta <> pcuenta then
        let vcodret = "100";
        return vcodret, vsdodisp,vstatuscta;
    end if

    if vstatuscta = "3" then
        select cargo, abono 
          into vcargo, vabono
          from sc_bloqueo
         where codigo = vmotivo;
         
        if vcargo = "S" or vabono = "S" then
            let vstatuscta = "1";
        end if
    end if
    
    return vcodret,vsdodisp,vstatuscta;
    
    end
    
end procedure

DOCUMENT 
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 02-06-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para considerar un nuevo campo',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2';

CREATE PROCEDURE "informix".cons_saldo_cel( pnum_tarjeta char(16),
                                            pcuenta      char(20),
                                            psucursalcom char(4),
                                            pusuariocom  char(8),
                                            ptrancencom  char(4),
                                            ptransuccom  char(4),
                                            pfolsuccom   char(16),
                                            pcuentacom   char(20),
                                            pchequecom   integer,
                                            pmontocom    money(14,2),
                                            pdivisacom   char(2),
                                            prefercom    char(40),
                                            pbanderacom  char(1),
                                            pSurcharge   char(1) )
returning char(5), money(14,2), char(1), char(5), date, money(14,2);
    
    define vsqlerr      int;
    define vcodret      char(5);
    define vcodret1     char(5);
    define vcodretcom   char(5);
    define vfechoy      date;
    define vsdodisp     money(14,2);
    define vtotret      money(14,2);
    define vempresa     char(3);
    define vtasaiva     decimal(9,3);
    define vivacom      money(14,2);
    define vsuccta      char(4);
    define vtraniva     char(4);
    define vtranret1    char(4);
    define vstatus_cta  char(1);
    define vdate        date;
    define vmto         money(14,2);
    define vind_dispon  char(1);
    define vhora        char(15);
    define vidtransacc  char(5);
    define vcodret_reg  char(5);
    define vserial      integer;
    define vprodtrnf    char(4);
    define vvueltas     integer;
    define vSQL         char(10);
    define cStatus      char(1);
    define cTramaRes    char(600);
    define vtransaccion integer;
    define vusuario     char(8);
	define vfecha_operacion date;
	define desc_bex    CHAR(100); --bex
    
    LET vidtransacc  = '';
    LET vcodret_reg  = '';
    LET vserial      = 0;
    LET vprodtrnf    = '8000';
    LET vvueltas     = 0; 
    LET vSQL         = '';
    LET cStatus      = '';
    let vcodret      = "000";
    let vsdodisp     = 0;
    let vstatus_cta  = "";
    let vcodretcom   = "000";
    let psucursalcom = "9"||trim(psucursalcom);
    let cTramaRes    = '';
    let vtransaccion = 0;
    let vhora        = '';
    let vusuario     = user;
	let vfecha_operacion = TODAY;
	let desc_bex = '';  --bex 
    
    --set debug file to "/informix/moha/cons_saldo_cel.out";
    --trace on;
    
    set isolation to dirty read;
    set lock mode to wait 3;
    
    BEGIN
    
    on exception set vsqlerr
        if vsqlerr <> 0  then
            let vcodret = vsqlerr;
            IF SUBSTR(pcuenta, 1, 2) <> '80' THEN
                if vtransaccion = 1 then
                    ROLLBACK WORK;
                    BEGIN WORK;
                else
                    ROLLBACK WORK;
                end if;
            END IF;
            RETURN vcodret, vsdodisp, vstatus_cta, vcodretcom, vfechoy, vsdodisp;
        end if;
    end exception;
    
    on exception in (-535)
        let vtransaccion = 1;
    end exception with resume;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    select empresa 
      into vempresa
      from bdinteg:si_ejecut
     where ejecutivo = pusuariocom;
    
    if vempresa is null then
        let vempresa = "001";
    end if

    select fecha_hoy, ind_disponible 
      into vfechoy, vind_dispon
      from sc_fechas
     where empresa = vempresa;
     
    IF vind_dispon = '0' THEN
        if vtransaccion = 1 then
            ROLLBACK WORK;
            BEGIN WORK;
        else
            ROLLBACK WORK;
        end if;
        LET vcodret = "004";
        RETURN vcodret, vsdodisp, vstatus_cta, vcodretcom, vfechoy, vsdodisp;
    END IF;
    
    select cuenta 
      into pcuenta
      from sc_tarjeta
     where empresa = vempresa
       and num_tarjeta = pnum_tarjeta;
    
    if pcuenta is null then
        let vcodret = "100";
        if vtransaccion = 1 then
            ROLLBACK WORK;
            BEGIN WORK;
        else
            ROLLBACK WORK;
        end if;
        RETURN vcodret, vsdodisp, vstatus_cta, vcodretcom, vfechoy, vsdodisp;
    end if
    
    select iva 
      into vtasaiva
      from bdinteg:si_sucursales
     where empresa = vempresa 
       and sucursal = '9290';
       
    if vtasaiva is null then
        let vtasaiva = 0;
    end if
    
    IF SUBSTR(pcuenta, 1, 2) = '80' THEN
        
        LET vcodret = "999";
        RETURN vcodret, vsdodisp, vstatus_cta, vcodretcom, vfechoy, vsdodisp;
        
        /* ##########################################################################################################################################
        IF ( pfolsuccom is null OR pfolsuccom = '' OR pfolsuccom = ' ' ) THEN
            LET vhora = CURRENT HOUR TO FRACTION;
            LET pfolsuccom = vusuario||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
        END IF;
        
        -- // OBTIENE EL SALDO DE LA CUENTA TRANSFER
        SELECT valor
          INTO vidtransacc
          FROM sc_param
         WHERE empresa = vempresa
           AND codparam = 'TranConSdoTransfer';  
           
        CALL sp_transfer_online_consdo( vidtransacc, pnum_tarjeta, pfolsuccom, pusuariocom, pmontocom )
        RETURNING vcodret_reg, vserial;
        
        IF ( vcodret_reg is null OR vcodret_reg <> '000' ) OR ( vserial is null OR vserial = 0 ) THEN
            IF vtransaccion = 1 THEN
                COMMIT WORK;
                BEGIN WORK;
            ELSE
                COMMIT WORK;
            END IF;
            LET vcodret = "999";
            RETURN vcodret, vsdodisp, vstatus_cta, vcodretcom, vfechoy, vsdodisp;
        END IF;
        
        COMMIT WORK;
        
        LET vvueltas = 0;
        LET cStatus = 'N';
        
        WHILE cStatus IN('N','E') 
            SET ISOLATION TO DIRTY READ;
            
            SELECT status, trama_res
              INTO cStatus, cTramaRes
              FROM sc_transfer_online
             WHERE no_serial = vserial
               AND cuenta = pnum_tarjeta
               AND folio_suc = pfolsuccom
               AND id_transacc = vidtransacc;
               
            IF cStatus IN('F','X') THEN
                EXIT WHILE;
            ELSE
                LET vSQL = 'sleep 3'; 
                SYSTEM vSQL; 
                LET vvueltas = vvueltas + 1; 
                IF vvueltas > 5 THEN 
                    EXIT WHILE; 
                END IF; 
            END IF;
        END WHILE;
        
        IF ( cStatus is null OR cStatus = '' OR cStatus IN('N','E') ) THEN
            UPDATE {+INDEX(sc_transfer_online idx_transferonline_serctafoltra)} sc_transfer_online
               SET status = 'T'
             WHERE no_serial = vserial
               AND cuenta = pnum_tarjeta
               AND folio_suc = pfolsuccom
               AND id_transacc = vidtransacc;
               
            LET vcodret = "96"; 
            RETURN vcodret, vsdodisp, vstatus_cta, vcodretcom, vfechoy, vsdodisp;
            
        ELIF cStatus = 'X' THEN
            SELECT cod_ret
              INTO vcodret
              FROM sc_transfer_online
             WHERE no_serial = vserial
               AND cuenta = pnum_tarjeta
               AND folio_suc = pfolsuccom
               AND id_transacc = vidtransacc;
               
            RETURN vcodret, vsdodisp, vstatus_cta, vcodretcom, vfechoy, vsdodisp;
        END IF;
        
        LET vsdodisp = SUBSTR(cTramaRes, 49, 17);
        
        IF pmontocom > 0 THEN
        
            BEGIN WORK;
            
            SELECT valor
              INTO vprodtrnf
              FROM sc_param
             WHERE empresa = vempresa
               AND codparam = 'ProductoTransfer';
            
            IF psurcharge = 'V' THEN
                if ptrancencom = '0874' then
                    let ptrancencom = '0893';
                elif ptrancencom = '0875' then
                    let ptrancencom = '0894';
                elif ptrancencom = '0876' then
                    let ptrancencom = '0895';
                end if
                
                LET vhora = CURRENT HOUR TO FRACTION;
                
                INSERT INTO sc_movdia VALUES
                ( 0, pfolsuccom, psucursalcom, pusuariocom, vfechoy, vfechoy, vhora, ptrancencom, psucursalcom, vprodtrnf, 
                  vempresa, pcuenta, "", 0, pmontocom, 0, 0, 0, 0, "", "", 0.00, ptrancencom, prefercom, 0, pnum_tarjeta, '', '', vfecha_operacion);
                  
                IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
                    SELECT tran_relac 
                      INTO vtraniva
                      FROM bdinteg:si_transacc
                     WHERE empresa = vempresa 
                       AND numero = ptrancencom;
                     
                    LET vivacom = pmontocom * vtasaiva;
                    
                    IF vivacom > 0 AND (vtraniva is not null or vtraniva <> '') THEN
                        INSERT INTO sc_movdia VALUES
                        ( 0, pfolsuccom, psucursalcom, pusuariocom, vfechoy, vfechoy, vhora, ptrancencom, psucursalcom, vprodtrnf, 
                          vempresa, pcuenta, "", 0, vivacom, 0, 0, 0, 0, "", "", 0.00, ptrancencom, 'IVA '||prefercom, 0, pnum_tarjeta, '', '', vfecha_operacion);
                    END IF;
                END IF;
            ELSE
                INSERT INTO sc_movdia VALUES
                ( 0, pfolsuccom, psucursalcom, pusuariocom, vfechoy, vfechoy, vhora, ptrancencom, psucursalcom, vprodtrnf, 
                  vempresa, pcuenta, "", 0, pmontocom, 0, 0, 0, 0, "", "", 0.00, ptrancencom, prefercom, 0, pnum_tarjeta, '', '', vfecha_operacion);
                
                IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
                    SELECT tran_relac 
                      INTO vtraniva
                      FROM bdinteg:si_transacc
                     WHERE empresa = vempresa 
                       AND numero = ptrancencom;
                     
                    LET vivacom = pmontocom * vtasaiva;
                    
                    IF vivacom > 0 AND (vtraniva is not null or vtraniva <> '') THEN
                        INSERT INTO sc_movdia VALUES
                        ( 0, pfolsuccom, psucursalcom, pusuariocom, vfechoy, vfechoy, vhora, ptrancencom, psucursalcom, vprodtrnf, 
                          vempresa, pcuenta, "", 0, vivacom, 0, 0, 0, 0, "", "", 0.00, ptrancencom, 'IVA '||prefercom, 0, pnum_tarjeta, '', '', vfecha_operacion);
                    END IF;
                END IF;
            END IF;
            
            COMMIT WORK;
            
        END IF;
        
        ########################################################################################################################################## */
        
    ELSE
        
        let vivacom = pmontocom * vtasaiva;
        let vtotret = pmontocom + vivacom;
        
        -- RQM 09 704. Se agrega el campo saldo_sbc para que sea considerado en el calculo del saldo disponible. LEOC
        select sucursal, sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc + saldo_sbc), status_cta
          into vsuccta, vsdodisp, vstatus_cta
          from sc_maechq
         where empresa = vempresa 
           and cuenta = pcuenta;
        
        if vsdodisp < vtotret then
            let vcodret = "400";
            let vsdodisp = 0;
            
            if vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            else
                ROLLBACK WORK;
            end if;
            
            RETURN vcodret, vsdodisp, vstatus_cta, vcodretcom, vfechoy, vsdodisp;
        end if

        if pmontocom > 0 then
            if psurcharge = 'V' then
                if ptrancencom = '0874' then
                    let ptrancencom = '0893';
                elif ptrancencom = '0875' then
                    let ptrancencom = '0894';
                elif ptrancencom = '0876' then
                    let ptrancencom = '0895';
                end if
                   
                call cargo_ref_td(vempresa,psucursalcom,pusuariocom,ptrancencom,ptransuccom,pfolsuccom,pcuenta,pchequecom,pmontocom,pdivisacom,prefercom,pnum_tarjeta,"")
                returning vcodret,vtranret1, vdate, vmto, vmto;
                
                if vcodret <> "000" then
                    if vtransaccion = 1 then
                        ROLLBACK WORK;
                        BEGIN WORK;
                    else
                        ROLLBACK WORK;
                    end if;
                    let vsdodisp = 0;
                    RETURN vcodret, vsdodisp, vstatus_cta, vcodretcom, vfechoy, vsdodisp;
                else
                    select tran_relac 
                      into vtraniva
                      from bdinteg:si_transacc
                     where empresa = vempresa 
                       and numero = ptrancencom;
                       
                    if vivacom > 0 and (vtraniva is not null or vtraniva <> '') then
                        call cargo_ref_td(vempresa,psucursalcom,pusuariocom,vtraniva,"0000",pfolsuccom,pcuenta,pchequecom,vivacom,pdivisacom,prefercom,pnum_tarjeta,"")
                        returning vcodret, vtranret1, vdate, vmto, vmto;
                        
                        if vcodret <> "000" then
                            if vtransaccion = 1 then
                                ROLLBACK WORK;
                                BEGIN WORK;
                            else
                                ROLLBACK WORK;
                            end if;
                            let vsdodisp = 0;
                            RETURN vcodret, vsdodisp, vstatus_cta, vcodretcom, vfechoy, vsdodisp;
                        end if
                    end if
                end if
            else
                call cargo_ref_td(vempresa,psucursalcom,pusuariocom,ptrancencom,ptransuccom,pfolsuccom,pcuenta,pchequecom,pmontocom,pdivisacom,prefercom,pnum_tarjeta,"")
                returning vcodret,vtranret1, vdate, vmto, vmto;
                
                if vcodret <> "000" then
                    if vtransaccion = 1 then
                        ROLLBACK WORK;
                        BEGIN WORK;
                    else
                        ROLLBACK WORK;
                    end if;
                    let vsdodisp = 0;
                    RETURN vcodret, vsdodisp, vstatus_cta, vcodretcom, vfechoy, vsdodisp;
                else
                    select tran_relac 
                      into vtraniva
                      from bdinteg:si_transacc
                     where empresa = vempresa 
                       and numero = ptrancencom;
                       
                    if vivacom > 0 then
                        call cargo_ref_td(vempresa,psucursalcom,pusuariocom,vtraniva,"0000",pfolsuccom,pcuenta,pchequecom,vivacom,pdivisacom,prefercom,pnum_tarjeta,"")
                        returning vcodret, vtranret1, vdate, vmto, vmto;
                        
                        if vcodret <> "000" then
                            if vtransaccion = 1 then
                                ROLLBACK WORK;
                                BEGIN WORK;
                            else
                                ROLLBACK WORK;
                            end if;
                            let vsdodisp = 0;
                            RETURN vcodret, vsdodisp, vstatus_cta, vcodretcom, vfechoy, vsdodisp;
                        end if
                    end if
                end if
            end if
        end if
        
          -- RQM 09 704. Se agrega el campo saldo_sbc para que sea considerado en el calculo del saldo disponible. LEOC
          select sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc + saldo_sbc)
          into vsdodisp
          from sc_maechq
         where empresa = vempresa 
           and cuenta = pcuenta;
           
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
        END IF;
           
    END IF;
    
	--inicio validacion BEX
    Select limit 1 valor into desc_bex FROM bdinteg:si_param where cod_param='495';
	IF  trim(desc_bex) = 'V' then
	    EXECUTE PROCEDURE bdinteg:sp_actbex ('2','','',pnum_tarjeta,'8','','','')
	    INTO  vcodret,desc_bex;
	END IF;
	--fin validacion BEX
	
    RETURN vcodret, vsdodisp, vstatus_cta, vcodretcom, vfechoy, vsdodisp;
    
    END;
    
END PROCEDURE
DOCUMENT
'AUTOR:         N/A',
'DESCRIPCION :  Este procedimiento realiza la consulta de saldos relacionados de una cuenta de captacion, en caso de tener un monto de comision en los parametros de entrada realiza un cargo adicional de la consulta ',
'BD :           bdicheq',
'VERSION :      1.0.0',
'FECHA :        N/A',
'----------------------------------------------------',
'MODIFICO :     Luis Enrique Orozco Cosme',
'FECHA :        30-05-2025',
'MODIFICACION : Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo llamado saldo_sbc',
'PROYECTO :     RQM 09 704 Cobranza Automatica en cuentas de captacion',
'VERSION :      1.0.1';

create procedure "informix".cons_saldo_web(pcuenta char(20))

returning char(5),money(16,2),char(1);

    define vcodret    char(5);
    define vsqlerr    integer;
    define vcuenta    char(20);
    define vsdodisp   money(16,2);
    define vstatuscta char(1);
    define vmotivo    char(2);
    define vcargo     char(1);
    define vabono     char(1);

    let vcodret    = "00000";
    let vcuenta    = "";
    let vsdodisp   =  0;
    let vstatuscta = " ";
    
    begin
    
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret,vsdodisp,vstatuscta;
        end if
    end exception;
    
    set isolation to dirty read;
    set lock mode to wait 3;

    --- 
    if pcuenta = " " then
        let vcodret = "110";
        return vcodret,vsdodisp,vstatuscta;
    end if

    ---
    --RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. EEAP
    select cuenta, sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc + saldo_sbc), status_cta, motivo
      into vcuenta, vsdodisp, vstatuscta, vmotivo
      from sc_maechq
     where cuenta = pcuenta;
     
    if vcuenta is null or vcuenta <> pcuenta then
        let vcodret = "00100";
        return vcodret, vsdodisp,vstatuscta;
    end if

    if vstatuscta = "3" then
        select cargo, abono 
          into vcargo, vabono
          from sc_bloqueo
         where codigo = vmotivo;
         
        if vcargo = "S" or vabono = "S" then
            let vstatuscta = "1";
        end if
    end if
    
    return vcodret,vsdodisp,vstatuscta;
    
    end
    
end procedure

DOCUMENT 
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 02-06-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para considerar un nuevo campo',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2';

CREATE PROCEDURE "informix".cons_sdo_disp( pcuenta char(20), pnum_tarjeta char(16) ) 
returning char(5), money(14,2);
    
    define vcod_ret         char(5);
    define vcod_ret2        char(5);
    define vcod_ret3        char(50);
    define sql_err          integer;
    define isam_err         integer;
    define desc_err         char(50);
    define vind_dispon      char(1);
    define vstatus_cta      char(1);
    define vstatus_tar      char(1);
    define vsdo_actual      money(14,2);
    define vsdo_retenido    money(14,2);
    define vsdo_cong        money(14,2);
    define vimp_chq_sbg     money(14,2);
    define vsdo_disp        money(14,2);
    --RQM 09 704. Se crea la siguiente variable. EEAP 
    define mSaldoSBC        money(14,2); 
    
    let vcod_ret      = '000';
    let vcod_ret2     = '';
    let vcod_ret3     = '';
    let sql_err       = 0;
    let isam_err      = 0;
    let desc_err      = '';
    let vind_dispon   = '';
    let vstatus_cta   = '';
    let vstatus_tar   = '';
    let vsdo_actual   = 0.00;
    let vsdo_retenido = 0.00;
    let vsdo_cong     = 0.00;
    let vimp_chq_sbg  = 0.00;
    let vsdo_disp     = 0.00;
    -- RQM 09 704. Se inicializa la variable creada. EEAP
    let mSaldoSBC     = 0.00;
    
    begin
    
    on exception set sql_err, isam_err, desc_err
        set debug file to "/resplogifx/conciliachq/cons_sdo_disp.err";
        trace on;
        if sql_err <> 0 then
            let vcod_ret = sql_err;
            let vcod_ret2 = isam_err;
            let vcod_ret3 = desc_err;
            return vcod_ret, vsdo_disp;
        end if;
    end exception;
    
    set isolation to dirty read;
    set lock mode to wait 3;
 
    -- // VALIDA PARAMETROS DE ENTRADA
    if ( pcuenta is null or pcuenta = '' or length(pcuenta) <> 11 ) and ( pnum_tarjeta is null or pnum_tarjeta = '' or length(pnum_tarjeta) <> 16 ) then
        let vcod_ret = '110';
        return vcod_ret, vsdo_disp;
    end if;
    
    -- // VALIDA DISPONIBILIDAD DEL SISTEMA
    select ind_disponible
      into vind_dispon
      from sc_fechas
     where empresa = '001';
    
    if vind_dispon = '0' then
        let vcod_ret = '004';
        return vcod_ret, vsdo_disp;
    end if;
    
    if pnum_tarjeta is not null and pnum_tarjeta <> '' and length(pnum_tarjeta) = 16 then
        -- // VALIDA QUE LA TARJETA ESTE ACTIVA
        select cuenta, status_tar
          into pcuenta, vstatus_tar
          from sc_tarjeta
         where num_tarjeta = pnum_tarjeta;
        
        -- // TARJETA NO EXISTE
        if vstatus_tar is null then
            let vcod_ret = '054';
            return vcod_ret, vsdo_disp;
        end if;
        
        -- // TARJETA INACTIVA
        if vstatus_tar <> 'A' then
            let vcod_ret = '055'; 
            return vcod_ret, vsdo_disp;
        end if;
    end if;
    
    -- // VALIDA LA CUENTA DE CHEQUES
    --RQM 09 704. Se agrega el campo saldo_sbc y la variable mSaldoSBC en la consulta. EEAP
    select status_cta, sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbg, saldo_sbc
      into vstatus_cta, vsdo_actual, vsdo_retenido, vsdo_cong, vimp_chq_sbg, mSaldoSBC
      from sc_maechq
     where cuenta = pcuenta;
     
    -- // CUENTA NO EXISTE
    if vstatus_cta is null then
        let vcod_ret = '100';
        return vcod_ret, vsdo_disp;
    end if;
    
    -- // CUENTA ESTA CANCELADA
    if vstatus_cta in ('2','6','7','8') then
        let vcod_ret = '200';
        return vcod_ret, vsdo_disp;
    end if;
     
    -- // CALCULA SALDO DISPONIBLE
    if vsdo_retenido < 0 then
        let vsdo_retenido = vsdo_retenido * -1;
    end if;
    
    if vsdo_cong < 0 then
        let vsdo_cong = vsdo_cong * -1;
    end if;
    
    if vimp_chq_sbg < 0 then
        let vimp_chq_sbg = vimp_chq_sbg * -1;
    end if;
    
    --RQM 09 704. Se crea la siguiente validacion para la nueva variable mSaldoSBC. EEAP 
    if mSaldoSBC < 0 then
        let mSaldoSBC = mSaldoSBC * -1;
    end if;
    
    --RQM 09 704. Se agrega la variable mSaldoSBC al calculo del saldo disponible. EEAP
    let vsdo_disp = vsdo_actual - vsdo_retenido - vsdo_cong - vimp_chq_sbg - mSaldoSBC;
    
    if vsdo_disp < 0 then
        let vsdo_disp = 0.00;
    end if;
    
    return vcod_ret, vsdo_disp;
           
    end;
    
end procedure


DOCUMENT 
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 02-06-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para considerar un nuevo campo',
'               Se crea una nueva variable mSaldoSBC para almacenar el valor del nuevo campo saldo_sbc',
'               Se agrega la validacion de la nueva variable para valores negativos',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2';

create procedure "informix".cons_sdos1( pempresa char(3), pcuenta char(20), pnum_tarjeta char(16) ) 
returning char(5),      -- cod retorno
          char(20),     -- no. cuenta
          char(20),     -- no. cliente
          char(26),     -- apell paterno
          char(26),     -- apell materno
          char(26),     -- nombre 1
          char(26),     -- nombre 2
          char(60),     -- razon social
          char(1),      -- edo cuenta
          money(14,2),  -- sdo disponible
          money(14,2),  -- sdo retenido
          money(14,2),  -- sdo ccc
          money(14,2),  -- sdo disp ccc
          money(14,2),  -- sdo cuenta
          char(1),      -- tipo de linea
          char(40),     -- producto
          char(40),     -- sdo ccc completo
          money(14,2),  -- sdo t1
          money(14,2),  -- sdo congelado
          money(14,2),  -- sdo sbc
          char(8),      -- usuario bloqueo
          date,         -- fecha bloqueo
          char(16),     -- no tarjeta
          char(18);     -- cta clabe
    
    define vcod_ret         char(5);
    define vcod_ret2        char(5);
    define vcod_ret3        char(50);
    define sql_err          integer;
    define isam_err         integer;
    define desc_err         char(50);
    define vcuenta          char(20);
    define vedo_cta         char(1);
    define vsdo_cta         money(14,2);
    define vsdo_ret         money(14,2);
    define vsdo_cong        money(14,2);
    define vsdo_ccc         money(14,2);
    define vimp_chq_sbc     money(14,2);
    define vtipo_linea      char(1);
    define vsdo_disp        money(14,2);
    define vnro_cte         char(20);
    define vnumero          char(20);
    define vnum_cte         char(20);
    define vimp_sbg_ccc     money(14,2);
    define vsdo_disp_ccc    money(14,2);
    define vsdo_t1          money(14,2);
    define vimp_chq_sbg     money(14,2);
    define vapell_pat       char(26);
    define vapell_mat       char(26);
    define vnombre1         char(26);
    define vnombre2         char(26);
    define vrazon_soc       char(60);
    define vdivisa          char(2);
    define vmoneda          char(30);
    define vproducto        char(4);
    define vprodnom         char(35);
    define vplaza           char(3);
    define vlong_cta        char(2);
    define longitud         smallint;
    define vdescrip1        char(40);
    define vdescrip2        char(40);
    define vfecbloq         date;
    define vusubloq         char(8);
    define vrowid           integer;
    define vnum_tarjeta     char(16);
    define vcta_clabe       char(18);
    define vmarca_ret       char(1);
    define vstatus_tar      char(1);
    define vmotivo          char(2);
    define vind_dispon      char(1);
    define vtpo_persona     char(2);
    define vesfisica        char(1);
    define vdescripcion     char(60);
    -- RQM 09 704. Se crea la siguiente variable. LEOC
    define mSaldoSBC        money(14,2); -- Obtiene el saldo_sbc de la maestra de cheques. 
    
    let vcod_ret      = "000";
    let vcod_ret2     = "";
    let vcod_ret3     = "";
    let sql_err       = 0;
    let isam_err      = 0;
    let desc_err      = "";
    let vcuenta       = pcuenta;
    let vnum_cte      = "";
    let vapell_pat    = " ";
    let vapell_mat    = " ";
    let vnombre1      = " ";
    let vnombre2      = " ";
    let vrazon_soc    = " ";
    let vedo_cta      = "";
    let vsdo_disp     = 0 ;
    let vsdo_ret      = 0 ;
    let vsdo_ccc      = 0 ;
    let vsdo_disp_ccc = 0 ;
    let vsdo_cta      = 0 ;
    let vtipo_linea   = " ";
    let vdescrip1     = "";
    let vdescrip2     = "";
    let vsdo_t1       = 0 ;
    let vsdo_cong     = 0 ;
    let vimp_chq_sbc  = 0;
    let vimp_sbg_ccc  =  0 ;
    let vmoneda       = " ";
    let vdivisa       = " ";
    let vproducto     = " ";
    let vprodnom      = " ";
    let vsdo_cong     = 0;
    let vfecbloq      = "";
    let vusubloq      = " ";
    let vnum_tarjeta  = pnum_tarjeta;
    let vcta_clabe    = "";
    let vimp_chq_sbg  = 0;
    let vstatus_tar   = "";
    let vmotivo       = "";
    let vind_dispon   = '0';
    let vtpo_persona  = '';
    let vesfisica     = '';
    let vdescripcion  = '';
    -- RQM 09 704. Se inicializa la variable creada. LEOC
    let mSaldoSBC  = 0; 
    
    begin
    
    on exception set sql_err, isam_err, desc_err
        set debug file to "/resplogifx/conciliachq/cons_sdos1.err";
        trace on;
        if sql_err <> 0 then
            let vcod_ret = sql_err;
            let vcod_ret2 = isam_err;
            let vcod_ret3 = desc_err;
            let vmoneda = " " ;
            let vprodnom = " ";
            return vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc,
                   vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe;
        end if;
    end exception;
    
    set isolation to dirty read;
    set lock mode to wait 3;
    
    --- set debug file to "/resplogifx/conciliachq/cons_sdos1.out";
    --- trace on;
    
    select ind_disponible
      into vind_dispon
      from sc_fechas
     where empresa = pempresa;
    
    if vind_dispon = '0' then
        let vcod_ret = "004";
        let vmoneda  = " ";
        let vprodnom = " ";
        return vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc,
               vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe;
    end if;
    
    -- // Valida que la Cuenta  no sea Blanco
    if pcuenta = "00000000000" and
        pnum_tarjeta = "0000000000000000" then
        let vcod_ret = "110";
        let vmoneda = " ";
        let vprodnom = " ";
        return vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc,
               vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe;
    end if
    
    -- // Valida exista la cuenta de cheques y extrae los siguientes campos
    if pcuenta = "00000000000" then
        if pnum_tarjeta <> "0000000000000000" then
            select cuenta, numcte, status_tar
              into pcuenta, vnum_cte, vstatus_tar
              from sc_tarjeta
             where empresa = pempresa 
               and num_tarjeta = pnum_tarjeta;

            -- // Si la Tarjeta No esta Activa regresa error
            if vstatus_tar != "A" then
                let vcod_ret = "122";
                return vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc,
                       vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe;
            end if
        end if
    end if
    
    if vnum_cte != "" then
        -- RQM 09 704. Se agrega el campo saldo_sbc a la consulta y se asigna la variable mSaldoSBC. LEOC
        select cuenta, mc.plaza, status_cta, motivo, lim_sbg_ccc, imp_sbg_ccc, tipo_linea, sdo_retenido, sdo_cong, sdo_actual,
               mc.producto, pr.nombre, pr.divisa, di.descripcion, imp_chq_sbc, fec_cancelac, cuenta_clabe, marca_ret, imp_chq_sbg, mc.saldo_sbc
          into vcuenta, vplaza, vedo_cta, vmotivo, vsdo_ccc, vimp_sbg_ccc, vtipo_linea, vsdo_ret, vsdo_cong, vsdo_cta,
               vproducto, vprodnom, vdivisa, vmoneda, vimp_chq_sbc, vfecbloq, vcta_clabe, vmarca_ret, vimp_chq_sbg, mSaldoSBC
          from sc_maechq mc,
               sc_producto pr,
               bdinteg:si_divisas di
         where mc.empresa = pempresa 
           and cuenta = pcuenta
           and pr.empresa = mc.empresa 
           and pr.producto = mc.producto
           and di.empresa = pr.empresa 
           and di.divisa = pr.divisa;
    else
        -- RQM 09 704. Se agrega el campo saldo_sbc a la consulta y se asigna la variable mSaldoSBC. LEOC
        select cuenta, mc.plaza, num_cte, status_cta, motivo, lim_sbg_ccc, imp_sbg_ccc, tipo_linea, sdo_retenido, sdo_cong, sdo_actual,
               mc.producto, pr.nombre, pr.divisa, di.descripcion, imp_chq_sbc, fec_cancelac, cuenta_clabe, marca_ret, imp_chq_sbg, mc.saldo_sbc
          into vcuenta, vplaza, vnum_cte, vedo_cta, vmotivo, vsdo_ccc, vimp_sbg_ccc, vtipo_linea, vsdo_ret, vsdo_cong, vsdo_cta,
               vproducto, vprodnom, vdivisa, vmoneda, vimp_chq_sbc, vfecbloq, vcta_clabe, vmarca_ret, vimp_chq_sbg, mSaldoSBC
          from sc_maechq mc,
               sc_producto pr,
               bdinteg:si_divisas di
         where mc.empresa = pempresa 
           and cuenta = pcuenta
           and pr.empresa = mc.empresa 
           and pr.producto = mc.producto
           and di.empresa = pr.empresa 
           and di.divisa = pr.divisa;
    end if
    
    if vcuenta is null then
        let vcod_ret = "100";
        let vmoneda = " ";
        let vprodnom = " ";
        return vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc,
               vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe;
    end if
    
    if vmarca_ret <> "1" or vmarca_ret is null then
        let vedo_cta = "0";
    end if
    
    -- // Extrae Nombre(s) del Cliente
    select numcte, apell_paterno, nvl(apell_materno,""), nombre1, nvl(nombre2,""), razon_social, tpo_persona
      into vnumero, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vtpo_persona
      from bdinteg:si_cliente
     where numcte = vnum_cte;
    
    select es_fisica 
      into vesfisica 
      from bdinteg:si_tipper
     where tpo_persona = vtpo_persona;
    
    if vesfisica <> "S" then
        select descripcion 
          into vdescripcion 
          from bdinteg:si_ctepm, 
               bdinteg:si_sufijos 
         where numcte = vnum_cte
           and codigo = sufijo;
           
        let vrazon_soc = trim(vrazon_soc)||" "||trim(vdescripcion);			   
    else
        let vrazon_soc = " ";
    end if;
    
    if vapell_pat is null then
        let vapell_pat = " ";
    end if;
    
    if vapell_mat is null then
        let vapell_mat = " ";
    end if;
    
    if vnombre1 is null then
        let vnombre1 = " ";
    end if;
    
    if vnombre2 is null then
        let vnombre2 = " ";
    end if;
    
    if vrazon_soc is null then
        let vrazon_soc = " ";
    end if;
    
    if vnumero is null then
        let vnumero = "0";
    end if
    
    -- // Cliente no Existe
    if vnumero != vnum_cte then
        let vcod_ret = "104";
        let vmoneda = " ";
        return vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc,
               vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe;
    end if
    
    -- // Calcula Saldo Disponible
    if vsdo_ret < 0 then
        let vsdo_ret = vsdo_ret * -1;
    end if
    
    if vsdo_cong < 0 then
        let vsdo_cong = vsdo_cong * -1;
    end if
    
    if vimp_chq_sbg < 0 then
        let vimp_chq_sbg = vimp_chq_sbg * -1;
    end if

    -- RQM 09 704. Se agrega la validacion a la variable mSaldoSBC para que siempre sea un campo positivo. LEOC
    if mSaldoSBC < 0 then
        let mSaldoSBC = mSaldoSBC * -1;
    end if

    -- RQM 09 704. Se agrega la variable mSaldoSBC a la formula del calculo del saldo disponible. LEOC
    let vsdo_disp = vsdo_cta - vsdo_ret - vsdo_cong - vimp_chq_sbg - mSaldoSBC;
    
    if vsdo_disp < 0 then
        let vsdo_disp = 0.00;
    end if;
    
    let vsdo_ret = vsdo_ret + vimp_chq_sbc;
    
    -- // Calcula Saldo Disponible de CCC
    let vsdo_disp_ccc = vsdo_ccc - vimp_sbg_ccc;
    
    if vedo_cta in("3","4","5","8") then
        let vedo_cta = "1";
    end if
    
    -- // Regresa Variables de Salida
    let vdescrip2 = vdivisa||" "||vmoneda;
    let vdescrip1 = vproducto||" "||vprodnom;
    let vsdo_ccc  = vsdo_ccc - vsdo_disp_ccc;
    
    return vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc,
           vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe;
           
    end;
    
end procedure
DOCUMENT
'AUTOR:         N/A',
'DESCRIPCION :  Este procedimiento realiza la consulta de saldos y datos relacionados a una cuenta de captacion, teniendo como parametro de entrada cuenta o la tarjeta ',
'BD :           bdicheq',
'VERSION :      1.0.0',
'FECHA :        N/A',
'----------------------------------------------------',
'MODIFICO :     Luis Enrique Orozco Cosme',
'FECHA :        30-05-2025',
'MODIFICACION : Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo llamado saldo_sbc',
'PROYECTO :     RQM 09 704 Cobranza Automatica en cuentas de captacion',
'VERSION :      1.0.1';

CREATE PROCEDURE "informix".cons_sdos2( pempresa CHAR(3), pcuenta CHAR(20), pnum_tarjeta CHAR(16) )
returning CHAR(5),     --- CODIGO DE RETORNO
          CHAR(20),    --- CUENTA
          CHAR(20),    --- NO. CLIENTE
          CHAR(26),    --- APELL PATERNO
          CHAR(26),    --- APELL MATERNO
          CHAR(26),    --- NOMBRE 1
          CHAR(26),    --- NOMBRE 2
          CHAR(60),    --- RAZON SOCIAL
          CHAR(1),     --- STATUS CUENTA
          MONEY(14,2), --- SALDO DISPONIBLE
          MONEY(14,2), --- SALDO RETENIDO
          MONEY(14,2), --- SALDO CCC
          MONEY(14,2), --- SALDO CCC DISP
          MONEY(14,2), --- SALDO CUENTA
          CHAR(1),     --- TIPO DE LINEA
          CHAR(40),    --- DESCRIPCION 1
          CHAR(40),    --- DESCRIPCION 2
          MONEY(14,2), --- SALDO T1
          MONEY(14,2), --- SALDO CONGELADO
          MONEY(14,2), --- SALDO SBC
          CHAR(8),     --- USUARIO BLOQUEO
          DATE,        --- FECHA BLOQUEO
          CHAR(16),    --- NO. TARJETA
          CHAR(18),    --- CUENTA CLABE
          DATE;        --- FECHA EXP TARJETA
    
    DEFINE vcod_ret          CHAR(5);
    DEFINE vcod_ret2         CHAR(5);
    DEFINE vcod_ret3         CHAR(50);
    DEFINE sql_err           INTEGER;
    DEFINE isam_err          INTEGER;
    DEFINE desc_err          CHAR(50);
    DEFINE vcuenta           CHAR(20);
    DEFINE vedo_cta          CHAR(1);
    DEFINE vsdo_cta          MONEY(14,2);
    DEFINE vsdo_ret          MONEY(14,2);
    DEFINE vsdo_cong         MONEY(14,2);
    DEFINE vsdo_ccc          MONEY(14,2);
    DEFINE vimp_chq_sbc      MONEY(14,2);
    DEFINE vtipo_linea       CHAR(1);
    DEFINE vsdo_disp         MONEY(14,2);
    DEFINE vnro_cte          CHAR(20);
    DEFINE vnumero           CHAR(20);
    DEFINE vnum_cte          CHAR(20);
    DEFINE vimp_sbg_ccc      MONEY(14,2);
    DEFINE vsdo_disp_ccc     MONEY(14,2);
    DEFINE vsdo_t1           MONEY(14,2);
    DEFINE vimp_chq_sbg      MONEY(14,2);
    DEFINE vapell_pat        CHAR(26);
    DEFINE vapell_mat        CHAR(26);
    DEFINE vnombre1          CHAR(26);
    DEFINE vnombre2          CHAR(26);
    DEFINE vrazon_soc        CHAR(60);
    DEFINE vdivisa           CHAR(2);
    DEFINE vmoneda           CHAR(30);
    DEFINE vproducto         CHAR(4);
    DEFINE vprodnom          CHAR(35);
    DEFINE vplaza            CHAR(3);
    DEFINE vlong_cta         CHAR(2);
    DEFINE longitud          SMALLINT;
    DEFINE vdescrip1         CHAR(40);
    DEFINE vdescrip2         CHAR(40);
    DEFINE vfecbloq          DATE;
    DEFINE vusubloq          CHAR(8);
    DEFINE vrowid            INTEGER;
    DEFINE vnum_tarjeta      CHAR(16);
    DEFINE vcta_clabe        CHAR(18);
    DEFINE vmarca_ret        CHAR(1);
    DEFINE vstatus_tar       CHAR(1);
    DEFINE vmotivo           CHAR(2);
    DEFINE sFecExp           DATE;
    DEFINE vind_dispon       CHAR(1);
    DEFINE vind_cierre       CHAR(1);
	DEFINE vtpo_persona      CHAR(2);
    DEFINE vesfisica         CHAR(1);
    DEFINE vdescripcion      CHAR(60);
	DEFINE cCodStatusTarjeta CHAR(3);
     -- RQM 09 704. Se crea la siguiente variable. LEOC
    DEFINE mSaldoSBC        money(14,2); -- Obtiene el saldo_sbc de la maestra de cheques. 
    
    
    LET vcod_ret          = "000";
    LET vcod_ret2         = "";
    LET vcod_ret3         = "";
    LET sql_err           = 0;
    LET isam_err          = 0;
    LET desc_err          = "";
    LET vcuenta           = pcuenta;
    LET vnum_cte          = "";
    LET vapell_pat        = " ";
    LET vapell_mat        = " ";
    LET vnombre1          = " ";
    LET vnombre2          = " ";
    LET vrazon_soc        = " ";
    LET vedo_cta          = "";
    LET vsdo_disp         = 0 ;
    LET vsdo_ret          = 0 ;
    LET vsdo_ccc          = 0 ;
    LET vsdo_disp_ccc     = 0 ;
    LET vsdo_cta          = 0 ;
    LET vtipo_linea       = " ";
    LET vdescrip1         = "";
    LET vdescrip2         = "";
    LET vsdo_t1           = 0 ;
    LET vsdo_cong         = 0 ;
    LET vimp_chq_sbc      = 0;
    LET vimp_sbg_ccc      =  0 ;
    LET vmoneda           = " ";
    LET vdivisa           = " ";
    LET vproducto         = " ";
    LET vprodnom          = " ";
    LET vsdo_cong         = 0;
    LET vfecbloq          = "";
    LET vusubloq          = " ";
    LET vnum_tarjeta      = pnum_tarjeta;
    LET vcta_clabe        = "";
    LET vimp_chq_sbg      = 0;
    LET vstatus_tar       = "";
	LET vmotivo           = "";
	LET sFecExp           = "";
	LET vind_dispon       = '0';
	LET vind_cierre       = '0';
	LET vtpo_persona      = '';
	LET vesfisica         = '';
	LET vdescripcion      = '';
	LET cCodStatusTarjeta = '';
    -- RQM 09 704. Se inicializa la variable creada. LEOC
    let mSaldoSBC  = 0;
	
	BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/cons_sdos2.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcod_ret = sql_err;
            LET vcod_ret2 = isam_err;
            LET vcod_ret3 = desc_err;
            LET vmoneda = " " ;
            LET vprodnom = " ";
            RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, 
                   vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/cons_sdos2.out";	
	--- TRACE ON;
    
    SELECT ind_disponible, ind_cierre
      INTO vind_dispon, vind_cierre
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = pempresa;
    
    IF ( vind_dispon = '0' OR vind_cierre = '0' ) THEN
        LET vcod_ret = "004";
        LET vmoneda  = " ";
        LET vprodnom = " ";
        RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, 
               vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
    END IF;
    
    IF pcuenta = "00000000000" AND pnum_tarjeta = "0000000000000000" THEN
        LET vcod_ret = "110";
        LET vmoneda = " ";
        LET vprodnom = " ";
        RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, 
               vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
    END IF
    
    IF pcuenta = "00000000000" THEN
        IF pnum_tarjeta <> "0000000000000000" THEN
            SELECT codstatustarjeta 
              INTO cCodStatusTarjeta 
              FROM intercard:"informix".tarjeta 
             WHERE numtarjeta = pnum_tarjeta;
            
            IF cCodStatusTarjeta = 'BLO' THEN
                LET vcod_ret = "122";
                RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, 
                       vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
            ELSE
                SELECT cuenta, numcte, status_tar, expiracion, prodtarjeta
                  INTO pcuenta, vnum_cte, vstatus_tar, sFecExp, vproducto
                  FROM bdicheq:"informix".sc_tarjeta
                 WHERE empresa = pempresa 
                   AND num_tarjeta = pnum_tarjeta;
                
                LET sFecExp = DATE(mdy(MONTH(sFecExp), '01', YEAR(sFecExp)));
                
                IF vstatus_tar != "A" THEN
                    LET vcod_ret = "122";
                    RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, 
                           vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
                END IF
                
                IF vproducto = "8000" THEN 
                    -- // Validación para una transacción no permitida con producto 8000
                    LET vcod_ret = "855";
                    LET vproducto = "";
                    RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, 
                           vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
                END IF
            END IF
        END IF
    END IF
    
    IF vnum_cte != "" THEN
        -- RQM 09 704. Se agrega el campo saldo_sbc a la consulta y se asigna la variable mSaldoSBC. LEOC
        SELECT cuenta, mc.plaza, status_cta, motivo, lim_sbg_ccc, imp_sbg_ccc, tipo_linea, sdo_retenido, sdo_cong, sdo_actual, 
               mc.producto, pr.nombre, pr.divisa, di.descripcion, imp_chq_sbc, fec_cancelac, cuenta_clabe, marca_ret, imp_chq_sbg, mc.saldo_sbc
          INTO vcuenta, vplaza, vedo_cta, vmotivo, vsdo_ccc, vimp_sbg_ccc, vtipo_linea, vsdo_ret, vsdo_cong, vsdo_cta, 
               vproducto, vprodnom, vdivisa, vmoneda, vimp_chq_sbc, vfecbloq, vcta_clabe, vmarca_ret, vimp_chq_sbg, mSaldoSBC
          FROM bdicheq:"informix".sc_maechq mc,
               bdicheq:"informix".sc_producto pr,
               bdinteg:"informix".si_divisas di
         WHERE mc.empresa = pempresa 
           AND cuenta = pcuenta
           AND pr.empresa = mc.empresa 
           AND pr.producto = mc.producto
           AND di.empresa = pr.empresa 
           AND di.divisa = pr.divisa;
    ELSE
        -- RQM 09 704. Se agrega el campo saldo_sbc a la consulta y se asigna la variable mSaldoSBC. LEOC
        SELECT cuenta, mc.plaza, num_cte, status_cta, motivo, lim_sbg_ccc, imp_sbg_ccc, tipo_linea, sdo_retenido, sdo_cong, sdo_actual, 
               mc.producto, pr.nombre, pr.divisa, di.descripcion, imp_chq_sbc, fec_cancelac, cuenta_clabe, marca_ret, imp_chq_sbg, mc.saldo_sbc
          INTO vcuenta, vplaza, vnum_cte, vedo_cta, vmotivo, vsdo_ccc, vimp_sbg_ccc, vtipo_linea, vsdo_ret, vsdo_cong, vsdo_cta, 
               vproducto, vprodnom, vdivisa, vmoneda, vimp_chq_sbc, vfecbloq, vcta_clabe, vmarca_ret, vimp_chq_sbg, mSaldoSBC
          FROM bdicheq:"informix".sc_maechq mc,
               bdicheq:"informix".sc_producto pr,
               bdinteg:"informix".si_divisas di
         WHERE mc.empresa = pempresa 
           AND cuenta = pcuenta
           AND pr.empresa = mc.empresa 
           AND pr.producto = mc.producto
           AND di.empresa = pr.empresa 
           AND di.divisa = pr.divisa;
    END IF
    
    IF vcuenta is null THEN
        LET vcod_ret = "100";
        LET vmoneda = " ";
        LET vprodnom = " ";
        RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, 
               vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
    END IF
    
    IF vmarca_ret <> "1" OR vmarca_ret IS NULl THEN
        LET vedo_cta = "0";
    END IF
    
    SELECT numcte, apell_paterno, NVL(apell_materno,""), nombre1, NVL(nombre2,""), razon_social, tpo_persona
      INTO vnumero, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vtpo_persona
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = vnum_cte;
    
    SELECT es_fisica 
      INTO vesfisica 
      FROM bdinteg:"informix".si_tipper
     WHERE tpo_persona = vtpo_persona;
        
    IF vesfisica <> "S" THEN
        SELECT descripcion 
          INTO vdescripcion 
          FROM bdinteg:"informix".si_ctepm, 
               bdinteg:si_sufijos 
         WHERE numcte = vnum_cte
           AND codigo = sufijo;
        
        LET vrazon_soc = TRIM(vrazon_soc)||" "||TRIM(vdescripcion);			   
    ELSE
        LET vrazon_soc = " ";
    END IF;
    
    IF vapell_pat is null THEN
        LET vapell_pat = " ";
    END IF;
    
    IF vapell_mat is null THEN
        LET vapell_mat = " ";
    END IF;
    
    IF vnombre1 is null THEN
        LET vnombre1 = " ";
    END IF;
    
    IF vnombre2 is null THEN
        LET vnombre2 = " ";
    END IF;
    
    IF vrazon_soc is null THEN
        LET vrazon_soc = " ";
    END IF;
    
    IF vnumero is null THEN
        LET vnumero = "0";
    END IF
    
    IF vnumero != vnum_cte THEN
        LET vcod_ret = "104";
        LET vmoneda = " ";
        RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, 
               vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
    END IF
    
    IF vsdo_ret < 0 THEN
        LET vsdo_ret = vsdo_ret * -1;
    END IF
    
    IF vsdo_cong < 0 THEN
        LET vsdo_cong = vsdo_cong * -1;
    END IF
    
    IF vimp_chq_sbg < 0 THEN
        LET vimp_chq_sbg = vimp_chq_sbg * -1;
    END IF

    -- RQM 09 704. Se agrega la validacion a la variable mSaldoSBC para que siempre sea un campo positivo. LEOC
    IF mSaldoSBC < 0 THEN
        let mSaldoSBC = mSaldoSBC * -1;
    END IF
    
    -- RQM 09 704. Se agrega la variable mSaldoSBC a la formula del calculo del saldo disponible. LEOC
    LET vsdo_disp = vsdo_cta - vsdo_ret - vsdo_cong - vimp_chq_sbg - mSaldoSBC;
    
    IF vsdo_disp < 0 THEN
        LET vsdo_disp = 0.00;
    END IF;
    
    LET vsdo_ret = vsdo_ret + vimp_chq_sbc;
    LET vsdo_disp_ccc = vsdo_ccc - vimp_sbg_ccc;
    
    IF vedo_cta IN("3", "4", "5", "8") THEN
        LET vedo_cta = "1";
    END IF
    
    LET vdescrip2 = vdivisa||" "||vmoneda;
    LET vdescrip1 = vproducto||" "||vprodnom;
    LET vsdo_ccc  = vsdo_ccc - vsdo_disp_ccc;
    
    RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, 
           vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
    
    END;
    
END PROCEDURE

DOCUMENT
'FOLIO.........: 1455 - TransferOFI',
'AUTOR.........: 95734511 - José Magdiel Martínez López',
'FECHA.........: 05/06/2014	DSB05062014',
'MODIFICACIÓN..: Se añadio validación para la busqueda por numero de tarjeta, se verifica si el producto es 8000-Transfer.',
'SUSTENTO......: Se definio en el contrato 1455-RQI Transfer-Contrato.pdf',
'SOLICITA......: Berenice Mendez',
'BD............: BDICHEQ',
'----------------------------------------------------',
'Folio: 1730 - OperacionesMayoresConNIP',
'Autor: 95142134 Mario Gallardo',
'Fecha: 02/06/2015',
'Modificación: Se modifica procedimiento para verificar si la tarjeta se encuentra inactiba en la base de datos intercard',
'Sustento: RQM 06 221 Operaciones Mayores con NIP y autorizadas por cajero o gerente.pdf',
'Solicita: Rodolfo Gómez',
'BD: bdicheq',
'----------------------------------------------------',
'MODIFICO :     Luis Enrique Orozco Cosme',
'FECHA :        30-05-2025',
'MODIFICACION : Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo llamado saldo_sbc',
'PROYECTO :     RQM 09 704 Cobranza Automatica en cuentas de captacion',
'VERSION :      1.0.2',
'BD :           bdicheq';

CREATE PROCEDURE "informix".cons_sdos2_web( pempresa CHAR(3),pcuenta  CHAR(20),pnum_tarjeta CHAR(16) )

RETURNING CHAR(5), --- CODIGO DE RETORNO
          CHAR(20), --- CUENTA
          CHAR(20), --- NO. CLIENTE
          CHAR(26), --- APELL PATERNO
          CHAR(26), --- APELL MATERNO
          CHAR(26), --- NOMBRE 1
          CHAR(26), --- NOMBRE 2
          CHAR(60), --- RAZON SOCIAL
          CHAR(1), --- STATUS CUENTA
          MONEY(14,2), --- SALDO DISPONIBLE
          MONEY(14,2), --- SALDO RETENIDO
          MONEY(14,2), --- SALDO CCC
          MONEY(14,2), --- SALDO CCC DISP
          MONEY(14,2), --- SALDO CUENTA
          CHAR(1), --- TIPO DE LINEA
          CHAR(40), --- DESCRIPCION 1
          CHAR(40), --- DESCRIPCION 2
          MONEY(14,2), --- SALDO T1
          MONEY(14,2), --- SALDO CONGELADO
          MONEY(14,2), --- SALDO SBC
          CHAR(8), --- USUARIO BLOQUEO
          DATE, --- FECHA BLOQUEO
          CHAR(16), --- NO. TARJETA
          CHAR(18), --- CUENTA CLABE
          DATE; --- FECHA EXP TARJETA
    
    DEFINE vcod_ret CHAR(5);
	DEFINE vcod_ret2         CHAR(5);
    DEFINE vcod_ret3         CHAR(50);
    DEFINE sql_err           INTEGER;
    DEFINE isam_err          INTEGER;
    DEFINE desc_err          CHAR(50);
    DEFINE vcuenta CHAR(20);
    DEFINE vedo_cta CHAR(1);
    DEFINE vsdo_cta MONEY(14,2);
    DEFINE vsdo_ret MONEY(14,2);
    DEFINE vsdo_cong MONEY(14,2);
    DEFINE vsdo_ccc MONEY(14,2);
    DEFINE vimp_chq_sbc MONEY(14,2);
    DEFINE vtipo_linea CHAR(1);
    DEFINE vsdo_disp MONEY(14,2);
    DEFINE vnro_cte CHAR(20);
    DEFINE vnumero CHAR(20);
    DEFINE vnum_cte CHAR(20);
    DEFINE vimp_sbg_ccc MONEY(14,2);
    DEFINE vsdo_disp_ccc MONEY(14,2);
    DEFINE vsdo_t1 MONEY(14,2);
    DEFINE vimp_chq_sbg MONEY(14,2);
    DEFINE vapell_pat CHAR(26);
    DEFINE vapell_mat CHAR(26);
    DEFINE vnombre1 CHAR(26);
    DEFINE vnombre2 CHAR(26);
    DEFINE vrazon_soc CHAR(60);
    DEFINE vdivisa CHAR(2);
    DEFINE vmoneda CHAR(30);
    DEFINE vproducto CHAR(4);
    DEFINE vprodnom CHAR(35);
    DEFINE vplaza CHAR(3);
    DEFINE vlong_cta CHAR(2);
    DEFINE longitud SMALLINT;
    DEFINE vdescrip1 CHAR(40);
    DEFINE vdescrip2 CHAR(40);
    DEFINE vfecbloq DATE;
    DEFINE vusubloq CHAR(8);
    DEFINE vrowid INTEGER;
    DEFINE vnum_tarjeta CHAR(16);
    DEFINE vcta_clabe CHAR(18);
    DEFINE vmarca_ret CHAR(1);
    DEFINE vstatus_tar CHAR(1);
    DEFINE vmotivo CHAR(2);
    DEFINE sFecExp DATE;
    DEFINE vind_dispon CHAR(1);
    DEFINE vind_cierre CHAR(1);
	DEFINE vtpo_persona CHAR(2);
    DEFINE vesfisica CHAR(1);
    DEFINE vdescripcion CHAR(60);
	DEFINE cCodStatusTarjeta CHAR(3);
	-- RQM 09 704. Se crea la siguiente variable. LEOC
    DEFINE mSaldoSBC        money(14,2); -- Obtiene el saldo_sbc de la maestra de cheques. 
    
    LET vcod_ret = "00000";
	LET vcod_ret2         = "";
    LET vcod_ret3         = "";
    LET sql_err           = 0;
    LET isam_err          = 0;
    LET desc_err          = "";
    LET vcuenta = pcuenta;
    LET vnum_cte = "";
    LET vapell_pat = " ";
    LET vapell_mat = " ";
    LET vnombre1 = " ";
    LET vnombre2 = " ";
    LET vrazon_soc = " ";
    LET vedo_cta = "";
    LET vsdo_disp = 0 ;
    LET vsdo_ret = 0 ;
    LET vsdo_ccc = 0 ;
    LET vsdo_disp_ccc = 0 ;
    LET vsdo_cta = 0 ;
    LET vtipo_linea = " ";
    LET vdescrip1 = "";
    LET vdescrip2 = "";
    LET vsdo_t1 = 0 ;
    LET vsdo_cong = 0 ;
    LET vimp_chq_sbc = 0;
    LET vimp_sbg_ccc  =  0 ;
    LET vmoneda = " ";
    LET vdivisa = " ";
    LET vproducto = " ";
    LET vprodnom = " ";
    LET vsdo_cong = 0;
    LET vfecbloq = "";
    LET vusubloq = " ";
    LET vnum_tarjeta = pnum_tarjeta;
    LET vcta_clabe = "";
    LET vimp_chq_sbg = 0;
    LET vstatus_tar = "";
	LET vmotivo = "";
	LET sFecExp = "";
	LET vind_dispon = '0';
	LET vind_cierre = '0';
	LET vtpo_persona = '';
	LET vesfisica = '';
	LET vdescripcion = '';
	LET cCodStatusTarjeta = '';
	-- RQM 09 704. Se inicializa la variable creada. LEOC
    let mSaldoSBC  = 0;
	
	--SET DEBUG FILE TO "/home/sysifx/Magg/Caja/cons_sdos2.out";	
	--TRACE ON;	
	
    BEGIN

		ON EXCEPTION SET sql_err
			
			IF sql_err <> 0 THEN
				LET vcod_ret = sql_err;
				LET vmoneda = " " ;
				LET vprodnom = " ";

				RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, 
				vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, 
				vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
			END IF;

		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		SELECT ind_disponible, ind_cierre
		INTO vind_dispon, vind_cierre
		FROM bdicheq:"informix".sc_fechas
		WHERE empresa = pempresa;
		 
		IF ( vind_dispon = '0' OR vind_cierre = '0' ) THEN
			LET vcod_ret = "00004";
			LET vmoneda  = " ";
			LET vprodnom = " ";

			RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, 
			vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, 
			vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;			
		END IF;
		
		IF pcuenta = "00000000000" AND pnum_tarjeta = "0000000000000000" THEN
			LET vcod_ret = "00110";
			LET vmoneda = " ";
			LET vprodnom = " ";
		
			RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, 
			vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, 
			vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
			
		END IF
		
		IF pcuenta = "00000000000" THEN
			IF pnum_tarjeta <> "0000000000000000" THEN
				SELECT codstatustarjeta INTO cCodStatusTarjeta FROM intercard:"informix".tarjeta WHERE numtarjeta = pnum_tarjeta;
				IF cCodStatusTarjeta = 'BLO' THEN
					LET vcod_ret = "00122";
					RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, 
					vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, 
					vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
				ELSE
					SELECT cuenta, numcte, status_tar, expiracion, prodtarjeta
					INTO pcuenta, vnum_cte, vstatus_tar, sFecExp, vproducto
					FROM bdicheq:"informix".sc_tarjeta

					WHERE empresa = pempresa 
					AND num_tarjeta = pnum_tarjeta;
				   
					LET sFecExp = DATE(mdy(MONTH(sFecExp), '01', YEAR(sFecExp)));
					
					IF vstatus_tar != "A" THEN
						LET vcod_ret = "00122";

						RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, 
						vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, 
						vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
						
					END IF

					 IF vproducto = "8000" THEN 
						--Validacion para una transaccion no permitida con producto 8000
						LET vcod_ret = "00855";
						LET vproducto="";
						RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, 
						vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, 
						vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
					END IF
				END IF
			END IF
		END IF

	
		IF vnum_cte != "" THEN
        	-- RQM 09 704. Se agrega el campo saldo_sbc a la consulta y se asigna la variable mSaldoSBC. LEOC
			SELECT cuenta, mc.plaza, status_cta, motivo, lim_sbg_ccc, imp_sbg_ccc,
			tipo_linea, sdo_retenido, sdo_cong, sdo_actual, mc.producto, pr.nombre, pr.divisa, 
			di.descripcion, imp_chq_sbc, fec_cancelac, cuenta_clabe, marca_ret, imp_chq_sbg, mc.saldo_sbc
			INTO vcuenta, vplaza, vedo_cta, vmotivo, vsdo_ccc, vimp_sbg_ccc,
			vtipo_linea, vsdo_ret, vsdo_cong, vsdo_cta, vproducto, vprodnom, vdivisa,
			vmoneda, vimp_chq_sbc, vfecbloq, vcta_clabe, vmarca_ret, vimp_chq_sbg, mSaldoSBC
			FROM bdicheq:"informix".sc_maechq mc,
			bdicheq:"informix".sc_producto pr,
			bdinteg:"informix".si_divisas di
			WHERE mc.empresa = pempresa 
			AND cuenta = pcuenta
			AND pr.empresa = mc.empresa 
			AND pr.producto = mc.producto
			AND di.empresa = pr.empresa 
			AND di.divisa = pr.divisa;
		ELSE
		    -- RQM 09 704. Se agrega el campo saldo_sbc a la consulta y se asigna la variable mSaldoSBC. LEOC
			SELECT cuenta, mc.plaza, num_cte, status_cta, motivo, lim_sbg_ccc, imp_sbg_ccc, 
			tipo_linea, sdo_retenido, sdo_cong, sdo_actual, mc.producto, pr.nombre, pr.divisa, 
			di.descripcion, imp_chq_sbc, fec_cancelac, cuenta_clabe, marca_ret, imp_chq_sbg, mc.saldo_sbc
			INTO vcuenta, vplaza, vnum_cte, vedo_cta, vmotivo, vsdo_ccc, vimp_sbg_ccc,
			vtipo_linea, vsdo_ret, vsdo_cong, vsdo_cta, vproducto, vprodnom, vdivisa,
			vmoneda, vimp_chq_sbc, vfecbloq, vcta_clabe, vmarca_ret, vimp_chq_sbg, mSaldoSBC
			FROM bdicheq:"informix".sc_maechq mc,
			bdicheq:"informix".sc_producto pr,
			bdinteg:"informix".si_divisas di
			WHERE mc.empresa = pempresa 
			AND cuenta = pcuenta
			AND pr.empresa = mc.empresa 
			AND pr.producto = mc.producto
			AND di.empresa = pr.empresa 
			AND di.divisa = pr.divisa;
		END IF
		
		IF vcuenta is null THEN
			LET vcod_ret = "00100";
			LET vmoneda = " ";
			LET vprodnom = " ";

			RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, 
			vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, 
			vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
		END IF

		IF vmarca_ret <> "1" OR vmarca_ret IS NULl THEN
			LET vedo_cta = "0";
		END IF
		
		SELECT numcte, apell_paterno, NVL(apell_materno,""), nombre1, NVL(nombre2,""), razon_social, tpo_persona
		INTO vnumero, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vtpo_persona
		FROM bdinteg:"informix".si_cliente
		WHERE numcte = vnum_cte;

		SELECT es_fisica 
		INTO vesfisica 
		FROM bdinteg:"informix".si_tipper
		WHERE tpo_persona = vtpo_persona;
			 
		IF vesfisica <> "S" THEN
			SELECT descripcion 
			INTO vdescripcion 
			FROM bdinteg:"informix".si_ctepm, 
			bdinteg:si_sufijos 
			WHERE numcte = vnum_cte
			AND codigo = sufijo;
			   
			LET vrazon_soc = TRIM(vrazon_soc)||" "||TRIM(vdescripcion);			   
		ELSE

			LET vrazon_soc = " ";
		END IF;

		IF vapell_pat is null THEN
			LET vapell_pat = " ";
		END IF;


		IF vapell_mat is null THEN
			LET vapell_mat = " ";
		END IF;


		IF vnombre1 is null THEN
			LET vnombre1 = " ";
		END IF;


		IF vnombre2 is null THEN
			LET vnombre2 = " ";
		END IF;

		IF vrazon_soc is null THEN
			LET vrazon_soc = " ";
		END IF;

		IF vnumero is null THEN
			LET vnumero = "0";
		END IF
		
		IF vnumero != vnum_cte THEN
			LET vcod_ret = "00104";
			LET vmoneda = " ";

			RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, 
			vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, 
			vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;			
		END IF

		IF vsdo_ret < 0 THEN
			LET vsdo_ret = vsdo_ret * -1;
		END IF
		
		IF vsdo_cong < 0 THEN
			LET vsdo_cong = vsdo_cong * -1;
		END IF
		
		IF vimp_chq_sbg < 0 THEN
			LET vimp_chq_sbg = vimp_chq_sbg * -1;
		END IF
		
		-- RQM 09 704. Se agrega la validacion a la variable mSaldoSBC para que siempre sea un campo positivo. LEOC
	    IF mSaldoSBC < 0 THEN
	        let mSaldoSBC = mSaldoSBC * -1;
	    END IF

    	-- RQM 09 704. Se agrega la variable mSaldoSBC a la formula del calculo del saldo disponible. LEOC
		LET vsdo_disp = vsdo_cta - vsdo_ret - vsdo_cong - vimp_chq_sbg - mSaldoSBC;
		
		IF vsdo_disp < 0 THEN
			LET vsdo_disp = 0.00;
		END IF;
		
		LET vsdo_ret = vsdo_ret + vimp_chq_sbc;
		LET vsdo_disp_ccc = vsdo_ccc - vimp_sbg_ccc;
		
		IF vedo_cta IN("3", "4", "5", "8") THEN
			LET vedo_cta = "1";
		END IF
		
		LET vdescrip2 = vdivisa||" "||vmoneda;
		LET vdescrip1 = vproducto||" "||vprodnom;
		LET vsdo_ccc  = vsdo_ccc - vsdo_disp_ccc;	
		
		RETURN vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, 
		vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, 
		vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, sFecExp;
		
    END;    
END PROCEDURE
DOCUMENT
'FOLIO.........: 1455 - TransferOFI',
'AUTOR.........: 95734511 - Jose Magdiel Martinez Lopez',
'FECHA.........: 05/06/2014	DSB05062014',
'MODIFICACION..: Se aÃ±adio validacion para la busqueda por numero de tarjeta, se verifica si el producto es 8000-Transfer.',
'SUSTENTO......: Se definio en el contrato 1455-RQI Transfer-Contrato.pdf',
'SOLICITA......: Berenice Mendez',
'BD............: BDICHEQ',
'----------------------------------------------------',
'Folio: 1730 - OperacionesMayoresConNIP',
'Autor: 95142134 Mario Gallardo',
'Fecha: 02/06/2015',
'Modificacion: Se modifica procedimiento para verificar si la tarjeta se encuentra inactiva en la base de datos intercard',
'Sustento: RQM 06 221Operaciones Mayores con NIP y autorizadas por cajero o gerente.pdf',
'Solicita: Rodolfo Gomez',
'BD: bdicheq',
'----------------------------------------------------',
'MODIFICO :     Luis Enrique Orozco Cosme',
'FECHA :        30-05-2025',
'MODIFICACION : Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo llamado saldo_sbc',
'PROYECTO :     RQM 09 704 Cobranza Automatica en cuentas de captacion',
'VERSION :      1.0.2',
'BD :           bdicheq';

create procedure "informix".cons_sdos3( pempresa char(3), pcuenta char(20), pnum_tarjeta char(16), ptelefono char(10) ) 
returning char(5),      -- cod retorno
          char(20),     -- no. cuenta
          char(20),     -- no. cliente
          char(26),     -- apell paterno
          char(26),     -- apell materno
          char(26),     -- nombre 1
          char(26),     -- nombre 2
          char(60),     -- razon social
          char(1),      -- edo cuenta
          money(14,2),  -- sdo disponible
          money(14,2),  -- sdo retenido
          money(14,2),  -- sdo ccc
          money(14,2),  -- sdo disp ccc
          money(14,2),  -- sdo cuenta
          char(1),      -- tipo de linea
          char(40),     -- producto
          char(40),     -- sdo ccc completo
          money(14,2),  -- sdo t1
          money(14,2),  -- sdo congelado
          money(14,2),  -- sdo sbc
          char(8),      -- usuario bloqueo
          date,         -- fecha bloqueo
          char(16),     -- no tarjeta
          char(18),     -- cta clabe
		  date;         -- fecha expira tarjeta 
    
    define vcod_ret         char(5);
    define vcod_ret2        char(5);
    define vcod_ret3        char(50);
    define sql_err          integer;
    define isam_err         integer;
    define desc_err         char(50);
    define vcuenta          char(20);
    define vedo_cta         char(1);
    define vsdo_cta         money(14,2);
    define vsdo_ret         money(14,2);
    define vsdo_cong        money(14,2);
    define vsdo_ccc         money(14,2);
    define vimp_chq_sbc     money(14,2);
    define vtipo_linea      char(1);
    define vsdo_disp        money(14,2);
    define vnro_cte         char(20);
    define vnumero          char(20);
    define vnum_cte         char(20);
    define vimp_sbg_ccc     money(14,2);
    define vsdo_disp_ccc    money(14,2);
    define vsdo_t1          money(14,2);
    define vimp_chq_sbg     money(14,2);
    define vapell_pat       char(26);
    define vapell_mat       char(26);
    define vnombre1         char(26);
    define vnombre2         char(26);
    define vrazon_soc       char(60);
    define vdivisa          char(2);
    define vmoneda          char(30);
    define vproducto        char(4);
    define vprodnom         char(35);
    define vplaza           char(3);
    define vlong_cta        char(2);
    define longitud         smallint;
    define vdescrip1        char(40);
    define vdescrip2        char(40);
    define vfecbloq         date;
    define vusubloq         char(8);
    define vrowid           integer;
    define vnum_tarjeta     char(16);
    define vcta_clabe       char(18);
    define vmarca_ret       char(1);
    define vstatus_tar      char(1);
    define vmotivo          char(2);
    define vind_dispon      char(1);
    define vtpo_persona     char(2);
    define vesfisica        char(1);
    define vdescripcion     char(60);
	define vtelefono        char(13);
	define vfec_exp_tar     date;
    -- RQM 09 704. Se crea la siguiente varible. EEAP
    define mSaldoSBC        money(14,2); 
    
    let vcod_ret      = "000";
    let vcod_ret2     = "";
    let vcod_ret3     = "";
    let sql_err       = 0;
    let isam_err      = 0;
    let desc_err      = "";
    let vcuenta       = pcuenta;
    let vnum_cte      = "";
    let vapell_pat    = " ";
    let vapell_mat    = " ";
    let vnombre1      = " ";
    let vnombre2      = " ";
    let vrazon_soc    = " ";
    let vedo_cta      = "";
    let vsdo_disp     = 0 ;
    let vsdo_ret      = 0 ;
    let vsdo_ccc      = 0 ;
    let vsdo_disp_ccc = 0 ;
    let vsdo_cta      = 0 ;
    let vtipo_linea   = " ";
    let vdescrip1     = "";
    let vdescrip2     = "";
    let vsdo_t1       = 0 ;
    let vsdo_cong     = 0 ;
    let vimp_chq_sbc  = 0;
    let vimp_sbg_ccc  =  0 ;
    let vmoneda       = " ";
    let vdivisa       = " ";
    let vproducto     = " ";
    let vprodnom      = " ";
    let vsdo_cong     = 0;
    let vfecbloq      = "";
    let vusubloq      = " ";
    let vnum_tarjeta  = pnum_tarjeta;
    let vcta_clabe    = "";
    let vimp_chq_sbg  = 0;
    let vstatus_tar   = "";
    let vmotivo       = "";
    let vind_dispon   = '0';
    let vtpo_persona  = '';
    let vesfisica     = '';
    let vdescripcion  = '';
	let vtelefono     = ptelefono;
	let vfec_exp_tar  = '';
    -- RQM 09 704. Se inicializa la variable creada. EEAP
    let mSaldoSBC     = 0;
    
    begin
    
    on exception set sql_err, isam_err, desc_err
       -- set debug file to "/informix/c94796696/cons_sdos1.err";
       -- trace on;
        if sql_err <> 0 then
            let vcod_ret = sql_err;
            let vcod_ret2 = isam_err;
            let vcod_ret3 = desc_err;
            let vmoneda = " " ;
            let vprodnom = " ";
            return vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc,
                   vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, vfec_exp_tar;
        end if;
    end exception;
    
    set isolation to dirty read;
    set lock mode to wait 3;
    
    -- set debug file to "/informix/c94796696/cons_sdos1.out";
     --trace on;
    
    select ind_disponible
      into vind_dispon
      from sc_fechas
     where empresa = pempresa;
    
    if vind_dispon = '0' then
        let vcod_ret = "004";
        let vmoneda  = " ";
        let vprodnom = " ";
        return vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc,
               vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, vfec_exp_tar;
    end if;
    
    -- // Valida que la Cuenta  no sea Blanco
    if pcuenta = "00000000000" and pnum_tarjeta = "0000000000000000" and ptelefono = '0000000000' then
        let vcod_ret = "100";
        let vmoneda = " ";
        let vprodnom = " ";
        return vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc,
               vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, vfec_exp_tar;
    end if
	
	    -- // Valida que la Cuenta  no sea nulo
    if pcuenta is null and pnum_tarjeta is null and ptelefono is null then
        let vcod_ret = "100";
        let vmoneda = " ";
        let vprodnom = " ";
        return vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc,
               vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, vfec_exp_tar;
    end if
	
    
    -- // Valida exista la cuenta de cheques y extrae los siguientes campos
    if pcuenta = "00000000000" then
        if pnum_tarjeta <> "0000000000000000" then
            select cuenta, numcte, status_tar, expiracion
              into pcuenta, vnum_cte, vstatus_tar, vfec_exp_tar
              from sc_tarjeta
             where empresa = pempresa 
               and num_tarjeta = pnum_tarjeta;

            -- // Si la Tarjeta No esta Activa regresa error
            if vstatus_tar != "A" then
                let vcod_ret = "122";
                return vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc,
                       vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, vfec_exp_tar;
            end if
		else
            if ptelefono <> '0000000000' then
               select cuenta, num_cte, telefono
                 into pcuenta, vnum_cte, vtelefono
                 from sc_cuenta_telefono
                where telefono = ptelefono;
				
			    if vtelefono is null then
                   let vcod_ret = "100";
                   let vmoneda = " ";
                   let vprodnom = " ";
                   return vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc,
                          vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, vfec_exp_tar;
                end if
			end if
        end if
    end if
    
    if vnum_cte != "" then
        -- RQM 09 704. Se agrega el campo saldo_sbc a la consulta y se asigna la variable mSaldoSBC. EEAP
        select mc.cuenta, mc.plaza, mc.status_cta, mc.motivo, mc.lim_sbg_ccc, mc.imp_sbg_ccc, mc.tipo_linea, mc.sdo_retenido, mc.sdo_cong, mc.sdo_actual,
               mc.producto, pr.nombre, pr.divisa, di.descripcion, mc.imp_chq_sbc, mc.fec_cancelac, mc.cuenta_clabe, mc.marca_ret, mc.imp_chq_sbg, mc.saldo_sbc
          into vcuenta, vplaza, vedo_cta, vmotivo, vsdo_ccc, vimp_sbg_ccc, vtipo_linea, vsdo_ret, vsdo_cong, vsdo_cta,
               vproducto, vprodnom, vdivisa, vmoneda, vimp_chq_sbc, vfecbloq, vcta_clabe, vmarca_ret, vimp_chq_sbg, mSaldoSBC
          from sc_maechq mc,
               sc_producto pr,
               bdinteg:si_divisas di
         where mc.empresa = pempresa 
           and mc.cuenta = pcuenta
           and pr.empresa = mc.empresa 
           and pr.producto = mc.producto
           and di.empresa = pr.empresa 
           and di.divisa = pr.divisa;
    else
        -- RQM 09 704. Se agrega el campo saldo_sbc a la consulta y se asigna la variable mSaldoSBC. EEAP
        select mc.cuenta, mc.plaza, mc.num_cte, mc.status_cta, mc.motivo, mc.lim_sbg_ccc, mc.imp_sbg_ccc, mc.tipo_linea, mc.sdo_retenido, mc.sdo_cong, mc.sdo_actual,
               mc.producto, pr.nombre, pr.divisa, di.descripcion, mc.imp_chq_sbc, mc.fec_cancelac, mc.cuenta_clabe, mc.marca_ret, mc.imp_chq_sbg, mc.saldo_sbc
          into vcuenta, vplaza, vnum_cte, vedo_cta, vmotivo, vsdo_ccc, vimp_sbg_ccc, vtipo_linea, vsdo_ret, vsdo_cong, vsdo_cta,
               vproducto, vprodnom, vdivisa, vmoneda, vimp_chq_sbc, vfecbloq, vcta_clabe, vmarca_ret, vimp_chq_sbg, mSaldoSBC
          from sc_maechq mc,
               sc_producto pr,
               bdinteg:si_divisas di
         where mc.empresa = pempresa 
           and mc.cuenta = pcuenta
           and pr.empresa = mc.empresa 
           and pr.producto = mc.producto
           and di.empresa = pr.empresa 
           and di.divisa = pr.divisa;
    end if
    
    if vcuenta is null then
        let vcod_ret = "100";
        let vmoneda = " ";
        let vprodnom = " ";
        return vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc,
               vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, vfec_exp_tar;
    end if
    
    if vmarca_ret <> "1" or vmarca_ret is null then
        let vedo_cta = "0";
    end if
	
	select limit 1 num_tarjeta, expiracion
	  into vnum_tarjeta, vfec_exp_tar
	  from sc_tarjeta
	 where cuenta = pcuenta
	   and tipo_tarjeta = 'T'
	   and status_tar = 'A';
	
	if vnum_tarjeta is null then
	   let vnum_tarjeta = ' ';
	   let vfec_exp_tar = ' ';
	end if
    
    -- // Extrae Nombre(s) del Cliente
	select numcte, apell_paterno, replace(nvl(apell_materno,""),apell_materno,'***'), nombre1, replace(nvl(nombre2,""),nombre2,'***'), razon_social, tpo_persona
      into vnumero, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vtpo_persona
      from bdinteg:si_cliente
     where numcte = vnum_cte;
    
    select es_fisica 
      into vesfisica 
      from bdinteg:si_tipper
     where tpo_persona = vtpo_persona;
    
    if vesfisica <> "S" then
        select descripcion 
          into vdescripcion 
          from bdinteg:si_ctepm, 
               bdinteg:si_sufijos 
         where numcte = vnum_cte
           and codigo = sufijo;
           
        let vapell_pat  = " ";	
		let vapell_mat  = " ";	
		let vnombre1  = " ";	
		let vnombre2  = " ";	
		
    else
        let vrazon_soc = " ";
    end if;
    
    if vapell_pat is null then
        let vapell_pat = " ";
    end if;
    
    if vapell_mat is null then
        let vapell_mat = " ";
    end if;
    
    if vnombre1 is null then
        let vnombre1 = " ";
    end if;
    
    if vnombre2 is null then
        let vnombre2 = " ";
    end if;
    
    if vrazon_soc is null then
        let vrazon_soc = " ";
    end if;
    
    if vnumero is null then
        let vnumero = "0";
    end if
    
    -- // Cliente no Existe
    if vnumero != vnum_cte then
        let vcod_ret = "104";
        let vmoneda = " ";
        return vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc,
               vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, vfec_exp_tar;
    end if
    
    -- // Calcula Saldo Disponible
    if vsdo_ret < 0 then
        let vsdo_ret = vsdo_ret * -1;
    end if
    
    if vsdo_cong < 0 then
        let vsdo_cong = vsdo_cong * -1;
    end if
    
    if vimp_chq_sbg < 0 then
        let vimp_chq_sbg = vimp_chq_sbg * -1;
    end if

    -- RQM 09 704. Se agrega la validacion a la variable mSaldoSBC para que siempre sea un campo positivo. EEAP
    IF mSaldoSBC < 0 THEN
        let mSaldoSBC = mSaldoSBC * -1;
    END IF
    --RQM 09 704. Se agrega la variable mSaldoSBC al calculo del saldo disponible. EEAP
    let vsdo_disp = vsdo_cta - vsdo_ret - vsdo_cong - vimp_chq_sbg - mSaldoSBC;
    let vsdo_ret = vsdo_ret + vimp_chq_sbc;
    
    -- // Calcula Saldo Disponible de CCC
    let vsdo_disp_ccc = vsdo_ccc - vimp_sbg_ccc;
    
    if vedo_cta in("3","4","5","8") then
        let vedo_cta = "1";
    end if
    
    -- // Regresa Variables de Salida
    let vdescrip2 = vdivisa||" "||vmoneda;
    let vdescrip1 = vproducto||" "||vprodnom;
    let vsdo_ccc  = vsdo_ccc - vsdo_disp_ccc;
    
    return vcod_ret, vcuenta, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc,
           vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe, vfec_exp_tar;
           
    end;
    
end procedure


DOCUMENT 
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 04-06-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para considerar un nuevo campo',
'               Se crea una nueva variable mSaldoSBC para almacenar el valor del nuevo campo saldo_sbc',
'               Se agrega la validacion de la nueva variable para valores negativos',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2';

CREATE PROCEDURE "informix".cons_sdoschq_bpi(pEmpresa char(3),
                                       pCuenta char(20),
                                       pNumTarjeta char(16))
   returning char(5), money(14,2), money(14,2), money(14,2),
                     char(40), money(14,2), char(18);

   -- Modificó: Mauricio León
   -- Actividad: Se agrega instrucción SET ISOLATION
   -- Fecha:  22/06/2009
					 
-- Definición de variables
   define vCodRet             char(5);
   define vCuenta              char(20);
   define vSdoCta             money(14,2);
   define vSdoRet             money(14,2);
   define vSdoCong            money(14,2);
   define vSdoDisp            money(14,2);
   define vImpChqSbg         money(14,2);
   define vProducto            char(4);
   define vProdNom             char(35);
   define vDescripcion            char(40);
   define vCtaClabe           char(18);
   define sql_err              integer;
	--RQM 09 704. Se crea la siguiente variable . DHG
	DEFINE mSaldoSBC  			MONEY; 		--Obtiene el saldo_sbc de la maestra de cheques.
	
--- Inicializa Variables de Salida
    let vCodRet   = "000";
    let vCuenta    = pcuenta;
    let vSdoDisp  = 0 ;
    let vSdoRet   = 0 ;
    let vSdoCta   = 0 ;
    let vDescripcion = "";
    let vSdoCong  = 0 ;
    let vProducto = " ";
    let vProdNom = " ";
    let vCtaClabe = "";
    let vImpChqSbg = 0;
	--RQM 09 704. Se inicializa la siguiente variable generada. DHG
	LET mSaldoSBC				=0.00;


BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         let vCodRet = sql_err;
         RETURN vCodRet, vSdoDisp, vSdoRet, vSdoCta,
                         vDescripcion, vSdoCong, vCtaClabe;
      END IF ;
   END EXCEPTION ;

--SET DEBUG FILE TO "/tmp/cons_sdos1.out";
--TRACE ON;

--- Valida que la Cuenta  no sea Blanco
   IF (pCuenta = "00000000000" or pCuenta="") AND pNumTarjeta = "0000000000000000" THEN
      let vCodRet = "110";
       RETURN vCodRet, vSdoDisp, vSdoRet, vSdoCta,
                         vDescripcion, vSdoCong, vCtaClabe;
   END IF ;

   SET ISOLATION DIRTY READ ;

    IF TRIM(NVL(pCuenta,'')) = '' OR pCuenta IS NULL THEN
        SELECT cuenta INTO vCuenta FROM sc_tarjeta WHERE  empresa = pEmpresa and  num_tarjeta = pNumTarjeta;
    ELSE
        LET vCuenta = pCuenta;
    END IF
		--RQM 09 704. Se agrega la variable mSaldoSBC para almacenar el dato de la columna saldo_sbc. DHG
		SELECT cuenta, sdo_retenido, sdo_cong, sdo_actual,
						mc.producto, pr.nombre, cuenta_clabe, imp_chq_sbg, saldo_sbc
		INTO vCuenta, vSdoRet, vSdoCong, vSdoCta, vProducto, vProdNom, vCtaClabe, vImpChqSbg, mSaldoSBC
		FROM sc_maechq mc,sc_producto pr
		WHERE mc.empresa = pEmpresa AND cuenta = pCuenta
				AND pr.empresa = mc.empresa AND pr.producto = mc.producto;
	
		IF vCuenta IS NULL THEN
			let vCodRet = "100";
			RETURN vCodRet, vSdoDisp, vSdoRet, vSdoCta,
							vDescripcion, vSdoCong, vCtaClabe;
		END IF ;

--- Calcula Saldo Disponible
	--RQM 09 704. Se agrega la variable mSaldoSBC para almacenar el dato de la columna saldo_sbc. DHG
    let vSdoDisp = vSdoCta - vSdoRet - vSdoCong - vImpChqSbg - mSaldoSBC;

    { IF vSdoDisp < 0 THEN
        let vSdoDisp = 0;
    END IF }

--- Regresa Variables de Salida
    let vDescripcion = vProducto || " " || vProdNom;
    RETURN vCodRet, vSdoDisp, vSdoRet, vSdoCta,
                         vDescripcion, vSdoCong, vCtaClabe;

END
END PROCEDURE 
DOCUMENT
'MODIFICO : Daniel Hernandez Garcia',
'FECHA : 29-05-2025',
'MODIFICACION  : Se agrega el valor del campo saldo_sbc en el calculo del saldo disponible',
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2';

CREATE PROCEDURE "informix".sp_cobracominactividad( pEmpresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
    
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vComienza        INTEGER;
    DEFINE vEn_Transacc     SMALLINT;
    DEFINE vContador1       INTEGER;
    DEFINE vContador2       INTEGER;
    DEFINE vContador3       INTEGER;
    
    DEFINE vFecha_Hoy       DATE;
    DEFINE vFecha_Ant       DATE;
    DEFINE vUlt_Dia_Mes     DATE;
    DEFINE vCtaMin          CHAR(20);
    DEFINE vCtaMax          CHAR(20);
    DEFINE vDias_Inact      SMALLINT;
    DEFINE vComision        CHAR(4);
    DEFINE vMtoAplic        DECIMAL(14,2); 
    DEFINE vGenIva          CHAR(1);
    DEFINE vTranCom         CHAR(4);
    DEFINE vTranIva         CHAR(4);
    DEFINE vValorIva        DECIMAL(9,6);
    DEFINE vMontoCOM        DECIMAL(14,2);
    DEFINE vMontoIVA        DECIMAL(14,2);
    DEFINE vUsuario         CHAR(8);
    DEFINE vHora            CHAR(12);
    DEFINE vFolio           CHAR(16);
    DEFINE vDivisa          CHAR(2);
    
    DEFINE vCuenta          CHAR(20);
    DEFINE vSucursal        CHAR(4);
    DEFINE vSdo_Actual      DECIMAL(18,2);
    DEFINE vSdo_Retenido    DECIMAL(18,2);
    DEFINE vSdo_Cong        DECIMAL(18,2);
    DEFINE vCodRet          CHAR(5);
    DEFINE vSdo_Disponible  DECIMAL(18,2);
    DEFINE vTranRet         CHAR(4);
    DEFINE vsdo_desp        DECIMAL(18,2);
    DEFINE vfecultdep       DATE;
    DEFINE vfecultret       DATE;
    DEFINE vfecha_alta      DATE;
    DEFINE vmontomincobroiva DECIMAL(14,2);
    DEFINE vpri_hab_mes     DATE;
    DEFINE vcodretrpt1      CHAR(5);
    DEFINE vcodretrpt2      CHAR(5);
    DEFINE vcodretrpt3      CHAR(50);
	--RQM 09 704. Se crea la siguiente variable . DHG
	DEFINE mSaldoSBC  			MONEY; 		--Obtiene el saldo_sbc de la maestra de cheques.
	
    LET Sql_Err	 = 0;
    LET Isam_Err = 0;
    LET Desc_Err = '';
    LET vCodRet1 = '000';
    LET vCodRet2 = '000';
    LET vCodRet3 = '';
    
    LET vComienza    = -1;
    LET vEn_Transacc = 0;
    LET vContador1   = 0;
    LET vContador2   = 0;
    LET vContador3   = 0;
    
    LET vFecha_Hoy   = '';
    LET vFecha_Ant   = '';
    LET vUlt_Dia_Mes = '';
    LET vCtaMin      = '';
    LET vCtaMax      = '';
    LET vDias_Inact  = 0;
    LET vComision    = '';
    LET vMtoAplic    = 0.00;
    LET vGenIva      = '';
    LET vTranCom     = '';
    LET vTranIva     = '';
    LET vValorIva    = 0;
    LET vMontoCOM    = 0.00;
    LET vMontoIVA    = 0.00;
    LET vUsuario     = 'informix';
    LET vHora        = '';
    LET vFolio       = '';
    LET vDivisa      = '01';
    
    LET vCuenta         = '';
    LET vSucursal       = '';
    LET vSdo_Actual     = 0.00;
    LET vSdo_Retenido   = 0.00;
    LET vSdo_Cong       = 0.00;
    LET vCodRet         = '000';
    LET vSdo_Disponible = 0.00;
    LET vTranRet        = '';
    LET vsdo_desp       = 0.00;
    LET vfecultdep      = '';
    LET vfecultret      = '';
    LET vfecha_alta     = '';
    LET vmontomincobroiva = 0.00;
    LET vpri_hab_mes = ''; 
    LET vcodretrpt1 = '';
    LET vcodretrpt2 = '';
    LET vcodretrpt3 = '';
	--RQM 09 704. Se inicializa la siguiente variable generada. DHG
	LET mSaldoSBC				=0.00;

    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cobracominactividad.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vEn_Transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cobracominactividad.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy, fecha_ant, ult_dia_mes, pri_hab_mes
      INTO vFecha_Hoy, vFecha_Ant, vUlt_Dia_Mes, vpri_hab_mes
      FROM sc_fechas
     WHERE empresa = pEmpresa;
       
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vCtaMin, vCtaMax
      FROM sc_maechq;  

    SELECT valor
      INTO vDias_Inact
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'DiasMaxDeInactividad';
       
    SELECT valor
      INTO vComision
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'ComisionxInactividad';
       
    SELECT monto_aplica, genera_iva, transacc_com, transacc_iva
      INTO vMtoAplic, vGenIva, vTranCom, vTranIva
      FROM sc_comisiones
     WHERE empresa = pEmpresa
       AND comision = vComision;
       
    SELECT valor 
      INTO vValorIva 
      FROM bdinteg:si_param
     WHERE empresa = pEmpresa
       AND cod_param = 47;
       
    SELECT valor
      INTO vmontomincobroiva
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'SdoMinCobrIvaComInac';
       
    IF vGenIva = "N" THEN 
        LET vValorIva = 0;  
    END IF;
    
    LET vHora  = CURRENT HOUR TO FRACTION;
    LET vFolio = vUsuario||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
    
    FOREACH WITH HOLD
		--RQM 09 704. Se agrega la variable mSaldoSBC para almacenar el dato de la columna saldo_sbc. DHG
        SELECT {+INDEX(sc_ctasinact_cobro_comision idx_ctasinact)} 
		       ctas.cuenta, mae.sucursal, mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.fecultdep, mae.fecultret, noc.fecha_alta, mae.saldo_sbc
          INTO vCuenta, vSucursal, vSdo_Actual, vSdo_Retenido, vSdo_Cong, vfecultdep, vfecultret, vfecha_alta, mSaldoSBC
          FROM sc_ctasinact_cobro_comision ctas,
               sc_maechq mae,
               sc_maenoc noc
         WHERE ctas.cuenta = mae.cuenta 
           AND mae.empresa = pEmpresa
           AND mae.cuenta = ctas.cuenta
           AND mae.status_cta = '4'
           AND (((vFecha_Hoy - mae.fecultdep) > vDias_Inact) OR ((vFecha_Hoy - mae.fecultret) > vDias_Inact) OR 
		       (fecultdep is null OR fecultdep = '') OR (fecultret is null OR fecultret = '' ))
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta 
           
        IF vComienza = -1 THEN
            LET vComienza = 0;
            BEGIN WORK;
            LET vEn_Transacc = 1;
        END IF;
        
        LET vContador1 = vContador1 + 1;
        
        IF vfecultdep is null OR vfecultdep = '' THEN
            LET vfecultdep = vfecha_alta;
        END IF;
        
        IF vfecultret is null OR vfecultret = '' THEN
            LET vfecultret = vfecha_alta;
        END IF;
        
        IF ((vFecha_Hoy - vfecultdep) > vDias_Inact) AND ((vFecha_Hoy - vfecultret) > vDias_Inact) THEN
            --RQM 09 704. Se agrega la variable mSaldoSBC en la formula de saldo disponible. DHG
			LET vSdo_Disponible = vSdo_Actual - ( vSdo_Retenido + vSdo_Cong + mSaldoSBC);
            
            IF vSdo_Disponible > 0 THEN
                IF ( vSdo_Disponible <= vmontomincobroiva ) THEN
                    LET vMontoCOM = vSdo_Disponible;
                    LET vMontoIVA = 0.00;
                ELIF ( vSdo_Disponible > vmontomincobroiva ) AND ( vSdo_Disponible <= (vMtoAplic * (1 + vValorIva)) )THEN
                    LET vMontoCOM = ROUND(vSdo_Disponible / (1 + vValorIva), 2);
                    LET vMontoIVA = vSdo_Disponible - vMontoCOM;
                ELIF ( vSdo_Disponible > (vMtoAplic * (1 + vValorIva)) ) THEN
                    LET vMontoCOM = vMtoAplic;
                    LET vMontoIVA = TRUNC(vMtoAplic * vValorIva, 2);
                END IF;
                
                CALL cargon_ref(pEmpresa, vSucursal, vUsuario, vTranCom, "0000", vFolio, vCuenta, 0, vMontoCom, vDivisa, "", "", "")
                RETURNING vCodRet, vTranRet;
                
                -- // Realiza Cobro de Iva
                IF vGenIva = "S" AND vMontoIVA > 0.00 THEN
                    CALL cargon_ref(pEmpresa, vSucursal, vUsuario, vTranIva, "0000", vFolio, vCuenta, 0, vMontoIVA, vDivisa, "", "", "")
                    RETURNING vCodRet, vTranRet;
                END IF;
                
                LET vContador3 = vContador3 + 1;
            END IF;
            
            SELECT sdo_actual
              INTO vsdo_desp
              FROM sc_maechq
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta;
               
            IF vsdo_desp <= 0.00 THEN
                UPDATE sc_maechq
                   SET fecha_proceso = vFecha_Ant
                 WHERE empresa = pEmpresa
                   AND cuenta = vCuenta;
            END IF;
        END IF;
        
        COMMIT WORK;
        BEGIN WORK;

        LET vCuenta         = '';   
        LET vSucursal       = '';     
        LET vSdo_Actual     = 0.00;
        LET vSdo_Retenido   = 0.00;
        LET vSdo_Cong       = 0.00;
        LET vSdo_Disponible = 0.00;
        LET vMontoCOM       = 0.00;
        LET vMontoIVA       = 0.00;
        LET vTranRet        = '';
        LET vCodRet         = '000';
        LET vsdo_desp       = 0.00;
        LET vfecultdep      = '';
        LET vfecultret      = '';
        LET vfecha_alta     = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    IF LPAD(DAY(vFecha_Hoy),2,'0') = '03' THEN
        CALL sp_rptcobrocominactividad(pEmpresa)
        RETURNING vcodretrpt1, vcodretrpt2, vcodretrpt3;
        
        IF vcodretrpt1 <> '000' THEN
            LET vCodRet1 = vcodretrpt1;
            LET vCodRet2 = vcodretrpt2;
            LET vCodRet3 = 'REPORTE COBRO COMISION INACTIVIDAD FALLO VERIFIQUE';
        END IF;
        
        CALL sp_rptctasinact(pEmpresa)
        RETURNING vcodretrpt1, vcodretrpt2, vcodretrpt3;
        
        IF vcodretrpt1 <> '000' THEN
            LET vCodRet1 = vcodretrpt1;
            LET vCodRet2 = vcodretrpt2;
            LET vCodRet3 = 'REPORTE CUENTAS INACTIVAS FALLO VERIFIQUE';
        END IF;
    END IF;
    
    END;

    RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador3;

END PROCEDURE
DOCUMENT
'MODIFICO : Daniel Hernandez Garcia',
'FECHA : 05-06-2025',
'MODIFICACION  : Se agrega el valor del campo saldo_sbc en el calculo del saldo disponible',
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : BDICHEQ',
'VER   : 1.1';

create procedure "informix".cons_chq(pempresa char(3), pnum_cte char(20), pmoneda char(2))
returning char(5),char(20), DECIMAL(14,2);

    -- ***************************************************************************
    -- Define variables
    -- ***************************************************************************
    define cod_ret char(5);
    define sql_err integer;
    define v_numcte,v_cuenta char(20);
    define longitud,v_long_cte smallint;
    define prenglon, v_conta, v_ciclo smallint;
    define v_sdoactual, v_sdoretenido, v_sdocong, v_sdodisp,
    v_limccc, v_impccc, v_dispccc DECIMAL(14,2);
    --RQM 09 704. Se crea la siguiente variable "mSaldoSBC". EEAP 
    define mSaldoSBC money(14,2);
    define v_venccc, v_fechoy date;
    define vprodcrec char(4);

    -- ***************************************************************************
    -- Inicializa variables
    -- ***************************************************************************
    let cod_ret       = "000";
    let v_cuenta      = " ";
    let v_conta       = 0;
    let v_ciclo       = 0;
    let prenglon      = 0;
    LET v_sdoactual   =0;
    LET v_sdoretenido =0;
    LET v_sdocong     =0;
    LET v_sdodisp     =0;
    LET vprodcrec     = "";
    -- RQM 09 704. Se inicializa la variable creada. EEAP
    LET mSaldoSBC     =0;
    
    --set debug file to "cons_chq.out";
    --trace on;

    begin
    
    on exception set sql_err
        if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret,v_cuenta, v_sdodisp;
        end if
    end exception;
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION  TO DIRTY READ;


    select fecha_hoy 
      into v_fechoy
      from sc_fechas 
     where empresa = pempresa;

    select numcte 
      into v_numcte 
      from bdinteg:si_cliente
     where numcte = pnum_cte;
     
    if v_numcte is null then
        let cod_ret = "104";
        return cod_ret,v_cuenta, v_sdodisp;
    end if

    -- Carga el Parametro del Producto Creciente
    SELECT valor 
      INTO vprodcrec
      FROM sc_param
     WHERE codparam = "PRODCREC"
       AND empresa = pempresa;

    let v_conta = 0;
    
    foreach
        --RQM 09 704. Se agrega el campo saldo_sbc y la variable mSaldoSBC en la consulta. EEAP
        select cuenta, sdo_actual, sdo_retenido, sdo_cong, lim_sbg_ccc, imp_sbg_ccc, fech_venc_ccc, saldo_sbc 
          into v_cuenta, v_sdoactual, v_sdoretenido, v_sdocong, v_limccc, v_impccc, v_venccc, mSaldoSBC
          from sc_maechq mc, 
               sc_producto pr
         where mc.empresa = pempresa 
           and mc.empresa = pr.empresa 
           and mc.producto = pr.producto 
           and mc.num_cte = pnum_cte 
           and mc.status_cta not in("2","6","7")
           and pr.divisa = pmoneda
           and mc.producto != vprodcrec
         order by cuenta
         
        if v_cuenta is null then
            let cod_ret = 100;
            return cod_ret,v_cuenta, v_sdodisp;
        end if
        
        let v_dispccc = v_limccc - v_impccc;
        
        if v_dispccc is null then
            let v_dispccc = 0;
        end if
        
        if v_dispccc > 0 and v_venccc < v_fechoy then
            let v_dispccc = 0;
        end if
        
        --RQM 09 704. Se agrega la variable mSaldoSBC al calculo del saldo disponible. EEAP
        LET v_sdodisp = v_sdoactual - v_sdoretenido - v_sdocong - mSaldoSBC + v_dispccc;
        let v_conta = v_conta + 1;
        let v_ciclo = v_ciclo + 1;
        
        if v_ciclo <= prenglon then
            continue foreach;
        end if;
        
        return cod_ret, v_cuenta, v_sdodisp WITH RESUME;
    end foreach
    
    end
    
end procedure


DOCUMENT 
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 02-06-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para considerar un nuevo campo',
'               Se crea una nueva variable mSaldoSBC para almacenar el valor del nuevo campo saldo_sbc',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2';

CREATE PROCEDURE "informix".sc_cons_ctasdos_bpi_mx(pempresa CHAR(3),
                                                pnum_cte CHAR(20),
                                                pRegistro SMALLINT )
returning char(5), char(20), money(14,2), money(14,2), money(14,2), char(40), money(14,2), char(18), char(1),char(1),char(1);

					 
    -- Definicion de variables
    define vCodRet             char(5);
    define vCuenta              char(20);
    define vSdoCta             money(14,2);
    define vSdoRet             money(14,2);
    define vSdoCong            money(14,2);
    define vSdoDisp            money(14,2);
    define vImpChqSbg         money(14,2);
    define vProducto            char(4);
    define vProdNom             char(35);
    define vDescripcion            char(40);
    define vCtaClabe           char(18);
    define sql_err              integer;
    define iCont		integer;
	define vedo_cta             char(1);
	DEFINE vstatus_serv		char(1);
	DEFINE vcPortabilidadFlag	char(1);
	--RQM 09 704. Se crea la siguiente variable . DHG
	DEFINE mSaldoSBC  			MONEY; 		--Obtiene el saldo_sbc de la maestra de cheques.
	
    --- Inicializa Variables de Salida
    let vCodRet   = "000";
    let vCuenta    = "";
    let vSdoDisp  = 0 ;
    let vSdoRet   = 0 ;
    let vSdoCta   = 0 ;
    let vDescripcion = "";
    let vSdoCong  = 0 ;
    let vProducto = " ";
    let vProdNom = " ";
    let vCtaClabe = "";
    let vImpChqSbg = 0;
    let iCont =0;
	let vedo_cta   = "";
	LET vstatus_serv	= "";
	LET vcPortabilidadFlag = "";
	--RQM 09 704. Se inicializa la siguiente variable generada. DHG
	LET mSaldoSBC				=0.00;

	-- ***************************************************************************        
    -- Objetivo:            Consulta las cuentas efectivas
    -- Creado por:			Autor desconocido
    -- ModIFicacion por:    Walber Castro
    -- Ultima ModIFicacion: 2012/07/04    
    -- Razon:				Se agrega parametro de salida del status de la cuenta
    -- ***************************************************************************
    -- Modificacion por:    Roberto Castro
    -- Ultima Modificacion: 2014/03/24    
    -- Razon:				Se agrega parametro de salida del status del servicio
	--						de emision de estados de cuenta CFDI
    -- ***************************************************************************
    -- Modificacion por:    Moises Soriano
    -- Ultima Modificacion: 2015/02/15    
    -- Razon:				Se agrega parametro de salida del status del servicio
	--						de portabilidad de nomina.
    -- ***************************************************************************
    -- Modifico:    		Daniel Hernandez Garcia
    -- Fecha: 				05-06-2025    
    -- Modificacion: 		Se agrega el valor del campo saldo_sbc en el calculo del saldo disponible
	-- PROYECTO: 			RQM 09 704 Cobranza Automatica en cuentas de captacion
	-- BD    : 				bdicheq
	-- VERSION:				1.5
	-- ***************************************************************************
	
    BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            let vCodRet = sql_err;
            RETURN vCodRet, vCuenta, vSdoDisp, vSdoRet, vSdoCta, vDescripcion, vSdoCong, vCtaClabe, vedo_cta, vstatus_serv,vcPortabilidadFlag;
        END IF ;
    END EXCEPTION ;

    --SET DEBUG FILE TO "/home/sysifx/moises/bdicheq/cons_sdos1.out";
    --TRACE ON;

    --- Valida que el cliente no sea Blanco
    IF pnum_cte = "000000000" THEN
        let vCodRet = "110";
        RETURN vCodRet, vCuenta, vSdoDisp, vSdoRet, vSdoCta, vDescripcion, vSdoCong, vCtaClabe, vedo_cta, NVL(vstatus_serv, ""),NVL(vcPortabilidadFlag,"0");
    END IF ;

    SET ISOLATION DIRTY READ ;
	SET LOCK MODE TO WAIT 3;

    FOREACH
        --RQM 09 704. Se agrega la variable mSaldoSBC para almacenar el dato de la columna saldo_sbc. DHG
		SELECT SKIP pRegistro FIRST 10  mc.cuenta, mc.sdo_retenido, mc.sdo_cong, mc.sdo_actual,
               mc.producto, pr.nombre, mc.cuenta_clabe, mc.imp_chq_sbg, mc.status_cta, mc.saldo_sbc
          INTO vCuenta, vSdoRet, vSdoCong, vSdoCta, vProducto, vProdNom, vCtaClabe, vImpChqSbg, vedo_cta, mSaldoSBC
          FROM bdicheq:"informix".sc_maechq as mc, bdicheq:"informix".sc_producto as pr
     --- WHERE num_cte = pnum_cte 
         WHERE mc.num_cte = pnum_cte
           AND mc.status_cta not in ('2')
           AND pr.empresa = mc.empresa 
           AND pr.producto = mc.producto
         ORDER BY mc.cuenta

		--RQM 09 704. Se agrega la variable mSaldoSBC en el calculo de saldo disponible. DHG
        let vSdoDisp = vSdoCta - vSdoRet - vSdoCong - vImpChqSbg - mSaldoSBC;

        /* ####################
        IF vSdoDisp < 0 THEN
            let vSdoDisp = 0;
        END IF 
        #################### */

        LET iCont = iCont + 1;

        let vDescripcion = vProducto || " " || vProdNom;
		
		SELECT status_serv_elec
		INTO vstatus_serv
		FROM bdiedoelec:"informix".edelec_alta_serv
		WHERE cuenta = vCuenta;
		
		SELECT CASE WHEN estatus = '01' THEN '1' ELSE '0' END
		INTO vcPortabilidadFlag
		FROM bdicheq:"informix".sc_portabilidadnomina
		WHERE cuenta_abono = vCuenta
		AND cliente = pnum_cte
		AND estatus = '01';

        RETURN vCodRet, vCuenta, vSdoDisp, vSdoRet, vSdoCta, vDescripcion, vSdoCong, vCtaClabe, vedo_cta, NVL(vstatus_serv, ""),NVL(vcPortabilidadFlag,"0") WITH RESUME;
    END FOREACH;
    
    IF ( iCont = 0 AND pRegistro = 0 ) THEN
        LET vCodRet = '101'; --- Cliente No tiene cuentas
        RETURN vCodRet, vCuenta, vSdoDisp, vSdoRet, vSdoCta, vDescripcion, vSdoCong, vCtaClabe, vedo_cta, NVL(vstatus_serv, ""),NVL(vcPortabilidadFlag,"0");
    END IF

    END
    
END PROCEDURE 
DOCUMENT
'MODIFICO : Daniel Hernandez Garcia',
'FECHA : 05-06-2025',
'MODIFICACION  : Se agrega el valor del campo saldo_sbc en el calculo del saldo disponible',
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.1';

CREATE PROCEDURE "informix".sc_cons_ctasdos_bpi( pempresa CHAR(3), pnum_cte CHAR(20), pRegistro SMALLINT )
returning char(5), char(20), money(14,2), money(14,2), money(14,2), char(40), money(14,2), char(18), char(1),char(1),char(1);
    
    -- ***************************************************************************        
    -- Objetivo:            Consulta las cuentas efectivas
    -- Creado por:			Autor desconocido
    -- ModIFicacion por:    Walber Castro
    -- Ultima ModIFicacion: 2012/07/04    
    -- Razon:				Se agrega parametro de salida del status de la cuenta
    -- ***************************************************************************
    -- Modificacion por:    Roberto Castro
    -- Ultima Modificacion: 2014/03/24    
    -- Razon:				Se agrega parametro de salida del status del servicio
	--						de emision de estados de cuenta CFDI
    -- ***************************************************************************
    -- Modificacion por:    Moises Soriano
    -- Ultima Modificacion: 2015/02/15    
    -- Razon:				Se agrega parametro de salida del status del servicio
	--						de portabilidad de nomina.
    -- ***************************************************************************
    --Modificado por:       Eric E. Armenta Perez
    --Ultima mpodificacion: 2025/06/03
    --Razon:                Se agrega la nueva variable sdo_sbc (saldo buen cobro) 
    --                      a la operacion aritmetica para el nuevo calculo de 
    --                      saldo disponible.
    -- ***************************************************************************


    --- Definicion de variables
    define vCodRet char(5);
    define vCodRet2 char(5);
    define vCodRet3 char(80);
    define sql_err integer;
    define isam_err integer;
    define desc_err char(80);
    define vCuenta char(20);
    define vSdoCta money(14,2);
    define vSdoRet money(14,2);
    define vSdoCong money(14,2);
    define vSdoDisp money(14,2);
    define vImpChqSbg money(14,2);
    --RQM 09 704. Se crea la siguiente variable. EEAP 
    define mSaldoSBC money(14,2);
    define vProducto char(4);
    define vProdNom char(35);
    define vDescripcion char(40);
    define vCtaClabe char(18);
    define iCont integer;
	define vedo_cta char(1);
	DEFINE vstatus_serv char(1);
	DEFINE vcPortabilidadFlag char(1);

    --- Inicializa Variables de Salida
    let vCodRet = "000";
    let vCodRet2 = "";
    let vCodRet3 = "";
    let sql_err = 0;
    let isam_err = 0;
    let desc_err = "";
    let vCuenta = "";
    let vSdoDisp = 0 ;
    let vSdoRet = 0 ;
    let vSdoCta = 0 ;
    let vDescripcion = "";
    let vSdoCong = 0 ;
    let vProducto = " ";
    let vProdNom = " ";
    let vCtaClabe = "";
    let vImpChqSbg = 0;
    -- RQM 09 704. Se inicializa la variable creada. EEAP
    let mSaldoSBC = 0;
    let iCont = 0;
	let vedo_cta = "";
	LET vstatus_serv = "";
	LET vcPortabilidadFlag = "";
	
	BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sc_cons_ctasdos_bpi.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vCodRet = sql_err;
            LET vCodRet2 = isam_err;
            LET vCodRet3 = desc_err;
            RETURN vCodRet, vCuenta, vSdoDisp, vSdoRet, vSdoCta, vDescripcion, vSdoCong, vCtaClabe, vedo_cta, vstatus_serv,vcPortabilidadFlag;
        END IF ;
    END EXCEPTION ;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sc_cons_ctasdos_bpi.out";
    --- TRACE ON;

    --- Valida que el cliente no sea Blanco
    IF pnum_cte = "000000000" THEN
        let vCodRet = "110";
        RETURN vCodRet, vCuenta, vSdoDisp, vSdoRet, vSdoCta, vDescripcion, vSdoCong, vCtaClabe, vedo_cta, NVL(vstatus_serv, ""),NVL(vcPortabilidadFlag,"0");
    END IF ;

    SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;

    FOREACH
        SELECT {+INDEX(bdicheq:sc_maechq maecheques), 
                +INDEX(bdicheq:sc_producto idxscproductopba)}
               SKIP pRegistro FIRST 10  
                --RQM 09 704. Se agrega el campo saldo_sbc y la variable mSaldoSBC en la consulta. EEAP
               mc.cuenta, mc.sdo_retenido, mc.sdo_cong, mc.sdo_actual, mc.producto, pr.nombre, mc.cuenta_clabe, mc.imp_chq_sbg, mc.status_cta, mc.saldo_sbc
          INTO vCuenta, vSdoRet, vSdoCong, vSdoCta, vProducto, vProdNom, vCtaClabe, vImpChqSbg, vedo_cta, mSaldoSBC
          FROM bdicheq:sc_maechq as mc, 
               bdicheq:sc_producto as pr
         WHERE mc.num_cte = pnum_cte
           AND mc.status_cta in ('1','3','4','5')
           AND pr.producto = mc.producto
         ORDER BY mc.cuenta
         
        IF vSdoRet < 0 THEN 
            LET vSdoRet = vSdoRet * -1; 
        END IF;
        
        IF vSdoCong < 0 THEN 
            LET vSdoCong = vSdoCong * -1; 
        END IF;
        
        IF vImpChqSbg < 0 THEN 
            LET vImpChqSbg = vImpChqSbg * -1;
        END IF;
        
        --RQM 09 704. Se crea la siguiente validacion para la nueva variable mSaldoSBC. EEAP 
        IF mSaldoSBC < 0 THEN 
            LET mSaldoSBC = mSaldoSBC * -1;
        END IF;
        
        --RQM 09 704. Se agrega la variable mSaldoSBC al calculo del saldo disponible. EEAP
        LET vSdoDisp = vSdoCta - vSdoRet - vSdoCong - vImpChqSbg - mSaldoSBC;
        
        /* ####################
        IF vSdoDisp < 0 THEN
            let vSdoDisp = 0;
        END IF 
        #################### */

        LET iCont = iCont + 1;

        LET vDescripcion = vProducto || " " || vProdNom;
		
		SELECT {+INDEX(bdiedoelec:edelec_alta_serv idx02_edelec_alta_serv)}
               status_serv_elec
		  INTO vstatus_serv
		  FROM bdiedoelec:edelec_alta_serv
		 WHERE cuenta = vCuenta;
		
		SELECT CASE WHEN estatus = '01' THEN '1' ELSE '0' END
		  INTO vcPortabilidadFlag
		  FROM bdicheq:sc_portabilidadnomina
		 WHERE empresa = pempresa
           AND cliente = pnum_cte
           AND cuenta_abono = vCuenta
		   AND secuencia > 0
		   AND estatus = '01';

        RETURN vCodRet, vCuenta, vSdoDisp, vSdoRet, vSdoCta, vDescripcion, vSdoCong, vCtaClabe, vedo_cta, NVL(vstatus_serv, ""),NVL(vcPortabilidadFlag,"0") WITH RESUME;
    END FOREACH;
    
    IF ( iCont = 0 AND pRegistro = 0 ) THEN
        LET vCodRet = '101'; --- Cliente No tiene cuentas
        RETURN vCodRet, vCuenta, vSdoDisp, vSdoRet, vSdoCta, vDescripcion, vSdoCong, vCtaClabe, vedo_cta, NVL(vstatus_serv, ""),NVL(vcPortabilidadFlag,"0");
    END IF

    END
    
END PROCEDURE;