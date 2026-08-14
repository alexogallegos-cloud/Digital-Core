CREATE PROCEDURE "informix".calcula_int_pba( pempresa CHAR(3), pdias INTEGER, psdo_prom MONEY(14,2) )
RETURNING CHAR(5);
     
    -- *********************************************************************************************************
    -- * calcula_int                                                                                           *
    -- * Version              1.0.1                                                                            *
    -- * Obejtivo:            Calcula, provisiona y capitaliza los intereses e isr de cualquier tipo de cuenta *
    -- * Creado por:                                                                                           *
    -- * ModIFicado por:      Alejandro Rueda Sanchez                                                          *
    -- * Ultima Modificacion: Febrero 2010                                                                     *
    -- *                                          Creación de SPL                                              *
    -- *********************************************************************************************************
    
    DEFINE GLOBAL vgcuenta         	CHAR(20)     	DEFAULT " ";
    DEFINE GLOBAL vgsucursal       	CHAR(4)      	DEFAULT " ";
    DEFINE GLOBAL vgsdo_actual     	MONEY(14,2)  	DEFAULT 0;
    DEFINE GLOBAL vgacum_sdo_pos   	MONEY(14,2)  	DEFAULT 0;
    DEFINE GLOBAL vgdia_sdo_pos    	SMALLINT     	DEFAULT 0;
    DEFINE GLOBAL vgproducto       	CHAR(4)      	DEFAULT " ";
    DEFINE GLOBAL vgstatus_cta     	CHAR(1)      	DEFAULT " ";
    DEFINE GLOBAL vgpaga_interes   	CHAR(1)      	DEFAULT " ";
    DEFINE GLOBAL vgmto_pag_int    	MONEY(14,2)  	DEFAULT 0;
    DEFINE GLOBAL vgtasa           	CHAR(8)      	DEFAULT " ";
    DEFINE GLOBAL vgsobretasa      	DECIMAL(9,6) 	DEFAULT 0;
    DEFINE GLOBAL vgtp_moneda      	CHAR(2)      	DEFAULT " ";
    DEFINE GLOBAL vges_fisica      	CHAR(1)      	DEFAULT " ";
    DEFINE GLOBAL vgexento_isr     	CHAR(1)      	DEFAULT " ";
    DEFINE GLOBAL vgtipo_dias_calc 	CHAR(1)      	DEFAULT " ";
    DEFINE GLOBAL vgpago_interes   	CHAR(1)      	DEFAULT " ";
    DEFINE GLOBAL vgtipo_anio_calc 	CHAR(1)      	DEFAULT " ";
    DEFINE GLOBAL vgusuario        	CHAR(8)      	DEFAULT " ";
    DEFINE GLOBAL vgprox_fecha     	DATE         	DEFAULT " ";
    DEFINE GLOBAL vgfecha_hoy      	DATE         	DEFAULT " ";
    DEFINE GLOBAL vgfecha_pago     	DATE         	DEFAULT " ";
    DEFINE GLOBAL vgpri_hab_mes    	DATE         	DEFAULT " ";
    DEFINE GLOBAL vgpri_dia_mes    	DATE         	DEFAULT " ";
    DEFINE GLOBAL vgult_hab_mes    	DATE         	DEFAULT " ";
    DEFINE GLOBAL vgult_dia_mes    	DATE         	DEFAULT " ";
    DEFINE GLOBAL vgtrans_pag_int  	CHAR(4)      	DEFAULT " ";
    DEFINE GLOBAL vgtransisr       	CHAR(4)      	DEFAULT " ";
    DEFINE GLOBAL vgtranrevprov    	CHAR(4)      	DEFAULT " ";
    DEFINE GLOBAL vgtranprov       	CHAR(4)      	DEFAULT " ";
    DEFINE GLOBAL vgtranabotrasp   	CHAR(4)      	DEFAULT " ";
    DEFINE GLOBAL vgnum_cte        	CHAR(20)     	DEFAULT " ";
    DEFINE GLOBAL vgprodaho        	CHAR(4)      	DEFAULT " ";
    DEFINE GLOBAL vgsdominaho      	MONEY(10,2)  	DEFAULT 0;
    DEFINE GLOBAL vgacum_sdo_int   	MONEY(14,2)  	DEFAULT 0;
    DEFINE GLOBAL vgdias_acum_int  	INTEGER      	DEFAULT 0;
    DEFINE GLOBAL vgfecha_alta     	DATE         	DEFAULT "";
    DEFINE GLOBAL vgTasaVar         CHAR(1)      	DEFAULT "";
    DEFINE GLOBAL vgProdCreciente  	CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgint_acum       	DECIMAL(14,2) 	DEFAULT 0;
    DEFINE GLOBAL vgsdo_disp       	DECIMAL(14,2) 	DEFAULT 0;
    DEFINE GLOBAL vgfecha_mod       DATE            DEFAULT " ";
    DEFINE GLOBAL vgnum_tarjeta     CHAR(20)     	DEFAULT " ";
    DEFINE GLOBAL vgsdo_retenido    DECIMAL(14,2)   DEFAULT 0;
    DEFINE GLOBAL vgsdo_cong        DECIMAL(14,2)   DEFAULT 0;
    DEFINE GLOBAL vginstrucc        CHAR(2)         DEFAULT " ";
    DEFINE GLOBAL vgcuentadep       CHAR(20)        DEFAULT " ";
    
    DEFINE vnumdias         		SMALLINT;
    DEFINE visr                     MONEY(14,2);
    DEFINE vsdocong    		        MONEY(14,2);
    DEFINE vimporte                 MONEY(14,2);
    DEFINE vtotint                  MONEY(14,2);
    DEFINE vtipper          		CHAR(1);
    DEFINE vvalor_tasa      		DECIMAL(9,6);
    DEFINE vvaltasa         		DECIMAL(9,6);
    DEFINE vtransuc         		CHAR(4);
    DEFINE vcero	           		SMALLINT;
    DEFINE vdias_prom       		INTEGER;
    DEFINE vhora            		DATETIME HOUR TO FRACTION;
    DEFINE vsecuencia       		INTEGER;
    DEFINE vmes                     CHAR(2);
    DEFINE vdia                     CHAR(2);
    DEFINE vsdodisp         		MONEY(14,2);
    DEFINE vmesdia                  CHAR(4);
    DEFINE vanio                    CHAR(4);
    DEFINE vhoraw           		CHAR(15);
    DEFINE vclave           		CHAR(5);
    DEFINE vaceptab         		CHAR(1);
    DEFINE vmotivo          		CHAR(2);
    DEFINE vfolio_suc       		CHAR(16);
    DEFINE vcodret          		CHAR(5);
    DEFINE vcodret2         		CHAR(5);
    DEFINE vcodret3         		CHAR(40);
    DEFINE vsqlerr          		INTEGER;
    DEFINE isam_err         		INTEGER;
    DEFINE error_info       		CHAR(40);
    DEFINE vsdo_promedio    		MONEY(14,2);
    DEFINE vmaxsec                  SMALLINT;
    DEFINE vintdia          		MONEY(14,2);
    DEFINE vmaxsecuencia            SMALLINT;
    DEFINE vdia_sdo_pos             SMALLINT;
    DEFINE IntCrece         		DECIMAL(14,2);
    DEFINE vfecha_mod               DATE;
    DEFINE vMtoMeta         		DECIMAL(14,2);
    DEFINE vint_acum        		DECIMAL(14,2);
    DEFINE vopcion                  CHAR(2);
    DEFINE vrangofecha              CHAR(1);
    DEFINE visr_prem                MONEY(14,2);
    DEFINE vfechahora               CHAR(40);
    DEFINE vcodret_trasp            CHAR(5);

    LET vcero         = 0;
    LET vtransuc      = "0000";
    LET vcodret       = "000";
    LET vcodret2      = "000";
    LET vcodret3      = "000";
    LET visr          = 0;
    LET visr_prem     = 0;
    LET vgcuenta      = vgcuenta;
    LET IntCrece      = 0;
    LET vMtoMeta      = 0;
    LET vopcion       = "";
    LET vfechahora    = " ";
    LET vcodret_trasp = '';
    LET vimporte      = 0.00;

    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "calcula_int.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            LET vfechahora = CURRENT;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "calcula_int.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    
    -- // ############################# //
    -- // # OBTIENE NUMERO DE TARJETA # //
    -- // ############################# //
    SELECT MAX(secuencia)
      INTO vmaxsec
      FROM sc_tarjeta
     WHERE numcte = vgnum_cte
       AND cuenta = vgcuenta
       AND tipo_tarjeta = "T";

    SELECT NVL(num_tarjeta, " ")
      INTO vgnum_tarjeta
      FROM sc_tarjeta
     WHERE numcte = vgnum_cte
       AND cuenta = vgcuenta
       AND secuencia = vmaxsec;
    
    -- // ##################### //
    -- // # FOLIO OPERACIONES # //
    -- // ##################### //
    LET vhora = current hour to fraction;
    LET vhoraw = vhora;
    LET vhoraw = vhoraw[1,2]||vhoraw[4,5]||vhoraw[7,8]||vhoraw[10,11];
    
    LET vfolio_suc = vgusuario||vhoraw[1,8];
    
    LET vdia = DAY(vgfecha_alta);
    LET vmes = MONTH(vgfecha_hoy);
    LET vanio = YEAR(vgfecha_hoy);
    
    -- // ################################################### //
    -- // # VERIFICA SI ES MESIVERSARIO DE LA FECHA DE ALTA # //
    -- // ################################################### //
    IF vgpago_interes = "V" THEN
        CALL calcula_fechapago(vgfecha_hoy, 0,vdia)
        RETURNING vcodret, vgfecha_pago, vnumdias;
        
        IF vdia = 1 THEN
            CALL monthadd(vgfecha_pago, 1)
            RETURNING vgfecha_pago;
        ELIF vdia = 2 AND vgfecha_hoy = '12'||'31'||YEAR(vgfecha_hoy) THEN
            CALL monthadd(vgfecha_pago, 1)
            RETURNING vgfecha_pago;
        ELSE
            LET vgfecha_pago = vgfecha_hoy + vnumdias;
        END IF;
        
        IF NOT(vdia > DAY(vgult_dia_mes) OR vdia < 1) THEN
            LET vgfecha_pago = vgfecha_pago - 1;
        END IF
    END IF
    
    LET vsecuencia = vanio||LPAD(trim(vmes),2,"0");
    
    -- // ########################## //
    -- // # ASIGNA TIPO DE PERSONA # //
    -- // ########################## //
    IF vges_fisica = "S" THEN
        LET vtipper = "F";
    ELSE
        LET vtipper = "M";
    END IF
    
    -- // ############################## //
    -- // # CALCULA LA TASA DE INTERES # //
    -- // ############################## //
    LET vsdo_promedio = vgacum_sdo_pos / vgdia_sdo_pos;
    
    IF vsdo_promedio >= vgmto_pag_int OR vgproducto = vgProdCreciente THEN
        SELECT rangofecha
          INTO vrangofecha
          FROM bdinteg:si_tiptasa
         WHERE tasa = vgtasa
           AND empresa = pempresa;
        
        IF vrangofecha <> "R" THEN
            CALL calc_tasa(pempresa, vgtasa, vtipper, psdo_prom)
            RETURNING vcodret, vvaltasa, IntCrece;
        
            IF vvaltasa IS NULL THEN
                LET vvaltasa = 0;
            END IF
        
            LET vvalor_tasa = vvaltasa / 100;
        ELIF vrangofecha = "R" THEN
            CALL calc_tasa(pempresa, vgtasa, vtipper, vsdo_promedio)
            RETURNING vcodret, vvaltasa, IntCrece;
        
            IF vvaltasa IS NULL THEN
                LET vvaltasa = 0;
            END IF
        
            LET vvalor_tasa = vvaltasa / 100;
        END IF
    ELSE
        LET vvaltasa = 0;
        LET vvalor_tasa = 0;
    END IF
    
    -- // ########################### //
    -- // # ASIGNA NO. DIAS DEL AÑO # //
    -- // ########################### //
    IF vgtipo_anio_calc = "1" THEN
        LET vnumdias = 360;
    ELSE
        LET vnumdias = 365;
    END IF
    
    SET LOCK MODE TO WAIT 2;
    
    -- // ################################# //
    -- // # PROVISION Y PAGO DE INTERESES # //
    -- // ################################# //
    IF vgtipo_dias_calc IN ("D","M") THEN  
        LET psdo_prom = vgsdo_disp;
        LET vdias_prom = pdias;
        LET vtotint = 0;
        LET vsdo_promedio = vgacum_sdo_pos / vgdia_sdo_pos;
        
        -- // ################################ //
        -- // # CALCULO DE INTERESES DIARIOS # //
        -- // ################################ //
        IF vgpaga_interes = "S" AND vsdo_promedio >= vgmto_pag_int THEN  
            LET vvaltasa = vvaltasa + vgsobretasa;
            LET vvalor_tasa = vvaltasa / 100;
            
            IF vgtipo_anio_calc = "1" THEN
                LET vnumdias = 360;
            ELSE
                LET vnumdias = 365;
            END IF
            
            IF vdias_prom > 0 THEN
                LET vtotint = (((vsdo_promedio * vvalor_tasa) / vnumdias) * vdias_prom);
            ELSE
                LET vtotint = 0;
            END IF
        END IF
            
        LET vintdia = vtotint;
                
        -- // ################################################################## //
        -- // # PROVISION DIARIA Y ACUMULACION, CAPITALIZACION AL MESIVERSARIO # //
        -- // ################################################################## //
        IF vgtipo_dias_calc = "D" THEN  
            IF vtotint > 0 THEN
                INSERT INTO sc_movdia VALUES 
                ( 0, vfolio_suc, vgsucursal, vgusuario, vgfecha_hoy, vgfecha_hoy, vhora, vgtranprov, vgsucursal, vgproducto, pempresa,
                  vgcuenta, "", 0, vtotint, vtotint, 0, 0, 0, "", vgstatus_cta, vgsdo_actual, "0000", " ", vvalor_tasa, vgnum_tarjeta, "" );
            
                UPDATE sc_maenoc
                   SET (int_acum, capitalizacion, paga_interes) =
                       (int_acum + vtotint, vgpago_interes, vgpaga_interes)
                 WHERE empresa = pempresa
                   AND cuenta = vgcuenta;
            END IF
            
        -- // ###################################### //
        -- // # PROVISION MENSUAL Y AL MESIVERARIO # //
        -- // ###################################### //
        ELIF vgtipo_dias_calc = "M"  THEN  
            IF (vgfecha_hoy = vgult_hab_mes OR vgfecha_pago = vgfecha_hoy) THEN
                
                -- // ################################################ //
                -- // # TRAE LA TASA INTERES PARA CUENTAS CRECIENTES # //
                -- // ################################################ //
                IF vgproducto = vgProdCreciente THEN  
                    SELECT valor_tasa/100
                      INTO vvalor_tasa
                      FROM sc_tasa_variable
                     WHERE empresa = pempresa
                       AND cuenta = vgcuenta
                       AND inicio_periodo < vgfecha_hoy
                       AND fin_periodo >= vgfecha_hoy
                       AND tipo_tasa = "M";
                END IF
                
                IF vvalor_tasa IS NULL THEN
                    LET vvalor_tasa = vvaltasa/100;
                END IF
                
                -- // ########################### //
                -- // # PROVISION DE FIN DE MES # //
                -- // ########################### //
                IF (vgfecha_hoy = vgult_hab_mes) THEN  
                    LET vint_acum = vgint_acum;
                    LET vgacum_sdo_int = ((((vgacum_sdo_pos / vgdia_sdo_pos) * vvalor_tasa) / vnumdias) * vgdia_sdo_pos);
                    LET vgacum_sdo_int = vgacum_sdo_int - vint_acum;
                    LET vgint_acum = vgacum_sdo_int;
                    
                    -- // ############################################################ //
                    -- // # SOLO PERMITE PROVISIONAR CUANDO EL SALDO ES MAYOR A CERO # //
                    -- // ############################################################ //
                    IF vgacum_sdo_int > 0 THEN  
                        INSERT INTO sc_movdia VALUES 
                        ( 0, vfolio_suc, vgsucursal, vgusuario, vgfecha_hoy, vgfecha_hoy, vhora, vgtranprov, vgsucursal, vgproducto, pempresa,
                          vgcuenta, "", 0, vgacum_sdo_int, vgacum_sdo_int, 0, 0, 0, "", vgstatus_cta, vgsdo_actual, "0000", " ", vvalor_tasa, vgnum_tarjeta, "" );
                    END IF
                
                -- // ############################# //
                -- // # PROVISION AL MESIVERSARIO # //
                -- // ############################# //
                ELSE  
                    LET vgacum_sdo_int = ((((vgacum_sdo_pos / vgdia_sdo_pos) * vvalor_tasa) / vnumdias) * vgdia_sdo_pos);
                
                    IF vgacum_sdo_int >= vgint_acum THEN
                        LET vgacum_sdo_int = vgacum_sdo_int - vgint_acum;
                    
                        IF vgacum_sdo_int > 0 THEN
                            INSERT INTO sc_movdia VALUES 
                            ( 0, vfolio_suc, vgsucursal, vgusuario, vgfecha_hoy, vgfecha_hoy, vhora, vgtranprov, vgsucursal, vgproducto, pempresa,
                              vgcuenta, "", 0, vgacum_sdo_int, vgacum_sdo_int, 0, 0, 0, "", vgstatus_cta, vgsdo_actual, "0000", " ", vvalor_tasa, vgnum_tarjeta, "" );
                        END IF
                    ELSE
                        LET vgacum_sdo_int = vgint_acum - vgacum_sdo_int;
                    
                        IF vgacum_sdo_int > 0 THEN
                            INSERT INTO sc_movdia VALUES 
                            ( 0, vfolio_suc, vgsucursal, vgusuario, vgfecha_hoy, vgfecha_hoy, vhora, vgtranrevprov, vgsucursal, vgproducto, pempresa, 
                              vgcuenta, "", 0, vgacum_sdo_int, vgacum_sdo_int, 0, 0, 0, "", vgstatus_cta, vgsdo_actual, "0000", " ", vvalor_tasa, vgnum_tarjeta, "" );
                        END IF
                        
                        LET vgacum_sdo_int = vgacum_sdo_int * -1;
                    END IF
                    
                    LET vint_acum = vgint_acum;
                    LET vgint_acum = vgacum_sdo_int;
                END IF
                
            -- // ##################### //
            -- // # ACUMULA INTERESES # //
            -- // ##################### //
            ELSE  
                LET vgacum_sdo_int = vgacum_sdo_int + vtotint;
            END IF
        END IF
        
        -- // ##################### //
        -- // # PAGO DE INTERESES # //
        -- // ##################### //
        LET vgfecha_pago   = vgfecha_pago;
        LET vgprox_fecha   = vgprox_fecha;
        LET vgpago_interes = vgpago_interes;
        LET vgfecha_hoy    = vgfecha_hoy;
        
        IF /* PAGO DIARIO */       
           ( vgpago_interes = "D" ) OR 
           /* PAGO MENSUAL */      
           ( vgpago_interes = "M"   AND vgfecha_hoy = vgult_hab_mes ) OR 
           /* PAGO ANUAL */        
           ( vgpago_interes = "A"   AND vgfecha_hoy = vgult_hab_mes AND vmes = "12" ) OR 
           /* PAGO FECHA */        
           ( vgpago_interes = "F"   AND vgfecha_pago >= vgfecha_hoy AND vgfecha_pago < vgprox_fecha ) OR 
           /* PAGO SEMESTRAL */    
           ( vgpago_interes = "S"   AND vgfecha_hoy = vgult_hab_mes AND ( vmes = "6" OR vmes = "12" ) ) OR                                       
           /* PAGO TRIMESTRAL */   
           ( vgpago_interes = "T"   AND vgfecha_hoy = vgult_hab_mes AND ( vmes = "3" OR vmes = "6" OR vmes = "9" OR vmes = "12" ) ) OR           
           /* PAGO MESIVERSARIO */ 
           ( ( vgpago_interes = "V" AND vgfecha_pago >= vgfecha_hoy AND vgfecha_pago < vgprox_fecha ) AND ( vgfecha_alta <> vgfecha_hoy ) ) THEN 
            
            LET vsdo_promedio = vgacum_sdo_pos / vgdia_sdo_pos;
            LET vtotint = ((((vgacum_sdo_pos / vgdia_sdo_pos) * vvalor_tasa) / vnumdias) * vgdia_sdo_pos);
            
            IF vtotint > 0 THEN
                -- // ############################################## //
                -- // # REGISTRA TRANSACCION DEL PAGO DE INTERESES # //
                -- // ############################################## //
                INSERT INTO sc_movdia VALUES 
                ( 0, vfolio_suc, vgsucursal, vgusuario, vgfecha_hoy, vgfecha_hoy, vhora, vgtrans_pag_int, vgsucursal, vgproducto,
                  pempresa, vgcuenta, "", 0, vtotint, vtotint, 0, 0, 0, "", "1", vgsdo_actual, "0000", " ", vvalor_tasa, vgnum_tarjeta, "" );
                
                LET vmaxsecuencia = 1;
                LET vMtoMeta = 0;
                   
                -- // ########################################## //
                -- // # VENCIMIENTOS DE INVERSIONES CRECIENTES # //
                -- // ########################################## //
                IF vgproducto = vgProdCreciente THEN
				    LET vfecha_mod = vgfecha_mod;
                    LET vfecha_mod = vfecha_mod - 1 UNITS DAY;
                    
                    EXECUTE PROCEDURE "informix".sp_valfechabil(vfecha_mod, '-') 
                    INTO vcodret, vfecha_mod;
                    
                    IF (vfecha_mod = vgfecha_hoy) THEN
                        -- // ############################### //
                        -- // # TRAE EL INTERES X TASA META # //
                        -- // ############################### //
                        SELECT int_acum, valor_tasa, isr, (fin_periodo - inicio_periodo)
                          INTO vMtoMeta, vvaltasa, visr_prem, vnumdias
                          FROM sc_tasa_variable
                         WHERE empresa = pempresa
                           AND cuenta = vgcuenta
                           AND fin_periodo = vgfecha_mod
                           AND tipo_tasa = "P";
                           
                        LET visr_prem = 0.00;
                        
                        -- // ############################ //
                        -- // # PROVISION DEL MONTO META # //
                        -- // ############################ //
                        INSERT INTO sc_movdia VALUES
                        ( 0, vfolio_suc, vgsucursal, vgusuario, vgfecha_hoy, vgfecha_hoy, vhora, vgtranprov, vgsucursal, vgproducto, pempresa, 
                          vgcuenta, "", 0, vMtoMeta, vMtoMeta, 0, 0, 0, "", vgstatus_cta, vgsdo_actual, "0000", " ", vvalor_tasa, vgnum_tarjeta, "" );
                        
                        -- // ################################# //
                        -- // # CAPITALIZACION DEL MONTO META # //
                        -- // ################################# //
                        INSERT INTO sc_movdia VALUES
                        ( 0, vfolio_suc, vgsucursal, vgusuario, vgfecha_hoy, vgfecha_hoy, vhora, vgtrans_pag_int, vgsucursal, vgproducto, pempresa, 
                          vgcuenta, "", 0, vMtoMeta, vMtoMeta, 0, 0, 0, "", vgstatus_cta, vgsdo_actual, "0000", " ", vvalor_tasa, vgnum_tarjeta, "" );
                        
                        -- // ################################ //
                        -- // # RETENCION ISR DEL MONTO META # //
                        -- // ################################ //
                        IF visr_prem > 0 THEN
                            INSERT INTO sc_movdia VALUES
                            ( 0, vfolio_suc, vgsucursal, vgusuario, vgfecha_hoy, vgfecha_hoy, vhora, vgtransisr, vgsucursal, vgproducto, pempresa, 
                              vgcuenta, "", 0, visr_prem, visr_prem, 0, 0, 0, "", vgstatus_cta, vgsdo_actual, "0000", " ", 0.0, vgnum_tarjeta, "" );
                             
                            -- // ################################# //
                            -- // # REFERENCIA ISR DEL MONTO META # //
                            -- // ################################# //
                            INSERT INTO sc_isr VALUES
                            ( pempresa, vgcuenta, vsecuencia, vgsdo_actual, vvaltasa, vnumdias, vMtoMeta, 0, 0, visr_prem, vMtoMeta - visr_prem );
                        END IF
                        
                        LET vmaxsecuencia = 2;
                    END IF
                END IF
                
                -- // ##################################################################################################################### //
                -- // # SE AGREAGA INICIALIZAR EL NUMERO DE CHEQUES EXPEDIDOS EN EL MES AL MOMENTO DEL PAGO DE INTERESES PISA-ARS FEB2010 # //
                -- // ##################################################################################################################### //
                UPDATE sc_maechq
                   SET (num_abonos_mes, imp_abonos_mes, sdo_actual, ultpagoint, chq_exp_mes) =
                       (num_abonos_mes + vmaxsecuencia, imp_abonos_mes + (vtotint + vMtoMeta), sdo_actual + ((vtotint + vMtoMeta) - visr_prem), vgfecha_hoy, 0)
                 WHERE empresa = pempresa
                   AND cuenta = vgcuenta;
                
                LET vgsdo_actual = (vgsdo_actual + vtotint + vMtoMeta) - visr_prem;
            END IF
            
            -- // ########################## //
            -- // # VERIFICAR SI COBRA ISR # //
            -- // ########################## //
            IF vgexento_isr = "N" OR vgexento_isr = "n" THEN
                IF vtotint > 0 THEN
                    IF vges_fisica = "S" THEN
                        LET vtipper = "F";
                    ELSE
                        LET vtipper = "M";
                    END IF
                
                    LET vgdia_sdo_pos = vgdia_sdo_pos;
                    
                    CALL calc_isr(pempresa,vgcuenta,vgfecha_hoy,vvaltasa,vtotint,vsdo_promedio,vgdia_sdo_pos,vtipper)
                    RETURNING vcodret,visr;
                    
                    IF visr > 0 THEN
                        CALL cargocie(pempresa,vgsucursal,vgusuario,vgtransisr,vtransuc,vfolio_suc,vgcuenta,vcero,visr)
                        RETURNING vcodret;
                        
                        UPDATE sc_maenoc
                           SET isr_acum = isr_acum + (visr + visr_prem)
                         WHERE empresa = pempresa
                           AND cuenta = vgcuenta;
                        
                        -- // ######################################################## //
                        -- // # RESTA EL IMPORTE DE LA RETENCION ISR AL SALDO ACTUAL # //
                        -- // ######################################################## //
                        LET vgsdo_actual = vgsdo_actual - visr ;
                    END IF
                END IF
            ELSE                
                -- // ######################################## //
                -- // # GRABA LA CUENTA SIN RETENCION DE ISR # //
                -- // ######################################## //
                LET visr = 0; 
                INSERT INTO sc_isr VALUES
                (pempresa, vgcuenta, vsecuencia, psdo_prom, vvaltasa, vgdias_acum_int, vtotint, 0, 0, 0, vtotint);
            END IF
            
            LET vimporte = vtotint - visr;
            
            IF vgproducto = vgProdCreciente THEN
                IF vimporte > 0 THEN
                    IF vginstrucc IS NULL THEN
                        LET vginstrucc = "01";
                    END IF
                    
                    -- // ############################################################# //
                    -- // # INSTRUCCION 2 TRASPASO CAPITAL E INTERESES AL ANIVERSARIO # //
                    -- // ############################################################# //
                    IF vginstrucc = "02" THEN
                        IF vfecha_mod = vgfecha_hoy THEN
                            CALL abono_ref( pempresa, vgsucursal, vgusuario, '0205', '0000', vfolio_suc, vgcuentadep, 
                                            0, vgsdo_actual, vgsdo_actual, 0, 0, 0, '01', 'TRASPASO CAP E INT INV. CRECIENTE', vgnum_tarjeta, '')
                            RETURNING vcodret_trasp;
                            
                            IF vcodret_trasp = '000' THEN
                                INSERT INTO sc_movdia VALUES
                                ( 0, vfolio_suc, vgsucursal, vgusuario, vgfecha_hoy, vgfecha_hoy, vhora, '0239', vgsucursal, vgproducto, pempresa, vgcuenta, "", 0, 
                                  vgsdo_actual, vgsdo_actual, 0, 0, 0, "", vgstatus_cta, vgsdo_actual, "0000", "CARGO POR TRASPASO", vvalor_tasa, vgnum_tarjeta, "" );
                                 
                                UPDATE sc_maechq
                                   SET num_cgos_mes = num_cgos_mes + 1,
                                       imp_cgos_mes = imp_cgos_mes + vgsdo_actual,
                                       sdo_actual = sdo_actual - vgsdo_actual,
                                       status_cta = '2',
                                       fec_ult_mov = vgfecha_hoy
                                 WHERE empresa = pempresa
                                   AND cuenta = vgcuenta;
                            END IF;
                        END IF;
                    END IF;
                    
                    -- // ############################################################################################# //
                    -- // # INSTRUCCION 3 TRASPASO MENSUAL DE LOS INTERESES Y REINVERSION DEL CAPITAL AL MESIVERSARIO # //
                    -- // ############################################################################################# //
                    IF vginstrucc = "03" THEN
                        LET vimporte = vimporte + vMtoMeta;
                        
                        CALL abono_ref( pempresa, vgsucursal, vgusuario, '0205', '0000', vfolio_suc, vgcuentadep, 
                                        0, vimporte, vimporte, 0, 0, 0, '01', 'TRASPASO INT INV. CRECIENTE', vgnum_tarjeta, '')
                        RETURNING vcodret_trasp;
                        
                        IF vcodret_trasp = '000' THEN
                            INSERT INTO sc_movdia VALUES
                            ( 0, vfolio_suc, vgsucursal, vgusuario, vgfecha_hoy, vgfecha_hoy, vhora, '0239', vgsucursal, vgproducto, pempresa, vgcuenta,  
                              "", 0, vimporte, vimporte, 0, 0, 0, "", vgstatus_cta, vgsdo_actual, "0000", "CARGO POR TRASPASO", vvalor_tasa, vgnum_tarjeta, "" );
                             
                            UPDATE sc_maechq
                               SET num_cgos_mes = num_cgos_mes + 1,
                                   imp_cgos_mes = imp_cgos_mes + vimporte,
                                   sdo_actual = sdo_actual - vimporte,
                                   fec_ult_mov = vgfecha_hoy
                             WHERE empresa = pempresa
                               AND cuenta = vgcuenta;
                        END IF;
                    END IF;
                    
                    -- // ########################################################################################## //
                    -- // # INSTRUCCION 4 TRASPASO MENSUAL DE LOS INTERESES Y TRASPASO DEL CAPITAL AL MESIVERSARIO # //
                    -- // ########################################################################################## //
                    IF vginstrucc = "04" THEN
                        IF vfecha_mod = vgfecha_hoy THEN
                            CALL abono_ref( pempresa, vgsucursal, vgusuario, '0205', '0000', vfolio_suc, vgcuentadep, 
                                            0, vgsdo_actual, vgsdo_actual, 0, 0, 0, '01', 'TRASPASO CAP INV. CRECIENTE', vgnum_tarjeta, '')
                            RETURNING vcodret_trasp;
                            
                            IF vcodret_trasp = '000' THEN
                                INSERT INTO sc_movdia VALUES
                                ( 0, vfolio_suc, vgsucursal, vgusuario, vgfecha_hoy, vgfecha_hoy, vhora, '0239', vgsucursal, vgproducto, pempresa, vgcuenta, "", 0, 
                                  vgsdo_actual, vgsdo_actual, 0, 0, 0, "", vgstatus_cta, vgsdo_actual, "0000", "CARGO POR TRASPASO", vvalor_tasa, vgnum_tarjeta, "" );
                                 
                                UPDATE sc_maechq
                                   SET num_cgos_mes = num_cgos_mes + 1,
                                       imp_cgos_mes = imp_cgos_mes + vgsdo_actual,
                                       sdo_actual = sdo_actual - vgsdo_actual,
                                       status_cta = '2',
                                       fec_ult_mov = vgfecha_hoy
                                 WHERE empresa = pempresa
                                   AND cuenta = vgcuenta;
                            END IF;
                        ELSE
                            CALL abono_ref( pempresa, vgsucursal, vgusuario, '0205', '0000', vfolio_suc, vgcuentadep, 
                                            0, vimporte, vimporte, 0, 0, 0, '01', 'TRASPASO INT INV. CRECIENTE', vgnum_tarjeta, '')
                            RETURNING vcodret_trasp;
                            
                            IF vcodret_trasp = '000' THEN
                                INSERT INTO sc_movdia VALUES
                                ( 0, vfolio_suc, vgsucursal, vgusuario, vgfecha_hoy, vgfecha_hoy, vhora, '0239', vgsucursal, vgproducto, pempresa, vgcuenta,  
                                  "", 0, vimporte, vimporte, 0, 0, 0, "", vgstatus_cta, vgsdo_actual, "0000", "CARGO POR TRASPASO", vvalor_tasa, vgnum_tarjeta, "" );
                                 
                                UPDATE sc_maechq
                                   SET num_cgos_mes = num_cgos_mes + 1,
                                       imp_cgos_mes = imp_cgos_mes + vimporte,
                                       sdo_actual = sdo_actual - vimporte,
                                       fec_ult_mov = vgfecha_hoy
                                 WHERE empresa = pempresa
                                   AND cuenta = vgcuenta;
                            END IF;
                        END IF;
                    END IF;
                END IF
            END IF;
            
            IF vgpago_interes = "V" THEN
                UPDATE sc_maenoc
                   SET int_acum        = 0,
                       dias_acum_int   = 0,
                       acum_sdo_int    = 0,
                       dia_sdo_pos     = 0,
                       acum_sdo_pos    = 0,
                       acum_sbc        = 0,
                       acum_rem        = 0,
                       sdo_mes_ant     = vgsdo_actual,
                       sdo_prom_mesant = vsdo_promedio,
                       ret_mes_ant     = vgsdo_retenido,
                       cong_mes_ant    = vgsdo_cong
                 WHERE empresa = pempresa
                   AND cuenta = vgcuenta;
            END IF;
               
            -- // ###################################### //
            -- // # VALIDA SI LA CUENTA ESTA BLOQUEADA # //
            -- // ###################################### //
            LET vsdocong = 0;
            
            IF vgstatus_cta = "3" AND vtotint > 0 THEN
                SELECT motivo
                  INTO vmotivo
                  FROM sc_maechq
                 WHERE empresa = pempresa
                   AND cuenta = vgcuenta;
                
                SELECT abono
                  INTO vaceptab
                  FROM sc_bloqueo
                 WHERE codigo = vmotivo;
                
                SELECT opcion
                  INTO vopcion
                  FROM sc_ctabloqueo
                 WHERE cuenta = vgcuenta;
                
                IF ((vaceptab = "N" AND vmotivo <> '99') OR (vopcion = 4 OR vopcion = 2)) THEN
                    LET vsdocong = vtotint - visr;
                    LET vmesdia = MONTH(vgfecha_hoy) + DAY(vgfecha_hoy);
                    LET vclave = vmesdia + vhoraw;
                    LET vsdodisp = vgsdo_actual;
                    
                    INSERT INTO sc_histbloq (empresa,cuenta,tipo_mov,motivo,opcion,importe,usuario,fecha,hora,clave,status_blo,folio_suc,referencia)  
                    VALUES (pempresa,vgcuenta,"B",vmotivo,vopcion,vsdocong,vgusuario,vgfecha_hoy,vhora,vclave,"B",vfolio_suc,"BLOQUEO POR PAGO DE INTERES");
                    
                    INSERT INTO sc_movdia VALUES 
                    ( 0, vfolio_suc, vgsucursal, vgusuario, vgfecha_hoy, vgfecha_hoy, vhora, "3353", vgsucursal, vgproducto,
                      pempresa, vgcuenta, "", 0, vsdocong, vsdocong, 0, 0, 0, "", "1", vsdodisp, "0000", " ", 0, vgnum_tarjeta, "" );
                ELSE
                    LET vsdocong = 0;
                END IF
            END IF
                
            -- // ########################################################## //
            -- // # GENERA ESTADO DE CUENTA PARA CUENTAS TIPO MESIVERSARIO # //
            -- // ########################################################## //
            IF vgpago_interes = "V" THEN
                CALL crea_maehis(pempresa, vgcuenta, vgfecha_pago, vgfecha_alta, vgacum_sdo_pos, vgdia_sdo_pos)
                RETURNING vcodret;
                
                IF vdia = 1 AND vgfecha_hoy = '12'||'31'||YEAR(vgfecha_hoy) THEN
                    LET vdias_prom = pdias - 1;
                    LET vsdo_promedio = vgacum_sdo_pos / vgdia_sdo_pos;
                    LET vintdia = (((vsdo_promedio * vvalor_tasa) / vnumdias) * vdias_prom);
                    LET vgacum_sdo_int = vintdia;
                    LET vgacum_sdo_pos = vgsdo_actual;
                    LET vgdias_acum_int = vdias_prom;
                    LET vgdia_sdo_pos = vdias_prom;
                    LET vgint_acum = 0;
                ELSE
                    LET vgacum_sdo_int = 0;
                    LET vgacum_sdo_pos = 0;
                    LET vgdias_acum_int = 0;
                    LET vgdia_sdo_pos = 0;
                    LET vgint_acum = 0;
                END IF
                
            END IF
            
        END IF
        
    END IF
    
    SET LOCK MODE TO NOT WAIT;
    
    RETURN vcodret;
    
    END
    
END PROCEDURE
    
DOCUMENT 
'Se realiza modificacion al procedimiento en los inserts a la tablas sc_ctabloqueo y sc_histbloq ',
'Modifico : Jesús Manuel Aguilar Heredia',
'FECHA : 14/SEPTIEMBRE/2010',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".cierrechq_reg_pba( pempresa   CHAR(3),
                                           pdias      INTEGER,
                                           pcuenta    CHAR(20),
                                           pProducto  CHAR(4),
                                           pSdoActual MONEY(14,2),
                                           pSucursal  CHAR(4) )
RETURNING CHAR(5);
    
    -- ***********************************************************************
    -- *                                                                     *
    -- * cierrechq_reg                                                       *
    -- * Version              1.0.0                                          *
    -- * Obejtivo:            Obtiene Informacion e identifica tipo de cierre*
    -- * Creado por:                                                         *
    -- * ModIFicado por:      Alejandro Rueda Sanchez                        *
    -- * Ultima Modificacion: Septiembre 2009                                *
    -- *                     Creación de SPL                                 *
    -- *                                                                     *
    -- ***********************************************************************
    
    DEFINE GLOBAL vgusuario       CHAR(8)       DEFAULT " ";
    DEFINE GLOBAL vgprox_fecha    DATE          DEFAULT " ";
    DEFINE GLOBAL vgfecha_hoy     DATE          DEFAULT " ";
    DEFINE GLOBAL vgpri_hab_mes   DATE          DEFAULT " ";
    DEFINE GLOBAL vgpri_dia_mes   DATE          DEFAULT " ";
    DEFINE GLOBAL vgult_hab_mes   DATE          DEFAULT " ";
    DEFINE GLOBAL vgult_dia_mes   DATE          DEFAULT " ";
    DEFINE GLOBAL vgtrans_pag_int CHAR(4)       DEFAULT " ";
    DEFINE GLOBAL vgtransisr      CHAR(4)       DEFAULT " ";
    DEFINE GLOBAL vgtranprov      CHAR(4)       DEFAULT " ";
    DEFINE GLOBAL vgtranabotrasp  CHAR(4)       DEFAULT " ";
    DEFINE GLOBAL vgtranrevprov   CHAR(4)       DEFAULT " ";
    DEFINE GLOBAL vgfecha_pago    DATE          DEFAULT " ";
    DEFINE GLOBAL vgProdCreciente CHAR(4)       DEFAULT " ";
    DEFINE GLOBAL vgint_acum      DECIMAL(14,2) DEFAULT 0;
    DEFINE GLOBAL vgacum_sdo_int  MONEY(14,2)   DEFAULT 0;
    DEFINE GLOBAL vgfecha_mod     DATE          DEFAULT " ";
    DEFINE GLOBAL vgnum_cte       CHAR(20)      DEFAULT " ";
    DEFINE GLOBAL vgfecha_alta    DATE          DEFAULT " ";
    DEFINE GLOBAL vgstatus_cta    char(1)       DEFAULT " ";
    DEFINE GLOBAL vgtranrecrece   char(4)       DEFAULT " ";
    DEFINE GLOBAL vginstrucc      CHAR(2)       DEFAULT " ";
    DEFINE GLOBAL vgcuentadep     CHAR(20)      DEFAULT " ";
    
    DEFINE vdiaspri       INTEGER;
    DEFINE vcodret        CHAR(5);
    DEFINE vcodret2       CHAR(5);
    DEFINE vcodret3       CHAR(40);
    DEFINE vsqlerr        INTEGER;
    DEFINE isam_err       INTEGER;
    DEFINE error_info     CHAR(40);
    DEFINE vfolio_suc     CHAR(16);
    DEFINE vcontador      INTEGER;
    DEFINE vsdo_total     MONEY(14,2);
    DEFINE vrenuevac      SMALLINT;
    DEFINE vaniomescre    CHAR(6);
    DEFINE vfecha         DATE;
    DEFINE vfecha_mod     DATE;
    DEFINE vfechahora     CHAR(40);
    
    LET vcodret     = "000";
    LET vcodret2    = "000";
    LET vcodret3    = "000";
    LET vaniomescre = "";
    LET vrenuevac   = 0;
    LET vfechahora  = " ";
    
    BEGIN WORK;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "cierrechq_reg.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            LET vfechahora = CURRENT;
            ROLLBACK WORK;
            INSERT INTO sc_valcierre VALUES(pempresa, pcuenta,vcodret);
            RETURN vcodret;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;
    
    IF vgfecha_hoy = vgult_hab_mes THEN
        CALL cierre_mensual(pempresa,pdias,pcuenta) 
        RETURNING vcodret;
        
        IF vcodret <> "000" THEN
            ROLLBACK WORK;
            INSERT INTO sc_valcierre values (pempresa, pcuenta,vcodret);
            RETURN vcodret;
        END IF
    ELSE
        IF vgfecha_hoy = vgpri_hab_mes THEN
            IF vgpri_dia_mes != vgpri_hab_mes THEN
                LET vdiaspri = day(vgpri_hab_mes) - 1;
                
                SELECT count(*) 
                  INTO vcontador
                  FROM sc_maechq a, 
                       sc_maenoc b, 
                       sc_producto c
                 WHERE a.empresa = pempresa
                   AND a.cuenta = pcuenta
                   AND a.status_cta <> "3"
                   AND b.empresa = a.empresa
                   AND b.cuenta = a.cuenta
                   AND b.fecha_alta < vgpri_dia_mes
                   AND c.empresa = a.empresa
                   AND c.producto = a.producto
                   AND c.pago_interes NOT IN("V","F","D");
                    
                IF vcontador > 0 THEN
                    UPDATE sc_maenoc
                       SET (dia_sdo_pos,acum_sdo_pos) = (vdiaspri,sdo_mes_ant * vdiaspri)
                    WHERE empresa = pempresa
                      AND cuenta = pcuenta;
                END IF
            END IF
        END IF
        
        CALL cierre_diario(pempresa,pdias,pcuenta) 
        RETURNING vcodret;
        
        IF vcodret <> "000" THEN
            ROLLBACK WORK;
            INSERT INTO sc_valcierre VALUES(pempresa, pcuenta,vcodret);
            RETURN vcodret;
        END IF
    END IF
    
    SELECT count(*) 
      INTO vcontador
      FROM sc_maechq
     WHERE empresa = pempresa
       AND cuenta = pcuenta
       AND status_cta = "1"
       AND ( imp_sbg_ccc > 0 OR imp_chq_sbg > 0 OR cuenta IN(SELECT distinct mv.cuenta 
                                                               FROM sc_movdia mv
                                                              WHERE mv.empresa = pempresa 
                                                                AND mv.cuenta = pcuenta
                                                                AND mv.cancelad != "S" 
                                                                AND mv.transacc IN("3240","3241","3242","3247","3357")) );
    
    IF vcontador = 1 THEN
        CALL histsbg(pempresa,pcuenta) 
        RETURNING vcodret;
        
        IF vcodret <> "000" THEN
            ROLLBACK WORK;
            INSERT INTO sc_valcierre VALUES(pempresa, pcuenta, vcodret);
            RETURN vcodret;
        END IF
    END IF
    
    LET vrenuevac = 0;
    
    -- // ################################################## //
    -- // #  VERIFICA SI LA INVERSION CRECIENTE YA VENCIO  # //
    -- // ################################################## //
    IF pProducto = vgProdCreciente THEN
        LET vfecha_mod = vgfecha_mod;
        LET vfecha_mod = vfecha_mod - 1 UNITS DAY;
        
        EXECUTE PROCEDURE "informix".sp_valfechabil(vfecha_mod, '-') 
        INTO vcodret, vfecha_mod;
        
        IF (vfecha_mod = vgfecha_hoy) THEN
            IF vginstrucc IN('01','03') THEN
                -- // ######################################## //
                -- // # Obtiene el Saldo Actual de la Cuenta # //
                -- // ######################################## //
                SELECT sdo_actual
                  INTO vsdo_total
                  FROM sc_maechq
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta;
                
                LET vfolio_suc = current hour TO fraction(3);
                LET vfolio_suc = vgusuario||vfolio_suc[1,2]||vfolio_suc[4,5]||vfolio_suc[7,8]||vfolio_suc[10,11];
                
                -- // ######################################################## //
                -- // # REALIZA EL MOVIMIENTO DE RENOVACION (ES REFERENCIAL) # //
                -- // ######################################################## //
                INSERT INTO sc_movdia VALUES
                ( 0, vfolio_suc, psucursal, USER, vgfecha_hoy, vgfecha_hoy, current hour TO fraction(3), 
                  vgtranrecrece, psucursal, pProducto, pempresa, pcuenta, " ", 0, vsdo_total, vsdo_total, 
                  0, 0, 0, " ", " ", vsdo_total, "0000", "RENOVACION DE INVERSION CRECIENTE", 0, "", "" );
                
                -- // ################################################# //
                -- // # Respalda la proyeccion actual en el historico # //
                -- // ################################################# //
                LET vaniomescre = YEAR(vgfecha_hoy)||LPAD(month(vgfecha_hoy),2,0);
                
                INSERT INTO sc_tasa_var_hist
                SELECT vaniomescre, a.*
                  FROM sc_tasa_variable a
                 WHERE a.empresa = pempresa
                   AND a.cuenta  = pcuenta;
                
                -- // ################################ //
                -- // # ELIMINA LA PROYECCION ACTUAL # //
                -- // ################################ //
                DELETE FROM sc_tasa_variable
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta;
                
                -- // ################################################################ //
                -- // # REALIZA LAS ACTUALIZACIONES PARA GENERAR LA NUEVA PROYECCION # //
                -- // ################################################################ //
                UPDATE sc_maenoc
                   SET fecha_mod = NULL,
                       fecha_alta = vgprox_fecha,
                       dia_sdo_pos = 0,
                       acum_sdo_pos = 0
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta;
                   
                UPDATE sc_maechq
                   SET imp_chq_rem = vsdo_total,
                       fec_ult_mov = vgfecha_hoy
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta;
                
                LET vrenuevac = 1;
                
            ELIF vginstrucc IN('02','04') THEN
            
                -- // ################################################# //
                -- // # Respalda la proyeccion actual en el historico # //
                -- // ################################################# //
                LET vaniomescre = YEAR(vgfecha_hoy)||LPAD(month(vgfecha_hoy),2,0);
                
                INSERT INTO sc_tasa_var_hist
                SELECT vaniomescre, a.*
                  FROM sc_tasa_variable a
                 WHERE a.empresa = pempresa
                   AND a.cuenta  = pcuenta;
                
                -- // ################################ //
                -- // # ELIMINA LA PROYECCION ACTUAL # //
                -- // ################################ //
                DELETE FROM sc_tasa_variable
                 WHERE empresa = pempresa
                   AND cuenta = pcuenta;
                   
                LET vrenuevac = -1;
            END IF
        END IF
    END IF
    
    LET vcontador = dbinfo("sqlca.sqlerrd2");
    LET vcodret = "000";
    LET vfecha = vgprox_fecha;
    
    -- // ###################################################################### //
    -- // # Si es renovacion, pone la fecha_proceso a una fecha especifica.... # //
    -- // ###################################################################### //
    IF vrenuevac = 1 THEN
        LET vfecha = "01/01/1900"; 
    ELIF vrenuevac = -1 THEN
        LET vfecha = vgfecha_hoy; 
    END IF
    
    SET LOCK MODE TO WAIT 2;
    
    -- // ############################################## //
    -- // # Actualiza con la fecha como ya procesado.. # //
    -- // ############################################## //
    UPDATE sc_maechq
       SET fecha_proceso = vfecha,
           sdo_dia_ant = sdo_actual
     WHERE empresa = pempresa
       AND cuenta = pcuenta;
       
    SET LOCK MODE TO NOT WAIT;
    
    COMMIT WORK;
    
    END;
    
    RETURN vcodret;
    
END PROCEDURE;