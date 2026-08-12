CREATE PROCEDURE "informix".sp_validatelefonosrefos(pEmpresa CHAR(3), pNumCteTitular CHAR(20),pNumSolicitud CHAR(20), pSecuencia CHAR(20))
RETURNING CHAR(5);

DEFINE cCodret            CHAR(5);
DEFINE cNumSolicitud      CHAR(20);
DEFINE cSecuencia         CHAR(20);
DEFINE cNumCte            CHAR(20);
DEFINE cProducto          CHAR(4);
DEFINE cCofeteltel1       CHAR(1);
DEFINE cCofeteltel2       CHAR(1);
DEFINE cCofeteltel3       CHAR(1);
DEFINE cParentesco        CHAR(2);
DEFINE iSql_err           INTEGER;
DEFINE iExistsReg         INTEGER;
DEFINE iValidar           INTEGER;
DEFINE iRegistros         INTEGER;
DEFINE iFlag              INTEGER;
DEFINE iBandConyuge       INTEGER;

--SET DEBUG FILE TO '/tmp/sp_validatelefonosrefos.out';
--TRACE ON;

LET cCodret          = '00002';
LET cNumSolicitud    = '';
LET cSecuencia       = '';
LET cNumCte          = '';
LET cProducto        = '';
LET cCofeteltel1     = '';
LET cCofeteltel2     = '';
LET cCofeteltel3     = '';
LET cParentesco      = '';
LET iSql_err         = 0;
LET iExistsReg       = 0;
LET iValidar         = 1;
LET iRegistros       = 0;
LET iFlag            = 0;
LET iBandConyuge     = 0;

BEGIN
	ON EXCEPTION SET iSql_err
		--LET cCodret = CAST(iSql_err AS CHAR); 
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN cCodret;
		END IF;
	END EXCEPTION;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF TRIM(NVL(pEmpresa,'')) <> '' AND TRIM(NVL(pNumCteTitular,'')) <> ''  THEN 
		IF TRIM(NVL(pNumSolicitud,'')) = '' THEN
			SELECT MAX(num_solicitud)
			INTO cNumSolicitud
			FROM bdisolic:"informix".ss_solicitudes
			WHERE  empresa= pEmpresa 
			AND numcte =pNumCteTitular; 

			IF dbinfo("sqlca.sqlerrd2") = 1  THEN
				SELECT num_producto
				INTO cProducto
				FROM bdisolic:"informix".ss_solicitudes 
				WHERE empresa= pEmpresa 
				AND num_solicitud = cNumSolicitud;

				IF dbinfo("sqlca.sqlerrd2") = 1  THEN
					IF TRIM(NVL(cProducto,'')) <> '6500' THEN
						LET iBandConyuge= 1;
					END IF;
				END IF;
			ELSE	
				LET cCodret = '00003';
			END IF;
		ELSE
			LET cNumSolicitud = pNumSolicitud;
		END IF;

		SELECT COUNT (a.secuencia) 
		INTO iRegistros
		FROM "informix".si_refclientes AS a, "informix".si_refdirecciones AS b 
		WHERE a.numcte = b.numcte 
		AND a.secuencia = b.secuencia 
		AND a.numcte_banco=b.numcte_banco 
		AND a.empresa=pEmpresa 
		AND a.numcte = pNumCteTitular
		AND a.num_solicitud = cNumSolicitud;

		IF iRegistros <> 0 THEN
			IF TRIM(NVL(pSecuencia,'')) <> '' AND CAST(pSecuencia AS INTEGER) > 0 THEN
				IF EXISTS (SELECT a.numcte FROM "informix".si_refclientes AS a, "informix".si_refdirecciones AS b WHERE a.numcte = b.numcte AND a.secuencia = b.secuencia
						AND a.numcte_banco=b.numcte_banco AND a.empresa=pEmpresa AND a.numcte = pNumCteTitular AND a.num_solicitud = cNumSolicitud	AND a.secuencia = pSecuencia) THEN
					LET iExistsReg = 1;
				END IF;	

				IF iRegistros = 1 AND iExistsReg= 1 OR (iRegistros = 2)THEN
					LET iValidar= 0;
				END IF;

				IF iValidar = 1 THEN
					SELECT a.numcte_banco, b.ind_cofeteltel1, b.ind_cofeteltel2, b.ind_cofeteltel3, a.parentesco
					INTO cNumCte, cCofeteltel1, cCofeteltel2, cCofeteltel3, cParentesco
					FROM "informix".si_refclientes AS a, "informix".si_refdirecciones AS b
					WHERE a.numcte = b.numcte
					AND a.secuencia = b.secuencia 
					AND a.numcte_banco=b.numcte_banco
					AND a.empresa=pEmpresa
					AND a.numcte = pNumCteTitular 
					AND a.num_solicitud = cNumSolicitud
					AND a.secuencia = (SELECT NVL(MAX(secuencia),0) FROM "informix".si_refclientes 
						WHERE numcte = pNumCteTitular AND num_solicitud = cNumSolicitud AND secuencia <> pSecuencia);
					--AND a.secuencia <> pSecuencia;  --BCPL 05/05/2014

					IF dbinfo("sqlca.sqlerrd2") = 1 THEN
						IF TRIM(cParentesco) <> 'E' THEN	
							IF TRIM(NVL(cCofeteltel1,'')) <> '' OR TRIM(NVL(cCofeteltel2,'')) <> '' OR TRIM(NVL(cCofeteltel3,'')) <> '' THEN
								LET iFlag = 1;
							ELSE
								LET cCodret = '00002';
							END IF;		
						ELSE
							IF TRIM(NVL(cNumCte,'')) <> '' THEN
								FOREACH
									SELECT cofetel
									INTO cCofeteltel1
									FROM "informix".si_telefonos_actual 
									WHERE empresa = pEmpresa 
									AND numcte  = cNumCte 
									AND status_tel = 'A'  

									IF TRIM(NVL(cCofeteltel1,'')) = 'V' THEN 
										LET cCodret = '00001';
									END IF;
								END FOREACH;
							ELSE
								LET cCodret = '00005';
							END IF;
						END IF;	
					ELSE
						LET cCodret = '00004';
					END IF;
				ELSE
					LET cCodret = '00000';
				END IF;

			ELSE
				IF iBandConyuge = 1 THEN
					SELECT a.secuencia
					INTO cSecuencia
					FROM "informix".si_refclientes a
					LEFT OUTER JOIN "informix".si_refdirecciones b
					ON (a.numcte = b.numcte
					AND a.secuencia = b.secuencia)
					WHERE a.empresa = pEmpresa
					AND a.numcte = pNumCteTitular 
					AND a.num_solicitud = cNumSolicitud
					AND a.secuencia = (SELECT NVL(MAX(secuencia),0) FROM "informix".si_refclientes 
						WHERE numcte = pNumCteTitular AND num_solicitud = cNumSolicitud AND a.parentesco <> 'E');
					--AND a.parentesco <> 'E';  --BCPL 05/05/2014

					IF dbinfo("sqlca.sqlerrd2") = 1 THEN
						SELECT a.numcte_banco, b.ind_cofeteltel1, b.ind_cofeteltel2, b.ind_cofeteltel3
						INTO cCofeteltel1, cCofeteltel2, cCofeteltel3
						FROM "informix".si_refclientes AS a, "informix".si_refdirecciones AS b
						WHERE a.numcte = b.numcte
						AND a.secuencia = b.secuencia 
						AND a.numcte_banco=b.numcte_banco
						AND a.empresa=pEmpresa
						AND a.numcte = pNumCteTitular 
						AND a.num_solicitud = cNumSolicitud
						AND a.secuencia = cSecuencia;

						IF TRIM(NVL(cCofeteltel1,'')) <> '' OR TRIM(NVL(cCofeteltel2,'')) <> '' OR TRIM(NVL(cCofeteltel3,'')) <> '' THEN
							LET iFlag = 1;
						ELSE
							LET cCodret = '00002';
						END IF;
					ELSE
						LET cCodret = '00000';
					END IF;

				ELSE
					IF iRegistros > 1 THEN
					FOREACH
						SELECT a.numcte_banco, b.ind_cofeteltel1, b.ind_cofeteltel2, b.ind_cofeteltel3, a.parentesco
						INTO cNumCte, cCofeteltel1, cCofeteltel2, cCofeteltel3, cParentesco
						FROM "informix".si_refclientes AS a, "informix".si_refdirecciones AS b
						WHERE a.numcte = b.numcte
						AND a.secuencia = b.secuencia 
						AND a.numcte_banco=b.numcte_banco
						AND a.empresa=pEmpresa
						AND a.numcte = pNumCteTitular 
						AND a.num_solicitud = cNumSolicitud
						
						SELECT count(numcte) INTO iRegistros FROM bdisolic:"informix".ss_refpersonales WHERE numcte =pNumCteTitular AND parentesco = cParentesco AND numcte_ref = 'R3';
						
						IF NVL(iRegistros,0) = 1 THEN
							LET cCodret = '00000';
						ELSE 
							IF TRIM(cParentesco) <> 'E' THEN
								IF TRIM(NVL(cCofeteltel1,'')) <> '' OR TRIM(NVL(cCofeteltel2,'')) <> '' OR TRIM(NVL(cCofeteltel3,'')) <> '' THEN
									LET iFlag = 1;
								ELSE
									LET cCodret = '00002';
								END IF;

							ELSE
								IF TRIM(NVL(cNumCte,'')) <> '' THEN
									FOREACH
										SELECT cofetel
										INTO cCofeteltel1
										FROM "informix".si_telefonos_actual 
										WHERE empresa = pEmpresa 
										AND numcte  = cNumCte 
										AND status_tel = 'A'  

										IF TRIM(NVL(cCofeteltel1,'')) = 'V' THEN 
											LET cCodret = '00001';
										END IF;
									END FOREACH;

								ELSE
									LET cCodret = '00005';
								END IF;
							END IF;	
						END IF
					END FOREACH;
					ELSE
						LET cCodret = '00003';
					END IF;
				END IF;
			END IF;

			IF iFlag = 1 THEN
				IF TRIM(NVL(cCofeteltel1,'')) = 'V' THEN
					LET cCodret = '00001';
				END IF;
				IF TRIM(NVL(cCofeteltel2,'')) = 'V' THEN
					LET cCodret = '00001';
				END IF;
				IF TRIM(NVL(cCofeteltel3,'')) = 'V' THEN
				LET cCodret = '00001';
				END IF;
			END IF;

		ELSE
			LET cCodret = '00000';
		END  IF;
	END IF;					

	RETURN cCodret;	

END;
END PROCEDURE
DOCUMENT
'AUTOR         : Felipe Urias',
'DESCRIPCION   : se realizo este Sp para revizar si la otra referencia cuenta con un numero valido',
'BASE DE DATOS : bdinteg ',
'FECHA         : 21/06/2013';

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