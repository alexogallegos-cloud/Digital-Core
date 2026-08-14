CREATE PROCEDURE "informix".sp_borratemporales()

--**************************************************
-- Creado por Alfredo Avena 30/Mar/2007 --*
--**************************************************

            Delete FROM bdicont:tmpco_detpol;

            Delete FROM bdicont:co_errorpoliza;

END PROCEDURE;