CREATE PROCEDURE "informix".sp_insertalog(piId INT, pcDescrip CHAR(100), pcNombreArchivo CHAR(50), pcUser CHAR(10), pcTipo CHAR(1), pcDescripError CHAR(100))
	RETURNING CHAR(5) AS Retorno, CHAR(100) as DescError;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  inserta registro en la tabla log ---------------------------------------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 04/10/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/
	
	DEFINE viCodigo			INT;
	DEFINE vcCodRet			CHAR(5);	
	DEFINE vcDescRet		CHAR(100);
	DEFINE dtFechaInsercion DATETIME YEAR TO FRACTION;
			
	LET viCodigo			= 0;
	LET vcCodRet			= '00000';	
	LET vcDescRet			= '';	
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;		
		RETURN NVL(vcCodRet,''),NVL(vcDescRet,'');
	END EXCEPTION;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF ( NVL(piId,0) = 0 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, ID OPERACIÓN INVÁLIDO (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( NOT EXISTS(SELECT id_operacion FROM "informix".rp_cat_operaciones WHERE id_operacion = NVL(piId,0)) ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, ID OPERACIÓN NO EXISTE (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( NVL(pcDescrip,'') = '' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, DESCRIPCIÓN INVÁLIDA (PARÁMETRO 2)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( NVL(pcUser,'') = '' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, USUARIO INVÁLIDO (PARÁMETRO 4)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( NVL(pcTipo,'') <> '1' AND NVL(pcTipo,'') <> '2' AND NVL(pcTipo,'') <> '3' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, TIPO LOG INVÁLIDO (PARÁMETRO 5)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	SELECT DBINFO('utc_to_datetime',sh_curtime) 
	INTO dtFechaInsercion 
	FROM sysmaster:"informix".sysshmvals;
	
	IF ( NVL(pcTipo,0) = '1') THEN
		INSERT INTO "informix".rp_log(id_operacion, descripcion, user_insert, fecha_insert)
		VALUES (piId, pcDescrip, pcUser, dtFechaInsercion);
	ELIF ( NVL(pcTipo,0) = '2') THEN
		INSERT INTO "informix".rp_procesos(id_operacion, descripcion, nombre_archivo, user_insert, fecha_insert)
		VALUES (piId, pcDescrip, NVL(pcNombreArchivo,''), pcUser, dtFechaInsercion);
	ELIF ( NVL(pcTipo,0) = '3') THEN
		INSERT INTO "informix".rp_errores(id_operacion, desc_proceso, desc_error, user_insert, fecha_insert)
		VALUES (piId, pcDescrip, NVL(pcDescripError,''), pcUser, dtFechaInsercion);
	END IF;
	RETURN vcCodRet, vcDescRet;
	END;
END PROCEDURE
