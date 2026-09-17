CREATE PROCEDURE "informix".sp_pay_cuenta_his(pinicio DATE, pfin DATE)
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
	
	LET vfini = TO_CHAR(pinicio,'%m-%d-%Y') ;	
	LET vffin = TO_CHAR(pfin,'%m-%d-%Y');
	
--info cuenta cheq
LET v_sqld1 = 'echo "SELECT  ''9914'' AS mti,'||
        'LPAD(TRIM(c.num_cte), 15, ''0'') AS num_cte,'||
        'CASE WHEN c.producto=''2000'' THEN ''D'''||
             ' ELSE ''D'''||
            ' END  AS tipo_prod,'||
        'LPAD(TRIM(c.cuenta), 15, ''0'') AS num_cta,'|| '"'||' > qryctacheq.sql'; 
		
LET v_sqld2 = 'echo "LPAD(c.status_cta, 5, 0) AS estado,'||
        ' ''484'' AS cod_moneda,'||
        'LPAD(0 , 15 , ''0'')  AS lim_cred,'||
        'LPAD( 0 , 15, ''0'') AS disponible,'||
        'TO_CHAR(NVL(n.fecha_alta,MDY(1,1,1900)),''%Y%m%d'') AS fecha_apertura,'|| '"'||' >> qryctacheq.sql'; 
		
LET v_sqld3 = 'echo "CASE WHEN c.status_cta = ''2'''||
                    ' THEN TO_CHAR(NVL(c.fecha_proceso,MDY(1,1,1900)),''%Y%m%d'')'||  
        ' ELSE TO_CHAR(MDY(1,1,1900),''%Y%m%d'')'||	
        ' END AS fecha_cierre,'||
		'c.producto AS prod,'||
		'n.fecha_alta AS fecha'|| '"'||' >> qryctacheq.sql'; 
		
LET v_sqld4 = 'echo " FROM bdicheq:sc_maechq c,'||
          'bdicheq:sc_maenoc n'||
	 ' WHERE c.status_cta <> ''4'''||
		' AND c.empresa = ''001'''|| 
		' AND n.empresa = c.empresa'||	
		' AND n.cuenta = c.cuenta'||
		' AND n.fecha_alta BETWEEN '''|| vfini || '''' ||' AND '''|| vffin ||''''|| '"'||' >> qryctacheq.sql'; 

	
	
	
LET v_sqld5 = 'echo "INTO temp his_info_cta_cheq WITH NO LOG;'|| 
			'SELECT LPAD(char_length(mti||num_cte||tipo_prod||num_cta||estado||cod_moneda||'||
			'lim_cred||disponible||fecha_apertura||fecha_cierre),4,0)'||
			'||mti||num_cte'|| '"'||' >> qryctacheq.sql'; 
			
LET v_sqld6 = 'echo "||tipo_prod||num_cta||estado||cod_moneda||lim_cred||disponible||fecha_apertura||fecha_cierre AS trama'||
	  ' FROM his_info_cta_cheq'||
	  ' INTO temp his_cta_cheq WITH NO LOG;'|| '"'||' >> qryctacheq.sql'; 

	  
LET v_sqld7 = 'echo " UNLOAD TO ''cta_cheq_'||vfechaini||'_al_'||vfechafin||'.unl'''||
	  ' SELECT * FROM his_cta_cheq;'|| '"'||' >> qryctacheq.sql'; 
	  
	SYSTEM v_sqld1;
	SYSTEM v_sqld2;
	SYSTEM v_sqld3;
	SYSTEM v_sqld4;
	SYSTEM v_sqld5;
	SYSTEM v_sqld6;
	SYSTEM v_sqld7;
      LET v_sqld1 = "dbaccess bdipayt qryctacheq.sql";
    SYSTEM v_sqld1;  
	  
  
--Comprimir Archivo 		
SYSTEM v_comprime;
      LET v_comprime = "gzip -9 'cta_cheq_'"||vfechaini||"_al_"||vfechafin||".unl";
SYSTEM v_comprime;


--info cuenta cred

    --para activos
	LET v_sqlc1 = 'echo "SELECT  ''9914'' AS mti,'||
		'LPAD(TRIM(c.numcte), 15, ''0'') AS num_cte,'||
		'CASE WHEN c.num_producto = ''6001'' THEN ''C'''|| 
             ' ELSE ''C'''||
          ' END AS tipo_prod,'||
        'LPAD(TRIM(c.num_credito), 15, ''0'') AS num_cta,'|| '"'||' > qryctacred.sql';
		--IFRS Se contemplan los nuevos estatus de crÃ©dito por Etapas
	LET v_sqlc2 = 'echo "CASE WHEN c.id_unidad_prod IS NOT NULL THEN ''00003'''||' >> qryctacred.sql';

			--' WHEN c.status_cred = ''AA'' AND  c.id_unidad_prod IS NULL THEN  ''00001'''||
            --' WHEN c.status_cred = ''BA'' AND  c.id_unidad_prod IS NULL THEN  ''00001'''|| '"'||' >> qryctacred.sql';
			 
--	LET v_sqlc3 = 'echo " WHEN c.status_cred = ''BT'' AND  c.id_unidad_prod IS NULL THEN  ''00001'''||
	LET v_sqlc3 = 'echo " ELSE ''00001'''||
          ' END AS estado,'|| 
        '''484'' AS cod_moneda,'||
        'LPAD(REPLACE(CAST(NVL(m.monto_otorgado,0) AS DECIMAL(13,2)),''.'','''') ,15,0) AS lim_cred,'|| '"'||' >> qryctacred.sql';
		
	LET v_sqlc4 = 'echo "CASE WHEN (m.monto_otorgado-m.sdo_cap_insoluto-m.sdo_retenido) < 0'||
             ' THEN  ''-''||LPAD(REPLACE((REPLACE(CAST(NVL((m.monto_otorgado-m.sdo_cap_insoluto-m.sdo_retenido),0) AS DECIMAL(13,2)),''.'',''''))'||
			 ',''-'',''''),14,0)'|| '"'||' >> qryctacred.sql';  
			 
	LET v_sqlc5 = 'echo " ELSE LPAD(REPLACE(CAST(NVL((m.monto_otorgado-m.sdo_cap_insoluto-m.sdo_retenido),0) AS DECIMAL(13,2)),''.'','''') ,15,0)'|| 
          ' END AS disponible,'|| 
        'TO_CHAR(NVL(c.fecha_apertura,MDY(1,1,1900)),''%Y%m%d'') AS fecha_apertura,'|| '"'||' >> qryctacred.sql';
		
	LET v_sqlc6 = 'echo "TO_CHAR(MDY(1,1,1900),''%Y%m%d'') AS fecha_cierre,'||
		'c.num_producto AS prod,'||
		'c.fecha_apertura AS fecha'||
	 ' FROM bdicred:sd_maecred c,'||
          'bdicred:sd_maesdos m'|| '"'||' >> qryctacred.sql';
	--IFRS Se contemplan los nuevos estatus de crÃ©dito por Etapas	  
	LET v_sqlc7 = 'echo " WHERE c.empresa = ''001'''|| 
        ' AND c.num_credito = m.num_credito'|| 
		' AND c.status_cred IN (''AA'', ''BA'', ''BT'',''E1'', ''E2'', ''E3'')'||
       --' AND c.status_cred IN (''AA'', ''BA'', ''BT'')'||
		' AND c.fecha_apertura BETWEEN '''|| vfini || '''' ||' AND '''|| vffin ||''''|| 
		' INTO temp his_info_cta_cred_act WITH NO LOG;'||'"'||' >> qryctacred.sql';
		
	LET v_sqlc8 = 'echo " SELECT LPAD(char_length(mti||num_cte||tipo_prod||num_cta||estado||cod_moneda||'||
					'lim_cred||disponible||fecha_apertura||fecha_cierre),4,0)'||
					'||mti||num_cte||tipo_prod||num_cta||estado||cod_moneda||lim_cred||disponible||'||'"'||' >> qryctacred.sql';
			
	LET v_sqlc9 = 'echo "fecha_apertura||fecha_cierre AS trama'||
					' FROM his_info_cta_cred_act'||
					' INTO temp his_cta_cred WITH NO LOG;'||
		' UNLOAD TO ''cta_cred_'||vfechaini||'_al_'||vfechafin||'.unl'''||
	  ' SELECT * FROM his_cta_cred;'|| '"'||' >> qryctacred.sql'; 
	

	
	SYSTEM v_sqlc1;
	SYSTEM v_sqlc2;
	SYSTEM v_sqlc3;
	SYSTEM v_sqlc4;
	SYSTEM v_sqlc5;
	SYSTEM v_sqlc6;
	SYSTEM v_sqlc7;
	SYSTEM v_sqlc8;
	SYSTEM v_sqlc9;
      LET v_sqlc1 = "dbaccess bdipayt qryctacred.sql";
    SYSTEM v_sqlc1;
	
	--Comprimir Archivo 		
SYSTEM v_comprime2;
      LET v_comprime2 = "gzip -9 'cta_cred_'"||vfechaini||"_al_"||vfechafin||".unl";
SYSTEM v_comprime2;
		
    RETURN vcod_ret, 'PROCESO EXITOSO';
END PROCEDURE;