CREATE PROCEDURE "informix".sp_act_sdoamortiza(eEmpresa CHAR(3), pNumCrd CHAR(20))
       RETURNING VARCHAR(5);

DEFINE P_COD_RET  VARCHAR(5);
DEFINE P_MENSAJE  VARCHAR(80);

DEFINE SQL_ERR    INTEGER;
DEFINE ISAM_ERR   INTEGER;
DEFINE ERROR_INFO VARCHAR(80);
DEFINE vNumCrd    char(20);
DEFINE vMtoOtorgado decimal(14,2);
DEFINE vSdoInsoluto decimal(14,2);
DEFINE vDifSdo      decimal(14,2);
DEFINE vStatus      char(2);
					   
					   
DEFINE vMtoCapAMortiza decimal(14,2);
DEFINE vDifMtoOtorgado decimal(14,2);
DEFINE vDifSdoReal     decimal(14,2);
DEFINE vMtoCapPago     decimal(14,2);
DEFINE vCapNoExigAmortiza     decimal(14,2);
DEFINE vCapExigAmortiza     decimal(14,2);
DEFINE vCapExigible     decimal(14,2);
DEFINE vCapNoExigible     decimal(14,2);
DEFINE vCapTotal     decimal(14,2);
DEFINE vFecActualiza   date;

BEGIN
  ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET  = SQL_ERR;
     LET P_MENSAJE  = ERROR_INFO;
     RETURN P_COD_RET;
  END EXCEPTION;

 --SET DEBUG FILE TO "/tmp/sp_actamo.out";
 --TRACE ON;



  LET P_COD_RET       = '00000';
  LET P_MENSAJE       = 'PROCESO EXITOSO';
  LET vNumCrd         = '';
  LET vMtoOtorgado    = 0;
  LET vDifSdo         = 0;
  LET vStatus         = '';
				   
				   
  LET vMtoCapAMortiza = 0;
  LET vDifMtoOtorgado = 0;
  LET vSdoInsoluto    = 0;
  LET vDifSdoReal     = 0;
  LET vMtoCapPago     = 0;
  LET vFecActualiza   = '';
  LET vCapNoExigAmortiza = 0;
  LET vCapExigAmortiza   = 0;
  LET vCapExigible       = 0;
  LET vCapNoExigible     = 0;
  LET vCapTotal          = 0;

  --FOREACH
        SELECT num_credito,status_cred
        INTO vNumCrd,vStatus
        FROM sd_maecredcrd
        WHERE empresa = eEmpresa
        AND num_credito = pNumCrd;
        --ORDER BY 1


        SELECT sdo_capital + mto_venc_trasp + monto_vencido + cap_tras_no_venci,sdo_cap_insoluto
        INTO vSdoInsoluto,vCapTotal
        FROM sd_maesdoscrd
        WHERE empresa = eEMpresa
          AND num_credito = vNumCrd;

        SELECT sum(capital_debe - capital_pagado)
        INTO vMtoCapAMortiza
        FROM sd_amortiza_creditocrd
        WHERE empresa  = eEMpresa
          AND num_credito = vNumCrd;

        SELECT max(fecha_cuota)
        INTO vFecActualiza
        FROM sd_amortiza_creditocrd
        WHERE empresa = eEmpresa
          AND num_credito = vNumCrd;

	IF (vSdoInsoluto = vCapTotal) and (vStatus = 'VP' or vStatus = 'AA' or vStatus = 'E1') THEN
             IF vSdoInsoluto  < vMtoCapAMortiza THEN
                LET vDifSdoReal =  vMtoCapAMortiza - vSdoInsoluto ;

                UPDATE sd_amortiza_creditocrd SET capital_debe = capital_debe - vDifSdoReal
                WHERE empresa = eEmpresa
                AND num_credito = vNumCrd
                AND fecha_cuota = vFecActualiza;

                UPDATE sd_amortiza_creditocrd SET capital_status = '5'
                WHERE empresa = eEmpresa
                AND num_credito = vNumCrd
                AND fecha_cuota = vFecActualiza
                AND capital_debe = capital_pagado;

             END IF;
        END IF;
  --END FOREACH;
END ;
     RETURN P_COD_RET;

END PROCEDURE;