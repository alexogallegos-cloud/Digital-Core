CREATE PROCEDURE "informix".sp_consultarcausastatussoc(p_Status CHAR(2))
RETURNING
	CHAR(5) AS COD_RET,
	CHAR(2) AS STATUS,
	VARCHAR(40) AS DESC_STA,
	CHAR(3) AS CAUSA,
	VARCHAR(100) AS DESC_CAUSA,
	VARCHAR(100) AS JUSTIFICACION; 
	
	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
	DEFINE sStatus				CHAR(2);
	DEFINE sDescStatus			VARCHAR(40);
	DEFINE sCausa				CHAR(3);
	DEFINE sDescCausa			VARCHAR(100);
	DEFINE sJustificacion 		VARCHAR(100);
	
	
	---INICIALIZACIONES
	LET v_cod_ret 			= '00000';
	LET iSqlErr				= 0;
	LET iSamErr				= 0;
	LET sStatus				= "";
	LET sCausa				= "";
	LET sDescStatus			= "";
	LET sDescCausa			= "";
	LET sJustificacion 		= "";

BEGIN

	ON EXCEPTION
		SET iSqlErr, iSamErr
		IF iSqlErr <> 0 THEN
			LET v_cod_ret = iSqlErr;
		END IF;
		
		RETURN v_cod_ret, "", "", "", "", "";
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	 --SET DEBUG FILE TO "/tmp/sp_consultarcausastatus.out";
	 --TRACE ON;
	
	IF p_Status = "" THEN
	
		FOREACH
			SELECT status_solicitud, descripcion, "", ""
			INTO sStatus, sDescStatus, sCausa, sDescCausa 
			FROM bdisolic:"informix".ss_status_sol 
			WHERE activa_reporte = "1"
			AND status_solicitud NOT IN('PC','AN')
			ORDER BY status_solicitud

			RETURN v_cod_ret, sStatus, sDescStatus, sCausa, sDescCausa, sJustificacion WITH RESUME;
		END FOREACH
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET v_cod_ret = '00001'; -- NO SE ENCUENTRAN REGISTROS.
		END IF
		
	ELIF p_Status = "IN" THEN
	
		FOREACH
			SELECT status_solicitud, descripcion, "", ""
			INTO sStatus, sDescStatus, sCausa, sDescCausa 
			FROM bdisolic:"informix".ss_status_sol 
			WHERE activa_reporte = "1"
			  AND status_solicitud IN('AT','RT','CN','EE','CE','OA','BC','CC','OS')
			ORDER BY status_solicitud

			RETURN v_cod_ret, sStatus, sDescStatus, sCausa, sDescCausa, sJustificacion WITH RESUME;
		END FOREACH
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET v_cod_ret = '00001'; -- NO SE ENCUENTRAN REGISTROS.
		END IF
		
	ELIF p_Status = "FN" THEN
	
		FOREACH
			SELECT status_solicitud, descripcion, "", ""
			INTO sStatus, sDescStatus, sCausa, sDescCausa 
			FROM bdisolic:"informix".ss_status_sol 
			WHERE activa_reporte = "1"
			  AND status_solicitud IN('AT','RT','CM','EE')
			ORDER BY status_solicitud

			RETURN v_cod_ret, sStatus, sDescStatus, sCausa, sDescCausa, sJustificacion WITH RESUME;
		END FOREACH
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET v_cod_ret = '00001'; -- NO SE ENCUENTRAN REGISTROS.
		END IF
		
	ELIF p_Status = "#" THEN

		FOREACH
			SELECT t2.status_solicitud, t2.causa_solicitud, t2.causa_solicitud ||' ' || t2.descripcion
			INTO sStatus, sCausa, sDescCausa
			FROM bdisolic:"informix".ss_causas_sol t2
			WHERE activa_reporte = "1"
			
			RETURN v_cod_ret, sStatus, sDescStatus, sCausa, sDescCausa, sJustificacion WITH RESUME;
		END FOREACH
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET v_cod_ret = '00001'; -- NO SE ENCUENTRAN REGISTROS.
		END IF
		
	ELIF p_Status = "RT" THEN -- REPORTE POR TIPO DE RECHAZO.
	
		FOREACH 
			SELECT status_solicitud, "", causa_solicitud, descripcion
			INTO sStatus, sDescStatus, sCausa, sDescCausa
			FROM bdisolic:"informix".ss_causas_sol
			WHERE status_solicitud = p_Status
			AND causa_solicitud  in( 'RCE','RCZ','RBE','RSE')
			AND activa_reporte = "1"
			AND tipo_auto = "2"
			
			RETURN v_cod_ret, sStatus, sDescStatus, sCausa, sDescCausa, sJustificacion WITH RESUME;
		END FOREACH
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET v_cod_ret = '00001'; -- NO SE ENCUENTRAN REGISTROS.
		END IF
		
	ELSE -- REPORTE POR ESTATUS SOLICITADO.
		FOREACH 
		SELECT a.status_solicitud, "", a.causa_solicitud, a.descripcion, nvl(b.justificacion,'')
		INTO sStatus, sDescStatus, sCausa, sDescCausa,sJustificacion 
		FROM bdisolic:"informix".ss_causas_sol a
		LEFT JOIN bdisolic:"informix".ss_causas_justificaciones b on ( a.status_solicitud = b.status_solicitud AND a.causa_solicitud = b.causa_solicitud)
		WHERE a.status_solicitud = p_Status
		AND a.causa_solicitud IN('CME','CMC','CEV')
		AND a.activa_reporte = "1"
		AND a.tipo_auto = "2"
			
			
			/*SELECT justificacion
			INTO  sJustificacion 
			FROM bdisolic:"informix".ss_causas_justificaciones
			WHERE status_solicitud = TRIM(p_Status)
			AND causa_solicitud = sCausa;*/
			
			
			RETURN v_cod_ret, sStatus, sDescStatus, sCausa, sDescCausa, sJustificacion WITH RESUME;
		END FOREACH
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET v_cod_ret = '00001'; -- NO SE ENCUENTRAN REGISTROS.
		END IF
	END IF
	
	IF v_cod_ret <> "00000" THEN
		RETURN v_cod_ret, "", "", "", "", "";
	END IF
END;

END PROCEDURE
DOCUMENT
'Descripcion: Se crea procedimiento para consultar los estatus y causas asociadas',
'Fecha: 07/ Junio/ 2010',
'BD: bdicred',
'Autor: Mohamed Hassan',
'Descripcion: Se le agrego que al momento de generar el reporte por TIPO DE RECHAZO no muestre las causas RMC y RSC ,',
'tambien que al momento de consultar por estatus muestra los diferente estatus separados. INICIAL Y FINAL',
'Fecha: 03/Diciembre/2012',
'BD: bdicred',
'Modifico: Valentin Lopez',
"AUTOR: Johnattan Esquivel SÃ?Â¡nchez",
"FECHA: 01/08/2018",
"DESCRIPCION: Se aplica mantto MC";

CREATE PROCEDURE "informix".sp_eliminatemp ()	
	RETURNING CHAR(5) AS CodRet;
                			
	-- Declaracion de variables
	DEFINE iSqlErr          			INTEGER;
	DEFINE cCodRet           			CHAR(5);

	-- Asignacion variables
	LET iSqlErr             		= 0;
	LET cCodRet              		= '00000';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/informix/Stored_Procedures/SP/sp_eliminatemp.out"; 
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		DELETE FROM "informix".tmp_sd_definicion;
		DELETE FROM "informix".tmp_sd_frectipopago;
		DELETE FROM "informix".tmp_tasas_diferenciadas;
		DELETE FROM "informix".tmp_convivenciaProductos;
		DELETE FROM "informix".tmp_documentos_digitalizar;
		DELETE FROM "informix".tmp_doctos_imprimir;
		DELETE FROM "informix".tmp_operaciones_canal;
		DELETE FROM "informix".tmp_activacionmsj;
		DELETE FROM "informix".tmp_politicacreditoprod;
		DELETE FROM "informix".tmp_tipofacturacion;
		DELETE FROM "informix".tmp_ctasmedioacceso;
		DELETE FROM "informix".tmp_caracteristicas_complementarias;
		 
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT
'Se crea el procedimiento almacenado "sp_eliminatemp" Para el Eliminado de Tablas temporales de taller de productos en sistema "SOC"',
'Base de datos: BDICRED';

CREATE PROCEDURE "informix".sp_consulta_frecpago()

RETURNING CHAR(5) AS CodRet,
          CHAR(2) AS Valor,
		  VARCHAR(20) AS TipoPago;
    
DEFINE cCodRet CHAR(5);
DEFINE cValor CHAR(2);
DEFINE cTipoPago VARCHAR(20);
DEFINE iSqlErr  INTEGER;

LET cCodRet = '00000';
LET cValor = '';
LET cTipoPago = '';
LET iSqlErr = 0;
    
	BEGIN
		-- // MANEJO DE EXCEPCIONES   
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cValor,cTipoPago;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/ifxsif01/home/e_efierro/sp_consulta_frecpago.out";
		--TRACE ON;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT valor,tipo_pago
			INTO cValor,cTipoPago
			FROM "informix".sd_cattipopago
		
			RETURN cCodRet, cValor,cTipoPago WITH RESUME;
		END FOREACH;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= '00001';  --No hay informacion
			RETURN cCodRet, TRIM(cValor), TRIM(cTipoPago);
		END IF;
	END
END PROCEDURE           ;