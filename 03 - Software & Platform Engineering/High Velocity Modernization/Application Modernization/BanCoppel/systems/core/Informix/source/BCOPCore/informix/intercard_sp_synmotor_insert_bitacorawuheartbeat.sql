CREATE PROCEDURE "informix".sp_synmotor_insert_bitacorawuheartbeat
(sPartner_ID VARCHAR(32), sSystem_IpAddress VARCHAR(17), sSystem_ConnectorID VARCHAR(30), 
sDevice_ID VARCHAR(30), sDevice_Type VARCHAR(6), sRtncode VARCHAR(5),  sStatusCode VARCHAR(6),  
sStatus_message VARCHAR(40),  sError VARCHAR(250))

RETURNING CHAR(5) As CodRet;

/**************************************************************************/
/* Fecha: 02/Abril/2018                                                   */
/* SPL: "informix".sp_synmotor_insert_bitacorawuheartbeat()               */
/* Actividad:                                                             */
/* Realizado por: Francisco Javier Benito Santiago(fbenito@syndein.com.mx)*/
/* @Copyright 2018 Syndein, S.A. de C.V. All rights reserved.             */
/* SYNDEIN PROPIETARY/CONFIDENTIAL.                                       */
/* Use is subject to license terms                                        */
/**************************************************************************/

DEFINE vCodRet  CHAR(5);
DEFINE sql_err INTEGER;
DEFINE vPartner_ID VARCHAR(32); 
DEFINE vSystem_IpAddress VARCHAR(17);
DEFINE vSystem_ConnectorID VARCHAR(30);
DEFINE vDevice_ID VARCHAR(30);
DEFINE vDevice_Type VARCHAR(6);
DEFINE vRtncode VARCHAR(5); 
DEFINE vStatus_code VARCHAR(6); 
DEFINE vStatus_message VARCHAR(40); 
DEFINE vError VARCHAR(250);


LET vCodRet = '000';
LET vPartner_ID = sPartner_ID; 
LET vSystem_IpAddress = sSystem_IpAddress;
LET vSystem_ConnectorID =  sSystem_ConnectorID;
LET vDevice_ID = sDevice_ID;
LET vDevice_Type = sDevice_Type;
LET vRtncode = sRtncode; 
LET vStatus_code = sStatusCode; 
LET vStatus_message = sStatus_message; 
LET vError = sError;


BEGIN
  /* Procedure body */
  ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
        LET vCodRet = sql_err;
        RETURN  vCodRet;
     END IF;
  END EXCEPTION;
  
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

  INSERT INTO bitacorawuheartbeat 
  (partner_id, system_ipaddress, system_connectorid, device_id, device_type, 
  rtncode, status_code, status_message, fechahorainsercion, error) 
  VALUES
  (vPartner_ID, vSystem_IpAddress, vSystem_ConnectorID, vDevice_ID, vDevice_Type,
  vRtncode, vStatus_code, vStatus_message, CURRENT, vError);
 
  RETURN vCodRet;
   
END;
END PROCEDURE;