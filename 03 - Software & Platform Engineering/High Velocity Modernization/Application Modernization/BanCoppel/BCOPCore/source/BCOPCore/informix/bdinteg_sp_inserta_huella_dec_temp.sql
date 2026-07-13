CREATE PROCEDURE "informix".sp_inserta_huella_dec_temp(
							pNumcte 	 CHAR(20),
							pSucursal 	 CHAR(5),
							pId_template CHAR(2),
							pUser_insert CHAR(8),
							pFecha       DATE,
							cDH 		 CHAR(955),
							pImagen 	 CHAR(25),
							pRutaimg 	 CHAR(50),
							pEmpleado 	 CHAR(8),
							pUsuario3 	 CHAR(8) )

	RETURNING
	CHAR(5) AS cCodigoRet;

	DEFINE sql_err INTEGER;
	DEFINE cCodigoRet CHAR(5);
	DEFINE pFecha_insert DATETIME YEAR TO FRACTION;
	DEFINE pSecuencia SMALLINT;
	DEFINE cliente CHAR(20);
	DEFINE idTemplate CHAR(2);

	LET cCodigoRet = '00000';
	LET pFecha_insert = CURRENT;
	LET pSecuencia = '';
	LET cliente = '';
	LET idTemplate = '';

BEGIN
 
    ON EXCEPTION SET sql_err
		RETURN sql_err;
    END EXCEPTION;

	-- SET DEBUG FILE TO "/home/sysifx/Mario/trace.sql";
	-- TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--VALIDAR DATOS VACIOS
	IF NVL(pNumcte,'') = '' OR NVL(pSucursal, '') = '' OR NVL(pId_template, '') = '' OR NVL(pUser_insert, '') = '' OR NVL(pFecha,'') = '' OR NVL(cDH,'') = '' OR NVL(pRutaimg,'') = '' THEN	
		LET cCodigoRet = '00001'; --Datos vacios
		RETURN cCodigoRet;
	ELSE 	
		LET cliente = (SELECT numcte FROM "informix".si_cte_huella_dec_temp WHERE numcte = pNumcte AND id_template = pId_template);
		LET idTemplate = (SELECT id_template FROM "informix".si_cte_huella_dec_temp WHERE numcte = pNumcte AND id_template = pId_template);
		LET pSecuencia = (SELECT secuencia FROM "informix".si_cte_huella_dec_temp WHERE numcte =  pNumcte AND id_template = pId_template);
		
		IF NVL(pSecuencia, '') = ''  THEN
			LET pSecuencia = 1; 
		ELSE 
			LET pSecuencia = pSecuencia + 1;
		END IF;
	
		IF NVL(cliente, '') = '' AND NVL(idTemplate, '') = '' THEN
			INSERT INTO "informix".si_cte_huella_dec_temp (numcte,secuencia,id_template,status,template,sucursal,user_insert,fecha,fecha_insert,imagen,rutaimg,empleado,usuario3) VALUES (pNumcte,pSecuencia,pId_template,"M",cDH,pSucursal,pUser_insert,pFecha,pFecha_insert,pImagen,pRutaimg,pEmpleado,pUsuario3);
		ELSE
			DELETE FROM "informix".si_cte_huella_dec_temp WHERE numcte = pNumcte AND id_template = pId_template;
			INSERT INTO "informix".si_cte_huella_dec_temp (numcte,secuencia,id_template,status,template,sucursal,user_insert,fecha,fecha_insert,imagen,rutaimg,empleado,usuario3) VALUES (pNumcte,pSecuencia,pId_template,"M",cDH,pSucursal,pUser_insert,pFecha,pFecha_insert,pImagen,pRutaimg,pEmpleado,pUsuario3);
		END IF
	 
	END IF;
 RETURN cCodigoRet;

END;
END PROCEDURE;