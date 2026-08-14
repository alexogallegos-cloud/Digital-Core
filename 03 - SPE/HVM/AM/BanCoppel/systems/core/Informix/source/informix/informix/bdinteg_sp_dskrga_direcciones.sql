CREATE PROCEDURE "informix".sp_dskrga_direcciones( )
RETURNING CHAR(5), CHAR(5);

    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE vcomienza1   SMALLINT;  
    DEFINE vcomienza2   SMALLINT;  
    DEFINE vcomienza3   SMALLINT;  
    DEFINE vcontador1   INTEGER;
    DEFINE vcontador2   INTEGER;
    
    DEFINE vctemin          CHAR(20);
    DEFINE vctemax          CHAR(20);
    DEFINE vnumcte          CHAR(20);
    DEFINE vsecuencia_max   SMALLINT;
    DEFINE vsql             CHAR(300);
    
    LET vcodret1    = '000';
    LET vcodret2    = '000';
    LET sql_err	    = 0;
    LET isam_err    = 0;
    LET vcomienza1  = -1;
    LET vcomienza2  = -1;
    LET vcomienza3  = -1;
    LET vcontador1  = 0;
    LET vcontador2  = 0;
    
    LET vctemin        = '';
    LET vctemax        = '';
    LET vnumcte        = '';
    LET vsecuencia_max = 0;
    LET vsql           = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_dskrga_direcciones.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            RETURN vcodret1, vcodret2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_dskrga_direcciones.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  
                WHERE partnum > 0 AND tabname = 'ultimas_direcciones') THEN
        DROP TABLE "informix".ultimas_direcciones;        
    END IF;
    
    CREATE RAW TABLE "informix".ultimas_direcciones(
        numcte               char(20),
        secuencia            integer,
        tipo_dir             char(1),
        calle                char(40),
        colonia              char(60),
        entre_calles         char(40),
        pais                 char(3),
        estado               char(2),
        ciudad               char(3),
        municipio            char(5),
        cod_postal           char(5),
        apart_postal         char(11),
        tipo_telef1          char(1),
        telefono1            char(13),
        tipo_telef2          char(1),
        telefono2            char(13),
        tipo_telef3          char(1),
        telefono3            char(13),
        extension            char(5),
        estado_inegi         char(2),
        municipio_inegi      char(3),
        localidad_inegi      char(4),
        numerociudad         smallint,
        numeroextcalle       char(10),
        numerointcalle       char(10),
        departamento         char(6),
        numerocalle          integer,
        numerocolonia        integer,
        puntocardinal        char(1),
        unidadhabitac        char(1),
        manzana              smallint,
        otros                smallint,
        andador              smallint,
        etapa                smallint,
        lote                 smallint,
        edificio             smallint,
        entrada              smallint,
        observaciones        char(80),
        user_insert          char(8),
        fecha_insert         date,
        ind_cofeteltel1      char(1),
        ind_cofeteltel2      char(1),
        ind_cofeteltel3      char(1)
    ) EXTENT SIZE 5815430 NEXT SIZE 581543 LOCK MODE ROW;
    UPDATE STATISTICS MEDIUM FOR TABLE ultimas_direcciones;
    
    SELECT MIN(numcte), MAX(numcte)
      INTO vctemin, vctemax
      FROM si_direcciones
     WHERE numcte > '000000000';
    
    FOREACH WITH HOLD
        SELECT UNIQUE numcte
          INTO vnumcte
          FROM si_direcciones
         WHERE numcte BETWEEN vctemin AND vctemax
           AND tipo_dir = '1'
          
        IF vcomienza1 = -1 THEN
            LET vcomienza1 = 0;
            BEGIN WORK;
        END IF;
        
        SELECT MAX(secuencia)
          INTO vsecuencia_max
          FROM si_direcciones
         WHERE numcte = vnumcte
           AND tipo_dir = '1';
           
        INSERT INTO ultimas_direcciones
        SELECT *
          FROM si_direcciones
         WHERE numcte = vnumcte
           AND secuencia = vsecuencia_max
           AND tipo_dir = '1';
           
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;
        
        IF vcontador2 = 7500 THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
    END FOREACH;
    
    IF vcontador2 >= 0 THEN
        LET vcontador2 = 0;
        COMMIT WORK;
    END IF;
    
    FOREACH WITH HOLD
        SELECT UNIQUE numcte
          INTO vnumcte
          FROM si_direcciones
         WHERE numcte BETWEEN vctemin AND vctemax
           AND tipo_dir = '2'
          
        IF vcomienza2 = -1 THEN
            LET vcomienza2 = 0;
            BEGIN WORK;
        END IF;
        
        SELECT MAX(secuencia)
          INTO vsecuencia_max
          FROM si_direcciones
         WHERE numcte = vnumcte
           AND tipo_dir = '2';
           
        INSERT INTO ultimas_direcciones
        SELECT *
          FROM si_direcciones
         WHERE numcte = vnumcte
           AND secuencia = vsecuencia_max
           AND tipo_dir = '2';
           
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;
        
        IF vcontador2 = 7500 THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
    END FOREACH;
    
    IF vcontador2 >= 0 THEN
        LET vcontador2 = 0;
        COMMIT WORK;
    END IF;
    
    FOREACH WITH HOLD
        SELECT UNIQUE numcte
          INTO vnumcte
          FROM si_direcciones
         WHERE numcte BETWEEN vctemin AND vctemax
           AND tipo_dir = '3'
          
        IF vcomienza3 = -1 THEN
            LET vcomienza3 = 0;
            BEGIN WORK;
        END IF;
        
        SELECT MAX(secuencia)
          INTO vsecuencia_max
          FROM si_direcciones
         WHERE numcte = vnumcte
           AND tipo_dir = '3';
           
        INSERT INTO ultimas_direcciones
        SELECT *
          FROM si_direcciones
         WHERE numcte = vnumcte
           AND secuencia = vsecuencia_max
           AND tipo_dir = '3';
           
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;
        
        IF vcontador2 = 7500 THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
    END FOREACH;
    
    IF vcontador2 >= 0 THEN
        LET vcontador2 = 0;
        COMMIT WORK;
    END IF;
              
    -- // DESCARGA ULTIMAS DIRECCIONES
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/ultimas_direcciones.unl '||
               ' SELECT * FROM ultimas_direcciones;" > /resplogifx/conciliachq/dskrga_direcciones.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    --- LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/dskrga_direcciones.sql"; 
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/dskrga_direcciones.sql"; 
    SYSTEM vsql;
    
    END;

    RETURN vcodret1, vcodret2;

END PROCEDURE;