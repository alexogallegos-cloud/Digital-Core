CREATE PROCEDURE "informix".sp_consulta_avatar_bm_pba(pEmpresa CHAR(3),pUsuario CHAR(50))
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
	
	IF(pEmpresa <> '' OR pEmpresa IS NOT NULL OR pUsuario<>'' OR pUsuario IS NOT NULL) THEN
	
		SELECT numcte INTO vNumCliente FROM bdinteg:"informix".si_bpiusuarios WHERE usuario=TRIM(pUsuario);
		
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