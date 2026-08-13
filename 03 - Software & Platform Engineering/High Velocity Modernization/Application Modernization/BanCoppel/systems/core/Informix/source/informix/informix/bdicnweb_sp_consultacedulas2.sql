CREATE PROCEDURE "informix".sp_consultacedulas2( pFechaConcil DATE, pTipo SMALLINT, pregistros INTEGER, precuperacion INTEGER )
RETURNING CHAR(5), CHAR(40), CHAR(14), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), CHAR(255), CHAR(1);
    
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iExiste          SMALLINT;
    DEFINE cNombre          CHAR(40);
    DEFINE cCtaContable     CHAR(14);
    DEFINE mSdoCheques      DECIMAL(18,2);
    DEFINE mSdoContab       DECIMAL(18,2);
    DEFINE mDifSaldos       DECIMAL(18,2);
    DEFINE cObservaciones   CHAR(255);
    DEFINE cEditable        CHAR(1);
    
    LET cCodRet1       = '000';
    LET cCodRet2       = '';
    LET cCodRet3       = '';
    LET iSqlErr	       = 0;
    LET iSamErr        = 0;
    LET cDesErr        = '';
    LET iExiste        = 0;
    LET cNombre        = '';
    LET cCtaContable   = '';
    LET mSdoCheques    = 0.00;
    LET mSdoContab     = 0.00;
    LET mDifSaldos     = 0.00;
    LET cObservaciones = '';
    LET cEditable      = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    END EXCEPTION;  
    
    -- SET DEBUG FILE TO "/tmp/sp_consultacedulas2.out";
    -- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pFechaConcil is null OR pFechaConcil = '' ) OR
         ( pTipo is null OR pTipo NOT IN(1, 2, 3, 4, 5) ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
    END IF;
    
    IF pTipo = 1 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'CAPITAL';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT SKIP pregistros FIRST precuperacion nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'CAPITAL'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    ELIF pTipo = 2 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'INTERES';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT SKIP pregistros FIRST precuperacion nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'INTERES'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    ELIF pTipo = 3 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'SOBREGIRO';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT SKIP pregistros FIRST precuperacion nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'SOBREGIRO'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    ELIF pTipo = 4 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'PAGARE';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT SKIP pregistros FIRST precuperacion nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'PAGARE'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
	ELIF pTipo = 5 THEN
        SELECT COUNT(*) 
        INTO iExiste
        FROM bdicheq:sc_cedulacontable
        WHERE fecha_concil = pFechaConcil
			AND concepto = 'INT PAGARE';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT SKIP pregistros FIRST precuperacion nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'INT PAGARE'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
		END IF;
	END IF;
     
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 27/06/2016',
'DESCRIPCION:Se agrego una consulta con el concepto de inteses de pagare para el pTipo = 5 de la consulta de cedulas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultacedulas2_totales( pFechaConcil DATE, pTipo SMALLINT )
RETURNING CHAR(5), INTEGER;
    
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iExiste          SMALLINT;
    DEFINE cNombre          CHAR(40);
    DEFINE cCtaContable     CHAR(14);
    DEFINE mSdoCheques      DECIMAL(18,2);
    DEFINE mSdoContab       DECIMAL(18,2);
    DEFINE mDifSaldos       DECIMAL(18,2);
    DEFINE cObservaciones   CHAR(255);
    DEFINE cEditable        CHAR(1);
    DEFINE vNoRegistros INTEGER;
	
    LET cCodRet1       = '000';
    LET cCodRet2       = '';
    LET cCodRet3       = '';
    LET iSqlErr	       = 0;
    LET iSamErr        = 0;
    LET cDesErr        = '';
    LET iExiste        = 0;
    LET cNombre        = '';
    LET cCtaContable   = '';
    LET mSdoCheques    = 0.00;
    LET mSdoContab     = 0.00;
    LET mDifSaldos     = 0.00;
    LET cObservaciones = '';
    LET cEditable      = '';
	LET vNoRegistros = 0;
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, vNoRegistros;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_consultacedulas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pFechaConcil is null OR pFechaConcil = '' ) OR
         ( pTipo is null OR pTipo NOT IN(1, 2, 3, 4, 5) ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1, vNoRegistros;
    END IF;
    
    IF pTipo = 1 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'CAPITAL';
           
        IF iExiste > 0 THEN
            --FOREACH
                SELECT COUNT(*)
				  INTO vNoRegistros
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'CAPITAL';
                   
                RETURN cCodRet1, vNoRegistros;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            --END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, vNoRegistros;
        END IF;
    ELIF pTipo = 2 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'INTERES';
           
        IF iExiste > 0 THEN
            --FOREACH
                SELECT COUNT(*)
				  INTO vNoRegistros
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'INTERES';
                   
                RETURN cCodRet1, vNoRegistros;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            --END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, vNoRegistros;
        END IF;
    ELIF pTipo = 3 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'SOBREGIRO';
           
        IF iExiste > 0 THEN
            --FOREACH
                SELECT COUNT(*)
				  INTO vNoRegistros
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'SOBREGIRO';
                   
                RETURN cCodRet1, vNoRegistros;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            --END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, vNoRegistros;
        END IF;
    ELIF pTipo = 4 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'PAGARE';
           
        IF iExiste > 0 THEN
            --FOREACH
                SELECT COUNT(*)
				  INTO vNoRegistros
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'PAGARE';
                   
                RETURN cCodRet1, vNoRegistros;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            --END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, vNoRegistros;
        END IF;
	ELIF pTipo = 5 THEN
        SELECT COUNT(*) 
        INTO iExiste
        FROM bdicheq:sc_cedulacontable
        WHERE fecha_concil = pFechaConcil
			AND concepto = 'INT PAGARE';
           
        IF iExiste > 0 THEN
            --FOREACH
                SELECT COUNT(*)
				INTO vNoRegistros
				FROM bdicheq:sc_cedulacontable
				WHERE fecha_concil = pFechaConcil
					AND concepto = 'INT PAGARE';
                   
               RETURN cCodRet1, vNoRegistros;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            --END FOREACH;
        ELSE
            LET cCodRet1 = '100';
           RETURN cCodRet1, vNoRegistros;
		END IF;
	END IF;
     
    END;
    
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 27/06/2016',
'DESCRIPCION:Se agrego una consulta para el total de inteses de pagare con el pTipo = 5 de la consulta de cedulas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultamovinversion(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio Date, pFechafin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		DATE AS fecha,
		CHAR(4) AS sucursal,
		DATE AS fecha_alt,
		CHAR(4) AS transaccion,
		CHAR(20) AS num_cuenta,
		CHAR(20) AS num_cte,
		SMALLINT AS secuencia,
		DECIMAL(18,2) AS monto_total,
		CHAR(14) AS cta_cargo,
		CHAR(14) AS cta_abono;	
		
	DEFINE cCodRet			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	define cFecha			DATE;
	DEFINE cSucursal		CHAR(4);
	DEFINE dFechaMov    	DATE;
	DEFINE cTransaccion 	CHAR(4) ;
	DEFINE cNumCuenta      	CHAR(20); 
	DEFINE cNumCte      	CHAR(20); 
	DEFINE dMontoTotal  	DECIMAL(18,2);
	DEFINE cCtaCargo    	CHAR(14);
	DEFINE cCtaAbono    	CHAR(14);
	DEFINE sSecuencia   	SMALLINT;
	DEFINE iNoRegistros 	INTEGER;
	DEFINE iRegistros   	INTEGER;
	DEFINE iRecuperacion    INTEGER;
	
	LET cCodRet 	  = '00000';
	LET iSqlErr 	  = 0;
	LET cFecha		  = '';
	LET cSucursal	  = '';
	LET dFechaMov     = '';
	LET cTransaccion  = '';
	LET cNumCuenta       = '';
	LET cNumCte       = '';
	LET dMontoTotal   = 0.00;
	LET cCtaCargo     = '';
	LET cCtaAbono     = '';
	LET sSecuencia    = 0;
	LET iNoRegistros  = 0;
	LET iRegistros    = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cFecha, cSucursal, dFechaMov, cTransaccion, cNumCuenta, cNumCte, sSecuencia, dMontoTotal, cCtaCargo, cCtaAbono;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultamovinversion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pFechaInicio IS NULL OR pFechafin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFecha, cSucursal, dFechaMov, cTransaccion, cNumCuenta, cNumCte, sSecuencia, dMontoTotal, cCtaCargo, cCtaAbono;
		END IF;	
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cFecha, cSucursal, dFechaMov, cTransaccion, cNumCuenta, cNumCte, sSecuencia, dMontoTotal, cCtaCargo, cCtaAbono;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFecha, cSucursal, dFechaMov, cTransaccion, cNumCuenta, cNumCte, sSecuencia, dMontoTotal, cCtaCargo, cCtaAbono;
		END IF;
		
		FOREACH 
			SELECT SKIP pRegistros FIRST pRecuperacion fecha, sucursal, fech_alt, transacc, cuenta, num_cte, monto_tot, secuencia, cta_cargo, cta_abono
			INTO cFecha, cSucursal, dFechaMov, cTransaccion, cNumCuenta, cNumCte, dMontoTotal, sSecuencia, cCtaCargo, cCtaAbono
			FROM bdinvers:"informix".sv_movsinver
			WHERE fecha >= pFechaInicio 
				AND fecha <= pFechafin
		
			LET iNoRegistros = iNoRegistros + 1;
			
			RETURN cCodRet, cFecha, cSucursal, dFechaMov, cTransaccion, cNumCuenta, cNumCte, sSecuencia, dMontoTotal, cCtaCargo, cCtaAbono WITH RESUME;
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cFecha, cSucursal, dFechaMov, cTransaccion, cNumCuenta, cNumCte, sSecuencia, dMontoTotal, cCtaCargo, cCtaAbono;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cFecha, cSucursal, dFechaMov, cTransaccion, cNumCuenta, cNumCte, sSecuencia, dMontoTotal, cCtaCargo, cCtaAbono;
		END IF;	
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angélica Hernández Pérez',
'FECHA: 15/06/2016',
'MODULO: CONCILIACIONES',
'FUNCIONALIDAD: MOVIMIENTOS DEL SISTEMA DE INVERSIONES (PAGARE)',
'DESCRIPCION: Spl que realiza la consulta de los movimientos del sistema de inversiones de los pagares.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultamovinversion_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio Date, pFechafin DATE)
		RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
		
	DEFINE cCodRet			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	DEFINE iNoRegistros 	INTEGER;
	
	LET cCodRet 	  = '00000';
	LET iSqlErr 	  = 0;
	LET iNoRegistros  = 0;
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consultamovinversion_totales.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pFechaInicio IS NULL OR pFechafin IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;	
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SELECT COUNT(*)
		INTO iNoRegistros
		FROM bdinvers:"informix".sv_movsinver
		WHERE fecha >= pFechaInicio 
			AND fecha <= pFechafin;
		
		RETURN cCodRet, iNoRegistros;
	
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 15/06/2016',
'MODULO: CONCILIACIONES',
'FUNCIONALIDAD: MOVIMIENTOS DEL SISTEMA DE INVERSIONES (PAGARE)',
'DESCRIPCION: Spl que realiza la consulta de los totales para los movimientos del sistema de inversiones de los pagares.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_finalizacedulas( pFechaConcil DATE, pTipo SMALLINT ) 
RETURNING CHAR(5);
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      SMALLINT;
    
    LET cCodRet1     = '000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr	     = 0;
    LET iSamErr      = 0;
    LET cDesErr      = '';
    LET iExiste      = 0;
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_finalizacedulas.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_finalizacedulas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pFechaConcil is null OR pFechaConcil = '' ) OR
         ( pTipo is null OR pTipo NOT IN(1, 2, 3, 4, 5) ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1;
    END IF;
    
    IF pTipo = 1 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'CAPITAL';
           
        IF iExiste > 0 THEN
            UPDATE bdicheq:sc_cedulacontable
               SET editable = '1'
             WHERE fecha_concil = pFechaConcil
               AND concepto = 'CAPITAL';
               
            RETURN cCodRet1;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1;
        END IF;
    ELIF pTipo = 2 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'INTERES';
           
        IF iExiste > 0 THEN
            UPDATE bdicheq:sc_cedulacontable
               SET editable = '1'
             WHERE fecha_concil = pFechaConcil
               AND concepto = 'INTERES';
               
            RETURN cCodRet1;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1;
        END IF;
    ELIF pTipo = 3 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'SOBREGIRO';
           
        IF iExiste > 0 THEN
            UPDATE bdicheq:sc_cedulacontable
               SET editable = '1'
             WHERE fecha_concil = pFechaConcil
               AND concepto = 'SOBREGIRO';
               
            RETURN cCodRet1;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1;
        END IF;
    ELIF pTipo = 4 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'PAGARE';
           
        IF iExiste > 0 THEN
            UPDATE bdicheq:sc_cedulacontable
               SET editable = '1'
             WHERE fecha_concil = pFechaConcil
               AND concepto = 'PAGARE';
               
            RETURN cCodRet1;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1;
        END IF;
    ELIF pTipo = 5 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'INT PAGARE';
           
        IF iExiste > 0 THEN
            UPDATE bdicheq:sc_cedulacontable
               SET editable = '1'
             WHERE fecha_concil = pFechaConcil
               AND concepto = 'INT PAGARE';
               
            RETURN cCodRet1;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1;
        END IF;
    END IF;
     
    END;
    
END PROCEDURE;