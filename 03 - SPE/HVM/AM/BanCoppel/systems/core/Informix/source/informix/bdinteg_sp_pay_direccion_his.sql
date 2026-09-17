CREATE PROCEDURE "informix".sp_pay_direccion_his(pinicio DATE, pfin DATE)
RETURNING VARCHAR(10), varchar(255);


	DEFINE v_sql        		VARCHAR(255);
	DEFINE v_sql2        		VARCHAR(255);
	DEFINE v_sql3       		VARCHAR(255);
	DEFINE v_sql4        		VARCHAR(255);
	DEFINE v_sql5       		VARCHAR(255);
	DEFINE v_sql6        		VARCHAR(255);
	DEFINE v_sql7        		VARCHAR(255);
	DEFINE v_sql8       		VARCHAR(255);
	DEFINE v_sql9        		VARCHAR(255);
	DEFINE v_sql10       		VARCHAR(255);
	DEFINE v_sql11        		VARCHAR(255);
	DEFINE v_sql12        		VARCHAR(255);
	DEFINE v_sql13       		VARCHAR(255);
	DEFINE v_sql14        		VARCHAR(255);
	DEFINE v_sql15       		VARCHAR(255);
	DEFINE v_sql16        		VARCHAR(255);
	DEFINE v_sql17        		VARCHAR(255);
	DEFINE v_sql18       		VARCHAR(255);
	DEFINE v_sql19        		VARCHAR(255);
	DEFINE v_comprime		    CHAR(200);
	
	DEFINE vcod_ret         	VARCHAR(10); 
	DEFINE sql_err          	INTEGER;
	DEFINE isam_err         	INTEGER;
	DEFINE error_info       	CHAR(40);
	
	DEFINE vfechaini			CHAR(8);
	DEFINE vfechafin			CHAR(8);
	
	DEFINE vfini				CHAR(10);
	DEFINE vffin				CHAR(10);
	
	


--Manejo del error
       ON EXCEPTION
		SET sql_err, isam_err, error_info
		
           IF sql_err <> 0 THEN
            LET vcod_ret=sql_err;
            RETURN vcod_ret, isam_err||' '||error_info;
			
           END IF;
       END EXCEPTION;   
	   

--set debug file to "/tmp/sp_pay_direccion_his.out";
--TRACE ON;		

	LET v_sql = '';  
	LET v_sql2 = ''; 
	LET v_sql3 = ''; 
	LET v_sql4 = ''; 
	LET v_sql5 = ''; 
	LET v_sql6 = ''; 
	LET v_sql7 = ''; 
	LET v_sql8 = ''; 
	LET v_sql9 = '';
	LET v_sql10 = '';
	LET v_sql11 = '';
	LET v_sql12 = '';
	LET v_sql13 = '';
	LET v_sql14 = '';
	LET v_sql15 = '';
	LET v_sql16 = '';
	LET v_sql17 = '';
	LET v_sql18 = '';
	LET v_sql19 = '';
	
	LET v_comprime = '';

	LET vcod_ret = '000';          
	LET sql_err = 0;          
	LET isam_err = 0;        
	LET error_info = '';	
	
	LET vfechaini = TO_CHAR(pinicio,'%Y%m%d') ;	
	LET vfechafin = TO_CHAR(pfin,'%Y%m%d');	
	
	LET vfini = TO_CHAR(pinicio,'%m-%d-%Y') ;	
	LET vffin = TO_CHAR(pfin,'%m-%d-%Y');
	

	   
	 

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;	 


--Obtencion de info direcciones




LET v_sql = 'echo "SELECT {+ INDEX (bdinteg:si_direcciones inx_puntocardinales)} '||
			'''9912'' AS mti,'||
			'LPAD(TRIM(c.numcte), 15, ''0'') AS num_cliente,'||
			'CASE WHEN  d.tipo_dir = ''1'' AND d.secuencia = 1  THEN ''0'''|| 
				 ' WHEN d.tipo_dir = ''1'' AND d.secuencia > 1 THEN ''1'''|| '"'||' > querydir.sql';
				 
LET v_sql2 = 'echo " WHEN  d.tipo_dir = ''2'' AND d.secuencia =1 THEN ''0'''||
				 ' WHEN  d.tipo_dir = ''2'' AND d.secuencia =2 THEN ''0'''|| 
				 ' WHEN  d.tipo_dir = ''2'' AND d.secuencia > 2 THEN ''1'''||  
			  ' END AS accion,'||'"'||' >> querydir.sql';
			
LET v_sql3 = 'echo "TRIM(tipo_dir) AS tipo,'||
			'RPAD((TRIM(c.apell_paterno)||'' ''||TRIM(c.apell_materno)||'' ''||TRIM(c.nombre1)||'' ''||TRIM(c.nombre2)), 40, '' '') AS nombre,'||
			'LPAD(TRIM(c.rfc), 20, ''0'') AS rfc,'||'"'||' >> querydir.sql';
			
			
LET v_sql4 = 'echo "LPAD(52, 4, ''0'') AS cod_pais_tel,'|| 
			'CASE WHEN TRIM(d.telefono1) = '''' THEN LPAD(0, 4, ''0'')'||
                 ' ELSE LPAD(SUBSTR(d.telefono1,1,2), 4,''0'')'|| 
			  ' END AS cod_cd_tel,'||'"'||' >> querydir.sql';
			  
			  
LET v_sql5 = 'echo "CASE WHEN TRIM(d.telefono1) = '''' THEN RPAD(0, 12, ''0'')'|| 
                 ' ELSE  52||nvl(TRIM(d.telefono1),0)'|| 
			  ' END    AS num_telefono,'||
			'LPAD(52, 4, ''0'') AS cod_pais_tel_mobil,'||'"'||' >> querydir.sql';
			
			
LET v_sql6 = 'echo "CASE WHEN TRIM(d.telefono2) = '''' THEN RPAD(0, 4, ''0'')'||
                 ' ELSE LPAD(SUBSTR(d.telefono2, 4, 2), 4, ''0'')'|| 
			  ' END AS cod_cd_tel_mobil,'||'"'||' >> querydir.sql';
			  
			  
LET v_sql7 = 'echo "CASE WHEN TRIM(d.telefono2) = '''' THEN RPAD(0, 12, ''0'')'|| 
				 ' WHEN length(d.telefono2) = 13 THEN  52||SUBSTR(TRIM(d.telefono2), 4, 13)'||
				 ' WHEN length(d.telefono2) = 10 THEN  52||TRIM(d.telefono2)'||'"'||' >> querydir.sql'; 
				 
				 
LET v_sql8 = 'echo " WHEN length(d.telefono2) = 11 THEN LPAD(TRIM(d.telefono2), 12, ''0'')'||
                 ' WHEN length(d.telefono2) < 10 THEN LPAD(TRIM(d.telefono2), 12, ''0'')'|| 
				 ' ELSE RPAD(nvl(d.telefono2, 0), 12, 0)'|| '"'||' >> querydir.sql';
				 
				 
LET v_sql9 ='echo " END AS tel_mobil,'||
			'RPAD((TRIM(l.nombrecalle)||'' ''||TRIM(d.numeroextcalle)), 40, '' '') AS calle,'||
			'RPAD(0, 5, ''0'') AS numero,'|| 
			'RPAD(d.cod_postal, 10, '' '') AS cod_postal,'|| '"'||' >> querydir.sql';
			
			
LET v_sql10 = 'echo "RPAD(TRIM(d.observaciones), 40, '' '') AS complementos,'||
			'RPAD(z.nombrezona, 25, '' '') AS colonia,'||
			'RPAD(s.nombre, 25, '' '') AS ciudad,'||
			'd.estado AS estado,'||
			'd.pais AS pais,'|| '"'||' >> querydir.sql';
			
			
LET v_sql11 ='echo "d.secuencia AS secuencia,'||
			'd.fecha_insert AS fecha'||
			' FROM bdinteg:si_direcciones d,'||
				'bdinteg:si_cliente c,'||
				'bdinteg:si_catcalles l,'||
				'bdinteg:si_catzonas z,'||
				'bdinteg:si_ciudades s'|| '"'||' >> querydir.sql';
				
				
LET v_sql12 ='echo "WHERE d.numcte = c.numcte'||
            ' AND d.secuencia = (SELECT MAX(secuencia)'||
								 ' FROM bdinteg:si_direcciones'||
								 ' WHERE numcte = c.numcte'||
								   ' AND tipo_dir = d.tipo_dir)'|| '"'||' >> querydir.sql';
LET v_sql13 ='echo "AND d.tipo_dir IN (''1'', ''2'')'||                       
			' AND d.fecha_insert BETWEEN ' || '''' || vfini ||''' AND '''||  vffin || ''''||
			' AND l.numerocalle = d.numerocalle'||
			' AND z.numerociudad =  d.numerociudad'|| '"'||' >> querydir.sql';
			
			
LET v_sql14 ='echo "AND z.numerocolonia = d.numerocolonia'||
			' AND s.pais = d.pais'||
			' AND s.estado = d.estado'||
			' AND s.ciudad = d.ciudad'|| 
		' INTO temp tmp_direcciones WITH NO LOG;'|| '"'||' >> querydir.sql';
			
			

LET v_sql15 = 'echo "SELECT num_cliente, 					LPAD(char_length(mti||num_cliente||accion||tipo||nombre||rfc||cod_pais_tel||cod_cd_tel||num_telefono||cod_pais_tel_mobil'|| '"'||' >> querydir.sql';


LET v_sql16 = 'echo "||cod_cd_tel_mobil||tel_mobil||calle||numero||cod_postal||complementos||colonia) + char_length(ciudad||estado||pais),4,0) AS cta,'|| '"'||' >> querydir.sql';

LET v_sql17 = 'echo "mti||num_cliente||accion||tipo||nombre||rfc||cod_pais_tel||cod_cd_tel||num_telefono||cod_pais_tel_mobil'||
        '||cod_cd_tel_mobil||tel_mobil||calle||numero||cod_postal||complementos||colonia AS trama1,'|| '"'||' >> querydir.sql';
		
		
LET v_sql18 = 'echo "ciudad||estado||pais AS trama2'||
		' FROM tmp_direcciones'||	
		' INTO temp tmp_final_direcciones WITH NO LOG;'|| '"'||' >> querydir.sql';

	
				
LET v_sql19 ='echo "UNLOAD TO ''direcc_'||vfechaini||'_al_'||vfechafin||'.unl'''||
			'SELECT (cta||trama1::LVARCHAR||trama2::LVARCHAR) FROM tmp_final_direcciones;'|| '"'||' >> querydir.sql';

		
					
	SYSTEM v_sql;
	SYSTEM v_sql2;
	SYSTEM v_sql3;
	SYSTEM v_sql4;
	SYSTEM v_sql5;
	SYSTEM v_sql6;
	SYSTEM v_sql7;
	SYSTEM v_sql8;
	SYSTEM v_sql9;
	SYSTEM v_sql10;
	SYSTEM v_sql11;
	SYSTEM v_sql12;
	SYSTEM v_sql13;
	SYSTEM v_sql14;
	SYSTEM v_sql15;
	SYSTEM v_sql16;
	SYSTEM v_sql17;
	SYSTEM v_sql18;
	SYSTEM v_sql19;
      LET v_sql = "dbaccess bdipayt querydir.sql";
    SYSTEM v_sql;	

	
	


--Comprimir Archivo 		
SYSTEM v_comprime;
      LET v_comprime = "gzip -9 'direcc_'"||vfechaini||"_al_"||vfechafin||".unl";
SYSTEM v_comprime;

		
    RETURN vcod_ret, 'PROCESO EXITOSO';
END PROCEDURE;