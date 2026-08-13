CREATE PROCEDURE "informix".ctefisico(pempresa CHAR(3),
                          pfuncion CHAR(1),
                          pnumcte CHAR(20),
                          psucursal CHAR(4),
                          pejecutivo CHAR(8),
                          ptp_persona CHAR (2),
                          ptp_cliente CHAR(1),
                          ppaterno CHAR (26),
                          pmaterno CHAR (26),
                          pnombre1 CHAR (26),
                          pnombre2 CHAR (26),
                          prfc CHAR (13),
                          psector CHAR (2),
                          psegmento CHAR (3),
                          pactividad_princ CHAR (3),
                          pgrupo CHAR(3),
                          psubgrupo CHAR(3),
                          presidencia CHAR(1),
                          papell_casada CHAR(20),
                          pnumcte_ref char(20),
                          pdistrito CHAR(2),
                          ppuesto_ppes char(1),
                          pfamiliar_ppes char(1),
                          pactividad_esp char(11),
                          pfecha_nac date, -- Inician columnas de Ctepf
                          plugar_nac CHAR (2),
                          pnacionalidad CHAR(3),
                          pfm3 CHAR(18),
                          pestado_civil CHAR(1),
                          pregimen_mat CHAR(1),
                          pprofesion CHAR (3),
                          psexo CHAR(1),
                          pcurp CHAR(20),
                          pcodidentif CHAR(2),
                          pnumidentif CHAR(20),
                          pno_imss CHAR(12),
                          pdependientes smallint,
                          ptutor CHAR(60),
                          pemail CHAR(60),
                          pnom_conyuge CHAR(60),
                          pseguro_defunc CHAR(1),
                          pescolaridad CHAR(2),
                          phabita_en CHAR(20),
                          panios_habita SMALLINT,
                          pnombre_prop CHAR(60),
                          pimphiporenta MONEY(14,2),
                          pnumeroife char(20),
                          pnumerotutor char(20),
                          pnumeroconyuge char(20),
                          pejecut_autoriza char(8),
                          ppromocion char(2),
                          pnumhabitantes char (60))

  RETURNING CHAR(5),CHAR(20);

define vcodret CHAR(5);
define vfecha DATE;
define vsignumcte INT;
define vexiste CHAR(1);
define vempresa CHAR(3);
define vnumcte CHAR(20);
define vsucursal CHAR(4);
define vejecutivo CHAR(8);
define vejecut_autoriza CHAR(8);
define vtp_persona CHAR (2);
define vtp_cliente CHAR(1);
define vpaterno CHAR (26);
define vmaterno CHAR (26);
define vnombre1 CHAR (26);
define vnombre2 CHAR (26);
define vrfc CHAR (13);
define vsector CHAR (2);
define vsegmento CHAR (3);
define vactividad_princ CHAR (3);
define vgrupo CHAR(3);
define vsubgrupo CHAR(3);
define vresidencia CHAR(1);
define vapell_casada CHAR(20);
define vnumcte_referencia char(20);
define vdistrito CHAR(2);
define vpuesto_ppes char(1);
define vfamiliar_ppes char(1);
define vactividad_esp char(11);
define vfecha_nac date; -- Inician columnas de Ctepf
define vlugar_nac CHAR (2);
define vnacionalidad CHAR(3);
define vfm3 CHAR(18);
define vestado_civil CHAR(1);
define vregimen_mat CHAR(1);
define vprofesion CHAR (3);
define vsexo CHAR(1);
define vcurp CHAR(20);
define vcodidentif CHAR(2);
define vnumidentif CHAR(20);
define vno_imss CHAR(12);
define vdependientes smallint;
define vtutor CHAR(60);
define vemail CHAR(60);
define vnom_conyuge CHAR(60);
define vseguro_defunc CHAR(1);
define vescolaridad CHAR(2);
define vhabita_en CHAR(20);
define vanios_habita SMALLINT;
define vnombre_prop CHAR(60);
define vimphiporenta MONEY(14,2);
define vnumeroife char(20);
define vnumerotutor char(20);
define vnumeroconyuge char(20);
define vusuario char(8);
define vtppersona CHAR(2);
define vcont SMALLINT;
define vesfisica CHAR(1);
define vlongitud,vlong_cte SMALLINT;
define vsqlerr,visamerr INTEGER;
define vstatus_cte CHAR(2);
define vfecha_alta DATE;
define vrazon_soc CHAR(40);
define vcod_param smallint;
define vdescripcion char(40);
define vdiferencia,i smallint;
define vnumcte_ref char(20);
define vnumhabitantes char(60);
define cSucursalCajaUnica char(1);


LET vcodret = "000";
LET vempresa = pempresa;
LET vnumcte = " ";
LET vsucursal = psucursal;
LET vtppersona = ptp_persona;
LET vnumcte_ref = " ";
LET vejecut_autoriza = pejecut_autoriza;

BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,vnumcte;
   END IF;
END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/ctefisico.out';
	--TRACE ON;

SELECT fecha_hoy INTO vfecha
   FROM si_fechas
   WHERE empresa = pempresa;

IF pfuncion = "B" THEN
   LET vnumcte = pnumcte;
   SELECT tpo_persona INTO vtppersona
      FROM si_cliente
      WHERE numero = pnumero;
   IF vtppersona IS NULL THEN
      LET vnumcte = pnumcte;
      LET vcodret = "104";
      RETURN vcodret,vnumcte;
   ELSE
      SELECT es_fisica INTO vesfisica
         FROM si_tipper
         WHERE tpo_persona = vtppersona;
      IF UPPER(vesfisica) != "S" THEN
         LET vcodret = "120";
         RETURN vcodret,vnumcte;
      END IF;
   END IF
   SELECT COUNT(*) INTO vcont
      FROM bdicheq:sc_maechq
      WHERE numcte = pnumcte;
   IF vcont > 0 THEN
      LET vcodret = "121";
      RETURN vcodret,vnumcte;
   END IF
   SELECT COUNT(*) INTO vcont
      FROM bdisolic:ss_solicitudes
      WHERE empresa="001" and numcte = pnumcte;
   IF vcont > 0 THEN
      LET vcodret = "121";
      RETURN vcodret,vnumcte;
   END IF
   SELECT COUNT(*) INTO vcont
      FROM bdicred:sd_maecred
      WHERE numcte = pnumcte;
   IF vcont > 0 THEN
      LET vcodret = "121";
      RETURN vcodret,vnumcte;
   END IF
   SELECT COUNT(*) INTO vcont
      FROM bdinvers:sv_maeinv
      WHERE numcte = pnumcte;
   IF vcont > 0 THEN
      LET vcodret = "121";
      RETURN vcodret,vnumcte;
   END IF
   BEGIN
      DELETE FROM si_direcciones WHERE numcte = pnumcte;
      DELETE FROM si_refcomer WHERE numcte = pnumcte;
      DELETE FROM si_refbancarias WHERE numcte = pnumcte;
      DELETE FROM si_refper WHERE numcte = pnumcte;
      DELETE FROM si_ctepf WHERE numcte = pnumcte;
      DELETE FROM si_ingresos WHERE numcte = pnumcte;
      DELETE FROM si_cterelacionado WHERE empresa="001" and numcte = pnumcte;
      DELETE FROM si_cteppes WHERE numcte = pnumcte;
      DELETE FROM si_cliente WHERE numcte = pnumcte;
   END;
   RETURN vcodret,vnumcte;
END IF

IF pfuncion = "C" THEN
   LET vnumcte = pnumcte;
   SELECT empresa,     numcte,       status_cte,     sucursal,     ejecutivo,
          tpo_persona, tipo_cliente, apell_paterno,  apell_materno,
          nombre1,     nombre2,      razon_social,   rfc,
          sectOR,      segmento,     actividad_princ,grupo,
          subgrupo,    residencia,   fecha_alta,     apell_casada,
          distrito,    numcte_ref,   puesto_ppes,    familiar_ppes,
          actividad_princ,ejecut_autoriza, string2
      INTO vempresa,   vnumcte,      vstatus_cte,    vsucursal,   vejecutivo,
          vtppersona,  vtp_cliente,  vpaterno,       vmaterno,
          vnombre1,    vnombre2,     vrazon_soc,     vrfc,
          vsectOR,     vsegmento,    vactividad_princ,vgrupo,
          vsubgrupo,   vresidencia,  vfecha_alta,    vapell_casada,
          vdistrito,   vnumcte_ref,  vpuesto_ppes,   vfamiliar_ppes,
          vactividad_esp,vejecut_autoriza, vnumhabitantes
      FROM si_cliente
      WHERE numcte = pnumcte;

    IF vnumcte IS NULL THEN
      LET vcodret = "104";
      RETURN vcodret,vnumcte;
   END IF
   IF pempresa IS NULL OR pempresa = " " THEN
        LET pempresa = vempresa;
   END IF
   IF psucursal IS NULL OR psucursal = " " THEN
      LET psucursal=vsucursal;
   END IF;
   IF pejecutivo IS NULL OR pejecutivo = " " THEN
      LET pejecutivo=vejecutivo;
   END IF;
   IF ptp_persona IS NULL OR ptp_persona = " " THEN
      LET ptp_persona=vtppersona;
   END IF;
   IF ptp_cliente IS NULL OR ptp_cliente = " " THEN
      LET ptp_cliente = vtp_cliente;
   END IF;
   IF ptp_cliente = '2' AND vtp_cliente = '1' THEN
        LET ptp_cliente = vtp_cliente;
   END IF;
   IF ppaterno IS NULL OR ppaterno = " " THEN
      LET ppaterno=vpaterno;
   END IF;
   IF pmaterno IS NULL OR pmaterno = " " THEN
      LET pmaterno=vmaterno;
   END IF;
   IF pnombre1 IS NULL OR pnombre1 = " " THEN
      LET pnombre1=vnombre1;
   END IF;
   IF pnombre2 IS NULL OR pnombre2 = " " THEN
      LET pnombre2=vnombre2;
   END IF;
   IF prfc IS NULL OR prfc = " " THEN
      LET prfc=vrfc;
   END IF;
   IF psector IS NULL OR psector = " " THEN
      LET psectOR=vsectOR;
   END IF;
   IF psegmento IS NULL OR psegmento = " " THEN
      LET psegmento=vsegmento;
   END IF;
   IF pactividad_princ IS NULL OR pactividad_princ = " " THEN
      LET pactividad_princ=vactividad_princ;
   END IF;
   IF pgrupo IS NULL OR pgrupo = " " THEN
      LET pgrupo=vgrupo;
   END IF;
   IF psubgrupo IS NULL OR psubgrupo = " " THEN
      LET psubgrupo=vsubgrupo;
   END IF;
   IF presidencia IS NULL OR presidencia = " " THEN
      LET presidencia=vresidencia;
   END IF;
   IF papell_casada IS NULL OR papell_casada = " " THEN
      LET papell_casada = vapell_casada;
   END IF;
   IF pdistrito IS NULL OR pdistrito = " " THEN
      LET pdistrito=vdistrito;
   END IF;
   IF pnumcte_ref IS NULL OR pnumcte_ref = " " THEN
      LET pnumcte_ref=vnumcte_ref;
   END IF;
   IF ppuesto_ppes IS NULL OR ppuesto_ppes = " " THEN
      LET ppuesto_ppes=vpuesto_ppes;
   END IF;
   IF pfamiliar_ppes IS NULL OR pfamiliar_ppes = " " THEN
      LET pfamiliar_ppes=vfamiliar_ppes;
   END IF;
   IF pactividad_esp IS NULL OR pactividad_esp = " " THEN
      LET pactividad_esp=vactividad_esp;
   END IF;
   IF pejecut_autoriza IS NULL OR pejecut_autoriza = " " THEN
      LET pejecut_autoriza=vejecut_autoriza;
   END IF;
   SELECT numcte,         fecha_nac,       lugar_nac,        nacionalidad,
          no_fm3,         estado_civil,    regim_matrimonio, profesion,
          sexo,           curp,            codidentifi,      numidentifi,
          no_imss,        dependientes,    tutor,            email,
          nom_conyuge,    seguro_defunc,   escolaridad,      habita_en,
          anios_habita,   nombre_prop,     imp_hipo_renta,   numeroife,
          numerotutor,    numeroconyuge
      INTO vnumcte,       vfecha_nac,      vlugar_nac,       vnacionalidad,
          vfm3,           vestado_civil,   vregimen_mat,     vprofesion,
          vsexo,          vcurp,           vcodidentif,      vnumidentif,
          vno_imss,       vdependientes,   vtutor,           vemail,
          vnom_conyuge,   vseguro_defunc,  vescolaridad,     vhabita_en,
          vanios_habita,  vnombre_prop,    vimphiporenta,    vnumeroife,
          vnumerotutor,   vnumeroconyuge
      FROM si_ctepf
      WHERE numcte = pnumcte;
   IF pfecha_nac IS NULL OR pfecha_nac = " " THEN
      LET pfecha_nac=vfecha_nac;
   END IF;
   IF plugar_nac IS NULL OR plugar_nac = " " THEN
      LET plugar_nac=vlugar_nac;
   END IF;
   IF pnacionalidad IS NULL OR pnacionalidad = " " THEN
      LET pnacionalidad=vnacionalidad;
   END IF;
   IF pfm3 IS NULL OR pfm3 = " " THEN
      LET pfm3 = vfm3;
   END IF;
   IF pestado_civil IS NULL OR pestado_civil = " " THEN
      LET pestado_civil=vestado_civil;
   END IF;
   IF pregimen_mat IS NULL OR pregimen_mat = " " THEN
      LET pregimen_mat=vregimen_mat;
   END IF;
   IF pprofesion IS NULL OR pprofesion = " " THEN
      LET pprofesion = vprofesion;
   END IF;
   IF psexo IS NULL OR psexo = " " THEN
      LET psexo=vsexo;
   END IF;
   IF pcurp IS NULL OR pcurp = " " THEN
      LET pcurp = vcurp;
   END IF
   IF pcodidentif IS NULL OR pcodidentif = " " THEN
      LET pcodidentif = vcodidentif;
   END IF
   IF pnumidentif IS NULL OR pnumidentif = " " THEN
      LET pnumidentif = vnumidentif;
   END IF
   IF pno_imss IS NULL OR pno_imss = " " THEN
      LET pno_imss = vno_imss;
   END IF
   IF pdepENDientes IS NULL OR pdepENDientes = " " THEN
      LET pdepENDientes = vdepENDientes;
   END IF
   IF ptutor IS NULL OR ptutor = " " THEN
      LET ptutor = vtutor;
   END IF
   IF pemail IS NULL OR pemail = " " THEN
      LET pemail = vemail;
   END IF
   IF pnom_conyuge IS NULL OR pnom_conyuge = " " THEN
      LET pnom_conyuge = vnom_conyuge;
   END IF
--IF pseguro_definc IS NULL OR pseguro_defunc = " " THEN
--LET pseguro_defunc = vseguro_defunc;
--END IF
   IF pescolaridad IS NULL OR pescolaridad = " " THEN
        LET pescolaridad = vescolaridad;
   END IF
   IF phabita_en IS NULL OR phabita_en = " " THEN
        LET phabita_en = vhabita_en;
   END IF
   IF panios_habita IS NULL THEN
        LET panios_habita = vanios_habita;
   END IF
   IF pnombre_prop IS NULL OR pnombre_prop = " " THEN
        LET pnombre_prop = vnombre_prop;
   END IF
   IF pimphiporenta IS NULL THEN
        LET pimphiporenta = vimphiporenta;
   END IF
   IF pnumeroife IS NULL or pnumeroife = " " THEN
        LET pnumeroife = vnumeroife;
   END IF
   IF pnumerotutor IS NULL or pnumerotutor = " " THEN
        LET pnumerotutor = vnumerotutor;
   END IF
   IF pnumeroconyuge IS NULL or vnumeroconyuge = " " THEN
        LET pnumeroconyuge = vnumeroconyuge;
   END IF
END IF

--- Verifica recepcion correcta de datos
IF psucursal IS NULL OR pejecutivo IS NULL
   OR ptp_persona IS NULL OR ptp_cliente IS NULL
   OR ppaterno IS NULL OR pnombre1 IS NULL OR prfc IS NULL
   OR psector IS NULL OR psegmento IS NULL
   OR pactividad_princ IS NULL OR pgrupo IS NULL
   OR psubgrupo IS NULL OR presidencia IS NULL
   OR ppuesto_ppes IS NULL OR pfamiliar_ppes IS NULL
   OR pfecha_nac IS NULL or plugar_nac IS NULL
   OR pnacionalidad IS NULL OR pestado_civil IS NULL
   OR pprofesion IS NULL OR psexo IS NULL
   OR pcodidentif IS NULL OR pnumidentif IS NULL
   OR pdependientes IS NULL OR pescolaridad is null
   OR phabita_en IS NULL THEN
   LET vcodret = "110";
   RETURN vcodret,vnumcte;
END IF;

SELECT es_fisica INTO vesfisica
   FROM si_tipper
   WHERE tpo_persona = ptp_persona;
IF UPPER(vesfisica) != "S" THEN
   LET vcodret = "120";
   RETURN vcodret,vnumcte;
END IF;

SELECT 1 INTO vexiste
   FROM si_sucursales
   WHERE sucursal=psucursal;
IF vexiste IS NULL THEN
   LET vcodret="111";
   RETURN vcodret,vnumcte;
END IF;

SELECT 1 INTO vexiste
   FROM si_ejecut
   WHERE ejecutivo=pejecutivo;
IF vexiste IS NULL THEN
   LET vcodret="112";
   RETURN vcodret,vnumcte;
END IF;

SELECT 1 INTO vexiste
   FROM si_sector
   WHERE sector=psector;
IF vexiste IS NULL THEN
   LET vcodret="113";
   RETURN vcodret,vnumcte;
END IF;

SELECT 1 INTO vexiste
   FROM si_segment
   WHERE segmento=psegmento;
IF vexiste IS NULL THEN
   LET vcodret="114";
   RETURN vcodret,vnumcte;
END IF;

SELECT 1 INTO vexiste
   FROM si_grupos
   WHERE grupo=pgrupo;
IF vexiste IS NULL THEN
   LET vcodret="115";
   RETURN vcodret,vnumcte;
END IF;

SELECT 1 INTO vexiste
   FROM si_subgpos
   WHERE subgrupo=psubgrupo;
IF vexiste IS NULL THEN
   LET vcodret="116";
   RETURN vcodret,vnumcte;
END IF;

SELECT 1 INTO vexiste
   FROM si_nacion
   WHERE nacion=pnacionalidad;
IF vexiste IS NULL THEN
   LET vcodret="124";
   RETURN vcodret,vnumcte;
END IF;

{SELECT 1 INTO vexiste
   FROM si_actesp
   WHERE codigo=pactividad_esp;
IF vexiste IS NULL THEN
   LET vcodret="125";
   RETURN vcodret,vnumcte;
END IF;}

SELECT 1 INTO vexiste
   FROM si_profesion
   WHERE profesion = pprofesion;
IF vexiste IS NULL THEN
   LET vcodret="126";
   RETURN vcodret,vnumcte;
END IF;

let prfc=Trim(prfc);
SELECT 1 INTO vexiste
   FROM si_cliente
   WHERE rfc = prfc;
IF not vexiste IS NULL and pfuncion = "A" THEN
   LET vcodret="106";
   RETURN vcodret,vnumcte;
END IF
{SELECT 1 INTO vexiste
   FROM si_escolaridad
   WHERE escolaridad = pescolaridad;
IF vexiste IS NULL THEN
   LET vcodret="135";
   RETURN vcodret,vnumcte;
END IF;
}

if Trim(pcodidentif) <> "" then
   SELECT 1 INTO vexistE
      FROM si_tipoidentif
      WHERE codidentif = pcodidentif;
   IF vexiste IS NULL THEN
      LET vcodret="133";
      RETURN vcodret,vnumcte;
   end if
END IF;

{SELECT 1 INTO vexiste
   FROM si_habitaen
   WHERE habita_en = phabita_en;
IF vexiste IS NULL THEN
   LET vcodret="117";
   RETURN vcodret,vnumcte;
END IF;} -- Revisar MAC

IF ptp_cliente = "M" THEN ---MenOR de edad
   IF ptutor IS NULL OR ptutor = "" THEN
      LET vcodret = "144";
      RETURN vcodret,vnumcte;
   END IF
   SELECT 1 INTO vexiste
      FROM si_cliente
      WHERE numcte = ptutor;
   IF vexiste IS NULL THEN
      LET vcodret = "145";
      RETURN vcodret,vnumcte;
   END IF
END IF;

IF pnumcte IS NULL OR pnumcte = " " THEN
   SELECT valor
     INTO vlong_cte
     FROM si_param
    WHERE cod_param = 7
      AND empresa = pempresa;

   IF vlong_cte IS NULL THEN
      LET vcodret="105";
      RETURN vcodret,vnumcte;
   ELSE
      SELECT valor INTO vsignumcte
         FROM si_param
         WHERE empresa = pempresa and cod_param = 6;
      if vsignumcte is null then
         let vsignumcte = 1;
      end if
      LET vnumcte=vsignumcte;
      LET vsignumcte=vsignumcte + 1;
      UPDATE si_param
         SET (valor) = (vsignumcte)
         WHERE empresa = pempresa and cod_param = 6;
      let vdiferencia = vlong_cte - length(vnumcte);
      if vdiferencia > 0 then
         for i = 1 to vdiferencia
             let vnumcte = "0" || vnumcte;
         end for;
      end if
   END IF;
ELSE
   LET vnumcte = pnumcte;
END IF;

-- ****************** Actualizacion de Parametros *****************
IF pfuncion="A" THEN
   SELECT 1 INTO vexiste FROM si_cliente
      WHERE numcte = vnumcte;
   IF vexiste = "1" THEN
      LET vcodret="118";
      RETURN vcodret,vnumcte;
   END IF;

   BEGIN
      INSERT INTO si_cliente
        (empresa,      numcte,        status_cte,     sucursal,
         ejecutivo,    tpo_persona,   tipo_cliente,   apell_paterno,
         apell_materno,nombre1,       nombre2,        razon_social,
         rfc,          sectOR,        segmento,       actividad_princ,
         grupo,        subgrupo,      residencia,     fecha_alta,
         apell_casada, distrito,      numcte_ref,     string1,
         string2,      numeric1,      numeric2,       money1,
         date1,        puesto_ppes,   familiar_ppes,  actividad_esp,
         ejecut_autoriza,user_insert, fecha_insert)
      VALUES
         (pempresa,         vnumcte,      "AL",           psucursal,
          pejecutivo,       ptp_persona,  ptp_cliente,    ppaterno,
          pmaterno,         pnombre1,     pnombre2,       " ",
          prfc,             psectOR,      psegmento,      pactividad_princ,
          pgrupo,           psubgrupo,    presidencia,    vfecha,
          papell_casada,    pdistrito,    pnumcte_ref,    "",
          pnumhabitantes,   0,            0,              0,
          "",           ppuesto_ppes, pfamiliar_ppes, pactividad_esp,
          pejecut_autoriza,pejecutivo,  vfecha);

      INSERT INTO si_ctepf
          (numcte,         fecha_nac,      lugar_nac,        nacionalidad,
           no_fm3,         estado_civil,   regim_matrimonio, profesion,
           sexo,           curp,           codidentifi,      numidentifi,
           no_imss,        dependientes,   tutor,            email,
           nom_conyuge,    empresa,
           seguro_defunc,  escolaridad,habita_en,        anios_habita,
           nombre_prop,    imp_hipo_renta, string1)
      VALUES
         (vnumcte,        pfecha_nac,     plugar_nac,       pnacionalidad,
          pfm3,           pestado_civil,  pregimen_mat,     pprofesion,
          psexo,          pcurp,          pcodidentif,      pnumidentif,
          pno_imss,       pdependientes,  ptutor,           pemail,
          pnom_conyuge,   pempresa,
          pseguro_defunc, pescolaridad,   phabita_en,       panios_habita,
          pnombre_prop,   pimphiporenta,  ppromocion);
		  
		SELECT NVL(cajaunica, '') 
			INTO cSucursalCajaUnica  
		FROM bditarjcop:sucursalescajaunica
		WHERE cvesucursal = psucursal;

		IF cSucursalCajaUnica = 'V' THEN
			UPDATE si_cliente SET string1 = '1' WHERE numcte = vnumcte; 
		END IF;
   END;
   RETURN vcodret,vnumcte;
ELSE
   SELECT 1 INTO vexiste FROM si_cliente
      WHERE numcte = vnumcte;
   IF vexiste IS NULL THEN
      LET vcodret="104";
      RETURN vcodret,vnumcte;
   END IF;

   BEGIN
      -- Se Desactiva por Requerimiento de Bancoppel JLP 18/09/07
      UPDATE si_cliente
         SET(ejecutivo,     tpo_persona, tipo_cliente,
             --apell_paterno, apell_materno, nombre1,     nombre2,
             --rfc,           sectOR,        segmento,    actividad_esp,
             sectOR,        segmento,    actividad_esp,
             grupo,         subgrupo,      residencia,  fecha_alta,
             apell_casada,         distrito, string2)
           =
            (pejecutivo,    ptp_persona, ptp_cliente,
             --ppaterno,      pmaterno,      pnombre1,    pnombre2,
             psector,       psegmento,   pactividad_esp,
             pgrupo,        psubgrupo,     presidencia, vfecha,
             papell_casada,        pdistrito, pnumhabitantes)
       WHERE numcte = vnumcte;
      UPDATE si_ctepf
         SET(fecha_nac,      lugar_nac,       nacionalidad,    no_fm3,
             estado_civil,   regim_matrimonio,profesion,       sexo,
             curp,           codidentifi,     numidentifi,      no_imss,
             dependientes,   tutor,           email,           nom_conyuge,
             seguro_defunc,  escolaridad, habita_en,       anios_habita,
             nombre_prop,    imp_hipo_renta)
           =
            (pfecha_nac,     plugar_nac,     pnacionalidad,     pfm3,
             pestado_civil,  pregimen_mat,   pprofesion,        psexo,
             pcurp,          pcodidentif,    pnumidentif,       pno_imss,
             pdependientes,  ptutor,         pemail,            pnom_conyuge,
             pseguro_defunc, pescolaridad,phabita_en,       panios_habita,
             pnombre_prop,   pimphiporenta)
         WHERE numcte = vnumcte;
   END;
END IF;
RETURN vcodret,vnumcte;
END;
END PROCEDURE
DOCUMENT
"Alta, Baja y/o Cambio de cliente persona fisica ",
"AutOR : Procesamiento Interactivo S.A. de C.V.",
"FECHA : 14/Marzo/2008",
"Ver.  : 1.1",
"BD    : bdinteg",
"MODIFICO : Moreno Cota Jesus Alberto",
"MODIFICACION: Se agrega cantidad de personas vivien domicilio",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : Gaxiola Gaxiola Frank",
"MODIFICACION: Se agrega validación para cuando la sucursal este activa como caja unica", 
"marque al cliente en el campo string1 como cliente nacido en caja unica",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_activardesactivartokenbpi(psTipo CHAR(1), psEmpresa CHAR(3), psNumCte CHAR(20), psStatusToken SMALLINT,
                    psSucursal CHAR(4), psNumEmpleado CHAR(9))
    RETURNING CHAR(5), CHAR(10);

--Declaracion de variables

DEFINE vsCodRet CHAR(5);
DEFINE viSqlErr INTEGER;
DEFINE viEdoCte SMALLINT;
DEFINE vsSolicitud CHAR(10);
DEFINE vdFecha  DATE;

--SET DEBUG FILE TO "/tmp/sp_ActivarDesactivarTokenBPI.out";
--TRACE ON;

--Asignacion de variables

LET vsCodRet = '00000';
LET viSqlErr = 0;
LET vsSolicitud = '';
LET vdFecha = '01-01-1900';

IF NVL(psTipo, '') = '' OR  NVL(psEmpresa, '') = '' OR NVL(psNumCte, '') = ''  OR  NVL(psStatusToken, '') = '' OR NVL(psSucursal, '') = '' OR NVL(psNumEmpleado, '') = '' THEN --Valida que  no sean nulo o espacio en blanco
    LET vsCodRet = '-2';
END IF;

--Inicio del procedimiento

BEGIN

    ON EXCEPTION SET viSqlErr --Manejador de Errores
        IF viSqlErr <> 0 then
            LET vsCodRet = viSqlErr;
            RETURN vsCodRet, vsSolicitud;
        END IF;
    END EXCEPTION;

    IF vsCodRet = '00000' THEN
        IF psTipo = '1' THEN        ---activavión

            LET vsSolicitud = (SELECT MAX(solicitud) FROM bdibpi:bpi_tokensolicitud WHERE numcte = psNumCte AND empresa = psEmpresa);

            UPDATE bdibpi:bpi_tokensolicitud SET id_status =  psStatusToken, f_solicitud = CURRENT, sucursal = psSucursal, usr_solicita = psNumEmpleado
            WHERE numcte = psNumCte AND empresa = psEmpresa AND solicitud = vsSolicitud;

            LET vdFecha = (SELECT MAX(f_registro::DATE) FROM bdinteg:si_bpitoken WHERE num_cliente =  psNumCte AND  empresa = psEmpresa);

            UPDATE bdinteg:si_bpitoken SET id_status_token = psStatusToken, f_status = CURRENT  WHERE empresa = TRIM(psEmpresa) AND num_cliente = TRIM(psNumCte)
            AND f_registro::DATE = vdFecha;

      --  ELIF psTipo = '2' OR psTipo = '3' THEN        -- Desactivacion    ---Consulta el último número de solicitud del cliente
         ELIF psTipo = '3' THEN
            LET vsSolicitud = (SELECT MAX(solicitud) FROM bdibpi:bpi_tokensolicitud WHERE numcte = psNumCte AND empresa = psEmpresa);

         --   IF psTipo = '2' THEN
         --       UPDATE bdibpi:bpi_tokensolicitud SET id_status =  psStatusToken
         --       WHERE numcte = psNumCte AND empresa = psEmpresa AND solicitud = vsSolicitud;
         --   END IF;

         ELSE
            LET vsCodRet = '-1';
        END IF
    END IF

   RETURN vsCodRet, vsSolicitud;

END
END PROCEDURE
DOCUMENT
"Realiza el envio de solicitud a central, y/o la consulta de la solicitud mas reciente del cliente",
"Autor : Dulce Ramírez",
"FECHA : Noviembre de 2009",
"Ver.  : 1.0",
"BD    : bdibpi",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_consultarclientebpi(pTipo CHAR(1), pEmpresa CHAR(3), pNumCte CHAR(20))

    --DATOS A REGRESAR---
    RETURNING
    CHAR(5),   -- Codigo de Retorno
    CHAR(10), -- Fecha Nacimiento
    CHAR(20), -- Numero de Cliente
    CHAR(26), -- Apellido Paterno
    CHAR(26), -- Apellido Materno
    CHAR(26), -- Nombre1
    CHAR(26), -- Nombre2
    CHAR(2),  -- Id Status
    CHAR(40), -- Descripción Status
    CHAR(165); -- Descrición Validación

    --DEFINICION DE VARIABLES--
    DEFINE sql_err      INT;
    DEFINE vCodRet      CHAR(5);
    DEFINE vFechaNac    CHAR(10);
    DEFINE vNumCte      CHAR(20);
    DEFINE vApePat      CHAR(26);
    DEFINE vApeMat      CHAR(26);
    DEFINE vNombre1     CHAR(26);
    DEFINE vNombre2     CHAR(26);
    DEFINE vStatus      CHAR(2);
    DEFINE vDescStatus  CHAR(40);
    DEFINE vMensValid   CHAR(165);
    DEFINE vTipoPersona CHAR(2);
    DEFINE cOperacion   CHAR(4);

        --INICIALIZACION DE VARIABLES--
    LET sql_err =   0;
    LET vCodRet =   '000';
    LET vFechaNac = '01/01/1900';
    LET vNumCte =   '';
    LET vApePat =   '';
    LET vApeMat =   '';
    LET vNombre1 =  '';
    LET vNombre2 =  '';
    LET vStatus     = '';
    LET vDescStatus = '';
    LET vMensValid  = '';
    LET vTipoPersona = '';
    LET cOperacion = '';

    --SET DEBUG FILE TO "/tmp/SP_ConsultarClienteBPI.out";
    --TRACE ON;

BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET vCodRet = sql_err;
            RETURN vCodRet, vFechaNac, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vStatus, vDescStatus, vMensValid;
        END IF;
    END EXCEPTION;

    IF EXISTS(SELECT numcte FROM bdinteg:si_cliente WHERE numcte = pNumCte and tpo_persona = '01') THEN
        IF pTipo = '1' THEN
            IF (SELECT count(id_status) FROM bdinteg:si_bpiusuarios WHERE numcte = pNumCte AND id_status <> '99') = 0 THEN
                IF (SELECT count(cuenta) FROM bdicheq:sc_maechq WHERE num_cte = pNumCte AND producto IN (SELECT producto FROM bdibpi:bpi_pprod WHERE id_oper = '1012')) > 0 THEN
                    IF EXISTS(SELECT bdi_sictepf.fecha_nac, bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2, bdi_sibpi.id_status
                              FROM bdinteg:si_cliente bdi_sicte, bdinteg:si_ctepf bdi_sictepf, bdinteg:si_bpiusuarios bdi_sibpi
                              WHERE bdi_sicte.numcte = pNumCte
                              AND bdi_sicte.empresa = pEmpresa
                              AND bdi_sicte.tpo_persona = '01'
                              AND bdi_sicte.numcte = bdi_sictepf.numcte
                              AND bdi_sicte.numcte  = bdi_sibpi.numcte) THEN

                        SELECT bdi_sictepf.fecha_nac, bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2, bdi_sibpi.id_status
                        INTO vFechaNac, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vStatus
                        FROM bdinteg:si_cliente bdi_sicte, bdinteg:si_ctepf bdi_sictepf, bdinteg:si_bpiusuarios bdi_sibpi
                        WHERE bdi_sicte.numcte = pNumCte
                        AND bdi_sicte.empresa = pEmpresa
                        AND bdi_sicte.tpo_persona = '01'
                        AND bdi_sicte.numcte = bdi_sictepf.numcte
                        AND bdi_sicte.numcte  = bdi_sibpi.numcte;
                    ELSE
                        SELECT bdi_sictepf.fecha_nac, bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2
                        INTO vFechaNac, vNumCte, vApePat, vApeMat, vNombre1, vNombre2
                        FROM bdinteg:si_cliente bdi_sicte, bdinteg:si_ctepf bdi_sictepf
                        WHERE bdi_sicte.numcte = pNumCte
                        AND bdi_sicte.empresa = pEmpresa
                        AND bdi_sicte.tpo_persona = '01'
                        AND bdi_sicte.numcte = bdi_sictepf.numcte
                        AND bdi_sicte.numcte = bdi_sictepf.numcte;
                    END IF;

                ELSE
                    LET vCodRet = '003';
                    LET vMensValid =   'Este usuario no puede ser pre-activado ya que aún no cuenta con alguno de los productos establecidos para otorgarle este servicio';
                END IF;
            ELSE
                LET vCodRet = '002';
                LET vMensValid =   'El Cliente ya tiene activado el servicio';
            END IF;
        ELIF pTipo = '2' THEN
            IF (SELECT count(id_status) FROM bdinteg:si_bpiusuarios WHERE numcte = pNumCte) > 0 THEN
                IF (SELECT count(cuenta) FROM bdicheq:sc_maechq WHERE num_cte = pNumCte AND producto IN (SELECT producto FROM bdibpi:bpi_pprod WHERE id_oper = '1012')) > 0 THEN
                    SELECT id_status INTO vStatus FROM bdinteg:si_bpiusuarios WHERE numcte = pNumCte;

                    IF vStatus = '99' THEN
                        LET vCodRet = '005';
                        LET vMensValid =   'El cliente presenta estatus de cancelado, si requiere el servicio de banca por internet es necesario ingresar a la sección de Activación de servicio por Internet';
                    ELSE
                        SELECT bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2, bdi_sibpi.id_status, bdi_sista.desc_status
                        INTO vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vStatus, vDescStatus
                        FROM bdinteg:si_cliente bdi_sicte,
                            bdinteg:si_ctepf bdi_sictepf,
                            bdinteg:si_bpiusuarios bdi_sibpi,
                            bdinteg:si_bpistatus bdi_sista
                        WHERE bdi_sicte.numcte = pNumCte
                        AND bdi_sicte.empresa = pEmpresa
                        AND bdi_sicte.tpo_persona = '01'
                        AND bdi_sicte.numcte = bdi_sictepf.numcte
                        AND bdi_sicte.numcte = bdi_sibpi.numcte
                        AND bdi_sista.id_status = vStatus;
                    END IF;
                ELSE
                    LET vCodRet = '006';
                    LET vMensValid =  'Este usuario no puede ser bloqueado/desbloqueado ya que aún no cuenta con alguno de los productos establecidos para otorgarle este servicio';
                END IF;
            ELSE
                LET vCodRet =   '004';
                LET vMensValid =   'El Cliente no tiene activado el servicio';
            END IF;
        END IF;
    ELSE
        SELECT tpo_persona
        INTO vTipoPersona
        FROM bdinteg:si_cliente
        WHERE numcte = pNumcte;

        IF vTipoPersona = '02' THEN
            LET vCodRet = '002';
            LET vMensValid = 'Cliente Moral, verifique';
        ELSE
            LET vCodRet =   '001';
            LET vMensValid = 'Cliente no Existe';
        END IF
    END IF;
    RETURN vCodRet, vFechaNac, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vStatus, vDescStatus, vMensValid;
END
END PROCEDURE;