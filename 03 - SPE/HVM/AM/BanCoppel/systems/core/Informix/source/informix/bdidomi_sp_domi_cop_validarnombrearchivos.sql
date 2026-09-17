CREATE PROCEDURE "informix".sp_domi_cop_validarnombrearchivos(p_Sentido CHAR(1), cNumcteProveedor CHAR(20), p_NombreArchivo VARCHAR(20))
RETURNING
	CHAR(5); ---cod_ret
---	VARCHAR(115); ---descripcion

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;

	DEFINE sDescMensajeError	VARCHAR(95);
	DEFINE iNumDia				SMALLINT;
	DEFINE iNumMes				SMALLINT;
	DEFINE iNumAnio				SMALLINT;
	DEFINE sCodBanco			CHAR(3);
	DEFINE sCodRetFecha			VARCHAR(5);
	DEFINE dFechaHoy				DATE;
	DEFINE dFechaHabil				DATE;
	--DEFINE cNumcteCoppel CHAR(9);

	---INICIALIZACIONES
	LET v_cod_ret 				= "00000";
	LET sDescMensajeError		= "";
	LET iNumDia					= 0;
	LET iNumMes					= 0;
	LET iNumAnio				= 0;
	LET sCodBanco				= "";
	LET sCodRetFecha			= "00000";
	LET dFechaHoy				= MDY(1,1,1900);
	LET dFechaHabil				= MDY(1,1,1900);
	--LET cNumcteCoppel = '';

	BEGIN

		ON EXCEPTION
			SET iSqlErr, iSamErr
			IF iSqlErr <> 0 THEN
				LET v_cod_ret = iSqlErr;
			END IF;

			RETURN v_cod_ret;
		END EXCEPTION;

		--SET DEBUG FILE TO "/tmp/josea/10211/sp_domi_cop_validarnombrearchivos.out";
		--TRACE ON;
		
		-- plantilla de nombre de archivo = S01bbbAs.tffddcc
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--- OBTIENE CODIGO DE BANCOPPEL
		SELECT TRIM(valor)
		INTO sCodBanco
		FROM bdidomi: dom_parametros
		WHERE cod_param = "05";

		--- OBTIENE EL NUMERO DE DIA, MES Y AÃ?O DE LA FECHA DEL SISTEMA
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT DAY(fecha_hoy), MONTH(fecha_hoy), YEAR(fecha_hoy)
		INTO iNumDia, iNumMes, iNumAnio
		FROM bdicheq:sc_fechas;
		
		IF p_Sentido = 'E' THEN
			IF LENGTH(p_NombreArchivo) <> 20 THEN	--- VALIDA LA LONGITUD DEL NOMBRE
				EXECUTE PROCEDURE bdidomi: sp_ObtenerMensajeError("02800") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret;
			ELIF SUBSTR(p_NombreArchivo,1,1) <> 'E' THEN	--- VALIDA SENTIDO DEL ARCHIVO
				EXECUTE PROCEDURE bdidomi: sp_ObtenerMensajeError("02801") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret;
			ELIF SUBSTR(p_NombreArchivo,2,9) <> cNumcteProveedor THEN	--- VALIDA NUM CTE PROVEEDOR
				EXECUTE PROCEDURE bdidomi: sp_ObtenerMensajeError("02802") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret;
			ELIF SUBSTR(p_NombreArchivo,11,1) NOT IN ('D','B') THEN --- VALIDA CLAVE DE DOMICILIACION
				EXECUTE PROCEDURE bdidomi: sp_ObtenerMensajeError("02803") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret;
			ELIF SUBSTR(p_NombreArchivo,12,2) <> LPAD(TRIM(iNumDia::CHAR(2)),2,'0') THEN --- VALIDA DIA DEL ARCHIVO
				EXECUTE PROCEDURE bdidomi: sp_ObtenerMensajeError("02804") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret;
			ELIF SUBSTR(p_NombreArchivo,14,2) <> LPAD(TRIM(iNumMes::CHAR(2)),2,'0') THEN --- VALIDA MES DEL ARCHIVO
				EXECUTE PROCEDURE bdidomi: sp_ObtenerMensajeError("02805") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret;
			ELIF SUBSTR(p_NombreArchivo,16,2) <> SUBSTR(iNumAnio::CHAR(4),3,2) THEN --- VALIDA AÃ?O DEL ARCHIVO
				EXECUTE PROCEDURE bdidomi: sp_ObtenerMensajeError("02806") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret;
			ELIF SUBSTR(p_NombreArchivo,18,1) <> '.' THEN ---- VALIDA PUNTO DE ARCHIVO
				EXECUTE PROCEDURE bdidomi: sp_ObtenerMensajeError("02807") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret;
			--ELIF SUBSTR(p_NombreArchivo,19,2) <> '01' THEN ---- VALIDA CONSECUTIVO 
			--	EXECUTE PROCEDURE bdidomi: sp_ObtenerMensajeError("02808") INTO v_cod_ret, sDescMensajeError;
			--	RETURN v_cod_ret;
			ELSE											
				EXECUTE PROCEDURE sp_valida_cadena(SUBSTR(p_NombreArchivo,19,2),'N') INTO v_cod_ret;
				IF v_cod_ret <> "00000" THEN --- VALIDA CONSECUTIVO
						EXECUTE PROCEDURE bdidomi: sp_ObtenerMensajeError("02808") INTO v_cod_ret, sDescMensajeError;
						RETURN v_cod_ret;
				ELSE
						RETURN v_cod_ret;
				END IF;
			END IF;
		ELIF UPPER(p_Sentido) = 'S' THEN
		
			/*SELECT fecha_hoy
			INTO dFechaHoy
			FROM bdicheq: sc_fechas;
				--- SE OBTIENE LA FECHA VALIDA MAS PROXIMA
			EXECUTE FUNCTION bdinteg:splvalfecha('001',(dFechaHoy) + 1 ,0) INTO sCodRetFecha,dFechaHabil;

			IF sCodRetFecha::INTEGER = 0 THEN
				SELECT DAY(dFechaHabil), MONTH(dFechaHabil), YEAR(dFechaHabil)
				INTO iNumDia, iNumMes, iNumAnio
				FROM bdicheq: sc_fechas;
			END IF;*/
		ELSE
			/*SELECT DAY(fecha_hoy), MONTH(fecha_hoy), YEAR(fecha_hoy)
			INTO iNumDia, iNumMes, iNumAnio
			FROM bdicheq: sc_fechas;*/
		END IF;
	END
END PROCEDURE;