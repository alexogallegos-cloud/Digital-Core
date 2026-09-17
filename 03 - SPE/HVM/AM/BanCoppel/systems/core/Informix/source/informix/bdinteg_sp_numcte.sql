CREATE PROCEDURE "informix".sp_numcte(pId CHAR(12), pIdDocto CHAR(1))
   RETURNING CHAR(5) as CodRet, CHAR(9) as NumCte, CHAR(4) as cod_docto, CHAR(5) as secuencia, CHAR(3) as formato;
DEFINE iSqlErr      INTEGER;
DEFINE cCodRet      CHAR(5);
DEFINE cNumCte      CHAR(9);
DEFINE iStatusValua	INTEGER;
DEFINE sCodRetImg   CHAR(3);
DEFINE sCodRetExp   CHAR(3);
DEFINE iSecuencia   SMALLINT;
DEFINE pIdDoctoAux  CHAR(1);
DEFINE sCodDocto    CHAR(4);
DEFINE sFormato     CHAR(3);
DEFINE iExiste     INTEGER;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

LET iSqlErr         = 0;
LET cCodRet         = '00000';
LET sCodRetExp      ='000';
LET cNumCte         = '';
LET sCodRetImg      = '';
LET iSecuencia      = 0;
LET sCodDocto       = '';
LET sFormato        = '';
LET pIdDoctoAux     ='';
LET iExiste			=0;
LET iStatusValua	=-1;

BEGIN

ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
   IF iSqlErr <> 0 THEN
       LET cCodRet = iSqlErr;
       RETURN cCodRet,'', '', 0, '';
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/VH/movil/sp_numcte.out';
--TRACE ON;

IF pIdDocto='0' THEN
    LET sCodDocto = '0001';
    LET sFormato='JPG';
ELIF pIdDocto='1' THEN
    LET sCodDocto = '0001';
    LET sFormato='JPG';
ELIF pIdDocto='3' THEN
    LET sCodDocto = '0600';
    LET sFormato='PNG';    
ELIF pIdDocto='4' THEN
    LET sCodDocto = '0601';
    LET sFormato='PNG';
ELIF pIdDocto='5' THEN
    LET sCodDocto = '0602';
    LET sFormato='PNG';
ELIF pIdDocto='6' THEN
    LET sCodDocto = '0603';
    LET sFormato='JPG';
END IF;




	SET ISOLATION TO DIRTY READ;
    SELECT numcte,status_valua INTO cNumCte, iStatusValua FROM bdinteg:"informix".si_solicitud_movil WHERE id=pId;
	
	IF iStatusValua IS NOT NULL AND iStatusValua=2 THEN
		LET cCodRet='00005';
		RETURN cCodRet,'', '', 0, '';
	END IF;
	

	IF sCodDocto = '0001' THEN
		--SELECT COUNT(*) INTO iExiste FROM bdidigital@coppelimg_crx:dg_expediente WHERE empresa='001' and cliente=cNumCte and cod_docto='0001';
		SELECT COUNT(*) INTO iExiste FROM bdidigital@coppelimg_crx:"informix".dg_expediente ex INNER JOIN bdidigital@coppelimg_crx:"informix".dg_expediente_img1 img1 ON ex.cliente=img1.cliente AND img1.cod_docto=ex.cod_docto AND ex.secuencia=img1.secuencia WHERE ex.cliente=cNumCte and ex.cod_docto='0001' AND img1.imagen IS NOT NULL;
		IF iExiste>=2 THEN
             LET cCodRet='00004';
             RETURN cCodRet,'', '', 0, '';
		END IF;
		SELECT COUNT(*) INTO iExiste FROM bdidigital@coppelimg_crx:"informix".dg_expediente ex INNER JOIN bdidigital@coppelimg_crx:"informix".dg_expediente_img2 img2 ON ex.cliente=img2.cliente AND img2.cod_docto=ex.cod_docto AND ex.secuencia=img2.secuencia WHERE ex.cliente=cNumCte and ex.cod_docto='0001';
		IF iExiste>=2 THEN
             LET cCodRet='00004';
             RETURN cCodRet,'', '', 0, '';
		END IF;
	END IF;

    IF cNumCte IS NULL OR 
	(cNumCte)='' THEN
        LET cCodRet='00001';
        RETURN cCodRet,'', '', 0, '';
    ELSE
      --EJECUTANDO SP INSERTA_IMG_PREVIO
       execute procedure bdidigital@coppelimg_crx:"informix".inserta_img_previo('001', cNumCte, sCodDocto, sFormato, 'informix')
        INTO sCodRetImg, iSecuencia;

       IF sCodRetImg<>'000' THEN
          LET cCodRet='00002';
          RETURN cCodRet,'', '', 0, '';
       ELSE
          EXECUTE PROCEDURE bdidigital:"informix".inserta_reg_expediente('001', cNumCte, '99999999999', '9999', sCodDocto, iSecuencia, 'ALTA CLIENTES', '','informix')
            INTO sCodRetExp;
          IF sCodRetExp<>'000' THEN
             LET cCodRet='00003';
             RETURN cCodRet,'', '', 0, '';
          END IF;
       END IF;

    END IF

RETURN cCodRet, cNumCte,sCodDocto, iSecuencia, sFormato;

END
END PROCEDURE
DOCUMENT
'Descripcion: consulta el identificador de solicitudes movil.',
'BD: BDINTEG';

CREATE PROCEDURE "informix".consdirec_web(pempresa char(3), pnumcte char(20), pnum_direc smallint)
returning char(5),int,char(1),char(40),char(60),char(40),
          char(3),char(2),char(3),char(5),char(5),char(11),char(1),
          char(13),char(1),char(13),char(1),char(13),char(5),char(2),char(3),
          char(4),smallint,char(10),char(10),char(6),int,int,char(1),
          char(1),smallint,smallint,smallint,smallint,smallint,smallint,
          smallint,char(80);

    DEFINE vcodret char(5);
    DEFINE vciclo smallint;
    DEFINE vsqlerr integer;

    DEFINE vsecuencia int ;
    DEFINE vtipo_dir char(1);
    DEFINE vcalle char(40);
    DEFINE vcolonia char(60);
    DEFINE ventre_calles char(40);
    DEFINE vpais char(3);
    DEFINE vestado char(2);
    DEFINE vciudad char(3);
    DEFINE vmunicipio char(5);
    DEFINE vcod_postal char(5);
    DEFINE vapart_postal char(11);
    DEFINE vtipo_telef1  char(1);
    DEFINE vtelefono1 char(13);
    DEFINE vtipo_telef2  char(1);
    DEFINE vtelefono2  char(13);
    DEFINE vtipo_telef3  char(1);
    DEFINE vtelefono3  char(13);
    DEFINE vextension char(5);
    DEFINE vestado_inegi  char(2);
    DEFINE vmunicipio_inegi char(3);
    DEFINE vlocalidad_inegi  char(4);
    DEFINE vnumerociudad smallint ;
    DEFINE vnumeroextcalle  char(10);
    DEFINE vnumerointcalle  char(10);
    DEFINE vdepartamento  char(6);
    DEFINE vnumerocalle int ;
    DEFINE vnumerocolonia int ;
    DEFINE vpuntocardinal  char(1);
    DEFINE vunidadhabitac  char(1);
    DEFINE vmanzana smallint ;
    DEFINE votros  smallint ;
    DEFINE vandador smallint ;
    DEFINE vetapa smallint ;
    DEFINE vlote  smallint ;
    DEFINE vedificio  smallint ;
    DEFINE ventrada  smallint ;
    DEFINE vobservaciones char(80);
	DEFINE vsecuenciamax int ;
	DEFINE vsecuenciamin int ;

    LET vciclo = 0;
    LET vcodret = "00000";
    LET  vsqlerr = 0;

    LET vsecuencia = 0;
	LET vsecuenciamax = 0;
	LET vsecuenciamin = 0;
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

    BEGIN

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

		SET ISOLATION DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		select max(secuencia) 
		INTO  vsecuenciamax
		from "informix".si_direcciones 		
		where numcte = pnumcte;

		if vsecuenciamax > 20 THEN

			let vsecuenciamin = vsecuenciamax - 20;

		end if;
	-- Termina modificacion

    FOREACH
        SELECT dir.secuencia,dir.tipo_dir,dir.calle,dir.colonia,dir.entre_calles,dir.pais,dir.estado,dir.ciudad,dir.municipio,dir.cod_postal,dir.apart_postal,
                nvl(tel1.tipo_tel,''),nvl(tel1.telefono,''),nvl(tel2.tipo_tel,''),nvl(trim(tel2.telefono),''),nvl(tel3.tipo_tel,''),nvl(tel3.telefono,''),nvl(tel3.extension,''),
                dir.estado_inegi,dir.municipio_inegi,dir.localidad_inegi,dir.numerociudad,dir.numeroextcalle,dir.numerointcalle,dir.departamento,
                dir.numerocalle,dir.numerocolonia,dir.puntocardinal,dir.unidadhabitac,dir.manzana,dir.otros,dir.andador,dir.etapa,dir.lote,dir.edificio,dir.entrada,dir.observaciones
          INTO  vsecuencia,vtipo_dir,vcalle,vcolonia,ventre_calles,vpais,vestado,vciudad,vmunicipio,vcod_postal,vapart_postal,
                vtipo_telef1,vtelefono1,vtipo_telef2,vtelefono2,vtipo_telef3,vtelefono3,vextension,
                vestado_inegi,vmunicipio_inegi,vlocalidad_inegi,vnumerociudad,vnumeroextcalle,vnumerointcalle,vdepartamento,
                vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,vmanzana,votros,vandador,vetapa,vlote,vedificio,ventrada,vobservaciones
          FROM "informix".si_direcciones dir
          LEFT OUTER JOIN "informix".si_telefonos_actual tel1 ON (tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
          LEFT OUTER JOIN "informix".si_telefonos_actual tel2 ON (tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
          LEFT OUTER JOIN "informix".si_telefonos_actual tel3 ON (tel3.numcte = dir.numcte AND tel3.tipo_tel = 3)
         WHERE dir.numcte = pnumcte
		 and dir.secuencia > vsecuenciamin
		 and dir.secuencia <= vsecuenciamax
         ORDER BY dir.secuencia

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
                vciudad,vmunicipio,vcod_postal,vapart_postal,vtipo_telef1,vtelefono1,
                vtipo_telef2,vtelefono2,vtipo_telef3,vtelefono3,vextension,vestado_inegi,vmunicipio_inegi,
                vlocalidad_inegi,vnumerociudad,vnumeroextcalle,vnumerointcalle,vdepartamento,
                vnumerocalle,vnumerocolonia,vpuntocardinal,vunidadhabitac,vmanzana,
                votros,vandador,vetapa,vlote,vedificio,ventrada,vobservaciones  with resume;
    END FOREACH;
    
    END
    
END PROCEDURE

DOCUMENT
"Consulta de direcciones del cliente",
"Autor : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Daniel Zambada",
"FECHA : 30/octubre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".consppes_n_web (pempresa char(3), pnumcte char(20), pnum_direc smallint)
            RETURNING CHAR(5), -- Codigo Retorno
                                     CHAR(3), -- Empresa
                                     CHAR(20), -- NumCte
                                     CHAR(1), -- Tipo_ppes
                                     CHAR(2), -- puesto_ppes
                                     CHAR(26), -- Apell_paterno
                                     CHAR(26), -- Apell_materno
                                     CHAR(26), -- Nombre1
                                     CHAR(26), -- Nombre2
                                     DECIMAL(14,2), --Participacion
                                     CHAR(80), -- Domicilio
                                     CHAR(20), -- Telefono
                                     CHAR(8), -- User_insert
                                     DATE, -- Fecha_insert
                                     INTEGER, -- NumeroRegistro
                                     CHAR(40); -- Asociacion_civil

-- Definicion de Variables
DEFINE vcodret CHAR(5);
DEFINE vciclo SMALLINT;
DEFINE vsqlerr INTEGER;
-- si_cteppes
DEFINE vempresa CHAR(3);
DEFINE vnumcte CHAR(20);
DEFINE vtipo_ppes CHAR(1);
DEFINE vpuesto_ppes  CHAR(2);
DEFINE vapell_paterno  CHAR(26);
DEFINE vapell_materno CHAR(26);
DEFINE vnombre1  CHAR(26);
DEFINE vnombre2  CHAR(26);
DEFINE vparticipacion DECIMAL(14,2);
DEFINE vdomicilio  CHAR(80);
DEFINE vtelefono  CHAR(20);
DEFINE vuser_insert CHAR(8);
DEFINE vfecha_insert DATE;
DEFINE vnumeroregistro  INTEGER ;
DEFINE vasociacioncivil CHAR(40);

-- Inicializacion de Variables
LET vciclo = 0;
LET vcodret = "00000";
LET  vsqlerr = 0;
-- si_cteppes
LET vempresa = "";
LET vnumcte = "";
LET vtipo_ppes = "";
LET vpuesto_ppes = "";
LET vapell_paterno = "";
LET vapell_materno = "";
LET vnombre1 = "";
LET vnombre2 = "";
LET vparticipacion = 0;
LET vdomicilio = "";
LET vtelefono = "";
LET vuser_insert = "";
LET vfecha_insert = "";
LET vnumeroregistro = 0;
LET vasociacioncivil = "";

   -- SET DEBUG FILE TO "/informix/JesusBueno/servicios/SpsModificados/consppes_n.out";
   -- TRACE ON;

BEGIN
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret,vempresa,vnumcte,vtipo_ppes,vpuesto_ppes,vapell_paterno,vapell_materno,vnombre1,vnombre2,
                            vparticipacion,vdomicilio,vtelefono,vuser_insert,vfecha_insert,vnumeroregistro,vasociacioncivil;
        END IF;
    END EXCEPTION;

    SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    FOREACH
        SELECT empresa, numcte,tipo_ppes,puesto_ppes,apell_paterno,apell_materno,nombre1,nombre2,
                        participacion,domicilio,telefono,user_insert,fecha_insert,numeroregistro,asociacion_civil
             INTO  vempresa,vnumcte,vtipo_ppes,vpuesto_ppes,vapell_paterno,vapell_materno,vnombre1,vnombre2,
                        vparticipacion,vdomicilio,vtelefono,vuser_insert,vfecha_insert,vnumeroregistro,vasociacioncivil
           FROM bdinteg:"informix".si_cteppes
        WHERE numcte = pnumcte AND empresa = pempresa
        ORDER BY numeroregistro
        
        LET vciclo = vciclo+1;
        
        IF vciclo <= pnum_direc THEN
            CONTINUE FOREACH;
        END IF
        
        RETURN vcodret,vempresa,vnumcte,vtipo_ppes,vpuesto_ppes,vapell_paterno,vapell_materno,vnombre1,vnombre2,
                        vparticipacion,vdomicilio,vtelefono,vuser_insert,vfecha_insert,vnumeroregistro,vasociacioncivil WITH RESUME;
	
    END FOREACH;
	
	IF vciclo = 0 THEN
		LET vcodret = '00001';
		 RETURN vcodret,vempresa,vnumcte,vtipo_ppes,vpuesto_ppes,vapell_paterno,vapell_materno,vnombre1,vnombre2,
                        vparticipacion,vdomicilio,vtelefono,vuser_insert,vfecha_insert,vnumeroregistro,vasociacioncivil;
		
	END IF 
END
END PROCEDURE
DOCUMENT
"Consulta de personas politicas",
"Autor : Daniela Viridiana Ramirez Perez",
"FECHA : 15/07/2011",
"BD    : bdinteg";

CREATE PROCEDURE "informix".direcciones_web( pEmpresa         CHAR(3),  
                                         pFuncion         CHAR(1),   
                                         pNumCte          CHAR(20), 
                                         pSecuencia       SMALLINT, 
                                         pTipoDir         CHAR(1), 
                                         pCalle           CHAR(40),
                                         pColonia         CHAR(60), 
                                         pMunicipio       CHAR(5), 
                                         pEntre_Calles    CHAR(40),
                                         pPais            CHAR(3),
                                         pEntidad         CHAR(2),
                                         pLocalidad       CHAR(3),
                                         pCodPostal       CHAR(5),
                                         pTipoTel1        CHAR(1),
                                         pTelefono1       CHAR(13),
                                         pTipoTel2        CHAR(1),
                                         pTelefono2       CHAR(13),
                                         pTipoTel3        CHAR(1),
                                         pTelefono3       CHAR(13),
                                         pExtension       CHAR(5),
                                         pEstado_Inegi    CHAR(2),
                                         pMunicipio_Inegi CHAR(3),
                                         pLocalidad_Inegi CHAR(4),
                                         pNoCiudad        SMALLINT,
                                         pNoExt           CHAR(10),
                                         pNoInt           CHAR(10),
                                         pDepto           CHAR(6),
                                         pNoCalle         INTEGER,
                                         pNoColonia       INTEGER,
                                         pPuntoCar        CHAR(1),
                                         pUniHabi         CHAR(1),
                                         pManz            SMALLINT,
                                         pPOtros          SMALLINT,
                                         pAndador         SMALLINT,
                                         pEtapa           SMALLINT,
                                         pLote            SMALLINT,
                                         pEdif            SMALLINT,
                                         pEntrada         SMALLINT,
                                         pObserva         CHAR(80),
                                         pUser_Insert     CHAR(8),
                                         pFecha_Insert    DATE,
                                         cSucursal        CHAR(4) )
RETURNING CHAR(5);

    DEFINE cCodRet             CHAR(5);
    DEFINE cCodRet2            CHAR(5);
    DEFINE cCodRet3            CHAR(50);
    DEFINE iSqlErr             INTEGER;
    DEFINE iIsamErr            INTEGER;
    DEFINE cDescErr            CHAR(50);
    DEFINE cNumCte             CHAR(20);
    DEFINE iCoincide_dir        SMALLINT;
    DEFINE cTipoDir         	CHAR(1);
    DEFINE cCalle            	CHAR(40);
    DEFINE cColonia         	CHAR(60);
    DEFINE cEntreCalles     	CHAR(40);
    DEFINE cPais           	CHAR(3);
    DEFINE cEstado         	CHAR(2);
    DEFINE cCiudad         	CHAR(3);
    DEFINE cMunicipio      	CHAR(5);
    DEFINE cCodPostal     	CHAR(5);
    DEFINE cApartPostal   	CHAR(11);
    DEFINE cTelefono1      	CHAR(13);
    DEFINE cTelefono2      	CHAR(13);
    DEFINE cTelefono3      	CHAR(13);
    DEFINE cExtension      	CHAR(5);
    DEFINE cEstadoInegi   	CHAR(2);
    DEFINE cMunicipioInegi	CHAR(3);
    DEFINE cLocalidadInegi    CHAR(4);
    DEFINE iNumeroCiudad   	SMALLINT;
    DEFINE cNumeroExtCalle 	CHAR(10);
    DEFINE cNumeroIntCalle 	CHAR(10);
    DEFINE cDepartamento   	CHAR(6);
    DEFINE iNumeroCalle    	INTEGER;
    DEFINE iNumeroColonia  	INTEGER;
    DEFINE cPuntoCardinal  	CHAR(1);
    DEFINE cUnidadHabitac  	CHAR(1);
    DEFINE iManzana        	SMALLINT;
    DEFINE iOtros          	SMALLINT;
    DEFINE iAndador        	SMALLINT;
    DEFINE iEtapa          	SMALLINT;
    DEFINE iLote           	SMALLINT;
    DEFINE iEdificio       	SMALLINT;
    DEFINE iEntrada        	SMALLINT;
    DEFINE cObservaciones  	CHAR(80);
    DEFINE cCodRetTel          CHAR(5);
    DEFINE iTipoTel             SMALLINT;
    DEFINE iCanal               SMALLINT;
    DEFINE cSituacionEsp        CHAR(1);  --- VARIABLE DE SITUACION ESPECIAL
    DEFINE iCausa               INTEGER;  --- VARIABLE DE SITUACION ESPECIAL

    LET cCodRet          = '';
    LET cCodRet2         = '';
    LET cCodRet3         = '';
    LET iSqlErr          = 0;
    LET iIsamErr         = 0;
    LET cDescErr         = '';
    LET cNumCte          = '';
    LET iCoincide_dir     = 0;
    LET cTipoDir        = '';
    LET cCalle           = '';
    LET cColonia         = '';
    LET cEntreCalles    = '';
    LET cPais            = '';
    LET cEstado          = '';
    LET cCiudad          = '';
    LET cMunicipio       = '';
    LET cCodPostal      = '';
    LET cApartPostal    = '';
    LET cTelefono1       = '';
    LET cTelefono2       = '';
    LET cTelefono3       = '';
    LET cExtension       = '';
    LET cEstadoInegi    = '';
    LET cMunicipioInegi = '';
    LET cLocalidadInegi = '';
    LET iNumeroCiudad    = 0;
    LET cNumeroExtCalle  = '';
    LET cNumeroIntCalle  = '';
    LET cDepartamento    = '';
    LET iNumeroCalle     = 0;
    LET iNumeroColonia   = 0;
    LET cPuntoCardinal   = '';
    LET cUnidadHabitac   = '';
    LET iManzana         = 0;
    LET iOtros           = 0;
    LET iAndador         = 0;
    LET iEtapa           = 0;
    LET iLote            = 0;
    LET iEdificio        = 0;
    LET iEntrada         = 0;
    LET cObservaciones   = '';
    LET cCodRetTel       = '';
    LET iTipoTel          = 0;
    LET iCanal            = 1;
    LET cSituacionEsp     = 'N'; --- VARIABLE DE SITUACION ESPECIAL
    LET iCausa            = 0;   --- VARIABLE DE SITUACION ESPECIAL

     --SET DEBUG FILE TO "/informix/tmp/direcciones.out";
     --TRACE ON;

    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        --SET DEBUG FILE TO "/tmp/direcciones.err";
        --TRACE ON;
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = cDescErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    LET cCodRet = "00000";
    LET pEntidad = CAST( LPAD (TRIM(pEntidad), 2 ,  "0") AS CHAR(2));

    SELECT numcte 
      INTO cNumCte 
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = pNumCte;
     
    IF cNumCte IS NULL THEN
        LET cCodRet = "00104";
        RETURN cCodRet;
    END IF

    IF pFuncion = "C" THEN
        DELETE FROM bdinteg:"informix".si_direcciones
         WHERE numcte = pNumCte 
           AND secuencia = pSecuencia;
           
        DELETE FROM bdinteg:"informix".si_direcciones_actual
         WHERE numcte = pNumCte 
           AND secuencia = pSecuencia;
           
        LET pFuncion = "A";
    END IF

    IF pFuncion = "A" THEN
        SELECT MAX(secuencia) 
          INTO pSecuencia
          FROM bdinteg:"informix".si_direcciones_actual
         WHERE numcte = pNumCte;
         
        IF pSecuencia IS NULL THEN
            LET pSecuencia = 1;
        ELSE
            LET pSecuencia = pSecuencia + 1;
            LET cSituacionEsp = 'S';
        END IF;

        -- // SE AGREGA VALIDACION PARA SI LA CLAVE DEL MUNICIPIO VIENE VACIO, LE ASIGNE  "00000".
        IF pMunicipio = "" OR pMunicipio is null  THEN
            LET pMunicipio = LPAD(TRIM(NVL(pMunicipio,"00000")),5,"0");
        END IF;
        
        -- // VALIDA LA INFORMACION DE LA DIRECCION DEL CLIENTE
        SELECT tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
               estado_inegi, municipio_inegi, localidad_inegi, numerociudad, 
               numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
               puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones
          INTO cTipoDir, cCalle, cColonia, cEntreCalles, cPais, cEstado, cCiudad, cMunicipio, cCodPostal, cApartPostal,
               cEstadoInegi, cMunicipioInegi, cLocalidadInegi, iNumeroCiudad, 
               cNumeroExtCalle, cNumeroIntCalle, cDepartamento, iNumeroCalle, iNumeroColonia, 
               cPuntoCardinal, cUnidadHabitac, iManzana, iOtros, iAndador, iEtapa, iLote, iEdificio, iEntrada, cObservaciones
          FROM bdinteg:"informix".si_direcciones_actual
         WHERE numcte = pNumCte
           AND tipo_dir = pTipoDir;
        
        IF ( cTipoDir is not null               
             AND cCalle = pCalle                     
             AND cColonia = pColonia                 
             AND cEntreCalles = pEntre_Calles       
             AND cPais = pPais                       
             AND cEstado = pEntidad                  
             AND cCiudad = pLocalidad                
             AND cMunicipio = pMunicipio             
             AND cCodPostal = pCodPostal            
             AND cEstadoInegi = pEstado_Inegi       
             AND cMunicipioInegi = pMunicipio_Inegi 
             AND cLocalidadInegi = pLocalidad_Inegi 
             AND iNumeroCiudad = pNoCiudad           
             AND cNumeroExtCalle = pNoExt            
             AND cNumeroIntCalle = pNoInt            
             AND cDepartamento = pDepto              
             AND iNumeroCalle = pNoCalle             
             AND iNumeroColonia = pNoColonia         
             AND cPuntoCardinal = pPuntoCar          
             AND cUnidadHabitac = pUniHabi           
             AND iManzana = pManz                    
             AND iOtros = pPOtros                    
             AND iAndador  = pAndador                
             AND iEtapa = pEtapa                     
             AND iLote = pLote                       
             AND iEdificio = pEdif                   
             AND iEntrada = pEntrada                 
             AND cObservaciones = pObserva ) THEN
            LET iCoincide_dir = 1;
			LET cCodRet = "00001";
        ELSE
            LET iCoincide_dir = 0;
        END IF;
        
        IF ( iCoincide_dir <= 0 ) THEN
			INSERT INTO bdinteg:"informix".si_direcciones
            ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
              estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, 
              departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, 
              andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )
            VALUES
            ( pNumCte, pSecuencia, pTipoDir, pCalle, pColonia, pEntre_Calles, pPais, pEntidad, pLocalidad, pMunicipio, pCodPostal, "",
              pEstado_Inegi, pMunicipio_Inegi, pLocalidad_Inegi, pNoCiudad, pNoExt, pNoInt,
              pDepto, pNoCalle, pNoColonia, pPuntoCar, pUniHabi, pManz, pPOtros,
              pAndador, pEtapa, pLote, pEdif, pEntrada, pObserva, pUser_Insert, pFecha_Insert );
        END IF;
        
        -- // VALIDA LA INFORMACION DE LOS TELEFONOS DEL CLIENTE
        SELECT telefono
          INTO cTelefono1
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 1;
           
        IF cTelefono1 is null THEN
            LET cTelefono1 = ' ';
        END IF;
           
        IF cTelefono1 <> pTelefono1 THEN
            IF cSucursal = '5002' THEN
                LET iCanal = 12;
            END IF;
              
            IF ( ( pTipoTel1 is not null AND pTipoTel1 <> '' ) AND ( pTelefono1 is not null AND pTelefono1 <> '' ) ) THEN
                LET iTipoTel = 1;
                CALL bdinteg:"informix".sp_registra_telefonos(pEmpresa, pNumCte, pTelefono1, iTipoTel, '', 0, iCanal, pUser_Insert)
                RETURNING cCodRetTel;
            END IF;
        END IF;
           
        SELECT telefono
          INTO cTelefono2
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 2;
           
        IF cTelefono2 is null THEN
            LET cTelefono2 = ' ';
        END IF;
           
        IF cTelefono2 <> pTelefono2 THEN
            IF cSucursal = '5002' THEN
                LET iCanal = 12;
            END IF;
              
            IF ( ( pTipoTel2 is not null AND pTipoTel2 <> '' ) AND ( pTelefono2 is not null AND pTelefono2 <> '' ) ) THEN
                LET iTipoTel = 2;
                CALL bdinteg:"informix".sp_registra_telefonos(pEmpresa, pNumCte, pTelefono2, iTipoTel, '', 0, iCanal, pUser_Insert)
                RETURNING cCodRetTel;
            END IF;
        END IF;
           
        SELECT telefono, extension
          INTO cTelefono3, cExtension
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 3;
           
        IF cTelefono3 is null THEN
            LET cTelefono3 = ' ';
        END IF;
           
        IF cTelefono3 <> pTelefono3 THEN
            IF cSucursal = '5002' THEN
                LET iCanal = 12;
            END IF;
              
            IF ( ( pTipoTel3 is not null AND pTipoTel3 <> '' ) AND ( pTelefono3 is not null AND pTelefono3 <> '' ) ) THEN
                LET iTipoTel = 3;
                CALL bdinteg:"informix".sp_registra_telefonos(pEmpresa, pNumCte, pTelefono3, iTipoTel, pExtension, 0, iCanal, pUser_Insert)
                RETURNING cCodRetTel;
            END IF;
        END IF;
        
        -- // VALIDACION DE SITUACION ESPECIAL
        IF pTipoDir = '1' AND cSituacionEsp = 'S' THEN
            SELECT LIMIT 1 NVL(situacion,''), causa
              INTO cSituacionEsp, iCausa
              FROM bdisitesp:"informix".se_ctessitespcte
             WHERE numcte = pNumCte;
			
            IF cSituacionEsp = 'L' THEN			 
                DELETE FROM bdisitesp:"informix".se_ctessitespcte 
                 WHERE numcte = pNumCte 
                   AND situacion = 'L';
            
                INSERT INTO bdisitesp:"informix".se_ctessitespcte_his
                (empresa, sucursal, numcte, situacion, causa, tipomovto, empleadoefectuo, usralta, fchmodifica)
                VALUES
                (pEmpresa, cSucursal, pNumCte, cSituacionEsp, iCausa, 'B', pUser_Insert, pUser_Insert, pFecha_Insert);
            END IF;
        END IF;
        RETURN cCodRet;
    END IF;
    END;
END PROCEDURE;