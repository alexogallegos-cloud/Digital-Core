CREATE PROCEDURE "informix".sp_validahorariopitdc_testhmd()

 RETURNING
 CHAR(5), CHAR(5);

--DEFINICION DE VARIABLES
    DEFINE iSqlErr      INTEGER;
    DEFINE cCodRet1     CHAR (5);
	DEFINE cCodRet2     CHAR (5);
    DEFINE cHoraActual  CHAR (5);
    DEFINE cHoraAParam  CHAR (5);

--INICIALIZACION DE VARIABLES
    LET iSqlErr      = 0;
    LET cCodRet1     = "00000";
	LET cCodRet2     = "00000";
    LET cHoraActual  = "";
	LET cHoraAParam  = "";

    -- SET DEBUG FILE TO "/tmp/sp_ValidaHorarioPITDC.out";
    -- TRACE ON;


 BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
			RETURN cCodret1, cCodret2;
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
		
    SELECT (CURRENT HOUR TO MINUTE), NVL(valor,'')
    INTO cHoraActual, cHoraAParam
    FROM bdicheq:sc_param
    WHERE codparam = "HORAPITDC";
	
	
	IF cHoraActual = "" OR cHoraActual IS NULL OR cHoraAParam = "" OR cHoraAParam IS NULL THEN
	    LET cCodRet2 = "00001";
	ELSE
	    IF CAST(SUBSTR(cHoraActual,1,2) AS INTEGER) > CAST(SUBSTR(cHoraAParam,1,2) AS INTEGER) THEN
			LET cCodRet2 = "00002";  --Esta fuera del horario
		ELSE
			IF CAST(SUBSTR(cHoraActual,1,2)  AS INTEGER) = CAST(SUBSTR(cHoraAParam,1,2) AS INTEGER) THEN
	    					
				IF CAST(SUBSTR(cHoraActual,4,2) AS INTEGER) > CAST(SUBSTR(cHoraAParam,4,2) AS INTEGER) THEN
					LET cCodRet2 = "00002";  --Esta fuera del horario
				END IF;
			END IF;	
		END IF;	
	END IF;

    RETURN cCodret1, cCodret2;

 END;
END PROCEDURE
DOCUMENT
    'AUTOR : Jaime Gonzalez',
    'DESCRIPCION: Se encarga de validar si es un horario permitido para las operaciones de PITDC',
    'EJECUTADO O LLAMADO POR: abono_ref',
    'BD    : bdicheq';

CREATE PROCEDURE "informix".spsctransctaspropias23_testhmd(pEmpresa char(3),
                                                pSucursal char(4),
                                                pUsuario char(8),
                                                pTransCargo char(4),
                                                pTransAbono char(4),
                                                pTransSuc char(4),
                                                pFolioSuc char(16),
                                                pNumCtaOrigen char(12),
                                                pNumCtaDestino char(12),
                                                pCheque integer,
                                                pMonto money(14,2),
                                                pMoneda char(2),
                                                pReferencia char(40),
						pReferenciaBe char(40),
                                                pNumTarjetaOrigen char(16),
                                                pNumTarjetaDestino char(16),
                                                pUsuAutoriza char(8),
                                                pMontoTotal money(14,2),
                                                pMontoFirme money(14,2),
                                                pMontoSBC money(14,2),
                                                pMontoRem money(14,2),
                                                pDiasRet smallint,
                                                pDocto integer)
        RETURNING char(5), char(5);

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Transferencia entre cuentas propias
    -- Solicitó  : Diana Castellanos
    -- Fecha     :  20/05/2008
	--******************************************************
	-- Modificó		: Walber Castro
	-- Actividad	: Se agrega nuevo parámetro de entrada pReferenciaBe.
	-- Solicitó		: Pachín
	-- Fecha		: 25/01/2012
	--******************************************************
	-- Modificó		: Berenice Noriega
	-- Actividad	: Se agrega validación para saber si las cuentas pertenecen al mismo cliente.
	--                si es del mimo cliente envia la transaccion 0309, si no lo es envia 0239    
	-- Solicitó		: Alejandro vazquez
	-- Fecha		: 14/Julio/2014
	-- Base Datos	: bdicheq
	--******************************************************
	-- Modificó		: Berenice Noriega
	-- Actividad	: Se agrega validación para saber si las cuentas pertenecen al mismo cliente.
	--                si es del mismo cliente envia la transaccion de abono 0313, si no lo es, envia 0205    
	-- Solicitó		: Alejandro vazquez
	-- Fecha		: 25/Septiembre/2014
	-- Base Datos	: bdicheq		
	--******************************************************
    -- Modificó		: Nydia Payán
	-- Actividad	: Se agrega validación para Asignación y concatenación de Cuenta del Cargo y/o
    --                la Cuenta Abono, y la Referencia para el Estado de Cuenta    
	-- Solicitó		: Alejandro vazquez
	-- Fecha		: 04/Marzo/2015
	--******************************************************

	DEFINE vcodret   char(5);
       	DEFINE vcodretRev   char(5);
       	DEFINE sql_err   integer;
       	DEFINE vTrans    char(4);
	DEFINE vFechaHoy date;
	DEFINE vSdoDisp  money(14,2);
	DEFINE vMontoRet money(14,2);
	DEFINE vPasoCargo char(1);
	DEFINE vMensajeRet char(100);
	DEFINE vReferencia	char(40);
	DEFINE vTransCargo char(4);
	DEFINE vCliente1 CHAR(20);
	DEFINE vCuenta1 char(12);
	DEFINE vTransAbono CHAR(4);
    DEFINE cReferencia varchar(40);
    DEFINE aReferencia varchar(40);
	DEFINE vFechaProcesoOr date;
	DEFINE vFechaProcesoDe date;
	   
	LET vReferencia ='' ;
   	LET vTransCargo ='';
	  
	LET vCliente1 ='';
	LET vCuenta1 ='';
	LET vTransAbono='';
	   
BEGIN
ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        IF vPasoCargo = '1' THEN
            EXECUTE PROCEDURE bdicheq:"informix".reversion(pEmpresa,
                                        pSucursal,
                                        pUsuario,
                                        pFolioSuc,
                                        'A') INTO vcodretRev;
        END IF;
        IF vcodretRev = '000' THEN
            LET vcodretRev = '001';
        END IF;

        LET vcodret = sql_err;
        RETURN vcodret, vcodretRev;
       END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

LET vPasoCargo = '0';
LET vcodret = '000';
LET vcodretRev = '000';
LET vMensajeRet = '';

LET cReferencia = '';
LET aReferencia = '';

	/*IF pReferenciaBe  = '' THEN
		LET vReferencia = pReferencia;
    ELSE
		LET vReferencia = pReferenciaBe;
    END IF;*/

---Asignación y concatenación de Cuenta del Cargo/Abono y la Referencia para el Estado de Cuenta
LET cReferencia = TRIM(pNumCtaDestino) || ' ' || pReferencia; --cargo y la Referencia 
LET aReferencia = TRIM(pNumCtaOrigen) || ' ' || pReferenciaBe; --abono y la Referencia del Beneficiario


	EXECUTE PROCEDURE bdicheq:"informix".sp_validatransferencias_bpi(pEmpresa, pNumCtaOrigen, pNumCtaDestino)
    INTO vcodret, vMensajeRet ;
	--*********************************************************************--
	IF pTransCargo='0239' THEN
			
		select count(distinct num_cte), count(cuenta)
        into vCliente1, vCuenta1
        from bdicheq:"informix".sc_maechq
        where ( cuenta=pNumCtaOrigen  or cuenta=pNumCtaDestino)
        and empresa ='001';
		
	    IF vCliente1 = 1 AND vCuenta1 = 2 THEN
         	LET vTransCargo='0309';
			--**Cambia ID de Abono a **********--
				LET vTransAbono='0313';
                LET aReferencia = TRIM(pNumCtaOrigen) || ' ' || pReferencia;			
				
	--*********************************--
		ELSE	
			LET vTransCargo=pTransCargo;
			LET vTransAbono=pTransAbono;		

	    END IF
	
		
	END IF
	
	--********************Valida las Fechas procesos*************************************************--
	IF vcodret = '00000' THEN
		SELECT fecha_proceso INTO vFechaProcesoOr FROM bdicheq:sc_maechq WHERE cuenta = pNumCtaOrigen;
		SELECT fecha_proceso INTO vFechaProcesoDe FROM bdicheq:sc_maechq WHERE cuenta = pNumCtaDestino;
		
		IF (vFechaProcesoOr <> vFechaProcesoDe) THEN
			LET vcodret = '00001';
		END IF;
	END IF
	
	
    IF  vcodret = '00000'  THEN
            EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(pEmpresa,
                                        pSucursal,
                                        pUsuario,
                                        vTransCargo, --Envia 0309 si es entre cuentas del mismo cliente sino envia el de entrada 0239.
                                        pTransSuc,
                                        pFolioSuc,
                                        pNumCtaOrigen,
                                        pCheque,
                                        pMonto,
                                        pMoneda,
                                        cReferencia,
                                        pNumTarjetaOrigen,
                                        pUsuAutoriza) INTO vcodret,
                                                           vTrans,
                                                           vFechaHoy,
                                                           vSdoDisp,
                                                           vMontoRet;

            IF vcodret <> '000' THEN
                RETURN vcodret, vcodretRev;
            ELSE
                LET vPasoCargo = '1';
            END IF;

            EXECUTE PROCEDURE bdicheq:"informix".abono_ref(pEmpresa,
                                        pSucursal,
                                        pUsuario,
                                        vTransAbono, --Envia 0313 si es entre cuentas del mismo cliente sino envia el de entrada 0205.
                                        pTransSuc,
                                        pFolioSuc,
                                        pNumCtaDestino,
                                        pDocto,
                                        pMontoTotal,
                                        pMontoFirme,
                                        pMontoSBC,
                                        pMontoRem,
                                        pDiasRet,
                                        pMoneda,
                                        aReferencia,
                                        pNumTarjetaDestino,
                                        pUsuAutoriza) INTO vcodret;

            IF vcodret <> '000' THEN
                EXECUTE PROCEDURE bdicheq:"informix".reversion(pEmpresa,
                                            pSucursal,
                                            pUsuario,
                                            pFolioSuc,
                                            'A') INTO vcodretRev;
                IF vcodretRev = '000' THEN
                    LET vcodretRev = '001';
                END IF;
                RETURN vcodret, vcodretRev;
            END IF;
    ELSE
        RETURN vcodret, vcodretRev;
    END IF;

END;
RETURN vcodret, vcodretRev;
END PROCEDURE;