CREATE PROCEDURE "informix".sp_synmotor_getcantidadcampos
(vOperacion CHAR(5))
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

  SELECT Count(*) As Cantidad
  INTO vCantidad
  FROM mc_iac_transaccion AS MCIT, mc_iac_trans_campos AS MITC,mc_operaciones AS MCO,mc_parametros AS MCP 
  WHERE MCIT.tran_iac = vOperacion  AND MCO.id_tran = MCIT.id_tran AND MITC.id_tran = MCIT.id_tran AND MCP.id_campo = MITC.id_campo ;
  
  RETURN vCodRet, vCantidad;

END;
END PROCEDURE;