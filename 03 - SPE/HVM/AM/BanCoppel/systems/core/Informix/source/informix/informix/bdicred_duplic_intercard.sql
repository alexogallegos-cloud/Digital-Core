CREATE PROCEDURE "informix".duplic_intercard(eEmpresa CHAR(3))
RETURNING CHAR(5);

DEFINE CodRet      CHAR(5);
DEFINE pReferencia CHAR(40);
DEFINE pRfcComer   CHAR(20);
DEFINE pRef23      CHAR(23);
DEFINE pTarjeta    CHAR(20);
DEFINE Fecha       DATE;
DEFINE NumCred     CHAR(20);
DEFINE pSucursal   CHAR(4);
DEFINE pUsuario    CHAR(8);
DEFINE FolioSuc    CHAR(16);
DEFINE pTran       CHAR(4);
DEFINE SecMov      INTEGER;
DEFINE Cuantos     INTEGER;
DEFINE MontoMov    DECIMAL(14,2);
DEFINE vHoy	   DATE;
DEFINE sql_err     INTEGER;
DEFINE isam_err    INTEGER;
DEFINE error_info  VARCHAR(60);


   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "dupintercard.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;

 SET DEBUG FILE TO "dupintercard.out";
 TRACE ON;

LET CodRet = "000";
SELECT COUNT(*) INTO Cuantos
  FROM sd_transfun
 WHERE codigo_fun ="342"
   AND codigo_ref = 2;
IF CUantos = 0 THEN
	INSERT INTO sd_transfun
	 VALUES(eEMpresa, "342",2,"001","6996","BONIFICACION COMPRA");
END IF


SELECT fecha_hoy INTO vHoy FROM sd_fechas;

FOREACH SELECT fecha_mov, num_credito, sucursal, folio_suc,
	       '6996', referencia, rfc_comer, referencia23,nro_tarjeta,
	       monto, COUNT(*)
	  INTO Fecha, NumCred, pSucursal, FolioSuc, pTran,
	       pReferencia, pRfcComer, pRef23, pTarjeta, MontoMov, Cuantos
          FROM sd_movhis
         WHERE transacc_suc ="6830"
           AND reversado ="N"
	   AND monto_dls <> 1
         GROUP BY 1,2,3,4,5,6,7,8,9,10
        HAVING COUNT(*)  > 1
         ORDER BY 1


        CALL abono_cred(eEmpresa, NumCred, pSucursal, USER, pTran,
                        MontoMov, FolioSuc, pTarjeta, 0, 0, vHoy, pReferencia,
                            "A", pRfcComer, pRef23)
        RETURNING CodRet;
	IF CodRet <> "000" THEN
		CONTINUE FOREACH;
	END IF

	UPDATE sd_movhis SET monto_dls = 1
         WHERE empresa = eEmpresa
           AND num_credito = NumCred
           AND folio_suc = FolioSuc
           AND fecha_mov = Fecha;


END FOREACH



FOREACH SELECT a.num_credito, b.monto_vencido
	  INTO NumCred, MontoMov
	  FROM sd_maecred a, sd_maesdos b
	 WHERE a.empresa = b.empresa
	   AND a.num_credito = b.num_credito
	   AND monto_vencido < 0
	   AND status_cred = "BA"



	UPDATE sd_maesdos
	   SET sdo_capital = sdo_capital + MontoMov,
	       monto_vencido = 0
	 WHERE empresa = eEmpresa
	   AND num_credito = NumCred;

	UPDATE sd_maecred SET status_cred = "AA"
	 WHERE empresa = eEmpresa
	   AND num_credito = NumCred;

	UPDATE sd_amortiza_credito
	   SET capital_status = "1"
	 WHERE empresa = eEmpresa
	   AND num_credito = NumCred
	   AND capital_status ="7";

END FOREACH



return CodRet;

END PROCEDURE
;