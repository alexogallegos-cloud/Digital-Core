CREATE PROCEDURE "informix".actualiza_solos(o_empresa       CHAR(3),
                             o_num_solicitud CHAR(20),
                             o_fecha         DATE,
                             o_status        CHAR(1))

-- Control de Cambios
-----------------------------------------------------------------------------------
--ModificaciÃ?Â³n #1
--Juan AndrÃ?Â©s Coronel M.
--14-08-2007
--Que al recibir una respuesta 'D' en la orden de supervisiÃ?Â³n la solicitud cambie 
--al estatus 'OA'.
--Que solo permita cambiar de estatus una solicitud que estÃ?Â© en estatus 'EE' Ã?Âº 
--'OS'(nuevo).
--Que cada vez que cambie de estatus, actualizar en ss_autorizaciÃ?Â³n el campo 
--fecha_salida al estatus que acaba de abandonar la solicitud.
--21-08-2007, Juan A. Coronel M, usar la fecha del servidor como fecha actual, 
--en vez del calendario, para actualizar campos de fecha
-----------------------------------------------------------------------------------
--ModificÃ?Â³: Viridiana Osobampo
--DescripciÃ?Â³n; Se modifica para asignar una clave de rechazo a la solicitud cuando 
--Ã?Â©sta sea rechazada por orden de supervisiÃ?Â³n.
--Fecha: 26-04-2010
--PeticiÃ?Â³n: RQM 09 171 - Arbol de anÃ?Â¡lisis de solicitudes de crÃ?Â©dito.
-----------------------------------------------------------------------------------
-- Autor:  JesÃ?Âºs Manuel Aguilar Heredia
-- ModificaciÃ?Â³n:  Se modifica para enviar a revision de lineas de credito a solicitudes que cuenten con un ingreso mensual mayor a 7,000 pesos y que cuente con un comprobante de ingresos digitalizado, antes de que se les autorice
-- Fecha de ModificaciÃ?Â³n: 24-11-2011
-- PeticiÃ?Â³n: RQM 09 180 RevisiÃ?Â³n de lÃ?Â­nea de crÃ?Â©dito por CAC
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
DEFINE cNumSol CHAR(20);
DEFINE cStatusMovil CHAR(1);
DEFINE cCanal	    CHAR(1); --rocket
DEFINE v_valor          DECIMAL(14,2);
DEFINE cTipoMovto       CHAR(1);
DEFINE v_hereda_status  CHAR(2);
DEFINE cEstatus	        CHAR(1);
DEFINE cProducto        CHAR(20);
define cStatusPrev        CHAR(2); 
define iMotivoOs         integer;
define iBanderaFaltaOSTEL integer;
define iFlagForzarEnvioMC smallint;

define val_mc  integer; --IPCB, 10092021 - validacion val_mc
define sRevisionMC       SMALLINT;
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
LET cNumSol="";
LET cStatusMovil="";
LET cCanal              = '';	
LET v_valor             = 0;
LET cTipoMovto          ='';
LET v_hereda_status     ='';
LET cEstatus	        ='';
LET cProducto           ='';
LET cStatusPrev          =''; 
let iBanderaFaltaOSTEL =0;
let iFlagForzarEnvioMC =0;  
let val_mc =0;
LET sRevisionMC = 0;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SELECT fecha_hoy INTO vHoy FROM bdicred:sd_fechas WHERE empresa = o_empresa;
SELECT current year to day INTO vHoy FROM bdisolic:"informix".dual;
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

--SET DEBUG FILE TO "/ifxsif01/Israel/actualiza_solos.out";
-- TRACE ON;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

         SELECT sol.status_solicitud,sol.numcte,sol.sucursal,sol.num_producto,sol.monto_solicitado,mov.num_solicitud,status
			INTO vStatusSol,cNumcte,cSucursal,cNumProd,dMontoAut,cNumSol,cStatusMovil
         FROM bdisolic:"informix".ss_solicitudes sol 
		 LEFT JOIN bdisolic:"informix".ss_solicitudes_movil mov on (mov.empresa = sol.empresa and mov.num_solicitud = sol.num_solicitud AND status <> '3')
		 WHERE sol.empresa = o_empresa
         AND sol.num_solicitud = o_num_solicitud;

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

	SELECT canal_sol,estatus
		INTO   cCanal,cEstatus
	FROM bdisolic:ss_prospecteo_solicitudes 
		WHERE num_solicitud = o_num_solicitud;
	
	IF cCanal IS NULL THEN
		LET cCanal = '';
	END IF;
	IF cEstatus IS NULL THEN
		LET cEstatus = '';
	END IF;

	IF o_status = "A"  THEN
		LET vStatusSol = "AT";
       SELECT count(*) INTO sRevisionMC FROM bdisolic:"informix".ss_solicitudes_cac WHERE empresa = o_empresa AND num_solicitud = o_num_solicitud;		IF sRevisionMC = 0 THEN
			IF cNumProd ='6001' THEN
				EXECUTE PROCEDURE bdisolic:"informix".sp_valida_comprobante(o_empresa ,cNumcte ,  o_num_solicitud)
				 INTO cCodRet,cMensajeRet,iValido;
				 
				IF cCodRet::INTEGER = 0 AND iValido = 1 THEN
					LET vStatusSol = "LC";
					LET vMensajeStatus= 'RevisiÃ?Â³n LÃ?Â­nea de CrÃ?Â©dito';
					INSERT INTO bdisolic:"informix".ss_solicitudes_cac 
					(empresa, num_solicitud, numcte, sucursal, num_producto, status, ejecutivo_atiende, ejecutivo_autoriza, comprobante_valido, observaciones, os, linea_determinada_sistema, fecha_insert,hora_insert, fecha_determinacion, revisado) 
					VALUES (o_empresa, o_num_solicitud, cNumcte,cSucursal, cNumProd, vStatusSol, "", "", "", "", "S", dMontoAut, CURRENT,CURRENT, DATE(1), 'N');			 
				END IF;	
			
			END IF;
		END IF; 
		
		IF NVL(cNumSol,'') <> '' AND NVL(cStatusMovil,'') ='1' AND iValido = 0 THEN											
					LET vStatusSol = 'PA';
					LET vCausaSol = '';
		
					SELECT descripcion INTO vMensajeStatus FROM "informix".ss_status_sol WHERE status_solicitud = vStatusSol;
							
					UPDATE "informix".ss_solicitudes_movil		
						SET status_solicitud = vStatusSol		
					WHERE 	empresa  = o_empresa 
					AND  num_solicitud = o_num_solicitud;
		END IF;
		
		--rocket
		SELECT estatus,numcte,num_producto,canal_sol,sts_prev_pa, vvalor_junk, imotivos_junk, iband_altaostel, ctipo_movto_junk, flagforenviomcjunk,  v_hereda_stat_junk  	
		  into cEstatus,cNumcte,cProducto,cCanal, cStatusPrev, v_valor, iMotivoOs, iBanderaFaltaOSTEL, cTipoMovto, iFlagForzarEnvioMC, v_hereda_status
          FROM ss_prospecteo_solicitudes 
         WHERE empresa = o_empresa
           and num_solicitud = o_num_solicitud;	

    /*SELECT estatus,num_producto,canal_sol
		INTO cEstatus,cProducto, cCanal
		FROM bdisolic:ss_prospecteo_solicitudes
		WHERE num_solicitud = o_num_solicitud and canal_sol = '4'; --AND estatus = 'A';	
	*/
		let cCanal=nvl(cCanal,'');
		let cEstatus=nvl(cEstatus,'');
		let cProducto=nvl(cProducto,'');
		
		select count(*) INTO val_mc  from ss_solicitudes_mc where num_solicitud =o_num_solicitud;
		
		IF (cCanal IN ('4','0') and val_mc = 0)  THEN  --IPCB, 10092021 - validacion val_mc para que no entre por 2da vez a MC
			IF cProducto = '6001' THEN
				IF cEstatus = 'A' AND cCanal = '4' THEN
					LET vStatusSol = 'IN';
                    SELECT descripcion INTO vMensajeStatus FROM "informix".ss_status_sol WHERE status_solicitud = vStatusSol; 
					--LET vMensajeStatus = 'En espera de Captura de InformaciÃ?Â³n del Cliente';
					
				ELSE
					IF cEstatus = 'F' AND cCanal = '4' THEN
						LET vStatusSol='MC';
						
						LET v_hereda_status = 'AT';
                        
                        SELECT descripcion INTO vMensajeStatus FROM "informix".ss_status_sol WHERE status_solicitud = vStatusSol; 

						
						INSERT INTO "informix".ss_solicitudes_mc (empresa,num_solicitud,numcte,sucursal,num_producto,monto_solicitado,status_ini,status_fin,ejecutivo_atiende,ejecutivo_autoriza,observaciones,fecha_insert,hora_insert,fecha_determinacion,revisado,motivo_os,ostel,tipo_alta,status_hereda,prioridad)																																										  
                        VALUES (o_empresa,o_num_solicitud,cNumcte,'8503',cProducto, v_valor, vStatusSol,'','','','Cliente Nuevo',CURRENT,CURRENT,CURRENT,'N',iMotivoOs,iBanderaFaltaOSTEL,cTipoMovto,v_hereda_status,iFlagForzarEnvioMC);

 

					END IF
				
				END IF;
			ELSE 
				IF cProducto = '6500' THEN
					IF cEstatus = 'F' THEN
						LET vStatusSol = 'AT';
						
						SELECT descripcion INTO vMensajeStatus FROM "informix".ss_status_sol WHERE status_solicitud = vStatusSol; 
					else
						LET vStatusSol = 'PA';
						
						SELECT descripcion INTO vMensajeStatus FROM "informix".ss_status_sol WHERE status_solicitud = vStatusSol; 
						
						IF cCanal = '0' THEN
							UPDATE bdisolic:"informix".ss_prospecteo_solicitudes 
								set status_solicitud = vStatusSol, sts_prev_pa = 'AT'
							where num_solicitud = o_num_solicitud; 
						END IF;
						
						
					end if;
					
				END IF;
			END IF;
		End if;
		
		
		
	ELIF o_status = "R" THEN
		LET vStatusSol = "RT";
        LET vCausaSol  = "ROS";
			IF NVL(cNumSol,'') <> '' THEN		
				 UPDATE "informix".ss_solicitudes_movil		
						SET status = '3',--finalizado
						descripcion_status = vCausaSol ,
						status_solicitud = vStatusSol	
					WHERE 	empresa  = o_empresa 
					AND  num_solicitud = o_num_solicitud;
					
			ELIF cCanal IN ('0','4') THEN
			
				UPDATE bdisolic:"informix".ss_prospecteo_solicitudes 
					set status_solicitud = vStatusSol,estatus = 'F'
				where num_solicitud = o_num_solicitud; 
							
			END IF;
		
		
	ELIF o_status = "D" THEN
		LET vStatusSol = "OA";
		
		IF cCanal = '0' AND cEstatus = 'A' THEN
		
			UPDATE bdisolic:"informix".ss_prospecteo_solicitudes 
				set status_solicitud = 'PA', sts_prev_pa = vStatusSol
			where num_solicitud = o_num_solicitud; 
			
			LET vStatusSol = "PA";

		END IF;
		
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