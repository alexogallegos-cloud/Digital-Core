CREATE PROCEDURE "informix".sp_replicainformacionvisadebito_reproceso_2011(dFecha1 DATETIME year to fraction(5),dFecha2 DATETIME year to fraction(5),cTrimestre CHAR(5),iMes INTEGER)
returning
char (5),
char(100);


--#################################################################################
--### Creado por: Jorge Nuñez
--##  Fecha: 08/07/2008
--##  Descripcion: Replica informacion de debito mensualmente para el reporte trimestral de visa
--## DESARROLLO
--MODIFICADO: CASANOVA EDEZA HECTOR JUAN 05/03/2009
--###################################################################################
--MODIFICADO: Javier Chávez García 26/10/2009
--Descripción: Se ajustan consultas para el número de pagos vencidos, ya que la tabla histvalvon deja de utilizarse
-- Se ajusta la volumetría para reportar disposiciones de efectivo en ATM's propios y en otros ATM´s por solicitud del
-- área operativa.
--MODIFICADO: Javier Chávez García 05/10/2010
--Descripción: Se ajustan consultas para obtener la volumetría de las liberaciones en SIF

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

DEFINE iTotalDispATMtotal_b    DECIMAL;
DEFINE mSaldoDispATMtotal_b    MONEY(14,2);
DEFINE iTotalDispAtmInt1_b DECIMAL;
DEFINE dMontoAtmInt1_b     MONEY(14,2);
DEFINE iTotalDispAtmInt2_b DECIMAL;
DEFINE dMontoAtmInt2_b     MONEY(14,2);
DEFINE iTotalDispAtmIntTotal_b DECIMAL;
DEFINE dMontoAtmIntTotal_b     MONEY(14,2);
DEFINE dNumDispATMprop_b  DECIMAL;
DEFINE mMontoDispATMproptotal_b MONEY(14,2);

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

DEFINE iTotalComprasEntTotal05 DECIMAL;
DEFINE dMontoComprasEntTotal05 MONEY(14,2);
DEFINE iTotalComprasInterTotal05 DECIMAL;
DEFINE dMontoComprasInterTotal05 MONEY(14,2);
DEFINE iTotalComprasEntTotal01 DECIMAL;
DEFINE dMontoComprasEntTotal01 MONEY(14,2);
DEFINE iTotalComprasInterTotal01 DECIMAL;
DEFINE dMontoComprasInterTotal01 MONEY(14,2);

DEFINE iTotalComprasEntTotal05_b DECIMAL;
DEFINE dMontoComprasEntTotal05_b MONEY(14,2);
DEFINE iTotalComprasInterTotal05_b DECIMAL;
DEFINE dMontoComprasInterTotal05_b MONEY(14,2);
DEFINE iTotalComprasEntTotal01_b DECIMAL;
DEFINE dMontoComprasEntTotal01_b MONEY(14,2);
DEFINE iTotalComprasInterTotal01_b DECIMAL;
DEFINE dMontoComprasInterTotal01_b MONEY(14,2);

DEFINE iTotalComprasEntTotal_b DECIMAL;
DEFINE dMontoComprasEntTotal_b MONEY(14,2);
DEFINE iTotalComprasInterTotal_b DECIMAL;
DEFINE dMontoComprasInterTotal_b MONEY(14,2);



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
			
			--VALIDA SI EXISTE LA TABLATEMPORAL DE MOVHIS Y MAECRED

			IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames
				WHERE partnum is not null AND tabname = 'tmp_replica' AND dbsname= 'bdireports') THEN
				DROP TABLE bdireports:tmp_replica;
			END IF;

			LET cCodret=iSqlErr;
            RETURN cCodret, cVarDataErr;
        END IF;
  END EXCEPTION;

--Set debug file to "/ids_fc5/perifericos/visadeb.out";
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
LET iTotalDispAtmTotal_b = 0;
LET mSaldoDispATMtotal_b = 0;
LET iTotalComprasEntTotal = 0;
LET dMontoComprasEntTotal = 0;
LET iTotalComprasEntTotal_b = 0;
LET dMontoComprasEntTotal_b= 0;
LET iTotalComprasInterTotal = 0;
LET dMontoComprasInterTotal = 0;
LET iTotalComprasInterTotal_b = 0;
LET dMontoComprasInterTotal_b = 0;
LET iTotalDispAtmIntTotal = 0;
LET dMontoAtmIntTotal = 0;
LET iTotalDispAtmIntTotal_b = 0;
LET dMontoAtmIntTotal_b = 0;
LET dNumDispATMprop = 0.0;
LET mMontoDispATMproptotal = 0.0;
LET dNumDispATMprop_b = 0.0;
LET mMontoDispATMproptotal_b = 0.0;


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

LET iTotalComprasEntTotal05 = 0;
LET dMontoComprasEntTotal05 = 0;
LET iTotalComprasInterTotal05 = 0;
LET dMontoComprasInterTotal05 = 0;
LET iTotalComprasEntTotal01 = 0;
LET dMontoComprasEntTotal01 = 0;
LET iTotalComprasInterTotal01 = 0;
LET dMontoComprasInterTotal01 = 0;


--INFORMACION DE DEBITO
--Disposiciones de efectivo-Propio nacional número y monto

	
	--//// SE ELIMINA  EL REPORTE DE DISPOSICION DE VENTANILLA A SOLICITUD DE OPERACIONES
	/*
    SELECT  --{+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
	NVL(COUNT(*),0), SUM(NVL(monto_tot,0))
	INTO iTotalDisp,mSaldoDisp
	FROM bdicheq:sc_movhis
    WHERE empresa='001'
    AND cuenta <> ''
    AND fech_alt >= dFecha1::date
    AND fech_alt <= dFecha2::date
    AND cancelad <> 'S'
    AND transacc = '0223'
	AND producto='2000'
	GROUP BY producto;*/
	

	--IF iTotalDisp IS NULL OR mSaldoDisp IS NULL THEN
		LET iTotalDisp = 0;
		LET mSaldoDisp = 0;
	--END IF

	--Inserta en la base de datos
SET ISOLATION TO dirty read;
	LET cCodFila = 'VVP';
	LET cProducto = '2000';

	INSERT INTO bdireports:rpt_volumetria(num_producto,trimestre,id_col,mes,campo_a,campo_b,campo_c,campo_d,campo_e,campo_f,campo_g,campo_h,campo_i,campo_j)
	VALUES(cProducto,cTrimestre,cCodFila,iMes,0,0,0,0,0,0,iTotalDisp,mSaldoDisp,0,0);
	
	--- POS NACIONAL ( DESLIZADA - 90 )
	select  count(secuenciaextendida), nvl(sum(monto),0) INTO iTotalComprasEntTotal, dMontoComprasEntTotal
	from intercard:movimiento where fechahorainauth >=dFecha1 and fechahorainauth <=dFecha2
	and prodind='02' and codigoiso='00' and movreversado='F' and esnacional='V' and transaccionorigen = '1234' and numtarjeta matches '4008*'
	and formato <> '0420' and movconciliado='V' and metodocaptura='90' ;

	select  count(secuenciaextendida),nvl(sum(monto),0) INTO iTotalComprasEntTotal_b, dMontoComprasEntTotal_b
	from intercard:movimientohistorico where fechahorainauth >=dFecha1 and fechahorainauth <=dFecha2
	and prodind='02' and codigoiso='00' and movreversado='F' and esnacional='V' and transaccionorigen = '1234' and numtarjeta matches '4008*'
	and formato <> '0420' and movconciliado='V' and metodocaptura='90' ;
	
	LET iTotalComprasEntTotal = iTotalComprasEntTotal + iTotalComprasEntTotal_b;
	LET dMontoComprasEntTotal = dMontoComprasEntTotal + dMontoComprasEntTotal_b;
	
	--- POS INTERNACIONAL  ( DESLIZADA - 90 )
	select  count(secuenciaextendida),nvl(sum(monto),0) INTO iTotalComprasInterTotal, dMontoComprasInterTotal
	from intercard:movimiento where fechahorainauth >=dFecha1 and fechahorainauth <=dFecha2
	and prodind='02' and codigoiso='00' and movreversado='F' and esnacional='F'  and transaccionorigen = '1234' and numtarjeta matches '4008*'
	and formato <> '0420' and movconciliado='V' and metodocaptura='90' ;
	
	select  count(secuenciaextendida),nvl(sum(monto),0) INTO iTotalComprasInterTotal_b, dMontoComprasInterTotal_b
	from intercard:movimientohistorico where fechahorainauth >=dFecha1 and fechahorainauth <=dFecha2
	and prodind='02' and codigoiso='00' and movreversado='F' and esnacional='F'  and transaccionorigen = '1234' and numtarjeta matches '4008*'
	and formato <> '0420' and movconciliado='V' and metodocaptura='90' ;
	
	LET iTotalComprasInterTotal = iTotalComprasInterTotal + iTotalComprasInterTotal_b;
	LET dMontoComprasInterTotal = dMontoComprasInterTotal + dMontoComprasInterTotal_b;
	
	
	--- POS NACIONAL ( CHIP - 05 )
	select  count(secuenciaextendida),nvl(sum(monto),0) INTO iTotalComprasEntTotal05, dMontoComprasEntTotal05
	from intercard:movimiento where fechahorainauth >=dFecha1 and fechahorainauth <=dFecha2
	and prodind='02' and codigoiso='00' and movreversado='F' and esnacional='V' and transaccionorigen = '1234' and numtarjeta matches '4008*'
	and formato <> '0420' and movconciliado='V' and metodocaptura='05' ;

	select  count(secuenciaextendida),nvl(sum(monto),0) INTO iTotalComprasEntTotal05_b, dMontoComprasEntTotal05_b
	from intercard:movimientohistorico where fechahorainauth >=dFecha1 and fechahorainauth <=dFecha2
	and prodind='02' and codigoiso='00' and movreversado='F' and esnacional='V' and transaccionorigen = '1234' and numtarjeta matches '4008*'
	and formato <> '0420' and movconciliado='V' and metodocaptura='05' ;
	
	LET iTotalComprasEntTotal05 = iTotalComprasEntTotal05 +  iTotalComprasEntTotal05_b;
	LET dMontoComprasEntTotal05 = dMontoComprasEntTotal05 + dMontoComprasEntTotal05_b;
	
	--- POS INTERNACIONAL ( CHIP - 05 )
	select  count(secuenciaextendida),nvl(sum(monto),0) INTO iTotalComprasInterTotal05, dMontoComprasInterTotal05
	from intercard:movimiento where fechahorainauth >=dFecha1 and fechahorainauth <=dFecha2
	and prodind='02' and codigoiso='00' and movreversado='F' and esnacional='F' and transaccionorigen = '1234' and numtarjeta matches '4008*'
	and formato <> '0420' and movconciliado='V' and metodocaptura='05' ;
	
	select  count(secuenciaextendida),nvl(sum(monto),0) INTO iTotalComprasInterTotal05_b, dMontoComprasInterTotal05_b
	from intercard:movimientohistorico where fechahorainauth >=dFecha1 and fechahorainauth <=dFecha2
	and prodind='02' and codigoiso='00' and movreversado='F' and esnacional='F' and transaccionorigen = '1234' and numtarjeta matches '4008*'
	and formato <> '0420' and movconciliado='V' and metodocaptura='05' ;
	
	LET iTotalComprasInterTotal05 = iTotalComprasInterTotal05 +  iTotalComprasInterTotal05_b;
	LET dMontoComprasInterTotal05 = dMontoComprasInterTotal05 +  dMontoComprasInterTotal05_b;
	
	--- POS NACIONAL ( DIGITADA - 01 )
	select  count(secuenciaextendida),nvl(sum(monto),0) INTO iTotalComprasEntTotal01, dMontoComprasEntTotal01
	from intercard:movimiento where fechahorainauth >=dFecha1 and fechahorainauth <=dFecha2
	and prodind='02' and codigoiso='00' and movreversado='F' and esnacional='V' and transaccionorigen = '1234' and numtarjeta matches '4008*'
	and formato <> '0420' and movconciliado='V' and metodocaptura='01' ;

	select  count(secuenciaextendida),nvl(sum(monto),0) INTO iTotalComprasEntTotal01_b, dMontoComprasEntTotal01_b
	from intercard:movimientohistorico where fechahorainauth >=dFecha1 and fechahorainauth <=dFecha2
	and prodind='02' and codigoiso='00' and movreversado='F' and esnacional='V' and transaccionorigen = '1234' and numtarjeta matches '4008*'
	and formato <> '0420' and movconciliado='V' and metodocaptura='01' ;
	
	LET iTotalComprasEntTotal01 = iTotalComprasEntTotal01 + iTotalComprasEntTotal01_b;
	LET dMontoComprasEntTotal01 = dMontoComprasEntTotal01 + dMontoComprasEntTotal01_b;
	
	--- POS INTERNACIONAL ( DIGITADA - 01 )
	select  count(secuenciaextendida),nvl(sum(monto),0) INTO iTotalComprasInterTotal01, dMontoComprasInterTotal01
	from intercard:movimiento where fechahorainauth >=dFecha1 and fechahorainauth <=dFecha2
	and prodind='02' and codigoiso='00' and movreversado='F' and esnacional='F' and transaccionorigen = '1234' and numtarjeta matches '4008*'
	and formato <> '0420' and movconciliado='V' and metodocaptura='01';

	select  count(secuenciaextendida),nvl(sum(monto),0) INTO iTotalComprasInterTotal01_b, dMontoComprasInterTotal01_b
	from intercard:movimientohistorico where fechahorainauth >=dFecha1 and fechahorainauth <=dFecha2
	and prodind='02' and codigoiso='00' and movreversado='F' and esnacional='F' and transaccionorigen = '1234' and numtarjeta matches '4008*'
	and formato <> '0420' and movconciliado='V' and metodocaptura='01' ;
	
	LET iTotalComprasInterTotal01 = iTotalComprasInterTotal01 +  iTotalComprasInterTotal01_b;
	LET dMontoComprasInterTotal01 = dMontoComprasInterTotal01 +  dMontoComprasInterTotal01_b;

		--- ATM NACIONAL 
	select count(secuenciaextendida),nvl(sum(monto),0)  INTO iTotalDispAtmTotal, mSaldoDispATMtotal
	from intercard:movimiento 
	where  fechahorainauth >=dFecha1 and fechahorainauth <=dFecha2
	and prodind='01' and codigoiso='00' and movreversado='F' and esnacional='V' and trancajeropropio='F' and transaccionorigen = '1234' and numtarjeta matches '4008*'
	and formato <> '0420' 
	and movconciliado='V' ;

	select count(secuenciaextendida),nvl(sum(monto),0)  INTO iTotalDispAtmTotal_b, mSaldoDispATMtotal_b
	from intercard:movimientohistorico 
	where  fechahorainauth >=dFecha1 and fechahorainauth <=dFecha2
	and prodind='01' and codigoiso='00' and movreversado='F' and esnacional='V' and trancajeropropio='F' and transaccionorigen = '1234' and numtarjeta matches '4008*'
	and formato <> '0420' 
	and movconciliado='V' ;
	
	LET iTotalDispAtmTotal = iTotalDispAtmTotal +  iTotalDispAtmTotal_b;
	LET mSaldoDispATMtotal = mSaldoDispATMtotal +  mSaldoDispATMtotal_b;
	
	--- ATM INTERNACIONAL
	select  count(secuenciaextendida),nvl(sum(monto),0) INTO iTotalDispAtmIntTotal , dMontoAtmIntTotal
	from intercard:movimiento 
	where  fechahorainauth >=dFecha1 and fechahorainauth <=dFecha2
	and prodind='01' and codigoiso='00' and movreversado='F' and esnacional='F' and trancajeropropio='F' and transaccionorigen = '1234' and numtarjeta matches '4008*'
	and formato <> '0420'
	and movconciliado='V' ;

	select  count(secuenciaextendida),nvl(sum(monto),0) INTO iTotalDispAtmIntTotal_b , dMontoAtmIntTotal_b
	from intercard:movimientohistorico 
	where  fechahorainauth >=dFecha1 and fechahorainauth <=dFecha2
	and prodind='01' and codigoiso='00' and movreversado='F' and esnacional='F' and trancajeropropio='F' and transaccionorigen = '1234' and numtarjeta matches '4008*'
	and formato <> '0420'
	and movconciliado='V' ;
	
	LET iTotalDispAtmIntTotal = iTotalDispAtmIntTotal +  iTotalDispAtmIntTotal_b;
	LET dMontoAtmIntTotal = dMontoAtmIntTotal + dMontoAtmIntTotal_b;
	
		--- ATM PROPIOS
	select  count(secuenciaextendida),nvl(sum(monto),0) INTO dNumDispATMprop, mMontoDispATMproptotal
	from intercard:movimiento 
	where  fechahorainauth >=dFecha1 and fechahorainauth <=dFecha2
	and prodind='01' and codigoiso='00' and movreversado='F' and esnacional='V' and trancajeropropio='V' and transaccionorigen = '1234' and numtarjeta matches '4008*'
	and formato <> '0420'
	and movconciliado='V' ;

	select  count(secuenciaextendida),nvl(sum(monto),0) INTO dNumDispATMprop_b, mMontoDispATMproptotal_b
	from intercard:movimientohistorico 
	where  fechahorainauth >=dFecha1 and fechahorainauth <=dFecha2
	and prodind='01' and codigoiso='00' and movreversado='F' and esnacional='V' and trancajeropropio='V' and transaccionorigen = '1234' and numtarjeta matches '4008*'
	and formato <> '0420'
	and movconciliado='V' ;
	
	LET dNumDispATMprop = dNumDispATMprop + dNumDispATMprop_b;
	LET mMontoDispATMproptotal = mMontoDispATMproptotal + mMontoDispATMproptotal_b;

	--Inserta en la base de datos
	LET cCodFila = 'CEN';
	INSERT INTO bdireports:rpt_volumetria(num_producto,trimestre,id_col,mes,campo_a,campo_b,campo_c,campo_d,campo_e,campo_f,campo_g,campo_h,campo_i,campo_j)
	VALUES('2000',cTrimestre,cCodFila,iMes,iTotalComprasEntTotal,dMontoComprasEntTotal,iTotalComprasEntTotal05 ,dMontoComprasEntTotal05 ,iTotalComprasEntTotal01,dMontoComprasEntTotal01,0,0,iTotalDispAtmTotal,mSaldoDispATMtotal);

	--Se inserta en la base de datos la informacion
	LET cCodFila = 'CEI';
	INSERT INTO bdireports:rpt_volumetria(num_producto,trimestre,id_col,mes,campo_a,campo_b,campo_c,campo_d,campo_e,campo_f,campo_g,campo_h,campo_i,campo_j)
	VALUES('2000',cTrimestre,cCodFila,iMes,iTotalComprasInterTotal,dMontoComprasInterTotal,iTotalComprasInterTotal05 ,dMontoComprasInterTotal05 ,iTotalComprasInterTotal01,dMontoComprasInterTotal01,0,0,iTotalDispAtmIntTotal,dMontoAtmIntTotal);

    --Inserta en la base de datos - ATM's Propios
    UPDATE {+INDEX(rpt_volumetria idx_rpt_volumetria)} bdireports:rpt_volumetria SET campo_i = dNumDispATMprop , campo_j = mMontoDispATMproptotal
    WHERE num_producto = '2000' AND trimestre=cTrimestre AND id_col = 'VVP' AND mes = iMes;
	
----------------------------------------------------------------------------------------------------------------------------------------------------------



	--Esta informacion se corre a final del trimestre
	IF iMes = 3 OR iMes = 6 OR iMes = 9 OR iMes = 12 THEN


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
	
		--/// CUENTAS
	/*	select {+INDEX(bdicheq:sc_maechq ix174_4), (bdicheq:sc_maenoc idx_maenoc1)} 
		count(a.cuenta) 
		into dTotalCuentasDeb	
		from bdicheq:sc_maechq a, bdicheq:sc_maenoc b where a.empresa='001' 
		and a.status_cta <> '2'
		and a.producto in ('1300','1400','1500','1700','1800','1900','2000')
		and b.empresa = a.empresa
		and b.cuenta = a.cuenta
		and b.fecha_alta <= dFechaFin::date; */
		/* se sustituyo el query anterior por el siguiente */
		
                Set isolation to dirty read;
		select {+INDEX(bdicheq:sc_maechq idx_maechq1)}
		count(a.cuenta) into dTotalCuentasDeb
		from  bdicheq:sc_maechq a, bdicheq:sc_maenoc b
		where a.empresa=b.empresa
		and a.cuenta = b.cuenta
		and b.fecha_alta <= dFechaFin::date
		and a.status_cta <> 4;
		
		--Numero de Tarjetas

		/*set isolation to dirty read;
		select --{+INDEX(bdicheq:sc_maechq ix174_4), (bdicheq:sc_maenoc idx_maenoc1),(bdicheq:sc_tarjeta ix_tarjeta4)}
		count(c.num_tarjeta)
		into dNumeroTarjetas
		from bdicheq:sc_maechq a, bdicheq:sc_maenoc b ,bdicheq:sc_tarjeta c where a.empresa='001'
		and a.status_cta <> '2'
		and a.producto in ('1300','1400','1500','1700','1800','1900','2000')
		and b.empresa = a.empresa
		and b.cuenta = a.cuenta
		and b.fecha_alta <= dFechaFin::date
		and c.cuenta=b.cuenta
		and c.status_tar='A';*/
                /* se sustituyo el query anterior por el siguiente */
		
		Set isolation to dirty read;
		select count(numtarjeta) 
		INTO dNumeroTarjetas
		from  intercard:tarjeta
		where  codproductotarjeta='501'
		and fechaasignacion <= dFechaFin
		and codstatustarjeta not in ('CAN','INA','DES','FAL','EXT','DAN','ROB');
				
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
			cProducto,
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
	END IF
	
		--VALIDA SI EXISTE LA TABLATEMPORAL DE MOVIMIENTOS

	IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames
		WHERE partnum is not null AND tabname = 'tmpmovimientosmensual' AND dbsname= 'bdireports') THEN
		DROP TABLE bdireports:tmpmovimientosmensual;
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