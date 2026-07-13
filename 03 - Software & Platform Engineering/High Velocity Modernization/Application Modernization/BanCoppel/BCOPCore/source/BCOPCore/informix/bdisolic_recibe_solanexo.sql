CREATE PROCEDURE "informix".recibe_solanexo(r_empresa              CHAR(3),
                                 r_num_solicitud        CHAR(20),
                                 r_numcte               CHAR(20),
                                 r_co_numcte            CHAR(20),
                                 r_sucursal             CHAR(4) ,
                                 r_tipo_solicitud       CHAR(1) ,
                                 r_num_producto         CHAR(4) ,
                                 r_tipo_prestamo        CHAR(2) ,
                                 r_monto_solicitado     MONEY(14,2),
                                 r_tp_amortizacion      CHAR(1),
                                 r_fecha_sol            DATE, -- Ini Anexo
                                 r_raza_o_presta        CHAR(1),
                                 r_raza_o_copres        CHAR(1),
                                 r_otro_raza_p          CHAR(30),
                                 r_otro_raza_cp         CHAR(30),
                                 r_num_cred_agen        CHAR(20),
                                 r_num_prestador        CHAR(20),
                                 r_sexo_copresta        CHAR(1),
                                 r_tasa                 DECIMAL(9,6),
                                 r_plazo                INTEGER,
                                 r_numacta              CHAR(20))
RETURNING CHAR(5);

-- *************************************************************************
-- *                       DEFINICION DE VARIABLES                         *
-- *************************************************************************
DEFINE vcod_ret   CHAR(5);
DEFINE vsqlerr    INTEGER;
DEFINE vplaza     CHAR(3);
DEFINE vregional  CHAR(3);
DEFINE vsol       CHAR(20);
DEFINE vtpsol     CHAR(1);
DEFINE vplazo_max INTEGER;
-- *************************************************************************
-- *                       ASIGNACION DE VARIABLES                         *
-- *************************************************************************
LET vcod_ret = "00000";
LET vsqlerr  = 0;

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcod_ret=vsqlerr;
      RETURN vcod_ret;
   END IF;
END EXCEPTION;


-- *************************************************************************

        -- Valida que la Solicitud exista
        SELECT num_solicitud INTO vsol FROM ss_solicitudes
         WHERE empresa = r_empresa
           AND num_solicitud = r_num_solicitud;
        IF vsol IS NULL THEN
                LET vcod_ret="100";
                RETURN vcod_ret;
        END IF

        -- Determina el Tipo de Solicitud
        SELECT SUBSTR(descripcion,1,1), a.plazo_max_cred
          INTO vtpsol, vplazo_max
          FROM bdicred:sd_definicion a, bdicred:sd_tipcred b, ss_solicitudes c
         WHERE b.cod_tipcred = a.cod_tipcred
           AND b.empresa = a.empresa
           AND a.num_producto = c.num_producto
           AND a.empresa = c.empresa
           AND c.num_solicitud =  r_num_solicitud
           AND c.empresa = r_empresa;

        -- Actualiza ss_anexosol
        UPDATE ss_anexosol
           SET (fecha_sol,     raza_origen_presta, raza_origen_cop,
                otro_presta,   otro_copresta,      num_cred_agencia,
                num_prestador, sexo_copresta,      num_acta)
               =
               (r_fecha_sol,     r_raza_o_presta, r_raza_o_copres,
                r_otro_raza_p,   r_otro_raza_cp,  r_num_cred_agen,
                r_num_prestador, r_sexo_copresta, r_numacta)
         WHERE num_solicitud = r_num_solicitud
           AND empresa = r_empresa;

        -- Actualiza ss_solicitudes
        SELECT b.plaza, b.regional
          INTO vplaza, vregional
          FROM bdinteg:si_sucursales a, bdinteg:si_plazas B
         WHERE b.plaza = a.plaza
           AND b.empresa = a.empresa
           AND a.sucursal = r_sucursal
           AND a.empresa = r_empresa;

        IF vtpsol = "I" THEN
                LET r_plazo = vplazo_max;
        END IF

        -- En la columna con integrantes se guarda el tipo de amortizacion

        -- Si Existe Numero de acta registrar en sd_CtasCargo
        IF TRIM(r_numacta) <> '' THEN
           let vsol = NULL;
           select num_credito
           into   vsol
           from   bdicred:sd_ctascarg
           where  num_credito = r_num_solicitud
           and    empresa = r_empresa;
           if vsol is null then
              INSERT INTO bdicred:sd_ctascarg
                         (empresa, num_credito, naturaleza, num_cta)
               VALUES (r_empresa, r_num_solicitud, "A", r_numacta);
           else
              update bdicred:sd_ctascarg
              set    num_cta = r_numacta
              where  num_credito = r_num_solicitud
              and    empresa = r_empresa;
           end if;
        END IF;

	IF vtpsol = "C" AND  r_raza_o_presta = "2" THEN
	     let r_num_solicitud = r_num_solicitud;
              SELECT cuenta INTO r_numacta
	   	FROM bdicheq:sc_maechq
	      -- WHERE cuenta LIKE SUBSTR(r_num_solicitud,1,9) || "30%"
                 WHERE cuenta = r_numacta
		 AND status_cta = "1";

	      IF r_numacta IS NULL THEN
		LET vcod_ret = "430";
        	RETURN vcod_ret;
	      END IF
              INSERT INTO bdicred:sd_ctascarg
                         (empresa, num_credito, naturaleza, num_cta)
               VALUES (r_empresa, r_num_solicitud, "C", r_numacta);
	END IF

        UPDATE ss_solicitudes
           SET (numcte, co_numcte, cod_funcion, regional, plaza, sucursal,
                tipo_solicitud, status_solicitud, tipo_prestamo,
                monto_solicitado, con_integrantes, plazo, tasa_interes)
               =
               (r_numcte, r_co_numcte, "001", vregional, vplaza, r_sucursal,
                r_tipo_solicitud, "CO", r_tipo_prestamo, r_monto_solicitado,
                r_tp_amortizacion, r_plazo, r_tasa)
         WHERE num_solicitud = r_num_solicitud
           AND empresa = r_empresa;

END
        RETURN vcod_ret;
END PROCEDURE;