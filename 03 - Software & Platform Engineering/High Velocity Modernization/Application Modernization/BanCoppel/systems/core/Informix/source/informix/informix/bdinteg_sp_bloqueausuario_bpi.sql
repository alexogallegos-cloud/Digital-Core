CREATE PROCEDURE "informix".sp_bloqueausuario_bpi(pEmpresa char(3), pUsuario char(50))
   returning char(5);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE cod_ret char(5);
   DEFINE sql_err integer;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret       = "000";


BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;


   IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND usuario = pUsuario ) THEN

        UPDATE bdinteg:si_bpiusuarios SET id_status = 40, f_status = current  WHERE usuario = pUsuario;

        LET cod_ret = '000';  -- Usuario bloqueado

   ELSE

        LET cod_ret = '001';  -- No existe el usuario

   END IF ;

   RETURN cod_ret;

END

END PROCEDURE ;