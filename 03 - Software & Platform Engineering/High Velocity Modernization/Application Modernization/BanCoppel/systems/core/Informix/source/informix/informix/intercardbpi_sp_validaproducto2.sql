CREATE PROCEDURE "informix".sp_validaproducto2(pNumProd CHAR(4), pNumTarjeta CHAR(16), pNumOpc CHAR(1),pClave CHAR(3),Tipot CHAR(1) )
   RETURNING CHAR(5), CHAR(6), CHAR(3), INTEGER;
      
   DEFINE cCodRet            CHAR(5);
   DEFINE iSqlErr            INTEGER;
   DEFINE cCodBin            CHAR(6);
   DEFINE cCodProd           CHAR(3);
   DEFINE cCodClaveTar       INTEGER;
   DEFINE cNumCta            CHAR(12);
   DEFINE cLimiteAut         money (14,2);
     
   LET cCodRet              = '00000';   
   LET cCodBin              = '000000';
   LET cCodProd             = '000';
   LET cCodClaveTar         = 0;
         
BEGIN
                   ON EXCEPTION SET iSqlErr
                      IF iSqlErr <> 0 THEN
                         LET cCodRet = iSqlErr;
                                                               
                             RETURN cCodRet, cCodBin, cCodProd, cCodClaveTar;
                         END IF;
                   END EXCEPTION;
                
                --SET DEBUG FILE TO "/tmp/combinacion/Sp_ValidaProducto.out";
                --TRACE ON;
                
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;

           SELECT codproductotarjeta,clave_tipotarjeta,bin  
           INTO cCodProd,cCodClaveTar,cCodBin 
           FROM intercard:tipotarjeta 
           WHERE clave = pClave 
           AND Tipo = Tipot; 
           --AND flagsolicitud = 1;

                         IF pNumProd = "6001" THEN
                                               
                            SELECT LIMIT 1 num_credito INTO cNumCta FROM bdicred: sd_tarjeta WHERE num_tarjeta = pNumTarjeta;
                            SELECT LIMIT 1 monto_otorgado INTO cLimiteAut FROM bdicred: sd_maesdos where num_credito = cNumCta;        
                               
                            --* La busqueda en la tabla intercard:"informix".segmentoproducto donde el tipo_producto sea igual a C y los limites que anteriormente tenia en el sp
                            SELECT LIMIT 1 TRIM(codproductotarjeta) INTO cCodProd
                            FROM intercard:"informix".segmentoproducto
                            WHERE tipo_producto = "C"
                            AND limite_max >= NVL(cLimiteAut,0) 
                            AND limite_min <= NVL(cLimiteAut,0);                                                                            
                          END IF;

              IF cCodBin IS NULL or cCodClaveTar IS NULL or cCodBin IS NULL THEN
                      LET  cCodRet = '00001';
              END IF;
              

               RETURN cCodRet, cCodBin, cCodProd,cCodClaveTar;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Scarlett Mendoza',
'FECHA: 17/10/2017',
'BD: Intercard',
'Objetivo: Se copia procedimiento para validar que en numero de producto de la cuenta exista en la base de datos intercard y sea correcto';

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