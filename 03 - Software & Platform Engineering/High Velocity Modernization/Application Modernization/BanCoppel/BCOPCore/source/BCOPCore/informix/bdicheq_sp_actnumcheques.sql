CREATE PROCEDURE "informix".sp_actnumcheques() 
RETURNING CHAR(5), CHAR(80);
--DEFINICION DE VARIABLES
DEFINE vc_CodRet			CHAR(5);
DEFINE vi_SqlErr			INTEGER;
DEFINE vi_iSAMErr			INTEGER;
DEFINE vi_iSAMData			CHAR(80);
DEFINE vc_Mensaje			CHAR(80);
DEFINE cCuenta			    CHAR(20);
DEFINE inumeroconteo		INTEGER;
DEFINE inumerochq			INTEGER;
--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET vi_iSAMErr=0;
LET vi_iSAMData="";
LET vc_Mensaje = "EL PROCESO SE EFECTUO CORRECTAMENTE";
LET cCuenta="";
LET inumeroconteo=0;
LET inumerochq=0;


    BEGIN

    ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            LET vc_Mensaje = "ERROR NO CONTROLADO";
            RETURN vc_CodRet, vc_Mensaje;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/informix/VH/chequeras/sp_actnumcheques.out";
    --TRACE ON;

	SET ISOLATION TO DIRTY READ;
	FOREACH

		SELECT cuenta,max(numero) INTO cCuenta,inumeroconteo FROM sc_contch
		WHERE cuenta IN (
		SELECT DISTINCT cuenta FROM sc_contch)
		GROUP BY cuenta
		ORDER BY cuenta

		SELECT ult_chq INTO inumerochq FROM sc_maechq WHERE empresa='001' AND cuenta=cCuenta;
		
		IF inumeroconteo<>inumerochq THEN
			UPDATE "informix".sc_maechq SET ult_chq = inumeroconteo WHERE empresa='001' AND cuenta=cCuenta;
		END IF;

	END FOREACH;  

	RETURN vc_CodRet, vc_Mensaje;
END;
END PROCEDURE;