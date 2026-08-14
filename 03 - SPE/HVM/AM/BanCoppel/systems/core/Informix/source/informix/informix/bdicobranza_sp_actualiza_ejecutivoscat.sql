CREATE PROCEDURE "informix".sp_actualiza_ejecutivoscat()
       RETURNING CHAR(6), CHAR(80);


DEFINE v_cvearea                                          CHAR(2);
DEFINE cEmpresa                                           CHAR(3);
DEFINE v_proceso                                          CHAR(4);
DEFINE v_campana                                          CHAR(5);
DEFINE vCodRet, vvcCod_ret, v_numedificio2, v_nummodulo, v_numgrupo, v_numsubgrupo  CHAR(6);
DEFINE v_keyx, v_numedificio, v_cvepuesto                 CHAR(10); 
DEFINE v_contrasena                                       CHAR(12);
DEFINE v_numempleado, v_numempleado_2, v_numcentro, v_fechaingresocoppel, v_fechaingresocobtel, v_telefono    CHAR(20);
DEFINE cNombreProceso, v_nombre, v_apellidopaterno, v_apellidomaterno               CHAR(30);
DEFINE ERROR_INFO                                                                   VARCHAR(80);
DEFINE cRuta, cNombre, cNombre2, vMensaje, vMensaje2                                CHAR(100);
DEFINE v_fecha                                                                      DATE;

DEFINE i_ins_datos_grales, i_upd_datos_grales, i_ins_ejecutivos, i_upd_ejecutivos,v_procesar_datosgrales           INTEGER;
DEFINE SQL_ERR, ISAM_ERR, iParamRuta, iParamNombre, iParamNombre2, iCantidad, v_paso        INTEGER;
DEFINE cCadena                                                                      CHAR(500); 
            

LET v_cvearea = '';             LET v_numempleado = '';     LET v_numempleado_2 = '';   LET v_numcentro = '';       LET v_fechaingresocoppel = '';
LET v_fechaingresocobtel = '';  LET v_telefono = '';        LET v_contrasena = '';      LET v_nombre = '';          LET v_apellidopaterno = '';
LET v_numedificio = '';         LET v_cvepuesto = 0;        LET v_keyx = '';            LET vvcCod_ret = '';        LET v_proceso = '0027';
LET i_ins_datos_grales = 0;     LET i_upd_datos_grales = 0; LET i_ins_ejecutivos = 0;   LET i_upd_ejecutivos = 0;   LET v_paso = 0;   
LET v_nummodulo = '';           LET v_numedificio2 = '';    LET v_campana = '';         LET iCantidad = 0;          LET v_procesar_datosgrales = 1; 

LET cNombreProceso  = 'ACTUALIZA EJECUTIVOS Y HORARIOS CAT';
LET vCodRet         = '000000';
LET vMensaje        = 'PROCESO FINALIZADO'; 
LET vMensaje2       = '';
LET cCadena         = '';
LET cEmpresa        = '001';
LET iParamRuta      = 83; LET iParamNombre    = 84;   LET iParamNombre2    = 85;
LET cRuta           = '';
LET cNombre         = '';
LET v_fecha         = DATE(1);
LET v_numempleado   = "";

   
--SET DEBUG FILE TO "/informix/macf/sp_cargarcatalogosepomex.out";
--TRACE ON; 

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
--SET pdqpriority 20;

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET vCodRet  = SQL_ERR;
        LET vMensaje  = ERROR_INFO;

        IF vCodRet = '-668' THEN
          IF ( v_paso = 1  OR  v_paso = 3 ) then
              LET vCodRet = '00003';
              LET vMensaje = 'NO EXISTE LA RUTA QUE SE INDICA EN LOS PARAMETROS';
          ELIF ( v_paso = 2 OR  v_paso = 4)then
              LET vCodRet = '00004';
              LET vMensaje = 'NO SE ENCONTRO ALGUN ARCHIVO';
          END IF;
          CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, v_proceso, vCodRet, vMensaje, '02')
            RETURNING vvcCod_ret;
          LET vCodRet = '000000';
          LET vMensaje = 'PROCESO FINALIZADO';
          RETURN vCodRet, vMensaje;   
        END IF;
       
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, v_proceso, vCodRet, vMensaje, '02')
          RETURNING vvcCod_ret;
       
        RETURN vCodRet, vMensaje;
    END EXCEPTION;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, v_proceso, vCodRet, vMensaje, '01') RETURNING vvcCod_ret;

    --Se toma la fecha del día anterior, así ya es seguro que está el archivo
    SELECT fecha_ant  INTO v_fecha
      FROM bdicred:sd_fechas
     WHERE empresa = cEmpresa;

    --LET v_fecha = MDY('05','02','2013');

    IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'cb_cat_datosgenerales_temp'  AND dbsname = 'bdicobranza' AND partnum >1048577) THEN
            DROP TABLE cb_cat_datosgenerales_temp;
    END IF;
 
    --truncate cb_cat_outmsgs;   -- TEST 
  
    SELECT valor  INTO cRuta
      FROM bdicobranza:cb_param 
     WHERE empresa = cEmpresa 
       AND cod_param = iParamRuta;	
    
    --- PROD  '/home/syscobra/cat/envios/respaldo/'
    --LET cRuta = '/informix/macf/';   --- TEST
    
    SELECT valor  INTO cNombre2
      FROM bdicobranza:cb_param 
     WHERE empresa = cEmpresa 
       AND cod_param = iParamNombre;	
    	
    --LET cNombre2 = 'Catdatosgenerales';   --  TEST  Catdatosgenerales01052013.txt
          
    LET cNombre = trim(cNombre2) || LPAD(DAY(v_fecha),2,0) || LPAD(MONTH(v_fecha),2,0) || YEAR(v_fecha) || '.txt';
    
    -- PRIMER ARCHIVO A PROCESAR CAT DATOS GENERALES
    -- CREAR TABLA
    CREATE TABLE cb_cat_datosgenerales_temp(
        cvearea           	char(2),
        numempleado       	char(20),
        nombre            	char(30),
        apellidopaterno   	char(30),
        apellidomaterno   	char(30),
        numedificio       	char(10),
        cvepuesto         	char(10),
        numcentro         	char(20),
        fechaingresocoppel	char(20),
        fechaingresocobtel	char(20),
        telefono          	char(20),
        contrasena        	char(12),
        keyx              	char(10) 
    );

    IF ( NVL(cRuta,'') <> '' and NVL(cNombre,'') <> '') THEN
    
          
        LET cCadena = 'echo "load from ''' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cNombre,1,LENGTH(cNombre)) || '''' ||
                      ' INSERT INTO bdicobranza:cb_cat_datosgenerales_temp" > ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'importa_datosgenerales.sql'; 

        LET v_paso = 1;
        System SUBSTR(cCadena,1,LENGTH(cCadena)); 
        
        let cCadena = 'dbaccess bdicobranza ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'importa_datosgenerales.sql';
       
        LET v_paso = 2;
        System SUBSTR(cCadena,1,LENGTH(cCadena));
    	
    	  SELECT count(*) into iCantidad
          FROM bdicobranza:cb_cat_datosgenerales_temp;
          
        IF iCantidad <= 0 THEN
              LET vMensaje2 =  'No hubo información que cargar(datos grales).' ;  
    		      CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, v_proceso, vCodRet, TRIM(vMensaje2) , '02')
                RETURNING vvcCod_ret;
              LET v_procesar_datosgrales = 0;  
        END IF; 
    	
    	  IF v_procesar_datosgrales > 0 THEN
            FOREACH
               SELECT NVL(cvearea, ''), NVL(numempleado,''), NVL(nombre,''), NVL(apellidopaterno,''), NVL(apellidomaterno,''), NVL(numedificio,''), NVL(cvepuesto,''),
                      NVL(numcentro,''), NVL(fechaingresocoppel,''), NVL(fechaingresocobtel,''), NVL(telefono,''), NVL(contrasena,''), NVL(keyx,'')
                 INTO v_cvearea, v_numempleado, v_nombre, v_apellidopaterno, v_apellidomaterno, v_numedificio, v_cvepuesto, v_numcentro, v_fechaingresocoppel, 
                      v_fechaingresocobtel, v_telefono, v_contrasena, v_keyx 
                 FROM cb_cat_datosgenerales_temp
                 
                 SELECT numempleado
                   INTO v_numempleado_2
                   FROM "informix".cb_cat_datosgenerales
                  WHERE numempleado = v_numempleado;
                   
                   IF NVL(v_numempleado_2,'') = '' THEN
                      INSERT INTO "informix".cb_cat_datosgenerales(cvearea, numempleado, nombre, apellidopaterno, apellidomaterno, numedificio, cvepuesto, numcentro, 
                                                                 fechaingresocoppel, fechaingresocobtel, telefono, contrasena, keyx) 
                      VALUES(v_cvearea, v_numempleado, v_nombre, v_apellidopaterno, v_apellidomaterno, v_numedificio, v_cvepuesto, v_numcentro, v_fechaingresocoppel, 
                             v_fechaingresocobtel, v_telefono, v_contrasena, v_keyx);
                      LET i_ins_datos_grales = i_ins_datos_grales + 1;
                   ELSE
                      UPDATE "informix".cb_cat_datosgenerales SET cvearea = v_cvearea, nombre = v_nombre, apellidopaterno = v_apellidopaterno,          
                                                                  apellidomaterno = v_apellidomaterno, numedificio = v_numedificio, cvepuesto = v_cvepuesto,
                                                                  numcentro = v_numcentro, fechaingresocoppel = v_fechaingresocoppel, fechaingresocobtel = v_fechaingresocobtel,
                                                                  telefono = v_telefono, contrasena = v_contrasena, keyx = v_keyx
                                                      WHERE numempleado = v_numempleado_2;
                      LET i_upd_datos_grales = i_upd_datos_grales + 1;
                   END IF;
            END FOREACH            
    
        		LET vMensaje2 =  ' ins_datos_grales = ' || i_ins_datos_grales || ' - upd_datos_grales = ' || i_upd_datos_grales ;  
        		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, v_proceso, vCodRet, TRIM(vMensaje2) , '02')
              RETURNING vvcCod_ret;
              
		     END IF;
		
    		-- SEGUNDO ARCHIVO A PROCESAR CAT EJECUTIVOS ------
    		IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'cb_catejecutivos_temp'  AND dbsname = 'bdicobranza' AND partnum >1048577) THEN
                DROP TABLE cb_catejecutivos_temp;
        END IF;
    		
    		SELECT valor  INTO cNombre2
          FROM bdicobranza:cb_param 
         WHERE empresa = cEmpresa 
           AND cod_param = iParamNombre2;
    		
    		LET cNombre = trim(cNombre2) || LPAD(DAY(v_fecha),2,0) || LPAD(MONTH(v_fecha),2,0) || YEAR(v_fecha) || '.txt';
    		
    		CREATE TABLE "informix".cb_catejecutivos_temp ( 
            numedificio	char(6),
            nummodulo  	char(6),
            numgrupo   	char(6),
            numsubgrupo	char(6),
            numempleado	char(20),
            campana    	char(5),
            keyx       	char(10)   
    		);
    		
    		
    		LET cCadena = 'echo "load from ''' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cNombre,1,LENGTH(cNombre)) || '''' ||
                          ' INSERT INTO bdicobranza:cb_catejecutivos_temp" > ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'importa_catejecutivos.sql'; 
    
        LET v_paso = 3;    
            System SUBSTR(cCadena,1,LENGTH(cCadena)); 
        
            let cCadena = 'dbaccess bdicobranza ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'importa_catejecutivos.sql';
    
        LET v_paso = 4;
            System SUBSTR(cCadena,1,LENGTH(cCadena));
    
          SELECT count(*) into iCantidad
            FROM bdicobranza:cb_catejecutivos_temp;
          
          IF iCantidad <= 0 THEN
              LET vMensaje2 =  'No hubo información que cargar (catejecutivos).' ;  
    		      CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, v_proceso, vCodRet, TRIM(vMensaje2) , '02')
                RETURNING vvcCod_ret;
                
              CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, v_proceso, vCodRet, vMensaje, '03')
                RETURNING vvcCod_ret;
                  
              RETURN vCodRet, vMensaje;
          ELSE
              TRUNCATE "informix".cb_catejecutivos;
          END IF; 
    
        FOREACH
            SELECT numedificio, nummodulo, numgrupo, numsubgrupo, numempleado, campana, keyx
              INTO v_numedificio2, v_nummodulo, v_numgrupo, v_numsubgrupo, v_numempleado, v_campana, v_keyx
              FROM "informix".cb_catejecutivos_temp
      
              INSERT INTO "informix".cb_catejecutivos(numedificio, nummodulo, numgrupo, numsubgrupo, numempleado, campana, keyx)
                    VALUES(v_numedificio2, v_nummodulo, v_numgrupo, v_numsubgrupo, v_numempleado, v_campana, v_keyx);
    
              LET i_ins_ejecutivos = i_ins_ejecutivos + 1;
        END FOREACH
    		
    		LET vMensaje2 =  ' i_ins_ejecutivos = ' || i_ins_ejecutivos ;  
    		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, v_proceso, vCodRet, TRIM(vMensaje2) , '02')
          RETURNING vvcCod_ret;
    		
		END IF;	
		
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, v_proceso, vCodRet, vMensaje, '03')
      RETURNING vvcCod_ret;
		
RETURN vCodRet, vMensaje;

END 
END PROCEDURE;