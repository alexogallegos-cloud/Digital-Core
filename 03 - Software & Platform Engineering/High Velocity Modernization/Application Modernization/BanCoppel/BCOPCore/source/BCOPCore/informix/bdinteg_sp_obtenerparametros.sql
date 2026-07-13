CREATE PROCEDURE "informix".sp_obtenerparametros(p_iCodParam INTEGER, p_sEmpresa CHAR(3))
RETURNING CHAR(50) AS descripcion,
          CHAR(100) AS valor;
        
    DEFINE v_sDescripcion 	CHAR(50);
    DEFINE v_sValor			CHAR(100);
    DEFINE vparam_min       SMALLINT;
    DEFINE vparam_max       SMALLINT;
    
    LET v_sDescripcion = '';
    LET v_sValor       = '';
    LET vparam_min     = 0;
    LET vparam_max     = 0;

    --- Creado por Erick Zamora 17/12/2008

    --- SET DEBUG FILE TO "/tmp/sp_obtenerParametros.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;

    BEGIN
    
    SELECT {+FULL} MIN(cod_param), MAX(cod_param)
      INTO vparam_min, vparam_max
      FROM bdinteg:si_param;
    
    IF p_iCodParam is null OR p_iCodParam = '' THEN
        FOREACH
            SELECT {+INDEX(bdinteg:si_param ix_si_param)} descripcion, valor
              INTO v_sDescripcion, v_sValor
              FROM bdinteg:si_param
             WHERE cod_param BETWEEN vparam_min AND vparam_max --- NVL(p_iCodParam,cod_param)
               AND empresa = p_sEmpresa

            RETURN v_sDescripcion, v_sValor WITH RESUME;
        END FOREACH;
    ELSE
        FOREACH
            SELECT {+INDEX(bdinteg:si_param ix_si_param)} descripcion, valor
              INTO v_sDescripcion, v_sValor
              FROM bdinteg:si_param
             WHERE cod_param = p_iCodParam --- NVL(p_iCodParam,cod_param)
               AND empresa = p_sEmpresa

            RETURN v_sDescripcion, v_sValor WITH RESUME;
        END FOREACH;
    END IF;
    
    END;
    
END PROCEDURE;