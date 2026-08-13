create procedure "informix".quita_moracc()
returning CHAR(3);

define codret CHAR(3);
define v_credito CHAR(20);
LET codret="000";
	FOREACH SELECT num_credito INTO v_credito
		  FROM sd_maecred
		 where status_cred = "CC"

		UPDATE sd_maesdos set sdo_exig_int =0,
				      sdo_no_exig = 0,
				      mto_venc_int = 0,
				      mto_venc_tra_int = 0
		 WHERE num_credito = v_credito;


		UPDATE sd_paginter SET monto_cuota =0
		 WHERE num_credito = v_credito;


	END FOREACH



return codret;



END PROCEDURE;