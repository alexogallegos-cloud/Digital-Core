CREATE PROCEDURE "informix".sp_consulta_tokensnoasociados_bei(pNumCliente char(9))
 returning char(5), CHAR(10)   , INTEGER ;


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;


    DEFINE sNsToken CHAR(10);
    DEFINE sIdStatusToken INTEGER ;


    LET cod_ret  = "00000";
    LET sNsToken = '';
    LET sIdStatusToken = 0;

--****************************************************************************************************
-- DESCRIPCION:  OBTIENE LOS DATOS DE LOS TOKENS EXISTENTES SIN ASOCIAR
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :

-- MODIFICACIÃN: SE MODIFICA PARA QUE CONSULTE LOS TOKESN DISPONIBLES 
-- (QUE ESTAN EN LA TABLA DE SOLCITUD DEL CLIENTE Y QUE NO ESTAN SIENDO USADOS EN LA TABLA BEI_TOKEN)
-- AUTOR : Berenice Noriega Guevara
-- FECHA : 04 Septiembre 2013 3:18 PM
-- BD: bdibei
-- SOLICITO :Ismael Hernandez

-- MODIFICACIÃN: SE MODIFICA PARA OMITA LOS TOKEN QUE TIENEN ESTATUS 199-CANCELADOS
-- AUTOR : Berenice Noriega Guevara
-- FECHA : 21 octubre 2014 
-- BD: bdibei
-- SOLICITO :Alejandro Vazquez-BanCoppel


-- MODIFICACIÃN: Se agrega validciÃ³n para estatus 220-CANCELADOS por renovaciÃ³n
-- AUTOR : Gabriela Aguilar
-- FECHA : 02 octubre 2018
-- BD: bdibei
-- 
--***************************************************************************************************
  
  --SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_consulta_tokensnoasociados_bei.out";
  --TRACE ON;
  
  
   SET LOCK MODE TO WAIT 3;
	 SET ISOLATION TO DIRTY READ;

  
  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
          RETURN cod_ret, sNsToken, sIdStatusToken;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE TOKEN
--**************************************************************************************************************

	IF NVL(pNumCliente,0) == 0 THEN
	 	  LET cod_ret = '001'; -- No ay Registros
          RETURN cod_ret, sNsToken, sIdStatusToken;
	END IF;
   

--**************************************************************************************************************
--OBTIENES DATOS DE TOKEN
--**************************************************************************************************************
        FOREACH
             
	    SELECT bts.ns_token, tns.id_status
            INTO sNsToken, sIdStatusToken
            FROM "informix".bei_tokensolicitud as bts
            INNER JOIN bdibpi:"informix".tkn_nseries as tns 
            ON bts.ns_token=tns.ns_token AND bts.numcte=pNumCliente 
            and bts.ns_token not in (SELECT ns_token from "informix".bei_token WHERE num_cliente  = pNumCliente)
            and tns.ns_token not in (SELECT ns_token from "informix".bei_token WHERE num_cliente  = pNumCliente)
    	    and tns.id_status not in ('199','220')
            RETURN cod_ret, sNsToken, sIdStatusToken WITH RESUME;
     
         END FOREACH;

END
END PROCEDURE;