CREATE PROCEDURE "informix".sp_generareportevisaelectron(dFechaIn DATETIME year to fraction(5),dFechaFin DATETIME year to fraction(5),cTrimestre CHAR(5),iMes INTEGER)
returning
char (5),
char(100);

--##################################################################################################
--### Creado por: Jorge Nuñez																	  ##
--##  Fecha: 08/07/2008																			  ##
--##  Descripcion: Replica informacion de debito mensualmente para el reporte trimestral de visa  ##
--## DESARROLLO																					  ##
--## MODIFICADO: JUAN FCO. PONCE DAMIAN	 01/01/2013                                               ##
--## MODIFICACION: Se modifico para reing. de reporte VISA. sólo llena las tablas trimestrales    ##
--##################################################################################################
--## MODIFICADO: JUAN FCO. PONCE DAMIAN	 15/03/2013                                               ##
--## MODIFICACION: Se mejoran consultas para ajilizar el proceso.							      ##
--##################################################################################################
--## MODIFICADO: JUAN FCO. PONCE DAMIAN	 15/06/2013                                               ##
--## MODIFICACION:Se integra consulta y campo nuevo para almacenar el numero de tarjetas con Chip.##
--####################################################
--##############################################


DEFINE iSqlErr          INTEGER;
DEFINE cVarDataErr      CHAR(100);
DEFINE cCodret          CHAR(5);
DEFINE cProducto        CHAR(4);

DEFINE dTotalCuentasDeb DECIMAL;
DEFINE dNumeroTarjetas  DECIMAL;
DEFINE dNumeroTarjetasChip  DECIMAL;
DEFINE dNumeroTarjetasChip2 DECIMAL;
DEFINE dTotalCuentasAct DECIMAL;
DEFINE dTotalCuentasPerDep DECIMAL;
DEFINE dTotalTarjPOS    DECIMAL;
DEFINE dTotalTarjATM    DECIMAL;
DEFINE dTotalTransRechPOS DECIMAL;
DEFINE dTotalTarjRech   DECIMAL;
DEFINE dTotalRechOtras  DECIMAL;
DEFINE dTarjRechATM     DECIMAL;
DEFINE dTotalRechATM    DECIMAL;
DEFINE dTotalOtrasATM   DECIMAL;

DEFINE vsNumTarjeta CHAR (16);
DEFINE vsCodigoIso CHAR (2);
DEFINE vsCodtran CHAR (2);
DEFINE vsProdind CHAR (2);
DEFINE vsMovreversado char(1);

DEFINE vsFlagEnTransaccion CHAR (1);

DEFINE viContadorRegistros INTEGER;

  ON EXCEPTION SET iSqlErr
		
		LET cVarDataErr = 'ERROR NO CONTROLADO (' || iSqlErr || '). ' ;
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

		LET cCodret= '-1';
		INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,ultima_actualizacion,estatus_actualizacion,dias_pendientes,ultimo_error)  
		VALUES ( 'sp_generareportevisaelectron',iMes,dFechaIn::DATE,'', 0 ,cVarDataErr);
		
           RETURN cCodret, cVarDataErr;
  
  END EXCEPTION;

--Set debug file to "sp_generareportevisaelectron.out";
--trace on;
	
LET cCodret = '00000';
LET cVarDataErr = '';

LET vsNumTarjeta = '';
LET vsCodigoIso = '';
LET vsCodtran = '';
LET vsProdind = '';
LET vsMovreversado='';

LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;

	--Inserta en la base de datos
SET ISOLATION TO dirty read;
	LET cProducto = '2000';
	
----------------------------------------------------------------------------------------------------------------------------------------------------------

		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH WITH HOLD 
			SELECT {+INDEX(Intercard:Movimiento idx_fechahorainauth)}
			NumTarjeta, CodigoIso, Prodind,codtran,movreversado
			INTO vsNumTarjeta, vsCodigoIso, vsProdind, vsCodtran, vsMovreversado
			FROM Intercard:Movimiento WHERE FechaHoraInAuth BETWEEN dFechaIn AND dFechaFin
			AND (numtarjeta matches '416916*' or numtarjeta matches '400819*')  --DEBITO--
			UNION
			SELECT {+INDEX(Intercard:movimientoHistorico idx_fechahorainauth)}
			NumTarjeta, CodigoIso, Prodind,codtran,movreversado
			FROM Intercard:movimientoHistorico WHERE  FechaHoraInAuth BETWEEN dFechaIn AND dFechaFin
			AND (numtarjeta matches '416916*' or numtarjeta matches '400819*')  --DEBITO--
			
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
		
       	--Número de cuentas activas - durante el trimestre
		/*Proporcionar el número de cuentas activas con una o más compras o disposiciones de efectivo durante el trimestre. 
		Por ejemplo, una tarjeta de débito que está conectada a una cuenta de cheque que ha tenido actividad durante el trimestre.*/
		
		SELECT {+INDEX(bdireports:tmpmovimientostrim idx_tmpmovimientostrim_02),(bdicheq:sc_tarjeta ix_tarjeta2)} 
		COUNT(b.cuenta)
		INTO dTotalCuentasAct 
		FROM tmpmovimientostrim a, bdicheq:sc_tarjeta b 
		WHERE codigoiso='00'
		AND a.codtran <> '31'
		AND a.movreversado='F'
		AND b.empresa='001'
		AND b.num_tarjeta=a.numtarjeta;
		
		--Numero de tarjetas con actividad en en pos
		SELECT COUNT(DISTINCT numtarjeta)
		INTO dTotalTarjPOS
		FROM BdiReports:tmpmovimientostrim
		WHERE ProdInd = '02'
        AND CodigoIso <> ''; -- POS

		--Numero de tarjetas con actividad en ATM
		SELECT COUNT(DISTINCT numtarjeta)
		INTO dTotalTarjATM
		FROM BdiReports:tmpmovimientostrim
		WHERE ProdInd = '01'
        AND CodigoIso <> ''; -- ATM

		--TRANSACCIONES RECHAZADAS POR FONDOS INSUFICIENTES POS
		SELECT COUNT(*)
		INTO dTotalTransRechPOS
		FROM BdiReports:tmpmovimientostrim
		WHERE ProdInd = '02' -- POS
		AND CodigoIso = '51';

		--TRANSACCIONES RECHAZADAS POR RECOGER TARJETA
		SELECT COUNT(*)
		INTO dTotalTarjRech
		FROM BdiReports:tmpmovimientostrim
		WHERE ProdInd = '02' -- POS
		AND ( ( codigoiso = '04' ) OR ( codigoiso = '07' )
		OR ( ( codigoiso >= '33' ) AND ( codigoiso <= '38' ) )
		OR ( codigoiso = '41' )
		OR ( codigoiso = '43' ) OR ( codigoiso = '67' ) );

		--TRANSACCIONES RECHAZADAS POR OTRAS RAZONES POS
		SELECT COUNT(*)
		INTO dTotalRechOtras
		FROM BdiReports:tmpmovimientostrim
		WHERE ProdInd = '02' -- POS
		AND ( codigoiso <> '00' ) AND ( codigoiso <> '53' ) AND ( codigoiso <> '51' )
		AND  ( codigoiso <> '04' ) AND ( codigoiso <> '07' ) AND ( codigoiso <> '41' )
		AND ( codigoiso <> '43' ) AND ( codigoiso <> '67' )
		AND ( ( codigoiso < '33' ) OR ( codigoiso > '38' ) ) ;

		--TRANSACCIONES RECHAZADAS POR FONDOS INSUFICIENTES ATM
		SELECT COUNT(*)
		INTO dTarjRechATM
		FROM BdiReports:tmpmovimientostrim
		WHERE ProdInd = '01' -- ATM
		AND CodigoISO = '51';

		--TRANSACCIONES RECHAZADAS POR RECOGER TARJETA ATM
		SELECT COUNT(*)
		INTO dTotalRechATM
		FROM BdiReports:tmpmovimientostrim
		WHERE ProdInd = '01' -- ATM
		AND ( ( codigoiso = '04' ) OR ( codigoiso = '07' ) OR ( ( codigoiso >= '33' )
		AND ( codigoiso <= '38' ) ) OR ( codigoiso = '41' )
		OR ( codigoiso = '43' ) OR ( codigoiso = '67' ) ) ;

		--TRANSACCIONES RECHAZADAS POR OTRAS RAZONES ATM
		SELECT COUNT(*)
		INTO dTotalOtrasATM
		FROM BdiReports:tmpmovimientostrim
		WHERE ProdInd = '01' -- ATM
		AND ( codigoiso <> '00' ) AND ( codigoiso <> '53' ) AND ( codigoiso <> '51' )
		AND  ( codigoiso <> '04' ) AND ( codigoiso <> '07' ) AND ( codigoiso <> '41' )
		AND ( codigoiso <> '43' ) AND ( codigoiso <> '67' )
		AND ( ( codigoiso < '33' ) OR ( codigoiso > '38' ) ) ;
		
		LET dFechaIn = CAST(dFechaIn as DATE);
		LET dFechaFin = CAST(dFechaFin as DATE);
		
		--TOTAL DE CUENTAS DE DEBITO
		set isolation to dirty read;
		SELECT COUNT(a.cuenta) INTO dTotalCuentasDeb
		FROM bdicheq:sc_maechq a INNER JOIN bdicheq:sc_maenoc b ON a.cuenta = b.cuenta
		WHERE b.fecha_alta <= dFechaFin AND a.producto NOT IN ('1100','1800','2400') AND a.status_cta IN ('1','3','4');
		
		--TOTAL DE TARJETAS DE DEBITO
        Set isolation to dirty read; 
		SELECT COUNT(c.num_tarjeta) INTO dNumeroTarjetas
		FROM (bdicheq:sc_maechq a INNER JOIN bdicheq:sc_maenoc b 
		ON a.cuenta = b.cuenta) INNER JOIN bdicheq:sc_tarjeta c  on c.cuenta=a.cuenta
		WHERE b.fecha_alta <= dFechaFin  AND a.producto NOT IN ('1100','1800','2400') AND a.status_cta IN ('1','3','4');
		
		--TOTAL DE TARJETAS DE DEBITO CON CHIP, BIN 416916
		Set isolation to dirty read; 
		SELECT COUNT(c.num_tarjeta) INTO dNumeroTarjetasChip
		FROM (bdicheq:sc_maechq a INNER JOIN bdicheq:sc_maenoc b 
		ON a.cuenta = b.cuenta) INNER JOIN bdicheq:sc_tarjeta c  on (c.cuenta=a.cuenta and c.num_tarjeta matches '416916*')
		WHERE b.fecha_alta <= dFechaFin  AND a.producto NOT IN ('1100','1800','2400') AND a.status_cta IN ('1','3','4');
		
		--TOTAL DE TARJETAS DE DEBITO CON CHIP, BIN 400819
		SELECT COUNT(c.numtarjeta) INTO dNumeroTarjetasChip2
		FROM (bdicheq:sc_maechq a INNER JOIN bdicheq:sc_maenoc b
		ON a.cuenta = b.cuenta) INNER JOIN intercard:tarjetacuenta c 
		ON a.cuenta = c.numcuenta INNER JOIN intercard:tarjeta d 
		ON c.numtarjeta=d.numtarjeta INNER JOIN intercard:lote e ON
		(d.numerolote=e.numerolote and e.clave_tipotarjeta = 6)
		WHERE b.fecha_alta <= dFechaFin  AND a.producto NOT IN 
		('1100','1800','2400') AND a.status_cta IN ('1','3','4');
		
		LET dNumeroTarjetasChip = dNumeroTarjetasChip + dNumeroTarjetasChip2;
		
		--TOTAL DE TARJETAS DE DEBITO QUE RECIBIERON ALGUN DEPOSITO EN EL TRIMESTRE
		SELECT COUNT(cuenta) INTO dTotalCuentasPerDep FROM bdicheq:sc_maechq WHERE fecultdep >= dFechaIn 
		AND producto NOT IN ('1100','1800','2400') AND status_cta IN ('1','3','4') ;
		
		SET LOCK  MODE TO WAIT 3;
		--Inserta en la base de datos
		INSERT INTO bdireports:rpt_visaelectron(ide_producto,tipo_producto,trimestre,num_ctasinter,num_ctasrest,num_tar,numctas_act,numctas_perdep,
		tpoctas_ctacor,tpoctas_chqesp,tpoctas_ctaaho,tpoctas_otras,met_posteo,per_fractas,per_frabru,mon_recfra,otra_perctas,otra_perbru,otra_perrec,
		numctas_actpos,numctas_actatm,tranpos_fdoins,tranpos_rectar,tranpos_otrara,tranatm_fdoins,tranatm_rectar,tranatm_otrara,visami_com,visami_uni,
		tar_recrem,numrem_rec,monto_remrec,num_tarchip)
		VALUES(
			cProducto,
			'D',
			cTrimestre,
			NVL(dTotalCuentasDeb,0),
			0,
			NVL(dNumeroTarjetas,0),
			NVL(dTotalCuentasAct,0),
			NVL(dTotalCuentasPerDep,0),
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
			0,
			NVL(dNumeroTarjetasChip,0)
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