CREATE PROCEDURE "informix".corrige_sdos2009(eEmpresa CHAR(3))
RETURNING CHAR(5);



DEFINE NumCred     CHAR(20);
DEFINE Insoluto    DECIMAL(14,2);
DEFINE Capital     DECIMAL(14,2);
DEFINE sql_err     INTEGER;
DEFINE isam_err    INTEGER;
DEFINE error_info  VARCHAR(60);
DEFINE CodRet      CHAR(5);
DEFINE MtoVencido DECIMAL(14,2);
DEFINE CUantos    SMALLINT;
DEFINE Vencido    DECIMAL(14,2);
DEFINE NoVencido  DECIMAL(14,2);
DEFINE NumProducto CHAR(4);
DEFINE vSucursal   CHAR(4);
DEFINE vDivisa     CHAR(2);
DEFINE Folio       CHAR(16);



   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "dupintercard.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;

 SET DEBUG FILE TO "dupintercard.out";
 TRACE ON;

LET CodRet ="000";

FOREACH SELECT a.num_credito, (SELECT COUNT(*) FROM sd_amortiza_credito c
			        WHERE c.empresa = a.empresa
				  AND c.num_credito = a.num_credito
				  AND c.capital_status IN ("2","7")),
	       mto_venc_trasp, cap_tras_no_venci, num_producto,
	       sucursal, divisa
	  INTO NumCred, Cuantos, Vencido, NoVencido, NumProducto,
	       vSucursal, vDivisa
	  FROM sd_maecred a, sd_maesdos b
	 WHERE a.empresa = eEmpresa
	   AND status_cred = "BT"
	   AND b.num_credito = a.num_credito
	   AND b.empresa = a.empresa


	IF Cuantos <> 1 THEN
		CONTINUE FOREACH;
	END IF

        SELECT
           USER||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(current,3,2)||
           SUBSTR(CURRENT,12,2)||substr(current,15,2)
           ||SUBSTR(current,18,2)
        INTO Folio
        FROM dual;


	UPDATE sd_maesdos
	   SET monto_vencido = Vencido,
	       sdo_capital = NoVencido,
	       mto_venc_trasp = 0,
	       cap_tras_no_venci = 0
	 WHERE num_credito = NumCred
	   AND empresa = eEmpresa;

	UPDATE sd_maesdoshist
	   SET monto_vencido = Vencido,
	       sdo_capital = NoVencido,
	       mto_venc_trasp = 0,
	       cap_tras_no_venci = 0
	 WHERE num_credito = NumCred
	   AND empresa = eEmpresa
	   AND fecha = "09/20/2007";

	UPDATE sd_maecred SET status_cred ="BA"
	 WHERE num_credito = NumCred
	   AND empresa = eEmpresa;

	UPDATE sd_maecredanexo SET fecha_vencto ="08/20/2007"
	 WHERE num_credito = NumCred
	   AND empresa = eEmpresa;


        CALL GenMov(eEmpresa, NumCred, NumProducto,1,
                    "602", "09/21/2007", Vencido,
                    Folio, vSucursal, vDivisa, "0000")
        RETURNING  CodRet, error_info;



END FOREACH


FOREACH SELECT a.num_credito, (SELECT COUNT(*) FROM sd_amortiza_credito c
                                WHERE c.empresa = a.empresa
                                  AND c.num_credito = a.num_credito
                                  AND c.capital_status IN ("2","7")),
               mto_venc_trasp, sdo_capital + cap_tras_no_venci, num_producto,
               sucursal, divisa
          INTO NumCred, Cuantos, Vencido, NoVencido, NumProducto,
               vSucursal, vDivisa
          FROM sd_maecred a, sd_maesdos b
         WHERE a.empresa = eEmpresa
           AND status_cred = "BT"
           AND b.num_credito = a.num_credito
           AND b.empresa = a.empresa


        IF Cuantos <> 0 THEN
                CONTINUE FOREACH;
        END IF
        UPDATE sd_maesdos
           SET monto_vencido = 0,
               sdo_capital = NoVencido,
               mto_venc_trasp = 0,
               cap_tras_no_venci = 0
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

        UPDATE sd_maesdoshist
           SET monto_vencido = 0,
               sdo_capital = NoVencido,
               mto_venc_trasp = 0,
               cap_tras_no_venci = 0
         WHERE num_credito = NumCred
           AND empresa = eEmpresa
           AND fecha = "09/20/2007";

        UPDATE sd_maecred SET status_cred ="AA"
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

        UPDATE sd_maecredanexo SET fecha_vencto = NULL
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;


END FOREACH

   FOREACH SELECT a.num_credito,
                  (SELECT COUNT(*) FROM sd_amortiza_credito
                    where empresa =eEmpresa
                      AND num_credito = a.num_credito
                      AND capital_status IN ("7","2"))
             INTO NumCred, Cuantos
             FROM sd_maecred a
            WHERE status_cred = "AA"


             IF Cuantos = 0 THEN
                CONTINUE FOREACH;
             END IF


             UPDATE sd_amortiza_credito
                SET capital_status ="5"
              WHERE num_credito = NumCred
                AND empresa = eEmpresa
                AND fecha_cuota <= "08/20/2007";


   END FOREACH

   FOREACH SELECT a.num_credito,
                  (SELECT COUNT(*) FROM sd_amortiza_credito
                    where empresa =eEmpresa
                      AND num_credito = a.num_credito
                      AND capital_status IN ("7"))
             INTO NumCred, Cuantos
             FROM sd_maecred a
            WHERE status_cred = "BA"


             IF Cuantos <> 2 THEN
                CONTINUE FOREACH;
             END IF

             UPDATE sd_amortiza_credito
                SET capital_status ="5"
              WHERE num_credito = NumCred
                AND empresa = eEmpresa
                AND fecha_cuota < ("08/20/2007");

             UPDATE sd_amortiza_credito
                SET capital_status ="7"
              WHERE num_credito = NumCred
                AND empresa = eEmpresa
                AND fecha_cuota IN ("08/20/2007");

   END FOREACH

   FOREACH SELECT num_credito
             INTO NumCred
             FROM sd_maecred a
	    WHERE num_credito ="600000005691"
	      AND empresa = eEmpresa

	UPDATE sd_maesdos
	   SET sdo_capital = sdo_cap_insoluto,
	       monto_vencido = 0,
	       mto_venc_trasp = 0,
	       cap_tras_no_venci = 0
	 WHERE num_credito = "600000005691"
	   AND empresa = eEmpresa;

        UPDATE sd_maecred SET status_cred ="AA"
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

        UPDATE sd_maecredanexo SET fecha_vencto = NULL
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

	UPDATE sd_amortiza_credito
	   SET capital_status = "5"
	 WHERE empresa = "001"
	   AND num_credito = NumCred
	   AND empresa = "001"
	   AND fecha_cuota < "09/20/2007"
	   AND capital_status IN ("2","7");

   END FOREACH

   FOREACH SELECT a.num_credito,
                  (SELECT COUNT(*) FROM sd_amortiza_credito
                    where empresa =eEmpresa
                      AND num_credito = a.num_credito
                      AND capital_status IN ("7"))
             INTO NumCred, Cuantos
             FROM sd_maecred a, sd_maesdos b
            WHERE status_cred = "AA"
	      AND a.num_credito = b.num_credito
	      AND cap_tras_no_venci > 0

        UPDATE sd_maesdos
           SET sdo_capital = sdo_cap_insoluto,
               monto_vencido = 0,
               mto_venc_trasp = 0,
               cap_tras_no_venci = 0
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

        UPDATE sd_maecred SET status_cred ="AA"
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

        UPDATE sd_maecredanexo SET fecha_vencto = NULL
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

  END FOREACH


   FOREACH SELECT a.num_credito,
                  (SELECT COUNT(*) FROM sd_amortiza_credito
                    where empresa =eEmpresa
                      AND num_credito = a.num_credito
                      AND capital_status IN ("7"))
             INTO NumCred, Cuantos
             FROM sd_maecred a, sd_maesdos b
            WHERE status_cred = "BT"
              AND a.num_credito = b.num_credito
              AND cap_tras_no_venci > 0
	      AND sdo_capital > 0
	      AND mto_venc_trasp > 0

        UPDATE sd_maesdos
           SET sdo_capital = cap_tras_no_venci,
               monto_vencido = sdo_capital + mto_venc_trasp,
               mto_venc_trasp = 0,
               cap_tras_no_venci = 0
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

        UPDATE sd_maecred SET status_cred ="BA"
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

        UPDATE sd_maecredanexo SET fecha_vencto = "08/20/2007"
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

        UPDATE sd_amortiza_credito
           SET capital_status = "5"
         WHERE empresa = "001"
           AND num_credito = NumCred
           AND empresa = "001"
           AND fecha_cuota < "08/20/2007"
           AND capital_status IN ("2","7");



  END FOREACH


  UPDATE sd_maesdos set cap_tras_no_venci = 0
   WHERE num_credito = "600000053196"
     AND empresa = "001";




RETURN CodRet;

END PROCEDURE
;