CREATE PROCEDURE "informix".sp_consultainformacionccc(pEmpresa CHAR(3), pCentroc char(4))
				
 --DATOS A REGRESAR---	
	RETURNING CHAR(5), 	--codret
			  CHAR(40),	--Nombre del centro
			  CHAR(3),	--Numero de Zona
			  CHAR(40),	--Zona de centro de costo
			  INTEGER,	--Numero de GCB
			  CHAR(30); --Gerente comercial
	
--DEFINICION DE VARIABLES--			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	--------------------------
	DEFINE cNomCC	CHAR(40); -- Nombre del centro
	DEFINE cPlaza 	CHAR(3);  -- # de zona centro de costo
	DEFINE cZonCC 	CHAR(40); -- Zona de centro de costo
	DEFINE cIdGer	CHAR(3);  -- id de Gerencia
	DEFINE cGerCC	CHAR(30); -- Gerente comercial
	
	LET cCodRet='00001';
	LET iSqlErr= 0;
	LET cNomCC ='';
	LET cPlaza ='';
	LET cZonCC ='';
	LET cIdGer ='';
	LET cGerCC ='';
	
	--SET DEBUG FILE TO "/home/sysifx/Trinidad/bdinteg/sp_consultainformacionccc.out";
	--TRACE ON;	

	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;	

	-- INICIO DEL PROCEDIMIENTO	
	BEGIN
	-- MANEJADOR DE ERRORES	
		ON EXCEPTION SET iSqlErr
			--LET cCodRet = v_paso;
			LET cCodRet = iSqlErr;
			Return cCodRet, cNomCC,cPlaza, cZonCC,cIdGer,cGerCC; 
		END EXCEPTION;
		
		if Trim(pEmpresa) is null or Trim(pCentroc) is null then
			LET cCodRet ='00001';
		else
			
			select trim(s.nombre), trim(d. plaza), trim(d.nombre), cg.id_gerencia, trim(cg.gerencia_comercial)
			Into cNomCC, cPlaza, cZonCC, cIdGer, cGerCC
			from bdinteg: "informix".si_sucursales s inner join bdinteg: "informix".si_plazas d on d.plaza=s.plaza left join bdinteg: "informix".si_catgcb_rh cg on s.id_gerencia_rh = cg.id_gerencia
			where s.sucursal= pCentroc and s.tpo_sucursal in ('S','N') and s.empresa= pEmpresa;
			LET cCodRet= '00000';
		End if;
		
		Return cCodRet, cNomCC,cPlaza, cZonCC,cIdGer,cGerCC; 
		
	End;
END PROCEDURE;