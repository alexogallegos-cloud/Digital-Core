CREATE PROCEDURE "informix".sp_obtener_cta_con_num_tar_cred(pEmpresa char(3),
                                                        pNumTarj char(16))
        RETURNING char(5), char(20);


       DEFINE vcodret char(5);
       DEFINE vcuenta char(20);
       DEFINE sql_err integer;

	LET vcodret = '000';
	LET vcuenta = '';

--set debug file to "/home/informix/bibiana/sp_obtener_cta_con_num_tar_cred";
--trace on;
--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;


	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vcodret = sql_err;
				RETURN vcodret, vcuenta;
		    END IF;
		END EXCEPTION;
		IF EXISTS(SELECT num_credito FROM bdicred:"informix".sd_tarjeta WHERE empresa = pEmpresa AND num_tarjeta = pNumTarj AND tipo_tarjeta = 'T' AND status_tar = 'A' ) THEN
			SELECT num_credito 
			INTO vcuenta
			FROM bdicred:"informix".sd_tarjeta 
			WHERE empresa = pEmpresa 
			AND num_tarjeta = pNumTarj
			AND tipo_tarjeta = 'T' AND status_tar = 'A' ;
		ELSE
			LET vcodret = '001';
		END IF;
		RETURN vcodret, vcuenta;
	END;
END PROCEDURE;