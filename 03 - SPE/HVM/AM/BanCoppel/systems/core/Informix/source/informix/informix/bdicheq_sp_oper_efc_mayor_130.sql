CREATE PROCEDURE "informix".sp_oper_efc_mayor_130( pempresa char(3))
RETURNING   CHAR(5);


DEFINE vsqlerr    INTEGER;
DEFINE vcodret    CHAR(5);
DEFINE v_num_cte  CHAR(20);
DEFINE vcuenta    CHAR(20);
DEFINE v_monto    MONEY(14,2);
DEFINE v_nombre   CHAR(255);
DEFINE v_desc     CHAR(255);
DEFINE v_transa   CHAR(4);
DEFINE v_fecha    DATE;
DEFINE v_fecha_hoy    DATE;
DEFINE v_primer_dia   DATE;
DEFINE v_primer_dia_0 DATE;
DEFINE v_ultimo_dia  DATE; 
DEFINE v_anio_fin      INTEGER;
DEFINE v_mes_fin       CHAR(2);
DEFINE v_dia_fin       CHAR(2);
DEFINE v_f_fin         VARCHAR(8);
DEFINE vsql            CHAR(500);
DEFINE v_mes_ini       CHAR(2);
DEFINE v_mes_fina       CHAR(2);
DEFINE v_anio          INTEGER;
--DEFINE v_num_cte       CHAR(20);
DEFINE v_cuenta        CHAR(20);
DEFINE v_monto_tot     MONEY(14,2);
DEFINE v_fech_alt      DATE;
--DEFINE v_nombre        CHAR(255);
DEFINE vsflagentransaccion     CHAR(1);
DEFINE vicontadorregistros     INTEGER;
DEFINE vEstatus        INTEGER;
DEFINE vMaxFecha               INTEGER; 

LET v_num_cte   = "";
LET v_cuenta    = "";
LET v_monto_tot = 0;
LET v_nombre    = "";
LET vCuenta     = 0;
LET vEstatus    = 0;
LET vMaxFecha   = 0;

LET vsqlerr = 0; 
LET vcodret = "00000";



BEGIN
	 ON EXCEPTION SET vsqlerr
	    SET DEBUG FILE TO "/resplogifx/conciliachq/oper_130.txt";
	 	   TRACE ON;
            IF vsqlerr <> 0 THEN
               LET vcodret = vsqlerr;
            RETURN vcodret;
            END IF;
     END EXCEPTION;
	
    ---SET DEBUG FILE TO '/informix/rsv/operaciones_mayores/info_oper_130.txt';
    ---TRACE ON;
	
	 SET ISOLATION TO DIRTY READ;
	 SET LOCK MODE TO WAIT 3;
	 SELECT fecha_hoy,   DATE(pri_dia_mes - 3 UNITS MONTH), DATE(pri_dia_mes - 1  UNITS DAY),pri_dia_mes   
	   INTO v_fecha_hoy, v_primer_dia                     , v_ultimo_dia                    ,v_primer_dia_0
	   FROM sc_fechas
	  WHERE empresa = pempresa;
	
	--LET v_primer_dia ='04012024';
	--LET v_ultimo_dia = '06302024';
	--LET v_fecha_hoy = '07012024';

     ---LIMPIAMOS LA TABLA    
     --BEGIN;
     --TRUNCATE TABLE sc_oper_efec; 
     --COMMIT; 
	
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
		 
		 
		 ---VALIDACION PARA LA DESCARGA DE INFORMACION 
		 --IF v_mes_fin = '04'  THEN 
		 --   LET v_mes_ini  = '01';
		 --	LET v_mes_fina  = '03';
		 --	LET v_anio_fin = v_anio_fin; 
	     --END IF; 
		 
		 
		 --IF v_mes_fin = '07'  THEN 
		 --   LET v_mes_ini  = '04';
	     --		LET v_mes_fina  = '06';
	 	 -- 	LET v_anio_fin = v_anio_fin; 
	     --END IF; 
		 
		 --IF v_mes_fin = '10'  THEN 
		 --   LET v_mes_ini  = '07';
		 --	LET v_mes_fina  = '09';
		 --	LET v_anio_fin = v_anio_fin; 
	     --END IF; 
		 
		 --IF v_mes_fin = '01'  THEN 
		 --   LET v_mes_ini  = '10';
		 --	LET v_mes_fina  = '12';
		 --	LET v_anio_fin = v_anio_fin - 1; 
	     --END IF; 

		--VALIDA QUE NO SE HAYA EJECUTADO EL SP EN EL PERIODO
		SELECT COUNT(*),estatus INTO vCuenta,vEstatus FROM sc_control_procesos WHERE proceso='sp_oper_efc_mayor_130' AND fecha = v_primer_dia_0 GROUP BY 2;
		
		IF vCuenta = 0 OR vCuenta IS NULL THEN
           --LIMPIA TABLA DETECTA QUE SE EJECUTA EL SP POR PRIMERA VEZ 
		   BEGIN;
		   		INSERT INTO sc_control_procesos VALUES('sp_oper_efc_mayor_130',v_primer_dia_0,0);
		   COMMIT;	 
		   BEGIN;
		   TRUNCATE TABLE sc_oper_efec; 
		   COMMIT;
		END IF; 
		IF vCuenta = 1 AND vEstatus=1 THEN
		   --LIMPIA TABLA DETECTA QUE YA SE HABIA EJECUTADO EL SP EN EL PERIODO Y LO REPROCESA DESDE CERO
           BEGIN;
           TRUNCATE TABLE sc_oper_efec; 
           COMMIT;
           BEGIN;
                UPDATE sc_control_procesos SET estatus=0 WHERE proceso='sp_oper_efc_mayor_130' AND fecha= v_primer_dia_0;
           COMMIT;
        ELSE 
			IF vCuenta = 1 AND vEstatus=0 THEN
		        --LIMPIA TABLA DETECTA QUE EL SP NO CONCLUYO EN SU ANTERIOR EJECUCION E INICIA EN EL PUNTO EN EL CUAL SE QUEDO 
				SELECT MAX(fecha)
				INTO vMaxFecha
				FROM bdicheq:sc_oper_efec WHERE fecha >= v_primer_dia and fecha <= v_ultimo_dia;
			    LET v_primer_dia = vMaxFecha; 
                DELETE FROM bdicheq:sc_oper_efec where fecha >= v_primer_dia AND fecha <=v_ultimo_dia; 	
			END IF; 
		END IF; 	
		
		WHILE v_primer_dia<=v_ultimo_dia 
			LET vsflagentransaccion = 'F';		   
			LET vicontadorregistros = 0;
					
			foreach cur_sc_movhis_01 with hold
			for
			 SELECT
					mc.num_cte,
					mc.cuenta,
					mh.monto_tot,
					mh.fech_alt,
					TRIM(NVL(TRIM(cte.nombre1), "")||' '||
						 NVL(TRIM(cte.nombre2), "")||' '||
						 NVL(TRIM(cte.apell_paterno), "")||' '||
						 NVL(TRIM(cte.apell_materno), "")||' '||
						 NVL(TRIM(cte.razon_social), "")) AS nombre   
			   INTO v_num_cte,v_cuenta,v_monto_tot,v_fech_alt,v_nombre				 
			   FROM sc_movhis  AS mh, 
					sc_maechq  AS mc,
					bdinteg:si_cliente AS cte
					--bdinteg:si_transacc AS tra
			  WHERE 
				mh.cuenta =  mc.cuenta
				--AND mh.fech_alt  BETWEEN v_primer_dia AND v_ultimo_dia
				AND mh.fech_alt = v_primer_dia
				AND mh.cancelad <> 'S'
				AND mh.transacc IN ('0202','0282','0325','0223')
				--AND mh.transacc = tra.numero
				AND mc.num_cte  = cte.numcte
				AND mh.monto_tot > 130000.00
				
					if(vsflagentransaccion = 'F') then
						begin work;
						let vsflagentransaccion = 'V';
					end if;
					INSERT INTO sc_oper_efec(cliente,cuenta,monto,fecha,nombre)
                    VALUES(v_num_cte,v_cuenta,v_monto_tot,v_fech_alt,v_nombre);
					let vicontadorregistros = vicontadorregistros + 1;
							
							if (vicontadorregistros = 500) then
								commit work;
								let vsflagentransaccion = 'F';
								let vicontadorregistros = 0;
								continue foreach;
							end if;
			end foreach;     
			if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
				commit work;
				let vsflagentransaccion = 'F';
			end if;
			 
			LET vsflagentransaccion = 'F';	   
			LET vicontadorregistros = 0;	 
			foreach cur_sc_movhis_02 with hold
			for
			 SELECT 
					mc.num_cte,
					mc.cuenta,
					mh.monto_tot,
					mh.fech_alt,
					TRIM(NVL(TRIM(cte.nombre1), "")||' '||
						 NVL(TRIM(cte.nombre2), "")||' '||
						 NVL(TRIM(cte.apell_paterno), "")||' '||
						 NVL(TRIM(cte.apell_materno), "")||' '||
						 NVL(TRIM(cte.razon_social), "")) AS nombre 
			   INTO v_num_cte,v_cuenta,v_monto_tot,v_fech_alt,v_nombre
			   FROM sc_movhis_old AS mh, 
					sc_maechq     AS mc,
					bdinteg:si_cliente AS cte
				--	bdinteg:si_transacc AS tra
			  WHERE
				mh.cuenta =  mc.cuenta 
			    --AND mh.fech_alt  BETWEEN v_primer_dia AND v_ultimo_dia
				AND mh.fech_alt = v_primer_dia
				AND mh.cancelad <> 'S'
				AND mh.transacc IN ('0202','0282','0325','0223')
				--AND mh.transacc = tra.numero
				AND mc.num_cte  = cte.numcte
				AND mh.monto_tot > 130000.00
				
				if(vsflagentransaccion = 'F') then
					begin work;
					let vsflagentransaccion = 'V';
				end if;
				
				INSERT INTO sc_oper_efec(cliente,cuenta,monto,fecha,nombre)
                VALUES(v_num_cte,v_cuenta,v_monto_tot,v_fech_alt,v_nombre);
				let vicontadorregistros = vicontadorregistros + 1;
							
				if (vicontadorregistros = 500) then
					commit work;
					let vsflagentransaccion = 'F';
					let vicontadorregistros = 0;
					continue foreach;
				end if;
			end foreach;     
			if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
				commit work;
				let vsflagentransaccion = 'F';
			end if;	 	  
		LET v_primer_dia = v_primer_dia + 1 UNITS DAY;
		END WHILE;
		
		UPDATE STATISTICS MEDIUM FOR TABLE sc_oper_efec(cliente);
		
		 --PROCESO PARA LA DESCARGA DEL ARCHIVO 
		 LET vsql = '';
         LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
                    'UNLOAD TO  /resplogifx/conciliachq/619_REP_TRI_OPER_EFC_MAYOR_130_PRO_'||v_f_fin||'.txt'||
                    ' SELECT * FROM sc_oper_efec " >  /resplogifx/conciliachq/consulta_saldos.sql';
           
          SYSTEM vsql;
           
          --EJECUCION DEL ARCHIVO .SQL
          LET vsql = '';
          LET vsql = "dbaccess bdicheq  /resplogifx/conciliachq/consulta_saldos.sql";
          SYSTEM vsql;
	
        IF vCuenta = 1 AND vEstatus=0 THEN
        	BEGIN;
            	UPDATE sc_control_procesos SET estatus=1 WHERE proceso='sp_oper_efc_mayor_130' AND fecha= v_primer_dia_0;
			COMMIT;
        END IF; 
RETURN  vcodret;
END; 
END PROCEDURE;