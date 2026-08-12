CREATE PROCEDURE "informix".sp_reproceso_volumetriadeb(cTrimestre CHAR(5),iMes INTEGER,dFecha1 date, dFecha2 date)
returning
char (5),
char(100);

DEFINE iSqlErr          INTEGER;
DEFINE iSamErr          INTEGER;
DEFINE cVarDataErr      CHAR(100);
DEFINE cCodret          CHAR(5);
DEFINE cProducto        CHAR(4);
DEFINE cTransacc        CHAR(4);
DEFINE cFecha           CHAR(2);
DEFINE iTotalDisp    DECIMAL;
DEFINE mSaldoDisp   MONEY(14,2);
DEFINE iTotalDispATM1    DECIMAL;
DEFINE mSaldoDispATM1   MONEY(14,2);
DEFINE iTotalDispATM2    DECIMAL;
DEFINE mSaldoDispATM2   MONEY(14,2);
DEFINE iTotalDispATMtotal    DECIMAL;
DEFINE mSaldoDispATMtotal    MONEY(14,2);
DEFINE iMes1            INTEGER;
DEFINE iAnio            INTEGER;
DEFINE iTotalComprasEnt1 DECIMAL;
DEFINE dMontoComprasEnt1 MONEY(14,2);
DEFINE iTotalComprasEnt2 DECIMAL;
DEFINE dMontoComprasEnt2 MONEY(14,2);
DEFINE iTotalComprasEntTotal DECIMAL;
DEFINE dMontoComprasEntTotal MONEY(14,2);
DEFINE iTotalDispAtmInt1 DECIMAL;
DEFINE dMontoAtmInt1     MONEY(14,2);
DEFINE iTotalDispAtmInt2 DECIMAL;
DEFINE dMontoAtmInt2     MONEY(14,2);
DEFINE iTotalDispAtmIntTotal DECIMAL;
DEFINE dMontoAtmIntTotal     MONEY(14,2);
DEFINE dNumDispATMprop  DECIMAL;
DEFINE mMontoDispATMproptotal MONEY(14,2);
DEFINE dTotalCuentasDeb DECIMAL;
DEFINE dNumeroTarjetas  DECIMAL;
DEFINE dTotalCuentasAct DECIMAL;
DEFINE dTotalTarjPOS    DECIMAL;
DEFINE dTotalTarjATM    DECIMAL;
DEFINE dTotalTransRechPOS DECIMAL;
DEFINE dTotalTarjRech   DECIMAL;
DEFINE dTotalRechOtras  DECIMAL;
DEFINE dTarjRechATM     DECIMAL;
DEFINE dTotalRechATM    DECIMAL;
DEFINE dTotalOtrasATM   DECIMAL;
DEFINE cCodFila         CHAR(8);
DEFINE dFechaIn         DATETIME year to fraction(5);
DEFINE dFechaFin        DATETIME year to fraction(5);
DEFINE cFecha1          CHAR(50);
DEFINE cFecha2          CHAR(50);
DEFINE cProd            CHAR(2);
DEFINE cNacional        CHAR(1);
DEFINE cCodtran         CHAR(2);
DEFINE cFormato         CHAR(4);
DEFINE cTrancajeropropio CHAR(1);
DEFINE iMesFecha        INTEGER;
DEFINE dTotal           DECIMAL;
DEFINE dSaldo           DECIMAL;
DEFINE iTotalComprasInter1 DECIMAL;
DEFINE dMontoComprasInter1 DECIMAL;
DEFINE iTotalComprasInter2 DECIMAL;
DEFINE dMontoComprasInter2 DECIMAL;
DEFINE iTotalComprasInterTotal DECIMAL;
DEFINE dMontoComprasInterTotal DECIMAL;

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

DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER;

DEFINE vsCuentadeb char(25);
DEFINE vsTarjeta char(16);
DEFINE vsFoliosuc char(16);
DEFINE vsMonto_tot money(16,2);
DEFINE vsFech_alt date;
DEFINE vsTransacc char(4);
DEFINE vsReferencia char(50);
DEFINE vsCuentafolio char(41);

DEFINE vconsmovhis      CHAR(10);
DEFINE vconsmovhisold   CHAR(10);
DEFINE vconsmovhisold2  CHAR(10);




  ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN

			LET cCodret=iSqlErr;
            RETURN cCodret, cVarDataErr;
        END IF;
  END EXCEPTION;

--Set debug file to "/informixuc7/perifericos/visadeb.txt";
--trace on;

LET cCodret = '000';
LET cVarDataErr = '';
LET iAnio = 0;
LET iTotalDispATM1 = 0;
LET mSaldoDispATM1 = 0;
LET iTotalComprasEnt1 = 0;
LET dMontoComprasEnt1 = 0;
LET iTotalDispAtmInt1 = 0;
LET dMontoAtmInt1 = 0;
LET iTotalComprasInter1 = 0;
LET dMontoComprasInter1 = 0;
LET iTotalDispATM2 = 0;
LET mSaldoDispATM2 = 0;
LET iTotalComprasEnt2 = 0;
LET dMontoComprasEnt2 = 0;
LET iTotalDispAtmInt2 = 0;
LET dMontoAtmInt2 = 0;
LET iTotalComprasInter2 = 0;
LET dMontoComprasInter2 = 0;
LET iTotalDispAtmTotal = 0;
LET mSaldoDispATMtotal = 0;
LET iTotalComprasEntTotal = 0;
LET dMontoComprasEntTotal = 0;
LET iTotalComprasInterTotal = 0;
LET dMontoComprasInterTotal = 0;
LET iTotalDispAtmIntTotal = 0;
LET dMontoAtmIntTotal = 0;
LET dNumDispATMprop = 0.0;
LET mMontoDispATMproptotal = 0.0;


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

LET vsCuentadeb ='';
LET  vsTarjeta ='';
LET  vsFoliosuc ='';
LET  vsMonto_tot =0.0;
LET  vsFech_alt = today;
LET  vsTransacc ='';
LET  vsReferencia ='';
LET  vsCuentafolio ='';
 

LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;

BEGIN WORK;
	DELETE {+INDEX(rpt_volumetria idx_rpt_volumetria)} FROM  bdireports:rpt_volumetria where trimestre=cTrimestre and  mes=iMes and num_producto='2000';
COMMIT WORK;

	 SELECT valor
      INTO vconsmovhis
      FROM bdicheq:sc_param
     WHERE empresa = '001'
       AND codparam = 'fechcon_movhis';
       
    SELECT valor
      INTO vconsmovhisold
      FROM bdicheq:sc_param
     WHERE empresa = '001'
       AND codparam = 'FechIniCon_movhis_ol';
       
    SELECT valor
      INTO vconsmovhisold2
      FROM bdicheq:sc_param
     WHERE empresa = '001'
       AND codparam = 'FechaIniMovhisOld2';


	IF (dFecha1 >=  vconsmovhis::date) THEN
				--INFORMACION DE DEBITO
				--Disposiciones de efectivo-Propio nacional número y monto

				SET ISOLATION TO dirty read;
				SELECT  --{+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
				NVL(COUNT(*),0), SUM(NVL(monto_tot,0))
				INTO iTotalDisp,mSaldoDisp
				FROM bdicheq:sc_movhis
				WHERE empresa='001'
				AND cuenta <> ''
				AND fech_alt >= dFecha1
				AND fech_alt <= dFecha2
				AND cancelad <> 'S'
				AND transacc = '0223'
				AND producto='2000'
				GROUP BY producto;
	END IF;
	
	IF (dFecha1 >= vconsmovhisold::date and dFecha2 < vconsmovhis::date) THEN
				--INFORMACION DE DEBITO
				--Disposiciones de efectivo-Propio nacional número y monto

				SET ISOLATION TO dirty read;
				SELECT  --{+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
				NVL(COUNT(*),0), SUM(NVL(monto_tot,0))
				INTO iTotalDisp,mSaldoDisp
				FROM bdicheq:sc_movhis_old
				WHERE empresa='001'
				AND cuenta <> ''
				AND fech_alt >= dFecha1
				AND fech_alt <= dFecha2
				AND cancelad <> 'S'
				AND transacc = '0223'
				AND producto='2000'
				GROUP BY producto;
	END IF;
	
	IF (dFecha1 >= vconsmovhisold2::date and dFecha2 < vconsmovhisold::date) THEN	
				--INFORMACION DE DEBITO
				--Disposiciones de efectivo-Propio nacional número y monto

				SET ISOLATION TO dirty read;
				SELECT  --{+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
				NVL(COUNT(*),0), SUM(NVL(monto_tot,0))
				INTO iTotalDisp,mSaldoDisp
				FROM bdicheq:sc_movhis_old2
				WHERE empresa='001'
				AND cuenta <> ''
				AND fech_alt >= dFecha1
				AND fech_alt <= dFecha2
				AND cancelad <> 'S'
				AND transacc = '0223'
				AND producto='2000'
				GROUP BY producto;
	END IF;
	
	
	IF (dFecha1 < vconsmovhisold2::date) THEN
				--INFORMACION DE DEBITO
				--Disposiciones de efectivo-Propio nacional número y monto

				SET ISOLATION TO dirty read;
				SELECT  --{+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
				NVL(COUNT(*),0), SUM(NVL(monto_tot,0))
				INTO iTotalDisp,mSaldoDisp
				FROM bdicheq:sc_movhis_old3
				WHERE empresa='001'
				AND cuenta <> ''
				AND fech_alt >= dFecha1
				AND fech_alt <= dFecha2
				AND cancelad <> 'S'
				AND transacc = '0223'
				AND producto='2000'
				GROUP BY producto;
	END IF;
	
	
	IF iTotalDisp IS NULL OR mSaldoDisp IS NULL THEN
		LET iTotalDisp = 0;
		LET mSaldoDisp = 0;
	END IF

	--Inserta en la base de datos

	LET cCodFila = 'VVP';
	LET cProducto = '2000';

	INSERT INTO bdireports:rpt_volumetria(num_producto,trimestre,id_col,mes,campo_a,campo_b,campo_c,campo_d,campo_e,campo_f,campo_g,campo_h,campo_i,campo_j)
	VALUES(cProducto,cTrimestre,cCodFila,iMes,0,0,0,0,0,0,iTotalDisp,mSaldoDisp,0,0);
	

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
	CREATE INDEX idx_TmpMovimientosmensual ON bdireports:tmpmovimientosmensual (cuentafolio) in datos03;
	COMMIT WORK;
	BEGIN WORK;
	CREATE INDEX idx_TmpMovimientosmensual2 ON bdireports:tmpmovimientosmensual (transacc, fech_alt) in datos03;
	COMMIT WORK;
	
	UPDATE STATISTICS MEDIUM FOR TABLE bdireports:tmpmovimientosmensual;
	
		--VALIDA SI EXISTE LA TABLATEMPORAL DE MOVIMIENTOS (VID)
	SET ISOLATION TO DIRTY READ;
	
	IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames
		WHERE partnum is not null AND tabname = 'tmpmovimientosmensual_vid' AND dbsname= 'bdireports') THEN
		DROP TABLE bdireports:tmpmovimientosmensual_vid;
	END IF;
	
		CREATE TABLE bdireports:tmpmovimientosmensual_vid
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
		CREATE INDEX idx_TmpMovimientosmensual_vid ON bdireports:tmpmovimientosmensual_vid (cuentafolio) in datos03;
	COMMIT WORK;
	BEGIN WORK;
		CREATE INDEX idx_TmpMovimientosmensual_vid2 ON bdireports:tmpmovimientosmensual_vid (fecha_aplica) in datos03;
	COMMIT WORK;
	
	UPDATE STATISTICS MEDIUM FOR TABLE bdireports:tmpmovimientosmensual_vid;
	
	--///////////////// CARGA DE MOVIMIENTOS DE LIBERACION DEL MES /////////////////////////////
	
	IF (dFecha1 >=  vconsmovhis::date) THEN
	
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
				
		SET ISOLATION TO DIRTY READ;
		FOREACH WITH HOLD	
				SELECT --{+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
				cuenta,num_tarjeta,folio_suc,monto_tot,fech_alt,transacc,referencia ,trim(cuenta)||trim(folio_suc)
				INTO vsCuentadeb, vsTarjeta,vsFoliosuc,vsMonto_tot, vsFech_alt,vsTransacc,vsReferencia,vsCuentafolio
				FROM bdicheq:sc_movhis WHERE empresa='001'
				AND cuenta <> ''
				AND fech_alt >= dFecha1
				AND fech_alt <= dFecha2
				AND cancelad <> 'S'
				AND transacc IN ('0830','0818','0817','0872','0871','0706','0756','0808','0825','0824','0819','0873','0826','0800','0807')
				AND sucursal='9290'
			
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;

			SET LOCK  MODE TO WAIT 3;
			INSERT INTO bdireports:tmpmovimientosmensual ( cuenta,num_tarjeta,folio_suc,monto_tot,fech_alt,transacc,referencia ,cuentafolio )
			VALUES (vsCuentadeb, vsTarjeta,vsFoliosuc,vsMonto_tot, vsFech_alt,vsTransacc,vsReferencia,vsCuentafolio);

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
	
	END IF;
	
	
	IF (dFecha1 >= vconsmovhisold::date and dFecha2 < vconsmovhis::date) THEN
	
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
				
		SET ISOLATION TO DIRTY READ;
		FOREACH WITH HOLD	
				SELECT --{+INDEX(bdicheq:sc_movhis_old movhis1)}
				cuenta,num_tarjeta,folio_suc,monto_tot,fech_alt,transacc,referencia ,trim(cuenta)||trim(folio_suc)
				INTO vsCuentadeb, vsTarjeta,vsFoliosuc,vsMonto_tot, vsFech_alt,vsTransacc,vsReferencia,vsCuentafolio
				FROM bdicheq:sc_movhis_old WHERE empresa='001'
				AND cuenta <> ''
				AND fech_alt >= dFecha1
				AND fech_alt <= dFecha2
				AND cancelad <> 'S'
				AND transacc IN ('0830','0818','0817','0872','0871','0706','0756','0808','0825','0824','0819','0873','0826','0800','0807')
				AND sucursal='9290'
			
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;

			SET LOCK  MODE TO WAIT 3;
			INSERT INTO bdireports:tmpmovimientosmensual ( cuenta,num_tarjeta,folio_suc,monto_tot,fech_alt,transacc,referencia ,cuentafolio )
			VALUES (vsCuentadeb, vsTarjeta,vsFoliosuc,vsMonto_tot, vsFech_alt,vsTransacc,vsReferencia,vsCuentafolio);

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
	
	END IF;	
	
	IF (dFecha1 >= vconsmovhisold2::date and dFecha2 < vconsmovhisold::date) THEN
	
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
				
		SET ISOLATION TO DIRTY READ;
		FOREACH WITH HOLD	
				SELECT --{+INDEX(bdicheq:sc_movhis_old2 movhis1_old2)}
				cuenta,num_tarjeta,folio_suc,monto_tot,fech_alt,transacc,referencia ,trim(cuenta)||trim(folio_suc)
				INTO vsCuentadeb, vsTarjeta,vsFoliosuc,vsMonto_tot, vsFech_alt,vsTransacc,vsReferencia,vsCuentafolio
				FROM bdicheq:sc_movhis_old2 WHERE empresa='001'
				AND cuenta <> ''
				AND fech_alt >= dFecha1
				AND fech_alt <= dFecha2
				AND cancelad <> 'S'
				AND transacc IN ('0830','0818','0817','0872','0871','0706','0756','0808','0825','0824','0819','0873','0826','0800','0807')
				AND sucursal='9290'
			
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;

			SET LOCK  MODE TO WAIT 3;
			INSERT INTO bdireports:tmpmovimientosmensual ( cuenta,num_tarjeta,folio_suc,monto_tot,fech_alt,transacc,referencia ,cuentafolio )
			VALUES (vsCuentadeb, vsTarjeta,vsFoliosuc,vsMonto_tot, vsFech_alt,vsTransacc,vsReferencia,vsCuentafolio);

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
	
	END IF;	
	
	
	IF (dFecha1 < vconsmovhisold2::date) THEN
	
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
				
		SET ISOLATION TO DIRTY READ;
		FOREACH WITH HOLD	
				SELECT --{+INDEX(bdicheq:sc_movhis_old3 movhis1_old3)}
				cuenta,num_tarjeta,folio_suc,monto_tot,fech_alt,transacc,referencia ,trim(cuenta)||trim(folio_suc)
				INTO vsCuentadeb, vsTarjeta,vsFoliosuc,vsMonto_tot, vsFech_alt,vsTransacc,vsReferencia,vsCuentafolio
				FROM bdicheq:sc_movhis_old3 WHERE empresa='001'
				AND cuenta <> ''
				AND fech_alt >= dFecha1
				AND fech_alt <= dFecha2
				AND cancelad <> 'S'
				AND transacc IN ('0830','0818','0817','0872','0871','0706','0756','0808','0825','0824','0819','0873','0826','0800','0807')
				AND sucursal='9290'
			
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;

			SET LOCK  MODE TO WAIT 3;
			INSERT INTO bdireports:tmpmovimientosmensual ( cuenta,num_tarjeta,folio_suc,monto_tot,fech_alt,transacc,referencia ,cuentafolio )
			VALUES (vsCuentadeb, vsTarjeta,vsFoliosuc,vsMonto_tot, vsFech_alt,vsTransacc,vsReferencia,vsCuentafolio);

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
	
	END IF;	
	
	--///////////////// CARGA DE MOVIMIENTOS INTERNACIONALES DE BDITARJETA (VID) DEL MES /////////////////////////////
	
	LET vsCuentadeb ='';
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
		select {+INDEX(bditarjeta:td_conposvid idx_concvid), (bdicheq:sc_tarjeta ix_tarjeta2)} 
		b.cuenta, a.cuenta, a.folio_mov,a.monto,a.fecha_aplica,a.tran_central,a.referencia ,trim(b.cuenta)||trim(a.folio_mov)
		into vsCuentadeb, vsTarjeta,vsFoliosuc,vsMonto_tot, vsFech_alt,vsTransacc,vsReferencia,vsCuentafolio
		from bditarjeta:td_conposvid a, bdicheq:sc_tarjeta b where a.empresa='001' 
        and (a.bandera_proceso ='C' or a.bandera_proceso ='A')
		and a.fecha_aplica >= dFecha1
		and a.fecha_aplica <= dFecha2
		and a.tran_central in ('0801')
        and b.empresa = a.empresa
		and b.num_tarjeta = a.cuenta
	
		--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (vsFlagEnTransaccion = 'F') THEN
			 BEGIN WORK;
			 LET vsFlagEnTransaccion = 'V';
		END IF;

		SET LOCK  MODE TO WAIT 3;
		INSERT INTO bdireports:tmpmovimientosmensual_vid ( cuenta,num_tarjeta,folio_suc,monto_tot,fecha_aplica,transacc,referencia ,cuentafolio )
		VALUES (vsCuentadeb, vsTarjeta,vsFoliosuc,vsMonto_tot, vsFech_alt,vsTransacc,vsReferencia,vsCuentafolio);

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
		UPDATE STATISTICS MEDIUM FOR TABLE bdireports:tmpmovimientosmensual_vid;
		LET vsFlagEnTransaccion = 'F';
	END IF;	

	--//// COMPRAS INTERNACIONALES /////
	set isolation to dirty read;
	select count(folio_suc), sum(monto_tot) 
	into iTotalComprasInterTotal, dMontoComprasInterTotal
	from tmpmovimientosmensual where transacc='0830'
	and fech_alt >=dFecha1 and fech_alt <=dFecha2
	and cuentafolio in (select cuentafolio from tmpmovimientosmensual_vid where fecha_aplica  >=dFecha1 and fecha_aplica <=dFecha2 );

	--///// COMPRAS NACIONALES /////
	set isolation to dirty read;
	select count(folio_suc), sum(monto_tot) 
	into iTotalComprasEntTotal, dMontoComprasEntTotal
	from tmpmovimientosmensual where transacc='0830'
	and fech_alt >=dFecha1 and fech_alt <=dFecha2
	and cuentafolio not in (select cuentafolio from tmpmovimientosmensual_vid where fecha_aplica  >=dFecha1 and fecha_aplica <=dFecha2);

	
	---///////ATM DEBITO - NACIONAL /////////
	set isolation to dirty read;
	select  count(folio_suc), sum(monto_tot) 
	into iTotalDispAtmTotal, mSaldoDispATMtotal
	from tmpmovimientosmensual where transacc in ('0818','0817','0872','0871','0706','0756','0808','0825','0824')
	and fech_alt >=dFecha1 and fech_alt <=dFecha2;

	 ---///////ATM DEBITO - INTERNACIONAL  /////////
	 set isolation to dirty read;
	select  count(folio_suc), sum(monto_tot) 
	into iTotalDispAtmIntTotal , dMontoAtmIntTotal
	from tmpmovimientosmensual where transacc in ('0819','0873','0826')
	and fech_alt >=dFecha1 and fech_alt <=dFecha2;

	---///////ATM DEBITO - PROPIOS /////////
	set isolation to dirty read;
	select   count(folio_suc), sum(monto_tot) 
	into dNumDispATMprop, mMontoDispATMproptotal
	from  tmpmovimientosmensual where transacc in ('0800','0807')
	and fech_alt >=dFecha1 and fech_alt <=dFecha2;
	
	--Inserta en la base de datos
	LET cCodFila = 'CEN';
	INSERT INTO bdireports:rpt_volumetria(num_producto,trimestre,id_col,mes,campo_a,campo_b,campo_c,campo_d,campo_e,campo_f,campo_g,campo_h,campo_i,campo_j)
	VALUES('2000',cTrimestre,cCodFila,iMes,iTotalComprasEntTotal,dMontoComprasEntTotal,0,0,0,0,0,0,iTotalDispAtmTotal,mSaldoDispATMtotal);

	--Se inserta en la base de datos la informacion
	LET cCodFila = 'CEI';
	INSERT INTO bdireports:rpt_volumetria(num_producto,trimestre,id_col,mes,campo_a,campo_b,campo_c,campo_d,campo_e,campo_f,campo_g,campo_h,campo_i,campo_j)
	VALUES('2000',cTrimestre,cCodFila,iMes,iTotalComprasInterTotal,dMontoComprasInterTotal,0,0,0,0,0,0,iTotalDispAtmIntTotal,dMontoAtmIntTotal);

    --Inserta en la base de datos - ATM's Propios
    UPDATE {+INDEX(rpt_volumetria idx_rpt_volumetria)} bdireports:rpt_volumetria SET campo_i = dNumDispATMprop , campo_j = mMontoDispATMproptotal
    WHERE num_producto = '2000' AND trimestre=cTrimestre AND id_col = 'VVP' AND mes = iMes;
	
	
	IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames
		WHERE partnum is not null AND tabname = 'tmpmovimientosmensual' AND dbsname= 'bdireports') THEN
		DROP TABLE bdireports:tmpmovimientosmensual;
	END IF;
		
	IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames
		WHERE partnum is not null AND tabname = 'tmpmovimientosmensual_vid' AND dbsname= 'bdireports') THEN
		DROP TABLE bdireports:tmpmovimientosmensual_vid;
	END IF;
	
RETURN cCodret,cVarDataErr;
END PROCEDURE;