CREATE PROCEDURE "informix".sp_msj_ins_huella()
RETURNING VARCHAR(10), varchar(255); 

	DEFINE vfecha	 			DATE;
	DEFINE vfecha_cte 			DATETIME YEAR TO SECOND;
	DEFINE vfecha_tmp 			DATETIME YEAR TO SECOND;
	DEFINE vcuenta_cte			SMALLINT;
	DEFINE vcuenta_tmp			SMALLINT;
	DEFINE vstatus_proc_cte		CHAR(1);
	DEFINE vstatus_proc_tmp		CHAR(1);

	DEFINE vcod_ret              VARCHAR(10); 
	DEFINE sql_err               SMALLINT;
	DEFINE isam_err              SMALLINT;
	DEFINE error_info            CHAR(40);
	
	DEFINE btabla1				CHAR(1);
	DEFINE btabla2				CHAR(1);
	
	DEFINE vreg_ins1			INTEGER;
	DEFINE vreg_ins2			INTEGER;
	DEFINE vreg_ins_tot			INTEGER;
	
	DEFINE vmsgidC				INTEGER;
    DEFINE vmsgidT				INTEGER;
	DEFINE cCodRet              CHAR(5);

	DEFINE vid_cliente 			CHAR(20);
	DEFINE vid_cliente_ulc      CHAR(4);
	
	DEFINE vfecha_pro    		DATETIME YEAR TO FRACTION;
	DEFINE vfecha_pro1    		DATETIME YEAR TO FRACTION;



--Manejo del error
       ON EXCEPTION
		SET sql_err, isam_err, error_info 

		  IF(btabla1 = 'T') THEN DROP TABLE tmp_cte_huella; END IF;	
		  IF(btabla2 = 'T') THEN DROP TABLE tmp_huella_temp; END IF;
		 
           IF sql_err <> 0 THEN
            LET vcod_ret=sql_err;
			
				UPDATE {+  INDEX(bdinteg:si_ctrl_info_mensajes "idx_id_si_ctrl_info1" ) } bdinteg:si_ctrl_info_mensajes 
			    	SET(fecha, cod_err, descripcion_err) = (CURRENT, vcod_ret, isam_err||' ' ||error_info)
					WHERE id_sp = '06';  			

            RETURN vcod_ret, isam_err||' ' ||error_info;
           END IF;
       END EXCEPTION;
	   
	--set debug file to "/tmp/sp_msj_ins_huella.out";
	--TRACE ON;		   
	  
	LET vfecha_cte = '';	 
	LET vfecha_tmp = '';
	LET vfecha = '';
	LET	vcuenta_cte = 0;		
	LET	vcuenta_tmp = 0;		
	LET	vstatus_proc_cte = '';	
	LET	vstatus_proc_tmp = '';	

	LET vcod_ret = '000';  
	LET sql_err = 0;   
	LET isam_err = 0;  
	LET error_info = '';
	
	LET btabla1 = 'F';
	LET btabla2 = 'F';
	
	LET vreg_ins1 = 0;	
	LET vreg_ins2 = 0;	
	LET vreg_ins_tot = 0;
	
	LET vmsgidC = 0;
	LET vmsgidT = 0;
	
	LET vid_cliente     = '';
	LET vid_cliente_ulc = '';
	LET vfecha_pro      = '';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	SELECT {+  INDEX(bdinteg:si_ctrl_info_mensajes "idx_id_si_ctrl_info" ) } fecha, status_proc 
	  INTO vfecha_cte, vstatus_proc_cte
	  FROM bdinteg:si_ctrl_info_mensajes
	  WHERE id = 'C'
	    AND id_sp = '06';
	  

	SELECT {+  INDEX(bdinteg:si_ctrl_info_mensajes "idx_id_si_ctrl_info" ) } fecha, status_proc 
	  INTO vfecha_tmp, vstatus_proc_tmp
	  FROM bdinteg:si_ctrl_info_mensajes
	  WHERE id = 'T'
		AND  id_sp = '06';  
	
	IF(vstatus_proc_cte = '1' AND vstatus_proc_tmp = '1') THEN
		UPDATE {+  INDEX(bdinteg:si_ctrl_info_mensajes "idx_id_si_ctrl_info1" ) } bdinteg:si_ctrl_info_mensajes 
		  SET(fecha, cod_err, descripcion_err) = (CURRENT, vcod_ret, 'PROCESO EN EJECUCION')
		  WHERE id_sp = '06';
	
		RETURN vcod_ret, 'PROCESO EN EJECUCION';
	END IF;
	
	UPDATE {+  INDEX(bdinteg:si_ctrl_info_mensajes "idx_id_si_ctrl_info1" ) } bdinteg:si_ctrl_info_mensajes
	  SET status_proc = '1'
	  WHERE  id_sp = '06';

	  
	SELECT {+  INDEX(bdinteg:si_ctrl_info_mensajes "idx_id_si_ctrl_info" ) } sec 
	  INTO vcuenta_cte 
	  FROM bdinteg:si_ctrl_info_mensajes
	  WHERE id = 'C'
		AND id_sp = '06';	
	  
	SELECT {+  INDEX(bdinteg:si_ctrl_info_mensajes "idx_id_si_ctrl_info" ) } sec 
	  INTO vcuenta_tmp 
	  FROM bdinteg:si_ctrl_info_mensajes
	  WHERE id = 'T'
	    AND id_sp = '06';	  

    IF (vcuenta_cte = 0 AND vcuenta_tmp = 0 ) THEN 
			
			LET vfecha = TODAY;
			LET vfecha_cte = TODAY::DATETIME YEAR TO SECOND;
			LET vfecha_tmp = TODAY::DATETIME YEAR TO SECOND;
		
  
	ELSE 
		 SELECT  {+  INDEX(bdinteg:si_ctrl_info_mensajes "idx_id_si_ctrl_info" ) } MAX(fecha)
		   INTO vfecha_cte
		   FROM bdinteg:si_ctrl_info_mensajes
		   WHERE id = 'C'
		     AND id_sp = '06';
		   
		 LET vfecha = vfecha_cte::DATE;  
		 
		 SELECT {+  INDEX(bdinteg:si_ctrl_info_mensajes "idx_id_si_ctrl_info" ) } (fecha)
		   INTO vfecha_tmp
		   FROM bdinteg:si_ctrl_info_mensajes
		   WHERE id = 'T'
		     AND id_sp = '06';
	END IF	
 
--info si_cte_huella	   
	SELECT
      {+  INDEX(bdinteg:si_cte_huella "ix_huellanew" ) } TRIM(c.numcte) AS id_cliente,  
      NVL(c.fech_ult_camb,c.fecha_alta) AS fecha
	FROM bdinteg:si_cte_huella c
	WHERE  c.numcte is not null
      AND c.secuencia > 1  
      AND c.fecha_alta  >= vfecha 
      AND c.fech_ult_camb >= vfecha_cte 
	  AND c.secuencia = (SELECT MAX(secuencia) FROM bdinteg:si_cte_huella WHERE numcte = c.numcte)	 
	 INTO temp tmp_cte_huella WITH NO LOG; 
	LET btabla1 = 'T';

	
	FOREACH WITH HOLD
	  	SELECT *
	        INTO vid_cliente,vfecha_pro
	        FROM tmp_cte_huella
	  	  WHERE  1=1
			
		LET vid_cliente_ulc = SubStr(vid_cliente,6,10);
		EXECUTE PROCEDURE  bdimnsj:sp_registra_evento 
		( 2,'HUL_MANTTO', vid_cliente,'', '',1, vid_cliente_ulc,'', '', '', '', 0, 0,0, 0, 0, vfecha_pro, '') 
		INTO cCodRet; 
		
         IF (cCodRet = '00000') THEN
		    LET vmsgidC = vmsgidC +1;
		 END IF;
		 
	  	CONTINUE FOREACH;
	  END FOREACH;
  
--info si_huella_temp
	SELECT 
      {+ AVOID_FULL(bdinteg:"informix".si_huella_temp) } TRIM(t.numcte) AS id_cliente,  
      t.fecha_alta AS fecha
	FROM bdinteg:si_huella_temp t	
	WHERE  t.numcte is not null
      AND t.secuencia > 1 
      AND t.fecha_alta >= vfecha_tmp 
	  AND t.secuencia = (SELECT MAX(secuencia) FROM bdinteg:si_huella_temp WHERE numcte = t.numcte)
	ORDER BY fecha_alta ASC
	INTO temp tmp_huella_temp WITH NO LOG;
	LET btabla2 = 'T';
 
 
--generacion de tramas
	FOREACH WITH HOLD
	  	SELECT *
	        INTO vid_cliente,vfecha_pro1
	        FROM tmp_huella_temp
	  	  WHERE  1=1
		
		LET vid_cliente_ulc = SubStr(vid_cliente,6,10);		
		EXECUTE PROCEDURE  bdimnsj:sp_registra_evento 
		( 2,'HUL_MANTTO', vid_cliente,'', '',1, vid_cliente_ulc,'', '', '', '', 0, 0,0, 0, 0, vfecha_pro1, '') 
		INTO cCodRet; 
		
         IF (cCodRet = '00000') THEN
		    LET vmsgidT = vmsgidT +1;
		 END IF;
		 
	  	CONTINUE FOREACH;
	  END FOREACH;


--datos tabla de control
--SELECT MAX(msgid)
--	INTO vmsgid
--	FROM bdinteg:si_ctrl_info_mensajes;
	


SELECT MAX(fecha)
  INTO vfecha_pro
  FROM tmp_cte_huella;
  
	 
SELECT MAX(fecha)
  INTO vfecha_pro1
  FROM tmp_huella_temp;
  
  
 --actualiza tabla de logs
	SELECT COUNT(*) 
	  INTO vreg_ins1
	  FROM tmp_cte_huella;
	  
	SELECT COUNT(*) 
	  INTO vreg_ins2
	  FROM tmp_huella_temp;  
	  
	--LET vreg_ins_tot = vreg_ins1 + vreg_ins2;  
 
	UPDATE {+  INDEX(bdinteg:si_ctrl_info_mensajes "idx_id_si_ctrl_info1" ) } bdinteg:si_ctrl_info_mensajes
					SET(fecha, cod_err, descripcion_err,reg_encontrados, reg_enviados) = (CURRENT, vcod_ret, 'PROCESO EXITOSO',vreg_ins1, vmsgidC)
					WHERE id = 'C'
					  AND id_sp = '06';   

	UPDATE {+  INDEX(bdinteg:si_ctrl_info_mensajes "idx_id_si_ctrl_info1" ) } bdinteg:si_ctrl_info_mensajes
					SET(fecha, cod_err, descripcion_err,reg_encontrados, reg_enviados) = (CURRENT, vcod_ret, 'PROCESO EXITOSO',vreg_ins2, vmsgidT)
					WHERE id = 'T'
					  AND id_sp = '06'; 					  


		
--borra tablas temporales  
  IF(btabla1 = 'T') THEN DROP TABLE tmp_cte_huella; END IF;	
  IF(btabla2 = 'T') THEN DROP TABLE tmp_huella_temp; END IF;

  
  

					
-- tablas de control  
IF (vfecha_pro IS NOT NULL) THEN
	UPDATE {+  INDEX(bdinteg:si_ctrl_info_mensajes "idx_id_si_ctrl_info1" ) } bdinteg:si_ctrl_info_mensajes
		SET (id, fecha, sec, reg_enviados, status_proc) = ('C', vfecha_pro::DATETIME YEAR TO SECOND + INTERVAL (01) SECOND(2) TO SECOND, '1', vmsgidC, '0')
		WHERE id = 'C'
		  AND id_sp = '06';
ELSE 
	UPDATE {+  INDEX(bdinteg:si_ctrl_info_mensajes "idx_id_si_ctrl_info1" ) } bdinteg:si_ctrl_info_mensajes
		SET (status_proc) = ('0'), (fecha) = (vfecha_cte)
		WHERE id = 'C'
		  AND id_sp = '06';
		
END IF;	

IF (vfecha_pro1 IS NOT NULL) THEN  
	UPDATE  {+  INDEX(bdinteg:si_ctrl_info_mensajes "idx_id_si_ctrl_info1" ) }  bdinteg:si_ctrl_info_mensajes
		SET (id, fecha, sec, reg_enviados, status_proc) = ('T', vfecha_pro1::DATETIME YEAR TO SECOND + INTERVAL (01) SECOND(2) TO SECOND, '1', vmsgidT,'0')
		WHERE id = 'T'
		  AND id_sp = '06';
ELSE 
	UPDATE  {+  INDEX(bdinteg:si_ctrl_info_mensajes "idx_id_si_ctrl_info1" ) }  bdinteg:si_ctrl_info_mensajes
		SET (status_proc) = ('0'), (fecha) = (vfecha_tmp)
		WHERE id = 'T'
		  AND id_sp = '06';		
END IF;						


	RETURN vcod_ret, 'PROCESO EXITOSO';
END PROCEDURE;