CREATE PROCEDURE "informix".sp_domi_generar_comprimido_ob()
RETURNING VARCHAR(5) AS cCodRet, VARCHAR(100) AS cMensaje, VARCHAR(100) AS cArchivo;

DEFINE vsSQL 			CHAR(1000);
DEFINE cCodRet			VARCHAR(5);
DEFINE viSqlErr			INTEGER;
DEFINE cNombreArchResp	CHAR(20);
DEFINE cRutaarchivoResp CHAR(100);
DEFINE cRutaNombreArch 	CHAR(1000);
DEFINE cMensaje			VARCHAR(100);

LET vsSQL 				= '';
LET cCodRet 			= '';
LET viSqlErr			= '';
LET cNombreArchResp	 	= '';
LET cRutaarchivoResp 	= '';
LET cRutaNombreArch		= '';
LET cMensaje			= '';


--SET DEBUG FILE TO "/tmp/ingrid/sp_domi_generar_comprimido_ob.out";
--TRACE ON;


BEGIN

		ON EXCEPTION SET viSqlErr   
				IF viSqlErr <> 0 THEN
				RETURN viSqlErr, 'ERROR AL COMPRIMIR EL ARCHIVO', '';
				END IF;
		END EXCEPTION;

		
		--SE OBTIENE RUTA DONDE SE DEPOSITA ARCHIVO DE RESPUESTA
		SELECT valor 
		INTO cRutaarchivoResp
		FROM dom_parametros
		WHERE cod_param = '02';
		
		
		--SE OBTIENE NOMBRE DE ARCHIVOS DE RESPUESTA GENERADOS 
		FOREACH WITH HOLD
		
			SELECT DISTINCT nombre_arch
			INTO cNombreArchResp
			FROM dom_cte_archivos 
			WHERE LEFT( nombre_arch, 1 ) = 'S'
			AND SUBSTR( nombre_arch, 11, 1 ) = 'D'
			AND fecha_insert = TODAY
			
			LET cRutaNombreArch = TRIM(cRutaNombreArch) || ' ' || TRIM(cRutaarchivoResp)|| TRIM(cNombreArchResp);
			
		END FOREACH;
	
		IF cRutaNombreArch <> '' THEN
			
			LET vsSQL = 'zip '||TRIM(cRutaarchivoResp)||'RespuestaDomiciliacionD' || TO_CHAR( TODAY , '%Y%m%d' ) || '.zip '||'-P bancoppel ' ||cRutaNombreArch;
			SYSTEM vsSQL;
			
			LET cCodRet = '01424';
			LET cMensaje = 'ARCHIVO COMPRIMIDO';
			RETURN cCodRet, cMensaje, TRIM(cRutaarchivoResp)||'RespuestaDomiciliacionD' || TO_CHAR( TODAY , '%Y%m%d' ) || '.zip';
		
		ELSE 
		
			LET cCodRet = '01427';
			LET cMensaje = 'NO HAY ARCHIVO PARA COMPRIMIR';
			RETURN cCodRet, cMensaje, '';
			
		END IF;
		
END;
END PROCEDURE;