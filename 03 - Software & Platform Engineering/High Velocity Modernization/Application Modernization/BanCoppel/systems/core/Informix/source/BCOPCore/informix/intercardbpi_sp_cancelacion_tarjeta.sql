CREATE PROCEDURE "informix".sp_cancelacion_tarjeta
(p_tarjeta varchar(16),
p_codigoproductotarjeta varchar(3),
p_usuario varchar(16))
RETURNING varchar(3), varchar(80);

DEFINE  vsqlerr                     integer;
DEFINE  isam_err                    integer;
DEFINE  vcodret                     varchar(3);
DEFINE  error_info                  varchar(80);
DEFINE  p_mensaje                   varchar(80);
DEFINE  w_reg_count                  integer;
--SET DEBUG FILE TO "/home/informix/cvaeq.out";
--TRACE ON;
BEGIN
    ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr <> 0 OR vsqlerr <> -206 THEN
                    LET vcodret = vsqlerr;
                    LET p_mensaje  = error_info;
                    RETURN vcodret, p_mensaje;
            END IF;
    END EXCEPTION;
    LET w_reg_count = 0;
    SELECT  count(*) INTO w_reg_count
    FROM tarjeta
    WHERE numtarjeta = p_tarjeta
    AND codproductotarjeta = p_codigoproductotarjeta;
    IF w_reg_count <=0  THEN
	LET vcodret = '001';
	LET p_mensaje = 'TARJETA NO EXISTE';
	RETURN vcodret, p_mensaje;
    END IF
    SELECT  count(*) INTO w_reg_count
    FROM tarjeta
    WHERE numtarjeta = p_tarjeta
    and codstatustarjeta = 'CAN'
    AND codproductotarjeta = p_codigoproductotarjeta;

    IF w_reg_count >0  THEN
	LET vcodret = '002';
	LET p_mensaje = 'TARJETA YA ESTA CANCELADA';
	RETURN vcodret, p_mensaje;
    END IF
    UPDATE tarjeta SET codstatustarjeta = 'CAN'
    , fechaultmodif = current YEAR TO FRACTION
    WHERE numtarjeta = p_tarjeta
    AND codproductotarjeta = p_codigoproductotarjeta;

    INSERT INTO bitacoracancelaciontarjetas
    ( tarjeta, codigoproductotarjeta, fecha, usuario, resultado, descripcion)
    VALUES ( p_tarjeta, p_codigoproductotarjeta,
    current YEAR TO FRACTION , p_usuario,'000','CANCELACION DE TARJETA');
    LET vcodret = '000';
    LET p_mensaje = 'PROCESO EXITOSO';
    RETURN vcodret, p_mensaje;
END;
END PROCEDURE;