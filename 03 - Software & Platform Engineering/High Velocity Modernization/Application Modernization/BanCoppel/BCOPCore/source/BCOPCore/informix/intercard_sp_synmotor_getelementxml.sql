CREATE PROCEDURE "informix".sp_synmotor_getelementxml
( sOperacion CHAR(5), sTipo CHAR(2))

RETURNING CHAR(5), INTEGER;

/**************************************************************************/
/* Fecha: 02/Abril/2018                                                   */
/* SPL: "informix".sp_synmotor_getElementXML                              */
/* Actividad:                                                             */
/* Realizado por: Francisco Javier Benito Santiago(fbenito@syndein.com.mx)*/
/* @Copyright 2018 Syndein, S.A. de C.V. All rights reserved.             */
/* SYNDEIN PROPIETARY/CONFIDENTIAL.                                       */
/* Use is subject to license terms                                        */
/**************************************************************************/

DEFINE vCodRet  CHAR(5);
DEFINE sql_err  INTEGER;
DEFINE iLenTrama INTEGER;
DEFINE vOperacion CHAR(5);
DEFINE vTipo CHAR(2);

LET vCodRet = "000";
LET iLenTrama = 0;
LET vOperacion = sOperacion;
LET vTipo = sTipo;

BEGIN
  /* Procedure body */
  
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET vCodRet = sql_err;
        
           RETURN  vCodRet, iLenTrama;
      END IF;
  END EXCEPTION;
  
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

  SELECT NVL(SUM(MCIAC.tamano),-1)  
  INTO iLenTrama
  FROM mc_iac_transaccion AS MCIT, mc_iac_trans_campos as MCIAC 
  WHERE MCIT.tran_iac = vOperacion  AND MCIAC.id_tran = MCIT.id_tran 
  AND MCIAC.tipo = vTipo  AND MCIAC.estatus = 'A';
  
  RETURN  vCodRet, iLenTrama;
  
END;
END PROCEDURE;