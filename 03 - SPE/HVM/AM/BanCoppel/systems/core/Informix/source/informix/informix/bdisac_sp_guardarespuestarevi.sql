CREATE PROCEDURE "informix".sp_guardarespuestarevi(pSucursal CHAR (4), 
                                        pTxn_Status CHAR(1), 
										pConfirmation_nm CHAR (11), 
										pProcess_Reason_Cd CHAR(3), 
                                        pBank_Ref_Num CHAR(20), 
										pRev_Bank_Ref_Nm CHAR(20), 
										pUser_name CHAR(20), 
										pSup_User_Name CHAR(20), 
										pTerminal CHAR(15), 
										pAgent_Dt CHAR(8), 
	                                    pAgent_Tm CHAR(6), 
										pOpCode CHAR(4), 
										pProcess_Msg CHAR(255), 
										pError_Param_Full_Name CHAR(255), 
										pTrans_Status_Cd CHAR(3), 
										pTrans_Status_Dt CHAR(8),
	                                    pProcess_Dt CHAR(8), 
										pProcess_Tm CHAR(6), 
										pService_Cd CHAR(3), 
										pPaymet_Type_Cd CHAR(3), 
										pOrig_Country_Cd CHAR(3), 
										pOrig_Currency_Cd CHAR(3), 
	                                    pDest_Country_Cd CHAR(3), 
										pDest_Currency_Cd CHAR(3), 
										pOrig_Am CHAR(20), 
										pDestination_Am CHAR(20), 
										pExch_Rate_Fx CHAR(21), 
										pR_First_Name CHAR(40), 
	                                    pR_Middle_Name CHAR(40), 
										pR_Last_Name CHAR(40), 
										pR_Mother_M_Name CHAR(40), 
										pUsuario CHAR(8))


	--DATOS A REGRESAR---
    RETURNING
    CHAR(5);   -- Codigo de Retorno
	
	 --DEFINICION DE VARIABLES--
    DEFINE sql_err                INT;
    DEFINE cCodRet                CHAR(5);
	DEFINE cAgent_Trans_Type_Code CHAR(4);
	DEFINE cAgent_Cd              CHAR(3);
	DEFINE cRegion_Sd             CHAR(15);
	DEFINE cBranch_Sd             CHAR(15);
	DEFINE cState_Cd              CHAR(3);
	DEFINE cCountry_Cd            CHAR(3);
	
	
	--INICIALIZACION DE VARIABLES--
    LET sql_err                = 0;
    LET cCodRet                = '00000';
	LET cAgent_Trans_Type_Code = 'REVI';
	LET cAgent_Cd              = '';
	LET cRegion_Sd             = '';
	LET cBranch_Sd             = '';
	LET cState_Cd              = '';
	LET cCountry_Cd            = '';
	
	
	--SET DEBUG FILE TO "/respaldosbd/Dulce/sp_GuardaRespuestaRevi.out";
   -- TRACE ON;
	
	BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCodRet = sql_err;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
	
	IF pSucursal = "" OR  pSucursal IS NULL OR pTxn_Status = "" OR pTxn_Status IS NULL 
	    OR pConfirmation_nm = "" OR pConfirmation_nm IS NULL  OR pProcess_Reason_Cd = "" OR pProcess_Reason_Cd IS NULL  
		OR pBank_Ref_Num = "" OR pBank_Ref_Num IS NULL  OR pRev_Bank_Ref_Nm = "" OR pRev_Bank_Ref_Nm IS NULL  
	    OR pUser_name = "" OR pUser_name IS NULL OR pTerminal = "" OR pTerminal IS NULL OR pAgent_Dt = "" OR pAgent_Dt IS NULL 
		OR pAgent_Tm = "" OR pAgent_Tm IS NULL  OR pSup_User_Name = "" OR pSup_User_Name IS NULL OR pUsuario = "" OR pUsuario IS NULL THEN
		LET cCodRet = "00001";
		RETURN cCodRet;
	END IF;
		
	SET ISOLATION TO DIRTY READ;
	
	EXECUTE PROCEDURE BDISAC:sp_consultasucursal (pSucursal) 
	INTO cCodRet, cAgent_Cd, cRegion_Sd, cBranch_Sd, cState_Cd, cCountry_Cd;
	IF cCodRet = "00000" THEN
		INSERT INTO sac_bts_revi (txn_status, agent_trans_type_code, agent_cd, confirmation_nm, process_reason_cd, bank_ref_nm, rev_bank_ref_nm,
		        region_sd, branch_sd, state_cd, country_cd, user_name, sup_user_name, terminal, agent_dt, agent_tm, sucursal, opcode, process_msg, 
				error_param_full_name, trans_status_cd, trans_status_dt, process_dt, process_tm, service_cd, paymet_type_cd, orig_country_cd, 
				orig_currency_cd, dest_country_cd, dest_currency_cd, orig_am, destination_am, exch_rate_fx, r_first_name, r_middle_name, 
				r_last_name, r_mother_m_name, user_insert, fecha_insert)
		VALUES(pTxn_Status, cAgent_Trans_Type_Code, cAgent_Cd, pConfirmation_Nm, pProcess_Reason_Cd, pBank_Ref_Num, pRev_Bank_Ref_Nm, cRegion_Sd, 
		        cBranch_Sd, cState_Cd, cCountry_Cd, pUser_Name, pSup_User_Name, pTerminal, pAgent_Dt, pAgent_Tm, pSucursal, pOpCode, pProcess_Msg, 
				pError_Param_Full_Name, pTrans_Status_Cd, pTrans_Status_Dt, pProcess_Dt, pProcess_Tm, pService_Cd, pPaymet_Type_Cd, pOrig_Country_Cd, 
				pOrig_Currency_Cd, pDest_Country_Cd, pDest_Currency_Cd, pOrig_Am, pDestination_Am, pExch_Rate_Fx, pR_First_Name, pR_Middle_Name, 
				pR_Last_Name, pR_Mother_M_Name, pUsuario, CURRENT);			 
	END IF;
	
	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea SP para guardar los datos de envio y recepción del mensaje REVI de BTS',
'AUTOR : Dulce Ramirez',
'FECHA : 05/Enero/2011',
'Ver.  : 1.1',
'BD    : bdisac',
'VER   : 1.1';

CREATE PROCEDURE "informix".sp_reportebts_mensual ( pdtPeriodo DATE )

RETURNING INTEGER AS Dia, INTEGER AS Tot_Operaciones, MONEY AS Monto;

--****************************************************************************************************
-- DESCRIPCION:  GENERA REPORTE DE TBS  MENSUAL
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 18/11/2010
-- BD: BDISAC
-- SISTEMA : BTS
-- MODIFICADO :
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */

DEFINE vdtFechaIni DATE;
DEFINE vdtFechaFin DATE;

DEFINE viDia INTEGER;
DEFINE viTot_Operaciones INTEGER;
DEFINE vmMonto MONEY;

DEFINE visqlerr INTEGER ;

/* INICIALIZACION DE VARIABLES */

LET vdtFechaIni = CURRENT;
LET vdtFechaFin = CURRENT;

LET viDia = 0;
LET viTot_Operaciones = 0;
LET vmMonto = 0.0;

LET visqlerr = 0 ;

BEGIN

	ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado

		RETURN visqlerr, 0, 0.0 ;

	END EXCEPTION;

	IF (pdtPeriodo  IS NULL) THEN
		RETURN 0,0,0.0;
	ELSE

		LET vdtFechaIni = MONTH(pdtPeriodo) || '/01/' || YEAR(pdtPeriodo);
		LET vdtFechaFin = vdtFechaIni + INTERVAL (1) MONTH TO MONTH;
		--LET vdtFechaFin = vdtFechaFin - INTERVAL (1) DAY TO DAY;


		WHILE (vdtFechaIni < vdtFechaFin)

			SELECT
			DAY(vdtFechaIni) AS DIA , NVL(COUNT(Importe_Pago), 0) AS NUM_MOV, NVL(SUM(Importe_Pago),0) AS MONTO
			INTO viDia, viTot_Operaciones, vmMonto
			FROM BdiSac:Sac_MovimientosHistorial
			WHERE Fecha_Pago = vdtFechaIni
			AND NumCategoria = '07'
			AND NumConvenio = '004'
			AND status_cancelado = 'N';

			RETURN viDia, viTot_Operaciones, vmMonto WITH RESUME;

			LET vdtFechaIni = vdtFechaIni + INTERVAL (1) DAY TO DAY;

		END WHILE;


	END IF;

END

END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: BTS',
'Solicito: ',
'Descripcion: GENERA REPORTE DE TBS MENSUAL.',
'Fecha: 2010/11/18',
'Version: 20101118.1058',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_validabts(pNumBTS CHAR(11))
RETURNING VARCHAR(6) AS COD_RET,VARCHAR(80) AS MSG;

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  vAscii           INTEGER;
DEFINE  vPos             INTEGER;
DEFINE  iDigVerCapturado INTEGER;
DEFINE  iNoPeso          INTEGER;
DEFINE  iAux             INTEGER;
DEFINE  iValorDigito     INTEGER;
DEFINE  cNum1		     CHAR(1);
DEFINE  cNum2		     CHAR(1);
DEFINE  iSuma            INTEGER;
DEFINE  iResiduo         INTEGER;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;


 --+-----------------------------------------------------------------+--
 --|         FECHA: 21 de Febrero del 2011                           |--
 --|       ELABORO: Manuel Osuna Valencia                            |--
 --| FUNCIONALIDAD: Valida si el digito verificador capturado en la  |--
 --|                consulta de pagos de remesas BTS es correcto.    |--
 --|                Recibe:Numero de Confirmación BTS (11 digitos).  |--
 --|                Regresa: 0=Digito Verificador Correcto           |--
 --|                1=Digito Verificador Invalido                    |--
 --|                2=Referencia diferente de 11 digitos             |--
 --|                3=El Numero de Referencia contiene una letra     |--
 --+-----------------------------------------------------------------+--


   LET P_COD_RET = '00001';
   LET P_MENSAJE = 'PROCESO EXITOSO';
   LET vAscii = '';
   LET vPos = 1;
   LET iDigVerCapturado = 0;
   LET iNoPeso = 0;
   LET iAux = 0;
   LET iSuma = 0;
   LET iResiduo = 0;

  IF LENGTH(TRIM(pNumBTS))= 11 THEN

		IF ( (UPPER(SUBSTR(pNumBTS,11,1)) >= 'A' AND  UPPER(SUBSTR(pNumBTS,11,1)) <= 'Z' ) OR   UPPER(SUBSTR(pNumBTS,11,1)) = '±' OR  UPPER(SUBSTR(pNumBTS,11,1)) = 'Ð') THEN
			LET P_COD_RET = '00003';
			RETURN P_COD_RET,P_MENSAJE;
		ELIF (UPPER(SUBSTR(pNumBTS,vPos,1)) >= '0' AND UPPER(SUBSTR(pNumBTS,vPos,1)) <= '9' ) THEN
			LET iDigVerCapturado = SUBSTR(pNumBTS,11,1)::int;
		END IF;

		FOR vPos = 4 TO 10
			IF ( (UPPER(SUBSTR(pNumBTS,vPos,1)) >= 'A' AND  UPPER(SUBSTR(pNumBTS,vPos,1)) <= 'Z' ) OR   UPPER(SUBSTR(pNumBTS,vPos,1)) = '±' OR  UPPER(SUBSTR(pNumBTS,vPos,1)) = 'Ð') THEN
				LET P_COD_RET = '00003';
				RETURN P_COD_RET,P_MENSAJE;
			ELIF (UPPER(SUBSTR(pNumBTS,vPos,1)) >= '0' AND UPPER(SUBSTR(pNumBTS,vPos,1)) <= '9' ) THEN
				LET iValorDigito = SUBSTR(pNumBTS,vPos,1)::int;
			END IF;

			IF MOD(vPos,2)= 0 THEN
				LET iNoPeso = 2;
			ELSE
				LET iNoPeso = 1;
			END IF;

			LET iAux = iValorDigito * iNoPeso;

			IF iAux > 9 THEN
                LET cNum1 = SUBSTR(iAux::char(2),1,1) ;
				LET cNum2 = SUBSTR(iAux::char(2),2,1) ;
				LET iAux = (cNum1::int) + (cNum2::int);
			END IF;

			LET iSuma = iSuma + iAux;

		END FOR;

		LET iResiduo = mod(iSuma , 10);
		IF iResiduo > 0 THEN
			LET iValorDigito = 10 - iResiduo;
			IF iValorDigito =  iDigVerCapturado THEN
				LET P_COD_RET = '00000';
			END IF;
		ELSE
			IF iResiduo =  iDigVerCapturado THEN
				LET P_COD_RET = '00000';
			END IF;
		END IF;

  ELSE
	LET P_COD_RET = '00002';
  END IF;


 RETURN P_COD_RET,P_MENSAJE;

END
END PROCEDURE;