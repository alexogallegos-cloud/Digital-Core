CREATE PROCEDURE "informix".sp_actualiza_contadores_ivr(pEmpresa CHAR(3), pNumCte CHAR(20), pNumTel CHAR(13), pOpcion CHAR(1))

	RETURNING	CHAR(6) AS CodRet;
			
	DEFINE 	cCodRet		 CHAR(6);
	DEFINE	iSqlErr	 	 INTEGER;
	DEFINE	iContSMS	 SMALLINT;
	DEFINE	iContLlamada SMALLINT;
	DEFINE	iActSms		 SMALLINT;
	DEFINE	iActRpt		 SMALLINT;
	DEFINE iIntentosMax	 SMALLINT;	DEFINE iIntentos	 SMALLINT;
	LET	cCodRet		 = '000000';
	LET iSqlErr		 = 0;
	LET iContSMS	 = 0;
	LET iContLlamada = 0;
	LET iActSms 	 = 0;
	LET iActRpt 	 = 0; 
	LET iIntentosMax = 0;
	LET iIntentos	 = 0;

	BEGIN
		
		--CONTROL DE ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET  cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/sp_actualiza_contadores_ivr.out';
		--TRACE ON;
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		--VALIDA ERRORES DE LOS PARAMETROS
		IF NVL(pEmpresa,'') = '' OR NVL(pNumCte,'') = '' OR NVL(pNumTel,'') = '' OR NVL(pOpcion,'') = '' THEN
			LET cCodRet='000001';
		ELSE
			IF pOpcion = 2 THEN
				--DSB-13/06/2016
				--OBTIENE EL NUMERO DE INTENTOS MAX EN LLAMADA
				SELECT CAST(TRIM(valor) AS SMALLINT) INTO iIntentosMax FROM "informix".si_param WHERE cod_param = 389;
				
				SELECT COUNT(numcte) INTO iIntentos FROM "informix".si_bitllamada_ivr 
				WHERE empresa = pEmpresa AND numcte = TRIM(pNumCte) AND numtel = pNumTel 
				AND fecha_insert > CURRENT YEAR TO DAY;
				
				IF iIntentos < iIntentosMax THEN
					UPDATE "informix".si_bit_intentos_ivr
					SET cont_sms = cont_sms + 1, cont_llamada = cont_llamada + 1,fecha_mov = CURRENT
					WHERE empresa = pEmpresa AND numcte = TRIM(pNumCte)
					AND numtel = pNumTel;
				ELSE
					LET cCodRet='000002';
				END IF;
			ELSE
				IF pOpcion = 1 THEN
					LET iActSms = 1;
				ELSE
					LET iActRpt = 1;
				END IF;
				
				IF EXISTS(SELECT numcte FROM "informix".si_bit_intentos_ivr WHERE empresa = pEmpresa AND numcte = TRIM(pNumCte) AND numtel = pNumTel) THEN
					
					UPDATE "informix".si_bit_intentos_ivr
					SET cont_sms = cont_sms + iActSms, cont_rpte = cont_rpte + iActRpt, fecha_mov = CURRENT
					WHERE empresa = pEmpresa AND numcte = pNumCte
					AND numtel = pNumTel;
					
				ELSE
					INSERT INTO "informix".si_bit_intentos_ivr (empresa,numcte,numtel,cont_sms,cont_llamada,fecha_insert,fecha_mov,cont_rpte) VALUES (pEmpresa,TRIM(pNumCte),pNumTel,iActSms,0,CURRENT,CURRENT,iActRpt);
				END IF;
			END IF;
		END IF;
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT
'AUTOR:	ERNESTO AGUILERA',
'FECHA:	28/DIC/2015',
'DESCRIPCION: Actualizar contadores de sms y llamada',
'BD: BDINTEG',
'MODIFICO:	VICTOR HUGO NUNEZ',
'FECHA:	13/06/2016',
'DESCRIPCION: Se modifica para poder validar la cantidad maxima de llamas a realizar por dia',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_ctes_fusionados(pFechIni DATE, pFechFin DATE)
RETURNING	 INTEGER as CodErr, CHAR(10) as Fecha, INTEGER as Fusionados, INTEGER as No_Fusionados, INTEGER as Total

DEFINE iSqlErr			INTEGER;
DEFINE iFusionados      INTEGER;
DEFINE iNoFusionados    INTEGER;
DEFINE iTotal           INTEGER;
DEFINE dFecha           CHAR(10);


LEt iSqlErr              =0;
LEt iFusionados          =0;
LEt iNoFusionados        =0;
LEt iTotal               =0;
LEt dFecha               ='';

BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr, dFecha, iFusionados, iNoFusionados, iTotal;
			END IF;
		END EXCEPTION;

			SET ISOLATION TO DIRTY READ;
            FOREACH c1 FOR
                    select fecha_proceso, sum(procesados) as Total, sum(fusionados) as fusionados, sum(no_fusionados) as no_fusionados
                    into dFecha, iTotal, iFusionados, iNoFusionados
                    from si_estadistica_fusiones where fecha_proceso between pFechIni and pFechFin
                    group by fecha_proceso

                RETURN iSqlErr, dFecha, iFusionados, iNoFusionados, iTotal WITH RESUME;
            END FOREACH;
END
END PROCEDURE;