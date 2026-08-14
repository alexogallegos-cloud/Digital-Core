CREATE PROCEDURE "informix".sp_obt_cant_reg_referencias(pNumCliente CHAR(20), pCveCuenta CHAR(2),pCveBanco CHAR(3))
        RETURNING CHAR(5), INTEGER;

    -- Realizo   : Javier Calderon
    -- Actividad : Obetener cantidad de registros de un cliente en la tabla de pp_ctasterceros, y que sean cuentas de SKY, DISH o MasTV
    -- Solicitó  : Mauricio Leon
    -- Fecha     : 27-Agosto-2010

	-- Modificó  : Walber Castro
	-- Fecha     : 30/09/2010
	-- Motivo    : Se elimina la condicion del where donde valida los 30 min

    DEFINE vcodret		CHAR(5);
    DEFINE vCantidad	INTEGER;
    DEFINE sql_err		INTEGER;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vCantidad;
       END IF;
END EXCEPTION;

LET vcodret = '00000';
LET vCantidad = 0; 
LET pNumCliente = TRIM(pNumCliente);
LET pCveCuenta = TRIM(pCveCuenta);
LET pCveBanco = TRIM(pCveBanco); 
 
SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

BEGIN  
	SELECT COUNT(*) 
	INTO vCantidad
	FROM (SELECT cuenta FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte= pNumCliente  AND cve_cuenta= pCveCuenta AND cve_banco= pCveBanco AND cve_estado='01' UNION ALL
	SELECT cuenta FROM bdiprog:"informix".pp_ctasterceros_bex WHERE num_cte= pNumCliente AND cve_cuenta= pCveCuenta AND cve_banco= pCveBanco AND cve_estado='01');	
	
    RETURN vcodret, vCantidad;
END;
END PROCEDURE 
/*DOCUMENT
'Autor: 97915041 Rocio Vidales',
'Fecha: 28/12/2018',
'Modificacion: Se realiza el Conteo de las Cuentas Frecuentes dadas de Alta por BPI y BancaExpress',
'Sustento: RRQI 03 698 Cuentas Frecuentes de Bancoppel Express a BPI',
'Solicita: Arturo Alejandro Vazquez',
'------------------------------------------------------------------------------------------------------------'*/;

CREATE PROCEDURE "informix".sp_consulta_ope_favoritas_bex(pnumCte CHAR(20), pidOperacion INTEGER, pCta_destino CHAR(20))
    
RETURNING  	CHAR(5) AS codret,
			CHAR(4) AS id_operacion,
			CHAR(20) AS num_cte,
			CHAR(20) AS cta_destino,
			CHAR(8) AS banco,
			CHAR(50) AS beneficiario,
			CHAR(40) AS concepto,
			CHAR(50) AS referencia,
			MONEY(16,2) AS importe,    
			CHAR(1) AS estatus,
			CHAR(2) AS total;
	
    DEFINE sql_err 			INTEGER;
    DEFINE cCod_ret 		CHAR(5);
	DEFINE vId_operacion 	INTEGER;
	DEFINE vNum_cte			CHAR(20);
	DEFINE vCta_destino 	CHAR (20);
	DEFINE vBenefi 			CHAR (50);
	DEFINE vConcepto 		CHAR(40);
	DEFINE vReferencia 		CHAR(50);
	DEFINE vEstatus 		CHAR(1);
	DEFINE vBanco	 		CHAR(8);
	DEFINE vImporte 		MONEY(16,2);	
	DEFINE vTotal			CHAR(2);
	
	LET cCod_ret  			= '00000';
	LET vId_operacion		= 0;
	LET vNum_cte			= '';
	LET vCta_destino 		= '';
	LET vBenefi 			= '';
	LET vConcepto			= '';
	LET vReferencia 		= '';
	LET vEstatus 			= '';
	LET vImporte 	    	= 0;
	LET vBanco				= '';
	LET vTotal				= '0';
	
	
BEGIN

	ON EXCEPTION SET sql_err
	  IF sql_err <> 0 THEN
			let cCod_ret = sql_err;
			RETURN cCod_ret, vId_operacion, vNum_cte, vCta_destino, vBanco, vBenefi, vConcepto, vReferencia, vImporte,vEstatus,vTotal;
	  END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	LET pnumCte = NVL(pnumCte,'');
	LET pidOperacion = NVL(pidOperacion,0);
	
	SELECT COUNT(num_cte)
			INTO vTotal
			FROM bdiprog:"informix".pp_registro_favoritos_bex
			WHERE num_cte = pnumCte 
			AND estatus = '1';
	
	IF pnumCte <> '' AND pCta_destino <> '' THEN

		SELECT id_operacion, num_cte, cta_destino, banco, beneficiario, concepto, referencia, importe, estatus
			INTO vId_operacion, vNum_cte, vCta_destino, vBanco, vBenefi, vConcepto, vReferencia, vImporte, vEstatus
			FROM bdiprog:"informix".pp_registro_favoritos_bex
			WHERE num_cte = pnumCte 
			AND estatus = '1' 
			AND id_operacion = pidOperacion
			AND cta_destino = pCta_destino;
		
			LET vCta_destino = NVL(vCta_destino,'');
		
			IF vCta_destino = '' THEN
				LET cCod_ret = '00002';			END IF;
			
		RETURN cCod_ret, vId_operacion, vNum_cte, vCta_destino, vBanco, vBenefi, vConcepto, vReferencia, vImporte,vEstatus,vTotal;
	
	ELSE 
		IF pnumCte <> '' AND pidOperacion = '3' THEN  
		
			FOREACH
				SELECT id_operacion, num_cte, cta_destino,banco, beneficiario, concepto, referencia, importe, estatus
				INTO vId_operacion, vNum_cte, vCta_destino, vBanco,vBenefi, vConcepto, vReferencia, vImporte, vEstatus
				FROM bdiprog:"informix".pp_registro_favoritos_bex
				WHERE num_cte = pnumCte 
				AND estatus = '1'
				
				LET vCta_destino = NVL(vCta_destino,'');
		
				IF vCta_destino = '' THEN
					LET cCod_ret = '00002';				END IF;
			
				RETURN cCod_ret, vId_operacion, vNum_cte, vCta_destino, vBanco, vBenefi, vConcepto, vReferencia, vImporte,vEstatus,vTotal WITH RESUME;
		
			END FOREACH;
			
		ELSE 	
			
			FOREACH
					SELECT id_operacion, num_cte, cta_destino,banco, beneficiario, concepto, referencia, importe, estatus
					INTO vId_operacion, vNum_cte, vCta_destino, vBanco,vBenefi, vConcepto, vReferencia, vImporte, vEstatus
					FROM bdiprog:"informix".pp_registro_favoritos_bex
					WHERE num_cte = pnumCte 
					AND id_operacion = pidOperacion
					AND estatus = '1'
					
					LET vCta_destino = NVL(vCta_destino,'');
			
					IF vCta_destino = '' THEN
						LET cCod_ret = '00002';					END IF;
				
					RETURN cCod_ret, vId_operacion, vNum_cte, vCta_destino, vBanco, vBenefi, vConcepto, vReferencia, vImporte,vEstatus,vTotal WITH RESUME;
				
			END FOREACH;
		END IF;
	END IF;
   
END
END PROCEDURE
;