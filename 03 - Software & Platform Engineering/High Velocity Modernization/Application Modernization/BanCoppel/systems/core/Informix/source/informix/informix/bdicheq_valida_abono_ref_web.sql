CREATE PROCEDURE "informix".valida_abono_ref_web( pempresa     CHAR(3),
                                       psucursal    CHAR(4),
                                       pusuario     CHAR(8),
                                       ptransacc    CHAR(4),
                                       ptransuc     CHAR(4),                                   
                                       pcuenta      CHAR(20),
                                       pmto_tot     MONEY(14,2),
                                       pdias_ret    SMALLINT)
RETURNING CHAR(5);
    
    -- ********************************************************************
    -- Nombre:              valida_abono_ref
    -- Version:             1.0.0
    -- Objetivo:            Valida Limites de deposito 204 y 209
    -- Supuestos:           Ninguno
    -- Creado por:          Concepcion Alvarez Carrillo
    -- Ultima Modificacion: Enero 2016
    -- ********************************************************************

    DEFINE vcodret              CHAR(5);
    DEFINE vcodret2             CHAR(5);
    DEFINE vcodret3             CHAR(50);
    DEFINE vsqlerr              INTEGER;
    DEFINE visamerr             INTEGER;
    DEFINE vdescerr             CHAR(50);
    DEFINE vsuccta              CHAR(4);
    DEFINE vproducto            CHAR(4);
    DEFINE vvaldoc              CHAR(1);
    DEFINE vnat                 CHAR(1);
    DEFINE vstatus              CHAR(1);
    DEFINE vfecha_hoy           DATE;
    DEFINE vfecha_prox          DATE;
    DEFINE vfecha_sistema       DATE;
    DEFINE vnumcte              CHAR(20);
    DEFINE vtransaccion         INTEGER;
    DEFINE vestado_oper         CHAR(2);
    DEFINE vestado_cta          CHAR(2);
    DEFINE vmonto_acum          DECIMAL(18,2);
    DEFINE vmonto_perm          DECIMAL(16,2);
    DEFINE vtpo_per_valida      CHAR(1);
    DEFINE vlimdepefec          DECIMAL(18,2);
    DEFINE vmtodepacum          DECIMAL(18,2);
    DEFINE vCteExcluido         CHAR(20);
    DEFINE vlimdepinterpza      DECIMAL(18,2);
    DEFINE vind_dispon          CHAR(1);
    DEFINE vSQL                 CHAR(10);
    DEFINE vTpoValidacion       CHAR(1);
    DEFINE iNoTrxsPerm          INTEGER;
    DEFINE iNoTrxsHechas        INTEGER;
    DEFINE vpri_dia_mes         DATE;

    LET vcodret         = "00000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
    LET vtransaccion    = 0;
    LET vmonto_acum     = 0;
    LET vmonto_perm     = 0;
    LET vtpo_per_valida = '';
    LET vlimdepefec     = 0.00;
    LET vmtodepacum     = 0.00;
    LET vCteExcluido    = '';
    LET vlimdepinterpza = 0.00;
    LET vind_dispon     = '0';
    LET vSQL            = '';
    LET vTpoValidacion  = '';
    LET iNoTrxsPerm     = 0;
    LET iNoTrxsHechas   = 0;
    LET vpri_dia_mes    = '';
   
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        --SET DEBUG FILE TO "/tmp/abono_ref.err";
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
    
    --- SET DEBUG FILE TO "/tmp/abono_ref.out";
    --- TRACE ON;
    
    --  PARA CUENTAS DEL BANCO
 
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            BEGIN WORK;
        END IF;
                
        --  Valida la informacion de entrada
        IF psucursal  = "" OR pusuario   = "" OR 
           ptransacc  = "" OR pcuenta    = "" OR 
		   pdias_ret  < 0  THEN
            LET vcodret = '00110';
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN vcodret;
        END IF;
        
        --  Obtiene fechas del sistema de cheques
        SELECT {+INDEX(sc_fechas idx_fechas1)} 
               fecha_hoy, prox_fecha, fecha_hoy, ind_disponible, pri_dia_mes
          INTO vfecha_hoy, vfecha_prox, vfecha_sistema, vind_dispon, vpri_dia_mes
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
                
        --  Valida que exista la transaccion de abono
        SELECT naturaleza, valida_docto, dias_ret
          INTO vnat, vvaldoc, pdias_ret
          FROM bdinteg:si_transacc
         WHERE empresa = pempresa 
           AND numero = ptransacc
           AND sistema = '01'
           AND naturaleza = 'A';
        
        IF vnat IS NULL THEN
            LET vcodret = "00552";
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN vcodret;
        END IF;
        
        --  Valida que la naturaleza sea de abono
        IF vnat != "A" THEN
            LET vcodret = "00552";
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN vcodret;
        END IF;
        
        --  Inicializa los dias de retencion
        IF pdias_ret IS NULL THEN
            LET pdias_ret = 0;
        END IF;
        
        -- Valida exista la cuenta
        SELECT status_cta, fecha_proceso, producto, sucursal, num_cte
          INTO vstatus, vfecha_hoy, vproducto, vsuccta, vnumcte
          FROM sc_maechq
         WHERE empresa = pempresa 
           AND cuenta = pcuenta;
           
        SELECT tpper_valida
          INTO vtpo_per_valida
          FROM sc_producto
         WHERE producto = vproducto;
        
        IF vproducto = '2300' AND ptransacc = '0202' THEN
           LET vcodret = '00100';
           RETURN vcodret;
        END IF
        
        IF vproducto = '2800' AND ptransacc = '0202' THEN
           LET vcodret = '00403';
           RETURN vcodret;
        END IF
           
        IF vstatus IS NULL THEN
            LET vcodret = "00100";
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

        --  Valida que la cuenta no este cancelada
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
        
        --  Valida cuentas inactivas
        IF vstatus IN("4","5") THEN
            LET vfecha_hoy = vfecha_sistema;
        END IF

        --  Trae la fecha del dia de hoy en cheques...
        IF vfecha_hoy IS NULL THEN
            LET vfecha_hoy = vfecha_sistema;
        END IF
  
      --  SOLICITUD DE EXCEPCION PARA OMITIR VALIDACIONES DE CONTROL DE DEPOSITOS EN EFECTIVO
        SELECT COUNT(1)
          INTO vCteExcluido
          FROM sc_exentos_dep_efec
         WHERE num_cte = vnumcte;
        
        IF vCteExcluido = 0 THEN
            
            IF ptransacc = '0202' AND vtpo_per_valida IN('1','3') AND vproducto <> '1100' THEN
                    
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

            /*
            SELECT estado
              INTO vestado_oper
              FROM bdinteg:si_sucursales
             WHERE sucursal = psucursal;
            */
             
            SELECT cve_estado
              INTO vestado_cta
              FROM bdinteg:si_ptf
             WHERE id_ptf = vsuccta 
               AND tipo = 'S'; 

            /*
            SELECT estado
              INTO vestado_cta
              FROM bdinteg:si_sucursales
             WHERE sucursal = vsuccta;
            */
             
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
            END IF;
        END IF;
            
            
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

				/*
				SELECT estado
				  INTO vestado_oper
				  FROM bdinteg:"informix".si_sucursales
				 WHERE sucursal = psucursal;
				*/
				 
				SELECT cve_estado
				  INTO vestado_cta
				  FROM bdinteg:"informix".si_ptf
				 WHERE id_ptf = vsuccta 
				   AND tipo = 'S';
				  
				/*
				SELECT estado
				  INTO vestado_cta
				  FROM bdinteg:"informix".si_sucursales
				 WHERE sucursal = vsuccta;
				*/
                 
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
                    IF ( ( SELECT COUNT(1) FROM sc_limitedeposito WHERE sucursal = psucursal ) > 0 ) THEN  
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
                SELECT COUNT(1), SUM(monto) 
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
            END IF;    
        END IF;

        IF vcodret = "00000" THEN
            IF vtransaccion = 1 THEN
                COMMIT WORK;
                BEGIN WORK;
            ELSE
                COMMIT WORK;
            END IF;
           
        ELSE
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
        END IF
    
    RETURN vcodret;
    
    END;
END PROCEDURE
DOCUMENT
'AUTOR:	      Concepcion Alvarez Carrillo',
'FECHA:	      enero/2016',
'DESCRIPCION: Se consulta los limites de deposito de la transaccion 204 y 209',
'VERSION:     1.0',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_proyeccionsc_web( pempresa CHAR(3),
                                             psucursal CHAR(4),
                                             pusuario CHAR(8),
                                             pproducto CHAR(4),
                                             pmonto MONEY(14,2),
                                             pInstruc CHAR(2) )
RETURNING CHAR(5), DATE, DATE, DECIMAL(4,2), MONEY(14,2), 
          DECIMAL(4,2), MONEY(14,2), MONEY(14,2), DECIMAL(9,6);

    -- ############################################################################################################################################################
    -- sp_proyeccionsc
    -- Version              1.0.0
    -- Objetivo:            Obtener la proyeccion de una cuenta de cheques tasa variable
    -- Supuestos:           Ninguno
    -- Creado por:
    -- Modificado por:      Alejandro Rueda Sanchez
    -- Ultima Modificacion: Enero - 2009
    -- Modificado por:      JesÃÂºs Manuel Aguilar Heredia
    -- Descripcion del cambio: Se agrego paarametro de entrada al procedimiento con el cual se recibira la instruccion de proyeccion, 
    --                         para los casos 01,02 se deja la misma funcionalidad del procedimiento y Se valida que cuando 
    --                         sea el tipo de instruccion sea 03 ÃÂ³  04 no se sume el interes al capital, y validar que para estas dos opciones 
    --                         el monto sea mayor a 50,000, monto obtendido de un prametro.
    --                         Ademas se le realiza la adecuacion al procedimiento para que cumpla las reglas de informix, 
    --                         por lo cual se le eliminaron algunas variables que no se utilizan, tales como:vferiado,vfecha_tmp1,vfecha_tmp2,vdia_sig,vacumulado
    --                         y se corrigio el nombrado de las variables para cumplir con el standar de programacion.
    -- Fecha de modificacion: 24-Mayo-2011
    -- ############################################################################################################################################################
    
    DEFINE cCodret     CHAR(5);
    DEFINE iSqlerr     INTEGER;
    DEFINE dtFecha_ini  DATE;
    DEFINE dtFecha_fin  DATE;
    DEFINE dtFecha_tmp  DATE;
    DEFINE dtFecha_hoy  DATE;
    DEFINE cMes        CHAR(2);
    DEFINE dTasa       DECIMAL(4,2);
    DEFINE mMonto_int  MONEY(14,2);
    DEFINE dTasa_tot   DECIMAL(4,2);
    DEFINE mMonto_tot  MONEY(14,2);
    DEFINE icontador   SMALLINT;
    DEFINE sDias       SMALLINT;
    DEFINE cTipo_calc  CHAR(1);
    DEFINE cTasa_nom   CHAR(8);
    DEFINE sDia_aper   SMALLINT;
    DEFINE cTipo_tasa  CHAR(1);
    DEFINE mIsr        MONEY(14,2);
    DEFINE dTisr       DECIMAL(9,6);
    DEFINE sNumdias    SMALLINT;
    DEFINE mAnualisr   MONEY(14,2);
    DEFINE dValor      DECIMAL(14,2);

    ON EXCEPTION SET iSqlerr
        IF iSqlerr <> 0 THEN
            LET cCodret = iSqlerr;
            RETURN cCodret,NULL,NULL,0,0,0,0, 0, 0;
        END IF
    END EXCEPTION;
    
     --set debug file to "/pisa/pisabanco/pisa_ftes/sp_proyeccionsc.out";
     --trace on;
    
    LET cCodret    = "00000";
    LET dtFecha_ini = "";
    LET dtFecha_fin = "";
    LET cMes       = "";
    LET dTasa      = 0;
    LET mMonto_int = 0;
    LET dTasa_tot  = 0;
    LET mMonto_tot = pmonto;
    LET dtFecha_tmp = "";
    LET dtFecha_hoy = "";
    LET sDias      = 0;
    LET cTipo_calc = "";
    LET dTasa      = "";
    LET cTasa_nom  = "";
    LET sDia_aper  = 0;
    LET cTipo_tasa = "";
    LET mIsr       = 0;
    LET dTisr      = 0;
    LET sNumdias   = 0;
    LET mAnualisr  = 0;
    LET dValor     = 0;
    LET icontador = 1;
    
    IF Trim(pproducto) = "" OR pmonto = 0 OR NVL(pInstruc,"") = "" THEN
        LET cCodret = "00110";
        RETURN cCodret,dtFecha_ini,dtFecha_fin,dTasa,mMonto_int,dTasa_tot,mMonto_tot,mIsr, dTisr;
    END IF;
    
    IF pInstruc IN("03","04") THEN
        SELECT valor
          INTO dValor
          FROM bdicheq:"informix".sc_param
         WHERE empresa = pempresa
           AND codparam = "INSVTOINVCRE";

        IF pmonto < dValor THEN
            LET cCodret = "00111";
            RETURN cCodret,dtFecha_ini,dtFecha_fin,dTasa,mMonto_int,dTasa_tot,mMonto_tot,mIsr, dTisr;
        END IF;  
    END IF;

    -- // Extrae las Caracteristicas del Producto
    SELECT tipo_anio_calc,tasa
      INTO cTipo_calc,cTasa_nom
      FROM bdicheq:"informix".sc_producto
     WHERE producto = pproducto
       AND empresa = pempresa;

    -- // Obtiene la fecha del Sistema de Captacion
    SELECT fecha_hoy 
      INTO dtFecha_hoy 
      FROM bdicheq:"informix".sc_fechas;

    LET sDia_aper = DAY(dtFecha_hoy);

    SELECT MAX(fecha)
      INTO dtFecha_tmp
      FROM bdinteg:"informix".si_tasa_mes;

    LET dtFecha_ini = dtFecha_hoy;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    FOREACH
        SELECT mes,valor_tasa,tipo_tasa
          INTO cMes,dTasa,cTipo_tasa
          FROM bdinteg:"informix".si_tasa_mes
         WHERE fecha = dtFecha_tmp
           AND tasa = cTasa_nom
         ORDER BY mes::SMALLINT

        LET icontador = cMes::SMALLINT;

        IF icontador = 13  THEN
            CALL "informix".sp_mes_siguiente(dtFecha_hoy, icontador - 1  ,sDia_aper) RETURNING cCodret, dtFecha_fin, sNumdias;
        ELSE
            CALL "informix".sp_mes_siguiente(dtFecha_ini, 1 ,sDia_aper) RETURNING cCodret, dtFecha_fin, sNumdias;
            
            IF sNumdias > 40 THEN
                CALL "informix".sp_mes_siguiente(dtFecha_ini, 0 ,sDia_aper) RETURNING cCodret, dtFecha_fin, sNumdias;
            END IF
        END IF

        LET sDias = sNumdias;
        
        -- // Aqui esta la Modificacion del Calculo de Intereses
        IF pInstruc IN("03","04") THEN --- se agrega validacion para que cuando sean estos tipos de instruccion, el interes no se sume al capital.
            LET pmonto = pmonto-mIsr;
        ELSE
            LET pmonto = pmonto + mMonto_int - mIsr;
        END IF;

        -- // Aqui Termina la Modificacin ALE Realizada por MEL 17 Enero 2009
        CALL "informix".calc_isr_proy(pempresa, "0000000", dtFecha_hoy, sDias, mMonto_int, pmonto, sDias, "S")
        RETURNING cCodret, mIsr, dTisr;

        -- // Calcula los Intereses
        IF cTipo_calc = "1" THEN
            LET mMonto_int = pmonto * (dTasa/100) / 360 * sDias;
        ELSE
            LET mMonto_int = pmonto * (dTasa/100) / 365 * sDias;
        END IF

        -- // Calcula los Intereses META
        IF cTipo_tasa = "P" THEN
            LET dtFecha_ini = dtFecha_hoy;

            IF cTipo_calc = "1" THEN
                LET mMonto_int = mMonto_tot * (dTasa/100) / 360 * sDias;
                LET dTasa_tot = dTasa;
            ELSE
                LET mMonto_int = mMonto_tot * (dTasa/100) / 365 * sDias;
                LET dTasa_tot = dTasa;
            END  IF

            LET mIsr = mAnualisr;
        ELSE  -- // Calcula Intereses Acumulados
            LET mAnualisr = mAnualisr + mIsr;
        END IF;

        RETURN cCodret,dtFecha_ini,dtFecha_fin,dTasa,mMonto_int,dTasa_tot,mMonto_tot, mIsr, dTisr WITH RESUME;
        
        LET dtFecha_ini = dtFecha_fin;
    END FOREACH
    
END PROCEDURE DOCUMENT "Version 1.00.000";

create procedure "informix".tasa() returning decimal(9,6);
define v_fecha_tiie date;
define v_tasa_sbc decimal(9,6);

        select max(fecha) into v_fecha_tiie
                from bdinteg:si_fechavalor
                where codigo="TIIE";

        select valor into v_tasa_sbc 
                from bdinteg:si_fechavalor 
                where codigo="TIIE"
                and fecha=v_fecha_tiie;

        if v_tasa_sbc is null then 
                let v_tasa_sbc=10;
        end if;
return v_tasa_sbc;
end procedure;