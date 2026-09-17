create procedure "informix".conciliadebito(pempresa char(3),
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