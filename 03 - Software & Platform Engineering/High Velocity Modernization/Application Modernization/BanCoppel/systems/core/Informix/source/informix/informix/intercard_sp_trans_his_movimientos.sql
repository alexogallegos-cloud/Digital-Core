CREATE PROCEDURE "informix".sp_trans_his_movimientos(eFechaIni datetime year to fraction(5), eFechaFin datetime year to fraction(5))
returning
char (5),
char(150);

--##################################################################################################
--### Creado por: JUAN FCO. PONCE DAMIAN														  ##
--##  Fecha: 28/05/2013																			  ##
--##  Descripcion: Realiza la tranferencia de la tabla movimientohistorico a otra tabla por blokes##
--##  de 1,000 y un update statistics medium a la tabla cada 100,000.							  ##
--##################################################################################################



DEFINE iSqlErr          INTEGER;
DEFINE cVarDataErr      CHAR(150);
DEFINE cCodret          CHAR(5);

DEFINE vsFlagEnTransaccion	CHAR(5);
DEFINE viContadorRegistros	INTEGER;
DEFINE viContadorRegistros2	INTEGER;

--Variables para paso de tabla
DEFINE vsecuencia varchar(7);
DEFINE vnumtarjeta varchar(16);
DEFINE vfechahorainauth datetime year to fraction(5);

	ON EXCEPTION SET iSqlErr
		
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
		END IF;
		
        LET cCodret = iSqlErr;
		LET cVarDataErr = 'ERROR NO CONTROLADO: '||vfechahorainauth||'-'||vnumtarjeta||'-'||vsecuencia;
        RETURN cCodret, cVarDataErr;
  
	END EXCEPTION;

--Set debug file to "/informix/pruebasconciliacion/sp_trans_his_movimientos.sql";
--trace on;

	LET vsFlagEnTransaccion = 'F';
	LET viContadorRegistros = 0;
	LET viContadorRegistros2 = 0;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD 
			
		SELECT {+INDEX(intercard:movimientohistorico idx_movimiento3)}
		secuencia,numtarjeta,fechahorainauth
		INTO
		vsecuencia,vnumtarjeta,vfechahorainauth
		FROM intercard:movimientohistorico WHERE fechahorainauth >= eFechaIni AND fechahorainauth < eFechaFin
		
		--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (vsFlagEnTransaccion = 'F') THEN
			 BEGIN WORK;
			 LET vsFlagEnTransaccion = 'V';
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		INSERT INTO intercard:movimientohistorico_2015  (
		secuencia,codigoiso,codgironeg,codigocentral,numtarjeta,enlinea,enviado,prodind,formato,codtran,tipoctaorigen,tipoctadestino,fechaexptarj,fechamov,
		horamov,codreversa,moneda,referencia,monto,infreceptor,idreceptor,idterminal,montorealrevfzda,secuenciaorig,pinvalido,cvvvalido,preautorizacion,
		movreversado,fechaapliccentral,esnacional,pais,metodocaptura,motivo,draftcaptura,prosaauth,authhost,hostauth,authprosa,cobrocomision,montocomision,
		movconciliado,fechalocaltransaccion,horalocaltransaccion,fechacaptura,trancajeropropio,fechahorainauth,comisionenlinea,codigoretcomision,seccomision,
		tnrcobrocomisionctaindividual,tnrmontocomisionctaindividual,permitecomisionpendiente,generocomisionpendiente,movduranteactsaldos,montosurcharge,
		secsurcharge,montocashback,secuenciacashback,secuenciacomcashback,montocomcashback,cvv2valido,transaccionorigen,tipotransaccionposdigitada,tokens63in,
		trancajeroconvenio,codigoisorev,fechahoraoutauth,fechahorabcentral,fechahoraacentral,fechahorainauthj,idretailer,tipotransaccionpos,secuenciaextendida,surcharge)
		SELECT {+INDEX(intercard:movimientohistorico idx_movimiento3)}
		secuencia,codigoiso,codgironeg,codigocentral,numtarjeta,enlinea,enviado,prodind,formato,codtran,tipoctaorigen,tipoctadestino,fechaexptarj,fechamov,
		horamov,codreversa,moneda,referencia,monto,infreceptor,idreceptor,idterminal,montorealrevfzda,secuenciaorig,pinvalido,cvvvalido,preautorizacion,
		movreversado,fechaapliccentral,esnacional,pais,metodocaptura,motivo,draftcaptura,prosaauth,authhost,hostauth,authprosa,cobrocomision,montocomision,
		movconciliado,fechalocaltransaccion,horalocaltransaccion,fechacaptura,trancajeropropio,fechahorainauth,comisionenlinea,codigoretcomision,seccomision,
		tnrcobrocomisionctaindividual,tnrmontocomisionctaindividual,permitecomisionpendiente,generocomisionpendiente,movduranteactsaldos,montosurcharge,
		secsurcharge,montocashback,secuenciacashback,secuenciacomcashback,montocomcashback,cvv2valido,transaccionorigen,tipotransaccionposdigitada,tokens63in,
		trancajeroconvenio,codigoisorev,fechahoraoutauth,fechahorabcentral,fechahoraacentral,fechahorainauthj,idretailer,tipotransaccionpos,secuenciaextendida,surcharge
		FROM intercard:movimientohistorico where fechahorainauth = vfechahorainauth and numtarjeta = vnumtarjeta and secuencia = vsecuencia ;
		
		DELETE {+INDEX(movimientohistorico idx_movimiento3)} FROM intercard:movimientohistorico where fechahorainauth = vfechahorainauth and numtarjeta = vnumtarjeta and secuencia = vsecuencia ;

		LET viContadorRegistros = viContadorRegistros + 1;
		LET viContadorRegistros2 = viContadorRegistros2 + 1;
		
		--SE APLICA update statistics medium A LA TABLA.
		IF (viContadorRegistros = 100000) THEN --VERIFICA SI EL BLOKE 2 ALCANSO LA CONDICION PARA REALIZAR EL update statistics
			update statistics medium for table intercard:"informix".movimientohistorico;
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