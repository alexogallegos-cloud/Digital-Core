CREATE PROCEDURE "informix".sp_grabarerrores(pArchivo CHAR(16), pCodigoError CHAR(6),pTipoError CHAR(1), pSPllamdo CHAR(40), pMensaje CHAR(200),pMostrado CHAR(1) )
RETURNING CHAR(6);
    --*************************************************
	--Creado por: Anselmo Verdugo                   --*
	-- Actividad: Realiza registro a la tabla bdilide:sl_errores.
    --  Solicitó: Aymme Osuna                       --*
	--     Fecha: 10/SEP/2008                       --*
    --*************************************************

-- DEFINICIÓN DE LAS VARIABLES.
DEFINE vcCodRet CHAR(6);
DEFINE sql_err  INTEGER;
DEFINE vdFechaError DATE;
DEFINE vdHoraError DATETIME hour to fraction(3);

        --MANEJADOR DE EXEPCIONES
        ON EXCEPTION SET sql_err
            LET vcCodRet = sql_err;
            RETURN vcCodRet;
        END EXCEPTION;


	--INICIALIZACIÓN DE VARIABLES
	LET vcCodRet = '000';
	
	--SELECT NVL(fecha_hoy,'01/01/1900')   INTO vdFechaError  FROM bdinteg:si_fechas; 
    LET vdFechaError  = CURRENT::DATE;
    LET vdHoraError = CURRENT hour to fraction(3);

    IF (pArchivo = '' or pArchivo IS NULL) or (pCodigoError = '' or pCodigoError IS NULL) or (pTipoError = '' or pTipoError IS NULL) THEN
        LET vcCodRet = '001';
        RETURN vcCodRet;
    END IF; 

    IF NOT EXISTS( select nombre_arch from bdilide:sl_archsat where nombre_arch = pArchivo ) THEN
        LET pCodigoError = '-691';
        LET pTipoError = 'P';
        LET pSPllamdo = 'sp_grabarErrores';
        LET pMensaje = 'No se puede hacer registro en sl_errores con el archivo: ' || pArchivo || ' ya que no existe en la tabla sl_archsat.';
        LET pArchivo = 'GENERICO';
    END IF;

    INSERT INTO bdilide:sl_errores VALUES(pArchivo,vdFechaError,vdHoraError,pCodigoError,pTipoError,pSPllamdo,pMensaje,pMostrado );

RETURN vcCodRet;

END PROCEDURE;