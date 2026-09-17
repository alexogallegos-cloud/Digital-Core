CREATE PROCEDURE "informix".sp_actualizar_registros_indicadores()
RETURNING
	CHAR(6),
	CHAR(80)

	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
	DEFINE cDescRet			CHAR(80);
	
	DEFINE iUnTercio		INT8;
	DEFINE cCuenta			CHAR(20);

	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	LET cDescRet			= "PROCESO EXITOSO";

	LET iUnTercio			= 0;
	LET cCuenta				= "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescRet = cErrorInfo;
			RETURN cCodRet, cDescRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/informix/moha/sp_actualizar_registros_indicadores.out';
	--TRACE ON;

	UPDATE "informix".sc_param
	SET valor = ""
	WHERE empresa = "001"
	AND codparam IN ("CtaInsRegIndic_uno","CtaInsRegIndic_dos");
	
	SELECT (COUNT(*)) / 3
	INTO iUnTercio
	FROM "informix".sc_indicadores
	WHERE cuenta >= "10000005016"
	AND anio_mes = "201407";
	
	FOREACH
		SELECT SKIP iUnTercio LIMIT 1 cuenta
		INTO cCuenta
		FROM "informix".sc_indicadores
		WHERE cuenta >= "10000005016"
		AND anio_mes = "201407"
	
	END FOREACH
	
	UPDATE "informix".sc_param
	SET valor = cCuenta
	WHERE empresa = "001"
	AND codparam = 'CtaInsRegIndic_uno';
	
	LET cCuenta = "";
	
	LET iUnTercio = iUnTercio * 2;
	
	FOREACH
		SELECT SKIP iUnTercio LIMIT 1 cuenta
		INTO cCuenta
		FROM "informix".sc_indicadores
		WHERE cuenta >= "10000005016"
		AND anio_mes = "201407"
	
	END FOREACH
	
	UPDATE "informix".sc_param
	SET valor = cCuenta
	WHERE empresa = "001"
	AND codparam = "CtaInsRegIndic_dos";
	
	RETURN cCodRet, cDescRet;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obetener los rangos de las ctas para posteriormente ejecutar tres procesos en paralelo.',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Julio 2014';

CREATE PROCEDURE "informix".sp_actualizar_registros_indicadores_1()
RETURNING
	CHAR(6),
	CHAR(80)

	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
	DEFINE cDescRet			CHAR(80);
	DEFINE vabierto     	CHAR(1);
	DEFINE vcontador3   	INTEGER;
	DEFINE cCodRetMesSig	CHAR(5);
	DEFINE iDiasTransc		INTEGER;

	DEFINE cCuenta			CHAR(20);
	DEFINE dtMesiversario	DATE;
	DEFINE dtFechaApertura	DATE;
	DEFINE cCuentaRangoUno	CHAR(20);
	DEFINE dtFechaDepOrig	DATE;
	DEFINE dImporteDepOrig	DECIMAL(14,2);
	DEFINE cNumCte			CHAR(20);
	DEFINE iIdStatus		SMALLINT;
	DEFINE iInternet		SMALLINT;

	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	LET cDescRet			= "PROCESO EXITOSO";
	LET vabierto   			= '0';
	LET vcontador3 			= 0;

	LET cCuenta				= "";
	LET dtMesiversario		= DATE(1);
	LET cCodRetMesSig		= "00000";
	LET iDiasTransc			= 0;
	LET dtFechaApertura		= DATE(1);
	LET cCuentaRangoUno		= "";
	LET dtFechaDepOrig		= DATE(1);
	LET dImporteDepOrig		= 0.0;
	LET cNumCte				= "";
	LET iIdStatus			= 0;
	LET iInternet			= 0;


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescRet = cErrorInfo;
            IF vabierto = '1' THEN
                ROLLBACK WORK;
            END IF;
			RETURN cCodRet, cDescRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/informix/moha/sp_actualizar_registros_indicadores_1.out';
	--TRACE ON;
	
	SELECT valor
	INTO cCuentaRangoUno
	FROM "informix".sc_param
	WHERE empresa = "001"
	AND codparam = ("CtaInsRegIndic_uno");
	
	FOREACH WITH HOLD
		SELECT cuenta, fecha_apertura, fec_prim_deposito_orig, imp_prim_deposito_orig
		INTO cCuenta, dtFechaApertura, dtFechaDepOrig, dImporteDepOrig
		FROM "informix".sc_indicadores
		WHERE anio_mes = "201407"
		AND cuenta < cCuentaRangoUno
		
		IF vcontador3 = 0 THEN
			BEGIN WORK;
			LET vabierto = '1'; 
		END IF

		LET cNumCte				= "";
		LET iIdStatus			= 0;
		LET iInternet			= 0;
		
		EXECUTE PROCEDURE "informix".sp_mes_siguiente(TODAY, 1, DAY(dtFechaApertura - 1 UNITS DAY))
		INTO cCodRetMesSig, dtMesiversario, iDiasTransc;
		
		SELECT num_cte
		INTO cNumCte
		FROM "informix".sc_maechq
		WHERE empresa = "001" AND cuenta = cCuenta;
		
		SELECT id_status
		INTO iIdStatus
		FROM bdinteg: "informix".si_bpiusuarios 
		WHERE empresa = "001" AND numcte = cNumCte;
		
		IF iIdStatus IS NOT NULL AND iIdStatus <> 99 THEN
			LET iInternet = 1;
		END IF
		
		UPDATE "informix".sc_indicadores
		SET fecha_mesiversario = dtMesiversario, fec_prim_deposito_orig = dtFechaDepOrig, imp_prim_deposito_orig = dImporteDepOrig, internet = iInternet
		WHERE anio_mes = "201408"
		AND cuenta = cCuenta;
		
		LET vcontador3 = vcontador3 + 1;
		
		IF vcontador3 = 5000 THEN
			LET vabierto = '0';
			LET vcontador3 = 0;
			COMMIT WORK;
		END IF
	END FOREACH

	IF vcontador3 > 0 THEN
		COMMIT WORK;
	END IF	
	
	RETURN cCodRet, cDescRet;
    	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para insertar el registro de cada cuenta de los indicadores de captación para el mes actual',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Julio 2014';

CREATE PROCEDURE "informix".sp_actualizar_registros_indicadores_2()
RETURNING
	CHAR(6),
	CHAR(80)

	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
	DEFINE cDescRet			CHAR(80);
	DEFINE vabierto     	CHAR(1);
	DEFINE vcontador3   	INTEGER;
	DEFINE cCodRetMesSig	CHAR(5);
	DEFINE iDiasTransc		INTEGER;

	DEFINE cProducto		CHAR(4);
	DEFINE cCuenta			CHAR(20);
	DEFINE cSucursal		CHAR(4);
	DEFINE dtMesiversario	DATE;
	DEFINE dtFechaApertura	DATE;
	DEFINE cCuentaRangoUno	CHAR(20);
	DEFINE cCuentaRangoDos	CHAR(20);
	DEFINE dtFechaDepOrig	DATE;
	DEFINE dImporteDepOrig	DECIMAL(14,2);
	DEFINE cNumCte			CHAR(20);
	DEFINE iIdStatus		SMALLINT;
	DEFINE iInternet		SMALLINT;

	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	LET cDescRet			= "PROCESO EXITOSO";
	LET vabierto   			= '0';
	LET vcontador3 			= 0;

	LET cProducto			= "";
	LET cCuenta				= "";
	LET cSucursal			= "";
	LET dtMesiversario		= DATE(1);
	LET cCodRetMesSig		= "00000";
	LET iDiasTransc			= 0;
	LET dtFechaApertura		= DATE(1);
	LET cCuentaRangoUno		= "";
	LET cCuentaRangoDos		= "";
	LET dtFechaDepOrig		= DATE(1);
	LET dImporteDepOrig		= 0.0;
	LET cNumCte				= "";
	LET iIdStatus			= 0;
	LET iInternet			= 0;


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescRet = cErrorInfo;
            IF vabierto = '1' THEN
                ROLLBACK WORK;
            END IF;
			RETURN cCodRet, cDescRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/informix/moha/sp_actualizar_registros_indicadores_2.out';
	--TRACE ON;
	
	SELECT valor
	INTO cCuentaRangoUno
	FROM "informix".sc_param
	WHERE empresa = "001"
	AND codparam = ("CtaInsRegIndic_uno");
	
	SELECT valor
	INTO cCuentaRangoDos
	FROM "informix".sc_param
	WHERE empresa = "001"
	AND codparam = ("CtaInsRegIndic_dos");
	
	FOREACH WITH HOLD
		SELECT cuenta, fecha_apertura, fec_prim_deposito_orig, imp_prim_deposito_orig
		INTO cCuenta, dtFechaApertura, dtFechaDepOrig, dImporteDepOrig
		FROM "informix".sc_indicadores
		WHERE anio_mes = "201407"
		AND cuenta >= cCuentaRangoUno AND cuenta <= cCuentaRangoDos
		
		IF vcontador3 = 0 THEN
			BEGIN WORK;
			LET vabierto = '1'; 
		END IF
		
		LET cNumCte				= "";
		LET iIdStatus			= 0;
		LET iInternet			= 0;

		EXECUTE PROCEDURE "informix".sp_mes_siguiente(TODAY, 1, DAY(dtFechaApertura - 1 UNITS DAY))
		INTO cCodRetMesSig, dtMesiversario, iDiasTransc;
		
		SELECT num_cte
		INTO cNumCte
		FROM "informix".sc_maechq
		WHERE empresa = "001" AND cuenta = cCuenta;
		
		SELECT id_status
		INTO iIdStatus
		FROM bdinteg: "informix".si_bpiusuarios 
		WHERE empresa = "001" AND numcte = cNumCte;
		
		IF iIdStatus IS NOT NULL AND iIdStatus <> 99 THEN
			LET iInternet = 1;
		END IF
		
		UPDATE "informix".sc_indicadores
		SET fecha_mesiversario = dtMesiversario, fec_prim_deposito_orig = dtFechaDepOrig, imp_prim_deposito_orig = dImporteDepOrig, internet = iInternet
		WHERE anio_mes = "201408"
		AND cuenta = cCuenta;
		
		LET vcontador3 = vcontador3 + 1;
		
		IF vcontador3 = 5000 THEN
			LET vabierto = '0';
			LET vcontador3 = 0;
			COMMIT WORK;
		END IF
	END FOREACH

	IF vcontador3 > 0 THEN
		COMMIT WORK;
	END IF	
	
	RETURN cCodRet, cDescRet;
    	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para insertar el registro de cada cuenta de los indicadores de captación para el mes actual',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Julio 2014';

CREATE PROCEDURE "informix".sp_actualizar_registros_indicadores_3()
RETURNING
	CHAR(6),
	CHAR(80)

	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
	DEFINE cDescRet			CHAR(80);
	DEFINE vabierto     	CHAR(1);
	DEFINE vcontador3   	INTEGER;
	DEFINE cCodRetMesSig	CHAR(5);
	DEFINE iDiasTransc		INTEGER;

	DEFINE cCuenta			CHAR(20);
	DEFINE dtMesiversario	DATE;
	DEFINE dtFechaApertura	DATE;
	DEFINE cCuentaRangoDos	CHAR(20);
	DEFINE dtFechaDepOrig	DATE;
	DEFINE dImporteDepOrig	DECIMAL(14,2);
	DEFINE cNumCte			CHAR(20);
	DEFINE iIdStatus		SMALLINT;
	DEFINE iInternet		SMALLINT;

	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	LET cDescRet			= "PROCESO EXITOSO";
	LET vabierto   			= '0';
	LET vcontador3 			= 0;

	LET cCuenta				= "";
	LET dtMesiversario		= DATE(1);
	LET cCodRetMesSig		= "00000";
	LET iDiasTransc			= 0;
	LET dtFechaApertura		= DATE(1);
	LET cCuentaRangoDos		= "";
	LET dtFechaDepOrig		= DATE(1);
	LET dImporteDepOrig		= 0.0;
	LET cNumCte				= "";
	LET iIdStatus			= 0;
	LET iInternet			= 0;


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescRet = cErrorInfo;
            IF vabierto = '1' THEN
                ROLLBACK WORK;
            END IF;
			RETURN cCodRet, cDescRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/informix/moha/sp_actualizar_registros_indicadores_3.out';
	--TRACE ON;
	
	SELECT valor
	INTO cCuentaRangoDos
	FROM "informix".sc_param
	WHERE empresa = "001"
	AND codparam = ("CtaInsRegIndic_dos");
	
	FOREACH WITH HOLD
		SELECT cuenta, fecha_apertura, fec_prim_deposito_orig, imp_prim_deposito_orig
		INTO cCuenta, dtFechaApertura, dtFechaDepOrig, dImporteDepOrig
		FROM "informix".sc_indicadores
		WHERE anio_mes = "201407"
		AND cuenta > cCuentaRangoDos
		
		LET cNumCte				= "";
		LET iIdStatus			= 0;
		LET iInternet			= 0;
		
		IF vcontador3 = 0 THEN
			BEGIN WORK;
			LET vabierto = '1'; 
		END IF

		EXECUTE PROCEDURE "informix".sp_mes_siguiente(TODAY, 1, DAY(dtFechaApertura - 1 UNITS DAY))
		INTO cCodRetMesSig, dtMesiversario, iDiasTransc;
		
		SELECT num_cte
		INTO cNumCte
		FROM "informix".sc_maechq
		WHERE empresa = "001" AND cuenta = cCuenta;
		
		SELECT id_status
		INTO iIdStatus
		FROM bdinteg: "informix".si_bpiusuarios 
		WHERE empresa = "001" AND numcte = cNumCte;
		
		IF iIdStatus IS NOT NULL AND iIdStatus <> 99 THEN
			LET iInternet = 1;
		END IF
		
		UPDATE "informix".sc_indicadores
		SET fecha_mesiversario = dtMesiversario, fec_prim_deposito_orig = dtFechaDepOrig, imp_prim_deposito_orig = dImporteDepOrig, internet = iInternet
		WHERE anio_mes = "201408"
		AND cuenta = cCuenta;
		
		LET vcontador3 = vcontador3 + 1;
		
		IF vcontador3 = 5000 THEN
			LET vabierto = '0';
			LET vcontador3 = 0;
			COMMIT WORK;
		END IF
	END FOREACH	

	IF vcontador3 > 0 THEN
		COMMIT WORK;
	END IF	
	
	RETURN cCodRet, cDescRet;
    	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para insertar el registro de cada cuenta de los indicadores de captación para el mes actual',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Julio 2014';

CREATE PROCEDURE "informix".sp_insertar_registros_indicadores()
RETURNING
	CHAR(6),
	CHAR(80)

	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
	DEFINE cDescRet			CHAR(80);
	
	DEFINE iUnTercio		INT8;
	DEFINE cCuenta			CHAR(20);
	DEFINE cAnioMesActual	CHAR(6);

	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	LET cDescRet			= "PROCESO EXITOSO";

	LET iUnTercio			= 0;
	LET cCuenta				= "";
	LET cAnioMesActual		= "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescRet = cErrorInfo;
			RETURN cCodRet, cDescRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/informix/moha/sp_insertar_registros_indicadores.out';
	--TRACE ON;

	SELECT YEAR(fecha_hoy) || LPAD(MONTH(fecha_hoy),2,"0")
	INTO cAnioMesActual
	FROM "informix".sc_fechas
	WHERE empresa = "001";
	
	UPDATE "informix".sc_param
	SET valor = ""
	WHERE empresa = "001"
	AND codparam IN ("CtaInsRegIndic_uno","CtaInsRegIndic_dos");
	
	SELECT (COUNT(*)) / 3
	INTO iUnTercio
	FROM "informix".sc_indicadores
	WHERE cuenta >= "10000005016"
	AND anio_mes = cAnioMesActual;
	
	FOREACH
		SELECT SKIP iUnTercio LIMIT 1 cuenta
		INTO cCuenta
		FROM "informix".sc_indicadores
		WHERE cuenta >= "10000005016"
		AND anio_mes = cAnioMesActual
	
	END FOREACH
	
	UPDATE "informix".sc_param
	SET valor = cCuenta
	WHERE empresa = "001"
	AND codparam = 'CtaInsRegIndic_uno';
	
	LET cCuenta = "";
	
	LET iUnTercio = iUnTercio * 2;
	
	FOREACH
		SELECT SKIP iUnTercio LIMIT 1 cuenta
		INTO cCuenta
		FROM "informix".sc_indicadores
		WHERE cuenta >= "10000005016"
		AND anio_mes = cAnioMesActual
	
	END FOREACH
	
	UPDATE "informix".sc_param
	SET valor = cCuenta
	WHERE empresa = "001"
	AND codparam = "CtaInsRegIndic_dos";
	
	RETURN cCodRet, cDescRet;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obetener los rangos de las ctas para posteriormente ejecutar tres procesos en paralelo.',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Julio 2014';

CREATE PROCEDURE "informix".sp_conctas_activas_cte(pEmpresa CHAR(3),pNumCte CHAR(9))

	RETURNING
	CHAR(6)		AS CodRet,
	CHAR(20) 	AS NumCta,
	CHAR(4) 	AS NumProd;

	--DEFINICION DE VARIABLES	
	DEFINE cCodRet 		CHAR(6);
	DEFINE cCuenta  	CHAR(20);
	DEFINE cProducto 	CHAR(4);
	DEFINE iSqlErr      INTEGER;

	--INICIALIZACION DE VARIABLES
	LET cCodRet 	= '000000';
	LET cCuenta 	= '';
	LET cProducto 	= '';
	LET iSqlErr 	= 0;	
	
	
	--SET DEBUG FILE TO "/respaldosbd/isarai/sp_conctas_activas.out";
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
		
			IF iSqlErr != 0 THEN
			
				LET cCodRet = iSqlErr;
				RETURN cCodRet, NVL(cCuenta,''), NVL(cProducto,'');
				
			END IF;
			
		END EXCEPTION;

		IF NVL(pEmpresa,'') = '' OR  NVL(pNumCte,'') = '' THEN
		
			LET cCodRet = '000001'; --PARAMETROS VACIOS
			RETURN cCodRet, NVL(cCuenta,''), NVL(cProducto,'');
		
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		
		--SE OBTIENEN LAS CUENTAS DE CAPTACION ACTIVAS DEL CLIENTE
		FOREACH
			
			SELECT mae.cuenta, Mae.producto
			INTO cCuenta, cProducto
			FROM  "informix".sc_maechq Mae
			INNER JOIN  bdicred: "informix".sd_productos_sdoret prod ON (Mae.empresa = prod.empresa 
																	AND mae.producto = prod.num_producto)
			WHERE  Mae.num_cte = pNumCte
			AND Mae.status_cta = '1'
			AND Mae.empresa = Mae.empresa
			AND Mae.empresa = pEmpresa
			ORDER BY mae.cuenta

			RETURN TRIM(cCodRet), TRIM(NVL(cCuenta,'')), TRIM(NVL(cProducto,'')) WITH RESUME;
			
		END FOREACH;
		
		IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
		
			LET cCodRet = '000002'; -- CLIENTE NO TIENE CUENTAS ACTIVAS
			RETURN cCodRet, NVL(cCuenta,''), NVL(cProducto,'');
		
		END IF;
		
	 END
	 
END PROCEDURE
DOCUMENT
'BD : BDICHEQ',
'AUTOR: ISARAI BOJORQUEZ',
'DESCRIPCION:SE CREA PROCEDIMIENTO PARA OBTENER LAS CUENTAS DE CAPTACION ACTIVAS DEL CLIENTE',
'FECHA: 29/07/2014',
'VERSION: 20140729.0942';

CREATE PROCEDURE "informix".sp_cargadividearchivonomina_bpi(pnombrearchivo CHAR(20))
	RETURNING CHAR(5), CHAR(16), CHAR(50);

-------------------------------------------------------------------------------------------------------
--Realizó: Jose Ruben Lopez
--Solicito:Jorge Nuñez
--Fecha: 28/06/2013
--Actividad:Se agrego codigo de retorno del sp_validadatostempnomina_bpi para cuando se repita un empleado en el archivo
--BD:bdicheq.
-------------------------------------------------------------------------------------------------------

---- VARIABLES  GENERALES---
DEFINE cSqlerr			 INTEGER;
DEFINE cCodret      	 CHAR(5);
DEFINE cCodret2      	 CHAR(3);
DEFINE cNombreArchivo    CHAR(23);
DEFINE vsSQL    CHAR(100);
DEFINE cFolio CHAR(16);
DEFINE cRuta CHAR(60);
DEFINE cMensaje CHAR(50);
Define cSQL CHAR(250);
DEFINE cLinea LVARCHAR(500);
DEFINE cBandera CHAR(1);
DEFINE cBan INTEGER;
DEFINE iContador SMALLINT;
DEFINE iNumCaracteres INTEGER;
DEFINE iNumReg INTEGER;
Define cRenglon CHAR(134);
DEFINE dFecha1 DATE;
DEFINE dFecha2 DATE;

--Variables de encabezado
Define cTipoRegistroE CHAR(1);  --clave para identificar registro  (1)
Define cSecuenciaE CHAR(5);      --numero de archivos en el dia
Define cSentidoE CHAR(1);               --control bancoppel
Define cFechaGenE CHAR(8);      --fecha generacion
Define cCuentaCargoE CHAR(16);  --cuenta cargo
Define cFechaAplicE CHAR(8);      --fecha para aplicacion
Define clf_crE CHAR(2);                --control fin de linea

--Variables de detalle
Define cTipoRegistroD CHAR(1);                 --clave para identificar registro  (2)
Define cSecuenciaD CHAR(5); 	          --numero de archivos en el dia
Define cNumeroEmpleadoD CHAR(10);     --clave del empleado
Define cApellidoPaternoD CHAR(30);      --ape del empleado
Define cApellidoMaternoD CHAR(20);    --ape del empleado
Define cNombreD CHAR(30);                  --nombre del empleado
Define cCuentaAbonoD CHAR(18);        --cuenta destino del empleado
Define cConceptoD CHAR(2);                --no existe en el layout, incluirlo para saber el motivo del depósito
Define cImporteD CHAR(18);                   --importe a pagar
Define clf_crD CHAR(2);                          --control fin de linea

--Variables de  sumario
Define cTipoRegistroS CHAR(1);          --clave para identificar registro  (3)
Define cSecuenciaS CHAR(5);           --numero de archivo en el dia
Define cTotalRegistrosS CHAR(5);    --total de empleados que van en el archivo
Define cImporteTotalS CHAR(18);    --total a pagar de los empleados
Define clf_crS CHAR(2);
DEFINE vcomienza SMALLINT; 
DEFINE ven_transacc SMALLINT; 

DEFINE vexiste SMALLINT;
DEFINE vexistehist SMALLINT;

--VALORES INICIALES
LET cSqlerr = '';
LET cCodret = '00000';
LET cCodret2 = '000';
LET cNombreArchivo = '';
LET vsSQL    = '';
LET cFolio = '';
LET cRuta = '';
LET cSQL = '';
LET cLinea = '';
LET cRenglon = '';
LET cBandera = "F";
LET iContador = 0;
LET iNumCaracteres = 0;
LET iNumReg = 0;
LET cBan = 0;
LET dFecha1 = CURRENT;
LET dFecha2 = CURRENT;
LET cMensaje = 'LA APLICACION SE EJECUTO EXITOSAMENTE';

--Variables de encabezado
LET cTipoRegistroE = '';  
LET cSecuenciaE = '';      
LET cSentidoE = '';               
LET cFechaGenE = '';       
LET cCuentaCargoE = '';   
LET cFechaAplicE = '';      
LET clf_crE = '';               

--Variables de detalle
LET cTipoRegistroD = '';                  
LET cSecuenciaD = ''; 	          
LET cNumeroEmpleadoD = '';    
LET cApellidoPaternoD = '';      
LET cApellidoMaternoD = '';    
LET cNombreD = '';                  
LET cCuentaAbonoD = '';       
LET cConceptoD = '';              
LET cImporteD = '';                   
LET clf_crD = '';                      

--Variables de  sumario
LET cTipoRegistroS = '';          
LET cSecuenciaS = '';            
LET cTotalRegistrosS = '';     
LET cImporteTotalS = '';    
LET clf_crS = '';
LET vcomienza = -1;
LET ven_transacc = 0;
LET vexiste = 0;
LET vexistehist = 0;

--SET debug FILE TO "/home/informix/ivonne/sp_cargadividearchivonomina_bpi.out";
--Trace ON;

BEGIN
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;			
            RETURN cCodret, cFolio, cMensaje;
        END IF;
	END EXCEPTION;
	
	on exception in (-535)
       let ven_transacc = 1;
    end exception with resume;
    
    SELECT COUNT(*)
      INTO vexistehist
      FROM sc_nominaencabezadosumariohist
     WHERE nombre_archivo = pnombrearchivo;
     
    SELECT COUNT(*)
      INTO vexiste
      FROM sc_nominaencabezadosumario
     WHERE nombre_archivo = pnombrearchivo;
     
    IF vexistehist > 0 OR vexiste > 0 THEN
        Let cCodret = '';
        RETURN cCodret, cFolio, cMensaje;
    END IF;
	
	--Se leerá de la tabla de parámetros (pp_parametros), aquellos datos fijos(ruta,  nombre de archivo, número de contrato, etc.).
	SELECT valor INTO cRuta 
	  FROM bdicheq:"informix".sc_param 
	 WHERE empresa = "001" 
	   AND codparam = 'NomRutaDestino_BPI';
	--------------Validar que el archivo exista en la ruta del servidor ---------------------------------------------
	--- BORRAR  LA TABLA DE TEMPORAL EN CASO DE QUE EXISTA
	IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'nomi_tmp_bpi') THEN
		DROP TABLE nomi_tmp_bpi;
	END IF

	--- CREAR LA TABLA DE TEMPORAL
	CREATE TABLE nomi_tmp_bpi (linea LVARCHAR(500));

	LET cSQL = '';
	--- GUARDA LOS NOMBRES DE LOS ARCHIVOS EXISTENTES EN LA RUTA EL CARPETA.CAR
	LET cSQL = 'ls ' || TRIM(cRuta) || ' > ' || TRIM(cRuta) || 'carpeta_bpi.car';
	SYSTEM cSQL;

	IF (vcomienza = -1) THEN
       LET vcomienza = 0;
       BEGIN WORK;
    END IF;
	
	LET cSQL = '';
	--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
	LET cSQL = 'echo "LOAD FROM ' || TRIM(cRuta) || 'carpeta_bpi.car' || ' INSERT INTO nomi_tmp_bpi" > '|| TRIM(cRuta) || 'Temporal_bpi.sql';
	SYSTEM cSQL;

	COMMIT WORK;
	BEGIN WORK;
	
	LET cSQL = '';
	--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
	LET cSQL = '/ifxsif01/bin/dbaccess bdicheq ' || TRIM(cRuta) || 'Temporal_bpi.sql';	--LET cSQL = 'dbaccess bdicheq ' || TRIM(cRuta) || 'Temporal_bpi.sql';--se activa para desarrollo
	SYSTEM cSQL;

	COMMIT WORK;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--- CICLO PARA BUSCAR EL NOMBRE DEL ARCHIVO
	FOREACH
		SELECT linea INTO cLinea FROM nomi_tmp_bpi
		IF cLinea = pNombreArchivo THEN
			LET cBandera = "T";
			EXIT FOREACH;
		END IF
	END FOREACH

	--- BORRAR LA TABLA TEMPORAL
	DROP TABLE nomi_tmp_bpi;

	--- VALIDA QUE EL ARCHIVO EXISTA
	IF cBandera = "F" THEN
		--LET cMensaje = 'El Archivo no Existe en la ruta parametrizada';
		LET cCodret = '191';
		--Obtener los mensajes de retorno 
		SELECT DESCRIPCION INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
		RETURN cCodret, cFolio, cMensaje;
	ELSE
		-----------------------------------	
		--LIMPIAR LAS TABLAS TEMPORALES
		DELETE FROM bdicheq:"informix".sc_NominaArchTemp WHERE num_serial is not null;
		DELETE FROM bdicheq:"informix".sc_nominaencabezadosumariotemp WHERE nombre_archivo = pNombreArchivo;
		DELETE FROM bdicheq:"informix".sc_nominamovimientostemp WHERE nombre_archivo = pNombreArchivo;

		---------Se carga archivo ( LOAD)---------
		Let cSQL = '';
		Let  cSQL = 'echo "load from '||TRIM(cRuta) || TRIM(pNombreArchivo) ||
					' insert into sc_NominaArchTemp(columna); " > '||TRIM(cRuta) ||'querynom_bpi.sql';
		System cSQL;
		Let cSQL = '';
		--Let cSQL = 'dbaccess bdicheq '||TRIM(cRuta) ||'querynom_bpi.sql';  --Se activa para desarrollo   
		Let cSQL = '/ifxsif01/bin/dbaccess bdicheq '||TRIM(cRuta) ||'querynom_bpi.sql ';  --Se activa para Produccion
		System cSQL;
		------------------------------------------------------------------------------------------
		------------------VALIDACIONES SOBRE EL ARCHIVO----------------------
		--- VALIDA QUE NO EXISTAN TIPOS DE REGISTROS AJENOS A LOS AUTORIZADOS
		IF EXISTS(SELECT columna FROM bdicheq:"informix".sc_NominaArchTemp WHERE SUBSTR(columna,1,1) NOT IN ("1","2","3")) THEN
			--Existe un tipo de registro que no es autorizado
			LET cCodret = '175';
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
			RETURN cCodret, cFolio, cMensaje;
		END IF
		--- VALIDA QUE EXISTAN LOS NUEMROS DE REGISTROS CORRESPONDIENTES
		LET iNumReg = 0;
		--- OBTENER EL NUMERO DE REGISTROS DE ENCABEZADO
		SELECT COUNT(*)::INTEGER INTO iNumReg FROM  bdicheq:"informix".sc_NominaArchTemp WHERE SUBSTR(columna,1,1) = "1";
		IF iNumReg = 0 THEN
			--No Existe Encabezado en el archivo
			LET cCodret = '176';
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
			RETURN cCodret, cFolio, cMensaje;
		ELIF iNumReg > 1 THEN
			--Existe mas de un Encabezado en el archivo
			LET cCodret = '177';
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
			RETURN cCodret, cFolio, cMensaje;
		END IF
		LET iNumReg		= 0;
		--- OBTENER EL NUMERO DE REGISTROS DE SUMARIO
		SELECT COUNT(*)::INTEGER INTO iNumReg FROM  bdicheq:"informix".sc_NominaArchTemp WHERE SUBSTR(columna,1,1) = "3";
		IF iNumReg = 0 THEN
			--No Existe Sumario en el archivo
			LET cCodret = '178';
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
			RETURN cCodret, cFolio, cMensaje;
		ELIF iNumReg > 1 THEN
			--Existe mas de un Sumario en el archivo
			LET cCodret = '179';
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
			RETURN cCodret, cFolio, cMensaje;
		END IF
		LET iNumReg		= 0;
		--- OBTENER EL NUMERO DE REGISTROS DE DETALLE
		SELECT COUNT(*)::INTEGER INTO iNumReg FROM  bdicheq:"informix".sc_NominaArchTemp WHERE SUBSTR(columna,1,1) = "2";
		IF iNumReg = 0 THEN
			--No Existe Detalle en el archivo
			LET cCodret = '180';
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
			RETURN cCodret, cFolio, cMensaje;
		END IF
		--- BORRAR  LA TABLA DE TEMPORAL EN CASO DE QUE EXISTA
		IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'Nomi_tmp_secuencia_bpi') THEN
			DROP TABLE Nomi_tmp_secuencia_bpi;
		END IF
		---VALIDAR LA SECUENCIA DE LOS REGISTROS
		--- CREAR LA TABLA DE SECUENCIA
		CREATE TABLE Nomi_tmp_secuencia_bpi (secuencia CHAR(5));
				
		INSERT INTO Nomi_tmp_secuencia_bpi
		SELECT SUBSTR(columna,2,5) AS SECUENCIA FROM  bdicheq:"informix".sc_NominaArchTemp WHERE SUBSTR(columna,1,1) = "2" ;
		---VERIFICAR QUE NO VENGAN REPETIDOS LOS NUMEROS DE SECUENCIA
		IF EXISTS(SELECT SECUENCIA FROM Nomi_tmp_secuencia_bpi GROUP BY SECUENCIA HAVING COUNT(*) > 1) THEN
			DROP TABLE Nomi_tmp_secuencia_bpi;
			--La secuencia en el detalle no es correcta
			LET cCodret = '181';
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
			RETURN cCodret, cFolio, cMensaje;
		END IF
		---BORRAR LA TABLA DE SECUENCIA
		DROP TABLE Nomi_tmp_secuencia_bpi;
		---------Se valida la estructura del archivo---------
		FOREACH
			SELECT columna INTO cRenglon FROM bdicheq:"informix".sc_NominaArchTemp ORDER BY(num_serial)
			--aSIGNACION DE VALORES A LAS VARIABLES
			IF SUBSTR(cRenglon,1,1) = "1" THEN --- ENCABEZADO
				LET cTipoRegistroE = SUBSTR(cRenglon,1,1);  
				LET cSecuenciaE = SUBSTR(cRenglon,2,5);      
				LET cSentidoE = SUBSTR(cRenglon,7,1);               
				LET cFechaGenE = SUBSTR(cRenglon,8,8);       
				LET cCuentaCargoE = SUBSTR(cRenglon,16,16);   
				LET cFechaAplicE = SUBSTR(cRenglon,32,8);      
				--Validar si son nullos
				IF TRIM(cTipoRegistroE) = '' OR (cTipoRegistroE IS null) OR TRIM(cSecuenciaE) = '' OR (cSecuenciaE IS null) OR 
				   TRIM(cSentidoE) = '' OR (cSentidoE IS null) OR TRIM(cFechaGenE) = '' OR (cFechaGenE IS null) OR
				   TRIM(cCuentaCargoE) = '' OR (cCuentaCargoE IS null) OR TRIM(cFechaAplicE) = '' OR (cFechaAplicE IS null)  THEN
					--Error Un valor nULLOS En EL Archivo
					LET cCodret = '182';
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
					RETURN cCodret, cFolio, cMensaje;
				END IF;
				--Validar si son numericos
				IF bdiprog:"informix".isnumeric(cTipoRegistroE) <> '1' OR bdiprog:"informix".isnumeric(cSecuenciaE) <> '1' OR  bdiprog:"informix".isnumeric(cFechaGenE) <> '1' 
					OR bdiprog:"informix".isnumeric(cCuentaCargoE) <> '1' OR bdiprog:"informix".isnumeric(cFechaAplicE) <> '1'THEN
					--Error Un valor No Es  Numerico En Encabezado
					LET cCodret = '183';
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
					RETURN cCodret, cFolio, cMensaje;
				END IF;
				--Validar si son cadenas
				IF bdiprog:"informix".isnumeric(cSentidoE) <> '0' THEN
					--Error Un valor Es  Numerico En Encabezado
					LET cCodret = '184';
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
					RETURN cCodret, cFolio, cMensaje;
				END IF;
				--VALIDAR LAS FECHAS
				IF NOT ((SUBSTR(cFechaGenE,1,2) > 0 AND  SUBSTR(cFechaGenE,1,2) < 13) AND (SUBSTR(cFechaGenE,3,2) > 0 AND SUBSTR(cFechaGenE,3,2) < 32) 
					AND (SUBSTR(cFechaGenE,5,4) > 2000 AND SUBSTR(cFechaGenE,5,4) < 3000 ) )  THEN
					--Error en una fecha  en Encabezado
					LET cCodret = '185';
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
					RETURN cCodret, cFolio, cMensaje;
				END IF;
				--VALIDAR LAS FECHAS
				IF NOT ((SUBSTR(cFechaAplicE,1,2) > 0 AND  SUBSTR(cFechaAplicE,1,2) < 13) AND (SUBSTR(cFechaAplicE,3,2) > 0 AND SUBSTR(cFechaAplicE,3,2) < 32) 
					AND (SUBSTR(cFechaAplicE,5,4) > 2000 AND SUBSTR(cFechaAplicE,5,4) < 3000)) THEN
					--Error en una fecha  en Encabezado
					LET cCodret = '185';
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
					RETURN cCodret, cFolio, cMensaje;
				END IF;
				LET cBan = cBan + 1;
			ELIF SUBSTR(cRenglon,1,1) = "2" THEN --- DETALLE
				LET cTipoRegistroD = SUBSTR(cRenglon,1,1);                  
				LET cSecuenciaD = SUBSTR(cRenglon,2,5); 	          
				LET cNumeroEmpleadoD = SUBSTR(cRenglon,7,10);    
				LET cApellidoPaternoD = SUBSTR(cRenglon,17,30);      
				LET cApellidoMaternoD = SUBSTR(cRenglon,47,20);    
				LET cNombreD = SUBSTR(cRenglon,67,30);                  
				LET cCuentaAbonoD = SUBSTR(cRenglon,97,18);       
				LET cConceptoD = SUBSTR(cRenglon,115,2);              
				LET cImporteD = SUBSTR(cRenglon,117,18);                   
				--Validar si son nullos
				IF TRIM(cTipoRegistroD) = '' OR (cTipoRegistroD IS null) OR TRIM(cSecuenciaD) = '' OR (cSecuenciaD IS null) OR 
				   TRIM(cNumeroEmpleadoD) = '' OR (cNumeroEmpleadoD IS null) OR TRIM(cApellidoPaternoD) = '' OR (cApellidoPaternoD IS null) OR
				   TRIM(cApellidoMaternoD) = '' OR (cApellidoMaternoD IS null) OR TRIM(cNombreD) = '' OR (cNombreD IS null) OR 
				   TRIM(cCuentaAbonoD) = '' OR (cCuentaAbonoD IS null) OR TRIM(cConceptoD) = '' OR (cConceptoD IS null) OR TRIM(cImporteD) = '' 
				   OR (cImporteD IS null) THEN
					--Error Un valor nULLOS En EL Archivo
					LET cCodret = '182';
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
					RETURN cCodret, cFolio, cMensaje;
				END IF;				
				--Validar si son numericos
				IF bdiprog:"informix".isnumeric(cTipoRegistroD) <> '1' OR bdiprog:"informix".isnumeric(cSecuenciaD) <> '1' --OR  bdiprog:isnumeric(cNumeroEmpleadoD) <> '1' 
					OR bdiprog:"informix".isnumeric(cCuentaAbonoD) <> '1' OR bdiprog:"informix".isnumeric(cConceptoD) <> '1' OR bdiprog:"informix".isnumeric(cImporteD) <> '1' THEN
					--Error Un valor No Es  Numerico En detalle
					LET cCodret = '187';
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
					RETURN cCodret, cFolio, cMensaje;
				END IF;
				--HAcer el inser a la temporal para una siguiente validacion
				INSERT INTO  bdicheq:"informix".sc_nominamovimientostemp (nombre_archivo, num_empleado, apell_paterno, apell_materno, nombres, cuenta_abono, importe, concepto, status)
				VALUES (pNombreArchivo, cNumeroEmpleadoD, cApellidoPaternoD, cApellidoMaternoD, cNombreD, cCuentaAbonoD, (cImporteD), cConceptoD, '0');
			ELIF SUBSTR(cRenglon,1,1) = "3" THEN --- SUMARIO
				LET cTipoRegistroS = SUBSTR(cRenglon,1,1);          
				LET cSecuenciaS = SUBSTR(cRenglon,2,5);            
				LET cTotalRegistrosS = SUBSTR(cRenglon,7,5);     
				LET cImporteTotalS = SUBSTR(cRenglon,12,18);    
				--Validar si son nullos
				IF TRIM(cTipoRegistroS) = '' OR (cTipoRegistroS IS null) OR TRIM(cSecuenciaS) = '' OR (cSecuenciaS IS null) OR 
				   TRIM(cTotalRegistrosS) = '' OR (cTotalRegistrosS IS null) OR TRIM(cImporteTotalS) = '' OR (cImporteTotalS IS null) THEN
					--Error Un valor nULLOS En EL Archivo
					LET cCodret = '182';
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
					RETURN cCodret, cFolio, cMensaje;
				END IF;
				--Validar si son numericos
				IF bdiprog:"informix".isnumeric(cTipoRegistroS) <> '1' OR bdiprog:"informix".isnumeric(cSecuenciaS) <> '1' OR  bdiprog:"informix".isnumeric(cTotalRegistrosS) <> '1' 
					OR bdiprog:"informix".isnumeric(cImporteTotalS) <> '1' THEN
					--Error Un valor No Es  Numerico En Sumario
					LET cCodret = '189';
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
					RETURN cCodret, cFolio, cMensaje;
				END IF;
				LET cBan = cBan + 1;
			END IF;
		END FOREACH;
        IF cBan = 2 THEN--06302009   2009-06-30    empresa + fecha + folio (2)     aaaammdd   mmddaaaa
		--LET cFechaFormateada = SUBSTR(cFecha_presentacionD,5,2) ||'/'|| SUBSTR(cFecha_presentacionD,7,2) ||'/'|| SUBSTR(cFecha_presentacionD,1,4);
			INSERT INTO bdicheq:"informix".sc_nominaencabezadosumariotemp (empresa, fecha_gen, folio_archivo, nombre_archivo, sentido, cuenta_cargo, fecha_aplicacion, 
			            total_registros, importe_tot, status, fecha_insert)
			VALUES (SUBSTR(pNombreArchivo,1,3),SUBSTR(cFechaGenE,1,2) ||'/'||SUBSTR(cFechaGenE,3,2) ||'/'|| SUBSTR(cFechaGenE,5,4), 
			        SUBSTR(pNombreArchivo,12,2), pNombreArchivo, cSentidoE, cCuentaCargoE,SUBSTR(cFechaAplicE,1,2) ||'/'||
					SUBSTR(cFechaAplicE,3,2) ||'/'|| SUBSTR(cFechaAplicE,5,4), cTotalRegistrosS, (cImporteTotalS), '0', CURRENT::DATE);
		ELSE
			--No se Obtuvo Encabezado o Suamrio
			LET cCodret = '190';
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
			RETURN cCodret, cFolio, cMensaje;
		END IF;
       -- Se manda llamar el sp sp_validadatostempnomina
		EXECUTE PROCEDURE BDICHEQ: sp_validadatostempnomina_bpi(SUBSTR(pNombreArchivo,1,3), SUBSTR(cFechaGenE,1,2) ||'/'||SUBSTR(cFechaGenE,3,2) ||'/'||
			    SUBSTR(cFechaGenE,5,4),  SUBSTR(pNombreArchivo,12,2)) INTO cCodret2,cFolio;
		IF cCodret2 <> '000' THEN
			--Error en el sp de valida datos
			--192 - 199
			IF cCodret2 = '600' THEN
				LET cCodret = '192';
			ELIF cCodret2 = '100' THEN
				LET cCodret = '193';
			ELIF cCodret2 = '150' THEN
				LET cCodret = '194';
			ELIF cCodret2 = '200' THEN
				LET cCodret = '195';
			ELIF cCodret2 = '250' THEN
				LET cCodret = '196';
			ELIF cCodret2 = '550' THEN
				LET cCodret = '197';
			ELIF cCodret2 = '551' THEN--Empleado Repetido en el archivo
				LET cCodret = '189';
			ELIF cCodret2 = '300' THEN
				LET cCodret = '198';
			ELIF cCodret2 = '350' THEN
				LET cCodret = '199';
			ELIF cCodret2 = '400' THEN
				LET cCodret = '186';
			ELIF cCodret2 = '450' THEN
				LET cCodret = '188';
			END IF;
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION INTO cMensaje FROM bdinteg:"informix".si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
			RETURN cCodret, cFolio,cMensaje;
		END IF;
		--------------------------------------------------------------
	END IF;
	RETURN cCodret, cFolio, cMensaje;
    
    END

END PROCEDURE;