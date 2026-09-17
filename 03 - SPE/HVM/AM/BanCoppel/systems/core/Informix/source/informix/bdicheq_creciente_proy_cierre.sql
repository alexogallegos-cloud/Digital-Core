CREATE PROCEDURE "informix".creciente_proy_cierre( pempresa  CHAR(3),
                                                   pcuenta   CHAR(20),
                                                   pproducto CHAR(4),
                                                   pmonto    MONEY(14,2),
                                                   pinstrucc CHAR(2) )
returning CHAR(5);

    -- ##################################################################################
    -- creciente_proy_cierre
    -- Version              1.0.0
    -- Objetivo:            Registra la proyeccion de una cuenta de cheques en el cierre
    -- Supuestos:           Ninguno
    -- Creado por:
    -- ModIFicado por:      Alejandro Rueda Sanchez
    -- Ultima Modificacion: Abril - 2008
    --                      Creación de SPL
    -- ##################################################################################

    -- // Definicion de variables
    DEFINE vcodret     CHAR(5);
    DEFINE vsucursal   CHAR(4);
    DEFINE vusuario    CHAR(8);
    DEFINE vtasatotal  DECIMAL(4,2);
    DEFINE vfecha_ini  DATE;
    DEFINE vfecha_fin  DATE;
    DEFINE vfecha_hoy  DATE;
    DEFINE vtasa       DECIMAL(4,2);
    DEFINE vmonto_int  MONEY(14,2);
    DEFINE vmonto_tot  MONEY(14,2);
    DEFINE i           SMALLINT;
    DEFINE vtipo_tasa  CHAR(1);
    DEFINE vmontoprom  DECIMAL(14,2);
    DEFINE vtisr	      DECIMAL(9,6);
    DEFINE sql_err     INTEGER;
    DEFINE vint_acum   DECIMAL(14,2);

    -- // Inicializacion de Variables
    LET vcodret    = "000";
    LET vsucursal  = "0000";
    LET vusuario   = "informix";

    LET vfecha_ini = "";
    LET vfecha_fin = "";
    LET vtasa      = 0;
    LET vmonto_int = 0;
    LET vmontoprom = 0;
    LET vmonto_tot = pmonto;
    LET vfecha_hoy = "";
    LET vtasa      = "";
    LET vtipo_tasa = "";
    LET vtisr      = 0;
    LET sql_err    = 0;
    
    BEGIN
        
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET vcodret = sql_err;
            RETURN vcodret ;
        END IF;
    END EXCEPTION;
    
    --- set debug file to "creciente_proy_cierre.out";
    --- trace on;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;
    
    IF TRIM(pproducto) = "" or pmonto = 0 THEN
        LET vcodret = "110";
        RETURN vcodret;
    END IF

    LET i = 1;
    LET vint_acum = 0;

    FOREACH
        EXECUTE FUNCTION sp_proyeccionsc(pempresa, vsucursal, vusuario, pproducto, pmonto, pinstrucc)
        INTO vcodret,vfecha_ini,vfecha_fin, vtasa, vmonto_int, vtasatotal, vmonto_tot, vmontoprom, vtisr
        
        IF trim(vcodret) <> "000" THEN
            RETURN vcodret;
        END IF;
        
        SELECT tipo_tasa
          INTO vtipo_tasa
          FROM bdinteg:si_tasa_mes
         WHERE valor_tasa = vtasa
           AND mes = i;
            
        IF vtipo_tasa <> "P" THEN
            LET vint_acum = vint_acum + vmonto_int;
        ELSE
            LET vmonto_int = vmonto_int - vint_acum;
        END IF
        
        INSERT INTO sc_tasa_variable (empresa, cuenta, inicio_periodo, fin_periodo, tipo_tasa, valor_tasa, int_acum, isr, tasa_isr)
        VALUES (pempresa, pcuenta, vfecha_ini, vfecha_fin, vtipo_tasa, vtasa, vmonto_int, vmontoprom, vtisr);
        
        LET i = i +1;
    END FOREACH;

    UPDATE sc_maenoc
       SET fecha_mod = vfecha_fin
     WHERE empresa = pempresa
       AND cuenta = pcuenta;

    END;
    
    RETURN vcodret;
    
END PROCEDURE;