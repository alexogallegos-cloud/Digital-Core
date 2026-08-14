CREATE PROCEDURE "informix".spvalidararchivos (p_dFechaRegistro DATE, p_sNombreArchivo CHAR(20), p_sUsuarioInserta CHAR(8))

	RETURNING CHAR(5) AS Retorno;

	DEFINE iSqlErr				INTEGER;
	DEFINE v_sValRetorno		CHAR(5);
	DEFINE v_dFechaRegistro 	DATE;
	DEFINE v_sNombreArchivo		CHAR(20);
	DEFINE v_sUsuarioInserta	CHAR(8);	
	DEFINE v_sEstatus			CHAR(1);
		
	-----------------------------------------------------------------------
	--SET DEBUG FILE TO "/dbexportb/Fabiola/spvalidararchivos.out"; ";
	--TRACE ON;
	-----------------------------------------------------------------------
		
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sValRetorno = iSqlErr;
				RETURN v_sValRetorno;
			END IF;
		END EXCEPTION;
		
		LET v_sValRetorno = '00003';
		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_dFechaRegistro,'')='' OR NVL(p_sNombreArchivo,'')='' OR NVL(p_sUsuarioInserta,'')='' THEN
			LET v_sValRetorno = '00001';	
			RETURN v_sValRetorno;
		END IF;
		
		SELECT estatus INTO v_sEstatus FROM bdirech:rec_archivos WHERE nombrearchivo = p_sNombreArchivo;
									
		IF v_sEstatus IS NULL THEN			
			INSERT INTO bdirech:rec_archivos (fecharegistro, nombrearchivo, usuarioinserta, estatus) 
			VALUES(p_dFechaRegistro, p_sNombreArchivo, p_sUsuarioInserta, '0');
			LET v_sValRetorno = '00000';	
		ELIF v_sEstatus = '0' OR v_sEstatus = '' THEN
			UPDATE bdirech:rec_archivos SET estatus = '0' WHERE nombrearchivo = p_sNombreArchivo;
			LET v_sValRetorno = '00000';	
		ELIF v_sEstatus = '1' THEN
			LET v_sValRetorno = '00002';
		END IF 
	
		RETURN v_sValRetorno;
	END;    	
				
END PROCEDURE 
