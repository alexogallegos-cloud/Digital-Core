create procedure "informix".consctemoral(pempresa char(3),pnumcte char(20))
       returning char(5),char(2),char(4),char(8),
                 char(2),char(1),char(26),char(26),char(26),
                 char(26),char(60),char(13),char(2),char(3),char(3),char(3),
                 char(3),char(1),date,char(26),char(2),char(20),char(20),char(60),
                 smallint,int,money(14,2),date,char(1),char(1),char(11),
                 char(8),
                 char(3),char(30),char(48),char(13),char(2),char(3),Char(3),char(30),
		 char(30),char(30),char(5),char(30),date,date,char(30),char(30),
		 char(30),char(30),char(5),char(30),date,date,char(30),char(30),
		 char(50),char(15),char(20),char(40),char(20),char(20),char(20),
		 smallint, date, char(8), date;

--si_cliente
define vcodret char(5);
--define vesmoral char(1);
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


--si_ctepm
define vnacionalidad	char(3);
define vnombre_corto	char(30);
define vnombre_contacto	char(48);
define vtelefono_contacto char(13);
define vsufijo		char(2);
define vgiro		char(3);
define vactividadsocial	Char(3);
define vpagina_internet	char(30);
define vescritura_constitutiva	char(30);
define vnombre_notarioct char(30);
define vnumero_notarioct char(5);
define vciudad_notarioct char(30);
define vfecha_inscripct	date;
define vfecha_constitct	date;
define vnumero_foliomercantilct char(30);
define vciudad_foliomercantilct char(30);
define vescritura_poderes char(30);
define vnombre_notariopd char(30);
define vnumero_notariopd	char(5);
define vciudad_notariopd char(30);
define vfecha_inscrippd	date;
define vfecha_escritpd 	date;
define vnumero_foliomercantilpd	char(30);
define vciudad_foliomercantilpd	char(30);
define vnombre_sociedad char(50);
define vregpub_comer	char(15);
define vno_inscripcion	char(20);
define voficina		char(40);
define vnum_ofi		char(20);
define vtomo		char(20);
define vprotocolo	char(20);
define vnum_trimestre	smallint;
define vfecha_trimestre	date;
define vuser_insert 	char(8);
define vfecha_insert	date;

let vcodret = "";
--let vesfisica = "";
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

let vnacionalidad = "";
let vnombre_corto = "";
let vnombre_contacto = "";
let vtelefono_contacto = "";
let vsufijo = "";
let vgiro = "";
let vactividadsocial = "";
let vpagina_internet = "";
let vescritura_constitutiva = "";
let vnombre_notarioct = "";
let vnumero_notarioct = "";
let vciudad_notarioct = "";
let vfecha_inscripct = "";
let vfecha_constitct = "";
let vnumero_foliomercantilct = "";
let vciudad_foliomercantilct = "";
let vescritura_poderes = "";
let vnombre_notariopd = "";
let vnumero_notariopd = "";
let vciudad_notariopd = "";
let vfecha_inscrippd = "";
let vfecha_escritpd = "";
let vnumero_foliomercantilpd = "";
let vciudad_foliomercantilpd = "";
let vnombre_sociedad = "";
let vregpub_comer = "";
let vno_inscripcion = "";
let voficina = "";
let vnum_ofi = "";
let vtomo = "";
let vprotocolo = "";
let vnum_trimestre = 0;
let vfecha_trimestre = "";
let vuser_insert = "";
let vfecha_insert = ""; 


BEGIN
        on exception set vsqlerr
                if vsqlerr <> 0 then
                        let vcodret = vsqlerr;


                        RETURN   vcodret  ,vstatus_cte ,vsucursal ,vejecutivo ,vtpo_persona ,
                                            vtipo_cliente ,vapell_paterno ,vapell_materno ,vnombre1 ,vnombre2 ,
                                            vrazon_social ,vrfc ,vsector ,vsegmento ,vactividad_princ ,vgrupo ,vsubgrupo ,
                                            vresidencia ,vfecha_alta ,vapell_casada ,vdistrito ,vnumcte_ref ,vstring1,
                                            vstring2 ,vnumeric1 ,vnumeric2 ,vmoney1 ,vdate1 ,vpuesto_ppes,
                                            vfamiliar_ppes ,vactividad_esp ,vejecut_autoriza,
			

					    vnacionalidad, vnombre_corto, vnombre_contacto, vtelefono_contacto, 
					    vsufijo, vgiro, vactividadsocial, vpagina_internet, vescritura_constitutiva, 
					    vnombre_notarioct, vnumero_notarioct, vciudad_notarioct, vfecha_inscripct, 
					    vfecha_constitct, vnumero_foliomercantilct, vciudad_foliomercantilct, vescritura_poderes,
					    vnombre_notariopd, vnumero_notariopd, vciudad_notariopd, vfecha_inscrippd, vfecha_escritpd, 
					    vnumero_foliomercantilpd, vciudad_foliomercantilpd, vnombre_sociedad, vregpub_comer,
					    vno_inscripcion, voficina, vnum_ofi, vtomo, vprotocolo, vnum_trimestre,  vfecha_trimestre, vuser_insert, vfecha_insert;


               end if
        end exception;

let vcodret = "00000";

select valor into vlong_cte from bdinteg:si_param where cod_param = 7
and   empresa = pempresa;

        let vlongitud = length(pnumcte);
        if vlongitud < vlong_cte then
                foreach
                        execute procedure formateo_cte(pnumcte)
                                into pnumcte
                end foreach;
        end if


       SELECT                     nvl(c.status_cte, ' ') ,nvl(c.sucursal, ' ') ,nvl(c.ejecutivo, ' ') ,nvl(c.tpo_persona, ' '),
                                  nvl(c.tipo_cliente, ' '),nvl(c.apell_paterno, ' '),nvl(c.apell_materno, ' '), nvl(c.nombre1, ' '),nvl(c.nombre2, ' '),
                                  nvl(c.razon_social, ' '), nvl(c.rfc, ' ') ,nvl(c.sector, ' '), nvl(c.segmento, ' '), nvl(c.actividad_princ, ' '), nvl(c.grupo, ' '), nvl(c.subgrupo, ' '),
                                  nvl(c.residencia, ' '), nvl(c.fecha_alta, ' ') ,nvl(c.apell_casada, ' '), nvl(c.distrito, ' '), nvl(c.numcte_ref, ' ') ,nvl(c.string1, ' '),
                                  nvl(c.string2, ' '), nvl(c.numeric1, ' '), nvl(c.numeric2, ' '), nvl(c.money1, ' '), nvl(c.date1, ' '), nvl(c.puesto_ppes, ' '),
                                  nvl(c.familiar_ppes, ' ') ,nvl(c.actividad_esp, ' '), nvl(c.ejecut_autoriza, ' '),

				  nvl(f.nacionalidad, ' '), nvl(f.nombre_corto, ' '), nvl(f.nombre_contacto, ' '), nvl(f.telefono_contacto, ' '), nvl(f.sufijo, ' '), 
				  nvl(f.giro, ' '), nvl(f.actividadsocial, ' '), nvl(f.pagina_internet, ' '), nvl(f.escritura_constitutiva, ' '), nvl(f.nombre_notarioct, ' '), 
				  nvl(f.numero_notarioct, ' '), nvl(f.ciudad_notarioct, ' '), nvl(f.fecha_inscripct, ' '), nvl(f.fecha_constitct, ' '), nvl(f.numero_foliomercantilct, ' '), 
				  nvl(f.ciudad_foliomercantilct, ' '), nvl(f.escritura_poderes, ' '), nvl(f.nombre_notariopd, ' '), nvl(f.numero_notariopd, ' '), nvl(f.ciudad_notariopd, ' '),
				  nvl(f.fecha_inscrippd, ' '), nvl(f.fecha_escritpd, ' '), nvl(f.numero_foliomercantilpd, ' '), nvl(f.ciudad_foliomercantilpd, ' '), nvl(f.nombre_sociedad, ' '), 
				  nvl(f.regpub_comer, ' '), nvl(f.no_inscripcion, ' '), nvl(f.oficina, ' '), nvl(f.num_ofi, ' '), nvl(f.tomo, ' '), nvl(f.protocolo, ' '), nvl(f.num_trimestre, 0), nvl(f.fecha_trimestre, ''),
				  nvl(f.user_insert, ' '), nvl(f.fecha_insert, ' ')


       INTO                       vstatus_cte ,vsucursal ,vejecutivo ,vtpo_persona ,
                                  vtipo_cliente ,vapell_paterno ,vapell_materno ,vnombre1 ,vnombre2 ,
                                  vrazon_social ,vrfc ,vsector ,vsegmento ,vactividad_princ ,vgrupo ,vsubgrupo ,
                                  vresidencia ,vfecha_alta ,vapell_casada ,vdistrito ,vnumcte_ref ,vstring1,
                                  vstring2 ,vnumeric1 ,vnumeric2 ,vmoney1 ,vdate1 ,vpuesto_ppes,
                                  vfamiliar_ppes ,vactividad_esp ,vejecut_autoriza,

				  vnacionalidad, vnombre_corto, vnombre_contacto, vtelefono_contacto, vsufijo, vgiro, vactividadsocial,
				  vpagina_internet, vescritura_constitutiva, vnombre_notarioct, vnumero_notarioct, vciudad_notarioct,
				  vfecha_inscripct, vfecha_constitct, vnumero_foliomercantilct, vciudad_foliomercantilct, vescritura_poderes, 
				  vnombre_notariopd, vnumero_notariopd, vciudad_notariopd, vfecha_inscrippd, vfecha_escritpd, vnumero_foliomercantilpd,
				  vciudad_foliomercantilpd, vnombre_sociedad, vregpub_comer, vno_inscripcion, voficina, vnum_ofi, vtomo, vprotocolo,
				  vnum_trimestre, vfecha_trimestre, vuser_insert, vfecha_insert	          
				   

      FROM si_cliente c,outer si_ctepm f
      WHERE c.numcte = pnumcte and
            c.empresa = pempresa and
            c.numcte = f.numcte;


if vfecha_trimestre is null then

	let vfecha_trimestre = ' ';
end if

        		RETURN  vcodret  ,vstatus_cte ,vsucursal ,vejecutivo ,vtpo_persona ,
                                            vtipo_cliente ,vapell_paterno ,vapell_materno ,vnombre1 ,vnombre2 ,
                                            vrazon_social ,vrfc ,vsector ,vsegmento ,vactividad_princ ,vgrupo ,vsubgrupo ,
                                            vresidencia ,vfecha_alta ,vapell_casada ,vdistrito ,vnumcte_ref ,vstring1,
                                            vstring2 ,vnumeric1 ,vnumeric2 ,vmoney1 ,vdate1 ,vpuesto_ppes,
                                            vfamiliar_ppes ,vactividad_esp ,vejecut_autoriza,

 					    vnacionalidad, vnombre_corto, vnombre_contacto, vtelefono_contacto, 
					    vsufijo, vgiro, vactividadsocial, vpagina_internet, vescritura_constitutiva, 
					    vnombre_notarioct, vnumero_notarioct, vciudad_notarioct, vfecha_inscripct, 
					    vfecha_constitct, vnumero_foliomercantilct, vciudad_foliomercantilct, vescritura_poderes,
					    vnombre_notariopd, vnumero_notariopd, vciudad_notariopd, vfecha_inscrippd, vfecha_escritpd, 
					    vnumero_foliomercantilpd, vciudad_foliomercantilpd, vnombre_sociedad, vregpub_comer,
					    vno_inscripcion, voficina, vnum_ofi, vtomo, vprotocolo, vnum_trimestre,  vfecha_trimestre, vuser_insert, vfecha_insert;			


 
end
end procedure



















;