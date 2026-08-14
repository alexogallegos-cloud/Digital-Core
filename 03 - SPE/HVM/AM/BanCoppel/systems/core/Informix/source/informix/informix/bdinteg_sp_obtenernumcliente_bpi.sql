CREATE PROCEDURE "informix".sp_obtenernumcliente_bpi(pEmpresa char(3), pUsuario char(50))
                      returning char(5),char(20);

-------------------------------------------------
-- Realizó: Alfredo Avena
-- Actividad: Desactivar el DROP
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 20/09/2008
-------------------------------------------------


-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   define cod_ret char(5);
   define sql_err integer;
   define v_num_cte char(20) ;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let cod_ret       = "000";
   let v_num_cte = "";

BEGIN
   on exception set sql_err
      if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret, v_num_cte;
      end if
   end exception;

   IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios  WHERE empresa = pEmpresa AND usuario = pUsuario ) THEN

             SELECT numcte INTO v_num_cte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND usuario = pUsuario;

             LET cod_ret = '000';

   ELSE

            LET cod_ret = '001';

   END IF ;

  RETURN cod_ret, v_num_cte;

END

END PROCEDURE ;