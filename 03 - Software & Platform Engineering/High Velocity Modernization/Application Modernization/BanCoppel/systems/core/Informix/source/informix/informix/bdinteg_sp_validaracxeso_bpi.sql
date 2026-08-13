CREATE PROCEDURE "informix".sp_validaracxeso_bpi(pEmpresa char(3), pUsuario char(50), pPass char(50))
   returning char(5);

--Creador: Javier CalderÃ³n Zazueta
--Fecha: 08/12/09
--SolicitÃ³: Mauricio LeÃ³n
--Actividad: Permite validar si la contraseÃ±a del usuario es correcta

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret  = "000";


  Set isolation to dirty read;

 --SET DEBUG FILE TO '/tmp/sp_loginusuario_bpi.out';
 --TRACE ON;


  BEGIN


   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;

        --Set explain file to '/tmp/bancaTiempo.out';
        IF EXISTS (SELECT numcte FROM bdinteg:si_bpiusuarios  WHERE empresa = pEmpresa AND usuario = pUsuario AND pass = pPass ) THEN

                LET cod_ret = '000';  -- Sesion iniciada

        ELSE

                LET cod_ret = '001';  -- Usuario y/o ContraseÃ±a incorrecta

        END IF ;

   RETURN cod_ret;

END

END PROCEDURE ;