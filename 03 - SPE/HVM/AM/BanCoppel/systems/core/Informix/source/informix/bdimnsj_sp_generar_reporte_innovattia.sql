CREATE PROCEDURE "informix".sp_generar_reporte_innovattia()
RETURNING 	VARCHAR(6) AS cCodRet,
			VARCHAR(40) AS cMensaje,
			VARCHAR(40) AS cRegistros;
			
		  
/*DEFINICION DE VARIABLES */

DEFINE 	cCodRet      	  VARCHAR(6);
DEFINE 	cMensaje      	  VARCHAR(40);
DEFINE 	cRegistros     	  VARCHAR(40);
DEFINE 	vsNombreArchivo   VARCHAR(50);
DEFINE  cSQL			  VARCHAR(250);
DEFINE  cSQL1			  LVARCHAR(500);
DEFINE  iCont			  INTEGER;	
DEFINE  iSqlErr			  INTEGER;
DEFINE  vTelefono		  VARCHAR(13);
DEFINE	dFecha_hora		  DATETIME YEAR TO SECOND;

/*FIN DE DEFINICION DE VARIABLES*/
LET cCodRet   = 0;
LET cMensaje   = '';
LET cRegistros = '';
LET vsNombreArchivo = '';
LET cSQL	    = '';
LET cSQL1	    = '';	  
LET iCont	    = 0;	  
LET iSqlErr     = 0;
LET vTelefono	= '';
LET dFecha_hora = DATE(0);

/*FIN DE INICIALIZACION*/

--SET DEBUG FILE TO "/tmp/cristo/bdimnsj/sp_generar_reporte_innovattia.out";
--TRACE ON;

BEGIN
	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN -- manejador de errores
			LET cCodRet = iSqlErr;
			LET cMensaje  = 'ERROR AL GENERAR REPORTE';
			LET cRegistros  = 'REGISTROS: '||iCont;
			RETURN cCodRet,cMensaje,cRegistros;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	TRUNCATE bdimnsj:"informix".tmp_sms_innovattia;
	
	--Nombre del archivo
	LET vsNombreArchivo = '/RESPALDOSNEW/REPORTE_SMS_INNOVATTIA.csv';
						
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	FOREACH	WITH HOLD
		--- SMS enviados por Innovattia
		SELECT '52'||celular_alterno as telefono, fecha_hora_registro  INTO vTelefono,dFecha_hora
		FROM "informix".mnsjr_trx_online
		WHERE fecha_hora_registro between current - 1 UNITS HOUR and current
		and transaction_id <> 'PENDIENTE' and transaction_id is not null
		and id_mensaje in ('POS_DEBS','ATM_DEBS','POS_CREDS','ATM_CREDS','HUL_MANTTO','NIP_MANTTO','PYT_ATMAS','CUB_SMS','IVR_ALTA','AUT_SINREC','INCR_CRED','OFI_AVSMS','ACL_SMS','PORTACECSM','SMS_RECI','PORTAL_SMS','VAL_AURO','VAL_INNO','ADN_SMS','CANTJT_SMS','TJTPER_SMS','SMS_ACT_IC','TJTSMS_SIA','TJTPESMS2','TJTPESMS3','TJTPESMS4','SMS_CAMNIP','SMS_FPG','SPEI_SMREC','51TJNP_SMS','0137TX_SMS','1CPANP_SMS','SMS_ACT_TA','SMS_ER_ACT','PROD_SMS','CIT_PRO_CA','OPER_SMS')
		and celular_alterno <> ''
		
		LET iCont=iCont+1;
		
		INSERT INTO "informix".tmp_sms_innovattia(telefono, fecha_hora_registro) VALUES (vTelefono,dFecha_hora);
		
	END FOREACH; 
	
	FOREACH	WITH HOLD
		--- SMS enviados por Innovattia
		SELECT '52'||tel.telefono as telefono, sms.fecha_hora_registro  INTO vTelefono,dFecha_hora
		FROM bdimnsj@lat_tcp:"informix".mnsjr_trx_online sms, bdinteg:"informix".si_telefonos_actual tel
		WHERE sms.fecha_hora_registro between current - 1 UNITS HOUR and current
		and sms.transaction_id <> 'PENDIENTE' and sms.transaction_id is not null
		and sms.cliente <> '000000000'
		and sms.cliente = tel.numcte and tel.tipo_tel='2' and tel.status_tel='A'
		and id_mensaje in ('POS_DEBS','ATM_DEBS','POS_CREDS','ATM_CREDS','HUL_MANTTO','NIP_MANTTO','PYT_ATMAS','CUB_SMS','IVR_ALTA','AUT_SINREC','INCR_CRED','OFI_AVSMS','ACL_SMS','PORTACECSM','SMS_RECI','PORTAL_SMS','VAL_AURO','VAL_INNO','ADN_SMS','CANTJT_SMS','TJTPER_SMS','SMS_ACT_IC','TJTSMS_SIA','TJTPESMS2','TJTPESMS3','TJTPESMS4','SMS_CAMNIP','SMS_FPG','SPEI_SMREC','51TJNP_SMS','0137TX_SMS','1CPANP_SMS','SMS_ACT_TA','SMS_ER_ACT','PROD_SMS','CIT_PRO_CA','OPER_SMS')
		
		LET iCont=iCont+1;
		
		INSERT INTO "informix".tmp_sms_innovattia(telefono, fecha_hora_registro) VALUES (vTelefono,dFecha_hora);
		
	END FOREACH; 

	IF NVL(iCont,0) > 0 THEN
		LET cSQL1 = 'echo "UNLOAD TO '||TRIM(vsNombreArchivo)||' DELIMITER '','' SELECT telefono,fecha_hora_registro from bdimnsj:"informix".tmp_sms_innovattia " > /RESPALDOSNEW/generar_reporte_innovattia.sql';
		SYSTEM cSQL1;

		LET cSQL='dbaccess bdimnsj /RESPALDOSNEW/generar_reporte_innovattia.sql';
		SYSTEM cSQL;
		
		LET cMensaje  = 'REPORTE GENERADO CORRECTAMENTE';
		LET cRegistros  = 'REGISTROS: '||iCont;
		LET cCodRet = '000000';
	ELSE
		
		LET cMensaje  = 'NO SE ENCONTRARON REGISTROS';
		LET cRegistros  = 'REGISTROS: '||iCont;
		LET cCodRet = '000001';
	END IF;		
	RETURN cCodRet,cMensaje,cRegistros;
END;
END PROCEDURE;