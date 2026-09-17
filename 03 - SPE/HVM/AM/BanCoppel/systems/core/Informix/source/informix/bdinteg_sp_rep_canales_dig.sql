CREATE PROCEDURE "informix".sp_rep_canales_dig()
RETURNING CHAR(5), CHAR(100);

--DEFINICION DE VARIABLES
DEFINE cCodRet 			CHAR(5);
DEFINE cMsjCodRet 		CHAR(100);
DEFINE cMensaje			CHAR(100);
DEFINE cNumCte			CHAR(20);
DEFINE cRegional		CHAR(3);
DEFINE cNombre			CHAR(40);
DEFINE cSystem			CHAR(1000);
DEFINE cNombreRepExc	CHAR(50);
DEFINE cNombreRepTxt	CHAR(50);   
DEFINE cRutaRepor		CHAR(50);
DEFINE cNomb			CHAR(50);
DEFINE iCte				INTEGER;
DEFINE iCorreo			INTEGER;		
DEFINE iNumCel			INTEGER;		
DEFINE iNumCelConf		INTEGER;		
DEFINE iBanEle			INTEGER;
DEFINE iActBanEle		INTEGER;
DEFINE iAcBcplExp		INTEGER;
DEFINE iCtaEfecPlus		INTEGER;
DEFINE iProBasNom		INTEGER;
DEFINE iTarCredVisa		INTEGER;
DEFINE iCtaPresPe		INTEGER;
DEFINE iSqlErr			INTEGER;
DEFINE iSamErr			INTEGER;
DEFINE iMaxL			INTEGER;
DEFINE iPaso			SMALLINT;
DEFINE dFechaHoy		DATE;
DEFINE dPrimMes			DATE;
DEFINE dUltMes			DATE;
DEFINE cMes				CHAR(2);
DEFINE cYear			CHAR(4);


--ASIGNACION DE VARIABLES
LET cCodRet 		= '00000';
LET cMsjCodRet 		= 'EL REPORTE DE CANALES DIGITALES SE A GENERADO CORRECTAMENTE';
LET cMensaje		= 'ERROR EN PASO: ';
LET cNumCte			= '';
LET cRegional		= '';
LET cNombre			= '';
LET cSystem			= '';
LET cNombreRepExc	= '';
LET cNombreRepTxt	= '';
LET cRutaRepor		= '/home/procesos/';
LET cNomb			= '';
LET iCte			= 0;
LET iCorreo			= 0;
LET iNumCel			= 0;
LET iNumCelConf		= 0;
LET iBanEle			= 0;
LET iActBanEle		= 0;
LET iAcBcplExp		= 0;
LET iCtaEfecPlus	= 0;
LET iProBasNom		= 0;
LET iTarCredVisa	= 0;
LET iCtaPresPe		= 0;
LET iMaxL			= 0;
LET iPaso 			= 0;
LET dFechaHoy		= '';
LET dPrimMes		= '';	
LET dUltMes			= '';
LET cMes			= '';
LET cYear			= '';



	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	BEGIN

		ON EXCEPTION
			SET iSqlErr, iSamErr
			IF iSqlErr <> 0 THEN
			
				LET cCodRet = iSqlErr;
			END IF;
			
			LET cMensaje = TRIM( cMensaje ) || iPaso;
			
			RETURN cCodRet, cMensaje;
		END EXCEPTION;


	--SET DEBUG FILE TO "/tmp/ingrid/sp_rep_canales_dig.out";
	--TRACE ON;
	
	DELETE si_regional_ctes;
	

		FOREACH 
			SELECT regional, nombre
			INTO cRegional, cNombre
			FROM bdinteg:si_regional
	
			INSERT INTO bdinteg:si_regional_ctes(regional, nombre, clientes, correo, num_cel, cel_confir, banca_elec, act_banca_elec, act_bcpl_exp, cta_cap_efec_plus, prod_bas_nomina, tar_cred_visa_bcpl, cta_pres_pers)
			VALUES (cRegional, cNombre, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
			
		END FOREACH;
		
		--OBTENCION DE ÚLTIMOS 3 MESES
		SELECT fecha_hoy, ADD_MONTHS(DATE(pri_dia_mes),-3) AS prim_mes, LAST_DAY(ADD_MONTHS(DATE(fecha_hoy),-1)) AS ult_mes
		INTO dFechaHoy, dPrimMes, dUltMes
		FROM bdinteg:"informix".si_fechas;
		
		LET cMes = LPAD(MONTH(dFechaHoy), 2, 0);
		LET cYear = LPAD(YEAR(dFechaHoy), 4, 0);
		
		LET cNombreRepExc = 'Analisis_de_Datos_de_Canales_Digitales_'||cMes||cYear||'.csv';
		LET cNombreRepTxt = 'Analisis_de_Datos_de_Canales_Digitales_'||cMes||cYear||'.txt';
		
		LET iPaso = 1;
		--BORRA REPORTES 
		LET cSystem = 'rm -f /home/procesos/'||cNombreRepExc;
		SYSTEM cSystem; 
		
		LET cSystem = 'rm -f /home/procesos/'||cNombreRepTxt;
		SYSTEM cSystem; 
		
		
		--OBTIENE LONGITUD MAXIMA DEL NOMBRE DE REGION
		SELECT MAX(LENGTH(nombre))
		INTO iMaxL 
		FROM bdinteg:"informix".si_regional;

		LET iPaso = 2;
				--CREACION TABLA TEMPORAL SUCURSAL Y REGIONES
				SELECT {+AVOID_FULL(bdinteg:"informix".si_sucursales)} a.sucursal, b.regional 
					FROM si_sucursales a, si_plazas b
					WHERE a.plaza = b.plaza
					INTO TEMP tmp_regiones_sucursal;		
					
				SELECT {+INDEX "informix".idx_tpocte)} numcte, sucursal, '   ' AS regional
					FROM si_cliente
					WHERE tipo_cliente = 1
					INTO TEMP tmp_ctes_region;					

				CREATE INDEX "informix".idx_tmp_ctes_region_sucursal ON informix.tmp_ctes_region(sucursal);
				CREATE INDEX "informix".idx_tmp_ctes_region_numte ON informix.tmp_ctes_region(numcte);
				
				UPDATE tmp_ctes_region
				SET regional = ( SELECT regional FROM tmp_regiones_sucursal b WHERE tmp_ctes_region.sucursal = b.sucursal );
				
				DROP TABLE tmp_regiones_sucursal;
		
		LET iPaso = 3;	
			--CREACION TABLA TEMPORAL CTES POR REGION
				SELECT COUNT (*) AS clientes, {+INDEX "informix".idx_tmp_ctes_region)} regional AS region
					FROM tmp_ctes_region 
					GROUP BY regional
					INTO TEMP tmp_ctes_region_1;
					
					CREATE INDEX "informix".idx_tmp_ctes_region_1_region ON informix.tmp_ctes_region_1(region);
					
				--ACTUALIZA TABLA PRINCIPAL
				UPDATE si_regional_ctes 
				SET clientes = ( SELECT b.clientes FROM tmp_ctes_region_1 b WHERE si_regional_ctes.regional = b.region );
				
				DROP TABLE tmp_ctes_region_1;
		
		LET iPaso = 4;
			--CREACION TABLA TEMPORAL CTES CON CORREO POR REGION
				SELECT {+INDEX bdinteg:"informix".idx_correo_unico)} COUNT (*) AS con_correo, 
					{+INDEX bdinteg:"informix".idx_tmp_ctes_region)} b.regional 
					FROM si_correos a, tmp_ctes_region b
					WHERE a.numcte = b.numcte
					AND a.correo_elec <> ''
					GROUP BY  b.regional
					INTO TEMP tmp_ctes_correo;
					
					CREATE INDEX "informix".idx_tmp_ctes_correo_region ON informix.tmp_ctes_correo(regional);
				
				--ACTUALIZA TABLA PRINCIPAL
				UPDATE si_regional_ctes 
				SET correo = ( SELECT b.con_correo FROM tmp_ctes_correo b WHERE si_regional_ctes.regional = b.regional );
				
				DROP TABLE tmp_ctes_correo;				
		
		LET iPaso = 5;
			--CREACION TABLA TEMPORAL CTES CON NÚMERO CELULAR POR REGION
				SELECT {+INDEX bdinteg:"informix".idx_si_telefonos_telefono)} COUNT (*) AS celular,
					{+INDEX bdinteg:"informix".idx_tmp_ctes_region)} b.regional
					FROM si_telefonos_actual a, tmp_ctes_region b
					WHERE a.tipo_tel = 2
					AND a.numcte = b.numcte
					GROUP BY  b.regional
					INTO TEMP tmp_ctes_celular;
					
					CREATE INDEX "informix".idx_tmp_ctes_celular_region ON informix.tmp_ctes_celular(regional);
				
				--ACTUALIZA TABLA PRINCIPAL
				UPDATE si_regional_ctes 
				SET num_cel = ( SELECT b.celular FROM tmp_ctes_celular b WHERE si_regional_ctes.regional = b.regional );
				
				DROP TABLE tmp_ctes_celular;
			
		LET iPaso = 6;
			--CREACION TABLA TEMPORAL CTES CON CELULAR CONFIRMADO POR REGION
				SELECT {+INDEX bdinteg:"informix".idx_si_telefonos_telefono)} COUNT (*) AS cel_confi, 
					{+INDEX bdinteg:"informix".idx_tmp_ctes_region)} b.regional
					FROM si_telefonos a, tmp_ctes_region b
					WHERE a.tipo_tel = 2
					AND a.status_tel = 'A' AND NVL( a.verificado, 'F' ) = 'V'					
					AND a.numcte = b.numcte
					GROUP BY b.regional
					INTO TEMP tmp_ctes_cel_conf;
					
					CREATE INDEX "informix".idx_tmp_ctes_cel_conf_region ON informix.tmp_ctes_cel_conf(regional);
				
				--ACTUALIZA TABLA PRINCIPAL
				UPDATE si_regional_ctes 
				SET cel_confir = ( SELECT b.cel_confi FROM tmp_ctes_cel_conf b WHERE si_regional_ctes.regional = b.regional );
				
				DROP TABLE tmp_ctes_cel_conf;
		
		LET iPaso = 7;
			--CREACION TABLA TEMPORAL CTES EN BANCA ELECTRÓNICA POR REGION
				SELECT COUNT (*) AS banc_elec,
					{+INDEX bdinteg:"informix".idx_tmp_ctes_region)} b.regional
					FROM bdinteg:si_bpiusuarios a, tmp_ctes_region b
					WHERE a.numcte = b.numcte
					AND a.servicio IN (1, 2)
					GROUP BY b.regional
					INTO TEMP tmp_ctes_ban_elec;
					
					CREATE INDEX "informix".idx_tmp_ctes_ban_elec_region ON informix.tmp_ctes_ban_elec(regional);
					
				--ACTUALIZA TABLA PRINCIPAL
				UPDATE si_regional_ctes 
				SET banca_elec = ( SELECT b.banc_elec FROM tmp_ctes_ban_elec b WHERE si_regional_ctes.regional = b.regional );
				
				DROP TABLE tmp_ctes_ban_elec;
		
		LET iPaso = 8;
			--CREACION TABLA TEMPORAL CTES ACTIVOS EN BANCA ELECTRÓNICA POR REGION
				SELECT {+INDEX bdinteg:"informix".idx_bpi_st)} COUNT (*) AS act_ban_elec, 
					{+INDEX bdinteg:"informix".idx_tmp_ctes_region)} b.regional
					FROM bdinteg:"informix".si_bpiusuarios a, tmp_ctes_region b
					WHERE a.id_status = 30
					AND a.numcte = b.numcte
					AND a.f_status::DATE BETWEEN dPrimMes AND dUltMes
					GROUP BY b.regional
					INTO TEMP tmp_ctes_act_ban_elec;
					
					CREATE INDEX "informix".idx_tmp_ctes_act_ban_elec_region ON informix.tmp_ctes_act_ban_elec(regional);
					
				--ACTUALIZA TABLA PRINCIPAL
				UPDATE si_regional_ctes 
				SET act_banca_elec = ( SELECT b.act_ban_elec FROM tmp_ctes_act_ban_elec b WHERE si_regional_ctes.regional = b.regional );
				
				DROP TABLE tmp_ctes_act_ban_elec;
		
		LET iPaso = 9;	
			--CREACION TABLA TEMPORAL CTES ACTIVOS EN BANCOPPEL EXPRESS 
				SELECT {+INDEX bdibpi:"informix".idx_num_cliente)} COUNT (a.num_cliente) AS act_bcpl_exp,
					{+INDEX bdinteg:"informix".idx_tmp_ctes_region)} b.regional
					FROM bdibpi:"informix".bpi_registro_bex a, tmp_ctes_region b
					WHERE a.estatus_servicio = 1
					AND a.num_cliente = b.numcte
					AND a.fecha_registro::DATE BETWEEN dPrimMes AND dUltMes
					GROUP BY b.regional
					INTO TEMP tmp_ctes_act_bcpl_exp;
	
				CREATE INDEX "informix".idx_tmp_ctes_act_bcpl_exp_region ON informix.tmp_ctes_act_bcpl_exp(regional);
	
				--ACTUALIZA TABLA PRINCIPAL
				UPDATE si_regional_ctes 
				SET act_bcpl_exp = ( SELECT b.act_bcpl_exp FROM tmp_ctes_act_bcpl_exp b WHERE si_regional_ctes.regional = b.regional );
				
				DROP TABLE tmp_ctes_act_bcpl_exp;
				
		LET iPaso = 10;	
					
					SELECT COUNT (a.num_cte) AS cta_cap_efec_p, 
					{+INDEX bdinteg:"informix".idx_tmp_ctes_region)} b.regional
					FROM tmp_ctes_region b JOIN bdicheq:"informix".sc_maechq a
					ON a.num_cte = b.numcte
					WHERE a.producto = '1800'
					AND a.status_cta IN ( 1, 2, 3, 4)
					GROUP BY b.regional					
					INTO TEMP tmp_ctes_cta_cap_efec;					
					
					CREATE INDEX "informix".idx_tmp_ctes_cta_cap_efec_region ON informix.tmp_ctes_cta_cap_efec(regional);
					
				--ACTUALIZA TABLA PRINCIPAL
				UPDATE si_regional_ctes 
				SET cta_cap_efec_plus = ( SELECT b.cta_cap_efec_p FROM tmp_ctes_cta_cap_efec b WHERE si_regional_ctes.regional = b.regional );
				
				DROP TABLE tmp_ctes_cta_cap_efec;
				
		LET iPaso = 11;		
					
				SELECT COUNT (a.num_cte) AS pro_bas_nom,
					{+INDEX bdinteg:"informix".idx_tmp_ctes_region)} b.regional
					FROM tmp_ctes_region b JOIN bdicheq:"informix".sc_maechq a
					ON a.num_cte = b.numcte
					WHERE a.producto = '1700'
					AND a.status_cta IN ( 1, 2, 3, 4)
					GROUP BY b.regional
					INTO TEMP tmp_ctes_prod_bas_nom;	

				CREATE INDEX "informix".idx_tmp_ctes_prod_bas_nom_region ON informix.tmp_ctes_prod_bas_nom(regional);					
					
				--ACTUALIZA TABLA PRINCIPAL
				UPDATE si_regional_ctes 
				SET prod_bas_nomina = ( SELECT b.pro_bas_nom FROM tmp_ctes_prod_bas_nom b WHERE si_regional_ctes.regional = b.regional);
				
				DROP TABLE tmp_ctes_prod_bas_nom;
				
		LET iPaso = 12;	
					--IFRS Se contempla el nuevo estatus por Etapa 1
					SELECT COUNT (a.numcte) AS tar_cred_visa,
					{+INDEX bdinteg:"informix".idx_tmp_ctes_region)} b.regional
					FROM tmp_ctes_region b JOIN bdicred:"informix".sd_maecred a
					ON a.numcte = b.numcte										
					WHERE a.num_producto IN( '6001', '7000', '8100' )
					AND a.status_cred IN ('AA','CV','BA','E1')
					--AND a.status_cred IN ('AA','CV','BA')
					GROUP BY b.regional
					INTO TEMP tmp_ctes_tar_vis_bcpl;					
					
				CREATE INDEX "informix".idx_tmp_ctes_tar_vis_bcpl_region ON informix.tmp_ctes_tar_vis_bcpl(regional);					
					
				--ACTUALIZA TABLA PRINCIPAL
				UPDATE si_regional_ctes 
				SET tar_cred_visa_bcpl = (SELECT b.tar_cred_visa FROM tmp_ctes_tar_vis_bcpl b WHERE si_regional_ctes.regional = b.regional);
				
				DROP TABLE tmp_ctes_tar_vis_bcpl;
		
		LET iPaso = 13;
					--IFRS Se contempla el nuevo estatus por Etapa 1
					SELECT COUNT (a.numcte) AS pres_pers,
					{+INDEX bdinteg:"informix".idx_tmp_ctes_region)} b.regional
					FROM tmp_ctes_region b JOIN bdicred:"informix".sd_maecredcrd a
					ON a.numcte = b.numcte
					--WHERE a.num_producto IN ('6300','7600','7700')
					WHERE status_cred IN ('AA','CV','BA','E1')
					--WHERE status_cred IN ('AA','CV','BA')
					GROUP BY b.regional					
					INTO TEMP tmp_ctes_pres_per;		

				CREATE INDEX "informix".idx_tmp_ctes_pres_per_region ON informix.tmp_ctes_pres_per(regional);										
				
				--ACTUALIZA TABLA PRINCIPAL
				UPDATE si_regional_ctes 
				SET cta_pres_pers = (SELECT b.pres_pers FROM tmp_ctes_pres_per b WHERE si_regional_ctes.regional = b.regional);
				
				DROP TABLE tmp_ctes_pres_per;
				
				LET iPaso = 14;
				--IMPRIME ENCABEZADO REPORTE EXCEL
				LET cSystem =  'echo "' || 'REGION' || ',' || 'CLIENTES' || ',' || 'CON CORREO' || ',' || 'CON NÚMERO CELULAR' || ',' || 'CELULAR CONFIRMADO' || ',' || 'EN BANCA ELECTRÓNICA' || ',' || 'ACTIVOS EN BANCA ELECTRÓNICA' || ',' || 'ACTIVOS EN BANCOPPEL EXPRESS' || ',' || 'CON CUENTA CAPTACIÓN EFECTIVA PLUS' || ',' || 'CON CUENTA DE (CAPTACIÓN PRODUCTO BÁSICO NÓMINA)' || ',' || 'CON CUENTA CRÉDITO (TARJETA DE CRÉDITO VISA BANCOPPEL)' || ',' || 'CON CUENTA DE PRÉSTAMO PERSONAL' || '" >> ' || TRIM(cRutaRepor) || TRIM(cNombreRepExc);
				SYSTEM cSystem;
										
				LET iPaso = 15;
				--IMPRIME ENCABEZADO REPORTE TXT
				LET cSystem =  'echo "' || RPAD('REGION',iMaxL,' ') || '|' || RPAD('CLIENTES', 40, ' ') || '|' || RPAD('CON CORREO', 40, ' ') || '|' || RPAD('CON NÚMERO CELULAR', 40, ' ') || '|' || RPAD('CELULAR CONFIRMADO', 40, ' ') || '|' || RPAD('EN BANCA ELECTRÓNICA', 40, ' ') || '|' || RPAD('ACTIVOS EN BANCA ELECTRÓNICA', 40 , ' ') || '|' || RPAD('ACTIVOS EN BANCOPPEL EXPRESS', 40, ' ') || '|' || RPAD('CON CUENTA CAPTACIÓN EFECTIVA PLUS', 40, ' ') || '|' || RPAD('CON CUENTA DE (CAPTACIÓN PRODUCTO BÁSICO NÓMINA', 48, ' ') || '|' || RPAD('CON CUENTA CRÉDITO (TARJETA DE CRÉDITO VISA BANCOPPEL)', 55, ' ') || '|' || RPAD('CON CUENTA DE PRÉSTAMO PERSONAL', 40, ' ') || '" >> ' || TRIM(cRutaRepor) || TRIM(cNombreRepTxt);
				SYSTEM cSystem;
				
							
				FOREACH
					SELECT nombre, clientes, correo, num_cel, cel_confir, banca_elec, act_banca_elec, act_bcpl_exp, cta_cap_efec_plus, prod_bas_nomina, tar_cred_visa_bcpl, cta_pres_pers
					INTO cNomb, iCte, iCorreo, iNumCel, iNumCelConf, iBanEle, iActBanEle, iAcBcplExp, iCtaEfecPlus, iProBasNom, iTarCredVisa, iCtaPresPe
					FROM bdinteg:"informix".si_regional_ctes
					ORDER BY nombre
					
				LET iPaso = 16;					
					--IMPRIME REPORTE EXCEL
					LET cSystem = 'echo "' || RPAD(TRIM(cNomb),iMaxL,' ')  || ',' || NVL(iCte, '0') || ',' || NVL(iCorreo, '0') || ',' || NVL(iNumCel, '0') || ',' || NVL(iNumCelConf, '0') || ',' || NVL(iBanEle, '0') || ',' || NVL(iActBanEle, '0') || ',' || NVL(iAcBcplExp, '0') || ',' || NVL(iCtaEfecPlus, '0') || ',' || NVL(iProBasNom, '0') || ',' || NVL(iTarCredVisa, '0') || ',' || NVL(iCtaPresPe, '0') || '" >> ' || TRIM(cRutaRepor) || TRIM(cNombreRepExc);
					SYSTEM cSystem;	
				
				LET iPaso = 17;
					--IMPRIME REPORTE TXT
					LET cSystem = 'echo "' || RPAD(TRIM(cNomb),iMaxL,' ')  || '|' || NVL(iCte, '0') || '|' || NVL(iCorreo, '0') || '|' || NVL(iNumCel, '0') || '|' || NVL(iNumCelConf, '0') || '|' || NVL(iBanEle, '0') || '|' || NVL(iActBanEle, '0') || '|' || NVL(iAcBcplExp, '0') || '|' || NVL(iCtaEfecPlus, '0') || '|' || RPAD(NVL(iProBasNom, '0'), 48, ' ') || '|' || RPAD(NVL(iTarCredVisa, '0'), 55, ' ') || '|' || NVL(iCtaPresPe, '0') || '" >> ' || TRIM(cRutaRepor) || TRIM(cNombreRepTxt);
					SYSTEM cSystem;	
					
				END FOREACH;
				
			--BORRADO TABLAS TEMPORALES
			
			DROP TABLE tmp_ctes_region;
			DELETE si_regional_ctes;
		
		
		RETURN cCodRet, cMsjCodRet;
	END;	
END PROCEDURE
DOCUMENT		
'REALIZA: Reporte de Análisis de datos de Canales Digitales',		
'EQUIPO: Gerencia Mantto. 4',	
'FECHA: 02/08/2018',		
'VERSION: 1.0.0',
'CREADO POR: Ingrid Pamela Cázarez Villegas';

CREATE PROCEDURE "informix".sp_repcredsipab( pCliente CHAR(20), pIndicador SMALLINT )
RETURNING CHAR(5); 
    
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cErrorInfo       CHAR(80);
    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(80);
    DEFINE cTpCobranza      SMALLINT;
    DEFINE cMoneda          SMALLINT;
    DEFINE cSegmento        SMALLINT;
    DEFINE iContador        SMALLINT;
    DEFINE dOtrosAcces      DECIMAL(15,2);
    DEFINE cNumCred         CHAR(20);
    DEFINE dCapVig          DECIMAL(15,2);
    DEFINE dCapVenc         DECIMAL(15,2);
    DEFINE dIntVenc         DECIMAL(15,2);
    DEFINE dIntMor          DECIMAL(15,2);
    DEFINE dComPend         DECIMAL(15,2);
    DEFINE dIvaCom	        DECIMAL(15,2);
    DEFINE cProducto        CHAR(4);
    DEFINE dtFechaFinMes    DATE;
    DEFINE dtFechaHoy	    DATE;
    
    LET iSqlErr         = 0;
    LET iIsamErr        = 0;
    LET cErrorInfo      = '';
    LET cCodRet         = '00000';
    LET cCodRet2        = '';
    LET cCodRet3        = '';
    LET cSegmento       = 0;
    LET iContador       = 0;
    LET cTpCobranza     = 1;
    LET cMoneda         = 0;
    LET dOtrosAcces     = 0;
    LET	cNumCred        = '';
    LET	dCapVig         = 0;
    LET	dCapVenc        = 0;
    LET	dIntVenc        = 0;
    LET	dIntMor         = 0;
    LET	dComPend        = 0;
    LET	dIvaCom	        = 0;
    LET	cProducto       = "";
    LET	dtFechaFinMes   = DATE(1);
    LET	dtFechaHoy	    = DATE(1);
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_repcredsipab.err";
        TRACE ON;
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = cErrorInfo;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_repcredsipab.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    IF ( pCliente is null OR pCliente = '' ) THEN
        LET cCodRet	= '00001';
        RETURN cCodRet;
    END IF;
    
    SELECT fecha_hoy
	  INTO dtFechaHoy
	  FROM bdicred:sd_fechas
	 WHERE empresa = '001';
    
    LET dtFechaFinMes = mdy(month(dtFechaHoy),01,YEAR(dtFechaHoy)) - 1 UNITS DAY;
    --IFRS Se contemplan los nuevos estatus de crédito por Etapas de Vencido
    FOREACH WITH HOLD
        SELECT num_credito, num_producto, divisa
          INTO cNumCred, cProducto, cMoneda
          FROM bdicred:sd_maecred 
																								
         WHERE numcte = pCliente
           AND status_cred IN('BT','E2','E3')
								
           AND empresa = '001'
        UNION ALL
        SELECT num_credito, num_producto, divisa	  
          FROM bdicred:sd_maecredcrd 
																								
         WHERE numcte = pCliente
																						   
           AND status_cred IN('BT','E2','E3')
           AND empresa = '001'		
        
        IF cProducto = '6001' THEN 
            LET cSegmento = 3;
            
            SELECT sdo_capital, mto_venc_trasp + monto_vencido, int_tra_no_exig, sdo_moratorio + sdo_contab_mora
			  INTO dCapVig, dCapVenc, dIntVenc, dIntMor
		      FROM bdicred:sd_maesdoscont
		     WHERE fecha = dtFechaFinMes
		       AND empresa = '001'
               AND num_credito = cNumCred ;
            
            SELECT NVL(SUM(decode(tc.comi_o_seg, '1', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0),
                   NVL(SUM(decode(tc.comi_o_seg, '4', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0)
              INTO dComPend, dIvaCom
              FROM bdicred:sd_detcomi dc,
                   bdicred:sd_tpcomis tc
             WHERE dc.empresa = '001'
               AND dc.num_credito = cNumCred
               AND dc.estado_com = 'A'
               AND dc.empresa = tc.empresa
               AND dc.cod_comis = tc.cod_comis
               AND tc.comi_o_seg IN('1','4');
               
            LET dOtrosAcces = dComPend + dIvaCom;
        ELSE
            LET cSegmento = 4;
            
            SELECT sdo_capital, mto_venc_trasp + monto_vencido, int_tra_no_exig, sdo_moratorio + sdo_contab_mora
			  INTO dCapVig, dCapVenc, dIntVenc, dIntMor
		      FROM bdicred:sd_maesdoscontcrd
		     WHERE fecha = dtFechaFinMes
		       AND empresa = '001'
               AND num_credito = cNumCred;		
            
            LET dOtrosAcces = 0.00;
        END IF
        
        IF dCapVig     is null THEN LET dCapVig     = 0.00; END IF;
        IF dCapVenc    is null THEN LET dCapVenc    = 0.00; END IF;
        IF dIntVenc    is null THEN LET dIntVenc    = 0.00; END IF;
        IF dIntMor     is null THEN LET dIntMor     = 0.00; END IF;
        IF dOtrosAcces is null THEN LET dOtrosAcces = 0.00; END IF;
        
        IF pIndicador = 0 THEN
            INSERT INTO si_infcrdtit VALUES
            ( cNumCred, cMoneda, cSegmento, cTpCobranza, dCapVig, dCapVenc, dIntVenc, dIntMor, dOtrosAcces );
            
            INSERT INTO si_crdasotit VALUES
            ( cNumCred, pCliente );
        ELSE
            INSERT INTO si_infcrdtit_comp VALUES
            ( cNumCred, cMoneda, cSegmento, cTpCobranza, dCapVig, dCapVenc, dIntVenc, dIntMor, dOtrosAcces );
            
            INSERT INTO si_crdasotit_comp VALUES
            ( cNumCred, pCliente );
        END IF;
        
        LET iContador = 1;
    END FOREACH
    
    IF iContador = 0 THEN 
        LET cCodRet = '00002';
        RETURN cCodRet; 
    END IF;
    
    END;
    
    RETURN cCodRet;
    
END PROCEDURE
    
DOCUMENT    
'DESCRIPCION: Procedimiento para  la créditos vencidos de los titulares, RQM 06 419', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'FECHA: 01 Junio 2015',
'VERSION: 20150601.1645',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_repcredsipab_temp( pCliente CHAR(20), dtFechaHoy date )
RETURNING CHAR(5); 
    
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cErrorInfo       CHAR(80);
    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(80);
    DEFINE cTpCobranza      SMALLINT;
    DEFINE cMoneda          SMALLINT;
    DEFINE cSegmento        SMALLINT;
    DEFINE iContador        SMALLINT;
    DEFINE dOtrosAcces      DECIMAL(15,2);
    DEFINE cNumCred         CHAR(20);
    DEFINE dCapVig          DECIMAL(15,2);
    DEFINE dCapVenc         DECIMAL(15,2);
    DEFINE dIntVenc         DECIMAL(15,2);
    DEFINE dIntMor          DECIMAL(15,2);
    DEFINE dComPend         DECIMAL(15,2);
    DEFINE dIvaCom	        DECIMAL(15,2);
    DEFINE cProducto        CHAR(4);
    DEFINE dtFechaFinMes    DATE;
	DEFINE dDiaCorte        integer;
	DEFINE dIntVig          DECIMAL(15,2);
--    DEFINE dtFechaHoy	    DATE;
    
    LET iSqlErr         = 0;
    LET iIsamErr        = 0;
    LET cErrorInfo      = '';
    LET cCodRet         = '00000';
    LET cCodRet2        = '';
    LET cCodRet3        = '';
    LET cSegmento       = 0;
    LET iContador       = 0;
    LET cTpCobranza     = 1;
    LET cMoneda         = 0;
    LET dOtrosAcces     = 0;
    LET	cNumCred        = '';
    LET	dCapVig         = 0;
    LET	dCapVenc        = 0;
    LET	dIntVenc        = 0;
    LET	dIntMor         = 0;
    LET	dComPend        = 0;
    LET	dIvaCom	        = 0;
    LET	cProducto       = "";
    LET	dtFechaFinMes   = DATE(1);
	LET dDiaCorte       = 0;
	LET dIntVig         = 0;
--    LET	dtFechaHoy	    = DATE(1);
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr,cErrorInfo
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_repcredsipab_temp.err";
        TRACE ON;
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = cErrorInfo;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO "/ifxsif01/MarcoCardenas/IFRS/sp_repcredsipab_temp.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    IF ( pCliente is null OR pCliente = '' ) THEN
        LET cCodRet	= '00001';
        RETURN cCodRet;
    END IF;
    
--    SELECT fecha_hoy
--	  INTO dtFechaHoy
--	  FROM bdicred:sd_fechas
--	 WHERE empresa = '001';
    
--    LET dtFechaFinMes = mdy(month(dtFechaHoy),01,YEAR(dtFechaHoy)) - 1 UNITS DAY;
    --IFRS Se contemplan los nuevos estatus de crédito por Etapas de Vencido
	
	FOREACH WITH HOLD
        SELECT num_credito, num_producto, divisa
          INTO cNumCred, cProducto, cMoneda
          FROM bdicred:sd_maecredcont 
																									
         WHERE numcte = pCliente
		   AND fecha = dtFechaHoy
           AND status_cred IN  ('BT','E2','E3')
								
           AND empresa = '001'
        UNION ALL
        SELECT num_credito, num_producto, divisa	  
          FROM bdicred:sd_maecredcontcrd 
																									   
         WHERE numcte = pCliente
		   AND fecha = dtFechaHoy 
           AND status_cred IN  ('BT','E2','E3')
           AND empresa = '001'	
        
        IF cProducto in ("6001","8100","7000") THEN 
            LET cSegmento = 3;
            
            SELECT mto_venc_trasp + monto_vencido, int_tra_no_exig, sdo_moratorio + sdo_contab_mora
			  INTO dCapVenc, dIntVenc, dIntMor
		      FROM bdicred:sd_maesdoscont
		     WHERE fecha = dtFechaHoy
		       AND empresa = '001'
               AND num_credito = cNumCred ;
			   
			SELECT dia_corte
			  INTO dDiaCorte
		      FROM bdicred:sd_maecredanexo
		     WHERE empresa = '001'
               AND num_credito = cNumCred ;
			   
			SELECT sdo_int_anticip
			  INTO dIntVig
		      FROM bdicred:sd_maesdoshist
		     WHERE fecha = mdy(month(dtFechaHoy),dDiaCorte,year(dtFechaHoy))
		       AND empresa = '001'
               AND num_credito = cNumCred ;

            
         /*   SELECT NVL(SUM(decode(tc.comi_o_seg, '1', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0),
                   NVL(SUM(decode(tc.comi_o_seg, '4', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0)
              INTO dComPend, dIvaCom
              FROM bdicred:sd_detcomi dc,
                   bdicred:sd_tpcomis tc
             WHERE dc.empresa = '001'
               AND dc.num_credito = cNumCred
               AND dc.estado_com = 'A'
               AND dc.empresa = tc.empresa
               AND dc.cod_comis = tc.cod_comis
               AND tc.comi_o_seg IN('1','4');
               
            LET dOtrosAcces = dComPend + dIvaCom;*/
			LET dOtrosAcces = 0.00;
        ELSE 		   
            LET cSegmento = 4;
            
            SELECT mto_venc_trasp + monto_vencido, int_tra_no_exig, sdo_moratorio + sdo_contab_mora
			  INTO dCapVenc, dIntVenc, dIntMor
		      FROM bdicred:sd_maesdoscontcrd
		     WHERE fecha = dtFechaHoy
		       AND empresa = '001'
               AND num_credito = cNumCred;		
            
            LET dOtrosAcces = 0.00;
        END IF
        
        IF dIntVig     is null THEN LET dIntVig     = 0.00; END IF;
        IF dCapVenc    is null THEN LET dCapVenc    = 0.00; END IF;
        IF dIntVenc    is null THEN LET dIntVenc    = 0.00; END IF;
        IF dIntMor     is null THEN LET dIntMor     = 0.00; END IF;
        IF dOtrosAcces is null THEN LET dOtrosAcces = 0.00; END IF;

		IF (dIntVig > dIntVenc) then
			LET dIntVenc = 0;
		ELSE	
			LET dIntVenc = dIntVenc - dIntVig;
		END IF;
		
		LET dCapVig = dCapVenc + dIntVenc + dIntMor + dOtrosAcces;
        
        INSERT INTO si_infcrdtit_temp VALUES
        ( cNumCred, cMoneda, cSegmento, cTpCobranza, dCapVig, dCapVenc, dIntVenc, dIntMor, dOtrosAcces );
        
        INSERT INTO si_crdasotit_temp VALUES
        ( cNumCred, pCliente );
        
        LET iContador = 1;
    END FOREACH
    
    IF iContador = 0 THEN 
        LET cCodRet = '00002';
        RETURN cCodRet; 
    END IF;
    
    END;
    
    RETURN cCodRet;
    
END PROCEDURE
    
DOCUMENT    
'DESCRIPCION: Procedimiento para  la créditos vencidos de los titulares, RQM 06 419', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'FECHA: 01 Junio 2015',
'VERSION: 20150601.1645',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_reporte_cte_prod_act()
RETURNING VARCHAR(5) AS CodRetorno, 
		  VARCHAR(200) AS Mensaje;
		  
		  
DEFINE iSqlError 		  INTEGER;		  
DEFINE vsCodRetorno       VARCHAR (5);
DEFINE vsMensaje          VARCHAR(200);
DEFINE dFechahoy		  DATE;
DEFINE dFechapri		  DATE;
DEFINE dFechault		  DATE;
DEFINE dPridiames		  DATE;
DEFINE dUltdiames		  DATE;
DEFINE vNombreArchivo     VARCHAR(100);
DEFINE iCteprodactcre	  INTEGER;
DEFINE iCtetrantdc		  INTEGER;
DEFINE iCtetrantdctot	  VARCHAR(20);
DEFINE iCteprodactdb	  INTEGER;
DEFINE iCtetrandb    	  INTEGER;
DEFINE iCtetrandbtot      VARCHAR(20);
DEFINE cRutaArchRep	      CHAR(150);
DEFINE cRepcre            CHAR(300);
DEFINE cRepdb             CHAR(300);
DEFINE cNombrefecha       CHAR(6);

LET iSqlError = 0;
LET vsCodRetorno = '00000';
LET vsMensaje = '';
LET dFechahoy = '';
LET dFechapri = '';
LET dFechault = '';
LET dPridiames = '';
LET dUltdiames = '';
LET vNombreArchivo = '';
LET iCteprodactcre = '';
LET iCtetrantdc = '';
LET iCtetrantdctot = '';
LET iCteprodactdb = '';
LET iCtetrandb = '';
LET iCtetrandbtot = '';
		  
BEGIN


	ON EXCEPTION SET iSqlError
		IF (iSqlError != 0) THEN
			LET vsCodRetorno = iSqlError;
			LET vsMensaje = 'SE EJECUTO CON ERRORES';
			RETURN vsCodRetorno, vsMensaje;
		END IF;
	END EXCEPTION;		  

--SET DEBUG FILE TO "/ifxsif01/MarcoCardenas/IFRS/sp_reporte_cte_prod_act.out";
--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT 
		ADD_MONTHS(DATE(pri_dia_mes),-1) AS pri_dia_mes , LAST_DAY(ADD_MONTHS(DATE(fecha_hoy),-1)) AS fecha_hoy
		INTO dPridiames,dUltdiames
		FROM bdinteg:"informix".si_fechas;
		
		LET cNombrefecha = SUBSTR(dPridiames,1,2)||SUBSTR(dPridiames,7,4);

		LET vNombreArchivo = 'Clientes_con_productos_activos_'||cNombrefecha||'.csv';
		
		LET cRepcre = 'rm -f /home/procesos/'||vNombreArchivo;
		SYSTEM cRepcre; 
		--IFRS Se contempla el nuevo estatus por Etapa 1 Vigente
	-----------------------------------CREDITO------------------------------------
		SELECT a.numcte,a.num_credito
		FROM bdicred:sd_maecred a,
			 bdicred:sd_maesdos b
		WHERE a.num_credito = b.num_credito
		and a.status_cred IN ('AM', 'AA','AC','AE','AR','E1') 
		AND (b.monto_vencido + b.mto_venc_trasp) = 0
		--WHERE status_cred IN ('AM', 'AA','AC','AE','AR')
		INTO TEMP tmp_ctes_cre
		WITH NO LOG;
		
		SELECT numcte
		FROM tmp_ctes_cre 
		GROUP BY numcte
		INTO TEMP tmp_ctes_prod_act_cre
		WITH NO LOG;
		
		SELECT COUNT(DISTINCT numcte)
		INTO iCteprodactcre
		FROM tmp_ctes_prod_act_cre;


		SELECT num_credito,monto 
		FROM bdicred: sd_movhis 
		WHERE fecha_mov BETWEEN dPridiames AND dUltdiames
		INTO TEMP tmp_ctes_prod_act_sd_movhis
		WITH NO LOG;

		SELECT COUNT(DISTINCT numcte)
		INTO iCtetrantdc
		FROM tmp_ctes_cre 
		WHERE num_credito IN (SELECT num_credito FROM tmp_ctes_prod_act_sd_movhis);
		
	
		SELECT SUM(monto):: VARCHAR(20)
		INTO iCtetrantdctot  
		FROM tmp_ctes_prod_act_sd_movhis 
		WHERE num_credito IN(SELECT num_credito FROM tmp_ctes_cre);

	-----------------------------------DEBITO------------------------------------	
	
		SELECT num_cte,cuenta
		FROM bdicheq:sc_maechq  
		WHERE status_cta = 1
		INTO TEMP tmp_ctes_db
		WITH NO LOG;
		
		SELECT num_cte
		FROM tmp_ctes_db  
		GROUP BY num_cte
		INTO TEMP tmp_ctes_prod_act_db
		WITH NO LOG;
		
		SELECT COUNT(DISTINCT num_cte)
		INTO iCteprodactdb
		FROM tmp_ctes_prod_act_db;
		
		SELECT cuenta,monto_tot
		FROM bdicheq:sc_movhis 
		WHERE fech_alt BETWEEN dPridiames AND dUltdiames
		INTO TEMP tmp_ctes_prod_act_sc_movhis
		WITH NO LOG;
		
		SELECT COUNT(DISTINCT num_cte)
		INTO iCtetrandb
		FROM tmp_ctes_db WHERE cuenta IN (SELECT cuenta FROM tmp_ctes_prod_act_sc_movhis);
		
		SELECT SUM(monto_tot):: VARCHAR(20)
		INTO iCtetrandbtot 
		FROM tmp_ctes_prod_act_sc_movhis WHERE cuenta IN(SELECT cuenta FROM tmp_ctes_db);
		
			
		
		LET cRutaArchRep = '/home/procesos/';
		
		LET cRepcre = 'echo "' ||('Numero de clientes productos activos credito') || ',' || ('Numero de clientes que transaccionaron durante el mes credito') || ',' || ('Monto global de las transacciones credito')|| '" >> ' || TRIM(cRutaArchRep) || TRIM(vNombreArchivo);
		SYSTEM cRepcre; 
		
		LET cRepcre = 'echo "' ||(iCteprodactcre) || ',' || (iCtetrantdc) || ',' || NVL(iCtetrantdctot,'0')|| '" >> ' || TRIM(cRutaArchRep) || TRIM(vNombreArchivo);
		SYSTEM cRepcre;

		LET cRepcre = 'echo "' || '" >> ' || TRIM(cRutaArchRep) || TRIM(vNombreArchivo);
		SYSTEM cRepcre;
		
		LET cRepcre = 'echo "' ||('Numero de clientes productos activos debito') || ',' || ('Numero de clientes que transaccionaron durante el mes debito') || ',' || ('Monto global de las transacciones debito')|| '" >> ' || TRIM(cRutaArchRep) || TRIM(vNombreArchivo);
		SYSTEM cRepcre;
		
		LET cRepcre = 'echo "' ||(iCteprodactdb) || ',' || (iCtetrandb) || ',' || NVL(iCtetrandbtot,'0')|| '" >> ' || TRIM(cRutaArchRep) || TRIM(vNombreArchivo);
		SYSTEM cRepcre;
		
		LET cRepcre = 'zip '||TRIM(cRutaArchRep)||TRIM('Clientes_con_productos_activos')||'.zip '||'-P Reportecredb*2018 /'||TRIM(cRutaArchRep)||TRIM(vNombreArchivo);
		SYSTEM cRepcre;
		
		LET vsMensaje = 'SE GENERO EL REPORTE CORRECTAMENTE';
		
		DROP TABLE tmp_ctes_cre;
		DROP TABLE tmp_ctes_prod_act_cre;
		DROP TABLE tmp_ctes_prod_act_sd_movhis;
		DROP TABLE tmp_ctes_db;
		DROP TABLE tmp_ctes_prod_act_db;
		DROP TABLE tmp_ctes_prod_act_sc_movhis;
		
	RETURN vsCodRetorno, vsMensaje;
END;
END PROCEDURE;