CREATE PROCEDURE "informix".sp_registra_evento_pba2(
                  pIdProceso VARCHAR(20),
				  pNumTarjeta VARCHAR(16),
				  pNombreCliente CHAR(104),
				  pFechaHoraInAuth DATETIME YEAR TO FRACTION(5),
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
        
            IF (pIdProceso = 'MSJ_ICPANP') THEN
                
                    LET vIdPlantilla1 ='1CPANPMAIL'; -- plantilla email
                    LET valerta1      ='1CPANPMAIL'; -- alerta email
                    LET vIdPlantilla2 ='1CPANP_SMS'; -- plantilla sms
                    LET valerta2      ='1CPANP_SMS'; -- alerta sms                                
            ELSE
                
                LET vsCodRet1 = '00005'; 
                LET vsMensaje = 'Se intento procesar con un ID indefinido o erroneo';
                
                INSERT INTO intercard:"informix".bitacoraenvios_tjts (id_proceso,tarjeta,fecha_insert,estatus_envio,cod_ret,descripcion)
                VALUES (pIdProceso,vNumTarjeta,vdFechaInsert,'F',vsCodRet1,vsMensaje); 
                
                RETURN 	vsCodRet1,vsMensaje; 
            
            END IF;
            
            /*--Determina si el mensaje viene del Autorizador para reglas de negocio de Tarjeta
            IF(pIdProceso = 'MSJ_ICPANP') THEN*/
            --Verifica en la tabla de bditarjeta:td_parametro  si el parametro esta encendido para el envio del mensaje
            SET ISOLATION TO DIRTY READ;
            SELECT valor1, valor2, valor3 INTO vi_valor1, vd_valor2, vs_valor3
            FROM bditarjeta:"informix".td_parametro
            WHERE clave = pIdProceso;
                
            IF(vi_valor1 = 1) THEN --Bandera Encendida para Enviar Mensaje
                 
                --Obtiene el producto de la tarjeta
                SET ISOLATION TO DIRTY READ;
                SELECT creditodebito INTO vs_bines
                FROM intercard:"informix".bines
                WHERE bin = SUBSTRING(vNumTarjeta FROM 1 FOR 6);
            
                IF (vs_valor3 = vs_bines OR vs_valor3 = 'A') THEN --Verifica si aplica el mensaje para Debito, Credito o Ambos Productos (A)
                
                    --Verifica si la tarjeta ya llega al limite de mensajes diarios o mensuales, en su caso no envia mensaje.
                    SET ISOLATION TO DIRTY READ;
                    SELECT numtarjeta
					--	, contdiariotjtinactiva, contmensualtjtinactiva, contdiariotjtfondos, contmensualtjtfondos
                        INTO vs_numtarjeta
					--	, vi_contdiariotjtinactiva, vi_contmensualtjtinactiva, vi_contdiariotjtfondos, vi_contmensualtjtfondos
                    FROM intercard:"informix".tarjeta_indicadores
                    WHERE numtarjeta = vNumTarjeta;
                
                    IF(vs_numtarjeta <> '' AND vs_numtarjeta is not null) THEN --Se encontro tarjeta en Indicadores
                
                        --El valor almacenado en el campo valor2 tiene dos digitos. Por ejemplo: 11, 13, 19
                        --y usando la funcion trunc con operaciones aritmeticas
                        --se extraen el primer y segundo digito indicando siÂ­ cumple con las condiciones de enviar mensajes.
                        LET vi_contdiarios = trunc(vd_valor2/10, 0);
                        LET vi_contmensuales = vd_valor2 - (vi_contdiarios * 10);
                
                        LET vi_limdiarios = 1; --No lo requiere ya que lo controla el autorizador desde que invoca el SP
                        LET vi_limmensuales = 1; --No lo requiere ya que lo controla el autorizador desde que invoca el SP                                         
                        
                        IF (vi_limdiarios <= vi_contdiarios AND vi_limmensuales <= vi_contmensuales) THEN --Envia mensaje, si los contadores se supera no envia
            
                            INSERT INTO intercard:"informix".bitacoraenvios_tjts (id_proceso, tarjeta, fecha_insert, estatus_envio, tipo_envio, cod_ret, descripcion)
                                                            VALUES (pIdProceso,vNumTarjeta,vdFechaInsert,'P','','','');  
     
                            SELECT FIRST 1 secuencial,fecha_insert  INTO  vsecuencial,vdFechaInsert FROM intercard:"informix".bitacoraenvios_tjts
                            where estatus_envio = 'P' AND fecha_insert = vdFechaInsert AND tarjeta = vNumTarjeta AND id_proceso= pIdProceso;
          
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

                            IF ( vsnumcte <> '' AND vsnumcte is not null ) THEN  --- De encontrar usuarios le busca primero su contacto celular.
                            
                                EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_telefonos("001",vsnumcte,2,"0")
                                INTO vsCodRet1,vstelefono,vstipotel,vsSecuencia,vsStatustel,vsextension,vscarrier,vsnombrecarrier,vsStatusvalidacion;
               
                                IF (vsCodRet1 <> '000') THEN
                
                                    EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos("001",vsnumcte,1,"0")
                                    INTO vsCodRet2,vscorreo,vstipocorreo,vsStatuscorreo;
                                  
                                    IF (vsCodRet2 <> '000') THEN
                                    
                                        LET vsCodRet1 = '00006';
                                        LET vsMensaje = 'Error al obtener telefono y correo del titular.';  
                                        UPDATE  intercard:"informix".bitacoraenvios_tjts
                                            SET cod_ret = vsCodRet1, estatus_envio = 'E', tipo_envio = NULL, descripcion = vsMensaje
                                        WHERE secuencial = vsecuencial;
     
                                    ELSE
                                    
                                        IF (vscorreo <> '' AND vscorreo is not null)  THEN  
                                                
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
                                    
                                    IF (vstelefono <> '' AND vstelefono is not null)  THEN   
                            
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
         
                                            IF (vscorreo <> '' AND vscorreo is not null)  THEN  
                                            
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

CREATE PROCEDURE "informix".sp_registra_evento_pba3(
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

CREATE PROCEDURE "informix".sp_ctes_tdd_no_presente( pNumeroMeses VARCHAR(2), pNumMesAnteriorSdo INTEGER )
    
    RETURNING VARCHAR(6) as CODIGO_RETORNO, VARCHAR(80) as MENSAJE_RETORNO, 
        DATE as vFechaInicio, DATE as vFechaFinal;

    DEFINE CODIGO_RETORNO VARCHAR(6);
    DEFINE MENSAJE_RETORNO VARCHAR(80);
    DEFINE RUTA_DESTINO VARCHAR(80);
    DEFINE TIPO_PLANTILLA VARCHAR(15);
    DEFINE ID_PLANTILLA CHAR(1);
    DEFINE OCTUBRE CHAR(2);
    
    DEFINE vsql CHAR(1150);
    DEFINE vFechaInicio DATE;
    DEFINE vFechaFinal DATE;
    DEFINE vSaldoPromedio INTEGER;
    DEFINE vNumeroMeses VARCHAR(2);
    DEFINE vTotalRegistros INTEGER;
    DEFINE vNumInicioRegistros INTEGER;
    DEFINE vContadorArchivos VARCHAR(4);
    DEFINE vTotalInterna INTEGER;
    DEFINE vRegistrosMaxPorArchivo INTEGER;
    DEFINE vNumMesAnteriorSdo INTEGER; --Numero de meses anterior al mes actual (saldo promedio)
    DEFINE vAnyoMes CHAR(6);
    DEFINE vPrimerMesTrimestral CHAR(2);
    DEFINE vCamposFechaIntegral CHAR(20);
    DEFINE vPrimerDiaMes DATE;
BEGIN
    -- Los valores de las plantillas:  Valor 1 esta relacionado con la plantilla -> TP_CAPTA
    -- Valor 1 con la plantilla -> TP_CAPTA | Valor 2 con la plantilla -> TNP_CAPTA | Valor 3 con la plantilla -> TAG_CAPTA
    ---Valor 4 con la plantilla -> ATM_CAPTA | Valor 5 con la plantilla -> VENT_CAPTA
    ---Variables sin cambio de asignacion.
    LET CODIGO_RETORNO  = '00000';
    LET MENSAJE_RETORNO = 'PROCESO EXITOSO';
    LET RUTA_DESTINO = '/resplogifx/';
    LET TIPO_PLANTILLA = 'TNP_CAPTA';
    LET ID_PLANTILLA = '2';
    LET OCTUBRE = '10';
    
    --SET DEBUG FILE TO RUTA_DESTINO||"sp_ctes_tdd_no_presente.out";
    --TRACE ON;
    
    --Variables empleadas en las consultas a la base de datos.
    LET vFechaInicio = '';
    LET vFechaFinal = ''; 
    LET vSaldoPromedio = 0;
    
    --Variables utilizadas en la creacion de los archivos.
    LET vContadorArchivos = '1';
    LET vNumeroMeses = pNumeroMeses;
    LET vNumInicioRegistros = 0;
    LET vRegistrosMaxPorArchivo = 1;
    LET vTotalRegistros = 0;    
    LET vTotalInterna = 0;
    LET vNumMesAnteriorSdo = pNumMesAnteriorSdo;
    LET vAnyoMes = '';
    LET vPrimerMesTrimestral = '';
    LET vCamposFechaIntegral = '';
    LET vPrimerDiaMes = '';
    
    -->Paso 00. Obtener el RANGO DE FECHAS
    SET ISOLATION TO dirty READ;
    SELECT {+INDEX(bdinteg:si_fechas idx_si_fechas)}
        MONTH(EXTEND(pri_dia_mes) - vNumeroMeses units month), pri_dia_mes
        INTO vPrimerMesTrimestral, vPrimerDiaMes
    FROM bdinteg:si_fechas
        WHERE empresa = '001';
    
    --Campos empleados para la ejecucion del reporte trimestral: abril, julio y octubre.
    LET vCamposFechaIntegral = YEAR(today)||LPAD(MONTH(EXTEND(vPrimerDiaMes) - vNumMesAnteriorSdo units month), 2, "0");

    IF ( vPrimerMesTrimestral = OCTUBRE ) THEN
        --Campos empleados para la ejecucion del reporte trimestral: enero | Cambio de anio.
        LET vCamposFechaIntegral = YEAR(today) - 1||LPAD(MONTH(EXTEND(vPrimerDiaMes) - vNumMesAnteriorSdo units month), 2, "0");
    END IF;
        
    SET ISOLATION TO dirty READ;
    SELECT {+INDEX(bdinteg:si_fechas idx_si_fechas)}
        EXTEND(pri_dia_mes) - vNumeroMeses units month,
        EXTEND(pri_dia_mes),
        vCamposFechaIntegral
        INTO vFechaInicio, vFechaFinal, vAnyoMes
    FROM bdinteg:si_fechas
        WHERE empresa = '001';

    --Paso 00. Obtener el SALDO PROMEDIO. Variable por utilizar en el Paso 3.
    -- vSaldoPromedio Valor inicial del requerimiento 200 (29.junio)
    SET ISOLATION TO dirty READ;
    SELECT valor1 
        INTO vSaldoPromedio 
    FROM bditarjeta:td_parametro
        WHERE clave = 'SDO_TDD_NOPRESENTE';
    
    --Paso 00. Obtener el NUMERO MAXIMO DE REGISTROS POR ARCHIVO. 
    -- Variable por utilizar en el Paso 6.
    -- vRegistrosMaxPorArchivo Valor inicial del requerimiento 200 (29.junio)
    SET ISOLATION TO dirty READ;
    SELECT valor1
        INTO vRegistrosMaxPorArchivo 
    FROM bditarjeta:td_parametro
        WHERE clave = 'REGMAX_POR_ARCH';

    DROP TABLE IF EXISTS tmp_bines_debito;
    DROP TABLE IF EXISTS tmp_info_clientes;
    DROP TABLE IF EXISTS tmp_clientes_promedio;
    DROP TABLE IF EXISTS tmp_clientes_maestra;
    DROP TABLE IF EXISTS tmp_movimientos_actuales;
    DROP TABLE IF EXISTS tmp_movimientos_trimestrales;
    DROP TABLE IF EXISTS tmp_movimientos_historicos;

    --Es necesario implementar la directiva para considerar los indices creados en la tabla especificada.
    --    {+AVOID_FULL (movimientohistorico)} | "No full-table scan on the listed table".
    SET ISOLATION TO dirty READ;
    SELECT
        {+AVOID_FULL (bines)}
        {+INDEX(bines idx_bines)}
        bin 
    FROM bines
    WHERE creditodebito = 'D'
    INTO TEMP tmp_bines_debito;
    
    --Paso 1. 
    --  Construccion de tabla temporal de movimientos historicos
    --  Construccion de tabla temporal de movimientos actuales
    --  Union de todos los registros coincidentes de movimientos y tarjetas
    
    SET ISOLATION TO DIRTY READ; 
    SELECT {+AVOID_FULL (movimientohistorico)}
    {+INDEX(movimientohistorico idx_movimiento3)}
    {+INDEX(movimientohistorico idx_movimiento4)}
    {+INDEX(tarjeta idx_tarjeta1)}

    DISTINCT t.numcliente, t.numtarjeta
    FROM movimientohistorico movh, tarjeta t
        WHERE movh.fechahorainauth BETWEEN vFechaInicio AND vFechaFinal
        AND movh.numtarjeta = t.numtarjeta
        AND tipotransaccionposdigitada <> 'TG' --Deben excluirse las transacciones con TAG
        AND SUBSTR (movh.numtarjeta,0,6) IN 
            (
                SELECT bin
                FROM tmp_bines_debito
            )
        AND t.codstatustarjeta = 'ACT'
        AND t.titular IN ('T', 'A')
        AND codigoiso = '00'
        AND prodind = '02'
        AND metodocaptura IN ('01','81')
        ---Excluir los clientes que ya estan registrados en el archivo tarjeta presente
        AND t.numcliente NOT IN 
            (
                SELECT
                {+AVOID_FULL (info_reporte_trimestral)}
                {+INDEX(info_reporte_trimestral idx_info_reporte_trimestral)}
                    cliente 
                FROM info_reporte_trimestral 
                WHERE plantilla IN ('1')
            )        
    INTO TEMP tmp_movimientos_historicos WITH NO LOG;
    

    --Movimientos actuales
    SET ISOLATION TO DIRTY READ; 
    SELECT {+AVOID_FULL (movimiento)}
    {+INDEX(movimiento idx_movimiento3a)}
    {+INDEX(movimiento idx_movimiento4a)}
    {+INDEX(tarjeta idx_tarjeta1)}

    DISTINCT t.numcliente, t.numtarjeta
    FROM movimiento mov, tarjeta t
    WHERE mov.numtarjeta = t.numtarjeta
        AND fechahorainauth BETWEEN vFechaInicio AND vFechaFinal
        AND tipotransaccionposdigitada <> 'TG' --Deben excluirse las transacciones con TAG
        AND SUBSTR (mov.numtarjeta,0,6) IN 
            (
                SELECT bin
                FROM tmp_bines_debito
            )
        AND t.codstatustarjeta = 'ACT'
        AND t.titular IN ('T', 'A')
        AND codigoiso = '00'
        AND prodind = '02'
        AND metodocaptura IN ('01','81')
        ---Excluir los clientes que ya estan registrados en el archivo tarjeta presente
        AND t.numcliente NOT IN 
            (
                SELECT
                {+AVOID_FULL (info_reporte_trimestral)}
                {+INDEX(info_reporte_trimestral idx_info_reporte_trimestral)}
                    cliente 
                FROM info_reporte_trimestral 
                WHERE plantilla IN ('1')
            )        
    INTO TEMP tmp_movimientos_actuales WITH NO LOG;
    
    
    --Union de registros de movimientos.
    SELECT DISTINCT numcliente
    FROM tmp_movimientos_historicos
        UNION ALL
    SELECT DISTINCT numcliente
    FROM tmp_movimientos_actuales 
    WHERE numcliente NOT IN (SELECT DISTINCT numcliente FROM tmp_movimientos_historicos)
        INTO TEMP tmp_movimientos_trimestrales WITH NO LOG;
    
    --Obtencion de cuentas activas y unicamente relacionadas con tarjetas de los clientes previamente seleccionados
    SET ISOLATION TO DIRTY READ;
    SELECT 
        {+AVOID_FULL (bdicheq:sc_maechq)}
        {+INDEX(sc_maechq maecheques)}
    DISTINCT cuenta 
    FROM intercard:tarjetacuenta tarcta
        INNER JOIN bdicheq:sc_maechq mcheq
    ON (mcheq.cuenta = tarcta.numcuenta)
    WHERE mcheq.status_cta = 1
        AND mcheq.num_cte IN (SELECT numcliente FROM tmp_movimientos_trimestrales)
    INTO TEMP tmp_clientes_maestra WITH NO LOG;
    
    
    /*
    Paso 3. TDD Presente
    Obtener a los clientes con un promedio mensual anterior MAYOR A 200
    Considerar que debe evitarse dividir entre dias cero (0) [ AND diacum > 0 ]
    Script lines: 1-3 -- An attempt was made to divide by zero
    */   
    SET ISOLATION TO DIRTY READ;
    SELECT 
        {+AVOID_FULL (bdicheq:sc_sdodiarioc)}
        {+INDEX(sc_sdodiarioc isdodiario)}
    cuenta,
    CASE
        WHEN CAST((capvigacum/diacum) AS DECIMAL(10,0)) > vSaldoPromedio THEN 'S'
        ELSE 'N'
    END AS cte_promedio
    FROM bdicheq:sc_sdodiarioc 
        WHERE aniomes = vAnyoMes
        AND diacum > 0
        AND cuenta IN (SELECT cuenta FROM tmp_clientes_maestra) 
    INTO TEMP tmp_clientes_promedio WITH NO LOG;
    
    
    /*
    Paso 4. TDD Presente
    Los clientes tienen una cuenta activa y un correo valido (validacion por dominio (bdinteg)
    --indice para optimizar la busqueda en maech utilizando los campos: num_cte, status_cta
    */
    SET ISOLATION TO DIRTY READ;
    SELECT 
        {+AVOID_FULL (bdinteg:si_correos)}
        {+INDEX(si_correos idx_corr_cte_cons)}
    DISTINCT
        mcheq.num_cte cliente,
        sicte.nombre1 nombre1, sicte.nombre2 nombre2,
        sicor.correo_elec correo_electronico
    FROM bdicheq:sc_maechq mcheq, bdinteg:si_cliente sicte, bdinteg:si_correos sicor
    WHERE mcheq.num_cte = sicte.numcte
        AND mcheq.num_cte = sicor.numcte
        AND sicor.tipo_correo = '1'
        AND sicor.status_correo = 'A'
        AND sicor.valido = '1'
        AND sicor.valida_correo = '200'
        AND mcheq.status_cta = 1
        --Instruccion para obtener unicamente cuentas de clientes con saldo promedio 
        --SELECT cuenta FROM tmp_clientes_promedio WHERE cte_promedio = 'S'
        AND mcheq.cuenta IN (SELECT cuenta FROM tmp_clientes_promedio WHERE cte_promedio = 'S')
    INTO TEMP tmp_info_clientes WITH NO LOG;

    /*
    Paso 6.
        Tratamiento de los datos para crear el disenio solicitado en la plantilla de 
        clientes con compras utilizando tarjeta presente.
        Por requerimiento si el nombre1 es menor a dos caracteres se debe imprimir el nombre2
        en el archivo generado.
    */
    --NOTA: Se utilizan los asteriscos para despues ser sustituidos por pipes ( sed -e 's/\*/|/g' )
    --en el momento que se genera el archivo mediante el comando sed, asi evitando
    --que en el archivo se impriman diagonales invertidas con pipes \|\|
    SET ISOLATION TO DIRTY READ;    
    INSERT INTO info_reporte_trimestral (plantilla, cliente, correo_electronico, titular)
    
    SELECT ID_PLANTILLA, cliente,
        LOWER(TRIM(correo_electronico)) correo_electronico,
        CASE
            WHEN LENGTH (nombre1) < 3 THEN '****'||TIPO_PLANTILLA||'*'||'nombre='||TRIM(nombre2)
            ELSE '****'||TIPO_PLANTILLA||'*'||'nombre='||TRIM(nombre1) 
        END AS titular
    FROM tmp_info_clientes;
    
    
    /*
    Paso 7. Conteo de registros y recorrido para crear los 'n' archivos correspondientes.
    */
    SET ISOLATION TO DIRTY READ;
    SELECT COUNT(*) conteo_total INTO vTotalRegistros FROM info_reporte_trimestral WHERE plantilla = ID_PLANTILLA;
    
        -- Sin registros en la tabla temporal tmp_info_clientes.
        -- Por requerimiento se debe generar el archivo indicando 
        -- en el total de registros con el valor cero (0)
        IF (vTotalRegistros = 0) THEN
            LET vsql = '';
            LET vsql = 'echo "BANCOPPEL|productos||mail1|'||TIPO_PLANTILLA||'|'||vTotalRegistros||'"> '||RUTA_DESTINO||TIPO_PLANTILLA||'_00.ready';
            SYSTEM vsql;
            
            LET vsql = '';
            LET vsql = 'echo "UNLOAD TO "'||RUTA_DESTINO||TIPO_PLANTILLA||'"_00.unl SELECT * FROM info_reporte_trimestral WHERE plantilla = "'||ID_PLANTILLA||'";" > '||RUTA_DESTINO||'tdd_no_presente_capta.sql';
            SYSTEM vsql;
            
            LET vsql ='';
            LET vsql= 'dbaccess intercard '||RUTA_DESTINO||'tdd_no_presente_capta.sql';
            SYSTEM vsql;
            
            LET vsql = '';
            LET vsql ='rm '||RUTA_DESTINO||'tdd_no_presente_capta.sql';
            SYSTEM vsql;
        
            LET vsql ='';
            LET vsql = "sed 's/|s//g' "||RUTA_DESTINO||TIPO_PLANTILLA||"_00.unl >> "||RUTA_DESTINO||TIPO_PLANTILLA||"_00.ready";
            SYSTEM vsql;
            
            --Linea indispensable <EOF> que debe agregarse en los archivos para ser usados por Latinia.
            LET vsql ='';
            LET vsql ='echo "<EOF>" >> '||RUTA_DESTINO||TIPO_PLANTILLA||"_00.ready";
            SYSTEM vsql;
            
            LET vsql ='rm '||RUTA_DESTINO||TIPO_PLANTILLA||'_00.unl';
            SYSTEM vsql;
            
            DROP TABLE IF EXISTS tmp_info_clientes;
            DROP TABLE IF EXISTS tmp_clientes_promedio;
            DROP TABLE IF EXISTS tmp_clientes_maestra;
            DROP TABLE IF EXISTS tmp_movimientos_actuales;
            DROP TABLE IF EXISTS tmp_movimientos_trimestrales;
            DROP TABLE IF EXISTS tmp_movimientos_historicos;
            DROP TABLE IF EXISTS tmp_bines_debito;
            ----------------------------------------------------------------------------------------------------------------------------------------------------
            RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO, vFechaInicio, vFechaFinal;
        END IF;
        
        --La consulta tiene mas de un registro | Creacion de los 'n' archivos resultantes
        IF (vTotalRegistros >  0) THEN            
           
            WHILE (vTotalRegistros > 0 ) LOOP
                
                --Registros Base almacenado en la base de datos:bditarjeta / tabla:td_parametro / clave: REGMAX_POR_ARCH
                --La variable vRegistrosMaxPorArchivo = 20,000 | Requerimiento inicial 03 Julio
                
                LET vTotalInterna = vTotalRegistros - vRegistrosMaxPorArchivo;
                
                --Validacion interna vTotalInterna 
                --para restar los registros previamente almacenados en el archivo.
                --Cuando la previa operacion aritmetica tenga como resultado un cero o valor negativo
                --indicara que son los primeros o ultimos registros iterados para generar el archivo.
                IF (vTotalInterna <= 0) THEN
                    LET vTotalInterna = vTotalRegistros;
                ELIF (vTotalInterna > 0) THEN
                    LET vTotalInterna = vRegistrosMaxPorArchivo;
                END IF;
                
                IF (vContadorArchivos <= 99) THEN
                    LET vContadorArchivos = LPAD(vContadorArchivos, "2", 0);
                ELSE
                    LET vContadorArchivos = LPAD(vContadorArchivos, "3", 0);
                END IF;
                
                
                --La variable vTotalInterna se utiliza para indicar el total de registros almacenados por archivo.
                LET vsql = '';
                LET vsql = 'echo "BANCOPPEL|productos||mail1|'||TIPO_PLANTILLA||'|'||vTotalInterna||'"> "'||RUTA_DESTINO||TIPO_PLANTILLA||'"_'||vContadorArchivos||'.ready';
                SYSTEM vsql;
                
                --Consulta utilizada para ir paginando los registros en cada archivo iniciando
                --del registro 0 hasta la base de la variable vRegistrosMaxPorArchivo en cada ciclo.
                ---SELECT SKIP '||vNumInicioRegistros||' FIRST  vRegistrosMaxPorArchivo                
                
                LET vsql = '';
                LET vsql = 'echo "UNLOAD TO "'||RUTA_DESTINO||TIPO_PLANTILLA||'"_'||vContadorArchivos||'.unl SELECT SKIP '||vNumInicioRegistros||' FIRST '||vRegistrosMaxPorArchivo||' correo_electronico, titular FROM info_reporte_trimestral WHERE plantilla = "'||ID_PLANTILLA||'";" > '||RUTA_DESTINO||'tdd_no_presente_capta.sql';
                SYSTEM vsql;        
                
                LET vsql ='';
                LET vsql= 'dbaccess intercard '||RUTA_DESTINO||'tdd_no_presente_capta.sql';
                SYSTEM vsql;
                
                LET vsql = '';
                LET vsql ='rm '||RUTA_DESTINO||'tdd_no_presente_capta.sql';
                SYSTEM vsql;
            
                --Sustitucion del numero de asteriscos por pipes y eliminacion del ultimo pipe de cada registro.
                LET vsql ='';
                LET vsql = "sed -e 's/\*/|/g' -e 's/[|]*$//' "||RUTA_DESTINO||TIPO_PLANTILLA||"_"||vContadorArchivos||".unl >> "||RUTA_DESTINO||TIPO_PLANTILLA||"_"||vContadorArchivos||".tmp_ready";
                SYSTEM vsql;
                
                --Linea que genera los numeros de linea de cada uno de los registros obtenidos | No se hace en la base de datos para mejorar optimizacion.
                LET vsql ='';
                LET vsql = " sed = "||RUTA_DESTINO||TIPO_PLANTILLA||"_"||vContadorArchivos||".tmp_ready | sed 'N;s/\n/|/' >> "||RUTA_DESTINO||TIPO_PLANTILLA||"_"||vContadorArchivos||".ready";
                SYSTEM vsql;
                
                --Linea indispensable <EOF> que debe agregarse en los archivos para ser usados por Latinia.
                LET vsql ='';
                LET vsql ='echo "<EOF>" >> '||RUTA_DESTINO||TIPO_PLANTILLA||"_"||vContadorArchivos||".ready";
                SYSTEM vsql;
            
                LET vsql ='';
                LET vsql ='rm '||RUTA_DESTINO||TIPO_PLANTILLA||'_'||vContadorArchivos||'.tmp_ready';
                SYSTEM vsql;
                
                LET vsql ='rm '||RUTA_DESTINO||TIPO_PLANTILLA||'_'||vContadorArchivos||'.unl';
                SYSTEM vsql;
        
                --El numero vRegistrosMaxPorArchivo es la base de registros por archivo
                LET vNumInicioRegistros = vNumInicioRegistros + vRegistrosMaxPorArchivo;
                
                LET vContadorArchivos = vContadorArchivos::INTEGER + 1;
                --Se realiza una suma de la variable vNumInicioRegistros (cero) mas vRegistrosMaxPorArchivo
                --Para que en ciclo 2 el SKIP comience en el resultado de vNumInicioRegistros
               
               --Se actualiza la variable de registros faltantes por ingresar en el archivo.
                LET vTotalRegistros = vTotalRegistros - vTotalInterna;
            END LOOP;
        END IF;
            
        DROP TABLE IF EXISTS tmp_info_clientes;
        DROP TABLE IF EXISTS tmp_clientes_promedio;
        DROP TABLE IF EXISTS tmp_clientes_maestra;
        DROP TABLE IF EXISTS tmp_movimientos_actuales;
        DROP TABLE IF EXISTS tmp_movimientos_trimestrales;
        DROP TABLE IF EXISTS tmp_movimientos_historicos;
        DROP TABLE IF EXISTS tmp_bines_debito;
    ----------------------------------------------------------------------------------------------------------------------------------------------------
    RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO, vFechaInicio, vFechaFinal;

/*
-- Autor: [ agarciao@bancoppel.com ]
-- Modificado: 22.enero.2018 09:39:00am
-- Base de datos: intercard
-- Job: 533_REPORTE_TRIMESTRAL_CTES_CAPTA_INTERCARD_PRO
-- Descripcion:
-- Plantilla 1: Clientes con compra de tarjeta presente: sp_ctes_tdd_presente crea la tabla info_reporte_trimestral
-- Plantilla 2: Clientes con compra de tarjeta no presente: sp_ctes_tdd_no_presente
-- Plantilla 3: Clientes con compra TAG: sp_ctes_tdd_compratag
-- Plantilla 4: Clientes con retiros en cajeros automaticos: sp_ctes_tdd_retiros_atm
-- Plantilla 5: Clientes retiro o consulta de saldo en ventanilla: sp_ctes_tdd_ventanilla
-- Reporte de Conteo: El sp_reporte_trimestral_captacion borra la tabla info_reporte_trimestral
*/
END;
END PROCEDURE;