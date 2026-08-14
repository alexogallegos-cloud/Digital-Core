CREATE PROCEDURE "informix".spei_realizacargo_exp1(pvchrclaverastreo CHAR(30),      -- clave de rastreo
                                              pvchrcuentaord    CHAR(20),      -- numero de cuenta del ordenante
                                              pmnyimporte       DECIMAL(17,2), -- importe de la operaciÃ³n
                                              pintrefnumerica   CHAR(7),       -- referencia numÃ©rica
                                              pvchrrfcord       CHAR(18),      -- rfc o curp del beneficiario
                                              pvchrconceptopago CHAR(210),     -- referencia del pago en ventanilla
                                              pvchrrefcobranza  CHAR(40))      -- referencia cobranza

RETURNING CHAR(30); -- folio

    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vSqlErr          INTEGER; 
    DEFINE vIsamErr         INTEGER;
    
    DEFINE wempresa         CHAR(3);
    DEFINE whora            CHAR(15);
    DEFINE wserial_folio    INTEGER;
    DEFINE wfolio_suc       CHAR(30);
    DEFINE wcuenta          CHAR(20);
    DEFINE wnum_tarjeta     CHAR(16);
    DEFINE wmaxsec          SMALLINT;
    DEFINE wsuc_cta         CHAR(4);
    DEFINE wsucursal        CHAR(4);
    DEFINE wusuario         CHAR(8);
    DEFINE wtransacc        CHAR(4);
    DEFINE wdivisa          CHAR(2);
    DEFINE vtransacc        CHAR(4);
    DEFINE vfecha_cargo     DATE;
    DEFINE vdispo           DECIMAL(18,2);
    DEFINE vcargo           DECIMAL(18,2);
    DEFINE wexisteclave     CHAR(30);
    DEFINE vcuenta          CHAR(20);
    DEFINE wmonto_comision  DECIMAL(16,2);
    DEFINE wvalor_iva       DECIMAL(9,6); 
    DEFINE wmonto_iva       DECIMAL(14,2);
    DEFINE wcargo_total     DECIMAL(18,2);
    DEFINE wtran_comision   CHAR(4);
    DEFINE wtran_iva        CHAR(4);
    
    define vcod_ret         char(5);
    define vcuenta1          char(20);
    define vnum_cte         char(20);
    define vapell_pat       char(26);
    define vapell_mat       char(26);
    define vnombre1         char(26);
    define vnombre2         char(26);
    define vrazon_soc       char(60);
    define vedo_cta         char(1);
    define vsdo_disp        money(14,2);
    define vsdo_ret         money(14,2);
    define vsdo_ccc         money(14,2);
    define vsdo_disp_ccc    money(14,2);
    define vsdo_cta         money(14,2);
    define vtipo_linea      char(1);
    define vdescrip1        char(40);
    define vdescrip2        char(40);
    define vsdo_t1          money(14,2);
    define vsdo_cong        money(14,2);
    define vimp_chq_sbc     money(14,2);
    define vusubloq         char(8);
    define vfecbloq         date;
    define vnum_tarjeta     char(16);
    define vcta_clabe       char(18);
    define vtransaccion     integer;
    define vproducto        char(4);
    define wctaord          char(20);
	define mServTranSpei	money;
	define cTpoPersona		CHAR(1);
    
    LET vCodRet1 = "000";
    LET vCodRet2 = "000";
    LET vSqlErr  = 0;
    LET vIsamErr = 0;
    let vtransaccion = 0;
    
    LET wempresa        = '001';
    LET whora           = '';
    LET wserial_folio   = 0;
    LET wfolio_suc      = '0';
    LET wcuenta         = '';
    LET wnum_tarjeta    = '';
    LET wmaxsec         = 0;
    LET wsuc_cta        = '';
    LET wsucursal       = '9201';
    LET wusuario        = 'tranSPEI';
    LET wtransacc       = '0274';
    LET wdivisa         = '01';
    LET vtransacc       = '';  
    LET vfecha_cargo    = '';  
    LET vdispo          = 0.00; 
    LET vcargo          = 0.00; 
    LET wexisteclave    = '';
    LET vcuenta         = '';
    LET wmonto_comision = 0.00;
    LET wvalor_iva      = 0;
    LET wmonto_iva      = 0.00;
    LET wcargo_total    = 0.00;
    LET wtran_comision  = '';
    LET wtran_iva       = '';
	
    let vcod_ret      = "000";
    let vcuenta1      = '';
    let vnum_cte      = '';
    let vapell_pat    = '';
    let vapell_mat    = '';
    let vnombre1      = '';
    let vnombre2      = '';
    let vrazon_soc    = '';
    let vedo_cta      = '';
    let vsdo_disp     = 0.00;
    let vsdo_ret      = 0.00;
    let vsdo_ccc      = 0.00;
    let vsdo_disp_ccc = 0.00;
    let vsdo_cta      = 0.00;
    let vtipo_linea   = '';
    let vdescrip1     = '';
    let vdescrip2     = '';
    let vsdo_t1       = 0.00;
    let vsdo_cong     = 0.00;
    let vimp_chq_sbc  = 0.00;
    let vusubloq      = '';
    let vfecbloq      = '';
    let vnum_tarjeta  = '';
    let vcta_clabe    = '';
    let vproducto     = '';
	LET wctaord       = '';
	let mServTranSpei = 0.0;
	let cTpoPersona	  = "";
    
	--- DEBUG FILE TO "/informix/lflores/spei_realizacargo.out";
	 --SET DEBUG FILE TO "/informix/moha/spei_realizacargo.out";
     --TRACE ON;

    BEGIN

    ON EXCEPTION SET vSqlErr, vIsamErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_realizacargo.out";
        TRACE ON;
        IF vSqlErr != 0 THEN
            LET vCodRet1 = vSqlErr;
            LET vCodRet2 = vIsamErr;
            if vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            else
                ROLLBACK WORK;
            end if;
            RETURN wfolio_suc; 
        END IF;
    END EXCEPTION;
    
    on exception in (-535)
        let vtransaccion = 1;
    end exception with resume;
    
    if vtransaccion = 1 then
        COMMIT WORK;
        BEGIN WORK;
    else
        BEGIN WORK;
    end if;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF pmnyimporte <= 0.00 THEN
        LET wfolio_suc = '0';
        if vtransaccion = 1 then
            ROLLBACK WORK;
            BEGIN WORK;
        else
            ROLLBACK WORK;
        end if;
        RETURN wfolio_suc;
    END IF;
    
	SELECT vchrclaverastreo
      INTO wexisteclave
      FROM bdispei:"informix".tblpago
     WHERE vchrclaverastreo = pvchrclaverastreo;
	 
	--//Valida la longitud de la cuenta origen 
	IF LENGTH(TRIM(pvchrcuentaord)) = 16 THEN
		SELECT NVL(MAX(secuencia), ' ')
          INTO wmaxsec
          FROM bdicheq:"informix".sc_tarjeta
         WHERE empresa = wempresa
           AND num_tarjeta = pvchrcuentaord
           AND tipo_tarjeta = 'T';
		
		SELECT NVL(cuenta, ' ')
          INTO wctaord
          FROM bdicheq:"informix".sc_tarjeta
         WHERE empresa = wempresa
           AND num_tarjeta = pvchrcuentaord
           AND secuencia = wmaxsec;
		   
		let wnum_tarjeta = pvchrcuentaord;
		
	ELIF LENGTH(TRIM(pvchrcuentaord)) = 18 THEN
        LET wctaord = SUBSTR(pvchrcuentaord, 7, 11);
		
		SELECT NVL(MAX(secuencia), ' ')
          INTO wmaxsec
          FROM bdicheq:"informix".sc_tarjeta
         WHERE empresa = wempresa
           AND cuenta = wctaord
           AND tipo_tarjeta = 'T'
           AND status_tar = 'A';

        SELECT NVL(num_tarjeta, ' ')
          INTO wnum_tarjeta
          FROM bdicheq:"informix".sc_tarjeta
         WHERE empresa = wempresa
           AND cuenta = wctaord
           AND secuencia = wmaxsec;
		   		   
	ELIF LENGTH(TRIM(pvchrcuentaord)) = 11 THEN
		LET wfolio_suc = '0';
            if vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            else
                ROLLBACK WORK;
            end if;
            RETURN wfolio_suc;
    ELIF LENGTH(TRIM(pvchrcuentaord)) = 10 THEN
        
        SELECT cuenta
          INTO wctaord
          FROM bdicheq:sc_cuenta_telefono
         WHERE telefono = pvchrcuentaord;
        
        SELECT NVL(MAX(secuencia), ' ')
          INTO wmaxsec
          FROM bdicheq:"informix".sc_tarjeta
         WHERE empresa = wempresa
           AND cuenta = wctaord
           AND tipo_tarjeta = 'T'
           AND status_tar = 'A';

        SELECT NVL(num_tarjeta, ' ')
          INTO wnum_tarjeta
          FROM bdicheq:"informix".sc_tarjeta
         WHERE empresa = wempresa
           AND cuenta = wctaord
           AND secuencia = wmaxsec;
        
    END IF;
	
	SELECT folio_suc 
	  INTO wfolio_suc
	  FROM bdicheq:"informix".sc_movdia
	 WHERE empresa = wempresa
	   AND cuenta = wctaord
	   AND transacc = '0274'
	   AND referencia = pvchrclaverastreo;
	
	IF wfolio_suc is not null OR wfolio_suc <> 0 THEN
		RETURN wfolio_suc;
	END IF;
		
    IF wexisteclave is null OR wexisteclave = '' THEN
        IF SUBSTR(wctaord,1,2) = '80' THEN
            SELECT cuenta_tf
              INTO vcuenta
              FROM bditransfer:tf_maecte
             WHERE cuenta_tf = wctaord
               AND status_cta = '1';
               
            LET vproducto = '8000';
        ELSE
            SELECT cuenta, producto
              INTO vcuenta, vproducto
              FROM bdicheq:"informix".sc_maechq
             WHERE empresa = wempresa
               AND cuenta = wctaord;
        END IF;
           
        IF vcuenta is null OR vcuenta = '' THEN
            LET wfolio_suc = '0';
            if vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            else
                ROLLBACK WORK;
            end if;
            RETURN wfolio_suc;
        END IF;
           
        IF vproducto NOT IN('1300','1700','1400','9900','9901','8000') THEN
            SELECT mnycomision
              INTO wmonto_comision
              FROM bdispei:"informix".tblcomision
             WHERE vchrcvecomision = 'TARIFA 0';
             
            SELECT valor
              INTO wvalor_iva
              FROM bdinteg:"informix".si_param
             WHERE cod_param = 47
               AND empresa = wempresa;
			   
			SELECT tpper_valida
			INTO cTpoPersona
			FROM bdicheq:"informix".sc_producto
			WHERE empresa = "001" 
			AND producto = vproducto;
			   
			IF cTpoPersona IN ("2","4","5") AND vproducto <> "2600" THEN
				--// OBTIENE EL VALOR DE LA COMISION PARA SPEI EN LA TABLA MAESTRA DE COMISIONES DE PERSONAS MORALES
				SELECT serv_tran_spei
				INTO mServTranSpei
				FROM bdicheq:"informix".sc_maecomtasserv_pm
				WHERE cuenta = wctaord;
				
				IF mServTranSpei IS NOT NULL  THEN
					LET wmonto_comision = mServTranSpei;
				END IF
			END IF
               
            LET wmonto_iva = wmonto_comision * wvalor_iva;
            LET wcargo_total = pmnyimporte + wmonto_comision + wmonto_iva;
        ELSE
            LET wcargo_total = pmnyimporte;
            LET wmonto_comision = 0.00;
            LET wmonto_iva = 0.00;
        END IF;
		
		LET wcargo_total = pmnyimporte; 
		LET wmonto_comision = 0.00;
        LET wmonto_iva = 0.00;
		   
        IF SUBSTR(wctaord,1,2) = '80' THEN
            LET vsdo_disp = wcargo_total;
        ELSE
            -- // CONSULTA SALDO DISPONIBLE DE LA CUENTA
            EXECUTE PROCEDURE bdicheq:"informix".cons_sdos1(wempresa, wctaord, wnum_tarjeta)
            INTO vcod_ret, vcuenta1, vnum_cte, vapell_pat, vapell_mat, vnombre1, vnombre2, vrazon_soc, 
                 vedo_cta, vsdo_disp, vsdo_ret, vsdo_ccc, vsdo_disp_ccc, vsdo_cta, vtipo_linea, vdescrip1, 
                 vdescrip2, vsdo_t1, vsdo_cong, vimp_chq_sbc, vusubloq, vfecbloq, vnum_tarjeta, vcta_clabe;
        END IF;
        
        IF vsdo_disp >= wcargo_total THEN
                    
            -- // OBTIENE FOLIO
            CALL "informix".sp_obtfoliosuc(wusuario) 
            RETURNING vcodret1, wserial_folio, wfolio_suc;
            
            IF vcodret1 <> '000' THEN
                LET wfolio_suc = '0';
                if vtransaccion = 1 then
                    ROLLBACK WORK;
                    BEGIN WORK;
                else
                    ROLLBACK WORK;
                end if;
                RETURN wfolio_suc;
            END IF;
            
            -- // APLICA CARGO DEL SPEI 
            EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(wempresa, wsucursal, wusuario, wtransacc, wtransacc, wfolio_suc, 
                                                           wctaord, 0, pmnyimporte, wdivisa, pvchrclaverastreo, wnum_tarjeta, ' ')
            INTO vcodret1, vtransacc, vfecha_cargo, vdispo, vcargo;
            
            IF vcodret1 = '000' THEN
                
                IF wmonto_comision > 0.00 THEN
                        
                        SELECT vchrvalor
                          INTO wtran_comision
                          FROM bdispei:"informix".tblparametros
                         WHERE vchrcveparametro = 'TRANSACC_COMISION';
                         
                        -- // APLICA CARGO DE LA COMISION SPEI 
                        EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(wempresa, wsucursal, wusuario, wtran_comision, wtran_comision, wfolio_suc, 
                                                                       wctaord, 0, wmonto_comision, wdivisa, pvchrclaverastreo, wnum_tarjeta, ' ')
                        INTO vcodret1, vtransacc, vfecha_cargo, vdispo, vcargo;
                        
                        IF vcodret1 = '000' THEN 
                            SELECT tran_relac
                              INTO wtran_iva
                              FROM bdinteg:"informix".si_transacc
                             WHERE empresa = wempresa
                               AND numero = wtran_comision;
                            
                            -- // APLICA CARGO DEL IVA SPEI 
                            EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(wempresa, wsucursal, wusuario, wtran_iva, wtran_iva, wfolio_suc, 
                                                                           wctaord, 0, wmonto_iva, wdivisa, pvchrclaverastreo, wnum_tarjeta, ' ')
                            INTO vcodret1, vtransacc, vfecha_cargo, vdispo, vcargo;
                            
                            IF vcodret1 <> '000' THEN 
                                LET wfolio_suc = '0';
                                if vtransaccion = 1 then
                                    ROLLBACK WORK;
                                    BEGIN WORK;
                                else
                                    ROLLBACK WORK;
                                end if;
                                RETURN wfolio_suc;
                            END IF;
                        ELSE 
                            LET wfolio_suc = '0';
                            if vtransaccion = 1 then
                                ROLLBACK WORK;
                                BEGIN WORK;
                            else
                                ROLLBACK WORK;
                            end if;
                            RETURN wfolio_suc;
                        END IF;             
                END IF;
                
            ELSE 
                LET wfolio_suc = '0';
                if vtransaccion = 1 then
                    ROLLBACK WORK;
                    BEGIN WORK;
                else
                    ROLLBACK WORK;
                end if;
                RETURN wfolio_suc;
            END IF;
        ELSE
            LET wfolio_suc = '0';
            if vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            else
                ROLLBACK WORK;
            end if;
            RETURN wfolio_suc;
        END IF;
    ELSE
        LET wfolio_suc = '0';
        if vtransaccion = 1 then
            ROLLBACK WORK;
            BEGIN WORK;
        else
            ROLLBACK WORK;
        end if;
        RETURN wfolio_suc;
    END IF;
    
    if vtransaccion = 1 then
        COMMIT WORK;
        BEGIN WORK;
    else
        COMMIT WORK;
    end if;
    
    RETURN wfolio_suc;
   
   END;
    
END PROCEDURE;