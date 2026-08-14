CREATE PROCEDURE "informix".sp_guardasolcobranza(pEmpleadoCob CHAR(8), pNombreEmpCob CHAR(78), pFechaSolMasivas DATE, pEjecutivo CHAR(8), pSucursal CHAR(4), pSolEntregadas INTEGER, pSolRechazadas INTEGER, pOper CHAR(1))
   returning CHAR(5);

--******************************************************************************************
-- Define variables
--******************************************************************************************
	DEFINE cod_ret      CHAR(5);
	DEFINE sql_err      INTEGER;
	DEFINE vIdEmp		INTEGER;
	DEFINE vPendientes	INTEGER;
	DEFINE vRechazadas	INTEGER;
	
--******************************************************************************************
-- Inicializa variables
--******************************************************************************************
   LET cod_ret		= '00000';
   LET sql_err		= 0;
   LET vIdEmp		= 0;
   LET vPendientes	= 0;
   LET vRechazadas	= 0;

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;
   
	--SET DEBUG FILE TO '/tmp/sp_guardasolcobranza.out';
	--TRACE ON ;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ ;
			
	IF(pOper = '0') THEN 
		--Se consulta si ya existe el empleado
		SELECT id_empcob 
		INTO vIdEmp
		FROM bdiprospectos: "informix".pr_monitorconcilia
		WHERE empleado_cob = pEmpleadoCob AND fecha_solmasivas = pFechaSolMasivas;
		IF (vIdEmp IS NOT NULL OR vIdEmp <> 0) THEN
			LET cod_ret = '00004';
		ELSE
			--SI EL TIPO DE OPERACION ES IGUAL A 0 ENTONCES ES UN NUEVO REGISTRO A LA TABLA PR_MONITORCONCILIA
			INSERT INTO bdiprospectos: "informix".pr_monitorconcilia (empleado_cob, nombre, fecha_solmasivas, ejecutivo,fecha_insert, sucursal,sol_entregadas)
			VALUES (pEmpleadoCob, pNombreEmpCob, pFechaSolMasivas, pEjecutivo, CURRENT, pSucursal, pSolEntregadas);
		END IF;
		
	ELSE
		--EN CASO DE QUE LA VARIABLE pOper NO SEA 0 SE ACTUALIZAN LAS SOLICITUDES RECHAZADAS
		SELECT (sol_entregadas - sol_capturadas - sol_rechazadas), sol_rechazadas
		INTO vPendientes, vRechazadas
		FROM bdiprospectos: "informix".pr_monitorconcilia
		WHERE empleado_cob = pEmpleadoCob AND fecha_solmasivas = pFechaSolMasivas;
		
		IF (vPendientes = 0) THEN
			LET cod_ret = '00003';
		ELIF (pSolRechazadas > vPendientes) THEN
			LET cod_ret = '00002';
		ELSE
			UPDATE bdiprospectos: "informix".pr_monitorconcilia 
			SET sol_rechazadas = (vRechazadas + pSolRechazadas) 
			WHERE empleado_cob = pEmpleadoCob AND fecha_solmasivas = pFechaSolMasivas;
		END IF;
	END IF;
	
	RETURN cod_ret;
END
END PROCEDURE 
