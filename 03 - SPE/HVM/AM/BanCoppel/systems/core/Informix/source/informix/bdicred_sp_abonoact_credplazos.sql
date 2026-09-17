CREATE PROCEDURE "informix".sp_abonoact_credplazos(cEmpresa CHAR(3),CNumCredito CHAR(20))
RETURNING	CHAR(5) AS CodRet,
			DECIMAL(14,2) AS pagosactual;

 -- DEFINICION DE VARIABLES --
DEFINE sSqlErr			SMALLINT;
DEFINE Ncantidad		SMALLINT;
DEFINE Nciclos			SMALLINT;
DEFINE cCodRet			CHAR(5);
DEFINE cCodRet1  		CHAR(5);
DEFINE Cfechaperiodo	CHAR(10);
DEFINE Nsaldocorte		DECIMAL(14,2);
DEFINE NpagomINimo		DECIMAL(14,2);
DEFINE Npagos			DECIMAL(14,2);
DEFINE Npagosactual     DECIMAL(14,2);
DEFINE dtFechaHoy		DATE;
DEFINE cTipCred			CHAR(2);
DEFINE Ndiacorte		SMALLINT;
DEFINE NdiafIN			SMALLINT;
DEFINE cPeriodos		INTEGER;
DEFINE vPagosHist    DECIMAL (14,2);
DEFINE vPagosAct     DECIMAL (14,2);
DEFINE dFechaCorte	 DATE;
DEFINE dFechaMesiver DATE;
DEFINE dFechaCorte2  DATE;
DEFINE iTotalCtas    INTEGER;

LET sSqlErr			= 0;
LET cCodRet			= '00000';
LET cCodRet1		= '00000';
LET Cfechaperiodo	= '';
LET Nsaldocorte		= 0;
LET NpagomINimo		= 0;
LET Npagos			= 0;
LET Ncantidad		= 0;
LET dtFechaHoy		= DATE(1);
LET cTipCred		= '';
LET Nciclos			= 0;
LET Ndiacorte		= 0;
LET NdiafIN			= 0;
LET cPeriodos		= 0;
LET vPagosHist  = 0;
LET vPagosAct   = 0;
LET dFechaCorte = DATE(1);
LET dFechaMesiver = DATE(1);
LET dFechaCorte2  = DATE(1);


LET iTotalCtas = 0;
LET Npagosactual = 0;

	--SET DEBUG FILE TO '/informix/sp_abonoAct_credPlazos.out';
	--TRACE ON;

BEGIN
ON EXCEPTION SET sSqlErr
	LET cCodRet = sSqlErr;
	RETURN cCodRet, Npagosactual;
END EXCEPTION;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = cEmpresa;

	/* SELECT valor::integer INTO cPeriodos
	FROM bdinteg:"informix".si_param
    WHERE cod_param = 400
    AND empresa = cEmpresa; */

	SELECT b.cod_prod
	INTO cTipCred
	FROM bdicred:"informix".sd_maecred a,
	bdicred:"informix".sd_tipprod b
	WHERE a.num_credito = CNumCredito
	AND a.empresa=cEmpresa
	AND a.empresa=b.empresa
	AND a.num_producto=b.abrevia_prod;

     IF (cTipCred IS NULL) THEN
		SELECT b.cod_prod
		INTO cTipCred
		FROM bdicred:"informix".sd_maecredcrd a,
		bdicred:"informix".sd_tipprod b
		WHERE a.num_credito = CNumCredito
		AND a.empresa=cEmpresa
		AND a.empresa=b.empresa
		AND a.num_producto=b.abrevia_prod;

		IF (cTipCred IS NULL) THEN
			LET cCodRet= '00100';
			RETURN cCodRet, Npagosactual;
		END IF;
     END IF;

    IF cTipCred='T' THEN
  -- Obtiene fecha de corte
        SELECT dia_corte::INTEGER
        INTO Ndiacorte
        FROM bdicred:"informix".sd_maecredanexo
        WHERE empresa = cEmpresa
        AND num_credito = CNumCredito;

	    IF DAY(dtFechaHoy) <= Ndiacorte THEN
			let dFechaCorte = monthadd(mdy(MONTH(dtFechaHoy),Ndiacorte,YEAR(dtFechaHoy)), -1);
		ELSE
			let dFechaCorte = mdy(MONTH(dtFechaHoy),Ndiacorte,YEAR(dtFechaHoy));
		END IF;

  -- Obtiene pagos realizados historicos
        SELECT NVL(SUM(monto),0)
        INTO vPagosHist
        FROM bdicred:"informix".sd_movhis
        WHERE empresa = cEmpresa
          AND num_credito = CNumCredito
          AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanual)
          AND codigo_ref = 1
          AND reversado = 'N'
          AND fecha_mov > dFechaCorte
          AND fecha_mov <= dtFechaHoy;
  -- Obtiene pagos realizados actual

        SELECT NVL(SUM(monto),0)
        INTO vPagosAct
        FROM bdicred:"informix".sd_movdia
        WHERE empresa = cEmpresa
          AND num_credito = CNumCredito
          AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanual)
          AND codigo_ref = 1
          AND reversado = 'N'
          AND fecha_mov > dFechaCorte
          AND fecha_mov <= dtFechaHoy;

        LET Npagosactual = vPagosHist + vPagosAct;

 

    ELSE --lee dia de corte
		SELECT dia_corte::INTEGER
		INTO Ndiacorte
		FROM bdicred:"informix".sd_maecredanexocrd
		WHERE empresa = cEmpresa
		AND num_credito = CNumCredito;

        EXECUTE PROCEDURE bdicred:"informix".sp_fecha_plazo(cEmpresa,Ndiacorte)
        INTO cCodRet1, dFechaMesiver, dFechaCorte;

        IF (cCodRet1 <> '00000') THEN
			LET cCodRet= '00200';
			RETURN cCodRet, Npagosactual;
        END IF;

-- Obtiene pagos realizados historicos
--select sum(abonos)abonos from 
--(
        SELECT NVL(SUM(monto),0)-- abonos
        INTO vPagosHist
        FROM bdicred:"informix".sd_movhiscrd
        WHERE empresa = cEmpresa
          AND num_credito = CNumCredito
          AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd)
          AND codigo_ref = 1
          AND reversado = 'N'
          AND fecha_mov between  date(dFechaCorte + 1 units day) and dtFechaHoy;
  -- Obtiene pagos realizados actual
--union all
        SELECT NVL(SUM(monto),0) --abonos
        INTO vPagosAct
        FROM bdicred:"informix".sd_movdiacrd
        WHERE empresa = cEmpresa
          AND num_credito = CNumCredito
          AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd)
          AND codigo_ref = 1
          AND reversado = 'N'
          AND fecha_mov between  date(dFechaCorte + 1 units day) and dtFechaHoy;
--)
--group by abonos

		LET Npagosactual = vPagosHist + vPagosAct;
       
    END IF;



    IF (Ncantidad = 0) THEN
        RETURN cCodRet, Npagosactual;
    END IF;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se parametriza el numero de meses(variable cPeriodos) y se agrega lINea "a.fecha fecha," para obtener fecha completa y se paguina el sp',
'MODIFICO: Claudio Almodovar',
'FECHA: 30/07/2014',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_cargo_abono_mes_tdc (pempresa CHAR(3), pnum_credito CHAR(20))
	RETURNING CHAR(5), 
			  decimal(14,2),
			  decimal(14,2)

			 
	--------------------------------------------------------
	--	VARIABLES CONTROL DE ERRORES
	--------------------------------------------------------
	DEFINE cod_ret             		CHAR(5);
	DEFINE sql_err             		INTEGER;
	DEFINE v_cod_ret_otro			CHAR(5);

	DEFINE v_corta_linea_detalle 	INTEGER;
	DEFINE v_corta_linea_detalle2 	INTEGER;
	DEFINE v_corta_linea_mensaje 	INTEGER;


	DEFINE v_periodo_anterior   	DATE;			--Fecha Periodo Anterior
	DEFINE v_dias_periodo_tc 		INTEGER;		--dias_periodo_tc

	DEFINE v_periodo_tc_ini   		DATE;			--periodo_tc_ini
	DEFINE v_periodo_tc_fin   		DATE;			--periodo_tc_fin

	--------------------------------------------------------
	--	VARIABLES GENERACION DETALLE EDO CUENTA
	--------------------------------------------------------
	DEFINE v_dia           		CHAR(2);
	DEFINE v_mes           		CHAR(2);
	DEFINE v_ano	       		CHAR(4);
	DEFINE v_referencia    		CHAR(296);
	DEFINE v_referencia23  		CHAR(279);
	DEFINE v_rfc_comer     		CHAR(276);
	DEFINE v_transacc      		CHAR(4);
	DEFINE v_monto         		DECIMAL(14,2);
	DEFINE v_cargo         		DECIMAL(14,2);
	DEFINE v_abono      		DECIMAL(14,2);
	--DEFINE monto_total       	DECIMAL(18,2);
	--DEFINE naturaleza_toal		CHAR(1);

	DEFINE v_concepto      		VARCHAR(255);
	DEFINE v_naturaleza    		CHAR(1);
	DEFINE v_letra         		CHAR(15);
	DEFINE v_fecha_mov     		CHAR(12);

	DEFINE v_compra	       		DECIMAL(14,2);
	--DEFINE v_abono	       		DECIMAL(18,2);

	DEFINE v_maximo        		INTEGER;
	DEFINE v_contador      		SMALLINT;

	DEFINE v_Registros    		SMALLINT;
	DEFINE vfechacentral 		DATE;

	DEFINE iexists				INTEGER;	-- BANDERA DE SI SE LE GENERO UN CORTE O NO 
	DEFINE cfecAper				DATE;		-- FECHA DE APERTURA DEL CREDITO
	DEFINE cDiaCorte			CHAR(2);	-- DIA DE CORTE DEL CREDITO
	DEFINE cFecInicio			CHAR(10);	-- FECHA DE INICIO DEL PERIODO DE CONSULTA	

	--*******************************************************
	--*******************************************************
	--*******************************************************

	--------------------------------------------------------
	--	VARIABLES CONTROL DE ERRORES
	--------------------------------------------------------
	LET cod_ret = "00000";
	LET v_cod_ret_otro = "000";

	LET sql_err = "";
	LET v_corta_linea_detalle 	= 30;
	LET v_corta_linea_detalle2 	= 0;
	LET v_corta_linea_mensaje 	= 100;

	LET v_periodo_anterior   	= " ";  --Fecha Periodo Anterior
	LET v_dias_periodo_tc 		= 0;	--dias_periodo_tc

	LET v_periodo_tc_ini   		= " ";	--periodo_tc_ini
	LET v_periodo_tc_fin   		= " ";	--periodo_tc_fin

	--------------------------------------------------------
	--	VARIABLES GENERACION DETALLE EDO CUENTA
	--------------------------------------------------------
	LET vfechacentral  = NULL;
	LET v_dia          = "";
	LET v_mes          = "";
	LET v_ano	   	   = "";
	LET v_referencia   = "";
	LET v_referencia23 = "";
	LET v_rfc_comer    = "";
	LET v_transacc     = "";
	LET v_monto        = 0;
	--LET v_compra1        = 0;
	--LET v_compra2        = 0;
	--LET monto_tot      = 0;
	--LET monto_total    = 0;
	--LET naturaleza_toal = "";


	LET v_concepto     = "";
	LET v_naturaleza   = "";
	LET v_letra        = "";
	LET v_fecha_mov    = "";

	LET v_cargo       = 0;
	LET v_abono        = 0;

	LET v_maximo       = 0;
	LET v_contador     = 0;


	LET v_Registros    = 0;

	LET iexists		   = 1;		-- BANDERA DE SI SE LE GENERO UN CORTE O NO 
	LET cfecAper	   = '';	-- FECHA DE APERTURA DEL CREDITO
	LET cDiaCorte	   = '';	-- DIA DE CORTE DEL CREDITO
	LET cFecInicio	   = '';	-- FECHA DE INICIO DEL PERIODO DE CONSULTA


	--SET DEBUG FILE TO "/informix/movimientos_edoctaDIRECTO.out";
	--TRACE ON;

BEGIN

	ON EXCEPTION SET sql_err
		LET cod_ret = sql_err;
			RETURN cod_ret,NVL(v_abono, 0),NVL(v_cargo, 0);
	END EXCEPTION ;

	-------------------------------------------------------------
	--PERIODO ANTERIOR	
	-------------------------------------------------------------	 


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
	-- se obtiene la fecha hoy
	SELECT fecha_hoy 
	  INTO vfechacentral 
	  FROM bdicred:"informix".sd_fechas
	 WHERE empresa = '001';
	
	-- se obtiene el dia de corte
	SELECT dia_corte
	  INTO cDiaCorte
	  FROM bdicred:"informix".sd_maecredanexo
	 WHERE empresa = '001' 
	   AND num_credito = pnum_credito;
	   
	-- se le suma un dia al dia de corte
	LET cDiaCorte = cDiaCorte::INTEGER + 1;
	 
	-- se valida si el dia de la fecha hoy es mayor al dia de corte
	IF DAY(vfechacentral) > cDiaCorte THEN
	
		-- se une el mes de la fecha de hoy + el nuevo dia de corte + el aÃ±o de la fecha de hoy
		LET v_periodo_tc_ini = LPAD(MONTH(vfechacentral), 2, '0') || '-' || LPAD(cDiaCorte, 2, '0')  || '-' || YEAR(vfechacentral);
	
	-- se valida si el dia de la fecha de hoy es menor o igual al dia de corte
	ELIF DAY(vfechacentral) <= cDiaCorte THEN
	
		-- se le resta un mes a la fecha de hoy
		EXECUTE PROCEDURE bdicred:"informix".monthadd(vfechacentral, -1)
					 INTO cFecInicio;
		
		-- se une el mes de la fecha de hoy menos 1 mes + el nuevo dia de corte + el aÃ±o de la fecha de hoy menos 1 mes
		LET v_periodo_tc_ini = LPAD(MONTH(cFecInicio), 2, '0') || '-' || LPAD(cDiaCorte, 2, '0')  || '-' || YEAR(cFecInicio);
	
	END IF;	
			
	-- se asigna la fecha de final de consulta igual a la fecha de hoy
	LET v_periodo_tc_fin = vfechacentral;
	
	   	--##############################################################
	--##	GENERACION DETALLE	 EDO CUENTA				          ##
   	--##############################################################
   	   
		--------------------------------------------------------
    --      GENERA EL DETALLE DE LAS CUENTAS ABONOS
    --------------------------------------------------------
	--FOREACH WITH HOLD 
SELECT SUM(monto) 
		INTO v_abono
 FROM(
	select Sum(a.monto) monto
FROM bdicred:"informix".sd_movhis a
INNER JOIN bdicred:"informix".sd_transfun c ON TRIM(a.codigo_fun)||a.codigo_ref = TRIM(c.codigo_fun)||c.codigo_ref AND a.empresa = c.empresa
INNER JOIN bdinteg:"informix".si_transacc b ON c.empresa = b.empresa AND c.transacc = b.numero
	
		 WHERE a.empresa = pempresa
		   AND a.fecha_mov >= v_periodo_tc_ini
		   AND a.fecha_mov <= v_periodo_tc_fin
		   AND a.num_credito = pnum_credito
		   AND a.reversado <> "S"
		   AND b.se_emite_edocta = "S"
		   AND b.naturaleza = 'A'
 	 UNION ALL
		select Sum(a.monto) monto
		  FROM bdicred:"informix".sd_movdia a
	INNER JOIN bdicred:"informix".sd_transfun c ON TRIM(a.codigo_fun)||a.codigo_ref = TRIM(c.codigo_fun)||c.codigo_ref AND a.empresa = c.empresa
	INNER JOIN bdinteg:"informix".si_transacc b ON c.empresa = b.empresa AND c.transacc = b.numero
	     WHERE a.empresa = pempresa
		   AND a.fecha_mov >= v_periodo_tc_ini
		   AND a.fecha_mov <= v_periodo_tc_fin
		   AND a.num_credito = pnum_credito
		   AND a.reversado <> "S"
		   AND b.se_emite_edocta = "S"
		   AND b.naturaleza = 'A'
 );

		--------------------------------------------------------
    --      GENERA EL DETALLE DE LAS CUENTAS CARGOS 
    --------------------------------------------------------
  
SELECT SUM(monto) 
		into v_cargo 
 FROM(
   select Sum(a.monto) monto
FROM bdicred:"informix".sd_movhis a
INNER JOIN bdicred:"informix".sd_transfun c ON TRIM(a.codigo_fun)||a.codigo_ref = TRIM(c.codigo_fun)||c.codigo_ref AND a.empresa = c.empresa
INNER JOIN bdinteg:"informix".si_transacc b ON c.empresa = b.empresa AND c.transacc = b.numero
	
		 WHERE a.empresa = pempresa
		   AND a.fecha_mov >= v_periodo_tc_ini
		   AND a.fecha_mov <= v_periodo_tc_fin
		   AND a.num_credito = pnum_credito
		   AND a.reversado <> "S"
		   AND b.se_emite_edocta = "S"
		   AND b.naturaleza <> 'A'
 	 UNION ALL
		select Sum(a.monto) monto
		  FROM bdicred:"informix".sd_movdia a
	INNER JOIN bdicred:"informix".sd_transfun c ON TRIM(a.codigo_fun)||a.codigo_ref = TRIM(c.codigo_fun)||c.codigo_ref AND a.empresa = c.empresa
	INNER JOIN bdinteg:"informix".si_transacc b ON c.empresa = b.empresa AND c.transacc = b.numero
	     WHERE a.empresa = pempresa
		   AND a.fecha_mov >= v_periodo_tc_ini
		   AND a.fecha_mov <= v_periodo_tc_fin
		   AND a.num_credito = pnum_credito
		   AND a.reversado <> "S"
		   AND b.se_emite_edocta = "S"
		   AND b.naturaleza <> 'A'
 );

 
				RETURN cod_ret,NVL(v_abono, 0), NVL(v_cargo, 0);

END;
END PROCEDURE
DOCUMENT
'AUTOR: Ivan Castillo Montalvo',
'DESCRIPCION: Genera Acumulado cargos y abonos mensuales TDC',
'FECHA: ???',
'MODIFICO: ?????',
'VERSION: 20170111';

CREATE PROCEDURE "informix".sp_ce_consultafecha_inhabil (v_fecha DATE)

RETURNING CHAR(5), CHAR(1);
    
    ------------------------------------------------------------------------------>
    -- Objetivo: Sp para pago consulta de fechas laborales para el procesamiento de pólizas contables en días inhabiles 
    -- Autor: SADCV
    -- Fecha: 10/02/2016
    ------------------------------------------------------------------------------>
    
	------------------------------------------------------------------------------>
	--// Inicializa de Variables 

    DEFINE vSqlErr 			INTEGER;
    DEFINE cCodRet  		CHAR (5);
	DEFINE v_tipo       	SMALLINT;
	--DEFINE v_fecha 			DATE ;
	DEFINE v_laborable  	CHAR (1);

    ------------------------------------------------------------------------------>
	--// Inicializa variables
	
    LET vSqlErr 			= 0;
    LET cCodRet 			= '00000';
	LET v_laborable  		= '';
	
   -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Desactivar Debug   
   -- SET DEBUG FILE TO "/informix/SD/sp_ce_consultafecha_inhabil_.out";
   -- TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
		
    ------------------------------------------------------------------------------>
	--//
   
    BEGIN

    ON EXCEPTION SET vSqlErr
        IF vSqlErr <> 0 THEN
            let cCodRet = vSqlErr;
            --ROLLBACK WORK;
            RETURN cCodRet, v_tipo;
        END IF;
    END EXCEPTION;

	------------------------------------------------------------------------------>
	--//
	--BEGIN WORK;
	
    SET ISOLATION DIRTY READ;

		SELECT laborable
		INTO v_laborable
		FROM bdinteg:si_feriado
		WHERE fecha = v_fecha;
		
		LET v_fecha = v_fecha;
		LET v_laborable = v_laborable;
		
		IF v_laborable = 'N' THEN
			LET v_tipo = '0';
		ELSE
			LET v_tipo = '1';
		END IF;
		
		RETURN cCodRet, v_tipo;
    
	END;
	
END PROCEDURE;