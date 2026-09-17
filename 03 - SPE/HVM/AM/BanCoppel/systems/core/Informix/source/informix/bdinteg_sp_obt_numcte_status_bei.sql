CREATE PROCEDURE "informix".sp_obt_numcte_status_bei(pEmpresa CHAR(3), pNumCte CHAR(20), pUsuario CHAR(50))
                      RETURNING CHAR(5), CHAR(20), SMALLINT, INTEGER;

   DEFINE cCod_ret CHAR(5);
   DEFINE sql_err INTEGER;
   DEFINE sId_status SMALLINT;
   DEFINE iId_status_token INTEGER;
   DEFINE cNum_cte CHAR (20);

   LET cCod_ret       = "000";
   LET sId_status = 0;
   LET iId_status_token = 0;
   LET cNum_cte = "";

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret, cNum_cte, sId_status, iId_status_token;
      END IF
   END EXCEPTION;

  IF pNumCte <> '' THEN

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;
  
        IF EXISTS ( SELECT num_cliente FROM bdinteg:"informix".si_bpiusuariospm  WHERE empresa = pEmpresa AND num_cliente = pNumCte ) THEN

             SELECT a.num_cliente, a.id_status, b.id_status_token 
			 INTO cNum_cte, sId_status, iId_status_token 
			 FROM bdinteg:"informix".si_bpiusuariospm a, bdinteg:"informix".si_bpitokenpm b 
			 WHERE a.empresa = pEmpresa 
			 AND a.num_cliente = pNumCte
			 AND a.num_cliente =  b.num_cliente;
			 
			 LET cNum_cte = pNumCte;
             LET cCod_ret = '000';

        ELSE

            LET cCod_ret = '001';

        END IF ;

  ELSE

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;
  
        IF EXISTS ( SELECT num_cliente FROM bdinteg:"informix".si_bpiusuariospm  WHERE empresa = pEmpresa AND usuario = pUsuario ) THEN

             SELECT num_cliente,id_status 
			 INTO cNum_cte, sId_status 
			 FROM bdinteg:"informix".si_bpiusuariospm 
			 WHERE empresa = pEmpresa 
			 AND usuario = pUsuario;
			 
			 SELECT id_status_token 
			 INTO iId_status_token 
			 FROM bdinteg:"informix".si_bpitokenpm 
			 WHERE empresa = pEmpresa
			 AND num_cliente = cNum_cte;

             LET cCod_ret = '000';

        ELSE

            LET cCod_ret = '002';

        END IF ;

  END IF ;
  
  RETURN cCod_ret, cNum_cte, sId_status, iId_status_token;

END

END PROCEDURE;