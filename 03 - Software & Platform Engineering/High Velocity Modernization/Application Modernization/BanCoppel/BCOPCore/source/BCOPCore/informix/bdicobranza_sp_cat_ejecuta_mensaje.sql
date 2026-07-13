CREATE PROCEDURE "informix".sp_cat_ejecuta_mensaje(pTramaXML CHAR(3000))
RETURNING CHAR(6) AS COD_RET, CHAR(7500) AS TRAMA;
-- VARIABLES GENERALES
DEFINE iSqlErr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE error_info CHAR(80);
DEFINE cCodRet CHAR(6);
DEFINE cMensaje VARCHAR(80);
DEFINE iNumFilas INTEGER;
DEFINE cEmpresa CHAR(3);
DEFINE cNomMensaje CHAR(50);
DEFINE cRegistraBit CHAR(1);
DEFINE cValorCampo VARCHAR(255);
DEFINE cTramaEntrada LVARCHAR(2040);
DEFINE cEncabezadoEnt LVARCHAR(2040);
DEFINE sPosInicial SMALLINT;
DEFINE sPosFinal SMALLINT;
DEFINE pEmpresa CHAR(3);
DEFINE pOrigen SMALLINT;
DEFINE pEjecutivo CHAR(8);    
DEFINE pNumMensaje CHAR(5);
DEFINE iPosicion INTEGER;
DEFINE iPosicionTotal INTEGER;
DEFINE cCodRetVTD CHAR(6);
DEFINE cResultadoVTD CHAR(1);
DEFINE cCMParametro VARCHAR(33);
DEFINE cCMAbre VARCHAR(33);
DEFINE cCMCierra VARCHAR(33);
DEFINE cCMTipoDeDato VARCHAR(10);
DEFINE cCMLongitud VARCHAR(5);
DEFINE i INTEGER;
DEFINE cDescErrorCtrl VARCHAR(80);
DEFINE iParteEntera INTEGER;
DEFINE iParteDecimal INTEGER;
DEFINE cCodRetIB CHAR(6);
DEFINE cNumProceso CHAR(4);
DEFINE sTipoAccesso SMALLINT;
DEFINE cBand1 CHAR(1);
DEFINE cTipoCobranza CHAR(1);
-- DECLARACION DE VARIABLES GENERICAS USADAS EN LOS PARAMETROS DE ENTRADA DEL SP A EJECUTAAR
DEFINE cVAR_E1 VARCHAR(255);
DEFINE cVAR_E2 VARCHAR(255);
DEFINE cVAR_E3 VARCHAR(255);
DEFINE cVAR_E4 VARCHAR(255);
DEFINE cVAR_E5 VARCHAR(255);
DEFINE cVAR_E6 VARCHAR(255);
DEFINE cVAR_E7 VARCHAR(255);
DEFINE cVAR_E8 VARCHAR(255);
DEFINE cVAR_E9 VARCHAR(255);
DEFINE cVAR_E10 VARCHAR(255);
DEFINE cVAR_E11 VARCHAR(255);
DEFINE cVAR_E12 VARCHAR(255);
DEFINE cVAR_E13 VARCHAR(255);
DEFINE cVAR_E14 VARCHAR(255);
DEFINE cVAR_E15 VARCHAR(255);
DEFINE cVAR_E16 VARCHAR(255);
-- DECLARACION DE VARIABLES GENERICAS USADAS EN LOS PARAMETROS DE SALIDA DEL SP A EJECUTAR
DEFINE cVAR_S1 LVARCHAR(300);
DEFINE cVAR_S2 LVARCHAR(300);
DEFINE cVAR_S3 LVARCHAR(300);
DEFINE cVAR_S4 LVARCHAR(300);
DEFINE cVAR_S5 LVARCHAR(300);
DEFINE cVAR_S6 LVARCHAR(300);
DEFINE cVAR_S7 LVARCHAR(300);
DEFINE cVAR_S8 LVARCHAR(300);
DEFINE cVAR_S9 LVARCHAR(300);
DEFINE cVAR_S10 LVARCHAR(300);
DEFINE cVAR_S11 LVARCHAR(300);
DEFINE cVAR_S12 LVARCHAR(300);
DEFINE cVAR_S13 LVARCHAR(300);
DEFINE cVAR_S14 LVARCHAR(300);
DEFINE cVAR_S15 LVARCHAR(300);
DEFINE cVAR_S16 LVARCHAR(300);
DEFINE cVAR_S17 LVARCHAR(300);
DEFINE cVAR_S18 LVARCHAR(300);
DEFINE cVAR_S19 LVARCHAR(300);
DEFINE cVAR_S20 LVARCHAR(300);
DEFINE cVAR_S21 LVARCHAR(300);
DEFINE cVAR_S22 LVARCHAR(300);
DEFINE cVAR_S23 LVARCHAR(300);
DEFINE cVAR_S24 LVARCHAR(300);
DEFINE cVAR_S25 LVARCHAR(300);
DEFINE cVAR_S26 LVARCHAR(300);
DEFINE cVAR_S27 LVARCHAR(300);
DEFINE cVAR_S28 LVARCHAR(300);
DEFINE cVAR_S29 LVARCHAR(300);
DEFINE cVAR_S30 LVARCHAR(300);
DEFINE cVAR_S31 LVARCHAR(300);
DEFINE cVAR_S32 LVARCHAR(300);
DEFINE cVAR_S33 LVARCHAR(300);
DEFINE cVAR_S34 LVARCHAR(300);
DEFINE cVAR_S35 LVARCHAR(300);
DEFINE cVAR_S36 LVARCHAR(300);
DEFINE cVAR_S37 LVARCHAR(300);
DEFINE cVAR_S38 LVARCHAR(300);
-- VARIABLES PARA EL ARMADO DE LA CADENA DE SALIDA
DEFINE cEncabezadoSal LVARCHAR(512);
DEFINE cNomServicioSal VARCHAR(255);
DEFINE cCuerpoSal LVARCHAR(7290);
DEFINE cColaSal VARCHAR(255);
DEFINE cSalida LVARCHAR(7500); 
-- VARIABLES GENERALES
LET iSqlErr = 0;
LET iIsamErr = 0;
LET cCodRet = "000000";
LET cMensaje = 'PROCESO EXITOSO';
LET iNumFilas = 0;
LET cEmpresa = "";
LET cNomMensaje = "";
LET cRegistraBit = "";
LET cSalida = "";
LET cValorCampo = "";
LET cTramaEntrada = "";
LET cEncabezadoEnt = "";
LET sPosInicial = 0;
LET sPosFinal = 0;
LET pEmpresa = "";
LET pOrigen = 0;
LET pEjecutivo = "";
LET pNumMensaje = "00000";
LET iPosicion = 0;
LET iPosicionTotal = 0;
LET cCodRetVTD = "";
LET cResultadoVTD = "";
LET cCMParametro = "";
LET cCMAbre = "";
LET cCMCierra = "";
LET cCMTipoDeDato = "";
LET cCMLongitud = "";
LET i = 0;
LET cDescErrorCtrl = "";
LET iParteEntera = 0;
LET iParteDecimal = 0;
LET cCodRetIB = "000000";
LET cNumProceso = "";
LET sTipoAccesso = "";
LET cBand1 = "F";
LET cTipoCobranza = "";
-- INICIALIZACION DE VARIABLES GENERICAS USADAS EN LOS PARAMETROS DE ENTRADA
LET cVAR_E1 = "";
LET cVAR_E2 = "";
LET cVAR_E3 = "";
LET cVAR_E4 = "";
LET cVAR_E5 = "";
LET cVAR_E6 = "";
LET cVAR_E7 = "";
LET cVAR_E8 = "";
LET cVAR_E9 = "";
LET cVAR_E10 = "";    
LET cVAR_E11 = "";
LET cVAR_E12 = "";
LET cVAR_E13 = "";
LET cVAR_E14 = "";
LET cVAR_E15 = "";
LET cVAR_E16 = "";
-- INICIALIZACION DE VARIABLES UTILIZADAS EN LAS SALIDAS DE LOS SPS
LET cVAR_S1 = "";
LET cVAR_S2 = "";
LET cVAR_S3 = "";
LET cVAR_S4 = "";
LET cVAR_S5 = "";
LET cVAR_S6 = "";
LET cVAR_S7 = "";
LET cVAR_S8 = "";
LET cVAR_S9 = "";
LET cVAR_S10 = "";
LET cVAR_S11 = "";
LET cVAR_S12 = "";
LET cVAR_S13 = "";
LET cVAR_S14 = "";
LET cVAR_S15 = "";
LET cVAR_S16 = "";
LET cVAR_S17 = "";
LET cVAR_S18 = "";
LET cVAR_S19 = "";
LET cVAR_S20 = "";
LET cVAR_S21 = "";
LET cVAR_S22 = "";
LET cVAR_S23 = "";
LET cVAR_S24 = "";
LET cVAR_S25 = "";
LET cVAR_S26 = "";
LET cVAR_S27 = "";
LET cVAR_S28 = "";
LET cVAR_S29 = "";
LET cVAR_S30 = "";
LET cVAR_S31 = "";
LET cVAR_S32 = "";
LET cVAR_S33 = "";
LET cVAR_S34 = "";
LET cVAR_S35 = "";
LET cVAR_S36 = "";
LET cVAR_S37 = "";
LET cVAR_S38 = "";
-- VARIABLES PARA EL ARMADO DE LA CADENA DE SALIDA
LET cEncabezadoSal = "";
LET cNomServicioSal = "";
LET cCuerpoSal = "";
LET cColaSal = "";
LET cSalida = "";
BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, error_info
    IF iSqlErr != 0 THEN
        LET cCodRet = iSqlErr;
        LET cMensaje = error_info;
        LET cEncabezadoSal = '<?xml version="1.0" encoding="utf-8" ?>';
        LET cNomServicioSal = '<MensajeDeError xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
        LET cEncabezadoSal = cEncabezadoSal || cNomServicioSal;
        LET cMensaje = "Informix:" || iSqlErr || ":" || SUBSTR(cMensaje,1,LENGTH(cMensaje));
        LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(cMensaje, "error");
        LET cColaSal = "</MensajeDeError>";
        LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
        LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
      RETURN cCodRet, cSalida;
    END IF;
END EXCEPTION;

-- DIRECTIVA PARA CONSULTAR UNA TABLA AUNQUE ESTE BLOQEUADA
SET ISOLATION TO DIRTY READ;
-- DIRECTIVA PARA EXTENDER EL ACCESO A TRES SEGUNDOS
SET LOCK MODE TO WAIT 3;
--SET DEBUG FILE TO "/home/sysifx/hassan/sp_cat_ejecuta_mensaje.out";
--TRACE ON;   
-- SE FORMA LA TRAMA DEL FORMATO XML DE ERROR DE SALIDA
LET cEncabezadoSal = '<?xml version="1.0" encoding="utf-8" ?>';
LET cNomServicioSal = '<MensajeDeError xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
LET cEncabezadoSal = cEncabezadoSal || cNomServicioSal;
LET cColaSal = "</MensajeDeError>";

LET cTramaEntrada = pTramaXML;
LET cTramaEntrada = SUBSTR(cTramaEntrada,1,LENGTH(cTramaEntrada));
-- VALIDACION QUE LOS PARAMETROS DE ENTRADA NO ESTEN VACIOS
IF NVL(cTramaEntrada,"") = "" THEN
    LET cCodRet = "106001";
    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE codigo_error = cCodRet;
    LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,cCodRet), "error");
    LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
    LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
    RETURN cCodRet, cSalida;
END IF
-- BUSCA LA POSICION DONDE INICIAN LOS PARAMETROS DEL SP QUE SE QUIERE EJECUTAR
FOREACH
    EXECUTE PROCEDURE bdicobranza: "informix".sp_obtenerposicion (cTramaEntrada,"<parametros>")
    INTO iPosicion, iPosicionTotal
    IF iPosicion = -1 THEN
        LET  cCodRet = "106002";
        SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE codigo_error = cCodRet;
        LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,cCodRet), "error");
        LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
        LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
        RETURN cCodRet, cSalida;
    END IF
    EXIT FOREACH;
END FOREACH
-- OBTIENE LOS PARAMETROS QUE RECIBE EL PRINCIPAL DE sp_cat_ejecuta_mensaje
LET cEncabezadoEnt = SUBSTR(cTramaEntrada,1,iPosicion - 1);
-- OBTIENE LOS PARAMETROS QUE RECIBE EL PROCEDIMIENTO QUE SE VA A MANDAR LLAMAR
LET cTramaEntrada = SUBSTR(cTramaEntrada,iPosicion);
-- ////////////-- ////// *INICIA* VALIDACIONES DEL SEGMENTO DE PARAMETROS QUE SOLO PERTENECEN AL sp_cat_ejecuta_mensaje  //////-- //////-- 
-- BUSCA LA POSICION INICIAL DEL ORIGEN
FOREACH
    EXECUTE PROCEDURE bdicobranza: "informix".sp_obtenerposicion (cEncabezadoEnt,"<origen>")
    INTO iPosicion, iPosicionTotal
    IF iPosicion = -1 THEN
        LET  cCodRet = "106002";
        SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE codigo_error = cCodRet;
        LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
        LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
        LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
        RETURN cCodRet, cSalida;
    END IF
    EXIT FOREACH;
END FOREACH
LET sPosInicial = iPosicionTotal + 1;
-- BUSCA LA POSICION FINAL DE LA ORIGEN
FOREACH
    EXECUTE PROCEDURE bdicobranza: "informix".sp_obtenerposicion (cEncabezadoEnt,"</origen>")
    INTO iPosicion, iPosicionTotal
    IF iPosicion = -1 THEN
        LET  cCodRet = "106002";
        SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE codigo_error = cCodRet;
        LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
        LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
        LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
        RETURN cCodRet, cSalida;
    END IF
    EXIT FOREACH;
END FOREACH
LET sPosFinal = iPosicion;
LET sPosInicial = sPosInicial;
-- OBTIENE EL VALOR DEL ORIGEN
LET cValorCampo = SUBSTR(cEncabezadoEnt,sPosInicial,(sPosFinal - sPosInicial));
IF NVL(cValorCampo,"") = "" THEN
    -- VALIDA QUE EL ORIGEN NO ESTE VACIO
    LET cCodRet = "106004";
    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE codigo_error = cCodRet;
    LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
    LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
    LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
    RETURN cCodRet, cSalida;
END IF
EXECUTE PROCEDURE bdicobranza: "informix".sp_ValidarTipoDatos("E", cValorCampo, 0, 0)
INTO cCodRetVTD, cResultadoVTD;
-- VERIFICA QUE SE HAYA EJECUTADO CORRECTAMENTE EL sp_ValidarTipoDatos
IF cCodRetVTD::INTEGER <> 0 THEN
    -- ERROR EN EL sp_ValidarTipoDatos
    LET cCodRet = "106005";
    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE codigo_error = cCodRet;
    LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
    LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
    LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
    RETURN cCodRet, cSalida;
ELIF cResultadoVTD = "F" THEN
    -- VALIDA QUE EL VALOR DEL ORIGEN NO ES UN NUMERO ENTERO
    LET cCodRet = "106006";
    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores  WHERE codigo_error = cCodRet;
    LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
    LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
    LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
    RETURN cCodRet, cSalida;
ELSE
    LET pOrigen = cValorCampo;
END IF
-- BUSCA LA POSICION INICIAL DE LA EMPRESA
FOREACH
    EXECUTE PROCEDURE bdicobranza: "informix".sp_obtenerposicion (cEncabezadoEnt,"<empresa>")
    INTO iPosicion, iPosicionTotal
    IF iPosicion = -1 THEN
        LET  cCodRet = "106002";
        SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
        LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,cCodRet), "error");
        LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
        LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
        RETURN cCodRet, cSalida;
    END IF
    EXIT FOREACH;
END FOREACH
LET sPosInicial = iPosicionTotal + 1;
-- BUSCA LA POSICION FINAL DE LA EMPRESA
FOREACH
    EXECUTE PROCEDURE bdicobranza:"informix".sp_obtenerposicion (cEncabezadoEnt,"</empresa>")
    INTO iPosicion, iPosicionTotal
    IF iPosicion = -1 THEN
        LET  cCodRet = "106002";
        SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion)  INTO cDescErrorCtrl FROM cb_errores
        WHERE origen = pOrigen AND codigo_error = cCodRet;
        LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,cCodRet), "error");
        LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
        LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
        RETURN cCodRet, cSalida;
    END IF
    EXIT FOREACH;
END FOREACH
LET sPosFinal = iPosicion;
-- OBTIENE EL VALOR DE LA EMPRESA
LET pEmpresa = SUBSTR(cEncabezadoEnt,sPosInicial,(sPosFinal - sPosInicial));
SELECT {+INDEX(bdinteg:si_empresas idx_si_empresas)} empresa INTO cEmpresa FROM bdinteg:si_empresas WHERE empresa = pEmpresa;
-- VALIDA QUE LA EMPRESA EXISTA EN EL CATALOGO DE EMPRESAS
IF NVL(cEmpresa,"") = "" THEN
    LET  cCodRet = "106003";
    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
    LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
    LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
    LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
    RETURN cCodRet, cSalida;
END IF;    
-- BUSCA LA POSICION INICIAL DEL NUM_MENSAJE
FOREACH
    EXECUTE PROCEDURE bdicobranza: "informix".sp_obtenerposicion (cEncabezadoEnt,"<num_mensaje>")
    INTO iPosicion, iPosicionTotal
    IF iPosicion = -1 THEN
        LET  cCodRet = "106002";
        SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores  WHERE origen = pOrigen AND codigo_error = cCodRet;
        LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
        LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
        LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
        RETURN cCodRet, cSalida;
    END IF
    EXIT FOREACH;
END FOREACH
LET sPosInicial = iPosicionTotal + 1;
-- BUSCA LA POSICION FINAL DEL NUM_MENSAJE
FOREACH
    EXECUTE PROCEDURE bdicobranza: "informix".sp_obtenerposicion (cEncabezadoEnt,"</num_mensaje>")
    INTO iPosicion, iPosicionTotal
    IF iPosicion = -1 THEN
        LET  cCodRet = "106002"; 
        SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
        LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
        LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
        LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
        RETURN cCodRet, cSalida;
    END IF
    EXIT FOREACH;
END FOREACH
LET sPosFinal = iPosicion;
-- OBTIENE EL VALOR DEL NUM_MENSAJE
LET pNumMensaje = SUBSTR(cEncabezadoEnt,sPosInicial,(sPosFinal - sPosInicial));
-- BUSCA LA POSICION INICIAL DEL TIPO DE COBRANZA
FOREACH
    EXECUTE PROCEDURE bdicobranza: "informix".sp_obtenerposicion (cEncabezadoEnt,"<tipo_cobranza>")
    INTO iPosicion, iPosicionTotal
    IF iPosicion = -1 THEN
        LET  cCodRet = "106002";
        SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores  WHERE origen = pOrigen AND codigo_error = cCodRet;
        LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
        LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
        LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
        RETURN cCodRet, cSalida;
    END IF
    EXIT FOREACH;
END FOREACH
LET sPosInicial = iPosicionTotal + 1;
-- BUSCA LA POSICION FINAL DEL TIPO DE COBRANZA
FOREACH
    EXECUTE PROCEDURE bdicobranza:"informix".sp_obtenerposicion (cEncabezadoEnt,"</tipo_cobranza>")
    INTO iPosicion, iPosicionTotal
    IF iPosicion = -1 THEN
        LET  cCodRet = "106002"; 
        SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
        LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
        LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
        LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
        RETURN cCodRet, cSalida;
    END IF
    EXIT FOREACH;
END FOREACH
LET sPosFinal = iPosicion;
-- OBTIENE EL VALOR DEL TIPO DE COBRANZA
LET cTipoCobranza = SUBSTR(cEncabezadoEnt,sPosInicial,(sPosFinal - sPosInicial));
-- OBTIENE EL NOMBRE DEL SP A EJECUTAR
SELECT {+INDEX(cb_cat_mensaje idx_pk_cb_cat_mensaje)} TRIM(funcion), registra_bitacora, tipo_acceso INTO cNomMensaje, cRegistraBit, sTipoAccesso 
FROM cb_cat_mensaje WHERE sistema = "4" AND cve_mensaje = pNumMensaje;
-- VALIDA LA CLAVE DE MENSAJE EXISTA EN EL CATALOGO
IF NVL(cNomMensaje,"") = "" THEN
    LET cCodRet = "106007";
    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
    LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
    LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
    LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
    RETURN cCodRet, cSalida;
END IF
-- BUSCA LA POSICION INICIAL DEL EMPLEADO
FOREACH
    EXECUTE PROCEDURE bdicobranza: "informix".sp_obtenerposicion (cEncabezadoEnt,"<num_empleado>")
    INTO iPosicion, iPosicionTotal
    IF iPosicion = -1 THEN
        LET  cCodRet = "106002";
        SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores  WHERE origen = pOrigen AND codigo_error = cCodRet;
        LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
        LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
        LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
        RETURN cCodRet, cSalida;
    END IF
    EXIT FOREACH;
END FOREACH
LET sPosInicial = iPosicionTotal + 1;
-- BUSCA LA POSICION FINAL DEL EMPLEADO
FOREACH
EXECUTE PROCEDURE bdicobranza: "informix".sp_obtenerposicion (cEncabezadoEnt,"</num_empleado>")
    INTO iPosicion, iPosicionTotal
    IF iPosicion = -1 THEN
        LET  cCodRet = "106002";
        SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
        LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
        LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
        LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
        RETURN cCodRet, cSalida;
    END IF
    EXIT FOREACH;
END FOREACH
LET sPosFinal = iPosicion;
-- OBTIENE EL VALOR DEL EMPLEADO
LET pEjecutivo = SUBSTR(cEncabezadoEnt,sPosInicial,(sPosFinal - sPosInicial));
-- VALIDACION PARA QUE EL EJECUTIVO EXISTA MEDIANTE EL STATUS Y EL TIPO DE ACCESSO, 1 = MODO CONSUNLTA, 2 = MODO REGISTRO
IF NOT EXISTS (SELECT {+INDEX(cb_cat_acceso_ejecutivo idx_pk_cb_cat_acceso_ejecutivo)} ejecutivo FROM cb_cat_acceso_ejecutivo WHERE tipo_cobranza = cTipoCobranza AND ejecutivo = pEjecutivo AND status_ejecutivo = "AC" AND tipo_acceso = sTipoAccesso) THEN
    -- VALIDA SI ES TIPO DE ACCESSO DE MODO CONSULTA
    IF sTipoAccesso = 1 THEN
        LET cCodRet = "106018";
        SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
        LET cDescErrorCtrl = cDescErrorCtrl || " ejecutivo" || pEjecutivo;
        LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
        LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
        LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
        RETURN cCodRet, cSalida;
    -- VALIDA SI EL TIPO DE ACCESSO ES MODO REGISTRO
    ELIF sTipoAccesso = 2 THEN
        LET cBand1 = "T";
    END IF
END IF
-- ////////////-- ////// *TERMINA* VALIDACIONES DEL SEGMENTO DE PARAMETROS QUE SOLO PERTENECEN AL sp_cat_ejecuta_mensaje  //////-- //////-- 
-- ////////////-- ////// *INICIA* VALIDACIONES DEL SEGMENTO DE PARAMETROS QUE SOLO PERTENECEN AL PROCEDIMIENTO QUE SE VA A MANDAR LLAMAR  //////-- //////-- 
-- BUSCA LA POSICION INICIAL DEL CAMPO PARAMETROS
FOREACH
    EXECUTE PROCEDURE bdicobranza: "informix".sp_obtenerposicion (cTramaEntrada,"<parametros>")
    INTO iPosicion, iPosicionTotal
    IF iPosicion = -1 THEN
        LET  cCodRet = "106002";
        SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
        LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
        LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
        LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
        RETURN cCodRet, cSalida;
    END IF
    EXIT FOREACH;
END FOREACH
LET sPosInicial = iPosicion;    
-- OBTIENE LA TRAMA DE LOS PARAMETROS EN ADELANTE
LET cTramaEntrada = SUBSTR(cTramaEntrada,sPosInicial);    
LET i = 1;
-- CICLO PARA OBTENER LOS PARAMETROS  DE ENTRADA Y VALIDAR SU TIPO DE DATO
FOREACH
    SELECT TRIM(parametro), TRIM(tipodato), TRIM(longitud) INTO cCMParametro, cCMTipoDeDato, cCMLongitud 
    FROM bdicobranza: cb_cat_configura_mensaje WHERE sistema = "4" AND cve_mensaje = pNumMensaje AND tipo_parametro = "E"
    ORDER BY secuencia    
    LET cCMAbre = "<" || cCMParametro || ">";
    -- BUSCA LA POSICION INICIAL DEL CAMPO EN LOS PARAMETROS
    FOREACH
        EXECUTE PROCEDURE bdicobranza: "informix".sp_obtenerposicion (cTramaEntrada,cCMAbre)
        INTO iPosicion, iPosicionTotal
        IF iPosicion = -1 THEN
            -- VALIDA QUE EL NOMBRE DEL PARAMETRO QUE ESTA CONFIGURADO PARA EL SP SE ENCUENTRE EN LAS ETIQUETAS DEL CODIGO XML
            LET cCodRet = "106002";
            SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
            LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
            LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
            LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));                
            RETURN cCodRet, cSalida;
        END IF
        EXIT FOREACH;
    END FOREACH
    LET sPosInicial = iPosicionTotal + 1;
    LET cCMCierra = "</" || cCMParametro || ">";
    -- BUSCA LA POSICION FINAL DEL CAMPO EN LOS PARAMETROS
    FOREACH
        EXECUTE PROCEDURE bdicobranza: "informix".sp_obtenerposicion (cTramaEntrada,cCMCierra)
        INTO iPosicion, iPosicionTotal
        EXIT FOREACH;
    END FOREACH
    LET sPosFinal = iPosicion;
    LET cCMTipoDeDato = LOWER(cCMTipoDeDato);
    -- OBTIENE EL VALOR DEL CAMPO
    LET cValorCampo = SUBSTR(cTramaEntrada,sPosInicial,(sPosFinal - sPosInicial));
    IF TRIM(cValorCampo) <> "" THEN
        IF cCMTipoDeDato = "integer" THEN
            EXECUTE PROCEDURE bdicobranza: "informix".sp_ValidarTipoDatos("E", cValorCampo, 0, 0)
            INTO cCodRetVTD, cResultadoVTD;
            IF cCodRetVTD::INTEGER <> 0 THEN
                LET cCodRet = "106005";
                SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
                LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
                LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
                LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
                RETURN cCodRet, cSalida;
            END IF
            IF cResultadoVTD = "F" THEN
                LET cCodRet = "106006";
                SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
                LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
                LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
                LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
                RETURN cCodRet, cSalida;
            END IF
        ELIF cCMTipoDeDato = "smallint" THEN
            EXECUTE PROCEDURE bdicobranza: "informix".sp_ValidarTipoDatos("EC", cValorCampo, 0, 0)
            INTO cCodRetVTD, cResultadoVTD;
            IF cCodRetVTD::INTEGER <> 0 THEN
                LET cCodRet = "106005";
                SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
                LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
                LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
                LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
                RETURN cCodRet, cSalida;
            END IF
            IF cResultadoVTD = "F" THEN
                LET cCodRet = "106006";
                SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
                LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
                LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
                LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
                RETURN cCodRet, cSalida;
            END IF  
        ELIF cCMTipoDeDato = "decimal" THEN        
            -- BUSCA LA POSICION DONDE SE ENCUENTRA LA COMA, LA CUAL CUMPLE CON LA FUNCION DE SEPARADOR DEL FORMATO DECIMAL
            FOREACH
                EXECUTE PROCEDURE bdicobranza: "informix".sp_obtenerposicion (cCMLongitud,",")
                INTO iPosicion, iPosicionTotal
                EXIT FOREACH;
            END FOREACH
            LET iParteEntera = SUBSTR(cCMLongitud,1,iPosicion - 1)::INTEGER;
            LET iParteDecimal = SUBSTR(cCMLongitud,iPosicion + 1)::INTEGER;
            EXECUTE PROCEDURE bdicobranza: "informix".sp_ValidarTipoDatos("D", cValorCampo, iParteEntera, iParteDecimal)
            INTO cCodRetVTD, cResultadoVTD;
            IF cCodRetVTD::INTEGER <> 0 THEN
                LET cCodRet = "106005";
                SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
                LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
                LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
                LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
                RETURN cCodRet, cSalida;
            END IF
            IF cResultadoVTD = "F" THEN
                LET cCodRet = "106006";
                SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
                LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
                LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
                LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
                RETURN cCodRet, cSalida;
            END IF          
        ELIF cCMTipoDeDato = "date" THEN
            EXECUTE PROCEDURE bdicobranza: "informix".sp_ValidarTipoDatos("F1", cValorCampo, 0, 0)
            INTO cCodRetVTD, cResultadoVTD;
            IF cCodRetVTD::INTEGER <> 0 THEN
                LET cCodRet = "106005";
                SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
                LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
                LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
                LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
                RETURN cCodRet, cSalida;
            END IF
            IF cResultadoVTD = "F" THEN
                LET cCodRet = "106006";
                SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores 
                WHERE origen = pOrigen AND codigo_error = cCodRet;
                LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
                LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
                LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
                RETURN cCodRet, cSalida;
            END IF  
        ELIF cCMTipoDeDato = "datetime" THEN
            EXECUTE PROCEDURE bdicobranza: "informix".sp_ValidarTipoDatos("F2", cValorCampo, cCMLongitud::SMALLINT, 0)
            INTO cCodRetVTD, cResultadoVTD;
            IF cCodRetVTD::INTEGER <> 0 THEN
                LET cCodRet = "106005";
            SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
            LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
                LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
            LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
                RETURN cCodRet, cSalida;
            END IF
            IF cResultadoVTD = "F" THEN
                LET cCodRet = "106006";
                SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores 
                WHERE origen = pOrigen AND codigo_error = cCodRet;
                LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
                LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
                LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
                RETURN cCodRet, cSalida;
            END IF  
        END IF
    ELSE
        LET cValorCampo = "";
    END IF
    IF i = 1 THEN LET cVAR_E1 = cValorCampo; ELIF i = 2 THEN LET cVAR_E2 = cValorCampo; ELIF i = 3 THEN LET cVAR_E3 = cValorCampo;
    ELIF i = 4 THEN LET cVAR_E4 = cValorCampo; ELIF i = 5 THEN LET cVAR_E5 = cValorCampo; ELIF i = 6 THEN LET cVAR_E6 = cValorCampo;
    ELIF i = 7 THEN LET cVAR_E7 = cValorCampo; ELIF i = 8 THEN LET cVAR_E8 = cValorCampo; ELIF i = 9 THEN LET cVAR_E9 = cValorCampo;
    ELIF i = 10 THEN LET cVAR_E10 = cValorCampo; ELIF i = 11 THEN LET cVAR_E11 = cValorCampo; ELIF i = 12 THEN LET cVAR_E12 = cValorCampo;
    ELIF i = 13 THEN LET cVAR_E13 = cValorCampo; ELIF i = 14 THEN LET cVAR_E14 = cValorCampo; ELIF i = 15 THEN LET cVAR_E15 = cValorCampo;
    ELIF i = 16 THEN LET cVAR_E16 = cValorCampo; END IF
    LET i = i + 1;
END FOREACH
-- VALIDA SI LA CLAVE MENSAJE NO EXISTE EN EL CATALOGO DE CONFIGURACION DE MENSAJES
LET iNumFilas = dbinfo("sqlca.sqlerrd2");
IF iNumFilas = 0 THEN
    LET cCodRet = "106009";
    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
    LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
    LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
    LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
    RETURN cCodRet, cSalida;
END IF
-- OBTIENE EL NUMERO DE PROCESO QUE CORRESPONDE A LA CLAVE DEL MENSAJE
LET cNumProceso = DECODE(pNumMensaje,"10001","0020","10002","0021","10003","0022","10004","0023","10005","0024","10006","0025","100007","0026","10008","0027");
-- ////////////-- ////// *TERMINA* VALIDACIONES DEL SEGMENTO DE PARAMETROS QUE SOLO PERTENECEN AL PROCEDIMIENTO QUE SE VA A MANDAR LLAMAR  //////-- //////-- 
-- ////////////-- ////// *INICIA* VALIDACIONES DEL SEGMENTO DONDE SE ARMA EL CUERPO DEL XML DE SALIDA  //////-- //////-- 
IF cRegistraBit = "S" THEN
    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cNumProceso,"","","01")
    INTO cCodRetIB;
    IF cCodRetIB::INTEGER <> 0 THEN
        LET cCodRet = "106010";
        SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores 
        WHERE origen = pOrigen AND codigo_error = cCodRet;
        LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
        LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
        LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
        RETURN cCodRet, cSalida;
    END IF
END IF
IF pNumMensaje = "10001" THEN  
    FOREACH
        EXECUTE PROCEDURE bdicobranza: "informix".sp_cat_consulta_saldostc(cVAR_E1,cVAR_E2,cVAR_E3)
        INTO cVAR_S1,cVAR_S2,cVAR_S3,cVAR_S4,cVAR_S5,cVAR_S6,cVAR_S7,cVAR_S8,cVAR_S9,cVAR_S10,cVAR_S11,cVAR_S12,cVAR_S13,cVAR_S14,cVAR_S15,cVAR_S16
        IF cVAR_S1::INTEGER <> 0 THEN
            IF cRegistraBit = "S" THEN                                
                IF cVAR_S1::INTEGER > 0 THEN
                    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cVAR_S1;
                END IF                
                EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cNumProceso,cVAR_S1,NVL(cDescErrorCtrl,""),"02")
                INTO cCodRetIB;
                IF cCodRetIB::INTEGER <> 0 THEN
                    LET cCodRet = "106010";
                    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
                    LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
                    LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
                    LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
                    RETURN cCodRet, cSalida;
                END IF
            END IF
            LET cCodRet = "106008";
            SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
            LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
            LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
            LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
            RETURN cCodRet, cSalida;
        END IF
        -- SE QUITAN LOS ESPACIOS QUE PUEDIERAN ESTAR A LA DERECHA
        LET cVAR_S1 = SUBSTR(cVAR_S1,1,LENGTH(cVAR_S1));LET cVAR_S2 = SUBSTR(cVAR_S2,1,LENGTH(cVAR_S2));LET cVAR_S3 = SUBSTR(cVAR_S3,1,LENGTH(cVAR_S3));LET cVAR_S4 = SUBSTR(cVAR_S4,1,LENGTH(cVAR_S4));
        LET cVAR_S5 = SUBSTR(cVAR_S5,1,LENGTH(cVAR_S5));LET cVAR_S6 = SUBSTR(cVAR_S6,1,LENGTH(cVAR_S6));LET cVAR_S7 = SUBSTR(cVAR_S7,1,LENGTH(cVAR_S7));LET cVAR_S8 = SUBSTR(cVAR_S8,1,LENGTH(cVAR_S8));
        LET cVAR_S9 = SUBSTR(cVAR_S9,1,LENGTH(cVAR_S9));LET cVAR_S10 = SUBSTR(cVAR_S10,1,LENGTH(cVAR_S10));LET cVAR_S11 = SUBSTR(cVAR_S11,1,LENGTH(cVAR_S11));LET cVAR_S12 = SUBSTR(cVAR_S12,1,LENGTH(cVAR_S12));
        LET cVAR_S13 = SUBSTR(cVAR_S13,1,LENGTH(cVAR_S13));LET cVAR_S14 = SUBSTR(cVAR_S14,1,LENGTH(cVAR_S14));LET cVAR_S15 = SUBSTR(cVAR_S15,1,LENGTH(cVAR_S15));LET cVAR_S16 = SUBSTR(cVAR_S16,1,LENGTH(cVAR_S16));
        -- SE ARMA EL ENCABEZADO
        LET cEncabezadoSal = '<?xml version="1.0" encoding="utf-8" ?>';
        LET cNomServicioSal = '<ConsultaDeCuentas_Respuesta xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://cobtelbancoppel.coppel.com">';
        LET cEncabezadoSal = cEncabezadoSal || cNomServicioSal;
        LET cColaSal = "</ConsultaDeCuentas_Respuesta>";
        -- COMIENZA EL CUERPO DE LOS PARAMETROS
        LET cCuerpoSal = "<parametros>";
        LET cCMParametro = "";
        LET i = 1;
        FOREACH
            SELECT TRIM(parametro) INTO cCMParametro FROM bdicobranza: cb_cat_configura_mensaje WHERE sistema = "4" AND cve_mensaje = pNumMensaje AND tipo_parametro = "S" ORDER BY secuencia
            LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(DECODE(i,1,cVAR_S1,2,cVAR_S2,3,cVAR_S3,4,cVAR_S4,5,cVAR_S5,6,cVAR_S6,7,cVAR_S7,8,cVAR_S8,9,cVAR_S9,10,cVAR_S10,11,cVAR_S11,12,cVAR_S12,13,cVAR_S13,14,cVAR_S14,15,cVAR_S15,16,cVAR_S16), cCMParametro);
            LET i = i + 1;
        END FOREACH
        LET cCuerpoSal = cCuerpoSal || "</parametros>";
    END FOREACH
ELIF pNumMensaje = "10002" THEN
    FOREACH
        EXECUTE PROCEDURE bdicobranza: "informix".sp_cat_consulta_ultimo_convenio(cVAR_E1,cVAR_E2)
        INTO cVAR_S1,cVAR_S2,cVAR_S3,cVAR_S4,cVAR_S5,cVAR_S6,cVAR_S7,cVAR_S8
        IF cVAR_S1::INTEGER <> 0 THEN
            IF cRegistraBit = "S" THEN                                
                IF cVAR_S1::INTEGER > 0 THEN
                    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cVAR_S1;
                END IF                
                EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cNumProceso,cVAR_S1,NVL(cDescErrorCtrl,""),"02")
                INTO cCodRetIB;
                IF cCodRetIB::INTEGER <> 0 THEN
                    LET cCodRet = "106010";
                    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
                    LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
                    LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
                    LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
                    RETURN cCodRet, cSalida;
                END IF
            END IF
            LET cCodRet = "106011";
            SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;                
            LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
            LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
            LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
            RETURN cCodRet, cSalida;
        END IF
        -- SE ARMA EL ENCABEZADO
        LET cEncabezadoSal = '<?xml version="1.0" encoding="utf-8" ?>';
        LET cNomServicioSal = '<ConsultaDeConvenios_Respuesta xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://cobtelbancoppel.coppel.com">';
        LET cEncabezadoSal = cEncabezadoSal || cNomServicioSal;
        LET cColaSal = "</ConsultaDeConvenios_Respuesta>";
        -- COMIENZA EL CUERPO DE LOS PARAMETROS
        LET cCuerpoSal = "<parametros>";
        LET cCMParametro = "";
        LET i = 1;
        FOREACH
            SELECT TRIM(parametro) INTO cCMParametro FROM bdicobranza: cb_cat_configura_mensaje WHERE sistema = "4" AND cve_mensaje = pNumMensaje AND tipo_parametro = "S" ORDER BY secuencia
            LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(DECODE(i,1,cVAR_S1,2,cVAR_S2,3,cVAR_S3,4,cVAR_S4,5,cVAR_S5,6,cVAR_S6,7,cVAR_S7,8,cVAR_S8), cCMParametro);
            LET i = i + 1;
        END FOREACH
        LET cCuerpoSal = cCuerpoSal || "</parametros>";
    END FOREACH
ELIF pNumMensaje = "10003" THEN
    FOREACH
        EXECUTE PROCEDURE bdicobranza: "informix".sp_cat_consulta_pagos_tc(cVAR_E1,cVAR_E2,cVAR_E3)
        INTO cVAR_S1,cVAR_S2,cVAR_S3,cVAR_S4,cVAR_S5
        IF cVAR_S1::INTEGER <> 0 THEN
            IF cRegistraBit = "S" THEN                                
                IF cVAR_S1::INTEGER > 0 THEN
                    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cVAR_S1;
                END IF                
                EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cNumProceso,cVAR_S1,NVL(cDescErrorCtrl,""),"02")
                INTO cCodRetIB;
                IF cCodRetIB::INTEGER <> 0 THEN
                    LET cCodRet = "106010";
                    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
                    LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
                    LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
                    LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
                    RETURN cCodRet, cSalida;
                END IF
            END IF
            LET cCodRet = "106012";
            SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores  WHERE origen = pOrigen AND codigo_error = cCodRet;                
            LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
            LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
            LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
            RETURN cCodRet, cSalida;
        END IF
        -- SE QUITAN LOS ESPACIOS QUE PUEDIERAN ESTAR A LA DERECHA
        LET cVAR_S1 = SUBSTR(cVAR_S1,1,LENGTH(cVAR_S1));LET cVAR_S2 = SUBSTR(cVAR_S2,1,LENGTH(cVAR_S2));
        LET cVAR_S3 = SUBSTR(cVAR_S3,1,LENGTH(cVAR_S3));LET cVAR_S4 = SUBSTR(cVAR_S4,1,LENGTH(cVAR_S4));
        LET cVAR_S5 = SUBSTR(cVAR_S5,1,LENGTH(cVAR_S5));
        LET i = 1;
        -- COMIENZA EL CUERPO DE LOS PARAMETROS
        LET cCuerpoSal = cCuerpoSal || "<parametros>";
        FOREACH
            SELECT TRIM(parametro) INTO cCMParametro FROM bdicobranza: cb_cat_configura_mensaje WHERE sistema = "4" AND cve_mensaje = pNumMensaje AND tipo_parametro = "S" ORDER BY secuencia
            LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(DECODE(i,1,cVAR_S1,2,cVAR_S2,3,cVAR_S3,4,cVAR_S4,5,cVAR_S5), cCMParametro);
            LET i = i + 1;
        END FOREACH
        LET cCuerpoSal = cCuerpoSal || "</parametros>";
    END FOREACH
ELIF pNumMensaje = "10004" THEN
    FOREACH
        EXECUTE PROCEDURE bdicobranza: "informix".sp_cat_consulta_disponibilidad_cliente(cVAR_E1,cVAR_E2,cVAR_E3,cVAR_E4)
        INTO cVAR_S1,cVAR_S2,cVAR_S3
        IF cVAR_S1::INTEGER <> 0 THEN
            IF cRegistraBit = "S" THEN                                
                IF cVAR_S1::INTEGER > 0 THEN
                    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cVAR_S1;
                END IF                
                EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cNumProceso,cVAR_S1,NVL(cDescErrorCtrl,""),"02")
                INTO cCodRetIB;
                IF cCodRetIB::INTEGER <> 0 THEN
                    LET cCodRet = "106010";
                    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores 
                    WHERE origen = pOrigen AND codigo_error = cCodRet;
                    LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
                    LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
                    LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
                    RETURN cCodRet, cSalida;
                END IF
            END IF
            LET cCodRet = "106013";
            SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
            LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
            LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
            LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
            RETURN cCodRet, cSalida;
        END IF            
        -- SE ARMA EL ENCABEZADO
        LET cEncabezadoSal = '<?xml version="1.0" encoding="utf-8" ?>';
        LET cNomServicioSal = '<ConsultaDeDisponibilidad_Respuesta xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://cobtelbancoppel.coppel.com">';
        LET cEncabezadoSal = cEncabezadoSal || cNomServicioSal;
        LET cColaSal = "</ConsultaDeDisponibilidad_Respuesta>";
        -- COMIENZA EL CUERPO DE LOS PARAMETROS
        LET cCuerpoSal = "<parametros>";
        LET cCMParametro = "";
        LET i = 1;
        FOREACH
            SELECT TRIM(parametro) INTO cCMParametro FROM bdicobranza: cb_cat_configura_mensaje WHERE sistema = "4" AND cve_mensaje = pNumMensaje AND tipo_parametro = "S" ORDER BY secuencia
            LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(DECODE(i,1,cVAR_S1,2,cVAR_S2,3,cVAR_S3), cCMParametro);
            LET i = i + 1;
        END FOREACH            
        LET cCuerpoSal = cCuerpoSal || "</parametros>";
    END FOREACH                
ELIF pNumMensaje = "10005" THEN
    FOREACH    
        EXECUTE PROCEDURE bdicobranza: "informix".sp_cat_graba_respuesta_llamada(cVAR_E1,cVAR_E2,cVAR_E3,cVAR_E4,cVAR_E5,cVAR_E6,cVAR_E7,cVAR_E8,cVAR_E9,cVAR_E10,cVAR_E11,cVAR_E12)
        INTO cVAR_S1            
        IF cVAR_S1::INTEGER <> 0 THEN
            IF cRegistraBit = "S" THEN                                
                IF cVAR_S1::INTEGER > 0 THEN
                    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cVAR_S1;
                END IF                
                EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cNumProceso,cVAR_S1,NVL(cDescErrorCtrl,""),"02")
                INTO cCodRetIB;
                IF cCodRetIB::INTEGER <> 0 THEN
                    LET cCodRet = "106010";
                    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
                    LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
                    LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
                    LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
                    RETURN cCodRet, cSalida;
                END IF
            END IF
            LET cCodRet = "106014";
            SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;                
            LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
            LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
            LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
            RETURN cCodRet, cSalida;
        END IF
        -- SE ARMA EL ENCABEZADO
        LET cEncabezadoSal = '<?xml version="1.0" encoding="utf-8" ?>';
        LET cNomServicioSal = '<RegistroDeGestionOLlamadaRealizada_Respuesta xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://cobtelbancoppel.coppel.com">';
        LET cEncabezadoSal = cEncabezadoSal || cNomServicioSal;
        LET cColaSal = "</RegistroDeGestionOLlamadaRealizada_Respuesta>";
        -- COMIENZA EL CUERPO DE LOS PARAMETROS
        LET cCuerpoSal = "<parametros>";
        LET cCMParametro = "";
        LET i = 1;
        FOREACH
            SELECT TRIM(parametro) INTO cCMParametro FROM bdicobranza: cb_cat_configura_mensaje WHERE sistema = "4" AND cve_mensaje = pNumMensaje AND tipo_parametro = "S" ORDER BY secuencia
            LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(DECODE(i,1,cVAR_S1,2,cVAR_S2), cCMParametro);
            LET i = i + 1;
        END FOREACH
        LET cCuerpoSal = cCuerpoSal || "</parametros>";
    END FOREACH                
ELIF pNumMensaje = "10006" THEN
    FOREACH
        EXECUTE PROCEDURE bdicobranza: "informix".sp_cat_graba_telefono_adicional(cVAR_E1,cVAR_E2,cVAR_E3,cVAR_E4,cVAR_E5,cVAR_E6,cVAR_E7,cVAR_E8,cVAR_E9)
        INTO cVAR_S1
        IF cVAR_S1::INTEGER <> 0 THEN
            IF cRegistraBit = "S" THEN                                
                IF cVAR_S1::INTEGER > 0 THEN
                    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cVAR_S1;
                END IF                
                EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cNumProceso,cVAR_S1,NVL(cDescErrorCtrl,""),"02")
                INTO cCodRetIB;
                IF cCodRetIB::INTEGER <> 0 THEN
                    LET cCodRet = "106010";
                    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
                    LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
                    LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
                    LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
                    RETURN cCodRet, cSalida;
                END IF
            END IF
            LET cCodRet = "106015";
            SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;                
            LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
            LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
            LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
            RETURN cCodRet, cSalida;
        END IF
        -- SE ARMA EL ENCABEZADO
        LET cEncabezadoSal = '<?xml version="1.0" encoding="utf-8" ?>';
        LET cNomServicioSal = '<RegistroDeTelefonoAdicional_Repuesta xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://cobtelbancoppel.coppel.com">';
        LET cEncabezadoSal = cEncabezadoSal || cNomServicioSal;
        LET cColaSal = "</RegistroDeTelefonoAdicional_Repuesta>";
        -- COMIENZA EL CUERPO DE LOS PARAMETROS
        LET cCuerpoSal = "<parametros>";
        LET cCMParametro = "";
        LET i = 1;
        FOREACH
            SELECT TRIM(parametro) INTO cCMParametro FROM bdicobranza: cb_cat_configura_mensaje WHERE sistema = "4" AND cve_mensaje = pNumMensaje AND tipo_parametro = "S" ORDER BY secuencia
            LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(DECODE(i,1,cVAR_S1,2,cVAR_S2), cCMParametro);
            LET i = i + 1;
        END FOREACH            
        LET cCuerpoSal = cCuerpoSal || "</parametros>";
    END FOREACH                
ELIF pNumMensaje = "10007" THEN
    FOREACH
        EXECUTE PROCEDURE bdicobranza: "informix".sp_cat_consulta_generales(cVAR_E1,cVAR_E2,cVAR_E3)
        INTO cVAR_S1,cVAR_S2,cVAR_S3,cVAR_S4,cVAR_S5,cVAR_S6,cVAR_S7,cVAR_S8,cVAR_S9,cVAR_S10,cVAR_S11,cVAR_S12,cVAR_S13,cVAR_S14,cVAR_S15,cVAR_S16,cVAR_S17,cVAR_S18,cVAR_S19,cVAR_S20,cVAR_S21,cVAR_S22,cVAR_S23,cVAR_S24,cVAR_S25,cVAR_S26,cVAR_S27,cVAR_S28,cVAR_S29,cVAR_S30,cVAR_S31,cVAR_S32,cVAR_S33,cVAR_S34,cVAR_S35,cVAR_S36,cVAR_S37,cVAR_S38
        IF cVAR_S1::INTEGER <> 0 THEN
            IF cRegistraBit = "S" THEN                                
                IF cVAR_S1::INTEGER > 0 THEN
                    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cVAR_S1;
                END IF                
                EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cNumProceso,cVAR_S1,NVL(cDescErrorCtrl,""),"02")
                INTO cCodRetIB;
                IF cCodRetIB::INTEGER <> 0 THEN
                    LET cCodRet = "106010";
                    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl  FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
                    LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
                    LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
                    LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
                    RETURN cCodRet, cSalida;
                END IF
            END IF
            LET cCodRet = "106016";
            SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;                
            LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
            LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
            LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
            RETURN cCodRet, cSalida;
        END IF
        -- SE QUITAN LOS ESPACIOS QUE PUEDIERAN ESTAR A LA DERECHA
        LET cVAR_S1 = SUBSTR(cVAR_S1,1,LENGTH(cVAR_S1));LET cVAR_S2 = SUBSTR(cVAR_S2,1,LENGTH(cVAR_S2));LET cVAR_S3 = SUBSTR(cVAR_S3,1,LENGTH(cVAR_S3));
        LET cVAR_S4 = SUBSTR(cVAR_S4,1,LENGTH(cVAR_S4));LET cVAR_S5 = SUBSTR(cVAR_S5,1,LENGTH(cVAR_S5));LET cVAR_S6 = SUBSTR(cVAR_S6,1,LENGTH(cVAR_S6));
        LET cVAR_S7 = SUBSTR(cVAR_S7,1,LENGTH(cVAR_S7));LET cVAR_S8 = SUBSTR(cVAR_S8,1,LENGTH(cVAR_S8));LET cVAR_S9 = SUBSTR(cVAR_S9,1,LENGTH(cVAR_S9));
        LET cVAR_S10 = SUBSTR(cVAR_S10,1,LENGTH(cVAR_S10));LET cVAR_S11 = SUBSTR(cVAR_S11,1,LENGTH(cVAR_S11));LET cVAR_S12 = SUBSTR(cVAR_S12,1,LENGTH(cVAR_S12));
        LET cVAR_S13 = SUBSTR(cVAR_S13,1,LENGTH(cVAR_S13));LET cVAR_S14 = SUBSTR(cVAR_S14,1,LENGTH(cVAR_S14));LET cVAR_S15 = SUBSTR(cVAR_S15,1,LENGTH(cVAR_S15));
        LET cVAR_S16 = SUBSTR(cVAR_S16,1,LENGTH(cVAR_S16));LET cVAR_S17 = SUBSTR(cVAR_S17,1,LENGTH(cVAR_S17));LET cVAR_S18 = SUBSTR(cVAR_S18,1,LENGTH(cVAR_S18));
        LET cVAR_S19 = SUBSTR(cVAR_S19,1,LENGTH(cVAR_S19));LET cVAR_S20 = SUBSTR(cVAR_S20,1,LENGTH(cVAR_S20));LET cVAR_S21 = SUBSTR(cVAR_S21,1,LENGTH(cVAR_S21));
        LET cVAR_S22 = SUBSTR(cVAR_S22,1,LENGTH(cVAR_S22));LET cVAR_S23 = SUBSTR(cVAR_S23,1,LENGTH(cVAR_S23));LET cVAR_S24 = SUBSTR(cVAR_S24,1,LENGTH(cVAR_S24));
        LET cVAR_S25 = SUBSTR(cVAR_S25,1,LENGTH(cVAR_S25));LET cVAR_S26 = SUBSTR(cVAR_S26,1,LENGTH(cVAR_S26));LET cVAR_S27 = SUBSTR(cVAR_S27,1,LENGTH(cVAR_S27));
        LET cVAR_S28 = SUBSTR(cVAR_S28,1,LENGTH(cVAR_S28));LET cVAR_S29 = SUBSTR(cVAR_S29,1,LENGTH(cVAR_S29));LET cVAR_S30 = SUBSTR(cVAR_S30,1,LENGTH(cVAR_S30));
        LET cVAR_S31 = SUBSTR(cVAR_S31,1,LENGTH(cVAR_S31));LET cVAR_S32 = SUBSTR(cVAR_S32,1,LENGTH(cVAR_S32));LET cVAR_S33 = SUBSTR(cVAR_S33,1,LENGTH(cVAR_S33));
        LET cVAR_S34 = SUBSTR(cVAR_S34,1,LENGTH(cVAR_S34));LET cVAR_S35 = SUBSTR(cVAR_S35,1,LENGTH(cVAR_S35));LET cVAR_S36 = SUBSTR(cVAR_S36,1,LENGTH(cVAR_S36));
        LET cVAR_S37 = SUBSTR(cVAR_S37,1,LENGTH(cVAR_S37));LET cVAR_S38 = SUBSTR(cVAR_S38,1,LENGTH(cVAR_S38));
        -- SE ARMA EL ENCABEZADO
        LET cEncabezadoSal = '<?xml version="1.0" encoding="utf-8" ?>';
        LET cNomServicioSal = '<ConsultaDeDatosGenerales_Respuesta xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://cobtelbancoppel.coppel.com">';
        LET cEncabezadoSal = cEncabezadoSal || cNomServicioSal;
        LET cColaSal = "</ConsultaDeDatosGenerales_Respuesta>";
        -- COMIENZA EL CUERPO DE LOS PARAMETROS
        LET cCuerpoSal = "<parametros>";
        LET cCMParametro = "";
        LET i = 1;
        FOREACH
            SELECT TRIM(parametro) INTO cCMParametro FROM bdicobranza: cb_cat_configura_mensaje WHERE sistema = "4" AND cve_mensaje = pNumMensaje AND tipo_parametro = "S" ORDER BY secuencia
            LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(DECODE(i,1,cVAR_S1,2,cVAR_S2,3,cVAR_S3,4,cVAR_S4,5,cVAR_S5,6,cVAR_S6,7,cVAR_S7,8,cVAR_S8,9,cVAR_S9,10,cVAR_S10,11,cVAR_S11,12,cVAR_S12,13,cVAR_S13,14,cVAR_S14,15,cVAR_S15,16,cVAR_S16,17,cVAR_S17,18,cVAR_S18,19,cVAR_S19,20,cVAR_S20,21,cVAR_S21,22,cVAR_S22,23,cVAR_S23,24,cVAR_S24,25,cVAR_S25,26,cVAR_S26,27,cVAR_S27,28,cVAR_S28,29,cVAR_S29,30,cVAR_S30,31,cVAR_S31,32,cVAR_S32,33,cVAR_S33,34,cVAR_S34,35,cVAR_S35,36,cVAR_S36,37,cVAR_S37,38,cVAR_S38), cCMParametro);
            LET i = i + 1;
        END FOREACH                        
        LET cCuerpoSal = cCuerpoSal || "</parametros>";
    END FOREACH
ELIF pNumMensaje = "10008" THEN
    FOREACH    
        EXECUTE PROCEDURE bdicobranza: "informix".sp_grabacompac(cVAR_E1,cVAR_E2,cVAR_E3,cVAR_E4,cVAR_E5,cVAR_E6,cVAR_E7,cVAR_E8,cVAR_E9,cVAR_E10,cVAR_E11,cVAR_E12,cVAR_E13,cVAR_E14,cVAR_E15,cVAR_E16)
        INTO cVAR_S1            
        IF cVAR_S1::INTEGER <> 0 THEN
            IF cRegistraBit = "S" THEN                                
                IF cVAR_S1::INTEGER > 0 THEN
                    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cVAR_S1;
                END IF                
                EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cNumProceso,cVAR_S1,NVL(cDescErrorCtrl,""),"02")
                INTO cCodRetIB;
                IF cCodRetIB::INTEGER <> 0 THEN
                    LET cCodRet = "106010";
                    SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
                    LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
                    LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
                    LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
                    RETURN cCodRet, cSalida;
                END IF
            END IF
            LET cCodRet = "106017";
            SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores  WHERE origen = pOrigen AND codigo_error = cCodRet;
            LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
            LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
            LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
            RETURN cCodRet, cSalida;
        END IF
        -- SE ARMA EL ENCABEZADO
        LET cEncabezadoSal = '<?xml version="1.0" encoding="utf-8" ?>';
        LET cNomServicioSal = '<RegistroDeCompromisos_Respuesta xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://cobtelbancoppel.coppel.com">';
        LET cEncabezadoSal = cEncabezadoSal || cNomServicioSal;
        LET cColaSal = "</RegistroDeCompromisos_Respuesta>";
        -- COMIENZA EL CUERPO DE LOS PARAMETROS
        LET cCuerpoSal = "<parametros>";
        LET cCMParametro = "";
        LET i = 1;
        -- SE QUITAN LOS ESPACIOS QUE PUEDIERAN ESTAR A LA DERECHA
        LET cVAR_S1 = SUBSTR(cVAR_S1,1,LENGTH(cVAR_S1));
        FOREACH
            SELECT TRIM(parametro) INTO cCMParametro FROM bdicobranza: cb_cat_configura_mensaje WHERE sistema = "4" AND cve_mensaje = pNumMensaje AND tipo_parametro = "S" ORDER BY secuencia
            LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(DECODE(i,1,cVAR_S1), cCMParametro);
            LET i = i + 1;
        END FOREACH
        LET cCuerpoSal = cCuerpoSal || "</parametros>";
    END FOREACH                
END IF
-- ////////////-- ////// *TERMINA* VALIDACIONES DEL SEGMENTO DONDE SE ARMA EL CUERPO DEL XML DE SALIDA  //////-- //////-- 
-- SE FORMA LA TRAMA COMPLETA XML DE SALIDA
LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
-- SE QUITAN LOS CARACTERES EN BLANCO DE LA DERECHA
LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
-- REGISTRA EN LA BITACORA EL EXITO DE LA EJECUCION
IF cRegistraBit = "S" AND cCodRet::INTEGER = 0 THEN
    IF cBand1 = "T" THEN
        SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = "102013";
        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cNumProceso,"102013",NVL(cDescErrorCtrl,""),"02")
        INTO cCodRetIB;
        IF cCodRetIB::INTEGER <> 0 THEN
            LET cCodRet = "106010";
            SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
            LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
            LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
            LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
            RETURN cCodRet, cSalida;
        END IF
    END IF
    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cNumProceso,cVAR_S1,cDescErrorCtrl,"03")
    INTO cCodRetIB;
    IF cCodRetIB::INTEGER <> 0 THEN
        LET cCodRet = "106010";
        SELECT {+INDEX(cb_errores idx_pk_cb_errores)} TRIM(descripcion) INTO cDescErrorCtrl FROM cb_errores WHERE origen = pOrigen AND codigo_error = cCodRet;
        LET cCuerpoSal = cCuerpoSal || bdicobranza: fn_FormarEtiquetaXML(NVL(cDescErrorCtrl,""), "error");
        LET cSalida = cEncabezadoSal || cCuerpoSal || cColaSal;
        LET cSalida = SUBSTR(cSalida,1,LENGTH(cSalida));
        RETURN cCodRet, cSalida;
    END IF
END IF
RETURN cCodRet, cSalida;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento menú que recibe un identificador de mensaje que corresponde a un procedimiento parámetrizado preparado para ejecutarse.', 
'AUTOR: Mohamed Carreón ',
'*** NOTA: SI SE LLEGAN A AGREGAR NUEVOS SPS, VERIFICAR EL NUMERO DE PARAMETROS QUE RECIBE Y QUE REGRESA, SI SON MAYORES AL TOTAL DE VARIABLES',
' MAXIMAS, YA SEAN DE ENTRADA O DE SALIDA, SE DEBERAN DE AGREGAR EN LAS DEFINICIONES, EN LAS ASIGNACIONES, EL LA OBTENCION DEL VALOR',
' DE LOS PARAMETROS DE ENTRADA, TODO ESTO ADEMAS DE LA CONFIGURACION DEL EXECUTE NUEVO. EL NOMBRE DEL SP DEBE DE ESTAR REGISTRADO EN LA TABLA',
' bdicobranza: cb_cat_mensaje; LOS PARAMETROS TANTO DE ENTRADA COMO DE SALIDA SE DEBEN DE REGISTRAR EN bdicobranza: cb_cat_configura_mensaje.',
'VERSION: 20101028.1614';

CREATE PROCEDURE "informix".sp_compac_tipo_reporte()
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,	
		  INTEGER AS num_archivo,
		  CHAR(80) AS desc_archivo; 
---DECLARACIONES
DEFINE cCodRet        	  CHAR(6); 
DEFINE cMensajeRet        CHAR(80);
DEFINE iSqlErr      	  INTEGER;
DEFINE iIsamErr           INTEGER;
DEFINE cErrorInfo         CHAR(80);
DEFINE cDescripcionArchivo	CHAR(80);
DEFINE iNumArchivo		  INTEGER;

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "PROCESO EXITOSO";
LET iNumArchivo			= 0;
LET cDescripcionArchivo	= "";
       
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    LET cCodRet= iSqlErr;
	LET cMensajeRet = cErrorInfo;
    RETURN cCodRet, cMensajeRet,0,'';
END EXCEPTION;

--SET DEBUG FILE TO 'sp_compac_tipo_reporte.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	FOREACH
		SELECT UNIQUE(num_archivo),TRIM(nom_archivo)
		INTO iNumArchivo,cDescripcionArchivo
		FROM  bdicobranza:"informix".cb_param_archivos 
		ORDER BY num_archivo	
					
		 RETURN cCodRet, cMensajeRet,iNumArchivo,cDescripcionArchivo WITH RESUME;
	END FOREACH;
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para la obtencion de los tipos de reportes para estadistica de convenios',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 05/04/2011',
'BD    : BDICOBRANZA',
'Version: 20110404.0850';

create procedure "informix".sp_mail_compraxmonto(pempresa char(3), pfechacorte date)
returning VARCHAR(6);
--DEFINE pempresa          char(3);
DEFINE pnumcredito       char(20);
DEFINE pnumcte		 char(20);
DEFINE pemail		 char (60);
DEFINE pmonto  decimal(18,2);
--DEFINE pfechaact         date;
--DEFINE pfechaant         date;
DEFINE pfechahoy         date;
DEFINE pfechamov		 date;	

DEFINE cProceso  char(4);
DEFINE cCod_ret  smallint;
DEFINE cMensaje  char (100); 
--DEFINE pdia      date; 
DEFINE pfechaarmada date; 
 

DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE P_MENSAJE          VARCHAR(80);

BEGIN 
  
    ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, P_COD_RET, P_MENSAJE, '02')
        RETURNING P_COD_RET;
         LET P_COD_RET = SQL_ERR;
         LET P_MENSAJE = ERROR_INFO;
    RETURN P_COD_RET;
    END exception;
 
    let P_COD_RET = '111111';
    let cCod_ret = '';
    let cMensaje = '';
    let cProceso = '2027';
	
	--valida parametros
	IF NVL (pempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	IF NVL (pfechacorte, '') = '' THEN
        LET cCod_Ret= '104008';        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
       IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	
    Select Fecha_Hoy
        Into pfechahoy
    From bdicred:sd_fechas
    Where empresa = '001';

    delete from bdicobranza:cb_mail_cliente where fecha_insert = pfechahoy and tipo_mensaje = 1 and pagos_vencidos= 30;     
   /* select limit 1 dia_corte into pdia from bdicred:sd_maecredanexo where empresa = pempresa;
     
   
   let pfechaarmada = mdy(month(pfechacorte),day(pdia),year(pfechacorte));
   let pfechaact = date(pfechacorte);

   if (pfechacorte <= pfechaarmada) then
        let pfechaant = date (pfechaarmada) - 1 units month + 1 units day;
   end if;
   if (pfechacorte > pfechaarmada ) then
        let pfechaant = date (pfechaarmada) + 1 units day;
   end if;   */
   let pfechaarmada = date (pfechacorte) -  1 units day;

	
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '01')
        RETURNING P_COD_RET;

set isolation to dirty read;
foreach 
	
         
	SELECT  a.num_credito, a.numcte, b.email, e.monto, e.fecha_mov
		INTO  pnumcredito, pnumcte, pemail, pmonto, pfechamov
    FROM bdicred:sd_maecred a
		inner join bdinteg:si_ctepf b on ( b.empresa=a.empresa and b.numcte = a.numcte)
		join bdicred:sd_movhis e on (  e.empresa = a.empresa  and e.num_credito = a.num_credito)
    WHERE  a.status_cred = 'AA' 
       and e.fecha_mov = pfechaarmada
	   and nvl(e.monto,0) > 5000
       and e.codigo_fun = 002
	   and e.codigo_ref IN (50,30,40,41,42,34,35,36,60,61,62,63,64, 37,57)
	and e.reversado='N'	   
       AND nvl(b.email, '') <> '' 
       group by a.num_credito, a.numcte, b.email, e.monto, e.fecha_mov
    
    call "informix".sp_mail_inserta_cliente (pempresa,1, pnumcte, pnumcredito, pemail,pmonto,0,30,0,null,null,pfechamov,0,0)
    returning P_COD_RET;
    let P_COD_RET = '000000';

end foreach
	call   bdicobranza:"informix".sp_inserta_mensaje('001',1,0,30)
	RETURNING P_COD_RET;
            let P_COD_RET = '000000';  	  

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '03')
        RETURNING P_COD_RET;
end
    RETURN P_COD_RET;
END PROCEDURE;