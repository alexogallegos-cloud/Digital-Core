CREATE PROCEDURE "informix".envia_monitorsol(o_empresa     CHAR(3),
                                                      o_sucursal    CHAR(20),
                                                      o_solicitudes SMALLINT,
                                                      o_numcte      CHAR(20))
RETURNING CHAR(5),  -- Codigo de Retorno
          CHAR(20), -- Nro de Solicitud
          CHAR(20), -- Nro de Cliente
          CHAR(120),    -- Nombre del Cliente
          CHAR(15),     -- R.F.C.
          DATE,         -- Fecha de Solicitud
          DATE,         -- Fecha Autorizacion
          MONEY(14,2),  -- Linea Otorgada
          CHAR(2),      -- Status de la Solicitud
          CHAR(60),     -- Descripcion del Status de la Solicitud
          CHAR(255),    -- Comentario
          CHAR(2),      -- Dia de Corte
          CHAR(2),      -- Divisa
          MONEY(14,2),  -- Ingreso del Cliente
          CHAR(3),      -- Causa de solicitud
          CHAR(100),    -- Descripción de la causa de solicitud
		  INTEGER;      --Dias de vigencia de la solicitud en su ultimo estatus

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
DEFINE s_motivo			CHAR(100);
DEFINE s_rfc            CHAR(15);
DEFINE s_diacorte       CHAR(2);
DEFINE s_divisa         CHAR(2);
DEFINE iTipo_Auto		INTEGER;
DEFINE s_ingreso        MONEY(14,2);
DEFINE v_cuantos        SMALLINT;
DEFINE vfecha_hoy       DATE;
DEFINE vdias_rt         SMALLINT;
DEFINE vdias_at         SMALLINT;
DEFINE vdias_vigencia   INTEGER;
--jom ini
DEFINE r_social          CHAR(40);
DEFINE nombre1           CHAR(40);
DEFINE nombre2           CHAR(40);
DEFINE apellidopaterno   CHAR(40);
DEFINE apellidomaterno   CHAR(40);
DEFINE s_eval_min        DECIMAL(10,2);
DEFINE s_eval_max        DECIMAL(10,2);
--jom fin
define sinicio           INTEGER;
DEFINE cCausaSol         CHAR(3);
DEFINE vDescCausaSol     CHAR(100);

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
--*************************************************************************************
--ACTIVIDAD: Se agregan dos parámetros de retornos: uno para la causa de solicitud y otro
--           para la descipción de dicha causa.
--FECHA: 28/04/2010.
--AUTOR: Viridiana Osobampo Aguilar
--*************************************************************************************
--ACTIVIDAD: Se modifica el tipo de dato para la variable de retorno de la descripción
--            para Causa de estatus de solicitud.
--FECHA: 21/05/2010.
--AUTOR: Viridiana Osobampo Aguilar
--*************************************************************************************
--ACTIVIDAD: Se modifica para omitir el retorno para el comentario.
--FECHA: 02/06/2010.
--AUTOR: Mohamed Carreón
--*************************************************************************************
--ACTIVIDAD: Se modifica para  obtener el total de dias transcurridos de la solicitud con su estatus actual.
--FECHA: 04/03/2011.
--AUTOR: Héctor Manuel Bojórquez Ruelas.
--*************************************************************************************
-- ACTIVIDAD: Se modifica para  Agregar al spl envia_monitorsol las solicitudes en estatus CM con causa (CMC,CME,CVE,CEV) para mostrar en el monitor de solicitudes de sucursal OFI las solicitudes en estatus CM con causa (CMC, CME, CVE, CEV).
--Eliminar del spl envia_monitorsol el procesamiento de las solicitudes en estatus  CN.
-- FECHA: 05/09/2011.
-- AUTOR: Paul Ivan Quintero Varela / Jesus Manuel Aguilar Heredia
-- Petición o RQM asociado: RQM 09 211-2 Adendum CEV Cancelación MC por eventualidades
--*************************************************************************************
--ACTIVIDAD: Se modifica para  contemplar el status LC de las solicitudes.
--FECHA: 25/11/2011.
--AUTOR: Héctor Manuel Bojórquez Ruelas.
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
LET s_motivo		 = "";
LET s_stdesc         = "??????????";
LET s_rfc            = "??????????";
LET s_linea          = 0;
LET s_diacorte       = "20";
LET s_divisa         = "??";
LET iTipo_Auto		 = 0;
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
LET sinicio          = 0;
LET cCausaSol        = "";
LET vDescCausaSol    = "";

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut,
             s_linea, s_status, s_stdesc, s_comentario, s_diacorte, s_divisa,
             s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia;
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


--SET DEBUG FILE TO '/tmp/envia_monitorsol.out';
--TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

   -- Carga la Fecha del Dia
   SELECT {+INDEX(bdicred:"informix".sd_fechas idx_sdfechas)} fecha_hoy
     INTO vfecha_hoy
     FROM bdicred:"informix".sd_fechas
    WHERE empresa = o_empresa;

   -- Carga Parametro de Dias de Vigencia de Rechazadas
   SELECT {+INDEX(bdisolic:"informix".ss_param idx_ss_param)} valor
     INTO vdias_rt
     FROM bdisolic:"informix".ss_param
    WHERE empresa = o_empresa and
          secuencia = 20;

   IF vdias_rt IS NULL THEN
      LET scod_ret = "117";
      RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut,
                s_linea, s_status, s_stdesc, s_comentario, s_diacorte, s_divisa,
                s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia;
   END IF

    SELECT {+INDEX(bdisolic:"informix".ss_scoring_solic idx_ss_scoring_solic)} evaluacion_min
    INTO s_eval_min
    FROM bdisolic:"informix".ss_scoring_solic
    WHERE empresa = o_empresa AND tp_solicitud = 'T'
    AND seccion = 4 AND tpo_persona = '01' AND activa = '0';

    SELECT {+INDEX(bdisolic:"informix".ss_scoring_solic idx_ss_scoring_solic)} evaluacion_min
    INTO s_eval_max
    FROM bdisolic:"informix".ss_scoring_solic
    WHERE empresa = o_empresa
      AND seccion = 2
    AND tp_solicitud = 'T'
    AND tpo_persona = '01' AND activa = '0';

 /*
    SELECT {+INDEX(bdisolic:"informix".ss_scoring_solic idx_ss_scoring_solic)} evaluacion_min
    INTO s_eval_max
    FROM bdisolic:"informix".ss_scoring_solic
    WHERE empresa = o_empresa  AND tp_solicitud = 'T'
      AND seccion = 2   AND tpo_persona = '01' AND activa = '0' ; */

   -- Carga Parametro de Dias de Vigencia de Autolrizadas

   SELECT {+INDEX(bdisolic:"informix".ss_param idx_ss_param)} valor
     INTO vdias_at
     FROM bdisolic:"informix".ss_param
    WHERE empresa = o_empresa AND
          secuencia = 21;

    IF vdias_at IS NULL THEN
        LET scod_ret = "118";
        RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut,
                s_linea, s_status, s_stdesc, s_comentario, s_diacorte, s_divisa,
                s_ingreso,cCausaSol,vDescCausaSol, vdias_vigencia;
    END IF;

--    let sinicio = o_solicitudes - 10;
--    if (sinicio < 0) then let sinicio = 0; end if;

    IF o_numcte IS NULL OR o_numcte = "" THEN
--jom ini
        FOREACH
        SELECT {+INDEX(bdisolic:"informix".ss_solicitudes idx_ss_solicitudes2)} skip o_solicitudes LIMIT 11
               a.num_solicitud,
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
               NVL(f.causa_solicitud,""),
               NVL(i.descripcion,""),
	   		   TRIM(NVL(SUBSTR(f.comentario,1,155), ' ')) comentario,
--			   TRIM(NVL(g.motivo_cc, ' ')),
			   h.divisa, NVL(g.ingreso_mensual, 0),
			   i.tipo_auto
--            INTO s_numsol, s_numcte, s_nombre, s_rfc, s_fechaaut, s_linea,
          INTO s_numsol, s_numcte, r_social, nombre1, nombre2, apellidopaterno, apellidomaterno, s_rfc, s_fechasol,
               s_fechaaut, s_linea, s_status, s_stdesc, cCausaSol,vDescCausaSol,s_comentario, s_divisa, s_ingreso, iTipo_Auto
          FROM bdisolic:"informix".ss_solicitudes a
          JOIN bdinteg:"informix".si_cliente b ON (b.numcte = a.numcte)
          LEFT OUTER JOIN bdisolic:"informix".ss_autorizacion f ON (f.empresa = a.empresa AND f.num_solicitud = a.num_solicitud
                                                     AND f.status_solicitud = a.status_solicitud)
--        INNER JOIN ss_anexosol c ON c.empresa = a.empresa AND c.num_solicitud = a.num_solicitud
          LEFT OUTER JOIN bdisolic:"informix".ss_causas_sol i ON (i.empresa = f.empresa AND i.status_solicitud = f.status_solicitud
                                                                      AND i.causa_solicitud = f.causa_solicitud)
          JOIN bdisolic:"informix".ss_status_sol e ON (e.status_solicitud = a.status_solicitud)
          JOIN bdisolic:"informix".ss_resum_scor_fin g ON (g.empresa = a.empresa AND  g.num_solicitud = a.num_solicitud)
          JOIN bdicred:"informix".sd_definicion h ON (h.num_producto = a.num_producto AND h.empresa = a.empresa)
          WHERE a.empresa = o_empresa
            AND a.sucursal = o_sucursal
            AND a.num_producto IN ('6001','6600')
            AND a.status_solicitud IN ('CC','BC','OS','EE','OA','EA','CE','AT','RT','ST','CM','LC')
--                or (a.status_solicitud = 'RT' and a.fecha_insert >= (select today - (valor+0) from ss_param where empresa = a.empresa and secuencia = 20))
--                or (a.status_solicitud = 'AT' and a.fecha_insert >= (select today - (valor+0) from ss_param where empresa = a.empresa and secuencia = 21)))
            AND NVL(f.fecha_entrada,CURRENT YEAR TO DAY) = (SELECT {+INDEX(bdisolic:"informix".ss_autorizacion empsolsta)} NVL(MAX(NVL(fecha_entrada,CURRENT YEAR TO DAY)),CURRENT YEAR TO DAY)
                                                             FROM bdisolic:"informix".ss_autorizacion h
                                                            WHERE h.empresa = a.empresa
                                                              AND h.num_solicitud=a.num_solicitud
                                                              AND h.status_solicitud = a.status_solicitud)
        ORDER BY nombre, nombre2, paterno, materno, fecha_entrada
--jom fin
         
         LET s_nombre = TRIM(NVL(nombre1,"")) || " " || TRIM(NVL(nombre2,"")) || " " || TRIM(NVL(apellidopaterno,"")) || " " || TRIM(NVL(apellidomaterno,""));

--Hector Bojorquez
--Total de dias transcurridos de la solicitud con el status actual..

		IF s_fechaaut IS NULL THEN
        	LET s_fechaaut = DATE(1);
		END IF;

		LET vdias_vigencia = vfecha_hoy - s_fechaaut;

        IF s_status <> "AT" THEN
            LET s_fechaaut = "";
            LET s_linea = 0;
        END IF

		--En caso de no ser RT y tratada por el CAC se concatena comentario y motivo 
		--en caso de que sea RT Y tratada por el CAC solo se regresara comentario.
		IF s_status = "RT" AND iTipo_Auto = 2 THEN
			IF SUBSTR(s_comentario,15, 4) = "Mesa" THEN
				LET s_comentario = 'Rechazada por Mesa de Control';
				END IF;
			IF SUBSTR(s_comentario,15, 3) = "CAC" THEN
					LET s_comentario = 'Rechazada por Mesa de Control';
			END IF;
			IF SUBSTR(s_comentario,1, 2) = "RT" THEN
					LET s_comentario = 'Rechazada por Mesa de Control' ;
			END IF;
					
		END IF;

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
            FROM bdisolic:"informix".ss_autorizacion
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
                FROM bdisolic:"informix".ss_autorizacion
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

		--        LET v_cuantos = v_cuantos + 1;
		--        IF v_cuantos <= o_solicitudes THEN
		--            CONTINUE FOREACH;
		--        END IF;

        RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut,
                s_linea, s_status, s_stdesc, s_comentario, s_diacorte, s_divisa,
                s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia WITH RESUME;
        END FOREACH;
    ELSE
         FOREACH
        SELECT a.num_solicitud,
               a.numcte,
			   --            TRIM(NVL(b.razon_social,' ')) ||
			   --            TRIM(NVL(b.nombre1, ' ')) || ' ' ||
			   --            TRIM(NVL(b.nombre2, ' ')) || ' ' ||
			   --            TRIM(NVL(b.apell_paterno, ' ')) || ' ' ||
			   --            TRIM(NVL(b.apell_materno, ' ')) nombre, b.rfc,
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
               e.descripcion,
               NVL(f.causa_solicitud,""),
               NVL(i.descripcion,""),
			   TRIM(NVL(SUBSTR(f.comentario,1,155), ' ')) comentario,
--			   TRIM(NVL(g.motivo_cc, ' ')) ,
			   h.divisa, NVL(g.ingreso_mensual, 0),
			   i.tipo_auto
--            INTO s_numsol, s_numcte, s_nombre, s_rfc, s_fechaaut, s_linea,
          INTO s_numsol, s_numcte, r_social, nombre1, nombre2, apellidopaterno, apellidomaterno, s_rfc, s_fechasol, 
               s_fechaaut, s_linea, s_status, s_stdesc, cCausaSol,vDescCausaSol,s_comentario, s_divisa, s_ingreso, iTipo_Auto
          FROM bdisolic:"informix".ss_solicitudes a INNER JOIN bdinteg:"informix".si_cliente b ON (b.numcte = a.numcte )
               INNER JOIN bdisolic:"informix".ss_anexosol c ON c.empresa = a.empresa AND c.num_solicitud = a.num_solicitud
               INNER JOIN bdisolic:"informix".ss_status_sol e ON (e.empresa = a.empresa AND e.status_solicitud = a.status_solicitud)
               INNER JOIN bdisolic:"informix".ss_resum_scor_fin g ON (g.empresa = a.empresa AND g.num_solicitud = a.num_solicitud)
               INNER JOIN bdicred:"informix".sd_definicion h ON (h.empresa = a.empresa AND h.num_producto = a.num_producto)
               LEFT JOIN bdisolic:"informix".ss_autorizacion f ON (f.empresa = a.empresa AND f.num_solicitud = a.num_solicitud
                                               AND f.status_solicitud = a.status_solicitud)
               LEFT OUTER JOIN bdisolic:"informix".ss_causas_sol i ON (i.empresa = f.empresa
                                               AND i.status_solicitud = f.status_solicitud
                                               AND i.causa_solicitud = f.causa_solicitud)
--         WHERE a.empresa = o_empresa
--           where a.sucursal = o_sucursal
           WHERE a.empresa = o_empresa
             AND a.numcte = o_numcte
             AND a.num_producto = '6001'
             AND a.status_solicitud IN ('CC','BC','OS','EE','OA','EA','CE','AT','RT','ST','CM','LC')
             AND NVL(f.fecha_entrada,CURRENT) = (SELECT NVL(MAX(NVL(fecha_entrada,CURRENT)),CURRENT)
                                                   FROM bdisolic:"informix".ss_autorizacion h
                                                  WHERE h.empresa = a.empresa
                                                    AND h.num_solicitud=a.num_solicitud
                                                    and h.status_solicitud = a.status_solicitud)
	--jom ini
	--           and ((NVL(f.fecha_entrada,CURRENT) >= (select today - (valor+0) from ss_param where empresa = '001' and secuencia = 20) and a.status_solicitud = 'RT')
	--                  or
	--                (NVL(f.fecha_entrada,CURRENT) >= (select today - (valor+0) from ss_param where empresa = '001' and secuencia = 21) and a.status_solicitud = 'AT')
	--                  or
	--                (a.status_solicitud not in ('AT','RT')))
	--jom fin
         ORDER BY nombre, nombre2, paterno, materno, fecha_entrada

         LET s_nombre = TRIM(NVL(nombre1,"")) || " " || TRIM(NVL(nombre2,"")) || " " || TRIM(NVL(apellidopaterno,"")) || " " || TRIM(NVL(apellidomaterno,""));

		--Total de dias transcurridos de la solicitud con el status actual..
		IF s_fechaaut IS NULL THEN
        	LET s_fechaaut = DATE(1);
		END IF;

		LET vdias_vigencia = vfecha_hoy - s_fechaaut;

            IF s_status <> "AT" THEN
                LET s_fechaaut = "";
                LET s_linea = 0;
            END IF;

			--En caso de no ser RT y tratada por el CAC se concatena comentario y motivo 
			--en caso de que sea RT Y tratada por el CAC solo se regresara comentario.
		    IF s_status = "RT" AND iTipo_Auto = 2 THEN
				IF SUBSTR(s_comentario,15, 4) = "Mesa" THEN
					LET s_comentario = 'Rechazada por Mesa de Control';
				END IF;
				IF SUBSTR(s_comentario,15, 3) = "CAC" THEN
					LET s_comentario = 'Rechazada por Mesa de Control';
				END IF;
				IF SUBSTR(s_comentario,1, 2) = "RT" THEN
					LET s_comentario = 'Rechazada por Mesa de Control';
				END IF;
					
			END IF;

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

        {
             IF s_status = "RT" THEN
                SELECT vfecha_hoy - MAX(fecha_entrada)
                INTO vdias_vigencia
                FROM bdisolic:"informix".ss_autorizacion
                WHERE num_solicitud =  s_numsol 
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
                    FROM bdisolic:"informix".ss_autorizacion
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
                s_linea, s_status, s_stdesc, s_comentario, s_diacorte, s_divisa,
                s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia WITH RESUME;
        END FOREACH;
    END IF;
END;
END PROCEDURE
