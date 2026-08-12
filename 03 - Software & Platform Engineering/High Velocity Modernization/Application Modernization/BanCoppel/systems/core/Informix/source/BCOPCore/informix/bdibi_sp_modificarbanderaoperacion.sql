CREATE PROCEDURE "informix".sp_modificarbanderaoperacion(pTipoOper INT, pEstado BOOLEAN)
RETURNING CHAR (5);
	-- Creador: Javier Calderón
	-- Objetivo: Modifica el estado de la bandera de una operacion
	-- Solicitó: Diana Castellanos
	-- Fecha: 19/11/2010
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);

	--SET DEBUG FILE TO "/home/informix/bibiana/sp_modificarbanderaoperacion.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;
        --SET ISOLATION TO COMMITTED READ LAST COMMITTED;

		LET vCod_ret = '00000';
		IF (pTipoOper = 1) THEN
			UPDATE bdibpi:"informix".bpi_parametros_contenido SET flag_batch_cheques = pEstado;
		ELIF (pTipoOper = 2) THEN
			UPDATE bdibpi:"informix".bpi_parametros_contenido SET flag_batch_credito = pEstado;
		ELIF (pTipoOper = 3) THEN
			UPDATE bdibpi:"informix".bpi_parametros_contenido SET flag_batch_SPEI = pEstado;
		ELIF (pTipoOper = 4) THEN
			UPDATE bdibpi:"informix".bpi_parametros_contenido SET flag_batch_servicios = pEstado;
		END IF;

		RETURN vCod_ret;
	END;
END PROCEDURE
DOCUMENT
'Folio: 1440',
'Autor: 95586776',
'Fecha: 06/05/2014',
'Modificación: Se agrega la actualización de la bandera de servicios.',
'Sustento: Independencia de Sistemas',
'Solicita: Alejandro Vazquez',
'BD: Bdibpi';

CREATE PROCEDURE "informix".sps_consulta_avatar_bm(pEmpresa CHAR(3),pUsuario CHAR(10))
RETURNING   CHAR(5),--Codigo de retorno
			CHAR(10),--Nombre magen del avatar
			CHAR(50);
			
--****************************************************************************************************
-- DESCRIPCION:  OBTIENE LOS DATOS PARA MOSTRAR FRASE DE SEGURIDAD COMO EN BANCAMOVIL.
-- AUTOR : Francisco Rodríguez Ibarra
-- FECHA : 06/01/2012
-- BD: bdibpi
-- SOLICITO :Mauricio León
--***************************************************************************************************
-- SP utilizado en APP's y Tablet
		
--Declaración de variables
DEFINE vCodRet CHAR(5);
DEFINE sql_err INTEGER;
DEFINE vNumCliente CHAR(9);
DEFINE vNomImagen CHAR(10);
DEFINE vFrase CHAR(50);

--Inicializar variables
LET vNumCliente='';
LET vNomImagen='';
LET vFrase='';
LET vCodRet='00000';

	--set debug file to "/tmp/sp_consulta_avatar_bm.out";
	--trace on;
	
BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET vCodRet = sql_err;
			RETURN vCodRet, '', '';
		END IF ;
	END EXCEPTION ;


SET ISOLATION TO DIRTY READ;
	
	IF(pEmpresa <> '' OR pEmpresa IS NOT NULL OR pUsuario<>'' OR pUsuario IS NOT NULL) THEN
	
		--SELECT numcte INTO vNumCliente FROM bdinteg:"informix".si_bpiusuarios WHERE usuario=TRIM(pUsuario);
		SELECT bpi.numcte INTO vNumCliente 
				FROM bdinteg:"informix".si_bpiusuarios bpi 
					INNER JOIN bdibpi:"informix".bpi_usuario usr ON usr.numcliente=bpi.numcte AND usr.st_portal='activo'
				WHERE usr.id_usuario = pUsuario;
		
		IF (vNumCliente <> '' OR vNumCliente IS NOT NULL) THEN
			SELECT  imagen , frase INTO vNomImagen, vFrase FROM  bdibpi:"informix".bpi_avatar WHERE num_cte=vNumCliente;
			
			IF(vNomImagen = '' OR vNomImagen IS NULL OR vFrase ='' OR vFrase IS NULL) THEN
				LET vCodRet='00003';			END IF;
		ELSE
			LET vCodRet='00002';		END IF;
	ELSE
		LET vCodRet='00001';	END IF;
		
	RETURN vCodRet,vNomImagen,vFrase;
	
END
END PROCEDURE;