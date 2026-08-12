CREATE PROCEDURE "informix".sp_compac_genera_reporte(pEmpresa CHAR(3), pTipoReporte INTEGER, pFechaIni DATE, pFechaFin DATE)
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
		  CHAR(80) AS Nombre_archivo; 
---DECLARACIONES
DEFINE cCodRet        	  CHAR(6); 
DEFINE cMensajeRet        CHAR(80);
DEFINE cComentario        CHAR(80);
DEFINE iSqlErr      	  INTEGER;
DEFINE iIsamErr           INTEGER;
DEFINE cErrorInfo         CHAR(80);
DEFINE cNombreArchivo	  CHAR(80);
DEFINE iNumArchivo		  INTEGER;
DEFINE cTipoArchivo	      CHAR(80);
DEFINE cConsulta		  CHAR(2200);
DEFINE cConsulta2		  CHAR(200);
DEFINE cConsulta3		  CHAR(200);
DEFINE cSql		 		  CHAR(3000);
DEFINE cParam1		      CHAR(20);
DEFINE cParam2		      CHAR(20);
DEFINE cParam3		      CHAR(20);
DEFINE cRuta		      CHAR(80);
DEFINE cTabla		      CHAR(1);
DEFINE dtFecha		      DATE;

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "PROCESO EXITOSO";
LET iNumArchivo			= 0;
LET cNombreArchivo		= "reporte";
LET cTipoArchivo     	= "";
LET cConsulta			= "";
LET cConsulta2			= "";
LET cConsulta3			= "";
LET cParam1				= "";
LET cParam2				= "";
LET cParam3				= "";
LET cRuta				= "";
LET cTabla				= "N";
LET dtFecha				= DATE(1);
       
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    LET cCodRet= iSqlErr;
	LET cMensajeRet = cErrorInfo;
	IF cTabla="S" THEN
		DROP TABLE TME_ENCABEZADOS;
	END IF;
    RETURN cCodRet, cMensajeRet,"";
END EXCEPTION;

--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_compac_genera_reporte.out';
--TRACE ON;

IF NVL(pEmpresa,"") = "" OR  NVL(pTipoReporte,"") = "" OR  NVL(pFechaIni,"") = "" OR  NVL(pFechaFin,"") = "" THEN
	LET cCodRet= "000001";
	LET cMensajeRet = "Parametro no valido para realizar la consulta";
	RETURN cCodRet, cMensajeRet,"";
END IF;

--se obtiene la ruta donde se almacenara el archivo generado.
	SELECT  TRIM(valor_alfabetico) 
	INTO cRuta
	FROM bdicobranza:cb_param_campania
	WHERE tipo_campania = 11  
	AND  grupo_parametro = 'RUTAS'
	AND num_parametro =1;
	
IF NVL(cRuta,"") = "" THEN
	LET cCodRet= "000002";
	LET cMensajeRet = "No se pudo obtener la ruta donde se almacenara el archivo";
	RETURN cCodRet, cMensajeRet,"";
END IF;	
		SELECT fecha_hoy   
		INTO dtFecha 
		FROM bdicred:sd_fechas
		WHERE empresa=pEmpresa;

	LET cNombreArchivo= TRIM(cNombreArchivo)|| DAY(dtFecha) || LPAD(TRIM(MONTH(dtFecha)::CHAR(2)),2,'0') || YEAR(dtFecha);

 IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'TME_ENCABEZADOS'  AND dbsname = 'bdicobranza') THEN
            DROP TABLE TME_ENCABEZADOS;
 END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
	  FOREACH WITH HOLD 
	   SELECT num_archivo,tipo_archivo,query,param1,param2,param3
		INTO iNumArchivo,cTipoArchivo,cConsulta,cParam1,cParam2,cParam3		
		FROM  bdicobranza:"informix".cb_param_archivos 
		WHERE num_archivo = pTipoReporte
			
		IF NVL(iNumArchivo,0) <> 3 AND NVL(iNumArchivo,0) > 0 THEN
			
			IF cParam1 IN ('001','1','2') THEN
				LET cConsulta= replace( cConsulta , 'Param1' , "'"||TRIM(cParam1)||"'");
			END IF;
			
			IF cParam2 = 'Fecha Inicio' THEN
				LET cParam2 = pFechaIni;
				LET cConsulta= replace( cConsulta , 'Param2' , "'"||TRIM(cParam2)||"'");
			END IF;
			
			IF cParam3 = 'Fecha Fin' THEN
				LET cParam3 = pFechaFin;
				LET cConsulta= replace( cConsulta , 'Param3' , "'"||TRIM(cParam3)||"'");
			END IF;
		END IF;
		IF iNumArchivo =3 THEN
			IF cParam1 = 'Fecha Inicio' THEN
				LET cParam1 = pFechaIni;
				LET cConsulta= replace( cConsulta , 'Param1' , "'"||TRIM(cParam1)||"'");
			END IF;
			
			IF cParam2 = 'Fecha Fin' THEN
				LET cParam2 = pFechaFin;
				LET cConsulta= replace( cConsulta , 'Param2' , "'"||TRIM(cParam2)||"'");
			END IF;
		END IF;
		--crear encabezado dependiendo el tipo de archivo
		IF iNumArchivo =1 THEN
			CREATE TABLE TME_ENCABEZADOS(
			plaza   CHAR(20),
			ciudad	CHAR(20),
			sucursal CHAR(20),
			origen	CHAR(20),
			tipo_compac CHAR(20),
			plazo CHAR(20),
			total CHAR(20),
			importe CHAR(20),
			importe_pagado CHAR(20),
			cumplido CHAR(20),
			fecha_compac CHAR(20),
			fecha_vencimiento CHAR(20)
			);
			LET cTabla="S";
			LET cConsulta2 = 'INSERT INTO TME_ENCABEZADOS (plaza,ciudad,sucursal,origen,tipo_compac,plazo,total,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento)';
			LET cConsulta3 = 'SELECT plaza,ciudad,sucursal,origen,tipo_compac,plazo,total,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento FROM  TME_ENCABEZADOS';
			INSERT INTO TME_ENCABEZADOS (plaza,ciudad,sucursal,origen,tipo_compac,plazo,total,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento) 
			VALUES("plaza","ciudad","sucursal","origen","tipo_compac","plazo","total","importe","importe pagado","cumplido","fecha_compac","fecha_vencimiento");
		ELIF iNumArchivo =2 THEN
			IF  cTabla="N" THEN 
				CREATE TABLE TME_ENCABEZADOS(
				SUCURSAL   CHAR(20),
				NUMERO_CONVENIO	CHAR(20),
				IMPORTE_CONVENIADO CHAR(20),
				IMPORTE_PAGADO	CHAR(20),
				CUMPLIMIENTO CHAR(20));
				LET cTabla="S";
			END IF;
			
			LET cConsulta2 = 'INSERT INTO TME_ENCABEZADOS (SUCURSAL,NUMERO_CONVENIO,IMPORTE_CONVENIADO,IMPORTE_PAGADO,CUMPLIMIENTO)';
			IF cParam1 = '1' THEN
				INSERT INTO TME_ENCABEZADOS (SUCURSAL,NUMERO_CONVENIO,IMPORTE_CONVENIADO,IMPORTE_PAGADO,CUMPLIMIENTO)
				VALUES("COMPROMISOS","","","","");
			ELIF cParam1 = '2' THEN
				INSERT INTO TME_ENCABEZADOS (SUCURSAL,NUMERO_CONVENIO,IMPORTE_CONVENIADO,IMPORTE_PAGADO,CUMPLIMIENTO)
				VALUES("ACUERDOS","","","","");
			END IF;
			LET cConsulta3 = 'SELECT SUCURSAL,NUMERO_CONVENIO,IMPORTE_CONVENIADO,IMPORTE_PAGADO,CUMPLIMIENTO FROM  TME_ENCABEZADOS';
			INSERT INTO TME_ENCABEZADOS (SUCURSAL,NUMERO_CONVENIO,IMPORTE_CONVENIADO,IMPORTE_PAGADO,CUMPLIMIENTO)
			VALUES("SUCURSAL","NUMERO DE CONVENIO","IMPORTE CONVENIADO","IMPORTE PAGADO","CUMPLIMIENTO");

		ELIF iNumArchivo =3 THEN
			CREATE TABLE TME_ENCABEZADOS(
				SUCURSAL   CHAR(20),
				Total_recuperarPagoMin   CHAR(50),
				RecupPesosPagoMin	CHAR(50),
				PorcRecupPagoMin CHAR(50),
				Total_recuperarVencido   CHAR(50),
				RecupPesosVencido	CHAR(50),
				PorcRecupVencido CHAR(50)
			);
			LET cTabla="S";
			LET cConsulta2 = 'INSERT INTO TME_ENCABEZADOS (SUCURSAL,Total_recuperarPagoMin,RecupPesosPagoMin,PorcRecupPagoMin,Total_recuperarVencido,RecupPesosVencido,PorcRecupVencido)';
			LET cConsulta3 = 'SELECT SUCURSAL,Total_recuperarPagoMin,RecupPesosPagoMin,PorcRecupPagoMin,Total_recuperarVencido,RecupPesosVencido,PorcRecupVencido FROM  TME_ENCABEZADOS';
			INSERT INTO TME_ENCABEZADOS (SUCURSAL,Total_recuperarPagoMin,RecupPesosPagoMin,PorcRecupPagoMin,Total_recuperarVencido,RecupPesosVencido,PorcRecupVencido)
				VALUES("SUCURSAL","Total a recuperar/Pago Mínimo del mes ($)","Recup. en pesos vs. Total Pago","(%) Recup. vs. Mínimo a Pagar","Total a recuperar/vdo. del mes ($)","Recup. en pesos vs. Total vdo.","(%) Recup. vs. vdo.");
		END IF;
		IF iNumArchivo = 1 THEN
			LET cSql = '';
			LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.'||'unl'|| ' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query1.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = "dbaccess bdicobranza " ||TRIM(cRuta)||'query1.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'echo "LOAD FROM ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.'||'unl'|| ' '||TRIM(cConsulta2)||'" > '|| TRIM(cRuta) ||'query4.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = "dbaccess bdicobranza " ||TRIM(cRuta)||'query4.sql';
			SYSTEM TRIM(cSql);
			-- borrado de temporales que fueron usados para la creacion del archivo a enviar a buro de credito
			LET cSql = '';
			LET cSQL = "rm " ||TRIM(cRuta)||'query1.sql';		
			SYSTEM cSql; 
			LET cSql = '';
			LET cSQL = "rm " ||TRIM(cRuta)||'query4.sql';		
			SYSTEM cSql; 
			LET cSql = '';
			LET cSQL = "rm " ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.'||'unl';		
			SYSTEM cSql; 		
		ELSE
			LET cSql = '';
			LET cSql = 'echo "'||TRIM(cConsulta2)|| ' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query.sql';

			SYSTEM TRIM(cSql);
					
			LET cSql = '';
	        LET cSql = "dbaccess bdicobranza " ||TRIM(cRuta)||'query.sql';
	        SYSTEM TRIM(cSql);
			-- borrado de temporales que fueron usados para la creacion del archivo a enviar a buro de credito
			LET cSql = '';
			LET cSQL = "rm " ||TRIM(cRuta)||'query.sql';		
			SYSTEM cSql; 
			LET cSql = '';
		END IF;
	  END FOREACH;
		LET cConsulta3 =' '||TRIM(cConsulta3);
		LET cSql = '';
		LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.'||TRIM(cTipoArchivo)|| ' DELIMITER '|| '''	'''||cConsulta3||'" > '|| TRIM(cRuta) ||'query2.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "dbaccess bdicobranza " ||TRIM(cRuta)||'query2.sql';
		SYSTEM TRIM(cSql);
		
	
        LET cSQL = "rm " ||TRIM(cRuta)||'query2.sql';		
        SYSTEM cSql; 
	
		IF cTabla="S" THEN
			DROP TABLE TME_ENCABEZADOS;
		END IF;
		LET cNombreArchivo= TRIM(cNombreArchivo)||'.'||TRIM(cTipoArchivo);
		RETURN cCodRet, cMensajeRet,cNombreArchivo;
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para la generacion de archivos de los tipos de reportes para estadistica de convenios',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 05/04/2011',
'BD    : BDICOBRANZA',
'Version: 20110404.0850',
'Se modifica para que use el tabulador como separador en la generación del archivo',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 20/04/2011',
'BD    : BDICOBRANZA',
'Version: 20110420.1250',
'2012-05-16 Si existe borrar la tabla TME_ENCABEZADOS al inicio del proceso. Autor: Marco A. Campos';

CREATE PROCEDURE "informix".sp_cargatelefonosburo_pba()
       RETURNING CHAR(5), CHAR(80);
       
DEFINE vCodRet                  CHAR(5);
DEFINE vMensaje                 CHAR(80);
DEFINE SQL_ERR, ISAM_ERR        INTEGER;
DEFINE ERROR_INFO               VARCHAR(80);
DEFINE cNombreProceso           CHAR(30);
DEFINE v_fecha                  DATE;
DEFINE v_dia, v_mes             CHAR(2);
DEFINE v_anio                   CHAR(4);
DEFINE cRuta                    CHAR(100);
DEFINE cRuta2                   CHAR(100);  
DEFINE cNombre                  CHAR(100);
DEFINE cNombre2                 CHAR(100);      
DEFINE iParamRuta               INTEGER;
DEFINE iParamNombre             INTEGER;  
DEFINE iRegistros               INTEGER;
DEFINE v_count                  INTEGER;
DEFINE cCadena                  CHAR(2000);
DEFINE cEmpresa                 CHAR(3);
DEFINE v_numcte                 CHAR(20); 
DEFINE v_cuenta                 CHAR(20);
DEFINE v_telefono1              CHAR(13);
DEFINE v_telefono2              CHAR(13); 
DEFINE v_telefono3              CHAR(13); 
DEFINE v_telefono4              CHAR(13);
DEFINE v_telefono5              CHAR(13);
DEFINE v_longitud               SMALLINT; 
DEFINE vCodRet_2                CHAR(6);
DEFINE vCodRet_tel              CHAR(5);

LET vCodRet  = '11100';
LET vMensaje = 'PROCESO INICIALIZADO';
LET SQL_ERR  = 0; 
LET ISAM_ERR = 0; 
LET ERROR_INFO = '';
LET cNombreProceso  = 'CARGA DE TELEFONOS DE BURO';
LET v_fecha  = DATE(1);
LET v_dia    = '';  
LET v_mes    = ''; 
LET v_anio   = '';
LET cRuta    = '';  
LET cNombre  = '';
LET cRuta2   = '';  
LET cNombre2 = '';
LET iParamRuta  = 20;
LET iParamNombre = 40;
LET iRegistros  = 0;
LET cCadena     = '';
LET cEmpresa    = '001';
LET v_count     = 0;
LET v_numcte = ''; 
LET v_cuenta = '';
LET v_telefono1 = ''; 
LET v_telefono2 = ''; 
LET v_telefono3 = '';
LET v_telefono4 = ''; 
LET v_telefono5 = '';
LET v_longitud  = 0;
LET vCodRet_2   = ''; 
LET vCodRet_tel = '';   

 SET DEBUG FILE TO "sp_cargatelefonosburo_pba.out";
 TRACE ON; 

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET vCodRet  = SQL_ERR;
        LET vMensaje  = ERROR_INFO;

        --insertar control de procesos
        INSERT INTO bdicobranza:cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc) 
         VALUES(cNombreProceso, '11222', vMensaje, user, v_fecha, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals), iRegistros);
       
        RETURN vCodRet, vMensaje;
    END EXCEPTION;

    SELECT fecha_hoy 
    into v_fecha
    from bdinteg:si_fechas
    WHERE empresa = cEmpresa;

    INSERT INTO bdicobranza:cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc) 
     VALUES(cNombreProceso, vCodRet, vMensaje, user, v_fecha, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals), iRegistros);
    
    IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'tmp_telefonos_buro_2'  AND dbsname = 'bdicobranza') THEN
            DROP TABLE tmp_telefonos_buro_2;
    END IF;

    INSERT INTO bdicobranza:cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc) 
     VALUES(cNombreProceso, '11110', 'Obtuvo fecha y borro tabla tmp_telefonos_buro_2 si existia...', user, v_fecha, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals), iRegistros);
    
   
    CREATE TABLE "informix".tmp_telefonos_buro_2
    (
    	cuenta           CHAR(20),
    	empleo           CHAR(60),
    	calleynum        CHAR(60),
    	colonia          CHAR(60),    	
    	delegacion       CHAR(60),
    	ciudad           CHAR(60),
    	estado           CHAR(10),
    	cp               CHAR(10),
    	telefono1        CHAR(13),
    	telefono2        CHAR(13),
    	telefono3        CHAR(13),
    	telefono4        CHAR(13),
    	telefono5        CHAR(13),
    	fecha_reg        CHAR(10) 
    );

    --CUENTA|EMPLEO|CALLE Y NUMERO|COLONIA|DELEGACION|CIUDAD|ESTADO|CP|TELEFONOS|FECHA
    CREATE INDEX "informix".idx_tmp_telefonos_buro_2 ON tmp_telefonos_buro_2 (cuenta) USING btree ;

    INSERT INTO bdicobranza:cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc) 
     VALUES(cNombreProceso, '11111', 'Creo tabla tmp_telefonos_buro_2 e indice idx_tmp_telefonos_buro_2...', user, v_fecha, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals), iRegistros);

    IF day(v_fecha) < 10 then
    	LET v_dia = '0' || day(v_fecha);
    ELSE
    	LET v_dia = day(v_fecha);
    END IF;
    
    IF month(v_fecha) < 10 then
    	LET v_mes = '0' || month(v_fecha);
    ELSE
    	LET v_mes = month(v_fecha);
    END IF;
    
    LET v_anio = year(v_fecha);

    SELECT valor  INTO cRuta
    FROM bdicobranza:cb_param
    WHERE empresa = cEmpresa
      AND cod_param = iParamRuta;

    SELECT valor  INTO cNombre2
    FROM bdicobranza:cb_param
    WHERE empresa = cEmpresa
      AND cod_param = iParamNombre;
   
    LET vMensaje = 'Obtuvo parametros..' || iParamRuta || '-' || iParamNombre || '  ' || v_dia || '-' || v_mes || '-' || v_anio;
    
    INSERT INTO bdicobranza:cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc) 
     VALUES(cNombreProceso, '11112', vMensaje, user, v_fecha, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals), iRegistros);


  IF NVL(cRuta,'') <> '' and NVL(cNombre2, '') <> '' THEN

    LET cNombre = trim(SUBSTR(cNombre2,1,LENGTH(cNombre2)) || v_dia || v_mes || v_anio || '.txt');
    
    LET cCadena = 'echo "load from ''' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cNombre,1,LENGTH(cNombre)) || '''' ||
                  ' insert into bdicobranza:tmp_telefonos_buro_2 " > ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'importa_telefonosburo.sql;';
      
    system SUBSTR(cCadena,1,LENGTH(cCadena));              
    --INSERT INTO bdicobranza:cb_mensajes_trace(nom_variable, descripcion) VALUES('cCadena', trim(cCadena));

    LET cCadena = 'dbaccess bdicobranza ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'importa_telefonosburo.sql';
    
    LET vMensaje = 'Armo cCadena: ' || cCadena;
    
    INSERT INTO bdicobranza:cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc) 
    VALUES(cNombreProceso, '11113', vMensaje, user, v_fecha, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals), iRegistros);
  
    system SUBSTR(cCadena,1,LENGTH(cCadena));
    --DESPUES QUE LOS IMPORTE SE DEBERAN PROCESAR para insertarlos a CB_TELEFONOS  con el SP "sp_cat_graba_telefono_adicional" usado por Cajera Capturista

     INSERT INTO bdicobranza:cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc) 
     VALUES(cNombreProceso, '11114', 'Ejecuto el load from...', user, v_fecha, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals), iRegistros);
 
    SELECT count(*) into v_count 
      FROM tmp_telefonos_buro_2;
      
     IF v_count <= 0 THEN
         LET vCodRet = '00001';
         LET vMensaje = 'NO SE CARGARON REGISTROS A LA TABLA TEMPORAL';
         
         INSERT INTO bdicobranza:cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc) 
         VALUES(cNombreProceso, '11115', 'No se cargaron registros en tabla tempo...', user, v_fecha, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals), iRegistros);
         RETURN vCodRet, vMensaje;  
     END IF;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    --SET pdqpriority 20;
   
     INSERT INTO bdicobranza:cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc) 
     VALUES(cNombreProceso, '11116', 'Justo antes de entrar a Foreach...', user, v_fecha, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals), iRegistros);
    
     FOREACH 
           SELECT cuenta, telefono1, telefono2, telefono3, telefono4, telefono5               --LENGTH(telefono1)  
             INTO v_cuenta, v_telefono1, v_telefono2, v_telefono3, v_telefono4, v_telefono5   --v_longitud
             FROM bdicobranza:tmp_telefonos_buro_2

           SELECT FIRST 1 numcte INTO v_numcte
             FROM bdicred:sd_maecred
            WHERE num_credito = v_cuenta;

           
           IF LENGTH(v_telefono1)>= 10 THEN  --MÍNIMO QUE SEA DE 10 POSICIONES.
              -- VALIDAR QUE NO TRAIGA CARACTERES RAROS (bdinteg:sp_tipored solo recibe tels de 10 caracteres)
              EXECUTE procedure bdinteg:"informix".sp_validar_telefono(v_telefono1) into vCodRet_tel;

           -- pEmpresa CHAR(3), pOrigen SMALLINT, pNumcte CHAR(20), pTipo_telefono SMALLINT, pTelefono CHAR(13), pExtension CHAR(5), pParentesco CHAR(1), 
           --                   pResultado_gestion   INTEGER, pEjecutivo CHAR(8))

              IF vCodRet_tel = '00000' THEN
                  EXECUTE PROCEDURE "informix".sp_cat_graba_telefono_adicional(cEmpresa, 5, v_numcte, 1, v_telefono1, '', '', 0, user) INTO vCodRet_2;
              END IF;
           END IF;
           LET vCodRet_tel = '';
           
           IF LENGTH(v_telefono2)>= 10 THEN  
              EXECUTE procedure bdinteg:"informix".sp_validar_telefono(v_telefono2) into vCodRet_tel;

              IF vCodRet_tel = '00000' THEN
                  EXECUTE PROCEDURE "informix".sp_cat_graba_telefono_adicional(cEmpresa, 5, v_numcte, 2, v_telefono2, '', '', 0, user) INTO vCodRet_2;
              END IF;
           END IF;
           LET vCodRet_tel = '';
            
           IF LENGTH(v_telefono3)>= 10 THEN  
              EXECUTE procedure bdinteg:"informix".sp_validar_telefono(v_telefono3) into vCodRet_tel;

              IF vCodRet_tel = '00000' THEN
                  EXECUTE PROCEDURE "informix".sp_cat_graba_telefono_adicional(cEmpresa, 5, v_numcte, 3, v_telefono3, '', '', 0, user) INTO vCodRet_2;
              END IF;
           END IF;
           LET vCodRet_tel = '';
            
           IF LENGTH(v_telefono4)>= 10 THEN  
              EXECUTE procedure bdinteg:"informix".sp_validar_telefono(v_telefono4) into vCodRet_tel;

              IF vCodRet_tel = '00000' THEN
                  EXECUTE PROCEDURE "informix".sp_cat_graba_telefono_adicional(cEmpresa, 5, v_numcte, 4, v_telefono4, '', '', 0, user) INTO vCodRet_2;
              END IF;
           END IF;
           LET vCodRet_tel = '';

           IF LENGTH(v_telefono5)>= 10 THEN  
              EXECUTE procedure bdinteg:"informix".sp_validar_telefono(v_telefono5) into vCodRet_tel;

              IF vCodRet_tel = '00000' THEN
                  EXECUTE PROCEDURE "informix".sp_cat_graba_telefono_adicional(cEmpresa, 5, v_numcte, 5, v_telefono5, '', '', 0, user) INTO vCodRet_2;
              END IF;
           END IF;
                           
           LET iRegistros = iRegistros + 1;
      END FOREACH 
      
      LET vMensaje = 'PROCESO FINALIZADO';

     INSERT INTO bdicobranza:cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc) 
     VALUES(cNombreProceso, '11117', 'Concluyo Foreach...', user, v_fecha, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals), iRegistros);
 	    
      INSERT INTO bdicobranza:cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc) 
      VALUES(cNombreProceso, '11200', vMensaje, user, v_fecha, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals), iRegistros);

     INSERT INTO bdicobranza:cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc) 
     VALUES(cNombreProceso, '11118', 'Inserto en cb_bitacora_cob...', user, v_fecha, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals), iRegistros);

      DROP INDEX "informix".idx_tmp_telefonos_buro_2;
      --DROP TABLE "informix".tmp_telefonos_buro_2;
      INSERT INTO bdicobranza:cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc) 
      VALUES(cNombreProceso, '11119', 'Borro indice...', user, v_fecha, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals), iRegistros);
      
  END IF;
	  
   	
RETURN vCodRet, vMensaje;
END 
END PROCEDURE;