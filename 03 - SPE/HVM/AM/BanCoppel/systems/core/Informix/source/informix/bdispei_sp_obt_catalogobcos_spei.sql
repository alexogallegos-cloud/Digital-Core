CREATE PROCEDURE "informix".sp_obt_catalogobcos_spei(p_Registros INT)
RETURNING CHAR(5), INT, CHAR(20);

	--// ***************************************************************************
	--//sp_obt_catalogobcos_spei
	--//Version:			 	1.0
	--//Objetivo:	Obtener el catalogo de bancos de la tabla  si_banco
	--//			p_Registros = 1 obtiene cantidad de bancos, p_Registros = 0 obtiene catalogo
	--//Autor:	Moises Eduardo Soriano Guerrero
	--//Fecha: 20 Agosto 2015
	--// ***************************************************************************

DEFINE sql_err          INTEGER;
DEFINE isam_err         INTEGER;
DEFINE vcodret         	CHAR(5);
DEFINE vcNomBco			CHAR(20);
DEFINE vcCvecesif		INT;
DEFINE v_ContReg		SMALLINT;

LET sql_err  = 0;
LET isam_err = 0;
LET vcodret = "00000";
LET vcNomBco = "";
LET vcCvecesif = 0;
LET v_ContReg = 0;

BEGIN

	ON EXCEPTION SET sql_err, isam_err
		IF sql_err <> 0 THEN
			LET vcodret = sql_err;
			RETURN vcodret,vcCvecesif,vcNomBco;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
						
	
	IF (p_Registros = 1)THEN
		SELECT COUNT(cvecesif)
			INTO vcCvecesif
		FROM bdinteg:"informix".si_bancos
		WHERE flg_spei='1';
			
		RETURN vcodret,vcCvecesif,vcNomBco;
	END IF;
	
	IF (p_Registros = 0) THEN
			FOREACH

				SELECT cvecesif,vchrnombrecorto
				INTO vcCvecesif,vcNomBco
				FROM bdinteg:"informix".si_bancos WHERE flg_spei='1'
				ORDER BY vchrnombrecorto
					
				LET v_ContReg = v_ContReg + 1;

				IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
					CONTINUE FOREACH;
				END IF;
				
				RETURN vcodret, vcCvecesif,vcNomBco WITH RESUME;
			END FOREACH;
	END IF;
END;
END PROCEDURE;