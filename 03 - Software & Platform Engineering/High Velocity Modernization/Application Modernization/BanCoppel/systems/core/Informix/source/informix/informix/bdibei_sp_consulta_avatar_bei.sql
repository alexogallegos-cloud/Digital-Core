CREATE PROCEDURE "informix".sp_consulta_avatar_bei(pIdUsuario Integer,pNumCliente CHAR(9))
RETURNING   CHAR(5),
			SMALLINT,
			SMALLINT,
            VARCHAR(20),
			DATETIME YEAR to SECOND
			;

--Declaración de variables
DEFINE vCodRet CHAR(5);
DEFINE sql_err INTEGER;

   DEFINE vIdAvatar            SMALLINT;
   DEFINE vNumIntento          SMALLINT;
   DEFINE vFBloqueoTemp        DATETIME YEAR to SECOND; 
   DEFINE vTokenVirtual        VARCHAR(20) ;

--Inicializar variables
LET vCodRet='00000';

LET vIdAvatar=0;
LET vNumIntento=0;
LET vFBloqueoTemp = '';
LET vTokenVirtual = '';



	--****************************************************************************************************
	-- DESCRIPCION: Consulta el avatar del usuario
	-- AUTOR: Irving Guzman Salas - SOLSER
	-- FECHA: 22/09/2014
	-- BD: bdibei
	-- SOLICITO:BanCoppel
	-- FECHA LIBERACION A PRODUCCION: 22-ENERO-2015
	--***************************************************************************************************


BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET vCodRet = sql_err;
			RETURN vCodRet, vIdAvatar, vNumIntento,vTokenVirtual,vFBloqueoTemp;
		END IF ;
	END EXCEPTION ;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF(pNumCliente IS NOT NULL AND pIdUsuario IS NOT NULL AND pNumCliente <> '' AND  pIdUsuario>0 ) THEN
		
		
            SELECT id_avatar,numIntento, f_bloqueo_temp, tokenvirtual
			INTO vIdAvatar, vNumIntento,vFBloqueoTemp,vTokenVirtual
			FROM  bdibei:"informix".bei_avatar WHERE id_usuario=pIdUsuario AND num_cliente=pNumCliente;
			
			
			IF(vIdAvatar IS NULL OR vIdAvatar = '' ) THEN
				LET vCodRet='00003';
				LET vIdAvatar=0;
				LET vNumIntento=0;
				LET vFBloqueoTemp = '';
				LET vTokenVirtual = '';
			END IF;
				
	ELSE
		LET vCodRet='00001';
	END IF;
	
		RETURN vCodRet, vIdAvatar, vNumIntento,vTokenVirtual,vFBloqueoTemp;
END
END PROCEDURE;