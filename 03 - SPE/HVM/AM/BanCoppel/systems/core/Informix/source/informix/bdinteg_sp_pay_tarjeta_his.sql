CREATE PROCEDURE "informix".sp_pay_tarjeta_his(pinicio DATE, pfin DATE)
RETURNING VARCHAR(10), varchar(255);


	DEFINE v_sqlc1        		VARCHAR(250);
	DEFINE v_sqlc2        		VARCHAR(250);
	DEFINE v_sqlc3        		VARCHAR(250);
	DEFINE v_sqlc4        		VARCHAR(250);
	DEFINE v_sqlc5        		VARCHAR(250);
	DEFINE v_sqlc6        		VARCHAR(250);
	DEFINE v_sqlc7        		VARCHAR(250);
	DEFINE v_sqlc8       		VARCHAR(250);
	DEFINE v_sqlc9        		VARCHAR(250);
	DEFINE v_sqlc10        		VARCHAR(250);
	
	
	DEFINE v_sqld1        		VARCHAR(250);
	DEFINE v_sqld2        		VARCHAR(250);
	DEFINE v_sqld3        		VARCHAR(250);
	DEFINE v_sqld4        		VARCHAR(250);
	DEFINE v_sqld5        		VARCHAR(250);
	DEFINE v_sqld6        		VARCHAR(250);
	DEFINE v_sqld7        		VARCHAR(250);
	DEFINE v_sqld8       		VARCHAR(250);
	DEFINE v_sqld9        		VARCHAR(250);
	DEFINE v_sqld10        		VARCHAR(250);
	
	DEFINE v_sql        		CHAR(250);
	
	
	
	
	DEFINE v_sql2        		CHAR(250);
	DEFINE v_comprime		    CHAR(200);
	DEFINE v_comprime2		    CHAR(200);
	
	DEFINE vcod_ret         	VARCHAR(10); 
	DEFINE sql_err          	INTEGER;
	DEFINE isam_err         	INTEGER;
	DEFINE error_info       	CHAR(40);
	
	
	DEFINE vfechaini			CHAR(8);
	DEFINE vfechafin			CHAR(8);
	
	DEFINE vfini				CHAR(19);
	DEFINE vffin				CHAR(19);
	
	


--Manejo del error
       ON EXCEPTION
		SET sql_err, isam_err, error_info
		
           IF sql_err <> 0 THEN
            LET vcod_ret=sql_err;
            RETURN vcod_ret, isam_err||' '||error_info;
			
           END IF;
       END EXCEPTION;   
	   

--set debug file to "/tmp/sp_pay_tarjeta_his.out";
--TRACE ON;		

	LET v_sql = ''; 
	
	LET v_sqlc1 = ''; 
	LET v_sqlc2 = ''; 
	LET v_sqlc3 = ''; 
	LET v_sqlc4 = ''; 
	LET v_sqlc5 = '';
	LET v_sqlc6 = ''; 
	LET v_sqlc7 = ''; 
	LET v_sqlc8 = ''; 
	LET v_sqlc9 = ''; 
	LET v_sqlc10 = '';
	
	LET v_sqld1 = ''; 
	LET v_sqld2 = ''; 
	LET v_sqld3 = ''; 
	LET v_sqld4 = ''; 
	LET v_sqld5 = '';
	LET v_sqld6 = ''; 
	LET v_sqld7 = ''; 
	LET v_sqld8 = ''; 
	LET v_sqld9 = ''; 
	LET v_sqld10 = '';
	

	LET v_comprime = '';
	LET v_comprime2 = '';

	LET vcod_ret = '000';          
	LET sql_err = 0;          
	LET isam_err = 0;        
	LET error_info = '';	
	
	
	LET vfechaini = TO_CHAR(pinicio,'%Y%m%d') ;	
	LET vfechafin = TO_CHAR(pfin,'%Y%m%d');	
	
	LET vfini = TO_CHAR(pinicio,'%Y-%m-%d 00:00:00') ;	
	LET vffin = TO_CHAR(pfin,'%Y-%m-%d 23:59:59');


--para cred


LET v_sqlc1 = 'echo "SELECT {+ INDEX (bdicred:sd_tarjeta idx_tarjeta1)} '|| 
			'j.fechaultmodif AS fecha,'|| 
			'''9913'' AS mti,'||
			'LPAD(TRIM(c.num_credito), 15, ''0'') AS num_cta,'||
			'j.numtarjeta AS num_tarjeta,'||
			'LPAD(TRIM(c.numcte), 15, ''0'') AS num_cte_cta,'||'"'||' > qrycred.sql'; 
			
			
			
LET v_sqlc2 = 'echo "LPAD(TRIM(t.numcte), 15, ''0'') AS num_cte_tarjeta,'||
			'LPAD(TRIM(j.codproductotarjeta), 4, ''0'') AS id_producto,'||
			'LPAD ('''', 40, '' '') AS nombre_embozado,'||
			'''0'' AS accion,'||'"'||' >> qrycred.sql';
			
LET v_sqlc3 = 'echo "CASE WHEN j.titular = ''T'' then ''1'''||
				 'ELSE ''0'''||
              'END AS tipo,'||
			'TO_CHAR(nvl(j.fechaasignacion,MDY(1,1,1900)),''%Y%m%d'')  AS fecha_solicitud,'||'"'||' >> qrycred.sql';
			
LET v_sqlc4 = 'echo "TO_CHAR(nvl(j.fechaasignacion,MDY(1,1,1900)),''%H%M%S'') AS hora_solicitud,'||
			'TO_CHAR(nvl(j.fechaasignacion,MDY(1,1,1900)),''%Y%m%d'') AS fecha_emision,'||'"'||' >> qrycred.sql';
			
LET v_sqlc5 = 'echo "LPAD(REPLACE(CAST(nvl(t.limite_aut,0) AS DECIMAL(13,2)),''.'','''') ,15,0)  AS lim_cred'||
	  ' FROM  intercard:tarjeta j,'||
			'bdicred:sd_tarjeta t,'||
			'bdicred:sd_maecred c'||'"'||' >> qrycred.sql';
			
LET v_sqlc6 =  'echo " WHERE j.numcliente <>''0'''|| 
        ' AND j.fechaultmodif >= '''|| vfini || '''' || 
        ' AND j.fechaasignacion BETWEEN '''|| vfini || '''' ||' AND '''|| vffin ||''''||
        ' AND j.codstatustarjeta = ''ACT'''||
        ' AND t.empresa = ''001'''||'"'||' >> qrycred.sql';
    


		
LET v_sqlc7 = 'echo " AND t.num_tarjeta = j.numtarjeta'||
        ' AND c.empresa = t.empresa'||
		' AND c.numcte = t.numcte' ||	
	' INTO temp tmp_info_tarj_cred WITH NO LOG;'||'"'||' >> qrycred.sql';

	
LET v_sqlc8 ='echo " SELECT LPAD(CHAR_length(mti||num_cta||num_tarjeta||num_cte_cta||num_cte_tarjeta||'||
			'id_producto||nombre_embozado||accion||tipo||fecha_solicitud'||
			'||hora_solicitud||fecha_emision||lim_cred),4,0)||mti||num_cta'||'"'||' >> qrycred.sql';
	
LET v_sqlc9 = 'echo "||num_tarjeta||num_cte_cta||num_cte_tarjeta||id_producto||nombre_embozado||'||
			'accion||tipo||fecha_solicitud||hora_solicitud||fecha_emision||lim_cred AS trama'||
			' FROM tmp_info_tarj_cred'||'"'||' >> qrycred.sql';
	
	  
LET v_sqlc10 = 'echo " INTO temp tmp_his_tarj_cred WITH NO LOG;'|| 
				'UNLOAD TO ''tarj_cred_'||vfechaini||'_al_'||vfechafin||'.unl'''||
	  'SELECT * FROM tmp_his_tarj_cred;'||'"'||' >> qrycred.sql'; 	
	   
		
	

	SYSTEM v_sqlc1;
	SYSTEM v_sqlc2;
	SYSTEM v_sqlc3;
	SYSTEM v_sqlc4;
	SYSTEM v_sqlc5;
	SYSTEM v_sqlc6;
	SYSTEM v_sqlc7;
	SYSTEM v_sqlc8;
	SYSTEM v_sqlc9;
	SYSTEM v_sqlc10;
      LET v_sqlc1 = "dbaccess bdipayt qrycred.sql";
    SYSTEM v_sqlc1;		
	

--Comprimir Archivo 		
SYSTEM v_comprime;
      LET v_comprime = "gzip -9 'tarj_cred_'"||vfechaini||"_al_"||vfechafin||".unl";
SYSTEM v_comprime;	  



 --para cheq
 

LET v_sqld1 = 'echo "SELECT {+ INDEX (bdicheq:sc_tarjeta ix_tarjeta2)} '||
			'j.fechaultmodif AS fecha,'|| 
			'''9913'' AS mti,'||
			'LPAD(TRIM(c.cuenta), 15, ''0'') AS num_cta,'||
			'j.numtarjeta AS num_tarjeta,'||
			'LPAD(TRIM(c.num_cte), 15, ''0'') AS num_cte_cta,'||'"'||' > qrycheq.sql'; 
			
LET v_sqld2 = 'echo "LPAD(TRIM(t.numcte), 15, ''0'') AS num_cte_tarjeta,'||
			'LPAD(TRIM(j.codproductotarjeta), 4, ''0'') AS id_producto,'||
			'LPAD ('''', 40, '' '') AS nombre_embozado,'||
			'''0'' AS accion,'||'"'||' >> qrycheq.sql';
			
LET v_sqld3 = 'echo "CASE WHEN j.titular = ''T'' then ''1'''||
				 'ELSE ''0'''||
			  'END AS tipo,'||'"'||' >> qrycheq.sql';
			  
LET v_sqld4 = 'echo "TO_CHAR(nvl(j.fechaasignacion,MDY(1,1,1900)),''%Y%m%d'')  AS fecha_solicitud,'||
			'TO_CHAR(nvl(j.fechaasignacion,MDY(1,1,1900)),''%H%M%S'') AS hora_solicitud,'||
			'TO_CHAR(nvl(j.fechaasignacion,MDY(1,1,1900)),''%Y%m%d'') AS fecha_emision,'||'"'||' >> qrycheq.sql';
			
LET v_sqld5 = 'echo "LPAD(0 , 15 ,0)  AS lim_cred'||
	  ' FROM  intercard:tarjeta j,'|| 
			'bdicheq:sc_tarjeta t,'||
			'bdicheq:sc_maechq c'||'"'||' >> qrycheq.sql';
			
LET v_sqld6 = 'echo " WHERE  j.numcliente <> ''0'''|| 
        ' AND j.fechaultmodif >= '''|| vfini || '''' || 
		' AND j.fechaasignacion BETWEEN '''|| vfini || '''' ||' AND '''|| vffin ||''''|| 
        ' AND j.codstatustarjeta = ''ACT'''||'"'||' >> qrycheq.sql';
		


		
LET v_sqld7 = 'echo " AND j.numtarjeta = t.num_tarjeta'||
		' AND t.empresa = ''001'''||
		' AND c.empresa = t.empresa'||
		' AND c.cuenta = t.cuenta'|| 
	' INTO temp tmp_info_tarj_cheq WITH NO LOG;'||'"'||' >> qrycheq.sql';

LET v_sqld8 = 'echo " SELECT LPAD(CHAR_length(mti||num_cta||num_tarjeta||num_cte_cta||num_cte_tarjeta||id_producto||nombre_embozado||accion||tipo'||
			'||fecha_solicitud||hora_solicitud||fecha_emision||lim_cred),4,0)||mti||num_cta'||'"'||' >> qrycheq.sql';
			
			
LET v_sqld9 = 'echo "||num_tarjeta||num_cte_cta||num_cte_tarjeta'||
			'||id_producto||nombre_embozado||accion||tipo||fecha_solicitud||hora_solicitud||fecha_emision||lim_cred AS trama'||
	  ' FROM tmp_info_tarj_cheq'||'"'||' >> qrycheq.sql';	
	  
LET v_sqld10 = 'echo " INTO temp tmp_his_tarj_cheq WITH NO LOG;'||
	  ' UNLOAD TO ''tarj_cheq_'||vfechaini||'_al_'||vfechafin||'.unl'''||
	  ' SELECT * FROM tmp_his_tarj_cheq;'||'"'||' >> qrycheq.sql'; 
	  
	  
	  
	SYSTEM v_sqld1;
	SYSTEM v_sqld2;
	SYSTEM v_sqld3;
	SYSTEM v_sqld4;
	SYSTEM v_sqld5;
	SYSTEM v_sqld6;
	SYSTEM v_sqld7;
	SYSTEM v_sqld8;
	SYSTEM v_sqld9;
	SYSTEM v_sqld10;
      LET v_sqld1 = "dbaccess bdipayt qrycheq.sql";
    SYSTEM v_sqld1;	 



SYSTEM v_comprime2;
      LET v_comprime2 = "gzip -9 'tarj_cheq_'"||vfechaini||"_al_"||vfechafin||".unl";
SYSTEM v_comprime2;		  

	  
	      RETURN vcod_ret, 'PROCESO EXITOSO';
END PROCEDURE;