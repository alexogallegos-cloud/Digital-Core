CREATE PROCEDURE "informix".sp_domi_validarnombrearchivos(p_CodOper SMALLINT, p_Sentido CHAR(1), p_NombreArchivo VARCHAR(20))
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

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;

        RETURN v_cod_ret;
    END EXCEPTION;

	---SET DEBUG FILE TO "/tmp/has/sp_Domi_ValidarNombreArchivos.out";
	---TRACE ON;
	--- plantilla de nombre de archivo = S01bbbAs.tffddcc

	--- VALIDA QUE SEA UN CODIGO DE OPERACION LEGAL
	IF p_CodOper NOT IN (SELECT cod_operacion FROM bdidomi: dom_codigo_oper) THEN
		EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00209") INTO v_cod_ret, sDescMensajeError;
		RETURN v_cod_ret;
	ELSE
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--- OBTIENE CODIGO DE BANCOPPEL
		SELECT TRIM(valor)
		INTO sCodBanco
		FROM bdidomi: dom_parametros
		WHERE cod_param = "05";

		--- OBTIENE EL NUMERO DE DIA, MES Y AÑO DE LA FECHA DEL SISTEMA
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		--- SE VALIDA LA FECHA T +1 SOLAMENTE EN EL CASO DEL ARCHIVO CODIGO 34 DE SENTIDO 'E'
		IF p_CodOper = "34" AND p_Sentido = "E" THEN
			SELECT fecha_hoy
			INTO dFechaHoy
			FROM bdicheq: sc_fechas;
			--- SE OBTIENE LA FECHA VALIDA MAS PROXIMA
			EXECUTE FUNCTION bdinteg:splvalfecha('001',(dFechaHoy) + 1 ,0) INTO sCodRetFecha,dFechaHabil;

			IF sCodRetFecha::INTEGER = 0 THEN
				SELECT DAY(dFechaHabil), MONTH(dFechaHabil), YEAR(dFechaHabil)
				INTO iNumDia, iNumMes, iNumAnio
				FROM bdicheq: sc_fechas;
			END IF
		ELSE
			SELECT DAY(fecha_hoy), MONTH(fecha_hoy), YEAR(fecha_hoy)
			INTO iNumDia, iNumMes, iNumAnio
			FROM bdicheq: sc_fechas;
		END IF

		--- VALIDA LOS ARCHIVONS DE SALIDA DE CECOBAN
		IF UPPER(p_Sentido) = "S" THEN
			IF LENGTH(p_NombreArchivo) <> 16 THEN	--- VALIDA LA LONGITUD DEL NOMBRE
				EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00201") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret;
			ELSE
				IF SUBSTR(p_NombreArchivo,1,1) <> "S" THEN	--- VALIDA SENTIDO DEL ARCHIVO
					EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00202") INTO v_cod_ret, sDescMensajeError;
					RETURN v_cod_ret;
				ELSE
					IF SUBSTR(p_NombreArchivo,2,2) <> "01" THEN	--- VALIDA PLAZA DE CCEN
						EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00203") INTO v_cod_ret, sDescMensajeError;
						RETURN v_cod_ret;
					ELSE
						IF SUBSTR(p_NombreArchivo,4,3) <> sCodBanco THEN --- VALIDA CLAVE DE BANCOPPEL
							EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00204") INTO v_cod_ret, sDescMensajeError;
							RETURN v_cod_ret;
						ELSE
							IF SUBSTR(p_NombreArchivo,7,1) <> "A" THEN --- VALIDA BUZON
								EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00205") INTO v_cod_ret, sDescMensajeError;
								RETURN v_cod_ret;
							ELSE
								IF SUBSTR(p_NombreArchivo,8,1) <> "2" THEN --- VALIDA SERVICIO DE DOMICILIACION
									EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00206") INTO v_cod_ret, sDescMensajeError;
									RETURN v_cod_ret;
								ELSE
									IF SUBSTR(p_NombreArchivo,9,1) <> "." THEN --- VALIDA CARACTER PUNTO
										EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00207") INTO v_cod_ret, sDescMensajeError;
										RETURN v_cod_ret;
									ELSE
										IF SUBSTR(p_NombreArchivo,10,1) <> "A" THEN ---- VALIDA TIPO DE ARCHIVO
											EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00208") INTO v_cod_ret, sDescMensajeError;
											RETURN v_cod_ret;
										ELSE
											IF SUBSTR(p_NombreArchivo,11,2) <> p_CodOper THEN --- VALIDA CODIGO DE OPERACION
												EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00209") INTO v_cod_ret, sDescMensajeError;
												RETURN v_cod_ret;
											ELSE
												IF SUBSTR(p_NombreArchivo,13,2)::SMALLINT <> iNumDia THEN --- VALIDA DIA DEL PROCESO
													EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00210") INTO v_cod_ret, sDescMensajeError;
													RETURN v_cod_ret;
												ELSE
													EXECUTE PROCEDURE sp_valida_cadena(SUBSTR(p_NombreArchivo,15,2),"N") INTO v_cod_ret;
													IF v_cod_ret <> "00000" THEN --- VALIDA CONSECUTIVO
														EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00213") INTO v_cod_ret, sDescMensajeError;
														RETURN v_cod_ret;
													ELSE
														RETURN v_cod_ret;
													END IF
												END IF
											END IF
										END IF
									END IF
								END IF
							END IF
						END IF
					END IF
				END IF
			END IF
		ELSE
			--- VALIDA LOS ARCHIVOS DE ENTRADA DE CECOBAN
			IF LENGTH(p_NombreArchivo) <> 17 THEN	--- VALIDA LA LONGITUD DEL NOMBRE
				EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00201") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret;
			ELSE
				IF SUBSTR(p_NombreArchivo,1,1) <> "E" THEN	--- VALIDA SENTIDO DEL ARCHIVO
					EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00202") INTO v_cod_ret, sDescMensajeError;
					RETURN v_cod_ret;
				ELSE
					IF SUBSTR(p_NombreArchivo,2,3) <> sCodBanco THEN --- VALIDA CLAVE DE BANCOPPEL
						EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00204") INTO v_cod_ret, sDescMensajeError;
						RETURN v_cod_ret;
					ELSE
						IF SUBSTR(p_NombreArchivo,5,2)::SMALLINT <> iNumDia THEN --- VALIDA DIA DEL PROCESO
							EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00210") INTO v_cod_ret, sDescMensajeError;
							RETURN v_cod_ret;
						ELSE
							IF SUBSTR(p_NombreArchivo,7,2)::SMALLINT <> iNumMes THEN --- VALIDA MES DEL PROCESO
								EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00211") INTO v_cod_ret, sDescMensajeError;
								RETURN v_cod_ret;
							ELSE
								IF SUBSTR(p_NombreArchivo,9,4)::SMALLINT <> iNumAnio THEN --- VALIDA AÑO DEL PROCESO
									EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00212") INTO v_cod_ret, sDescMensajeError;
									RETURN v_cod_ret;
								ELSE
									IF SUBSTR(p_NombreArchivo,13,1) <> "." THEN --- VALIDA CARACTER PUNTO
										EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00207") INTO v_cod_ret, sDescMensajeError;
									RETURN v_cod_ret;
									ELSE
										IF SUBSTR(p_NombreArchivo,14,2) <> p_CodOper THEN --- VALIDA CODIGO DE OPERACION
											EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00209") INTO v_cod_ret, sDescMensajeError;
											RETURN v_cod_ret;
										ELSE
											EXECUTE PROCEDURE sp_valida_cadena(SUBSTR(p_NombreArchivo,16,2),"N") INTO v_cod_ret;
											IF v_cod_ret <> "00000" THEN --- VALIDA CONSECUTIVO
												EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00213") INTO v_cod_ret, sDescMensajeError;
												RETURN v_cod_ret;
											ELSE
												RETURN v_cod_ret;
											END IF
										END IF
									END IF
								END IF
							END IF
						END IF
					END IF
				END IF
			END IF
		END IF
	END IF
END;
--##############################################################################
--## Procedimiento   : sp_Domi_ValidarNombreArchivos
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Fecha creacion  : Julio de 2009
--##Descripcion :  Procedimiento para validar la estructura del nombre de los archivos a recibir por parte de cecoban, archivos codigo 10 y codigo 30
--##############################################################################
END PROCEDURE;