CREATE PROCEDURE "informix".sp_consulta_act_riesgo( pEmpresa    CHAR(3),
                                                    pNumCte     CHAR(20))
                                                      
RETURNING CHAR(6)  AS cCodRet,
          CHAR(60) AS cDescripcion,
          CHAR(1)  AS cRiesgoViviendaCpl,
          CHAR(1)  AS cRiesgoViviendaBcpl,
		  CHAR(1)  AS cActRiesgoCpl,
		  CHAR(1)  AS cActRiesgoBCpl,
		  CHAR(120)   AS cDescpRiesgo;
		  
DEFINE cCodRet               CHAR(6);
DEFINE cDescripcion   		 CHAR(60);
DEFINE cRiesgoViviendaCpl    CHAR(1);
DEFINE cRiesgoViviendaBcpl   CHAR(1);
DEFINE cActRiesgoCpl         CHAR(1);
DEFINE cActRiesgoBCpl        CHAR(1);
DEFINE cTipoVivienda         CHAR(2);  
DEFINE claveopuesto			 CHAR(4);
DEFINE clavesubopuesto		 CHAR(4);
DEFINE cDescpRiesgo			 CHAR(120);
DEFINE iSqlErr               INTEGER;

LET cCodRet = "000000";
LET cDescripcion = " ";
LET cRiesgoViviendaCpl = " ";
LET cRiesgoViviendaBcpl = " ";
LET cActRiesgoCpl = " ";
LET cActRiesgoBCpl = " ";
LET cTipoVivienda = " ";
LET claveopuesto = " ";
LET clavesubopuesto = " ";
LET cDescpRiesgo = "";
LET iSqlErr	 = 0;

BEGIN
  ON EXCEPTION SET iSqlErr
    IF iSqlErr <> 0 THEN
        LET cCodRet = iSqlErr;
        RETURN cCodRet, cDescripcion, cRiesgoViviendaCpl, cRiesgoViviendaBcpl, cActRiesgoCpl, cActRiesgoBCpl, cDescpRiesgo;
    END IF;
  END EXCEPTION;

   --SET DEBUG FILE TO "/respaldosbd/nadia/sp_consulta_act_riesgo.out";
   --TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
   
      -- VALIDA PARAMETROS DE ENTRADA
    IF (pEmpresa IS NULL OR pEmpresa = '') OR
       (pNumCte IS NULL OR pNumCte = '') THEN
	   
       LET cCodRet = "000001";
	   LET cDescripcion = "Parametros de entrada vacios";
	   
	ELSE
	
		SELECT habita_en 
		INTO cTipoVivienda
		FROM bdinteg:"informix".si_ctepf
		WHERE empresa = pEmpresa
		AND numcte = pNumCte;
   
		IF 	DBINFO('SQLCA.SQLERRD2') = 0 THEN
			
			LET cCodRet = "000002";
			LET cDescripcion = "No se encontraron registros";
			
		ELSE
		
		-- altoriesgocp/cRiesgoViviendaCpl   = 0 = EL CLIENTE NO PRESENTA PROBLEMAS CON EL TIPO DE VIVIENDA PARA COPPEL
		-- altoriesgocp/cRiesgoViviendaCpl   = 1 = EL TIPO DE VIVIENDA DEL CLIENTE ESTA MARCADO COMO INESTABILIDAD PARA COPPEL
		-- altoriesgobcp/cRiesgoViviendaBcpl = 0 = EL CLIENTE NO PRESENTA PROBLEMAS CON EL TIPO DE VIVIENDA PARA BANCOPPEL
		-- altoriesgobcp/cRiesgoViviendaBcpl = 1 = EL TIPO DE VIVIENDA DEL CLIENTE ESTA MARCADO COMO INESTABILIDAD PARA BANCOPPEL
		
			SELECT altoriesgocp, altoriesgobcp
			INTO cRiesgoViviendaCpl, cRiesgoViviendaBcpl
			FROM bdinteg:"informix".si_habitaen
			WHERE habita_en = cTipoVivienda;
			
			IF 	DBINFO('SQLCA.SQLERRD2') = 0 THEN
			
			LET cCodRet = "000002";
			LET cDescripcion = "No se encontraron registros";
			LET cRiesgoViviendaCpl = " ";
			LET cRiesgoViviendaBcpl = " ";
		
			END IF;
		
		END IF;
			
	SELECT claveopcionpuesto, clavesubopcionpuesto
	INTO claveopuesto, clavesubopuesto
	FROM bdinteg:"informix".si_ingresos a 
	WHERE a.numcte = pNumCte
	AND a.tipo_ingreso = 'T'
	AND a.sec_ingreso = (SELECT MAX (sec_ingreso)
	FROM bdinteg:"informix".si_ingresos b
	WHERE b.numcte = a.numcte
	AND b.tipo_ingreso = 'T');
	
	IF 	DBINFO('SQLCA.SQLERRD2') = 0 THEN
	
		LET cCodRet = "000002";
		LET cDescripcion = "No se encontraron registros";    
		
	ELSE
	
	-- altoriesgocredcp/cActRiesgoCpl  = 0 = EL CLIENTE NO PRESENTA OCUPACION DE ALTO RIESGO PARA COPPEL
	-- altoriesgocredcp/cActRiesgoCpl  = 1 = EL TIPO DE ACTIVIDAD DE CLIENTE ESTA MARCADO COMO ALTO RIESGO PARA COPPEL
	-- altoriesgocred/cActRiesgoBCpl   = 0 = EL CLIENTE NO PRESENTA OCUPACION DE ALTO RIESGO PARA BANCOPPEL
	-- altoriesgocred/cActRiesgoBCpl   = 1 = EL TIPO DE ACTIVIDAD DE CLIENTE ESTA MARCADO COMO ALTO RIESGO PARA BANCOPPEL
	
		SELECT altoriesgocredcp, altoriesgocred,descrip
		INTO cActRiesgoCpl, cActRiesgoBCpl, cDescpRiesgo
		FROM bdinteg:"informix".si_actsubact 
		WHERE id_act = claveopuesto
		AND id_subact = clavesubopuesto;
	
	END IF;
	END IF;
	
	IF cCodRet = '000000' THEN
		LET cDescripcion = "Ejecucion Exitosa";
	END IF;	
	
	RETURN cCodRet, cDescripcion, cRiesgoViviendaCpl, cRiesgoViviendaBcpl, cActRiesgoCpl, cActRiesgoBCpl, cDescpRiesgo;
	END;
	
END PROCEDURE

DOCUMENT
"DescripciÃ³n: Consulta si un cliente cuenta con una actividad de riesgo e inestabilidad en la vivienda",
"Autor      : Carolina Elizabeth Verdugo Gastelum",
"FECHA      : 28/12/2015",
"BD         : bdinteg";

CREATE PROCEDURE "informix".sp_actualiza_rfc()

    --DATOS A REGRESAR---
RETURNING CHAR(5) AS CodRet;  -- Codigo de Retorno

	--DEFINICION DE VARIABLES--
DEFINE iSql_err 			INTEGER;
DEFINE cCodRet 				CHAR(5);
DEFINE cNumcte          	CHAR(26);
DEFINE cRfc              	CHAR(26);
DEFINE cRFCcte              CHAR(26);
DEFINE iContartme			INTEGER;
DEFINE iTotal				INTEGER;
DEFINE iContar				INTEGER;
DEFINE iContar2				INTEGER;
DEFINE cCte                 CHAR (26);
DEFINE cRFC_alterno			CHAR (26);

	--INICIALIZACION DE VARIABLES--
LET iSql_err 				= 0;
LET cCodRet 				= '00001';
LET cNumcte         		= '';
LET cRfc                    = '';
LET cRFCcte                 = '';
LET iContartme				= 0;
LET iTotal					= 0;
LET iContar					= 0;
LET iContar2				= 0;
LET cCte                    = '';
LET cRFC_alterno            = '';

--SET DEBUG FILE TO "/tmp/rvd/sp_actualiza_rfc.out";
--TRACE ON;
BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			ROLLBACK WORK;
			RETURN  cCodRet;
		END IF;
	END EXCEPTION;
	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	BEGIN WORK;
	
        SELECT COUNT(numcte) INTO iContar FROM bdinteg:"informix".info_sat;
	
	

           FOREACH Cursos_RFC WITH HOLD FOR
            	SELECT numcte,rfc
                INTO cNumcte,cRfc
                FROM bdinteg:"informix".info_sat 
                ORDER BY numcte,rfc

                SELECT numcte, trim(rfc_alterno) as rfc_alterno,rfc
                INTO cCte, cRFC_alterno,cRFCcte
                FROM "informix".si_cliente
                WHERE empresa='001' and numcte = cNumcte;

				
                IF (cRFC_alterno= '') OR (cRFC_alterno IS NULL) OR (cRFC_alterno <> cRfc) OR (cRFCcte <> cRfc)  THEN
                    UPDATE bdinteg:"informix".si_cliente SET rfc_alterno = cRfc WHERE numcte = cNumcte and rfc<>cRfc;
				END IF;	
				
				UPDATE bdinteg:"informix".info_sat   SET actualizado = 1    WHERE numcte = cNumcte;		
				
			END FOREACH;

        
		LET cCodRet = '00000';
	COMMIT WORK;
	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'Creó:Rosalba Vargas Díaz',
'Descripción: Actualiza RFC Alterno en base a información proporcionada por el SAT',
'FECHA : 11/03/2015',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_actualiza_lugarnac()
RETURNING 
CHAR(5) AS cCodRet ,
CHAR(100) AS cMensajeREt;

--DECLARACIÃN DE VARIABLE
DEFINE cCodRet		CHAR(5);
DEFINE cMensajeREt	CHAR(100);
DEFINE cSql         CHAR(6000);
DEFINE iSqlErr      INTEGER;
DEFINE Cnumcte		CHAR(20);
DEFINE Cnumctetmp		CHAR(20);
DEFINE Clugar_nac	CHAR(2);
DEFINE Clugar_nac_new CHAR(2);
--INICIALIZACIÃN DE VARIABLE

LET cCodRet ='00000';
LET cMensajeREt ='Proceso Exitoso';
LET iSqlErr = 0;
LET cSql = '';
LET Cnumcte	='';
LET Clugar_nac ='';
LET Clugar_nac_new ='';
LET Cnumctetmp ='';

--SET DEBUG FILE TO "/informix/c92962301/lugarnacimiento/Detalle_error_caso1.out";
--TRACE ON;
BEGIN

ON EXCEPTION SET iSqlErr
				IF iSqlErr !=0 THEN
					 LET cCodRet = iSqlErr;
					 LET cMensajeRet = "Ocurrio un Error";
					 --TRUNCATE TABLE 	bdidigital:clientes_depuracion;	
					RETURN cCodRet,cMensajeRet;
				END IF;
			END EXCEPTION;
				

SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
					
		--Se optiene el numero de cliente de la tabla pivote
		SELECT num_credito INTO Cnumctetmp FROM bdicred:"informix".sd_param_movhis_dep WHERE proceso ='6';
				
	
		FOREACH  WITH HOLD
		SELECT numcte,lugar_nac INTO Cnumcte,Clugar_nac 
		FROM bdinteg:"informix".si_ctepf WHERE empresa = '001' AND numcte > Cnumctetmp AND lugar_nac <> '' AND fecha_insert <= '12-09-2015' order by numcte asc
	 	
IF Clugar_nac ='01' THEN
LET Clugar_nac_new ='18';
	ELIF	Clugar_nac ='02' THEN
	LET Clugar_nac_new ='25';
	    ELIF	Clugar_nac ='03' THEN
		LET Clugar_nac_new ='26';
			ELIF	Clugar_nac ='04' THEN
			LET Clugar_nac_new ='02';
				ELIF	Clugar_nac ='05' THEN
				LET Clugar_nac_new ='10';
					ELIF	Clugar_nac ='06' THEN
					LET Clugar_nac_new ='05';
						ELIF	Clugar_nac ='07' THEN
						LET Clugar_nac_new ='08';
							ELIF	Clugar_nac ='08' THEN
							LET Clugar_nac_new ='33';
								ELIF	Clugar_nac ='09' THEN
								LET Clugar_nac_new ='01';
								ELIF	Clugar_nac ='10' THEN
									LET Clugar_nac_new ='14';
										ELIF	Clugar_nac ='11' THEN
										LET Clugar_nac_new ='24';
											ELIF	Clugar_nac ='12' THEN
											LET Clugar_nac_new ='16';
												ELIF	Clugar_nac ='13' THEN
												LET Clugar_nac_new ='06';
													ELIF	Clugar_nac ='14' THEN
													LET Clugar_nac_new ='11';
														ELIF	Clugar_nac ='15' THEN
														LET Clugar_nac_new ='32';
															ELIF	Clugar_nac ='16' THEN
															LET Clugar_nac_new ='12';
																ELIF	Clugar_nac ='17' THEN
																LET Clugar_nac_new ='28';
																	ELIF	Clugar_nac ='18' THEN
																	LET Clugar_nac_new ='21';
																		ELIF	Clugar_nac ='19' THEN
																		LET Clugar_nac_new ='03';
																			ELIF	Clugar_nac ='20' THEN
																			LET Clugar_nac_new ='19';
																				ELIF	Clugar_nac ='21' THEN
																				LET Clugar_nac_new ='17';
																					ELIF	Clugar_nac ='22' THEN
																					LET Clugar_nac_new ='13';
																						ELIF	Clugar_nac ='23' THEN
																						LET Clugar_nac_new ='30';
																							ELIF	Clugar_nac ='24' THEN
																							LET Clugar_nac_new ='27';
																								ELIF	Clugar_nac ='25' THEN
																								LET Clugar_nac_new ='09';
																									ELIF	Clugar_nac ='26' THEN
																									LET Clugar_nac_new ='15';
																										ELIF	Clugar_nac ='27' THEN
																										LET Clugar_nac_new ='07';
																											ELIF	Clugar_nac ='28' THEN
																											LET Clugar_nac_new ='22';
																												ELIF	Clugar_nac ='29' THEN
																												LET Clugar_nac_new ='04';
																													ELIF	Clugar_nac ='30' THEN
																													LET Clugar_nac_new ='31';
																														ELIF	Clugar_nac ='31' THEN
																														LET Clugar_nac_new ='20';
																															ELIF	Clugar_nac ='32' THEN
																															LET Clugar_nac_new ='29';
																																ELIF	Clugar_nac ='33' THEN
																																LET Clugar_nac_new ='23';
																																ELSE 
																																LET Clugar_nac_new ='';
 END IF;
 --Fin Del Bloque--
 
 IF Clugar_nac_new <>'' THEN
  
	BEGIN;
	--Se Actualiza el cliente con el valor nuevo de lugar de nacimiento																																
						
		UPDATE bdinteg:"informix".si_ctepf SET lugar_nac = Clugar_nac_new WHERE empresa = '001' AND numcte = Cnumcte ;
	--Se actualiza el valor de la tabla pivote
		UPDATE  bdicred:"informix".sd_param_movhis_dep SET num_credito = Cnumcte WHERE proceso ='6';

	COMMIT;
	
END IF;
LET Clugar_nac_new = '';
		
	END FOREACH;	

			
			RETURN cCodRet,cMensajeRet;
				
END;
END PROCEDURE

;