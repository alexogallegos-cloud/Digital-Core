CREATE PROCEDURE "informix".sp_dinya_cancelarordenpago_acuenta
                                                (pEmpresa char(3), ---001
                                                pSucursal char(4), ---5008
                                                pUsuario char(8), ---transBEI
                                                pFolioSuc char(16), --folio que identifica esta cancelacion                            
												pNumCliente CHAR(9),  --numero de cliente                                           
											    pNumeroControl CHAR(12) --Numero de control o clave de envio de la orden que se quiere cancelar
                                                )
                         RETURNING char(5), char(5), char(16), char(12) ;

DEFINE cCodRet 			 		CHAR(5);
DEFINE vcodretRev               CHAR(5);
DEFINE iSqlErr			 		INTEGER;
DEFINE cCuentaPrestadora 		CHAR(20);
DEFINE pImporte					MONEY (16,2);
DEFINE cTransaccCargoPago 		CHAR(4);
DEFINE ctranret					CHAR(4);
DEFINE dfechoy					DATE;
DEFINE msdodisp					MONEY (14,2);
DEFINE mmontoret				MONEY (14,2);
DEFINE mImportePago				MONEY(16,2);
DEFINE dFechaHoy				DATE;
DEFINE cTransaccSuc				CHAR(4);
DEFINE iCargo                   INTEGER;
DEFINE cCodRet2					CHAR(5);
DEFINE cMensaje					CHAR(200);
DEFINE isam_error				INTEGER;
DEFINE vTransAbono              CHAR (4);
DEFINE vNumCtaDestino			CHAR (12);
DEFINE vFechaProcesoOr			date;
DEFINE vFechaProcesoDe			date;
DEFINE vTransSucAbono			CHAR(4);


	--SET DEBUG FILE TO "/home/informix/BereniceOut/sp_dinya_cancelarordenpago_acuenta.out";
    --TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr,isam_error,cMensaje
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			If iCargo = 1 THEN
				CALL  bdicheq:reversion('001',pSucursal,pUsuario,pFolioSuc,'A') RETURNING vcodretRev;
				INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
				VALUES (iSqlErr,isam_error,cMensaje,'sp_dinya_cancelarordenpago_acuenta',dfechoy,CURRENT );
			END IF;
			RETURN cCodRet, vcodretRev, pFolioSuc, vNumCtaDestino;
		END IF;
	END EXCEPTION;

	LET cCodRet 			   = '00000';
	LET iSqlErr			 	   = 0;
	LET cCuentaPrestadora 	   = '';
	LET cTransaccCargoPago	   = '';
	LET ctranret			   = '';
	LET dfechoy				   = '';
	LET msdodisp			   = '';
	LET mmontoret			   = '';
	LET mImportePago		   = '';
	LET dFechaHoy			   = '';
	LET cTransaccSuc		   = '';
	LET iCargo                 = 0;
	LET cMensaje			   = '';
	LET isam_error			   = '';
    LET vTransAbono            = '';
    LET vcodretRev             = '';
	LET vNumCtaDestino		   = '';
	LET vTransSucAbono		   = ''; --ver cual se asigna
	

	SET ISOLATION TO CURSOR STABILITY;
	SET LOCK MODE TO WAIT 10;

    --Se verifica que exista en la tabla de ordenes de pagos el numero de control enviado con estatus activo
	IF NOT EXISTS (SELECT {+INDEX (bdisac:sac_enviosdineroya idxsac_envdinya13_1)} no_control FROM "informix".sac_enviosdineroya WHERE no_control = pNumeroControl AND estatus = '01') THEN
		LET cCodRet = '00001';
		RETURN cCodRet, vcodretRev, pFolioSuc, vNumCtaDestino;
	END IF;

    --Se obtiene el importe de la orden de pago que se quiere cancelar.
	SELECT {+INDEX (bdisac:sac_enviosdineroya idxsac_envdinya13_1)} importe_pago
	INTO mImportePago
	FROM Bdisac:"informix".sac_enviosdineroya
	WHERE no_control = pNumeroControl and estatus is not null;
	
	--Se saca la cuenta de la que se saco el dinero para la orden de pago
	select cta_origen 
	INTO vNumCtaDestino
	from bdibei:"informix".bei_dispersiones_odp 
	where num_cliente=pNumCliente and clave_envio=pNumeroControl;

	--Obtiene el numero de la cuenta prestadora.
	SELECT valor INTO cCuentaPrestadora
	FROM Bdisac:"informix".sac_param
	WHERE cod_param='75';

	--Consulta el parametro de la transaccion para el cargo âCargo por CancelaciÃ³n, DineroYaâ valor de â1192â
    --se envia al cargo ref para hacer el cargo a la cuenta consentrador.
    SELECT valor INTO cTransaccCargoPago
	FROM Bdisac:"informix".sac_param
	WHERE cod_param='41507003';

    ---Numero de transaccion que se envia a cargo ref
	SELECT valor INTO cTransaccSuc --- valor 8703  
	FROM Bdisac:"informix".sac_param
	WHERE cod_param = '807003'; --pendiente de confirmar si es ese o uno nuevo  "Transaccion Sucursal Cancelacion Dinero Ya"

    ---Numero de transaccion que se envia a abono ref
    SELECT valor INTO vTransAbono ---valor 0272 -- en la si_transacc "ABONO A CUENTA DIVERSO" (pendiente de confirmar)
    FROM Bdisac:"informix".sac_param
	WHERE cod_param = '300701'; --"ABONO A CUENTA POR CANCELACION DE ORDEN DE PAGO" 
						    
           
        IF cCodRet = '00000' THEN
            SELECT fecha_proceso INTO vFechaProcesoOr FROM bdicheq:"informix".sc_maechq WHERE cuenta = cCuentaPrestadora;
            SELECT fecha_proceso INTO vFechaProcesoDe FROM bdicheq:"informix".sc_maechq WHERE cuenta = vNumCtaDestino;

            IF (vFechaProcesoOr <> vFechaProcesoDe) THEN
                LET cCodRet = '00002';
            END IF;
        END IF


        IF  cCodRet = '00000'  THEN ---fechas de proceso son iguales
            --Cargo a la cuenta prestadora
            EXECUTE PROCEDURE bdicheq:cargo_ref 
                (pEmpresa, 
                pSucursal, 
                pUsuario,  
                cTransaccCargoPago, 
                cTransaccSuc, 
                pFolioSuc,
                cCuentaPrestadora, 
                0,  ---cheque
                mImportePago,
                "01", --divisa
                 " ",  --referencia
                '',  ---pnum_tarjeta
                pUsuario)
            INTO
            cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

            IF cCodRet <> '000' THEN --Error en el cargo a la cuenta prestadora
                LET cCodRet = '00003'; 
                RETURN cCodRet, vcodretRev, pFolioSuc, vNumCtaDestino;
            ELSE ---paso bien el cargo
                LET iCargo = 1; 
            END IF;
            ---------------------------------------------------------------------
            EXECUTE PROCEDURE bdicheq:"informix".abono_ref(pEmpresa,
                                                    pSucursal,
                                                    pUsuario,
                                                    vTransAbono,  
                                                    vTransSucAbono, --se manda vacio 
                                                    pFolioSuc,
                                                    vNumCtaDestino,
                                                    '', ---? pDocto
                                                    mImportePago,
                                                    mImportePago, --- pMontoFirme
                                                    0, ---? pMontoSBC
                                                    0, ---? pMontoRem
                                                    0, ---? pDiasRet
                                                    "01",
                                                    "", ---? pReferencia
                                                    '',
                                                    pUsuario) 
                                                    INTO cCodRet;

                        IF cCodRet <> '000' THEN
                            EXECUTE PROCEDURE bdicheq:"informix".reversion(pEmpresa,
                                                        pSucursal,
                                                        pUsuario,
                                                        pFolioSuc,
                                                        'A') INTO vcodretRev;
                            IF vcodretRev = '000' THEN
                                LET vcodretRev = '001';
                            END IF;
                            RETURN cCodRet, vcodretRev, pFolioSuc, vNumCtaDestino;
                        END IF;
          ELSE --fechas de procesos diferentes
                RETURN cCodRet, vcodretRev, pFolioSuc, vNumCtaDestino;
          END IF;


         ---------------------------------------------------------------
         SELECT fecha_hoy INTO dFechaHoy FROM sac_fechas;
         
         --se llama al spl que registrara el movimiento en sac_movimientos
		CALL bdisac:sp_grabapagoservicio (pSucursal,'07','003', pNumeroControl,
		SUBSTR(LPAD(pNumeroControl,12,'0'),12,1),'1', mImportePago,'0.00','0.00','0.00','0.00',
		cCuentaPrestadora,pUsuario,pFolioSuc, cTransaccSuc,dFechaHoy)
		RETURNING cCodRet;

		IF cCodRet <> '00000' THEN --no paso bien el grabapagoservicio---
			CALL  bdicheq:reversion('001',pSucursal,pUsuario,pFolioSuc,'A') RETURNING vcodretRev;
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (cCodRet,isam_error,cMensaje,'sp_dinya_cancelarordenpago_acuenta',dfechoy,CURRENT );
			RETURN cCodRet, vcodretRev, pFolioSuc, vNumCtaDestino;
		END IF;

        --Se actualiza el estatus de la orden a cancelada
		UPDATE {+INDEX (bdisac:sac_enviosdineroya idxsac_envdinya13_1)} sac_enviosdineroya SET estatus = '02',suc_cance = pSucursal, fecha_cance = dFechaHoy,
			   hora_cance = CURRENT HOUR TO SECOND, usua_cance = pUsuario WHERE no_control = pNumeroControl and estatus is not null;

	
	RETURN cCodRet, vcodretRev, pFolioSuc, vNumCtaDestino;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: CANCELADA EL ENVIO DE DINERO-ORDEN DE PAGO NO COBRADA',
'AUTOR: BERENICE NORIEGA GUEVARA',
'FECHA: AGOSTO 2019',
'VERSION: 20190806',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_cargaarchivoaconciliacionbcpl(pFecha_Hoy DATE)
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(80)		AS mensaje_respuesta;
        
    DEFINE iSqlErr     	 	INTEGER;
    DEFINE iIsamErr     	INTEGER;
    DEFINE cInfoErr  		VARCHAR(100);
	DEFINE cSql_Stmt    	CHAR(2000);
    DEFINE cCodRet      	CHAR(5);
    DEFINE cMensaje     	CHAR(80);
	DEFINE cCodRet2      	CHAR(5);
	DEFINE cMensaje2		CHAR(80);
    DEFINE cRutaconc    	CHAR(80);
	DEFINE cNombrearch    	CHAR(100);
	DEFINE cNombreCifras    CHAR(100);
    DEFINE iCargados    	INTEGER;
	DEFINE cDescripcionSPJ	CHAR(100);
	DEFINE cStatus			CHAR(1);
	DEFINE cCodRetSP		CHAR(5);
	
	DEFINE cDia 			CHAR(2);
	DEFINE cMes 			CHAR(2);
	DEFINE cAnio			CHAR(4);
	--DEFINE pFecha_Hoy		DATE;
	DEFINE cColumna			CHAR(250);
	
	DEFINE sMovimiento    	VARCHAR(5);
    DEFINE sTipomovimiento	VARCHAR(5);
    DEFINE sImporte       	VARCHAR(25);
    DEFINE sFechapago     	VARCHAR(15);
    DEFINE sTienda        	VARCHAR(8);
    DEFINE sNumempleado   	VARCHAR(12);
    DEFINE sEmpresa       	VARCHAR(5);
    DEFINE sCiudad        	VARCHAR(7);
    DEFINE sDescripcion   	VARCHAR(55);
    DEFINE sCaja          	VARCHAR(7);
    DEFINE sFoliosucursal 	VARCHAR(20);
    DEFINE sNumerotiket   	VARCHAR(22);
    DEFINE sContrato      	VARCHAR(45);
    DEFINE sCampo1        	VARCHAR(25);
    DEFINE sCampo2        	VARCHAR(25);
    DEFINE sCampo3        	VARCHAR(25);
    DEFINE sCampo4        	VARCHAR(25);
	DEFINE sCampo5        	VARCHAR(25);
	DEFINE sCampo6        	VARCHAR(25);
	DEFINE sCampo7        	VARCHAR(25);
	DEFINE sCampo8        	VARCHAR(25);
	DEFINE sCampo9        	VARCHAR(25);
	DEFINE sCampo10       	VARCHAR(25);
	DEFINE sNumMovs			VARCHAR(25);
				
	DEFINE cMovimiento    	CHAR(2);
    DEFINE cTipomovimiento	CHAR(2);
    DEFINE iImporte       	INTEGER;
	DEFINE iImporte2       	INTEGER;
    DEFINE dFechapago     	DATE;
    DEFINE cTienda        	CHAR(4);
    DEFINE cNumempleado   	CHAR(8);
    DEFINE cEmpresa       	CHAR(1);
    DEFINE cCiudad        	CHAR(3);
    DEFINE cDescripcion   	CHAR(50);
    DEFINE cCaja          	CHAR(3);
    DEFINE cFoliosucursal 	CHAR(16);
    DEFINE cNumerotiket   	VARCHAR(18);
    DEFINE cContrato      	VARCHAR(40);
    DEFINE iCampo1        	INTEGER;
    DEFINE iCampo2        	INTEGER;
    DEFINE iCampo3        	INTEGER;
    DEFINE iCampo4        	INTEGER;
	DEFINE iCampo5        	INTEGER;
	DEFINE iCampo6        	INTEGER;
	DEFINE iCampo7        	INTEGER;
	DEFINE iCampo8        	INTEGER;
	DEFINE iCampo9        	INTEGER;
	DEFINE iCampo10       	INTEGER;
	DEFINE iNumMovs			INTEGER;
	DEFINE iNumMovs2		INTEGER;
	DEFINE dfecha_carga2	DATE;
	
	DEFINE iContCamp		INTEGER;
	DEFINE i				INTEGER;
	DEFINE iPrim			INTEGER;
	DEFINE iUlt				INTEGER;
	DEFINE cFechaFormat		CHAR(10);
	DEFINE cCarTemp			CHAR(1);
	DEFINE iCuentaHist		INTEGER;
	DEFINE iCuentaHist2		INTEGER;
	
	DEFINE bndCargaCifras	SMALLINT;
	DEFINE bndCargaDetalle	SMALLINT;
	DEFINE bndLeeCifras		SMALLINT;
	DEFINE bndLeeDetalle	SMALLINT;
	
	
	LET iSqlErr 			= 0;
    LET iIsamErr 			= '0';
    LET cSql_Stmt       	= '';
    LET cCodRet         	= '00000';
    LET cMensaje        	= 'PROCESO EXITOSO';
	LET cCodRet2         	= '';
	LET cMensaje2			= '';
    LET cRutaconc       	= '';
	LET cNombrearch    		= '';
	LET cNombreCifras       = '';
    LET iCargados       	= 0;
	LET cDescripcionSPJ		= 'Carga archivo para conciliacion de servicios homologados Coppel-Bancoppel';
	LET cStatus				= '0';
	LET cCodRetSP			= '00000';
	LET iNumMovs			= 0;
	LET iNumMovs2			= 0;
	
	LET cDia 				= '';
	LET cMes 				= '';
	LET cAnio				= '';
	--LET pFecha_Hoy			= DATE(1);
	LET cColumna			= '';
	LET cMovimiento    		= '';
    LET cTipomovimiento		= '';
    LET iImporte       		= 0;
	LET iImporte2      		= 0;
    LET dFechapago     		= DATE(1);
    LET cTienda        		= '';
    LET cNumempleado   		= '';
    LET cEmpresa       		= '';
    LET cCiudad        		= '';
    LET cDescripcion   		= '';
    LET cCaja          		= '';
    LET cFoliosucursal 		= '';
    LET cNumerotiket   		= '';
    LET cContrato      		= '';
    LET iCampo1        		= '';
    LET iCampo2        		= '';
    LET iCampo3        		= '';
    LET iCampo4        		= '';
	LET iCampo5        		= '';
	LET iCampo6        		= '';
	LET iCampo7        		= '';
	LET iCampo8        		= '';
	LET iCampo9        		= '';
	LET iCampo10       		= '';
	LET dfecha_carga2		= DATE(1);
	
	LET iContCamp			= 0;
	LET i					= 0;
	LET iPrim				= 0;
	LET iUlt				= 0;
	LET cFechaFormat		= '';
	LET cCarTemp			= '';
	
	LET bndCargaCifras		= 0;
	LET bndCargaDetalle		= 0;
	LET bndLeeCifras		= 0;
	LET bndLeeDetalle		= 0;


    --SET DEBUG FILE TO  '/informix/noe/hservicios/sp_cargaarchivoaconciliacionbcpl.out';
	--TRACE ON; 

    BEGIN

       ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_cargaarchivoaconciliacionbcpl");
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;

        ON EXCEPTION IN (-668)
		
			IF bndCargaCifras = 0 THEN
				LET cCodRet = '00001';
				LET cMensaje = 'ERROR EN LA CARGA DEL ARCHIVO DE CIFRAS';
			ELSE
				IF bndCargaDetalle = 0 THEN
					LET cCodRet = '00001';
					LET cMensaje = 'ERROR EN LA CARGA DEL ARCHIVO DE DETALLE';
				ELSE
					IF bndLeeCifras = 0 THEN
						LET cCodRet = '00001';
						LET cMensaje = 'ERROR EN EL LAYOUT DEL ARCHIVO DE CIFRAS';
					ELSE
						IF bndLeeDetalle = 0 THEN
							LET cCodRet = '00001';
							LET cMensaje = 'ERROR EN EL LAYOUT DEL ARCHIVO DE DETALLE';
						END IF;
					END IF;
				END IF;
			END IF;
			
			
			--IF EXISTS (SELECT 1 FROM bdisac:"informix".sac_conciliacion_bcpl_cpl) THEN
			--	LET cCodRet = '00001';
			--	LET cMensaje = 'ERROR EN LA CARGA DEL ARCHIVO';
			--ELSE					
			--	LET cCodRet = '00002';
			--	LET cMensaje = 'ERROR NO SE ENCONTRO EL ARCHIVO ESPECIFICADO';
			--END IF;

			LET cSql_Stmt = 'rm -f ' || TRIM(cRutaconc) || 'conciliacion.sql';
			SYSTEM cSql_Stmt;
			
			LET cSql_Stmt = 'rm -f ' || TRIM(cRutaconc) || 'conciliacioncifras.sql';
			SYSTEM cSql_Stmt;

			RETURN cCodRet,cMensaje;
	    END EXCEPTION;
		
		--BORRA TABLAS DE PASO
		EXECUTE PROCEDURE "informix".sp_inicializatablas_concbcpl('CARG',pFecha_Hoy) INTO cCodRetSP, cMensaje;
		IF cCodRetSP <> '00000' THEN
			LET cCodRet = '00003';
			LET cMensaje = "ERROR AL BORRAR REGISTROS DE TABLAS DE PASO PARA LA CONCILIACION";
			EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
			RETURN cCodRet, cMensaje;			
		END IF;		
		
		SELECT valor
		INTO cRutaconc
		FROM bdisac:"informix".sac_param 
		WHERE empresa = '001' 
		AND cod_param = '116';

		SELECT valor
		INTO cNombrearch
		FROM bdisac:"informix".sac_param 
		WHERE empresa = '001' 
		AND cod_param = '117';
		
		SELECT valor
		INTO cNombreCifras
		FROM bdisac:"informix".sac_param 
		WHERE empresa = '001' 
		AND cod_param = '121';

		--ASIGNA VALOR A LAS VARIABLES
		LET cDia = LPAD(DAY(pFecha_Hoy::DATE), 2, '0');
		LET cMes = LPAD(MONTH(pFecha_Hoy::DATE), 2, '0');
		LET cAnio = LPAD(YEAR(pFecha_Hoy::DATE),4,'0');	
		
		LET cNombrearch = REPLACE(cNombrearch,'AAAA',cAnio);
		LET cNombrearch = REPLACE(cNombrearch,'MM',cMes);
		LET cNombrearch = REPLACE(cNombrearch,'DD',cDia);
		
		LET cNombreCifras = REPLACE(cNombreCifras,'AAAA',cAnio);
		LET cNombreCifras = REPLACE(cNombreCifras,'MM',cMes);
		LET cNombreCifras = REPLACE(cNombreCifras,'DD',cDia);
		
		--CARGA ARCHIVO DE CIFRAS A TABLA
		LET cSql_Stmt = '';
		LET cSql_Stmt = 'echo "load from '||TRIM(cRutaconc) || TRIM(cNombreCifras) ||
				' insert into bdisac:sac_conc_archtemp1 " > '||TRIM(cRutaconc) ||'conciliacioncifras.sql';
		System cSql_Stmt;			
		
		LET cSql_Stmt = '';
		LET cSql_Stmt = 'dbaccess bdisac '||TRIM(cRutaconc) ||'conciliacioncifras.sql ';  --Se activa para desarrollo    
		--Let cSql_Stmt = '/ifxsif01/bin/dbaccess bdisac '||TRIM(cRutaconc) ||'conciliacioncifras.sql';  --Se activa para Produccion	
		System cSql_Stmt;
		
		LET cSql_Stmt = '' ;
		LET cSql_Stmt = 'rm ' || TRIM(cRutaconc) || 'conciliacioncifras.sql';
		SYSTEM cSql_Stmt;
		
		--Modifico bandera de proceso exitoso en Carga de archivo de cifras
		LET bndCargaCifras = 1;
		
		--CARGA ARCHIVO DE DETALLE A TABLA
		LET cSql_Stmt = '';
		LET cSql_Stmt = 'echo "load from '||TRIM(cRutaconc) || TRIM(cNombrearch) ||
				' insert into bdisac:sac_conc_archtemp2 " > '||TRIM(cRutaconc) ||'conciliacion.sql';
		System cSql_Stmt;			
		
		LET cSql_Stmt = '';
		LET cSql_Stmt = 'dbaccess bdisac '||TRIM(cRutaconc) ||'conciliacion.sql ';  --Se activa para desarrollo    
		--Let cSql_Stmt = '/ifxsif01/bin/dbaccess bdisac '||TRIM(cRutaconc) ||'conciliacion.sql';  --Se activa para Produccion	
		System cSql_Stmt;
		
		LET cSql_Stmt = '' ;
		LET cSql_Stmt = 'rm ' || TRIM(cRutaconc) || 'conciliacion.sql';
		SYSTEM cSql_Stmt;
		
		--Modifico bandera de proceso exitoso en Carga de archivo de detalle
		LET bndCargaDetalle = 1;
		
		--Se validara que existan registros por cargar

		LET iCargados = 0;
		
		SELECT COUNT(*)
		INTO iCargados
		FROM bdisac:"informix".sac_conc_archtemp2;
			
		IF iCargados <= 0 THEN
			--Se valida que existan registros de detalle
			LET cCodRet  = '00001';
			LET cMensaje = 'NO HAY REGISTROS CARGADOS EN LA TABLA';
			EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
			RETURN cCodRet, cMensaje;
		END IF;
		
		LET iCargados = 0;
		
		SELECT COUNT(*)
		INTO iCargados
		FROM bdisac:"informix".sac_conc_archtemp1;
			
		IF iCargados <= 0 THEN
			--Se valida que existan registros de cifras
			LET cCodRet  = '00001';
			LET cMensaje = 'NO HAY REGISTROS CARGADOS EN LA TABLA DE CIFRAS';
			EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
			RETURN cCodRet, cMensaje;
		END IF;
		
		--Valido que las cifras reportadas sean adecuadas con respecto al detalle
		--Intento la inserciÃÂ³n de datos de cifras en tabla de cifras
		FOREACH
			SELECT TRIM(fecha_pago), TRIM(tienda), TRIM(importe), TRIM(movimiento), TRIM(tipo_mov), TRIM(num_movs), TRIM(empresa)
			INTO   sFechapago, sTienda, sImporte, sMovimiento, sTipomovimiento, sNumMovs, sEmpresa
			FROM   bdisac:"informix".sac_conc_archtemp1
			
			/*Inicializo variables*/
			LET dFechapago     		= DATE(1);
			LET cTienda        		= '';
			LET iImporte       		= 0;
			LET cMovimiento    		= '';
			LET cTipomovimiento		= '';
			LET iNumMovs       		= 0;
			LET cEmpresa       		= '';
			
			IF LENGTH(sMovimiento) > 2 THEN
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR EL CAMPO MOVIMIENTO SOBREPASA LA LONGITUD (CIFRAS)';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			LET cMovimiento = sMovimiento;
			
			IF LENGTH(sTipomovimiento) > 2 THEN
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR EL CAMPO MOVIMIENTO SOBREPASA LA LONGITUD (CIFRAS)';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			LET cTipomovimiento = sTipomovimiento;
			
			IF bdiprog:isnumeric(sImporte) <> '0' THEN
				LET iImporte = sImporte;
			ELSE
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR EL CAMPO IMPORTE NO ES NUMERICO (CIFRAS)';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			
			IF LENGTH(sFechapago) > 10 THEN
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR EL CAMPO FECHAPAGO SOBREPASA LA LONGITUD (CIFRAS)';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			LET cFechaFormat = sFechapago;
			IF LENGTH(cFechaFormat) = 10 THEN
				LET dFechapago = MDY(SUBSTR(cFechaFormat,6,2),SUBSTR(cFechaFormat,9,2),SUBSTR(cFechaFormat,1,4));
			ELSE
				LET dFechapago = mdy(01,01,1900);
			END IF;
			
			IF LENGTH(sTienda) > 4 THEN
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR EL CAMPO TIENDA SOBREPASA LA LONGITUD (CIFRAS)';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			LET cTienda = sTienda;
			
			IF LENGTH(sEmpresa) > 1 THEN
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR EL CAMPO EMPRESA SOBREPASA LA LONGITUD (CIFRAS)';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			LET cEmpresa = sEmpresa;
			
			IF bdiprog:isnumeric(sNumMovs) <> '0' THEN
				LET iNumMovs = sNumMovs;
			ELSE
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR EL CAMPO NUMERO DE MOVIMIENTOS NO ES NUMERICO (CIFRAS)';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			
			IF (iNumMovs <= 0) THEN				
				LET cCodRet = '00006';
				LET cMensaje = 'ERROR NUMERO DE REGISTROS CIFRAS MENOR O IGUAL A CERO';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			ELSE
				
				INSERT INTO bdisac:"informix".sac_conciliacion_cifras (fechapago,tienda,importe,movimiento,tipomovimiento,numeromovs,empresa,
							fecha_concil,nombre_archivo)
				VALUES (dFechapago, cTienda, iImporte, cMovimiento, cTipomovimiento, sNumMovs, cEmpresa, TODAY, cNombreCifras);
							
			END IF;
			
		END FOREACH;
		
		--Modifico bandera de proceso exitoso en proceso de lectura del archivo de cifras
		LET bndLeeCifras = 1;
		
		FOREACH
			SELECT TRIM(movimiento), TRIM(tipo_mov), TRIM(importe), TRIM(fecha_pago), TRIM(tienda), TRIM(num_empleado),
				   TRIM(empresa), TRIM(ciudad), TRIM(descripcion), TRIM(caja), TRIM(folio_suc), TRIM(no_ticket),
				   TRIM(contrato), TRIM(campo1), TRIM(campo2), TRIM(campo3), TRIM(campo4),
				   TRIM(campo5), TRIM(campo6), TRIM(campo7), TRIM(campo8), TRIM(campo9), TRIM(campo10)
			INTO   sMovimiento, sTipomovimiento, sImporte, sFechapago, sTienda, sNumempleado, sEmpresa, sCiudad,
				   sDescripcion, sCaja, sFoliosucursal, sNumerotiket, sContrato, sCampo1, sCampo2, sCampo3, sCampo4,
				   sCampo5, sCampo6, sCampo7, sCampo8, sCampo9, sCampo10
			FROM   bdisac:"informix".sac_conc_archtemp2
				
			LET iContCamp = 1;
			LET iPrim = 1;
			/*Inicializo variables*/
			LET cMovimiento    		= '';
			LET cTipomovimiento		= '';
			LET iImporte       		= 0;
			LET dFechapago     		= DATE(1);
			LET cTienda        		= '';
			LET cNumempleado   		= '';
			LET cEmpresa       		= '';
			LET cCiudad        		= '';
			LET cDescripcion   		= '';
			LET cCaja          		= '';
			LET cFoliosucursal 		= '';
			LET cNumerotiket   		= '';
			LET cContrato      		= '';
			LET iCampo1        		= '';
			LET iCampo2        		= '';
			LET iCampo3        		= '';
			LET iCampo4        		= '';
			LET iCampo5        		= '';
			LET iCampo6        		= '';
			LET iCampo7        		= '';
			LET iCampo8        		= '';
			LET iCampo9        		= '';
			LET iCampo10       		= '';
			
			IF LENGTH(sMovimiento) > 2 THEN
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR EL CAMPO MOVIMIENTO SOBREPASA LA LONGITUD';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			LET cMovimiento = sMovimiento;
			
			IF LENGTH(sTipomovimiento) > 2 THEN
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR EL CAMPO MOVIMIENTO SOBREPASA LA LONGITUD';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			LET cTipomovimiento = sTipomovimiento;
			
			IF bdiprog:isnumeric(sImporte) <> '0' THEN
				LET iImporte = sImporte;
			ELSE
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR EL CAMPO IMPORTE NO ES NUMERICO';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			
			IF LENGTH(sFechapago) > 10 THEN
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR EL CAMPO FECHAPAGO SOBREPASA LA LONGITUD';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			LET cFechaFormat = sFechapago;
			IF LENGTH(cFechaFormat) = 10 THEN
				LET dFechapago = MDY(SUBSTR(cFechaFormat,6,2),SUBSTR(cFechaFormat,9,2),SUBSTR(cFechaFormat,1,4));
			ELSE
				LET dFechapago = mdy(01,01,1900);
			END IF;
			
			IF LENGTH(sTienda) > 4 THEN
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR EL CAMPO TIENDA SOBREPASA LA LONGITUD';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			LET cTienda = sTienda;
			
			IF LENGTH(sNumempleado) > 8 THEN
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR EL CAMPO USUARIO SOBREPASA LA LONGITUD';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			LET cNumempleado = sNumempleado;
			
			IF LENGTH(sEmpresa) > 1 THEN
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR EL CAMPO EMPRESA SOBREPASA LA LONGITUD';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			LET cEmpresa = sEmpresa;
			
			IF LENGTH(sCiudad) > 4 THEN
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR EL CAMPO CIUDAD SOBREPASA LA LONGITUD';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			LET cCiudad = sCiudad;
			
			IF LENGTH(sDescripcion) > 50 THEN
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR EL CAMPO DESCRIPCION SOBREPASA LA LONGITUD';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			LET cDescripcion = sDescripcion;
			
			IF LENGTH(sCaja) > 3 THEN
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR EL CAMPO CAJA SOBREPASA LA LONGITUD';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			LET cCaja = sCaja;
			
			IF LENGTH(sFoliosucursal) > 16 THEN
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR EL CAMPO FOLIOSUCURSAL SOBREPASA LA LONGITUD';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			LET cFoliosucursal = sFoliosucursal;
			
			IF LENGTH(sNumerotiket) > 18 THEN
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR EL CAMPO NUMEROTICKET SOBREPASA LA LONGITUD';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			LET cNumerotiket = sNumerotiket;
			
			IF LENGTH(sContrato) > 40 THEN
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR EL CAMPO CONTRATO SOBREPASA LA LONGITUD';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			LET cContrato = sContrato;
			
			IF bdiprog:isnumeric(sCampo1) <> '0' THEN
				LET iCampo1 = sCampo1;
			ELSE
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR CAMPO 1 NO ES NUMERICO';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			
			IF bdiprog:isnumeric(sCampo2) <> '0' THEN
				LET iCampo2 = sCampo2;
			ELSE
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR CAMPO 2 NO ES NUMERICO';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			
			IF bdiprog:isnumeric(sCampo3) <> '0' THEN
				LET iCampo3 = sCampo3;
			ELSE
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR CAMPO 3 NO ES NUMERICO';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			
			IF bdiprog:isnumeric(sCampo4) <> '0' THEN
				LET iCampo4 = sCampo4;
			ELSE
				LET cCodRet = '00004';
				LET cMensaje = 'ERROR CAMPO 4 NO ES NUMERICO';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			END IF;
			
			--Para estos campos ahorita solo los pasare directamente
			LET iCampo5 = sCampo5;
			LET iCampo6 = sCampo6;
			LET iCampo7 = sCampo7;
			LET iCampo8 = sCampo8;
			LET iCampo9 = sCampo9;
			LET iCampo10 = sCampo10;
			
			IF (cTienda = '' OR cTienda is NULL OR cTienda = '0000') OR (cCaja = '' OR cCaja is NULL) OR 
				(cNumerotiket = '' OR cNumerotiket is NULL) OR (cFoliosucursal = '' OR cFoliosucursal is NULL) THEN				
				LET cCodRet = '00005';
				LET cMensaje = 'ERROR CAMPOS OBLIGATORIOS EN BLANCO O NULL';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje, "sp_cargaarchivoaconciliacionbcpl");
				DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  nombre_archivo = cNombrearch;
				DELETE FROM bdisac:"informix".sac_conciliacion_cifras
				WHERE  nombre_archivo = cNombreCifras;
				RETURN cCodRet, cMensaje;
			ELSE
				IF cFoliosucursal = '0' THEN
					--Estos movimientos no se validaran, pero se espera que se vayan sin conciliar al archivo.
					LET cCodRet2 = '00009';
					LET cMensaje2 = 'EL REGISTRO CON FECPAGO ' || TRIM(sFechapago) || ' E IMP ' || TRIM(sImporte) || ' TIENE , EXCLUIDO';
					EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet2, iIsamErr, cMensaje2, "sp_cargaarchivoaconciliacionbcpl");
					
					INSERT INTO bdisac:"informix".sac_conciliacion_bcpl_cpl (movimiento,tipomovimiento,importe,fechapago,tienda,numempleado,empresa,
								ciudad,descripcion,caja,foliosucursal,numerotiket,contrato,campo1,campo2,campo3,campo4,campo5,campo6,campo7,campo8,campo9,campo10,
								fecha_insert,st_conciliado,
								fecha_concil,nombre_archivo)
					VALUES (cMovimiento,cTipomovimiento,iImporte,dFechapago,cTienda,cNumempleado,cEmpresa,cCiudad,cDescripcion,cCaja,cFoliosucursal,
								cNumerotiket,cContrato,iCampo1,iCampo2,iCampo3,iCampo4,iCampo5,iCampo6,iCampo7,iCampo8,iCampo9,iCampo10,TODAY,0,NULL,cNombrearch);
								
				ELSE
					--Reviso que no hayan sido cargados previamente
					LET iCuentaHist  = 0;
					LET iCuentaHist2 = 0;
					
					--SELECT COUNT(foliosucursal)
					--INTO   iCuentaHist
					--FROM   bdisac:"informix".sac_conciliacion_bcpl_cpl
					--WHERE  foliosucursal = cFoliosucursal
					--AND    fechapago     = dFechapago;
					
					SELECT COUNT(foliosucursal)
					INTO   iCuentaHist
					FROM   bdisac:"informix".sac_conciliacion_bcpl_cpl
					WHERE  foliosucursal  = cFoliosucursal
					AND    fechapago      = dFechapago
					AND    movimiento     = cMovimiento
					AND    tipomovimiento = cTipomovimiento
					AND    tienda         = cTienda
					AND    caja           = cCaja
					AND    numerotiket    = cNumerotiket;
					
					--SELECT COUNT(foliosucursal)
					--INTO   iCuentaHist2
					--FROM   bdisac:"informix".sac_conciliacion_bcpl_cpl_old
					--WHERE  foliosucursal = cFoliosucursal
					--AND    fechapago     = dFechapago
					--AND    st_conciliado = 1;
					
					SELECT COUNT(foliosucursal)
					INTO   iCuentaHist2
					FROM   bdisac:"informix".sac_conciliacion_bcpl_cpl_old
					WHERE  foliosucursal  = cFoliosucursal
					AND    fechapago      = dFechapago
					AND    movimiento     = cMovimiento
					AND    tipomovimiento = cTipomovimiento
					AND    tienda         = cTienda
					AND    caja           = cCaja
					AND    numerotiket    = cNumerotiket
					AND    st_conciliado  = 1;
					
					IF iCuentaHist + iCuentaHist2 = 0 THEN
					
						INSERT INTO bdisac:"informix".sac_conciliacion_bcpl_cpl (movimiento,tipomovimiento,importe,fechapago,tienda,numempleado,empresa,
									ciudad,descripcion,caja,foliosucursal,numerotiket,contrato,campo1,campo2,campo3,campo4,campo5,campo6,campo7,campo8,campo9,campo10,
									fecha_insert,st_conciliado,
									fecha_concil,nombre_archivo)
						VALUES (cMovimiento,cTipomovimiento,iImporte,dFechapago,cTienda,cNumempleado,cEmpresa,cCiudad,cDescripcion,cCaja,cFoliosucursal,
									cNumerotiket,cContrato,iCampo1,iCampo2,iCampo3,iCampo4,iCampo5,iCampo6,iCampo7,iCampo8,iCampo9,iCampo10,TODAY,0,NULL,cNombrearch);
									
					ELSE
					
						INSERT INTO bdisac:"informix".sac_conciliacion_bcpl_cpl (movimiento,tipomovimiento,importe,fechapago,tienda,numempleado,empresa,
									ciudad,descripcion,caja,foliosucursal,numerotiket,contrato,campo1,campo2,campo3,campo4,campo5,campo6,campo7,campo8,campo9,campo10,
									fecha_insert,st_conciliado,
									fecha_concil,nombre_archivo)
						VALUES (cMovimiento,cTipomovimiento,iImporte,dFechapago,cTienda,cNumempleado,cEmpresa,cCiudad,cDescripcion,cCaja,cFoliosucursal,
									cNumerotiket,cContrato,iCampo1,iCampo2,iCampo3,iCampo4,iCampo5,iCampo6,iCampo7,iCampo8,iCampo9,iCampo10,TODAY,2,NULL,cNombrearch);
						LET cCodRet2 = '00006';
						LET cMensaje2 = 'EL FOLIO ' || TRIM(cFoliosucursal) || ' YA FUE AGREGADO ANTERIORMENTE';
						--LET cMensaje = 'PROCESO EXITOSO, SE ENCONTRARON FOLIOS DUPLICADOS O YA CARGADOS ANTERIORMENTE';
						--LET cMensaje2 = 'EL FOLIO ' || TRIM(cFoliosucursal) || ' YA FUE AGREGADO ANTERIORMENTE';
						EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet2, iIsamErr, cMensaje2, "sp_cargaarchivoaconciliacionbcpl");
						--DELETE FROM sac_conciliacion_bcpl_cpl
						--WHERE  nombre_archivo = cNombrearch;
						--DELETE FROM sac_conciliacion_cifras
						--WHERE  nombre_archivo = cNombreCifras;
						--RETURN cCodRet, cMensaje;
						
					END IF;
				END IF;
			END IF;
		END FOREACH;
		
		--Modifico bandera de proceso exitoso en proceso de lectura del archivo de cifras
		LET bndLeeDetalle = 1;
		
		
		--REVISO CIFRAS VS DETALLE
		FOREACH
			SELECT fechapago, tienda, importe, movimiento, tipomovimiento, numeromovs, empresa, fecha_concil
			INTO   dFechapago, cTienda, iImporte, cMovimiento, cTipomovimiento, iNumMovs, cEmpresa, dfecha_carga2
			FROM   bdisac:"informix".sac_conciliacion_cifras
			WHERE  nombre_archivo = cNombreCifras
			
				--Para cada elemento busco la agrupacion en la tabla 'sac_conciliacion_bcpl_cpl'
				SELECT SUM(importe), COUNT(importe)
				INTO   iImporte2, iNumMovs2
				FROM   bdisac:"informix".sac_conciliacion_bcpl_cpl
				WHERE  fecha_insert  	= dfecha_carga2
				AND    fechapago      	= dFechapago
				AND    tienda         	= cTienda
				AND    movimiento 		= cMovimiento
				AND    tipomovimiento 	= cTipomovimiento
				AND    empresa 			= cEmpresa;
				--GROUP BY fechapago, tienda, movimiento, tipomovimiento, empresa;
				
				--Valido que el importe y la cuenta sean iguales
				IF iImporte != iImporte2 THEN
					LET cCodRet = '00007';
					LET cMensaje = 'EL ARCHIVO DE DETALLE NO COINCIDE EN TOTALES CON EL ARCHIVO DE CIFRAS';
					EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje2, "sp_cargaarchivoaconciliacionbcpl");
					DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
					WHERE  nombre_archivo = cNombrearch;
					DELETE FROM bdisac:"informix".sac_conciliacion_cifras
					WHERE  nombre_archivo = cNombreCifras;
					RETURN cCodRet, cMensaje;
				END IF;
				
				IF iNumMovs != iNumMovs2 THEN
					LET cCodRet = '00007';
					LET cMensaje = 'EL ARCHIVO DE DETALLE NO COINCIDE EN TOTALES CON EL ARCHIVO DE CIFRAS';
					EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje2, "sp_cargaarchivoaconciliacionbcpl");
					DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
					WHERE  nombre_archivo = cNombrearch;
					DELETE FROM bdisac:"informix".sac_conciliacion_cifras
					WHERE  nombre_archivo = cNombreCifras;
					RETURN cCodRet, cMensaje;
				END IF;
			
			
		END FOREACH;
		
		--AHORA REVISO DETALLE VS CIFRAS
		FOREACH
			SELECT fechapago, tienda, SUM(importe), movimiento, tipomovimiento, COUNT(importe), empresa, fecha_insert
			INTO   dFechapago, cTienda, iImporte, cMovimiento, cTipomovimiento, iNumMovs, cEmpresa, dfecha_carga2
			FROM   bdisac:"informix".sac_conciliacion_bcpl_cpl
			WHERE  fecha_insert  	= TODAY
			GROUP BY fechapago, tienda, movimiento, tipomovimiento, empresa, fecha_insert
			
				--Para cada elemento busco la agrupacion en la tabla 'sac_conciliacion_bcpl_cpl'
				SELECT NVL(importe,0), NVL(numeromovs,0)
				INTO   iImporte2, iNumMovs2
				FROM   bdisac:"informix".sac_conciliacion_cifras
				WHERE  fecha_concil  	= dfecha_carga2
				AND    fechapago      	= dFechapago
				AND    tienda         	= cTienda
				AND    movimiento 		= cMovimiento
				AND    tipomovimiento 	= cTipomovimiento
				AND    empresa 			= cEmpresa;
				
				--Valido que el importe y la cuenta sean iguales
				IF iImporte != iImporte2 THEN
					LET cCodRet = '00008';
					LET cMensaje = 'EL ARCHIVO DE CIFRAS NO COINCIDE EN TOTALES CON EL ARCHIVO DE DETALLE';
					EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje2, "sp_cargaarchivoaconciliacionbcpl");
					DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
					WHERE  nombre_archivo = cNombrearch;
					DELETE FROM bdisac:"informix".sac_conciliacion_cifras
					WHERE  nombre_archivo = cNombreCifras;
					RETURN cCodRet, cMensaje;
				END IF;
				
				IF iNumMovs != iNumMovs2 THEN
					LET cCodRet = '00008';
					LET cMensaje = 'EL ARCHIVO DE CIFRAS NO COINCIDE EN TOTALES CON EL ARCHIVO DE DETALLE';
					EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(cCodRet, iIsamErr, cMensaje2, "sp_cargaarchivoaconciliacionbcpl");
					DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
					WHERE  nombre_archivo = cNombrearch;
					DELETE FROM bdisac:"informix".sac_conciliacion_cifras
					WHERE  nombre_archivo = cNombreCifras;
					RETURN cCodRet, cMensaje;
				END IF;
			
			
		END FOREACH;
		--BORRO LOS REGISTROS QUE APARECIERON DUPLICADOS Y FUERON MARCADOS CON CONCILIADO = 2 EN EL ARCHIVO
		DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
		WHERE  nombre_archivo = cNombrearch
		AND    st_conciliado  = 2;
       
		--TERMINA EXITOSO
        RETURN cCodRet, cMensaje;
    END;

END PROCEDURE;