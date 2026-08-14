CREATE PROCEDURE "informix".sp_synmotor_insert_mc_estadistica
(vOPCODE CHAR(5))RETURNING CHAR(5) As CodRet, INTEGER AS Grupo;

/**************************************************************************/
/* Fecha: 02/Abril/2018                                                   */
/* SPL: "informix".sp_synmotor_insert_mc_estadistica()                    */
/* Actividad:                                                             */
/* Realizado por: Francisco Javier Benito Santiago(fbenito@syndein.com.mx)*/
/* @Copyright 2018 Syndein, S.A. de C.V. All rights reserved.             */
/* SYNDEIN PROPIETARY/CONFIDENTIAL.                                       */
/* Use is subject to license terms                                        */
/**************************************************************************/

 DEFINE vCodRet  CHAR(5);
 DEFINE sql_err INTEGER;
 DEFINE vGrupo INTEGER;
 DEFINE vCantidad INTEGER;

 LET vCodRet = "000";
 LET vGrupo =  1; 
 LET vCantidad =  0; 
    
 BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
        LET vCodRet = sql_err;
        RETURN  vCodRet, vGrupo;
     END IF;
   END EXCEPTION;
   
   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   SELECT grupo INTO vGrupo FROM mc_codigoretorno  WHERE codigo= vOPCODE;
   
   IF vGrupo != 1 THEN
      SELECT COUNT(cantidad) INTO vCantidad FROM mc_estadistica WHERE grupo= vGrupo AND fecha::date = today;
      
      IF vCantidad != 0 THEN
          /*SET LOCK MODE TO WAIT 1;*/
          UPDATE mc_estadistica SET cantidad = cantidad + 1 WHERE grupo = vGrupo AND fecha::date = today; 
          /*UPDATE mc_estadistica SET cantidad = vNumInst  WHERE grupo = 7 AND fecha::date = today;*/	
      ELSE 
         /*SET LOCK MODE TO WAIT 1;*/
         INSERT INTO mc_estadistica (grupo, cantidad, fecha) VALUES (vGrupo,1, current);
         /*UPDATE mc_estadistica SET cantidad = cantidad + 1 WHERE grupo = vGrupo AND fecha::date = today;*/ 
         /*UPDATE mc_estadistica SET cantidad = vNumInst  WHERE grupo = 7 AND fecha::date = today;*/	
      END IF;
   END IF; 
   
  RETURN  vCodRet, vGrupo;
  
  END;
END PROCEDURE;