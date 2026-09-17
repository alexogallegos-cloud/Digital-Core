CREATE PROCEDURE "informix".sp_registraprestamoscoppel_web(
		pNumCte CHAR(20),
		pNumCteCoppel CHAR(20), 
		pNumProducto CHAR(4), 
		pSucursal CHAR(4),
        pFolioPrestamo CHAR(20), 
		pToken CHAR(8), 
		pPromotor CHAR(30), 
		pCapacidadPres money(18,2), 
        pMontoAutorizado money(18,2), 
		pPlazo INTEGER,
		pOrigenApertura CHAR(1))

RETURNING CHAR(5), CHAR(40);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE v_cod_ret			CHAR(5);
DEFINE vsqlerr				INTEGER;
DEFINE sMensaje			    CHAR(40);
DEFINE sNumCteCppl		    CHAR(20);
DEFINE dFecha			    DATE;
DEFINE sCiudad		    	CHAR(3);
DEFINE sRegion		    	CHAR(3);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET v_cod_ret				= "00000";
LET vsqlerr					= 0;
LET sMensaje				= "REGISTRO INSERTADO CON EXITO";
LET sNumCteCppl				= pNumCteCoppel;
LET dFecha				    = TODAY;
LET sCiudad					= "";
LET sRegion					= "";

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

BEGIN
    ON EXCEPTION SET vsqlerr
    IF vsqlerr != 0 THEN
        LET v_cod_ret=vsqlerr;
        LET sMensaje = "ERROR AL INSERTAR REGISTRO";
        RETURN v_cod_ret, sMensaje;
    END IF;
    END EXCEPTION;


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/INFORMIXDUMP/sp_registraprestamoscoppel_web.trc';    
    --TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
    	
	IF NVL(pNumCte, '') <> "" AND NVL(pFolioPrestamo, '') <> "" AND NVL(pToken, '') <> "" THEN
		SELECT {+INDEX(bdinteg: "informix".si_fechas idx_si_fechas)}  fecha_hoy INTO dFecha
		FROM bdinteg:"informix".si_fechas
		WHERE empresa = '001';
		
		/*
		SELECT numcte_ref INTO sNumCteCppl
		FROM bdinteg:"informix".si_cliente 
		WHERE numcte = pNumCte;*/
		
		SELECT reg.numero_region, ciu.ciudad 
		INTO sRegion, sCiudad
		FROM bdinteg:"informix".si_sucursales suc,
			bdinteg:"informix".si_ciudades ciu , 
			bdinteg:"informix".si_catciudades cat,
			bdinteg:"informix".si_regiones reg
		WHERE --cat.numero_region = cat.numero_region AND
		ciu.ciudad_coppel = cat.numerociudad
		AND suc.empresa = '001'
		AND suc.estado = ciu.estado 
		AND suc.ciudad = ciu.ciudad
		AND suc.pais = ciu.pais
		AND suc.tpo_sucursal = 'S'
		AND suc.sucursal = pSucursal
		AND reg.numero_region = cat.numero_region;
		
		INSERT INTO bdisolic:"informix".ss_prestamoscoppel(numcte, num_producto, sucursal, folio_prestamo, token, user_insert, fecha_insert, fecha_contratacion,capacidad_pres, monto_autorizado, plazo, status_solicitud, status_result, numcte_ref, ciudad, region,apertura)
		VALUES(pNumCte, pNumProducto, pSucursal, pFolioPrestamo, pToken, pPromotor, dFecha, null,pCapacidadPres, pMontoAutorizado, pPlazo, 'P', '0', sNumCteCppl, sCiudad, sRegion,pOrigenApertura);
		IF DBINFO('SQLCA.SQLERRD2')<0 THEN
			LET v_cod_ret = '00002';
			LET sMensaje = "ERROR AL INSERTAR REGISTRO";
			RETURN v_cod_ret, sMensaje;
		END IF;					
	ELSE
		LET v_cod_ret = "00001";
        LET sMensaje = "FALTAN PARAMETROS DE ENTRADA";
	END IF;

    RETURN v_cod_ret, sMensaje;	
END;	

END PROCEDURE
