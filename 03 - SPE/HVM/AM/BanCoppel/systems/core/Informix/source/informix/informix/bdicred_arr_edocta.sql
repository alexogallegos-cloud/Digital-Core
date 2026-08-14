CREATE PROCEDURE "informix".arr_edocta(eEmpresa CHAR(3))
RETURNING CHAR(5);



DEFINE vMinimo DECIMAL(14,2);
DEFINE vMinAnt DECIMAL(14,2);
DEFINE vCred   CHAR(20);
DEFINE vVigente DECIMAL(14,2);
DEFINE vVencido DECIMAL(14,2);
DEFINE vInsoluto DECIMAL(14,2);
DEFINE vclcobra CHAR(51);
DEFINE vcodret CHAR(3);

LET vcodret = "000";

FOREACH SELECT a.num_credito, sdo_capital + cap_tras_no_venci,
	       monto_vencido + mto_venc_trasp, sdo_cap_insoluto
	  INTO vCred, vVigente, Vvencido, vInsoluto
	  FROM sd_maecred a, sd_maesdos b
	 WHERE a.num_credito = b.num_credito
	   AND a.empresa = b.empresa
	   AND NOT a.id_unidad_prod IS NULL

	SELECT sdo_trab4 INTO vMinAnt
	  FROM sd_maesdoshist
	 WHERE fecha = "12/20/2007"
	   AND empresa = eEmpresa
	   AND num_credito = vCred;

	LET vMinimo = ROUND(((vVigente / 10) + vVencido),0);

	IF vMinimo < vMinAnt THEN
		LET vMinimo = vMinAnt;
	END IF

	IF vInsoluto < vMinimo THEN
		LET vMinimo = vInsoluto;
	END IF

	UPDATE sd_maesdoshist
	   SET monto_financiado = vMinimo,
	       sdo_trab4 = vMinimo
	 WHERE fecha = "12/20/2007"
	   AND empresa = eEmpresa
	   AND num_credito = vCred;

	UPDATE sd_maesdos
	   SET monto_financiado = vMinimo,
	       sdo_trab4 = vMinimo
	 WHERE num_credito = vCred
	   AND empresa = eEmpresa;


	UPDATE sd_encabezado2_edocta
	   SET sdo_pagar = vMinimo
	 WHERE fecha_emision = "12/20/2007"
	   AND num_credito = vCred;



END FOREACH

LET vCred = " ";

FOREACH  SELECT num_credito INTO vCred
	   FROM sd_encabezado_edocta
	 WHERE fecha_emision = "12/20/2007"

         LET vclcobra = "";
         EXECUTE PROCEDURE cobranza(eEmpresa,vCred,"12/20/2007")
                 INTO vcodret,vclcobra;

	 UPDATE sd_encabezado_edocta
	   SET cl_cobra = vclcobra
	 WHERE num_credito = vCred
         AND   fecha_emision = "12/20/2007";
END FOREACH
RETURN vcodret;
END PROCEDURE;