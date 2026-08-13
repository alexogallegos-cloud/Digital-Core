CREATE PROCEDURE "informix".sp_consulta_cuentas_oper_bei(pIdUsuario INTEGER,pRegistro Integer)
   returning char(5),CHAR(16);

    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    DEFINE sNumCta CHAR(16);

    LET sNumCta='';
	LET cod_ret='00000';

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, sNumCta;
      END IF ;
   END EXCEPTION ;

      IF NVL(pIdUsuario,-1) == -1 THEN
          LET cod_ret = '00001'; --  Usuario Nulo
          RETURN cod_ret, sNumCta;
      END IF ;

     SET LOCK MODE TO WAIT 4;

         FOREACH

            SELECT  SKIP pRegistro FIRST 10 DISTINCT oper.num_cta
         	INTO sNumCta
            FROM bdibei:"informix".bei_operaciones  oper
            JOIN bdibei:"informix".bei_menu_oper moper ON moper.id_menu_oper=oper.id_menu_oper
            JOIN bdibei:"informix".bei_usuario_perfil usper ON usper.id_perfil=oper.id_perfil
            WHERE  usper.id_usuario=pIdUsuario
            AND moper.id_cat_oper IS NOT NULL
            AND oper.num_cta IS NOT NULL
            AND oper.id_menu_oper <> 2
        
            RETURN cod_ret, sNumCta WITH RESUME;
        
         END FOREACH;

END
END PROCEDURE;