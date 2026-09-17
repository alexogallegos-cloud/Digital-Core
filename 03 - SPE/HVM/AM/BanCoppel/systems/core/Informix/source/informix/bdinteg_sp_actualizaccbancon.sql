CREATE PROCEDURE "informix".sp_actualizaccbancon(cEmpresa CHAR(3),cCentroc CHAR(4), cRegion INTEGER, cgcb INTEGER, cStatus INTEGER, iZona INTEGER)

--------------------------------------------------------------------
--DOCUMENTACIÓN
--Actualiza solo los campos del si_sucursales gerencia, region y estatus
--Realizó: Richar 
--Fecha: 22/01/2015
--------------------------------------------------------------------													
--DOCUMENTACIÓN
--Se agrega que se puedan consultar CC de Corporativos
--Modifica: Fernando Fernández Gómez 
--Fecha: 17/08/2015
--------------------------------------------------------------------
--DOCUMENTACIÓN
--Se modifica procedimiento para que se actualicen los campos plaza, user_insert y fecha_insert estos campos son adicionales a los campos que ya se estaban actualizando, además se agregaron las reglas de informix
--Modifica: Misael Mercado Obeso
--Fecha: 23/09/2019
--Solicita: Ricardo Recendiz
--Folio: 612
--------------------------------------------------------------------
--cEmpresa = 001
--cCentroc = el numero del centro de costros
--cStatus = estatus de la consulta del CC
--cRegion id de la region de la tabla de catalogos
--cgcb id de la gerencia de la tabla de catalogos
--zona id de la zona de la tabla de catalogos

 --DATOS A REGRESAR---	
	RETURNING CHAR(5), 	--codret
			  CHAR(40); --Estatus de la actualizacion del CC
	
--DEFINICION DE VARIABLES--			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cMensaje CHAR (60);
    ---------------------------
	
	--Banderas
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cMensaje = 'Proceso de actualización exitosa';
	
	--SET DEBUG FILE TO "/home/sysifx/sp_consultaccbancon.out";
	--TRACE ON;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	

	-- INICIO DEL PROCEDIMIENTO	
	BEGIN
	-- MANEJADOR DE ERRORES	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cMensaje = 'Error en la ejecución.';
			RETURN cCodRet, cMensaje; 
		END EXCEPTION;			
		
		IF (cEmpresa = '' OR cEmpresa IS NULL) OR (cCentroc = '' OR cCentroc IS NULL) OR (cRegion = '' OR cRegion IS NULL) OR (cgcb = '' OR cgcb IS NULL) OR (cStatus = '' OR cStatus IS NULL) THEN
			LET cCodRet ='00002';
			LET cMensaje = 'Parametros incompletos';			
		ELSE			
			UPDATE si_sucursales 
			SET id_region_rh=cRegion, 
			id_gerencia_rh=cgcb, 
			id_status_rh=cStatus,
			id_czb_rh = iZona
			WHERE sucursal=cCentroc
			AND tpo_sucursal IN('S','N') 
			AND empresa=cEmpresa;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN											
				LET cCodRet ='00001';	
				LET cMensaje = 'No existen datos en la actualización';			
			END IF;			
		END IF;
		RETURN cCodRet, cMensaje;	
	END;	
END PROCEDURE;