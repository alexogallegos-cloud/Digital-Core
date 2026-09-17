CREATE PROCEDURE "informix".sp_creacta_pag(pempresa char(3),pnumcte char(20),psecuencia  smallint,pinstrumento char(4),i_num_invers char(20),vlongcta smallint,vdiferencia smallint)
RETURNING char(5),char(20);

  DEFINE vcodret char(5);
  DEFINE vsignumcta integer;
  DEFINE sql_err integer;
  DEFINE i smallint;
  DEFINE vdigverif char(1);
  DEFINE icuenta    int;
  DEFINE vtransaccion integer;

  BEGIN
    ON EXCEPTION SET sql_err
      LET vcodret = sql_err;     
      RETURN vcodret,i_num_invers;
    END EXCEPTION;

    ON EXCEPTION IN (-235,-239,-268)
      let icuenta = 0;
    END EXCEPTION WITH RESUME;
   
	  SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;  

    -- SET DEBUG FILE TO "/informix/FAOC/Debug/Inv/sp_creacta_pag.out";
    -- TRACE ON;

    LET vsignumcta = 0;
    LET sql_err = 0;
    LET vcodret = '00000';
    LET icuenta = 0;
    LET pinstrumento = pinstrumento;
    LET vtransaccion = 0;

    WHILE icuenta = 0
      SELECT valor 
      INTO vsignumcta
      FROM "informix".sv_param
      WHERE empresa = pempresa 
      AND codparam = "signumcta";

      UPDATE "informix".sv_param
      SET valor = vsignumcta + 1
      WHERE empresa = pempresa 
      AND codparam = "signumcta";

      LET i_num_invers = vsignumcta;
      LET vdiferencia = vlongcta - length(i_num_invers) - 2;

      IF vdiferencia > 0 THEN
        FOR i = 1 TO vdiferencia
          LET i_num_invers = "0" || i_num_invers;
        END FOR;
      END IF;

      LET i_num_invers = "3"||trim(i_num_invers);

      call "informix".digver11(i_num_invers)
      returning vcodret, vdigverif;

      LET i_num_invers = trim(i_num_invers)||vdigverif;

      IF NOT EXISTS (SELECT 1 FROM bdinvers:"informix".sv_maeinv WHERE cuenta = i_num_invers AND num_cte = pnumcte AND empresa = pempresa AND  secuencia = psecuencia) THEN
        LET icuenta = 1;
      END IF;
      IF icuenta = 1 THEN
        IF EXISTS (SELECT 1 FROM bdinvers:"informix".sv_maeinv WHERE cuenta = i_num_invers AND num_cte = pnumcte AND empresa = pempresa AND  secuencia = psecuencia) THEN
          LET icuenta = 0;
        ELSE
          INSERT INTO bdinvers:"informix".sv_maeinv(empresa, cuenta, secuencia, cod_instrum, num_cte)
          VALUES(pempresa, i_num_invers, psecuencia, pinstrumento, pnumcte);
        END IF;
      END IF;
    END WHILE;

    RETURN vcodret,i_num_invers;
  END;
END PROCEDURE;