CREATE PROCEDURE "informix".calcula_intqra
(
pempresa  	CHAR(3),
pdias 		INTEGER, 
psdo_prom 	MONEY(14,2)
)
RETURNING CHAR(5);

    -- ***********************************************************************
    -- * calcula_intqra
    -- * Version              1.0.0
    -- * Obejtivo:            Calcula, provisiona y capitaliza los intereses
    -- *                      e isr de las cuentas producto 1900
    -- * Creado por:
    -- * ModIFicado por:      Alejandro Rueda Sanchez
    -- * Ultima Modificacion: Junio 2010
    -- *                     Creación de SPL
    -- ***********************************************************************

    --//DEFINICION DE VARIABLES
    DEFINE GLOBAL vgracuenta         	CHAR(20)     	DEFAULT " ";
    DEFINE GLOBAL vgrasucursal       	CHAR(4)      	DEFAULT " ";
    DEFINE GLOBAL vgrasdo_actual     	MONEY(14,2)  	DEFAULT 0;
    DEFINE GLOBAL vgraacum_sdo_pos   	MONEY(14,2)  	DEFAULT 0;
    DEFINE GLOBAL vgradia_sdo_pos    	SMALLINT     	DEFAULT 0;
    DEFINE GLOBAL vgraproducto       	CHAR(4)      	DEFAULT " ";
    DEFINE GLOBAL vgrastatus_cta     	CHAR(1)      	DEFAULT " ";
    DEFINE GLOBAL vgrapaga_interes   	CHAR(1)      	DEFAULT " ";
    DEFINE GLOBAL vgramto_pag_int    	MONEY(14,2)  	DEFAULT 0;
    DEFINE GLOBAL vgratasa           	CHAR(8)      	DEFAULT " ";
    DEFINE GLOBAL vgrasobretasa      	DECIMAL(9,6) 	DEFAULT 0;
    DEFINE GLOBAL vgratp_moneda      	CHAR(2)      	DEFAULT " ";
    DEFINE GLOBAL vgraes_fisica      	CHAR(1)      	DEFAULT " ";
    DEFINE GLOBAL vgraexento_isr     	CHAR(1)      	DEFAULT " ";
    DEFINE GLOBAL vgratipo_dias_calc 	CHAR(1)      	DEFAULT " ";
    DEFINE GLOBAL vgrapago_interes   	CHAR(1)      	DEFAULT " ";
    DEFINE GLOBAL vgratipo_anio_calc 	CHAR(1)      	DEFAULT " ";
    DEFINE GLOBAL vgrausuario        	CHAR(8)      	DEFAULT " ";
    DEFINE GLOBAL vgraprox_fecha     	DATE         	DEFAULT " ";
    DEFINE GLOBAL vgrafecha_hoy      	DATE         	DEFAULT " ";
    DEFINE GLOBAL vgrafecha_pago     	DATE         	DEFAULT " ";
    DEFINE GLOBAL vgrapri_hab_mes    	DATE         	DEFAULT " ";
    DEFINE GLOBAL vgrapri_dia_mes    	DATE         	DEFAULT " ";
    DEFINE GLOBAL vgrault_hab_mes    	DATE         	DEFAULT " ";
    DEFINE GLOBAL vgrault_dia_mes    	DATE         	DEFAULT " ";
    DEFINE GLOBAL vgratrans_pag_int  	CHAR(4)      	DEFAULT " ";
    DEFINE GLOBAL vgratransisr       	CHAR(4)      	DEFAULT " ";
    DEFINE GLOBAL vgratranrevprov    	CHAR(4)      	DEFAULT " ";
    DEFINE GLOBAL vgratranprov       	CHAR(4)      	DEFAULT " ";
    DEFINE GLOBAL vgratranabotrasp   	CHAR(4)      	DEFAULT " ";
    DEFINE GLOBAL vgranum_cte        	CHAR(20)     	DEFAULT " ";
    DEFINE GLOBAL vgraprodaho        	CHAR(4)      	DEFAULT " ";
    DEFINE GLOBAL vgrasdominaho      	MONEY(10,2)  	DEFAULT 0;
    DEFINE GLOBAL vgraacum_sdo_int   	MONEY(14,2)  	DEFAULT 0;
    DEFINE GLOBAL vgradias_acum_int  	INTEGER      	DEFAULT 0;
    DEFINE GLOBAL vgrafecha_alta     	DATE         	DEFAULT "";
    DEFINE GLOBAL vgraTasaVar           CHAR(1)      	DEFAULT "";
    DEFINE GLOBAL vgraProdCreciente  	CHAR(4)         DEFAULT " ";
    DEFINE GLOBAL vgraint_acum       	DECIMAL(14,2) 	DEFAULT 0;
    DEFINE GLOBAL vgrasdo_disp       	DECIMAL(14,2) 	DEFAULT 0;
    DEFINE GLOBAL vgrafecha_mod         DATE            DEFAULT " ";
    DEFINE GLOBAL vgranum_tarjeta       CHAR(20)     	DEFAULT " ";
    DEFINE GLOBAL vgrasdo_retenido      DECIMAL(14,2)   DEFAULT 0;
    DEFINE GLOBAL vgrasdo_cong          DECIMAL(14,2)   DEFAULT 0;

    DEFINE vnumdias         		SMALLINT;
    DEFINE visr,vsdocong    		MONEY(14,2);
    DEFINE vimporte,vtotint 		MONEY(14,2);
    DEFINE vtipper          		CHAR(1);
    DEFINE vvalor_tasa      		DECIMAL(9,6);
    DEFINE vvaltasa         		DECIMAL(9,6);
    DEFINE vtransuc         		CHAR(4);
    DEFINE vcero	           		SMALLINT;
    DEFINE vdias_prom       		INTEGER;
    DEFINE vhora            		DATETIME HOUR TO FRACTION;
    DEFINE vsecuencia       		INTEGER;
    DEFINE vmes,vdia        		CHAR(2);
    DEFINE vsdodisp         		MONEY(14,2);
    DEFINE vmesdia,vanio    		CHAR(4);
    DEFINE vhoraw           		CHAR(15);
    DEFINE vclave           		CHAR(5);
    DEFINE vaceptab         		CHAR(1);
    DEFINE vmotivo          		CHAR(2);
    DEFINE vfolio_suc       		CHAR(16);
    DEFINE vcodret          		CHAR(5);
    DEFINE vsqlerr          		INTEGER;
    DEFINE vinstrucc        		CHAR(2);
    DEFINE vsistema                 CHAR(2);
    DEFINE vcuentadep               CHAR(20);
    DEFINE vtrancarint              CHAR(4);
    DEFINE vsdo_promedio    		MONEY(14,2);
    DEFINE vmaxsec                  SMALLINT;
    DEFINE vintdia          		MONEY(14,2);
    DEFINE vmaxsecuencia            SMALLINT;
    DEFINE vdia_sdo_pos             SMALLINT;
    DEFINE isam_err         		SMALLINT;
    DEFINE error_info       		CHAR(40);
    DEFINE IntCrece         		DECIMAL(14,2);
    DEFINE vfecha_mod               DATE;
    DEFINE vMtoMeta         		DECIMAL(14,2);
    DEFINE vint_acum        		DECIMAL(14,2);
    DEFINE vopcion                  CHAR(2);
    DEFINE vrangofecha              CHAR(1);
    DEFINE visr_prem                MONEY(14,2);
	DEFINE cCodRetIndicador			CHAR(6);
	DEFINE vfecha_operacion         DATE;
    DEFINE vtasa_isr                DECIMAL(9,6);
    
    LET vcero        = 0;
    LET vtransuc     = "0000";
    LET vcodret      = "000";
    LET visr         = 0;
    LET visr_prem    = 0;
    LET vgracuenta     = vgracuenta;
    LET IntCrece     = 0;
    LET vMtoMeta     = 0;
    LET vopcion      = "";
	LET cCodRetIndicador = "000000";
	LET vfecha_operacion = TODAY;
    LET vtasa_isr = 0;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, isam_err, error_info
        --- SET DEBUG FILE TO "calcula_intqra.err";
        --- TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/tmp/calcula_intqra.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;

    -- // NUMERO DE TARJETA
    SELECT MAX(secuencia)
      INTO vmaxsec
      FROM sc_tarjeta
     WHERE numcte = vgranum_cte
       AND cuenta = vgracuenta
       AND tipo_tarjeta = "T";

    SELECT NVL(num_tarjeta, " ")
      INTO vgranum_tarjeta
      FROM sc_tarjeta
     WHERE numcte = vgranum_cte
       AND cuenta = vgracuenta
       AND secuencia = vmaxsec;

    -- // FOLIO OPERACIONES
    LET vhora = current hour to fraction;
    LET vhoraw = vhora;
    LET vhoraw = vhoraw[1,2]||vhoraw[4,5]||vhoraw[7,8]||vhoraw[10,11];

    LET vfolio_suc = vgrausuario||vhoraw[1,8];

    LET vdia = DAY(vgrafecha_alta);
    LET vmes = MONTH(vgrafecha_hoy);
    LET vanio = YEAR(vgrafecha_hoy);

    -- // VERIFICA SI ES MESIVERSARIO DE LA FECHA DE ALTA
    IF vgrapago_interes = "V" THEN
        CALL calcula_fechapago(vgrafecha_hoy, 0,vdia)
        RETURNING vcodret, vgrafecha_pago, vnumdias;

        IF vdia = 1 THEN
            CALL monthadd(vgrafecha_pago,1)
            RETURNING vgrafecha_pago;
        ELIF vdia = 2 AND vgrafecha_hoy = '12'||'31'||YEAR(vgrafecha_hoy) THEN
            CALL monthadd(vgrafecha_pago,1)
            RETURNING vgrafecha_pago;
        ELSE
            LET vgrafecha_pago = vgrafecha_hoy + vnumdias;
        END IF;

        IF NOT(vdia > DAY(vgrault_dia_mes) OR vdia < 1) THEN
            LET vgrafecha_pago = vgrafecha_pago - 1;
        END IF
    END IF

    LET vsecuencia = vanio||LPAD(trim(vmes),2,"0");

    -- // ASIGNA TIPO DE PERSONA
    IF vgraes_fisica = "S" THEN
        LET vtipper = "F";
    ELSE
        LET vtipper = "M";
    END IF

    -- // CALCULA LA TASA DE INTERES
    LET vsdo_promedio = vgraacum_sdo_pos / vgradia_sdo_pos;

    IF vsdo_promedio >= vgramto_pag_int OR vgraproducto = vgraProdCreciente THEN
        SELECT rangofecha
          INTO vrangofecha
          FROM bdinteg:si_tiptasa
         WHERE tasa = vgratasa
           AND empresa = pempresa;

        IF vrangofecha <> "R" THEN
            CALL calc_tasaqra(pempresa, vgratasa, vtipper, psdo_prom)
            RETURNING vcodret, vvaltasa, IntCrece;

            IF vvaltasa IS NULL THEN
                LET vvaltasa = 0;
            END IF

            LET vvalor_tasa = vvaltasa / 100;
        ELIF vrangofecha = "R" THEN
            CALL calc_tasaqra(pempresa, vgratasa, vtipper, vsdo_promedio)
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

    -- // ASIGNA NO. DIAS DEL AÑO
    IF vgratipo_anio_calc = "1" THEN
        LET vnumdias = 360;
    ELSE
        LET vnumdias = 365;
    END IF

    SET LOCK MODE TO WAIT 2;
    
    -- // PROVISION Y PAGO DE INTERESES
    IF vgratipo_dias_calc IN ("D","M") THEN
        LET psdo_prom = vgrasdo_disp;
        LET vdias_prom = pdias;
        LET vtotint = 0;
        LET vsdo_promedio = vgraacum_sdo_pos / vgradia_sdo_pos;
        
        -- // CALCULO DE INTERESES DIARIOS
        IF vgrapaga_interes = "S" AND vsdo_promedio >= vgramto_pag_int THEN 
            LET vvaltasa = vvaltasa + vgrasobretasa;
            LET vvalor_tasa = vvaltasa / 100;

            IF vgratipo_anio_calc = "1" THEN
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
        
        -- // PROVISION DIARIA Y ACUMULACION,CAPITALIZACION AL MESIVERSARIO
        IF vgratipo_dias_calc = "D" THEN  
            IF vtotint > 0 THEN
                INSERT INTO sc_movdia
                VALUES (0,vfolio_suc,vgrasucursal,vgrausuario,vgrafecha_hoy,
                        vgrafecha_hoy,vhora,vgratranprov,vgrasucursal,vgraproducto,
                        pempresa,vgracuenta, "", 0, vtotint,vtotint, 0, 0, 0, "",
                        vgrastatus_cta,vgrasdo_actual, "0000", " ",
                        vvalor_tasa,vgranum_tarjeta,"","",vfecha_operacion);

                UPDATE sc_maenoc
                   SET (int_acum, capitalizacion, paga_interes) =
                       (int_acum + vtotint, vgrapago_interes, vgrapaga_interes)
                 WHERE empresa = pempresa
                   AND cuenta = vgracuenta;
            END IF
        -- // PROVISION MENSUAL Y AL MESIVERARIO
        ELIF vgratipo_dias_calc = "M"  THEN   
            IF (vgrafecha_hoy = vgrault_hab_mes OR ( vgrafecha_pago >= vgrafecha_hoy AND vgrafecha_pago < vgraprox_fecha ) ) THEN
                /* TRAE LA TASA INTERES PARA CUENTAS CRECIENTES */
                IF vgraproducto = vgraProdCreciente THEN  
                    SELECT valor_tasa/100
                      INTO vvalor_tasa
                      FROM sc_tasa_variable
                     WHERE empresa = pempresa
                       AND cuenta = vgracuenta
                       AND inicio_periodo < vgrafecha_hoy
                       AND fin_periodo >= vgrafecha_hoy
                       AND tipo_tasa = "M";
                END IF

                IF vvalor_tasa IS NULL THEN
                    LET vvalor_tasa = vvaltasa/100;
                END IF
                
                -- // PROVISION DE FIN DE MES
                IF (vgrafecha_hoy = vgrault_hab_mes) THEN   
                    LET vint_acum = vgraint_acum;
                    LET vgraacum_sdo_int = ((((vgraacum_sdo_pos / vgradia_sdo_pos) * vvalor_tasa) / vnumdias) * vgradia_sdo_pos);
                    LET vgraacum_sdo_int = vgraacum_sdo_int - vint_acum;
                    LET vgraint_acum = vgraacum_sdo_int;

                    -- // SOLO PERMITE PROVISIONAR CUANDO EL SALDO ES MAYOR A CERO
                    IF vgraacum_sdo_int > 0 THEN
                        INSERT INTO sc_movdia
                        VALUES (0,vfolio_suc,vgrasucursal,vgrausuario,vgrafecha_hoy,
                                vgrafecha_hoy,vhora,vgratranprov,vgrasucursal,vgraproducto,
                                pempresa,vgracuenta, "", 0,vgraacum_sdo_int,
                                vgraacum_sdo_int, 0, 0, 0, "",vgrastatus_cta,
                                vgrasdo_actual,"0000"," ",vvalor_tasa,vgranum_tarjeta,"","",vfecha_operacion);
                    END IF
                
                -- // PROVISION AL MESIVERSARIO
                ELSE    
                    LET vgraacum_sdo_int = ((((vgraacum_sdo_pos / vgradia_sdo_pos) * vvalor_tasa) / vnumdias) * vgradia_sdo_pos);

                    IF vgraacum_sdo_int >= vgraint_acum THEN
                        LET vgraacum_sdo_int = vgraacum_sdo_int - vgraint_acum;

                        IF vgraacum_sdo_int > 0 THEN
                            INSERT INTO sc_movdia
                            VALUES (0,vfolio_suc,vgrasucursal,vgrausuario,vgrafecha_hoy,
                                    vgrafecha_hoy,vhora,vgratranprov,vgrasucursal,
                                    vgraproducto,pempresa,vgracuenta, "",0,vgraacum_sdo_int,
                                    vgraacum_sdo_int,0,0,0,"",vgrastatus_cta,
                                    vgrasdo_actual,"0000"," ",vvalor_tasa,vgranum_tarjeta,"","",vfecha_operacion);
                        END IF
                    ELSE
                        LET vgraacum_sdo_int = vgraint_acum - vgraacum_sdo_int;

                        IF vgraacum_sdo_int > 0 THEN
                            INSERT INTO sc_movdia
                            VALUES (0,vfolio_suc,vgrasucursal,vgrausuario,vgrafecha_hoy,
                                    vgrafecha_hoy,vhora,vgratranrevprov,vgrasucursal,
                                    vgraproducto,pempresa,vgracuenta, "",0,vgraacum_sdo_int,
                                    vgraacum_sdo_int,0,0,0,"",vgrastatus_cta,
                                    vgrasdo_actual,"0000"," ",vvalor_tasa,vgranum_tarjeta,"","",vfecha_operacion);
                        END IF

                        LET vgraacum_sdo_int = vgraacum_sdo_int * -1;
                    END IF

                    LET vint_acum = vgraint_acum;
                    LET vgraint_acum = vgraacum_sdo_int;
                END IF
            -- // ACUMULA INTERESES
            ELSE    
                LET vgraacum_sdo_int = vgraacum_sdo_int + vtotint;
            END IF
        END IF

        -- // PAGO DE INTERESES

        -- // Solo es Monitoreo
        LET vgrafecha_pago   = vgrafecha_pago;
        LET vgraprox_fecha   = vgraprox_fecha;
        LET vgrapago_interes = vgrapago_interes;
        LET vgrafecha_hoy    = vgrafecha_hoy;
        
           -- // DIARIO
        IF vgrapago_interes = "D" OR 
           -- // MESIVERSARIO
           ((vgrapago_interes = "V" AND vgrafecha_pago >= vgrafecha_hoy AND vgrafecha_pago < vgraprox_fecha) AND (vgrafecha_alta <> vgrafecha_hoy)) OR
           -- // FECHA
           (vgrapago_interes = "F" AND vgrafecha_pago >= vgrafecha_hoy AND vgrafecha_pago < vgraprox_fecha) OR
           -- // MENSUAL
           (vgrapago_interes = "M" AND vgrafecha_hoy = vgrault_hab_mes) OR
           -- // TRIMESTRAL
           (vgrapago_interes = "T" AND vgrafecha_hoy = vgrault_hab_mes AND (vmes = "3" OR vmes = "6" OR vmes = "9" OR vmes = "12")) OR
           -- // SEMESTRAL
           (vgrapago_interes = "S" AND vgrafecha_hoy = vgrault_hab_mes AND (vmes = "6" OR vmes = "12")) OR
           -- // ANUAL
           (vgrapago_interes = "A" AND vgrafecha_hoy = vgrault_hab_mes AND vmes = "12")  THEN 

            LET vsdo_promedio = vgraacum_sdo_pos / vgradia_sdo_pos;
            LET vtotint = ((((vgraacum_sdo_pos / vgradia_sdo_pos) * vvalor_tasa) / vnumdias) * vgradia_sdo_pos);
            
            IF vtotint > 0 THEN
                INSERT INTO sc_movdia
                VALUES (0,vfolio_suc,vgrasucursal,vgrausuario,vgrafecha_hoy,
                        vgrafecha_hoy,vhora,vgratrans_pag_int,vgrasucursal,vgraproducto,
                        pempresa,vgracuenta, "",0,vtotint,vtotint,0,0,0,"","1",
                        vgrasdo_actual,"0000"," ",vvalor_tasa,vgranum_tarjeta,"","",vfecha_operacion);
						
				EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(vgrasucursal,vgracuenta,vgratrans_pag_int,vtotint,vgrafecha_hoy,"A")
				INTO cCodRetIndicador;

                LET vmaxsecuencia = 1;
                LET vMtoMeta = 0;

                IF vgraproducto = vgraProdCreciente THEN
				    LET vfecha_mod = vgrafecha_mod;
                    LET vfecha_mod = vfecha_mod - 1 UNITS DAY;

                    EXECUTE PROCEDURE "informix".sp_valfechabil(vfecha_mod, '-') 
                    INTO vcodret, vfecha_mod;

                    IF (vfecha_mod = vgrafecha_hoy) THEN
                        /* TRAE EL INTERES X TASA META */
                        SELECT int_acum, valor_tasa, isr, (fin_periodo - inicio_periodo)
                          INTO vMtoMeta, vvaltasa, visr_prem, vnumdias
                          FROM sc_tasa_variable
                         WHERE empresa = pempresa
                           AND cuenta = vgracuenta
                           AND fin_periodo = vgrafecha_mod
                           AND tipo_tasa = "P";
                           
                LET visr_prem = 0.00;

                        /* PROVISION DEL MONTO META */
                        INSERT INTO sc_movdia VALUES
                        (0, vfolio_suc, vgrasucursal, vgrausuario, vgrafecha_hoy, vgrafecha_hoy, vhora,
                         vgratranprov, vgrasucursal, vgraproducto, pempresa, vgracuenta, "", 0, vMtoMeta, vMtoMeta,
                         0, 0, 0, "", vgrastatus_cta, vgrasdo_actual, "0000", " ", vvalor_tasa, vgranum_tarjeta, "" ,"", vfecha_operacion);

                        /* CAPITALIZACION DEL MONTO META */
                        INSERT INTO sc_movdia VALUES
                        (0, vfolio_suc, vgrasucursal, vgrausuario, vgrafecha_hoy, vgrafecha_hoy, vhora,
                         vgratrans_pag_int, vgrasucursal, vgraproducto, pempresa, vgracuenta, "", 0, vMtoMeta, vMtoMeta,
                         0, 0, 0, "", vgrastatus_cta, vgrasdo_actual, "0000", " ", vvalor_tasa, vgranum_tarjeta, "" ,"", vfecha_operacion);
						 
						EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(vgrasucursal,vgracuenta,vgratrans_pag_int,vMtoMeta,vgrafecha_hoy,"A")
						INTO cCodRetIndicador;

                        /* RETENCION ISR DEL MONTO META */
                        IF visr_prem > 0 THEN
                            INSERT INTO sc_movdia VALUES
                            (0, vfolio_suc, vgrasucursal, vgrausuario, vgrafecha_hoy, vgrafecha_hoy, vhora,
                             vgratransisr, vgrasucursal, vgraproducto, pempresa, vgracuenta, "", 0, visr_prem, visr_prem,
                             0, 0, 0, "", vgrastatus_cta, vgrasdo_actual, "0000", " ", 0.0, vgranum_tarjeta, "", "", vfecha_operacion);
                             
                            /* REFERENCIA ISR DEL MONTO META */
                            SELECT valor 
                              INTO vtasa_isr
                              FROM bdinteg:si_fechavalor
                             WHERE empresa = pempresa 
                               AND tasa = "I.S.R." 
                               AND fecha IN( SELECT MAX(fecha) 
                                               FROM bdinteg:si_fechavalor
                                              WHERE empresa = pempresa 
                                                AND tasa = "I.S.R." );
                                                
                            INSERT INTO sc_isr VALUES
                            (pempresa, vgracuenta, vsecuencia, vgrasdo_actual, vvaltasa, vnumdias, vMtoMeta, 0, 0, visr_prem, vMtoMeta - visr_prem, vtasa_isr);
                        END IF
                        
                        LET vmaxsecuencia = 2;
                    END IF
                END IF
                UPDATE sc_maechq
                   SET (fec_ult_mov, num_abonos_mes, imp_abonos_mes, sdo_actual, ultpagoint, chq_exp_mes) =
                       (vgrafecha_hoy, num_abonos_mes + vmaxsecuencia, imp_abonos_mes + (vtotint + vMtoMeta), sdo_actual + ((vtotint + vMtoMeta) - visr_prem), vgrafecha_hoy, 0)
                 WHERE empresa = pempresa
                   AND cuenta = vgracuenta;

                LET vgrasdo_actual = (vgrasdo_actual + vtotint + vMtoMeta) - visr_prem;
            END IF

            -- // VERIFICAR SI COBRA ISR
            IF vgraexento_isr = "N" OR vgraexento_isr = "n" THEN
                IF vtotint > 0 THEN
                    IF vgraes_fisica = "S" THEN
                        LET vtipper = "F";
                    ELSE
                        LET vtipper = "M";
                    END IF

                    LET vgradia_sdo_pos = vgradia_sdo_pos;

                    CALL calc_isr(pempresa,vgracuenta,vgrafecha_hoy,vvaltasa,vtotint,vsdo_promedio,vgradia_sdo_pos,vtipper)
                    RETURNING vcodret,visr;

                    IF visr > 0 THEN
                        CALL cargocie_qra(pempresa,vgrasucursal,vgrausuario,vgratransisr,vtransuc,vfolio_suc,vgracuenta,vcero,visr)
                        RETURNING vcodret;

                        UPDATE sc_maenoc
                           SET isr_acum = isr_acum + (visr + visr_prem)
                         WHERE empresa = pempresa
                           AND cuenta = vgracuenta;

                        -- // RESTA EL IMPORTE DE LA RETENCION ISR AL SALDO ACTUAL
                        LET vgrasdo_actual = vgrasdo_actual - visr ;
                    END IF
                END IF
            ELSE
                LET visr = 0;
                
                -- // GRABA LA CUENTA SIN RETENCION DE ISR
                --- INSERT INTO sc_isr VALUES
                --- (pempresa, vgracuenta, vsecuencia, psdo_prom, vvaltasa, vgradias_acum_int, vtotint, 0, 0, 0, vtotint);
            END IF

            LET vimporte = vtotint - visr;

            IF vimporte > 0 THEN
                SELECT instrucc,sistema,cuentadep
                  INTO vinstrucc,vsistema,vcuentadep
                  FROM sc_maeinstrucc
                 WHERE empresa = pempresa
                   AND cuenta = vgracuenta
                   AND capint = "I";

                IF vinstrucc IS NULL THEN
                    LET vinstrucc = "01";
                END IF

                IF vinstrucc <> "01" THEN
                    IF vsistema = "01" AND vcuentadep <> "" THEN
                        INSERT INTO sc_movdia
                        VALUES (0,vfolio_suc,vgrasucursal,vgrausuario,vgrafecha_hoy,
                                vgrafecha_hoy,vhora,vgratranabotrasp,vgrasucursal,
                                vgraproducto,pempresa,vcuentadep, "",0,vimporte,
                                vimporte,0,0,0,"","1",vgrasdo_actual,"0000"," ",
                                vvaltasa,vgranum_tarjeta,"","",vfecha_operacion);
                    END IF

                    UPDATE sc_maeinstrucc
                       SET aplicado = "S"
                     WHERE empresa = pempresa
                       AND cuenta = vgracuenta
                       AND capint = "I";

                    SELECT trans_int
                      INTO vtrancarint
                      FROM sc_instrucc
                     WHERE empresa = pempresa
                       AND instrucc = vinstrucc;

                    INSERT INTO sc_movdia
                    VALUES (0,vfolio_suc,vgrasucursal,vgrausuario,vgrafecha_hoy,
                            vgrafecha_hoy,vhora,vtrancarint,vgrasucursal,vgraproducto,
                            pempresa,vgracuenta, "",0,vimporte,vimporte,0,0,0,"",
                            "1",vgrasdo_actual,"0000"," ",vvaltasa,vgranum_tarjeta,"","",vfecha_operacion);

                    UPDATE sc_maechq
                       SET (num_cgos_mes,imp_cgos_mes,sdo_actual) =
                           (num_cgos_mes + 1,imp_cgos_mes + vimporte,sdo_actual - vimporte)
                     WHERE empresa = pempresa
                       AND cuenta = vgracuenta;
                END IF
            END IF

            -- Inicializa el Contador de Cheques Expedidos
            UPDATE sc_maechq
               SET chq_exp_mes = 0
             WHERE empresa = pempresa
               AND cuenta = vgracuenta;
            
            IF vgrapago_interes = "V" THEN
                UPDATE sc_maenoc
                   SET int_acum        = 0,
                       dias_acum_int   = 0,
                       acum_sdo_int    = 0,
                       dia_sdo_pos     = 0,
                       acum_sdo_pos    = 0,
                       acum_sbc        = 0,
                       acum_rem        = 0,
                       sdo_mes_ant     = vgrasdo_actual,
                       sdo_prom_mesant = vsdo_promedio,
                       ret_mes_ant     = vgrasdo_retenido,
                       cong_mes_ant    = vgrasdo_cong
                 WHERE empresa = pempresa
                   AND cuenta = vgracuenta;
            END IF;

            -- // VALIDA SI LA CUENTA ESTA BLOQUEADA
            LET vsdocong = 0;

            IF vgrastatus_cta = "3" AND vtotint > 0 THEN
                SELECT motivo
                  INTO vmotivo
                  FROM sc_maechq
                 WHERE empresa = pempresa
                   AND cuenta = vgracuenta;

                SELECT abono
                  INTO vaceptab
                  FROM sc_bloqueo
                 WHERE codigo = vmotivo;

                SELECT opcion
                  INTO vopcion
                  FROM sc_ctabloqueo
                 WHERE cuenta = vgracuenta;

                IF ((vaceptab = "N" AND vmotivo <> '99') OR (vopcion = 4 OR vopcion = 2)) THEN
                    LET vsdocong = vtotint - visr;
                    LET vmesdia = MONTH(vgrafecha_hoy) + DAY(vgrafecha_hoy);
                    LET vclave = vmesdia + vhoraw;
                    LET vsdodisp = vgrasdo_actual;

                    INSERT INTO sc_histbloq (empresa,cuenta,tipo_mov,motivo,opcion,importe,usuario,fecha,hora,clave,status_blo,folio_suc,referencia)  
                    VALUES (pempresa,vgracuenta,"B",vmotivo,vopcion,vsdocong,
                            vgrausuario,vgrafecha_hoy,vhora,vclave,"B",vfolio_suc,
                            "BLOQUEO POR PAGO DE INTERES");

                    INSERT INTO sc_movdia
                    VALUES (0,vfolio_suc,vgrasucursal,vgrausuario,vgrafecha_hoy,
                            vgrafecha_hoy,vhora,"3353",vgrasucursal,vgraproducto,
                            pempresa,vgracuenta,"",0, vsdocong,vsdocong,0,0,0,"",
                            "1",vsdodisp,"0000"," ",0,vgranum_tarjeta,"","",vfecha_operacion);
                ELSE
                    LET vsdocong = 0;
                END IF
            END IF

            IF vgrapago_interes = "V" THEN
                CALL crea_maehisqra(pempresa, vgracuenta, vgrafecha_pago, vgrafecha_alta, vgraacum_sdo_pos, vgradia_sdo_pos)
                RETURNING vcodret;

                IF vdia = 1 AND vgrafecha_hoy = '12'||'31'||YEAR(vgrafecha_hoy) THEN
                    LET vdias_prom = pdias - 1;
                    LET vsdo_promedio = vgraacum_sdo_pos / vgradia_sdo_pos;
                    LET vintdia = (((vsdo_promedio * vvalor_tasa) / vnumdias) * vdias_prom);
                    LET vgraacum_sdo_int = vintdia;
                    LET vgraacum_sdo_pos = vgrasdo_actual;
                    LET vgradias_acum_int = vdias_prom;
                    LET vgradia_sdo_pos = vdias_prom;
                    LET vgraint_acum = 0;
                ELSE
                    LET vgraacum_sdo_int = 0;
                    LET vgraacum_sdo_pos = 0;
                    LET vgradias_acum_int = 0;
                    LET vgradia_sdo_pos = 0;
                    LET vgraint_acum = 0;
                END IF
                
            END IF
            
        END IF
        
    END IF
    
    --- SET LOCK MODE TO WAIT 2;

    RETURN vcodret;

    END

END PROCEDURE;