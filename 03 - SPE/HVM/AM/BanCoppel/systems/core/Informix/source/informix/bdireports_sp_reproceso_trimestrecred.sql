CREATE PROCEDURE "informix".sp_reproceso_trimestrecred(cTrimestre CHAR(5),iMes INTEGER,dFecha1 DATETIME year to fraction(5), dFecha2 DATETIME year to fraction(5))
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

			update statistics medium for table bdireports:tmpmovimientostrim;
		
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
	DELETE FROM  bdireports:rpt_creditoclasica where trimestre=cTrimestre ;
COMMIT WORK;

LET iMes1 = iMes - 2;
LET cFecha1 = YEAR(dFecha1) || '-' || iMes1 || '-' || '01' || ' 00:00:00.0';
LET dFechaIn = CAST (cFecha1 AS DATETIME year to fraction(5));
LET dFechaFin = dFecha2 - Interval(1) day to day;
LET cFecha2 = YEAR(dFecha1) || '-' || iMes || '-' || DAY(dFechaFin) || ' 23:59:59.0';
LET dFechaFin = CAST (cFecha2 AS DATETIME year to fraction(5));

LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;

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

--Numero de cuentas - internacionales 
/*Proporcionar el número de cuentas internacionales al final de este trimestre. Incluya las cuentas activas, inactivas o temporalmente bloqueadas. 
  *Una cuenta internacional le permite al tarjetahabiente utilizar la tarjeta en el país o territorio en que se emitió así como en todo el mundo*/


SELECT {+INDEX(bdicred:sd_maecred maesta)}
NVL (COUNT (num_credito), 0)
INTO dNumCuentasCredito
FROM bdicred:sd_maecred
WHERE empresa='001' 
AND status_cred <> 'CV'
AND fecha_apertura <= dFechaFin::DATE ;


--Numero de tarjetas con actividad en en pos

SELECT NVL(COUNT(DISTINCT numtarjeta), 0)
INTO dNumTarjActPOS
FROM BdiReports:tmpmovimientostrim
WHERE ProdInd = '02'
AND CodigoIso <> ''; -- POS

--Numero de tarjetas

SELECT NVL(COUNT (*), 0)
INTO dNumTarjetas
FROM intercard:Tarjeta
WHERE Numtarjeta matches '426807*'  --CREDITO--
AND Nombre IS NOT NULL
AND NumeroLote IS NOT NULL
AND FechaAsignacion <= dFechaFin
AND CodStatusTarjeta = 'ACT';


--Numero de transacciones NO aprobadas

SELECT NVL(COUNT(*), 0)
INTO dNumeroNoAprobadasTotal
FROM BdiReports:tmpmovimientostrim
WHERE  CodigoIso <> '00'
AND numtarjeta matches '426807*';


--Estados de cuenta
LET dFechaIn = CAST(dFechaIn as DATE);
LET dFechaFin = CAST(dFechaFin as DATE);
LET cFechaEdoCta_t = iMes1 || '-' || '20' || '-' || iAnio;
LET cFechaEdoCta = CAST (cFechaEdoCta_t AS DATE);

SET ISOLATION TO DIRTY READ;
SELECT NVL(COUNT(*), 0)
INTO dNumeroEdoCuenta1
FROM bdicred:sd_pie_edocta
WHERE fecha_emision = cFechaEdoCta
AND num_credito is not null ;

LET cFechaEdoCta_t = iMes1 + 1 || '-' || '20' || '-' || iAnio;
LET cFechaEdoCta = CAST (cFechaEdoCta_t AS DATE);


SELECT NVL(COUNT(*), 0)
INTO dNumeroEdoCuenta2
FROM bdicred:sd_pie_edocta
WHERE fecha_emision = cFechaEdoCta
AND num_credito is not null;

LET cFechaEdoCta_t = iMes1 + 2 || '-' || '20' || '-' || iAnio;
LET cFechaEdoCta = CAST (cFechaEdoCta_t AS DATE);


SELECT NVL(COUNT(*), 0)
INTO dNumeroEdoCuenta3
FROM bdicred:sd_pie_edocta
WHERE fecha_emision = cFechaEdoCta
AND num_credito is not null;

LET dNumeroEdoCuenta = dNumeroEdoCuenta1 + dNumeroEdoCuenta2 + dNumeroEdoCuenta3;

IF dNumeroEdoCuenta IS NULL THEN
	LET dNumeroEdoCuenta = 0;
END IF;

--Limite de credito total

SELECT SUM(NVL(monto_otorgado,0))
INTO dLimiteCredito
FROM bdicred:sd_maesdoscont a, bdicred:sd_maecredcont b
WHERE monto_otorgado > 0
AND a.empresa = b.empresa
AND a.num_credito = b.num_credito
AND b.status_cred <> 'CV'
AND a.fecha = dFechaFin
AND b.fecha = dFechaFin;

IF dLimiteCredito IS NULL THEN
	LET dLimiteCredito = 0;
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
) FRAGMENT BY ROUND ROBIN IN datos00, datos01, datos02
extent size 12400 next size 32
LOCK MODE ROW;

CREATE INDEX idx_tmp_replica1 ON BdiReports:tmp_replica (consulta) USING BTREE ;
CREATE INDEX idx_tmp_replica2 ON BdiReports:tmp_replica (codigo_Fun, codigo_Ref, transacc_Suc) USING BTREE ;

LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;
 
SET ISOLATION TO DIRTY READ;
FOREACH WITH HOLD

/************************       JYDG    **************************/ 
 select a.codigo_fun, a.codigo_ref, b.numero, b.descripcion, 
		nvl(c.secuencia,"") secuencia , sum(d.monto)monto
		,nvl(trim(a_ccmayor)||'-'||trim(a_ccsub)||'-'||trim(a_ccsubsub)||'-'||trim(a_ccsssub)||'-'||trim(a_ccssssub)||'-'||trim(a_sector),"") cuentaA, 
		consulta
 INTO v_codfun ,v_codref ,v_transacc ,v_descripcion ,v_secuencia ,v_monto ,v_cuentaA ,v_consulta 
 from bdicred:sd_transfun a
	left outer join bdinteg:si_transacc b on (b.sistema='06' and b.numero=a.transacc and b.empresa ='001')
	left outer join bdinteg:si_prodtran c on (c.empresa= '001' and c.producto<>0 and c.sistema=b.sistema and c.transaccion=a.transacc and c.secuencia <>0 )
	join bdireports:Param_Repo_Visa e     on (e.codigo_fun=a.codigo_fun and e.codigo_ref=a.codigo_ref and b.numero=e.valor ) 
	left outer join bdicred:sd_movhis d   on (d.empresa= '001' and d.num_credito>0 and d.codigo_fun=e.codigo_fun and d.codigo_ref=e.codigo_ref 
											  and fecha_mov between DATE(dFechaIn) and DATE(dFechaFin) and d.reversado = 'N')
 group by 1,2,3,4,5,7,8
/************************       JYDG    **************************/ 
	
	
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
	IF (viContadorRegistros = 50) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
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

select  sum (saldo_fin_de_dia)
INTO mCargoOtrosTotal
from bdicont:co_histsdodias s 
WHERE s.empresa = '001'
AND s.ccmayor='5105' 
AND s.ccsub = '61'
AND s.ccsubsub ='01' 
AND s.ccssubsub='01'
AND s.ccsssubsub='02' 
AND s.sector='32'  
and s.ciudad is not null 
AND s.sucursal is not null
and s.mes_dia = date(dFechaFin);

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


--Manuel Osuna V.

SELECT sum(NVL(sdo_cap_insoluto,0))
INTO mCredOtros  
FROM bdicred:sd_maecred mae,bdicred:sd_maesdos_vendida ven
WHERE mae.empresa = '001' and num_producto = '6001'
AND ven.empresa = '001'
AND mae.num_credito = ven.num_credito 
AND mae.status_cred = 'CV';


---Obtener numero y saldos de las cuentas cuentas corrientes morosas

SELECT NVL(mto_fin_ven_trasp,0),SUM(CASE WHEN NVL(sdo_cap_insoluto, 0) < 0 THEN 0 ELSE sdo_cap_insoluto END), NVL(COUNT(*),0)
INTO iPeriodos,dNumctas_men30, dSdonumctas_men30
FROM  bdicred: sd_maesdoscont 
WHERE empresa='001' and fecha = dFechaFin AND num_credito is not null and mto_fin_ven_trasp = 0
GROUP BY 1;

SELECT NVL(mto_fin_ven_trasp,0),SUM(CASE WHEN NVL(sdo_cap_insoluto, 0) < 0 THEN 0 ELSE sdo_cap_insoluto END), NVL(COUNT(*),0)
INTO iPeriodos, dNumctas_may30, dSdonumctas_may30
FROM  bdicred: sd_maesdoscont a
WHERE empresa='001' and fecha = dFechaFin AND num_credito is not null and mto_fin_ven_trasp = 1
GROUP BY 1;

SELECT NVL(mto_fin_ven_trasp,0),SUM(CASE WHEN NVL(sdo_cap_insoluto, 0) < 0 THEN 0 ELSE sdo_cap_insoluto END), NVL(COUNT(*),0)
INTO iPeriodos, dNumctas_may60, dSdonumctas_may60
FROM  bdicred: sd_maesdoscont a
WHERE empresa='001' and fecha = dFechaFin AND num_credito is not null and mto_fin_ven_trasp = 2
GROUP BY 1;

SELECT NVL(mto_fin_ven_trasp,0),SUM(CASE WHEN NVL(sdo_cap_insoluto, 0) < 0 THEN 0 ELSE sdo_cap_insoluto END), NVL(COUNT(*),0)
INTO iPeriodos, dNumctas_may90, dSdonumctas_may90
FROM  bdicred: sd_maesdoscont a
WHERE empresa='001' and fecha = dFechaFin AND num_credito is not null and mto_fin_ven_trasp = 3
GROUP BY 1;

-- se deja el periodo 5 copmo fijo para saldos de las cuentas cuentas corrientes morosas con 4 ó mas periodos  -- casanova edeza hector

SELECT 5, SUM(CASE WHEN NVL(sdo_cap_insoluto,0) < 0 THEN 0 ELSE sdo_cap_insoluto END), NVL(COUNT(*),0)
INTO iPeriodos, dNumctas_may120, dSdonumctas_may120
FROM  bdicred: sd_maesdoscont a
WHERE empresa='001' and fecha = dFechaFin AND num_credito is not null and mto_fin_ven_trasp >= 4
GROUP BY 1;

		
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
	'6001',
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



--VALIDA SI EXISTE LA TABLATEMPORAL DE MOVHIS Y MAECRED

IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames
WHERE partnum is not null AND tabname = 'tmp_replica' AND dbsname= 'bdireports') THEN
DROP TABLE bdireports:tmp_replica;
END IF;

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

update statistics medium for table bdireports:tmpmovimientostrim;

RETURN cCodret,cVarDataErr;
END PROCEDURE;