CREATE PROCEDURE "informix".sp_renuevapagares( pempresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;
    
    DEFINE GLOBAL vgusuario     CHAR(8) DEFAULT " ";
    DEFINE GLOBAL vgfecha_hoy   DATE    DEFAULT " ";
    DEFINE GLOBAL vgprox_fecha   DATE    DEFAULT " ";

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE vsqlerr          INTEGER;
    DEFINE visamerr         INTEGER;
    DEFINE vdescerr         CHAR(50);
    DEFINE vcontador1       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vsql             CHAR(200);
    DEFINE vstmt            CHAR(100);
    DEFINE vcodret          CHAR(5);
    DEFINE vpaso            CHAR(10);
    DEFINE vnum_cte         CHAR(20);
    DEFINE vcuenta          CHAR(20);
    DEFINE vfecha_venc      DATE;
    DEFINE vcta_cheques     CHAR(20);
    DEFINE vmonto           MONEY(14,2);
    DEFINE vsecuencia       SMALLINT;
    DEFINE vsucursal        CHAR(4);
    DEFINE vpromotor        CHAR(8);
    DEFINE vplaza           CHAR(3);
    DEFINE vhora            CHAR(15);
    DEFINE vfoliosuc        CHAR(16);
    DEFINE vtotal           MONEY(14,2);
    DEFINE vplazo           SMALLINT;
    DEFINE vcod_instrum     CHAR(4);
    DEFINE vplazo_nva       SMALLINT;
    DEFINE vfecha_nva       DATE;
    DEFINE vctanva          CHAR(20);
    DEFINE vsecnva          SMALLINT;
    DEFINE vper_acred_int   CHAR(1);
    DEFINE vcobraisr        CHAR(1);
    DEFINE visr_nvo         MONEY(14,2);
    DEFINE vintnet_nva      MONEY(14,2);
    DEFINE vtasa_nva        DECIMAL(9,6);
    DEFINE vtasaisr_nva     DECIMAL(9,6);
    DEFINE vtasaneta_nva    DECIMAL(9,6);
    DEFINE vstatus_cta      CHAR(1);
    DEFINE vsdo_cong        MONEY(14,2);
    DEFINE vprovdia         DECIMAL(14,6);
    DEFINE vtrans_cap       CHAR(4);
    DEFINE vtrans_int       CHAR(4);
    DEFINE vtrans_isr       CHAR(4);
    DEFINE vtrans_vtopas1   CHAR(4);
    DEFINE vtrans_vtopas2   CHAR(4);
    DEFINE vtrans_prov      CHAR(4);
    DEFINE vtrans_proval    CHAR(4);
    DEFINE vtrans_intval    CHAR(4);
    DEFINE vtrans_isrval    CHAR(4);
    DEFINE vtrans_reinv     CHAR(4);
    DEFINE vinteres         MONEY(14,2);
    DEFINE vdiasmact        SMALLINT;
    DEFINE vprovision       MONEY(14,2);
    DEFINE vdiasmsig        SMALLINT;
    
    LET vcodret1        = '';
    LET vcodret2        = '';
    LET vcodret3        = '';
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
    LET vcontador1      = 0;
    LET ven_transacc    = 0; 
    
    LET vsql           = '';
    LET vstmt          = '';
    LET vcodret        = '';
    LET vpaso          = '';
    LET vgfecha_hoy    = '';
    LET vnum_cte       = '';
    LET vcuenta        = '';
    LET vfecha_venc    = '';
    LET vcta_cheques   = '';
    LET vmonto         = 0.00;
    LET vsecuencia     = 0;
    LET vsucursal      = '';
    LET vpromotor      = '';
    LET vplaza         = '';
    LET vhora          = '';
    LET vfoliosuc      = '';
    LET vtotal         = 0.00;
    LET vplazo         = 0;
    LET vcod_instrum   = '';
    LET vplazo_nva     = 0;
    LET vfecha_nva     = '';
    LET vctanva        = '';
    LET vsecnva        = 0;
    LET vper_acred_int = '';
    LET vgusuario      = 'informix';
    LET vcobraisr      = '';
    LET visr_nvo       = 0.00;
    LET vintnet_nva    = 0.00;
    LET vtasa_nva      = 0;
    LET vtasaisr_nva   = 0;
    LET vtasaneta_nva  = 0;
    LET vstatus_cta    = '';
    LET vsdo_cong      = 0.00;
    LET vprovdia       = 0;
    LET vtrans_cap     = '';
    LET vtrans_int     = '';
    LET vtrans_isr     = '';
    LET vtrans_vtopas1 = '';
    LET vtrans_vtopas2 = '';
    LET vtrans_prov    = '';
    LET vtrans_proval  = '';
    LET vtrans_intval  = '';
    LET vtrans_isrval  = '';
    LET vtrans_reinv   = '';
    LET vinteres       = 0.00;
    LET vdiasmact      = 1;
    LET vprovision     = 0.00;
    LET vdiasmsig      = 0;
    
    BEGIN

    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET debug file to "/resplogifx/conciliachq/sp_renuevapagares.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret1 = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1;
        END IF;
    END EXCEPTION;
    
    --- SET debug file to "/resplogifx/conciliachq/sp_renuevapagares.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sv_pagaresrenovados') THEN
        DROP TABLE "informix".sv_pagaresrenovados;
    END IF;
    
    CREATE TABLE "informix".sv_pagaresrenovados
      (
        cuenta      char(20)    not null,
        secuencia   smallint    not null,
        plazo       smallint    not null,
        fecha_venc  date        not null,
        monto       money(18,2) not null,
        tasa        decimal(9,6) not null,
        intereses   money(18,2) not null,
        isr         money(18,2) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_pagrenov ON "informix".sv_pagaresrenovados(cuenta) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE sv_pagaresrenovados;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'pagaresxrenovar') THEN
        DROP TABLE "informix".pagaresxrenovar;
    END IF;
    
    CREATE TABLE "informix".pagaresxrenovar
      (
        cuenta      char(20)    not null,
        fecha_venc  date        not null,
        cta_cheques char(20)    not null,
        monto       money(18,2) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_pagxrenov ON "informix".pagaresxrenovar(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/pagares_a_renovar_1.unl DELIMITER ''","'' INSERT INTO pagaresxrenovar" > /resplogifx/conciliachq/pagaresxrenov.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/pagaresxrenov.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE pagaresxrenovar;
    
    SELECT fecha_hoy, prox_fecha
      INTO vgfecha_hoy, vgprox_fecha
      FROM sv_fechas
     WHERE empresa = pempresa;
    
    FOREACH WITH HOLD
        SELECT pag.cuenta, pag.fecha_venc, pag.cta_cheques, pag.monto, 
               mae.num_cte, mae.secuencia, mae.sucursal, mae.promotor, mae.plaza, mae.cod_instrum, 
               mae.per_acred_int, mae.cobraisr, mae.status_cta, mae.sdo_cong, 
               ins.trans_cap, ins.trans_int, ins.trans_isr, ins.trans_vtopas1, ins.trans_vtopas2, 
               ins.trans_prov, ins.trans_proval, ins.trans_intval, ins.trans_isrval, ins.trans_reinv
          INTO vcuenta, vfecha_venc, vcta_cheques, vmonto, 
               vnum_cte, vsecuencia, vsucursal, vpromotor, vplaza, vcod_instrum, vper_acred_int, vcobraisr, vstatus_cta, vsdo_cong,
               vtrans_cap, vtrans_int, vtrans_isr, vtrans_vtopas1, vtrans_vtopas2, vtrans_prov, vtrans_proval, vtrans_intval, vtrans_isrval, vtrans_reinv
          FROM pagaresxrenovar pag,
               sv_maeinv mae,
               sv_instrum ins
         WHERE mae.empresa = pempresa
           AND mae.cuenta = pag.cuenta
           AND mae.secuencia = ( SELECT MAX(secuencia)
                                   FROM sv_maeinv
                                  WHERE empresa = pempresa
                                    AND cuenta = pag.cuenta )
           AND ins.cod_instrum = mae.cod_instrum
            
        BEGIN WORK;
        LET ven_transacc = 1;
        LET vcontador1 = vcontador1 + 1;
            
        LET vhora = CURRENT HOUR TO FRACTION;
        LET vfoliosuc = vgusuario||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
        
        LET vtotal = vmonto;
        LET vplazo = vfecha_venc - vgfecha_hoy;
        
        CALL bdicheq:cargo_ref(pempresa, vsucursal, vpromotor, '0235', '0000', vfoliosuc, vcta_cheques, 0, vtotal, '01', '', '', '')
        RETURNING vcodret, vpaso, vpaso, vpaso, vpaso;

        IF vcodret <> "000" THEN
            UPDATE sv_maeinv
               SET status_cta = "2",
                   fec_cancelac = vgfecha_hoy
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND secuencia = vsecuencia;

            INSERT INTO sv_valcierre VALUES
            ( pempresa, vcuenta, 1, vcodret );

            LET vcodret = "000";
            
            COMMIT WORK;
            CONTINUE FOREACH;
        END IF

        LET vplazo_nva = vplazo;
        LET vfecha_nva = vgfecha_hoy + vplazo_nva;
        LET vctanva = vcuenta;
        LET vsecnva = vsecuencia + 1;

        -- // REAPERTURA LA CUENTA
        call apertura( pempresa, vnum_cte, vsecnva, vcod_instrum, vpromotor, "001", vsucursal, vplaza, "1", "0", " ", "N", " ", 
                       vplazo_nva, vfecha_nva, vtotal, vper_acred_int, " ", vgusuario, "1", vcta_cheques, vctanva, 0, vsecuencia, vcobraisr )
        returning vcodret, vctanva, vplazo_nva, vfecha_nva, visr_nvo, vintnet_nva, vtasa_nva, vtasaisr_nva, vtasaneta_nva;

        if vcodret <> "000" then
            ROLLBACK WORK;
            CONTINUE FOREACH;
        else
            update sv_maeinv
               set status_cta = '1',
                   sdo_cong = vsdo_cong
             where empresa = pempresa
               and cuenta = vctanva
               and secuencia = vsecnva;
        end if

        if vplazo_nva > 0 then
            let vprovdia = (vintnet_nva + visr_nvo) / vplazo_nva;
        else
            let vprovdia = 0;
        end if

        -- // REGISTRA DEPOSITO INICIAL NUEVO DOCUMENTO
        let vhora = current hour to fraction(3);
        
        insert into sv_movdia values 
        ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgfecha_hoy, vhora, vtrans_reinv, vsucursal,
          vctanva, vsecnva, vcod_instrum, 0, vtotal, vtotal, 0, 0, " ", vtotal, "0000" );

        -- // REGISTRA ENTRADA DEL PASIVO
        let vhora = current hour to fraction(3);
        
        if vtrans_vtopas1 <> "" and vtrans_vtopas1 is not null then
            insert into sv_movdia values 
            ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgfecha_hoy, vhora, vtrans_vtopas1, vsucursal,
              vctanva, vsecnva, vcod_instrum, 0, vtotal, vtotal, 0, 0, " ", vtotal, "0000" );
        end if

        -- // RECALCULA MONTOS EN INSTRUCCIONES AL VENCIMIENTO  * SE CAMBIA POR UPDATE LALO 05MZO09 *
        update sv_maeinstrucc
           set (importe,aplicado,fecha_venc) = (vtotal,"N",vfecha_nva)
         where empresa  = pempresa
           and cuenta   = vctanva
           and cap_int  = "C";
        
        update sv_maeinstrucc
           set (importe,aplicado,fecha_venc) = (0,"N",vfecha_nva)
         where empresa  = pempresa
           and cuenta   = vctanva
           and cap_int  = "I";

        let vinteres = vprovdia * vdiasmact;

        update sv_maeinv
           set fec_ult_mov = vgfecha_hoy,
               modificado  = vgusuario,
               fecha_mod   = vgfecha_hoy,
               status_cta  = "4"
         where empresa = pempresa
           and cuenta = vcuenta
           and secuencia = vsecuencia;

        -- // REGISTRA PROVISION DEL MES ACTUAL
        let vprovision = vprovdia * vdiasmact;
        let vhora = current hour to fraction(3);

        if vprovision > 0 then
            insert into sv_movdia values 
            ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgfecha_hoy, vhora, vtrans_prov, vsucursal,
              vctanva, vsecnva, vcod_instrum, vdiasmact, vprovision, vprovision, 0, 0, " ", vtotal, "0000");
        end if
        
        update sv_maeinv
           set sdo_ult_corte = vprovision
         where empresa = pempresa
           and cuenta = vctanva
           and secuencia = vsecnva;

        -- // REGISTRA PROVISION DEL MES SIGUIENTE
        let vprovision = 0;

        if vdiasmsig > 0 then
            let vprovision = vprovdia * vdiasmsig;
            let vhora = current hour to fraction;

            insert into sv_movdia values 
            ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgprox_fecha, vhora, vtrans_prov, vsucursal,
              vctanva, vsecnva, vcod_instrum, vdiasmsig, vprovision, vprovision, 0, 0, " ", vtotal, "0000" );
        end if

        update sv_maeinv
           set sdo_ult_corte = sdo_ult_corte + vprovision
         where empresa = pempresa
           and cuenta = vctanva
           and secuencia = vsecnva;

        -- // ACTUALIZA ACUMULADO DE INTERESES
        let vinteres = vprovdia * (vdiasmact + vdiasmsig);

        update sv_maeinstrucc
           set importe = importe + vinteres
         where empresa = pempresa
           and cuenta  = vctanva
           and cap_int = "I"
           and aplicado <> "S";
           
        INSERT INTO sv_pagaresrenovados VALUES( vctanva, vsecnva, vplazo_nva, vfecha_nva, vtotal, vtasa_nva, vintnet_nva, visr_nvo );
           
        COMMIT WORK;
        LET ven_transacc = 0;
        
    END FOREACH;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sv_pagaresrenovados;
    
    LET vcodret1 = "000";
    LET vcodret2 = "000";
    LET vcodret3 = "EL PROCESO SE REALIZO SATISFACTORIAMENTE";

    RETURN vcodret1, vcodret2, vcodret3, vcontador1;
    
    END;

END PROCEDURE;