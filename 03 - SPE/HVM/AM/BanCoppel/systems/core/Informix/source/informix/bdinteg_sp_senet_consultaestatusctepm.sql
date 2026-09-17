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