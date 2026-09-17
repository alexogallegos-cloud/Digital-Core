CREATE PROCEDURE "informix".cargo_ref( pempresa    char(3),
                                       psucursal   char(4),
                                       pusuario    char(8),
                                       ptransacc   char(4),
                                       ptransuc    char(4),
                                       pfolsuc     char(16),
                                       pcuenta     char(20),
                                       pcheque     integer,
                                       pmonto      money(14,2),
                                       pdivisa     char(2),
                                       preferencia char(40),
                                       pnum_tarjeta char(16),
                                       pusuautoriza char(8) )
RETURNING CHAR(5), CHAR(4), DATE, MONEY(14,2), MONEY(14,2);
    
    -- // Variables Globales Conciliacion intercar
    DEFINE GLOBAL vg_estatus    VARCHAR(5)  DEFAULT " ";
    DEFINE GLOBAL vgrfc_comer   VARCHAR(20) DEFAULT " ";
    DEFINE GLOBAL vgreferencia  VARCHAR(40) DEFAULT " ";
    
    define vsqlerr              integer;
    define visamerr             integer;
    define vdescerr             char(50);
    define vcodret              char(5);
    define vcodret2             char(5);
    define vcodret3             char(50);
    define vtiptran             char(2);
    define vcodret1             char(5);
    define vtranret             char(4);
    define vtiporef             char(1);
    define vclave               char(4);
    define vcomision            money(14,2);
    define vfechoy              date;
    define vfechacalendario     date;
    define vsdodisp             money(14,2);
    define vcompend             money(14,2);
    define vmontoret            money(14,2);
    define vnip                 char(4);
    define vlimite_aut          money(14,2);
    define vdisp_mes            money(14,2);
    define vadicional           integer;
    define vtransaccion         integer;
    define vstatus_cta          char(1);
    define vmsje_limites        char(80);
    define vid_autor            char(1);
    define vnum_cte             char(20);
    define vuser_limit          char(8);
    define vtran_limit          char(8);
    define vid_transacc         char(2);
    define vid_canal            char(2);
    define vproducto            char(4);
    define vind_dispon          char(1);
    define vhora                DATETIME HOUR TO FRACTION(3);
    define vidtransacc          char(5);
    define vcodret_reg          char(5);
    define vserial              integer;
    define vprodtrnf            char(4);
    define vvueltas             integer;
    define vSQL                 char(10);
    define cStatus              char(1);
    define vcodretrev           char(5);
	define vfecha_operacion     date;
    define vstatus              smallint;
    define vcodretver           char(5);
    define vfecharet            date;
    define vsdo_cuenta          decimal(14,2);
    define vsdo_disponible      decimal(14,2);
    define vsdo_actual          decimal(14,2);
    define vsdo_retenido        decimal(14,2);
    define vsdo_cong            decimal(14,2);
    define vimp_chq_sbg         decimal(14,2);
    define vpri_dia_mes         date;
    define msdo_actual          money(14,2);
    define msdo_retenido        money(14,2);
    define msdo_cong            money(14,2);
    define mimp_chq_sbg         money(14,2);
	DEFINE vcuenta              CHAR(20);
	DEFINE ccodretma            CHAR(5);
    define vflag_siweb          smallint;
    --RQM 09 704. Se agrega la variable para la consulta del campo saldo_sbc en la maestra de cheques. EEAP.
    define mSaldoSbc            money(14,2);
    
    let vsqlerr      = 0;
    let visamerr     = 0;
    let vdescerr     = '';
    let vtransaccion = 0;
    let vclave       = " ";
    let vind_dispon  = '0';
    let vcodret      = "000";
    let vcodret2     = "";
    let vcodret3     = "";
    let vtranret     = " ";
    let vtiporef     = "4";
    let vmontoret    = 0;
    let vsdodisp     = 0;
    let vnip         = " ";
    let vfechoy      = " ";
    
    let vidtransacc      = '';
    let vcodret_reg      = '';
    let vserial          = 0;
    let vprodtrnf        = '8000';
    let vvueltas         = 0; 
    let vSQL             = '';
    let cStatus          = '';
    let vcodretrev       = '';
	let vfecha_operacion = TODAY;
    let vstatus          = 0;
    let vcodretver       = '';
    let vfecharet        = '';
    let vsdo_cuenta      = 0.00;
    let vsdo_disponible  = 0.00;
    let vsdo_actual      = 0.00;
    let vsdo_retenido    = 0.00;
    let vsdo_cong        = 0.00;
    let vimp_chq_sbg     = 0.00;
    let vpri_dia_mes     = '';
    let msdo_actual      = 0.00;
    let msdo_retenido    = 0.00;
    let msdo_cong        = 0.00;
    let mimp_chq_sbg     = 0.00;
	LET vcuenta          = '';
	LET ccodretma        = '';
    let vflag_siweb      = 0;
    --RQM 09 704. Se inicializa la variable para la consulta del campo saldo_sbc en la maestra de cheques. EEAP.
    LET mSaldoSbc    = 0.00;
    
    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        --set debug file to "/tmp/cargo_ref.err";
        --trace on;
        if vsqlerr <> 0  then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            IF SUBSTR(pcuenta, 1, 2) <> '80' THEN
                if vtransaccion = 1 then
                    ROLLBACK WORK;
                    BEGIN WORK;
                else
                    ROLLBACK WORK;
                end if;
            END IF;
            return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
        end if;
    end exception;
    
    on exception in (-535)
        let vtransaccion = 1;
    end exception with resume;
    
    --- set debug file to "/tmp/cargo_ref.out";
    --- trace on;
    
    set isolation to dirty read;
    set lock mode to wait 5;
	
	
	--SIWEB
	IF ((TRIM(pcuenta) == '') AND (TRIM(pnum_tarjeta) == '')) THEN
		LET vcodret = '100';
		RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
	END IF;
	--SIWEB
	
	--AFORE
	IF ptransacc = '0223' and ptransuc= '0223' AND pcuenta <> '' AND psucursal <> '' AND pusuario <> '' THEN
    EXECUTE PROCEDURE bdinteg:"informix".sp_inserta_msjafore('',pcuenta,psucursal, pusuario)
    INTO ccodretma;
    END IF;
    --AFORE

	
    -- // PARA CUENTAS TRANSFER
    IF SUBSTR(pcuenta, 1, 2) = '80' THEN
        
        LET vcodret = "999";
        RETURN vcodret, '', vfechoy, 0, 0;
            
        /* ##########################################################################################################################################
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            BEGIN WORK;
        END IF;
    
        -- // Valida fecha de proceso de la cuenta
        select fecha_hoy, ind_disponible
          into vfechoy, vind_dispon
          from sc_fechas 
         where empresa = pempresa;
        
        IF vind_dispon = '0' THEN
            LET vcodret = "004";
            RETURN vcodret, '', vfechoy, 0, 0;
        END IF;
        
        SELECT valor
          INTO vprodtrnf
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = 'ProductoTransfer';
           
        SELECT status_cta
          INTO vstatus_cta
          FROM bditransfer:tf_maecte
         WHERE cuenta_tf = pcuenta;
        
        IF ( pcuenta = '80009999999' AND ptransacc = '0223' AND ptransuc = '9002' ) THEN
        
            LET vhora = CURRENT HOUR TO FRACTION;
            
            -- // Inserta el movimiento en la tabla de movimientos diarios...
            INSERT INTO sc_movdia VALUES
            ( 0, pfolsuc, psucursal, pusuario, vfechoy, vfechoy, vhora, ptransacc, psucursal, vprodtrnf, 
              pempresa, pcuenta, "", 0, pmonto, 0, 0, 0, 0, "", vstatus_cta, 0.00, ptransuc, preferencia, 0, '', '', '', vfecha_operacion);
            
        ELSE
            
            SELECT valor
              INTO vidtransacc
              FROM sc_param
             WHERE empresa = pempresa
               AND codparam = 'TranCargoTransfer';    
            
            --- CALL sp_transfer_online_cargo( vidtransacc, pcuenta, pfolsuc, pmonto, pusuario )
            --- RETURNING vcodret_reg, vserial;
            
            IF ptransacc = '0274' THEN
                CALL sp_transfer_online_cargospei( vidtransacc, pcuenta, pfolsuc, pmonto, pusuario )
                RETURNING vcodret_reg, vserial;
            ELSE
                CALL sp_transfer_online_cargo( vidtransacc, pcuenta, pfolsuc, pmonto, pusuario )
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
                
                RETURN vcodret, '', vfechoy, 0, 0;
            END IF;
            
            COMMIT WORK;
            
            LET vvueltas = 0;
            LET cStatus = 'N';
            
            WHILE cStatus IN('N','E') 
                SELECT status
                  INTO cStatus
                  FROM sc_transfer_online
                 WHERE no_serial = vserial
                   AND cuenta = pcuenta
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
                   AND cuenta = pcuenta
                   AND folio_suc = pfolsuc
                   AND id_transacc = vidtransacc;
                   
                -- // INICIO REVERSO AUTOMATICO A TRANSFER POR TIMEOUT // --
                SELECT valor
                  INTO vidtransacc
                  FROM sc_param
                 WHERE empresa = pempresa
                   AND codparam = 'TranReverTransfer';
                   
                CALL sp_transfer_online_reverso( vidtransacc, pcuenta, pfolsuc, pusuario )
                RETURNING vcodret_reg, vserial;
                
                IF ( vcodret_reg = '000' AND vserial > 0 ) THEN
                    LET vvueltas = 0;
                    LET cStatus = 'N';
                    
                    WHILE cStatus IN('N','E') 
                        SELECT status
                          INTO cStatus
                          FROM sc_transfer_online
                         WHERE no_serial = vserial
                           AND cuenta = pcuenta
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
                           AND cuenta = pcuenta
                           AND folio_suc = pfolsuc
                           AND id_transacc = vidtransacc;
                    END IF;
                END IF;
                -- // FINAL REVERSO AUTOMATICO A TRANSFER POR TIMEOUT // --
                
                LET vcodret = '24';
                
                IF vtransaccion = 1 THEN
                    BEGIN WORK;
                END IF;
                
                RETURN vcodret, '', vfechoy, 0, 0;
                
            ELIF cStatus = 'X' THEN
            
                SELECT cod_ret
                  INTO vcodret
                  FROM sc_transfer_online
                 WHERE no_serial = vserial
                   AND cuenta = pcuenta
                   AND folio_suc = pfolsuc
                   AND id_transacc = vidtransacc;
                
                IF vtransaccion = 1 THEN
                    BEGIN WORK;
                END IF;
                
                RETURN vcodret, '', vfechoy, 0, 0;
            END IF;
            
            BEGIN WORK;
            
            LET vhora = CURRENT HOUR TO FRACTION;
            
            -- // Inserta el movimiento en la tabla de movimientos diarios...
            INSERT INTO sc_movdia VALUES
            ( 0, pfolsuc, psucursal, pusuario, vfechoy, vfechoy, vhora, ptransacc, psucursal, vprodtrnf, 
              pempresa, pcuenta, "", 0, pmonto, 0, 0, 0, 0, "", vstatus_cta, 0.00, ptransuc, preferencia, 0, '', '', '', vfecha_operacion);
        
        END IF;
          
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
        END IF;
        ########################################################################################################################################## */
    
    -- // PARA CUENTAS DEL BANCO
    ELSE
    
        if vtransaccion = 1 then
            COMMIT WORK;
            BEGIN WORK;
        else
            BEGIN WORK;
        end if;
    
        -- // Valida fecha de proceso de la cuenta
        select fecha_hoy, ind_disponible, pri_dia_mes
          into vfechacalendario, vind_dispon, vpri_dia_mes
          from sc_fechas 
         where empresa = pempresa;
        
        if vind_dispon = '0' then
            let vcodret = "004";
            return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
        end if;
		
		--  SIWEB EN CASO DE NO TRAER CUENTA
		IF (TRIM(pcuenta) == '') THEN
			SELECT cuenta
			INTO vcuenta
			FROM sc_tarjeta
			WHERE empresa = pempresa
			AND num_tarjeta = pnum_tarjeta
			AND status_tar = 'A';
			
			IF (TRIM(vcuenta) == '') THEN 
				LET vcodret = "100";
				RETURN vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
			END IF;
			
			LET pcuenta = TRIM(vcuenta);
		END IF;
		--SIWEB EN CASO DE NO TRAER CUENTA
		--RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
        select fecha_proceso, status_cta, num_cte, producto, sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbg, saldo_sbc
          into vfechoy, vstatus_cta, vnum_cte, vproducto, vsdo_actual, vsdo_retenido, vsdo_cong, vimp_chq_sbg, mSaldoSbc
          from sc_maechq
         where empresa = pempresa
           and cuenta = pcuenta;
		   
   -- // 05/06/2021
		   
		execute procedure sp_cargo_val(pcuenta)
		into vcodret;

		if vcodret <> '00000' then
			let vcodret = '307';
			return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
		end if;
		
    -- // 05/06/2021
           
        if vsdo_retenido < 0 then
            let vsdo_retenido = vsdo_retenido * -1;
        end if;
        
        if vsdo_cong < 0 then
            let vsdo_cong = vsdo_cong * -1;
        end if;
        
        if vimp_chq_sbg < 0 then
            let vimp_chq_sbg = vimp_chq_sbg * -1;
        end if;

        --RQM 09 704. Se agrega la validacion de la variable mSaldoSbc. EEAP.
        if mSaldoSbc < 0 then
            let mSaldoSbc = mSaldoSbc * -1;
        end if;
           
        if vproducto in('1100', '2300') and ptransacc = '0223' then
           let vcodret = "962";
           return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
        end if  
		
		if vproducto in('1100', '2300') and ptransacc = '0402' then
           let vcodret = "100";
           return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
        end if  

        if vproducto = '2300' and ptransacc = '0239' and ptransuc <> '0000' then
           let vcodret = "962";
           return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
        end if   
        
        if vproducto in('2800') and ptransacc in ('0223','0402') then
           let vcodret = "404";
           return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
        end if    
    
        if (vfechoy is null or vstatus_cta = '4' or vstatus_cta = '5') then
            let vfechoy = vfechacalendario;
        end if
        
        if vstatus_cta = '8' then
            if ptransacc = '0223' or ptransacc = '0320' or ptransacc = '0270' or ptransacc = '0252' or ptransacc = '0402' then
                let vfechoy = vfechacalendario;
            else
                let vcodret = "200";
                return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
            end if
        end if
    
        if (vfechoy < vfechacalendario) then
            let vcodret = "549";
            return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
        end if
        
        if ( vstatus_cta in('2','6','7') ) then
            let vcodret = "200";
            return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
        end if
        
        -- // Valida que exista la transaccion de cargo y determina el tipo de transacciÃÆÃÂ³n
        select tipo_tran
          into vtiptran
          from bdinteg:si_transacc
         where empresa = pempresa
           and numero = ptransacc
           and sistema = '01'
           and naturaleza = 'C';
        
        if vtiptran is null then
            let vcodret = "550";
            return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
        end if;
	
        -- // Valida la sucursal para transacciones de aclaraciones
        IF ptransacc IN('0342', '0343') THEN
            SELECT sucursal 
              INTO psucursal
              FROM bdinteg:si_sucursales
             WHERE sucursal = psucursal;
             
                IF psucursal is null or psucursal = "" THEN
                    SELECT sucursal
                      INTO psucursal		  
                      FROM bdinteg:si_ejecut 
                     WHERE ejecutivo in( SELECT num_empleado 
                                           FROM bdiaclaracion:acl_aclaracion 
                                          WHERE folio_csuac = preferencia );
                END IF;
        END IF;	   
	
        -- // Valida limite autorizado en tarjetas adicionales
        if pcuenta = "" then
            select cuenta
              into pcuenta
              from sc_tarjeta
             where empresa = pempresa
               and num_tarjeta = pnum_tarjeta;
        end if;
    
        if ptransacc <> '0830' and ptransacc <> '0887' then
            select limite_aut, disp_mes
              into vlimite_aut, vdisp_mes
              from sc_tarjeta
             where empresa = pempresa
               and num_tarjeta = pnum_tarjeta
               and cuenta = pcuenta
               and tipo_tarjeta = "A";
        
            let vadicional = dbinfo("sqlca.sqlerrd2");
        
            if vadicional <> 0 then
                IF vlimite_aut <> 0 THEN
                    let vdisp_mes = nvl(vdisp_mes,0)  + pmonto;
                    
                    if vdisp_mes > vlimite_aut then
                        let  vcodret = "777";
                        return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
                    end if
                END IF
            end if
        end if;
    
        -- // Se modifca  la referencia pra el Pago de Cheque Propio en Sucursal
        if ptransacc ='3333' then 
            let preferencia = 'Pago Cheq. No.'|| trim(pcheque::char(7)) || ' Suc. ' || trim(psucursal::char(4));
        end if;
        
        -- // ValidaciÃÆÃÂ³n de limites 
        select usuario
          into vuser_limit
          from bdinteg:si_usuario_limites
         where usuario = pusuario
           and empresa = pempresa;
    
        if (vuser_limit is not null or vuser_limit <> '') then 
            -- // validaciÃÆÃÂ³n adicional para reconocimiento de canal 120612
            IF (vuser_limit = "intercar") then
                select transacc, id_transacc, id_canal
                  into vtran_limit, vid_transacc, vid_canal
                  from bdinteg:si_transacc_limites
                 where transacc = ptransacc
                   and empresa = pempresa
                   and sistema = '01';
            ELSE
                SELECT id_canal 
                  into vid_canal
                  from bdinteg:si_canales
                 where cc_canal = psucursal;

                select transacc, id_transacc
                  into vtran_limit, vid_transacc
                  from bdinteg:si_transacc_limites
                 where transacc = ptransacc
                   and empresa = pempresa
                   and sistema = '01'
                   and id_canal = vid_canal;
            END IF;         

            if (vtran_limit is not null or vtran_limit <> '') then
                execute procedure bdinteg:sp_limite_max(vnum_cte, pcuenta, vid_transacc, vid_canal, vfechoy, pmonto, pnum_tarjeta)
                into vcodret, vmsje_limites, vid_autor;

                if vcodret = '00035' then
                    let vcodret = '035';
                    return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
                else
                    let vcodret = '000';
                end if;
            end if;
        end if;
        
        -- // Valida Nuevos Limites Establecidos por PLD para Retiros en Efectivo
        if ptransacc = '0223' and ptransuc <> '0301' then
            select status
              into vstatus
              from sc_retirocliente_exento 
             where cliente = vnum_cte; 
             
            if ( vstatus = 0 or vstatus is null ) then
                call sp_verifica_retiro_efectivo( psucursal, pcuenta, pmonto, vfechacalendario, vpri_dia_mes )
                returning vcodretver, vfecharet, vsdo_cuenta;
                
                if vcodretver = '000' then
                    if vfecharet < vfechacalendario then
                        let vsdo_cuenta = vsdo_cuenta;
                    else
                        let vsdo_cuenta = vsdo_actual;
                    end if;                    
                    
                    --RQM 09 704. Se agrega la variable mSaldoSbc en el calculo de saldo disponible. EEAP.
                    let vsdo_disponible = vsdo_cuenta - vsdo_retenido - vsdo_cong - vimp_chq_sbg - mSaldoSbc;
                    
                    if vsdo_disponible < 0 then
                        let vsdo_disponible = 0.00;
                    end if;
                    
                    if pmonto > vsdo_disponible then
                        let vcodret = "400";
                        return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
                    end if;
                else
                    let vcodret = '999';
                    return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
                end if;
            end if;
        end if;
        
        -- // Determina tipo de cargo
        if vtiptran >= "20" and vtiptran <= "29" then
            call gen_protsdo(pempresa, psucursal, pusuario, ptransacc, ptransuc, pfolsuc, pcuenta, pmonto, 
                             pcheque, pdivisa, vnip, preferencia, vtiporef, pnum_tarjeta, pusuautoriza)
            returning vcodret, vclave, vcomision;
        
            if vcodret <> "000" then
                if vtransaccion = 1 then
                    ROLLBACK WORK;
                    BEGIN WORK;
                else
                    ROLLBACK WORK;
                end if;
                return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
            end if;
        else
            if vtiptran >= "30" and vtiptran <= "39" then
                call protsdo(pempresa, psucursal, pusuario, ptransacc, ptransuc, pfolsuc, pcuenta, pcheque, pmonto, pdivisa, vclave)
                returning vcodret, vtranret;
            
                if vcodret <> "000" then
                    if vtransaccion = 1 then
                        ROLLBACK WORK;
                        BEGIN WORK;
                    else
                        ROLLBACK WORK;
                    end if;
            
                    return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
                end if;
            else
                --//validacion piloto SIWEB
                select nvl(flag_piloto,0)
                into vflag_siweb 
                from bdinteg:si_sucursales_web
                where sucursal = psucursal;
                
                if vflag_siweb <> 0 then
                    --//SP SIWEB validacion de transacciones duplicadas
                    call cargon_ref_web(pempresa, psucursal, pusuario, ptransacc, ptransuc, pfolsuc, pcuenta, 
                                pcheque, pmonto, pdivisa, preferencia, pnum_tarjeta, pusuautoriza)
                    returning vcodret, vtranret;                
                else
                    call cargon_ref(pempresa, psucursal, pusuario, ptransacc, ptransuc, pfolsuc, pcuenta, 
                                pcheque, pmonto, pdivisa, preferencia, pnum_tarjeta, pusuautoriza)
                    returning vcodret, vtranret;
                end if;

                -- // Forza a aplicar los movtos para un cheque propio sobregirado PISA 26 Marzo 2010
                if vcodret <> "000" and vcodret <> "400" then 
                    if vtransaccion = 1 then
                        ROLLBACK WORK;
                        BEGIN WORK;
                    else
                        ROLLBACK WORK;
                    end if;
                    
                    return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
                end if;
            end if
        end if
        
        -- // Obtiene saldo disponible de la cuenta despues de la transaccion de cargo
        --- select sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc), com_pendiente
        --- into vsdodisp, vcompend
        --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
        select sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbg, com_pendiente, saldo_sbc
          into msdo_actual, msdo_retenido, msdo_cong, mimp_chq_sbg, vcompend, mSaldoSbc
          from sc_maechq
         where empresa = pempresa
           and cuenta = pcuenta;
           
        if msdo_retenido < 0 then
            let msdo_retenido = msdo_retenido * -1;
        end if;
        
        if msdo_cong < 0 then
            let msdo_cong = msdo_cong * -1;
        end if;
        
        if mimp_chq_sbg < 0 then
            let mimp_chq_sbg = mimp_chq_sbg * -1;
        end if;   
        
        --RQM 09 704. Se agrega la validacion de la variable mSaldoSbc. EEAP.
        if mSaldoSbc < 0 then
            let mSaldoSbc = mSaldoSbc * -1;
        end if;   
        
        --RQM 09 704. Se agrega la variable mSaldoSbc en el calculo de saldo disponible. EEAP.
        let vsdodisp = msdo_actual - ( msdo_retenido + msdo_cong + mimp_chq_sbg + mSaldoSbc);
        
        IF vsdodisp is null or vsdodisp < 0 then
            LET vsdodisp = 0.00;
        END IF;
        
        if vtransaccion = 1 then
            COMMIT WORK;
            BEGIN WORK;
        else
            COMMIT WORK;
        end if;
    END IF;
        
    let vtranret = ptransacc;
    let vmontoret = pmonto;
    
    return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
        
    END;
    
END PROCEDURE

DOCUMENT
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 01-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               el campo saldo_sbc en la consulta la maestra de cheques.',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2';

create procedure "informix".abonoref_td(psucursal   char(4),
                                      pusuario    char(8),
                                      ptransacc   char(4),
                                      ptransuc    char(4),
                                      pfolsuc     char(16),
                                      pcuenta     char(20),
                                      pmonto      money(14,2),
                                      pdivisa     char(2),
                                      preferencia char(40),
                                      pfolsuc_ori char(16),
                                      pmonto_ori  money(14,2),
                                      pajuste     char(1))

        returning char(5),char(4),date,money(14,2),money(14,2);

define vsqlerr integer;
define vcodret,vcodret1 char(5);
define vtransacc,vtranret char(4);
define vfechoy date;
define vsdodisp money(14,2);
define vcompend money(14,2);
define vmonto money(14,2);
define vempresa char(3);
define vconreg smallint;


set lock mode to wait 10;
begin
   on exception set vsqlerr
      if vsqlerr <> 0  then
         let vcodret = vsqlerr;
         return vcodret,vtranret,vfechoy,vsdodisp,vmonto;
      end if;
   end exception;

   set isolation to cursor stability;

   let vcodret = "000";
   let vtranret = " ";
   let vsdodisp = 0;
   let vmonto = 0;

   select empresa into vempresa
      from bdinteg:si_ejecut
      where ejecutivo = pusuario;

   select fecha_hoy into vfechoy
      from sc_fechas
      where empresa = vempresa;

   let vmonto = pmonto;

   if pajuste = "1" then
      select count(*) into vconreg
         from sc_movdia
         where empresa = vempresa and folio_suc = pfolsuc_ori;
      if vconreg > 0 then
         call reversion(vempresa,psucursal,pusuario,pfolsuc_ori,"A")
              returning vcodret;
      else
         select tran_relac into vtransacc
            from bdinteg:si_transacc
            where empresa = vempresa and numero = ptransacc;
         call cargon_ref(vempresa,psucursal,pusuario,vtransacc,ptransuc,
                         pfolsuc,pcuenta,0,pmonto_ori,pdivisa,preferencia)
              returning vcodret,vtranret;
         if vcodret <> "000" then
            return vcodret,vtranret,vfechoy,vsdodisp,vmonto;
         end if
      end if
   end if

   call abono_ref(vempresa,psucursal,pusuario,ptransacc,ptransuc,
                  pfolsuc,pcuenta,0,pmonto,pmonto,0,0,
                  0,pdivisa,preferencia) returning vcodret;

   if vcodret <> "000" then
      call reversion(vempresa,psucursal,pusuario,pfolsuc,"A")
           returning vcodret;
      return vcodret,vtranret,vfechoy,vsdodisp,vmonto;
   end if
   
   --RQM 09 704. Se agrega el campo saldo_sbc en el calculo de saldo disponible. EEAP.
   select sdo_actual - sdo_retenido - sdo_cong - saldo_sbc, com_pendiente
      into vsdodisp, vcompend
      from sc_maechq
      where empresa = vempresa and cuenta = pcuenta;
   IF vsdodisp is null then
      LET vsdodisp = 0;
   END IF;
   IF vcompend > 0 and vsdodisp > 0 then
      call cobintcomsbg(vempresa,pcuenta,pfolsuc,pusuario,psucursal)
           returning vcodret1;
   end if
   let vtranret = ptransacc;
   return vcodret,vtranret,vfechoy,vsdodisp,vmonto;
end
end procedure

DOCUMENT
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 01-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               el campo saldo_sbc en la consulta la maestra de cheques.',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2';

create procedure "informix".cargoref_td(psucursal   char(4),
                                      pusuario    char(8),
                                      ptransacc   char(4),
                                      ptransacc2  char(4),
                                      ptransuc    char(4),
                                      pfolsuc     char(16),
                                      pcuenta     char(20),
                                      pcheque     integer,
                                      pmonto      money(14,2),
                                      pmonto2     money(14,2),
                                      pdivisa     char(2),
                                      preferencia char(40),
                                      pfolsuc_ori char(16),
                                      pmonto_ori  money(14,2),
                                      pmonto2_ori money(14,2),
                                      pajuste     char(1))

        returning char(5),char(4),char(4),date,money(14,2),money(14,2),
                  money(14,2);

define vsqlerr int;
define vcodret,vcodret1 char(5);
define vtranret,vtranret2,vtransacc char(4);
define vtiporef char(1);
define vfechoy date;
define vsdodisp money(14,2);
define vcompend money(14,2);
define vmontoret,vmontoret2 money(14,2);
define vempresa char(3);
define vejecargo char(1);
define vconreg smallint;
--RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
define cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
define cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
--RQM 09 704. Se agregan las variables para la consulta de los campos en la maestra de cheques. EEAP.
define mSdoActual    money(14,2);
define mSdoRetenido  money(14,2);
define mSdoCong      money(14,2);
define mSaldoSbc     money(14,2);

--RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
let cCodRetConsSdo		= '00000';
let cMensajeRetConsSdo	= '';
--RQM 09 704. Se inicializan las variables los campos retornados de la maestra de cheques. EEAP.
let mSdoActual    = 0.00;
let mSdoRetenido  = 0.00;
let mSdoCong      = 0.00;
let mSaldoSbc     = 0.00;

set lock mode to wait 10;
begin
   on exception set vsqlerr
      if vsqlerr <> 0  then
         let vcodret = vsqlerr;
         return vcodret,vtranret,vtranret2,vfechoy,vsdodisp,vmontoret,
                vmontoret2;
      end if;
   end exception;

   set isolation to cursor stability;

   let vcodret = "000";
   let vtranret = " ";
   let vtranret2 = " ";
   let vsdodisp = 0;
   let vmontoret = 0;
   let vmontoret2 = 0;

   select empresa into vempresa
      from bdinteg:si_ejecut
      where ejecutivo = pusuario;

   select fecha_hoy into vfechoy 
      from sc_fechas 
      where empresa = vempresa;

   let vmontoret = pmonto;
   let vmontoret2 = pmonto2;

   if pajuste = "1" then
      select count(*) into vconreg
         from sc_movdia
         where empresa = vempresa and folio_suc = pfolsuc_ori;
      if vconreg > 0 then
         call reversion(vempresa,psucursal,pusuario,pfolsuc_ori,"A")
              returning vcodret;
      else
         select tran_relac into vtransacc
            from bdinteg:si_transacc
            where empresa = vempresa and numero = ptransacc;
         call abono_ref(vempresa,psucursal,pusuario,vtransacc,ptransuc,
                        pfolsuc,pcuenta,0,pmonto_ori,pmonto_ori,0,0,
                        0,pdivisa,preferencia) returning vcodret;
         if vcodret <> "000" then
            return vcodret,vtranret,vtranret2,vfechoy,vsdodisp,vmontoret,
                   vmontoret2;
         end if
         select tran_relac into vtransacc
            from bdinteg:si_transacc
            where empresa = vempresa and numero = ptransacc2;
         call abono_ref(vempresa,psucursal,pusuario,vtransacc,ptransuc,
                        pfolsuc,pcuenta,0,pmonto2_ori,pmonto2_ori,0,0,
                        0,pdivisa,preferencia) returning vcodret;
         if vcodret <> "000" then
            call reversion(vempresa,psucursal,pusuario,pfolsuc,"A")
                 returning vcodret1;
            return vcodret,vtranret,vtranret2,vfechoy,vsdodisp,vmontoret,
                   vmontoret2;
         end if
      end if   
   end if
 
   if pmonto > 0 then
      call cargon_ref(vempresa,psucursal,pusuario,ptransacc,ptransuc,
                   pfolsuc,pcuenta,pcheque,pmonto,pdivisa,preferencia)
           returning vcodret,vtranret;
   end if
   if vcodret = "000" then
      if pmonto2 > 0 then
         call cargon_ref(vempresa,psucursal,pusuario,ptransacc2,ptransuc,
                        pfolsuc,pcuenta,pcheque,pmonto2,pdivisa,preferencia)
              returning vcodret,vtranret;
         if vcodret <> "000" then
            call reversion(vempresa,psucursal,pusuario,pfolsuc,"A")
                 returning vcodret1;
         end if
      end if
   else
      call reversion(vempresa,psucursal,pusuario,pfolsuc,"A")
           returning vcodret1;
      return vcodret,vtranret,vtranret2,vfechoy,vsdodisp,vmontoret,
             vmontoret2;
   end if

   let vmontoret = pmonto;
   
   --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
   select sdo_actual, sdo_retenido, sdo_cong, saldo_sbc, com_pendiente
   into mSdoActual, mSdoRetenido, mSdoCong, mSaldoSbc, vcompend
   from sc_maechq
   where empresa = vempresa and cuenta = pcuenta;
   
   --RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
   EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCong, mSaldoSbc, '', '', '', 'F', 2) INTO cCodRetConsSdo,cMensajeRetConsSdo,vsdodisp; 

   IF vsdodisp is null then
      LET vsdodisp = 0;
   END IF;
   IF vcompend > 0 and vsdodisp > 0 then
      call cobintcomsbg(vempresa,pcuenta,pfolsuc,pusuario,psucursal)
           returning vcodret1;
   end if
   let vtranret = ptransacc;
   return vcodret,vtranret,vtranret2,vfechoy,vsdodisp,vmontoret,vmontoret2;
end
end procedure

DOCUMENT 
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 01-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros los campos retornados en la consulta a la maestra de cheques',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2';

create procedure "informix".cargo(pempresa    char(3),
                                       psucursal   char(4),
                                       pusuario    char(8),
                                       ptransacc   char(4),
                                       ptransuc    char(4),
                                       pfolsuc     char(16),
                                       pcuenta     char(20),
                                       pcheque     integer,
                                       pmonto      money(14,2),
                                       pdivisa     char(2))
       returning char(5),char(4);

define vsqlerr int;
define vmoneda char(2);
define vmonto,vimpsbg,vimpccc,vabono_eje money(14,2);
define vvaldoc,vnaturaleza,vval_chequeras char(1);
define vsuccta char(4);
define vproducto char(4);
define vcodret char(5);
define vhorax char(12);
define vfecha_hoy date;
define vchqexp smallint;
define vtrancancta,vtrancomcan,vtranretpar,vtranret char(4);
define vcheque,vultche int;
define vctacol char(20);
define vstatus_cta,vacepcargo,vestado,vcolat char(1);
define vmotivo char(2);
define vsaldo_fin,vsaldo_col,vsdorestar,vsdo_actual money(14,2);
define vlimccc,vdispccc,vretenido,vcongelado,vdisponible money(14,2);
define vreqccc,vutilccc,vsdodisp money(14,2);
define vfecultmov date;
define vfechaccc date;
define vtotcol smallint;
define vusuario char(8);
define vtasa_aplicada decimal(9,6);
define vsobregira char(1);
define vacepta_retpar,vacepta_retiros,vper_retiros char(1);
define vdiasret,vdiasultret,i smallint;
define vtrandevobco char(4);
define vtrandevbcoop char(4);
define preferencia char(30);
define vfecha_operacion date;

DEFINE cCodRetIndicador CHAR(6);

-- RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. LEOC.
DEFINE cCodRetConsSdo       CHAR(5);  -- Codigo de retorno de SP de consulta de saldo.
DEFINE cMensajeRetConsSdo   CHAR(50); -- Mensaje de retorno de SP de consulta de saldo.
DEFINE mSaldoSbc            MONEY(14,2); -- Variable que especifica el saldo de inmovilizacion

set lock mode to wait 10;
begin
   on exception set vsqlerr
      if vsqlerr <> 0  then
         let vcodret = vsqlerr;
         return vcodret,vtranret;
      end if;
   end exception;

   -- SET DEBUG FILE TO "/home/c90316821/cargo.out";
   -- TRACE ON;

   set isolation to cursor stability;

   let vtranret = ptransacc;
   let vtasa_aplicada = 0;
   let vcodret = "000";
   let preferencia = "";
   let vfecha_operacion = TODAY;
   
   LET cCodRetIndicador  = "000000";

   -- RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. LEOC.
   let cCodRetConsSdo      = '00000';
   let cMensajeRetConsSdo  = '';
   let mSaldoSbc           = '0';

   if psucursal is null or pusuario is null or ptransacc is null  or
      pcuenta is null or pfolsuc is null or pcheque is null or
      psucursal = "   " or pusuario = "   " or ptransacc = "    " or
      pcuenta = " " or pfolsuc = " " or pmonto = 0 or
      pmonto is null then
      let vcodret = "110";
      return vcodret,vtranret;
   end if;

   select ejecutivo into vusuario
      from bdinteg:si_ejecut
      where ejecutivo = pusuario;
   if vusuario <> pusuario or vusuario is null then
      let vcodret = "106";
      return vcodret,vtranret;
   end if

   select numero,naturaleza,valida_docto,sobregira
      into vtranret,vnaturaleza,vvaldoc,vsobregira
      from bdinteg:si_transacc
      where empresa = pempresa and numero = ptransacc;

   if ptransacc != vtranret or vtranret is null then
      let vcodret="550";
      return vcodret,vtranret;
   end if;

   if vnaturaleza != "C" then
      let vcodret="560";
      return vcodret,vtranret;
   end if;

   if vvaldoc = "S" and (pcheque is null or pcheque = 0) then
      let vcodret="110";
      return vcodret,vtranret;
   end if;

   select valor into vtranretpar
      from sc_param
      where empresa = pempresa and codparam = "tranretpar";

   select fecha_hoy into vfecha_hoy from sc_fechas where empresa = pempresa;

foreach
   select sucursal,producto,ult_chq,colateral,status_cta,motivo,
          sdo_actual,lim_sbg_ccc,imp_sbg_ccc,fech_venc_ccc,sdo_retenido,
          sdo_cong,fec_ult_mov,saldo_sbc
      into vsuccta,vproducto,vultche,vcolat,vstatus_cta,vmotivo,
          vsdo_actual,vlimccc,vutilccc,vfechaccc,vretenido,
          vcongelado,vfecultmov,mSaldoSbc
      from sc_maechq
      where empresa = pempresa and cuenta = pcuenta

   if vsuccta is null then
      let vcodret = "100";
      return vcodret,vtranret;
   end if;

   if vstatus_cta = "2" then
      let vcodret = "200";
      return vcodret,vtranret;
   else
      if vstatus_cta = "3" then
         select cargo into vacepcargo from sc_bloqueo
            where codigo = vmotivo;
         if vacepcargo = "N" then
            let vcodret = "300";
            return vcodret,vtranret;
         end if;
      end if;
   end if;

   select divisa,val_chequeras,acepta_retiros,per_retiros[1,1],
          per_retiros[3,5],acepta_retpar
      into vmoneda,vval_chequeras,vacepta_retiros,vper_retiros,vdiasret,
           vacepta_retpar
      from sc_producto
      where empresa = pempresa and producto = vproducto;
   if vmoneda != pdivisa then
      let vcodret="951";
      return vcodret,vtranret;
   end if;
   if vacepta_retiros = "N" then
      select valor into vtrancancta
         from sc_param
         where empresa = pempresa and codparam = "trancancta";
      select valor into vtrancomcan
         from sc_param
         where empresa = pempresa and codparam = "trancomcan";
      select valor into vtrandevobco
         from sc_param
         where empresa = pempresa and codparam = "trandevobco";
      select valor into vtrandevbcoop
         from sc_param
         where empresa = pempresa and codparam = "trandevbcoop";
      if (ptransacc <> vtranretpar or vtranretpar is null) and
         (ptransacc <> vtrancancta or vtrancancta is null) and
         (ptransacc <> vtrandevobco or vtrandevobco is null) and
         (ptransacc <> vtrandevbcoop or vtrandevbcoop is null) and
         (ptransacc <> vtrancomcan or vtrancomcan is null) then
         let vcodret = "957";
         return vcodret,vtranret;
      end if
   else
      let vdiasultret = vfecha_hoy - vfecultmov;
      if vdiasultret < vdiasret then
         let vcodret = "957";
         return vcodret,vtranret;
      end if
   end if

   if vval_chequeras = "S" and vvaldoc = "S" then
      if pcheque > vultche then
         let vcodret = "520";
         return vcodret,vtranret;
      end if;
   end if;

   if vvaldoc = "S" then
      select numero,estado into vcheque,vestado
         from sc_contch
         where empresa = pempresa and cuenta = pcuenta and numero = pcheque;
      if vcheque is null then
         let vcheque = 0;
         let vestado = " ";
      end if;
      if vcheque != pcheque then
         select numero,estado into vcheque,vestado
            from sc_histch
            where empresa = pempresa and cuenta = pcuenta and numero = pcheque;
         if vcheque is null then
            let vcheque = 0;
            let vestado = " ";
         end if;
         if vcheque != pcheque then
            insert into sc_contch
               values(pempresa,pcuenta,pcheque," ",vfecha_hoy,0);
            let vestado = "N";
         else
            if vestado="P" or vestado="X" then
               let vcodret="600";
               let vtranret=ptransacc;
               return vcodret,vtranret;
            end if;
            if vestado = "S" then
               let vcodret="700";
               let vtranret=ptransacc;
               return vcodret,vtranret;
            end if;
            if vestado = "C" then
               let vcodret="800";
               let vtranret=ptransacc;
               return vcodret,vtranret;
            end if;
         end if;
      else
         if vestado="P" or vestado="X" then
            let vcodret="600";
            let vtranret=ptransacc;
            return vcodret,vtranret;
         end if;
         if vestado = "S" then
            let vcodret="700";
            let vtranret=ptransacc;
            return vcodret,vtranret;
         end if;
         if vestado = "C" then
            let vcodret="800";
            let vtranret=ptransacc;
            return vcodret,vtranret;
         end if;
      end if;
   end if;

   let vdispccc = vlimccc - vutilccc;
   if vfechaccc < vfecha_hoy or vdispccc is null then
      let vdispccc = 0;
   end if

   -- RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. LEOC
   EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo('',vsdo_actual,vretenido,vcongelado,mSaldoSbc,'','','','F','2') INTO cCodRetConsSdo,cMensajeRetConsSdo,vsdodisp;

   -- RQM 09 704. Se modifica el calculo de saldo para esta operacion. LEOC
   -- let vdisponible = vsdo_actual - vretenido - vcongelado + vdispccc;
   let vdisponible = vsdodisp + vdispccc;

   if vsdo_actual = pmonto and ptransacc = vtranretpar then
      let vcodret="002";
      let vtranret=ptransacc;
      return vcodret,vtranret;
   end if

   if vsobregira = "S"  and pmonto > vdisponible then
      let vreqccc= pmonto - vsdo_actual - vretenido - vcongelado;
      if vdispccc >= vreqccc then
         let vimpccc = vreqccc;
         let vimpsbg = 0;
      else
         let vimpccc = vdispccc;
         let vimpsbg = vreqccc - vdispccc;
      end if
      if vimpccc > 0 then
         let vhorax = current hour to fraction(3);
         insert into sc_movdia values
            (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,vhorax,
             "3240",vsuccta,vproducto,pempresa,pcuenta,"  ",pcheque,vimpccc,
             vimpccc,0,0,0," "," ",vsdo_actual,ptransuc,
             preferencia,vtasa_aplicada,"","","",vfecha_operacion);
			 
		 EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,"3240",vimpccc,vfecha_hoy,"C")
		 INTO cCodRetIndicador;
      end if
      if vimpsbg > 0 then
         let vhorax = current hour to fraction(3);
         insert into sc_movdia values
            (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,vhorax,
             "3357",vsuccta,vproducto,pempresa,pcuenta,"  ",pcheque,vimpsbg,
             vimpsbg,0,0,0," "," ",vsdo_actual,ptransuc,
             preferencia,vtasa_aplicada,"","","",vfecha_operacion);
			 
		 EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,"3357",vimpsbg,vfecha_hoy,"C")
		 INTO cCodRetIndicador;
      end if
      let vhorax = current hour to fraction(3);
      insert into sc_movdia values
         (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,vhorax,
          ptransacc,vsuccta,vproducto,pempresa,pcuenta,"  ",pcheque,pmonto,0,
          0,0,0," "," ",vsdo_actual,ptransuc,preferencia,vtasa_aplicada,"","","",vfecha_operacion);
      if vvaldoc = "S" then
         update sc_contch
            set estado = "P",
                fecha_alta = vfecha_hoy,
                importe = pmonto
            where empresa = pempresa and cuenta = pcuenta and numero = pcheque;
         let vchqexp = 1;
      else
         let vchqexp = 0;
      end if
      update sc_maechq
         set sdo_actual     = sdo_actual - vdisponible + vdispccc,
             imp_sbg_ccc    = imp_sbg_ccc + vimpccc,
             imp_chq_sbg    = imp_chq_sbg + vimpsbg,
             imp_cgos_mes   = imp_cgos_mes + pmonto,
             num_cgos_mes   = num_cgos_mes + 1,
             imp_abonos_mes = imp_abonos_mes + vreqccc,
             num_abonos_mes = num_abonos_mes + 1,
             chq_exp_mes    = chq_exp_mes + vchqexp,
             fec_ult_mov    = vfecha_hoy
         where empresa = pempresa and cuenta = pcuenta;
      let vtranret = ptransacc;
      let vcodret = "000";
	  
	  -- LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
	  EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,ptransacc,pmonto,vfecha_hoy,"C")
	  INTO cCodRetIndicador;
	  
      return vcodret,vtranret;
   end if

   if pmonto > vdisponible then
      if vcolat = "S" then
         call total_colateral(pempresa,pcuenta) returning vsaldo_col,vtotcol;
         let vsaldo_fin = vdisponible + vsaldo_col;
         if pmonto > vsaldo_fin then
            if vvaldoc = "S" then
               call gencomdev(pempresa,pcuenta,ptransacc,pcheque,pfolsuc,
                    pmonto,"1", psucursal,pusuario)
                    returning vcodret;
            end if
            let vcodret = "400";
            let vtranret = ptransacc;
            return vcodret,vtranret;
         else
            let vsdorestar = pmonto - vdisponible;
            let vabono_eje = vsdorestar;
            for i= 1 to 10
                call sdoind_col(pempresa,pcuenta,i)
                     returning vsaldo_col,vctacol;
                if vsaldo_col >0 then
                   if vsdorestar > vsaldo_col then
                      call cargon_ref(pempresa,psucursal,pusuario,"3325",
                           ptransuc,pfolsuc,vctacol,0,vsaldo_col,pdivisa," ")
                           returning vcodret,vtranret;
                      let vhorax = current hour to fraction(3);
                      insert into sc_movdia values
                         (0,pfolsuc,psucursal,pusuario,vfecha_hoy,
                          vfecha_hoy,current hour to fraction(3),"3278",
                          vsuccta,vproducto,pempresa,pcuenta,"  ",
                          pcheque,vsaldo_col, vsaldo_col,0,0,0," ","2",
                          0,ptransuc,preferencia,vtasa_aplicada,"","","",vfecha_operacion);
                      let vsdorestar = vsdorestar - vsaldo_col;
					  EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,"3278",vsaldo_col,vfecha_hoy,"C")
					  INTO cCodRetIndicador;
                   else
                      call cargon_ref(pempresa,psucursal,pusuario,"3325",
                           ptransuc,pfolsuc,vctacol,0,vsdorestar,pdivisa," ")
                           returning vcodret,vtranret;
                      let vhorax = current hour to fraction(3);
                      insert into sc_movdia values
                         (0,pfolsuc,psucursal,pusuario,vfecha_hoy,
                          vfecha_hoy,current hour to fraction(3),"3278",
                          vsuccta,vproducto,pempresa,pcuenta," ",pcheque,
                          vsdorestar,vsdorestar,0,0,0," ","2",0,ptransuc,
                          preferencia,vtasa_aplicada,"","","",vfecha_operacion);
					  EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,"3278",vsdorestar,vfecha_hoy,"C")
					  INTO cCodRetIndicador;
                      exit for;
                   end if;
                end if;
            end for;
            let vhorax = current hour to fraction(3);
            if vdispccc > 0 then
               let i=i+1;
               let vhorax = current hour to fraction(3);
               insert into sc_movdia values
                  (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,
                   vhorax,"3240",vsuccta,vproducto,pempresa,pcuenta,"  ",
                   pcheque,vdispccc,vdispccc,0,0,0," "," ",vsdo_actual,
                   ptransuc,preferencia,vtasa_aplicada,"","","",vfecha_operacion);
			   EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,"3240",vdispccc,vfecha_hoy,"C")
			   INTO cCodRetIndicador;
            end if;
            let vhorax = current hour to fraction(3);
            insert into sc_movdia values
               (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,
                vhorax,ptransacc,vsuccta,vproducto,pempresa,pcuenta,
                "  ",pcheque,pmonto,0,0,0,0," "," ",vsdo_actual,ptransuc,
                preferencia,vtasa_aplicada,"","","",vfecha_operacion);
            if vvaldoc = "S" then
               update sc_contch
                  set estado  = "P",
                      fecha_alta = vfecha_hoy,
                      importe = pmonto
                  where empresa = pempresa and cuenta = pcuenta and
                        numero = pcheque;
               let vchqexp = 1;
            else
               let vchqexp = 0;
            end if
            update sc_maechq
               set sdo_actual    = vretenido + vcongelado,
                   fec_ult_mov   = vfecha_hoy,
                   imp_sbg_ccc   = imp_sbg_ccc+vdispccc,
                   imp_cgos_mes  = imp_cgos_mes + pmonto,
                   num_cgos_mes  = num_cgos_mes + 1,
                   imp_abonos_mes= imp_abonos_mes+vabono_eje+vdispccc,
                   num_abonos_mes= num_abonos_mes + i,
                   chq_exp_mes   = chq_exp_mes + vchqexp
               where empresa = pempresa and cuenta = pcuenta;
            let vcodret = "000";
            let vtranret = ptransacc;
			
			-- LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
			EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,ptransacc,pmonto,vfecha_hoy,"C")
			INTO cCodRetIndicador;
			
            return vcodret,vtranret;
         end if;
      else
         if vvaldoc = "S" then
            call gencomdev(pempresa,pcuenta,ptransacc,pcheque,pfolsuc,
                           pmonto,"1",psucursal,pusuario)
                 returning vcodret;
         end if
         let vcodret = "400";
         let vtranret = ptransacc;
         return vcodret,vtranret;
      end if;
   else
      -- RQM 09 704. Se modifica el calculo de saldo para esta operacion, se retira la inicializaciÃ³n del saldo disponible ya que es el mismo llamado del spl . LEOC
      -- let vsdodisp=vsdo_actual - vretenido - vcongelado;
      let vreqccc = 0;
      if pmonto > vsdodisp then
         let vreqccc = pmonto - vsdodisp;
         let vhorax = current hour to fraction(3);
         insert into sc_movdia values
            (0,pfolsuc,psucursal,pusuario,vfecha_hoy,
             vfecha_hoy,vhorax,"3240",vsuccta,vproducto,pempresa,pcuenta,
             " ",pcheque,vreqccc,vreqccc,0,0,0," "," ",vsdo_actual,
             ptransuc,preferencia,vtasa_aplicada,"","","",vfecha_operacion);
		 EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,"3240",vreqccc,vfecha_hoy,"C")
		 INTO cCodRetIndicador;
      end if;
      let vhorax = current hour to fraction(3);
      insert into sc_movdia values
         (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,
          vhorax,ptransacc,vsuccta,vproducto,pempresa,pcuenta," ",pcheque,
          pmonto,0,0,0,0, " "," ",vsdo_actual,ptransuc,preferencia,
          vtasa_aplicada,"","","",vfecha_operacion);
      if vvaldoc = "S" then
         let vchqexp = 1;
         update sc_contch
            set estado  = "P",
                fecha_alta = vfecha_hoy,
                importe = pmonto
            where empresa = pempresa and cuenta = pcuenta and numero = pcheque;
      else
         let vchqexp = 0;
      end if
      update sc_maechq
         set sdo_actual     = sdo_actual - pmonto + vreqccc,
             imp_sbg_ccc    = imp_sbg_ccc + vreqccc,
             imp_cgos_mes   = imp_cgos_mes + pmonto,
             num_cgos_mes   = num_cgos_mes + 1,
             imp_abonos_mes = imp_abonos_mes + vreqccc,
             num_abonos_mes = num_abonos_mes + 1,
             fec_ult_mov    = vfecha_hoy,
             chq_exp_mes    = chq_exp_mes + vchqexp
          where empresa = pempresa and cuenta = pcuenta;
		  
		 -- LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
		 EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,ptransacc,pmonto,vfecha_hoy,"C")
		 INTO cCodRetIndicador;
      return vcodret,vtranret;
   end if;
end foreach
let vcodret = "100";
let vtranret = ptransacc;
return vcodret,vtranret;
end;
end procedure
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
'VERSION :      1.0.1';

CREATE PROCEDURE "informix".cargo_ref_cel( pnum_tarjeta char(16),
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
    define mSaldoSbc            MONEY(14,2); -- Variable que especifica el saldo de inmovilizacion
    
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
        -- RQM 09 704. Se agrega la variable del saldo inmovilizado para el consumo del spl sp_cons_sdodisp_x_tpcalculo.LEOC
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
           
        if msdo_retenido < 0 then
            let msdo_retenido = msdo_retenido * -1;
        end if;
        
        if msdo_cong < 0 then
            let msdo_cong = msdo_cong * -1;
        end if;
        
        if mimp_chq_sbg < 0 then
            let mimp_chq_sbg = mimp_chq_sbg * -1;
        end if;  
        -- RQM 09 704. Se comenta el codigo(VALIDACIONES) que vienen incluido en el spl sp_cons_sdodisp_x_tpcalculo. LEOC      
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
               let ptransefe = '0805'; -- Se pone en duro ya que al ser cash Back libre no se puede identificar la transacciï¿½n
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
'VERSION :      1.0.1';

create procedure "informix".cargo_ref_td(pempresa     char(3),
                                         psucursal    char(4),
                                         pusuario     char(8),
                                         ptransacc    char(4),
                                         ptransuc     char(4),
                                         pfolsuc      char(16),
                                         pcuenta      char(20),
                                         pcheque      integer,
                                         pmonto       money(14,2),
                                         pdivisa      char(2),
                                         preferencia  char(40),
                                         pnum_tarjeta char(16),
                                         pusuautoriza char(8))
                                         
returning char(5), char(4), date, money(14,2), money(14,2);

    define vsqlerr                  int;
    define vtiptran                 char(2);
    define vcodret,vcodret1         char(5);
    define vtranret                 char(4);
    define vtiporef                 char(1);
    define vclave                   char(4);
    define vcomision                money(14,2);
    define vfechoy                  date;
    define vfechacalendario         date;
    define vsdodisp                 money(14,2);
    define vcompend                 money(14,2);
    define vmontoret                money(14,2);
    define vnip                     char(4);
    define vlimite_aut,vdisp_mes    money(14,2);
    define vadicional               integer;
    define vstatus_cta              char(1);
    
    define vmsje_limites            char(80);
    define vid_autor                char(1);
    define vnum_cte                 char(20);
    define vuser_limit              char(8);
    define vtran_limit              char(8);
    define vid_transacc             char(2);
    define vid_canal                char(2);
    define vind_dispon              char(1);
    
    define msdo_actual      money(14,2);
    define msdo_retenido    money(14,2);
    define msdo_cong        money(14,2);
    define mimp_chq_sbg     money(14,2);
    define mSaldoSbc    money(14,2);

    let vclave = " ";
    
    --- set debug file to "/tmp/cargoref.out";
    --- trace on;

    set isolation to dirty read;
    set lock mode to wait 2;

    begin

    on exception set vsqlerr
        if vsqlerr <> 0  then
            let vcodret = vsqlerr;
            return vcodret,vtranret,vfechoy,vsdodisp,vmontoret;
        end if;
    end exception;

    let vcodret = "000";
    let vtranret = " ";
    let vtiporef = "4";
    let vmontoret = 0;
    let vsdodisp = 0;
    let vnip = " ";
    let vind_dispon = '0';
    let msdo_actual = 0.00;
    let msdo_retenido = 0.00;
    let msdo_cong = 0.00;
    let mimp_chq_sbg = 0.00;
    let mSaldoSbc     = 0.00;
    
    select {+INDEX(sc_fechas idx_fechas1)}
           fecha_hoy, ind_disponible
      into vfechacalendario, vind_dispon
      from sc_fechas
     where empresa = pempresa;

    select fecha_proceso, status_cta, num_cte
      into vfechoy, vstatus_cta, vnum_cte
      from sc_maechq
     where empresa = pempresa
       and cuenta = pcuenta;
       
    if vind_dispon = '0' then
        let vcodret = "004";
        return vcodret,vtranret,vfechoy,vsdodisp,vmontoret;
    end if

    if (vfechoy is null or vstatus_cta = '4' or vstatus_cta = '5') then
        let vfechoy = vfechacalendario;
    end if
    
    if (vfechoy < vfechacalendario) then
        let vcodret = "549";
        return vcodret,vtranret,vfechoy,vsdodisp,vmontoret;
    end if
    
    if (vstatus_cta in('2','6','7','8')) then
        let vcodret = "200";
        return vcodret,vtranret,vfechoy,vsdodisp,vmontoret;
    end if
    
    select tipo_tran 
      into vtiptran
      from bdinteg:si_transacc
     where empresa = pempresa 
       and numero = ptransacc;

    if vtiptran is null then
        let vcodret = "550";
        return vcodret,vtranret,vfechoy,vsdodisp,vmontoret;
    end if;

    if pcuenta = "" then
        select cuenta 
          into pcuenta
          from sc_tarjeta
         where empresa = pempresa 
           and num_tarjeta = pnum_tarjeta;
    end if

    select limite_aut,disp_mes
      into vlimite_aut,vdisp_mes
      from sc_tarjeta
     where empresa = pempresa
       and num_tarjeta = pnum_tarjeta
       and cuenta   = pcuenta
       and tipo_tarjeta = "A";

    let vadicional = dbinfo("sqlca.sqlerrd2");

    if vadicional <> 0 then
        IF vlimite_aut <> 0 THEN
            let vdisp_mes = nvl(vdisp_mes,0)  + pmonto;
            if vdisp_mes > vlimite_aut then
                let  vcodret = "777";
                return vcodret,vtranret,vfechoy,vsdodisp,vmontoret;
            end if
        END IF
    end if
    
    -- // Validacion de limites 
    select usuario
      into vuser_limit
      from bdinteg:si_usuario_limites
     where usuario = pusuario
       and empresa = pempresa;
    
    if (vuser_limit is not null or vuser_limit <> '') then 
    -- // validacion adicional para reconocimiento de canal 120612
       IF (vuser_limit = "intercar") then
            select transacc, id_transacc, id_canal
                into vtran_limit, vid_transacc, vid_canal
                from bdinteg:si_transacc_limites
                where transacc = ptransacc
                and empresa = pempresa
                and sistema = '01';
       ELSE
         SELECT id_canal 
         into vid_canal
         from bdinteg:si_canales
         where cc_canal = psucursal;
         
            select transacc, id_transacc
                into vtran_limit, vid_transacc
                from bdinteg:si_transacc_limites
                where transacc = ptransacc
                and empresa = pempresa
                and sistema = '01'
                and id_canal = vid_canal;
       END IF;   

        if (vtran_limit is not null or vtran_limit <> '') then
            execute procedure bdinteg:sp_limite_max(vnum_cte, pcuenta, vid_transacc, vid_canal, vfechoy, pmonto, pnum_tarjeta, pfolsuc,preferencia)
            into vcodret, vmsje_limites, vid_autor;
            
            if vcodret = '00035' then
                let vcodret = '035';
                return vcodret, vtranret, vfechoy, vsdodisp, vmontoret;
            else
                let vcodret = '000';
            end if;
        end if;
    end if;
    
    if vtiptran >= "20" and vtiptran <= "29" then
        call gen_protsdo(pempresa,psucursal,pusuario,ptransacc,ptransuc,pfolsuc,
                         pcuenta,pmonto,pcheque,pdivisa,vnip,preferencia,
                         vtiporef,pnum_tarjeta,pusuautoriza)
        returning vcodret,vclave,vcomision;

        if vcodret <> "000" then
            return vcodret,vtranret,vfechoy,vsdodisp,vmontoret;
        end if;
        
    else
        if vtiptran >= "30" and vtiptran <= "39" then
            call protsdo(pempresa,psucursal,pusuario,ptransacc,ptransuc,pfolsuc,
            pcuenta,pcheque,pmonto,pdivisa,vclave)
            returning vcodret,vtranret;

            if vcodret <> "000" then
                return vcodret,vtranret,vfechoy,vsdodisp,vmontoret;
            end if;
        else
            call cargon_ref(pempresa,psucursal,pusuario,ptransacc,ptransuc,
                            pfolsuc,pcuenta,pcheque,pmonto,pdivisa,preferencia,
                            pnum_tarjeta,pusuautoriza)
            returning vcodret,vtranret;
            
            if vcodret <> "000" then
                return vcodret,vtranret,vfechoy,vsdodisp,vmontoret;
            end if;
        end if
    end if

    let vmontoret = pmonto;

    --- select sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc), com_pendiente
    ---   into vsdodisp, vcompend
    select sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbg, com_pendiente,saldo_sbc
      into msdo_actual, msdo_retenido, msdo_cong, mimp_chq_sbg, vcompend,mSaldoSbc
      from sc_maechq
     where empresa = pempresa 
       and cuenta = pcuenta;
       
    if msdo_retenido < 0 then
        let msdo_retenido = msdo_retenido * -1;
    end if;
    
    if msdo_cong < 0 then
        let msdo_cong = msdo_cong * -1;
    end if;
    
    if mimp_chq_sbg < 0 then
        let mimp_chq_sbg = mimp_chq_sbg * -1;
    end if;   
    
    let vsdodisp = msdo_actual - ( msdo_retenido + msdo_cong + mimp_chq_sbg + mSaldoSbc);
       
    IF vsdodisp is null or vsdodisp < 0 then
        LET vsdodisp = 0.00;
    END IF;

    IF vcompend > 0 and vsdodisp > 0 then
        call cobintcomsbg(pempresa,pcuenta,pfolsuc,pusuario,psucursal)
        returning vcodret1;

        if vcodret <> "000" then
            return vcodret,vtranret,vfechoy,vsdodisp,vmontoret;
        end if;
    end if

    let vtranret = ptransacc;

    return vcodret,vtranret,vfechoy,vsdodisp,vmontoret;

    end

end procedure

DOCUMENT
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 01-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros los campos retornados en la consulta a la maestra de cheques',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2';

CREATE PROCEDURE "informix".sp_obtienectascancel( pEmpresa      CHAR(3), 
                                                  pNumCte       CHAR(20), 
                                                  pCuenta       CHAR(20), 
                                                  pTarjeta      CHAR(20), 
                                                  pSolicitudes  SMALLINT, 
                                                  pOrigen       CHAR(1) )
RETURNING CHAR(5)     AS  CODIGO_SIF,
          CHAR(5)     AS  CODIGO_OFI,
          CHAR(80)    AS  MENSAJE_EJECUCION,
          CHAR(20)    AS  NUMERO_CLIENTE,
          CHAR(20)    AS  CUENTA,
          CHAR(4)     AS  CODIGO_PRODUCTO,
          CHAR(40)    AS  NOMBRE_PRODUCTO,
          CHAR(10)    AS  FECHA_APERTURA,
          CHAR(1)     AS  CODIGO_ESTATUS,
          CHAR(30)    AS  DESCRIPCION_ESTATUS,
          CHAR(10)    AS  FECHA_ULTIMO_MOVTO,
          MONEY(14,2) AS  SALDO;

    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;    
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cMensajeRet      CHAR(80);
    DEFINE ibandera			INTEGER;
    DEFINE cNumCte			CHAR(20);
    DEFINE cCuenta			CHAR(20);
    DEFINE cFechaAper		CHAR(10);
    DEFINE cUltimoMov		CHAR(10);
    DEFINE cStatus_cta		CHAR(1);
    DEFINE cDescStatus_cta	CHAR(30);
    DEFINE mSdoAct			MONEY(14, 2);
    DEFINE mSdoCong			MONEY(14, 2);
    DEFINE mSdoRet			MONEY(14, 2);
    DEFINE mSdoSbg          MONEY(14, 2);
    DEFINE mSdoSBC          MONEY(14, 2);
    DEFINE mSdoCCC          MONEY(14, 2);
    DEFINE mComPen          MONEY(14, 2);
    DEFINE cTpoTar			CHAR(1);
    DEFINE cStatTar			CHAR(1);
    DEFINE cCodProd			CHAR(4);
    DEFINE cNomProd			CHAR(40);
    DEFINE mSdoDisp		    MONEY(14, 2);
    DEFINE iLimite		    INTEGER;
	--RQM 09 704. Se crea la siguiente variable . DHG
	DEFINE mSaldoSBC  			MONEY; 		--Obtiene el saldo_sbc de la maestra de cheques.

    LET cCodRet			= '00000';
    LET cCodRet2		= '00000';
    LET iSqlErr			= 0;
    LET iIsamErr		= 0;
    LET cErrorInfo		= '';
    LET cMensajeRet		= 'PROCESO EXITOSO';
    LET ibandera		= 0;
    LET cNumCte			= '';
    LET cCuenta			= '';
    LET cFechaAper		= '';
    LET cStatus_cta		= '';
    LET cDescStatus_cta	= '';
    LET cUltimoMov		= '';
    LET mSdoAct			= 0.00;
    LET mSdoCong		= 0.00;
    LET mSdoRet			= 0.00;
    LET mSdoSbg         = 0.00;
    LET mSdoSBC         = 0.00;
    LET mSdoCCC         = 0.00;
    LET mComPen         = 0.00;
    LET cTpoTar			= '';
    LET cStatTar		= '';
    LET cCodProd		= '';
    LET cNomProd		= '';
    LET mSdoDisp		= 0.00;
    LET iLimite			= 0;
	--RQM 09 704. Se inicializa la siguiente variable generada. DHG
	LET mSaldoSBC				=0.00;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iSqlErr;
            LET cMensajeRet = 'ERROR NO CONTROLADO, VERIFIQUE CON EL AREA DE SISTEMAS';
            RETURN NVL(TRIM(cCodRet),''), NVL(TRIM(cCodRet2),''), NVL(TRIM(cMensajeRet),''), NVL(TRIM(cNumCte), ''), 
                   NVL(TRIM(cCuenta), ''), NVL(TRIM(cCodProd), ''), NVL(TRIM(cNomProd), ''), NVL(TRIM(cFechaAper), ''), 
                   NVL(TRIM(cStatus_cta), ''), NVL(TRIM(cDescStatus_cta), ''), NVL(TRIM(cUltimoMov), ''), NVL(mSdoDisp, 0.00);
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/home/sysifx/jesusm/sp_obtienectascancel.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;	
    SET LOCK MODE TO WAIT 3;
    
    IF NVL(pNumCte,'') = '' AND NVL(pCuenta,'') = '' AND NVL(pTarjeta,'') = '' THEN
        LET cCodRet = '050';
        LET cCodRet2 = '343';
        
        SELECT descripcion
          INTO cMensajeRet
          FROM bdinteg:"informix".si_codret
         WHERE codigo_retorno = '050'
           AND sistema = '01';

        RETURN NVL(TRIM(cCodRet),''), NVL(TRIM(cCodRet2),''), NVL(TRIM(cMensajeRet),''), NVL(TRIM(cNumCte), ''), 
               NVL(TRIM(cCuenta), ''), NVL(TRIM(cCodProd), ''), NVL(TRIM(cNomProd), ''), NVL(TRIM(cFechaAper), ''), 
               NVL(TRIM(cStatus_cta), ''), NVL(TRIM(cDescStatus_cta), ''), NVL(TRIM(cUltimoMov), ''), NVL(mSdoDisp, 0.00);
    END IF;

    IF NVL(pTarjeta, '') <> '' OR NVL(pCuenta, '') <> '' THEN
        LET cCuenta = TRIM(pCuenta);

        IF NVL(pTarjeta, '') <> '' THEN
            SELECT cuenta, tipo_tarjeta, status_tar
              INTO cCuenta, cTpoTar, cStatTar
              FROM bdicheq:"informix".sc_tarjeta
             WHERE empresa = pEmpresa
               AND num_tarjeta = TRIM(pTarjeta)
               AND secuencia = ( SELECT MAX(secuencia) 
                                   FROM bdicheq:"informix".sc_tarjeta 
                                  WHERE empresa = pEmpresa 
                                    AND num_tarjeta = pTarjeta );

            IF NVL(cCuenta, '') = '' THEN -- NO EXISTE LA TARJETA RECIBIDA
                LET cCodRet = '054';
                LET cCodRet2 = '324';
                
                SELECT descripcion
                  INTO cMensajeRet
                  FROM bdinteg:"informix".si_codret
                 WHERE codigo_retorno = '054'
                   AND sistema = '01';
                
                RETURN NVL(TRIM(cCodRet),''), NVL(TRIM(cCodRet2),''), NVL(TRIM(cMensajeRet),''), NVL(TRIM(cNumCte), ''), 
                       NVL(TRIM(cCuenta), ''), NVL(TRIM(cCodProd), ''), NVL(TRIM(cNomProd), ''), NVL(TRIM(cFechaAper), ''), 
                       NVL(TRIM(cStatus_cta), ''), NVL(TRIM(cDescStatus_cta), ''), NVL(TRIM(cUltimoMov), ''), NVL(mSdoDisp, 0.00);
            END IF

            IF cTpoTar <> 'T' THEN -- TIPO DE TARJETA INVALIDA PARA CANCELAR, TIENE QUE SER 'T' - TITULAR
                LET cCodRet = '053';
                LET cCodRet2 = '323';
                
                SELECT descripcion
                  INTO cMensajeRet
                  FROM bdinteg:"informix".si_codret
                 WHERE codigo_retorno = '053'
                   AND sistema = '01';
                
                RETURN NVL(TRIM(cCodRet),''), NVL(TRIM(cCodRet2),''), NVL(TRIM(cMensajeRet),''), NVL(TRIM(cNumCte), ''), 
                       NVL(TRIM(cCuenta), ''), NVL(TRIM(cCodProd), ''), NVL(TRIM(cNomProd), ''), NVL(TRIM(cFechaAper), ''), 
                       NVL(TRIM(cStatus_cta), ''), NVL(TRIM(cDescStatus_cta), ''), NVL(TRIM(cUltimoMov), ''), NVL(mSdoDisp, 0.00);
            END IF

            IF cStatTar <> 'A' THEN -- ESTATUS DE TARJETA NO VALIDO PARA CANCELAR, TIENE QUE ESTAR ACTIVA
                LET cCodRet = '055';
                LET cCodRet2 = '325';
                
                SELECT descripcion
                  INTO cMensajeRet
                  FROM bdinteg:"informix".si_codret
                 WHERE codigo_retorno = '055'
                   AND sistema = '01';
                
                RETURN NVL(TRIM(cCodRet),''), NVL(TRIM(cCodRet2),''), NVL(TRIM(cMensajeRet),''), NVL(TRIM(cNumCte), ''), 
                       NVL(TRIM(cCuenta), ''), NVL(TRIM(cCodProd), ''), NVL(TRIM(cNomProd), ''), NVL(TRIM(cFechaAper), ''), 
                       NVL(TRIM(cStatus_cta), ''), NVL(TRIM(cDescStatus_cta), ''), NVL(TRIM(cUltimoMov), ''), NVL(mSdoDisp, 0.00);
            END IF
        END IF
		--RQM 09 704. Se agrega la variable mSaldoSBC para almacenar el dato de la columna saldo_sbc. DHG
        SELECT a.cuenta, a.num_cte, a.producto, a.status_cta, 
               a.sdo_actual, a.sdo_cong, a.sdo_retenido, a.imp_chq_sbg, a.imp_chq_sbc, a.imp_sbg_ccc, a.com_pendiente,
               LPAD(DAY(a.fec_ult_mov), 2, "0") || "/" || LPAD(MONTH(a.fec_ult_mov), 2, "0")|| "/" || YEAR(a.fec_ult_mov),
               LPAD(DAY(b.fecha_alta), 2, "0") || "/" || LPAD(MONTH(b.fecha_alta), 2, "0")|| "/" || YEAR(b.fecha_alta),
               c.nombre, d.descripcion, a.saldo_sbc  
          INTO cCuenta, cNumCte, cCodProd, cStatus_cta, 
               mSdoAct, mSdoCong, mSdoRet, mSdoSbg, mSdoSBC, mSdoCCC, mComPen,
               cUltimoMov, cFechaAper, cNomProd, cDescStatus_cta, mSaldoSBC
          FROM bdicheq:"informix".sc_maechq a,
               bdicheq:"informix".sc_maenoc  b, 
               bdicheq:"informix".sc_producto c,
               bdicheq:"informix".sc_mae_estatus d
         WHERE a.cuenta = cCuenta
           AND b.cuenta = a.cuenta
           AND a.status_cta <> '2'
           AND a.producto = c.producto
           AND a.producto NOT IN ( SELECT producto FROM bdicheq:"informix".sc_productonocancelacion )
           AND a.status_cta = d.cod_estatus;


        IF NVL(cCuenta, '') = '' THEN -- INCONGRUENCIA DE DATOS, NO EXISTE LA CUENTA LIGADA A LA TARJETA EN EL MAESTRO DE CUENTAS DE DEBITO
            LET cCodRet = '060';
            LET cCodRet2 = '326';
            
            SELECT descripcion
              INTO cMensajeRet
              FROM bdinteg:"informix".si_codret
             WHERE codigo_retorno = '060'
               AND sistema = '01';            
            
            RETURN NVL(TRIM(cCodRet),''), NVL(TRIM(cCodRet2),''), NVL(TRIM(cMensajeRet),''), NVL(TRIM(cNumCte), ''), 
                   NVL(TRIM(cCuenta), ''), NVL(TRIM(cCodProd), ''), NVL(TRIM(cNomProd), ''), NVL(TRIM(cFechaAper), ''), 
                   NVL(TRIM(cStatus_cta), ''), NVL(TRIM(cDescStatus_cta), ''), NVL(TRIM(cUltimoMov), ''), NVL(mSdoDisp, 0.00);
        END IF

        --RQM 09 704. Se agrega la variable mSaldoSBC en el calculo de saldo disponible. DHG
		LET mSdoDisp = (mSdoAct + mSdoSBC) - (mSdoCong + mSdoRet + mSdoSbg + mSdoCCC + mComPen + mSaldoSBC);		

        RETURN NVL(TRIM(cCodRet),''), NVL(TRIM(cCodRet2),''), NVL(TRIM(cMensajeRet),''), NVL(TRIM(cNumCte), ''), 
               NVL(TRIM(cCuenta), ''), NVL(TRIM(cCodProd), ''), NVL(TRIM(cNomProd), ''), NVL(TRIM(cFechaAper), ''), 
               NVL(TRIM(cStatus_cta), ''), NVL(TRIM(cDescStatus_cta), ''), NVL(TRIM(cUltimoMov), ''), NVL(mSdoDisp, 0.00);


    ELSE
        IF pOrigen = 'C' THEN
            LET iLimite = 0;
            LET pSolicitudes = 0; 
        ELSE
            LET iLimite = 11;
        END IF;
        
        FOREACH	
			--RQM 09 704. Se agrega la variable mSaldoSBC para almacenar el dato de la columna saldo_sbc. DHG
            SELECT skip pSolicitudes LIMIT iLimite
                   a.cuenta, a.num_cte, a.producto, a.status_cta, 
                   a.sdo_actual, a.sdo_cong, a.sdo_retenido, a.imp_chq_sbg, a.imp_chq_sbc, a.imp_sbg_ccc, a.com_pendiente,
                   LPAD(DAY(a.fec_ult_mov), 2, "0") || "/" || LPAD(MONTH(a.fec_ult_mov), 2, "0")|| "/" || YEAR(a.fec_ult_mov),
                   LPAD(DAY(b.fecha_alta), 2, "0") || "/" || LPAD(MONTH(b.fecha_alta), 2, "0")|| "/" || YEAR(b.fecha_alta),
                   c.nombre, d.descripcion, a.saldo_sbc
              INTO cCuenta, cNumCte, cCodProd, cStatus_cta, 
                   mSdoAct, mSdoCong, mSdoRet, mSdoSbg, mSdoSBC, mSdoCCC, mComPen,
                   cUltimoMov, cFechaAper, cNomProd, cDescStatus_cta, mSaldoSBC
              FROM bdicheq:"informix".sc_maechq a,
                   bdicheq:"informix".sc_maenoc  b, 
                   bdicheq:"informix".sc_producto c,
                   bdicheq:"informix".sc_mae_estatus d
             WHERE b.cuenta = a.cuenta
               AND a.num_cte = pNumCte
               AND a.status_cta <> '2'
               AND a.producto = c.producto
               AND a.producto NOT IN (SELECT producto FROM bdicheq:"informix".sc_productonocancelacion )
               AND a.status_cta = d.cod_estatus 
             ORDER BY a.cuenta

            LET ibandera = 1;
            --RQM 09 704. Se agrega la variable mSaldoSBC en el calculo de saldo disponible. DHG
			LET mSdoDisp = (mSdoAct + mSdoSBC) - (mSdoCong + mSdoRet + mSdoSbg + mSdoCCC + mComPen + mSaldoSBC);

            LET cCodRet = '00000';
            LET cCodRet2 = '00000';
            LET cMensajeRet = 'PROCESO EXITOSO';

            RETURN NVL(TRIM(cCodRet),''), NVL(TRIM(cCodRet2),''), NVL(TRIM(cMensajeRet),''), NVL(TRIM(cNumCte), ''), 
                   NVL(TRIM(cCuenta), ''), NVL(TRIM(cCodProd), ''), NVL(TRIM(cNomProd), ''), NVL(TRIM(cFechaAper), ''), 
                   NVL(TRIM(cStatus_cta), ''), NVL(TRIM(cDescStatus_cta), ''), NVL(TRIM(cUltimoMov), ''), NVL(mSdoDisp, 0.00) WITH RESUME;
        END FOREACH
        
        IF ibandera = 0  THEN		
            LET cCodRet = '062';
            LET cCodRet2 = '344';
            
            SELECT codigo_retorno, descripcion
              INTO cCodRet, cMensajeRet
              FROM bdinteg:"informix".si_codret
             WHERE codigo_retorno = '062'
               AND sistema = '01';		
            
            RETURN NVL(TRIM(cCodRet),''), NVL(TRIM(cCodRet2),''), NVL(TRIM(cMensajeRet),''), NVL(TRIM(cNumCte), ''), 
                   NVL(TRIM(cCuenta), ''), NVL(TRIM(cCodProd), ''), NVL(TRIM(cNomProd), ''), NVL(TRIM(cFechaAper), ''), 
                   NVL(TRIM(cStatus_cta), ''), NVL(TRIM(cDescStatus_cta), ''), NVL(TRIM(cUltimoMov), ''), NVL(mSdoDisp, 0.00);			
        END IF;
    END IF;
    
    END
    
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se Obtienen las cuentas susceptibles a cancelacion', 
'AUTOR: Armando Morales',
'FECHA: Agosto 2012',
'VERSION: 20120802.1530',
'BD: BDICHEQ',
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 10-06-2025',
'MODIFICACION: Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.2';

CREATE PROCEDURE "informix".sp_obtienectascancel_web( pEmpresa      CHAR(3), 
                                                  pNumCte       CHAR(20), 
                                                  pCuenta       CHAR(20), 
                                                  pTarjeta      CHAR(20), 
                                                  pSolicitudes  SMALLINT, 
                                                  pOrigen       CHAR(1) )
RETURNING CHAR(5)     AS  CODIGO_SIF,
          CHAR(5)     AS  CODIGO_OFI,
          CHAR(80)    AS  MENSAJE_EJECUCION,
          CHAR(20)    AS  NUMERO_CLIENTE,
          CHAR(20)    AS  CUENTA,
          CHAR(4)     AS  CODIGO_PRODUCTO,
          CHAR(40)    AS  NOMBRE_PRODUCTO,
          CHAR(10)    AS  FECHA_APERTURA,
          CHAR(1)     AS  CODIGO_ESTATUS,
          CHAR(30)    AS  DESCRIPCION_ESTATUS,
          CHAR(10)    AS  FECHA_ULTIMO_MOVTO,
          MONEY(14,2) AS  SALDO;

    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;    
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cMensajeRet      CHAR(80);
    DEFINE ibandera			INTEGER;
    DEFINE cNumCte			CHAR(20);
    DEFINE cCuenta			CHAR(20);
    DEFINE cFechaAper		CHAR(10);
    DEFINE cUltimoMov		CHAR(10);
    DEFINE cStatus_cta		CHAR(1);
    DEFINE cDescStatus_cta	CHAR(30);
    DEFINE mSdoAct			MONEY(14, 2);
    DEFINE mSdoCong			MONEY(14, 2);
    DEFINE mSdoRet			MONEY(14, 2);
    DEFINE mSdoSbg          MONEY(14, 2);
    DEFINE mSdoSBC          MONEY(14, 2);
    DEFINE mSdoCCC          MONEY(14, 2);
    DEFINE mComPen          MONEY(14, 2);
    DEFINE cTpoTar			CHAR(1);
    DEFINE cStatTar			CHAR(1);
    DEFINE cCodProd			CHAR(4);
    DEFINE cNomProd			CHAR(40);
    DEFINE mSdoDisp		    MONEY(14, 2);
    DEFINE iLimite		    INTEGER;
	--RQM 09 704. Se crea la siguiente variable . DHG
	DEFINE mSaldoSBC  			MONEY; 		--Obtiene el saldo_sbc de la maestra de cheques.

    LET cCodRet			= '00000';
    LET cCodRet2		= '00000';
    LET iSqlErr			= 0;
    LET iIsamErr		= 0;
    LET cErrorInfo		= '';
    LET cMensajeRet		= 'PROCESO EXITOSO';
    LET ibandera		= 0;
    LET cNumCte			= '';
    LET cCuenta			= '';
    LET cFechaAper		= '';
    LET cStatus_cta		= '';
    LET cDescStatus_cta	= '';
    LET cUltimoMov		= '';
    LET mSdoAct			= 0.00;
    LET mSdoCong		= 0.00;
    LET mSdoRet			= 0.00;
    LET mSdoSbg         = 0.00;
    LET mSdoSBC         = 0.00;
    LET mSdoCCC         = 0.00;
    LET mComPen         = 0.00;
    LET cTpoTar			= '';
    LET cStatTar		= '';
    LET cCodProd		= '';
    LET cNomProd		= '';
    LET mSdoDisp		= 0.00;
    LET iLimite			= 0;
	--RQM 09 704. Se inicializa la siguiente variable generada. DHG
	LET mSaldoSBC				=0.00;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iSqlErr;
            LET cMensajeRet = 'ERROR NO CONTROLADO, VERIFIQUE CON EL AREA DE SISTEMAS';
            RETURN NVL(TRIM(cCodRet),''), NVL(TRIM(cCodRet2),''), NVL(TRIM(cMensajeRet),''), NVL(TRIM(cNumCte), ''), 
                   NVL(TRIM(cCuenta), ''), NVL(TRIM(cCodProd), ''), NVL(TRIM(cNomProd), ''), NVL(TRIM(cFechaAper), ''), 
                   NVL(TRIM(cStatus_cta), ''), NVL(TRIM(cDescStatus_cta), ''), NVL(TRIM(cUltimoMov), ''), NVL(mSdoDisp, 0.00);
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/home/sysifx/jesusm/sp_obtienectascancel.out";	
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;	
    SET LOCK MODE TO WAIT 3;
    
    IF NVL(pNumCte,'') = '' AND NVL(pCuenta,'') = '' AND NVL(pTarjeta,'') = '' THEN
        LET cCodRet = '00050';
        LET cCodRet2 = '00343';
        
        SELECT descripcion
          INTO cMensajeRet
          FROM bdinteg:"informix".si_codret
         WHERE codigo_retorno = '050'
           AND sistema = '01';

        RETURN NVL(TRIM(cCodRet),''), NVL(TRIM(cCodRet2),''), NVL(TRIM(cMensajeRet),''), NVL(TRIM(cNumCte), ''), 
               NVL(TRIM(cCuenta), ''), NVL(TRIM(cCodProd), ''), NVL(TRIM(cNomProd), ''), NVL(TRIM(cFechaAper), ''), 
               NVL(TRIM(cStatus_cta), ''), NVL(TRIM(cDescStatus_cta), ''), NVL(TRIM(cUltimoMov), ''), NVL(mSdoDisp, 0.00);
    END IF;

    IF NVL(pTarjeta, '') <> '' OR NVL(pCuenta, '') <> '' THEN
        LET cCuenta = TRIM(pCuenta);

        IF NVL(pTarjeta, '') <> '' THEN
            SELECT cuenta, tipo_tarjeta, status_tar
              INTO cCuenta, cTpoTar, cStatTar
              FROM bdicheq:"informix".sc_tarjeta
             WHERE empresa = pEmpresa
               AND num_tarjeta = TRIM(pTarjeta)
               AND secuencia = ( SELECT MAX(secuencia) 
                                   FROM bdicheq:"informix".sc_tarjeta 
                                  WHERE empresa = pEmpresa 
                                    AND num_tarjeta = pTarjeta );

            IF NVL(cCuenta, '') = '' THEN -- NO EXISTE LA TARJETA RECIBIDA
                LET cCodRet = '00054';
                LET cCodRet2 = '00324';
                
                SELECT descripcion
                  INTO cMensajeRet
                  FROM bdinteg:"informix".si_codret
                 WHERE codigo_retorno = '054'
                   AND sistema = '01';
                
                RETURN NVL(TRIM(cCodRet),''), NVL(TRIM(cCodRet2),''), NVL(TRIM(cMensajeRet),''), NVL(TRIM(cNumCte), ''), 
                       NVL(TRIM(cCuenta), ''), NVL(TRIM(cCodProd), ''), NVL(TRIM(cNomProd), ''), NVL(TRIM(cFechaAper), ''), 
                       NVL(TRIM(cStatus_cta), ''), NVL(TRIM(cDescStatus_cta), ''), NVL(TRIM(cUltimoMov), ''), NVL(mSdoDisp, 0.00);
            END IF

            IF cTpoTar <> 'T' THEN -- TIPO DE TARJETA INVALIDA PARA CANCELAR, TIENE QUE SER 'T' - TITULAR
                LET cCodRet = '00053';
                LET cCodRet2 = '00323';
                
                SELECT descripcion
                  INTO cMensajeRet
                  FROM bdinteg:"informix".si_codret
                 WHERE codigo_retorno = '053'
                   AND sistema = '01';
                
                RETURN NVL(TRIM(cCodRet),''), NVL(TRIM(cCodRet2),''), NVL(TRIM(cMensajeRet),''), NVL(TRIM(cNumCte), ''), 
                       NVL(TRIM(cCuenta), ''), NVL(TRIM(cCodProd), ''), NVL(TRIM(cNomProd), ''), NVL(TRIM(cFechaAper), ''), 
                       NVL(TRIM(cStatus_cta), ''), NVL(TRIM(cDescStatus_cta), ''), NVL(TRIM(cUltimoMov), ''), NVL(mSdoDisp, 0.00);
            END IF

            IF cStatTar <> 'A' THEN -- ESTATUS DE TARJETA NO VALIDO PARA CANCELAR, TIENE QUE ESTAR ACTIVA
                LET cCodRet = '00055';
                LET cCodRet2 = '00325';
                
                SELECT descripcion
                  INTO cMensajeRet
                  FROM bdinteg:"informix".si_codret
                 WHERE codigo_retorno = '055'
                   AND sistema = '01';
                
                RETURN NVL(TRIM(cCodRet),''), NVL(TRIM(cCodRet2),''), NVL(TRIM(cMensajeRet),''), NVL(TRIM(cNumCte), ''), 
                       NVL(TRIM(cCuenta), ''), NVL(TRIM(cCodProd), ''), NVL(TRIM(cNomProd), ''), NVL(TRIM(cFechaAper), ''), 
                       NVL(TRIM(cStatus_cta), ''), NVL(TRIM(cDescStatus_cta), ''), NVL(TRIM(cUltimoMov), ''), NVL(mSdoDisp, 0.00);
            END IF
        END IF
		--RQM 09 704. Se agrega la variable mSaldoSBC para almacenar el dato de la columna saldo_sbc. DHG
        SELECT a.cuenta, a.num_cte, a.producto, a.status_cta, 
               a.sdo_actual, a.sdo_cong, a.sdo_retenido, a.imp_chq_sbg, a.imp_chq_sbc, a.imp_sbg_ccc, a.com_pendiente,
               LPAD(DAY(a.fec_ult_mov), 2, "0") || "/" || LPAD(MONTH(a.fec_ult_mov), 2, "0")|| "/" || YEAR(a.fec_ult_mov),
               LPAD(DAY(b.fecha_alta), 2, "0") || "/" || LPAD(MONTH(b.fecha_alta), 2, "0")|| "/" || YEAR(b.fecha_alta),
               c.nombre, d.descripcion, a.saldo_sbc  
          INTO cCuenta, cNumCte, cCodProd, cStatus_cta, 
               mSdoAct, mSdoCong, mSdoRet, mSdoSbg, mSdoSBC, mSdoCCC, mComPen,
               cUltimoMov, cFechaAper, cNomProd, cDescStatus_cta,mSaldoSBC
          FROM bdicheq:"informix".sc_maechq a,
               bdicheq:"informix".sc_maenoc  b, 
               bdicheq:"informix".sc_producto c,
               bdicheq:"informix".sc_mae_estatus d
         WHERE a.cuenta = cCuenta
           AND b.cuenta = a.cuenta
           AND a.status_cta <> '2'
           AND a.producto = c.producto
           AND a.producto NOT IN ( SELECT producto FROM bdicheq:"informix".sc_productonocancelacion )
           AND a.status_cta = d.cod_estatus;


        IF NVL(cCuenta, '') = '' THEN -- INCONGRUENCIA DE DATOS, NO EXISTE LA CUENTA LIGADA A LA TARJETA EN EL MAESTRO DE CUENTAS DE DEBITO
            LET cCodRet = '00060';
            LET cCodRet2 = '00326';
            
            SELECT descripcion
              INTO cMensajeRet
              FROM bdinteg:"informix".si_codret
             WHERE codigo_retorno = '060'
               AND sistema = '01';            
            
            RETURN NVL(TRIM(cCodRet),''), NVL(TRIM(cCodRet2),''), NVL(TRIM(cMensajeRet),''), NVL(TRIM(cNumCte), ''), 
                   NVL(TRIM(cCuenta), ''), NVL(TRIM(cCodProd), ''), NVL(TRIM(cNomProd), ''), NVL(TRIM(cFechaAper), ''), 
                   NVL(TRIM(cStatus_cta), ''), NVL(TRIM(cDescStatus_cta), ''), NVL(TRIM(cUltimoMov), ''), NVL(mSdoDisp, 0.00);
        END IF

		--RQM 09 704. Se agrega la variable mSaldoSBC en el calculo de saldo disponible. DHG
		LET mSdoDisp = (mSdoAct + mSdoSBC) - (mSdoCong + mSdoRet + mSdoSbg + mSdoCCC + mComPen + mSaldoSBC);		

        RETURN NVL(TRIM(cCodRet),''), NVL(TRIM(cCodRet2),''), NVL(TRIM(cMensajeRet),''), NVL(TRIM(cNumCte), ''), 
               NVL(TRIM(cCuenta), ''), NVL(TRIM(cCodProd), ''), NVL(TRIM(cNomProd), ''), NVL(TRIM(cFechaAper), ''), 
               NVL(TRIM(cStatus_cta), ''), NVL(TRIM(cDescStatus_cta), ''), NVL(TRIM(cUltimoMov), ''), NVL(mSdoDisp, 0.00);


    ELSE
        IF pOrigen = 'C' THEN
            LET iLimite = 0;
            LET pSolicitudes = 0; 
        ELSE
            LET iLimite = 11;
        END IF;
        
        FOREACH	
		--RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DHG
            SELECT skip pSolicitudes LIMIT iLimite
                   a.cuenta, a.num_cte, a.producto, a.status_cta, 
                   a.sdo_actual, a.sdo_cong, a.sdo_retenido, a.imp_chq_sbg, a.imp_chq_sbc, a.imp_sbg_ccc, a.com_pendiente,
                   LPAD(DAY(a.fec_ult_mov), 2, "0") || "/" || LPAD(MONTH(a.fec_ult_mov), 2, "0")|| "/" || YEAR(a.fec_ult_mov),
                   LPAD(DAY(b.fecha_alta), 2, "0") || "/" || LPAD(MONTH(b.fecha_alta), 2, "0")|| "/" || YEAR(b.fecha_alta),
                   c.nombre, d.descripcion, a.saldo_sbc   
              INTO cCuenta, cNumCte, cCodProd, cStatus_cta, 
                   mSdoAct, mSdoCong, mSdoRet, mSdoSbg, mSdoSBC, mSdoCCC, mComPen,
                   cUltimoMov, cFechaAper, cNomProd, cDescStatus_cta, mSaldoSBC
              FROM bdicheq:"informix".sc_maechq a,
                   bdicheq:"informix".sc_maenoc  b, 
                   bdicheq:"informix".sc_producto c,
                   bdicheq:"informix".sc_mae_estatus d
             WHERE b.cuenta = a.cuenta
               AND a.num_cte = pNumCte
               AND a.status_cta <> '2'
               AND a.producto = c.producto
               AND a.producto NOT IN (SELECT producto FROM bdicheq:"informix".sc_productonocancelacion )
               AND a.status_cta = d.cod_estatus 
             ORDER BY a.cuenta

            LET ibandera = 1;
            --RQM 09 704. Se agrega la variable mSaldoSBC en el calculo de saldo disponible. DHG
			LET mSdoDisp = (mSdoAct + mSdoSBC) - (mSdoCong + mSdoRet + mSdoSbg + mSdoCCC + mComPen + mSaldoSBC);

            LET cCodRet = '00000';
            LET cCodRet2 = '00000';
            LET cMensajeRet = 'PROCESO EXITOSO';

            RETURN NVL(TRIM(cCodRet),''), NVL(TRIM(cCodRet2),''), NVL(TRIM(cMensajeRet),''), NVL(TRIM(cNumCte), ''), 
                   NVL(TRIM(cCuenta), ''), NVL(TRIM(cCodProd), ''), NVL(TRIM(cNomProd), ''), NVL(TRIM(cFechaAper), ''), 
                   NVL(TRIM(cStatus_cta), ''), NVL(TRIM(cDescStatus_cta), ''), NVL(TRIM(cUltimoMov), ''), NVL(mSdoDisp, 0.00) WITH RESUME;
        END FOREACH
        
        IF ibandera = 0  THEN		
            LET cCodRet = '00062';
            LET cCodRet2 = '00344';
            
            SELECT codigo_retorno, descripcion
              INTO cCodRet, cMensajeRet
              FROM bdinteg:"informix".si_codret
             WHERE codigo_retorno = '062'
               AND sistema = '01';		
            
            RETURN NVL(TRIM(cCodRet),''), NVL(TRIM(cCodRet2),''), NVL(TRIM(cMensajeRet),''), NVL(TRIM(cNumCte), ''), 
                   NVL(TRIM(cCuenta), ''), NVL(TRIM(cCodProd), ''), NVL(TRIM(cNomProd), ''), NVL(TRIM(cFechaAper), ''), 
                   NVL(TRIM(cStatus_cta), ''), NVL(TRIM(cDescStatus_cta), ''), NVL(TRIM(cUltimoMov), ''), NVL(mSdoDisp, 0.00);			
        END IF;
    END IF;
    
    END
    
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se Obtienen las cuentas susceptibles a cancelacion', 
'AUTOR: Armando Morales',
'FECHA: Agosto 2012',
'VERSION: 20120802.1530',
'BD: BDICHEQ',
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 10-06-2025',
'MODIFICACION: Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.2';

CREATE PROCEDURE "informix".cargo_retenido(pempresa char(3))

RETURNING CHAR(5);

   DEFINE vcodret     	CHAR(5);
   DEFINE sql_err     	INTEGER;

   DEFINE vfecha	DATE;
   DEFINE vhora		CHAR(15);
   DEFINE vsql		CHAR(100);
   DEFINE vfolio	CHAR(20);

   DEFINE vcuenta	CHAR(20);
   DEFINE vimporte 	MONEY(14,2);
   DEFINE vimport 	MONEY(14,2);
   DEFINE vdisp		MONEY(14,2);
   DEFINE vmaxsec 	SMALLINT;
   DEFINE vtarjeta	CHAR(16);
   DEFINE vsucursal	CHAR(4);
   DEFINE vtransacc	CHAR(4);
   DEFINE vfecha_cargo	DATE;
   DEFINE vdispo	MONEY(14,2);
   DEFINE vcargo	MONEY(14,2);
   DEFINE vdescripcion	CHAR(40);
	--RQM 09 704. Se agregan las variables para el llamado y retorno de consulta de saldo. DHG.
	DEFINE mSdoActual		MONEY(14,2); --Monto del saldo actual de la cuenta.
	DEFINE mSdoRetenido     MONEY(14,2); --Monto del saldo retenido de la cuenta.
	DEFINE mSdoCong	        MONEY(14,2); --Monto del saldo congelado de la cuenta.
	DEFINE mSaldoSBC        MONEY(14,2); --Monto del saldo inmovilizado (salvo buen cobro) de la cuenta.
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.


   LET vcodret = "000";
	--RQM 09 704. Se inicializan las variables para el llamado y retorno de consulta de saldo. DHG.
	LET mSdoActual			=0.00;	
	LET mSdoRetenido		=0.00;
	LET mSdoCong			=0.00;
	LET mSaldoSBC   		=0.00;
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';

   BEGIN

   ON EXCEPTION
       SET sql_err
       IF sql_err <> 0 THEN
	    LET vcodret = sql_err;
           RETURN vcodret;
       END IF;
   END EXCEPTION;

   -- SET DEBUG FILE TO "./cuentascargadas.out";
   -- TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   SELECT fecha_hoy
     INTO vfecha
     FROM sc_fechas
    WHERE empresa = pempresa;

   LET vhora = current hour to fraction;

   LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];

   FOREACH WITH HOLD
       SELECT {+ INDEX (cuentas idx_cuentas)} cuenta, importe, descripcion
	 INTO vcuenta, vimporte, vdescripcion
         FROM cuentas
        WHERE cuenta IS NOT NULL

	--SELECT sdo_actual - sdo_cong - sdo_retenido, sucursal
	 --INTO vdisp, vsucursal
       SELECT sdo_actual,sdo_cong,sdo_retenido,saldo_sbc,sucursal
	 INTO  mSdoActual,mSdoCong,mSdoRetenido,mSaldoSBC,vsucursal
	 FROM sc_maechq
	WHERE empresa = pempresa
	  AND cuenta = vcuenta;
	
	--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
	EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('',mSdoActual,mSdoRetenido,mSdoCong,mSaldoSBC,0.00,0.00,0.00,'F',2) INTO cCodRetConsSdo,cMensajeRetConsSdo,vdisp;
    
       IF vdisp > 0.00 THEN

           SELECT MAX(secuencia)
             INTO vmaxsec
             FROM sc_tarjeta
            WHERE empresa = pempresa
              AND cuenta = vcuenta
              AND tipo_tarjeta = "T";

           SELECT num_tarjeta
             INTO vtarjeta
             FROM sc_tarjeta
            WHERE empresa = pempresa
              AND cuenta = vcuenta
              AND secuencia = vmaxsec;

           UPDATE sc_maechq
              SET status_cta = "1",
		  motivo = " "
	    WHERE empresa = pempresa
              AND cuenta = vcuenta;


	   IF vdisp >= vimporte THEN

	       CALL cargo_ref(pempresa, vsucursal, "informix",
			      "0270", "0270", vfolio,
			      vcuenta, 0, vimporte, "01",
			      vdescripcion, vtarjeta, "informix")
	       RETURNING vcodret, vtransacc, vfecha_cargo, vdispo, vcargo;

	       IF vcodret = "000" THEN

		   INSERT INTO sc_histbloq VALUES(
			pempresa, vcuenta, "D", "00", " ",
	                0.00, "informix", vfecha,
			current hour to fraction,
			"1111", "D", vfolio, " ");

		   DELETE FROM sc_ctabloqueo
		    WHERE cuenta = vcuenta;

		   INSERT INTO sc_ctabloqueohist VALUES (vcuenta, "09", 4);

		   LET vcargo = vcargo;

               ELSE

		   UPDATE sc_maechq
                      SET status_cta = "3",
		          motivo = "09"
	            WHERE empresa = pempresa
                      AND cuenta = vcuenta;

		   UPDATE sc_ctabloqueo
	              SET opcion = 3
	    	    WHERE cuenta = vcuenta;

           	   UPDATE sc_histbloq
	      	      SET opcion = 3
	    	    WHERE cuenta = vcuenta;

		   LET vcargo = 0;

               END IF;

	       INSERT INTO cargos VALUES (vcuenta, vimporte, vcargo);

	   ELSE

 	       LET vimport = vdisp;

               CALL cargo_ref(pempresa, vsucursal, "informix",
			      "0270", "0270", vfolio,
			      vcuenta, 0, vimport, "01",
			      vdescripcion, vtarjeta, "informix")
	       RETURNING vcodret, vtransacc, vfecha_cargo, vdispo, vcargo;

               IF vcodret = "000" THEN

		   UPDATE sc_maechq
                      SET status_cta = "3",
		          motivo = "09"
	            WHERE empresa = pempresa
                      AND cuenta = vcuenta;

		   UPDATE sc_ctabloqueo
	              SET opcion = 3
	    	    WHERE cuenta = vcuenta;

           	   UPDATE sc_histbloq
	      	      SET opcion = 3
	    	    WHERE cuenta = vcuenta;

                   LET vcargo = vcargo;

               ELSE

		   UPDATE sc_maechq
                      SET status_cta = "3",
		          motivo = "09"
	            WHERE empresa = pempresa
                      AND cuenta = vcuenta;

		   UPDATE sc_ctabloqueo
	              SET opcion = 3
	            WHERE cuenta = vcuenta;

                   UPDATE sc_histbloq
	              SET opcion = 3
	            WHERE cuenta = vcuenta;

		   LET vcargo = 0;

               END IF;

               INSERT INTO cargos VALUES (vcuenta, vimporte, vcargo);

           END IF;

       ELSE

	  LET vcargo = 0;

	  INSERT INTO cargos VALUES (vcuenta, vimporte, vcargo);

	  CONTINUE FOREACH;

       END IF;

   END FOREACH

   LET vsql = "";
   LET vsql = 'echo "UNLOAD TO cuentascargadas.unl SELECT * FROM cargos WHERE cuenta IS NOT NULL" > cargos.sql';
   SYSTEM vsql;

   LET vsql = "";
   LET vsql = "dbaccess bdicheq cargos.sql";
   -- LET vsql = "/ifxsif01/bin/dbaccess bdicheq cargos.sql";
   SYSTEM vsql;
   LET vsql = "";

   END;

   --DROP TABLE "informix".cuentas;
   --DROP TABLE "informix".cargos;

   RETURN vcodret;

END PROCEDURE
DOCUMENT
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 11-06-2025',
'MODIFICACION: Se modifica la forma de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.2';

CREATE PROCEDURE "informix".cargo_retenido_especial(pempresa char(3))

RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret          CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vfecha           DATE;
    DEFINE vhora            CHAR(15);
    DEFINE vsql             CHAR(200);
    DEFINE vfolio           CHAR(20);
    DEFINE vcuenta          CHAR(20);
    DEFINE vstatus          CHAR(1);
    DEFINE vimporte         MONEY(14,2);
    DEFINE vimport          MONEY(14,2);
    DEFINE vdisp            MONEY(14,2);
    DEFINE vmaxsec          SMALLINT;
    DEFINE vtarjeta         CHAR(16);
    DEFINE vsucursal        CHAR(4);
    DEFINE vtransacc        CHAR(4);
    DEFINE vfecha_cargo     DATE;
    DEFINE vdispo           MONEY(14,2);
    DEFINE vcargo           MONEY(14,2);
    DEFINE vdescripcion     CHAR(40);
    DEFINE vexiste          INTEGER;
    DEFINE nComit           INTEGER;
    DEFINE vcuantos         INTEGER;
    DEFINE vcontador        INTEGER;
    DEFINE vfechades        CHAR(10);
    DEFINE vfechadescarga   CHAR(6);
    DEFINE vdia             CHAR(2);
    DEFINE vmes             CHAR(2);
    DEFINE vanio            CHAR(2);
    DEFINE vnombre          VARCHAR(40);
    DEFINE vcargado         MONEY(14,2);
    DEFINE whora1           CHAR(5);
    DEFINE whora2           CHAR(2);
    DEFINE whora3           CHAR(2);
    DEFINE whora            CHAR(4);
    DEFINE vnumcte          CHAR(20);
    DEFINE vctacte          CHAR(20);
    DEFINE vstatus_cta      CHAR(1);
    DEFINE vsuc_cta         CHAR(4);
    DEFINE vexiste_cta      CHAR(1);
    DEFINE vaceptab         CHAR(1);
    DEFINE vacepcargo       CHAR(1);
    DEFINE vmotivo          CHAR(2);
    DEFINE vimporte_cargo   MONEY(14,2);
    DEFINE vcargados        MONEY(14,2);
    DEFINE vdisponible      MONEY(14,2);
    DEFINE vcargo_cta       MONEY(14,2);
    DEFINE vdesc            CHAR(40);
	--RQM 09 704. Se agregan las variables para el llamado y retorno de consulta de saldo. DHG.
	DEFINE mSdoActual		MONEY(14,2); --Monto del saldo actual de la cuenta.
	DEFINE mSdoRetenido     MONEY(14,2); --Monto del saldo retenido de la cuenta.
	DEFINE mSdoCong	        MONEY(14,2); --Monto del saldo congelado de la cuenta.
	DEFINE mSaldoSBC        MONEY(14,2); --Monto del saldo inmovilizado (salvo buen cobro) de la cuenta.
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.

	--RQM 09 704. Se inicializan las variables para el llamado y retorno de consulta de saldo. DHG.
	LET mSdoActual			=0.00;	
	LET mSdoRetenido		=0.00;
	LET mSdoCong			=0.00;
	LET mSaldoSBC   		=0.00;
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';
		
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/cargo_retenido_especial.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret = sql_err;
            LET vcodret2 = isam_err;
            IF nComit = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret, vcodret2, vcuantos;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/cargo_retenido_especial.out";
    --- TRACE ON;

    LET vcodret   = "000";
    LET vcodret2  = "000";
    LET nComit    = 0;
    LET vcuantos  = 0;
    LET vcontador = -1;

    SET ISOLATION TO DIRTY READ;

    SELECT {+INDEX(sc_fechas idx_fechas1)}
           fecha_hoy
      INTO vfecha
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    UPDATE bdicheq:sc_producto
       SET per_retiros = 'D 0'
     WHERE producto = '1100';

    LET vhora  = CURRENT HOUR TO FRACTION;
    LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    TRUNCATE TABLE "informix".cargos;

    FOREACH WITH HOLD
        SELECT {+INDEX(cuentas idx_cuentas)}
               cuenta, importe, descripcion
          INTO vcuenta, vimporte, vdescripcion
          FROM cuentas
         WHERE cuenta IS NOT NULL

        --SELECT sdo_actual - sdo_cong - sdo_retenido, sucursal, status_cta
			--INTO vdisp, vsucursal, vstatus
        SELECT sdo_actual,sdo_cong,sdo_retenido,saldo_sbc, sucursal, status_cta
          INTO mSdoActual,mSdoCong,mSdoRetenido,mSaldoSBC, vsucursal, vstatus
          FROM sc_maechq
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
           
		--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
		EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('',mSdoActual,mSdoRetenido,mSdoCong,mSaldoSBC,0.00,0.00,0.00,'F',2) INTO cCodRetConsSdo,cMensajeRetConsSdo,vdisp;        
		   
        IF vcontador = -1 THEN
            BEGIN WORK;
            LET nComit    = 1;
            LET vcontador = 0;
        END IF
           
        IF vdisp > 0.00 THEN
            SELECT MAX(secuencia)
              INTO vmaxsec
              FROM sc_tarjeta
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND tipo_tarjeta = "T";

            SELECT num_tarjeta
              INTO vtarjeta
              FROM sc_tarjeta
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND secuencia = vmaxsec;

            IF vstatus = 3 THEN
                UPDATE sc_maechq
                   SET status_cta = "1",
                       motivo = " "
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta;

                SELECT COUNT(*)
                  INTO vexiste
                  FROM sc_ctabloqueo
                 WHERE cuenta = vcuenta;

                IF vexiste <> 0 THEN
                    DELETE FROM sc_ctabloqueo
                     WHERE cuenta = vcuenta;
                END IF

                SELECT COUNT(*)
                  INTO vexiste
                  FROM sc_histbloq
                 WHERE cuenta = vcuenta
                   AND status_blo = "B"
                   AND tipo_mov = "B"
                   AND empresa = pempresa;

                IF vexiste <> 0 THEN
                    INSERT INTO sc_histbloq VALUES(
                        pempresa, vcuenta, "D", "00", " ",
                        0.00, "informix", vfecha,
                        current hour to fraction,
                        "1111", "D", vfolio, " ");
                        --"1111", "D", vfolio, " ","","","","");
                END IF
            END IF

            IF vdisp >= vimporte THEN
                CALL cargo_ref(pempresa, vsucursal, "informix", "0270", 
                               "0270", vfolio, vcuenta, 0, vimporte, "01", 
                               vdescripcion, vtarjeta, "informix")
                RETURNING vcodret, vtransacc, vfecha_cargo, vdispo, vcargo;

                IF vcodret = "000" THEN
                    LET vcargo = vcargo;
                ELSE
                    UPDATE sc_maechq
                       SET status_cta = "3",
                           motivo = "09"
                     WHERE empresa = pempresa
                       AND cuenta = vcuenta;

                    SELECT COUNT(*)
                      INTO vexiste
                      FROM sc_ctabloqueo
                     WHERE cuenta = vcuenta;

                    IF vexiste = 0 THEN
                        INSERT INTO sc_ctabloqueo VALUES(vcuenta, "09", "3");
                    ELSE
                        UPDATE sc_ctabloqueo
                           SET clave = "09",
                               opcion = "3"
                         WHERE cuenta = vcuenta;
                    END IF

                    INSERT INTO sc_ctabloqueohist VALUES (vcuenta, "09", "3");

                    INSERT INTO sc_histbloq VALUES(
                        pempresa,vcuenta,"B","09",3,0.00,"informix",vfecha, 
                        current hour to fraction,"1111","B",vfolio," ");

                    LET vcargo = 0;
                END IF

                INSERT INTO cargos VALUES(vcuenta,vimporte,vcargo,vdescripcion, '');
            ELSE
                LET vimport = vdisp;

                CALL cargo_ref(pempresa, vsucursal, "informix", "0270", 
                               "0270", vfolio, vcuenta, 0, vimport, "01",
                               vdescripcion, vtarjeta, "informix")
                RETURNING vcodret, vtransacc, vfecha_cargo, vdispo, vcargo;

                IF vcodret = "000" THEN
                    UPDATE sc_maechq
                       SET status_cta = "3",
                           motivo = "09"
                     WHERE empresa = pempresa
                       AND cuenta = vcuenta;

                    SELECT COUNT(*)
                      INTO vexiste
                      FROM sc_ctabloqueo
                     WHERE cuenta = vcuenta;

                    IF vexiste = 0 THEN
                        INSERT INTO sc_ctabloqueo VALUES (vcuenta, "09", "3");
                    ELSE 
                        UPDATE sc_ctabloqueo
                           SET clave = "09",
                               opcion = "3"
                         WHERE cuenta = vcuenta;
                    END IF

                    INSERT INTO sc_ctabloqueohist VALUES (vcuenta, "09", "3");

                    INSERT INTO sc_histbloq VALUES(
                        pempresa,vcuenta,"B","09",3,0.00,"informix",vfecha, 
                        current hour to fraction,"1111","B",vfolio," ");                        

                    LET vcargo = vcargo;
                ELSE
                    UPDATE sc_maechq
                       SET status_cta = "3",
                           motivo = "09"
                     WHERE empresa = pempresa
                       AND cuenta = vcuenta;

                    SELECT COUNT(*)
                      INTO vexiste
                      FROM sc_ctabloqueo
                     WHERE cuenta = vcuenta;

                    IF vexiste = 0 THEN
                        INSERT INTO sc_ctabloqueo VALUES (vcuenta, "09", "3");
                    ELSE 
                        UPDATE sc_ctabloqueo
                           SET clave = "09",
                               opcion = "3"
                         WHERE cuenta = vcuenta;
                    END IF

                    INSERT INTO sc_ctabloqueohist VALUES (vcuenta, "09", "3");

                    INSERT INTO sc_histbloq VALUES(
                        pempresa,vcuenta,"B","09",3,0.00,"informix",vfecha, 
                        current hour to fraction,"1111","B",vfolio," ");

                    LET vcargo = 0;
                END IF

                INSERT INTO cargos VALUES(vcuenta,vimporte,vcargo,vdescripcion, '');
            END IF
        ELSE
            IF vstatus <> 3 THEN
                UPDATE sc_maechq
                   SET status_cta = "3",
                       motivo = "09"
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta;

                SELECT COUNT(*)
                  INTO vexiste
                  FROM sc_ctabloqueo
                 WHERE cuenta = vcuenta;

                IF vexiste = 0 THEN
                    INSERT INTO sc_ctabloqueo VALUES (vcuenta, "09", "3");
                ELSE 
                    UPDATE sc_ctabloqueo
                       SET clave = "09",
                           opcion = "3"
                     WHERE cuenta = vcuenta;
                END IF

                INSERT INTO sc_ctabloqueohist VALUES (vcuenta, "09", "3");

                INSERT INTO sc_histbloq VALUES(
                    pempresa,vcuenta,"B","09",3,0.00,"informix",vfecha, 
                    current hour to fraction,"1111","B",vfolio," ");
            END IF
            
            LET vcargo = 0;

            INSERT INTO cargos VALUES(vcuenta,vimporte,vcargo,vdescripcion, '');
        END IF;
        
        -- // CARGO A CUENTAS RELACIONADAS DEL CLIENTE
        IF vimporte > vcargo THEN
            LET vimporte_cargo = vimporte - vcargo;
            
            SELECT num_cte
              INTO vnumcte
              FROM sc_maechq
             WHERE empresa = pempresa
               AND cuenta = vcuenta;
            
            FOREACH WITH HOLD
                SELECT cuenta, status_cta, motivo, sucursal,sdo_cong,sdo_retenido,saldo_sbc,saldo_actual
                  INTO vctacte, vstatus_cta, vmotivo, vsuc_cta,mSdoCong,mSdoRetenido,mSaldoSBC,mSdoActual
                  FROM sc_maechq
                 WHERE num_cte = vnumcte
                   AND cuenta <> vcuenta
                   AND status_cta IN('1','3','4')
                   
                 
				--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
                EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('',mSdoActual,mSdoRetenido,mSdoCong,mSaldoSBC,0.00,0.00,0.00,'F',2) INTO cCodRetConsSdo,cMensajeRetConsSdo,vdisponible; 

				   
                SELECT MAX(secuencia)
                  INTO vmaxsec
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vctacte
                   AND tipo_tarjeta = "T";

                SELECT num_tarjeta
                  INTO vtarjeta
                  FROM sc_tarjeta
                 WHERE empresa = pempresa
                   AND cuenta = vctacte
                   AND secuencia = vmaxsec;
                
                IF vstatus_cta = "3" THEN
                    SELECT "1" 
                      INTO vexiste_cta
                      FROM sc_ctabloqueo 
                     WHERE cuenta = vctacte;

                    IF vexiste_cta = "1" THEN      
                        SELECT opcion 
                          INTO vaceptab
                          FROM sc_ctabloqueo 
                         WHERE cuenta = vctacte;

                        IF vaceptab = 4 OR vaceptab = 3 THEN
                            CONTINUE FOREACH;
                        END IF;
                    ELSE
                        SELECT cargo 
                          INTO vacepcargo 
                          FROM sc_bloqueo
                         WHERE codigo = vmotivo;

                        IF vacepcargo = "N" THEN
                            CONTINUE FOREACH;
                        END IF;
                    END IF;
                END IF;
                
                IF vdisponible > 0.00 THEN
                    IF vdisponible >= vimporte_cargo THEN
                        LET vhora  = CURRENT HOUR TO FRACTION;
                        LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
                        LET vdesc = vdescripcion||' '||vcuenta;
                    
                        CALL cargo_ref(pempresa, vsuc_cta, "informix", "0270", "0270", vfolio, 
                                       vctacte, 0, vimporte_cargo, "01", vdesc, vtarjeta, "informix")
                        RETURNING vcodret, vtransacc, vfecha_cargo, vdispo, vcargo_cta;
                        
                        IF vcodret = '000' THEN
                            IF vimporte_cargo = vcargo_cta THEN
                                INSERT INTO cargos VALUES(vcuenta, vimporte_cargo, vcargo_cta, vdescripcion, vctacte);
                                EXIT FOREACH;
                            ELIF vimporte_cargo > vcargo_cta THEN
                                INSERT INTO cargos VALUES(vcuenta, vimporte_cargo, vcargo_cta, vdescripcion, vctacte);
                                LET vimporte_cargo = vimporte_cargo - vcargo_cta;
                                CONTINUE FOREACH;
                            END IF
                        ELSE
                            CONTINUE FOREACH;
                        END IF
                    ELSE
                        LET vhora  = CURRENT HOUR TO FRACTION;
                        LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
                        LET vdesc = vdescripcion||' '||vcuenta;
                    
                        CALL cargo_ref(pempresa, vsuc_cta, "informix", "0270", "0270", vfolio, 
                                       vctacte, 0, vdisponible, "01", vdesc, vtarjeta, "informix")
                        RETURNING vcodret, vtransacc, vfecha_cargo, vdispo, vcargo_cta;
                        
                        IF vcodret = '000' THEN
                            IF vimporte_cargo = vcargo_cta THEN
                                INSERT INTO cargos VALUES(vcuenta, vimporte_cargo, vcargo_cta, vdescripcion, vctacte);
                                EXIT FOREACH;
                            ELIF vimporte_cargo > vcargo_cta THEN
                                INSERT INTO cargos VALUES(vcuenta, vimporte_cargo, vcargo_cta, vdescripcion, vctacte);
                                LET vimporte_cargo = vimporte_cargo - vcargo_cta;
                                CONTINUE FOREACH;
                            END IF
                        ELSE
                            CONTINUE FOREACH;
                        END IF
                    END IF
                ELSE
                    CONTINUE FOREACH;
                END IF
            END FOREACH
        END IF
        
        LET vcontador = vcontador + 1;
            
        IF nComit = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        END IF;

    END FOREACH

    IF nComit = 1 THEN
        COMMIT WORK;
        LET vcuantos = vcontador;
    END IF;
    
    UPDATE bdicheq:sc_producto
       SET per_retiros = 'U 0'
     WHERE producto = '1100';
    
    TRUNCATE TABLE "informix".cuentas;
    
    UPDATE STATISTICS MEDIUM FOR TABLE cuentas;
    UPDATE STATISTICS MEDIUM FOR TABLE cargos;

    LET whora1         = CURRENT HOUR TO MINUTE;
    LET whora2         = whora1[1,2];
    LET whora3         = whora1[4,5];
    LET whora          = whora2||whora3;
    LET vfechades      = TO_CHAR(vfecha, '%Y/%m/%d');
    LET vdia           = vfechades[9,10];
    LET vmes           = vfechades[6,7];
    LET vanio          = vfechades[3,4];
    LET vfechadescarga = vdia||vmes||vanio;
    LET vnombre        = 'aplicados_'||vfechadescarga||'_'||whora||'.txt';

    LET vsql = "";
    -- LET vsql = 'echo "UNLOAD TO ./'||vnombre||' SELECT * FROM cargos" > ./cargos.sql';
    LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/'||vnombre||' SELECT * FROM cargos" > /resplogifx/conciliachq/cargos.sql';
    SYSTEM vsql;
    LET vsql = "";
	-- LET vsql = "dbaccess bdicheq ./cargos.sql";
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/cargos.sql";
    SYSTEM vsql;
    LET vsql = "";
    -- LET vsql = 'chmod 664 ./'||vnombre;
    LET vsql = '/usr/bin/chmod 664 /resplogifx/conciliachq/'||vnombre;
    SYSTEM vsql;
    LET vsql = "";

    END;

    RETURN vcodret, vcodret2, vcuantos;

END PROCEDURE
DOCUMENT
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 22-07-2025',
'MODIFICACION: Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.2';

CREATE PROCEDURE "informix".sp_obtieneinfoctechq (pCuenta CHAR(20),pCte CHAR(20),pTarjeta CHAR(20), pAnioMes CHAR(6)) 
RETURNING CHAR(5) AS retorno,
          CHAR(20) AS cuenta,
          CHAR(20) AS Cliente,
          CHAR(1) AS Estatus,
          CHAR(2) AS MotivoBloqueo,
          CHAR(2) AS OpcionBloqueo,
          CHAR(44) AS DescripProducto,
          MONEY(16,2) AS SaldoDisponible,
          MONEY(16,2) AS SaldoRetenido,
          MONEY(16,2) AS SaldoCongelado,
          MONEY(16,2) AS SaldoActual,
          CHAR(4) AS ProductoCuenta,
          MONEY(16,2) AS SaldoSBC,
          CHAR(18) AS CuentaClabe,
          SMALLINT AS DireccionEnvio,
          DATE AS FechaUltimoMovimiento,
          CHAR(20) AS NumeroTarjeta,
          CHAR(1) AS EstatusTarjeta,
          CHAR(1) AS TipoTarjeta,
          CHAR(4) AS ProductoTarjeta,
          DATE AS FechaAlta,
          SMALLINT AS DireccionEnviMaenoc,
          MONEY(16,2) AS SdoRetenidoMesAnterior,
          MONEY(16,2) AS SdoCongeladoMesAnterior,
          MONEY(16,2) AS SdoRetenidoActualHist,
          MONEY(16,2) AS SdoCongeladoActualHist,
          MONEY(16,2) AS SdoSobreGiroHist,
          DATE AS FechaFin,
          CHAR(200) AS NombreCteYOEmpresa,
          CHAR(13) AS RFC,
          CHAR(1) AS TipoPersona,
          DATE AS cFechaNacOConstitucion,
          CHAR(1) AS EsFirmante,
          MONEY(16,2) AS SBChistorico;
    
    DEFINE cCodRet 						CHAR(5);
    DEFINE iSqlErr						INTEGER;
    DEFINE cNumCte	 					CHAR(20);
    DEFINE cCuenta	 					CHAR(20);
    DEFINE cStatus	 					CHAR(1);
    DEFINE cMotivo	 					CHAR(2);
    DEFINE cOpcion	 					CHAR(2);
    DEFINE mSdoDisponible				MONEY(16,2);
    DEFINE mSdoRetenido					MONEY(16,2);
    DEFINE mSdoCongelado				MONEY(16,2);
    DEFINE mSdoActual					MONEY(16,2);
    DEFINE cProductoCta					CHAR(4);
    DEFINE mSBC							MONEY(16,2);
    DEFINE cClabe						CHAR(18);
    DEFINE sDireccionEnvio				SMALLINT;
    DEFINE dFechaUltimoMov				DATE;
    DEFINE cNumTarjeta					CHAR(20);
    DEFINE cStatusTarjeta				CHAR(1);
    DEFINE cTipoTarjeta					CHAR(1);
    DEFINE cProductoTarjeta				CHAR(4);
    DEFINE cNombreCteOEmpresa 			CHAR(200);
    DEFINE cRFC							CHAR(13);
    DEFINE cTipoPersona					CHAR(1);
    DEFINE cFechaNacOConstitucion 		DATE;
    DEFINE cFirmantes					CHAR(1);
    DEFINE cDescripcionProducto 		CHAR(44);
    DEFINE cFechaAltaCta				DATE;
    DEFINE cDireccioEnvioMaenoc 		CHAR(1);
    DEFINE mSdoRetenidoMesAnterior 		MONEY(16,2);
    DEFINE mSdoCongeladoMesAnterior 	MONEY(16,2);
    DEFINE mSdoRetenidoActualHistorico 	MONEY(16,2);
    DEFINE mSdoCongeladoActualHistorico MONEY(16,2);
    DEFINE mSdoSobreGiroHistorico 		MONEY(16,2);
    DEFINE dFechaFin					DATE;
    DEFINE dFechaHoy					DATE;
    DEFINE cFechaFormat					CHAR(6);
    DEFINE mSBCMaehis			 		MONEY(16,2);
    DEFINE vexiste                      SMALLINT;


    LET cCodRet 					= '00000';
    LET iSqlErr						= 0;
    LET cNumCte	 					= '';
    LET cCuenta	 					= '';
    LET cStatus	 					= '';
    LET cMotivo	 					= '';
    LET cOpcion	 					= '';
    LET mSdoDisponible				= 0.00;
    LET mSdoRetenido				= 0.00;
    LET mSdoCongelado				= 0.00;
    LET mSdoActual					= 0.00;
    LET cProductoCta				= '';
    LET mSBC						= 0.00;
    LET cClabe						= '';
    LET sDireccionEnvio				= 0;
    LET dFechaUltimoMov				= '01/01/1900';
    LET cNumTarjeta					= '';
    LET cStatusTarjeta				= '';
    LET cTipoTarjeta				= '';
    LET cProductoTarjeta			= '';
    LET cNombreCteOEmpresa 			= '';
    LET cRFC						= '';
    LET cTipoPersona				= '';
    LET cFechaNacOConstitucion 		= '01/01/1900';
    LET cFirmantes					= '';
    LET cDescripcionProducto 		= '';
    LET cFechaAltaCta				= '01/01/1900';
    LET cDireccioEnvioMaenoc 		= '';
    LET mSdoRetenidoMesAnterior 	= 0.00;
    LET mSdoCongeladoMesAnterior 	= 0.00;
    LET mSdoRetenidoActualHistorico = 0.00;
    LET mSdoCongeladoActualHistorico  = 0.00;
    LET mSdoSobreGiroHistorico 		= 0.00;
    LET dFechaFin					= '01/01/1900';
    LET dFechaHoy					= '01/01/1900';
    LET cFechaFormat				= '';
    LET mSBCMaehis					= 0.00;
    LET vexiste                     = 0;

    BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET cCodRet= iSqlErr;

            RETURN cCodRet,cCuenta,cNumCte,cStatus,cMotivo,cOpcion,cDescripcionProducto,NVL(mSdoDisponible,'0'),NVL(mSdoRetenido,'0'),
                   NVL(mSdoCongelado,'0'),NVL(mSdoActual,'0'),cProductoCta,mSBC,cClabe,sDireccionEnvio,dFechaUltimoMov,cNumTarjeta,
                   cStatusTarjeta,cTipoTarjeta,cProductoTarjeta,cFechaAltaCta,cDireccioEnvioMaenoc,NVL(mSdoRetenidoMesAnterior,'0'),
                   NVL(mSdoCongeladoMesAnterior,'0'),NVL(mSdoRetenidoActualHistorico,'0'),NVL(mSdoCongeladoActualHistorico,'0'),
                   NVL(mSdoSobreGiroHistorico,'0'),dFechaFin,cNombreCteOEmpresa,cRFC,cTipoPersona,cFechaNacOConstitucion,cFirmantes,NVL(mSBCMaehis,'0');
        END IF;
    END EXCEPTION;

   --SET DEBUG FILE TO "/home/c90402536/Traza/sp_obtieneinfoctechq_modif.out";
   --TRACE ON; 
    
    SET ISOLATION TO DIRTY READ;
    
    IF pCuenta = '' AND pCte = '' AND pTarjeta = '' THEN
        LET cCodRet = '00010';
        RETURN cCodRet,cCuenta,cNumCte,cStatus,cMotivo,cOpcion,cDescripcionProducto,NVL(mSdoDisponible,'0'),NVL(mSdoRetenido,'0'),
               NVL(mSdoCongelado,'0'),NVL(mSdoActual,'0'),cProductoCta,mSBC,cClabe,sDireccionEnvio,dFechaUltimoMov,cNumTarjeta,
               cStatusTarjeta,cTipoTarjeta,cProductoTarjeta,cFechaAltaCta,cDireccioEnvioMaenoc,NVL(mSdoRetenidoMesAnterior,'0'),
               NVL(mSdoCongeladoMesAnterior,'0'),NVL(mSdoRetenidoActualHistorico,'0'),NVL(mSdoCongeladoActualHistorico,'0'),
               NVL(mSdoSobreGiroHistorico,'0'),dFechaFin,cNombreCteOEmpresa,cRFC,cTipoPersona,cFechaNacOConstitucion,cFirmantes,NVL(mSBCMaehis,'0');
    END IF;

    IF pCuenta <> '' THEN
        LET pCte = '';
        LET pTarjeta = '';
    ELIF pCte <> '' THEN
        LET pCuenta = '';
        LET pTarjeta = '';
    ELIF pTarjeta <> '' THEN
        LET pCuenta = '';
        LET pCte = '';
    END IF;

    IF pCuenta <> '' THEN
        SELECT cuenta,num_cte
          INTO cCuenta,cNumCte 
          FROM bdicheq:sc_maechq 
         WHERE empresa = '001' 
           AND cuenta = pCuenta;
           
        IF cCuenta IS NULL OR cCuenta = '' THEN
            LET cCodRet = '00011';
            RETURN cCodRet,cCuenta,cNumCte,cStatus,cMotivo,cOpcion,cDescripcionProducto,NVL(mSdoDisponible,'0'),NVL(mSdoRetenido,'0'),
                   NVL(mSdoCongelado,'0'),NVL(mSdoActual,'0'),cProductoCta,mSBC,cClabe,sDireccionEnvio,dFechaUltimoMov,cNumTarjeta,
                   cStatusTarjeta,cTipoTarjeta,cProductoTarjeta,cFechaAltaCta,cDireccioEnvioMaenoc,NVL(mSdoRetenidoMesAnterior,'0'),
                   NVL(mSdoCongeladoMesAnterior,'0'),NVL(mSdoRetenidoActualHistorico,'0'),NVL(mSdoCongeladoActualHistorico,'0'),
                   NVL(mSdoSobreGiroHistorico,'0'),dFechaFin,cNombreCteOEmpresa,cRFC,cTipoPersona,cFechaNacOConstitucion,cFirmantes,NVL(mSBCMaehis,'0');
        END IF;
    END IF;
    
    IF pCte <> '' THEN
        SELECT numcte 
          INTO cNumCte 
          FROM bdinteg:si_cliente 
         WHERE numcte = pCte;
        
        IF cNumCte = '' OR cNumCte IS NULL THEN
            LET cCodRet = '00011';	
            RETURN cCodRet,cCuenta,cNumCte,cStatus,cMotivo,cOpcion,cDescripcionProducto,NVL(mSdoDisponible,'0'),NVL(mSdoRetenido,'0'),
                   NVL(mSdoCongelado,'0'),NVL(mSdoActual,'0'),cProductoCta,mSBC,cClabe,sDireccionEnvio,dFechaUltimoMov,cNumTarjeta,
                   cStatusTarjeta,cTipoTarjeta,cProductoTarjeta,cFechaAltaCta,cDireccioEnvioMaenoc,NVL(mSdoRetenidoMesAnterior,'0'),
                   NVL(mSdoCongeladoMesAnterior,'0'),NVL(mSdoRetenidoActualHistorico,'0'),NVL(mSdoCongeladoActualHistorico,'0'),
                   NVL(mSdoSobreGiroHistorico,'0'),dFechaFin,cNombreCteOEmpresa,cRFC,cTipoPersona,cFechaNacOConstitucion,cFirmantes,NVL(mSBCMaehis,'0');
        END IF;
    END IF;
    
    IF pTarjeta <> '' THEN
        SELECT cuenta,num_tarjeta 
          INTO cCuenta,cNumTarjeta 
          FROM bdicheq:sc_tarjeta 
         WHERE empresa = '001' 
           AND cuenta = cuenta 
           AND num_tarjeta = pTarjeta
           AND status_tar = 'A';

        LET pCuenta = cCuenta;

        IF cCuenta IS NULL OR cCuenta = '' THEN
            LET cCodRet = '00012';
            RETURN cCodRet,cCuenta,cNumCte,cStatus,cMotivo,cOpcion,cDescripcionProducto,NVL(mSdoDisponible,'0'),NVL(mSdoRetenido,'0'),
                   NVL(mSdoCongelado,'0'),NVL(mSdoActual,'0'),cProductoCta,mSBC,cClabe,sDireccionEnvio,dFechaUltimoMov,cNumTarjeta,
                   cStatusTarjeta,cTipoTarjeta,cProductoTarjeta,cFechaAltaCta,cDireccioEnvioMaenoc,NVL(mSdoRetenidoMesAnterior,'0'),
                   NVL(mSdoCongeladoMesAnterior,'0'),NVL(mSdoRetenidoActualHistorico,'0'),NVL(mSdoCongeladoActualHistorico,'0'),
                   NVL(mSdoSobreGiroHistorico,'0'),dFechaFin,cNombreCteOEmpresa,cRFC,cTipoPersona,cFechaNacOConstitucion,cFirmantes,NVL(mSBCMaehis,'0');
        END IF;
    END IF;

    SELECT fecha_hoy 
      INTO dFechaHoy
      FROM bdicheq:sc_fechas
     WHERE empresa = '001';

    LET cFechaFormat = YEAR(dFechaHoy)||LPAD(MONTH(dFechaHoy),2,'0');

    IF pCte <> '' AND pCuenta = '' THEN
        FOREACH WITH HOLD
            --RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DFTL 
            SELECT mae.cuenta,mae.num_cte,mae.status_cta,mae.motivo,mae.sdo_actual-(mae.sdo_retenido + mae.sdo_cong + mae.saldo_sbc), 	
                   mae.sdo_retenido,mae.sdo_cong,mae.sdo_actual,mae.producto,mae.imp_chq_sbc,mae.cuenta_clabe,mae.direcc_envio,mae.fec_ult_mov		
              INTO cCuenta,cNumCte,cStatus,cMotivo,mSdoDisponible,mSdoRetenido,mSdoCongelado,mSdoActual,cProductoCta,mSBC,
                   cClabe,sDireccionEnvio,dFechaUltimoMov
              FROM bdicheq:sc_maechq AS mae
             WHERE mae.empresa = '001'
               AND mae.num_cte = cNumCte

            RETURN cCodRet,cCuenta,cNumCte,cStatus,cMotivo,cOpcion,cDescripcionProducto,NVL(mSdoDisponible,'0'),NVL(mSdoRetenido,'0'),
                   NVL(mSdoCongelado,'0'),NVL(mSdoActual,'0'),cProductoCta,mSBC,cClabe,sDireccionEnvio,dFechaUltimoMov,cNumTarjeta,
                   cStatusTarjeta,cTipoTarjeta,cProductoTarjeta,cFechaAltaCta,cDireccioEnvioMaenoc,NVL(mSdoRetenidoMesAnterior,'0'),
                   NVL(mSdoCongeladoMesAnterior,'0'),NVL(mSdoRetenidoActualHistorico,'0'),NVL(mSdoCongeladoActualHistorico,'0'),
                   NVL(mSdoSobreGiroHistorico,'0'),dFechaFin,cNombreCteOEmpresa,cRFC,cTipoPersona,cFechaNacOConstitucion,cFirmantes,NVL(mSBCMaehis,'0') WITH RESUME;
        END FOREACH;
    ELSE
        --RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DFTL 
        SELECT mae.cuenta,mae.num_cte,mae.status_cta,mae.motivo,ctabloq.opcion,mae.sdo_actual-(mae.sdo_retenido + mae.sdo_cong + mae.saldo_sbc), 	
               mae.sdo_retenido,mae.sdo_cong,mae.sdo_actual,mae.producto,mae.imp_chq_sbc,mae.cuenta_clabe,mae.direcc_envio,mae.fec_ult_mov		
          INTO cCuenta,cNumCte,cStatus,cMotivo,cOpcion,mSdoDisponible,mSdoRetenido,mSdoCongelado,mSdoActual,cProductoCta,mSBC,
               cClabe,sDireccionEnvio,dFechaUltimoMov
          FROM bdicheq:sc_maechq AS mae,
         OUTER bdicheq:sc_ctabloqueo AS ctabloq 
         WHERE mae.empresa = '001'
           AND mae.cuenta = pCuenta
           AND mae.cuenta = ctabloq.cuenta;

        SELECT tarj.num_tarjeta,tarj.status_tar,tarj.tipo_tarjeta,tarj.prodtarjeta
          INTO cNumTarjeta,cStatusTarjeta,cTipoTarjeta,cProductoTarjeta
          FROM bdicheq:sc_tarjeta AS tarj
         WHERE tarj.empresa = '001'
           AND tarj.cuenta = cCuenta
           AND tarj.secuencia = (SELECT MAX(secuencia) 
                                   FROM bdicheq:sc_tarjeta AS tarj 
                                  WHERE tarj.empresa = '001' 
                                    AND tarj.cuenta = cCuenta 
                                    AND tarj.status_tar = 'A'
                                    AND tarj.tipo_tarjeta = 'T')
           AND tarj.status_tar = 'A'
           AND tarj.tipo_tarjeta = 'T';

        if pCte <> '' then
            -- // Falta agregar la informacion del salvo buen cobro historico.
            SELECT noc.fecha_alta,noc.envio_direcc,his.ret_mes_ant,his.cong_mes_ant,his.sdo_retenido,									
                   his.sdo_cong,his.impsbg_fin_mes + his.impccc_fin_mes AS sobregiro,his.fechafin + DAY(1) AS fechafin
              INTO cFechaAltaCta,cDireccioEnvioMaenoc,mSdoRetenidoMesAnterior,mSdoCongeladoMesAnterior,									
                   mSdoRetenidoActualHistorico,mSdoCongeladoActualHistorico,mSdoSobreGiroHistorico,dFechaFin
              FROM bdicheq:sc_maenoc AS noc 
              LEFT OUTER JOIN bdicheq:sc_maehis AS his ON (his.cuenta = noc.cuenta)
             WHERE noc.empresa = '001'
               AND noc.cuenta = cCuenta
               AND his.empresa = '001'
               AND his.cuenta = cCuenta
               AND his.aniomes = CASE WHEN pAnioMes = "" THEN 
                                    (Select Max(aniomes) From bdicheq:sc_maehis  Where cuenta = cCuenta)  
                                 ELSE pAnioMes END;
                             
            IF dFechaFin is null OR dFechaFin = '' THEN
                select fecha_alta 
                  into dFechaFin
                  from sc_maenoc 
                 where empresa = '001'
                   and cuenta = cCuenta;
            END IF;
        else		
            -- // Falta agregar la informacion del salvo buen cobro historico.
            SELECT fecha_alta,envio_direcc
              INTO cFechaAltaCta,cDireccioEnvioMaenoc
              FROM bdicheq:sc_maenoc
             WHERE empresa = '001'
               AND cuenta = cCuenta;

            SELECT nvl(ret_mes_ant,0), nvl(cong_mes_ant,0), nvl(sdo_retenido,0), nvl(sdo_cong, 0) , 
                   nvl(impsbg_fin_mes + impccc_fin_mes, 0) AS sobregiro, 
                   nvl(fechafin + DAY(1), '') AS fechafin
              INTO mSdoRetenidoMesAnterior,mSdoCongeladoMesAnterior,mSdoRetenidoActualHistorico,
                   mSdoCongeladoActualHistorico,mSdoSobreGiroHistorico,dFechaFin
              FROM bdicheq:sc_maehis 
             WHERE  empresa = '001'
               AND cuenta = cCuenta
               AND aniomes = CASE WHEN pAnioMes = "" THEN 
                                (Select Max(aniomes) From bdicheq:sc_maehis  Where cuenta = cCuenta)  
                             ELSE pAnioMes END;

            IF dFechaFin is null OR dFechaFin = '' THEN
                select fecha_alta 
                  into dFechaFin
                  from sc_maenoc 
                 where empresa = '001'
                   and cuenta = cCuenta;
            END IF;
        end if;		

        SELECT TRIM(cte.nombre1)||' '||TRIM(cte.nombre2)||' '||TRIM(cte.apell_paterno)||' '||TRIM(cte.apell_materno)||' '||TRIM(cte.razon_social),	TRIM(cte.rfc)
          INTO cNombreCteOEmpresa,cRFC
          FROM bdinteg:si_cliente AS cte
         WHERE cte.numcte = cNumCte;
       --- AND cte.fecha_alta =  cte.fecha_alta;

        SELECT producto||' '||nombre 
          INTO cDescripcionProducto
          FROM bdicheq:sc_producto
         WHERE producto = cProductoCta;

        -- // Datos si es un firmante
        SELECT 'S'
          INTO cFirmantes
          FROM bdicheq:sc_firmantes f
         WHERE f.cuenta = cCuenta 
           AND f.numcte = cNumCte;

        IF cFirmantes IS NULL  THEN
            LET cFirmantes = 'N';
        END IF;

        -- // Datos si es persona fisica o persona moral
        SELECT count(*) 
          into vexiste
          FROM bdinteg:si_ctepf 
         WHERE numcte = cNumCte;

        IF vexiste > 0 THEN
            --- IF EXISTS (SELECT 1 FROM bdinteg:si_ctepf WHERE numcte = cNumCte) THEN
            SELECT fecha_nac 
              INTO cFechaNacOConstitucion
              FROM bdinteg:si_ctepf
             WHERE numcte = cNumCte;

            LET cTipoPersona = 'F';
        ELSE
        --- ELIF EXISTS (SELECT 1 FROM bdinteg:si_ctepm WHERE numcte = cNumCte) THEN
            SELECT fecha_constitct 
              INTO cFechaNacOConstitucion
              FROM bdinteg:si_ctepm
             WHERE numcte = cNumCte;

            LET cTipoPersona = 'M';
        END IF;
        
        RETURN cCodRet,cCuenta,cNumCte,cStatus,cMotivo,cOpcion,cDescripcionProducto,NVL(mSdoDisponible,'0'),NVL(mSdoRetenido,'0'),
               NVL(mSdoCongelado,'0'),NVL(mSdoActual,'0'),cProductoCta,mSBC,cClabe,sDireccionEnvio,dFechaUltimoMov,cNumTarjeta,
               cStatusTarjeta,cTipoTarjeta,cProductoTarjeta,cFechaAltaCta,cDireccioEnvioMaenoc,NVL(mSdoRetenidoMesAnterior,'0'),
               NVL(mSdoCongeladoMesAnterior,'0'),NVL(mSdoRetenidoActualHistorico,'0'),NVL(mSdoCongeladoActualHistorico,'0'),
               NVL(mSdoSobreGiroHistorico,'0'),dFechaFin,cNombreCteOEmpresa,cRFC,cTipoPersona,cFechaNacOConstitucion,cFirmantes,NVL(mSBCMaehis,'0') WITH RESUME;

    END IF;

    END;
    
END PROCEDURE

Document
'DESCRIPCION: Obtiene la informacion correspondiente a un cliente, su cuenta, nombre, tarjeta, etc', 
'AUTOR: Antonio Bastidas',
'FECHA: 07/01/2010',
'VERSION: 20100107.1144',
'BD: BDICHEQ',
'DESCRIPCION MODIFICACION:',
'Se modificó °¡a que pinte en pantalla el dato de la fecha de apertura, la cual no se mostraba cuando',
'la informacion de la cuenta no se encuentra en la tabla sc_maehis',
'AUTOR: Hector Manuel Bojorquez Ruelas',
'FECHA: 09/Junio/2010',
'VERSION: 20100906.0920',
'BD: BDICHEQ',
'Modificacion 10 Ago 2010 JICS',
'Se modifico la busqueda en el maehis para las cuenta que no tuvieran estado de cuenta regresara la fecha de alta.',
'Modificado:            Donovan F. Torres Landeros',
'Ultima mpodificacion:  2025/06/20',
'Razon:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO: RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.2';

CREATE PROCEDURE "informix".cargo_retenido_cong(pempresa char(3))

RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE nComit           SMALLINT;
    DEFINE vcuantos         INTEGER;
    DEFINE vcargados        INTEGER;
    
    DEFINE vfecha_hoy       DATE;
    DEFINE vhora            CHAR(15);
    DEFINE vsql             CHAR(200);
    DEFINE vfolio           CHAR(20);
    DEFINE vcuenta          CHAR(20);
    DEFINE vstatus          CHAR(1);
    DEFINE vimporte         MONEY(18,2);
    DEFINE vsdo_cong        MONEY(18,2);
    DEFINE vmaxsec          SMALLINT;
    DEFINE vtarjeta         CHAR(16);
    DEFINE vsucursal        CHAR(4);
    DEFINE vexiste          INTEGER;
    DEFINE vmotivo          CHAR(2);
    DEFINE vproducto        CHAR(4);
    DEFINE vsdo_actual      MONEY(18,2);
    DEFINE vsdo_cong_res    MONEY(18,2);
    DEFINE vsdo_disponible  MONEY(18,2);
    DEFINE vreferencia      CHAR(40);
    DEFINE vimporte_ori     MONEY(18,2);
    DEFINE vfechadescarga   CHAR(8);
    DEFINE vnombre          VARCHAR(50);
    --RQM 09 704. Se agregan las siguientes variable DFTL 
    DEFINE vsdo_retenido    MONEY(18,2);
    DEFINE mSaldoSbc        MONEY(18,2);
    DEFINE cCodRetConsSdo       CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo   CHAR(50); --Mensaje de retorno de SP de consulta de saldo.

    BEGIN

    ON EXCEPTION SET sql_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/cargo_retenido_cong.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            IF nComit = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcuantos, vcargados;
        END IF;
    END EXCEPTION;

    ---  SET DEBUG FILE TO "/home/c90402536/Traza/cargo_retenido_cong_modif.out";
    ---  TRACE ON; 

    LET vcodret1  = "000";
    LET vcodret2  = "000";
    LET sql_err   = 0;
    LET isam_err  = 0;
    LET nComit    = 0;
    LET vcuantos  = -1;
    LET vcargados = -1;
    
    LET vfecha_hoy      = '';
    LET vhora           = '';
    LET vfolio          = '';
    LET vcuenta         = ''; 
    LET vimporte        = 0.00;
    LET vsdo_cong       = 0.00;
    LET vsucursal       = '';
    LET vstatus         = '';
    LET vmaxsec         = '';
    LET vtarjeta        = '';
    LET vexiste         = '';
    LET vmotivo         = '';
    LET vproducto       = '';
    LET vsdo_actual     = 0.00;
    LET vsdo_cong_res   = 0.00;
    LET vsdo_disponible = 0.00;
    LET vreferencia     = '';
    LET vimporte_ori    = 0.00;
    --RQM 09 704. Se agregan las siguientes variable DFTL 
    LET vsdo_retenido    = 0.00;
    LET mSaldoSbc        = 0.00;
    LET cCodRetConsSdo      = '00000';
    LET cMensajeRetConsSdo  = '';
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'cuentas_cong') THEN
        DROP TABLE "informix".cuentas_cong;
    END IF;
    
    CREATE TABLE "informix".cuentas_cong(
        cuenta      char(20) not null,
        importe     money(14,2) not null,
        referencia  char(40) )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctascong ON cuentas_cong(cuenta) USING BTREE;   
    
    LET vsql = '';
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/congeladas_ref_aplicar.unl DELIMITER ''","'' INSERT INTO cuentas_cong" > /resplogifx/conciliachq/ctasxret.sql';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasxret.sql';
    --- LET vsql = 'dbaccess bdicheq /resplogifx/conciliachq/ctasxret.sql';
    SYSTEM vsql;
    
    UPDATE STATISTICS MEDIUM FOR TABLE cuentas_cong;
    
    IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'cargos_cong') THEN
        DROP TABLE "informix".cargos_cong;
    END IF;
    
    CREATE TABLE "informix".cargos_cong(
        cuenta char(20) not null,
        importe money(14,2)not null,
        referencia  char(40),
        cargado money(14,2)not null )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_cgocong ON cargos_cong(cuenta) USING BTREE;            
    
    UPDATE STATISTICS MEDIUM FOR TABLE cargos_cong;

    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;

    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    FOREACH WITH HOLD
        SELECT cuenta, importe, referencia
          INTO vcuenta, vimporte, vreferencia
          FROM cuentas_cong
           
        IF vcuantos = -1 THEN
            LET nComit = 1;
            LET vcuantos = 0;
            LET vcargados = 0;
            BEGIN WORK;
        END IF;
        
        SELECT sdo_actual, sdo_cong, sdo_cong - vimporte, sdo_retenido, saldo_sbc,
               sucursal, status_cta, motivo, producto
          INTO vsdo_actual, vsdo_cong, vsdo_cong_res, vsdo_retenido, mSaldoSbc,
               vsucursal, vstatus, vmotivo, vproducto
          FROM sc_maechq
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
           
        SELECT MAX(secuencia)
          INTO vmaxsec
          FROM sc_tarjeta
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND tipo_tarjeta = 'T';

        SELECT num_tarjeta
          INTO vtarjeta
          FROM sc_tarjeta
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND secuencia = vmaxsec;
        
        IF vsdo_cong >= vimporte THEN
        
            INSERT INTO sc_movdia VALUES
            (0, vfolio, '9290', 'intercar', vfecha_hoy, vfecha_hoy, vhora, '0830', 
             vsucursal, vproducto, pempresa, vcuenta, null, 0, vimporte, 0.00, 0.00, 
             0.00, 0, null, null, vsdo_actual, '0830', vreferencia, 0, vtarjeta, null, "");
             
            IF vsdo_cong_res = 0.00 THEN 
                UPDATE sc_maechq
                   SET sdo_actual = sdo_actual - vimporte,
                       sdo_cong = 0.00,
                       status_cta = '1',
                       motivo = null
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta;
                   
                SELECT COUNT(*)
                  INTO vexiste
                  FROM sc_ctabloqueo
                 WHERE cuenta = vcuenta;

                IF vexiste <> 0 THEN
                    DELETE FROM sc_ctabloqueo
                     WHERE cuenta = vcuenta;
                END IF

                SELECT COUNT(*)
                  INTO vexiste
                  FROM sc_histbloq
                 WHERE cuenta = vcuenta
                   AND status_blo = 'B'
                   AND tipo_mov = 'B'
                   AND empresa = pempresa;

                IF vexiste <> 0 THEN
                    INSERT INTO sc_histbloq VALUES
                    (pempresa, vcuenta, 'D', '00', null, 0.00, 'informix', 
                     vfecha_hoy, current hour to fraction, 'infor', 'D', vfolio, ' ');
                END IF;
            ELSE 
                UPDATE sc_maechq
                   SET sdo_actual = sdo_actual - vimporte,
                       sdo_cong = vsdo_cong_res,
                       status_cta = '3',
                       motivo = '09'
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta;
                
                SELECT COUNT(*)
                  INTO vexiste
                  FROM sc_ctabloqueo
                 WHERE cuenta = vcuenta;
                 
                IF vexiste = 0 THEN 
                    INSERT INTO sc_ctabloqueo VALUES(vcuenta, '09', '1');
                ELSE 
                    UPDATE sc_ctabloqueo
                       SET clave = '09',
                           opcion = '1'
                     WHERE cuenta = vcuenta;
                END IF;
                
                INSERT INTO sc_ctabloqueohist VALUES (vcuenta, '09', '1');

                SELECT COUNT(*)
                  INTO vexiste
                  FROM sc_histbloq
                 WHERE cuenta = vcuenta
                   AND status_blo = 'B'
                   AND tipo_mov = 'B'
                   AND empresa = pempresa;

                IF vexiste <> 0 THEN
                    INSERT INTO sc_histbloq VALUES
                    (pempresa, vcuenta, 'D', '00', null, 0.00, 'informix', 
                     vfecha_hoy, current hour to fraction, 'infor', 'D', vfolio, ' ');
                END IF;
                 
                INSERT INTO sc_histbloq VALUES
                (pempresa, vcuenta, 'B', '09', 1, vsdo_cong_res, 'informix',
                 vfecha_hoy, current hour to fraction, 'infor', 'B', vfolio, " ");
            END IF;    
            
            INSERT INTO cargos_cong VALUES (vcuenta, vimporte, vreferencia, vimporte);
            
            LET vcargados = vcargados + 1;
        ELSE    
            EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', vsdo_actual, vsdo_retenido, null, mSaldoSbc, null, null, null, 'F', '3') 
            INTO cCodRetConsSdo, cMensajeRetConsSdo, vsdo_disponible;

            
            IF vsdo_disponible > 0.00 THEN 
            
                IF vsdo_disponible >= vimporte THEN
                
                    INSERT INTO sc_movdia VALUES
                    (0, vfolio, '9290', 'intercar', vfecha_hoy, vfecha_hoy, vhora, '0830', 
                     vsucursal, vproducto, pempresa, vcuenta, null, 0, vimporte, 0.00, 0.00, 
                     0.00, 0, null, null, vsdo_actual, '0830', vreferencia, 0, vtarjeta, null, "");

                    UPDATE sc_maechq
                       SET sdo_actual = sdo_actual - vimporte,
                           sdo_cong = 0.00,
                           status_cta = '1',
                           motivo = null
                     WHERE empresa = pempresa
                       AND cuenta = vcuenta;
                       
                    SELECT COUNT(*)
                      INTO vexiste
                      FROM sc_ctabloqueo
                     WHERE cuenta = vcuenta;

                    IF vexiste <> 0 THEN
                        DELETE FROM sc_ctabloqueo
                         WHERE cuenta = vcuenta;
                    END IF

                    SELECT COUNT(*)
                      INTO vexiste
                      FROM sc_histbloq
                     WHERE cuenta = vcuenta
                       AND status_blo = 'B'
                       AND tipo_mov = 'B'
                       AND empresa = pempresa;

                    IF vexiste <> 0 THEN
                        INSERT INTO sc_histbloq VALUES
                        (pempresa, vcuenta, 'D', '00', null, 0.00, 'informix', 
                         vfecha_hoy, current hour to fraction, 'infor', 'D', vfolio, ' ');
                    END IF;
                       
                    INSERT INTO cargos_cong VALUES (vcuenta, vimporte, vreferencia, vimporte);
                    
                    LET vcargados = vcargados + 1;
                ELSE 
                    LET vimporte_ori = vimporte;
                    LET vimporte = vsdo_disponible;
                
                    INSERT INTO sc_movdia VALUES
                    (0, vfolio, '9290', 'intercar', vfecha_hoy, vfecha_hoy, vhora, '0830', 
                     vsucursal, vproducto, pempresa, vcuenta, null, 0, vimporte, 0.00, 0.00, 
                     0.00, 0, null, null, vsdo_actual, '0830', vreferencia, 0, vtarjeta, null, "");

                
                    UPDATE sc_maechq
                       SET sdo_actual = sdo_actual - vimporte,
                           sdo_cong = 0.00,
                           status_cta = '3',
                           motivo = '09'
                     WHERE empresa = pempresa
                       AND cuenta = vcuenta;
                    
                    SELECT COUNT(*)
                      INTO vexiste
                      FROM sc_ctabloqueo
                     WHERE cuenta = vcuenta;
                     
                    IF vexiste = 0 THEN 
                        INSERT INTO sc_ctabloqueo VALUES(vcuenta, '09', '3');
                    ELSE 
                        UPDATE sc_ctabloqueo
                           SET clave = '09',
                               opcion = '3'
                         WHERE cuenta = vcuenta;
                    END IF;
                    
                    INSERT INTO sc_ctabloqueohist VALUES (vcuenta, '09', '3');

                    SELECT COUNT(*)
                      INTO vexiste
                      FROM sc_histbloq
                     WHERE cuenta = vcuenta
                       AND status_blo = 'B'
                       AND tipo_mov = 'B'
                       AND empresa = pempresa;

                    IF vexiste <> 0 THEN
                        INSERT INTO sc_histbloq VALUES
                        (pempresa, vcuenta, 'D', '00', null, 0.00, 'informix', 
                         vfecha_hoy, current hour to fraction, 'infor', 'D', vfolio, ' ');
                    END IF;
                     
                    INSERT INTO sc_histbloq VALUES
                    (pempresa, vcuenta, 'B', '09', 3, 0.00, 'informix',
                     vfecha_hoy, current hour to fraction, 'infor', 'B', vfolio, " ");
                
                    INSERT INTO cargos_cong VALUES (vcuenta, vimporte_ori, vreferencia, vimporte);
                    
                    LET vcargados = vcargados + 1;
                END IF;
            ELSE 
                INSERT INTO cargos_cong VALUES (vcuenta, vimporte, vreferencia, 0.00);
            END IF;
        END IF;    
        
        LET vcuantos = vcuantos + 1;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vcuenta         = ''; 
        LET vimporte        = 0.00;
        LET vsdo_cong       = 0.00;
        LET vsucursal       = '';
        LET vstatus         = '';
        LET vmaxsec         = '';
        LET vtarjeta        = '';
        LET vexiste         = '';
        LET vmotivo         = '';
        LET vproducto       = '';
        LET vsdo_actual     = 0.00;
        LET vsdo_cong_res   = 0.00;
        LET vsdo_disponible = 0.00;
        LET vreferencia     = '';
        LET vimporte_ori    = 0.00;
        
    END FOREACH;

    IF nComit = 1 THEN
        COMMIT WORK;
        LET nComit = 0;
    END IF;

    UPDATE STATISTICS MEDIUM FOR TABLE cargos_cong;

    LET vfechadescarga = TO_CHAR(vfecha_hoy, '%d%m%Y');
    LET vnombre = 'recup_cong_'||vfechadescarga||'.txt';

    LET vsql = "";
    LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/'||vnombre||' SELECT * FROM cargos_cong" > /resplogifx/conciliachq/cargos.sql';
    SYSTEM vsql;
    LET vsql = "";
    --- LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/cargos.sql";
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/cargos.sql";
    SYSTEM vsql;
    LET vsql = "";
    --- LET vsql = 'chmod 664 /resplogifx/conciliachq/'||vnombre;
    LET vsql = '/usr/bin/chmod 664 /resplogifx/conciliachq/'||vnombre;
    SYSTEM vsql;
    LET vsql = "";

    END;

    RETURN vcodret1, vcodret2, vcuantos, vcargados;

END PROCEDURE
DOCUMENT
"MODIFICADO:            Donovan F. Torres Landeros",
"ULTIMA MODIFICACION:   2025/12/20",
"RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)",
"                       a la operacion aritmetica para el nuevo calculo de",
"                       saldo disponible.",
"PROYECTO: RQM 09 704   Cobranza Automatica en cuentas de captacion",
"BD:                    bdicheq",
"VER:                   1.2";

create procedure "informix".cargon_ref_mx1(pempresa     char(3),
                                       psucursal    char(4),
                                       pusuario     char(8),
                                       ptransacc    char(4),
                                       ptransuc     char(4),
                                       pfolsuc      char(16),
                                       pcuenta      char(20),
                                       pcheque      integer,
                                       pmonto       money(14,2),
                                       pdivisa      char(2),
                                       preferencia  char(40),
                                       pnum_tarjeta char(16),
                                       pusuautoriza char(8))
returning char(5),char(4);

    define vfecha_hoy       date;
    define vfecha_proc      date;
    define vchrFechaValor   date;
    define vfechacalendario date;
    define vfecultmov       date;
    define vfechaccc        date;
    define vFechaDev        date;
    define vvaldoc          char(1);
    define vnaturaleza      char(1);
    define vval_chequeras   char(1);
    define vexiste          char(1);
    define vaceptab         char(1);
    define vstatus_cta      char(1);
    define vacepcargo       char(1);
    define vestado          char(1);
    define vcolat           char(1);
    define vsobregira       char(1);
    define vacepta_retpar   char(1);
    define vacepta_retiros  char(1);
    define vper_retiros     char(1);
    define vcancelacta      char(1);
    define vCobComChqExp    char(1);
    define vind_dispon      char(1);
    define vmoneda          char(2);
    define vmotivo          char(2);
    define vtipo_tran       char(2);
    define vsuccta          char(4);
    define vproducto        char(4);
    define vtrancancta      char(4);
    define vtrancomcan      char(4);
    define vtranretpar      char(4);
    define vtranret         char(4);
    define vtrandevobco     char(4);
    define vtrandevbcoop    char(4);
    define vComxChqExp      char(4);
    define vTrxCargoConcen  char(4);
    define vcodret          char(5);
    define vcodret2         char(5);
    define cCodRetIndicador	char(6);
    define vusuario         char(8); 
    define vctacol          char(20);
    define vdescerr         char(50);
    define vcodret3         char(50);
    define vsqlerr          integer;
    define visamerr         integer;
    define vcheque          integer;
    define vultche          integer;
    define vchqexp          smallint;
    define vtotcol          smallint;
    define vdiasret         smallint;
    define vdiasultret      smallint;
    define vChqExpMes       smallint;
    define vChqsLibCom      smallint;
    define vIntChqDev       smallint;
    define vChqDev          smallint;
    define vexistlimsbg     smallint;
    define vmonto           money(14,2);
    define vimpsbg          money(14,2);
    define vimpccc          money(14,2);
    define vabono_eje       money(14,2);
    define vsaldo_fin       money(14,2);
    define vsaldo_col       money(14,2);
    define vsdorestar       money(14,2);
    define vsdo_actual      money(14,2);
    define vdisponible      money(14,2);
    define vretenido        money(14,2);
    define vcongelado       money(14,2);
    define vlimccc          money(14,2);
    define vdispccc         money(14,2);
    define vreqccc          money(14,2);
    define vutilccc         money(14,2);
    define vsdodisp         money(14,2);
    define vlimite_sbg      money(14,2);
    define vimp_acum_sbg    money(14,2);
    define vtasa_aplicada   decimal(9,6);
    define vfecha_operacion date; 
	define vcodret1         CHAR(5);
	define vfechaHabil		DATE;
    define vnum_cte         char(20);
    define vchrFechaVal     char(10);
	--RQM 09 704. Se crea la siguiente variable.
	DEFINE cCodRet			CHAR(5);
	DEFINE cMensajeRet		CHAR(50);
	DEFINE mSdoSbc			MONEY(14,2);
	DEFINE mSaldoDispo		MONEY(14,2);
    
    let vfecha_hoy       = '';
    let vfecha_proc      = '';
    let vchrFechaValor   = '';
    let vfechacalendario = '';
    let vfecultmov       = '';
    let vfechaccc        = '';
    let vFechaDev        = '';
    let vvaldoc          = '';
    let vnaturaleza      = '';
    let vval_chequeras   = '';
    let vexiste          = '';
    let vaceptab         = '';
    let vstatus_cta      = '';
    let vacepcargo       = '';
    let vestado          = '';
    let vcolat           = '';
    let vsobregira       = '';
    let vacepta_retpar   = '';
    let vacepta_retiros  = '';
    let vper_retiros     = '';
    let vcancelacta      = '';
    let vCobComChqExp    = '';
    let vind_dispon      = '';
    let vmoneda          = '';
    let vmotivo          = '';
    let vtipo_tran       = '';
    let vsuccta          = '';
    let vproducto        = '';
    let vtrancancta      = '';
    let vtrancomcan      = '';
    let vtranretpar      = '';
    let vtranret         = '';
    let vtrandevobco     = '';
    let vtrandevbcoop    = '';
    let vComxChqExp      = '';
    let vTrxCargoConcen  = '';
    let vcodret          = '';
    let vcodret2         = '';
    let cCodRetIndicador = '';
    let vusuario         = '';
    let vctacol          = '';
    let vdescerr         = '';
    let vcodret3         = '';
    let vsqlerr          = 0;
    let visamerr         = 0;
    let vcheque          = 0;
    let vultche          = 0;
    let vchqexp          = 0;
    let vtotcol          = 0;
    let vdiasret         = 0;
    let vdiasultret      = 0;
    let vChqExpMes       = 0;
    let vChqsLibCom      = 0;
    let vIntChqDev       = 0;
    let vChqDev          = 0;
    let vexistlimsbg     = 0;
    let vmonto           = 0;
    let vimpsbg          = 0;
    let vimpccc          = 0;
    let vabono_eje       = 0;
    let vsaldo_fin       = 0;
    let vsaldo_col       = 0;
    let vsdorestar       = 0;
    let vsdo_actual      = 0;
    let vdisponible      = 0;
    let vretenido        = 0;
    let vcongelado       = 0;
    let vlimccc          = 0;
    let vdispccc         = 0;
    let vreqccc          = 0;
    let vutilccc         = 0;
    let vsdodisp         = 0;
    let vlimite_sbg      = 0;
    let vimp_acum_sbg    = 0;
    let vtasa_aplicada   = 0;
	let vfecha_operacion = TODAY;
    LET vcodret1         = "00000";
    let vnum_cte         = '';
    let vchrFechaVal     = '';
	--RQM 09 704. Se define la siguiente variable.
	LET cCodRet		= '00000';
	LET cMensajeRet	= '';
	LET mSdoSbc		= 0.0;
	LET mSaldoDispo = 0.0;
	
    begin

    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/tmp/cargon_ref.err";
        trace on;
        if vsqlerr <> 0  then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            return vcodret, vtranret;
        end if;
    end exception;
    
    --Set Debug File To '/home/c90301007/Traza/cargon_ref_mx1_MODF.out';
    --Trace On;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    let vreqccc          = 0;
    let vcodret          = '000';
    let vtranret         = ptransacc;
    let vtipo_tran       = '';
    let vind_dispon      = '0';
    let vtasa_aplicada   = 0.000000;
    let cCodRetIndicador = '000000';

    if ( ( psucursal is null or psucursal = " " ) or 
         ( pusuario  is null or pusuario  = " " ) or 
         ( ptransacc is null or ptransacc = " " ) or
         ( pcuenta   is null or pcuenta   = " " ) or 
         ( pfolsuc   is null or pfolsuc   = " " ) or 
         ( pcheque   is null or pcheque   < 0   ) or
         ( pmonto    is null or pmonto    = 0   ) ) then
        let vcodret = '110';
        return vcodret, vtranret;
    end if;
    
    if psucursal <> "5005" then -- SI LA SUCURSAL ES CORRESPONSALES NO VALIDA EL USUARIO
        select ejecutivo 
          into vusuario
          from bdinteg:si_ejecut
         where ejecutivo = pusuario;
   
        if vusuario <> pusuario or vusuario is null then
            let vcodret = "106";
            return vcodret,vtranret;
        end if
    end if

    select numero,naturaleza,valida_docto,sobregira, tipo_tran
      into vtranret,vnaturaleza,vvaldoc,vsobregira, vtipo_tran
      from bdinteg:si_transacc
     where empresa = pempresa 
       and numero = ptransacc
       and sistema = '01'
       and naturaleza = 'C';

    if ptransacc != vtranret or vtranret is null then
        let vcodret = "550";
        return vcodret,vtranret;
    end if;

    if vnaturaleza != "C" then
        let vcodret = "560";
        return vcodret,vtranret;
    end if;

    if vvaldoc = "S" and (pcheque is null or pcheque = 0) then
        let vcodret = "110";
        return vcodret,vtranret;
    end if;

    select valor 
      into vtranretpar
      from sc_param
     where empresa = pempresa 
       and codparam = "tranretpar";
   
    select valor
      into vTrxCargoConcen
      from sc_param
     where empresa = pempresa
       and codparam = 'TrxCgoCtaConcentrada';

    select fecha_hoy, ind_disponible 
      into vfechacalendario,  vind_dispon 
      from sc_fechas 
     where empresa = pempresa;
     
    if vind_dispon = '0' then
        let vcodret = "004";
        return vcodret,vtranret;
    end if;

    select fecha_proceso, status_cta, producto
      into vfecha_hoy, vstatus_cta, vproducto
      from sc_maechq
     where cuenta = pcuenta;
    
    if vproducto = "1300" or vproducto = "1400" or vproducto = "1700" or vproducto = "2700" then
        if (ptransacc = "3220" or ptransacc = "0260") and (pmonto is null or pmonto = 0) then
            let vcodret = "000";
            return vcodret,vtranret;
        end if;
    end if;  

    if vproducto in("1100", "2300") and ptransacc = "0223" then
        let vcodret = "962";
        return vcodret,vtranret;
    end if;
	
	if vproducto in("1100", "2300") and ptransacc = "0402" then
        let vcodret = "100";
        return vcodret,vtranret;
    end if;
  
   	if vproducto = '2300' and ptransacc = '0239' and ptransuc <> '0000' then
	   let vcodret = "962";
       return vcodret, vtranret;
    end if    
  
    if (vfecha_hoy is null or vstatus_cta = '4' or vstatus_cta = '8' or vstatus_cta = '5') then
        let vfecha_hoy = vfechacalendario;
    end if

    if (vfecha_hoy < vfechacalendario ) then
        let vcodret = "549";
        return  vcodret,vtranret;
    end if
  
    if vstatus_cta in ("2","6","7") then
        let vcodret = "200";
        return vcodret,vtranret;
    end if;
    
    -- OBTIENE LA FECHA SPEI PARA TRANSACCION 0274
    if ptransacc = '0274' then
		IF CURRENT HOUR TO fraction > '17:58:00' AND CURRENT HOUR TO fraction < '18:05:00' THEN
			CALL bdispei:"informix".sp_validafecha(pEmpresa, vfecha_hoy)
			RETURNING vcodret1, vfechaHabil;
			LET vchrFechaValor = to_char(vfechaHabil, '%m/%d/%Y');
		ELSE
			SELECT vchrvalor
		      INTO vchrFechaVal
			  FROM bdispei:tblparametros
			WHERE vchrcveparametro = 'FECHA_OPERACION';
            
            LET vchrFechaValor = SUBSTR(vchrFechaVal,4,2)||'/'||SUBSTR(vchrFechaVal,1,2)||'/'||SUBSTR(vchrFechaVal,7,4);
		END IF;
    else
        LET vchrFechaValor= vfecha_hoy;
	end if;
   
    -- VALIDACION PARA CUENTAS CON STATUS 8 - ART 61 LIC
    if ( vstatus_cta = '8' and ptransacc not in('0223','0320','0270', '0252','0402') ) then
        let vcodret = "200";
        return vcodret,vtranret;
    end if;
    
    foreach
		-- RQM 09 704. Se agrega el campos saldo_sbc para considerarlo en los SP.
		select sucursal,producto,ult_chq,colateral,status_cta,motivo,sdo_actual,lim_sbg_ccc,imp_sbg_ccc,
               fech_venc_ccc,sdo_retenido,sdo_cong,fec_ult_mov, chq_exp_mes, fecha_proceso, num_cte, saldo_sbc
          into vsuccta,vproducto,vultche,vcolat,vstatus_cta,vmotivo,vsdo_actual,vlimccc,vutilccc,
               vfechaccc,vretenido,vcongelado,vfecultmov, vChqExpMes, vfecha_proc, vnum_cte, mSdoSbc
          from sc_maechq
         where cuenta = pcuenta
         
        if vretenido < 0 then
            let vretenido = vretenido * -1;
        end if;
        
        if vcongelado < 0 then
            let vcongelado = vcongelado * -1;
        end if;
        
        if vsuccta is null then
            let vcodret = "100";
            return vcodret,vtranret;
        end if;

        if vstatus_cta in ("2","6","7") then
            let vcodret = "200";
            return vcodret,vtranret;
        elif vstatus_cta = '5' then
            SELECT cargo 
              INTO vacepcargo 
              FROM sc_bloqueo
             WHERE codigo = vmotivo;

            IF vacepcargo = "N" THEN
                LET vcodret = "300";
                RETURN vcodret,vtranret;
            END IF;
        else
            -- Verifica el tipo de bloqueo de la cuenta.....
            IF vstatus_cta = "3" THEN
                IF ptransacc <> '0830' AND ptransacc <> '0887' THEN
                    SELECT "1" 
                      INTO vexiste
                      FROM sc_ctabloqueo 
                     WHERE cuenta = pcuenta;

                    IF vexiste = "1" THEN      
                        SELECT opcion 
                          INTO vaceptab
                          FROM sc_ctabloqueo 
                         WHERE cuenta = pcuenta;

                        IF vaceptab = 4 OR vaceptab = 3 THEN
                            LET vcodret = "300";
                            RETURN vcodret,vtranret;
                        END IF;
                    ELSE
                        SELECT cargo 
                          INTO vacepcargo 
                          FROM sc_bloqueo
                         WHERE codigo = vmotivo;

                        IF vacepcargo = "N" THEN
                            LET vcodret = "300";
                            RETURN vcodret,vtranret;
                        END IF;
                    END IF;
                END IF;
            END IF;
        end if;
        
        select divisa,val_chequeras,acepta_retiros,per_retiros[1,1],per_retiros[3,5],acepta_retpar, cancelacta
          into vmoneda,vval_chequeras,vacepta_retiros,vper_retiros,vdiasret, vacepta_retpar,vcancelacta
          from sc_producto
         where empresa = pempresa 
           and producto = vproducto;

        if vmoneda != pdivisa then
            let vcodret = "951";
            return vcodret,vtranret;
        end if;

        if vacepta_retiros = "N" then
            select valor 
              into vtrancancta
              from sc_param
             where empresa = pempresa 
               and codparam = "trancancta";           

            select valor 
              into vtrancomcan
              from sc_param
             where empresa = pempresa 
               and codparam = "trancomcan";
      
            select valor 
              into vtrandevobco
              from sc_param
             where empresa = pempresa 
               and codparam = "trandevobco";
             
            select valor 
              into vtrandevbcoop
              from sc_param
             where empresa = pempresa 
               and codparam = "trandevbcoop";
             
            if ( ( ptransacc <> vtranretpar   or vtranretpar   is null ) and
                 ( ptransacc <> vtrancancta   or vtrancancta   is null ) and
                 ( ptransacc <> vtrandevobco  or vtrandevobco  is null ) and
                 ( ptransacc <> vtrandevbcoop or vtrandevbcoop is null ) and
                 ( ptransacc <> vtrancomcan   or vtrancomcan   is null ) ) then
                let vcodret = '957';
                return vcodret, vtranret;
            end if
        else
			-- RQM 09 704. Se agrega el SP calcular el saldo disponible tomando en cuenta el saldo_sbc.
			EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo
			('', vsdo_actual, vretenido, vcongelado, mSdoSbc, '', '', '', 'F', '2') INTO cCodRet, cMensajeRet, mSaldoDispo;
			
            IF vper_retiros = "U" AND pmonto <> mSaldoDispo then
                let vcodret = "420";
                return vcodret,vtranret;
            END IF
			-- RQM 09 704. Se agrega el resultado del saldo disponible que considerado el saldo sbc.
            if ( vstatus_cta = '8' and pmonto <> mSaldoDispo ) then
                let vcodret = "420";
                return vcodret,vtranret;
            end if
         
            let vdiasultret = vfecha_hoy - vfecultmov;
          
            if vdiasultret < 0 then
                let vdiasultret = 0;
            end if
           
            if vdiasultret < vdiasret then
                let vcodret = "957";
                return vcodret,vtranret;
            end if
        end if

        if vval_chequeras = "S" and vvaldoc = "S" then
            if pcheque > vultche then
                let vcodret = "520";
                return vcodret,vtranret;
            end if;
        end if;
      
        -- Inicia Validaciones de Chequeras Gpo PISA 270110 --
        IF vvaldoc = "S" then
            SELECT valor 
              INTO vCobComChqExp 
              FROM sc_param
             WHERE empresa = pempresa
               AND codparam = "cobcomchqexp";

            select valor
              into vChqsLibCom
              from bdicntchq:sq_param
             where cod_param = 1; 

            SELECT valor 
              INTO vComxChqExp 
              FROM sc_param
             WHERE empresa = pempresa
               AND codparam = "comxchqexp";
             
            SELECT valor 
              INTO vIntChqDev 
              FROM sc_param
             WHERE empresa = pempresa
               AND codparam = "intentoschqdev";

            IF vCobComChqExp NOT IN ('S','N') OR vCobComChqExp IS NULL THEN
                LET vcodret = "705";
                LET vtranret = ptransacc;
                RETURN vcodret,vtranret;
            END IF

            SELECT {+INDEX(sc_contch idx_contch2)}
                   numero,estado
              INTO vcheque,vestado
              FROM sc_contch
             WHERE empresa = pempresa
               AND cuenta = pcuenta
               AND numero = pcheque;

            IF dbinfo("sqlca.sqlerrd2") = 0 THEN
                LET vcodret = "500";
                LET vtranret = ptransacc;
                RETURN vcodret,vtranret;
            END IF
          
            IF ( vestado = 'P' ) then -- Pagado
                LET vcodret = '600';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            ELIF ( vestado = 'E' OR vestado = 'S' ) THEN -- Cheque No Activado
                LET vcodret = '500';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            ELIF ( vestado = 'R' ) THEN -- Revocado (Suspendido)
                LET vcodret = '700';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            ELIF ( vestado = 'J' ) THEN -- Bloqueado Judicial
                LET vcodret = '701';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            ELIF ( vestado = 'B' ) THEN -- Bloqueado Autoridades
                LET vcodret = '702';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            ELIF ( vestado = 'F' ) THEN -- Fraudulento
                LET vcodret = '703';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            ELIF ( vestado = 'C' ) THEN -- Cancelado
                LET vcodret = '704';
                LET vtranret = ptransacc;
                RETURN vcodret, vtranret;
            END IF;
        END IF; -- Termina Validaciones para chequeras

        let vdispccc = vlimccc - vutilccc;
      
        if vfechaccc < vfecha_hoy or vdispccc is null then
            let vdispccc = 0;
        end if
		
		-- RQM 09 704. Se agrega el SP calcular el saldo disponible tomando en cuenta el saldo_sbc.
		EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo
		('', vsdo_actual, vretenido, vcongelado, mSdoSbc, '', '', '', 'F', '2') INTO cCodRet, cMensajeRet, vdisponible;
		
		--let vdisponible = vsdo_actual - vretenido - vcongelado + vdispccc;
		let vdisponible = vdisponible + vdispccc;
		
        if vdisponible < 0 then
            let vdisponible = 0.00;
        end if;

        if vsdo_actual = pmonto and ptransacc = vtranretpar then
            let vcodret = "002";
            let vtranret = ptransacc;
            return vcodret,vtranret;
        end if

        if vsobregira = "S"  and pmonto > vdisponible then
            select count(*)
              into vexistlimsbg
              from sc_limite_sbg
             where cuenta = pcuenta;
             
            if ( vexistlimsbg > 0 ) then
                select limite_sbg, imp_acum_sbg
                  into vlimite_sbg, vimp_acum_sbg
                  from sc_limite_sbg
                 where cuenta = pcuenta;
                 
                if ( ( pmonto + vimp_acum_sbg ) > ( vdisponible + vlimite_sbg ) ) then
                    let vcodret = '400';
                    let vtranret = ptransacc;
                    return vcodret, vtranret;
                end if;
            end if;
            
			let vreqccc = pmonto - (vsdo_actual - vretenido - vcongelado);          
            
            if vdispccc >= vreqccc then
                let vimpccc = vreqccc;
                let vimpsbg = 0;
            else
                let vimpccc = vdispccc;
                let vimpsbg = vreqccc - vdispccc;
            end if
          
            if vimpccc > 0 then
                insert into sc_movdia values
                (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vchrFechaValor,current hour to fraction(3),"3240",vsuccta,vproducto,pempresa,pcuenta,"  ",
                 pcheque,vimpccc,vimpccc,0,0,0," ",vstatus_cta,vsdo_actual,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,"",vfecha_operacion);
				 
				EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,"3240",vimpccc,vfecha_hoy,"A")
				INTO cCodRetIndicador;
            end if
          
            if vimpsbg > 0 then
                insert into sc_movdia values
                (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vchrFechaValor,current hour to fraction(3),"3357",vsuccta,vproducto,pempresa,pcuenta,"  ",
                 pcheque,vimpsbg,vimpsbg,0,0,0," ",vstatus_cta,vsdo_actual,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,"",vfecha_operacion);
                 
                update sc_limite_sbg
                   set imp_acum_sbg = imp_acum_sbg + vimpsbg
                 where cuenta = pcuenta;
				 
				EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,"3357",vimpsbg,vfecha_hoy,"A")
				INTO cCodRetIndicador;
            end if               

            insert into sc_movdia values
            (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vchrFechaValor,current hour to fraction(3),ptransacc,vsuccta,vproducto,pempresa,pcuenta,"  ",
             pcheque,pmonto,0,0,0,0," ",vstatus_cta,vsdo_actual,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,"",vfecha_operacion);
           
            if vvaldoc = "S" then
                update {+INDEX(sc_contch idx_contch2)} sc_contch
                   set estado = "P",
                       fecha_alta = vfecha_hoy,
                       importe = pmonto
                 where empresa = pempresa 
                   and cuenta = pcuenta 
                   and numero = pcheque;
                 
                let vchqexp = 1;
            else
                let vchqexp = 0; 
            end if
            
            if (vtipo_tran in('00','30') and ptransacc <> vTrxCargoConcen) then
                update sc_maechq
                   set sdo_actual     = sdo_actual - vdisponible + vdispccc,
                       imp_sbg_ccc    = imp_sbg_ccc + vimpccc,
                       imp_chq_sbg    = imp_chq_sbg + vimpsbg,
                       imp_cgos_mes   = imp_cgos_mes + pmonto,
                       num_cgos_mes   = num_cgos_mes + 1,
                       imp_abonos_mes = imp_abonos_mes + vreqccc,
                       num_abonos_mes = num_abonos_mes + 1,
                       chq_exp_mes    = chq_exp_mes + vchqexp,
                       fec_ult_mov    = vfecha_hoy,
                       fecultret      = vfecha_hoy
                 where cuenta = pcuenta;
            else
                update sc_maechq
                   set sdo_actual     = sdo_actual - vdisponible + vdispccc,
                       imp_sbg_ccc    = imp_sbg_ccc + vimpccc,
                       imp_chq_sbg    = imp_chq_sbg + vimpsbg,
                       imp_cgos_mes   = imp_cgos_mes + pmonto,
                       num_cgos_mes   = num_cgos_mes + 1,
                       imp_abonos_mes = imp_abonos_mes + vreqccc,
                       num_abonos_mes = num_abonos_mes + 1,
                       chq_exp_mes    = chq_exp_mes + vchqexp,
                       fec_ult_mov    = vfecha_hoy
                 where cuenta = pcuenta;
            end if;
     
            -- Actualiza Cuentas Inactivas e Informadas (Status 4 y 5)
            IF ( vstatus_cta IN('4','5') AND vtipo_tran in('00','30') ) THEN
                UPDATE sc_maechq
                   SET status_cta = '1',
                       fecha_proceso = vfecha_hoy
                 WHERE cuenta = pcuenta;
            END IF;

            -- Valida Comision por Cheque Expedido Gpo PISA 270110 --
            IF vvaldoc = "S" then
                IF vCobComChqExp = "S" THEN
                    IF vChqsLibCom < vChqExpMes + 1 THEN
                        CALL cargo_comisiones(pempresa, pcuenta, vComxChqExp, pmonto, pfolsuc, psucursal, pusuario, pcheque, pdivisa, vfecha_hoy)
                        RETURNING vcodret;
                       
                        IF vcodret <> "000" THEN
                            LET vtranret = ptransacc;
                            RETURN vcodret,vtranret;
                        END IF
                    END IF
                END IF
            END IF

            let vtranret = ptransacc;
            let vcodret = "000";
			
			-- LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
			EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,ptransacc,pmonto,vfecha_hoy,"C")
			INTO cCodRetIndicador;
			
            return vcodret,vtranret;
        end if

        if pmonto > vdisponible then        
           
            if vvaldoc = "S" then
                -- Siempre se cobra la comision
                call gencomdev(pempresa,pcuenta,ptransacc,pcheque,pfolsuc,pmonto,"1",psucursal,pusuario,pdivisa)
                returning vcodret;

                IF vcodret = "000" THEN
                    LET vcodret = "400"; --Debe retornar forndos insuficientes
                END IF

                -- Valida Comision por Cheque Expedido Axl'10 270110 --
                IF vvaldoc = "S" then
                    IF vCobComChqExp = "S" THEN
                        IF vChqsLibCom < vChqExpMes + 1 THEN
                            CALL cargo_comisiones(pempresa, pcuenta, vComxChqExp, pmonto, pfolsuc, psucursal, pusuario, pcheque, pdivisa, vfecha_hoy)
                            RETURNING vcodret;
                            
                            IF vcodret <> "000" THEN
                                LET vtranret = ptransacc;
                                RETURN vcodret,vtranret;
                            END IF
                        END IF
                    END IF
                END IF
                      
                SELECT COUNT(*), MAX(fecha)
                  INTO vChqDev, vFechaDev
                  FROM sc_chequedev
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta
                   AND fecha <= vfecha_hoy
                   AND numerochq = pcheque;

                IF (vChqDev +1) > vIntChqDev THEN
                    LET vcodret = "400";
                    LET vtranret = ptransacc;
                    RETURN vcodret,vtranret;
                END IF

                IF vFechaDev = vfecha_hoy  THEN
                    LET vcodret = "400";
                    LET vtranret = ptransacc;
                    RETURN vcodret,vtranret;
                END IF
            end if

            IF vcodret = "000" THEN --Fondos Insuficientes
                let vcodret = "400";
            END IF
               
            let vtranret = ptransacc;
            return vcodret,vtranret;
            
        else
            
            insert into sc_movdia values
            (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vchrFechaValor,current hour to fraction(3),ptransacc,vsuccta,vproducto,pempresa,pcuenta," ",
             pcheque,pmonto,0,0,0,0," ",vstatus_cta,vsdo_actual,ptransuc,preferencia,vtasa_aplicada,pnum_tarjeta,pusuautoriza,"",vfecha_operacion);
             
            if ptransacc = '0223' then
                insert into sc_retirosefectivo values
                (vfecha_hoy, current hour to fraction(3), pfolsuc, ptransacc, vnum_cte, pcuenta, psucursal, vsuccta, pmonto);
            end if
           
            if vvaldoc = "S" then
                let vchqexp = 1;    
                    
                update {+INDEX(sc_contch idx_contch2)} sc_contch
                   set estado  = "P",
                       fecha_alta = vfecha_hoy,
                       importe = pmonto
                 where empresa = pempresa 
                   and cuenta = pcuenta 
                   and numero = pcheque;
            else
                let vchqexp = 0;
            end if
           
            if (vtipo_tran in('00','30') and ptransacc <> vTrxCargoConcen) then
                update sc_maechq
                   set sdo_actual     = sdo_actual - pmonto + vreqccc,
                       imp_sbg_ccc    = imp_sbg_ccc + vreqccc,
                       imp_cgos_mes   = imp_cgos_mes + pmonto,
                       num_cgos_mes   = num_cgos_mes + 1,
                       imp_abonos_mes = imp_abonos_mes + vreqccc,
                       num_abonos_mes = num_abonos_mes + 1,
                       fec_ult_mov    = vfecha_hoy,
                       chq_exp_mes    = chq_exp_mes + vchqexp,
                       fecultret      = vfecha_hoy
                 where cuenta = pcuenta;
            else
                update sc_maechq
                   set sdo_actual     = sdo_actual - pmonto + vreqccc,
                       imp_sbg_ccc    = imp_sbg_ccc + vreqccc,
                       imp_cgos_mes   = imp_cgos_mes + pmonto,
                       num_cgos_mes   = num_cgos_mes + 1,
                       imp_abonos_mes = imp_abonos_mes + vreqccc,
                       num_abonos_mes = num_abonos_mes + 1,
                       fec_ult_mov    = vfecha_hoy,
                       chq_exp_mes    = chq_exp_mes + vchqexp
                 where cuenta = pcuenta;
            end if;
            
            -- Actualiza Cuentas Inactivas e Informadas (Status 4 y 5)
            IF ( vstatus_cta IN('4','5') AND vtipo_tran in('00','30') ) THEN
                UPDATE sc_maechq
                   SET status_cta = '1',
                       fecha_proceso = vfecha_hoy
                 WHERE cuenta = pcuenta;
            END IF;

            -- Valida Comision por Cheque Expedido Axl'10 270110 --
            IF vvaldoc = "S" then
                IF vCobComChqExp = "S" THEN
                    IF vChqsLibCom < vChqExpMes + 1 THEN
                        CALL cargo_comisiones(pempresa, pcuenta, vComxChqExp, pmonto, pfolsuc, psucursal, pusuario, pcheque, pdivisa, vfecha_hoy)
                        RETURNING vcodret;
                    
                        IF vcodret <> "000" THEN
                            LET vtranret = ptransacc;
                            RETURN vcodret,vtranret;
                        END IF
                    END IF
                END IF
            END IF
            
        end if;

        -- Para acumular en sc_tarjeta
        update {+INDEX(sc_tarjeta ix_tarjeta3)} sc_tarjeta
           set disp_mes = nvl(disp_mes,0) + pmonto
         where empresa = pempresa
           and cuenta  = pcuenta
           and num_tarjeta = pnum_tarjeta;

        -- Cancela la cuenta al retiro del monto
        IF ( vper_retiros = 'U' AND vcancelacta = 'S' ) OR ( vstatus_cta  = '8' AND ptransacc IN('0223','0270', '0252', '0402') ) THEN
            UPDATE sc_maechq
               SET status_cta = '2', 
                   fec_cancelac = vfechacalendario, 
                   motivo = '02'
             WHERE cuenta = pcuenta;
        END IF
    end foreach
    
    let vcodret = "000";
    let vtranret = ptransacc;

	-- LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
	EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,ptransacc,pmonto,vfecha_hoy,"C")
	INTO cCodRetIndicador;
	
    return vcodret, vtranret;

    end;

end procedure
DOCUMENT
'MODIFICO :     Ezequiel Moreno Paredes',
'BD :     		bdicheq',
'FECHA :        02-07-2025',
'MODIFICACION : Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo llamado saldo_sbc',
'PROYECTO :     RQM 09 704 Cobranza Automatica en cuentas de captacion',
'VERSION :      1.0.1';

create procedure "informix".cierre_diario(pempresa char(3), pdias integer, pcuenta char(20))
returning char(5);
    
    -- ***********************************************************************
    -- * cierre_diario                                                       *
    -- * Version              1.0.0                                          *
    -- * Obejtivo:            Calcula saldos acumulados para cierre diario   *
    -- * Creado por:                                                         *
    -- * ModIFicado por:      Alejandro Rueda Sanchez                        *
    -- * Ultima Modificacion: Septiembre 2009                                *
    -- *                     Creacion de SPL                                 *
	-- * MODIFICO :		Ezequiel Moreno Paredes									*
	-- * FECHA : 		19-06-2025												*
	-- * MODIFICACION : Se modifica la formula de calculo de saldo disponible	*
	-- *                para considerar un nuevo campo llamado saldo_sbc	 	*
	-- * PROYECTO :     RQM 09 704 Cobranza Automatica en cuentas de captacion	*
	-- * VERSION :      1.0.1												 	*
	-- * BD: 			bdicheq													*
	-- *                     				                                 	*
    -- ***********************************************************************
    
    DEFINE global vgcuenta          char(20)        default " ";
    DEFINE global vgsucursal        char(4)         default " ";
    DEFINE global vgsdo_actual      money(14,2)     default 0;
    DEFINE global vgacum_sdo_pos    money(14,2)     default 0;
    DEFINE global vgdia_sdo_pos     smallint        default 0;
    DEFINE global vgproducto        char(4)         default " ";
    DEFINE global vgstatus_cta      char(1)         default " ";
    DEFINE global vgpaga_interes    char(1)         default " ";
    DEFINE global vgmto_pag_int     money(14,2)     default 0;
    DEFINE global vgtasa            char(8)         default " ";
    DEFINE global vgsobretasa       decimal(9,6)    default 0;
    DEFINE global vgtp_moneda       char(2)         default " ";
    DEFINE global vges_fisica       char(1)         default " ";
    DEFINE global vgexento_isr      char(1)         default " ";
    DEFINE global vgtipo_dias_calc  char(1)         default " ";
    DEFINE global vgpago_interes    char(1)         default " ";
    DEFINE global vgtipo_anio_calc  char(1)         default " ";
    DEFINE global vgfecha_hoy       date            default " ";
    DEFINE global vgfecha_pago      date            default " ";
    DEFINE global vgnum_cte         char(20)        default " ";
    DEFINE global vgdias_acum_int   integer         default 0;
    DEFINE global vgacum_sdo_int    money(14,2)     default 0;
    DEFINE global vgfecha_alta      date            default "";
    DEFINE GLOBAL vgTasaVar         CHAR(1)         DEFAULT "";
    DEFINE GLOBAL vgFechaProc       DATE	        DEFAULT "";
    DEFINE GLOBAL vgProdCreciente   CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgint_acum        DECIMAL(14,2)   DEFAULT 0;
    DEFINE GLOBAL vgsdo_disp        DECIMAL(14,2)   DEFAULT 0;
    DEFINE GLOBAL vgpri_hab_mes     DATE            DEFAULT " ";
    DEFINE GLOBAL vgpri_dia_mes     DATE            DEFAULT " ";
    DEFINE GLOBAL vgfecha_mod       DATE            DEFAULT " ";
    DEFINE GLOBAL vgsdo_retenido    DECIMAL(14,2)   DEFAULT 0;
    DEFINE GLOBAL vgsdo_cong        DECIMAL(14,2)   DEFAULT 0;
    DEFINE GLOBAL vginstrucc        CHAR(2)         DEFAULT " ";
    DEFINE GLOBAL vgcuentadep       CHAR(20)        DEFAULT " ";
	--RQM 09 704. Se agregan las variables para el retorno de consulta de saldo.
	DEFINE mSaldoSBC	   MONEY(14,2); 

    DEFINE vsdo_prom     money(14,2);
    DEFINE vcodret       char(5);
    DEFINE vcodret2      char(5);
    DEFINE vcodret3      char(40);
    DEFINE vsqlerr       integer;
    DEFINE vcobraisr     char(1);
    DEFINE vfecpagoint   datetime month to day;
    DEFINE vultpagoint   date;
    DEFINE isam_err      INTEGER;
    DEFINE error_info    CHAR(40);
    DEFINE vmotivo       CHAR(2);
    DEFINE vfechahora    CHAR(40);

    let vcodret  = "000";
    let vcodret2 = "000";
    let vcodret3 = "000";
    LET vfechahora = " ";
	--RQM 09 704. Se inicializan la variable para el retorno de consulta de saldo.
    LET mSaldoSBC		= 0.0;

    begin

    on exception 
        set vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "cierrediario.err";
        TRACE ON;
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            let vcodret2 = isam_err;
            let vcodret3 = error_info;
            LET vfechahora = CURRENT;
            return vcodret;
        end if;
    end exception;

    set isolation to dirty read;
    SET LOCK MODE TO WAIT 3;
	--RQM 09 704. Se agrega la variable mSaldoSBC para almacenar el dato de la columna saldo_sbc
    select mae.cuenta, mae.num_cte, mae.sucursal, mae.status_cta, mae.motivo, mae.producto, mae.fecha_proceso, 
           mae.sdo_actual, mae.sdo_cong, mae.sdo_retenido, mae.ultpagoint, mae.cobraisr, 
           noc.fecha_alta, noc.acum_sdo_pos, noc.dia_sdo_pos, noc.int_acum, noc.acum_sdo_int, noc.dias_acum_int,
           pro.paga_interes, pro.tasa, pro.sobretasa, pro.divisa, pro.tipo_dias_calc, pro.pago_interes, 
           pro.tipo_anio_calc, pro.mto_pag_int, pro.fecpagoint, pro.paga_dividendo,
           tip.es_fisica, tip.exento_isr, mae.saldo_sbc
      into vgcuenta, vgnum_cte, vgsucursal, vgstatus_cta, vmotivo, vgproducto, vgFechaProc,
           vgsdo_actual, vgsdo_cong, vgsdo_retenido, vultpagoint, vcobraisr, 
           vgfecha_alta, vgacum_sdo_pos, vgdia_sdo_pos, vgint_acum, vgacum_sdo_int, vgdias_acum_int, 
           vgpaga_interes, vgtasa, vgsobretasa, vgtp_moneda, vgtipo_dias_calc, vgpago_interes, 
           vgtipo_anio_calc, vgmto_pag_int, vfecpagoint, vgTasaVar, 
           vges_fisica, vgexento_isr, mSaldoSBC
      from sc_maechq mae,
           sc_maenoc noc,
           sc_producto pro,
           bdinteg:si_cliente cte,
           bdinteg:si_tipper tip
     where mae.empresa = pempresa 
	   and mae.cuenta = pcuenta
       and mae.status_cta not in("2","7","8")
       and noc.empresa = mae.empresa
       and noc.cuenta = mae.cuenta
       and pro.empresa = mae.empresa
       and pro.producto = mae.producto
       and cte.numcte = mae.num_cte
       and tip.tpo_persona = cte.tpo_persona;

    if vcobraisr <> "" then
        if vcobraisr = "S" then
            let vgexento_isr = "N";
        else
            let vgexento_isr = "S";
        end if
    end if

    if vgpaga_interes is null then
        let vgpaga_interes = "N";
    end if

    if vgmto_pag_int is null then
        let vgmto_pag_int = 0;
    end if

    /* VERIFICA SI ES EL PRIMER DIA DEL MES, INICIALIZA SALDO INTERES ACUMULADO */
    IF DAY(vgpri_hab_mes) = DAY(vgfecha_hoy) THEN
        LET vgdias_acum_int = pdias;
        LET vgint_acum = vgacum_sdo_int;
        LET vgacum_sdo_int = 0;
        LET vgdia_sdo_pos = vgdia_sdo_pos + pdias;
        LET vgacum_sdo_pos = vgacum_sdo_pos + vgsdo_actual * pdias;
    /* DIAS DEL ACUMULADO DE INTERESES */
    ELSE 
        LET vgdias_acum_int = vgdias_acum_int + pdias;
        LET vgdia_sdo_pos = vgdia_sdo_pos + pdias;
        LET vgacum_sdo_pos = vgacum_sdo_pos + vgsdo_actual * pdias;
    END IF

    /* SI LA CUENTA ES EMPRESARIAL ESPECIAL, TOMA EL SALDO DISPONIBLE COMPLETO */
	--RQM 09 704. Se agrega la variable mSaldoSBC para almacenar el dato de la columna saldo_sbc
    IF vmotivo = '99' THEN
        let vgsdo_disp = vgsdo_actual - vgsdo_retenido - mSaldoSBC;
    ELSE
        let vgsdo_disp = vgsdo_actual - vgsdo_retenido - vgsdo_cong - mSaldoSBC;
    END IF
    
    LET vsdo_prom = vgacum_sdo_pos/vgdia_sdo_pos;
    
    /* SI EL PROMEDIO CERO LE PASO EL SALDO ACTUAL SI SON CEROS ESTA BIEN MEL */
    IF vsdo_prom = 0 THEN
        LET vsdo_prom = vgsdo_actual;
    END IF;
    
    if vgpaga_interes = "S" then
        call calcula_int(pempresa,pdias,vsdo_prom) 
        returning vcodret;
        
        if vcodret <> "000" then
            return vcodret;
        end if
    end if
    
    update sc_maenoc
       set dia_sdo_pos   = vgdia_sdo_pos,
           acum_sdo_pos  = vgacum_sdo_pos,
           dias_acum_int = vgdias_acum_int,
           acum_sdo_int  = vgacum_sdo_int,
           int_acum      = vgint_acum
     where empresa = pempresa
       and cuenta = vgcuenta;
    
    return vcodret;
    
    end
    
end procedure;