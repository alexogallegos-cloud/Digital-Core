CREATE PROCEDURE "informix".sp_pay_clientes_his(pinicio DATE, pfin DATE)
RETURNING VARCHAR(10), varchar(255);


	DEFINE v_sql1        		VARCHAR(250);
	DEFINE v_sql2        		VARCHAR(250);
	DEFINE v_sql3        		VARCHAR(250);
	DEFINE v_sql4        		VARCHAR(250);
	DEFINE v_sql5        		VARCHAR(250);
	DEFINE v_sql6        		VARCHAR(250);
	DEFINE v_sql7        		VARCHAR(250);

	
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
	   

--set debug file to "/tmp/sp_pay_clientes_his.out";
--TRACE ON;		

	LET v_sql1 = ''; 
	LET v_sql2 = ''; 
	LET v_sql3 = ''; 
	LET v_sql4 = ''; 
	LET v_sql5 = '';
	LET v_sql6 = ''; 
	LET v_sql7 = ''; 
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



--Obtencion de info clientes 

LET v_sql1 = 'echo "SELECT  ''9911'' AS mti,' ||  
			'LPAD(TRIM(c.numcte),15,''0'') AS no_cliente,'||
			'CASE WHEN c.fecha_alta = c.fecha_insert THEN ''0'''||
				 'WHEN c.fecha_alta > c.fecha_insert THEN ''1'''||
			'END AS accion, '|| '"'||' > qrycli.sql';		
			
LET v_sql2 = 'echo "RPAD((TRIM(c.apell_paterno)||'' ''||TRIM(c.apell_materno)||'' ''||TRIM(c.nombre1)||'' ''||TRIM(c.nombre2)),40, '' '') AS 	nombre,'||
			'LPAD(c.rfc,20,0) AS rfc,'||
			'TRIM(f.sexo) AS sexo,'|| '"'||' >> qrycli.sql';
			
LET v_sql3 = 'echo "TO_CHAR(f.fecha_nac,''%Y%m%d'') AS fecha_nac,'||
			'SUBSTR(e.razon_social,1,25) AS compania,'||
			'LPAD( 0 , 15, ''0'') AS ingreso'|| '"'||' >> qrycli.sql';
			
LET v_sql4 = 'echo " FROM bdinteg:si_cliente c,'||
			'bdinteg:si_ctepf f,'||
			'bdinteg:si_empresas e'||
		' WHERE c.numcte = f.numcte'|| '"'||' >> qrycli.sql';
		
LET v_sql5 = 'echo " AND c.fecha_alta >='|| '''' ||vfini|| '''' ||
		  ' AND c.fecha_insert BETWEEN '|| ''''|| vfini || '''' ||' AND '''|| vffin ||''''||
		  ' AND f.empresa = e.empresa'||
		  ' AND e.empresa = c.empresa '||
' INTO TEMP tmp_clientes_his WITH NO LOG;'|| '"'||' >> qrycli.sql';
		


LET v_sql6 = 'echo " SELECT  LPAD(CHAR_LENGTH(mti||no_cliente||accion||nombre||rfc||sexo||fecha_nac||compania||ingreso),4,0)||mti||no_cliente||'||
			   'accion||nombre||rfc||sexo||fecha_nac||compania||ingreso AS trama'||	
	    ' FROM tmp_clientes_his'|| '"'||' >> qrycli.sql';
		
LET v_sql7 = 'echo " INTO TEMP tmp_fin_clientes_his WITH NO LOG;'||	
	     ' UNLOAD TO ''clientes_'||vfechaini||'_al_'||vfechafin||'.unl'''||
	     ' SELECT * FROM tmp_fin_clientes_his;'  || '"'||' >> qrycli.sql';

		
					
	SYSTEM v_sql1;
	SYSTEM v_sql2;
	SYSTEM v_sql3;
	SYSTEM v_sql4;
	SYSTEM v_sql5;
	SYSTEM v_sql6;
	SYSTEM v_sql7;
      LET v_sql1 = "dbaccess bdipayt qrycli.sql ";
    SYSTEM v_sql1;		
	
	
--Comprimir Archivo 		


SYSTEM v_comprime;
      LET v_comprime = "gzip -9 'clientes_'"||vfechaini||"_al_"||vfechafin||".unl";
SYSTEM v_comprime;	

		
    RETURN vcod_ret, 'PROCESO EXITOSO';
END PROCEDURE;