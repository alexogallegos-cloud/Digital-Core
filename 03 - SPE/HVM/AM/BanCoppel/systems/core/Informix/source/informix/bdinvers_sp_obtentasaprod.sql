CREATE PROCEDURE "informix".sp_obtentasaprod( pempresa CHAR(3), 
                                              psucursal CHAR(4), 
                                              pproducto CHAR(4), 
                                              pultreg SMALLINT )
RETURNING CHAR(5),      --- 1.- codigo retorno
          SMALLINT,     --- 2.- plazo minimo
          SMALLINT,     --- 3.- plazo maximo
          DECIMAL(4,2), --- 4.- valor de la tasa
          DECIMAL(4,2); --- 5.- tipo tasa -- Quitar Ocoyuuussss!!! Agregar Tasa PM
    
    DEFINE vtasa_nom char(8);
    DEFINE vfecha_tmp date;
    DEFINE vinicial smallint;
    DEFINE vfinal smallint;
    DEFINE vtasa decimal(4,2);
    DEFINE vtasapm decimal(4,2);
    DEFINE vplaza char(3);
    DEFINE vclave_tasa char(8);
    DEFINE vcont smallint;

    LET vtasa_nom = "";
    LET vfecha_tmp = "";
    LET vinicial = 0;
    LET vfinal = 0;
    LET vtasa = 0;
    LET vplaza = "";
    LET vtasapm = 0;
    LET vclave_tasa = "";
    LET vcont = 0;
    
    BEGIN
    
    SET ISOLATION TO DIRTY READ;

    -- // BUSCO SI EL PRODUCTO ES DE CHEQUES (CUENTA CRECIENTE)
    IF EXISTS(SELECT * FROM bdicheq:sc_param WHERE empresa = pempresa AND codparam = "PRODCREC" AND valor = pproducto) THEN
        
        SELECT tasa 
          INTO vtasa_nom
          FROM bdicheq:sc_producto
         WHERE empresa = pempresa
           AND producto = pproducto;
        
        SELECT max(fecha) 
          INTO vfecha_tmp
          FROM bdinteg:si_tasa_mes
         WHERE tasa = vtasa_nom
           AND mes > 0 
           AND tipo_tasa IN('M','P');
        
        IF vfecha_tmp IS NULL THEN
            RETURN "00138",vinicial,vfinal,vtasa,vtasapm;
        END IF
        
        FOREACH
            SELECT mes,mes,valor_tasa
              INTO vinicial,vfinal,vtasa
              FROM bdinteg:si_tasa_mes
             WHERE tasa = vtasa_nom 
               AND mes > 0
               AND tipo_tasa IN('M','P')
               AND fecha = vfecha_tmp
             ORDER BY mes

            RETURN "00000",vinicial,vfinal,vtasa,vtasapm WITH RESUME;
        END FOREACH

    -- // BUSCO SI EL PRODUCTO ES DE INVERSIONES (PAGARE)
    ELIF EXISTS(SELECT * FROM bdinvers:sv_instrum WHERE cod_instrum = pproducto) THEN
        
        SELECT plaza 
          INTO vplaza
          FROM bdinteg:si_sucursales
         WHERE sucursal = psucursal;
        
        IF vplaza IS NULL THEN
            RETURN "00112",vinicial,vfinal,vtasa,vtasapm;
        END IF
        
        FOREACH
            SELECT plazo_min,plazo_max,tasa
              INTO vinicial,vfinal,vclave_tasa
              FROM bdinvers:sv_plazotasa
             WHERE empresa = pempresa
               AND cod_instrum = pproducto
               AND plaza = vplaza 
             ORDER BY plazo_min
            
            SELECT valor 
              INTO vtasa
              FROM bdinteg:si_fechavalor
             WHERE empresa = pempresa 
               AND tasa = vclave_tasa
               AND fecha IN(SELECT MAX(fecha) 
                              FROM bdinteg:si_fechavalor 
                             WHERE empresa = pempresa 
                               AND tasa = vclave_tasa);

            LET vcont = vcont + 1;
            
            -- // Solo Regresa los que le pido
            IF vcont <= pultreg THEN
                CONTINUE FOREACH;
            ELSE
                RETURN "00000",vinicial,vfinal,vtasa,vtasapm  WITH RESUME;
            END IF
        END FOREACH

        IF vcont = 0  THEN
            RETURN "00138",vinicial,vfinal,vtasa,vtasapm;
        END IF
        
    -- // SI NO EXISTE EL PRODUCTO
    ELSE
        RETURN "00105",vinicial,vfinal,vtasa,vtasapm;
    END IF

    END;
    
END PROCEDURE;