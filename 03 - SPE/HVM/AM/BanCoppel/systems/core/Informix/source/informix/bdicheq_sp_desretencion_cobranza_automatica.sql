CREATE PROCEDURE "informix".sp_desretencion_cobranza_automatica(
    pNumeroCliente CHAR(20),           -- Numero de cliente
    pCuentaCaptacion CHAR(20),         -- Numero de cuenta de captacion.
    pMontoDesretener MONEY(14,2)       -- Monto a des retener. 
)
RETURNING CHAR(5), 
          CHAR(150);

-- Declaracion de variables
--Variables de retorno
DEFINE cCodRet             	CHAR(5);            -- Codigo de retorno del SP
DEFINE cMensajeRet         	CHAR(150);          -- Mensaje de retorno del SP
--Variables de manejo de excepciones
DEFINE iSQLError           	INTEGER;            -- Variable de codigo SQL
DEFINE iISAMError          	INTEGER;            -- Variable de codigo ISAM
--Variables de obtencion de datos de la cuenta
DEFINE mSdoActual          	MONEY(14,2);        --Variable del saldo actual de la cuenta
DEFINE mSaldoSBC			MONEY(14,2);        --Variable del saldo salvo buen cobro (saldo inmovilizado)
DEFINE dFechaProceso       	DATE;               -- Fecha de proceso de la cuenta de captacion
DEFINE mMontoRetenido      	MONEY(14,2);        -- Monto registrado en la tabla de control
--Variable para la obtencion de la fecha del sistema
DEFINE dFechaHoy           	DATE;               -- Fecha del sistema
--Variables para el registro en la tabla de movimientos del dia del sistema de cheques
DEFINE cEmpresa            	CHAR(3);            -- Codigo de empresa
DEFINE cFolioSuc           	CHAR(16);           -- Folio suc del movimiento
DEFINE cSucursal		   	CHAR(4);			   -- Variable para el numero de sucursal del movimiento		
DEFINE dFechHor            	DATETIME HOUR TO FRACTION(3); -- Hora de la operacion
DEFINE cTransacc           	CHAR(4);            -- Numero de la transaccion
DEFINE cSucCuen            	CHAR(4);            -- Sucursal de la cuenta
DEFINE cProducto           	CHAR(4);            -- Numero de producto de la cuenta
DEFINE cTransaccSuc        	CHAR(4);            -- Transaccion de la Sucursal
DEFINE cEstatus            	INTEGER;            -- Estatus del registro en la tabla de control
DEFINE cReferencia         	CHAR(40);           -- Referencia del movimiento
DEFINE cStatusCta          	CHAR(1);            -- Estatus de la cuenta de captacion (1, 4 y 5 son validos)
DEFINE cUsuAutoriza        	CHAR(8);            -- Usuario del sistema que autoriza la operacion

DEFINE cCodParamTransacc   CHAR(20);           -- Codigo del parametro de transaccion
DEFINE cPrefijoFolioSuc    CHAR(6);           -- Prefijo del folio suc

--Declaracion de archivo de debuggeo
--SET DEBUG FILE TO "/home/c90402536/cobranza/sp_desretencion_cobranza_automatica.out";
--TRACE ON;

-- Inicializacion de variables
LET cCodRet                     = '00000';
LET cMensajeRet                 = 'Proceso de des retencion finalizado exitosamente';
LET iSQLError                   = 0;
LET iISAMError                  = 0;
LET mSdoActual          	    = 0.00;
LET mMontoRetenido              = 0.00;
LET mSaldoSBC					= 0.00;
LET dFechaProceso               = TODAY;
LET cStatusCta                  ='1';
LET dFechaHoy                   = TODAY;

LET cEmpresa                    = '001';
LET cSucursal				    ='9290';
LET cFolioSuc                   = '';
LET dFechHor                    = CURRENT HOUR TO FRACTION;
LET cTransacc                   = '';
LET cSucCuen                    = '';  
LET cProducto                   = ''; 
LET cTransaccSuc                ='0000';
LET cEstatus                    =0;
LET cReferencia                 = 'DESINMOVILIZA PARA COBRO AUTOMATICO';
LET cUsuAutoriza                = 'informix';

LET cCodParamTransacc           = 'TRANDESRETCOBAUTO';
LET cPrefijoFolioSuc            = 'desret';


BEGIN

    -- Manejo de excepciones
   ON EXCEPTION SET iSQLError, iISAMError, cMensajeRet
        IF iSQLError <> 0 THEN
             LET cCodRet = iSQLError;
             ROLLBACK WORK;
        END IF;
        RETURN cCodRet, cMensajeRet;
    END EXCEPTION;


    -- Directivas para nivel de lectura y tiempo de bloqueo
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

      -- Validacion de valores nulos o vacios
    IF (pNumeroCliente = '' OR pNumeroCliente IS NULL) OR
       (pCuentaCaptacion = '' OR pCuentaCaptacion IS NULL) THEN
        LET cCodRet = '00001';
        LET cMensajeRet = 'El valor de algun parametro de entrada es nulo, vacio o invalido.';
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- Validacion del monto a des retener
    IF pMontoDesretener <= 0.00 OR pMontoDesretener IS NULL THEN
        LET cCodRet = '00002';
        LET cMensajeRet = 'El monto a des retener debe ser mayor que 0.00 y no debe ser nulo.';
        RETURN cCodRet, cMensajeRet;
    END IF;


    -- Validar que exista un registro en la tabla de control con los numeros de cuenta proporcionados y en estatus 2
    SELECT estatus, monto_retenido
    INTO cEstatus, mMontoRetenido 
    FROM bdicheq:sc_control_cobranza_automatica
    WHERE cuenta_captacion = pCuentaCaptacion
    AND numero_cliente = pNumeroCliente;

    IF cEstatus <> '2' OR cEstatus IS NULL THEN
        LET cCodRet = '00003';
        LET cMensajeRet = 'No existe un registro valido en la tabla de control para la cuenta proporcionada.';
        RETURN cCodRet, cMensajeRet;
    END IF;

    --Obtencion de datos y saldos de la cuenta
	SELECT sucursal,producto, sdo_actual,saldo_sbc,fecha_proceso 
	INTO cSucCuen,cProducto,mSdoActual,mSaldoSBC,dFechaProceso 
	FROM sc_maechq
	WHERE cuenta = pCuentaCaptacion
    AND num_cte = pNumeroCliente;
		
	--Obtencion de la transaccion para la retencion
	SELECT valor INTO cTransacc FROM sc_param WHERE codparam = cCodParamTransacc;
			
    -- Validar que el saldo inmovilizado sea mayor o igual al monto proporcionado
    IF pMontoDesretener > mMontoRetenido THEN 
        LET cCodRet = '00004';
        LET cMensajeRet = 'El saldo que se desea desinmovilizar es diferente a lo permitido (desinmovilizado previamente).';
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- Validar que la cuenta este en un estatus valido (1, 4 o 5)
    IF cStatusCta NOT IN ('1', '4', '5') THEN
        LET cCodRet = '00005';
        LET cMensajeRet = 'La cuenta de captacion no tiene un estatus valido (debe ser 1 Activa, 4 Inactiva o 5 Informada).';
        RETURN cCodRet, cMensajeRet;
    END IF;

    --Obtencion de fechas de sistema
	SELECT fecha_hoy INTO dFechaHoy 
	FROM bdicheq:sc_fechas 
	WHERE empresa = cEmpresa;

    -- Realizar la des inmovilizacion del saldo en la cuenta de captacion
    UPDATE sc_maechq SET 
        saldo_sbc = mSaldoSBC - pMontoDesretener,
        fec_ult_mov = dFechaHoy
    WHERE cuenta = pCuentaCaptacion;

	--Armado del Folio_suc
	LET cFolioSuc = cPrefijoFolioSuc||LPAD(MONTH(CURRENT::DATE),2,0)||LPAD(DAY(CURRENT::DATE),2,0)||SUBSTR(TRIM(REPLACE(CURRENT::DATETIME HOUR TO FRACTION, ':', '')),1,6);
	
    -- Insercion del movimiento de dia con la transaccion de des inmovilizacion
    INSERT INTO sc_movdia VALUES
    (0, cFolioSuc, cSucursal, cUsuAutoriza, dFechaHoy, dFechaHoy, dFechHor, cTransacc, cSucCuen, cProducto, cEmpresa, pCuentaCaptacion, "", 0, pMontoDesretener, pMontoDesretener, 0.00, 
    0.00, 0, "", cStatusCta, mSdoActual, cTransaccSuc, cReferencia, 0, "", cUsuAutoriza, "", dFechaProceso);


    --Finalizacion del proceso
    RETURN cCodRet, cMensajeRet;

    END;
END PROCEDURE;