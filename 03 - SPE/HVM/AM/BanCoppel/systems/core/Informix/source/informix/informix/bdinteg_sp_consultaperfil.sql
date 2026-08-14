CREATE PROCEDURE "informix".sp_consultaperfil(cNumEmpleado CHAR(8))

--------------------------------------------------------------------
--DOCUMENTACIÓN
--Consultamos si tiene perfil de caja de general
--Realizó: Richar 
--Fecha: 26/01/2015
--------------------------------------------------------------------													
--cEmpresa = 001
--cCentroc = el numero del centro de costros
--cStatus = estatus de la consulta del CC
--cRegion id de la region de la tabla de catalogos
--cgcb id de la gerencia de la tabla de catalogos

 --DATOS A REGRESAR---	
	RETURNING CHAR(5) as codret, 	--codret
			  integer as perf; --perfil
	
--DEFINICION DE VARIABLES--			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE ivPerfil Integer;
	
    ---------------------------
	
	--Banderas
	DEFINE v_paso				varchar(50);
	
	--SET DEBUG FILE TO "/home/sysifx/sp_consultaperfil.out";
	--TRACE ON;	

	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;	

	-- INICIO DEL PROCEDIMIENTO	
	BEGIN
	-- MANEJADOR DE ERRORES	
		ON EXCEPTION SET iSqlErr
			--LET cCodRet = v_paso;
			LET cCodRet = iSqlErr;
			Return cCodRet, 0; 
		END EXCEPTION;		
				
			Select Perfil 
			Into ivPerfil
			from si_perfil_ejecut 
			where ejecutivo=cNumEmpleado
			And Perfil=201;
									
			if ivPerfil is null or ivPerfil='' then
			
				LET ivPerfil=0;
			
			End if;
			--LET v_paso='Consul';
			LET cCodRet = '00000' ;		
			
			return cCodRet,ivPerfil;
			
			
		
	End;
END PROCEDURE;