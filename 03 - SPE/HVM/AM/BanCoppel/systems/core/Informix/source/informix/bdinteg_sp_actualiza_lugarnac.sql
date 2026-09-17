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