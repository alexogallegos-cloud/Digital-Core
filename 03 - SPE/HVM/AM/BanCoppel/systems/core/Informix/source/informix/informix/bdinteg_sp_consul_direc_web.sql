CREATE procedure "informix".sp_consul_direc_web(eEmpresa  CHAR(3),
                                            eNumCte   CHAR(20),
                                            eTpDirec  INTEGER)

returning char(5),int,char(1),char(40),char(60),char(40),
          char(3),char(2),char(3),char(5),char(5),char(11),char(1),
          char(13),char(1),char(13),char(1),char(13),char(5),char(2),char(3),
          char(4),smallint,char(10),char(10),char(6),int,int,char(1),
          char(1),smallint,smallint,smallint,smallint,smallint,smallint,
          smallint,char(80),char(30),char(30),char(30),char(30),char(30),
          char(30), char(30), char(30), char(30), char(30),char(30);

    DEFINE vsqlerr          integer;
    DEFINE vsecuencia       int ;
    DEFINE vnumerocalle     int ;
    DEFINE vnumerocolonia   int ;
    DEFINE vcodret          char(5);
    DEFINE vtipo_dir        char(1);
    DEFINE vcalle           char(40);
    DEFINE vcolonia         char(60);
    DEFINE ventre_calles    char(40);
    DEFINE vpais            char(3);
    DEFINE vestado          char(2);
    DEFINE vciudad          char(3);
    DEFINE vmunicipio       char(5);
    DEFINE vcod_postal      char(5);
    DEFINE vapart_postal    char(11);
    DEFINE vtipo_telef1     char(1);
    DEFINE vtelefono1       char(13);
    DEFINE vtipo_telef2     char(1);
    DEFINE vtelefono2       char(13);
    DEFINE vtipo_telef3     char(1);
    DEFINE vtelefono3       char(13);
    DEFINE vextension       char(5);
    DEFINE vestado_inegi    char(2);
    DEFINE vmunicipio_inegi char(3);
    DEFINE vlocalidad_inegi char(4);
    DEFINE vnumeroextcalle  char(10);
    DEFINE vnumerointcalle  char(10);
    DEFINE vdepartamento    char(6);
    DEFINE vpuntocardinal   char(1);
    DEFINE vunidadhabitac   char(1);
    DEFINE vobservaciones   char(80);
    DEFINE vNomEdo          char(30);
    DEFINE vNomCiudad       char(30);
    DEFINE vNomColonia      char(30);
    DEFINE vNomCalle        char(30);
    DEFINE vNomLote         char(30);
    DEFINE vNomEntrada      char(30);
    DEFINE vNomEdificio     char(30);
    DEFINE vNomEtapa        char(30);
    DEFINE vNomAndador      char(30);
    DEFINE vNomOtros        char(30);
    DEFINE vNomManzana      char(30);
    DEFINE vmanzana         smallint ;
    DEFINE vCiclo           smallint;
    DEFINE votros           smallint ;
    DEFINE vandador         smallint ;
    DEFINE vetapa           smallint ;
    DEFINE vlote            smallint ;
    DEFINE vnumerociudad    smallint ;
    DEFINE vedificio        smallint ;
    DEFINE ventrada         smallint ;
    DEFINE vCdCoppel        smallint;
    DEFINE vSec             int;
    DEFINE pReg             int;
    
    LET vciclo             = 0;
    LET vcodret            = "00000";
    LET  vsqlerr           = 0;
    LET vsecuencia         = 0;
    LET vtipo_dir          = "";
    LET vcalle             = "";
    LET vcolonia           = "";
    LET ventre_calles      = "";
    LET vpais              = "";
    LET vestado            = "";
    LET vciudad            = "";
    LET vmunicipio         = "";
    LET vcod_postal        = "";
    LET vapart_postal      = "";
    LET vtipo_telef1       = "";
    LET vtelefono1         = "";
    LET vtipo_telef2       = "";
    LET vtelefono2         = "";
    LET vtipo_telef3       = "";
    LET vtelefono3         = "";
    LET vextension         = "";
    LET vestado_inegi      = "";
    LET vmunicipio_inegi   = "";
    LET vlocalidad_inegi   = "";
    LET vnumerociudad      = 0;
    LET vnumeroextcalle    = "";
    LET vnumerointcalle    = "";
    LET vdepartamento      = "";
    LET vnumerocalle       = 0;
    LET vnumerocolonia     = 0;
    LET vpuntocardinal     = "";
    LET vunidadhabitac     = "";
    LET vmanzana           = 0;
    LET votros             = 0;
    LET vandador           = 0;
    LET vetapa             = 0;
    LET vlote              = 0;
    LET vedificio          = 0;
    LET ventrada           = 0;
    LET vobservaciones     = "";
    LET vNomEdo            = '';
    LET vNomCiudad         = '';
    LET vNomColonia        = '';
    LET vNomCalle          = '';
    LET vCdCoppel          = '';
    LET vNomLote           = '';
    LET vNomEntrada        = '';
    LET vNomEdificio       = '';
    LET vNomEtapa          = '';
    LET vNomAndador        = '';
    LET vNomOtros          = '';
    LET vNomManzana        = '';
    LET vSec               = 0;
    LET pReg               = 0;
    --- set debug file to "/home/informix/ash/direc.out";
    --- trace on;

    BEGIN

    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            return  vcodret        ,vsecuencia   ,vtipo_dir      ,vcalle        ,vcolonia        ,ventre_calles   ,vpais        ,vestado        ,
                    vciudad        ,vmunicipio   ,vcod_postal    ,vapart_postal ,vtipo_telef1    ,vtelefono1      ,vtipo_telef2 ,vtelefono2     ,
                    vtipo_telef3   ,vtelefono3   ,vextension     ,vestado_inegi ,vmunicipio_inegi,vlocalidad_inegi,vnumerociudad,vnumeroextcalle,
                    vnumerointcalle,vdepartamento,vnumerocalle   ,vnumerocolonia,vpuntocardinal  ,vunidadhabitac  ,vmanzana     ,votros         ,
                    vandador       ,vetapa       ,vlote          ,vedificio     ,ventrada        ,vobservaciones  ,vNomEdo      ,vNomCiudad     ,
                    vNomColonia    ,vNomCalle    , vNomLote      , vNomEntrada  ,vNomEdificio    ,vNomEtapa       ,vNomAndador  ,vNomOtros      ,
                    vNomManzana    ;
        END IF;
    END EXCEPTION;

    
    IF eEmpresa IS NULL OR eEmpresa = '' OR eNumCte IS NULL OR eNumCte = '' THEN
		LET vcodret = '00001'; 
        return  vcodret        ,vsecuencia   ,vtipo_dir      ,vcalle        ,vcolonia        ,ventre_calles   ,vpais        ,vestado        ,
                vciudad        ,vmunicipio   ,vcod_postal    ,vapart_postal ,vtipo_telef1    ,vtelefono1      ,vtipo_telef2 ,vtelefono2     ,
                vtipo_telef3   ,vtelefono3   ,vextension     ,vestado_inegi ,vmunicipio_inegi,vlocalidad_inegi,vnumerociudad,vnumeroextcalle,
                vnumerointcalle,vdepartamento,vnumerocalle   ,vnumerocolonia,vpuntocardinal  ,vunidadhabitac  ,vmanzana     ,votros         ,
                vandador       ,vetapa       ,vlote          ,vedificio     ,ventrada        ,vobservaciones  ,vNomEdo      ,vNomCiudad     ,
                vNomColonia    ,vNomCalle    , vNomLote      ,vNomEntrada   ,vNomEdificio    ,vNomEtapa       ,vNomAndador  ,vNomOtros      ,
                vNomManzana;   
    END IF;
	
	IF eTpDirec = 0 THEN
	
	FOREACH

		 SELECT dir.secuencia     ,dir.tipo_dir      ,dir.calle       ,dir.colonia     ,dir.entre_calles    ,dir.pais,estado     , dir.ciudad      ,
                dir.municipio     ,dir.cod_postal    ,dir.apart_postal,tel1.tipo_tel ,tel1.telefono       ,tel2.tipo_tel     ,tel2.telefono    ,
                tel3.tipo_tel   ,tel3.telefono     ,tel3.extension   ,dir.estado_inegi,dir.municipio_inegi ,dir.localidad_inegi ,dir.numerociudad ,
                dir.numeroextcalle,dir.numerointcalle,dir.departamento, dir.numerocalle,dir.numerocolonia   ,dir.puntocardinal   ,dir.unidadhabitac,
                dir.manzana       ,dir.otros         ,dir.andador     ,dir.etapa       ,dir.lote            ,dir.edificio        ,dir.entrada       ,
                dir.observaciones
          INTO  vsecuencia   ,vtipo_dir     ,vcalle      ,vcolonia    ,ventre_calles   ,vpais          ,vestado       , vciudad,
                vmunicipio     ,vcod_postal   ,vapart_postal,vtipo_telef1 ,vtelefono1      ,vtipo_telef2    ,vtelefono2    ,
                vtipo_telef3   ,vtelefono3    ,vextension   ,vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,vnumerociudad ,
                vnumeroextcalle,vnumerointcalle,vdepartamento,vnumerocalle,vnumerocolonia  ,vpuntocardinal  ,vunidadhabitac,
                vmanzana       ,votros         ,vandador     ,vetapa      ,vlote           ,vedificio       ,ventrada      ,
                vobservaciones
          FROM si_direcciones_actual dir
          LEFT OUTER JOIN si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
          LEFT OUTER JOIN si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )
          LEFT OUTER JOIN si_telefonos_actual tel3 ON ( tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 )
         WHERE dir.numcte = eNumCte
		 


        SELECT TRIM(nombre) 
          INTO vNomEdo 
          FROM bdinteg:si_estados
         WHERE estado =vestado;

        SELECT TRIM(nombre),ciudad_coppel 
          INTO vNomCiudad,vCdCoppel 
          FROM bdinteg:si_ciudades
         WHERE estado = vestado 
           AND ciudad = vciudad;

        SELECT TRIM(nombrezona) 
          INTO vNomColonia 
          FROM bdinteg:si_catzonas
         WHERE numerociudad = vnumerociudad 
           and numerocolonia  = vnumerocolonia;

        SELECT TRIM(nombrecalle) 
          INTO  vNomCalle 
          FROM bdinteg:si_catcalles
         WHERE numerocalle = vnumerocalle;

        IF vlote > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomLote  
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = vlote;
        END IF;

        IF vmanzana > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomManzana  
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = vmanzana;
        END IF;

        IF votros > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomOtros  
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = votros;
        END IF;

        IF vandador > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomAndador  
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = vandador;
        END IF;

        IF vetapa > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomEtapa    
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = vetapa;
        END IF;

        IF vedificio > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomEdificio  
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = vedificio;
        END IF;

        IF ventrada > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomEntrada  
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = ventrada;
        END IF;  
        
         RETURN  vcodret        ,vsecuencia   ,vtipo_dir      ,vcalle        ,vcolonia        ,ventre_calles   ,vpais        ,vestado        ,
                vciudad        ,vmunicipio   ,vcod_postal    ,vapart_postal ,vtipo_telef1    ,vtelefono1      ,vtipo_telef2 ,vtelefono2     ,
                vtipo_telef3   ,vtelefono3   ,vextension     ,vestado_inegi ,vmunicipio_inegi,vlocalidad_inegi,vnumerociudad,vnumeroextcalle,
                vnumerointcalle,vdepartamento,vnumerocalle   ,vnumerocolonia,vpuntocardinal  ,vunidadhabitac  ,vmanzana     ,votros         ,
                vandador       ,vetapa       ,vlote          ,vedificio     ,ventrada        ,vobservaciones  ,vNomEdo      ,vNomCiudad     ,
                vNomColonia    ,vNomCalle    , vNomLote      ,vNomEntrada   ,vNomEdificio    ,vNomEtapa       ,vNomAndador  ,vNomOtros      ,
                vNomManzana  WITH RESUME;

    END FOREACH;

     
ELSE 
     FOREACH
        SELECT  SKIP pReg  dir.secuencia     ,dir.tipo_dir      ,dir.calle       ,dir.colonia     ,dir.entre_calles    ,dir.pais,estado     , dir.ciudad      ,
                dir.municipio     ,dir.cod_postal    ,dir.apart_postal,tel1.tipo_tel ,tel1.telefono       ,tel2.tipo_tel     ,tel2.telefono    ,
                tel3.tipo_tel   ,tel3.telefono     ,tel3.extension   ,dir.estado_inegi,dir.municipio_inegi ,dir.localidad_inegi ,dir.numerociudad ,
                dir.numeroextcalle,dir.numerointcalle,dir.departamento, dir.numerocalle,dir.numerocolonia   ,dir.puntocardinal   ,dir.unidadhabitac,
                dir.manzana       ,dir.otros         ,dir.andador     ,dir.etapa       ,dir.lote            ,dir.edificio        ,dir.entrada       ,
                dir.observaciones
          INTO  vsecuencia   ,vtipo_dir     ,vcalle      ,vcolonia    ,ventre_calles   ,vpais          ,vestado       , vciudad,
                vmunicipio     ,vcod_postal   ,vapart_postal,vtipo_telef1 ,vtelefono1      ,vtipo_telef2    ,vtelefono2    ,
                vtipo_telef3   ,vtelefono3    ,vextension   ,vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,vnumerociudad ,
                vnumeroextcalle,vnumerointcalle,vdepartamento,vnumerocalle,vnumerocolonia  ,vpuntocardinal  ,vunidadhabitac,
                vmanzana       ,votros         ,vandador     ,vetapa      ,vlote           ,vedificio       ,ventrada      ,
                vobservaciones
          FROM si_direcciones_actual dir
          LEFT OUTER JOIN si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
          LEFT OUTER JOIN si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )
          LEFT OUTER JOIN si_telefonos_actual tel3 ON ( tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 )
         WHERE dir.numcte    = eNumCte
         AND  dir.tipo_dir = eTpDirec
         
       
        SELECT TRIM(nombre) 
          INTO vNomEdo 
          FROM bdinteg:si_estados
         WHERE estado =vestado;

        SELECT TRIM(nombre),ciudad_coppel 
          INTO vNomCiudad,vCdCoppel 
          FROM bdinteg:si_ciudades
         WHERE estado = vestado 
           AND ciudad = vciudad;

        SELECT TRIM(nombrezona) 
          INTO vNomColonia 
          FROM bdinteg:si_catzonas
         WHERE numerociudad = vnumerociudad 
           and numerocolonia  = vnumerocolonia;

        SELECT TRIM(nombrecalle) 
          INTO  vNomCalle 
          FROM bdinteg:si_catcalles
         WHERE numerocalle = vnumerocalle;

        IF vlote > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomLote  
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = vlote;
        END IF;

        IF vmanzana > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomManzana  
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = vmanzana;
        END IF;

        IF votros > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomOtros  
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = votros;
        END IF;

        IF vandador > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomAndador  
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = vandador;
        END IF;

        IF vetapa > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomEtapa    
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = vetapa;
        END IF;

        IF vedificio > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomEdificio  
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = vedificio;
        END IF;

        IF ventrada > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomEntrada  
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = ventrada;
        END IF;
        
        
        IF vsecuencia > 0 THEN
        LET pReg = 1;
        END IF;

        END FOREACH;

        
        IF pReg > 0 THEN
            RETURN  vcodret        ,vsecuencia   ,vtipo_dir      ,vcalle        ,vcolonia        ,ventre_calles   ,vpais        ,vestado        ,
                vciudad        ,vmunicipio   ,vcod_postal    ,vapart_postal ,vtipo_telef1    ,vtelefono1      ,vtipo_telef2 ,vtelefono2     ,
                vtipo_telef3   ,vtelefono3   ,vextension     ,vestado_inegi ,vmunicipio_inegi,vlocalidad_inegi,vnumerociudad,vnumeroextcalle,
                vnumerointcalle,vdepartamento,vnumerocalle   ,vnumerocolonia,vpuntocardinal  ,vunidadhabitac  ,vmanzana     ,votros         ,
                vandador       ,vetapa       ,vlote          ,vedificio     ,ventrada        ,vobservaciones  ,vNomEdo      ,vNomCiudad     ,
                vNomColonia    ,vNomCalle    , vNomLote      ,vNomEntrada   ,vNomEdificio    ,vNomEtapa       ,vNomAndador  ,vNomOtros      ,
                vNomManzana;
            ELSE
				LET vcodret = '00001';
				RETURN  vcodret        ,vsecuencia   ,vtipo_dir      ,vcalle        ,vcolonia        ,ventre_calles   ,vpais        ,vestado        ,
                vciudad        ,vmunicipio   ,vcod_postal    ,vapart_postal ,vtipo_telef1    ,vtelefono1      ,vtipo_telef2 ,vtelefono2     ,
                vtipo_telef3   ,vtelefono3   ,vextension     ,vestado_inegi ,vmunicipio_inegi,vlocalidad_inegi,vnumerociudad,vnumeroextcalle,
                vnumerointcalle,vdepartamento,vnumerocalle   ,vnumerocolonia,vpuntocardinal  ,vunidadhabitac  ,vmanzana     ,votros         ,
                vandador       ,vetapa       ,vlote          ,vedificio     ,ventrada        ,vobservaciones  ,vNomEdo      ,vNomCiudad     ,
                vNomColonia    ,vNomCalle    , vNomLote      ,vNomEntrada   ,vNomEdificio    ,vNomEtapa       ,vNomAndador  ,vNomOtros      ,
                vNomManzana;
			END IF;

    END IF;
  END    
END PROCEDURE;