CREATE PROCEDURE "informix".sp_atmdudoso()
RETURNING
VARCHAR(5) AS CodRetorno, 
VARCHAR(50) AS DescRetorno

--****************************************************************************************************
-- DESCRIPCION:  PROCESO DE ATMDUDOSO (uso de llave primaria p/evitar registros duplicados).
-- AUTOR : Fermín Ramos García.
-- FECHA : 29/Ago/2016
-- BD: INTERCARD
-- SISTEMA : MAC-MPT (Prev. Fraudes).
-- MODIFICADO :
--****************************************************************************************************

DEFINE CodRetorno VARCHAR(5);
DEFINE DescRetorno VARCHAR(50);
DEFINE viSqlErr INTEGER;
DEFINE viSamErr INTEGER;
DEFINE vcerror_info VARCHAR(50);

DEFINE vcafilatm VARCHAR(19);
DEFINE vsql char(1150);


	--	SET DEBUG FILE TO "/resplogifx/sp_atmdudoso.out";
    --	TRACE ON;

--INICIALIZACION VARIABLES:

LET CodRetorno = '00000';
LET DescRetorno = 'Ejecución de proceso exitosa.';
LET viSqlErr = 0;
LET viSamErr = 0;
LET vcerror_info = '';
LET vcafilatm  = '';
LET vsql = '';

BEGIN
	ON EXCEPTION
		SET viSqlErr, viSamErr, vcerror_info
		LET CodRetorno = viSqlErr;
		LET DescRetorno = vcerror_info;
		RETURN CodRetorno, DescRetorno;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	let vsql = '';
	let vsql = 'echo "UNLOAD TO /resplogifx/atmdudoso_old.unl SELECT * FROM "informix".atmdudoso_old order by numafiliacionatm;">/resplogifx/unld_atmdudoso.sql';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	let vsql= 'dbaccess intercard /resplogifx/unld_atmdudoso.sql';
	system vsql;
	let vsql = '';
	let vsql ='rm /resplogifx/unld_atmdudoso.sql';
	system vsql;
	let vsql ='';
	
	set isolation to dirty read;
	
	select distinct (numafiliacionatm) as numafiliacionatm , max (fechainserta) as fechainserta 
	from "informix".atmdudoso_old 
    group by 1 
	into temp tmp_afiliacionatm;
	
	begin work;
	INSERT INTO "informix".atmdudoso 
		(numafiliacionatm, descripcion, bloqueado, metodobanda, metodochip, metododigitada, bloqueointernacional, bloqueonacional, fechainserta, usuarioinserta)
	SELECT a.numafiliacionatm, descripcion, bloqueado, metodobanda, metodochip, metododigitada, bloqueointernacional, bloqueonacional, a.fechainserta , usuarioinserta
	FROM "informix".atmdudoso_old a, intercard:tmp_afiliacionatm b
	where a.numafiliacionatm = b.numafiliacionatm
	and a.fechainserta =b.fechainserta;
	commit work;
	
	RETURN CodRetorno, DescRetorno;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Fermín Ramos García.',
'Descripcion: Proceso p/insertar en tabla solo registros NO repetidos.',
'Fecha: 2016/08/31',
'Version: 20160831.1300',
'BD: intercard';

CREATE PROCEDURE "informix".sp_trans_his_movimientoshistoricos(eFechaIni datetime year to fraction(5), eFechaFin datetime year to fraction(5))
returning
char (5),
char(150);

--###########################################################################################################
--### Creado por: Ulises Jacobo Acevedo Aguilar													           ##
--##  Fecha: 28/05/2016																			           ##
--##  Descripcion: Realiza la tranferencia de la tabla movimientohistorico2_2015 a otra tabla por blokes   ##
--##  de 1,000 y un update statistics medium a la tabla cada 100,000.							           ##
--##  Fecha: 04/11/2016																			           ##
--##  Modifica: FRG	                                                                                       ##
--##  Descripcion: Realiza la tranferencia de la tabla movimientohistorico2_2015 a nueva tabla             ##
--##  intercard: movimientohistorico_2016 por bloques de 1,000 registros y un update statistics medium a   ##
--##  la tabla cada 100,000 registros.   			                                                       ##
--###########################################################################################################

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

   --	Set debug file to "/informix/c94796696/sp_trans_his_movimientos.sql";
   --	trace on;

	LET vsFlagEnTransaccion = 'F';
	LET viContadorRegistros = 0;
	LET viContadorRegistros2 = 0;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH WITH HOLD 
			
		SELECT 
		secuencia,numtarjeta,fechahorainauth
		INTO
		vsecuencia,vnumtarjeta,vfechahorainauth
		FROM intercard:movimientohistorico2_2015 WHERE fechahorainauth >= eFechaIni AND fechahorainauth < eFechaFin
		
		--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (vsFlagEnTransaccion = 'F') THEN
			 BEGIN WORK;
			 LET vsFlagEnTransaccion = 'V';
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		INSERT INTO intercard:movimientohistorico_2016 (
		secuencia,codigoiso,codgironeg,codigocentral,numtarjeta,enlinea,enviado,prodind,formato,codtran,tipoctaorigen,tipoctadestino,fechaexptarj,fechamov,
		horamov,codreversa,moneda,referencia,monto,infreceptor,idreceptor,idterminal,montorealrevfzda,secuenciaorig,pinvalido,cvvvalido,preautorizacion,
		movreversado,fechaapliccentral,esnacional,pais,metodocaptura,motivo,draftcaptura,prosaauth,authhost,hostauth,authprosa,cobrocomision,montocomision,
		movconciliado,fechalocaltransaccion,horalocaltransaccion,fechacaptura,trancajeropropio,fechahorainauth,comisionenlinea,codigoretcomision,seccomision,
		tnrcobrocomisionctaindividual,tnrmontocomisionctaindividual,permitecomisionpendiente,generocomisionpendiente,movduranteactsaldos,montosurcharge,
		secsurcharge,montocashback,secuenciacashback,secuenciacomcashback,montocomcashback,cvv2valido,transaccionorigen,tipotransaccionposdigitada,tokens63in,
		trancajeroconvenio,codigoisorev,fechahoraoutauth,fechahorabcentral,fechahoraacentral,fechahorainauthj,idretailer,tipotransaccionpos,secuenciaextendida,surcharge,
		arqcrecibido,arqccalculado,arqcrc,pcc,eci)
		SELECT 
		secuencia,codigoiso,codgironeg,codigocentral,numtarjeta,enlinea,enviado,prodind,formato,codtran,tipoctaorigen,tipoctadestino,fechaexptarj,fechamov,
		horamov,codreversa,moneda,referencia,monto,infreceptor,idreceptor,idterminal,montorealrevfzda,secuenciaorig,pinvalido,cvvvalido,preautorizacion,
		movreversado,fechaapliccentral,esnacional,pais,metodocaptura,motivo,draftcaptura,prosaauth,authhost,hostauth,authprosa,cobrocomision,montocomision,
		movconciliado,fechalocaltransaccion,horalocaltransaccion,fechacaptura,trancajeropropio,fechahorainauth,comisionenlinea,codigoretcomision,seccomision,
		tnrcobrocomisionctaindividual,tnrmontocomisionctaindividual,permitecomisionpendiente,generocomisionpendiente,movduranteactsaldos,montosurcharge,
		secsurcharge,montocashback,secuenciacashback,secuenciacomcashback,montocomcashback,cvv2valido,transaccionorigen,tipotransaccionposdigitada,tokens63in,
		trancajeroconvenio,codigoisorev,fechahoraoutauth,fechahorabcentral,fechahoraacentral,fechahorainauthj,idretailer,tipotransaccionpos,secuenciaextendida,surcharge,
		arqcrecibido,arqccalculado,arqcrc,pcc,eci
		FROM intercard:movimientohistorico2_2015 where fechahorainauth = vfechahorainauth and numtarjeta = vnumtarjeta and secuencia = vsecuencia;
		
		DELETE  FROM intercard:movimientohistorico2_2015 where fechahorainauth = vfechahorainauth and numtarjeta = vnumtarjeta and secuencia = vsecuencia;

		LET viContadorRegistros = viContadorRegistros + 1;
		LET viContadorRegistros2 = viContadorRegistros2 + 1;
		
		--SE APLICA update statistics medium A LA TABLA.
		IF (viContadorRegistros = 100000) THEN --VERIFICA SI EL BLOKE 2 ALCANSO LA CONDICION PARA REALIZAR EL update statistics
			update statistics medium for table intercard:"informix".movimientohistorico_2016;
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