CREATE PROCEDURE "informix".consnumcte(pempresa char(3),pnumcte char(20))
       returning char(5),char(2),char(4),char(8),
                 char(2),char(1),char(26),char(26),char(26),
                 char(26),char(60),char(13),char(2),char(3),char(3),char(3),
                 char(3),char(1),date,char(26),char(2),char(20),char(20),char(60),
                 smallint,int,money(14,2),date,char(1),char(1),char(11),
                 char(8),
                 date,char(2),char(3),char(18),char(2),char(1),char(3),char(1),
                 char(20),char(2),char(20),char(12),smallint,char(60),char(60),
                 char(60),char(1),char(2),char(2),smallint,char(60),money(16,2),
                 char(30),char(20),char(20),char(20),char(20),char(20),int,int,
                 money(14,2),date;
    
    define vcodret char(5);
    define vesfisica char(1);
    define vlong_cte smallint;
    define vlongitud smallint;
    define vsqlerr integer;
    define vdiacorte smallint;
    
    define vstatus_cte char(2);
    define vsucursal char(4);
    define vejecutivo char(8);
    define vtpo_persona char(2);
    define vtipo_cliente char(1);
    define vapell_paterno char(26);
    define vapell_materno char(26);
    define vnombre1 char(26);
    define vnombre2 char(26);
    define vrazon_social char(60);
    define vrfc char(13);
    define vsector char(2);
    define vsegmento char(3);
    define vactividad_princ char(3);
    define vgrupo char(3);
    define vsubgrupo char(3);
    define vresidencia char(1);
    define vfecha_alta date ;
    define vapell_casada char(26);
    define vdistrito char(2);
    define vnumcte_ref char(20);
    define vstring1 char(20);
    define vstring2 char(60);
    define vnumeric1 smallint ;
    define vnumeric2 int ;
    define vmoney1 money(14,2);
    define vdate1 date ;
    define vpuesto_ppes char(1);
    define vfamiliar_ppes char(1);
    define vactividad_esp char(11);
    define vejecut_autoriza char(8);

    define vpffecha_nac date;
    define vpflugar_nac char(2);
    define vpfnacionalidad char(3);
    define vpfno_fm3 char(18);
    define vpfestado_civil char(2);
    define vpfregim_matrimonio char(1);
    define vpfprofesion char(3);
    define vpfsexo char(1);
    define vpfcurp char(20);
    define vpfcodidentifi char(2);
    define vpfnumidentifi char(20);
    define vpfno_imss char(12);
    define vpfdependientes smallint ;
    define vpftutor char(60);
    define vpfemail char(60);
    define vpfpfnom_conyuge char(60);
    define vpfseguro_defunc char(1);
    define vpfescolaridad char(2);
    define vpfhabita_en char(2);
    define vpfanios_habita smallint ;
    define vpfnombre_prop char(60);
    define vpfimp_hipo_renta money(16,2);
    define vpfactividadogiro char(30);
    define vpfnumeroife char(20);
    define vpfnumerotutor char(20);
    define vpfnumeroconyuge char(20);
    define vpfstring1 char(20);
    define vpfstring2 char(20);
    define vpfnumeric1 int ;
    define vpfnumeric2 int ;
    define vpfmoney1 money(14,2);
    define vpfdate1 date ;
    define vrfc_alterno char(13);
	define vdescripcion char(60);
    
    let vcodret = "";
    let vesfisica = "";
    let vlong_cte = 0;
    let vlongitud = 0;
    let vsqlerr = 0;
    let vdiacorte = 0;
    
    let vstatus_cte  = "";
    let vsucursal = "";
    let vejecutivo = "";
    let vtpo_persona = "";
    let vtipo_cliente = "";
    let vapell_paterno = "";
    let vapell_materno = "";
    let vnombre1 = "";
    let vnombre2 = "";
    let vrazon_social = "";
    let vrfc = "";
    let vsector = "";
    let vsegmento = "";
    let vactividad_princ = "";
    let vgrupo = "";
    let vsubgrupo = "";
    let vresidencia = "";
    let vfecha_alta = "";
    let vapell_casada  = "";
    let vdistrito = "";
    let vnumcte_ref = "";
    let vstring1 = "";
    let vstring2  = "";
    let vnumeric1  = 0;
    let vnumeric2  = 0;
    let vmoney1 = 0;
    let vdate1  = "";
    let vpuesto_ppes = "";
    let vfamiliar_ppes = "";
    let vactividad_esp = "";
    let vejecut_autoriza  = "";
    
    let vpffecha_nac  = "";
    let vpflugar_nac  = "";
    let vpfnacionalidad  = "";
    let vpfno_fm3  = "";
    let vpfestado_civil = "";
    let vpfregim_matrimonio = "";
    let vpfprofesion  = "";
    let vpfsexo = "";
    let vpfcurp  = "";
    let vpfcodidentifi = "";
    let vpfnumidentifi  = "";
    let vpfno_imss  = "";
    let vpfdependientes = 0;
    let vpftutor  = "";
    let vpfemail  = "";
    let vpfpfnom_conyuge  = "";
    let vpfseguro_defunc = "";
    let vpfescolaridad = "";
    let vpfhabita_en = "";
    let vpfanios_habita  = 0;
    let vpfnombre_prop = "";
    let vpfimp_hipo_renta  = 0;
    let vpfactividadogiro = "";
    let vpfnumeroife = "";
    let vpfnumerotutor = "";
    let vpfnumeroconyuge = "";
    let vpfstring1 = "";
    let vpfstring2 = "";
    let vpfnumeric1 = 0;
    let vpfnumeric2 = 0;
    let vpfmoney1 = 0;
    let vpfdate1 = "";
    let vrfc = "";
	let vdescripcion = "";
    
    begin
    
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            RETURN vcodret  ,vstatus_cte ,vsucursal ,vejecutivo ,vtpo_persona ,
                   vtipo_cliente ,vapell_paterno ,vapell_materno ,vnombre1 ,vnombre2 ,
                   vrazon_social ,vrfc ,vsector ,vsegmento ,vactividad_princ ,vgrupo ,vsubgrupo ,
                   vresidencia ,vfecha_alta ,vapell_casada ,vdistrito ,vnumcte_ref ,vstring1,
                   vstring2 ,vnumeric1 ,vnumeric2 ,vmoney1 ,vdate1 ,vpuesto_ppes,
                   vfamiliar_ppes ,vactividad_esp ,vejecut_autoriza,
                   vpffecha_nac  ,vpflugar_nac  ,vpfnacionalidad  ,vpfno_fm3  ,vpfestado_civil,
                   vpfregim_matrimonio ,vpfprofesion  ,vpfsexo  ,vpfcurp  ,vpfcodidentifi,
                   vpfnumidentifi  ,vpfno_imss  ,vpfdependientes  ,vpftutor  ,vpfemail,
                   vpfpfnom_conyuge   ,vpfseguro_defunc ,vpfescolaridad ,vpfhabita_en ,vpfanios_habita,
                   vpfnombre_prop ,vpfimp_hipo_renta ,vpfactividadogiro ,vpfnumeroife ,vpfnumerotutor ,
                   vpfnumeroconyuge ,vpfstring1 ,vpfstring2 ,vpfnumeric1 ,vpfnumeric2 ,vpfmoney1 ,vpfdate1;
        end if
    end exception;
    
SET LOCK MODE TO WAIT 3;
SET ISOLATION  TO DIRTY READ;


    let vcodret = "00000";
    
    select valor 
      into vlong_cte 
      from bdinteg:"informix".si_param 
     where cod_param = 7
       and empresa = pempresa;

    let vlongitud = length(pnumcte);
    
    if vlongitud < vlong_cte then
        foreach
            execute procedure formateo_cte(pnumcte)
            into pnumcte
        end foreach;
    end if

    SELECT c.status_cte ,c.sucursal ,c.ejecutivo ,c.tpo_persona ,
           c.tipo_cliente ,c.apell_paterno ,c.apell_materno ,c.nombre1 ,c.nombre2 ,
           c.razon_social ,c.rfc ,c.sector ,c.segmento ,c.actividad_princ ,c.grupo ,c.subgrupo ,
           c.residencia ,c.fecha_insert ,c.apell_casada ,c.distrito ,c.numcte_ref ,c.string1,
           c.string2 ,c.numeric1 ,c.numeric2 ,c.money1 ,c.date1 ,c.puesto_ppes,
           c.familiar_ppes ,c.actividad_esp ,c.ejecut_autoriza,
           f.fecha_nac  ,f.lugar_nac  ,f.nacionalidad  ,f.no_fm3  ,f.estado_civil,
           f.regim_matrimonio ,f.profesion  ,f.sexo  ,f.curp  ,f.codidentifi,
           f.numidentifi  ,f.no_imss  ,f.dependientes  , f.tutor,
           f.nom_conyuge   ,f.seguro_defunc ,f.escolaridad ,f.habita_en ,f.anios_habita,
           f.nombre_prop ,f.imp_hipo_renta ,f.actividadogiro ,f.numeroife ,f.numerotutor ,
           f.numeroconyuge ,f.string1 ,f.string2 ,f.numeric1 ,f.numeric2 ,f.money1 ,f.date1, c.rfc_alterno
      INTO vstatus_cte ,vsucursal ,vejecutivo ,vtpo_persona ,
           vtipo_cliente ,vapell_paterno ,vapell_materno ,vnombre1 ,vnombre2 ,
           vrazon_social ,vrfc ,vsector ,vsegmento ,vactividad_princ ,vgrupo ,vsubgrupo ,
           vresidencia ,vfecha_alta ,vapell_casada ,vdistrito ,vnumcte_ref ,vstring1,
           vstring2 ,vnumeric1 ,vnumeric2 ,vmoney1 ,vdate1 ,vpuesto_ppes,
           vfamiliar_ppes ,vactividad_esp ,vejecut_autoriza,
           vpffecha_nac  ,vpflugar_nac  ,vpfnacionalidad  ,vpfno_fm3  ,vpfestado_civil,
           vpfregim_matrimonio ,vpfprofesion  ,vpfsexo  ,vpfcurp  ,vpfcodidentifi,
           vpfnumidentifi  ,vpfno_imss  ,vpfdependientes  ,vpftutor,
           vpfpfnom_conyuge   ,vpfseguro_defunc ,vpfescolaridad ,vpfhabita_en ,vpfanios_habita,
           vpfnombre_prop ,vpfimp_hipo_renta ,vpfactividadogiro ,vpfnumeroife ,vpfnumerotutor ,
           vpfnumeroconyuge ,vpfstring1 ,vpfstring2 ,vpfnumeric1 ,vpfnumeric2 ,vpfmoney1 ,vpfdate1, vrfc_alterno
      FROM "informix".si_cliente c,
     outer "informix".si_ctepf f
     WHERE c.numcte = pnumcte 
       and c.empresa = pempresa 
       and c.numcte = f.numcte;
       
		select nvl(correo_elec, ' ')
		into vpfemail
		from "informix".si_correos
		where empresa = '001'
		and numcte = pnumcte
		and status_correo = 'A'
		and secuencia in 
		(select max(secuencia)
		from si_correos
		where  empresa = '001' and 
		numcte = pnumcte
		and status_correo = 'A');
       
    IF vpfemail is null THEN
        LET vpfemail = ' ';
    END IF;

    if vtpo_persona = " " or vtpo_persona is null then
        let vcodret = "800";
        RETURN  vcodret ,vstatus_cte ,vsucursal ,vejecutivo ,vtpo_persona ,
                vtipo_cliente ,vapell_paterno ,vapell_materno ,vnombre1 ,vnombre2 ,
                vrazon_social ,vrfc ,vsector ,vsegmento ,vactividad_princ ,vgrupo ,vsubgrupo ,
                vresidencia ,vfecha_alta ,vapell_casada ,vdistrito ,vnumcte_ref ,vstring1,
                vstring2 ,vnumeric1 ,vnumeric2 ,vmoney1 ,vdate1 ,vpuesto_ppes,
                vfamiliar_ppes ,vactividad_esp ,vejecut_autoriza,
                vpffecha_nac  ,vpflugar_nac  ,vpfnacionalidad  ,vpfno_fm3  ,vpfestado_civil,
                vpfregim_matrimonio ,vpfprofesion  ,vpfsexo  ,vpfcurp  ,vpfcodidentifi,
                vpfnumidentifi  ,vpfno_imss  ,vpfdependientes  ,vpftutor  ,vpfemail,
                vpfpfnom_conyuge   ,vpfseguro_defunc ,vpfescolaridad ,vpfhabita_en ,vpfanios_habita,
                vpfnombre_prop ,vpfimp_hipo_renta ,vpfactividadogiro ,vpfnumeroife ,vpfnumerotutor ,
                vpfnumeroconyuge ,vpfstring1 ,vpfstring2 ,vpfnumeric1 ,vpfnumeric2 ,vpfmoney1 ,vpfdate1;
    else
        select es_fisica 
          into vesfisica 
          from bdinteg:"informix".si_tipper
         where tpo_persona = vtpo_persona;
         
        if vesfisica <> "S" then
            let vapell_paterno = " ";
            let vapell_materno = " ";
            let vnombre1 = " ";
            let vnombre2 = " ";
			select descripcion 
			  into vdescripcion 
			  from bdinteg:"informix".si_ctepm, bdinteg:"informix".si_sufijos 
			 where numcte = pnumcte
			   and codigo = sufijo;
            let vrazon_social = trim(vrazon_social)||" "||trim(vdescripcion);			   
        else
            let vrazon_social = " ";
        end if;

        IF vrfc_alterno is not null and vrfc_alterno <> "" THEN
            LET vrfc = vrfc_alterno;
        END IF;	

        RETURN  vcodret  ,vstatus_cte ,vsucursal ,vejecutivo ,vtpo_persona ,
                vtipo_cliente ,vapell_paterno ,vapell_materno ,vnombre1 ,vnombre2 ,
                vrazon_social ,vrfc ,vsector ,vsegmento ,vactividad_princ ,vgrupo ,vsubgrupo ,
                vresidencia ,vfecha_alta ,vapell_casada ,vdistrito ,vnumcte_ref ,vstring1,
                vstring2 ,vnumeric1 ,vnumeric2 ,vmoney1 ,vdate1 ,vpuesto_ppes,
                vfamiliar_ppes ,vactividad_esp ,vejecut_autoriza,
                vpffecha_nac  ,vpflugar_nac  ,vpfnacionalidad  ,vpfno_fm3  ,vpfestado_civil,
                vpfregim_matrimonio ,vpfprofesion  ,vpfsexo  ,vpfcurp  ,vpfcodidentifi,
                vpfnumidentifi  ,vpfno_imss  ,vpfdependientes  ,vpftutor  ,vpfemail,
                vpfpfnom_conyuge   ,vpfseguro_defunc ,vpfescolaridad ,vpfhabita_en ,vpfanios_habita,
                vpfnombre_prop ,vpfimp_hipo_renta ,vpfactividadogiro ,vpfnumeroife ,vpfnumerotutor ,
                vpfnumeroconyuge ,vpfstring1 ,vpfstring2 ,vpfnumeric1 ,vpfnumeric2 ,vpfmoney1 ,vpfdate1;
    end if;

    end
    
end procedure
 
DOCUMENT
"MODIFICO : Daniel Zambada",
"FECHA : 27/octubre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".conscteppesfamilia(pempresa char(3),
                           pnumcte char(20))

       returning 	char(5), char(3), char(20), smallint, char(20),char(60), char(3), char(8), date;

define vcodret char(5);
define vciclo smallint;
define vsqlerr integer;

define vempresa char(3);
define vnumcte char(20);
define vsecuencia smallint;
define vnumctefamiliar  char(20);
define vnombrefamiliar  char(60);
define vparentesco char(3);
define vuser_insert 	char(8);
define vfecha_insert	date;



let vciclo = 0;                        
let vcodret = "000";
let  vsqlerr = 0;

let vempresa = "";
let vnumcte = "";
let vsecuencia = 0;
let vnumctefamiliar  = "";
let vnombrefamiliar  = "";
let vparentesco = "";
let vuser_insert = "";
let vfecha_insert = "";




begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret, vempresa, vnumcte, vsecuencia , vnumctefamiliar, vnombrefamiliar, vparentesco, vuser_insert, vfecha_insert;

      end if;
   end exception;

SET LOCK MODE TO WAIT 3;
SET ISOLATION  TO DIRTY READ;

   foreach
   
		SELECT empresa, numcte, secuencia, numctefamiliar, nombrefamiliar, parentesco, usuario_insert, fecha_insert 
		INTO vempresa, vnumcte, vsecuencia, vnumctefamiliar, vnombrefamiliar, vparentesco, vuser_insert, vfecha_insert	 	
		FROM si_ppefamilia 
		WHERE numcte = pnumcte 
		order by secuencia
        
         

      return    vcodret, vempresa, vnumcte, vsecuencia, vnumctefamiliar, vnombrefamiliar, vparentesco, vuser_insert, vfecha_insert with resume;

   end foreach;
      
end
end procedure
;