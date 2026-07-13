CREATE PROCEDURE "informix".sp_dep_inter_37_suc( pempresa char(3)) 
RETURNING   CHAR(5); 
 
 
DEFINE vsqlerr        INTEGER; 
DEFINE vcodret        CHAR(5); 
DEFINE VAL            INTEGER;  
DEFINE vsql           CHAR(500); 
 
--VARIABLES PARA EL PROCESO 
DEFINE v_fecha_hoy    DATE; 
DEFINE v_p_dia_ante   DATE; 
DEFINE v_u_dia_ante   DATE; 
DEFINE v_anio_fin     INTEGER; 
DEFINE v_mes_fin      CHAR(2); 
DEFINE v_dia_fin      CHAR(2); 
DEFINE v_f_fin        VARCHAR(8); 
 
 
LET vsqlerr = 0;  
LET vcodret = "00000"; 
 
 
BEGIN 
	   ON EXCEPTION SET vsqlerr 
	      SET DEBUG FILE TO "/resplogifx/conciliachq/37_suc.err"; 
	   	   TRACE ON; 
              IF vsqlerr <> 0 THEN 
                 LET vcodret = vsqlerr; 
              RETURN vcodret; 
              END IF; 
       END EXCEPTION; 
	    
       --SET DEBUG FILE TO '/resplogifx/conciliachq/37_suc.txt'; 
	   --TRACE ON; 
	    
	   SET ISOLATION TO DIRTY READ; 
	 
	 
	   --SE OBTIENEN LAS  FECHAS PARA EL PROCESO  
       SELECT DATE(pri_dia_mes - 1 UNITS MONTH), DATE(pri_dia_mes - 1  UNITS DAY),fecha_hoy	 
         INTO v_p_dia_ante,	                     v_u_dia_ante,                    v_fecha_hoy  
         FROM sc_fechas 
		WHERE empresa = pempresa; 
		  
		  
	   --LIMPIA TABLA 	  
	   BEGIN; 
       TRUNCATE TABLE sc_dep_inter;  
	   COMMIT; 
 
		  
	    BEGIN;   
       INSERT INTO sc_dep_inter(fecha,cliente,cuenta,monto,sucursal_dep,sucursal_cta) 
       SELECT mv.fech_alt, 
              ma.num_cte , 
              ma.cuenta  , 
              mv.monto_tot, 
              mv.sucursal AS sucursal_deposito, 
              ma.sucursal AS sucursal_apertura 
        FROM  sc_maechq AS ma, 
              sc_movhis AS mv 
        WHERE ma.empresa  = pempresa 
          AND ma.cuenta   = mv.cuenta 
          AND mv.fech_alt BETWEEN v_p_dia_ante AND v_u_dia_ante 
          AND mv.cancelad <> 'S' 
          AND mv.transacc IN('0202','0325') 
		  AND mv.monto_tot > '10000'  
          AND mv.sucursal  IN("0077","0265","0110","0225", 
                              "0368","0203","0029","0300", 
                              "0105","0020", "0266","0090", 
                              "0258","0338","0179","0365", 
                              "0369","0076","0417","0181", 
                              "0097","0098","0672","0099", 
                              "0341","0568","0198","0437", 
                              "0458","0457","0475","7005", 
       					      "0102","0436","0896","0851",  
       					      "1395" 
							  ); 
	   COMMIT;  
	    
	    
	    
	   BEGIN;   
       INSERT INTO sc_dep_inter(fecha,cliente,cuenta,monto,sucursal_dep,sucursal_cta) 
       SELECT mv.fech_alt, 
              ma.num_cte , 
              ma.cuenta  , 
              mv.monto_tot, 
              mv.sucursal AS sucursal_deposito, 
              ma.sucursal AS sucursal_apertura 
        FROM  sc_maechq AS ma, 
              sc_movhis_old AS mv 
        WHERE ma.empresa  = pempresa 
          AND ma.cuenta   = mv.cuenta 
          AND mv.fech_alt BETWEEN v_p_dia_ante AND v_u_dia_ante 
          AND mv.cancelad <> 'S' 
          AND mv.transacc IN('0202','0325') 
		  AND mv.monto_tot > '10000'  
          AND mv.sucursal  IN("0077","0265","0110","0225", 
                              "0368","0203","0029","0300", 
                              "0105","0020", "0266","0090", 
                              "0258","0338","0179","0365", 
                              "0369","0076","0417","0181", 
                              "0097","0098","0672","0099", 
                              "0341","0568","0198","0437", 
                              "0458","0457","0475","7005", 
       					      "0102","0436","0896","0851",  
       					      "1395" 
							  ); 
	   COMMIT;  
	    
	   -- SE OBTIENE LA FECHA PARA ASIGNARSELA AL NOMBRE DEL ARCHIVO 
		 LET v_anio_fin = YEAR (v_fecha_hoy); 
         LET v_mes_fin  = MONTH(v_fecha_hoy); 
         LET v_dia_fin  = DAY  (v_fecha_hoy); 
		   
		 IF  LEN (v_mes_fin) = 1 THEN 
             LET  v_mes_fin  = 0 || v_mes_fin; 
         END IF; 
 
         IF  LEN (v_dia_fin) = 1 THEN 
             LET  v_dia_fin  = 0 || v_dia_fin; 
         END IF; 
		   
		 --ARMA LA FECHA PARA EL NOMBRE DEL ARCHIVO  
         LET v_f_fin = v_dia_fin || v_mes_fin || v_anio_fin ; 
		   
		 --PROCESO PARA LA DESCARGA DEL ARCHIVO  
		 LET vsql = ''; 
         LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '|| 
                    'UNLOAD TO  /resplogifx/conciliachq/623_REP_MEN_DEP_INTER_PRO_'||v_f_fin||'.txt'|| 
                    ' SELECT * FROM sc_dep_inter " >  /resplogifx/conciliachq/rep_inter_37_consulta.sql'; 
            
         SYSTEM vsql; 
           
         --EJECUCION DEL ARCHIVO .SQL 
         LET vsql = ''; 
         LET vsql = "dbaccess bdicheq  /resplogifx/conciliachq/rep_inter_37_consulta.sql"; 
         SYSTEM vsql; 
 
 
    
RETURN  vcodret; 
END;  
END PROCEDURE;