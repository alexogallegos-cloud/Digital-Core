CREATE PROCEDURE "informix".sp_consultaparamlide()
RETURNING CHAR(3) 	AS Codigo_Retorno,
          DATE 		AS Fecha_Hoy,		  		 
          CHAR(50) 	AS Server_ifx,
		  CHAR(50) 	AS Usuario_ifx,
		  CHAR(50) 	AS Password_ifx,		  
		  CHAR(50) 	AS Ruta_Origen_ifx,		  		 		
		  CHAR(50) 	AS PC_Envio_SAT,                   
		  CHAR(50) 	AS Usuario_Envio_SAT,
		  CHAR(50) 	AS Ruta_Envio_SAT,		  		 
          CHAR(50) 	AS PC_Recibo_SAT,
		  CHAR(50) 	AS Usuario_Recibo_SAT,
		  CHAR(50) 	AS Password_Recibo_SAT,
		  CHAR(50) 	AS Ruta_Recibo_SAT,
		  CHAR(50) 	AS Num_Max_Ejec,
		  CHAR(50) 	AS Num_CASFIM,		  
		  CHAR(50) 	AS Ruta_Recibo_Envio,
		  INTEGER 	AS Regs_Resul_SAT,
		  INTEGER 	AS Regs_Infor_SAT;
		  		                            
    DEFINE cCodRet 				CHAR(3);
    DEFINE dFecha_hoy    		DATE;
    DEFINE cServer_ifx      	CHAR(50);
    DEFINE cUsuario_ifx      	CHAR(50);
    DEFINE cPassword_ifx      	CHAR(50);
    DEFINE cRuta_Origen_ifx     CHAR(50);
    DEFINE cPC_Envio_SAT      	CHAR(50);
    DEFINE cUsuario_Envio_SAT   CHAR(50);
    DEFINE cRuta_Envio_SAT      CHAR(50);
    DEFINE cPC_Recibo_SAT      	CHAR(50);
    DEFINE cUsuario_Recibo_SAT  CHAR(50);
    DEFINE cPassword_Recibo_SAT CHAR(50);
    DEFINE cRuta_Recibo_SAT     CHAR(50);
    DEFINE cNum_Max_Ejec        CHAR(50);
    DEFINE cCasFim             	CHAR(50);
    DEFINE cRuta_Recibo_Envio   CHAR(50);
    DEFINE iSQLerr				INTEGER;
    DEFINE iRegsResulSat		INTEGER;
    DEFINE iRegsInforSat		INTEGER;

    ON EXCEPTION SET iSQLerr
        IF iSQLerr <> 0 THEN
            LET cCodRet = iSQLerr;
            RETURN cCodRet,NVL(dFecha_hoy,'01-01-1900'),NVL(TRIM(cServer_ifx),''),NVL(TRIM(cUsuario_ifx),''),NVL(TRIM(cPassword_ifx),''),
                   NVL(TRIM(cRuta_Origen_ifx),''),NVL(TRIM(cPC_Envio_SAT),''),NVL(TRIM(cUsuario_Envio_SAT),''),
                   NVL(TRIM(cRuta_Envio_SAT),''),NVL(TRIM(cPC_Recibo_SAT),''),NVL(TRIM(cUsuario_Recibo_SAT),''),
                   NVL(TRIM(cPassword_Recibo_SAT),''),NVL(TRIM(cRuta_Recibo_SAT),''),NVL(TRIM(cNum_Max_Ejec),''),
                   NVL(TRIM(cCasFim),''),NVL(TRIM(cRuta_Recibo_Envio),''),NVL(iRegsResulSat,0),NVL(iRegsInforSat,0);
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    LET iSQLerr						= 0;
    LET	cCodRet 					= '000';
    LET	dFecha_hoy 					= '';
    LET cServer_ifx	        		= '';
    LET cUsuario_ifx	        	= '';
    LET cPassword_ifx	        	= '';
    LET cRuta_Origen_ifx	        = '';
    LET cPC_Envio_SAT	        	= '';
    LET cUsuario_Envio_SAT	        = '';
    LET cRuta_Envio_SAT	       		= '';
    LET cPC_Recibo_SAT	        	= '';
    LET cUsuario_Recibo_SAT	        = '';
    LET cPassword_Recibo_SAT        = '';
    LET cNum_Max_Ejec               = '';
    LET cCasFim                    	='';
    LET cRuta_Recibo_Envio          =''; 
    LET cRuta_Recibo_SAT          	=''; 
    LET iRegsResulSat          		= 0; 
    LET iRegsInforSat           	= 0; 

    --- SET DEBUG FILE TO '/home/sysifx/vlv/sp_consultaparamlide.out';
    --- TRACE ON;	

    BEGIN
    --------Consulta los parametros generales para la validacion del LIDE.

    -- // Obtengo la Fecha Hoy de la Base de Datos.
    SELECT fecha_hoy 			
      INTO dFecha_hoy  			
      FROM BDICHEQ:"informix".sc_fechas;      
      
    -- // Obtengo el Servidor de Informix donde se generan los archivos.
    SELECT TRIM(desc_valor) 	
      INTO cServer_ifx  			
      FROM BDILIDE:"informix".sl_parametros 
     WHERE cve_param = '23' 
       AND valor = '01';
       
    -- // Obtengo el Usuario de Informix donde se generan los archivos.
    SELECT TRIM(desc_valor) 	
      INTO cUsuario_ifx  			
      FROM BDILIDE:"informix".sl_parametros 
     WHERE cve_param = '23' 
       AND valor = '02';
       
    -- // Obtengo el Password de Informix donde se generan los archivos.
    SELECT TRIM(desc_valor) 	
      INTO cPassword_ifx  		
      FROM BDILIDE:"informix".sl_parametros 
     WHERE cve_param = '23' 
       AND valor = '03';
       
    -- // Obtengo la Ruta Origen de Informix donde se generan los archivos.
    SELECT TRIM(desc_valor) 	
      INTO cRuta_Origen_ifx  		
      FROM BDILIDE:"informix".sl_parametros 
     WHERE cve_param = '23' 
       AND valor = '04';
       
    -- // Obtengo la IP donde se envian los archivos al SAT.
    SELECT TRIM(desc_valor) 	
      INTO cPC_Envio_SAT  		
      FROM BDILIDE:"informix".sl_parametros 
     WHERE cve_param = '18' 
       AND valor = '01';
       
    -- // Obtengo el Usuario donde se envian los archivos del SAT.
    SELECT TRIM(desc_valor) 	
      INTO cUsuario_Envio_SAT		
      FROM BDILIDE:"informix".sl_parametros 
     WHERE cve_param = '18' 
       AND valor = '02';
       
    -- // Obtengo la Ruta Compartida donde se envian los archivos del SAT.
    SELECT TRIM(desc_valor) 	
      INTO cRuta_Envio_SAT  		
      FROM BDILIDE:"informix".sl_parametros 
     WHERE cve_param = '18' 
       AND valor = '04';
       
    -- // Obtengo la IP local donde se recibe el archivo.
    SELECT TRIM(desc_valor) 	
      INTO cPC_Recibo_SAT  		
      FROM BDILIDE:"informix".sl_parametros 
     WHERE cve_param = '22' 
       AND valor = '01';
       
    -- // Obtengo el Usuario local donde se recibe el archivo.
    SELECT TRIM(desc_valor) 	
      INTO cUsuario_Recibo_SAT  	
      FROM BDILIDE:"informix".sl_parametros 
     WHERE cve_param = '22' 
       AND valor = '02';
       
    -- // Obtengo el Password local donde se recibe el archivo.
    SELECT TRIM(desc_valor) 	
      INTO cPassword_Recibo_SAT 	
      FROM BDILIDE:"informix".sl_parametros 
       WHERE cve_param = '22' 
         AND valor = '03';
         
    -- // Obtengo la Ruta local donde se recibe el archivo.
    SELECT TRIM(desc_valor) 	
      INTO cRuta_Recibo_SAT 		
      FROM BDILIDE:"informix".sl_parametros 
     WHERE cve_param = '22' 
       AND valor = '04';      	  
       
    -- // Obtengo el Numero Maximo de Ejecuciones por proceso.      
    SELECT TRIM(valor) 		
      INTO cNum_Max_Ejec 		    
      FROM BDILIDE:"informix".sl_parametros 
     WHERE cve_param = '17' 
       AND desc_valor = 'NUM_DE_VEC_GEN_CON_EXT';
       
    -- // Obtendo la Clave CASFIM (Catalogo del Sistema Financiero Mexicano)
    SELECT TRIM(valor) 		
      INTO cCasFim  				
      FROM BDILIDE:"informix".sl_parametros 
     WHERE cve_param = '04' 
       AND desc_valor = 'CASFIM';	
       
    -- // Obtengo la Ruta local donde se reciben y se envian archivos.
    SELECT TRIM(desc_valor) 	
      INTO cRuta_Recibo_Envio 	
      FROM BDILIDE:"informix".sl_parametros 
     WHERE cve_param = '13' 
       AND valor = '04';

    -- // Obtengo el Total de Procesos para el dia de hoy de CargaResultadosSAT.
    SELECT COUNT(proceso)
      INTO iRegsResulSat 
      FROM BDILIDE:"informix".sl_procesos 
     WHERE proceso = 'CargaArchivo_Sat' 
       AND fecha_insert = dFecha_hoy;
       
    -- // Obtengo el Total de Procesos para el dia de hoy de CargaInformeSAT.
    SELECT COUNT(proceso)
      INTO iRegsInforSat 
      FROM BDILIDE:"informix".sl_procesos 
     WHERE proceso = 'CargaInforme_Sat'  
       AND fecha_insert = dFecha_hoy;	 

    -- // Se Valida que no regrese parametros nulos.
    IF cServer_ifx IS NULL OR cServer_ifx = '' OR cUsuario_ifx IS NULL OR cUsuario_ifx = '' OR cPassword_ifx IS NULL OR cPassword_ifx = '' OR cRuta_Origen_ifx IS NULL OR cRuta_Origen_ifx = '' THEN
        LET cCodRet = '001';    ELIF cPC_Envio_SAT IS NULL OR cPC_Envio_SAT = '' OR cUsuario_Envio_SAT IS NULL OR cUsuario_Envio_SAT = '' OR cPC_Recibo_SAT IS NULL OR cPC_Recibo_SAT = '' THEN 
        LET cCodRet = '002';    ELIF cUsuario_Recibo_SAT IS NULL OR cUsuario_Recibo_SAT = '' OR cPassword_Recibo_SAT IS NULL OR cPassword_Recibo_SAT = '' OR cRuta_Recibo_SAT IS NULL OR cRuta_Recibo_SAT = '' THEN      
        LET cCodRet = '003';    ELIF cNum_Max_Ejec IS NULL OR cNum_Max_Ejec = '' OR cCasFim IS NULL OR cCasFim = '' OR cRuta_Recibo_Envio IS NULL OR cRuta_Recibo_Envio = '' THEN
        LET cCodRet = '004';    ELIF iRegsResulSat >= cNum_Max_Ejec OR iRegsResulSat >= 9 THEN
        LET cCodRet = '005';    ELIF iRegsInforSat >= cNum_Max_Ejec OR iRegsInforSat >= 9 THEN
        LET cCodRet = '006';    END IF;

    RETURN cCodRet,NVL(dFecha_hoy,'01-01-1900'),NVL(TRIM(cServer_ifx),''),NVL(TRIM(cUsuario_ifx),''),NVL(TRIM(cPassword_ifx),''),
           NVL(TRIM(cRuta_Origen_ifx),''),NVL(TRIM(cPC_Envio_SAT),''),NVL(TRIM(cUsuario_Envio_SAT),''),
           NVL(TRIM(cRuta_Envio_SAT),''),NVL(TRIM(cPC_Recibo_SAT),''),NVL(TRIM(cUsuario_Recibo_SAT),''),
           NVL(TRIM(cPassword_Recibo_SAT),''),NVL(TRIM(cRuta_Recibo_SAT),''),NVL(TRIM(cNum_Max_Ejec),''),
           NVL(TRIM(cCasFim),''),NVL(TRIM(cRuta_Recibo_Envio),''),NVL(iRegsResulSat,0),NVL(iRegsInforSat,0);
    
    END
    
END PROCEDURE
