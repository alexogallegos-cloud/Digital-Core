CREATE PROCEDURE "informix".sp_cerrar_sesion(pc_numero_cliente varchar(20),pc_usuario varchar(20))
    RETURNING CHAR(5);
	
    DEFINE vcodret   CHAR(5);
    DEFINE sql_err   integer;
    DEFINE vCanal    VARCHAR(50);
    DEFINE vFecha    DATETIME YEAR TO FRACTION;

	LET vcodret   = '00000';
    LET vCanal    = '';

BEGIN		

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
			LET vcodret = sql_err;
        RETURN vcodret;
       END IF;
END EXCEPTION;
   
   SET LOCK MODE TO WAIT 3;
   SET ISOLATION TO DIRTY READ;
   
	IF (pc_usuario != '' )	THEN
		---DELETE FROM "informix".bpi_doblesesion WHERE  usuario LIKE pc_usuario;
        SELECT canal, fecha INTO vCanal, vFecha  FROM bdibpi:bpi_doblesesion where usuario = pc_usuario;

        IF(vCanal = 'PORTALBPI') THEN
            DELETE FROM "informix".bpi_doblesesion WHERE  usuario = pc_usuario;
        ELSE
            IF  (current - vFecha) > '0 00:15:00' THEN
                DELETE FROM "informix".bpi_doblesesion WHERE  usuario = pc_usuario;
            END IF;
        END IF;
    END IF	
	IF (pc_numero_cliente != '' )	THEN
		---DELETE FROM "informix".bpi_doblesesion WHERE numcliente LIKE pc_numero_cliente ;
        SELECT canal, fecha INTO vCanal, vFecha  FROM bdibpi:bpi_doblesesion where numcliente = pc_numero_cliente;

        IF(vCanal = 'PORTALBPI') THEN
            DELETE FROM "informix".bpi_doblesesion WHERE numcliente = pc_numero_cliente;
        ELSE 
            IF  (current - vFecha) > '0 00:15:00' THEN
                DELETE FROM "informix".bpi_doblesesion WHERE numcliente = pc_numero_cliente;
            END IF;
         END IF;
	END IF;
	
END;

	RETURN vcodret;
END PROCEDURE;