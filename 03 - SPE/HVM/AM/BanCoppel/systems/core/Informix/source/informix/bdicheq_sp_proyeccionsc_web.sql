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