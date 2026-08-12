CREATE PROCEDURE "informix".sp_depura_creditos_cancelados()
RETURNING 
CHAR(6),     -- cÃ³digo de retorno
CHAR(150);    -- mensaje


DEFINE cCodRet      	CHAR(6); 
DEFINE cMensaje     	CHAR(150); 
DEFINE vNumCred     	VARCHAR(20,1);
DEFINE vNumCredAux  	VARCHAR(20,1);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr     	INTEGER;
DEFINE Error_Info   	VARCHAR(80);
DEFINE dFechaDepura 	DATE;
DEFINE vFecha 			DATE;
DEFINE dFechaAProcesar 	DATE;
DEFINE vnum_credito 	CHAR(20);
DEFINE vfecha_corte 	DATE;
DEFINE cFechaDepura 	CHAR(10);
DEFINE iDepura			INTEGER;
DEFINE cHoraInicial		CHAR(8);
DEFINE cHoraFinal		CHAR(8);
DEFINE sHoraInicial		SMALLINT;
DEFINE sHoraFinal		SMALLINT;
DEFINE sMinutoInicial	SMALLINT;
DEFINE sMinutoFinal		SMALLINT;
DEFINE sHorasProceso	SMALLINT;
DEFINE cTerminaProceso					CHAR(1);
DEFINE iCuentasProcesadas				INTEGER;
DEFINE iCount_sd_maecred_old			INTEGER;
DEFINE iCount_sd_maecredanexo_old		INTEGER;
DEFINE iCount_sd_maesdos_old			INTEGER;
DEFINE iCount_sd_amortiza_credito_old	INTEGER;
DEFINE iCount_sd_movhis_old				INTEGER;
DEFINE iCount_sd_maesdoshist_old		INTEGER;
DEFINE iCount_sd_maesdoscont_old		INTEGER;
DEFINE iCount_sd_maecredcont_old		INTEGER;
DEFINE cProceso			CHAR(04);
DEFINE P_COD_RET    	VARCHAR(6);
DEFINE P_MENSAJE    	VARCHAR(150);

LET cCodRet      = '000000';
LET cMensaje     = '';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET Error_Info   = '';
LET vNumCred     = '';
LET vNumCredAux  = '';
LET dFechaDepura 	= DATE(1);
LET vFecha 			= DATE(1);
LET dFechaAProcesar = DATE(1);
LET vnum_credito	= '';
LET vfecha_corte	= DATE(1);
LET cFechaDepura	= '';
LET iDepura			= 0;
LET cHoraInicial	= '';
LET cHoraFinal		= '';
LET sHoraInicial	= 0;
LET sHoraFinal		= 0;
LET sMinutoInicial	= 0;
LET sMinutoFinal	= 0;
LET sHorasProceso	= 0;
LET cTerminaProceso = '0';
LET iCuentasProcesadas			= 0;
LET iCount_sd_maecred_old		= 0;
LET iCount_sd_maecredanexo_old	= 0;
LET iCount_sd_maesdos_old		= 0;
LET iCount_sd_amortiza_credito_old	= 0;
LET iCount_sd_movhis_old		= 0;
LET iCount_sd_maesdoshist_old	= 0;
LET iCount_sd_maesdoscont_old	= 0;
LET iCount_sd_maecredcont_old	= 0;
LET cProceso		= '0002';
LET P_COD_RET   	= '000000';
LET P_MENSAJE		= 'El proceso DEPURA CUENTAS CANCELADAS terminÃ³ exitosamente. Cuentas procesadas ';


BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, Error_Info
        IF iSqlErr != 0 THEN
			LET cMensaje = 'TOTAL Cuentas procesadas : ' ||iCuentasProcesadas;
			LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_maecred_old : ' ||iCount_sd_maecred_old;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
			LET cMensaje = 'Cuentas respaldadas sd_maecredanexo_old : ' ||iCount_sd_maecredanexo_old;
			LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_maesdos_old : ' ||iCount_sd_maesdos_old;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
			LET cMensaje = 'Cuentas respaldadas sd_amortiza_credito_old : ' ||iCount_sd_amortiza_credito_old;
			LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_movhis_old : ' ||iCount_sd_movhis_old;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
			LET cMensaje = 'Cuentas respaldadas sd_maesdoshist_old : ' ||iCount_sd_maesdoshist_old;
			LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_maesdoscont_old : ' ||iCount_sd_maesdoscont_old;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
			LET cMensaje = 'Cuentas respaldadas sd_maesdoscont_old : ' ||iCount_sd_maesdoscont_old;
		--	LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_maesdoscont_old : ' ||iCount_sd_maesdoscont_old;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

			LET cCodRet = iSqlErr;		
            LET cMensaje = 'Error --> '||Error_Info||'	'||vNumCred;

			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '02') RETURNING P_COD_RET;

            RETURN cCodRet,cMensaje;
        END IF;
    END EXCEPTION;

    CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '01') RETURNING P_COD_RET;

    IF P_COD_RET != '000000' THEN
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    END IF;
	
--SET DEBUG FILE TO 'sp_depura_creditos_cancelados.out';
--TRACE ON;

--    select fecha_hoy into vFecha
    --from bdicred:sd_fechas;

--temporal solo para pruebas
--LET vFecha = today; --mdy ('11','10','2013');
--temporal solo para pruebas

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraInicial from sysmaster:sysshmvals;

	LET sHoraInicial = SUBSTR(cHoraInicial,1,2);
	LET sMinutoInicial = SUBSTR(cHoraInicial,4,2);

-- ULTIMA CUENTA DEPURADA	
/*    SELECT num_credito
      INTO vNumCredAux
      FROM "informix".sd_param_movhis_dep
     WHERE proceso = 16;

    IF vNumCredAux IS NULL THEN 
       LET vNumCredAux = ""; 
       INSERT INTO "informix".sd_param_movhis_dep VALUES(16,'');
    END IF;
*/

-- ULTIMA FECHA DEPURACION CUENTAS CANCELADAS  FORMATO --> 12/31/2018
    SELECT valor::date
      INTO dFechaDepura
      FROM bdicred:sd_param
     WHERE cod_param = '113';

    IF dFechaDepura IS NULL THEN 
		INSERT INTO "informix".sd_param(empresa, cod_param, descripcion, valor, user_insert, fecha_insert) 
			VALUES('001', '113', 'ULTIMA FECHA DEPURACION CUENTAS CANCELADAS', '12/31/2019', user, TODAY);

		LET dFechaDepura = '12/31/2019';
/*		LET cCodRet = '100100';
        LET P_MENSAJE = 'No existe parÃ¡metro de fecha a depurar.';
        RETURN cCodRet,P_MENSAJE;*/
    END IF;

-- PARAMETRO DE HORAS A PROCESAR CUENTAS CANCELADAS      VALOR --> 5	
	SELECT valor::smallint
      INTO sHorasProceso
      FROM bdicred:sd_param
     WHERE cod_param = '114';

	 IF sHorasProceso IS NULL THEN 
		INSERT INTO "informix".sd_param(empresa, cod_param, descripcion, valor, user_insert, fecha_insert) 
			VALUES('001', '114', 'PARAMETRO DE HORAS A PROCESAR CUENTAS CANCELADAS', '5', user, TODAY);

		LET sHorasProceso = 5;
/*        LET cCodRet = '100200';
        LET P_MENSAJE = 'No existe parÃ¡metro de horas a procesar.';
        RETURN cCodRet,P_MENSAJE;*/
    END IF;
	 
/*    IF vNumCredAux = '' THEN
        execute PROCEDURE bdicred:monthadd(vFecha, -6) into dFechaDepura;

        let dFechaDepura = mdy(month(dFechaDepura),1,year(dFechaDepura)) - 1;

        UPDATE bdicred:sd_param
           SET valor = dFechaDepura
         WHERE cod_param = '113';
    END IF;
*/

--RETURN P_COD_RET,P_MENSAJE;

	SELECT a.num_credito,a.numcte
	FROM bdicred:sd_maecred a
	INNER JOIN bdicred:sd_maecredanexo b ON b.empresa = a.empresa AND b.num_credito = a.num_credito AND b.fecha_proceso <= dFechaDepura
	WHERE a.empresa='001'
--	AND num_credito > vNumCredAux
--and a.num_credito in (select num_credito from bdicred:sd_maecred_canceladas)
	AND a.status_cred NOT IN ('AA','BA','BT','E1','E2','E3')
	INTO TEMP cuentas_canceladas WITH NO LOG;
	
	UPDATE STATISTICS MEDIUM FOR TABLE cuentas_canceladas;
	
    FOREACH WITH HOLD

       SELECT TRIM(num_credito)
           INTO vNumCred 
           FROM cuentas_canceladas
       ORDER BY num_credito ASC

	   LET iCuentasProcesadas = iCuentasProcesadas + 1;
	   
        BEGIN WORK;
--sd_maecred
            insert into bdicred:sd_maecred_old
            select * from bdicred:sd_maecred
            where empresa = '001'
            and num_credito = vNumCred;

            delete from bdicred:sd_maecred
            where empresa = '001'
            and num_credito = vNumCred;
			
			LET iCount_sd_maecred_old	= iCount_sd_maecred_old + 1;

--sd_maecredanexo
            insert into bdicred:sd_maecredanexo_old
            select * from bdicred:sd_maecredanexo
            where empresa = '001'
            and num_credito = vNumCred;

            delete from bdicred:sd_maecredanexo
            where empresa = '001'
            and num_credito = vNumCred;
			
			LET iCount_sd_maecredanexo_old	= iCount_sd_maecredanexo_old + 1;

--sd_maesdos
            insert into bdicred:sd_maesdos_old
            select * from bdicred:sd_maesdos
            where empresa = '001'
            and num_credito = vNumCred;

            delete from bdicred:sd_maesdos
            where empresa = '001'
            and num_credito = vNumCred;

			LET iCount_sd_maesdos_old	= iCount_sd_maesdos_old + 1;
			
--sd_amortiza_credito
            insert into bdicred:sd_amortiza_credito_old
            select * from bdicred:sd_amortiza_credito
            where empresa = '001'
            and num_credito = vNumCred;

            delete from bdicred:sd_amortiza_credito
            where empresa = '001'
            and num_credito = vNumCred;

			LET iCount_sd_amortiza_credito_old	= iCount_sd_amortiza_credito_old + 1;

--sd_movhis
            insert into bdicred:sd_movhis_old
            select * from bdicred:sd_movhis
            where empresa = '001'
            and num_credito = vNumCred;

            delete from bdicred:sd_movhis
            where empresa = '001'
            and num_credito = vNumCred;

			LET iCount_sd_movhis_old	= iCount_sd_movhis_old + 1;
			
--sd_maesdoshist
            insert into bdicred:sd_maesdoshist_old
            select * from bdicred:sd_maesdoshist
            where empresa = '001'
            and num_credito = vNumCred;

            delete from bdicred:sd_maesdoshist
            where empresa = '001'
            and num_credito = vNumCred;

			LET iCount_sd_maesdoshist_old	= iCount_sd_maesdoshist_old + 1;
			
--sd_maesdoscont
            insert into bdicred:sd_maesdoscont_old
            select * from bdicred:sd_maesdoscont
            where empresa = '001'
            and num_credito = vNumCred;

            delete from bdicred:sd_maesdoscont
            where empresa = '001'
            and num_credito = vNumCred;

			LET iCount_sd_maesdoscont_old	= iCount_sd_maesdoscont_old + 1;

--sd_maecredcont
            insert into bdicred:sd_maecredcont_old
            select * from bdicred:sd_maecredcont
            where empresa = '001'
            and num_credito = vNumCred;

            delete from bdicred:sd_maecredcont
            where empresa = '001'
            and num_credito = vNumCred;

			LET iCount_sd_maecredcont_old	= iCount_sd_maecredcont_old + 1;

/*            UPDATE "informix".sd_param_movhis_dep
               SET num_credito = vNumCred
             WHERE proceso = 16;*/
        COMMIT WORK;  
        let iDepura = 0;

		SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraFinal from sysmaster:sysshmvals;

		LET	sHoraFinal = SUBSTR(cHoraFinal,1,2);
		LET	sMinutoFinal = SUBSTR(cHoraFinal,4,2);
		LET	sHoraFinal = sHoraFinal - sHoraInicial;

		IF sHoraFinal >= sHorasProceso AND sMinutoFinal > sMinutoInicial THEN
--			LET cTerminaProceso = '1';
			EXIT FOREACH;
		END IF;
	END FOREACH;

/*	IF cTerminaProceso = '0' THEN
		UPDATE "informix".sd_param_movhis_dep
		SET num_credito = ''
		WHERE proceso = 16;
	END IF;*/

	LET cMensaje = 'TOTAL Cuentas procesadas : ' ||iCuentasProcesadas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_maecred_old : ' ||iCount_sd_maecred_old;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = 'Cuentas respaldadas sd_maecredanexo_old : ' ||iCount_sd_maecredanexo_old;
	LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_maesdos_old : ' ||iCount_sd_maesdos_old;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = 'Cuentas respaldadas sd_amortiza_credito_old : ' ||iCount_sd_amortiza_credito_old;
	LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_movhis_old : ' ||iCount_sd_movhis_old;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = 'Cuentas respaldadas sd_maesdoshist_old : ' ||iCount_sd_maesdoshist_old;
	LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_maesdoscont_old : ' ||iCount_sd_maesdoscont_old;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = 'Cuentas respaldadas sd_maesdoscont_old : ' ||iCount_sd_maesdoscont_old;
--	LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_maesdoscont_old : ' ||iCount_sd_maesdoscont_old;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	
    CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '03') RETURNING P_COD_RET;

    IF P_COD_RET != '000000' THEN
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    END IF;

	LET P_MENSAJE = P_MENSAJE || ' ' || iCuentasProcesadas;
	
    RETURN cCodRet,P_MENSAJE;

    END
END PROCEDURE;