CREATE PROCEDURE "informix".sp_cp_grabadetallearchivotdc(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEjecucion CHAR(1),
pCredito CHAR(20), pNumCte CHAR(20), pNumTarjeta CHAR(20), pTit CHAR(3), pNombre CHAR(107), pEmbozado CHAR(21), pMaster CHAR(1), 
pTipoDomicilio CHAR(1), pTipoProceso CHAR(1), pNombreArchivo CHAR(100), pProdUpgrade CHAR(4), pError CHAR(1), pMensajeError CHAR(120))
	RETURNING CHAR(5) AS codret;	

DEFINE cCodRet CHAR(5);
DEFINE cCodRetSp CHAR(6);
DEFINE cDesCodRetSp CHAR(100);
DEFINE iSqlErr INTEGER;
DEFINE cEmpresa CHAR(3);
DEFINE iExiste SMALLINT;
DEFINE cMensajeError CHAR(120);

LET cCodRet = '00000';
LET cCodRetSp = '';
LET cDesCodRetSp = '';
LET iSqlErr = 0;
LET cEmpresa = '001';
LET iExiste = 0;
LET cMensajeError = '';

BEGIN

	ON EXCEPTION SET iSqlErr
		LET cCodRet = iSqlErr;
		RETURN cCodRet;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_grabadetallearchivotdc.out';
	--TRACE ON;
	
	IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pIdEjecucion = '' THEN
		LET cCodRet = '00003';
		RETURN cCodRet;
	END IF;
	
	-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
	EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
	IF cCodRet <> '00000' THEN
		RETURN cCodRet;
	END IF;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--Registro Desmarcado
	--AAME RQM 10 682-4 Se contempla que si el usuario desmarca un registro del proceso se indique la descripción ya que se esta mandando con opcion 3
	IF pIdEjecucion IN ('1','3') THEN
		
		EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(pCredito,pNumTarjeta,pProdUpgrade,
		pTit,pNombre,pError,'NO','NO',pMensajeError,pUsuario,pNombreArchivo,CURRENT)
		INTO cCodRetSp,cDesCodRetSp;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdicred:sp_grabadetallearchivotdc';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		ELIF cCodRetSp::INTEGER = 2 THEN
			LET cCodRet = '00481'; --EL NOMBRE DEL ARCHIVO NO CORRESPONDE CON LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
		END IF;
		--AAME RQM 10 682-4 Se contempla el grabado del resultado en la tabla de paso que cuenta el total de registros procesados
		IF pError = "1" THEN
			INSERT INTO bdicnweb:"informix".sw_cred_cambioproducto(descripcion,numero_credito,num_tarjeta,tipo_tarjeta,nombre_embozado,fecha,resultado,marcaje,sol_plastico,mensaje_error,us_insert,fecha_insert) 
			VALUES(cDesCodRetSp,pCredito,pNumTarjeta,pTit,pNombre,CURRENT,'NO EXITOSO','NO','NO',pMensajeError,pUsuario,current);
		ELIF pError = "0" THEN
			INSERT INTO bdicnweb:"informix".sw_cred_cambioproducto(descripcion,numero_credito,num_tarjeta,tipo_tarjeta,nombre_embozado,fecha,resultado,marcaje,sol_plastico,mensaje_error,us_insert,fecha_insert) 
			VALUES(cDesCodRetSp,pCredito,pNumTarjeta,pTit,pNombre,CURRENT,'EXITOSO','SI','SI',pMensajeError,pUsuario,current);	
		END IF;		
		
	END IF;
	
	RETURN cCodRet;
	
END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 30/04/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÓN MASIVA', 
'DESCRIPCION: SPL encargado de grabar la información a reportería (se ejecuta spl sp_grabadetallearchivotdc).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_bitacoraerrormanualtdc(pUsuario CHAR(8), pIdFuncion CHAR(10),pBandera CHAR(1), pNomProceso CHAR(35), pNumCredito CHAR(20), 
pNumCte CHAR(20), pNumTarjeta CHAR(17),pTipoTarjeta CHAR(4),pMensajeError CHAR(100), pDirMac CHAR(12),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(35) AS nombre_proceso,
		CHAR(20) AS numero_credito,
		CHAR(20) AS numero_cliente, 
		CHAR(17) AS numero_tarjeta, 
		CHAR(4)  AS tipo_tarjeta, 		
		CHAR(100) AS mensaje_error,
		INTEGER AS num_registros;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombreProceso CHAR(35);
	DEFINE cNumeroCredito CHAR(20);
	DEFINE cNumeroCliente CHAR(20);
	DEFINE cNumeroTarjeta CHAR(17);
	DEFINE cTipoTarjeta CHAR(4);
	DEFINE cMensajeError CHAR(100);			
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
    DEFINE iErrorInf INTEGER;	DEFINE cMensajeRet CHAR(100);	
	DEFINE cNomArchivo CHAR(35);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cNombreProceso = '';
	LET cNumeroCredito = '';
	LET cNumeroCliente = '';
	LET cNumeroTarjeta = '';
	LET cTipoTarjeta = '';
	LET cMensajeError = '';
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
    LET iErrorInf = 0; --- AAME 20190218 RQM 10682-4 iErrorInf, cMensajeRet, cNomArchivo
	LET cMensajeRet = '';
	LET cNomArchivo = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError,iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_bitacoraerrormanualtdc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError,iNoRegistros;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError,iNoRegistros;
		END IF;
		
		IF pBandera = '1' THEN
		
			--- AAME 20190218 RQM 10682-4 SE VALIDA QUE SEA POR FUNCIONALIDAD DE MASIVO, EN CASO CONTRARIO SE REGISTRARÁ NORMALMENTE LOS ERRORES
			IF pIdFuncion = 'CCP102' THEN
				SELECT nombre_archivo INTO cNomArchivo
				FROM  bdicred:"informix".sd_credito_upgrade 
				WHERE num_credito = pNumCredito AND numerotarjeta=pNumTarjeta ;
							
				IF pNomProceso ='EJECUTA TRAMA' OR pNomProceso = 'sp_cp_obtensolicitudmaquilatdc' OR pNomProceso = 'sp_cp_graba_prod_upgrade' THEN
					LET iErrorInf= CHARINDEX('-',pMensajeError);
				   
					IF  iErrorInf = 0 THEN 
						IF pNomProceso = 'sp_cp_graba_prod_upgrade' THEN
							--- AAME 20190218 RQM 10682-4 SE GUARDA INFORMACIÓN DE REPORTERÍA
							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(pNumCredito ,pNumTarjeta,'', pTipoTarjeta, '','1','NO','NO',cMensajeError,pUsuario,cNomArchivo,'')
							INTO cCodRet,cMensajeRet;
						ELSE
							--- AAME 20190218 RQM 10682-4 SE GUARDA INFORMACIÓN DE REPORTERÍA
							EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(pNumCredito ,pNumTarjeta,'', pTipoTarjeta, '','1','SI','NO',cMensajeError,pUsuario,cNomArchivo,'')
							INTO cCodRet,cMensajeRet;
						END IF;
					ELSE
						--- AAME 20190218 RQM 10682-4 SE GUARDA BITACORA DE ERROR SI SE PRESENTA ERROR DE INFORMIX
						INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrormanualtdc(nombre_proceso, numero_credito, numero_cliente, numero_tarjeta, tipo_tarjeta, mensaje_error, usuario, direccion_mac)
						VALUES(pNomProceso , pNumCredito, pNumCte, pNumTarjeta, pTipoTarjeta, pMensajeError, pUsuario, pDirMac);                    
					END IF;
				ELSE
					INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrormanualtdc(nombre_proceso, numero_credito, numero_cliente, numero_tarjeta, tipo_tarjeta, mensaje_error, usuario, direccion_mac)
					VALUES(pNomProceso , pNumCredito, pNumCte, pNumTarjeta, pTipoTarjeta, pMensajeError, pUsuario, pDirMac);
				END IF;
			ELSE
				INSERT INTO bdicnweb:"informix".sw_cp_bitacoraerrormanualtdc(nombre_proceso, numero_credito, numero_cliente, numero_tarjeta, tipo_tarjeta, mensaje_error, usuario, direccion_mac)
				VALUES(pNomProceso , pNumCredito, pNumCte, pNumTarjeta, pTipoTarjeta, pMensajeError, pUsuario, pDirMac);
			END IF;				
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN  
				LET cCodRet = '00282';
			END IF;
			
			RETURN cCodRet,cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError,iNoRegistros;
		
		ELIF pBandera = '2' THEN
		
				SELECT COUNT(*) AS total
				INTO iNoRegistros
				FROM bdicnweb:"informix".sw_cp_bitacoraerrormanualtdc
				WHERE usuario = pUsuario;
				
				RETURN cCodRet,cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError,NVL(iNoRegistros,0);
		
		ELIF pBandera = '3' THEN
		
			FOREACH	
				SELECT SKIP pRegistros FIRST pRecuperacion nombre_proceso, numero_credito, numero_cliente, numero_tarjeta, tipo_tarjeta, mensaje_error
				INTO cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError			
				FROM bdicnweb:"informix".sw_cp_bitacoraerrormanualtdc
				WHERE usuario = pUsuario
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError,iNoRegistros WITH RESUME;	
			END FOREACH;
			
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError,iNoRegistros;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet,cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError,iNoRegistros;
			END IF;
			
		ELIF pBandera = '4' THEN
		
			DELETE FROM bdicnweb:"informix".sw_cp_bitacoraerrormanualtdc WHERE usuario = pUsuario;
			
			/*IF DBINFO('sqlca.sqlerrd2') = 0 THEN  
				LET cCodRet = '00862';
			END IF;*/
			
			RETURN cCodRet,cNombreProceso,cNumeroCredito,cNumeroCliente,cNumeroTarjeta,cTipoTarjeta,cMensajeError,iNoRegistros;
		
		END IF;
					
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 30/03/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO PRODUCTO MANUAL Y MASIVO',
'DESCRIPCION: ESTE PROCEDIMIENTO CAPTURA LOS ERRORES QUE SE PUEDAN GENERAR EN EL PROCESO DE GUARDADO DE DATOS, MAQUILA Y EJECUCION DE LA TRANSACCION 30116',
'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 30/03/2017',
'DESCRIPCION: CAMBIO PARA CORREGIR LOS DUPLICADOS EN EL RETORNO DE LA INFORMACION',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_consultadetcuentas(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(12), pNombreArchivo CHAR(35),
pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_tarjeta,
		CHAR(2) AS status_cred, 
		CHAR(20) AS num_credito,
		CHAR(3) AS tipo_tarjeta,
		CHAR(30) AS nombre_cliente,
		CHAR(21) AS nombre_embozado,
		CHAR(2) AS master,
		CHAR(1) AS domicilio_envio,
		CHAR(20) AS desc_domicilio_envio,
		CHAR(4) AS sucursal,
		CHAR(40) AS desc_sucursal,
		CHAR(20) AS num_cliente,
		CHAR(4) AS prod_destino,
		CHAR(40) AS desc_prod_destino,
		CHAR(1) AS origen_reg,
		INTEGER AS id_registro;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cStatusCred CHAR(2);
	DEFINE cNumCredito CHAR(20);
	DEFINE cTipoTarjeta CHAR(3);
	DEFINE cNombreCliente CHAR(30);
	DEFINE cNombreEmbozado CHAR(21);
	DEFINE cMaster CHAR(2);
	DEFINE cDomicilioEnvio CHAR(1);
	DEFINE cSucursal CHAR(4);
	DEFINE cNumCliente CHAR(20);
	DEFINE cProdDestino CHAR(4);
	DEFINE cDescProdDestino CHAR(40);
	DEFINE cOrigenReg CHAR(1);
	DEFINE iIdRegistro INTEGER;
	DEFINE cDescDomEnvio CHAR(20);
	DEFINE cDescSucursal CHAR(40);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cNumTarjeta = '';
	LET cStatusCred = '';
	LET cNumCredito = '';
	LET cTipoTarjeta = '';
	LET cNombreCliente = '';
	LET cNombreEmbozado = '';
	LET cMaster = '';
	LET cDomicilioEnvio = '';
	LET cSucursal = '';
	LET cNumCliente = '';
	LET cProdDestino = '';
	LET cDescProdDestino = '';
	LET cOrigenReg = '';
	LET iIdRegistro = 0;
	LET cDescDomEnvio = '';
	LET cDescSucursal = '';
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNumTarjeta, cStatusCred,cNumCredito,cTipoTarjeta,cNombreCliente,cNombreEmbozado,cMaster,
			cDomicilioEnvio,cDescDomEnvio,cSucursal,cDescSucursal,cNumCliente,cProdDestino,cDescProdDestino,cOrigenReg,iIdRegistro;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_consultadetcuentas.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pDireccionMac = '' OR pNombreArchivo = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumTarjeta, cStatusCred,cNumCredito,cTipoTarjeta,cNombreCliente,cNombreEmbozado,cMaster,
			cDomicilioEnvio,cDescDomEnvio,cSucursal,cDescSucursal,cNumCliente,cProdDestino,cDescProdDestino,cOrigenReg,iIdRegistro;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNumTarjeta, cStatusCred,cNumCredito,cTipoTarjeta,cNombreCliente,cNombreEmbozado,cMaster,
			cDomicilioEnvio,cDescDomEnvio,cSucursal,cDescSucursal,cNumCliente,cProdDestino,cDescProdDestino,cOrigenReg,iIdRegistro;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumTarjeta, cStatusCred,cNumCredito,cTipoTarjeta,cNombreCliente,cNombreEmbozado,cMaster,
			cDomicilioEnvio,cDescDomEnvio,cSucursal,cDescSucursal,cNumCliente,cProdDestino,cDescProdDestino,cOrigenReg,iIdRegistro;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;			
		--AAME RQM 10 682-4 Se quita Trim del WHERE del Query principal y se le aplica trim por separado
		LET pNombreArchivo = TRIM(pNombreArchivo);
		
		FOREACH
			SELECT {+INDEX(bdicnweb:"informix".sw_cp_datosctastdc idx_sw_cp_datosctastdc_2)} SKIP pRegistros FIRST pRecuperacion num_tarjeta,status_cred,num_credito,tipo_tarjeta,
			nombre_cliente,nombre_embozado,master,
			--CASE WHEN master = 'M' THEN 'SI' WHEN master = 'V' THEN 'NO' ELSE '' END,
			domicilio_envio,sucursal,num_cliente,prod_destino,desc_prod_destino,origen_reg,id_registro
			INTO cNumTarjeta, cStatusCred,cNumCredito,cTipoTarjeta,cNombreCliente,cNombreEmbozado,
			cMaster,cDomicilioEnvio,cSucursal,cNumCliente,cProdDestino,cDescProdDestino,cOrigenReg,iIdRegistro
			FROM bdicnweb:"informix".sw_cp_datosctastdc 
			WHERE usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac
			--AND num_tarjeta NOT IN (SELECT num_tarjeta
			AND num_credito NOT IN (SELECT num_credito			
									FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdc 
									WHERE error_proceso = 'N' 
									AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac)
			GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14
			ORDER BY num_credito,num_tarjeta ASC
			
			--AAME RQM 10 682-4 Se quita Case When del Select por reglas de BD. y se reemplaza por condicionales
			IF NVL(cMaster,'') = 'M' THEN 
				LET cMaster = 'SI'; 
			ELIF NVL(cMaster,'')= 'V' THEN 
				LET cMaster='NO'; 
			ELSE 
				LET cMaster = ''; 
			END IF;
			
			-- RECUPERA DOMICILIO ENVÍO DEL TITULAR PARA HOMOLOGAR TARJETAS ADICIONALES
			IF NVL(cTipoTarjeta,'') = 'ADI' THEN
				
				SELECT domicilio_envio, sucursal, prod_destino, desc_prod_destino INTO cDomicilioEnvio, cSucursal, cProdDestino, cDescProdDestino
				FROM bdicnweb:"informix".sw_cp_datosctastdc
				WHERE num_credito = cNumCredito AND tipo_tarjeta = 'TIT' 
				AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
				
				UPDATE bdicnweb:"informix".sw_cp_datosctastdc SET domicilio_envio = cDomicilioEnvio, sucursal = cSucursal, prod_destino = cProdDestino, desc_prod_destino = cDescProdDestino
				WHERE id_registro = iIdRegistro AND num_credito = cNumCredito AND tipo_tarjeta = cTipoTarjeta 
				AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac;
				
			END IF;
			
			IF NVL(cDomicilioEnvio,'') <> '' THEN
				SELECT desc_tipo_dir 
				INTO cDescDomEnvio	
				FROM bdinteg:"informix".si_tipo_dir_upg WHERE empresa = '001' AND tipo_dir = cDomicilioEnvio;
				
				IF NVL(cDomicilioEnvio,'') = '3' THEN
					SELECT nombre
					INTO cDescSucursal
					FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND sucursal = cSucursal;
				ELSE 
					--LET cSucursal = '';
					LET cDescSucursal = '';
				END IF;
			ELSE
				LET cDescDomEnvio = '';
				LET cDescSucursal = '';
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNumTarjeta, UPPER(cStatusCred),cNumCredito,UPPER(cTipoTarjeta),UPPER(cNombreCliente),UPPER(cNombreEmbozado),
			UPPER(cMaster),cDomicilioEnvio,NVL(UPPER(cDescDomEnvio),''),cSucursal,NVL(UPPER(cDescSucursal),''),
			cNumCliente,cProdDestino,UPPER(cDescProdDestino),cOrigenReg,iIdRegistro WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cNumTarjeta, cStatusCred,cNumCredito,cTipoTarjeta,cNombreCliente,cNombreEmbozado,cMaster,
			cDomicilioEnvio,cDescDomEnvio,cSucursal,cDescSucursal,cNumCliente,cProdDestino,cDescProdDestino,cOrigenReg,iIdRegistro;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNumTarjeta, cStatusCred,cNumCredito,cTipoTarjeta,cNombreCliente,cNombreEmbozado,cMaster,
			cDomicilioEnvio,cDescDomEnvio,cSucursal,cDescSucursal,cNumCliente,cProdDestino,cDescProdDestino,cOrigenReg,iIdRegistro;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 28/04/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÓN MASIVA', 
'DESCRIPCION: SPL encargado de consultar el detalle de las cuentas a las cuales se les va a aplicar el cambio de producto.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 30/04/2019',
'DESCRIPCION: Se modifica spl para agregar nuevas reglas de negocio RQM 10 682-4.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 23/05/2019',
'DESCRIPCION: Se modifica spl para cambiar el filtro que descarta los registros con errores de negocio (num_credito por num_tarjeta).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_consultadetcuentas_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(12), pNombreArchivo CHAR(35))
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_consultadetcuentas_totales.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pDireccionMac = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;			

		LET pNombreArchivo = TRIM(pNombreArchivo);
		SELECT COUNT(*)
		INTO iNumRegistros
		FROM bdicnweb:"informix".sw_cp_datosctastdc 
		WHERE usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac
		--AND num_tarjeta NOT IN (SELECT num_tarjeta 
		AND num_credito NOT IN (SELECT num_credito
								FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdc 
								WHERE error_proceso = 'N' 
								AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac);			
			
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet,iNumRegistros;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 28/04/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÓN MASIVA', 
'DESCRIPCION: SPL encargado de consultar el número total de las cuentas a las cuales se les va a aplicar el cambio de producto.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 30/04/2019',
'DESCRIPCION: Se modifica spl para agregar nuevas reglas de negocio RQM 10 682-4.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 23/05/2019',
'DESCRIPCION: Se modifica spl para cambiar el filtro que descarta los registros con errores de negocio (num_credito por num_tarjeta).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_rep_prod_upgrade2(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaIni DATE, pFechaFin DATE, pTipo CHAR(1), pStatus CHAR(1), pArchivo CHAR(50), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,		
		CHAR(20) AS num_credito,
		CHAR(20) AS num_tarjeta,		  
        CHAR(10) AS tipo_tarjeta,
		CHAR(100) AS nombre,
		DATE AS fecha,
        CHAR(15) AS resultado,
		CHAR(3) AS marcaje,
		CHAR(2) AS sol_plastico,
		CHAR(100) AS mensaje_error;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	DEFINE cNombreEmbozado CHAR(100);
	DEFINE cNumCredito   CHAR(20);
	DEFINE cTipoTarjeta  CHAR(10);
	DEFINE cMiembro       CHAR(2);
	DEFINE dFecha		  DATE;
	DEFINE cResultado     CHAR(15);
	DEFINE cDescripcion   CHAR(100);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cMarcaje CHAR(3);
	DEFINE cSolPlastico CHAR(2);
	DEFINE cMensajeError CHAR(100);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;
	LET cNombreEmbozado = '';
	LET cNumCredito = '';
	LET cTipoTarjeta = '';
	LET cMiembro = '';
	LET dFecha = date(1);
	LET cResultado = '';
	LET cDescripcion = '';
	LET cNumTarjeta = '';
	LET cMarcaje = '';
	LET cSolPlastico = '';
	LET cMensajeError = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_rep_prod_upgrade2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaIni = '' OR pFechaFin = '' OR pTipo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".sp_rep_prod_upgrade2(cEmpresa, pFechaIni, pFechaFin, pTipo, pStatus, pArchivo, pRegistros, pRecuperacion)
			--INTO cCodRetSp,cDescripcion,cNombreEmbozado,cNumCredito,cTipoTarjeta,cMiembro,dFecha,cResultado
			INTO cCodRetSp,cDescripcion,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError		  
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP:bdicred:sp_rep_prod_upgrade2";		
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '00973';
				RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError;
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			--RETURN cCodRet, NVL(UPPER(cNombreEmbozado),''), NVL(UPPER(cNumCredito),''), NVL(UPPER(cTipoTarjeta),''), NVL(UPPER(cMiembro),''), NVL(dFecha,''), NVL(UPPER(cResultado),'') WITH RESUME;
			RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,NVL(UPPER(cNombreEmbozado),''),dFecha,NVL(UPPER(cResultado),''),cMarcaje,cSolPlastico,NVL(UPPER(cMensajeError),'') WITH RESUME;
			
		END FOREACH;
		
		IF NVL(iRecuperacion,0) = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cNumCredito,cNumTarjeta,cTipoTarjeta,cNombreEmbozado,dFecha,cResultado,cMarcaje,cSolPlastico,cMensajeError;
		END IF;
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 30/03/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO PRODUCTO MANUAL',
'DESCRIPCION: ESTE PROCEDIMIENTO EJECUTA UN SP CLONADO QUE LLENA EL COMBO PARA LA PANTALLA DE REPORTES Y LLENA EL GRID DE ESTA MISMA',
'AUTOR: L. Montserrat León Amador',
'FECHA: 03/05/2019',
'DESCRIPCION: Se modifica spl para agregar nuevas reglas de negocio RQM 10 682-4.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_updatedatoscuentastdc(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(12), pNombreArchivo CHAR(35))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS bandera_det_error; 
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDesCodRetSp CHAR(100);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cRenglon CHAR(400);
	DEFINE iLinea INTEGER;
	DEFINE cCampo CHAR(35);
	DEFINE cDesMensajeError CHAR(120);
	DEFINE iContador INTEGER;
	DEFINE cBanDetError CHAR(1);
	
	DEFINE cNumCredito_Sol CHAR(20);
	
	DEFINE cNumCredito_Up CHAR(20);
	DEFINE cNumTarjeta_Up CHAR(20);
	DEFINE cMaster_Up CHAR(1);
	DEFINE cDomicilio_Up CHAR(1);
	DEFINE cSucursal_Up CHAR(4);
	DEFINE cProdDestino_Up CHAR(4);
	DEFINE cDescProdDestino_Up CHAR(40);
	DEFINE cNumCredito_sp CHAR(20);
	DEFINE cStatusCred_sp CHAR(2);		  
	DEFINE cTipoTarjeta_sp CHAR(3);
	DEFINE cNomCliente_sp CHAR(30);
	DEFINE cNomEmbozado_sp CHAR(21);
	DEFINE cNumTarjeta_sp CHAR(20);
	DEFINE cNumCliente_sp CHAR(20);	
	DEFINE cNumTarjeta CHAR(20);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDesCodRetSp = '';
	LET iSqlErr = 0;
	LET cIdCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cRenglon = '';
	LET iLinea = 0;
	LET cCampo = '';
	LET cDesMensajeError = '';
	LET iContador = 0;
	LET cBanDetError = 'f';
	
	LET cNumCredito_Sol = '';
	
	LET cNumCredito_Up = '';
	LET cNumTarjeta_Up = '';
	LET cMaster_Up = '';
	LET cDomicilio_Up = '';
	LET cSucursal_Up = '';
	LET cProdDestino_Up = '';
	LET cDescProdDestino_Up = '';
	
	LET cNumCredito_sp = '';
	LET cStatusCred_sp = '';		  
	LET cTipoTarjeta_sp = '';
	LET cNomCliente_sp = '';
	LET cNomEmbozado_sp = '';
	LET cNumTarjeta_sp = '';
	LET cNumCliente_sp = '';	
	LET cNumTarjeta = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
			    
				SET LOCK MODE TO WAIT 3;
				UPDATE bdicnweb:"informix".sw_cp_statuslecturadatosctastdc
				SET  status = 'E', error_proceso = 'S', error = TRIM(cCodRet) 
				WHERE usuario = TRIM(pUsuario) AND tipo_proceso = 'LECTURA' AND nombre_archivo = TRIM(pNombreArchivo);
				
				RETURN cCodRet,cBanDetError; 
			END IF;
		END EXCEPTION;			
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_updatedatoscuentastdc.out';
		--TRACE ON;
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;		
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pDireccionMac = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';

			UPDATE bdicnweb:"informix".sw_cp_statuslecturadatosctastdc
			SET  status = 'E', error_proceso = 'S', error = TRIM(cCodRet) 
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
			
			RETURN cCodRet,cBanDetError; 
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN

			UPDATE bdicnweb:"informix".sw_cp_statuslecturadatosctastdc
			SET  status = 'E', error_proceso = 'S', error = TRIM(cCodRet) 
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
			
			RETURN cCodRet,cBanDetError; 
		END IF;
		
		-- SE LIMPIA TABLA POR USUARIO Y PROCESO
		DELETE FROM bdicnweb:"informix".sw_cp_statuslecturadatosctastdc
		WHERE usuario = TRIM(pUsuario) AND tipo_proceso = 'LECTURA' AND nombre_archivo = TRIM(pNombreArchivo);
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO bdicnweb:"informix".sw_cp_statuslecturadatosctastdc(usuario,nombre_archivo,status,bandera_det_error,error_proceso,tipo_proceso,error)
		VALUES(pUsuario,TRIM(pNombreArchivo),'I','','','LECTURA','');

		-- LIMPIA TABLA PRINCIPAL
		DELETE FROM bdicnweb:"informix".sw_cp_datosctastdc WHERE usuario = pUsuario AND direccion_mac = pDireccionMac;
		-- AAME 12062019 RQM 10 682-4 LIMPIA TABLA DE CONTEO DE REGISTROS EXITOSOS Y NO EXITOSOS
		DELETE FROM bdicnweb:"informix".sw_cred_cambioproducto WHERE us_insert = pUsuario AND fecha_insert = DATE(CURRENT);
		   
		
		FOREACH
		
			SELECT DISTINCT num_credito INTO cNumCredito_Sol
			FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdc
			WHERE tipo_tarjeta = 'T' AND usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac
			
			FOREACH
				/* AAME 24062019 RQM 10 682-4 SE QUITA INSERT- SELECT A PETICION DE BD
				INSERT INTO bdicnweb:"informix".sw_cp_datosctastdc(num_tarjeta,status_cred,num_credito,tipo_tarjeta,nombre_cliente,
				nombre_embozado,master,domicilio_envio,sucursal,num_cliente,prod_destino,desc_prod_destino,origen_reg,usuario,
				nombre_archivo,direccion_mac,fecha_insert)
				--SELECT cNumTarjeta_sp,cStatusCred_sp,cNumCredito_sp,cTipoTarjeta_sp,cNomCliente_sp,
				SELECT cNumTarjeta_sp,cStatusCred_sp,cNumCredito_Sol,cTipoTarjeta_sp,cNomCliente_sp,
				cNomEmbozado_sp,'','','',cNumCliente_sp,'','','B',pUsuario,pNombreArchivo,pDireccionMac,DATE(CURRENT)
				FROM TABLE (PROCEDURE bdicred:"informix".sp_mostrar_grid_upgrade('001',cNumCredito_Sol,'0',''))
				AS sp_mostrar_grid_upgrade(cCodRetSp, cNumCredito_sp, cStatusCred_sp, cTipoTarjeta_sp, cNomCliente_sp, cNomEmbozado_sp, cNumTarjeta_sp, cNumCliente_sp);*/
				
				EXECUTE PROCEDURE bdicred:"informix".sp_mostrar_grid_upgrade('001',cNumCredito_Sol,'0','')
				INTO cCodRetSp, cNumCredito_sp, cStatusCred_sp, cTipoTarjeta_sp, cNomCliente_sp, cNomEmbozado_sp, cNumTarjeta_sp, cNumCliente_sp

				INSERT INTO bdicnweb:"informix".sw_cp_datosctastdc(num_tarjeta,status_cred,num_credito,tipo_tarjeta,nombre_cliente,
				nombre_embozado,master,domicilio_envio,sucursal,num_cliente,prod_destino,desc_prod_destino,origen_reg,usuario,
				nombre_archivo,direccion_mac,fecha_insert)
				VALUES(cNumTarjeta_sp, cStatusCred_sp, cNumCredito_Sol, cTipoTarjeta_sp, cNomCliente_sp, cNomEmbozado_sp,'','','',cNumCliente_sp,'','','B',pUsuario,pNombreArchivo,pDireccionMac,DATE(CURRENT));
			
			END FOREACH;
						
		END FOREACH;
		
		FOREACH
			SELECT num_credito,num_tarjeta,aceptacion,domicilio_envio,sucursal,prod_destino 
			INTO cNumCredito_Up,cNumTarjeta_Up,cMaster_Up,cDomicilio_Up,cSucursal_Up,cProdDestino_Up 
			FROM bdicnweb:"informix".sw_cp_procesadetallearchivotdc 
			WHERE usuario = pUsuario AND nombre_archivo = pNombreArchivo AND direccion_mac = pDireccionMac
			ORDER BY id_registro ASC
			
			SELECT num_tarjeta 
			INTO cNumTarjeta
			FROM bdicnweb:"informix".sw_cp_datosctastdc 
			WHERE num_credito = cNumCredito_Up AND num_tarjeta = cNumTarjeta_Up
			AND usuario = pUsuario AND direccion_mac = pDireccionMac AND nombre_archivo = pNombreArchivo;
			--AAME 25062019 Se quita if exists a peticion de BD.
			IF cNumTarjeta <> '' THEN
			
				SELECT nombre_prod
				INTO cDescProdDestino_Up
				FROM bdicred:"informix".sd_definicion WHERE empresa = '001' AND num_producto = cProdDestino_Up;
	
				UPDATE bdicnweb:"informix".sw_cp_datosctastdc
				SET master = cMaster_Up, domicilio_envio = cDomicilio_Up, sucursal = cSucursal_Up, 
				prod_destino = cProdDestino_Up, desc_prod_destino = cDescProdDestino_Up, origen_reg = 'A'
				WHERE num_credito = cNumCredito_Up AND num_tarjeta = cNumTarjeta_Up
				AND usuario = pUsuario AND direccion_mac = pDireccionMac AND nombre_archivo = pNombreArchivo;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
					LET cBanDetError = 't';
					LET cCodRet = '00283';
					
					UPDATE bdicnweb:"informix".sw_cp_statuslecturadatosctastdc
					SET  status = 'E', error_proceso = 'S', error = cCodRet
					WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
					
					RETURN cCodRet,cBanDetError;
				END IF;	
	
			--ELSE
			
			END IF;
		END FOREACH;
		
		LET cBanDetError = TRIM(UPPER(cBanDetError));
		UPDATE bdicnweb:"informix".sw_cp_statuslecturadatosctastdc
		SET status = 'T', error_proceso = 'N', bandera_det_error = cBanDetError
		WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA' AND nombre_archivo = pNombreArchivo;
		
		RETURN cCodRet,cBanDetError; 
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 28/04/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÓN MASIVA', 
'DESCRIPCION: SPL encargado de consultar y agregar el detalle de todas las tarjetas adicionales que tienen las cuentas titulares',
'y que no se encontraron en el archivo de carga.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 23/05/2019',
'DESCRIPCION: Se modifica spl para asegurar el número de credito en la tabla sw_cp_datosctastdc de cada registro (cNumCredito_Sol).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cp_verificastatusarchivo(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(35))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(1) AS bandera_det_error,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,
		INTEGER AS total,
		INTEGER AS procesados,
		INTEGER AS no_procesados;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cBanDetError CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iTotal INTEGER;
	DEFINE iProcesados INTEGER;
	DEFINE iNoProcesados INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cBanDetError = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iTotal = 0;
	LET iProcesados = 0;
	LET iNoProcesados = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,cBanDetError,cErrorProceso,cError,iTotal,iProcesados,iNoProcesados;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_verificastatusarchivo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cBanDetError,cErrorProceso,cError,iTotal,iProcesados,iNoProcesados;	
		END IF;		
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cBanDetError,cErrorProceso,cError,iTotal,iProcesados,iNoProcesados;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status,bandera_det_error,error_proceso,error,total_registros,total_procesados,total_noprocesados
		INTO cStatus,cBanDetError,cErrorProceso,cError,iTotal,iProcesados,iNoProcesados
		FROM bdicnweb:"informix".sw_cp_statuslecturaarchivotdc
		WHERE usuario = TRIM(pUsuario) AND nombre_archivo = TRIM(pNombreArchivo);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			RETURN cCodRet,'I','','','',0,0,0;			
		ELSE 			
			RETURN cCodRet,cStatus,cBanDetError,cErrorProceso,cError,iTotal,iProcesados,iNoProcesados;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 24/04/2017',
'MODULO: CREDITO',
'FUNCIONALIDAD: CAMBIO DE PRODUCTO DE TDC OPERACIÓN MASIVA', 
'DESCRIPCION: SPL encargado de hacer la validación inicio/fin para el proceso de lectura de archivos.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 30/04/2019',
'DESCRIPCION: Se modifica spl para agregar nuevas reglas de negocio RQM 10 682-4.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_usuario_movil_ws(pEjecutivoAlta CHAR(8), pPassword  CHAR(20), pImei CHAR(20),pImeiAnt CHAR(20),
                                                                                        pActivo CHAR(1), pNombre CHAR(60), pCentro_costos CHAR(8), pSucursal CHAR(4),
                                                                                        pNo_telefono CHAR(10), pGenerico1 CHAR(20), pGenerico2 CHAR(30), 
                                                                                        pGenerico3 CHAR(40), ptipoOperacion INTEGER)
                RETURNING CHAR(5) AS codret,INTEGER AS iNoRegistros;
                
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iCodRetSp INTEGER;
        DEFINE iNoRegistros INTEGER;
        DEFINE bExisteUsuario BOOLEAN;
		DEFINE inoImei INTEGER;
		DEFINE bInTransaction BOOLEAN;
		DEFINE pUsuario CHAR(8);
		DEFINE vEjecutivo CHAR(8);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iCodRetSp = 0;
        LET iNoRegistros = 0;
        LET bExisteUsuario = 'f';
        LET inoImei = 0;
		LET bInTransaction = 'f';
		LET pUsuario = 'admonusr';
		LET vEjecutivo = '';
		
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, iNoRegistros;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/informix/LIP/sp_usuario_movil_ws.out';
                --TRACE ON;
        
				IF pPassword = '' OR   pImei = '' OR pActivo= '' OR pNombre = '' OR
                   pSucursal = '' OR pNo_telefono = '' OR ptipoOperacion IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, iNoRegistros;
                END IF;
		
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
		
                IF ptipoOperacion = 1 THEN
					-- Se valida que el ejecutivo no exista en la tabla
					
					SELECT ejecutivo
					INTO vEjecutivo
					FROM bdinteg:"informix".si_usuario_movil
					WHERE  ejecutivo = pEjecutivoAlta
					AND imei = pImei;
					
					IF (vEjecutivo IS NOT NULL AND vEjecutivo <> '')THEN
						LET cCodRet = '00479';
					ELSE	
						INSERT INTO bdinteg:"informix".si_usuario_movil (ejecutivo, password, imei, activo, nombre,centro_costos,
									no_telefono, generico1, generico2, generico3, fecha_insert,	user_insert, fecha_baja, user_baja, sucursal) 
						VALUES (pEjecutivoAlta, pPassword, pImei, pActivo, pNombre, pCentro_costos, pNo_telefono, pGenerico1,
									pGenerico2, pGenerico3, CURRENT, pUsuario, NULL, NULL,pSucursal);
																					
								LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
								IF iNoRegistros = 0 THEN -- 
									LET cCodRet = '00282';
								END IF;
                                                        
					END IF;
					RETURN cCodRet, iNoRegistros;
                
                END IF;

                IF  ptipoOperacion = 2 THEN 		
					IF pImei = pImeiAnt THEN
						UPDATE bdinteg:"informix".si_usuario_movil SET
                        password= pPassword,
                        imei= pImei,
                        activo= pActivo,
                        nombre = pNombre,
                        centro_costos=pCentro_costos,
                        no_telefono= pNo_telefono, 
                        generico1= pGenerico1, 
                        generico2= pGenerico2, 
                        generico3= pGenerico3, 
                        sucursal=pSucursal
                        WHERE ejecutivo=pEjecutivoAlta
						AND imei= pImeiAnt;
						
						IF(pActivo = '0') THEN
							UPDATE bdinteg:"informix".si_usuario_movil SET
							fecha_baja= CURRENT, 
							user_baja= pUsuario
							WHERE ejecutivo=pEjecutivoAlta
							AND imei= pImeiAnt;
						END IF
                        
                        LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
                        IF iNoRegistros = 0 THEN
                                LET cCodRet = '00001';
                        ELIF iNoRegistros > 1 THEN
                                LET cCodRet = '00283'; -- Se actulizaron mas de 1 registro
                        END IF;
						RETURN cCodRet, iNoRegistros;
					ELSE
						BEGIN
							ON EXCEPTION IN (-535)
								COMMIT; -- Transaccion del interact
								BEGIN WORK;
								LET bInTransaction = 't';
							END EXCEPTION WITH RESUME;
						
							BEGIN WORK;
							UPDATE bdinteg:"informix".si_usuario_movil SET
							password= pPassword,
							imei= pImei,
							activo= pActivo,
							nombre = pNombre,
							centro_costos=pCentro_costos,
							no_telefono= pNo_telefono, 
							generico1= pGenerico1, 
							generico2= pGenerico2, 
							generico3= pGenerico3, 
							sucursal=pSucursal
							WHERE ejecutivo=pEjecutivoAlta
							AND imei= pImeiAnt;
							
							IF(pActivo = '0') THEN
								UPDATE bdinteg:"informix".si_usuario_movil SET
								fecha_baja= CURRENT, 
								user_baja= pUsuario
								WHERE ejecutivo=pEjecutivoAlta
								AND imei= pImeiAnt;
							END IF
							
							SELECT COUNT(imei) INTO inoImei FROM bdinteg:"informix".si_usuario_movil WHERE imei= pImei AND ejecutivo = pEjecutivoAlta;
							IF inoImei = 1 THEN
								COMMIT WORK;
							ELSE
								ROLLBACK WORK;
								LET cCodRet = '00480'; -- El imei ya fue asignado anteriormente a este usuario
							END IF;
							
							IF bInTransaction THEN
								BEGIN WORK; -- APERTURA DE LA TRANSACCION DEL INTERACT
							END IF;
							
							RETURN cCodRet, iNoRegistros;
						END;
					END IF;
					
                END IF;
        END;
        
END PROCEDURE;