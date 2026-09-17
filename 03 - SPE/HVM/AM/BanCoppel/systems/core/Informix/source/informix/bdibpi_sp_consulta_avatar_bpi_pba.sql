CREATE PROCEDURE "informix".sp_consulta_avatar_bpi_pba(pEmpresa CHAR(3),pUsuario CHAR(50))
RETURNING   CHAR(5),--Codigo de retorno
			CHAR(10),--Nombre magen del avatar
			CHAR(50), -- Frase
			INTEGER, -- Numero de intentos al loguearse
			DATETIME YEAR TO SECOND , -- Fecha de primer intento fallido
			CHAR(1), -- Bloqueo temporal
			CHAR(50); -- Mosaico de avatares ficticios

--****************************************************************************************************
-- Bibiana Gaxiola Verdugo.
-- 10/01/2013
-- Se utiliza para el nuevo login del portal BPI donde se implementa la autenticación con avatar.
--***************************************************************************************************
--FECHA: 30/01/2013
--SOLICITO: ISMAEL HERNANDEZ
--MODIFICO: MANUEL OSUNA V.
--OBJETIVO: DESBLOQUEAR CLIENTES TEMPORALES MAYOR DE 24 HRS DE SU BLOQUEO.
--***************************************************************************************************
--FECHA: 21/03/2013
--MODIFICO: ISMAEL HERNANDEZ
--OBJETIVO: Modificar el nombre de imagen del avatar para que conviva la versión productiva con la reingeniería.
--***************************************************************************************************

--Declaración de variables
DEFINE vCodRet CHAR(5);
DEFINE sql_err INTEGER;
DEFINE vNumCliente CHAR(9);
DEFINE vNomImagen CHAR(10);
DEFINE vFrase CHAR(50);
DEFINE vNumIntentos INTEGER;
DEFINE vFechaPrimerInt DATETIME YEAR TO SECOND;
DEFINE vBloqueoTemporal CHAR(1);
DEFINE vMosaicoImg CHAR(50);

--Inicializar variables
LET vNumCliente='';
LET vNomImagen='';
LET vFrase='';
LET vCodRet='00000';
LET vNumIntentos = 0;
LET vFechaPrimerInt = '';
LET vBloqueoTemporal = '';
LET vMosaicoImg = '';

	--set debug file to "/home/informix/ivonne/sp_consulta_avatar_bpi.out";
	--trace on;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET vCodRet = sql_err;
			RETURN vCodRet, '', '','','','','';
		END IF ;
	END EXCEPTION ;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


	IF(pEmpresa <> '' OR pEmpresa IS NOT NULL OR pUsuario<>'' OR pUsuario IS NOT NULL) THEN

		SELECT numcte INTO vNumCliente FROM bdinteg:"informix".si_bpiusuarios WHERE usuario=TRIM(pUsuario);

		IF (vNumCliente <> '' OR vNumCliente IS NOT NULL) THEN
            SELECT CASE WHEN LENGTH(TRIM(imagen)) = 7 THEN "a00" || substring(imagen FROM 7 FOR 1) ELSE imagen END, 
                   frase, num_intentos_bloqtemp, fecha_bloqtemp, bloqueo_temporal, mosaico_img
			--SELECT  imagen, frase, num_intentos_bloqtemp, fecha_bloqtemp, bloqueo_temporal, mosaico_img
			INTO vNomImagen, vFrase, vNumIntentos, vFechaPrimerInt, vBloqueoTemporal, vMosaicoImg
			FROM  bdibpi:"informix".bpi_avatar WHERE num_cte=vNumCliente;

			IF(vNomImagen = '' OR vNomImagen IS NULL OR vFrase ='' OR vFrase IS NULL) THEN
				LET vCodRet='00003';
			END IF;

			IF (vBloqueoTemporal = 'T') THEN
				LET vCodRet = '00004'; --Si hay bloqueo temporal
			    IF ((vFechaPrimerInt +  INTERVAL(1) DAY TO DAY) <=  CURRENT ) THEN --si tiene mas de 24hrs

					LET vBloqueoTemporal = 'F';
					LET vNumIntentos = 0;
					LET vFechaPrimerInt = '';
					LET vMosaicoImg = '';

					UPDATE bdibpi:"informix".bpi_avatar SET bloqueo_temporal = vBloqueoTemporal, num_intentos_bloqtemp = vNumIntentos,
					fecha_bloqtemp = vFechaPrimerInt, mosaico_img = vMosaicoImg WHERE num_cte=vNumCliente;

					LET vCodRet = '00000';
				END IF;

			END IF;
		ELSE
			LET vCodRet='00002';
		END IF;
	ELSE
		LET vCodRet='00001';
	END IF;

	RETURN vCodRet,vNomImagen,vFrase,vNumIntentos,vFechaPrimerInt,vBloqueoTemporal,vMosaicoImg;

END
END PROCEDURE;