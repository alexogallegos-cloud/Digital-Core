CREATE PROCEDURE "informix".sp_obteneremailalternativousuario(pNumCliente VARCHAR(9))
RETURNING CHAR (5), CHAR(100);
	-- Creador: Javier CalderÃ³n
	-- Objetivo: Obtiene el correo electronico del usuario
	
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vEmail VARCHAR(100);
	
	--SET DEBUG FILE TO '/tmp/sp_grabaremail.out';
    --TRACE ON;
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vEmail;
		  END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT 5;
		
		LET vCod_ret = '00000';
		LET vEmail = '';
		
		SELECT e_mail INTO vEmail FROM "informix".bpi_usuario WHERE numcliente = pNumCliente AND st_portal='activo';

		RETURN vCod_ret, NVL(vEmail,'');
	END;
END PROCEDURE
DOCUMENT
'AUTOR.........: Edgar Alarcon Gonzalez',
'FECHA.........: 12-09-2016',
'MODIFICACIÃN..: Se amplia parametro de correo a 100 caracteres.',
'MODIFICACIÃN..: se clona SP para obtener Correo Electronico Alternativo.',
'FECHA MODIFICACION.........: 03-03-2017',
'SOLICITA......: Alejandro Vazquez',
'BD............: BDIBPI';

CREATE PROCEDURE "informix".sps_consulta_avatar_bpi_nueva_imagen(pEmpresa CHAR(3),pIdUsuario CHAR(11))
RETURNING   CHAR(5),--Codigo de retorno
			CHAR(10),--Nombre magen del avatar
			CHAR(50), -- Frase
			INTEGER, -- Numero de intentos al loguearse
			DATETIME YEAR TO SECOND , -- Fecha de primer intento fallido
			CHAR(1), -- Bloqueo temporal
			CHAR(50), -- Mosaico de avatares ficticios
			CHAR(1); -- Bandera que indica si ya se asignó avatar para nueva imagen
			
			--Declaración de variables
DEFINE cCodRet CHAR(5);
DEFINE iSql_err INTEGER;
DEFINE cNumCliente CHAR(9);
DEFINE cNomImagen CHAR(10);
DEFINE cFrase CHAR(50);
DEFINE iNumIntentos INTEGER;
DEFINE dFechaPrimerInt DATETIME YEAR TO SECOND;
DEFINE cBloqueoTemporal CHAR(1);
DEFINE cMosaicoImg CHAR(50);
DEFINE cAsig_avat_nuev_img CHAR(1);

	--Descripción: Consultar Avatar
	--16/03/2017

--Inicializar variables
LET cNumCliente='';
LET cNomImagen='';
LET cFrase='';
LET cCodRet='00000';
LET iNumIntentos = 0;
LET dFechaPrimerInt = '';
LET cBloqueoTemporal = '';
LET cMosaicoImg = '';
LET cAsig_avat_nuev_img = '';

	--set debug file to "/home/informix/ivonne/sp_consulta_avatar_bpi.out";
	--trace on;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, '', '','','','','', '';
		END IF ;
	END EXCEPTION ;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


	IF(pEmpresa <> '' OR pEmpresa IS NOT NULL OR pIdUsuario<>'' OR pIdUsuario IS NOT NULL) THEN

		SELECT NUMCLIENTE INTO cNumCliente FROM bdibpi:"informix".bpi_usuario WHERE ID_USUARIO = TRIM(pIdUsuario);
		
		IF (cNumCliente <> '' OR cNumCliente IS NOT NULL) THEN
            SELECT CASE WHEN LENGTH(TRIM(imagen)) = 7 THEN "a00" || substring(imagen FROM 7 FOR 1) ELSE imagen END, 
                   frase, num_intentos_bloqtemp, fecha_bloqtemp, bloqueo_temporal, mosaico_img, asig_avat_nuev_img
			INTO cNomImagen, cFrase, iNumIntentos, dFechaPrimerInt, cBloqueoTemporal, cMosaicoImg, cAsig_avat_nuev_img
			FROM  bdibpi:"informix".bpi_avatar WHERE num_cte=cNumCliente;
						
			IF(cNomImagen = '' OR cNomImagen IS NULL OR cFrase ='' OR cFrase IS NULL) THEN
				LET cCodRet='00003';
			END IF;

			IF (cBloqueoTemporal = 'T') THEN
				LET cCodRet = '00004'; --Si hay bloqueo temporal
			    IF ((dFechaPrimerInt +  INTERVAL(1) DAY TO DAY) <=  CURRENT ) THEN --si tiene mas de 24hrs

					LET cBloqueoTemporal = 'F';
					LET iNumIntentos = 0;
					LET dFechaPrimerInt = '';
					LET cMosaicoImg = '';

					UPDATE bdibpi:"informix".bpi_avatar SET bloqueo_temporal = cBloqueoTemporal, num_intentos_bloqtemp = iNumIntentos,
					fecha_bloqtemp = dFechaPrimerInt, mosaico_img = cMosaicoImg WHERE num_cte=cNumCliente;

					LET cCodRet = '00000';
				END IF;

			END IF;
		ELSE
			LET cCodRet='00002';
		END IF;
	ELSE
		LET cCodRet='00001';
	END IF;
	
	RETURN cCodRet,cNomImagen,cFrase,iNumIntentos,dFechaPrimerInt,cBloqueoTemporal,cMosaicoImg, cAsig_avat_nuev_img;

END
END PROCEDURE;