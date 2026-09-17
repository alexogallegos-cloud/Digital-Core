CREATE PROCEDURE "informix".sp_valfecha_banca_gdf(pCodPais 	  CHAR(3),
			    		pFechaActual DATE)
RETURNING
    VARCHAR(5),         -- CodigoRetorno
    DATE;               -- Fecha Habil del bloque


/* 
***************************************************************************
REALIZO: ING CRUZ
FECHA: 21/06/2013
DESCRIPCION: VALIDA SI EL DIA ACTUAL ES FERIADO Y OBTIENE EL SIGUIENTE
			 DIA HABIL.
*************************************************************************** 
*/

DEFINE cVarDataErr      VARCHAR(64);
DEFINE iSqlErr          INTEGER;
DEFINE iSamErr          INTEGER;

DEFINE cCodRet          CHAR(5);
DEFINE dFechaProx        DATE;

	--SET DEBUG FILE TO "/home/informix/bibiana/sp_sac_valfecha_banca_gdf.out";
	--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET cCodret=iSqlErr;
            RETURN cCodret, cVarDataErr;
        END IF;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 10;
	SET ISOLATION TO DIRTY READ;
	
	SELECT fecha_prox
	INTO dFechaProx       
	FROM bdinteg:si_feriado_banca
	WHERE fecha = pFechaActual
    AND pais = pCodPais and laborable = "N";
	
	IF(TRIM(NVL(dFechaProx,''))=='')THEN
		LET dFechaProx = pFechaActual;
	END IF;
	
   RETURN '000',dFechaProx;
END
END PROCEDURE;