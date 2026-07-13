CREATE PROCEDURE "informix".sp_descripcionerrorconciliacion
(
psArchivoOrigen CHAR(3),
pdFechaInicial DATETIME YEAR TO FRACTION (5),
pdFechaFinal DATETIME YEAR TO FRACTION (5)
)

RETURNING INTEGER AS X, DATETIME YEAR TO FRACTION(5) AS FechaConciliacion, CHAR(10) AS TipoConciliacion, 
          CHAR(3) AS ArchivoOrigen, CHAR(20) AS NombreArchivo, CHAR(500) AS DescripcionError ;

--****************************************************************************************************
-- DESCRIPCION: Obtiene la descripcion de error de conciliacion en caso de que exista alguno
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 30/10/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica
--***************************************************************************************************

DEFINE viLlave INTEGER;
DEFINE vdFecConciliacion DATETIME YEAR TO FRACTION (5);
DEFINE vsTipoConciliacion CHAR(10);
DEFINE vsArchivoOrigen CHAR(3);
DEFINE vsNombreArchivo CHAR(20);
DEFINE vsDecripcionError CHAR(500);
DEFINE vsSecuenciaBitacora INTEGER;
DEFINE viSqlErr INTEGER;
DEFINE vdFechaAux DATETIME YEAR TO FRACTION (5);
DEFINE vsSecuenciaAux INTEGER;

LET viLlave = 0;
LET vdFecConciliacion = CURRENT;
LET vsTipoConciliacion = "";
LET vsArchivoOrigen = "";
LET vsNombreArchivo = "";
LET vsDecripcionError = "";
LET vsSecuenciaBitacora = 0;
LET viSqlErr = 0;
LET vdFechaAux = CURRENT;
LET vsSecuenciaAux =0;


BEGIN

ON EXCEPTION SET viSqlErr
	IF viSqlErr <> 0 THEN 
		RETURN viSqlErr, vdFecConciliacion, vsTipoConciliacion, vsArchivoOrigen, vsNombreArchivo, vsDecripcionError;
	END IF;
END EXCEPTION;

IF(pdFechaInicial = "") OR (pdFechaFinal IS NULL) THEN
    LET viSqlErr = 1 ;
	
    RETURN viSqlErr, vdFecConciliacion, vsTipoConciliacion, vsArchivoOrigen, vsNombreArchivo, vsDecripcionError;
		   
END IF;

IF (pdFechaInicial = "") OR (pdFechaFinal IS NULL) THEN
    LET viSqlErr = 2;
	
    RETURN viSqlErr, vdFecConciliacion, vsTipoConciliacion, vsArchivoOrigen, vsNombreArchivo, vsDecripcionError;

END IF;

IF( psArchivoOrigen = '') THEN
	SET ISOLATION TO DIRTY READ;
	IF EXISTS(SELECT descripcionerror FROM syserror_conciliacion WHERE fecha >= pdFechaInicial AND fecha <= pdFechaFinal) THEN
		LET vsTipoConciliacion = 'MANUAL';
		FOREACH
		SELECT monitorman.fechaconciliacion, monitorman.archivoorigen, syserror.descripcionerror
		INTO vdFecConciliacion, vsArchivoOrigen, vsDecripcionError 	
		FROM intercard:monitor_conciliacionman AS monitorman 
		INNER JOIN intercard:syserror_conciliacion AS syserror ON monitorman.secuenciabitacora = syserror.secuenciabitacora WHERE fechaconciliacion >= pdFechaInicial AND fechaconciliacion <= pdFechaFinal
			
		RETURN viLlave, vdFecConciliacion, vsTipoConciliacion, vsArchivoOrigen, '', vsDecripcionError WITH RESUME;
        END FOREACH;	
	END IF;	
ELSE
	IF EXISTS(SELECT descripcionerror FROM syserror_conciliacion WHERE fecha >= pdFechaInicial AND fecha <= pdFechaFinal) THEN
		LET vsTipoConciliacion = 'MANUAL';
		FOREACH
		SELECT monitorman.fechaconciliacion, monitorman.archivoorigen, syserror.descripcionerror
		INTO vdFecConciliacion, vsArchivoOrigen, vsDecripcionError 	
		FROM intercard:monitor_conciliacionman AS monitorman 
		INNER JOIN intercard:syserror_conciliacion AS syserror ON monitorman.secuenciabitacora = syserror.secuenciabitacora WHERE archivoorigen = psArchivoOrigen
		AND fechaconciliacion >= pdFechaInicial AND fechaconciliacion <= pdFechaFinal			
			
		RETURN viLlave, vdFecConciliacion, vsTipoConciliacion, vsArchivoOrigen, '', vsDecripcionError WITH RESUME;
        END FOREACH;	
	END IF;		
END IF;	
	
IF( psArchivoOrigen = '') THEN	

	IF EXISTS(SELECT descripcionerror FROM syserror_conciliacion WHERE fecha >= pdFechaInicial AND fecha <= pdFechaFinal) THEN
		LET vsTipoConciliacion = 'AUTOMATICA';
		FOREACH
		SELECT monitoraut.fechaconciliacion, monitoraut.archivoorigen, monitoraut.nom_archivo, syserror.descripcionerror
		INTO vdFecConciliacion, vsArchivoOrigen, vsNombreArchivo, vsDecripcionError 	
		FROM intercard:monitor_conciliacionaut AS monitoraut 
		INNER JOIN intercard:syserror_conciliacion AS syserror ON monitoraut.secuenciabitacora = syserror.secuenciabitacora WHERE fechaconciliacion >= pdFechaInicial AND fechaconciliacion <= pdFechaFinal
		
		RETURN viLlave, vdFecConciliacion, vsTipoConciliacion, vsArchivoOrigen, vsNombreArchivo, vsDecripcionError WITH RESUME;
		END FOREACH;    
	END IF;	
ELSE

	IF EXISTS(SELECT descripcionerror FROM syserror_conciliacion WHERE fecha >= pdFechaInicial AND fecha <= pdFechaFinal) THEN
		LET vsTipoConciliacion = 'AUTOMATICA';
		FOREACH
		SELECT monitoraut.fechaconciliacion, monitoraut.archivoorigen, monitoraut.nom_archivo, syserror.descripcionerror
		INTO vdFecConciliacion, vsArchivoOrigen, vsNombreArchivo, vsDecripcionError 	
		FROM intercard:monitor_conciliacionaut AS monitoraut 
		INNER JOIN intercard:syserror_conciliacion AS syserror ON monitoraut.secuenciabitacora = syserror.secuenciabitacora WHERE archivoorigen = psArchivoOrigen
		AND fechaconciliacion >= pdFechaInicial AND fechaconciliacion <= pdFechaFinal		
		
		RETURN viLlave, vdFecConciliacion, vsTipoConciliacion, vsArchivoOrigen, vsNombreArchivo, vsDecripcionError WITH RESUME;
		END FOREACH;
    END IF;
END IF;	

END
END PROCEDURE;