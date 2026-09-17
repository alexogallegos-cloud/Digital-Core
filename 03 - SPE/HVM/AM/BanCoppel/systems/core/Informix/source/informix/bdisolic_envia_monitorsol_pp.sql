CREATE PROCEDURE "informix".envia_monitorsol_pp
                            (
                             pEmpresa     CHAR(3),   -- Empresa
                             pSucursal    CHAR(20),  -- Folio de sucursal
                             pSolicitudes SMALLINT,	 -- Número de solicitudes
                             pNumcte      CHAR(20),  -- Número de cliente
                             pProducto	  CHAR(4),	 -- Código de producto
                             pEstatus	  CHAR(2),	 -- Estatus de solicitud
                             pFechaIni	  CHAR(10),  -- Fecha inicial
                             pFechaFin	  CHAR(10)	 -- Fecha final
                            )

RETURNING 	CHAR(6)         AS CodRetorno,  	-- Codigo de retorno
            CHAR(54)        AS Mensaje_Retorno, -- Mensaje de retorno
            CHAR(20)	    AS NumSolicitud, 	-- Nro de solicitud
            CHAR(20)  	    AS NumCliente, 		-- Nro de cliente
            CHAR(120) 	    AS NombreCliente,  	-- Nombre del cliente
            CHAR(15)	    AS RFC,   			-- R.F.C.
            DATE		    AS FechaSol,		-- Fecha de solicitud
            DATE		    AS FechaAut,       	-- Fecha autorizacion
            CHAR(4)         AS Producto,		-- Código de producto
            CHAR(40)	    AS ProdDes,			-- Descripcion del producto
            MONEY(14,2)     AS LineaOtorgada,  	-- Linea otorgada
            CHAR(2)	        AS Estatus,      	-- Status de la solicitud
            CHAR(60)	    AS EstatusDes,     	-- Descripcion del status de la solicitud
            CHAR(255)	    AS Comentario,    	-- Comentario
            CHAR(2)	        AS DiaCorte,      	-- Dia de corte
            CHAR(2)	        AS Divisa,      	-- Divisa
            MONEY(14,2)     AS IngresoCliente,  -- Ingreso del cliente
            INTEGER		    AS EsCtaCap;		-- Valor para identificar si tiene o no cuenta de captación


-- MODIFICO: Paul Ivan Quintero Varela
-- Modificacion: 1.- Se valida para que no envie la fecha como default (1900-01-01) en el retorno
--               2.- Se modifica la consulta de las cuentas de captaciòn para ligarlas con su
--                    producto correspondiente
--               3.- Se modifica para evitar poner la condiciòn de que no acepte solo el producto "6001"
--                   y se obtiene a traves del tipo de solicitud el cual serà "P" para aquellas solicitudes
--                   que seran consultadas
-- Fecha: 2010/02/04

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
-- Variables de control de errores
DEFINE isqlerr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);

-- Variables para valores de retorno
DEFINE cCodRet     		CHAR(6); 	      -- Código de retorno de error
DEFINE cMens_Ret        CHAR(54);         -- Mensajes de error
DEFINE cNumSol     		CHAR(20);         -- Número de solicitud
DEFINE cNumCte     		CHAR(20);	      -- Número de cliente
DEFINE cNombre     		CHAR(110);        -- Nombre del cliente
DEFINE cRfc        		CHAR(15);	      -- RFC
DEFINE dFechaSol  		DATE;			  -- Fecha de solicitud
DEFINE dFechaAut   		DATE;			  -- Fecha de autorización
DEFINE cProducto		CHAR(4);	      -- Código de producto
DEFINE cProdDesc		CHAR(40);	      -- Descripción del producto
DEFINE mLinea      		MONEY(14,2);	  -- Línea de crédito autorizada
DEFINE cStatus     		CHAR(2);	      -- Código de estatus de la solicitud
DEFINE cStDesc     		CHAR(50);	      -- Descripción de estatus de la solicitud
DEFINE cComentario 		CHAR(255);	      -- Comentario
DEFINE cDiaCorte   		CHAR(2);	      -- Día de corte
DEFINE cDivisa     		CHAR(2);	      -- Divisa
DEFINE mIngreso    		MONEY(14,2);	  -- Ingreso
DEFINE iCuentaCap  		INTEGER;		  -- Cuenta de captación

--VARIABLES AUXILIARES
DEFINE dFechaHoy   		DATE;			  -- Fecha Actual
DEFINE sDias_rt     	SMALLINT;		  -- Días que lleva rechazada
DEFINE sDias_at     	SMALLINT;		  -- Días que lleva autorizada
DEFINE dFechaMax		DATE;			  -- Fecha máxima de solicitudes
DEFINE dFechaMin		DATE;			  -- Fecha mínima de solicitudes
DEFINE iNumReg			INTEGER;		  -- Número de registros
DEFINE sCuantos    		SMALLINT;         -- Contador de registros
DEFINE cRazonSocial     CHAR(40);         -- Razón social
DEFINE cNombre1         CHAR(40);	      -- Primer nombre
DEFINE cNombre2         CHAR(40);	      -- Segundo nombre
DEFINE cApellidoPaterno CHAR(40);	      -- Apellido paterno
DEFINE cApellidoMaterno CHAR(40);	      -- Apellido materno
DEFINE iNumRegCons  	INTEGER;          -- Número de registros de consulta general
DEFINE cComentario2     CHAR(255);        -- Comentario de la autorización
DEFINE cEstatusCompIni  CHAR(2);          -- Variable para comparación por el filtro estatus
DEFINE cEstatusCompFin  CHAR(2);          -- Variable para comparación por el filtro estatus
DEFINE cSucCompIni      CHAR(4);          -- Variable para comparación por el filtro de sucursal
DEFINE cSucCompFin      CHAR(4);          -- Variable para comparación por el filtro de sucursal
DEFINE cCteCompIni      CHAR(20);         -- Variable para comparación por el filtro de cliente
DEFINE cCteCompFin      CHAR(20);         -- Variable para comparación por el filtro de cliente
DEFINE cProdCompIni     CHAR(4);          -- Variable para comparación por el filtro de producto
DEFINE cProdCompFin     CHAR(4);          -- Variable para comparación por el filtro de producto

-- ****************************************************************************
-- *           ASIGNACION DE VALORES POR DEFAULT A VARIABLES                  *
-- ****************************************************************************
LET isqlerr     		= 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";

LET cCodRet     		= "000000";
LET cMens_Ret           = "Proceso realizado con exito";
LET cNumSol     		= "";
LET cNumCte     		= "";
LET cNombre     		= "";
LET cRfc        		= "";
LET dFechaSol   		= "";
LET dFechaAut   		= "";
LET cProducto			= "";
LET cProdDesc			= "";
LET mLinea      		= 0;
LET cStatus    	 		= "";
LET cStDesc     		= "";
LET cComentario 		= "";
LET cDiaCorte   		= "";
LET cDivisa     		= "";
LET mIngreso    		= 0;
LET iCuentaCap		    = 0;

LET dFechaHoy   		= "";
LET sDias_rt     		= 0;
LET sDias_at     		= 0;
LET dFechaMax			= DATE(1);
LET dFechaMin			= DATE(1);
LET iNumReg				= 0;
LET sCuantos    		= 0;
LET cRazonSocial        = "";
LET cNombre1          	= "";
LET cNombre2          	= "";
LET cApellidoPaterno  	= "";
LET cApellidoMaterno  	= "";
LET iNumRegCons  		= 0;
LET cComentario2        = "";
LET cEstatusCompIni     = "A";
LET cEstatusCompFin     = "ZZ";
LET cSucCompIni         = "0";
LET cSucCompFin         = "9999";
LET cCteCompIni         = "0";
LET cCteCompFin         = "99999999999999999999";
LET cProdCompIni        = "0";
LET cProdCompFin        = "9999";


-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

BEGIN
ON EXCEPTION SET isqlerr, iIsamErr, cErrorInfo
   IF isqlerr != 0 THEN
      LET cCodRet=isqlerr;
      LET cMens_Ret = cErrorInfo;
       RETURN NVL(cCodRet,""), NVL(cMens_Ret,""), NVL(cNumSol,""), NVL(cNumCte,""), NVL(cNombre,""),
             NVL(cRfc,""), NVL(dFechaSol,DATE(1)), NVL(dFechaAut,""), NVL(cProducto,""),
             NVL(cProdDesc,""), NVL(mLinea,0), NVL(cStatus,""), NVL(cStDesc,""),
             NVL(cComentario,""), NVL(cDiaCorte,""), NVL(cDivisa,""), NVL(mIngreso,0), NVL(iCuentaCap,0);
   END IF;
END EXCEPTION;

-- SET DEBUG FILE TO '/pisa/pisabanco/pisa_ftes/envia_monitorsol_pp_pba.out';
-- TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
   SELECT empresa
     INTO pEmpresa
     FROM bdinteg:si_empresas
    WHERE empresa = pEmpresa;

    IF NVL(pEmpresa,"") = "" OR NVL(pEmpresa,'') = '' THEN
      LET cCodRet   = "000001";
      LET cMens_Ret = "El número de empresa no es valido";
      RETURN NVL(cCodRet,""), NVL(cMens_Ret,""), NVL(cNumSol,""), NVL(cNumCte,""), NVL(cNombre,""),
             NVL(cRfc,""), NVL(dFechaSol,DATE(1)), NVL(dFechaAut,""), NVL(cProducto,""),
             NVL(cProdDesc,""), NVL(mLinea,0), NVL(cStatus,""), NVL(cStDesc,""),
             NVL(cComentario,""), NVL(cDiaCorte,""), NVL(cDivisa,""), NVL(mIngreso,0), NVL(iCuentaCap,0);
    ELSE
       LET pEmpresa = TRIM(pEmpresa);
    END IF;

    -- Carga la Fecha del Dia
    SELECT fecha_hoy
      INTO dFechaHoy
      FROM bdicred:sd_fechas
     WHERE empresa = pEmpresa;

    -- Carga parámetro de días de vigencia de rechazadas
    SELECT valor
      INTO sDias_rt
      FROM bdisolic:ss_param
     WHERE secuencia = 20
       AND empresa = pEmpresa;

    IF NVL(sDias_rt,0) = 0 THEN
      LET cCodRet   = "000002";
      LET cMens_Ret = "No existe el parámetro de días de vigencia de solicitudes rechazadas";
      RETURN NVL(cCodRet,""), NVL(cMens_Ret,""), NVL(cNumSol,""), NVL(cNumCte,""), NVL(cNombre,""),
             NVL(cRfc,""), NVL(dFechaSol,DATE(1)), NVL(dFechaAut,""), NVL(cProducto,""),
             NVL(cProdDesc,""), NVL(mLinea,0), NVL(cStatus,""), NVL(cStDesc,""),
             NVL(cComentario,""), NVL(cDiaCorte,""), NVL(cDivisa,""), NVL(mIngreso,0), NVL(iCuentaCap,0);
    END IF;

    -- Carga parámetro de días de vigencia de autorizadas
    SELECT valor
      INTO sDias_at
      FROM bdisolic:ss_param
     WHERE secuencia = 21
       AND empresa = pEmpresa;

    IF NVL(sDias_at,0) = 0 THEN
      LET cCodRet   = "000003";
      LET cMens_Ret = "No existe el parámetro de días de vigencia de solicitudes autorizadas";
      RETURN NVL(cCodRet,""), NVL(cMens_Ret,""), NVL(cNumSol,""), NVL(cNumCte,""), NVL(cNombre,""),
             NVL(cRfc,""), NVL(dFechaSol,DATE(1)), NVL(dFechaAut,""), NVL(cProducto,""),
             NVL(cProdDesc,""), NVL(mLinea,0), NVL(cStatus,""), NVL(cStDesc,""),
             NVL(cComentario,""), NVL(cDiaCorte,""), NVL(cDivisa,""), NVL(mIngreso,0), NVL(iCuentaCap,0);
    END IF;

-- Comparación para la asignación del rango de fechas.
IF (TRIM(NVL(pFechaIni,"")) = "" OR TRIM(NVL(pFechaFin,"")) = "") OR (( TRIM(NVL(pFechaIni,'')) = '') OR  (TRIM(NVL(pFechaFin,'')) = '')) THEN
    LET dFechaMax = dFechaHoy;
ELSE
    LET dFechaMin = TRIM(pFechaIni);
    LET dFechaMax = TRIM(pFechaFin);
END IF;

-- Comparación para la asignación del rango de fechas.
IF TRIM(NVL(pEstatus,"")) <> "" OR TRIM(NVL(pEstatus,'')) <> ''THEN
    LET cEstatusCompIni = TRIM(pEstatus);
    LET cEstatusCompFin = TRIM(pEstatus);
END IF;

IF TRIM(NVL(pNumcte,"")) <> ""  OR TRIM(NVL(pNumcte,'')) <> '' THEN
    LET cCteCompIni = TRIM(pNumcte);
    LET cCteCompFin = TRIM(pNumcte);
ELIF TRIM(NVL(pSucursal,"")) <> "" OR TRIM(NVL(pSucursal,'')) <> '' THEN
    LET cSucCompIni = TRIM(pSucursal);
    LET cSucCompFin = TRIM(pSucursal);
END IF;

IF TRIM(NVL(pProducto,"")) <> "" OR TRIM(NVL(pProducto,'')) <> '' THEN
    LET cProdCompIni = TRIM(pProducto);
    LET cProdCompFin = TRIM(pProducto);
END IF;

FOREACH with HOLD
     SELECT skip pSolicitudes limit 15
			x.descripcion,
            a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
            (CASE when a.monto_solicitado<a.monto_autorizado then a.monto_solicitado else a.monto_autorizado end), a.fecha_insert,
            c.motivo_cc, c.ingreso_mensual,
            e.fecha_entrada, e.comentario,
            f.nombre_prod, f.divisa,
            b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc
       INTO cStDesc,
            cNumSol, cNumCte, cStatus, cProducto, mLinea, dFechaSol,
            cComentario, mIngreso,
            dFechaAut, cComentario2,
            cProdDesc, cDivisa,
            cApellidoPaterno, cApellidoMaterno, cNombre1, cNombre2, cRazonSocial, cRfc
       FROM bdisolic:ss_solicitudes a
 INNER JOIN bdinteg:si_cliente b          ON (a.numcte  = b.numcte  AND a.empresa = a.empresa)
 INNER JOIN bdisolic:ss_resum_scor_fin c  ON (c.empresa = a.empresa AND c.num_solicitud = a.num_solicitud)
 INNER JOIN bdisolic:ss_anexosol d        ON (d.empresa = a.empresa AND d.num_solicitud = a.num_solicitud)
 INNER JOIN bdisolic:ss_status_sol x      ON (x.empresa = a.empresa AND x.status_solicitud= a.status_solicitud)
  LEFT JOIN bdisolic:ss_autorizacion e    ON (e.empresa = a.empresa AND e.num_solicitud = a.num_solicitud
                                              AND e.status_solicitud  = a.status_solicitud
                                              AND NVL(e.fecha_entrada,dFechaHoy) = (SELECT NVL(MAX(NVL(h.fecha_entrada,dFechaHoy)),dFechaHoy)
                                                                                    FROM bdisolic:ss_autorizacion h
                                                                                   WHERE h.empresa           = a.empresa
                                                                                     AND h.num_solicitud     = a.num_solicitud
                                                                                     AND h.status_solicitud  = a.status_solicitud)
                                              AND (((NVL(e.fecha_entrada,dFechaHoy) >= dFechaHoy - sDias_rt) AND a.status_solicitud = "RT")
                                                    OR ((NVL(e.fecha_entrada,dFechaHoy) >= dFechaHoy - sDias_at) AND a.status_solicitud = "AT")
                                                    OR (a.status_solicitud NOT IN ("AT","RT"))))
 INNER JOIN bdicred:sd_definicion f      ON (f.num_producto = a.num_producto AND f.empresa = a.empresa)
     WHERE a.num_solicitud > 0
       AND a.empresa = pEmpresa
       AND a.numcte >= cCteCompIni AND a.numcte <= cCteCompFin
       AND a.sucursal >= cSucCompIni AND a.sucursal <= cSucCompFin
       AND a.status_solicitud >= cEstatusCompIni AND a.status_solicitud <= cEstatusCompFin
       AND a.status_solicitud IN ("AT","RT","CC","BC","OS","EE","OA","EA","CE","CM")
       AND a.num_producto >= cProdCompIni AND a.num_producto <= cProdCompFin
       AND a.tipo_solicitud = 'P'
       AND a.fecha_insert BETWEEN dFechaMin AND dFechaMax
  ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, e.fecha_entrada

        -- SE ARMA EL NOMBRE DEL CLIENTE
        LET cNombre = TRIM(NVL(cNombre1,"")) || " " || TRIM(NVL(cNombre2,"")) || " " || TRIM(NVL(cApellidoPaterno,"")) || " " || TRIM(NVL(cApellidoMaterno,""));

        LET cComentario = TRIM(TRIM(NVL(cComentario2,"")) || " " || TRIM(NVL(cComentario,"")));

        -- SE VERIFICA QUE EL CLIENTE TENGA CUENTAS DE CAPTACION ACTIVAS
          SELECT LIMIT 1 1
            INTO iCuentaCap
            FROM bdicheq:sc_maechq a
       LEFT JOIN bdicheq:sc_ctabloqueo b         ON (b.cuenta = a.cuenta)
       LEFT JOIN bdicheq:sc_bloqueo c            ON (c.codigo = b.clave)
      INNER JOIN bdisolic:ss_producto_credcap d  ON (d.empresa = a.empresa AND d.producto_cap = a.producto)
      INNER JOIN bdisolic:ss_solic_producto e    ON (e.empresa = a.empresa AND e.tp_solicitud = 'P' AND e.num_producto = cProducto)
           WHERE a.cuenta  > 0
             AND a.empresa = pEmpresa
             AND a.num_cte = cNumCte
             AND d.num_producto = e.num_producto
             AND NVL(opcion,"00") = "00"
             AND NVL(c.codigo,"00") = "00"
             AND a.status_cta = "1";

                LET iNumReg = DBINFO("sqlca.sqlerrd2");

                    IF iNumReg = 0 THEN
                        LET iCuentaCap = 0;
                    END IF;

                    IF cStatus <> "AT" THEN
                        LET dFechaAut = "";
                        LET mLinea = 0;
                    END IF;

                    -- Se obtiene el día de corte
                    LET cDiaCorte = LPAD(DAY(dFechaAut),2,0);

					--   LET sCuantos = sCuantos + 1;
				--IF sCuantos <= pSolicitudes THEN
                   --    CONTINUE FOREACH;
                 --  END IF;
               

                    RETURN NVL(cCodRet,""), NVL(cMens_Ret,""), NVL(cNumSol,""), NVL(cNumCte,""), NVL(cNombre,""),
                           NVL(cRfc,""), NVL(dFechaSol,DATE(1)), NVL(dFechaAut,""), NVL(cProducto,""),
                           NVL(cProdDesc,""), NVL(mLinea,0), NVL(cStatus,""), NVL(cStDesc,""),
                           NVL(cComentario,""), NVL(cDiaCorte,""), NVL(cDivisa,""), NVL(mIngreso,0), NVL(iCuentaCap,0) 
						   WITH RESUME;
						   
						
END FOREACH;

LET iNumRegCons = DBINFO("sqlca.sqlerrd2");
IF iNumRegCons = 0 THEN
    LET cCodRet   = "000004";
    LET cMens_Ret = 'No se encontró información con el filtro seleccionado';
 RETURN NVL(cCodRet,""), NVL(cMens_Ret,""), NVL(cNumSol,""), NVL(cNumCte,""), NVL(cNombre,""),
                           NVL(cRfc,""), NVL(dFechaSol,DATE(1)), NVL(dFechaAut,""), NVL(cProducto,""),
                           NVL(cProdDesc,""), NVL(mLinea,0), NVL(cStatus,""), NVL(cStDesc,""),
                           NVL(cComentario,""), NVL(cDiaCorte,""), NVL(cDivisa,""), NVL(mIngreso,0), NVL(iCuentaCap,0);
END IF;
END;
END PROCEDURE
