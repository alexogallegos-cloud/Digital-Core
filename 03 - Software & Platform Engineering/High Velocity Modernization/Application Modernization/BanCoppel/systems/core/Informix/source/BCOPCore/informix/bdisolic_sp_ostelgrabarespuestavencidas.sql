CREATE PROCEDURE "informix".sp_ostelgrabarespuestavencidas(pOSTelefonica int)
returning char(5);

-- 30/12/2008
-- Bernardo Carlos Báez González
-- marca como enviadas las OS Telefonicas recibidas en la tabla ss_osclientesupervisartel
-- borra las tramas que llegaron correctamente de la tabla ss_osclientesupervisartel_xml
-- se graba la fecha y hora de respuesta en ss_ostelrefsolicitud_pendientes
---Modificó : Lorenzo Ibarra García
--Fecha: 26-10-2009
--Se agrega validación de los parámetros de entrada.
--Se agrega control de transacciónes.

define SQL_ERR integer;
define vCod_Ret char(5);

LET SQL_ERR = 0;
Let vCod_Ret = '000';

BEGIN
	ON EXCEPTION SET SQL_ERR
		IF SQL_ERR <> 0 THEN
			LET vCod_Ret = SQL_ERR;
             RETURN vCod_Ret;
		END IF;
	END EXCEPTION;

    IF pOSTelefonica IS NULL OR pOSTelefonica < 1 THEN
        Let vCod_Ret = '001';
        RETURN vCod_Ret;        
    END IF;
    
    set isolation to dirty read;

    update {+INDEX(bdisolic:ss_ostelSolVigenciaVencida idx_ostelvigven)} ss_ostelSolVigenciaVencida set enviada = '1' where secuenciaostel = pOSTelefonica;

    return vCod_Ret;
end;
end procedure;