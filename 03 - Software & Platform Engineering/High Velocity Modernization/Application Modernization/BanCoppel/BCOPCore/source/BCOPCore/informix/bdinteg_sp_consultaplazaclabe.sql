CREATE PROCEDURE "informix".sp_consultaplazaclabe()

--------------------------------------------------------------------
--DOCUMENTACIÓN
--Consultamos todas las plazas de la tabla
--Realizó: Richar 
--Fecha: 27/01/2015
--------------------------------------------------------------------													


 --DATOS A REGRESAR---	
	RETURNING CHAR(5) as codret, 	--codret
			  INTEGER as plaza,
			  char(60) as NomPlaza; --perfil
			  
	
--DEFINICION DE VARIABLES--			  
	DEFINE cCodRet 	CHAR(5);
	DEFINE iSqlErr 	INTEGER;	
	DEFINE iVPlaza  INTEGER;
	DEFINE cVNombre CHAR(60) ;	
    ---------------------------
	
	--Banderas
	DEFINE v_paso				varchar(50);
	
	--SET DEBUG FILE TO "/home/sysifx/sp_consultaplazaclabe.out";
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
			id_plazaclabe, 
			trim(nombre) || ' ' || trim(estado) as nombre 
			Into iVPlaza,cVNombre
			from si_plaza_clabe									
			order by nombre
			
			--LET v_paso='Consul';
			LET cCodRet = '00000' ;
			
			return cCodRet,iVPlaza,cVNombre WITH RESUME;
			
			End FOREACH;
			
			
		
	End;
END PROCEDURE;