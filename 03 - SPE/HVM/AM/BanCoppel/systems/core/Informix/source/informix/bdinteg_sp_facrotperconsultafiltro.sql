CREATE PROCEDURE "informix".sp_facrotperconsultafiltro(pfiltro integer)
				
 --DATOS A REGRESAR---	
	RETURNING CHAR(5), 	-- codret
			  CHAR(5),	--  # de registros
			  CHAR(40), -- arreglo de filtros
			  INTEGER;  -- # de datos
	
--DEFINICION DE VARIABLES--			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	---------------------------
	DEFINE cPlaza 	CHAR(3);  -- # de zona centro de costo
	DEFINE cZonCC 	CHAR(40); -- Zona de centro de costo
	DEFINE cSuc		CHAR(5);  -- # de centro de costo
	DEFINE cNomCC	CHAR(40); -- Nombre del centro
	DEFINE cIdGer	CHAR(3);  -- id de Gerencia
	DEFINE cGerCC	CHAR(30); -- Gerente comercial
	DEFINE iNumRe 	INTEGER;  -- # de registros
	DEFINE ifiltro	INTEGER;  -- Factor de RotaciÃ³n interna 1.- Zona, 2.- Centro de Costos 3.- GCB
		
	LET cCodRet='00001';
	LET iSqlErr= 0;
	LET cPlaza ='';
	LET cZonCC ='';
	LET cSuc ='';
	LET cNomCC ='';
	LET cIdGer ='';
	LET cGerCC ='';
	LET iNumRe = 0;
	LET ifiltro= pfiltro;
	
	--SET DEBUG FILE TO "/home/sysifx/Trinidad/bdinteg/sp_facrotperconsultafiltro.out";
	--TRACE ON;	

	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;	

	-- INICIO DEL PROCEDIMIENTO	
	BEGIN
	-- MANEJADOR DE ERRORES	
		ON EXCEPTION SET iSqlErr
			--LET cCodRet = v_paso;
			LET cCodRet = iSqlErr;
			Return cCodRet, '', '', 0; 
		END EXCEPTION;
		
		if ifiltro is null or ifiltro = '' then
			LET cCodRet ='00001';
			Return cCodRet, ifiltro,'No existe factor de rotaciÃ³n interna', 0; 
		else
			
			IF ifiltro = 1 THEN -- zona
				SELECT COUNT(DISTINCT nombre) INTO iNumRe FROM bdinteg: "informix".si_plazas;
				LET cCodRet ='00000';
			ELSE 
				IF ifiltro = 3 THEN --centro de costos
					SELECT COUNT(DISTINCT nombre) INTO iNumRe FROM bdinteg: "informix".si_sucursales;
					LET cCodRet ='00000';
				ELSE 
					IF ifiltro = 4 THEN-- gcb
						SELECT COUNT(DISTINCT gerencia_comercial) INTO iNumRe FROM bdinteg: "informix".si_catgcb_rh;
						LET cCodRet ='00000';
					ELSE
						LET cCodRet ='00002';
					END IF;
				END IF;
			END IF;
			
			IF iNumRe > 0 THEN
				IF cCodRet ='00000' THEN
						IF ifiltro = 1 THEN -- zona
							FOREACH
								-- zona
								SELECT DISTINCT(z.nombre), plaza INTO cZonCC, cPlaza FROM bdinteg: "informix".si_plazas as z
								LET cCodRet ='00000';
								Return cCodRet, cPlaza, cZonCC, iNumRe WITH RESUME;
							End FOREACH;	
						ELSE 
							IF ifiltro = 3 THEN --centro de costos
								FOREACH
									--centro de costos
									SELECT DISTINCT (cc.nombre),sucursal INTO cNomCC, cSuc  FROM bdinteg: "informix".si_sucursales as cc
									LET cCodRet ='00000';
									Return cCodRet, cSuc, cNomCC, iNumRe WITH RESUME;
								End FOREACH;
							ELSE 
								IF ifiltro = 4 THEN-- gcb
									FOREACH
										-- gcb
										SELECT DISTINCT (gcb.gerencia_comercial),id_gerencia INTO cGerCC, cIdGer FROM bdinteg: "informix".si_catgcb_rh as gcb
										LET cCodRet ='00000';
										Return cCodRet, cIdGer, cGerCC, iNumRe WITH RESUME;
									End FOREACH;
								END IF;
							END IF;
						END IF;
				ELSE 
					Return cCodRet, '','No existe factor de rotaciÃ³n interna', iNumRe; 				
								
				END IF;
			ELSE
				Return cCodRet, '', "Sin datos para factor de rotaciÃ³n interna", iNumRe; 
			END IF;	
		End if;
		
	End;
END PROCEDURE;