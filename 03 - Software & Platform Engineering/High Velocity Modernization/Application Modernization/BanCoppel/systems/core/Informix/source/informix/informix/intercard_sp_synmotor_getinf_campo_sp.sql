CREATE PROCEDURE "informix".sp_synmotor_getinf_campo_sp
(vID_SP_Central INTEGER)

-- RETURNING CHAR(5) AS CodRet, INTEGER AS IdSPCampo, INTEGER AS Tamano, VARCHAR(255) AS SPNombre, CHAR(100) AS BD,INTEGER AS LongSal, VARCHAR(3) AS Orden, CHAR(1) AS TipoCampo; 
RETURNING CHAR(5) AS CodRet, INTEGER AS IdSPCampo, INTEGER AS Tamano, VARCHAR(255) AS SPNombre, CHAR(100) AS BD,INTEGER AS LongSal, VARCHAR(3) AS Orden;   

 /**************************************************************************/
/* Fecha: 02/Abril/2018                                                    */
/* SPL: "informix".sp_synmotor_getinf_campo_sp                             */
/* Actividad:                                                              */
/* Realizado por: Francisco Javier Benito Santiago(fbenito@syndein.com.mx) */
/* @Copyright 2018 Syndein, S.A. de C.V. All rights reserved.              */
/* SYNDEIN PROPIETARY/CONFIDENTIAL.                                        */
/* Use is subject to license terms                                         */
/**************************************************************************/

DEFINE vCodRet  CHAR(5);
DEFINE sql_err INTEGER;
DEFINE vID_SP_Campo INTEGER; 
DEFINE vTamano INTEGER; 
DEFINE vSpnombre VARCHAR(255); 
DEFINE vBd CHAR(100); 
DEFINE vLongsal INTEGER; 
DEFINE vOrden VARCHAR(3); 

/*<20180402-FB>*/
-- DEFINE vTipoCampo CHAR(1);
/*</20180402-FB>*/

LET vCodRet= '000';
LET vID_SP_Campo = 0; 
LET vTamano =0; 
LET vSpnombre = ' '; 
LET vBd = ' '; 
LET vLongsal = 0; 
LET vOrden = ' '; 

/*<20180402-FB>*/
-- LET vTipoCampo = ' ';
/* </20180402-FB>*/

BEGIN
  /* Procedure body */
  ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
        LET vCodRet = sql_err;
        /*<20180402-FB>*/
         RETURN vCodRet, vID_SP_Campo, vTamano,  vSpnombre, vBd,  vLongsal,  vOrden;    
        --  RETURN vCodRet, vID_SP_Campo, vTamano,  vSpnombre, vBd,  vLongsal,  vOrden, vTipoCampo;     
        /* </20180402-FB>*/
     END IF;
  END EXCEPTION;
  
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

  FOREACH
     /*<20180402-FB>*/
     SELECT id_sp_campo, tamano, spnombre, bd, longsal, orden 
     INTO vID_SP_Campo, vTamano,  vSpnombre, vBd,  vLongsal,  vOrden   
     FROM mc_sp_central MS, mc_sp_central_campos MSC
     WHERE MS.id_sp=vID_SP_Central AND MSC.id_sp=MS.id_sp AND Tipo_campo='S' ORDER BY orden ASC
     
     -- SELECT id_sp_campo, tamano, spnombre, bd, longsal, orden, tipo_campo 
     -- INTO vID_SP_Campo, vTamano,  vSpnombre, vBd, vLongsal,vOrden, vTipoCampo   
     -- FROM mc_sp_central MS, mc_sp_central_campos MSC
     -- WHERE MS.id_sp= vID_SP_Central AND MSC.id_sp=MS.id_sp AND Tipo_campo='S' ORDER BY orden ASC
   
       RETURN vCodRet, vID_SP_Campo, vTamano,  vSpnombre, vBd,  vLongsal,  vOrden  WITH RESUME;   
     -- RETURN vCodRet, vID_SP_Campo, vTamano, vSpnombre, vBd,  vLongsal,  vOrden, vTipoCampo WITH RESUME;   
     /* </20180402-FB>*/
  END FOREACH;
  
END;
END PROCEDURE;