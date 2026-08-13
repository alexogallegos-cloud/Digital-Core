CREATE PROCEDURE "informix".sp_obtinfctesctas(pempresa CHAR(3))

RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vdesccodret      CHAR(50);
    DEFINE vsqlerr          INTEGER;
    DEFINE visamerr         INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE vcomienzaa       SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vmincta          CHAR(20);
    DEFINE vmaxcta          CHAR(20);
    
    DEFINE vnumcte          CHAR(20);
    DEFINE vnombre          CHAR(104);
    DEFINE vrfc             CHAR(13);
    DEFINE vcotit1          CHAR(1);
    DEFINE vcotit2          CHAR(1);
    DEFINE vcotit3          CHAR(1);
    DEFINE ves_fisica       CHAR(1);
    DEFINE vtipper          CHAR(1);
    DEFINE vtpopersona      CHAR(2);
    DEFINE vprofesion       CHAR(120);
    DEFINE vnacionalidad    CHAR(15);
    DEFINE vexiste          CHAR(20);
    DEFINE vmaxsec          SMALLINT;
    
    DEFINE vcuenta          CHAR(20);
    DEFINE vstatus          CHAR(1);
    DEFINE vfecha_proc      DATE;
    DEFINE vfecultdep       DATE;
    DEFINE vfecha_alta      DATE;
    DEFINE vfecha_alt       CHAR(8);
    DEFINE vfecha_baja      DATE;
    DEFINE vfecha_baj       CHAR(8);
    
    LET vcodret1     = "000";
    LET vcodret2     = "000";
    LET vdesccodret  = " ";
    LET vsqlerr      = 0;
    LET visamerr     = 0;
    LET vcomienza    = -1;
    LET vcomienzaa   = -1;
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vcontador3   = 0;
    LET ven_transacc = 0;       
    LET vmincta      = '';
    LET vmaxcta      = '';
    
    LET vnumcte       = "";
    LET vnombre       = '';
    LET vrfc          = '';
    LET vcotit1       = ' ';
    LET vcotit2       = ' ';
    LET vcotit3       = ' ';
    LET ves_fisica    = '';
    LET vtipper       = '';
    LET vtpopersona   = '';
    LET vprofesion    = '';
    LET vnacionalidad = '';
    LET vexiste       = '';
    LET vmaxsec       = 0;
    
    LET vcuenta     = "";
    LET vstatus     = '';
    LET vfecha_proc = '';
    LET vfecultdep  = '';
    LET vfecha_alta = '';
    LET vfecha_alt  = '';
    LET vfecha_baja = '';
    LET vfecha_baj  = '';


    BEGIN

    ON EXCEPTION SET vsqlerr, visamerr
        SET debug file to "./sp_obtinfctesctas.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret1 = vsqlerr;
            LET vcodret2 = visamerr;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vdesccodret, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET debug file to "./sp_obtinfctesctas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    CREATE TEMP TABLE sc_infctesctas
        (
            cuenta          CHAR(20), 
            numcte          CHAR(20), 
            nombre          CHAR(104),
            cotit1          CHAR(1),
            cotit2          CHAR(1),
            cotit3          CHAR(1),
            tpoper          CHAR(1),
            ocupacion       CHAR(120),
            rfc             CHAR(13),
            fecha_alta      CHAR(8),
            fecha_baja      CHAR(8),
            nacionalidad    CHAR(15)
        ) WITH NO LOG LOCK MODE ROW;
    CREATE INDEX idx_infctecta ON sc_infctesctas(numcte) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE sc_infctesctas;
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmincta, vmaxcta
      FROM bdicheq:sc_maechq;
    
    -- // INVERSIONES CRECIENTES
    FOREACH WITH HOLD
        SELECT UNIQUE mae.num_cte
          INTO vnumcte
          FROM bdicheq:sc_maechq mae,
               bdicheq:sc_maenoc noc
         WHERE mae.empresa = pempresa 
           AND mae.cuenta BETWEEN vmincta AND vmaxcta
           AND mae.producto = '1100'
           AND mae.fecultdep <= '06/30/2010'
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
        
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        SELECT TRIM(cte.apell_paterno)||' '||TRIM(cte.apell_materno)||' '||TRIM(cte.nombre1)||' '||TRIM(cte.nombre2), 
               cte.rfc, tip.es_fisica, tip.tpo_persona
          INTO vnombre, vrfc, ves_fisica, vtpopersona
          FROM bdinteg:si_cliente cte,
               bdinteg:si_tipper tip
         WHERE cte.numcte = vnumcte
           AND tip.tpo_persona = cte.tpo_persona;
         
        IF vtpopersona in('02', '04') THEN
            SELECT TRIM(razon_social)
              INTO vnombre
              FROM bdinteg:si_cliente
             WHERE numcte = vnumcte;
        END IF;
        
        IF ves_fisica = "S" THEN
            LET vtipper = "F"; --- FISICA
        ELSE
            LET vtipper = "M"; --- MORAL
        END IF;
        
        IF vtpopersona in('01', '03') THEN  
            
            SELECT FIRST 1 numcte
              INTO vexiste
              FROM bdiauditor:tbl_bitacoraapertura
             WHERE numcte = vnumcte
               AND id_pregunta = 6;
             
            IF vexiste = vnumcte THEN
            
                SELECT MAX(id_secuencia)
                  INTO vmaxsec
                  FROM bdiauditor:tbl_bitacoraapertura
                 WHERE numcte = vnumcte
                   AND id_pregunta = 6;
                   
                SELECT act.descrip
                  INTO vprofesion
                  FROM bdiauditor:tbl_bitacoraapertura ape,
                       bdinteg:si_actsubact act
                 WHERE ape.numcte = vnumcte
                   AND ape.id_pregunta = 6
                   AND ape.id_secuencia = vmaxsec
                   AND act.id_act = ape.id_act
                   AND act.id_subact = ape.id_subact;
                   
                SELECT nac.descripcion
                  INTO vnacionalidad
                  FROM bdinteg:si_ctepf pf,
                       bdinteg:si_nacion nac
                 WHERE pf.numcte = vnumcte
                   AND nac.nacion = pf.nacionalidad;
            
            ELSE
            
                SELECT pfs.descripcion, nac.descripcion
                  INTO vprofesion, vnacionalidad
                  FROM bdinteg:si_ctepf pf,
                       bdinteg:si_profesion pfs,
                       bdinteg:si_nacion nac
                 WHERE pf.numcte = vnumcte
                   AND pfs.profesion = pf.profesion
                   AND nac.nacion = pf.nacionalidad;
                   
            END IF;
               
        ELIF vtpopersona in('02', '04') THEN  
        
            SELECT act.nombre, nac.descripcion
              INTO vprofesion, vnacionalidad
              FROM bdinteg:si_cliente cli,
                   bdinteg:si_actecon act,
                   bdinteg:si_ctepm pm,
                   bdinteg:si_nacion nac
             WHERE cli.numcte = vnumcte
               AND act.actividad = cli.actividad_princ
               AND pm.numcte = cli.numcte
               AND nac.nacion = pm.nacionalidad;
                   
        END IF;
        
        FOREACH 
            SELECT mae.cuenta, mae.status_cta, mae.fecha_proceso, mae.fecultdep, noc.fecha_alta
              INTO vcuenta, vstatus, vfecha_proc, vfecultdep, vfecha_alta 
              FROM bdicheq:sc_maechq mae,
                   bdicheq:sc_maenoc noc
             WHERE mae.num_cte = vnumcte
               AND mae.producto = '1100'
               AND mae.fecultdep <= '06/30/2010'
               AND noc.empresa = mae.empresa
               AND noc.cuenta = mae.cuenta 

            IF vfecha_alta > '06/30/2010' THEN
                LET vfecha_alta = vfecultdep;
            END IF;
            
            IF vstatus = '2' THEN
                LET vfecha_baja = vfecha_proc;
                
                IF vfecha_baja is null THEN
                    LET vfecha_baja = vfecultdep;
                END IF;
            ELSE
               LET vfecha_baja = '';
            END IF;
               
            LET vfecha_alt = TO_CHAR(vfecha_alta, '%Y%m%d');
            LET vfecha_baj = TO_CHAR(vfecha_baja, '%Y%m%d');

            -- // Inserta datos en tabla sc_infctesctas
            INSERT INTO sc_infctesctas 
            ( cuenta, numcte, nombre, cotit1, cotit2, cotit3, tpoper, ocupacion, rfc, fecha_alta, fecha_baja, nacionalidad ) 
            VALUES 
            ( vcuenta, vnumcte, vnombre, vcotit1, vcotit2, vcotit3, vtipper, vprofesion, vrfc, vfecha_alt, vfecha_baj, vnacionalidad );
              
            LET vcontador2 = vcontador2 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            LET vcuenta	    = "";
            LET vstatus     = '';
            LET vfecha_proc = '';
            LET vfecultdep  = '';
            LET vfecha_alta = '';
            LET vfecha_alt  = '';
            LET vfecha_baja = '';
            LET vfecha_baj  = '';
        END FOREACH;
        
        LET vcontador1 = vcontador1 + 1;
        
        IF vcontador3 >= 7500 THEN
            LET vcontador3 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vnumcte       = "";
        LET vnombre       = '';
        LET vtipper       = "";
        LET vprofesion    = "";
        LET vrfc          = "";
        LET vnacionalidad = '';
        LET vexiste       = '';
        LET vmaxsec       = 0;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_infctesctas;
    
    -- // DIFERENTES A INVERSIONES CRECIENTES
    FOREACH WITH HOLD
        SELECT UNIQUE mae.num_cte
          INTO vnumcte
          FROM bdicheq:sc_maechq mae,
               bdicheq:sc_maenoc noc
         WHERE mae.empresa = pempresa 
           AND mae.cuenta BETWEEN vmincta AND vmaxcta
           AND mae.producto <> '1100'
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
           AND noc.fecha_alta <= '06/30/2010'
        
        IF vcomienzaa = -1 THEN
            LET vcomienzaa = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        SELECT TRIM(cte.apell_paterno)||' '||TRIM(cte.apell_materno)||' '||TRIM(cte.nombre1)||' '||TRIM(cte.nombre2), 
               cte.rfc, tip.es_fisica, tip.tpo_persona
          INTO vnombre, vrfc, ves_fisica, vtpopersona
          FROM bdinteg:si_cliente cte,
               bdinteg:si_tipper tip
         WHERE cte.numcte = vnumcte
           AND tip.tpo_persona = cte.tpo_persona;
         
        IF vtpopersona in('02', '04') THEN
            SELECT TRIM(razon_social)
              INTO vnombre
              FROM bdinteg:si_cliente
             WHERE numcte = vnumcte;
        END IF;
        
        IF ves_fisica = "S" THEN
            LET vtipper = "F"; --- FISICA
        ELSE
            LET vtipper = "M"; --- MORAL
        END IF;
        
        IF vtpopersona in('01', '03') THEN  
            
            SELECT FIRST 1 numcte
              INTO vexiste
              FROM bdiauditor:tbl_bitacoraapertura
             WHERE numcte = vnumcte
               AND id_pregunta = 6;
             
            IF vexiste = vnumcte THEN
            
                SELECT MAX(id_secuencia)
                  INTO vmaxsec
                  FROM bdiauditor:tbl_bitacoraapertura
                 WHERE numcte = vnumcte
                   AND id_pregunta = 6;
                   
                SELECT act.descrip
                  INTO vprofesion
                  FROM bdiauditor:tbl_bitacoraapertura ape,
                       bdinteg:si_actsubact act
                 WHERE ape.numcte = vnumcte
                   AND ape.id_pregunta = 6
                   AND ape.id_secuencia = vmaxsec
                   AND act.id_act = ape.id_act
                   AND act.id_subact = ape.id_subact;
                   
                SELECT nac.descripcion
                  INTO vnacionalidad
                  FROM bdinteg:si_ctepf pf,
                       bdinteg:si_nacion nac
                 WHERE pf.numcte = vnumcte
                   AND nac.nacion = pf.nacionalidad;
            
            ELSE
            
                SELECT pfs.descripcion, nac.descripcion
                  INTO vprofesion, vnacionalidad
                  FROM bdinteg:si_ctepf pf,
                       bdinteg:si_profesion pfs,
                       bdinteg:si_nacion nac
                 WHERE pf.numcte = vnumcte
                   AND pfs.profesion = pf.profesion
                   AND nac.nacion = pf.nacionalidad;
                   
            END IF;
               
        ELIF vtpopersona in('02', '04') THEN  
        
            SELECT act.nombre, nac.descripcion
              INTO vprofesion, vnacionalidad
              FROM bdinteg:si_cliente cli,
                   bdinteg:si_actecon act,
                   bdinteg:si_ctepm pm,
                   bdinteg:si_nacion nac
             WHERE cli.numcte = vnumcte
               AND act.actividad = cli.actividad_princ
               AND pm.numcte = cli.numcte
               AND nac.nacion = pm.nacionalidad;
                   
        END IF;
           
        FOREACH 
            SELECT mae.cuenta, mae.status_cta, mae.fecha_proceso, mae.fecultdep, noc.fecha_alta 
              INTO vcuenta, vstatus, vfecha_proc, vfecultdep, vfecha_alta 
              FROM bdicheq:sc_maechq mae,
                   bdicheq:sc_maenoc noc
             WHERE mae.num_cte = vnumcte
               AND mae.producto <> '1100'
               AND noc.empresa = mae.empresa
               AND noc.cuenta = mae.cuenta 
               AND noc.fecha_alta <= '06/30/2010'

            IF vstatus = '2' THEN
                LET vfecha_baja = vfecha_proc;
            ELSE
               LET vfecha_baja = '';
            END IF;
               
            LET vfecha_alt = TO_CHAR(vfecha_alta, '%Y%m%d');
            LET vfecha_baj = TO_CHAR(vfecha_baja, '%Y%m%d');

            -- // Inserta datos en tabla sc_infctesctas
            INSERT INTO sc_infctesctas 
            ( cuenta, numcte, nombre, cotit1, cotit2, cotit3, tpoper, ocupacion, rfc, fecha_alta, fecha_baja, nacionalidad ) 
            VALUES 
            ( vcuenta, vnumcte, vnombre, vcotit1, vcotit2, vcotit3, vtipper, vprofesion, vrfc, vfecha_alt, vfecha_baj, vnacionalidad );
              
            LET vcontador2 = vcontador2 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            LET vcuenta	    = "";
            LET vstatus     = '';
            LET vfecha_proc = '';
            LET vfecultdep  = '';
            LET vfecha_alta = '';
            LET vfecha_alt  = '';
            LET vfecha_baja = '';
            LET vfecha_baj  = '';
        END FOREACH;
        
        LET vcontador1 = vcontador1 + 1;
        
        IF vcontador3 >= 7500 THEN
            LET vcontador3 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vnumcte       = "";
        LET vnombre       = '';
        LET vtipper       = "";
        LET vprofesion    = "";
        LET vrfc          = "";
        LET vnacionalidad = '';
        LET vexiste       = '';
        LET vmaxsec       = 0;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_infctesctas;
    
    LET vdesccodret = "EL PROCESO SE REALIZO SATISFACTORIAMENTE";
    
    RETURN vcodret1, vcodret2, vdesccodret, vcontador1, vcontador2;
    
    END;

END PROCEDURE;