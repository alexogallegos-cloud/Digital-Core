CREATE PROCEDURE "informix".sp_consultacajagen()

--------------------------------------------------------------------
--DOCUMENTACIÓN
--Consultamos todas las plazas de la tabla si_plazas_cajagen
--Realizó: Richar 
--Fecha: 28/01/2015
--------------------------------------------------------------------													


 --DATOS A REGRESAR---	
	RETURNING CHAR(5) as codret, 	--codret
			  CHAR(3) as plaza,
			  char(60) as NomPlaza; --perfil
			  
	
--DEFINICION DE VARIABLES--			  
	DEFINE cCodRet 	CHAR(5);
	DEFINE iSqlErr 	INTEGER;	
	DEFINE cVPlaza  char(3);
	DEFINE cVNombre CHAR(60);	
    ---------------------------
	
	--Banderas
	DEFINE v_paso				varchar(50);
	
	--SET DEBUG FILE TO "/home/sysifx/sp_consultacajagen.out";
	--TRACE ON;	

	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;	

	-- INICIO DEL PROCEDIMIENTO	
	BEGIN
	-- MANEJADOR DE ERRORES	
		ON EXCEPTION SET iSqlErr
			--LET cCodRet = v_paso;
			LET cCodRet = iSqlErr;
			Return cCodRet, 0,''; 
		END EXCEPTION;		
				
			
			FOREACH
			select 
			codigo_plaza, 
			trim(descripcion) as nombre 
			Into cVPlaza,cVNombre
			from si_plazas_cajagen			
			order by descripcion
			
			--LET v_paso='Consul';
			LET cCodRet = '00000' ;
			
			return cCodRet,cVPlaza,cVNombre WITH RESUME;
			
			End FOREACH;
			
			
		
	End;
END PROCEDURE;