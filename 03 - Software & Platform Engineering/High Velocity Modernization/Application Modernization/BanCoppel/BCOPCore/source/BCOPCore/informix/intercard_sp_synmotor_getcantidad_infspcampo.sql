CREATE PROCEDURE "informix".sp_synmotor_getcantidad_infspcampo
(vId_SP INTEGER)
  RETURNING CHAR(5) As CodRet, INTEGER AS Cantidad;

/**************************************************************************/
/* Fecha: 02/Abril/2018                                                   */
/* SPL: "informix".sp_synmotor_getcantidad                                */
/* Actividad:                                                             */
/* Realizado por: Francisco Javier Benito Santiago(fbenito@syndein.com.mx)*/
/* @Copyright 2018 Syndein, S.A. de C.V. All rights reserved.             */
/* SYNDEIN PROPIETARY/CONFIDENTIAL.                                       */
/* Use is subject to license terms                                        */
/**************************************************************************/

DEFINE vCodRet  CHAR(5);
DEFINE sql_err INTEGER;
DEFINE vCantidad INTEGER;

LET vCodRet= '000'; 
LET vCantidad = 0;

BEGIN
  /* Procedure body */
   ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
        LET vCodRet = sql_err;
        RETURN  vCodRet, vCantidad;
     END IF;
  END EXCEPTION;
 
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

  SELECT COUNT(*) AS Cantidad 
  INTO vCantidad
  FROM mc_sp_central MS, mc_sp_central_campos MSC 
  WHERE MS.id_sp=vId_SP AND MSC.id_sp=MS.id_sp;
  
  RETURN vCodRet, vCantidad;

END;
END PROCEDURE;