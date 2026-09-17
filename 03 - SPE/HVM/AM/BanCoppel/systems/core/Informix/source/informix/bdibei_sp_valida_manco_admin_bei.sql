CREATE PROCEDURE "informix".sp_valida_manco_admin_bei(pIdUsuario INTEGER,pNumCliente CHAR(9))
   returning char(5), smallint;


    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;

    DEFINE sStatusMan smallint ;

	LET sStatusMan=0;
	LET cod_ret='00000';
--****************************************************************************************************
-- DESCRIPCION:  Valida la Mancomunidad de Usuarios Administradores
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, sStatusMan;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE USUARIOS
--**************************************************************************************************************

     SET LOCK MODE TO WAIT 4;

            SELECT serv.status_manco
         	INTO sStatusMan
            FROM "informix".bei_servicio  serv
            WHERE  serv.id_usuario=pIdUsuario
            AND serv.num_cliente=pNumCliente;


          IF NVL(sStatusMan,99) == 99 THEN
          	LET cod_ret='00002';
          	RETURN cod_ret,sStatusMan ;
     	  END IF ;

          RETURN cod_ret,sStatusMan ;


END
END PROCEDURE;