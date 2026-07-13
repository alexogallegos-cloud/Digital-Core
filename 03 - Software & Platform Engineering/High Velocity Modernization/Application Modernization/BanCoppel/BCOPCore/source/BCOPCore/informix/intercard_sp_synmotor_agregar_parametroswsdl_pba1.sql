CREATE PROCEDURE "informix".sp_synmotor_agregar_parametroswsdl_pba1(vRegistro INTEGER, vOperacion CHAR(5))
/*</20180813.svrMCWS.01.00.0012b.01.FB>*/

/*<20180626.svrMCWS.01.00.0012b.FB>*/
--RETURNING CHAR(5) AS CodRet, CHAR(100) AS Etiqueta,CHAR(1) AS Tipo, CHAR(250) AS Descripcion1,  CHAR(100) AS Campo, INTEGER AS IdParam, INTEGER AS Antecesor, INTEGER AS IdCampo, CHAR (50) AS Descripcion2, INTEGER AS IdSPCampo, CHAR(250) AS ValorDefault;
RETURNING CHAR(5) AS CodRet, CHAR(5) As TranIAC, CHAR(100) AS Etiqueta,CHAR(1) AS Tipo, CHAR(250) AS Descripcion1,  CHAR(100) AS Campo, INTEGER AS IdParam, INTEGER AS Antecesor, INTEGER AS IdCampo, CHAR (50) AS Descripcion2, INTEGER AS IdSPCampo, CHAR(250) AS ValorDefault;
 /*</20180626.svrMCWS.01.00.0012b.FB>*/
 
/**************************************************************************/
/* Fecha: 02/Abril/2018                                                   */
/* SPL: "informix".sp_synmotor_agregar_parametros                         */
/* Actividad:                                                             */
/* Realizado por: Francisco Javier Benito Santiago(fbenito@syndein.com.mx)*/
/* @Copyright 2018 Syndein, S.A. de C.V. All rights reserved.             */
/* SYNDEIN PROPIETARY/CONFIDENTIAL.                                       */
/* Use is subject to license terms                                        */
/**************************************************************************/

DEFINE vCodRet  CHAR(5);
DEFINE sql_err INTEGER;
DEFINE vEtiqueta CHAR(100);
DEFINE vTipo     CHAR(1); 
DEFINE vDescripcion1 CHAR(250); 
DEFINE vCampo CHAR(100);
DEFINE vId_Param INTEGER;
DEFINE vAntecesor INTEGER;
DEFINE vId_Campo INTEGER;
DEFINE vDescripcion2 CHAR (50);
DEFINE vId_SPCampo INTEGER;
DEFINE vValorDefault CHAR(250);

/*<20180626.svrMCWS.01.00.0012b.FB>*/
DEFINE vTranIAC CHAR(5);
/*</20180626.svrMCWS.01.00.0012b.FB>*/

LET vCodRet= '000';
LET vEtiqueta =  ' ';
LET vTipo     = ' '; 
LET vDescripcion1 = ' '; 
LET vCampo = ' ';
LET vId_Param = 0;
LET vAntecesor = 0;
LET vId_Campo = 0;
LET vDescripcion2 = ' ';
LET vId_SPCampo = 0;
LET vValorDefault = ' ';
/*<20180626.svrMCWS.01.00.0012b.FB>*/
LET vTranIAC  = ' ';
/*</20180626.svrMCWS.01.00.0012b.FB>*/
BEGIN
  /* Procedure body */
  
    ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
        LET vCodRet = sql_err;
		/*<20180626.svrMCWS.01.00.0012b.FB>*/
       --RETURN vCodRet, vEtiqueta,vTipo,vDescripcion1,vCampo,vId_Param,vAntecesor, vId_Campo, vDescripcion2, vId_SPCampo, vValorDefault WITH RESUME; 
        RETURN  vCodRet, vTranIAC, vEtiqueta,vTipo,vDescripcion1,vCampo,vId_Param,vAntecesor, vId_Campo, vDescripcion2, vId_SPCampo, vValorDefault;
		/*</20180626.svrMCWS.01.00.0012b.FB>*/
     END IF;
  END EXCEPTION;
 
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;
  
  FOREACH
       /*<20180626.svrMCWS.01.00.0012b.FB>*/
       --SELECT SKIP vRegistro FIRST 12 pa.etiqueta, pa.tipo, pa.descripcion, CASE when cia.campo is null then '' else cia.campo end as campo, pa.id_param, pa.antecesor, CASE when cia.id_campo is null then -1 else cia.id_campo end as id_campo, spc.descripcion as sp, CASE when spc.id_sp_campo is null then -1 else spc.id_sp_campo end as id_sp_campo, CASE when valordefault = 'null' then '' else valordefault end as valordefault
       --INTO vEtiqueta,vTipo,vDescripcion1,vCampo,vId_Param,vAntecesor, vId_Campo, vDescripcion2, vId_SPCampo, vValorDefault
       --FROM mc_web_service ws INNER JOIN mc_operaciones op ON ws.id_ws=op.id_ws INNER JOIN mc_parametros pa
       --ON pa.id_oper=op.id_oper LEFT JOIN mc_sp_central_campos spc ON spc.id_sp_campo=pa.id_sp_campo
       --LEFT JOIN mc_iac_trans_campos cia ON cia.id_campo=pa.id_campo 
       --INNER JOIN mc_iac_transaccion tia ON tia.id_tran = op.id_tran
       --WHERE tia.tran_iac = vOperacion ORDER BY pa.tipo,pa.id_param ASC
       
       SELECT SKIP vRegistro FIRST 12 tia.tran_iac As TranIAC, pa.etiqueta, pa.tipo, pa.descripcion, CASE when cia.campo is null then '' else cia.campo end as campo, pa.id_param, pa.antecesor, CASE when cia.id_campo is null then -1 else cia.id_campo end as id_campo, spc.descripcion as sp, CASE when spc.id_sp_campo is null then -1 else spc.id_sp_campo end as id_sp_campo, CASE when valordefault = 'null' then '' else valordefault end as valordefault
       INTO vTranIAC,vEtiqueta,vTipo,vDescripcion1,vCampo,vId_Param,vAntecesor, vId_Campo, vDescripcion2, vId_SPCampo, vValorDefault
       FROM mc_web_service ws INNER JOIN mc_operaciones op ON ws.id_ws=op.id_ws INNER JOIN mc_parametros pa
       ON pa.id_oper=op.id_oper LEFT JOIN mc_sp_central_campos spc ON spc.id_sp_campo=pa.id_sp_campo
       LEFT JOIN mc_iac_trans_campos cia ON cia.id_campo=pa.id_campo 
       INNER JOIN mc_iac_transaccion tia ON tia.id_tran = op.id_tran
       WHERE tia.tran_iac = vOperacion ORDER BY pa.tipo,pa.id_param ASC
      /*</20180626.svrMCWS.01.00.0012b.FB>*/
       
       /*<20180626.svrMCWS.01.00.0012b.FB>*/
       --RETURN vCodRet, vEtiqueta,vTipo,vDescripcion1,vCampo,vId_Param,vAntecesor, vId_Campo, vDescripcion2, vId_SPCampo, vValorDefault WITH RESUME; 
       RETURN vCodRet, vTranIAC, vEtiqueta,vTipo,vDescripcion1,vCampo,vId_Param,vAntecesor, vId_Campo, vDescripcion2, vId_SPCampo, vValorDefault WITH RESUME; 
       /*</20180626.svrMCWS.01.00.0012b.FB>*/
       
  END FOREACH;  
END;
END PROCEDURE;