CREATE PROCEDURE "informix".sp_reproceso_volumetriacred(cTrimestre CHAR(5),iMes INTEGER,dFecha1 date, dFecha2 date)
returning
char (5),
char(100);

DEFINE iSqlErr          INTEGER;
DEFINE iSamErr          INTEGER;
DEFINE cVarDataErr      CHAR(100);
DEFINE cCodret          CHAR(5);
DEFINE cNumProducto     CHAR(4);
DEFINE cTransacc_suc    CHAR(4);
DEFINE iTotalDisp       DECIMAL;
DEFINE mSaldoDisp   MONEY(14,2);
DEFINE dNumDispATM2      DECIMAL;
DEFINE mSaldoDispATM2    MONEY(14,2);
DEFINE dNumDispATMtotal      DECIMAL;
DEFINE mSaldoDispATMtotal    MONEY(14,2);
DEFINE dNumDispATM1      DECIMAL;
DEFINE mSaldoDispATM1    MONEY(14,2);
DEFINE iMes1            INTEGER;
DEFINE iAnio 	          INTEGER;
DEFINE dNumComprasNac1   DECIMAL;
DEFINE mSaldoComprasNac1 MONEY(14,2);
DEFINE dNumComprasNac2   DECIMAL;
DEFINE mSaldoComprasNac2 MONEY(14,2);
DEFINE dNumComprasNactotal   DECIMAL;
DEFINE mSaldoComprasNactotal MONEY(14,2);
DEFINE dNumDispATMint1   DECIMAL;
DEFINE mMontoDispATM1    MONEY(14,2);
DEFINE dNumDispATMint2   DECIMAL;
DEFINE mMontoDispATM2   MONEY(14,2);
DEFINE dNumDispATMintTotal   DECIMAL;
DEFINE mMontoDispATMtotal    MONEY(14,2);
DEFINE dNumDispATMprop  DECIMAL;
DEFINE mMontoDispATMproptotal MONEY(14,2);
DEFINE dNumComprasEI1    DECIMAL;
DEFINE mSaldoComprasEI1  MONEY(14,2);
DEFINE dNumComprasEI2    DECIMAL;
DEFINE mSaldoComprasEI2  MONEY(14,2);
DEFINE dNumComprasEItotal    DECIMAL;
DEFINE mSaldoComprasEItotal  MONEY(14,2);
DEFINE dNumCuentasCredito DECIMAL;
DEFINE dNumTarjActPOS   DECIMAL;
DEFINE dNumTarjetas     DECIMAL;
DEFINE dNumeroAprobadas1 DECIMAL;
DEFINE dNumeroNoAprobadas1 DECIMAL;
DEFINE dNumeroAprobadas2 DECIMAL;
DEFINE dNumeroNoAprobadas2 DECIMAL;
DEFINE dNumeroAprobadasTotal DECIMAL;
DEFINE dNumeroNoAprobadasTotal DECIMAL;
DEFINE dFechaIn         DATETIME year to fraction(5);
DEFINE dFechaFin         DATETIME year to fraction(5);
DEFINE cCodFila          CHAR(3);
DEFINE cFecha1           CHAR(50);
DEFINE cFecha2           CHAR(50);
DEFINE dNumeroEdoCuenta  DECIMAL;
DEFINE dLimiteCredito    MONEY(14,2);
DEFINE mCargoPorFin1     MONEY(14,2);
DEFINE mCargoPorFin2     MONEY(14,2);
DEFINE mCargoPorFinTotal MONEY(14,2);
DEFINE mCargoOtros1      MONEY(14,2);
DEFINE mCargoOtros2      MONEY(14,2);
DEFINE mCargoOtros3      MONEY(14,2);
DEFINE mCargoOtrosTotal  MONEY(14,2);
DEFINE mDebitosMisc1     MONEY(14,2);
DEFINE mDebitosMisc2     MONEY(14,2);
DEFINE mDebitosMisc3     MONEY(14,2);
DEFINE mDebitosMisc4     MONEY(14,2);
DEFINE mDebitosMiscTotal MONEY(14,2);
DEFINE mPagos1           MONEY(14,2);
DEFINE mPagos2           MONEY(14,2);
DEFINE mPagos3           MONEY(14,2);
DEFINE mPagosTotal       MONEY(14,2);
DEFINE cProd             CHAR(2);
DEFINE cNacional         CHAR(1);
DEFINE cCodtran         CHAR(2);
DEFINE cFormato         CHAR(4);
DEFINE cTrancajeropropio CHAR(1);
DEFINE iMesFecha         INTEGER;
DEFINE dTotal            DECIMAL;
DEFINE dSaldo            DECIMAL;
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
DEFINE mDebitosMisc5        MONEY(14,2);
DEFINE dNumeroEdoCuenta1  	DECIMAL;
DEFINE dNumeroEdoCuenta2  	DECIMAL;
DEFINE dNumeroEdoCuenta3  	DECIMAL;
DEFINE cFechaEdoCta_t       CHAR(10);
DEFINE cFechaEdoCta         DATETIME year to fraction(5);

DEFINE vsNumTarjeta CHAR (16);
DEFINE vsSecuencia CHAR (7);
DEFINE vmMonto MONEY (14,2);
DEFINE vsCodigoIso CHAR (2);
DEFINE vsCodtran CHAR (2);
DEFINE vsFormato CHAR (4);
DEFINE vsProdind CHAR (2);
DEFINE vsTrancajeropropio CHAR (1);
DEFINE vsEsNacional CHAR (1);
DEFINE dtFechaHoraInAuth DATETIME YEAR TO FRACTION (5);
DEFINE vsMovreversado char(1);

DEFINE v_snum_credito_mv 	CHAR(20);
DEFINE v_snum_credito_mc    CHAR(20);
DEFINE v_mmonto    			money(16,2);
DEFINE v_scodigo_fun 		CHAR(5);
DEFINE v_scodigo_ref 		CHAR(5);
DEFINE v_stransacc_suc 		CHAR(5);

DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER;

DEFINE vsNumcred char(25);
DEFINE vsTarjeta char(16);
DEFINE vsFoliosuc char(16);
DEFINE vsMonto_tot money(16,2);
DEFINE vsFech_alt date;
DEFINE vsTransacc char(4);
DEFINE vsReferencia char(50);
DEFINE vsCuentafolio char(41);

/***********JYDG*************/
DEFINE v_codfun char(5);
DEFINE v_codref char(5);
DEFINE v_transacc char(5);
DEFINE v_descripcion char(55);
DEFINE v_secuencia char(3);
DEFINE v_monto MONEY(16,2);
DEFINE v_cuentaA char(50);
DEFINE v_consulta CHAR(20);
/***********JYDG*************/

DEFINE iTotalComprasEntTotal DECIMAL;
DEFINE dMontoComprasEntTotal MONEY(14,2);
DEFINE iTotalDispATMtotal    DECIMAL;
DEFINE iTotalComprasInterTotal DECIMAL;
DEFINE dMontoComprasInterTotal DECIMAL;
DEFINE iTotalDispAtmIntTotal DECIMAL;
DEFINE dMontoAtmIntTotal     MONEY(14,2);


  ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
		
	--VALIDA SI EXISTE LA TABLATEMPORAL DE MOVIMIENTOS
			IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames
				WHERE partnum is not null AND tabname = 'tmpmovimientosmensual' AND dbsname= 'bdireports') THEN
				DROP TABLE bdireports:tmpmovimientosmensual;
			END IF;
			
		IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames
			WHERE partnum is not null AND tabname = 'tmpmovimientosmensual_vic' AND dbsname= 'bdireports') THEN
			DROP TABLE bdireports:tmpmovimientosmensual_vic;
		END IF;
	
            LET cCodret=iSqlErr;
            RETURN cCodret, cVarDataErr;
        END IF;
  END EXCEPTION;
    
--Set debug file to "/ids_fc5/perifericos/visacred.txt";
--trace on;


LET cCodret = '000';
LET cVarDataErr = '';
LET iAnio = YEAR(dFecha1);
LET iTotalDisp=0.0;
LET dNumComprasNac1 = 0;
LET mSaldoComprasNac1 = 0;
LET dNumDispATM1 = 0;
LET mSaldoDispATM1 = 0;
LET dNumComprasEI1 = 0;
LET mSaldoComprasEI1 = 0;
LET dNumDispATMint1 = 0;
LET mMontoDispATM1 = 0;
LET dNumComprasNac2 = 0;
LET mSaldoComprasNac2= 0;
LET dNumDispATM2 = 0;
LET mSaldoDispATM2 = 0;
LET dNumComprasEI2 = 0;
LET mSaldoComprasEI2 = 0;
LET dNumDispATMint2 = 0;
LET mMontoDispATM2 = 0;
LET dNumComprasNactotal = 0;
LET mSaldoComprasNactotal = 0;
LET dNumDispATMtotal = 0;
LET mSaldoDispATMtotal = 0;
LET dNumComprasEItotal = 0;
LET mSaldoComprasEItotal = 0;
LET dNumDispATMintTotal = 0;
LET mMontoDispATMtotal = 0;
LET dNumDispATMprop = 0.0;
LET mMontoDispATMproptotal = 0.0;

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
LET vsSecuencia = '';
LET vmMonto = 0.0;
LET vsCodigoIso = '';
LET vsCodtran = '';
LET vsFormato= '';
LET vsProdind = '';
LET vsTrancajeropropio = '';
LET vsEsNacional = '';
LET dtFechaHoraInAuth = CURRENT;
LET vsMovreversado='';

LET v_snum_credito_mv = '';
LET v_snum_credito_mc = '';
LET v_mmonto = 0.0;
LET v_scodigo_fun = '';
LET v_scodigo_ref = '';
LET v_stransacc_suc = '';

LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;

LET vsNumcred ='';
LET  vsTarjeta ='';
LET  vsFoliosuc ='';
LET  vsMonto_tot =0.0;
LET  vsFech_alt = today;
LET  vsTransacc ='';
LET  vsReferencia ='';
LET  vsCuentafolio ='';

/***********JYDG*************/
LET v_codfun ='';
LET v_codref ='';
LET v_transacc ='';
LET v_descripcion ='';
LET v_secuencia ='';
LET v_monto =0;
LET v_cuentaA  ='';
LET v_consulta ='';
/***********JYDG*************/

LET iTotalComprasEntTotal = 0;
LET dMontoComprasEntTotal = 0;  
LET iTotalDispAtmTotal = 0;
LET iTotalComprasInterTotal = 0;
LET dMontoComprasInterTotal = 0;
LET iTotalDispAtmIntTotal = 0;
LET dMontoAtmIntTotal = 0;
 

LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;


BEGIN WORK;
	DELETE {+INDEX(rpt_volumetria idx_rpt_volumetria)} FROM  bdireports:rpt_volumetria where trimestre=cTrimestre and  mes=iMes and num_producto='6001';
COMMIT WORK;

--INFORMACION DE CREDITO

	--Disposiciones de efectivo Propio numero y monto
	SET ISOLATION TO DIRTY READ;
	SELECT  --{+INDEX(bdicred:sd_movhis inx_movhis4)}
	NVL(count(*),0) as total ,sum(NVL(monto,0)) as saldo
	INTO iTotalDisp,mSaldoDisp
	FROM bdicred:sd_movhis
	WHERE empresa='001' 
	AND num_credito <> ''
    AND fecha_mov >= dFecha1
    AND fecha_mov <= dFecha2
	AND reversado ='N'
    AND transacc_suc in ('6900','7380')
	AND num_producto = '6001'
	GROUP BY num_producto;


	IF iTotalDisp IS NULL OR mSaldoDisp IS NULL THEN
		LET iTotalDisp = 0;
		LET mSaldoDisp = 0;
	END IF

	--Inserta en la base de datos

	LET cCodFila = 'VVP';
	LET cNumProducto = '6001';

	INSERT INTO bdireports:rpt_volumetria(num_producto,trimestre,id_col,mes,campo_a,campo_b,campo_c,campo_d,campo_e,campo_f,campo_g,campo_h,campo_i,campo_j)
	VALUES(cNumProducto,cTrimestre,cCodFila,iMes,0,0,0,0,0,0,iTotalDisp,mSaldoDisp,0,0);
	
	--VALIDA SI EXISTE LA TABLATEMPORAL DE MOVIMIENTOS
	SET ISOLATION TO DIRTY READ;
	
	IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames
		WHERE partnum is not null AND tabname = 'tmpmovimientosmensual' AND dbsname= 'bdireports') THEN
		DROP TABLE bdireports:tmpmovimientosmensual;
	END IF;
	
	CREATE TABLE bdireports:tmpmovimientosmensual
	(
		cuenta char(25),
		num_tarjeta char(16),
		folio_suc char(16),
		monto_tot money(16,2),
		fech_alt date,
		transacc char(4),
		referencia char(50),
		cuentafolio char(41)
	) FRAGMENT BY ROUND ROBIN IN datos00, datos01, datos02  
	extent size 143552 next size 14352
	LOCK MODE ROW;
	
	BEGIN WORK;
	CREATE INDEX idx_TmpMovimientosmensual ON bdireports:tmpmovimientosmensual (cuentafolio)  in datos03;
	COMMIT WORK;
	BEGIN WORK;
	CREATE INDEX idx_TmpMovimientosmensual2 ON bdireports:tmpmovimientosmensual (transacc, fech_alt) in datos03;
	COMMIT WORK;
	
	UPDATE STATISTICS MEDIUM FOR TABLE bdireports:tmpmovimientosmensual;
	
	--VALIDA SI EXISTE LA TABLATEMPORAL DE MOVIMIENTOS (VIC)
	SET ISOLATION TO DIRTY READ;
	
	IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames
		WHERE partnum is not null AND tabname = 'tmpmovimientosmensual_vic' AND dbsname= 'bdireports') THEN
		DROP TABLE bdireports:tmpmovimientosmensual_vic;
	END IF;
	
	CREATE TABLE bdireports:tmpmovimientosmensual_vic
	(
		cuenta char(25),
		num_tarjeta char(16),
		folio_suc char(16),
		monto_tot money(16,2),
		fecha_aplica date,
		transacc char(4),
		referencia char(50),
		cuentafolio char(41)
	) FRAGMENT BY ROUND ROBIN IN datos00, datos01, datos02
	extent size 143552 next size 14352
	LOCK MODE ROW;
	
	BEGIN WORK;
		CREATE INDEX idx_TmpMovimientosmensual_vic ON bdireports:tmpmovimientosmensual_vic (cuentafolio) in datos03;
	COMMIT WORK;
	BEGIN WORK;
		CREATE INDEX idx_TmpMovimientosmensual_vic2 ON bdireports:tmpmovimientosmensual_vic (fecha_aplica) in datos03;
	COMMIT WORK;
	
	UPDATE STATISTICS MEDIUM FOR TABLE bdireports:tmpmovimientosmensual_vic;

	--///////////////// CARGA DE MOVIMIENTOS DE LIBERACION DEL MES /////////////////////////////
	
	LET vsFlagEnTransaccion = 'F';
	LET viContadorRegistros = 0;
	
	SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD		
			select --{+INDEX(bdicred:sd_movhis inx_movhis4)}
			num_credito,nro_tarjeta,folio_suc,monto,fecha_mov,transacc_suc,referencia,trim(num_credito)||trim(folio_suc)
			into vsNumcred, vsTarjeta,vsFoliosuc,vsMonto_tot, vsFech_alt,vsTransacc,vsReferencia,vsCuentafolio
			from bdicred:sd_movhis where empresa='001' 
			and num_credito <> ''
			and fecha_mov >=dFecha1
			and fecha_mov <=dFecha2
			and reversado ='N'
			and sucursal='9290'
			and transacc_suc in ('6830','6872','6871','6825','6824','7383','7382','6873','6826','7384','6800','7381')
		
		--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (vsFlagEnTransaccion = 'F') THEN
			 BEGIN WORK;
			 LET vsFlagEnTransaccion = 'V';
		END IF;

		SET LOCK  MODE TO WAIT 3;
		INSERT INTO bdireports:tmpmovimientosmensual ( cuenta,num_tarjeta,folio_suc,monto_tot,fech_alt,transacc,referencia ,cuentafolio )
		VALUES (vsNumcred, vsTarjeta,vsFoliosuc,vsMonto_tot, vsFech_alt,vsTransacc,vsReferencia,vsCuentafolio);

		LET viContadorRegistros = viContadorRegistros + 1;

		--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
			CONTINUE FOREACH;
		END IF;
		
	END FOREACH ;

	-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
	IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
		COMMIT WORK;
		UPDATE STATISTICS MEDIUM FOR TABLE bdireports:tmpmovimientosmensual;
		LET vsFlagEnTransaccion = 'F';
	END IF;	

	--///////////////// CARGA DE MOVIMIENTOS INTERNACIONALES DE BDITARJETA (VIC) DEL MES /////////////////////////////
	
	LET vsNumcred ='';
	LET  vsTarjeta ='';
	LET  vsFoliosuc ='';
	LET  vsMonto_tot =0.0;
	LET  vsFech_alt = today;
	LET  vsTransacc ='';
	LET  vsReferencia ='';
	LET  vsCuentafolio ='';

	LET vsFlagEnTransaccion = 'F';
	LET viContadorRegistros = 0;
	
	SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD	
		select {+INDEX(bditarjeta:td_conposvic idx_concvic), (bdicred:sd_tarjeta idx_tarjeta1)} 
		b.num_credito, a.cuenta, a.folio_mov,a.monto,a.fecha_aplica,a.tran_central,a.referencia ,trim(b.num_credito)||trim(a.folio_mov)
		into vsNumcred, vsTarjeta,vsFoliosuc,vsMonto_tot, vsFech_alt,vsTransacc,vsReferencia,vsCuentafolio
		from bditarjeta:td_conposvic a, bdicred:sd_tarjeta b where a.empresa='001' 
		and (a.bandera_proceso ='C' or a.bandera_proceso ='A')
		and a.fecha_aplica >= dFecha1
		and a.fecha_aplica <= dFecha2
		and a.tran_central in ('0801')
		and a.cuenta = b.num_tarjeta
		and b.empresa = a.empresa
		and b.num_tarjeta = a.cuenta
	
		--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (vsFlagEnTransaccion = 'F') THEN
			 BEGIN WORK;
			 LET vsFlagEnTransaccion = 'V';
		END IF;

		SET LOCK  MODE TO WAIT 3;
		INSERT INTO bdireports:tmpmovimientosmensual_vic ( cuenta,num_tarjeta,folio_suc,monto_tot,fecha_aplica,transacc,referencia ,cuentafolio )
		VALUES (vsNumcred, vsTarjeta,vsFoliosuc,vsMonto_tot, vsFech_alt,vsTransacc,vsReferencia,vsCuentafolio);

		LET viContadorRegistros = viContadorRegistros + 1;

		--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
			CONTINUE FOREACH;
		END IF;
		
	END FOREACH ;

	-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
	IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
		COMMIT WORK;
		UPDATE STATISTICS MEDIUM FOR TABLE bdireports:tmpmovimientosmensual_vic;
		LET vsFlagEnTransaccion = 'F';
	END IF;	

	--//// COMPRAS INTERNACIONALES ////
	set isolation to dirty read;
	select count(folio_suc), sum(monto_tot) 
	into iTotalComprasInterTotal, dMontoComprasInterTotal
	from tmpmovimientosmensual where  transacc='6830' 
	and fech_alt >=dFecha1 and fech_alt <=dFecha2
	and cuentafolio in (select cuentafolio from tmpmovimientosmensual_vic where fecha_aplica  >=dFecha1 and fecha_aplica <=dFecha2 );

	--//// COMPRAS NACIONALES ////
	set isolation to dirty read;
	select count(folio_suc), sum(monto_tot) 
	into iTotalComprasEntTotal, dMontoComprasEntTotal
	from tmpmovimientosmensual where  transacc='6830' 
	and fech_alt >= dFecha1 and fech_alt <=dFecha2
	and cuentafolio not in (select cuentafolio from tmpmovimientosmensual_vic where fecha_aplica  >=dFecha1 and fecha_aplica <=dFecha2);
	
	---///////ATM CREDITO - NACIONAL///////
	set isolation to dirty read;
	select count(folio_suc), sum(monto_tot) 
	into iTotalDispAtmTotal, mSaldoDispATMtotal
	from  tmpmovimientosmensual where  transacc in ('6872','6871','6825','6824','7383','7382')
	and fech_alt >= dFecha1 and fech_alt <= dFecha2;
    
	---///////ATM CREDITO - INTERNACIONAL///////
	set isolation to dirty read;
	select count(folio_suc), sum(monto_tot) 
	into iTotalDispAtmIntTotal , dMontoAtmIntTotal
	from  tmpmovimientosmensual where  transacc in (	'6873','6826','7384')
	and fech_alt >= dFecha1 and fech_alt <= dFecha2;

	---///////ATM CREDITO - PROPIOS ///////
	set isolation to dirty read;
	select count(folio_suc), sum(monto_tot) 
	into dNumDispATMprop, mMontoDispATMproptotal
	from tmpmovimientosmensual where  transacc in ('6800','7381')
	and fech_alt >= dFecha1 and fech_alt <= dFecha2;

	--Inserta en la base de datos
	LET cCodFila = 'CEN';
	INSERT INTO bdireports:rpt_volumetria(num_producto,trimestre,id_col,mes,campo_a,campo_b,campo_c,campo_d,campo_e,campo_f,campo_g,campo_h,campo_i,campo_j)
	VALUES('6001',cTrimestre,cCodFila,iMes,iTotalComprasEntTotal,dMontoComprasEntTotal,0,0,0,0,0,0,iTotalDispAtmTotal,mSaldoDispATMtotal);

	--Se inserta en la base de datos la informacion
	LET cCodFila = 'CEI';
	INSERT INTO bdireports:rpt_volumetria(num_producto,trimestre,id_col,mes,campo_a,campo_b,campo_c,campo_d,campo_e,campo_f,campo_g,campo_h,campo_i,campo_j)
	VALUES('6001',cTrimestre,cCodFila,iMes,iTotalComprasInterTotal,dMontoComprasInterTotal,0,0,0,0,0,0,iTotalDispAtmIntTotal,dMontoAtmIntTotal);

    --Inserta en la base de datos - ATM's Propios
    UPDATE {+INDEX(rpt_volumetria idx_rpt_volumetria)}  bdireports:rpt_volumetria SET campo_i = dNumDispATMprop , campo_j = mMontoDispATMproptotal
    WHERE num_producto = '6001' AND trimestre=cTrimestre AND id_col = 'VVP' AND mes = iMes;

	
	IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames
		WHERE partnum is not null AND tabname = 'tmpmovimientosmensual' AND dbsname= 'bdireports') THEN
		DROP TABLE bdireports:tmpmovimientosmensual;
	END IF;
		
	IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames
		WHERE partnum is not null AND tabname = 'tmpmovimientosmensual_vic' AND dbsname= 'bdireports') THEN
		DROP TABLE bdireports:tmpmovimientosmensual_vic;
	END IF;

RETURN cCodret,cVarDataErr;
END PROCEDURE;