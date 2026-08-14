CREATE PROCEDURE "informix".sp_depura_sol2()
RETURNING CHAR(6), VARCHAR(70,1);

DEFINE cCodRet      	CHAR(6); 
DEFINE vNumCred     	VARCHAR(20,1);
DEFINE vNumCredAux  	VARCHAR(20,1);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr     	INTEGER;
DEFINE Error_Info   	VARCHAR(40);
DEFINE fFecha       	DATE;
DEFINE cProceso			CHAR(04);
DEFINE iSolProcesadas   INTEGER;
DEFINE cMensaje			VARCHAR(70,1);
DEFINE P_COD_RET    	VARCHAR(6);
DEFINE P_MENSAJE    	VARCHAR(150);
DEFINE cHoraInicial		CHAR(8);
DEFINE cHoraFinal		CHAR(8);
DEFINE sHoraInicial		SMALLINT;
DEFINE sHoraFinal		SMALLINT;
DEFINE sMinutoInicial	SMALLINT;
DEFINE sMinutoFinal		SMALLINT;
DEFINE sHorasProceso	SMALLINT;
DEFINE cTerminaProceso	CHAR(1);
DEFINE cStatus 			CHAR(2);
DEFINE cNumcte          CHAR(20);
DEFINE sCommit          SMALLINT;

-- Variable con fecha de solicitud mas antigua a depurar--
DEFINE fFecha_min		DATE;

-----Variables contador------------
DEFINE iMaxCommit INTEGER;
DEFINE iContador  INTEGER;

LET cCodRet      	= '000000';
LET iSqlErr      	= 0;
LET iIsamErr     	= 0;
LET Error_Info	 	= '';
LET vNumCred     	= '';
LET vNumCredAux  	= '';
LET fFecha       	= date(1);
LET cProceso	 	= '0013';
LET iSolProcesadas  = 0;
LET cMensaje	 	= 'PROCESO EXITOSO.';
LET P_COD_RET    	= '';
LET P_MENSAJE    	= '';
LET cHoraInicial	= '';
LET cHoraFinal		= '';
LET sHoraInicial	= 0;
LET sHoraFinal		= 0;
LET sMinutoInicial	= 0;
LET sMinutoFinal	= 0;
LET sHorasProceso	= 0;
LET cTerminaProceso = '0';
LET cStatus 		= '';
LET cNumcte 		= '';
LET sCommit 		= 0;

-- Variable con fecha de solicitud mas antigua a depurar--
LET fFecha_min		= date(1);

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

--   SET DEBUG FILE TO '/home/c90077639/depura_2025/depuracion_cursor/sp_depura_sd_movhis2.out';
--   TRACE ON;

	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '01') RETURNING P_COD_RET;

	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraInicial FROM sysmaster:sysshmvals;

	LET sHoraInicial = SUBSTR(cHoraInicial,1,2);
	LET sMinutoInicial = SUBSTR(cHoraInicial,4,2);

    SELECT num_credito
			INTO vNumCredAux
    FROM bdicred:"informix".sd_param_movhis_dep
			where proceso = 19;

    IF vNumCredAux IS NULL THEN 
       LET vNumCredAux = ""; 
       INSERT INTO bdicred:"informix".sd_param_movhis_dep VALUES(19,vNumCredAux);
    END IF;

    SELECT valor--::date
      INTO fFecha
    FROM bdicred:sd_param
		WHERE empresa = '001' AND cod_param = '802'; 
	
	IF fFecha IS NULL THEN 
		LET fFecha = MDY(12, 31, 2023);
			INSERT INTO bdicred:sd_param VALUES
			('001','802','FECHA DEPURA SOL 2','12-31-2023',user,today);
    END IF;
		
	---Se declara parametro con fecha de dos anos atras
	LET fFecha_min = fFecha - 2 UNITS YEAR;

	
	SELECT valor::SMALLINT
		INTO sHorasProceso
	FROM bdicred:sd_param
		WHERE cod_param = '137';

	IF sHorasProceso IS NULL THEN 
		LET sHorasProceso = 1;				
			INSERT INTO bdicred:sd_param VALUES
			('001','137','Horas a procesar sp_depura_sol2',sHorasProceso,user,today);
    END IF;
	
	-- Se agrega ciclo while para validar que el parametro fFecha sea mayor o igual a fFecha_min y de esta manera poder realizar la depuracion por lapsos de tiempo
	WHILE fFecha >= fFecha_min
	
		FOREACH -- Se ajusta foreach 
		
			SELECT num_solicitud, numcte INTO vNumCred, cNumcte
				FROM bdisolic:"informix".ss_solicitudes
					WHERE fecha_insert <= fFecha_min 
					AND empresa = '001'
					AND status_solicitud IN ('PC','AN','CM','CN') 

					
			---Se agrega contador para que realice la depuracion cada 1000 solicitudes
			IF iContador = 0 THEN
				BEGIN WORK;
			END IF;
					
			LET iContador = iContador + 1;
			LET iSolProcesadas = iSolProcesadas + 1;
				
			--
			INSERT INTO bdisolic:ss_detalle_scoring_resp_2021
			SELECT * FROM bdisolic:ss_detalle_scoring
			WHERE num_solicitud = vNumCred;
			
			DELETE FROM bdisolic:ss_detalle_scoring
			WHERE num_solicitud = vNumCred;
			
			--
			INSERT INTO bdisolic:ss_autorizacion_resp_2021
			SELECT * FROM bdisolic:ss_autorizacion
			WHERE empresa = '001' AND num_solicitud = vNumCred;
			
			DELETE FROM bdisolic:ss_autorizacion
			WHERE empresa = '001' AND num_solicitud = vNumCred;
			
			--
			INSERT INTO bdisolic:ss_detalle_modelo_resp_2021
			SELECT * FROM bdisolic:ss_detalle_modelo
			WHERE empresa = '001' AND num_solicitud = vNumCred;
			
			DELETE FROM bdisolic:ss_detalle_modelo
			WHERE empresa = '001' AND num_solicitud = vNumCred;
			
			----------NUEVAS TABLAS A DEPURAR----------
			INSERT INTO bdisolic:ss_revision_determinacion_resp_2021
			SELECT * FROM bdisolic:ss_revision_determinacion
			WHERE empresa = '001' AND num_solicitud = vNumCred;
			
			DELETE FROM bdisolic:ss_revision_determinacion
			WHERE empresa = '001' AND num_solicitud = vNumCred;
			
			--
			INSERT INTO bdisolic:ss_resum_scor_fin_resp_2021
			SELECT * FROM bdisolic:ss_resum_scor_fin
			WHERE empresa = '001' AND num_solicitud = vNumCred;
			
			DELETE FROM bdisolic:ss_resum_scor_fin
			WHERE empresa = '001' AND num_solicitud = vNumCred;
			
			--
			INSERT INTO bdisolic:ss_solicitudes_sic_resp_2021
			SELECT * FROM bdisolic:ss_solicitudes_sic
			WHERE numcte = cNumcte AND num_solicitud = vNumCred;
			
			DELETE FROM bdisolic:ss_solicitudes_sic
			WHERE numcte = cNumcte AND num_solicitud = vNumCred;
			
			--
			INSERT INTO bdisolic:ss_autorizacion_especial_resp_2021
			SELECT * FROM bdisolic:ss_autorizacion_especial
			WHERE num_solicitud = vNumCred;
			
			DELETE FROM bdisolic:ss_autorizacion_especial
			WHERE num_solicitud = vNumCred;
			
			--
			INSERT INTO bdisolic:ss_solicitudes_cac_resp_2021
			SELECT * FROM bdisolic:ss_solicitudes_cac
			WHERE empresa = '001' AND num_solicitud = vNumCred;
			
			DELETE FROM bdisolic:ss_solicitudes_cac
			WHERE empresa = '001' AND num_solicitud = vNumCred;
			
			--
			INSERT INTO bdisolic:ss_refpersonales_resp_2021
			SELECT * FROM bdisolic:ss_refpersonales
			WHERE num_solicitud = vNumCred;
			
			DELETE FROM bdisolic:ss_refpersonales
			WHERE num_solicitud = vNumCred;
			
			--
			INSERT INTO bdisolic:ss_solicitudes_resp_2021
			SELECT * FROM bdisolic:ss_solicitudes
			WHERE empresa = '001' AND num_solicitud = vNumCred;
			
			--Cursor elimina registro actual de la tabla
			DELETE FROM bdisolic:ss_solicitudes WHERE num_solicitud = vNumCred;
			
			--CURRENT OF cursor_depura;
			
			UPDATE bdicred:sd_param_movhis_dep
			SET num_credito = vNumCred
			WHERE proceso = 19; 
		
			SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND 
					INTO cHoraFinal from sysmaster:sysshmvals;
		
			LET	sHoraFinal = SUBSTR(cHoraFinal,1,2);
			LET	sMinutoFinal = SUBSTR(cHoraFinal,4,2);
			LET	sHoraFinal = sHoraFinal - sHoraInicial;
		
			IF iContador = iMaxCommit THEN
				COMMIT WORK;
				LET iContador = 0;
			END IF;
			
		END FOREACH;
	
		IF iContador > 0 THEN
			COMMIT WORK;
			LET iContador = 0;
		END IF;
		
		--Se agrega actualizacion de fFecha_min
		LET fFecha_min = LAST_DAY(fFecha_min + 1 units MONTH)::DATE;
		UPDATE bdicred:sd_param SET valor = fFecha_min WHERE empresa = '001' AND cod_param = 'FCN';
	
	END WHILE;
	
	IF cTerminaProceso = '0' THEN
		UPDATE bdicred:sd_param_movhis_dep
		SET num_credito = ''
		WHERE proceso = 19;
	END IF;

	LET cMensaje = 'TOTAL solicitudes procesadas: ' ||  iSolProcesadas;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '03') RETURNING P_COD_RET;

	LET cMensaje = 'PROCESO EXITOSO.';
	LET cMensaje = cMensaje || ' Se procesaron -> ' || iSolProcesadas || ' solicitudes.';

    RETURN cCodRet, cMensaje;

    END
END PROCEDURE
