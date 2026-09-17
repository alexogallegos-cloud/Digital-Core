CREATE PROCEDURE "informix".sp_insertar_filas_indicadores()
RETURNING
	CHAR(6) 	AS cod_ret,
	CHAR(80)	AS desc_ret

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
	DEFINE dtFechaAlta		DATE;
	DEFINE cSucursal		CHAR(4);
	DEFINE dtMesiversario	DATE;
	DEFINE dtFecPrimerDep	DATE;
	DEFINE dtMontoPrimerDep	MONEY;
	DEFINE dFechaHoy		DATE;
	DEFINE iNumSerie		INT8;
	DEFINE cEmpresa			CHAR(3);



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
	LET dtFechaAlta			= DATE(1);
	LET cSucursal			= "";
	LET dtMesiversario		= DATE(1);
	LET dtFecPrimerDep		= NULL;
	LET dtMontoPrimerDep	= NULL;
	LET dFechaHoy			= DATE(1);
	LET cCodRetMesSig		= "00000";
	LET iDiasTransc			= 0;
	LET iNumSerie			= 0;
	LET cEmpresa			= "";
	


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
    
	--SET DEBUG FILE TO '/informix/moha/sp_insertar_filas_indicadores.out';
	--TRACE ON;
		
	-- OBTIENE EL AÑO Y EL MES ACTUAL Y EL DEL SIGUIENTE MES
	SELECT fecha_hoy, YEAR(fecha_hoy) || LPAD(MONTH(fecha_hoy),2,"0"), YEAR(fecha_hoy + 1 units MONTH) || LPAD(MONTH(fecha_hoy + 1 units MONTH),2,"0")
	INTO dFechaHoy, cAnioMesActual, cAnioMesSig
	FROM "informix".sc_fechas
	WHERE empresa = "001";

	SELECT {+INDEX(sc_maechq bdicheq)}
	t1.producto,t1.cuenta,t1.sucursal,t2.fecha_alta
	FROM "informix".sc_maechq t1, "informix".sc_maenoc t2
	WHERE t1.empresa = t2.empresa
	AND t1.empresa = "001"
	AND t1.cuenta = t2.cuenta
	AND t1.status_cta NOT IN ("2","7")
	AND t1.producto <> "1100"
	AND t2.fecha_alta >= "04/10/2014"
	UNION
	SELECT {+INDEX(sc_maechq bdicheq)}
	t1.producto, t1.cuenta, t1.sucursal, t1.fecultdep
	FROM "informix".sc_maechq t1, "informix".sc_maenoc t2
	WHERE t1.empresa = t2.empresa
	AND t1.empresa = "001"
	AND t1.cuenta = t2.cuenta
	AND t1.status_cta NOT IN ("2","7")
	AND t1.producto = "1100"
	AND t1.fecultdep >= "04/10/2014"
	INTO TEMP tmp_ctas_capt WITH NO LOG;
	CREATE INDEX idx_tmp_ctas_capt ON tmp_ctas_capt(cuenta);
	UPDATE statistics medium FOR TABLE tmp_ctas_capt;
	
	-- CICLO PARA OBTENER LAS CUENTAS DE CAPTACION EXCEPTO INVERSION CRECIENTE 1100
	FOREACH WITH HOLD
		SELECT producto, cuenta, sucursal, fecha_alta
		INTO cProducto, cCuenta, cSucursal, dtFechaAlta
		FROM tmp_ctas_capt
		ORDER BY cuenta
		
		IF vcontador3 = 0 THEN
			BEGIN WORK;
			LET vabierto = '1'; 
		END IF
		
		-- OBTIENE FECHA DE MESIVERSARIO
		EXECUTE PROCEDURE "informix".sp_mes_siguiente(dFechaHoy, 1, DAY(dtFechaAlta - 1 UNITS DAY))
		INTO cCodRetMesSig, dtMesiversario, iDiasTransc;
		
		LET dtFecPrimerDep = NULL;
		LET dtMontoPrimerDep = NULL;
		
		FOREACH WITH HOLD
			SELECT FIRST 1 mov.fech_alt, mov.monto_tot
			  INTO dtFecPrimerDep, dtMontoPrimerDep
			  FROM sc_movhis mov,   
				   bdinteg:si_transacc trx
			 WHERE mov.empresa = trx.empresa
			   AND mov.cuenta = cCuenta
			   AND mov.fech_alt >= "04/10/2014"
			   AND mov.cancelad <> 'S'   
			   AND mov.transacc = trx.numero
			   AND trx.naturaleza = 'A'  
			   AND trx.se_emite_edocta = 'S'
			 ORDER BY mov.num_serial
			 
			 EXIT FOREACH;
		END FOREACH
		
		SELECT empresa
		INTO cEmpresa
		FROM "informix".sc_indicadores 
		WHERE anio_mes = cAnioMesActual 
		AND cuenta = cCuenta;
		
		LET cEmpresa = NVL(cEmpresa,"");

		IF cEmpresa = "" THEN
				
				INSERT INTO "informix".sc_indicadores
				(empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig) 
				VALUES("001", cAnioMesActual, cProducto, cCuenta, dtFechaAlta, cSucursal, dtMesiversario, dtFecPrimerDep, dtMontoPrimerDep);

		END IF
		
		LET vcontador3 = vcontador3 + 1;
		LET cEmpresa = "";
		
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
'FECHA: Abril 2014';

CREATE PROCEDURE "informix".sp_movdiaconcil_descarga()
RETURNING CHAR(5);
          
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(5);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE cSql         CHAR(300);
    
    LET cCodRet  = '000';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
    LET iSqlErr  = 0;
    LET iSamErr  = 0;
    LET cDesErr  = 0;
    LET cSql     = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_movdiaconcil_descarga.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_movdiaconcil_descarga.out";
    --- TRACE ON;
        
    LET cSql = '';
    LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/movdia_concil.unl '||
               'SELECT mov.* FROM sc_movdia mov, sc_fechas fecha WHERE mov.fech_alt = fecha.fecha_ant;" > /resplogifx/conciliachq/movdiaconcil.sql';
    SYSTEM cSql;
    
    LET cSql = '';
    LET cSql = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/movdiaconcil.sql'; 
    SYSTEM cSql;
    
    LET cSql = '';
    LET cSql = 'ls -l /resplogifx/conciliachq/movdia_concil.unl'; 
    SYSTEM cSql;
     
    END;
    
    RETURN cCodRet;
    
END PROCEDURE;