CREATE PROCEDURE "informix".sp_synmotor_existeoperacion
(vOperacion CHAR(5))
RETURNING CHAR(5) As CodRet, CHAR(1) As bExisteTran;

  /* Procedure body */
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
DEFINE vExisteTran CHAR(1);
DEFINE sql_err INTEGER;

LET vCodRet = "000";
LET vExisteTran= "F";

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
        LET vCodRet = sql_err;
        RETURN  vCodRet, vExisteTran;
     END IF;
   END EXCEPTION;
 
   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   IF EXISTS (SELECT tran_iac FROM mc_iac_transaccion WHERE tran_iac= vOperacion) THEN
     LET vExisteTran= "V"; 
   ELSE
     LET vExisteTran= "F";
   END IF;
   
   RETURN  vCodRet, vExisteTran;
END;
END PROCEDURE;