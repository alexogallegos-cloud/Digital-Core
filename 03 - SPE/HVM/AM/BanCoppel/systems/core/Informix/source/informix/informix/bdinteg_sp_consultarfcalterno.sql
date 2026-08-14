CREATE PROCEDURE "informix".sp_consultarfcalterno(pempresa char(3),pnumcte char(20))

--VARIABLES A RETORNAR(MOSTRAR)
RETURNING
CHAR(5), -- Codigo de retorno
CHAR(13); -- rfc;

--DEFINIR VARIABLES A UTILIZAR (DEFINE)
DEFINE vcodret char(5);
DEFINE vrfc_alterno char(13);

--INICIALIZAR VARIABLES
LET vcodret ="00000";
LET vrfc_alterno = "";

--SET DEBUG FILE TO '/tmp/sp_consultarrfcalterno.out';
--TRACE ON;

BEGIN

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		IF EXISTS (SELECT rfc_alterno FROM bdinteg:"informix".si_cliente WHERE numcte=pnumcte AND empresa=pempresa) THEN

			SELECT rfc_alterno
			INTO vrfc_alterno 
			FROM bdinteg:"informix".si_cliente 
			WHERE numcte=pnumcte
			AND empresa=pempresa;

			IF  NVL(vrfc_alterno,"" ) = ""  THEN
	
			 LET  vcodret = "001";
			 LET  vrfc_alterno = "";
		
			ELSE 
		
		 	LET  vcodret = "000";
		
			END IF
	
			RETURN vcodret, vrfc_alterno;

		END IF;
	
END
END PROCEDURE
DOCUMENT
'Folio.........: 1519-INC-RFC_ALTERNO_II',
'Autor.........: Prisma Calderón',
'Fecha.........: 03/10/2014',
'Modificación..: Se crea procedimiento para consultar el rfc alterno.',
'Sustento......: Insertar el dato del RFC Alterno en sucursal',
'Solicita......: Cutberto Gonzalez',
'BD............: bdinteg';

CREATE PROCEDURE "informix".sp_reporte_mtto_domicilio_ife(pEmpresa CHAR(3))
RETURNING CHAR(5) AS codret ;

    DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cMes CHAR(2);
	DEFINE cAnio CHAR(4);
    DEFINE dFecha_Hoy DATE;
	DEFINE dFecha_reporte DATE;
	DEFINE cNumCte CHAR(20);
	DEFINE cNumCredito CHAR(20);
	DEFINE dFechaApertura DATE;
	DEFINE dFechaInicio DATE;
	DEFINE dFechaFinal DATE;
	DEFINE cSucursal CHAR(4);
	DEFINE cRutaReporteIFE CHAR(100);
	DEFINE cStmt CHAR(250);


    LET cCodRet = "00000";
    LET iSqlErr = 0;
    LET cMes = '';
    LET cAnio = '';
	LET dFecha_Hoy = DATE(1);
	LET dFecha_reporte = DATE(1);
	LET cNumCte = '';
	LET cNumCredito = '';
	LET dFechaApertura = DATE(1);
	LET cSucursal = '';
	LET dFechaInicio  = DATE(1);
	LET dFechaFinal  = DATE(1);
	LET cRutaReporteIFE = '';
	LET cStmt = '';

	 -- SET DEBUG FILE TO '/respaldosbd/mario/sp_reporte_mtto_domicilio_ife.out';
	 -- TRACE ON;

    BEGIN

        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				RETURN cCodRet  ;
            END IF;
        END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM bdinteg:"informix".si_fechas
		WHERE empresa =pEmpresa;

		EXECUTE PROCEDURE bdicred:"informix".monthadd(dFecha_Hoy,-1)  INTO dFecha_reporte;
		
        LET cMEs = LPAD(MONTH(dFecha_reporte::DATE), 2, '0');
        LET cAnio = YEAR(dFecha_reporte ::DATE);		

		SELECT TRIM(a.valor)|| TRIM(b.valor)
		INTO cRutaReporteIFE
		FROM bdicred:"informix".sd_param a , bdicred:"informix".sd_param b
		WHERE a.empresa = pEmpresa AND b.empresa = pEmpresa
		AND  a.cod_param = 150 AND b.cod_param = 151;

		LET cRutaReporteIFE = REPLACE(cRutaReporteIFE,'MM',cMes);
		LET cRutaReporteIFE = REPLACE(cRutaReporteIFE,'AAAA',cAnio);

		
		LET dFechaInicio =  dFecha_reporte-DAY(dFecha_reporte-1);
		LET dFechaFinal =  LAST_DAY(dFecha_reporte);


		FOREACH SELECT numcte,num_solicitud,fecha_insert,sucursal INTO cNumCte, cNumCredito, dFechaApertura,cSucursal  FROM bdisolic:"informix".ss_solicitudes  WHERE num_solicitud IN (SELECT num_solicitud FROM bdisolic:"informix".ss_solicitud_os WHERE motivo_os =  '14') AND fecha_insert  BETWEEN dFechaInicio AND dFechaFinal	

			LET cStmt = 'echo "' || TRIM(cNumCte)||"|"|| TRIM(cNumCredito)|| "|" || dFechaApertura|| "|" || TRIM(cSucursal) || '">> ' || cRutaReporteIFE;
			SYSTEM cStmt;
			
		END FOREACH;
			
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cStmt = 'echo "' || "" ||'">> ' || cRutaReporteIFE;
			SYSTEM cStmt;
		END IF;

		RETURN cCodRet;

    END;
END PROCEDURE
DOCUMENT
"Folio:1586",
"Autor:95142134 Mario Gallardo",
"Fecha:10/03/2014",
"Modificación: Se crea SP para generar reporte de los clientes que entraron en el proceso de mantenimiento de domicilio diferente al IFE",
"Sustento: RQM 09 337 Mantenimiento de Datos y OS para Domicilio diferente al IFE_0001_v1.0.pdf",
"Solicita: Jaime Garciadiego, Juan Miguel Rivas ",
"BD: bdisolic";

CREATE PROCEDURE "informix".sp_marca_domicilio_os
(
   pEmpresa CHAR(3),
   pNumCte CHAR(20),
   pRespuestaOs CHAR(1),
   pSecuenciaDireccion INTEGER
)
RETURNING CHAR(5) AS codret ;
    
DEFINE cCodRet CHAR(5);
DEFINE iSql_err INTEGER;

LET cCodRet = '00000';
LET iSql_err	 = 0;

BEGIN
    
    ON EXCEPTION SET iSql_err
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
            RETURN cCodRet  ;
        END IF;
    END EXCEPTION;
    
     --SET DEBUG FILE TO "/respaldosbd/mario/sp_marca_domicilio_os.out";
     --TRACE ON;
	 --SET DEBUG FILE TO "/respaldosbd/mc/sp_marca_domicilio_os.out";
      --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;  
	
	IF NVL(pEmpresa,'') <> '' AND NVL(pNumCte,'') <> '' AND NVL(pRespuestaOs,'') <> '' AND NVL(pSecuenciaDireccion,'') <> '' THEN
		IF (SELECT MAX(secuencia) FROM bdinteg:"informix".si_direcciones_actual WHERE  numcte = pNumCte AND tipo_dir = '1'  ) > pSecuenciaDireccion THEN
			IF (SELECT 1 FROM bdinteg:"informix".si_ctes_manttodomife WHERE empresa =pEmpresa AND numcte = pNumCte) = 1 THEN
				UPDATE bdinteg:"informix".si_ctes_manttodomife SET flag_envia_os = '1' WHERE empresa =pEmpresa AND numcte = pNumCte;
			ELSE
				INSERT INTO bdinteg:"informix".si_ctes_manttodomife (empresa,numcte,flag_envia_os,fecha_insert,fecha_respuesta_os) VALUES (pEmpresa,pNumCte,pRespuestaOs,CURRENT,'');
			END IF;
		END IF;
	ELSE
		LET cCodRet = '00001';
	END IF;
	
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
"Folio:1586",
"Autor:95142134 Mario Gallardo",
"Fecha:27/02/2014",
"Modificación: Se crea SP para vailidar que el domicilio de el cliente sea el mismo que el de la IFE",
"Sustento: RQM 09 337 Mantenimiento de Datos y OS para Domicilio diferente al IFE_0001_v1.0.pdf",
"Solicita: Jaime Garciadiego, Juan Miguel Rivas ",
"BD: bdinteg",
"Folio:1430",
"Autor:95142134 Ivan Garcia",
"Fecha:26/05/2014",
"Modificación: Se Modifica SP para que no comtemple el campo fecha_respuesta_os de la tabla si_ctes_manttodomife tanto para la inserción como la actualización",
"Sustento: RQM 09 337 Mantenimiento de Datos y OS para Domicilio diferente al IFE_0001_v1.0.pdf",
"Solicita: Aangeles Perez,Rodolfo Gomez ",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_validatarjtranfer(pEmpresa CHAR(3),pNumeroTarjeta CHAR(16), pTipoCuenta CHAR(1))
--RETORNOS-
RETURNING
CHAR(6) AS codret,
CHAR(26) AS apell_paterno,
CHAR(26) AS apell_materno,
CHAR(26) AS nombre1,
CHAR(26) AS nombre2,
CHAR(60) AS Razon_social,
CHAR(2) AS tipo_persona,
CHAR(20) AS numcte;

--DECLARACION DE VARIABLES--
DEFINE cCodret CHAR(6);
DEFINE iSql_err INTEGER; 
DEFINE iIsamErr INTEGER;
DEFINE cApell_paterno CHAR(26);
DEFINE cApell_materno CHAR(26); 
DEFINE cNombre1 CHAR(26);
DEFINE cNombre2 CHAR(26); 
DEFINE cRazon_social CHAR(60);
DEFINE cTipo_persona CHAR(2); 
DEFINE cNumcte CHAR(20); 
DEFINE cProdTransfer CHAR(4);
DEFINE cProdTarjeta CHAR(4);

--INICIALIZACION DE VARIABLES--
LET cCodret = '000000';
LET iIsamErr = 0 ;
LET iSql_err = 0 ;
LET cApell_paterno ='';
LET cApell_materno ='';
LET cNombre1 ='';
LET cNombre2 ='';
LET cRazon_social ='';
LET cTipo_persona ='';
LET cNumcte ='';
LET cProdTransfer = '';
LET cProdTarjeta = '';

BEGIN

	ON EXCEPTION SET iSql_err , iIsamErr
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN cCodret,cApell_paterno,cApell_materno,cNombre1,cNombre2,cRazon_social,cTipo_persona,cNumcte;
		END IF;
	END EXCEPTION;
		
	--SET DEBUG FILE TO '/respaldosbd/mario/sp_validatarjtranfer.out';
	--TRACE ON;
	
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;
	  

	 IF NVL(pEmpresa, '' ) = '' OR NVL(pNumeroTarjeta,'')= '' OR  NVL(pTipoCuenta, '') = '' THEN
		LET cCodret = '000001'; 
	ELSE
			SELECT valor
			INTO cProdTransfer
			FROM bditransfer:"informix".tf_param
			WHERE empresa = pEmpresa AND cod_param = 4;
			
			IF pTipoCuenta = '0' THEN
			
					SELECT prodtarjeta 
					INTO cProdTarjeta
					FROM bdicheq:"informix".sc_tarjeta
					WHERE empresa = pEmpresa AND num_tarjeta = pNumeroTarjeta;
					
			ELIF pTipoCuenta = '1' THEN
			
					SELECT prodtarjeta 
					INTO cProdTarjeta
					FROM bdicred:"informix".sd_tarjeta
					WHERE empresa = pEmpresa AND num_tarjeta = pNumeroTarjeta;
					
			ELSE
				LET cCodret = '000002'; 
			END IF;
			
			IF cCodret =  '000000' THEN
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000002';
				ELSE
					IF TRIM(cProdTransfer) <> TRIM(cProdTarjeta) THEN					
						IF pTipoCuenta = '0' THEN
							SELECT a.apell_paterno,a.apell_materno,a.nombre1,a.nombre2,a.razon_social,a.tpo_persona,a.numcte
							INTO cApell_paterno,cApell_materno,cNombre1,cNombre2,cRazon_social,cTipo_persona,cNumcte
							FROM bdinteg:"informix".si_cliente a, bdicheq:"informix".sc_tarjeta b
							WHERE a.empresa = pEmpresa AND a.numcte = b.numcte AND b.num_tarjeta = pNumeroTarjeta;
						ELIF pTipoCuenta = '1' THEN						
							SELECT a.apell_paterno,a.apell_materno,a.nombre1,a.nombre2,a.razon_social,a.tpo_persona,a.numcte
							INTO cApell_paterno,cApell_materno,cNombre1,cNombre2,cRazon_social,cTipo_persona,cNumcte
							FROM bdinteg:"informix".si_cliente a ,bdicred:"informix".sd_tarjeta b
							WHERE a.empresa = pEmpresa AND a.numcte = b.numcte AND b.num_tarjeta =pNumeroTarjeta;
						END IF;
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodret = '000002';
						END IF;
						
					ELSE
						LET cCodret = "858";
					END IF
				END IF;
			END IF;
	 END IF;
	 
	 RETURN cCodret,cApell_paterno,cApell_materno,cNombre1,cNombre2,cRazon_social,cTipo_persona,cNumcte;
	 
END;
END PROCEDURE
DOCUMENT
'Folio:1636',
'Autor:951421354 Mario Gallardo',
'Fecha:27/08/2014',
'Modificación: se crea procedimiento para validar si la tarjeta tiene producto transfer',
'Sustento: Cambios_Plataforma_Observaciones.odt',
'Solicita:  Berenice Mendez',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_get_estadisticafusion(cTipoFusion CHAR(1), cEstadoFusion CHAR(5) ,dFechaProceso DATE, cCanal CHAR(5), dFecha DATE, cUsuario CHAR(8))
RETURNING CHAR(6);

	DEFINE iMesActual			INTEGER;
	DEFINE iMesAnterior			INTEGER;
	DEFINE iAnioActual			INTEGER;
	DEFINE iAnioAnterior		INTEGER;
	DEFINE iProcesados			INTEGER;
	DEFINE iFusionados			INTEGER;
	DEFINE iNo_fusionados		INTEGER;
	DEFINE iCantResultado		INTEGER;
	DEFINE iSqlErr				INTEGER;

	DEFINE cResultado			CHAR(5);
	DEFINE cRetorno				CHAR(6);
	
	DEFINE dFechaInicial		DATE;
	DEFINE dFechaFinal			DATE;
	DEFINE dMaxFechaInicial		DATE;
	DEFINE dMaxFechaFinal		DATE;
	

	LET iMesActual = MONTH(CURRENT::DATE);
	LET iAnioActual = YEAR(CURRENT::DATE);
	LET iProcesados			= 0;
	LET iFusionados			= 0;
	LET iNo_fusionados		= 0;
	LET iCantResultado		= 0;
	
	LET cRetorno 			= '000000';

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cRetorno = iSqlErr;
			ROLLBACK WORK;			
			RETURN cRetorno;
		END IF;
	END EXCEPTION;
	SET LOCK MODE TO WAIT 3;
	--Origen
	--1: Fusion automatica
	--2: Fusion manual
	--3: SOS - SIF
	--4: SOS - SOC
	--5: FRA - SIF
	--SET DEBUG FILE TO '/informix/cristobalhdez/estadistica.out';
	--TRACE ON;
	
	BEGIN WORK;
	
	IF NVL(cTipoFusion,'') = '' THEN
		LET cRetorno = '00001';
	ELIF cTipoFusion NOT IN ('0', '1', '2', '3', '4', '5') THEN
		LET cRetorno = '00002';
	ELIF (cTipoFusion = '0') AND (NVL(dFechaProceso,'') = '') OR (NVL(dFecha,'') = '') THEN
		LET cRetorno = '00003';
	ELIF (cTipoFusion IN ('1','2','3','4','5') AND (NVL(cEstadoFusion,'') = '' OR NVL(dFechaProceso,'') = '' OR NVL(cCanal,'') = '' OR NVL(dFecha,'') = '' OR NVL(cUsuario,'') = '')) THEN
		LET cRetorno = '00004';
	--ELIF (cTipoFusion <> '1' AND cTipoFusion <> '2') AND ((NVL(cEstadoFusion,'') = '' OR NVL(cUsuario,'') = '' OR NVL(dFechaProceso,'') = '')) THEN
	--	LET cRetorno = '00005';
	ELSE
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT MONTH(MAX(fecha_final)), YEAR(MAX(fecha_final)) 
		INTO iMesAnterior, iAnioAnterior 
		FROM bdinteg:si_estadistica_fusiones_mens;
		
		--Estadistica total diaria
		IF cTipoFusion = '0' THEN
			FOREACH
				SELECT canal, NVL(SUM(procesados),0) as procesados, NVL(SUM(fusionados),0) as fusionados, NVL(SUM(no_fusionados),0) as no_fusionados
				INTO cTipoFusion, iProcesados, iFusionados, iNo_fusionados
				FROM (TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_fusionaut idx_fusfp_estatus)} canal,
														CASE WHEN estatus IS NOT NULL THEN NVL(COUNT(cliente_tit),0) END AS procesados,
														CASE WHEN estatus = '1' THEN NVL(COUNT(cliente_tit),0) END AS fusionados,
														CASE WHEN estatus >= '2' THEN NVL(COUNT(cliente_tit),0) END AS no_fusionados																
													FROM bdinteg:si_fusionaut
													WHERE fecha_proceso = dFechaProceso
													GROUP BY canal,estatus)))
				GROUP BY canal
				UNION ALL
				SELECT canal, NVL(SUM(procesados),0) as procesados, NVL(SUM(fusionados),0) as fusionados, NVL(SUM(no_fusionados),0) as no_fusionados
				FROM (TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_fusion_solic idx_fussolic_estatus)} canal,
														CASE WHEN estatus IS NOT NULL THEN NVL(COUNT(cliente_tit),0) END AS procesados,
														CASE WHEN estatus = '1' THEN NVL(COUNT(cliente_tit),0) END AS fusionados,
														CASE WHEN estatus >= '2' THEN NVL(COUNT(cliente_tit),0) END AS no_fusionados																
													FROM bdinteg:si_fusion_solic
													WHERE fecha_proceso = dFechaProceso
													GROUP BY canal,estatus))) 
				GROUP BY canal
				ORDER BY canal
				
				IF EXISTS(SELECT fecha_proceso FROM bdinteg:si_estadistica_fusiones WHERE fecha_proceso = dFechaProceso AND tipo_fusion = cTipoFusion) THEN
					UPDATE bdinteg:si_estadistica_fusiones SET
						procesados = iProcesados,
						fusionados = iFusionados,
						no_fusionados = iNo_fusionados,
						fecha_insert = CURRENT::DATE
					WHERE fecha_proceso = dFechaProceso::DATE 
					AND tipo_fusion = cTipoFusion;
				ELSE
					INSERT INTO bdinteg:si_estadistica_fusiones (fecha_proceso, tipo_fusion, procesados, fusionados, no_fusionados, user_proceso, user_insert, fecha_insert)
					VALUES(dFechaProceso,cTipoFusion,iProcesados,iFusionados,iNo_fusionados,cUsuario,USER,CURRENT);
				END IF;
				
				--Estadistica detalle diaria
				FOREACH 
					SELECT cod_retorno, COUNT(*)
					INTO cResultado, iCantResultado
					FROM bdinteg:si_fusionaut 
					WHERE fecha_proceso = dFechaProceso
					AND canal = cTipoFusion
					GROUP BY cod_retorno
					UNION ALL
					SELECT cod_retorno, COUNT(*)
					FROM bdinteg:si_fusion_solic
					WHERE fecha_proceso = dFechaProceso
					AND canal = cTipoFusion
					GROUP BY cod_retorno
					ORDER BY cod_retorno ASC
					
					IF EXISTS(SELECT fecha_proceso FROM bdinteg:si_estadistica_fusiones_det WHERE fecha_proceso=dFechaProceso AND tipo_fusion = cTipoFusion AND cod_retorno = cResultado ) THEN
						UPDATE bdinteg:si_estadistica_fusiones_det
							SET cantidad = iCantResultado
							WHERE fecha_proceso=dFechaProceso
							AND tipo_fusion = cTipoFusion 
							AND cod_retorno = cResultado;
					ELSE
						INSERT INTO bdinteg:si_estadistica_fusiones_det (fecha_proceso, tipo_fusion, cod_retorno, cantidad, user_proceso, user_insert, fecha_insert)
						VALUES (dFechaProceso, cTipoFusion, cResultado, iCantResultado, cUsuario, USER, CURRENT);
					END IF;				
				END FOREACH;			
			END FOREACH;
			
			SELECT MAX(fecha_inicial), MAX(fecha_final) 
			INTO dMaxFechaInicial, dMaxFechaFinal 
			FROM si_estadistica_fusiones_mens;
			--WHERE tipo_fusion = cTipoFusion;
												
			LET dFechaInicial = (EXTEND(dFechaProceso::DATE, YEAR TO MONTH) - 1 UNITS MONTH)::DATE;
			LET dFechaFinal = (EXTEND(dFechaProceso::DATE, YEAR TO MONTH))::DATE - 1;
			
			--Estadistica mensual
			IF (DAY (dFechaProceso) = 1) OR (dFechaProceso - dMaxFechaFinal > DAY(dFechaFinal) OR (DAY (dFechaProceso::DATE) > 1 AND dMaxFechaFinal IS NULL))  THEN
				
				FOREACH 
					SELECT DISTINCT tipo_fusion, NVL(SUM(procesados),0), NVL(SUM(fusionados),0), NVL(SUM(no_fusionados),0)
					INTO cTipoFusion, iProcesados,iFusionados,iNo_fusionados
					FROM bdinteg:si_estadistica_fusiones
					WHERE fecha_proceso >= dFechaInicial
					AND fecha_proceso <= dFechaFinal
					--AND tipo_fusion = cTipoFusion
					GROUP BY tipo_fusion
					
					IF NOT EXISTS (SELECT dFechaInicial FROM si_estadistica_fusiones_mens WHERE fecha_inicial = dFechaInicial AND fecha_final = dFechaFinal AND tipo_fusion = cTipoFusion) THEN
						INSERT INTO bdinteg:si_estadistica_fusiones_mens (fecha_inicial, fecha_final, tipo_fusion, procesados, fusionados, no_fusionados, user_proceso, user_insert, fecha_insert)
						VALUES (dFechaInicial, dFechaFinal, cTipoFusion, iProcesados,iFusionados,iNo_fusionados, cUsuario, USER, CURRENT);
					ELSE
						UPDATE bdinteg:si_estadistica_fusiones_mens
							SET procesados = iProcesados, fusionados = iFusionados, no_fusionados = iNo_fusionados
						WHERE fecha_inicial = dFechaInicial 
							AND fecha_final = dFechaFinal 
							AND tipo_fusion = cTipoFusion;
					END IF;
					
				END FOREACH;	
				
				--Estadistica detalle mensual
				FOREACH 
					SELECT DISTINCT tipo_fusion, cod_retorno, NVL(SUM(cantidad),0)
					INTO cTipoFusion, cResultado, iCantResultado
					FROM bdinteg:si_estadistica_fusiones_det
					WHERE fecha_proceso >= dFechaInicial
					AND fecha_proceso <= dFechaFinal
					GROUP BY tipo_fusion,cod_retorno
					ORDER BY tipo_fusion ASC, cod_retorno ASC
					
					IF NOT EXISTS(SELECT dFechaInicial FROM bdinteg:si_estadistica_fusiones_det_mens WHERE fecha_inicial = dFechaInicial AND fecha_final = dFechaFinal AND tipo_fusion = cTipoFusion AND cod_retorno = cResultado) THEN
						INSERT INTO bdinteg:si_estadistica_fusiones_det_mens (fecha_inicial, fecha_final, tipo_fusion, cod_retorno, cantidad, user_proceso, user_insert, fecha_insert)
						VALUES (dFechaInicial, dFechaFinal, cTipoFusion, cResultado, iCantResultado, cUsuario, USER, CURRENT);
					ELSE
						UPDATE bdinteg:si_estadistica_fusiones_det_mens
							SET cantidad = iCantResultado
						WHERE fecha_inicial = dFechaInicial 
							AND fecha_final = dFechaFinal							
							AND tipo_fusion = cTipoFusion
							AND cod_retorno = cResultado;
					END IF;
					
				END FOREACH;
			END IF;
		ELSE
			IF cEstadoFusion::INTEGER = 0 THEN 
				LET iFusionados = 1;
			ELSE
				LET iNo_fusionados = 1;
			END IF;
			IF NOT EXISTS (SELECT fecha_proceso  FROM bdinteg:si_estadistica_fusiones WHERE fecha_proceso = dFechaProceso::DATE AND tipo_fusion = cTipoFusion) THEN

				INSERT INTO bdinteg:si_estadistica_fusiones (fecha_proceso, tipo_fusion, procesados, fusionados, no_fusionados, user_proceso, user_insert, fecha_insert)
				VALUES (dFechaProceso::DATE, cTipoFusion, 1  , iFusionados, iNo_fusionados , cUsuario, USER, CURRENT);
															
				INSERT INTO bdinteg:si_estadistica_fusiones_det (fecha_proceso, tipo_fusion, cod_retorno, cantidad, user_proceso, user_insert, fecha_insert)
				VALUES (dFechaProceso::DATE, cTipoFusion, cEstadoFusion, 1, cUsuario, USER, CURRENT);
			ELSE
				UPDATE bdinteg:si_estadistica_fusiones
				SET procesados = procesados + 1, fusionados = fusionados + iFusionados, no_fusionados = no_fusionados + iNo_fusionados
				WHERE fecha_proceso = dFechaProceso::DATE 
				AND tipo_fusion = cTipoFusion;
				
				UPDATE bdinteg:si_estadistica_fusiones_det
				SET cantidad = cantidad + 1
				WHERE fecha_proceso = dFechaProceso::DATE
				AND tipo_fusion = cTipoFusion
				AND cod_retorno = cEstadoFusion;
			END IF;			
		END IF;		
	END IF;
	COMMIT WORK;
	RETURN cRetorno;
END 
END PROCEDURE
DOCUMENT
'SUSTENTA: RQI 64 032',
'AUTOR: Jose Angel Lopez Adams',
'FECHA: 2014-07-25',
'SOLICITA: Jaime GonzÃ¡lez',
'MODIFICACION: Se crea SP el se encaragrÃ  de calcular las estadisticas en cuanto a resultados diarios y acumulados mensuales de la fusion automatica,',
'              de igual forma, esta preparado para contabilizar las fusiones manuales ejecutadas por el SOS a travÃ¨s del SIF o SOC, y tambien ejecuciones',
'              manuales del SP bdinteg:sp_fusion_cte_automatizada',
'BASE DE DATOS: bdinteg',
'EJECUTADO POR: bdinteg:sp_fusion_cte_automatizada',
'*********************************************************************************',
'AUTOR: Jose Angel Lopez Adams',
'FECHA: 2014-07-30',
'MODIFICACION: Se modifica para que al calcular las instrucciones NO fusionadas, contemple las que fueron omitidas por la validacion de tipo de cliente (3 y 4)',
'*********************************************************************************',
'AUTOR: Jose Angel Lopez Adams',
'FECHA: 2014-11-19',
'MODIFICACION: Se modifica para que cuando reciba como parametro de tipo fusión un 0 calcule las estadisticas de todos los origenes de fusion, ',
'asi mismo hará las validaciones para determinar si debe calcular la estadistica mensual',
'si recibe un origen de fusión entre 1 y 5 el proceso asumira que es una fusion especifica y actualizara con incremento de 1 el origen de fusion que corresponda ',
'y omitira el calculo de la estadistica mensual';

CREATE PROCEDURE "informix".sp_referencias_personales()
	RETURNING CHAR(5),CHAR(80);	
	--DEFINICION DE VARIABLES	
	DEFINE vc_CodRet    CHAR(5);
	DEFINE cSql_stmt	CHAR(1000);
	DEFINE vi_SqlErr    INTEGER;
	DEFINE vi_iSAMErr   INTEGER;
	DEFINE vi_iSAMData  CHAR(80);
	DEFINE vc_Mensaje   CHAR(80);
	DEFINE vc_proceso   CHAR(50);
	DEFINE vc_tabla     CHAR(30);
	DEFINE vc_detalle_mov2 CHAR(200);
	DEFINE vClienteTitular CHAR(20);
	DEFINE vClienteTraspasaCtas CHAR(20); 
	DEFINE dtFechaInsercion DATETIME HOUR TO FRACTION;
	DEFINE pUsuario CHAR(8);
	DEFINE vfecha_fusion DATE;
	--ASIGNACION DE VALORES
	LET vc_CodRet = "00000";
	LET cSql_stmt = "";
	LET vi_SqlErr = 0;
	LET vi_iSAMErr= 0;
	LET vi_iSAMData="";
	LET vc_Mensaje = "EL PROCESO SE EFECTUO CORRECTAMENTE";
	LET vc_proceso = "FusionClientes";
	LET vc_tabla = "";
	LET vc_detalle_mov2 = "";
	LET vClienteTitular = "";
	LET vClienteTraspasaCtas = "";
	LET pUsuario = "";	
	LET vfecha_fusion = "";
	--SET DEBUG FILE TO "/informix/rmarquez/sp_referencias_personales.out";
	--TRACE ON;		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
	BEGIN		
		ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
			IF vi_SqlErr <> 0 THEN
				LET vc_CodRet = vi_SqlErr;
				LET vc_Mensaje = "ERROR NO CONTROLADO";
				SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
				ROLLBACK WORK;
				LET vc_detalle_mov2=vi_SqlErr||'|'||vi_iSAMErr||'|'||vi_iSAMData;
				INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES (vc_proceso,vc_tabla,vClienteTitular,vClienteTraspasaCtas,vc_detalle_mov2,dtFechaInsercion,pUsuario,dtFechaInsercion::DATE);
				RETURN vc_CodRet,vc_Mensaje;
			END IF;
		END EXCEPTION;		
		
		BEGIN WORK;
		FOREACH		
			--CLIENTES A FUSIONAR.
			SELECT cliente_titular, cliente_traspasar, fecha_fusion::date 
			INTO vClienteTitular, vClienteTraspasaCtas, vfecha_fusion 
			FROM bdinteg:"informix".si_fusbitacora WHERE fusion ='SI' AND cliente_titular <> '' AND  cliente_traspasar <> ''
			AND cliente_traspasar NOT IN (SELECT numcte FROM bdinteg:si_cliente)
			UNION ALL 
			SELECT {+INDEX (bdinteg:"informix".si_fusionaut idx_fusfp_estatus)}  cliente_tit, cliente_tras, fecha_fusion 
			FROM bdinteg:"informix".si_fusionaut WHERE estatus = 1
			AND cliente_tras NOT IN (SELECT numcte FROM bdinteg:si_cliente)
			ORDER BY 3
			
			IF EXISTS (SELECT {+INDEX(bdisolic:ss_refpersonales  idx_ss_refpersonales01)} num_solicitud  FROM bdisolic:"informix".ss_refpersonales WHERE numcte_ref = vClienteTraspasaCtas) THEN

				LET vc_proceso='TRASPASO DE REFERENCIAS';
				LET vc_tabla = "bdisolic:ss_refpersonales";
				SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
				
				INSERT INTO bdinteg:si_fusrefpersonales (empresa, num_solicitud, numcte, numcte_ref, parentesco, tipo_relacion, nombre_ref, telefono_ref)
				SELECT {+INDEX(bdisolic:ss_refpersonales idx_ss_refpersonales01)} empresa, num_solicitud, numcte, numcte_ref, parentesco, tipo_relacion, nombre_ref, telefono_ref
				FROM bdisolic:"informix".ss_refpersonales 
				WHERE numcte_ref = vClienteTraspasaCtas;
													
				LET cSql_stmt = "INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert) "||
					"SELECT '"||vc_proceso||"','"||vc_tabla||"','"||vClienteTitular||"','"||vClienteTraspasaCtas||"',TRIM('"||vClienteTraspasaCtas||"')||"||"'|'"||"||TRIM(num_solicitud),'"|| dtFechaInsercion ||"','"||pUsuario||"',CURRENT::DATE FROM bdisolic:ss_refpersonales WHERE empresa = '001' AND num_solicitud IS NOT NULL AND numcte IS NOT NULL AND numcte_ref='"||vClienteTraspasaCtas||"';";
				SET ISOLATION TO DIRTY READ;
				EXECUTE IMMEDIATE cSql_stmt;

				UPDATE {+INDEX(bdisolic:ss_refpersonales idx_ss_refpersonales01)} bdisolic:"informix".ss_refpersonales 
				SET numcte_ref = vClienteTitular
				WHERE numcte_ref = vClienteTraspasaCtas;		
			END IF;		 
		END FOREACH;
		
		COMMIT WORK;		
		
		RETURN vc_CodRet,vc_Mensaje;			
	END;
END PROCEDURE
DOCUMENT
'AUTOR: Rocio Karina Márquez Coronel',
'FECHA: 18/Nov/2014',
'DESCRIPCION: Se agrega el proceso para fusionar los registros de la tabla bdisolic:ss_refpersonales cuando el cliente incorrecto se encuentre como referencia (numcte_ref)',
'Actualizará la tabla ss_refpersonales los clientes que se encuentran en la tabla si_fusbitacora y si_fusionaut',
'SUSTENTO: RQI 64 054 Fusión de referencias personales',
'SOLICITA: José Angel López Adams',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_cons_chq_dev_aud(pTipo INTEGER,
												pFechaIni CHAR(10),
												pFechaFin CHAR(10),
												pEmpresa CHAR(3),
												pSucursal CHAR(4),
												pCodigo CHAR(4),
												pUsuario CHAR(8),
												pSkip INTEGER,
												pLimite INTEGER)
													
RETURNING 
		      CHAR(5)  AS CodRet,
			  CHAR(20) AS Cliente,
			  CHAR(16) AS Folio,
			  CHAR(10) AS Fecha,
			  CHAR(20) AS Cuenta,
			  CHAR(17) AS Monto,
			  CHAR(12) AS Hora,
			  CHAR(8)  AS Usuario,
			  CHAR(4)  AS Transaccion,
			  CHAR(17) AS Saldo,
			  CHAR(4)  AS Sucursal,
			  CHAR(4)  AS Banco,
			  CHAR(20) AS Cuenta_del_Banco,
			  CHAR(11) AS Cheque,
			  CHAR(16) AS Tarjeta,
			  INTEGER  AS TotRows;
			
--Definicion de Variables
DEFINE cCodRet				CHAR(5);
DEFINE cCliente				CHAR(20);
DEFINE cFolio				CHAR(16);
DEFINE cHora				CHAR(12);
DEFINE cUsuario				CHAR(8);
DEFINE cTransaccion			CHAR(4);
DEFINE cSaldo				CHAR(17);
DEFINE cSucursal			CHAR(4);
DEFINE cBanco				CHAR(4);
DEFINE cCtaBanco			CHAR(20);
DEFINE cCheque				CHAR(11);
DEFINE cTarjeta				CHAR(16);
DEFINE dFechaIni			DATE;
DEFINE dFechaFin			DATE;
DEFINE dFechaHoy			DATE;
DEFINE dFechaParaMovhisOld 	DATE;
DEFINE dFechaParaMovhisOld2 DATE;
DEFINE cFechaParaMovhisOld 	CHAR(10);
DEFINE cFechaParaMovhisOld2 CHAR(10);
DEFINE iFechAnio 			INTEGER;
DEFINE cFechaIni 			CHAR(10);
DEFINE cFechaFin 			CHAR(10);
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(4);
DEFINE iSqlErr 				INTEGER;
DEFINE iLinea				INTEGER;
DEFINE cCuenta				CHAR(20);
DEFINE cMonto				CHAR(17);
DEFINE dFecha_Alt			DATE;
DEFINE iTotalRows			INTEGER;
DEFINE dFecha				DATE;
DEFINE dFechaActual			DATE;
DEFINE cReferencia          CHAR(40);


LET cCodRet 				= "00000";
LET cCliente 				= "";
LET cFolio 					= "";
LET cHora 					= "";
LET cUsuario 				= "";
LET cTransaccion 			= "";
LET cSaldo 					= "";
LET cSucursal 				= "";
LET cBanco 					= "";
LET cCtaBanco 				= "";
LET cCheque 				= "";
LET cTarjeta 				= "";
LET dFechaIni 				= DATE(1);
LET dFechaFin 				= DATE(1);
LET dFechaHoy 				= DATE(1);
LET dFechaParaMovhisOld 	= DATE(1);
LET dFechaParaMovhisOld2 	= DATE(1);
LET iFechAnio 				= 0;
LET cFechaParaMovhisOld 	= "";
LET cFechaParaMovhisOld2 	= "";
LET cFechaIni 				= "";
LET cFechaFin 				= "";
LET cDia 					= "";
LET cMes 					= "";
LET cAnio 					= "";
LET iLinea 					= 0;
LET	cCuenta					= "";
LET cMonto					= "";
LET dFecha_Alt				= DATE(1);
LET iTotalRows 				= 0;
LET dFecha					= DATE(1);
LET dFechaActual            = DATE(1);
LET cReferencia          	= '';

/*----------------*----------------*----------------*----------------*----------------*------------*
/ Se crea procedimiento almacenado para extraer la información requerida para la generación        /
/ del reporte de "Cheques Devueltos" desde la tabla si_rptcaja_aud                                 /
/ Elaborado por: Adilene Lara                                                                      /
/ Fecha: 24/11/2014                                                                                /
/ Solicitado por: Norberto Corona                                                                  /
*----------------*----------------*----------------*----------------*----------------*------------*/
	

--SET DEBUG FILE TO '/tmp/sp_cons_chq_dev_aud.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
			
			
			LET cCliente 				= "";
			LET cFolio 					= "";
			LET cHora 					= "";
			LET cUsuario 				= "";
			LET cTransaccion 			= "";
			LET cSaldo 					= "";
			LET cSucursal 				= "";
			LET dFecha_Alt				= "";
			LET cBanco 					= "";
			LET cCtaBanco 				= "";
			LET cCheque 				= "";
			LET cTarjeta 				= "";
			LET iTotalRows 				= 0;
			RETURN cCodRet,cCliente,cFolio,dFecha_Alt,cCuenta,cMonto,cHora,cUsuario,cTransaccion,cSaldo,cSucursal,cBanco,cCtaBanco,cCheque,cTarjeta,iTotalRows;
			
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
				LET cFechaIni = pFechaIni;
				LET cDia = SUBSTRING(cFechaIni FROM 1 FOR 2);
				LET cMes =  SUBSTRING(SUBSTRING(cFechaIni FROM 4 FOR 4) FROM 1 FOR 2);
				LET cAnio = SUBSTRING(cFechaIni FROM 7 FOR 10);
				LET dFechaIni = DATE(TRIM(cMes||'/'||cDia||'/'||cAnio));

				LET cFechaFin = pFechaFin;
				LET cDia = SUBSTRING(cFechaFin FROM 1 FOR 2);
				LET cMes =  SUBSTRING(SUBSTRING(cFechaFin FROM 4 FOR 4) FROM 1 FOR 2);
				LET cAnio = SUBSTRING(cFechaFin FROM 7 FOR 10);
				LET dFechaFin = DATE(TRIM(cMes||'/'||cDia||'/'||cAnio));
			
				SELECT DISTINCT(COUNT(folio))
				INTO iTotalRows
				FROM bdinteg:"informix".si_rptcaja_aud
				WHERE empresa = pEmpresa
				AND sucursal = pSucursal
				AND cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
				AND fecha BETWEEN dFechaIni AND dFechaFin
				AND reversado <> 'S';	
				
			FOREACH
			
				SELECT SKIP pSkip LIMIT  pLimite  DISTINCT cliente,folio,fecha,cuenta,monto,hora,usuario,transaccion,saldo,sucursal,banco,cuenta_banco, cheque,tarjeta
				INTO cCliente,cFolio,dFecha_Alt,cCuenta,cMonto,cHora,cUsuario,cTransaccion,cSaldo, cSucursal,cBanco,cCtaBanco,cCheque,cTarjeta
				FROM bdinteg:"informix".si_rptcaja_aud
				WHERE empresa = pEmpresa
				AND sucursal = pSucursal
				AND cod_transacc IN  (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE empresa = pEmpresa  AND codigo = pCodigo)
				AND fecha BETWEEN dFechaIni AND dFechaFin
				AND reversado <> 'S'
				ORDER BY fecha,hora ASC
				
				LET cCodRet = '00000'; --Sin Errores
				
				RETURN cCodRet,cCliente,cFolio,dFecha_Alt,cCuenta,cMonto,cHora,cUsuario,cTransaccion,cSaldo,cSucursal,cBanco,cCtaBanco,cCheque,cTarjeta,iTotalRows WITH RESUME;	
				
			END FOREACH;
			
			LET pSkip = pSkip + pLimite ;
	END
END PROCEDURE;