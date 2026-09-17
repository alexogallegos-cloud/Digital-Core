CREATE PROCEDURE "informix".sp_registra_evento_pba1(pIdProceso VARCHAR(20),pNumTarjeta VARCHAR(16),pUsuario CHAR(10))

RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;

---VARIABLES PARA CAPTURAR ERRORES
DEFINE vNumTarjeta          Varchar(16);
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
DEFINE vsecuencial          integer; 
DEFINE valerta1             varchar(10);
DEFINE valerta2             varchar(10);
DEFINE vIdPlantilla1        varchar(15); 
DEFINE vIdPlantilla2        varchar(15); 
DEFINE vdFechaInsert        DATETIME YEAR TO FRACTION(5);
DEFINE vdFechaHoy           DATETIME YEAR TO FRACTION(5);
DEFINE vcount               integer;


BEGIN 
 
 ---INICIALIZAN VARIABLES PARA QUERYS
LET vsnumcte           = '';
LET vsCodRet1          = '00000';
LET vsCodRet2          = '00000';
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
LET cCodRet = '00000';
LET vsecuencial = 0; 
LET vdFechaInsert      =  sysdate;  
LET vdFechaHoy         =  sysdate;  
LET vcount             = 0; 
 
--set debug file to "/informix/HomeInformix/mgap/sp_registra_evento.out";
--trace on;	

LET vNumTarjeta = pNumTarjeta; 

        IF (pIdProceso = 'REC_SUC') THEN

            LET vIdPlantilla1 ='TJTPERMAIL';    -- plantilla email    
            LET valerta1      ='TJTPERMAIL';    -- alerta email 
            LET vIdPlantilla2 ='TJTPER_SMS';    -- plantilla sms    
            LET valerta2      ='TJTPER_SMS';    -- alerta sms   		         
        
        ELIF (pIdProceso = 'MSJ_NOTIF_SIA') THEN
            
            LET vIdPlantilla1 ='TJEMAILSIA'; 
            LET valerta1      ='TJEMAILSIA'; 
            LET vIdPlantilla2 ='TJTSMS_SIA';
            LET valerta2      ='TJTSMS_SIA'; 

        ELSE
            
            LET vsCodRet1 = '005'; 
            LET vsMensaje = 'Se intento procesar con un ID indefinido o erroneo';
            
            INSERT INTO intercard:"informix".bitacoraenvios_tjts (id_proceso,tarjeta,fecha_insert,estatus_envio,cod_ret,descripcion)
            VALUES (pIdProceso,vNumTarjeta,vdFechaInsert,'F',vsCodRet1,vsMensaje); 
            
            RETURN 	vsCodRet1,vsMensaje; 
        
        END IF;         
         
        INSERT INTO intercard:"informix".bitacoraenvios_tjts (id_proceso, tarjeta, fecha_insert, estatus_envio, tipo_envio, cod_ret, descripcion)
													  VALUES (pIdProceso,vNumTarjeta,vdFechaInsert,'P','','','');  
 
        SELECT FIRST 1 secuencial,fecha_insert  INTO  vsecuencial,vdFechaInsert   FROM intercard:"informix".bitacoraenvios_tjts  
		where estatus_envio = 'P' AND fecha_insert = vdFechaInsert AND tarjeta = vNumTarjeta AND id_proceso= pIdProceso;
      
		SELECT {+INDEX(intercard:tarjeta 819_8158 } FIRST 1 numcliente  INTO  vsnumcte FROM  intercard:"informix".tarjeta  
		WHERE   numtarjeta = vNumTarjeta;
		 
	    IF (vsnumcte <> '' AND vsnumcte is not null  ) THEN  --- De encontrar usuarios le busca primero su contacto celular.

	       EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_telefonos("001",vsnumcte,2,"0") 
		   INTO vsCodRet1,vstelefono,vstipotel,vsSecuencia,vsStatustel,vsextension,vscarrier,vsnombrecarrier,vsStatusvalidacion;
		   
	        IF vsCodRet1 <> '000' THEN   
			
	                          EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos("001",vsnumcte,1,"0")
				              INTO vsCodRet2,vscorreo,vstipocorreo,vsStatuscorreo;         
							  
	                            IF vsCodRet2 <> '000' THEN  
					                LET vsCodRet1 = '006';
									LET vsMensaje = 'Error al obtener telefono y correo del titular.';  
									UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                                    WHERE secuencial = vsecuencial; 
 
								 ELSE 
	 
	                                        IF (vscorreo <> '' AND vscorreo is not null)  THEN  
											
											    ---  INVOCAR  SP REGISTRA EVENTO (EMAIL)
                                                LET  vsString1  =  SUBSTR(vNumTarjeta,13,4); 
                                                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento  ('1',valerta1,vIdPlantilla1,'000000000','',vNumTarjeta,'1',vsString1,'','','','','','','','','',vscorreo,'',0,0,0,0,0,vdFechaHoy,'')
                                                INTO 	cCodRet;
												
												    IF  ( cCodRet <> '00000' )  THEN 
                                                        LET vsCodRet1 = '004';
														LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                                                        UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                                                        WHERE secuencial = vsecuencial; 
	                                                END IF;  
													
												UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = '000',estatus_envio = 'V',descripcion = 'Se envio Correo al titular.' 
                                                WHERE secuencial = vsecuencial; 
									  
									         ELSE    --- De no encontrar ningun medio de contacto genera bitacora de error. 
											 
	                                          LET vsCodRet1 = '002';
                                              LET vsMensaje   = 'Titular no tiene registrado celular o correo electronico.';
											  UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1, estatus_envio = 'E', descripcion = vsMensaje 
                                              WHERE secuencial = vsecuencial; 
                                             
	                                        END IF;
							    END IF;	
	                            ------------------
	 
	         ELSE 
				    IF (vstelefono <> '' AND vstelefono is not null)  THEN   
					    
						---  INVOCAR  SP REGISTRA EVENTO (SMS) 
						    LET  vsString1  =  SUBSTR(vNumTarjeta,13,4); 
				            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento  ('1',valerta2,vIdPlantilla2,'000000000','',vNumTarjeta,'1',vsString1,'','','','','','','','','','',vstelefono,0,0,0,0,0,vdFechaHoy,'')
                            INTO 	cCodRet;
							
								    IF  ( cCodRet <> '00000' )  THEN 
                                        LET vsCodRet1 = '004';
										LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                                        UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                                        WHERE secuencial = vsecuencial; 
	                                END IF; 
							
							UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = '000',estatus_envio = 'V',descripcion = 'Se envio SMS al titular.' 
                            WHERE secuencial = vsecuencial;
						
	                  ELSE    --- De no encontrar el telefono procede con la busqueda de algun correo electronico. 
									
					        EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos("001",vsnumcte,1,"0")
				            INTO vsCodRet2,vscorreo,vstipocorreo,vsStatuscorreo; 
									
							    IF vsCodRet2 <> '000' THEN   -- Guarda bitacora en caso de generar un error en el proceso anterior. 
					                LET vsCodRet1 = '006';
									LET vsMensaje = 'Error al obtener telefono y correo del titular.';
									UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                                    WHERE secuencial = vsecuencial; 
									
							     ELSE 
	 
	                                        IF (vscorreo <> '' AND vscorreo is not null)  THEN  
											  	---  INVOCAR  SP REGISTRA EVENTO (EMAIL) 
												    LET  vsString1  =  SUBSTR(vNumTarjeta,13,4); 
									                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento  ('1',valerta1,vIdPlantilla1,'000000000','',vNumTarjeta,'1',vsString1,'','','','','','','','','',vscorreo,'',0,0,0,0,0,vdFechaHoy,'')
                                                    INTO 	cCodRet;
													
                                                    IF  ( cCodRet <> '00000' )  THEN 
                                                        LET vsCodRet1 = '004';
														LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                                                        UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                                                        WHERE secuencial = vsecuencial; 
	                                                END IF; 
													
													UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = '000',estatus_envio = 'V',descripcion = 'Se envio Correo al titular.' 
                                                    WHERE secuencial = vsecuencial; 
													
									         ELSE    --- De no hallar ningun medio de contacto genera bitacora de error. 
	                                          LET vsCodRet1 = '003';
											  LET vsMensaje = 'Titular no tiene registrado celular o correo electronico.';
											  UPDATE  intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'E',descripcion = vsMensaje
                                              WHERE secuencial = vsecuencial; 
                                             
	                                        END IF;
										
							    END IF;	
					END IF;		
			END IF; 	  
	 
	      ELSE  
              LET vsCodRet1 = '001';  
              LET vsMensaje   = 'Cliente no se pudo identificar con tarjeta : '||vNumTarjeta||'';
		  
          UPDATE intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'F',descripcion = vsMensaje
          WHERE secuencial = vsecuencial; 		         

	      END IF;   				 
	 
----------------------------------------------------------------------------------------------------------------------------------------------------
RETURN 	vsCodRet1,vsMensaje; 
   
END;
END PROCEDURE;