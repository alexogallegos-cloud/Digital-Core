CREATE PROCEDURE "informix".sp_consultadatospiezas_bym(pFechaCaptura DATE, pFechaIni DATE, pFechaFin DATE, pSucursal CHAR(4), pNumRecibo CHAR(10), 
													   pNumGuia CHAR(12), pEstatus INTEGER, pDictamen INTEGER, pEmpresa CHAR(3), pRegistros INTEGER)
RETURNING  	CHAR(6) 	AS CodRet,
			CHAR(80) 	AS Mensaje,
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
			CHAR(30)    AS EstadoDesc,
			INTEGER     AS Registros,
			INTEGER     AS Termino;
			
-- ****************************************************************************
-- Declarar variables
-- ****************************************************************************
DEFINE iSql_err              INTEGER;
DEFINE iSamErr               INTEGER;
DEFINE cDesErr               CHAR(80);
DEFINE cCodRet               CHAR(6);
DEFINE cMensaje              CHAR(80);
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
DEFINE iLimit                INTEGER;
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
-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
LET iSql_err                = 0;
LET iSamErr                 = 0;
LET cDesErr                 = '';
LET cCodRet                 = '000000';
LET cMensaje                = '';
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
LET iLimit                  = 10;
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
SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

 --SET DEBUG FILE TO "/respaldosbd/felipe/sp_consultadatospiezas_bym.out";
 --TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err, iSamErr, cDesErr
		IF iSql_err <> 0 THEN
			LET cCodRet = CAST(iSql_err AS CHAR(6));
			LET cMensaje = cDesErr;
			RETURN cCodRet, cMensaje, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes, iRegistros, iTermino WITH RESUME;
		END IF;
	END EXCEPTION;
	
	IF TRIM(NVL(pEmpresa,'')) <> '' THEN
		
		IF NVL(pFechaCaptura,DATE(1)) <> DATE(1) THEN
			LET dFechaInicio = pFechaCaptura;
			LET dFechaFin = pFechaCaptura;
			LET iBandFecha = 1;
		ELIF NVL(pFechaIni,DATE(1)) <> DATE(1) AND NVL(pFechaFin,DATE(1)) <> DATE(1) THEN
			LET dFechaInicio = pFechaIni;
			LET dFechaFin = pFechaFin;
			LET iBandFecha = 1;
		END IF;
			
		IF iBandFecha = 1 OR TRIM(NVL(pSucursal,'')) <> '' OR TRIM(NVL(pNumRecibo,'')) <> '' OR TRIM(NVL(pNumGuia,'')) <> '' OR NVL(pEstatus,0) > 0 OR NVL(pDictamen,0) > 0 THEN
			
			
			IF iBandFecha = 1 THEN
			
				SELECT {+INDEX (bdisuc:"informix".ss_piezas_bym_falsos idx_PiezasEstatus)}
					COUNT(Recibo.num_recibo)
				INTO
					iContador
				FROM
					bdisuc:"informix".ss_tenedor_pieza AS Tenedor INNER JOIN
					bdisuc:"informix".ss_recibo_bym_falsos AS Recibo ON
					Tenedor.id_tenedor = Recibo.id_tenedor  INNER JOIN
					bdisuc:"informix".ss_piezas_bym_falsos AS Piezas ON
					Piezas.num_recibo = Recibo.num_recibo
				WHERE	
					Recibo.empresa_retiene = pEmpresa
				AND Recibo.fecha_insert >= dFechaInicio
				AND Recibo.fecha_insert <= dFechaFin
				AND Recibo.num_sucursal_retencion = CASE WHEN TRIM(NVL(pSucursal,'')) <> '' THEN pSucursal ELSE Recibo.num_sucursal_retencion END
				AND Recibo.num_recibo = CASE WHEN TRIM(NVL(pNumRecibo,'')) <> '' THEN pNumRecibo ELSE Recibo.num_recibo END
				AND NVL(Piezas.num_guia,'') = CASE WHEN TRIM(NVL(pNumGuia,'')) <> '' THEN  pNumGuia ELSE NVL(Piezas.num_guia,'') END
				AND Piezas.estatus = CASE WHEN NVL(pEstatus,0) > 0 THEN pEstatus ELSE Piezas.estatus END
				AND NVL(Piezas.dictamen_banxico,0) =  CASE WHEN NVL(pDictamen,0) > 0 THEN pDictamen ELSE NVL(Piezas.dictamen_banxico,0) END;			
				
				FOREACH
					SELECT {+INDEX (bdisuc:"informix".ss_piezas_bym_falsos idx_PiezasEstatus)} SKIP pRegistros LIMIT iLimit
						Recibo.num_recibo, Recibo.id_tenedor, Recibo.num_sucursal_retencion, Tenedor.nombre_1, Tenedor.nombre_2, Tenedor.ap_paterno, Tenedor.ap_materno, Tenedor.calle,
						Tenedor.numero_calle, Tenedor.colonia, Tenedor.delegacion_poblacion, Tenedor.cod_postal, Tenedor.ciudad, Tenedor.estado, Tenedor.telefono, Tenedor.email, 
						Tenedor.ejecutivo_insert, Tenedor.identificacion, Tenedor.num_identificacion, Piezas.id_pieza, Piezas.fecha_recepcion, Piezas.id_denominacion, Piezas.serie,
						Piezas.folio, Piezas.fecha_emision, Piezas.num_piezas, Piezas.nota, Piezas.folio_banxico, Piezas.dictamen_banxico, Piezas.num_lote_banxico, Piezas.fecha_pago,
						Piezas.tipo_pago, Piezas.num_cta_cliente, Piezas.estatus, Recibo.fecha_insert
					INTO
						cNumReciboCon, iIdTenedor, cNumSucursalReten, cNombre1, cNombre2, cApPaterno, cApMaterno, cCalleCon, 
						cNumeroCalle, cColoniaCon, cDelegacionPoblacion, cCodPostalCon, cCiudadCon, cEstadoCon, cTelefonoCon, cEmailCon, 
						cEjecutivoInsert, cIdentificacionCon, cNumIdentificacionCon, cIdPieza, dFechaRecepcion, iIdDenominacion, cSerieCon, 
						cFolioCon, dFechaEmisionCon, iNumPiezasCon, cNotaCon, cFolioBanxicoCon, iDictamenBanxico, cNumLoteBanxicoCon, dFechaPagoCon,
						iTipoPago, cNumCtaCliente, iEstatus, dFechaInsert
					FROM
						bdisuc:"informix".ss_tenedor_pieza AS Tenedor INNER JOIN
						bdisuc:"informix".ss_recibo_bym_falsos AS Recibo ON
						Tenedor.id_tenedor = Recibo.id_tenedor  INNER JOIN
						bdisuc:"informix".ss_piezas_bym_falsos AS Piezas ON
						Piezas.num_recibo = Recibo.num_recibo
					WHERE	
						Recibo.empresa_retiene = pEmpresa
					AND Recibo.fecha_insert >= dFechaInicio
					AND Recibo.fecha_insert <= dFechaFin
					AND Recibo.num_sucursal_retencion = CASE WHEN TRIM(NVL(pSucursal,'')) <> '' THEN pSucursal ELSE Recibo.num_sucursal_retencion END
					AND Recibo.num_recibo = CASE WHEN TRIM(NVL(pNumRecibo,'')) <> '' THEN pNumRecibo ELSE Recibo.num_recibo END
					AND NVL(Piezas.num_guia,'') = CASE WHEN TRIM(NVL(pNumGuia,'')) <> '' THEN  pNumGuia ELSE NVL(Piezas.num_guia,'') END
					AND Piezas.estatus = CASE WHEN NVL(pEstatus,0) > 0 THEN pEstatus ELSE Piezas.estatus END
					AND NVL(Piezas.dictamen_banxico,0) =  CASE WHEN NVL(pDictamen,0) > 0 THEN pDictamen ELSE NVL(Piezas.dictamen_banxico,0) END	
					ORDER BY Recibo.empresa_retiene, Recibo.num_sucursal_retencion, Recibo.num_recibo, Recibo.fecha_insert
					
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
						LET cPromotor               = '';
						LET cEstadoDesRes           = '';
						
						LET iBandInicio = 1;
					
						SELECT desc_tipo_pago
						INTO cDesTipoPago
						FROM  bdisuc:"informix".ss_cat_tipo_pago_bym_falsos
						WHERE id_tipo_pago = iTipoPago;
						
						SELECT desc_dictamen 
						INTO cDesDictamen
						FROM bdisuc:"informix".ss_cat_dictamen_bym_falsos
						WHERE empresa = pEmpresa 
						AND id_dictamen = iDictamenBanxico;
		
						SELECT descripcion
						INTO cIdentificacionDes
						FROM bdinteg:"informix".si_tipoidentifpm
						WHERE empresa = pEmpresa
						AND codigo = TRIM(NVL(cIdentificacionCon,''));
						
						SELECT nombre
						INTO cEstadoDes
						FROM bdinteg:"informix".si_estados
						WHERE estado = cEstadoCon;
						
						IF NVL(cCiudadCon,'') <> '' THEN
							LET cCiudadoDelegacion	= cCiudadCon;
						ELIF NVL(cDelegacionPoblacion,'') <> '' THEN
							LET cCiudadoDelegacion	= cDelegacionPoblacion;
						END IF;
						
						IF NVL(cCiudadoDelegacion,'') <>'' THEN
						
							SELECT nombre, ciudad_coppel
							INTO cNombreCidDel,cCiudadoCoppel
							FROM bdinteg:"informix".si_ciudades 
							WHERE estado = cEstadoCon 
							AND ciudad = CAST(NVL(cCiudadoDelegacion,'') AS INTEGER);
							
							IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
								SELECT nombrezona
								INTO cNombreCol						
								FROM bdinteg:"informix".si_catzonas 
								WHERE  numerocolonia = NVL(cColoniaCon,'')
								AND  numerociudad = NVL(cCiudadoCoppel,'');
							END IF;
						END IF;
							
						SELECT nombrecalle
						INTO cNombreCalle
						FROM bdinteg:"informix".si_catcalles
						WHERE numerocalle = NVL(cCalleCon,'');		

						SELECT nombre, direccion1 
						INTO cNombreScucursal, cDireccion1
						FROM bdinteg:"informix".si_sucursales
						WHERE sucursal = TRIM(cNumSucursalReten);
						
						IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
						
							SELECT nombre
							INTO cNombreOperador
							FROM bdinteg:"informix".si_ejecut
							WHERE empresa = pEmpresa
							AND ejecutivo = cEjecutivoInsert;
						
							IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
							
								SELECT clave_pieza, denominacion
								INTO cDesCvePieza, cDenominacionCon
								FROM bdisuc:"informix".ss_denominacion_bym_falsos
								WHERE empresa = pEmpresa
								AND	id_denominacion = iIdDenominacion;

								IF dbinfo("sqlca.sqlerrd2") = 1 THEN 

									SELECT desc_estatus 
									INTO cDesEstatus
									FROM  bdisuc:"informix".ss_cat_estatus_bym_falsos 
									WHERE empresa = pEmpresa
									AND id_estatus = iEstatus;
										
									IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
										LET iBandRegistros = 1;
										LET iRegCon = iRegCon +1;
										LET iRegistros = pRegistros + iRegCon;
												
										IF iRegistros = iContador THEN
											LET iTermino = 1;
										END IF;
										
										IF NVL(cCiudadCon,'') <> '' THEN
											LET cNombreCiudad	= cNombreCidDel;
											LET cNombreDelegacion = '';
										ELIF NVL(cDelegacionPoblacion,'') <> '' THEN
											LET cNombreDelegacion	= cNombreCidDel;
											LET cNombreCiudad	= '';
										END IF;
															
										LET cMensaje            = 'EjecuciÃ³n Exitosa.'; 
										LET iCvePieza           = NVL(cIdPieza,'');
										LET dFechaCaptura       = NVL(dFechaInsert,DATE(1));
										LET cNumRecibo          = NVL(cNumReciboCon,'');
										LET iNumPiezas          = NVL(iNumPiezasCon,0);
										LET cTipoPieza          = NVL(cDesCvePieza,'');
										LET cDenominacion       = NVL(cDenominacionCon,'');
										LET iCveDenominacion    = NVL(iIdDenominacion,0);
										LET cSerie              = NVL(cSerieCon,'');
										LET cFolio              = NVL(cFolioCon,'');
										LET dFechaEmision       = NVL(dFechaEmisionCon,DATE(1));  
										LET cNota               = NVL(cNotaCon,'');
										LET cEstatus            = NVL(cDesEstatus,'');
										LET cDictamenBanxico    = NVL(cDesDictamen,'');
										LET cNumLoteBanxico     = NVL(cNumLoteBanxicoCon,'');
										LET cFolioBanxico       = NVL(cFolioBanxicoCon,'');
										LET dFechaPago          = NVL(dFechaPagoCon,DATE(1));
										LET cFormaPago          = NVL(cDesTipoPago,'');   
										LET cNumCta             = NVL(cNumCtaCliente,'');
										LET cNumSuc             = NVL(cNumSucursalReten,'');
										LET cNombreSuc          = NVL(cNombreScucursal,'');
										LET cDomSuc             = NVL(cDireccion1,'');
										LET cNomOperador        = NVL(cNombreOperador,'');
										LET cApellidoTenedor1   = NVL(cApPaterno,'');
										LET cApellidoTenedor2   = NVL(cApMaterno,'');
										LET cNomTenedor1        = NVL(cNombre1,'');
										LET cNomTenedor2        = NVL(cNombre2,'');
										LET cIdentificacion     = NVL(cIdentificacionDes,''); 
										LET cNumIdentificacion  = NVL(cNumIdentificacionCon,'');
										LET cCalle              = NVL(cNombreCalle,'');
										LET cNumCasa            = NVL(cNumeroCalle,'');
										LET cColonia            = NVL(cNombreCol,'');
										LET cDelegacion         = NVL(cNombreDelegacion,'');
										LET cCodPostal          = NVL(cCodPostalCon,'');
										LET cCiudad             = NVL(cNombreCiudad,'');
										LET cEstado             = NVL(cEstadoCon,'');
										LET cTelefono           = NVL(cTelefonoCon,'');
										LET cEmail              = NVL(cEmailCon,'');
										LET cPromotor           = NVL(cEjecutivoInsert,'');
										LET cEstadoDesRes       = NVL(cEstadoDes,''); 

                                        SELECT edo_banxico INTO cEstadoBanxico from  bdisuc:ss_edos_banxico where edo_bancoppel = cEstado;
                                        LET cEstado = cEstadoBanxico;
										RETURN cCodRet, cMensaje, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes, iRegistros, iTermino WITH RESUME;
									ELSE
										LET cCodRet = '000002';
										EXIT FOREACH;
									END IF;
								ELSE
									LET cCodRet = '000002';
									EXIT FOREACH;
								END IF;
							ELSE
								LET cCodRet = '000002';
								EXIT FOREACH;
							END IF;
						ELSE
							LET cCodRet = '000002';
							EXIT FOREACH;
						END IF;
				END FOREACH;
			
			ELIF iBandFecha = 0 THEN
				
				SELECT {+INDEX (bdisuc:"informix".ss_piezas_bym_falsos idx_PiezasEstatus)}
					COUNT(Recibo.num_recibo)
				INTO
					iContador
				FROM
					bdisuc:"informix".ss_tenedor_pieza AS Tenedor INNER JOIN
					bdisuc:"informix".ss_recibo_bym_falsos AS Recibo ON
					Tenedor.id_tenedor = Recibo.id_tenedor  INNER JOIN
					bdisuc:"informix".ss_piezas_bym_falsos AS Piezas ON
					Piezas.num_recibo = Recibo.num_recibo
				WHERE	
					Recibo.empresa_retiene = pEmpresa
				AND Recibo.num_sucursal_retencion = CASE WHEN TRIM(NVL(pSucursal,'')) <> '' THEN pSucursal ELSE Recibo.num_sucursal_retencion END
				AND Recibo.num_recibo = CASE WHEN TRIM(NVL(pNumRecibo,'')) <> '' THEN pNumRecibo ELSE Recibo.num_recibo END
				AND NVL(Piezas.num_guia,'') = CASE WHEN TRIM(NVL(pNumGuia,'')) <> '' THEN  pNumGuia ELSE NVL(Piezas.num_guia,'') END
				AND Piezas.estatus = CASE WHEN NVL(pEstatus,0) > 0 THEN pEstatus ELSE Piezas.estatus END
				AND NVL(Piezas.dictamen_banxico,0) =  CASE WHEN NVL(pDictamen,0) > 0 THEN pDictamen ELSE NVL(Piezas.dictamen_banxico,0) END;
			
				FOREACH
					SELECT {+INDEX (bdisuc:"informix".ss_piezas_bym_falsos idx_PiezasEstatus)} SKIP pRegistros LIMIT iLimit
						Recibo.num_recibo, Recibo.id_tenedor, Recibo.num_sucursal_retencion, Tenedor.nombre_1, Tenedor.nombre_2, Tenedor.ap_paterno, Tenedor.ap_materno, Tenedor.calle,
						Tenedor.numero_calle, Tenedor.colonia, Tenedor.delegacion_poblacion, Tenedor.cod_postal, Tenedor.ciudad, Tenedor.estado, Tenedor.telefono, Tenedor.email, 
						Tenedor.ejecutivo_insert, Tenedor.identificacion, Tenedor.num_identificacion, Piezas.id_pieza, Piezas.fecha_recepcion, Piezas.id_denominacion, Piezas.serie,
						Piezas.folio, Piezas.fecha_emision, Piezas.num_piezas, Piezas.nota, Piezas.folio_banxico, Piezas.dictamen_banxico, Piezas.num_lote_banxico, Piezas.fecha_pago,
						Piezas.tipo_pago, Piezas.num_cta_cliente, Piezas.estatus, Recibo.fecha_insert
					INTO
						cNumReciboCon, iIdTenedor, cNumSucursalReten, cNombre1, cNombre2, cApPaterno, cApMaterno, cCalleCon, 
						cNumeroCalle, cColoniaCon, cDelegacionPoblacion, cCodPostalCon, cCiudadCon, cEstadoCon, cTelefonoCon, cEmailCon, 
						cEjecutivoInsert, cIdentificacionCon, cNumIdentificacionCon, cIdPieza, dFechaRecepcion, iIdDenominacion, cSerieCon, 
						cFolioCon, dFechaEmisionCon, iNumPiezasCon, cNotaCon, cFolioBanxicoCon, iDictamenBanxico, cNumLoteBanxicoCon, dFechaPagoCon,
						iTipoPago, cNumCtaCliente, iEstatus, dFechaInsert
					FROM
						bdisuc:"informix".ss_tenedor_pieza AS Tenedor INNER JOIN
						bdisuc:"informix".ss_recibo_bym_falsos AS Recibo ON
						Tenedor.id_tenedor = Recibo.id_tenedor  INNER JOIN
						bdisuc:"informix".ss_piezas_bym_falsos AS Piezas ON
						Piezas.num_recibo = Recibo.num_recibo
					WHERE	
						Recibo.empresa_retiene = pEmpresa
					AND Recibo.num_sucursal_retencion = CASE WHEN TRIM(NVL(pSucursal,'')) <> '' THEN pSucursal ELSE Recibo.num_sucursal_retencion END
					AND Recibo.num_recibo = CASE WHEN TRIM(NVL(pNumRecibo,'')) <> '' THEN pNumRecibo ELSE Recibo.num_recibo END
					AND NVL(Piezas.num_guia,'') = CASE WHEN TRIM(NVL(pNumGuia,'')) <> '' THEN  pNumGuia ELSE NVL(Piezas.num_guia,'') END
					AND Piezas.estatus = CASE WHEN NVL(pEstatus,0) > 0 THEN pEstatus ELSE Piezas.estatus END
					AND NVL(Piezas.dictamen_banxico,0) =  CASE WHEN NVL(pDictamen,0) > 0 THEN pDictamen ELSE NVL(Piezas.dictamen_banxico,0) END
					ORDER BY Recibo.empresa_retiene, Recibo.num_sucursal_retencion, Recibo.num_recibo, Recibo.fecha_insert
					
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
						LET cPromotor               = '';
						LET cEstadoDesRes           = '';
						
						LET iBandInicio = 1;
						
						SELECT desc_tipo_pago
						INTO cDesTipoPago
						FROM  bdisuc:"informix".ss_cat_tipo_pago_bym_falsos
						WHERE id_tipo_pago = iTipoPago;
						
						SELECT desc_dictamen 
						INTO cDesDictamen
						FROM bdisuc:"informix".ss_cat_dictamen_bym_falsos
						WHERE empresa = pEmpresa 
						AND id_dictamen = iDictamenBanxico;
						
						SELECT descripcion
						INTO cIdentificacionDes
						FROM bdinteg:"informix".si_tipoidentifpm
						WHERE empresa = pEmpresa
						AND codigo = TRIM(NVL(cIdentificacionCon,''));
						
						SELECT nombre
						INTO cEstadoDes
						FROM bdinteg:"informix".si_estados
						WHERE estado = cEstadoCon;
						
						IF NVL(cCiudadCon,'') <> '' THEN
							LET cCiudadoDelegacion	= cCiudadCon;
						ELIF NVL(cDelegacionPoblacion,'') <> '' THEN
							LET cCiudadoDelegacion	= cDelegacionPoblacion;
						END IF;
						
						IF NVL(cCiudadoDelegacion,'') <>'' THEN
						
							SELECT nombre, ciudad_coppel
							INTO cNombreCidDel,cCiudadoCoppel
							FROM bdinteg:"informix".si_ciudades 
							WHERE estado = cEstadoCon 
							AND ciudad = CAST(NVL(cCiudadoDelegacion,'') AS INTEGER);
							
							IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
								SELECT nombrezona
								INTO cNombreCol						
								FROM bdinteg:"informix".si_catzonas 
								WHERE  numerocolonia = NVL(cColoniaCon,'')
								AND  numerociudad = NVL(cCiudadoCoppel,'');
							END IF;
						END IF;
						
						SELECT nombrecalle
						INTO cNombreCalle
						FROM bdinteg:"informix".si_catcalles
						WHERE numerocalle = NVL(cCalleCon,'');		
						
						SELECT nombre, direccion1 
						INTO cNombreScucursal, cDireccion1
						FROM bdinteg:"informix".si_sucursales
						WHERE sucursal = TRIM(cNumSucursalReten);
						
						IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
						
							SELECT nombre
							INTO cNombreOperador
							FROM bdinteg:"informix".si_ejecut
							WHERE empresa = pEmpresa
							AND ejecutivo = cEjecutivoInsert;
						
							IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
							
								SELECT clave_pieza, denominacion
								INTO cDesCvePieza, cDenominacionCon
								FROM bdisuc:"informix".ss_denominacion_bym_falsos
								WHERE empresa = pEmpresa 
								AND id_denominacion = iIdDenominacion;

								IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
								
									SELECT desc_estatus 
									INTO cDesEstatus
									FROM  bdisuc:"informix".ss_cat_estatus_bym_falsos 
									WHERE empresa = pEmpresa 
									AND id_estatus = iEstatus;
											
									IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
										LET iBandRegistros = 1;
										LET iRegCon = iRegCon +1;
										LET iRegistros = pRegistros + iRegCon;
										
										IF iRegistros = iContador THEN
											LET iTermino = 1;
										END IF;
										
										IF NVL(cCiudadCon,'') <> '' THEN
											LET cNombreCiudad	= cNombreCidDel;
											LET cNombreDelegacion = '';
										ELIF NVL(cDelegacionPoblacion,'') <> '' THEN
											LET cNombreDelegacion	= cNombreCidDel;
											LET cNombreCiudad	= '';
										END IF;
															
										LET cMensaje            = 'EjecuciÃ³n Exitosa.'; 
										LET iCvePieza           = NVL(cIdPieza,'');
										LET dFechaCaptura       = NVL(dFechaInsert,DATE(1));
										LET cNumRecibo          = NVL(cNumReciboCon,'');
										LET iNumPiezas          = NVL(iNumPiezasCon,0);
										LET cTipoPieza          = NVL(cDesCvePieza,'');
										LET cDenominacion       = NVL(cDenominacionCon,'');
										LET iCveDenominacion    = NVL(iIdDenominacion,0);
										LET cSerie              = NVL(cSerieCon,'');
										LET cFolio              = NVL(cFolioCon,'');
										LET dFechaEmision       = NVL(dFechaEmisionCon,DATE(1));  
										LET cNota               = NVL(cNotaCon,'');
										LET cEstatus            = NVL(cDesEstatus,'');
										LET cDictamenBanxico    = NVL(cDesDictamen,'');
										LET cNumLoteBanxico     = NVL(cNumLoteBanxicoCon,'');
										LET cFolioBanxico       = NVL(cFolioBanxicoCon,'');
										LET dFechaPago          = NVL(dFechaPagoCon,DATE(1));
										LET cFormaPago          = NVL(cDesTipoPago,'');   
										LET cNumCta             = NVL(cNumCtaCliente,'');
										LET cNumSuc             = NVL(cNumSucursalReten,'');
										LET cNombreSuc          = NVL(cNombreScucursal,'');
										LET cDomSuc             = NVL(cDireccion1,'');
										LET cNomOperador        = NVL(cNombreOperador,'');
										LET cApellidoTenedor1   = NVL(cApPaterno,'');
										LET cApellidoTenedor2   = NVL(cApMaterno,'');
										LET cNomTenedor1        = NVL(cNombre1,'');
										LET cNomTenedor2        = NVL(cNombre2,'');
										LET cIdentificacion     = NVL(cIdentificacionDes,''); 
										LET cNumIdentificacion  = NVL(cNumIdentificacionCon,'');
										LET cCalle              = NVL(cNombreCalle,'');
										LET cNumCasa            = NVL(cNumeroCalle,'');
										LET cColonia            = NVL(cNombreCol,'');
										LET cDelegacion         = NVL(cNombreDelegacion,'');
										LET cCodPostal          = NVL(cCodPostalCon,'');
										LET cCiudad             = NVL(cNombreCiudad,'');
										LET cEstado             = NVL(cEstadoCon,'');
										LET cTelefono           = NVL(cTelefonoCon,'');
										LET cEmail              = NVL(cEmailCon,'');
										LET cPromotor           = NVL(cEjecutivoInsert,'');
										LET cEstadoDesRes       = NVL(cEstadoDes,''); 
										SELECT edo_banxico INTO cEstadoBanxico from  bdisuc:ss_edos_banxico where edo_bancoppel = cEstado;
                                        LET cEstado = cEstadoBanxico;		
										RETURN cCodRet, cMensaje, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes, iRegistros, iTermino WITH RESUME;
									ELSE
										LET cCodRet = '000002';
										EXIT FOREACH;
									END IF;
								ELSE
									LET cCodRet = '000002';
									EXIT FOREACH;
								END IF;
							ELSE
								LET cCodRet = '000002';
								EXIT FOREACH;
							END IF;
						ELSE
							LET cCodRet = '000002';
							EXIT FOREACH;
						END IF;
				END FOREACH;
				
			END IF;
		ELSE
			LET cCodRet = '000001';
		END IF;
		
	ELSE
		LET cCodRet = '000001';
	END IF;

	IF cCodRet <> '000000' THEN
		IF cCodRet = '000001' THEN
			LET cMensaje = 'ParÃ¡metros de Entrada VacÃ­os';
		ELIF cCodRet = '000002' THEN
			LET cCodigo = '256';
		END IF;
		LET iRegistros = pRegistros + (iRegCon + 1);
		
		IF iRegistros >= NVL(iContador,0) AND NVL(iContador,0) > 0  THEN
			LET iTermino = 1;
		ELIF iRegistros >= NVL(iContador,0) AND NVL(iContador,0) = 0  THEN
			LET iTermino = 2;
		END IF;
		
		IF cCodRet = '000002' THEN
			SELECT descripcion INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '11' AND codigo_retorno = cCodigo;
		END IF;
		
        SELECT edo_banxico INTO cEstadoBanxico from  bdisuc:ss_edos_banxico where edo_bancoppel = cEstado; 
        LET cEstado = cEstadoBanxico;
		RETURN cCodRet, cMensaje, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes, iRegistros, iTermino WITH RESUME;
		
	ELSE
		IF iBandInicio = 0 OR iBandRegistros = 0 THEN
			LET cCodRet = '000002';
			LET cCodigo = '256';
			LET iRegistros = pRegistros + (iRegCon + 1);
			
			IF iRegistros >= NVL(iContador,0) AND NVL(iContador,0) > 0  THEN
				LET iTermino = 1;
			ELIF iRegistros >= NVL(iContador,0) AND NVL(iContador,0) = 0  THEN
				LET iTermino = 2;
			END IF;
			
			SELECT descripcion INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '11' AND codigo_retorno = cCodigo;
			SELECT edo_banxico INTO cEstadoBanxico from  bdisuc:ss_edos_banxico where edo_bancoppel = cEstado;
            LET cEstado = cEstadoBanxico;
            RETURN cCodRet, cMensaje, iCvePieza, dFechaCaptura, cNumRecibo, iNumPiezas, cTipoPieza, cDenominacion, iCveDenominacion, cSerie, cFolio, dFechaEmision, cNota, cEstatus, cDictamenBanxico, cNumLoteBanxico, cFolioBanxico, dFechaPago, cFormaPago, cNumCta, cNumSuc, cNombreSuc, cDomSuc, cNomOperador, cApellidoTenedor1, cApellidoTenedor2, cNomTenedor1, cNomTenedor2,cIdentificacion, cNumIdentificacion, cCalle, cNumCasa, cColonia, cDelegacion, cCodPostal, cCiudad, cEstado, cTelefono, cEmail, cPromotor, cEstadoDesRes, iRegistros, iTermino WITH RESUME;
			
		END IF;
	END IF;
END;    
END PROCEDURE
DOCUMENT
'REALIZO: Felipe Urias',
'FECHA: 20/04/2015',
'DESCRIPCION: cunsulta multiples registros dependiendo de su entrada de datos para el filtrado.',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_atms(pempresa   CHAR(3),
                                    psucursal  CHAR(4),
                                    pregistro  SMALLINT)

RETURNING CHAR(5),CHAR(4),CHAR(100);

DEFINE vcodret          CHAR(5);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vnumatm          CHAR(4);
DEFINE vnombreatm       CHAR(100);
 
LET vcodret    = "000";
LET vnumatm    = "";
LET vnombreatm = "";

SET LOCK MODE TO WAIT 5;
SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,vnumatm,vnombreatm;
   END IF;
END EXCEPTION;

--SET debug file to "/tmp/sp_atms.out";
--trace on;

    IF pempresa = '0' or pempresa = '' or  psucursal = '0' or psucursal = '' then
          LET vcodret = "110";
    END IF;

    FOREACH
        SELECT s.sucursal,s.nombre
        INTO vnumatm, vnombreatm
        FROM bdisuc:"informix".ss_atms_sucursal a, bdinteg:"informix".si_sucursales s
        WHERE s.sucursal = a.cod_atm  
          AND s.empresa = pempresa
          /*AND a.sucursal = psucursal    */       
        ORDER BY s.nombre

        RETURN vCodRet,vnumatm,vnombreatm  WITH resume;

    END FOREACH;
END;
END PROCEDURE;