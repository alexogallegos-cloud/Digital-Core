CREATE PROCEDURE "informix".sp_cargo_tdc_via_app(
pempresa  CHAR(3),      --- EMPRESA
pc_costos CHAR(4),      --- SUCURSAL
pusuario CHAR(8),       --- USUARIO
pnum_tarjeta CHAR(16),  --- TARJETA DE CREDITO
pmto_tot DECIMAL(14,2), --- MONTO
pmto_com DECIMAL(14,2), --- MONTO COMISION
pTransDispoE CHAR(4),
pTransuc CHAR(4),       --- TRANSACCION
pfolio CHAR(16),        --- FOLIO SUC
preferencia CHAR(40),   --- REFERENCIA
cTadestinoCaptacion CHAR(11))
RETURNING CHAR(3),      --- CODIGO DE RETORNO
          CHAR(4),      --- TERMINACION TARJETA
          CHAR(53),     --- NOMBRE CORTO DEL CLIENTE
          CHAR(11),     --- NUMERO CTA
          DECIMAL(16,2),--- MONTO IMPORTE
          DECIMAL(16,2),--- IMPORTE COMISION
          DECIMAL(16,2);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE vcodret1     CHAR(3);
    DEFINE vcodret2     CHAR(5);
    DEFINE cod_ret          CHAR(3);
    DEFINE vtransaccion     SMALLINT; 
    DEFINE vproceso         CHAR(1);
    
    DEFINE vtarjeta         CHAR(16);
    DEFINE vnum_credito     CHAR(20);
    DEFINE vstatus_tar      CHAR(1);
    DEFINE cTerminacion     CHAR(4);
    DEFINE cNombreCorto     CHAR(53);
    DEFINE cImporteCom      DECIMAL(16,2);
    DEFINE cImporteIvaCom   DECIMAL(16,2);
    DEFINE cTranDispoEfect  CHAR(4);
    DEFINE iImporteCom      INT8;
    DEFINE iImporteIvaCom   INT8;
    DEFINE vmtoacumcta      DECIMAL(18,6);
    DEFINE vlim_cuenta      DECIMAL(18,6);
    DEFINE iLimitePesos     INT8;
    DEFINE vexiste          CHAR(20);
    DEFINE vcuenta          CHAR(11);
    DEFINE vimporte         DECIMAL(16,2);
    DEFINE vpmto_firme      DECIMAL(14,2);
    DEFINE vNombreCte       CHAR(60);
    DEFINE vTerminacion     CHAR(4);
    DEFINE vNumCte          CHAR(20);

    DEFINE dFechaCierrePP   DATE;
    DEFINE cStatusCierrePP  CHAR(1);
    DEFINE dFechaIntegral   DATE;
    DEFINE cIndCierreCheq   CHAR(1);
    DEFINE dFechaHabilAnt   DATE;
    DEFINE cCodRet3         CHAR(5);
    
    --// PARAMETROS DEL PROCESO QUE REALIZA EL CARGO POR RETIRO DE LA TDC
    DEFINE ctCodRet         CHAR(3);
    DEFINE ctTerminacion    CHAR(4);
    DEFINE ctNombreCte      CHAR(53);
    DEFINE cNumCta          CHAR(11);
    DEFINE ctMtoImporte     DECIMAL(16,2);
    DEFINE ctMtoCargo       DECIMAL(16,2);
    DEFINE ctMtoComision    DECIMAL(16,2);
    DEFINE ctMtoIvaCom      DECIMAL(16,2);
    DEFINE ctSdoDisp        DECIMAL(16,2);
    DEFINE dDia             DATE;
    DEFINE cHora            CHAR(8);
    
    LET sql_err  = 0;
    LET isam_err = 0;
    LET vcodret1 = '000';
    LET cod_ret = '000';
    LET vcodret2 = '000';
    LET vtransaccion    = 0;
    LET vproceso        = '0';
    
    LET vtarjeta         = '';
    LET vcuenta          = '';
    LET vimporte         = 0.0;
    LET vnum_credito     = '';
    LET vstatus_tar      = '';
    LET cTerminacion    = "";
    LET cNombreCorto    = "";
    LET cImporteCom     = 0.00;
    LET cImporteIvaCom  = 0.00;
    LET iImporteCom     = 0;
    LET iImporteIvaCom  = 0;
    LET vmtoacumcta     = 0.00;
    LET vlim_cuenta     = 0.00;
    LET iLimitePesos    = 0;
    LET vexiste         = '';
    LET cNumCta         = '';
    LET vpmto_firme     = 0.00;
    LET vNombreCte      = "";
    LET vTerminacion    = "";
    LET vNumCte         = "";

    LET dFechaCierrePP          = DATE(1);
    LET cStatusCierrePP         = '';
    LET dFechaIntegral          = DATE(1);
    LET cIndCierreCheq          = "";
    LET dFechaHabilAnt          = DATE(1);
    LET cCodRet3                = '000';
    LET dDia                    = DATE(1);
    LET cHora                   = '';
    
    --// PARAMETROS DEL PROCESO QUE REALIZA EL CARGO POR RETIRO DE LA TDC
    LET ctCodRet        = '000';
    LET ctTerminacion   = '';
    LET ctNombreCte     = '';
    LET ctMtoImporte    = 0;
    LET ctMtoCargo      = 0;
    LET ctMtoComision   = 0.0;
    LET ctMtoIvaCom     = 0.0;
    LET ctSdoDisp       = 0.0;

    --SET DEBUG FILE TO "/ifxsif01/efv/trace_reportes/sp_cargo_tdc_via_app.out";
    -- SET DEBUG FILE TO "/RESPALDOS/Prueba_SP_cargoref_tdc/corresp_disp_efec_tdc.out";
    --TRACE ON;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
         --SET DEBUG FILE TO "/RESPALDOS/Prueba_SP_cargoref_tdc/sp_cargoref_tdc_general_cta.err";
         --TRACE ON;

        LET sql_err  = 0;
        LET vcodret2 = sql_err;
        IF sql_err <> 0 THEN
            --- LET vcodret1 = sql_err;
             LET vcodret2 = pTransuc;
            IF vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            IF vproceso = '1' THEN
                LET vcodret1 = '000';
                LET cod_ret=vcodret1;
            ELSE
                LET vcodret1 = '999';
                LET cod_ret=vcodret1;
            END IF;
            RETURN cod_ret, cTerminacion, cNombreCorto, cNumCta, ctMtoImporte, cImporteCom, cImporteIvaCom;
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


    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO dDia FROM sysmaster:sysshmvals;
    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHora FROM sysmaster:sysshmvals;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF (pempresa is null OR pempresa = '') OR
       (pc_costos is null OR pc_costos = '') OR
       (pusuario is null OR pusuario = '' OR LENGTH(pusuario) <> 8) OR
       (pnum_tarjeta is null OR pnum_tarjeta = '' OR LENGTH(pnum_tarjeta) <> 16) OR
       (pmto_tot is null OR pmto_tot <= 0.00) OR
       (pTransDispoE is null OR pTransDispoE = '')OR
       (pTransuc is null OR pTransuc = '')OR
       (pfolio is null OR pfolio = '' OR LENGTH(pfolio) <> 16) OR
       (preferencia IS NULL OR preferencia = '' ) OR
       (cTadestinoCaptacion IS NULL OR cTadestinoCaptacion = '' ) THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '110';
        LET cod_ret = vcodret1;
        RETURN cod_ret, cTerminacion, cNombreCorto, cNumCta, ctMtoImporte, cImporteCom, cImporteIvaCom;
    END IF;

    --// Obtine el numero de credito
    SELECT b.numcte
    INTO  vNumCte
    FROM bdicred:"informix".sd_tarjeta a,
    bdicred:"informix".sd_maecred b
    WHERE a.empresa    = pempresa
    AND a.num_tarjeta = pnum_tarjeta
    AND b.empresa     = a.empresa
    AND b.num_credito = a.num_credito;

    --// Obtiene el nombre del cliente
    SELECT TRIM(NVL(razon_social, ' ')) ||
     TRIM(nombre1) || " " ||
    --TRIM(NVL(nombre2, ' ')) || " " ||
    TRIM(apell_paterno)
    --TRIM(apell_materno)
    INTO vNombreCte
    FROM bdinteg:"informix".si_cliente
    WHERE numcte = vNumCte;  

    LET ctNombreCte = vNombreCte;

    SELECT num_tarjeta, num_credito, status_tar
      INTO vtarjeta, vnum_credito, vstatus_tar
      FROM bdicred:sd_tarjeta
     WHERE num_tarjeta = pnum_tarjeta
       AND empresa = '001';

    LET vTerminacion = SUBSTR(pnum_tarjeta,LENGTH(pnum_tarjeta)-3,LENGTH(pnum_tarjeta));
    LET ctTerminacion = vTerminacion;
       
    IF (vnum_credito is null OR vnum_credito = '') THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '008';
        LET cod_ret=vcodret1;
        RETURN cod_ret, cTerminacion, cNombreCorto, cNumCta, ctMtoImporte, cImporteCom, cImporteIvaCom;
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
        LET cod_ret=vcodret1;
        RETURN cod_ret, cTerminacion, cNombreCorto, cNumCta, ctMtoImporte, cImporteCom, cImporteIvaCom;
    END IF;
  


    --Valida fechas
    SELECT ind_cierre INTO cIndCierreCheq FROM bdicheq:"informix".sc_fechas;
    SELECT fecha_hoy INTO dFechaIntegral FROM bdinteg:"informix".si_fechas;

    SELECT max(fecha) INTO dFechaCierrePP FROM bdicred:sd_contproc WHERE empresa = '001' AND proceso = "CierrePrest";
    SELECT status_proc INTO cStatusCierrePP FROM bdicred:sd_contproc WHERE proceso = "CierrePrest" AND fecha = dFechaCierrePP;

    EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil((dFechaIntegral - 1),'-') INTO cCodRet3, dFechaHabilAnt;

    --Se inserta registro de ejecucion
    INSERT INTO bdicred:sd_bitacora_disp_app (empresa,nom_proceso,num_tarjeta,sucursal,usuario,transaccion,monto,referencia,folio,cod_ret,ctadestinodaptacion,proceso_ejecucion,fecha_ejecucion,hora_ejecucion) 
    VALUES ('001','sp_valfechabil',pnum_tarjeta,pc_costos,pusuario,pTransuc,pmto_tot,preferencia,pfolio,cCodRet3,cTadestinoCaptacion,'',dDia,cHora);

    LET ctCodRet = '005';
    IF cIndCierreCheq = '1' AND dFechaCierrePP = dFechaHabilAnt AND UPPER(cStatusCierrePP) = 'F' THEN 

        EXECUTE PROCEDURE bdicred:"informix".cargoref_tc_ofi(pempresa,pc_costos,pusuario,pnum_tarjeta,pmto_tot,pfolio,pTransuc)
        INTO ctCodRet,ctSdoDisp,ctMtoCargo,ctMtoComision,ctMtoIvaCom;

        --Actualizacion registro de ejecucion
        update bdicred:sd_bitacora_disp_app set nom_proceso = 'cargoref_tc_ofi', proceso_ejecucion = 'sp_valfechabil' where num_tarjeta = pnum_tarjeta and folio = pfolio and fecha_ejecucion = dDia;

        --EXECUTE PROCEDURE bdicred:sp_cargoref_tdc_general(pempresa, pc_costos, pusuario, pnum_tarjeta, pmto_tot, pTransuc, pfolio, preferencia)
        --INTO ctCodRet, ctTerminacion, ctNombreCte, ctMtoCargo, ctMtoComision, ctMtoIvaCom;

    END IF;


    IF ctCodRet <> '000' THEN
        IF ctCodRet = "005" THEN
            LET vcodret1 = '010';
            LET cod_ret = vcodret1;
        ELSE
            LET vcodret1 = '999';
            LET cod_ret = vcodret1;
        END IF
        
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        
        RETURN cod_ret, cTerminacion, cNombreCorto, cNumCta, ctMtoImporte, cImporteCom, cImporteIvaCom;
    ELSE
        LET vproceso = '1';
        LET vpmto_firme = pmto_tot;
        LET cNumCta = cTadestinoCaptacion;

        EXECUTE PROCEDURE bdicheq:abono_ref(pempresa, pc_costos, pusuario,pTransDispoE,'',pfolio,cNumCta,0,pmto_tot,vpmto_firme,0,0,0,'01',preferencia,'','')
        INTO ctCodRet;

        --Actualiza registro de ejecucion
        update bdicred:sd_bitacora_disp_app set nom_proceso = 'abono_ref', proceso_ejecucion = 'sp_valfechabil / cargoref_tc_ofi' where num_tarjeta = pnum_tarjeta and folio = pfolio and fecha_ejecucion = dDia;

       ---Validacion de respuesta
        IF ctCodRet <> '000' THEN
        ROLLBACK WORK;
        {
        
        EXECUTE PROCEDURE bdicred:"informix".reversion("001",pc_costos,pusuario,pfolio,'A')
        into ctCodRet;

        --Actualiza registro de ejecucion

        update bdicred:sd_bitacora_disp_app set nom_proceso = 'reversion', proceso_ejecucion = 'sp_valfechabil / cargoref_tc_ofi' where num_tarjeta = pnum_tarjeta and folio = pfolio and fecha_ejecucion = dDia;
    
        }
    END IF;

		
        LET cTerminacion = ctTerminacion;
        LET cNombreCorto = ctNombreCte;
        LET cNumCta = cTadestinoCaptacion;
        LET ctMtoImporte = ctMtoCargo;
        LET cImporteCom = ctMtoComision;
        LET cImporteIvaCom = ctMtoIvaCom;
        --LET iImporteCom = ROUND(ctMtoComision,0);
        --LET cImporteCom = LPAD(iImporteCom,14,'0') || '00';
        --LET iImporteIvaCom = ROUND(ctMtoIvaCom,0);
        --LET cImporteIvaCom = LPAD(iImporteIvaCom,14,'0') || '00';
        
   END IF
       
   IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
   END IF;

   RETURN cod_ret, cTerminacion, cNombreCorto, cNumCta, ctMtoImporte, cImporteCom, cImporteIvaCom;

   
  END;

END PROCEDURE;