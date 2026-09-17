CREATE PROCEDURE "informix".sp_depura_sd_amortiza_2()
--EXECUTE PROCEDURE sp_depura_sd_amortiza_2();
RETURNING 
CHAR(6),     -- codigo de retorno
CHAR(150);   -- mensaje

-- Modificacion -> Se hardcodea la fecha por motivo de que no corre con la variable dFechaDepura

DEFINE cCodRet      CHAR(6); 
DEFINE cMensaje     CHAR(150); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE Error_Info   VARCHAR(80);
DEFINE dFechaDepura DATE;
DEFINE sHoraInicial	SMALLINT;
DEFINE sHoraFinal	SMALLINT;
DEFINE cHoraInicial		CHAR(8);
DEFINE cHoraFinal		CHAR(8);
DEFINE sMinutoInicial	SMALLINT;
DEFINE sMinutoFinal		SMALLINT;
DEFINE sHorasProceso	SMALLINT;
DEFINE iCuentasProcesadas	INTEGER;
DEFINE iCount_sd_amortiza_credito_old	INTEGER;
DEFINE cProceso		CHAR(04);
DEFINE P_COD_RET    	VARCHAR(6);

LET cCodRet      = '000000';
LET cMensaje     = '';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET Error_Info   = '';
LET vNumCred     = '';
LET vNumCredAux  = '';
LET dFechaDepura = date(1);
LET sHoraInicial = 0;
LET sHoraFinal	 = 0;
LET cHoraInicial	= '';
LET cHoraFinal		= '';
LET sMinutoInicial	= 0;
LET sMinutoFinal	= 0;
LET sHorasProceso	= 0;
LET iCuentasProcesadas	= 0;
LET iCount_sd_amortiza_credito_old	= 0;
LET cProceso		= '0003';
LET P_COD_RET   	= '000000';

-- SET ISOLATION TO COMMITTED READ LAST COMMITTED;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, Error_Info
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;	
            LET cMensaje = 'Error --> '||Error_Info||'	'||vNumCred;
			CALL "informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '02') RETURNING P_COD_RET;			
            RETURN cCodRet,cMensaje;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO '/RESPALDOSNEW/Ulises/sp_depura_sd_movhis2.out';
    --TRACE ON;

    CALL "informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '01') RETURNING P_COD_RET;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraInicial from sysmaster:sysshmvals;

	LET sHoraInicial = SUBSTR(cHoraInicial,1,2);
	LET sMinutoInicial = SUBSTR(cHoraInicial,4,2);
	
	--begin; update "informix".sd_param_movhis_dep set num_credito = '' where proceso = 10; commit;
	
    SELECT num_credito
      INTO vNumCredAux
      FROM "informix".sd_param_movhis_dep
     where proceso = 10;

    IF vNumCredAux = '' OR vNumCredAux IS NULL THEN 
       --LET vNumCredAux = '0'; 
       INSERT INTO "informix".sd_param_movhis_dep VALUES(10,'0');
    END IF;

--    select fecha_insert
--      into dFechaDepura
--    from sd_param
--    where empresa = '001'
--    and cod_param = '800'; 

    SELECT valor
      INTO dFechaDepura
      FROM "informix".sd_param
     WHERE cod_param = '115';

    IF dFechaDepura IS NULL THEN 
		INSERT INTO "informix".sd_param(empresa, cod_param, descripcion, valor, user_insert, fecha_insert) 
			VALUES('001', '115', 'FECHA DEPURACION AMORTIZA_CREDITO CUENTAS ACTIVAS', '12/31/2018', user, TODAY);
			
		--LET dFechaDepura = mdy('12','31','2018');
	END IF;

	SELECT valor
      INTO sHorasProceso
      FROM "informix".sd_param
     WHERE cod_param = '116';

	 IF sHorasProceso IS NULL THEN 
		INSERT INTO "informix".sd_param(empresa, cod_param, descripcion, valor, user_insert, fecha_insert) 
			VALUES('001', '116', 'PARAMETRO DE HORAS A PROCESAR CUENTAS ACTIVAS', '5', user, TODAY);

		--LET sHorasProceso = 5;
    END IF;

       SELECT num_credito
           FROM "informix".sd_maecred
           WHERE empresa  = '001' 
            AND num_credito > vNumCredAux
			AND status_cred IN ('AA','BA','BT')
			INTO TEMP cuentas_activas WITH NO LOG;
		
		UPDATE STATISTICS MEDIUM FOR TABLE cuentas_activas;
		
	FOREACH WITH HOLD	

		SELECT TRIM(num_credito)
           INTO vNumCred 
        FROM cuentas_activas
		ORDER BY num_credito ASC

	   LET iCuentasProcesadas = iCuentasProcesadas + 1;
	   
        BEGIN WORK;

            insert into "informix".sd_amortiza_credito_old --sd_amortiza_credito_14
            select * from "informix".sd_amortiza_credito
            where empresa = '001'
            and fecha_cuota <= mdy('12','31','2018') --dFechaDepura
            and num_credito = vNumCred
            and capital_status = 5;

            DELETE FROM "informix".sd_amortiza_credito
            where empresa = '001'
            and fecha_cuota <= mdy('12','31','2018') --dFechaDepura
            and num_credito = vNumCred
            and capital_status = 5;

			LET iCount_sd_amortiza_credito_old	= iCount_sd_amortiza_credito_old + 1;
						
			UPDATE "informix".sd_param_movhis_dep
			SET num_credito = vNumCred
			where proceso = 10;		

        COMMIT WORK;

		SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraFinal from sysmaster:sysshmvals;

		LET	sHoraFinal = SUBSTR(cHoraFinal,1,2);
		LET	sMinutoFinal = SUBSTR(cHoraFinal,4,2);
		LET	sHoraFinal = sHoraFinal - sHoraInicial;

		IF sHoraFinal >= sHorasProceso AND sMinutoFinal > sMinutoInicial THEN
			EXIT FOREACH;
		END IF;
		
    END FOREACH;
	drop table cuentas_activas;

	LET cMensaje = 'TOTAL Cuentas procesadas : ' ||iCuentasProcesadas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_amortiza_credito_old : ' ||iCount_sd_amortiza_credito_old;
	CALL "informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = 'El proceso DEPURA CUENTAS ACTIVAS termino exitosamente. Cuentas procesadas ' || iCuentasProcesadas;

	CALL "informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '03') RETURNING P_COD_RET;
	
    RETURN cCodRet,cMensaje;

    END
END PROCEDURE;