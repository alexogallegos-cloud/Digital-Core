CREATE PROCEDURE "informix".sp_generareportecreditoclasico(dFechaIn DATETIME year to fraction(5),dFechaFin DATETIME year to fraction(5),cTrimestre cHAR(5),iMes INTEGER)
returning
char (5),
char(50);

--##################################################################################################
--### Creado por: Jorge Nuñez                                                                     ##
--##  Fecha: 08/07/2008                                                                           ##
--##  Descripcion: Replica informacion de credito mensualmente para el reporte trimestral de visa ##
--##   DESARROLLO                                               								  ##
--## MODIFICADO: JUAN FCO. PONCE DAMIAN	 01/01/2013                                               ##
--## MODIFICACION: Se modifico para reing. de reporte VISA. sólo llena las tablas trimestrales    ##
--##################################################################################################
--## MODIFICADO: JUAN FCO. PONCE DAMIAN	 15/06/2013                                               ##
--## MODIFICACION: Se mejoran consultas para ajilizar el proceso.							      ##
--##################################################################################################
--## MODIFICADO: JUAN FCO. PONCE DAMIAN	 29/07/2013                                               ##
--## MODIFICACION: Se modifica el proceso para obtener las cuentas internacionales por solicitud  ##
--## del usuario para que sea igual a la suma de cuentas corrientes y morosas.					  ##
--##################################################################################################
--## MODIFICADO: JUAN FCO. PONCE DAMIAN	 08/10/2013                                               ##
--## MODIFICACION: Se modifica el proceso para obtener las cuentas internacionales y pagos de re  ##
--## -cibo, por errores encontrados en el codigo.												  ##
--##################################################################################################
DEFINE iSqlErr          INTEGER;
DEFINE cVarDataErr      CHAR(100);
DEFINE cCodret          CHAR(5);
DEFINE cNumProducto     CHAR(4);
DEFINE iMes1            INTEGER;
DEFINE iAnio 	          INTEGER;
DEFINE dNumCuentasCredito DECIMAL;
DEFINE dNumTarjActPOS   DECIMAL;
DEFINE dNumTarjetas     DECIMAL;
DEFINE dNumTarjetasMod     DECIMAL;
DEFINE dNumeroNoAprobadasTotal DECIMAL;
DEFINE dNumeroEdoCuenta  DECIMAL;
DEFINE dLimiteCredito    MONEY(14,2);
DEFINE mCargoPorFinTotal MONEY(14,2);
DEFINE mCargoOtrosTotal  MONEY(14,2);
	DEFINE mDebitosMisc1     MONEY(14,2);
	DEFINE mDebitosMisc2     MONEY(14,2);
DEFINE mDebitosMiscTotal MONEY(14,2);
DEFINE mPagosTotal       MONEY(14,2);
	DEFINE mPagosTotal1       MONEY(14,2);
	DEFINE mPagosTotal2       MONEY(14,2);
	DEFINE mPagosTotal3       MONEY(14,2);
	DEFINE mPagosTotal4       MONEY(14,2);
	DEFINE mPagosTotal5       MONEY(14,2);
DEFINE mCredOtros        MONEY(14,2);

DEFINE dNumctas_men30       DECIMAL;
DEFINE dSdonumctas_men30    DECIMAL;
DEFINE dNumctas_may30       DECIMAL;
DEFINE dSdonumctas_may30    DECIMAL;
DEFINE dNumctas_may60       DECIMAL;
DEFINE dSdonumctas_may60    DECIMAL;
DEFINE dNumctas_may90       DECIMAL;
DEFINE dSdonumctas_may90    DECIMAL;
DEFINE dNumctas_may120      DECIMAL;
DEFINE dSdonumctas_may120   DECIMAL;
DEFINE iPeriodos			INTEGER;
DEFINE dNumeroEdoCuenta1  	DECIMAL;
DEFINE dNumeroEdoCuenta2  	DECIMAL;
DEFINE dNumeroEdoCuenta3  	DECIMAL;
DEFINE cFechaEdoCta_t       CHAR(10);
DEFINE cFechaEdoCta         DATETIME year to fraction(5);

DEFINE vsNumTarjeta CHAR (16);
DEFINE vsCodigoIso CHAR (2);
DEFINE vsCodtran CHAR (2);
DEFINE vsProdind CHAR (2);
DEFINE vsMovreversado char(1);

DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER;

DEFINE v_codfun char(5);
DEFINE v_codref char(5);
DEFINE v_transacc char(5);
DEFINE v_descripcion char(55);
DEFINE v_secuencia char(3);
DEFINE v_monto MONEY(16,2);
DEFINE v_cuentaA char(50);
DEFINE v_consulta CHAR(20);

  ON EXCEPTION  SET iSqlErr
  
		LET cVarDataErr = 'ERROR NO CONTROLADO (' || iSqlErr || '). ' ;
        LET cCodret= '-1';
		
		INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,ultima_actualizacion,estatus_actualizacion,dias_pendientes,ultimo_error)  
		VALUES ( 'sp_generareportecreditoclasico',iMes,dFechaIn::DATE,'', 0 ,cVarDataErr);
		RETURN cCodret, cVarDataErr;
  END EXCEPTION;
    
--Set debug file to "sp_generareportecreditoclasico.out";
--trace on;

LET cCodret = '00000';
LET cVarDataErr = '';
LET iAnio = YEAR(dFechaFin) ;
LET cNumProducto = '6001';

LET dNumctas_men30       = 0;
LET dSdonumctas_men30    = 0;
LET dNumctas_may30       = 0;
LET dSdonumctas_may30    = 0;
LET dNumctas_may60       = 0;
LET dSdonumctas_may60    = 0;
LET dNumctas_may90       = 0;
LET dSdonumctas_may90    = 0;
LET dNumctas_may120      = 0;
LET dSdonumctas_may120   = 0;
LET iPeriodos			 = 0;
LET vsNumTarjeta = '';
LET vsCodigoIso = '';
LET vsCodtran = '';
LET vsProdind = '';
LET vsMovreversado='';

LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;


LET v_codfun = '';
LET v_codref = '';
LET v_transacc = '';
LET v_descripcion = '';
LET v_secuencia = '';
LET v_monto = 0 ;
LET v_cuentaA  = '';
LET v_consulta = '';

		
	--BORRA LA TABLA tmpmovimientostrim Y LA DEJA LISTA PARA LA PROXIMA EJECUCIÓN
	SET ISOLATION TO DIRTY READ;
	IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames
	WHERE partnum is not null AND tabname = 'tmpmovimientostrim' AND dbsname= 'bdireports') THEN
	DROP TABLE bdireports:tmpmovimientostrim;
	END IF;	
	--CREA LA TABLA  tmpmovimientostrim
	CREATE TABLE tmpmovimientostrim
	(
		numTarjeta	CHAR (16),                                                                                     
		codigoIso	CHAR (2),
		prodind 	CHAR (2),
		codtran     CHAR(2),
		movreversado CHAR(1)
	) FRAGMENT BY ROUND ROBIN IN datos00, datos01, datos02 
	EXTENT SIZE 445312 NEXT SIZE 44531
	LOCK MODE ROW;
	
	begin work;
		CREATE INDEX idx_tmpmovimientostrim_01 ON bdireports:tmpmovimientostrim (ProdInd,CodigoIso);
	commit work;
	begin work;
		CREATE INDEX idx_tmpmovimientostrim_02 ON bdireports:tmpmovimientostrim (CodigoIso);
	commit work;

--Esta informacion solo se corre si es final de trimestre
		
		SET ISOLATION TO DIRTY READ;
		FOREACH WITH HOLD 
            SELECT   {+INDEX(Intercard:Movimiento idx_fechahorainauth)}
			NumTarjeta, CodigoIso, Prodind,codtran,movreversado
			INTO vsNumTarjeta, vsCodigoIso, vsProdind,vsCodtran, vsMovreversado
			FROM Intercard:Movimiento WHERE FechaHoraInAuth BETWEEN dFechaIn AND dFechaFin 
			AND Numtarjeta matches '426807*'  --CREDITO--
			UNION
			SELECT {+INDEX(Intercard:movimientoHistorico idx_fechahorainauth)}
			NumTarjeta, CodigoIso, Prodind,codtran,movreversado
			FROM Intercard:movimientoHistorico WHERE FechaHoraInAuth BETWEEN dFechaIn AND dFechaFin
			AND Numtarjeta matches '426807*'  --CREDITO--
			
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN 
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;
			
			SET LOCK MODE TO WAIT 3;
			INSERT INTO BdiReports:tmpmovimientostrim ( NumTarjeta, CodigoIso, Prodind)
					VALUES (vsNumTarjeta, vsCodigoIso, vsProdind);
			
			LET viContadorRegistros = viContadorRegistros + 1;
			
			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros = 5000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;
		
		END FOREACH ;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
		
		LET iMes1 = iMes - 2;
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
		LET dFechaIn = CAST(dFechaIn as DATE);
		LET dFechaFin = CAST(dFechaFin as DATE);	
		--Numero de cuentas - internacionales 
		/*Proporcionar el número de cuentas internacionales al final de este trimestre. Incluya las cuentas activas, inactivas o temporalmente bloqueadas. 
		  Una cuenta internacional le permite al tarjetahabiente utilizar la tarjeta en el país o territorio en que se emitió así como en todo el mundo*/
		/*Set isolation to dirty read;		
		SELECT count(a.num_credito) INTO dNumCuentasCredito FROM bdicred:sd_maecred a INNER JOIN bdicred:sd_tarjeta b 
		ON  a.num_credito = b.num_credito
		WHERE  a.num_producto='6001' AND a.fecha_apertura <= dFechaFin AND a.status_cred 
		NOT IN ('CV','FF') AND b.status_tar = 'A' AND b.numcte <> ''; */
		
		Set isolation to dirty read;
        /*select {+INDEX(bdicred:sd_maecred idx_maecred3)} count(num_credito) INTO dNumCuentasCredito
		from  bdicred:sd_maecred  where num_producto='6001' and  fecha_apertura <= dFechaFin
		and status_cred <> 'CV' and status_cred <> 'FF' and num_credito in 
		(select num_credito from bdicred:sd_tarjeta where numcte <> '' and status_tar = 'A');*/
		        		
		--Numero de tarjetas con actividad en en pos
		SELECT NVL(COUNT(DISTINCT numtarjeta), 0)
		INTO dNumTarjActPOS
		FROM BdiReports:tmpmovimientostrim
		WHERE ProdInd = '02'
		AND CodigoIso <> ''; -- POS
		
		--Se guardan las tarjetas canceladas en el trimestre, para sumarlas al total.
		Set isolation to dirty read;
		select NVL(count(numtarjeta), 0) INTO dNumTarjetasMod 
		from  intercard:tarjeta  where  codproductotarjeta in('001','002','003','004')
		and fechaultmodif::date >= dFechaIn and fechaultmodif::date <= dFechaFin and  
		codstatustarjeta in ('CAN','INA','DES','FAL','EXT','DAN','ROB') 
		and fechaasignacion <= dFechaFin ;
		
		select NVL(count(numtarjeta), 0) 
		INTO dNumTarjetas
		from  intercard:tarjeta
		where  codproductotarjeta in('001','002','003','004')
		and fechaasignacion <= dFechaFin
		and codstatustarjeta not in ('CAN','INA','DES','FAL','EXT','DAN','ROB');
		
		LET dNumTarjetas = dNumTarjetas + dNumTarjetasMod ;

		
		--Numero de transacciones NO aprobadas
		SELECT NVL(COUNT(*), 0)
		INTO dNumeroNoAprobadasTotal
		FROM BdiReports:tmpmovimientostrim
		WHERE  CodigoIso <> '00'
		AND numtarjeta matches '426807*';
			
		--Estados de cuenta
  		LET cFechaEdoCta_t = iMes1 || '-' || '20' || '-' || iAnio;
		LET cFechaEdoCta = CAST (cFechaEdoCta_t AS DATE);

		SET ISOLATION TO DIRTY READ;
		SELECT NVL(COUNT(*), 0)
		INTO dNumeroEdoCuenta1
		FROM bdicred@pld_tcp:sd_pie_edocta
		WHERE fecha_emision = cFechaEdoCta
        AND num_credito is not null ;

	  	LET cFechaEdoCta_t = iMes1 + 1 || '-' || '20' || '-' || iAnio;
    	LET cFechaEdoCta = CAST (cFechaEdoCta_t AS DATE);

		SELECT NVL(COUNT(*), 0)
		INTO dNumeroEdoCuenta2
		FROM bdicred@pld_tcp:sd_pie_edocta
		WHERE fecha_emision = cFechaEdoCta
        AND num_credito is not null;

    	LET cFechaEdoCta_t = iMes1 + 2 || '-' || '20' || '-' || iAnio;
    	LET cFechaEdoCta = CAST (cFechaEdoCta_t AS DATE);

		SELECT NVL(COUNT(*), 0)
		INTO dNumeroEdoCuenta3
		FROM bdicred@pld_tcp:sd_pie_edocta
		WHERE fecha_emision = cFechaEdoCta
        AND num_credito is not null;

		LET dNumeroEdoCuenta = dNumeroEdoCuenta1 + dNumeroEdoCuenta2 + dNumeroEdoCuenta3;

		IF dNumeroEdoCuenta IS NULL THEN
			LET dNumeroEdoCuenta = 0;
		END IF;

		--Limite de credito total
		SELECT SUM(NVL(monto_otorgado,0)) INTO dLimiteCredito FROM bdicred:sd_maesdoscont a INNER JOIN bdicred:sd_maecredcont b 
		ON (a.num_credito = b.num_credito AND a.fecha = b.fecha )
		WHERE b.fecha = dFechaFin AND b.status_cred <> 'CV';
		
		IF dLimiteCredito IS NULL THEN
			LET dLimiteCredito = 0;
		END IF;
		
		
		SELECT {+INDEX(bdireports:rpt_volumetria idx_rpt_volumetria)} SUM ( case when id_col = 'VVP' then (campo_h + campo_j )
		when id_col in ('CEN','CEI') then (campo_b + campo_d + campo_f + campo_j) end) 	INTO mCargoPorFinTotal
		FROM bdireports:rpt_volumetria where num_producto = cNumProducto and trimestre = cTrimestre and 
		id_col <> '' and mes <> 0;
		

		--Cargos por pagos en atraso y otros
		SET ISOLATION TO DIRTY READ;
        SELECT  SUM (saldo_fin_de_dia)  INTO mCargoOtrosTotal
        FROM bdicont:co_histsdodias s 
        WHERE s.empresa = '001' AND s.ccmayor='5105'  AND s.ccsub = '61' AND s.ccsubsub ='01' AND s.ccssubsub='01'
        AND s.ccsssubsub='02' AND s.sector='32' and s.ciudad is not null AND s.sucursal is not null
        and s.mes_dia = dFechaFin;

		--Pagos Recibidos
		SET ISOLATION TO DIRTY READ;
		
		SELECT {+MULTI_INDEX (sd_movhis)} SUM(NVL(monto,0)) INTO mPagosTotal1 FROM bdicred:sd_movhis WHERE empresa= '001' and fecha_mov between dFechaIn and dFechaFin
		and num_credito > 0 and codigo_fun in ('334','335') and codigo_ref in ('7','8','10','907','908','909') and reversado = 'N' and num_producto NOT IN ('7000');
		
		SELECT {+MULTI_INDEX (sd_movhis)} SUM(NVL(monto,0)) INTO mPagosTotal2 FROM bdicred:sd_movhis WHERE empresa= '001' and fecha_mov between dFechaIn and dFechaFin
		and num_credito > 0 and codigo_fun = '033' and codigo_ref in ('7','8','10','901','907','908','909') and reversado = 'N' and num_producto NOT IN ('7000');
		
		SELECT {+MULTI_INDEX (sd_movhis)} SUM(NVL(monto,0)) INTO mPagosTotal3 FROM bdicred:sd_movhis WHERE empresa= '001' and fecha_mov between dFechaIn and dFechaFin
		and num_credito > 0 and codigo_fun = '336' and codigo_ref in ('7','8','10','901','907','908','909') and reversado = 'N' and num_producto NOT IN ('7000');
		
		SELECT {+MULTI_INDEX (sd_movhis)} SUM(NVL(monto,0)) INTO mPagosTotal4 FROM bdicred:sd_movhis WHERE empresa= '001' and fecha_mov between dFechaIn and dFechaFin
		and num_credito > 0 and codigo_fun ='337' and codigo_ref in ('10','901','907','908','909') and reversado = 'N' and num_producto NOT IN ('7000');

		SELECT {+MULTI_INDEX (sd_movhis)} SUM(NVL(monto,0)) INTO mPagosTotal5 FROM bdicred:sd_movhis WHERE empresa= '001' and fecha_mov between dFechaIn and dFechaFin
		and num_credito > 0 and codigo_fun ='342' and codigo_ref='1' and reversado = 'N' and num_producto NOT IN ('7000');

		--LET mPagosTotal = mPagosTotal1 + mPagosTotal2 + mPagosTotal3 + mPagosTotal4 + mPagosTotal5 ; 
		LET mPagosTotal = NVL(mPagosTotal1,0) + NVL(mPagosTotal2,0) + NVL(mPagosTotal3,0) + NVL(mPagosTotal4,0) + NVL(mPagosTotal5,0) ;
		----Debitos Miscelaneos 
		/*
		SET ISOLATION TO DIRTY READ;
		
		select SUM(NVL(monto,0)) INTO mDebitosMisc1 FROM bdicred:sd_movhis WHERE empresa= '001' and fecha_mov between dFechaIn and dFechaFin
		and num_credito > 0 and codigo_fun = '340' and codigo_ref in ('1','2')  and reversado = 'N';

		select SUM(NVL(monto,0)) INTO mDebitosMisc2 FROM bdicred:sd_movhis WHERE empresa= '001' and fecha_mov between dFechaIn and dFechaFin
		and num_credito > 0 and codigo_fun = '339' and codigo_ref in ('1','3','50')  and reversado = 'N';

		LET mDebitosMiscTotal = mDebitosMisc1 + mDebitosMisc2 ;
		*/
		LET mDebitosMiscTotal = 0 ;
		
		/*select sum(NVL(sdo_cap_insoluto,0)) INTO mCredOtros FROM bdicred:sd_maecred a INNER JOIN 
		bdicred:sd_maesdos_vendida b ON a.num_credito = b.num_credito 
		WHERE a.empresa = '001' AND a.status_cred = 'CV' AND a.num_producto = '6001';*/
		set isolation to dirty read;

		SELECT sum(NVL(sdo_cap_insoluto,0)) INTO mCredOtros 
		FROM bdicred:sd_maecred mae, bdicred:sd_maesdos_vendida ven
		WHERE mae.empresa = '001' and num_producto = '6001'
		AND ven.empresa = '001' AND mae.num_credito = ven.num_credito AND mae.status_cred = 'CV'
        AND ven.fecha >= dFechaIn AND ven.fecha <= dFechaFin;
		
		---Obtener numero y saldos de las cuentas cuentas corrientes morosas
	
		-- SELECT NVL(mto_fin_ven_trasp,0),SUM(CASE WHEN NVL(sdo_cap_insoluto, 0) < 0 THEN 0 ELSE sdo_cap_insoluto END), NVL(COUNT(*),0)
		-- COMENTARIOS PARA AGREGAR LAS MODIFICACIONES NECESARIAS SOLO PARA QUE TOME EL REPORTE DE VISA "RELIZA EL FILTRADO Y UNIENDO LA TABLA "sd_maecredcont" 
		-- PARA FILTRAR EL PRODUCTO"
		SELECT SUM(CASE WHEN NVL(sdo_cap_insoluto, 0) < 0 THEN 0 ELSE sdo_cap_insoluto END), NVL(COUNT(*),0)
		INTO dNumctas_men30, dSdonumctas_men30
		FROM  bdicred:sd_maesdoscont 
		WHERE fecha = dFechaFin AND empresa='001' AND num_credito is not null AND mto_fin_ven_trasp <= 1;
		
		SELECT SUM(CASE WHEN NVL(sdo_cap_insoluto, 0) < 0 THEN 0 ELSE sdo_cap_insoluto END), NVL(COUNT(*),0)
		INTO  dNumctas_may30, dSdonumctas_may30
		FROM  bdicred:sd_maesdoscont a
		WHERE fecha = dFechaFin AND empresa='001' AND num_credito is not null and mto_fin_ven_trasp = 2;

		SELECT SUM(CASE WHEN NVL(sdo_cap_insoluto, 0) < 0 THEN 0 ELSE sdo_cap_insoluto END), NVL(COUNT(*),0)
		INTO dNumctas_may60, dSdonumctas_may60
		FROM  bdicred:sd_maesdoscont a
		WHERE fecha = dFechaFin AND empresa='001' AND num_credito is not null and mto_fin_ven_trasp = 3;

		SELECT SUM(CASE WHEN NVL(sdo_cap_insoluto, 0) < 0 THEN 0 ELSE sdo_cap_insoluto END), NVL(COUNT(*),0)
		INTO dNumctas_may90, dSdonumctas_may90
		FROM  bdicred:sd_maesdoscont a
		WHERE fecha = dFechaFin AND empresa='001' AND num_credito is not null and mto_fin_ven_trasp = 4;

        -- se deja el periodo 5 como fijo para saldos de las cuentas cuentas corrientes morosas con 4 ó mas periodos  -- casanova edeza hector
		SELECT  SUM(CASE WHEN NVL(sdo_cap_insoluto,0) < 0 THEN 0 ELSE sdo_cap_insoluto END), NVL(COUNT(*),0)
		INTO dNumctas_may120, dSdonumctas_may120
		FROM  bdicred: sd_maesdoscont a
		WHERE fecha = dFechaFin AND empresa='001' AND num_credito is not null and mto_fin_ven_trasp > 4;
		
		--Numero de cuentas internacionales, es igual a la suma de todas las cuentas corrientes o morasos a la fecha.
		--LET dNumCuentasCredito= dNumctas_men30+ dNumctas_may30+ dNumctas_may60+ dNumctas_may90+ dNumctas_may120;
		LET dNumCuentasCredito= dSdonumctas_men30+ dSdonumctas_may30+ dSdonumctas_may60+ dSdonumctas_may90+ dSdonumctas_may120;
		
		--Guarda en la base de datos
		SET LOCK MODE TO WAIT 3;
		INSERT INTO bdireports:rpt_creditoclasica
		(
			ide_producto,
			tipo_producto,
			trimestre,
			car_fin,
			car_pagatra,
			deb_mis,
			per_credctas,
			per_credbru,
			mon_reccred,
			per_fractas,
			per_frabru,
			mon_recfra,
			pag_recidos,
			vau_cred,
			otros_cred,
			num_ctasinter,
			num_ctasrest,
			num_tar,
			est_ctasenviados,
			est_ctasfina,
			numctas_men30,
			sdonumctas_men30,
			numctas_may30,
			sdonumctas_may30,
			numctas_may60,
			sdonumctas_may60,
			numctas_may90,
			sdonumctas_may90,
			numctas_may120,
			sdonumctas_may120,
			numctas_ptovta,
			numtran_noapro,
			num_refe,
			limcred_tot,
			cuota_anual,
			visami_com,
			visami_uni
		)
		VALUES
		(
			cNumProducto,
			'C',
			cTrimestre,
			NVL(mCargoPorFinTotal,0.0),
			NVL(mCargoOtrosTotal,0.0),
			NVL(mDebitosMiscTotal,0.0),
			0,
			0,
			0,
			0,
			0,
			0,
			NVL(mPagosTotal,0.0),
			0,
			NVL(mCredOtros,0.0),
			NVL(dNumCuentasCredito,0.0),
			0,
			NVL(dNumTarjetas,0.0),
			NVL(dNumeroEdoCuenta,0.0),
			0,
			NVL(dSdonumctas_men30,0.0),
			NVL(dNumctas_men30,0),
			NVL(dSdonumctas_may30,0.0),
			NVL(dNumctas_may30,0),
			NVL(dSdonumctas_may60,0.0),
			NVL(dNumctas_may60,0),
			NVL(dSdonumctas_may90,0.0),
			NVL(dNumctas_may90,0),
			NVL(dSdonumctas_may120,0.0),
			NVL(dNumctas_may120,0),
			NVL(dNumTarjActPOS,0),
			NVL(dNumeroNoAprobadasTotal,0),
			0,
			NVL(dLimiteCredito,0.0),
			0,
			0,
			0
		);
	
RETURN cCodRet,cVarDataErr;

END PROCEDURE;