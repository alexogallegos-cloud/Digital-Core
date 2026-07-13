CREATE PROCEDURE "informix".sp_confpago_remesa (cReferencia1 CHAR (20))
RETURNING
CHAR(5);

    -- Definicion de Variables
    DEFINE cCodRet CHAR(5);
    DEFINE iSql_err INTEGER;
	DEFINE iIsamErr INTEGER;
	DEFINE cDescripcion CHAR (200);
	DEFINE cConf_pago CHAR(1);
	DEFINE cTxn_status CHAR(1);
	DEFINE dMaxFexha DATETIME YEAR TO SECOND;
	
	LET cCodRet = '00000';
	LET iSql_err = 0;
	LET iIsamErr = 0;
	LET cDescripcion = '';
	LET cConf_pago = '';
	LET cTxn_status = '';
	LET dMaxFexha = '1900-01-01 00:00:00';

	--SET DEBUG FILE TO '/home/sysifx/HMLG/sp_confpago_remesa.out';
	--TRACE ON;
	 

    BEGIN
		ON EXCEPTION SET iSql_err, iIsamErr, cDescripcion
		   IF iSql_err <> 0 THEN
			  LET cCodRet = iSql_err;
			  RETURN cCodRet;
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		


		IF  NVL(cReferencia1,'') <> ''THEN		
		
				SELECT MAX(fecha_insert)
				INTO dMaxFexha
				FROM bdisac:'informix'.sac_wu_pay 
				WHERE mtcn = cReferencia1
				AND TO_CHAR(fecha_insert::DATE) = TODAY;									
									
				SELECT conf_pago, txn_status 
				INTO cConf_pago, cTxn_status 
				FROM bdisac:'informix'.sac_wu_pay 
				WHERE  mtcn = cReferencia1 
				AND fecha_insert = dMaxFexha;

				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00002';
				ELSE
					IF NVL(cConf_pago,'') <> '' AND NVL(cTxn_status,'') <> '' THEN
						IF TRIM(cConf_pago) <> 'P' AND TRIM(cTxn_status) <>'A' THEN
							LET cCodRet = '00004';
						END IF;
					ELSE
						LET cCodRet = '00003';
					END IF;
				END IF;

		ELSE
			LET cCodRet = '00001';
		END IF;	

		RETURN cCodRet;
    END;
END PROCEDURE;