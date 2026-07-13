CREATE PROCEDURE "informix".cons_imgnula(pempresa CHAR(3),
		       	pcliente   	CHAR(20),
                pcoddocto   CHAR(4),
		       	psecuencia 	SMALLINT)
			RETURNING
			CHAR(5),CHAR(1);


   DEFINE v_codret          CHAR(5);
   DEFINE v_esnula          CHAR(1);
   DEFINE sql_err,isam_err  int;

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************
   LET v_codret     = "000";
   LET v_esnula     = "-1";

BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         RETURN v_codret,v_esnula;
      end if;
   end exception;

SET ISOLATION DIRTY READ;
SET LOCK MODE TO WAIT 3;
-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

	IF  pempresa is null or
        pcliente is null or
	 	pcoddocto is null or
		psecuencia is null then

	   -- datos de entrada incompletos

	   let v_codret = 110;
	   RETURN v_codret,v_esnula;
	END IF;

-- ****************************************************************************
-- devuelve 1 si la imagen es nula, y 0 si no
-- ****************************************************************************

        SELECT "1"
        INTO    v_esnula
        FROM    dg_expediente_img1
        WHERE   empresa = pempresa
		and cliente     = trim(pcliente)
                and cod_docto   = pcoddocto
                and secuencia   = psecuencia
                and imagen is null;

        IF v_esnula <> "1" or v_esnula is null then
                LET v_esnula = "0";
        END IF;

	RETURN v_codret,v_esnula;

END;
END PROCEDURE;