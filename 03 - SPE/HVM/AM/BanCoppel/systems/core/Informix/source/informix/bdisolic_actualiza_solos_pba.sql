CREATE PROCEDURE "informix".actualiza_solos_pba(o_empresa       CHAR(3),
                             o_num_solicitud CHAR(20),
                             o_fecha         DATE,
                             o_status        CHAR(1))

-- Control de Cambios
-----------------------------------------------------------------------------------
--Modificación #1
--Juan Andrés Coronel M.
--14-08-2007
--Que al recibir una respuesta 'D' en la orden de supervisión la solicitud cambie 
--al estatus 'OA'.
--Que solo permita cambiar de estatus una solicitud que esté en estatus 'EE' ú 
--'OS'(nuevo).
--Que cada vez que cambie de estatus, actualizar en ss_autorización el campo 
--fecha_salida al estatus que acaba de abandonar la solicitud.
--21-08-2007, Juan A. Coronel M, usar la fecha del servidor como fecha actual, 
--en vez del calendario, para actualizar campos de fecha
-----------------------------------------------------------------------------------
--Modificó: Viridiana Osobampo
--Descripción; Se modifica para asignar una clave de rechazo a la solicitud cuando 
--ésta sea rechazada por orden de supervisión.
--Fecha: 26-04-2010
--Petición: RQM 09 171 - Arbol de análisis de solicitudes de crédito.
-----------------------------------------------------------------------------------
-- Autor:  Jesús Manuel Aguilar Heredia
-- Modificación:  Se modifica para enviar a revision de lineas de credito a solicitudes que cuenten con un ingreso mensual mayor a 7,000 pesos y que cuente con un comprobante de ingresos digitalizado, antes de que se les autorice
-- Fecha de Modificación: 24-11-2011
-- Petición: RQM 09 180 Revisión de línea de crédito por CAC
--------------------------------------------------------------------------------
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE vStatusSol       CHAR(2);
DEFINE vHoy             DATE;
define dFechaEnt        DATE;
DEFINE vCausaSol        CHAR(3);
DEFINE P_COD_RET   VARCHAR(5);
DEFINE cNumcte   CHAR(20);
DEFINE cCodRet   CHAR(6);
DEFINE cMensajeRet   CHAR(100);
DEFINE iValido   INTEGER;
DEFINE cSucursal   CHAR(4);
DEFINE cNumProd   CHAR(4);
DEFINE dMontoAut   DECIMAL(18,2);
DEFINE vMensajeStatus         CHAR(80);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET vStatusSol  = "??";
LET vHoy  = DATE(1);
LET dFechaEnt  =  DATE(1);
LET vCausaSol   = "";
LET P_COD_RET   = "";
LET cNumcte   = "";
LET cCodRet   = "";
LET cMensajeRet   = "";
LET iValido   = 0;
LET cSucursal   = "";
LET cNumProd   = "";
LET dMontoAut   = 0;
LET vMensajeStatus="";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SELECT fecha_hoy INTO vHoy FROM bdicred:sd_fechas WHERE empresa = o_empresa;
SELECT current year to day INTO vHoy FROM bdisolic:"informix".dual;
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

--SET DEBUG FILE TO "actualiza_solos.out";
--TRACE ON;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

         SELECT status_solicitud,numcte,sucursal,num_producto,monto_solicitado
			INTO vStatusSol,cNumcte,cSucursal,cNumProd,dMontoAut
         FROM bdisolic:"informix".ss_solicitudes
         WHERE empresa = o_empresa
         AND num_solicitud = o_num_solicitud;

--	IF vStatusSol = "RT" THEN
--		RETURN;
--	END IF

	If vStatusSol not in ("EE", "OS") THEN
		RETURN;
	END IF
/*
	select max(fecha_entrada)
	Into dFechaEnt
	from ss_autorizacion
	where num_solicitud = o_num_solicitud
	and status_solicitud = vStatusSol;

	Update ss_autorizacion
	Set fecha_salida = vHoy
	Where num_solicitud = o_num_solicitud
	and fecha_entrada = dFechaEnt
	and status_solicitud = vStatusSol;
*/
	IF o_status = "A"  THEN
		LET vStatusSol = "AT";
		
		 IF cNumProd ='6001' THEN
			EXECUTE PROCEDURE bdisolic:"informix".sp_valida_comprobante(o_empresa ,cNumcte ,  o_num_solicitud)
			 INTO cCodRet,cMensajeRet,iValido;
			 
			IF cCodRet::INTEGER = 0 AND iValido = 1 THEN
				LET vStatusSol = "LC";
				LET vMensajeStatus= 'Revisión Línea de Crédito';
				INSERT INTO bdisolic:"informix".ss_solicitudes_cac 
				(empresa, num_solicitud, numcte, sucursal, num_producto, status, ejecutivo_atiende, ejecutivo_autoriza, comprobante_valido, observaciones, os, linea_determinada_sistema, fecha_insert,hora_insert, fecha_determinacion, revisado) 
				VALUES (o_empresa, o_num_solicitud, cNumcte,cSucursal, cNumProd, vStatusSol, "", "", "", "", "S", dMontoAut, CURRENT,CURRENT, DATE(1), 'N');			 
			END IF;		
	    END IF
	ELIF o_status = "R" THEN
		LET vStatusSol = "RT";
        LET vCausaSol  = "ROS";
	ELIF o_status = "D" THEN
		LET vStatusSol = "OA";
	END IF;

  call "informix".sp_actualiza_status_sol(o_empresa ,'sistema' ,o_num_solicitud ,vStatusSol ,
                                                       vCausaSol,vMensajeStatus) returning P_COD_RET; 


/*	UPDATE ss_solicitudes SET status_solicitud = vStatusSol
	 WHERE empresa = o_empresa
	   AND num_solicitud = o_num_solicitud;

	INSERT INTO ss_autorizacion
		(empresa, ejecutivo_auto, num_solicitud, status_solicitud,causa_solicitud,
		comentario, fecha_entrada, fecha_salida, user_insert, fecha_insert, revision_cac)
	VALUES
		(o_empresa, "sistema", o_num_solicitud, vStatusSol,vCausaSol,
		"Resolucion Orden de Supervision", vHoy, vHoy, user, today, 0);*/

END PROCEDURE;