CREATE PROCEDURE "informix".sp_consultarpt_bym_web(pOpcion CHAR(1), pFechaIni DATE, pFechaFin DATE,pNumSucursal CHAR(4), pEmpresa CHAR(3),pEjecutivo CHAR(8),pRegistros SMALLINT)

	RETURNING
		CHAR(5) 	AS cCodRet,
		INTEGER		AS iNum_Piezas,
		CHAR(10)	AS cNumRecibo,
		CHAR(8) 	AS cNumUsuario,
		CHAR(45) 	AS cNombre,
		CHAR(10) 	AS cDenominacion,
		CHAR(40) 	AS cNumSerie,
		INTEGER		AS iCantidad,
		CHAR(160) 	AS cNombreCte,
		CHAR(40) 	AS cFolioBanxico,
		INTEGER 	AS iSumCantidad;

--DECLARACION DE VARIABLES
	DEFINE cCodRet 				CHAR(5);
	DEFINE cNumUsuario 			CHAR(8);
	DEFINE cNombre 				CHAR(100);
	DEFINE cDenominacion 		CHAR(10);
	DEFINE cNumSerie 			CHAR(40);
	DEFINE iCantidad 			INTEGER;
	DEFINE cNombreCte 			CHAR(160);
	DEFINE cFolioBanxico 		CHAR(40);
	DEFINE iSqlErr				INTEGER;
	DEFINE dtFechaHoy			DATE;
	DEFINE cNumRecibo			CHAR(10);
	DEFINE sContNumRecib    	SMALLINT;
	DEFINE iDenom 				INTEGER;
	DEFINE iNum_Piezas 			INTEGER;
	DEFINE cNumRecibo2 			CHAR(10);
	--Denomicacion
	DEFINE cDenominacion2  		CHAR(10);
	DEFINE iContDenom			SMALLINT;
	--id_tenedor
	DEFINE iTenedor				INTEGER;
	--nombre_completo
	DEFINE iSumCantidad 		INTEGER;
	DEFINE iOpcion1  			INTEGER;
	DEFINE iOpcion2  			INTEGER;
	DEFINE vDia 				CHAR(2);
	DEFINE vMes					CHAR(2);
	DEFINE vAnio 				CHAR(4);
	DEFINE vFechaFinal 			CHAR(10);
	DEFINE vFechaInicial  		CHAR(10);

--INICIALIZACION DE VARIABLES
	LET cNombre 				= '';
	LET cNumUsuario 			= '';
	LET cCodRet 				= '00000';
	LET cDenominacion 			= '';
	LET cNumSerie 				= '';
	LET vDia 					= '';
	LET vMes 					= '';
	LET vAnio 					= '';
	LET cNombreCte 				= '';
	LET cFolioBanxico 			= '';
	LET iCantidad 				= 0 ;
	LET cNumRecibo 				= '';
	LET dtFechaHoy 				= '';
	LET sContNumRecib 			= 0;
	LET iSqlErr 				= 0;
	LET iDenom 					= 0;
	LET iNum_Piezas 			= 0;
	LET cNumRecibo2				='';
	LET iContDenom 				= 0;
	LET iTenedor 				= 0;
	LET cDenominacion2 			= 0;
	LET iSumCantidad 			= 0;
	LET iOpcion1 				= 0;
	LET iOpcion2 				= 0;
	LET vFechaFinal             ='';
	LET vFechaInicial           ='';
	--Codigo de Retorno
	--000000 = Ejecucion Exitosa
	--000001 = Parametros de Entrada Vacios
	--000002 = No se encontraron registros


	-----------------------------------------------------------------------
	---SET DEBUG FILE TO "/informix/sp_consultarpt_bym_web.out";
    ---TRACE ON;
	-----------------------------------------------------------------------
	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;

				RETURN NVL(cCodRet,''),iNum_Piezas, NVL(cNumRecibo,''),NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion,''), NVL(cNumSerie,''), NVL(iCantidad,0),
				NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0);
			END IF;
		END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

		SELECT fecha_hoy INTO dtFechaHoy FROM bdinteg: "informix".si_fechas WHERE empresa = pEmpresa;


		LET vDia = LPAD(day(pFechaIni),2,'0');
		LET vMes = LPAD(MONTH(pFechaIni),2,'0');
		LET vAnio = YEAR(pFechaIni);
		LET vFechaInicial = LPAD(vMes,2,'0')||'-'||LPAD(vDia,2,'0')||'-'|| vAnio;
		LET vDia = LPAD(day(pFechaFin),2,'0');
		LET vMes = LPAD(MONTH(pFechaFin),2,'0');
		LET vAnio = YEAR(pFechaFin);
		LET vFechaFinal = LPAD(vMes,2,'0')||'-'||LPAD(vDia,2,'0')||'-'|| vAnio;

		--LOS PARAMETROS NO DEBEN SER NULOS
		IF TRIM(NVL(pOpcion,''))=''THEN
			LET cCodRet = '00001';
			RETURN NVL(cCodRet,''),iNum_Piezas,NVL(cNumRecibo,''), NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion,''), NVL(cNumSerie,''), NVL(iCantidad,0),
			NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0);
		END IF;

		--OPCION 1 REPORTE DIARIO
		--TODO LOS USUARIOS
		LET pEjecutivo = TRIM(pEjecutivo);
		IF pEjecutivo = '' AND pOpcion = '1' THEN

			IF(SELECT COUNT(*) FROM "informix".ss_recibo_bym_falsos  WHERE num_sucursal_retencion = pNumSucursal
				AND empresa_retiene = pEmpresa AND fecha_insert = dtFechaHoy ) > 0 THEN--6
				LET iOpcion1 = 1;
			ELSE
				LET cCodRet = '00002';
				LET cNumRecibo = '1';
				RETURN NVL(cCodRet,''),iNum_Piezas, nVL(cNumRecibo,''),NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion,''), NVL(cNumSerie,''),
							NVL(iCantidad,0), NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0);
			END IF;
		--UN SOLO USUARIO
		ELIF pEjecutivo <> ''  AND pOpcion = '1' THEN

			IF(SELECT COUNT(*) FROM "informix".ss_recibo_bym_falsos  WHERE num_sucursal_retencion = pNumSucursal
				AND empresa_retiene = pEmpresa AND fecha_insert = dtFechaHoy AND ejecutivo_insert = pEjecutivo) > 0 THEN
				LET iOpcion1 = 1;
			ELSE
				LET cCodRet = '00002';
				LET cNumRecibo = '2';
				RETURN NVL(cCodRet,''),iNum_Piezas,NVL(cNumRecibo,''), NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion,''), NVL(cNumSerie,''), NVL(iCantidad,0),
				NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0);
			END IF;
		--OPCION 2 REPORTE HISTORICO
		ELIF pOpcion = '2'  THEN
			IF TRIM(NVL(pFechaIni,''))='' OR TRIM(NVL(pFechaFin,''))='' THEN
				LET cCodRet = '00001';
				RETURN NVL(cCodRet,''),iNum_Piezas,NVL(cNumRecibo,''), NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion,''), NVL(cNumSerie,''), NVL(iCantidad,0),
				NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0);
			ELSE
				--TODO LOS USUARIOS
				IF  pEjecutivo = '' THEN

					IF(SELECT COUNT(*) FROM "informix".ss_recibo_bym_falsos  WHERE num_sucursal_retencion = pNumSucursal	AND empresa_retiene = pEmpresa AND fecha_insert BETWEEN vFechaInicial AND vFechafinal) > 0 THEN
						LET iOpcion2 = 1;
					ELSE
						LET cCodRet = '00002';
						LET cNumRecibo = '3';
						RETURN NVL(cCodRet,''),iNum_Piezas,NVL(cNumRecibo,''),NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion,''), NVL(cNumSerie,''),
								NVL(iCantidad,0), NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0);
					END IF;
				--UN SOLO USUARIO
				ELIF pEjecutivo <> '' THEN
					IF(SELECT COUNT(*) FROM "informix".ss_recibo_bym_falsos  WHERE num_sucursal_retencion = pNumSucursal	AND empresa_retiene = pEmpresa AND fecha_insert BETWEEN pFechaIni AND pFechaFin
					AND ejecutivo_insert = pEjecutivo) > 0 THEN
						LET iOpcion2 = 1;
					ELSE
						LET cCodRet = '00002';
						LET cNumRecibo = '4';
						RETURN NVL(cCodRet,''),iNum_Piezas,NVL(cNumRecibo,''),NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion,''), NVL(cNumSerie,''),
								NVL(iCantidad,0), NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0);
					END IF;
				END IF;
			END IF;
		END IF;

		IF iOpcion1 = 1 THEN
			FOREACH
				SELECT FIRST 10 TRIM(NVL(num_recibo,'')) INTO cNumRecibo
				FROM "informix".ss_recibo_bym_falsos
				WHERE num_sucursal_retencion = pNumSucursal
				AND empresa_retiene = pEmpresa
				AND ejecutivo_insert = DECODE(pEjecutivo,'',ejecutivo_insert,pEjecutivo)
				AND fecha_insert = dtFechaHoy

				IF(SELECT COUNT(*) FROM "informix". ss_piezas_bym_falsos WHERE num_recibo = cNumRecibo) > 0 THEN
					FOREACH
						SELECT NVL(id_pieza,0),TRIM(NVL(ejecutivo_insert,'')), NVL(id_denominacion,0), TRIM(NVL(serie,'')), NVL(num_piezas,0),
							TRIM(NVL(num_recibo,'')), TRIM(NVL(folio_banxico,''))
						INTO iNum_Piezas,cNumUsuario,iDenom,cNumSerie,iCantidad,cNumRecibo2,cFolioBanxico
						FROM "informix". ss_piezas_bym_falsos
						WHERE num_recibo = cNumRecibo

						LET cDenominacion = CAST(iDenom AS CHAR(10));
						Let iSumCantidad = iSumCantidad + iCantidad;

						IF(SELECT COUNT(*) FROM "informix".ss_denominacion_bym_falsos WHERE id_denominacion = iDenom AND empresa=TRIM(NVL(pEmpresa,''))) > 0 THEN
							SELECT TRIM(NVL(denominacion,'')) INTO cDenominacion2 FROM "informix".ss_denominacion_bym_falsos
							WHERE id_denominacion = iDenom AND empresa=TRIM(NVL(pEmpresa,''));

							IF (SELECT COUNT(*) FROM "informix".ss_recibo_bym_falsos WHERE num_recibo = cNumRecibo2) >  0 THEN

								SELECT NVL(id_tenedor,0) INTO iTenedor  FROM "informix".ss_recibo_bym_falsos
								WHERE num_recibo = cNumRecibo;
								---
								IF(SELECT COUNT(*) FROM "informix".ss_tenedor_pieza  WHERE id_tenedor = iTenedor) > 0 THEN
									SELECT TRIM(NVL(nombre_1,"")) || " " || TRIM(NVL(nombre_2,"")) || " " || TRIM(NVL(ap_paterno,"")) || " " || TRIM(NVL(ap_materno,""))
									INTO cNombreCte
									FROM "informix".ss_tenedor_pieza
									WHERE id_tenedor = iTenedor;

									IF(SELECT COUNT(*) FROM bdinteg: "informix".si_ejecut WHERE ejecutivo = cNumUsuario) > 0 THEN
										SELECT nombre INTO cNOmbre FROM bdinteg: "informix".si_ejecut WHERE ejecutivo = cNumUsuario;
									ELSE
										LET sContNumRecib = 1;
									END IF;
								ELSE
									LET sContNumRecib = 1;
								END IF;
							ELSE
								LET sContNumRecib = 1;
							END IF;
						ELSE
							LET sContNumRecib = 1;
						END IF

						LET iContDenom = iContDenom + 1;

						IF iContDenom <= pRegistros THEN
							CONTINUE FOREACH;
						END IF;

						RETURN NVL(cCodRet,''), iNum_Piezas,NVL(cNumRecibo,''),NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion2,''), NVL(cNumSerie,''), NVL(iCantidad,0), NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0) WITH RESUME;

					END FOREACH

				ELSE
					LET sContNumRecib = 1;
				END IF;


				IF sContNumRecib = 1 THEN
					LET cCodRet = '00002';
					LET cNumRecibo = '5';
					RETURN NVL(cCodRet,''), iNum_Piezas,NVL(cNumRecibo,''),NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion,''), NVL(cNumSerie,''),
					NVL(iCantidad,0), NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0);
				END IF;
			END FOREACH

		ELIF iOpcion2 = 1 THEN
			FOREACH
				SELECT FIRST 10 TRIM(NVL(num_recibo,'')) INTO cNumRecibo
				FROM "informix".ss_recibo_bym_falsos
				WHERE num_sucursal_retencion = pNumSucursal
				AND fecha_insert >=vFechaInicial
				AND fecha_insert <=vFechafinal
				AND empresa_retiene = pEmpresa
				AND ejecutivo_insert = CASE WHEN TRIM(NVL(pEjecutivo,''))<>'' THEN TRIM(NVL(pEjecutivo,''))
										ELSE ejecutivo_insert END--DECODE(pEjecutivo,'',ejecutivo_insert,pEjecutivo)

				IF(SELECT COUNT(*) FROM "informix". ss_piezas_bym_falsos WHERE num_recibo = cNumRecibo) > 0 THEN
					FOREACH
						SELECT NVL(id_pieza,0),TRIM(NVL(ejecutivo_insert,'')), NVL(id_denominacion,0), TRIM(NVL(serie,'')), NVL(num_piezas,0),
							TRIM(NVL(num_recibo,'')), TRIM(NVL(folio_banxico,''))
						INTO iNum_Piezas,cNumUsuario,iDenom,cNumSerie,iCantidad,cNumRecibo2,cFolioBanxico
						FROM "informix". ss_piezas_bym_falsos
						WHERE num_recibo = cNumRecibo

						LET cDenominacion = CAST(iDenom AS CHAR(10));
						Let iSumCantidad = iSumCantidad + iCantidad;

						IF(SELECT COUNT(*) FROM "informix".ss_denominacion_bym_falsos WHERE id_denominacion = iDenom AND empresa=TRIM(NVL(pEmpresa,''))) > 0 THEN
							SELECT TRIM(NVL(denominacion,'')) INTO cDenominacion2 FROM "informix".ss_denominacion_bym_falsos
							WHERE id_denominacion = iDenom AND empresa=TRIM(NVL(pEmpresa,''));

							IF (SELECT COUNT(*) FROM "informix".ss_recibo_bym_falsos WHERE num_recibo = cNumRecibo2) >  0 THEN

								SELECT NVL(id_tenedor,0) INTO iTenedor  FROM "informix".ss_recibo_bym_falsos
								WHERE num_recibo = cNumRecibo;
								---
								IF(SELECT COUNT(*) FROM "informix".ss_tenedor_pieza  WHERE id_tenedor = iTenedor) > 0 THEN
									SELECT TRIM(NVL(nombre_1,"")) || " " || TRIM(NVL(nombre_2,"")) || " " || TRIM(NVL(ap_paterno,"")) || " " || TRIM(NVL(ap_materno,""))
									INTO cNombreCte
									FROM "informix".ss_tenedor_pieza
									WHERE id_tenedor = iTenedor;

									IF(SELECT COUNT(*) FROM bdinteg: "informix".si_ejecut WHERE ejecutivo = cNumUsuario) > 0 THEN
										SELECT nombre INTO cNOmbre FROM bdinteg: "informix".si_ejecut WHERE ejecutivo = cNumUsuario;
									ELSE
										LET sContNumRecib = 1;
									END IF;
								ELSE
									LET sContNumRecib = 1;
								END IF;
							ELSE
								LET sContNumRecib = 1;
							END IF;
						ELSE
							LET sContNumRecib = 1;
						END IF

						LET iContDenom = iContDenom + 1;

						IF iContDenom <= pRegistros THEN
							CONTINUE FOREACH;
						END IF;

						RETURN NVL(cCodRet,''),iNum_Piezas, NVL(cNumRecibo,''),NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion2,''), NVL(cNumSerie,''), NVL(iCantidad,0), NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0) WITH RESUME;

					END FOREACH

				ELSE
					LET sContNumRecib = 1;
				END IF;


				IF sContNumRecib = 1 THEN
					LET cCodRet = '00002';
					LET cNumRecibo = '6';
					RETURN NVL(cCodRet,''),iNum_Piezas,NVL(cNumRecibo,''),NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion,''), NVL(cNumSerie,''),
					NVL(iCantidad,0), NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0);
				END IF;

			END FOREACH
		END IF;
	END;
END PROCEDURE
DOCUMENT
'Fecha: 25/03/2015',
'Folio :1706',
'Proyecto: BilletesFalsosEnOFI',
'Descripcion: Se modifica el aplicativo de generepo para agregar el llamado de los reportes B23 Captura de billetes falsos diario y B24 captura de billetes falsos', 'historico. Ademas de modificar el reporte de la tira auditora para que se reflejen los movimientos de las transacciones 51 Pago de billete autentico en efectivo',
'y 52 Pago de billete autentico abono a cuenta.',
'Autor: 95358897-Isarai Bojorquez',
'Modifico: Leslie Rendon',
'Folio: 1725',
'Proyecto: OptBilletesFalsosEnOfi',
'Descripcion: Se modifica sp para indexar consultas y se corrige reporte por rango de fechas y reporte diario',
'Fecha: 21/05/2015';

CREATE PROCEDURE "informix".sp_consultadatospiezas_bym2(pFechaCaptura DATE, pFechaIni DATE, pFechaFin DATE, pSucursal CHAR(4), pNumRecibo CHAR(10), pNumGuia CHAR(12), pEstatus INTEGER, pDictamen INTEGER, pEmpresa CHAR(3))
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

DEFINE pRegistros			INTEGER;
DEFINE dFechaInicio          DATE;
DEFINE dFechaFin             DATE;
DEFINE iBandFecha            INTEGER;
--DEFINE iLimit                INTEGER;
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
--LET iLimit                  = 10;
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
LET pRegistros				=  0;

SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/tmp/mfinis/sp_consultadatospiezas_bym2.out";
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
					SELECT {+INDEX (bdisuc:"informix".ss_piezas_bym_falsos idx_PiezasEstatus)} 
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
															
										LET cMensaje            = 'Ejecución Exitosa.'; 
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
					SELECT {+INDEX (bdisuc:"informix".ss_piezas_bym_falsos idx_PiezasEstatus)} 
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
															
										LET cMensaje            = 'Ejecución Exitosa.'; 
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
			LET cMensaje = 'Parámetros de Entrada Vacíos';
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
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 14/12/2016',
'MODULO: CAJA GENERAL ',
'FUNCIONALIDAD: BILLETES PRESUNTAMENTE FALSOS EN SUCURSAL',
'DESCRIPCION: Spl clon, se elimina paginado.',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_consultadatospiezas_bym3(pFechaCaptura DATE, pFechaIni DATE, pFechaFin DATE, pSucursal CHAR(4), pNumRecibo CHAR(10), pNumGuia CHAR(12), pEstatus INTEGER, pDictamen INTEGER, pEmpresa CHAR(3), pRegistros INTEGER,pRecuperacion INTEGER)
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
--DEFINE iLimit                INTEGER;
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
--LET iLimit                  = 10;
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

--SET DEBUG FILE TO "/tmp/mfinis/sp_consultadatospiezas_bym3.out";
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
					SELECT {+INDEX (bdisuc:"informix".ss_piezas_bym_falsos idx_PiezasEstatus)} SKIP pRegistros FIRST pRecuperacion --LIMIT iLimit
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
															
										LET cMensaje            = 'Ejecución Exitosa.'; 
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
					SELECT {+INDEX (bdisuc:"informix".ss_piezas_bym_falsos idx_PiezasEstatus)} SKIP pRegistros FIRST pRecuperacion --LIMIT iLimit
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
															
										LET cMensaje            = 'Ejecución Exitosa.'; 
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
			LET cMensaje = 'Parámetros de Entrada Vacíos';
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
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 14/12/2016',
'MODULO: CAJA GENERAL ',
'FUNCIONALIDAD: BILLETES PRESUNTAMENTE FALSOS EN SUCURSAL',
'DESCRIPCION: Clon de SPL, se agrega parametro de entrada pRecuperacion.',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_consultadatospiezas_bym3_totales(pFechaCaptura DATE, pFechaIni DATE, pFechaFin DATE, pSucursal CHAR(4), pNumRecibo CHAR(10), pNumGuia CHAR(12), pEstatus INTEGER, pDictamen INTEGER, pEmpresa CHAR(3))
RETURNING  	CHAR(6) 	AS CodRet,
			INTEGER     AS total;
			
-- ****************************************************************************
-- Declarar variables
-- ****************************************************************************
DEFINE iSql_err               INTEGER;
DEFINE iSamErr               INTEGER;
DEFINE cDesErr               CHAR(80);
DEFINE cCodRet               CHAR(6);
DEFINE cMensaje              CHAR(80);
DEFINE iTotales        		 INTEGER;
DEFINE iBandFecha            INTEGER;
DEFINE iNoRegistros 		 INTEGER;
DEFINE dFechaInicio          DATE;
DEFINE dFechaFin             DATE;

    
-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
LET iSql_err                 = 0;
LET iSamErr                 = 0;
LET cDesErr                 = '';
LET cCodRet                 = '000000';
LET cMensaje                = '';
LET iTotales          		= 0;
LET iBandFecha              = 0;
LET iNoRegistros 			= 0;
LET dFechaInicio            = DATE(1);
LET dFechaFin               = DATE(1);

    
SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/tmp/mfinis/sp_consultadatospiezas_bym3_totales.out";
--TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err, iSamErr, cDesErr
		IF iSql_err <> 0 THEN
			LET cCodRet = CAST(iSql_err AS CHAR(6));
			LET cMensaje = cDesErr;
			RETURN cCodRet,iNoRegistros;
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
					iNoRegistros
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
				
				IF iNoRegistros = 0 THEN
					LET cCodRet = '000002';				END IF;
		
				RETURN cCodRet,iNoRegistros;
    
			
			ELIF iBandFecha = 0 THEN
				
				SELECT {+INDEX (bdisuc:"informix".ss_piezas_bym_falsos idx_PiezasEstatus)}
					COUNT(Recibo.num_recibo)
				INTO
					iNoRegistros
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
			
				IF iNoRegistros = 0 THEN
					LET cCodRet = '000002';				END IF;
		
				RETURN cCodRet,iNoRegistros;
    
				
			END IF;
		ELSE
			LET cCodRet = '000001';		END IF;
	ELSE
		LET cCodRet = '000001';	END IF;
	

	END;    
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 14/12/2016',
'MODULO: CAJA GENERAL ',
'FUNCIONALIDAD: BILLETES PRESUNTAMENTE FALSOS EN SUCURSAL',
'DESCRIPCION: Clon de SPL, para obtener totales.',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_consultaden_mon_web(
		pempresa          CHAR(3),
		psucursal         CHAR(4),
  		ptransaccion      CHAR(4),
        pTipo             CHAR(2),
        pFecha            CHAR(8),
        Pfolio            CHAR(16),
		pcant1  		  FLOAT(8),
		pcant2  		  FLOAT(8),
		pcant3  		  FLOAT(8),
		pcant4  		  FLOAT(8),
		pcant5  		  FLOAT(8),
		pcant6  		  FLOAT(8),
		pcant7  		  FLOAT(8),
        pmonto            FLOAT(8),
        psecuencia        CHAR(8)
           ) 


--RETURNING CHAR(500);

RETURNING CHAR(5),CHAR(8),CHAR(8),CHAR(8);

DEFINE vcodret			   CHAR(5);
DEFINE vsqlerr             INTEGER;
DEFINE visamerr            INTEGER;
DEFINE vhora  			   CHAR(5);
DEFINE vproveedor 		   CHAR(4);
DEFINE vfecha              DATE;
DEFINE vmensaje			   CHAR(8);
DEFINE pcant_1  		   FLOAT(8);
DEFINE pcant_2  		   FLOAT(8);
DEFINE pcant_3  		   FLOAT(8);
DEFINE pcant_4  		   FLOAT(8);
DEFINE pcant_5  		   FLOAT(8);
DEFINE pcant_6  		   FLOAT(8);
DEFINE pcant_7  		   FLOAT(8);
DEFINE psaldo_total        CHAR(20);
DEFINE cant1  		       FLOAT(8);
DEFINE cant2  		       FLOAT(8);
DEFINE cant3  		       FLOAT(8);
DEFINE cant4  	       	  FLOAT(8);
DEFINE cant5  		      FLOAT(8);
DEFINE cant6  		      FLOAT(8);
DEFINE cant7  		      FLOAT(8);
DEFINE cantdev1  		  FLOAT(8);
DEFINE cantdev2  		  FLOAT(8);
DEFINE cantdev3  		  FLOAT(8);
DEFINE cantdev4  	      FLOAT(8);
DEFINE cantdev5  		  FLOAT(8);
DEFINE cantdev6  		  FLOAT(8);
DEFINE cantdev7  		  FLOAT(8);
DEFINE CantFaltante       CHAR(8);
DEFINE CantNum            CHAR(8);


LET vcodret = "00000";
LET vproveedor = "";
LET vhora = substr(current,12,5);
LET vmensaje ='CORRECTO';
LET psaldo_total = 0;
LET CantNum  = "";

BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
   END IF;
END EXCEPTION;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

--SET debug file to "/informix/sp_consultaden_mon.out";
--trace on;


 IF pempresa = '0' or pempresa = '' or psucursal = '0' or psucursal = '' or
   ptransaccion = '0' or ptransaccion = ''  or pTipo = '0' or pTipo = '' or
   pmonto = 0 or pmonto = '' THEN
   LET vcodret = "00110";
 ELSE
  LET CantFaltante = '';
  LET pFecha = pFecha;
    SELECT p.cod_proveedor
    INTO vproveedor
	FROM bdisuc:ss_proveedores p, bdinteg:si_sucursales s
    WHERE p.plaza = s.plaza_cajagen
    AND s.empresa = pempresa
	AND s.sucursal = psucursal;

	SELECT fecha_hoy 
		into vfecha
	FROM bdinteg:si_fechas;

  IF (select count(cod_proveedor) from  bdisuc:ss_proveedores where cod_proveedor = vproveedor) > 0 THEN
	    IF ptransaccion = '27' and pTipo = "1" THEN
              LET cant1 = 0;
              LET cant2 = 0;
              LET cant3 = 0;
              LET cant4 = 0;
              LET cant5 = 0;
              LET cant6 = 0;
              LET cant7 = 0;
              
             --Suma las cantidades de cajageneral
              SELECT sum(cantidad_1), sum(cantidad_2),sum(cantidad_3),sum(cantidad_4),sum(cantidad_5),sum(cantidad_6),sum(cantidad_7) INTO
              pcant_1,pcant_2,pcant_3,pcant_4,pcant_5,pcant_6,pcant_7 
              FROM bdisuc:ss_cajageneral WHERE cod_proveedor = vproveedor; 


              IF pcant_1 is null  or pcant_1 < 0 THEN
                 LET pcant_1=0;
               END IF;

              IF pcant_2 is null or pcant_2 <  0 THEN
                 LET pcant_2=0;
               END IF;

               IF pcant_3 is null or  pcant_3 < 0 THEN
                 LET pcant_3=0;
               END IF;

                IF pcant_4  is null or pcant_4 < 0 THEN
                 LET pcant_4=0;
               END IF;
              
               IF pcant_5 is null or pcant_5  < 0 THEN
                 LET pcant_5=0;
               END IF;
               
               IF pcant_6 is null or  pcant_6  < 0 THEN
                 LET pcant_6=0;
               END IF;
               
              IF pcant_7 is null or  pcant_7 < 0 THEN
                 LET pcant_7=0;
              END IF;


			select sum(cantidad_1), sum(cantidad_2),sum(cantidad_3),sum(cantidad_4),sum(cantidad_5),sum(cantidad_6),sum(cantidad_7)INTO
			cant1,cant2,cant3,cant4,cant5,cant6,cant7 
			from bdisuc:ss_operaciones a  where a.folio_sucursal in (select b.folio_sucursal 
			from bdisuc:ss_mae_entradasalida b where b.cod_proveedor = vproveedor and b.fecha_solicitud = vfecha  and  b.status = '01') and a.cod_trans = '0001';

		   
		   ---Si valor es null iguala a 0
               IF cant1   is null THEN
                 LET cant1=0;
               END IF;

              IF cant2 is null THEN
                 LET cant2=0;
               END IF;

               IF cant3 is null THEN
                 LET cant3=0;
               END IF;

                IF cant4 is null THEN
                 LET cant4=0;
               END IF;
              
               IF cant5 is null THEN
                 LET cant5=0;
               END IF;
               
               IF cant6 is null THEN
                 LET cant6=0;
               END IF;
               
              IF cant7 is null THEN
                 LET cant7=0;
              END IF;
        
		
			select sum(cantidad_1), sum(cantidad_2),sum(cantidad_3),sum(cantidad_4),sum(cantidad_5),sum(cantidad_6),sum(cantidad_7)INTO
			cantdev1,cantdev2,cantdev3,cantdev4,cantdev5,cantdev6,cantdev7 
			from bdisuc:ss_operaciones a  where a.folio_sucursal in (select b.folio_sucursal 
			from bdisuc:ss_mae_entradasalida b where b.cod_proveedor = vproveedor and b.fecha_solicitud = vfecha and b.status = '07') and a.cod_trans = '0002';

              IF cantdev1   is null THEN
                 LET cantdev1=0;
               END IF;

              IF cantdev2 is null THEN
                 LET cantdev2=0;
               END IF;

               IF cantdev3 is null THEN
                 LET cantdev3=0;
               END IF;

                IF cantdev4 is null THEN
                 LET cantdev4=0;
               END IF;
              
               IF cantdev5 is null THEN
                 LET cantdev5=0;
               END IF;
               
               IF cantdev6 is null THEN
                 LET cantdev6=0;
               END IF;
               
              IF cantdev7 is null THEN
                 LET cantdev7=0;
              END IF;


             IF pcant7 <> 0 AND pcant7 >(pcant_7 - cant7 ) THEN
                LET CantNum = '';
                LET CantFaltante = "1";
                LET CantNum = pcant_7 - cant7;  
              END IF


             IF pcant6 <> 0 AND pcant6 >(pcant_6 - cant6 ) THEN
               LET CantNum = '';
               LET CantFaltante = "20";
               LET CantNum = pcant_6 - cant6;  
              END IF


              IF pcant5 <>0 AND pcant5 >(pcant_5 - cant5 ) THEN
                   LET CantNum = '';
                  LET CantFaltante = "50";
                  LET CantNum = pcant_5 - cant5;  
              END IF

              	

              IF pcant4 <> 0 AND  pcant4 >(pcant_4 - cant4 ) THEN
                LET CantNum = '';
                LET CantFaltante = "100";
                LET CantNum = pcant_4 - cant4;  
              END IF
              IF pcant3 <> 0 AND pcant3 > (pcant_3 - cant3) THEN
                LET  CantNum = '';
                LET CantFaltante = "200";
                LET CantNum = pcant_3 - cant3;               
              END IF
       
             IF pcant2 <>0 AND pcant2 >(pcant_2 - cant2 ) THEN
                LET CantNum = '';
                LET CantFaltante = "500";
                LET CantNum= pcant_2 - cant2;  
              END IF ;

              IF pcant1 <>0 AND pcant1 >(pcant_1 - cant1 ) THEN
                LET CantNum = '';
                LET CantFaltante = "1000";
                LET CantNum = pcant_1 - cant1;  
              END IF ;


             IF pcant1  <= 0 THEN
                 LET pcant1=0;
             END IF;

              IF pcant2  <=  0 THEN
                 LET pcant2=0;
               END IF;

               IF  pcant3  <= 0 THEN
                 LET pcant3=0;
               END IF;

                IF pcant4  < 0 THEN
                 LET pcant4=0;
               END IF;
              
               IF pcant5   <= 0 THEN
                 LET pcant5=0;
               END IF;
               
               IF   pcant6   <= 0 THEN
                 LET pcant6=0;
               END IF;
               
              IF  pcant7  <= 0 THEN
                 LET pcant7=0;
              END IF;


        END IF;  
                    
      ELSE 
          LET vcodret = "00105";
  END IF;

 END IF;

RETURN vcodret,vmensaje,CantFaltante,CantNum;
--RETURN vcodret;
END;
END PROCEDURE;