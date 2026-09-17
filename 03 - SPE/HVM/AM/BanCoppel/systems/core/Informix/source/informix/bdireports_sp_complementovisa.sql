create procedure "informix".sp_complementovisa(dFecha1 DATETIME year to fraction(5),dFecha2 DATETIME year to fraction(5),cTrimestre cHAR(5),iMes INTEGER)
returning
char (5),
char(50);

DEFINE iSqlErr          INTEGER;
DEFINE iSamErr          INTEGER;
DEFINE cVarDataErr      CHAR(100);
DEFINE cCodret          CHAR(5);
DEFINE cNumProducto     CHAR(4);
DEFINE cTransacc_suc    CHAR(4);
DEFINE dTotalDisp       DECIMAL;
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
DEFINE vsProdind CHAR (2);
DEFINE vsEsNacional CHAR (1);
DEFINE dtFechaHoraInAuth DATETIME YEAR TO FRACTION (5);

DEFINE v_snum_credito_mv 	CHAR(20);
DEFINE v_snum_credito_mc    CHAR(20);
DEFINE v_mmonto    			money(16,2);
DEFINE v_scodigo_fun 		CHAR(5);
DEFINE v_scodigo_ref 		CHAR(5);
DEFINE v_stransacc_suc 		CHAR(5);

DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER;

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

  ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN

			--VALIDA SI EXISTE LA TABLATEMPORAL DE MOVIMIENTOS
			SET ISOLATION TO DIRTY READ;
			IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames  WHERE tabname = 'tmpmovimientosmensual' AND dbsname= 'bdireports') THEN
				DROP TABLE BdiReports:TmpMovimientosMensual;
			END IF;

			--VALIDA SI EXISTE LA TABLATEMPORAL DE MOVIMIENTOS DEL TRIMESTRE

			IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames  WHERE tabname = 'tmpmovimientostrim' AND dbsname= 'bdireports') THEN
				DROP TABLE BdiReports:TmpMovimientosTrim;
			END IF;

			--VALIDA SI EXISTE LA TABLATEMPORAL DE MOVHIS Y MAECRED

			IF EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE (tabname = 'tmp_replica' AND dbsname= 'bdireports') OR (tabname = 'informix:tmp_replica' AND dbsname= 'bdireports')) THEN
				DROP TABLE bdireports:tmp_replica;
			END IF;

			-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
			IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
			END IF;

            LET cCodret=iSqlErr;
            RETURN cCodret, cVarDataErr;
        END IF;
  END EXCEPTION;

--Set debug file to "/home/informix/jydg/sp_replicainformacionvisaCREDJYDG.out";
--trace on;

LET cCodret = '000';
LET cVarDataErr = '';
LET iAnio = YEAR(dFecha1);
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
LET vsProdind = '';
LET vsEsNacional = '';
LET dtFechaHoraInAuth = CURRENT;

LET v_snum_credito_mv = '';
LET v_snum_credito_mc = '';
LET v_mmonto = 0.0;
LET v_scodigo_fun = '';
LET v_scodigo_ref = '';
LET v_stransacc_suc = '';

LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;



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

--Esta informacion solo se corre si es final de trimestre
	IF iMes = 3 OR iMes = 6 OR iMes = 9 OR iMes = 12 THEN

	/*	LET iMes1 = iMes - 2;
		LET cFecha1 = YEAR(dFecha1) || '-' || iMes1 || '-' || '01' || ' 00:00:00.0';
		LET dFechaIn = CAST (cFecha1 AS DATETIME year to fraction(5));
		LET dFechaFin = dFecha2 - Interval(1) day to day;
		LET cFecha2 = YEAR(dFecha1) || '-' || iMes || '-' || DAY(dFechaFin) || ' 23:59:59.0';
		LET dFechaFin = CAST (cFecha2 AS DATETIME year to fraction(5));*/



		--VALIDA SI EXISTE LA TABLATEMPORAL DE MOVHIS Y MAECRED

		IF EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE (tabname = 'tmp_replica' AND dbsname= 'bdireports') OR (tabname = 'informix:tmp_replica' AND dbsname= 'bdireports')) THEN
			DROP TABLE bdireports:tmp_replica;
		END IF;

		CREATE TABLE tmp_replica
		(
			codigo_Fun CHAR(5),
			codigo_Ref CHAR(5),
			transacc_Suc CHAR(5),
            descripcion CHAR(55),
            secuencia CHAR(3),
			monto MONEY(16,2),
            cuentaA CHAR(25),
            consulta CHAR(20)
		);

		CREATE INDEX idx_tmp_replica1 ON BdiReports:tmp_replica (consulta) USING BTREE ;
		CREATE INDEX idx_tmp_replica2 ON BdiReports:tmp_replica (codigo_Fun, codigo_Ref, transacc_Suc) USING BTREE ;

		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;

		SET ISOLATION TO DIRTY READ;
		FOREACH WITH HOLD
/*			SELECT num_credito,num_credito,NVL(monto,0),codigo_fun,codigo_ref,transacc_suc
            INTO v_snum_credito_mv,v_snum_credito_mc,v_mmonto,v_scodigo_fun,v_scodigo_ref,v_stransacc_suc
			FROM bdicred:sd_movhis
			WHERE empresa = '001'
			AND num_credito is not null
            			AND num_producto is not null
			AND fecha_mov >= dFecha1::DATE
		              AND fecha_mov <= dFecha2::DATE
			AND reversado = 'N'
		            --AND mc.cod_caract_2 matches 'BC*'
*/

	/*****************************************************************************************************************/
	/************************************************       JYDG    **************************************************/

         select a.codigo_fun, a.codigo_ref, b.numero, b.descripcion,
                nvl(c.secuencia,"") secuencia , sum(d.monto)monto
                ,nvl(trim(a_ccmayor)||'-'||trim(a_ccsub)||'-'||trim(a_ccsubsub)||'-'||trim(a_ccsssub)||'-'||trim(a_ccssssub)||'-'||trim(a_sector),"") 				cuentaA, consulta
         INTO v_codfun ,v_codref ,v_transacc ,v_descripcion ,v_secuencia ,v_monto ,v_cuentaA ,v_consulta
         from bdicred:sd_transfun a
            left outer join bdinteg:si_transacc b on (b.sistema='06' and b.numero=a.transacc and b.empresa ='001')
            left outer join bdinteg:si_prodtran c on (c.empresa= '001' and c.producto<>0 and c.sistema=b.sistema and c.transaccion=a.transacc and c.secuencia <>0 )
            join bdireports:Param_Repo_Visa e     on (e.codigo_fun=a.codigo_fun and e.codigo_ref=a.codigo_ref and e.valor=b.numero)
            left outer join bdicred:sd_movhis d   on (d.empresa= '001' and d.num_credito>0 and d.codigo_fun=e.codigo_fun and d.codigo_ref=e.codigo_ref
                                                      and fecha_mov between '04012009' and  '06302009' and d.reversado = 'N')
         group by 1,2,3,4,5,7,8
	/************************************************       JYDG    **************************************************/
	/*****************************************************************************************************************/

			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;


			SET LOCK MODE TO WAIT 3;
			INSERT INTO tmp_replica(codigo_Fun ,codigo_Ref ,transacc_Suc ,descripcion ,secuencia ,monto ,cuentaA ,consulta)
			VALUES(v_codfun ,v_codref ,v_transacc ,v_descripcion ,v_secuencia ,v_monto ,v_cuentaA ,v_consulta);

			LET viContadorRegistros = viContadorRegistros + 1;

			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros = 10) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
            	LET viContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;

		END FOREACH;

		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;

		--(JYDG)--CREATE INDEX idx_tmp_replica1 ON BdiReports:tmp_replica (num_credito_mv,num_credito_mc,transacc_suc);
		--(JYDG)--CREATE INDEX idx_tmp_replica2 ON BdiReports:tmp_replica (num_credito_mv,num_credito_mc,codigo_fun,codigo_ref);


		--Cargos por financiamiento

		SET ISOLATION TO DIRTY READ;
		SELECT SUM(NVL(monto,0))
		INTO mCargoPorFinTotal
		FROM BdiReports:tmp_replica
		WHERE consulta = 'CARFINANCIA' and Secuencia=1;


		--Cargos por pagos en atraso y otros


		SELECT SUM(NVL(monto,0))
		INTO mCargoOtrosTotal
		FROM BdiReports:tmp_replica
		WHERE consulta = 'CARATRASO';

		--Pagos Recibidos


		SELECT SUM(NVL(monto,0))
		INTO mPagosTotal
		FROM BdiReports:tmp_replica
		WHERE consulta = 'CARPAGREC' and Secuencia=1;

		----Debitos Miscelaneos
		SELECT SUM(NVL(monto,0))
		INTO mDebitosMisc1
		FROM BdiReports:tmp_replica
		WHERE consulta = 'CARDEBMISCE' and Secuencia=1;

		LET mDebitosMiscTotal = mDebitosMisc1 ;

		IF mDebitosMiscTotal IS NULL THEN
			LET mDebitosMiscTotal = 0;
		END IF;


	    update bdireports:rpt_creditoclasica set car_fin=mCargoPorFinTotal, car_pagatra=mCargoOtrosTotal, 
        	pag_recidos=mPagosTotal, deb_mis=mDebitosMisc1
	    where trimestre = '20092';


	END IF;

 RETURN cCodRet,cVarDataErr;

END PROCEDURE;