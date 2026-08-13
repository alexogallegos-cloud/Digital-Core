CREATE PROCEDURE "informix".caja(p_empresa CHAR(3),
			   p_sucursal CHAR(3),
			   p_usuario  CHAR(8),
			   p_accion   CHAR(2))
RETURNING CHAR(5);

-- ***************************************************************************
-- *                         DEFINICION DE VARIABLES                         *
-- ***************************************************************************
DEFINE v_codret		CHAR(5);
DEFINE sql_err		INTEGER;
DEFINE v_apertura       INTEGER;
DEFINE v_cierre         INTEGER;
DEFINE v_tempo		INTEGER;

-- ***************************************************************************


   ON EXCEPTION SET sql_err
      LET v_codret  = "000";
      IF sql_err <> 0 THEN
         SET DEBUG FILE TO "/apasco/pisa_ftes/ofi.spl/caja.out";
         TRACE ON;
         LET v_codret = sql_err;
         RETURN v_codret;
      END IF
   END EXCEPTION;



LET v_codret  = "000";
LET sql_err   = 0;
LET v_cierre = 0;
LET v_tempo = 0;

IF p_accion = " " or p_usuario = " " THEN
   LET v_codret = "110";
   RETURN v_codret;
END IF

SELECT cajeroapertura,cajerocierreest,cajerocierrediario
INTO   v_apertura,v_tempo,v_cierre
FROM   bdapbuild:so_usuariostatus
where  usuarioid = trim(p_usuario);

IF v_apertura IS NULL THEN
   LET v_codret = "006";
   RETURN v_codret;
END IF


 IF v_cierre = 1 AND p_accion = "AD" THEN
    LET v_codret = "004";
    RETURN v_codret;
 END IF
 IF v_apertura = 0  AND p_accion <> "AD" THEN
    LET v_codret = "005";
    RETURN v_codret;
 END IF
        IF p_accion = "AD" THEN
           IF v_apertura = 1 THEN
              LET v_codret = "001";
              RETURN v_codret;
           ELSE
	      UPDATE bdapbuild:so_usuariostatus SET cajeroapertura = 1
	      WHERE usuarioid = trim(p_usuario);
           END IF
        END IF;
	IF p_accion = "CE" THEN
           IF v_tempo = 1 THEN
              LET v_codret = "002";
              RETURN v_codret;
           ELSE
	      UPDATE bdapbuild:so_usuariostatus SET cajerocierreest = 1
	      WHERE usuarioid = trim(p_usuario);
           END IF
        END IF;
	IF p_accion = "AE" THEN
           IF v_tempo = 0 THEN
              LET v_codret = "003";
              RETURN v_codret;
           ELSE
	      UPDATE bdapbuild:so_usuariostatus SET cajerocierreest = 0
	      WHERE usuarioid = trim(p_usuario);
           END IF
        END IF;
	IF p_accion = "CT" THEN
           IF v_cierre = 1 THEN
              LET v_codret = "004";
              RETURN v_codret;
           ELSE
	      UPDATE bdapbuild:so_usuariostatus SET cajerocierrediario = 1
	      WHERE usuarioid = trim(p_usuario);
           END IF
        END IF;
RETURN v_codret;

END PROCEDURE;