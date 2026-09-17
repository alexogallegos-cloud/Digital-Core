CREATE PROCEDURE "informix".sp_tarj_det_vcas_test()
RETURNING VARCHAR(10), VARCHAR(255)

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
	
	--set debug file to "/tmp/sp_tarj_det_vcas.out";
	--TRACE ON;
				
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
	 
  -- CREAR TEMPORALES PARA RESULTADO FINAL
    SELECT {+AVOID_FULL(intercard:info_tarjeta_pyt)} numtarjeta, fechaasignacion
    FROM intercard:info_tarjeta_pyt
    WHERE codstatustarjeta = 'ACT'
    AND fechaasignacion>=vfecha
    INTO temp tmptarj with no log;

	CREATE INDEX "informix".tmp_tartarj_vcas
    ON tmptarj(numtarjeta);
	
	SELECT bin 
	FROM intercard:bines WHERE marca ='VS'
	INTO temp BIN_VISA with no log;

    --TARJETAS DE CREDITO
    SELECT numcte,num_tarjeta 
    FROM bdicred:sd_tarjeta
    WHERE empresa= '001' AND num_tarjeta IN (SELECT numtarjeta FROM tmptarj GROUP BY numtarjeta)
    INTO temp tmpctestarj with no log;

    CREATE INDEX "informix".tmp_cte_pt
        ON tmpctestarj(numcte);

    CREATE INDEX "informix".tmp_tarj_pt
        ON tmpctestarj(num_tarjeta);

    --TARJETAS DE DEBITO
    INSERT INTO tmpctestarj
    SELECT numcte, num_tarjeta 
    FROM bdicheq:sc_tarjeta
    WHERE empresa= '001' AND num_tarjeta IN (SELECT numtarjeta FROM tmptarj GROUP BY numtarjeta);
	
    -- TABLA TELEONOS TIPO 2
	SELECT {+AVOID_FULL(bdinteg:si_telefonos_actual)} telefono, numcte, status_tel, fecha_hora
    FROM bdinteg:si_telefonos_actual
    WHERE tipo_tel = 2 
    INTO temp tmptelefono_tipo2 with no log;
	
	CREATE INDEX "informix".tmptelefono_tipo2_idx1  ON tmptelefono_tipo2(status_tel,fecha_hora); 
    CREATE INDEX "informix".tmptelefono_tipo2_idx2  ON tmptelefono_tipo2(numcte); 
	

    --TEMPORAL DE TELEONOS
	SELECT telefono, numcte
    FROM tmptelefono_tipo2 WHERE status_tel = 'A' and fecha_hora >= vfecha
    GROUP BY telefono, numcte
    UNION 
    SELECT telefono, numcte
    FROM tmptelefono_tipo2 WHERE numcte IN (SELECT numcte FROM tmpctestarj WHERE 1=1) AND status_tel = 'A'
    GROUP BY telefono, numcte 
    INTO temp tmptelefono with no log;
	
	CREATE INDEX "informix".tmptelefono_idx1 ON tmptelefono(telefono);
    CREATE INDEX "informix".tmptelefono_idx2 ON tmptelefono(numcte);


    -- TABLA CORREOS  TIPO 1
	SELECT {+AVOID_FULL(bdinteg:si_correos)} tipo_correo, status_correo, secuencia, valido, numcte, correo_elec, fecha_hora
    FROM bdinteg:si_correos C
    WHERE C.tipo_correo = 1 AND C.status_correo = 'A' AND C.valido = 1 
	INTO temp tmpsi_correos with no log;
	
	CREATE INDEX "informix".tmpsi_correos_idx1 ON tmpsi_correos(tipo_correo,status_correo,fecha_hora, valido);
	CREATE INDEX "informix".tmpsi_correos_idx2 ON tmpsi_correos(numcte,tipo_correo,status_correo,valido);
	
	--TEMPORAL DE CORREOS
	
	SELECT correo_elec, numcte
    FROM bdinteg:tmpsi_correos C
    WHERE numcte IN  (SELECT numcte FROM tmpctestarj WHERE 1=1)
	AND C.tipo_correo = 1 AND C.status_correo = 'A' AND C.valido = 1
    GROUP BY correo_elec, numcte
	UNION
	SELECT correo_elec, numcte
    FROM bdinteg:tmpsi_correos C
    WHERE C.tipo_correo = 1 AND C.status_correo = 'A' AND fecha_hora >= vfecha AND C.valido = 1 
	GROUP BY correo_elec, numcte
	INTO temp tmpcorreo with no log;

    CREATE INDEX "informix".tmp_correlec_vcas
    ON tmpcorreo(correo_elec);

    CREATE INDEX "informix".tmp_numctecorr_vcas
    ON tmpcorreo(numcte);

   --TARJETAS DE CREDITO CTES
    SELECT numcte,num_tarjeta 
    FROM bdicred:sd_tarjeta
    WHERE empresa= '001' AND numcte IN (SELECT numcte FROM tmpcorreo UNION ALL SELECT numcte FROM tmptelefono)
    INTO temp tmpctestarjfin with no log;

    CREATE INDEX "informix".tmp_cte_pts
        ON tmpctestarjfin(numcte);

    CREATE INDEX "informix".tmp_tarj_pts
        ON tmpctestarjfin(num_tarjeta);

    --TARJETAS DE DEBITO CTES
    INSERT INTO tmpctestarjfin
    SELECT numcte, num_tarjeta 
    FROM bdicheq:sc_tarjeta
    WHERE empresa= '001' AND numcte IN (SELECT numcte FROM tmpcorreo UNION ALL SELECT numcte FROM tmptelefono);

	--CTES CON TARJETAS ACTUALIZADAS
    SELECT {+AVOID_FULL(intercard:info_tarjeta_pyt)} numtarjeta, A.fechaasignacion, B.numcte
    FROM intercard:info_tarjeta_pyt A, tmpctestarjfin B
    WHERE A.numtarjeta=B.num_tarjeta AND codstatustarjeta = 'ACT'
    GROUP BY A.numtarjeta, A.fechaasignacion, B.numcte
    INTO temp tmptarjeta with no log;

    CREATE INDEX "informix".tmp_numtarj_vcas
    ON tmptarjeta(numtarjeta);

    CREATE INDEX "informix".tmp_numclient_vcas
    ON tmptarjeta(numcte);

    CREATE INDEX "informix".tmp_fechasig_vcas
    ON tmptarjeta(fechaasignacion);
    
	-- INFORMACION QUE SE EJECUTARA CADA DETERMINADO TIEMPO.
		BEGIN WORK;
		FOREACH WITH HOLD
            SELECT CASE WHEN A.fechaasignacion >= vfecha THEN 'ADD' ELSE 'UPDATE' END AS action,
				A.numtarjeta, 
				B.telefono AS telefono, 
				C.correo_elec AS correo_elec, 
				CURRENT AS fecha
            INTO var_action, var_numtarjeta, var_telefono, var_correo_elec, var_fecha
            FROM tmptarjeta A
            LEFT JOIN tmptelefono B ON A.numcte=B.numcte
            LEFT JOIN tmpcorreo C ON A.numcte=C.numcte
            WHERE SUBSTR(A.numtarjeta,1,6) IN (SELECT bin FROM BIN_VISA )
			AND((B.telefono IS NOT NULL)OR(C.correo_elec IS NOT NULL))            
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
			
		   --SE AÃADEN LOS ENCABEZADOS Y LOS RESULTADOS EXTRAIDOS AL ARCHIVO AUXILIAR.
			LET v_sql = "sed 's/$//g' "|| TRIM(cRuta) || "queryenc.sql >> " || TRIM (cNombreArchivo2);
            SYSTEM TRIM(v_sql);

            LET v_sql="";

			LET v_sql = "sed 's/$//g' "|| TRIM (cNombreArchivo1) || " >> " || TRIM (cNombreArchivo2);
            SYSTEM TRIM(v_sql);

            --SE PASA LA INFORMACION DESCARGADA AL ARCHIVO FINAL.
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
	SELECT MAX(fecha::DATETIME YEAR TO SECOND + INTERVAL (01) SECOND(2) TO SECOND )
	  INTO vfecha 	
	  FROM intercard:ctas_vcas;

	IF  vfecha  IS NULL THEN 
	     LET vfecha = CURRENT;
	END IF 
	 
	-- CONTEO DE REGISTROS.
	SELECT COUNT(*) 
	  INTO vreg_ins
	  FROM intercard:ctas_vcas;
				
	-- ELIMINA REGISTROS DE TABLA DE RESULTADOS Y TEMPORALES.
     TRUNCATE TABLE intercard:ctas_vcas;
	 
	 DROP TABLE BIN_VISA;
	 DROP TABLE tmpctestarj;
     DROP TABLE tmptelefono;
     DROP TABLE tmpcorreo;
	 DROP TABLE tmptarjeta;	
     DROP TABLE tmptarj;
     DROP TABLE tmpctestarjfin;
	 		
	-- ACTUALIZAR TABLA CONTROL.
	  UPDATE intercard:ctrl_info_ctes_vcas
	    SET ( fecha, status_proc,cod_err, descripcion_err, reg_insertados) = ( vfecha, '0', vcod_ret, 'DESCARGA EXITOSA', vreg_ins);		

			  
    RETURN vcod_ret, 'DESCARGA EXITOSA';
END PROCEDURE;