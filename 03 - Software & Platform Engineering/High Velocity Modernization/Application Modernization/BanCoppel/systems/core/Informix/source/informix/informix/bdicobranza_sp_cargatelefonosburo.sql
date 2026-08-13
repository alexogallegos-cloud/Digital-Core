CREATE PROCEDURE "informix".sp_cargatelefonosburo()
       RETURNING CHAR(5), CHAR(80);
       
DEFINE vCodRet                  CHAR(5);
DEFINE vMensaje                 CHAR(80);
DEFINE SQL_ERR, ISAM_ERR        INTEGER;
DEFINE ERROR_INFO               VARCHAR(80);
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
DEFINE cProceso                 CHAR(4);
DEFINE vvcCod_ret               CHAR(6);

LET SQL_ERR  = 0; 
LET ISAM_ERR = 0; 
LET ERROR_INFO = '';
LET vCodRet  = '00000'; LET vCodRet_2   = ''; LET vCodRet_tel = '';  
LET vvcCod_ret  = '';
LET vMensaje = '';
LET v_fecha  = DATE(1);
LET v_dia    = '';  LET v_mes    = '';  LET v_anio   = '';
LET cRuta    = '';  LET cNombre  = '';
LET cRuta2   = '';  LET cNombre2 = '';
LET iParamRuta  = 20;
LET iParamNombre = 40;
LET iRegistros  = 0;
LET cCadena     = '';
LET cEmpresa    = '001';
LET v_count     = 0;
LET v_numcte = ''; 
LET v_cuenta = '';
LET v_telefono1 = '';  LET v_telefono2 = '';  LET v_telefono3 = '';  
LET v_telefono4 = '';  LET v_telefono5 = '';
LET v_longitud  = 0;
LET cProceso    = '0020';   


 --SET DEBUG FILE TO "/informix/macf/sp_cargatelefonosburo.out";
 --TRACE ON; 

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET vCodRet  = SQL_ERR;
        LET vMensaje  = ERROR_INFO;
         
        IF vCodRet = '-668' THEN
            LET vMensaje  = ISAM_ERR || ' El archivo a procesar no se encuentra en la carpeta';
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, vCodRet, trim(vMensaje), '02')
            RETURNING vvcCod_ret;
            LET vCodRet  = '00000';
            LET vMensaje  = '';
            RETURN vCodRet, vMensaje;
        ELSE 
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, vCodRet, vMensaje, '02')
            RETURNING vvcCod_ret;
        END IF;
          
        RETURN vCodRet, vMensaje;
        
    END EXCEPTION;

    SET LOCK MODE TO WAIT 3;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, vCodRet, vMensaje, '01') RETURNING vvcCod_ret;
    SET ISOLATION TO dirty READ;

    SELECT fecha_hoy 
    into v_fecha
    from bdinteg:si_fechas
    WHERE empresa = cEmpresa;
    
    IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'tmp_telefonos_buro_2'  AND dbsname = 'bdicobranza') THEN
            DROP TABLE tmp_telefonos_buro_2;
    END IF;

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
   
    --LET vMensaje = 'Obtuvo parametros..' || iParamRuta || '-' || iParamNombre || '  ' || v_dia || v_mes || v_anio || ' -- ' || cRuta || '  ' || cNombre2;
    
  IF NVL(cRuta,'') <> '' and NVL(cNombre2, '') <> '' THEN

    LET cNombre = trim(SUBSTR(cNombre2,1,LENGTH(cNombre2)) || v_dia || v_mes || v_anio || '.txt');
    
    LET cCadena = 'echo "load from ''' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cNombre,1,LENGTH(cNombre)) || '''' ||
                  ' insert into bdicobranza:tmp_telefonos_buro_2 " > ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'importa_telefonosburo.sql;';
      
    system SUBSTR(cCadena,1,LENGTH(cCadena));              
    --INSERT INTO bdicobranza:cb_mensajes_trace(nom_variable, descripcion) VALUES('cCadena', trim(cCadena));

    LET cCadena = 'dbaccess bdicobranza ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'importa_telefonosburo.sql';
    
    system SUBSTR(cCadena,1,LENGTH(cCadena));
    --DESPUES QUE LOS IMPORTE SE DEBERAN PROCESAR para insertarlos a CB_TELEFONOS  con el SP "sp_cat_graba_telefono_adicional" usado por Cajera Capturista

    SELECT count(*) into v_count 
      FROM tmp_telefonos_buro_2;
      
     IF v_count <= 0 THEN
         LET vCodRet = '00001';
         LET vMensaje = 'NO SE CARGARON REGISTROS A LA TABLA TEMPORAL';
         RETURN vCodRet, vMensaje;  
     END IF;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    --SET pdqpriority 20;
   
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

      DROP INDEX "informix".idx_tmp_telefonos_buro_2;
      --DROP TABLE "informix".tmp_telefonos_buro_2;
      
      LET cCadena = '';
      LET cCadena = 'bzip2 ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cNombre,1,LENGTH(cNombre)); 
      system SUBSTR(cCadena,1,LENGTH(cCadena));
      
      CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, vCodRet, vMensaje, '03')
      RETURNING vvcCod_ret;
      
  END IF;
	  
   	
RETURN vCodRet, vMensaje;
END 
END PROCEDURE;