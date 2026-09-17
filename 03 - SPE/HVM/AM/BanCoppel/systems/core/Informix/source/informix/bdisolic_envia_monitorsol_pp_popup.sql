CREATE PROCEDURE "informix".envia_monitorsol_pp_popup(pEmpresa		CHAR(3),
													pSucursal		CHAR(20),
													pSolicitudes	SMALLINT,
													pNumcte      	CHAR(20),
													pProducto	  	CHAR(4),
													pEstatus	  	CHAR(2),
													pLimit		  	SMALLINT,
													pFechaIni 		DATE,
													pFechaFin 		DATE)
RETURNING 	CHAR(6)         AS CodRetorno,  	-- Codigo de retorno
            CHAR(54)        AS Mensaje_Retorno, -- Mensaje de retorno
            CHAR(20)	    AS NumSolicitud, 	-- Nro de solicitud
            CHAR(20)  	    AS NumCliente, 		-- Nro de cliente
            CHAR(120) 	    AS NombreCliente,  	-- Nombre del cliente
            CHAR(15)	    AS RFC,   			-- R.F.C.
            DATE		    AS FechaSol,		-- Fecha de solicitud
            DATE		    AS FechaAut,       	-- Fecha autorizacion
            CHAR(4)         AS Producto,		-- CÃ³digo de producto
            CHAR(40)	    AS ProdDes,			-- Descripcion del producto
            MONEY(14,2)     AS LineaOtorgada,  	-- Linea otorgada
            CHAR(2)	        AS Estatus,      	-- Status de la solicitud
            CHAR(60)	    AS EstatusDes,     	-- Descripcion del status de la solicitud
            CHAR(255)	    AS Comentario,    	-- Comentario
            CHAR(2)	        AS DiaCorte,      	-- Dia de corte
            CHAR(2)	        AS Divisa,      	-- Divisa
            MONEY(14,2)     AS IngresoCliente,  -- Ingreso del cliente
            INTEGER		    AS EsCtaCap,        -- Valor para identificar si tiene o no cuenta de captaciÃ³n
			CHAR(20)  	    AS NumCuenta,		-- numero de cuenta
			INTEGER		    AS FrecuenciaPago,  -- frecuencia de pago de nomina
			INTEGER		    AS DiaPago,         -- dia de pago		
			INTEGER         AS dias_vigencia,   -- dias de vigencia		
			CHAR(4)			AS CausaSolicitud,  -- Causa de solicitud.
			CHAR(100)		AS DescripcionSol; -- Descripcion de solicitud.
-- Variables de control de errores
DEFINE isqlerr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);

-- Variables para valores de retorno
DEFINE cCodRet     		CHAR(6); 	      -- CÃ³digo de retorno de error
DEFINE cMens_Ret        CHAR(54);         -- Mensajes de error
DEFINE cNumSol     		CHAR(20);         -- nÃºmero de solicitud
DEFINE cNumCte     		CHAR(20);	      -- nÃºmero de cliente
DEFINE cNombre     		CHAR(110);        -- Nombre del cliente
DEFINE cRfc        		CHAR(15);	      -- RFC
DEFINE dFechaSol  		DATE;			  -- Fecha de solicitud
DEFINE dFechaAut   		DATE;			  -- Fecha de autorizaciÃ³n
DEFINE cProducto		CHAR(4);	      -- CÃ³digo de producto
DEFINE cProdDesc		CHAR(40);	      -- DescripciÃ³n del producto
DEFINE mLinea      		MONEY(14,2);	  -- LÃ­nea de crÃ©dito autorizada
DEFINE cStatus     		CHAR(2);	      -- CÃ³digo de estatus de la solicitud
DEFINE cStDesc     		CHAR(50);	      -- DescripciÃ³n de estatus de la solicitud
DEFINE cComentario 		CHAR(255);	      -- Comentario
DEFINE cDiaCorte   		CHAR(2);	      -- dÃ­a de corte
DEFINE cDivisa     		CHAR(2);	      -- Divisa
DEFINE mIngreso    		MONEY(14,2);	  -- Ingreso
DEFINE iCuentaCap  		INTEGER;		  -- Cuenta de captaciÃ³n
DEFINE vdias_vigencia 	INTEGER;          -- Dias de vigencia
DEFINE iContPP1824 		INTEGER;  

--VARIABLES AUXILIARES
DEFINE dFechaHoy   		DATE;			  -- Fecha Actual
DEFINE sDias_rt     	SMALLINT;		  -- dÃ­as que lleva rechazada
DEFINE sDias_at     	SMALLINT;		  -- dÃ­as que lleva autorizada
DEFINE dFechaMax		DATE;			  -- Fecha mÃ¡xima de solicitudes
DEFINE dFechaMin		DATE;			  -- Fecha mÃ­nima de solicitudes
DEFINE iNumReg			INTEGER;		  -- nÃºmero de registros
DEFINE sCuantos    		SMALLINT;         -- Contador de registros
DEFINE cRazonSocial     CHAR(40);         -- RazÃ³n social
DEFINE cNombre1         CHAR(40);	      -- Primer nombre
DEFINE cNombre2         CHAR(40);	      -- Segundo nombre
DEFINE cApellidoPaterno CHAR(40);	      -- Apellido paterno
DEFINE cApellidoMaterno CHAR(40);	      -- Apellido materno
DEFINE iNumRegCons  	INTEGER;          -- nÃºmero de registros de consulta general
DEFINE cComentario2     CHAR(255);        -- Comentario de la autorizaciÃ³n
DEFINE cEstatusCompIni  CHAR(2);          -- Variable para comparaciÃ³n por el filtro estatus
DEFINE cEstatusCompFin  CHAR(2);          -- Variable para comparaciÃ³n por el filtro estatus
DEFINE cProdCompIni     CHAR(4);          -- Variable para comparaciÃ³n por el filtro de producto
DEFINE cProdCompFin     CHAR(4);          -- Variable para comparaciÃ³n por el filtro de producto
DEFINE dFechaEntradaIni DATE;			  -- Fecha Inicio de solicitudes
DEFINE dFechaEntradaFin DATE;			  -- Fecha Fin de solicitudes
--VARIABLES PARA CREDINOMINA
DEFINE cCuenta_eje      CHAR(20);
DEFINE iFrecuencia      INTEGER;
DEFINE iDiaPago         INTEGER;
DEFINE cCausasolicitud  CHAR(4);
DEFINE cDescripcionSol CHAR(100);
-- VARIABLES RQM 09 435
DEFINE cNumCteAux       CHAR(20);
DEFINE cCodRet2         CHAR(6);
DEFINE cNumSolEliminar  CHAR(20);
DEFINE cNum_ProdAux		CHAR(4);
DEFINE sSolsTot			SMALLINT;

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
LET dFechaEntradaIni	= DATE(1);
LET dFechaEntradaFin	= DATE(1);
--VARIABLES PARA CREDINOMINA
LET cCuenta_eje         = "";
LET iFrecuencia         = 1;
LET iDiaPago        	= 0;
LET cCausasolicitud 	= "";
LET iContPP1824 		= 0;
LET cDescripcionSol 	="";
-- VARIABLES RQM 09 435
LET cNumCteAux          = "";
LET cCodRet2            = "";
LET cNumSolEliminar     = "";
LET cNum_ProdAux		= '';
LET sSolsTot			= 0;

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
			NVL(cCuenta_eje,""), NVL(iFrecuencia,0), NVL(iDiaPago,0), NVL(vdias_vigencia,0),NVL(cCausasolicitud,""),NVL(cDescripcionSol,"");
   END IF;
END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysifx/Brando/envia_monitorsol_pp_PopUp.out";
	--TRACE ON;
	SET ISOLATION TO DIRTY READ;
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
      LET cMens_Ret = "El nÃºmero de empresa no es valido";

		RETURN NVL(cCodRet,""), NVL(cMens_Ret,""), NVL(cNumSol,""), NVL(cNumCte,""), NVL(cNombre,""),
			NVL(cRfc,""), NVL(dFechaSol,DATE(1)), NVL(dFechaAut,""), NVL(cProducto,""),
			NVL(cProdDesc,""), NVL(mLinea,0), NVL(cStatus,""), NVL(cStDesc,""),
			NVL(cComentario,""), NVL(cDiaCorte,""), NVL(cDivisa,""), NVL(mIngreso,0), NVL(iCuentaCap,0),
			NVL(cCuenta_eje,""), NVL(iFrecuencia,0), NVL(iDiaPago,0), NVL(vdias_vigencia,0),NVL(cCausasolicitud,""), NVL(cDescripcionSol,"");
    ELSE
       LET pEmpresa = TRIM(pEmpresa);
    END IF;
	--RQM 10 1177 Se parametriza el valor de producto min y producto max de prÃ©stamos
	SELECT MIN(num_producto) INTO cProdCompIni FROM bdicred:sd_definicion WHERE cod_tipcred= '05';
	SELECT MAX(num_producto) INTO cProdCompFin FROM bdicred:sd_definicion WHERE cod_tipcred= '05';	

   -- Carga la Fecha del Dia
	SELECT fecha_hoy
	INTO dFechaHoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = pEmpresa;

    -- Carga parÃ¡metro de dÃ­as de vigencia de rechazadas
	SELECT valor
	INTO sDias_rt
	FROM "informix".ss_param
	WHERE secuencia = 20
	AND empresa = pEmpresa;

    IF NVL(sDias_rt,0) = 0 THEN
      LET cCodRet   = "000002";
      LET cMens_Ret = "No existe el parÃ¡metro de dÃ­as de vigencia de solicitudes rechazadas";

		RETURN NVL(cCodRet,""), NVL(cMens_Ret,""), NVL(cNumSol,""), NVL(cNumCte,""), NVL(cNombre,""),
			NVL(cRfc,""), NVL(dFechaSol,DATE(1)), NVL(dFechaAut,""), NVL(cProducto,""),
			NVL(cProdDesc,""), NVL(mLinea,0), NVL(cStatus,""), NVL(cStDesc,""),
			NVL(cComentario,""), NVL(cDiaCorte,""), NVL(cDivisa,""), NVL(mIngreso,0), NVL(iCuentaCap,0),
			NVL(cCuenta_eje,""), NVL(iFrecuencia,0), NVL(iDiaPago,0), NVL(vdias_vigencia,0),NVL(cCausasolicitud,""), NVL(cDescripcionSol,"");
    END IF;

    -- Carga parÃ¡metro de dÃ­as de vigencia de autorizadas
	SELECT valor
	INTO sDias_at
	FROM "informix".ss_param
	WHERE secuencia = 21
	AND empresa = pEmpresa;

    IF NVL(sDias_at,0) = 0 THEN
      LET cCodRet   = "000003";
      LET cMens_Ret = "No existe el parÃ¡metro de dÃ­as de vigencia de solicitudes autorizadas";

		RETURN NVL(cCodRet,""), NVL(cMens_Ret,""), NVL(cNumSol,""), NVL(cNumCte,""), NVL(cNombre,""),
			NVL(cRfc,""), NVL(dFechaSol,DATE(1)), NVL(dFechaAut,""), NVL(cProducto,""),
			NVL(cProdDesc,""), NVL(mLinea,0), NVL(cStatus,""), NVL(cStDesc,""),
			NVL(cComentario,""), NVL(cDiaCorte,""), NVL(cDivisa,""), NVL(mIngreso,0), NVL(iCuentaCap,0),
			NVL(cCuenta_eje,""), NVL(iFrecuencia,0), NVL(iDiaPago,0), NVL(vdias_vigencia,0),NVL(cCausasolicitud,""), NVL(cDescripcionSol,"");
    END IF;

	IF TRIM(NVL(pEstatus,"")) <> "" OR TRIM(NVL(pEstatus,'')) <> ''THEN
		LET cEstatusCompIni = TRIM(pEstatus);
		LET cEstatusCompFin = TRIM(pEstatus);
	END IF;

	IF TRIM(NVL(pProducto,"")) <> "" OR TRIM(NVL(pProducto,'')) <> '' THEN
		LET cProdCompIni = TRIM(pProducto);
		LET cProdCompFin = TRIM(pProducto);
	END IF;

	SELECT count(num_producto)
	  INTO iContPP1824		
	  FROM bdinteg:"informix".si_prod_sucursal   
	 WHERE num_producto in ('7600','7700')
	   AND sucursal = pSucursal;
	
	
	-- 09 435 VALIDACIONES PARA LA ASIGNACION DE CREDITOS PERSONALES.
	IF NVL(pEstatus,"") = "AT" OR NVL(pNumcte,"") <> ""  THEN
	
		IF  NVL(pNumcte,"") <> "" THEN	-- Busqueda por cliente

			FOREACH WITH HOLD		
			  SELECT a.numcte, a.num_producto, count(a.numcte) INTO cNumCteAux, cNum_ProdAux, sSolsTot
			    FROM "informix".ss_solicitudes a
				JOIN bdicred:sd_definicion p ON (a.numcte = pNumcte and a.num_producto = p.num_producto and p.llena_solicitud = 'S' AND lower(p.edocta_param) = 'prestamo_personal')
			   WHERE a.status_solicitud = 'AT'																								--in ('6300','7700','7600','6800')
			   GROUP BY a.numcte, a.num_producto
		      HAVING COUNT (a.numcte) > 1
			  
				FOREACH WITH HOLD
				 SELECT num_solicitud INTO cNumSolEliminar
				   FROM bdisolic:"informix".ss_solicitudes 
				  WHERE numcte = cNumCteAux
					AND num_producto = cNum_ProdAux			--in ('6300','7700','7600','6800')
					AND status_solicitud = 'AT'
					order by monto_autorizado desc
			  
					EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(pEmpresa, 'sistema', cNumSolEliminar, 'RT', 'PPD', 'Mas de un tramite de prestamo personal por dia') INTO cCodRet2;
					IF cCodRet2 <> '000000' THEN
						CONTINUE FOREACH;
					END IF
					
					LET sSolsTot = sSolsTot - 1;
					IF sSolsTot <= 1 THEN
						EXIT FOREACH;
					END IF;
				END FOREACH;
			END FOREACH;
		ELSE

			FOREACH WITH HOLD	
			  SELECT a.numcte, a.num_producto, count(a.numcte) INTO cNumCteAux, cNum_ProdAux, sSolsTot
			    FROM "informix".ss_solicitudes a
				JOIN bdicred:sd_definicion p ON (a.sucursal = pSucursal and a.status_solicitud = 'AT' and a.num_producto = p.num_producto and p.llena_solicitud = 'S' AND lower(p.edocta_param) = 'prestamo_personal')
			   GROUP BY a.numcte, a.num_producto																												--in ('6300','7700','7600','6800')
			  HAVING COUNT (a.numcte) > 1
			  
				FOREACH WITH HOLD
				 SELECT num_solicitud INTO cNumSolEliminar
				   FROM bdisolic:"informix".ss_solicitudes 
				  WHERE numcte = cNumCteAux
					AND num_producto = cNum_ProdAux			--in ('6300','7700','7600','6800')
					AND status_solicitud = 'AT'
					order by monto_autorizado desc
					
					EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(pEmpresa, 'sistema', cNumSolEliminar, 'RT', 'PPD', 'Mas de un tramite de prestamo personal por dia') INTO cCodRet2;
					IF cCodRet2 <> '000000' THEN											
						CONTINUE FOREACH;
					END IF

					LET sSolsTot = sSolsTot - 1;
					IF sSolsTot <= 1 THEN
						EXIT FOREACH;
					END IF;					
				END FOREACH;						   
			END FOREACH;
		END IF;
	END IF;	---	Fin solicitudes dobles
		
	IF pNumcte IS NULL OR pNumcte = "" THEN -- Consulta por Sucursal 
		-- AAME 20150317 RQM 10 550 Se agrega el filtro por tipo de solicitud de prestamo y ademÃ¡s se cambia el valor final del producto (cProdCompFin=7700) 
		LET pFechaIni = NVL(pFechaIni,'');
		LET pFechaFin = NVL(pFechaFin,'');
		
		LET dFechaEntradaIni = pFechaIni;
		LET dFechaEntradaFin = pFechaFin; 
		
		IF (pFechaIni = '') or (pFechaIni is null) THEN
			LET dFechaEntradaIni = dFechaHoy - 10;
		END IF;
		
		IF (pFechaFin = '') or (pFechaFin is null) THEN
			LET dFechaEntradaFin = dFechaHoy;
		END IF;
		
		IF NVL(pEstatus,"")  <> "RS" THEN
		
			FOREACH WITH HOLD
			
				SELECT {+INDEX("informix".ss_solicitudes idx_ss_solicitudes2)} skip pSolicitudes LIMIT pLimit				
					a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
					a.monto_autorizado, a.fecha_insert, 
					b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc, c.causa_solicitud, c.comentario
				INTO cNumSol, cNumCte, cStatus, cProducto, mLinea, dFechaSol,
					cApellidoPaterno, cApellidoMaterno, cNombre1, cNombre2, cRazonSocial, cRfc, cCausasolicitud, cComentario
				FROM "informix".ss_solicitudes a
				INNER JOIN "informix".ss_autorizacion c on (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud and a.status_solicitud = c.status_solicitud and fecha_entrada = 
															   (SELECT MAX(fecha_entrada) FROM "informix".ss_autorizacion h
																WHERE c.empresa           = empresa
																AND c.num_solicitud     = num_solicitud
																AND c.status_solicitud  = status_solicitud)
																  AND c.fecha_entrada >= dFechaEntradaIni
																AND c.fecha_entrada <= dFechaEntradaFin)
				INNER JOIN bdinteg:"informix".si_cliente b ON (a.numcte  = b.numcte  )
				WHERE a.sucursal = pSucursal
				AND a.status_solicitud >= cEstatusCompIni AND a.status_solicitud <= cEstatusCompFin
				AND a.num_producto >= cProdCompIni AND a.num_producto <= cProdCompFin
				AND a.tipo_solicitud = 'P'
				AND a.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','CM')			
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
						AND nom.num_solicitud =  cNumSol ) , 
					 e.causa_solicitud, j.descripcion
				INTO cStDesc, cComentario, mIngreso, dFechaAut, cComentario2,
					cProdDesc, cDivisa,	cCuenta_eje,iFrecuencia,iDiaPago,cCausasolicitud, cDescripcionSol
				FROM "informix".ss_resum_scor_fin c, "informix".ss_autorizacion e, bdicred:"informix".sd_definicion f , "informix".ss_status_sol x, "informix".ss_causas_sol j
				WHERE c.empresa = pEmpresa
				  AND c.num_solicitud = cNumSol
				  AND e.empresa = c.empresa 
				  AND e.num_solicitud = c.num_solicitud
						AND e.status_solicitud = cStatus
						AND e.fecha_hora = (SELECT MAX(h.fecha_hora) FROM "informix".ss_autorizacion h
										  WHERE h.empresa           = pEmpresa--c.empresa
															  AND h.num_solicitud     = cNumSol
																AND h.status_solicitud  = cStatus) --c.status_solicitud)
				  AND f.num_producto = cProducto
				  AND f.empresa = pEmpresa
				  and x.empresa = pEmpresa
				  AND x.status_solicitud= cStatus
				  AND e.causa_solicitud= j.causa_solicitud
				  AND j.status_solicitud = cStatus;
				
				IF cCausasolicitud = 'CPS'  AND iContPP1824 > 0  THEN--12				
					--LET cComentario = "Rechazada por CPS cliente puede solicitar producto 18 o 24";				
					LET cComentario = "Rechazo CPS. En Productos valida si cte. accede a otro plazo";	
				ELSE
					LET cComentario = TRIM(TRIM(NVL(cComentario2,"")) || " " || TRIM(NVL(cComentario,"")));
				END IF;
				-- SE VERIFICA QUE EL CLIENTE TENGA CUENTAS DE CAPTACION ACTIVAS
				SELECT LIMIT 1 1
				INTO iCuentaCap
				FROM bdicheq:"informix".sc_maechq a
				LEFT JOIN bdicheq:"informix".sc_ctabloqueo b         ON (b.cuenta = a.cuenta)
				LEFT JOIN bdicheq:"informix".sc_bloqueo c            ON (c.codigo = b.clave)
				INNER JOIN "informix".ss_producto_credcap d  ON (d.empresa = a.empresa AND d.producto_cap = a.producto)
				INNER JOIN "informix".ss_solic_producto e    ON (e.empresa = a.empresa AND e.tp_solicitud = 'P' AND e.num_producto = cProducto)
				WHERE a.empresa = pEmpresa
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

				-- Se obtiene el dÃ­a de corte
				LET cDiaCorte = LPAD(DAY(dFechaAut),2,0);

				RETURN NVL(cCodRet,""), NVL(cMens_Ret,""), NVL(cNumSol,""), NVL(cNumCte,""), NVL(cNombre,""),
					   NVL(cRfc,""), NVL(dFechaSol,DATE(1)), NVL(dFechaAut,""), NVL(cProducto,""),
					   NVL(cProdDesc,""), NVL(mLinea,0), NVL(cStatus,""), NVL(cStDesc,""),
					   NVL(cComentario,""), NVL(cDiaCorte,""), NVL(cDivisa,""), NVL(mIngreso,0), NVL(iCuentaCap,0),
					   NVL(cCuenta_eje,""), NVL(iFrecuencia,1), NVL(iDiaPago,0), NVL(vdias_vigencia,0),NVL(cCausasolicitud,""),
					   NVL(cDescripcionSol,"") WITH RESUME;
			END FOREACH;
		
		ELSE
			-- SOLICITUDES RECHAZADAS POR OS CALLE
            FOREACH
			   SELECT {+INDEX("informix".ss_solicitudes idx_ss_solicitudes2)} skip pSolicitudes LIMIT pLimit				
					sol.num_solicitud, sol.numcte, sol.status_solicitud, sol.num_producto,
					sol.monto_autorizado, sol.fecha_insert, 
					cte.apell_paterno, cte.apell_materno, cte.Nombre1, cte.Nombre2, cte.razon_social,cte.rfc
				INTO cNumSol, cNumCte, cStatus, cProducto, mLinea, dFechaSol,
					cApellidoPaterno, cApellidoMaterno, cNombre1, cNombre2, cRazonSocial, cRfc
             from bdisolic:"informix".ss_solicitudes sol, bdinteg:si_cliente cte,
                         bdisolic:"informix".ss_resum_scor_fin  res, 
                         bdisolic:"informix".ss_solicitud_os solos , "informix".ss_autorizacion c ,
						 bdisitesp:"informix".se_catsitesp esp, bdinteg:"informix".si_telefonos_actual tel,
						 bdinteg:"informix".si_telefonos_actual tel2, bdinteg:"informix".si_bitsmstels sms
                    where cte.numcte = sol.numcte
					  and res.num_solicitud = sol.num_solicitud  
					  and res.empresa = sol.empresa
					  and sol.status_solicitud = "RT"
					  and sol.tipo_solicitud ='P'
					  and sol.sucursal = pSucursal
					  and sol.num_producto  = pProducto
					  and res.evalua_cc = '0'
					  and sol.num_solicitud = solos.num_solicitud
					  and sol.empresa = solos.empresa 
					  and solos.status = 'R'	
					AND solos.situacionespecialrespuesta = esp.situacion  
					  AND solos.causasituacionespecialrespuesta = esp.causa
					  AND esp.autoriza_gerente = '1'					  
					  AND c.fecha_entrada >= TODAY - 60
                      and solos.fecha_solicitud = (select max(fecha_solicitud) from bdisolic:ss_solicitud_os 
                                                   where empresa = '001' and num_solicitud = sol.num_solicitud ) 					  AND sol.empresa = c.empresa 
						and sol.num_solicitud = c.num_solicitud 
						and sol.status_solicitud = c.status_solicitud
						and fecha_entrada = (SELECT MAX(fecha_entrada) FROM "informix".ss_autorizacion h
						WHERE c.empresa           = empresa
						AND c.num_solicitud     = num_solicitud
						AND c.status_solicitud  = status_solicitud)						
						AND (tel.numcte =cte.numcte 
						and tel.tipo_tel = '2'
						AND tel.status_tel ='A'
						AND tel.cofetel ='V')
						AND (tel2.numcte =cte.numcte 
						and tel2.tipo_tel in ('1','3','4')
						AND tel2.status_tel ='A'
						AND tel2.cofetel ='V'
                        AND tel2.secuencia = (SELECT MAX(tel3.secuencia) 
                                            FROM  bdinteg:"informix".si_telefonos_actual tel3 
                                            WHERE tel3.numcte =tel2.numcte
                                            and tel3.tipo_tel in ('1','3','4')
                                            AND tel3.status_tel ='A'
                                            AND tel3.cofetel ='V')
                            )
						AND (sms.numcte =cte.numcte
						AND sms.bandera = 'T' 
						AND sms.telefono =tel.telefono
                        AND sms.teclea_ejecut not in ('1111','2222','3333','4444')
                        AND sms.fecha = (SELECT MAX(fecha) FROM  bdinteg:"informix".si_bitsmstels sms2 WHERE sms2.numcte =sms.numcte))
						AND sms.fecha > TODAY -60
					ORDER BY cte.Nombre1, cte.Nombre2, cte.apell_paterno, cte.apell_materno, sol.num_solicitud
			
			
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
					WHERE a.empresa = pEmpresa
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

					-- Se obtiene el dÃ­a de corte
					LET cDiaCorte = LPAD(DAY(dFechaAut),2,0);

					RETURN NVL(cCodRet,""), NVL(cMens_Ret,""), NVL(cNumSol,""), NVL(cNumCte,""), NVL(cNombre,""),
						   NVL(cRfc,""), NVL(dFechaSol,DATE(1)), NVL(dFechaAut,""), NVL(cProducto,""),
						   NVL(cProdDesc,""), NVL(mLinea,0), NVL("RS",""), NVL(cStDesc,""),
						   NVL(cComentario,""), NVL(cDiaCorte,""), NVL(cDivisa,""), NVL(mIngreso,0), NVL(iCuentaCap,0),
						   NVL(cCuenta_eje,""), NVL(iFrecuencia,1), NVL(iDiaPago,0), NVL(vdias_vigencia,0),NVL(cCausasolicitud,""), 
						   NVL(cDescripcionSol,"") WITH RESUME;
            END FOREACH;
		
		
		END IF
			
		
		
	ELSE -- Consulta por Cliente
		-- AAME 20150317 RQM 10 550 Se agrega el filtro por tipo de solicitud de prestamo y ademÃ¡s se cambia el valor final del producto (cProdCompFin=7700) 
		FOREACH WITH HOLD
			--APR 20220225 Se comenta lÃ­nea
			--SELECT {+INDEX("informix".ss_solicitudes idx_numctesolic)} skip pSolicitudes LIMIT pLimit				
			--APR 20220225 Se elimina el limit
			SELECT {+INDEX("informix".ss_solicitudes idx_numctesolic)}
				a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_autorizado, a.fecha_insert, 
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc
			INTO cNumSol, cNumCte, cStatus, cProducto, mLinea, dFechaSol,
				cApellidoPaterno, cApellidoMaterno, cNombre1, cNombre2, cRazonSocial, cRfc
			FROM "informix".ss_solicitudes a
			INNER JOIN bdinteg:"informix".si_cliente b          ON (a.numcte  = b.numcte  )
			WHERE a.numcte = pNumcte
			--and  a.sucursal = pSucursal
			--AND a.status_solicitud >= cEstatusCompIni AND a.status_solicitud <= cEstatusCompFin
			--AND a.num_producto >= cProdCompIni AND a.num_producto <= cProdCompFin
			AND a.tipo_solicitud = 'P'
			--AND a.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','CM')
			AND a.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','CM')
			ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, a.num_solicitud
			
			SELECT 
				x.descripcion,
				c.motivo_cc, c.ingreso_mensual , e.fecha_entrada, e.comentario , f.nombre_prod, f.divisa ,				
                 ( select nom.cuenta from "informix".ss_sol_nomina nom where nom.empresa = pEmpresa
                    AND nom.num_solicitud =  cNumSol ) , 
                 ( select nom.Frecuencia_pgo from "informix".ss_sol_nomina nom where nom.empresa = pEmpresa
                    AND nom.num_solicitud =  cNumSol ) , 
                 ( select nom.dia_pago from "informix".ss_sol_nomina nom where nom.empresa = pEmpresa
                    AND nom.num_solicitud =  cNumSol ) ,
                 e.causa_solicitud, j.descripcion
			INTO cStDesc, cComentario, mIngreso, dFechaAut, cComentario2,
				cProdDesc, cDivisa,	cCuenta_eje,iFrecuencia,iDiaPago, cCausasolicitud, cDescripcionSol
			FROM "informix".ss_resum_scor_fin c, "informix".ss_autorizacion e, bdicred:"informix".sd_definicion f , "informix".ss_status_sol x, "informix".ss_causas_sol j
            WHERE c.empresa = pEmpresa
              AND c.num_solicitud = cNumSol
              AND e.empresa = c.empresa 
              AND e.num_solicitud = c.num_solicitud
			        AND e.status_solicitud = cStatus
			        AND e.fecha_hora = (SELECT MAX(h.fecha_hora) FROM "informix".ss_autorizacion h
                                      WHERE h.empresa           = pEmpresa--c.empresa
										                  AND h.num_solicitud     = cNumSol
											                AND h.status_solicitud  = cStatus) --c.status_solicitud)
              AND f.num_producto = cProducto
              AND f.empresa = pEmpresa
              and x.empresa = pEmpresa
              AND x.status_solicitud= cStatus
			  AND e.causa_solicitud= j.causa_solicitud
			  AND j.status_solicitud = cStatus;

			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				IF cStatus = "CN" OR cStatus = "CM" THEN
					SELECT 
						x.descripcion,
						'', 0, e.fecha_entrada, e.comentario , f.nombre_prod, f.divisa,
							( select nom.cuenta from "informix".ss_sol_nomina nom where nom.empresa = pEmpresa
							AND nom.num_solicitud =  cNumSol ) , 
							( select nom.Frecuencia_pgo from "informix".ss_sol_nomina nom where nom.empresa = pEmpresa
							AND nom.num_solicitud =  cNumSol ) , 
							( select nom.dia_pago from "informix".ss_sol_nomina nom where nom.empresa = pEmpresa
							AND nom.num_solicitud =  cNumSol ) ,
							e.causa_solicitud, j.descripcion
					INTO cStDesc, cComentario, mIngreso, dFechaAut, cComentario2,
						cProdDesc, cDivisa,	cCuenta_eje,iFrecuencia,iDiaPago, cCausasolicitud, cDescripcionSol
					FROM "informix".ss_autorizacion e, bdicred:"informix".sd_definicion f , "informix".ss_status_sol x, "informix".ss_causas_sol j
					WHERE e.empresa = pEmpresa
						AND e.num_solicitud = cNumSol
						AND e.status_solicitud = cStatus
						AND e.fecha_hora = (SELECT MAX(h.fecha_hora) FROM "informix".ss_autorizacion h
												WHERE h.empresa           = pEmpresa
													AND h.num_solicitud     = cNumSol
													AND h.status_solicitud  = cStatus)
						AND f.num_producto = cProducto
						AND f.empresa = pEmpresa
						AND x.empresa = pEmpresa
						AND x.status_solicitud= cStatus
						AND e.causa_solicitud= j.causa_solicitud
						AND j.status_solicitud = cStatus;
				END IF;
			END IF;
		
			-- SE ARMA EL NOMBRE DEL CLIENTE
			LET cNombre = TRIM(NVL(cNombre1,"")) || " " || TRIM(NVL(cNombre2,"")) || " " || TRIM(NVL(cApellidoPaterno,"")) || " " || TRIM(NVL(cApellidoMaterno,""));

			IF cCausasolicitud = 'CPS'  AND iContPP1824 > 0  THEN--12				
				--LET cComentario = "Rechazada por CPS cliente puede solicitar producto 18 o 24";				
				LET cComentario = "Rechazo CPS. En Productos valida si cte. accede a otro plazo";					
			ELSE
				LET cComentario = TRIM(TRIM(NVL(cComentario2,"")) || " " || TRIM(NVL(cComentario,"")));
			END IF;

			-- SE VERIFICA QUE EL CLIENTE TENGA CUENTAS DE CAPTACION ACTIVAS
			SELECT LIMIT 1 1
			INTO iCuentaCap
			FROM bdicheq:"informix".sc_maechq a
			LEFT JOIN bdicheq:"informix".sc_ctabloqueo b         ON (b.cuenta = a.cuenta)
			LEFT JOIN bdicheq:"informix".sc_bloqueo c            ON (c.codigo = b.clave)
			INNER JOIN "informix".ss_producto_credcap d  ON (d.empresa = a.empresa AND d.producto_cap = a.producto)
			INNER JOIN "informix".ss_solic_producto e    ON (e.empresa = a.empresa AND e.tp_solicitud = 'P' AND e.num_producto = cProducto)
			WHERE a.empresa = pEmpresa
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
			-- Se obtiene el dÃ­a de corte
			LET cDiaCorte = LPAD(DAY(dFechaAut),2,0);

			RETURN NVL(cCodRet,""), NVL(cMens_Ret,""), NVL(cNumSol,""), NVL(cNumCte,""), NVL(cNombre,""),
					NVL(cRfc,""), NVL(dFechaSol,DATE(1)), NVL(dFechaAut,""), NVL(cProducto,""),
					NVL(cProdDesc,""), NVL(mLinea,0), NVL(cStatus,""), NVL(cStDesc,""),
					NVL(cComentario,""), NVL(cDiaCorte,""), NVL(cDivisa,""), NVL(mIngreso,0), NVL(iCuentaCap,0),
					NVL(cCuenta_eje,""), NVL(iFrecuencia,1), NVL(iDiaPago,0), NVL(vdias_vigencia,0),NVL(cCausasolicitud,""),
					NVL(cDescripcionSol,"") WITH RESUME;  --DSB 28/06/2012
		END FOREACH;
	
	END IF;
END;
END PROCEDURE
