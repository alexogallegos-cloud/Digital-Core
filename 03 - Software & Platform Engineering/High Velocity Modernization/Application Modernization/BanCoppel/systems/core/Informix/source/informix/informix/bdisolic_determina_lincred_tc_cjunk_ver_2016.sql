CREATE PROCEDURE "informix".determina_lincred_tc_cjunk_ver_2016(o_empresa CHAR(3),o_numsol  CHAR(20),o_cte_nvo CHAR(1))
RETURNING CHAR(5)       AS retorno,
          MONEY(14,2)   AS linea_cred,
          MONEY(14,2)   AS capacidad_de_pago,
          INTEGER       AS plazo;
		  
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret                 CHAR(3);
DEFINE vsqlerr                  INTEGER;
DEFINE v_salariomin             DECIMAL(14,2);
DEFINE v_porcsalmin             DECIMAL(6,3);
DEFINE v_paramfactor            SMALLINT;
DEFINE v_ingreso                MONEY(14,2);
DEFINE v_tope_ingre             DECIMAL(9,6);
DEFINE v_tope_ingreso      DECIMAL(14,2);
DEFINE v_situacion              DECIMAL(6,3);
DEFINE v_meseshist              SMALLINT;
DEFINE v_porcpermitido          DECIMAL(6,3);
DEFINE v_mesespermitido         SMALLINT;
DEFINE v_minimomesespermitido   SMALLINT;
DEFINE v_capacidad              MONEY(14,2);
DEFINE v_linea                  MONEY(14,2);
DEFINE v_factor_vp            DECIMAL(21,10);
DEFINE v_compromisos            MONEY(14,2);
DEFINE v_lintienda              MONEY(14,2);
DEFINE cNumCte                  CHAR(20);
DEFINE cEdad                    CHAR(10);
DEFINE v_limite_inferior        DECIMAL(14,2);
DEFINE v_topemax                DECIMAL(14,2);
DEFINE v_abonomesprestamo       MONEY(14,2);
DEFINE v_abonomesmuebles        MONEY(14,2);
DEFINE v_abonomesropa           MONEY(14,2);
-- Ini Caja Unica. Viridiana
DEFINE cProducto                CHAR (4);
DEFINE cProducto2                CHAR (4);
DEFINE iEdad                    SMALLINT;
DEFINE cNumcredito              CHAR(20);
DEFINE v_comprobanco            MONEY (14,2);
DEFINE v_comprobancoprestamo    MONEY (14,2);
DEFINE iPlazoMax                INTEGER;
DEFINE cSucursal                CHAR(4);
DEFINE iNum_periodos            INTEGER;
DEFINE dtFecha_cuota            DATE;
DEFINE dSdo_inicial             MONEY(14,2);
DEFINE dPago_mensual            MONEY(14,2);
DEFINE dMto_Interes             MONEY(14,2);
DEFINE dIva_interes             MONEY(14,2);
DEFINE dCapital                 MONEY(14,2);
DEFINE dSdo_final               MONEY(14,2);
DEFINE sDias_periodo            SMALLINT;
DEFINE v_diaspromedio           DECIMAL(14,2);
DEFINE dMto_min                 DECIMAL(18,2);
DEFINE dMto_max                 DECIMAL(18,2);
DEFINE Codret                   CHAR(6);
DEFINE dtFecha_Aper		        DATE;
DEFINE cTpSolicitud             CHAR(1);
DEFINE iPlazoMin                INTEGER;
DEFINE cTpSeccion				INTEGER;
DEFINE cStatus					CHAR(2);
DEFINE cCompIngresos			CHAR(1);
DEFINE v_flujo_libre1      DECIMAL(14,2);
DEFINE v_flujo_libre2      DECIMAL(14,2);
DEFINE v_factor_flujo1     DECIMAL(5,2);
DEFINE v_factor_flujo2     DECIMAL(5,2);
DEFINE v_min_flujo         DECIMAL(14,2);
DEFINE v_max_flujo         DECIMAL(14,2);
DEFINE v_linea_teorica     DECIMAL(14,2);
DEFINE v_salarios_max      DECIMAL(14,2);
DEFINE v_paso              DECIMAL(14,2);
DEFINE mIngresoProm		   MONEY(16,2);
DEFINE iFrecuencia		   INTEGER;
DEFINE cNumMesesPagos      CHAR(3);
DEFINE dLineaPorcentaje    DECIMAL(14,2);
DEFINE v_factorree         DECIMAL(14,2);
DEFINE v_linea_ree         DECIMAL(14,2);
DEFINE v_lineasinTopes     DECIMAL(14,2);
-- RQM 09 262 LHM INI
DEFINE v_topemax_NO_HIT    DECIMAL(14,2);
DEFINE v_evalua_cc         char(01);
DEFINE v_compromi_tdc      DECIMAL(14,2);
-- RQM 09 262LHM FIN
DEFINE dIngresoCac         DECIMAL(14,2);
DEFINE dCompromisosCac     DECIMAL(14,2);
DEFINE cTope 			   CHAR(1);
DEFINE v_grupo             char(01); 
DEFINE vlMontoHipoteca     decimal (14,2);
DEFINE pporc_mod_lin	   decimal(5,2);
DEFINE pporc_mod_linTDC	   decimal(18,2);
DEFINE pporc_mod_linPP	   decimal(18,2);
DEFINE ptipo_modifica 	   CHAR(1);
DEFINE v_lineaMod          MONEY(14,2);
DEFINE v_capacidadMod      MONEY(14,2);
DEFINE cCodRet 				CHAR(6); 
DEFINE ptipogrupo 			CHAR(2); 
DEFINE phit 				CHAR(6); 	
DEFINE v_compteorico        MONEY(14,2);
define vcompromiso_coppel   MONEY;
define vcompromiso_rmp    	MONEY;
DEFINE dPorcIncr     DECIMAL(14,2);
DEFINE dMontoIncr     DECIMAL(14,2);
DEFINE dMontoDecr     DECIMAL(14,2);
DEFINE dPorcDecr     DECIMAL(14,2);
DEFINE v_comprobancoCRNOM DECIMAL(14,2);
DEFINE v_comprobancoPP DECIMAL(14,2);
DEFINE v_comprobancoTDC DECIMAL(14,2);
DEFINE v_lineaAnt DECIMAL(14,2);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret            = "000";
LET vsqlerr             = 0;
LET v_linea             = 0;
LET cNumCte             = "";
LET cEdad               = "";
LET v_abonomesprestamo  = 0;
LET v_abonomesmuebles   = 0;
LET v_abonomesropa      = 0;
LET iEdad                   = 0;
LET v_capacidad             = 0;
LET cNumcredito             = "";
LET v_comprobanco           = 0;
LET v_comprobancoprestamo   = 0;
LET iPlazoMax               = 0;
LET cSucursal               = "";
LET iNum_periodos           = 0;
LET dtFecha_cuota           = DATE(1);
LET dSdo_inicial            = 0;
LET dPago_mensual           = 0;
LET dMto_Interes            = 0;
LET dIva_interes            = 0;
LET dCapital                = 0;
LET dSdo_final              = 0;
LET sDias_periodo           = 0;
LET dMto_min                = 0;
LET dMto_max                = 0;
LET Codret                  = "000000";
LET dtFecha_Aper            = DATE(1);
LET cTpSolicitud            = "";
LET iPlazoMin               = 0;
LET cTpSeccion				= 0;
LET cStatus					= "";
LET cCompIngresos			= "";
LET v_diaspromedio          = 0;
LET v_tope_ingreso  = 0;
LET v_factor_flujo1 = 0;
LET v_factor_flujo2 = 0;
LET v_salarios_max   = 0;
LET v_paso = 0;
LET mIngresoProm	= 0;
LET iFrecuencia		= 1;
LET cNumMesesPagos  	= "";
LET dLineaPorcentaje    = 0;
LET v_factorree       = 0;
LET v_linea_ree       = 0;
LET v_compromi_tdc = 0;
LET v_lineasinTopes = 0;
LET dIngresoCac         = 0;
LET dCompromisosCac     = 0;
LET cTope 			    = 'S';
LET v_grupo            = "";
LET vlMontoHipoteca    = 0;
let v_factor_vp      = 0;
let v_compteorico	   = 0;
LET vcompromiso_coppel = 0;
let vcompromiso_rmp	   = 0;
LET v_topemax_NO_HIT = 0;
LET v_evalua_cc      = '';
LET pporc_mod_lin	=0;
LET pporc_mod_linTDC	=0;
LET pporc_mod_linPP	=0;
LET ptipo_modifica 	='';
LET v_lineaMod        = 0;
LET v_capacidadMod		  = 0;
LET cCodRet  = '000000'; 
LET dPorcIncr = 0;
LET dMontoIncr = 0;
LET dMontoDecr = 0;
LET dPorcDecr = 0;
LET v_lineaAnt = 0;
LET v_comprobancoCRNOM = 0;
LET v_comprobancoPP = 0;
LET v_comprobancoTDC = 0;
LET cProducto = '';
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/informix/Israel/determina_lincred16.out";
--TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
-- ********************************************
   --  Se obtiene la edad del cliente            *
   -- ********************************************
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

   SELECT a.numcte,a.sucursal,a.num_producto,a.tipo_solicitud, a.status_solicitud,NVL(b.ingreso_cac,0),NVL(compromisos_cac,0),NVL(comprobante_valido_cac,"N")
    INTO cNumCte,cSucursal,cProducto,cTpSolicitud,cStatus,dIngresoCac,dCompromisosCac,cCompIngresos
    FROM bdisolic:"informix".ss_solicitudes a
	LEFT OUTER JOIN	bdisolic:"informix".ss_solicitudes_cac b ON ( a.num_solicitud = b.num_solicitud)
	WHERE a.num_solicitud = o_numsol;


--***************************************************
--Se obtienes los salarios maximos para producto 6600
--***************************************************

    ---- SE OBTIENE EL POCENTAJE DE LOS COMPROMISOS DE TDC

       SELECT valor INTO v_compromi_tdc
        FROM bdisolic:"informix".ss_param
       WHERE empresa= o_empresa AND secuencia= 35;
        

-- Se obtiene la edad del cliente
   SELECT (EXTEND(current, year to month) - extend(fecha_nac, year to month))
    INTO cEdad
     FROM bdinteg:"informix".si_ctepf
    WHERE numcte = cNumCte;

    LET cEdad = TRIM(cEdad);
    LET iEdad= CAST(cEdad[1,2] AS SMALLINT);

	-- **************************************************

	-- Extrae Parametros para la definicion de la Linea *
	-- **************************************************

	SELECT valor
      INTO v_porcpermitido -- Porcentaje de Situacion de pago
	  FROM bdisolic:"informix".ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 307;

	IF v_porcpermitido IS NULL THEN
		LET scod_ret = "451";
		RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
	END IF

	SELECT valor
      INTO v_mesespermitido -- Meses de Historia base
	  FROM bdisolic:"informix".ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 308;

    IF v_mesespermitido IS NULL THEN
		LET scod_ret = "452";
		RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
	END IF

    SELECT valor
      INTO v_minimomesespermitido --  Meses de Historia Minimo
	  FROM bdisolic:"informix".ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 329;

	IF  v_minimomesespermitido IS NULL THEN
		LET scod_ret = "452";
		RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
	END IF

	SELECT valor::DECIMAL(14,2)
      INTO v_salariomin -- Salario Minimo Base
	  FROM bdisolic:"informix".ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 354;

	IF v_salariomin IS NULL THEN
		LET scod_ret = "452";
		RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
	END IF;

	SELECT valor::DECIMAL(14,2)
      INTO v_diaspromedio -- Salario Minimo Base
	  FROM bdisolic:"informix".ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 355;

	IF v_diaspromedio IS NULL THEN
		LET scod_ret = "452";
		RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
	END IF;

    SELECT valor::DECIMAL(9,6)
      INTO v_tope_ingre
      FROM bdisolic:"informix".ss_param
 	 WHERE empresa = o_empresa
	   AND secuencia=353;

	-- *******************************************************************
	-- Extrae Ingreso, Situacion de Pago y Meses de Historia del Cliente *
	-- *******************************************************************

   SELECT ingreso_mensual, situacion_pago, meses_historia , pago_minimo,
          linea_tienda, abonomensualprestamos,abonomensualmuebles,abonomensualropa, evalua_cc,
          monto_hipoteca, nvl(grupo,'')
	 INTO v_ingreso, v_situacion, v_meseshist, v_compromisos, v_lintienda,
          v_abonomesprestamo,v_abonomesmuebles,v_abonomesropa, v_evalua_cc,
          vlMontoHipoteca, v_grupo
     FROM bdisolic:"informix".ss_resum_scor_fin
    WHERE empresa = o_empresa
      AND num_solicitud = o_numsol;

	if v_lintienda > 0 then
	  let v_compteorico	= (v_lintienda * .10);
	end if; 
	---Se valida que si es el producto CrediNomina va a comparar cual es el monto menor, el ingreso mensual o el promedio mensual, ya que se va a considerar el menor para el calculo de linea de credito
	IF cProducto = '6400' THEN
		SELECT NVL(promedio_mes,0),NVL(frecuencia_pgo,1)
		INTO mIngresoProm,iFrecuencia
		FROM bdisolic:"informix".ss_sol_nomina
		WHERE  empresa = o_empresa
		AND num_solicitud = o_numsol;
		
		IF v_ingreso > mIngresoProm THEN
			LET v_ingreso = mIngresoProm;
		END IF;
	END IF;


	
--ini cas rqm 09 172
            -- *******************************************
            -- Extrae Porcentaje de ingresos del cliente *
            -- *******************************************
    IF (v_situacion >= v_porcpermitido and v_meseshist >= v_minimomesespermitido) THEN -- OR (v_situacion >= v_porcpermitido and v_meseshist < v_mesespermitido and v_meseshist >= v_minimomesespermitido)
        LET v_paramfactor = 301; -- Cliente No Nuevo factor 0.20
    ELSE
        LET v_paramfactor = 302; -- Cliente Nuevo
        LET v_situacion = 0;
        LET v_meseshist = 0;
    END IF
    ---Se limpia meses de historia y Situacion para cliente Grupo A
    IF ( v_grupo = 'A') then
        LET v_situacion = 0;
        LET v_meseshist = 0;
    END IF;   

    SELECT valor / 100
      INTO v_porcsalmin
      FROM bdisolic:"informix".ss_param
     WHERE empresa = o_empresa
       AND secuencia = v_paramfactor;

    IF v_porcsalmin IS NULL THEN
        LET scod_ret = "453";
        RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
    END IF

--fin cas rqm 09 172

    IF v_ingreso IS NULL THEN
    LET scod_ret = "454";
            RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
    END IF

    IF v_compromisos IS NULL THEN
    LET v_compromisos = 0;
    END IF

    IF v_abonomesprestamo IS NULL THEN
            LET v_abonomesprestamo=0;
    END IF;

    IF v_abonomesmuebles IS NULL THEN
            LET v_abonomesmuebles=0;
    END IF;

    IF v_abonomesropa IS NULL THEN
            LET v_abonomesropa=0;
    END IF;

    IF v_situacion IS NULL THEN
    LET scod_ret = "455";
            RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
    END IF

    IF v_meseshist IS NULL THEN
    LET scod_ret = "456";
            RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
    END IF

    IF v_lintienda IS NULL THEN
    LET scod_ret = "457";
            RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
    END IF

    -- ************************************
    -- Inicia Proceso de Calculo de Linea *
    -- ************************************

    IF v_ingreso < round(v_salariomin * v_diaspromedio,-2) THEN -- Moha
        LET v_ingreso = round(v_salariomin * v_diaspromedio,-2);
		
    END IF;

--******* COMPROMISOS BANCO INI
-- CREDITOS REVOLVENTES

	LET cNumcredito = "";

    FOREACH
	   SELECT num_credito
		 INTO cNumcredito
		 FROM bdicred:"informix".sd_maecred
		WHERE empresa = o_empresa
		  AND numcte = cNumCte
		  AND status_cred NOT IN ("FF","FM","FR","FE","CC","FC","CV")

	   SELECT NVL(a.sdo_cap_insoluto,0)
		 INTO v_comprobancoTDC
		 FROM bdicred:"informix".sd_maesdos a
		WHERE a.empresa     = o_empresa
		  AND a.num_credito = cNumcredito;
		  
	   IF v_comprobancoTDC IS NULL or v_comprobancoTDC <= 0 THEN
		   LET v_comprobancoTDC = 0;
	   ELSE
		   IF Round(v_comprobancoTDC,-1) - v_comprobancoTDC < 0 THEN
				LET v_comprobancoTDC = Round(v_comprobancoTDC,-1) + 10;
		   ELSE
			    LET v_comprobancoTDC = Round(v_comprobancoTDC,-1);
			END IF;
	   END IF;
	   
	   LET v_comprobanco = round((v_comprobanco + v_comprobancoTDC) * v_compromi_tdc ,-1);


    END FOREACH;

	LET v_comprobancoTDC = v_comprobanco;	
-- CREDITOS A PLAZO
    FOREACH
	   SELECT num_credito,num_producto
		 INTO cNumcredito,cProducto2
		 FROM bdicred:"informix".sd_maecredcrd
		WHERE empresa = o_empresa
		  AND numcte = cNumCte
		  AND status_cred NOT IN ("FF","FM","FR","FE","CC","FC","CV")

	   SELECT NVL(a.capital_mto_cuota,0)
		 INTO v_comprobancoprestamo
		 FROM bdicred:"informix".sd_amortiza_creditocrd a
		WHERE a.empresa     = o_empresa
		  AND a.num_credito = cNumcredito
		  AND a.num_pago = 1;

	   IF v_comprobancoprestamo IS NULL THEN
		   LET v_comprobancoprestamo = 0;
	   END IF;

	   LET v_comprobanco = v_comprobanco + v_comprobancoprestamo;
	   IF cProducto2  = '6400' THEN--JMAH RQM 09 366-2
			LET v_comprobancoCRNOM = v_comprobancoCRNOM + v_comprobancoprestamo;
	   ELSE
			LET v_comprobancoPP = v_comprobancoPP + v_comprobancoprestamo;
	   END IF;
	   
    END FOREACH;

-- GRABAR COMPROMISOS BANCO
	
	IF v_comprobanco IS NULL  THEN
        LET v_comprobanco=0;
    END IF;

--******* COMPROMISOS BANCO FIN

--  TOPDE DE INGRESO EXCEPTO CREDINOMINA INI

	LET v_tope_ingreso = round(v_salariomin * v_diaspromedio * v_tope_ingre,-2);
	
	IF ( v_ingreso > v_tope_ingreso and cProducto <> "6400" and cTope = 'S') or ( cStatus = 'LC' and cCompIngresos = 'N') then
		let v_ingreso = v_tope_ingreso;
	END IF;


  ----Se quitan el monto de hipoteca al ingreso.
  LET   v_ingreso = v_ingreso - NVL(vlMontoHipoteca,0);
  if v_compromisos > 0 then
    LET   v_compromisos = v_compromisos -NVL(vlMontoHipoteca,0);    
  end if;  

		LET cTpSeccion = '11'; --seccion productiva

	SELECT (sum(round(cant_smb_inf * v_salariomin * v_diaspromedio,-2))), --v_salariomin * v_diaspromedio),
		   (sum(round(cant_smb_sup * v_salariomin * v_diaspromedio,-2))),
		   (sum(round(cant_smb_sup_no_hit * v_salariomin * v_diaspromedio,-2))),
			sum(factor_flujo1),
			sum(factor_flujo2),
			min(min_flujo),
			max(max_flujo),
			sum(linea_teorica),
			sum(factorree),
			sum(linea_ree)
		 INTO v_limite_inferior,
			  v_topemax,
			  v_topemax_NO_HIT,
			  v_factor_flujo1,
			  v_factor_flujo2,
			  v_min_flujo,
			  v_max_flujo,
			  v_linea_teorica,
			  v_factorree,
			  v_linea_ree
		 FROM bdisolic:"informix".ss_scoring_solic
		WHERE empresa = o_empresa
		  AND tp_solicitud = cTpSolicitud
		  AND seccion = cTpSeccion
		  AND activa = '1'
      AND grupo = v_grupo; --- multiple 2013;
	
	IF (v_topemax IS NULL OR v_topemax = 0) and ( v_topemax_NO_HIT is null or v_topemax_NO_HIT = 0 )  THEN
		 LET scod_ret = "463";
		 RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
	END IF;

	IF v_limite_inferior IS NULL  OR v_limite_inferior = 0 THEN
		 LET scod_ret = "466";
		 RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
	END IF;
	
	let vcompromiso_rmp = v_abonomesprestamo + v_abonomesmuebles + v_abonomesropa;
	
	if vcompromiso_rmp >= v_compteorico  then 
	  let vcompromiso_coppel = vcompromiso_rmp; 
	else  let vcompromiso_coppel =v_compteorico;
	end if;

	LET v_flujo_libre1 = Round(v_factor_flujo1 * v_ingreso - (v_compromisos + v_comprobanco + vcompromiso_coppel +dCompromisosCac ),2);
	LET v_flujo_libre2 = round(v_factor_flujo2 * v_ingreso,2);
	
	IF ( v_flujo_libre1 < v_min_flujo ) then
	   LET v_linea = 0;
	   LET scod_ret = "010"; -- capacidad de pago saturada
	   RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
	END IF;
	
   IF cTpSolicitud = 'P' THEN
  
		SELECT NVL(plazo_min_cred,0),NVL(plazo_max_cred,0),monto_min_cred, monto_max_cred
		  INTO iPlazoMin,iPlazoMax,dMto_min,dMto_max
		  FROM bdicred:"informix".sd_definicion
		 WHERE empresa = o_empresa
		   AND num_producto = cProducto;
	  
	  ----Monto Minimo y Maximo para Hit y No Hit
			LET  dMto_min =round(v_limite_inferior,-2); 
		IF (v_evalua_cc = 'X') THEN
			LET dMto_max = round(v_topemax_NO_HIT,-2);
		ELSE 
			LET dMto_max = round(v_topemax,-2);   
		END IF;
    
-- TOPE CREDINOMINA 4 meses INI
		IF dMto_max > v_ingreso * 4 AND cProducto = "6400" THEN
			LET dMto_max = v_ingreso * 4;
		END IF;
-- TOPE CREDINOMINA	4 meses FIN  
	  
		IF iPlazoMin IS NULL OR iPlazoMax IS NULL THEN
		   LET scod_ret = "470";
		   RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
		END IF;
   
   		IF ( v_flujo_libre1 <= v_max_flujo ) then
			IF cProducto = "6400" THEN
				EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (dMto_min,iPlazoMax,0,cProducto,cSucursal,0,0,o_numsol,"",NVL(iFrecuencia,1))
				INTO Codret,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
				dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos;
				
				IF Codret <> "000000" THEN
					LET scod_ret = "474";
					RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
				END IF;	
				LET v_capacidad = dPago_mensual;
			ELSE	
				EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (dMto_min,iPlazoMax,0,cProducto,cSucursal,0,0,o_numsol,"")
						 INTO Codret,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
							  dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper;
				IF Codret <> "000000" THEN
					LET scod_ret = "474";
					RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
				END IF;
				LET v_capacidad = dPago_mensual;
			END IF;
		ELSE	
			if ( v_flujo_libre1 > v_flujo_libre2) then
				let v_capacidad = v_flujo_libre2;
			else
				let v_capacidad = v_flujo_libre1;
			end if;
		end if;			
		
		
	   IF NVL(v_capacidad,0) <= 0 THEN
		   LET v_linea = 0;
		   LET scod_ret = "010"; -- capacidad de pago saturada
		   RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
	   END IF;

	   IF cProducto = "6400" THEN --JMAH se contempla usar el procedimiento productivo y el procedimiento de credinomina

			LET dMto_max = ROUND(dMto_max,-1);
			LET v_capacidad =  ROUND(v_capacidad,-1);

---lhm capacidad quincenal
            IF iFrecuencia = 2 THEN
                LET v_capacidad = ROUND(v_capacidad/2,-1);
            END IF;
			
			EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (0,iPlazoMax * iFrecuencia,v_capacidad,cProducto,cSucursal,0,0,o_numsol,"",NVL(iFrecuencia,1))
			INTO Codret,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
			dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos;
			
			IF Codret <> "000000" THEN
				LET scod_ret = "471";
				RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
			END IF;

			IF NVL(dSdo_inicial,0) > dMto_max THEN

				LET dSdo_inicial = dMto_max;

				EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (dMto_max,0,v_capacidad,cProducto,cSucursal,0,0,o_numsol,"",NVL(iFrecuencia,1))
				INTO Codret,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
				dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos;
				IF Codret <> "000000" THEN
					IF Codret = "000005" THEN

						EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (dMto_max,iPlazoMin,0,cProducto,cSucursal,0,0,o_numsol,"",NVL(iFrecuencia,1))
						INTO Codret,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
						dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos;
						
						IF Codret <> "000000" THEN
							LET scod_ret = "474";
							RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
						END IF;
						
						--LET iPlazoMax = iPlazoMin;
						LET v_capacidad = dPago_mensual;

					ELSE
						LET scod_ret = "472";
						RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
					END IF;
				END IF;
	
			END IF;
			LET iPlazoMax = iNum_periodos;				
			LET v_linea = ROUND(dSdo_inicial,-2);
			LET v_lineasinTopes = v_linea;
		
			RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
		ELSE
			EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (0,iPlazoMax,v_capacidad,cProducto,cSucursal,0,0,o_numsol,"")
					INTO Codret,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
						 dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper;

			IF Codret <> "000000" THEN
				LET scod_ret = "471";
				RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
			END IF;

			IF NVL(dSdo_inicial,0) > dMto_max THEN

				LET dSdo_inicial = dMto_max;

				EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (dMto_max,0,v_capacidad,cProducto,cSucursal,0,0,o_numsol,"")
						INTO Codret,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
							 dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper;
				IF Codret <> "000000" THEN
					IF Codret = "000005" THEN

						EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (dMto_max,iPlazoMin,0,cProducto,cSucursal,0,0,o_numsol,"")
								 INTO Codret,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
									  dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper;

						IF Codret <> "000000" THEN
							LET scod_ret = "474";
							RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
						END IF;

						LET iPlazoMax = iPlazoMin;
						LET v_capacidad = dPago_mensual;

					ELSE
						LET scod_ret = "472";
						RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);
					END IF;
				END IF;

			END IF;

			LET v_linea = ROUND(dSdo_inicial,-2);
			LET v_lineasinTopes = v_linea;

		END IF;
        
	END IF

		IF cProducto = "6600" THEN
				LET v_paso = NVL(v_linea,0)/NVL(v_salarios_max,0);
			IF NVL(v_paso,0) > nvl(v_salarios_max,0) THEN
			  LET v_linea= nvl(v_salarios_max,0) * nvl(v_salariomin,0);
			END IF;
		END IF
	
	--SE VALIDA SI EL CLIENTE CUANTA CON UN CREDITO DE REESTRUCTURA LIQUIDADO.
	IF EXISTS (SELECT status_cred
				FROM bdicred:"informix".sd_maecredcrd 
				WHERE empresa = o_empresa
				AND numcte = cNumCte
				AND num_producto = '6011'
				AND status_cred ="FF" ) THEN

		IF v_factorree IS NULL OR v_factorree = '' THEN
		   LET v_factorree = 0;
		END IF

		IF v_linea_ree IS NULL OR v_linea_ree = '' THEN
		   LET v_linea_ree = 0;
		END IF;    

		LET dLineaPorcentaje = v_linea * (v_factorree / 100);
		
		IF v_linea_ree > dLineaPorcentaje THEN
			LET v_linea = ROUND(v_linea_ree,-2);
		ELSE 
			LET v_linea = ROUND(dLineaPorcentaje,-2);
		END IF;				
		
    END IF;
    
   IF cStatus <> 'LC' THEN  
     CALL bdisolic:"informix".sp_obtieneincrementolin(o_numsol, cTpSolicitud)
	 RETURNING scod_ret,pporc_mod_lin, ptipo_modifica;
   ELSE 	 
     LET ptipo_modifica = 'N';
   END IF; 

   LET v_lineaAnt = v_linea;
   
   IF ptipo_modifica <> 'N' then
     let  v_lineaMod =     v_linea * (pporc_mod_lin / 100);
	   let  v_capacidadMod = v_capacidad * (pporc_mod_lin / 100);
     if ptipo_modifica = 'I' then
		 let dPorcIncr = pporc_mod_lin;
		 let dMontoIncr = v_lineaMod - v_linea;
	     let  v_linea = Round((v_linea+ v_lineaMod),-2);
	     let  v_capacidad = Round((v_capacidad+ v_capacidadMod),-1);	    
	   elif ptipo_modifica = 'D' then
	   	 let dPorcDecr = pporc_mod_lin;
		 let dMontoDecr = v_lineaMod - v_linea;
	     let  v_linea = Round((v_linea- v_lineaMod),-2);
	     let  v_capacidad = Round((v_capacidad- v_capacidadMod),-1);
	   end if;	  
   END if;

	RETURN TRIM(scod_ret), NVL(v_linea,0),NVL(v_capacidad,0),NVL(iPlazoMax,0);

END
END PROCEDURE

