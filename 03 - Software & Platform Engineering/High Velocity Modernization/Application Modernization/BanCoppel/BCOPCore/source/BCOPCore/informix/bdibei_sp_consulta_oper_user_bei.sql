CREATE PROCEDURE "informix".sp_consulta_oper_user_bei(pIdPerfil INTEGER,pNoReg INTEGER,pRegIni INTEGER)
 returning char(5), INTEGER,INTEGER,INTEGER,CHAR(50),DECIMAL(16,2),DECIMAL(16,2),CHAR(5);


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;

    DEFINE iTotalReg INTEGER ;

    DEFINE sIdOper        				INTEGER;
    DEFINE sIdMenuOper             		INTEGER;
    DEFINE sNumCta      				CHAR(20);
    DEFINE sMontoMin         			DECIMAL(16,2);
    DEFINE sMontoMax         			DECIMAL(16,2);
    DEFINE sMancomunado     			BOOLEAN;


    LET  sIdOper        	=0;
    LET  sIdMenuOper        =0;
    LET  sNumCta      		= "";
    LET  sMontoMin         	=0.0;
    LET  sMontoMax         	=0.0;
    LET  sMancomunado     	= "f";
    LET iTotalReg=0;
    LET cod_ret  = "000";


--****************************************************************************************************
-- DESCRIPCION:  Consulta Operaciones de usuario Para Modificacion de Usuario
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
             RETURN cod_ret, iTotalReg,sIdOper,sIdMenuOper,sNumCta,sMontoMin,sMontoMax,sMancomunado;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--**************************************************************************************************************

	   IF NVL(pIdPerfil,-1) == -1 THEN
          LET cod_ret = '00001'; -- No mando Nombre de Usuario Valido
          RETURN cod_ret, iTotalReg,sIdOper,sIdMenuOper,sNumCta,sMontoMin,sMontoMax,sMancomunado;

      END IF ;

      IF NVL(pNoReg,-1) == -1 THEN
          LET cod_ret = '00002'; -- No mando Nombre de Usuario Valido
           RETURN cod_ret, iTotalReg,sIdOper,sIdMenuOper,sNumCta,sMontoMin,sMontoMax,sMancomunado;
      END IF ;

         IF NVL(pRegIni,-1) == -1 THEN
           LET cod_ret = '00003'; -- No mando Nombre de Usuario Valido
           RETURN cod_ret, iTotalReg,sIdOper,sIdMenuOper,sNumCta,sMontoMin,sMontoMax,sMancomunado;
      END IF ;


	SET LOCK MODE TO WAIT 4;


            SELECT COUNT(*)
            INTO iTotalReg
            FROM "informix".bei_operaciones  oper
            WHERE  oper.id_perfil  = pIdPerfil;

     IF iTotalReg == 0 THEN
          LET cod_ret = '00004'; -- No Hay Registros
           RETURN cod_ret, iTotalReg,sIdOper,sIdMenuOper,sNumCta,sMontoMin,sMontoMax,sMancomunado;
      END IF ;

--**************************************************************************************************************
--**************************************************************************************************************


          FOREACH
            SELECT   SKIP pRegIni FIRST pNoReg id_oper,id_menu_oper ,num_cta  ,monto_min ,monto_max  ,mancomunado
            INTO sIdOper,sIdMenuOper,sNumCta,sMontoMin,sMontoMax,sMancomunado
            FROM "informix".bei_operaciones  oper
            WHERE  oper.id_perfil  = pIdPerfil


            RETURN cod_ret, iTotalReg,sIdOper,sIdMenuOper,sNumCta,sMontoMin,sMontoMax,sMancomunado WITH RESUME;
          END FOREACH;


END
END PROCEDURE;