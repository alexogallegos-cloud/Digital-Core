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