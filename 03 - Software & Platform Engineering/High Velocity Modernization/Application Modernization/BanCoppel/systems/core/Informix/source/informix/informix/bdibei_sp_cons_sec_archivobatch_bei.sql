CREATE PROCEDURE "informix".sp_cons_sec_archivobatch_bei(pCodEmpresa VARCHAR(3), pRegistro integer)
returning CHAR(5),  char(17);

--****************************************************************************************************
-- DESCRIPCION:  Se consulta los archivos para recuperar la secuencia
-- AUTOR : SOLSER 
-- FECHA : 10/MARZO/2016
-- BD: bdibei
-- SOLICITO : BanCoppel
-- FECHA DE LIBERACIÃN: 
--***************************************************************************************************


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;
    DEFINE pNombre char(17);

    LET cod_ret  = "00000";
    LET pNombre='';

	
	 
 BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
             RETURN cod_ret, NVL(pNombre,'');
      END IF ;
   END EXCEPTION ;


	IF NVL(pCodEmpresa,0) == 0 THEN
	 	LET cod_ret = '001'; 
        RETURN cod_ret, NVL(pNombre,'');
	END IF;

    SET LOCK MODE TO WAIT 4;
  
    FOREACH
      Select  skip pRegistro first 10  nom_tem_archivo
        Into  pNombre
        From  bei_archivos_eval
       Where  codigo_empresa = pCodEmpresa
         And  TO_CHAR(fecha_alta, '%d/%m/%Y')=TO_CHAR(today, '%d/%m/%Y')
    Order by  nom_tem_archivo asc

      RETURN cod_ret, NVL(pNombre,'') WITH RESUME;
    END FOREACH;

END
END PROCEDURE;