CREATE PROCEDURE "informix".consnumcte_n_v1(pempresa CHAR(3),pnumcte CHAR(20))
RETURNING -------- DATOS SI_CLIENTE --------
          CHAR(5),      -- Codigo de retorno
          CHAR(3),      -- Empresa
          CHAR(20),     -- Num de cliente
          CHAR(2),      -- Status Cliente
          CHAR(4),      -- Sucursal
          CHAR(8),      -- ejecutivo
          CHAR(2),      -- Tipo persona
          CHAR(1),      -- Tipo cliente
          CHAR(26),     -- Apellido parterno
          CHAR(26),     -- Apellido Materno
          CHAR(26),     -- Nombre1
          CHAR(26),     -- Nombre2
          CHAR(60),     -- razon social
          CHAR(13),     -- rfc
          CHAR(2),      -- Sector
          CHAR(3),      -- Segmento
          CHAR(3),      -- Actividad Principal
          CHAR(3),      -- Grupo
          CHAR(3),      -- Subgrupo
          CHAR(1),      -- Residencia
          DATE,         -- Fecha Alta
          CHAR(26),     -- Apellido Casada
          CHAR(2),      -- Distrito
          CHAR(20),     -- numcte_ref
          CHAR(20),     -- String1
          CHAR(60),     -- String2
          SMALLINT,     -- Numeric1
          INTEGER,      -- Numeric2
          MONEY(14,2),  -- Money1
          DATE,         -- Date1
          CHAR(1),      -- puesto_ppes
          CHAR(1),      -- familiar_ppes
          CHAR(11),     -- actividad_esp
          CHAR(8),      -- ejecut_autoriza
          CHAR(8),      -- user_insert
          DATE,         -- Fecha_insert
          CHAR(13),     -- rfc_alterno
		  CHAR(03),	--id_pais		DSB230162JERV1694
          -------- DATOS SI_CTEPF --------
          CHAR(3),      -- Empresa
          CHAR(20),     -- Num de cliente
          DATE,         -- Fecha_nac
          CHAR(2),      -- Lugar_nac
          CHAR(3),      -- Nacionalidad
          CHAR(18),     -- no_fm3
          CHAR(2),      -- Estado Civil
          CHAR(1),      -- regim_matrimonio
          CHAR(3),      -- Profesion
          CHAR(1),      -- Sexo
          CHAR(20),     -- Curp
          CHAR(2),      -- codidentifi 
          CHAR(20),     -- numidentifi
          CHAR(12),     -- no_imss
          SMALLINT,     -- Dependientes
          CHAR(60),     -- Tutor
          CHAR(60),     -- Email
          CHAR(60),     -- Nom_conyuge
          CHAR(1),      -- seguro_defunc
          CHAR(2),      -- escolaridad
          CHAR(2),      -- habita_en
          SMALLINT,     -- anios_habita
          CHAR(60),     -- nombre_prop
          MONEY(16,2),  -- imp_hipo_renta
          CHAR(30),     -- actividadogiro
          CHAR(20),     -- numeroife
          CHAR(20),     -- numerotutor
          CHAR(20),     -- numeroconyuge
          CHAR(20),     -- string1
          CHAR(20),     -- string2
          INTEGER,      -- numeric1
          INTEGER,      -- numeric2
          MONEY(14,2),  -- money1
          DATE,         -- date1
          CHAR(8),      -- user_insert
          DATE,         -- Fecha_insert
		  CHAR(03);	-- id_pais		DSB230162JERV1694

    -- Definición de Variables
    DEFINE vcodret CHAR(5);
    DEFINE vesfisica CHAR(1);
    DEFINE vlong_cte SMALLINT;
    DEFINE vlongitud SMALLINT;
    DEFINE vsqlerr INTEGER;
    DEFINE vdiacorte SMALLINT;

    -- si_cliente
    DEFINE vempresa CHAR(3);
    DEFINE vnumcte CHAR(20);
    DEFINE vstatus_cte CHAR(2);
    DEFINE vsucursal CHAR(4);
    DEFINE vejecutivo CHAR(8);
    DEFINE vtpo_persona CHAR(2);
    DEFINE vtipo_cliente CHAR(1);
    DEFINE vapell_paterno CHAR(26);
    DEFINE vapell_materno CHAR(26);
    DEFINE vnombre1 CHAR(26);
    DEFINE vnombre2 CHAR(26);
    DEFINE vrazon_social CHAR(60);
    DEFINE vrfc CHAR(13);
    DEFINE vsector CHAR(2);
    DEFINE vsegmento CHAR(3);
    DEFINE vactividad_princ CHAR(3);
    DEFINE vgrupo CHAR(3);
    DEFINE vsubgrupo CHAR(3);
    DEFINE vresidencia CHAR(1);
    DEFINE vfecha_alta DATE ;
    DEFINE vapell_casada CHAR(26);
    DEFINE vdistrito CHAR(2);
    DEFINE vnumcte_ref CHAR(20);
    DEFINE vstring1 CHAR(20);
    DEFINE vstring2 CHAR(60);
    DEFINE vnumeric1 SMALLINT ;
    DEFINE vnumeric2 INTEGER ;
    DEFINE vmoney1 MONEY(14,2);
    DEFINE vdate1 DATE;
    DEFINE vpuesto_ppes CHAR(1);
    DEFINE vfamiliar_ppes CHAR(1);
    DEFINE vactividad_esp CHAR(11);
    DEFINE vejecut_autoriza CHAR(8);
    DEFINE vuser_insert CHAR(8);
    DEFINE vfecha_insert DATE;
    DEFINE vrfc_alterno CHAR(13);
	DEFINE vid_pais CHAR(03);			--DSB230162JERV1694
    -- si_ctepf
    DEFINE vpfempresa CHAR(3);
    DEFINE vpfnumcte CHAR(20);
    DEFINE vpffecha_nac DATE;
    DEFINE vpflugar_nac CHAR(2);
    DEFINE vpfnacionalidad CHAR(3);
    DEFINE vpfno_fm3 CHAR(18);
    DEFINE vpfestado_civil CHAR(2);
    DEFINE vpfregim_matrimonio CHAR(1);
    DEFINE vpfprofesion CHAR(3);
    DEFINE vpfsexo CHAR(1);
    DEFINE vpfcurp CHAR(20);
    DEFINE vpfcodidentifi CHAR(2);
    DEFINE vpfnumidentifi CHAR(20);
    DEFINE vpfno_imss CHAR(12);
    DEFINE vpfdependientes SMALLINT ;
    DEFINE vpftutor CHAR(60);
    DEFINE vpfemail CHAR(60);
    DEFINE vpfpfnom_conyuge CHAR(60);
    DEFINE vpfseguro_defunc CHAR(1);
    DEFINE vpfescolaridad CHAR(2);
    DEFINE vpfhabita_en CHAR(2);
    DEFINE vpfanios_habita SMALLINT ;
    DEFINE vpfnombre_prop CHAR(60);
    DEFINE vpfimp_hipo_renta MONEY(16,2);
    DEFINE vpfactividadogiro CHAR(30);
    DEFINE vpfnumeroife CHAR(20);
    DEFINE vpfnumerotutor CHAR(20);
    DEFINE vpfnumeroconyuge CHAR(20);
    DEFINE vpfstring1 CHAR(20);
    DEFINE vpfstring2 CHAR(20);
    DEFINE vpfnumeric1 INTEGER ;
    DEFINE vpfnumeric2 INTEGER ;
    DEFINE vpfmoney1 MONEY(14,2);
    DEFINE vpfdate1 DATE;
    DEFINE vpfuser_insert CHAR(8);
    DEFINE vpffecha_insert DATE;
	DEFINE vpid_pais CHAR(03);			--DSB230162JERV1694

    -- Inicializacion de variables
    LET vcodret = "";
    LET vesfisica = "";
    LET vlong_cte = 0;
    LET vlongitud = 0;
    LET vsqlerr = 0;
    LET vdiacorte = 0;
    -- si_cliente
    LET vempresa  = "";
    LET vnumcte  = "";
    LET vstatus_cte  = "";
    LET vsucursal = "";
    LET vejecutivo = "";
    LET vtpo_persona = "";
    LET vtipo_cliente = "";
    LET vapell_paterno = "";
    LET vapell_materno = "";
    LET vnombre1 = "";
    LET vnombre2 = "";
    LET vrazon_social = "";
    LET vrfc = "";
    LET vsector = "";
    LET vsegmento = "";
    LET vactividad_princ = "";
    LET vgrupo = "";
    LET vsubgrupo = "";
    LET vresidencia = "";
    LET vfecha_alta = "";
    LET vapell_casada  = "";
    LET vdistrito = "";
    LET vnumcte_ref = "";
    LET vstring1 = "";
    LET vstring2  = "";
    LET vnumeric1  = 0;
    LET vnumeric2  = 0;
    LET vmoney1 = 0;
    LET vdate1  = "";
    LET vpuesto_ppes = "";
    LET vfamiliar_ppes = "";
    LET vactividad_esp = "";
    LET vejecut_autoriza  = "";
    LET vuser_insert = "";
    LET vfecha_insert = "";
    LET vrfc_alterno = "";
	LET vid_pais = '';			--DSB230162JERV1694 se envia valor por que no se encuentra en la tabla si_cliente.
    -- si_ctepf
    LET vpfempresa  = "";
    LET vpfnumcte  = "";
    LET vpffecha_nac  = "";
    LET vpflugar_nac  = "";
    LET vpfnacionalidad  = "";
    LET vpfno_fm3  = "";
    LET vpfestado_civil = "";
    LET vpfregim_matrimonio = "";
    LET vpfprofesion  = "";
    LET vpfsexo = "";
    LET vpfcurp  = "";
    LET vpfcodidentifi = "";
    LET vpfnumidentifi  = "";
    LET vpfno_imss  = "";
    LET vpfdependientes = 0;
    LET vpftutor  = "";
    LET vpfemail  = "";
    LET vpfpfnom_conyuge  = "";
    LET vpfseguro_defunc = "";
    LET vpfescolaridad = "";
    LET vpfhabita_en = "";
    LET vpfanios_habita  = 0;
    LET vpfnombre_prop = "";
    LET vpfimp_hipo_renta  = 0;
    LET vpfactividadogiro = "";
    LET vpfnumeroife = "";
    LET vpfnumerotutor = "";
    LET vpfnumeroconyuge = "";
    LET vpfstring1 = "";
    LET vpfstring2 = "";
    LET vpfnumeric1 = 0;
    LET vpfnumeric2 = 0;
    LET vpfmoney1 = 0;
    LET vpfdate1 = "";
    LET vpfuser_insert = "";
    LET vpffecha_insert = "";
    LET vpid_pais = '';			--DSB230162JERV1694

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
    --- SET DEBUG FILE TO "/respaldosbd/consnumcte_n.out";
    --- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN  vcodret,
                    vempresa, vnumcte, vstatus_cte, vsucursal, vejecutivo, vtpo_persona, vtipo_cliente, vapell_paterno, vapell_materno, vnombre1, vnombre2,
                    vrazon_social, vrfc, vsector, vsegmento, vactividad_princ, vgrupo, vsubgrupo, vresidencia, vfecha_alta, vapell_casada, vdistrito, vnumcte_ref,
                    vstring1, vstring2, vnumeric1, vnumeric2, vmoney1, vdate1, vpuesto_ppes, vfamiliar_ppes, vactividad_esp, vejecut_autoriza, vuser_insert, 
                    vfecha_insert, vrfc_alterno, vid_pais,		--DSB230162JERV1694 vid_pais
                    vpfempresa, vpfnumcte, vpffecha_nac, vpflugar_nac, vpfnacionalidad, vpfno_fm3, vpfestado_civil, vpfregim_matrimonio, vpfprofesion, vpfsexo, 
                    vpfcurp, vpfcodidentifi, vpfnumidentifi, vpfno_imss, vpfdependientes, vpftutor, vpfemail, vpfpfnom_conyuge, vpfseguro_defunc, vpfescolaridad,
                    vpfhabita_en, vpfanios_habita, vpfnombre_prop, vpfimp_hipo_renta, vpfactividadogiro, vpfnumeroife, vpfnumerotutor, vpfnumeroconyuge, 
                    vpfstring1, vpfstring2, vpfnumeric1, vpfnumeric2, vpfmoney1, vpfdate1, vpfuser_insert, vpffecha_insert, vpid_pais;		--DSB230162JERV1694 vpid_pais
        END IF
    END EXCEPTION;


    LET vcodret = "00000";

    SELECT valor 
      INTO vlong_cte 
      FROM bdinteg:"informix".si_param 
     WHERE cod_param = 7 
       AND empresa = pempresa;

    LET vlongitud = length(pnumcte);

    IF vlongitud < vlong_cte THEN
        FOREACH
            EXECUTE PROCEDURE formateo_cte(pnumcte) 
            INTO pnumcte
        END FOREACH;
    END IF

    SELECT c.empresa, c.numcte, c.status_cte, c.sucursal, c.ejecutivo, c.tpo_persona, c.tipo_cliente, c.apell_paterno, c.apell_materno, c.nombre1, c.nombre2,
           c.razon_social, c.rfc, c.sector, c.segmento, c.actividad_princ, c.grupo, c.subgrupo, c.residencia, c.fecha_alta, c.apell_casada, c.distrito, c.numcte_ref, 
           c.string1, c.string2, c.numeric1, c.numeric2, c.money1, NVL(c.date1,CURRENT), c.puesto_ppes, c.familiar_ppes, c.actividad_esp, c.ejecut_autoriza, c.user_insert,
           c.fecha_insert, NVL(c.rfc_alterno," "), -- c.id_pais,		--DSB230162JERV1694 c.id_pais,
           f.empresa, f.numcte, f.fecha_nac, f.lugar_nac, f.nacionalidad, f.no_fm3, f.estado_civil, f.regim_matrimonio, f.profesion, f.sexo, f.curp, f.codidentifi,
           f.numidentifi, f.no_imss, f.dependientes, f.tutor, f.nom_conyuge, f.seguro_defunc, f.escolaridad, f.habita_en, f.anios_habita, f.nombre_prop,
           NVL(f.imp_hipo_renta,0), NVL(f.actividadogiro," "), NVL(f.numeroife," "), NVL( f.numerotutor," "),NVL( f.numeroconyuge," "), NVL(f.string1," "), NVL(f.string2," "), 
           NVL(f.numeric1,0), NVL(f.numeric2,0), NVL(f.money1,0), NVL(f.date1,CURRENT), f.user_insert, f.fecha_insert, f.id_pais		--DSB230162JERV1694 f.id_pais
      INTO vempresa, vnumcte, vstatus_cte, vsucursal, vejecutivo, vtpo_persona, vtipo_cliente, vapell_paterno, vapell_materno, vnombre1, vnombre2, 
           vrazon_social, vrfc, vsector, vsegmento, vactividad_princ, vgrupo, vsubgrupo, vresidencia, vfecha_alta, vapell_casada, vdistrito, vnumcte_ref, 
           vstring1, vstring2, vnumeric1, vnumeric2, vmoney1, vdate1, vpuesto_ppes, vfamiliar_ppes, vactividad_esp, vejecut_autoriza, vuser_insert,
           vfecha_insert, vrfc_alterno, -- vid_pais,		--DSB230162JERV1694 vid_pais,
           vpfempresa, vpfnumcte, vpffecha_nac, vpflugar_nac, vpfnacionalidad, vpfno_fm3, vpfestado_civil, vpfregim_matrimonio, vpfprofesion, vpfsexo, vpfcurp,
           vpfcodidentifi, vpfnumidentifi, vpfno_imss, vpfdependientes, vpftutor, vpfpfnom_conyuge, vpfseguro_defunc, vpfescolaridad, vpfhabita_en,
           vpfanios_habita, vpfnombre_prop, vpfimp_hipo_renta, vpfactividadogiro, vpfnumeroife, vpfnumerotutor, vpfnumeroconyuge, vpfstring1, vpfstring2,
           vpfnumeric1, vpfnumeric2, vpfmoney1, vpfdate1, vpfuser_insert, vpffecha_insert, vpid_pais		--DSB230162JERV1694 vpid_pais
      FROM bdinteg:"informix".si_cliente c, 
     OUTER bdinteg:"informix".si_ctepf f
     WHERE c.numcte = pnumcte 
       AND c.empresa = pempresa 
       AND c.numcte = f.numcte;
       
    SELECT NVL(correo_elec, ' ')
      INTO vpfemail
      FROM "informix".si_correos
     WHERE numcte = pnumcte
       AND status_correo = 'A'
	   AND secuencia = (SELECT MAX(secuencia) FROM "informix".si_correos WHERE numcte = pnumcte AND status_correo = 'A' );

    IF vpfemail IS NULL 
       THEN
           LET vpfemail=" ";
    END IF;

    IF vtpo_persona = " " OR vtpo_persona IS NULL THEN
        LET vcodret = "800";
        RETURN  vcodret,
                vempresa, vnumcte, vstatus_cte, vsucursal, vejecutivo, vtpo_persona, vtipo_cliente, vapell_paterno, vapell_materno, vnombre1, vnombre2,
                vrazon_social, vrfc, vsector, vsegmento, vactividad_princ, vgrupo, vsubgrupo, vresidencia, vfecha_alta, vapell_casada, vdistrito, vnumcte_ref,
                vstring1, vstring2, vnumeric1, vnumeric2, vmoney1, vdate1, vpuesto_ppes, vfamiliar_ppes, vactividad_esp, vejecut_autoriza, vuser_insert, 
                vfecha_insert, vrfc_alterno, vid_pais,		--DSB230162JERV1694 vid_pais,
                vpfempresa, vpfnumcte, vpffecha_nac, vpflugar_nac, vpfnacionalidad, vpfno_fm3, vpfestado_civil, vpfregim_matrimonio, vpfprofesion, vpfsexo, 
                vpfcurp, vpfcodidentifi, vpfnumidentifi, vpfno_imss, vpfdependientes, vpftutor, vpfemail, vpfpfnom_conyuge, vpfseguro_defunc, vpfescolaridad,
                vpfhabita_en, vpfanios_habita, vpfnombre_prop, vpfimp_hipo_renta, vpfactividadogiro, vpfnumeroife, vpfnumerotutor, vpfnumeroconyuge, 
                vpfstring1, vpfstring2, vpfnumeric1, vpfnumeric2, vpfmoney1, vpfdate1, vpfuser_insert, vpffecha_insert, vpid_pais;		--DSB230162JERV1694 vpid_pais;
    ELSE
        SELECT {+INDEX(bdinteg:"informix".si_tipper ix193_1)} es_fisica 
          INTO vesfisica 
          FROM bdinteg:"informix".si_tipper 
         WHERE tpo_persona = vtpo_persona;

        IF vesfisica <> "S" THEN
            LET vapell_paterno = " ";
            LET vapell_materno = " ";
            LET vnombre1 = " ";
            LET vnombre2 = " ";
        ELSE
            LET vrazon_social = " ";
        END IF;

        RETURN  vcodret,
                vempresa, vnumcte, vstatus_cte, vsucursal, vejecutivo, vtpo_persona, vtipo_cliente, vapell_paterno, vapell_materno, vnombre1, vnombre2,
                vrazon_social, vrfc, vsector, vsegmento, vactividad_princ, vgrupo, vsubgrupo, vresidencia, vfecha_alta, vapell_casada, vdistrito, vnumcte_ref,
                vstring1, vstring2, vnumeric1, vnumeric2, vmoney1, vdate1, vpuesto_ppes, vfamiliar_ppes, vactividad_esp, vejecut_autoriza, vuser_insert, 
                vfecha_insert, vrfc_alterno, vid_pais,			--DSB230162JERV1694 vid_pais,
                vpfempresa, vpfnumcte, vpffecha_nac, vpflugar_nac, vpfnacionalidad, vpfno_fm3, vpfestado_civil, vpfregim_matrimonio, vpfprofesion, vpfsexo, 
                vpfcurp, vpfcodidentifi, vpfnumidentifi, vpfno_imss, vpfdependientes, vpftutor, vpfemail, vpfpfnom_conyuge, vpfseguro_defunc, vpfescolaridad,
                vpfhabita_en, vpfanios_habita, vpfnombre_prop, vpfimp_hipo_renta, vpfactividadogiro, vpfnumeroife, vpfnumerotutor, vpfnumeroconyuge, 
                vpfstring1, vpfstring2, vpfnumeric1, vpfnumeric2, vpfmoney1, vpfdate1, vpfuser_insert, vpffecha_insert, vpid_pais;  --DSB230162JERV1694 vpid_pais;
    END IF;

    END
    
END PROCEDURE

DOCUMENT
"Autor : Daniela Viridiana Ramirez Perez",
"FECHA : 14/07/2011",
"BD    : bdinteg",
"-------------------",
"Folio:			1693",
"Proyecto:		MTTO-OFI_PAIS_NACION",
"Asunto:		Requerimiento",
"Autor: 		95579737 - José Ernesto Raygoza Villa",
"Fecha: 		03/Mayo/2016",
"Sustento:		peticiones pendientes de desarrollo bancoppel",
"Solicita:		Gisela Rivera",
"Descripción:	Creación de SP que consulta un registro del catálogo de paises recibiendo como parámetro el id_pais",
"BD: 			bdinteg",
"Etiqueta:		DSB230162JERV1694";

create procedure "informix".consppes(pempresa char(3),
                           pnumcte char(20),
                           pnum_direc smallint)
       returning char(5),char(1),char(2),char(26),
                        char(26),char(26),char(26),decimal(14,2),char(80),char(20),char(40),int ;

define vcodret char(5);
define vciclo smallint;
define vsqlerr integer;


define vtipo_ppes char(1);
define vpuesto_ppes  char(2);
define vapell_paterno  char(26);
define vapell_materno char(26);
define vnombre1  char(26);
define vnombre2  char(26);
define vparticipacion decimal(14,2);
define vdomicilio  char(80);
define vtelefono  char(20);
define vasociacioncivil char(40);
define vnumeroregistro  int ;



let vciclo = 0;
let vcodret = "000";
let  vsqlerr = 0;

let vtipo_ppes = "";
let vpuesto_ppes = "";
let vapell_paterno = "";
let vapell_materno = "";
let vnombre1 = "";
let vnombre2 = "";
let vparticipacion = 0;
let vdomicilio = "";
let vtelefono = "";
let vasociacioncivil = "";
let vnumeroregistro = 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret,vtipo_ppes,vpuesto_ppes,vapell_paterno,vapell_materno,vnombre1,
                      vnombre2,vparticipacion,vdomicilio,vtelefono,vasociacioncivil,vnumeroregistro;

      end if;
   end exception;

   foreach
      SELECT   tipo_ppes,puesto_ppes,apell_paterno,apell_materno,nombre1,
                        nombre2,participacion,domicilio,telefono,asociacion_civil,numeroregistro
         INTO      vtipo_ppes,vpuesto_ppes,vapell_paterno,vapell_materno,vnombre1,
                        vnombre2,vparticipacion,vdomicilio,vtelefono,vasociacioncivil,vnumeroregistro
         FROM si_cteppes
         WHERE numcte = pnumcte
         ORDER BY numeroregistro
      let vciclo = vciclo+1;
      if vciclo <= pnum_direc then
         continue foreach;
      end if
      return    vcodret,vtipo_ppes,vpuesto_ppes,vapell_paterno,vapell_materno,vnombre1,
                      vnombre2,vparticipacion,vdomicilio,vtelefono,vasociacioncivil,vnumeroregistro with resume;
   end foreach;
end
end procedure
DOCUMENT
"Consulta de personas politicas",
"Autor : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Daniel Zambada",
"FECHA : 30/octubre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".consedadcte(p_empresa     char(3),
                             p_numcte      char(20))
   RETURNING CHAR(5), CHAR(104), smallint;

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   DEFINE v_numcte            CHAR(20);
   DEFINE v_nomcte            CHAR(104);

   DEFINE v_ano_cte           SMALLINT;
   DEFINE v_edad	          SMALLINT;
   DEFINE v_fecha_hoy         DATE; 


	ON EXCEPTION SET sql_err, isam_err, error_info
		SET DEBUG FILE TO "VerifCte1.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET cod_ret = sql_err;
		RETURN  cod_ret,v_nomcte, v_edad;
	END EXCEPTION;


	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";


	LET v_numcte = '';
	LET v_nomcte = '';
	LET v_ano_cte =0;
	LET v_edad = 0;
	LEt v_fecha_hoy = date(1);
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	select fecha_hoy
	into v_fecha_hoy
	from bdinteg:si_fechas;

	SELECT NVL(trim(cli.apell_paterno),' ') || ' ' ||
          NVL(trim(cli.apell_materno),' ') || ' ' ||
          NVL(trim(cli.nombre1),' ') || ' ' ||
          NVL(trim(cli.nombre2),' ') nomcte,
		 case when month(fecha_nac) < month(v_fecha_hoy)
				then year(v_fecha_hoy) - year(fecha_nac)
				else case when month(fecha_nac) = month(v_fecha_hoy) and day(fecha_nac) <= day(v_fecha_hoy) 
					then year(v_fecha_hoy) - year(fecha_nac)
					else year(v_fecha_hoy) - year(fecha_nac) - 1 
     			end  
		 end edad
	INTO v_nomcte,v_edad
	FROM si_cliente cli,
          si_ctepf pf
    WHERE cli.empresa = p_empresa and
          pf.numcte = cli.numcte  AND
          cli.numcte =p_numcte;

    if v_nomcte is null then
		let cod_ret = "104";
		RETURN  cod_ret,v_nomcte, v_edad;
    end if

    RETURN  cod_ret,v_nomcte, v_edad;

END PROCEDURE

DOCUMENT
'SPL Extrae la Edad del Cliente',
"MODIFICO : Victor Luna",
"FECHA : 12/Febrero/2007",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : ",
"FECHA : 30/Marzo/2012",
"BD    : bdinteg",
"VER   : 1.2";

CREATE PROCEDURE "informix".consdireccionbenef(pEmpresa CHAR(3), pNumCliente CHAR(13), pNumCliBenef CHAR(13))
--DATOS A REGRESAR--
RETURNING CHAR(5),   -- Codigo de Retorno
          CHAR(104), -- Nombre Completo
          INTEGER,   -- Numero Calle
          CHAR(10),  -- Numero Exterior
          INTEGER,   -- Numero Colonia
          CHAR(3),   -- Numero Ciudad 
          SMALLINT,  -- Numero Ciudad
          CHAR(2),   -- Numero Estado
          CHAR(13),  -- Telefono 1
          CHAR(13);  -- Telefono 2
    
    --DEFINICION DE VARIABLES--
    DEFINE cCodRet		CHAR(5);
    DEFINE cTipCte      CHAR(1);
    DEFINE cDirExi      CHAR(2);
    DEFINE iMaxSec      INTEGER;
    DEFINE iNumCall     INTEGER;
    DEFINE cNumExt      CHAR(10);
    DEFINE iNumCol      INTEGER;
    DEFINE sNumCiu      SMALLINT;
    DEFINE cCiudad      CHAR(3);
    DEFINE iNumEdo      CHAR(2);
    DEFINE cTel1        CHAR(13);
    DEFINE cTel2        CHAR(13);
    DEFINE cNomComp     CHAR(104);
    DEFINE cNombre1     CHAR(26);
    DEFINE cNombre2     CHAR(26);
    DEFINE cApellPt     CHAR(26);
    DEFINE cApellMt     CHAR(26);
    DEFINE iSqlErr		INTEGER;
    
    --INICIALIZACIONES
    LET cCodRet = "000";
    LET cNumExt      = "";
    LET iNumCall      = 0;
    LET cNomComp     = "";
    LET iNumCol      = 0;
    LET sNumCiu      = 0;
    LET cCiudad      = "";
    LET iNumEdo      = "";
    LET cTel1        = "";
    LET cTel2        = "";
    LET cNombre1     = "";
    LET cNombre2     = "";
    LET cApellPt     = "";
    LET cApellMt     = "";
    LET iSqlErr      = 0;
    
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
    --- SET DEBUG FILE TO "/home/sysifx/adrianl/ConsDireccionBenef.out";    
    --- TRACE ON; 
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cNomComp, iNumCall, cNumExt, iNumCol, sNumCiu, cCiudad, iNumEdo, cTel1, cTel2;
        END IF;
    END EXCEPTION;

    SELECT tipo_cliente 
      INTO cTipCte 
      FROM bdinteg:si_cliente 
     WHERE numcte = pNumCliBenef;
     
    SELECT COUNT(*) 
      INTO cDirExi 
      FROM bdinteg:si_direcciones_actual 
     WHERE numcte = pNumCliBenef
     AND tipo_dir = '1'; 
    
    IF (cTipCte = "1") AND (cDirExi <> "0") OR (cTipCte = "2") AND (cDirExi <> "0") THEN
        SELECT {+ INDEX (bdinteg:si_direcciones_actual idx_diract_cte )} 
               cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, dir.numeroextcalle, dir.numerocalle, 
               dir.numerocolonia, dir.numerociudad, TRIM(dir.ciudad), dir.estado, nvl(tel1.telefono,''), nvl(tel2.telefono,'')
          INTO cNombre1, cNombre2, cApellPt, cApellMt, cNumExt, iNumCall, iNumCol, sNumCiu, cCiudad, iNumEdo, cTel1, cTel2
          FROM bdinteg:si_direcciones_actual dir 
         INNER JOIN bdinteg:si_cliente cte ON ( cte.numcte = dir.numcte )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON (tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON (tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
         WHERE dir.numcte = pNumCliBenef 
           and dir.tipo_dir = '1';  
                    
        LET cNomComp = TRIM(cNombre1) || ' ' || TRIM(cNombre2) || ' ' || TRIM(cApellPt) || ' ' || TRIM(cApellMt);

        --- LET cCodRet = "000";
        --- RETURN cCodRet, cNomComp, iNumCall, cNumExt, iNumCol, sNumCiu, cCiudad, iNumEdo, cTel1, cTel2;
    ELSE
        IF cTipCte = 1 OR  cTipCte = 2 THEN
            SELECT nombre1, nombre2, apell_paterno, apell_materno 
              INTO cNombre1, cNombre2, cApellPt, cApellMt
              FROM bdinteg:si_cliente 
             WHERE numcte = pNumCliBenef;

            LET cNomComp = TRIM(cNombre1) || ' ' || TRIM(cNombre2) || ' ' || TRIM(cApellPt) || ' ' || TRIM(cApellMt);

            SELECT {+ INDEX (bdinteg:si_direcciones_actual idx_diract_ctetpo )} 
                   dir.numeroextcalle, dir.numerocalle, dir.numerocolonia, dir.numerociudad, dir.ciudad, dir.estado, nvl(tel1.telefono,''), nvl(tel2.telefono,'')
              INTO cNumExt, iNumCall, iNumCol, sNumCiu, cCiudad, iNumEdo, cTel1, cTel2
              FROM bdinteg:si_direcciones_actual dir
              LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON (tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
              LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON (tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
             WHERE dir.numcte = pNumCliente 
               AND dir.tipo_dir = '1';

            LET cCodRet = "001";
            --- RETURN cCodRet, cNomComp, iNumCall, cNumExt, iNumCol, sNumCiu, cCiudad, iNumEdo, cTel1, cTel2;

        ELSE   
            SELECT nombre1, nombre2, apell_paterno, apell_materno
              INTO cNombre1, cNombre2, cApellPt, cApellMt
              FROM bdinteg:si_cliente 
             WHERE numcte = pNumCliBenef;

            LET cNomComp = TRIM(cNombre1) || ' ' || TRIM(cNombre2) || ' ' || TRIM(cApellPt) || ' ' || TRIM(cApellMt);

            LET iNumCall = 0;
            LET cNumExt = "";
            LET iNumCol = 0;
            LET sNumCiu = 0;
            LET cCiudad = "";
            LET iNumEdo = "";
            LET cTel1 = "";
            LET cTel2 = "";
            LET cCodRet = "002";
            --- RETURN cCodRet, cNomComp, iNumCall, cNumExt, iNumCol, sNumCiu, cCiudad, iNumEdo, cTel1, cTel2;
        END IF
    END IF
    
    RETURN cCodRet, TRIM(cNomComp), iNumCall, cNumExt, iNumCol, cCiudad, sNumCiu, iNumEdo, cTel1, cTel2;
    
    END
    
END PROCEDURE

DOCUMENT
'Modifico: Adrian Lara',
'Proyecto: BeneficiariosCONDUSEF',
'Solicito: Frank Gaxiola',
'Descripcion: Se crea procedimiento que obtiene las direcciones de los clientes tipo 1 y tipo 2,',
'si es tipo 1 y no tiene direccion se trae la del cliente titular',
'Fecha: 19/08/2010',
'Version: 20100827.0853',
'BD: bdinteg',
'MODIFICO: SERGIO FERNANDEZ',
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO QUE EN VEZ DE CONSULTAR DE SI_DIRECCIONES EL DOMICILIO LA CONSULTE DE SI_DIRECCIONES_ACTUAL',
'FECHA: OCTUBRE 2011',
'Fecha: 15/10/2013',
'MODIFICO: Leslie Rendón',
'DESCRIPCION: Se modifica para que obtenga la direccion del cliente titular', 
'en caso de no tener dirección el beneficiario como cliente tipo 2',
'Fecha: 10/06/2015',
'MODIFICO: Aarón Quiñonez',
'DESCRIPCION: Se modifica la consulta para que obtenga la direccion del cliente titular', 
'en caso de no tener dirección el beneficiario como cliente tipo 2';

CREATE PROCEDURE "informix".sp_actvalidacioncofetel ( cEmpresa CHAR(3),cNumCte CHAR(9), cFlagTelefonoCasa CHAR(1), cFlagTelefonoCelular CHAR(1),
                                                     cflagTelefonoOficina CHAR(1), cTipoDireccion CHAR(1))
    RETURNING CHAR(5);

    -- Definicion de Variables
    DEFINE cCodRet CHAR(5);
    DEFINE iSql_err INT;
    DEFINE iMaxSecuencia INT;

    -- Inicializa variables
     LET cCodRet = "00000";
     LET iSql_err = 0;
     LET iMaxSecuencia = 0;

    --SET debug FILE TO "/tmp/sp_actvalidacioncofetel.out";
    --trace ON;
	 
	-----------------------------------------
	--CREACION: Hector Bojorquez
	--FECHA: 2009-02-18
	--FUNCIONALIDAD: Actualiza un registro en la si_direcciones si el telefono 
	--                            proporcionado por el cliente en alta de la dirección fue 
	--                            validado por la COFETEL
	----------------------------------------
	 
    BEGIN
        ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;

        SET ISOLATION COMMITTED READ;

        SELECT max(secuencia) INTO iMaxSecuencia  from si_direcciones  WHERE  numcte = cNumCte and tipo_dir = cTipoDireccion;

        IF cFlagTelefonoCasa = 1 AND cTipoDireccion = "1" THEN
            UPDATE si_direcciones SET ind_COFETELtel1 = "V" WHERE numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
        END IF;
		
		IF cFlagTelefonoCelular = 1 AND cTipoDireccion = "1" THEN
            UPDATE si_direcciones SET ind_COFETELtel2 = "V" WHERE numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
        END IF;

		IF cFlagTelefonoOficina = 1 AND cTipoDireccion = "2" THEN
            UPDATE si_direcciones SET ind_COFETELtel3 = "V" WHERE numcte = cNumCte and tipo_dir = cTipoDireccion and secuencia = iMaxSecuencia;
        END IF;

        RETURN cCodRet;
    END;
END PROCEDURE;