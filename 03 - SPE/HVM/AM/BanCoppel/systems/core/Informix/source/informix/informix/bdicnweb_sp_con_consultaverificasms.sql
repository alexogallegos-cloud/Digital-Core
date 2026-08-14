CREATE PROCEDURE "informix".sp_con_consultaverificasms(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechIni DATE, pFechFin DATE , pRegistros INTEGER, pRecuperacion INTEGER)
			RETURNING CHAR(5) AS codret,
			CHAR(10) AS Fecha,
			INTEGER AS Validos,
			INTEGER AS No_Validos,
			INTEGER AS Total,
			INTEGER AS total_validos,
			INTEGER AS total_novalidos,
			INTEGER AS resultado_total;	
		
		DEFINE cCodRet CHAR(5);
		DEFINE iSqlErr INTEGER;
		DEFINE cCodRetSp CHAR(5);
		DEFINE iCodRetSp INTEGER;
		DEFINE cFecha CHAR(10);
		DEFINE iValidos INTEGER;
		DEFINE iNoValidos INTEGER;
		DEFINE iTotal INTEGER;
		DEFINE iTotalValidos INTEGER;
		DEFINE iTotalNoValidos INTEGER;
		DEFINE iResultadoTotal INTEGER;
		DEFINE iNoRegistros INTEGER;
	
		LET cCodRet = '00000';
		LET iSqlErr = 0;
		LET cCodRetSp = '';
		LET iCodRetSp = 0;
		LET cFecha = '';
		LET iValidos = 0;
		LET iNoValidos = 0;
		LET iTotal = 0;
		LET iTotalValidos = 0;
		LET iTotalNoValidos = 0;
		LET iResultadoTotal = 0;
		LET iNoRegistros = 0;	
	
		BEGIN	
				ON EXCEPTION SET iSqlErr
						LET cCodRet = iSqlErr;
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal;
				END EXCEPTION;
			
				--SET DEBUG FILE TO '/tmp/mfinis/sp_con_consultaverificasms.out';
				--TRACE ON;
		
				IF pUsuario = '' OR pIdFuncion = '' OR  pFechIni IS NULL OR pFechFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
						LET cCodRet = '00003';
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal;
				END IF;
				
				-- VALIDACION DE LA PAGINACION
				IF pRegistros < 0 OR pRecuperacion < 0 THEN
						LET cCodRet = '00098';
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal;
				END IF;
		
				-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
				IF cCodRet <> '00000' THEN
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal;
				END IF;
				-- OBTIENE SUMA TOTALES
				FOREACH
						EXECUTE PROCEDURE bdinteg:"informix".sp_verifica_sms(pFechIni, pFechFin)
						INTO cCodRetSp, cFecha, iValidos, iNoValidos, iTotal
						
						LET iCodRetSp = cCodRetSp::INTEGER;
						IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_verifica_sms';		
						END IF;
			
						LET iTotalValidos = iTotalValidos + iValidos;
						LET iTotalNoValidos = iTotalNoValidos + iNoValidos;
						LET iResultadoTotal = iResultadoTotal + iTotal;	
				END FOREACH
				--OBTIENE DETALLES DE LA CONSULTA
				FOREACH
						EXECUTE PROCEDURE bdinteg:"informix".sp_verifica_sms2(pFechIni, pFechFin, pRegistros, pRecuperacion)
						INTO cCodRetSp, cFecha, iValidos, iNoValidos, iTotal
						
						LET iCodRetSp = cCodRetSp::INTEGER;
						IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_verifica_sms2';		
						END IF;									
		
						LET iNoRegistros = iNoRegistros + 1;
		
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal WITH RESUME;
		
				END FOREACH
		
				IF iNoRegistros = 0 AND pRegistros = 0 THEN			
						LET cCodRet = '00017';
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal;
				ELIF iNoRegistros = 0 AND pRegistros > 0 THEN 
						LET cCodRet = '1001';		
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal;
				END IF;	
		END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 12/11/2015',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: Reporte Procesos Sucursal',
'DESCRIPCION: SPL que consulta la verificaciÃ³n de sms del Reporte Procesos Sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actualizacedulas( pFechaConcil DATE, pCtaContable CHAR(14), pObservaciones CHAR(255) )
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
        SET DEBUG FILE TO "/tmp/sp_actualizacedulas.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_actualizacedulas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pFechaConcil is null OR pFechaConcil = '' ) OR
         ( pCtaContable is null OR pCtaContable = '' ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1;
    END IF;
    
    SELECT COUNT(*) 
      INTO iExiste
      FROM bdicheq:sc_cedulacontable
     WHERE fecha_concil = pFechaConcil
       AND cta_contable = pCtaContable
       AND editable = '0';
       
    IF iExiste > 0 THEN
        UPDATE bdicheq:sc_cedulacontable
           SET observaciones = pObservaciones
         WHERE fecha_concil = pFechaConcil
           AND cta_contable = pCtaContable;
    ELSE
        LET cCodRet1 = '100';
        RETURN cCodRet1;
    END IF;
    
    RETURN cCodRet1;
     
    END;
    
END PROCEDURE;