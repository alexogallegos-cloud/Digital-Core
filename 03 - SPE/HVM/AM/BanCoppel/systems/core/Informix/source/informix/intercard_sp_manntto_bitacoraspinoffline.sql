CREATE PROCEDURE "informix".sp_manntto_bitacoraspinoffline (pe_sysdate DATETIME YEAR TO FRACTION(5))
RETURNING CHAR (5) AS CODIGO_RETORNO, CHAR(300) AS MENSAJE_RETORNO;

    DEFINE SQL_ERR          INTEGER;
    DEFINE ISAM_ERR         INTEGER;
    DEFINE ERROR_INFO       CHAR(40);
    DEFINE CODIGO_RETORNO 	CHAR(5);
    DEFINE MENSAJE_RETORNO 	CHAR(150);
    DEFINE ANIO_MES		CHAR (06);
    DEFINE RUTA_ORIGEN	CHAR (80);
    DEFINE dtfechahoy	DATETIME YEAR TO FRACTION(5);
    DEFINE canio		CHAR (04);
    DEFINE cmes		CHAR (02);
    DEFINE cdia		CHAR (02);
    DEFINE cnombretabla1 	CHAR (50);
    DEFINE cnombretabla2 	CHAR (50);
    DEFINE vExecuteSQL 	CHAR (1500);
    DEFINE cbandera		CHAR (50);
    DEFINE cnombretablapivote1 	CHAR (20);
    DEFINE cnombretablapivote2 	CHAR (20);
    DEFINE crenombratabla1	CHAR (20);
	
    --	SET DEBUG FILE TO '/RESPALDOSNEW/sp_manntto_bitacoraspinoffline.out';
    --	TRACE ON; 
	
    let SQL_ERR = 0;
    let ISAM_ERR = 0;
    let ERROR_INFO = '';
    let CODIGO_RETORNO = '00000';
    let MENSAJE_RETORNO = 'sp_manntto_bitacoraspinoffline ejecutado exitosamente.';
    let dtfechahoy = pe_sysdate;
    let canio = substr (dtfechahoy, 1, 4);
    let cmes = substr (dtfechahoy, 6, 2);
    let cdia = substr (dtfechahoy, 9, 2); 
    let cnombretabla1 = '';
    let cnombretabla2 = '';
    let vExecuteSQL = '';
    let cbandera = '';
    let cnombretablapivote1 = '';
    let cnombretablapivote2 = '';
    let crenombratabla1 = '';
	
BEGIN        
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        SET DEBUG FILE TO '/RESPALDOSNEW/sp_manntto_bitacoraspinoffline.out';
        TRACE ON;
        LET CODIGO_RETORNO = SQL_ERR;
        LET MENSAJE_RETORNO = ISAM_ERR||ERROR_INFO;            
        RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
    END EXCEPTION;        

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
/*
    SELECT 
		fecha_hoy, YEAR (fecha_hoy), month (fecha_hoy), day (fecha_hoy) 
		into dtfechahoy, canio, cmes, cdia
	FROM bdinteg:"informix".si_fechas
	WHERE empresa = '001';
*/
	drop table if exists "informix".bitacorapinoffline_pivoterepo;
	drop table if exists "informix".bitpinoffline_pivoterepo;
		
--	TablaPivote1: bitacorapinoffline_pivoterepo:
	CREATE TABLE "informix".bitacorapinoffline_pivoterepo 
	( 
		numtarjeta       	CHAR(16) NOT NULL,
		fechageneracion  	DATETIME YEAR to FRACTION(5) NOT NULL,
		transaccionorigen	VARCHAR(4) NOT NULL,
		estatusscripting 	INTEGER,
		secuenciaorig    	VARCHAR(6),
		respuestatlv     	VARCHAR(255),
		tag_9f5b         	VARCHAR(11),
		idterminal       	VARCHAR(16),
		PRIMARY KEY(fechageneracion,numtarjeta,transaccionorigen)
	)
	fragment by round robin in 
	dbssc_sdodiarioc01, dbssc_sdodiarioc02, dbssc_sdodiarioc03
	extent size 2781964 next size 1024000
	LOCK MODE ROW;

	
--	TablaPivote2: bitpinoffline_pivoterepo:
	CREATE TABLE "informix".bitpinoffline_pivoterepo 
	( 
		numtarjeta        	CHAR(16) NOT NULL,
		tarjeta_edoinicial	CHAR(1) NOT NULL,
		tarjeta_edofinal  	CHAR(1) NOT NULL,
		sucursal          	CHAR(4) NOT NULL,
		ip_pc             	CHAR(15) NOT NULL,
		ejecutivo         	CHAR(8) NOT NULL,
		fechahora_insert  	DATETIME YEAR to FRACTION(5) NOT NULL,
		PRIMARY KEY(fechahora_insert,numtarjeta)
	)
	fragment by round robin in 
	dbssc_sdodiarioc01, dbssc_sdodiarioc02, dbssc_sdodiarioc03
	extent size 2781964 next size 1024000
	LOCK MODE ROW;


	--	Renombrado de tablas actuales a <_aniomes>:
		let cnombretabla1 = 'bitacorapinoffline_'||canio||cmes; 

		LET vExecuteSQL = '';
		LET vExecuteSQL = 'echo "RENAME TABLE bitacorapinoffline TO "'||cnombretabla1||'> renombratabla1.sql';
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = 'dbaccess intercard renombratabla1.sql';
		SYSTEM vExecuteSQL;

		let cnombretabla2 = 'bitpinoffline_'||canio||cmes; 
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'echo "RENAME TABLE bit_pinoffline TO "'||cnombretabla2||'> renombratabla2.sql';
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = 'dbaccess intercard renombratabla2.sql';
		SYSTEM vExecuteSQL;


	--	Renombrado de tablas pivote a limpias:
			--	LET cnombretablapivote1 = 'bitacorapinoffline';
			LET vExecuteSQL = '';
			LET vExecuteSQL = 'echo "RENAME TABLE bitacorapinoffline_pivoterepo TO bitacorapinoffline"> renombratablapivote1.sql';
			SYSTEM vExecuteSQL;

			LET vExecuteSQL = '';
			LET vExecuteSQL = 'dbaccess intercard renombratablapivote1.sql';
			SYSTEM vExecuteSQL;

			--	LET cnombretablapivote2 = 'bit_pinoffline';
			LET vExecuteSQL = '';
			LET vExecuteSQL = 'echo "RENAME TABLE bitpinoffline_pivoterepo TO bit_pinoffline"> renombratablapivote2.sql';
			SYSTEM vExecuteSQL;

			LET vExecuteSQL = '';
			LET vExecuteSQL = 'dbaccess intercard renombratablapivote2.sql';
			SYSTEM vExecuteSQL;		
			
			LET vExecuteSQL = '';
			LET vExecuteSQL ='rm -f renombratabla1.sql renombratabla2.sql renombratablapivote1.sql renombratablapivote2.sql';
			SYSTEM vExecuteSQL;		
	
	
    RETURN CODIGO_RETORNO, NVL(MENSAJE_RETORNO,'');

    END
END PROCEDURE
DOCUMENT
'AUTOR: FRG',
'Proyecto: RQI nn ccc Depuracion tablas <intercard:bitacorapinoffline> e <intercard:bit_pinoffline>',
'Fecha de creacion: 30.Enero.2021',
'Fecha de modificacion: N/A.',
'Invocacion: execute procedure "informix".sp_manntto_bitacoraspinoffline (current);', 
'Base de datos: intercard'
;

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