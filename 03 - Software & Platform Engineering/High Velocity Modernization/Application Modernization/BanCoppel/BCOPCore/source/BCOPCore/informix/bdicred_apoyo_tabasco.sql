CREATE PROCEDURE "informix".apoyo_tabasco()

DEFINE vCred CHAR(20);

	FOREACH SELECT num_credito INTO vCred
		  FROM sd_apoyotabasco
		 

		UPDATE bdicred:sd_maecred 
		   SET id_unidad_prod = 1
		 WHERE num_credito = vCred
		   AND empresa = "001";


	END FOREACH



END PROCEDURE
;