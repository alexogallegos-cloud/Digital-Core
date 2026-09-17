CREATE PROCEDURE "informix".sp_consulta_solicitudes_pbas2( pInstitucion CHAR(2),precuperacion INT)
RETURNING   CHAR(5) AS codret,
			CHAR(2) AS institucion,
			CHAR(20) AS numcte,
			CHAR(20) AS num_solicitud,
			CHAR(255) AS envio,
			CHAR(255) AS envio1,
			CHAR(255) AS envio2,
			CHAR(1) AS status;
			
	--Declaraciones   Generales
	DEFINE inicio INTEGER;
	DEFINE cCodret CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE iNoRegistros INTEGER;
	DEFINE cInstitucion CHAR(2);
	DEFINE cNumcte CHAR(20);
	DEFINE cNum_solicitud CHAR(20) ;
	DEFINE cEnvio CHAR(255);
	DEFINE cEnvio1 CHAR(255);
	DEFINE cEenvio2 CHAR(255); 
	DEFINE cStatus CHAR(1) ;
	
	
	LET inicio ='';
	LET cCodret ='';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET cInstitucion ='';
	LET cNumcte ='';
	LET cNum_solicitud ='' ;
	LET cEnvio ='';
	LET cEnvio1 ='';
	LET cEenvio2 =''; 
	LET cStatus ='';
    
	BEGIN	
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodret,cInstitucion, cNumcte, cNum_solicitud,cEnvio,cEnvio1,cEenvio2,cStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/Respaldos/ipcb/tasf/sp_consulta_solicitudes.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ; 
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			select first precuperacion institucion,numcte,num_solicitud, envio, envio1, envio2, status 
			into cInstitucion, cNumcte, cNum_solicitud,cEnvio,cEnvio1,cEenvio2,cStatus
			from bdiburo:br_traslado where  institucion = pInstitucion and status ='0' and fecha_insert = today
			
			
			update bdiburo:br_traslado  set status = '1' where num_solicitud = cNum_solicitud
			and  institucion = pInstitucion  and  status ='0'; 
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodret,cInstitucion, cNumcte, cNum_solicitud,cEnvio,cEnvio1,cEenvio2,cStatus WITH RESUME;	
			
		END FOREACH;	
		
		IF iNoRegistros = 0  THEN
				LET cCodRet = '00017';
				RETURN cCodret,cInstitucion, cNumcte, cNum_solicitud,cEnvio,cEnvio1,cEenvio2,cStatus;
		END IF;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez',
'FECHA:14/06/2016',
'MODULO: Demonio  ',
'FUNCIONALIDAD: Consulta de solicitudes Enviadas a BC y CC',
'DESCRIPCION: Consulta de solicitudes Enviadas a Buro y Circulo de Credito.',
'BD: bdiburo';

CREATE PROCEDURE "informix".sp_ctes_activ_rep_buro_cred(pEmpresa CHAR(3))

RETURNING 
          CHAR(06) AS resultado,    CHAR(80) AS mensaje;

-- Marzo 2013. RQM 09 309 - Reporte para credito.  Reporte de clientes activos reportados a Buro de Credito.

DEFINE vproceso         CHAR(4);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cMensajeRet      CHAR(80);
DEFINE cCodRet          CHAR(6); 
DEFINE cCod_RetIB       CHAR(6);
DEFINE dFechaHoy        DATE;
DEFINE cRutaArch        CHAR(100);
DEFINE cNomArchivo      CHAR(100);
DEFINE cNomArch         CHAR(100);
DEFINE cNomArch1        CHAR(100);
DEFINE cNomArchEjecSql  CHAR(100);
DEFINE cSQL             CHAR(8204);
DEFINE cSQL1            CHAR(500);
DEFINE cSQL2            CHAR(6204);
DEFINE cSQL3            CHAR(100);


--SET DEBUG FILE TO "/informix/mahr/sp_ctes_activ_rep_buro_cred.out";
--TRACE ON;

LET vproceso        = '0503';
LET cCod_RetIB      = '000000';
LET dFechaHoy       = DATE(0); 
LET cMensajeRet     = 'PROCESO EXITOSO';    
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = '000000';
LET cRutaArch       = '';
LET cNomArchivo     = '';
LET cNomArch        = '';
LET cNomArch1       = '';
LET cNomArchEjecSql = '';
LET cSQL            = '';
LET cSQL1           = '';
LET cSQL2           = '';
LET cSQL3           = '';


BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        LET cCodRet = iSqlErr;
        LET cMensajeRet = cErrorInfo;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, trim(cMensajeRet)||'-'|| iIsamErr::CHAR, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 10;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '01') Returning cCod_RetIB;

    IF ( NVL(pEmpresa,"") = "" ) THEN
        LET cCodRet= '102005'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, trim(cMensajeRet)||'-'|| iIsamErr::CHAR, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    SELECT fecha_hoy INTO dFechaHoy FROM bdicred:sd_fechas WHERE empresa = pempresa;
    IF ( dFechaHoy IS NULL ) THEN
        LET cCodRet= '20013'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, trim(cMensajeRet)||'-'|| iIsamErr::CHAR, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    -- Ruta destino del archivo
    SELECT valor INTO cRutaArch FROM bdicred:sd_param WHERE empresa = pempresa AND cod_param = '103';
	IF NVL (cRutaArch,'') = '' THEN
        LET cCodRet = '104005';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, trim(cMensajeRet)||'-'|| iIsamErr::CHAR, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- Nombre de Archivo
    SELECT valor INTO cNomArch FROM bdicred:sd_param WHERE empresa = pempresa AND cod_param = '104';
	IF NVL (cNomArch,'') = '' THEN
        LET cCodRet= '104006';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensajeRet)||'-'|| iIsamErr::CHAR, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    -- Asigna nombre del archivo.
    LET cNomArchEjecSql = 'SQL_rep_Ctes_activ_rep_buro.sql';
    LET cNomArch1 =  TRIM(cNomArch) || '_Aux_' || lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
    LET cNomArchivo  =  TRIM(cNomArch) || lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';

    LET cSQL = '';
	LET cSQL = ' echo "Numero Credito;Numero Tarjeta;Fecha reporto a Buro de Credito; "> ' || TRIM(cRutaArch) || TRIM(cNomArch1);
	SYSTEM cSQL;

	LET cSQL1 = '';
    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; ';
    LET cSQL2 = ''; 
    -- Genera consulta con registros reportados a Buro de Crédito en Cred_rep_buro y se elimina los registros que se encuentran en 
    -- bdiburo:br_burofisicas_concilia. Son aquellos que no se envian a buro por error en la información.
    LET cSQL2 =  " SELECT bur.num_credito, NVL(tar.num_tarjeta,'0') num_tarjeta, bur.fecha_reporte FROM bdiburo:br_burofisicas_describe bur "
            || " LEFT OUTER JOIN bdicred:sd_tarjeta tar ON (bur.num_credito = tar.num_credito and tar.tipo_tarjeta = 'T' "
            || " and tar.secuencia = (select max(secuencia) from bdicred:sd_tarjeta where empresa = '001' and bur.num_credito = num_credito " 
            || " and tipo_tarjeta = 'T')) WHERE clave_obs != 'UP' "
            || " INTO TEMP Cred_rep_buro WITH NO LOG; CREATE INDEX inx_cred_increm on Cred_rep_buro (num_credito); "
            || " UPDATE STATISTICS medium FOR TABLE Cred_rep_buro; "
            || " UNLOAD TO " || TRIM(cRutaArch) || TRIM(cNomArch1) || " DELIMITER " || '''|'''
            || " SELECT * FROM Cred_rep_buro; ";

    LET cSQL3 =   '">' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    LET cSQL = trim(cSQL1) || cSQL2 || cSQL3;
    SYSTEM cSQL;

    LET cSQL = 'chmod 777 '|| TRIM(cRutaArch)|| TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = 'dbaccess bdiburo ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = '';
    LET cSQL = "sed 's/|$//g' "|| TRIM(cRutaArch) || TRIM(cNomArch1) || " >> " || TRIM(cRutaArch) || TRIM(cNomArchivo);
    SYSTEM cSQL;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cRutaArch) || TRIM(cNomArch1) || ' ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '03') Returning cCod_RetIB;
    RETURN cCodRet,cMensajeRet;

END
END PROCEDURE;