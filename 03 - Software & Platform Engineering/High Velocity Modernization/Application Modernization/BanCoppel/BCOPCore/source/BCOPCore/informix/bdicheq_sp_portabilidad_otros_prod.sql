CREATE PROCEDURE "informix".sp_portabilidad_otros_prod(p_empresa char(3))
RETURNING   CHAR(5);

DEFINE v_c_vcomienza    SMALLINT;
DEFINE ven_transacc     SMALLINT;
DEFINE v_c_vcontador    INTEGER;
DEFINE v_monto_tot      DECIMAL(18,2);
DEFINE vult_mes_ant     DATE;
DEFINE vult_mes_ant1    CHAR(8);
DEFINE vpri_mes_ant     DATE; 
DEFINE vpri_mes_ant1    CHAR(8);
DEFINE vsqlerr          INTEGER;
DEFINE vcodret          CHAR(5);
DEFINE v_sucursal       CHAR(4);
DEFINE v_cuenta         CHAR(20);
DEFINE v_cliente        CHAR(20); 
DEFINE v_cliente_2      CHAR(20);
DEFINE v_nombre         CHAR(50);
DEFINE v_nombre2        CHAR(50);
DEFINE v_apellido       CHAR(50);
DEFINE v_tel_cel        CHAR(13);	
DEFINE v_correo         CHAR(100);
DEFINE v_fecha_estatus  CHAR(8);
DEFINE vsql             CHAR(500);
DEFINE v_fecha_arch     CHAR(8);
DEFINE v_fecha_hoy      DATE; 
DEFINE v_inv            INTEGER;
DEFINE v_pag            INTEGER;
DEFINE v_ciudad         CHAR(30);
DEFINE v_estado         CHAR(30);
DEFINE v_cp             CHAR(5);
DEFINE v_presta_per     INTEGER;
DEFINE v_ant_nom        INTEGER;
DEFINE v_prest_nom      INTEGER;
DEFINE v_tdc            INTEGER;
DEFINE v_flexible       INTEGER;


	
LET vsqlerr             = 0; 
LET vcodret             = "00000";
LET v_c_vcomienza       = -1;
LET ven_transacc        = 0;
LET v_c_vcontador       = 0;
LET vsql                = '';




BEGIN
	 ON EXCEPTION SET vsqlerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_portabilidad_otros_prod.err";
	 	    TRACE ON;
            IF vsqlerr <> 0 THEN
               LET vcodret = vsqlerr;
			   IF ven_transacc = 1 THEN
                  ROLLBACK WORK;
               END IF;
            RETURN vcodret;
            END IF;
     END EXCEPTION;
	
     ---SET   DEBUG FILE TO '/ifxsif01/rsv/RQM101222/porta_otros.txt';
	 ---TRACE ON;
	
	   SET ISOLATION TO DIRTY READ;
	SELECT DATE(pri_dia_mes - 1 UNITS MONTH), DATE(pri_dia_mes - 1  UNITS DAY) , fecha_hoy 
	  INTO vpri_mes_ant                     , vult_mes_ant                     , v_fecha_hoy
      FROM sc_fechas
     WHERE empresa = p_empresa;
	 
	 	 
	   LET vpri_mes_ant1 = to_char(vpri_mes_ant, '%Y%m%d');
	   LET vult_mes_ant1 = to_char(vult_mes_ant, '%Y%m%d');
	 	
	 
    CREATE TABLE tmp_porta_otros_prod (
	       cliente            CHAR(20),
	       cuenta             CHAR(20),
	       sucursal           CHAR(4),
		   nombre_1           CHAR(50),
		   nombre_2           CHAR(50),
		   apellido_p         CHAR(50),
		   correo             CHAR(100),
		   fecha_portabilidad CHAR(8),
		   ciudad             CHAR(30),
		   estado             CHAR(30),
		   cp                 CHAR(5),
		   telefono           CHAR(13),
		   inv_cre            INTEGER,
		   pagare             INTEGER,
		   tdc                INTEGER,
		   prestamo_p         INTEGER,
		   ant_nom            INTEGER,
		   prest_nom          INTEGER,
		   flexible           INTEGER
	       );
		   
 	 		
   FOREACH WITH HOLD

         SELECT {+INDEX (sc_portacec_solicitud )} 
                DISTINCT(a.num_cte)
		   INTO v_cliente
		   FROM bdicheq:sc_portacec_solicitud AS a
		  INNER JOIN sc_maechq AS b ON (a.num_cte = b.num_cte AND a.cta_receptora = b.cuenta_clabe)
		  WHERE a.estatus_portabilidad = 1
           			 
		     -- Abre la transaccion 
		     IF (v_c_vcomienza = -1) THEN
                LET v_c_vcomienza = 0;
                LET ven_transacc = 1;
                BEGIN WORK;
            END IF;
		
		 SELECT COUNT(*)
		   INTO v_inv
		   FROM bdicheq:sc_maechq
		  WHERE num_cte = v_cliente
		    AND producto = '1100'
			AND status_cta = '1';
		  		  
		 SELECT COUNT(*)
		   INTO v_pag
		   FROM bdinvers:sv_maeinv
		  WHERE num_cte = v_cliente
		    AND status_cta = '1';
			
	     SELECT COUNT(*)
		   INTO v_tdc
		   FROM bdicred:sd_maecred
		  WHERE numcte = v_cliente
		    AND num_producto = '6001'
			AND status_cred IN ('AA','BA','BT','E1','E2','E3');
			
			
		 SELECT COUNT(*)
		   INTO v_presta_per
		   FROM bdicred:sd_maecredcrd
		  WHERE numcte = v_cliente
		    AND num_producto IN('6300','7600','7700')
		    AND status_cred IN ('AA','BA','BT','E1','E2','E3');
						
		 SELECT COUNT(*)
		   INTO v_ant_nom
		   FROM bdicred:sd_maecred
		  WHERE numcte = v_cliente
		    AND num_producto = '7800'
			AND status_cred IN ('AA','BA','BT','E1','E2','E3');
						
		 SELECT COUNT(*)
		   INTO v_prest_nom
		   FROM bdicred:sd_maecredcrd
		  WHERE numcte = v_cliente
		    AND num_producto  = '6400'
		    AND status_cred IN ('AA','BA','BT','E1','E2','E3');
			
		 SELECT COUNT(*)
		   INTO v_flexible
		   FROM bdicred:sd_maecredcrd
		  WHERE numcte = v_cliente
		    AND num_producto  = '6800'
		    AND status_cred IN ('AA','BA','BT','E1','E2','E3');
			

			
	      	 IF v_inv > 1 THEN 
			    LET v_inv = 1; 
			END IF;
			
			 IF v_pag > 1 THEN 
			    LET v_pag = 1; 
			END IF;
			
			 IF v_tdc > 1 THEN 
			    LET v_tdc = 1; 
			END IF;
			
			 IF v_presta_per > 1 THEN 
			    LET v_presta_per = 1; 
			END IF;
			
			 IF v_ant_nom > 1 THEN 
			    LET v_ant_nom = 1; 
			END IF;
			
			 IF v_prest_nom > 1 THEN 
			    LET v_prest_nom = 1; 
			END IF;
			
			 IF v_flexible > 1 THEN 
			    LET v_flexible = 1;
		    END IF;
			 
		 SELECT FIRST 1 b.num_cte,  
	            a.cuenta, 
			    a.sucursal,
			    c.nombre1 AS nombre1, 
			    c.nombre2 AS nombre2, 
			    c.apell_paterno AS apellido, 
			    e.correo_elec,
				b.fecha_estatus_portabilidad,
			    f.municipiozona,
                h.nombre,
		        g.cod_postal,
			    d.telefono
		   INTO v_cliente_2,v_cuenta,v_sucursal,v_nombre,v_nombre2, v_apellido,v_correo,v_fecha_estatus,v_ciudad,v_estado,v_cp,v_tel_cel		   
		   FROM bdicheq:sc_maechq                        AS a
          INNER JOIN bdicheq:sc_portacec_solicitud       AS b ON (b.num_cte = a.num_cte AND b.cta_receptora = a.cuenta_clabe)
		  INNER JOIN bdinteg:si_cliente                  AS c ON (c.numcte  = b.num_cte )
		   LEFT OUTER JOIN bdinteg:si_direcciones_actual AS g ON (g.numcte  = b.num_cte AND g.tipo_dir = '1')
           LEFT OUTER JOIN bdinteg:si_telefonos_actual   AS d ON (d.numcte  = b.num_cte AND d.tipo_tel = 2)
           LEFT OUTER JOIN bdinteg:si_correos            AS e ON (e.numcte  = b.num_cte AND e.tipo_correo = 1 and e.status_correo = 'A')
		   LEFT OUTER JOIN bdinteg:si_catzonas           AS f ON (f.numerociudad = g.numerociudad AND f.numerocolonia = g.numerocolonia )
		   LEFT OUTER JOIN bdinteg:si_estados            AS h ON (h.estado = g.estado)
          WHERE a.num_cte = v_cliente
		 ---   AND b.fecha_estatus_portabilidad  BETWEEN  vpri_mes_ant1 AND  vult_mes_ant1
            AND b.estatus_portabilidad = 1;
  
         INSERT INTO tmp_porta_otros_prod VALUES (TRIM(v_cliente_2),TRIM(v_cuenta),TRIM(v_sucursal),TRIM(v_nombre),TRIM(v_nombre2),TRIM(v_apellido),TRIM(v_correo),TRIM(v_fecha_estatus),TRIM(v_ciudad),TRIM(v_estado),TRIM(v_cp),TRIM(v_tel_cel),v_inv,v_pag,v_tdc,v_presta_per,v_ant_nom,v_prest_nom,v_flexible);
  
  		    LET v_c_vcontador = v_c_vcontador + 1;
			    --Realiza commit cada 3000 registros 
			 IF (v_c_vcontador >= 3000) THEN
                LET v_c_vcontador = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 
			
   END FOREACH;
	    
		--Si la transaccion esta abierta realiza el commit
	    IF  ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;
 
		LET v_fecha_arch = to_char (v_fecha_hoy,'%d%m%YY');
		
		LET vsql = '';
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
			       'UNLOAD TO /RESPALDOSNEW/Porta_prod_asoc'||v_fecha_arch||'.txt '||
		           'SELECT * FROM tmp_porta_otros_prod" > /resplogifx/conciliachq/porta.sql';
	    SYSTEM vsql; 
	
	    --/EJECUCION DEL ARCHIVO .SQL 
        LET vsql = '';
        LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/porta.sql"; 
        SYSTEM vsql;	
        
		BEGIN;
		DROP TABLE tmp_porta_otros_prod;
		COMMIT; 
		
	    --/COMPRIME EL ARCHIVO .SQL 
        LET vsql = '';
        LET vsql = '/usr/bin/gzip -9 /RESPALDOSNEW/Porta_prod_asoc'||v_fecha_arch||'.txt'; 
        SYSTEM vsql;
								  
RETURN  vcodret;
END; 
END PROCEDURE;