CREATE PROCEDURE "informix".sp_cancel_presdig (pNumCred  CHAR(20)) 	
RETURNING CHAR(5), VARCHAR(90);    

DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr     		INTEGER;
DEFINE cErrorInfo   		VARCHAR(255,1);
DEFINE COD_RET      		CHAR(5);
DEFINE cCodRet2				CHAR(6);
DEFINE cCodRet      	    CHAR(6);
DEFINE cMen_ret 			VARCHAR(100,1);
DEFINE cNumeroFolio 	    CHAR(16);
DEFINE P_MENSAJE		    VARCHAR(90);
DEFINE v_empresa 		    CHAR(3);

DEFINE vNumCredito  	    CHAR(20);
DEFINE vNumCte 			    CHAR(20);
DEFINE vStatus			    CHAR(2);
DEFINE vSucursal		    CHAR(4);
DEFINE vSecCred             SMALLINT;
DEFINE vFechaOtorga         DATE;
DEFINE vFechaVencCred    	DATE;
DEFINE vFechaCancela        DATE;
DEFINE vFechaUltMod 	    DATE;
DEFINE vMontoDisp           DECIMAL(18,2);
DEFINE vLineaDisp           DECIMAL(18,2);
DEFINE vCancelPf            CHAR(1);
DEFINE vFechaUltPf          DATE;
DEFINE vFechaHoy            DATE;
DEFINE pEjecutivo           VARCHAR(8);
							  

					
LET iSqlErr         		= 0;
LET iIsamErr        		= 0;
LET cErrorInfo      		= "";
LET COD_RET         		= "00000";
LET cMen_ret     			= "";
LET cNumeroFolio            = "";
LET cCodRet2                = '';
LET P_MENSAJE               = 'PROCESO EXITOSO';

LET vNumCredito             = '';
LET vNumCte                 = '';
LET vStatus                 = '';
LET vSucursal               = '';
LET vSecCred                = 0;
LET vFechaOtorga            = '';
LET vFechaVencCred          = '';   
LET vFechaCancela           = '';
LET vFechaUltMod            = '';
LET vMontoDisp              = 0;
LET vLineaDisp              = 0;
LET vCancelPf               = '';
LET vFechaUltPf             = '';
LET v_empresa 		        = '001';
LET vFechaHoy               = '';
LET pEjecutivo              = '';
LET cCodRet      	        = '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo

    IF iSqlErr != 0 THEN
		LET COD_RET = iSqlErr;
		LET P_MENSAJE = 'Error al ejecutar el proceso.';
		RETURN COD_RET,P_MENSAJE;
	END IF;

END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	--SET debug FILE TO "/respaldos/krgb/sp_cancel_presdig.out";
	--TRACE ON;
	
	SELECT fecha_hoy INTO vFechaHoy FROM bdicred:"informix".sd_fechas WHERE empresa = v_empresa;

	SELECT {+AVOID_FULL(bdicred:"informix".sd_linea_prestamo)} pres.num_credito, crd.numcte, crd.status_cred, crd.sucursal, pres.sec_credito, pres.fecha_otorga, crd.fecha_vencim, pres.fecha_cancela, pres.fecha_ult_mod, 
	pres.monto_linea, pres.linea_disponible , pres.cancel_pf, pres.fecha_ult_pf 
	INTO vNumCredito,  vNumCte, vStatus, vSucursal, vSecCred, vFechaOtorga, vFechaVencCred, vFechaCancela, vFechaUltMod, vMontoDisp, vLineaDisp, vCancelPf, vFechaUltPf 
	FROM bdicred:"informix".sd_linea_prestamo pres
	JOIN bdicred:"informix".sd_maecredcrd crd ON (pres.num_credito = crd.num_credito)		
																					  
	WHERE pres.num_credito = pNumCred;
	
	IF vStatus IN ('AA','E1') AND vSecCred = 0 AND vMontoDisp = vLineaDisp THEN
		-- SE GENERA EL FOLIO
		LET pEjecutivo = 'informix';
		CALL bdicheq:"informix".sp_generafolionomina(pEjecutivo) RETURNING cCodRet2, cNumeroFolio; 

		IF cCodRet2::integer  <> '000' THEN
			LET COD_RET = "00002";  --Error en sp_generafolionomina
			LET P_MENSAJE = 'Error en la generacion de folio del movimiento';
			RETURN COD_RET,P_MENSAJE;
		ELSE				
			-- SE GENERA MOVIMIENTO DE RECUPERACION LINEA PRESTAMO DIGITAL
			EXECUTE PROCEDURE bdicred:genmovcrd(v_empresa,pNumCred, '6800', 2, '002', vFechaHoy, vMontoDisp, cNumeroFolio, vSucursal, '01', '7480', 'Cancelacion Linea Prestamo Digital' , '' ) INTO cCodRet, cErrorInfo;

			IF cCodRet::integer  <> '000000' THEN
				LET COD_RET = "00004"; --Error en genmovcrd		
				LET P_MENSAJE = 'Error en la generacion del movimiento';
				RETURN COD_RET,P_MENSAJE;			   
			ELSE		
				UPDATE "informix".sd_maecredcrd SET status_cred = "FF", fecha_vencim = vFechaHoy WHERE empresa = v_empresa AND num_credito = pNumCred;
				UPDATE bdicred:"informix".sd_linea_prestamo SET fecha_cancela = vFechaHoy, cancel_pf = '1', fecha_ult_pf = vFechaHoy WHERE num_credito = pNumCred;	
			END IF;	
		END IF;
	ELIF vStatus = 'FF' AND vMontoDisp = vLineaDisp THEN	--Caso en que se tenga alguna disposicion     
							
		-- SE GENERA EL FOLIO
		LET pEjecutivo = 'informix';
		CALL bdicheq:"informix".sp_generafolionomina(pEjecutivo) RETURNING cCodRet2, cNumeroFolio; 

		IF cCodRet2::integer  <> '000' THEN
			LET COD_RET = "00002";  --Error en sp_generafolionomina
			LET P_MENSAJE = 'Error en la generacion de folio del movimiento';
			RETURN COD_RET,P_MENSAJE;			   
		ELSE
			-- SE GENERA MOVIMIENTO DE RECUPERACION LINEA PRESTAMO DIGITAL
			EXECUTE PROCEDURE bdicred:genmovcrd(v_empresa,pNumCred, '6800', 2, '002', vFechaHoy, vMontoDisp, cNumeroFolio, vSucursal, '01', '7480', 'Cancelacion Linea Prestamo Digital' , '' ) INTO cCodRet, cErrorInfo;					
			
			IF cCodRet::integer  <> '000000' THEN
				LET COD_RET = "00004"; --Error en genmovcrd
				LET P_MENSAJE = 'Error en la generacion del movimiento';
				RETURN COD_RET,P_MENSAJE;
			ELSE
				UPDATE bdicred:"informix".sd_linea_prestamo SET fecha_cancela = vFechaHoy, cancel_pf = '1', fecha_ult_pf = vFechaVencCred WHERE num_credito = pNumCred;
			END IF;					
		END IF;		
	END IF;
	
	IF vMontoDisp <> vLineaDisp THEN
		LET COD_RET = "00003";
		LET P_MENSAJE = 'No se cancelo prestamo digital. Favor de revisar si cuenta con algun adeudo.';
		RETURN COD_RET,P_MENSAJE;
	END IF;
	
RETURN COD_RET,P_MENSAJE;
     
END
END PROCEDURE;