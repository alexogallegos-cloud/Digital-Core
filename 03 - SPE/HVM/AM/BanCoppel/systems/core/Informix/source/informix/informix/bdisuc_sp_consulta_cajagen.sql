CREATE PROCEDURE "informix".sp_consulta_cajagen()

RETURNING CHAR(5), CHAR(100), CHAR(4), CHAR(40);

DEFINE SQL_ERR INTEGER;
DEFINE ISAM_ERR INTEGER;
DEFINE ERROR_INFO VARCHAR(80);
DEFINE cod_ret CHAR(5);
DEFINE msj CHAR(100);
DEFINE vcod_proveedor CHAR(4);
DEFINE vdescripcion CHAR(40);

LET cod_ret = '00000';
LET msj = 'Operación exitosa';
LET vcod_proveedor = '';
LET vdescripcion = '';

BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET cod_ret = SQL_ERR;
        LET msj = ERROR_INFO;
        RETURN cod_ret, msj, vcod_proveedor, vdescripcion;
    END EXCEPTION;

    set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;

    FOREACH
        SELECT {+index(bdisuc:"informix".ss_proveedores idx01ss_proveedores)}
               cod_proveedor, SUBSTR(descripcion, 14)
          INTO vcod_proveedor, vdescripcion
          FROM bdisuc:"informix".ss_proveedores
         ORDER BY descripcion

        RETURN cod_ret, msj, vcod_proveedor, vdescripcion WITH RESUME;
    END FOREACH;
END;

END PROCEDURE;