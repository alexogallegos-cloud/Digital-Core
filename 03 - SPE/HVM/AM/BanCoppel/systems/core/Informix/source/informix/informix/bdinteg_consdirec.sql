CREATE PROCEDURE "informix".consdirec(pnumcte CHAR(20), pconsulta INTEGER, ptipo_dir INTEGER, pnum_direc SMALLINT)
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
	-- ModificaciÃ³n --
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
	-- ModificaciÃ³n --
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
                   NVL(vtipo_telef1,''), NVL(vtelefono1,''), NVL(vtipo_telef2,''), NVL(vtelefono2,''), NVL(vtipo_telef3,''), NVL(vtelefono3,''), NVL(vextension,''),
                   vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,
                   vnumerociudad,vnumeroextcalle,vnumerointcalle,vdepartamento,vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,
                   vmanzana,votros,vandador,vetapa,vlote,vedificio,ventrada,vobservaciones,vuser_insert,vfecha_insert,vind_cofeteltel1,
                   vind_cofeteltel2,vind_cofeteltel3,NVL(vCarrier,'00')  WITH RESUME;
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
                   NVL(vtipo_telef1,''), NVL(vtelefono1,''), NVL(vtipo_telef2,''), NVL(vtelefono2,''), NVL(vtipo_telef3,''), NVL(vtelefono3,''), NVL(vextension,''),
                   vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,
                   vnumerociudad,vnumeroextcalle,vnumerointcalle,vdepartamento,vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,
                   vmanzana,votros,vandador,vetapa,vlote,vedificio,ventrada,vobservaciones,vuser_insert,vfecha_insert,vind_cofeteltel1,
                   vind_cofeteltel2,vind_cofeteltel3,NVL(vCarrier,'00')  WITH RESUME;
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
                   NVL(vtipo_telef1,''), NVL(vtelefono1,''), NVL(vtipo_telef2,''), NVL(vtelefono2,''), NVL(vtipo_telef3,''), NVL(vtelefono3,''), NVL(vextension,''),
                   vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,
                   vnumerociudad,vnumeroextcalle,vnumerointcalle,vdepartamento,vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,
                   vmanzana,votros,vandador,vetapa,vlote,vedificio,ventrada,vobservaciones,vuser_insert,vfecha_insert,vind_cofeteltel1,
                   vind_cofeteltel2,vind_cofeteltel3,NVL(vCarrier,'00')  WITH RESUME;
        END FOREACH;
    END IF

    END

END PROCEDURE

DOCUMENT
"Consulta de direcciones del cliente a la si_direcciones_actual y si_direcciones",
"Autor : Daniela Viridiana Ramirez Perez",
"FECHA : 13/07/2011",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_act_folio_procesado_solicitudes_movil() RETURNING CHAR(5) AS cod_retorno;



--DEFINICION DE VARIABLES
DEFINE vcodRet 		    VARCHAR(6); 	-- CODIGO DE RETORNO
DEFINE iSqlErr      	integer;
DEFINE cMensaje		    VARCHAR(100);
DEFINE nContador        INT;
DEFINE nfecha			DATE;


--INICIALIZACION DE VARIABLES
LET vcodRet 			= '00000';
LET iSqlErr             = 0;
LET cMensaje		    = 'ERROR EN PASO: ';
LET nContador       	= 0;
LET nfecha				= '';


	
BEGIN 
			ON EXCEPTION SET iSqlErr
						IF iSqlErr <> 0 THEN
							LET vcodRet = iSqlErr;
						END IF;
			END EXCEPTION;
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/tmp/masv/sp_act_folio_procesado_solicitudes_movil.out";
		--TRACE ON;
	
		Select fecha_hoy into nfecha from si_fechas;
	
			UPDATE si_solicitud_movil set folio_procesado=2
			where fecha_insert = nfecha 
			and status_valua is not null 
			and (num_prestamo is null or num_prestamo='') and (num_tdc_bcoppel is null or num_tdc_bcoppel='') and (num_tdc_coppel is null or num_tdc_coppel='')
			and folio_procesado=0
			and status_valua=1;
	
	LET vCodRet ='00000';
	
	
	
		
	
	return vCodRet;
END;
END PROCEDURE ;