CREATE PROCEDURE "informix".sp_parametroscredito_pba (pEmpresa CHAR(3), pNumEmpleado CHAR(8))

RETURNING
        CHAR( 5) AS RETORNO,            -- CODIGO DE RETORNO
        CHAR( 2) AS LONGITUDCLIENTE,    -- LONGITUD DEL CLIENTE
        CHAR( 2) AS CODMONNAC,          -- CODIGO DE LA MONEDA NACIONAL
       CHAR(100) AS CODPATHREP,         -- VALOR PATH DEL REPORTE
        CHAR(45) AS NOMUSUARIO,         -- NOMBRE DEL USUARIO
        CHAR(30) AS NOMEMPRESA,         -- NOMBRE DE LA EMPRESA   
            DATE AS FECHAHOY,           -- FECHA HOY
        CHAR( 2) AS SISTEMA,            -- CODIGO DEL SISTEMA
        CHAR(11) AS LONGITUDCTA,        -- LONGITUD DE LA CUENTA
            DATE AS FECHAANT,           -- FECHA ANTERIOR
            DATE AS PROXFECHA,          -- FECHA PROXIMA
            DATE AS PRIDIAMES,          -- PRIMER DIA DEL MES
            DATE AS PRIMHABMES,         -- PRIMER DIA HABIL MES
            DATE AS ULTDIAMES,          -- ULTIMO DIA DEL MES
            DATE AS ULTHABMES;          -- ULTIMO DIA HABIL DEL MES
    
  --DECLARACION DE VARIABLES
    DEFINE iSqlErr              INTEGER;
    DEFINE cCodRet              CHAR(5);
    DEFINE cLongitudCliente     CHAR(2);
    DEFINE cCodMonNac           CHAR(2);
    DEFINE cPathRep             CHAR(100);
    DEFINE cNombreUsuario       CHAR(45);
    DEFINE cNombreEmpresa       CHAR(30);
    DEFINE dFecha_Hoy           DATE;
    DEFINE cSistema             CHAR(2);
    DEFINE cLongCta             CHAR(11);
    DEFINE dFecha_ant           DATE;
    DEFINE dProx_fecha          DATE;
    DEFINE dPri_dia_mes         DATE;
    DEFINE dPri_hab_mes         DATE;
    DEFINE dUlt_dia_mes         DATE;
    DEFINE dUlt_hab_mes         DATE;
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
  --INICIALIZAR VARIABLES
    LET cCodRet 		  	= '00000';
    LET cLongitudCliente	= '';
    LET cCodMonNac			= '';
    LET cPathRep			= '';
    LET cNombreUsuario		= '';
    LET cNombreEmpresa 		= '';
    LET dFecha_Hoy 			= DATE(1);
    LET cSistema 			= '';
    LET cLongCta			= '';
    LET dFecha_ant			= DATE(1);
    LET dProx_fecha 		= DATE(1);
    LET dPri_dia_mes		= DATE(1);
    LET dPri_hab_mes		= DATE(1);
    LET dUlt_dia_mes		= DATE(1);
    LET dUlt_hab_mes		= DATE(1);
    
    --SET DEBUG FILE TO "/home/sysifx/vlv/sp_parametroscredito.out";
	--TRACE ON;
    
BEGIN
	  --CREA EL CONTROL DE ERRORES
        ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN TRIM(cCodRet), TRIM(NVL(cLongitudCliente, '')), TRIM(NVL(cCodMonNac, '')), TRIM(NVL(cPathRep, '')), 
					   TRIM(NVL(cNombreUsuario, '')), TRIM(NVL(cNombreEmpresa, '')), NVL(dFecha_Hoy, DATE(1)), 
					   TRIM(NVL(cSistema, '')), cLongCta, NVL(dFecha_ant, DATE(1)), NVL(dProx_fecha, DATE(1)), 
					   NVL(dPri_dia_mes, DATE(1)), NVL(dPri_hab_mes, DATE(1)), NVL(dUlt_dia_mes, DATE(1)), NVL(dUlt_hab_mes, DATE(1));
			END IF;
		END EXCEPTION;        
	
	IF pEmpresa = '' AND pNumEmpleado = '' THEN
		LET cCodRet = '00001'; -- FALTAN PARAMETROS PARA SU EJECUCION.
		RETURN cCodRet, TRIM(cLongitudCliente), TRIM(cCodMonNac), TRIM(cPathRep), TRIM(cNombreUsuario), TRIM(cNombreEmpresa), 
			   dFecha_Hoy, TRIM(cSistema), TRIM(cLongCta), dFecha_ant, dProx_fecha, dPri_dia_mes, dPri_hab_mes, dUlt_dia_mes, 
			   dUlt_hab_mes;
	END IF
	
    -- OBTENGO EL VALOR LONGITUD DEL NUMERO DE CLIENTE		
	SELECT TRIM(valor)
	INTO cLongitudCliente 
	FROM bdinteg:"informix".si_param 
	WHERE empresa = pEmpresa AND descripcion = ('longitud cliente'); 
	
	IF cLongitudCliente IS NULL THEN
		LET cLongitudCliente = '';
	END IF
	
    -- OBTENGO EL VALOR CODIGO DE LA MONEDA NACIONAL
	SELECT TRIM(valor)
	INTO cCodMonNac 
	FROM bdinteg:"informix".si_param 
	WHERE empresa = pEmpresa AND descripcion = ('codigo mn');
	
	IF cCodMonNac IS NULL THEN
	   LET cCodMonNac = '';
	END IF
	
    -- OBTENGO EL VALOR PATH DE REPORTES
	SELECT NVL(TRIM(valor), '')
    INTO cPathRep
	FROM bdicred:"informix".sd_param 
	WHERE empresa = pEmpresa AND cod_param = '50';
	
	IF cPathRep IS NULL THEN
  	   LET cPathRep = '';
	END IF
	
	-- OBTENGO EL NOMBRE DEL USUARIO O EJECUTIVO
	SELECT NVL(nombre, '')
	INTO cNombreUsuario
	FROM bdinteg:"informix".si_ejecut
	WHERE ejecutivo = pNumEmpleado;
	
	IF cNombreUsuario IS NULL THEN
	   LET cNombreUsuario = '';
	END IF
	
    -- OBTENGO EL NOMBRE DE LA EMPRESA
	SELECT NVL(razon_social, '')
	INTO cNombreEmpresa
	FROM bdinteg:"informix".si_empresas 
	WHERE empresa = pEmpresa;
	
	IF cNombreEmpresa IS NULL THEN
		LET cNombreEmpresa = '';
	END IF
    
	-- OBTIENE EL VALOR DE LA LONGITUD DE LA CUENTA.
	SELECT TRIM(NVL(valor, ''))
	INTO cLongCta
	FROM bdicred:"informix".sd_param 
	WHERE cod_param = '8';
	
	IF cLongCta IS NULL THEN
		LET cLongCta = '';
	END IF
	
    -- OBTENGO FECHA DE CREDITO PARA LA CAPTURA DE PARAMETROS
	SELECT fecha_hoy, fecha_ant, prox_fecha, pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes  
	INTO dFecha_Hoy, dFecha_ant, dProx_fecha, dPri_dia_mes, dPri_hab_mes, dUlt_dia_mes, dUlt_hab_mes
	FROM bdicred:"informix".sd_fechas;
	
	IF dFecha_Hoy IS NULL THEN
		LET dFecha_Hoy   = DATE(1);
		LET dFecha_ant   = DATE(1);
		LET dProx_fecha  = DATE(1);
		LET dPri_dia_mes = DATE(1);
		LET dPri_hab_mes = DATE(1);
		LET dUlt_dia_mes = DATE(1);
		LET dUlt_hab_mes = DATE(1);
	END IF
	
    -- OBTENGO CODIGO DEL SISTEMA
	SELECT TRIM(NVL(sistema, ''))
	INTO cSistema
	FROM bdinteg:"informix".si_sistema 
	WHERE siglas = 'SD';
	
	IF cSistema IS NULL THEN
		LET cSistema = '';
	END IF
	
	RETURN cCodRet, TRIM(cLongitudCliente), TRIM(cCodMonNac), TRIM(cPathRep), TRIM(cNombreUsuario), TRIM(cNombreEmpresa), 
		   dFecha_Hoy, TRIM(cSistema), TRIM(cLongCta), dFecha_ant, dProx_fecha, dPri_dia_mes, dPri_hab_mes, dUlt_dia_mes,
		   dUlt_hab_mes;	
END
END PROCEDURE
DOCUMENT
'CREACION     : VALENTIN LÓPEZ VALENZUELA',
'DESCRIPCION  : OBTIENE PARAMETROS BASICOS PARA EL FUNCIONAMIENTO DEL MODULO DE CREDITO CON REGLAS DE PROGRAMACION',
'FECHA    	  : NOVIEMBRE 2010',
'BASE DE DATOS: BDICRED',
'VERSION  	  : 20111130.1529';

CREATE PROCEDURE "informix".sp_carga_ctes_dirty_behavior(pEmpresa CHAR(3))

RETURNING 
          CHAR(06) AS resultado,    CHAR(80) AS mensaje;


DEFINE vproceso         CHAR(4);
DEFINE cCod_RetIB       CHAR(6);
DEFINE dFechaHoy        DATE;
DEFINE dFechaAumLinCrd  DATE;
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cRutaArch        CHAR(100);
DEFINE cParamNomArch    CHAR(100);
DEFINE cNomArchivo      CHAR(150);
DEFINE cNomArchEjecSql  CHAR(100);
DEFINE cSQL             CHAR(1500);


--SET DEBUG FILE TO "sp_carga_ctes_dirty_behavior.out";
--TRACE ON;

LET vproceso        = '0502';
LET cCod_RetIB      = '000000';
LET dFechaHoy       = DATE(0); 
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = '000000';
LET cMensajeRet     = 'PROCESO EXITOSO';    
LET cRutaArch       = '';
LET cNomArchivo     = '';
LET cNomArchEjecSql = '';
LET cSQL            = '';


BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        LET cCodRet = iSqlErr;
        LET cMensajeRet = cErrorInfo;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, trim(cMensajeRet) || "-" || iIsamErr::CHAR, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 10;

    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '01') Returning cCod_RetIB;

    IF ( NVL(pEmpresa,"") = "" ) THEN
        LET cCodRet= '102005'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    SELECT fecha_hoy INTO dFechaHoy FROM bdicred:sd_fechas WHERE empresa = pempresa;
    IF ( dFechaHoy IS NULL ) THEN
        LET cCodRet= '20013'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    SELECT fecha_hoy INTO dFechaAumLinCrd FROM bdicred:"informix".sd_fechas_aumlincred  WHERE empresa = pEmpresa;
    IF dFechaAumLinCrd IS NULL OR dFechaAumLinCrd = date(1) OR dFechaAumLinCrd = date(0) THEN
        LET dFechaAumLinCrd = dFechaHoy;
    END IF

    SELECT trim(valor) INTO cParamNomArch FROM bdicred:sd_param WHERE cod_param = 102;
    IF ( NVL(cParamNomArch, "") = "" ) THEN
        LET cCodRet= '104006';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT trim(valor) INTO cRutaArch  FROM bdicred:sd_param WHERE cod_param = 103;
    IF ( NVL(cRutaArch, "") = "" ) THEN
        LET cCodRet = '104005';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;

    LET cNomArchivo = trim(cParamNomArch) || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
    LET cNomArchEjecSql = 'Carga_Ctes_Dirty_Incr_lcr.sql';
    
    -- Realiza carga de archivo.
    LET cSQL = '';
    LET cSQL = ' echo " CREATE TEMP TABLE cred_tmp_behavior (num_credito CHAR(20), score CHAR(4)); '
            || ' LOAD FROM ' || TRIM(cRutaArch) || TRIM(cNomArchivo) 
            || ' INSERT INTO cred_tmp_behavior; '
            || ' INSERT INTO bdicred:sd_clientes_dirty_behavior ( fecha_reporte, num_credito,  score ) '
            || ' SELECT ''' || dFechaAumLinCrd || ''', num_credito, score FROM cred_tmp_behavior;  ">' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql); 
    SYSTEM cSQL;

    LET cSQL = 'dbaccess bdicred ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '03') Returning cCod_RetIB;

    RETURN cCodRet,cMensajeRet;

END
END PROCEDURE;