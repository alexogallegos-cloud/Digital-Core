CREATE PROCEDURE "informix".sp_cat_graba_respuesta_llamada(pEmpresa     CHAR(3),
                                                           pNumcte      CHAR(20),
                                                           pTipotel     SMALLINT,
                                                           pTelefono    CHAR(13),
                                                           pResultado   SMALLINT,
                                                           pFechaProg   DATE,
                                                           pHoraProg    DATETIME HOUR TO FRACTION,
                                                           pEjecutivo   CHAR(8),
                                                           pId_llamada  CHAR(100),
                                                           pTipoCob     CHAR(1),
                                                           pParentesco  CHAR(1),
                                                           pTpoMovto    SMALLINT)

RETURNING CHAR(6) AS cod_ret;

DEFINE iSqlErr          INTEGER; 
DEFINE iIsamErr         INTEGER;
DEFINE cCod_ret         CHAR(6);

DEFINE iExiste          SMALLINT;
DEFINE dtFecha          DATETIME HOUR TO FRACTION;
DEFINE dtFechaHora      DATETIME YEAR TO FRACTION;
DEFINE cMensaje         CHAR(80);

LET iSqlErr          = 0;
LET iIsamErr         = 0;
LET cCod_ret         = "000000";

LET iExiste          = 0;
LET dtFecha          = DATE(1);
LET dtFechaHora      = CURRENT YEAR TO SECOND;
LET cMensaje         = "";

--SET DEBUG FILE TO "/home/sysifx/sp_cat_graba_respuesta_llamada.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr
          LET cCod_ret = iSqlErr;
          RETURN cCod_ret;
    END EXCEPTION;

     IF pTpoMovto NOT IN (1,2) THEN
        LET cCod_ret = "102001";
     END IF;

    IF pTpoMovto = 1 THEN -- Identifica que es una llamada
        IF NVL(pEmpresa,"") = "" OR NVL(pNumcte,"") = "" OR pTipotel IS NULL OR NVL(pTelefono,"") = ""
           OR  pResultado IS NULL OR NVL(pId_llamada,"") = "" THEN
            LET cCod_ret = "102002";
            RETURN cCod_ret;
        END IF;
    END IF;

     IF pTpoMovto = 2 THEN -- Identifica que es una gestión
         IF NVL(pTipotel,"") <> "" OR NVL(pTelefono,"") <> ""  OR NVL(pFechaProg,"") <> "" 
              OR NVL(pHoraProg,"") <> "" OR NVL(pId_llamada,"") <> "" OR NVL(pEmpresa,"") = "" OR NVL(pNumcte,"") = "" THEN
              LET cCod_ret = "102002";
              RETURN cCod_ret;
         END IF;        
     END IF;

   SELECT COUNT(empresa)
     INTO iExiste
     FROM bdinteg:"informix".si_empresas
    WHERE empresa = pEmpresa;

    IF iExiste = 0 THEN
        LET cCod_ret = "102003";
        RETURN cCod_ret;
    END IF;

    SELECT fecha_hoy, CURRENT
      INTO dtFecha, dtFechaHora
      FROM bdinteg:"informix".si_fechas
     WHERE empresa = pEmpresa;

   INSERT INTO bdicobranza:"informix".cb_cat_resultado_llamada (empresa,fecha_llamada,tipo_campania,numcte,id_llamada,
                                                                  tipo_telefono,telefono,codigo_resultado,fecha_llamar_despues,
                                                                  hora_llamar_despues,ejecutivo,fh_movimiento,parentesco)
           VALUES (pEmpresa,dtFecha,pTipoCob,pNumcte,pId_llamada,
                   pTipotel,pTelefono,pResultado,pFechaProg,
                   pHoraProg,pEjecutivo,dtFechaHora,pParentesco);
    IF pTpoMovto = 2 THEN 
        EXECUTE PROCEDURE "informix".sp_cat_cambia_estatus_cte(pNumcte, 
                                                            "PR", 
                                                            0, 
                                                            pTipoCob,
                                                            pEmpresa, 
                                                            pEjecutivo)
        INTO cCod_ret, cMensaje;
        IF cCod_ret <> "000000" THEN
            LET cCod_ret = "102004";
        END IF;
   END IF;
RETURN cCod_ret;

END 
END PROCEDURE
DOCUMENT
"Descripción: Registra los resultados de la llamadas realizadas por el ejecutivo",
"cobranza telefónica",
"BD: bdicobranza",
"Autor: Viridiana Osobampo Aguilar",
"Fecha: 29-Sep-2010";

CREATE PROCEDURE "informix".sp_random() RETURNING INTEGER;
	DEFINE GLOBAL seed DECIMAL(10) DEFAULT 1; 
	DEFINE d DECIMAL(20,0); 
	LET d = (seed * 1103515245) + 12345; 
	LET seed = d - 4294967296 * TRUNC(d / 4294967296); 
	RETURN MOD(TRUNC(seed / 65536), 32768); 
END PROCEDURE;