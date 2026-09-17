CREATE PROCEDURE "informix".sp_obtienecobranzaostel(pImporte_min decimal(18,2), pImporte_max decimal(18,2), pRegistros integer)
											
RETURNING CHAR(6), CHAR(20), CHAR(20), CHAR(2), CHAR(4), DATE, CHAR(80), CHAR(13), CHAR(13),
CHAR(13), CHAR(5), DECIMAL(18,2), INTEGER , CHAR(4);

---Elaborado por: Armida Pazos 
--Fecha: 07-12-2009
--Objetivo: Obtener registros para la campaña  os telefonica del CAT filtrando por los parámetros.


--VARIABLES
DEFINE vcodret                  CHAR(6);
DEFINE vsqlerr                  INTEGER;
DEFINE v_solicitud              CHAR(20);
DEFINE v_cliente                CHAR(20);
DEFINE v_status_sol             CHAR(2);
DEFINE v_sucursal               CHAR(4);
DEFINE v_fecha_insert           DATE;
DEFINE v_nombre                 CHAR(80);
DEFINE v_t_casa                 CHAR(13);
DEFINE v_celular                CHAR(13);
DEFINE v_t_trabajo              CHAR(13);
DEFINE v_ext_trabajo            CHAR(5);
DEFINE v_monto_solicitud        DECIMAL(18,2);
DEFINE v_meses_historial		INTEGER;
DEFINE v_tipo_comprobante       CHAR(4);

LET vcodret = '000';
LET vsqlerr = 0;
LET v_solicitud = '';
LET v_cliente = '';
LET v_status_sol = '';
LET v_sucursal = '';
LET v_fecha_insert = '';
LET v_nombre = '';
LET v_t_casa = '';
LET v_celular = '';
LET v_t_trabajo = '';
LET v_ext_trabajo = '';
LET v_monto_solicitud = 0;
LET v_meses_historial = 0;
LET v_tipo_comprobante = '';

--SET DEBUG FILE TO '/tmp/sp_obtienecobranzaostel.out';
--TRACE ON;

BEGIN
   ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret, NVL(v_solicitud,''), NVL(v_cliente,''), NVL(v_status_sol,''), NVL(v_sucursal,''), 
            NVL(v_fecha_insert,''), NVL(v_nombre,''), NVL(v_t_casa,''), NVL(v_celular,''), NVL(v_t_trabajo,''),
            NVL(v_ext_trabajo,''), NVL(v_monto_solicitud,0), NVL(v_meses_historial, 0), NVL(v_tipo_comprobante,'');
        END IF;
    END EXCEPTION;

    IF pImporte_min is null or pImporte_max is null or pRegistros is null then
        LET vcodret = '001'; -- Parametros no validos
            RETURN vcodret, NVL(v_solicitud,''), NVL(v_cliente,''), NVL(v_status_sol,''), NVL(v_sucursal,''), 
                NVL(v_fecha_insert,''), NVL(v_nombre,''), NVL(v_t_casa,''), NVL(v_celular,''), NVL(v_t_trabajo,''),
                NVL(v_ext_trabajo,''), NVL(v_monto_solicitud,0), NVL(v_meses_historial, 0), NVL(v_tipo_comprobante,'');
	END IF;


    IF pImporte_min < 0 OR pImporte_max < 0 OR pRegistros < 0 then
        LET vcodret = '002'; -- los parametros numericos recibidos deben ser positivos
            RETURN vcodret, NVL(v_solicitud,''), NVL(v_cliente,''), NVL(v_status_sol,''), NVL(v_sucursal,''), 
                NVL(v_fecha_insert,''), NVL(v_nombre,''), NVL(v_t_casa,''), NVL(v_celular,''), NVL(v_t_trabajo,''),
                NVL(v_ext_trabajo,''), NVL(v_monto_solicitud,0), NVL(v_meses_historial, 0), NVL(v_tipo_comprobante,'');

    END IF;
    
    IF NOT EXISTS(select numcte from cb_repos_cat
                    where monto_sol >= pImporte_min and monto_sol <= pImporte_max) THEN
        LET vcodret = '003'; -- no hay registros para los criterios pasados como parametros
            RETURN vcodret, NVL(v_solicitud,''), NVL(v_cliente,''), NVL(v_status_sol,''), NVL(v_sucursal,''), 
                NVL(v_fecha_insert,''), NVL(v_nombre,''), NVL(v_t_casa,''), NVL(v_celular,''), NVL(v_t_trabajo,''),
                NVL(v_ext_trabajo,''), NVL(v_monto_solicitud,0), NVL(v_meses_historial, 0), NVL(v_tipo_comprobante,'');

    END IF;

    IF pRegistros = 0 then 
        FOREACH
            select num_solicitud, numcte, status_solicitud, sucursal, fecha_insert, nombre_completo, tel_casa, celular, tel_trab, ext_trab, 
			monto_sol, meses_historial, tipo_comprobante
            INTO v_solicitud, v_cliente, v_status_sol, v_sucursal, v_fecha_insert, v_nombre, v_t_casa, v_celular, v_t_trabajo, 
			v_ext_trabajo, v_monto_solicitud, v_meses_historial, v_tipo_comprobante
            from cb_repos_cat
            where monto_sol >= pImporte_min and monto_sol <= pImporte_max

             RETURN vcodret, NVL(v_solicitud,''), NVL(v_cliente,''), NVL(v_status_sol,''), NVL(v_sucursal,''), 
                NVL(v_fecha_insert,''), NVL(v_nombre,''), NVL(v_t_casa,''), NVL(v_celular,''), NVL(v_t_trabajo,''),
                NVL(v_ext_trabajo,''), NVL(v_monto_solicitud,0), NVL(v_meses_historial, 0), NVL(v_tipo_comprobante,'') with resume;
        END FOREACH;
    ELSE
        FOREACH
            select first pRegistros num_solicitud, numcte, status_solicitud, sucursal, fecha_insert, nombre_completo, tel_casa, celular,
			tel_trab, ext_trab, monto_sol, meses_historial, tipo_comprobante
            INTO v_solicitud, v_cliente, v_status_sol, v_sucursal, v_fecha_insert, v_nombre, v_t_casa, v_celular, v_t_trabajo, 
			v_ext_trabajo, v_monto_solicitud, v_meses_historial, v_tipo_comprobante
            from cb_repos_cat
            where monto_sol >= pImporte_min and monto_sol <= pImporte_max

              RETURN vcodret, NVL(v_solicitud,''), NVL(v_cliente,''), NVL(v_status_sol,''), NVL(v_sucursal,''), 
                NVL(v_fecha_insert,''), NVL(v_nombre,''), NVL(v_t_casa,''), NVL(v_celular,''), NVL(v_t_trabajo,''),
                NVL(v_ext_trabajo,''), NVL(v_monto_solicitud,0), NVL(v_meses_historial, 0), NVL(v_tipo_comprobante,'')with resume;

        END FOREACH;
    END IF;
END;
END PROCEDURE;