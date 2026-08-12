CREATE PROCEDURE "informix".sp_inserta_bitacora_pba(pempresa CHAR(3), pproceso CHAR(4),pCod_ret CHAR(6)
                                                             ,pMensaje CHAR(150), p_tipoejecucion CHAR(2)) 
       RETURNING char(6);

--declaracion de variables
------------------------------------------------------------
DEFINE iSql_err 		  INTEGER;
DEFINE cError_info		  CHAR(150);
DEFINE iIsamErr           INTEGER;
DEFINE cMensaje 		  CHAR(80);
DEFINE cCod_ret           CHAR(6);
DEFINE dDia               DATE;
DEFINE cHora              CHAR(8);


--SET DEBUG FILE TO '/respaldosbd/Malena/sp_inserta_bitacora.out';
--TRACE ON;

      LET cCod_ret      = '000000';
	  LET iSql_err      = 0;
	  LET iIsamErr      = 0;
	  LET cError_info   = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
    
    
 
BEGIN
        ON EXCEPTION SET iSql_err, iIsamErr, cError_info
            LET cCod_ret = iSql_err;
            LET cMensaje = cError_info;
            RETURN cCod_ret;
        END EXCEPTION;
				
		SET LOCK MODE TO WAIT 3;

        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO dDia FROM sysmaster:sysshmvals;
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHora FROM sysmaster:sysshmvals;

        IF (p_tipoejecucion = '01') THEN
			--Se inserta registro de inicio de la ejecucion de proceso
            INSERT INTO bdicred:"informix".sd_bitacora_mec(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
            VALUES(pempresa, pproceso, today, '000000', 'PROCESO INICIALIZADO', user, dDia, cHora);
                
        ELIF (p_tipoejecucion = '02') THEN
			--Se inserta registro para el caso de que ocurra algun error
            INSERT INTO bdicred:"informix".sd_bitacora_mec(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
            VALUES(pempresa, pproceso, today, pCod_ret, pMensaje, user, dDia, cHora);
    
        ELIF (p_tipoejecucion = '03') THEN
			--Se inserta registro de fin de ejecucion de proceso
            INSERT INTO bdicred:"informix".sd_bitacora_mec(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
            VALUES(pempresa, pproceso, today, '000000', 'PROCESO FINALIZADO', user, dDia,  cHora);

        END IF;

    RETURN cCod_ret;
    END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento espejo para llevar un registro de inicio y fin en la ejecucion de procesos así como en caso de que ocurra algun error.',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 15/JULIO/2011',
'BD: BDICRED',
'VERSION:20110715.1805';

CREATE PROCEDURE "informix".sp_guardaresburooc(pNumcte CHAR(20), pNumsol CHAR(20), pTipo CHAR(2))
returning CHAR(5) AS CodigoRetorno;

--DECLARACION DE VARIABLES
DEFINE cCodret  CHAR(5);
DEFINE iSqlErr 	INTEGER;
DEFINE cDescripcion CHAR(50);

--INICIALIZACION DE VARIABLES
LET cCodret = '00000';
LET iSqlErr = 0;
LET cDescripcion = ''; 

	--SET DEBUG FILE TO '/tmp/bernardo/prueba/sp_guardaresburooc.out';
	--TRACE ON;


BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
            LET cCodret = iSqlErr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  

	IF nvl(pNumcte,'') = '' OR LEN(TRIM(pNumcte)) > 9 THEN 
		LET cCodret = '00001'; --Parametro pNumcte vacio o numero de solicitud mayor 9.
	ELIF NVL(pNumsol,'') = '' OR LEN(TRIM(pNumsol)) > 14 THEN
		LET cCodret = '00002'; --Parametro pNumsol vacio o numero de solicitud mayor a 14.
	ELIF NVL(pTipo,'') = '' OR LEN(TRIM(pTipo)) > 1 THEN
		LET cCodret = '00003'; --Parametro pTipo vacio o tipo de error mayor a 1.
	ELSE  
		IF pTipo = '0' THEN
			LET cDescripcion = 'Normal';
		ELIF pTipo = '1' THEN
			LET cDescripcion = 'Malos antecedentes en SIC';
		ELIF pTipo = '2' THEN
			LET cDescripcion = 'Capacidad de Pago Saturada (CPS)';
		ELIF pTipo = '3' THEN
			LET cDescripcion = 'Atraso en Coppel';
		ELIF pTipo = '4' THEN
			LET cDescripcion = 'Biometricos';
		ELIF pTipo = '5' THEN
			LET cDescripcion = 'Otro';
		END IF;
		
		INSERT INTO bdicred:catalogo_errores_buro_oc (empresa, numcte, numsol, tipo_respuesta, descripcion) 
		VALUES ('001', pNumcte, pNumsol, pTipo, cDescripcion);
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodret = '00004'; --No inserto en la tabla.
		END IF;
	END IF;
	
	return cCodret;
END;
END PROCEDURE;