CREATE PROCEDURE "informix".cargo_ref_cel_mib( pnum_tarjeta char(16),
                                           psucursal    char(4),
                                           pusuario     char(8),
                                           ptransacc    char(4),
                                           ptransuc     char(4),
                                           pfolsuc      char(16),
                                           pcuenta      char(20),
                                           pcheque      integer,
                                           pmtocompra   money(14,2),
                                           pmontoefe    money(14,2),
                                           ptransefe    char(4),
                                           pfolioefe    char(16),
                                           pdivisa      char(2),
                                           preferencia  char(40),
                                           psucursalcom char(4),
                                           pusuariocom  char(8),
                                           ptrancencom  char(4),
                                           ptransuccom  char(4),
                                           pfolsuccom   char(16),
                                           pcuentacom   char(20),
                                           pchequecom   integer,
                                           pmontocom    money(14,2),
                                           pdivisacom   char(2),
                                           prefercom    char(40),
                                           pbanderacom  char(1),
                                           psurcharge   char(1),
                                           ptrancomefe  char(4),
                                           ptrascomefe  char(4),
                                           pfolcomefe   char(16),
                                           pchequeefe   integer,
                                           pmtocomefe   money(14,2),
                                           pdivcomefe   char(2),
                                           prefcomefe   char(40) ) 
RETURNING char(5), char(4), date, money(14,2), money(14,2), 
          char(5), char(4), date, money(14,2), money(14,2);
    
    define vsqlerr      integer;
    define vcodret      char(5);
    define vcodret1     char(5);
    define vcodretcom   char(5);
    define vtranret1    char(4);
    define vtranret     char(4);
    define vtransacc    char(4);
    define vtiporef     char(1);
    define vfechoy      date;
    define vsdodisp     money(14,2);
    define vcompend     money(14,2);
    define vmontoret    money(14,2);
    define vtotcom      money(14,2);
    define vempresa     char(3);
    define vejecargo    char(1);
    define vconreg      smallint;
    define vcuenta      char(20);
    define vtotiva      money(14,2);
    define vtasaiva     decimal(9,3);
    define vivacom      money(14,2);
    define vtotret      money(14,2);
    define vsuccta      char(4);
    define vtraniva     char(4);
    define vfecapli     date;
    define vmtoapli     money(14,2);
    define vind_dispon  char(1);
    define vhora        DATETIME HOUR TO FRACTION(3);
    define vidtransacc  char(5);
    define vcodret_reg  char(5);
    define vserial      integer;
    define vprodtrnf    char(4);
    define vvueltas     integer;
    define vSQL         char(10);
    define cStatus      char(1);
    define vtransaccion integer;
    define cTramaRes    char(500);
    define vcodautrnf   char(6);
    define vtotrettrf   money(14,2);
	define vfecha_operacion date;
    define msdo_actual      money(14,2);
    define msdo_retenido    money(14,2);
    define msdo_cong        money(14,2);
    define mimp_chq_sbg     money(14,2);

    -- RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. LEOC.
    define mSaldoSbc        MONEY(14,2); -- Variable que especifica el saldo de inmovilizacion
    
    LET vcodret      = "000";
    LET vtranret     = " ";
    LET vfechoy      = ' ';
    LET vsdodisp     = 0;
    LET vmontoret    = 0;
    LET vcodretcom   = "000";
    LET vtotcom      = 0;
    LET psucursal    = "9"||trim(psucursal);
    LET psucursalcom = "9"||trim(psucursalcom);
    LET vind_dispon  = '0';
    LET vidtransacc  = '';
    LET vcodret_reg  = '';
    LET vserial      = 0;
    LET vprodtrnf    = '8000';
    LET vvueltas     = 0; 
    LET vSQL         = '';
    LET cStatus      = '';
    LET vtransaccion = 0;
    LET cTramaRes    = '';
    LET vcodautrnf   = '';
    LET vtotrettrf   = 0.00;
	LET vfecha_operacion = TODAY;
    LET msdo_actual      = 0.00;
    LET msdo_retenido    = 0.00;
    LET msdo_cong        = 0.00;
    LET mimp_chq_sbg     = 0.00;
    
    -- RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. LEOC.
    LET mSaldoSbc           = '0';

    --- set debug file to "/informix/HomeInformix/rrm/cargo_ref_cel.out";
    --- trace on;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0  THEN
            LET vcodret = vsqlerr;
            IF SUBSTR(pcuenta, 1, 2) <> '80' THEN
                if vtransaccion = 1 then
                    ROLLBACK WORK;
                    BEGIN WORK;
                else
                    ROLLBACK WORK;
                end if;
            END IF;
            RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret, vcodretcom, ptrancomefe, vfechoy, vsdodisp, vtotcom;
        END IF;
    END EXCEPTION;
    
    on exception in (-535)
        let vtransaccion = 1;
    end exception with resume;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    SELECT empresa 
      INTO vempresa
      FROM bdinteg:si_ejecut
     WHERE ejecutivo = pusuario;
     
    IF vempresa is null THEN
        LET vempresa = '001';
    END IF;
    
    -- // Valida fecha de proceso de la cuenta
    SELECT fecha_hoy, ind_disponible
      INTO vfechoy, vind_dispon
      FROM sc_fechas
     WHERE empresa = vempresa;
     
    IF vind_dispon = '0' THEN
        if vtransaccion = 1 then
            ROLLBACK WORK;
            BEGIN WORK;
        else
            ROLLBACK WORK;
        end if;
        LET vcodret = "004";
        RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret, vcodretcom, ptrancomefe, vfechoy, vsdodisp, vtotcom;
    END IF;
    
    LET vfecapli = vfechoy;
    
    SELECT iva 
      INTO vtasaiva
      FROM bdinteg:si_sucursales
     WHERE empresa = vempresa 
       and sucursal = '9290';
       
    IF vtasaiva is null THEN
        LET vtasaiva = 0;
    END IF;
    
    LET vtotcom = pmontocom + pmtocomefe;
    LET vtotiva = vtotcom * vtasaiva;
    LET vmontoret = pmtocompra + pmontoefe;
    LET vtotret = pmtocompra + pmontoefe + vtotcom + vtotiva;    
    
    SELECT cuenta 
      INTO vcuenta
      FROM sc_tarjeta
     WHERE empresa = vempresa 
       AND num_tarjeta = pnum_tarjeta;
       
    IF vcuenta is null or vcuenta = '' THEN
        LET vcodret = "100";
        if vtransaccion = 1 then
            ROLLBACK WORK;
            BEGIN WORK;
        else
            ROLLBACK WORK;
        end if;
        RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret, vcodretcom, ptrancomefe, vfechoy, vsdodisp, vtotcom;
    END IF
    
    IF SUBSTR(vcuenta, 1, 2) = '80' THEN
        
        LET vcodret = "999";
        RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret, vcodretcom, ptrancomefe, vfechoy, vsdodisp, vtotcom;
        
        /* ############################################################################################################################################
        LET vtotrettrf = pmtocompra + pmontoefe + vtotcom;    
        
        IF ptransacc IN ('0801','0881') THEN
            SELECT valor
              INTO vidtransacc
              FROM sc_param
             WHERE empresa = vempresa
               AND codparam = 'TranCgoPosTransfer';  
               
            CALL sp_transfer_online_cgopos( vidtransacc, pnum_tarjeta, pfolsuc, vtotrettrf, pusuario, vfechoy )
            RETURNING vcodret_reg, vserial;
        ELIF ptransacc IN ('0800','0871','0873','0952') THEN
            SELECT valor
              INTO vidtransacc
              FROM sc_param
             WHERE empresa = vempresa
               AND codparam = 'TranRetATMTransfer';  
               
            CALL sp_transfer_online_retatm( vidtransacc, pnum_tarjeta, pfolsuc, vtotrettrf, pusuario )
            RETURNING vcodret_reg, vserial;
        END IF;
        
        IF ( vcodret_reg is null OR vcodret_reg <> '000' ) OR ( vserial is null OR vserial = 0 ) THEN
            IF vtransaccion = 1 THEN
                COMMIT WORK;
                BEGIN WORK;
            ELSE
                COMMIT WORK;
            END IF;
            LET vcodret = "999";
            RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret, vcodretcom, ptrancomefe, vfechoy, vsdodisp, vtotcom;
        END IF;
        
        COMMIT WORK;
        
        LET vvueltas = 0;
        LET cStatus = 'N';
        
        WHILE cStatus IN('N','E') 
            SET ISOLATION TO DIRTY READ;
            
            SELECT status, trama_res
              INTO cStatus, cTramaRes
              FROM sc_transfer_online
             WHERE no_serial = vserial
               AND cuenta = pnum_tarjeta
               AND folio_suc = pfolsuc
               AND id_transacc = vidtransacc;
               
            IF cStatus IN('F','X') THEN
                EXIT WHILE;
            ELSE
                LET vSQL = 'sleep 3'; 
                SYSTEM vSQL; 
                LET vvueltas = vvueltas + 1; 
                IF vvueltas > 5 THEN 
                    EXIT WHILE; 
                END IF; 
            END IF;
        END WHILE;
        
        IF ( cStatus is null OR cStatus = '' OR cStatus IN('N','E') ) THEN
            UPDATE {+INDEX(sc_transfer_online idx_transferonline_serctafoltra)} sc_transfer_online
               SET status = 'T'
             WHERE no_serial = vserial
               AND cuenta = pnum_tarjeta
               AND folio_suc = pfolsuc
               AND id_transacc = vidtransacc;
               
            -- // INICIO REVERSO AUTOMATICO A TRANSFER POR TIMEOUT // --
            IF ptransacc IN ('0801','0881') THEN 
                SELECT valor
                  INTO vidtransacc
                  FROM sc_param
                 WHERE empresa = vempresa
                   AND codparam = 'TranReverPosTransfer';
                   
                CALL sp_transfer_online_reversopos( vidtransacc, pnum_tarjeta, pfolsuc, pusuario, vtotrettrf, vfechoy, '' )
                RETURNING vcodret_reg, vserial;
                
            ELIF ptransacc IN ('0800','0871','0873') THEN
                SELECT valor
                  INTO vidtransacc
                  FROM sc_param
                 WHERE empresa = vempresa
                   AND codparam = 'TranReverTransfer';
                   
                CALL sp_transfer_online_reverso( vidtransacc, pnum_tarjeta, pfolsuc, pusuario )
                RETURNING vcodret_reg, vserial;
            END IF;
            
            IF ( vcodret_reg = '000' AND vserial > 0 ) THEN
                LET vvueltas = 0;
                LET cStatus = 'N';
                
                WHILE cStatus IN('N','E') 
                    SET ISOLATION TO DIRTY READ;
                    
                    SELECT status
                      INTO cStatus
                      FROM sc_transfer_online
                     WHERE no_serial = vserial
                       AND cuenta = pnum_tarjeta
                       AND folio_suc = pfolsuc
                       AND id_transacc = vidtransacc;
                       
                    IF cStatus IN('F','X') THEN
                        EXIT WHILE;
                    ELSE
                        LET vSQL = 'sleep 3'; 
                        SYSTEM vSQL;
                           
                        LET vvueltas = vvueltas + 1;
                        
                        IF vvueltas > 5 THEN
                            EXIT WHILE;
                        END IF;
                    END IF;
                END WHILE;
                
                IF ( cStatus is null OR cStatus = '' OR cStatus IN('N','E') ) THEN
                    UPDATE {+INDEX(sc_transfer_online idx_transferonline_serctafoltra)} 
                           sc_transfer_online
                       SET status = 'T'
                     WHERE no_serial = vserial
                       AND cuenta = pnum_tarjeta
                       AND folio_suc = pfolsuc
                       AND id_transacc = vidtransacc;
                END IF;
            END IF;
            -- // FINAL REVERSO AUTOMATICO A TRANSFER POR TIMEOUT // --   
               
            LET vcodret = "96"; 
            
            IF vtransaccion = 1 THEN
                BEGIN WORK;
            END IF;
               
            RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret, vcodretcom, ptrancomefe, vfechoy, vsdodisp, vtotcom;
            
        ELIF cStatus = 'X' THEN
        
            SELECT cod_ret
              INTO vcodret
              FROM sc_transfer_online
             WHERE no_serial = vserial
               AND cuenta = pnum_tarjeta
               AND folio_suc = pfolsuc
               AND id_transacc = vidtransacc;
            
            IF vtransaccion = 1 THEN
                BEGIN WORK;
            END IF;
            
            RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret, vcodretcom, ptrancomefe, vfechoy, vsdodisp, vtotcom;
        END IF;
        
        BEGIN WORK;
           
        SELECT valor
          INTO vprodtrnf
          FROM sc_param
         WHERE empresa = vempresa
           AND codparam = 'ProductoTransfer';
        
        LET vhora = CURRENT HOUR TO FRACTION;
        
        IF ptransacc IN ('0801','0881') THEN 
            LET vcodautrnf = SUBSTR(cTramaRes, 479, 6);
        ELSE
            LET vcodautrnf = '';
        END IF;
        
        -- // Inserta el movimiento en la tabla de movimientos diarios...
        INSERT INTO sc_movdia VALUES
        ( 0, pfolsuc, psucursal, pusuario, vfechoy, vfechoy, vhora, ptransacc, psucursal, vprodtrnf, vempresa, vcuenta, 
          "", 0, pmtocompra, 0, 0, 0, 0, "", "", 0.00, ptransuc, preferencia, 0, pnum_tarjeta, '', vcodautrnf, vfecha_operacion);
          
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            IF pmontocom > 0 THEN
                IF psurcharge = 'V' THEN
                    IF ptrancencom = '0857' THEN
                        let ptrancencom = '0890';
                    ELIF ptrancencom = '0858' THEN
                        let ptrancencom = '0891';
                    ELIF ptrancencom = '0859' THEN
                        let ptrancencom = '0892';
                    END IF
                    
                    INSERT INTO sc_movdia VALUES
                    ( 0, pfolsuc, psucursalcom, pusuario, vfechoy, vfechoy, vhora, ptrancencom, psucursalcom, vprodtrnf, 
                      vempresa, vcuenta, "", 0, pmontocom, 0, 0, 0, 0, "", "", 0.00, ptrancencom, prefercom, 0, pnum_tarjeta, '', '', vfecha_operacion);
                      
                    IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
                        SELECT tran_relac 
                          INTO vtraniva
                          FROM bdinteg:si_transacc
                         WHERE empresa = vempresa 
                           AND numero = ptrancencom;
                         
                        LET vivacom = pmontocom * vtasaiva;
                        
                        IF vivacom > 0 AND (vtraniva is not null or vtraniva <> '') THEN
                            INSERT INTO sc_movdia VALUES
                            ( 0, pfolsuc, psucursalcom, pusuario, vfechoy, vfechoy, vhora, ptrancencom, psucursalcom, vprodtrnf, 
                              vempresa, vcuenta, "", 0, vivacom, 0, 0, 0, 0, "", "", 0.00, ptrancencom, 'IVA '||prefercom, 0, pnum_tarjeta, '', '', vfecha_operacion);
                        END IF;
                    END IF;
                ELSE
                    INSERT INTO sc_movdia VALUES
                    ( 0, pfolsuc, psucursalcom, pusuario, vfechoy, vfechoy, vhora, ptrancencom, psucursalcom, vprodtrnf, 
                      vempresa, vcuenta, "", 0, pmontocom, 0, 0, 0, 0, "", "", 0.00, ptrancencom, prefercom, 0, pnum_tarjeta, '', '', vfecha_operacion);
                    
                    IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
                        SELECT tran_relac 
                          INTO vtraniva
                          FROM bdinteg:si_transacc
                         WHERE empresa = vempresa 
                           AND numero = ptrancencom;
                         
                        LET vivacom = pmontocom * vtasaiva;
                        
                        IF vivacom > 0 AND (vtraniva is not null or vtraniva <> '') THEN
                            INSERT INTO sc_movdia VALUES
                            ( 0, pfolsuc, psucursalcom, pusuario, vfechoy, vfechoy, vhora, ptrancencom, psucursalcom, vprodtrnf, 
                              vempresa, vcuenta, "", 0, vivacom, 0, 0, 0, 0, "", "", 0.00, ptrancencom, 'IVA '||prefercom, 0, pnum_tarjeta, '', '', vfecha_operacion);
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
        ############################################################################################################################################ */
        
    ELSE
        
        --- select sucursal, sdo_actual - sdo_retenido - sdo_cong
        ---   into vsuccta, vsdodisp
        -- RQM 09 704. Se retiran llamados a variables que vienen incluidas en le spl sp_cons_sdodisp_x_tpcalculo.LEOC
        select sucursal, sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbg, saldo_sbc
          into vsuccta, msdo_actual, msdo_retenido, msdo_cong, mimp_chq_sbg, mSaldoSbc
          from sc_maechq
         where empresa = vempresa 
           and cuenta = vcuenta;
		   
   -- // 05/06/2021
		   
		execute procedure sp_cargo_val(vcuenta)
		into vcodret;

		if vcodret <> '00000' then
			let vcodret = '307';
			RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret, vcodretcom, ptrancomefe, vfechoy, vsdodisp, vtotcom;
		end if;
		
    -- // 05/06/2021
     -- RQM 09 704. Se comenta el codigo(VALIDACIONES) que vienen incluido en el spl sp_cons_sdodisp_x_tpcalculo. LEOC     
     -- RQM 09 704. Se des comenta el codigo(VALIDACIONES) que viene incluido en el spl sp_cons_sdodisp_x_tpcalculo el cual ya no se utilizara. DFTL  
    if msdo_retenido < 0 then
            let msdo_retenido = msdo_retenido * -1;
    end if;
        
    if msdo_cong < 0 then
            let msdo_cong = msdo_cong * -1;
    end if;
        
    if mimp_chq_sbg < 0 then
            let mimp_chq_sbg = mimp_chq_sbg * -1;
    end if;  

    IF mSaldoSbc < 0 THEN
        let mSaldoSbc = mSaldoSbc * -1;
    END IF; 

     -- RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. LEOC
    --EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo('',msdo_actual,msdo_retenido,msdo_cong,mSaldoSbc,mimp_chq_sbg,'','','F','1') INTO cCodRetConsSdo,cMensajeRetConsSdo,vsdodisp;
    -- RQM 09 704. Se agrega la variable mSaldoSbc a la de consulta de saldo . DFTL
    let vsdodisp = msdo_actual - ( msdo_retenido + msdo_cong + mimp_chq_sbg + mSaldoSbc);
    

        if vsdodisp is null or vsdodisp < 0 then
            let vsdodisp = 0.00;
        end if;
           
        if vsuccta is null or vsuccta = '' then
            let vcodret = "100";
            if vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            else
                ROLLBACK WORK;
            end if;
            
            RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret, vcodretcom, ptrancomefe, vfechoy, vsdodisp, vtotcom;
        end if
           
        if pmontoefe > 0 then --LAGS y RRM
           if ptransefe is null or ptransefe = '' or ptransefe = '0805' then 
               let ptransefe = '0805'; -- Se pone en duro ya que al ser cash Back libre no se puede identificar la transaccion
               let pfolioefe = pfolsuc; -- Para que tome el folio de la trasaccion original 
            end if
        end if
        
        if vsdodisp < vtotret then
            let vcodret = "400";
            if vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            else
                ROLLBACK WORK;
            end if;
            
            RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret, vcodretcom, ptrancomefe, vfechoy, vsdodisp, vtotcom;
        end if

        if pmtocompra > 0 then
            call cargo_ref_td(vempresa,psucursal,pusuario,ptransacc,ptransuc,pfolsuc,vcuenta,pcheque,pmtocompra,pdivisa,preferencia,pnum_tarjeta,"")
            returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
            
            if vcodret <> "000" then
                if vtransaccion = 1 then
                    ROLLBACK WORK;
                    BEGIN WORK;
                else
                    ROLLBACK WORK;
                end if;
                
                RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret, vcodretcom, ptrancomefe, vfechoy, vsdodisp, vtotcom;
            end if
        end if

        if pmontoefe > 0 then	       
            call cargo_ref_td(vempresa,psucursal,pusuario,ptransefe,ptransuc,pfolioefe,vcuenta,pcheque,pmontoefe,pdivisa,preferencia,pnum_tarjeta,"")
            returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
            
            if vcodret <> "000" then
                if vtransaccion = 1 then
                    ROLLBACK WORK;
                    BEGIN WORK;
                else
                    ROLLBACK WORK;
                end if;
                
                RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret, vcodretcom, ptrancomefe, vfechoy, vsdodisp, vtotcom;
            end if
        end if
        
        if pmontocom > 0 then
            if psurcharge = 'V' then
                if ptrancencom = '0857' then
                    let ptrancencom = '0890';
                elif ptrancencom = '0858' then
                    let ptrancencom = '0891';
                elif ptrancencom = '0859' then
                    let ptrancencom = '0892';
                end if
                
                call cargo_ref_td(vempresa,psucursal,pusuario,ptrancencom,ptransuccom,pfolsuccom,vcuenta,pchequecom,pmontocom,pdivisacom,prefercom,pnum_tarjeta,"")
                returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
                
                if vcodret <> "000" then
                    if vtransaccion = 1 then
                        ROLLBACK WORK;
                        BEGIN WORK;
                    else
                        ROLLBACK WORK;
                    end if;
                    
                    RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret, vcodretcom, ptrancomefe, vfechoy, vsdodisp, vtotcom;
                else
                    select tran_relac 
                      into vtraniva
                      from bdinteg:si_transacc
                     where empresa = vempresa 
                       and numero = ptrancencom;
                     
                    let vivacom = pmontocom * vtasaiva;
                    
                    if vivacom > 0 and (vtraniva is not null or vtraniva <> '') then
                        call cargo_ref_td(vempresa,psucursal,pusuario,vtraniva,"0000",pfolsuccom,vcuenta,pchequecom,vivacom,pdivisacom,prefercom,pnum_tarjeta,"")
                        returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
            
                        if vcodret <> "000" then
                            if vtransaccion = 1 then
                                ROLLBACK WORK;
                                BEGIN WORK;
                            else
                                ROLLBACK WORK;
                            end if;
                            
                            RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret, vcodretcom, ptrancomefe, vfechoy, vsdodisp, vtotcom;
                        end if
                    end if
                end if
            else            
                call cargo_ref_td(vempresa,psucursal,pusuario,ptrancencom,ptransuccom,pfolsuccom,vcuenta,pchequecom,pmontocom,pdivisacom,prefercom,pnum_tarjeta,"")
                returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
                
                if vcodret <> "000" then
                    if vtransaccion = 1 then
                        ROLLBACK WORK;
                        BEGIN WORK;
                    else
                        ROLLBACK WORK;
                    end if;
                    
                    RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret, vcodretcom, ptrancomefe, vfechoy, vsdodisp, vtotcom;
                else
                    select tran_relac 
                      into vtraniva
                      from bdinteg:si_transacc
                     where empresa = vempresa 
                       and numero = ptrancencom;
                     
                    let vivacom = pmontocom * vtasaiva;
                    
                    if vivacom > 0 then
                        call cargo_ref_td(vempresa,psucursal,pusuario,vtraniva,"0000",pfolsuccom,vcuenta,pchequecom,vivacom,pdivisacom,prefercom,pnum_tarjeta,"")
                        returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
            
                        if vcodret <> "000" then
                            if vtransaccion = 1 then
                                ROLLBACK WORK;
                                BEGIN WORK;
                            else
                                ROLLBACK WORK;
                            end if;
                            
                            RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret, vcodretcom, ptrancomefe, vfechoy, vsdodisp, vtotcom;
                        end if
                    end if
                end if
            end if
        end if
        
        if pmtocomefe > 0 then
            call cargo_ref_td(vempresa,psucursal,pusuario,ptrancomefe,ptrancomefe,pfolcomefe,vcuenta,pchequeefe,pmtocomefe,pdivcomefe,prefcomefe,pnum_tarjeta,"")
            returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
            
            if vcodret <> "000" then
                if vtransaccion = 1 then
                    ROLLBACK WORK;
                    BEGIN WORK;
                else
                    ROLLBACK WORK;
                end if;
                
                RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret, vcodretcom, ptrancomefe, vfechoy, vsdodisp, vtotcom;
            else
                select tran_relac 
                  into vtraniva
                  from bdinteg:si_transacc
                 where empresa = vempresa 
                   and numero = ptrancencom;
                   
                let vivacom = pmtocomefe * vtasaiva;
                
                if vivacom > 0 then
                    call cargo_ref_td(vempresa,psucursal,pusuario,vtraniva,"0000",pfolcomefe,vcuenta,pchequeefe,vivacom,pdivcomefe,prefcomefe,pnum_tarjeta,"")
                    returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
                    
                    if vcodret <> "000" then
                        if vtransaccion = 1 then
                            ROLLBACK WORK;
                            BEGIN WORK;
                        else
                            ROLLBACK WORK;
                        end if;
                        
                        RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret, vcodretcom, ptrancomefe, vfechoy, vsdodisp, vtotcom;
                    end if
                end if
            end if
        end if
        
        let vfechoy = vfecapli;
        
        --- select sdo_actual - sdo_retenido - sdo_cong 
        ---   into vsdodisp
        
        -- RQM 09 704. Se comenta el codigo(BUSQUEDA Y VALIDACIONES) que vienen incluido en el spl sp_cons_sdodisp_x_tpcalculo. LEOC
        -- RQM 09 704. Se des comenta el codigo(VALIDACIONES) que viene incluido en el spl sp_cons_sdodisp_x_tpcalculo el cual ya no se utilizara. DFTL  
        select sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbg, saldo_sbc
          into msdo_actual, msdo_retenido, msdo_cong, mimp_chq_sbg, mSaldoSbc
          from sc_maechq
         where empresa = vempresa 
           and cuenta = vcuenta;
           
        if msdo_retenido < 0 then
            let msdo_retenido = msdo_retenido * -1;
        end if;
        
        if msdo_cong < 0 then
            let msdo_cong = msdo_cong * -1;
        end if;
        
        if mimp_chq_sbg < 0 then
            let mimp_chq_sbg = mimp_chq_sbg * -1;
        end if;  
        
        -- RQM 09 704. Se agrega la siguiente validacion
        IF mSaldoSbc < 0 THEN
            let mSaldoSbc = mSaldoSbc * -1;
        END IF; 
        
        -- RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. LEOC
        --EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo('',msdo_actual,msdo_retenido,msdo_cong,mSaldoSbc,mimp_chq_sbg,'','','F','1') INTO cCodRetConsSdo,cMensajeRetConsSdo,vsdodisp;
        -- RQM 09 704. Se agrega la variable mSaldoSbc a la consulta del saldo DFTL
        let vsdodisp = msdo_actual - ( msdo_retenido + msdo_cong + mimp_chq_sbg + mSaldoSbc);
        
        if vsdodisp is null or vsdodisp < 0 then
            let vsdodisp = 0.00;
        end if;
           
    END IF;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
        
    RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret, vcodretcom, ptrancomefe, vfechoy, vsdodisp, vtotcom;
    
    END;
    
END PROCEDURE
DOCUMENT
'AUTOR:         N/A',
'DESCRIPCION :  Este procedimiento tiene como proposito realizar operaciones de cargo a una cuenta asociada a una cuenta de cheques, con multiples validaciones y transacciones ',
'BD :           bdicheq',
'VERSION :      1.0.0',
'FECHA :        N/A',
'----------------------------------------------------',
'MODIFICO :     Luis Enrique Orozco Cosme',
'FECHA :        13-06-2025',
'MODIFICACION : Se modifica el calculo de saldo disponible para homologarlo con el llamado a un nuevo spl sp_cons_sdodisp_x_tpcalculo',
'PROYECTO :     RQM 09 704 Cobranza Automatica en Cuentas de Captacion',
'BD :           bdicheq',
'VERSION :      1.0.1',
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/09/02',
'RAZON:                 Se agregan validaciones y se quita el sp sp_cons_sdodisp_x_tpcalculo',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.0.3';

CREATE PROCEDURE "informix".sp_dispercionnomina_bpi(psucursal CHAR(4), pnombrearchivo CHAR(20) )

-- ******************************************************************************************
-- Realizo   : Martin Valenzuela Ojeda, Armando Mercado
-- Proyecto  : Dispersion Nomina BanCoppel
-- Actividad : Ejecuta el proceso para la dispersion de la nomina,
--             actualiza el campo status en el detalle de aquellos empleados
--             que si se les ejecuto el pago de la nomina y
--             aquellos que por algun motivo no se les disperso su sueldo.
--             Tambien actualiza el encabezado para aquellos archivos que fueron dispersados,
--             ejecutando las validaciones correspondientes.
--             Este store sera ejecutado para varios archivos en Batch
-- Fecha     : Abril de 2008
-- ActualizaciÃ³n 2025-08-15 INC 03 500 EmpresaNet - AplicaciÃ³n Parcial de NÃ³mina.
-- mtinajero - lbaldivia
-- ValidaciÃ³n para que cuando se haga una aplicaciÃ³n parcial de nÃ³mina, marque sin errores la ejecuciÃ³n completa
-- ******************************************************************************************

RETURNING CHAR(5);

-- // DefiniciÃÂ³n de Variables
DEFINE GLOBAL mtotalregspei             INTEGER	DEFAULT 0;

DEFINE cNumeroEmpresa                   CHAR(3);
DEFINE dFechaGeneracion                 DATE;
DEFINE IFolioArchivo                    INTEGER;
DEFINE dFechaActual                     DATE;
DEFINE cEstatusCta                      CHAR(1);
DEFINE cNumeroCuentaEmpleado            CHAR(20);
DEFINE cNumeroEmpleado                  CHAR(10);
DEFINE mImporteEmpleado                 MONEY(14,3);
DEFINE dFechaAplicacion                 DATE;
DEFINE cHoraActual                      DATETIME HOUR TO SECOND;
DEFINE cNumeroTarjeta                   CHAR(20);
DEFINE mImporteAbonado                  MONEY(16,3);
DEFINE mImporteNoAbonado                MONEY(16,3);
DEFINE mImporteTotalAplicado            MONEY(16,3);
DEFINE siSaldoDisponible                SMALLINT;
DEFINE mTotalNoPagado                   MONEY(16,3);
DEFINE mTotalComisionDispercionIvaEmp   MONEY(14,3);
DEFINE mImporteTotalEnc                 MONEY(14,3);
DEFINE mSaldoActual                     MONEY(14,3);
DEFINE iNumeroRegistros                 INTEGER;
DEFINE bPrimerEmpleado                  BOOLEAN;
DEFINE bSiguienteEmpleado               BOOLEAN;
DEFINE cCodRet                          CHAR(3);
DEFINE cMensaje                         CHAR(100);
DEFINE mTotaliva                        MONEY(14,3);
DEFINE mTotalComision                   MONEY(14,3);
DEFINE iCodigoEstatus                   INTEGER;
DEFINE vsqlerr                          INTEGER;
DEFINE vcodret                          VARCHAR(6);
DEFINE p_mensaje                        VARCHAR(100);
DEFINE cNumeroFolio                     CHAR(16);
DEFINE cNombreArchivo                   CHAR(30);
DEFINE vtranret                         CHAR(4);
DEFINE vfechoy                          DATE;
DEFINE vsdodisp                         MONEY(14,2);
DEFINE vmontoret                        MONEY(14,2);
DEFINE cFolioDispercion                 CHAR(16);
DEFINE mComisionAplicado                MONEY(16,3);
DEFINE mIvaAplicado                     MONEY(16,3);
DEFINE cNombreArchivoConciliacion       CHAR(20);
DEFINE cCuentaEje                       CHAR(20);
DEFINE cCuentaEjeClabe					CHAR(20);
DEFINE cUsuarioAutoriza                 CHAR(8);
DEFINE siValorStatus					SMALLINT;

-- // Variables del sp: conciliacionDispercionNomina
DEFINE v_cCodRet                        CHAR(5);

-- // Nuevas Variables
DEFINE siValorConcepto                  SMALLINT;
DEFINE siValorConceptoAnterior          SMALLINT;
DEFINE cValorTransaccion                CHAR(4);
DEFINE cValorTipoTransaccion            CHAR(3);
DEFINE cTransaccAbono                   CHAR(4);
DEFINE cTransaccCargo                   CHAR(4);
DEFINE mMontoTransComiDisp              MONEY(16,2);
DEFINE mMontoTransComiAper              MONEY(16,2);
DEFINE mMontoTransIvaDisp               MONEY(16,2);
DEFINE mMontoTransIvaAper               MONEY(16,2);
DEFINE mMontoFijo                       MONEY(16,2);
DEFINE mTotalPagado                     MONEY(16,3);
DEFINE mTotalCargo                      MONEY(16,3);
DEFINE cTransaccComiDisp                CHAR(4);    -- // Aqui se traera el 0394
DEFINE cTransacIvaDisp                  CHAR(4);    -- // Aqui se traera el 0396
DEFINE mImporteEmpleadoCuentaEje        MONEY(16,3);
DEFINE mImporteEmpleadoComisionMasIva   MONEY(16,3);
DEFINE cEstatusCuenta                   CHAR(1);
DEFINE vcodretCargo1                    CHAR(6);
DEFINE vcodretCargo2                    CHAR(6);
DEFINE vcodretCargo3                    CHAR(6);
DEFINE vBegin                           CHAR(1);
DEFINE mIvaPorEmpleado                  MONEY(16,2);
DEFINE siTipoEmpresa                    SMALLINT ;
DEFINE cSucursalAbono                   CHAR(4);
DEFINE cSucursalCargo                   CHAR(4);
DEFINE cRecDatonoUtilizableNOperacion   CHAR(4);
DEFINE siVuelta                         INTEGER ;
DEFINE cCargo               			CHAR(2);
DEFINE cAbono               			CHAR(2);
DEFINE cAceptaProducto         			CHAR(50);
DEFINE iContador						INTEGER;
DEFINE vexiste_encab                    CHAR(17);
DEFINE vexiste_ctaeje                   CHAR(20);
DEFINE vexiste_cta                      CHAR(20);
DEFINE cProducto                        CHAR(20);
DEFINE vexiste_sec                      SMALLINT;
DEFINE iNumeroRegistrosAplicados        INTEGER ;
DEFINE vspei                            CHAR(1);
DEFINE mtotalspei                       MONEY(16,3);
DEFINE mtotalcomspei                    MONEY(16,3);
DEFINE mtotalivaspei                    MONEY(16,3);
DEFINE vcomisionspei                    MONEY(16,3);
DEFINE vcomisionspei_gral               MONEY(16,3);  --aqui
DEFINE vnombre_empresa                  CHAR(40);
DEFINE vnumcte_empresa                  CHAR(20); 
DEFINE vrfc_empresa                     CHAR(13);
DEFINE vnombre_beneficiario             CHAR(40);
DEFINE verror                           CHAR(100);
DEFINE vcverastreo                      CHAR(30);
DEFINE vcvebanco_benef					CHAR(5);
DEFINE vcvebanco_cta					CHAR(3);
DEFINE mDispCtaBcoppel					MONEY;
DEFINE mDispCtaOtroBco					MONEY;
--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
DEFINE vExcentaComision					INTEGER;
DEFINE cProductoEje                     CHAR(20);

--INC 03 500
DEFINE cUnoExitoso                      CHAR(1);

-- // VALORES INICIALES
LET siValorStatus = 0;
LET p_mensaje = " ";
LET dFechaActual = '' ;
LET cEstatusCta = '' ;
LET cNumeroCuentaEmpleado = '';
LET cNumeroEmpleado = '';
LET mImporteEmpleado = 0;
LET dFechaAplicacion = '';
LET cHoraActual = '' ;
LET cNumeroTarjeta = '';
LET mImporteAbonado = 0;
LET mImporteNoAbonado = 0;
LET mImporteTotalAplicado = 0;
LET siSaldoDisponible = 0 ;
LET mTotalNoPagado = 0;
LET mTotalComisionDispercionIvaEmp = 0;
LET mImporteTotalEnc = 0;
LET mSaldoActual = 0;
LET iNumeroRegistros = 0;
LET iCodigoEstatus = 0;
LET bPrimerEmpleado = "T" ;
LET bSiguienteEmpleado = "F" ;
LET cNombreArchivo = "";
LET iNumeroRegistrosAplicados = 0;
LET siValorConceptoAnterior = 0;
LET cValorTransaccion = '';
LET cValorTipoTransaccion = '';
LET cTransaccAbono = '';
LET cTransaccCargo = '';
LET mMontoTransComiDisp = 0;
LET mMontoTransComiAper = 0;
LET mMontoTransIvaDisp = 0;
LET mMontoTransIvaAper = 0;
LET mMontoFijo = 0;
LET mTotalPagado = 0;
LET mTotalCargo = 0;
LET cTransaccComiDisp = '';
LET cTransacIvaDisp = '';
LET mImporteTotalEnc = 0;
LET mImporteEmpleadoCuentaEje = 0;
LET mImporteEmpleadoComisionMasIva = 0;
LET cEstatusCuenta = '';
LET vBegin = 'N';
LET mIvaPorEmpleado = 0;
LET siTipoEmpresa = 0;
LET cSucursalAbono = '';
LET cSucursalCargo = '';
LET siVuelta = 0;
LET cCargo='';
LET cAbono='';
LET cAceptaProducto = '';
LET cNumeroFolio = '';
LET iContador = 0;
LET vexiste_encab = '';
LET vexiste_ctaeje = '';
LET vexiste_cta = '';
LET vexiste_sec = 0;
LET vspei = 0;
LET mtotalspei = 0;
LET mtotalregspei = 0;
LET mtotalcomspei = 0;
LET mtotalivaspei = 0;
LET vcomisionspei = 0;
LET vcomisionspei_gral = 0; --aqui
LET vnombre_empresa = ' ';
LET vnumcte_empresa = ' ';
LET vrfc_empresa = ' ';
LET vnombre_beneficiario = ' ';
LET verror = ' ';
LET vcverastreo = ' ';
LET vcvebanco_benef = ' ';
LET vcvebanco_cta = ' ';
LET cproducto = '';
LET mDispCtaBcoppel	= 0.0;
LET mDispCtaOtroBco	= 0.0;
LET cUnoExitoso = '0';

--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
LET vExcentaComision = 0;
LET cProductoEje = '';

	--SET debug FILE TO "/home/informix/BereniceOut/sp_dispercionnomina_bpi1paramSUC.out";
	--Trace ON;

BEGIN

	ON EXCEPTION SET vsqlerr
		IF vsqlerr <> 0 OR vsqlerr <> -206 THEN
			LET vcodret = vsqlerr;  --- Dispercion No Ejecutada
			LET cFolioDispercion = "";
			LET mImporteTotalAplicado = 0;
			LET mComisionAplicado = 0;
			LET mIvaAplicado = 0;
			LET cNombreArchivoConciliacion = "";
			IF vBegin = 'S' THEN
				ROLLBACK WORK;
			END IF;
			RETURN vcodret;
		END IF;
	END EXCEPTION;

	ON EXCEPTION IN (-535)
      LET vBegin = 'S';
      COMMIT WORK;
 	END EXCEPTION WITH RESUME;
	
	SET ISOLATION TO CURSOR STABILITY;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;

		SELECT fecha_hoy
	  INTO dFechaActual
	  FROM bdicheq:sc_fechas
	 WHERE empresa = "001";

	SELECT FIRST 1 nombre_archivo
	--SELECT nombre_archivo
	  INTO vexiste_encab
	  FROM bdicheq:sc_nominaencabezadosumario_bpi
	 WHERE status = '1'
	   AND fecha_aplicacion = dFechaActual
	   AND nombre_archivo=pnombrearchivo;

	IF vexiste_encab IS NULL OR vexiste_encab = '' THEN
		LET vcodret = '805'; --- Dispercion No Ejecutada: No Existe el Encabezado del Archivo Ã??el Estatus No es el Correcto;
		RETURN vcodret;
	END IF

	LET cHoraActual = CURRENT;

	-- // Se borra la tabla de control al inicio de cada ciclo
	--TRUNCATE TABLE bdicheq:sc_nominaresultadosdispercionautomatica;

	SELECT valor
	  INTO mMontoTransIvaDisp
	  FROM bdinteg:si_param
	 WHERE cod_param = 47
	   AND empresa = "001";
	   
	--SELECT mnycomision
	--	INTO vcomisionspei_gral --aqui
	--	FROM bdispei:tblcomision; 
	  
	-- OBTIENE EL VALOR DE LA COMISION POR DISPERSION DE CTAS DE OTRO BANCO EN LA TABLA si_transsacc con el numero '3257'
	SELECT monto_fijo 
	  INTO vcomisionspei_gral
	  FROM bdinteg:"informix".si_transacc
	 WHERE sistema = '01' 
	   AND empresa = '001'
	   AND numero = '3257';
	  
	IF (mMontoTransIvaDisp = "") OR (mMontoTransIvaDisp = " ") OR (mMontoTransIvaDisp IS NULL) THEN
		LET vcodret = '855';  --- Dispercion No Ejecutada: El Valor del Iva No es Valido
		RETURN vcodret;
	END IF	
	
	FOREACH WITH HOLD
		SELECT empresa, fecha_gen, folio_archivo, nombre_archivo, cuenta_cargo, fecha_aplicacion, total_registros, importe_tot
		  INTO cNumeroEmpresa, dFechaGeneracion, IFolioArchivo, cNombreArchivo, cCuentaEje, dFechaAplicacion, iNumeroRegistros, mImporteTotalEnc
		  FROM bdicheq:sc_nominaencabezadosumario_bpi
		 WHERE status = '1'
		   AND fecha_aplicacion <= dFechaActual
		   AND nombre_archivo=pnombrearchivo
		 ORDER BY empresa, nombre_archivo

		BEGIN WORK;
		LET vBegin = 'S';
		LET vcodret = '000';

		-- // Consulta el Tipo de empresa
		SELECT tipo_empresa, TRIM(acepta_producto), nombre, numcte
		  INTO siTipoEmpresa, cAceptaProducto, vnombre_empresa, vnumcte_empresa
		  FROM bdicheq:sc_nominaempresas
		 WHERE codigo = cNumeroEmpresa;
		 
		SELECT rfc INTO vrfc_empresa
          FROM bdinteg:si_cliente
         WHERE numcte = vnumcte_empresa;		  

		SELECT LIMIT 1 concepto --, nombre_archivo
		  INTO siValorConcepto --, cNombre
		  FROM bdicheq:sc_nominamovimientos_bpi
		 WHERE nombre_archivo = cNombreArchivo
		   AND status = '0';

		--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
		SELECT cuenta, cuenta_clabe, sdo_actual, producto
		  INTO vexiste_ctaeje, cCuentaEjeClabe, mSaldoActual, cProductoEje
		  FROM bdicheq:sc_maechq
		 WHERE empresa = '001'
		   AND cuenta = cCuentaEje;

		--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
		SELECT COUNT(1) INTO vExcentaComision FROM bdicheq:sc_nominaexcentocomision WHERE producto = cProductoEje;

		IF vexiste_ctaeje IS NULL THEN
			LET vcodret  = "810"; --- La cuenta NO Existe en la Base de Datos

				--// Nueva Instruccion Para actualizar el encabezado y saber porque no se disperso el Archivo
			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = '7', --
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo
			   AND nombre_archivo = cNombreArchivo;
			COMMIT WORK;
				LET vBegin = 'N';
			CONTINUE FOREACH;

		ELSE
			
			--CALL sp_dispersionnominavalidacionestatus_bpi (cCuentaEje, cNumeroEmpresa, dFechaGeneracion::CHAR(10), iFolioArchivo, dFechaActual::CHAR(10), cHoraActual::CHAR(8), '', '', 0.0, 0.0, '')
				--SE agrega validaciÃÂ³n del nombre del archivo **gaguilar**
				CALL sp_dispersionnominavalidacionestatus_bpi (cCuentaEje, cNumeroEmpresa, dFechaGeneracion::CHAR(10), iFolioArchivo, dFechaActual::CHAR(10), cHoraActual::CHAR(8), 'cNombreArchivo', '', 0.0, 0.0, '')
				RETURNING vcodret, cEstatusCuenta, cCargo, mImporteNoAbonado, cSucursalCargo, cRecDatonoUtilizableNOperacion;
			
			IF vcodret <> '000' THEN
				COMMIT WORK;
				LET vBegin = 'N';
				CONTINUE FOREACH;
			END IF
		END IF
		
		--// OBTIENE EL VALOR DE LA COMISION POR DISPERSION DE CTAS DE BANCOPPEL EN LA TABLA MAESTRA DE COMISIONES DE PERSONAS MORALES
		SELECT disp_cta_bcoppel, disp_cta_otrobco
		INTO mDispCtaBcoppel, mDispCtaOtroBco
		FROM "informix".sc_maecomtasserv_pm
		WHERE cuenta = cCuentaEje;
		
		--// OBTIENE EL VALOR DE LA COMISION POR DISPERSION DE CTAS DE OTRO BANCO EN LA TABLA MAESTRA DE COMISIONES DE PERSONAS MORALES
		{
		SELECT disp_cta_otrobco
		INTO mDispCtaOtroBco
		FROM "informix".sc_maecomtasserv_pm
		WHERE cuenta = cCuentaEje;
		}

		LET cUsuarioAutoriza = "informix";
		LET mTotalNoPagado = 0;
		LET mImporteAbonado = 0;
		LET mImporteNoAbonado = 0;
		LET mImporteTotalAplicado = 0;
		LET mTotalPagado = 0;
		LET iNumeroRegistrosAplicados = 0;
		LET mTotalCargo = 0;
		LET mtotalspei = 0;
		LET mtotalregspei = 0;
        LET mtotalcomspei = 0;
        LET mtotalivaspei = 0; 

		IF (cNombreArchivo IS NULL) OR (cNombreArchivo = "") OR (cNombreArchivo = " ") THEN
			LET vcodret = '830';
			LET p_mensaje = "Dispercion No Ejecutada: Existe el Encabezado Pero No Existe el Detalle del Archivo";
			LET cFolioDispercion = "";
			LET mImporteTotalAplicado = 0;
			LET mComisionAplicado = 0;
			LET mIvaAplicado = 0;
			LET cNombreArchivoConciliacion = "";

			LET vcodret = '000'; --- Este codigo se deja en 000 porque el ciclo continua ejecutandose para otro archivo y necesita llevar este valor

			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = '6', --Importe restaurado a la cuenta
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo
			   AND nombre_archivo = cNombreArchivo;

			COMMIT WORK;
			LET vBegin = 'N';
		END IF

		LET siValorConceptoAnterior = 0; --- Aqui inicializo la variable cada vez que se vaya a procesar otro archivo

		-- // Se Limpian las Variables en Cada Vuelta
		LET cTransaccAbono = "";
		LET cTransaccCargo = "";
		LET cTransaccComiDisp = "";
		LET cTransacIvaDisp = "";
		LET vcodret = '000';

		{
		SELECT sdo_actual
		  INTO mSaldoActual
		  FROM bdicheq:sc_maechq
		 WHERE empresa ='001'
		   AND cuenta = cCuentaEje;
		}

		SELECT MIN(importe)
		  INTO mImporteEmpleado
		  FROM bdicheq:sc_nominamovimientos_bpi
		 WHERE nombre_archivo = cNombreArchivo
		   AND status = '0'; --- Con status <> 1 tomo todos los registros que no hayan sido procesados

		--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
		IF vExcentaComision > 0 THEN 
			LET mIvaPorEmpleado = 0;
			LET mTotalComisionDispercionIvaEmp = 0;
			LET mImporteEmpleadoCuentaEje = mImporteEmpleado;
		ELSE
			LET mIvaPorEmpleado = mMontoTransComiDisp * mMontoTransIvaDisp;
			LET mTotalComisionDispercionIvaEmp = mMontoTransComiDisp + mIvaPorEmpleado;
			LET mImporteEmpleadoCuentaEje = mImporteEmpleado + mTotalComisionDispercionIvaEmp;
		END IF

			--- Linea nueva aqui valido que por lo menos exista saldo para pagar a un empleado
		IF (mSaldoActual <= 0) OR (mSaldoActual < mImporteEmpleadoCuentaEje) THEN
			LET siSaldoDisponible = 0;
			LET vcodret = '835';
			LET p_mensaje = "Dispercion No Ejecutada: La Cuenta Eje No Tiene Saldo";
			LET cFolioDispercion = "";
			LET mImporteTotalAplicado = 0;
			LET mComisionAplicado = 0;
			LET mIvaAplicado = 0;
			LET cNombreArchivoConciliacion = "";
			LET vcodret = '000'; --- Este codigo se deja en 000 porque el ciclo continua para otro archivo y necesita llevar este valor

			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = '5', --Saldo insuficiente
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo
			   AND nombre_archivo = cNombreArchivo;

			COMMIT WORK;
			LET vBegin = 'N';
			CONTINUE FOREACH;
		ELSE
			LET siSaldoDisponible = 1;
			LET mImporteEmpleado = 0;
			LET mTotalComisionDispercionIvaEmp = 0;
			LET mImporteEmpleadoCuentaEje = 0;
		END IF

		LET cNumeroEmpresa = cNumeroEmpresa;
		LET siValorConcepto = siValorConcepto;

		-- // CICLO PARA VALIDAR LOS VALORES DE LAS TRANSACCIONES
		--- CALL sp_dispersionnominatransacciones (siTipoEmpresa, cNumeroEmpresa, siValorConcepto)
        CALL sp_dispersionnominatransacciones (siTipoEmpresa, siValorConcepto)
		RETURNING vcodret, cValorTipoTransaccion, cValorTransaccion, mMontoFijo, cTransaccAbono, cTransaccCargo,
				  cTransaccComiDisp, mMontoTransComiDisp, mMontoTransComiAper, cTransacIvaDisp, mMontoTransIvaAper;

		IF vcodret <> '000' THEN
			-- // El Numero De transaccion es Invalido o No Existe
			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = '4', --No aplicado cuenta inexistente
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo
			   AND nombre_archivo = cNombreArchivo;

			COMMIT WORK;
			LET vBegin = 'N';
			CONTINUE FOREACH;
		END IF

		LET siVuelta = 0;
		
		--aqui	
		IF mDispCtaOtroBco IS NOT NULL THEN
			LET vcomisionspei = mDispCtaOtroBco;
		ELSE
            LET vcomisionspei = vcomisionspei_gral;
		END IF		
		
		LET vcomisionspei = NVL(vcomisionspei,0);
		
		--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
		IF vExcentaComision > 0 THEN 
			LET vcomisionspei = 0;
		END IF
		
		--INC 03 500
		LET cUnoExitoso = '0';

		FOREACH WITH HOLD

			SELECT mov.num_empleado, mov.cuenta_abono, mov.importe, mov.concepto,
                   TRIM(nombres)||" "||TRIM(apell_paterno)||" "||TRIM(apell_materno)			
			  INTO cNumeroEmpleado, cNumeroCuentaEmpleado, mImporteEmpleado, siValorConcepto, vnombre_beneficiario
			FROM bdicheq:sc_nominamovimientos_bpi mov
			WHERE mov.nombre_archivo = cNombreArchivo
			  AND mov.status = 0 --- Con status <> 1 tomo todos los registros que no hayan sido procesados
			ORDER BY mov.importe

			LET cProducto = ' ';
			
            IF LENGTH(cNumeroCuentaEmpleado) <> 18 THEN
			   SELECT mae.status_cta, mae.producto
			     INTO siValorStatus, cProducto
			     FROM bdicheq:sc_maechq mae
			    WHERE mae.empresa = '001'
				  AND mae.cuenta = cNumeroCuentaEmpleado;
			   LET vspei = '0';
			ELSE
               LET vspei = '1';
            END IF

			LET siVuelta = siVuelta + 1;
			LET iContador = iContador + 1;

			IF (siValorConcepto <> 0) AND (siValorConceptoAnterior <> siValorConcepto) THEN
				LET siValorConceptoAnterior = siValorConcepto;
			END IF

			-- // CICLO PARA VALIDAR LOS VALORES DE LAS TRANSACCIONES
			--- CALL sp_dispersionnominatransacciones(siTipoEmpresa, cNumeroEmpresa, siValorConcepto)
            CALL sp_dispersionnominatransacciones(siTipoEmpresa, siValorConcepto)
			RETURNING vcodret, cValorTipoTransaccion, cValorTransaccion, mMontoFijo, cTransaccAbono, cTransaccCargo,
					  cTransaccComiDisp, mMontoTransComiDisp, mMontoTransComiAper, cTransacIvaDisp, mMontoTransIvaAper;

			IF vcodret <> '000' THEN
				-- // El Numero De transaccion es Invalido o No Existe
				UPDATE bdicheq:sc_nominaencabezadosumario_bpi
				   SET status = '4', --Error
					   fecha_aplicado = dFechaActual,
					   hora_aplicado = cHoraActual
				 WHERE empresa = cNumeroEmpresa
				   AND fecha_gen = dFechaGeneracion
				   AND folio_archivo = IFolioArchivo
				   AND nombre_archivo = cNombreArchivo;

				COMMIT WORK;
				LET vBegin = 'N';
				LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
				CONTINUE FOREACH;
			END IF

			LET cAceptaProducto = TRIM(cAceptaProducto);

		    IF (cProducto IS NULL OR cProducto = ' ') AND vspei = '0' THEN
				-- // Cuenta no existe
				UPDATE bdicheq:sc_nominamovimientos_bpi
				SET status = '4'
				WHERE nombre_archivo = cNombreArchivo
				AND num_empleado = cNumeroEmpleado;

				LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
				CONTINUE FOREACH;
	        END IF

			--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
			IF vExcentaComision > 0 THEN 
				LET mIvaPorEmpleado = 0;
				LET mTotalComisionDispercionIvaEmp = 0;
				LET mImporteEmpleadoComisionMasIva = mImporteEmpleado;
			ELSE
				-- // Inicio de validacion de tipo de empresa externas
				LET mIvaPorEmpleado = mMontoTransComiDisp * mMontoTransIvaDisp;
				LET mTotalComisionDispercionIvaEmp = mMontoTransComiDisp + mIvaPorEmpleado;
				LET mImporteEmpleadoComisionMasIva = mImporteEmpleado + mTotalComisionDispercionIvaEmp;
			END IF
			
			--- Aqui se le resta 1 centavo, porque cuando el saldo inicial de la cuenta eje
			--- es igual a la suma del  monto a dispersar + su comision + su iva
			--- cuando ya esta en el ultimo empleado el proceso le suma 1 centavo
			--- a mTotalCargo + mImporteEmpleadoComisionMasIva, por lo tango
			--- el mSaldoActual es menor que mTotalCargo + mImporteEmpleadoComisionMasIva,
			--- cuando la realidad es que deben de ser iguales.

			IF siVuelta = iNumeroRegistros THEN
				LET mTotalCargo = mTotalCargo - 0.01;
			END IF

			-- // Si el saldo sobrante que me queda es Mayor o Igual al importe a pagar, le pago al empleado
			IF mSaldoActual >= (mTotalCargo + mImporteEmpleadoComisionMasIva) THEN
				LET bSiguienteEmpleado = "T" ;
				LET siSaldoDisponible = 1;
			ELSE
				LET bSiguienteEmpleado = "F" ;
				LET siSaldoDisponible = 0;
			END IF

			IF (bPrimerEmpleado = "T") OR  (bSiguienteEmpleado = "T") THEN
				IF siValorStatus > 1 THEN
				   IF vspei = '0' THEN
					  CALL sp_dispersionnominavalidacionestatus_bpi
					       (cNumeroCuentaEmpleado, '', '', 0, '', '' ,cNombreArchivo, cNumeroEmpleado, mImporteEmpleado, mImporteNoAbonado, siTipoEmpresa)
					       RETURNING vcodret, cEstatusCta, cAbono, mImporteNoAbonado, cRecDatonoUtilizableNOperacion, cSucursalAbono;
				   END IF
				ELSE
					LET cEstatusCta=1;
				END IF

				LET cSucursalAbono = "9103";
				
				-- // Estatus 1 = Cuenta Activa, Estatus 3 = Cuenta Bloqueada,
				-- // Se modifica IF, se le agrego, que pudiera se abonar a la cuenta bloqueada, si el motivo del bloqueo lo permite
				IF vspei = '0' THEN

					
					IF  ((siSaldoDisponible = 1) AND (cEstatusCta = '1' )) OR ((siSaldoDisponible = 1) AND (cAbono = 'S')) THEN
						SELECT MAX(secuencia)
						INTO vexiste_sec
						FROM bdicheq:sc_tarjeta
						WHERE empresa = '001'
						AND cuenta = cNumeroCuentaEmpleado
						AND tipo_tarjeta = "T"
						AND status_tar = "A";

						IF vexiste_sec IS NOT NULL OR vexiste_sec <> '' OR vexiste_sec > 0 THEN
							SELECT NVL(num_tarjeta, '')
							INTO cNumeroTarjeta
							FROM bdicheq:sc_tarjeta
							WHERE empresa = '001'
							AND cuenta = cNumeroCuentaEmpleado
							AND tipo_tarjeta = "T"
							AND status_tar = "A"
							AND secuencia = vexiste_sec;
						ELSE
							LET cNumeroTarjeta = '';
						END IF

						CALL sp_generafolionomina ("informix")
						RETURNING cCodRet, cNumeroFolio;

						-- // Aqui siempre se mandara la empresa 001 indepENDientemente
						-- // del numero de empresa que se este ejecutando tanto para el abono_ref y el cargo_ref

						CALL abono_ref ("001", cSucursalAbono, "informix", cTransaccAbono, "0000", cNumeroFolio, cNumeroCuentaEmpleado,
										0, mImporteEmpleado, mImporteEmpleado, 0, 0, 0, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
						RETURNING vcodret;

						IF vcodret = '000' THEN
							UPDATE bdicheq:sc_nominamovimientos_bpi
							SET status = '1'  --- Aqui actualizo el status = 1  (Aplicado)
							WHERE nombre_archivo = cNombreArchivo
							AND num_empleado = cNumeroEmpleado;

							LET mImporteAbonado = mImporteAbonado + mImporteEmpleado;

							LET iNumeroRegistrosAplicados = iNumeroRegistrosAplicados +1;

							--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
							IF vExcentaComision > 0 THEN 
								LET mTotalComision = 0;
								LET mTotaliva = 0;
							ELSE
								LET mTotalComision = iNumeroRegistrosAplicados * mMontoTransComiDisp;
								LET mTotaliva = mTotalComision * mMontoTransIvaDisp;  --Nueva Forma de Calcular el Iva
							END IF
							
							LET mTotalPagado = mTotalPagado + mImporteEmpleado;
							LET mTotalCargo = mTotalPagado + mTotalComision + mTotaliva;
						ELSE
							UPDATE bdicheq:sc_nominamovimientos_bpi
							SET status = '9'  --- Aqui actualizo el status = 9  (Error en la transaccion del sp abono_ref)
							WHERE nombre_archivo = cNombreArchivo
							AND num_empleado = cNumeroEmpleado;
							LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
						END IF
					ELSE
						UPDATE bdicheq:sc_nominamovimientos_bpi
						SET status = '5' --- Saldo Insuficiente
						WHERE nombre_archivo = cNombreArchivo
						AND num_empleado = cNumeroEmpleado;
						LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
					END IF
				ELSE
					LET cNumeroFolio = "";
                    CALL sp_generafolionomina ("informix")
						RETURNING cCodRet, cNumeroFolio;
					LET vcvebanco_cta = SUBSTR(cNumeroCuentaEmpleado, 1, 3);
					LET vcvebanco_benef = "40"||TRIM(vcvebanco_cta);
					CALL bdispei:sp_regordenpagospei_pp ("001", "informix", cSucursalAbono, cNumeroFolio, vcvebanco_benef, dFechaActual, 1, 0, mImporteEmpleado, vnombre_empresa, cCuentaEjeClabe, vrfc_empresa, vnombre_beneficiario, cNumeroCuentaEmpleado, " ", 0.00, 0,
                                                 " ", " ", " ", " ", " ", " ", "NOMINA", "0274", 40, 40)
						 RETURNING vcodret, verror, vcverastreo;
                     IF vcodret = "000" THEN
						UPDATE bdicheq:sc_nominamovimientos_bpi
						   SET status = '1'  --- Aqui actualizo el status = 1  (Aplicado)
					  	 WHERE nombre_archivo = cNombreArchivo
						   AND num_empleado = cNumeroEmpleado;
						   
						LET mImporteAbonado = mImporteAbonado + mImporteEmpleado;
						LET iNumeroRegistrosAplicados = iNumeroRegistrosAplicados +1;
							
						--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
						IF vExcentaComision > 0 THEN 
							LET mTotalComision = 0;
							LET mTotaliva = 0;
						ELSE
							LET mTotalComision = iNumeroRegistrosAplicados * mMontoTransComiDisp;
							LET mTotaliva = mTotalComision * mMontoTransIvaDisp;  --Nueva Forma de Calcular el Iva
						END IF
						
						LET mTotalPagado = mTotalPagado + mImporteEmpleado;
						LET mTotalCargo = mTotalPagado + mTotalComision + mTotaliva;					 
						LET mtotalspei = mtotalspei + mImporteEmpleado;
						LET mtotalregspei = mtotalregspei + 1;
						
						-- CARGO POR CADA SPEI A REALIZAR CORRESPONDIENTE A CADA IMPORTE ABONADO
						CALL cargo_ref ("001", cSucursalCargo, "informix", '0274', "0331", cNumeroFolio,
							cCuentaEje, 0, mImporteEmpleado, "01", vcverastreo, cNumeroTarjeta, cUsuarioAutoriza)
							RETURNING vcodretCargo1, vtranret, vfechoy, vsdodisp, vmontoret;
						IF vcodretCargo1 = '000' AND vcomisionspei > 0 THEN
							-- CARGO POR COMISION POR CADA DISPERSION
							CALL cargo_ref ("001", cSucursalCargo, "informix", "3257", "0000", cNumeroFolio,
								cCuentaEje, 0, vcomisionspei, "01", vcverastreo, cNumeroTarjeta, cUsuarioAutoriza)
								RETURNING vcodretCargo2, vtranret, vfechoy, vsdodisp, vmontoret;
							IF vcodretCargo2 = '000' THEN
								-- CARGO POR IVA POR COMISION POR CADA DISPERSION
								CALL cargo_ref ("001", cSucursalCargo, "informix", '0260', "0000", cNumeroFolio,
								cCuentaEje, 0, vcomisionspei *  mMontoTransIvaDisp, "01", vcverastreo, cNumeroTarjeta, cUsuarioAutoriza)
								RETURNING vcodretCargo3,vtranret,vfechoy,vsdodisp,vmontoret;
							END IF
						END IF
 				     ELSE
					 	UPDATE bdicheq:sc_nominamovimientos_bpi
						   SET status = '9'  --- Aqui actualizo el status = 9  (Error al enviar el SPEI)
					     WHERE nombre_archivo = cNombreArchivo
						   AND num_empleado = cNumeroEmpleado;
						LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
					 END IF
                END IF
			END IF  -- // FIN de: IF (bPrimerEmpleado = "T") OR  (bSiguienteEmpleado = "T")

			--INC 03 500
			IF vcodret = '000' AND cUnoExitoso = '0' THEN
				LET cUnoExitoso = '1';
			END IF
			
			LET bPrimerEmpleado = "F" ;
		END FOREACH;
		
		--INC 03 500
		IF cUnoExitoso = '1' AND vcodret <> '000' THEN
			LET vcodret = '000';
		END IF

		-- // Inicio de validacion de tipo de empresa externas
		CALL sp_generafolionomina ("informix")
			RETURNING cCodRet, cNumeroFolio;
			
		--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
		IF vExcentaComision > 0 THEN 
			LET mTotalComspei = 0;
			LET mTotalivaspei = 0;	
			LET mMontoTransComiDisp = 0;
		ELSE
			--aqui
			LET mTotalComspei = mtotalregspei * vcomisionspei;
			LET mTotalivaspei = mTotalComspei * mMontoTransIvaDisp;	
			IF mDispCtaBcoppel IS NOT NULL THEN
				LET mMontoTransComiDisp = mDispCtaBcoppel;
			END IF
		END IF

			-- // Aqui se manda llamar el sp que obtiene los totales del IVA y de la comision de los empleados Aplicados
		CALL sp_nominatotalivacomision_bpi (cNombreArchivo, mMontoTransIvaDisp, mMontoTransComiDisp) 
			RETURNING cCodRet, cMensaje, mTotaliva, mTotalComision, mTotalPagado, mTotalNoPagado, mTotalCargo;


		IF mTotalNoPagado <> 0 THEN
			LET iCodigoEstatus = 3;
		ELSE
			LET iCodigoEstatus = 2;
		END IF

		IF cCodRet = '000' THEN
			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = iCodigoEstatus,
				   importe_aplicado = mTotalPagado,
				   importe_no_aplicado = mTotalNoPagado,
				   folio_dispersion = cNumeroFolio,
				   iva = mTotaliva + mTotalivaspei,
				   comision = mTotalComision + mTotalComspei,
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo
			   AND nombre_archivo = cNombreArchivo;
		ELSE
			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = iCodigoEstatus,
				   importe_no_aplicado = mTotalNoPagado,
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo
			   AND nombre_archivo = cNombreArchivo;
		END IF

		LET cNumeroTarjeta = '';
		LET vcodretCargo1 = '000';
		LET vcodretCargo2 = '000';
		LET vcodretCargo3 = '000';
		
		IF mTotalPagado > 0 or mTotalComision > 0 or mtotalspei > 0 THEN
			IF mTotalPagado - mtotalspei > 0 THEN
				CALL cargo_ref ("001", cSucursalCargo, "informix", cTransaccCargo, "0000", cNumeroFolio,
								cCuentaEje, 0, mTotalPagado - mtotalspei, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
					RETURNING vcodretCargo1, vtranret, vfechoy, vsdodisp, vmontoret;
			ELSE
				LET vcodretCargo1 = '000';
			END IF
			/*
			IF vcodretcargo1 = '000' THEN
				IF mtotalspei > 0 THEN
					CALL cargo_ref ("001", cSucursalCargo, "informix", '0274', "0000", cNumeroFolio,
									cCuentaEje, 0, mtotalspei, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
						RETURNING vcodretCargo1, vtranret, vfechoy, vsdodisp, vmontoret;
				ELSE
					LET vcodretCargo1 = '000';
				END IF
			END IF
			*/
			IF vcodretCargo1 = '000' AND mTotalComision > 0 THEN
				CALL cargo_ref ("001", cSucursalCargo, "informix", cTransaccComiDisp, "0000", cNumeroFolio,
								cCuentaEje, 0, mTotalComision, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
				RETURNING vcodretCargo2, vtranret, vfechoy, vsdodisp, vmontoret;

				IF vcodretCargo2 = '000' THEN
					CALL cargo_ref ("001", cSucursalCargo, "informix", '0260', "0000", cNumeroFolio,
									cCuentaEje, 0, mTotaliva, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
					RETURNING vcodretCargo3,vtranret,vfechoy,vsdodisp,vmontoret;
				END IF
			ElIF (vcodretCargo1 = '000') AND (mTotalComision = 0) THEN
			 	 LET vcodretCargo2 = '000';
				 LET vcodretCargo3 = '000';
			END IF
			
            IF vcodretCargo1 = '000' AND mTotalComspei > 0 THEN
				/*
			     CALL cargo_ref ("001", cSucursalCargo, "informix", "3257", "0000", cNumeroFolio,
								cCuentaEje, 0, mTotalComspei, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
				 RETURNING vcodretCargo2, vtranret, vfechoy, vsdodisp, vmontoret;
				 IF vcodretCargo2 = '000' THEN
				    CALL cargo_ref ("001", cSucursalCargo, "informix", '0260', "0000", cNumeroFolio,
									cCuentaEje, 0, mTotalivaspei, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
					RETURNING vcodretCargo3,vtranret,vfechoy,vsdodisp,vmontoret;
				 END IF	  
				 */
			ElIF (vcodretCargo1 = '000') AND (mTotalComision = 0) THEN
				 LET vcodretCargo2 = '000';
				 LET vcodretCargo3 = '000';
			END IF
		END IF

		IF (vcodretCargo1 = '000') AND (vcodretCargo2 = '000') AND (vcodretCargo3 = '000') THEN
			COMMIT WORK;
		ELSE
			ROLLBACK WORK;

			-- // El archivo no efectuo el cargo y deja movimientos en cero pero actualiza el status de encabezado sumario a 9
			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = '9', --Error del cargo_ref
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = iFolioArchivo;
		END IF

		LET v_cCodret ='00000';
		
		CALL sp_dispersiontraspasomovtos_bpi(cNombreArchivo)
		  RETURNING v_cCodRet;
		
	    IF v_cCodRet <> "00000" AND v_cCodRet <> "00001" THEN
	       LET vcodret = '100'; --los registros ya fueron enviados a la tabla historica
	    END IF;
		
		LET vBegin = 'N';
	CONTINUE FOREACH;
	END FOREACH;

	--LET v_cCodret ='00000';

	--Se Corre este procedimiento para enviar los registros procesados a las tablas historicas.
	--EXECUTE PROCEDURE sp_dispersiontraspasomovtos_bpi()
	--INTO v_cCodRet;

	--IF v_cCodRet <> "00000" AND v_cCodRet <> "00001" THEN
	--   LET vcodret = '100'; --los registros ya fueron enviados a la tabla historica
	--END IF;

	RETURN vcodret;
    
    END;
    
END PROCEDURE;