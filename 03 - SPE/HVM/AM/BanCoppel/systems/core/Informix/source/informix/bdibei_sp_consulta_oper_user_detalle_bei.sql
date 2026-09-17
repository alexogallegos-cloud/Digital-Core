CREATE PROCEDURE "informix".sp_consulta_oper_user_detalle_bei(pIdMancomunidad INTEGER,pNoReg INTEGER,pRegIni INTEGER)
 RETURNING CHAR(5), INTEGER, INTEGER, CHAR(50), DECIMAL(16,2), DECIMAL(16,2),CHAR(5);


    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER;

    DEFINE iTotalReg INTEGER;

    DEFINE sIdOper        				INTEGER;
    DEFINE sIdMenuOper                  INTEGER;
    DEFINE sNumCta      				CHAR(20);
    DEFINE sMontoMin         			DECIMAL(16,2);
    DEFINE sMontoMax         			DECIMAL(16,2);
    DEFINE sMancomunado     			CHAR(5);

    LET  sIdMenuOper        = 0;
    LET  sNumCta      		= "";
    LET  sMontoMin         	= 0.0;
    LET  sMontoMax         	= 0.0;
    LET  sMancomunado     	= "f";
    LET iTotalReg           = 0;
    LET cod_ret             = "000";


--****************************************************************************************************
-- DESCRIPCION:  Consulta Operaciones de usuario Para Mostrar Detalle de Usuario
-- AUTOR : Jesús Ferruzca Luna / SOLSER
-- FECHA : 24/02/2014
-- BD: bdibei
-- SOLICITO : BanCoppel
-- LIBERADO : Mayo 2014
--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
             --RETURN cod_ret, iTotalReg,sIdMenuOper,sNumCta,sMontoMin,sMontoMax,sMancomunado;
             RETURN cod_ret, iTotalReg, sIdMenuOper, sNumCta, sMontoMin, sMontoMax,sMancomunado;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--**************************************************************************************************************

	   IF NVL(pIdMancomunidad,-1) == -1 THEN
          LET cod_ret = '00001'; 
          RETURN cod_ret, iTotalReg, sIdMenuOper, sNumCta, sMontoMin, sMontoMax,sMancomunado;

      END IF ;

      IF NVL(pNoReg,-1) == -1 THEN
          LET cod_ret = '00002'; 
           RETURN cod_ret, iTotalReg, sIdMenuOper, sNumCta, sMontoMin, sMontoMax,sMancomunado;
      END IF ;

         IF NVL(pRegIni,-1) == -1 THEN
           LET cod_ret = '00003'; 
           RETURN cod_ret, iTotalReg, sIdMenuOper, sNumCta, sMontoMin, sMontoMax,sMancomunado;
      END IF ;


	SET LOCK MODE TO WAIT 4;


        SELECT COUNT(*)
        INTO iTotalReg
        From bdibei:"informix".bei_admin_manco_det_temp
		Where id_admin_manco = pIdMancomunidad
        And   tipo_oper = 2;

    IF iTotalReg == 0 THEN
        LET cod_ret = '00004'; -- No ay Registros
        RETURN cod_ret, iTotalReg, sIdMenuOper, sNumCta, sMontoMin, sMontoMax,sMancomunado;
    END IF ;

--**************************************************************************************************************
--**************************************************************************************************************


    FOREACH
        SELECT SKIP pRegIni FIRST pNoReg id_menu_oper ,num_cta  ,monto_min ,monto_max, CASE WHEN mancomunado THEN 't' ELSE 'f' END
        INTO sIdMenuOper, sNumCta, sMontoMin, sMontoMax, sMancomunado
        From bdibei:"informix".bei_admin_manco_det_temp
        Where id_admin_manco = pIdMancomunidad
        And tipo_oper = 2


        RETURN cod_ret, iTotalReg, sIdMenuOper, sNumCta, sMontoMin, sMontoMax,sMancomunado WITH RESUME;
    END FOREACH;

END
END PROCEDURE;