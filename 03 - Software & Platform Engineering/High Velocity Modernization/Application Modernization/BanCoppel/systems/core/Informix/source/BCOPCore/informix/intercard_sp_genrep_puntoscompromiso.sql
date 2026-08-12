CREATE PROCEDURE "informix".sp_genrep_puntoscompromiso(pUsuario CHAR(8), pIdFuncion CHAR(10),psProdInd VARCHAR(2), psIdPOSATM VARCHAR(19), 
psGiro VARCHAR(4), psTarjetas CHAR(570), psModoCaptura VARCHAR(2), psCodigoIso VARCHAR(2), pdtFechaIni DATE, pdtFechaFin DATE, pRuta CHAR(100), pTipoReporte SMALLINT)
    RETURNING CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
    DEFINE iCodRetSp INTEGER;
	DEFINE cRutaArchivo CHAR(100);
	DEFINE cNombreArchivo CHAR(30);
	DEFINE bInTransaction BOOLEAN;
	DEFINE cSql CHAR(2500);
	DEFINE cNombreReporte CHAR(100);
	DEFINE cNombreReporteHist CHAR(100);
	DEFINE cFechaHoraArchivo CHAR(15);
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO MINUTE;
	DEFINE iTotalReg INTEGER;
	DEFINE cIdPlantilla CHAR(10);
	DEFINE cIdMensaje CHAR(10);
	DEFINE cStr1 CHAR(30);
	DEFINE cStr6 CHAR(100);
	DEFINE cStr7 CHAR(60);
	DEFINE dHoy DATETIME YEAR TO FRACTION(3);
	DEFINE cFeHrInsert CHAR(6);
	
	LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '000000';
    LET iCodRetSp = 0;
	LET cRutaArchivo = '';
	LET cNombreArchivo = '';
	LET bInTransaction = 'f';
	LET cSql = '';
	LET cNombreReporte = '';
	LET cNombreReporteHist = '';
	LET cFechaHoraArchivo = '';
	LET dFechaHoy = '';
	LET dHoraHoy = '';
	LET iTotalReg = 0;
	LET cIdPlantilla = '';
	LET cIdMensaje   = '';
	LET cStr1 = '';
	LET cStr6 = '';
	LET cStr7 = '';
	LET dHoy = '';
	LET cFeHrInsert = TO_CHAR(CURRENT::DATETIME HOUR TO SECOND, '%H%M%S');
	
	BEGIN
	 
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_puntoscompromiso.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR psProdInd ='' OR pdtFechaIni IS NULL OR pdtFechaFin IS NULL OR pRuta = '' OR pTipoReporte IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE intercard:"informix".sp_puntoscompromiso3_2(psProdInd,psIdPOSATM,psGiro,psTarjetas,psModoCaptura,psCodigoIso,pdtFechaIni,pdtFechaFin,pUsuario,pRuta,pTipoReporte,cFeHrInsert)  
        INTO cCodRetSp, cRutaArchivo, cNombreArchivo;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		--IF iCodRetSp < 0 THEN
		--	RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP intercard:'informix'.sp_puntoscompromiso3_2";
		--END IF;
		
		-- SE ASIGNAN VALORES PARA LA GENERACIÓN DEL REPORTE
		LET cNombreReporte = cNombreArchivo;
		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;
		
		SELECT COUNT(*) INTO iTotalReg FROM bdicnweb:"informix".sw_con_puntoscompromisos_genrep WHERE us_insert = pUsuario AND fechahora_insert = cFeHrInsert;
		
		IF iCodRetSp = 0 THEN
		
			-- SE ELIMINAN TODOS LOS REGISTROS GENERADOS MENORES A LA FECHA HOY (T-1)
			FOREACH
			
				SELECT nombre_reporte
				INTO cNombreReporteHist
				FROM bdicnweb:"informix".sw_ctrlgenreportespuntoscomp 
				WHERE fecha_reporte < dFechaHoy 
				AND usuario_insert = pUsuario --AND nombre_reporte = TRIM(cNombreReporte)
				
				LET cSql = '';
				LET cSql = '/usr/bin/rm -rf '||TRIM(pRuta)||TRIM(cNombreReporteHist);
				SYSTEM TRIM(cSql);
				
				DELETE FROM bdicnweb:"informix".sw_ctrlgenreportespuntoscomp WHERE nombre_reporte = TRIM(cNombreReporteHist);
				
			END FOREACH;
			
			-- SE REGISTRA EN BITÁCORA
			DELETE FROM bdicnweb:"informix".sw_ctrlgenreportespuntoscomp WHERE nombre_reporte = TRIM(cNombreReporte);
			INSERT INTO bdicnweb:"informix".sw_ctrlgenreportespuntoscomp(nombre_reporte,fecha_reporte,hr_reporte,usuario_insert)
			VALUES(TRIM(cNombreReporte),dFechaHoy,dHoraHoy,pUsuario);
			
			-- PROCESO SIN ERROR
            LET cIdPlantilla = 'WEB_ARMOV';
			LET cIdMensaje   = 'WEB_PCOMCE';
			LET cStr6 = 'NOTIFICACIÓN GENERACIÓN ARCHIVO';
			
		ELSE
			
			-- PROCESO CON ERROR
            LET cIdPlantilla = 'WEB_ARMOV';
			LET cIdMensaje   = 'WEB_PCOMCE';
			LET cStr6 = 'NOTIFICACIÓN ERROR GENERACIÓN ARCHIVO';
			LET cCodRet = cCodRetSp;
			
		END IF;
		
		-- SE LIMPIAN TABLAS CONTROL GENERACIÓN DE REPORTE
		DELETE FROM bdicnweb:"informix".sw_con_puntoscompromisos_genrep WHERE us_insert = pUsuario AND fechahora_insert = cFeHrInsert;
		DELETE FROM bdicnweb:"informix".sw_con_pcompromisostarjetas_genrep WHERE us_insert = pUsuario AND fechahora_insert = cFeHrInsert;
		 
		-- NOTIFICACIÓN VÍA CORREO ELECTRÓNICO
		LET cStr1 = NVL(iTotalReg,0);
		LET cStr7 = 'GENERACIÓN DEL ARCHIVO';
		LET dHoy = CURRENT;
		
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(
		'1', 
		TRIM(cIdPlantilla), -- WEB_ARMOV
		TRIM(cIdMensaje),   -- WEB_PCOMCE
		pUsuario, 
		'',
		'', 
		'1', 
		TRIM(cStr1),
		'',
		'',
		'',
		'',
		TRIM(cStr6),
		TRIM(cStr7),
		'',
		'',
		'',
		'',
		'',
		'1',
		'0',
		'0',
		'0',
		'0',
		dHoy,
		dHoy) INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdimnsj:sp_registra_evento';
		ELIF iCodRetSp > 0 THEN
			LET cCodRet = '01018'; --OCURRIO UN ERROR EN LA EJECUCIÓN DEL SP bdimnsj:"informix".sp_registra_evento, VERIFIQUE
		END IF;
		
		
		RETURN cCodRet;
    
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat León Amador',
'FECHA: 15/01/2020',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE PUNTOS COMPROMISO',
'DESCRIPCION: SPL encargado de generar los reportes en formato txt y notificar vía correo electrónico al usuario que lo generó.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 28/01/2020',
'DESCRIPCION: Se modifica SPL para consumir nuevas tablas que controlan generación de reporte.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 14/02/2020',
'DESCRIPCION: Se modifica SPL para cancelar implementación de tratado de transacciones.',
'BD: intercard';

CREATE PROCEDURE "informix".sp_consultaestatus_tar(pEmpresa CHAR(3),pTarjeta CHAR(20))
							 RETURNING CHAR(5) AS codigo_retorno, CHAR(3) AS estatus_tar;
							 
DEFINE  iSqlerr  INTEGER;
DEFINE  cCodret  CHAR(5);
DEFINE  cEstatus CHAR(3);

LET     iSqlerr = 0;                    
LET 	cCodret = "00000";                     
LET 	cEstatus = "";                     


 --SET DEBUG FILE TO "/respaldosbd/mireya/sp_consultaestatus_tar.out";
 --TRACE ON;


	BEGIN
		ON EXCEPTION SET iSqlerr
				IF iSqlerr <> 0  THEN
						LET cCodret = iSqlerr;
						RETURN cCodret, cEstatus; 
				END IF;
				
		END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pTarjeta,"")) <> "" THEN

		SELECT  NVL(codstatustarjeta,"")
		INTO cEstatus
		FROM "informix".tarjeta
		WHERE numtarjeta = TRIM(pTarjeta);
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN  
			LET cCodret = "00002"; --TARJETA NO EXISTE
		end if;
	ELSE
		LET cCodret = "00001"; --PARAMETRO DE ENTRADA VACIO
	END IF;
	
	RETURN cCodret, cEstatus;

	END;

END PROCEDURE;