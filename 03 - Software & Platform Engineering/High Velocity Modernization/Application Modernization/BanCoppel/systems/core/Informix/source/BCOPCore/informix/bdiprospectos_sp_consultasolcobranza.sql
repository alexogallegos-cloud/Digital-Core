CREATE PROCEDURE "informix".sp_consultasolcobranza(pSucursal char(4), pEmpCobranza char(8), pSolPend char(1), pReg integer)
   returning char(5), date, char(8), char(78), char(4), integer, integer, integer, integer;

--******************************************************************************************
-- Define variables
--******************************************************************************************
	DEFINE cod_ret      char(5);
	DEFINE sql_err      integer;
	DEFINE vFecha   	date;
	DEFINE vEmpleado    char(8);
	DEFINE vNombre		char(78);
	DEFINE vSucursal    char(4) ;   
    DEFINE vEntregadas	integer;
	DEFINE vCapturadas	integer;
	DEFINE vRechazadas	integer;
	DEFINE vPendientes	integer;
	
	DEFINE vFechaVieja date;
--******************************************************************************************
-- Inicializa variables
--******************************************************************************************
   LET cod_ret		= '00000';
   LET vFecha		= '01-01-1900';
   LET vEmpleado	= '';
   LET vNombre		= '';
   LET vSucursal	= '';
   LET vEntregadas	= 0;
   LET vCapturadas	= 0;
   LET vRechazadas	= 0;
   LET vPendientes	= 0;

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, vFecha, vEmpleado, vNombre, vSucursal, vEntregadas, vCapturadas, vRechazadas, vPendientes;
      END IF ;
   END EXCEPTION ;
   
	--SET DEBUG FILE TO '/tmp/sp_consultasolcobranza.out';
	--TRACE ON ;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ ;
			
	IF(pSolPend = '1') THEN 
		--SI SE BUSCAN LAS SOLICITUDES PENDIENTES SE TOMAN SOLO LOS REGISTROS QUE TENGAN SOLICITUDES PENDIENTES DE UN AÑO ANTERIOR A LA FECHA ACTUAL.
		LET vFechaVieja = current - 1 UNITS YEAR - 1 UNITS DAY;
		
		IF (pSucursal <> '' AND pSucursal IS NOT NULL) THEN	--SI SUCURSAL ES DIFERENTE DE VACIO ENTONCES ES UNA BUSQUEDA POR SUCURSAL.
			FOREACH
				SELECT SKIP pReg FIRST 11 fecha_solmasivas, empleado_cob, nombre, sucursal, sol_entregadas, sol_capturadas, sol_rechazadas 
				INTO vFecha, vEmpleado, vNombre, vSucursal, vEntregadas, vCapturadas, vRechazadas
				FROM bdiprospectos: "informix".pr_monitorconcilia
				WHERE sucursal = pSucursal 
				AND fecha_solmasivas > vFechaVieja
				AND (sol_entregadas - sol_capturadas - sol_rechazadas) > 0
				--SE CALCULAN LAS SOLICITUDES PENDIENTES
				LET vPendientes = vEntregadas - vCapturadas - vRechazadas;

				RETURN cod_ret, vFecha, vEmpleado, vNombre, vSucursal, vEntregadas, vCapturadas, vRechazadas, vPendientes WITH RESUME;
				
			END FOREACH;
			
		ELIF(pEmpCobranza <> '' AND pEmpCobranza IS NOT NULL) THEN	--SI EMPLEADO ES DIFERENTE DE VACIO ENTONCES ES UNA BUSQUEDA POR EMPLEADO.
			FOREACH
				SELECT SKIP pReg FIRST 11 fecha_solmasivas, empleado_cob, nombre, sucursal, sol_entregadas, sol_capturadas, sol_rechazadas 
				INTO vFecha, vEmpleado, vNombre, vSucursal, vEntregadas, vCapturadas, vRechazadas
				FROM bdiprospectos: "informix".pr_monitorconcilia
				WHERE empleado_cob = pEmpCobranza 
				AND fecha_solmasivas > vFechaVieja
				AND (sol_entregadas - sol_capturadas - sol_rechazadas) > 0
				--SE CALCULAN LAS SOLICITUDES PENDIENTES
				LET vPendientes = vEntregadas - vCapturadas - vRechazadas;
				
				RETURN cod_ret, vFecha, vEmpleado, vNombre, vSucursal, vEntregadas, vCapturadas, vRechazadas, vPendientes WITH RESUME;
				
			END FOREACH;
		END IF;
	ELSE
		--SI LA VARIABLE pSolPend ES 0 SE TOMAN TODAS LAS SOLICITUDES DE UN MES ANTERIOR A LA FECHA ACTUAL. YA SEA POR SUCURSAL O POR EMPLEADO.
		LET vFechaVieja = current - 30 UNITS DAY;
	
		IF (pSucursal <> '' AND pSucursal IS NOT NULL) THEN
			FOREACH
				SELECT SKIP pReg FIRST 11 fecha_solmasivas, empleado_cob, nombre, sucursal, sol_entregadas, sol_capturadas, sol_rechazadas 
				INTO vFecha, vEmpleado, vNombre, vSucursal, vEntregadas, vCapturadas, vRechazadas
				FROM bdiprospectos: "informix".pr_monitorconcilia
				WHERE sucursal = pSucursal AND fecha_solmasivas > vFechaVieja
				
				LET vPendientes = vEntregadas - vCapturadas - vRechazadas;
			
				RETURN cod_ret, vFecha, vEmpleado, vNombre, vSucursal, vEntregadas, vCapturadas, vRechazadas, vPendientes WITH RESUME;
				
			END FOREACH;
			
		ELIF(pEmpCobranza <> '' AND pEmpCobranza IS NOT NULL) THEN
			FOREACH
				SELECT SKIP pReg FIRST 11 fecha_solmasivas, empleado_cob, nombre, sucursal, sol_entregadas, sol_capturadas, sol_rechazadas 
				INTO vFecha, vEmpleado, vNombre, vSucursal, vEntregadas, vCapturadas, vRechazadas
				FROM bdiprospectos: "informix".pr_monitorconcilia
				WHERE empleado_cob = pEmpCobranza AND fecha_solmasivas > vFechaVieja
				
				LET vPendientes = vEntregadas - vCapturadas - vRechazadas;
				
				RETURN cod_ret, vFecha, vEmpleado, vNombre, vSucursal, vEntregadas, vCapturadas, vRechazadas, vPendientes WITH RESUME;
				
			END FOREACH;
		END IF;
	END IF;
END
END PROCEDURE 
