CREATE PROCEDURE "informix".sp_obt_numcte_status(pEmpresa char(3), pIdUsuario char(20), pUsuario char(50))
                      returning char(5),char(20),smallint;

-- Realizó: Javier Chavez
-- Actividad: Obtener el número y estatus del cliente
-- Solicitó: Mauricio León
-- Fecha:  23/10/2008

--Modificó: Edgar M. Alarcon
--Actividad: valida si recibe id de usuario o numero de cliente
--Solicito: Jose de Jesus
--Fecha: 05-11-15
					
					  
-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   define cod_ret char(5);
   define sql_err integer;
   define v_id_status smallint ;
   define v_num_cte char (20);
   define pNumCte char (20);
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let cod_ret       = "000";
   let v_id_status = 0;
   let v_num_cte = "";
   
	--SET DEBUG FILE TO "/home/informix/bibiana/sp_obt_numcte_status.out";
	--TRACE ON;

BEGIN
   on exception set sql_err
      if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret, v_num_cte, v_id_status;
      end if
   end exception;

  IF pIdUsuario <> '' THEN
  
		SELECT numcliente INTO pNumCte FROM bdibpi:"informix".bpi_usuario WHERE id_usuario = pIdUsuario AND st_portal = 'activo'; -- ID_usuario
		
		IF pNumCte = '' OR pNumCte IS NULL THEN
			LET pNumCte = "";
			LET pNumCte = pIdUsuario;
		END IF

        IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_bpiusuarios  WHERE empresa = pEmpresa AND numcte = pNumCte ) THEN

             SELECT numcte,id_status INTO v_num_cte, v_id_status FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND numcte = pNumCte;
			 LET v_num_cte = pNumCte;
             LET cod_ret = '000';

        ELSE

            LET cod_ret = '001';

        END IF ;

  ELSE

        IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_bpiusuarios  WHERE empresa = pEmpresa AND usuario = pUsuario ) THEN

             SELECT numcte,id_status INTO v_num_cte,v_id_status FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND usuario = pUsuario;

             LET cod_ret = '000';

        ELSE

            LET cod_ret = '002';

        END IF ;

  END IF ;
  
  RETURN cod_ret, v_num_cte, v_id_status;

END

END PROCEDURE ;