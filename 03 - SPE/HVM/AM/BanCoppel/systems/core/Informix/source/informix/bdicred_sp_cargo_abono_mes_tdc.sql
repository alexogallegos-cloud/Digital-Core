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