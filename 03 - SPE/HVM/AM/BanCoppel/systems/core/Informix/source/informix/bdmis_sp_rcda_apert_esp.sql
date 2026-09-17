CREATE PROCEDURE "informix".sp_rcda_apert_esp()
RETURNING CHAR(005) AS cod_ret,
		  CHAR(180) AS mensaje;
    
    -- // DECLARACION DE VARIABLES
    DEFINE vusuario         CHAR(8);
    DEFINE vtipo_reg        INTEGER;
    DEFINE vempresa         CHAR(3);
    DEFINE vsucursal        CHAR(4);
    DEFINE vejecutivo       CHAR(8);
    DEFINE vnombre          CHAR(45);
    DEFINE vproducto        CHAR(4);
    DEFINE vfechacierre     CHAR(10);
    DEFINE vnumtdc          INTEGER;
    DEFINE vmetanumtdc      INTEGER;
    DEFINE vcumpmetatdc     MONEY(18,2);
    DEFINE vmeta 			INTEGER;
    
    DEFINE SQL_ERR          INTEGER;
    DEFINE ISAM_ERR         INTEGER;
    DEFINE ERROR_INFO       VARCHAR(80);
    DEFINE P_COD_RET        VARCHAR(6);
    DEFINE P_COD_RET2       VARCHAR(6);
    DEFINE P_MENSAJE        VARCHAR(80);
    DEFINE dFecha           DATE;
    DEFINE dFechafto        CHAR(10);
    DEFINE dFechaCorte      DATE;
    DEFINE dFechaAnt        DATE;
    DEFINE dFechaAnioAnt    DATE;
    DEFINE cFechaAnioAnt    CHAR(06);
    DEFINE dFechahoy        DATE;
    DEFINE dult_dia_mes     DATE;
    DEFINE dfechaantier     DATE;
    DEFINE iDiasMes         INTEGER;
    DEFINE vpaso		    INTEGER;	
    
    DEFINE cod_ret			CHAR(04);
    DEFINE vmensaje			CHAR(80);	
    
    DEFINE op_sucursal		CHAR(04);
    DEFINE op_usuario	 	CHAR(08);
    DEFINE op_fech_alt		DATE;
    DEFINE op_n_transacc	INTEGER;
    DEFINE op_monto		 	MONEY(18,2);
    DEFINE vcajero			CHAR(08);
    
    DEFINE vsucconv	        CHAR(004);
    DEFINE vcliconv	        CHAR(020);
    DEFINE	vjecutconv	    CHAR(008);
    DEFINE vct_conv	        CHAR(006);
    DEFINE vynconv		    INTEGER;	
    DEFINE vcuentaconv      CHAR(020);
    DEFINE vnombrecb 	    CHAR(104); 
    
    DEFINE pgmincodigo_retorno	CHAR(6);
    DEFINE pgminmensaje_retorno CHAR(80);
    DEFINE pgminnumero_credito  CHAR(20);
    DEFINE pgmincodigo_tipcred  CHAR(2);
    DEFINE pgminfecha_origen	DATE;
    DEFINE pgminfecha_prox_pago DATE;
    DEFINE pgminpago_minimo     DECIMAL(18,2);
    DEFINE pgminfecha_ult_pago  DATE;
    DEFINE pgminplazo			INTEGER;
    
    BEGIN
    
    -- // CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        SET DEBUG FILE TO '/resplogifx/conciliachq/sp_rcda_apert.err';
        TRACE ON;
        
        LET P_COD_RET  = SQL_ERR;
        LET P_COD_RET2 = ISAM_ERR;
        LET P_MENSAJE  = ERROR_INFO||' sp_rcda_apert en paso '||vpaso;
        
        INSERT INTO "informix".mi_rcda_cierresucerror( fecha_cierre, estatus_ejec, codigo_error, desc_error )
        SELECT fecha_ant, 'F', P_COD_RET, P_MENSAJE 
          FROM "informix".mi_fechas;
          
        RETURN P_COD_RET, P_MENSAJE;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/sp_rcda_apert.out';
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // INICIALIZACION
    LET P_COD_RET = '00000';
    LET P_MENSAJE ='PROCESO EXITOSO';
    
    -- // SE OBTIENEN LAS FECHAS
    LET vpaso = 0;  
    
    SELECT fecha_ant, DAY(ult_dia_mes)::INT, (fecha_ant - 1), fecha_hoy, ult_dia_mes 
      INTO dFecha, iDiasMes, dfechaantier, dFechahoy, dult_dia_mes 
      FROM "informix".mi_fechas;
    
        
    -- // LIMPIA LA TABLA DEL ACUMULADO DE SOLICITUDES MENSUAL AL INICIO DE MES (01/04/2012)
    LET vpaso = 1;
    
     
    
    /* #####################################################  APERTURAS DE CUENTAS DE CAPTACION  ##################################################### */
    LET vpaso = 2;  
    
  
    
     LET vpaso = 3;
    
     
    
    /* ######################################################  APERTURAS DE CUENTAS DE PAGARES  ###################################################### */
    LET vpaso = 4;
    
 
    LET vpaso = 5;
    
     
    LET vpaso = 6;
    
    
    LET vpaso = 7;
    
    
    LET vpaso = 8;  
    

    LET vpaso = 9;
    

    LET vpaso = 10;
    
    
     
    /* ###########################################################  CLUB DE PROTECCION  ########################################################### */
    SELECT club.suc_alta AS sucursal, club.ejecutivo AS ejecutivo, COUNT(*) AS cantidad, sac.referencia1::INT8 referencia1
      FROM bdisac:sac_movimientoshistorial sac, 
           bdinteg:si_club_proteccion club 
     WHERE sac.fecha_pago = dfecha 
       AND sac.numcategoria = '01' 
       AND sac.numconvenio = '002' 
       AND sac.status_cancelado <> 'S' 
       AND sac.referencia1::INT8 = club.numcte_coppel::INT8
     GROUP BY 1, 2, 4
    INTO TEMP club_proteccion1 WITH NO LOG;
    
    SELECT referencia1::INT8 referencia1
      FROM bdisac:sac_movimientoshistorial 
     WHERE fecha_pago = dfecha 
       AND numcategoria = '01' 
       AND numconvenio = '002' 
       AND status_cancelado <> 'S' 
       AND referencia1::INT8 NOT IN( SELECT referencia1 FROM club_proteccion1 )
    INTO TEMP club_p1 WITH NO LOG;
    
    SELECT ctebancpl, ctecpltitular::INT8 ctecpltitular
      FROM bdinteg:si_club_hiscteprospecto
     WHERE ctecplprospecto::INT8 IN( SELECT referencia1 FROM club_p1 )
    INTO TEMP club_p2 WITH NO LOG;
    
    SELECT suc_alta AS sucursal, ejecutivo, COUNT(*) AS cantidad, numcte_coppel
      FROM bdinteg:si_club_proteccion 
     WHERE ( numcte_coppel::INT8 IN( SELECT ctecpltitular FROM club_p2 ) OR numcte::INT8 IN( SELECT ctecpltitular FROM club_p2) )
     GROUP BY 1, 2, 4
    INTO TEMP club_proteccion2 WITH NO LOG;
    
    INSERT INTO "informix".mi_rcda_suc( tipo, empresa, sucursal, ejecutivo, producto, num_ctasdia )
    SELECT 'APERC' AS tipo, '001' AS empresa, sucursal, ejecutivo, '7777' AS producto, SUM (cantidad) AS suma
      FROM TABLE ( MULTISET ( SELECT sucursal, ejecutivo, COUNT(*) AS cantidad, referencia1
                                FROM club_proteccion1
                               GROUP BY 1, 2, 4
                              UNION ALL
                              SELECT sucursal, ejecutivo, COUNT(*) AS cantidad, numcte_coppel::INT8 numcte_coppel  
                                FROM club_proteccion2
                               GROUP BY 1, 2, 4 ) )
     GROUP BY sucursal, ejecutivo;
    
    DROP TABLE club_p1;
    DROP TABLE club_p2;
    DROP TABLE club_proteccion1;
    DROP TABLE club_proteccion2;	
    
    
    /* ###########################################################  RETIROS CAPTACION  ########################################################### */
    LET vpaso = 11;
    
    -- // Operaciones en ventanilla
    truncate table "informix".mi_opventanilla;
    
    /* -----------------------------------------------------------------------
    execute procedure "informix".sp_bitacora_rcda('rcda_ret_captacion', 1)
    into cod_ret, vmensaje;
    
    if trim(cod_ret) <> '000' then
        return cod_ret ,vmensaje;
    end if;
    ----------------------------------------------------------------------- */
    
    merge into "informix".mi_opventanilla a
    using( select mov.sucursal, mov.usuario, mov.fech_alt, count(*) as n_transacc, sum(mov.monto_tot) as monto
             from "informix".mi_rcda_movdeb mov,
                  bdicheq:sc_maechq mae
            where mov.empresa = '001' 
              and mov.cuenta = mae.cuenta 
              and mov.fech_alt = dfecha 
              and mov.producto = mae.producto 
              and mov.empresa = mae.empresa
              and mov.transacc in('0223') 
            group by 1, 2, 3 ) b on ( a.fecha = b.fech_alt and a.sucursal = b.sucursal and a.cajero = b.usuario )
    WHEN NOT MATCHED THEN 
    insert( a.fecha, a.sucursal, a.cajero, a.tpo_reg, a.num_retcap, a.mont_retcap )
    values( b.fech_alt, b.sucursal, b.usuario, 1, b.n_transacc, b.monto );
    
    /* -----------------------------------------------------------------------
    execute procedure "informix".sp_bitacora_rcda('rcda_ret_captacion', 2)
    into cod_ret, vmensaje;
    
    if trim(cod_ret) <> '000' then
        return cod_ret ,vmensaje;
    end if;
    ----------------------------------------------------------------------- */
    
    
    /* #########################################################  DEPOSITOS DE CAPTACIÃN  #########################################################	*/
    LET vpaso = 12;
    
    /* -----------------------------------------------------------------------
    execute procedure "informix".sp_bitacora_rcda('rcda_dep_captacion', 1)
    into cod_ret, vmensaje;
    
    if trim(cod_ret) <> '000' then
        return cod_ret ,vmensaje;
    end if;
    ----------------------------------------------------------------------- */
    
    merge into "informix".mi_opventanilla a
    using( select mov.sucursal, mov.usuario, mov.fech_alt, count(*) as n_transacc, sum(mov.monto_tot) as monto
             from "informix".mi_rcda_movdeb mov,
                  bdicheq:sc_maechq mae
            where mov.empresa = '001' 
              and mov.cuenta = mae.cuenta 
              and mov.fech_alt = dfecha 
              and mov.producto = mov.producto 
              and mov.empresa = mae.empresa
              and mov.transacc in('0202','0250','0310','0325') 
            group by 1, 2, 3) b on ( a.fecha = b.fech_alt and a.sucursal = b.sucursal and a.cajero = b.usuario )
    WHEN NOT MATCHED THEN 
        insert( a.fecha,a.sucursal,a.cajero,a.tpo_reg,a.num_depcap,a.mont_depcap ) 
        values( b.fech_alt,b.sucursal,b.usuario,1,b.n_transacc,b.monto )
    WHEN MATCHED THEN 
        update set num_depcap = b.n_transacc, 
                   mont_depcap = b.monto;
    
    /* -----------------------------------------------------------------------
    execute procedure "informix".sp_bitacora_rcda('rcda_dep_captacion', 2)
    into cod_ret, vmensaje;
    
    if trim(cod_ret) <> '000' then
        return cod_ret ,vmensaje;
    end if;
    ----------------------------------------------------------------------- */	
    
    
    /* ###########################################################  PAGO DE SERVICIOS  ########################################################### */
    LET vpaso = 13;
    
    /* -----------------------------------------------------------------------
    execute procedure "informix".sp_bitacora_rcda('rcda_pag_serv', 1)
    into cod_ret, vmensaje;
    
    if trim(cod_ret) <> '000' then
        return cod_ret ,vmensaje;
    end if;
    ----------------------------------------------------------------------- */
    
    merge into "informix".mi_opventanilla a
    using( select mov.sucursal, mov.usuario, mov.fech_alt, count(*) as n_transacc, sum(mov.monto_tot) as monto
             from "informix".mi_rcda_movdeb mov,
                  bdicheq:sc_maechq mae
            where mov.empresa = '001' 
              and mov.cuenta = mae.cuenta 
              and mov.fech_alt = dfecha 
              and mov.producto = mov.producto 
              and mov.empresa = mae.empresa
              and mov.transacc in ('1154','1124','1149','1134','1104','1139','1170','1110','1163','1168','1108','1169','1109','1191',
                                   '1167','1107','1101','1161','1195','1193','1116','1176','1115','1175','1117','1177','1118','1178') 
            group by 1, 2, 3) b on ( a.fecha = b.fech_alt and a.sucursal = b.sucursal and a.cajero = b.usuario )
    WHEN NOT MATCHED THEN 
        insert( a.fecha, a.sucursal, a.cajero, a.tpo_reg, a.num_pagserv, a.mont_pagserv )
        values( b.fech_alt, b.sucursal, b.usuario, 1, b.n_transacc,b.monto )
    WHEN MATCHED THEN 
        update set num_pagserv = b.n_transacc,
                   mont_pagserv = b.monto;
    
    /* -----------------------------------------------------------------------
    execute procedure "informix".sp_bitacora_rcda('rcda_pag_serv', 2)
    into cod_ret, vmensaje;
    
    if trim(cod_ret) <> '000' then
        return cod_ret ,vmensaje;
    end if;	
    ----------------------------------------------------------------------- */	
    
    
    /* ###########################################################  PAGOS DE CREDITO  ########################################################### */
    LET vpaso = 14;
    
    /* -----------------------------------------------------------------------
    execute procedure "informix".sp_bitacora_rcda('rcda_pag_cred', 1)
    into cod_ret, vmensaje;
    
    if trim(cod_ret) <> '000' then
        return cod_ret ,vmensaje;
    end if;
    ----------------------------------------------------------------------- */
    
    merge into "informix".mi_opventanilla a
    using( select mov.sucursal, mov.usuario, mov.fecha_mov, count(*) as n_transacc, sum(monto) as monto
             from "informix".mi_rcda_movcred mov
            where ( mov.codigo_fun = '033' and mov.codigo_ref = '1' ) or 
                  ( mov.codigo_fun = '052' and mov.codigo_ref = '1' ) or
                  ( mov.codigo_fun = '053' and mov.codigo_ref = '1' ) or
                  ( mov.codigo_fun = '336' and mov.codigo_ref = '1' )
            group by 1, 2, 3 ) b on ( a.fecha = b.fecha_mov and a.sucursal = b.sucursal and a.cajero = b.usuario )
    WHEN NOT MATCHED THEN 
        insert( a.fecha, a.sucursal, a.cajero, a.tpo_reg, a.num_pagcred, a.mont_pagcred )
        values( b.fecha_mov, b.sucursal, b.usuario, 1, b.n_transacc, b.monto )
    WHEN  MATCHED THEN 
        update set num_pagcred = b.n_transacc,
                   mont_pagcred = b.monto;
    
    
    /* #########################################################  DISPOSICIONES DE CREDITO  ######################################################### */
    LET vpaso = 15;
    
    /* -----------------------------------------------------------------------
    execute procedure "informix".sp_bitacora_rcda('rcda_pag_cred', 2)
    into cod_ret, vmensaje;
    
    if trim(cod_ret) <> '000' then
        return cod_ret ,vmensaje;
    end if;
    ----------------------------------------------------------------------- */
    
    merge into "informix".mi_opventanilla a
    using( select mov.sucursal, mov.usuario, mov.fecha_mov, count(*) as transacc, sum(monto) as monto
             from "informix".mi_rcda_movcred mov
            where mov.transacc_suc = '6900'  
            group by 1, 2, 3 ) b on ( a.fecha = b.fecha_mov and a.sucursal = b.sucursal and a.cajero = b.usuario )
    WHEN NOT MATCHED THEN 
        insert( a.fecha, a.sucursal, a.cajero, a.tpo_reg, a.num_dispcred, a.mont_dispcred ) 
        values( b.fecha_mov, b.sucursal, b.usuario, 1, b.transacc, b.monto )
    WHEN  MATCHED THEN 
    update set num_dispcred = b.transacc,
               mont_dispcred = b.monto;
    
    FOREACH
        select cajero 
          into vcajero 
          from "informix".mi_opventanilla 
    
        select nombre 
          into vnombre 
          from bdinteg:si_ejecut 
         where ejecutivo = vcajero;

        update "informix".mi_opventanilla 
           set nombre = vnombre 
         where cajero = vcajero;
    END FOREACH;
    
    -- // AdiciÃ³n de calculo para los contratos de convenio de pago.
    LET vpaso = 16;
    
    EXECUTE PROCEDURE "informix".sp_obt_cobranza()
    INTO cod_ret, vmensaje;
    
    IF cod_ret <> '000' THEN
        return cod_ret, vmensaje;
    END IF
    
    RETURN P_COD_RET, P_MENSAJE;
    
    END
    
END PROCEDURE;