CREATE PROCEDURE "informix".situacion_pago_banco(o_empresa CHAR(3),
				o_num_cliente   CHAR(20),
				o_producto      CHAR(4),
				o_sucursal      CHAR(4),
				o_ejecutivo     CHAR(8),
				o_bandera       CHAR(1))


RETURNING CHAR(5), CHAR(2), CHAR(20),CHAR(120),CHAR(20),CHAR(120), CHAR(1),
          CHAR(1), SMALLINT, CHAR(2), CHAR(3), CHAR(1), CHAR(3), CHAR(13), 
          CHAR(13), CHAR(2), CHAR(2), CHAR(20);

-- CONTROL DE CAMBIOS:		  
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--Modificación: Se modifica para asignar valor al puesto en base a los nuevos 
--              catálogos definidos.
--Petición:	Alta Única
--Fecha de Modificación: 05-11-2009
--------------------------------------------------------------------------------
--Modificacion: Se modifica para que la consulta a la tabla ss_scoring_solic
-- solo busque los registros antes de alta única
--Autor: Julio Cesar Polanco
--Fecha: 23/02/2009
--------------------------------------------------------------------------------
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE sql_err      SMALLINT;
DEFINE isam_err     SMALLINT;
DEFINE error_info   CHAR(100);
DEFINE v_nroref     SMALLINT;
DEFINE v_paramref   SMALLINT;
DEFINE s_tipper     CHAR(2);
DEFINE v_motivo     CHAR(1);
DEFINE v_tpsol      CHAR(1);
DEFINE v_eva_min    DECIMAL(5,2);
DEFINE v_eva_max    DECIMAL(5,2);
DEFINE v_porcen     DECIMAL(6,2);
DEFINE v_situacion  CHAR(1);
DEFINE v_producto   CHAR(4);
DEFINE v_fecha_apert DATE;
DEFINE s_referen1   CHAR(20);
DEFINE s_nomrefer1  CHAR(110);
DEFINE s_referen2   CHAR(20);
DEFINE s_nomrefer2  CHAR(110);
DEFINE s_numsol     CHAR(20);
DEFINE s_sexo       CHAR(1);
DEFINE s_edad       SMALLINT;
DEFINE s_edocivil   CHAR(1);
DEFINE v_meses      SMALLINT;
DEFINE s_habita_en  CHAR(2);
DEFINE s_puesto     CHAR(3);
DEFINE s_creditos   SMALLINT;
DEFINE s_profesion  CHAR(3);
DEFINE s_tel_ref_1  CHAR(13);
DEFINE s_tel_ref_2  CHAR(13);
DEFINE s_parentesco1 char(2);
DEFINE s_parentesco2 char(2);
DEFINE s_cteref      char(20);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET v_nroref     = 0;
LET v_paramref   = 0;
LET s_tipper     = "??";
LET v_tpsol      = "?";
LET v_eva_min    = 0;
LET v_eva_max    = 0;
LET v_porcen     = 0;
LET v_situacion  = "?";
LET v_producto   = "????";
LET s_referen1   = "??????????";
LET s_referen2   = "??????????";
LET s_nomrefer1  = "??????????";
LET s_sexo       = "?";
LET s_edad       = 0;
LET s_edocivil   = "?";
LET s_nomrefer2  = "??????????";
LET s_numsol     = "??????????";
LET s_habita_en  = "??";
LET s_puesto     = "??";
LET v_meses      = 0;
LET s_creditos   = 0;
LET s_profesion  = " ";
LET s_tel_ref_1  = " ";
LET s_tel_ref_2  = " ";
LET s_parentesco1 = " ";
LET s_parentesco2 = " ";
LET s_cteref      = " ";

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CargoLineaCredito.err";
   --   TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET scod_ret = sql_err;
      RETURN scod_ret, s_tipper, s_referen1, s_nomrefer1,
             s_referen2, s_nomrefer2, s_sexo, s_edocivil, s_edad, s_habita_en,
	     s_puesto, s_creditos, S_profesion, s_tel_ref_1, s_tel_ref_2,
             s_parentesco1, s_parentesco2, s_cteref;
   END EXCEPTION;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

	-- ***************************************
	-- Extrae el Tipo de Persona del Cliente *
	-- ***************************************
	SELECT tpo_persona, nvl(numcte_ref, " ") INTO s_tipper, s_cteref
	  FROM bdinteg:si_cliente
	 WHERE numcte = o_num_cliente;

	-- *******************************************************
	-- Extrae el numero de referencias por tipo de solicitud *
	-- *******************************************************
	SELECT NVL(nro_referencias,0), a.tp_solicitud
          INTO v_paramref, v_tpsol
	  FROM ss_tp_solicitud a, ss_solic_producto b
	 WHERE b.empresa = o_empresa
	   AND b.num_producto = o_producto
	   AND a.tp_solicitud = b.tp_solicitud;

	IF v_paramref = 0 OR v_paramref IS NULL THEN
		LET scod_ret = "100";
		RETURN scod_ret, s_tipper, s_referen1, s_nomrefer1,
		       s_referen2, s_nomrefer2, s_sexo, s_edocivil, s_edad,
		       s_habita_en, s_puesto, s_creditos,S_profesion, s_tel_ref_1, s_tel_ref_2,
		       s_parentesco1, s_parentesco2, s_cteref;
	END IF

	-- ****************************
	-- Valida Referencia Personas *
	-- ****************************
	SELECT COUNT(*) INTO v_nroref FROM ss_refpersonales
	 WHERE empresa = o_empresa
	   AND numcte = o_num_cliente;

	IF v_nroref IS NULL THEN
	   LET v_nroref = 0;
	END IF

	-- **************************
	-- Extrae Datos del Cliente *
	-- **************************

	SELECT a.sexo, a.estado_civil, a.habita_en,
	      (select year(fecha_hoy) from bdinteg:si_fechas)-year(a.fecha_nac), NVL(profesion, " ")
	  INTO s_sexo, s_edocivil, s_habita_en, s_edad, s_profesion
	  FROM bdinteg:si_ctepf a
	 WHERE a.numcte = o_num_cliente;

	SELECT puesto INTO s_puesto
	  FROM bdinteg:si_ingresos
	 WHERE empresa = o_empresa
          AND numcte = o_num_cliente
           AND sec_ingreso = 1
           AND tipo_ingreso = "T";

	IF s_puesto IS NULL THEN
		LET s_puesto = "09";
	END IF

	IF v_nroref < v_paramref AND o_bandera ="0" THEN
		LET scod_ret = "000";
		LET s_referen1 = " ";
		LET s_nomrefer1 =" ";
		LET s_referen2 = " ";
		LET s_nomrefer2 =" ";
                LET s_tel_ref_1 = " ";
		LET s_tel_ref_2 = " ";
		RETURN scod_ret, s_tipper, s_referen1, s_nomrefer1,
		       s_referen2, s_nomrefer2, s_sexo, s_edocivil, s_edad,
		       s_habita_en, s_puesto, s_creditos, S_profesion, s_tel_ref_1, s_tel_ref_2,
		       s_parentesco1, s_parentesco2, s_cteref;
	END IF

	LET v_nroref = 0;

--	FOREACH SELECT a.numcte_ref,
--		       NVL(razon_social," ") ||
--		       NVL(nombre1, " ") ||
--		       NVL(nombre2, " ") ||
--		       NVL(apell_paterno, " ") ||
--		       NVL(apell_materno, " ") nombre
--		  INTO s_referen2, s_nomrefer2
--		  FROM ss_refpersonales a, bdinteg:si_cliente b
--		 WHERE a.empresa = o_empresa
--		   AND a.numcte = o_num_cliente
--		   AND b.numcte  = a.numcte_ref
--
--		LET v_nroref = v_nroref + 1;
--		IF v_nroref = 1 THEN
--			LET s_referen1 = s_referen2;
--			LET s_nomrefer1 = s_nomrefer2;
--			LET s_referen2 = " ";
--			LET s_nomrefer2 = " ";
--		ELSE
--			EXIT FOREACH;
--		END IF
--	END FOREACH


	FOREACH SELECT a.numcte_ref, nvl(nombre_ref," "), nvl(telefono_ref, " "), nvl(parentesco, " ")
		  INTO s_referen2, s_nomrefer2, s_tel_ref_2, s_parentesco2
		  FROM ss_refpersonales a
		 WHERE a.empresa = o_empresa
		   AND a.numcte = o_num_cliente
		   AND not a.nombre_ref is null

		LET v_nroref = v_nroref + 1;

		IF v_nroref = 1 THEN
			LET s_referen1 = s_referen2;
			LET s_nomrefer1 = s_nomrefer2;
			LET s_tel_ref_1 = s_tel_ref_2;
			LET s_parentesco1 = s_parentesco2;
			LET s_referen2 = " ";
			LET s_nomrefer2 = " ";
			LET s_tel_ref_2 = " ";
			LET s_parentesco2 = " ";
		ELSE
			EXIT FOREACH;
		END IF
	END FOREACH


	-- ************************************
	-- Inicia Precalificacion del Cliente *
	-- ************************************

	SELECT porcentaje, situacion, fecha_apertura, num_producto
	  INTO v_porcen, v_situacion, v_fecha_apert, v_producto
	  FROM bdicred:sd_situacion_pago a, bdicred:sd_maecred b
	 WHERE b.numcte = o_num_cliente
	   AND b.empresa = o_empresa
	   AND a.empresa = b.empresa
	   AND a.num_credito = b.num_credito
	   AND a.fecha = (SELECT MAX(fecha) FROM bdicred:sd_situacion_pago s
			   WHERE s.empresa = b.empresa
			     AND s.num_credito = b.num_credito
			     AND s.porcentaje=(SELECT MIN(porcentaje)
					       FROM bdicred:sd_situacion_pago j
					       WHERE j.empresa = b.empresa
					      AND j.num_credito=b.num_credito));

	 --ORDER BY fecha_apertura;

	IF v_situacion IS NULL THEN
	   LET v_situacion = "O";
	END IF

	SELECT motivo_rechazo_sol INTO v_motivo
	  FROM bdicred:sd_situacion_cred
	 WHERE empresa = o_empresa
	   AND situacion = v_situacion;

	-- *****************************
	-- Valida Situacion de credito *
	-- *****************************
	IF v_motivo = "1" THEN
		LET scod_ret = "001";
		RETURN scod_ret, s_tipper, s_referen1, s_nomrefer1,
		       s_referen2, s_nomrefer2, s_sexo, s_edocivil, s_edad,
		       s_habita_en, s_puesto, s_creditos,s_profesion, s_tel_ref_1, s_tel_ref_2,
		       s_parentesco1, s_parentesco2, s_cteref;
	END IF

	-- *******************************************
	-- Extrae los rangos validos de calificacion *
	-- *******************************************

	SELECT evaluacion_min, evaluacion_max INTO v_eva_min, v_eva_max
	  FROM ss_scoring_solic
	 WHERE empresa = o_empresa
	   AND tp_solicitud = v_tpsol
	   AND seccion = 1
       AND tpo_persona = s_tipper
       AND activa = '0';

	-- *****************************
	-- Valida Situacion de Pago    *
	-- *****************************

	IF v_porcen IS NULL THEN
		LET v_porcen = v_eva_min;
	END IF

	IF v_porcen < v_eva_min OR v_porcen >  v_eva_max THEN
		LET scod_ret = "001";
		RETURN scod_ret, s_tipper, s_referen1, s_nomrefer1,
		       s_referen2, s_nomrefer2, s_sexo, s_edocivil, s_edad,
		       s_habita_en, s_puesto, s_creditos, s_profesion, s_tel_ref_1, s_tel_ref_2,
                   s_parentesco1, s_parentesco2, s_cteref;
	END IF

	-- *******************
	-- Meses de Historia *
	-- *******************
	SELECT (SELECT MONTH(fecha_hoy) FROM bdicred:sd_fechas) -
	        MONTH(v_fecha_apert)
	  INTO v_meses
	  FROM bdicred:sd_fechas
	 WHERE empresa = o_empresa;

	IF v_meses IS NULL THEN
		LET v_meses = 0;
	END IF

	IF o_bandera = "1" THEN
		LET s_referen1 = v_porcen;
		LET s_referen1 = 0;
		LET s_nomrefer1 = v_situacion;
		LET s_referen2  = v_meses;
		RETURN scod_ret, s_tipper, s_referen1, s_nomrefer1,
		       s_referen2, s_nomrefer2, s_sexo, s_edocivil, s_edad,
		       s_habita_en, s_puesto, s_creditos, s_profesion, s_tel_ref_1, s_tel_ref_2,
                       s_parentesco1, s_parentesco2, s_cteref;
	END IF


	-- ******************************************************************************
	-- Consulta si el Cliente ya tiene Historial Crediticio con el Banco 		*
	-- ******************************************************************************
	SELECT count(*) INTO s_creditos
	  FROM bdicred:sd_maecred
	 WHERE empresa = o_empresa and numcte = o_num_cliente and status_cred <> "CC";

	IF s_creditos IS NULL THEN
	   LET s_creditos = 0;
	END IF

	IF s_creditos > 0 THEN
	   LET s_creditos = 1;
	END IF

END
	RETURN scod_ret, s_tipper, s_referen1, s_nomrefer1,
	       s_referen2, s_nomrefer2, s_sexo, s_edocivil, s_edad,
	       s_habita_en, s_puesto, s_creditos, s_profesion, s_tel_ref_1, s_tel_ref_2,
             s_parentesco1, s_parentesco2, s_cteref;


END PROCEDURE;