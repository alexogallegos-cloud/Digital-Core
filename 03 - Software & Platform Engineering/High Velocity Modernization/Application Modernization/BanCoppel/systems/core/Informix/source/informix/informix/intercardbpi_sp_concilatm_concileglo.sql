CREATE PROCEDURE "informix".sp_concilatm_concileglo( pEmpresa char(3),pfecha   date)
RETURNING VARCHAR(5), VARCHAR(255);

--//Definicion de variables
DEFINE vcodret        CHAR(5);
DEFINE vsqlerr        INTEGER;
DEFINE iSamErr		  INTEGER;
DEFINE cVarDataErr	  VARCHAR(64);

DEFINE vt_producto 	  CHAR(4);

DEFINE v_numtarjeta_s           	VARCHAR(16);
DEFINE v_numcuenta_s            	VARCHAR(12);
DEFINE v_descripcion_s          	VARCHAR(40);
DEFINE v_indicadordereversa_s   	VARCHAR(1);
DEFINE v_monto_s                	DECIMAL(18,2);
DEFINE v_montosurcharge_s       	DECIMAL(18,2);
DEFINE v_montosurcharge_mov     	DECIMAL(18,2);
DEFINE v_sum_monto              	DECIMAL(18,2);
DEFINE v_secuenciaut_s          	VARCHAR(7);
DEFINE v_secuenciaext_s         	VARCHAR(15);
--DEFINE v_fecha_mov_s            	DATE; 
DEFINE v_fecha_s                	CHAR(8);
DEFINE v_hora_s	                	VARCHAR(6);
DEFINE v_hora_s_con	            	VARCHAR(6);
DEFINE v_numcajero_s            	VARCHAR(4);
DEFINE v_monto_loyaltyfee_s     	DECIMAL(18,2);
DEFINE v_banderaadquiriente_s   	VARCHAR(1);       
DEFINE v_rowcount               	INTEGER;
DEFINE v_rowloyalty             	INTEGER;
DEFINE v_fechalocaltransaccion  	VARCHAR(4);
DEFINE v_fechalocaltransaccion_uno  VARCHAR(4);
DEFINE v_transacc_s             	VARCHAR(4);
DEFINE v_montosurcharge_rev     	DECIMAL(18,2);
DEFINE v_monto_rev               	DECIMAL(18,2);
DEFINE v_codigo_fun                 VARCHAR(3);
DEFINE v_codigo_ref                 INTEGER;

--DEFINE v_fechahoraoutauth   DATETIME YEAR to FRACTION(5);
DEFINE v_fechahoraoutauth     DATETIME YEAR to FRACTION(4);

DEFINE v_adquiriente_s       VARCHAR(4);
DEFINE v_codigoiso_s         VARCHAR(2);
DEFINE v_surcharge_s         VARCHAR(1);

DEFINE v_fecha              DATE;
DEFINE v_idia               SMALLINT;
DEFINE v_iMes               SMALLINT;
DEFINE v_iAnio              SMALLINT;
DEFINE pFecha_muno           DATE;
DEFINE pFecha_meuno          DATE;


DEFINE btabla1				CHAR(1);
DEFINE btabla2				CHAR(1);

   --Manejo del error
    ON EXCEPTION SET vsqlerr,iSamErr, cVarDataErr
		
		IF(btabla1 = 'T') THEN  DROP TABLE tmp_movimiento_sc; END IF;	
		IF(btabla1 = 'T') THEN  DROP TABLE tmp_sc_movhis_2; END IF;	
		IF(btabla2 = 'T') THEN  DROP TABLE tmp_sd_movhis; END IF;

		IF vsqlerr <> 0 then
			LET vcodret = vsqlerr;
			RETURN vcodret, iSamErr || ' ' ||cVarDataErr;
		END IF
    END EXCEPTION;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   --set debug file to "/tmp/sp_concilatm_concileglo.out";
   --trace on;

    --//Inicializacion de variables
   LET vcodret                 = "000";
   LET v_numtarjeta_s          = "";	    
   LET v_numcuenta_s     = "";	
   LET v_descripcion_s         = "";	
   LET v_indicadordereversa_s  = "";	
   LET v_monto_s               = 0.0;
   LET v_montosurcharge_s      = 0.0;
   LET v_montosurcharge_mov    = 0.0;
   LET v_sum_monto             = 0.0;
   LET v_montosurcharge_rev    = 0.0;
   LET v_monto_rev             = 0.0;
   LET v_secuenciaut_s         = "";	
   LET v_secuenciaext_s        = "";
   LET v_fecha_s               = "";
   LET v_hora_s	               = '';
   LET v_numcajero_s  	       = "";
   LET v_monto_loyaltyfee_s    = 0.0; 
   LET v_banderaadquiriente_s  = "";
   LET v_fechalocaltransaccion = '';
   LET v_fechalocaltransaccion_uno = '';
   LET v_codigo_fun            = '';
   LET v_codigo_ref            = 0;
      
   LET v_transacc_s = "";	       
   LET v_rowcount   = 0;       
   LET v_rowloyalty = 0; 
    
   LET v_fechahoraoutauth = "";				
   LET v_adquiriente_s    = "";
   LET v_codigoiso_s      = "";

   LET v_fecha      = "";   
   LET v_idia       = "";
   LET v_iMes       = ""; 
   LET v_iAnio      = ""; 
   
   LET btabla1 = 'F';
   LET btabla2 = 'F';

   IF pEmpresa ="" OR pfecha ="" THEN
      LET vcodret = "110";
      RETURN vcodret,"FALTAN PARAMETROS";
   END IF
	
	LET v_idia       = DAY   (pFecha);
	LET v_iMes       = MONTH (pFecha);
	LET v_iAnio      = YEAR  (pFecha);	
	
		
	IF (DAY(pFecha) = 01 AND MONTH(pFecha) = 01) THEN
	    LET pFecha_muno  = MDY(v_iMes,DAY(pFecha + 1),v_iAnio);	
		LET pFecha_meuno = MDY(12 ,31,YEAR(v_iAnio) - 1); 
	ELIF (DAY(pFecha) = 01 AND MONTH(pFecha) <> 01) THEN
	    LET pFecha_muno  = MDY(v_iMes,DAY(pFecha + 1),v_iAnio);	
		LET pFecha_meuno = MDY(MONTH (pFecha) - 1,DAY(pFecha - 1),v_iAnio); 		
	ELIF (DAY(pFecha) = 31 AND MONTH(pFecha) = 12) THEN
	    LET pFecha_muno  = MDY(01,DAY(pFecha + 1),v_iAnio +1);	
		LET pFecha_meuno = MDY(MONTH (pFecha),DAY(pFecha - 1),v_iAnio); 			
	ELSE 
	    LET pFecha_muno  = MDY(v_iMes,v_idia,v_iAnio) +1;	
		LET pFecha_meuno = MDY(v_iMes,v_idia,v_iAnio) -1; 		   	
	END IF;
	
	LET  v_fechalocaltransaccion = LPAD(MONTH(pfecha),2,'0')||LPAD(DAY(pfecha),2,0);	
	LET  v_fechalocaltransaccion_uno = LPAD(MONTH(pFecha_muno),2,'0')||LPAD(DAY(pFecha_muno),2,0);	 
  
	SELECT secuencia,secuenciaextendida,numtarjeta,idreceptor,codigoiso,fechalocaltransaccion,fechahorainauth,horalocaltransaccion,idterminal,monto,montocomision,montosurcharge,surcharge
	FROM intercard:movimiento,intercard:conciliacion_atm_es
	--WHERE secuencia[2,7]  = secuenciaut_e[2,7]  
	WHERE secuencia = secuenciaut_e
	and secuenciaut_e <> '1000000' 
	AND numtarjeta = numtarjeta_e 
	--AND numtarjeta in ('4008190265796840','4268070209704412')
	AND fechalocaltransaccion = v_fechalocaltransaccion 
	AND horalocaltransaccion BETWEEN '220000' AND  '235959'
	union
	SELECT secuencia,secuenciaextendida,numtarjeta,idreceptor,codigoiso,fechalocaltransaccion,fechahorainauth,horalocaltransaccion,idterminal,monto,montocomision,montosurcharge,surcharge
	FROM intercard:movimiento,intercard:conciliacion_atm_es
	--WHERE secuencia[2,7]  = secuenciaut_e[2,7]
	WHERE secuencia  = secuenciaut_e
	and secuenciaut_e <> '1000000' 
	AND numtarjeta = numtarjeta_e 
    --AND numtarjeta in ('4008190265796840','4268070209704412')	
	AND fechalocaltransaccion = v_fechalocaltransaccion_uno  
	AND horalocaltransaccion BETWEEN '000000' AND  '215959'
    INTO TEMP tmp_movimiento_sc
    WITH NO LOG;	
	
	CREATE INDEX informix.idx01tmp_movimiento_sc ON informix.tmp_movimiento_sc(secuencia,numtarjeta,fechahorainauth,horalocaltransaccion);
	UPDATE STATISTICS MEDIUM FOR TABLE intercard:tmp_movimiento_sc;	   	
    
	DELETE FROM intercard:concilatm_sifegloposacum WHERE fecha_mov = v_fechalocaltransaccion;
	DELETE FROM intercard:concilatm_sifegloposacum WHERE fecha_mov = v_fechalocaltransaccion_uno;
	
	--ESTA PARTE SE NECESITA DEFINIR EN CUANTO A SI AGREGAR EL MONTO SOURCHARG EL REALIZAR LA SUMA DE LOS MONTOS, TANTO PARA DEBITO COMO PARA CREDITO
	INSERT INTO intercard:concilatm_sifegloposacum(sistema,usuario,num_reg_ins,importe,fecha_mov)
    SELECT '01','intercar',count(*),nvl(sum(monto),0),fechalocaltransaccion 
      FROM tmp_movimiento_sc
     GROUP BY fechalocaltransaccion; 

		SELECT num_tarjeta,cuenta,referencia,TRIM(folio_suc[2,16]) AS secuenciaext,a.monto_tot,fech_alt,cancelad,fech_hor
          FROM bdicheq:sc_movhis a, tmp_movimiento_sc es			  
		 WHERE a.folio_suc[2,16] = es.secuenciaextendida
		   AND a.num_tarjeta = es.numtarjeta
	       AND a.empresa          = pEmpresa
	       AND a.cancelad IS NOT NULL
		   AND a.referencia <>'' 
		 GROUP BY 1,2,3,4,5,6,7,8
		  INTO TEMP tmp_sc_movhis_2  
          WITH NO LOG;

	      CREATE INDEX informix.idx01tmp_sc_movhis_2 ON informix.tmp_sc_movhis_2(cuenta,secuenciaext);
	      UPDATE STATISTICS MEDIUM FOR TABLE intercard:tmp_sc_movhis_2;		
		  
		SELECT 	
		-- {+INDEX(bdicred:sd_movhis inx_movhis1)}
		codigo_fun,codigo_ref,nro_tarjeta,num_credito,referencia,a.monto,TRIM(folio_suc[10,16]) AS secuencia,TRIM(folio_suc[2,16]) AS secuenciaext,fecha_mov,reversado,hora_mov,transacc_suc
		  FROM bdicred:sd_movhis a, tmp_movimiento_sc es
		 WHERE codigo_fun is not null
		   AND codigo_ref is not null
		   AND a.folio_suc[2,16] = es.secuenciaextendida
		   AND nro_tarjeta = numtarjeta
		 GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12
		  INTO TEMP tmp_sd_movhis
		  WITH NO LOG;
		  
		 CREATE INDEX informix.idx01tmp_sd_movhis ON informix.tmp_sd_movhis(num_credito,nro_tarjeta,secuencia);
		 UPDATE STATISTICS MEDIUM FOR TABLE intercard:tmp_sd_movhis;	 	 	
		
	LET btabla1 = 'T';
	
	FOREACH 
	SELECT secuencia,secuenciaextendida,numtarjeta,idreceptor,codigoiso,fechahorainauth,horalocaltransaccion,idterminal,monto,montosurcharge,montocomision,surcharge
	  INTO v_secuenciaut_s,v_secuenciaext_s,v_numtarjeta_s,v_adquiriente_s,v_codigoiso_s,v_fechahoraoutauth,v_hora_s,v_numcajero_s,v_monto_s,v_montosurcharge_mov,v_monto_loyaltyfee_s,v_banderaadquiriente_s 
	  FROM tmp_movimiento_sc
	 WHERE 1 = 1	        
	 
			--LET  v_fechalocaltransaccion = LPAD(MONTH(v_fecha_mov_s),2,'0')||DAY(v_fecha_mov_s);	
			LET  v_hora_s_con            = REPLACE ( v_hora_s, ':', '' ) ;
			LET v_idia      = DAY   (v_fechahoraoutauth);
			LET v_iMes      = MONTH (v_fechahoraoutauth);
			LET v_iAnio     = SUBSTR(YEAR(v_fechahoraoutauth),3,2);	
			LET v_fecha_s   = LPAD(v_idia,2,0)||"/"||LPAD(v_iMes,2,0)||"/"||LPAD(v_iAnio,2,0);
			LET v_hora_s	= SUBSTR(v_fechahoraoutauth,11,8);			
					
	 			   

         IF (v_numtarjeta_s[1,4] = '4008') THEN 
		 
	       SELECT cuenta,referencia,cancelad
	         INTO v_numcuenta_s,v_descripcion_s,v_indicadordereversa_s
	         FROM tmp_sc_movhis_2
		    WHERE secuenciaext = v_secuenciaext_s
			  AND num_tarjeta  = v_numtarjeta_s
			  AND referencia not like ('%REV%');
			  
			SELECT COUNT(numtarjeta_e) 
			  INTO v_rowloyalty
			  FROM intercard:conciliacion_atm_es 
			 WHERE keyx_e is not null
			   AND secuenciaut_e[2,7] = substr(v_secuenciaut_s,2,6)
			   AND fecha_e IS NOT NULL
			 --AND montosurcharge_e = v_montosurcharge_s						
			   AND numtarjeta_e = v_numtarjeta_s							
			   AND nombre_arc	 LIKE '%ATMD%';				  
			   
        ELIF  (v_numtarjeta_s[1,4] = '4268') THEN
		
		      SELECT 
               --{+INDEX(bdicred:sd_movhis inx_movhis1)}
                     num_credito,referencia,reversado
                INTO v_numcuenta_s,v_descripcion_s,v_indicadordereversa_s	  
	            FROM tmp_sd_movhis a
	           WHERE codigo_fun = '002'
			     and codigo_ref = '40'
			     AND secuenciaext  = v_secuenciaext_s
                 AND nro_tarjeta   = v_numtarjeta_s; 	

			SELECT COUNT(numtarjeta_e) 
			  INTO v_rowloyalty
			  FROM intercard:conciliacion_atm_es 
			 WHERE keyx_e is not null
			   AND secuenciaut_e[2,7] = substr(v_secuenciaut_s,2,6)
			   AND fecha_e IS NOT NULL
			 --AND montosurcharge_e = v_montosurcharge_s						
			   AND numtarjeta_e = v_numtarjeta_s							
               AND nombre_arc	LIKE '%ATMC%';			   		 			   
			   
		END IF    
			 															   		 				
				IF 	v_rowloyalty > 0 THEN 		
				     IF v_monto_s <> 0 THEN 
					    LET v_monto_s = v_monto_s + v_monto_loyaltyfee_s;
					 END IF
					UPDATE intercard:conciliacion_atm_es SET 
						adquiriente_s        = v_adquiriente_s,
						secuenciaut_s        = v_secuenciaut_s,       
						numtarjeta_s         = v_numtarjeta_s, 
						numcuenta_s          = v_numcuenta_s,
						descripcion_s        = v_descripcion_s,
						indicadordereversa_s = v_indicadordereversa_s,
						codigoiso_s          = v_codigoiso_s,
						monto_s              = v_monto_s,
						montosurcharge_s     = v_montosurcharge_mov,
						hora_s               = v_hora_s,
						fecha_s              = v_fecha_s,		
						numcajero_s          = v_numcajero_s,
						monto_loyaltyfee_s   = v_monto_loyaltyfee_s,
						banderaadquiriente_s = v_banderaadquiriente_s
					WHERE keyx_e is not null 
						AND secuenciaut_e = v_secuenciaut_s
						AND (fecha_s IS NULL OR fecha_s = '')						
						AND numtarjeta_e = v_numtarjeta_s	
				        AND indicadordereversa_e <> 'REVERSAL';
	
			    ELSE 
		
					INSERT INTO intercard:conciliacion_atm_es(adquiriente_s,secuenciaut_s,numtarjeta_s,numcuenta_s,descripcion_s,indicadordereversa_s,codigoiso_s,monto_s,montosurcharge_s,fecha_s,hora_s,numcajero_s,monto_loyaltyfee_s,banderaadquiriente_s)
													VALUES(v_adquiriente_s,v_secuenciaut_s,v_numtarjeta_s,v_numcuenta_s,v_descripcion_s,v_indicadordereversa_s,v_codigoiso_s,v_monto_s,v_montosurcharge_mov,v_fecha_s,v_hora_s,v_numcajero_s,v_monto_loyaltyfee_s,v_banderaadquiriente_s);					
			
     			END IF

	END FOREACH;

	IF(btabla1 = 'T') THEN  DROP TABLE tmp_movimiento_sc; END IF;	
	IF(btabla1 = 'T') THEN  DROP TABLE tmp_sc_movhis_2;	END IF;	
	IF(btabla2 = 'T') THEN  DROP TABLE tmp_sd_movhis;	END IF;
	RETURN vcodret,"PROCESO EXITOSO";
END PROCEDURE;