CREATE PROCEDURE "informix".sp_cnt_consultadetallesolicitudes(pUsuario CHAR(8), pIdFuncion CHAR(10), pSt CHAR(2),
pSolicitud CHAR(1), pAgrupamiento CHAR(35), pNumCte CHAR(20), pNumCred CHAR(20), pSucursal CHAR(4), pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		INTEGER AS iEstatusos,		  --ESTATUS
		SMALLINT AS sNumerocobranzas, --NUMERO DE COBRANZAS
		CHAR(40) AS cNombre,		  --NOMBRE DE SUCURSAL
		CHAR(5) AS cAbrevia_prod,	  --ABREVIATURA DE PRODUCTO
		CHAR(20) AS cNum_solicitud,	  --NUMERO DE SOLICITUD
		DATE AS dFechasolic,	      --FECHA DE REGISTRO
		CHAR(2) AS cStatus_solicitud, --ESTATUS DE SOLICITUD
		CHAR(170) AS cNombre_cliente, --NOMBRE DEL CLIENTE
		DATE AS dFecha_nac,			  --FECHA DE NACIMIENTO
		CHAR(50) AS cFolio,			  --FOLIO
		CHAR(20) AS cFechaos,		  --FECHA DE OS
		INTEGER AS iDias,			  --DIAS
		CHAR(30) AS cNombrecalle,	  --NOMBRE DE CALLE
		CHAR(10) AS cNumeroextcalle,  --NUMERO EXTERIOR
		CHAR(10) AS cNumerointcalle,  --NUMERO INTERIOR
		CHAR(80) AS cComplemento,	  --COMPLEMENTO
		CHAR(50) AS cZona,			  --COLONIA
		CHAR(10) AS cCiudad,		  --CIUDAD
		CHAR(10) AS cEstado,		  --ESTADO
		CHAR(13) AS cTelefono1,		  --TELEFONO 1
		CHAR(13) AS cTelefono2,		  --TELEFONO 2
		CHAR(13) AS cTelefono3,       --TELEFONO 3
		CHAR(30) AS cNombreRegion_os, --
		CHAR(20) AS cNumCliente_os;	  --
	                 
    DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	DEFINE iEstatusos INTEGER;		
	DEFINE sNumerocobranzas SMALLINT;
	DEFINE cNombre CHAR(40);		
	DEFINE cAbrevia_prod CHAR(5);	
	DEFINE cNum_solicitud CHAR(20);	
	DEFINE dFechasolic DATE;		
	DEFINE cStatus_solicitud CHAR(2);
	DEFINE cNombre_cliente CHAR(170);
	DEFINE dFecha_nac DATE;			
	DEFINE cFolio CHAR(50);			
	DEFINE cFechaos CHAR(20);		
	DEFINE iDias INTEGER;			
	DEFINE cNombrecalle CHAR(30);	
	DEFINE cNumeroextcalle CHAR(10);
	DEFINE cNumerointcalle CHAR(10);
	DEFINE cComplemento CHAR(80);	
	DEFINE cZona CHAR(50);			
	DEFINE cCiudad CHAR(10);		
	DEFINE cEstado CHAR(10);		
	DEFINE cTelefono1 CHAR(13);		
	DEFINE cTelefono2 CHAR(13);		
	DEFINE cTelefono3 CHAR(13);
	DEFINE cNombreRegion_os CHAR(30);
	DEFINE cNumCliente_os CHAR(20);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRet = 0;
	LET iSqlErr = 0;
	LET cEmpresa = '';    
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	LET iEstatusos = 0;		
	LET sNumerocobranzas = 0;
	LET cNombre = '';		
	LET cAbrevia_prod = '';	
	LET cNum_solicitud = '';	
	LET dFechasolic = '';		
	LET cStatus_solicitud = '';
	LET cNombre_cliente = '';
	LET dFecha_nac = '';			
	LET cFolio = '';			
	LET cFechaos = '';		
	LET iDias = 0;			
	LET cNombrecalle = '';	
	LET cNumeroextcalle = '';
	LET cNumerointcalle = '';
	LET cComplemento = '';	
	LET cZona = '';		
	LET cCiudad = '';		
	LET cEstado = '';		
	LET cTelefono1 = '';		
	LET cTelefono2 = '';		
	LET cTelefono3 = '';
	LET cNombreRegion_os = '';
	LET cNumCliente_os = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet,iEstatusos,sNumerocobranzas,cNombre,cAbrevia_prod,cNum_solicitud,dFechasolic,cStatus_solicitud,
			cNombre_cliente,dFecha_nac,cFolio,cFechaos,iDias,cNombrecalle,cNumeroextcalle,cNumerointcalle,
			cComplemento,cZona,cCiudad,cEstado,cTelefono1,cTelefono2,cTelefono3,cNombreRegion_os,cNumCliente_os;			
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnt_consultadetallesolicitudes.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iEstatusos,sNumerocobranzas,cNombre,cAbrevia_prod,cNum_solicitud,dFechasolic,cStatus_solicitud,
			cNombre_cliente,dFecha_nac,cFolio,cFechaos,iDias,cNombrecalle,cNumeroextcalle,cNumerointcalle,
			cComplemento,cZona,cCiudad,cEstado,cTelefono1,cTelefono2,cTelefono3,cNombreRegion_os,cNumCliente_os;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,iEstatusos,sNumerocobranzas,cNombre,cAbrevia_prod,cNum_solicitud,dFechasolic,cStatus_solicitud,
			cNombre_cliente,dFecha_nac,cFolio,cFechaos,iDias,cNombrecalle,cNumeroextcalle,cNumerointcalle,
			cComplemento,cZona,cCiudad,cEstado,cTelefono1,cTelefono2,cTelefono3,cNombreRegion_os,cNumCliente_os;
		END IF;
		
		-- VALIDACIÓN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iEstatusos,sNumerocobranzas,cNombre,cAbrevia_prod,cNum_solicitud,dFechasolic,cStatus_solicitud,
			cNombre_cliente,dFecha_nac,cFolio,cFechaos,iDias,cNombrecalle,cNumeroextcalle,cNumerointcalle,
			cComplemento,cZona,cCiudad,cEstado,cTelefono1,cTelefono2,cTelefono3,cNombreRegion_os,cNumCliente_os;
		END IF;
		
		IF pAgrupamiento = 'ESTATUS' THEN
			LET pAgrupamiento = 'STATUS';
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH 
		
			SELECT SKIP pRegistros FIRST pRecuperacion estatusos,numerocobranzas,nombre,abrevia_prod,
			num_solicitud,fechasolic,status_solicitud,nombre_cliente,fecha_nac,folio,fechaos,dias,nombrecalle,	
			numeroextcalle,numerointcalle,complemento,zona,ciudad,estado,telefono1,telefono2,telefono3,nombreregion,num_cliente
			INTO iEstatusos,sNumerocobranzas,cNombre,cAbrevia_prod,cNum_solicitud,dFechasolic,cStatus_solicitud,
			cNombre_cliente,dFecha_nac,cFolio,cFechaos,iDias,cNombrecalle,cNumeroextcalle,cNumerointcalle,
			cComplemento,cZona,cCiudad,cEstado,cTelefono1,cTelefono2,cTelefono3,cNombreRegion_os,cNumCliente_os
			FROM bdicnweb:"informix".sw_cnt_detallemonitorsol
			WHERE usuario_insert = pUsuario
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,iEstatusos,sNumerocobranzas,cNombre,cAbrevia_prod,cNum_solicitud,dFechasolic,cStatus_solicitud,
			cNombre_cliente,dFecha_nac,cFolio,cFechaos,iDias,cNombrecalle,cNumeroextcalle,cNumerointcalle,
			cComplemento,cZona,cCiudad,cEstado,cTelefono1,cTelefono2,cTelefono3,cNombreRegion_os,cNumCliente_os WITH RESUME;
						
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,iEstatusos,sNumerocobranzas,cNombre,cAbrevia_prod,cNum_solicitud,dFechasolic,cStatus_solicitud,
			cNombre_cliente,dFecha_nac,cFolio,cFechaos,iDias,cNombrecalle,cNumeroextcalle,cNumerointcalle,
			cComplemento,cZona,cCiudad,cEstado,cTelefono1,cTelefono2,cTelefono3,cNombreRegion_os,cNumCliente_os;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,iEstatusos,sNumerocobranzas,cNombre,cAbrevia_prod,cNum_solicitud,dFechasolic,cStatus_solicitud,
			cNombre_cliente,dFecha_nac,cFolio,cFechaos,iDias,cNombrecalle,cNumeroextcalle,cNumerointcalle,
			cComplemento,cZona,cCiudad,cEstado,cTelefono1,cTelefono2,cTelefono3,cNombreRegion_os,cNumCliente_os;
		END IF;
		
	END;
END PROCEDURE
