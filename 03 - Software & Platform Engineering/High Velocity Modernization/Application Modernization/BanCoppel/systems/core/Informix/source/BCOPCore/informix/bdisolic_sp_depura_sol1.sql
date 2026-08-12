CREATE PROCEDURE "informix".sp_depura_sol1()
RETURNING CHAR(6), VARCHAR(70,1);

DEFINE cCodRet      CHAR(6); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE Error_Info   VARCHAR(40);
DEFINE fFecha       DATE;
DEFINE cProceso		CHAR(04);
DEFINE iSolProcesadas  INTEGER;
DEFINE cMensaje		VARCHAR(70,1);
DEFINE P_COD_RET    VARCHAR(6);
DEFINE P_MENSAJE    VARCHAR(150);
DEFINE cHoraInicial		CHAR(8);
DEFINE cHoraFinal		CHAR(8);
DEFINE sHoraInicial		SMALLINT;
DEFINE sHoraFinal		SMALLINT;
DEFINE sMinutoInicial	SMALLINT;
DEFINE sMinutoFinal		SMALLINT;
DEFINE sHorasProceso	SMALLINT;
DEFINE cTerminaProceso	CHAR(1);

LET cCodRet      = '000000';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET Error_Info	 = '';
LET vNumCred     = '';
LET vNumCredAux  = '';
LET fFecha       = date(1);
LET cProceso	 = '0012';
LET iSolProcesadas  = 0;
LET cMensaje	 = 'PROCESO EXITOSO.';
LET P_COD_RET    = '';
LET P_MENSAJE    = '';
LET cHoraInicial	= '';
LET cHoraFinal		= '';
LET sHoraInicial	= 0;
LET sHoraFinal		= 0;
LET sMinutoInicial	= 0;
LET sMinutoFinal	= 0;
LET sHorasProceso	= 0;
LET cTerminaProceso = '0';


set isolation to dirty read;
set lock mode to wait 10;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, Error_Info
        IF iSqlErr != 0 THEN
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

	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '01') RETURNING P_COD_RET;

	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraInicial from sysmaster:sysshmvals;

	LET sHoraInicial = SUBSTR(cHoraInicial,1,2);
	LET sMinutoInicial = SUBSTR(cHoraInicial,4,2);

    SELECT num_credito
      INTO vNumCredAux
      FROM bdicred:"informix".sd_param_movhis_dep
     where proceso = 8;

    IF vNumCredAux IS NULL THEN 
       LET vNumCredAux = ""; 
       INSERT INTO bdicred:"informix".sd_param_movhis_dep VALUES(8,vNumCredAux);
    END IF;

    select valor::date
      into fFecha
    from bdicred:sd_param
    where empresa = '001'
    and cod_param = '801'; 

	SELECT valor::smallint
      INTO sHorasProceso
      FROM bdicred:sd_param
     WHERE cod_param = '094';

	IF sHorasProceso IS NULL THEN 
		LET sHorasProceso = 1;
		INSERT INTO bdicred:sd_param VALUES
			('001','094','Horas a procesar sp_depura_sol1',sHorasProceso,user,today);
    END IF;

    FOREACH WITH HOLD

       SELECT num_solicitud
           INTO vNumCred 
           FROM bdisolic:"informix".ss_solicitudes
          WHERE status_solicitud = 'CN'
            AND fecha_insert <= fFecha
           -- AND num_solicitud > vNumCredAux --CAX se quita filtro por existencia de 11,812,195 menores al num de credito registrado
        -- ORDER BY num_solicitud ASC

        BEGIN WORK;

            insert into bdisolic:ss_detalle_scoring_resp
            select * from bdisolic:ss_detalle_scoring
            where empresa = '001'
            and num_solicitud = vNumCred;

            DELETE FROM bdisolic:ss_detalle_scoring
            where empresa = '001'
            and num_solicitud = vNumCred;

            insert into bdisolic:ss_autorizacion_resp
            select * from bdisolic:ss_autorizacion
            where empresa = '001'
            and num_solicitud = vNumCred;

            DELETE FROM bdisolic:ss_autorizacion
            where empresa = '001'
            and num_solicitud = vNumCred;

            insert into bdisolic:ss_detalle_modelo_resp
            select * from bdisolic:ss_detalle_modelo
            where empresa = '001'
            and num_solicitud = vNumCred;

            DELETE FROM bdisolic:ss_detalle_modelo
            where empresa = '001'
            and num_solicitud = vNumCred;

            UPDATE bdicred:sd_param_movhis_dep
               SET num_credito = vNumCred
             where proceso = 8;

        COMMIT WORK;  

		LET iSolProcesadas = iSolProcesadas + 1;

		SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraFinal from sysmaster:sysshmvals;

		LET	sHoraFinal = SUBSTR(cHoraFinal,1,2);
		LET	sMinutoFinal = SUBSTR(cHoraFinal,4,2);
		LET	sHoraFinal = sHoraFinal - sHoraInicial;

		IF sHoraFinal >= sHorasProceso AND sMinutoFinal > sMinutoInicial THEN	
			LET cTerminaProceso = '1';
			EXIT FOREACH;
		END IF;
--RETURN cCodRet, cMensaje;
    END FOREACH;

	IF cTerminaProceso = '0' THEN
		UPDATE bdicred:sd_param_movhis_dep
		SET num_credito = ''
		WHERE proceso = 8;
	END IF;

	LET cMensaje = 'TOTAL solicitudes procesadas: ' ||  iSolProcesadas;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '03') RETURNING P_COD_RET;

	LET cMensaje = 'PROCESO EXITOSO.';
	LET cMensaje = cMensaje || ' Se procesaron -> ' || iSolProcesadas || ' solicitudes.';

    RETURN cCodRet, cMensaje;

    END
END PROCEDURE
