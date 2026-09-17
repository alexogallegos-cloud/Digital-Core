CREATE PROCEDURE "informix".sp_actualizacccajagen(vCentroC Char(4),vMontoMin FLOAT, vMontoMax FLOAT, vPlazaCG CHAR(3), vPlazaCB INTEGER)

--------------------------------------------------------------------
--DOCUMENTACIÃN
--Actualiza lo saldos maximos, minimos, plaza clabe y caja general
--RealizÃ³: Richar 
--Fecha: 29/01/2015
--------------------------------------------------------------------													

 --DATOS A REGRESAR---	
	RETURNING CHAR(5) as codret, 	--codret
			  CHAR(30) as status;    --Observaciones

			  
--DEFINICION DE VARIABLES--			  
	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;	
	DEFINE cVStatus  	char(30);
	DEFINE cNoPlazaClabe Char(4);
	DEFINE cNoPlaza Char(3);
	DEFINE cPos			INTEGER;
		
    ---------------------------	
	--Banderas
	DEFINE v_paso				varchar(50);	
	
	--SET DEBUG FILE TO "sp_actualizacccajagen.out";
	--TRACE ON;	

	LET cNoPlaza = '';
	
	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;	

	-- INICIO DEL PROCEDIMIENTO	
	BEGIN
	-- MANEJADOR DE ERRORES	
		ON EXCEPTION SET iSqlErr
			--LET cCodRet = v_paso;
			LET cCodRet = iSqlErr;
			Return cCodRet, ''; 
		END EXCEPTION;		
				--Actualizamos la tabla si_sucursales
				update si_sucursales set mto_min_efect=vMontoMin, mto_max_efect=vMontoMax, plaza_cajagen=vPlazaCG, id_plazaclabe=vPlazaCB
				where sucursal=vCentroC and empresa='001';
				
				select no_plaza 
				INTO cNoPlazaClabe
				from si_plaza_clabe where id_plazaclabe=vPlazaCB;
				
			IF cNoPlazaClabe<>'' then
				
				IF exists(select {+INDEX (bdicheq:sc_plazaclabe idx_plazaclabe_trx1)} * from bdicheq:sc_plazaclabe where trim(sucursal)=trim(vCentroC) and empresa='001') THEN
					delete {+INDEX (bdicheq:sc_plazaclabe idx_plazaclabe_trx1)} from bdicheq:sc_plazaclabe where trim(sucursal)=trim(vCentroC) and empresa='001';
				End if;
				
				select plaza 
				INTO cNoPlaza
				from si_sucursales where trim(sucursal)=trim(vCentroC) and empresa='001';
				
				LET cPos = length(cNoPlazaClabe);
				
				if cPos=1 then
					LET cNoPlazaClabe = '00' || cNoPlazaClabe;
				ELIF cPos=2 then
					LET cNoPlazaClabe = '0' || cNoPlazaClabe;				
				End if;
				
				Insert into bdicheq:sc_plazaclabe(empresa,plazaclabe,plaza,localidad,sucursal) 
				values ('001', cNoPlazaClabe,cNoPlaza,'01',trim(vCentroC));
			
			End if;
			
			LET cCodRet = '00000' ;			
			return cCodRet,'Actualizacion exitosa' WITH RESUME;			
			
	End;
END PROCEDURE;