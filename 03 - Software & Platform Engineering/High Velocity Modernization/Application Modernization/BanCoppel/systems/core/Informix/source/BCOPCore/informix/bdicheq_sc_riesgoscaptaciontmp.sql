CREATE PROCEDURE "informix".sc_riesgoscaptaciontmp()
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;

    -------------------------------------------------
    -- Recopila los datos de captacion del cliente, 
    -- como el saldo disponible hasta el dia de hoy 
    -- y los guarda en la tabla sc_riesgoscap.
    -------------------------------------------------
    
    DEFINE GLOBAL vgcuenta      CHAR(20)     DEFAULT " ";
    DEFINE GLOBAL vgfechahoy    DATE         DEFAULT " ";
    DEFINE GLOBAL vgtasavar     CHAR(1)      DEFAULT "";
    
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vdesccodret      CHAR(50);
    DEFINE vsqlerr          INTEGER;
    DEFINE visamerr         INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vconsmovhis      CHAR(10);
    DEFINE vconsmovhisold   CHAR(10);
    DEFINE vconsmovhisold2  CHAR(10);
    DEFINE vmincta, vmaxcta CHAR(20);
    DEFINE vfecha           CHAR(8);
    DEFINE vsql             CHAR(500);
    
    DEFINE vnumcte          CHAR(20);
    DEFINE vsucursal	    CHAR(4);
    DEFINE vplazo		    CHAR(3);
    DEFINE vproducto	    CHAR(4);
    DEFINE vactividad       CHAR(3);
    DEFINE vresidencia	    CHAR(1);
    DEFINE vedocivil		CHAR(2);
    DEFINE vsexo	  	    CHAR(1);
    DEFINE vocupacion       CHAR(30);
    DEFINE vciudad          CHAR(15);
    DEFINE vtasa			CHAR(8);
    DEFINE vanioshab	    SMALLINT;
    DEFINE vdiaspos         SMALLINT;
    DEFINE vdependientes    SMALLINT;
    DEFINE vacumsdopos		MONEY(18,2);
    DEFINE vsdoprom		    MONEY(18,2);
    DEFINE vsdoactual	    MONEY(18,2);
    DEFINE vsdoret		    MONEY(18,2);
    DEFINE vsdocong		    MONEY(18,2);
    DEFINE vsdodisp         MONEY(18,2);
    DEFINE vint_acum        MONEY(18,2);
    DEFINE vacum_sdo_int    MONEY(18,2);
    DEFINE vprovint         MONEY(18,2);
    DEFINE vfechaaniv       DATE;
    DEFINE vfechaalta       DATE;
    DEFINE vfechprimermov   DATE;
    DEFINE vfechultimomov   DATE;
    DEFINE ves_fisica       CHAR(1);
    DEFINE vtipper          CHAR(1);
    DEFINE vvaltasa         DECIMAL(9,6);
    DEFINE vintinvcrec      DECIMAL(14,2);
    DEFINE vmaxsec          INTEGER;
    DEFINE vfecha_nac       DATE;
    DEFINE vedad            INTEGER;
    DEFINE vhabita_en       CHAR(1);
    DEFINE vplaza           CHAR(3);
    
    LET vcodret1        = "000";
    LET vcodret2        = "000";
    LET vdesccodret     = " ";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vcomienza       = -1;
    LET vcontador1      = 0;
    LET vcontador2      = 0;
    LET vcontador3      = 0;
    LET ven_transacc    = 0; 
    
    LET vgfechahoy      = "";
    LET vconsmovhis     = '';
    LET vconsmovhisold  = '';
    LET vconsmovhisold2 = '';
    LET vmincta         = '';
    LET vmaxcta         = '';
    LET vfecha          = '';
    LET vsql            = '';
    
    LET vnumcte         = "";
    LET vgcuenta        = "";
    LET vsucursal       = "";
    LET vplazo          = "";
    LET vproducto       = "";
    LET vactividad      = "";
    LET vresidencia     = "";
    LET vedocivil       = "";
    LET vsexo           = "";
    LET vocupacion      = "";
    LET vciudad         = "";
    LET vtasa           = 0;
    LET vanioshab       = 0;
    LET vdiaspos        = 0;
    LET vdependientes   = 0;
    LET vacumsdopos     = 0;
    LET vsdoprom        = 0;
    LET vsdoactual      = 0;
    LET vsdoret		    = 0;
    LET vsdocong		= 0;
    LET vsdodisp        = 0;
    LET vint_acum       = 0;
    LET vacum_sdo_int   = 0;
    LET vprovint        = 0;
    LET vfechaaniv      = '';
    LET vfechaalta      = '';
    LET vfechprimermov  = '';
    LET vfechultimomov  = '';
    LET ves_fisica      = '';
    LET vtipper         = '';
    LET vvaltasa        = 0;
    LET vintinvcrec     = 0;
    LET vmaxsec         = 0;
    LET vfecha_nac      = '';
    LET vedad           = 0;
    LET vhabita_en      = '';
    LET vplaza          = '';

    BEGIN

    ON EXCEPTION SET vsqlerr, visamerr
        SET debug file to "/resplogifx/conciliachq/sc_riesgoscaptaciontmp.err";
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
    
    --- SET debug file to "/resplogifx/conciliachq/sc_riesgoscaptaciontmp.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // Obtiene la fecha del dia de hoy
    SELECT fecha_ant
      INTO vgfechahoy
      FROM sc_fechas
     WHERE empresa = '001';
    
    CREATE TEMP TABLE sc_riesgoscap_tmp
        (
            empresa         char(3),
            numcte          char(20),
            cuenta          char(20),
            sucursal        char(4),
            plazo           char(3),
            producto        char(4),
            tasa            decimal(9,6),
            actividad       char(3),
            ocupacion       char(30),
            residencia      char(1),
            edocivil        char(2),
            sexo            char(1),
            anioshab        smallint,
            dependientes    smallint,
            ciudad          char(15),
            sdoprom         money(14,2),
            sdodisp         money(14,2),
            provintdev      money(14,2),
            fechaaniv       date,
            fecaltacte      date,
            primermov       date,
            ultimomov       date,
            fecha           date,
            edad            integer
        ) WITH NO LOG;
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmincta, vmaxcta
      FROM sc_maechq;
    
    /* -- CLIENTES -- */
    FOREACH WITH HOLD
        SELECT {+INDEX(sc_maechq idx_sc_maechq3)} 
               UNIQUE num_cte
          INTO vnumcte
          FROM bdicheq:sc_maechq
         WHERE empresa = '001' 
           AND cuenta BETWEEN vmincta AND vmaxcta
           AND status_cta <> '2'
           AND fecha_proceso >= vgfechahoy
        
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        /* -- Obtiene los datos socioeconomicos del cliente -- */
        SELECT cli.actividad_princ, cli.residencia, cli.fecha_alta,
               cte.estado_civil, cte.sexo, cte.anios_habita, cte.dependientes, cte.fecha_nac, cte.habita_en,
               pfs.descripcion, tip.es_fisica
          INTO vactividad, vresidencia, vfechaalta,
               vedocivil, vsexo, vanioshab, vdependientes, vfecha_nac, vhabita_en,
               vocupacion, ves_fisica
          FROM bdinteg:si_cliente cli
         INNER JOIN bdinteg:si_tipper tip ON (tip.tpo_persona = cli.tpo_persona)
          LEFT OUTER JOIN bdinteg:si_ctepf cte ON (cli.numcte = cte.numcte AND cli.empresa = cte.empresa)
          LEFT OUTER JOIN bdinteg:si_profesion pfs ON (cte.profesion = pfs.profesion)
         WHERE cli.empresa = '001' 
           AND cli.numcte = vnumcte;
           
        LET vedad = (vgfechahoy - vfecha_nac) / 365;
        
        IF vhabita_en = 'P' THEN
            LET vresidencia = '1';
        ELIF vhabita_en = 'G' THEN
            LET vresidencia = '2';
        ELIF vhabita_en = 'F' THEN
            LET vresidencia = '3';
        ELIF vhabita_en = 'R' THEN
            LET vresidencia = '4';
        ELIF vhabita_en = 'H' THEN
            LET vresidencia = '9';
        ELSE
            LET vresidencia = '0';
        END IF;
        
        /* -- Obtiene la ciudad del cliente -- */
        /* ######################################
        SELECT a.nombreciudad 
          INTO vciudad 
          FROM bdinteg:si_catciudades a,
               bdinteg:si_direcciones_actual b
         WHERE b.numcte = vnumcte 
           AND b.tipo_dir = '1' 
           AND a.numerociudad = b.numerociudad;
        ###################################### */
        
        /* -- ASIGNA TIPO DE PERSONA -- */
        IF ves_fisica = "S" THEN
            LET vtipper = "F";
        ELSE
            LET vtipper = "M";
        END IF;
        
        /* -- CUENTAS -- */
        FOREACH 
            SELECT mae.cuenta, mae.sucursal, mae.producto, mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.fec_ult_mov, mae.plaza,
                   noc.fecha_alta, noc.acum_sdo_pos, noc.dia_sdo_pos, noc.int_acum, noc.acum_sdo_int,
                   pro.tasa, pro.paga_dividendo
              INTO vgcuenta, vsucursal, vproducto, vsdoactual, vsdoret, vsdocong, vfechultimomov, vplaza,
                   vfechaaniv, vacumsdopos, vdiaspos, vint_acum, vacum_sdo_int,
                   vtasa, vgtasavar
              FROM bdicheq:sc_maechq mae,
                   bdicheq:sc_maenoc noc,
                   bdicheq:sc_producto pro
             WHERE mae.num_cte = vnumcte
               AND mae.status_cta <> '2'
               AND mae.fecha_proceso >= vgfechahoy
               AND noc.empresa = mae.empresa
               AND noc.cuenta = mae.cuenta
               AND pro.empresa = mae.empresa
               AND pro.producto = mae.producto
        
            /* -- Calcula el saldo promedio del cliente -- */
            IF vdiaspos > 0 THEN
                LET vsdoprom = vacumsdopos / vdiaspos;
            ELSE
                LET vsdoprom = vsdoactual;
            END IF;
            
            /* -- Obtiene el valor de la tasa -- */
            CALL calc_tasa("001", vtasa, vtipper, vsdoprom)
            RETURNING vcodret1, vvaltasa, vintinvcrec;

            /* -- Calcula el saldo disponible del cliente -- */
            LET vsdodisp = vsdoactual - (vsdoret + vsdocong);
            
            /* -- Calcula la provision de intereses -- */
            LET vprovint = vint_acum + vacum_sdo_int;
            
            LET vplazo = ' ';
            LET vfechprimermov = vfechaaniv;

            /* -- Inserta datos en tabla sc_riesgoscap_tmp -- */
            INSERT INTO sc_riesgoscap_tmp 
            ( empresa, numcte, cuenta, sucursal, plazo, producto, tasa, 
              actividad, ocupacion, residencia, edocivil, sexo, anioshab, dependientes, ciudad, 
              sdoprom, sdodisp, provintdev, fechaaniv, fecaltacte, primermov, ultimomov, fecha, edad )
            VALUES 
            ( '001', vnumcte, vgcuenta, vsucursal, vplazo, vproducto, vvaltasa,
              vactividad, vocupacion, vresidencia, vedocivil, vsexo, vanioshab, vdependientes, vplaza,
              vsdoprom, vsdodisp, vprovint, vfechaaniv, vfechaalta, vfechprimermov, vfechultimomov, vgfechahoy, vedad );
              
            LET vcontador2 = vcontador2 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            LET vgcuenta	    = "";
            LET vsucursal       = "";
            LET vplazo          = "";
            LET vproducto       = "";
            LET vtasa           = 0;
            LET vgtasavar       = "";
            LET vdiaspos        = 0;
            LET vacumsdopos     = 0;
            LET vsdoprom        = 0;
            LET vsdoactual      = 0;
            LET vsdoret		    = 0;
            LET vsdocong		= 0;
            LET vsdodisp        = 0;
            LET vint_acum       = 0;
            LET vacum_sdo_int   = 0;
            LET vprovint        = 0;
            LET vfechaaniv      = '';
            LET vfechprimermov  = '';
            LET vfechultimomov  = '';
            LET vvaltasa        = 0;
            LET vintinvcrec     = 0;
            LET vplaza          = '';
        END FOREACH;
        
        /* -- PAGARES -- */
        FOREACH 
            SELECT mae.cuenta, mae.sucursal, mae.cod_instrum, mae.capital, mae.fec_ult_mov, mae.intereses, mae.fecha_alta, mae.tasa, mae.plazo, mae.plaza
              INTO vgcuenta, vsucursal, vproducto, vsdoactual, vfechultimomov, vprovint, vfechaaniv, vvaltasa, vplazo, vplaza
              FROM bdinvers:sv_maeinv mae
             WHERE mae.num_cte = vnumcte
               AND mae.status_cta = '1'
        
            /* -- Calcula el saldo promedio del cliente -- */
            LET vsdoprom = vsdoactual;
            
            /* -- Calcula el saldo disponible del cliente -- */
            LET vsdodisp = vsdoactual;
            
            LET vfechprimermov = vfechaaniv;

            /* -- Inserta datos en tabla sc_riesgoscap_tmp -- */
            INSERT INTO sc_riesgoscap_tmp 
            ( empresa, numcte, cuenta, sucursal, plazo, producto, tasa, 
              actividad, ocupacion, residencia, edocivil, sexo, anioshab, dependientes, ciudad, 
              sdoprom, sdodisp, provintdev, fechaaniv, fecaltacte, primermov, ultimomov, fecha, edad )
            VALUES 
            ( '001', vnumcte, vgcuenta, vsucursal, vplazo, vproducto, vvaltasa,
              vactividad, vocupacion, vresidencia, vedocivil, vsexo, vanioshab, vdependientes, vplaza,
              vsdoprom, vsdodisp, vprovint, vfechaaniv, vfechaalta, vfechprimermov, vfechultimomov, vgfechahoy, vedad );
              
            LET vcontador2 = vcontador2 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            LET vgcuenta	    = "";
            LET vsucursal       = "";
            LET vplazo          = "";
            LET vproducto       = "";
            LET vsdoprom        = 0;
            LET vsdoactual      = 0;
            LET vsdodisp        = 0;
            LET vprovint        = 0;
            LET vfechaaniv      = '';
            LET vfechprimermov  = '';
            LET vfechultimomov  = '';
            LET vvaltasa        = 0;
            LET vplaza          = '';
        END FOREACH;
        
        LET vcontador1 = vcontador1 + 1;
        
        IF vcontador3 >= 7500 THEN
            LET vcontador3 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vnumcte         = "";
        LET vactividad      = "";
        LET vresidencia     = "";
        LET vedocivil       = "";
        LET vsexo           = "";
        LET vocupacion      = "";
        LET vciudad         = "";
        LET vanioshab       = 0;
        LET vdependientes   = 0;
        LET vfechaalta      = '';
        LET ves_fisica      = '';
        LET vtipper         = '';
        LET vfecha_nac      = '';
        LET vedad           = 0;
        LET vhabita_en      = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    CREATE INDEX idx_riesgoscaptemp ON sc_riesgoscap_tmp(numcte) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE sc_riesgoscap_tmp;
    
    LET vdesccodret = "EL PROCESO SE REALIZO SATISFACTORIAMENTE";

    RETURN vcodret1, vcodret2, vdesccodret, vcontador1, vcontador2;
    
    END;

END PROCEDURE;