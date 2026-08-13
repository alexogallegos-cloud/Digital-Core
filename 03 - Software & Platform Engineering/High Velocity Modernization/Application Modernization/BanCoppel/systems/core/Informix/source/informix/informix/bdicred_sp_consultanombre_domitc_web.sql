CREATE PROCEDURE "informix".sp_consultanombre_domitc_web
(
   pEmpresa CHAR(3),
   pNumCte CHAR(9),
   pNumCuenta CHAR(20),
   pNumTarjeta CHAR(20)
)
RETURNING CHAR(5) AS CodRet , CHAR(9) AS NumCliente, CHAR(107) AS NombreCte, CHAR(1) AS Status;

DEFINE  cCodRet           CHAR(5);
DEFINE  iSql_err          INTEGER;
DEFINE  cNombre1          CHAR(26);
DEFINE  cNombre2          CHAR(26);
DEFINE  cApellPat         CHAR(26);
DEFINE  cApellMat         CHAR(26);
DEFINE  cStatusServElec   CHAR(1);
DEFINE  cNombreCompleto   CHAR(107);
DEFINE  tpo_tarjeta       CHAR(20);

LET  cCodRet         = '00000';
LET  iSql_err        = 0;
LET  cNombre1        = "";
LET  cNombre2        = "";
LET  cApellPat       = "";
LET  cApellMat       = "";
LET  cStatusServElec = "";
LET  cNombreCompleto = "";
LET  tpo_tarjeta     = "";

BEGIN

    ON EXCEPTION SET iSql_err
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
           RETURN cCodRet, NVL(pNumCte,''), TRIM(cNombreCompleto), cStatusServElec;
        END IF;
    END EXCEPTION;

     --SET DEBUG FILE TO "/home/tmp/sp_consultanombre_domi.out";
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND (NVL(pNumTarjeta,'') <> '' OR NVL(pNumCte,'')<> '' OR NVL(pNumCuenta,'')<> '') THEN

		IF NVL(pNumCuenta,'') <> '' THEN

			SELECT LIMIT 1 num_cte         --verifica si es tarjeta de debito
			INTO pNumCte
			FROM bdicheq:"informix".sc_maechq
			WHERE empresa = pEmpresa
			AND cuenta = pNumCuenta;

			IF dbinfo("sqlca.sqlerrd2") = 0 THEN

				SELECT LIMIT 1 numcte   --verifica si es tarjeta de credito
				INTO pNumCte
				FROM bdicred:"informix".sd_maecred
				WHERE empresa = pEmpresa
				AND num_credito = pNumCuenta;

				IF dbinfo("sqlca.sqlerrd2") = 0 THEN

					SELECT LIMIT 1 numcte   --verifica si es prestamo o reestructura
					INTO pNumCte
					FROM bdicred:"informix".sd_maecredcrd
					WHERE empresa = pEmpresa
					AND num_credito = pNumCuenta;

					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
							LET cCodRet = '00003';
					END IF;
				END IF;
			END IF;
		END IF;

		IF NVL(pNumTarjeta,'') <> '' THEN

			SELECT LIMIT 1 numcte
			INTO pNumCte
			FROM bdicheq:"informix".sc_tarjeta
			WHERE empresa = pEmpresa
			AND num_tarjeta = pNumTarjeta
			AND status_tar = "A"
			AND tipo_tarjeta="T";

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN

				SELECT LIMIT 1 numcte, tipo_tarjeta
				INTO pNumCte,tpo_tarjeta
				FROM bdicred:"informix".sd_tarjeta
				WHERE empresa = pEmpresa
				AND num_tarjeta = pNumTarjeta
				AND status_tar = "A";
			  --  AND tipo_tarjeta="T";

				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00002';
				END IF;
				IF tpo_tarjeta <>"T" THEN 
					LET cCodRet = '00005';
					RETURN cCodRet, NVL(pNumCte,''), TRIM(cNombreCompleto), cStatusServElec;
				END IF;	
			END IF;
		END IF;

		IF NVL(pNumCte,'') <> '' THEN
			SELECT nombre1, nombre2, apell_paterno, apell_materno
			INTO cNombre1, cNombre2, cApellPat, cApellMat
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = pNumCte;

			LET cNombreCompleto = TRIM(cNombre1) || " " || TRIM(cNombre2) || " " || TRIM(cApellPat) ||" " || TRIM(cApellMat);

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00002';
			ELSE
				SELECT LIMIT 1 status_serv_elec
				INTO cStatusServElec
				FROM bdiedoelec:"informix".edelec_alta_serv
				WHERE numcte = pNumCte
				AND status_serv_elec = 'A';

				IF  DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cStatusServElec = 'I';
				END IF;
			END IF;
		END IF;
    ELSE
        LET cCodRet = '00001'; --parametros vacios
    END IF;

        RETURN cCodRet, NVL(pNumCte,''), TRIM(cNombreCompleto), cStatusServElec;
END;
END PROCEDURE;