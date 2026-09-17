CREATE PROCEDURE "informix".sp_inserta_cteemp_baja(p_empresa CHAR(3))
RETURNING CHAR(5) AS cod_ret,VARCHAR(80) AS mens_ret, VARCHAR(60) AS mens_ctrl;

--*****************************************************
-- DECLARACION DE VARIABLES
--*****************************************************
DEFINE bCodRet		CHAR(5);
DEFINE bMensaje		CHAR(80);
DEFINE bMensajeCtrl	CHAR(60);
DEFINE iContInacNoExis	INTEGER;
DEFINE iContAct			INTEGER;
DEFINE iContBaja		INTEGER;
DEFINE iContInexis		INTEGER;
DEFINE p_numcte_banco	CHAR(20);
DEFINE p_num_empleado	CHAR(10);
DEFINE p_fecha_hoy		DATE;
--*****************************************************
--- Inicializar variables
--*****************************************************
LET bCodRet  = "00000";
LET bMensaje = "";
LET bMensajeCtrl = "Validar";
LET iContAct = 0;
LET iContBaja = 0;
LET p_numcte_banco = '';
LET p_num_empleado = '';
LET p_fecha_hoy = '';


BEGIN
		
	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;
	
	SELECT fecha_hoy
	INTO p_fecha_hoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = p_empresa;
	
	DELETE FROM bdinteg:"informix".si_baja_rel_cte_emp;

	--SET DEBUG FILE TO "/aplicacion/resplogifx/Credito_GC/sp_inserta_cteemp_baja.out";
	--TRACE ON;
		
		FOREACH
				SELECT a.num_empleado,b.numcte_banco
				INTO p_num_empleado,p_numcte_banco
				FROM bdinteg:"informix".si_baja_rel_cte_emp_paso a 
				INNER JOIN bdinteg:"informix".si_rel_cte_empleado b ON a.num_empleado = b.num_empleado
				WHERE b.status_emp = 1
				
				select count (*)
				into iContBaja
				FROM bdinteg:"informix".si_baja_rel_cte_emp
				WHERE empresa = '001' and numcte_banco = p_numcte_banco and num_empleado = p_num_empleado; 
				
				IF iContBaja = 0 THEN 
					INSERT INTO bdinteg:"informix".si_baja_rel_cte_emp(empresa,numcte_banco,num_empleado,fecha_registro)
						VALUES (p_empresa,p_numcte_banco,p_num_empleado,p_fecha_hoy);
						
					LET iContAct = iContAct + 1;
				END IF; 	
				LET iContBaja = 0;
		END FOREACH;
		
		LET bCodRet = '00000'; 
		LET bMensaje = "Se realizo el proceso de insercion correctamente";	
		LET bMensajeCtrl = 'Insertados: '||cast(iContAct as char(6))||'';
		
		RETURN bCodRet,bMensaje,bMensajeCtrl;

END;
END PROCEDURE;