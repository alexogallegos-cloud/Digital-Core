CREATE PROCEDURE "informix".sp_cau_consestatussolicitudes(psFecha CHAR(7))
RETURNING CHAR(5) AS codret, CHAR(100) AS mensajeret, CHAR(50) AS tipomov, INTEGER AS totales;

--****************************************************************************************************
-- DESCRIPCION : Consulta de relanzamiento realizados paralas tarjetas Coppel por mesa de control
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 2013/01/18
-- BD: bdisolic
-- SISTEMA : 
-- MODIFICADO : JUAN DANIEL LAZALDE CENTENO
-- FECHA DE MODIFICACION : 2013/02/14
/* DESCRIPCION DE LA MODIFICACION :
		En la consulta de relanzamientos de OA mostrar los status_nvo = 'OS' de cuentas solicitudes coppel (numero de producto = 6500) de la tabla ss_autorizacion_especial
		En solicitudes atendidas mostrar las solicitudes de cuentas coppel (numero de producto = 6500) de la tabla ss_autorizacion_especial
		En relanzamiento del SIC mostrar todos los relanzamientos de solicitud que aparescan mas de una ves en bdiburo.br_auditor; 
			El primer relanzamiento lo hace el sistema y los demás relanzamientos de solicitud lo efectua mesa de control en la tabla bdiburo.br_auditor.
*/
--****************************************************************************************************

--Declaracion de variables
DEFINE vcCodRet CHAR(5);
DEFINE vcMensajeRet CHAR(100);
DEFINE viSqlErr INTEGER;
DEFINE vcTipoMov CHAR(50);
DEFINE viTotales INTEGER;
DEFINE vcFechaIni CHAR(10);
DEFINE vcFechaFin DATE;
DEFINE viConSol INTEGER;
DEFINE vinsTit CHAR(1);

--Inicilizando variables
LET vcCodRet = '00000';
LET vcMensajeRet = 'PROCESO EXITOSO';
LET viSqlErr = '';
LET vcTipoMov = '';
LET viTotales = 0;

LET vcFechaIni = '';
LET vcFechaFin = '01/01/1900';
LET viConSol = 0; 
LET vinsTit = '';

--SET DEBUG FILE TO "/informix/c92962301/sp_cau_consestatussolicitudes.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr
	IF (viSqlErr <> 0) THEN
		RETURN viSqlErr, vcMensajeRet, vcTipoMov, viTotales;
	END IF;
END EXCEPTION;

LET vcFechaIni = SUBSTRING(psFecha FROM 1 FOR 3) || '01/' || SUBSTRING(psFecha FROM 4 FOR 4);
LET vcFechaFin = vcFechaIni;
LET vcFechaFin = vcFechaFin + INTERVAL(1) MONTH TO MONTH;
LET vcFechaFin = vcFechaFin - 1;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;


SELECT 'Relanzamiento de OA', COUNT(a.num_solicitud)
INTO vcTipoMov, viTotales
FROM bdisolic:'informix'.ss_solicitudes AS a
INNER JOIN bdisolic:'informix'.ss_autorizacion_especial AS b
ON a.empresa = b.empresa AND a.num_solicitud = b.num_solicitud
WHERE b.status_ant ='OA' AND b.status_nvo = 'EE' and a.num_producto = '6500'
AND b.fecha_modif BETWEEN vcFechaIni AND vcFechaFin;
RETURN vcCodRet, vcMensajeRet, vcTipoMov, viTotales WITH RESUME;


LET vcTipoMov = 'Relanzamiento de SIC';
/*FOREACH 
	
	SELECT COUNT(a.solicitud),institucion
	INTO viTotales, vinsTit
	FROM bdiburo:'informix'.br_auditor AS a
	WHERE a.solicitud like '6500%'
	AND a.fecha BETWEEN vcFechaIni AND vcFechaFin
	group by a.solicitud , institucion
	if (viTotales) > 1 then
	     LET viConSol = viConSol + (viTotales-1);
	end if;
END FOREACH;
*/
	SELECT COUNT(numsolicitud) INTO viConSol 
	FROM "informix".ss_mon_buro_rep
	WHERE empresa = '001'
	AND numsolicitud > ''
	AND fecha_reenvio BETWEEN vcFechaIni AND vcFechaFin
	AND producto ='6500'
	AND reenvio_exit='1';

	RETURN vcCodRet, vcMensajeRet, vcTipoMov, viConSol WITH RESUME;

SELECT 'Solicitudes Atendidas', COUNT (num_solicitud)
INTO vcTipoMov, viTotales
FROM bdisolic:'informix'.ss_solicitudes_mc 
WHERE num_producto ='6500' and revisado ='S'
AND fecha_insert BETWEEN vcFechaIni AND vcFechaFin;
RETURN vcCodRet, vcMensajeRet, vcTipoMov, viTotales WITH RESUME;


END
END PROCEDURE
