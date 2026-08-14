CREATE PROCEDURE "informix".sp_cre_genreportevalidacionhuellacoppel_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaIncio DATE, pFechaFin DATE)
		RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
		BEGIN
	
		ON EXCEPTION SET iSqlErr    
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_genreportevalidacionhuellacoppel_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaIncio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SELECT  COUNT(*)
			INTO iNoRegistros
			FROM bdisolic:"informix".ss_clientes_exentos_rgc
			WHERE fecha_insert BETWEEN pFechaIncio AND pFechaFin;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		RETURN cCodRet, iNoRegistros;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 02/05/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE VALIDACIÓN HUELLA EN LÍNEA',
'DESCRIPCION:SPL que consulta el total de los clientes que tiene credito grupo coppel para la generación del reporte validacion huella en línea.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_abonotransfersoc( pSucursal   CHAR(4), 
                                                 pUsuario    CHAR(8),
                                                 pTransacc   CHAR(4),
                                                 pCuenta     CHAR(20),
                                                 pCheque     INTEGER,
                                                 pMonto      DECIMAL(14,2),
                                                 pReferencia CHAR(40),
                                                 pTarjeta    CHAR(16) )
RETURNING CHAR(5), CHAR(40);
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(40);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE cProceso     CHAR(10);
    DEFINE cStatusTar   CHAR(1);
    DEFINE cHora        CHAR(15);
    DEFINE cFolio       CHAR(16);
    DEFINE cCodRet4     CHAR(5);
    
    LET cCodRet1   = '';
    LET cCodRet2   = '';
    LET cCodRet3   = '';
    LET iSqlErr	   = 0;
    LET iSamErr    = 0;
    LET cDesErr    = '';
    LET cProceso   = '';
    LET cStatusTar = '';
    LET cHora      = '';
    LET cFolio     = '';
    LET cCodRet4   = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_abonotransfersoc.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, cCodRet3;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_abonotransfersoc.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF ( pMonto     is null OR pMonto <= 0.00 ) OR
       ( pSucursal  is null OR pSucursal = '' OR LENGTH(pSucursal) <> 4 ) OR
       ( pUsuario   is null OR pUsuario  = '' OR LENGTH(pUsuario)  <> 8 ) OR
       ( pTransacc  is null OR pTransacc = '' OR LENGTH(pTransacc) <> 4 ) OR
       ( ( pCuenta  is null OR pCuenta   = '' OR LENGTH(pCuenta)   <> 11 ) AND 
         ( pTarjeta is null OR pTarjeta  = '' OR LENGTH(pTarjeta)  <> 16 ) ) THEN
        LET cCodRet1 = '110';
        LET cCodRet3 = 'PARAMETROS INSUFICENTES';
        RETURN cCodRet1, cCodRet3;
    END IF;
    
    -- // VALIDA PROCESO DE LA TRANSACCION
    SELECT proceso
      INTO cProceso
      FROM bdicheq:sc_trxtrfabonosoc
     WHERE transacc = pTransacc;
     
    IF cProceso is null OR cProceso = '' THEN
        LET cCodRet1 = '110';
        LET cCodRet3 = 'PROCESO NO REGISTRADO';
        RETURN cCodRet1, cCodRet3;
    END IF;
    
    -- // OBTIENE CUENTA SI NO VIENE EN LOS PARAMETROS DE ENTRADA
    IF pCuenta is null OR pCuenta = '' THEN
        SELECT cuenta, status_tar
          INTO pCuenta, cStatusTar
          FROM bdicheq:sc_tarjeta
         WHERE empresa = '001'
           AND num_tarjeta = pTarjeta;
           
        IF pCuenta is null OR cStatusTar is null OR cStatusTar <> 'A' THEN
            LET cCodRet1 = '200';
            LET cCodRet3 = 'CUENTA CANCELADA';
            RETURN cCodRet1, cCodRet3;
        END IF;
    END IF;
    
    -- // OBTIENE TARJETA SI NO VIENE EN LOS PARAMETROS DE ENTRADA
    IF pTarjeta is null OR pTarjeta = '' THEN
        SELECT num_tarjeta
          INTO pTarjeta
          FROM bdicheq:sc_tarjeta
         WHERE empresa = '001'
           AND cuenta = pCuenta
           AND secuencia = (SELECT MAX(secuencia)
                              FROM bdicheq:sc_tarjeta
                             WHERE empresa = '001'
                               AND cuenta = pCuenta)
           AND status_tar = 'A';
           
        IF pTarjeta is null THEN
            LET pTarjeta = '';
        END IF;
    END IF;
    
    -- // APLICA EL ABONO EN LA CUENTA
    IF cProceso = 'abono_ref' THEN
        
        LET cHora = CURRENT HOUR TO FRACTION;
        LET cFolio = pUsuario||cHora[1,2]||cHora[4,5]||cHora[7,8]||cHora[10,11];
        
        CALL bdicheq:abono_ref( '001', pSucursal, pUsuario, pTransacc, '0000', cFolio, pCuenta, 0, pMonto, pMonto, 0, 0, 0, '01', pReferencia, pTarjeta, pUsuario ) 
        RETURNING cCodRet4;
        
        IF cCodRet4 <> '000' THEN
            LET cCodRet1 = cCodRet4;
            LET cCodRet3 = 'ERROR EN EL PROCESO DE ABONO';
            RETURN cCodRet1, cCodRet3;
        END IF;
        
    ELSE
        
        LET cCodRet1 = '110';
        LET cCodRet3 = 'PROCESO DE ABONO NO REGISTRADO';
        RETURN cCodRet1, cCodRet3;
        
    END IF;
    
    LET cCodRet1 = '000';
    LET cCodRet3 = 'DEPOSITO REALIZADO CORRECTAMENTE';
    
    END;
    
    RETURN cCodRet1, cCodRet3;
    
END PROCEDURE;