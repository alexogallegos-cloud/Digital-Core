create procedure "informix".reversiontd_cel( pnum_tarjeta    char(16),
                                             psucursal       char(4),
                                             pusuario        char(8),
                                             pfolsucori      char(16),
                                             pdoctoori       integer,
                                             pcuenta         char(20),
                                             ptranrevcomp    char(4),
                                             pmtocompori     money(14,2),
                                             pmtoefeori      money(14,2),
                                             ptranefeori     char(4),
                                             pfolioefeori    char(16),
                                             pmontonvo       money(14,2),
                                             pfolsucnvo      char(16),
                                             pdoctonvo       integer,
                                             ptransucnva     char(4),
                                             pdivisanva      char(2),
                                             psucursalcom    char(4),
                                             pusuariocom     char(8),
                                             pfolsuccomori   char(16),
                                             pdoctocomori    integer,
                                             pcuentacom      char(20),
                                             ptranrevcom     char(4),
                                             pmontocomori    money(14,2),
                                             pmontocomnvo    money(14,2),
                                             pfolsuccomnvo   char(16),
                                             pdoctocomnvo    integer,
                                             ptransuccomnva  char(4),
                                             pdivisacomnva   char(2),
                                             pbanderacomnva  char(1),
                                             pSurcharge      char(1),
                                             pfolcomefeori   char(16),
                                             pdoctocomefeori integer,
                                             ptrancomefeori  char(4),
                                             pmtocomefeori   money(14,2),
                                             pmtocomefenvo   money(14,2),
                                             pfolcomefenvo   char(16),
                                             pdoctocomefenvo integer,
                                             ptranrevcomefe  char(4),
                                             pdivcomefenva   char(2) )
returning char(5),date,char(5),date;

    define sql_err,
           isam_err         int;
    define vcodret,
           vcodretcom,
           vcodret1         char(5)  ;
    define vempresa         char(3);
    define vfechoy          date;
    define vtranret,
           vtranret1        char(4);
    define vsaldo           money(14,2);
    define vsuccta          char(4);
    define vtraniva         char(4);
    define vivacom          money(14,2);
    define vtasaiva         decimal(9,6);
    define vtrancompra, 
           vtrancomcomp, 
           vtrancomefe      char(4);
    define vmonto_ori       money(14,2);
    DEFINE vRefRev          CHAR(40);
    DEFINE vDato            CHAR(10);
    
    DEFINE vtransaccion 	    integer;
    DEFINE vidtransacc          CHAR(5);
    DEFINE vcodret_reg          CHAR(5);
    DEFINE vserial              INTEGER;
    DEFINE vvueltas             INTEGER;
    DEFINE vSQL                 CHAR(10);
    DEFINE cStatus              CHAR(1);
    DEFINE vtrama_res           CHAR(600);
    DEFINE vtrxposcodaut           CHAR(6);
    DEFINE vprodtrnf            char(4);
    DEFINE vhora                char(15);
    DEFINE vtransaccpos       char(5);
    DEFINE vtrama               char(600);
    DEFINE vtrxpostime        char(6);
    DEFINE vtrxposdate        char(4);
    DEFINE vtrxposrefer        char(12);
	DEFINE vfecha_operacion DATE;
    
    let vcodret = "000";
    let vcodretcom = "000";
    let psucursal = "9"||trim(psucursal);
    let psucursalcom = "9"||trim(psucursalcom);
    let vtrancompra = "";
    let vtrancomcomp = "";
    let vtrancomefe = "";
    let vRefRev = " ";
	let vfecha_operacion = TODAY;
    
    LET vtransaccion = 0;
    
    set isolation to dirty read;
    set lock mode to wait 2;
    
    begin
    
    on exception set sql_err
        if sql_err <> 0  then
            let vcodret = sql_err;
            IF SUBSTR(pcuenta, 1, 2) <> '80' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret,vfechoy,vcodretcom,vfechoy;
        end if;
    end exception;
    
    ON EXCEPTION IN (-535)
        let vtransaccion = 1;
    END EXCEPTION WITH RESUME;
    
     --SET DEBUG FILE TO "/informix/moha/reversiontd_cel.out";
     --TRACE ON;
    
    select fecha_hoy 
      into vfechoy 
      from sc_fechas;
      
    -- // Valida que no existan montos negativos
    IF ( pmtocompori < 0 OR pmtocompori < 0 ) THEN
        let vcodret = "110";
        RETURN vcodret,vfechoy,vcodretcom,vfechoy;
    END IF;

    if 	( ( pmtocompori + pmtoefeori) <> pmontonvo) and 
        ( pmontonvo > 0 ) and 
        ( pdoctonvo is null or pdoctonvo = " " or ptransucnva is null or ptransucnva = " " or pdivisanva is null or pdivisanva = " " ) then
        let vcodret = "110";
        RETURN vcodret,vfechoy,vcodretcom,vfechoy;
    end if;
      
    select empresa 
      into vempresa
      from bdinteg:si_ejecut
     where ejecutivo = pusuario;
     
    if vempresa is null then
        let vcodret = "106";
        RETURN vcodret,vfechoy,vcodretcom,vfechoy;
    end if
    
    LET pcuenta = pcuenta;
    LET pfolsucori = pfolsucori;
        
    IF SUBSTR(pcuenta, 1, 2) = '80' THEN
        
        LET vcodret = '999';
                
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
        END IF;
        
        RETURN vcodret,vfechoy,vcodretcom,vfechoy;
    
        /* ##########################################################################################################################################
        
        if pmtocompori > 0 then
        
            IF vtransaccion = 1 THEN
                COMMIT WORK;
                BEGIN WORK;
            ELSE
                BEGIN WORK;
            END IF;
            
            IF ptranrevcomp = '0808' THEN
            
                SELECT valor
                  INTO vidtransacc
                  FROM sc_param
                 WHERE empresa = vempresa
                   AND codparam = 'TranReverPosTransfer';
                   
                SELECT valor
                  INTO vtransaccpos
                  FROM sc_param
                 WHERE empresa = vempresa
                   AND codparam = 'TranCgoPosTransfer';
                   
                SELECT trama ,trama_res
                  INTO vtrama, vtrama_res
                  FROM sc_transfer_online
                 WHERE no_serial > 0
                   AND cuenta = cuenta
                   AND folio_suc = pfolsucori
                   AND id_transacc = '20058';
                   
                LET vtrxposcodaut = SUBSTR(vtrama_res, 479, 6);
                LET vtrxpostime = SUBSTR(vtrama, 339, 6);
                LET vtrxposdate = SUBSTR(vtrama, 345, 4);
                LET vtrxposrefer = SUBSTR(vtrama, 386, 12);
                   
                CALL sp_transfer_online_reversopos( vidtransacc, pnum_tarjeta, pfolsucori, pusuario, pmtocompori, vfechoy, 
                                                    vtrxposcodaut, vtransaccpos, vtrxpostime, vtrxposdate, vtrxposrefer )
                RETURNING vcodret_reg, vserial;
                
            ELSE
            
                SELECT valor
                  INTO vidtransacc
                  FROM sc_param
                 WHERE empresa = vempresa
                   AND codparam = 'TranReverTransfer';
                   
                CALL sp_transfer_online_reverso( vidtransacc, pnum_tarjeta, pfolsucori, pusuario )
                RETURNING vcodret_reg, vserial;
            
            END IF;
            
            IF ( vcodret_reg is null OR vcodret_reg <> '000' ) OR ( vserial is null OR vserial = 0 ) THEN
                LET vcodret = '999';
                
                IF vtransaccion = 1 THEN
                    COMMIT WORK;
                    BEGIN WORK;
                ELSE
                    COMMIT WORK;
                END IF;
                
                RETURN vcodret,vfechoy,vcodretcom,vfechoy;
            END IF;
            
            COMMIT WORK;
            
            LET vvueltas = 0;
            LET cStatus = 'N';
            
            WHILE cStatus IN('N','E') 
                SET ISOLATION TO DIRTY READ;
                
                SELECT status
                  INTO cStatus
                  FROM sc_transfer_online
                 WHERE no_serial = vserial
                   AND cuenta = pnum_tarjeta
                   AND folio_suc = pfolsucori
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
                   AND folio_suc = pfolsucori
                   AND id_transacc = vidtransacc;
                   
                LET vcodret = '96';
                
                IF vtransaccion = 1 THEN
                    BEGIN WORK;
                END IF;
                
                RETURN vcodret,vfechoy,vcodretcom,vfechoy;
                
            ELIF cStatus = 'X' THEN
            
                SELECT cod_ret
                  INTO vcodret
                  FROM sc_transfer_online
                 WHERE no_serial = vserial
                   AND cuenta = pnum_tarjeta
                   AND folio_suc = pfolsucori
                   AND id_transacc = vidtransacc;
            
                IF vtransaccion = 1 THEN
                    BEGIN WORK;
                END IF;
                
                RETURN vcodret,vfechoy,vcodretcom,vfechoy;
            END IF;
            
            BEGIN WORK;
            
            UPDATE {+INDEX("informix".sc_movdia idx_movdia2a)} "informix".sc_movdia
               SET cancelad = "S"
             WHERE folio_suc = pfolsucori
               AND empresa = vempresa;
               
            COMMIT WORK;
           
            -- // SE CARGA EL MONTO NUEVO
            if ( ( pmtocompori + pmtoefeori ) <> pmontonvo ) then 
                
                SELECT valor
                  INTO vidtransacc
                  FROM sc_param
                 WHERE empresa = vempresa
                   AND codparam = 'TranRetATMTransfer';  
                   
                CALL sp_transfer_online_retatm( vidtransacc, pnum_tarjeta, pfolsuccomnvo, pmontonvo, pusuario )
                RETURNING vcodret_reg, vserial;
                
                IF ( vcodret_reg is null OR vcodret_reg <> '000' ) OR ( vserial is null OR vserial = 0 ) THEN
                    IF vtransaccion = 1 THEN
                        BEGIN WORK;
                    END IF;
                    LET vcodret = "999";
                    RETURN vcodret,vfechoy,vcodretcom,vfechoy;
                END IF;
                
                LET vvueltas = 0;
                LET cStatus = 'N';
                
                WHILE cStatus IN('N','E') 
                    SET ISOLATION TO DIRTY READ;
                    
                    SELECT status, trama_res
                      INTO cStatus, vtrama_res
                      FROM sc_transfer_online
                     WHERE no_serial = vserial
                       AND cuenta = pnum_tarjeta
                       AND folio_suc = pfolsuccomnvo
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
                       AND folio_suc = pfolsuccomnvo
                       AND id_transacc = vidtransacc;
                       
                    SELECT valor
                      INTO vidtransacc
                      FROM sc_param
                     WHERE empresa = vempresa
                       AND codparam = 'TranReverTransfer';
                       
                    CALL sp_transfer_online_reverso( vidtransacc, pnum_tarjeta, pfolsuccomnvo, pusuario )
                    RETURNING vcodret_reg, vserial;
                    
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
                               AND folio_suc = pfolsuccomnvo
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
                               AND folio_suc = pfolsuccomnvo
                               AND id_transacc = vidtransacc;
                        END IF;
                    END IF;
                    -- // FINAL REVERSO AUTOMATICO A TRANSFER POR TIMEOUT // --   
                       
                    LET vcodret = "96"; 
                    
                    IF vtransaccion = 1 THEN
                        BEGIN WORK;
                    END IF;
                       
                    RETURN vcodret,vfechoy,vcodretcom,vfechoy;
                    
                ELIF cStatus = 'X' THEN
                
                    SELECT cod_ret
                      INTO vcodret
                      FROM sc_transfer_online
                     WHERE no_serial = vserial
                       AND cuenta = pnum_tarjeta
                       AND folio_suc = pfolsuccomnvo
                       AND id_transacc = vidtransacc;
                    
                    IF vtransaccion = 1 THEN
                        BEGIN WORK;
                    END IF;
                    
                    RETURN vcodret,vfechoy,vcodretcom,vfechoy;
                END IF;
                
                BEGIN WORK;
                
                select tran_relac 
                  into vtrancompra
                  from bdinteg:si_transacc
                 where empresa = vempresa 
                   and numero = ptranrevcomp;
                   
                SELECT valor
                  INTO vprodtrnf
                  FROM sc_param
                 WHERE empresa = vempresa
                   AND codparam = 'ProductoTransfer';
                
                LET vhora = CURRENT HOUR TO FRACTION;
                
                IF vtrancompra IN ('0801','0881') THEN 
                    LET vtrxposcodaut = SUBSTR(vtrama_res, 479, 6);
                ELSE
                    LET vtrxposcodaut = '';
                END IF;
                
                -- // Inserta el movimiento en la tabla de movimientos diarios...
                INSERT INTO sc_movdia VALUES
                ( 0, pfolsuccomnvo, psucursal, pusuario, vfechoy, vfechoy, vhora, vtrancompra, psucursal, vprodtrnf, vempresa, pcuenta, 
                  "", 0, pmontonvo, 0, 0, 0, 0, "", "", 0.00, vtrancompra, '', 0, pnum_tarjeta, '', vtrxposcodaut, vfecha_operacion);
                  
                COMMIT WORK;

            end if;        
        
        end if;
        
        IF vtransaccion = 1 THEN
            BEGIN WORK;
        END IF;
        ########################################################################################################################################## */
        
    ELSE
        
        BEGIN WORK;
        
        FOREACH 
            SELECT monto_tot, NVL(referencia, ' ')
              INTO vmonto_ori, vRefRev
              FROM sc_movdia
             WHERE empresa = vempresa
               AND cuenta = pcuenta
               AND folio_suc = pfolsucori
               AND cancelad <> "S"
            
            IF vmonto_ori IS NULL OR vmonto_ori = 0 THEN
                LET vcodret = "091";
                ROLLBACK WORK;
                RETURN vcodret,vfechoy,vcodretcom,vfechoy;
            END IF
        END FOREACH

        if pmtocompori = pmontonvo then  ----   Para tomar datos de compra original  RRM
            select first 1 monto_tot   
              into vmonto_ori
              from sc_movdia
             where empresa = vempresa 
               and cuenta = pcuenta 
               and folio_suc = pfolsucori
               and cancelad <> "S";
               
            IF ptranefeori = "0812" THEN
                if vmonto_ori <> pmtoefeori then
                    let vcodret = "410";
                    ROLLBACK WORK;
                    RETURN vcodret,vfechoy,vcodretcom,vfechoy;
                end if
            ELSE
                if vmonto_ori <> pmontonvo then
                    let vcodret = "410";
                    ROLLBACK WORK;
                    RETURN vcodret,vfechoy,vcodretcom,vfechoy;
                end if
            END IF
        end if
        
        select sdo_actual,sucursal
          into vsaldo,vsuccta
          from sc_maechq
         where empresa = vempresa 
           and cuenta = pcuenta;
        
        if pmtocompori > 0 then
            call reversiontd(vempresa,psucursal,pusuario,pfolsucori,"A",pcuenta,ptranrevcomp)
            returning vcodret;
            
            IF TRIM(vcodret) <> "000" THEN
                ROLLBACK WORK;
                RETURN vcodret,vfechoy,vcodretcom,vfechoy;
            END IF
            
            if pmtocompori + pmtoefeori <> pmontonvo then 
                select tran_relac 
                  into vtrancompra
                  from bdinteg:si_transacc
                 where empresa = vempresa 
                   and numero = ptranrevcomp;
                   
                CALL cargo_ref_td(vempresa,psucursal,pusuario,vtrancompra,ptransucnva,pfolsucnvo,pcuenta,pdoctonvo,pmontonvo,pdivisanva,vRefRev,pnum_tarjeta,"")
                RETURNING vcodret,vtranret, vDato, vDato, vDato;
                
                if vcodret <> "000" then
                    ROLLBACK WORK;
                    RETURN vcodret,vfechoy,vcodretcom,vfechoy;
                ELSE -- Agregado por Axl para identificar a la tran. forzada
                    UPDATE sc_docret
                       SET referencia ="Forzada " || pfolsucnvo || TRIM(referencia)
                     WHERE empresa = vempresa
                       AND cuenta = pcuenta
                       AND folio_suc = pfolsucori
                       AND cancelado = "S";
                end if
            end if
        end if
        
        if pmtoefeori > 0 then
            if ptranefeori is null or ptranefeori = '' then --RRM
               let ptranefeori = ptranrevcomp;
               let pfolioefeori = pfolsucori;
            end if
            call reversiontd(vempresa,psucursal,pusuario,pfolioefeori,"A",pcuenta,ptranefeori)
            returning vcodret;
            
            IF TRIM(vcodret) <> "000" THEN
                ROLLBACK WORK;
                RETURN vcodret,vfechoy,vcodretcom,vfechoy;
            END IF
        end if
        
        if pmontocomori > 0 then
            call reversiontd(vempresa,psucursal,pusuario,pfolsuccomori,"A",pcuenta,ptranrevcom)
            returning vcodret1;
            
            IF TRIM(vcodret1) <> "000" THEN
                ROLLBACK WORK;
                RETURN vcodret,vfechoy,vcodretcom,vfechoy;
            END IF

            if pmontocomori <> pmontocomnvo then
                select tran_relac 
                  into vtrancomcomp
                  from bdinteg:si_transacc
                 where empresa = vempresa 
                   and numero = ptranrevcom;
                   
                call cargon_ref(vempresa,psucursal,pusuario,vtrancomcomp,ptransuccomnva,pfolsuccomnvo,pcuenta,pdoctocomnvo,pmontocomnvo,pdivisacomnva,"",pnum_tarjeta,"")
                returning vcodret,vtranret;
                
                if vcodret <> "000" then
                    ROLLBACK WORK;
                    RETURN vcodret,vfechoy,vcodretcom,vfechoy;
                else
                    select tran_relac 
                      into vtraniva
                      from bdinteg:si_transacc
                     where empresa = vempresa 
                       and numero = vtrancomcomp;
                       
                    let vivacom = pmontocomnvo * vtasaiva;
                    
                    if vivacom > 0 then
                        call cargon_ref(vempresa,psucursal,pusuario,vtraniva,"0000",pfolsuccomnvo,pcuenta,pdoctocomnvo,vivacom,pdivisacomnva,"",pnum_tarjeta,"")
                        returning vcodret,vtranret1;
                        
                        if vcodret <> "000" then
                            ROLLBACK WORK;
                            RETURN vcodret,vfechoy,vcodretcom,vfechoy;
                        end if
                    end if
                end if
            end if
        end if
        
        if pmtocomefeori > 0 then
            call reversiontd(vempresa,psucursal,pusuario,pfolcomefeori,"A",pcuenta,ptranrevcomefe)
            returning vcodret;
            
            IF TRIM(vcodret) <> "000" THEN
                ROLLBACK WORK;
                RETURN vcodret,vfechoy,vcodretcom,vfechoy;
            END IF

            if pmtocomefeori <> pmtocomefenvo then
                select tran_relac 
                  into vtrancomefe
                  from bdinteg:si_transacc
                 where empresa = vempresa 
                   and numero = ptranrevcomefe;
                   
                call cargon_ref(vempresa,psucursal,pusuario,vtrancomefe,"0000",pfolcomefenvo,pcuenta,pdoctocomefenvo,pmtocomefenvo,pdivcomefenva,"",pnum_tarjeta,"")
                returning vcodret,vtranret;
                
                if vcodret <> "000" then
                    ROLLBACK WORK;
                    RETURN vcodret,vfechoy,vcodretcom,vfechoy;
                else
                    select tran_relac 
                      into vtraniva
                      from bdinteg:si_transacc
                     where empresa = vempresa 
                       and numero = vtrancomefe;
                       
                    let vivacom = pmtocomefenvo * vtasaiva;
                    
                    if vivacom > 0 then
                        call cargon_ref(vempresa,psucursal,pusuario,vtraniva,"0000",pfolcomefenvo,pcuenta,pdoctocomefenvo,vivacom,pdivcomefenva,"",pnum_tarjeta,"")
                        returning vcodret,vtranret1;
                        
                        if vcodret <> "000" then
                            ROLLBACK WORK;
                            RETURN vcodret,vfechoy,vcodretcom,vfechoy;
                        end if
                    end if
                end if
            end if
        end if
        
        -- // Reversa la Consulta de Saldo por Comisiones
        IF pmtoefeori = 0 AND pmontocomori > 0 THEN
            call reversiontd(vempresa,psucursal,pusuario,pfolsuccomnvo,"A",pcuenta,vtrancomefe)
            returning vcodret1;
            
            IF TRIM(vcodret1) <> "000" THEN
                ROLLBACK WORK;
                RETURN vcodret,vfechoy,vcodretcom,vfechoy;
            END IF
        END IF
        
        COMMIT WORK;
        
    END IF;    
    
    RETURN vcodret,vfechoy,vcodretcom,vfechoy;
    
    end;
    
end procedure;