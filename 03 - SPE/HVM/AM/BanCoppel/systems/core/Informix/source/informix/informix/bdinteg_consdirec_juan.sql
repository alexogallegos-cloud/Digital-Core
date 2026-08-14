CREATE PROCEDURE "informix".consdirec_juan(pnumcte CHAR(20), pconsulta INTEGER, ptipo_dir INTEGER, pnum_direc SMALLINT)
RETURNING CHAR(5),  -- Codigo Retorno
          CHAR(20), -- numcte
          INTEGER,  -- secuencia
          CHAR(1),  -- tipo_dir
          CHAR(40), -- calle
          CHAR(60), -- colonia
          CHAR(40), -- entre_calles
          CHAR(3),  -- pais
          CHAR(2),  -- estado
          CHAR(3),  -- ciudad
          CHAR(5),  -- municipio
          CHAR(5),  -- cod_postal
          CHAR(11), -- apart_postal
          CHAR(1),  -- tipo_telef1
          CHAR(13), -- telefono1
          CHAR(1),  -- tipo_telef2
          CHAR(13), -- telefono2
          CHAR(1),  -- tipo_telef3
          CHAR(13), -- telefono3
          CHAR(5),  -- extension
          CHAR(2),  -- estado_inegi
          CHAR(3),  -- municipio_inegi
          CHAR(4),  -- localidad_inegi
          SMALLINT, --numerocuidad
          CHAR(10), -- numextcalle
          CHAR(10), -- numintcalle
          CHAR(6),  -- departamento
          INTEGER,  -- numerocalle
          INTEGER,  -- numerocolonia
          CHAR(1),  -- puntocardinal
          CHAR(1),  -- unidadhabitac
          SMALLINT, -- manzana
          SMALLINT, -- otros
          SMALLINT, -- andador
          SMALLINT, -- etapa
          SMALLINT, -- lote
          SMALLINT, -- edificio
          SMALLINT, -- entrada
          CHAR(80), -- observaciones
          CHAR(8),  -- user_insert
          DATE,     -- fecha_insert
          CHAR(1),  -- ind_cofeteltel1
          CHAR(1),  -- ind_cofeteltel2
          CHAR(1),  -- ind_cofeteltel3
          CHAR(2);  -- carrier

    -- Define de Variables
    DEFINE vcodret char(5);
    DEFINE vciclo smallint;
    DEFINE vsqlerr integer;

    -- Define  variables de la tabla si_direcciones y si_direcciones_actual
    DEFINE vnumcte CHAR(20);
    DEFINE vsecuencia INTEGER;
    DEFINE vtipo_dir CHAR(1);
    DEFINE vcalle CHAR(40);
    DEFINE vcolonia CHAR(60);
    DEFINE ventre_calles CHAR(40);
    DEFINE vpais CHAR(3);
    DEFINE vestado CHAR(2);
    DEFINE vciudad CHAR(3);
    DEFINE vmunicipio CHAR(5);
    DEFINE vcod_postal CHAR(5);
    DEFINE vapart_postal CHAR(11);
    DEFINE vtipo_telef1  CHAR(1);
    DEFINE vtelefono1 CHAR(13);
    DEFINE vtipo_telef2  CHAR(1);
    DEFINE vtelefono2  CHAR(13);
    DEFINE vtipo_telef3  CHAR(1);
    DEFINE vtelefono3  CHAR(13);
    DEFINE vextension CHAR(5);
    DEFINE vestado_inegi  CHAR(2);
    DEFINE vmunicipio_inegi CHAR(3);
    DEFINE vlocalidad_inegi  CHAR(4);
    DEFINE vnumerociudad SMALLINT;
    DEFINE vnumeroextcalle  CHAR(10);
    DEFINE vnumerointcalle  CHAR(10);
    DEFINE vdepartamento  CHAR(6);
    DEFINE vnumerocalle INTEGER;
    DEFINE vnumerocolonia INTEGER;
    DEFINE vpuntocardinal  CHAR(1);
    DEFINE vunidadhabitac  CHAR(1);
    DEFINE vmanzana SMALLINT;
    DEFINE votros  SMALLINT;
    DEFINE vandador SMALLINT;
    DEFINE vetapa SMALLINT;
    DEFINE vlote  SMALLINT;
    DEFINE vedificio  SMALLINT;
    DEFINE ventrada  SMALLINT;
    DEFINE vobservaciones CHAR(80);
    DEFINE vuser_insert CHAR(8);
    DEFINE vfecha_insert DATE;
    DEFINE vind_cofeteltel1 CHAR(1);
    DEFINE vind_cofeteltel2 CHAR(1);
    DEFINE vind_cofeteltel3 CHAR(1);
    DEFINE vCarrier char(2);
	-- Modificación --
	define vlimite_inicia int;
	define vlimite_final  int;
	define vnum_row       int;

    --Inicializa variables
    LET vciclo = 0;
    LET vcodret = "000";
    LET  vsqlerr = 0;
    -- Inicializa variables de la tabla si_direcciones y si_direcciones_actual
    LET vnumcte = "";
    LET vsecuencia = 0;
    LET vtipo_dir = "";
    LET vcalle = "";
    LET vcolonia = "";
    LET ventre_calles = "";
    LET vpais = "";
    LET vestado = "";
    LET vciudad = "";
    LET vmunicipio = "";
    LET vcod_postal = "";
    LET vapart_postal = "";
    LET vtipo_telef1 = "";
    LET vtelefono1 = "";
    LET vtipo_telef2 = "";
    LET vtelefono2 = "";
    LET vtipo_telef3 = "";
    LET vtelefono3 = "";
    LET vextension = "";
    LET vestado_inegi = "";
    LET vmunicipio_inegi = "";
    LET vlocalidad_inegi = "";
    LET vnumerociudad = 0;
    LET vnumeroextcalle = "";
    LET vnumerointcalle = "";
    LET vdepartamento = "";
    LET vnumerocalle = 0;
    LET vnumerocolonia = 0;
    LET vpuntocardinal = "";
    LET vunidadhabitac = "";
    LET vmanzana = 0;
    LET votros  = 0;
    LET vandador  = 0;
    LET vetapa = 0;
    LET vlote = 0;
    LET vedificio  = 0;
    LET ventrada = 0;
    LET vobservaciones = "";
    LET vuser_insert = "";
    LET vfecha_insert = "";
    LET vind_cofeteltel1 = "";
    LET vind_cofeteltel2 = "";
    LET vind_cofeteltel3 = "";
    let vCarrier = '00';
	-- Modificación --
	let vlimite_inicia = 0;
	let vlimite_final  = 0; 
	let vnum_row       = 0;
    
    --- SET DEBUG FILE TO "/respaldosbd/consdirec_n.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret,vnumcte,vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,vciudad,vmunicipio,vcod_postal,vapart_postal,
                   vtipo_telef1,vtelefono1,vtipo_telef2,vtelefono2,vtipo_telef3,vtelefono3,vextension,vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,
                   vnumerociudad,vnumeroextcalle,vnumerointcalle,vdepartamento,vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,
                   vmanzana,votros,vandador,vetapa,vlote,vedificio,ventrada,vobservaciones,vuser_insert,vfecha_insert,vind_cofeteltel1,
                   vind_cofeteltel2,vind_cofeteltel3,vCarrier;
        END IF;
    END EXCEPTION;
	
	-- BLOQUE DE MODIFICACION --
	select max(secuencia) 
      into vnum_row 
      from "informix".si_direcciones 
     where numcte = pnumcte;
   
	IF vnum_row > 40 THEN 
		LET vlimite_inicia = vnum_row - 20;
		LET vlimite_final  = vnum_row; 
	ELSE 
		LET vlimite_inicia = 1;
		LET vlimite_final  = vnum_row;
	END IF;
   -- FIN DE BLOQUE

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF pconsulta = 1 THEN
        FOREACH
            SELECT a.numcte, a.secuencia, a.tipo_dir,calle, a.colonia, a.entre_calles, a.pais,estado, a.ciudad, a.municipio, a.cod_postal, a.apart_postal, 
                   --nvl(tel1.tipo_tel,''), nvl(tel1.telefono,''), nvl(tel2.tipo_tel,''), nvl(tel2.telefono,''), nvl(tel3.tipo_tel,''), nvl(tel3.telefono,''), nvl(tel3.extension,''), 
                   a.estado_inegi, a.municipio_inegi, a.localidad_inegi, a.numerociudad, a.numeroextcalle, a.numerointcalle, a.departamento, 
                   a.numerocalle, a.numerocolonia, a.puntocardinal, a.unidadhabitac, a.manzana, a.otros, a.andador, a.etapa, a.lote, a.edificio,
                   a.entrada, a.observaciones, a.user_insert, a.fecha_insert, a.ind_cofeteltel1, a.ind_cofeteltel2, a.ind_cofeteltel3
              INTO vnumcte,vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,vciudad,vmunicipio,vcod_postal,vapart_postal,
			       --vtipo_telef1,vtelefono1,vtipo_telef2,vtelefono2,vtipo_telef3,vtelefono3,vextension,
				   vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,vnumerociudad,
                   vnumeroextcalle,vnumerointcalle,vdepartamento,vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,vmanzana,votros,
                   vandador,vetapa,vlote,vedificio,ventrada,vobservaciones,vuser_insert,vfecha_insert,vind_cofeteltel1,vind_cofeteltel2,vind_cofeteltel3
              FROM bdinteg:"informix".si_direcciones a 
              --LEFT OUTER JOIN si_telefonos_actual tel1 ON (tel1.numcte = a.numcte AND tel1.tipo_tel = 1)
              --LEFT OUTER JOIN si_telefonos_actual tel2 ON (tel2.numcte = a.numcte AND tel2.tipo_tel = 2)
              --LEFT OUTER JOIN si_telefonos_actual tel3 ON (tel3.numcte = a.numcte AND tel3.tipo_tel = 3)
             WHERE a.numcte = pnumcte
               AND a.secuencia >= vlimite_inicia
               AND a.secuencia <= vlimite_final
            ORDER BY a.secuencia

            SELECT nvl(tipo_tel,''), nvl(telefono,'')
              INTO vtipo_telef1, vtelefono1
              FROM bdinteg:"informix".si_telefonos_actual
             WHERE numcte = pnumcte
               AND tipo_tel = 1;
			
            SELECT nvl(tipo_tel,''), nvl(telefono,''), nvl(carrier,'00')
              INTO vtipo_telef2, vtelefono2, vCarrier
              FROM bdinteg:"informix".si_telefonos_actual
             WHERE numcte = pnumcte
               AND tipo_tel = 2;

            SELECT nvl(tipo_tel,''), nvl(telefono,''), nvl(extension,'')
              INTO vtipo_telef3, vtelefono3, vextension
              FROM bdinteg:"informix".si_telefonos_actual
             WHERE numcte = pnumcte
               AND tipo_tel = 3;
            
            --SELECT carrier
            --  INTO vCarrier
            --  FROM bdinteg:"informix".si_telefonos_actual
            -- WHERE numcte = pnumcte
             --  AND tipo_tel = 2;
                                   
            --IF vCarrier is null THEN
            --    LET vCarrier = '00';
            --END IF;

            LET vciclo = vciclo+1;

            IF vciclo <= pnum_direc THEN
                CONTINUE FOREACH;
            END IF

            RETURN vcodret,vnumcte,vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,vciudad,vmunicipio,vcod_postal,vapart_postal,
                   vtipo_telef1,vtelefono1,vtipo_telef2,vtelefono2,vtipo_telef3,vtelefono3,vextension,vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,
                   vnumerociudad,vnumeroextcalle,vnumerointcalle,vdepartamento,vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,
                   vmanzana,votros,vandador,vetapa,vlote,vedificio,ventrada,vobservaciones,vuser_insert,vfecha_insert,vind_cofeteltel1,
                   vind_cofeteltel2,vind_cofeteltel3,vCarrier  WITH RESUME;
        END FOREACH;
    END IF

    IF pconsulta = 2 THEN
        FOREACH
            SELECT a.numcte, a.secuencia, a.tipo_dir, a.calle, a.colonia, a.entre_calles, a.pais, a.estado, a.ciudad, a.municipio, a.cod_postal, a.apart_postal, 
                   --nvl(tel1.tipo_tel,''), nvl(tel1.telefono,''), nvl(tel2.tipo_tel,''), nvl(tel2.telefono,''), nvl(tel3.tipo_tel,''), nvl(tel3.telefono,''), nvl(tel3.extension,''), 
                   a.estado_inegi, a.municipio_inegi, a.localidad_inegi, a.numerociudad, a.numeroextcalle,
                   a.numerointcalle, a.departamento, a.numerocalle, a.numerocolonia, a.puntocardinal, a.unidadhabitac, a.manzana, a.otros, a.andador, a.etapa, a.lote, a.edificio,
                   a.entrada, a.observaciones, a.user_insert, a.fecha_insert, a.ind_cofeteltel1, a.ind_cofeteltel2, a.ind_cofeteltel3
              INTO vnumcte,vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,vciudad,vmunicipio,vcod_postal,vapart_postal,
			       --vtipo_telef1,vtelefono1,vtipo_telef2,vtelefono2,vtipo_telef3,vtelefono3,vextension,
				   vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,vnumerociudad,
                   vnumeroextcalle,vnumerointcalle,vdepartamento,vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,vmanzana,votros,
                   vandador,vetapa,vlote,vedificio,ventrada,vobservaciones,vuser_insert,vfecha_insert,vind_cofeteltel1,vind_cofeteltel2,vind_cofeteltel3
              FROM bdinteg:"informix".si_direcciones a 
              --LEFT OUTER JOIN si_telefonos_actual tel1 ON (tel1.numcte = a.numcte AND tel1.tipo_tel = 1)
              --LEFT OUTER JOIN si_telefonos_actual tel2 ON (tel2.numcte = a.numcte AND tel2.tipo_tel = 2)
              --LEFT OUTER JOIN si_telefonos_actual tel3 ON (tel3.numcte = a.numcte AND tel3.tipo_tel = 3)
             WHERE a.numcte = pnumcte
               AND a.secuencia >= vlimite_inicia
               AND a.secuencia <= vlimite_final
             ORDER BY a.secuencia

            SELECT nvl(tipo_tel,''), nvl(telefono,'')
              INTO vtipo_telef1, vtelefono1
              FROM bdinteg:"informix".si_telefonos_actual
             WHERE numcte = pnumcte
               AND tipo_tel = 1;
			
            SELECT nvl(tipo_tel,''), nvl(telefono,''), nvl(carrier,'00')
              INTO vtipo_telef2, vtelefono2, vCarrier
              FROM bdinteg:"informix".si_telefonos_actual
             WHERE numcte = pnumcte
               AND tipo_tel = 2;

            SELECT nvl(tipo_tel,''), nvl(telefono,''), nvl(extension,'')
              INTO vtipo_telef3, vtelefono3, vextension
              FROM bdinteg:"informix".si_telefonos_actual
             WHERE numcte = pnumcte
               AND tipo_tel = 3;

             
            --SELECT carrier
            --  INTO vCarrier
            --  FROM bdinteg:"informix".si_telefonos_actual
            -- WHERE numcte = pnumcte
            --   AND tipo_tel = 2;
                                   
            --IF vCarrier is null THEN
            --    LET vCarrier = '00';
            --END IF;

            LET vciclo = vciclo+1;

            IF vciclo <= pnum_direc THEN
                CONTINUE FOREACH;
            END IF

            RETURN vcodret,vnumcte,vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,vciudad,vmunicipio,vcod_postal,vapart_postal,
                   vtipo_telef1,vtelefono1,vtipo_telef2,vtelefono2,vtipo_telef3,vtelefono3,vextension,vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,
                   vnumerociudad,vnumeroextcalle,vnumerointcalle,vdepartamento,vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,
                   vmanzana,votros,vandador,vetapa,vlote,vedificio,ventrada,vobservaciones,vuser_insert,vfecha_insert,vind_cofeteltel1,
                   vind_cofeteltel2,vind_cofeteltel3,vCarrier  WITH RESUME;
        END FOREACH;
    END IF

    IF  pconsulta = 3 THEN
        FOREACH
            SELECT a.numcte, a.secuencia, a.tipo_dir, a.calle, a.colonia, a.entre_calles, a.pais, a.estado, a.ciudad, a.municipio, a.cod_postal, a.apart_postal,  
                   a.estado_inegi, a.municipio_inegi, a.localidad_inegi, a.numerociudad, a.numeroextcalle,
                   a.numerointcalle, a.departamento, a.numerocalle, a.numerocolonia, a.puntocardinal, a.unidadhabitac, a.manzana, a.otros, a.andador, a.etapa, a.lote, a.edificio,
                   a.entrada, a.observaciones, a.user_insert, a.fecha_insert, a.ind_cofeteltel1, a.ind_cofeteltel2, a.ind_cofeteltel3
              INTO vnumcte,vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,vciudad,vmunicipio,vcod_postal,vapart_postal,vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,vnumerociudad,
                   vnumeroextcalle,vnumerointcalle,vdepartamento,vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,vmanzana,votros,
                   vandador,vetapa,vlote,vedificio,ventrada,vobservaciones,vuser_insert,vfecha_insert,vind_cofeteltel1,vind_cofeteltel2,vind_cofeteltel3
              FROM bdinteg:"informix".si_direcciones a 
              --LEFT OUTER JOIN si_telefonos_actual tel1 ON (tel1.numcte = a.numcte AND tel1.tipo_tel = 1)
              --LEFT OUTER JOIN si_telefonos_actual tel2 ON (tel2.numcte = a.numcte AND tel2.tipo_tel = 2)
              --LEFT OUTER JOIN si_telefonos_actual tel3 ON (tel3.numcte = a.numcte AND tel3.tipo_tel = 3)
             WHERE a.numcte = pnumcte
               AND a.tipo_dir = ptipo_dir
               AND a.secuencia >= vlimite_inicia
               AND a.secuencia <= vlimite_final
             ORDER BY a.secuencia

            SELECT nvl(tipo_tel,''), nvl(telefono,'')
              INTO vtipo_telef1, vtelefono1
              FROM bdinteg:"informix".si_telefonos_actual
             WHERE numcte = pnumcte
               AND tipo_tel = 1;
			
            SELECT nvl(tipo_tel,''), nvl(telefono,''), nvl(carrier,'00')
              INTO vtipo_telef2, vtelefono2, vCarrier
              FROM bdinteg:"informix".si_telefonos_actual
             WHERE numcte = pnumcte
               AND tipo_tel = 2;

            SELECT nvl(tipo_tel,''), nvl(telefono,''), nvl(extension,'')
              INTO vtipo_telef3, vtelefono3, vextension
              FROM bdinteg:"informix".si_telefonos_actual
             WHERE numcte = pnumcte
               AND tipo_tel = 3;
            
                                   
            --IF vCarrier is null THEN
            --   LET vCarrier = '00';
            --END IF;

            LET vciclo = vciclo+1;

            IF vciclo <= pnum_direc THEN
                CONTINUE FOREACH;
            END IF

            RETURN vcodret,vnumcte,vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,vciudad,vmunicipio,vcod_postal,vapart_postal,
                   vtipo_telef1,vtelefono1,vtipo_telef2,vtelefono2,vtipo_telef3,vtelefono3,vextension,vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,
                   vnumerociudad,vnumeroextcalle,vnumerointcalle,vdepartamento,vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,
                   vmanzana,votros,vandador,vetapa,vlote,vedificio,ventrada,vobservaciones,vuser_insert,vfecha_insert,vind_cofeteltel1,
                   vind_cofeteltel2,vind_cofeteltel3,vCarrier  WITH RESUME;
        END FOREACH;
    END IF

    END

END PROCEDURE

DOCUMENT
"Consulta de direcciones del cliente a la si_direcciones_actual y si_direcciones",
"Autor : Daniela Viridiana Ramirez Perez",
"FECHA : 13/07/2011",
"BD    : bdinteg";

create procedure "informix".consdirec(pempresa char(3), pnumcte char(20), pnum_direc smallint)
returning char(5),int,char(1),char(40),char(60),char(40),
          char(3),char(2),char(3),char(5),char(5),char(11),char(1),
          char(13),char(1),char(13),char(1),char(13),char(5),char(2),char(3),
          char(4),smallint,char(10),char(10),char(6),int,int,char(1),
          char(1),smallint,smallint,smallint,smallint,smallint,smallint,
          smallint,char(80);

    define vcodret char(5);
    define vciclo smallint;
    define vsqlerr integer;

    define vsecuencia int ;
    define vtipo_dir char(1);
    define vcalle char(40);
    define vcolonia char(60);
    define ventre_calles char(40);
    define vpais char(3);
    define vestado char(2);
    define vciudad char(3);
    define vmunicipio char(5);
    define vcod_postal char(5);
    define vapart_postal char(11);
    define vtipo_telef1  char(1);
    define vtelefono1 char(13);
    define vtipo_telef2  char(1);
    define vtelefono2  char(13);
    define vtipo_telef3  char(1);
    define vtelefono3  char(13);
    define vextension char(5);
    define vestado_inegi  char(2);
    define vmunicipio_inegi char(3);
    define vlocalidad_inegi  char(4);
    define vnumerociudad smallint ;
    define vnumeroextcalle  char(10);
    define vnumerointcalle  char(10);
    define vdepartamento  char(6);
    define vnumerocalle int ;
    define vnumerocolonia int ;
    define vpuntocardinal  char(1);
    define vunidadhabitac  char(1);
    define vmanzana smallint ;
    define votros  smallint ;
    define vandador smallint ;
    define vetapa smallint ;
    define vlote  smallint ;
    define vedificio  smallint ;
    define ventrada  smallint ;
    define vobservaciones char(80);
	define vsecuenciamax int ;
	define vsecuenciamin int ;

    let vciclo = 0;
    let vcodret = "000";
    let  vsqlerr = 0;

    let vsecuencia = 0;
	let vsecuenciamax = 0;
	let vsecuenciamin = 0;
    let vtipo_dir = "";
    let vcalle = "";
    let vcolonia = "";
    let ventre_calles = "";
    let vpais = "";
    let vestado = "";
    let vciudad = "";
    let vmunicipio = "";
    let vcod_postal = "";
    let vapart_postal = "";
    let vtipo_telef1 = "";
    let vtelefono1 = "";
    let vtipo_telef2 = "";
    let vtelefono2 = "";
    let vtipo_telef3 = "";
    let vtelefono3 = "";
    let vextension = "";
    let vestado_inegi = "";
    let vmunicipio_inegi = "";
    let vlocalidad_inegi = "";
    let vnumerociudad = 0;
    let vnumeroextcalle = "";
    let vnumerointcalle = "";
    let vdepartamento = "";
    let vnumerocalle = 0;
    let vnumerocolonia = 0;
    let vpuntocardinal = "";
    let vunidadhabitac = "";
    let vmanzana = 0;
    let votros  = 0;
    let vandador  = 0;
    let vetapa = 0;
    let vlote = 0;
    let vedificio  = 0;
    let ventrada = 0;
    let vobservaciones = "";

    begin

    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret,vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,
            vciudad,vmunicipio,vcod_postal,vapart_postal,vtipo_telef1,vtelefono1,
            vtipo_telef2,vtelefono2,vtipo_telef3,vtelefono3,vextension,vestado_inegi,vmunicipio_inegi,
            vlocalidad_inegi,vnumerociudad,vnumeroextcalle,vnumerointcalle,vdepartamento,
            vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,vmanzana,
            votros,vandador,vetapa,vlote,vedificio,ventrada,vobservaciones;
        end if;
    end exception;

	-- Bloque modificacion

		set isolation to dirty read;

		select max(secuencia) 
		INTO  vsecuenciamax
		from "informix".si_direcciones 		
		where numcte = pnumcte;

		if vsecuenciamax > 20 THEN

			let vsecuenciamin = vsecuenciamax - 20;

		end if;
	-- Termina modificacion

    foreach
        SELECT dir.secuencia,dir.tipo_dir,dir.calle,dir.colonia,dir.entre_calles,dir.pais,dir.estado,dir.ciudad,dir.municipio,dir.cod_postal,dir.apart_postal,
                dir.estado_inegi,dir.municipio_inegi,dir.localidad_inegi,dir.numerociudad,dir.numeroextcalle,dir.numerointcalle,dir.departamento,
                dir.numerocalle,dir.numerocolonia,dir.puntocardinal,dir.unidadhabitac,dir.manzana,dir.otros,dir.andador,dir.etapa,dir.lote,dir.edificio,dir.entrada,dir.observaciones
          INTO  vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,vciudad,vmunicipio,vcod_postal,vapart_postal,
                vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,vnumerociudad,vnumeroextcalle,vnumerointcalle,vdepartamento,
                vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,vmanzana,votros,vandador,vetapa,vlote,vedificio,ventrada,vobservaciones
          FROM "informix".si_direcciones dir
          --LEFT OUTER JOIN "informix".si_telefonos_actual tel1 ON (tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
          --LEFT OUTER JOIN "informix".si_telefonos_actual tel2 ON (tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
          --LEFT OUTER JOIN "informix".si_telefonos_actual tel3 ON (tel3.numcte = dir.numcte AND tel3.tipo_tel = 3)
         WHERE dir.numcte = pnumcte
		 and dir.secuencia > vsecuenciamin
		 and dir.secuencia <= vsecuenciamax
         ORDER BY dir.secuencia

         select nvl(tipo_tel,''),nvl(telefono,'')
           into vtipo_telef1,vtelefono1
           from "informix".si_telefonos_actual 
          WHERE numcte = pnumcte
            and tipo_tel = 1;

         select nvl(tipo_tel,''),nvl(trim(telefono),'')
           into vtipo_telef2,vtelefono2
           from "informix".si_telefonos_actual 
          WHERE numcte = pnumcte
            and tipo_tel = 2;

         select nvl(tipo_tel,''),nvl(telefono,''),nvl(extension,'')
           into vtipo_telef3,vtelefono3,vextension
           from "informix".si_telefonos_actual
          WHERE numcte = pnumcte
            and tipo_tel = 3;

        let vciclo = vciclo+1;

        if vciclo <= pnum_direc then
            continue foreach;
        end if

        IF LENGTH(vtelefono2) = 13 THEN
            LET vtelefono2 = SUBSTRING(vtelefono2 FROM 4 FOR 13);
        ELIF LENGTH(vtelefono2) = 12 THEN
            LET vtelefono2 = SUBSTRING(vtelefono2 FROM 3 FOR 12);
        ELIF LENGTH(vtelefono2) = 11 THEN
            LET vtelefono2 = SUBSTRING(vtelefono2 FROM 2 FOR 11);
        END IF;

        return  vcodret,vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,
                vciudad,vmunicipio,vcod_postal,vapart_postal,vtipo_telef1, NVL(vtelefono1,''),
                NVL(vtipo_telef2,''), NVL(vtelefono2,''), NVL(vtipo_telef3,''), NVL(vtelefono3,''), 
                NVL(vextension,''), vestado_inegi,vmunicipio_inegi,
                vlocalidad_inegi,vnumerociudad,vnumeroextcalle,vnumerointcalle,vdepartamento,
                vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,vmanzana,
                votros,vandador,vetapa,vlote,vedificio,ventrada,vobservaciones  with resume;
    end foreach;
    
    end
    
end procedure

DOCUMENT
"Consulta de direcciones del cliente",
"Autor : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Daniel Zambada",
"FECHA : 30/octubre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_cuentadoctos_soc(pNumeroCliente CHAR(20),pTipo_cte SMALLINT)
RETURNING CHAR(5),INT,CHAR(100);
--DECLARACION DE VARIABLES
DEFINE vc_CodRet    CHAR(5);
DEFINE vi_SqlErr    INTEGER;
DEFINE v_contador        smallint;
DEFINE v_registro    INTEGER;
DEFINE vc_CodDocto  CHAR(4);
DEFINE vs_Secuencia SMALLINT;
DEFINE v_nomarch    CHAR(20);
DEFINE v_nomarch2    CHAR(20);
DEFINE v_ruta       CHAR(50);
DEFINE isam_err  INT;
DEFINE v_descripcion  CHAR(100);
DEFINE vc_aniomesI       CHAR(6);
DEFINE vc_aniomesF       CHAR(6);
DEFINE cFecha			CHAR(10);
--INICIALIZACION DE VARIABLES
LET vc_CodDocto = "";
LET vs_Secuencia = 0;
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET v_registro=0;
LET v_contador=0;
LET v_nomarch='img';
LET v_nomarch2="";
LET v_ruta="";
LET isam_err="0";
LET v_descripcion="PROCESO EJECUTADO CORRECTAMENTE";
LET vc_aniomesI="";
LET vc_aniomesF="";
LET cFecha="";

  --SET DEBUG FILE TO "/tmp/mfinis/sp_cuentadoctos_soc.out";
  --TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

  ON EXCEPTION SET vi_SqlErr
    IF vi_SqlErr <> 0 THEN
        let v_descripcion="ERROR EN EL PROCESO";
        LET vc_CodRet = vi_SqlErr;
        RETURN vc_CodRet,isam_err,v_descripcion;
    END IF;
  END EXCEPTION;

    IF pNumeroCliente IS NULL OR pNumeroCliente = "" THEN --PARAMETROS INVALIDOS
        LET vc_CodRet = "99999";
        RETURN vc_CodRet,isam_err,v_descripcion;
    END IF;

	SELECT 
	{+AVOID_FULL ("informix".si_fechas)}
	TO_CHAR(fecha_hoy,'%m/%d/%Y') INTO cFecha from si_fechas;
	
	LET vc_aniomesI=SUBSTR(cFecha,7,4)||'01';
	LET vc_aniomesF=SUBSTR(cFecha,7,4)||'12';



    IF EXISTS (SELECT numcte FROM bdinteg:si_cliente WHERE (numcte = pNumeroCliente AND tpo_persona = "02")) THEN --CLIENTE PERSONA MORAL
        LET vc_CodRet = "00100"; 
        RETURN vc_CodRet,isam_err,v_descripcion;
    END IF;
    
    IF pTipo_cte=2 THEN
        IF EXISTS (SELECT num_cte FROM bdilide:sl_retlide WHERE num_cte = pNumeroCliente AND aniomes BETWEEN vc_aniomesI AND vc_aniomesF ) THEN --CLIENTE CON ADEUDO EN IDE, IMPOSIBLE REALIZAR TRASPASO DE CUENTAS
           LET vc_CodRet = "00200"; 
           RETURN vc_CodRet,isam_err,v_descripcion;
       END IF;
    END IF;

    IF pTipo_cte=2 THEN
        IF EXISTS (SELECT numcte FROM bdinteg:si_bpiusuarios WHERE numcte= pNumeroCliente AND servicio=2 AND empresa='001' AND id_status<>99) THEN --CLIENTE CON BANCA ELECTRONICA AVANZADA
            LET vc_CodRet = "00300"; 
            RETURN vc_CodRet,isam_err,v_descripcion;
        END IF;
    END IF;

    IF EXISTS (SELECT numcte FROM bdinteg:si_cliente WHERE numcte= pNumeroCliente AND status_cte="FU") THEN --CLIENTE FUSIONADO
        LET vc_CodRet = "00400";
        RETURN vc_CodRet,isam_err,v_descripcion; 
    END IF;

    SELECT TRIM(valor) INTO v_ruta FROM bdinteg:si_param WHERE cod_param=122;

    FOREACH
        SELECT cod_docto,secuencia
        INTO vc_CodDocto, vs_Secuencia
        FROM bdidigital@coppelimg_tcp:dg_expediente
        WHERE cliente = pNumeroCliente AND empresa='001'

        SELECT nvl(count(*),0) INTO v_registro 
        --FROM bdidigital@coppelimg_tcp:dg_expediente_img
		FROM bdidigital@coppelimg_tcp:dg_expediente_img1
        WHERE cliente = pNumeroCliente 
        AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
		
		IF v_registro=0 THEN
			SELECT nvl(count(*),0) INTO v_registro 
			--FROM bdidigital@coppelimg20_tcp:dg_expediente_img
			FROM bdidigital@coppelimghis_tcp:dg_expediente_img
			WHERE cliente = pNumeroCliente 
			AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
			
			IF v_registro=0 THEN
				SELECT nvl(count(*),0) INTO v_registro 				
				--FROM bdidigital@coppelimg20_tcp:dg_expediente_img_his
				FROM bdidigital@coppelimghis_tcp:dg_expediente_img_his
				WHERE cliente = pNumeroCliente 
				AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
			END IF;
		END IF;
        
        IF v_registro=0 THEN
            INSERT INTO bdidigital@coppelimg_tcp:dg_expediente_fus
            SELECT * FROM bdidigital@coppelimg_tcp:dg_expediente WHERE cliente = pNumeroCliente AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
            DELETE FROM bdidigital@coppelimg_tcp:dg_expediente WHERE cliente = pNumeroCliente AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
        END IF
    END FOREACH;


    FOREACH
        SELECT cod_docto,secuencia
        INTO vc_CodDocto, vs_Secuencia
        --FROM bdidigital@coppelimg_tcp:dg_expediente_img
		FROM bdidigital@coppelimg_tcp:dg_expediente_img1
        WHERE cliente = pNumeroCliente AND empresa='001'

        SELECT nvl(count(*),0) INTO v_registro 
        FROM bdidigital@coppelimg_tcp:dg_expediente
        WHERE cliente = pNumeroCliente 
        AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
        
        IF v_registro=0 THEN
            LET v_nomarch2=trim(v_nomarch)||TRIM(pNumeroCliente)||'.unl';
            CALL bdidigital@coppelimg_tcp:sp_resimgapl(pNumeroCliente,v_nomarch2,v_ruta,vc_CodDocto,vs_Secuencia) RETURNING vc_CodRet,isam_err,v_descripcion;
            CALL bdidigital@coppelimg_tcp:sp_carga_img(pNumeroCliente,v_nomarch2,v_ruta) RETURNING vc_CodRet,isam_err,v_descripcion;
			IF vc_CodRet="00000" THEN
				--DELETE FROM bdidigital@coppelimg_tcp:dg_expediente_img WHERE cliente = pNumeroCliente AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
				DELETE FROM bdidigital@coppelimg_tcp:dg_expediente_img1 WHERE cliente = pNumeroCliente AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
			END IF;
        END IF
    END FOREACH;

    FOREACH
        SELECT cod_docto,secuencia
        INTO vc_CodDocto, vs_Secuencia
		--FROM bdidigital@coppelimg20_tcp:dg_expediente_img
		FROM bdidigital@coppelimghis_tcp:dg_expediente_img
        WHERE cliente = pNumeroCliente AND empresa='001'

        SELECT nvl(count(*),0) INTO v_registro 
        FROM bdidigital@coppelimg_tcp:dg_expediente
        WHERE cliente = pNumeroCliente 
        AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
        
        IF v_registro=0 THEN
            LET v_nomarch2=trim(v_nomarch)||TRIM(pNumeroCliente)||'.unl';
            --CALL bdidigital@coppelimg20_tcp:sp_resimgapl3(pNumeroCliente,v_nomarch2,v_ruta,vc_CodDocto,vs_Secuencia) RETURNING vc_CodRet,isam_err,v_descripcion;
            CALL bdidigital@coppelimghis_tcp:sp_resimgapl3(pNumeroCliente,v_nomarch2,v_ruta,vc_CodDocto,vs_Secuencia) RETURNING vc_CodRet,isam_err,v_descripcion;
            CALL bdidigital@coppelimg_tcp:sp_carga_img3(pNumeroCliente,v_nomarch2,v_ruta) RETURNING vc_CodRet,isam_err,v_descripcion;
			IF vc_CodRet="00000" THEN
				--DELETE FROM bdidigital@coppelimg20_tcp:dg_expediente_img WHERE cliente = pNumeroCliente AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
				DELETE FROM bdidigital@coppelimghis_tcp:dg_expediente_img WHERE cliente = pNumeroCliente AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
			END IF;
        END IF
    END FOREACH;	

    FOREACH
        SELECT cod_docto,secuencia
        INTO vc_CodDocto, vs_Secuencia
        --FROM bdidigital@coppelimg_tcp:dg_expediente_img_his
		--FROM bdidigital@coppelimg20_tcp:dg_expediente_img_his
		FROM bdidigital@coppelimghis_tcp:dg_expediente_img_his
        WHERE cliente = pNumeroCliente AND empresa='001'

        SELECT nvl(count(*),0) INTO v_registro 
        FROM bdidigital@coppelimg_tcp:dg_expediente
        WHERE cliente = pNumeroCliente 
        AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
        
        IF v_registro=0 THEN
            LET v_nomarch2=trim(v_nomarch)||TRIM(pNumeroCliente)||'.unl';
            --CALL bdidigital@coppelimg20_tcp:sp_resimgapl2(pNumeroCliente,v_nomarch2,v_ruta,vc_CodDocto,vs_Secuencia) RETURNING vc_CodRet,isam_err,v_descripcion;
            CALL bdidigital@coppelimghis_tcp:sp_resimgapl2(pNumeroCliente,v_nomarch2,v_ruta,vc_CodDocto,vs_Secuencia) RETURNING vc_CodRet,isam_err,v_descripcion;
            CALL bdidigital@coppelimg_tcp:sp_carga_img2(pNumeroCliente,v_nomarch2,v_ruta) RETURNING vc_CodRet,isam_err,v_descripcion;
			IF vc_CodRet="00000" THEN
				--DELETE FROM bdidigital@coppelimg_tcp:dg_expediente_img_his WHERE cliente = pNumeroCliente AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
				--DELETE FROM bdidigital@coppelimg20_tcp:dg_expediente_img_his WHERE cliente = pNumeroCliente AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
				DELETE FROM bdidigital@coppelimghis_tcp:dg_expediente_img_his WHERE cliente = pNumeroCliente AND cod_docto=vc_CodDocto AND secuencia=vs_Secuencia AND empresa='001';
			END IF;
        END IF
    END FOREACH;

    RETURN vc_CodRet,isam_err,v_descripcion;
END;
END PROCEDURE
DOCUMENT
'----------------------------------------------',
'FECHA: 10/11/2015',
'MODIFICACION: Se modifica para especificar instancia de imagenes correcta de acuerdo al tipo de imagen (historica o actual)',
'SUSTENTO: RQI 64 127 Separacion de imagenes',
'---------------------',
'SUSTENTA: INC 64 027',
'FECHA: 25/11/2015',
'MODIFICACION: Se modifica para especificar correctamente la instancia donde reside el SP sp_carga_img2', 
'---------------------',
'SUSTENTA: RQI 64 132',
'FECHA: 07/12/2015',
'MODIFICACION: Se modifica para contemplar la depuracion de inconsistencias en la tabla dg_expediente_img de la instancia coppelimghis_tcp',
'---------------------',
'AUTOR: L. Montserrat León Amador',
'FECHA: 07/05/2020',
'MODIFICACION: Se realiza clonación de spl para cambiar instancia coppelimghis_tcp por coppelimg20_tcp',
'---------------------',
'AUTOR: Sandra Cano',
'FECHA: 18/09/2020',
'MODIFICACION: Se modifica procedimiento almacenado para eliminar validación por adeudo IDE, de modo que si alguno o ambos clientes cuentan con un adeudo IDE, la aplicación permita continuar con el proceso de fusión de clientes',
'---------------------',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 13/05/2021',
'MODIFICACION: Se modifica procedimiento almacenado para restaurar la validación por adeudo IDE y el formato de recuperacion de fecha.';

CREATE PROCEDURE "informix".sp_altafideicomiso_esp( pEmpresa CHAR(3) ) 
RETURNING CHAR(5), CHAR(20), CHAR(20), CHAR(18);
    
    DEFINE intSqlErr    INTEGER;
    DEFINE intIsamErr   INTEGER;
    DEFINE chrDescErr   CHAR(80);
    DEFINE chrCodRet1   CHAR(5);
    DEFINE chrCodRet2   CHAR(5);
    DEFINE chrCodRet3   CHAR(80);
    
    DEFINE sLong_cte    SMALLINT;
    DEFINE iSignumcte 	INTEGER;
    DEFINE cNumcte 		CHAR(20);
    DEFINE sDiferencia	SMALLINT;
    DEFINE sI 			SMALLINT;
    
    DEFINE vlongcta     SMALLINT;
    DEFINE vsignumcta   INTEGER;
    DEFINE cCuenta      CHAR(20);
    DEFINE vDiferencia  SMALLINT;
    DEFINE i            SMALLINT;
    DEFINE vdigverif    CHAR(1);
    DEFINE vexiste      CHAR(1);
    DEFINE vctaclabe    CHAR(18);

    LET intSqlErr  = 0;
    LET intIsamErr = 0;
    LET chrDescErr = '';
    LET chrCodRet1 = '000';
    LET chrCodRet2 = '';
    LET chrCodRet3 = '';
    
    LET sLong_cte   = 0;
    LET iSignumcte  = 0;
    LET cNumcte     = '';
    LET sDiferencia = 0;
    
    LET vlongcta    = 0;
    LET vsignumcta  = 0;
    LET cCuenta     = '';
    LET vDiferencia = 0;
    LET i           = 0;
    LET vdigverif   = '';
    LET vexiste     = '';
    LET vctaclabe   = '';

    BEGIN
    
    ON EXCEPTION SET intSqlErr, intIsamErr, chrDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_altafideicomiso_esp.err";
        TRACE ON;
        IF intSqlErr <> 0 THEN
            LET chrCodRet1 = intSqlErr;
            LET chrCodRet2 = intIsamErr;
            LET chrCodRet3 = chrDescErr;
            RETURN chrCodRet1, cNumcte, cCuenta, vctaclabe;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_altafideicomiso_esp.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT valor
      INTO sLong_cte
      FROM bdinteg:si_param
     WHERE cod_param = 7
       AND empresa = pEmpresa;
       
    SELECT valor
      INTO iSignumcte
      FROM bdinteg:si_param
     WHERE empresa = pEmpresa
       AND cod_param = 6;

    LET cNumcte = iSignumcte;
    LET iSignumcte = iSignumcte + 1;

    UPDATE bdinteg:si_param
       SET valor = iSignumcte
     WHERE empresa = pEmpresa
       AND cod_param = 6;

    LET sDiferencia = sLong_cte - LENGTH(cNumcte);

    IF sDiferencia > 0 THEN
        FOR sI = 1 TO sDiferencia
            LET cNumcte = "0" || cNumcte;
        END FOR;
    END IF;
    
    -- // ALTA DEL CLIENTE
    insert into bdinteg:si_cliente values(
        pEmpresa,               --- empresa
        cNumcte,                --- numcte           
        'AL',                   --- status_cte       
        '0004',                 --- sucursal         
        'informix',             --- ejecutivo        
        '02',                   --- tpo_persona      
        '1',                    --- tipo_cliente     
        '',                     --- apell_paterno
        '',                     --- apell_materno
        '',                     --- nombre1
        '',                     --- nombre2
        'BANCOPPEL SA FIDEICOMISO F/001', --- razon_social
        'FID210519000',         --- rfc
        '31',                   --- sector           
        '000',                  --- segmento         
        '000',                  --- actividad_princ  
        '000',                  --- grupo            
        '000',                  --- subgrupo         
        '1',                    --- residencia       
        today,                  --- fecha_alta       
        '',                     --- apell_casada
        '',                     --- distrito
        '',                     --- numcte_ref
        '',                     --- string1
        '',                     --- string2
        null,                   --- numeric1
        null,                   --- numeric2
        null,                   --- money1
        '',                     --- date1
        '',                     --- puesto_ppes
        '',                     --- familiar_ppes
        '',                     --- actividad_esp
        '',                     --- ejecut_autoriza
        '',                     --- user_insert      
        today,                  --- fecha_insert     
        '',                     --- rfc_alterno
        '0',                    --- tpo_biometria    
        '',                     --- cliente_pros
        null                    --- envio_movtos 
    );
    
    -- // ALTA DE LA PERSONA MORAL
    insert into bdinteg:si_ctepm values(
        pEmpresa,                           --- empresa             
        cNumcte,                            --- numcte              
        '',                                 --- nombre_comercial
        '',                                 --- nombre_titular
        'Bancario/Fiduciario ',             --- giro                
        '',                                 --- fecha_inscrip       
        '',                                 --- fecha_constitct     
        '',                                 --- regpub_comer
        '',                                 --- no_inscripcion
        '',                                 --- oficina
        '',                                 --- num_ofi
        '',                                 --- tomo
        '',                                 --- protocolo
        '',                                 --- num_trimestre
        '',                                 --- fecha_trimestre
        '0004',                             --- sucursal           
        'informix',                         --- operador            
        today,                              --- fecha_alta          
        1,                                  --- nacionalidad        
        'F/001',                            --- nombre_corto        
        'MARIO ISRAEL GARCIA VALDOS',       --- nombre_contacto     
        '5552780000',                       --- telefono_contacto   
        '',                                 --- sufijo              
        '',                                 --- actividadsocial     
        '',                                 --- pagina_internet     
        '',                                 --- user_insert
        today,                              --- fecha_insert        
        '',                                 --- escritura_constit+  
        '',                                 --- nombre_notarioct    
        '',                                 --- numero_notarioct    
        '',                                 --- ciudad_notarioct    
        '',                                 --- numero_foliomerca+
        '',                                 --- ciudad_foliomerca+
        '',                                 --- escritura_poderes   
        '',                                 --- nombre_notariopd    
        '',                                 --- numero_notariopd    
        '',                                 --- ciudad_notariopd    
        '',                                 --- fecha_inscrippd     
        '',                                 --- fecha_escritpd
        '',                                 --- numero_foliomerca+
        '',                                 --- ciudad_foliomerca+
        '',                                 --- nombre_sociedad
        '',                                 --- sat_fea
        'mgarciav@bancoppel.com',           --- emailpm             
        '',                                 --- tipo_poder
        '',                                 --- tipo_admon
        '',                                 --- tipo_org
        ''                                  --- doc_constitucion
    );
    
    -- // ALTA DE LA DIRECCION DEL CLIENTE
    insert into bdinteg:si_direcciones values(
        cNumcte,                            --- numcte           
        1,                                  --- secuencia        
        '1',                                --- tipo_dir         
        'INSURGENTES SUR',                  --- calle           
        'ESCANDON',                         --- colonia       
        'AV. NUEVO LEON - INGENIEROS',      --- entre_calles
        '001',                              --- pais             
        '09',                               --- estado           
        '019',                              --- ciudad           
        '019',                              --- municipio        
        '11800',                            --- cod_postal      
        '',                                 --- apart_postal
        '',                                 --- estado_inegi
        '',                                 --- municipio_inegi
        '',                                 --- localidad_inegi
        null,                               --- numerociudad     
        '553',                              --- numeroextcalle  
        'PISO 3',                           --- numerointcalle   
        '',                                 --- departamento
        null,                               --- numerocalle     
        null,                               --- numerocolonia    
        '',                                 --- puntocardinal
        '',                                 --- unidadhabitac    
        null,                               --- manzana
        null,                               --- otros
        null,                               --- andador
        null,                               --- etapa
        null,                               --- lote
        null,                               --- edificio
        null,                               --- entrada
        '',                                 --- observaciones    
        'informix',                         --- user_insert      
        today,                              --- fecha_insert     
        'F',                                --- ind_cofeteltel1  
        'F',                                --- ind_cofeteltel2  
        'F'                                 --- ind_cofeteltel3  
    );
    
    -- // ALTA DE LOS TELEFONOS DEL CLIENTE
    insert into bdinteg:si_telefonos values(
        pEmpresa,               --- empresa          
        cNumcte,                --- numcte           
        '5552780000',           --- telefono         
        1,                      --- tipo_tel         
        'A',                    --- status_tel       
        1,                      --- secuencia        
        '550105',               --- extension
        0,                      --- carrier          
        7,                      --- canal            
        0,                      --- contacto         
        'V',                    --- cofetel          
        current,                --- fecha_hora       
        '90090585',             --- user_insert      
        '0',                    --- movil_fijo       
        '',                     --- status_stel
        'F',                    --- verificado       
        '',                     --- marcatel
        '',                     --- fecha_actualiza
        '',                     --- tel_confirmado
        ''                      --- fech_confirmado
    );
    
    -- // ALTA DE LA CUENTA
    SELECT valor 
      INTO vlongcta
	  FROM bdicheq:sc_param
	 WHERE empresa = pEmpresa 
       AND codparam = "longcta";
    
    SELECT valor
      INTO vsignumcta
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'signumcta2';
       
    LET cCuenta = vsignumcta;
    LET vsignumcta = vsignumcta + 1;
    
    UPDATE bdicheq:sc_param
       SET valor = vsignumcta
     WHERE empresa = pEmpresa
       AND codparam = 'signumcta2';
       
    LET vDiferencia = vlongcta - LENGTH(cCuenta) - 3;
    
    IF vDiferencia > 0 THEN
        FOR i = 1 TO vDiferencia
            LET cCuenta = "0" || cCuenta; 
        END FOR;
    END IF;
    
    LET cCuenta = "12" || TRIM(cCuenta);
    
    CALL bdicheq:digver11(cCuenta)
    RETURNING chrCodRet1, vdigverif;
    
    LET cCuenta = TRIM(cCuenta)||vdigverif;
    
    IF length(cCuenta) = vlongcta AND bdinteg:val_num(cCuenta) THEN
        SELECT 1 
          INTO vexiste
		  FROM bdicheq:sc_maechq 
         WHERE empresa = pEmpresa 
           AND cuenta = cCuenta;
           
        IF vexiste IS NOT NULL THEN
            LET chrCodRet1 = "405";
            RETURN chrCodRet1, cNumcte, cCuenta, vctaclabe;
        END IF;
        
        CALL bdicheq:ctaclabe(pEmpresa, cCuenta, '0002')
        RETURNING chrCodRet1, vctaclabe;
        
        IF chrCodRet1 <> "000" THEN
            LET chrCodRet1 = "170";
            RETURN chrCodRet1, cNumcte, cCuenta, vctaclabe;
        END IF;
        
        insert into bdicheq:sc_maechq values(
            pEmpresa,               --- empresa
            cCuenta,                --- cuenta              
            '0002',                 --- sucursal            
            '001',                  --- plaza               
            '1200',                 --- producto            
            cNumcte,                --- num_cte             
            '1',                    --- status_cta          
            '',                     --- motivo
            0,                      --- ult_chq             
            'N',                    --- colateral           
            '',                     --- fec_ult_mov         
            '',                     --- fec_cancelac
            0.00,                   --- lim_chq_sbc   
            0.00,                   --- imp_chq_sbc     
            '',                     --- fech_alta_sbc
            '',                     --- fech_venc_sbc
            0.00,                   --- lim_chq_rem     
            0.00,                   --- imp_chq_rem
            '',                     --- fech_alta_rem
            '',                     --- fech_venc_rem
            0.00,                   --- lim_sbg_ccc      
            0.00,                   --- imp_sbg_ccc     
            '0',                    --- tipo_linea          
            '',                     --- fec_alta_ccc
            '',                     --- fech_venc_ccc
            0.00,                   --- imp_int_ccc       
            0.00,                   --- sdo_retenido     
            0,                      --- chq_exp_mes         
            0,                      --- chq_dev             
            0.00,                   --- monto_dev         
            0,                      --- chq_dev_obco        
            0.00,                   --- sdo_cong         
            0,                      --- num_cgos_mes        
            0.00,                   --- imp_cgos_mes     
            0,                      --- num_abonos_mes      
            0.00,                   --- imp_abonos_mes  
            0.00,                   --- sdo_actual       
            0.00,                   --- sdo_dia_ant      
            '1',                    --- marca_ret           
            1,                      --- direcc_envio        
            0.00,                   --- com_pendiente      
            0.00,                   --- imp_chq_sbg       
            0.00,                   --- imp_int_sbg       
            ' ',                    --- fecha_proceso       
            '',                     --- cuenta_rel
            0.00,                   --- saldo_sbc         
            '',                     --- fecultdep
            '',                     --- fecultret
            '',                     --- ultpagocap          
            '',                     --- ultpagoint          
            0,                      --- plazo               
            'S',                    --- cobraisr            
            '',                     --- proced_aperturacta  
            '',                     --- proced_mantenercta  
            '',                     --- monto_mensual       
            '',                     --- depositos_cantidad  
            '',                     --- depositos_monto     
            '',                     --- retiros_cantidad    
            '',                     --- retiros_monto       
            vctaclabe               --- cuenta_clabe        
        );
        
        insert into bdicheq:sc_maenoc values(
            pEmpresa,           --- empresa           
            cCuenta,            --- cuenta       
            '00',               --- num_cot           
            '1',                --- clase_cta         
            '1',                --- reg_firmas        
            '001',              --- tipo_bca          
            'informix',         --- ejecutivo         
            '0',                --- envio_direcc      
            0.000000,           --- porc_sdoprom_sbc  
            0.000000,           --- porc_sdoprom_rem  
            '',                 --- tasa_int_ccc
            0.000000,           --- sobretasa_ccc     
            '',                 --- cta_en_legal
            '',                 --- fec_tras_legal
            0,                  --- dias_ccc          
            0.00,               --- acum_ccc       
            0,                  --- dia_sdo_pos       
            0.00,               --- acum_sdo_pos    
            0.00,               --- sdo_prom_mesant 
            0.00,               --- acum_sbc       
            0.00,               --- acum_rem       
            0.00,               --- sdo_mes_ant    
            '',                 --- adicionado        
            today,              --- fecha_alta        
            '',                 --- modificado
            '',                 --- fecha_mod
            0.00,               --- int_acum       
            0.00,               --- isr_acum       
            'M',                --- capitalizacion    
            '',                 --- paga_interes
            0.00,               --- ret_mes_ant     
            0.00,               --- cong_mes_ant    
            0,                  --- dias_acum_int     
            0.00                --- acum_sdo_int  
        );
        
        /* ##########################################
        insert into bdicheq:sc_firmantes values(
            pEmpresa,           --- empresa      
            cCuenta,            --- cuenta       
            1,                  --- secuencia    
            cNumcte,            --- numcte       
            'CRUZ ALMADA',      --- apellidos   
            'DAVID',            --- nombre     
            '1',                --- reg_firma    
            'A',                --- tipo_firma   
            'A',                --- combinacion  
            ''                  --- parentesco
        );
        ########################################## */
    END IF;    
        
    RETURN chrCodRet1, cNumcte, cCuenta, vctaclabe;
    
    END;
    
END PROCEDURE;