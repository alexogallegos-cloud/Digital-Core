CREATE PROCEDURE "informix".sps_verificauser_exist_bei(pUserNom CHAR(50))
   returning char(5), smallint;


    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;

    DEFINE sExiste smallint ;
    DEFINE sExisteManco smallint ;
    DEFINE sTotal smallint ;
    LET sExiste=0;
    LET sExisteManco=0;
    LET cod_ret  = "00000";

--****************************************************************************************************
-- DESCRIPCION: Verifica si Nombre de Usuario ya Existe en la base de Datos
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, sExiste;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA Existencia de Nombre de Usuario
--**************************************************************************************************************

     IF NVL(pUserNom,'') == '' THEN
          LET cod_ret = '00002'; -- No mando Nombre de Usuario Valido
          RETURN cod_ret, sExiste;
      END IF ;

            

--Verifica Tabla de Usuarios De mancomunidad, en Alta y en Modificacion
            SELECT COUNT(*) 
            INTO sExisteManco
            FROM bdibei:"informix".bei_admin_manco_temp usu
            WHERE usu.tipo_oper=1 AND usu.tipo_mov IN( 1,3) AND usu.usuario_bei= pUserNom;



            LET sTotal=NVL(sExisteManco,0);

  	RETURN cod_ret, sTotal;

END
END PROCEDURE;