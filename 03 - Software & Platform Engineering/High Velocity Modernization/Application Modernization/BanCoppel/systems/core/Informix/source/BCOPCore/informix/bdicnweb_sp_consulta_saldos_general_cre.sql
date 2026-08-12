CREATE PROCEDURE "informix".sp_consulta_saldos_general_cre(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumeroCredito CHAR(20))
	RETURNING CHAR(5) AS codret,
		CHAR(20)      AS numeroCredito,
		CHAR(2)       AS codigoTipcred,
		DATE          AS fechaOrigen,
		DATE          AS fechaProxPago,
		DECIMAL(18,2) AS pagoMinimo,
		DATE          AS fechaUltPago,
		INTEGER       AS plazo,
		INTEGER       AS pagosRealizados,
		DECIMAL(18,2) AS lineaOtorgada,
		DECIMAL(9,6)  AS tasaInteres,
		DECIMAL(9,6)  AS tasaMoratorios,
		DECIMAL(14,2) AS montoSbc,
		DECIMAL(18,2) AS capVig,
		DECIMAL(18,2) AS capTrans,
		DECIMAL(18,2) AS capVdoExig,
		DECIMAL(18,2) AS capVdoNoExig,
		DECIMAL(18,2) AS sdoActTotalCap,
		DECIMAL(18,2) AS intVig,
		DECIMAL(18,2) AS intVdo,
		DECIMAL(18,2) AS intMoratorios,
		DECIMAL(18,2) AS intMes,
		DECIMAL(18,2) AS sdoActTotalInt,
		DECIMAL(18,2) AS ivaIntVig,
		DECIMAL(18,2) AS ivaIntVdo,
		DECIMAL(18,2) AS ivaIntMoratorios,
		DECIMAL(18,2) AS ivaIntMes,
		DECIMAL(18,2) AS sdoActTotalIva,
		DECIMAL(18,2) AS comPend,
		DECIMAL(18,2) AS ivaCom,
		DECIMAL(18,2) AS sdoRetenido,
		DECIMAL(18,2) AS totalLiquidacion,
		DECIMAL(18,2) AS intDevengado,
		DECIMAL(18,2) AS ivaIntDevengado,
		DECIMAL(18,2) AS lineaDisponible,
		DECIMAL(18,2) AS pagosVdos,
		CHAR(60)      AS descStatusCred,
		INTEGER       AS idBloqueoCred,
		CHAR(60)      AS bloqueoCta,
		CHAR(3)       AS idCausaBloqueoCred,
		CHAR(50)      AS causaBloqueoCta,
		CHAR(1)       AS idSitEspEte,
		INTEGER       AS idCausaEspCte,
		CHAR(75)      AS sitEspCte,
		CHAR(1)       AS idSitEspCred,
		INTEGER       AS idCausaEspCred,
		CHAR(75)      AS sitEspCred,
		DATE          AS fechaCarteraVendida;
		
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE mensajeRetorno CHAR(80);
	DEFINE numeroCredito CHAR(20);
	DEFINE codigoTipcred CHAR(2);
	DEFINE fechaOrigen DATE;
	DEFINE fechaProxPago DATE;
	DEFINE pagoMinimo DECIMAL(18,2);
	DEFINE fechaUltPago DATE;
	DEFINE plazo INTEGER;
	DEFINE pagosRealizados INTEGER;
	DEFINE lineaOtorgada DECIMAL(18,2);
	DEFINE tasaInteres DECIMAL(9,6);
	DEFINE tasaMoratorios DECIMAL(9,6);
	DEFINE montoSbc DECIMAL(14,2);
	DEFINE capVig DECIMAL(18,2);
	DEFINE capTrans DECIMAL(18,2);
	DEFINE capVdoExig DECIMAL(18,2);
	DEFINE capVdoNoExig DECIMAL(18,2);
	DEFINE sdoActTotalCap DECIMAL(18,2);
	DEFINE intVig DECIMAL(18,2);
	DEFINE intVdo DECIMAL(18,2);
	DEFINE intMoratorios DECIMAL(18,2);
	DEFINE intMes DECIMAL(18,2);
	DEFINE sdoActTotalInt DECIMAL(18,2);
	DEFINE ivaIntVig DECIMAL(18,2);
	DEFINE ivaIntVdo DECIMAL(18,2);
	DEFINE ivaIntMoratorios DECIMAL(18,2);
	DEFINE ivaIntMes DECIMAL(18,2);
	DEFINE sdoActTotalIva DECIMAL(18,2);
	DEFINE comPend DECIMAL(18,2);
	DEFINE ivaCom DECIMAL(18,2);
	DEFINE sdoRetenido DECIMAL(18,2);
	DEFINE totalLiquidacion DECIMAL(18,2);
	DEFINE intDevengado DECIMAL(18,2);
	DEFINE ivaIntDevengado DECIMAL(18,2);
	DEFINE lineaDisponible DECIMAL(18,2);
	DEFINE pagosVdos DECIMAL(18,2);
	DEFINE descStatusCred CHAR(60);
	DEFINE idBloqueoCred INTEGER;
	DEFINE bloqueoCta CHAR(60);
	DEFINE idCausaBloqueoCred CHAR(3);
	DEFINE causaBloqueoCta CHAR(50);
	DEFINE idSitEspEte CHAR(1);
	DEFINE idCausaEspCte INTEGER;
	DEFINE sitEspCte CHAR(75);
	DEFINE idSitEspCred CHAR(1);
	DEFINE idCausaEspCred INTEGER;
	DEFINE sitEspCred CHAR(75);
	DEFINE dFechCartVendida DATE;

	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET mensajeRetorno = '';
	LET numeroCredito = NULL;
	LET codigoTipcred = NULL;
	LET fechaOrigen = NULL;
	LET fechaProxPago = NULL;
	LET pagoMinimo = NULL;
	LET fechaUltPago = NULL;
	LET plazo = NULL;
	LET pagosRealizados = NULL;
	LET lineaOtorgada = NULL;
	LET tasaInteres = NULL;
	LET tasaMoratorios = NULL;
	LET montoSbc = NULL;
	LET capVig = NULL;
	LET capTrans = NULL;
	LET capVdoExig = NULL;
	LET capVdoNoExig = NULL;
	LET sdoActTotalCap = NULL;
	LET intVig = NULL;
	LET intVdo = NULL;
	LET intMoratorios = NULL;
	LET intMes = NULL;
	LET sdoActTotalInt = NULL;
	LET ivaIntVig = NULL;
	LET ivaIntVdo = NULL;
	LET ivaIntMoratorios = NULL;
	LET ivaIntMes = NULL;
	LET sdoActTotalIva = NULL;
	LET comPend = NULL;
	LET ivaCom = NULL;
	LET sdoRetenido = NULL;
	LET totalLiquidacion = NULL;
	LET intDevengado = NULL;
	LET ivaIntDevengado = NULL;
	LET lineaDisponible = NULL;
	LET pagosVdos = NULL;
	LET descStatusCred = NULL;
	LET idBloqueoCred = NULL;
	LET bloqueoCta = NULL;
	LET idCausaBloqueoCred = NULL;
	LET causaBloqueoCta = NULL;
	LET idSitEspEte = NULL;
	LET idCausaEspCte = NULL;
	LET sitEspCte = NULL;
	LET idSitEspCred = NULL;
	LET idCausaEspCred = NULL;
	LET sitEspCred = NULL;
	LET dFechCartVendida = NULL;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, numeroCredito, codigoTipcred, fechaOrigen, fechaProxPago, pagoMinimo,
				fechaUltPago, plazo, pagosRealizados, lineaOtorgada, tasaInteres, tasaMoratorios, montoSbc, capVig, capTrans, capVdoExig, capVdoNoExig, 
				sdoActTotalCap, intVig, intVdo, intMoratorios, intMes, sdoActTotalInt, ivaIntVig, ivaIntVdo, ivaIntMoratorios, ivaIntMes, sdoActTotalIva,
				comPend, ivaCom, sdoRetenido, totalLiquidacion, intDevengado, ivaIntDevengado, lineaDisponible, pagosVdos, descStatusCred, idBloqueoCred,
				bloqueoCta, idCausaBloqueoCred, causaBloqueoCta, idSitEspEte, idCausaEspCte, sitEspCte, idSitEspCred, idCausaEspCred, sitEspCred, dFechCartVendida;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_saldos_general_cre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumeroCredito = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, numeroCredito, codigoTipcred, fechaOrigen, fechaProxPago, pagoMinimo,
				fechaUltPago, plazo, pagosRealizados, lineaOtorgada, tasaInteres, tasaMoratorios, montoSbc, capVig, capTrans, capVdoExig, capVdoNoExig, 
				sdoActTotalCap, intVig, intVdo, intMoratorios, intMes, sdoActTotalInt, ivaIntVig, ivaIntVdo, ivaIntMoratorios, ivaIntMes, sdoActTotalIva,
				comPend, ivaCom, sdoRetenido, totalLiquidacion, intDevengado, ivaIntDevengado, lineaDisponible, pagosVdos, descStatusCred, idBloqueoCred,
				bloqueoCta, idCausaBloqueoCred, causaBloqueoCta, idSitEspEte, idCausaEspCte, sitEspCte, idSitEspCred, idCausaEspCred, sitEspCred, dFechCartVendida;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, numeroCredito, codigoTipcred, fechaOrigen, fechaProxPago, pagoMinimo,
				fechaUltPago, plazo, pagosRealizados, lineaOtorgada, tasaInteres, tasaMoratorios, montoSbc, capVig, capTrans, capVdoExig, capVdoNoExig, 
				sdoActTotalCap, intVig, intVdo, intMoratorios, intMes, sdoActTotalInt, ivaIntVig, ivaIntVdo, ivaIntMoratorios, ivaIntMes, sdoActTotalIva,
				comPend, ivaCom, sdoRetenido, totalLiquidacion, intDevengado, ivaIntDevengado, lineaDisponible, pagosVdos, descStatusCred, idBloqueoCred,
				bloqueoCta, idCausaBloqueoCred, causaBloqueoCta, idSitEspEte, idCausaEspCte, sitEspCte, idSitEspCred, idCausaEspCred, sitEspCred, dFechCartVendida;
		END IF;
		
		EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(cEmpresa, pNumeroCredito)
		INTO cCodRetSp, mensajeRetorno, numeroCredito, codigoTipcred, fechaOrigen, fechaProxPago, pagoMinimo,
			fechaUltPago, plazo, pagosRealizados, lineaOtorgada, tasaInteres, tasaMoratorios, montoSbc, capVig, capTrans, capVdoExig, capVdoNoExig, 
			sdoActTotalCap, intVig, intVdo, intMoratorios, intMes, sdoActTotalInt, ivaIntVig, ivaIntVdo, ivaIntMoratorios, ivaIntMes, sdoActTotalIva,
			comPend, ivaCom, sdoRetenido, totalLiquidacion, intDevengado, ivaIntDevengado, lineaDisponible, pagosVdos, descStatusCred, idBloqueoCred,
			bloqueoCta, idCausaBloqueoCred, causaBloqueoCta, idSitEspEte, idCausaEspCte, sitEspCte, idSitEspCred, idCausaEspCred, sitEspCred;
		
		IF cCodRetSp = '000001' THEN
			LET cCodRet = '00003'; -- Faltan parametros de entrada
		ELIF cCodRetSp = '000002' THEN	
			LET cCodRet = '00003';
		ELIF cCodRetSp = '000003' THEN	
			LET cCodRet = '00009'; -- El numero de credito no existe
		ELIF cCodRetSp = '000004' THEN	
			LET cCodRet = '00009';
		ELIF cCodRetSp = '000005' THEN	
			LET cCodRet = '00208'; -- Ocurrio un errro al realizar el calculo
		ELIF cCodRetSp = '000006' THEN	
			LET cCodRet = '00209';
		ELIF cCodRetSp = '000000' THEN
			 FOREACH
				SELECT LIMIT 1 fecha INTO dFechCartVendida FROM bdicred:sd_maecred_vendida WHERE num_credito  = pNumeroCredito
				UNION
				SELECT fecha FROM bdicred:sd_maecredcrd_vendida WHERE num_credito  = pNumeroCredito
			END FOREACH;
		END IF;
		
		RETURN cCodRet, numeroCredito, codigoTipcred, fechaOrigen, fechaProxPago, pagoMinimo,
				fechaUltPago, plazo, pagosRealizados, lineaOtorgada, tasaInteres, tasaMoratorios, montoSbc, capVig, capTrans, capVdoExig, capVdoNoExig, 
				sdoActTotalCap, intVig, intVdo, intMoratorios, intMes, sdoActTotalInt, ivaIntVig, ivaIntVdo, ivaIntMoratorios, ivaIntMes, sdoActTotalIva,
				comPend, ivaCom, sdoRetenido, totalLiquidacion, intDevengado, ivaIntDevengado, lineaDisponible, pagosVdos, descStatusCred, idBloqueoCred,
				bloqueoCta, idCausaBloqueoCred, causaBloqueoCta, idSitEspEte, idCausaEspCte, sitEspCte, idSitEspCred, idCausaEspCred, sitEspCred, dFechCartVendida;
	
	END;
	
END PROCEDURE;