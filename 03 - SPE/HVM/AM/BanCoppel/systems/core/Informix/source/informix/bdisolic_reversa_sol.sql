CREATE PROCEDURE "informix".reversa_sol(r_empresa CHAR(3),
			     r_num_solicitud CHAR(20))
RETURNING CHAR(5);

-- *************************************************************************
-- *                       DEFINICION DE VARIABLES                         *
-- *************************************************************************
DEFINE vcod_ret  CHAR(5);
DEFINE vsqlerr   INTEGER;
DEFINE vtp_sol   CHAR(1);
-- *************************************************************************
-- *                       ASIGNACION DE VARIABLES                         *
-- *************************************************************************
LET vcod_ret = "00000";
LET vsqlerr  = 0;
LET vtp_sol  = " ";

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcod_ret=vsqlerr;
      RETURN vcod_ret;
   END IF;
END EXCEPTION;

-- *************************************************************************


	DELETE FROM ss_bienes_deudas
	 WHERE empresa = r_empresa
	   AND num_solicitud = r_num_solicitud;

	DELETE FROM ss_edades_depend
	 WHERE empresa = r_empresa
	   AND num_solicitud = r_num_solicitud;

	DELETE FROM ss_hipot_propiedad
	 WHERE empresa = r_empresa
	   AND num_solicitud = r_num_solicitud;

	DELETE FROM ss_hipotprop_tit
	 WHERE empresa = r_empresa
	   AND num_solicitud = r_num_solicitud;

	DELETE FROM ss_info_empleo
	 WHERE empresa = r_empresa
	   AND num_solicitud = r_num_solicitud;

	DELETE FROM ss_info_ingegre
	 WHERE empresa = r_empresa
	   AND num_solicitud = r_num_solicitud;

	DELETE FROM ss_info_prestatario
	 WHERE empresa = r_empresa
	   AND num_solicitud = r_num_solicitud;

	DELETE FROM ss_otros_ing
	 WHERE empresa = r_empresa
	   AND num_solicitud = r_num_solicitud;

	DELETE FROM ss_propiedades
	 WHERE empresa = r_empresa
	   AND num_solicitud = r_num_solicitud;

	DELETE FROM ss_tran_declara
	 WHERE empresa = r_empresa
	   AND num_solicitud = r_num_solicitud;

        DELETE FROM bdicred:sd_ctascarg
         WHERE empresa = r_empresa
           AND num_credito = r_num_solicitud;

	DELETE FROM bdicred:sd_detdocum
	 WHERE empresa = r_empresa
	   AND num_credito = r_num_solicitud;

	DELETE FROM bdigaran:sg_maegaran
	 WHERE empresa = r_empresa
	   AND num_credito = r_num_solicitud;

	DELETE FROM bdigaran:sg_aval
	 WHERE empresa = r_empresa
	   AND num_credito = r_num_solicitud;

	DELETE FROM bdigaran:sg_prend
	 WHERE empresa = r_empresa
	   AND num_credito = r_num_solicitud;

	DELETE FROM bdigaran:sg_hipot
	 WHERE empresa = r_empresa
	   AND num_credito = r_num_solicitud;

      DELETE FROM BDIGARAN:SG_HABER
       WHERE EMPRESA = r_empresa
         AND NUM_CREDITO = R_NUM_SOLICITUD;

	SELECT tipo_solicitud INTO vtp_sol
	  FROM ss_solicitudes
	 WHERE empresa = r_empresa 
	   AND num_solicitud = r_num_solicitud;

	  UPDATE ss_solicitudes SET status_solicitud = "TT"
	   WHERE empresa = r_empresa
	     AND num_solicitud = r_num_solicitud;
END
	RETURN vcod_ret;

END PROCEDURE;