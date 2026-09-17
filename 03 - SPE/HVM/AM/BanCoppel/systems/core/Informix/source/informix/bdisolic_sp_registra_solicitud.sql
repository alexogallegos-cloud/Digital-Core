CREATE PROCEDURE "informix".sp_registra_solicitud(
                      p_empresa            LIKE ss_solicitudes.empresa,
                      p_num_solicitud      LIKE ss_solicitudes.num_solicitud,
                      p_numcte             LIKE ss_solicitudes.numcte,
                      p_sucursal           LIKE ss_solicitudes.sucursal,
                      p_num_producto       LIKE ss_solicitudes.num_producto,
                      p_monto_solicitado   LIKE ss_solicitudes.monto_solicitado,
                      p_plazo              LIKE ss_solicitudes.plazo,
                      p_gracia_cap         LIKE ss_solicitudes.gracia_cap,
                      p_diferimiento_int   LIKE ss_solicitudes.diferimiento_int,
                      p_fecha_apert_prop   DATE,
                      p_actividad          CHAR(3),
                      p_cod_tipo_linea     CHAR(2),
                      p_cod_linea          CHAR(4),
                      p_ciclo              CHAR(25),
                      p_id_unidad_prod     INTEGER,
                      p_exp_com_prod       INTEGER,
                      p_registro_mpc       CHAR(20),
                      p_expert_agro_nombre CHAR(60),
                      p_exp_agro_cedula    CHAR(20),
                      p_exp_agro_registro  CHAR(20),
                      p_uempc_nombre       CHAR(60),
                      p_uempc_cedula       CHAR(20),
                      p_fecha_sol          DATE,
                      p_ejecutivo_sol      CHAR(8),
                      p_id_origen          CHAR(2),
                      p_origen             CHAR(3),
                      p_efz_razon_social   CHAR(40),
                      p_efz_direccion      CHAR(60),
                      p_cvediv             CHAR(3))
   RETURNING CHAR(5), CHAR(80);

                          
   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;
   
   DEFINE v_basura            CHAR(1);
   DEFINE v_tipo_calculo      CHAR(3);
   DEFINE v_monto             MONEY(14,3);

  ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "Sp_Registra_Solicitud.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET p_mensaje = error_info;
      RETURN cod_ret, p_mensaje;
   END EXCEPTION;

   LET cod_ret = '000';
   LET p_mensaje = "Operacion Realizada Exitosamente";
   LET v_monto = p_monto_solicitado;
   
   SELECT
      COUNT(*)
   INTO
      nrows
   FROM
      bdinteg:si_cliente
   WHERE
      numcte = p_numcte;
      
   IF(nrows = 0) THEN
      LET cod_ret = '100';
      LET p_mensaje = 'Cliente No Existe';
      RETURN cod_ret, p_mensaje;
   END IF;

   -- Valida que el producto y obtiene el tipo de calculo
   
   SELECT
      tipo_calculo
   INTO
      v_tipo_calculo
   FROM
      bdicred:sd_definicion
   WHERE
      num_producto = p_num_producto
   AND
      empresa = p_empresa;
      
   IF(v_tipo_calculo IS NULL) THEN
      LET cod_ret = '101';
      LET p_mensaje = 'Producto no Tiene Tipo de Calculo';
      RETURN cod_ret, p_mensaje;
   END IF;
   
   INSERT INTO
      ss_solicitudes
         (empresa,
          num_solicitud,
          numcte,
          sucursal,
          num_producto,
          monto_solicitado,
          plazo,
          tipo_calculo,
          gracia_cap,
          diferimiento_int,
          fecha_apert_prop,
          cod_funcion,
          status_solicitud,
          regional,
          plaza,
          tipo_solicitud,
          divisa)
   VALUES
         (p_empresa,
          p_num_solicitud,
          p_numcte,
          p_sucursal,
          p_num_producto,
          v_monto,
          p_plazo,
          v_tipo_calculo,
          p_gracia_cap,
          p_diferimiento_int,
          p_fecha_apert_prop,
          '001',
          'CO',
          '001',
          '001',
          'N',
          p_cvediv);
          
   INSERT INTO
      ss_anexosol
         (empresa,
         num_solicitud,
         actividad,
         cod_tipo_linea,
         cod_linea,
         ciclo,
         id_unidad_prod,
         exp_como_prod,
         registro_mpc,
         expert_agro_nombre,
         exp_agro_cedula,
         exp_agro_registro,
         uempc_nombre,
         uempc_cedula,
         fecha_sol,
         ejecutivo_sol,
         id_origen,
         origen,
         efz_razonsocial,
         efz_direccion)
   VALUES
         (p_empresa,
         p_num_solicitud,
         p_actividad,
         p_cod_tipo_linea,
         p_cod_linea,
         p_ciclo,
         p_id_unidad_prod,
         p_exp_com_prod,
         p_registro_mpc,
         p_expert_agro_nombre,
         p_exp_agro_cedula,
         p_exp_agro_registro,
         p_uempc_nombre,
         p_uempc_cedula,
         p_fecha_sol,
         p_ejecutivo_sol,
         p_id_origen,
         p_origen,
         p_efz_razon_social,
         p_efz_direccion);
         

   RETURN cod_ret, p_mensaje;

END PROCEDURE
