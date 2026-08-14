CREATE PROCEDURE "informix".determina_udi_rango(pEmpresa CHAR(3),
                                                pFecha_ini   DATE,
                                                pFecha_fin   DATE)
RETURNING CHAR(5) AS retorno,
          DECIMAL(14,6) AS valor_udi;
--------------------------------------------------------------------------------
-- Modificó: Viridiana Osobampo
-- Descripción: Se valida que la información de fechas recibidas sea correcta.
--        La fecha inicial no debe ser mayor que la fecha final y la fecha final 
--        no debe ser mayor a la fecha actual.
-- Fecha de modificación: 09-10-2009
-- Petición: Préstamo Personal.
--------------------------------------------------------------------------------
-- Modificó: Viridiana Osobampo
-- Descripción: Se modifica para que al obtener el valor2 de la udi, primero busque
--              en la tabla si_tpcambio y si no encontró información buscar en la
--              si_histdiv, tal como se hace al obtener el valor inicial.
-- Fecha de modificación: 22-01-2010
-- Petición: Préstamo Personal.
--------------------------------------------------------------------------------

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************

   DEFINE cod_ret		CHAR(5);
   DEFINE sql_err       SMALLINT;
   DEFINE isam_err      SMALLINT;
   DEFINE error_info    CHAR(40);
   DEFINE vValor1       DECIMAL(14,6);
   DEFINE vValor2       DECIMAL(14,6);
   DEFINE vPrecio       DECIMAL(14,6);
   DEFINE vFechaPaso    DATE;
   DEFINE vDivUdi       CHAR(2);
   DEFINE vClaseUdi     CHAR(1);
   DEFINE dtFechaHoy    DATE;

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
BEGIN

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      RETURN cod_ret, vPrecio;
   END EXCEPTION;

 --SET DEBUG FILE TO "/pisa/cas/determina_udi_rango.out";
 --TRACE ON;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
   LET cod_ret    	= "000";
   LET vValor1   	= 0;
   LET vValor2   	= 0;
   LET vPrecio   	= 0;
   LET vFechaPaso 	= "";
   LET dtFechaHoy   = DATE(1);

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

    -- Valida que se proporcionen los parámetros de entrada
   IF NVL(pEmpresa,'')= '' OR NVL(pFecha_ini,'')= '' OR NVL(pFecha_fin,'')= '' THEN
       LET cod_ret = '902';
       RETURN cod_ret, NVL(vPrecio,0);
   END IF;

    -- valida que la fecha ini no sea mayor que la fecha fin
   IF pFecha_ini > pFecha_fin THEN
       LET cod_ret = '903';
       RETURN cod_ret, NVL(vPrecio,0);  
   END IF; 

   -- Valida que la fecha fin no sea mayor que la fecha actual
   SELECT fecha_hoy
     INTO dtFechaHoy
     FROM bdicred:sd_fechas;

   IF pFecha_fin > dtFechaHoy THEN
       LET cod_ret = '904';
       RETURN cod_ret, NVL(vPrecio,0);
   END IF;

      -- ******************************************
      -- Extrae Parametro de Codigo de Divisa UDI *
      -- ******************************************
   SELECT TRIM(valor) 
     INTO vDivUdi
     FROM bdinteg:si_param
    WHERE empresa = pEmpresa
      AND cod_param = 16;

      -- *****************************************
      -- Extrae Clase de Tipo de Cmabio para UDI *
      -- *****************************************
   SELECT TRIM(valor) 
     INTO vClaseUdi
     FROM sd_param
    WHERE empresa = pEmpresa
      AND cod_param = "336";

      -- **************
      -- Precio Inicio*
      -- **************    
   SELECT precio_compra 
     INTO vValor1
     FROM bdinteg:si_tpcambio
    WHERE empresa = pEmpresa
      AND divisa = vDivUdi
      AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
                              FROM bdinteg:si_tpcambio
                             WHERE empresa = pEmpresa
                               AND divisa = vDivUdi
                               AND fecha_tpcambio = pFecha_fin)
      AND hora_tpcambio=(SELECT MAX(hora_tpcambio)
                           FROM bdinteg:si_tpcambio
                          WHERE empresa = pEmpresa
                            AND divisa = vDivUdi
                            AND fecha_tpcambio = pFecha_fin)
      AND clase_tpcambio = vClaseUdi;

       IF vValor1 IS NULL THEN

           SELECT precio_compra 
             INTO vValor1
             FROM bdinteg:si_histdiv
            WHERE empresa = pEmpresa
              AND divisa = "09"
              AND fecha_tc = (SELECT MAX(fecha_tc)
                                FROM bdinteg:si_histdiv
                               WHERE empresa = pEmpresa
                                 AND divisa = "09"
                                 AND fecha_tc = pFecha_fin)
              AND hora_tc=(SELECT MAX(hora_tc)
                             FROM bdinteg:si_histdiv
                            WHERE empresa = pEmpresa
                              AND divisa = "09"
                              AND fecha_tc = pFecha_fin)
              AND clase_tpcambio = vClaseUdi;

           IF vValor1 IS NULL THEN
               LET cod_ret = "900";
               RETURN cod_ret, vPrecio;
           END IF;

        END IF;

            -- *************
            -- Precio Final*
            -- *************
   SELECT precio_compra 
     INTO vValor2
     FROM bdinteg:si_tpcambio
    WHERE empresa = pEmpresa
      AND divisa = vDivUdi
      AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
                              FROM bdinteg:si_tpcambio
                             WHERE empresa = pEmpresa
                               AND divisa = vDivUdi
                               AND fecha_tpcambio = pFecha_ini)
      AND hora_tpcambio=(SELECT MAX(hora_tpcambio)
                           FROM bdinteg:si_tpcambio
                          WHERE empresa = pEmpresa
                            AND divisa = vDivUdi
                            AND fecha_tpcambio = pFecha_ini)
      AND clase_tpcambio = vClaseUdi;

      IF vValor2 IS NULL THEN

           SELECT precio_compra 
             INTO vValor2
             FROM bdinteg:si_histdiv
            WHERE empresa = pEmpresa
              AND divisa = "09"
              AND fecha_tc = (SELECT MAX(fecha_tc)
                                FROM bdinteg:si_histdiv
                               WHERE empresa = pEmpresa
                                 AND divisa = "09"
                                 AND fecha_tc = pFecha_ini)
              AND hora_tc=(SELECT MAX(hora_tc)
                           FROM bdinteg:si_histdiv
                           WHERE empresa = pEmpresa
                           AND divisa = "09"
                           AND fecha_tc = pFecha_ini)  
              AND clase_tpcambio = vClaseUdi;

           IF vValor2 IS NULL THEN
               LET cod_ret = "901";
               RETURN cod_ret, vPrecio;
           END IF
      END IF;

           LET vPrecio = (vValor1 / vValor2);

       IF vPrecio > 1 THEN
           LET vPrecio =  vPrecio -1;
       ELSE
           LET vPrecio = 0;
       END IF;
END
       RETURN cod_ret, vPrecio;
END PROCEDURE 
DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".cons_tarjeta_credcte(o_empresa CHAR(3),o_tarjeta CHAR(20))
RETURNING CHAR(5), CHAR(20), CHAR(20), CHAR(1), CHAR(1);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE sql_err      SMALLINT;
DEFINE isam_err     SMALLINT;
DEFINE error_info   CHAR(100);
DEFINE vcredito     CHAR(20);
DEFINE vcliente     CHAR(20);
DEFINE vStatus      CHAR(1);
DEFINE vTipoTarjeta CHAR(1);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET vcredito     = "";
LET vcliente     = "";
LET vStatus      = "";
LET vTipoTarjeta = "";

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "cons_cred_tarjeta.err";
   --   TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET scod_ret = sql_err;
      RETURN scod_ret, vcredito, vcliente, vStatus, vTipoTarjeta;
   END EXCEPTION;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************


	-- ****************************
	-- Extrae Datos de la Tarjeta *
	-- ****************************

    SELECT num_credito, numcte, status_tar, tipo_tarjeta
    INTO vcredito, vcliente, vStatus, vTipoTarjeta
          FROM sd_tarjeta
	 WHERE empresa = o_empresa AND
	       num_tarjeta = o_tarjeta;
	       -- status_tar = "A"; Jom INI

	IF vcredito is null THEN
	   let vcredito = "";
	   let scod_ret = "100";
       RETURN scod_ret, vcredito, vcliente, vStatus, vTipoTarjeta;
	END IF

END
    RETURN scod_ret, vcredito, vcliente, vStatus, vTipoTarjeta;
END PROCEDURE
DOCUMENT
    'DESCRIPCION: Consulta el datos de una tarjeta en especifico',
    'DESCRIPCION DEL CAMBIO: Se agrea el tipo de tarjeta y el estatus al retorno del sp',
    'AUTOR CAMBIO: RRRR',
    'VERSION: 20091019.1616',
    'BD: BDICRED',
    'UTILIZADO POR: CONEDOCR.exe';

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
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE s_numsol     CHAR(20);
DEFINE s_numcte     CHAR(20);
DEFINE s_nombre     CHAR(110);
DEFINE s_fechaaut   DATE;
DEFINE  s_fechasol  DATE;
DEFINE s_linea      MONEY(14,2);
DEFINE s_status     CHAR(2);
DEFINE s_stdesc     CHAR(50);
DEFINE s_comentario CHAR(255);
DEFINE s_rfc        CHAR(15);
DEFINE s_diacorte   CHAR(2);
DEFINE s_divisa     CHAR(2);
DEFINE s_ingreso    MONEY(14,2);
DEFINE v_cuantos    SMALLINT;
DEFINE vfecha_hoy   DATE;
DEFINE vdias_rt     SMALLINT;
DEFINE vdias_at     SMALLINT;
DEFINE vdias_vigencia SMALLINT;
--jom ini
DEFINE r_social          CHAR(40);
DEFINE nombre1           CHAR(40);
DEFINE nombre2           CHAR(40);
DEFINE apellidopaterno   CHAR(40);
DEFINE apellidomaterno   CHAR(40);
DEFINE s_eval_min      DECIMAL(10,2);
DEFINE s_eval_max      DECIMAL(10,2);
--jom fin

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET s_nombre     = "??????????";
LET s_numcte     = "??????????";
LET s_fechaaut   = "";
LET s_fechasol   = "";
LET s_status     = "??";
LET s_numsol     = "??????????";
LET s_comentario = "??????????";
LET s_stdesc     = "??????????";
LET s_rfc        = "??????????";
LET s_linea      = 0;
LET s_diacorte   = "20";
LET s_divisa     = "??";
LET v_cuantos    = 0;
LET vfecha_hoy   = "";
LET vdias_rt     = 0;
LET vdias_at     = 0;
LET vdias_vigencia = 0;
LET s_ingreso    = 0;
-- jom ini
LET r_social         = "";
LET nombre1          = "";
LET nombre2          = "";
LET apellidopaterno  = "";
LET apellidomaterno  = "";
LET s_eval_min      = 0;
LET s_eval_max      = 0;
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

set isolation to dirty read;
set lock mode to wait 3;

   -- Carga la Fecha del Dia

   SELECT {+INDEX(sd_fechas idx_sdfechas)} fecha_hoy
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
    INTO s_eval_max
    FROM bdisolic:ss_scoring_solic 
    where seccion = 2;

    SELECT {+INDEX(bdisolic:ss_scoring_solic idx_ss_scoring_solic)} evaluacion_min
    INTO s_eval_min
    FROM bdisolic:ss_scoring_solic 
    where seccion = 4;

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
               TRIM(NVL(f.comentario, ' ')) || ' ' ||
               TRIM(NVL(g.motivo_cc, ' ')) comentario,
               h.divisa, NVL(g.ingreso_mensual, 0)
--            INTO s_numsol, s_numcte, s_nombre, s_rfc, s_fechaaut, s_linea,
            INTO s_numsol, s_numcte, r_social, nombre1, nombre2, apellidopaterno, apellidomaterno, s_rfc, s_fechasol, s_fechaaut, 
		s_linea, s_status, s_stdesc, s_comentario, s_divisa, s_ingreso
          FROM ss_solicitudes a INNER JOIN bdinteg:si_cliente b ON b.numcte = a.numcte
                       INNER JOIN ss_anexosol c ON c.empresa = a.empresa AND c.num_solicitud = a.num_solicitud
                       INNER JOIN ss_status_sol e ON e.empresa = a.empresa AND e.status_solicitud = a.status_solicitud
                       INNER JOIN ss_resum_scor_fin g ON g.empresa = a.empresa AND g.num_solicitud = a.num_solicitud
                       INNER JOIN bdicred:sd_definicion h ON h.empresa = a.empresa AND h.num_producto = a.num_producto
                       LEFT JOIN ss_autorizacion f ON f.empresa = a.empresa AND f.num_solicitud = a.num_solicitud
                       AND f.status_solicitud = a.status_solicitud
--         WHERE a.empresa = o_empresa
           where a.sucursal = o_sucursal
--           AND a.status_solicitud NOT IN ('PC','AP','AN',"CA","CR")
             and a.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA')
           AND NVL(f.fecha_entrada,CURRENT YEAR TO DAY) = (SELECT NVL(MAX(NVL(fecha_entrada,CURRENT YEAR TO DAY)),CURRENT YEAR TO DAY)
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
        END IF

        LET s_status = s_status;



  -- Consulta para  hacer las validaciones de acuerdo al RQM 09 075

     IF s_status = "RT" THEN
            
           IF EXISTS (SELECT {+INDEX(bdisolic:ss_resumen_scoring empsolres)} 1
                     FROM bdisolic:ss_solicitudes b,
                        bdisolic:ss_resum_scor_fin c,
                        bdisolic:ss_resumen_scoring e,
                        bdisolic:ss_detalle_scoring d,
                        bdisolic:ss_detalle_scoring f,
                        bdinteg:si_cliente a
                    WHERE b.num_solicitud = s_numsol
                        AND (c.num_solicitud = b.num_solicitud and c.meses_historia <= 13 and c.evalua_cc<>'1')
                        AND ( d.num_solicitud = b.num_solicitud and d.grupo = 7 and d.elemento  in(9, 11))
                        AND ( f.num_solicitud = b.num_solicitud and f.grupo = 14 and f.elemento =2)
                        AND a.numcte = b.numcte
                        AND e.num_solicitud = b.num_solicitud
                    GROUP BY 1
                    HAVING SUM(e.evaluacion) BETWEEN s_eval_min AND s_eval_max) THEN

                    LET s_comentario = 'Solicitar al cliente un comprobante de ingresos';
            END IF;
        END IF;



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
               TRIM(NVL(f.comentario, ' ')) || ' ' ||
               TRIM(NVL(g.motivo_cc, ' ')) comentario,
               h.divisa, NVL(g.ingreso_mensual, 0)
--            INTO s_numsol, s_numcte, s_nombre, s_rfc, s_fechaaut, s_linea,
            INTO s_numsol, s_numcte, r_social, nombre1, nombre2, apellidopaterno, apellidomaterno, s_rfc, s_fechasol, s_fechaaut, 
	       s_linea, s_status, s_stdesc, s_comentario, s_divisa, s_ingreso
          FROM ss_solicitudes a INNER JOIN bdinteg:si_cliente b ON b.numcte = a.numcte
                       INNER JOIN ss_anexosol c ON c.empresa = a.empresa AND c.num_solicitud = a.num_solicitud
                       ---INNER JOIN ss_status_sol e ON e.empresa = a.empresa AND e.status_solicitud = a.status_solicitud
                       INNER JOIN ss_status_sol e ON e.status_solicitud = a.status_solicitud
                       INNER JOIN ss_resum_scor_fin g ON g.empresa = a.empresa AND g.num_solicitud = a.num_solicitud
                       INNER JOIN bdicred:sd_definicion h ON h.empresa = a.empresa AND h.num_producto = a.num_producto
                       LEFT JOIN ss_autorizacion f ON f.empresa = a.empresa AND f.num_solicitud = a.num_solicitud
                       AND f.status_solicitud = a.status_solicitud
--         WHERE a.empresa = o_empresa
--           where a.sucursal = o_sucursal
           WHERE a.numcte = o_numcte
 --          AND a.status_solicitud NOT IN ('PC','AP','AN',"CA","CR")
             and a.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA')
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

     IF s_status = "RT" THEN
            
           IF EXISTS (SELECT {+INDEX(bdisolic:ss_resumen_scoring empsolres)} 1
                     FROM bdisolic:ss_solicitudes b,
                        bdisolic:ss_resum_scor_fin c,
                        bdisolic:ss_resumen_scoring e,
                        bdisolic:ss_detalle_scoring d,
                        bdisolic:ss_detalle_scoring f,
                        bdinteg:si_cliente a
                    WHERE b.num_solicitud = s_numsol
                        AND (c.num_solicitud = b.num_solicitud and c.meses_historia <= 13 and c.evalua_cc<>'1')
                        AND ( d.num_solicitud = b.num_solicitud and d.grupo = 7 and d.elemento  in(9, 11))
                        AND ( f.num_solicitud = b.num_solicitud and f.grupo = 14 and f.elemento =2)
                        AND a.numcte = b.numcte
                        AND e.empresa = o_empresa 
                        AND e.num_solicitud = b.num_solicitud
                    GROUP BY 1
                    HAVING SUM(e.evaluacion) BETWEEN s_eval_min AND s_eval_max) THEN

                    LET s_comentario = 'Solicitar al cliente un comprobante de ingresos';
            END IF;
        END IF;



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