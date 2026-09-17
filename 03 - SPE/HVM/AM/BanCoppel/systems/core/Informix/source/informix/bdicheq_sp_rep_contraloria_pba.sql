CREATE PROCEDURE "informix".sp_rep_contraloria_pba()
RETURNING CHAR(5);
    
    DEFINE vcodret          CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE vsqlerr          INTEGER;  
    DEFINE visamerr         INTEGER;  
    DEFINE vdescerr         CHAR(50);  
    DEFINE vcomienza        SMALLINT;
    DEFINE ven_transacc     CHAR(1);
    DEFINE vcontador        INTEGER;	
    DEFINE vfecha_ini       DATE; 
    DEFINE vfecha_fin       DATE; 
    DEFINE vfecha_hoy	    DATE; 
    DEFINE vfecha_ant       DATE;
    DEFINE fecha_movhis     DATE;
    DEFINE fecha_movhisold  DATE;
    DEFINE vfechades        CHAR(8);
    DEFINE vempresa         CHAR(3);
    DEFINE vnum_serial      INTEGER;
    DEFINE ccuenta       	CHAR(20);
    DEFINE cfecha    		DATE;
    DEFINE ctransacc     	CHAR(4);
    DEFINE cmonto    		MONEY(18,2);
    DEFINE vdescripcion		CHAR(50);
    DEFINE vnumcte			CHAR(20);
    DEFINE vsucursal		CHAR(4);
    DEFINE vpaterno			CHAR(26);
    DEFINE vmaterno			CHAR(26);
    DEFINE vnombre1			CHAR(26);
    DEFINE vnombre2			CHAR(26);
    DEFINE vrazon			CHAR(60);
    DEFINE vnombrecalle		CHAR(30);
    DEFINE vnumext			CHAR(10);
    DEFINE vnumint			CHAR(10);
    DEFINE vnombrezona		CHAR(32);
    DEFINE vcpostal			CHAR(5);
    DEFINE vnomciudad		CHAR(30);
    DEFINE viniestado		CHAR(4);
    DEFINE vtelefono1		CHAR(13);
    DEFINE vtelefono2 		CHAR(13);
    DEFINE vtelefono3		char(13);
    DEFINE vsql             CHAR(500);
    DEFINE vstmt            CHAR(200);

    LET vcodret         = "000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
    LET vcomienza       = -1;
    LET ven_transacc    = '0';
    LET vcontador       = 0;
    LET vfecha_ini      = '';
    LET vfecha_fin      = '';
    LET vfecha_hoy 	    = '';
    LET vfecha_ant      = '';
    LET fecha_movhis    = '';
    LET fecha_movhisold = '';
    LET vfechades       = '';
    LET vempresa        = '001';
    LET vnum_serial     = 0;
    LET ccuenta         = "";
    LET cfecha    	    = '';
    LET ctransacc       = "";
    LET cmonto   	    = 0.00;
    LET vdescripcion    = "";
    LET vnumcte		    = "";
    LET vsucursal	    = "";
    LET vpaterno	    = "";
    LET vmaterno	    = "";
    LET vnombre1	    = "";
    LET vnombre2	    = "";
    LET vrazon		    = "";
    LET vnombrecalle    = "";
    LET vnumext		    = "";
    LET vnumint		    = "";
    LET vnombrezona	    = "";
    LET vcpostal	    = "";
    LET vnomciudad	    = "";
    LET viniestado	    = "";
    LET vtelefono1	    = "";
    LET vtelefono2 	    = "";
    LET vtelefono3	    = "";
    LET vsql            = "";
    LET vstmt           = "";
	
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rep_contraloria.out";
    --- TRACE ON; 
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rep_contraloria.err";
        TRACE ON; 
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
            IF ven_transacc = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret;
        END IF;
    END EXCEPTION;
    
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy, fecha_ant
	  INTO vfecha_hoy, vfecha_ant
	  FROM sc_fechas
	 WHERE empresa = vempresa;
    
    IF WEEKDAY(vfecha_hoy) = 2 THEN
        IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tmp_rep_cont' ) THEN
            DROP TABLE tmp_rep_cont;
        END IF	
            
        CREATE TABLE tmp_rep_cont 
          ( 
            cuenta       	char(20),
            fech_alt     	date,
            sucursal        char(4),
            transacc     	char(4),
            descripcion    	char(50),
            monto_tot    	money,
            num_cte         char(20),
            apell_paterno  	char(26),
            apell_materno  	char(26),
            nombre1        	char(26),
            nombre2        	char(26),
            razon_social   	char(60),
            nombrecalle    	char(30),
            numeroextcalle 	char(10),
            numerointcalle 	char(10),
            nombrezona      char(32),
            cod_postal     	char(5),
            nombreciudad    char(30),
            inicialestado   char(4),
            telefono1   	char(13),
            telefono2   	char(13),
            telefono3   	char(13)
          )
        EXTENT SIZE 150000 NEXT SIZE 15000 LOCK MODE ROW;
    END IF;
	
	FOREACH WITH HOLD
        SELECT {+INDEX(sc_movhis idx_movhisnew4)}
               mov1.num_serial, mov1.cuenta, mov1.sucursal, mov1.fech_alt, mov1.transacc, mov1.monto_tot, trx1.descripcion, mae.num_cte
          INTO vnum_serial, ccuenta, vsucursal, cfecha, ctransacc, cmonto, vdescripcion, vnumcte
          FROM sc_movhis mov1,
               bdinteg:si_transacc trx1,
               sc_maechq mae
         WHERE mov1.empresa = vempresa
           AND mov1.cuenta <> '16000000012'
           AND mov1.fech_alt = vfecha_ant
           AND mov1.cancelad <> "S"
           AND mov1.transacc IN("0202", "0204", "0250", "0282", "0310", "0325", "0223") 
           AND trx1.numero = mov1.transacc
           AND mae.cuenta = mov1.cuenta
           AND mae.producto = mov1.producto
        
		IF vcomienza = -1 THEN
            BEGIN WORK;
            LET vcomienza = 0;
            LET ven_transacc = '1';
        END IF;
        
        INSERT INTO tmp_rep_cont( cuenta, fech_alt, sucursal, transacc, descripcion, monto_tot, num_cte )
        VALUES( ccuenta, cfecha, vsucursal, ctransacc, vdescripcion, cmonto, vnumcte );
        
        LET vcontador = vcontador + 1;
        
        IF vcontador >= 10000 THEN
            COMMIT WORK;
            BEGIN WORK;
            LET vcontador = 0;
        END IF;
	END FOREACH
    
    IF ven_transacc = '1' THEN
        COMMIT WORK;
        LET ven_transacc = '0';
    END IF;
    
    IF WEEKDAY(vfecha_hoy) = 2 THEN
        CREATE INDEX idx_tmp_rep_cont_1 ON tmp_rep_cont(num_cte) USING BTREE;
        CREATE INDEX idx_tmp_rep_cont_2 ON tmp_rep_cont(fech_alt) USING BTREE;
		CREATE INDEX idx_tmp_rep_cont_3 ON tmp_rep_cont(num_cte, fech_alt) USING BTREE;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_rep_cont;
    
    LET vcontador = 0;
    LET vcomienza = -1;
    LET ven_transacc = '0';
    
    FOREACH WITH HOLD
        SELECT {+INDEX(tmp_rep_cont idx_tmp_rep_cont_2)}
               UNIQUE num_cte
          INTO vnumcte
          FROM tmp_rep_cont
         WHERE fech_alt = vfecha_ant
          
        IF vcomienza = -1 THEN
            BEGIN WORK;
            LET vcomienza = 0;
            LET ven_transacc = '1';
        END IF;
          
        SELECT cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, cte.razon_social, calle.nombrecalle, dir.numeroextcalle, dir.numerointcalle, 
               zona.nombrezona, dir.cod_postal, ciudad.nombreciudad, ciudad.inicialestado, tel1.telefono, tel2.telefono, tel3.telefono
          INTO vpaterno, vmaterno, vnombre1, vnombre2, vrazon, vnombrecalle, vnumext, vnumint, 
               vnombrezona, vcpostal, vnomciudad, viniestado, vtelefono1, vtelefono2, vtelefono3
          FROM bdinteg:si_cliente cte
         INNER JOIN bdinteg:si_direcciones_actual dir ON (dir.numcte = cte.numcte AND dir.tipo_dir = '1')
          LEFT OUTER JOIN bdinteg:si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
          LEFT OUTER JOIN bdinteg:si_catciudades ciudad ON (ciudad.numerociudad = dir.numerociudad)
          LEFT OUTER JOIN bdinteg:si_catzonas zona ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia) 
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON (tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 AND tel1.status_tel = 'A')
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON (tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 AND tel2.status_tel = 'A')
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel3 ON (tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 AND tel3.status_tel = 'A')
         WHERE cte.numcte = vnumcte;
           
        UPDATE {+INDEX(tmp_rep_cont idx_tmp_rep_cont_1)} tmp_rep_cont
           SET ( apell_paterno, apell_materno, nombre1, nombre2, razon_social, nombrecalle, numeroextcalle, numerointcalle, 
                 nombrezona, cod_postal, nombreciudad, inicialestado, telefono1, telefono2, telefono3 ) =
               ( vpaterno, vmaterno, vnombre1, vnombre2, vrazon, vnombrecalle, vnumext, vnumint, 
                 vnombrezona, vcpostal, vnomciudad, viniestado, vtelefono1, vtelefono2, vtelefono3 )
         WHERE num_cte = vnumcte
		   AND fech_alt = vfecha_ant;
        
        LET vcontador = vcontador + 1;
        
        IF vcontador >= 10000 THEN
            COMMIT WORK;
            BEGIN WORK;
            LET vcontador = 0;
        END IF;
    END FOREACH;
    
    IF ven_transacc = '1' THEN
        COMMIT WORK;
        LET ven_transacc = '0';
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_rep_cont;
    
    IF WEEKDAY(vfecha_hoy) = 1 THEN
        LET vfechades = SUBSTR(vfecha_ant,7,4) || SUBSTR(vfecha_ant,1,2) || SUBSTR(vfecha_ant,4,2);
        LET vfechades = vfechades;
        
        LET vsql =  'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/dep_contral_'||vfechades||'.unl '||
                    'SELECT * FROM tmp_rep_cont;" > /resplogifx/conciliachq/query_contraloria.sql';
        SYSTEM vsql;
        
        LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_contraloria.sql"; 
        SYSTEM vstmt;
    END IF;

	END;
    
    RETURN vcodret;
	
END PROCEDURE;