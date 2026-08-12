CREATE PROCEDURE "informix".sp_constit_precan(pEmpresa CHAR(3),
											  pNumCte CHAR(20),												 
											  pNumCredito CHAR(20),
											  pNumTarjeta CHAR(20)) 
--DATOS A REGRESAR---												 
	RETURNING
	CHAR(6)      AS cCodRet,
	CHAR(20) 	 AS cNumCte,
	CHAR(26) 	 AS cNombre1,
	CHAR(26) 	 AS cNombre2,
	CHAR(26) 	 AS cApPaterno,
	CHAR(26) 	 AS cApMaterno,
	CHAR(20) 	 AS cNumCredito,
	CHAR(20) 	 AS cNumTarjeta,
	CHAR(4) 	 AS cNumProducto,
	CHAR(1) 	 AS cTipoTarjeta,
	CHAR(1) 	 AS cStatusTarjeta,
	CHAR(4)		 AS cFechaExp;
	
---DECLARACIONES
DEFINE iSqlErr         	 INTEGER;
DEFINE cCodRet         	 CHAR(6);
DEFINE cNumCte        	 CHAR(20);
DEFINE cNumCteAux        CHAR(20);
DEFINE cNombre1        	 CHAR(26);
DEFINE cNombre2       	 CHAR(26);
DEFINE cApPaterno        CHAR(26);
DEFINE cApMaterno        CHAR(26);
DEFINE cNumCredito       CHAR(20);
DEFINE cNumTarjeta       CHAR(20);
DEFINE cNumProducto      CHAR(4);
DEFINE cFechaExp	     CHAR(4);
DEFINE cTipoTarjeta      CHAR(1);
DEFINE cStatusTarjeta    CHAR(1);
DEFINE sSecuencia		 SMALLINT;

---INICIALIZACIONES
LET iSqlErr           = 0;
LET cCodRet           = "000000";
LET cNumCte           = "";
LET cNumCteAux		  = "";
LET cNombre1          = "";
LET cNombre2          = "";
LET cApPaterno        = "";
LET cApMaterno        = "";
LET cNumCredito       = "";
LET cNumTarjeta       = "";
LET cNumProducto      = "";
LET cTipoTarjeta      = "";
LET cStatusTarjeta    = "";
LET cFechaExp   	  = "";
LET sSecuencia		  = 0;

BEGIN
    ON EXCEPTION SET iSqlErr	
	IF 	iSqlErr <> 0 THEN
		LET cCodRet = iSqlErr;
		RETURN cCodRet,cNumCte,cNombre1,cNombre2,cApPaterno,cApMaterno,cNumCredito,cNumTarjeta,cNumProducto,cTipoTarjeta,cStatusTarjeta,cFechaExp;
	END IF
END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 4;

	--SET DEBUG FILE TO "/home/tmp/jairo/sp_constit_precan.out";
	--TRACE ON;
	
	IF NVL(pEmpresa,'') = "" THEN	
		LET cCodRet = "000458"; --PARAMETROS VACIOS
		RETURN cCodRet,cNumCte,cNombre1,cNombre2,cApPaterno,cApMaterno,cNumCredito,cNumTarjeta,cNumProducto,cTipoTarjeta,cStatusTarjeta,cFechaExp;			
	ELSE			
		IF NVL(pNumCte,'') = "" THEN			
				IF NVL(pNumCredito,'') <> "" AND  NVL(pNumTarjeta,'') = "" THEN
					
					SELECT tar.num_credito, tar.numcte, tar.num_tarjeta,tjt.fechaexp
					INTO  cNumCredito, cNumCte, cNumTarjeta,cFechaExp 
					FROM  bdicred:"informix".sd_tarjeta tar,
						  bdicred:"informix".sd_maecred	mae,
						   intercard:"informix".tarjeta tjt
						   
					WHERE mae.empresa = pEmpresa
					AND tar.num_credito = mae.num_credito
					AND mae.num_credito = pNumCredito
					AND tjt.numtarjeta = tar.num_tarjeta;
				
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodRet = "001062";
						RETURN  cCodRet,cNumCte,cNombre1,cNombre2,cApPaterno,cApMaterno,cNumCredito,cNumTarjeta,cNumProducto,cTipoTarjeta,cStatusTarjeta,cFechaExp;
					END IF;
				
				ELIF NVL(pNumCredito,'') = "" AND  NVL(pNumTarjeta,'') <> "" THEN
					
					SELECT tar.num_credito, tar.num_tarjeta, tar.numcte,tjt.fechaexp
					INTO  cNumCredito, cNumTarjeta, cNumCte,cFechaExp 
					FROM  bdicred:"informix".sd_tarjeta tar,
						  bdicred:"informix".sd_maecred	mae,
						   intercard:"informix".tarjeta tjt
						   
					WHERE tar.empresa = pEmpresa
					AND tar.num_tarjeta = pNumTarjeta
					AND tar.numcte = mae.numcte
					AND tar.num_credito = mae.num_credito
					AND tar.tipo_tarjeta = "T"
					AND tar.status_tar = "A"
					AND tjt.numtarjeta = tar.num_tarjeta;
					
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodRet = "000545";
						RETURN  cCodRet,cNumCte,cNombre1,cNombre2,cApPaterno,cApMaterno,cNumCredito,cNumTarjeta,cNumProducto,cTipoTarjeta,cStatusTarjeta,cFechaExp;
					END IF;
					
				ELIF NVL(pNumCredito,'') = "" AND NVL(pNumTarjeta,'') = "" THEN
				
						LET cCodRet = "000458";
						RETURN  cCodRet,cNumCte,cNombre1,cNombre2,cApPaterno,cApMaterno,cNumCredito,cNumTarjeta,cNumProducto,cTipoTarjeta,cStatusTarjeta,cFechaExp;					
				END IF;
		ELIF NVL(pNumCte,'') <> "" THEN
		
			SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno
			INTO cNumCteAux, cNombre1, cNombre2, cApPaterno, cApMaterno 
			FROM bdinteg:"informix".si_cliente
			WHERE empresa = pEmpresa
			AND numcte = pNumCte;
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = "000002"; --NO SE ENCONTRO INFORMACION
				RETURN  cCodRet,cNumCte,cNombre1,cNombre2,cApPaterno,cApMaterno,cNumCredito,cNumTarjeta,cNumProducto,cTipoTarjeta,cStatusTarjeta,cFechaExp;
			END IF;
		
				IF NVL(pNumCredito,'') = "" AND NVL(pNumTarjeta,'') = "" THEN
			
						SELECT tar.num_credito, tar.num_tarjeta, tar.numcte,tjt.fechaexp
						INTO  cNumCredito, cNumTarjeta, cNumCte,cFechaExp 
						FROM  bdicred:"informix".sd_tarjeta tar,
							  bdicred:"informix".sd_maecred	mae,
							  intercard:"informix".tarjeta tjt
							  
						WHERE mae.empresa = pEmpresa
						AND mae.numcte = pNumCte
						AND tar.numcte = mae.numcte
						AND tar.num_credito = mae.num_credito
						AND tar.tipo_tarjeta = "T"
						AND tar.status_tar = "A"
						AND tjt.numtarjeta = tar.num_tarjeta;

						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = "001062"; --NO SE ENCONTRO INFORMACION
							RETURN  cCodRet,cNumCte,cNombre1,cNombre2,cApPaterno,cApMaterno,cNumCredito,cNumTarjeta,cNumProducto,cTipoTarjeta,cStatusTarjeta,cFechaExp;
						END IF;
				ELSE
				
					LET cCodRet = "000458";
					RETURN  cCodRet,cNumCte,cNombre1,cNombre2,cApPaterno,cApMaterno,cNumCredito,cNumTarjeta,cNumProducto,cTipoTarjeta,cStatusTarjeta,cFechaExp;
				
				END IF;
		END IF;
		
		SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno
		INTO cNumCteAux, cNombre1, cNombre2, cApPaterno, cApMaterno 
		FROM bdinteg:"informix".si_cliente
		WHERE empresa = pEmpresa
		AND numcte = cNumCte;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = "001062"; --NO SE ENCONTRO INFORMACION
			RETURN  cCodRet,cNumCte,cNombre1,cNombre2,cApPaterno,cApMaterno,cNumCredito,cNumTarjeta,cNumProducto,cTipoTarjeta,cStatusTarjeta,cFechaExp;
		END IF;
			
		SELECT tar.secuencia, tar.tipo_tarjeta, tar.status_tar, mae.num_producto
		INTO  sSecuencia, cTipoTarjeta, cStatusTarjeta, cNumProducto
		FROM  bdicred:"informix".sd_tarjeta tar,
			  bdicred:"informix".sd_maecred	mae
		WHERE tar.empresa = pEmpresa
		AND mae.num_credito = cNumCredito
		AND tar.numcte = cNumCte
		AND tar.secuencia = (SELECT MAX(secuencia) 
							FROM bdicred:"informix".sd_tarjeta 
							WHERE empresa = pEmpresa 
							AND num_credito = cNumCredito);
		
		IF cTipoTarjeta = "T" THEN
		
			IF cNumCteAux <> cNumCte THEN
			
				IF pNumCte <> "" THEN
					LET cCodRet = "000134"; --CLIENTE NO TITULAR
					RETURN cCodRet,cNumCte,cNombre1,cNombre2,cApPaterno,cApMaterno,cNumCredito,cNumTarjeta,cNumProducto,cTipoTarjeta,cStatusTarjeta,cFechaExp;
				ELIF pNumTarjeta <> "" THEN
					LET cCodRet = "000524"; --TARJETA NO TITULAR
					RETURN cCodRet,cNumCte,cNombre1,cNombre2,cApPaterno,cApMaterno,cNumCredito,cNumTarjeta,cNumProducto,cTipoTarjeta,cStatusTarjeta,cFechaExp;
				END IF;
			
			ELSE
				IF cStatusTarjeta = "A" THEN
					LET cCodRet = "000000"; --TARJETA ACTIVA
					RETURN cCodRet,cNumCte,cNombre1,cNombre2,cApPaterno,cApMaterno,cNumCredito,cNumTarjeta,cNumProducto,cTipoTarjeta,cStatusTarjeta,cFechaExp;
				ELSE
					LET cCodRet = "000396"; --TARJETA NO ACTIVA
					RETURN cCodRet,cNumCte,cNombre1,cNombre2,cApPaterno,cApMaterno,cNumCredito,cNumTarjeta,cNumProducto,cTipoTarjeta,cStatusTarjeta,cFechaExp;
				END IF;
			
			END IF;
		
		ELIF cTipoTarjeta <> "T" THEN
		
			IF pNumCte <> "" THEN
				LET cCodRet = "000134"; --CLIENTE NO TITULAR
				RETURN cCodRet,cNumCte,cNombre1,cNombre2,cApPaterno,cApMaterno,cNumCredito,cNumTarjeta,cNumProducto,cTipoTarjeta,cStatusTarjeta,cFechaExp;
			ELIF pNumTarjeta <> "" THEN
					LET cCodRet = "000524"; --TARJETA NO TITULAR
					RETURN cCodRet,cNumCte,cNombre1,cNombre2,cApPaterno,cApMaterno,cNumCredito,cNumTarjeta,cNumProducto,cTipoTarjeta,cStatusTarjeta,cFechaExp;	
			END IF;
		
		END IF;
	
	END IF;
END;
END PROCEDURE
DOCUMENT
'Folio:1740',
'Autor:95975071 Jairo Valdez Gonzalez',
'Fecha:06/05/2015',
'Modificación: Se requiere crear un procedimiento almacenado para validar si el cliente consultado por número de cliente',
'			   número de crédito o número de tarjeta pertenece a un Cliente Titular y la tarjeta se encuentra como Activa.',
'Sustento: RQM 10 453 Disminución de línea campaña pre-cancelación vía Suc.odt ',
'Solicita: Paul Ivan Quintero Varela',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_consulta_info_disminucion(pEmpresa CHAR(3),pNumCredito CHAR(12))
--DATOS A REGRESAR---
RETURNING CHAR(6) AS cCodRet, INTEGER AS iEstatus, CHAR(100) AS cEstatus;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet 		CHAR(6);
DEFINE  iEstatus		INTEGER;
DEFINE  cEstatus		CHAR(100);
DEFINE  cFecha			CHAR(25);
DEFINE	sIndicador		SMALLINT;
DEFINE	dcMonto			DECIMAL(18,2);
DEFINE  iSqlErr			INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet 		= '000000';
LET cEstatus		= '';
LET cFecha			= '';
LET iEstatus		= 0;
LET sIndicador		= 0;
LET dcMonto			= 0.0;
LET iSqlErr			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,iEstatus,cEstatus;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/tmp/jairo/sp_consulta_info_disminucion.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 4;

	IF NVL(pEmpresa,'') <> '' AND NVL(pNumCredito,'') <> '' THEN
		SELECT MAX(fecha_insert),indicador INTO cFecha,sIndicador FROM bdicred:"informix".sd_disminucion_linea_precan
		WHERE empresa = pEmpresa AND num_credito = pNumCredito
		AND fecha_insert = (SELECT MAX(fecha_insert) FROM bdicred:"informix".sd_disminucion_linea_precan
		WHERE empresa = pEmpresa AND num_credito = pNumCredito)
		GROUP BY indicador;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '001062';
			RETURN cCodRet,iEstatus,cEstatus;
		END IF;

		SELECT monto_otorgado INTO dcMonto FROM bdicred:"informix".sd_maesdos
		WHERE empresa = pEmpresa AND num_credito = pNumCredito;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '001062';
			RETURN cCodRet,iEstatus,cEstatus;
		END IF;

		IF NVL(sIndicador,0) = 1 AND NVL(dcMonto,0) = 1 THEN
			LET iEstatus = 1;
			SELECT valor INTO cEstatus FROM bdicred:"informix".sd_param
			WHERE empresa = pEmpresa AND cod_param = '166';

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodret = '001062';
			END IF;
		ELIF NVL(sIndicador,0) = 0 AND NVL(dcMonto,0) <> 1 THEN
			LET iEstatus = 0;
			SELECT valor INTO cEstatus FROM bdicred:"informix".sd_param
			WHERE empresa = pEmpresa AND cod_param = '165';

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodret = '001062';
			END IF;
		END IF;
	ELSE
		LET cCodRet ='000458';
	END IF
	RETURN cCodRet,iEstatus,cEstatus;
END;
END PROCEDURE
DOCUMENT
'000000-0 - Precancelada por Inactividad',
'000000-1 - Tarjeta Activa ',
'000458-0 - Parametros Vacios',
'001062-0 - Consulta sin Datos',
'DESCRIPCION: Se crea sp para consultar la información de un cliente que se encuentre en proceso de Pre-Cancelación',
'AUTOR : jairo valdez',
'Folio:1740',
'Solicita: Salvador Cota',
'FECHA : 07/08/2015',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_reactivar_lincred(pEmpresa CHAR(3),pNumCredito CHAR(12))
--DATOS A REGRESAR---
RETURNING CHAR(6) AS cCodRet, CHAR(10) AS cFolio, DECIMAL(18,2) AS dcMonto;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet 	CHAR(6);
DEFINE  cFolio		CHAR(10);
DEFINE  cFecha		CHAR(25);
DEFINE  cHoraMin	CHAR(8);
DEFINE	dcMonto		DECIMAL(18,2);
DEFINE  iSqlErr		INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet 	= '000000';
LET cFolio		= '';
LET cFecha		= '';
LET cHoraMin	= '';
LET dcMonto		= 0.00;
LET iSqlErr		= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,cFolio,dcMonto;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/tmp/jairo/sp_reactivar_lincred.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 4;

	IF NVL(pEmpresa,'') <> '' AND NVL(pNumCredito,'') <> '' THEN		
		SELECT MAX(fecha_insert),linea_anterior INTO cFecha,dcMonto FROM bdicred:"informix".sd_disminucion_linea_precan
		WHERE empresa = pEmpresa AND num_credito = pNumCredito AND indicador = 1
		AND fecha_insert = (SELECT MAX(fecha_insert) FROM bdicred:"informix".sd_disminucion_linea_precan
		WHERE empresa = pEmpresa AND num_credito = pNumCredito)
		GROUP BY linea_anterior;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '001062';
			RETURN cCodRet,cFolio,dcMonto;
		END IF;
			
		UPDATE bdicred:"informix".sd_maesdos
		SET monto_otorgado = dcMonto
		WHERE empresa = pEmpresa AND num_credito = pNumCredito;
		
		SELECT FIRST 1 CURRENT HOUR TO MINUTE INTO cHoraMin FROM "informix".systables;
		LET cHoraMin =  REPLACE(cHoraMin,':','');		
		LET cFolio = SUBSTR(pNumCredito,7,6);	
		LET cFolio = TRIM(cFolio) || TRIM(cHoraMin);		
		
		UPDATE bdicred:"informix".sd_disminucion_linea_precan
		SET indicador = 0, folio = cFolio
		WHERE empresa = pEmpresa AND num_credito = pNumCredito AND indicador = 1;		
	ELSE
		LET cCodRet ='000458';		
	END IF
	RETURN cCodRet,cFolio,dcMonto;
END;
END PROCEDURE
DOCUMENT
'000000 - Se reactivo el credito ',
'000458 - Parametros Vacios',
'001062 - Consulta sin Datos',
'DESCRIPCION: Se crea sp para consultar la información de un cliente que se encuentre en proceso de Pre-Cancelación',
'AUTOR : jairo valdez',
'Folio:1740',
'Solicita: Salvador Cota',
'FECHA : 07/08/2015',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_reactivacion_linea_tdc()
RETURNING   VARCHAR(6,1) 	AS retorno,
            VARCHAR(100,1)   AS mensaje_ret;

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(100,1);
DEFINE cCodRet      VARCHAR(6,1);
DEFINE cMensajeRet  VARCHAR(100,1);	

DEFINE vNumCred     VARCHAR(20,1);
DEFINE dLineaAnt    DECIMAL(18,2);

LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET cErrorInfo   = "";
LET cCodRet      = "000000";
LET cMensajeRet  = "EL PROCESO SE APLICO CORRECTAMENTE";

LET vNumCred     = "";
LET dLineaAnt    = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr , cErrorInfo
	LET cCodRet     = iSqlErr;
	LET cMensajeRet = cErrorInfo;  
	RETURN cCodRet, cMensajeRet;
END EXCEPTION;

--SET DEBUG FILE TO "/RESPALDOS/sp_reactivacion_linea_tdc.out";
--TRACE ON; 

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

FOREACH WITH HOLD
	SELECT num_credito, linea_anterior 
	  INTO vNumCred, dLineaAnt
	  FROM "informix".sd_disminucion_linea_precan

		BEGIN;
			UPDATE "informix".sd_maesdos SET monto_otorgado = dLineaAnt WHERE empresa = '001' AND num_credito = vNumCred AND monto_otorgado = 1;
		COMMIT;
		
END FOREACH

IF dbinfo("sqlca.sqlerrd2") = 0 THEN
	LET cCodRet     = "000001";
	LET cMensajeRet = "NO HAY REGISTROS POR ACTUALIZAR";  
	RETURN cCodRet, cMensajeRet;
END IF;

RETURN cCodRet, cMensajeRet; 
END;
END PROCEDURE
DOCUMENT
"Se crea procedimiento para reactivar las líneas de los clientes",
"BASE DE DATOS: BDICRED",
"AUTOR : Paul Ivan Quintero Varela",
"FECHA : 10/FEB/2016";

CREATE PROCEDURE "informix".sp_camp_primer_uso(pempresa CHAR(3))
RETURNING CHAR(6);

--Creado: MAHR. Mayo 2012. Campaña de Primer uso. Campañas dirigidas a los clientes que no han realizad operaciones con su tarjeta de credito entregada.
-- Subcampaña: 2 LlamadaBienvenida, 3 CorreoDirecto, 4 CrediEfectivo, 5 Recomprensa, 6 LlamadaPreCanc, 7 PreCanc-1erBim, 8 PreCanc-2doBim, 
--  9 Ctas_por_cancelar, 10 cierre de numeros de campaña 9.


--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE iGenero_info         INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE vempresa				CHAR(3);
DEFINE vproceso				CHAR(4);
DEFINE cempresa             CHAR(3);
DEFINE cCod_RetIB           CHAR(6);
DEFINE dFechaHoy            DATE;
DEFINE dFecha_1_anio        DATE;
DEFINE sDia5_correcamp      SMALLINT;
DEFINE sDia21_correcamp     SMALLINT;
DEFINE sMessinactAnt        SMALLINT;
DEFINE cdelimitador         CHAR(1);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoejecsql   CHAR(100);
DEFINE cSQL                 CHAR(2500);
DEFINE cSQL1                CHAR(1000);
DEFINE cSQL2                CHAR(1000);
DEFINE cSQL3                CHAR(500);


--SET DEBUG FILE TO "/informix/gpe/sp_camp_primer_uso.out";
--TRACE ON;

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET iGenero_info            = 0;
LET error_info              = '';
LET cCod_Ret                = '000000';
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0600';
LET vempresa				= '001';
LET cempresa                = '';
LET cCod_RetIB              = '000000';
LET dFechaHoy               = DATE(1);
LET dFecha_1_anio           = DATE(1);
LET sDia5_correcamp         = 0; 
LET sDia21_correcamp        = 0; 
LET sMessinactAnt           = 0;
--LET iNum_tarjetas_ent       = 0;
LET cdelimitador            = '';
LET cruta                   = '';
LET cnombre                 = '';
LET cnomarchivo             = '';
LET cnomarchivo1			= '';
LET cnomarchivoejecsql      = '';
LET cSQL                    = '';
LET cSQL1                   = '';
LET cSQL2                   = '';
LET cSQL3                   = '';

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        RETURN cCod_ret;
	END EXCEPTION;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '01') Returning cCod_RetIB;

    -- Validacion de parámetros de entrada
    IF NVL(pEmpresa,"") = "" THEN
        LET cCod_Ret= '104001';
        SELECT descripcion INTO cMensaje 
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        RETURN cCod_Ret;
	END IF;

	--Validación de la empresa
	SELECT empresa INTO cempresa
	FROM bdinteg:si_empresas WHERE empresa = pempresa;
	IF NVL (cempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        SELECT descripcion INTO cMensaje 
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN LET cMensaje = "";  END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

    -- Obtiene los dias en que se ejecuta este proceso para asignar el aviso correspondiente
    SELECT TRIM(valor_alfabetico)::SMALLINT, valor_numerico::SMALLINT INTO sDia5_correcamp, sDia21_correcamp
        FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 12;
    IF (NVL(sDia5_correcamp,0) = 0 OR NVL(sDia21_correcamp,0) = 0 ) THEN
        LET cCod_Ret= '104001';
        SELECT descripcion INTO cMensaje 
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN LET cMensaje = "";  END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        Return cCod_Ret;
    END IF;

    -- Obtiene la fecha del dia de hoy
   SELECT fecha_hoy INTO dFechaHoy FROM bdinteg:"informix".si_fechas WHERE empresa = pempresa;
	
    -- Campaña 2: LlamadaBienvenida: Se ejecuta dia 5 del mes
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN    

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch(vempresa, '02', 1, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;
    END IF;

   -- Campaña 3:  CorreoDirecto    Se ejecuta el dia 21 (despues del corte) de cada mes.
 IF (DAY(dFechaHoy) = sDia21_correcamp) OR (DAY(dFechaHoy) = sDia21_correcamp - 1) THEN   

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 14;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch(vempresa, '03', sMessinactAnt, dFechaHoy) Returning cCod_RetIB;

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;                    
    END IF;

   -- Campaña 4: CrediEfectivo     Se ejecuta dia 5 del mes
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 15;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch(vempresa, '04', sMessinactAnt, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;                    
    END IF;

    -- Campaña 5: Recomprensa       Se ejecuta los dias 21 de cada mes.
   IF (DAY(dFechaHoy) = sDia21_correcamp) OR (DAY(dFechaHoy) = sDia21_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 16;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch(vempresa, '05', sMessinactAnt, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;
    END IF;

    -- Campaña 6: Llamada de precancelacion     Se ejecuta dia 5 del mes
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 17;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch (vempresa, '06', sMessinactAnt, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero información y se creara el reporte de seguimiento
        END IF;
    END IF;

    -- Campaña 7: Seguimiento 1er Bimestre Pre-Cancelacion.
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 27;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch (vempresa, '07', sMessinactAnt, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;
    END IF;

    -- Campaña 8: Seguimiento 2do Bimestre Pre-Cancelacion.
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 37;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch (vempresa, '08', sMessinactAnt, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;
    END IF;

    -- Campaña 9: Cuentas por cancelar
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 38;

        CALL bdicred:"informix".sp_camp_primer_uso_crea_arch (vempresa, '09', sMessinactAnt, dFechaHoy) Returning cCod_RetIB; 

        IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;
    END IF;

    -- Campaña 10: Cierre de cifras de campaña 9: Cuentas por cancelar, y genera de reporte de cuentas canceladas.
    IF (DAY(dFechaHoy) = sDia5_correcamp) OR (DAY(dFechaHoy) = sDia5_correcamp - 1) THEN

        SELECT valor_numerico::SMALLINT INTO sMessinactAnt 
            FROM bdicred:"informix".sd_param_campania WHERE grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 39;

        CALL bdicred:"informix".sp_camp_primer_uso_cierra9a10RepCanc (vempresa, '10', 0, dFechaHoy) Returning cCod_RetIB; 

         IF cCod_RetIB = '000000' THEN
            LET iGenero_info = 1;  -- Se genero informacion y se creara el reporte de seguimiento
        END IF;
    END IF;

    -- GENERA REPORTE DE SEGUIMIENTO DE LAS CAMPAÑAS
    IF iGenero_info = 1 THEN
                --Obtener caracter delimitador
        SELECT trim(valor_alfabetico) INTO cdelimitador FROM bdicobranza:"informix".cb_param_campania WHERE empresa = pempresa
            AND tipo_campania = 1 AND grupo_parametro = 'ARCHIVOS' AND num_parametro = 26;
        IF NVL(cDelimitador,'') = '' THEN
            LET cCod_Ret= '104004';
            SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
            IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
            RETURN cCod_Ret;
        END IF;

        -- Obtiene la ruta del archivo
        SELECT TRIM(valor_alfabetico) INTO cruta FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
            AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 1; 
    	IF NVL (cruta,'') = '' THEN
            LET cCod_Ret= '104005';
            SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
            IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
            RETURN cCod_Ret;
        END IF;

    	-- Obtiene el nombre del archivo con el reporte de seguimiento.
        SELECT TRIM(valor_alfabetico) INTO cnombre FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
            AND grupo_parametro = 'ARCH1ERUSO' AND num_parametro = 24; 
        IF NVL (cnombre,'') = '' THEN
            LET cCod_Ret= '102002';
            SELECT descripcion INTO cMensaje FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
            IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
            RETURN cCod_Ret;
    	END IF;

        -- Asigna nombre de archivo, segun el nombre asignado en el parametro y la fecha correspondiente
        LET cnomarchivo1 =  trim(cnombre)||'Aux'||substr(year(dFechaHoy),3)||to_char(dFechaHoy,'%m%d')||'.txt';
        LET cnomarchivo  =  trim(cnombre)||substr(year(dFechaHoy),3)||to_char( dFechaHoy,'%m%d')||'.txt';
        LET cnomarchivoejecsql = 'Ejecuta_rep_seguim_1er_uso.sql';

        LET cSql='';
        LET cSql = 'echo "fecha_campaña'||';'||'entregadas desde'||';'||'entregadas hasta'||';'||'nombre campaña'||';'||'tarjetas entregadas'
                         ||';'||'tarjetas_con_telefono'||';'||'tarjetas_sin_telefono'||';'||'tarjetas_activas_con_telefono'
						 ||';'||'tarjetas_activas_sin_telefono'||';'||'tarjetas_inactivas_con_telefono'||';'||'tarjetas_inactivas_sin_telefono'
						 ||';'||'tarjetas_actcontel_canceladas'||';'||'tarjetas_actsintel_canceladas'||';'||'tarjetas_inactcontel_canceladas'||';'||'tarjetas_inactsintelcanceladas'
						 || ' " >' ||TRIM(cruta)|| cnomarchivo;
        System csql;

        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
        --LET dFecha_1_anio = dFechaHoy - 2 units year;
		

        LET cSQL2 = " SELECT fecha_gen_campania, fecha_entreg_desde, fecha_entreg_hasta, trim(param.valor_alfabetico), tot_tarj_entreg_ina, "
                || " tot_tarj_contel,tot_tarj_sintel, tot_tarj_activas_contel, "
				|| " tot_tarj_activas_sintel,tot_tarj_inactivas_contel, tot_tarj_inactivas_sintel, "
				|| " tot_tarj_act_contel_canceladas,tot_tarj_act_sintel_canceladas,tot_tarj_inact_contel_canceladas,tot_tarj_inact_sintel_canceladas "
                || " FROM bdicred:cb_1eruso_rep_seguim seguim, bdicred:sd_param_campania param "
                || " WHERE param.grupo_parametro = 'ARCH1ERUSO' AND param.num_parametro in (18, 19, 20, 21, 22, 23, 40, 41, 42) "
                || " AND seguim.sub_campania = param.valor_numerico "
                || " AND seguim.fecha_gen_campania >= mdy(12,05,2015) "
                || " ORDER BY seguim.fecha_gen_campania, seguim.fecha_ejecucion, seguim.sub_campania ";

        LET cSQL3 = '">'||TRIM(cRuta)|| cnomarchivoejecsql;
        LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
        System cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoejecsql;
        System cSQL;

        let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || cnomarchivoejecsql;
        System cSQL;

        LET cSql = cSql;
        LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
        SYSTEM cSql;

    	LET cSQL = '' ;
    	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || ' ' || TRIM(cruta) || cnomarchivo1  ; 
        SYSTEM cSQL;

    END IF;

    -- Valida si existen las tablas temporales y las borra.
    IF EXISTS( SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'sd_temp_1er_uso_telef' ) THEN
        DROP TABLE bdicred:sd_temp_1er_uso_telef;
    END IF;
 
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '03')
        Returning cCod_RetIB;

	RETURN cCod_ret;

END;
END PROCEDURE;