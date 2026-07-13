CREATE PROCEDURE "informix".sp_limpiatarjeta_bloqueada_iccat()
	RETURNING CHAR(6), CHAR(18); -- CODIGO DE RETORNO

	DEFINE sql_err 		INTEGER ;
    DEFINE cCodret1  	CHAR(6);
	DEFINE cCodret2  	CHAR(18);
	DEFINE iNumReg		INTEGER;

    LET cCodret1  = '000000';
	LET cCodret2  = 'Ejecución Correcta';
	LET iNumReg = 0;

	--SET DEBUG FILE TO '/informix/tmp/sp_limpiatarjeta_bloqueada_iccat.out'; 
	--TRACE ON;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodret1 = '000001';
			LET cCodret2 = 'No Existe Tabla';
			RETURN cCodret1, cCodret2;
		END IF;
	END EXCEPTION;

	SELECT COUNT(*) INTO iNumReg
	FROM "informix".stmp_tarjeta_clte_bloqueada_iccat;
	IF (iNumReg > 0) THEN		
		--TRUNCATE TABLE INTERCARD: "informix".stmp_tarjeta_clte_bloqueada_iccat DROP STORAGE;
		DELETE FROM "informix".stmp_tarjeta_clte_bloqueada_iccat;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN		
			LET cCodret1 = '000001';
			LET cCodret2 = 'Falló Borrado';			
		END IF;
	END IF;

	RETURN cCodret1, cCodret2;
END;

END PROCEDURE

DOCUMENT
'OBJETIVO: 	Eliminar informacion contenida en la tabla stmp_tarjeta_clte_bloqueada_iccat',
'AUTOR:		Pedro Portugal',
'FECHA : 	01/06/2017',
'BD : 		INTERCARD',
'OBJETIVO: 	Se modifica procedimiento para que regrese un código de retorno de éxito o fallo, así como se modifica el borrado de la información de tabla contenedora ya que se usaba: TRUNCATE TABLE',
'AUTOR:		José Luis Polanco Bustillo',
'FECHA : 	18/10/2017',
'BD : 		INTERCARD';

CREATE PROCEDURE "informix".sp_registra_evento(
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

CREATE PROCEDURE "informix".sp_validartarjetas_debcred_iccat(pNumcte CHAR(9), pNum_cta CHAR(20), pNum_tarjeta CHAR(16))
	RETURNING CHAR(9), CHAR(16);
	
	DEFINE sql_err INTEGER ;
	DEFINE cCodRet CHAR(9);
	DEFINE cStatusTar CHAR(16);
	DEFINE isCredito CHAR(1);
	DEFINE cTarjActiva CHAR(16);
	DEFINE cCodTar CHAR(4);
	DEFINE cTitular CHAR(1);
	
	LET cCodRet  = '000000000';
	LET cStatusTar = '';
	LET cTarjActiva = '';
	LET cCodTar = '';
	LET cTitular = '';
	
	--SET DEBUG FILE TO "/informix/tmp/sp_validartarjetas_debcred_iccat.out";
	--TRACE ON;
  
BEGIN	
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			let cCodRet = sql_err;
			RETURN cCodRet, cTarjActiva;
		END IF;
	END EXCEPTION;	
	
	IF NVL(pNumcte,'') = '' OR NVL(pNum_cta,'') = '' OR NVL(pNum_tarjeta,'') = '' THEN
		LET cCodRet  = '000000005'; --PARAMETROS VACIOS
		RETURN cCodRet,cTarjActiva;
	END IF;  

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;   
		--OBTENEMOS EL VALO DE ISCREDITO  DÉBITO = 0 , CRÉDITO = 1
	/*SELECT COUNT(*) 
	INTO isCredito
	FROM bdicred:"informix".sd_tarjeta
	WHERE num_credito = pNum_cta;
		--BLOQUEO POR INTENTOS FALLIDOS ICCAT
	SELECT status_tar
	INTO cStatusTar
	FROM intercard:"informix".stmp_tarjeta_clte_bloqueada_iccat 
	WHERE numcuenta = pNum_cta AND numtarjeta = pNum_tarjeta;
	
	--OBTENEMOS EL TIPO DE TARJETA
	SELECT titular
	INTO cTitular
	FROM intercard: "informix".tarjeta
	WHERE numtarjeta = pNum_tarjeta;
	
	IF (cTitular IS NULL) THEN
		LET cTitular = '';
	END IF;
   
	IF (cStatusTar = 'B') THEN
		LET cCodRet = '000000001'; --BLOQUEADO POR INTENTOS FALLIDOS ICCAT
		RETURN cCodRet, cTarjActiva;
	END IF;
		--SI ES MAYOR QUE CERO ES TARJETA DE CRÉDITO
	IF (isCredito > 0) THEN 
	--TARJETA ACTIVA TITULAR
		--TRAEMOS EL PRODUCTO
		SELECT FIRST 1 prodtarjeta
		INTO cCodTar
		FROM bdicred:"informix".sd_tarjeta
		WHERE num_credito = pNum_cta AND numcte = pNumcte;
				
		SELECT s.num_tarjeta
		INTO cTarjActiva
		FROM bdicred:"informix".sd_tarjeta AS s, intercard: "informix".tarjeta AS t  
		WHERE s.numcte = pNumcte AND s.num_tarjeta = t.numtarjeta AND t.codstatustarjeta = 'ACT' 
		AND t.titular = cTitular AND s.prodtarjeta = cCodTar
		AND s.num_credito = pNum_cta;

		IF (cTarjActiva IS NOT NULL OR cTarjActiva != '') THEN
			LET cCodRet = '000000002'; --TITULAR TIENE UNA TARJETA ACTIVA DEL MISMO TIPO
			RETURN cCodRet, cTarjActiva;
		END IF;
	
	--BLOQUEADA POR EL ICCAT
		SELECT FIRST 1 s.num_tarjeta
		INTO cTarjActiva
		FROM bdicred:"informix".sd_tarjeta AS s, intercard: "informix".tarjeta AS t 
		WHERE s.numcte = pNumcte AND s.num_tarjeta = t.numtarjeta 
		AND t.codstatustarjeta IN('EXT','ROB','BTC') AND s.prodtarjeta = cCodTar
		AND s.num_credito = pNum_cta;
		
		IF (cTarjActiva != '' OR cTarjActiva IS NOT NULL) THEN
			LET cCodRet = '000000003'; --CUENTA CON UNA TARJETA CON ALGUNO DE LOS SIG. STATUS Extraviada(?EXT?), Robada(?ROB?) o Bloqueo Temporal CAT(?BTC?).
			RETURN cCodRet, cTarjActiva;
		END IF;
	--TARJETA BLOQUEADA NO POR ICCAT
		SELECT COUNT(*)
		INTO cStatusTar
		FROM bdicred:"informix".sd_tarjeta AS s, intercard: "informix".tarjeta AS t 
		WHERE s.numcte = pNumcte AND s.num_credito = pNum_cta AND s.num_tarjeta = t.numtarjeta 
			AND t.codstatustarjeta IN('BLO','BLT') AND s.prodtarjeta IN (6001,7000,8100);
		
		IF (cStatusTar > 0) THEN
			LET cCodRet = '000000004'; --LA TARJETA CUENTA CON LOS SIG. STATUS BLOQUEADA(?BLO?) o Bloqueo Temporal (?BLT?).
			RETURN cCodRet, cTarjActiva;
		END IF;
	ELSE
	
	--TARJETA ACTIVA TITULAR/ADICIONAL
		SELECT s.num_tarjeta
		INTO cTarjActiva
		FROM bdicheq:"informix".sc_tarjeta AS s, intercard: "informix".tarjeta AS t  
		WHERE s.numcte = pNumcte AND s.num_tarjeta = t.numtarjeta AND t.codstatustarjeta = 'ACT' 
		AND t.titular = cTitular AND s.prodtarjeta = '2400'
		AND s.cuenta = pNum_cta;

		IF (cTarjActiva IS NOT NULL) THEN
			LET cCodRet = '000000002'; --TITULAR TIENE UNA TARJETA ACTIVA DEL MISMO TIPO
			RETURN cCodRet, cTarjActiva;
		END IF;
	
	--BLOQUEADA POR EL ICCAT
		SELECT FIRST 1 s.num_tarjeta
		INTO cTarjActiva
		FROM bdicheq:"informix".sc_tarjeta AS s, intercard: "informix".tarjeta AS t 
		WHERE s.numcte = pNumcte AND s.num_tarjeta = t.numtarjeta 
		AND t.codstatustarjeta IN('EXT','ROB','BTC') AND s.prodtarjeta = '2400'
		AND s.cuenta = pNum_cta;
		
		IF (cTarjActiva != '' OR cTarjActiva IS NOT NULL) THEN
			LET cCodRet = '000000003'; --CUENTA CON UNA TARJETA CON ALGUNO DE LOS STATUS Extraviada(?EXT?), Robada(?ROB?) o Bloqueo Temporal CAT(?BTC?).
			RETURN cCodRet,cTarjActiva;
		END IF;
	--TARJETA BLOQUEADA NO POR ICCAT
		SELECT COUNT(*)
		INTO cStatusTar
		FROM bdicheq:"informix".sc_tarjeta AS s, intercard: "informix".tarjeta AS t 
		WHERE s.numcte = pNumcte AND s.cuenta = pNum_cta AND s.num_tarjeta = t.numtarjeta 
			AND t.codstatustarjeta IN('BLO','BLT') AND s.prodtarjeta = '2400';
		
		IF (cStatusTar > 0) THEN
			LET cCodRet = '000000004'; --LA TARJETA CUENTA CON LOS SIG. STATUS BLOQUEADA(?BLO?) o Bloqueo Temporal (?BLT?).
			RETURN cCodRet, cTarjActiva;
		END IF;
	END IF;
--SI ES CERO LA TARJETA SE PUEDE ACTIVAR
	IF (cStatusTar = 0) THEN*/
		RETURN cCodRet, cTarjActiva;
	--END IF;
END
END PROCEDURE  
DOCUMENT
'OBJETIVO: 	VALIDAR SI SE PODRÁ ACTIVAR LA TARJETA DESDE EL ICCAT',
'AUTOR:		FELIPE MONZÓN MENDOZA',
'FECHA : 	05/06/2017',
'BD : 		INTERCARD',
'OBJETIVO: Se modifica SP para quitar las validaciones de bloqueos y permitir',
'		   poder activar las tarjetas a petición del dueño del producto MKT',
'AUTOR:     José Luis Polanco Bustillo',
'FECHA :   12/02/2018';

CREATE PROCEDURE "informix".sp_validarfechatarjetas_debcred_iccat(pNumTarjeta char(16), pFecha char(4))
RETURNING  	CHAR(9);	--CODIGO DE RETORNO
			

DEFINE cCodRet char(9);
DEFINE cNumTar char(16);
DEFINE isql_err integer;
DEFINE pFecha1 char(2);
DEFINE pFecha2 char(2);

LET cCodRet = '000000000';
LET cNumTar = '';
LET pFecha1 = '';
LET pFecha2 = '';

BEGIN

	ON EXCEPTION SET isql_err
		IF isql_err <> 0 THEN
			let cCodRet = isql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION DIRTY READ;

	--SET DEBUG FILE TO '/informix/tmp/sp_validarfechatarjetas_debcred_iccat.out';	
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;

	LET pFecha1 = SUBSTR(pFecha,1,2);
	LET pFecha2 = SUBSTR(pFecha,3,2);

	LET pFecha = '';
	LET pFecha = pFecha2||pFecha1;
	
	/*IF EXISTS (SELECT num_tarjeta FROM bdicred:"informix".sd_tarjeta WHERE num_tarjeta = pNumTarjeta) THEN -- ES CREDITO
		
		SELECT tr.numtarjeta
		INTO cNumTar
		FROM intercard:"informix".tarjeta tr 
		INNER JOIN intercard:"informix".hsmcard hs on hs.expirationdate = tr.fechaexp
		--INNER JOIN bdicred:"informix".sd_tarjeta sdtar on TO_CHAR(sdtar.expiracion, '%m%y') = hs.expirationdate
		INNER JOIN bdicred:"informix".sd_tarjeta sdtar on TO_CHAR(sdtar.expiracion, '%y%m') = hs.expirationdate
		WHERE hs.card_no = tr.numtarjeta 
		AND sdtar.num_tarjeta = tr.numtarjeta
		AND tr.numtarjeta = pNumTarjeta
		AND tr.fechaexp = pFecha;
		
	ELIF EXISTS (SELECT num_tarjeta FROM bdicheq:"informix".sc_tarjeta WHERE num_tarjeta = pNumTarjeta) THEN -- ES DEBITO
		
		SELECT tr.numtarjeta 
		INTO cNumTar
		FROM intercard:"informix".tarjeta tr 
		INNER JOIN intercard:"informix".hsmcard hs on hs.expirationdate = tr.fechaexp
		--INNER JOIN bdicheq:"informix".sc_tarjeta sctar on TO_CHAR(sctar.expiracion, '%m%y') = hs.expirationdate
		INNER JOIN bdicheq:"informix".sc_tarjeta sctar on TO_CHAR(sctar.expiracion, '%y%m') = hs.expirationdate
		WHERE hs.card_no = tr.numtarjeta 
		AND sctar.num_tarjeta = tr.numtarjeta
		AND tr.numtarjeta = pNumTarjeta
		AND tr.fechaexp = pFecha;
		
	END IF;
	
	IF (cNumTar IS NULL OR cNumTar = '') THEN
		LET cCodRet = '000000001'; -- FECHA NO COINCIDE
	END IF;*/
	
	RETURN cCodRet;

END 
END PROCEDURE
DOCUMENT
'OBJETIVO: 	Valida que cuadre la fecha de expiracion de la tarjeta en las tablas correspondientes',
'AUTOR:		Keevyn Adrian Gil Valenzuela',
'FECHA : 	13/06/2017',
'BD : 		intercard',
'OBJETIVO:  Se omite validación de fecha de caducidad de las tarjetas a petición del dueño del producto MKT',
'AUTOR:     José Luis Polanco Bustillo',
'FECHA:     12/02/2018';

CREATE PROCEDURE "informix".sp_registraintentos_acttarjetas_iccat(pNumcte CHAR(20), pNum_cta CHAR(20), pNum_tar CHAR(16), pNomcte CHAR(104), pEjecutivo CHAR(8), pTipotarj CHAR(1))
	RETURNING CHAR(9);
	
	DEFINE sql_err INTEGER ;
	DEFINE cCodRet CHAR(9);
	DEFINE iContador INTEGER;
	DEFINE isCredito CHAR(1);
	DEFINE cNumcte_adic CHAR(20);
	DEFINE cNumcte_tit CHAR(20);
	
	LET cCodRet  = '000000000';
	LET cNumcte_adic = '';
	LET cNumcte_tit = '';
	
	--SET DEBUG FILE TO "/informix/tmp/sp_registraintentos_acttarjetas_iccat.out";
	--TRACE ON;
  
BEGIN	
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodRet = sql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;	
	
	IF (NVL(pNumcte,'') = '' OR NVL(pNum_cta,'') = '' OR NVL(pNomcte,'') = '' OR NVL(pEjecutivo,'') = '' OR NVL(pTipotarj,'') = '' OR NVL(pNum_tar,'') = '') THEN
		LET cCodRet  = '000000002'; --PARAMETROS VACIOS
		RETURN cCodRet;
	END IF;  

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;   
	
		--OBTENEMOS EL VALOR DE ISCREDITO  DÉBITO = 0 , CRÉDITO = 1
	/*SELECT COUNT(*) 
	INTO isCredito
	FROM bdicred:"informix".sd_tarjeta
	WHERE num_credito = pNum_cta;
		--SI ES MAYOR QUE CERO ES TARJETA DE CRÉDITO
	IF (isCredito > 0) THEN
		SELECT numcte
		INTO cNumcte_tit
		FROM bdicred:"informix".sd_tarjeta
		WHERE num_credito = pNum_cta AND secuencia = 1;
	
		IF (cNumcte_tit != pNumcte) THEN
			SELECT FIRST 1 numcte
			INTO cNumcte_adic
			FROM bdicred:"informix".sd_tarjeta
			WHERE num_credito = pNum_cta AND tipo_tarjeta = 'A' AND prodtarjeta IN (6001,7000,8100);
		END IF;
		
	ELSE 
		SELECT numcte 
		INTO cNumcte_tit
		FROM bdicheq:"informix".sc_tarjeta 
		WHERE cuenta = pNum_cta AND secuencia = 1;
		
		
		IF (cNumcte_tit != pNumcte) THEN
			SELECT FIRST 1 numcte 
			INTO cNumcte_adic
			FROM bdicheq:"informix".sc_tarjeta 
			WHERE cuenta = pNum_cta AND tipo_tarjeta = 'A' AND prodtarjeta = '2400';
		END IF;		
	END IF;
	
	SELECT num_int_fallidos
	INTO iContador
	FROM intercard:"informix".stmp_tarjeta_clte_bloqueada_iccat 
	WHERE numtarjeta = pNum_tar;
	
	IF (iContador IS NULL) THEN 
		LET iContador = 0;
	END IF;
	
	IF (iContador = 0) THEN 
		INSERT INTO intercard:"informix".stmp_tarjeta_clte_bloqueada_iccat (empresa,numcte_tit,numcuenta,numtarjeta,nombre,num_int_fallidos,fecha_utl_mod,ejecutivo,status_tar,tipo_tarjeta,numcte_adic,user_insert,fecha_insert)
		VALUES ('001',cNumcte_tit,pNum_cta,pNum_tar,pNomcte,1,CURRENT,pEjecutivo,'I',pTipotarj,cNumcte_adic,pEjecutivo,CURRENT);
	ELIF (iContador = 1) THEN
		UPDATE intercard:"informix".stmp_tarjeta_clte_bloqueada_iccat SET num_int_fallidos = '2', fecha_utl_mod = CURRENT 
		WHERE numcte_tit = cNumcte_tit AND numtarjeta = pNum_tar;
	ELIF (iContador = 2) THEN
		UPDATE intercard:"informix".stmp_tarjeta_clte_bloqueada_iccat SET num_int_fallidos = '3', status_tar = 'B', fecha_utl_mod = CURRENT 
		WHERE numcte_tit = cNumcte_tit AND numtarjeta = pNum_tar;
		LET cCodRet  = '000000001';
	END IF;*/
	
	RETURN cCodRet;
END
END PROCEDURE  
DOCUMENT
'OBJETIVO: 	REGISTRAR NÚMERO DE INTENTOS FALLIDOS AL ACTIVAR LA TARJETA DESDE EL ICCAT',
'AUTOR:		FELIPE MONZÓN MENDOZA',
'FECHA : 	05/06/2017',
'BD : 		INTERCARD',
'OBJETIVO:  Se omite bloqueo por intentos fallidos de activación a petición del dueño del producto MKT',
'AUTOR:     José Luis Polanco Bustillo',
'FECHA:     12/02/2018';

CREATE PROCEDURE "informix".sp_arqcvalidoshistorico()
RETURNING VARCHAR(6) as Cod_ret, VARCHAR(80) as Men_ret;

	--  Variables de Errores y datos de SP
	define  sql_err          integer;
	define  isam_err         integer;
	define  error_info       varchar(80);
	define  p_cod_ret        varchar(6);
	define  p_mensaje        varchar(80);
	
	
   	--  Variables para control de contadores
	define  vsflagentransaccion 	char(1);
	define 	vicontadorregistros 	integer;
	define  vicontadorregistros2 	integer;
    
	--  Variables para datos de primary key
	define  vmaxnumregistros integer;
	define  vperiododepuracion integer;
	define  vsecuencia  varchar (7);
	define  vsecuenciaextendida  varchar (16);
	define  vfechalocaltransaccion  varchar (4);
	define  vhoralocaltransaccion  varchar (6);
		


BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET P_COD_RET    = SQL_ERR;
	LET P_MENSAJE  = ERROR_INFO;
	
    RETURN 	P_COD_RET,P_MENSAJE;
		
   END EXCEPTION;

	let		vsecuenciaextendida='';
	let		vperiododepuracion=0;
	let 	vsflagentransaccion = 'F';
	let		vicontadorregistros = 0;
	let		vicontadorregistros2 = 0;
	let		p_cod_ret = '00000';
	let		p_mensaje = 'Proceso Exitoso.';
	let            vmaxnumregistros = 0;
	--set debug file to '/tmp/sp_arqcvalidoshistorico.out';
	--trace on;
		select 	maxnumregistros into  vmaxnumregistros
			from intercard:"informix".parametros;
		select periododepuracion into vperiododepuracion
			from intercard:"informix".parametros;
					
	set isolation to dirty read;
		foreach cusor1 with hold
				for    
				select {+INDEX (movimiento  idx_fechahorainauth)} m.secuenciaextendida
					into vsecuenciaextendida
				from intercard:"informix".movimiento m 
					inner join intercard:"informix".arqcvalidos a on 
						m.metodocaptura = '05' 
						and fechahorainauth < (CURRENT - (vperiododepuracion units day))  
						and m.secuenciaextendida = a.secuenciaextendida
			
                if(vsflagentransaccion = 'F') then
			begin work;
	                let vsflagentransaccion = 'V';
		end if;
			
		--  Inserta datos en la tabla historica
		
		
		insert into arqcvalidoshistorico 
		select secuenciaextendida, arqccalculado 
		from intercard:"informix".arqcvalidos 
		where secuenciaextendida = vsecuenciaextendida;
		
		--  Borra registro de la Tabla de arqcvalidos	
		delete from intercard:"informix".arqcvalidos 
		where secuenciaextendida = vsecuenciaextendida;
		let vicontadorregistros = vicontadorregistros + 1;


			if (vicontadorregistros = vmaxnumregistros) then
				commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
				continue foreach;
			end if;		
		end foreach;
		
		if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
				commit work;
				let vsflagentransaccion = 'F';
		end if;

	RETURN 	P_COD_RET,P_MENSAJE;
END;

END PROCEDURE;