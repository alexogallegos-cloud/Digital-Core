CREATE PROCEDURE "informix".sp_obtener_datos_login_bpi(pEmpresa CHAR(3),pUsuario CHAR(50))
	RETURNING CHAR (5), CHAR(4), CHAR(50),DATETIME YEAR TO SECOND, CHAR(11),CHAR(20),SMALLINT;

	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Creador: Francisco Rodríguez
	-- Objetivo: Se obtiene la sucursal virtual, el usuario virtual, el numero de cliente, el estatus del cliente y el id de usuario, todo esto para optimizar el login de la bpi
	-- Solicitó: Mauricio León
	-- Fecha: 16/02/2011
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--Declaración de variables
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vSucursal VARCHAR(50);
	DEFINE vUsuario VARCHAR(50);
	DEFINE vIdUsuario VARCHAR(11);
	DEFINE vIdStatus SMALLINT;
	DEFINE vNumCte VARCHAR(20);
	DEFINE vFecha  DATETIME YEAR TO SECOND;
	
	--Inicializar valores de variables
	LET vSucursal = '';
	LET vUsuario = '';
	LET vIdUsuario = '';
	LET vIdStatus=0;
	LET vNumCte='';
	LET vCod_ret='00000';
	LET vFecha=null;
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vSucursal,vUsuario,vFecha,vIdUsuario,vNumCte,vIdStatus;
		  END IF ;
		END EXCEPTION ;

		IF(pUsuario<>'' OR pUsuario IS NOT NULL) THEN
			
			SELECT numcte,id_status 
				INTO vNumCte, vIdStatus 
			FROM bdinteg:si_bpiusuarios 
				WHERE empresa = pEmpresa AND usuario = pUsuario;
			
			IF (vNumCte<>'' OR vNumCte IS NOT NULL) THEN 
			
				SELECT sucursal_virtual,usuario_virtual,current  
					INTO vSucursal, vUsuario, vFecha
				FROM  bdibpi:bpi_parametros_contenido;
				
				SELECT id_usuario 
					INTO vIdUsuario 
				FROM bdibpi:bpi_usuario 
					WHERE numcliente = vNumCte AND st_portal = 'activo';
				
			ELSE 
				LET vCod_ret='00002';			END IF		 
			
		ELSE
			LET vCod_ret='00001';		END IF;
		
		RETURN vCod_ret, vSucursal,vUsuario,vFecha,vIdUsuario,vNumCte,vIdStatus;
	END;
END PROCEDURE
		
	;