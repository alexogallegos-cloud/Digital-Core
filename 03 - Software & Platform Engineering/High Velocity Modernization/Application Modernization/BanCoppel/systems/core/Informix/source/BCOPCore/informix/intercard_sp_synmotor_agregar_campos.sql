CREATE PROCEDURE "informix".sp_synmotor_agregar_campos
(vRegistro INTEGER, vOperacion CHAR(5))

RETURNING CHAR(5) AS CodRet, INTEGER AS IDCampo, CHAR(100) AS Campo, INTEGER AS Orden, CHAR(2) As Tipo, CHAR(30) AS Descripcion,  INTEGER AS Tamano,   CHAR(1) AS Status, CHAR(5) AS Tran_IAC,  CHAR(30) AS DescTran_IAC,  CHAR(1) AS Status_MCIT,  CHAR(100) AS Etiqueta;
  
 /**************************************************************************/
/* Fecha: 02/Abril/2018                                                   */
/* SPL: "informix".sp_synmotor_agregar_campos                             */
/* Actividad:                                                             */
/* Realizado por: Francisco Javier Benito Santiago(fbenito@syndein.com.mx)*/
/* @Copyright 2018 Syndein, S.A. de C.V. All rights reserved.             */
/* SYNDEIN PROPIETARY/CONFIDENTIAL.                                       */
/* Use is subject to license terms                                        */
/**************************************************************************/


 DEFINE vCodRet  CHAR(5);
 DEFINE sql_err INTEGER;
 DEFINE vID_Campo       INTEGER;
 DEFINE vCampo          CHAR(100);
 DEFINE vOrden          INTEGER;
 DEFINE vTipo           CHAR(2);
 DEFINE vDescripcion    CHAR(30);
 DEFINE vTamano         INTEGER;  
 DEFINE vEstatus        CHAR(1);
 DEFINE vTran_iac       CHAR(5); 
 DEFINE vDesc_tran_iac  CHAR(30);
 DEFINE vEstatus_MCIT   CHAR(1);
 DEFINE vEtiqueta_MCP   CHAR(100);
 
 
 LET vCodRet= '000';
 LET vID_Campo       = 0;
 LET vCampo          = ' ';
 LET vOrden          = 0;
 LET vTipo           = ' ';
 LET vDescripcion    = ' ';
 LET vTamano         = 0;  
 LET vEstatus        = ' ';
 LET vTran_iac       = ' '; 
 LET vDesc_tran_iac  = ' ';
 LET vEstatus_MCIT   = ' ';
 LET vEtiqueta_MCP   = ' ';
 

BEGIN
  /* Procedure body */
   ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
        LET vCodRet = sql_err;
        RETURN  vCodRet, vID_Campo, vCampo, vOrden, vTipo, vDescripcion, vTamano, vEstatus, vTran_iac, vDesc_tran_iac, vEstatus_MCIT,  vEtiqueta_MCP;
     END IF;
  END EXCEPTION;
  
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

  FOREACH
     SELECT SKIP vRegistro FIRST 30 MITC.id_campo, MITC.campo, MITC.orden, MITC.tipo, MITC.descripcion, MITC.tamano, MCO.estatus as estatusOper,
     MCIT.tran_iac, MCIT.desc_tran_iac, MCIT.estatus AS estatusTran, MCP.etiqueta 
     INTO vID_Campo, vCampo, vOrden, vTipo, vDescripcion, vTamano, vEstatus, vTran_iac, vDesc_tran_iac, vEstatus_MCIT,  vEtiqueta_MCP
     FROM mc_iac_transaccion AS MCIT, mc_iac_trans_campos AS MITC,mc_operaciones AS MCO,mc_parametros AS MCP 
     WHERE MCIT.tran_iac = vOperacion AND MCO.id_tran = MCIT.id_tran AND MITC.id_tran = MCIT.id_tran AND MCP.id_campo = MITC.id_campo 
     ORDER BY MITC.tipo, MITC.orden ASC
     
      RETURN vCodRet,vID_Campo, vCampo, vOrden, vTipo, vDescripcion, vTamano, vEstatus, vTran_iac, vDesc_tran_iac, vEstatus_MCIT,  vEtiqueta_MCP WITH RESUME;
  END FOREACH;
  
END;
END PROCEDURE;