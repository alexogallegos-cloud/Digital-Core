CREATE PROCEDURE "informix".sp_synmotor_geturlwsdl(vRegistro INTEGER)
/*</20180813.svrMCWS.01.00.0012b.01.FB>*/
/*</20180626.svrMCWS.01.00.0012b.FB>*/

/*<20180626.svrMCWS.01.00.0012b.FB>*/
--RETURNING CHAR(5) AS CodRet,VARCHAR(255) AS Url, CHAR(100) AS NombreOper ,VARCHAR(255) AS KeyStoreFileName, VARCHAR(255) AS KeySotorePassword, 
--VARCHAR(255) AS TrustStoreFileName ,VARCHAR(255) AS TrustStorePassword, VARCHAR(20) AS IP_InterAct, VARCHAR(8) AS Port_InterAct, INTEGER AS ID_SP;

RETURNING CHAR(5) AS CodRet,CHAR(100) AS NombreOper,VARCHAR(255) AS Url ,VARCHAR(255) AS KeyStoreFileName, VARCHAR(255) AS KeySotorePassword, 
VARCHAR(255) AS TrustStoreFileName ,VARCHAR(255) AS TrustStorePassword, CHAR(20) AS IP_InterAct, CHAR(8) AS Port_InterAct, INTEGER AS ID_SP, INTEGER AS ID_WS, INTEGER AS ID_TRAN, CHAR(5) AS tran_iac , CHAR(30) AS desc_tran, CHAR(1) AS estatus;
/*</20180626.svrMCWS.01.00.0012b.FB>*/

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
/*<20180626.svrMCWS.01.00.0012b.FB>*/
DEFINE vIdWS INTEGER;
DEFINE vIdTran INTEGER;
DEFINE vDescTranIAC CHAR(30);
DEFINE vEstatus CHAR(1);
DEFINE vNoRegistro INTEGER;
/*</20180626.svrMCWS.01.00.0012b.FB>*/
LET vCodRet = "000";
LET vUrlLink = " ";
LET vNombreOper = " ";
LET vKeystoreFilename = " ";
LET vKeystorePassword = " ";
LET vTruststoreFilename = " ";
LET vTruststorePassword = " ";
LET vIpInteract = " ";
LET vPortInteract= " ";
LET vIdSP = 0;
LET vTran_IAC = "  ";
/*<20180626.svrMCWS.01.00.0012b.FB>*/
LET vIdWS = 0;
LET vIdTran = 0;
LET vDescTranIAC = " ";
LET vEstatus = " ";
LET vNoRegistro = vRegistro;
/*</20180626.svrMCWS.01.00.0012b.FB>*/

BEGIN
  /* Procedure body */
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET vCodRet = sql_err;
        
           /*<20180626.svrMCWS.01.00.0012b.FB>*/
           --RETURN  vCodRet, vUrlLink, vNombreOper, vKeystoreFilename, vKeystorePassword, 
           --        vTruststoreFilename, vTruststorePassword, vIpInteract, 
           --        vPortInteract, vIdSP;
				                      
            RETURN  vCodRet, vNombreOper,vUrlLink, vKeystoreFilename, vKeystorePassword, 
                   vTruststoreFilename, vTruststorePassword, vIpInteract, 
                   vPortInteract, vIdSP,vIdWS,vIdTran,vTran_IAC,vDescTranIAC,vEstatus;
	   /*</20180626.svrMCWS.01.00.0012b.FB>*/
      END IF;
  END EXCEPTION;

  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

  /*<20180626.svrMCWS.01.00.0012b.FB>*/
  --SELECT MCWS.url_link, MCO.nombreoper, 
  --NVL(keystorefilename,"  "), 
  --NVL(keystorepassword,"  "),
  --NVL(truststorefilename,"  "), 
  --NVL(truststorepassword,"  "), 
  --NVL(ipinteract, "  "), 
  --NVL(portinteract, "  "), id_sp 
  --INTO vUrlLink, vNombreOper, vKeystoreFilename, vKeystorePassword,  vTruststoreFilename, vTruststorePassword, vIpInteract, vPortInteract, vIdSP
  --FROM mc_iac_transaccion AS MCIT, mc_operaciones AS MCO, mc_web_service AS MCWS
  --WHERE MCIT.tran_iac = vTran_IAC AND MCO.id_tran = MCIT.id_tran AND MCWS.id_ws = MCO.id_ws;
  
  FOREACH
     SELECT SKIP vNoRegistro FIRST 1
     NVL(MCO.nombreoper, " ") AS nombreoper,  
     NVL(MCWS.url_link, " ") AS url_link, 
     NVL(MCWS.keystorefilename,"  ") AS keystorefilename, 
     NVL(MCWS.keystorepassword,"  ") AS keystorepassword,
     NVL(MCWS.truststorefilename,"  ") AS truststorefilename, 
     NVL(MCWS.truststorepassword,"  ") AS truststorepassword, 
     NVL(MCWS.ipinteract, "  ") AS ipinteract, 
     NVL(MCWS.portinteract, "  ") AS portinteract, 
     id_sp AS id_sp,
     MCWS.id_ws AS id_ws,
     MCIT.id_tran AS id_tran,
     MCIT.tran_iac AS tran_iac,
     MCIT.desc_tran_iac AS desc_tran, 
     MCIT.estatus AS estatus 
     INTO vNombreOper, vUrlLink, vKeystoreFilename, vKeystorePassword,  vTruststoreFilename, vTruststorePassword, vIpInteract, vPortInteract, vIdSP,vIdWS,vIdTran,vTran_IAC,vDescTranIAC,vEstatus
     FROM mc_iac_transaccion AS MCIT, mc_operaciones AS MCO, mc_web_service AS MCWS
     WHERE MCO.id_tran = MCIT.id_tran AND MCWS.id_ws = MCO.id_ws
     /*<20180626.svrMCWS.01.00.0012b.FB>*/
     RETURN  vCodRet,vNombreOper,vUrlLink, vKeystoreFilename, vKeystorePassword, vTruststoreFilename, vTruststorePassword, vIpInteract, 
             vPortInteract, vIdSP,vIdWS,vIdTran,vTran_IAC,vDescTranIAC,vEstatus WITH RESUME;
     /*</20180626.svrMCWS.01.00.0012b.FB>*/
  END FOREACH;
END;
END PROCEDURE;