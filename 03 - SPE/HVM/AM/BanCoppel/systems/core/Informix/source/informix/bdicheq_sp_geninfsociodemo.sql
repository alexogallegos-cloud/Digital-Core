CREATE PROCEDURE "informix".sp_geninfsociodemo(pempresa CHAR(3))

RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;

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
    
    DEFINE vfechahoy        DATE; 
    DEFINE vmincta          CHAR(20);
    DEFINE vmaxcta          CHAR(20);
    DEFINE vfecha           CHAR(8);
    DEFINE vsql             CHAR(500);
    
    DEFINE vnumcte          CHAR(20);
    DEFINE vsucursal	    CHAR(4);
    DEFINE vproducto	    CHAR(4);
    DEFINE vcuenta          CHAR(20);
    DEFINE vsexo	  	    CHAR(1);
    DEFINE vedocivil		CHAR(2);
    DEFINE vfecha_nac       DATE;
    DEFINE vsdo_dia_ant     DECIMAL(14,2);
    DEFINE vfecha_alta      DATE;
    DEFINE vfechultimomov   DATE;
    
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
    
    LET vfechahoy        = "";
    LET vmincta          = '';
    LET vmaxcta          = '';
    LET vfecha           = '';
    LET vsql             = '';
    
    LET vnumcte         = "";
    LET vcuenta         = "";
    LET vsucursal       = "";
    LET vproducto       = "";
    LET vedocivil       = "";
    LET vsexo           = "";
    LET vfecha_nac      = '';
    LET vsdo_dia_ant    = 0;
    LET vfecha_alta     = '';
    LET vfechultimomov  = '';

    BEGIN

    ON EXCEPTION SET vsqlerr, visamerr
        SET debug file to "/resplogifx/conciliachq/sp_geninfsociodemo.err";
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
    
    --- SET debug file to "/resplogifx/conciliachq/sp_geninfsociodemo.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vfechahoy
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  
                WHERE partnum > 0 AND tabname = 'sc_infsociodemocap') THEN
        DROP TABLE bdicheq:"informix".sc_infsociodemocap;        
    END IF;
    
    CREATE RAW TABLE "informix".sc_infsociodemocap
        (
            numcte       CHAR(20)     NOT NULL, 
            sucursal     CHAR(4)      NOT NULL, 
            producto     CHAR(4)      NOT NULL, 
            cuenta       CHAR(20)     NOT NULL, 
            sdo_fin_mes  MONEY(18,2)  NOT NULL, 
            fecha_alta   DATE         NOT NULL, 
            fech_ult_mov DATE, 
            sexo         CHAR(1), 
            edocivil     CHAR(1), 
            fecha_nac    DATE 
        )
    EXTENT SIZE 351562 NEXT SIZE 35156 LOCK MODE ROW;
    CREATE INDEX "informix".idx_socdemcap ON "informix".sc_infsociodemocap(numcte) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE sc_infsociodemocap;
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmincta, vmaxcta
      FROM sc_maechq;
    
    /* -- CLIENTES -- */
    FOREACH WITH HOLD
        SELECT UNIQUE num_cte
          INTO vnumcte
          FROM bdicheq:sc_maechq
         WHERE empresa = pempresa 
           AND cuenta BETWEEN vmincta AND vmaxcta
           AND status_cta <> '2' 
        
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        /* -- Obtiene los datos socioeconomicos del cliente -- */
        SELECT sexo, estado_civil, fecha_nac
          INTO vsexo, vedocivil, vfecha_nac
          FROM bdinteg:si_ctepf
         WHERE numcte = vnumcte;
           
        /* -- CUENTAS -- */
        FOREACH 
            SELECT mae.sucursal, mae.producto, mae.cuenta, mae.fec_ult_mov, mae.sdo_dia_ant, noc.fecha_alta 
              INTO vsucursal, vproducto, vcuenta, vfechultimomov, vsdo_dia_ant, vfecha_alta 
              FROM bdicheq:sc_maechq mae,
                   bdicheq:sc_maenoc noc
             WHERE mae.num_cte = vnumcte
               AND mae.status_cta <> '2'
               AND noc.empresa = mae.empresa
               AND noc.cuenta = mae.cuenta       

            -- // Inserta datos en tabla sc_infsociodemocap
            INSERT INTO sc_infsociodemocap 
            ( numcte, sucursal, producto, cuenta, sdo_fin_mes, fecha_alta, fech_ult_mov, sexo, edocivil, fecha_nac ) 
            VALUES 
            ( vnumcte, vsucursal, vproducto, vcuenta, vsdo_dia_ant, vfecha_alta, vfechultimomov, vsexo, vedocivil, vfecha_nac );
              
            LET vcontador2 = vcontador2 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            LET vsucursal       = "";
            LET vproducto       = "";
            LET vcuenta	        = "";
            LET vsdo_dia_ant    = 0;
            LET vfecha_alta     = "";
            LET vfechultimomov  = '';
        END FOREACH;
        
        /* -- PAGARES -- */
        FOREACH 
            SELECT mae.sucursal, mae.cod_instrum, mae.cuenta, mae.fec_ult_mov, mae.capital, mae.fecha_alta 
              INTO vsucursal, vproducto, vcuenta, vfechultimomov, vsdo_dia_ant, vfecha_alta 
              FROM bdinvers:sv_maeinv mae
             WHERE mae.num_cte = vnumcte
               AND mae.status_cta = '1'      

            /* -- Inserta datos en tabla sc_infsociodemocap -- */
            INSERT INTO sc_infsociodemocap 
            ( numcte, sucursal, producto, cuenta, sdo_fin_mes, fecha_alta, fech_ult_mov, sexo, edocivil, fecha_nac ) 
            VALUES 
            ( vnumcte, vsucursal, vproducto, vcuenta, vsdo_dia_ant, vfecha_alta, vfechultimomov, vsexo, vedocivil, vfecha_nac );
              
            LET vcontador2 = vcontador2 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            LET vsucursal       = "";
            LET vproducto       = "";
            LET vcuenta	        = "";
            LET vsdo_dia_ant    = 0;
            LET vfecha_alta     = "";
            LET vfechultimomov  = '';
        END FOREACH;
        
        LET vcontador1 = vcontador1 + 1;
        
        IF vcontador3 >= 7500 THEN
            LET vcontador3 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vnumcte         = "";
        LET vsexo           = "";
        LET vedocivil       = "";
        LET vfecha_nac      = "";
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_infsociodemocap;
    
    LET vfecha = TO_CHAR(vfechahoy, '%d%m%Y');
    
    LET vsql = '';
    LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/infosociodemograficacaptacion_'||vfecha||'.txt'||
               ' SELECT numcte, sucursal, producto, cuenta, sdo_fin_mes, fecha_alta, fech_ult_mov, sexo, edocivil, fecha_nac'||
               ' FROM sc_infsociodemocap ORDER BY numcte;" > /resplogifx/conciliachq/infsociodemocap.sql';
    SYSTEM vsql;
    LET vsql = '';
    --- LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/infsociodemocap.sql"; 
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/infsociodemocap.sql"; 
    SYSTEM vsql;
    LET vsql = '';
    
    LET vdesccodret = "EL PROCESO SE REALIZO SATISFACTORIAMENTE";
    
    RETURN vcodret1, vcodret2, vdesccodret, vcontador1, vcontador2;
    
    END;

END PROCEDURE;