CREATE PROCEDURE "informix".sps_consulta_avatar_bmovil(pEmpresa CHAR(3),pUsuario CHAR(10))
RETURNING   CHAR(5),--Codigo de retorno
			CHAR(10),--Nombre imagen del avatar
			CHAR(50),
			SMALLINT,
            CHAR(1);
			
--***************************************************************************************************
-- DESCRIPCION:  Se clona SP para que sea utilizado solo en Bmovil
-- AUTOR : Bibiana Gaxiola Verdugo
-- FECHA : 11/02/2016
-- BD: bdibpi
--***************************************************************************************************
--***************************************************************************************************
-- DESCRIPCION:  Se agrega campo de retorno para validar nuevo avatar
-- REALIZO : Evelia Ontiveros
-- FECHA : 20/07/2017
-- BD: bdibpi
--***************************************************************************************************
			
		
--Declaración de variables
DEFINE cCodRet CHAR(5);
DEFINE iSql_err INTEGER;
DEFINE cNumCliente CHAR(9);
DEFINE cNomImagen CHAR(10);
DEFINE cFrase CHAR(50);
DEFINE sIdStatus SMALLINT;
DEFINE sAvatarNvo CHAR(1);

--Inicializar variables
LET cNumCliente='';
LET cNomImagen='';
LET cFrase='';
LET cCodRet='00000';
LET sIdStatus=0;
LET sAvatarNvo='';

	--set debug file to "/tmp/sps_consulta_avatar_bm.out";
	--trace on;
	
BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, '', '', 0,'';
		END IF ;
	END EXCEPTION ;
	
    SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF(pEmpresa <> '' OR pEmpresa IS NOT NULL OR pUsuario<>'' OR pUsuario IS NOT NULL) THEN
	
		--SELECT numcte INTO cNumCliente FROM bdinteg:"informix".si_bpiusuarios WHERE usuario=TRIM(pUsuario);
		SELECT bpi.numcte, bpi.id_status INTO cNumCliente, sIdStatus 
				FROM bdinteg:"informix".si_bpiusuarios bpi 
					INNER JOIN bdibpi:"informix".bpi_usuario usr ON usr.numcliente=bpi.numcte AND usr.st_portal='activo'
				WHERE usr.id_usuario = pUsuario;
		
		IF (cNumCliente <> '' OR cNumCliente IS NOT NULL) THEN
        SELECT  imagen, frase, asig_avat_nuev_img 
            INTO cNomImagen, cFrase, sAvatarNvo 
            FROM bdibpi:"informix".bpi_avatar WHERE num_cte=cNumCliente;

            IF LEN(cNomImagen) > 3 THEN
            LET cNomImagen = SUBSTR(cNomImagen,2,3);
           END IF;           
			
			IF(cNomImagen = '' OR cNomImagen IS NULL OR cFrase ='' OR cFrase IS NULL) THEN
				LET cCodRet='00003';			END IF;
		ELSE
			LET cCodRet='00002';		
		END IF;
		
	ELSE
		LET cCodRet='00001';	
	END IF;
	
	IF (sIdStatus = 0 OR sIdStatus IS NULL) THEN
		LET cCodRet='00004';
	END IF;
		
	RETURN cCodRet,cNomImagen,cFrase,sIdStatus,sAvatarNvo;
	
END
END PROCEDURE;