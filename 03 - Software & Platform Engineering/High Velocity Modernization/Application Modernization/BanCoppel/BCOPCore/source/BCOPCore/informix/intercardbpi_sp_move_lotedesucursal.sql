CREATE PROCEDURE "informix".sp_move_lotedesucursal(p_numerolote integer, p_clave_suc_ori varchar(5), p_clave_suc_des varchar(5))
RETURNING varchar(6), varchar(80);
-- Cambiar Lote de Sucursal
/**************************************************************************/
/* Fecha: 27/02/2009                                                      */
/* SPL: "informix".sp_move_lotedesucursal()                               */
/* Actividad: Se encarga de mover una tarjeta de sucursal                 */
/* Realizado por: Aaron Quiroz /Syndein                                   */
/* Modificado:25/04/2009 para crear la relacion sucursaltipotarjeta       */
/**************************************************************************/

DEFINE  vsqlerr                     integer;
DEFINE  isam_err                    integer;
DEFINE  vcodret                     varchar(6);
DEFINE  cCodRet                     varchar(6);
DEFINE  error_info                  varchar(80);
DEFINE  p_mensaje                   varchar(80);
DEFINE  c_mensaje                   varchar(80);


DEFINE v_cant_tarjetas_x_lote      integer;
DEFINE v_clave_tipotarjeta         integer;
DEFINE v_Cuantas                   integer;
BEGIN
    ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr <> 0 OR vsqlerr <> -206 THEN
                    LET vcodret = vsqlerr;
                    LET  p_mensaje  = error_info;
                    ROLLBACK WORK;
                    RETURN vcodret, p_mensaje;
            END IF;
    END EXCEPTION;
BEGIN work;
       
    /*Se obtiene la clave del tipo de tarjeta*/
    SELECT clave_tipotarjeta INTO v_clave_tipotarjeta
    FROM lote
    WHERE
        numerolote = p_numerolote
    AND clave_sucursal = p_clave_suc_ori;


    /*Obtiene el numero lote y Sucursal de una Tarjeta*/
   /* SELECT lt.clave_sucursal,lt.numerolote 
                      FROM tarjeta t, lote lt 
                      WHERE t.numerolote = lt.numerolote 
                      AND t.numtarjeta = '';*/



    /*Se obtiene el numero de tarjetas INA y NOA del lote (Existencias en Inventario)*/
    SELECT count(numtarjeta) into v_cant_tarjetas_x_lote
                      FROM tarjeta t, lote lt 
                      WHERE t.numerolote = lt.numerolote 
		      AND  t.CodStatusAsignada = 'NOA' 
                      AND t.codstatustarjeta = 'INA'
		      AND lt.clave_sucursal = p_clave_suc_ori
		      AND lt.numerolote = p_numerolote;

    /*Validar que tenga tarjetas INA y NOA*/

   /*Validar que exista el lote*/
   SELECT COUNT(*) INTO v_Cuantas FROM lote WHERE  numerolote = p_numerolote
    AND clave_sucursal = p_clave_suc_ori ;

   if v_Cuantas <= 0 THEN
      LET vcodret = '001';
      LET p_mensaje = 'No existe la relacion sucursal origen con numero de lote.';
      ROLLBACK WORK;
      RETURN vcodret, p_mensaje;
    END IF;

    /*Se cambia el lote de sucursal */
    UPDATE lote SET clave_sucursal = p_clave_suc_des 
    WHERE  numerolote = p_numerolote
    AND clave_sucursal = p_clave_suc_ori ;

    /*Validar que exista la relacion Sucursal origen tipo de tarjeta*/
    SELECT COUNT(*) INTO v_Cuantas FROM sucursal_tipotarjeta 
    WHERE clave_sucursal = p_clave_suc_ori AND clave_tipotarjeta = v_clave_tipotarjeta;
    if v_Cuantas <= 0 THEN
      LET vcodret = '002';
      LET p_mensaje = 'No existe la relacion sucursal  tipotarjeta origen.';
      ROLLBACK WORK;
      RETURN vcodret, p_mensaje;
    END IF;

     /*Se decrementa la existencia*/
    UPDATE sucursal_tipotarjeta set existencia = existencia - v_cant_tarjetas_x_lote 
    WHERE clave_sucursal = p_clave_suc_ori AND clave_tipotarjeta = v_clave_tipotarjeta;

    /*Validar que exista la relacion sucursal destino y tipo de tarjeta*/
    SELECT COUNT(*) INTO v_Cuantas FROM sucursal_tipotarjeta 
    WHERE clave_sucursal = p_clave_suc_des AND clave_tipotarjeta = v_clave_tipotarjeta;
    if v_Cuantas <= 0 THEN
     /*Si no existe crearla*/
      insert into sucursal_tipotarjeta (clave_sucursal,  clave_tipotarjeta,  existencia,  solicitadas)
	values(p_clave_suc_des,v_clave_tipotarjeta,0,0);
    END IF;

     /*Se incrementa la existencia*/
    UPDATE sucursal_tipotarjeta set existencia = existencia + v_cant_tarjetas_x_lote 
    WHERE clave_sucursal = p_clave_suc_des AND clave_tipotarjeta = v_clave_tipotarjeta;


  
    LET vcodret = '000';
    LET p_mensaje = 'PROCESO EXITOSO';
    COMMIT WORK;
RETURN vcodret, p_mensaje;
END;
END PROCEDURE;