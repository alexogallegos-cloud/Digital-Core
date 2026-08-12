CREATE PROCEDURE "informix".sp_synmotor_gettrandummy
( sOperacion CHAR(5))

RETURNING CHAR(5) As CodRet, CHAR(1) As OperDummy;

/**************************************************************************/
/* Fecha: 02/Abril/2018                                                   */
/* SPL: "informix".sp_synmotor_gettrandummy                               */
/* Actividad:                                                             */
/* Realizado por: Francisco Javier Benito Santiago(fbenito@syndein.com.mx)*/
/* @Copyright 2018 Syndein, S.A. de C.V. All rights reserved.             */
/* SYNDEIN PROPIETARY/CONFIDENTIAL.                                       */
/* Use is subject to license terms                                        */
/**************************************************************************/

DEFINE vCodRet  CHAR(5);
DEFINE sql_err  INTEGER;
DEFINE vOperDummy CHAR(1);

DEFINE vOperacion CHAR(5); 
  
LET vCodRet = "000";
LET vOperDummy = " "; 

LET vOperacion = sOperacion;

BEGIN
  /* Procedure body */
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET vCodRet = sql_err;
           RETURN  vCodRet, vOperDummy;
      END IF;
  END EXCEPTION;

  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

  SELECT MCO.oper_dummy 
  INTO vOperDummy
  FROM mc_iac_transaccion AS MCIT, mc_operaciones AS MCO, mc_web_service AS MCWS 
  WHERE MCIT.tran_iac = vOperacion AND MCO.id_tran = MCIT.id_tran AND MCWS.id_ws = MCO.id_ws;	       

  RETURN  vCodRet, vOperDummy;
END;
END PROCEDURE;