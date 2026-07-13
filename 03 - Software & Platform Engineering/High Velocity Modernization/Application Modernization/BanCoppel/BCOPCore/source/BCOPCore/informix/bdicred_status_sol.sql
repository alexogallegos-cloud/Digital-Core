create procedure "informix".status_sol(
                pempresa     CHAR(3),
                psucursal    CHAR(4),
                pfechafin    DATE,
                pfechaini    DATE,
                pstatus      CHAR(2))

RETURNING CHAR(5),       -- Codigo de Retorno
          CHAR(20),      -- Nro de Solicitud
          CHAR(4),       -- Sucursal
          CHAR(40),      -- Nombre Sucursal
          CHAR(104),     -- Nombre del Cliente
          CHAR(2),       -- Status Solicitud
          MONEY(14,2),   -- Monto Solicitud
		  MONEY(14,2),   -- Monto otorgado
          DATE,          -- Fecha Alta
          DATE,          -- Fecha Cambio Status
          DECIMAL(10,4), -- Eficiencia de Pago
          SMALLINT,      -- Meses de Historia
          SMALLINT,      -- Scoring 1
          SMALLINT,      -- Scoring 2
          SMALLINT,      -- Total Scoring
          CHAR(10);      -- Causa de Rechazo

--Juan Andrès Coronel M
--21/12/2007
--Se modifica para que devuelva la causa de rechazo de la solicitud.
--Se unifica el còdigo para hacer un solo select de los 4 que existian en la versiòn previa.
--Se agrega validaciòn para que si los parametros de psucursal y pstatus vienen vacìo o null, el sp pueda devolver datos con ambos valores.


--Roque Enrique Solis Campaña
--28/10/2008
--se agrego el campo monto otorgado para incluirse en el reporte RStatusSol.rpt
--se realizo la consulta para obtener el campo monto otorgado

--Julio Cesar Polanco Inzunza
--04/03/2009
--Se modifica para contemplar los cambios en la tabla ss_scoring_solic
-- para que solo contemple los registros antes de caja unica campo activa = 0

--*************************************************************************
--                         DEFINICION DE VARIABLES
--*************************************************************************
DEFINE scod_ret        CHAR(5);
DEFINE vsqlerr         INTEGER;
DEFINE s_numsol        CHAR(20);
DEFINE s_sucursal      CHAR(4);
DEFINE s_nomsuc        CHAR(40);
DEFINE s_status        CHAR(2);
DEFINE s_monto         MONEY(14,2);
DEFINE s_monto_aut     MONEY(14,2);
DEFINE s_nombrecte     CHAR(104);
DEFINE s_nombre1       CHAR(26);
DEFINE s_nombre2       CHAR(26);
DEFINE s_apell_paterno CHAR(26);
DEFINE s_apell_materno CHAR(26);
DEFINE s_comentario    VARCHAR(255,1);
DEFINE s_evalua_cc     CHAR(1);
DEFINE s_status_nvo    CHAR(2);



DEFINE s_fecha_sol     DATE;
DEFINE s_fecha_entrada DATE;
DEFINE s_eficiencia    DECIMAL(10,4);
DEFINE s_meses         SMALLINT;
DEFINE s_scoring_1     SMALLINT;
DEFINE s_scoring_2     SMALLINT;
DEFINE s_scoring_total SMALLINT;

DEFINE s_numcte        CHAR(20);
DEFINE v_cuantos       SMALLINT;
DEFINE vfecha_hoy      DATE;
DEFINE s_consulta      SMALLINT;
DEFINE s_causa         char(10);
DEFINE s_eval_min      DECIMAL(10,2);
DEFINE s_eval_max      DECIMAL(10,2);
DEFINE s_eva_min_sup   DECIMAL(5,2);
DEFINE sMesesHis       SMALLINT;


-- *************************************************************************
-- *                        ASIGNACION DE VARIABLES
-- **************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET s_numcte     = "";
LET v_cuantos    = 0;

LET s_numsol        = "";
LET s_sucursal      = "";
LET s_nomsuc        = "";
LET s_status        = "";
LET s_monto         = 0;
LET s_monto_aut     = 0;
LET s_nombrecte     = "";
LET s_nombre1       = "";
LET s_nombre2       = "";
LET s_apell_paterno = "";
LET s_apell_materno = "";
LET s_comentario    = "";
LET s_evalua_cc     = "";
LET s_status_nvo    = "";
LET s_fecha_sol     = "";
LET s_fecha_entrada = "";
LET s_eficiencia    = "";
LET s_meses         = 0;
LET s_scoring_1     = 0;
LET s_scoring_2     = 0;
LET s_scoring_total = 0;
LET s_consulta      = 0;
LET s_causa         = '';
LET s_eval_min      = 0;
LET s_eval_max      = 0;
LET s_eva_min_sup   = 0;
LET sMesesHis       = 0;

-- **********************************************************************
-- *                        CONTROL DE ERRORES
-- ***********************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, s_numsol, s_sucursal, s_nomsuc, s_nombrecte,
         s_status, s_monto, s_monto_aut, s_fecha_sol, s_fecha_entrada,
         s_eficiencia, s_meses, s_scoring_1, s_scoring_2, s_scoring_total, s_causa;
   END IF;
END EXCEPTION;

-- SET DEBUG FILE TO "status_sol.out";
-- TRACE ON;

-- **********************************************************************
-- *                        PROGRAMA PRINCIPAL
-- **********************************************************************


let pempresa = pempresa;
let psucursal = psucursal;
let pfechafin = pfechafin;
let pfechaini  = pfechaini;
let pstatus = pstatus;

   -- Carga la Fecha del Dia

   SELECT fecha_hoy
     INTO vfecha_hoy
     FROM bdicred:sd_fechas
    WHERE empresa = pempresa;

   -- Valida Tipo de Consulta

    If nvl(psucursal, '') = '' then
        Let psucursal = null;
    End if;
    If nvl(pstatus, '') = '' then
        Let pstatus = null;
    End if;

/*
    IF psucursal = "" AND pstatus = "" then
        LET s_consulta = 1;
    ELSE
        IF psucursal <> "" AND pstatus = "" then
            LET s_consulta = 2;
        ELSE
            IF pstatus <> "" AND psucursal = "" then
                LET s_consulta = 3;
            ELSE
                IF psucursal <> "" AND pstatus <> "" then
                    LET s_consulta = 4;
                END IF
            END IF
        END IF
    END IF
*/
    LET s_consulta = 1;

    IF s_consulta = 1 THEN
        FOREACH

        SELECT
            a.num_solicitud, a.sucursal, a.status_solicitud, nvl(a.monto_solicitado,0),
            g.nombre1,g.nombre2,g.apell_paterno,g.apell_materno,
            b.nombre, nvl(a.fecha_insert,date(1)),nvl(d.fecha_entrada,date(1)), nvl(e.situacion_pago,0), nvl(e.meses_historia,0),
--            nvl((select SUM(f.evaluacion) from bdisolic:ss_resumen_scoring f where
--            a.empresa = f.empresa AND a.num_solicitud = f.num_solicitud group by f.num_solicitud),0),
            d.comentario,e.evalua_cc,h.status_nvo
          INTO
            s_numsol,s_sucursal,s_status,s_monto,
            s_nombre1,s_nombre2,s_apell_paterno,s_apell_materno,
            s_nomsuc,s_fecha_sol,s_fecha_entrada,s_eficiencia,s_meses,
--            s_scoring_total,s_comentario,s_evalua_cc,s_status_nvo
            s_comentario,s_evalua_cc,s_status_nvo
        FROM
        (((
            bdisolic:ss_solicitudes a LEFT OUTER JOIN bdinteg:si_sucursales b
            ON a.empresa = b.empresa AND a.sucursal = b.sucursal)
--            LEFT OUTER JOIN bdisolic:ss_anexosol c
--            ON a.empresa = c.empresa AND a.num_solicitud = c.num_solicitud)
            LEFT OUTER JOIN bdisolic:ss_autorizacion d
            ON a.empresa = d.empresa AND a.num_solicitud = d.num_solicitud AND a.status_solicitud = d.status_solicitud
            and fecha_entrada = (select nvl(max(fecha_entrada),today) from bdisolic:ss_autorizacion
            where a.empresa = empresa AND a.num_solicitud = num_solicitud AND a.status_solicitud = status_solicitud ))
            LEFT OUTER JOIN bdisolic:ss_resum_scor_fin e
            ON a.empresa = e.empresa AND a.num_solicitud = e.num_solicitud)
            LEFT OUTER JOIN bdinteg:si_cliente g
            ON a.empresa = g.empresa AND a.numcte = g.numcte
            LEFT OUTER JOIN bdisolic:ss_autorizacion_especial h On a.empresa = h.empresa and a.num_solicitud = h.num_solicitud and h.status_nvo = 'RT'
        WHERE a.empresa = pempresa AND
            (a.fecha_insert >= pfechaini AND a.fecha_insert <= pfechafin) AND
            a.status_solicitud = nvl(pstatus,   a.status_solicitud) AND
            a.sucursal         = nvl(psucursal, a.sucursal)
        ORDER BY a.sucursal, b.nombre ASC


    let s_scoring_total = 0;
---cambio CAS
    LET s_nombrecte=trim(s_nombre1) || ' ' || trim(s_nombre2) || ' ' || trim(s_apell_paterno) || ' ' || trim(s_apell_materno);

    -- Calcula Scoring 2

            SELECT SUM(VALOR)
              INTO s_scoring_2
              FROM bdisolic:ss_detalle_scoring
             WHERE empresa = pempresa AND
                   num_solicitud = s_numsol;

    -- Calcula Scoring 1

            SELECT nvl(sum(nvl(puntuacion,0)),0)
              INTO s_scoring_1
              FROM bdisolic:ss_scoring_financ sf, bdisolic:ss_resum_scor_fin rsf
             WHERE rsf.empresa = pempresa
               and rsf.num_solicitud = s_numsol
               and rsf.empresa = sf.empresa
               and upper(sf.tp_solicitud) = 'T'
               and sf.circulo_credito = evalua_cc
               and sf.min_mes_hist <= rsf.meses_historia
               and sf.max_mes_hist >= rsf.meses_historia
               and sf.min_porc_pago <= rsf.situacion_pago
               and sf.max_porc_pago >= rsf.situacion_pago;

    LET s_scoring_total = s_scoring_1 + s_scoring_2;
--JCP
    SELECT evaluacion_min
      INTO s_eval_max
      FROM bdisolic:ss_scoring_solic
     WHERE empresa = pempresa AND tp_solicitud = 'T'
       AND seccion = 2 AND tpo_persona = '01' AND activa = '0';

    SELECT evaluacion_min
      INTO s_eval_min
      FROM bdisolic:ss_scoring_solic
     WHERE empresa = pempresa AND tp_solicitud = 'T'
       AND seccion = 4 AND tpo_persona = '01' AND activa = '0';

	SELECT evaluacion_min
      INTO s_eva_min_sup
	  FROM bdisolic:ss_scoring_solic
     WHERE empresa = pempresa AND tp_solicitud = 'T'
       AND seccion = 1 AND tpo_persona = '01' AND activa = '0';
--JCP
    SELECT valor INTO sMesesHis
      FROM bdisolic:ss_param
     WHERE empresa = pempresa
       AND secuencia = 308;


    IF  s_status = 'RT' then
        IF (s_scoring_total >= s_eval_min and s_scoring_total <= s_eval_max) or (s_eficiencia >= s_eva_min_sup  and s_eficiencia >= sMesesHis) then
              LET s_causa='CAC';
        ELSE
            IF trim(s_comentario) = 'Resolucion Orden de Supervision' then
                 LET s_causa='OS';
            ELSE
                IF trim(s_evalua_cc) = '1' then
                    LET s_causa='CC';
                ELSE
                    IF  s_scoring_total < s_eval_min then
                         LET s_causa='SC';
                    ELSE
                        IF not s_status_nvo is null then
                            LET s_causa='E';
                        ELSE
                            LET s_causa='OTRO';
                        END IF;
                    END IF;
                END IF;
             END IF;
        END IF;
    ELSE
         LET s_causa='';
    END IF;
---cambio CAS


       -----------------------------MONTO AUTORIZADO--------------------------------
          LET s_monto_aut=0;
		IF   s_status='AT' OR s_status='AP' THEN

		  if exists (SELECT monto_otorgado
			FROM bdicred:sd_maesdos
			where empresa=pempresa and num_credito=s_numsol) then
				SELECT monto_otorgado
					INTO s_monto_aut
					FROM bdicred:sd_maesdos
					where empresa=pempresa and num_credito=s_numsol;
		   end if;
		END IF;


            RETURN scod_ret, s_numsol, s_sucursal, s_nomsuc, s_nombrecte,
                   s_status, s_monto, s_monto_aut, s_fecha_sol, s_fecha_entrada, s_eficiencia,
                   s_meses, s_scoring_1, s_scoring_2, s_scoring_total, s_causa
            WITH RESUME;
        END FOREACH;
    END IF;
END;
END PROCEDURE;