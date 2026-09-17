CREATE PROCEDURE "informix".sp_valida_saldos_credinomq_tablatemp(pAnio CHAR(5),pNum_credito CHAR(20))
RETURNING CHAR(5)
	--31-01-2014
	--Realizo: Jose Ruben Lopez
	--calcula el saldo del producto credinomina quincenal y mensual 
	--Solicito:Jose de Jesus Nevarez
	--BD: bdimonitorcob
	--------------------------------------------------------
DEFINE cCod_Ret           CHAR(5);
DEFINE iSqlErr            INTEGER;
DEFINE iSamErr            INTEGER;
DEFINE vDesErr            CHAR(60);
DEFINE anioAux   		  INTEGER;
DEFINE ciclo 			  INTEGER;
DEFINE vStatuscred		  CHAR(2);
DEFINE vTipoCred		  CHAR(1);

DEFINE montoS				MONEY(16,2);
DEFINE eneS				  MONEY(16,2);
DEFINE febS				  MONEY(16,2);
DEFINE marS				  MONEY(16,2);
DEFINE abrS				  MONEY(16,2);
DEFINE mayS				  MONEY(16,2);
DEFINE junS				  MONEY(16,2);
DEFINE julS				  MONEY(16,2);
DEFINE agoS				  MONEY(16,2);
DEFINE sepS				  MONEY(16,2);
DEFINE octS				  MONEY(16,2);
DEFINE novS				  MONEY(16,2);
DEFINE dicS				  MONEY(16,2);

DEFINE eneM				  MONEY(16,2);
DEFINE febM				  MONEY(16,2);
DEFINE marM				  MONEY(16,2);
DEFINE abrM				  MONEY(16,2);
DEFINE mayM				  MONEY(16,2);
DEFINE junM				  MONEY(16,2);
DEFINE julM				  MONEY(16,2);
DEFINE agoM				  MONEY(16,2);
DEFINE sepM				  MONEY(16,2);
DEFINE octM				  MONEY(16,2);
DEFINE novM				  MONEY(16,2);
DEFINE dicM				  MONEY(16,2);

LET montoS=0;
LET eneS=0;
LET febS=0;
LET marS=0;
LET abrS=0;
LET mayS=0;
LET junS=0;
LET julS=0;
LET agoS=0;
LET sepS=0;
LET octS=0;
LET novS=0;
LET dicS=0;

LET eneM=0;
LET febM=0;
LET marM=0;
LET abrM=0;
LET mayM=0;
LET junM=0;
LET julM=0;
LET agoM=0;
LET sepM=0;
LET octM=0;
LET novM=0;
LET dicM=0;
LET vStatuscred = '';
LET vTipoCred = '';

LET anioAux=0;
LET cCod_Ret='00000';
--SET DEBUG FILE TO "/informix/ALL/sp_valida_comportamiento_tabla_temporal.out";
--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
            LET cCod_Ret = iSqlErr;
        END IF;
        RETURN cCod_Ret;
    END EXCEPTION;
	ON EXCEPTION IN (-206) --ERROR TABLA TEMPORAL NO EXISTE
        LET cCod_Ret = '00002';        RETURN cCod_Ret;
    END EXCEPTION;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- Sacamos el status del cliente
				SELECT status_cred,bandera_ministra INTO vStatuscred, vTipoCred
				FROM bdicred:sd_maecredcrd WHERE empresa = '001' AND num_credito= pNum_credito;
				
					LET anioAux=pAnio;
					FOR  ciclo = 1 TO 3 --SON TRES ANIOS LOS QUE SE MANEJAN 
							
							SELECT ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic 
							INTO eneS,febS,marS,abrS,mayS,junS,julS,agoS,sepS,octS,novS,dicS
							FROM tTempInd 
							where anio=anioAux 
							AND id_concepto='370';
							
							SELECT ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic 
							INTO eneM,febM,marM,abrM,mayM,junM,julM,agoM,sepM,octM,novM,dicM
							FROM tTempInd 
							where anio=anioAux 
							AND id_concepto='250';
							
							--ENERO
							--Sacamos el saldo para los credinomina que son quincenales y se valida si traen vencido en el mes.
							IF vTipoCred = 'Q' THEN
								IF eneM = 0 THEN
									LET montoS = eneS * 2;
									UPDATE tTempInd SET ene=montoS where anio=anioAux AND id_concepto='370';
								END IF;
							END IF;
							
							--FEBRERO
							IF vTipoCred = 'Q' THEN
								IF febM = 0 THEN
									LET montoS = febS * 2;
									UPDATE tTempInd SET feb=montoS where anio=anioAux AND id_concepto='370';
								END IF;
							END IF;
							
							--MARZO
							IF vTipoCred = 'Q' THEN
								IF marM = 0 THEN
									LET montoS = marS * 2;
									UPDATE tTempInd SET mar=montoS where anio=anioAux AND id_concepto='370';
								END IF;
							END IF;
							
							--ABRIL
							IF vTipoCred = 'Q' THEN
								IF abrM = 0 THEN
									LET montoS = abrS * 2;
									UPDATE tTempInd SET abr=montoS where anio=anioAux AND id_concepto='370';
								END IF;
							END IF;
							
							--MAYO
							IF vTipoCred = 'Q' THEN
								IF mayM = 0 THEN
									LET montoS = mayS * 2;
									UPDATE tTempInd SET may=montoS where anio=anioAux AND id_concepto='370';
								END IF;
							END IF;
							
							--JUNIO
							IF vTipoCred = 'Q' THEN
								IF junM = 0 THEN
									LET montoS = junS * 2;
									UPDATE tTempInd SET jun=montoS where anio=anioAux AND id_concepto='370';
								END IF;
							END IF;
							
							--JULIO
							IF vTipoCred = 'Q' THEN
								IF julM = 0 THEN
									LET montoS = julS * 2;
									UPDATE tTempInd SET jul=montoS where anio=anioAux AND id_concepto='370';
								END IF;
							END IF;
							
							--AGOSTO
							IF vTipoCred = 'Q' THEN
								IF agoM = 0 THEN
									LET montoS = agoS * 2;
									UPDATE tTempInd SET ago=montoS where anio=anioAux AND id_concepto='370';
								END IF;
							END IF;
							
							--SEPTIEMBRE
							IF vTipoCred = 'Q' THEN
								IF sepM = 0 THEN
									LET montoS = sepS * 2;
									UPDATE tTempInd SET sep=montoS where anio=anioAux AND id_concepto='370';
								END IF;
							END IF;
							
							--OCTUBRE
							IF vTipoCred = 'Q' THEN
								IF octM = 0 THEN
									LET montoS = octS * 2;
									UPDATE tTempInd SET octu=montoS where anio=anioAux AND id_concepto='370';
								END IF;
							END IF;
							
							--NOVIEMBRE
							IF vTipoCred = 'Q' THEN
								IF novM = 0 THEN
									LET montoS = novS * 2;
									UPDATE tTempInd SET nov=montoS where anio=anioAux AND id_concepto='370';
								END IF;
							END IF;
							
							--DICIEMBRE
							IF vTipoCred = 'Q' THEN
								IF dicM = 0 THEN
									LET montoS = dicS * 2;
									UPDATE tTempInd SET dic=montoS where anio=anioAux AND id_concepto='370';
								END IF;
							END IF;
							
							LET anioAux = anioAux+1;
					END FOR;

				RETURN cCod_Ret;
END;
END PROCEDURE;