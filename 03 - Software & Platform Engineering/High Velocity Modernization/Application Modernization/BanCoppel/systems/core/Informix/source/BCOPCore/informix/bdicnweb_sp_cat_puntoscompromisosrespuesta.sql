CREATE PROCEDURE "informix".sp_cat_puntoscompromisosrespuesta(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		CHAR(5) AS cve_respuesta,
		CHAR(100) AS desc_respuesta;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCveRespuesta CHAR(5);
	DEFINE cDescRespuesta CHAR(100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCveRespuesta = '';
	LET cDescRespuesta = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCveRespuesta, cDescRespuesta;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cat_puntoscompromisosrespuesta.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCveRespuesta, cDescRespuesta;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCveRespuesta, cDescRespuesta;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH
			SELECT cve_respuesta, descripcion
			INTO cCveRespuesta, cDescRespuesta
			FROM "informix".cat_pcompromisos_respuesta
			
			RETURN cCodRet, cCveRespuesta, cDescRespuesta WITH RESUME;
		END FOREACH;	
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCveRespuesta, cDescRespuesta;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 20/02/2017',
'MODULO: CONSULTAS > APOYO',
'FUNCIONALIDAD: CONSULTAS DE PUNTOS COMPROMISOS',
'DESCRIPCION:SPL que consulta el catalo de respuesta',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_puntoscompro_metodocaptura(pUsuario CHAR(8), pIdFuncion CHAR(10))
        RETURNING CHAR(5) AS codret,
        CHAR(2) AS cve_metodo,
		CHAR(30) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
    DEFINE iCodRetSp INTEGER;
	DEFINE iErr INTEGER;
    DEFINE cCveMetodo CHAR(2);
    DEFINE cDescripcion CHAR(30);      
    DEFINE iRecuperacion INTEGER;
        
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '000000';
    LET iCodRetSp = 0;
	LET iErr =0;
    LET cCveMetodo = '';
    LET cDescripcion = '';
    LET iRecuperacion = 0;
   
	BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCveMetodo, cDescripcion;
		END EXCEPTION;
        
		--SET DEBUG FILE TO '/tmp/mfinis/sp_puntoscompro_metodocaptura.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCveMetodo, cDescripcion;
		END IF;
        
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN  cCodRet, cCveMetodo, cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH
            EXECUTE PROCEDURE intercard:"informix".sp_metodocaptura()  
            INTO iErr, cCveMetodo, cDescripcion
			
			IF iErr < 0 THEN 
				RAISE EXCEPTION iErr, 0, 'ERROR EN LA EJECUCIÓN DEL SP intercard:sp_metodocaptura';
			END IF;
			
            LET iRecuperacion = iRecuperacion + 1;
            RETURN cCodRet, cCveMetodo,  UPPER(TRIM(cDescripcion)) WITH RESUME;           
        END FOREACH;
		
		LET iRecuperacion = DBINFO('sqlca.sqlerrd2');
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCveMetodo, cDescripcion;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 13/02/2016',
'MODULO: CONSULTAS APOYO',
'FUNCIONALIDAD: CONSULTAS DE PUNTOS COMPROMISOS',
'DESCRIPCION:SPL Intermedio que consulta el catalogo de metodos de Captura',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_generacedulaintsisr( pEmpresa CHAR(3), pFecha DATE ) 
RETURNING CHAR(5);
    
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iTransacc        SMALLINT;
    DEFINE dFecha           DATE;
    DEFINE cProducto        CHAR(4);
    DEFINE cNombreProd      CHAR(40);
    DEFINE mIntsCalculados  DECIMAL(18,2);
    DEFINE mIntsPagados     DECIMAL(18,2);
    DEFINE mDifIntereses    DECIMAL(18,2);
    DEFINE mISRCalculado    DECIMAL(14,2);
    DEFINE mIsrCobrado      DECIMAL(18,2);
    DEFINE mDiferenciaISR   DECIMAL(14,2);
    DEFINE cObservaciones   CHAR(255);
    DEFINE cEditable        CHAR(1);
    
    LET cCodRet1        = '000';
    LET cCodRet2        = '';
    LET cCodRet3        = '';
    LET iSqlErr	        = 0;
    LET iSamErr         = 0;
    LET cDesErr         = '';
    LET iTransacc       = 0;
    LET dFecha          = '';
    LET cProducto       = '';
    LET cNombreProd     = '';
    LET mIntsCalculados = 0.00;
    LET mIntsPagados    = 0.00;
    LET mDifIntereses   = 0.00;
    LET mISRCalculado   = 0.00;
    LET mIsrCobrado     = 0.00;
    LET mDiferenciaISR  = 0.00;
    LET cObservaciones  = '';
    LET cEditable       = '0';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_generacedulaintsisr.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            IF iTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet1;
        END IF;
    END EXCEPTION;  
    
    on exception in (-535)
        let iTransacc = 1;
    end exception with resume;
	
	IF iTransacc = 1 THEN
       COMMIT WORK;
	   LET iTransacc = 0;
    END IF;
	
	--- SET DEBUG FILE TO "/tmp/sp_generacedulaintsisr.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pEmpresa is null OR pEmpresa = '' ) OR
         ( pFecha is null OR pFecha = '' ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1;
    END IF;
    
    FOREACH WITH HOLD
        SELECT fecha, producto, nombre, 
               SUM(interes_calculado), SUM(interes_pagado), SUM(diferencia_interes), 
               SUM(isr_calculado), SUM(isr_cobrado), SUM(diferencia_isr)
          INTO dFecha, cProducto, cNombreProd, 
               mIntsCalculados, mIntsPagados, mDifIntereses, 
               mISRCalculado, mIsrCobrado, mDiferenciaISR
          FROM bdicheq:sc_pagoints_cobroisr
         WHERE fecha = pFecha
         GROUP BY 1, 2, 3
         ORDER BY 1, 2
            
        BEGIN WORK;
        LET iTransacc = 1;
               
        INSERT INTO bdicheq:sc_intisrxprodcedula
        ( fecha, producto, nombre, interes_calculado, interes_pagado, diferencia_interes, isr_calculado, isr_cobrado, diferencia_isr, observaciones, editable )
        VALUES
        ( dFecha, cProducto, cNombreProd, mIntsCalculados, mIntsPagados, mDifIntereses, mISRCalculado, mIsrCobrado, mDiferenciaISR, cObservaciones, cEditable );
        
        COMMIT WORK;
        LET iTransacc = 0;
        
        LET dFecha = '';
        LET cProducto = '';
        LET cNombreProd = '';
        LET mIntsCalculados = 0.00;
        LET mIntsPagados = 0.00;
        LET mDifIntereses = 0.00;
        LET mISRCalculado = 0.00;
        LET mIsrCobrado = 0.00;
        LET mDiferenciaISR = 0.00;
    ENd FOREACH;
    
    END;
    
    RETURN cCodRet1;
    
END PROCEDURE;