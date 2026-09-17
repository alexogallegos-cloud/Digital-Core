CREATE PROCEDURE "informix".consnumcte_prospectorfc(pempresa char(3), pRfc char(13))
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
          CHAR(254),     -- razon social
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
          DATE;         -- Fecha_insert

    -- DefiniciÃ³n de Variables
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
    DEFINE vrazon_social CHAR(254);
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
    DEFINE vdate1 DATE ;
    DEFINE vpuesto_ppes CHAR(1);
    DEFINE vfamiliar_ppes CHAR(1);
    DEFINE vactividad_esp CHAR(11);
    DEFINE vejecut_autoriza CHAR(8);
    DEFINE vuser_insert CHAR(8);
    DEFINE vfecha_insert DATE;
    DEFINE vrfc_alterno CHAR(13);
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
    DEFINE iregistros INTEGER;

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
    LET iregistros  = 0;
    
    --- SET DEBUG FILE TO "/respaldosbd/consnumcte_prospectorfc.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;

    BEGIN
    
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN  vcodret,
                    vempresa, vnumcte, vstatus_cte, vsucursal, vejecutivo, vtpo_persona, vtipo_cliente, vapell_paterno, vapell_materno, vnombre1, vnombre2,
                    vrazon_social, vrfc, vsector, vsegmento, vactividad_princ, vgrupo, vsubgrupo, vresidencia, vfecha_alta, vapell_casada, vdistrito, vnumcte_ref,
                    vstring1, vstring2, vnumeric1, vnumeric2, vmoney1, vdate1, vpuesto_ppes, vfamiliar_ppes, vactividad_esp, vejecut_autoriza, vuser_insert, 
                    vfecha_insert, vrfc_alterno,
                    vpfempresa, vpfnumcte, vpffecha_nac, vpflugar_nac, vpfnacionalidad, vpfno_fm3, vpfestado_civil, vpfregim_matrimonio, vpfprofesion, vpfsexo, 
                    vpfcurp, vpfcodidentifi, vpfnumidentifi, vpfno_imss, vpfdependientes, vpftutor, vpfemail, vpfpfnom_conyuge, vpfseguro_defunc, vpfescolaridad,
                    vpfhabita_en, vpfanios_habita, vpfnombre_prop, vpfimp_hipo_renta, vpfactividadogiro, vpfnumeroife, vpfnumerotutor, vpfnumeroconyuge, 
                    vpfstring1, vpfstring2, vpfnumeric1, vpfnumeric2, vpfmoney1, vpfdate1, vpfuser_insert, vpffecha_insert;
        END IF
    END EXCEPTION;

    SET LOCK MODE TO WAIT 3;

    LET vcodret = "00000";

    SELECT valor 
    INTO vlong_cte 
    FROM bdinteg:"informix".si_param 
    WHERE cod_param = 7 
    AND empresa = pempresa;

    SELECT COUNT(c.numcte) 
    INTO iregistros
    FROM bdinteg:"informix".si_cliente c,  
    OUTER bdinteg:"informix".si_ctepf f 
    WHERE c.rfc = TRIM(pRfc)  
    AND c.empresa = pempresa  
    AND c.numcte = f.numcte;

    IF iregistros = 0 THEN
         LET vcodret = '00017';
        RETURN  vcodret,
                vempresa, vnumcte, vstatus_cte, vsucursal, vejecutivo, vtpo_persona, vtipo_cliente, vapell_paterno, vapell_materno, vnombre1, vnombre2,
                vrazon_social, vrfc, vsector, vsegmento, vactividad_princ, vgrupo, vsubgrupo, vresidencia, vfecha_alta, vapell_casada, vdistrito, vnumcte_ref,
                vstring1, vstring2, vnumeric1, vnumeric2, vmoney1, vdate1, vpuesto_ppes, vfamiliar_ppes, vactividad_esp, vejecut_autoriza, vuser_insert, 
                vfecha_insert, vrfc_alterno,
                vpfempresa, vpfnumcte, vpffecha_nac, vpflugar_nac, vpfnacionalidad, vpfno_fm3, vpfestado_civil, vpfregim_matrimonio, vpfprofesion, vpfsexo, 
                vpfcurp, vpfcodidentifi, vpfnumidentifi, vpfno_imss, vpfdependientes, vpftutor, vpfemail, vpfpfnom_conyuge, vpfseguro_defunc, vpfescolaridad,
                vpfhabita_en, vpfanios_habita, vpfnombre_prop, vpfimp_hipo_renta, vpfactividadogiro, vpfnumeroife, vpfnumerotutor, vpfnumeroconyuge, 
                vpfstring1, vpfstring2, vpfnumeric1, vpfnumeric2, vpfmoney1, vpfdate1, vpfuser_insert, vpffecha_insert; 
    END IF;

    SELECT c.empresa, c.numcte, c.status_cte, c.sucursal, c.ejecutivo, c.tpo_persona, c.tipo_cliente, c.apell_paterno, c.apell_materno, c.nombre1, c.nombre2,
           c.razon_social, c.rfc, c.sector, c.segmento, c.actividad_princ, c.grupo, c.subgrupo, c.residencia, c.fecha_alta, c.apell_casada, c.distrito, c.numcte_ref, 
           c.string1, c.string2, c.numeric1, c.numeric2, c.money1, NVL(c.date1,CURRENT), c.puesto_ppes, c.familiar_ppes, c.actividad_esp, c.ejecut_autoriza, c.user_insert,
           c.fecha_insert, NVL(c.rfc_alterno," "),
           f.empresa, f.numcte, f.fecha_nac, f.lugar_nac, f.nacionalidad, f.no_fm3, f.estado_civil, f.regim_matrimonio, f.profesion, f.sexo, f.curp, f.codidentifi,
           f.numidentifi, f.no_imss, f.dependientes, f.tutor, f.nom_conyuge, f.seguro_defunc, f.escolaridad, f.habita_en, f.anios_habita, f.nombre_prop,
           NVL(f.imp_hipo_renta,0), NVL(f.actividadogiro," "), NVL(f.numeroife," "), NVL( f.numerotutor," "),NVL( f.numeroconyuge," "), NVL(f.string1," "), NVL(f.string2," "), 
           NVL(f.numeric1,0), NVL(f.numeric2,0), NVL(f.money1,0), NVL(f.date1,CURRENT), f.user_insert, f.fecha_insert
      INTO vempresa, vnumcte, vstatus_cte, vsucursal, vejecutivo, vtpo_persona, vtipo_cliente, vapell_paterno, vapell_materno, vnombre1, vnombre2, 
           vrazon_social, vrfc, vsector, vsegmento, vactividad_princ, vgrupo, vsubgrupo, vresidencia, vfecha_alta, vapell_casada, vdistrito, vnumcte_ref, 
           vstring1, vstring2, vnumeric1, vnumeric2, vmoney1, vdate1, vpuesto_ppes, vfamiliar_ppes, vactividad_esp, vejecut_autoriza, vuser_insert,
           vfecha_insert, vrfc_alterno,
           vpfempresa, vpfnumcte, vpffecha_nac, vpflugar_nac, vpfnacionalidad, vpfno_fm3, vpfestado_civil, vpfregim_matrimonio, vpfprofesion, vpfsexo, vpfcurp,
           vpfcodidentifi, vpfnumidentifi, vpfno_imss, vpfdependientes, vpftutor, vpfpfnom_conyuge, vpfseguro_defunc, vpfescolaridad, vpfhabita_en,
           vpfanios_habita, vpfnombre_prop, vpfimp_hipo_renta, vpfactividadogiro, vpfnumeroife, vpfnumerotutor, vpfnumeroconyuge, vpfstring1, vpfstring2,
           vpfnumeric1, vpfnumeric2, vpfmoney1, vpfdate1, vpfuser_insert, vpffecha_insert
      FROM bdinteg:"informix".si_cliente c, 
     OUTER bdinteg:"informix".si_ctepf f
     WHERE c.rfc = TRIM(pRfc) 
       AND c.empresa = pempresa 
       AND c.numcte = f.numcte;

    --CAMBIO 
	--SE OBTIENEN LAS RAZON SOCIAL DEl CLIENTE MORAL DE LA TABLA si_fiscal
	SELECT LIMIT 1 TRIM(NVL(nom_razon_soc,''))
	INTO vrazon_social
	FROM bdinteg:"informix".si_fiscal
	WHERE empresa = '001' 
	AND rfc = TRIM(pRfc);


    LET vlongitud = length(vnumcte);

    IF vlongitud < vlong_cte THEN
        FOREACH
            EXECUTE PROCEDURE formateo_cte(vnumcte) 
            INTO vnumcte
        END FOREACH;
    END IF
       
    SELECT nvl(correo_elec, ' ')
      INTO vpfemail
      FROM "informix".si_correos
     WHERE numcte = vnumcte
       AND status_correo = 'A'
	   AND secuencia = (select max(secuencia) from "informix".si_correos WHERE numcte = vnumcte AND status_correo = 'A' );

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
                vfecha_insert, vrfc_alterno,
                vpfempresa, vpfnumcte, vpffecha_nac, vpflugar_nac, vpfnacionalidad, vpfno_fm3, vpfestado_civil, vpfregim_matrimonio, vpfprofesion, vpfsexo, 
                vpfcurp, vpfcodidentifi, vpfnumidentifi, vpfno_imss, vpfdependientes, vpftutor, vpfemail, vpfpfnom_conyuge, vpfseguro_defunc, vpfescolaridad,
                vpfhabita_en, vpfanios_habita, vpfnombre_prop, vpfimp_hipo_renta, vpfactividadogiro, vpfnumeroife, vpfnumerotutor, vpfnumeroconyuge, 
                vpfstring1, vpfstring2, vpfnumeric1, vpfnumeric2, vpfmoney1, vpfdate1, vpfuser_insert, vpffecha_insert;
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
                vfecha_insert, vrfc_alterno,
                vpfempresa, vpfnumcte, vpffecha_nac, vpflugar_nac, vpfnacionalidad, vpfno_fm3, vpfestado_civil, vpfregim_matrimonio, vpfprofesion, vpfsexo, 
                vpfcurp, vpfcodidentifi, vpfnumidentifi, vpfno_imss, vpfdependientes, vpftutor, vpfemail, vpfpfnom_conyuge, vpfseguro_defunc, vpfescolaridad,
                vpfhabita_en, vpfanios_habita, vpfnombre_prop, vpfimp_hipo_renta, vpfactividadogiro, vpfnumeroife, vpfnumerotutor, vpfnumeroconyuge, 
                vpfstring1, vpfstring2, vpfnumeric1, vpfnumeric2, vpfmoney1, vpfdate1, vpfuser_insert, vpffecha_insert;
    END IF;

    END
    
END PROCEDURE

DOCUMENT 'AUTOR: Jose Antonio RamÃ­rez Franco',
'DESCRIPCION:SP Encarcago de consultar informaciÃ³n del cliente prospecto por medio de RFC',
'FECHA: 17/10/2023',
"BD    : bdinteg";

CREATE PROCEDURE "informix".ctemoral2(pempresa char(3),
			  pfuncion 			char(1),
			  pnumcte 			char(20),
              pdato 			char(2),
			  psucursal 		char(4),
			  pejecutivo 		char(8),
			  ptp_persona 		char(2),
			  ptp_cliente 		char(1),
			  prazon_social 	char(254),
			  prfc       		char(13),
			  pfechaalta  		date,
			  pnacionalidad   	char(2),
			  pnombrecorto    	char(60),
			  pnombrecontacto 	char(48),
			  ptelefonocontacto char(13),
			  psufijo 			char(2),
			  pgiro 			char(20),
 			  pactividad_princ 	char(3),
              ppaginainternet 	char(30),
			  pejecutivo2 		char(8),
			  pfechaalta2 		date,
			  pCURP             CHAR(20),
			  pRFCAlt           CHAR(13),
			  pRegimen			CHAR(3))
 returning char(5),char(20);

define v_codret char(5);
define v_cliente,vnumcte char(20);
define v_nombre char(40);
define v_fecha date;
define v_signumcte int;
define v_rowid,v_rowid2 integer;
define v_tppersona char(2);
define v_cont1,v_cont2 smallint;
define v_esfisica char(1);
define v_longitud,vlong_cte smallint;
define v_sucursal char(4);
define v_razon_social char(120);
define v_ejecutivo char(8);
define v_tp_cliente char(1);
define v_rfc char (13);
define v_sector char (2);
define v_segmento char (3);
define v_actividad_princ char (3);
define v_grupo char(3);
define v_subgrupo char(3);
define v_nacionalidad char(2);
define v_residencia char(1);
define v_nombre_comercial,v_nombre_titular char(40);
define v_giro char(20);
define v_fecha_inscrip,v_fecha_constit date;
define v_sqlerr,v_isamerr integer;
DEFINE v_apodo CHAR(20);
DEFINE v_distrito CHAR(2);
define vcod_param smallint;
define vdescripcion char(40);
define vdiferencia, i smallint;
DEFINE vRFC CHAR(13);
DEFINE cCodRetAux CHAR(5);
DEFINE vcteApo CHAR(20);
DEFINE v_canal CHAR(2);

define psegmento char(3);
define pgrupo char(3);
define psubgrupo char(3);


--set debug file to "/tmp/mfinis/Antonio/ctemoral.out";
--trace on;


--begin
--on exception set v_sqlerr,v_isamerr
--	if v_sqlerr !=0 then
--		let v_codret=v_sqlerr;
--		return v_codret,vnumcte;
--	end if;
--end exception;

set isolation to dirty read;
SET LOCK MODE TO WAIT 3;

let psegmento = "000";
let pgrupo = "000";
let psubgrupo = "000";


let vnumcte = "000000000";
let v_codret = "000";
LET vRFC = '';
LET cCodRetAux ='';
LET vcteApo ='';
LET v_canal = '0';

--- *************************** Validaciones ******************************
select fecha_hoy into v_fecha from bdinteg:"informix".si_fechas WHERE empresa = pempresa;
if pfuncion="A" then

	--- Verifica recepcion correcta de datos
	if psucursal is null
		or pejecutivo is null
		or ptp_persona is null
		or ptp_cliente is null
		or prfc is null
		or pactividad_princ is null
		or psubgrupo is null
		or pnombrecorto is null
		or pgiro is null then
		let v_codret = "110";
		return v_codret,vnumcte;
	end if;

---*************************** Extraccion de Parametros ***************
	if pnumcte is null or pnumcte = " " then
   	   select valor into vlong_cte
    	      from bdinteg:"informix".si_param
    	      WHERE cod_param = 7 AND empresa = pempresa;
   	   if vlong_cte is null then
	      let v_codret="105";
    	      return v_codret,vnumcte;
       	   end if

           SELECT valor INTO v_signumcte
              FROM bdinteg:"informix".si_param
              WHERE empresa = pempresa and cod_param = 6;
           LET vnumcte = v_signumcte;
           LET v_signumcte = v_signumcte + 1;
           UPDATE bdinteg:"informix".si_param
              SET (valor) = (v_signumcte)
              WHERE empresa = pempresa and cod_param = 6;
           let vdiferencia = vlong_cte - length(vnumcte);
           if vdiferencia > 0 then
              for i = 1 to vdiferencia
                  let vnumcte = "0" || vnumcte;
              end for;
           end if
	else
	   let vnumcte=pnumcte;
	end if;

 	select numcte into v_cliente
                from bdinteg:"informix".si_cliente
                where numcte = vnumcte;
        if v_cliente = vnumcte then
                let v_codret="118";
                return v_codret,vnumcte;
        end if;
        let ptp_persona = ptp_persona;
        let ptp_cliente = ptp_cliente;
	select es_fisica into v_esfisica from bdinteg:"informix".si_tipper
  	   where tpo_persona = ptp_persona;
	if v_esfisica is null or
           (v_esfisica != "N" and v_esfisica != "n") then
           let v_codret = "120";
           return v_codret,vnumcte;
	end if;

 	select nombre into v_nombre
                from bdinteg:"informix".si_sucursales
                where sucursal=psucursal;
        if v_nombre is null then
                let v_codret="111";
                return v_codret,vnumcte;
        end if;

        select nombre into v_nombre
                from bdinteg:"informix".si_ejecut
                where ejecutivo=pejecutivo;
        if v_nombre is null then
                let v_codret="112";
                return v_codret,vnumcte;
        end if;

 	/*select nombre into v_nombre
                from si_actecon
                where actividad=pactividad_princ;
        if v_nombre is null then
                let v_codret="125";
                return v_codret,vnumcte;
        end if;*/
		
		--SELECT numcteapoderado	
	--	INTO vcteApo
	--	FROM "informix".si_apoderado where numcte = TRIM(pnumcte);
		
	--	IF NVL (vcteApo,'') = '' THEN
	--	  let v_codret="00022";
     --           return v_codret,vnumcte;
	--	END IF;
		
        SELECT numcte	
		INTO vcteApo
		FROM "informix".si_ctepf where numcte = TRIM(vnumcte);	 
		
	   IF nvl (psufijo,'') ='' THEN 
		LET psufijo ='99';
	   END IF;

	   	SELECT cve_canal 
		INTO  v_canal
		FROM bdinteg:si_canal
		WHERE nombre_canal = 'SOC';

-- ********************** Actualizacion de Parametros ************************

   begin
	
   	insert into bdinteg:"informix".si_cliente
          (numcte,      empresa,      status_cte,     sucursal,     ejecutivo,
           tpo_persona, tipo_cliente, apell_paterno,  apell_materno,
           nombre1,     nombre2,      razon_social,   rfc,
           sector,      segmento,     actividad_princ,grupo,
           subgrupo,    residencia,   fecha_alta, rfc_alterno)
        values
          (vnumcte,    pempresa,     pdato,            psucursal,    pejecutivo,
           ptp_persona, ptp_cliente,  " ",            " ",
           " ",         " ",          prazon_social,  prfc,
           "31",     psegmento,    pactividad_princ, pgrupo,
           psubgrupo,   "1",        v_fecha, pRFCAlt );

	insert into bdinteg:"informix".si_ctepm
           (empresa,numcte,  giro, nombre_corto, nombre_contacto, telefono_contacto, sufijo,pagina_internet,nacionalidad,
            actividadsocial,operador,sucursal,fecha_alta)
         values
           (pempresa, vnumcte,pgiro,pnombrecorto, pnombrecontacto, ptelefonocontacto, psufijo, ppaginainternet,pnacionalidad,
            pactividad_princ,pejecutivo,psucursal,pfechaalta);
			
			update bdinteg:"informix".si_ctepf set curp =pCURP  where numcte =vcteApo;
			
	insert into bdinteg:"informix".si_fiscal
			(empresa, numcte, sucursal, ejecutivo, nom_razon_soc, cod_postal, rfc, regim_fiscal, fecha_hora, canal)
	values ( pempresa,vnumcte, psucursal, pejecutivo,  prazon_social, '', prfc, pRegimen, 	CURRENT YEAR TO SECOND, 	v_canal);
   end;
   return v_codret,vnumcte;

elif pfuncion = "B" then


	let pnumcte = pnumcte;


	select rowid,tpo_persona into v_rowid,v_tppersona
	  from bdinteg:"informix".si_cliente
      	 where numcte = pnumcte;
      	if v_rowid is null then
       	   let vnumcte=pnumcte;
       	   let v_codret = "104";
       	   return v_codret,pnumcte;
	else
	   select es_fisica into v_esfisica
	     from bdinteg:"informix".si_tipper
	    where tpo_persona=v_tppersona;

        let v_esfisica = v_esfisica;

        if v_esfisica != "N" then
       	     let v_codret = "12a0";
       	     return v_codret,pnumcte;
	   end if;
      	end if

--   	select count(*) into v_cont2 from bdicheq:sc_maechq
--      	 where num_cte = pnumcte;
--      	if v_cont2>0 then
--          let vnumcte = pnumcte;
--       	  let v_codret = "121";
--       	  return v_codret,pnumcte;
--      	end if

--   	select count(*) into v_cont2 from bdisolic:ss_solicitudes
--      	 where num_cte = pnumcte;
--      	if v_cont2>0 then
--          let vnumcte = pnumcte;
--       	  let v_codret = "121";
--       	  return v_codret,pnumcte;
--      	end if

--   	select count(*) into v_cont2 from bdicred:sd_maecred
--      	 where num_cte = pnumcte;
--      	if v_cont2>0 then
---          let vnumcte = pnumcte;
--       	  let v_codret = "121";
--       	  return v_codret,pnumcte;
--      	end if
   	let vnumcte = pnumcte;
	begin
		/*Nueva tabla*/
	  delete from bdinteg:"informix".si_fiscal 
	  		where numcte = pnumcte;

   	  delete from bdinteg:"informix".si_cliente
      	   where rowid=v_rowid;

	  delete from bdinteg:"informix".si_ctepf where numcte = pnumcte;
	end;
else
	select rowid,sucursal,ejecutivo,rfc,
	       actividad_princ
	  into v_rowid,v_sucursal,v_ejecutivo,
	       v_rfc, v_actividad_princ
	  from bdinteg:"informix".si_cliente
	  where numcte = pnumcte;

	if v_rowid is null then
        	let v_codret = "104";
         	return v_codret,pnumcte;
	end if

	if psucursal is null then
		let psucursal=v_sucursal;
	end if;

	if pejecutivo is null then
	  	let pejecutivo=v_ejecutivo;
	end if;

	if ptp_persona is null then
		let ptp_persona=v_tppersona;
	end if;

	if ptp_cliente is null then
		let ptp_cliente = v_tp_cliente;
	end if;

	if prazon_social is null then
		let prazon_social=v_razon_social;
	end if;

	if psufijo is null then
		let prfc=v_rfc;
	end if;
	
	SELECT numcteapoderado	
		INTO vcteApo
		FROM "informix".si_apoderado where numcte = TRIM(pnumcte);
		
		IF NVL (vcteApo,'') = '' THEN
		  let v_codret="00022";
                return v_codret,vnumcte;
		END IF;
			   
	   IF nvl (psufijo,'') ='' THEN 
		LET psufijo ='99';
	   END IF;

	   	SELECT cve_canal 
		INTO  v_canal
		FROM bdinteg:si_canal
		WHERE nombre_canal = 'SOC';

--	select rowid, numcte,nombre_titular,giro,fecha_inscrip,fecha_constit
--	into v_rowid2,vnumcte,	v_nombre_titular,	v_giro,	v_fecha_inscrip,v_fecha_constit
--	from si_ctepm
--	where numcte=pnumcte;
--ACTUALIZACACION 
	/*Nueva tabla*/
	begin
	update bdinteg:"informix".si_fiscal set
		(empresa, sucursal, ejecutivo,  nom_razon_soc, cod_postal, rfc, regim_fiscal, fecha_hora, canal)
		= 
		(pempresa, psucursal, pejecutivo, prazon_social, '', prfc, pRegimen, CURRENT YEAR TO SECOND, v_canal)
	WHERE numcte = pnumcte;

	update bdinteg:"informix".si_cliente set
	     (sucursal,        ejecutivo, tpo_persona,tipo_cliente,
              razon_social,    rfc,  sector,     segmento,
              actividad_princ, grupo,     subgrupo,   residencia,
	      fecha_alta,rfc_alterno)
            =
             (psucursal,       pejecutivo, ptp_persona,ptp_cliente,
              prazon_social,   prfc,       "31",    "000",
              pactividad_princ,pgrupo,     psubgrupo,  "1",
	      v_fecha,pRFCAlt)
        where rowid=v_rowid;

	update bdinteg:"informix".si_ctepm set
             (giro,nombre_corto,nombre_contacto, telefono_contacto, sufijo,pagina_internet,nacionalidad, actividadsocial)
            =
	     (pgiro,pnombrecorto, pnombrecontacto, ptelefonocontacto,psufijo, ppaginainternet,pnacionalidad,pactividad_princ)
	where numcte=pnumcte;
	
	update bdinteg:"informix".si_ctepf set curp =pCURP  where numcte =vcteApo;	
	
	end;
	return v_codret,pnumcte;
end if;
--end;
end procedure
DOCUMENT
"MODIFICO : Manuel Hernandez",
"FECHA : 12/Septiembre/2006",
"MODIFICO : Dulce Ramirez",
"FECHA : 22/Junio/2011",
"DESCRIPCION : Se inhibe select a la tabla si_actecon ya que es la tabla del giro",
" e intentaba buscar la variable que contiene la actividad",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : Daniel Reyes Guillen",
"FECHA : 24/06/2021",
"DESCRIPCION : Se aÃ±ade rfc alterno y curp persona fisica",
"MODIFICO : JosÃ© Antonio RamÃ­rez Franco",
"FECHA : 29/09/2023",
"DESCRIPCION : SP CLON DE ctemoral Se aÃ±ade el regimen fiscal y se cambia la logitud del campo Nombre corto y razÃ³n social";

CREATE PROCEDURE "informix".sp_consultarctemoral_04(pNumcte CHAR(20))

	RETURNING
	CHAR(6) 		AS COD_RET,	
	CHAR(13) 		AS RFC,
	CHAR(26) 		AS APELL_PATER_REP_LEG,
	CHAR(26) 		AS APELL_MATER_REP_LEG,
	CHAR(26) 		AS NOMB1_REP_LEG,
	CHAR(26) 		AS NOMB2_REP_LEG,		
	CHAR(40)   		AS CALLE_FISCAL,
	CHAR(10)   		AS NUM_EXT_CALLE_FISCAL,
	CHAR(60)   		AS COL_FISCAL,
	VARCHAR(60,1)  	AS NOM_CIUD_FISCAL,
	CHAR(3)   		AS COD_MUN_FISCAL,
	CHAR(30)    	AS NOM_ESTADO_FISCAL,
	CHAR(20) 		AS NUM_CTE,
	CHAR(60) 		AS NOM_CORTO,
	CHAR(30) 		AS PAG_INTERNET,
	CHAR(25) 		AS SAT_FEA,
	CHAR(15) 		AS TEL_CONTACTO,
	CHAR(20) 		AS GIRO,
	CHAR(40) 		AS NOM_GIRO,
	CHAR(3)         AS ACTIVIDAD_SOC,
	CHAR(30) 		AS DES_ACT_OBJ,	
	CHAR(2) 		AS RESP_STATUS,								
	CHAR(26) 		AS APELL_PATER_FIRMANTES,					
	CHAR(26) 		AS APELL_MATER_FIRMANTES,
	CHAR(26) 		AS NOMB1_FIRMANTES, 		
	CHAR(26) 		AS NOMB2_FIRMANTES,
	CHAR(20)        AS DES_PODER,
	CHAR(20)        AS DES_ADMIN,
	CHAR(40)        AS DES_ORG,
	DATE            AS FECHA_INS,
	DATE            AS FECHA_CONS,
	CHAR(3)         AS NACIONALIDAD,
	CHAR(15)        AS DESC_NACIONALIDAD,
	CHAR(48)        AS NOMBRE_CONTACTO,
	CHAR(2)         AS SUFIJO,
	CHAR(60)        AS DES_SUFIJO, 
	CHAR(30)        AS ESCRITURA,
	CHAR(30)        AS NOMBRE_NOT,
	CHAR(5)         AS NUM_NOT,
	CHAR(30)        AS CDNOTARIO_OCT,
	CHAR(30)        AS DES_NOTARIOCT,
	CHAR(30)        AS ESCRITURA_POD,
	CHAR(30)        AS NOMNOTARIO_PD,
	CHAR(5)         AS NUMNOTARIO_PD,
	CHAR(30)        AS CDNOTARIO_PD,
	CHAR(30)        AS DESC_CDNOTARIOPD,
	CHAR(50)        AS NOMBRESOC,
	DATE            AS FECHAINS_PD,
	CHAR(60)        AS EMAIL_PM,
	CHAR(30)        AS FOLIO_MERCAN,
	CHAR(30)        AS CD_FOLIOMERCA,
	INTEGER         AS ESTATUS_CTE,  
	CHAR(1)         AS AUXILIAR1, 
	CHAR(1) 		AS AUXILIAR2,
	CHAR(1) 		AS AUXILIAR3,
    CHAR(1)         AS AUXILIAR4,	
	CHAR(1)         AS AUXILIAR5,
    CHAR(1)         AS AUXILIAR6,
    CHAR(1)         AS AUXILIAR7,
	CHAR(1)         AS AUXILIAR8,
	CHAR(1)         AS AUXILIAR9,
	CHAR(1)         AS AUXILIAR10,
	CHAR(02)        AS TIPO_PERSONA,
	CHAR(20)        AS NUMCTE_APODERADO,
	CHAR(60)        AS NOMCTE_APODERADO,
	CHAR(100)       AS DESC_DOCONSTITUCION,
	CHAR(4)         AS SUCURSAL,
	DATE            AS FECHA_ALTA,
	CHAR(1)         AS AUXILIAR11,
	CHAR(3)         AS TIPO_PODER,
	CHAR(3)         AS TIPO_ADMON,
	CHAR(3)         AS TIPO_ORGANIZACION,
	CHAR(40)        AS NOMBRE_SUCURSAL,
	CHAR(1)         AS VALORPARAM_MORALGOB,
	CHAR(254)        AS RAZON_SOCIAL,
    CHAR(20)        AS CURP,
	CHAR(13)		AS RFC_ALT,
	CHAR(3)			AS REG_FISCAL;
	
	
	---DECLARACIONES
	DEFINE iSqlErr						INTEGER;    		
	DEFINE cCodRet         				CHAR(6);				
	DEFINE cRFC         				CHAR(13);	
    DEFINE cSucursal                    CHAR(4);	
	DEFINE cApellPaterContactoRepLeg 	CHAR(26);				
	DEFINE cApellMaterContactoRepLeg	CHAR(26);				
	DEFINE cNomb1ContactoRepLeg         CHAR(26);				
	DEFINE cNomb2ContactoRepLeg     	CHAR(26);				
	DEFINE cCalleFiscal					CHAR(40);				
	DEFINE cNumExtCalleFiscal       	CHAR(10);				
	DEFINE cColFiscal         			CHAR(60);				
	DEFINE vNomCiudFiscal         		VARCHAR(60,1);			
	DEFINE cCodMunFiscal        		CHAR(3);				
	DEFINE cNomEstadoFiscal        		CHAR(30);				
	DEFINE cNumcte         				CHAR(20);				
	DEFINE cNomCorto        			CHAR(60);				
	DEFINE cPagInternet        			CHAR(30);				
	DEFINE cSatFea        				CHAR(25);				
	DEFINE cTelContacto    				CHAR(15);				
	DEFINE cGiro      					CHAR(20);				
	DEFINE cNomGiro    					CHAR(40);	
	DEFINE cActividadSoc                CHAR(3);
	DEFINE cDesActObj  					CHAR(30);				
	DEFINE cUsuarioAut    				CHAR(200);	
	DEFINE cStatusAlta 					CHAR(1);				
	DEFINE cRespStatus 					CHAR(2);				
	DEFINE cApellPaterFirmantes 		CHAR(26);				
	DEFINE cApellMaterFirmantes 		CHAR(26);				
	DEFINE cNomb1Firmantes 				CHAR(26);				
	DEFINE cNomb2Firmantes 				CHAR(26);				
	DEFINE cCuentaNomina 				CHAR(20);
	DEFINE cPoder                       CHAR(3);
	DEFINE cAdmin                       CHAR(3);
	DEFINE cOrg                         CHAR(3);
	DEFINE cDesPoder                    CHAR(20);
	DEFINE cDesAdmin                    CHAR(20);
	DEFINE cDesOrg                      CHAR(40);
	DEFINE cTpoPersona                  CHAR(2);
	DEFINE dFechaIns                    DATE;
	DEFINE dFechaCons                   DATE;
	DEFINE iNac                         INTEGER;
	DEFINE cNomContacto                 CHAR(48);
	DEFINE cSufijo                      CHAR(2);
	DEFINE cDescSufi                    CHAR(60);
	DEFINE cEscritura                   CHAR(30);
	DEFINE cNombreNot                   CHAR(30);
	DEFINE cNumNot                      CHAR(5);
	DEFINE cCdNotarioct                 CHAR(60);
	DEFINE cDesCdNot                    CHAR(30);
	DEFINE cEscrituraPod                CHAR(30);
	DEFINE cNomNotariopd                CHAR (30);
	DEFINE cNumNotariopd                CHAR(5);
	DEFINE cCdNotariopd                 CHAR(30);
	DEFINE cDesCdNotpd                  CHAR(30);
	DEFINE cNombreSoc                   CHAR(50);
	DEFINE dFechaInspd                  DATE;
	DEFINE cEmailpm                     CHAR(60);
	DEFINE cEsFisica                    CHAR(1);
	DEFINE cNumfoliomerct               CHAR(30);
	DEFINE cCdfoliomerct                CHAR(30);
	DEFINE cAuxiliar1                   CHAR(1);
	DEFINE cAuxiliar2                   CHAR(1);
	DEFINE cAuxiliar3                   CHAR(1);
	DEFINE cAuxiliar4   				CHAR(1);
	DEFINE cAuxiliar5   				CHAR(1);
	DEFINE cAuxiliar6                   CHAR(1);
	DEFINE cAuxiliar7                   CHAR(1);
	DEFINE cAuxiliar8                   CHAR(1);
	DEFINE cAuxiliar9                   CHAR(1);
	DEFINE cAuxiliar10                  CHAR(1);
	DEFINE cAuxiliar11                  CHAR(1);
	DEFINE cNumcteapoder                CHAR(20);
	DEFINE cNomapoder                   CHAR(60);
	DEFINE cDocConst                    CHAR(100);
	DEFINE cDesNacion                   CHAR(15);
	DEFINE cNac                         CHAR(3);
	DEFINE dFechaAlta                   DATE;
	DEFINE cNombreSucursal              CHAR(40);
	DEFINE cPrmTpopersonaGob            CHAR(5);
	DEFINE cValorTpopersonaGop          CHAR(1);
	DEFINE iEstatusCteEmpNet            INTEGER;
	DEFINE cRazonSocial					CHAR(254);
    DEFINE cCURP                        CHAR(20);
	DEFINE cRFCAlt						CHAR(13);
	DEFINE cCodRegFiscal				CHAR(3);
	DEFINE cRegimenFiscal				CHAR(3);
	
	
	---INICIALIZACIONES
	LET iSqlErr						= 0;    		
	LET cCodRet         			= '000000';				
	LET cRFC         				= '';
	LET cApellPaterContactoRepLeg   = '';
	LET cApellMaterContactoRepLeg 	= '';
	LET cNomb1ContactoRepLeg        = '';
	LET cNomb2ContactoRepLeg     	= '';
	LET cCalleFiscal				= '';
	LET cNumExtCalleFiscal       	= '';
	LET cColFiscal         			= '';
	LET vNomCiudFiscal         		= '';
	LET cCodMunFiscal        		= '';
	LET cNomEstadoFiscal        	= '';
	LET cNumcte         			= '';
	LET cNomCorto        			= '';
	LET cPagInternet        		= '';
	LET cSatFea        				= '';
	LET cTelContacto    			= '';
	LET cGiro      					= '';
	LET cNomGiro    				= '';
	LET cDesActObj  				= '';
	LET cUsuarioAut    				= '';	
	LET cStatusAlta 				= '';
	LET cRespStatus 				= '';
	LET cApellPaterFirmantes 		= '';
	LET cApellMaterFirmantes 		= '';
	LET cNomb1Firmantes 			= '';
	LET cNomb2Firmantes 			= '';			
	LET cCuentaNomina	 			= '';
	LET cPoder                      = '';
	LET cAdmin                      = '';
	LET cOrg                        = '';  	
	LET cDesPoder                   = '';
	LET cDesAdmin                   = '';
	LET cDesOrg                     = '';  
	LET cTpoPersona                 = '';		
	LET dFechaIns                   = DATE(1);
	LET dFechaCons                  = DATE(1);
	LET iNac                        = 0;
	LET cNomContacto                = '';
	LET cSufijo                     = '';
	LET cDescSufi                   = '';
	LET cActividadSoc               = '';
	LET cEscritura                  = '';
	LET cNombreNot                  = '';
	LET cNumNot                     = '';
	LET cCdNotarioct                = '';
	LET cDesCdNot                   = '';
	LET cEscrituraPod               = '';
	LET cNomNotariopd               = '';
	LET cNumNotariopd               = '';
	LET cCdNotariopd                = '';
	LET cDesCdNotpd                 = '';
	LET cNombreSoc                  = '';
	LET dFechaInspd                 = DATE(1);
	LET cEmailpm                    = '';
	LET cEsFisica                   = '';
	LET cCdfoliomerct               = '';
	LET cNumfoliomerct              = '';
	LET cAuxiliar1                  = '';
	LET cAuxiliar2                  = '';
	LET cAuxiliar3                  = '';
	LET cAuxiliar4                  = '';
	LET cAuxiliar5                  = '';
	LET cAuxiliar6                  = '';
	LET cAuxiliar7                  = '';
	LET cAuxiliar8                  = '';
	LET cAuxiliar9                  = '';
	LET cAuxiliar10                 = '';
	LET cAuxiliar11                 = '';
	LET cNumcteapoder               = '';
	LET cNomapoder                  = '';
	LET cDocConst                   = '';
	LET cDesNacion                  = '';
	LET cNac                        = '';
	LET cSucursal                   = '';
	LET dFechaAlta                  = DATE(1);
	LET cNombreSucursal             = '';
	LET cPrmTpopersonaGob              = '';
	LET cValorTpopersonaGop            = '';
	LET iEstatusCteEmpNet           = 0;
	LET cRazonSocial				= '';
    LET cCURP                       = '';
	LET cRFCAlt						= '';
	LET cRegimenFiscal				= '';
	LET cCodRegFiscal				= '';
	
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
		   IF iSqlErr != 0 THEN
			  LET cCodRet = iSqlErr;
			  RETURN 	cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,'')),TRIM(NVL(cRazonSocial,'')),cCURP,cRFCAlt, cRegimenFiscal;
					
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultarctemoral02.out';
		--TRACE ON;
		
		IF TRIM(NVL(pNumcte,'')) = '' THEN
			LET cCodRet = '000001'; --PARÃÂMETRO VACIO
			
		 	RETURN cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,'')),TRIM(NVL(cRazonSocial,'')),cCURP,cRFCAlt, cRegimenFiscal;
		END IF;
		

		
		--SE CONSULTA EL TIPO PERSONA, RFC Y SUCURSAL REFERENTE AL CLIENTE
		SELECT LIMIT 1  numcte, sucursal, rfc, regim_fiscal
		INTO  cNumcte, cSucursal, cRFC, cCodRegFiscal
		FROM "informix".si_fiscal
		WHERE numcte = TRIM(pNumcte)
		AND empresa = '001';

		LET cRegimenFiscal = cCodRegFiscal;

		--SE CONSULTA EL TIPO PERSONA, RFC Y SUCURSAL REFERENTE AL CLIENTE
		SELECT tpo_persona, rfc, sucursal,rfc_alterno
		INTO cTpoPersona, cRFC, cSucursal, cRFCAlt
		FROM "informix".si_cliente
		WHERE numcte = TRIM(pNumcte)
		AND empresa = '001';

		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
		   LET cCodRet = '000002'; --CONSULTA SIN RESULTADOS, AL CONSULTAR PARAMETRO INVÃÂLIDO
		   
		   RETURN 	cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,'')),TRIM(NVL(cRazonSocial,'')),cCURP,cRFCAlt, cRegimenFiscal;
		END IF;
		
		--CONSULTA es_fisica OBTENIENDO 'S'= PERSONA FÃÂSICA, 'N'=PERSONA MORAL
		SELECT es_fisica
		INTO cEsFisica
        FROM "informix".si_tipper
		WHERE tpo_persona = TRIM(cTpoPersona);
		
		IF cEsFisica = 'S' THEN
		   LET cCodRet = '000003'; --PERSONA FÃÂSICA
		   LET cRFC = '';
		   
		   RETURN 	cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,'')),TRIM(NVL(cRazonSocial,'')),cCURP,cRFCAlt, cRegimenFiscal;
		   
		END IF;
		--CAMBIO
		--SE OBTIENEN LOS DATOS DE CLIENTE MORAL DE LA TABLA si_ctepm
		SELECT TRIM(NVL(numcte,'')),NVL(nombre_corto,''),NVL(pagina_internet,''),TRIM(NVL(sat_fea,'')),
			   TRIM(NVL(telefono_contacto,'')), TRIM(NVL(giro, '')),TRIM(NVL(tipo_poder,'')),TRIM(NVL(tipo_admon,'')), 
			   TRIM(NVL(tipo_org,'')),fecha_inscrip,fecha_constitct,fecha_alta,nacionalidad,TRIM(NVL(nombre_contacto,'')),
			   TRIM(NVL(sufijo,'')),TRIM(NVL(actividadsocial,'')),NVL(escritura_constitutiva,''),
			   TRIM(NVL(nombre_notarioct,'')),TRIM(NVL(numero_notarioct,'')),TRIM(NVL(ciudad_notarioct,'')),
			   TRIM(NVL(numero_foliomercantilct,'')),TRIM(NVL(ciudad_foliomercantilct,'')),TRIM(NVL(escritura_poderes,'')),
			   TRIM(NVL(nombre_notariopd,'')),TRIM(NVL(numero_notariopd,'')), TRIM(NVL(ciudad_notariopd,'')),
			   TRIM(NVL(nombre_sociedad,'')),fecha_inscrippd, TRIM(NVL(emailpm,'')), TRIM(NVL(doc_constitucion,''))
		INTO cNumcte, cNomCorto, cPagInternet, cSatFea,
		     cTelContacto, cGiro, cPoder, cAdmin,
			 cOrg, dFechaIns, dFechaCons,dFechaAlta,iNac, cNomContacto,
			 cSufijo, cActividadSoc, cEscritura,
			 cNombreNot, cNumNot, cCdNotarioct,
			 cNumfoliomerct, cCdfoliomerct, cEscrituraPod,
			 cNomNotariopd, cNumNotariopd, cCdNotariopd,
			 cNombreSoc, dFechaInspd, cEmailpm,cDocConst
		FROM "informix".si_ctepm 
		WHERE numcte = TRIM(pNumcte)
		AND empresa = '001';
		
	    LET cNac = LPAD(iNac, 3,'0');
		
		--SE OBTIENE LA DESCRIPCION DE LA NACIONALIDAD
	    SELECT descripcion
		INTO cDesNacion
		FROM "informix".si_nacion
		WHERE nacion = cNac;
		
		--SE OBTIENE LA DESCRIPCION DEL SUFIJO 
		SELECT descripcion 
		INTO cDescSufi 
		FROM "informix".si_sufijos 
		WHERE empresa = '001'
		AND codigo = TRIM(cSufijo);
		
		--SE OBTIENE LA DESCRIPCION DEL ESTADO DE cCdNotarioct
		
		SELECT nombre 
		INTO cDesCdNot 
		FROM "informix".si_estados 
		WHERE estado = TRIM(cCdNotarioct);
		
		-- SE OBTIENE LA DESCRIPCION DEL ESTADO DE cCdNotariopd
		
		SELECT nombre 
		INTO cDesCdNotpd 
		FROM "informix".si_estados 
		WHERE estado = TRIM(cCdNotariopd);
		
		LET cPrmTpopersonaGob = 'tpo'||TRIM(cTpoPersona);		                                              --el parÃÂ¡metro en la tabla sc_param.		
		
		SELECT TRIM(valor)
		INTO cValorTpopersonaGop
		FROM bdicheq:"informix".sc_param
		WHERE empresa = '001'
		AND codparam = TRIM(cPrmTpopersonaGob);
		
		--SE OBTIENE LA DESCRIPCION DE DATOS DE PERSONAS DE GOBIERNO tpo_persona = '05'*
		IF cValorTpopersonaGop = 'S' THEN
			
			SELECT descripcion
			INTO cDesPoder
			FROM "informix".si_tipo_poder_pm 
			WHERE empresa = '001'
			AND codigo = TRIM(cPoder);
			
			SELECT descripcion
			INTO cDesAdmin
			FROM "informix".si_tipo_admin_pm 
			WHERE empresa = '001'
			AND codigo = TRIM(cAdmin);
			
			SELECT descripcion
			INTO cDesOrg
			FROM "informix".si_tipo_org_pm 
			WHERE empresa = '001'
			AND codigo = TRIM(cOrg);
			
		ELSE 
		   
		   LET cDesPoder = "";
		   LET cDesAdmin = "";
		   LET cDesOrg = "";
		 
		END IF;
		
		
		--SE OBTIENE LA CUENTA Y EL ESTATUS DE LA EMPRESA CON EL SERVICIO DE NOMINA
		SELECT TRIM(NVL(cuenta,'')), TRIM(NVL(status_alta,''))
		INTO cCuentaNomina, cStatusAlta
		FROM bdicheq:"informix".sc_nominaempresas
		WHERE numcte = TRIM(pNumcte);
		
		IF TRIM(NVL(cStatusAlta,'')) = '3' THEN
		   LET cRespStatus = 'Si';
		ELSE
		   LET cRespStatus = 'No';
		END IF;		
						
		--SE OBTIENE NOMBRE DEL REPRESENTANTE LEGAL Y RFC.
		SELECT TRIM(NVL(apell_paterno,'')),TRIM(NVL(apell_materno,'')),
	    TRIM(NVL(nombre1,'')),TRIM(NVL(nombre2,'')) 
		INTO cApellPaterContactoRepLeg,cApellMaterContactoRepLeg,cNomb1ContactoRepLeg,cNomb2ContactoRepLeg
		FROM "informix".si_cliente 
		WHERE numcte = TRIM(cNomContacto)
		AND empresa = '001';
		
							
		--SE OBTIENE DOMICILIO FISCAL.			
		SELECT 	TRIM(NVL(e.nombrecalle,'')),TRIM(NVL(a.numeroextcalle,'')),TRIM(NVL(f.nombrezona,'')),
				TRIM(NVL(g.nombre,'')),TRIM(NVL(c.municipio,'')),TRIM(NVL(b.nombre,''))			
		INTO cCalleFiscal,cNumExtCalleFiscal,cColFiscal,vNomCiudFiscal,cCodMunFiscal,cNomEstadoFiscal
		FROM "informix".si_direcciones_actual a 
			 LEFT OUTER JOIN "informix".si_estados 	   b ON (a.estado = b.estado)
			 LEFT OUTER JOIN "informix".si_municipios  c ON (a.municipio = c.municipio AND a.estado = c.estado AND a.ciudad = c.ciudad AND a.pais = c.pais)
			 LEFT OUTER JOIN "informix".si_catcalles   e ON (a.numerocalle = e.numerocalle)
			 LEFT OUTER JOIN "informix".si_catzonas    f ON (a.numerociudad = f.numerociudad AND a.numerocolonia = f.numerocolonia)
			 LEFT OUTER JOIN "informix".si_ciudades    g ON (a.estado = g.estado AND a.ciudad = g.ciudad)		 
		WHERE a.numcte = TRIM(pNumcte)
		AND a.tipo_dir = 1;
		
		--SE OBTIENE GIRO MERCANTIL.
		SELECT TRIM(NVL(nombre,'')) 
		INTO cNomGiro
		FROM "informix".si_actecon
		WHERE actividad = TRIM(cGiro);
										
		--SE OBTIENE ACTIVIDAD U OBJETO SOCIAL.
		SELECT TRIM(NVL(descripcion,'')) 
		INTO cDesActObj
		FROM "informix".si_actividadsocial 
		WHERE codigo = TRIM(cActividadSoc);		
	
	    --SE OBTIENE EL ESTATUS DEL SERVICIO DE EMPRESANET DEL CLIENTE
	    SELECT MAX (NVL(status_contrato, 0))
		INTO iEstatusCteEmpNet
		FROM bdibei:"informix".bei_contratacion
		WHERE empresa = '001'
		AND num_cliente = pNumcte;
		
		--OBTIENE EL NUMERO DE CTE APODERADO ASI COMO SU NOMBRE
		SELECT numcteapoderado,nombreapoderado 
		INTO cNumcteapoder, cNomapoder
		FROM "informix".si_apoderado
		WHERE empresa = '001'
		AND numcte = TRIM(cNumcte)
		AND secuencia = (SELECT MAX(secuencia) FROM "informix".si_apoderado WHERE empresa = '001');

        --OBTIENE LA CLAVE CURP DE CTE APODERADO
		SELECT TRIM(curp)
		INTO cCURP
		FROM "informix".si_ctepf
		WHERE empresa = '001'
		AND numcte = TRIM(cNumcteapoder);
        
	
		--SE OBTIENE EL AUTORIZADO PARA MANEJAR LAS CUENTAS DE REGISTRO FIRMAS:
		SELECT TRIM(NVL(b.apell_paterno,'')),TRIM(NVL(b.apell_materno,'')),TRIM(NVL(b.nombre1,'')),TRIM(NVL(b.nombre2,''))
		INTO cApellPaterFirmantes,cApellMaterFirmantes,cNomb1Firmantes,cNomb2Firmantes
		FROM bdicheq:"informix".sc_firmantes a INNER JOIN "informix".si_cliente b ON(a.numcte = b.numcte)
		WHERE a.empresa = '001'
		AND a.cuenta = TRIM(cCuentaNomina)
		AND a.secuencia = 1;
		
		--SE OBTIENE EL NOMBRE DE LA SUCURSAL
		SELECT nombre 
		INTO cNombreSucursal
        FROM "informix".si_sucursales
        WHERE sucursal = TRIM(cSucursal);
		
		--CAMBIO 
		--SE OBTIENEN LAS RAZON SOCIAL DEl CLIENTE MORAL DE LA TABLA si_fiscal
		SELECT LIMIT 1 TRIM(NVL(nom_razon_soc,''))
		INTO cRazonSocial 
		FROM bdinteg:"informix".si_fiscal
		WHERE empresa = '001' 
		AND numcte = TRIM(pNumcte);
		
		--SE RETORNA INFORMACION.
	   RETURN 	cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,'')),TRIM(NVL(cRazonSocial,'')),cCURP,cRFCAlt, cRegimenFiscal;
                    	
	END;
END PROCEDURE
DOCUMENT
'AUTOR:  Jose Antonio Ramirez Franco',   
'FECHA: 29/09/2023',
'DESCRIPCION: SP Clon de sp_consultarctemoral_03 en donde se aÃ±ada el regimen fiscal',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_consultarctemoral_rfc(pRfc CHAR(13))

	RETURNING
	CHAR(6) 		AS COD_RET,	
	CHAR(13) 		AS RFC,
	CHAR(26) 		AS APELL_PATER_REP_LEG,
	CHAR(26) 		AS APELL_MATER_REP_LEG,
	CHAR(26) 		AS NOMB1_REP_LEG,
	CHAR(26) 		AS NOMB2_REP_LEG,		
	CHAR(40)   		AS CALLE_FISCAL,
	CHAR(10)   		AS NUM_EXT_CALLE_FISCAL,
	CHAR(60)   		AS COL_FISCAL,
	VARCHAR(60,1)  	AS NOM_CIUD_FISCAL,
	CHAR(3)   		AS COD_MUN_FISCAL,
	CHAR(30)    	AS NOM_ESTADO_FISCAL,
	CHAR(20) 		AS NUM_CTE,
	CHAR(60) 		AS NOM_CORTO,
	CHAR(30) 		AS PAG_INTERNET,
	CHAR(25) 		AS SAT_FEA,
	CHAR(15) 		AS TEL_CONTACTO,
	CHAR(20) 		AS GIRO,
	CHAR(40) 		AS NOM_GIRO,
	CHAR(3)         AS ACTIVIDAD_SOC,
	CHAR(30) 		AS DES_ACT_OBJ,	
	CHAR(2) 		AS RESP_STATUS,								
	CHAR(26) 		AS APELL_PATER_FIRMANTES,					
	CHAR(26) 		AS APELL_MATER_FIRMANTES,
	CHAR(26) 		AS NOMB1_FIRMANTES, 		
	CHAR(26) 		AS NOMB2_FIRMANTES,
	CHAR(20)        AS DES_PODER,
	CHAR(20)        AS DES_ADMIN,
	CHAR(40)        AS DES_ORG,
	DATE            AS FECHA_INS,
	DATE            AS FECHA_CONS,
	CHAR(3)         AS NACIONALIDAD,
	CHAR(15)        AS DESC_NACIONALIDAD,
	CHAR(48)        AS NOMBRE_CONTACTO,
	CHAR(2)         AS SUFIJO,
	CHAR(60)        AS DES_SUFIJO, 
	CHAR(30)        AS ESCRITURA,
	CHAR(30)        AS NOMBRE_NOT,
	CHAR(5)         AS NUM_NOT,
	CHAR(30)        AS CDNOTARIO_OCT,
	CHAR(30)        AS DES_NOTARIOCT,
	CHAR(30)        AS ESCRITURA_POD,
	CHAR(30)        AS NOMNOTARIO_PD,
	CHAR(5)         AS NUMNOTARIO_PD,
	CHAR(30)        AS CDNOTARIO_PD,
	CHAR(30)        AS DESC_CDNOTARIOPD,
	CHAR(50)        AS NOMBRESOC,
	DATE            AS FECHAINS_PD,
	CHAR(60)        AS EMAIL_PM,
	CHAR(30)        AS FOLIO_MERCAN,
	CHAR(30)        AS CD_FOLIOMERCA,
	INTEGER         AS ESTATUS_CTE,  
	CHAR(1)         AS AUXILIAR1, 
	CHAR(1) 		AS AUXILIAR2,
	CHAR(1) 		AS AUXILIAR3,
    CHAR(1)         AS AUXILIAR4,	
	CHAR(1)         AS AUXILIAR5,
    CHAR(1)         AS AUXILIAR6,
    CHAR(1)         AS AUXILIAR7,
	CHAR(1)         AS AUXILIAR8,
	CHAR(1)         AS AUXILIAR9,
	CHAR(1)         AS AUXILIAR10,
	CHAR(02)        AS TIPO_PERSONA,
	CHAR(20)        AS NUMCTE_APODERADO,
	CHAR(60)        AS NOMCTE_APODERADO,
	CHAR(100)       AS DESC_DOCONSTITUCION,
	CHAR(4)         AS SUCURSAL,
	DATE            AS FECHA_ALTA,
	CHAR(1)         AS AUXILIAR11,
	CHAR(3)         AS TIPO_PODER,
	CHAR(3)         AS TIPO_ADMON,
	CHAR(3)         AS TIPO_ORGANIZACION,
	CHAR(40)        AS NOMBRE_SUCURSAL,
	CHAR(1)         AS VALORPARAM_MORALGOB,
	CHAR(254)        AS RAZON_SOCIAL,
    CHAR(20)        AS CURP,
	CHAR(13)		AS RFC_ALT,
	CHAR(3)			AS REG_FISCAL;
	
	
	---DECLARACIONES
	DEFINE iSqlErr						INTEGER;    		
	DEFINE cCodRet         				CHAR(6);				
	DEFINE cRFC         				CHAR(13);	
    DEFINE cSucursal                    CHAR(4);	
	DEFINE cApellPaterContactoRepLeg 	CHAR(26);				
	DEFINE cApellMaterContactoRepLeg	CHAR(26);				
	DEFINE cNomb1ContactoRepLeg         CHAR(26);				
	DEFINE cNomb2ContactoRepLeg     	CHAR(26);				
	DEFINE cCalleFiscal					CHAR(40);				
	DEFINE cNumExtCalleFiscal       	CHAR(10);				
	DEFINE cColFiscal         			CHAR(60);				
	DEFINE vNomCiudFiscal         		VARCHAR(60,1);			
	DEFINE cCodMunFiscal        		CHAR(3);				
	DEFINE cNomEstadoFiscal        		CHAR(30);				
	DEFINE cNumcte         				CHAR(20);				
	DEFINE cNomCorto        			CHAR(60);				
	DEFINE cPagInternet        			CHAR(30);				
	DEFINE cSatFea        				CHAR(25);				
	DEFINE cTelContacto    				CHAR(15);				
	DEFINE cGiro      					CHAR(20);				
	DEFINE cNomGiro    					CHAR(40);	
	DEFINE cActividadSoc                CHAR(3);
	DEFINE cDesActObj  					CHAR(30);				
	DEFINE cUsuarioAut    				CHAR(200);	
	DEFINE cStatusAlta 					CHAR(1);				
	DEFINE cRespStatus 					CHAR(2);				
	DEFINE cApellPaterFirmantes 		CHAR(26);				
	DEFINE cApellMaterFirmantes 		CHAR(26);				
	DEFINE cNomb1Firmantes 				CHAR(26);				
	DEFINE cNomb2Firmantes 				CHAR(26);				
	DEFINE cCuentaNomina 				CHAR(20);
	DEFINE cPoder                       CHAR(3);
	DEFINE cAdmin                       CHAR(3);
	DEFINE cOrg                         CHAR(3);
	DEFINE cDesPoder                    CHAR(20);
	DEFINE cDesAdmin                    CHAR(20);
	DEFINE cDesOrg                      CHAR(40);
	DEFINE cTpoPersona                  CHAR(2);
	DEFINE dFechaIns                    DATE;
	DEFINE dFechaCons                   DATE;
	DEFINE iNac                         INTEGER;
	DEFINE cNomContacto                 CHAR(48);
	DEFINE cSufijo                      CHAR(2);
	DEFINE cDescSufi                    CHAR(60);
	DEFINE cEscritura                   CHAR(30);
	DEFINE cNombreNot                   CHAR(30);
	DEFINE cNumNot                      CHAR(5);
	DEFINE cCdNotarioct                 CHAR(60);
	DEFINE cDesCdNot                    CHAR(30);
	DEFINE cEscrituraPod                CHAR(30);
	DEFINE cNomNotariopd                CHAR (30);
	DEFINE cNumNotariopd                CHAR(5);
	DEFINE cCdNotariopd                 CHAR(30);
	DEFINE cDesCdNotpd                  CHAR(30);
	DEFINE cNombreSoc                   CHAR(50);
	DEFINE dFechaInspd                  DATE;
	DEFINE cEmailpm                     CHAR(60);
	DEFINE cEsFisica                    CHAR(1);
	DEFINE cNumfoliomerct               CHAR(30);
	DEFINE cCdfoliomerct                CHAR(30);
	DEFINE cAuxiliar1                   CHAR(1);
	DEFINE cAuxiliar2                   CHAR(1);
	DEFINE cAuxiliar3                   CHAR(1);
	DEFINE cAuxiliar4   				CHAR(1);
	DEFINE cAuxiliar5   				CHAR(1);
	DEFINE cAuxiliar6                   CHAR(1);
	DEFINE cAuxiliar7                   CHAR(1);
	DEFINE cAuxiliar8                   CHAR(1);
	DEFINE cAuxiliar9                   CHAR(1);
	DEFINE cAuxiliar10                  CHAR(1);
	DEFINE cAuxiliar11                  CHAR(1);
	DEFINE cNumcteapoder                CHAR(20);
	DEFINE cNomapoder                   CHAR(60);
	DEFINE cDocConst                    CHAR(100);
	DEFINE cDesNacion                   CHAR(15);
	DEFINE cNac                         CHAR(3);
	DEFINE dFechaAlta                   DATE;
	DEFINE cNombreSucursal              CHAR(40);
	DEFINE cPrmTpopersonaGob            CHAR(5);
	DEFINE cValorTpopersonaGop          CHAR(1);
	DEFINE iEstatusCteEmpNet            INTEGER;
	DEFINE cRazonSocial					CHAR(254);
    DEFINE cCURP                        CHAR(20);
	DEFINE cRFCAlt						CHAR(13);
	DEFINE cCodRegFiscal				CHAR(3);
	DEFINE cRegimenFiscal				CHAR(3);
	DEFINE pNumcte						CHAR(20);
	
	---INICIALIZACIONES
	LET iSqlErr						= 0;    		
	LET cCodRet         			= '000000';				
	LET cRFC         				= '';
	LET cApellPaterContactoRepLeg   = '';
	LET cApellMaterContactoRepLeg 	= '';
	LET cNomb1ContactoRepLeg        = '';
	LET cNomb2ContactoRepLeg     	= '';
	LET cCalleFiscal				= '';
	LET cNumExtCalleFiscal       	= '';
	LET cColFiscal         			= '';
	LET vNomCiudFiscal         		= '';
	LET cCodMunFiscal        		= '';
	LET cNomEstadoFiscal        	= '';
	LET cNumcte         			= '';
	LET cNomCorto        			= '';
	LET cPagInternet        		= '';
	LET cSatFea        				= '';
	LET cTelContacto    			= '';
	LET cGiro      					= '';
	LET cNomGiro    				= '';
	LET cDesActObj  				= '';
	LET cUsuarioAut    				= '';	
	LET cStatusAlta 				= '';
	LET cRespStatus 				= '';
	LET cApellPaterFirmantes 		= '';
	LET cApellMaterFirmantes 		= '';
	LET cNomb1Firmantes 			= '';
	LET cNomb2Firmantes 			= '';			
	LET cCuentaNomina	 			= '';
	LET cPoder                      = '';
	LET cAdmin                      = '';
	LET cOrg                        = '';  	
	LET cDesPoder                   = '';
	LET cDesAdmin                   = '';
	LET cDesOrg                     = '';  
	LET cTpoPersona                 = '';		
	LET dFechaIns                   = DATE(1);
	LET dFechaCons                  = DATE(1);
	LET iNac                        = 0;
	LET cNomContacto                = '';
	LET cSufijo                     = '';
	LET cDescSufi                   = '';
	LET cActividadSoc               = '';
	LET cEscritura                  = '';
	LET cNombreNot                  = '';
	LET cNumNot                     = '';
	LET cCdNotarioct                = '';
	LET cDesCdNot                   = '';
	LET cEscrituraPod               = '';
	LET cNomNotariopd               = '';
	LET cNumNotariopd               = '';
	LET cCdNotariopd                = '';
	LET cDesCdNotpd                 = '';
	LET cNombreSoc                  = '';
	LET dFechaInspd                 = DATE(1);
	LET cEmailpm                    = '';
	LET cEsFisica                   = '';
	LET cCdfoliomerct               = '';
	LET cNumfoliomerct              = '';
	LET cAuxiliar1                  = '';
	LET cAuxiliar2                  = '';
	LET cAuxiliar3                  = '';
	LET cAuxiliar4                  = '';
	LET cAuxiliar5                  = '';
	LET cAuxiliar6                  = '';
	LET cAuxiliar7                  = '';
	LET cAuxiliar8                  = '';
	LET cAuxiliar9                  = '';
	LET cAuxiliar10                 = '';
	LET cAuxiliar11                 = '';
	LET cNumcteapoder               = '';
	LET cNomapoder                  = '';
	LET cDocConst                   = '';
	LET cDesNacion                  = '';
	LET cNac                        = '';
	LET cSucursal                   = '';
	LET dFechaAlta                  = DATE(1);
	LET cNombreSucursal             = '';
	LET cPrmTpopersonaGob              = '';
	LET cValorTpopersonaGop            = '';
	LET iEstatusCteEmpNet           = 0;
	LET cRazonSocial				= '';
    LET cCURP                       = '';
	LET cRFCAlt						= '';
	LET cRegimenFiscal				= '';
	LET cCodRegFiscal				= '';
	LET	pNumcte						= '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
		   IF iSqlErr != 0 THEN
			  LET cCodRet = iSqlErr;
			  RETURN 	cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,'')),TRIM(NVL(cRazonSocial,'')),cCURP,cRFCAlt, cRegimenFiscal;
					
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/Antonio/sp_consultarctemoral_rfc.out';
		--TRACE ON;
		
		IF TRIM(NVL(pRfc,'')) = '' THEN
			LET cCodRet = '000001'; --PARÃÂMETRO VACIO
			
		 	RETURN cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,'')),TRIM(NVL(cRazonSocial,'')),cCURP,cRFCAlt, cRegimenFiscal;
		END IF;
		--SE CONSULTA EL TIPO PERSONA, RFC Y SUCURSAL REFERENTE AL CLIENTE
		SELECT LIMIT 1 tpo_persona, numcte, sucursal,rfc_alterno, rfc
		INTO cTpoPersona, cNumcte, cSucursal, cRFCAlt, cRFC
		FROM "informix".si_cliente
		WHERE rfc = TRIM(pRFC)
		AND empresa = '001';

		--SE CONSULTA EL TIPO PERSONA, RFC Y SUCURSAL REFERENTE AL CLIENTE
		SELECT LIMIT 1  numcte, sucursal, rfc
		INTO  cNumcte, cSucursal, cRFC
		FROM "informix".si_fiscal
		WHERE rfc = TRIM(pRFC)
		AND empresa = '001';
		
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
		   LET cCodRet = '000002'; --CONSULTA SIN RESULTADOS, AL CONSULTAR PARAMETRO INVÃÂLIDO
		   
		   RETURN 	cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,'')),TRIM(NVL(cRazonSocial,'')),cCURP,cRFCAlt, cRegimenFiscal;
		END IF;
		
		LET pNumcte = TRIM(cNumcte);
		--CONSULTA es_fisica OBTENIENDO 'S'= PERSONA FÃÂSICA, 'N'=PERSONA MORAL
		SELECT es_fisica
		INTO cEsFisica
        FROM "informix".si_tipper
		WHERE tpo_persona = TRIM(cTpoPersona);
		
		IF cEsFisica = 'S' THEN
		   LET cCodRet = '000003'; --PERSONA FÃÂSICA
		   LET cRFC = '';
		   
		   RETURN 	cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,'')),TRIM(NVL(cRazonSocial,'')),cCURP,cRFCAlt, cRegimenFiscal;
		   
		END IF;
		--CAMBIO
		--SE OBTIENEN LOS DATOS DE CLIENTE MORAL DE LA TABLA si_ctepm
		SELECT TRIM(NVL(numcte,'')),NVL(nombre_corto,''),NVL(pagina_internet,''),TRIM(NVL(sat_fea,'')),
			   TRIM(NVL(telefono_contacto,'')), TRIM(NVL(giro, '')),TRIM(NVL(tipo_poder,'')),TRIM(NVL(tipo_admon,'')), 
			   TRIM(NVL(tipo_org,'')),fecha_inscrip,fecha_constitct,fecha_alta,nacionalidad,TRIM(NVL(nombre_contacto,'')),
			   TRIM(NVL(sufijo,'')),TRIM(NVL(actividadsocial,'')),NVL(escritura_constitutiva,''),
			   TRIM(NVL(nombre_notarioct,'')),TRIM(NVL(numero_notarioct,'')),TRIM(NVL(ciudad_notarioct,'')),
			   TRIM(NVL(numero_foliomercantilct,'')),TRIM(NVL(ciudad_foliomercantilct,'')),TRIM(NVL(escritura_poderes,'')),
			   TRIM(NVL(nombre_notariopd,'')),TRIM(NVL(numero_notariopd,'')), TRIM(NVL(ciudad_notariopd,'')),
			   TRIM(NVL(nombre_sociedad,'')),fecha_inscrippd, TRIM(NVL(emailpm,'')), TRIM(NVL(doc_constitucion,''))
		INTO cNumcte, cNomCorto, cPagInternet, cSatFea,
		     cTelContacto, cGiro, cPoder, cAdmin,
			 cOrg, dFechaIns, dFechaCons,dFechaAlta,iNac, cNomContacto,
			 cSufijo, cActividadSoc, cEscritura,
			 cNombreNot, cNumNot, cCdNotarioct,
			 cNumfoliomerct, cCdfoliomerct, cEscrituraPod,
			 cNomNotariopd, cNumNotariopd, cCdNotariopd,
			 cNombreSoc, dFechaInspd, cEmailpm,cDocConst
		FROM "informix".si_ctepm 
		WHERE numcte = TRIM(pNumcte)
		AND empresa = '001';
		
	    LET cNac = LPAD(iNac, 3,'0');
		
		--SE OBTIENE LA DESCRIPCION DE LA NACIONALIDAD
	    SELECT descripcion
		INTO cDesNacion
		FROM "informix".si_nacion
		WHERE nacion = cNac;
		
		--SE OBTIENE LA DESCRIPCION DEL SUFIJO 
		SELECT descripcion 
		INTO cDescSufi 
		FROM "informix".si_sufijos 
		WHERE empresa = '001'
		AND codigo = TRIM(cSufijo);
		
		--SE OBTIENE LA DESCRIPCION DEL ESTADO DE cCdNotarioct
		
		SELECT nombre 
		INTO cDesCdNot 
		FROM "informix".si_estados 
		WHERE estado = TRIM(cCdNotarioct);
		
		-- SE OBTIENE LA DESCRIPCION DEL ESTADO DE cCdNotariopd
		
		SELECT nombre 
		INTO cDesCdNotpd 
		FROM "informix".si_estados 
		WHERE estado = TRIM(cCdNotariopd);
		
		LET cPrmTpopersonaGob = 'tpo'||TRIM(cTpoPersona);		                                              --el parÃÂ¡metro en la tabla sc_param.		
		
		SELECT TRIM(valor)
		INTO cValorTpopersonaGop
		FROM bdicheq:"informix".sc_param
		WHERE empresa = '001'
		AND codparam = TRIM(cPrmTpopersonaGob);
	
		--SE OBTIENE LA DESCRIPCION DE DATOS DE PERSONAS DE GOBIERNO tpo_persona = '05'*
		IF cValorTpopersonaGop = 'S' THEN
			
			SELECT descripcion
			INTO cDesPoder
			FROM "informix".si_tipo_poder_pm 
			WHERE empresa = '001'
			AND codigo = TRIM(cPoder);
			
			SELECT descripcion
			INTO cDesAdmin
			FROM "informix".si_tipo_admin_pm 
			WHERE empresa = '001'
			AND codigo = TRIM(cAdmin);
			
			SELECT descripcion
			INTO cDesOrg
			FROM "informix".si_tipo_org_pm 
			WHERE empresa = '001'
			AND codigo = TRIM(cOrg);
			
		ELSE 
		   
		   LET cDesPoder = "";
		   LET cDesAdmin = "";
		   LET cDesOrg = "";
		 
		END IF;
		
		
		--SE OBTIENE LA CUENTA Y EL ESTATUS DE LA EMPRESA CON EL SERVICIO DE NOMINA
		SELECT TRIM(NVL(cuenta,'')), TRIM(NVL(status_alta,''))
		INTO cCuentaNomina, cStatusAlta
		FROM bdicheq:"informix".sc_nominaempresas
		WHERE numcte = TRIM(pNumcte);
		
		IF TRIM(NVL(cStatusAlta,'')) = '3' THEN
		   LET cRespStatus = 'Si';
		ELSE
		   LET cRespStatus = 'No';
		END IF;		
						
		--SE OBTIENE NOMBRE DEL REPRESENTANTE LEGAL Y RFC.
		SELECT TRIM(NVL(apell_paterno,'')),TRIM(NVL(apell_materno,'')),
	    TRIM(NVL(nombre1,'')),TRIM(NVL(nombre2,'')) 
		INTO cApellPaterContactoRepLeg,cApellMaterContactoRepLeg,cNomb1ContactoRepLeg,cNomb2ContactoRepLeg
		FROM "informix".si_cliente 
		WHERE numcte = TRIM(cNomContacto)
		AND empresa = '001';
		
							
		--SE OBTIENE DOMICILIO FISCAL.			
		SELECT 	TRIM(NVL(e.nombrecalle,'')),TRIM(NVL(a.numeroextcalle,'')),TRIM(NVL(f.nombrezona,'')),
				TRIM(NVL(g.nombre,'')),TRIM(NVL(c.municipio,'')),TRIM(NVL(b.nombre,''))			
		INTO cCalleFiscal,cNumExtCalleFiscal,cColFiscal,vNomCiudFiscal,cCodMunFiscal,cNomEstadoFiscal
		FROM "informix".si_direcciones_actual a 
			 LEFT OUTER JOIN "informix".si_estados 	   b ON (a.estado = b.estado)
			 LEFT OUTER JOIN "informix".si_municipios  c ON (a.municipio = c.municipio AND a.estado = c.estado AND a.ciudad = c.ciudad AND a.pais = c.pais)
			 LEFT OUTER JOIN "informix".si_catcalles   e ON (a.numerocalle = e.numerocalle)
			 LEFT OUTER JOIN "informix".si_catzonas    f ON (a.numerociudad = f.numerociudad AND a.numerocolonia = f.numerocolonia)
			 LEFT OUTER JOIN "informix".si_ciudades    g ON (a.estado = g.estado AND a.ciudad = g.ciudad)		 
		WHERE a.numcte = TRIM(pNumcte)
		AND a.tipo_dir = 1;
		
		--SE OBTIENE GIRO MERCANTIL.
		SELECT TRIM(NVL(nombre,'')) 
		INTO cNomGiro
		FROM "informix".si_actecon
		WHERE actividad = TRIM(cGiro);
										
		--SE OBTIENE ACTIVIDAD U OBJETO SOCIAL.
		SELECT TRIM(NVL(descripcion,'')) 
		INTO cDesActObj
		FROM "informix".si_actividadsocial 
		WHERE codigo = TRIM(cActividadSoc);		
	
	    --SE OBTIENE EL ESTATUS DEL SERVICIO DE EMPRESANET DEL CLIENTE
	    SELECT MAX (NVL(status_contrato, 0))
		INTO iEstatusCteEmpNet
		FROM bdibei:"informix".bei_contratacion
		WHERE empresa = '001'
		AND num_cliente = pNumcte;
		
		--OBTIENE EL NUMERO DE CTE APODERADO ASI COMO SU NOMBRE
		SELECT numcteapoderado,nombreapoderado 
		INTO cNumcteapoder, cNomapoder
		FROM "informix".si_apoderado
		WHERE empresa = '001'
		AND numcte = TRIM(cNumcte)
		AND secuencia = (SELECT MAX(secuencia) FROM "informix".si_apoderado WHERE empresa = '001');

        --OBTIENE LA CLAVE CURP DE CTE APODERADO
		SELECT TRIM(curp)
		INTO cCURP
		FROM "informix".si_ctepf
		WHERE empresa = '001'
		AND numcte = TRIM(cNumcteapoder);
        
	
		--SE OBTIENE EL AUTORIZADO PARA MANEJAR LAS CUENTAS DE REGISTRO FIRMAS:
		SELECT TRIM(NVL(b.apell_paterno,'')),TRIM(NVL(b.apell_materno,'')),TRIM(NVL(b.nombre1,'')),TRIM(NVL(b.nombre2,''))
		INTO cApellPaterFirmantes,cApellMaterFirmantes,cNomb1Firmantes,cNomb2Firmantes
		FROM bdicheq:"informix".sc_firmantes a INNER JOIN "informix".si_cliente b ON(a.numcte = b.numcte)
		WHERE a.empresa = '001'
		AND a.cuenta = TRIM(cCuentaNomina)
		AND a.secuencia = 1;
		
		--SE OBTIENE EL NOMBRE DE LA SUCURSAL
		SELECT nombre 
		INTO cNombreSucursal
        FROM "informix".si_sucursales
        WHERE sucursal = TRIM(cSucursal);
		
		--CAMBIO 
		--SE OBTIENEN LAS RAZON SOCIAL DEl CLIENTE MORAL DE LA TABLA si_fiscal
		SELECT LIMIT 1 TRIM(NVL(nom_razon_soc,'')),regim_fiscal
		INTO cRazonSocial,cRegimenFiscal
		FROM bdinteg:"informix".si_fiscal
		WHERE empresa = '001' 
		AND numcte = TRIM(pNumcte);

		LET cRegimenFiscal = cCodRegFiscal;
		
		--SE RETORNA INFORMACION.
	   RETURN 	cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,'')),TRIM(NVL(cRazonSocial,'')),cCURP,cRFCAlt, cRegimenFiscal;
                    	
	END;
END PROCEDURE
DOCUMENT
'AUTOR:  Jose Antonio Ramirez Franco',   
'FECHA: 17/10/2023',
'DESCRIPCION: SP encargado de obtener la informaciÃ³n de cliente de tipo Moral por medio del RFC',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_ctamec_generarptportadaproducto2_2(pEmpresa CHAR(3), pNumCte CHAR(20), pNumCta CHAR(20))

	-- DATOS A REGRESAR --
	RETURNING
	CHAR(5) AS COD_RET,    		-- Codigo de retorno
	CHAR(4) AS COD_PRODUCTO,   	--CODIGO DEL PRODUCTO
	CHAR(40) AS NOM_PRODUCTO, 	--NOMBRE DEL PRODUCTO
	CHAR(314) AS RAZON_SOC, 		--RAZON SOCIAL
	CHAR(20) AS NUM_CLIENTE, 	--NUMERO DEL CLIENTE
	CHAR(20) AS NUM_CUENTA,		--NUMERO DE LA CUENTA
	CHAR(18) AS CLABE,			--NUMERO CLABE
	CHAR(1) AS CLAVE_REGIMEN,	--CLAVE DEL REGIMEN DE FIRMAS
	CHAR(20) AS REGIMEN_FIRMAS,	--REGIMEN DE FIRMAS
	CHAR(20) AS ESPECI_MANEJO,	--ESPECIFICACIONES DE MANEJO, COMBINACION
	CHAR(13) AS RFC,			--RFC
	DATE AS FECHA_OPERACION,	--FECHA DE LA OPERACION
	CHAR(104) AS NOMBRE_FIRMANTE,--NOMBRE DE EL FIRMANTE
	CHAR(1) AS TIPO_FIRMA,		--TIPO DE FIRMA
	CHAR(4)	AS	SUCURSAL,		--NUMERO DE SUCURSAL
	CHAR(40) AS	NOMSUC,			--NOMBRE DE SUCURSAL
	CHAR(60) AS	RECA;			--DESCRIPCION DE RECA
	
	--	VARIABLES CONTROL DE ERRORES --
	DEFINE cCodRet  CHAR(5);
	DEFINE iSqlErr  INTEGER;
	
	-- VARIABLES --
	DEFINE cCodReg	CHAR(2);
	DEFINE cCodProd CHAR(4);
	DEFINE cNomProd CHAR(40);
	DEFINE cRazon CHAR(254);
	DEFINE cNumCte CHAR(20);
	DEFINE cNumCta CHAR(20);
	DEFINE cClabe CHAR(18);
	DEFINE cClaveReg CHAR(1);
	DEFINE cRegimen CHAR(20);
	DEFINE cCombinacion CHAR(20);
	DEFINE cRfc CHAR(13);
	DEFINE dFecha DATE;
	DEFINE cFirmNom CHAR(104);
	DEFINE cTipoFirma CHAR(1);
	DEFINE cNumCteFir CHAR(20);
	DEFINE cProducto CHAR(4);
	DEFINE iParam SMALLINT;
	DEFINE cSuc	CHAR(4);
	DEFINE cNomSuc CHAR(40);
	DEFINE cSufijo CHAR(60);	--DSB 16/05/2013
	DEFINE cReca CHAR(60);
	DEFINE cRFCAlt CHAR(13);
	DEFINE cRazonaux CHAR(254);

	-- INICIALIZACION DE VARIABLES --
	LET cCodRet  = "000";
	LET cCodReg = "00";
	LET cCodProd = "";
	LET cNomProd = "";
	LET cRazon ="";
	LET cNumCte ="";
	LET cNumCta ="";
	LET cClabe ="";
	LET cClaveReg = "";
	LET cRegimen ="";
	LET cCombinacion ="";
	LET cRfc ="";
	LET dFecha ="";
	LET cFirmNom ="";
	LET cTipoFirma ="";
	LET cNumCteFir="";
	LET cProducto ="";
	LET iParam = 0;
	LET iSqlErr = 0;
	LET cSuc	= "";
	LET cNomSuc	= "";
	LET cSufijo = "";	--DSB 16/05/2013
	LET cReca = "";
	LET cRFCAlt = "";
	LET cRazonaux = "";		

	--SET DEBUG FILE TO '/tmp/mfinis/Antonio/sp_ctamec_generarptportadaproducto2_2.out';
	--TRACE ON;
	
	
	-- CONTROL DE ERRORES --	
BEGIN
	ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
        END IF
	END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
/*
	IF NVL(pNumCte,'') = '' THEN --SI NO SE PROPORCIONA EL CLIENTE  
		LET pNumCte = NULL;
	END IF
	
	IF pNumCta = "" THEN --SI NO SE PROPORCIONA CUENTA
		LET pNumCta = NULL;
	END IF
*/	
	IF NVL(pNumCta,'') = '' AND NVL(pNumCte,'') = '' OR NVL(pEmpresa,'') = '' THEN --VERIFICA QUE HAYA ALMENOS UN PARAMETRO DE BUSQUEDA
		LET cCodRet = "110";
		RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
	END IF
	
	IF TRIM(pNumCta) <> '' AND TRIM(pNumCte) <> '' THEN
		LET cCodRet = "310"; -- SOLAMENTE DEBE ENVIAR UN SOLO PARAMETRO.
		RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
	END IF
	
	--OBTENEMOS LA FECHA ACTUAL
	SELECT fecha_hoy 
	INTO dFecha
	FROM bdicheq:"informix".sc_fechas
	WHERE empresa = pEmpresa;
	
	
	IF TRIM(NVL(pNumCta,'')) = '' THEN --OBTENEMOS TODOS LOS FIRMANTES POR CUENTA POR EL NUMERO DEL CLIENTE
		LET cNumCte = pNumCte;
		
		--OBTENEMOS LA RAZON SOCIAL, Y EL RFC
		SELECT TRIM(s.nombre1)|| ' '||TRIM(s.nombre2)||' '|| 
		TRIM(s.apell_paterno)||' '||TRIM(s.apell_materno)||' '||TRIM(NVL(f.nom_razon_soc,'')) AS nombre, s.rfc,s.rfc_alterno
		INTO cRazon, cRfc, cRFCAlt
		FROM bdinteg:"informix".si_cliente s
		LEFT JOIN bdinteg:"informix".si_fiscal f ON s.numcte = f.numcte
		WHERE s.empresa = pEmpresa
		AND	s.numcte = cNumCte;
		
		IF NVL(cRFCAlt,'')<>'' THEN
		 LET cRfc = cRFCAlt;
		END IF;
		
		--DSB 16/05/2013		
		SELECT NVL(descripcion, '')
		INTO cSufijo
		FROM bdinteg:"informix".si_sufijos suf,
		bdinteg:"informix".si_ctepm cte
		WHERE suf.codigo = cte.sufijo
		AND cte.numcte = pNumCte;
		LET cRazon = TRIM(cRazon)||" "||TRIM(NVL(cSufijo,''));
		
		IF NVL(cRfc,'') = '' THEN --NO EXISTE EL CLIENTE 
			LET cCodRet = '104';
			RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
		END IF;
		
		
		FOREACH
		--OBTENEMOS LAS CUENTAS DEL CLIENTE Y LA SUCURSAL DE LAS MISMAS.
			SELECT sc_m.cuenta,sc_m.cuenta_clabe, sc_mn.reg_firmas,sc_m.producto, sc_m.sucursal, si.nombre
			INTO cNumCta,cClabe,cClaveReg, cProducto, cSuc, cNomSuc
			FROM bdicheq:"informix".sc_maechq sc_m,
				 bdicheq:"informix".sc_maenoc sc_mn,
				 bdinteg:"informix".si_sucursales si
			WHERE sc_m.empresa = sc_mn.empresa 
			AND sc_m.empresa = pEmpresa
			AND sc_mn.cuenta = sc_m.cuenta
			AND sc_m.num_cte = pNumCte
			AND sc_m.sucursal = si.sucursal
			
			
			--OBTENEMOS LA DESCRIPCION DEL REGIMEN Y LA COMBINACION
			SELECT descripcion,combinacion
			INTO cRegimen,cCombinacion
			FROM bdicntchq:"informix".sq_catregimen 
			WHERE cve_regimen = cClaveReg;
			
			--OBTENEMOS EL CODIGO DEL PRODUCTO Y SU NOMBRE
			SELECT producto,nombre
			INTO cCodProd,cNomProd
			FROM bdicheq:"informix".sc_producto 
			WHERE empresa = pEmpresa
			AND producto = cProducto;
		
			--OBTENEMOS EL VALOR RECA
			SELECT valor
			INTO cReca
			FROM "informix".sc_param
			WHERE empresa = "001"
			AND codparam = "REKA" || cCodProd;
		
			FOREACH
			--OBTENEMOS A LOS FIRMANTES DE LA CUENTA
				SELECT numcte,tipo_firma
				INTO cNumCteFir, cTipoFirma
				FROM bdicheq:"informix".sc_firmantes
				WHERE empresa = pEmpresa			
				AND cuenta = cNumCta
				ORDER BY tipo_firma, secuencia
			
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '|| TRIM(apell_paterno)||' '||TRIM(apell_materno) AS nombre
				INTO cFirmNom
				FROM bdinteg:"informix".si_cliente
				WHERE empresa = pEmpresa
				AND numcte = cNumCteFir;
			
				LET iparam = 1;
		
		
			RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca) WITH RESUME;
		
			END FOREACH;
		END FOREACH;
		
	ELSE --SE REALIZA LA BUSQUEDA POR CUENTA
	
		LET cNumCta = pNumCta;
		--OBTENEMOS EL NUMERO DE CLIENTE, LA CUENTA CLABE Y EL NUMERO DE SUCURSAL DE LA CUENTA.
		SELECT sc.cuenta, sc.num_cte, sc.cuenta_clabe, sc.producto, sc.sucursal, si.nombre
		INTO cNumCta, cNumCte, cClabe, cCodProd, cSuc, cNomSuc
		FROM bdicheq:"informix".sc_maechq sc,
			 bdinteg:"informix".si_sucursales si	
		WHERE sc.empresa = pEmpresa
		AND sc.cuenta = pNumCta
		AND sc.sucursal = si.sucursal;
		
		IF cNumCte IS NULL THEN --NO EXISTE EL NUMERO DE CUENTA
			LET cCodRet = '200';
			RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
		END IF;
		
		--OBTENEMOS EL NOMBRE DEL PRODUCTO
		SELECT nombre 
		INTO cNomProd
		FROM bdicheq:"informix".sc_producto 
		WHERE empresa= pEmpresa
		AND producto = cCodProd;
		
		IF cNumCte IS NULL THEN --NO EXISTE EL PRODUCTO
			LET cCodRet = '210';
			RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
		END IF;
		
		--OBTENEMOS LA RAZON SOCIAL, Y EL RFC
		SELECT TRIM(s.nombre1)|| ' '||TRIM(s.nombre2)||' '|| 
		TRIM(s.apell_paterno)||' '||TRIM(s.apell_materno)||' '||TRIM(NVL(f.nom_razon_soc,'')) AS nombre, s.rfc,s.rfc_alterno
		INTO cRazon, cRfc, cRFCAlt
		FROM bdinteg:"informix".si_cliente s
		LEFT JOIN bdinteg:"informix".si_fiscal f ON s.numcte = f.numcte
		WHERE s.empresa = pEmpresa
		AND	s.numcte = cNumCte;
		
		IF NVL(cRFCAlt,'')<>'' THEN
		 LET cRfc = cRFCAlt;
		END IF;
		
		--DSB 16/05/2013		
		SELECT NVL(descripcion, '')
		INTO cSufijo
		FROM bdinteg:"informix".si_sufijos suf,
		bdinteg:"informix".si_ctepm cte
		WHERE suf.codigo = cte.sufijo 
		AND cte.numcte = cNumCte;
		LET cRazon = TRIM(cRazon)||" "||TRIM(NVL(cSufijo,''));
		
		IF cRazon IS NULL THEN --NO EXISTE EL NUMERO DE CUENTA
			LET cCodRet = '250';
			RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
		END IF;
		
		--OBTENEMOS EL REGIMEN DE FIRMAS
		SELECT reg_firmas 
		INTO cClaveReg 
		FROM bdicheq:"informix".sc_maenoc
		WHERE empresa = pEmpresa
		AND cuenta = pNumCta;
		
		IF cClaveReg IS NULL THEN --NO EXISTE EL NUMERO DE CUENTA EN TABLA MAENOC
			LET cCodRet = '260';
			RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
		END IF;
	
		IF EXISTS(SELECT noproducto FROM bdicnweb:"informix".productos WHERE  activa = 1 AND noproducto = cCodProd) THEN	
		
		ELSE
	
			--OBTENEMOS LA DESCRIPCION DEL REGIMEN DE FIRMAS Y LA COMBINACION
			SELECT descripcion, combinacion
			INTO cRegimen, cCombinacion
			FROM bdicntchq:"informix".sq_catregimen
			WHERE cve_regimen = cClaveReg;
			
			IF cRegimen IS NULL THEN --NO EXISTE EL TIPO DE REGIMEN
				LET cCodRet = '270';
				RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
			END IF;
		END IF;
		
		--OBTENEMOS EL VALOR RECA
		SELECT valor
		INTO cReca
		FROM "informix".sc_param
		WHERE empresa = "001"
		AND codparam = "REKA" || cCodProd;
		
		IF NOT EXISTS(SELECT noproducto FROM bdicnweb:"informix".productos WHERE  activa = 1 AND noproducto = cCodProd) THEN	
			--OBTENEMOS A LOS FIRMANTES
			FOREACH
				SELECT numcte,tipo_firma
				INTO cNumCteFir, cTipoFirma
				FROM bdicheq:"informix".sc_firmantes
				WHERE empresa = pEmpresa			
				AND cuenta = pNumCta
				ORDER BY tipo_firma, secuencia
				
				SELECT TRIM(nombre1)|| ' '||TRIM(nombre2)||' '|| TRIM(apell_paterno)||' '||TRIM(apell_materno) AS nombre
				INTO cFirmNom
				FROM bdinteg:"informix".si_cliente
				WHERE empresa = pEmpresa
				AND numcte = cNumCteFir;
				
				LET iParam = 1;

			RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca) WITH RESUME;
			
			END FOREACH;
		ELSE
			LET cFirmNom ="";
			LET iParam = 1;
			RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
		END IF;
	
	END IF;
	
	IF iParam = 0 THEN --NO HAY DATOS DE FIRMANTES CON ESOS CRITERIOS
		LET cCodRet = '300';
		RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
	END IF
	
END
END PROCEDURE
DOCUMENT
'Procedimiento   : GenerarRptPortadaCtaEjeEmpresarialChequesSPL',
'Versiï¿½n         : 1.0',
'Creado por      : Victor Hugo Nuï¿½ez Velazquez',
'Fecha creacion  : 13 Junio 2011',
'Descripcion     : Obtiene todos los firmantes de una cuenta en particular y obtiene todos los firmantes por cuentas por el numero del cliente',
'Procedimiento   : GenerarRptPortadaCtaEjeEmpresarialChequesSPL',
'Modificado por  : Armando Morales Barraza',
'Fecha creacion  : 14 Marzo 2012',
'Descripcion     : Obtiene el numero y nombre de sucursal de la cuenta',
'MODIFICO: Jose Luis Polanco B.',
'FECHA: DSB 16/05/2013',
'DESCRIPCION: Se agrega el "sufijo" a la variable de retorno "cRazon" para que aparesca en los reportes',
'AUTOR MODIFICACION: Uriel Caamaï¿½o Mejia',
'BD: bdicheq',
'FECHA: 01/12/2017',
'DESCRIPCION: Se clona el SPL y se agregan nuevas reglas de negocio para el comportamiento de los productos',
'AUTOR MODIFICACION: JosÃ© Antonio RamÃ­rez Franco',
'BD: bdicheq',
'FECHA: 11/12/2023',
'DESCRIPCION: Se clona el SPL y se agrega la nueva estructura si_fiscal para la recuperaciÃ³n de la nueva razÃ³n social';

CREATE PROCEDURE "informix".sp_obtclavetarjeta(Tipot CHAR(1), pBin CHAR(6),pSubBin CHAR(2), pCodProdCta CHAR(4), pOperacion CHAR(35), pMigracionVisaActiva CHAR(1))
   RETURNING CHAR(5), CHAR(6), CHAR(3), CHAR(3);
      
   DEFINE cCodRet             CHAR(5);
   DEFINE iSqlErr             INTEGER;
   DEFINE cCodBin             CHAR(6);
   DEFINE cCodProdTar            CHAR(3);
   DEFINE cClave            CHAR(3);


   DEFINE cCodProdPlat          CHAR(4);   
   DEFINE cCodProdORO           CHAR(4);
   DEFINE cSubBinOroN           CHAR(2);
   DEFINE cSubBinPlat          CHAR(2);
   DEFINE cSubBinOroI           CHAR(2);
   DEFINE cClaTipoPlat          CHAR(2);  
   DEFINE cClaTipoOroN          CHAR(2);       
   DEFINE cClaTipoOroI          CHAR(2);   
   DEFINE cClaveOroN            CHAR(3);       
   DEFINE cClaveOroI            CHAR(3);  

   LET cCodRet        ='00000';   
   LET cCodBin        ='000000';
   LET cCodProdTar       ='000';
   LET cClave       ='000';


   LET cCodProdPlat   = '7000';
   LET cCodProdORO    = '8100';
   LET cSubBinOroN    = '05';
   LET cSubBinPlat    = '06';
   LET cSubBinOroI    = '08';
   LET cClaTipoPlat   = '74';
   LET cClaTipoOroN   = '73';
   LET cClaTipoOroI   = '75';
   LET cClaveOroN     = '100';  
   LET cClaveOroI     = '104';  
   
BEGIN
                ON EXCEPTION SET iSqlErr
                      IF iSqlErr <> 0 THEN
                         LET cCodRet = iSqlErr;
                                                               
                         RETURN cCodRet, cCodBin, cCodProdTar, cClave;
                      END IF;
                END EXCEPTION;

                --SET DEBUG FILE TO '/tmp/sp_obtclavetarjeta.out';
	            --TRACE ON;
                
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;
				
				IF pOperacion <> 'Solicitud de Tarjeta Personalizada' THEN

                    IF pMigracionVisaActiva = '1' THEN
                        ----------------------------------------------------------------------------------------------------------------
                        ----------------------------RQM MIGRACIÃN TDC ORO Y PLATINUM MASTERCARD A VISA
                        SELECT b.bin, b.codproductotarjeta, b.clave
                        INTO cCodBin, cCodProdTar, cClave
                        FROM intercard:binproducto a
                        INNER JOIN intercard:Tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
                        WHERE a.bin = pBin 
                        AND a.producto= pSubBin  
                        AND a.codprodcta = pCodProdCta
                        AND b.consecutivo = (
                            CASE 
                                WHEN pCodProdCta = cCodProdPlat AND pSubBin = cSubBinPlat THEN (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin AND  clave_tipotarjeta = cClaTipoPlat)
                                WHEN pCodProdCta = cCodProdORO  AND pSubBin = cSubBinOroI THEN (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin AND  clave_tipotarjeta = cClaTipoOroI) 
                                WHEN pCodProdCta = cCodProdORO  AND pSubBin = cSubBinOroN THEN (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin AND  clave_tipotarjeta = cClaTipoOroN)
                                ELSE                                     (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin)
                            END
                            )           
                        AND b.clave =(
                            CASE  
                                WHEN pCodProdCta = cCodProdORO AND pSubBin = cSubBinOroI THEN cClaveOroI
                                WHEN pCodProdCta = cCodProdORO AND pSubBin = cSubBinOroN THEN cClaveOroN
                                ELSE b.clave 
                            END
                        );
                        ----------------------------------------------------------------------------------------------------------------
                    ELSE
                        -- RQM MIGRACION VISA APAGADA
                        SELECT b.bin, b.codproductotarjeta, clave  
                        INTO cCodBin, cCodProdTar, cClave
                        FROM intercard:binproducto a
                        INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
                        WHERE a.bin = pBin 
                        AND a.producto= pSubBin 
                        AND a.codprodcta = pCodProdCta
                        AND consecutivo = (SELECT max(consecutivo) FROM intercard:tipotarjeta WHERE bin = pBin);

                    END IF;

                ELSE
					IF pCodProdCta NOT IN (cCodProdPlat,cCodProdORO) THEN
						SELECT b.bin, b.codproductotarjeta, clave  
						INTO cCodBin, cCodProdTar, cClave
						FROM intercard:binproducto a
						INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
						WHERE a.bin = pBin 
						AND a.producto= pSubBin 
						AND a.codprodcta = pCodProdCta
						AND consecutivo = (SELECT max(consecutivo) FROM intercard:tipotarjeta WHERE bin = pBin AND descripcion LIKE 'PERSONALIZADO PREDISE%') ;
					ELSE

                        IF pMigracionVisaActiva = '1' THEN
                            ----------------------------RQM MIGRACIÃN TDC ORO Y PLATINUM MASTERCARD A VISA
                            SELECT b.bin, b.codproductotarjeta, b.clave
                            INTO cCodBin, cCodProdTar, cClave
                            FROM intercard:binproducto a
                            INNER JOIN intercard:Tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
                            WHERE a.bin = pBin 
                            AND a.producto= pSubBin  
                            AND a.codprodcta = pCodProdCta
                            AND b.consecutivo = (
                                CASE 
                                    WHEN pCodProdCta = cCodProdPlat AND pSubBin = cSubBinPlat THEN (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin AND  clave_tipotarjeta = cClaTipoPlat)
                                    WHEN pCodProdCta = cCodProdORO  AND pSubBin = cSubBinOroI THEN (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin AND  clave_tipotarjeta = cClaTipoOroI) 
                                    WHEN pCodProdCta = cCodProdORO  AND pSubBin = cSubBinOroN THEN (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin AND  clave_tipotarjeta = cClaTipoOroN)
                                    ELSE                                     (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin)
                                END
                                )           
                            AND b.clave =(
                                CASE  
                                    WHEN pCodProdCta = cCodProdORO AND pSubBin = cSubBinOroI THEN cClaveOroI
                                    WHEN pCodProdCta = cCodProdORO AND pSubBin = cSubBinOroN THEN cClaveOroN
                                    ELSE b.clave 
                                END
                                );
                             ----------------------------------------------------------------------------------------------------------------
                        ELSE 
                            -- RQM MIGRACION VISA APAGADA               
                            SELECT b.bin, b.codproductotarjeta, clave  
                            INTO cCodBin, cCodProdTar, cClave
                            FROM intercard:binproducto a
                            INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
                            WHERE a.bin = pBin 
                            AND a.producto= pSubBin 
                            AND a.codprodcta = pCodProdCta
                            AND consecutivo = (SELECT max(consecutivo) FROM intercard:tipotarjeta WHERE bin = pBin);

                        END IF;

					END IF;
				END IF;
        

           IF cCodBin IS NULL or cCodProdTar IS NULL OR cClave IS NULL THEN
                      LET  cCodRet = '00001';
           END IF;

           RETURN cCodRet, cCodBin, cCodProdTar, cClave;
END;
END PROCEDURE;