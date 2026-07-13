CREATE PROCEDURE "informix".sp_creacta_inv(pempresa char(3),pnum_cte char(20),pproducto char(4),pcuenta char(20),vlongcta smallint,vdiferencia smallint,vidcta char(1))
RETURNING char(5),char(20);

DEFINE vcodret char(5);
DEFINE vsignumcta integer;
DEFINE sql_err integer;
DEFINE vparamsigcta char(20);
DEFINE icuenta int;
DEFINE i SMALLINT;
DEFINE vdigverif char(1);

	BEGIN
		ON EXCEPTION SET sql_err
			LET vcodret = sql_err; 
			RETURN vcodret,pcuenta;
		END EXCEPTION;
		ON EXCEPTION IN (-235,-239,-268)
			let icuenta = 0;
		END EXCEPTION WITH RESUME;
		
		set isolation to dirty read;	
		SET LOCK MODE TO WAIT 15;  

		-- SET DEBUG FILE TO "/informix/FAOC/Debug/Inv/sp_creacta_inv.out";
		-- TRACE ON;

		LET vsignumcta = 0;
		LET sql_err = 0;
		LET vcodret = '00000';
		LET vparamsigcta = '';
		LET icuenta = 0;
		
		-- ******************************************
		-- Extra consecutivo de acuerdo al producto *
		-- ******************************************
		IF pproducto <= '2000' THEN
			LET vparamsigcta = "signumcta" || TRIM(vidcta);
		ELSE
			LET vparamsigcta = "signumcta" || SUBSTR(pproducto, 1, 2);
		END IF;
		
		WHILE icuenta = 0
		
			SELECT valor
			INTO vsignumcta
			FROM bdicheq:"informix".sc_param
			WHERE empresa = pempresa
			AND codparam = TRIM(vparamsigcta);
			IF vsignumcta IS NULL THEN
				LET vcodret = "933";
				RETURN vcodret,pcuenta;
			END IF;

			LET pcuenta = vsignumcta;

			UPDATE bdicheq:"informix".sc_param
			SET valor = vsignumcta + 1
			WHERE empresa = pempresa
			AND codparam =  TRIM(vparamsigcta);
			
			LET vdiferencia = vlongcta - LENGTH(pcuenta) - 3;

			IF vdiferencia > 0 THEN
				FOR i = 1 TO vdiferencia
					LET pcuenta = "0" || pcuenta;
				END FOR;
			END IF

			IF pproducto <= '2000' THEN
				LET pcuenta = "1" || TRIM(vidcta) || TRIM(pcuenta);
				ELSE
						LET pcuenta = SUBSTR(pproducto, 1, 2) || TRIM(pcuenta);
			END IF;	

			CALL "informix".digver11(pcuenta)
			RETURNING vcodret,vdigverif;
			LET pcuenta = TRIM(pcuenta)||vdigverif;

			IF NOT EXISTS (SELECT 1 FROM bdicheq:"informix".sc_maechq WHERE empresa = pempresa AND cuenta = pcuenta) THEN
				LET icuenta = 1;
				INSERT INTO bdicheq:"informix".sc_maechq(empresa, cuenta, producto, num_cte, status_cta)
				VALUES (pempresa,pcuenta,pproducto,pnum_cte,"1");
			END IF;
		END WHILE;
		RETURN vcodret,pcuenta;
	END;
END PROCEDURE;