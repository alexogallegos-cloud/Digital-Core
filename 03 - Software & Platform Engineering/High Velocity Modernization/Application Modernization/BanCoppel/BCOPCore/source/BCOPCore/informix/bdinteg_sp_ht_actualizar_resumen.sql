CREATE PROCEDURE "informix".sp_ht_actualizar_resumen()
RETURNING
	CHAR(6) AS cod_ret

	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cCodRet			CHAR(6);
	
	DEFINE cFolioArchivo		CHAR(13);
	DEFINE iTotCtes				INT8;
	DEFINE iTotTelsVal 			INT8;
	DEFINE iTotTelsInval 		INT8;
	DEFINE iTotRegsPend			INT8;
	DEFINE iTotTelsAmbos 		INT8;
	DEFINE iTotTelsFijo 		INT8;
	DEFINE iTotTelsCel 			INT8;
	DEFINE iTotTelsFijoVal 		INT8;
	DEFINE iTotTelsFijoInval	INT8;
	DEFINE iTotTelsCelVal		INT8;
	DEFINE iTotTelsCelInval		INT8;

	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cCodRet             = "000000";
	
	LET cFolioArchivo		= "";
	LET iTotCtes			= 0;
	LET iTotTelsVal 		= 0;
	LET iTotTelsInval 		= 0;
	LET iTotRegsPend		= 0;
	LET iTotTelsAmbos 		= 0;
	LET iTotTelsFijo 		= 0;
	LET iTotTelsCel 		= 0;
	LET iTotTelsFijoVal 	= 0;
	LET iTotTelsFijoInval	= 0;
	LET iTotTelsCelVal		= 0;
	LET iTotTelsCelInval	= 0;


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/informix/moha/sp_ht_actualizar_resumen.out';
	--TRACE ON;
	
	-- HACE UN BARRIDO POR ARCHIVO
	FOREACH
		SELECT folio_archivo
		INTO cFolioArchivo
		FROM "informix".si_ht_resumen_ctrl_tels
		WHERE folio_archivo = folio_archivo
		
		-- OBTIENE EL TOTAL DE CLIENTES 
		SELECT COUNT(DISTINCT num_cte)
		INTO iTotCtes
		FROM "informix".si_ht_detalle_ctrl_tels 
		WHERE folio_archivo = cFolioArchivo;
		
		-- OBTIEN EL TOTAL DE TELS VALIDOS
		SELECT COUNT(DISTINCT TELEFONO) 
		INTO iTotTelsVal
		FROM "informix".si_ht_detalle_ctrl_tels 
		WHERE folio_archivo = cFolioArchivo
		AND valido = "S";
		
		-- OBTIEN EL TOTAL DE TELS INVALIDOS
		SELECT COUNT(DISTINCT TELEFONO) 
		INTO iTotTelsInval
		FROM "informix".si_ht_detalle_ctrl_tels 
		WHERE folio_archivo = cFolioArchivo
		AND valido = "N";

		-- OBTIENE EL TOTAL DE REGS PENDIENTES
		SELECT COUNT(DISTINCT TELEFONO)
		INTO iTotRegsPend
		FROM "informix".si_ht_detalle_ctrl_tels 
		WHERE folio_archivo = cFolioArchivo AND valido = "P";
		
		-- OBTIENE EL TOTAL DE TELEFONOS FIJOS Y CELULARES
		SELECT COUNT(DISTINCT telefono)
		INTO iTotTelsAmbos
		FROM "informix".si_ht_detalle_ctrl_tels 
		WHERE folio_archivo = cFolioArchivo
		AND tipo_tel IN (1,2);
		
		-- OBTIENE EL TOTAL DE TELEFONOS FIJOS	
		SELECT COUNT(DISTINCT telefono)
		INTO iTotTelsFijo
		FROM "informix".si_ht_detalle_ctrl_tels 
		WHERE folio_archivo = cFolioArchivo
		AND tipo_tel = 1;
		
		-- OBTIENE EL TOTAL DE TELEFONOS FIJOS VALIDOS
		SELECT COUNT(DISTINCT telefono)
		INTO iTotTelsFijoVal
		FROM "informix".si_ht_detalle_ctrl_tels 
		WHERE folio_archivo = cFolioArchivo
		AND tipo_tel = 1
		AND valido = "S";
		
		-- OBTIENE EL TOTAL DE TELEFONOS FIJOS INVALIDOS
		SELECT COUNT(DISTINCT telefono)
		INTO iTotTelsFijoInval
		FROM "informix".si_ht_detalle_ctrl_tels 
		WHERE folio_archivo = cFolioArchivo
		AND tipo_tel = 1
		AND valido = "N";

		-- OBTIENE EL TOTAL DE TELEFONOS CELULARES
		SELECT COUNT(DISTINCT telefono)
		INTO iTotTelsCel
		FROM "informix".si_ht_detalle_ctrl_tels 
		WHERE folio_archivo = cFolioArchivo
		AND tipo_tel = 2;
		
		-- OBTIENE EL TOTAL DE TELEFONOS CELULARES VALIDOS
		SELECT COUNT(DISTINCT telefono)
		INTO iTotTelsCelVal
		FROM "informix".si_ht_detalle_ctrl_tels 
		WHERE folio_archivo = cFolioArchivo
		AND tipo_tel = 2
		AND valido = "S";
		
		-- OBTIENE EL TOTAL DE TELEFONOS CELULARES INVALIDOS
		SELECT COUNT(DISTINCT telefono)
		INTO iTotTelsCelInval
		FROM "informix".si_ht_detalle_ctrl_tels 
		WHERE folio_archivo = cFolioArchivo
		AND tipo_tel = 2
		AND valido = "N";

		-- SE ACTUALIZA LA TABLA DE RESUMEN
		UPDATE "informix".si_ht_resumen_ctrl_tels
		SET tot_ctes = iTotCtes, tels_validos = iTotTelsVal, tels_invalidos = iTotTelsInval, tels_pend = iTotRegsPend, 
			tot_telsambos = iTotTelsAmbos, tot_telsfijo = iTotTelsFijo, tot_telscel = iTotTelsCel, 
			tot_telsfijoval = iTotTelsFijoVal, tot_telsfijoinval = iTotTelsFijoInval, tot_telscelval = iTotTelsCelVal, 
			tot_telscelinval = iTotTelsCelInval
		WHERE folio_archivo = cFolioArchivo;
		
	END FOREACH
	
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para actualizar los totales de los telefonos de los archivos de marcatel',
'BD: bdinteg', 
'AUTOR: Mohamed Carreón ',
'FECHA: Febrero 2015';

CREATE PROCEDURE "informix".sp_ht_resumen_ctrl_tels
(
pArchivo	CHAR(13)
)
RETURNING
	CHAR(6)		AS cod_ret,
	CHAR(14)	AS cFolioArchivo,
	SMALLINT	AS iStatus,
	INT8		AS iTotRegs,
	INT8		AS iTotCtes,
	INT8		AS iTelsEnviados,
	INT8		AS iTelsValidos,
	INT8		AS iTelsInvalidos,
	INT8		AS iTotTelsPend,
	INT8		AS iTotTelsAmbos,
	INT8		AS iTotTelsFijo,
	INT8		AS iTotTelsCel,
	INT8 		AS iTotTelsFijoVal,
	INT8		AS iTotTelsFijoInval,
	INT8		AS iTotTelsCelVal,
	INT8 		AS iTotTelsCelInval

	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cCodRet			CHAR(6);
	
	DEFINE cFolioArchivo		CHAR(13);
	DEFINE iStatus				SMALLINT;
	DEFINE iTotRegs				INT8;
	DEFINE iTotCtes				INT8;
	DEFINE iTelsEnviados		INT8;
	DEFINE iTelsValidos			INT8;
	DEFINE iTelsInvalidos		INT8;
	DEFINE iTotTelsPend			INT8;
	DEFINE iTotTelsAmbos		INT8;
	DEFINE iTotTelsFijo			INT8;
	DEFINE iTotTelsCel			INT8;
	DEFINE iTotTelsFijoVal		INT8;
	DEFINE iTotTelsFijoInval	INT8;
	DEFINE iTotTelsCelVal		INT8;
	DEFINE iTotTelsCelInval		INT8;


	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cCodRet             = "000000";
	
	LET cFolioArchivo		= "";
	LET iStatus				= 0;
	LET iTotRegs			= 0;
	LET iTotCtes			= 0;
	LET iTelsEnviados		= 0;
	LET iTelsValidos		= 0;
	LET iTelsInvalidos		= 0;
	LET iTotTelsPend		= 0;
	LET iTotTelsAmbos		= 0;
	LET iTotTelsFijo		= 0;
	LET iTotTelsCel			= 0;
	LET iTotTelsFijoVal		= 0;
	LET iTotTelsFijoInval	= 0;
	LET iTotTelsCelVal		= 0;
	LET iTotTelsCelInval	= 0;
	

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cFolioArchivo, iStatus, iTotRegs, iTotCtes, iTelsEnviados, iTelsValidos, iTelsInvalidos, iTotTelsPend,
				iTotTelsAmbos, iTotTelsFijo, iTotTelsCel, iTotTelsFijoVal, iTotTelsFijoInval, iTotTelsCelVal, iTotTelsCelInval;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/informix/moha/sp_cons_ht_resumen_ctrl_tels.out';
	--TRACE ON;
	
	IF pArchivo IS NULL THEN  --// VALIDA QUE SI ES NULO	
		LET cCodRet = "000001";	
	ELSE
		FOREACH
			--// OBTIENE LOS DATOS DEL RESUMEN
			SELECT folio_archivo,status,tot_reg,tot_ctes,tels_enviados,tels_validos,tels_invalidos,tels_pend,tot_telsambos,
				tot_telsfijo,tot_telscel,tot_telsfijoval,tot_telsfijoinval,tot_telscelval,tot_telscelinval
			INTO cFolioArchivo,iStatus,iTotRegs,iTotCtes,iTelsEnviados,iTelsValidos,iTelsInvalidos,iTotTelsPend,iTotTelsAmbos,
				iTotTelsFijo,iTotTelsCel,iTotTelsFijoVal,iTotTelsFijoInval,iTotTelsCelVal,iTotTelsCelInval
			FROM "informix".si_ht_resumen_ctrl_tels
			WHERE folio_archivo = DECODE(pArchivo,"",folio_archivo,pArchivo)
			
			RETURN cCodRet, cFolioArchivo, iStatus, iTotRegs, iTotCtes, iTelsEnviados, iTelsValidos, iTelsInvalidos, iTotTelsPend,
				iTotTelsAmbos, iTotTelsFijo, iTotTelsCel, iTotTelsFijoVal, iTotTelsFijoInval, iTotTelsCelVal, iTotTelsCelInval WITH RESUME;
		END FOREACH
		--// NO EXISTEN DATOS
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = "000002";
			RETURN cCodRet, cFolioArchivo, iStatus, iTotRegs, iTotCtes, iTelsEnviados, iTelsValidos, iTelsInvalidos, iTotTelsPend,
				iTotTelsAmbos, iTotTelsFijo, iTotTelsCel, iTotTelsFijoVal, iTotTelsFijoInval, iTotTelsCelVal, iTotTelsCelInval;
		END IF
	END IF
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para consultar el resumen de los teléfonos enviados a marcatel',
'BD: bdinteg', 
'AUTOR: Mohamed Carreón ',
'FECHA: Junio 2014';

CREATE PROCEDURE "informix".sp_ht_grabar_respuesta
(
pArchivo	CHAR(100)
)
RETURNING
	CHAR(6) 	AS cod_ret,
	CHAR(80)	AS desc_ret
---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
	DEFINE cDescRet			CHAR(80);

	DEFINE cBandera				CHAR(1);
	DEFINE iNumSerial			INT8;
	DEFINE iRespuesta			SMALLINT;
	DEFINE cTelefono			CHAR(13);
	DEFINE iNumTelsValidos		INT8;
	DEFINE iNumTelsInValidos	INT8;
	DEFINE iTotRegsPend			INT8;
	DEFINE iTotTelsFijoVal 		INT8;
	DEFINE iTotTelsFijoInval 	INT8;
	DEFINE iTotTelsCelVal 		INT8;
	DEFINE iTotTelsCelInval 	INT8;
	DEFINE iTipoTel 			SMALLINT;

	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	LET cDescRet			= "PROCESO EXITOSO";

	LET cBandera			= "0";
	LET iNumSerial			= 0;
	LET iRespuesta			= 0;
	LET cTelefono			= "";
	LET iNumTelsValidos		= 0;
	LET iNumTelsInValidos	= 0;
	LET iTotRegsPend		= 0;
	LET iTotTelsFijoVal 	= 0;
	LET iTotTelsFijoInval 	= 0;
	LET iTotTelsCelVal 		= 0;
	LET iTotTelsCelInval 	= 0;
	LET iTipoTel			= 0;


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescRet = cErrorInfo;
			RETURN cCodRet, cDescRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/informix/RESPALDOS/sp_ht_grabar_respuesta.out';
	--TRACE ON;
	
	LET pArchivo = TRIM(pArchivo);
	
	--// VALIDA QUE LOS PARAMETROS NO ESTEN VACIOS
	IF NVL(pArchivo,"") = "" THEN 
		LET cCodRet = "000001";
		LET cDescRet = "FALTAN PARAMETROS";
	ELSE
		SELECT LIMIT 1 "1"
		INTO cBandera
		FROM "informix".si_ht_resumen_ctrl_tels
		WHERE folio_archivo = pArchivo;
		
		IF NVL(cBandera,"0") <> "1" THEN
			LET cCodRet = "000002";
			LET cDescRet = "ARCHIVO NO EXISTE";
		ELSE
			FOREACH
				SELECT num_serial, respuesta
				INTO iNumSerial, iRespuesta
				FROM "informix".si_ht_regreso_marcatel
				WHERE folio_archivo = pArchivo

				SELECT telefono, tipo_tel
				INTO cTelefono, iTipoTel
				FROM "informix".si_ht_detalle_ctrl_tels
				WHERE folio_archivo = pArchivo
				AND num_serial = iNumSerial;
					
				IF iRespuesta IN (1,2,3,4) THEN
					UPDATE "informix".si_ht_detalle_ctrl_tels
					SET valido = "S"
					WHERE folio_archivo = pArchivo
					AND telefono = cTelefono;
					
					--// ACTUALIZA EN LA SI_TELEFONOS
					UPDATE "informix".si_telefonos
					SET marcatel = "V", fecha_actualiza = TODAY
					WHERE telefono = cTelefono;
					
					LET iNumTelsValidos	= iNumTelsValidos + 1;
					
					IF iTipoTel = 1 THEN
						LET iTotTelsFijoVal = iTotTelsFijoVal + 1;
					ELIF iTipoTel = 2 THEN
						LET iTotTelsCelVal = iTotTelsCelVal + 1;
					END IF

				ELIF iRespuesta IN (5,6) THEN
					UPDATE "informix".si_ht_detalle_ctrl_tels
					SET valido = "N"
					WHERE folio_archivo = pArchivo
					AND telefono = cTelefono;
					
					--// ACTUALIZA EN LA SI_TELEFONOS
					UPDATE "informix".si_telefonos
					SET marcatel = "F", fecha_actualiza = TODAY
					WHERE telefono = cTelefono;

					LET iNumTelsInValidos = iNumTelsInValidos + 1;
					
					IF iTipoTel = 1 THEN
						LET iTotTelsFijoInval = iTotTelsFijoInval + 1;
					ELIF iTipoTel = 2 THEN
						LET iTotTelsCelInval = iTotTelsCelInval + 1;
					END IF
				END IF
			
			END FOREACH
			
			-- OBTIENE EL TOTAL DE TELS PENDIENTES
			SELECT COUNT(DISTINCT TELEFONO)
			INTO iTotRegsPend
			FROM "informix".si_ht_detalle_ctrl_tels 
			WHERE folio_archivo = pArchivo AND valido = "P";
			
			UPDATE "informix".si_ht_resumen_ctrl_tels
			SET status = 2, tels_validos = iNumTelsValidos, tels_invalidos = iNumTelsInValidos, tels_pend = iTotRegsPend, 
				tot_telsfijoval = iTotTelsFijoVal,tot_telsfijoinval = iTotTelsFijoInval, tot_telscelval = iTotTelsCelVal, tot_telscelinval = iTotTelsCelInval
			WHERE folio_archivo = pArchivo;

		END IF
	END IF
		
	RETURN cCodRet, cDescRet;
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para replicar la respuesta de marcatel en el caso de que un telefono es valido o invalido',
'BD: bdinteg', 
'AUTOR: Mohamed Carreón ',
'FECHA: Junio 2014';

CREATE PROCEDURE "informix".sp_ingresos_movil(pNumSolic char(12))
RETURNING CHAR(5) as codret,
          CHAR(4) as tipo_ing,
          CHAR(4) as periodicidad,
          CHAR(10) as monto

DEFINE iSqlErr		INTEGER;
DEFINE sTipoIng         CHAR(4);
DEFINE sPeriodicidad    CHAR(4);
DEFINE sMonto           CHAR(10);


LET iSqlErr		=0;
LET sTipoIng            ='';
LET sPeriodicidad       ='';
LET sMonto              ='';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			RETURN iSqlErr, sTipoIng, sPeriodicidad, sMonto;
		END IF;
	END EXCEPTION;


        SELECT tp_ingreso, periodo_ingreso, ingreso_mensual
        INTO sTipoIng, sPeriodicidad, sMonto
        FROM bdisolic:ss_resum_scor_fin 
        WHERE num_solicitud=pNumSolic;
      --AND sec_ingreso =(SELECT MAX(sec_ingreso) FROM bdinteg:si_ingresos WHERE numcte=pNumCte);
              
	RETURN '00000', sTipoIng, sPeriodicidad, sMonto;

END
END PROCEDURE;