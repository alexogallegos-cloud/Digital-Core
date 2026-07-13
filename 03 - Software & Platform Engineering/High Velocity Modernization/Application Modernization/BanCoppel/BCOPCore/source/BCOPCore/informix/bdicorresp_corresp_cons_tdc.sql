CREATE PROCEDURE "informix".corresp_cons_tdc( pc_costos CHAR(4),      --- SUCURSAL
                                             pusuario CHAR(8),       --- USUARIO
                                             pfolio CHAR(16),        --- FOLIO SUC
                                             pnum_tarjeta CHAR(16),  --- TARJETA DE CREDITO
                                             pfecha CHAR(8),            --- FECHA
                                             preferencia CHAR(40) )  --- REFERENCIA
RETURNING CHAR(3),  --- CODIGO DE RETORNO
		  CHAR(4),  --- TERMINACION
          CHAR(53), --- NOMBRE CORTO DEL CLIENTE
          CHAR(16),  --- SALDO TOTAL
		  CHAR(16),  --- PAGO MINIMO
		  CHAR(16),  --- PAGO PARA NO GENERAR INTERESES
		  CHAR(10);  --- FECHA LIMITE DE PAGO

    DEFINE sql_err      	INTEGER;
    DEFINE isam_err     	INTEGER;
    DEFINE vcodret1     	CHAR(3);
    DEFINE vcodret2     	CHAR(5);
	DEFINE vtransaccion     SMALLINT;
	DEFINE vproceso         CHAR(1);
    
	DEFINE vstatus_tar      CHAR(1);
	DEFINE cTerminacion		CHAR(4);
	DEFINE cNombreCorto		CHAR(53);
	DEFINE cSdoTotal		CHAR(16);
	DEFINE cPagoMinimo		CHAR(16);
	DEFINE cPagoNoGenInt	CHAR(16);
	DEFINE cFecLimPago		CHAR(10);
	DEFINE cStatusCta		CHAR(1);
	DEFINE cStatusTar		CHAR(1);
	DEFINE cTranConsSdo		CHAR(4);
	DEFINE cHora            DATETIME HOUR TO FRACTION;
	DEFINE cNumCredito		CHAR(20);
	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_tdc_general
	DEFINE cgCodRet			CHAR(5);
	DEFINE cgTerminacion	CHAR(4);
	DEFINE cgNombreCte		CHAR(60);
	DEFINE cgSaldoTotal		DECIMAL(14,2);
	DEFINE cgPagoMinimo		DECIMAL(14,2);
	DEFINE cgPagoNoGenInt	DECIMAL(14,2);
	DEFINE cgFecLimPago		CHAR(10);
	DEFINE iSaldoTotal		INT8;
	DEFINE iPagoMinimo		INT8;
	DEFINE iPagoNoGenInt	INT8;

    
    LET sql_err  = 0;
    LET isam_err = 0;
    LET vcodret1 = '000';
    LET vcodret2 = '000';
	LET vtransaccion     = 0;
	LET vproceso        = '0';
	
	LET vstatus_tar      = '';
	LET cTerminacion	= "";
	LET cNombreCorto	= "";
	LET cSdoTotal		= "";
	LET cPagoMinimo		= "";
	LET cPagoNoGenInt	= "";
	LET cFecLimPago	= DATE(1);
	LET cStatusCta		= "";
	LET cStatusTar		= "";
	LET cTranConsSdo	= "";
	LET cHora        	= CURRENT HOUR TO FRACTION;
	LET cNumCredito		= "";
    
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_tdc_general
	LET cgCodRet		= "000";
	LET cgTerminacion	= "";
	LET cgNombreCte		= "";
	LET cgSaldoTotal	= 0.0;
	LET cgPagoMinimo	= 0.0;
	LET cgPagoNoGenInt	= 0.0;
	LET cgFecLimPago	= "";
	LET iSaldoTotal		= 0;
	LET iPagoMinimo		= 0;
	LET iPagoNoGenInt	= 0;

	
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_cons_tdc.out";
     --SET DEBUG FILE TO "/informix/moha/corresp_cons_tdc.out";
     --TRACE ON;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_cons_tdc.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            IF vproceso = '1' THEN
                LET vcodret1 = '000';
            ELSE
                LET vcodret1 = '999';
            END IF;
            RETURN vcodret1, cTerminacion, cNombreCorto, cSdoTotal, cPagoMinimo, cPagoNoGenInt, cFecLimPago;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH resume;

    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-- OBTIENE LA TRANSACCION CORRESPONDIENTE A LA CONSULTA
	SELECT TRIM(valor)
	INTO cTranConsSdo
	FROM bdicheq: "informix".sc_param
	WHERE empresa = "001"
	AND codparam = "conssdotdcbancv";    

    IF (pc_costos is null OR pc_costos = '') OR
       (pusuario is null OR pusuario = '' OR LENGTH(pusuario) <> 8) OR
       (pfolio is null OR pfolio = '' OR LENGTH(pfolio) <> 16) OR
       (pnum_tarjeta is null OR pnum_tarjeta = '' OR LENGTH(pnum_tarjeta) <> 16) OR
       (pfecha is null OR pfecha = '') OR
	   (preferencia is null OR preferencia = '') THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '110';
        RETURN vcodret1, cTerminacion, cNombreCorto, cSdoTotal, cPagoMinimo, cPagoNoGenInt, cFecLimPago;
    END IF;
       
    -- // VALIDA DATOS DEL CREDITO
    SELECT num_credito, status_tar, nombre
      INTO cNumCredito, vstatus_tar, cNombreCorto
      FROM bdicred:sd_tarjeta
     WHERE num_tarjeta = pnum_tarjeta
       AND empresa = '001';
        
    IF cNumCredito is null THEN
        LET cNumCredito = ' ';
    END IF;
    
    IF vstatus_tar is null THEN
        LET vstatus_tar = ' ';
    END IF;
	
    IF (cNumCredito is null OR cNumCredito = '') THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '008';
        RETURN vcodret1, cTerminacion, cNombreCorto, cSdoTotal, cPagoMinimo, cPagoNoGenInt, cFecLimPago;
    END IF;
       
    IF (vstatus_tar <> 'A')  THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '009';
        RETURN vcodret1, cTerminacion, cNombreCorto, cSdoTotal, cPagoMinimo, cPagoNoGenInt, cFecLimPago;
    END IF;
	
	--- OBTIENE LOS SALDOS ACTUALES DEL CREDITO
	EXECUTE PROCEDURE bdicred: sp_consulta_tdc_general("001", cTranConsSdo, pc_costos, pusuario, pfolio, pnum_tarjeta, "", TRIM(preferencia))
	INTO cgCodRet, cgTerminacion, cgNombreCte, cgSaldoTotal, cgPagoMinimo, cgPagoNoGenInt, cgFecLimPago;
	IF cgCodRet <> "000" THEN
		--// VALIDA DATOS INSUFICIENTES
		IF cgCodRet IN ("1070","1071","1072","1073","1074","1075","1076") THEN
			LET vcodret1 = "110";
		ELSE
			LET vcodret1 = "999";
		END IF
		IF vtransaccion = 1 THEN
			ROLLBACK WORK;
			BEGIN WORK;
		ELSE
			ROLLBACK WORK;
		END IF;
		
		RETURN vcodret1, cTerminacion, cNombreCorto, cSdoTotal, cPagoMinimo, cPagoNoGenInt, cFecLimPago;
	ELSE 
		LET vproceso = '1';
		
		IF cgSaldoTotal IS NULL OR cgSaldoTotal < 0 THEN
			LET cgSaldoTotal = 0;
		END IF
		
		IF cgPagoMinimo IS NULL OR cgPagoMinimo < 0 THEN
			LET cgPagoMinimo = 0;
		END IF
		
		IF cgPagoNoGenInt IS NULL OR cgPagoNoGenInt < 0 THEN
			LET cgPagoNoGenInt = 0;
		END IF
		
		LET cTerminacion = cgTerminacion;
		LET cNombreCorto = cgNombreCte;
		
		LET cgSaldoTotal = cgSaldoTotal + 0.49;
		LET iSaldoTotal = ROUND(cgSaldoTotal,0);
		LET cSdoTotal = LPAD(iSaldoTotal,14,'0') || '00';
		
		LET cgPagoMinimo = cgPagoMinimo + 0.49;
		LET iPagoMinimo = ROUND(cgPagoMinimo,0);
		LET cPagoMinimo = LPAD(iPagoMinimo,14,'0') || '00';
		
		LET cgPagoNoGenInt = cgPagoNoGenInt + 0.49;
		LET iPagoNoGenInt = ROUND(cgPagoNoGenInt,0);
		LET cPagoNoGenInt = LPAD(iPagoNoGenInt,14,'0') || '00';
		
		LET cFecLimPago = cgFecLimPago;		
	END IF;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
    
    RETURN vcodret1, cTerminacion, cNombreCorto, cSdoTotal, cPagoMinimo, cPagoNoGenInt, cFecLimPago;
    
    END;

END PROCEDURE;