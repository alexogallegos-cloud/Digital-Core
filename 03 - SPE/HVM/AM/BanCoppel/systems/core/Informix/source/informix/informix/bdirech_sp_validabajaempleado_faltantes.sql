CREATE PROCEDURE "informix".sp_validabajaempleado_faltantes()

--------------------------------------------------------------------
--DOCUMENTACIÓN
--Validamos a los empleados dados de baja con recuperacion finiquito, que aun esten activos
--Realizó: Richar 
--Fecha: 01/09/2015
--------------------------------------------------------------------

													
--cEmpresa = 001
--cCc = el numero del centro de costros
--cStatus = estatus de la consulta del CC

 --DATOS A REGRESAR---	
	RETURNING CHAR(5), --codret
			  CHAR(8), --NumEmpleado
			  Integer; --IdFaltante
			  
--DEFINICION DE VARIABLES--
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    ---------------------------
	
	DEFINE cNumEmpleado Char(8);
	DEFINE iFaltante Integer;
			
	--SET DEBUG FILE TO "sp_validabajaempleado_faltantes.out";
	--TRACE ON;	

	set isolation to dirty read;
	
	-- INICIO DEL PROCEDIMIENTO	
	BEGIN
	-- MANEJADOR DE ERRORES	
		ON EXCEPTION SET iSqlErr
			--LET cCodRet = v_paso;
			LET cCodRet = iSqlErr;
			Return cCodRet,'',''; 
		END EXCEPTION;
	
	
	FOREACH
	select numempleado,idfaltante 
	into cNumEmpleado,iFaltante
	from bdirech:rec_confaltante where idrecupera=1 and idestatus=1
	and numempleado in (select ejecutivo from bdinteg:si_ejecut where upper(trim(password))='BAJA')
	Union
	select numempleado,idfaltante 	
	from bdirech:rec_confaltante where idrecupera=3 and idestatus=1
	and numempleado in (select ejecutivo from bdinteg:si_ejecut where upper(trim(password))='BAJA')
	
		LET cCodRet='00000';
		Return cCodRet,cNumEmpleado,iFaltante WITH RESUME;
		
	End FOREACH;
		
	End;
END PROCEDURE;