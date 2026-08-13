CREATE PROCEDURE "informix".envia_monitorsol_pp_ss_mov
													(pEmpresa     CHAR(3),
													 pSucursal    CHAR(20),
													 pSolicitudes SMALLINT,
													 pNumcte      CHAR(20),
													 pProducto	  CHAR(4),
													 pEstatus	  CHAR(2),
													 pLimit		  SMALLINT,
													 pFechaIni DATE, 
													 pFechaFin DATE
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
            INTEGER		    AS EsCtaCap,        -- Valor para identificar si tiene o no cuenta de captación
			CHAR(20)  	    AS NumCuenta,		-- numero de cuenta
			INTEGER		    AS FrecuenciaPago,  -- frecuencia de pago de nomina
			INTEGER		    AS DiaPago,         -- dia de pago		
			INTEGER         AS dias_vigencia;   -- dias de vigencia		

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
DEFINE vdias_vigencia 	INTEGER;          -- Dias de vigencia

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
DEFINE cProdCompIni     CHAR(4);          -- Variable para comparación por el filtro de producto
DEFINE cProdCompFin     CHAR(4);          -- Variable para comparación por el filtro de producto
--VARIABLES PARA CREDINOMINA
DEFINE cCuenta_eje      CHAR(20);
DEFINE iFrecuencia      INTEGER;
DEFINE iDiaPago         INTEGER;
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
LET vdias_vigencia 	    = 0;

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
LET cProdCompIni        = "6300";
LET cProdCompFin        = "7700";
--VARIABLES PARA CREDINOMINA
LET cCuenta_eje         = "";
LET iFrecuencia         = 1;
LET iDiaPago        	= 0;

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
			NVL(cComentario,""), NVL(cDiaCorte,""), NVL(cDivisa,""), NVL(mIngreso,0), NVL(iCuentaCap,0),
			NVL(cCuenta_eje,""), NVL(iFrecuencia,0), NVL(iDiaPago,0), NVL(vdias_vigencia,0);
   END IF;
END EXCEPTION;

	--SET DEBUG FILE TO "/informix/jesus/envia_monitorsol_pp_ss.out";
	--TRACE ON;
	SET ISOLATION TO DIRTY READ;
        --SET ISOLATION TO COMMITTED READ LAST COMMITTED;
	SET LOCK MODE TO WAIT 3;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
	SELECT empresa
	INTO pEmpresa
	FROM bdinteg:"informix".si_empresas
	WHERE empresa = pEmpresa;

    IF NVL(pEmpresa,"") = "" OR NVL(pEmpresa,'') = '' THEN
      LET cCodRet   = "000001";
      LET cMens_Ret = "El número de empresa no es valido";

		RETURN NVL(cCodRet,""), NVL(cMens_Ret,""), NVL(cNumSol,""), NVL(cNumCte,""), NVL(cNombre,""),
			NVL(cRfc,""), NVL(dFechaSol,DATE(1)), NVL(dFechaAut,""), NVL(cProducto,""),
			NVL(cProdDesc,""), NVL(mLinea,0), NVL(cStatus,""), NVL(cStDesc,""),
			NVL(cComentario,""), NVL(cDiaCorte,""), NVL(cDivisa,""), NVL(mIngreso,0), NVL(iCuentaCap,0),
			NVL(cCuenta_eje,""), NVL(iFrecuencia,0), NVL(iDiaPago,0), NVL(vdias_vigencia,0);
    ELSE
       LET pEmpresa = TRIM(pEmpresa);
    END IF;

   -- Carga la Fecha del Dia
	SELECT fecha_hoy
	INTO dFechaHoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = pEmpresa;

    -- Carga parámetro de días de vigencia de rechazadas
	SELECT valor
	INTO sDias_rt
	FROM "informix".ss_param
	WHERE secuencia = 20
	AND empresa = pEmpresa;

    IF NVL(sDias_rt,0) = 0 THEN
      LET cCodRet   = "000002";
      LET cMens_Ret = "No existe el parámetro de días de vigencia de solicitudes rechazadas";

		RETURN NVL(cCodRet,""), NVL(cMens_Ret,""), NVL(cNumSol,""), NVL(cNumCte,""), NVL(cNombre,""),
			NVL(cRfc,""), NVL(dFechaSol,DATE(1)), NVL(dFechaAut,""), NVL(cProducto,""),
			NVL(cProdDesc,""), NVL(mLinea,0), NVL(cStatus,""), NVL(cStDesc,""),
			NVL(cComentario,""), NVL(cDiaCorte,""), NVL(cDivisa,""), NVL(mIngreso,0), NVL(iCuentaCap,0),
			NVL(cCuenta_eje,""), NVL(iFrecuencia,0), NVL(iDiaPago,0), NVL(vdias_vigencia,0);
    END IF;

    -- Carga parámetro de días de vigencia de autorizadas
	SELECT valor
	INTO sDias_at
	FROM "informix".ss_param
	WHERE secuencia = 21
	AND empresa = pEmpresa;

    IF NVL(sDias_at,0) = 0 THEN
      LET cCodRet   = "000003";
      LET cMens_Ret = "No existe el parámetro de días de vigencia de solicitudes autorizadas";

		RETURN NVL(cCodRet,""), NVL(cMens_Ret,""), NVL(cNumSol,""), NVL(cNumCte,""), NVL(cNombre,""),
			NVL(cRfc,""), NVL(dFechaSol,DATE(1)), NVL(dFechaAut,""), NVL(cProducto,""),
			NVL(cProdDesc,""), NVL(mLinea,0), NVL(cStatus,""), NVL(cStDesc,""),
			NVL(cComentario,""), NVL(cDiaCorte,""), NVL(cDivisa,""), NVL(mIngreso,0), NVL(iCuentaCap,0),
			NVL(cCuenta_eje,""), NVL(iFrecuencia,0), NVL(iDiaPago,0), NVL(vdias_vigencia,0);
    END IF;

	IF TRIM(NVL(pEstatus,"")) <> "" OR TRIM(NVL(pEstatus,'')) <> ''THEN
		LET cEstatusCompIni = TRIM(pEstatus);
		LET cEstatusCompFin = TRIM(pEstatus);
	END IF;

	IF TRIM(NVL(pProducto,"")) <> "" OR TRIM(NVL(pProducto,'')) <> '' THEN
		LET cProdCompIni = TRIM(pProducto);
		LET cProdCompFin = TRIM(pProducto);
	END IF;

	IF pNumcte IS NULL OR pNumcte = "" THEN -- Consulta por Sucursal 
		-- AAME 20150317 RQM 10 550 Se agrega el filtro por tipo de solicitud de prestamo y además se cambia el valor final del producto (cProdCompFin=7700) 
		FOREACH WITH HOLD
			SELECT skip pSolicitudes LIMIT pLimit				
				a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_autorizado, a.fecha_insert, 
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc
			INTO cNumSol, cNumCte, cStatus, cProducto, mLinea, dFechaSol,
				cApellidoPaterno, cApellidoMaterno, cNombre1, cNombre2, cRazonSocial, cRfc
			FROM  "informix".ss_solicitudes_movil 	e  
			INNER JOIN  "informix".ss_solicitudes a ON (a.empresa = e.empresa 
													and a.sucursal = e.sucursal 
													AND a.num_solicitud = e.num_solicitud
													And a.status_solicitud >= cEstatusCompIni AND a.status_solicitud <= cEstatusCompFin
													AND a.num_producto >= cProdCompIni AND a.num_producto <= cProdCompFin
													AND a.tipo_solicitud = 'P'
													AND a.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','PA','CN')	)
			INNER JOIN "informix".ss_autorizacion c on (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud and a.status_solicitud = c.status_solicitud and fecha_entrada = 
                                                           (SELECT MAX(fecha_entrada) FROM "informix".ss_autorizacion h
                                                            WHERE c.empresa           = empresa
									   	                    AND c.num_solicitud     = num_solicitud
											                AND c.status_solicitud  = status_solicitud)
                                                              AND c.fecha_entrada >= CASE WHEN NVL(pFechaIni,'') = '' THEN  dFechaHoy - 10 ELSE pFechaIni END
															AND c.fecha_entrada <= CASE WHEN NVL(pFechaFin,'') = '' THEN  dFechaHoy ELSE  pFechaFin END)
			INNER JOIN bdinteg:"informix".si_cliente b ON (a.numcte  = b.numcte  )
			WHERE e.empresa =a.empresa
			AND e.folio_movil > ''
			AND e.producto = a.num_producto
			AND  e.num_solicitud = a.num_solicitud  
			ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, a.num_solicitud
		  
			-- SE ARMA EL NOMBRE DEL CLIENTE
			LET cNombre = TRIM(NVL(cNombre1,"")) || " " || TRIM(NVL(cNombre2,"")) || " " || TRIM(NVL(cApellidoPaterno,"")) || " " || TRIM(NVL(cApellidoMaterno,""));

            SELECT 
				x.descripcion,
				c.motivo_cc, c.ingreso_mensual , e.fecha_entrada, e.comentario , f.nombre_prod, f.divisa ,				
                 ( select nom.cuenta from "informix".ss_sol_nomina nom where nom.empresa = pEmpresa
                    AND nom.num_solicitud =  cNumSol ) , 
                 ( select nom.Frecuencia_pgo from "informix".ss_sol_nomina nom where nom.empresa = pEmpresa
                    AND nom.num_solicitud =  cNumSol ) , 
                 ( select nom.dia_pago from "informix".ss_sol_nomina nom where nom.empresa = pEmpresa
                    AND nom.num_solicitud =  cNumSol )  
                 
			INTO cStDesc, cComentario, mIngreso, dFechaAut, cComentario2,
				cProdDesc, cDivisa,	cCuenta_eje,iFrecuencia,iDiaPago
			FROM "informix".ss_resum_scor_fin c, "informix".ss_autorizacion e, bdicred:"informix".sd_definicion f , "informix".ss_status_sol x
            WHERE c.empresa = pEmpresa
              AND c.num_solicitud = cNumSol
              AND e.empresa = c.empresa 
              AND e.num_solicitud = c.num_solicitud
			        AND e.status_solicitud = cStatus
			        AND e.fecha_entrada = (SELECT MAX(h.fecha_entrada) FROM "informix".ss_autorizacion h
                                      WHERE h.empresa           = pEmpresa--c.empresa
										                  AND h.num_solicitud     = cNumSol
											                AND h.status_solicitud  = cStatus) --c.status_solicitud)
              AND f.num_producto = cProducto
              AND f.empresa = pEmpresa
              and x.empresa = pEmpresa
              AND x.status_solicitud= cStatus;
			

			LET cComentario = TRIM(TRIM(NVL(cComentario2,"")) || " " || TRIM(NVL(cComentario,"")));

			-- SE VERIFICA QUE EL CLIENTE TENGA CUENTAS DE CAPTACION ACTIVAS
			SELECT LIMIT 1 1
			INTO iCuentaCap
			FROM bdicheq:"informix".sc_maechq a
			LEFT JOIN bdicheq:"informix".sc_ctabloqueo b         ON (b.cuenta = a.cuenta)
			LEFT JOIN bdicheq:"informix".sc_bloqueo c            ON (c.codigo = b.clave)
			INNER JOIN "informix".ss_producto_credcap d  ON (d.empresa = a.empresa AND d.producto_cap = a.producto)
			INNER JOIN "informix".ss_solic_producto e    ON (e.empresa = a.empresa AND e.tp_solicitud = 'P' AND e.num_producto = cProducto)
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
			
			IF dFechaAut IS NULL THEN
				LET dFechaAut = DATE(1);
			END IF;
				
			LET vdias_vigencia = NVL(dFechaHoy - dFechaAut,0);

			IF cStatus <> "AT" THEN
				LET dFechaAut = "";
				LET mLinea = 0;
			END IF;

			-- Se obtiene el día de corte
			LET cDiaCorte = LPAD(DAY(dFechaAut),2,0);

			RETURN NVL(cCodRet,""), NVL(cMens_Ret,""), NVL(cNumSol,""), NVL(cNumCte,""), NVL(cNombre,""),
				   NVL(cRfc,""), NVL(dFechaSol,DATE(1)), NVL(dFechaAut,""), NVL(cProducto,""),
				   NVL(cProdDesc,""), NVL(mLinea,0), NVL(cStatus,""), NVL(cStDesc,""),
				   NVL(cComentario,""), NVL(cDiaCorte,""), NVL(cDivisa,""), NVL(mIngreso,0), NVL(iCuentaCap,0),
				   NVL(cCuenta_eje,""), NVL(iFrecuencia,1), NVL(iDiaPago,0), NVL(vdias_vigencia,0) WITH RESUME;
		END FOREACH;
		
	ELSE -- Consulta por Cliente
		-- AAME 20150317 RQM 10 550 Se agrega el filtro por tipo de solicitud de prestamo y además se cambia el valor final del producto (cProdCompFin=7700) 
		FOREACH WITH HOLD
			SELECT skip pSolicitudes LIMIT pLimit				
				a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_autorizado, a.fecha_insert, 
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc
			INTO cNumSol, cNumCte, cStatus, cProducto, mLinea, dFechaSol,
				cApellidoPaterno, cApellidoMaterno, cNombre1, cNombre2, cRazonSocial, cRfc
			FROM  "informix".ss_solicitudes_movil 	e  
			INNER JOIN  "informix".ss_solicitudes a ON (a.empresa = e.empresa 
													and a.sucursal = e.sucursal 
													AND a.num_solicitud = e.num_solicitud
													And a.status_solicitud >= cEstatusCompIni AND a.status_solicitud <= cEstatusCompFin
													AND a.num_producto >= cProdCompIni AND a.num_producto <= cProdCompFin
													AND a.tipo_solicitud = 'P'
													AND a.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','PA','CN')	)
			INNER JOIN bdinteg:"informix".si_cliente b          ON (a.numcte  = b.numcte  )
			WHERE e.numcte = pNumcte
			AND e.empresa =a.empresa
			AND e.folio_movil > ''
			AND e.producto = a.num_producto
			AND  e.num_solicitud = a.num_solicitud  
			ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, a.num_solicitud
		
			SELECT 
				x.descripcion,
				c.motivo_cc, c.ingreso_mensual , e.fecha_entrada, e.comentario , f.nombre_prod, f.divisa ,				
                 ( select nom.cuenta from "informix".ss_sol_nomina nom where nom.empresa = pEmpresa
                    AND nom.num_solicitud =  cNumSol ) , 
                 ( select nom.Frecuencia_pgo from "informix".ss_sol_nomina nom where nom.empresa = pEmpresa
                    AND nom.num_solicitud =  cNumSol ) , 
                 ( select nom.dia_pago from "informix".ss_sol_nomina nom where nom.empresa = pEmpresa
                    AND nom.num_solicitud =  cNumSol )  
                 
			INTO cStDesc, cComentario, mIngreso, dFechaAut, cComentario2,
				cProdDesc, cDivisa,	cCuenta_eje,iFrecuencia,iDiaPago
			FROM "informix".ss_resum_scor_fin c, "informix".ss_autorizacion e, bdicred:"informix".sd_definicion f , "informix".ss_status_sol x
            WHERE c.empresa = pEmpresa
              AND c.num_solicitud = cNumSol
              AND e.empresa = c.empresa 
              AND e.num_solicitud = c.num_solicitud
			        AND e.status_solicitud = cStatus
			        AND e.fecha_entrada = (SELECT MAX(h.fecha_entrada) FROM "informix".ss_autorizacion h
                                      WHERE h.empresa           = pEmpresa--c.empresa
										                  AND h.num_solicitud     = cNumSol
											                AND h.status_solicitud  = cStatus) --c.status_solicitud)
              AND f.num_producto = cProducto
              AND f.empresa = pEmpresa
              and x.empresa = pEmpresa
              AND x.status_solicitud= cStatus;
			
		  
				-- SE ARMA EL NOMBRE DEL CLIENTE
				LET cNombre = TRIM(NVL(cNombre1,"")) || " " || TRIM(NVL(cNombre2,"")) || " " || TRIM(NVL(cApellidoPaterno,"")) || " " || TRIM(NVL(cApellidoMaterno,""));

				LET cComentario = TRIM(TRIM(NVL(cComentario2,"")) || " " || TRIM(NVL(cComentario,"")));

				-- SE VERIFICA QUE EL CLIENTE TENGA CUENTAS DE CAPTACION ACTIVAS
				SELECT LIMIT 1 1
				INTO iCuentaCap
				FROM bdicheq:"informix".sc_maechq a
				LEFT JOIN bdicheq:"informix".sc_ctabloqueo b         ON (b.cuenta = a.cuenta)
				LEFT JOIN bdicheq:"informix".sc_bloqueo c            ON (c.codigo = b.clave)
				INNER JOIN "informix".ss_producto_credcap d  ON (d.empresa = a.empresa AND d.producto_cap = a.producto)
				INNER JOIN "informix".ss_solic_producto e    ON (e.empresa = a.empresa AND e.tp_solicitud = 'P' AND e.num_producto = cProducto)
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
				
				IF dFechaAut IS NULL THEN
					LET dFechaAut = DATE(1);
				END IF;
				
				LET vdias_vigencia = NVL(dFechaHoy - dFechaAut,0);

				IF cStatus <> "AT" THEN
					LET dFechaAut = "";
					LET mLinea = 0;
				END IF;
				-- Se obtiene el día de corte
				LET cDiaCorte = LPAD(DAY(dFechaAut),2,0);

				RETURN NVL(cCodRet,""), NVL(cMens_Ret,""), NVL(cNumSol,""), NVL(cNumCte,""), NVL(cNombre,""),
					   NVL(cRfc,""), NVL(dFechaSol,DATE(1)), NVL(dFechaAut,""), NVL(cProducto,""),
					   NVL(cProdDesc,""), NVL(mLinea,0), NVL(cStatus,""), NVL(cStDesc,""),
					   NVL(cComentario,""), NVL(cDiaCorte,""), NVL(cDivisa,""), NVL(mIngreso,0), NVL(iCuentaCap,0),
					   NVL(cCuenta_eje,""), NVL(iFrecuencia,1), NVL(iDiaPago,0), NVL(vdias_vigencia,0) WITH RESUME;  --DSB 28/06/2012
		END FOREACH;
	
	END IF;
END;
END PROCEDURE
