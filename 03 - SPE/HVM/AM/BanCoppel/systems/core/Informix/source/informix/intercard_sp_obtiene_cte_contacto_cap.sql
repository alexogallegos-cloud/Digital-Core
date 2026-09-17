CREATE PROCEDURE "informix".sp_obtiene_cte_contacto_cap ( 
                                                           pNumEmpCoppel   CHAR(9), 
														   pCuenta         VARCHAR(4)
														)

RETURNING VARCHAR(5) AS CODIGO_RETORNO, VARCHAR (50) AS MENSAJE_RETORNO, CHAR(1) as VC_TIPOENVIO, VARCHAR(10) AS ALERTA, VARCHAR(15) AS ID_PLANTILLA, CHAR(20) AS NUMCTE;	
 
	--Definicion de variables
    DEFINE  codigo_retorno      CHAR(5);				
	DEFINE  mensaje_retorno     CHAR(50);
	
	DEFINE SQLERR		INTEGER;
	DEFINE ISAM_ERR		INTEGER;
	DEFINE ERROR_INFO	VARCHAR(80); 
    DEFINE RUTA_DESTINO VARCHAR(80);	
	
	DEFINE valerta1             varchar(10);
    DEFINE valerta2             varchar(10);
	DEFINE ALERTA                varchar(10);
    DEFINE vIdPlantilla1        varchar(15); 
    DEFINE vIdPlantilla2        varchar(15); 
	DEFINE ID_PLANTILLA         varchar(15); 
	DEFINE VC_TIPOENVIO          char(1); 
   
    DEFINE VC_NUMCTE 	        CHAR (20);
    DEFINE vstelefono	        INTEGER;
    DEFINE vscorreo			    INTEGER;
	DEFINE vCuentaComp VARCHAR(13);
	DEFINE vempleado CHAR(9);
	DEFINE vcuenta VARCHAR(13);
	DEFINE vcuentacorta Varchar(4);
	
	LET RUTA_DESTINO  = '/RESPALDOSNEW/';
    LET vstelefono         = 0;
    LET VC_NUMCTE           = '';
    LET vscorreo           = 0;
	LET codigo_retorno  = '00000';
	LET MENSAJE_RETORNO     = '';
	LET VC_TIPOENVIO = '';
	LET vCuentaComp = ''; 
	LET vempleado = '';
	LET vcuenta = '';
	LET vcuentacorta = '';
	
	--SET DEBUG FILE TO RUTA_DESTINO || "sp_obtiene_cte_contacto_cap.out";
    --TRACE ON;        	
	
BEGIN 
	
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_DESTINO || "sp_obtiene_cte_contacto_cap_e.out";
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN			  
			      DROP TABLE IF EXISTS "informix".ctas_nomina_emp_paso;			
                  LET CODIGO_RETORNO = SQLERR;
                  LET MENSAJE_RETORNO = ERROR_INFO;                
                 RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO,VC_TIPOENVIO,ALERTA,vIdPlantilla2,NVL(VC_NUMCTE,'0');
            END IF;
			
        END EXCEPTION;	

	    SET ISOLATION TO DIRTY READ; 
	    SET LOCK MODE TO WAIT 3;
------------------------------------------------------------------------------------------------------------------------
		 LET codigo_retorno  = '00000';
		 LET mensaje_retorno = 'PROCESO EXITOSO';
		 LET vIdPlantilla1 ='D_CAPP_EMAIL';    -- plantilla email   
		 LET valerta1      ='CMPC_BATCH';    -- alerta email 
		
		 LET vIdPlantilla2 ='D_CAPP_SMS';    -- plantilla sms     
         LET valerta2      ='CMPS_BATCH';    -- alerta sms 
		 
		LET ALERTA = '';
     	LET ID_PLANTILLA = '';

		--DROP TABLE IF EXISTS "informix".ctas_nomina_emp_paso;

	   --Creacion de tabla de paso   
	     CREATE TEMP TABLE ctas_nomina_emp_paso
         (
            num_empleado       CHAR(9),
            cuenta             VARCHAR(13),
            cuenta_corta      VARCHAR(4)
         ) WITH NO LOG LOCK MODE ROW;

		    CREATE INDEX "informix".idx_ctas_nomina_emp_paso_1 ON "informix".ctas_nomina_emp_paso(num_empleado) ;
 
		    foreach cur_F1_main WITH hold for
		
		         Select  num_empleado,cuenta INTO vempleado,vcuenta from intercard:ctas_nomina_empleado where num_empleado = pNumEmpCoppel	 
  
		          LET vcuentacorta = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
 
			     INSERT INTO "informix".ctas_nomina_emp_paso  (num_empleado,cuenta,cuenta_corta)
		         VALUES  (vempleado,vcuenta,vcuentacorta );

		   end foreach; 
		----------
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".ctas_nomina_emp_paso;  
		----------
		Select limit 1 cuenta into vCuentaComp from ctas_nomina_emp_paso where num_empleado = pNumEmpCoppel and  cuenta_corta  = pCuenta;
		----------
		--Obtiene el num. de cte. 
		----------
		  SELECT limit 1 num_cte  INTO VC_NUMCTE
          FROM bdicheq:sc_maechq 
          WHERE  empresa = '001' 
          AND  cuenta = vCuentaComp; 
		  
		  IF VC_NUMCTE IS NULL THEN 

		                 DROP TABLE IF EXISTS "informix".ctas_nomina_emp_paso;
		  
		  					LET MENSAJE_RETORNO = 'EMP-CTA NO ENCONTRADO EN CATALOGO COPPEL';
							LET VC_TIPOENVIO = '0';
							LET ALERTA = '0';
							LET ID_PLANTILLA = '0';
		      RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO,VC_TIPOENVIO,ALERTA,ID_PLANTILLA,NVL(VC_NUMCTE,'0');
		  END IF;
		  
		----------
		  Select  COUNT(*) INTO  vscorreo
		  from   bdinteg:"informix".si_correos sic 
          Where  sic.tipo_correo = '1'
          and sic.status_correo = 'A'
          and numcte =  VC_NUMCTE; 
 
		  Select  COUNT(*) INTO vstelefono 
          from  bdinteg:"informix".si_telefonos_actual sit 
          where sit.status_tel = 'A' 
          AND sit.tipo_tel = '2'
          AND numcte = VC_NUMCTE ; 
 
            IF    (vscorreo = '0' and vstelefono = '0')   THEN 

							LET MENSAJE_RETORNO = 'CLIENTE SIN DATOS DE CONTACTO';
							LET VC_TIPOENVIO = '0';
							LET ALERTA = '0';
							LET ID_PLANTILLA = '0';
			    
			ELIF ( (vscorreo <> '0' AND vscorreo is not null) ) THEN 	
			       --email 
			            LET  VC_TIPOENVIO   = '1';
						LET  MENSAJE_RETORNO     = 'OK EMAIL';
				     	LET ALERTA = valerta1;
			         	LET ID_PLANTILLA = vIdPlantilla1;
 
            ELIF   ( (vstelefono <> '0' AND vstelefono is not null) ) THEN  
		
					-- sms 
					    LET  VC_TIPOENVIO   = '2';
						LET  MENSAJE_RETORNO     = 'OK SMS';
				     	LET ALERTA = valerta2;
			         	LET ID_PLANTILLA = vIdPlantilla2;
 
			END IF; 
 
           DROP TABLE IF EXISTS "informix".ctas_nomina_emp_paso;
------------------------------------------------------------------------------------------------------------------------

    RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO,VC_TIPOENVIO,ALERTA,ID_PLANTILLA,NVL(VC_NUMCTE,'0');


END;
END PROCEDURE;