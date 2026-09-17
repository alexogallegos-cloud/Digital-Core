CREATE PROCEDURE "informix".situacion_pago_tienda(o_empresa CHAR(3),
				o_num_cliente    CHAR(20),
				o_producto       CHAR(4),
				o_sucursal       CHAR(4),
				o_ejecutivo      CHAR(8),
				o_porcentaje     DECIMAL(5,2),
				o_situacion      CHAR(1),
				o_causa		 SMALLINT,
				o_num_referencia CHAR(20),
				o_nombre	 CHAR(104),
				o_nombre_coppel  CHAR(104),
				o_meses_hist     SMALLINT,
				o_vencidomuebles INTEGER,
				o_vencidoropa    INTEGER,
				o_vencidoprestamos INTEGER,
				o_abonomuebles	 INTEGER,
				o_abonoropa      INTEGER,
				o_abonoprestamos INTEGER,
				o_saldomuebles   INTEGER,
				o_saldoropa      INTEGER,
				o_saldoprestamos INTEGER)


RETURNING CHAR(5),CHAR(200);

-- Fecha Modificacion:  08/09/2008
-- Autor: Paul Ivan Quintero Varela
-- Descripcion: Se modifica la validacion del vencido de los clientes coppel A- con
--                         eficiencia de pagos entre 75 y 84.9 en Coppel, RQM 09 078.

--************************************************************************
--ACTIVIDAD: Se modifica para que las consultas a la tabla ss_scoring_solic
-- lean los registros antes de caja unica, activa=0.
--FECHA: 23/02/2009
--AUTOR: Julio Cesar Polanco.
--************************************************************************


--****************************************************************************
--*                        DEFINICION DE VARIABLES
--****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE v_nroref     SMALLINT;
DEFINE v_paramref   SMALLINT;
DEFINE s_tipper     CHAR(2);
DEFINE v_motivo     CHAR(1);
DEFINE v_tpsol      CHAR(1);
DEFINE v_eva_min_inf    DECIMAL(5,2);
DEFINE v_eva_max_inf    DECIMAL(5,2);
DEFINE v_eva_min_sup    DECIMAL(5,2);
DEFINE v_eva_max_sup    DECIMAL(5,2);
DEFINE v_porcen     DECIMAL(6,2);
DEFINE v_situacion  CHAR(1);
DEFINE v_producto   CHAR(4);
DEFINE s_numsol     VARCHAR(20);
DEFINE vMensaje     CHAR(200);
DEFINE vTipoRech    CHAR(1);
DEFINE v_avanza     SMALLINT;
DEFINE dFechaHoy	date;
DEFINE iMedSalMin		DECIMAL(10,2);
DEFINE iUdi		DECIMAL(10,2);
DEFINE iComparacion75 DECIMAL(10,2);
DEFINE iComparacion85 DECIMAL(10,2);
DEFINE Can_iUdi DECIMAL(10,2);
DEFINE v_MesesHis       SMALLINT;
--  INI jom Parametro referencia coppel
DEFINE v_paso_cliente       char(20);
--  FIN jom Parametro referencia coppel
--****************************************************************************
--*                        ASIGNACION DE VARIABLES
--****************************************************************************

LET scod_ret     = "000";
LET vsqlerr      = 0;
LET v_nroref     = 0;
LET v_paramref   = 0;
LET s_tipper     = "??";
LET v_tpsol      = "?";
LET v_eva_min_inf= 0;
LET v_eva_max_inf= 0;
LET v_eva_min_sup= 0;
LET v_eva_max_sup= 0;
LET v_porcen     = 0;
LET v_situacion  = "?";
LET v_producto   = "????";
LET s_numsol     = "??????????";
LET vMensaje     = "Pre-Calificacion Aprobada";
LET v_avanza	 = 0;
LET iMedSalMin	 = 0;
LET iUdi	 = 0;
LET iComparacion75= 0;
LET iComparacion85= 0;
LET Can_iUdi=0;
--  INI jom Parametro referencia coppel
LET v_paso_cliente = '';
--  FIN jom Parametro referencia coppel

--****************************************************************************
--*                        CONTROL DE ERRORES
--****************************************************************************

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, vMensaje;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "situacion_pago_t_cas.out";
--TRACE ON;

--****************************************************************************
--*                        PROGRAMA PRINCIPAL
--****************************************************************************

	-- ************************************
	-- Inicia Precalificacion del Cliente *
	-- ************************************

--  ini jom Parametro referencia coppel

    SELECT valor INTO v_paso_cliente
      FROM ss_param
     WHERE empresa = o_empresa
       AND secuencia = 324;


    if trim(v_paso_cliente) = trim(o_num_referencia) then
        RETURN scod_ret, nvl(vMensaje,'');
    end if;

	SELECT motivo_rechazo_sol, tipo_rechazo,descripcion
	  INTO v_motivo, vTipoRech, vMensaje
	  FROM bdicred:sd_situacion_cred
	 WHERE empresa = o_empresa
	   AND situacion = o_situacion;

	-- *****************************
	-- Valida Situacion de credito *
	-- *****************************

	IF v_motivo IS NULL THEN
	   LET v_motivo ="0";
	END IF

	IF v_motivo = "1" THEN
           LET scod_ret = "001";

	   -- Inserta Bitacora
           INSERT INTO bdisolic:ss_bitacora_precal

           (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
           causa,motivo,tipo_rechazo,codret,mensaje, vencidototalmuebles, vencidototalropa, vencidoprestamos, saldomuebles, saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos)
           VALUES
           (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
           o_causa,v_motivo,vTipoRech,scod_ret,vMensaje, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos);

           RETURN scod_ret, vMensaje;
	END IF

	IF vTipoRech = "1" THEN
	   LET scod_ret = "001";

   	   -- Inserta Bitacora
           INSERT INTO bdisolic:ss_bitacora_precal

           (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
           causa,motivo,tipo_rechazo,codret,mensaje, vencidototalmuebles, vencidototalropa, vencidoprestamos, saldomuebles, saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos)
           VALUES
           (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
           o_causa,v_motivo,vTipoRech,scod_ret,vMensaje, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos);

	   RETURN scod_ret, vMensaje;
	ELSE
	   SELECT motivo_rechazo_sol, descripcion
	     INTO v_motivo, vMensaje
	     FROM bdicred:sd_causas_cte_coppel
	    WHERE empresa = o_empresa
	      AND situacion = o_situacion
	      AND causa = o_causa;
	   IF v_motivo = "1" THEN
	      LET scod_ret = "001";

       	      -- Inserta Bitacora
              INSERT INTO bdisolic:ss_bitacora_precal

              (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
              causa,motivo,tipo_rechazo,codret,mensaje, vencidototalmuebles, vencidototalropa, vencidoprestamos, saldomuebles, saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos)
              VALUES
              (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
              o_causa,v_motivo,vTipoRech,scod_ret,vMensaje, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos);

	      RETURN scod_ret, vMensaje;
	   END IF
	END IF

	-- ***********************************************
	-- Extrae los rangos validos de calificacion
	-- ***********************************************
        SELECT tp_solicitud
          INTO v_tpsol
          FROM ss_solic_producto b
         WHERE b.empresa = o_empresa
           AND b.num_producto = o_producto;

	SELECT evaluacion_min, evaluacion_max INTO v_eva_min_inf, v_eva_max_inf
	  FROM ss_scoring_solic
	 WHERE empresa = o_empresa
	   AND tp_solicitud = v_tpsol
	   AND seccion = 1
       AND tpo_persona = '01'
       AND activa = '0';


	SELECT evaluacion_min, evaluacion_max INTO v_eva_min_sup, v_eva_max_sup
	  FROM ss_scoring_solic
	 WHERE empresa = o_empresa
	   AND tp_solicitud = v_tpsol
	   AND seccion = 3
       AND tpo_persona = '01'
       AND activa = '0';

	-- *******************************
	-- Valida Situacion de Pago
	-- *******************************

        IF o_porcentaje >= 0 THEN
           IF o_porcentaje  < v_eva_min_sup OR o_porcentaje  >  v_eva_max_sup THEN
		LET vMensaje = "Rango de Eficiencia fuera de politica.";
		LET scod_ret = "001";

	        -- Inserta Bitacora
                INSERT INTO bdisolic:ss_bitacora_precal

	        (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
                causa,motivo,tipo_rechazo,codret,mensaje, vencidototalmuebles, vencidototalropa, vencidoprestamos, saldomuebles, saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos)
                VALUES
                (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
                o_causa,v_motivo,vTipoRech,scod_ret,vMensaje, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos);

		RETURN scod_ret, vMensaje;
            END IF
        END IF

        -- *************************************************************************************
	-- Obtiene parametro de comparacion clientes coppel A- (eficiencia 75 y 84.9)
	-- *************************************************************************************

        -- Se toma el parametro para la comparacion clientes coppel entre 75 y 84.9.
        SELECT valor
        INTO iComparacion75
        FROM bdisolic:ss_param
        WHERE secuencia= '321';

        -- Se valida que el parametro tenga informacion correspondiente a la comparaciones de clientes coppel.
        IF iComparacion75 IS NULL THEN
            LET iComparacion75= 0;
        END IF;

        -- ***********************************************
	-- Valida que haya algun vencido
	-- ***********************************************

	IF o_vencidomuebles > 0 OR o_vencidoropa > 0 OR o_vencidoprestamos > 0 THEN
                    LET v_avanza = 1;
	END IF;

	IF ( v_avanza = 1 ) THEN

	-- *****************************************************************
	-- Valida porcentaje de eficiencia entre 75 y 84.9 y su vencido
	-- *****************************************************************

    		IF o_porcentaje >= v_eva_min_inf AND o_porcentaje < v_eva_min_sup THEN

                        LET v_avanza = 0;
			IF NOT ( o_vencidomuebles <= o_abonomuebles/2 AND o_vencidomuebles <= iComparacion75 ) AND o_vencidomuebles > 0 THEN
				LET v_avanza = 1;
			END IF

			IF NOT ( o_vencidoropa <= o_abonoropa/2 AND o_vencidoropa <= iComparacion75 ) AND v_avanza = 0 AND o_vencidoropa > 0 THEN
				LET v_avanza = 1;
			END IF

			IF NOT ( o_vencidoprestamos <= o_abonoprestamos/2 AND o_vencidoprestamos <= iComparacion75 ) AND v_avanza = 0 AND o_vencidoprestamos > 0 THEN
				LET v_avanza = 1;
			END IF

                        IF ( v_avanza = 1 ) THEN

                                    LET vMensaje = "El Cliente presenta un atraso en su cuenta Coppel.";
                                    LET scod_ret = "001";

                                    -- Inserta Bitacora
                                    INSERT INTO bdisolic:ss_bitacora_precal
                                    (empresa,fecha,producto,sucursal,nombre,nombre_coppel,
                                    num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
                                    causa,motivo,tipo_rechazo,codret,mensaje, vencidototalmuebles, vencidototalropa, vencidoprestamos, saldomuebles, saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos)
                                    VALUES
                                    (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,
                                    o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
                                    o_causa,v_motivo,vTipoRech,scod_ret,vMensaje, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos);

                                    RETURN scod_ret, vMensaje;
                        END IF
		END IF

		-- *******************************************************************
		-- Valida porcentaje de eficiencia mayor igual 85 y su vencido
		-- *******************************************************************

		IF o_porcentaje >= v_eva_min_sup THEN

			SELECT fecha_hoy
			INTO dFechaHoy
			FROM bdicred:sd_fechas
			WHERE empresa ='001';

--			SELECT (nvl(sp.valor,0) * 1) / 2 AS sal_min
--			INTO iMedSalMin
--			FROM bdisolic:ss_param sp
--			WHERE sp.secuencia = 303 AND empresa = o_empresa;
            SELECT valor
            INTO iComparacion85
            FROM bdisolic:ss_param
            WHERE secuencia= '322';


			LET v_avanza = 0;
			
			IF NOT ( o_vencidomuebles <= o_abonomuebles/2 AND o_vencidomuebles <= iComparacion85 ) AND o_vencidomuebles > 0 THEN
				LET v_avanza = 1;
			END IF

			IF NOT ( o_vencidoropa <= o_abonoropa/2 AND o_vencidoropa <= iComparacion85 ) AND v_avanza = 0 AND o_vencidoropa > 0 THEN
				LET v_avanza = 1;
			END IF

			IF NOT ( o_vencidoprestamos <= o_abonoprestamos/2 AND o_vencidoprestamos <= iComparacion85 ) AND v_avanza = 0 AND o_vencidoprestamos > 0 THEN
				LET v_avanza = 1;
			END IF

{
			IF ( v_avanza = 1 ) THEN

            SELECT valor
            INTO Can_iUdi
            FROM bdisolic:ss_param
            WHERE secuencia= '323';

				SELECT LIMIT 1 nvl(sp.precio_compra,0) * Can_iUdi as udi
				INTO iUdi
				FROM bdinteg:si_histdiv sp
				WHERE sp.divisa = '09' AND sp.empresa = o_empresa AND sp.fecha_tc <= dFechaHoy
				AND (sp.fecha_tc || ' ' || sp.hora_tc) =
				(SELECT max(sp2.fecha_tc || ' ' || sp2.hora_tc)
				FROM bdinteg:si_histdiv sp2
				wHERE sp2.divisa = '09' AND sp2.empresa = o_empresa AND sp2.fecha_tc <= dFechaHoy);

				LET v_avanza = 0;
				IF NOT (o_vencidomuebles < iUdi ) AND o_vencidomuebles > 0 THEN
					LET v_avanza = 1;
				END IF

				IF NOT (o_vencidoropa < iUdi ) AND v_avanza = 0 AND o_vencidoropa > 0 THEN
					LET v_avanza = 1;
				END IF

				IF NOT (o_vencidoprestamos < iUdi ) AND v_avanza = 0 AND o_vencidoprestamos > 0 THEN
					LET v_avanza = 1;
				END IF

			END IF
}

			IF ( v_avanza = 1 ) THEN

				LET vMensaje = "El Cliente presenta un atraso en su cuenta Coppel.";
				LET scod_ret = "001";

			     	-- Inserta Bitacora
        			INSERT INTO bdisolic:ss_bitacora_precal
                		(empresa,fecha,producto,sucursal,nombre,nombre_coppel,
                        	num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
                        	causa,motivo,tipo_rechazo,codret,mensaje, vencidototalmuebles, vencidototalropa, vencidoprestamos, saldomuebles, saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos)
	              		VALUES
        			(o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,
                        	o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
                        	o_causa,v_motivo,vTipoRech,scod_ret,vMensaje, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos);

				RETURN scod_ret, vMensaje;
			END IF
		END IF
	END IF

	-- ****************************************************
	--       VERIFICA ANTIGUEDAD EN CLIENTES COPPEL       *
	-- ****************************************************

    SELECT valor INTO v_MesesHis
      FROM ss_param
     WHERE empresa = o_empresa
       AND secuencia = 327;




       IF (trim(v_paso_cliente) <> trim(o_num_referencia)) THEN

            IF NVL(o_meses_hist,0)<v_MesesHis THEN
                LET vMensaje = "Cliente con poca antigüedad en Coppel";
                LET scod_ret = "001";

                -- Inserta Bitacora
                    INSERT INTO bdisolic:ss_bitacora_precal

                (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
                    causa,motivo,tipo_rechazo,codret,mensaje, vencidototalmuebles, vencidototalropa, vencidoprestamos, saldomuebles, saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos)
                    VALUES
                    (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
                    o_causa,v_motivo,vTipoRech,scod_ret,vMensaje, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos);

                RETURN scod_ret, vMensaje;
            END IF;
       END IF;
--  FIN jom Parametro referencia coppel
END
	RETURN scod_ret, nvl(vMensaje,'');

END PROCEDURE;