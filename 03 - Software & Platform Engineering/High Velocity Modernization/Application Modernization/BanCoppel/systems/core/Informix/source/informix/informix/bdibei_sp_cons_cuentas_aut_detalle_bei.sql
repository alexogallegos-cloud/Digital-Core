CREATE PROCEDURE "informix".sp_cons_cuentas_aut_detalle_bei(pIdMancomunidad Integer,pNumCliente CHAR(9),pNoReg INTEGER,pRegIni INTEGER)
   returning char(5), Integer,CHAR(16),CHAR(2)  ;



    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    DEFINE iTotalReg INTEGER ;

    DEFINE pNum_Cta  CHAR(16);
 	DEFINE pAutoriza BOOLEAN;


    	LET cod_ret  	= "00000";
   		LET pNum_Cta     = "";
 		LET pAutoriza    = "f";
		LET iTotalReg  	= 0;
		
	--****************************************************************************************************
	-- DESCRIPCION: Consulta Datos de Usuario para Presentar en Pantalla
	-- AUTOR : Jesus Ferruzca Luna / SOLSER
	-- FECHA : 25/02/2014
	-- BD: bdibei
	-- SOLICITO : BanCoppel
	-- Liberado a Producción: Mayo 2014
	--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret,iTotalReg,pNum_Cta ,pAutoriza;
      END IF ;
   END EXCEPTION ;



--**************************************************************************************************************
--**************************************************************************************************************

     IF NVL(pIdMancomunidad,-1) == -1 THEN
          LET cod_ret = '00001'; -- No mando Nombre de Usuario Valido
        RETURN cod_ret,iTotalReg,pNum_Cta ,pAutoriza;
      END IF ;
     IF NVL(pNumCliente,'') == '' THEN
          LET cod_ret = '00002'; -- No mando Nombre de Usuario Valido
       RETURN cod_ret,iTotalReg,pNum_Cta ,pAutoriza;
      END IF ;
--**************************************************************************************************************
--**************************************************************************************************************


	SET LOCK MODE TO WAIT 4;


            SELECT COUNT(*)
            INTO iTotalReg
            FROM bdibei:"informix".bei_admin_manco_det_temp  man
            WHERE  man.id_admin_manco  = pIdMancomunidad
            AND man.num_cte=pNumCliente
            And tipo_oper = 1;

     IF iTotalReg == 0 THEN
          LET cod_ret = '003'; -- No ay Registros
            RETURN cod_ret,iTotalReg,pNum_Cta ,pAutoriza;
      END IF ;
--**************************************************************************************************************
--**************************************************************************************************************


      FOREACH
            SELECT SKIP pRegIni FIRST pNoReg  num_cta,autoriza
            INTO pNum_Cta,pAutoriza
            FROM bdibei:"informix".bei_admin_manco_det_temp  man
            WHERE  man.id_admin_manco  = pIdMancomunidad
            AND man.num_cte=pNumCliente
            And tipo_oper = 1

            RETURN cod_ret,iTotalReg,pNum_Cta ,pAutoriza WITH RESUME;
      END FOREACH;

END
END PROCEDURE;