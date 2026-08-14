CREATE PROCEDURE "informix".envia_monitorsol_pba(o_empresa     CHAR(3),
                                                      o_sucursal    CHAR(20),
                                                      o_solicitudes SMALLINT,
                                                      o_numcte      CHAR(20))
RETURNING CHAR(5),  -- Codigo de Retorno
          CHAR(20), -- Nro de Solicitud
          CHAR(20), -- Nro de Cliente
          CHAR(120),    -- Nombre del Cliente
          CHAR(15),     -- R.F.C.
          DATE,	    -- Fecha de Solicitud
          DATE,         -- Fecha Autorizacion
          MONEY(14,2),  -- Linea Otorgada
          CHAR(2),      -- Status de la Solicitud
          CHAR(60),     -- Descripcion del Status de la Solicitud
          CHAR(255),    -- Comentario
          CHAR(2),      -- Dia de Corte
          CHAR(2),      -- Divisa
          MONEY(14,2);  -- Ingreso del Cliente

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret         CHAR(5);
DEFINE vsqlerr          INTEGER;
DEFINE s_numsol         CHAR(20);
DEFINE s_numcte         CHAR(20);
DEFINE s_nombre         CHAR(110);
DEFINE s_fechaaut       DATE;
DEFINE  s_fechasol      DATE;
DEFINE s_linea          MONEY(14,2);
DEFINE s_status         CHAR(2);
DEFINE s_stdesc         CHAR(50);
DEFINE s_comentario     CHAR(255);
DEFINE s_rfc            CHAR(15);
DEFINE s_diacorte       CHAR(2);
DEFINE s_divisa         CHAR(2);
DEFINE s_ingreso        MONEY(14,2);
DEFINE v_cuantos        SMALLINT;
DEFINE vfecha_hoy       DATE;
DEFINE vdias_rt         SMALLINT;
DEFINE vdias_at         SMALLINT;
DEFINE vdias_vigencia   SMALLINT;
--jom ini
DEFINE r_social          CHAR(40);
DEFINE nombre1           CHAR(40);
DEFINE nombre2           CHAR(40);
DEFINE apellidopaterno   CHAR(40);
DEFINE apellidomaterno   CHAR(40);
DEFINE s_eval_min        DECIMAL(10,2);
DEFINE s_eval_max        DECIMAL(10,2);
--jom fin

--*************************************************************************************
--ACTIVIDAD: Se modifica para que las consultas a la tabla ss_scoring_solic lo
-- hagan para el tp_solcitud ='T' y activa=0. Cambios Version Actual Caja Unica.
--FECHA: 23/02/2009
--AUTOR: Julio Cesar Polanco.
--*************************************************************************************
--ACTIVIDAD: Se para que solo muestre el producto 6001 que seria tarjeta de crédito.
--FECHA: 11/01/2010.
--AUTOR: Paul Ivan Quintero Varela.
--*************************************************************************************

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret         = "000";
LET vsqlerr          = 0;
LET s_nombre         = "??????????";
LET s_numcte         = "??????????";
LET s_fechaaut       = "";
LET s_fechasol       = "";
LET s_status         = "??";
LET s_numsol         = "??????????";
LET s_comentario     = "??????????";
LET s_stdesc         = "??????????";
LET s_rfc            = "??????????";
LET s_linea          = 0;
LET s_diacorte       = "20";
LET s_divisa         = "??";
LET v_cuantos        = 0;
LET vfecha_hoy       = "";
LET vdias_rt         = 0;
LET vdias_at         = 0;
LET vdias_vigencia   = 0;
LET s_ingreso        = 0;
-- jom ini
LET r_social         = "";
LET nombre1          = "";
LET nombre2          = "";
LET apellidopaterno  = "";
LET apellidomaterno  = "";
LET s_eval_min       = 0;
LET s_eval_max       = 0;
-- jom fin


-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut,
             s_linea, s_status, s_stdesc, s_comentario, s_diacorte, s_divisa,
         s_ingreso;
   END IF;
END EXCEPTION;


-- SET DEBUG FILE TO '/tmp/envia_monitorsol.out';
-- TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

   -- Carga la Fecha del Dia
   SELECT {+INDEX(bdicred:sd_fechas idx_sdfechas)} fecha_hoy
     INTO vfecha_hoy
     FROM bdicred:sd_fechas
    WHERE empresa = o_empresa;

   -- Carga Parametro de Dias de Vigencia de Rechazadas
   SELECT {+INDEX(bdisolic:ss_param idx_ss_param)} valor
     INTO vdias_rt
     FROM bdisolic:ss_param
    WHERE empresa = o_empresa and
          secuencia = 20;

   IF vdias_rt IS NULL THEN
      LET scod_ret = "117";
      RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut,
             s_linea, s_status, s_stdesc, s_comentario, s_diacorte, s_divisa,
         s_ingreso;
   END IF

    SELECT {+INDEX(bdisolic:ss_scoring_solic idx_ss_scoring_solic)} evaluacion_min
    INTO s_eval_min
    FROM bdisolic:ss_scoring_solic
    WHERE empresa = o_empresa AND tp_solicitud = 'T'
    AND seccion = 4 AND tpo_persona = '01' AND activa = '0';


    SELECT evaluacion_min
    INTO s_eval_max
    FROM bdisolic:ss_scoring_solic
    WHERE empresa = o_empresa 
      AND seccion = 2 
    AND tp_solicitud = 'T'
    AND tpo_persona = '01' AND activa = '0';

 /*
    SELECT {+INDEX(bdisolic:ss_scoring_solic idx_ss_scoring_solic)} evaluacion_min
    INTO s_eval_max
    FROM bdisolic:ss_scoring_solic
    WHERE empresa = o_empresa  AND tp_solicitud = 'T'  
      AND seccion = 2   AND tpo_persona = '01' AND activa = '0' ; */


   -- Carga Parametro de Dias de Vigencia de Autolrizadas

   SELECT {+INDEX(bdisolic:ss_param idx_ss_param)} valor
     INTO vdias_at
     FROM bdisolic:ss_param
    WHERE empresa = o_empresa and
          secuencia = 21;

    IF vdias_rt IS NULL THEN
        LET scod_ret = "118";
        RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut,
             s_linea, s_status, s_stdesc, s_comentario, s_diacorte, s_divisa,
         s_ingreso;
    END IF;


    IF o_numcte is null or o_numcte = "" then
--jom ini 
        FOREACH
        SELECT {+INDEX(bdisolic:ss_solicitudes idx_ss_solicitudes2)} a.num_solicitud, 
               a.numcte,
               b.razon_social,
               b.nombre1 nombre,
               b.nombre2 nombre2,
               b.apell_paterno paterno,
               b.apell_materno materno,
               b.rfc,
               a.fecha_insert,
               NVL(f.fecha_entrada,TODAY::DATE),
               NVL(a.monto_solicitado,0),
               a.status_solicitud, 
               e.descripcion ,
               TRIM(NVL(SUBSTR(f.comentario,1,155), ' '))   || ' ' || 
               TRIM(NVL(g.motivo_cc, ' ')) comentario,
               h.divisa, NVL(g.ingreso_mensual, 0)
--            INTO s_numsol, s_numcte, s_nombre, s_rfc, s_fechaaut, s_linea,
          INTO s_numsol, s_numcte, r_social, nombre1, nombre2, apellidopaterno, apellidomaterno, s_rfc, 
               s_fechasol, s_fechaaut, s_linea, s_status, s_stdesc, s_comentario, s_divisa, s_ingreso
          FROM ss_solicitudes a 
               JOIN bdinteg:si_cliente b ON (a.empresa = b.empresa and b.numcte = a.numcte)
               LEFT outer JOIN ss_autorizacion f ON (    f.empresa = a.empresa 
                                                     AND f.num_solicitud = a.num_solicitud 
                                                     AND f.status_solicitud = a.status_solicitud)
--                       INNER JOIN ss_anexosol c ON c.empresa = a.empresa AND c.num_solicitud = a.num_solicitud
               JOIN ss_status_sol e ON (e.empresa = a.empresa AND e.status_solicitud = a.status_solicitud)
               JOIN ss_resum_scor_fin g ON (e.empresa = a.empresa and  g.empresa = '001' AND g.num_solicitud = a.num_solicitud)
               JOIN bdicred:sd_definicion h ON (h.num_producto = a.num_producto and h.empresa = a.empresa)
         WHERE a.empresa = o_empresa
           and a.sucursal = o_sucursal
           and a.num_producto = '6001'
           and (
                a.status_solicitud in ('CC','BC','OS','EE','OA','EA','CE') 
                or (a.status_solicitud = 'RT' and a.fecha_insert >= (select today - (valor+0) from ss_param where empresa = a.empresa and secuencia = 20))
                or (a.status_solicitud = 'AT' and a.fecha_insert >= (select today - (valor+0) from ss_param where empresa = a.empresa and secuencia = 21))
                 )
           AND NVL(f.fecha_entrada,CURRENT YEAR TO DAY) = (SELECT {+INDEX(bdisolic:ss_autorizacion empsolsta)} NVL(MAX(NVL(fecha_entrada,CURRENT YEAR TO DAY)),CURRENT YEAR TO DAY)
                                                             FROM ss_autorizacion h
                                                            WHERE h.empresa = a.empresa
                                                              AND h.num_solicitud=a.num_solicitud
                                                              and h.status_solicitud = a.status_solicitud)
        ORDER BY nombre, nombre2, paterno, materno, fecha_entrada
--jom fin
         let s_nombre = trim(nvl(nombre1,"")) || " " || trim(nvl(nombre2,"")) || " " || trim(nvl(apellidopaterno,"")) || " " || trim(nvl(apellidomaterno,""));

        IF s_status <> "AT" THEN
            LET s_fechaaut = "";
            LET s_linea = 0;
        END IF

        LET s_status = s_status;

  -- Consulta para  hacer las validaciones de acuerdo al RQM 09 075

--     IF s_status = "RT" THEN
--
 --          IF EXISTS (SELECT 1
 --                    FROM bdisolic:ss_solicitudes b,
 --                       bdisolic:ss_resum_scor_fin c,
 --                       bdisolic:ss_resumen_scoring e,
 --                       bdisolic:ss_detalle_scoring d,
 --                       bdisolic:ss_detalle_scoring f,
 --                       bdinteg:si_cliente a
 --                   WHERE b.num_solicitud = s_numsol
 --                       AND (c.num_solicitud = b.num_solicitud and c.meses_historia <= 13 and c.evalua_cc<>'1')
 --                       AND ( d.num_solicitud = b.num_solicitud and d.grupo = 7 and d.elemento  in(9, 11))
 --                       AND ( f.num_solicitud = b.num_solicitud and f.grupo = 14 and f.elemento =2)
 --                       AND a.numcte = b.numcte
 --                       AND e.num_solicitud = b.num_solicitud
 --                   GROUP BY 1
  --                  HAVING SUM(e.evaluacion) BETWEEN s_eval_min AND s_eval_max) THEN

--                    LET s_comentario = 'Solicitar al cliente un comprobante de ingresos';
 --           END IF;
 --       END IF;

        -- Valida el Tiempo de Permanecia de las Solicitudes AT y RT
{
        IF s_status = "RT" THEN
            SELECT vfecha_hoy - MAX(fecha_entrada)
            INTO vdias_vigencia
            FROM bdisolic:ss_autorizacion
            WHERE empresa = o_empresa
            AND num_solicitud =  s_numsol
            AND status_solicitud = s_status;

            LET vdias_vigencia = vdias_vigencia;
            LET vdias_rt = vdias_rt;

            IF vdias_vigencia >= vdias_rt THEN
              CONTINUE FOREACH;
            END IF;

        ELSE
            IF s_status = "AT" THEN
                LET vfecha_hoy = vfecha_hoy;
                LET s_fechaaut = s_fechaaut;

                SELECT vfecha_hoy - MAX(fecha_entrada)
                INTO vdias_vigencia
                FROM bdisolic:ss_autorizacion
                WHERE num_solicitud =  s_numsol AND
                     status_solicitud = s_status;

                LET vdias_vigencia = vdias_vigencia;
                LET vdias_at = vdias_at;

                IF vdias_vigencia >= vdias_at THEN
                    CONTINUE FOREACH;
                END IF;
            END IF;
        END IF;
}

        LET v_cuantos = v_cuantos + 1;
        IF v_cuantos <= o_solicitudes THEN
            CONTINUE FOREACH;
        END IF;

        RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut,
               s_linea, s_status, s_stdesc, s_comentario, s_diacorte,
               s_divisa, s_ingreso
        WITH RESUME;
        END FOREACH;
    ELSE
         FOREACH
        SELECT a.num_solicitud, a.numcte,
--               TRIM(NVL(b.razon_social,' ')) ||
--               TRIM(NVL(b.nombre1, ' ')) || ' ' ||
--               TRIM(NVL(b.nombre2, ' ')) || ' ' ||
--               TRIM(NVL(b.apell_paterno, ' ')) || ' ' ||
--               TRIM(NVL(b.apell_materno, ' ')) nombre, b.rfc,
               b.razon_social,
               b.nombre1 nombre,
               b.nombre2 nombre2,
               b.apell_paterno paterno,
               b.apell_materno materno,
               b.rfc,
               a.fecha_insert,
               NVL(f.fecha_entrada,TODAY::DATE),
               NVL(a.monto_solicitado,0),
               a.status_solicitud, e.descripcion,
               TRIM(NVL(SUBSTR(f.comentario,1,155), ' ')) || ' ' ||
               TRIM(NVL(g.motivo_cc, ' ')) comentario,
               h.divisa, NVL(g.ingreso_mensual, 0)
--            INTO s_numsol, s_numcte, s_nombre, s_rfc, s_fechaaut, s_linea,
          INTO s_numsol, s_numcte, r_social, nombre1, nombre2, apellidopaterno, apellidomaterno, s_rfc, 
                 s_fechasol, s_fechaaut, s_linea, s_status, s_stdesc, s_comentario, s_divisa, s_ingreso
          FROM ss_solicitudes a INNER JOIN bdinteg:si_cliente b ON ( b.empresa = a.empresa and  b.numcte = a.numcte )
               INNER JOIN ss_anexosol c ON c.empresa = a.empresa AND c.num_solicitud = a.num_solicitud
               INNER JOIN ss_status_sol e ON (e.empresa = a.empresa AND e.status_solicitud = a.status_solicitud)
               INNER JOIN ss_resum_scor_fin g ON (g.empresa = a.empresa and  g.empresa = '001' AND g.num_solicitud = a.num_solicitud)
               INNER JOIN bdicred:sd_definicion h ON (h.empresa = a.empresa AND h.num_producto = a.num_producto)
               LEFT JOIN ss_autorizacion f ON (f.empresa = a.empresa AND f.num_solicitud = a.num_solicitud
                                               AND f.status_solicitud = a.status_solicitud)
--         WHERE a.empresa = o_empresa
--           where a.sucursal = o_sucursal
           WHERE a.empresa = o_empresa
             AND a.numcte = o_numcte
             AND a.num_producto = '6001'
 --          AND a.status_solicitud NOT IN ('PC','AP','AN',"CA","CR")
             and a.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA','CE')
             AND NVL(f.fecha_entrada,CURRENT) = (SELECT NVL(MAX(NVL(fecha_entrada,CURRENT)),CURRENT)
                                                   FROM ss_autorizacion h
                                                  WHERE h.empresa = a.empresa
                                                    AND h.num_solicitud=a.num_solicitud
                                                    and h.status_solicitud = a.status_solicitud)
--jom ini
           and ((NVL(f.fecha_entrada,CURRENT) >= (select today - (valor+0) from ss_param where empresa = '001' and secuencia = 20) and a.status_solicitud = 'RT')
                  or
                (NVL(f.fecha_entrada,CURRENT) >= (select today - (valor+0) from ss_param where empresa = '001' and secuencia = 21) and a.status_solicitud = 'AT')
                  or
                (a.status_solicitud not in ('AT','RT')))
--jom fin
         ORDER BY nombre, nombre2, paterno, materno, fecha_entrada

         let s_nombre = trim(nvl(nombre1,"")) || " " || trim(nvl(nombre2,"")) || " " || trim(nvl(apellidopaterno,"")) || " " || trim(nvl(apellidomaterno,""));

            IF s_status <> "AT" THEN
                LET s_fechaaut = "";
                LET s_linea = 0;
            END IF;

            LET s_status = s_status;

  -- Consulta para  hacer las validaciones de acuerdo al RQM 09 075

--     IF s_status = "RT" THEN
--
--           IF EXISTS (SELECT 1
--                     FROM bdisolic:ss_solicitudes b,
--                        bdisolic:ss_resum_scor_fin c,
--                        bdisolic:ss_resumen_scoring e,
 --                       bdisolic:ss_detalle_scoring d,
 --                       bdisolic:ss_detalle_scoring f,
 --                       bdinteg:si_cliente a
 --                   WHERE b.num_solicitud = s_numsol
 --                       AND (c.num_solicitud = b.num_solicitud and c.meses_historia <= 13 and c.evalua_cc<>'1')
 --                       AND ( d.num_solicitud = b.num_solicitud and d.grupo = 7 and d.elemento  in(9, 11))
 --                       AND ( f.num_solicitud = b.num_solicitud and f.grupo = 14 and f.elemento =2)
 --                       AND a.numcte = b.numcte
 --                       AND e.num_solicitud = b.num_solicitud
 --                   GROUP BY 1
 --                   HAVING SUM(e.evaluacion) BETWEEN s_eval_min AND s_eval_max) THEN
--
 --                   LET s_comentario = 'Solicitar al cliente un comprobante de ingresos';
 --           END IF;
 --       END IF;

        -- Valida el Tiempo de Permanecia de las Solicitudes AT y RT

{            IF s_status = "RT" THEN
                SELECT vfecha_hoy - MAX(fecha_entrada)
                INTO vdias_vigencia
                FROM bdisolic:ss_autorizacion
                WHERE num_solicitud =  s_numsol AND
                      status_solicitud = s_status;

                LET vdias_vigencia = vdias_vigencia;
                LET vdias_rt = vdias_rt;

                IF vdias_vigencia >= vdias_rt THEN
                  CONTINUE FOREACH;
                END IF;
            ELSE
                IF s_status = "AT" THEN
                    LET vfecha_hoy = vfecha_hoy;
                    LET s_fechaaut = s_fechaaut;

                    SELECT vfecha_hoy - MAX(fecha_entrada)
                    INTO vdias_vigencia
                    FROM bdisolic:ss_autorizacion
                    WHERE num_solicitud =  s_numsol AND
                         status_solicitud = s_status;

                    LET vdias_vigencia = vdias_vigencia;
                    LET vdias_at = vdias_at;

                    IF vdias_vigencia >= vdias_at THEN
                        CONTINUE FOREACH;
                    END IF;
               END IF;
            END IF;
}
            LET v_cuantos = v_cuantos + 1;
            IF v_cuantos <= o_solicitudes THEN
                CONTINUE FOREACH;
            END IF;

            RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut,
                   s_linea, s_status, s_stdesc, s_comentario, s_diacorte,
                   s_divisa, s_ingreso
            WITH RESUME;
        END FOREACH;
    END IF;
END;
	END PROCEDURE;