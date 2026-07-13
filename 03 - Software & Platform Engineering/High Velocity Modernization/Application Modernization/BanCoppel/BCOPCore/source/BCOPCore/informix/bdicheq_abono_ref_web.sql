CREATE PROCEDURE "informix".abono_ref_web( pempresa     CHAR(3),
                                       psucursal    CHAR(4),
                                       pusuario     CHAR(8),
                                       ptransacc    CHAR(4),
                                       ptransuc     CHAR(4),
                                       pfolio_suc   CHAR(16),
                                       pcuenta      CHAR(20),
                                       pdocto       INTEGER,
                                       pmto_tot     MONEY(14,2),
                                       pmto_firme   MONEY(14,2),
                                       pmto_sbc     MONEY(14,2),
                                       pmto_rem     MONEY(14,2),
                                       pdias_ret    SMALLINT,
                                       pdivisa      CHAR(2),
                                       preferencia  CHAR(40),
                                       pnum_tarjeta CHAR(16),
                                       pusuautoriza CHAR(8) )
RETURNING CHAR(5);
    
    DEFINE vcodret              CHAR(5);
    DEFINE vcodret2             CHAR(5);
    DEFINE vcodret3             CHAR(50);
    DEFINE cCodRet3             CHAR(5);
    DEFINE cCodRet4             CHAR(5);
    DEFINE vsqlerr              INTEGER;
    DEFINE visamerr             INTEGER;
    DEFINE vdescerr             CHAR(50);
    DEFINE vsuccta              CHAR(4);
    DEFINE vexiste              CHAR(1);
    DEFINE vproducto            CHAR(4);
    DEFINE vgencom              CHAR(1);
    DEFINE vcobracom            CHAR(1);
    DEFINE vvaldoc              CHAR(1);
    DEFINE vnat                 CHAR(1);
    DEFINE vstatus              CHAR(1);
    DEFINE vaceptab             CHAR(1);
    DEFINE vmotivo              CHAR(2);
    DEFINE vmoneda              CHAR(2);
    DEFINE vmontotran           MONEY(14,2);
    DEFINE vsdo_actual          MONEY(14,2);
    DEFINE vimpsbg              MONEY(14,2);
    DEFINE vtotal_sbc           MONEY(14,2);
    DEFINE vdepinic             MONEY(14,2);
    DEFINE vfecha_hoy           DATE;
    DEFINE vfecha_prox          DATE;
    DEFINE vfecha_sistema       DATE;
    DEFINE vhora                DATETIME HOUR TO FRACTION(3);
    DEFINE vusuario             CHAR(8);
    DEFINE vtasa_aplicada       DECIMAL(9,6);
    DEFINE vmarca_ret           CHAR(1);
    DEFINE vdepinicial          MONEY(14,2);
    DEFINE vmtominape           MONEY(14,2);
    DEFINE vdepminini           MONEY(14,2);
    DEFINE vacepta_depositos    CHAR(1);
    DEFINE vper_depositos       CHAR(1);
    DEFINE vdiasultdep          SMALLINT;
    DEFINE vdiasdep             SMALLINT;
    DEFINE vfecultmov           DATE;
    DEFINE vfecultdep           DATE;
    DEFINE vfecultret           DATE;
    DEFINE vtranpagint          CHAR(4);
    DEFINE vtranusoccc          CHAR(4);
    DEFINE vtranusosbg          CHAR(4);
    DEFINE vtranabocol          CHAR(4);
    DEFINE vnumcte              CHAR(20);
    DEFINE vmto_apertura        MONEY(14,2);
    DEFINE vtransaccion         INTEGER;
    DEFINE vfech_spei           CHAR(10);
    DEFINE vfech_val            DATE;
    DEFINE vfecha_proc          DATE;
    DEFINE vref1				CHAR(20);
    DEFINE vestado_oper         CHAR(2);
    DEFINE vestado_cta          CHAR(2);
    DEFINE vmonto_acum          DECIMAL(18,2);
    DEFINE vmonto_perm          DECIMAL(16,2);
    DEFINE vinterpza            CHAR(1);
    DEFINE vaumentaret          CHAR(1);
    DEFINE vtpo_per_valida      CHAR(1);
    DEFINE vlimdepefec          DECIMAL(18,2);
    DEFINE vmtodepacum          DECIMAL(18,2);
    DEFINE vCteExcluido         CHAR(20);
    DEFINE vlimdepinterpza      DECIMAL(18,2);
    DEFINE vind_dispon          CHAR(1);
    DEFINE cCodRetIndicador		CHAR(6);
    DEFINE vidtransacc          CHAR(5);
    DEFINE vcodret_reg          CHAR(5);
    DEFINE vserial              INTEGER;
    DEFINE vprodtrnf            CHAR(4);
    DEFINE vvueltas             INTEGER;
    DEFINE vSQL                 CHAR(10);
    DEFINE cStatus              CHAR(1);
    DEFINE vexiste_cobro        INTEGER;
	DEFINE vfecha_operacion     DATE;
	DEFINE vTpoValidacion       CHAR(1);
    DEFINE iNoTrxsPerm          INTEGER;
    DEFINE iNoTrxsHechas        INTEGER;
    DEFINE vpri_dia_mes         DATE;
    DEFINE vLimRetDepSpei       DECIMAL(14,2);
    DEFINE vMtoAcumDepSpei      DECIMAL(14,2);
    DEFINE vMtoRetDepSpei       DECIMAL(14,2);
    DEFINE vCteNivel1           SMALLINT;
    DEFINE vEsFisica            CHAR(1);
	DEFINE vexceptuado			SMALLINT;
    
    DEFINE vExisLimProd         SMALLINT;
    DEFINE vTrxExentaLimProd    SMALLINT;
    DEFINE vhoramax             DATETIME HOUR TO MINUTE;
    DEFINE vprecio_udi          DECIMAL(14,6);  
    DEFINE vfecha_tpcambio      DATE;
    DEFINE vnomaxudis           INTEGER;
    DEFINE vmtoacumcta          DECIMAL(18,6);
    DEFINE vmonto_udi           DECIMAL(18,6);
    DEFINE vmtopagosudi         DECIMAL(18,6);   
    DEFINE vlim_cuenta          DECIMAL(18,6); 
    DEFINE vExisAcumCtaNvl2     SMALLINT;
    
    DEFINE iExiste              SMALLINT;
	DEFINE pfoliSuc				CHAR(16);
	DEFINE pPasoFoliSuc			CHAR(16);
	DEFINE pNumSerial 			INTEGER;
    DEFINE pLimiteFolio         CHAR(6);
	
   	--RQM 09 704 . Daniel Hernandez Garcia. Fecha modificacion: 28/02/2025
	--Variables de retorno para el sp maestro de retenciones.
	DEFINE cCodRetSpReten		CHAR(5);
	DEFINE cMensajeRetSpReten	CHAR(150);
	DEFINE iContTxPermRet       INTEGER;
    DEFINE cProceso             CHAR(50);
	
    
    LET vusuario         = USER;
    LET vcodret          = "00000";
    LET vcodret2         = "";
    LET vcodret3         = "";
    LET vsqlerr          = 0;
    LET visamerr         = 0;
    LET vdescerr         = '';
    LET vtransaccion     = 0;
    LET vmonto_acum      = 0;
    LET vmonto_perm      = 0;
    LET vinterpza        = '0';
    LET vaumentaret      = '0';
    LET vtpo_per_valida  = '';
    LET vlimdepefec      = 0.00;
    LET vmtodepacum      = 0.00;
    LET vCteExcluido     = '';
    LET vlimdepinterpza  = 0.00;
    LET vind_dispon      = '0';
    LET cCodRetIndicador = "000000";
    LET vidtransacc      = '';
    LET vcodret_reg      = '';
    LET vserial          = 0;
    LET vprodtrnf        = '8000';
    LET vvueltas         = 0; 
    LET vSQL             = '';
    LET cStatus          = '';
    LET vexiste_cobro    = 0;
	LET vfecha_operacion = TODAY;
    LET vTpoValidacion   = '';
    LET iNoTrxsPerm      = 0;
    LET iNoTrxsHechas    = 0;
    LET vpri_dia_mes     = '';
    LET vLimRetDepSpei   = 0.00;
    LET vMtoAcumDepSpei  = 0.00;
    LET vMtoRetDepSpei   = 0.00;
    LET vCteNivel1       = 0;
    LET vEsFisica        = '';
	LET vexceptuado 	 = 0;
    
    LET vExisLimProd      = 0;
    LET vTrxExentaLimProd = 0;
    LET vhoramax          = '';
    LET vprecio_udi       = 0.00; 
    LET vfecha_tpcambio   = '';
    LET vnomaxudis        = 0;
    LET vmtoacumcta       = 0.00;
    LET vmonto_udi        = 0.00;
    LET vmtopagosudi      = 0.00;
    LET vlim_cuenta       = 0.00;
    LET vExisAcumCtaNvl2  = 0;
    
    LET iExiste = 0;
	
	LET pfoliSuc 		  = '';
	LET pPasoFoliSuc      = '';
	LET pNumSerial		  = 0;
	LET pNumSerial		  = 0;
	
	--RQM 09 704 . Daniel Hernandez Garcia. Fecha modificacion: 28/02/2025
	--Variables de retorno para el sp maestro de retenciones.
	LET cCodRetSpReten		='00000';
	LET cMensajeRetSpReten	='';
	LET iContTxPermRet		=0;
    LET cProceso            = 'abono_ref_web';
    
    BEGIN

    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        --SET DEBUG FILE TO "/resplogifx/conciliachq/abono_ref.err";
        --TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
            IF SUBSTR(pcuenta, 1, 2) <> '80' THEN
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
            END IF;
            RETURN vcodret;
        END IF
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;
    

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
   -- SET DEBUG FILE TO "abono_ref.out";
    ---TRACE ON;

    -- // Obtiene fechas del sistema de cheques
    SELECT {+INDEX(sc_fechas idx_fechas1)} 
		   fecha_hoy, ind_disponible, pri_dia_mes
	  INTO vfecha_hoy, vind_dispon, vpri_dia_mes
	  FROM sc_fechas 
	 WHERE empresa = pempresa;
	 	 
	IF vind_dispon = '0' THEN
		LET vcodret = '00004';
		RETURN vcodret;
	END IF;
	
    -- // OBTIENE LA FECHA DE OPERACION SPEI PARA ABONOS, CANCELACIONES Y DEVOLUCIONES
    IF ptransacc IN('0273','0276','0277', '0446') THEN
        SELECT vchrvalor
          INTO vfech_spei
          FROM bdispei:tblparametros
         WHERE vchrcveparametro = 'FECHA_OPERACION'; 
         
        LET vfech_val = SUBSTR(vfech_spei,4,2)||'/'||SUBSTR(vfech_spei,1,2)||'/'||SUBSTR(vfech_spei,7,4);
	ELSE	
        LET vfech_val = vfecha_hoy;
	END IF;
    
    -- // PARA CUENTAS TRANSFER
    IF SUBSTR(pcuenta, 1, 2) = '80' THEN
        
        LET vcodret = '00999';
        RETURN vcodret;
        
        /* ###############################################################################################################################################
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            BEGIN WORK;
        END IF;
    
		-- // Valida la informacion de entrada
        IF psucursal  = "" OR pusuario   = "" OR 
           ptransacc  = "" OR pfolio_suc = "" OR 
           pcuenta    = "" OR pmto_tot   = 0  THEN
            LET vcodret = 110;
            RETURN vcodret;
        END IF;
        
        SELECT valor
          INTO vidtransacc
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = 'TranAbonoTransfer';
        
        IF ptransacc IN('0273','0276','0277') THEN
            IF ptransacc = '0273' THEN
				CALL sp_transfer_online_abonospei( vidtransacc, pcuenta, pfolio_suc, pmto_tot, pusuario, preferencia ) 
				RETURNING vcodret_reg, vserial;
			END IF;
			IF ptransacc IN('0276','0277') THEN
				SELECT valor
				  INTO vidtransacc
				  FROM sc_param
				 WHERE empresa = pempresa
				   AND codparam = 'TranCorSdoTransfer';
				IF ptransacc ='0276' THEN
					CALL sp_transfer_online_setsvabalance( vidtransacc, pCuenta, pfolio_suc, pUsuario, pmto_tot, preferencia, psucursal, 'REVERSO TRANSFER POR CANCELACION DE SPEI')
					RETURNING vcodret_reg, vserial;
				END IF;
				IF ptransacc ='0277' THEN
					CALL sp_transfer_online_setsvabalance( vidtransacc, pCuenta, pfolio_suc, pUsuario, pmto_tot, preferencia, psucursal, 'REVERSO TRANSFER POR DEVOLUCION DE SPEI')
					RETURNING vcodret_reg, vserial;
				END IF;
			END IF;
        ELSE
            CALL sp_transfer_online_abono( vidtransacc, pcuenta, pfolio_suc, pmto_tot, pusuario )
            RETURNING vcodret_reg, vserial;
        END IF;
        
        IF ( vcodret_reg is null OR vcodret_reg <> '00000' ) OR ( vserial is null OR vserial = 0 ) THEN
            LET vcodret = '999';
            IF vtransaccion = 1 THEN
                COMMIT WORK;
                BEGIN WORK;
            ELSE
                COMMIT WORK;
            END IF;
            RETURN vcodret;
        END IF;
        
        COMMIT WORK;
        
        LET vvueltas = 0;
        LET cStatus = 'N';
        
        WHILE cStatus IN('N','E') 
         --   SET ISOLATION TO DIRTY READ;
            
            SELECT status
              INTO cStatus
              FROM sc_transfer_online
             WHERE no_serial = vserial
               AND cuenta = pcuenta
               AND folio_suc = pfolio_suc
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
               AND folio_suc = pfolio_suc
               AND id_transacc = vidtransacc;
            
            -- // MANDA REVERSO AUTOMATICO A TRANSFER POR TIMEOUT
            SELECT valor
			  INTO vidtransacc
			  FROM sc_param
			 WHERE empresa = pempresa
			   AND codparam = 'TranCorSdoTransfer';
               
            CALL sp_transfer_online_setsvabalance( vidtransacc, pCuenta, pfolio_suc, pUsuario, pmto_tot, preferencia, psucursal, 'REVERSO AUTOMATICO TRANSFER DE SPEI')
			RETURNING vcodret_reg, vserial;
            
            IF ( vcodret_reg = '00000' AND vserial > 0 ) THEN
                LET vvueltas = 0;
                LET cStatus = 'N';
                
                WHILE cStatus IN('N','E') 
                 --   SET ISOLATION TO DIRTY READ;
                    
                    SELECT status
                      INTO cStatus
                      FROM sc_transfer_online
                     WHERE no_serial = vserial
                       AND cuenta = pcuenta
                       AND folio_suc = pfolio_suc
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
                       AND folio_suc = pfolio_suc
                       AND id_transacc = vidtransacc;
                END IF;
            END IF;
            
            LET vcodret = '24';
            
            IF vtransaccion = 1 THEN
                BEGIN WORK;
            END IF;
            
            RETURN vcodret;
            
        ELIF cStatus = 'X' THEN
        
            SELECT cod_ret
              INTO vcodret
              FROM sc_transfer_online
             WHERE no_serial = vserial
               AND cuenta = pcuenta
               AND folio_suc = pfolio_suc
               AND id_transacc = vidtransacc;
               
            IF ptransacc IN('0273','0276','0277') THEN
                LET vcodret = '880';
            END IF;
        
            IF vtransaccion = 1 THEN
                BEGIN WORK;
            END IF;
            
            RETURN vcodret;
        END IF;
        
        BEGIN WORK;
        
        SELECT valor
          INTO vprodtrnf
          FROM sc_param
         WHERE empresa = pempresa
           AND codparam = 'ProductoTransfer';
           
        SELECT status_cta
          INTO vstatus
          FROM bditransfer:tf_maecte
         WHERE cuenta_tf = pcuenta;
        
        LET vhora = CURRENT HOUR TO FRACTION;
        
		-- // Inserta el movimiento en la tabla de movimientos diarios...
        INSERT INTO sc_movdia VALUES
        ( 0, pfolio_suc, psucursal, pusuario, vfecha_hoy, vfech_val, vhora, ptransacc, psucursal, vprodtrnf, pempresa, pcuenta, 
          "", 0, pmto_tot, pmto_firme, pmto_sbc, pmto_rem, pdias_ret, "", vstatus, 0.00, ptransuc, preferencia, 0, '', '', '', vfecha_operacion );
        		
		IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
        END IF;
        ############################################################################################################################################### */
    
    -- // PARA CUENTAS DEL BANCO
    ELSE  
        
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            BEGIN WORK;
        END IF;
        
        LET vtasa_aplicada = 0;
        LET vgencom = 0;
        LET vcobracom = "0";
        LET vmto_apertura = 0;
        
		-- // Valida la informacion de entrada
        IF psucursal  = "" OR pusuario   = "" OR 
           ptransacc  = "" OR pfolio_suc = "" OR 
           pcuenta    = "" OR pmto_tot   = 0  OR 
           pmto_firme < 0  OR pmto_sbc   < 0  OR 
           pmto_rem   < 0  OR pdias_ret  < 0  THEN
            LET vcodret = '00110';
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN vcodret;
        END IF;
        
        -- // Obtiene fechas del sistema de cheques
        SELECT {+INDEX(sc_fechas idx_fechas1)} 
               fecha_hoy, prox_fecha, fecha_hoy, ind_disponible
          INTO vfecha_hoy, vfecha_prox, vfecha_sistema, vind_dispon
          FROM sc_fechas 
         WHERE empresa = pempresa;
         
        IF vind_dispon = '0' THEN
            LET vcodret = '00004';
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN vcodret;
        END IF;
         
		-- // Valida la suma de los montos
        LET vmontotran = pmto_firme + pmto_sbc + pmto_rem;
        
        IF vmontotran != pmto_tot OR pmto_tot = 0 THEN
            LET vcodret = "00420";
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN vcodret;
        END IF;
        
        IF ptransacc = '1193' or ptransacc = '1195' or ptransacc = '1196' or ptransacc = '1197' or ptransacc = '8017' THEN
            EXECUTE PROCEDURE  bdicheq:sp_validahorariopitdc() 
            INTO cCodRet3, cCodRet4;
            
            IF CAST(cCodRet3 AS INTEGER) <> 0 THEN
                LET vcodret  = cCodRet3;
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                RETURN vcodret;
            ELIF CAST(cCodRet4 AS INTEGER) <> 0 THEN
                LET vcodret = "00233";
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                RETURN vcodret;
            END IF;
        END IF;
		
		--Validacion que no permite deposito doble en ventanilla
		IF ptransacc = '0202' and ptransuc= '0204' THEN
		
		SELECT   MAX(num_serial)
				INTO pNumSerial
			FROM bdicheq:sc_movdia WHERE cuenta = pcuenta
			AND sucursal = psucursal
			AND usuario= pusuario
			AND monto_tot = pmto_tot;
		
			SELECT  folio_suc 
				INTO pfoliSuc
			FROM bdicheq:sc_movdia WHERE cuenta = pcuenta
			AND sucursal = psucursal
			AND usuario= pusuario
			AND monto_tot = pmto_tot
			AND num_serial = pNumSerial;
		
		LET pLimiteFolio = to_char(extend (SUBSTR(pfoliSuc,9,2) || ':' || SUBSTR(pfoliSuc,11,2) || ':' || SUBSTR(pfoliSuc,13,2) , hour to second) + INTERVAL (30) SECOND(2) TO SECOND,'%H%M%S');
		--LET pfoliSuc  = SUBSTR(pfoliSuc,9,6);
		LET pPasoFoliSuc = SUBSTR(pfolio_suc,9,6);
		
		IF TO_NUMBER(pPasoFoliSuc) < TO_NUMBER(pLimiteFolio) THEN
		LET vcodret = '00397';
           IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
           RETURN vcodret;
		
		END IF;
		
		IF pPasoFoliSuc - pfoliSuc = 1  THEN
		LET vcodret = '00397';
           IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
           RETURN vcodret;
		END IF;
		
	END IF;
		
        
        -- // Valida que exista la transaccion de abono
        SELECT naturaleza, valida_docto, dias_ret
          INTO vnat, vvaldoc, pdias_ret
          FROM bdinteg:si_transacc
         WHERE empresa = pempresa 
           AND numero = ptransacc
           AND sistema = '01'
           AND naturaleza = 'A';
        
        IF ( vnat IS NULL OR vnat != "A" ) THEN
            LET vcodret = "00552";
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN vcodret;
        END IF;
        
		-- // Valida la sucursal para transacciones de aclaraciones
        IF ptransacc IN('0340', '0345') THEN
           SELECT sucursal 
             INTO psucursal
             FROM bdinteg:si_sucursales
            WHERE sucursal = psucursal;
            
            IF psucursal is null or psucursal = "" THEN
                SELECT sucursal
                  INTO psucursal		  
                  FROM bdinteg:si_ejecut 
                 WHERE ejecutivo in(SELECT num_empleado 
                                      FROM bdiaclaracion:acl_aclaracion 
                                     WHERE folio_csuac = preferencia);
            END IF;
        END IF;	   
        
        -- // Obtiene referencia en Pagos del GDF
        IF ptransacc IN('1119', '1179', '1180') THEN
            SELECT {+INDEX(bdisac:sac_movimientos idxsac_mov2)} referencia1 
              INTO vref1
              FROM bdisac:sac_movimientos
             WHERE id_sucursal = psucursal 
               AND numcategoria = '08' 
               AND numconvenio = '001' 
               AND folio_suc = pfolio_suc;
            
            IF vref1 is null or vref1 = "" THEN
                LET preferencia = 'LINEA DE CAPTURA NO LOCALIZADA';
            ELSE
                LET preferencia = vref1;
            END IF;
        END IF;	
        
        -- // Inicializa los dias de retencion
        IF pdias_ret IS NULL THEN
            LET pdias_ret = 0;
        END IF;
        
        -- // Valida exista la cuenta
        SELECT mae.status_cta, mae.fecha_proceso, mae.producto, mae.sucursal, mae.num_cte, pro.tpper_valida
          INTO vstatus, vfecha_hoy, vproducto, vsuccta, vnumcte, vtpo_per_valida
          FROM sc_maechq mae,
               sc_producto pro
         WHERE mae.cuenta = pcuenta
           AND pro.producto = mae.producto;
        
        IF ( vstatus IS NULL OR ( vproducto = '2300' AND (ptransacc = '0202' OR ptransacc = '0318')) ) THEN
           LET vcodret = '00100';
           IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
           RETURN vcodret;
        END IF
        
        IF vproducto = '2800' AND (ptransacc = '0202' OR ptransacc = '0318') THEN
           LET vcodret = '00403';
           IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
           RETURN vcodret;
        END IF
        
        IF vstatus = '6' AND ptransacc = '0324' THEN
            LET vstatus = '1';
            LET vfecha_hoy = vfecha_sistema;
        END IF;

		-- // Valida que la cuenta no este cancelada
        IF vstatus in ("2","6","7","8") THEN
            LET vcodret = "00200";
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN vcodret;
        END IF
        
		-- // Valida cuentas inactivas
        IF ( vstatus IN("4","5") OR vfecha_hoy IS NULL ) THEN
            LET vfecha_hoy = vfecha_sistema;
        END IF
        
        -- // VERIFICA CARGO PARA PAGO DE CHEQUES PROPIOS
        IF ptransacc = '0310' THEN
            SELECT COUNT(*)
              INTO vexiste_cobro
              FROM sc_movdia
             WHERE folio_suc = pfolio_suc
               AND cancelad <> 'S'
               AND transacc = '3333';
               
            IF vexiste_cobro = 0 THEN
                LET vcodret = "00802";
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                RETURN vcodret;
            END IF;
        END IF;
        
        -- // VALIDACIONES DE LIMITES PARA CUENTAS NIVEL 2
		IF vproducto = '2900' THEN
			IF ptransacc NOT IN('0276', '0277') THEN
			SELECT COUNT(*)
			  INTO vExisLimProd
			  FROM sc_limites_producto
			 WHERE producto = vproducto;
			 
			IF vExisLimProd > 0 THEN
				SELECT COUNT(*)
				  INTO vTrxExentaLimProd
				  FROM sc_transacc_exentas_limprod
				 WHERE transacc = ptransacc;
				 
				IF vTrxExentaLimProd = 0 THEN
					-- // OBTIENE EL VALOR DE LA UDI
					SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
						   FIRST 1 MAX(hora_tpcambio) 
					  INTO vhoramax
					  FROM bdinteg:si_tpcambio 
					 WHERE empresa = pempresa 
					   AND divisa = '09'
					   AND fecha_tpcambio = vfecha_sistema;
					
					IF vhoramax is null OR vhoramax = '' THEN
						SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
							   FIRST 1 precio_venta
						  INTO vprecio_udi
						  FROM bdinteg:si_tpcambio
						 WHERE empresa = pempresa
						   AND divisa = '09'
						   AND fecha_tpcambio = vfecha_sistema;
					ELSE
						SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
							   FIRST 1 precio_venta
						  INTO vprecio_udi
						  FROM bdinteg:si_tpcambio
						 WHERE empresa = pempresa
						   AND divisa = '09'
						   AND fecha_tpcambio = vfecha_sistema
						   AND hora_tpcambio = vhoramax;
					END IF;
				   
					IF vprecio_udi is null OR vprecio_udi = '' THEN
						SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
							   FIRST 1 MAX(fecha_tpcambio) 
						  INTO vfecha_tpcambio
						  FROM bdinteg:si_tpcambio
						 WHERE empresa = pempresa 
						   AND divisa = '09'
						   AND fecha_tpcambio <= vfecha_sistema;
					   
						SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
							   FIRST 1 MAX(hora_tpcambio) 
						  INTO vhoramax
						  FROM bdinteg:si_tpcambio 
						 WHERE empresa = pempresa 
						   AND divisa = '09'
						   AND fecha_tpcambio = vfecha_tpcambio;
						
						IF vhoramax is null OR vhoramax = '' THEN
							SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
								   FIRST 1 precio_venta
							  INTO vprecio_udi
							  FROM bdinteg:si_tpcambio
							 WHERE empresa = pempresa
							   AND divisa = '09'
							   AND fecha_tpcambio = vfecha_tpcambio;
						ELSE
							SELECT {+INDEX(bdinteg:si_tpcambio idx_si_tpcambio2)} 
								   FIRST 1 precio_venta
							  INTO vprecio_udi
							  FROM bdinteg:si_tpcambio
							 WHERE empresa = pempresa
							   AND divisa = '09'
							   AND fecha_tpcambio = vfecha_tpcambio
							   AND hora_tpcambio = vhoramax;
						END IF;
					END IF;
					
					-- // OBTIENE EL VALOR MAXIMO DE UDIS 
					SELECT valor::int
					  INTO vnomaxudis
					  FROM sc_param
					 WHERE codparam = "UdisMaxDepCtaNvl2"
					   AND empresa = pempresa;
					   
					IF vnomaxudis is null THEN
						IF vtransaccion = 1 THEN
							ROLLBACK WORK;
							BEGIN WORK;
						ELSE
							ROLLBACK WORK;
						END IF;
						LET vcodret = '00151';
						RETURN vcodret;
					END IF;
					
					-- // OBTIENE EL ACUMULADO DE LA CUENTA
					SELECT monto_acum
					  INTO vmtoacumcta
					  FROM sc_acummesctanvl2
					 WHERE cuenta = pcuenta;
					 
					IF vmtoacumcta is null THEN
						LET vmtoacumcta = 0.00;
					END IF;
					
					-- // CONVIERTE MONTO DE LA TRANSACCION EN UDIS
					LET vmonto_udi = pmto_tot / vprecio_udi;
				
					-- // CONVIERTE ACUMULADO DE LA CUENTA EN UDIS
					LET vmtopagosudi = vmtoacumcta / vprecio_udi;
					
					-- // SUMA EL MONTO DE LA TRANSACCION AL ACUMULADO DE LA CUENTA
					LET vlim_cuenta = vmonto_udi + vmtopagosudi;
					
					-- // VALIDA QUE EL ACUMULADO DE LA CUENTA NO REBASE EL LIMITE PERMITIDO 
					IF ( vlim_cuenta > vnomaxudis ) THEN
						IF vtransaccion = 1 THEN
							ROLLBACK WORK;
							BEGIN WORK;
						ELSE
							ROLLBACK WORK;
						END IF;
						LET vcodret = '00151';
						RETURN vcodret;
					END IF; 
				END IF;
			END IF;
		END IF;
		END IF;
		
        -- // VALIDACION DE CONTROL DE DEPOSITOS EN EFECTIVO PARA PM
        IF ptransacc IN('0202','0325','0282','0318', '0482', '0491') AND vtpo_per_valida NOT IN('1','3') THEN
			SELECT COUNT(*)
              INTO vCteExcluido
              FROM sc_exentos_dep_efec
             WHERE num_cte = vnumcte;
             
            IF vCteExcluido = 0 THEN
				SELECT valor
                  INTO vlimdepefec
                  FROM sc_param
                 WHERE empresa = pempresa
                   AND codparam = 'LimDepEfectivoPM';

				IF pmto_tot > vlimdepefec THEN
					LET vcodret = '00152';
					IF vtransaccion = 1 THEN
						ROLLBACK WORK;
						BEGIN WORK;
					ELSE
						ROLLBACK WORK;
                    END IF;
                    RETURN vcodret;
                END IF;
			END IF;
		END IF;
        
        -- // VALIDACIONES PARA DEPOSITOS EN EECTIVO
        IF ptransacc IN('0202','0325','0282','0318', '0482', '0491') THEN
            
            -- // SOLICITUD DE EXCEPCION PARA OMITIR VALIDACIONES DE CONTROL DE DEPOSITOS EN EFECTIVO
            SELECT COUNT(*)
              INTO vCteExcluido
              FROM sc_exentos_dep_efec
             WHERE num_cte = vnumcte;
             
            IF vCteExcluido = 0 THEN
                
                -- // VALIDACIONES PARA DEPOSITOS EN EFECTIVO CORRESPONSALES
                IF ptransacc = '0282' AND vtpo_per_valida IN('1','3') THEN
                    SELECT valor
                      INTO vlimdepefec
                      FROM sc_param
                     WHERE empresa = pempresa
                       AND codparam = 'LimDepositosEfetivo';
                
                    SELECT SUM(monto)
                      INTO vmtodepacum
                      FROM sc_depositosefectivo
                     WHERE num_cte = vnumcte;
                     
                    IF vmtodepacum is null THEN
                        LET vmtodepacum = 0.00;
                    END IF;
                    
                    LET vmtodepacum = vmtodepacum + pmto_tot;
                    
                    IF vmtodepacum > vlimdepefec THEN
                        LET vcodret = '00397';
                        IF vtransaccion = 1 THEN
                            ROLLBACK WORK;
                            BEGIN WORK;
                        ELSE
                            ROLLBACK WORK;
                        END IF;
                        RETURN vcodret;
                    END IF;
                END IF;
                
                -- // VALIDACIONES PARA DEPOSITOS EN EFECTIVO EN VENTANILLA TRANSACCION 0202
                IF (ptransacc = '0202' OR ptransacc = '0318' OR ptransacc = '0482' OR ptransacc = '0491') AND vtpo_per_valida IN('1','3') AND vproducto <> '1100' THEN
                    
                    -- // VALIDA MONTO MENSUAL PERMITIDO POR CLIENTE 
                    SELECT valor
                      INTO vlimdepefec
                      FROM sc_param
                     WHERE empresa = pempresa
                       AND codparam = 'LimDepositosEfetivo';
                    
                    SELECT SUM(monto)
                      INTO vmtodepacum
                      FROM sc_depositosefectivo
                     WHERE num_cte = vnumcte;
                    
                    IF vmtodepacum is null THEN
                        LET vmtodepacum = 0.00;
                    END IF;
                    
                    LET vmtodepacum = vmtodepacum + pmto_tot;
                    
                    IF vmtodepacum > vlimdepefec THEN
                        LET vcodret = '00397';
                        IF vtransaccion = 1 THEN
                            ROLLBACK WORK;
                            BEGIN WORK;
                        ELSE
                            ROLLBACK WORK;
                        END IF;
                        RETURN vcodret;
                    END IF;
                    
                    -- // VALIDACIONES INTERESTADO
                    SELECT cve_estado
                      INTO vestado_oper
                      FROM bdinteg:si_ptf
                     WHERE id_ptf = psucursal 
                       AND tipo = 'S';

                    /* ##############################
                    SELECT estado
                      INTO vestado_oper
                      FROM bdinteg:si_sucursales
                     WHERE sucursal = psucursal;
                    ############################## */
                     
                    SELECT cve_estado
                      INTO vestado_cta
                      FROM bdinteg:si_ptf
                     WHERE id_ptf = vsuccta 
                       AND tipo = 'S';
                    
                    /* ##############################
                    SELECT estado
                      INTO vestado_cta
                      FROM bdinteg:si_sucursales
                     WHERE sucursal = vsuccta;
                    ############################## */
                     
                    IF vestado_oper <> vestado_cta THEN
                        SELECT valor 
                          INTO vTpoValidacion
                          FROM sc_param
                         WHERE empresa  = pempresa
                           AND codparam = 'LimDepositoInterEsta'; 
                           
                        IF vTpoValidacion is null OR vTpoValidacion = '' THEN
                            LET vTpoValidacion = 'O';
                        END IF;
                        
                        IF vTpoValidacion = 'S' THEN  
                            IF ( ( SELECT COUNT(*) FROM sc_limitedeposito WHERE sucursal = psucursal ) > 0 ) THEN  
                                SELECT monto
                                  INTO vmonto_perm
                                  FROM sc_limitedeposito 
                                 WHERE sucursal = psucursal;
                            ELSE 
                                SELECT monto
                                  INTO vmonto_perm
                                  FROM sc_limitedeposito 
                                 WHERE sucursal = '9999';
                            END IF; 
                        ELIF vTpoValidacion = 'G' THEN  
                            SELECT monto
                              INTO vmonto_perm
                              FROM sc_limitedeposito 
                             WHERE sucursal = '9999';
                        ELSE
                            SELECT valor
                              INTO vmonto_perm
                              FROM sc_param
                             WHERE empresa = pempresa
                               AND codparam = 'MontoDepInterPlaza';
                        END IF;
                            
                        SELECT SUM(monto_acum)
                          INTO vmonto_acum
                          FROM sc_depinterpza
                         WHERE num_cte = vnumcte
                           AND fecha >= vpri_dia_mes;
                           
                        IF vmonto_acum is null THEN
                            LET vmonto_acum = 0.00;
                        END IF;
                           
                        LET vmonto_acum = vmonto_acum + pmto_tot;
                           
                        IF vmonto_acum > vmonto_perm THEN
                            LET vcodret = '00371';
                            IF vtransaccion = 1 THEN
                                ROLLBACK WORK;
                                BEGIN WORK;
                            ELSE
                                ROLLBACK WORK;
                            END IF;
                            RETURN vcodret;
                        END IF;      
                        
                        LET vinterpza = '1';
                        LET vaumentaret = '0';
                    END IF;
                END IF;
                
                -- // VALIDACIONES PARA DEPOSITOS EN EFECTIVO EN VENTANILLA TRANSACCION 0325
                IF ptransacc = '0325' THEN 
                    
                    -- // VALIDA MONTO MENSUAL ACUMULADO POR CLIENTE 
                    SELECT valor
                      INTO vlimdepefec
                      FROM sc_param
                     WHERE empresa = pempresa
                       AND codparam = 'LimDepositosEfetivo';
                    
                    SELECT SUM(monto)
                      INTO vmtodepacum
                      FROM sc_depositosefectivo
                     WHERE num_cte = vnumcte;
                    
                    IF vmtodepacum is null THEN
                        LET vmtodepacum = 0.00;
                    END IF;
                    
                    LET vmtodepacum = vmtodepacum + pmto_tot;
                    
                    IF vmtodepacum > vlimdepefec THEN
                        LET vcodret = '00397';
                        IF vtransaccion = 1 THEN
                            ROLLBACK WORK;
                            BEGIN WORK;
                        ELSE
                            ROLLBACK WORK;
                        END IF;
                        RETURN vcodret;
                    END IF;
                    
                    -- // VALIDA QUE EL TIPO DE PERSONA SEA FISICA
					IF vtpo_per_valida IN ('2','4') THEN
                        LET vcodret = '00375';
                        IF vtransaccion = 1 THEN
                            ROLLBACK WORK;
                            BEGIN WORK;
                        ELSE
                            ROLLBACK WORK;
                        END IF;
                        RETURN vcodret;
                    END IF;
                    
                    -- // VALIDA QUE LA TRANSACCION SEA INTER-ESTADO
					SELECT cve_estado
                      INTO vestado_oper
                      FROM bdinteg:"informix".si_ptf
                     WHERE id_ptf = psucursal 
                       AND tipo = 'S';
                       
                    /* ##############################
                    SELECT estado
                      INTO vestado_oper
                      FROM bdinteg:si_sucursales
                     WHERE sucursal = psucursal;
                    ############################## */
                     
                    SELECT cve_estado
                      INTO vestado_cta
                      FROM bdinteg:"informix".si_ptf
                     WHERE id_ptf = vsuccta 
                       AND tipo = 'S';
                    
                    /* ##############################
                    SELECT estado
                      INTO vestado_cta
                      FROM bdinteg:si_sucursales
                     WHERE sucursal = vsuccta;
                    ############################## */
                    
                    IF vestado_oper = vestado_cta THEN
                        LET vcodret = '00374';
                        IF vtransaccion = 1 THEN
                            ROLLBACK WORK;
                            BEGIN WORK;
                        ELSE
                            ROLLBACK WORK;
                        END IF;
                        RETURN vcodret;
                    END IF;  
                    
                    -- // OBTIENE MONTO MINIMO PERMITIDO PARA UTILIZAR TRANSACCION 0325 
			        SELECT valor 
			          INTO vTpoValidacion
			          FROM sc_param
					 WHERE empresa  = pempresa
			           AND codparam = 'LimDepositoInterEsta'; 
                       
                    IF vTpoValidacion is null OR vTpoValidacion = '' THEN
                        LET vTpoValidacion = 'O';
                    END IF;
                    
                    IF vTpoValidacion = 'S' THEN  
                        IF ( ( SELECT COUNT(*) FROM sc_limitedeposito WHERE sucursal = psucursal ) > 0 ) THEN  
                            SELECT monto, num_transaccion
						      INTO vmonto_perm, iNoTrxsPerm
						      FROM sc_limitedeposito 
						   	 WHERE sucursal = psucursal;
					    ELSE 
                            SELECT monto, num_transaccion
						      INTO vmonto_perm, iNoTrxsPerm
						      FROM sc_limitedeposito 
						   	 WHERE sucursal = '9999';
						END IF; 
                    ELIF vTpoValidacion = 'G' THEN  
                        SELECT monto, num_transaccion
                          INTO vmonto_perm, iNoTrxsPerm
                          FROM sc_limitedeposito 
                         WHERE sucursal = '9999';
                    ELSE
                        SELECT valor
                          INTO vmonto_perm
                          FROM sc_param
                         WHERE empresa = pempresa
                           AND codparam = 'MontoDepInterPlaza';
                           
                        LET iNoTrxsPerm = 999999;
                    END IF;
                       
                    -- // OBTIENE ACUMULADO MENSUAL INTER-ESTADO POR CLIENTE
                    SELECT SUM(monto_acum)
                      INTO vmonto_acum
                      FROM sc_depinterpza
                     WHERE num_cte = vnumcte
                       AND fecha >= vpri_dia_mes;
                       
                    IF vmonto_acum is null THEN
                        LET vmonto_acum = 0.00;
                    END IF;
                       
                    LET vmonto_acum = vmonto_acum + pmto_tot;
                       
                    -- // VALIDA MONTO MINIMO PARA DEPOSITOS INTERESTADO
                    IF vmonto_acum < vmonto_perm THEN 
                        LET vcodret = '00374';
                        IF vtransaccion = 1 THEN
                            ROLLBACK WORK;
                            BEGIN WORK;
                        ELSE
                            ROLLBACK WORK;
                        END IF;
                        RETURN vcodret;
                    END IF;
                    
                    -- // OBTIENE MONTO LIMITE PERMITIDO PARA UTILIZAR LA TRANSACCION 0325
                    LET vlimdepinterpza = vlimdepefec - vmonto_perm;
                    
                    -- // OBTIENE TRANSACCIONES INTER-ESTADO REALIZADAS POR EL CLIENTE
                    SELECT COUNT(*), SUM(monto) 
                      INTO iNoTrxsHechas, vmtodepacum
                      FROM sc_depositosefectivo
                     WHERE num_cte = vnumcte
                       AND transacc = '0325';
                       
                    IF vmtodepacum is null THEN
                        LET vmtodepacum = 0.00;
                    END IF;
                     
                    LET iNoTrxsHechas = iNoTrxsHechas + 1;
                    LET vmtodepacum = vmtodepacum + pmto_tot;
                    
                    -- // VALIDA LIMITES PERMITIDOS PARA MONTOS Y NUMERO DE TRANSACCIONES
                    IF ( ( vmtodepacum > vlimdepinterpza ) OR ( iNoTrxsHechas > iNoTrxsPerm ) ) THEN
                        LET vcodret = '00397';
                        IF vtransaccion = 1 THEN
                            ROLLBACK WORK;
                            BEGIN WORK;
                        ELSE
                            ROLLBACK WORK;
                        END IF;
                        RETURN vcodret;
                    END IF;
                                        
                    LET vinterpza   = '1';
                    LET vaumentaret = '1';
                END IF;            
            END IF;
        END IF;
        
        FOREACH abono_cursor FOR
            SELECT mae.status_cta, mae.motivo, mae.sucursal, mae.producto, mae.sdo_actual, mae.marca_ret, 
                   mae.fec_ult_mov, mae.fecultdep, mae.fecultret, mae.imp_chq_sbg + mae.imp_sbg_ccc, mae.num_cte, mae.imp_chq_rem, 
                   mae.fecha_proceso, pro.divisa, pro.acepta_depositos, pro.mtominape, pro.per_depositos[1,1], pro.per_depositos[3,5]
              INTO vstatus, vmotivo, vsuccta, vproducto, vsdo_actual, vmarca_ret, 
                   vfecultmov, vfecultdep, vfecultret, vimpsbg, vnumcte, vmto_apertura, 
                   vfecha_proc, vmoneda, vacepta_depositos, vmtominape, vper_depositos, vdiasdep
              FROM sc_maechq mae,
                   sc_producto pro
             WHERE mae.cuenta = pcuenta
               AND pro.producto = mae.producto

            IF vmoneda != pdivisa THEN
                LET vcodret = "00951";
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                RETURN vcodret;
            END IF;
			

			IF vmarca_ret = "0" AND ptransacc IN("0273", "0446") AND vproducto <> "1100" THEN
				LET vmarca_ret = "1";
			END IF;
			
			-- // Para deposito inicial
			IF vmarca_ret = "0" THEN  
				IF vacepta_depositos ="N" AND vper_depositos = "U" THEN
					IF vmto_apertura <>  pmto_tot THEN
						LET vcodret = "00959";
						IF vtransaccion = 1 THEN
							ROLLBACK WORK;
							BEGIN WORK;
						ELSE
							ROLLBACK WORK;
						END IF;
						RETURN vcodret;
					END IF;
				END IF;

				LET vdepinicial = vsdo_actual + pmto_tot;

				-- // Valida para un monto de apertura, que no sea menor al indicado en el producto
				IF vdepinicial >= vmtominape THEN
					LET vmarca_ret = "1";
					IF vacepta_depositos ="N" AND vper_depositos = "U" THEN
						IF vmto_apertura <>  pmto_tot THEN
							LET vcodret = "00959";
							IF vtransaccion = 1 THEN
								ROLLBACK WORK;
								BEGIN WORK;
							ELSE
								ROLLBACK WORK;
							END IF;
							RETURN vcodret;
						END IF;
					ELSE 
						-- // Realiza Busqueda de Premio
						UPDATE sc_premio
						SET sucursal = psucursal,
							numcte = vnumcte,
							fecha_otorgo = vfecha_hoy,
							folio_operacion = pfolio_suc
						WHERE empresa = pempresa
						AND cuenta = pcuenta
						AND fecha_vigencia >= vfecha_hoy;
					END IF;
				ELSE 
					--//El deposito inicial es menor que el indicado en la definicion del producto
					LET vcodret = "00959";
					IF vtransaccion = 1 THEN
						ROLLBACK WORK;
						BEGIN WORK;
					ELSE
						ROLLBACK WORK;
					END IF;
					RETURN vcodret;
				END IF;
			ELSE
				IF vacepta_depositos = "N" THEN
					-- // Si aun no tienen saldo y por alguna razon el marca_ret > 0
					IF NOT(vper_depositos = "U" AND vsdo_actual = 0) THEN
						LET vcodret = "00956";
						IF vtransaccion = 1 THEN
							ROLLBACK WORK;
							BEGIN WORK;
						ELSE
							ROLLBACK WORK;
						END IF;
						RETURN vcodret;
					END IF;
				ELSE
					LET vdiasultdep = vfecha_hoy - vfecultdep;
					IF vdiasultdep < vdiasdep THEN
						LET vcodret = "00956";
						IF vtransaccion = 1 THEN
							ROLLBACK WORK;
							BEGIN WORK;
						ELSE
							ROLLBACK WORK;
						END IF;
						RETURN vcodret;
					END IF;
				END IF;
			END IF;

            
            -- // Para una cuenta bloqueada, verifica el tipo de bloqueo....
            IF vstatus = 3 THEN
                SELECT "1" 
                  INTO vexiste
                  FROM sc_ctabloqueo 
                 WHERE cuenta = pcuenta;

                IF vexiste = "1" THEN 
                    SELECT opcion 
                      INTO vaceptab
                      FROM sc_ctabloqueo 
                     WHERE cuenta = pcuenta;

                    IF vaceptab IN(2,4) THEN
                        LET vcodret = "00301";
                        IF vtransaccion = 1 THEN
                            ROLLBACK WORK;
                            BEGIN WORK;
                        ELSE
                            ROLLBACK WORK;
                        END IF;
                        RETURN vcodret;
                    END IF;
                ELSE
                    SELECT abono 
                      INTO vaceptab
                      FROM sc_bloqueo 
                     WHERE codigo = vmotivo;

                    IF vaceptab = "N" THEN
                        LET vcodret = "00301";
                        IF vtransaccion = 1 THEN
                            ROLLBACK WORK;
                            BEGIN WORK;
                        ELSE
                            ROLLBACK WORK;
                        END IF;
                        RETURN vcodret;
                    END IF;
                END IF;
            END IF;

            LET vhora = CURRENT HOUR TO FRACTION;

            SELECT {+INDEX(sc_transcomis idx_transcomis1)} 1 
              INTO vgencom
              FROM sc_transcomis
             WHERE empresa = pempresa 
               AND transacc = ptransacc;

            IF vgencom IS NULL THEN
                LET vgencom = 0;
                LET vcobracom = "0";
            END IF

            --- // JOM INICIO 
            IF (ptransuc = '0201' and pmto_sbc <= 0) THEN
                LET vcodret = "00401";
                IF vtransaccion = 1 THEN
                   ROLLBACK WORK;
                   BEGIN WORK;
                ELSE
                   ROLLBACK WORK;
                END IF;
                RETURN vcodret;
            END IF;
            --- // JOM FIN

            IF pmto_sbc > 0 THEN
                SELECT SUM(NVL(monto,0)) 
                  INTO vtotal_sbc			--MOHA
                  FROM sc_docret_sbc
                 WHERE empresa = pempresa 
                   AND cuenta = pcuenta 
                   AND folio_suc = pfolio_suc 
                   AND fecha_alta = vfecha_hoy 
                   AND siglas = "SC";

                IF NVL(vtotal_sbc, 0) <> pmto_sbc THEN
                    LET vcodret = "00401";
                    IF vtransaccion = 1 THEN
                       ROLLBACK WORK;
                       BEGIN WORK;
                    ELSE
                       ROLLBACK WORK;
                    END IF;
                    RETURN vcodret;
                END IF;
            END IF; 
            
            -- // OBTIENE EL TIPO DE PERSONA
            SELECT tpo.es_fisica
              INTO vEsFisica
              FROM bdinteg:si_cliente cte,
                   bdinteg:si_tipper tpo
             WHERE cte.numcte = vnumcte
               AND tpo.tpo_persona = cte.tpo_persona;
            
            -- // VALIDA SI SE RETIENEN LOS ABONOS SPEI
            IF ( ptransacc IN('0273','0446') AND vproducto NOT IN('1200','1600','1800','2200','2600','2700') ) THEN
                SELECT COUNT(*)
                  INTO vCteNivel1
                  FROM bdinteg:si_cliente_nivel
                 WHERE numcte = vnumcte;
				 
				SELECT COUNT(*)
                  INTO vexceptuado
                  FROM sc_spei_cta_sin_retencion
                 WHERE cuenta = pcuenta
				   AND estatus = 'A';
            
                IF vCteNivel1 = 0 THEN
					IF vexceptuado = 0 THEN
						IF vEsFisica = 'S' THEN
							SELECT valor
							  INTO vLimRetDepSpei
							  FROM sc_param
							 WHERE empresa = pempresa
							   AND codparam = 'MontoIniRetDepSpei';
							   
							SELECT SUM(monto_tot)
							  INTO vMtoAcumDepSpei
							  FROM sc_depositospei
							 WHERE fecha_hoy = vfecha_sistema
							   AND cuenta = pcuenta;
							   
							IF vMtoAcumDepSpei is null THEN
								LET vMtoAcumDepSpei = 0.00;
							END IF;
							
							LET vMtoAcumDepSpei = vMtoAcumDepSpei + pmto_tot;
							
							IF vMtoAcumDepSpei >= vLimRetDepSpei THEN
								LET vMtoRetDepSpei = pmto_tot;
							ELSE
								LET vMtoRetDepSpei = 0.00;
							END IF; 
							
							INSERT INTO sc_depositospei VALUES
							(vfecha_hoy, vfech_val, vhora, pfolio_suc, ptransacc, vnumcte, pcuenta, psucursal, pmto_tot, vMtoRetDepSpei, preferencia, '0');
						ELSE
							LET vMtoRetDepSpei = 0.00;
						END IF;
					ELSE
						LET vMtoRetDepSpei = 0.00;
					END IF;
				ELSE
					LET vMtoRetDepSpei = 0.00;
				END IF;
            ELSE
                LET vMtoRetDepSpei = 0.00;
            END IF;
            
            -- // Inserta el movimiento en la tabla de movimientos diarios...
            INSERT INTO sc_movdia VALUES
            (0, pfolio_suc, psucursal, pusuario, vfecha_hoy, vfech_val, vhora, ptransacc, vsuccta, vproducto, pempresa, pcuenta, "", 0, pmto_tot, pmto_firme,
             pmto_sbc, pmto_rem, pdias_ret, "", vstatus, vsdo_actual, ptransuc, preferencia, vtasa_aplicada, pnum_tarjeta, pusuautoriza, "", vfecha_operacion);
            
            -- // Actualiza el Maestro de Cheques...
            UPDATE sc_maechq
               SET fec_ult_mov = vfecha_hoy,
                   num_abonos_mes = num_abonos_mes + 1,
                   imp_abonos_mes = imp_abonos_mes + pmto_tot, -- Aqui se podria restar el SBC
                   sdo_actual = sdo_actual + pmto_tot - pmto_sbc,
                   imp_chq_sbc = imp_chq_sbc + pmto_sbc, -- Cambia a SBC No Utiliza Retenido
                   marca_ret = vmarca_ret,
                   fecultdep = vfecha_hoy,
                   sdo_retenido = sdo_retenido + vMtoRetDepSpei
             WHERE cuenta = pcuenta;
             
            -- // INSERTA EN TABLA PARA ENVIO DE MENSAJES (CUB)
            IF vEsFisica = 'S' THEN
                SELECT {+INDEX(sc_transacc_cub idx_transacc_cub_trx)}
                       COUNT(*) 
                  INTO iExiste
                  FROM sc_transacc_cub
                 WHERE transacc = ptransuc;
                 
                IF iExiste > 0 THEN
                    INSERT INTO sc_notif_cub_vent
                    (sucursal, transacc, transacc_suc, numcte, cuenta, num_tarjeta, monto_tot, folio_suc, estatus)
                    VALUES
                    (psucursal, ptransacc, ptransuc, vnumcte, pcuenta, pnum_tarjeta, pmto_tot, pfolio_suc, '0');
                END IF;
            END IF;
            
            -- // Actualiza Cuentas Informadas (Status 5)
            IF vstatus IN('4','5') THEN
                UPDATE sc_maechq
                   SET status_cta = '1',
                       fecha_proceso = vfecha_hoy
                 WHERE cuenta = pcuenta;
            END IF; 
            
            -- // Genera comision por transaccion
            IF vgencom = "1" THEN
                CALL gencomtran(pempresa, pcuenta, ptransacc, pmto_tot, pfolio_suc, psucursal, pusuario)
                RETURNING vcodret;
				LET vcodret = '00'||vcodret;
                LET vcobracom = "1";
            END IF
            
            -- // ACUMULA MONTO PARA CUENTAS NIVEL 2
			IF vproducto = '2900' THEN
				IF vExisLimProd > 0 AND vTrxExentaLimProd = 0 THEN
					SELECT COUNT(*)
					  INTO vExisAcumCtaNvl2
					  FROM sc_acummesctanvl2
					 WHERE cuenta = pcuenta;
					 
					IF vExisAcumCtaNvl2 = 0 THEN
						INSERT INTO sc_acummesctanvl2 VALUES(pcuenta, pmto_tot);
					ELSE
						UPDATE sc_acummesctanvl2
						   SET monto_acum = monto_acum + pmto_tot
						 WHERE cuenta = pcuenta;
					END IF;
				END IF;
			END IF;
            
            -- // SOLICITUD DE EXCEPCION PARA OMITIR VALIDACIONES DE CONTROL DE DEPOSITOS EN EFECTIVO
            IF ( ptransacc IN('0202','0325','0282', '0318', '0482', '0491') AND vproducto <> '1100' ) THEN 
                IF vCteExcluido = 0 THEN
                    IF vtpo_per_valida IN('1','3') THEN
                        INSERT INTO sc_depositosefectivo(fecha, hora, folio_suc, transacc, num_cte, cuenta, sucursal, suc_cuenta, monto)
                        VALUES(vfecha_hoy, vhora, pfolio_suc, ptransacc, vnumcte, pcuenta, psucursal, vsuccta, pmto_tot);
                    END IF;
                    
                    IF vinterpza = '1' THEN
                        IF vaumentaret = '0' THEN
                            INSERT INTO sc_depinterpza( fecha, num_cte, cuenta, monto_acum, monto_ret, liberado, sucursal, transacc, folio_suc  ) 
                            VALUES( vfecha_hoy, vnumcte, pcuenta, pmto_tot, 0, '0', psucursal, ptransacc, pfolio_suc );
                        ELIF vaumentaret = '1' THEN
                            INSERT INTO sc_depinterpza( fecha, num_cte, cuenta, monto_acum, monto_ret, liberado, sucursal, transacc, folio_suc  ) 
                            VALUES( vfecha_hoy, vnumcte, pcuenta, pmto_tot, pmto_tot, '0', psucursal, ptransacc, pfolio_suc );
                            
                            UPDATE sc_maechq
                               SET sdo_retenido = sdo_retenido + pmto_tot
                             WHERE cuenta = pcuenta;
                        END IF;
                    END IF;
                END IF; 
            END IF;
			
            --RQM 09 704 . Daniel Hernandez Garcia. Fecha modificacion: 28/02/2025 
			--Se realiza la validacion sobre las transacciones de pago de nomina para el llamado al sp de retenciones
			--Conteo para validacion de transaccion permitida
			SELECT COUNT(*) 
            INTO iContTxPermRet 
			FROM sc_transaccs_no_permitidas_reten_cob_auto 
			WHERE transaccion = ptransacc AND estatus = '1';

            --Validacion de transaccion
			IF(iContTxPermRet = 0) THEN
                --Se llama al SPL sp_retencion_cobranza_automatica para realizar la retencion.			
			    EXECUTE PROCEDURE sp_retencion_cobranza_automatica(vnumcte,pcuenta,pfolio_suc) INTO cCodRetSpReten,cMensajeRetSpReten;
                  --Validacion del codigo de retorno.
                IF (cCodRetSpReten NOT IN ('00000','00002','00003')) THEN
                    --Registro del tipo de error al ejecutar el SPL sp_retencion_cobranza_automatica.
                   INSERT INTO sc_bit_error_cobranza_automatica VALUES(0, cProceso, cCodRetSpReten, cMensajeRetSpReten, vnumcte, pcuenta, vfecha_operacion, vhora, pfolio_suc);
                END IF;
            END IF;
			
            -- // Obtiene los parametros generales
            SELECT valor 
              INTO vtranpagint
              FROM sc_param
             WHERE empresa = pempresa 
               AND codparam = "tranpagint";
            
            SELECT valor 
              INTO vtranusoccc
              FROM sc_param
             WHERE empresa = pempresa 
               AND codparam = "tranusoccc";

            SELECT valor 
              INTO vtranabocol
              FROM sc_param
             WHERE empresa = pempresa 
               AND codparam = "tranabocol";

            SELECT valor 
              INTO vtranusosbg
              FROM sc_param
             WHERE empresa = pempresa 
               AND codparam = "tranusosbg";

            -- // Cobra comisiones pendientes
            IF ptransacc = vtranpagint or ptransacc = vtranabocol OR
               ptransacc = vtranusoccc or ptransacc = vtranusosbg THEN
                LET vcobracom = "0";
            ELSE
                IF vimpsbg > 0 THEN
                    LET vcobracom = "1";
                END IF
                
                IF vcobracom = "0" THEN
                    SELECT UNIQUE 1 
                      INTO vcobracom
                      FROM sc_detcomis
                     WHERE empresa = pempresa 
                       AND cuenta = pcuenta 
                       AND estado_com = "P";

                    IF vcobracom IS NULL THEN
                       LET vcobracom = "0";
                    ELSE
                       LET vcobracom = "1";
                    END IF
                END IF
            END IF
            
            IF vcobracom = "1" THEN
                CALL cobintcomsbg(pempresa, pcuenta, pfolio_suc, pusuario, psucursal)
                RETURNING vcodret;
				LET vcodret = '00'||vcodret;
            END IF
            
        END FOREACH;
        
        IF vcodret = "00000" THEN
            IF vtransaccion = 1 THEN
                COMMIT WORK;
                BEGIN WORK;
            ELSE
                COMMIT WORK;
            END IF;
            
            -- // LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
            --- EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,ptransacc,pmto_tot,vfecha_hoy,"A")
            --- INTO cCodRetIndicador;
        ELSE
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
        END IF;
        
    END IF;
    
    RETURN vcodret;
    
    END;
    
END PROCEDURE;