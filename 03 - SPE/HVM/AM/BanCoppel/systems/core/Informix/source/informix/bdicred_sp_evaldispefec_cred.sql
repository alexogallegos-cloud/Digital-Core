CREATE PROCEDURE "informix".sp_evaldispefec_cred (pNumCred  CHAR(20), pMontoSol MONEY(16,2)) 	
RETURNING CHAR(5), CHAR(3), MONEY(16,2), VARCHAR(100,1);
-- Codigo de Retorno, Porcentaje Disposicion Efectivo, Monto disponible en linea de credito, Mensaje de Disposicion de Credito (Etiqueta)

-- Dependiendo del parametro de entrada enviado, se identifica el canal por el que es consumido el SP
-- pMontoSol = -1 -> OFI , pMontoSol = -2 -> SOC y pMontoSol > 0 (cero) -> Caja y Cajeros
-- Indicadores de Disposicion en efectivo
-- 0 -> acceso a efectivo sin restriccion , 1 -> sin acceso a efectivo y 2 -> acceso a efectivo con restriccion

DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr     		INTEGER;
DEFINE cErrorInfo   		VARCHAR(255,1);
DEFINE cCodRet      		CHAR(5);
DEFINE cMen_ret 			VARCHAR(100,1);

DEFINE vNumCred				CHAR(20);
DEFINE v_montoporcmaxdisp   DECIMAL(18,2);
DEFINE v_porcmaxdisp        DECIMAL(18,2);
DEFINE v_gpo_sol            CHAR(1);
DEFINE v_evaluacc_sol       CHAR(1);
DEFINE vNumProducto         CHAR(4);
DEFINE vLineaCred       	DECIMAL(18,2);
DEFINE vLinCredAct          MONEY(16,2); 
DEFINE vDispEfec            CHAR(1);
DEFINE vIDispEfec           CHAR(3);
DEFINE vSucursal			CHAR(4);
DEFINE vMtoComDisp          DECIMAL(14,2);
DEFINE viva                 DECIMAL(14,2);
DEFINE montosoltot          DECIMAL(14,2);
DEFINE vEmpresa 			CHAR(4);
DEFINE v_montoact           DECIMAL(18,2); 
DEFINE vFechaAper           DATE;
DEFINE vSdoCapInsoluto      DECIMAL(18,2); 
DEFINE vAcumDispAnterior   	DECIMAL(18,2);
DEFINE v_montodisponible    DECIMAL(18,2);
DEFINE v_monto_acalcular_comision DECIMAL(18,2); 

-------------------------------------
LET iSqlErr         		= 0;
LET iIsamErr        		= 0;
LET cErrorInfo      		= "";
LET cCodRet         		= "";
LET cMen_ret     			= "";

LET vNumCred    			= "";
LET vLineaCred              = 0;
LET vLinCredAct             = 0;
LET vDispEfec               = '';
LET vIDispEfec              = '';

LET v_montoporcmaxdisp      = 0;
LET v_porcmaxdisp           = 0;
LET v_gpo_sol               = '';
LET v_evaluacc_sol          = '';
LET vNumProducto            = '';
LET vSucursal               = '';
LET viva                    = 0;
LET vMtoComDisp             = 0;
LET montosoltot               = 0;
LET vEmpresa                = '001';
LET v_montoact              = 0;
LET vFechaAper              = DATE (1);
LET vSdoCapInsoluto         = 0;
LET vAcumDispAnterior       = 0;
LET v_montodisponible       = 0;
LET v_monto_acalcular_comision = 0;


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo

    IF iSqlErr != 0 THEN
		LET cCodRet = iSqlErr;
		LET cMen_ret = cErrorInfo;
		LET vIDispEfec = '';
		LET vLinCredAct = 0;		
		RETURN cCodRet, vIDispEfec, vLinCredAct, cMen_ret;
	END IF;

END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/Rebeca/sp_evaldispefec_cred.out';
    --TRACE ON;
    
	IF pNumCred IS NULL OR pNumCred = '' THEN 
		LET cCodRet    = '00003';
		LET vIDispEfec = '';
		LET vLinCredAct = 0;
		LET cMen_ret = 'Numero de credito invalido. Transaccion Invalida.';
		RETURN cCodRet, vIDispEfec, vLinCredAct, Trim(cMen_ret);        
    END IF;		
	
	IF  pMontoSol = '' OR pMontoSol IS NULL OR pMontoSol = 0 THEN 		
			LET cCodRet    = '00004';
			LET vIDispEfec = '';
			LET vLinCredAct = 0;
			LET cMen_ret = 'Monto de disposicion invalido.';
			RETURN cCodRet, vIDispEfec, vLinCredAct, Trim(cMen_ret);
	END IF;
		
	SELECT {+AVOID_FULL(bdicred:"informix".sd_definicion)} d.ind_disp_efec, b.num_producto, b.fecha_apertura INTO vDispEfec, vNumProducto, vFechaAper
	FROM bdicred:"informix".sd_definicion d
	JOIN bdicred:sd_maecred b ON d.num_producto =  b.num_producto 
	WHERE b.num_credito = pNumCred;
	
	IF vDispEfec IS NULL OR vDispEfec = '' THEN 			
		LET cCodRet    = '00006';
		LET vIDispEfec = '';
		LET vLinCredAct = 0;
		LET cMen_ret = 'Producto no cuenta con indicador de disposicion en efectivo.';
		RETURN cCodRet, vIDispEfec, vLinCredAct, Trim(cMen_ret);
	END IF;	
	
	IF vNumProducto = '6001' AND YEAR(vFechaAper) > 2016 THEN --Validaciones para producto 6001	
		SELECT  {+AVOID_FULL(bdicred:"informix".sd_maecred)} d.num_credito, d.diferimiento_int,b.grupo, b.evalua_cc, 
				c.porc_max_disposicion, d.sucursal,  e.monto_otorgado, e.sdo_cap_insoluto, e.sdo_acum_vencido
		INTO	vNumCred, vIDispEfec, v_gpo_sol, v_evaluacc_sol, 
				v_porcmaxdisp, 			vSucursal,  vLineaCred, 		vSdoCapInsoluto, vAcumDispAnterior
		FROM bdicred:sd_maecred d
		JOIN bdicred:sd_maesdos e ON d.num_credito = e.num_credito
		JOIN bdisolic:ss_resum_scor_fin b ON d.num_credito = b.num_solicitud
		JOIN bdicred:sd_tasas_disposiciones_diferenciadas c ON b.grupo = c.grupo AND b.evalua_cc = c.evalua_cc AND d.num_producto = c.num_producto	
		WHERE d.num_credito = pNumCred;			
    ELIF vNumProducto = '6001' AND YEAR(vFechaAper) < 2016 THEN	
		SELECT {+AVOID_FULL(bdicred:"informix".sd_maecred)} e.monto_otorgado INTO  vLineaCred 
		FROM bdicred:sd_maecred d 	
		JOIN bdicred:sd_maesdos e ON d.num_credito = e.num_credito
		WHERE d.num_credito = pNumCred;					

		LET cCodRet    = '00000';
		LET vIDispEfec = '100';
		LET vLinCredAct = vLineaCred;
		LET cMen_ret = 'Sin restricciones (revolvente).';
		RETURN cCodRet, vIDispEfec, vLinCredAct, Trim(cMen_ret);   		
	ELIF vNumProducto IN ('7000','8100','5400') THEN			
		LET cCodRet    = '00000';
		LET vIDispEfec = '0';
		LET vLinCredAct = 0;
		LET cMen_ret = '';
		RETURN cCodRet, vIDispEfec, vLinCredAct, Trim(cMen_ret);	
	ELIF vNumProducto not in ('6001','6600','7000','7800','8100','8500') THEN --Validaciones para productos diferentes de 6001		
		LET cCodRet    = '00000';
		LET vIDispEfec = '0';
		LET vLinCredAct = 0;
		LET cMen_ret = '';
		RETURN cCodRet, vIDispEfec, vLinCredAct, Trim(cMen_ret);		
	ELIF vNumProducto IS NULL OR vNumProducto = '' THEN
		LET cCodRet    = '00003';
		LET vIDispEfec = '';
		LET vLinCredAct = 0;
		LET cMen_ret = 'Numero de credito invalido.';
		RETURN cCodRet, vIDispEfec, vLinCredAct, Trim(cMen_ret);
	END IF;	

	IF vDispEfec = '1' THEN -- El producto cuenta con acceso a criterios de disposicion de efectivo	
		IF pMontoSol = -1 THEN -- Casos de Mensajes de OFI - Proceso Asignacion de TDC
			IF vIDispEfec = '1' THEN
			   LET cCodRet = '00303'; -- SIN Acceso a efectivo
			   LET vIDispEfec = v_porcmaxdisp::CHAR(3);
			   LET vLinCredAct = 0;
			   LET cMen_ret = '';
			ELIF vIDispEfec IN ('0','2')  THEN
 			   LET cCodRet = '00000'; -- Con acceso a efectivo restringido
			   LET vIDispEfec = v_porcmaxdisp::CHAR(3);
			   LET vLinCredAct = 0;
			   LET cMen_ret = '';	 		   
			END IF;
		ELIF pMontoSol = -2 THEN  -- Casos de Mensajes SOC - Mostrar etiquetas
			LET v_montoporcmaxdisp = vLineaCred * (v_porcmaxdisp / 100);
		
			IF vIDispEfec = '1' THEN
			   LET cCodRet = '00303'; -- Sin Acceso a efectivo
			   LET vIDispEfec = '0';
			   LET vLinCredAct = 0.00;
			   LET cMen_ret = 'Sin acceso a Efectivo.';
			ELIF vIDispEfec IN ('0') THEN
			   LET cCodRet = '00000'; -- Acceso a efectivo SIN restriccion
			   LET vIDispEfec = '100';
			   LET vLinCredAct = v_montoporcmaxdisp;
			   LET cMen_ret = 'Sin restricciones (revolvente).';		
			ELIF vIDispEfec IN ('2') THEN
			   LET cCodRet = '00302'; -- Acceso a efectivo CON restriccion
			   LET vIDispEfec = '100';
			   LET vLinCredAct = v_montoporcmaxdisp;
			   LET cMen_ret = 'Con restriccion.';	
			END IF;
		ELIF pMontoSol > 0 THEN -- Disposicion en efectivo en Caja y Cajeros
			IF vIDispEfec = '1' THEN
 				IF (vSdoCapInsoluto < 0 AND (vSdoCapInsoluto * -1 >= pMontoSol)) THEN --AND (vSdoCapInsoluto + v_montoact <= v_montoporcmaxdisp) THEN --En caso de contar con saldo a favor
					LET cCodRet = '00000'; -- Permite disposicion
					LET vIDispEfec = '';
					LET vLinCredAct = 0;
					LET cMen_ret = '';							
				ELSE
				   LET cCodRet = '00303'; -- Sin Acceso a efectivo
				   LET vIDispEfec = '';
				   LET vLinCredAct = 0;
				   LET cMen_ret = '';
				END IF;
			ELIF vIDispEfec = '2' THEN	--Disposicion de efectivo con restricciÃÂ³n
				IF vSdoCapInsoluto < 0 THEN				    
					LET v_monto_acalcular_comision = pMontoSol + vSdoCapInsoluto;
				ELSE
					LET v_monto_acalcular_comision = pMontoSol;
				END IF

				IF (v_monto_acalcular_comision > 0) THEN
					EXECUTE PROCEDURE bdicred:"informix".comdistdc (vEmpresa,vSucursal,v_monto_acalcular_comision,vNumProducto) 
						INTO cCodRet, vMtoComDisp, viva;				
				ELSE					
					LET vMtoComDisp = 0;
					LET viva = 0;
				END IF;				

				LET montosoltot = vMtoComDisp + viva + v_monto_acalcular_comision; --Se calcula la comision e IVA del monto solicitado por el cliente en la disposicion	
				LET v_montoporcmaxdisp = vLineaCred * (v_porcmaxdisp / 100);  --Monto con porcentaje autorizado de disposicion de efectivo									
				LET v_montoact = montosoltot + vAcumDispAnterior; -- Monto que se va a convertir en deuda (monto total solicitado + acumulado de disposiciones anteriores)

				IF vAcumDispAnterior >= v_montoporcmaxdisp AND vMtoComDisp > 0 THEN
					LET cCodRet = '00301'; -- Acumulo el 100% de disposicionesde efectivo del monto autorizado
					LET vIDispEfec = '';
					LET vLinCredAct = 0;
					LET cMen_ret = '';		   
				ELIF v_montoact > v_montoporcmaxdisp THEN --En caso de contar con saldo a favor
					LET cCodRet = '00302'; -- Monto ingresado es mayor al disponible
					LET vIDispEfec = '';
					LET vLinCredAct = 0;
					LET cMen_ret = '';
				ELSE
					LET cCodRet = '00000'; -- Permite disposicion
					LET vIDispEfec = '';
					LET vLinCredAct = 0;
					LET cMen_ret = '';	
				END IF; 
			ELSE
				LET cCodRet = '00000'; -- Permite disposicion
				LET vIDispEfec = '';
				LET vLinCredAct = 0;
				LET cMen_ret = '';	
			END IF;
		END IF;	
	ELSE	
		LET cCodRet = '00000'; -- Permite disposicion
		LET vIDispEfec = '';
		LET vLinCredAct = 0;
		LET cMen_ret = '';	
	END IF;

RETURN cCodRet, vIDispEfec, vLinCredAct, Trim(cMen_ret);
     
END
END PROCEDURE;