CREATE PROCEDURE "informix".sp_consulta_claves_envio(pNumControl CHAR(12))
   returning char(5), char(26), char(26),char(26),char(26),decimal(16,2),char(12);


    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    DEFINE priNomBen char(26);
    DEFINE segNomBen  char(26);
    DEFINE apellPatBen char(26);
    DEFINE apellMatBen char(26);
    DEFINE importeTotal decimal(16,2);
    DEFINE numControl char(12);

    LET cod_ret     ="00000";
    LET priNomBen   ="";
    LET segNomBen      ="";
    LET apellPatBen    ="";
    LET apellMatBen     ="";
    LET importeTotal     =0.0;
    LET numControl     ="";
       

--****************************************************************************************************
-- DESCRIPCION: Consulta direccion y telefono de la empresa
-- AUTOR : Jesus Ferruzca Luan
-- FECHA : 23/02/2015
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
             RETURN cod_ret, priNomBen,segNomBen, apellPatBen, apellMatBen, importeTotal,numControl;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA Existencia de Nombre de Usuario
--**************************************************************************************************************

     IF NVL(pNumControl,'') == '' THEN
          LET cod_ret = '00001'; -- No mando Num de Cliente
          RETURN cod_ret, priNomBen,segNomBen, apellPatBen, apellMatBen, importeTotal,numControl;
     END IF ;

    SELECT TRIM(en.pri_nom_ben),TRIM(en.seg_nom_ben),
           TRIM(en.apell_pat_ben),TRIM(en.apell_mat_ben),
            en.importe_envio,en.no_control
            INTO
            priNomBen,segNomBen,apellPatBen,apellMatBen,importeTotal,numControl
    FROM bdisac:sac_enviosdineroya en
    WHERE en.no_control=pNumControl; 

  RETURN cod_ret, priNomBen,segNomBen, apellPatBen, apellMatBen, importeTotal,numControl;

END
END PROCEDURE;