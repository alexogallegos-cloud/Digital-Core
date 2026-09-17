CREATE PROCEDURE "informix".sp_consucursaltpo(pEmpresa CHAR(3) ,pNumSuc CHAR(4), pRegistro SMALLINT)

RETURNING
	CHAR(6)  		AS  COD_RET,
	VARCHAR(80) 	AS  MENS_RET,
	CHAR(4)  		AS  SUCURSAL,
	CHAR(40) 		AS  NOMSUCURSAL,
	DECIMAL(18,2) 	AS 	PAG;
	
	--DECLARACIONES
    DEFINE iSqlErr         	INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet         	CHAR(6);
    DEFINE vMensajeRet      VARCHAR(40);
	DEFINE cNumSuc          CHAR(4);
	DEFINE cNomSucursal     CHAR(40);
	DEFINE iTotSuc			INTEGER;
	DEFINE dPag				DECIMAL(18,2);
	
	
	--INICIALIZACIONES
    LET iSqlErr            = 0;
    LET iIsamErr           = 0;
    LET cErrorInfo         = "";
    LET cCodRet            = "000000";
    LET vMensajeRet        = "SE REALIZO LA CONSULTA CORRECTAMENTE";
	LET cNumSuc            = "";
	LET cNomSucursal       = "";
	LET iTotSuc			   = 0;
	LET dPag			   = 0;
	
	
	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET vMensajeRet = cErrorInfo;
				RETURN TRIM(cCodRet), TRIM(vMensajeRet), TRIM(NVL(cNumSuc, '')), TRIM(NVL(cNomSucursal, '')), NVL(dPag, 0);
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO '/home/sysifx/armandomorales/sp_considentificacion.out';
		--TRACE ON;
		
		--VALIDANDO LOS PARAMETROS.
		IF TRIM(NVL(pEmpresa, '')) = '' AND TRIM(NVL(pNumSuc, '')) = '' THEN
			LET cCodRet = "000001";
			LET vMensajeRet = "ERROR, EN LOS PARAMETROS";
			RETURN TRIM(cCodRet), TRIM(vMensajeRet), TRIM(NVL(cNumSuc, '')), TRIM(NVL(cNomSucursal, '')), NVL(dPag, 0);
		END IF;		
		
		--VALIDA SI VIENE SUCURSAL VACIA
		IF pNumSuc = "" THEN
			--OBTIENE EL NUMERO DE REGISTROS DE LA TABLA Y LOS DIVIDE ENTRE 10 PARA OBTENER EL NUMERO DE PAGINACION
			
			
			SELECT COUNT(sucursal) 
			INTO iTotSuc
			FROM bdinteg:"informix".si_sucursales
			WHERE sucursal = sucursal
			AND empresa = pEmpresa;
			
			LET dPag = iTotSuc/10;
				
			--CONSULTA LOS PRIMEROS 10 REGISTROS DEPENDIENDO DEL "SALTO" QUE SE LE INDIQUE
			FOREACH	
				SELECT SKIP pRegistro LIMIT 10 sucursal, nombre
				INTO cNumSuc, cNomSucursal
				FROM bdinteg:"informix".si_sucursales
				WHERE sucursal = sucursal
				AND empresa = pEmpresa
				ORDER BY sucursal
				
				RETURN cCodRet, TRIM(vMensajeRet), TRIM(cNumSuc), TRIM(cNomSucursal),dPag WITH RESUME;
			END FOREACH;			
		ELSE
			--CONSULTA NUMERO DE SUCURSAL Y NOMBRE VALIDANDO EMPRESA 
			SELECT sucursal, nombre
			INTO cNumSuc, cNomSucursal
			FROM bdinteg:"informix".si_sucursales 
			WHERE sucursal = pNumSuc
			AND empresa = pEmpresa;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet= "000002";
				LET vMensajeRet = "ERROR, NO SE ENCONTRO INFORMACION";				
			END IF;
			
			RETURN TRIM(cCodRet), TRIM(vMensajeRet), TRIM(NVL(cNumSuc, '')), TRIM(NVL(cNomSucursal, '')), NVL(dPag, 0);
		END IF;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= "000002";
			LET vMensajeRet = "ERROR, NO SE ENCONTRO INFORMACION";
			RETURN TRIM(cCodRet), TRIM(vMensajeRet), TRIM(NVL(cNumSuc, '')), TRIM(NVL(cNomSucursal, '')), NVL(dPag, 0);
		END IF;
	END
END PROCEDURE
DOCUMENT 
'DESCRIPCION : Se realiza procedimiento para Obtener el listado de Sucursales',
'AUTOR : Armando Morales Barraza',
'FECHA : 18/ABRIL/2012',
'BD    : BDINTEG';

CREATE PROCEDURE "informix".sp_consultarctemoral(pNumcte CHAR(20))

	RETURNING
		CHAR(6) 		AS COD_RET,	
		CHAR(13) 		AS RFC,
		CHAR(26) 		AS APELL_PATER_REP_LEG,
		CHAR(26) 		AS APELL_MATER_REP_LEG,
		CHAR(26) 		AS NOMB1_REP_LEG,
		CHAR(26) 		AS NOMB2_REP_LEG,		
		CHAR(40)   		AS CALLE_FISCAL,
		CHAR(10)   		AS NUM_EXT_CALLE_FISCAL,
		CHAR(60)   		AS COL_FISCAL,
		VARCHAR(60,1)  	AS NOM_CIUD_FISCAL,
		CHAR(3)   		AS COD_MUN_FISCAL,
		CHAR(30)    	AS NOM_ESTADO_FISCAL,
		CHAR(20) 		AS NUM_CTE,
		CHAR(30) 		AS NOM_CORTO,
		CHAR(30) 		AS PAG_INTERNET,
		CHAR(25) 		AS SAT_FEA,
		CHAR(15) 		AS TEL_CONTACTO,
		CHAR(20) 		AS GIRO,
		CHAR(40) 		AS NOM_GIRO,
		CHAR(3) 		AS ACT_SOCIAL,
		CHAR(30) 		AS DES_ACT_OBJ,
		CHAR(50) 		AS USUARIO_AUT,		
		CHAR(12) 		AS FOL_CONTRATO,
		CHAR(2) 		AS RESP_STATUS,								
		CHAR(26) 		AS APELL_PATER_FIRMANTES,					
		CHAR(26) 		AS APELL_MATER_FIRMANTES,
		CHAR(26) 		AS NOMB1_FIRMANTES, 		
		CHAR(26) 		AS NOMB2_FIRMANTES,
		CHAR(30)		AS NO_IDENT;
			
		---DECLARACIONES
		DEFINE iSqlErr						INTEGER;    		
		DEFINE cCodRet         				CHAR(6);				
		DEFINE cRFC         				CHAR(13);				
		DEFINE cApellPaterContactoRepLeg 	CHAR(26);				
		DEFINE cApellMaterContactoRepLeg	CHAR(26);				
		DEFINE cNomb1ContactoRepLeg         CHAR(26);				
		DEFINE cNomb2ContactoRepLeg     	CHAR(26);				
		DEFINE cCalleFiscal					CHAR(40);				
		DEFINE cNumExtCalleFiscal       	CHAR(10);				
		DEFINE cColFiscal         			CHAR(60);				
		DEFINE vNomCiudFiscal         		VARCHAR(60,1);			
		DEFINE cCodMunFiscal        		CHAR(3);				
		DEFINE cNomEstadoFiscal        		CHAR(30);				
		DEFINE cNumcte         				CHAR(20);				
		DEFINE cNomCorto        			CHAR(30);				
		DEFINE cPagInternet        			CHAR(30);				
		DEFINE cSatFea        				CHAR(25);				
		DEFINE cTelContacto    				CHAR(15);				
		DEFINE cGiro      					CHAR(20);				
		DEFINE cNomGiro    					CHAR(40);				
		DEFINE cActSocial 					CHAR(3);				
		DEFINE cDesActObj  					CHAR(30);				
		DEFINE cUsuarioAut    				CHAR(50);						
		DEFINE cFolContrato   				CHAR(12);				
		DEFINE cStatusAlta 					CHAR(1);				
		DEFINE cRespStatus 					CHAR(2);				
		DEFINE cApellPaterFirmantes 		CHAR(26);				
		DEFINE cApellMaterFirmantes 		CHAR(26);				
		DEFINE cNomb1Firmantes 				CHAR(26);				
		DEFINE cNomb2Firmantes 				CHAR(26);				
		DEFINE cCuentaNomina 				CHAR(20);
		DEFINE cNumIdent					CHAR(30);
			
		---INICIALIZACIONES
		LET iSqlErr						= 0;    		
		LET cCodRet         			= '000000';				
		LET cRFC         				= '';
		LET cApellPaterContactoRepLeg   = '';
		LET cApellMaterContactoRepLeg 	= '';
		LET cNomb1ContactoRepLeg        = '';
		LET cNomb2ContactoRepLeg     	= '';
		LET cCalleFiscal				= '';
		LET cNumExtCalleFiscal       	= '';
		LET cColFiscal         			= '';
		LET vNomCiudFiscal         		= '';
		LET cCodMunFiscal        		= '';
		LET cNomEstadoFiscal        	= '';
		LET cNumcte         			= '';
		LET cNomCorto        			= '';
		LET cPagInternet        		= '';
		LET cSatFea        				= '';
		LET cTelContacto    			= '';
		LET cGiro      					= '';
		LET cNomGiro    				= '';
		LET cActSocial 					= '';
		LET cDesActObj  				= '';
		LET cUsuarioAut    				= '';		
		LET cFolContrato   				= '';
		LET cStatusAlta 				= '';
		LET cRespStatus 				= '';
		LET cApellPaterFirmantes 		= '';
		LET cApellMaterFirmantes 		= '';
		LET cNomb1Firmantes 			= '';
		LET cNomb2Firmantes 			= '';			
		LET cCuentaNomina	 			= '';
		LET cNumIdent					='';
				
	BEGIN
		
		ON EXCEPTION SET iSqlErr
		   IF iSqlErr != 0 THEN
			  LET cCodRet = iSqlErr;
			  RETURN 	cCodRet,NVL(cRFC,''),NVL(cApellPaterContactoRepLeg,''),NVL(cApellMaterContactoRepLeg,''),NVL(cNomb1ContactoRepLeg,''),
						NVL(cNomb2ContactoRepLeg,''),NVL(cCalleFiscal,''),NVL(cNumExtCalleFiscal,''),NVL(cColFiscal,''),
						NVL(vNomCiudFiscal,''),NVL(cCodMunFiscal,''),NVL(cNomEstadoFiscal,''),NVL(cNumcte,''),
						NVL(cNomCorto,''),NVL(cPagInternet,''),NVL(cSatFea,''),NVL(cTelContacto,''),NVL(cGiro,''),
						NVL(cNomGiro,''),NVL(cActSocial,''),NVL(cDesActObj,''),NVL(cUsuarioAut,''),
						NVL(cFolContrato,''),NVL(cRespStatus,''),NVL(cApellPaterFirmantes,''),NVL(cApellMaterFirmantes,''),
						NVL(cNomb1Firmantes,''),NVL(cNomb2Firmantes,''), NVL(cNumIdent,'');
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/home/sysifx/SPsPAYAN/sp_consultarctemoral.out';
		--TRACE ON;
		
		IF TRIM(NVL(pNumcte,'')) = '' THEN
			LET cCodRet = '000001';
			RETURN 	cCodRet,NVL(cRFC,''),NVL(cApellPaterContactoRepLeg,''),NVL(cApellMaterContactoRepLeg,''),NVL(cNomb1ContactoRepLeg,''),
					NVL(cNomb2ContactoRepLeg,''),NVL(cCalleFiscal,''),NVL(cNumExtCalleFiscal,''),NVL(cColFiscal,''),
					NVL(vNomCiudFiscal,''),NVL(cCodMunFiscal,''),NVL(cNomEstadoFiscal,''),NVL(cNumcte,''),
					NVL(cNomCorto,''),NVL(cPagInternet,''),NVL(cSatFea,''),NVL(cTelContacto,''),NVL(cGiro,''),
					NVL(cNomGiro,''),NVL(cActSocial,''),NVL(cDesActObj,''),NVL(cUsuarioAut,''),
					NVL(cFolContrato,''),NVL(cRespStatus,''),NVL(cApellPaterFirmantes,''),NVL(cApellMaterFirmantes,''),
					NVL(cNomb1Firmantes,''),NVL(cNomb2Firmantes,''),NVL(cNumIdent,'');
		END IF;
		
		--SE OBTIENE DENOMINACIÓN O RAZÓN SOCIAL, NÚMERO DE LA FIRMA ELECTRÓNICA AVANZADA Y TELÉFONO DEL CONTACTO.
		SELECT TRIM(NVL(a.numcte,'')),TRIM(NVL(a.nombre_corto,'')),TRIM(NVL(a.pagina_internet,'')),TRIM(NVL(a.sat_fea,'')),TRIM(NVL(a.telefono_contacto,''))
		INTO cNumcte,cNomCorto,cPagInternet,cSatFea,cTelContacto
		FROM bdinteg:"informix".si_ctepm a, bdinteg:"informix".si_cliente b 
		WHERE a.numcte = pNumcte
		AND b.empresa = '001'
		AND b.numcte = pNumcte
		AND b.tpo_persona = '02';
					
		IF NVL(CNumcte,'') = '' THEN 
		   LET cCodRet = '000002';
		   RETURN 	cCodRet,NVL(cRFC,''),NVL(cApellPaterContactoRepLeg,''),NVL(cApellMaterContactoRepLeg,''),NVL(cNomb1ContactoRepLeg,''),
					NVL(cNomb2ContactoRepLeg,''),NVL(cCalleFiscal,''),NVL(cNumExtCalleFiscal,''),NVL(cColFiscal,''),
					NVL(vNomCiudFiscal,''),NVL(cCodMunFiscal,''),NVL(cNomEstadoFiscal,''),NVL(cNumcte,''),
					NVL(cNomCorto,''),NVL(cPagInternet,''),NVL(cSatFea,''),NVL(cTelContacto,''),NVL(cGiro,''),
					NVL(cNomGiro,''),NVL(cActSocial,''),NVL(cDesActObj,''),NVL(cUsuarioAut,''),
					NVL(cFolContrato,''),NVL(cRespStatus,''),NVL(cApellPaterFirmantes,''),NVL(cApellMaterFirmantes,''),
					NVL(cNomb1Firmantes,''),NVL(cNomb2Firmantes,''), NVL(cNumIdent,'');
		END IF;
		
		--SE OBTIENE LA CUENTA Y EL ESTATUS DE LA EMPRESA CON EL SERVICIO DE NOMINA
		SELECT TRIM(NVL(cuenta,'')), TRIM(NVL(status_alta,''))
		INTO cCuentaNomina, cStatusAlta
		FROM bdicheq:"informix".sc_nominaempresas
		WHERE numcte = pNumcte;
		
		IF TRIM(NVL(cStatusAlta,'')) = '3' THEN
		   LET cRespStatus = 'Si';
		ELSE
		   LET cRespStatus = 'No';
		END IF;		
						
		--SE OBTIENE NOMBRE DEL REPRESENTANTE LEGAL Y RFC.
		SELECT TRIM(NVL(c.rfc,'')),TRIM(NVL(b.apell_paterno,'')),TRIM(NVL(b.apell_materno,'')),
			   TRIM(NVL(b.nombre1,'')),TRIM(NVL(b.nombre2,'')) 
		INTO cRFC,cApellPaterContactoRepLeg,cApellMaterContactoRepLeg,cNomb1ContactoRepLeg,cNomb2ContactoRepLeg
		FROM bdinteg:"informix".si_ctepm a 
		INNER JOIN bdinteg:"informix".si_cliente b ON (a.nombre_contacto = b.numcte)
		INNER JOIN bdinteg:"informix".si_cliente c ON (c.numcte = pNumcte)
		WHERE a.numcte = pNumcte
		AND b.empresa = '001'
		AND b.numcte = a.nombre_contacto 
		AND c.empresa = '001'
		AND c.numcte = pNumcte;
							
		--SE OBTIENE DOMICILIO FISCAL.			
		SELECT 	TRIM(NVL(e.nombrecalle,'')),TRIM(NVL(a.numeroextcalle,'')),TRIM(NVL(f.nombrezona,'')),
				TRIM(NVL(g.nombre,'')),TRIM(NVL(c.municipio,'')),TRIM(NVL(b.nombre,''))			
		INTO cCalleFiscal,cNumExtCalleFiscal,cColFiscal,vNomCiudFiscal,cCodMunFiscal,cNomEstadoFiscal
		FROM bdinteg:"informix".si_direcciones_actual a 
			 LEFT OUTER JOIN bdinteg:"informix".si_estados 	   b ON (a.estado = b.estado)
			 LEFT OUTER JOIN bdinteg:"informix".si_municipios  c ON (a.municipio = c.municipio AND a.estado = c.estado AND a.ciudad = c.ciudad AND a.pais = c.pais)
			 LEFT OUTER JOIN bdinteg:"informix".si_catcalles   e ON (a.numerocalle = e.numerocalle)
			 LEFT OUTER JOIN bdinteg:"informix".si_catzonas    f ON (a.numerociudad = f.numerociudad and a.numerocolonia = f.numerocolonia)
			 LEFT OUTER JOIN bdinteg:"informix".si_ciudades    g ON (a.estado = g.estado AND a.ciudad = g.ciudad)		 
		WHERE a.numcte = pNumcte
		AND a.tipo_dir = 1;
		
		--SE OBTIENE GIRO MERCANTIL.
		SELECT TRIM(NVL(a.giro,'')),TRIM(NVL(b.nombre,'')) 
		INTO cGiro,cNomGiro
		FROM bdinteg:"informix".si_ctepm a INNER JOIN bdinteg:"informix".si_actecon b ON(TRIM(LPAD(a.giro,3,'0')) = TRIM(b.actividad))
		WHERE a.numcte = pNumcte;
										
		--SE OBTIENE ACTIVIDAD U OBJETO SOCIAL.
		SELECT TRIM(NVL(a.actividadsocial,'')),TRIM(NVL(b.descripcion,'')) 
		INTO cActSocial,cDesActObj
		FROM bdinteg:"informix".si_ctepm a INNER JOIN bdinteg:"informix".si_actividadsocial b ON (TRIM(a.actividadsocial) = TRIM(b.codigo))
		WHERE numcte = pNumcte;		
						
		--SE OBTIENE USUARIO AUTORIZADO Y SU NUMERO DE IDENTIFICACION.
		SELECT TRIM(NVL(usuario_aut,'')), TRIM(NVL(no_identificacion_oficial, ''))
		INTO cUsuarioAut, cNumIdent
		FROM bdinteg:"informix".si_bpiusuariospm 
		WHERE empresa = '001'
		AND num_cliente = pNumcte;
	
		--SE OBTIENE FOLIO DE ACTIVACIÓN DEL TOKEN:		
		SELECT TRIM(NVL(a.folio_contrato,''))
		INTO cFolContrato
		FROM bdinteg:"informix".si_bpiusuariospm a
		INNER JOIN bdinteg:"informix".si_bpitokenpm b ON (a.num_cliente = b.num_cliente)
		WHERE a.num_cliente = pNumcte
		AND b.folio_token = a.folio_contrato
		AND a.id_status >= 10;
		
		IF TRIM(NVL(cFolContrato,'')) = '' THEN
			LET cFolContrato = 'Sin Activar';
		END IF;
		
		--SE OBTIENE EL AUTORIZADO PARA MANEJAR LAS CUENTAS DE REGISTRO FIRMAS:
		SELECT TRIM(NVL(apell_paterno,'')),TRIM(NVL(apell_materno,'')),TRIM(NVL(nombre1,'')),TRIM(NVL(nombre2,''))		
		INTO cApellPaterFirmantes,cApellMaterFirmantes,cNomb1Firmantes,cNomb2Firmantes
		FROM bdicheq:"informix".sc_firmantes a INNER JOIN bdinteg:"informix".si_cliente b ON(a.numcte = b.numcte)
		WHERE a.empresa = '001'
		AND a.cuenta = cCuentaNomina
		AND a.secuencia = 1;
	
		--SE RETORNA INFORMACION.
		RETURN 	cCodRet,NVL(cRFC,''),NVL(cApellPaterContactoRepLeg,''),NVL(cApellMaterContactoRepLeg,''),NVL(cNomb1ContactoRepLeg,''),
				NVL(cNomb2ContactoRepLeg,''),NVL(cCalleFiscal,''),NVL(cNumExtCalleFiscal,''),NVL(cColFiscal,''),
				NVL(vNomCiudFiscal,''),NVL(cCodMunFiscal,''),NVL(cNomEstadoFiscal,''),NVL(cNumcte,''),
				NVL(cNomCorto,''),NVL(cPagInternet,''),NVL(cSatFea,''),NVL(cTelContacto,''),NVL(cGiro,''),
				NVL(cNomGiro,''),NVL(cActSocial,''),NVL(cDesActObj,''),NVL(cUsuarioAut,''),
				NVL(cFolContrato,''),NVL(cRespStatus,''),NVL(cApellPaterFirmantes,''),NVL(cApellMaterFirmantes,''),
				NVL(cNomb1Firmantes,''),NVL(cNomb2Firmantes,''), NVL(cNumIdent,'');
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que obtiene la informacion de cliente moral', 
'AUTOR: Guadalupe Payan ',
'VERSION: 20110928.1152',
'FECHA: Septiembre 2011',
'BD: bdinteg',
'MODIFICACION: Se agrega procedimiento para que obtenga el numero de identificacion autorizado.', 
'AUTOR: Armando Morales ',
'VERSION: 20120302.1152',
'FECHA: Marzo 2012',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_senet_actualizaestatusctepm( pEmpresa CHAR(3), pNumCte CHAR(20) , pEstatus CHAR(3), pFolioToken CHAR(12), pUsuarioAutoriza CHAR(50), pCodIdentif CHAR(2), pNumIdentOficial CHAR(30), pUsuario CHAR(8) ,pIP CHAR(15))
	RETURNING CHAR(6) AS cCodRet,
		      SMALLINT AS Estatus,
			  CHAR(100) AS Mensaje;
    
  -- DEFINICIONES
	DEFINE cCodRet           CHAR(6);
	DEFINE iSql_Err          INTEGER;
	DEFINE cMensaje          CHAR(100);
	DEFINE sEstatusAnterior  SMALLINT;
	DEFINE sEstatus          SMALLINT;
	DEFINE cNumCte           CHAR(20);
	DEFINE cFolioToken       CHAR(12);
    DEFINE dtFechaHoy        DATE;
	
	-- INICIALIZACIONES
	LET cCodRet           	= '000';
	LET iSql_Err          	= 0;
	LET cMensaje          	= '';
	LET sEstatusAnterior  	= 0;
	LET sEstatus          	= 0;
	LET cNumCte           	= '';
	LET cFolioToken       	= '';
	LET dtFechaHoy         	= '01-01-2000';
    	
	BEGIN
		
		ON EXCEPTION SET iSql_Err
			LET cCodRet = iSql_Err;
			LET cMensaje = '';
			LET sEstatus = '0';
			RETURN cCodRet, sEstatus, cMensaje;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO "/respaldosbd/Guadalupe/sp_senet_actualizaestatusctepm.out";
		-- TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	  --Valida los parametros de entrada.
		IF (pEmpresa = '' OR pEmpresa IS NULL) OR (pNumCte = '' OR pNumCte IS NULL) OR pEstatus IS NULL OR pUsuarioAutoriza IS NULL OR (pNumIdentOficial = '' OR pNumIdentOficial IS NULL) OR (pUsuario = '' OR pUsuario IS NULL) OR TRIM(NVL(pCodIdentif,'')) = '' THEN
		   LET cCodRet = '001';
		   LET cMensaje = 'FALTAN PARAMETROS PARA SU EJECUCIÓN';
		   LET sEstatus = '0';
		   RETURN cCodRet, sEstatus, cMensaje;
		END IF
		
	  -- Consultamos la fecha actual
		SELECT fecha_hoy INTO dtFechaHoy
		FROM bdicheq:"informix".sc_fechas;
		
	  --Valida si el estatus viene vacio inserta un registro en la tabla.
		IF pEstatus = '' THEN
		   
		  LET sEstatus = 0;
		  LET cFolioToken = pFolioToken;
		   
		 -- Inserta un registro en las tablas.
		   INSERT INTO bdinteg:"informix".si_bpiusuariospm (empresa, num_cliente, id_status, folio_contrato, usuario_aut    , codidentif , no_identificacion_oficial, rep_legal, pass, f_pass, pass1, f_pass1, pass2, f_pass2, pass3, f_pass3, f_status, f_ultimo_acceso, f_actualizacion, f_registro, fec_primer_acceso, num_empleado, fecha_movto, f_unico_reg, usuario,suc_registro)
           VALUES                                         (pEmpresa, pNumCte   , sEstatus , cFolioToken   , pUsuarioAutoriza, pCodIdentif, pNumIdentOficial        ,''        ,''   ,''     ,''    ,''      , ''   , ''     , ''   , ''     , ''      , ''             , ''             , ''        , ''               , pUsuario    , ''         , dtFechaHoy , '','5001');
		   
	       INSERT INTO bdinteg:"informix".si_cambiostctepm ( numcliente, id_statusanterior, id_statusactual  , ipusuario, fecha_cambio, suc_cambio, usuario_cambio )
           VALUES                                         ( pNumCte   , sEstatus         , sEstatus         , pIP      , dtFechaHoy    , '5001'    , pUsuario);
		   
		  LET cCodRet = '000';
		  LET cMensaje = 'INSERTO CORRECTAMENTE';
		   
		   RETURN cCodRet, sEstatus, cMensaje;
		   
		ELSE
			
            LET sEstatusAnterior = pEstatus::SMALLINT;		
			
		  -- Valida el estatus que se va actualizar
			IF pEstatus = '0' THEN
			  LET sEstatus = 1;
			  LET cFolioToken = pFolioToken;
			  
			  UPDATE bdinteg:"informix".si_bpiusuariospm SET id_status = sEstatus , folio_contrato = cFolioToken 
			  WHERE empresa = pEmpresa AND num_cliente =pNumCte;
			  
			ELIF pEstatus = '1' THEN
			  LET sEstatus = 2;
			  LET cFolioToken = pFolioToken;
			  
			  UPDATE bdinteg:"informix".si_bpiusuariospm SET id_status = sEstatus , folio_contrato = cFolioToken 
			  WHERE empresa = pEmpresa AND num_cliente =pNumCte;
			ELIF pEstatus = '2' THEN
			  LET sEstatus = 10;
			  LET cFolioToken = pFolioToken;
			  
			  UPDATE bdinteg:"informix".si_bpiusuariospm SET id_status = sEstatus , folio_contrato = cFolioToken , f_registro = dtFechaHoy
			  WHERE empresa = pEmpresa AND num_cliente =pNumCte;
			END IF 
			
		  -- Inserta en la tabla un registro del historial del estatus que lleva el cliente.
	        INSERT INTO bdinteg:"informix".si_cambiostctepm ( numcliente, id_statusanterior, id_statusactual  , ipusuario, fecha_cambio, suc_cambio, usuario_cambio )
            VALUES                                         ( pNumCte   , sEstatusAnterior , sEstatus         , pIP       , dtFechaHoy  ,  '5001'    , pUsuario);
		    
		    LET cCodRet = '000';
		    LET cMensaje = 'ACTUALIZO CORRECTAMENTE';
			
			RETURN cCodRet, sEstatus, cMensaje;
			
		END IF
        
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Actualiza e Inserta registros en la tabla si_bpiusuariospm en caso de que el estatus se encuentre vacio ',
'             y actualiza la tabla en el estatus que le sigue en el proceso',
'AUTOR:  Valentin Lopez',
'FECHA DE CREACION: 27 de Septiembre del 2011',
'DESCRIPCION MODIFICACION: Se modifico el número de identificación a char(30) y recibir como parametro el típo de identificación para su registro y',
'							se cambiaron todos los mensajes a mayuscula',
'FECHA MODIFICACION: 13 de Marzo del 2012',
'AUTOR MODIFICACION: Guadalupe Payan',
'VERSION: 20120313.1204',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_senet_altaservicioctepmempresanet( pNumCte CHAR(20), pUsuario CHAR(8) )
	RETURNING CHAR(6) AS cCodRet,
			  CHAR(40) AS Mensaje;
    
  -- DEFINICIONES
  	DEFINE iSql_Err         INTEGER;
	DEFINE cCodRet          CHAR(6);
	DEFINE cMensaje         CHAR(40);
	DEFINE cFolioToken      CHAR(12);
	DEFINE dtFechaHoy       DATE;
	DEFINE sEstatus         SMALLINT;
	DEFINE sEstatusAnt      SMALLINT;
	DEFINE sSecuencia       SMALLINT;
	DEFINE cSolicitud       CHAR(10);
	DEFINE cFolioSucursal   CHAR(16);
	DEFINE cRandon1         CHAR(6);
	DEFINE cRandon2         CHAR(2);
	
	-- INICIALIZACIONES
	LET iSql_Err           	= 0;
	LET cCodRet           	= '000000';
	LET cMensaje          	= 'SE GENERO EL ALTA EXISTOSAMENTE';
	LET cFolioToken       	= '';
	LET dtFechaHoy         	= '01-01-2000';
	LET sEstatus          	= 0;
	LET sEstatusAnt       	= 0;
	LET sSecuencia        	= 0;
	LET cSolicitud        	= '';
	LET cFolioSucursal    	= '';
	LET cRandon1          	= '';
	LET cRandon2         	= '';
		
	BEGIN
	
		ON EXCEPTION SET iSql_Err
			LET cCodRet = iSql_Err;
			LET cMensaje = '';
			RETURN cCodRet, cMensaje;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO "/respaldosbd/Guadalupe/sp_senet_altaservicioctepmempresanet.out";
		-- TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		 
	  --Valida los parametros de entrada.
		IF (pNumCte = '' OR pNumCte IS NULL) OR (pUsuario = '' OR pUsuario IS NULL) THEN
		   LET cCodRet = '000001';
		   LET cMensaje = 'FALTAN PARAMETROS PARA SU EJECUCIÓN';
		   RETURN cCodRet, cMensaje;
		END IF
		 
  	  -- Consultamos la fecha actual
		SELECT fecha_hoy INTO dtFechaHoy
		FROM bdicheq:"informix".sc_fechas;
		 
      -- Consultamos la maxima secuencia del domicilio del cliente.
		SELECT secuencia INTO sSecuencia
		FROM bdinteg:"informix".si_direcciones_actual 
		WHERE numcte = pNumCte
			AND tipo_dir = 1;
		 
	    IF sSecuencia IS NULL THEN
		  SELECT MAX(secuencia) INTO sSecuencia 
		  FROM bdinteg:"informix".si_direcciones
		  WHERE numcte = pNumCte
			AND tipo_dir = 1;
		END IF
		 
      -- Consulta el maximo regitro + 1
  	    SELECT (NVL(MAX(solicitud),'0')::INTEGER + 1) INTO cSolicitud
		FROM bdibpi:"informix".bpi_tokensolicitud;
		
		IF cSolicitud IS NULL THEN
			LET cSolicitud = '1';
		END IF;
		
		LET cSolicitud = LPAD(TRIM(cSolicitud), 10, '0');	
		
	  -- Consultamos el FolioToken
		SELECT folio_contrato, id_status INTO cFolioToken, sEstatus
		FROM bdinteg:"informix".si_bpiusuariospm 
		WHERE num_cliente = pNumCte;
		
	  -- Consultamos la hora para generar el folio.
		SELECT SUBSTR(DBINFO('utc_to_datetime', sh_curtime),12,2) || SUBSTR(DBINFO('utc_to_datetime', sh_curtime),15,2) || SUBSTR(DBINFO('utc_to_datetime', sh_curtime),18,2)
		INTO cRandon1
		FROM sysmaster:sysshmvals;
		
	 -- Generamos un Randon para completar el valor del folio.
	   EXECUTE PROCEDURE bdicheq:"informix".sp_random()
	   INTO cRandon2;
		
		LET cFolioSucursal = 'SINCOMIS'||cRandon1||LPAD(TRIM(cRandon2), 2, '0');
		
	  --Valida el estatus anterior.
	    IF sEstatus = 0 THEN
		  LET sEstatusAnt = 0;
		ELIF sEstatus = 1 THEN
		  LET sEstatusAnt = 0;
		ELIF sEstatus = 2 THEN
		  LET sEstatusAnt = 1;
		ELIF sEstatus = 10 THEN
		  LET sEstatusAnt = 2;
		ELSE
		  LET cCodRet = '000002';
		  LET cMensaje = 'ESTATUS NO VALIDO PARA EL PROCESO DE ALTA DE EMPRESA NET';
		  RETURN cCodRet, cMensaje;
		END IF 
		
	 --  Inserta los registros de la alta definitiva del servicio de EmpresaNet.
		INSERT INTO bdinteg:"informix".si_bpitokenpm ( empresa, num_cliente, ns_token, suc_registro, folio_token, id_status_token, f_status  , f_registro )
		VALUES                                       ( '001'  , pNumCte    , ''      , '5001'      , cFolioToken, 0              , dtFechaHoy , dtFechaHoy );
	    
		INSERT INTO bdibpi:"informix".bpi_tokensolicitud ( solicitud, numcte , id_status, sucursal, f_solicitud, sec_domicilio, f_atencion, comentarios, usr_solicita, usr_atiende, empresa, ns_token, tipo, folio_suc )
		VALUES                                          ( cSolicitud, pNumCte, '100'    , '5001'  , dtFechaHoy  , sSecuencia   , dtFechaHoy , ''         , pUsuario    , ''         , '001'  , ''      , 3   , cFolioSucursal);
	    		
		RETURN cCodRet, cMensaje;
        
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Realiza un alta definitiva del servicio de EmpresaNet',
'AUTOR:  Valentin Lopez',
'FECHA DE CREACION: 28 de Septiembre del 2011',
'DESCRIPCION MODIFICACION: Se agrego el filtro de tipo_dir = 2 para la tabla de direcciones y', 
'							se cambiaron todos los mensajes a mayuscula',
'FECHA MODIFICACION: 13 de Marzo del 2012',
'AUTOR MODIFICACION: Guadalupe Payan',
'VERSION: 20120313.1426',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_senet_consultaestatusctepm( pNumCte CHAR(20) , pCuenta CHAR(20) )
	
	RETURNING CHAR(6) 		AS CodRet,
		      CHAR(100) 	AS Mensaje,
			  CHAR(3) 		AS Estatus,			  
			  CHAR(50) 		AS UsuarioAutorizado,
			  CHAR(2) 		AS CodIdentif,
			  CHAR(50) 		AS DescripIdenfOficial,
			  CHAR(30) 		AS Identificacion,
			  CHAR(12) 		AS FoliosolicitudToken;
    
	--DEFINICIONES DE VARIABLES.
	DEFINE cCodRet         			CHAR(6);
	DEFINE iSqlErr        			INTEGER;
	DEFINE iIsamErr        			INTEGER;
	DEFINE cDescErr        			CHAR(100);
	DEFINE cMensaje        			CHAR(100);
	DEFINE cEstatus        			CHAR(3);
	DEFINE cNumCte	       			CHAR(20);
	DEFINE cUsuarioAut	   			CHAR(50);
	DEFINE cDescripIdenfOficial  	CHAR(55);
	DEFINE cCodIdentif  			CHAR(2);
	DEFINE cIdentificacion 			CHAR(30);
	DEFINE cFolioSolToken  			CHAR(12);
	    	
	--INICIALIZACIONES DE VARIABLES.
	LET cCodRet         			= '000';
	LET iSqlErr         			= 0;
	LET iIsamErr         			= 0;
	LET cDescErr        			= '';
	LET cMensaje        			= 'VALIDACION TERMINADA';
	LET cEstatus        			= '';
	LET cNumCte         			= '';
	LET cUsuarioAut     			= '';	
	LET cCodIdentif  				= '';
	LET cDescripIdenfOficial		= '';
	LET cIdentificacion 			= '';
	LET cFolioSolToken  			= '';		
	  
	BEGIN
		ON EXCEPTION SET iSqlErr,iIsamErr,cDescErr
			LET cCodRet = iSqlErr;
			LET cMensaje = cDescErr;
			RETURN cCodRet,TRIM(cMensaje),TRIM(NVL(cEstatus,'')),TRIM(NVL(cUsuarioAut,'')),TRIM(NVL(cCodIdentif,'')),TRIM(NVL(cDescripIdenfOficial,'')),TRIM(NVL(cIdentificacion,'')),TRIM(NVL(cFolioSolToken,''));
		END EXCEPTION;

		-- SET DEBUG FILE TO "/respaldosbd/Guadalupe/sp_senet_consultaestatusctepm.out";
		-- TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	  --Valida los parametros de entrada.		
		IF NVL(pNumCte, '') = '' AND NVL(pCuenta, '') = '' THEN
		   LET cCodRet = '002';
		   LET cMensaje = 'FALTAN PARAMETROS PARA SU EJECUCIÓN';
		   RETURN cCodRet,cMensaje,TRIM(cEstatus),TRIM(cUsuarioAut),TRIM(cCodIdentif),TRIM(cDescripIdenfOficial),TRIM(cIdentificacion),TRIM(cFolioSolToken);
		   
		ELIF NVL(pNumCte,'' ) <> '' AND NVL(pCuenta,'') <> '' THEN		
		   LET cCodRet = '003';
		   LET cMensaje = 'SOLAMENTE DEBE INGRESAR UN PARAMETRO';
		   RETURN cCodRet,cMensaje,TRIM(cEstatus),TRIM(cUsuarioAut),TRIM(cCodIdentif),TRIM(cDescripIdenfOficial),TRIM(cIdentificacion),TRIM(cFolioSolToken);
		   
		END IF
		
	  --Si el cliente viene vacio consulta el cliente por el numero de cuenta		
		IF NVL(pNumCte,'') = '' THEN
		  SELECT num_cte 
		  INTO cNumCte
		  FROM bdicheq: "informix".sc_maechq
		  WHERE empresa = '001'
		    AND cuenta = pCuenta;
		  		  
		  IF NVL(cNumCte,'') = ''THEN            
			LET cCodRet = '004';
		    LET cMensaje = 'NO EXISTE LA CUENTA EN LA BASE DE DATOS';
		    RETURN cCodRet,cMensaje,TRIM(cEstatus),TRIM(cUsuarioAut),TRIM(cCodIdentif),TRIM(cDescripIdenfOficial),TRIM(cIdentificacion),TRIM(cFolioSolToken);
			
		  END IF
		  
		  LET pNumCte = cNumCte;
		   
		END IF
		
	  -- Consulta el estatus que tiene asignado el cliente.
		SELECT id_status,usuario_aut,codidentif,no_identificacion_oficial,folio_contrato 
		INTO cEstatus,cUsuarioAut,cCodIdentif,cIdentificacion,cFolioSolToken
		FROM bdinteg: "informix".si_bpiusuariospm 
		WHERE empresa = '001'
		  AND num_cliente = pNumCte;
		
	  -- Valida si el estatus es NULL o Vacio.		
		IF NVL(cEstatus,'') = '' THEN
		   LET cCodRet = '000';
		   LET cEstatus = '';
		   LET cMensaje = 'EMPRESA NO A SIDO DADA DE ALTA EN EL SERVICIO DE EMPRESA NET';		   
		   RETURN cCodRet,cMensaje,TRIM(cEstatus),TRIM(NVL(cUsuarioAut,'')),TRIM(NVL(cCodIdentif,'')),TRIM(cDescripIdenfOficial),TRIM(NVL(cIdentificacion,'')),TRIM(NVL(cFolioSolToken,''));
		   
		END IF
						
		--Consulta la descripcion y el codigo identificacion oficial.
		SELECT TRIM(descripcion)
		INTO cDescripIdenfOficial
		FROM bdinteg: "informix".si_tipoidentifpm
		WHERE empresa = '001'
		  AND codigo = TRIM(cCodIdentif);		
		
	  -- Valida el estatus obtenido en la consulta.
		IF cEstatus = '0' THEN
  		  LET cCodRet = '000';
 		  LET cMensaje = 'EL PROCESO DE ALTA SE DETUVO EN LA GENERACIÓN DEL CODIGO DE SOLICITUD DEL TOKEN';
		ELIF cEstatus = '1' THEN
	      LET cCodRet = '000';
		  LET cMensaje = 'EL PROCESO DE ALTA SE DETUVO POR PROBLEMAS EN LA DIGITALIZACIÓN';
		ELIF cEstatus = '2' THEN
		  LET cCodRet = '000';
		  LET cMensaje = 'EL PROCESO DE ALTA SE DETUVO POR PROBLEMAS EN LAS AFECTACIONES A TABLAS';
		ELIF cEstatus = '10' THEN		
		  LET cCodRet = '000';
		  LET cMensaje = 'EL CLIENTE MORAL YA CUENTA CON EL SERVICIO DE EMPRESANET ACTIVO EN CENTRAL';
		ELIF cEstatus = '30' THEN
		  LET cCodRet = '000';
		  LET cMensaje = 'EL CLIENTE MORAL YA CUENTA CON EL SERVICIO DE EMPRESANET ACTIVO EN EL PORTAL';
		ELSE
		  LET cCodRet = '001';
		  LET cMensaje = 'ESTATUS NO VALIDO PARA EL PROCESO DE ALTA DE EMPRESA NET';
		END IF 
		
		RETURN cCodRet,cMensaje,TRIM(cEstatus),TRIM(NVL(cUsuarioAut,'')),TRIM(NVL(cCodIdentif,'')),TRIM(NVL(cDescripIdenfOficial,'')),TRIM(NVL(cIdentificacion,'')),TRIM(NVL(cFolioSolToken,''));
	END;
	
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que obtiene el estatus del cliente en cuestion al servicio de EmpresaNet.',
'AUTOR:  Valentin Lopez',
'FECHA DE CREACION: 27 de Septiembre del 2011',
'DESCRIPCION MODIFICACION: Cambiar el tamaño de la variable cIdentificacion a char(30) ya que cambio en el tamaño de la tabla y', 
'						   se cambiaron todos los mensajes a mayuscula,se agrego consulta para obtener cDescripIdenfOficial, se',
'						   agrego validacion para el estatus 30, se cambio el orden de retorno para que fuera primero cMensaje y',
'						   despues cEstatus',
'FECHA MODIFICACION: 13 de Marzo del 2012',
'AUTOR MODIFICACION: Guadalupe Payan',
'VERSION: 20120313.1626',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_cnsif_edoctacap(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),cANIOMES CHAR(6), cNUMEMP CHAR(20))
							
				returning CHAR(5)  AS Cod_Retorno,
						  CHAR(6)  AS Anio_Mes,
						  CHAR(107) AS Nombre_Cliente,
						  CHAR(30) AS Calle,
						  CHAR(10) AS Numero_Exterior,
						  CHAR(10) AS Numero_Interior, 
						  CHAR(30) AS Colonia, 
						  CHAR(30) AS Ciudad, 
						  CHAR(30) AS Estado,
						  CHAR(5)  AS Codigo_Postal, 
						  DATE        AS Fecha_Actual, 
						  CHAR(13) AS RFC, 
						  CHAR(20) AS CURP, 
						  CHAR(40) AS Sucursal, 
						  DATE        AS Fecha_Alta, 
						  CHAR(20) AS Numero_Cliente, 
						  CHAR(20)    AS Numero_Cuenta, 
						  CHAR(16)    AS Numero_Tarjeta, 
						  CHAR(18)    AS CLABE, 
						  MONEY(16,2) AS Saldo_Anterior,
						  MONEY(16,2) AS Depositos, 
						  MONEY(16,2) AS Intereses_Pagados, 
						  MONEY(16,2) AS Retiros, 
						  MONEY(16,2) AS Otros_Cargos, 
						  MONEY(16,2) AS Iva_Otros_Cargos, 
						  MONEY(16,2) AS Saldo_Al_Corte, 
						  MONEY(16,2) AS Saldo_Promedio, 
						  MONEY(16,2) AS Retencion_ISR, 
						  MONEY(16,2) AS Intereses_Netos,
						  INTEGER     AS Dias, 
						  MONEY(16,2) AS Tasa_Bruta, 
						  DATE        AS Fecha_Corte, 
						  DECIMAL(9,4) AS GAT, 
						  MONEY(16,2) AS Mas_InteresesPagados, 
						  MONEY(16,2) AS Mas_Otros_Cargos, 
						  MONEY(16,2) AS Saldo_Actual,
						  INTEGER     AS Consulta_Maxima,
                          CHAR(11)    AS Fecha_Inicio,
                          CHAR(11)    AS Fecha_Fin;
						  						
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;

DEFINE vcodret, cCodPostal CHAR(5);
DEFINE cNumExt, cNumInt, cNumProducto CHAR(10);
DEFINE cRFC CHAR(13);
DEFINE cNumTarjeta CHAR(20);
DEFINE cClabe CHAR(18);
DEFINE cNumCte, cCurp CHAR(20);
DEFINE cNomCalle, cNomColonia, cNomCiudad, cNomEstado CHAR(30);
DEFINE cNomSucursal CHAR(40);
DEFINE cProducto CHAR(45);
DEFINE cNomcte CHAR(107);
DEFINE dFechaIni, dFechaFin, dFechaAlta DATE;
DEFINE mSaldoAnterior, mSaldoCorte, mAux1, mSaldoPromedio MONEY(14, 2);
DEFINE mDepositos, mRetiros, mInteresesPagados, mRetencionIsr, mIvaOtrosCargos, mOtrosCargos, mInteresesNetos MONEY(16, 2);
DEFINE dTasaBruta DECIMAL(9, 6);
DEFINE iDias, vsec_dir, iAnioMes SMALLINT;
DEFINE v_mes, v_mes2 CHAR(2);
DEFINE mSaldoRet MONEY(15,2);
DEFINE cTipoPersona Char(1);
DEFINE mtotOtroscargos MONEY(16,2);
DEFINE mGat DECIMAL(9,4);
DEFINE mTotretirosefe MONEY(16,2);

DEFINE cCodretEdoCta  CHAR(5);
DEFINE cNomFis        CHAR(60);
DEFINE cNomNoFis      CHAR(60);
DEFINE cDescripcion   CHAR(100);
DEFINE cFechaGrafica  CHAR(6);
DEFINE cGrafica       CHAR(2);
DEFINE cProac         CHAR(2);

DEFINE cCodRetInfCte				CHAR(5);
DEFINE cCuenta	 					CHAR(20);
DEFINE cStatus	 					CHAR(1);
DEFINE cMotivo	 					CHAR(2);
DEFINE cOpcion	 					CHAR(2);
DEFINE mSdoDisponible				MONEY(16,2);
DEFINE mSdoRetenido					MONEY(16,2);
DEFINE mSdoCongelado				MONEY(16,2);
DEFINE mSdoActual					MONEY(16,2);
DEFINE cProductoCta					CHAR(4);
DEFINE mSBC							MONEY(16,2);
DEFINE sDireccionEnvio				SMALLINT;
DEFINE dFechaUltimoMov				DATE;
DEFINE cStatusTarjeta				CHAR(1);
DEFINE cTipoTarjeta					CHAR(1);
DEFINE cProductoTarjeta				CHAR(4);
DEFINE cNombreCteOEmpresa 			CHAR(200);
DEFINE cFechaNacOConstitucion 		DATE;
DEFINE cFirmantes					CHAR(1);
DEFINE cDescripcionProducto 		CHAR(44);
DEFINE cFechaAltaCta				DATE;
DEFINE cDireccioEnvioMaenoc 		CHAR(1);
DEFINE mSdoRetenidoMesAnterior 		MONEY(16,2);
DEFINE mSdoCongeladoMesAnterior 	MONEY(16,2);
DEFINE mSdoRetenidoActualHistorico 	MONEY(16,2);
DEFINE mSdoCongeladoActualHistorico MONEY(16,2);
DEFINE mSdoSobreGiroHistorico 		MONEY(16,2);
DEFINE dFechaHoy					DATE;
DEFINE mSBCMaehis			 		MONEY(16,2);

DEFINE  pEmpresa 			CHAR(3);
DEFINE  pUsuario 			CHAR(8);
DEFINE  pCuenta			    CHAR(20);
DEFINE  pProducto			CHAR(45);
DEFINE  pNumTarjeta			CHAR(16);
DEFINE  pClabe				CHAR(18);
DEFINE  pFechaIni			DATE;
DEFINE  pFechaFin			DATE;
DEFINE  pSaldoAnterior		MONEY(16,2);
DEFINE  pDepositos			MONEY(16,2);
DEFINE  pInteresesPagados	MONEY(16,2);
DEFINE  pRetiros			MONEY(16,2);
DEFINE  pOtrosCargos		MONEY(16,2);
DEFINE  pIvaOtrosCargos		MONEY(16,2);
DEFINE  pSaldoCorte			MONEY(16,2);
DEFINE  pSaldoPromedio		MONEY(16,2);
DEFINE  pRetencionISR		MONEY(16,2);
DEFINE  pInteresesNetos		MONEY(16,2);
DEFINE  pDias				INTEGER;
DEFINE  pTasaBruta			MONEY(16,2);
DEFINE  pNumCte				CHAR(20);
DEFINE  pNombreCte			CHAR(107);
DEFINE  pNumExterior		CHAR(10);
DEFINE  pNumInterior		CHAR(10);
DEFINE  pCalle				CHAR(30);
DEFINE  pColonia			CHAR(30);
DEFINE  pCiudad				CHAR(30);
DEFINE  pEstado				CHAR(30);
DEFINE  pCodPostal			CHAR(5);
DEFINE  pRFC				CHAR(13);
DEFINE  pCURP				CHAR(20);
DEFINE  pFechaAlta			DATE;
DEFINE  pSucursal			CHAR(40);
DEFINE  pRetMesAnt			MONEY(16,2);
DEFINE  pCongMesAnt			MONEY(16,2);
DEFINE  pSaldoRetenido		MONEY(16,2);
DEFINE  pSaldoCongelado		MONEY(16,2);
DEFINE  pSobreGiro			MONEY(16,2);
DEFINE  ptotOtrosCargos		MONEY(16,2);
DEFINE  pGat 				DECIMAL(9,4);
DEFINE  pTotretirosefe		MONEY(16,2);

--VARIABLES DE SALIDA DE sp_registraencabezadoedocta
DEFINE cCodRetEnca 			CHAR(5);
DEFINE iConsultaMaxima   INTEGER;

--VARIABLES DE SALIDA DE sp_edoctamovtos_central
DEFINE cCodRetEdoCtaMov            CHAR(5);
DEFINE cFechaMovEdoCtaMovto        CHAR(10);
DEFINE cReferenciaEdoCtaMovto      CHAR(40);
DEFINE cDescripcionEdoCtaMovto     CHAR(50);
DEFINE mRetiroEdoCtaMovto          MONEY(14,2);
DEFINE mDepositoEdoCtaMovto        MONEY(14,2); 
DEFINE mSaldoEdoCtaMovto           MONEY(14,2); 
DEFINE cSucursalEdoCtaMovto        CHAR(50);
DEFINE cTransaccEdoCtaMovto        CHAR(4);
DEFINE cNumTarjetaEdoCtaMovto      CHAR(16);

--VARIABLES DE SALIDA DE sp_grabaedoctamov
DEFINE cCodRetGrabaEdoCtaMov      CHAR(6);

--VARIABLES DE SALIDA DE sp_proac_edocta
DEFINE vCodRetProac CHAR(5);
DEFINE pEmpresaProac CHAR(03);
DEFINE pUsuarioProac CHAR(08); 
DEFINE vCicloProac SMALLINT;
DEFINE dFechaMov1Proac DATE;
DEFINE dFecha_cancProac CHAR(10);
DEFINE mRedondeoProac, mPremioProac MONEY(14, 2);
DEFINE mSaldo1Proac, mSaldo2Proac,mGranTotalProac MONEY(14, 2);
DEFINE cCuentaPROAC CHAR(20);
DEFINE dFechaAuxiliar DATE;
DEFINE iBandera     SMALLINT;
DEFINE cFechaI      CHAR(11);
DEFINE cFechaF      CHAR(11);
DEFINE mSaldo2      MONEY(14,2); 

--VARIABLES DE SALIDA DE sp_proac_edocta
LET vCodRetProac      = '000';
LET pEmpresaProac     = '001';
LET pUsuarioProac         = cNUMEMP;
LET vCicloProac       = 0;
LET dFechaMov1Proac   = '';
LET dFecha_cancProac  = '';
LET mRedondeoProac    = 0;
LET mPremioProac      = 0;
LET mSaldo1Proac      = 0;
LET mSaldo2Proac      = 0;
LET mGranTotalProac   = 0;
LET cCuentaPROAC      = '';
let dFechaAuxiliar    = '';

--INICIALIZA VARIABLES DE sp_grabaedoctamov
LET cCodRetGrabaEdoCtaMov = "000";

--INICIALIZA VARIABLES DE sp_edoctamovtos_central
LET cCodRetEdoCtaMov            = '000';
LET cFechaMovEdoCtaMovto        = '';
LET cReferenciaEdoCtaMovto      = '';
LET cDescripcionEdoCtaMovto     = '';
LET mRetiroEdoCtaMovto          = 0;
LET mDepositoEdoCtaMovto        = 0;
LET mSaldoEdoCtaMovto           = 0;
LET cSucursalEdoCtaMovto        = '';
LET cTransaccEdoCtaMovto        = '';
LET cNumTarjetaEdoCtaMovto      = '';


--INICIALIZA VARIABLES DE SALIDA DE sp_registraencabezadoedocta
LET cCodRetEnca 			= '00000';
LET iConsultaMaxima      = 0;

--INICIALIZA VARIABLES CONSTANTES
LET  iexiste   = 0;
LET cCodRet    = "00000";
LET iSql_err   = 0 ;	

--INICIALIZA VARIABLES DE sp_edoctagenerales_central
LET vcodret = "000";
LET cProducto = "";
LET cNumProducto = "";
LET cNumTarjeta = "";
LET cClabe = "";
LET cNumCte = "";
LET cNomCte = "";
LET cNumExt = "";
LET cNumInt = "";
LET cNomCalle = "";
LET cNomColonia = "";
LET cNomCiudad = "";
LET cNomEstado = "";
LET cCodPostal = "";
LET cRFC = "";
LET cCurp = "";
LET cNomSucursal = "";
LET dFechaIni = "";
LET dFechaFin = "";
LET dFechaAlta = "";
LET mSaldoPromedio= 0;
LET mInteresesNetos = 0;
LET mSaldoAnterior = 0;
LET mDepositos = 0;
LET mRetiros = 0;
LET mInteresesPagados = 0;
LET mOtrosCargos = 0;
LET mIvaOtrosCargos = 0;
LET mSaldoCorte = 0;
LET mRetencionIsr = 0;
LET iDias = 0;
LET dTasaBruta = 0;
LET mAux1 = 0;
LET vsec_dir = 0;
LET iAnioMes = 0;
LET pcuenta = '';
LET mSaldoRet = '';
LET cTipoPersona = "";
LET mtotOtroscargos= 0;
LET mGat = 0;
LET mTotretirosefe = 0;		

--INICIALIZA VARIABLES DE sp_ConsultaEdoCtaParam
LET cCodretEdoCta  = "000";
LET cNomFis        = '';
LET cNomNoFis      = '';
LET cDescripcion   = '';
LET cFechaGrafica  = '';
LET cGrafica       = '';
LET cProac         = '';	

--INICIALIZA VARIABLES DE sp_ObtieneInfoCteChq 
LET cCodRetInfCte   			= '00000';
--LET cNumCte	 					= '';
LET cCuenta	 					= '';
LET cStatus	 					= '';
LET cMotivo	 					= '';
LET cOpcion	 					= '';
LET mSdoDisponible				= 0.00;
LET mSdoRetenido				= 0.00;
LET mSdoCongelado				= 0.00;
LET mSdoActual					= 0.00;
LET cProductoCta				= '';
LET mSBC						= 0.00;
LET sDireccionEnvio				= 0;
LET dFechaUltimoMov				= '01/01/1900';
LET cStatusTarjeta				= '';
LET cTipoTarjeta				= '';
LET cProductoTarjeta			= '';
LET cNombreCteOEmpresa 			= '';
LET cFechaNacOConstitucion 		= '01/01/1900';
LET cFirmantes					= '';
LET cDescripcionProducto 		= '';
LET cFechaAltaCta				= '01/01/1900';
LET cDireccioEnvioMaenoc 		= '';
LET mSdoRetenidoMesAnterior 	= 0.00;
LET mSdoCongeladoMesAnterior 	= 0.00;
LET mSdoRetenidoActualHistorico = 0.00;
LET mSdoCongeladoActualHistorico  = 0.00;
LET mSdoSobreGiroHistorico 		= 0.00;
LET dFechaHoy					= '01/01/1900';
LET mSBCMaehis					= 0.00;
		
--INICIALIZA VARIABLES DE ENTRADA DE sp_RegistraEncabezadoEdoCta
LET  pEmpresa 			= '001';
LET  pUsuario 			= '';
LET  pCuenta			= '';
LET  pProducto			= '';
LET  pNumTarjeta		= '';
LET  pClabe				= '';
LET  pFechaIni			= '';
LET  pFechaFin			= '';
LET  pSaldoAnterior		= 0;
LET  pDepositos			= 0;
LET  pInteresesPagados	= 0;
LET  pRetiros			= 0;
LET  pOtrosCargos		= 0;
LET  pIvaOtrosCargos	= 0;
LET  pSaldoCorte		= 0;
LET  pSaldoPromedio		= 0;
LET  pRetencionISR		= 0;
LET  pInteresesNetos	= 0;
LET  pDias				= 0;
LET  pTasaBruta			= 0;
LET  pNumCte			= '';
LET  pNombreCte			= '';
LET  pNumExterior		= '';
LET  pNumInterior		= '';
LET  pCalle				= '';
LET  pColonia			= '';
LET  pCiudad			= '';
LET  pEstado			= '';
LET  pCodPostal			= '';
LET  pRFC				= '';
LET  pCURP				= '';
LET  pFechaAlta			= '';
LET  pSucursal			= '';
LET  pRetMesAnt			= 0;
LET  pCongMesAnt		= 0;
LET  pSaldoRetenido		= 0;
LET  pSaldoCongelado	= 0;
LET  pSobreGiro			= 0;
LET  ptotOtrosCargos	= 0;
LET  pGat 				= 0;
LET  pTotretirosefe		= 0;
LET iBandera=0;
LET cFechaI="";
LET cFechaF="";
LET mSaldo2=0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet,cANIOMES, pNombreCte, pCalle, pNumExterior, pNumInterior, pColonia, pCiudad, pEstado, pCodPostal,
			TODAY, pRFC, pCURP, pSucursal, pFechaAlta, pNumCte, pCuenta, pNumTarjeta, pClabe, pSaldoAnterior, pDepositos,
			pInteresesPagados, pRetiros, pOtrosCargos, pIvaOtrosCargos, pSaldoCorte, pSaldoPromedio, pRetencionISR, pInteresesNetos,
			pDias, pTasaBruta, pFechaFin, pGat,  pInteresesPagados, pOtrosCargos, mSdoActual,iConsultaMaxima,cFechaI,cFechaF;
		END IF;
	END EXCEPTION;
	              --    SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_edoctacap.out";
	              --    TRACE ON;
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA  = ''	OR 
		cANIOMES   IS NULL OR 
		cNUMEMP = '' THEN 
		LET cCodRet = "00036";
		RETURN
		cCodRet,cANIOMES, pNombreCte, pCalle, pNumExterior, pNumInterior, pColonia, pCiudad, pEstado, pCodPostal,
		TODAY, pRFC, pCURP, pSucursal, pFechaAlta, pNumCte, pCuenta, pNumTarjeta, pClabe, pSaldoAnterior, pDepositos,
		pInteresesPagados, pRetiros, pOtrosCargos, pIvaOtrosCargos, pSaldoCorte, pSaldoPromedio, pRetencionISR, pInteresesNetos,
		pDias, pTasaBruta, pFechaFin, pGat,  pInteresesPagados, pOtrosCargos, mSdoActual,iConsultaMaxima,cFechaI,cFechaF;
	END IF;	

	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'01','1')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
		RETURN  cCodRet,cANIOMES, pNombreCte, pCalle, pNumExterior, pNumInterior, pColonia, pCiudad, pEstado, pCodPostal,
				TODAY, pRFC, pCURP, pSucursal, pFechaAlta, pNumCte, pCuenta, pNumTarjeta, pClabe, pSaldoAnterior, pDepositos,
				pInteresesPagados, pRetiros, pOtrosCargos, pIvaOtrosCargos, pSaldoCorte, pSaldoPromedio, pRetencionISR, pInteresesNetos,
				pDias, pTasaBruta, pFechaFin, pGat,  pInteresesPagados, pOtrosCargos, mSdoActual,iConsultaMaxima,cFechaI,cFechaF;
	END IF;
	-- TERMINA VALIDACION
	
	SELECT NVL(COUNT(cuenta),0) into iexiste FROM bdicheq:sc_maechq WHERE cuenta  = cNUMCUENTA;
	IF iexiste  = 0 THEN 
		LET cCodRet = "00009";
		RETURN 
		cCodRet,cANIOMES, pNombreCte, pCalle, pNumExterior, pNumInterior, pColonia, pCiudad, pEstado, pCodPostal,
		TODAY, pRFC, pCURP, pSucursal, pFechaAlta, pNumCte, pCuenta, pNumTarjeta, pClabe, pSaldoAnterior, pDepositos,
		pInteresesPagados, pRetiros, pOtrosCargos, pIvaOtrosCargos, pSaldoCorte, pSaldoPromedio, pRetencionISR, pInteresesNetos,
		pDias, pTasaBruta, pFechaFin, pGat,  pInteresesPagados, pOtrosCargos, mSdoActual,iConsultaMaxima,cFechaI,cFechaF;
	END IF;
		
    
   
	SET ISOLATION TO DIRTY READ;

		EXECUTE PROCEDURE bdicheq:sp_edoctagenerales_central('001', cNUMCUENTA, cANIOMES, '0')
		INTO
		vcodret, cProducto, cNumProducto, cNumTarjeta, cClabe, dFechaIni, dFechaFin,
		mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos,
		mIvaOtrosCargos, mSaldoCorte, mSaldoPromedio, mRetencionIsr, mInteresesNetos,
		iDias, dTasaBruta, cNumCte, cNomcte, cNumExt,
		cNumInt, cNomCalle, cNomColonia, cNomCiudad, cNomEstado,
		cCodPostal, cRFC, cCurp, dFechaAlta, cNomSucursal, mSaldoRet,mtotOtroscargos, mGat, mTotretirosefe;
		
		IF vcodret  <> '000' THEN 
            LET cCodRet = "00007"; --NUEVO ERROR
		RETURN 
		cCodRet,cANIOMES, pNombreCte, pCalle, pNumExterior, pNumInterior, pColonia, pCiudad, pEstado, pCodPostal,
		TODAY, pRFC, pCURP, pSucursal, pFechaAlta, pNumCte, pCuenta, pNumTarjeta, pClabe, pSaldoAnterior, pDepositos,
		pInteresesPagados, pRetiros, pOtrosCargos, pIvaOtrosCargos, pSaldoCorte, pSaldoPromedio, pRetencionISR, pInteresesNetos,
		pDias, pTasaBruta, pFechaFin, pGat,  pInteresesPagados, pOtrosCargos, mSdoActual,iConsultaMaxima,cFechaI,cFechaF;
		END IF;
	
		IF cNumProducto <> '' THEN		
			EXECUTE PROCEDURE bdicheq:sp_consultaedoctaparam (cNumProducto)
			INTO
			cCodretEdoCta, cNomFis, cNomNoFis, cDescripcion, cFechaGrafica, cGrafica, cProac;

			--LA COMPARACION ES CON 000
			IF cCodretEdoCta <> '000' THEN
				LET cCodRet = "00008"; 
				RETURN 
				cCodRet,cANIOMES, pNombreCte, pCalle, pNumExterior, pNumInterior, pColonia, pCiudad, pEstado, pCodPostal,
				TODAY, pRFC, pCURP, pSucursal, pFechaAlta, pNumCte, pCuenta, pNumTarjeta, pClabe, pSaldoAnterior, pDepositos,
				pInteresesPagados, pRetiros, pOtrosCargos, pIvaOtrosCargos, pSaldoCorte, pSaldoPromedio, pRetencionISR, pInteresesNetos,
				pDias, pTasaBruta, pFechaFin, pGat,  pInteresesPagados, pOtrosCargos, mSdoActual,iConsultaMaxima,cFechaI,cFechaF;
			END IF;
			
			FOREACH 
				EXECUTE PROCEDURE bdicheq:sp_obtieneinfoctechq (cNUMCUENTA,'','',cANIOMES) 
				INTO
				cCodRetInfCte,cCuenta,cNumCte,cStatus,cMotivo,
				cOpcion,cDescripcionProducto,mSdoDisponible,
				mSdoRetenido,mSdoCongelado,mSdoActual,
				cProductoCta,mSBC,cClabe,sDireccionEnvio,dFechaUltimoMov,cNumTarjeta,
				cStatusTarjeta,cTipoTarjeta,cProductoTarjeta,cFechaAltaCta,cDireccioEnvioMaenoc,
				mSdoRetenidoMesAnterior,mSdoCongeladoMesAnterior,
				mSdoRetenidoActualHistorico,mSdoCongeladoActualHistorico,
				--mSdoSobreGiroHistorico,dFechaFin,cNombreCteOEmpresa,cRFC,cTipoPersona,
                mSdoSobreGiroHistorico,pFechaFin,cNombreCteOEmpresa,cRFC,cTipoPersona,
				cFechaNacOConstitucion,cFirmantes,mSBCMaehis
			END FOREACH;
			
			IF cCodRetInfCte <> '00000' THEN
				LET cCodRet = "00009"; 
				RETURN 
				cCodRet,cANIOMES, pNombreCte, pCalle, pNumExterior, pNumInterior, pColonia, pCiudad, pEstado, pCodPostal,
				TODAY, pRFC, pCURP, pSucursal, pFechaAlta, pNumCte, pCuenta, pNumTarjeta, pClabe, pSaldoAnterior, pDepositos,
				pInteresesPagados, pRetiros, pOtrosCargos, pIvaOtrosCargos, pSaldoCorte, pSaldoPromedio, pRetencionISR, pInteresesNetos,
				pDias, pTasaBruta, pFechaFin, pGat,  pInteresesPagados, pOtrosCargos, mSdoActual,iConsultaMaxima,cFechaI,cFechaF;
			END IF;
		END IF;

		--ASIGNA VALORES A INSERTAR 
		LET  pUsuario 			= cNUMEMP;
		LET  pCuenta			= cNUMCUENTA;
		LET  pProducto			= cProducto;
		LET  pNumTarjeta		= cNumTarjeta;
		LET  pClabe				= cClabe;
		--LET  pFechaIni			= dFechaIni;
		--LET  pFechaFin			= dFechaFin;
		LET  pSaldoAnterior		= mSaldoAnterior;
		LET  pDepositos			= mDepositos;
		LET  pInteresesPagados	= mInteresesPagados;
		LET  pRetiros			= mRetiros;
		LET  pOtrosCargos		= mOtrosCargos;
		LET  pIvaOtrosCargos	= mIvaOtrosCargos;
		LET  pSaldoCorte		= mSaldoCorte;
		LET  pSaldoPromedio		= mSaldoPromedio;
		LET  pRetencionISR		= mRetencionIsr;
		LET  pInteresesNetos	= mInteresesNetos;
		LET  pDias				= iDias;
		LET  pTasaBruta			= dTasaBruta;
		LET  pNumCte			= cNumcte;
		LET  pNombreCte			= cNomCte;
		LET  pNumExterior		= cNumExt;
		LET  pNumInterior		= cNumInt;
		LET  pCalle				= cNomCalle;
		LET  pColonia			= cNomColonia;
		LET  pCiudad			= cNomCiudad;
		LET  pEstado			= cNomEstado;
		LET  pCodPostal			= cCodPostal;
		LET  pRFC				= cRFC;
		LET  pCURP				= cCurp;
		LET  pFechaAlta			= dFechaAlta;
		LET  pSucursal			= cNomSucursal;
		LET  pRetMesAnt			= mSdoRetenidoMesAnterior;
		LET  pCongMesAnt		= mSdoCongeladoMesAnterior;
		LET  pSaldoRetenido		= mSaldoRet;
		LET  pSaldoCongelado	= mSdoCongeladoActualHistorico;
		LET  pSobreGiro			= mSdoSobreGiroHistorico;
		LET  ptotOtrosCargos	= mtotOtroscargos;
		LET  pGat 				= mGat;
		LET  pTotretirosefe		= mTotretirosefe;
        LET  mSaldo2            = pSaldoCorte;
		
		EXECUTE PROCEDURE bdicheq:sp_registraencabezadoedocta (pEmpresa, pUsuario, pCuenta, pProducto, pNumTarjeta, pClabe, pFechaIni, pFechaFin, pSaldoAnterior, pDepositos,
		pInteresesPagados, pRetiros, pOtrosCargos, pIvaOtrosCargos, pSaldoCorte, pSaldoPromedio, pRetencionISR, pInteresesNetos,
		pDias, pTasaBruta, pNumCte, pNombreCte, pNumExterior, pNumInterior, pCalle, pColonia, pCiudad, pEstado, pCodPostal, pRFC,
		pCURP, pFechaAlta, pSucursal, pRetMesAnt, pCongMesAnt, pSaldoRetenido, pSaldoCongelado, pSobreGiro, ptotOtrosCargos, pGat,
		pTotretirosefe)
		INTO
		cCodRetEnca, iConsultaMaxima;

		IF cCodRetEnca <> '00000' THEN
			LET cCodRet = "00010"; --NUEVO ERROR
			RETURN 
			cCodRet,cANIOMES, pNombreCte, pCalle, pNumExterior, pNumInterior, pColonia, pCiudad, pEstado, pCodPostal,
			TODAY, pRFC, pCURP, pSucursal, pFechaAlta, pNumCte, pCuenta, pNumTarjeta, pClabe, pSaldoAnterior, pDepositos,
			pInteresesPagados, pRetiros, pOtrosCargos, pIvaOtrosCargos, pSaldoCorte, pSaldoPromedio, pRetencionISR, pInteresesNetos,
			pDias, pTasaBruta, pFechaFin, pGat,  pInteresesPagados, pOtrosCargos, mSdoActual,iConsultaMaxima,cFechaI,cFechaF;
		END IF;
		
		IF iConsultaMaxima > 0 THEN
		    FOREACH
				EXECUTE PROCEDURE bdicheq:sp_edoctamovtos_central('001', cNUMCUENTA,dFechaIni, dFechaFin,0,cNUMEMP,iConsultaMaxima)
				INTO
				cCodRetEdoCtaMov, cFechaMovEdoCtaMovto, cReferenciaEdoCtaMovto, cDescripcionEdoCtaMovto, mRetiroEdoCtaMovto, 
				mDepositoEdoCtaMovto, mSaldoEdoCtaMovto, cSucursalEdoCtaMovto, cTransaccEdoCtaMovto, cNumTarjetaEdoCtaMovto
                IF cCodRetEdoCtaMov <> '000' and cCodRetEdoCtaMov <> '100' THEN
                    LET cCodRet = "00011"; --NUEVO ERROR
                    RETURN 
                    cCodRet,cANIOMES, pNombreCte, pCalle, pNumExterior, pNumInterior, pColonia, pCiudad, pEstado, pCodPostal,
                    TODAY, pRFC, pCURP, pSucursal, pFechaAlta, pNumCte, pCuenta, pNumTarjeta, pClabe, pSaldoAnterior, pDepositos,
                    pInteresesPagados, pRetiros, pOtrosCargos, pIvaOtrosCargos, pSaldoCorte, pSaldoPromedio, pRetencionISR, pInteresesNetos,
                    pDias, pTasaBruta, pFechaFin, pGat,  pInteresesPagados, pOtrosCargos, mSdoActual,iConsultaMaxima,cFechaI,cFechaF;
                END IF;		
                IF cFechaMovEdoCtaMovto<>'' THEN
                    LET cFechaMovEdoCtaMovto = SUBSTR(cFechaMovEdoCtaMovto,6,2) || '/' || SUBSTR(cFechaMovEdoCtaMovto,9,2) || '/' || SUBSTR(cFechaMovEdoCtaMovto,1,4);
                    IF cCodRetEdoCtaMov = '000' THEN
                        IF mRetiroEdoCtaMovto>0 THEN
                            LET mSaldo2= mSaldo2 + mRetiroEdoCtaMovto;
                        ELIF mDepositoEdoCtaMovto>0 THEN
                            LET mSaldo2= mSaldo2 - mDepositoEdoCtaMovto;
                        END IF;

                        EXECUTE PROCEDURE bdicheq:sp_grabaedoctamov('001', cNUMEMP, cNUMCUENTA, cFechaMovEdoCtaMovto, '', '', mRetiroEdoCtaMovto, 
                        mDepositoEdoCtaMovto, mSaldo2, cDescripcionEdoCtaMovto, cReferenciaEdoCtaMovto, cSucursalEdoCtaMovto, '', '', '',iConsultaMaxima)
                        INTO
                        cCodRetGrabaEdoCtaMov;
                    END IF;        

                    IF cCodRetGrabaEdoCtaMov <> '000' THEN
                        LET  cCodRet = '00012';	-- 
                        RETURN 
                        cCodRet,cANIOMES, pNombreCte, pCalle, pNumExterior, pNumInterior, pColonia, pCiudad, pEstado, pCodPostal,
                        TODAY, pRFC, pCURP, pSucursal, pFechaAlta, pNumCte, pCuenta, pNumTarjeta, pClabe, pSaldoAnterior, pDepositos,
                        pInteresesPagados, pRetiros, pOtrosCargos, pIvaOtrosCargos, pSaldoCorte, pSaldoPromedio, pRetencionISR, pInteresesNetos,
                        pDias, pTasaBruta, pFechaFin, pGat,  pInteresesPagados, pOtrosCargos, mSdoActual,iConsultaMaxima,cFechaI,cFechaF;
                    END IF; 
                END IF;    

			END FOREACH;
		END IF;
		
		LET dFechaAuxiliar = CAST(cFechaMovEdoCtaMovto AS DATE);
		
		IF cProac <> '0' THEN
			EXECUTE PROCEDURE  bdicheq:sp_proac_edocta('C',cNUMEMP,'001', cNUMCUENTA, pFechaIni, dFechaAuxiliar,0, iConsultaMaxima)
			INTO
			vCodRetProac, pEmpresaProac,pUsuarioProac,vCicloProac,cCuentaPROAC,dFechaMov1Proac,mRedondeoProac,mSaldo1Proac,mPremioProac,
			mSaldo2Proac,mGranTotalProac,dFecha_cancProac;		  
		END IF;
	
		LET  pEmpresa 			= '001';
		LET  pUsuario 			= '';
		LET  pCuenta			= '';
		LET  pProducto			= '';
		LET  pNumTarjeta		= '';
		LET  pClabe				= '';
		LET  pFechaIni			= '';
		LET  pFechaFin			= '';
		LET  pSaldoAnterior		= 0;
		LET  pDepositos			= 0;
		LET  pInteresesPagados	= 0;
		LET  pRetiros			= 0;
		LET  pOtrosCargos		= 0;
		LET  pIvaOtrosCargos	= 0;
		LET  pSaldoCorte		= 0;
		LET  pSaldoPromedio		= 0;
		LET  pRetencionISR		= 0;
		LET  pInteresesNetos	= 0;
		LET  pDias				= 0;
		LET  pTasaBruta			= 0;
		LET  pNumCte			= '';
		LET  pNombreCte			= '';
		LET  pNumExterior		= '';
		LET  pNumInterior		= '';
		LET  pCalle				= '';
		LET  pColonia			= '';
		LET  pCiudad			= '';
		LET  pEstado			= '';
		LET  pCodPostal			= '';
		LET  pRFC				= '';
		LET  pCURP				= '';
		LET  pFechaAlta			= '';
		LET  pSucursal			= '';
		LET  pRetMesAnt			= 0;
		LET  pCongMesAnt		= 0;
		LET  pSaldoRetenido		= 0;
		LET  pSaldoCongelado	= 0;
		LET  pSobreGiro			= 0;
		LET  ptotOtrosCargos	= 0;
		LET  pGat 				= 0;
		LET  pTotretirosefe		= 0;
		
		--LA COMPARACION ES CON 000
/*		IF vCodRetProac <> '000' THEN
			LET  cCodRet = '00013';	
			RETURN 
			cCodRet,cANIOMES, pNombreCte, pCalle, pNumExterior, pNumInterior, pColonia, pCiudad, pEstado, pCodPostal,
			TODAY, pRFC, pCURP, pSucursal, pFechaAlta, pNumCte, pCuenta, pNumTarjeta, pClabe, pSaldoAnterior, pDepositos,
			pInteresesPagados, pRetiros, pOtrosCargos, pIvaOtrosCargos, pSaldoCorte, pSaldoPromedio, pRetencionISR, pInteresesNetos,
			pDias, pTasaBruta, pFechaFin, pGat,  pInteresesPagados, pOtrosCargos, mSdoActual,iConsultaMaxima,cFechaI,cFechaF;
		END IF; */
		
		SELECT {+INDEX (bdicheq:vedocta idx_usu1)} empresa, cod_usuario, cuenta, producto, tarjeta, clabe, fechaini, fechafin, saldoanterior, depositos,
		interesespagados, retiros, otroscargos, ivaotroscargos, saldocorte, saldopromedio, retencionisr, interesesnetos,
		dias, tasabruta, numerocliente, nombrecliente, numeroexterior, numerointerior, calle, colonia, ciudad, estado, codigopostal, rfc,
		curp, fechaalta, sucursal, ret_mes_ant, cong_mes_ant, sdo_retenido, sdo_cong, sobregiro, consulta, totretirosefec, tototroscargos,porcientogat 
		INTO
		pEmpresa, pUsuario, pCuenta, pProducto, pNumTarjeta, pClabe, pFechaIni, pFechaFin, pSaldoAnterior, pDepositos,
		pInteresesPagados, pRetiros, pOtrosCargos, pIvaOtrosCargos, pSaldoCorte, pSaldoPromedio, pRetencionISR, pInteresesNetos,
		pDias, pTasaBruta, pNumCte, pNombreCte, pNumExterior, pNumInterior, pCalle, pColonia, pCiudad, pEstado, pCodPostal, pRFC,
		pCURP, pFechaAlta, pSucursal, pRetMesAnt, pCongMesAnt, pSaldoRetenido, pSaldoCongelado, pSobreGiro, iConsultaMaxima, pTotretirosefe, ptotOtrosCargos, pGat
		FROM bdicheq:vedocta
	    WHERE cod_usuario=cNUMEMP AND consulta = iConsultaMaxima;

       IF MONTH(dFechaIni) = 1 THEN
        LET cFechaI=DAY(dFechaIni) ||  '/' ||  'ENE' ||  '/' || YEAR(dFechaIni);
       ELIF MONTH(dFechaIni) = 2 THEN
        LET cFechaI=DAY(dFechaIni) ||  '/' ||  'FEB' ||  '/' || YEAR(dFechaIni);
       ELIF MONTH(dFechaIni) = 3 THEN
        LET cFechaI=DAY(dFechaIni) ||  '/' ||  'MAR' ||  '/' || YEAR(dFechaIni);
       ELIF MONTH(dFechaIni) = 4 THEN
        LET cFechaI=DAY(dFechaIni) ||  '/' ||  'ABR' ||  '/' || YEAR(dFechaIni);
       ELIF MONTH(dFechaIni) = 5 THEN
        LET cFechaI=DAY(dFechaIni) ||  '/' ||  'MAY' ||  '/' || YEAR(dFechaIni);
       ELIF MONTH(dFechaIni) = 6 THEN
        LET cFechaI=DAY(dFechaIni) ||  '/' ||  'JUN' ||  '/' || YEAR(dFechaIni);
       ELIF MONTH(dFechaIni) = 7 THEN
        LET cFechaI=DAY(dFechaIni) ||  '/' ||  'JUL' ||  '/' || YEAR(dFechaIni);
       ELIF MONTH(dFechaIni) = 8 THEN
        LET cFechaI=DAY(dFechaIni) ||  '/' ||  'AGO' ||  '/' || YEAR(dFechaIni);
       ELIF MONTH(dFechaIni) = 9 THEN
        LET cFechaI=DAY(dFechaIni) ||  '/' ||  'SEP' ||  '/' || YEAR(dFechaIni);
       ELIF MONTH(dFechaIni) = 10 THEN
        LET cFechaI=DAY(dFechaIni) ||  '/' ||  'OCT' ||  '/' || YEAR(dFechaIni);
       ELIF MONTH(dFechaIni) = 11 THEN
        LET cFechaI=DAY(dFechaIni) ||  '/' ||  'NOV' ||  '/' || YEAR(dFechaIni);
       ELIF MONTH(dFechaIni) = 12 THEN
        LET cFechaI=DAY(dFechaIni) ||  '/' ||  'DIC' ||  '/' || YEAR(dFechaIni);
       END IF; 


       IF MONTH(dFechaFin) = 1 THEN
        LET cFechaF=DAY(dFechaFin) ||  '/' ||  'ENE' ||  '/' || YEAR(dFechaFin);
       ELIF MONTH(dFechaFin) = 2 THEN
        LET cFechaF=DAY(dFechaFin) ||  '/' ||  'FEB' ||  '/' || YEAR(dFechaFin);
       ELIF MONTH(dFechaFin) = 3 THEN
        LET cFechaF=DAY(dFechaFin) ||  '/' ||  'MAR' ||  '/' || YEAR(dFechaFin);
       ELIF MONTH(dFechaFin) = 4 THEN
        LET cFechaF=DAY(dFechaFin) ||  '/' ||  'ABR' ||  '/' || YEAR(dFechaFin);
       ELIF MONTH(dFechaFin) = 5 THEN
        LET cFechaF=DAY(dFechaFin) ||  '/' ||  'MAY' ||  '/' || YEAR(dFechaFin);
       ELIF MONTH(dFechaFin) = 6 THEN
        LET cFechaF=DAY(dFechaFin) ||  '/' ||  'JUN' ||  '/' || YEAR(dFechaFin);
       ELIF MONTH(dFechaFin) = 7 THEN
        LET cFechaF=DAY(dFechaFin) ||  '/' ||  'JUL' ||  '/' || YEAR(dFechaFin);
       ELIF MONTH(dFechaFin) = 8 THEN
        LET cFechaF=DAY(dFechaFin) ||  '/' ||  'AGO' ||  '/' || YEAR(dFechaFin);
       ELIF MONTH(dFechaFin) = 9 THEN
        LET cFechaF=DAY(dFechaFin) ||  '/' ||  'SEP' ||  '/' || YEAR(dFechaFin);
       ELIF MONTH(dFechaFin) = 10 THEN
        LET cFechaF=DAY(dFechaFin) ||  '/' ||  'OCT' ||  '/' || YEAR(dFechaFin);
       ELIF MONTH(dFechaFin) = 11 THEN
        LET cFechaF=DAY(dFechaFin) ||  '/' ||  'NOV' ||  '/' || YEAR(dFechaFin);
       ELIF MONTH(dFechaFin) = 12 THEN
        LET cFechaF=DAY(dFechaFin) ||  '/' ||  'DIC' ||  '/' || YEAR(dFechaFin);
       END IF; 


		RETURN 
			cCodRet,cANIOMES,pNombreCte, pCalle, pNumExterior, pNumInterior, pColonia, pCiudad, pEstado, pCodPostal,
			TODAY, pRFC, pCURP, pSucursal, pFechaAlta, pNumCte, pCuenta, pNumTarjeta, pClabe, pSaldoAnterior, pDepositos,
			pInteresesPagados, pRetiros, pOtrosCargos, pIvaOtrosCargos, pSaldoCorte, pSaldoPromedio, pRetencionISR, pInteresesNetos,
            --pDias, pTasaBruta, pFechaFin, pGat,  pInteresesPagados, pOtrosCargos, mSdoActual,iConsultaMaxima,cFechaI,cFechaF;
            pDias, pTasaBruta, pFechaFin, pGat,  pInteresesPagados, pOtrosCargos, pSaldoCorte,iConsultaMaxima,cFechaI,cFechaF;
	
END
END PROCEDURE
;