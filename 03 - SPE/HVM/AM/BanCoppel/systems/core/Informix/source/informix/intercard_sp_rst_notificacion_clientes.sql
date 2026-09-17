CREATE PROCEDURE "informix".sp_rst_notificacion_clientes( pNumCliente VARCHAR(20), pNumTarjeta VARCHAR(16), pMonto DECIMAL(19,2), pNumAutorizacion INTEGER ) 
    RETURNING VARCHAR(5) AS rCodigoRetorno, VARCHAR (80) as rMensajeRetorno;
	
    DEFINE SQL_ERR   INTEGER;
    DEFINE ISAM_ERR   INTEGER;
    DEFINE ERROR_INFO  CHAR(80);
    DEFINE RUTA_ORIGEN VARCHAR(30);
    
    DEFINE vCodigoRetorno VARCHAR(5);
    DEFINE vMensajeRetorno VARCHAR(80);
    DEFINE vNumeroCliente VARCHAR(20);
    DEFINE vNumCliente VARCHAR(20);
    DEFINE vNumeroTarjeta VARCHAR(16);
    DEFINE vTipoTransaccion VARCHAR(5);
    
    DEFINE vPlantilla VARCHAR(12);
    DEFINE vContrato VARCHAR(10);
    DEFINE vNumTelefono CHAR(13);    
    DEFINE vTerminacionTarjeta CHAR(4);
    DEFINE vPrimerNombre VARCHAR(26);
    DEFINE vSegundoNombre VARCHAR(26);    
    DEFINE vApellidoPaterno VARCHAR(26);
    DEFINE vApellidoMaterno VARCHAR(26);
    DEFINE vCorreoElect VARCHAR(100);
    DEFINE NOTIF_SMS VARCHAR(3);
    DEFINE NOTIF_CORREO_ELEC VARCHAR(3);
    DEFINE NOTIF_AMBOS_SMS_CORREO VARCHAR(3);
    DEFINE vFechaSistema DATETIME YEAR TO FRACTION(5);
    DEFINE vMontoRetiro DECIMAL(19,2);
    DEFINE vNumAutorizacion INTEGER;  
    
    DEFINE vContratoSMS VARCHAR(12);
    DEFINE vPlantillaSMS VARCHAR(12);
    DEFINE vContratoCorreo VARCHAR(12);
    DEFINE vPlantillaCorreo VARCHAR(12);
    DEFINE vTipoEnvio CHAR(1);
    DEFINE vHabilitarEnvio CHAR(1);
    DEFINE VALIDAR_NO CHAR(2);
    
    
    LET SQL_ERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
    
    LET vCodigoRetorno = '00000';
    LET vMensajeRetorno = 'Inicio de ejecucion';
    LET RUTA_ORIGEN = '/RESPALDOSNEW/';    
        
    LET vNumCliente = TRIM(pNumCliente);    
    LET vNumeroTarjeta = TRIM(pNumTarjeta);    
    LET vCorreoElect = '0';
    LET vNumeroCliente = '0';
    
    LET vPlantilla = NULL;
    LET vContrato = '';
    LET vNumTelefono = '0';    
    LET vTerminacionTarjeta = '0000';    
    LET vPrimerNombre = '0';
    LET vSegundoNombre = '0';
    LET vApellidoPaterno = '0';
    LET vApellidoMaterno = '0';
    
    LET NOTIF_AMBOS_SMS_CORREO = '0';
    LET NOTIF_SMS = '1';
    LET NOTIF_CORREO_ELEC = '2';
    
    LET vFechaSistema = current;
    LET vMontoRetiro = pMonto;
    LET vNumAutorizacion = pNumAutorizacion;
    
    LET vTipoEnvio = '0';
    LET vHabilitarEnvio = 'N';
    LET vContratoSMS = 'CMPS_BATCH';    
    LET vPlantillaSMS = 'RST_MSJ_SMS';
    LET vContratoCorreo = 'CMPC_BATCH';
    LET vPlantillaCorreo = 'RST_MSJ_CEC';
    LET VALIDAR_NO = 'NO';
    
    --SET DEBUG FILE TO RUTA_ORIGEN || "debug_sp_rst_notificacion_clientes.out" WITH APPEND;
    --TRACE ON;
	
	BEGIN

        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_ORIGEN || "excep_sp_rst_notificacion_clientes.err" WITH APPEND;
            TRACE ON;
            
            IF ( SQL_ERR <> 0 ) THEN
                LET vCodigoRetorno = SQL_ERR;
                LET vMensajeRetorno = ERROR_INFO;                
                RETURN vCodigoRetorno, vMensajeRetorno;
            END IF
			
        END EXCEPTION

        SET ISOLATION TO DIRTY READ; 
        SET LOCK MODE TO WAIT 3;
        
        EXECUTE PROCEDURE intercard:"informix".sp_intercard_info_ctes_por_notif( vNumCliente, VALIDAR_NO )
            INTO vCodigoRetorno,  vMensajeRetorno, vNumeroCliente, vPrimerNombre, vSegundoNombre, vApellidoPaterno, vApellidoMaterno,
                vNumTelefono, vCorreoElect;            
                          
        IF ( vCodigoRetorno  =  '00001') THEN
            LET vCodigoRetorno = '00000';
            LET vMensajeRetorno = 'Continuar Transaccionalidad. Sin notificacion al cliente.';
            RETURN vCodigoRetorno, vMensajeRetorno;
        END IF 
        
        SELECT valores 
            INTO vHabilitarEnvio 
        FROM intercard:"informix".tbl_inter_parametros 
            WHERE empresa = '001'
                AND cond_busqueda = 'rst_habilitar_envio';
            
        IF ( vHabilitarEnvio <> 'S' AND vHabilitarEnvio <> 'N' ) THEN
            LET vCodigoRetorno = '00000';
            LET vMensajeRetorno = 'Parametro de envio incorrecto.';
            RETURN vCodigoRetorno, vMensajeRetorno;
        END IF
        
        IF ( vHabilitarEnvio == 'N') THEN
            LET vCodigoRetorno = '00000';
            LET vMensajeRetorno = 'El envio de notificaciones esta deshabilitado.';
            RETURN vCodigoRetorno, vMensajeRetorno;
        END IF
        
        
        --Validar si debe enviarse el mensaje al cliente.
        SELECT valores 
            INTO vTipoEnvio 
        FROM intercard:"informix".tbl_inter_parametros 
            WHERE empresa = '001'
                AND cond_busqueda = 'rst_tipo_envio';
        
        IF ( vTipoEnvio <> '0' AND vTipoEnvio <> '1' AND vTipoEnvio <> '2' ) THEN
            LET vCodigoRetorno = '00000';
            LET vMensajeRetorno = 'Tipo de envio incorrecto.';
            RETURN vCodigoRetorno, vMensajeRetorno;
        END IF 
        
        LET vTerminacionTarjeta = SUBSTR( vNumeroTarjeta, 13, 4 );
        
        ---Envio de mensajes para los clientes
        --- vTipoEnvio = 0 | El mensaje es enviado por SMS y Correo Electronico.
        --- vTipoEnvio = 1 | El mensaje es enviado por SMS.
        --- vTipoEnvio = 2 | El mensaje es enviado por Correo Electronico.
        ---Por default para asignarle el numero encontrado del cliente.
        
        LET vNumeroCliente = '000000000';
        
        IF ( vTipoEnvio = '0' ) THEN
        
            IF ( LENGTH(TRIM(vNumTelefono)) <> 0 ) THEN
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2', vContratoSMS, vPlantillaSMS, vNumeroCliente,'','','1',vPrimerNombre,vTerminacionTarjeta,vNumAutorizacion,'','','','','','','','',vNumTelefono,vMontoRetiro,0,0,0,0,vFechaSistema,vFechaSistema)
                    INTO vCodigoRetorno;
            END IF
            
            IF ( LENGTH(TRIM(vCorreoElect)) <> 0 ) THEN                
               --	 EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1',vContratoCorreo, vPlantillaCorreo, vNumeroCliente,'','','1',vPrimerNombre,vTerminacionTarjeta,vNumAutorizacion,'','','','','','','',vCorreoElect,'',vMontoRetiro,0,0,0,0,vFechaSistema,vFechaSistema)
				--	2023.09.25-i	Se modifica orden de campos de plantilla por comentarios de Abel Ricardo Gómez.
			    	EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('1',vContratoCorreo,vPlantillaCorreo,vNumeroCliente,'','','1',vPrimerNombre,vNumAutorizacion,vMontoRetiro,'','','','','','','',vCorreoElect,'',0,0,0,0,0,vFechaSistema,vFechaSistema)
				--	Desarrollo: 
				--	EXECUTE PROCEDURE bdimnsj@coppel_latinia_tcp:sp_registra_evento('1',vContratoCorreo,vPlantillaCorreo,vNumeroCliente,'','','1',vPrimerNombre,vNumAutorizacion,vMontoRetiro,'','','','','','','',vCorreoElect,'',0,0,0,0,0,vFechaSistema,vFechaSistema)
				--	2023.09.25-f
                    INTO  vCodigoRetorno;
            END IF
                        
            LET vCodigoRetorno = '00000';
            LET vMensajeRetorno = 'Registro de Notificaciones. Continuar con transaccionalidad.';
            RETURN vCodigoRetorno, vMensajeRetorno;
            
        END IF 
    
        IF ( vTipoEnvio = '1' ) THEN
        
             IF ( LENGTH(TRIM(vNumTelefono)) <> 0 ) THEN                
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2', vContratoSMS, vPlantillaSMS , vNumeroCliente,'','','1',vPrimerNombre,vTerminacionTarjeta,vNumAutorizacion,'','','','','','','','',vNumTelefono,vMontoRetiro,0,0,0,0,vFechaSistema,vFechaSistema)
                    INTO vCodigoRetorno;                
            END IF
            
            LET vCodigoRetorno = '00000';
            LET vMensajeRetorno = 'Registro de Notificaciones. Continuar con transaccionalidad.';
            RETURN vCodigoRetorno, vMensajeRetorno;
        END IF
        
        IF ( vTipoEnvio = '2' ) THEN           
            
            IF ( LENGTH(TRIM(vCorreoElect)) <> 0 ) THEN                 
                --	EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1',vContratoCorreo, vPlantillaCorreo, vNumeroCliente,'','','1',vPrimerNombre,vTerminacionTarjeta,vNumAutorizacion,'','','','','','','',vCorreoElect,'',vMontoRetiro,0,0,0,0,vFechaSistema,vFechaSistema)
				--	2023.09.25-i	Se modifica orden de campos de plantilla por comentarios de Abel Ricardo Gómez.
			    	EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('1',vContratoCorreo,vPlantillaCorreo,vNumeroCliente,'','','1',vPrimerNombre,vNumAutorizacion,vMontoRetiro,'','','','','','','',vCorreoElect,'',0,0,0,0,0,vFechaSistema,vFechaSistema)
				--	Desarrollo: 
				--	EXECUTE PROCEDURE bdimnsj@coppel_latinia_tcp:sp_registra_evento('1',vContratoCorreo,vPlantillaCorreo,vNumeroCliente,'','','1',vPrimerNombre,vNumAutorizacion,vMontoRetiro,'','','','','','','',vCorreoElect,'',0,0,0,0,0,vFechaSistema,vFechaSistema)
				--	2023.09.25-f
                    INTO vCodigoRetorno;
            END IF
            
            LET vCodigoRetorno = '00000';
            LET vMensajeRetorno = 'Registro de Notificaciones. Continuar con transaccionalidad.';
            RETURN vCodigoRetorno, vMensajeRetorno;  
        END IF       

        RETURN vCodigoRetorno, vMensajeRetorno;
            
	END
				
END PROCEDURE
DOCUMENT
'Autor: Armando Garcia Ortiz',
'Base de datos: intercard',
'Fecha de creación: 27 de enero del 2021',
'Descripcion: Registro de notificaciones de mensaje de texto o correo electronico para retiro sin tarjeta', 

'Autor: Fermín Ramos García',
'Base de datos: intercard',
'Fecha de modificación: 10 de Octubre del 2023',
'Descripcion: Se actualiza orden de los campos para envío de email a solicitud de usuario: Axel Baez Obregón'

;

CREATE PROCEDURE "informix".sp_migra_oro_plat_reporte()
   --MIGRA_ORO_PLAT_DDMMAAAA
RETURNING CHAR(5) AS CodRet; /* El RETURNING solo regresa el cÃ³digo "00000" o en su caso el valor correspondiente al error detectado */


	DEFINE iSqlErr      INTEGER;
	DEFINE cCodRet 	    CHAR(5);

    DEFINE tipoprod    CHAR(16);
    DEFINE numprod     CHAR(4);
    DEFINE nombrecli   CHAR(100);
    DEFINE sucursal    CHAR(5);
    DEFINE numcliente  CHAR(9);
    DEFINE numcuenta   CHAR(12);
    DEFINE numtarjeta  CHAR(16);
    DEFINE descr       CHAR(50);
    
    DEFINE cCodProdPlat     CHAR(4);   
    DEFINE cCodProdORO      CHAR(4);
    DEFINE cSubBinOroI      CHAR(2);
    DEFINE cSubBinOroN      CHAR(2);
	DEFINE cSubBinPlat      CHAR(2);
	
    DEFINE cBinVisaOroI         CHAR(8);
	DEFINE cBinVisaOroN         CHAR(8);
	DEFINE cBinVisaPlat         CHAR(8);

	DEFINE vfecha_ini      DATE;
	DEFINE sfecha_ini      CHAR(8);
	
	DEFINE iCont           INT;		
	
	/* Variables para generar el reporte */
	DEFINE cCmd1								CHAR(2500);
	DEFINE pRutaDescarga						CHAR(100);
	DEFINE cRutaGral							CHAR(150);
	DEFINE cRutaGral2							CHAR(150);
	DEFINE bInTransaction						BOOLEAN;
	DEFINE ven_transacc							SMALLINT;
	DEFINE cSql									CHAR(2500);
	DEFINE dFechaHoy							DATE;
	DEFINE cFechaArchivo						CHAR(15);
	DEFINE cNombreArchivo						CHAR(50);
    /*-------------------------------------------------------*/
	
	LET cCodRet 	   = '00000';
	
    LET cCodProdPlat   = '7000';  
    LET cCodProdORO    = '8100'; 
    LET cSubBinOroI    = '08'; -- Stock
    LET cSubBinOroN    = '05'; -- Personalizada
    LET cSubBinPlat    = '06'; -- Platino

    LET cBinVisaOroI       ='42680708';
    LET cBinVisaOroN       ='42680705';
    LET cBinVisaPlat       ='42680706';
	
	LET iCont = 0;
	
	/* Variables para generar el reporte */
	LET cCmd1								= '';
	LET pRutaDescarga						= '/RESPALDOSNEW';
	LET cRutaGral							= '';
	LET cRutaGral2							= '';
	LET bInTransaction						= 'f';
	LET ven_transacc						= 0;
	LET cSql								= '';
	LET dFechaHoy							= '';
	LET cFechaArchivo						= '';
	LET cNombreArchivo						= '';
    /*-------------------------------------------------------*/
	 
	 /* Se obtiene la fecha del ultimo dÃ­a de hace 2 meses para obtener los registros desde el 01 del mes anterior,
		considerando que en el mes de enero este proceso se va a ejecutar el dÃ­a 02 */
    --LET vfecha_ini = add_months(current,-1);
	-- Se coloca menos 2 para traer la ultima fecha de hace dos meses como fecha inicial
    LET vfecha_ini = add_months(last_day(current)::date,-2); 
    
    BEGIN
        
		/* En caso de error regresa el cÃ³digo correspondiente, y se agregan excepciones */
        ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;

				IF ven_transacc = 1 THEN
					ROLLBACK WORK;		
				END IF;
				
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		/*-------------------------------------------------------*/
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/ifxsif01/uai/sp_migra_oro_plat_reporte.out';
		--TRACE ON;
		
		/* Se crea tabla para almacenar los datos obtenidos y asÃ­ poder recuperarlos para generar el reporte */
        CREATE TABLE migraoroplat (
        ttipoprod    char(16),
        tnumprod     char(4),
        tnombrecli   char(100),
        tsucursal    char(5),
        tnumcliente  char(9),
        tnumcuenta   char(12),
        tnumtarjeta  char(16),
        tdescr       char(50)
        );             
                
		--5min
		SELECT 
			'ORO Innominada' AS TIPO,
			asig_tarjet.sucursal, asig_tarjet.numcliente, asig_tarjet.numcuenta, asig_tarjet.numtarjeta, asig_tarjet.descripcion     
		FROM intercard:bitasignacionactivaciontarjeta AS asig_tarjet
		WHERE 
			asig_tarjet.numtarjeta LIKE '42680708%' --('42680708%','42680705%','42680706%')
			AND asig_tarjet.fecharegistro > vfecha_ini
		INTO TEMP tmp_bitasignacionactivaciontarjeta WITH NO LOG;

		--UNION
		INSERT INTO tmp_bitasignacionactivaciontarjeta (TIPO, sucursal, numcliente, numcuenta, numtarjeta, descripcion)
		SELECT 
			'ORO Nominada' AS TIPO,
			asig_tarjet.sucursal, asig_tarjet.numcliente, asig_tarjet.numcuenta, asig_tarjet.numtarjeta, asig_tarjet.descripcion     
		FROM intercard:bitasignacionactivaciontarjeta AS asig_tarjet
		WHERE 
			asig_tarjet.numtarjeta LIKE '42680705%' --('42680708%','42680705%','42680706%')
			AND asig_tarjet.fecharegistro > vfecha_ini;

		--UNION
		INSERT INTO tmp_bitasignacionactivaciontarjeta (TIPO, sucursal, numcliente, numcuenta, numtarjeta, descripcion)
		SELECT 
			'PLATINO Nominada' AS TIPO,
			asig_tarjet.sucursal, asig_tarjet.numcliente, asig_tarjet.numcuenta, asig_tarjet.numtarjeta, asig_tarjet.descripcion     
		FROM intercard:bitasignacionactivaciontarjeta AS asig_tarjet
		WHERE 
			asig_tarjet.numtarjeta LIKE '42680706%' --('42680708%','42680705%','42680706%')
			AND asig_tarjet.fecharegistro > vfecha_ini;
		
        FOREACH WITH HOLD
			SELECT {+INDEX (intercard:bitasignacionactivaciontarjeta idx_numtarjeta_fecharegistro)} --{+INDEX (bdicred:sd_tarjeta idx_tarjeta1)}
				asig_tarjet.TIPO,
				sd_mae.num_producto,
				sd_tar.nombre,
				asig_tarjet.sucursal,
				asig_tarjet.numcliente,
				asig_tarjet.numcuenta,
				asig_tarjet.numtarjeta,
				asig_tarjet.descripcion
			INTO 
				tipoprod, 
				numprod, 
				nombrecli, 
				sucursal, 
				numcliente, 
				numcuenta, 
				numtarjeta, 
				descr                    
			FROM 
				tmp_bitasignacionactivaciontarjeta AS asig_tarjet
				JOIN bdicred:sd_tarjeta AS sd_tar ON asig_tarjet.numtarjeta = sd_tar.num_tarjeta and sd_tar.empresa = '001'
				JOIN bdicred:sd_maecred AS sd_mae ON asig_tarjet.numcuenta = sd_mae.num_credito 
			WHERE 
				 sd_mae.num_producto in ('7000','8100') 
			GROUP BY 
				TIPO, 
				sd_mae.num_producto, 
				sd_tar.nombre, 
				asig_tarjet.sucursal, 
				asig_tarjet.numcliente, 
				asig_tarjet.numcuenta, 
				asig_tarjet.numtarjeta, 
				asig_tarjet.descripcion 

			IF iCont > 1000 THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			
           -- RETURN tipoprod,numprod,nombrecli,sucursal,numcliente,numcuenta,numtarjeta,descr WITH RESUME;
            INSERT INTO migraoroplat (ttipoprod,tnumprod,tnombrecli,tsucursal,tnumcliente,tnumcuenta,tnumtarjeta,tdescr)
            VALUES(tipoprod,numprod,nombrecli,sucursal,numcliente,numcuenta,numtarjeta,descr);
        END FOREACH;
        
		/* Se comentan lÃ­neas dado de que no es necesario regresar los registros almacenados en la tabla migraoroplat */
        --FOREACH        
        --    SELECT ttipoprod,tnumprod,tnombrecli,tsucursal,tnumcliente,tnumcuenta,tnumtarjeta,tdescr
        --    INTO tipoprod,numprod,nombrecli,sucursal,numcliente,numcuenta,numtarjeta,descr
        --    FROM migraoroplat
        --    
        --    RETURN tipoprod,numprod,nombrecli,sucursal,numcliente,numcuenta,numtarjeta,descr WITH RESUME;
        --END FOREACH;
		
		/* GENERAR REPORTE */
		LET dFechaHoy = TODAY;
		LET cFechaArchivo = LPAD(DAY(dFechaHoy),2,0)||LPAD(MONTH(dFechaHoy),2,0)||YEAR(dFechaHoy);
		LET cNombreArchivo = 'MIGRA_ORO_PLAT_'||TRIM(cFechaArchivo);
		
		LET cCmd1 = "SELECT 'Sucursal','No. Cliente','Nombre del Cliente','Producto','No. Credito','No. Tarjeta','Tipo de Tarjeta','Accion' FROM systables WHERE tabid = 1 UNION ALL "
					|| "SELECT * FROM (SELECT tsucursal,tnumcliente,tnombrecli,tnumprod,tnumcuenta,tnumtarjeta,ttipoprod,tdescr  FROM migraoroplat ORDER BY tsucursal); ";

		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo)||'.txt';
		LET cRutaGral2 = TRIM(pRutaDescarga)||TRIM(cNombreArchivo)||'.xls';
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			-- Se crea el query
			LET cSql = '';
			LET cSql = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||TRIM(cRutaGral)||' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query_migra_oro_plat.sql';
			SYSTEM TRIM(cSql);
			
			-- AsignaciÃ³n de permisos de acceso
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(pRutaDescarga)||'query_migra_oro_plat.sql';
			SYSTEM TRIM(cSql);	
			
			-- Se ejecuta el query
			LET cSql = '';
			LET cSql = 'dbaccess intercard '||TRIM(pRutaDescarga)||'query_migra_oro_plat.sql';
			SYSTEM TRIM(cSql);
			
			-- Se elimina el query
			LET cSql = '';
			LET cSql = 'rm -rf '||TRIM(pRutaDescarga)||'query_migra_oro_plat.sql';
			SYSTEM TRIM(cSql);
			
			-- AsignaciÃ³n de permisos de acceso
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de linea
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" >> "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- AsignaciÃ³n de permisos de acceso
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el archivo original
			LET cSql = '';
			LET cSql = "rm -rf "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			-- Se modifica el archivo .tmp a txt
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp >> "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			-- AsignaciÃ³n de permisos de acceso
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			-- Se modifica el archivo .tmp a xls
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp >> "||TRIM(cRutaGral2);
			SYSTEM TRIM(cSql);
			
			-- AsignaciÃ³n de permisos de acceso
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral2);
			SYSTEM TRIM(cSql);	
			
			-- Eliminamos el archivo .tmp
			LET cSql = '';
			LET cSql = "rm -rf "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
		COMMIT WORK;
		
		LET ven_transacc = 0;
        
		/* Se elemina tabla */
        DROP TABLE migraoroplat;

		RETURN cCodRet;
    END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea sp "sp_migra_oro_plat_reporte", para obtener la informacion',
'DESCRIPCION: para poder generar el reporte mensual llamado MIGRA_ORO_PLAT_DDMMAAAA',
'AUTOR : Adrian Curiel',
'FECHA : 17/03/2023',
'BD    : intercard';

CREATE PROCEDURE "informix".sp_codprodaumentolinea(chempresa char(3))  
	RETURNING char (5),char(50);

DEFINE iSqlErr          		INTEGER;
DEFINE iIsamErr         		INTEGER;
DEFINE cInfoErr					CHAR(100);
DEFINE cCodret          		CHAR(5);
DEFINE cMensRet         		CHAR(50);
DEFINE cEmpresa          		CHAR(3);
DEFINE cnum_tarjeta				CHAR (20);
DEFINE csubbin                  CHAR(2); --Nueva variable
DEFINE dmnuevalineacredito		DECIMAL(18,2);
DEFINE dmaumlincred_lincredant	DECIMAL(18,2);
DEFINE cpermite_segmentacion	CHAR(1);
DEFINE icommit					INTEGER;
DEFINE vsegcodproductotarjeta 	CHAR(3);
DEFINE vseglimite_max 			DECIMAL(19,4);
DEFINE vExisteRegistro          INTEGER;
DEFINE vFechaCarga              DATE;

	--SET DEBUG FILE TO "/informix/LDBZ/sp_validaaumentolincred.out";
	--TRACE ON;
	
	-- Base de Datos: intercard
	-- Fecha de modificacion: 30 de Marzo de 2023
	-- Autor: Luis Daniel Bautista Zamora 
	-- Comentario: Se agregan validaciones para evitar extraer registros dobles en consulta con lÃ­mites de crÃ©ditos iguales debido a nuevo producto infinite.

LET cInfoErr 				= '';
LET cCodret 				= '00000';
LET cMensRet 				= 'Ejecucion sp_codprodaumentolinea exitosa.';
LET cEmpresa 				= chempresa;
LET cnum_tarjeta			= '';
LET csubbin                 = '';  --Se incializa variable
LET dmnuevalineacredito		= 0;
LET dmaumlincred_lincredant	= 0;
LET cpermite_segmentacion	= '';
LET icommit 				= 0;
LET vsegcodproductotarjeta 	= '';
LET vseglimite_max 			= 0;
LET vExisteRegistro         = 0;
LET vFechaCarga             = CURRENT;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensRet = 'Error en el proceso, validar.';
				--SET DEBUG FILE TO "/RESPALDOSNEW/sp_validaaumentolincred.out";
				--TRACE ON;
				RETURN cCodret,cMensRet;
			END IF;
		END EXCEPTION;
		
		--DROP TABLE IF EXISTS aumentoslineacredito;

/*-----------------------------------------------------------------------------------------------------------------
		PROCESO DE DESCARGA DE REGISTROS CON AUMENTO EN LINEA DE CRÃDITO DEL MES ANTERIOR (T-1):
-----------------------------------------------------------------------------------------------------------------*/

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT max(fecha_ejecucion)
			INTO vFechaCarga
		FROM intercard:bitacoraprocesosejec
		WHERE idproceso='CODPRODAUMENTOLINEA'
		AND estatus='TERMINADO';
		
		SELECT
			num_solicitud, status, lincred_sugerida, lincred_actual
		FROM bdicred:sd_bitacora_aumlincred
		WHERE fecha_status >= vFechaCarga
			AND status = 'AP'
			AND fecha_insert >= '01-01-1900'
		INTO TEMP sd_bitacora_aumlincred_temp WITH NO LOG;
		
		CREATE INDEX tmp_idx_numsoli  ON  sd_bitacora_aumlincred_temp(num_solicitud) ONLINE;
	
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_bitacora_aumlincred_temp; 
 
		SELECT 
			a.empresa, d.num_tarjeta AS num_tarjeta, b.status,
			b.lincred_sugerida AS nuevalineacredito, b.lincred_actual AS aumlincred_lincredant,monto_vencido, mto_venc_trasp				
		FROM intercard:sd_bitacora_aumlincred_temp AS b 
		INNER JOIN bdicred:sd_maesdos AS a ON b.num_solicitud = a.num_credito
		INNER JOIN bdicred:sd_maecred AS f ON a.num_credito = f.num_credito	
		INNER JOIN bdicred:sd_tarjeta AS d ON b.num_solicitud = d.num_credito
		INNER JOIN intercard:tarjeta AS e ON d.num_tarjeta = e.numtarjeta
		WHERE f.status_cred IN ('AA','E1') 
			AND d.tipo_tarjeta in ('T', 'A')
			AND d.status_tar = 'A'							 
			AND e.codstatustarjeta in ('ACT', 'BLO', 'BLT')
			AND e.codstatusasignada = 'SIA'
		INTO TEMP aumentoslineacredito WITH NO LOG;

/*-----------------------------------------------------------------------------------------------------------------
		PROCESO DE VALIDACIÃN DE LINEAS DE CRÃDITO:
-----------------------------------------------------------------------------------------------------------------*/
		 
			FOREACH WITH HOLD
					SELECT 
				num_tarjeta, nuevalineacredito, aumlincred_lincredant,num_tarjeta[7,8]
			INTO
				cnum_tarjeta,dmnuevalineacredito, dmaumlincred_lincredant, csubbin
			FROM "informix".aumentoslineacredito where  empresa = cEmpresa
			
		
			SELECT 
				distinct sp.permite_segmentacion         ,sp.codproductotarjeta,  limite_max 
				    INTO cpermite_segmentacion           ,vsegcodproductotarjeta, vseglimite_max
			FROM intercard:segmentoproducto sp
            INNER JOIN intercard:binproducto bp
            ON sp.codproductotarjeta=bp.codproductotarjeta
            INNER JOIN intercard:bines bi 
            ON bp.bin=bi.bin
			INNER JOIN aumentoslineacredito tmp
            ON  cnum_tarjeta[7,8]=(select pi.producto 
                from intercard:tipotarjeta tt
                join intercard:productoimagen pi
                on tt.clave = pi.clave
                where tt.bin = '426807'
                and pi.producto= csubbin)
			WHERE tipo_producto='C'
            AND bi.bin=cnum_tarjeta[1,6]
			and cnum_tarjeta[7,8]=bp.producto
            AND limite_max >= dmnuevalineacredito
            AND limite_min <= dmnuevalineacredito;
			
			/*select distinct d.permite_segmentacion, d.codproductotarjeta, d.limite_max
			INTO cpermite_segmentacion           ,vsegcodproductotarjeta, vseglimite_max
			from intercard:bines b
			join intercard:binproducto c
			on c.bin = b.bin
			join intercard:segmentoproducto d
			on d.codproductotarjeta = c.codproductotarjeta
			where c.producto = csubbin
			and c.bin = SUBSTR(cnum_tarjeta, 1, 6)
			and SUBSTR(cnum_tarjeta, 7, 2) =
			(
				select pi.producto 
				from intercard:tipotarjeta tt
				join intercard:productoimagen pi
				on tt.clave = pi.clave
				where tt.bin = '426807'
				and pi.producto = csubbin
			)
			and d.tipo_producto = 'C'
			and d.limite_max >= dmnuevalineacredito
			and d.limite_min <= dmnuevalineacredito;*/
			
			/*			
			--TRACE 'Segmentacion '||cpermite_segmentacion;	
			--TRACE 'Producto '||vsegcodproductotarjeta;
			--TRACE 'Limite '||vseglimite_max;*/
						
			LET vExisteRegistro = dbinfo("sqlca.sqlerrd2");
			
			BEGIN WORK;
			
				IF icommit = 1000
					THEN
						COMMIT WORK;
						LET icommit = 0;
						CONTINUE FOREACH;
					ELSE
				END IF;
	
				IF dmnuevalineacredito > vseglimite_max AND cpermite_segmentacion = 'V' AND vExisteRegistro > 0 THEN
				
						UPDATE "informix".tarjeta 
						SET codproductotarjeta = vsegcodproductotarjeta 
						WHERE numtarjeta = cnum_tarjeta;
						UPDATE "informix".bitacoracambiostarjeta 
						SET descvaloranterior = dmaumlincred_lincredant, descvalornuevo = dmnuevalineacredito 
						WHERE tarjeta = cnum_tarjeta AND fechacambio ::date >= today;
						
						LET icommit = icommit+2;
				
				ELIF dmaumlincred_lincredant!=dmnuevalineacredito AND vExisteRegistro > 0 THEN
				
						UPDATE "informix".tarjeta 
						SET codproductotarjeta = vsegcodproductotarjeta 
						WHERE numtarjeta = cnum_tarjeta;
						UPDATE "informix".bitacoracambiostarjeta SET descvaloranterior = dmaumlincred_lincredant, descvalornuevo = dmnuevalineacredito 
						WHERE tarjeta = cnum_tarjeta AND fechacambio ::date >= today;
					
						LET icommit = icommit+2;
					
					ELSE
						
						LET vExisteRegistro=0;
						--TRACE 'NO ESTOY HACIENDO NADA';
				END IF;
			COMMIT WORK;
		END FOREACH;
		
		BEGIN;
		INSERT INTO intercard:bitacoraprocesosejec (idproceso,fecha_ejecucion,fechahora_ultejecucion,estatus,descripcion,usuario)
			VALUES ('CODPRODAUMENTOLINEA',CURRENT,CURRENT,'TERMINADO','Proceso que valida codigo de producto en aumento de linea de credito tarjeta','informix');
		COMMIT;
		 
		RETURN cCodret,cMensRet;
		
		DROP TABLE IF EXISTS aumentoslineacredito;
		DROP TABLE IF EXISTS sd_bitacora_aumlincred_temp;
		
    END;

END PROCEDURE
DOCUMENT
'AUTOR: Edgar Ivan Cisneros Yescas',
'Proyecto: RQI 10 1017 ActualizaciÃ³n de producto INTERCARD',
'Fecha: 2018/05/04',
'BD: intercard';

CREATE PROCEDURE "informix".sp_rpt_trim_consultar_movs (
            pRUTA_ORIGEN VARCHAR(30),
            pRUTA_DESTINO VARCHAR(30),
            pRUTA_UNLOAD VARCHAR(30),
            pTipoReporte VARCHAR(15),
            pIdPlantilla CHAR(1),
            pFechaInicial DATETIME YEAR TO FRACTION(5),
            pFechaFinal DATETIME YEAR TO FRACTION(5)
    )
    RETURNING CHAR (5) AS CODIGO_RETORNO, CHAR(120) AS MENSAJE_RETORNO;	
    
    DEFINE SQLERR		INTEGER;
    DEFINE ISAM_ERR		INTEGER;
    DEFINE ERROR_INFO	VARCHAR(100);
	DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RETORNO CHAR(120);
	DEFINE RUTA_UNLOAD VARCHAR(30);
	DEFINE RUTA_ORIGEN VARCHAR(30);
	DEFINE RUTA_DESTINO VARCHAR(30);	
    DEFINE NOMBRE_UNL_ARCHIVO VARCHAR(20);
    DEFINE PREFIJO_SCRIPTS CHAR(4);
    DEFINE RPT_TARJ_PRESENTE VARCHAR(20);
    DEFINE RPT_TARJ_NO_PRESENTE VARCHAR(20);
    DEFINE RPT_TARJ_TAG VARCHAR(20);
    DEFINE RPT_TARJ_ATM VARCHAR(20);
    DEFINE RPT_TARJ_VENT VARCHAR(20);
    DEFINE CONTADOR_TRANSACCIONES SMALLINT;
    DEFINE SCRIPT_EJECUCION VARCHAR(30);    
    DEFINE vExecuteSQL LVARCHAR(4000);    
    DEFINE vCondicionesPlantilla LVARCHAR(2000);
    DEFINE pBusFechaInicial  DATE;
    DEFINE pBusFechaFinal DATE;
           
    LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RETORNO = 'Ejecucion exitosa.';
    LET RUTA_UNLOAD = '/RESPALDOSNEW/';
    LET RUTA_ORIGEN = '/resplogifx/';
    LET RUTA_DESTINO = '/resplogifx/';
    LET vExecuteSQL = '';
    LET RPT_TARJ_PRESENTE = 'TP_CAPTA';
    LET RPT_TARJ_NO_PRESENTE = 'TNP_CAPTA';
    LET RPT_TARJ_TAG = 'TAG_CAPTA';
    LET RPT_TARJ_ATM = 'ATM_CAPTA';
    LET RPT_TARJ_VENT = 'VENT_CAPTA';
    LET NOMBRE_UNL_ARCHIVO = '';
    LET PREFIJO_SCRIPTS = 'rpt_';
    LET CONTADOR_TRANSACCIONES = 1000;
    LET vCondicionesPlantilla = '';
    LET pBusFechaInicial =  '';
    LET pBusFechaFinal = '';
            
    --SET DEBUG FILE TO RUTA_ORIGEN || "ejec_sp_rpt_trim_consultar_movs.out";
    --TRACE ON;        
	
    BEGIN 
		
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO            
            SET DEBUG FILE TO RUTA_ORIGEN || "excepcion_sp_rpt_trim_consultar_movs.err.out";
            TRACE ON;            
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RETORNO = ERROR_INFO;
                RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
            END IF;            
        END EXCEPTION;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
    
        IF ( pTipoReporte = RPT_TARJ_PRESENTE ) THEN
            LET NOMBRE_UNL_ARCHIVO = 'ctes_tp_capta';
            LET SCRIPT_EJECUCION = 'script_trxs_tp.sql';
            LET vCondicionesPlantilla = " AND metodocaptura = '05' "|| 
                "  AND prodind = '02'  ";
        ELIF ( pTipoReporte = RPT_TARJ_NO_PRESENTE ) THEN
            LET NOMBRE_UNL_ARCHIVO = 'ctes_tnp_capta';
            LET SCRIPT_EJECUCION = 'script_trxs_tnp.sql';
            ------Excluir los clientes que ya estan registrados en el archivo tarjeta presente 
            ---Deben excluirse las transacciones con TAG
            LET vCondicionesPlantilla = " AND metodocaptura IN ('01','81')  " ||
            "  AND prodind = '02'  " ||
            "  AND tipotransaccionposdigitada <> 'TG' " ||
            "    AND t.numcliente NOT IN ( " ||
            "      SELECT  " ||                
            "           cliente " ||
            "       FROM info_reporte_trimestral  " ||
            "          WHERE plantilla = '1'  ) ";
        ELIF ( pTipoReporte = RPT_TARJ_TAG ) THEN
            LET NOMBRE_UNL_ARCHIVO = 'ctes_tag_capta';
            LET SCRIPT_EJECUCION = 'script_trxs_tag.sql';
            LET vCondicionesPlantilla = " AND metodocaptura IN ('01','81')  " ||
            "  AND prodind = '02'  " ||
            "  AND tipotransaccionposdigitada = 'TG' " ||
            "  AND codgironeg IN ('4784', '7523') " ||
            "    AND t.numcliente NOT IN ( " ||
            "      SELECT  " ||
            "           cliente " ||
            "       FROM info_reporte_trimestral  " ||
            "          WHERE plantilla IN ('1', '2') ) ";
        ELIF ( pTipoReporte = RPT_TARJ_ATM ) THEN
            LET NOMBRE_UNL_ARCHIVO = 'ctes_atm_capta';
            LET SCRIPT_EJECUCION = 'script_trxs_atm.sql';
            LET vCondicionesPlantilla = " AND prodind = '01'  " ||
            "  AND codtran = '01'  " ||
            "    AND t.numcliente NOT IN ( " ||
            "      SELECT  " ||
            "           cliente " ||
            "       FROM info_reporte_trimestral  " ||
            "          WHERE plantilla IN ( '1', '2', '3' ) ) ";
        ELIF ( pTipoReporte = RPT_TARJ_VENT ) THEN
            LET NOMBRE_UNL_ARCHIVO = 'ctes_vent_capta';
            LET SCRIPT_EJECUCION = 'script_trxs_vent.sql';        
        END IF
        
        IF ( pTipoReporte = RPT_TARJ_VENT ) THEN
        
            LET pBusFechaInicial = pFechaInicial::DATE;
            LET pBusFechaFinal = pFechaFinal::DATE;
        
--{-OPTIMIZACION STK202309

            LET vExecuteSQL	= '';
            LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD||NOMBRE_UNL_ARCHIVO||'.unl'||
                ' SELECT d.numcliente as inf_cliente, a.cuenta as inf_cuenta, '''||pIdPlantilla||''' as inf_plantilla' ||
                '   FROM bdicheq:sc_movhis_old a  ' ||
                '       LEFT JOIN bdicheq:sc_movhis b ' ||
                '           ON (a.empresa = b.empresa AND a.fech_alt = b.fech_alt) ' ||
                '       INNER JOIN bdicheq:sc_maechq c ' ||
                '           ON (a.cuenta = c.cuenta)  ' ||
                '       INNER JOIN intercard:tarjeta d  ' ||
                '           ON (a.num_tarjeta = d.numtarjeta)  ' ||
                ' WHERE a.fech_alt  BETWEEN '''||pBusFechaInicial||''' AND '''||pBusFechaFinal||''' '||
                --" WHERE a.fech_alt BETWEEN '05/10/2019'  AND '05/10/2019'  "||
                "   AND a.transacc IN ('0223', '0202') " ||
                "   AND a.num_tarjeta <> '' " ||
                '   AND c.status_cta = 1 ' ||
                "   AND d.codstatustarjeta = 'ACT' " ||                
                '   AND c.num_cte NOT IN  ( ' ||
                '    SELECT cliente  ' ||
                '       FROM info_reporte_trimestral  ' ||
                "       WHERE plantilla IN ('1', '2', '3', '4') ) " ||                
                '" >'||RUTA_ORIGEN||SCRIPT_EJECUCION;
    
            SYSTEM vExecuteSQL;
--OPTIMIZACION STK202309}

--{+OPTIMIZACION STK202309}

  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

  INSERT INTO info_paso_clientes
  SELECT {+AVOID_STMT_CACHE
        +INDEX(bdicheq:"informix".sc_movhis_old idx_movhis_old_reppitdcweb)
        +INDEX(intercard:"informix".tarjeta " 144_89")}
        d.numcliente as inf_cliente, a.cuenta as inf_cuenta, '5' as inf_plantilla
  FROM bdicheq:sc_movhis_old a,
  bdicheq:sc_maechq c,
  intercard:tarjeta d
     WHERE a.transacc in ('0202','0223')
--     AND a.fech_alt >= pBusFechaInicial AND a.fech_alt <= pBusFechaFinal
     AND a.fech_alt >= "01/08/2023" AND a.fech_alt <= "01/08/2023"
     AND a.num_tarjeta <> " "
     AND a.cuenta = c.cuenta
     AND c.status_cta = 1
     AND a.num_tarjeta = d.numtarjeta
     AND d.codstatustarjeta = 'ACT'
     AND not exists(
        SELECT i.cliente
          FROM info_reporte_trimestral i
        WHERE i.cliente = c.num_cte
          AND i.plantilla IN ('1', '2', '3', '4') );

--{+OPTIMIZACION STK202309}
            
        ELSE

            LET vExecuteSQL	= '';
            LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD||NOMBRE_UNL_ARCHIVO||'.unl'||
                ' SELECT t.numcliente as inf_cliente, \" \" as inf_cuenta, '''||pIdPlantilla||''' as inf_plantilla' ||
                ' FROM movimiento mov INNER JOIN tarjeta t '||
                ' ON (mov.numtarjeta = t.numtarjeta) '||
                'WHERE mov.fechahorainauth  BETWEEN '''||pFechaInicial||''' AND '''||pFechaFinal||''' '||
                --" WHERE mov.fechahorainauth  BETWEEN '2018-08-20 10:00:00.0000' AND '2018-08-20 10:30:00.0000' "||
                    " AND t.codstatustarjeta = 'ACT' " ||
                    " AND t.titular IN ('T', 'A') " ||
                    " AND mov.codigoiso = '00' " ||
                    " AND mov.formato = '0200' " ||
                    " AND SUBSTR (mov.numtarjeta,0,6) IN " ||
                    "    ( " ||
                    "      SELECT bin " ||                
                    "       FROM bines " ||
                    "      WHERE creditodebito = 'D' ) " || vCondicionesPlantilla ||
                ' UNION ' ||
                    ' SELECT t.numcliente as inf_cliente, \" \" as inf_cuenta ,'''||pIdPlantilla||''' as inf_plantilla' ||
                ' FROM movimientohistorico movh INNER JOIN tarjeta t '||
                ' ON (movh.numtarjeta = t.numtarjeta) '||
                'WHERE movh.fechahorainauth  BETWEEN '''||pFechaInicial||''' AND '''||pFechaFinal||''' '||
                --" WHERE movh.fechahorainauth  BETWEEN '2018-08-20 10:00:00.0000' AND '2018-08-20 10:30:00.0000' "||
                    " AND t.codstatustarjeta = 'ACT' " ||
                    " AND t.titular IN ('T', 'A') " ||
                    " AND movh.codigoiso = '00' " ||
                    " AND movh.formato = '0200' " ||
                    " AND SUBSTR (movh.numtarjeta,0,6) IN " ||
                    "    ( " ||
                    "      SELECT bin " ||
                    "         FROM bines " ||
                    "      WHERE creditodebito = 'D' ) "  || vCondicionesPlantilla ||
                    
                    '" >'||RUTA_ORIGEN||SCRIPT_EJECUCION;
                    
                SYSTEM vExecuteSQL;
           
--{-OPTIMIZACION STK202309
--       END IF           
---OPTIMIZACION STK202309}
           
        LET vExecuteSQL   ='';
        LET vExecuteSQL   ='chmod 777 '||RUTA_ORIGEN||SCRIPT_EJECUCION;
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL   ='';
        LET vExecuteSQL   ='dbaccess intercard '||RUTA_ORIGEN||SCRIPT_EJECUCION;
        SYSTEM vExecuteSQL;        
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD||
                          NOMBRE_UNL_ARCHIVO||'.unl' || "' delimiter '|' "|| '3'||
                          "; INSERT INTO info_paso_clientes" || ";"||'"'||' > '||PREFIJO_SCRIPTS||'reg_ctes_paso.txt';
        SYSTEM vExecuteSQL;        
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||PREFIJO_SCRIPTS||"reg_ctes_paso.txt -l "||PREFIJO_SCRIPTS||"err_reg_ctes.log -n "||CONTADOR_TRANSACCIONES||" -r";
        SYSTEM vExecuteSQL;  
        
        LET vExecuteSQL   = '';
        LET vExecuteSQL   =	'rm -f '||RUTA_ORIGEN||SCRIPT_EJECUCION;
        SYSTEM vExecuteSQL; 
        
        LET vExecuteSQL   = '';
        LET vExecuteSQL   =	'rm -f '||RUTA_UNLOAD||NOMBRE_UNL_ARCHIVO||'.unl';
        SYSTEM vExecuteSQL;
    END IF           
  

		RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
	END

END PROCEDURE
/*
-- Autor: [ agarciao@bancoppel.com ]
-- Fecha de creacion: 10.septiembre.2019
-- Base de datos: intercard
-- El procedimiento almacenado es utilizado por los jobs: 533_00, 533_01, 533_02, 533_03 y 533_04
-- Para obtener los movimientos de las fechas enviadas en el parametro y considerando el tipo de plantilla.
-- Descripcion:
-- Plantilla 1: Clientes con compra de tarjeta presente: sp_ctes_tdd_presente
-- Plantilla 2: Clientes con compra de tarjeta no presente: sp_ctes_tdd_no_presente
-- Plantilla 3: Clientes con compra TAG: sp_ctes_tdd_compratag
-- Plantilla 4: Clientes con retiros en cajeros automaticos: sp_ctes_tdd_retiros_atm
-- Plantilla 5: Clientes retiro o consulta de saldo en ventanilla: sp_ctes_tdd_ventanilla
-- Reporte de Conteo: El sp_reporte_trimestral_captacion borra la tabla info_reporte_trimestral

-- Modificado: Softtek / A.Canseco 09.2023
-- Optimizacion
*/
;

CREATE PROCEDURE "informix".sp_rpt_trim_registrar_clientes( pRUTA_ORIGEN VARCHAR(30), pRUTA_UNLOAD VARCHAR(30),
    pTipoPlantilla VARCHAR(15), pIdPlantilla CHAR(1) )
    
    RETURNING CHAR(6) as CODIGO_RETORNO, VARCHAR(80) as MENSAJE_RETORNO;
    
    DEFINE SQLERR		INTEGER;
    DEFINE ISAM_ERR		INTEGER;
    DEFINE ERROR_INFO	VARCHAR(100);
    DEFINE CODIGO_RETORNO CHAR(6);
    DEFINE MENSAJE_RETORNO VARCHAR(80);
    DEFINE PREFIJO_SCRIPTS CHAR(8);
    DEFINE CONTADOR_TRANSACCIONES SMALLINT;
    DEFINE vExecuteSQL CHAR(1150);
    
    LET CODIGO_RETORNO  = '00000';
    LET MENSAJE_RETORNO = 'PROCESO EXITOSO';
    LET PREFIJO_SCRIPTS = 'reptrim_';
    LET CONTADOR_TRANSACCIONES = 1000;
    
    --SET DEBUG FILE TO pRUTA_ORIGEN||"sp_rpt_trim_registrar_clientes.out";
    --TRACE ON;
        
    BEGIN
    
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO            
            SET DEBUG FILE TO pRUTA_ORIGEN || "excepcion_sp_rpt_trim_registrar_clientes.err.out";
            TRACE ON;            
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RETORNO = ERROR_INFO;
                RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
            END IF;
            
        END EXCEPTION; 

        
--{-OPTIMIZACION STK202309

        LET vExecuteSQL = '';
        LET vExecuteSQL  = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||pRUTA_UNLOAD||PREFIJO_SCRIPTS||'regs_clientes.unl ' ||    
        ' SELECT 0, '||pIdPlantilla||', cliente,'||
        '   LOWER(TRIM(correo_electronico)) correo_electronico,' ||
        '  CASE ' ||
        "     WHEN LENGTH (nombre1) < 3 THEN '****"||pTipoPlantilla||"*"||"nombre='||"||"TRIM(nombre2)"||
        "    ELSE '****"||pTipoPlantilla||"*"||"nombre='||"||"TRIM(nombre1)"||
        '  END AS titular ' ||
        ' FROM intercard:info_clientes_captacion ' ||
        "  WHERE plantilla = '"||pIdPlantilla||"'"||
        ' "> '||pRUTA_ORIGEN||PREFIJO_SCRIPTS||'script_regs_clientes.sql';    
        SYSTEM vExecuteSQL;

        LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess intercard '||pRUTA_ORIGEN||PREFIJO_SCRIPTS||'script_regs_clientes.sql';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "file '"||pRUTA_UNLOAD||PREFIJO_SCRIPTS||
                              'regs_clientes.unl' || "' delimiter '|' "|| '5'||
                              "; INSERT INTO info_reporte_trimestral" || ";"||'"'||' > '||PREFIJO_SCRIPTS||'file_reg_clientes.txt';
        SYSTEM vExecuteSQL;
        
        --Se ejecuta el dbload en intercard porque ahi esta creada la tabla tbl_paso_prom_mensual
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||PREFIJO_SCRIPTS||"file_reg_clientes.txt -l "||PREFIJO_SCRIPTS||"err_carga_ctes.log -n "||CONTADOR_TRANSACCIONES||" -r";
        SYSTEM vExecuteSQL;
        
        --Borrado de todos los archivos generados en el proceso
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||pRUTA_ORIGEN||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||pRUTA_UNLOAD||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;

--OPTIMIZACION STK202309}

--{+OPTIMIZACION STK202309}

 		SET ISOLATION TO DIRTY READ;
 		SET LOCK MODE TO WAIT 3;

		INSERT INTO info_reporte_trimestral
		SELECT {+AVOID_STMT_CACHE}
                0, pIdPlantilla, cliente,
  				LOWER(TRIM(correo_electronico)) correo_electronico,
  				CASE
    				WHEN LENGTH (nombre1) < 3 THEN "****"||pTipoPlantilla||"*nombre="||TRIM(nombre2)
    			ELSE "****"||pTipoPlantilla||"*nombre="||TRIM(nombre1)
  				END AS titular
		FROM intercard:info_clientes_captacion
	   WHERE plantilla = pIdPlantilla;

--{+OPTIMIZACION STK202309}

        RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO;
    
    END
    
END PROCEDURE
/*
-- Autor: [ agarciao@bancoppel.com ]
-- Fecha de creacion: 10.septiembre.2019
-- Base de datos: intercard
-- El procedimiento almacenado es utilizado por los jobs 533_00, 533_01, 533_02, 533_03 y 533_04
-- Registrar en la tabla el formato solicitado para los archivos .ready
-- Descripcion:
-- Plantilla 1: Clientes con compra de tarjeta presente: sp_ctes_tdd_presente
-- Plantilla 2: Clientes con compra de tarjeta no presente: sp_ctes_tdd_no_presente
-- Plantilla 3: Clientes con compra TAG: sp_ctes_tdd_compratag
-- Plantilla 4: Clientes con retiros en cajeros automaticos: sp_ctes_tdd_retiros_atm
-- Plantilla 5: Clientes retiro o consulta de saldo en ventanilla: sp_ctes_tdd_ventanilla
-- Reporte de Conteo: El sp_reporte_trimestral_captacion borra la tabla info_reporte_trimestral

-- Modificado: Softtek / A.Canseco 09.2023
-- Optimizacion
*/
;

CREATE PROCEDURE "informix".sp_elimina_mj_vau()
RETURNING CHAR(5) AS CodigoRetorno, CHAR(160) AS mensaje;
----DefiniciÃÂÃÂ³n de variables de control del proceso


	DEFINE vCodigoRetorno			CHAR(5);
	DEFINE vMensaje 				CHAR(160);
	DEFINE vCommit  				VARCHAR(50);
	DEFINE RUTA						VARCHAR(50);

	DEFINE vExecuteSQL		    	LVARCHAR(1000);
	DEFINE SQLERR 					INTEGER;
	DEFINE ISAM_ERR 				INTEGER;
	DEFINE ERROR_INFO 				VARCHAR(80);
----Definicion de variables de evaluacion
	DEFINE vNumtarjeta VARCHAR(16);
	DEFINE vFechaexp          		VARCHAR(4);
    DEFINE vNumtarjetasustituta		VARCHAR(16);
	DEFINE vFechaexpsustita   		VARCHAR(4);
	DEFINE vreps INTEGER;
	DEFINE vDia						VARCHAR(2);
	DEFINE vMes						VARCHAR(2);
	DEFINE vAnio					VARCHAR(4);
	DEFINE HORA_MINUTO_SEG_INICIAL  VARCHAR(14);
	DEFINE HORA_MINUTO_SEG_FINAL    VARCHAR(14);
	DEFINE vFechaInicial			VARCHAR(25);
	DEFINE vFechaFinal				VARCHAR(25);
-----------------------------------------------------****-----------------
----Inicalizacion de variables de control 


	LET vCodigoRetorno ="";
	LET vMensaje ="";
	LET vCommit ="";
	LET RUTA = '/home/c90296115/';
	LET vExecuteSQL	='';
	LET SQLERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
----Inicializacion de variables de evaluaciÃ³n  
	LET vNumtarjeta ="";
	LET vFechaexp ='';    	
	LET vNumtarjetasustituta = '';	
	LET vFechaexpsustita =''; 
-----
	LET vDia ='';
	LET vMes = '';
	LET vAnio= '';
	LET HORA_MINUTO_SEG_INICIAL = '00:00:00.00000';
	LET HORA_MINUTO_SEG_FINAL = '23:59:59.99999';
	LET vFechaInicial='';
	LET vFechaFinal ='';
	
	
	 
	 
	 
	 --SET DEBUG FILE TO RUTA||"vau_busca_pasado_g.out";
	--TRACE ON;
	 
	 BEGIN
	
		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
				
		--SET DEBUG FILE TO RUTA || "sp_elimina_mj_vau.unl.out" WITH APPEND;
		--TRACE ON;
				
				IF ( SQLERR <> 0 ) THEN
					LET vCodigoRetorno = SQLERR;
					LET vMensaje = ERROR_INFO||' '||vMensaje;                
					RETURN vCodigoRetorno, vMensaje;
				END IF;
				
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		
--Obtiene la fecha del dia 
		SELECT SUBSTR(fecha_hoy,4,2),
			   SUBSTR(fecha_hoy,1,2),
			    SUBSTR(fecha_hoy,7,4)
             INTO vDia, vMes, vAnio
        FROM bdinteg:si_fechas
                WHERE empresa = '001';

		LET vFechaInicial = vAnio||'-'||vMes||'-'||vDia||' '||HORA_MINUTO_SEG_INICIAL;
		LET vFechaFinal = vAnio||'-'||vMes||'-'||vDia||' '||HORA_MINUTO_SEG_FINAL;	
-------------------------------------------------Trae sus_tar 
		SELECT numtarjetasustituta AS numtar, fechaexp
		FROM intercard:tbl_tarjetas_vau_final
		WHERE identificadorvau = "A"
		INTO TEMP j_vau WITH NO LOG;
-----------------De las actualizaciones en la tab_vau_final, valida las tar_sus en bitacora
		SELECT numtar
		FROM j_vau AS td_tarsus, intercard:bitacoracambiosstatustarjeta AS bita
		WHERE td_tarsus.numtar = bita.tarjeta
		AND bita.codstatustarjetanvo in ('CAN', 'DES', 'EXT', 'ROB', 'FAL', 'DAN')
		AND fechahora BETWEEN vFechaInicial AND vFechaFinal
		INTO TEMP bt_tarsus WITH NO LOG;
			
			
-------------------------------------------------Trae los datos de las tarjetas que se repiten en numtar y sustar
		SELECT numtarjeta,fechaexp, numtarjetasustituta, fechaexpsustituta
		FROM tbl_tarjetas_vau_final as final, bt_tarsus as fil
		WHERE final.numtarjetasustituta = fil.numtar
		INTO TEMP f_vau WITH NO LOG;
-------------------------------------------------Elimina los registros en tarjetasF_vau por vtarjeta sustituta

		
		
		
		SET ISOLATION TO DIRTY READ;
		FOREACH tarjetas WITH HOLD FOR
			
				
					SELECT numtarjetasustituta 
					INTO vNumtarjetasustituta
					FROM f_vau
					
		DELETE FROM tbl_tarjetas_vau_final WHERE numtarjetasustituta = vNumtarjetasustituta;
					
						
			
		END FOREACH
					
-----------------------------------------------Inserta en tab_auxiliar
		TRUNCATE TABLE intercard:valida_mj;
		
	
		FOREACH tarjetas WITH HOLD FOR
			
				
					SELECT numtarjeta,fechaexp, numtarjetasustituta, fechaexpsustituta
					INTO vNumtarjeta, vFechaexp, vNumtarjetasustituta, vFechaexpsustita
					FROM f_vau
					
					
					INSERT INTO informix.valida_mj(numtarjeta, fechaexp, numtarjetasustituta, fechaexpsustituta) 
			VALUES(vNumtarjeta, vFechaexp, vNumtarjetasustituta, vFechaexpsustita);
						
			
		END FOREACH

	------------------------------------------------------------------Inserta lo borrado en C


		SET ISOLATION TO DIRTY READ;
		FOREACH insert_tar_j WITH HOLD FOR
		
		SELECT numtarjetasustituta, fechaexpsustituta, numtarjeta , fechaexp
		INTO  vNumtarjetasustituta, vFechaexpsustita, vNumtarjeta,vFechaexp
		FROM valida_mj 
	
		IF (  vNumtarjetasustituta = vNumtarjetasustituta ) THEN 
		---no insertes en C la tar_sus  e inserta la num_tar en C 
			INSERT INTO tbl_tarjetas_vau_final(empresa, numtarjeta, fechaexp, numtarjetasustituta, fechaexpsustituta, identificadorvau, filerdetalle)
				VALUES('001',vNumtarjeta, vFechaexp, null, null, 'C', NULL);
		ELSE 
		
		INSERT INTO tbl_tarjetas_vau_final(empresa, numtarjeta, fechaexp, numtarjetasustituta, fechaexpsustituta, identificadorvau, filerdetalle)
				VALUES('001',vNumtarjetasustituta, vFechaexpsustita, null, null, 'C', NULL);
		
		END IF;
		
			END FOREACH
		
		LET vCodigoRetorno = '00000';
		LET vMensaje = 'Proceso exitoso';
		RETURN vCodigoRetorno,vMensaje;
		
		
	 END
END PROCEDURE
DOCUMENT
'Operacion TI soporte 1er Nivel Servidores Distribuidos| Gerencia Mantenimiento I',
'Autor: Miguel Angel Lopez Galvan ',
'Fecha de creacion:24/11/2023',
'Base de datos: intercard',
'RQI 32 332 - OPT - OptimizaciÃ³n sp_carga_diaria_vau , buscapasado_vau y creaciÃ³n sp_elimina_mj_vau y tabla valida_mj',
'Descripcion: Mitiga los reject code J y M '
;

CREATE PROCEDURE "informix".busca_pasadovau()
RETURNING CHAR(5) AS CodigoRetorno, CHAR(160) AS mensaje;
----Definicion de variables de control del proceso


	DEFINE vCodigoRetorno			CHAR(5);
	DEFINE vMensaje 				CHAR(160);
	DEFINE vCommit  				VARCHAR(50);
	DEFINE RUTA						VARCHAR(50);

	DEFINE vExecuteSQL		    	LVARCHAR(1000);
	DEFINE SQLERR 					INTEGER;
	DEFINE ISAM_ERR 				INTEGER;
	DEFINE ERROR_INFO 				VARCHAR(80);
----Definicion de variables de evaluacion
	DEFINE vNumtarjeta VARCHAR(16);
	DEFINE v2tarjeta	VARCHAR(16);
	DEFINE vreps INTEGER;
-----------------------------------------------------****-----------------
----Inicalizacion de variables de control 


	LET vCodigoRetorno ="";
	LET vMensaje ="";
	LET vCommit ="";
	LET RUTA = '/RESPALDOSNEW/MALG';
	LET vExecuteSQL	='';
	LET SQLERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
----Inicializacion de variables de evaluacion 
	LET vNumtarjeta ="";
	LET vreps =0;
-----------------------------------------------------------
	 
	 --SET DEBUG FILE TO RUTA||"vau_busca_pasado_g.out";
	--TRACE ON;
	 
	 BEGIN
	
		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
				
		--SET DEBUG FILE TO RUTA || "vau_carga_diaria_int.err.out" WITH APPEND;
		--TRACE ON;
				
				IF ( SQLERR <> 0 ) THEN
					LET vCodigoRetorno = SQLERR;
					LET vMensaje = ERROR_INFO||' '||vMensaje;                
					RETURN vCodigoRetorno, vMensaje;
				END IF;
				
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--Obtiene el numero de  afectaciones para realizar los commits 
		SELECT valores
			INTO vCommit
		FROM "informix".tbl_inter_parametros
		WHERE empresa = '001' 
		AND cond_busqueda = 'Commits_vau';

-------------------------------------------------Valida lo insertado en tab_final y busca en el pasado en bitacora.
	SELECT tbf.numtarjeta
	FROM intercard:bitacoracambiosstatustarjeta as bt,  intercard:tbl_tarjetas_vau_final as tbf
	WHERE bt.tarjeta= tbf.numtarjeta
	AND codigoerror in ('00')
	AND fechahora < today
	AND codstatustarjetanvo NOT IN ('BLT', 'BLO')
	INTO TEMP pasado_vau WITH NO LOG;
-------------------------------------------------

SET ISOLATION TO DIRTY READ;
FOREACH tarjetas WITH HOLD FOR
	
			SELECT numtarjeta
			INTO vNumtarjeta
			FROM pasado_vau
			

	DELETE intercard:tbl_tarjetas_vau_final where numtarjeta =  vNumtarjeta;

	
END FOREACH
		
		LET vCodigoRetorno = '00000';
		LET vMensaje = 'Proceso exitoso';
		RETURN vCodigoRetorno,vMensaje;
		
		
	 END
END PROCEDURE
DOCUMENT
'Operacion TI soporte 1er Nivel Servidores Distribuidos | Gerencia Mantenimiento I',
'Autor: Miguel Angel Lopez Galvan ',
'Fecha de creacion: 18 de septiembre del 2023',
'Base de datos: intercard',
'RQI 32 -262 - OptimizaciÃÂ³n de sp_carga_diaria_vau y creaciÃÂ³n sp_buscapasado_vau',
'Descripcion: Busca desde tab final si se registro en la bitacora esa tarjeta en el pasado',
'MODIFICO: #5 Miguel Angel Lopez Galvan',
'INC 32 016 - AtenciÃ³n a sp: busca_pasadovau por error y cambio de orden de ejecuciÃ³n en sp_caraga_diaria_vau',
'Fecha:02-01-2024';

CREATE PROCEDURE "informix".sp_carga_diaria_vau()
RETURNING CHAR(5) AS CodigoRetorno, CHAR(160) AS mensaje;
	
	--Definicion de variables
	DEFINE vCodigoRetorno			CHAR(5);
	DEFINE vMensaje 				CHAR(160);
	DEFINE vCodigoRetornoPeriodos	CHAR(5);
	DEFINE vMensajePeriodos			CHAR(160);
	DEFINE vCodigoRetornoArchivo	CHAR(5);
	DEFINE vMensajeArchivo			CHAR(160);
	DEFINE RUTA						VARCHAR(50);
	DEFINE vNumtarjeta          	VARCHAR(16);
	DEFINE vFechaexp          		VARCHAR(4);
    DEFINE vNumtarjetasustituta		VARCHAR(16);
	DEFINE vFechaexpsustita   		VARCHAR(4);
	DEFINE vCodstatustarjeta		CHAR(3);
	DEFINE vFechaInicial			VARCHAR(25);
	DEFINE vFechaFinal				VARCHAR(25);
	DEFINE vFechaIntegral			DATE;
	DEFINE vCommit  				VARCHAR(50);
	DEFINE vConteoRegistros 		INTEGER;
	DEFINE vIniciaTransaccion   	CHAR(1);
	DEFINE vDia						VARCHAR(2);
	DEFINE vMes						VARCHAR(2);
	DEFINE vAnio					VARCHAR(4);
	DEFINE HORA_MINUTO_SEG_INICIAL  VARCHAR(14);
	DEFINE HORA_MINUTO_SEG_FINAL    VARCHAR(14);
	DEFINE vExecuteSQL		    	LVARCHAR(1000);
	DEFINE SQLERR 					INTEGER;
    DEFINE ISAM_ERR 				INTEGER;
    DEFINE ERROR_INFO 				VARCHAR(80);
	
	--Inicializacion de variables
	LET vCodigoRetorno = '';
	LET vMensaje = '';
	LET vCodigoRetornoPeriodos= '';
	LET vMensajePeriodos = '';			
	LET vCodigoRetornoArchivo='';
	LET vMensajeArchivo='';
	LET RUTA = '/home/c90296115/';
	LET vNumtarjeta ='';      
	LET vFechaexp ='';    	
	LET vNumtarjetasustituta = '';	
	LET vFechaexpsustita =''; 
	LET vCodstatustarjeta ='';
	LET vFechaInicial='';
	LET vFechaFinal ='';
	LET vFechaIntegral ='';
	LET vConteoRegistros = 0;
	LET vCommit = '';
	LET vIniciaTransaccion = '';
	LET vDia ='';
	LET vMes = '';
	LET vAnio= '';
	LET HORA_MINUTO_SEG_INICIAL = '00:00:00.00000';
	LET HORA_MINUTO_SEG_FINAL = '23:59:59.99999';
	
	LET vExecuteSQL	='';
	LET SQLERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
	
	
	--SET DEBUG FILE TO RUTA||"vau_debug_carga_diaria.out";
	--TRACE ON;

	BEGIN
	
		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
				
				--SET DEBUG FILE TO RUTA || "vau_carga_diaria.err.out" WITH APPEND;
				--TRACE ON;
				
				IF(vConteoRegistros > 0 OR vIniciaTransaccion = 'V')THEN
					COMMIT WORK;
				END IF
				
				IF ( SQLERR <> 0 ) THEN
					LET vCodigoRetorno = SQLERR;
					LET vMensaje = ERROR_INFO||' '||vMensaje;                
					RETURN vCodigoRetorno, vMensaje;
				END IF;
				
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--Obtiene el numero de  afectaciones para realizar los commits 
		SELECT valores
			INTO vCommit
		FROM "informix".tbl_inter_parametros
		WHERE empresa = '001' 
		AND cond_busqueda = 'Commits_vau';
		
		--Borra el contenido de la tabla
		TRUNCATE TABLE "informix".tbl_tarjetas_vau_final DROP STORAGE;
		
		LET vIniciaTransaccion = 'F';
		
		--Obtiene la fecha del dia 
		SELECT SUBSTR(fecha_hoy,4,2),
			   SUBSTR(fecha_hoy,1,2),
			    SUBSTR(fecha_hoy,7,4)
             INTO vDia, vMes, vAnio
        FROM bdinteg:si_fechas
                WHERE empresa = '001';
        
		LET vFechaInicial = vAnio||'-'||vMes||'-'||vDia||' '||HORA_MINUTO_SEG_INICIAL;
		LET vFechaFinal = vAnio||'-'||vMes||'-'||vDia||' '||HORA_MINUTO_SEG_FINAL;			


		--------------------------------------------------------Trae tarjetas de bitacora de ese dia con la sig condiciones.
			
			
				SELECT DISTINCT tarjeta
				FROM intercard:bitacoracambiosstatustarjeta 
					WHERE  fechahora BETWEEN vFechaInicial AND vFechaFinal
					AND codigoerror in ('00')
					AND codstatustarjetaorig NOT IN ('CAN', 'DES', 'EXT', 'ROB', 'FAL', 'DAN')
					AND codstatustarjetanvo IN ('CAN', 'DES', 'EXT', 'ROB', 'FAL', 'DAN')
			INTO TEMP Bitacoratmp1 WITH NO LOG;
			

		-----------------------------------------------------------Trae los datos de tarjeta
					
			SELECT tar.numtarjeta, tar.fechaexp,tar.numtarjetasustituta
				FROM intercard:tarjeta AS tar ,Bitacoratmp1 AS bittm
					WHERE bittm.tarjeta = tar.numtarjeta
					INTO TEMP tartemp WITH NO LOG;
			
			SELECT  * FROM tartemp
				INTO TEMP Dorigen_vau WITH NO LOG;
				
			

		-----------------------------------------------------------> Comienza proceso de asiganciÃÂÃÂ³n de indicadores
		SET ISOLATION TO DIRTY READ;
		FOREACH tarjetas WITH HOLD FOR
							
		SELECT  numtarjeta, fechaexp, numtarjetasustituta
			INTO vNumtarjeta, vFechaexp, vNumtarjetasustituta
			FROM Dorigen_vau 
				
				
			IF (vNumtarjetasustituta is null)THEN
			
					
				IF (vIniciaTransaccion = 'F') THEN 
					BEGIN WORK;
					LET vIniciaTransaccion = 'V';
				END IF;
				
			------------------------------------------------------------------------------------Identificadores 'C'	
				--Inserta registros en la tabla final		
				INSERT INTO "informix".tbl_tarjetas_vau_final (empresa, numtarjeta, fechaexp, numtarjetasustituta, fechaexpsustituta, identificadorvau, filerdetalle)
					VALUES( '001', vNumtarjeta, vFechaexp, NULL, NULL,'C',NULL);
					
				LET vConteoRegistros = vConteoRegistros + 1;
					
				IF (vConteoRegistros >= vCommit) THEN
					COMMIT WORK;
					LET vConteoRegistros = 0;
					LET vIniciaTransaccion = 'F';
					CONTINUE FOREACH;
				END IF
			------------------------------------------------------------------------------------Identificadores 'A'
			ELSE  
			
				IF (vIniciaTransaccion = 'F') THEN 
					BEGIN WORK;
					LET vIniciaTransaccion = 'V';
				END IF;
				
								--Obtiene la fecha de expiracion de la tarjeta sustituta
				SELECT fechaexp 
					INTO vFechaexpsustita
				FROM "informix".tarjeta
				WHERE numtarjeta = vNumtarjetasustituta;
				
				
				--Inserta registros en la tabla final		
				INSERT INTO "informix".tbl_tarjetas_vau_final (empresa, numtarjeta, fechaexp, numtarjetasustituta, fechaexpsustituta, identificadorvau, filerdetalle)
					VALUES( '001', vNumtarjeta, vFechaexp, vNumtarjetasustituta, vFechaexpsustita,'A', NULL);
					
				LET vConteoRegistros = vConteoRegistros + 1;
				IF (vConteoRegistros >= vCommit) THEN
					COMMIT WORK;
					LET vConteoRegistros = 0;
					LET vIniciaTransaccion = 'F';
					CONTINUE FOREACH;
				END IF
			END IF
		END FOREACH
			
		--Cierre de bloque de transacciones en caso de que se cumplan las condiciones del if	
		IF(vConteoRegistros > 0 OR vIniciaTransaccion = 'V')THEN
			COMMIT WORK;
		END IF
			
		--Actualizacion de estadisticas
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".tbl_tarjetas_vau_final;
		
				------------------------------------------------Ejecuta sp para omitir reject code  J y M
		EXECUTE PROCEDURE "informix".sp_elimina_mj_vau()
		INTO vCodigoRetornoArchivo, vMensajeArchivo;
		
		
				--Ejecuta sp para omitir los reject code W 
		EXECUTE PROCEDURE "informix".busca_pasadovau()
		INTO vCodigoRetornoArchivo, vMensajeArchivo;
		
		
		--Ejecuta sp para generar archivos con la informacion
		EXECUTE PROCEDURE "informix".sp_rpt_vau()
		INTO vCodigoRetornoArchivo, vMensajeArchivo;
		
		
		IF(vCodigoRetornoArchivo <> '00000')THEN
			LET vCodigoRetorno = '00002';
			LET vMensaje = 'Error al generar archivos';
			RETURN vCodigoRetorno, vMensaje;
		END IF
			
		LET vCodigoRetorno = '00000';
		LET vMensaje = 'Proceso exitoso';
		RETURN vCodigoRetorno,vMensaje;
			
	END
END PROCEDURE
DOCUMENT
'Coordinacion de Tarjetas e Interfaces Transaccionales | Gerencia Mantenimiento I',
'Autor: Kenya Itzel Alonso Sanchez',
'Fecha de creacion: 19 de octubre del 2021',
'Base de datos: intercard',
'RQM 10 1425 - Implementacion  Herramienta VAU',
'Descripcion: SPL que genera reporte de forma diaria de tarjetas con estatus final para VAU.',
'MODIFICO: #2 Miguel Angel Lopez Galvan',
'RQM 32 247 -  ActualizaciÃÂ³n sp_carga_diaria_vau, con nueva regla de negocio',
'Fecha: 08 de Agosto de 2023',
'MODIFICO: #3 Miguel Angel Lopez Galvan',
'RQI 32 -262 - Optimizacion de sp_carga_diaria_vau y creaciÃÂ³n sp_buscapasado_vau',
'Fecha:18-09-2023 ',
'MODIFICO: #4 Miguel Angel Lopez Galvan',
'RQI 32 332 - OPT - OptimizaciÃÂ³n sp_carga_diaria_vau , buscapasado_vau y creaciÃÂ³n sp_elimina_mj_vau y tabla valida_mj',
'Fecha:05-12-2023 ',
'MODIFICO: #5 Miguel Angel Lopez Galvan',
'INC 32 016 - AtenciÃ³n a sp: busca_pasadovau por error y cambio de orden de ejecuciÃ³n en sp_caraga_diaria_vau',
'Fecha:02-01-2024';

CREATE PROCEDURE "informix".sp_monitor_rst()
RETURNING CHAR(5) AS rCodigoRetorno, CHAR(160) AS mensaje, DATETIME YEAR TO FRACTION(3) AS fechaInicial, DATETIME YEAR TO FRACTION(3) AS fechaFinal;
    
    DEFINE vDescripcion	            VARCHAR(20);
    DEFINE vCodigoiso	            VARCHAR(2);
    DEFINE vMotivo 		            VARCHAR(70);
    DEFINE vTotalRST     	        SMALLINT;
    DEFINE vTotalMov     	        SMALLINT;
    DEFINE vEstatusOTP              CHAR(1);
    DEFINE vTotalTransaccionesRST   SMALLINT;
    DEFINE vTotalTransaccionesMov   SMALLINT;
    DEFINE vFechaInicial			DATETIME YEAR TO FRACTION(3);
    DEFINE RUTA						VARCHAR(100);
    --DEFINE NOMBRE_ARCHIVO			VARCHAR(35);
    DEFINE SCRIPT_EJECUCION1		VARCHAR(35);
    DEFINE SCRIPT_EJECUCION2		VARCHAR(35);
    DEFINE ARCHIVO_RST				VARCHAR(35);
    DEFINE ARCHIVO_INTERCARD		VARCHAR(35);
    DEFINE vExecuteSQL				LVARCHAR(1000);
    DEFINE SQLERR 					INTEGER;
    DEFINE ISAM_ERR 				INTEGER;
    DEFINE ERROR_INFO 				VARCHAR(80);
    DEFINE vCodigoRetorno           CHAR(5);
    DEFINE vMensaje		            CHAR(160);
	DEFINE vPrefijo                 VARCHAR(5);
    DEFINE vFechaFinal              DATETIME YEAR TO FRACTION(3);
	DEFINE vCommit  				INTEGER;
	DEFINE vConteoRegistros 		INTEGER;
	DEFINE vIniciaTransaccion   	CHAR(1);
	

    LET vDescripcion = '';
    LET vMotivo = '';
    LET vTotalRST = 0;
    LET vTotalMov = 0;
    LET vFechaInicial = current;
    LET vCodigoiso = '';
    LET vEstatusOTP = '';
    LET vTotalTransaccionesRST= 0;
    LET vTotalTransaccionesMov= 0;

    LET RUTA = '/RESPALDOSNEW/';
    --LET NOMBRE_ARCHIVO = 'Monitor_txn_rst.txt';
    LET ARCHIVO_RST = 'registros_claves_retiro.unl ';
    LET ARCHIVO_INTERCARD = 'registros_movimiento.unl ';
    LET SCRIPT_EJECUCION1 = 'ejec_script_clavesretiro.sql';
    LET SCRIPT_EJECUCION2 = 'ejec_script_movimiento.sql';
    LET vExecuteSQL = '';

    LET vCodigoRetorno = '';
    LET vMensaje = '';
	
	LET vCommit = 10;
    LET vConteoRegistros = 0;
    LET vIniciaTransaccion='';
	
	LET vPrefijo = 'mrst_';
    LET vFechaFinal = current;
    
    
    --SET DEBUG FILE TO RUTA||vPrefijo||"monitor_rst.out";
	--TRACE ON;    
		
	BEGIN 
    
		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
				
				SET DEBUG FILE TO RUTA || "excepcion_sp_monitor_rst.err.out";
				TRACE ON;
				
												
				IF ( SQLERR <> 0 ) THEN
					LET vCodigoRetorno = SQLERR;
					LET vMensaje = ERROR_INFO;                
					RETURN vCodigoRetorno, vMensaje, vFechaInicial, vFechaFinal;
				END IF;
				
		END EXCEPTION;
		
		
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		TRUNCATE TABLE intercard:"informix".tbl_monitor_rst DROP STORAGE;
		TRUNCATE TABLE intercard:"informix".tbl_monitor_rst_movimiento DROP STORAGE;
		
		--Obtiene la fecha
		SELECT CURRENT - 30 UNITS MINUTE
			INTO vFechaInicial
		FROM bdinteg:"informix".si_fechas
		WHERE empresa = '001';
		
		
		SELECT count(*)
				INTO vTotalTransaccionesRST
		FROM bdirst:"informix".claves_retiro
			WHERE cr_alta_fecha BETWEEN vFechaInicial AND CURRENT;
			
		SELECT count(*)
				INTO vTotalTransaccionesMov
		FROM intercard:"informix".movimiento
			WHERE fechahorainauth BETWEEN vFechaInicial AND CURRENT
			AND tipoctadestino = '71'
			AND codtran = '01'
			AND prodind = '01'
			AND movreversado = 'F'
			AND formato = '0200';
					
			
		LET vIniciaTransaccion = 'F';
		
		IF (vTotalTransaccionesRST > 0) THEN
			FOREACH monitorRST WITH HOLD FOR
				
				SELECT a.cr_status, b.cat_descripcion_status,count(*)
					INTO vEstatusOTP, vDescripcion, vTotalRST
				FROM bdirst:"informix".claves_retiro a 
				INNER JOIN bdirst:"informix".cat_status b
				ON( a.cr_status = b.cat_cod_status)
					WHERE cr_alta_fecha BETWEEN vFechaInicial AND CURRENT
				GROUP BY a.cr_status, b.cat_descripcion_status
				
				IF (vIniciaTransaccion = 'F') THEN 
					BEGIN WORK;
					LET vIniciaTransaccion = 'V';
				END IF;
				
				INSERT INTO intercard:"informix".tbl_monitor_rst
					VALUES (vEstatusOTP,vDescripcion, vTotalRST);
					
				LET vConteoRegistros = vConteoRegistros + 1;
				
				IF (vConteoRegistros >= vCommit) THEN
					COMMIT WORK;
					LET vConteoRegistros = 0;
					LET vIniciaTransaccion = 'F';
					CONTINUE FOREACH;
				END IF
				
		END FOREACH
			
		ELSE 
			
			INSERT INTO intercard:"informix".tbl_monitor_rst
				VALUES ("-", "No hay trancciones de retiro sin tarjeta",0);
			
			LET vConteoRegistros = vConteoRegistros + 1;
        
			IF (vConteoRegistros >= vCommit) THEN
				COMMIT WORK;
				LET vConteoRegistros = 0;
				LET vIniciaTransaccion = 'F';
				
			END IF
		
		END IF			
		
		IF(vConteoRegistros = 0 OR vIniciaTransaccion = 'V')THEN --Se cambia validacion para que cuando no encuentre registros termine la transaccion y no devuelva un error -255
			COMMIT WORK;
		END IF
			
		LET vIniciaTransaccion = 'F';
			
		IF (vTotalTransaccionesMov > 0 ) THEN
			FOREACH movimiento WITH HOLD FOR
			 
				SELECT codigoiso, motivo, count(*)
					INTO vCodigoiso, vMotivo, vTotalMov
				FROM intercard:"informix".movimiento
					WHERE fechahorainauth BETWEEN vFechaInicial AND CURRENT
					AND tipoctadestino = '71'
					AND codtran = '01'
					AND prodind = '01'
					AND movreversado = 'F'
					AND formato = '0200'
				GROUP BY codigoiso, motivo
				IF (vCodigoiso = '00') THEN
					
					IF (vIniciaTransaccion = 'F') THEN 
						BEGIN WORK;
						LET vIniciaTransaccion = 'V';
					END IF;
				
										
					INSERT INTO intercard:"informix".tbl_monitor_rst_movimiento
						VALUES (vCodigoiso, "Transaccion aprobada", vTotalMov);
						
					LET vConteoRegistros = vConteoRegistros + 1;
					
					IF(vConteoRegistros > 0 OR vIniciaTransaccion = 'V')THEN
						COMMIT WORK;
					END IF
			
					
					ELSE
						IF (vIniciaTransaccion = 'F') THEN 
							BEGIN WORK;
							LET vIniciaTransaccion = 'V';
						END IF;
						
						INSERT INTO intercard:"informix".tbl_monitor_rst_movimiento
							VALUES (vCodigoiso, vMotivo, vTotalMov);
						
						LET vConteoRegistros = vConteoRegistros + 1;
						
						IF (vConteoRegistros >= vCommit) THEN
							COMMIT WORK;
							LET vConteoRegistros = 0;
							LET vIniciaTransaccion = 'F';
							CONTINUE FOREACH;
						END IF
				END IF
					
					
			END FOREACH
		ELSE
				IF (vIniciaTransaccion = 'F') THEN 
						BEGIN WORK;
						LET vIniciaTransaccion = 'V';
				END IF;
			
				INSERT INTO intercard:"informix".tbl_monitor_rst_movimiento
					VALUES ("-", "No hay transacciones de retiro sin tarjeta", 0);
				
				LET vConteoRegistros = vConteoRegistros + 1;
						
				IF (vConteoRegistros >= vCommit) THEN
					COMMIT WORK;
					LET vConteoRegistros = 0;
					LET vIniciaTransaccion = 'F';
						
				END IF
				
				IF(vConteoRegistros > 0 OR vIniciaTransaccion = 'V')THEN
					COMMIT WORK;
				END IF
			
		
		END IF
		
		
		--GeneraciÃÂ³n de archivo
				
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA||vPrefijo||ARCHIVO_RST||
		'SELECT * FROM intercard:"informix".tbl_monitor_rst;" >'||RUTA||vPrefijo||SCRIPT_EJECUCION1;
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA||vPrefijo||ARCHIVO_INTERCARD||
		'SELECT * FROM intercard:"informix".tbl_monitor_rst_movimiento;" >'||RUTA||vPrefijo||SCRIPT_EJECUCION2;
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'dbaccess intercard '||RUTA||vPrefijo||SCRIPT_EJECUCION1;
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'dbaccess intercard '||RUTA||vPrefijo||SCRIPT_EJECUCION2;
		SYSTEM vExecuteSQL;
			
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'rm -f '||RUTA||vPrefijo||SCRIPT_EJECUCION1;
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'rm -f '||RUTA||vPrefijo||SCRIPT_EJECUCION2;
		SYSTEM vExecuteSQL;
		
				
		LET vCodigoRetorno = '00000';
		LET vMensaje = 'Proceso exitoso';
		RETURN vCodigoRetorno, vMensaje,vFechaInicial, vFechaFinal;
			
	END
	
END PROCEDURE
DOCUMENT
'Autor: Kenya Itzel Alonso Sanchez',
'Objetivo: Monitor de transacciones de retiro sin tarjeta',
'Fecha de CreaciÃÂ³n: 18/04/2021',
'Fecha ÃÂºltima modificaciÃÂ³n: 12/04/2022'
;

CREATE PROCEDURE "informix".sp_consultatarjetabin_pba(pEmpresa CHAR(3), pLote INTEGER, pTarjetaini CHAR(16), pTarjetafin CHAR(16))
RETURNING CHAR(5) AS codigo_retorno,CHAR(1) AS tipo;

	DEFINE cCodRet CHAR(6);
	DEFINE iSqlErr INTEGER;
	DEFINE cTipo CHAR(1);
	DEFINE cBin CHAR(6);
	DEFINE iNumeroLote1 INTEGER;
	DEFINE iNumeroLote2 INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cTipo = '';
	LET cBin = '';
	LET iNumeroLote1 = 0;
	LET iNumeroLote2 = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr		
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr::CHAR(8);
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cTipo,''));
			END IF;			
		END EXCEPTION; 	

		 -- SET DEBUG FILE TO "/respaldosbd/mario/trace.sql";
		 -- TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		
		IF TRIM(NVL(pEmpresa,'')) = '' OR TRIM(NVL(pLote,'')) = '' OR TRIM(NVL(pTarjetaini,'')) = '' OR TRIM(NVL(pTarjetafin,'')) = ''  THEN		
			LET cCodRet = '00001';
		ELSE				
			SELECT numerolote INTO iNumeroLote1
			FROM intercard:"informix".lote
			WHERE numerolote = pLote;
			
			SELECT DISTINCT(numerolote) INTO iNumeroLote2
			FROM intercard:"informix".tarjeta 
			WHERE numtarjeta >= pTarjetaini AND numtarjeta <= pTarjetafin;
			
			IF iNumeroLote1 = iNumeroLote2 THEN
			
				LET cBin = SUBSTR(pTarjetaini,1,6);
				
				SELECT creditodebito INTO cTipo FROM intercard:"informix".bines WHERE bin = cBin;
				
				IF TRIM(NVL(cTipo,'')) = '' THEN			
					LET cCodRet = '00003';
				END IF;			
				
			ELSE
				LET cCodRet = '00002';
			END IF;
				
		END IF;		
		RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cTipo,''));		
	END;
END PROCEDURE
DOCUMENT
'Autor: 95142134 Mario Gallardo',
'Folio: 144 - ControlRegistrTarjetasSucursal',
'Fecha: 29-11-2016',
'ModificaciÃ³n: Se crea procedimiento para validar bines de tarjetas',
'Sustento: 144_1_1_1_11_12_1_1_5_.pdf',
'Solicita: Abraham Narvaez',
'Base de datos: Intercard';

CREATE PROCEDURE "informix".sp_consultatarjetabin_pba1(pEmpresa CHAR(3), pLote INTEGER, pTarjetaini CHAR(16), pTarjetafin CHAR(16))
RETURNING CHAR(5) AS codigo_retorno,CHAR(1) AS tipo;

	DEFINE cCodRet CHAR(6);
	DEFINE iSqlErr INTEGER;
	DEFINE cTipo CHAR(1);
	DEFINE cBin CHAR(6);
	DEFINE iNumeroLote1 INTEGER;
	DEFINE iNumeroLote2 INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cTipo = '';
	LET cBin = '';
	LET iNumeroLote1 = 0;
	LET iNumeroLote2 = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr		
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr::CHAR(8);
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cTipo,''));
			END IF;			
		END EXCEPTION; 	

		 -- SET DEBUG FILE TO "/respaldosbd/mario/trace.sql";
		 -- TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		
		IF TRIM(NVL(pEmpresa,'')) = '' OR TRIM(NVL(pLote,'')) = '' OR TRIM(NVL(pTarjetaini,'')) = '' OR TRIM(NVL(pTarjetafin,'')) = ''  THEN		
			LET cCodRet = '00001';
		ELSE				
			SELECT numerolote INTO iNumeroLote1
			FROM intercard:"informix".lote
			WHERE numerolote = pLote;
			
			SELECT DISTINCT(numerolote) INTO iNumeroLote2
			FROM intercard:"informix".tarjeta_20240205 
			WHERE numtarjeta >= pTarjetaini AND numtarjeta <= pTarjetafin;
			
			IF iNumeroLote1 = iNumeroLote2 THEN
			
				LET cBin = SUBSTR(pTarjetaini,1,6);
				
				SELECT creditodebito INTO cTipo FROM intercard:"informix".bines WHERE bin = cBin;
				
				IF TRIM(NVL(cTipo,'')) = '' THEN			
					LET cCodRet = '00003';
				END IF;			
				
			ELSE
				LET cCodRet = '00002';
			END IF;
				
		END IF;		
		RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cTipo,''));		
	END;
END PROCEDURE
DOCUMENT
'Autor: 95142134 Mario Gallardo',
'Folio: 144 - ControlRegistrTarjetasSucursal',
'Fecha: 29-11-2016',
'ModificaciÃ³n: Se crea procedimiento para validar bines de tarjetas',
'Sustento: 144_1_1_1_11_12_1_1_5_.pdf',
'Solicita: Abraham Narvaez',
'Base de datos: Intercard';

CREATE PROCEDURE "informix".sp_consultatarjetabin_pba2(pEmpresa CHAR(3), pLote INTEGER, pTarjetaini CHAR(16), pTarjetafin CHAR(16))
RETURNING CHAR(5) AS codigo_retorno,CHAR(1) AS tipo;

	DEFINE cCodRet CHAR(6);
	DEFINE iSqlErr INTEGER;
	DEFINE cTipo CHAR(1);
	DEFINE cBin CHAR(6);
	DEFINE iNumeroLote1 INTEGER;
	DEFINE iNumeroLote2 INTEGER;
	DEFINE str1 CHAR(50);
define vfecha_hoy       char(8);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cTipo = '';
	LET cBin = '';
	LET iNumeroLote1 = 0;
	LET iNumeroLote2 = 0;
	LET str1 = '';
let vfecha_hoy          = "";
	
	BEGIN

		ON EXCEPTION SET iSqlErr		
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr::CHAR(8);
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cTipo,''));
			END IF;			
		END EXCEPTION; 	

		  SET DEBUG FILE TO "trace_pba1.out";
		  TRACE ON;

		SET ISOLATION TO DIRTY READ;
SELECT to_char(DBINFO('utc_to_datetime', sh_curtime)::DATE, "%Y%m%d")  INTO vfecha_hoy
   from sysmaster:sysshmvals;

		IF TRIM(NVL(pEmpresa,'')) = '' OR TRIM(NVL(pLote,'')) = '' OR TRIM(NVL(pTarjetaini,'')) = '' OR TRIM(NVL(pTarjetafin,'')) = ''  THEN		
			LET cCodRet = '00001';
		ELSE				
			SELECT numerolote INTO iNumeroLote1
			FROM intercard:"informix".lote
			WHERE numerolote = pLote;
			
SELECT to_char(DBINFO('utc_to_datetime', sh_curtime)::DATE, "%Y%m%d")  INTO vfecha_hoy
   from sysmaster:sysshmvals;

			SELECT DISTINCT(numerolote) INTO iNumeroLote2
			FROM intercard:"informix".tarjeta 
			WHERE numtarjeta >= pTarjetaini AND numtarjeta <= pTarjetafin;
			

			IF iNumeroLote1 = iNumeroLote2 THEN
			
				LET cBin = SUBSTR(pTarjetaini,1,6);
				
SELECT to_char(DBINFO('utc_to_datetime', sh_curtime)::DATE, "%Y%m%d")  INTO vfecha_hoy
   from sysmaster:sysshmvals;

				SELECT creditodebito INTO cTipo FROM intercard:"informix".bines WHERE bin = cBin;
				
SELECT to_char(DBINFO('utc_to_datetime', sh_curtime)::DATE, "%Y%m%d")  INTO vfecha_hoy
   from sysmaster:sysshmvals;

				IF TRIM(NVL(cTipo,'')) = '' THEN			
					LET cCodRet = '00003';
				END IF;			
				
			ELSE
				LET cCodRet = '00002';
			END IF;
				
		END IF;		
		RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cTipo,''));		
	END;
END PROCEDURE
DOCUMENT
'Autor: 95142134 Mario Gallardo',
'Folio: 144 - ControlRegistrTarjetasSucursal',
'Fecha: 29-11-2016',
'ModificaciÃ³n: Se crea procedimiento para validar bines de tarjetas',
'Sustento: 144_1_1_1_11_12_1_1_5_.pdf',
'Solicita: Abraham Narvaez',
'Base de datos: Intercard';

CREATE PROCEDURE "informix".sp_genera_archivo_afiliacion_comercios()
RETURNING CHAR(5) AS Cod_Retorno;

-- ****************************************************************************
-- Definicion de variables
-- ****************************************************************************

DEFINE v_idproceso        	INT;
DEFINE v_fecha_inicio_mes 	DATE;
DEFINE sDiaP              	CHAR(2);
DEFINE sMesP              	CHAR(2);
DEFINE sAnoP              	CHAR(4);
DEFINE v_hInicio          	CHAR(11);
DEFINE v_fhInicioMes      	VARCHAR(25);
DEFINE v_fecha_fin_mes    	DATE;
DEFINE v_hFin             	CHAR(11);
DEFINE v_fhFinMes         	VARCHAR(25);

DEFINE cCmd1        	    CHAR(1000);
DEFINE pArchDeclarga1	    CHAR(1000);
DEFINE cQuery1        	    CHAR(3000);

DEFINE nombreArchivo        VARCHAR(25);
DEFINE fh_inicioProceso		DATETIME YEAR TO FRACTION(5);
DEFINE fh_finProceso		DATETIME YEAR TO FRACTION(5);
DEFINE vMaxIdProceso        INT;
DEFINE vMinIdProceso        INT;
DEFINE totalRegistros       INT;

DEFINE iSql_err				INT;
DEFINE cCodRet				CHAR(5);


-- ****************************************************************************
-- Inicializa de variables
-- ****************************************************************************

LET v_idproceso 			= 0;
LET v_fecha_inicio_mes 		= '';
LET sDiaP               	= '';
LET sMesP               	= '';
LET sAnoP               	= '';
LET v_hInicio 				= ' 00:00:00.0';
LET v_fhInicioMes 			= '';
LET v_fecha_fin_mes 		= '';
LET v_hFin 					= ' 23:59:59.9';
LET v_fhFinMes 				= '';

LET cCmd1           	    = '';
LET pArchDeclarga1          = '';
LET cQuery1        	        = '';

LET nombreArchivo           = '';
LET fh_inicioProceso		= '';
LET fh_finProceso			= '';
LET vMaxIdProceso           = 0;
LET vMinIdProceso           = 0;
LET totalRegistros          = 0;

LET iSql_err				= 0;
LET cCodRet					= '00000';


-- ****************************************************************************
-- Logica del SP
-- ****************************************************************************

BEGIN

		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
	
        --SET DEBUG FILE TO "/home/c90304940/mroman/prueba_jesus.out";
       -- TRACE ON;
        
        --SE ELIMINA LA INFORMACION DE LA TABLA
		TRUNCATE TABLE "informix".tbl_idproceso_numero_afiliacion DROP STORAGE;
		
		--SE ELIMINA LA INFORMACION DE LA TABLA
        TRUNCATE TABLE "informix".tbl_numero_afiliacion DROP STORAGE;
		
		--SE ELIMINA LA INFORMACION DE LA TABLA
		TRUNCATE TABLE "informix".tbl_movimiento_mes_anterior DROP STORAGE;
								
		--Consulta el primer dia del mes anterior

        LET sDiaP = "01";
         
		IF (MONTH(today )-1 = 0) THEN
		
            LET sMesP = "12";
        
            SELECT year(today ) - 1  INTO sAnoP FROM systables   where tabid=1;
    
		ELSE 
	
		
		    SELECT month(today )-1 INTO sMesP FROM systables   where tabid=1;
		    IF sMesP < 10 THEN
		        LET sMesP = 0 || sMesP;
		    END IF

            SELECT year(today )  INTO sAnoP FROM systables  where tabid=1;
		
		END IF
		
        
        ----Fecha y hora inicio mes anterior---- 
        LET v_fhInicioMes = trim(sAnoP ||'-'|| sMesP || '-' || sDiaP || v_hInicio);
        
        --Consulta el ultimo dia del mes anterior ***";        
        LET v_fecha_fin_mes = add_months(last_day(DATE(today)),-1);
        LET sDiaP = '';
        LET sDiaP = day(v_fecha_fin_mes);
        
        --Fecha y hora fin mes anterior---- ***';
        LET v_fhFinMes = trim(sAnoP ||'-'|| sMesP ||'-'|| sDiaP || v_hFin);
        

        --Consulta el estatus del ultimo idProceso registrado en la tabla bitacora_afiliaciones_comercios
        SELECT idproceso 
            INTO v_idproceso
        FROM "informix".bitacora_afiliaciones_comercios
        WHERE estatus_proceso = 'P'
            AND total_registros = 0;
         
        LET v_idproceso = v_idproceso;      
                
        --Evalua si el valor de la variable v_idproceso es igual 0 o nulo
        IF (v_idproceso = 0 OR v_idproceso IS NULL) THEN
        
		SET ISOLATION TO dirty READ;
             
		BEGIN WORK;
			INSERT INTO "informix".tbl_idproceso_numero_afiliacion (idproceso, numero_afiliacion)
			    SELECT idproceso, trim(numero_afiliacion)
					FROM "informix".afiliaciones_comercios
			    WHERE estatus_comercio = "A" 
			        ORDER BY idproceso;
		COMMIT WORK;
		
			--consulta el valor maximo almacenado en la tabla "informix".tbl_idproceso_numero_afiliacion
			SELECT MAX(idproceso) max_idProceso 
				INTO vMaxIdProceso
			FROM "informix".tbl_idproceso_numero_afiliacion;

			LET vMaxIdProceso = vMaxIdProceso;

			--consulta el valor minimo almacenado en la tabla "informix".tbl_idproceso_numero_afiliacion
			SELECT MIN(idproceso) min_idProceso 
				INTO vMinIdProceso
			FROM "informix".tbl_idproceso_numero_afiliacion;

			
			WHILE (vMinIdProceso <= vMaxIdProceso)  LOOP
        
				SET ISOLATION TO dirty READ;
				
				BEGIN WORK;
                INSERT INTO "informix".tbl_numero_afiliacion(numero_afiliacion)
					SELECT numero_afiliacion
						FROM "informix".tbl_idproceso_numero_afiliacion
					WHERE idproceso = vMinIdProceso;
				COMMIT WORK;

				SET ISOLATION TO dirty READ;
				
				BEGIN WORK;
				INSERT INTO "informix".tbl_movimiento_mes_anterior(fechaTrxn, bin8, codISO, metodoCaptura, esNacional, codTransaccion, numAfiliacion, infoReceptor, tipoTransaccionPos, tipoTransaccionPosdigitada, metodoIdentificacion, motivoRechazo, cantidadTransacciones, montoTotalOperado)
					SELECT -- {+INDEX(intercard:movimiento idx_fechahorainauth)}
						DATE(mv.fechahorainauth) AS fecha,
						SUBSTR (mv.numtarjeta,0,8) AS bin,
						mv.codigoiso, 
						mv.metodocaptura, 
						mv.esnacional,
						mv.codtran,
						mv.idretailer AS Afiliacion,
						mv.infreceptor, 
						mv.tipotransaccionpos, 
						mv.tipotransaccionposdigitada, 
						mv.MetodoIdentificacion, 
						mv.motivo,
						COUNT(*) AS Cantidad, 
						SUM(mv.monto) AS Monto_Total
						FROM intercard:movimiento mv
						WHERE mv.fechahorainauth BETWEEN v_fhInicioMes AND v_fhFinMes     
						AND SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM intercard:bines)
						AND mv.codigoiso IS NOT NULL 
						AND mv.codigoiso != ('null') AND mv.codigoiso <> ' '
						AND mv.prodind = '02'
						AND mv.esnacional IN ('V','F')
						AND mv.formato = '0200'
						AND mv.codtran IN ('00','09')
						AND mv.idretailer IN (SELECT numero_afiliacion FROM "informix".tbl_numero_afiliacion)
						AND mv.codreversa = '0'                            
						AND mv.movreversado = 'F'  
						AND mv.metodocaptura IS NOT NULL 
						AND mv.metodocaptura != ('null')
						AND mv.transaccionorigen = '1234'
						GROUP BY fecha, bin,2,3,4,5,6,7,8,9,10,11,12;
				COMMIT WORK;	
				
				--Se inicializa la variable fh_inicioProceso
				LET fh_inicioProceso = '';
				--Sentencia utilizada para obtener el fecha y hora actual para ser almacenda en la variable fh_inicioProceso
				SELECT DBINFO('utc_to_datetime', sh_curtime) 
					INTO fh_inicioProceso
				FROM sysmaster:"informix".sysshmvals;
				LET fh_inicioProceso = fh_inicioProceso;
				
				--Se hace un insert a la tabla "informix".bitacora_afiliaciones_comercios por cada IdProceso 
				INSERT INTO "informix".bitacora_afiliaciones_comercios(idproceso,fechahora_inicio_proceso,fechahora_fin_proceso,estatus_proceso,total_registros)
                VALUES (vMinIdProceso,fh_inicioProceso,'','P',0);
				
				
				--NOMBRE ARCHIVO
                LET nombreArchivo = '';
                LET nombreArchivo ='ID'||vMinIdProceso||'-'||sMesP||sAnoP;

                --Genera archivo por ID proceso
				LET pArchDeclarga1='"/RESPALDOSNEW/'||TRIM(nombreArchivo)||'.unl" delimiter "|" ';
				LET cCmd1 = 'SELECT fechatrxn, bin8, codISO, metodoCaptura, esNacional, codTransaccion, numAfiliacion, infoReceptor, tipoTransaccionPos, tipoTransaccionPosdigitada, metodoIdentificacion, motivoRechazo, cantidadTransacciones, montoTotalOperado FROM intercard:tbl_movimiento_mes_anterior ORDER BY  numAfiliacion,fechatrxn;';
				LET cQuery1 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pArchDeclarga1)||"  "||TRIM(cCmd1)||"' | /ifxsif01/bin/dbaccess intercard > /dev/null 2>&1";
				SYSTEM TRIM(cQuery1);
				
				--CONSULTA QUE OBTIEN EL TOTAL DE REGISTROS EN UN ARCHIVO POR IDPROCESO
                SELECT COUNT(*)
					INTO totalRegistros
                FROM "informix".tbl_movimiento_mes_anterior;
                LET totalRegistros = totalRegistros;
				
				--Se inicializa la variable fh_finProceso
				LET fh_finProceso = '';
				--Sentencia utilizada para obtener el fecha y hora actual para ser almacenda en la variable fh_finProceso
				SELECT DBINFO('utc_to_datetime', sh_curtime) 
					INTO fh_finProceso
				FROM sysmaster:"informix".sysshmvals;
				LET fh_finProceso = fh_finProceso;

                --actualiza tabla "informix".bitacora_afiliaciones_comercios por cada IDproceso
                UPDATE "informix".bitacora_afiliaciones_comercios
					SET  fechahora_fin_proceso = fh_finProceso, estatus_proceso='T', total_registros = totalRegistros
                WHERE idProceso = vMinIdProceso 
					AND estatus_proceso = 'P';

				--SE ELIMINA LA INFORMACION DE LA TABLA
				TRUNCATE TABLE "informix".tbl_movimiento_mes_anterior DROP STORAGE;
                 
                --incrementa valor variable
                LET vMinIdProceso = vMinIdProceso + 1;
                
                --SE ELIMINA LA INFORMACION DE LA TABLA
                TRUNCATE TABLE "informix".tbl_numero_afiliacion DROP STORAGE;

            END LOOP;
      
	    --Evalua si el valor de la variable v_idproceso es diferente a 0
        ELIF (v_idproceso <> 0 ) THEN 
            
		
		    SET ISOLATION TO dirty READ;
            
			BEGIN WORK;
            INSERT INTO "informix".tbl_idproceso_numero_afiliacion (idproceso, numero_afiliacion)
			    SELECT idproceso, trim(numero_afiliacion)
			    FROM intercard:afiliaciones_comercios
			 WHERE estatus_comercio = "A" 
			    AND idproceso >= v_idproceso
                ORDER BY idproceso;
			COMMIT WORK;
			        
			--consulta el valor maximo almacenado en la tabla "informix".tbl_idproceso_numero_afiliacion
			SELECT MAX(idproceso) max_idProceso 
				INTO vMaxIdProceso
			FROM "informix".tbl_idproceso_numero_afiliacion;

			LET vMaxIdProceso = vMaxIdProceso;
        
			--consulta el valor minimo almacenado en la tabla "informix".tbl_idproceso_numero_afiliacion
			SELECT MIN(idproceso) min_idProceso 
				INTO vMinIdProceso
			FROM "informix".tbl_idproceso_numero_afiliacion;
        
			LET vMinIdProceso = vMinIdProceso;


			WHILE (vMinIdProceso <= vMaxIdProceso)  LOOP
        
				SET ISOLATION TO dirty READ;
					
					BEGIN WORK;
                    INSERT INTO "informix".tbl_numero_afiliacion(numero_afiliacion)
						SELECT numero_afiliacion
							FROM "informix".tbl_idproceso_numero_afiliacion
						WHERE idproceso = vMinIdProceso;
					COMMIT WORK;
         
				SET ISOLATION TO dirty READ;
					
					BEGIN WORK;
					INSERT INTO "informix".tbl_movimiento_mes_anterior(fechaTrxn, bin8, codISO, metodoCaptura, esNacional, codTransaccion, numAfiliacion, infoReceptor, tipoTransaccionPos, tipoTransaccionPosdigitada, metodoIdentificacion, motivoRechazo, cantidadTransacciones, montoTotalOperado)
						SELECT -- {+INDEX(intercard:movimiento idx_fechahorainauth)}
							DATE(mv.fechahorainauth) AS fecha,
							SUBSTR (mv.numtarjeta,0,8) AS bin,
							mv.codigoiso, 
							mv.metodocaptura, 
							mv.esnacional,
							mv.codtran,
							mv.idretailer AS Afiliacion,
							mv.infreceptor, 
							mv.tipotransaccionpos, 
							mv.tipotransaccionposdigitada, 
							mv.MetodoIdentificacion, 
							mv.motivo,
							COUNT(*) AS Cantidad, 
							SUM(mv.monto) AS Monto_Total
							FROM intercard:movimiento mv
							WHERE mv.fechahorainauth BETWEEN v_fhInicioMes AND v_fhFinMes   
							AND SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM intercard:bines)
							AND mv.codigoiso IS NOT NULL 
							AND mv.codigoiso != ('null') AND mv.codigoiso <> ' '
							AND mv.prodind = '02'
							AND mv.esnacional IN ('V','F')
							AND mv.formato = '0200'
							AND mv.codtran IN ('00','09')
							AND mv.idretailer IN (SELECT numero_afiliacion FROM "informix".tbl_numero_afiliacion)
							AND mv.codreversa = '0'                            
							AND mv.movreversado = 'F'  
							AND mv.metodocaptura IS NOT NULL 
							AND mv.metodocaptura != ('null')
							AND mv.transaccionorigen = '1234'
							GROUP BY fecha, bin,2,3,4,5,6,7,8,9,10,11,12;
					COMMIT WORK;

				--NOMBRE ARCHIVO

                LET nombreArchivo = '';
                LET nombreArchivo ='ID'||vMinIdProceso||'-'||sMesP||sAnoP;
				
                --Genera archivo por ID proceso
                
				LET pArchDeclarga1='"/RESPALDOSNEW/'||TRIM(nombreArchivo)||'.unl" delimiter "|" ';
				LET cCmd1 = 'SELECT fechatrxn, bin8, codISO, metodoCaptura, esNacional, codTransaccion, numAfiliacion, infoReceptor, tipoTransaccionPos, tipoTransaccionPosdigitada, metodoIdentificacion, motivoRechazo, cantidadTransacciones, montoTotalOperado FROM intercard:tbl_movimiento_mes_anterior ORDER BY  numAfiliacion,fechatrxn;';
				LET cQuery1 = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pArchDeclarga1)||"  "||TRIM(cCmd1)||"' | /ifxsif01/bin/dbaccess intercard > /dev/null 2>&1";
				SYSTEM TRIM(cQuery1);
				
				
				
				--CONSULTA QUE CUENTA EL TOTAL DE REGISTROS EN UN ARCHIVO POR IDPROCESO
                SELECT COUNT(*)
					INTO totalRegistros
                FROM "informix".tbl_movimiento_mes_anterior;
                
                LET totalRegistros = totalRegistros;
				
				--Se inicializa la variable fh_finProceso
				LET fh_finProceso = '';
				--Sentencia utilizada para obtener el fecha y hora actual para ser almacenda en la variable fh_finProceso
				SELECT DBINFO('utc_to_datetime', sh_curtime) 
					INTO fh_finProceso
				FROM sysmaster:"informix".sysshmvals;
				LET fh_finProceso = fh_finProceso;

                --actualiza tabla "informix".bitacora_afiliaciones_comercios por cada IDproceso
                UPDATE "informix".bitacora_afiliaciones_comercios 
					SET  fechahora_fin_proceso = fh_finProceso, estatus_proceso = 'T', total_registros = totalRegistros
				WHERE idProceso = vMinIdProceso
					AND estatus_proceso = 'P';
			
				--SE ELIMINA LA INFORMACION DE LA TABLA
				TRUNCATE TABLE "informix".tbl_movimiento_mes_anterior DROP STORAGE;
                 
                --incrementa valor variable
                LET vMinIdProceso = vMinIdProceso + 1;
                

                IF(vMinIdProceso <= vMaxIdProceso)THEN
				
					--Se inicializa la variable fh_inicioProceso
					LET fh_inicioProceso = '';
					--Sentencia utilizada para obtener el fecha y hora actual para ser almacenda en la variable fh_inicioProceso
					SELECT DBINFO('utc_to_datetime', sh_curtime) 
						INTO fh_inicioProceso
					FROM sysmaster:"informix".sysshmvals;
					LET fh_inicioProceso = fh_inicioProceso;
					
					--Se hace un insert a la tabla "informix".bitacora_afiliaciones_comercios por cada IdProceso 
					INSERT INTO "informix".bitacora_afiliaciones_comercios(idproceso,fechahora_inicio_proceso,fechahora_fin_proceso,estatus_proceso,total_registros)
					VALUES (vMinIdProceso,fh_inicioProceso,'','P',0);

                END IF;
                
                --SE ELIMINA LA INFORMACION DE LA TABLA
                TRUNCATE TABLE "informix".tbl_numero_afiliacion DROP STORAGE;
                
            END LOOP;
		END IF;
		
	RETURN cCodRet;
	END;
END PROCEDURE;