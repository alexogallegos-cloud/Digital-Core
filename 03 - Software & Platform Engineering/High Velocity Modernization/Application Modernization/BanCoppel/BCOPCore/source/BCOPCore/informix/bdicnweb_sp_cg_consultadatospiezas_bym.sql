CREATE PROCEDURE "informix".sp_cg_consultadatospiezas_bym(pUsuario CHAR(8), pIdFuncion CHAR(10),pFechaCaptura DATE, pFechaIni DATE, pFechaFin DATE, pSucursal CHAR(4), pNumRecibo CHAR(10), pNumGuia CHAR(12), pEstatus INTEGER, pDictamen INTEGER, pTipoConsulta INTEGER, pRegistros INTEGER,pRecuperacion INTEGER)
    RETURNING CHAR(5) AS CodRet,
		INTEGER 	AS CvePieza,
		DATE 		AS FechaCaptura,
		CHAR(10) 	AS NumRecibo,
		INTEGER 	AS NumPiezas,
		CHAR(1) 	AS TipoPieza,
		CHAR(10) 	AS Denominacion,
		INTEGER 	AS CveDenominacion,
		CHAR(40) 	AS Serie,
		CHAR(40) 	AS Folio,
		DATE 		AS FechaEmision,
		CHAR(200) 	AS Nota,
		CHAR(20) 	AS Estatus,
		CHAR(20) 	AS DictamenBanxico,
		CHAR(40) 	AS NumLoteBanxico,
		CHAR(40) 	AS FolioBanxico,
		DATE 		AS FechaPago,
		CHAR(20) 	AS FormaPago,
		CHAR(11) 	AS NumCta,
		CHAR(4) 	AS NumSuc,
		CHAR(40) 	AS NombreSuc,
		CHAR(80) 	AS DomSuc,
		CHAR(45) 	AS NomOperador,
		CHAR(40) 	AS ApellidoTenedor1,
		CHAR(40) 	AS ApellidoTenedor2,
		CHAR(40) 	AS NomTenedor1,
		CHAR(40) 	AS NomTenedor2,
		CHAR(50) 	AS Identificacion,
		CHAR(40) 	AS NumIdentificacion,
		CHAR(30) 	AS Calle,
		CHAR(10) 	AS NumCasa,
		CHAR(32) 	AS Colonia,
		CHAR(60) 	AS Delegacion,
		CHAR(5) 	AS CodPostal,
		CHAR(60) 	AS Ciudad,
		CHAR(2) 	AS Estado,
		CHAR(13) 	AS Telefono,
		CHAR(30) 	AS Email,
		CHAR(8)     AS Operador,
		CHAR(30)    AS EstadoDesc;
			
	DEFINE iSqlErr               INTEGER;
	DEFINE iSamErr               INTEGER;
	DEFINE cDesErr               CHAR(80);
	DEFINE cCodRet               CHAR(5);
	DEFINE cCodRetSp 			 CHAR(6);
	DEFINE cMensaje              CHAR(80);
	DEFINE iRecuperacion 		 INTEGER;
	DEFINE iCvePieza             INTEGER;
	DEFINE dFechaCaptura         DATE;
	DEFINE cNumRecibo            CHAR(10);
	DEFINE iNumPiezas            INTEGER;
	DEFINE cTipoPieza            CHAR(1);
	DEFINE cDenominacion         CHAR(10);
	DEFINE iCveDenominacion      INTEGER;
	DEFINE cSerie                CHAR(40);
	DEFINE cFolio                CHAR(40);
	DEFINE dFechaEmision         DATE;
	DEFINE cNota                 CHAR(200);
	DEFINE cEstatus              CHAR(20);
	DEFINE cDictamenBanxico      CHAR(20);
	DEFINE cNumLoteBanxico       CHAR(40);
	DEFINE cFolioBanxico         CHAR(40);
	DEFINE dFechaPago            DATE;
	DEFINE cFormaPago            CHAR(20);
	DEFINE cNumCta               CHAR(11);
	DEFINE cNumSuc               CHAR(4);
	DEFINE cNombreSuc            CHAR(40);
	DEFINE cDomSuc               CHAR(80);
	DEFINE cNomOperador          CHAR(45);
	DEFINE cApellidoTenedor1     CHAR(40);
	DEFINE cApellidoTenedor2     CHAR(40);
	DEFINE cNomTenedor1          CHAR(40);
	DEFINE cNomTenedor2          CHAR(40);
	DEFINE cIdentificacion       CHAR(50);
	DEFINE cNumIdentificacion    CHAR(40);
	DEFINE cCalle                CHAR(30);
	DEFINE cNumCasa              CHAR(10);
	DEFINE cColonia              CHAR(32);
	DEFINE cDelegacion           CHAR(60);
	DEFINE cCodPostal            CHAR(5);
	DEFINE cCiudad               CHAR(60);
	DEFINE cEstado               CHAR(2);
	DEFINE cTelefono             CHAR(13);
	DEFINE cEmail                CHAR(30); 

	DEFINE dFechaInicio          DATE;
	DEFINE dFechaFin             DATE;
	DEFINE iBandFecha            INTEGER;
	DEFINE iBandInicio           INTEGER;
	DEFINE iBandRegistros        INTEGER;
	DEFINE iRegistros            INTEGER;
	DEFINE iRegCon               INTEGER;
	DEFINE iContador             INTEGER;
	DEFINE iTermino              INTEGER;
	DEFINE cNumReciboCon         CHAR(10);
	DEFINE iIdTenedor            INTEGER;
	DEFINE cNumSucursalReten     CHAR(4);
	DEFINE cNombre1              CHAR(40);
	DEFINE cNombre2              CHAR(40);
	DEFINE cApPaterno            CHAR(40);
	DEFINE cApMaterno            CHAR(40);
	DEFINE cCalleCon             CHAR(40);
	DEFINE cNumeroCalle          CHAR(10);
	DEFINE cColoniaCon           CHAR(6);
	DEFINE cDelegacionPoblacion  CHAR(3);
	DEFINE cCodPostalCon         CHAR(5);
	DEFINE cCiudadCon            CHAR(3);
	DEFINE cEstadoCon            CHAR(2);
	DEFINE cTelefonoCon          CHAR(13);
	DEFINE cEmailCon             CHAR(30);
	DEFINE cEjecutivoInsert      CHAR(8);
	DEFINE cIdentificacionCon    CHAR(20);
	DEFINE cIdentificacionDes    CHAR(50);
	DEFINE cNumIdentificacionCon CHAR(40);
	DEFINE cIdPieza              INTEGER;
	DEFINE dFechaRecepcion       DATE;
	DEFINE iIdDenominacion       INTEGER;
	DEFINE cSerieCon             CHAR(40);
	DEFINE cFolioCon             CHAR(40);
	DEFINE dFechaEmisionCon      DATE;
	DEFINE iNumPiezasCon         INTEGER;
	DEFINE cNotaCon              CHAR(200);
	DEFINE cFolioBanxicoCon      CHAR(40);
	DEFINE iDictamenBanxico      INTEGER;
	DEFINE cNumLoteBanxicoCon    CHAR(40);
	DEFINE dFechaPagoCon         DATE;
	DEFINE iTipoPago             INTEGER;
	DEFINE cNumCtaCliente        CHAR(11);
	DEFINE iEstatus              INTEGER;
	DEFINE dFechaInsert          DATE;
	DEFINE cNombreScucursal      CHAR(40);
	DEFINE cDireccion1           CHAR(40);
	DEFINE cNombreOperador       CHAR(45);
	DEFINE cDesCvePieza          CHAR(1); 
	DEFINE cDenominacionCon      CHAR(10);
	DEFINE cDesDictamen          CHAR(20);  
	DEFINE cDesTipoPago          CHAR(20);
	DEFINE cDesEstatus           CHAR(20);
	DEFINE cCodigo               CHAR(3);
	DEFINE cPromotor             CHAR(8);
	DEFINE cCiudadoDelegacion    CHAR(3);
	DEFINE cCiudadoCoppel        INTEGER;
	DEFINE cNombreCidDel         CHAR(60);
	DEFINE cNombreCol		     CHAR(32);
	DEFINE cNombreCalle          CHAR(30);	
	DEFINE cNombreCiudad         CHAR(60);
	DEFINE cNombreDelegacion     CHAR(60);
	DEFINE cEstadoDes            CHAR(30);
	DEFINE cEstadoDesRes         CHAR(30);
	DEFINE cEstadoBanxico        CHAR(3);
	DEFINE cEmpresa 			 CHAR(3);
	DEFINE dFechaHoy 			 DATE;

	LET iSqlErr                 = 0;
	LET iSamErr                 = 0;
	LET cDesErr                 = '';
	LET cCodRet                 = '00000';
	LET cCodRetSp				= '000000';
	LET cMensaje                = '';
	LET iRecuperacion			= 0;
	LET iCvePieza               = 0;
	LET dFechaCaptura           = DATE(1);
	LET cNumRecibo              = '';
	LET iNumPiezas              = 0;
	LET cTipoPieza              = '';
	LET cDenominacion           = '';
	LET iCveDenominacion        = 0;  
	LET cSerie                  = '';
	LET cFolio                  = '';
	LET dFechaEmision           = DATE(1);
	LET cNota                   = '';
	LET cEstatus                = '';  
	LET cDictamenBanxico        = '';  
	LET cNumLoteBanxico         = '';
	LET cFolioBanxico           = '';
	LET dFechaPago              = DATE(1);
	LET cFormaPago              = ''; 
	LET cNumCta                 = '';
	LET cNumSuc                 = '';
	LET cNombreSuc              = '';
	LET cDomSuc                 = ''; 
	LET cNomOperador            = '';
	LET cApellidoTenedor1       = ''; 
	LET cApellidoTenedor2       = '';                                                                                                                               
	LET cNomTenedor1            = '';
	LET cNomTenedor2            = '';
	LET cIdentificacion         = '';
	LET cNumIdentificacion      = ''; 
	LET cCalle                  = '';
	LET cNumCasa                = '';                                             
	LET cColonia                = '';
	LET cDelegacion             = '';
	LET cCodPostal              = '';
	LET cCiudad                 = '';
	LET cEstado                 = '';
	LET cTelefono               = '';
	LET cEmail                  = '';

	LET dFechaInicio            = DATE(1);
	LET dFechaFin               = DATE(1);
	LET iBandFecha              = 0;
	LET iBandInicio             = 0;
	LET iBandRegistros          = 0;
	LET iRegistros              = 0;
	LET iRegCon                 = 0;
	LET iContador               = 0;
	LET iTermino                = 0;
	LET cNumReciboCon			= '';
	LET iIdTenedor				= 0;
	LET cNumSucursalReten		= '';
	LET cNombre1				= '';
	LET cNombre2				= '';
	LET cApPaterno				= '';
	LET cApMaterno				= '';
	LET cCalleCon				= '';
	LET cNumeroCalle			= '';
	LET cColoniaCon				= '';
	LET cDelegacionPoblacion	= '';
	LET cCodPostalCon			= '';
	LET cCiudadCon				= '';
	LET cEstadoCon				= '';
	LET cTelefonoCon			= '';
	LET cEmailCon				= '';
	LET cEjecutivoInsert		= '';
	LET cIdentificacionCon		= '';
	LET cIdentificacionDes 	    = '';
	LET cNumIdentificacionCon	= '';
	LET cIdPieza				= 0;
	LET dFechaRecepcion			= DATE(1);
	LET iIdDenominacion			= 0;
	LET cSerieCon				= '';
	LET cFolioCon				= '';
	LET dFechaEmisionCon		= DATE(1);
	LET iNumPiezasCon			= 0;
	LET cNotaCon				= '';
	LET cFolioBanxicoCon		= '';
	LET iDictamenBanxico		= 0;
	LET cNumLoteBanxicoCon		= '';
	LET dFechaPagoCon           = DATE(1);
	LET iTipoPago				= 0;
	LET cNumCtaCliente			= '';
	LET iEstatus				= 0;
	LET dFechaInsert            = DATE(1);
	LET cNombreScucursal        = '';
	LET cDireccion1             = '';
	LET cNombreOperador         = '';
	LET cDesCvePieza            = '';
	LET cDenominacionCon        = ''; 
	LET cDesDictamen            = ''; 
	LET cDesTipoPago            = ''; 
	LET cDesEstatus             = ''; 
	LET cCodigo                 = ''; 
	LET cPromotor               = '';
	LET cCiudadoDelegacion      = '';
	LET cCiudadoCoppel          = 0;
	LET cNombreCidDel           = '';
	LET cNombreCol		        = '';
	LET cNombreCalle            = '';
	LET cNombreCiudad           = '';	
	LET cNombreDelegacion       = '';
	LET cEstadoDes              = '';
	LET cEstadoDesRes           = '';
	LET cEstadoBanxico          =  '';
	LET cEmpresa 				= '001';
	LET dFechaHoy 				= DATE(CURRENT);

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_consultadatospiezas_bym.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL OR pTipoConsulta IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
		   RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
		END IF;

		IF pTipoConsulta = 1 THEN --GRID PRINCIPAL
		
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;

			FOREACH 
				
				SELECT {+INDEX (bdicnweb:sw_cg_billetesfalsos idx_sw_cg_billetesfalsos)} SKIP pRegistros FIRST pRecuperacion 
				cve_pieza,fecha_captura,num_recibo,num_piezas,tipo_pieza,denominacion,cve_denominacion,serie,folio,fecha_emision,nota,estatus,dictamen_banxico,num_lote_banxico,folio_banxico,fecha_pago,
				forma_pago,num_cta,num_suc,nombre_suc,dom_suc,nom_operador,apellido_tenedor1, apellido_tenedor2, nom_tenedor1,nom_tenedor2,
				identificacion,num_identificacion,calle, numcasa,colonia,delegacion,codpostal, ciudad,estado,telefono,email,operador,estado_desc  
				INTO iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, 
				cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,
				cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes
				FROM bdicnweb:"informix".sw_cg_billetesfalsos
				WHERE us_insert=pUsuario
				ORDER BY id_serial ASC

				LET iRecuperacion = iRecuperacion + 1;	
				RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes WITH RESUME;           
		
			END FOREACH;
		
		ELSE --GRID REPORTE
		
			FOREACH 
			
				EXECUTE PROCEDURE bdisuc:"informix".sp_consultadatospiezas_bym3(pFechaCaptura, pFechaIni, pFechaFin, pSucursal, pNumRecibo, pNumGuia, pEstatus, pDictamen, cEmpresa,pRegistros,pRecuperacion )
				INTO cCodRetSp, cMensaje, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes,iRegistros, iTermino
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisuc:sp_consultadatospiezas_bym3';
				ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00003';
					RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
				ELIF cCodRetSp::INTEGER = 2 AND pRegistros = 0  THEN		
					LET cCodRet = '00017';
					RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
				ELIF cCodRetSp::INTEGER = 2 AND pRegistros > 0 THEN		
					LET cCodRet = '1001';
					RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
				END IF;
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes WITH RESUME;           
	
			END FOREACH;
		
		END IF;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 15/12/2016',
'MODULO: CAJA GENERAL ',
'FUNCIONALIDAD: BILLETES PRESUNTAMENTE FALSOS EN SUCURSAL',
'DESCRIPCION:SPL Intermedio que obtiene informacion para llenado de grid',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 07/04/2016',
'MODIFICACION: Se agrega validación para la recuperación de registros a retornar.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consulta_sac_reportediario( pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha_inicial DATE,pFecha_final DATE,pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,DATE AS FechaProceso, INTEGER AS num_mesesvent, MONEY(16,2) AS importe_vent, 
	INTEGER AS num_mesesdomi,MONEY(16,2) AS Importe_domi, INTEGER AS num_meses,MONEY(16,2) AS importe_total,MONEY(16,2) AS comision,
	MONEY(16,2) AS iva,MONEY(16,2) AS importe_pago_coppel;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotales INTEGER;
	DEFINE dFechaProceso DATE;
	DEFINE iNum_mesesvent INTEGER;
	DEFINE mImporte_vent MONEY(16,2);
	DEFINE iNum_mesesdomi INTEGER;
	DEFINE mImporte_domi MONEY(16,2);
	DEFINE iNum_meses INTEGER;
	DEFINE mImporte_total MONEY(16,2);
	DEFINE mComision MONEY(16,2);
	DEFINE mIva MONEY(16,2);
	DEFINE mImporte_pago_coppel MONEY(16,2);
    DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotales = 0;
	LET dFechaProceso=DATE(1);
	LET iNum_mesesvent =0;
	LET mImporte_vent =0;
	LEt iNum_mesesdomi=0;
	LET mImporte_domi=0;
	LET iNum_meses=0;
	LET mImporte_total=0;
	LET mComision=0;
	LET mIva=0;
	LET mImporte_pago_coppel=0;
	LET iRecuperacion=0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,iNum_meses,mImporte_domi,mImporte_total,mComision,mIva,mImporte_pago_coppel;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_sac_reportediario.out';
		--TRACE ON;
		
		IF pUsuario = '' OR  pIdFuncion = '' OR pFecha_inicial = '' OR pFecha_final = ''THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

       FOREACH

		SELECT SKIP pRegistros FIRST pRecuperacion fecha_proceso,num_mesesvent,importe_vent ,num_mesesdomi,importe_domi,num_meses,importe_total,comision,iva,importe_pago_coppel
		INTO dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel
		FROM bdisac:sac_reportediario_seg  
     	WHERE fecha_proceso BETWEEN pFecha_inicial AND pFecha_final and reportesoc ='1'
      ORDER BY fecha_proceso ASC

       LET iRecuperacion = iRecuperacion + 1;
        
      RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel WITH RESUME;
       END FOREACH;

		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFechaProceso,iNum_mesesvent,mImporte_vent,iNum_mesesdomi,mImporte_domi,iNum_meses,mImporte_total,mComision,mIva,mImporte_pago_coppel;
		END IF;	
		

	END;		

END PROCEDURE;