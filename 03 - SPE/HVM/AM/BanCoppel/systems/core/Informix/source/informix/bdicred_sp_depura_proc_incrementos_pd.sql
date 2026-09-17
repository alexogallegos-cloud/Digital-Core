CREATE PROCEDURE "informix".sp_depura_proc_incrementos_pd()
RETURNING CHAR(6);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE cCodRet					CHAR(6);
DEFINE vsqlerr					INTEGER;
DEFINE cEmpresa					CHAR(3);
DEFINE cNumCte             		CHAR(20);
DEFINE cNumCteExc             	CHAR(20);
DEFINE cCredito					CHAR(20);
DEFINE cCreditoExc				CHAR(20);
DEFINE dFechaApertExc			DATE;
DEFINE cMotvRechProc			CHAR(150);
DEFINE dFechaInsertExc			DATE;
DEFINE cNumProd					CHAR(4);
DEFINE cNumCel                  CHAR(13);
DEFINE sSecuencia				SMALLINT;
DEFINE sNumIncrementos		    SMALLINT;
DEFINE dFechaEval				DATE;
DEFINE dMontoLinea    		    DECIMAL(18,2);
DEFINE dNuevoMontoLinea         DECIMAL(18,2);
DEFINE cPorcenAumentoLinea      CHAR(7);
DEFINE dFechaIncremento			DATE;
DEFINE cIncrementoAuto          CHAR(2);
DEFINE cCanalNotiInvt           CHAR(10);
DEFINE cIdAtm          			CHAR(14);
DEFINE cAceptoIncremento     	CHAR(9);
DEFINE dFechaAutRech			DATE;
DEFINE cOfertIncLinea			CHAR(8);
DEFINE dFechaFinVigOfer			DATE;
DEFINE cObservacionOfert		CHAR(100);
DEFINE cFrecRecOfer				CHAR(3);
DEFINE dFechaProxRec			DATE;
DEFINE cStatusSms				CHAR(10);
DEFINE cCodRetSms				CHAR(6);
DEFINE iContador     			INTEGER;
DEFINE iContadorParam154     	INTEGER;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET cCodRet	                    = "000000";
LET vsqlerr						= 0;
LET cEmpresa					= '';
LET cNumCte                     = '';
LET cNumCteExc                  = '';
LET cCredito 					= '';
LET cCreditoExc 				= '';
LET dFechaApertExc 				= DATE(1);
LET cMotvRechProc 				= '';
LET dFechaInsertExc				= DATE(1);
LET cNumProd 					= '';
LET cNumCel             		= '';
LET sSecuencia                  = 0;
LET sNumIncrementos        	    = 0;
LET dFechaEval           	    = DATE(1);
LET dMontoLinea              	= 0;
LET dNuevoMontoLinea         	= 0;
LET cPorcenAumentoLinea 		= '';
LET dFechaIncremento			= DATE(1);
LET cIncrementoAuto		 		= '';
LET cCanalNotiInvt		 		= '';
LET cIdAtm				 		= '';
LET cAceptoIncremento         	= '';
LET dFechaAutRech				= DATE(1);
LET cOfertIncLinea	         	= '';
LET dFechaFinVigOfer			= DATE(1);
LET cObservacionOfert	        = '';
LET cFrecRecOfer		        = '';
LET dFechaProxRec				= DATE(1);
LET cStatusSms			        = '';
LET cCodRetSms			        = '';
LET iContador     				= 1;
LET iContadorParam154     		= 0;

BEGIN
	ON EXCEPTION SET vsqlerr
	   IF vsqlerr != 0 THEN
		  LET cCodRet=vsqlerr;
		  
		  RETURN cCodRet;
	   END IF;
	END EXCEPTION;
	
 	 --SET DEBUG FILE TO "/informix/sp_depura_proc_incrementos_pd.out";
	 --TRACE ON; 
	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
	--Obtenemos todos los valores a usar de la tabla bdicred:"informix".sd_param
	SELECT valor INTO iContadorParam154 FROM bdicred:"informix".sd_param WHERE cod_param = '154';

	--Depura tabla sd_incrementos_prestamos_digitales
	FOREACH WITH HOLD
		SELECT 		
		empresa,
		numcte,
		num_credito,
		num_producto,
		telefono,
		secuencia,
		numero_incrementos,
		fecha_evaluacion,
		linea_prestamo_anterior,
		linea_prestamo_actual,
		porcentaje_incremento_aplicado,
		fecha_incremento,
		incremento_automatico,
		canal_notificacion_invitacion,
		id_atm,
		respuesta_incremento,
		fecha_autorizo_o_rechazo, 
		oferta_incremento_linea,
		fecha_fin_vigencia_oferta,
		observacion_oferta,
		frec_recordatorio_oferta,
		fecha_prox_recordatorio,
		estatus_sms,
		cod_ret_sms
		INTO cEmpresa, 
			 cNumCte, 
			 cCredito, 
			 cNumProd, 
			 cNumCel, 
			 sSecuencia, 
			 sNumIncrementos,
			 dFechaEval,
			 dMontoLinea,
			 dNuevoMontoLinea,
			 cPorcenAumentoLinea,
			 dFechaIncremento,
			 cIncrementoAuto,
			 cCanalNotiInvt,
			 cIdAtm,
			 cAceptoIncremento,
			 dFechaAutRech,
			 cOfertIncLinea,
			 dFechaFinVigOfer,
			 cObservacionOfert,
			 cFrecRecOfer,
			 dFechaProxRec,
			 cStatusSms,
			 cCodRetSms
	FROM bdicred:"informix".sd_incrementos_prestamos_digitales

	IF iContador = 1 THEN       
		BEGIN WORK;
	END IF;

	INSERT INTO bdicred:"informix".sd_incrementos_prestamos_digitales_hist(
			empresa, 
			numcte, 
			num_credito, 
			num_producto, 
			telefono, 
			secuencia, 
			numero_incrementos, 
			fecha_evaluacion, 
			linea_prestamo_anterior, 
			linea_prestamo_actual, 
			porcentaje_incremento_aplicado, 
			fecha_incremento, 
			incremento_automatico, 
			canal_notificacion_invitacion, 
			id_atm, 
			respuesta_incremento, 
			fecha_autorizo_o_rechazo, 
			oferta_incremento_linea, 
			fecha_fin_vigencia_oferta, 
			observacion_oferta, 
			frec_recordatorio_oferta, 
			fecha_prox_recordatorio, 
			estatus_sms, 
			cod_ret_sms) 
	VALUES(cEmpresa, 
		   cNumCte, 
		   cCredito, 
		   cNumProd, 
		   cNumCel, 
		   sSecuencia, 
		   sNumIncrementos, 
		   dFechaEval, 
		   dMontoLinea, 
		   dNuevoMontoLinea, 
		   cPorcenAumentoLinea, 
		   dFechaIncremento, 
		   cIncrementoAuto, 
		   cCanalNotiInvt, 
		   cIdAtm, 
		   cAceptoIncremento, 
		   dFechaAutRech, 
		   cOfertIncLinea, 
		   dFechaFinVigOfer, 
		   cObservacionOfert, 
		   cFrecRecOfer, 
		   dFechaProxRec, 
		   cStatusSms, 
		   cCodRetSms);
												
		
	DELETE FROM bdicred:"informix".sd_incrementos_prestamos_digitales WHERE numcte = cNumCte AND num_credito = cCredito AND secuencia = sSecuencia;
	
	IF iContador = iContadorParam154 THEN               
		COMMIT WORK;
		LET iContador = 1;           
	ELSE
		LET iContador = iContador + 1;
	END IF;      
	
	END FOREACH;
	
	IF iContador > 1 THEN
		COMMIT WORK;
	END IF;
	
	--Depura tabla sd_excluidos_incrementos_prest_digital
	LET iContador = 1;
	
	FOREACH WITH HOLD
			SELECT 	
			numcte,
			num_credito,
			fecha_apertura,
			motivo_rechazo_proc,
			fecha_insert
			INTO 
			cNumCteExc,
			cCreditoExc,
			dFechaApertExc,
			cMotvRechProc,
			dFechaInsertExc
			FROM bdicred:"informix".sd_excluidos_incrementos_prest_digital
	
	IF iContador = 1 THEN       
		BEGIN WORK;
	END IF;
	
	INSERT INTO bdicred:"informix".sd_excluidos_incrementos_prest_digital_hist	
		(
			numcte,
			num_credito,
			fecha_apertura,
			motivo_rechazo_proc,
			fecha_insert
		) VALUES(
			cNumCteExc,
			cCreditoExc,
			dFechaApertExc,
			cMotvRechProc,
			dFechaInsertExc);
	
	DELETE FROM bdicred:"informix".sd_excluidos_incrementos_prest_digital WHERE numcte = cNumCteExc AND num_credito = cCreditoExc;
	
	IF iContador = iContadorParam154 THEN               
		COMMIT WORK;
		LET iContador = 1;           
	ELSE
		LET iContador = iContador + 1;
	END IF; 
	
	END FOREACH;
	
	IF iContador > 1 THEN
		COMMIT WORK;
	END IF;
	
END
RETURN cCodRet;

END PROCEDURE;