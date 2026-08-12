CREATE PROCEDURE "informix".sp_consulta_status_solic_wsp( pnum_solicitud CHAR(20),
ptipo_Consulta CHAR(1),
presponse_code CHAR(32),
pu_id CHAR(64))
RETURNING CHAR(6) AS codret, CHAR(20) AS nombre, CHAR(13) AS num_cel, CHAR(20) AS num_solicitud, CHAR(2) AS status_solicitud, CHAR(1) AS canal_sol, DATETIME YEAR TO SECOND AS fecha_insert, CHAR(4) AS num_producto, CHAR(20) AS numctebanco, CHAR(20) AS numctecoppel, CHAR(4) AS sucursal, CHAR(20) AS gen1, CHAR(20) AS gen2;

	-----------------------------------------------------------------------------------------
		--Autor: Cecilia Fernanda HernÃ¡ndez Baez
		--27-07-2022
		--SP para realizar consultas a la tabla de trabajo status_solic_wsp para saber en que status se encuentran
		--las solicitudes de credito y hacer un respaldo de los registros ya procesados de la tabla ss_status_solic_wsp
		-- a la tabla ss_status_solic_wsp_hist.
		--Solicita: Maria Nereyda De La O Beltran
	-----------------------------------------------------------------------------------------
		--Modifico: Luis Enrique Moo Varguez
		--29-06-2023
		--Se agrega el campo fecha_solicitud a las tablas ss_status_solic_wsp y ss_status_solic_wsp_hist donde se registra
		--la fecha_insert de la tabla ss_solicitudes. De igual manera se agrega validacion por producto 6500 y una secmentacion
		--por el ultimo digito del cliente para enviar como testigo a la ss_status_solic_wsp_hist.
		--Solicitantes: Mayra Quiroz / Miguel Olivas
	-----------------------------------------------------------------------------------------
		--Modifico: Kevin Galvez Parra
		--15-08-2023
		--Se agrega valores de retorno de Fecha Solicitud, numero del producto, numero de cliente banco, 
		--numero cliente coppel, el numero de sucursal y 2 valores genericos. Al igual que se hizo un ajuste
		--de las validaciones y campos de las tablas ss_status_solic_wsp y ss_status_solic_wsp_hist 
		--incluyendo estas nuevas variables.
		--Solicitantes: Mayra Quiroz / Miguel Olivas
	-----------------------------------------------------------------------------------------


DEFINE iCodRet INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE cNumcte CHAR(20);
DEFINE cNombre CHAR(110);
DEFINE cNumCel CHAR(13);
DEFINE cNumSolicitud CHAR(20);
DEFINE cStatusSolicitud CHAR(2);
DEFINE cCanalSol CHAR(1);
DEFINE dFechaInsert DATETIME YEAR TO SECOND;
DEFINE response_code CHAR(32);
DEFINE u_id CHAR(64);
DEFINE cNumSolicitudConsulta CHAR(20);
DEFINE istatusProceso CHAR(2);
DEFINE idiferencia INTEGER;
DEFINE dFechaProceso DATETIME YEAR TO SECOND;

DEFINE cNumcte_np CHAR(20);
DEFINE cNombre_np CHAR(110);
DEFINE cNumCel_np CHAR(13);
DEFINE cNumSolicitud_np CHAR(20);
DEFINE cStatusSolicitud_np CHAR(2);
DEFINE cCanalSol_np CHAR(1);
DEFINE dFechaInsert_np DATETIME YEAR TO SECOND;
DEFINE istatusProceso_np CHAR(2);
DEFINE dFechaProceso_np DATETIME YEAR TO SECOND;

--Se agrega campo de fecha solicitud
DEFINE cFechaSolicitud DATE;
DEFINE vFechaProceso DATETIME YEAR TO SECOND;
--Se agregan los siguientes campos
DEFINE cNumProducto CHAR(4);
DEFINE cNumCteCoppel CHAR(20);
DEFINE cSecuencia INTEGER;
DEFINE cSucursal CHAR(4);
DEFINE gen1 CHAR(20);
DEFINE gen2 CHAR(20);

LET iCodRet = 0;
LET cCodRet = '00000';
LET cNumcte = '';
LET cNombre = '';
LET cNumCel = '';
LET cNumSolicitud = '';
LET cStatusSolicitud = '';
LET cCanalSol = '';
LET dFechaInsert = '';
LET response_code = presponse_code;
LET u_id = pu_id;
LET cNumSolicitudConsulta = '';
LET istatusProceso = '';
LET idiferencia = 0;
LET dFechaProceso = '';

LET cNumcte_np = '';
LET cNombre_np = '';
LET cNumCel_np = '';
LET cNumSolicitud_np = '';
LET cStatusSolicitud_np = '';
LET cCanalSol_np = '';
LET dFechaInsert_np = '';
LET istatusProceso_np = '';
LET dFechaProceso_np = '';
LET cNumProducto = '';
LET cNumCteCoppel = '';
LET cSecuencia = 0;
LET cSucursal = '';
LET gen1 = '';
LET gen2 = '';


BEGIN
ON EXCEPTION SET iCodRet
LET cCodRet = iCodRet;
RETURN cCodRet, cNombre, cNumCel, cNumSolicitud, cStatusSolicitud, cCanalSol, dFechaInsert, cNumProducto, cNumCte, cNumCteCoppel, cSucursal, gen1, gen2;
END EXCEPTION;

--SET debug file to '/tmp/sp_consulta_status_solic_wsp.out';
--trace on;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

IF ptipo_Consulta IS NULL THEN
LET cCodRet = '000001'; ---Status vacio
RETURN cCodRet, cNombre, cNumCel, cNumSolicitud, cStatusSolicitud, cCanalSol, dFechaInsert, cNumProducto, cNumCte, cNumCteCoppel, cSucursal, gen1, gen2;
END IF;


IF ptipo_Consulta = '1' AND (pnum_solicitud IS NULL OR pnum_solicitud ='')
THEN


FOREACH
	SELECT numcte, nombre, num_cel, num_solicitud, status_solicitud, canal_sol, fecha_insert, status_proceso, fecha_proceso, fecha_solicitud, num_producto, secuencia, sucursal, numctecoppel
    INTO cNumcte_np, cNombre_np, cNumCel_np, cNumSolicitud_np, cStatusSolicitud_np, cCanalSol_np, dFechaInsert_np, istatusProceso_np, dFechaProceso_np, cFechaSolicitud, cNumProducto, cSecuencia, cSucursal, cNumCteCoppel
    FROM (
    SELECT {+ INDEX ("informix".ss_status_solic_wsp idx_solic_wsp_fecha_insert)} numcte, nombre, num_cel, num_solicitud, status_solicitud, canal_sol, fecha_insert, status_proceso, fecha_proceso, fecha_solicitud, num_producto, secuencia, sucursal, numctecoppel
    FROM "informix".ss_status_solic_wsp
    WHERE 
     DAY(fecha_insert) <> DAY(CURRENT))

    IF cNombre_np IS NOT NULL THEN
        INSERT INTO "informix".ss_status_solic_wsp_hist(numcte, nombre, num_cel, num_solicitud, status_solicitud, canal_sol, fecha_insert, response_code, response_id, fecha_solicitud, num_producto, secuencia, sucursal, numctecoppel)
        VALUES(cNumcte_np,cNombre_np, cNumCel_np, cNumSolicitud_np, cStatusSolicitud_np, cCanalSol_np, current, 'No Procesado', null, cFechaSolicitud, cNumProducto, cSecuencia, cSucursal, cNumCteCoppel);

        IF DBINFO('SQLCA.SQLERRD2')>0 THEN
            DELETE FROM "informix".ss_status_solic_wsp
            WHERE num_solicitud = cNumSolicitud_np;
        END IF;
    END IF;
	
END FOREACH;




LET vFechaProceso = (SELECT {+ INDEX ("informix".ss_status_solic_wsp idx_solic_wsp_status_fecha)} MIN (fecha_proceso) FROM ss_status_solic_wsp where fecha_proceso IS NOT NULL);
SELECT LIMIT 1 numcte, nombre, num_cel, num_solicitud, status_solicitud, canal_sol, fecha_insert, status_proceso, fecha_proceso, fecha_solicitud, num_producto, secuencia, sucursal, numctecoppel
INTO cNumCte, cNombre, cNumCel, cNumSolicitud, cStatusSolicitud, cCanalSol, dFechaInsert, istatusProceso, dFechaProceso, cFechaSolicitud, cNumProducto, cSecuencia, cSucursal, cNumCteCoppel
FROM (
SELECT  numcte, nombre, num_cel, num_solicitud, status_solicitud, canal_sol, fecha_insert, status_proceso, fecha_proceso, fecha_solicitud, num_producto, secuencia, sucursal, numctecoppel
FROM "informix".ss_status_solic_wsp
WHERE (status_proceso = '0' AND fecha_proceso = vFechaProceso)
OR (status_proceso = '1'
AND fecha_proceso = vFechaProceso
and (SELECT CAST ((current - fecha_proceso) as interval second(9) to second)::VARCHAR(12)::INT as dif from systables where tabid=1) > 30)
ORDER BY  fecha_proceso asc);

IF DBINFO('SQLCA.SQLERRD2')>1 THEN
LET cCodRet = '000002';
RETURN cCodRet, cNombre, cNumCel, cNumSolicitud, cStatusSolicitud, cCanalSol, dFechaInsert, cNumProducto, cNumCte, cNumCteCoppel, cSucursal, gen1, gen2;
END IF;

IF cNumCte IS NULL AND cNombre IS NULL AND cNumCel IS NULL AND cNumSolicitud IS NULL AND cStatusSolicitud IS NULL AND cCanalSol IS NULL AND dFechaInsert IS NULL THEN
LET cCodRet = '000002';
RETURN cCodRet, cNombre, cNumCel, cNumSolicitud, cStatusSolicitud, cCanalSol, dFechaInsert, cNumProducto, cNumCte, cNumCteCoppel, cSucursal, gen1, gen2;
END IF;

update "informix".ss_status_solic_wsp set status_proceso = '1', fecha_proceso = current
where num_solicitud = cNumSolicitud;



RETURN cCodRet, cNombre, cNumCel, cNumSolicitud, cStatusSolicitud, cCanalSol, dFechaInsert, cNumProducto, cNumCte, cNumCteCoppel, cSucursal, gen1, gen2;



-- fecha_insert = (SELECT MIN (fecha_insert)
-- FROM ss_status_solic_wsp);

IF DBINFO('SQLCA.SQLERRD2')=0 AND cNumCte IS NULL AND cNombre IS NULL AND cNumCel IS NULL THEN
LET cCodRet = '000002';
RETURN cCodRet, cNombre, cNumCel, cNumSolicitud, cStatusSolicitud, cCanalSol, dFechaInsert, cNumProducto, cNumCte, cNumCteCoppel, cSucursal, gen1, gen2;
END IF;


END IF;








IF ptipo_Consulta = '2' AND pnum_solicitud IS NOT NULL THEN
SELECT
 numcte, nombre, num_cel, num_solicitud, status_solicitud, canal_sol, fecha_insert, status_proceso, fecha_proceso, fecha_solicitud, num_producto, secuencia, sucursal, numctecoppel
INTO cNumCte, cNombre, cNumCel, cNumSolicitud, cStatusSolicitud, cCanalSol, dFechaInsert, istatusProceso, dFechaProceso, cFechaSolicitud, cNumProducto, cSecuencia, cSucursal, cNumCteCoppel
FROM "informix".ss_status_solic_wsp
WHERE num_solicitud = pnum_solicitud;

IF DBINFO('SQLCA.SQLERRD2')>1 THEN
LET cCodRet = '000002';
RETURN cCodRet, cNombre, cNumCel, cNumSolicitud, cStatusSolicitud, cCanalSol, dFechaInsert, cNumProducto, cNumCte, cNumCteCoppel, cSucursal, gen1, gen2;
END IF;

IF cNumCte IS NULL AND cNombre IS NULL AND cNumCel IS NULL AND cNumSolicitud IS NULL AND cStatusSolicitud IS NULL AND cCanalSol IS NULL AND dFechaInsert IS NULL THEN
LET cCodRet = '000002';
RETURN cCodRet, cNombre, cNumCel, cNumSolicitud, cStatusSolicitud, cCanalSol, dFechaInsert, cNumProducto, cNumCte, cNumCteCoppel, cSucursal, gen1, gen2;
END IF;

INSERT INTO "informix".ss_status_solic_wsp_hist(numcte, nombre, num_cel, num_solicitud, status_solicitud, canal_sol, fecha_insert, response_code, response_id, fecha_solicitud, num_producto, secuencia, sucursal, numctecoppel)
VALUES(cNumcte,cNombre, cNumCel, cNumSolicitud, cStatusSolicitud, cCanalSol, current, 'Cliente Piloto', pu_id, cFechaSolicitud, cNumProducto, cSecuencia, cSucursal, cNumCteCoppel);

IF DBINFO('SQLCA.SQLERRD2')>0 THEN
DELETE FROM "informix".ss_status_solic_wsp
WHERE num_solicitud = pnum_solicitud;
END IF;

IF cNumCte IS NULL AND cNombre IS NULL AND cNumCel IS NULL AND cNumSolicitud IS NULL AND cStatusSolicitud IS NULL AND cCanalSol IS NULL AND dFechaInsert IS NULL THEN
LET cCodRet = '000002';
RETURN cCodRet, cNombre, cNumCel, cNumSolicitud, cStatusSolicitud, cCanalSol, dFechaInsert, cNumProducto, cNumCte, cNumCteCoppel, cSucursal, gen1, gen2;
END IF;

RETURN cCodRet, cNombre, cNumCel, cNumSolicitud, cStatusSolicitud, cCanalSol, dFechaInsert, cNumProducto, cNumCte, cNumCteCoppel, cSucursal, gen1, gen2;


END IF;

LET cCodRet = '00002';
RETURN cCodRet, cNombre, cNumCel, cNumSolicitud, cStatusSolicitud, cCanalSol, dFechaInsert, cNumProducto, cNumCte, cNumCteCoppel, cSucursal, gen1, gen2;
--Validacion tipo de consulta FIN
END;
END PROCEDURE;