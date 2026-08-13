CREATE PROCEDURE "informix".sp_msj_ins_nip()
RETURNING VARCHAR(10), varchar(255); 

	--DEFINE vfecha	 			DATETIME YEAR TO SECOND;
	DEFINE vfecha_ctl 			DATETIME YEAR TO SECOND;
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
	DEFINE vid_cliente_ulc		CHAR(4);
	DEFINE vnumtarjeta          CHAR(16);
	DEFINE vfecha_pro    		DATETIME YEAR TO FRACTION;



--Manejo del error
       ON EXCEPTION
		SET sql_err, isam_err, error_info 

		  IF(btabla1 = 'T') THEN DROP TABLE tmp_cte_nip; END IF;	
		 
           IF sql_err <> 0 THEN
            LET vcod_ret=sql_err;
			
				UPDATE bdinteg:si_ctrl_info_mensajes 
			    	SET(fecha, cod_err, descripcion_err) = (CURRENT, vcod_ret, isam_err||' ' ||error_info)
					WHERE id_sp = '07';  			

            RETURN vcod_ret, isam_err||' ' ||error_info;
           END IF;
       END EXCEPTION;
	   
	--set debug file to "/tmp/sp_msj_ins_nip.out";
	--TRACE ON;		   
	  
	LET vfecha_ctl = '';	 
	LET vfecha_tmp = '';
	--LET vfecha = '';
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
	
	SELECT fecha, status_proc 
	  INTO vfecha_ctl, vstatus_proc_cte
	  FROM bdinteg:si_ctrl_info_mensajes
	  WHERE id_sp = '07';
	  	
	IF(vstatus_proc_cte = '1') THEN
		UPDATE bdinteg:si_ctrl_info_mensajes 
		  SET(fecha, cod_err, descripcion_err) = (CURRENT, vcod_ret, 'PROCESO EN EJECUCION')
		  WHERE id_sp = '07';
	
		RETURN vcod_ret, 'PROCESO EN EJECUCION';
	END IF;
	
	UPDATE bdinteg:si_ctrl_info_mensajes
	  SET status_proc = '1'
	  WHERE  id_sp = '07';

	  
	SELECT sec 
	  INTO vcuenta_cte 
	  FROM bdinteg:si_ctrl_info_mensajes
	  WHERE  id_sp = '07';
			


    IF (vcuenta_cte = 0 AND vcuenta_tmp = 0 ) THEN 
			
			--LET vfecha = TODAY::DATETIME YEAR TO SECOND;
			LET vfecha_ctl = TODAY::DATETIME YEAR TO SECOND;
  
	ELSE 
		 SELECT MAX(fecha)
		   INTO vfecha_ctl
		   FROM bdinteg:si_ctrl_info_mensajes
		   WHERE id_sp = '07';
		   
		 --LET vfecha = vfecha_ctl;  
	END IF	
 
--info si_cte_nip
	
	SELECT TRIM(b.numcliente) as numcliente,TRIM(a.numtarjeta) as numtarjeta, a.fechahorainauth
	  FROM intercard:movimiento a, intercard:tarjeta b
	 WHERE codigoiso = '00'
	   AND transaccionorigen = "0004"
	   AND codtran = "95"
	   AND fechahorainauth >=  vfecha_ctl
	   AND a.numtarjeta = b.numtarjeta
	   AND date(b.fechaasignacion) < date(a.fechahorainauth)
	 INTO temp tmp_cte_nip WITH NO LOG; 
	 LET btabla1 = 'T';	   

	FOREACH WITH HOLD
	  	SELECT *
	        INTO vid_cliente,vnumtarjeta,vfecha_pro
	        FROM tmp_cte_nip
	  	  WHERE  1=1
		LET vid_cliente_ulc = SubStr(vid_cliente,6,10);	
		EXECUTE PROCEDURE  bdimnsj:sp_registra_evento 
		( 2,'NIP_MANTTO', vid_cliente,'',vnumtarjeta,1,vid_cliente_ulc,'', '', '', '', 0, 0,0, 0, 0, vfecha_pro, '') 
		INTO cCodRet; 

         IF (cCodRet = '00000') THEN
		    LET vmsgidC = vmsgidC +1;
		 END IF;
		 
	  	CONTINUE FOREACH;
	  END FOREACH;
  

--datos tabla de control
--SELECT MAX(msgid)
--	INTO vmsgid
--	FROM bdinteg:si_ctrl_info_mensajes;
	


SELECT MAX(fechahorainauth)
  INTO vfecha_pro
  FROM tmp_cte_nip;
  	 
 --actualiza tabla de logs
	SELECT COUNT(*) 
	  INTO vreg_ins1
	  FROM tmp_cte_nip;
	  
	--LET vreg_ins_tot = vreg_ins1 + vreg_ins2;  
 
	UPDATE bdinteg:si_ctrl_info_mensajes
					SET(fecha, cod_err, descripcion_err, reg_enviados) = (CURRENT, vcod_ret, 'PROCESO EXITOSO', vmsgidC)
					WHERE id_sp = '07';   


		
--borra tablas temporales  
IF(btabla1 = 'T') THEN DROP TABLE tmp_cte_nip; END IF;	
  				
-- tablas de control  
IF (vfecha_pro IS NOT NULL) THEN
	UPDATE  bdinteg:si_ctrl_info_mensajes
		SET (id, fecha, sec, msgid, status_proc,reg_encontrados) = ('C', vfecha_pro::DATETIME YEAR TO SECOND + INTERVAL (01) SECOND(2) TO SECOND, '1', vmsgidC, '0',vreg_ins1)
		WHERE id_sp = '07';

ELSE 
	UPDATE   bdinteg:si_ctrl_info_mensajes
		SET (status_proc) = ('0'), (fecha) = (vfecha_ctl)				
		WHERE id_sp = '07';		
END IF;	


	RETURN vcod_ret, 'PROCESO EXITOSO';
END PROCEDURE;