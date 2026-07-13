CREATE PROCEDURE "informix".sp_synmotor_getcantidadparametros
(vOperacion CHAR(5))
RETURNING CHAR(5) AS CodRet, INTEGER AS Cantidad;

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

  SELECT Count(*) As Cantidad
  INTO vCantidad 
  FROM mc_web_service ws INNER JOIN mc_operaciones op ON ws.id_ws=op.id_ws INNER JOIN mc_parametros pa
  ON pa.id_oper=op.id_oper LEFT JOIN mc_sp_central_campos spc ON spc.id_sp_campo=pa.id_sp_campo
  LEFT JOIN mc_iac_trans_campos cia ON cia.id_campo=pa.id_campo 
  INNER JOIN mc_iac_transaccion tia ON tia.id_tran = op.id_tran
  WHERE tia.tran_iac = vOperacion;
  
  RETURN vCodRet, vCantidad;
 
END;
END PROCEDURE;