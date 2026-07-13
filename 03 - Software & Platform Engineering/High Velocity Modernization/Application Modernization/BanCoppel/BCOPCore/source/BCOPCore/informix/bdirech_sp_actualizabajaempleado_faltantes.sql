CREATE PROCEDURE "informix".sp_actualizabajaempleado_faltantes(cNumEmpleado Char(8), iFaltante int)

--------------------------------------------------------------------
--DOCUMENTACIÓN
--Validamos a los empleados dados de baja con recuperacion finiquito, que aun esten activos
--Realizó: Richar 
--Fecha: 03/09/2015
--------------------------------------------------------------------

													
--cEmpresa = 001
--cCc = el numero del centro de costros
--cStatus = estatus de la consulta del CC

 --DATOS A REGRESAR---	
	RETURNING CHAR(5); --codret
			 
			  
--DEFINICION DE VARIABLES--			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    ---------------------------
			
	--SET DEBUG FILE TO "sp_validabajaempleado_faltantes.out";
	--TRACE ON;	

	set isolation to dirty read;
	
	-- INICIO DEL PROCEDIMIENTO	
	BEGIN
	-- MANEJADOR DE ERRORES	
		ON EXCEPTION SET iSqlErr
			--LET cCodRet = v_paso;
			LET cCodRet = iSqlErr;
			Return cCodRet; 
		END EXCEPTION;		
		
		if len(cNumEmpleado)=0 or iFaltante=0 then --El numero de empleado vacio o el id faltante en ceros
		
			LET cCodRet='00001';
			return cCodRet;
		
		End if	
	
			update bdirech:rec_confaltante set idestatus=3 where numempleado = cNumEmpleado and idfaltante=iFaltante;
			
			LET cCodRet='00000';
			return cCodRet;
	End;
END PROCEDURE;