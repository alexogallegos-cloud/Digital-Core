CREATE PROCEDURE "informix".sp_obtenerstatususuario_bpi(pEmpresa char(3), pNumCte char(20), pUsuario char(50))
                      returning char(5),smallint;

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   define cod_ret char(5);
   define sql_err integer;
   define v_id_status smallint ;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let cod_ret       = "000";
   let v_id_status = 0;

BEGIN
   on exception set sql_err
      if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret, v_id_status;
      end if
   end exception;

  IF pNumCte <> "" THEN

        IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios  WHERE empresa = pEmpresa AND numcte = pNumCte ) THEN

             SELECT id_status INTO v_id_status FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND numcte = pNumCte;

             LET cod_ret = '000';

        ELSE

            LET cod_ret = '001';

        END IF ;

  ELSE

        IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios  WHERE empresa = pEmpresa AND usuario = pUsuario ) THEN

             SELECT id_status INTO v_id_status FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND usuario = pUsuario;

             LET cod_ret = '000';

        ELSE

            LET cod_ret = '002';

        END IF ;

  END IF ;

  RETURN cod_ret, v_id_status;

END

END PROCEDURE;