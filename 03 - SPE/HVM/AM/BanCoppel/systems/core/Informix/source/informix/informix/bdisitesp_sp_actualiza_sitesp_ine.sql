CREATE PROCEDURE "informix".sp_actualiza_sitesp_ine(pFechaIni DATE,pFechaFin DATE) 											
											
RETURNING CHAR(5)  AS cCodRet,     
		  CHAR(50) AS cDescripcion,
		  INTEGER  AS iTotReg,
		  INTEGER  AS iRegTrue,
		  INTEGER  AS iRegFalse;

--Definicion de Variables
DEFINE cCodRet			CHAR(5);
DEFINE iSqlErr			INTEGER;
DEFINE cDescripcion		CHAR(50);
DEFINE iRegTrue			INTEGER;
DEFINE iRegFalse		INTEGER;
DEFINE iTotReg			INTEGER;
DEFINE iRegPro			INTEGER;
DEFINE cNumCte			CHAR(20);
DEFINE cResultado		CHAR(50);


DEFINE cSituacion		CHAR(1);
DEFINE iCausa			INTEGER;


--Inicializacion de Variables
LET cCodRet			= '00000';
LET cDescripcion	= 'Actualizacion Exitosa de registros';
LET iSqlErr			= 0;
LET iRegTrue		= 0;
LET iRegFalse		= 0;
LET iTotReg			= 0;
LET iRegPro			= 0;
LET cNumCte 		= '';
LET cResultado		= '';
LET cSituacion		= '';
LET iCausa			= 0;


--SET DEBUG FILE TO '/tmp/cristo/sp_actualiza_sitesp_ine.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cDescripcion,iTotReg,iRegTrue,iRegFalse;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF  ((NVL(pFechaIni,'01/01/1900') = '01/01/1900') OR	(NVL(pFechaFin,'01/01/1900') = '01/01/1900') ) OR pFechaIni > pFEchaFin THEN
		LET cCodRet = '00001'; 
		LET cDescripcion = "Error en parametros de entrada";
	ELSE
		BEGIN WORK;	
		
		FOREACH WITH HOLD
			
			SELECT numcte
			INTO cNumCte
			FROM bdisitesp:"informix".se_ctessitespcte
			WHERE situacion = 'P' AND causa = 109 
			AND fchalta::DATE BETWEEN pFechaIni AND pFechaFin
			
			LET iTotReg=iTotReg+1;
			LET iRegPro=iRegPro+1;
			LET iRegFalse = iRegFalse+1;
			
			LET cResultado='';

			FOREACH WITH HOLD
				SELECT FIRST 1 TRIM(resultado) INTO cResultado
				FROM bdinteg:"informix".si_bitacora_ife
				WHERE numcte=cNumCte
				ORDER BY fecha DESC
			END FOREACH;
				
				IF NVL(cResultado,'')<>'Falso' THEN
					LET iRegTrue = iRegTrue+1;
					LET iRegFalse = iRegFalse-1;
					IF NOT EXISTS(SELECT {+INDEX(bdisitesp:"informix".se_ctessitespcte_his se_ctessitespcte_his_idx2)} numcte FROM bdisitesp:"informix".se_ctessitespcte_his WHERE numcte=cNumCte and causa not in (109,61,62,65)) THEN
						UPDATE {+INDEX(bdisitesp:"informix".se_ctessitespcte se_ctessitespcte_idx1,se_ctessitespcte_idx2)} bdisitesp:"informix".se_ctessitespcte SET situacion='U',causa='65',motivo_desmarcaje='DEPURACION P-109' WHERE numcte=cNumCte AND situacion = 'P' AND causa = 109;
					ELSE
						
						FOREACH WITH HOLD
							SELECT {+INDEX(bdisitesp:"informix".se_ctessitespcte_his se_ctessitespcte_his_idx2)} FIRST 1 situacion,causa INTO cSituacion,iCausa
							FROM bdisitesp:"informix".se_ctessitespcte_his 
							WHERE numcte=cNumCte
							and causa not in (109,61,62)
							order by idmovto DESC
							
						END FOREACH;
						
						UPDATE {+INDEX(bdisitesp:"informix".se_ctessitespcte se_ctessitespcte_idx1,se_ctessitespcte_idx2)}  bdisitesp:"informix".se_ctessitespcte SET situacion=cSituacion,causa=iCausa,motivo_desmarcaje='DEPURACION P-109 HIST.' WHERE numcte=cNumCte AND situacion = 'P' AND causa = 109;
						
					END IF;
				END IF;
			
			LET cSituacion		= 'U';
			LET iCausa			= 65;

			IF iRegPro = 3000 THEN
				COMMIT WORK;
				LET iRegPro = 0;
				BEGIN WORK;
			END IF;
							
		END FOREACH;
		
		IF iRegPro < 3000 THEN
			COMMIT WORK;
		END IF;
		
		RETURN cCodRet, cDescripcion,iTotReg,iRegTrue,iRegFalse;	
	END IF;	
END;

END PROCEDURE;