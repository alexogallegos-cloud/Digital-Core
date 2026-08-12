CREATE PROCEDURE "informix".corresp_disp_efec_tdc( 
pc_costos CHAR(4),      --- SUCURSAL
pusuario CHAR(8),       --- USUARIO
pfolio CHAR(16),        --- FOLIO SUC
pnum_tarjeta CHAR(16),  --- TARJETA DE CREDITO
pfecha CHAR(8),            --- FECHA
pmto_tot DECIMAL(14,2), --- MONTO
pmoneda CHAR(3),        --- MONEDA
preferencia CHAR(40) )  --- REFERENCIA
RETURNING CHAR(3),  		--- CODIGO DE RETORNO
	      CHAR(4),  		--- TERMINACION TARJETA
          CHAR(53), 		--- NOMBRE CORTO DEL CLIENTE
		  CHAR(16), 	--- IMPORTE COMISION
		  CHAR(16); 	--- IMPORTE IVA COMISION

    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE vcodret1     CHAR(3);
    DEFINE vcodret2     CHAR(5);
	DEFINE vtransaccion     SMALLINT;
	DEFINE vproceso         CHAR(1);
    
    DEFINE vtarjeta         CHAR(16);
    DEFINE vnum_credito     CHAR(20);
    DEFINE vstatus_tar      CHAR(1);
	DEFINE cTerminacion		CHAR(4);
	DEFINE cNombreCorto		CHAR(53);
	DEFINE cImporteCom		CHAR(16);
	DEFINE cImporteIvaCom	CHAR(16);
	DEFINE cTranDispoEfect	CHAR(4);
	DEFINE iImporteCom		INT8;
	DEFINE iImporteIvaCom	INT8;
	DEFINE vmtoacumcta      DECIMAL(18,6);
	DEFINE vlim_cuenta      DECIMAL(18,6);
	DEFINE iLimitePesos		INT8;
	DEFINE vexiste          CHAR(20);
	
	--// PARAMETROS DEL PROCESO QUE REALIZA EL CARGO POR RETIRO DE LA TDC
	DEFINE ctCodRet			CHAR(5);
	DEFINE ctTerminacion	CHAR(4);
	DEFINE ctNombreCte		CHAR(60);
	DEFINE ctMtoCargo		DECIMAL(16,2);
	DEFINE ctMtoComision	DECIMAL(16,2);
	DEFINE ctMtoIvaCom		DECIMAL(16,2);
	
	
    
    LET sql_err  = 0;
    LET isam_err = 0;
    LET vcodret1 = '000';
    LET vcodret2 = '000';
	LET vtransaccion	= 0;
	LET vproceso		= "0";
    
    LET vtarjeta         = '';
    LET vnum_credito     = '';
    LET vstatus_tar      = '';
	LET cTerminacion	= "";
	LET cNombreCorto	= "";
	LET cImporteCom		= "";
	LET cImporteIvaCom	= "";
	LET cTranDispoEfect	= "";
	LET iImporteCom		= 0;
	LET iImporteIvaCom	= 0;
	LET vmtoacumcta     = 0.00;
	LET vlim_cuenta     = 0.00;
	LET iLimitePesos	= 0;
	LET vexiste         = '';
	
	--// PARAMETROS DEL PROCESO QUE REALIZA EL CARGO POR RETIRO DE LA TDC
	LET ctCodRet		= "000";
	LET ctTerminacion	= "";
	LET ctNombreCte		= "";
	LET ctMtoCargo		= 0.0;
	LET ctMtoComision	= 0.0;
	LET ctMtoIvaCom		= 0.0;

	
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_disp_efec_tdc.out";
     --SET DEBUG FILE TO "/informix/moha/corresp_disp_efec_tdc.out";
     --TRACE ON;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_disp_efec_tdc.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            --- LET vcodret1 = sql_err;
            --- LET vcodret2 = isam_err;
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
            RETURN vcodret1, cTerminacion, cNombreCorto, cImporteCom, cImporteIvaCom;
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
    
    IF (pc_costos is null OR pc_costos = '') OR
       (pusuario is null OR pusuario = '' OR LENGTH(pusuario) <> 8) OR
       (pfolio is null OR pfolio = '' OR LENGTH(pfolio) <> 16) OR
       (pnum_tarjeta is null OR pnum_tarjeta = '' OR LENGTH(pnum_tarjeta) <> 16) OR
       (pfecha is null OR pfecha = '') OR
       (pmto_tot is null OR pmto_tot <= 0.00) OR
       (pmoneda is null OR pmoneda = '' OR LENGTH(pmoneda) <> 03) OR 
	   (preferencia IS NULL OR preferencia = '' ) THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '110';
        RETURN vcodret1, cTerminacion, cNombreCorto, cImporteCom, cImporteIvaCom;
    END IF;
	
	LET pmto_tot = pmto_tot / 100;
	
    IF LENGTH(pmoneda) = 03 THEN
        LET pmoneda = pmoneda[2,3]; 
    END IF;
	
	-- OBTIENE LA TRANSACCION CORRESPONDIENTE A LA CONSULTA
	SELECT TRIM(valor)
	INTO cTranDispoEfect
	FROM bdicheq: "informix".sc_param
	WHERE empresa = "001"
	AND codparam = "retefectdcbancv";
    
    -- // VALIDA DATOS DEL CREDITO
    SELECT num_tarjeta, num_credito, status_tar
      INTO vtarjeta, vnum_credito, vstatus_tar
      FROM bdicred:sd_tarjeta
     WHERE num_tarjeta = pnum_tarjeta
       AND empresa = '001';
	   
    IF (vnum_credito is null OR vnum_credito = '') THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '008';
        RETURN vcodret1, cTerminacion, cNombreCorto, cImporteCom, cImporteIvaCom;
    END IF;
    
    IF vtarjeta is null THEN
        LET vtarjeta = ' ';
    END IF;
        
    IF vstatus_tar is null THEN
        LET vstatus_tar = ' ';
    END IF;
       
    IF (vtarjeta <> pnum_tarjeta) OR (vstatus_tar <> 'A')  THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '009';
        RETURN vcodret1, cTerminacion, cNombreCorto, cImporteCom, cImporteIvaCom;
    END IF;
	
    -- // OBTIENE EL VALOR MAXIMO DE PESOS PARA CREDITO
    SELECT valor
      INTO iLimitePesos
      FROM bdicheq:"informix".sc_param_corresp
     WHERE codparam = 'NUMAXPESRETEFECTDC'
       AND empresa = '001';
    
    -- // VALIDA QUE EL MONTO DE LA TRANSACCION NO REBASE EL LIMITE PERMITIDO POR OPERACION
    IF (pmto_tot > iLimitePesos) THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '006';
        RETURN vcodret1, cTerminacion, cNombreCorto, cImporteCom, cImporteIvaCom;
    END IF;
	
    -- // OBTIENE EL ACUMULADO DEL DIA DEL CREDITO
    SELECT SUM(monto)
      INTO vmtoacumcta
      FROM bdicred:sd_movdia
     WHERE empresa = '001'
       AND num_credito = vnum_credito
       AND fecha_mov = pfecha
       AND reversado <> 'S'
       AND sucursal = pc_costos
       AND ((transacc_suc = '8105' AND codigo_fun = '002' AND codigo_ref = 109) OR 
            (transacc_suc = '8112' AND codigo_fun = '002' AND codigo_ref = 110));
     
    IF vmtoacumcta is null THEN
        LET vmtoacumcta = 0.00;
    END IF;
    
    -- // SUMA EL MONTO DE LA TRANSACCION AL ACUMULADO DEL CREDITO
    LET vlim_cuenta = pmto_tot + vmtoacumcta;
	
	-- // VALIDA QUE EL MONTO DE LA TRANSACCION NO REBASE EL LIMITE PERMITIDO POR DIA
    IF (vlim_cuenta > iLimitePesos) THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '002';
        RETURN vcodret1, cTerminacion, cNombreCorto, cImporteCom, cImporteIvaCom;
    END IF;
	
	EXECUTE PROCEDURE bdicred: sp_cargoref_tdc_general("001", pc_costos, pusuario, pnum_tarjeta, pmto_tot, cTranDispoEfect, pfolio, preferencia)
	INTO ctCodRet, ctTerminacion, ctNombreCte, ctMtoCargo, ctMtoComision, ctMtoIvaCom;
	IF ctCodRet <> '000' THEN
		IF ctCodRet = "005" THEN
			LET vcodret1 = '010';
		ELSE
			LET vcodret1 = '999';
		END IF
		
		IF vtransaccion = 1 THEN
			ROLLBACK WORK;
			BEGIN WORK;
		ELSE
			ROLLBACK WORK;
		END IF;
		
		RETURN vcodret1, cTerminacion, cNombreCorto, cImporteCom, cImporteIvaCom;
	ELSE 
		LET vproceso = '1';
		
		LET cTerminacion = ctTerminacion;
		LET cNombreCorto = ctNombreCte;
		LET iImporteCom = ROUND(ctMtoComision,0);
		LET cImporteCom = LPAD(iImporteCom,14,'0') || '00';
		LET iImporteIvaCom = ROUND(ctMtoIvaCom,0);
		LET cImporteIvaCom = LPAD(iImporteIvaCom,14,'0') || '00';

	END IF;

    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;

    RETURN vcodret1, cTerminacion, cNombreCorto, cImporteCom, cImporteIvaCom;
    
    END;

END PROCEDURE;