CREATE PROCEDURE "informix".sp_proyecta_credisoluciones_web(
pSucursal 		CHAR(4),
pNumPromocion 	SMALLINT, -- 1-efectivo, 2-compras, 3-saldos
pSaldoDisp		DECIMAL(18,2),
pMonto 			DECIMAL(18,2),
pPlazo 			SMALLINT
)

RETURNING  CHAR(5)          AS Codigo, 		  -- CODIGO DE RETORNO
            INTEGER         AS Periodo,       -- PERIODO ACTUAL
            DATE            AS FechaCouta,	  -- FECHA DEL PAGO
            DECIMAL(18,2)   AS SaldoInicial,  -- SALDO INICIAL
            DECIMAL(18,2)   AS Mensualidad,	  -- MENSUALIDAD
            DECIMAL(18,2)   AS Intereses,	  -- INTERESES
            DECIMAL(18,2)   AS IvaInteres,	  -- IVA DE INTERESES
            DECIMAL(18,2)   AS Capital,		  -- CAPITAL
            DECIMAL(18,2)   AS ComisionTotal,	  -- COMISION POR DISPOSICION
            SMALLINT        AS DiasPeriodo,	  -- DIAS DEL PERIODO
            DATE            AS FechaAper,	  -- FECHA DE APERTURA
			CHAR(3)         AS NumMesesPago;  -- NUMERO DE MESES

	---DECLARACIONES
    DEFINE iSqlErr				INTEGER;
    DEFINE iIsamErr				INTEGER;
    DEFINE cErrorInfo			CHAR(80);
    DEFINE cCodRet				CHAR(5);
    DEFINE cMensajeRet			CHAR(80);
	DEFINE dFactorIvaSucursal	DECIMAL(5,3);
	DEFINE dComisDisposicion	DECIMAL(18,6);
	DEFINE dIvaComision			DECIMAL(18,6);
	DEFINE dFactorComDispEfect	DECIMAL(18,6);
	DEFINE cCodComDispEfectivo	CHAR(4);
	DEFINE dValorMinDiferir		DECIMAL(18,6);
	DEFINE dComisionTotal       DECIMAL(18,6);
	DEFINE dTotalPagar			DECIMAL(18,6);
	DEFINE dFechaAper           DATE;
	DEFINE mSdoInicial        DECIMAL(18,6);
	DEFINE mSdoFinal          DECIMAL(18,6);
	DEFINE mMensualidad  	DECIMAL(18,6);
	DEFINE mMensualidad2 	DECIMAL(18,6);
	DEFINE mIntereses       DECIMAL(18,6);
	DEFINE mPeriodo		    INTEGER;
	DEFINE dFechaCouta      DATE;
	DEFINE mIvaInt			DECIMAL(18,6);
	DEFINE mCapital			DECIMAL(18,6);	
	DEFINE sDiasPeriodo		SMALLINT;
	DEFINE Contador         INTEGER;	
	
	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '00000';
	LET cMensajeRet			= 'PROCESO EXITOSO';
	LET dFactorIvaSucursal	= 0.0;
	LET dComisDisposicion	= 0.0;
	LET dIvaComision		= 0.0;
	LET dFactorComDispEfect	= 0.0;
	LET cCodComDispEfectivo	= '';
	LET dValorMinDiferir	= 0.0;
	LET dComisionTotal      = 0.0;
	LET dTotalPagar			= 0.0;
	LET dFechaAper          = DATE(1);
	LET mSdoInicial         = 0.0;
	LET mSdoFinal           = 0;
	LET mMensualidad  	    = 0.0; 
	LET mMensualidad2       = 0.0;
	LET mIntereses		= 0.0;
	LET mIvaInt			= 0.0;
	LET mCapital		= 0.0;	
	LET mPeriodo 			= 0;	
	LET dFechaCouta         = DATE(1);
	LET sDiasPeriodo		= 0;
	LET Contador            = 0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, dComisionTotal, sDiasPeriodo, dFechaAper, pPlazo;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/Malena/sp_proyecta_credisoluciones.out';
	--TRACE ON;

	-- OBTIENE EL VALOR MINIMO CONTEMPLADO PARA EL MONTO A DIFERIR EN LAS PROMOCIONES DE CREDISOLUCION
	SELECT TRIM(valor)::DECIMAL(18,2)
	INTO dValorMinDiferir
	FROM bdicred:"informix".sd_param
	WHERE cod_param  = '029';
	-- VALIDA QUE EL MONTO A DIFERIR SEA MAYOR AL VALOR MINIMO DE LA PROMOCION 
	IF pMonto < dValorMinDiferir THEN
		LET cCodRet = '00016';
		LET cMensajeRet = 'EL MONTO A DIFERIR ES MENOR AL MONTO MINIMO PERMITIDO ';		
	ELSE 
		-- VALIDA QUE LA SUCURSAL EXISTA Y ADEMAS OBTIENE EL IVA
		SELECT iva
		INTO dFactorIvaSucursal
		FROM bdinteg:"informix".si_sucursales
		WHERE sucursal = pSucursal;
					
		--SI EL FACTOR DEL IVA DE SUCURSAL ES IGUAL A 0 SE ASIGNA EL VALOR 0.16 POR DEFAULT
		IF dFactorIvaSucursal = 0 THEN
			LET dFactorIvaSucursal = 0.16;
		END IF;
			
		-- VALIDA SI SE TRATA DE PROMOCION DE EFECTIVO
		IF pNumPromocion = 1 THEN
			-- OBTIENE EL CODIGO PARA LA COMISION DE LA DISPOSICION DE EFECTIVO
			SELECT TRIM(valor)::CHAR(4)
			INTO cCodComDispEfectivo
			FROM bdicred:"informix".sd_param
			WHERE cod_param  = '334';
			IF NVL(cCodComDispEfectivo,'') = '' THEN
				LET cCodRet = '00017';
				LET cMensajeRet = 'ERROR AL OBTENER EL PARAMETRO DEL CODIGO DE LA COMISION DE DISP. DE EFECTIVO';
			ELSE 
			-- OBTIENE EL FACTOR PARA LA COMISION DE LA DISPOSICION DE EFECTIVO
				SELECT apli_factor
				INTO dFactorComDispEfect
				FROM bdicred:"informix".sd_tpcomis
				WHERE cod_comis = cCodComDispEfectivo;
				IF NVL(dFactorComDispEfect,0.0) = 0.0 THEN
					LET cCodRet = '00018';
					LET cMensajeRet = 'ERROR AL OBTENER EL PARAMETRO DEL FACTOR DE LA COMISION DE DISP. DE EFECTIVO';
				ELSE 								
					-- CALCULA LA COMISION POR LA DISPOSICION
					LET dComisDisposicion = pMonto * (dFactorComDispEfect/100);
					-- CALCULA EL IVA DE LA COMISION
					LET dIvaComision = dComisDisposicion * dFactorIvaSucursal;
					-- CALCULA LA COMISION TOTAL
					LET dComisionTotal= dComisDisposicion + dIvaComision;								
				END IF;						
			END IF;
		END IF;	
		LET Contador = 0;
		LET mSdoInicial = 0;

		FOREACH                
			EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(pMonto,pPlazo::INTEGER,0,'6900',pSucursal,1,0,'',null,1,pNumPromocion::INTEGER) 
			INTO cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad2, mIntereses, mIvaInt,mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, pPlazo
			LET dTotalPagar = dTotalPagar + mMensualidad2;
		END FOREACH;			
		IF pSaldoDisp <= dTotalPagar THEN
			IF pPlazo = 6 THEN
				LET cCodRet = '00019';
				LET cMensajeRet = 'NO CUENTA CON SALDO SUFICIENTE PARA CONTRATAR';
			ELSE
				LET cCodRet = '00019';
				LET cMensajeRet = 'NO CUENTA CON SALDO SUFICIENTE PARA CONTRATAR, POR FAVOR INTENTE POR UN PLAZO O MONTO DIFERENTE';
			END IF;
		END IF;		
		IF cCodRet = '00000' THEN 
		-- RQM 10 452 AAME 20150610 se solicita cambiar la forma de obtener las mensualidades de una credisolucion.
			LET Contador = 0;
			LET mSdoInicial = 0;

			FOREACH                

				EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(pMonto,pPlazo::INTEGER,0,'6900',pSucursal,1,0,'',null,1,pNumPromocion::INTEGER) 
				INTO cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad2, mIntereses, mIvaInt,mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, pPlazo

				LET Contador = Contador + 1;

				IF Contador = 1 THEN

					LET mMensualidad = mMensualidad2;

				END IF;

				LET dTotalPagar = dTotalPagar + mMensualidad2;
				
				RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad2, mIntereses, mIvaInt, mCapital, dComisionTotal, sDiasPeriodo, dFechaAper, pPlazo WITH RESUME;

			END FOREACH;
	
		END IF;
	END IF;
	IF Contador=0 THEN
		RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, ROUND(mMensualidad2,2), mIntereses, mIvaInt, mCapital, dComisionTotal, sDiasPeriodo, dFechaAper, pPlazo;		
	END IF;
END
END PROCEDURE
DOCUMENT 
'DESCRIPCION: Realiza el desglose de la proyecciÃ³n para credisoluciones ',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 15/Octubre/2013',
'BD    : BDICRED',
'Version: 20131015.1614';

CREATE PROCEDURE "informix".sp_actualiza_lincred_central_masivo(P_empresa CHAR(3), P_num_credito CHAR(20), Pmonto DECIMAL(18,2) , Ptipo CHAR(1),Pstatus CHAR(1),Pusuario CHAR(20))
              
RETURNING CHAR(6),
          VARCHAR(80);  
--Héctor Manuel Bojórquez Ruelas
--08  DE Junio DE 2011
--actualiza la linea de credito central y genera un movimiento en la movdia, así como tambien genera un registro del crédito en sd_bitacora_aumlincred y en  sd_autorizacion_aumlincred
--Folio 1258-BitácoraIncrementoLinCred

		  
--Roque Enrique Solis Campaña 
--20  DE DICIEMBRE DE 2008
--actualiza la linea de credito central y genera un movimiento en la movdia 
--19 DE FEBRERO DE 2009
--El movimiento se genera con la cantidad la diferencia del monto actual y el monto nuevo


--Modificación	  
--Juan Daniel Lazalde Centeno
--12  DE FEBRERO DE 2014
--Identificar si el usuario, que esta realizando la operación esta registrado en la tabla bdicred:sd_perfiles_cac_aumlincred y ponga en el campo roigen = "S" Sucursal 
--*************************************************************************
--                         DEFINICION DE VARIABLES
--*************************************************************************
DEFINE scod_ret 		CHAR(6);
DEFINE cCod_ret 		CHAR(6);
DEFINE vsqlerr 			INTEGER;

DEFINE c_num_producto 	CHAR(4);
DEFINE c_divisa 		CHAR(2);
DEFINE c_sucursal 		CHAR(4);
DEFINE d_fecha_hoy 		DATE;
DEFINE c_transacc_suc 	CHAR(4);
DEFINE c_folio_suc 		VARCHAR(20);
DEFINE p_cod_ret 		VARCHAR(10);
DEFINE p_mensaje 		VARCHAR(80);
DEFINE d_hora           DATETIME HOUR TO SECOND;
DEFINE cDif			    CHAR (1);
DEFINE mMontoanterior   DECIMAL(18,2);
DEFINE cNum_cte         CHAR(20);
DEFINE cNombre_cte      CHAR(100);
DEFINE mMontoMov        DECIMAL(18,2);
DEFINE mMontoDif        DECIMAL(18,2);
DEFINE v_nombre_usuario CHAR(100);
DEFINE cNumCte          CHAR(20);
DEFINE cGradoRiesgo     CHAR(2);
DEFINE dMontoReserva    DECIMAL(18,2);
DEFINE valorsm			DECIMAL(18,2);
DEFINE smblinsug		DECIMAL(18,2);
DEFINE cCalifBuro       CHAR(1);
DEFINE cMotivoRechazo   CHAR(255);
DEFINE cCompromiso      DECIMAL(14,2);
DEFINE iReg             INTEGER;
DEFINE cOrigen          CHAR(1);


-- *************************************************************************
-- *                        ASIGNACION DE VARIABLES
-- **************************************************************************

LET scod_ret		 = "000000";
LET cCod_ret		 = "000000";
LET vsqlerr			 = 0;
LET c_num_producto	 ="";
LET c_divisa		 ="";
LET c_sucursal		 ="";
LET d_fecha_hoy		 = DATE(1);
LET c_transacc_suc	 ="";
LET c_folio_suc		 ="";
LET p_cod_ret		 ="";
LET p_mensaje		 =""; 	
LET d_hora           = CURRENT HOUR TO SECOND;
LET cDif			 ="";
LET mMontoanterior	 = 0;
LET cNum_cte		 ="";
LET cNombre_cte		 ="";
LET mMontoMov 	     = 0;
LET mMontoDif        = 0;
LET v_nombre_usuario = "";
LET cNumCte          = "";
LET cGradoRiesgo     = "";
LET dMontoReserva    = 0;
LET valorsm			 = 0;
LET smblinsug	     = 0;
LET cCalifBuro       = ""; 
LET cMotivoRechazo   = "";
LET cCompromiso      = 0;
LET cOrigen          = "";

-- **********************************************************************
-- *                        CONTROL DE ERRORES
-- ***********************************************************************
BEGIN
    ON EXCEPTION SET vsqlerr
       IF vsqlerr != 0 THEN
          LET scod_ret=vsqlerr;
		  ROLLBACK WORK;
          RETURN scod_ret, p_mensaje ;
       END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/respaldosbd/hectorb/actualiza_lincred.out";
	--TRACE ON;

    -- **********************************************************************
    -- *                        PROGRAMA PRINCIPAL
    -- **********************************************************************
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    SELECT monto_otorgado
    INTO mMontoanterior
    FROM "informix".sd_maesdos 
    where num_credito=P_num_credito;

	IF (mMontoanterior is not null) THEN
	   
--	   EXECUTE PROCEDURE bdicred:"informix".sp_consultacredito_central( P_empresa, P_num_credito) INTO p_cod_ret, p_mensaje, cNum_cte,cNombre_cte,mMontoanterior ;
        
		UPDATE "informix".sd_maesdos
		SET monto_otorgado=Pmonto
		WHERE empresa=P_empresa AND num_credito=P_num_credito;
		
		SELECT num_producto, sucursal , divisa, numcte 
		INTO   c_num_producto, c_sucursal, c_divisa, cNum_cte
		FROM   "informix".sd_maecred
		WHERE  empresa     = P_empresa
		AND    num_credito = P_num_credito;

		--Obtener la fecha del dia	
		SELECT fecha_hoy
		INTO   d_fecha_hoy
		FROM   "informix".sd_fechas
		WHERE  empresa = P_empresa;
        
		-- obtener el valor del salario minimo de la zona C
		SELECT valor 
		INTO valorsm
		FROM "informix".sd_param 
		WHERE empresa   = P_empresa 
		AND cod_param = '013';
		
		
		SELECT grado_riesgo,NVL(reserva_calificacion,0.00)
		INTO cGradoRiesgo, dMontoReserva
		FROM "informix".sd_hist_reserva
		WHERE  empresa     = P_empresa
		AND    num_credito = P_num_credito
		AND   fecha_cierre = (SELECT  MAX(fecha_cierre)
                    FROM "informix".sd_hist_reserva
                    WHERE  empresa     = P_empresa
                    AND    num_credito = P_num_credito);
		
		
	    LET  c_transacc_suc  = '0000';
		LET  c_folio_suc = 'Act LineaCredito';
        
        IF mMontoanterior < Pmonto THEN
		    LET cDif = '1';
            LET mMontoDif = Pmonto-mMontoanterior;
		ELSE
		    LET cDif = '2';
            LET mMontoDif = mMontoanterior-Pmonto;
		END IF;

		EXECUTE PROCEDURE "informix".GENMOV( P_empresa, P_num_credito
                                 , c_num_producto , cDif
                                 ,'008' , d_fecha_hoy
                                 , mMontoDif , c_folio_suc
                                 , c_sucursal, c_divisa
                                 , c_transacc_suc
                                 ) INTO p_cod_ret, p_mensaje;

		IF p_cod_ret::INTEGER > 0 THEN
			LET scod_ret= '000002'; 
			LET p_mensaje="Ocurrio un error al guardar los movimientos del credito en el SP bdicred:genmov";	   	
			RETURN scod_ret, p_mensaje;   
		END IF;

		LET smblinsug = Pmonto / (30.42 * valorsm);
				
		---Obtiene la  calificacion buro para actualizar el campo  califica_buro de la tabla sd_bitacora_aumlincred
		EXECUTE PROCEDURE bdisolic:"informix".cal_circulocredito_cjunk(P_empresa, cNum_cte, P_num_credito) 
		INTO  cCod_ret, 	    -- Codigo de Retorno
              cCalifBuro,	    -- Calificacion 1 Aprobado, 0 Rechazado
		      cCompromiso,      -- Compromisos > 0 si Calificacion es 1
		      cMotivoRechazo;   -- Descripcion de Creditos Motivo de Rechazo
		
		
		--Lazalde: Validar si el usuario existe en sd_perfiles_cac_aumlincred para identificar a que origen "SUCURSAL ó CENTRAL" se esta realizando el incremento de linea de crédito
		IF EXISTS(SELECT ejecutivo FROM "informix".sd_perfiles_cac_aumlincred where empresa = P_empresa AND ejecutivo = Pusuario) THEN
			LET cOrigen = 'S';
		ELSE
			LET cOrigen = 'C';
		END IF
		
		
		INSERT INTO "informix".sd_bitacora_aumlincred
		(empresa, num_solicitud,numcte,num_producto,status,causa_status,fecha_status,hora_status,sucursal,lincred_actual,lincred_sugerida,
		smb_lincred,grado_riesgo,monto_reserva,califica_buro,resp_cte,mensaje,ejecutivo,sucursal_at,origen,user_insert,fecha_insert)
		VALUES (P_empresa,P_num_credito,cNum_cte,'6001','AP','',d_fecha_hoy,d_hora,c_sucursal,mMontoanterior,Pmonto,smblinsug,
		cGradoRiesgo,dMontoReserva,cCalifBuro,'1',Ptipo, Pusuario,'0000',cOrigen,Pusuario,d_fecha_hoy);

		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET scod_ret = "000004";
			LET p_mensaje = "Ocurrio un error al guardar la información en la bitacora de aumento de linea de crédito";
			RETURN scod_ret, p_mensaje;   
		END IF;
		

		INSERT INTO "informix".sd_autorizacion_aumlincred 
		(empresa, num_solicitud, status,causa_status,user_insert,fecha_status,fecha_insert, revision_cac)     		
		VALUES(P_empresa,P_num_credito,'AP','',Pusuario,d_fecha_hoy,d_fecha_hoy,0);
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET scod_ret = "000005";
			LET p_mensaje = "Ocurrio un error al guardar la información en la bitacora de autorización de aumento de linea de crédito";
			RETURN scod_ret, p_mensaje;   
		END IF;

	ELSE
       LET scod_ret= '000001'; 
       LET p_mensaje="No es posible realizar la actualizacion";	   
	END IF
	

    RETURN scod_ret, p_mensaje;   
          
END;
END PROCEDURE;