CREATE PROCEDURE "informix".sp_altactenominaexterna(pempresa CHAR(3),
                                                    pfuncion CHAR(1),
                                                    pnumcte_moral CHAR(20),
                                                    psucursal CHAR(4),
                                                    pejecutivo CHAR(8),
                                                    ptp_persona CHAR (2),
                                                    ptp_cliente CHAR(1),
                                                    ppaterno CHAR (26),
                                                    pmaterno CHAR (26),
                                                    pnombre1 CHAR (26),
                                                    pnombre2 CHAR (26),
                                                    psector CHAR (2),
                                                    presidencia CHAR(1),
                                                    pdistrito CHAR(2),
                                                    pactividad_esp char(11),
                                                    pfecha_nac date,
                                                    pnacionalidad CHAR(3),
                                                    pestado_civil CHAR(1),
                                                    pcodidentif CHAR(2),
                                                    pnumidentif CHAR(20),
                                                    pprofesion CHAR (3),
                                                    psexo CHAR(1),
                                                    phabita_en CHAR(2))
RETURNING CHAR(6),VARCHAR(100),CHAR(20);

    -- Variables de proceso
    DEFINE dtFechaHoy   DATE;
    DEFINE vnumcte      CHAR(20);
    DEFINE sExiste      SMALLINT;
    DEFINE cMensaje_ret VARCHAR(100);
    DEFINE cRfc         VARCHAR(13);
    DEFINE sSecuencia   SMALLINT;
    DEFINE cMunicipio   CHAR(5);
    DEFINE cPais        CHAR(3);
    DEFINE cEstado      CHAR(2);
    DEFINE cCiudad      CHAR(3);
    DEFINE cCod_post    CHAR(5);
    DEFINE cTipoTel1    CHAR(1);
    DEFINE cTel1        CHAR(13);
    DEFINE cTipoTel2    CHAR(1);
    DEFINE cTel2        CHAR(13);
    DEFINE cTipoTel3    CHAR(1);
    DEFINE cTel3        CHAR(13);
    DEFINE cExtension   CHAR(5);
    DEFINE cEdo_inegi       CHAR(2);
    DEFINE cMuni_iegi       CHAR(3);
    DEFINE cLocal_inegi     CHAR(4);
    DEFINE sNumCiudad       SMALLINT;
    DEFINE cNumExtCalle     CHAR(10);
    DEFINE cNumIntCalle     CHAR(10);
    DEFINE cDepto           CHAR(6);
    DEFINE iNumCalle        INTEGER;
    DEFINE iNumColonia      INTEGER;
    DEFINE cPtoCardinal     CHAR(1);
    DEFINE cUnidad_habit    CHAR(1);
    DEFINE sManzana         SMALLINT;
    DEFINE sOtros           SMALLINT;
    DEFINE sAndador         SMALLINT;
    DEFINE sEtapa           SMALLINT;
    DEFINE sLote            SMALLINT;
    DEFINE sEdificio        SMALLINT;
    DEFINE sEntrada         SMALLINT;
    DEFINE cObserva         CHAR(80);
    DEFINE cCalle           CHAR(40);
    DEFINE cColonia         CHAR(60);
    DEFINE cEntreCalles     CHAR(40);

    -- Control de errores
    DEFINE vsqlerr  INTEGER;
    DEFINE visamerr INTEGER;
    DEFINE vcodret  CHAR(6);

    -- Variables de proceso
    LET dtFechaHoy      = DATE(1);
    LET vnumcte         = "";
    LET sExiste         = 0;
    LET cMensaje_ret    = "El proceso se realizó con éxito.";
    LET cRfc            = "";
    LET sSecuencia      = 0;
    LET cPais           = "";
    LET cEstado         = "";
    LET cCiudad         = "";
    LET cCod_post       = "";
    LET cTipoTel1       = "";
    LET cTel1           = "";
    LET cTipoTel2       = "";
    LET cTel2           = "";
    LET cTipoTel3       = "";
    LET cTel3           = "";
    LET cExtension      = "";
    LET cEdo_inegi      = "";
    LET cMuni_iegi      = "";
    LET cLocal_inegi    = "";
    LET sNumCiudad      = 0;
    LET cNumExtCalle    = "";
    LET cNumIntCalle    = "";
    LET cDepto          = "";
    LET iNumCalle       = 0;
    LET iNumColonia     = 0;
    LET cPtoCardinal    = "";
    LET cUnidad_habit   = "";
    LET sManzana        = 0;
    LET sOtros          = 0;
    LET sAndador        = 0;
    LET sEtapa          = 0;
    LET sLote           = 0;
    LET sEdificio       = 0;
    LET sEntrada        = 0;
    LET cObserva        = "";
    LET cCalle          = "";
    LET cColonia        = "";
    LET cEntreCalles    = "";

    -- Control de errores
    LET vsqlerr     = 0;
    LET visamerr    = 0;
    LET vcodret     = "000000";

    BEGIN
    
    ON EXCEPTION SET vsqlerr,visamerr
        IF vsqlerr != 0 THEN
            LET vcodret=vsqlerr;
            RETURN vcodret,cMensaje_ret,vnumcte;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO '/home/sysifx/viridiana/altactenominaexterna.out';
    --TRACE ON;

    SELECT fecha_hoy
      INTO dtFechaHoy
      FROM bdinteg:si_fechas
     WHERE empresa = pempresa;

    --- Verifica que los datos de entrada se hayan proporcionado correctamente
    IF NVL(pempresa,"") = "" OR NVL(pfuncion,"") = "" OR NVL(pnumcte_moral,"") = "" OR (NVL(ppaterno,"") = "" AND NVL(pmaterno,"") = "")
       OR (NVL(pnombre1,"") = "" AND NVL(pnombre2,"") = "") OR NVL(pfecha_nac,"") = "" THEN
        LET vcodret = "000001";
        RETURN vcodret,cMensaje_ret,vnumcte;
    END IF;

    SELECT COUNT(cte.numcte)
      INTO sExiste
      FROM bdinteg:si_cliente cte
     INNER JOIN bdinteg:si_tipper tpo ON cte.tpo_persona = tpo.tpo_persona
     WHERE cte.empresa = pempresa
       AND cte.numcte = pnumcte_moral
       AND tpo.es_fisica = "N";

    IF sExiste = 0 THEN
        LET vcodret = "000002";
        RETURN vcodret,cMensaje_ret,vnumcte;
    END IF;

    EXECUTE PROCEDURE sp_calcularfc(pempresa,ppaterno,pmaterno,pnombre1,pnombre2,pfecha_nac)
    INTO vcodret, cMensaje_ret,cRfc;

    IF vcodret <> "000000" THEN
        LET vcodret = "000003";
        RETURN vcodret,cMensaje_ret,vnumcte;
    END IF;

    SELECT MAX(secuencia)
      INTO sSecuencia
      FROM bdinteg:si_direcciones_actual
     WHERE numcte = pnumcte_moral;

    IF sSecuencia IS NULL THEN
        LET vcodret = "000004";
        LET cMensaje_ret = "No existe dirección para el cliente moral indicado.";
        RETURN vcodret,cMensaje_ret,vnumcte;
    END IF;
    
    SELECT dir.calle, dir.colonia, dir.municipio, dir.entre_calles, dir.pais, dir.estado, dir.ciudad, dir.cod_postal,
           tel1.tipo_tel, tel1.telefono, tel2.tipo_tel, tel2.telefono, tel3.tipo_tel, tel3.telefono, tel3.extension,
           dir.estado_inegi, dir.municipio_inegi, dir.localidad_inegi, dir.numerociudad, dir.numeroextcalle, dir.numerointcalle,
           dir.departamento, dir.numerocalle, dir.numerocolonia, dir.puntocardinal, dir.unidadhabitac, dir.manzana,
           dir.otros, dir.andador, dir.etapa, dir.lote, dir.edificio, dir.entrada, dir.observaciones
      INTO cCalle,cColonia,cMunicipio,cEntreCalles,cPais,cEstado,cCiudad,cCod_post,
           cTipoTel1,cTel1,cTipoTel2,cTel2,cTipoTel3,cTel3,cExtension,
           cEdo_inegi,cMuni_iegi,cLocal_inegi,sNumCiudad,
           cNumExtCalle,cNumIntCalle,cDepto,
           iNumCalle,iNumColonia,cPtoCardinal,cUnidad_habit,
           sManzana,sOtros,sAndador,sEtapa,sLote,sEdificio,sEntrada,
           cObserva
      FROM bdinteg:si_direcciones_actual dir
      LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
      LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )
      LEFT OUTER JOIN bdinteg:si_telefonos_actual tel3 ON ( tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 )
     WHERE dir.numcte = pnumcte_moral
       AND dir.secuencia = sSecuencia;
    
    EXECUTE PROCEDURE ctefisico(pempresa,pfuncion,"",psucursal,pejecutivo,ptp_persona,ptp_cliente,ppaterno,pmaterno,pnombre1,pnombre2,
                                cRfc,psector,"000","","000","000",presidencia,"","",pdistrito,"","",pactividad_esp,pfecha_nac,"",pnacionalidad,
                                "",pestado_civil,"",pprofesion,psexo,"",pcodidentif,pnumidentif,"",0,"","","","0","",phabita_en,0,"",0,"","","",USER,"","")
    INTO vcodret, vnumcte;
    
    IF vcodret <> "000" THEN
        LET vcodret = "000005";
        LET cMensaje_ret = "Error al dar de alta al cliente.";
        RETURN vcodret,cMensaje_ret,vnumcte;
    END IF;
    
    EXECUTE PROCEDURE direcciones(pempresa,pfuncion,vnumcte,0,"2",cCalle,cColonia,cMunicipio,cEntreCalles,cPais,cEstado,cCiudad,cCod_post,cTipoTel1,cTel1,cTipoTel2,cTel2,
                                  cTipoTel3,cTel3,cExtension,cEdo_inegi,cMuni_iegi,cLocal_inegi,sNumCiudad,cNumExtCalle,cNumIntCalle,cDepto,iNumCalle,iNumColonia,cPtoCardinal,
                                  cUnidad_habit,sManzana,sOtros,sAndador,sEtapa,sLote,sEdificio,sEntrada,cObserva,pejecutivo,dtFechaHoy,psucursal)
    INTO vcodret;

    IF vcodret <> "000" THEN
        LET vcodret = "000006";
        LET cMensaje_ret = "Error al registrar la dirección del cliente.";
    END IF;

    UPDATE bdinteg:si_cliente
       SET string1 = "2"
     WHERE empresa = pempresa
       AND numcte = vnumcte;

    RETURN vcodret,cMensaje_ret,vnumcte;
    
    END;
    
END PROCEDURE

DOCUMENT
"Descripción: Procedimiento que da de alta a clientes y dirección",
"BD: bdinteg",
"Fecha: 06-Abril-2010",
"Autor: Viridiana Osobampo Aguilar",
"Modificación: Se modifica consulta que validaba  tipo de persona = 02",
"              ya que se descartaba otro tipo de persona Moral, el 04",
"Fecha: 10-Junio-2010",
"Modifico: Saúl Ivanhoe Valdespino Hernández";

create procedure "informix".sp_consdirec( eEmpresa CHAR(3),
                                          eNumCte  CHAR(20),
                                          eTpDirec INTEGER )

returning char(5),int,char(1),char(40),char(60),char(40),
          char(3),char(2),char(3),char(5),char(5),char(11),char(1),
          char(13),char(1),char(13),char(1),char(13),char(5),char(2),char(3),
          char(4),smallint,char(10),char(10),char(6),int,int,char(1),
          char(1),smallint,smallint,smallint,smallint,smallint,smallint,
          smallint,char(80),char(30),char(30),char(30),char(30),char(27),
          char(30),char(30), char(30), char(30), char(30), char(30),char(30);

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
    DEFINE vNomMunicipio char(27);
    
    LET vciclo             = 0;
    LET vcodret            = "000";
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
    LET vSec                = 0;
    LET vNomMunicipio    = "";

    --- set debug file to "/respaldosbd/saul/sp_consdirec.out";
    --- trace on;

    BEGIN
    
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            
            return vcodret, vsecuencia, vtipo_dir, vcalle, vcolonia, ventre_calles, vpais, vestado,
                   vciudad, vmunicipio, vcod_postal, vapart_postal, vtipo_telef1, vtelefono1, vtipo_telef2, vtelefono2,
                   vtipo_telef3, vtelefono3, vextension, vestado_inegi, vmunicipio_inegi, vlocalidad_inegi, vnumerociudad, vnumeroextcalle,
                   vnumerointcalle, vdepartamento, vnumerocalle, vnumerocolonia, vpuntocardinal, vunidadhabitac, vmanzana, votros,
                   vandador, vetapa, vlote, vedificio, ventrada, vobservaciones, vNomEdo, vNomCiudad,
                   vNomColonia, vNomCalle, vNomMunicipio, vNomLote, vNomEntrada, vNomEdificio, vNomEtapa, vNomAndador, vNomOtros, vNomManzana;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT secuencia
      INTO vSec       
      FROM si_direcciones_actual
     WHERE numcte = eNumCte
       AND tipo_dir = eTpDirec;

    IF vSec IS NULL THEN
    
        LET vcodret = "001"; 
        
    ELSE
    
        SELECT dir.secuencia, dir.tipo_dir, dir.calle, dir.colonia, dir.entre_calles, dir.pais, dir.estado, dir.ciudad,
               dir.municipio, dir.cod_postal, dir.apart_postal, tel1.tipo_tel, tel1.telefono, tel2.tipo_tel, tel2.telefono,
               tel3.tipo_tel, tel3.telefono, tel3.extension, dir.estado_inegi, dir.municipio_inegi, dir.localidad_inegi, dir.numerociudad,
               dir.numeroextcalle, dir.numerointcalle, dir.departamento, dir.numerocalle, dir.numerocolonia, dir.puntocardinal, dir.unidadhabitac,
               dir.manzana, dir.otros, dir.andador, dir.etapa, dir.lote, dir.edificio, dir.entrada, dir.observaciones
          INTO vsecuencia, vtipo_dir, vcalle, vcolonia, ventre_calles, vpais, vestado, vciudad, 
               vmunicipio, vcod_postal, vapart_postal, vtipo_telef1, vtelefono1, vtipo_telef2 , vtelefono2, 
               vtipo_telef3, vtelefono3, vextension, vestado_inegi, vmunicipio_inegi, vlocalidad_inegi, vnumerociudad,
               vnumeroextcalle, vnumerointcalle, vdepartamento, vnumerocalle, vnumerocolonia, vpuntocardinal, vunidadhabitac,
               vmanzana, votros, vandador, vetapa, vlote, vedificio, ventrada, vobservaciones
          FROM si_direcciones_actual dir
          LEFT OUTER JOIN si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
          LEFT OUTER JOIN si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )
          LEFT OUTER JOIN si_telefonos_actual tel3 ON ( tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 )
         WHERE dir.numcte = eNumCte            
           AND dir.tipo_dir = eTpDirec;
       --- AND secuencia = vSec; se elimina la secuencia
        
        SELECT TRIM(nombre) 
          INTO vNomEdo 
          FROM bdinteg:si_estados
         WHERE estado = vestado;

        SELECT TRIM(nombre), ciudad_coppel 
          INTO vNomCiudad, vCdCoppel 
          FROM bdinteg:si_ciudades
         WHERE estado = vestado 
           AND ciudad = vciudad;

        SELECT TRIM(nombrezona) 
          INTO vNomColonia 
          FROM bdinteg:si_catzonas
         WHERE numerociudad = vnumerociudad 
           and numerocolonia = vnumerocolonia;

        SELECT TRIM(nombrecalle) 
          INTO vNomCalle 
          FROM bdinteg:si_catcalles
         WHERE numerocalle = vnumerocalle;

        IF TRIM(vmunicipio) ='00000' THEN     
            LET vmunicipio  = "";     

            SELECT TRIM(municipiozona) 
              INTO vNomMunicipio 
              FROM bdinteg:si_catzonas
             WHERE numerociudad = vnumerociudad 
               and numerocolonia  = vnumerocolonia;
        ELSE
            LET vNomMunicipio = vNomCiudad;     
        END IF; 

        IF vmanzana > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomManzana  
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = 1 
               AND complementoclave = vmanzana;
        END IF;

        IF votros > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomOtros  
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = 2 
               AND complementoclave = votros;
        END IF;

        IF vandador > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomAndador  
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = 3 
               AND complementoclave = vandador;
        END IF;

        IF vetapa > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomEtapa    
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = 4 
               AND complementoclave = vetapa;
        END IF;

        IF vedificio > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomEdificio  
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = 5 
               AND complementoclave = vedificio;
        END IF;

        IF ventrada > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomEntrada  
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = 6 
               AND complementoclave = ventrada;
        END IF;

        IF vlote > 0 THEN
            SELECT TRIM(nombredomicilio) 
              INTO vNomLote  
              FROM bdinteg:si_catdomicilios
             WHERE numerociudad = vCdCoppel 
               AND numerocolonia = vnumerocolonia 
               AND clavedomicilio = 7 
               AND complementoclave = vlote;
        END IF;

    END IF;

    return vcodret, vsecuencia, vtipo_dir, vcalle, vcolonia, ventre_calles, vpais, vestado,
           vciudad, vmunicipio, vcod_postal, vapart_postal, vtipo_telef1, vtelefono1, vtipo_telef2, vtelefono2,
           vtipo_telef3, vtelefono3, vextension, vestado_inegi, vmunicipio_inegi, vlocalidad_inegi, vnumerociudad, vnumeroextcalle,
           vnumerointcalle,vdepartamento,vnumerocalle   ,vnumerocolonia,vpuntocardinal  ,vunidadhabitac  ,vmanzana, votros,
           vandador, vetapa, vlote, vedificio, ventrada, vobservaciones, vNomEdo, vNomCiudad,
           vNomColonia, vNomCalle, vNomMunicipio, vNomLote, vNomEntrada, vNomEdificio, vNomEtapa, vNomAndador, vNomOtros, vNomManzana;

    END;
    
end procedure

DOCUMENT
"Descripción: Consulta la direccion de un Cliente",
"BD: bdinteg",
"Fecha: 26-Noviembre-2010",
"Autor: Saul Ivanhoe Valdespino Hernandez";

CREATE PROCEDURE "informix".sp_consultactesitesp( pEmpresa char(3),
                                                  pSucursal char(4),
                                                  pOrigen smallint,
                                                  pNumCte char(20),
                                                  pApellidoPat char(26),
                                                  pApellidoMat char(26),
                                                  pNombreCte1 char(26),
                                                  pNombreCte2 char(26) )

RETURNING CHAR(6), CHAR(20), CHAR(26), CHAR(26), CHAR(26), CHAR(26), CHAR(1), SMALLINT, CHAR(13), DATE,CHAR(7);

    ----------------------------------------------------------------------
    --ACTIVIDAD: Consulta los clientes
    --Bencoppel con situacion especial.
    --Elaboró : Diana Castellanos L.
    ----------------------------------------------------------------------
    --Modificación: Cambiar Tabla si_direcciones por si_direcciones_actual
    --y eliminar la secuencia de las condiciones.
    --Fecha: 28-02-2011
    --Modifico: Sergio Fernandez Cordero
    ----------------------------------------------------------------------

    DEFINE chrcodret      CHAR(6);
    DEFINE chrnumcte      CHAR(50);
    DEFINE chrnombre1     CHAR(26);
    DEFINE chrnombre2     CHAR(26);
    DEFINE chrapell_pat   CHAR(26);
    DEFINE chrapell_mat   CHAR(26);
    DEFINE chrsituacion   CHAR(1);
    DEFINE chrtelefono    CHAR(13);
    DEFINE chrzona        CHAR(7);
    DEFINE intcausa       INTEGER;
    DEFINE intflag        SMALLINT;
    DEFINE intcodret      INT;
    DEFINE dtefecha       DATE;

    BEGIN

    ON EXCEPTION SET intcodret
        IF intcodret <> 0 THEN
            LET chrcodret = intcodret;
            RETURN chrcodret, pNumCte, pApellidoPat, pApellidoMat, pNombreCte1, pNombreCte2, chrsituacion, intcausa, chrtelefono, dtefecha, chrzona;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/tmp/consultasitesp.out";
    --- TRACE ON;

    LET chrcodret     = '000';
    LET chrnumcte     = '';
    LET chrnombre1    = '';
    LET chrnombre2    = '';
    LET chrapell_pat  = '';
    LET chrapell_mat  = '';
    LET chrsituacion  = '';
    LET chrtelefono   = '';
    LET chrzona       = '';
    LET intcausa      = 0;
    LET intflag       = 0;
    LET dtefecha      = '01-01-1900';

    set isolation to dirty read;
    set lock mode to wait 3;

    IF pNumCte <> '' THEN
        IF EXISTS ( SELECT numcte FROM bdinteg:si_cliente WHERE numcte = pNumCte ) THEN
            SELECT NVL(TRIM(a.nombre1),''),
                   NVL(TRIM(a.nombre2),''),
                   NVL(a.apell_paterno,''),
                   NVL(a.apell_materno,''),
                   NVL(b.situacion,'' ),
                   NVL(b.causa,0),
                   NVL(e.telefono,''),
                   d.fecha_nac,
                   trim(lpad(c.numerociudad,3,'0') ) || trim(lpad(c.numerocolonia,4,'0'))
              INTO chrnombre1, chrnombre2, chrapell_pat, chrapell_mat, chrsituacion, intcausa, chrtelefono, dtefecha, chrzona
              FROM bdinteg:si_cliente a
             INNER JOIN bdinteg:si_direcciones_actual c ON ( a.numcte = c.numcte and tipo_dir = 1 )
              LEFT JOIN bdisitesp:se_ctessitespcte b ON ( a.numcte = b.numcte )
              LEFT JOIN bdinteg:si_ctepf d ON ( a.numcte = d.numcte )
              LEFT OUTER JOIN si_telefonos_actual e ON ( e.numcte = a.numcte AND e.tipo_tel = 1 )
            WHERE a.numcte = pNumCte;

            RETURN chrcodret, pNumCte, chrapell_pat, chrapell_mat, chrnombre1, chrnombre2, chrsituacion, intcausa, chrtelefono, dtefecha, chrzona WITH RESUME;
        ELSE
            LET chrcodret = '001';  --- No existe numero de cliente
            RETURN chrcodret, pNumCte, chrapell_pat, chrapell_mat, chrnombre1, chrnombre2, chrsituacion, intcausa, chrtelefono, dtefecha, chrzona WITH RESUME;
        END IF;
    ELSE
        FOREACH
            SELECT a.numcte,
                   NVL(TRIM(a.nombre1),''),
                   NVL(TRIM(a.nombre2),''),
                   NVL(a.apell_paterno,''),
                   NVL(a.apell_materno,''),
                   NVL(b.situacion,'' ),
                   NVL(b.causa,0),
                   NVL(e.telefono,''),
                   d.fecha_nac,
                   trim(lpad(c.numerociudad,3,'0') ) || trim(lpad(c.numerocolonia,4,'0'))
              INTO chrnumcte, chrnombre1, chrnombre2, chrapell_pat, chrapell_mat, chrsituacion, intcausa, chrtelefono, dtefecha, chrzona
              FROM bdinteg:si_cliente a
             INNER JOIN bdinteg:si_direcciones_actual c ON a.numcte = c.numcte and c.tipo_dir = 1
             LEFT JOIN bdisitesp:se_ctessitespcte b ON a.numcte = b.numcte
             LEFT JOIN bdinteg:si_ctepf d ON a.numcte = d.numcte
             LEFT OUTER JOIN si_telefonos_actual e ON ( e.numcte = a.numcte AND e.tipo_tel = 1 )
             WHERE TRIM(a.nombre1) || ' ' || TRIM(a.nombre2) = TRIM(pNombreCte1)
               AND a.apell_paterno = pApellidoPat
               AND a.apell_materno = pApellidoMat

            LET intflag = 1;

            RETURN chrcodret, chrnumcte, chrapell_pat, chrapell_mat, chrnombre1, chrnombre2, chrsituacion, intcausa, chrtelefono, dtefecha, chrzona WITH RESUME;
        END FOREACH;

        IF intflag = 0 THEN
            LET chrcodret = '002';  --- No existe nombre de cliente
            RETURN chrcodret, chrnumcte, chrapell_pat, chrapell_mat, chrnombre1, chrnombre2, chrsituacion, intcausa, chrtelefono, dtefecha, chrzona WITH RESUME;
        END IF;

    END IF;

    END;

END PROCEDURE;