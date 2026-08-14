CREATE PROCEDURE "informix".sp_tarj_det_vcas_mx2()
RETURNING VARCHAR(10), VARCHAR(255);

	DEFINE vfecha			DATETIME YEAR TO FRACTION(5);
	DEFINE vstatus_proc		CHAR(1);
	
	DEFINE vcod_ret         VARCHAR(10); 
	DEFINE sql_err          INTEGER;
	DEFINE isam_err         INTEGER;
	DEFINE error_info       CHAR(40);
	
	DEFINE v_dia        	CHAR(2);
    DEFINE v_mes        	CHAR(2);
    DEFINE v_ano        	CHAR(4); 
	DEFINE v_hora			DATETIME HOUR TO SECOND;
    DEFINE v_hora2			CHAR(8);
    DEFINE v_sql        	CHAR(250);
    DEFINE cEncabezado  	CHAR(250);
	
	DEFINE cRuta			CHAR(250);
    DEFINE cRuta2			CHAR(250);
	DEFINE cNombreArchivo 	CHAR(250);
    DEFINE cNombreArchivo1 	CHAR(250);
    DEFINE cNombreArchivo2 	CHAR(250);

    DEFINE var_action 		CHAR(6);
	DEFINE var_numtarjeta   VARCHAR(16);
	DEFINE var_telefono     CHAR(13);
	DEFINE var_correo_elec 	CHAR(100);
	DEFINE var_fecha        DATETIME YEAR to SECOND;
	
	DEFINE iContador_pay    SMALLINT;
    
	DEFINE vreg_ins 		INTEGER;

	--MANEJO DEL ERROR.
       ON EXCEPTION
		SET sql_err, isam_err, error_info
			
			UPDATE intercard:ctrl_info_ctes_vcas
			  SET status_proc = '0';

           IF sql_err <> 0 THEN
              LET vcod_ret=sql_err;
			  UPDATE intercard:ctrl_info_ctes_vcas 
					SET(cod_err, descripcion_err) = (vcod_ret, isam_err||' ' ||error_info);
              RETURN vcod_ret, isam_err||' ' ||error_info;
           END IF;
       END EXCEPTION;
	
	/*set debug file to "/tmp/sp_tarj_det_vcas.out";
	TRACE ON;*/	
				
	LET vfecha = TODAY;	
	LET vstatus_proc = '';
	
	LET vcod_ret = '000';          
	LET sql_err = 0;          
	LET isam_err = 0;        
	LET error_info = '';
	LET iContador_pay = 0;
	
	LET v_dia           = "";
    LET v_mes           = "";
    LET v_ano           = "";  
	LET v_hora			= CURRENT;
    LET v_hora2			= "";
    LET v_sql           = "";
	
    LET cEncabezado     = "";
	
	LET cRuta	= "/tmp/";
    LET cRuta2	= "/RESPALDOSNEW/VCAS_resultados/";
	LET cNombreArchivo	= "";
    LET cNombreArchivo1	= "";
    LET cNombreArchivo2	= "";

    LET var_action 			= "";
	LET var_numtarjeta      = "";
	LET var_telefono       	= "";
	LET var_correo_elec 	= "";
	LET var_fecha          	= CURRENT;
		
	LET vreg_ins = 0;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	  
	SELECT status_proc 
	INTO vstatus_proc
	FROM intercard:ctrl_info_ctes_vcas;

	IF(vstatus_proc = '1') THEN
		UPDATE intercard:ctrl_info_ctes_vcas 
			SET(cod_err, descripcion_err) = (vcod_ret, 'DESCARGA EN PROCESO');
		RETURN vcod_ret, 'DESCARGA EN PROCESO';
	END IF;
    
    UPDATE intercard:ctrl_info_ctes_vcas
	SET status_proc = '1';  
	  
	SELECT fecha
	INTO vfecha	
    FROM intercard:ctrl_info_ctes_vcas;			 	
	
	-- ELIMINA REGISTROS DE TABLA DE RESULTADOS EN CASO DE QUE HAYA FALLADO EL SP Y HAYA GENERADO INFORMACION.
     TRUNCATE TABLE intercard:ctas_vcas;

	SELECT numtarjeta,numcliente,fechaultmodif,fechaasignacion
	FROM intercard:tarjeta
	WHERE LEFT(numtarjeta,6) IN (SELECT bin FROM intercard:bines WHERE marca ='VS')
                AND codstatusasignada = 'SIA'
                AND codstatustarjeta = 'ACT'
	INTO temp tmptarjeta with no log;

    CREATE INDEX "informix".tmp_numtarj_vcas
    ON "informix".tmptarjeta(numtarjeta);

    CREATE INDEX "informix".tmp_numclient_vcas
    ON "informix".tmptarjeta(numcliente);

    CREATE INDEX "informix".tmp_fechmod_vcas
    ON "informix".tmptarjeta(fechaultmodif);

    CREATE INDEX "informix".tmp_fechasig_vcas
    ON "informix".tmptarjeta(fechaasignacion);
					
		-- INFORMACIÓN QUE SE EJECUTARÁ CADA DETERMINADO TIEMPO.
		BEGIN WORK;
		FOREACH WITH HOLD
            SELECT CASE WHEN A.fechaasignacion >= vfecha THEN 'ADD' ELSE 'UPDATE' END AS action,
				A.numtarjeta, 
				B.telefono AS telefono, 
				C.correo_elec AS correo_elec, 
				CURRENT AS fecha
            INTO var_action, var_numtarjeta, var_telefono, var_correo_elec, var_fecha
            FROM tmptarjeta A
            LEFT JOIN bdinteg:si_telefonos_actual B ON A.numcliente=B.numcte AND B.tipo_tel=2 AND B.status_tel = 'A' 
            LEFT JOIN bdinteg:si_correos C ON A.numcliente=C.numcte AND C.tipo_correo = 1 AND C.status_correo = 'A' AND C.valido=1 AND C.secuencia =(SELECT MAX(secuencia) FROM bdinteg: si_correos f WHERE C.numcte=f.numcte AND f.tipo_correo = 1 AND f.status_correo = 'A' AND f.valido=1)
            WHERE ((B.telefono IS NOT NULL)OR(C.correo_elec IS NOT NULL))
              AND ((A.fechaultmodif>=vfecha)OR(B.fecha_hora>=vfecha)OR(C.fecha_hora>=vfecha))
            GROUP BY A.numtarjeta, B.telefono, C.correo_elec,fecha,action
			
			LET iContador_pay = iContador_pay + 1;
			
			INSERT INTO "informix".ctas_vcas(action, numtarjeta, telefono, correo_elec, fecha) 
                    VALUES(var_action, var_numtarjeta, var_telefono, var_correo_elec, var_fecha);
        
          IF iContador_pay = 1000 THEN
		  COMMIT;
		  LET	iContador_pay = 0;
		  BEGIN WORK;
		  END IF;
	END FOREACH;	
	COMMIT; 
		
	-- DESCARGAR ARCHIVO.
		   LET v_dia = LPAD(DAY(CURRENT),2,'0');  
		   LET v_mes = LPAD(MONTH(CURRENT),2,'0');
		   LET v_ano = year(CURRENT);
           LET v_hora2 = v_hora::CHAR(8);
		   LET cNombreArchivo = TRIM(cRuta2)||'ISSUERNAME'||v_ano||v_mes||v_dia||SUBSTR(v_hora2,1,2)||SUBSTR(v_hora2,4,2)||SUBSTR(v_hora2,7,2)||'.csv';
           LET cNombreArchivo1 = TRIM(cRuta)||'ISSUERNAME'||v_ano||v_mes||v_dia||'_aux.csv';
           LET cNombreArchivo2 = TRIM(cRuta)||'ISSUERNAME'||v_ano||v_mes||v_dia||'_aux2.csv';
		          
		   -- DESCARGA DEL ARCHIVO .CSV.
			LET cEncabezado = 'echo "action,pan,mobilenumber,email,segmentationindicator," > /tmp/queryenc.sql';
            System cEncabezado;

			LET v_sql = 'echo "UNLOAD TO ' || TRIM (cNombreArchivo1) || ' DELIMITER '',''" > /tmp/queryhist.sql ';
			System v_sql;
			
			LET v_sql = 'echo "SELECT action,numtarjeta AS pan, ''+52''||RIGHT(LTRIM(RTRIM(telefono)),10) AS mobilenumber," >> /tmp/queryhist.sql ';
			System v_sql;

            LET v_sql = 'echo "LTRIM(RTRIM(correo_elec)) AS email, ''01'' AS segmentationindicator" >> /tmp/queryhist.sql ';
			System v_sql;
			
			LET v_sql = 'echo " from intercard:ctas_vcas  where numtarjeta <> ''''" >> /tmp/queryhist.sql';						
			System v_sql;
						
			LET v_sql = "dbaccess intercard /tmp/queryhist.sql";
			System v_sql;

			LET v_sql="";
			
		   --SE AÑADEN LOS ENCABEZADOS Y LOS RESULTADOS EXTRAÍDOS AL ARCHIVO AUXILIAR.
			LET v_sql = "sed 's/$//g' "|| TRIM(cRuta) || "queryenc.sql >> " || TRIM (cNombreArchivo2);
            SYSTEM TRIM(v_sql);

            LET v_sql="";

			LET v_sql = "sed 's/$//g' "|| TRIM (cNombreArchivo1) || " >> " || TRIM (cNombreArchivo2);
            SYSTEM TRIM(v_sql);

            --SE PASA LA INFORMACIÓN DESCARGADA AL ARCHIVO FINAL.
            LET v_sql = "";
            LET v_sql = "sed -e 's/.$//' "|| TRIM(cNombreArchivo2) || " >> " || TRIM (cNombreArchivo);
            SYSTEM v_sql;

			--BORRADO DE SCRIPTS GENERADOS EN EL PROCESO.
            LET v_sql = "";
            LET v_sql = "rm " || TRIM(cRuta) || "queryhist.sql";	
            SYSTEM TRIM(v_sql);

            LET v_sql = "";
            LET v_sql = "rm " || TRIM(cRuta) || "queryenc.sql";	
            SYSTEM TRIM(v_sql);

            LET v_sql = "";
            LET v_sql = "rm " || TRIM(cNombreArchivo1);	
            SYSTEM TRIM(v_sql);

            LET v_sql = "";
            LET v_sql = "rm " || TRIM(cNombreArchivo2);	
            SYSTEM TRIM(v_sql);

	-- DATOS PARA LA TABLA CONTROL.
	SELECT MAX(fecha) 
	  INTO vfecha 	
	  FROM intercard:ctas_vcas;
	  
	-- CONTEO DE REGISTROS.
	SELECT COUNT(*) 
	  INTO vreg_ins
	  FROM intercard:ctas_vcas;
				
	-- ELIMINA REGISTROS DE TABLA DE RESULTADOS Y TEMPORALES.
     TRUNCATE TABLE intercard:ctas_vcas;
	 DROP TABLE tmptarjeta;
	 		
	-- ACTUALIZAR TABLA CONTROL.
	  UPDATE intercard:ctrl_info_ctes_vcas
	    SET ( fecha, status_proc,cod_err, descripcion_err, reg_insertados) = ( vfecha, '0', vcod_ret, 'DESCARGA EXITOSA', vreg_ins);		
				  
    RETURN vcod_ret, 'DESCARGA EXITOSA';
END PROCEDURE;