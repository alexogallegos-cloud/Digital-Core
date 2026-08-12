CREATE PROCEDURE "informix".situacion_pago_tienda_cjunk(o_empresa CHAR(3),
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
				o_saldoprestamos INTEGER,
                o_ultimacompra   DATE)


RETURNING CHAR(5) 	as retorno,
		  --CHAR(200) as mensaje;
          CHAR(250) as mensaje;
    -- CONTROL DE CAMBIOS:
--------------------------------------------------------------------------------
-- Fecha Modificacion:  08/09/2008
-- Autor: Paul Ivan Quintero Varela
-- Descripcion: Se modifica la validacion del vencido de los clientes coppel A- con
--                         eficiencia de pagos entre 75 y 84.9 en Coppel, RQM 09 078.
--------------------------------------------------------------------------------
-- Fecha de Modificacion: 08/01/2009
-- Modifico: Viridiana Osobampo 
-- Descripcion: Se agrego parametro de entrada (o_ultimacompra) para indicar la 
-- fecha de la ultima compra del cliente en tiendas coppel. Proyecto Caja Unica
--------------------------------------------------------------------------------
--ACTIVIDAD: Se modifica para que las consultas a la tabla ss_scoring_solic
-- lean los registros antes de caja unica, activa=0.
--FECHA: 23/02/2009
--AUTOR: Julio Cesar Polanco.
--------------------------------------------------------------------------------
-- Fecha de Modificacion: 07/01/2010
-- Modifico: Viridiana Osobampo 
-- Descripcion: Se unifican cambios realizados para el proyecto Alta Única con
--              la versión del spl productivo.
--------------------------------------------------------------------------------
-- Fecha de Modificacion: 23/06/2010
-- Modifico: Viridiana Osobampo 
-- Descripcion: Se modifican los mensajes cuando no se cumple con el
-- 		    rango de eficiencia y vencidos en coppel.
--------------------------------------------------------------------------------

--****************************************************************************
--*                        DEFINICION DE VARIABLES
--****************************************************************************
DEFINE scod_ret             CHAR(5);
DEFINE vsqlerr              INTEGER;
DEFINE v_nroref             SMALLINT;
DEFINE v_paramref           SMALLINT;
DEFINE s_tipper             CHAR(2);
DEFINE v_motivo             CHAR(1);
DEFINE v_tpsol              CHAR(1);
DEFINE v_eva_min_inf        DECIMAL(5,2);
DEFINE v_eva_max_inf        DECIMAL(5,2);
DEFINE v_eva_min_sup        DECIMAL(5,2);
DEFINE v_eva_max_sup        DECIMAL(5,2);
DEFINE v_porcen             DECIMAL(6,2);
DEFINE v_situacion          CHAR(1);
DEFINE v_producto           CHAR(4);
DEFINE s_numsol             VARCHAR(20);
--DEFINE vMensaje             CHAR(200);
DEFINE vMensaje             CHAR(250);
DEFINE vTipoRech            CHAR(1);
DEFINE v_avanza             SMALLINT;
DEFINE iMedSalMin           DECIMAL(10,2);
DEFINE iUdi                 DECIMAL(10,2);
DEFINE iComparacion75       DECIMAL(10,2);
DEFINE iComparacion85       DECIMAL(10,2);
DEFINE Can_iUdi             DECIMAL(10,2);
DEFINE v_MesesHis           SMALLINT;
--  INI jom Parametro referencia coppel
DEFINE v_paso_cliente       CHAR(20);
--  FIN jom Parametro referencia coppel
--  INI jom valor de udis
DEFINE vFechaHoy            DATE;
DEFINE vMaxMtoUdi           DECIMAL(14,2);
DEFINE vValorUdi            DECIMAL(14,6);
DEFINE vCodUdi              CHAR(2);
DEFINE vClase               CHAR(1);
DEFINE vCodRet              CHAR(5);                
--  FIN jom valor de udis
--****************************************************************************
--*                        ASIGNACION DE VARIABLES
--****************************************************************************

LET scod_ret        = "000";
LET vsqlerr         = 0;
LET v_nroref        = 0;
LET v_paramref      = 0;
LET s_tipper        = "??";
LET v_tpsol         = "?";
LET v_eva_min_inf   = 0;
LET v_eva_max_inf   = 0;
LET v_eva_min_sup   = 0;
LET v_eva_max_sup   = 0;
LET v_porcen        = 0;
LET v_situacion     = "?";
LET v_producto      = "????";
LET s_numsol        = "??????????";
LET vMensaje        = "Pre-Calificacion Aprobada";
LET v_avanza        = 0;
LET iMedSalMin      = 0;
LET iUdi            = 0;
LET iComparacion75  = 0;
LET iComparacion85  = 0;
LET Can_iUdi        =0;
--  INI jom Parametro referencia coppel
LET v_paso_cliente  = '';
--  FIN jom Parametro referencia coppel
--  INI jom valor de udis
let vFechaHoy       = null;
LET vMaxMtoUdi      = 0;
LET vValorUdi       = 0;
LET vCodRet          = "00000";
LET vCodUdi         ="";
LET vClase          ="";
--  FIN jom valor de udis

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

--SET DEBUG FILE TO "/tmp/situacion_pago_t.out";
--TRACE ON;

--****************************************************************************
--*                        PROGRAMA PRINCIPAL
--****************************************************************************

	-- ************************************
	-- Inicia Precalificacion del Cliente *
	-- ************************************
--obtiene la fecha del día
    SELECT fecha_hoy
      INTO vFechaHoy
      FROM bdicred:sd_fechas
     WHERE empresa = o_empresa;

    SELECT valor 
      INTO vMaxMtoUdi
      FROM ss_param
     WHERE empresa = o_empresa
       AND secuencia = 309;

      -- *****************************************
      --  Extrae Clase y Tipo de Cmabio para UDI *
      -- *****************************************

    SELECT TRIM(valor) 
      INTO vCodUdi
      FROM bdinteg:si_param
     WHERE empresa = o_empresa
       AND cod_param = 16;

      SELECT TRIM(valor) INTO vClase
	    FROM bdicred:sd_param
       WHERE empresa = o_empresa
	     AND cod_param = "336";

    CALL bdinteg:valor_divisa_pesos(o_empresa, vFechaHoy, vCodUdi, vClase) RETURNING vCodRet, vValorUdi;

    if (vCodRet <> "00000") THEN
        LET scod_ret = vCodRet;
        RETURN scod_ret, "No se econtro valor de UDI";
    end if;
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
       causa,motivo,tipo_rechazo,codret,mensaje, vencidototalmuebles, vencidototalropa, vencidoprestamos, saldomuebles, 
       saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos,fecha_ultima_compra)
       VALUES
       (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
       o_causa,v_motivo,vTipoRech,scod_ret,vMensaje, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, 
       o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos,o_ultimacompra);

       RETURN scod_ret, vMensaje;
   END IF

   IF vTipoRech = "1" THEN
       LET scod_ret = "001";

       -- Inserta Bitacora
       INSERT INTO bdisolic:ss_bitacora_precal

       (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
       causa,motivo,tipo_rechazo,codret,mensaje, vencidototalmuebles, vencidototalropa, vencidoprestamos, saldomuebles, 
       saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos,fecha_ultima_compra)
       VALUES
       (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
       o_causa,v_motivo,vTipoRech,scod_ret,vMensaje, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, 
       o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos,o_ultimacompra);

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
           causa,motivo,tipo_rechazo,codret,mensaje, vencidototalmuebles, vencidototalropa, vencidoprestamos, saldomuebles, 
           saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos,fecha_ultima_compra)
           VALUES
           (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
           o_causa,v_motivo,vTipoRech,scod_ret,vMensaje, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, 
           o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos,o_ultimacompra);

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
   AND tpo_persona = "01"
   AND activa = '0'; -- Caja Unica. Viridiana


   SELECT evaluacion_min, evaluacion_max INTO v_eva_min_sup, v_eva_max_sup
   FROM ss_scoring_solic
   WHERE empresa = o_empresa
   AND tp_solicitud = v_tpsol
   AND seccion = 3
   AND tpo_persona = "01"
   AND activa = '0'; -- Caja Unica. Viridiana

	-- *******************************
	-- Valida Situacion de Pago
	-- *******************************

   IF o_porcentaje >= 0 THEN
       IF o_porcentaje  < v_eva_min_sup OR o_porcentaje  >  v_eva_max_sup THEN
           --LET vMensaje = "Rango de Eficiencia fuera de politica.";
           LET vMensaje = "Por el momento le podemos tramitar su Cuenta Efectiva. Para tramitar "||
                          "una solicitud de crédito BanCoppel es necesario realizar puntualmente "||
                          "sus pagos mensuales en su Tienda Coppel.";
           LET scod_ret = "001";

            -- Inserta Bitacora
           INSERT INTO bdisolic:ss_bitacora_precal

           (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
           causa,motivo,tipo_rechazo,codret,mensaje, vencidototalmuebles, vencidototalropa, vencidoprestamos, saldomuebles, 
           saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos,fecha_ultima_compra)
           VALUES
           (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
           o_causa,v_motivo,vTipoRech,scod_ret,vMensaje, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, 
           o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos,o_ultimacompra);

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

               --LET vMensaje = "El Cliente presenta un atraso en su cuenta Coppel.";

               LET vMensaje = "Por el momento le podemos tramitar su Cuenta Efectiva.  Para tramitar " || 
                              "una solicitud de crédito BanCoppel es necesario tener sus pagos al " || 
                              "corriente en su Tienda Coppel. Lo invito a ser más puntual en sus pagos " ||
                              "en su tienda Coppel.";
               LET scod_ret = "001";

                -- Inserta Bitacora
               INSERT INTO bdisolic:ss_bitacora_precal

               (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
               causa,motivo,tipo_rechazo,codret,mensaje, vencidototalmuebles, vencidototalropa, vencidoprestamos, saldomuebles, 
               saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos,fecha_ultima_compra)
               VALUES
               (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
               o_causa,v_motivo,vTipoRech,scod_ret,vMensaje, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, 
               o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos,o_ultimacompra);

               RETURN scod_ret, vMensaje;
           END IF
       END IF

		-- *******************************************************************
		-- Valida porcentaje de eficiencia mayor igual 85 y su vencido
		-- *******************************************************************

       IF o_porcentaje >= v_eva_min_sup THEN

--           SELECT valor
--           INTO iComparacion85
--           FROM bdisolic:ss_param
--           WHERE secuencia= '322';

           let iComparacion85 = vMaxMtoUdi * vValorUdi;

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


           IF ( v_avanza = 1 ) THEN

               --LET vMensaje = "El Cliente presenta un atraso en su cuenta Coppel.";

               LET vMensaje = "Por el momento le podemos tramitar su Cuenta Efectiva.  Para tramitar " || 
                              "una solicitud de crédito BanCoppel es necesario tener sus pagos al " || 
                              "corriente en su Tienda Coppel. Lo invito a ser más puntual en sus pagos " ||
                              "en su tienda Coppel.";
               LET scod_ret = "001";

                -- Inserta Bitacora
               INSERT INTO bdisolic:ss_bitacora_precal

               (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
               causa,motivo,tipo_rechazo,codret,mensaje, vencidototalmuebles, vencidototalropa, vencidoprestamos, saldomuebles, 
               saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos,fecha_ultima_compra)
               VALUES
               (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
               o_causa,v_motivo,vTipoRech,scod_ret,vMensaje, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, 
               o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos,o_ultimacompra);

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
           causa,motivo,tipo_rechazo,codret,mensaje, vencidototalmuebles, vencidototalropa, vencidoprestamos, saldomuebles, 
           saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos,fecha_ultima_compra)
           VALUES
           (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
           o_causa,v_motivo,vTipoRech,scod_ret,vMensaje, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, 
           o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos,o_ultimacompra);

           RETURN scod_ret, vMensaje;
       END IF;

   END IF;
--  FIN jom Parametro referencia coppel
END
	RETURN scod_ret, nvl(vMensaje,'');

END PROCEDURE;