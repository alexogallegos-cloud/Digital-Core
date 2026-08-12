create procedure "informix".verifcte(pempresa char(3),
			  pappat char(26),
                          pnombre1 char(26),
	                  prazon_soc char(60),
                          pnum_movto smallint)
       returning char(5),char(26),char(26),char(26),char(26),
		char(60),char(13),char(20);

define vpaterno,vmaterno,vnombre1,vnombre2 char(15);
define vciclo smallint;
define vcodret char(5);
define vrazon_soc char(60);
define vnumcte char(20);
define vrfc char(13);
define sql_err integer;

begin
   on exception set sql_err
      if sql_err <> 0 then
	 let vcodret = sql_err;
	 return vcodret,vpaterno,vmaterno,vnombre1,vnombre2,vrazon_soc,
                vrfc,vnumcte;
      end if
   end exception;


   set isolation to dirty read;

   let vnumcte=" ";
   let vpaterno=" ";
   let vmaterno=" ";
   let vnombre1=" ";
   let vnombre2=" ";
   let vrazon_soc=" ";
   let vrfc = " ";
   let vcodret="000";
   let vciclo = 0;

   if pappat is null and prazon_soc is null then
      let vcodret="110";
      return vcodret,vpaterno,vmaterno,vnombre1,vnombre2,vrazon_soc,
             vrfc,vnumcte;
   end if
   if prazon_soc is null or prazon_soc = " " then
     -- let pappat = trim(pappat) || "*";
     -- let pnombre1 = trim(pnombre1) || "*";
     -- Valida por RFC MEL 09/Mar/2007
      foreach
	 select apell_paterno,apell_materno,nombre1,nombre2,razon_social,
		rfc,si_cliente.numcte
	    into vpaterno,vmaterno,vnombre1,vnombre2,
		vrazon_soc,vrfc,vnumcte
	    from si_cliente
	    where rfc = pappat 
	  --  where apell_paterno matches pappat and
          --      nombre1 matches pnombre1
         let vciclo = vciclo+1;
         if vciclo <= pnum_movto then
            continue foreach;
         end if
	 if vpaterno is null then
	    let vcodret = "104";
	 end if
	 if vrfc is null then
	    let vrfc = " ";
	 end if
	 return vcodret,vpaterno,vmaterno,vnombre1,vnombre2,vrazon_soc,
                vrfc,vnumcte with resume;
      end foreach
   else
      foreach
	 select apell_paterno,apell_materno,nombre1,nombre2,razon_social,
		rfc,si_cliente.numcte
	    into vpaterno,vmaterno,vnombre1,vnombre2,vrazon_soc,
		vrfc,vnumcte
            from si_cliente
	    where rfc =  pappat
	    --where razon_social matches prazon_soc
            let vciclo = vciclo+1;
            if vciclo <= pnum_movto then
               continue foreach;
            end if
 	    if vrazon_soc is null then
	       let vcodret = "104";
	    end if
	    if vrfc is null then
	       let vrfc = " ";
	    end if
	    return vcodret,vpaterno,vmaterno,vnombre1,vnombre2,vrazon_soc,
                   vrfc,vnumcte with resume;
      end foreach
   end if;
end
end procedure
DOCUMENT
"Consulta de clientes por Apellidos o Razon Social",
"Autor : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Manuel Hernandez",
"MODIFICO : Mario Escobar",
"FECHA : 12/Septiembre/2006",
"FECHA : 19/Diciembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".califica_scoring(o_empresa CHAR(3),
				  o_numsol   	CHAR(20),
				  o_referencia1 	CHAR(20),
				  o_referencia2 	CHAR(20),
				  o_ingreso     	MONEY(14,2),
			  	  o_conyuge     	CHAR(20),
                          o_nombreref_1 	CHAR(104),
                          o_nombreref_2 	CHAR(104),
                          o_parentesco_1  CHAR(2),
                          o_parentesco_2  CHAR(2),
                          o_telefono_1    CHAR(13),
                          o_telefono_2    CHAR(13))

RETURNING CHAR(5);


-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE v_valor      DECIMAL(14,2);
DEFINE v_valor_1s   DECIMAL(14,2);
DEFINE v_valor_2s   DECIMAL(14,2);
DEFINE v_valor_im   DECIMAL(14,2);
DEFINE v_valor_ex   DECIMAL(14,2);
DEFINE v_paso       CHAR(1);
DEFINE v_cuantos    SMALLINT;
DEFINE v_seccion    SMALLINT;
DEFINE v_grupo      SMALLINT;
DEFINE v_tpsol      CHAR(1);
DEFINE v_hoy        DATE;
DEFINE v_cliente    CHAR(20);
DEFINE vCompromisos DECIMAL(14,2);
DEFINE vMensaje     VARCHAR(255);
DEFINE vedocivil    CHAR(1);
DEFINE vTpCiudad    CHAR(1);
DEFINE vCiudadCte   CHAR(3);
DEFINE vEstadoCte   CHAR(2);
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET v_valor      = 0;
LET v_valor_1s   = 0;
LET v_valor_2s   = 0;
LET v_valor_im   = 0;
LET v_valor_ex   = 0;
LET v_paso       = "";
LET v_cuantos    = 0;
LET v_seccion    = 0;
LET v_grupo      = 0;
LET v_tpsol      = "";
SELECT fecha_hoy INTO v_hoy FROM bdicred:sd_fechas;
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret;
   END IF;
END EXCEPTION;



-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
	-- ********************************
	-- Inserta Referencias Personales *
	-- ********************************

	SELECT numcte INTO v_cliente
	  FROM ss_solicitudes
	 WHERE empresa = o_empresa
	   AND num_solicitud = o_numsol;

	SELECT estado_civil
          INTO vedocivil
          FROM bdinteg:si_ctepf
         WHERE empresa = o_empresa and numcte = v_cliente;


	let o_empresa = o_empresa;
	let o_numsol = o_numsol;
	let v_cliente = v_cliente;
	let o_referencia1 = o_referencia1;

         INSERT INTO ss_refpersonales
 	  (empresa, num_solicitud, numcte, numcte_ref, tipo_relacion, 
	   nombre_ref, parentesco, telefono_ref)
         VALUES
	  (o_empresa, o_numsol, v_cliente, o_referencia1, "01", 
	   o_nombreref_1 , o_parentesco_1, o_telefono_1);


--	IF NOT o_referencia2 IS NULL AND LENGTH(o_referencia2) > 0 THEN
--		INSERT INTO ss_refpersonales
--	 	  (empresa, num_solicitud, numcte, numcte_ref, tipo_relacion)
--		VALUES
--	 	  (o_empresa, o_numsol, v_cliente, o_referencia2, "01");
--	END IF


	let o_empresa = o_empresa;
	let o_numsol = o_numsol;
	let v_cliente = v_cliente;
	let o_referencia2 = o_referencia2;


	IF NOT o_nombreref_2 IS NULL AND LENGTH(o_nombreref_2) > 0 THEN
		INSERT INTO ss_refpersonales
	 	 (empresa, num_solicitud, numcte, numcte_ref, tipo_relacion, 
		  nombre_ref, parentesco, telefono_ref)
		VALUES
	 	 (o_empresa, o_numsol, v_cliente, o_referencia2, "01", 
		  o_nombreref_2 , o_parentesco_2, o_telefono_2);
	END IF


--	IF o_referencia1 = o_conyuge THEN
--		LET scod_ret = "088";
--                RETURN scod_ret;
--	END IF

--      IF vedocivil = "C" THEN
--         if not o_referencia2 is null AND LENGTH(o_referencia2) > 0 then
--            IF o_referencia2 = o_conyuge THEN
-- 	         LET scod_ret = "088";
--               RETURN scod_ret;
--   	      END IF
--         end if
--      END IF


	let o_empresa = o_empresa;
	let o_numsol = o_numsol;
	let v_cliente = v_cliente;
	let o_conyuge = o_conyuge;

	-- Registro que identificara el numero de cliente asignado al conyuge
	IF NOT o_conyuge IS NULL AND LENGTH(o_conyuge) > 0 THEN
		INSERT INTO ss_refpersonales
	 	 (empresa, num_solicitud, numcte, numcte_ref, parentesco)
		VALUES
	 	 (o_empresa, o_numsol, v_cliente, o_conyuge, "05");
	END IF

	-- ********************************
	-- Actualiza Ingresos del Cliente *
	-- ********************************
	UPDATE ss_resum_scor_fin SET ingreso_mensual = o_ingreso
	 WHERE empresa = o_empresa
	   AND num_solicitud = o_numsol;

	-- **********************************************************
	-- Incorpora Grupo 12 (ciudad) de acuerdo a dato del cliente*
	-- **********************************************************
	SELECT estado, ciudad
	  INTO vEstadoCte, vCiudadCte
	  FROM bdinteg:si_direcciones a, ss_solicitudes b
	 WHERE b.empresa = o_empresa
	   AND b.num_solicitud = o_numsol
	   AND a.numcte = b.numcte
	   AND a.secuencia = (SELECT MAX(secuencia) 
			        FROM bdinteg:si_direcciones c
			       WHERE c.numcte = a.numcte
				 AND c.tipo_dir ="1");

	SELECT tipo_ciudad
	  INTO vTpCiudad
	  FROM bdinteg:si_ciudades
	 WHERE estado = vEstadoCte
	   AND ciudad = vCiudadCte;

	IF vTpCiudad IS NULL THEN
		LET vTpCiudad = "0";
	END IF

        SELECT valor INTO v_valor
          FROM ss_scoring_pesos
         WHERE empresa = o_empresa
           AND tp_solicitud = "T"
           AND grupo = 12
           AND elemento = vTpCiudad
           AND seccion = 2
           AND tpo_persona = "01";

	IF v_valor IS NULL THEN
		LET v_valor = 0;
	END IF

        INSERT INTO ss_detalle_scoring
         (empresa, seccion, grupo, elemento, tpo_persona, num_solicitud, valor)
        VALUES
         (o_empresa, 2, 12, vTpCiudad, "01", o_numsol, v_valor);


        -- **************************************
        -- Inicia Proceso de Circulo de Credito *
        -- **************************************

       { EXECUTE PROCEDURE cal_circulocredito(o_empresa, v_cliente)
           INTO scod_ret, v_paso, vCompromisos, vMensaje;

        IF scod_ret <> "000" THEN
                RETURN scod_ret;
        END IF

        UPDATE ss_resum_scor_fin
           SET evalua_cc = v_paso,
               motivo_cc= vMensaje,
               pago_minimo = v_compromisos
         WHERE empresa = o_empresa
           AND num_solicitud = o_numsol;

        IF v_paso = "1" THEN

		UPDATE ss_solicitudes SET status_solicitud = "RT"
		 WHERE empresa = o_empresa
		   AND num_solicitud = o_numsol;

		INSERT INTO ss_autorizacion
		 (empresa, ejecutivo_auto, num_solicitud, status_solicitud,
		  comentario, fecha_entrada, fecha_salida)
		VALUES
		 (o_empresa, "sistema", o_numsol, "RT",
	 	  "Evaluacion en Circulo de Credito Negativa, " ||
		  "Solicitud No Aprobada", v_hoy, v_hoy);

                RETURN scod_ret;
        END IF}

        UPDATE ss_resum_scor_fin
           SET evalua_cc = "0",
               motivo_cc= "Prueba",
               pago_minimo = 0
         WHERE empresa = o_empresa
           AND num_solicitud = o_numsol;


	-- ********************************
	-- Inicia Proceso de Calificacion *
	-- ********************************

	SELECT tipo_solicitud INTO v_tpsol
	  FROM ss_solicitudes
	 WHERE empresa = o_empresa
	   AND num_solicitud = o_numsol;

	FOREACH SELECT a.seccion INTO v_seccion
		  FROM ss_scoring_solic a, ss_scoring_seccion b
		 WHERE a.empresa = o_empresa
		   AND a.tp_solicitud = v_tpsol
                   AND b.empresa = a.empresa
		   AND b.seccion = a.seccion
		   AND b.automatico = "0"

	   -- ************
	   -- Explicitos *
	   -- ************
	   FOREACH SELECT grupo INTO v_grupo
		     FROM ss_scoring_grupo
		    WHERE empresa = o_empresa
		      AND seccion  = v_seccion
		      AND implicito = "0"


		SELECT SUM(valor) INTO v_valor
		  FROM ss_detalle_scoring
		 WHERE empresa = o_empresa
		   AND seccion = v_seccion
		   AND grupo = v_grupo
	    	   AND num_solicitud = o_numsol;

		IF v_valor IS NULL THEN
			LET v_valor = 0;
		END IF

		LET v_valor_ex = v_valor_ex + v_valor;

	   END FOREACH

	   -- ************
	   -- Implicitos *
	   -- ************
           FOREACH SELECT agrupar, valor, COUNT(*)
                     INTO v_paso, v_valor, v_cuantos
                     FROM ss_scoring_grupo a, ss_detalle_scoring b
                    WHERE a.empresa = o_empresa
                      AND a.seccion  = v_seccion
                      AND a.implicito = "1"
		      AND b.empresa = a.empresa
		      AND b.seccion = a.seccion
		      AND b.grupo = a.grupo
		      AND b.elemento = 1
		      AND b.num_solicitud = o_numsol
		    GROUP BY 1,2

		IF v_cuantos > 0 THEN
			LET v_valor_im = v_valor_im + v_valor;
		END IF

           END FOREACH

	   LET v_valor_1s = v_valor_ex + v_valor_im;

	END FOREACH

	-- ********************************
	-- Califica Comportamiento Interno*
	-- ********************************

	SELECT puntuacion INTO v_valor_2s
	  FROM ss_scoring_financ a, ss_resum_scor_fin b
	 WHERE b.empresa = o_empresa
	   AND b.num_solicitud = o_numsol
	   AND a.empresa = a.empresa
	   AND a.tp_solicitud = v_tpsol
	   AND (b.meses_historia >= a.min_mes_hist
	   AND b.meses_historia <= a.max_mes_hist )
	   AND (b.situacion_pago >= a.min_porc_pago
	   AND b.situacion_pago <= a.max_porc_pago)
	   AND a.circulo_credito = (SELECT DECODE(r.evalua_cc,"0","0",
							      "2","1",
							      "3","1",
    							      "4","1","1")
				      FROM ss_resum_scor_fin r
				     WHERE empresa = o_empresa
				       AND num_solicitud = o_numsol);

	IF v_valor_2s IS NULL THEN
		LET v_valor_2s = 0;
	END IF

	-- *************************************
	-- Almacena Resultado de la Evaluacion *
	-- *************************************
	LET v_valor = v_valor_1s + v_valor_2s;
	INSERT INTO ss_resumen_scoring
	  (empresa, num_solicitud, seccion, evaluacion)
	VALUES
	  (o_empresa, o_numsol, v_seccion, v_valor);


	-- ************************************
	-- Valida Resultado de la  Evaluacion *
	-- ************************************
	SELECT COUNT(*) INTO v_cuantos
	  FROM ss_scoring_solic
	 WHERE empresa = o_empresa
	   AND tp_solicitud = v_tpsol
	   AND seccion = v_seccion
	   AND (v_valor >= evaluacion_min
	   AND  v_valor <= evaluacion_max);

	IF v_cuantos IS NULL OR v_cuantos = 0 THEN
		UPDATE ss_solicitudes SET status_solicitud = "RT"
		 WHERE empresa = o_empresa
		   AND num_solicitud = o_numsol;

		INSERT INTO ss_autorizacion
		 (empresa, ejecutivo_auto, num_solicitud, status_solicitud,
		  comentario, fecha_entrada, fecha_salida)
		VALUES
		 (o_empresa, "sistema", o_numsol, "RT",
		  "Puntos acumulados en Scoring fueron insuficientes para " ||
		  "su Aprobacion", v_hoy, v_hoy);

		RETURN scod_ret;
	END IF

	-- *******************************
	-- Evalua Antiguedad del Cliente *
	-- *******************************

	-- Extrae Valor de Parametro
	SELECT valor INTO v_cuantos
	  FROM ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 300;

	-- Extrae Valor del Cliente
	SELECT meses_historia INTO v_valor
	  FROM ss_resum_scor_fin
	 WHERE empresa = o_empresa
	   AND num_solicitud = o_numsol;

	-- Valida para generacion de Orden de Supervision
	LET v_paso = "0";
	IF v_valor <= v_cuantos THEN
		INSERT INTO ss_solicitud_os
		  (empresa, num_solicitud, fecha_solicitud, status,
		   usuario_solicita)
		VALUES
		  (o_empresa, o_numsol, v_hoy, "S", "sistema");

		--EXECUTE PROCEDURE sp_os_integracion(o_numsol, v_hoy)
		--   INTO scod_ret;

                INSERT INTO ss_autorizacion
                 (empresa, ejecutivo_auto, num_solicitud, status_solicitud,
                  comentario, fecha_entrada, fecha_salida)
                VALUES
                 (o_empresa, "sistema", o_numsol, "EE",
                  "Solicitud Enviada a Orden de Supervision ", v_hoy, v_hoy);

		UPDATE ss_solicitudes SET status_solicitud = "EE"
		 WHERE empresa = o_empresa
		   AND num_solicitud = o_numsol;

		LET v_paso = "1"; -- Asigna Bandera para nuevos
	END IF

	-- *************************
	-- Genera Linea de Credito *
	-- *************************
	EXECUTE PROCEDURE determina_lincred_tc(o_empresa,
				 	       o_numsol,
					       v_paso)
	INTO scod_ret, v_valor;

	IF v_paso = "0" THEN -- Bandera que indica que esta en O.S.
        	UPDATE ss_solicitudes
	   	   SET monto_solicitado = v_valor,
	   	       status_solicitud = "AT"
         	 WHERE empresa = o_empresa
           	   AND num_solicitud = o_numsol;

                INSERT INTO ss_autorizacion
                 (empresa, ejecutivo_auto, num_solicitud, status_solicitud,
                  comentario, fecha_entrada, fecha_salida)
                VALUES
                 (o_empresa, "sistema", o_numsol, "AT",
                  "Solicitud Autorizada", v_hoy, v_hoy);
	ELSE
        	UPDATE ss_solicitudes
	   	   SET monto_solicitado = v_valor
         	 WHERE empresa = o_empresa
           	   AND num_solicitud = o_numsol;
	END IF
END
	RETURN scod_ret;

END PROCEDURE
;