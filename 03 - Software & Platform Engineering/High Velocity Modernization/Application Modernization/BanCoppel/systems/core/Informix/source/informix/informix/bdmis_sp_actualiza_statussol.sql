CREATE PROCEDURE "informix".sp_actualiza_statussol(pstatus_solicitud varchar(2) ,pdescripcion varchar(40))
DEFINE  iOrden  INTEGER;
BEGIN

--Hecho por: Manuel Osuna Valencia
--Fecha:22/02/2010
--Descripcion: Stored ejecutado por el trigger bdisolic:tr_statussol_insert
--para la actualizacion de estatus de solicitud. en el mis

    set isolation to dirty read;

   SELECT MAX(orden) INTO iOrden FROM bdmis:mi_statussol;
   INSERT INTO bdmis:mi_statussol   (estatus_des,estatus,orden,rptsolicitudes_num)
   VALUES (pdescripcion,pstatus_solicitud,iOrden + 1,'1');

END;
END PROCEDURE;