create procedure "informix".cons_sec_expendiente(pempresa char(3), pcliente	char(20),pcod_docto char(4))
			RETURNING char(5), smallint;


   DEFINE v_codret          char(5);
   DEFINE sql_err,isam_err  int;
   DEFINE v_secuencia smallint;

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret     = "000";
   LET v_secuencia = 0;

BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         RETURN v_codret,v_secuencia;
      end if;
   end exception;


-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************
  SET ISOLATION TO DIRTY READ;

	IF  	pempresa is null or pcliente is null or pcod_docto is null then
	   -- datos de entrada incompletos
	   let v_codret = '110';
	   RETURN v_codret,v_secuencia;
	END IF;


-- ****************************************************************************
-- devuelve la secuencia
-- ****************************************************************************
        select max(secuencia) into v_secuencia 
        from bdidigital@coppelimg_tcp:dg_expediente
        --from bdidigital@coppelimgdn_tcp:dg_expediente_img
        -----where empresa   = pempresa
        where cliente   = trim(pcliente)
        and cod_docto   = pcod_docto;

        IF v_secuencia is null then
                LET v_secuencia = 1;
        ELSE
                LET v_secuencia = v_secuencia +1;
        END IF;

	RETURN v_codret,v_secuencia;

END;
END PROCEDURE;