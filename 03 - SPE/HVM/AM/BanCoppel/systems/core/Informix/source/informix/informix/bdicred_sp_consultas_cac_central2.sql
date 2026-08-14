CREATE PROCEDURE "informix".sp_consultas_cac_central2(pEmpresa          CHAR(3),
                                                     pSucursal         CHAR(4),
                                                     pFechaInicial     DATE,
                                                     pFechaFinal       DATE,
                                                     pNumSol           CHAR(20),
                                                     pBanCac           CHAR(1),
                                                     pCac_Opt1_1       DECIMAL(5,2),
                                                     pCac_Opt3_1       INTEGER,
                                                     pArea             CHAR(2),
                                                     pStatus           CHAR(2),
                                                     pCausa            CHAR(3),
													 pProducto         CHAR(4),
                                                     pEjecutivo        CHAR(9),
                                                     pInicioReg        INTEGER, 
                                                     pFinReg           INTEGER)
RETURNING
          CHAR(6),          -- CÃ³digo de Retorno
          CHAR(80),         -- Mensaje de Retorno		 
          CHAR(20),         -- NÃ³mero de Solicitud
          CHAR(20),         -- NÃ³mero de Cliente
          CHAR(104),        -- Nombre del Cliente
          CHAR(13),         -- RFC
          CHAR(4),          -- Sucursal
          DATE,             -- Fecha Solicitud
          DATE,             -- Fecha Cambio Estatus
          DECIMAL(18,2),    -- Importe de Linea
          DECIMAL(5,2),     -- Eficiencia
          INTEGER,          -- Historial
          DECIMAL(5,2),     -- Puntos 1a SecciÃ³n
          DECIMAL(5,2),     -- Puntos 2da SecciÃ³n
          CHAR(2),          -- Estatus
          CHAR(511),        -- Observaciones Anteriores
          DECIMAL(8,2),     -- Suma de Secciones
		  CHAR(3);          -- Causa del Status

DEFINE cNumSolicitud           CHAR(20);
DEFINE cNumCte                 CHAR(20);
DEFINE cSucursal               CHAR(4);
DEFINE dtFechaInsert           DATE;
DEFINE dtFechaModificacion     DATE;
DEFINE dMontoSolicitado        DECIMAL(18,2);
DEFINE cStatusSol              CHAR(2);
DEFINE cTipoSolicitud          CHAR(1);
DEFINE iInfoBuro               INTEGER;
DEFINE cComentarioAut          CHAR(511);
DEFINE iRevisionCac            INTEGER;
DEFINE cNombreCte              CHAR(104);
DEFINE cRFC                    CHAR(13);
DEFINE dSituacionPago          DECIMAL(5,2);
DEFINE iMesesHistoria          INTEGER;
DEFINE dSeccion1               DECIMAL(18,2);
DEFINE dSeccion2               DECIMAL(18,2);
DEFINE dSeccionAux             DECIMAL(18,2);
DEFINE dSumaSecciones          DECIMAL(18,2);
DEFINE iCantidad               INTEGER;
DEFINE icuantos                INTEGER;
DEFINE iSecAux                 INTEGER;
DEFINE cEmpAux                 CHAR(3);
DEFINE iSqlErr                 INTEGER;
DEFINE iIsamErr                INTEGER;
DEFINE cErrorInfo              CHAR(80);
DEFINE cCodRet                 CHAR(6);
DEFINE cMensajeRet             CHAR(80);
DEFINE cFecha                  CHAR(10);
DEFINE cCausa				   CHAR(3);
DEFINE dECValor1			   DECIMAL(5,2);
DEFINE dECValor2			   DECIMAL(5,2);
DEFINE dMACValor1			   DECIMAL(5,2);
DEFINE dMACValor2			   DECIMAL(5,2);
DEFINE dPSValor1			   DECIMAL(5,2);
DEFINE dPSValor2			   DECIMAL(5,2);

DEFINE iMeseshist              INTEGER;
DEFINE cProducto               CHAR(4);
DEFINE dBandera                INTEGER;



LET cNumSolicitud              = '';
LET cNumCte                    = '';
LET cSucursal                  = '';
LET dtFechaInsert              = DATE(1);
LET dtFechaModificacion        = DATE(1);
LET dMontoSolicitado           = 0;
LET cStatusSol                 = '';
LET cTipoSolicitud             = '';
LET iInfoBuro                  = 0;
LET cComentarioAut             = '';
LET iRevisionCac               = 0;

LET cNombreCte                 = '';
LET cRFC                       = '';

LET dSituacionPago             = 0;
LET iMesesHistoria             = 0;

LET dSeccion1                  = 0;
LET dSeccion2                  = 0;
LET dSeccionAux                = 0;
LET dSumaSecciones             = 0;
LET iCantidad                  = 0;
LET icuantos                   = 0;
LET iSecAux                    = 0;
LET cEmpAux                    = '';

LET iSqlErr                    = 0;
LET iIsamErr                   = 0;
LET cErrorInfo                 = '';
LET cCodRet                    = '';
LET cMensajeRet                = '';

LET cFecha                     = '';
LET cCausa					   = '';
LET dECValor1				   = 0.0;
LET dECValor2				   = 0.0;
LET dMACValor1				   = 0.0;
LET dMACValor2				   = 0.0;
LET dPSValor1				   = 0.0;
LET dPSValor2				   = 0.0;
LET iMeseshist                 = 0;
LET cProducto                  = "";
LET dBandera                   = 0; 


-- ** HISTORIAL DE CAMBIOS ** --

--  Autor: Roque Solis.
--  Fecha : 02/25/2009.
--  Comentarios: Se quitaron las restricciones de comprobacion de ingresos.

-- Autor: Paul Ivan Quintero Varela.
-- Fecha: 04/05/2009.
-- Comentarios: Se modifica para contemplar en la selecciÃ³n principal los 3 tipos de consulta
--                        adicionales (Numero cte, Nombre y Numero de solicitud).
--Autor Roque Solis
--25/05/2009
--Comentarios: Se quitaron las consultas por nombre y numero de cliente,
-- se agrego el rfc
--
--Autor Mohamed CarreÃ³n
--07/06/ 2010
--Comentarios: se agregÃ³ la causa del status y los filtros para los criterios del cac y mc.

--Autor: Viridiana Osobampo Aguilar
--24/01/ 2011
--Comentarios: Se modifica para que la validaciÃ³n de eficiencia, meses de historia y puntuaciÃ³n scoring
--                        solo se realice cuando se trate de una consulta por CAC o MC.

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet,cMensajeRet,NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''),NVL(cRFC,''),NVL(cSucursal,''),dtFechaInsert,dtFechaModificacion,NVL(dMontoSolicitado,0),
           NVL(dSituacionPago,0),NVL(iMesesHistoria,0),NVL(dSeccion1,0),NVL(dSeccion2,0),NVL(cStatusSol,''),NVL(cComentarioAut,''), dSumaSecciones, NVL(cCausa,'');
   END IF;
END EXCEPTION;

--  Se genera archivo DEBUG!


--SET DEBUG FILE TO '/tmp/mfinis/sp_consultas_cac_central.out';
--TRACE ON;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

LET cCodRet= "000000";
LET cMensajeRet= "Se realizo la consulta al central correctamente.";

 IF NVL(pSucursal,'') = '' THEN
    LET pSucursal = NULL;
 END IF;

 IF pFechaInicial = '' THEN
    LET pFechaInicial = DATE(1);
 END IF;

 IF pFechaFinal = '' THEN
    LET pFechaFinal = CURRENT;
 END IF;

 IF pFechaInicial IS NOT NULL AND pFechaFinal IS NULL THEN
     SELECT valor
           INTO cFecha
           FROM bdicred:"informix".sd_param
          WHERE cod_param='030';
     LET pFechaInicial=DATE(cFecha);
  END IF;

 IF pNumSol = '' THEN
    LET pNumSol = NULL;
 END IF;

	FOREACH WITH HOLD
		SELECT SKIP pInicioReg FIRST pFinReg num_solicitud,num_cte,nombre_cte,rfc, sucursal,fecha_solic,fecha_cambio_stsuts,importe_linea,
			eficiencia,historial,puntos_seccion,puntos_2da_seccion,status_solicitud,observaciones_ant,suma_secciones,causas_status 
		INTO cNumSolicitud,cNumCte,cNombreCte,cRFC,cSucursal,dtFechaInsert,dtFechaModificacion,dMontoSolicitado,
           dSituacionPago,iMesesHistoria,dSeccion1,dSeccion2,cStatusSol,cComentarioAut, dSumaSecciones, cCausa
		FROM bdicnweb:"informix".paso1
		WHERE usuario = pEjecutivo
	   
		RETURN cCodRet, cMensajeRet, NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''),NVL(cRFC,''),NVL(cSucursal,''),dtFechaInsert,dtFechaModificacion,NVL(dMontoSolicitado,0),
           NVL(dSituacionPago,0),NVL(iMesesHistoria,0),NVL(dSeccion1,0),NVL(dSeccion2,0),NVL(cStatusSol,''),NVL(cComentarioAut,''), dSumaSecciones, NVL(cCausa,'') WITH RESUME;
	   
	END FOREACH;   

END
END PROCEDURE;