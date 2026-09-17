CREATE PROCEDURE "informix".sp_reproceso_trimestredeb(cTrimestre CHAR(5),iMes INTEGER,dFecha1 DATETIME year to fraction(5) , dFecha2 DATETIME year to fraction(5))
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
DEFINE vsMovreversado char(1);

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
DEFINE vNum_ofi         INTEGER;




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

--Set debug file to "/informixuc7/perifericos/visadeb.txt";
--trace on;

LET cCodret = '000';
LET cVarDataErr = '';
LET iAnio = YEAR(dFecha1);
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
LET vsMovreversado='';

LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;

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

   --//// Obtiene el número de oficinas (sucursales) , llena la tabla de rpt_miembroprincipal///

 BEGIN WORK;
	DELETE FROM  bdireports:rpt_miembroprincipal where trimestre=cTrimestre;
COMMIT WORK;

select count(a.sucursal) INTO vNum_ofi
from bdinteg:si_sucursales a, intercard:sucursal b
where empresa='001'
AND a.sucursal =substr (b.clave_sucursal,2,4)
AND b.enoperacion <> 'F';

INSERT INTO bdireports:rpt_miembroprincipal(linea_ident,trimestre,num_identi,cod_pais,num_ofi,num_map,num_sucmap,num_atmplus,num_atmvisa,seg_rrcpcvisaemp,seg_rrcpc,prog_visaprem,
					ser_conse,mes1_porcpar,mes2_porcpar,mes3_porcpar,mes1_porcparcom,mes2_porcparcom,mes3_porcparcom)
VALUES('MI',cTrimestre,'10061189','484',vNum_ofi,0,0,0,0,0,0,0,0,100,100,100,0,0,0);

BEGIN WORK;
	DELETE FROM  bdireports:rpt_visaelectron where trimestre=cTrimestre ;
COMMIT WORK;

LET iMes1 = iMes - 2;
LET cFecha1 = YEAR(dFecha1)|| '-' || iMes1 || '-' || '01' || ' 00:00:00.0';
LET dFechaIn = CAST (cFecha1 AS DATETIME year to fraction(5));
LET dFechaFin = dFecha2 - Interval(1) day to day;
LET cFecha2 = YEAR(dFecha1) || '-' || iMes || '-' || DAY(dFechaFin) || ' 23:59:59.0';
LET dFechaFin = CAST(cFecha2 AS DATETIME year to fraction(5));


LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;
FOREACH WITH HOLD 
	SELECT {+INDEX(Intercard:Movimiento idx_fechahorainauth)}
	NumTarjeta, CodigoIso, Prodind,codtran,movreversado
	INTO vsNumTarjeta, vsCodigoIso, vsProdind, vsCodtran, vsMovreversado
	FROM Intercard:Movimiento WHERE FechaHoraInAuth BETWEEN dFechaIn AND dFechaFin
	AND Numtarjeta matches '400819*'  --DEBITO--
	UNION
	SELECT {+INDEX(Intercard:movimientoHistorico idx_fechahorainauth)}
	NumTarjeta, CodigoIso, Prodind,codtran,movreversado
	FROM Intercard:movimientoHistorico WHERE  FechaHoraInAuth BETWEEN dFechaIn AND dFechaFin
	AND Numtarjeta matches '400819*'  --DEBITO--
	

	--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
	IF (vsFlagEnTransaccion = 'F') THEN
		 BEGIN WORK;
		 LET vsFlagEnTransaccion = 'V';
	END IF;

	SET LOCK MODE TO WAIT 3;
	INSERT INTO BdiReports:tmpmovimientostrim ( NumTarjeta, CodigoIso, Prodind,codtran,movreversado)
			VALUES (vsNumTarjeta, vsCodigoIso, vsProdind,vsCodtran, vsMovreversado);

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

select {+INDEX(bdicheq:sc_maechq ix174_4), (bdicheq:sc_maenoc idx_maenoc1)} 
count(a.cuenta) 
into dTotalCuentasDeb	
from bdicheq:sc_maechq a, bdicheq:sc_maenoc b where a.empresa='001' 
and a.status_cta <> '2'
and b.empresa = a.empresa
and b.cuenta = a.cuenta
and b.fecha_alta <= dFechaFin::date;

--Numero de Tarjetas
SET ISOLATION TO DIRTY READ;
SELECT NVL(COUNT (*), 0)
INTO dNumeroTarjetas
FROM intercard:Tarjeta
WHERE Numtarjeta matches '400819*'  --DEBITO--
AND Nombre IS NOT NULL
AND NumeroLote IS NOT NULL
AND FechaAsignacion <= dFechaFin
AND CodStatusTarjeta = 'ACT';

--Número de cuentas activas - durante el trimestre
/*Proporcionar el número de cuentas activas con una o más compras o disposiciones de efectivo durante el trimestre. 
   Por ejemplo, una tarjeta de débito que está conectada a una cuenta de cheque que ha tenido actividad durante el trimestre.*/

SELECT {+INDEX(bdireports:tmpmovimientostrim idx_tmpmovimientostrim_02),(bdicheq:sc_tarjeta ix_tarjeta2)} 
count(b.cuenta)
into dTotalCuentasAct 
FROM tmpmovimientostrim a, bdicheq:sc_tarjeta b 
WHERE codigoiso='00'
AND a.codtran <> '31'
AND a.movreversado='F'
AND b.empresa='001'
AND b.num_tarjeta=a.numtarjeta;

--Numero de tarjetas con actividad en en pos
SELECT NVL(COUNT(DISTINCT numtarjeta), 0)
INTO dTotalTarjPOS
FROM BdiReports:tmpmovimientostrim
WHERE ProdInd = '02'
AND CodigoIso <> ''; -- POS

--Numero de tarjetas con actividad en ATM
SELECT NVL(COUNT(DISTINCT numtarjeta), 0)
INTO dTotalTarjATM
FROM BdiReports:tmpmovimientostrim
WHERE ProdInd = '01'
AND CodigoIso <> ''; -- ATM

--TRANSACCIONES RECHAZADAS POR FONDOS INSUFICIENTES POS
SELECT NVL(COUNT(*), 0)
INTO dTotalTransRechPOS
FROM BdiReports:tmpmovimientostrim
WHERE ProdInd = '02' -- POS
AND CodigoIso = '51';

--TRANSACCIONES RECHAZADAS POR RECOGER TARJETA
SELECT NVL(COUNT(*), 0)
INTO dTotalTarjRech
FROM BdiReports:tmpmovimientostrim
WHERE ProdInd = '02' -- POS
AND ( ( codigoiso = '04' ) OR ( codigoiso = '07' )
OR ( ( codigoiso >= '33' ) AND ( codigoiso <= '38' ) )
OR ( codigoiso = '41' )
OR ( codigoiso = '43' ) OR ( codigoiso = '67' ) );

--TRANSACCIONES RECHAZADAS POR OTRAS RAZONES POS
SELECT NVL(COUNT(*), 0)
INTO dTotalRechOtras
FROM BdiReports:tmpmovimientostrim
WHERE ProdInd = '02' -- POS
AND ( codigoiso <> '00' ) AND ( codigoiso <> '53' ) AND ( codigoiso <> '51' )
AND  ( codigoiso <> '04' ) AND ( codigoiso <> '07' ) AND ( codigoiso <> '41' )
AND ( codigoiso <> '43' ) AND ( codigoiso <> '67' )
AND ( ( codigoiso < '33' ) OR ( codigoiso > '38' ) ) ;

--TRANSACCIONES RECHAZADAS POR FONDOS INSUFICIENTES ATM
SELECT NVL(COUNT(*), 0)
INTO dTarjRechATM
FROM BdiReports:tmpmovimientostrim
WHERE ProdInd = '01' -- ATM
AND CodigoISO = '51';

--TRANSACCIONES RECHAZADAS POR RECOGER TARJETA ATM
SELECT NVL(COUNT(*), 0)
INTO dTotalRechATM
FROM BdiReports:tmpmovimientostrim
WHERE ProdInd = '01' -- ATM
AND ( ( codigoiso = '04' ) OR ( codigoiso = '07' ) OR ( ( codigoiso >= '33' )
AND ( codigoiso <= '38' ) ) OR ( codigoiso = '41' )
OR ( codigoiso = '43' ) OR ( codigoiso = '67' ) ) ;

--TRANSACCIONES RECHAZADAS POR OTRAS RAZONES ATM
SELECT NVL(COUNT(*), 0)
INTO dTotalOtrasATM
FROM BdiReports:tmpmovimientostrim
WHERE ProdInd = '01' -- ATM
AND ( codigoiso <> '00' ) AND ( codigoiso <> '53' ) AND ( codigoiso <> '51' )
AND  ( codigoiso <> '04' ) AND ( codigoiso <> '07' ) AND ( codigoiso <> '41' )
AND ( codigoiso <> '43' ) AND ( codigoiso <> '67' )
AND ( ( codigoiso < '33' ) OR ( codigoiso > '38' ) ) ;


SET LOCK  MODE TO WAIT 3;
--Inserta en la base de datos
INSERT INTO bdireports:rpt_visaelectron(ide_producto,tipo_producto,trimestre,num_ctasinter,num_ctasrest,num_tar,numctas_act,numctas_perdep,
tpoctas_ctacor,tpoctas_chqesp,tpoctas_ctaaho,tpoctas_otras,met_posteo,per_fractas,per_frabru,mon_recfra,otra_perctas,otra_perbru,otra_perrec,
numctas_actpos,numctas_actatm,tranpos_fdoins,tranpos_rectar,tranpos_otrara,tranatm_fdoins,tranatm_rectar,tranatm_otrara,visami_com,visami_uni,
tar_recrem,numrem_rec,monto_remrec)
VALUES(
	'2000',
	'D',
	cTrimestre,
	NVL(dTotalCuentasDeb,0),
	0,
	NVL(dNumeroTarjetas,0),
	NVL(dTotalCuentasAct,0),
	0,
	'',
	'Y',
	'N',
	'N',
	'DEFERRED',
	0,
	0,
	0,
	0,
	0,
	0,
	NVL(dTotalTarjPOS,0),
	NVL(dTotalTarjATM,0),
	NVL(dTotalTransRechPOS,0),
	NVL(dTotalTarjRech,0),
	NVL(dTotalRechOtras,0),
	NVL(dTarjRechATM,0),
	NVL(dTotalRechATM,0),
	NVL(dTotalOtrasATM,0),
	0,
	0,
	0,
	0,
	0
);

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