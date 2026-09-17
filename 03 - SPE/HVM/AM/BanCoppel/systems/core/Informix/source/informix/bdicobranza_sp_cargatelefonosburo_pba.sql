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