CREATE PROCEDURE "informix".sp_ccl_consintisrxproddetalle_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaConciliacion DATE, pProducto CHAR(4))
		RETURNING CHAR(5) AS codret,
		INTEGER AS totalRegistros;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iExiste = 0;

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iExiste;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ccl_consintisrxproddetalle_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaConciliacion IS NULL OR pProducto = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iExiste;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iExiste;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_consintisrxproddetalle2_totales(pFechaConciliacion, pProducto)
		INTO cCodRetSp, iExiste;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
		RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:sp_consintisrxproddetalle2_totales";
		ELIF iCodRetSp = 110  THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 100  THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iExiste;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 01/03/2017',
'MODULO: Conciliaciones',
'FUNCIONALIDAD: ConciliaciÃ³n de Intereses Pagados en Cuentas de CaptaciÃ³n',
'DESCRIPCION: Realiza la consulta de los total de los datos para el llenado del grid de la pantalla modal de la funcionalidad',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ccl_consultainteresisr(pUsuario CHAR(8), pIdFuncion CHAR(10), pfechaCedula DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				DATE			AS fechaConsultada,
				CHAR(4) 		AS producto, 
				CHAR(40)		AS nombreProducto, 
				DECIMAL(18,2)	AS interesCalculado, 
				DECIMAL(18,2)	AS interesPagado, 
				DECIMAL(18,2)	AS diferenciaInteres, 
				DECIMAL(18,2)	AS isrCalculado,
				DECIMAL(18,2)	AS isrPagado,
				DECIMAL(18,2)	AS ifernciaIsr;
		
	DEFINE cCodRet 		CHAR(5);	
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRetSp 	CHAR(5);
	DEFINE iCodRetSp 	INTEGER;
	DEFINE dFecha       DATE;
    DEFINE cProducto    CHAR(4);
    DEFINE cNombre      CHAR(40);
    DEFINE mInteresCalc DECIMAL(18,2);
    DEFINE mInteresPag  DECIMAL(18,2);
    DEFINE mDifInteres  DECIMAL(18,2);
    DEFINE mIsrCalc     DECIMAL(18,2);
    DEFINE mIsrPagado  	DECIMAL(18,2);
    DEFINE mDifIsr      DECIMAL(18,2);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET cCodRetSp 		= '';
	LET iCodRetSp 		= 0;
	LET dFecha       	= '';
    LET cProducto    	= '';
    LET cNombre      	= '';
    LET mInteresCalc 	= 0.00;
    LET mInteresPag  	= 0.00;
    LET mDifInteres  	= 0.00;
    LET mIsrCalc     	= 0.00;
    LET mIsrPagado  	= 0.00;
    LET mDifIsr      	= 0.00;
	LET iNoRegistros	= 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ccl_consultainteresisr.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pfechaCedula IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdicheq:"informix".sp_consintisrxprod2(pfechaCedula, pRegistros, pRecuperacion)
			INTO cCodRetSp, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:sp_consintisrxprod2";
			ELIF iCodRetSp = 110  THEN
				LET cCodRet = '00003';
			ELIF iCodRetSp = 100  THEN
				LET cCodRet = '00017';
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, dFecha, NVL(cProducto,""), NVL(UPPER(TRIM(cNombre)),""), NVL(mInteresCalc,0), NVL(mInteresPag,0), NVL(mDifInteres,0), NVL(mIsrCalc,0), NVL(mIsrPagado,0), NVL(mDifIsr,0) WITH RESUME;
		END FOREACH;

		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFecha, cProducto, cNombre, mInteresCalc, mInteresPag, mDifInteres, mIsrCalc, mIsrPagado, mDifIsr;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 01/03/2017',
'MODULO: Conciliaciones',
'FUNCIONALIDAD: ConciliaciÃ³n de Intereses Pagados en Cuentas de CaptaciÃ³n',
'DESCRIPCION: Realiza la consulta de los datos para el llenado del grid pricipal de la funcionalidad',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ccl_consultainteresisr_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaConciliacion DATE)
		RETURNING CHAR(5) AS codret,
		INTEGER AS totalRegistros;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iExiste = 0;

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iExiste;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ccl_consultainteresisr_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaConciliacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iExiste;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iExiste;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_consintisrxprod2_totales(pFechaConciliacion)
		INTO cCodRetSp, iExiste;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
		RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:sp_consintisrxprod2_totales";
		ELIF iCodRetSp = 110  THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 100  THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iExiste;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 01/03/2017',
'MODULO: Conciliaciones',
'FUNCIONALIDAD: ConciliaciÃ³n de Intereses Pagados en Cuentas de CaptaciÃ³n',
'DESCRIPCION: Realiza la consulta de los total de los datos para el llenado del grid pricipal de la funcionalidad',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ccl_finalizacedulainterescap(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE)
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ccl_finalizacedulainterescap.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_finintisrxprodcedula(pFecha)
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:sp_finintisrxprodcedula";
		ELIF iCodRetSp = 110  THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 100  THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 06/03/2017',
'MODULO: Conciliaciones',
'FUNCIONALIDAD: CÃ©dula Contable de Intereses Pagados en Cuentas de CaptaciÃ³n',
'DESCRIPCION: Finaliza la cedula impidiendo la modificacion de esta',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_usuarioscedulas( pFechaConcil DATE, pTipo SMALLINT ) 
RETURNING CHAR(5), CHAR(104), SMALLINT;
    
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iExiste          SMALLINT;
    DEFINE cNombre          CHAR(104);
    DEFINE iFuncion         SMALLINT;
    
    LET cCodRet1         = '000';
    LET cCodRet2         = '';
    LET cCodRet3         = '';
    LET iSqlErr	         = 0;
    LET iSamErr          = 0;
    LET cDesErr          = '';
    LET iExiste          = 0;
    LET cNombre          = '';
    LET iFuncion         = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_usuarioscedulas.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_usuarioscedulas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pFechaConcil is null OR pFechaConcil = '' ) OR
         ( pTipo is null OR pTipo NOT IN(1, 2, 3, 4, 5, 6) ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1, cNombre, iFuncion;
    END IF;
    
    IF pTipo = 1 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontableusuarios
         WHERE concepto = 'CAPITAL'
           AND status = '1';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, funcion
                  INTO cNombre, iFuncion
                  FROM bdicheq:sc_cedulacontableusuarios
                 WHERE concepto = 'CAPITAL'
                   AND status = '1'
                 
                RETURN cCodRet1, cNombre, iFuncion WITH RESUME;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    ELIF pTipo = 2 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontableusuarios
         WHERE concepto = 'INTERES'
           AND status = '1';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, funcion
                  INTO cNombre, iFuncion
                  FROM bdicheq:sc_cedulacontableusuarios
                 WHERE concepto = 'INTERES'
                   AND status = '1'
                 
                RETURN cCodRet1, cNombre, iFuncion WITH RESUME;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    ELIF pTipo = 3 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontableusuarios
         WHERE concepto = 'SOBREGIRO'
           AND status = '1';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, funcion
                  INTO cNombre, iFuncion
                  FROM bdicheq:sc_cedulacontableusuarios
                 WHERE concepto = 'SOBREGIRO'
                   AND status = '1'
                 
                RETURN cCodRet1, cNombre, iFuncion WITH RESUME;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    ELIF pTipo = 4 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontableusuarios
         WHERE concepto = 'PAGARE'
           AND status = '1';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, funcion
                  INTO cNombre, iFuncion
                  FROM bdicheq:sc_cedulacontableusuarios
                 WHERE concepto = 'PAGARE'
                   AND status = '1'
                 
                RETURN cCodRet1, cNombre, iFuncion WITH RESUME;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    ELIF pTipo = 5 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontableusuarios
         WHERE concepto = 'INT PAGARE'
           AND status = '1';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, funcion
                  INTO cNombre, iFuncion
                  FROM bdicheq:sc_cedulacontableusuarios
                 WHERE concepto = 'INT PAGARE'
                   AND status = '1'
                 
                RETURN cCodRet1, cNombre, iFuncion WITH RESUME;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    ELIF pTipo = 6 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontableusuarios
         WHERE concepto = 'INTS E ISR'
           AND status = '1';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, funcion
                  INTO cNombre, iFuncion
                  FROM bdicheq:sc_cedulacontableusuarios
                 WHERE concepto = 'INTS E ISR'
                   AND status = '1'
                 
                RETURN cCodRet1, cNombre, iFuncion WITH RESUME;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    END IF;
    
    END;
    
END PROCEDURE;