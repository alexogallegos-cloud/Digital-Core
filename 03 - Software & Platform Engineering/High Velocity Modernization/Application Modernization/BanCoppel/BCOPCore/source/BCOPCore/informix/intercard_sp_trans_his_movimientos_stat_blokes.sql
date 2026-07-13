CREATE PROCEDURE "informix".sp_trans_his_movimientos_stat_blokes(eFechaIni datetime year to fraction(5), eFechaFin datetime year to fraction(5))
returning
char (5),
char(150);

--##################################################################################################
--### Creado por: Ana Lidia Rubio Salazar														  ##
--##  Fecha: 29/11/2016																			  ##
--##  Descripcion: Realiza la tranferencia de la tabla conciliacion_atm_stat06_his a 		      ##
--##  conciliacion_atm_stat06 por blokes y un update statistics medium a la tabla cada 100,000.	  ##
--##################################################################################################


DEFINE iSqlErr          INTEGER;
DEFINE cVarDataErr      CHAR(150);
DEFINE cCodret          CHAR(5);

DEFINE vsFlagEnTransaccion	CHAR(5);
DEFINE viContadorRegistros	INTEGER;
DEFINE viContadorRegistros2	INTEGER;

--Variables para paso de tabla
DEFINE vautorizacion varchar(7);
DEFINE vnumtarjeta varchar(16);
DEFINE vfechaconciliacion datetime year to fraction(5);

	ON EXCEPTION SET iSqlErr
		
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
		END IF;
		
        LET cCodret = iSqlErr;
		LET cVarDataErr = 'ERROR NO CONTROLADO: '||vfechaconciliacion||'-'||vnumtarjeta||'-'||vautorizacion;
        RETURN cCodret, cVarDataErr;
  
	END EXCEPTION;

	--Set debug file to "/informix/analy/sp_trans_his_movimientos.sql";
	--trace on;

	LET vsFlagEnTransaccion = 'F';
	LET viContadorRegistros = 0;
	LET viContadorRegistros2 = 0;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
		FOREACH WITH HOLD 
			
		SELECT autorizacion,numtarjeta,fechaconciliacion
		INTO vautorizacion,vnumtarjeta,vfechaconciliacion
		FROM intercard:conciliacion_atm_stat06_his 
		WHERE fechaconciliacion >= eFechaIni AND fechaconciliacion < eFechaFin
		
		--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (vsFlagEnTransaccion = 'F') THEN
			 BEGIN WORK;
			 LET vsFlagEnTransaccion = 'V';
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		INSERT INTO intercard:conciliacion_atm_stat06 (
		keyx, fechaconciliacion, archivoorigen, nombrearchivo, emisor, numcajero, numtarjeta, numcuenta, indicadordereversa, descripcion, respuesta, codigoiso, 
		secuencia, fecha, hora, orden, red, monto, dolares, comisionsurcharge, donativo, emp, autorizacion, compania, comision_loyaltyfee, comision_usolinea, 
		pos_entry_mode, service_code, terminal_capability, arqc, arpc, arqc_verify)
		SELECT 
		keyx, fechaconciliacion, archivoorigen, nombrearchivo, emisor, numcajero, numtarjeta, numcuenta, indicadordereversa, descripcion, respuesta, codigoiso, 
		secuencia, fecha, hora, orden, red, monto, dolares, comisionsurcharge, donativo, emp, autorizacion, compania, comision_loyaltyfee, comision_usolinea, 
		pos_entry_mode, service_code, terminal_capability, arqc, arpc, arqc_verify
		FROM intercard:conciliacion_atm_stat06_his where fechaconciliacion = vfechaconciliacion and numtarjeta = vnumtarjeta and autorizacion = vautorizacion ;
		
		DELETE FROM intercard:conciliacion_atm_stat06_his where fechaconciliacion = vfechaconciliacion and numtarjeta = vnumtarjeta and autorizacion = vautorizacion ;

		LET viContadorRegistros = viContadorRegistros + 1;
		LET viContadorRegistros2 = viContadorRegistros2 + 1;
		
		--SE APLICA update statistics medium A LA TABLA.
		IF (viContadorRegistros = 100000) THEN --VERIFICA SI EL BLOKE 2 ALCANSO LA CONDICION PARA REALIZAR EL update statistics
			update statistics medium for table intercard:"informix".conciliacion_atm_stat06_his;
			LET viContadorRegistros2 = 0;
			CONTINUE FOREACH;
		END IF;

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
			LET vsFlagEnTransaccion = 'F';
		END IF;
	
	LET cCodret = '00000';
	LET cVarDataErr = 'PROCESO EXITOSO' ;
		
RETURN cCodret,cVarDataErr;
END PROCEDURE;