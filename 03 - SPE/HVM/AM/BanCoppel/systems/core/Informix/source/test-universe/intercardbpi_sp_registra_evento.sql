CREATE PROCEDURE "informix".sp_registra_evento(
                  pTipoRechazo     	VARCHAR(1), -- 'N'egocio/'C'entral
                  pIdvalidacionAuth VARCHAR(6), 
				  pNumTarjeta VARCHAR(16),
				  pNombreCliente CHAR(104),
				  pFechaHoraInAuth DATETIME YEAR TO FRACTION(5),
				  pProdind VARCHAR(2),
				  pEsNacional VARCHAR(1),
				  pMetodoCaptura VARCHAR(2),
				  pTipoTransaccionPosDigitada VARCHAR(2),
				  pInfReceptor VARCHAR(40),
				  pMonto DECIMAL(19,4),
				  pSecuencia VARCHAR(7),
				  pUsuario CHAR(10))

    RETURNING VARCHAR(5) as Cod_ret,VARCHAR(80) as Men_ret;

    ---VARIABLES PARA CAPTURAR ERRORES
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
    DEFINE vIdPlantilla1        VARCHAR(15); 
    DEFINE vIdPlantilla2        VARCHAR(15); 
    DEFINE vdFechaInsert        DATETIME YEAR TO FRACTION(5);
    DEFINE vdFechaHoy           DATETIME YEAR TO FRACTION(5);
    DEFINE vcount               INTEGER;
	DEFINE vi_valor1            INTEGER;
	DEFINE vd_valor2            DECIMAL(19,8);
	DEFINE vs_valor3            CHAR(50);
	DEFINE vi_limdiarios        INTEGER;
	DEFINE vi_limmensuales      INTEGER;
	DEFINE vi_contdiarios       INTEGER;
	DEFINE vi_contmensuales     INTEGER;
	DEFINE vs_bines				CHAR(6);
	DEFINE vi_contdiariotjtinactiva INTEGER;
    DEFINE vi_contmensualtjtinactiva INTEGER;
    DEFINE vi_contdiariotjtfondos INTEGER;
    DEFINE vi_contmensualtjtfondos INTEGER;
	DEFINE vs_numtarjeta         VARCHAR(16);
	DEFINE vs_nombre            VARCHAR(250);
	DEFINE vs_nombre_completo   LVARCHAR(400);
	DEFINE vd_hora   CHAR(8);
	DEFINE vNumeroCliente   VARCHAR(20);
	
	DEFINE vidvalidacionauth            VARCHAR(6);
	DEFINE vidproceso					VARCHAR(10);
	DEFINE vtiporechazo             	VARCHAR(1);
    DEFINE vtipoproducto            	CHAR(1);
    DEFINE vnotifica                	CHAR(1);
    DEFINE venvia_sms               	CHAR(1);
    DEFINE vplantilla_sms           	VARCHAR(10);
    DEFINE vcontenido_sms           	VARCHAR(160);
    DEFINE venvia_email             	CHAR(1);
    DEFINE vplantilla_email         	VARCHAR(10);
    DEFINE vcontenido_email         	CHAR(300);
    DEFINE vmotivo                  	VARCHAR(20);
    DEFINE vaplica_producto         	CHAR(1);
    DEFINE vaplica_prodind          	CHAR(1);
    DEFINE vaplica_transaccionorigen	CHAR(1);
    DEFINE vaplica_metodocaptura    	VARCHAR(20);
    DEFINE vlimdiarionotificacredito	INTEGER;
    DEFINE vlimensualnotificacredito	INTEGER;
    DEFINE vlimdiarionotificadebito 	INTEGER;
    DEFINE vlimmensualnotificadebito	INTEGER;
	
	DEFINE vcontmaxtrandiarias          INTEGER;
	DEFINE vcontmaxtranmens              INTEGER;

	DEFINE det_ProdInd CHAR(2);
    DEFINE det_ProdInd2 CHAR(2);
	DEFINE det_Origen CHAR(1);
	DEFINE det_Origen2 CHAR(1);
	DEFINE det_MetodoCaptura CHAR;
	DEFINE det_MetodoCaptura2 CHAR(20);

    BEGIN 

		--	SET DEBUG FILE TO "/informix/frg/autorizador/sp_registra_evento_13p.out";
		--	TRACE ON;

	
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
        LET vi_valor1          = 0;
        LET vd_valor2          = 0;
        LET vi_limdiarios      = 0;
        LET vi_limmensuales    = 0;
        LET vi_contdiarios     = 0;
        LET vi_contmensuales   = 0;
        LET vs_valor3          = '';
        LET vs_bines	       = '';
        LET vi_contdiariotjtinactiva = 0;
        LET vi_contmensualtjtinactiva = 0;
        LET vi_contdiariotjtfondos = 0;
        LET vi_contmensualtjtfondos = 0;
        LET vs_numtarjeta = '';
        LET vs_nombre = '';
        LET vs_nombre_completo = '';
        LET vd_hora = '';
        -- Los ceros indican un cliente generico para Latinia
        --Y debe tomar en cuenta el dato almacenado en el campo celular_alterno o correo_alterno
        LET vNumeroCliente = '000000000';

        LET vNumTarjeta = pNumTarjeta;
		
		LET vidvalidacionauth           = '';
		LET vidproceso					= '';
		LET vtiporechazo   				= '';
		LET vtipoproducto  				= 'N';
		LET vnotifica      				= '';
		LET venvia_sms     				= '';
		LET vPlantilla_sms 				= '';
		LET vcontenido_sms  			= '';
		LET venvia_email    			= '';
		LET vplantilla_email 			= '';
		LET vcontenido_email 			= '';
		LET vmotivo           			= '';
		LET vaplica_producto 			= '';
		LET vaplica_prodind  			= '';
		LET vaplica_transaccionorigen	= '';
		LET vaplica_metodocaptura    	= '';
		LET vlimdiarionotificacredito	= 0.0;
		LET vlimensualnotificacredito	= 0.0;
		LET vlimdiarionotificadebito 	= 0.0;
		LET vlimmensualnotificadebito	= 0.0;	
		
		LET vcontmaxtrandiarias         = 0;
	    LET vcontmaxtranmens             = 0;

		
		LET det_ProdInd = '';
		LET det_ProdInd2 = '';
		LET det_Origen = '';
		LET det_Origen2 = '';
		LET det_MetodoCaptura = '';
		LET det_MetodoCaptura2 = '';
		
        --Obtiene el producto de la tarjeta
        SET ISOLATION TO DIRTY READ;
        SELECT creditodebito INTO vs_bines
			FROM intercard:"informix".bines
            WHERE bin = SUBSTRING(vNumTarjeta FROM 1 FOR 6);

		SET ISOLATION TO DIRTY READ;
        SELECT idproceso, tiporechazo, tipoproducto, notifica, envia_sms, plantilla_sms, contenido_sms, envia_email, plantilla_email, contenido_email,
		       motivo, aplica_producto, aplica_prodind, aplica_transaccionorigen, aplica_metodocaptura, 
			   limdiarionotificacredito, limensualnotificacredito, limdiarionotificadebito, limmensualnotificadebito
		INTO vidproceso, vtiporechazo, vtipoproducto, vnotifica, venvia_sms, vplantilla_sms,vcontenido_sms, venvia_email, vplantilla_email, vcontenido_email,
		       vmotivo, vaplica_producto, vaplica_prodind, vaplica_transaccionorigen, vaplica_metodocaptura, 
			   vlimdiarionotificacredito, vlimensualnotificacredito, vlimdiarionotificadebito, vlimmensualnotificadebito
        FROM intercard:"informix".catparamnotificaciones
        WHERE idvalidacionauth = pIdvalidacionAuth and tiporechazo = pTipoRechazo
			AND (tipoproducto = vs_bines OR tipoproducto = vtipoproducto);						
		
        IF (vnotifica <> '') THEN --No hay coincidencia de registros
                
            LET vIdPlantilla1 = vplantilla_email; -- plantilla email
            LET valerta1      = vplantilla_email; -- alerta email
            LET vIdPlantilla2 = vplantilla_sms; -- plantilla sms
            LET valerta2      = vplantilla_sms; -- alerta sms               
        ELSE
                
            LET vsCodRet1 = '00005'; 
            LET vsMensaje = 'Se intento procesar con un ID indefinido o erroneo';
              
            INSERT INTO intercard:"informix".bitacoraenvios_tjts (id_proceso,tarjeta,fecha_insert,estatus_envio,cod_ret,descripcion)
            VALUES (vidproceso,vNumTarjeta,vdFechaInsert,'F',vsCodRet1,vsMensaje); 
                
            RETURN 	vsCodRet1,vsMensaje; 
            
        END IF;
        
		IF(vaplica_prodind = 'A') THEN   
			LET det_ProdInd = 'T'; --Ambos POS y ATM
		ELSE
			LET det_ProdInd = 'A'; --Solo uno		
		END IF;
		
		IF det_ProdInd = 'A' THEN
			IF vaplica_prodind = 'T' THEN  
				let det_ProdInd2 = '01'; --ATM
			ELSE
				let det_ProdInd2 = '02'; --POS
			END IF;
		END IF;	
		
		IF(vaplica_transaccionorigen = 'A') THEN	    
			LET det_Origen = 'T'; --Todos
			ELSE
			LET det_Origen = 'A'; --Solo uno
		END IF;
	 
		IF(det_Origen = 'A') THEN	    
			IF vaplica_transaccionorigen = 'N' THEN
				let det_Origen2 = 'V';
				ELSE
				let det_Origen2 = 'F';
			END IF;
		END IF;
		
		IF(length(vaplica_metodocaptura) < 2) THEN --Define los métodos de Captura que aplica
           IF(vaplica_metodocaptura = '') THEN	    
				LET det_MetodoCaptura = 'T'; --Todos
			ELSE
				LET det_MetodoCaptura = 'A'; --Solo uno
			END IF
		ELSE
		    LET det_MetodoCaptura2 = vaplica_metodocaptura;
		END IF;
							
		--Aqui voy
			--Verifica si está encendida la Notificacion(notifica)	y si aplica para todos los Criterios del mensaje		               
            IF(vnotifica = 'V' and (venvia_sms = 'V' OR venvia_email = 'V') and 
               (det_ProdInd = 'T' or det_ProdInd2 = pProdind) and -- Para todos los Canales o Solo ATM o POS
			   (det_Origen = 'T' or  det_Origen2 = pEsNacional) and --Para todos los Origenes o Solo Nacional o Internacional
			   (det_MetodoCaptura = 'T' or INSTR(vaplica_metodocaptura,pMetodoCaptura,1) > 0 )) THEN --Para todos los métodos de captura o Solo algunos de ellos               
            
                IF (vaplica_producto = vs_bines OR vaplica_producto = 'A') THEN --Verifica si aplica el mensaje para Debito, Credito o Ambos Productos (A)
                
                    --Verifica si la tarjeta ya llega al limite de mensajes diarios o mensuales, en su caso no envia mensaje.
                    SET ISOLATION TO DIRTY READ;
                    SELECT numtarjeta, tiporechazo, idvalidacionauth, contmaxtrandiarias, contmaxtranmens
                        INTO vs_numtarjeta, vtiporechazo, vidvalidacionauth, vcontmaxtrandiarias, vcontmaxtranmens
                    FROM intercard:"informix".tarjeta_rechazos
                    WHERE numtarjeta = vNumTarjeta and idvalidacionauth = pIdvalidacionAuth and tiporechazo = pTipoRechazo;
                
                    IF(vs_numtarjeta <> '' AND vs_numtarjeta is not null) THEN --Se encontro tarjeta en <<tarjeta_rechazos>>                             
                        
						IF (vs_bines = 'C') THEN
                            LET vi_limdiarios = vlimdiarionotificacredito;
                            LET vi_limmensuales = vlimensualnotificacredito;
						ELSE
						    LET vi_limdiarios = vlimdiarionotificadebito;
                            LET vi_limmensuales = vlimmensualnotificadebito;
						END IF;
                                     
                        IF (vcontmaxtrandiarias <= vi_limdiarios AND vcontmaxtranmens <= vi_limmensuales) THEN --Envia mensaje, si los contadores se supera no envia
            
                            INSERT INTO intercard:"informix".bitacoraenvios_tjts (id_proceso, tarjeta, fecha_insert, estatus_envio, tipo_envio, cod_ret, descripcion)
                                                            VALUES (vidproceso,vNumTarjeta,vdFechaInsert,'P','','','');  
     
                            SELECT FIRST 1 secuencial,fecha_insert  INTO  vsecuencial,vdFechaInsert FROM intercard:"informix".bitacoraenvios_tjts
                            where estatus_envio = 'P' AND fecha_insert = vdFechaInsert AND tarjeta = vNumTarjeta AND id_proceso= vidproceso;
          
                            SELECT {+INDEX(intercard:tarjeta 819_8158 } FIRST 1 numcliente  INTO  vsnumcte FROM  intercard:"informix".tarjeta  
                            WHERE   numtarjeta = vNumTarjeta;
             
                            --Obtener el nombre del cliente correspondiente a los mensajes de texto o correo electronico.
                            --Si es mensaje de texto se utiliza la variable vs_nombre
                            --Si es correo electronico se utiliza la variable vs_nombre_completo
                            SET ISOLATION TO DIRTY READ;
                            SELECT
                                CASE
                                    WHEN LENGTH (TRIM(nombre1)) < 3 THEN TRIM(nombre2)
                                    ELSE TRIM(nombre1)
                                END AS nombre,
                                TRIM(nombre1) ||' '|| TRIM(nombre2)  ||' '|| TRIM(apell_paterno) ||' '|| TRIM(apell_materno) AS nombre_completo
                            INTO vs_nombre, vs_nombre_completo
                            FROM bdinteg:"informix".si_cliente
                            WHERE numcte = vsnumcte;
                            
                            --Ultimos 4 digitos del numero de tarjeta
                            LET  vsString1  =  SUBSTR(vNumTarjeta,13,4);

                            IF ( vsnumcte <> '' AND vsnumcte is not null and venvia_sms = 'V') THEN  --- De encontrar usuarios le busca primero su contacto celular.
                            
                                EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_telefonos("001",vsnumcte,2,"0")
                                INTO vsCodRet1,vstelefono,vstipotel,vsSecuencia,vsStatustel,vsextension,vscarrier,vsnombrecarrier,vsStatusvalidacion;
               
                                IF (vsCodRet1 <> '000' and venvia_email = 'V') THEN
                
                                    EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos("001",vsnumcte,1,"0")
                                    INTO vsCodRet2,vscorreo,vstipocorreo,vsStatuscorreo;
                                  
                                    IF (vsCodRet2 <> '000') THEN
                                    
                                        LET vsCodRet1 = '00006';
                                        LET vsMensaje = 'Error al obtener telefono y correo del titular.';  
                                        UPDATE  intercard:"informix".bitacoraenvios_tjts
                                            SET cod_ret = vsCodRet1, estatus_envio = 'E', tipo_envio = NULL, descripcion = vsMensaje
                                        WHERE secuencial = vsecuencial;
     
                                    ELSE
                                    
                                        IF (vscorreo <> '' AND vscorreo is not null and venvia_email = 'V')  THEN  
                                                
                                            ---  INVOCAR  SP REGISTRA EVENTO (EMAIL)
                                            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('1',valerta1,vIdPlantilla1,vNumeroCliente,NULL,vNumTarjeta,'1', vsString1, SUBSTR(TRIM(pInfReceptor), 0,20),NULL,NULL, vs_nombre_completo,NULL,NULL,NULL,NULL,NULL,vscorreo,NULL,pMonto,0,0,0,0,vdFechaHoy,NULL)
                                            INTO 	cCodRet;
                                                    
                                            IF  ( cCodRet <> '00000' )  THEN 
                                                LET vsCodRet1 = '00004';
                                                LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                                                UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                    SET cod_ret = vsCodRet1,estatus_envio = 'E', tipo_envio = '2', descripcion = vsMensaje
                                                WHERE secuencial = vsecuencial; 
                                            END IF;  
                                                        
                                            UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                SET cod_ret = '000', estatus_envio = 'V', tipo_envio = '2', descripcion = 'Se envio Correo al titular.' 
                                            WHERE secuencial = vsecuencial; 
                                          
                                        ELSE    --- De no encontrar ningun medio de contacto genera bitacora de error. 
                                 
                                            LET vsCodRet1 = '00002';
                                            LET vsMensaje   = 'Titular no tiene registrado celular o correo electronico.';
                                            UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                SET cod_ret = vsCodRet1, estatus_envio = 'E', tipo_envio = NULL , descripcion = vsMensaje 
                                            WHERE secuencial = vsecuencial; 
                                                 
                                        END IF;
                                        
                                    END IF; -- CIERRE | IF (vsCodRet2 <> '000') THEN | Consulta de correos
                                    
                                ELSE -- IF (vsCodRet1 <> '000') THEN | | Consulta de telefonos
                                    
                                    IF (vstelefono <> '' AND vstelefono is not null and venvia_sms = 'V')  THEN   
                            
                                        ---  INVOCAR  SP REGISTRA EVENTO (SMS)
                                        
                                        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento  ('1',valerta2,vIdPlantilla2,vNumeroCliente,NULL,vNumTarjeta,'1', vsString1, SUBSTR(TRIM(pInfReceptor), 0,20),NULL,NULL, vs_nombre,NULL,NULL,NULL,NULL,NULL,NULL,vstelefono,pMonto,0,0,0,0,vdFechaHoy,NULL)
                                        INTO 	cCodRet;
                                
                                        IF  ( cCodRet <> '00000' )  THEN
                                            LET vsCodRet1 = '00004';
                                            LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                                            UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                SET cod_ret = vsCodRet1,estatus_envio = 'E', tipo_envio = '1', descripcion = vsMensaje
                                            WHERE secuencial = vsecuencial; 
                                        END IF; 
                                
                                        UPDATE  intercard:"informix".bitacoraenvios_tjts
                                            SET cod_ret = '000',estatus_envio = 'V', tipo_envio = '1', descripcion = 'Se envio SMS al titular.' 
                                        WHERE secuencial = vsecuencial;
                            
                                    ELSE    --- De no encontrar el telefono procede con la busqueda de algun correo electronico.

                                        
                                        EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos("001",vsnumcte,1,"0")
                                        INTO vsCodRet2,vscorreo,vstipocorreo,vsStatuscorreo; 
                                        
                                        IF (vsCodRet2 <> '000') THEN   -- Guarda bitacora en caso de generar un error en el proceso anterior. 
                                            LET vsCodRet1 = '00006';
                                            LET vsMensaje = 'Error al obtener el correo del titular.';
                                            UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                SET cod_ret = vsCodRet1, estatus_envio = 'E', tipo_envio = '2', descripcion = vsMensaje
                                            WHERE secuencial = vsecuencial; 
                                        
                                        ELSE 
         
                                            IF (vscorreo <> '' AND vscorreo is not null and venvia_email = 'V')  THEN  
                                            
                                            ---  INVOCAR  SP REGISTRA EVENTO (EMAIL)
                                                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('1',valerta1,vIdPlantilla1,vNumeroCliente,NULL,vNumTarjeta,'1', vsString1, SUBSTR(TRIM(pInfReceptor), 0,20),NULL,NULL, vs_nombre_completo,NULL,NULL,NULL,NULL,NULL,vscorreo,NULL,pMonto,0,0,0,0,vdFechaHoy,NULL)
                                                INTO 	cCodRet;
                                                        
                                                IF  ( cCodRet <> '00000' )  THEN 
                                                    LET vsCodRet1 = '004';
                                                    LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                                                    UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                        SET cod_ret = vsCodRet1,estatus_envio = 'E', tipo_envio = '2', descripcion = vsMensaje
                                                    WHERE secuencial = vsecuencial;
                                                END IF;
                                                
                                                UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                    SET cod_ret = '000', estatus_envio = 'V', tipo_envio = '2', descripcion = 'Se envio Correo al titular.' 
                                                WHERE secuencial = vsecuencial; 
                                                        
                                            ELSE    --- De no hallar ningun medio de contacto genera bitacora de error. 
                                                
                                                LET vsCodRet1 = '00003';
                                                LET vsMensaje = 'Titular no tiene registrado celular o correo electronico.';
                                                UPDATE  intercard:"informix".bitacoraenvios_tjts
                                                    SET cod_ret = vsCodRet1, estatus_envio = 'E', tipo_envio = NULL, descripcion = vsMensaje
                                                WHERE secuencial = vsecuencial; 
                                                 
                                            END IF;
                                        
                                        END IF;
                                        
                                    END IF;
                                    
                                END IF; -- CIERRE | IF (vsCodRet1 <> '000') THEN Codigo de retorno para consulta de telefonos.
         
                            ELSE
                            
                                LET vsCodRet1 = '00001';
                                LET vsMensaje   = 'Cliente no se pudo identificar con tarjeta : '||vNumTarjeta||'';
              
                                UPDATE intercard:"informix".bitacoraenvios_tjts SET cod_ret = vsCodRet1,estatus_envio = 'F',descripcion = vsMensaje
                                WHERE secuencial = vsecuencial;

                            END IF; -- CIERRE -> IF ( vsnumcte <> '' AND vsnumcte is not null ) THEN
                            
                        END IF; -- Sobre Limites Diarios y Mensuales
                        
                    END IF; --Sobre Indicadores de la Tarjeta
                    
                END IF; --Sobre Bines
                
            ELSE --No se envia ningun mensaje o no aplica para la plantilla
            
                LET vsCodRet1          = '00000';
                LET vsMensaje          = '';
                
            END IF; --Sobre Indicador de Envio o No de Mensajes para la Platilla
    ----------------------------------------------------------------------------------------------------------------------------------------------------
        RETURN 	vsCodRet1,vsMensaje; 
   
    END;
    
END PROCEDURE

DOCUMENT
'AUTOR : Luis Antonio Gomez',
'DESCRIPCION: SP para registro y envio de SMS/email al tarjetahabiente.',
'EJECUTADO O LLAMADO POR:',
'sp_registra_evento(VARCHAR(20), VARCHAR(16), CHAR(10), DATETIME, CHAR (40), MONEY, CHAR (6), CHAR (8))',
'FECHA : Septiembre/2017',
'VERSION: 20170912',
'BD    : intercard';

CREATE PROCEDURE "informix".sp_validaproducto1(pNumProd CHAR(4), pNumTarjeta CHAR(16), pNumOpc CHAR(1),pClave CHAR(3),Tipot CHAR(1), Clavetp CHAR(3) )
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
               WHERE codproductotarjeta = pClave 
               AND Tipo = Tipot
               AND clave = Clavetp;
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
'AUTOR: Irma Ureta Gaxiola',
'FECHA: 17/10/2016',
'BD: Intercard',
'Objetivo: Se crea procedimiento para validar que en número de producto de la cuenta exista en la base de datos intercard ';

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