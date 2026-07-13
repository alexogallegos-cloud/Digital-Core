CREATE PROCEDURE "informix".sp_insertar_registros_indicadores_3()
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

	DEFINE cAnioMesActual	CHAR(6);
	DEFINE cAnioMesSig		CHAR(6);
	DEFINE cProducto		CHAR(4);
	DEFINE cCuenta			CHAR(20);
	DEFINE cSucursal		CHAR(4);
	DEFINE dtMesiversario	DATE;
	DEFINE dtFechaApertura	DATE;
	DEFINE cCuentaRangoDos	CHAR(20);
	DEFINE dtFechaDepOrig	DATE;
	DEFINE dImporteDepOrig	DECIMAL(14,2);
	DEFINE cParamCta		CHAR(20);
	DEFINE cBandCta			CHAR(1);

	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	LET cDescRet			= "PROCESO EXITOSO";
	LET vabierto   			= '0';
	LET vcontador3 			= 0;

	LET cAnioMesActual		= "";
	LET cAnioMesSig			= "";
	LET cProducto			= "";
	LET cCuenta				= "";
	LET cSucursal			= "";
	LET dtMesiversario		= DATE(1);
	LET cCodRetMesSig		= "00000";
	LET iDiasTransc			= 0;
	LET dtFechaApertura		= DATE(1);
	LET cCuentaRangoDos		= "";
	LET dtFechaDepOrig		= DATE(1);
	LET dImporteDepOrig		= 0.0;
	LET cParamCta			= "0";
	LET cBandCta			= "";


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
    
	--SET DEBUG FILE TO '/informix/moha/sp_insertar_registros_indicadores_3.out';
	--TRACE ON;
		
	SELECT YEAR(fecha_hoy) || LPAD(MONTH(fecha_hoy),2,"0"), YEAR(fecha_hoy + 1 units MONTH) || LPAD(MONTH(fecha_hoy + 1 units MONTH),2,"0")
	INTO cAnioMesActual, cAnioMesSig
	FROM "informix".sc_fechas
	WHERE empresa = "001";
	
	SELECT valor
	INTO cCuentaRangoDos
	FROM "informix".sc_param
	WHERE empresa = "001"
	AND codparam = ("CtaInsRegIndic_dos");
	
	-- OBTIENE EL PARAMETRO DE LA CTA INICIAL
	SELECT valor
	INTO cParamCta
	FROM "informix".sc_param
	WHERE empresa = "001"
	AND codparam = "UltCtaInsertIndic3";
		
	FOREACH WITH HOLD
		SELECT producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig
		INTO cProducto, cCuenta, dtFechaApertura, cSucursal, dtMesiversario, dtFechaDepOrig, dImporteDepOrig
		FROM "informix".sc_indicadores
		WHERE anio_mes = cAnioMesActual
		AND cuenta > cParamCta
		AND cuenta > cCuentaRangoDos
		
		IF vcontador3 = 0 THEN
			BEGIN WORK;
			LET vabierto = '1'; 
		END IF

		EXECUTE PROCEDURE "informix".sp_mes_siguiente(TODAY, 1, DAY(dtFechaApertura - 1 UNITS DAY))
		INTO cCodRetMesSig, dtMesiversario, iDiasTransc;
		
		SELECT LIMIT 1 1
		INTO cBandCta
		FROM "informix".sc_indicadores
		WHERE anio_mes = cAnioMesSig
		AND cuenta = cCuenta;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN		
			INSERT INTO "informix".sc_indicadores
			(empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig) 
			VALUES("001", cAnioMesSig, cProducto, cCuenta, dtFechaApertura, cSucursal, dtMesiversario, dtFechaDepOrig, dImporteDepOrig);
		END IF
			
		LET vcontador3 = vcontador3 + 1;
		
		IF vcontador3 = 5000 THEN
			LET vabierto = '0';
			LET vcontador3 = 0;
			UPDATE "informix".sc_param
			SET valor = cCuenta
			WHERE empresa = "001" 
			AND codparam = "UltCtaInsertIndic3";
			COMMIT WORK;
		END IF
	END FOREACH	

	IF vcontador3 > 0 THEN
		COMMIT WORK;
	END IF	
	
	-- SE REINICIA EL PARAMETRO DE LA CTA INICIAL
	UPDATE "informix".sc_param
	SET valor = "0"
	WHERE empresa = "001"
	AND codparam = "UltCtaInsertIndic3";
	
	RETURN cCodRet, cDescRet;
    	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para insertar el registro de cada cuenta de los indicadores de captación para el mes actual',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Julio 2014';

CREATE PROCEDURE "informix".sp_inicializa_sdomensualc( pEmpresa CHAR(3), pAnio SMALLINT )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;

    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE error_info   CHAR(50);
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE vcomienza    SMALLINT;
    DEFINE vcuantos     INTEGER;
    DEFINE vcommit      INTEGER;
    
    DEFINE vfecha_hoy   DATE;
    DEFINE vanio_actual CHAR(4);
    DEFINE vult_dia_mes DATE;
    DEFINE vdiaproxmes  DATE;
    DEFINE vanio        CHAR(4);
    DEFINE vmes         CHAR(2);
    DEFINE vaniomes     CHAR(6);
    DEFINE vcuenta      CHAR(20);
    DEFINE vsucursal    CHAR(4);
    DEFINE vmincta      CHAR(20);
    DEFINE vmaxcta      CHAR(20);

    LET sql_err    = 0;
    LET isam_err   = 0;
    LET error_info = '';
    LET vcodret1   = '000';
    LET vcodret2   = '000';
    LET vcodret3   = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET vcomienza  = -1;
    LET vcuantos   = 0;
    LET vcommit    = 0;
    
    LET vfecha_hoy = '';
    LET vanio_actual = '';
    LET vult_dia_mes = '';
    LET vdiaproxmes = '';
    LET vanio = '2015';
    LET vmes = '';
    LET vaniomes = '';
    LET vcuenta = '';
    LET vsucursal = '';
    LET vmincta  = "";
    LET vmaxcta  = "";
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_inicializa_sdomensualc.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            IF vcommit > 0 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3, vcuantos;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_inicializa_sdomensualc.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmincta, vmaxcta
      FROM sc_maechq;
      
    SELECT cuenta 
      FROM sc_sdomensualc
     WHERE cuenta BETWEEN vmincta AND vmaxcta
       AND anio = pAnio
      INTO TEMP tmp_sdosmensuales WITH NO LOG;
    CREATE INDEX idx_tmpsdos ON tmp_sdosmensuales(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_sdosmensuales;
    
    FOREACH WITH HOLD
        SELECT cuenta, sucursal 
          INTO vcuenta, vsucursal
          FROM sc_maechq
         WHERE empresa = pEmpresa
           AND cuenta BETWEEN vmincta AND vmaxcta
           AND cuenta NOT IN(SELECT cuenta FROM tmp_sdosmensuales)
           AND status_cta <> '2'
        
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            BEGIN WORK;
        END IF;
        
        INSERT INTO sc_sdomensualc VALUES( vcuenta, pAnio, vsucursal,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );
        
        INSERT INTO sc_sdotrimestralc VALUES
        (vcuenta, pAnio, vsucursal, 0.00, 0.00, 0.00, 0.00);
        
        LET vcuantos = vcuantos + 1;
        LET vcommit = vcommit + 1; 
        
        IF vcommit >= 1000 THEN
            LET vcommit = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;   
        
        LET vcuenta = '';
        LET vsucursal = '';
    END FOREACH;
    
    IF vcommit >= 0 THEN
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_sdomensualc;
    
    END;
    
    RETURN vcodret1, vcodret2, vcodret3, vcuantos;
    
END PROCEDURE;