CREATE PROCEDURE "informix".sp_consultaplazaclabecc(vCSucursal char(4))

--------------------------------------------------------------------
--DOCUMENTACIÓN
--Consulta la plaza clabe que pertenece a una sucursal desde la bdicheq
--Realizó: Richar 
--Fecha: 28/01/2015
--------------------------------------------------------------------													


 --DATOS A REGRESAR---	
	RETURNING CHAR(5) as codret, 	--codret
			  INTEGER as idplazaClabe, --Id del catalogo de la plaza clabe
			  char(60) as NomPlaza; --perfil
			  
	
--DEFINICION DE VARIABLES--			  
	DEFINE cCodRet 	CHAR(5);
	DEFINE iSqlErr 	INTEGER;	
	DEFINE cIPlaza  INTEGER;	DEFINE cVNombre CHAR(60);	DEFINE cCPlazaCheq  Char(3);	
    ---------------------------
	
	
	--Banderas
	DEFINE v_paso				varchar(50);
	
	--SET DEBUG FILE TO "/home/sysifx/sp_consultaplazaclabecc.out";
	--TRACE ON;	
	
	LET cCPlazaCheq='';
	LET cIPlaza=0;

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
					
			select id_plazaclabe,SP.plazaclabe 
			into cIPlaza,cCPlazaCheq
			from
			si_sucursales SS inner join bdicheq:sc_plazaclabe SP
			on SS.sucursal=SP.sucursal
			where SS.sucursal=vCSucursal and SS.empresa='001';
			
			If ((cIPlaza<=0 or cIPlaza is null) and cCPlazaCheq<>'') then		
			
				select first 1 id_plazaclabe,trim(nombre) || ' ' || trim(estado) as nombre 
				INTO cIPlaza,cVNombre
				from si_plaza_clabe where no_plaza=cCPlazaCheq;
				
				Return '0000', cIPlaza,trim(cVNombre); 
				
			ELIF  (cIPlaza>0 and cCPlazaCheq<>'') THEN
			
				select id_plazaclabe,trim(nombre) || ' ' || trim(estado) as nombre 
				INTO cIPlaza,cVNombre
				from si_plaza_clabe where id_plazaclabe=cIPlaza;
				
				Return '0000', cIPlaza,trim(cVNombre); 				
				
			End if;
			
				Return '0001', 999,trim('Sin asignar');  --No encontro informacion
				
	End;
END PROCEDURE;