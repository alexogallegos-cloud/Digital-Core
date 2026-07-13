CREATE PROCEDURE "informix".sp_guarda_oper_bei( pIdPerfil INTEGER,
												pIdOper INTEGER,
												pNumCta CHAR(16),
												pMontoMin DECIMAL(16,2),
												pMontoMax DECIMAL(16,2),
												pMancomunado CHAR(1),
												pCreatedBy INTEGER
												 )
   returning char(5),INTEGER;


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;
 	DEFINE sIdOper INTEGER;


    LET sIdOper  = 0;
	LET cod_ret = '000000';

--****************************************************************************************************
-- DESCRIPCION:  Guarda OPERACIONES de Mancomunidad por Cuenta
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret,sIdOper;
      END IF ;
   END EXCEPTION ;


SET LOCK MODE TO WAIT 4;

			INSERT INTO "informix".bei_operaciones
			(id_oper,id_menu_oper,id_perfil,num_cta,monto_min,monto_max,mancomunado,createdby,createdon,updatedby,updatedon) VALUES
			(sIdOper, pIdOper,pIdPerfil,pNumCta,pMontoMin, pMontoMax,pMancomunado,pCreatedBy,CURRENT YEAR TO DAY,pCreatedBy,CURRENT YEAR TO DAY);

			LET sIdOper = DBINFO('sqlca.sqlerrd1');

  RETURN cod_ret,sIdOper;


END
END PROCEDURE;