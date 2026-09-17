CREATE PROCEDURE "informix".sp_synmotor_geturlws
( vTranIAC  CHAR(5))

RETURNING CHAR(5) AS CodRet,VARCHAR(255) AS Url, CHAR(100) AS NombreOper ,VARCHAR(255) AS KeyStoreFileName, VARCHAR(255) AS KeySotorePassword, 
VARCHAR(255) AS TrustStoreFileName ,VARCHAR(255) AS TrustStorePassword, VARCHAR(20) AS IP_InterAct, VARCHAR(8) AS Port_InterAct, INTEGER AS ID_SP;

/**************************************************************************/
/* Fecha: 02/Abril/2018                                                   */
/* SPL: "informix".sp_synmotor_geturlws                                   */
/* Actividad:                                                             */
/* Realizado por: Francisco Javier Benito Santiago(fbenito@syndein.com.mx)*/
/* @Copyright 2018 Syndein, S.A. de C.V. All rights reserved.             */
/* SYNDEIN PROPIETARY/CONFIDENTIAL.                                       */
/* Use is subject to license terms                                        */
/**************************************************************************/

DEFINE vCodRet  CHAR(5);
DEFINE sql_err  INTEGER;
DEFINE vUrlLink LVARCHAR(255);
DEFINE vNombreOper CHAR(100);
DEFINE vKeystoreFilename VARCHAR(255);
DEFINE vKeystorePassword VARCHAR(255);
DEFINE vTruststoreFilename VARCHAR(255);
DEFINE vTruststorePassword VARCHAR(255);
DEFINE vIpInteract VARCHAR(20);
DEFINE vPortInteract  VARCHAR(8);
DEFINE vIdSP INTEGER;
DEFINE vTran_IAC CHAR(5);


LET vCodRet = "000";
LET vUrlLink = "                                                                                                                                                                                                                                                               ";
LET vNombreOper = " ";
LET vKeystoreFilename = "                                                                                                                                                                                                                                                               ";
LET vKeystorePassword = "                                                                                                                                                                                                                                                               ";
LET vTruststoreFilename = "                                                                                                                                                                                                                                                               ";
LET vTruststorePassword = "                                                                                                                                                                                                                                                               ";
LET vIpInteract = "        ";
LET vPortInteract= "                    ";
LET vIdSP = 0;
LET vTran_IAC = vTranIAC;

BEGIN
  /* Procedure body */
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET vCodRet = sql_err;
        
           RETURN  vCodRet, vUrlLink, vNombreOper, vKeystoreFilename, vKeystorePassword, 
                   vTruststoreFilename, vTruststorePassword, vIpInteract, 
                   vPortInteract, vIdSP;
      END IF;
  END EXCEPTION;

  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

  SELECT MCWS.url_link, MCO.nombreoper, 
  NVL(keystorefilename,"  "), 
  NVL(keystorepassword,"  "),
  NVL(truststorefilename,"  "), 
  NVL(truststorepassword,"  "), 
  NVL(ipinteract, "  "), 
  NVL(portinteract, "  "), id_sp 
  INTO vUrlLink, vNombreOper, vKeystoreFilename, vKeystorePassword,  vTruststoreFilename, vTruststorePassword, vIpInteract, vPortInteract, vIdSP
  FROM mc_iac_transaccion AS MCIT, mc_operaciones AS MCO, mc_web_service AS MCWS
  WHERE MCIT.tran_iac = vTran_IAC AND MCO.id_tran = MCIT.id_tran AND MCWS.id_ws = MCO.id_ws;

  RETURN vCodRet, vUrlLink, vNombreOper, vKeystoreFilename, vKeystorePassword, 
         vTruststoreFilename, vTruststorePassword, vIpInteract, vPortInteract, vIdSP;
         
END;
END PROCEDURE;