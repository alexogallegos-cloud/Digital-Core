CREATE PROCEDURE "informix".sp_depura_autorizacion()
RETURNING CHAR(6), VARCHAR(70,1);

DEFINE cCodRet      CHAR(6); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE Error_Info   VARCHAR(40);
DEFINE cProceso		CHAR(04);
DEFINE iSolProcesadas  INTEGER;
DEFINE cMensaje		VARCHAR(70,1);
DEFINE P_COD_RET    VARCHAR(6);
DEFINE P_MENSAJE    VARCHAR(150);
DEFINE cHoraInicial		CHAR(8);
DEFINE sHoraInicial		SMALLINT;
DEFINE sMinutoInicial	SMALLINT;
DEFINE sCommit          SMALLINT;

-----Variables contador------------
DEFINE iMaxCommit INTEGER;
DEFINE iContador INTEGER;

LET cCodRet      = '000000';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET Error_Info	 = '';
LET vNumCred     = '';
LET vNumCredAux  = '';
LET cProceso	 = '0014';
LET iSolProcesadas  = 0;
LET cMensaje	 = 'PROCESO EXITOSO.';
LET P_COD_RET    = '';
LET P_MENSAJE    = '';
LET cHoraInicial	= '';
LET sHoraInicial	= 0;
LET sMinutoInicial	= 0;
LET sCommit = 0;

-----Variables contador------------
LET iMaxCommit = 1000;
LET iContador = 0;

set isolation to dirty read;
set lock mode to wait 3;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, Error_Info
        IF iSqlErr != 0 THEN
			
			IF (sCommit = -1) THEN
				ROLLBACK WORK;
			END IF;
			
			LET cCodRet = iSqlErr;		

			LET cMensaje = 'TOTAL solicitudes procesadas: ' ||  iSolProcesadas;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

            LET cMensaje = 'Error --> '|| iSqlErr ||'	'|| trim(Error_Info);
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

            LET cMensaje = 'Solicitud --> '|| TRIM(vNumCred);
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
			
            RETURN cCodRet, cMensaje;
        END IF;
    END EXCEPTION;

--    SET DEBUG FILE TO 'sp_depura_sd_movhis2.out';
--    TRACE ON;

--	SET DEBUG FILE TO '/home/c90077639/depura_2025/sp_depura_sd_movhis2.out';
--    TRACE ON;

  -- SET DEBUG FILE TO '/home/c90077639/sp_depura/univ_unic/sp_depura_sd_movhis2.out';
  -- TRACE ON;

	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '01') RETURNING P_COD_RET;

	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraInicial FROM sysmaster:sysshmvals;
	
		
	FOREACH WITH HOLD -- Se ajusta foreach por CURSOR

		SELECT num_solicitud into vNumCred from bdisolic:depura_ss_detalle_scoring
		
			---Se agrega contador para que se realice la depuracion cada 1000 solicitude				
				IF iContador = 0 THEN
					BEGIN WORK;
				END IF;
				
				LET iContador = iContador + 1;
				LET iSolProcesadas = iSolProcesadas + 1;
										
				INSERT INTO bdisolic:ss_autorizacion_resp_2021
				SELECT * FROM bdisolic:ss_autorizacion
				WHERE empresa = '001' AND num_solicitud = vNumCred;
				
				DELETE FROM bdisolic:ss_autorizacion
				WHERE empresa = '001' AND num_solicitud = vNumCred;
				
				DELETE FROM bdisolic:depura_ss_detalle_scoring
				WHERE num_solicitud = vNumCred;
				
				IF iContador = iMaxCommit THEN
					COMMIT WORK;
					LET iContador = 0;
				END IF;
				
    END FOREACH;
	
	IF iContador > 0 THEN
		COMMIT WORK;
		LET iContador = 0;
	END IF;
	
	LET cMensaje = 'TOTAL solicitudes procesadas: ' ||  iSolProcesadas;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '03') RETURNING P_COD_RET;

	LET cMensaje = 'PROCESO EXITOSO.';
	LET cMensaje = cMensaje || ' Se procesaron -> ' || iSolProcesadas || ' solicitudes.';

    RETURN cCodRet, cMensaje;

    END
END PROCEDURE
