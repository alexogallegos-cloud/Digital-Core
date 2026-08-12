CREATE PROCEDURE "informix".sp_registro_bitacora_envio_mensajes(
        pIdProceso VARCHAR(20), pNumTarjeta VARCHAR(16), pUsuario CHAR(10),
        pFechaInsert DATETIME YEAR TO SECOND, pMonto MONEY (16,2), pFechaCompleta DATETIME YEAR TO SECOND,
        pComercioGiro VARCHAR (50)
    )
    RETURNING VARCHAR(6) as Cod_ret, VARCHAR(80) as Men_ret;

    ---Definicion de variables
    DEFINE vNumTarjeta          VARCHAR(16);
    DEFINE vsnumcte 	        CHAR (20);
    DEFINE vsCodRet1            CHAR(5);
    DEFINE vsCodRet2            CHAR(5);
    DEFINE vstelefono	        CHAR(13);
    DEFINE vstipotel 	        SMALLINT;
    DEFINE vsSecuencia          SMALLINT;
    DEFINE vsStatustel	        CHAR(1);
    DEFINE vsextension 	   	    CHAR(5);
    DEFINE vscarrier	   	    SMALLINT;
    DEFINE vsnombrecarrier 	    CHAR(20);
    DEFINE vsStatusvalidacion   SMALLINT;
    DEFINE vscorreo			    CHAR(100);
    DEFINE vstipocorreo		    SMALLINT;
    DEFINE vsStatuscorreo       CHAR(1);
    DEFINE vsMensaje            CHAR(200);
    DEFINE vsString1            VARCHAR(50);  
    DEFINE cCodRet              CHAR(5);
    DEFINE vsecuencial          INTEGER;
    DEFINE valerta1             VARCHAR(10);
    DEFINE valerta2             VARCHAR(10);
    DEFINE vIdPlantilla1        VARCHAR(12); 
    DEFINE vIdPlantilla2        VARCHAR(12); 
    DEFINE vdFechaInsert        DATETIME YEAR TO FRACTION(5);
    DEFINE vdFechaHoy           DATETIME YEAR TO FRACTION(5);
    DEFINE vcount               INTEGER;    
    DEFINE vFechaInsertRec DATETIME YEAR TO SECOND;
    
    --NOTA: 
    -- valerta1 y valerta2: Tienen asignado 10 caracteres correspondiente al parametro pIdMsj correspondiente en bdimnsj.sp_registra_evento.sql
    -- vIdPlantilla1, vIdPlantilla2: Tienen asignado 12 caracteres correspondiente al parametro pIdParam correspondiente en bdimnsj.sp_registra_evento.sql
    
    BEGIN
        
        --SET DEBUG FILE TO "/informix/argoz/sp_registro_bitacora_envio_mensajes.out";
        --TRACE ON;
        
        ---Inicializacion y asignacion de valores
        LET vsnumcte           = '';
        LET vsCodRet1          = '00000';
        LET vsCodRet2          = '00000';
        LET vsMensaje          = 'Proceso ejecutado exitosamente.';
        LET vstelefono         = '';
        LET vsMensaje          = ''; 
        LET vstipotel          = 0;
        LET vsSecuencia        = 0;
        LET vsStatustel        = '';
        LET vsextension        = '';
        LET vscarrier          = 0;   
        LET vsnombrecarrier    = '';
        LET vsStatusvalidacion = 0;
        LET vscorreo           = '';
        LET vsStatuscorreo     = '';
        LET vstipocorreo       = 0;
        LET cCodRet            = '00000';
        LET vsecuencial        = 0; 
        LET vdFechaInsert      = sysdate;  
        LET vdFechaHoy         = sysdate;  
        LET vcount             = 0;
        LET vNumTarjeta        = pNumTarjeta;        
        LET vFechaInsertRec    = pFechaInsert;
        
        -- A) REC_SUC     ==> Parametro considerado cuando la tarjeta ya se recibio en sucursal y notificar el primer aviso.
        -- B) MSJ_NOTIF_2 ==> Parametro considerado para notificar el segundo aviso.
        -- C) MSJ_NOTIF_3 ==> Parametro considerado para notificar el tercer aviso.
        -- D) MSJ_NOTIF_4 ==> Parametro considerado para notificar el cuarto aviso.
        
        -- NOTA: El id_proceso MSJ_NOTIF_SIA es realizado a traves del AppServer 
        -- utilizando el intercar:sp_registra_evento con 3 parametros.
        
        IF (pIdProceso = 'REC_SUC') THEN            
            
                LET vIdPlantilla1 ='TJTPERMAIL';
                LET valerta1      ='TJTPERMAIL';
                LET vIdPlantilla2 ='TJTPER_SMS';
                LET valerta2      ='TJTPER_SMS';
            
            ELIF (pIdProceso = 'MSJ_NOTIF_2') THEN
                
                LET vIdPlantilla1 ='TJTPEMAIL2';
                LET valerta1      ='TJTPEMAIL2';
                LET vIdPlantilla2 ='TJTPESMS2';
                LET valerta2      ='TJTPESMS2';
                
            ELIF (pIdProceso = 'MSJ_NOTIF_3') THEN
                
                LET vIdPlantilla1 ='TJTPEMAIL3';
                LET valerta1      ='TJTPEMAIL3';
                LET vIdPlantilla2 ='TJTPESMS3';
                LET valerta2      ='TJTPESMS3';
            
            ELIF (pIdProceso = 'MSJ_NOTIF_4') THEN
            
                LET vIdPlantilla1 ='TJTPEMAIL4';
                LET valerta1      ='TJTPEMAIL4';
                LET vIdPlantilla2 ='TJTPESMS4';
                LET valerta2      ='TJTPESMS4';                
        ELSE
                LET vsCodRet1 = '005'; 
                LET vsMensaje = 'Se intento procesar con un ID indefinido o erroneo';
                
                INSERT INTO intercard:"informix".bitacoraenvios_tjts (id_proceso,tarjeta,fecha_insert,estatus_envio,cod_ret,descripcion)
                VALUES (pIdProceso,vNumTarjeta,vdFechaInsert,'F',vsCodRet1,vsMensaje);
                
            RETURN 	vsCodRet1,vsMensaje; 
        
        END IF;
        
        INSERT INTO intercard:"informix".bitacoraenvios_tjts (id_proceso, tarjeta, fecha_insert, estatus_envio, tipo_envio, cod_ret, descripcion)
                    VALUES (pIdProceso,vNumTarjeta,vdFechaInsert,'P','','','');
    
        SELECT FIRST 1 secuencial,fecha_insert
            INTO  vsecuencial,vdFechaInsert
        FROM intercard:"informix".bitacoraenvios_tjts
        WHERE estatus_envio = 'P'
            AND fecha_insert = vdFechaInsert
            AND tarjeta = vNumTarjeta
            AND id_proceso= pIdProceso;
          
        SELECT {+INDEX(intercard:tarjeta 819_8158 } FIRST 1 numcliente INTO vsnumcte
        FROM    intercard:"informix".tarjeta  
        WHERE   numtarjeta = vNumTarjeta;
             
            ---De encontrar usuarios busca primero su contacto celular.
            IF (vsnumcte <> '' AND vsnumcte IS NOT NULL) THEN  

                /*
                    SP para consultar los telefonos
                    Empresa: 001 | NumeroCliente: vsnumcte | TipoTelefono: 2 (Todos los telefonos) | Consulta: Telefono mas reciente del tipo especificado
                */
                EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_telefonos("001",vsnumcte,2,"0")
                INTO vsCodRet1,vstelefono,vstipotel,vsSecuencia,vsStatustel,vsextension,vscarrier,vsnombrecarrier,vsStatusvalidacion;
               
                IF (vsCodRet1 <> '000') THEN   
                
                    ---Busqueda de correos electronicos.
                    /*
                        SP para consultar los telefonos
                        Empresa: 001 | NumeroCliente: vsnumcte | TipoCorreo: 1 (Todos los telefonos) | Consulta: Correo mas reciente del tipo especificado
                    */
                    EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos("001",vsnumcte,1,"0")
                        INTO vsCodRet2,vscorreo,vstipocorreo,vsStatuscorreo;         
                                  
                        IF (vsCodRet2 <> '000') THEN
                        
                            LET vsCodRet1 = '006';
                            LET vsMensaje = 'Error al obtener telefono y correo del titular.';
                            
                            UPDATE  intercard:"informix".bitacoraenvios_tjts
                            SET cod_ret = vsCodRet1, estatus_envio = 'E', descripcion = vsMensaje
                            WHERE secuencial = vsecuencial;
     
                        ELSE 

                            IF (vscorreo <> '' AND vscorreo IS NOT NULL) THEN
                                                
                                --- Invocar al procedimiento almacenado sp_registra_evento de BD bdimnsj (EMAIL)
                                LET  vsString1  =  SUBSTR(vNumTarjeta,13,4);
                                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento  ('1',valerta1,vIdPlantilla1,'000000000','',vNumTarjeta,'1',vsString1,'','','','','','','','','',vscorreo,'',0,0,0,0,0,vdFechaHoy,vFechaInsertRec)
                                    INTO    cCodRet;

                                IF  ( cCodRet <> '00000' )  THEN 
                                    
                                    LET vsCodRet1 = '004';
                                    LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                                    
                                    UPDATE  intercard:"informix".bitacoraenvios_tjts
                                    SET cod_ret = vsCodRet1, estatus_envio = 'E', descripcion = vsMensaje
                                    WHERE   secuencial = vsecuencial; 
                                
                                END IF; ---(cCodRet <> '00000')
                                                        
                                UPDATE  intercard:"informix".bitacoraenvios_tjts
                                SET cod_ret = '000', estatus_envio = 'V', descripcion = 'Se envio Correo al titular.' 
                                WHERE secuencial = vsecuencial;
                                          
                            ELSE --- De no encontrar ningun medio de contacto genera bitacora de error. 
                                                 
                                LET vsCodRet1 = '002';
                                LET vsMensaje   = 'Titular no tiene registrado celular o correo electronico.';
                                
                                UPDATE  intercard:"informix".bitacoraenvios_tjts
                                SET cod_ret = vsCodRet1, estatus_envio = 'E', descripcion = vsMensaje 
                                WHERE secuencial = vsecuencial;
                                                 
                            END IF; ---(vscorreo <> '' AND vscorreo is not null)
                            
                        END IF; ---(vsCodRet2 <> '000')
                                    
                ELSE --vsCodRet1 <> '000' 
                
                    IF (vstelefono <> '' AND vstelefono IS NOT NULL) THEN
                            
                        ---  INVOCAR  SP REGISTRA EVENTO (SMS) 
                        LET  vsString1  =  SUBSTR(vNumTarjeta,13,4);
                        
                        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento  ('1',valerta2,vIdPlantilla2,'000000000','',vNumTarjeta,'1',vsString1,'','','','','','','','','','',vstelefono,0,0,0,0,0,vdFechaHoy,vFechaInsertRec)
                            INTO cCodRet;
                                
                        IF ( cCodRet <> '00000' ) THEN
                            
                            LET vsCodRet1 = '004';
                            LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                            UPDATE  intercard:"informix".bitacoraenvios_tjts
                            SET cod_ret = vsCodRet1, estatus_envio = 'E', descripcion = vsMensaje
                            WHERE secuencial = vsecuencial;
                        
                        END IF; ---(cCodRet <> '00000')
                                
                        UPDATE  intercard:"informix".bitacoraenvios_tjts
                        SET cod_ret = '000', estatus_envio = 'V', descripcion = 'Se envio SMS al titular.'
                        WHERE secuencial = vsecuencial;
                            
                    ELSE    --- De no encontrar el telefono procede con la busqueda de algun correo electronico.
                                        
                        EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos("001",vsnumcte,1,"0")
                            INTO vsCodRet2,vscorreo,vstipocorreo,vsStatuscorreo;
                                        
                        -- Guarda bitacora en caso de generar un error en el proceso anterior. 
                        IF vsCodRet2 <> '000' THEN
                                        
                            LET vsCodRet1 = '006';
                            LET vsMensaje = 'Error al obtener telefono y correo del titular.';
                            
                            UPDATE  intercard:"informix".bitacoraenvios_tjts
                            SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                            WHERE secuencial = vsecuencial; 
                                        
                        ELSE 

                            IF (vscorreo <> '' AND vscorreo IS NOT NULL)  THEN  
                                
                                ---  INVOCAR  SP REGISTRA EVENTO (EMAIL) 
                                LET  vsString1  =  SUBSTR(vNumTarjeta,13,4); 
                                
                                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento  ('1',valerta1,vIdPlantilla1,'000000000','',vNumTarjeta,'1',vsString1,'','','','','','','','','',vscorreo,'',0,0,0,0,0,vdFechaHoy,vFechaInsertRec)
                                INTO 	cCodRet;
                                                        
                                IF  ( cCodRet <> '00000' )  THEN 
                                
                                    LET vsCodRet1 = '004';
                                    LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                                                            
                                    UPDATE  intercard:"informix".bitacoraenvios_tjts
                                    SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                                    WHERE secuencial = vsecuencial;
                                
                                END IF; ---( cCodRet <> '00000' )
                                                        
                                UPDATE intercard:"informix".bitacoraenvios_tjts
                                SET cod_ret = '000',estatus_envio = 'V',descripcion = 'Se envio Correo al titular.'
                                WHERE secuencial = vsecuencial;
                                                        
                            ELSE    --- De no hallar ningun medio de contacto genera bitacora de error.
                            
                                LET vsCodRet1 = '003';
                                LET vsMensaje = 'Titular no tiene registrado celular o correo electrÃ³nico.';
                                
                                UPDATE  intercard:"informix".bitacoraenvios_tjts
                                SET cod_ret = vsCodRet1, estatus_envio = 'E', descripcion = vsMensaje
                                WHERE secuencial = vsecuencial; 
                                                 
                            END IF; ----(vscorreo <> '' AND vscorreo is not null)
                                            
                        END IF; ---vsCodRet2 <> '000'
                    
                    END IF; ---(vstelefono <> '' AND vstelefono is not null)
                    
                END IF; --- vsCodRet1 <> '000'
         
            ELSE  
            
                LET vsCodRet1 = '001';  
                LET vsMensaje   = 'Cliente no se pudo identificar con tarjeta : '||vNumTarjeta||'';
                
                UPDATE intercard:"informix".bitacoraenvios_tjts
                SET cod_ret = vsCodRet1, estatus_envio = 'F', descripcion = vsMensaje
                WHERE secuencial = vsecuencial; 		         

            END IF; --- (vsnumcte <> '' AND vsnumcte is not null  )

        RETURN 	vsCodRet1,vsMensaje; 
       
    END; ---BEGIN

END PROCEDURE;