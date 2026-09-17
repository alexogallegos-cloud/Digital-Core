CREATE PROCEDURE "informix".sp_contratocoppel(pempresa CHAR(3), cNumcte CHAR(20), cNumSolicitud CHAR(20))
RETURNING CHAR(5),  CHAR(26), CHAR(26), CHAR(53), CHAR(1),  CHAR(1),   CHAR(1),  CHAR(6),  CHAR(10),
          CHAR(10), CHAR(10), CHAR(10), CHAR(13), CHAR(30), CHAR(6),  CHAR(80),  CHAR(40), CHAR(30), CHAR(20),
          CHAR(30), CHAR(17), CHAR(3),  CHAR(11), CHAR(30), CHAR(10), CHAR(30),  CHAR(60), CHAR(11), CHAR(13),
          CHAR(30), CHAR(20), CHAR(30), CHAR(17), CHAR(1),  CHAR(20), CHAR(107), CHAR(13), CHAR(11), CHAR(5),
          CHAR(6),  CHAR(4),  CHAR(5);

    DEFINE vcodret CHAR(5);
    DEFINE vcliente_ref CHAR(20); --Cliente Coppel
    DEFINE vnombre1 CHAR(26);
    DEFINE vnombre2 CHAR(26);
    DEFINE vapell_paterno CHAR(26);
    DEFINE vapell_materno CHAR(26);
    DEFINE vcolonia SMALLINT;
    DEFINE vcalle INTEGER;
    DEFINE vcasa CHAR(10);
    DEFINE vletrasnumcasa VARCHAR(10);
    DEFINE vcomplemento CHAR(80);
    DEFINE ventrecalles CHAR(40); --
    DEFINE vtelefono CHAR(13);
    DEFINE vtelefonocelular CHAR(13);
    DEFINE vcasapropia CHAR (10);
    DEFINE vsexo CHAR(1);
    DEFINE vestadocivil CHAR(1);
    DEFINE vfechanacimiento DATE;
    DEFINE vfechadesdecuandoviveahi DATE;
    DEFINE vpersonastrabajan SMALLINT;
    DEFINE vlimitecredito SMALLINT;
    DEFINE vingresomensual INTEGER;
    DEFINE vsituacionespecial CHAR(1);
    DEFINE vcreditojoven CHAR(1);
    DEFINE vlugartrabajo CHAR(60);
    DEFINE cEstadoTrabajo CHAR(2);
    DEFINE vcoloniatrabajo CHAR(11);
    DEFINE vciudadtrabajo SMALLINT;
    DEFINE vcalletrabajo INTEGER;
    DEFINE vcasatrabajo CHAR(10);
    DEFINE vletrasnumtrabajo CHAR(13);
    DEFINE vtelefonotrabajo CHAR(13);
    DEFINE vpuesto CHAR(3);
    DEFINE vfechaantiguedadtrabajo DATE;
    DEFINE vnombreunoconyuge CHAR(26);
    DEFINE vnombredosconyuge CHAR(26);
    DEFINE vapellidopaternoconyuge CHAR(26);
    DEFINE vapellidomaternoconyuge CHAR(26);
    DEFINE vciudadAltaSolic SMALLINT;
    DEFINE ventrecallesconyuge CHAR(40);
    DEFINE vtelefonocasareferencia CHAR(13);
    DEFINE vtelefonocelularreferencia CHAR(13);
    DEFINE vtelefonotrabajoreferencia CHAR(13);
    DEFINE vtelefonoreferencia CHAR(13);
    DEFINE vclaveconyugefamilia CHAR(1);
    DEFINE vefectuo CHAR(8);
    DEFINE vtiendafolio CHAR(5) ;
    DEFINE vfechaaltacliente DATE;
    DEFINE vempleadoautorizo INTEGER;
    DEFINE vfechamovto DATE;
    DEFINE vnumerosolicituddecredito CHAR(20);
    DEFINE vclientebancoppel CHAR(20);
    DEFINE vclaveproducto SMALLINT;
    DEFINE cMunicipio CHAR(5);
    DEFINE cDescMunicipio CHAR(30);
    DEFINE cDescMunicipioT CHAR(30);
    DEFINE cMunicipioT CHAR(5);
    DEFINE cNumZona CHAR(17);
    DEFINE cNumZonaT INTEGER;
    DEFINE cPoblacion CHAR(20);
    DEFINE cCteDesde CHAR(10);
    DEFINE iSalarioMinimo INTEGER;
    DEFINE cPoblacionT CHAR(20);
    DEFINE iCiudad INTEGER;
    DEFINE iCiudadT INTEGER;
    DEFINE cCiudad CHAR(25);
    DEFINE cCiudadRef CHAR(15);
    DEFINE cCiudadT CHAR(15);
    DEFINE iEstado INTEGER;
    DEFINE cNom_EmpresaT CHAR(60);
    DEFINE cEmpresa CHAR(60);
    DEFINE cfechanac CHAR(10);
    DEFINE cfechadesdecuandovive CHAR(10);
    DEFINE cfechaantiguedtrab CHAR(10);
    DEFINE cfechaaltacte CHAR (10);
    DEFINE cfechamovto CHAR (10);
    DEFINE dfechasolicitud DATE;
    DEFINE inumerocasa INTEGER;
    DEFINE inumerocasatrabajo INTEGER;
    DEFINE snumerocasaconyugue SMALLINT;
    DEFINE vTipo_Dir CHAR(2);
    DEFINE vFecha_Hoy DATE;
    DEFINE vtiendafolio2 INTEGER;
    DEFINE vNombre CHAR(104);
    DEFINE vEdad INTEGER;
    DEFINE vsSQL LVARCHAR(32000);
    define vnumcte CHAR(20);
    DEFINE iSqlErr INTEGER;
    DEFINE vCodRetorno CHAR(5);
    DEFINE cUnidadHabit CHAR(1);
    DEFINE dFechaResidencia DATE;
    DEFINE dFechaLaborando DATE;
    DEFINE cProfesion CHAR(30);
    DEFINE dFechaAlta DATE;
    DEFINE cSucursalRef CHAR(4);
    DEFINE vclientereferencia2 CHAR(20);
    DEFINE cNombreCalle CHAR(30);
    DEFINE cNombreCalleT CHAR(30);
    DEFINE cColonia CHAR(30);
    DEFINE cColoniaT CHAR(30);
    DEFINE cNombreCompletoConyuge CHAR(107);
    DEFINE cFechaAltaSolicitud CHAR(11);
    DEFINE iIngresoMensual DECIMAL(18,2);
    DEFINE cCredAut INTEGER;
    DEFINE vLimiteCreditoAutori INTEGER;
    DEFINE cPromotor CHAR(45);
    DEFINE iValor INTEGER;
    DEFINE vCiudadAltaSoli CHAR(60);
    DEFINE cEstadoAltaSoli CHAR(2);
    DEFINE cPaisAltaSoli  CHAR(3);
    DEFINE dFecha_Sistema CHAR(10);
    DEFINE cSiglas_Ciudad CHAR(4);
    DEFINE cPunto_cardinal CHAR(5);
    DEFINE cPun_Car        CHAR(1);
    DEFINE vNombres CHAR(53);
    DEFINE cMesFechaAlta CHAR(3);
    DEFINE iSecuencia INTEGER;
    DEFINE cNumCteBanco CHAR(20);

    LET  vcodret = '00000';
    LET vcliente_ref = '';
    LET vnombre1 = '';
    LET vnombre2 = '';
    LET vapell_paterno= '';
    LET vapell_materno = '';
    LET vcolonia = 0;
    LET vcalle = 0;
    LET vcasa = '';
    LET vletrasnumcasa = '';
    LET vcomplemento = '';
    LET ventrecalles = '';
    LET vtelefono = '';
    let vtelefonocelular = '';
    LET vcasapropia = '';
    LET vsexo = '';
    LET vestadocivil = '';
    LET vfechanacimiento = DATE(1);
    LET vfechadesdecuandoviveahi = DATE(1);
    LET vpersonastrabajan = 0;
    LET vlimitecredito ='';
    LET vingresomensual = 0;
    LET vsituacionespecial = '';
    LET vcreditojoven = '';
    LET vlugartrabajo = '';
    LET vciudadtrabajo = 0;
    LET cEstadoTrabajo = '';
    LET vcoloniatrabajo  = '';
    LET vcalletrabajo = 0;
    LET vcasatrabajo  = '';
    LET vletrasnumtrabajo = '';
    LET vtelefonotrabajo = '';
    LET vpuesto = '';
    LET vnombreunoconyuge ='';
    LET vnombredosconyuge ='';
    LET vapellidopaternoconyuge ='';
    LET vapellidomaternoconyuge ='';
    LET vciudadAltaSolic = 0;
    LET ventrecallesconyuge = '';
    LET vtelefonocasareferencia = '';
    LET vtelefonocelularreferencia = '';
    LET vtelefonotrabajoreferencia = '';
    LET vtelefonoreferencia = '';
    LET vclaveconyugefamilia= '';
    LET vefectuo = '0' ;
    LET vtiendafolio = '' ;
    LET vfechaaltacliente = DATE(1);
    LET vempleadoautorizo = 0 ;
    LET vfechamovto = DATE(1) ;
    LET vnumerosolicituddecredito = '';
    LET vclientebancoppel ='';
    LET vclaveproducto =0 ;
    LET cMunicipio  = '';
    LET cDescMunicipio = '';
    LET cDescMunicipioT = '';
    LET cMunicipioT  = '';
    LET cNumZona = '';
    LET cNumZonaT = '';
    LET cPoblacion = '';
    LET cCteDesde = '';
    LET iSalarioMinimo= 0;
    LET cPoblacionT = '';
    LET iCiudad = 0;
    LET cCiudad = '';
    LET cCiudadT = '';
    LET cCiudadRef = '';
    LET iEstado = 0;
    LET cfechanac = '';
    LET cfechadesdecuandovive ='';
    LET cfechaantiguedtrab = '';
    LET cfechaaltacte = '';
    LET  cfechamovto ='';
    LET dfechasolicitud = DATE(1);
    LET inumerocasa = 0;
    LET inumerocasatrabajo = 0;
    LET snumerocasaconyugue = 0;
    LET vTipo_Dir = '';
    LET vFecha_Hoy = DATE(1);
    LET vtiendafolio2 ='';
    LET vNombre ='';
    LET vEdad =0;
    LET vsSQL ='';
    LET vnumcte ='';
    LET iSqlErr =0;
    LET vCodRetorno = '00000';
    LET cUnidadHabit ='';
    LET dFechaResidencia = DATE(1);
    LET dFechaLaborando = DATE(1);
    LET cProfesion= '';
    LET dFechaAlta = DATE(1);
    LET cSucursalRef = '';
    LET vclientereferencia2 = '';
    LET cNombreCalle = '';
    LET cNombreCalleT = '';
    LET cColonia = '';
    LET cColoniaT = '';
    LET cNombreCompletoConyuge = '';
    LET cFechaAltaSolicitud = '';
    LET iIngresoMensual = 0;
    LET cCredAut = 0;
    LET vLimiteCreditoAutori = 0;
    LET cPromotor = '';
    LET iValor = 0;
    LET vCiudadAltaSoli = '';
    LET cEstadoAltaSoli = '';
    LET cPaisAltaSoli = '';
    LET dFecha_Sistema = '';
    LET cNom_EmpresaT = '';
    LET cEmpresa = '';
    LET cSiglas_Ciudad = '';
    LET cPunto_cardinal = '';
    LET cPun_Car = '';
    LET vNombres = '';
    LET cMesFechaAlta = '';
    LEt iSecuencia = 0;
    LET cNumCteBanco = '';

    --SET DEBUG FILE TO '/tmp/sp_ContratoCoppel.out';
    --TRACE ON;

    --------------------------------------------------------------------------
    -- Creado por Rodolfo Tortolero Varela
    --FECHA: 2011-06-10
    --Se consulta toda la información que se va imprimir en el contracto coppel
    --------------------------------------------------------------------------
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET vCodRet = iSqlErr;
            RETURN  vCodret,NVL(vapell_paterno,''),NVL(vapell_materno,''),NVL(vnombres,''),
                    NVL(vsexo,''),NVL(vestadocivil,''),NVL(vsituacionespecial,''),nvl(vpersonastrabajan,0),NVL(cfechanac,'01-01-1900'),
                    NVL(vcasapropia,'P'),NVL(cfechadesdecuandovive,'1995'),NVL(cCteDesde,''),NVL(vtelefono,''),NVL(cNombreCalle,''),
                    NVL(inumerocasa,0),NVL(vcomplemento,''),NVL(ventrecalles,''),NVL(cColonia,''),NVL(cPoblacion,''),
                    NVL(cDescMunicipio,''), cNumZona,NVL(vpuesto,''),NVL(vingresomensual,0),NVL(cProfesion,''), NVL(cfechaantiguedtrab,'1995'),
                    NVL(cNombreCalleT,''),NVL(cNom_EmpresaT,''),NVL(inumerocasatrabajo,0),NVL(vtelefonotrabajo,''), NVL(cColoniaT,''),
                    NVL(cPoblacionT,''),NVL(cDescMunicipioT,''),NVL(cNumZonaT,0),NVL(vclaveconyugefamilia,''),NVL(cNumCteBanco,''),
                    NVL(cNombreCompletoConyuge,''),NVL(vtelefonoreferencia,''),NVL(cFechaAltaSolicitud,'01ENE1900'),NVL(vtiendafolio,''),
                    NVL(vLimiteCreditoAutori,0),NVL(cSiglas_Ciudad,''),NVL(cPunto_cardinal,'');
        END IF;
    END EXCEPTION;

    IF cNumcte <> '' THEN
        SELECT fecha_hoy 
          INTO dFecha_Sistema 
          FROM bdicred:sd_fechas;

        -- Número de solicitud de crédito y el Monto Otorgado
        SELECT num_solicitud, monto_solicitado, fecha_insert, sucursal
          INTO vnumerosolicituddecredito, iIngresoMensual, dFechaAlta, vtiendafolio
          FROM bdisolic:"informix".ss_solicitudes
         WHERE numcte = cNumcte 
           AND num_solicitud = cNumSolicitud
           AND fecha_insert = dFecha_Sistema 
           AND status_solicitud <> 'AN';

        -- Situacion de Crédito e Ingreso Mensual
        SELECT situacion_credito, ingreso_mensual
          INTO vsituacionespecial, vingresomensual
          FROM bdisolic:"informix".ss_resum_scor_fin
         WHERE num_solicitud = vnumerosolicituddecredito;

        SELECT	cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno,
                cte.numcte,cte.ejecut_autoriza,cte.fecha_alta,iden.habita_en,
                iden.sexo,iden.estado_civil,iden.fecha_nac,dir.numerocolonia,dir.numerociudad, dir.numerocalle,
                dir.numeroextcalle, dir.observaciones, dir.entre_calles, TRIM(NVL(tel1.telefono,'')), TRIM(NVL(tel2.telefono,'')),
                dir.municipio,ing.nombre_empresa,ing.clavesubopcionpuesto,cte.fecha_insert,cte.numcte_ref
          INTO 	vnombre1,vnombre2,vapell_paterno,vapell_materno,
                cNumcte,vefectuo,vfechaaltacliente,vcasapropia,
                vsexo,vestadocivil,vfechanacimiento,vcolonia,iCiudad, vcalle,
                vcasa,vcomplemento,ventrecalles,vtelefono,vtelefonocelular,
                cMunicipio,vlugartrabajo,vpuesto,vfechamovto,vcliente_ref
          FROM 	bdinteg:"informix".si_cliente cte
         INNER JOIN  bdinteg:"informix".si_ctepf iden ON ( cte.numcte = iden.numcte )
         INNER JOIN  bdinteg:"informix".si_direcciones_actual dir ON ( cte.numcte = dir.numcte AND dir.tipo_dir = '1' )
         INNER JOIN  bdinteg:"informix".si_ingresos ing ON ( cte.numcte = ing.numcte AND ing.sec_ingreso = ( SELECT MAX(sec_ingreso) 
                                                                                                               FROM bdinteg:si_ingresos 
                                                                                                              WHERE numcte = cNumcte 
                                                                                                                AND tipo_ingreso = 'T' ) )
        LEFT OUTER JOIN si_telefonos_actual tel1 ON ( tel1.numcte = cte.numcte AND tel1.tipo_tel = 1 )
        LEFT OUTER JOIN si_telefonos_actual tel2 ON ( tel2.numcte = cte.numcte AND tel2.tipo_tel = 2 )
        WHERE 	cte.numcte = cNumcte;

        SELECT nombrezona, poblacionzona, municipiozona
          INTO cColonia, cPoblacion, cDescMunicipio
          FROM bdinteg:"informix".si_catzonas
         WHERE numerociudad = iCiudad
           AND numerocolonia = vcolonia;

        LET cNumZona = iCiudad||vcolonia;
        LET vNombres = TRIM(vnombre1)||" "||TRIM(vnombre2);

        -- Ciudad de la Sucursal en cual se dio de Alta la Solicitud
        SELECT pais,estado,ciudad
          INTO cPaisAltaSoli,cEstadoAltaSoli,vciudadAltaSolic
          FROM bdinteg:"informix".si_sucursales
         WHERE sucursal = vtiendafolio;

        SELECT ciudad_coppel
          INTO vCiudadAltaSoli
          FROM bdinteg:"informix".si_ciudades
         WHERE pais = cPaisAltaSoli
           AND estado = cEstadoAltaSoli
           AND ciudad = vciudadAltaSolic;

        SELECT inicialciudad
          INTO cSiglas_Ciudad
          FROM bdinteg:"informix".si_catciudades
         WHERE numerociudad = vCiudadAltaSoli;

        SELECT valor::INTEGER
          INTO iValor
          FROM bdisolic:"informix".ss_param
         WHERE secuencia = 303;

        LET vlimitecredito = (vingresomensual/iValor)::INTEGER;

        IF vlimitecredito > 0.1 AND vlimitecredito < 1 THEN
            LET vlimitecredito = 1;
        END IF;

        EXECUTE PROCEDURE bdinteg:"informix".consedadcte (pempresa, cNumcte) 
        INTO vCodRetorno, vNombre, vEdad;

        --EVALUA SI ES CREDITO JOVEN
        IF vsexo = 'M' THEN
            IF vEdad >= '16' AND vEdad <='20' THEN
                LET vcreditojoven = 'J';
                LET vLimiteCreditoAutori = 1800;
            ELSE
                IF vlimitecredito > 0 THEN
                    IF vlimitecredito = 1 OR (vlimitecredito > 0 AND vlimitecredito < 1) OR (vlimitecredito > 1 and vlimitecredito < 2) OR  vlimitecredito = 2 THEN
                        SELECT creditoautorizado INTO cCredAut FROM bdisolic:"informix".ss_catsmcoppel WHERE limiteinferior = 0 AND limitesuperior = 2;
                        SELECT cantidad INTO vLimiteCreditoAutori FROM bdisolic:"informix".ss_catcacoppel WHERE creditoautorizado = cCredAut;
                    ELIF vlimitecredito = 3 OR vlimitecredito = 4 OR (vlimitecredito > 3 AND vlimitecredito < 4) THEN
                        SELECT creditoautorizado INTO cCredAut FROM bdisolic:"informix".ss_catsmcoppel WHERE limiteinferior = 3 AND limitesuperior = 4;
                        SELECT cantidad INTO vLimiteCreditoAutori FROM bdisolic:"informix".ss_catcacoppel WHERE creditoautorizado = cCredAut;
                    ELIF vlimitecredito = 5 OR vlimitecredito = 6 OR (vlimitecredito > 5 AND vlimitecredito < 6) THEN
                        SELECT creditoautorizado INTO cCredAut FROM bdisolic:"informix".ss_catsmcoppel WHERE limiteinferior = 5 AND limitesuperior = 6;
                        SELECT cantidad INTO vLimiteCreditoAutori FROM bdisolic:"informix".ss_catcacoppel WHERE creditoautorizado = cCredAut;
                    ELIF vlimitecredito = 7 OR vlimitecredito = 8 OR (vlimitecredito > 7 AND vlimitecredito < 8) THEN
                        SELECT creditoautorizado INTO cCredAut FROM bdisolic:"informix".ss_catsmcoppel WHERE limiteinferior = 7 AND limitesuperior = 8;
                        SELECT cantidad INTO vLimiteCreditoAutori FROM bdisolic:"informix".ss_catcacoppel WHERE creditoautorizado = cCredAut;
                    ELIF vlimitecredito = 9 OR vlimitecredito > 9 THEN
                        SELECT creditoautorizado INTO cCredAut FROM bdisolic:"informix".ss_catsmcoppel WHERE limiteinferior = 9 OR limitesuperior > 8;
                        SELECT cantidad INTO vLimiteCreditoAutori FROM bdisolic:"informix".ss_catcacoppel WHERE creditoautorizado = cCredAut;
                    END IF;
                ELSE
                    LET vLimiteCreditoAutori = 1;
                END IF;
            END IF;
        END IF;

        IF  vsexo = 'F' THEN
            IF vEdad >='16' AND vEdad <='17' THEN
                LET vcreditojoven = 'J';
                LET vLimiteCreditoAutori = 1800;
            ELSE
                IF vlimitecredito > 0 THEN
                    IF vlimitecredito = 1 OR (vlimitecredito > 0 AND vlimitecredito < 1) OR (vlimitecredito > 1 and vlimitecredito < 2) OR vlimitecredito = 2 THEN
                        SELECT creditoautorizado INTO cCredAut FROM bdisolic:"informix".ss_catsmcoppel WHERE limiteinferior = 0 AND limitesuperior = 2;
                        SELECT cantidad INTO vLimiteCreditoAutori FROM bdisolic:"informix".ss_catcacoppel WHERE creditoautorizado = cCredAut;
                    ELIF vlimitecredito = 3 OR vlimitecredito = 4 OR (vlimitecredito > 3 AND vlimitecredito < 4) THEN
                        SELECT creditoautorizado INTO cCredAut FROM bdisolic:"informix".ss_catsmcoppel WHERE limiteinferior = 3 AND limitesuperior = 4;
                        SELECT cantidad INTO vLimiteCreditoAutori FROM bdisolic:"informix".ss_catcacoppel WHERE creditoautorizado = cCredAut;
                    ELIF vlimitecredito = 5 OR vlimitecredito = 6 OR (vlimitecredito > 5 AND vlimitecredito < 6) THEN
                        SELECT creditoautorizado INTO cCredAut FROM bdisolic:"informix".ss_catsmcoppel WHERE limiteinferior = 5 AND limitesuperior = 6;
                        SELECT cantidad INTO vLimiteCreditoAutori FROM bdisolic:"informix".ss_catcacoppel WHERE creditoautorizado = cCredAut;
                    ELIF vlimitecredito = 7 OR vlimitecredito = 8 OR (vlimitecredito > 7 AND vlimitecredito < 8) THEN
                        SELECT creditoautorizado INTO cCredAut FROM bdisolic:"informix".ss_catsmcoppel WHERE limiteinferior = 7 AND limitesuperior = 8;
                        SELECT cantidad INTO vLimiteCreditoAutori FROM bdisolic:"informix".ss_catcacoppel WHERE creditoautorizado = cCredAut;
                    ELIF vlimitecredito = 9 OR vlimitecredito > 9 THEN
                        SELECT creditoautorizado INTO cCredAut FROM bdisolic:"informix".ss_catsmcoppel WHERE limiteinferior = 9 OR  limitesuperior > 8;
                        SELECT cantidad INTO vLimiteCreditoAutori FROM bdisolic:"informix".ss_catcacoppel WHERE creditoautorizado = cCredAut;
                    END IF;
                ELSE
                    LET vLimiteCreditoAutori = 1;
                END IF;
            END IF;
        END IF;

        IF vLimiteCreditoAutori > 12600 THEN
            LET vLimiteCreditoAutori = 12600;
        END IF;

        --INGRESO MENSUAL
        LET vingresomensual = (vingresomensual/iValor)::INTEGER;

        IF vingresomensual > 0.1 AND vingresomensual < 1 THEN
            LET vingresomensual = 1;
        END IF;

        LET vpersonastrabajan = 1;
        LET cCtedesde = vfechamovto;

        SELECT nombrecalle
          INTO cNombreCalle
          FROM bdinteg:"informix".si_catcalles
         WHERE numerocalle = vcalle;

        LET cCtedesde = LPAD (MONTH (vfechamovto),2,0)||YEAR(vfechamovto) ;
        LET cfechamovto = YEAR(vfechamovto)||"-"|| LPAD (MONTH (vfechamovto),2,0)||"-"||LPAD(DAY(vfechamovto),2,0);
        LET cfechanac = LPAD (DAY(vfechanacimiento),2,0)||LPAD (MONTH (vfechanacimiento),2,0)||YEAR(vfechanacimiento);

        --DAR FORMATO A NUMERO DE CASA
        EXECUTE PROCEDURE bdinteg:"informix".sp_ConvierteNumerodeCasa(vcasa) 
        INTO vCodRet, inumerocasa, vletrasnumcasa;

        --TIEMPO DE RESIDENCIA
        EXECUTE PROCEDURE bdinteg:"informix".sp_ObtieneTiempoResidencia(cNumcte,'AT')
        INTO vcodret,dFechaResidencia;
        
        LET cfechadesdecuandovive = YEAR(dFechaResidencia);

        --TIEMPO LABORANDO
        EXECUTE PROCEDURE bdinteg:"informix".sp_ObtieneTiempoLaborando(cNumcte,'AT')
        INTO vcodret,dFechaLaborando;
        
        LET cfechaantiguedtrab = YEAR(dFechaLaborando);

        SELECT nombre 
          INTO cPromotor 
          FROM bdinteg:"informix".si_ejecut 
         WHERE ejecutivo = vefectuo;

        -- DATOS DE DIRECCION DE TRABAJO
        SELECT dir.numerocolonia, dir.numerocalle, dir.numeroextcalle,dir.municipio,TRIM(NVL(tel3.telefono3,0)),
               dir.numerociudad, dir.estado, dir.puntocardinal, ing.nombre_empresa
          INTO vcoloniatrabajo,vcalletrabajo,vcasatrabajo,cMunicipioT,vtelefonotrabajo,
               vciudadtrabajo, cEstadoTrabajo,cPun_car,cEmpresa
          FROM bdinteg:"informix".si_cliente cte
         INNER JOIN bdinteg:"informix".si_direcciones_actual dir ON ( cte.numcte = dir.numcte AND dir.tipo_dir = '2' )
         INNER JOIN bdinteg:"informix".si_ingresos ing ON ( cte.numcte = ing.numcte AND ing.tipo_ingreso = 'T' )
          LEFT OUTER JOIN si_telefonos_actual tel3 ON ( tel3.numcte = cte.numcte AND tel3.tipo_tel = 3 )
         WHERE cte.numcte = cNumcte;
        -- AND dir.secuencia = (SELECT NVL (MAX(secuencia),0)FROM bdinteg:"informix".si_direcciones WHERE numcte = cNumcte AND  tipo_dir = '2');

        LET cNom_EmpresaT = TRIM(cEmpresa);
        LET cNumZonaT = vciudadtrabajo||TRIM(vcoloniatrabajo);

        SELECT nombrezona, poblacionzona, municipiozona
          INTO cColoniaT, cPoblacionT, cDescMunicipioT
          FROM bdinteg:"informix".si_catzonas
         WHERE numerociudad = vciudadtrabajo
           AND numerocolonia = vcoloniatrabajo;

        IF trim(cPun_car) = 'N' THEN
            LET cPunto_cardinal	= 'NORTE';
        ELIF trim(cPun_car) = 'S' THEN
            LET cPunto_cardinal	= 'SUR';
        ELIF trim(cPun_car) = 'E' THEN
            LET cPunto_cardinal	= 'ESTE';
        ELIF trim(cPun_car) = 'O' THEN
            LET cPunto_cardinal	= 'OESTE';
        ELIF trim(cPun_car) = ' ' THEN
            LET cPunto_cardinal	= '';
        END IF;

        SELECT nombrecalle
          INTO cNombreCalleT
          FROM bdinteg:"informix".si_catcalles
         WHERE numerocalle = vcalletrabajo;

        --LET cPoblacionT = cDescMunicipioT;
        SELECT nombrecalle
          INTO cNombreCalleT
          FROM bdinteg:"informix".si_catcalles
         WHERE numerocalle = vcalletrabajo;

        --DAR FORMATO A NUMERO DE TRABAJO
        EXECUTE PROCEDURE bdinteg:"informix".sp_ConvierteNumerodeCasa(vcasatrabajo) 
        INTO vCodRet, inumerocasatrabajo, vletrasnumtrabajo;

        --DATOS DE CONYUGE
        IF vestadocivil = 'C' THEN
            SELECT MAX(secuencia) 
              INTO iSecuencia 
              FROM bdinteg:"informix".si_refclientes 
             WHERE numcte = cNumcte 
               AND parentesco = 'E';

            SELECT	sucursal, numcte, nombre1, nombre2, apell_paterno, apell_materno, parentesco, numcte_banco
              INTO	cSucursalRef, vclientereferencia2, vnombreunoconyuge, vnombredosconyuge, vapellidopaternoconyuge,
                    vapellidomaternoconyuge, vclaveconyugefamilia, cNumCteBanco
              FROM 	bdinteg:"informix".si_refclientes
             WHERE 	numcte = cNumcte
               AND	secuencia = iSecuencia;

            SELECT	TRIM(NVL(telefono1,'')),TRIM(NVL(telefono2,'')),TRIM(NVL(telefono3,''))
              INTO	vtelefonocasareferencia, vtelefonocelularreferencia, vtelefonotrabajoreferencia
              FROM	bdinteg:"informix".si_refdirecciones
             WHERE	numcte = cNumcte
               AND	secuencia = iSecuencia;
        ELSE
            SELECT MAX(secuencia) - 1 
              INTO iSecuencia 
              FROM bdinteg:"informix".si_refclientes 
             WHERE numcte = cNumcte;

            SELECT	sucursal, numcte, nombre1, nombre2, apell_paterno, apell_materno, parentesco
              INTO	cSucursalRef, vclientereferencia2, vnombreunoconyuge, vnombredosconyuge, vapellidopaternoconyuge,
                    vapellidomaternoconyuge, vclaveconyugefamilia
              FROM	bdinteg:"informix".si_refclientes
             WHERE	numcte = cNumcte
               AND	secuencia = iSecuencia;

            SELECT	TRIM(NVL(telefono1,'')),TRIM(NVL(telefono2,'')),TRIM(NVL(telefono3,''))
              INTO	vtelefonocasareferencia, vtelefonocelularreferencia, vtelefonotrabajoreferencia
              FROM	bdinteg:"informix".si_refdirecciones
             WHERE	numcte = cNumcte
               AND	secuencia = iSecuencia;
        END IF;

        IF vtelefonotrabajoreferencia IS NULL OR vtelefonotrabajoreferencia = '' THEN
            IF vtelefonocasareferencia IS NULL OR vtelefonocasareferencia = '' THEN
                IF vtelefonocelularreferencia IS NULL OR vtelefonocelularreferencia = '' THEN
                    LET vtelefonocelularreferencia = '';
                ELSE
                    LET vtelefonoreferencia = vtelefonocelularreferencia;
                END IF;
            ELSE
                LET vtelefonoreferencia = vtelefonocasareferencia;
            END IF;
        ELSE
            LET vtelefonoreferencia = vtelefonotrabajoreferencia;
        END IF;

        --FORMATO A FECHAS
        IF LPAD (MONTH (dFechaAlta),2,0) = '01' THEN
            LET cMesFechaAlta = 'ENE';
        ELIF LPAD (MONTH (dFechaAlta),2,0) = '02' THEN
            LET cMesFechaAlta = 'FEB';
        ELIF LPAD (MONTH (dFechaAlta),2,0) = '03' THEN
            LET cMesFechaAlta = 'MAR';
        ELIF LPAD (MONTH (dFechaAlta),2,0) = '04' THEN
            LET cMesFechaAlta = 'ABR';
        ELIF LPAD (MONTH (dFechaAlta),2,0) = '05' THEN
            LET cMesFechaAlta = 'MAY';
        ELIF LPAD (MONTH (dFechaAlta),2,0) = '06' THEN
            LET cMesFechaAlta = 'JUN';
        ELIF LPAD (MONTH (dFechaAlta),2,0) = '07' THEN
            LET cMesFechaAlta = 'JUL';
        ELIF LPAD (MONTH (dFechaAlta),2,0) = '08' THEN
            LET cMesFechaAlta = 'AGO';
        ELIF LPAD (MONTH (dFechaAlta),2,0) = '09' THEN
            LET cMesFechaAlta = 'SEP';
        ELIF LPAD (MONTH (dFechaAlta),2,0) = '10' THEN
            LET cMesFechaAlta = 'OCT';
        ELIF LPAD (MONTH (dFechaAlta),2,0) = '11' THEN
            LET cMesFechaAlta = 'NOV';
        ELIF LPAD (MONTH (dFechaAlta),2,0) = '12' THEN
            LET cMesFechaAlta = 'DIC';
        END IF;
    
        IF dFechaAlta  = '01-01-1900' OR dFechaAlta = '' THEN
            LET cFechaAltaSolicitud = '';
        ELSE
            LET cFechaAltaSolicitud = LPAD(DAY(dFechaAlta),2,0)||cMesFechaAlta||YEAR(dFechaAlta);
        END IF;
    
        LET cNombreCompletoConyuge = TRIM(vnombreunoconyuge)||" "||TRIM(vnombredosconyuge)||" "||TRIM(vapellidopaternoconyuge)||" "||TRIM(vapellidomaternoconyuge);
    
        IF cNumCteBanco IS NULL THEN
            LET cNumCteBanco = '';
        END IF;
        
    ELSE
    
        LET vCodRet = '00001';
        
    END IF;
    
    RETURN  vCodret,NVL(vapell_paterno,''),NVL(vapell_materno,''),NVL(vnombres,''),
            NVL(vsexo,''),NVL(vestadocivil,''),NVL(vsituacionespecial,''),nvl(vpersonastrabajan,0),NVL(cfechanac,'01-01-1900'),
            NVL(vcasapropia,'P'),NVL(cfechadesdecuandovive,'1995'),NVL(cCteDesde,''),NVL(vtelefono,''),NVL(cNombreCalle,''),
            NVL(inumerocasa,0),NVL(vcomplemento,''),NVL(ventrecalles,''),NVL(cColonia,''),NVL(cPoblacion,''),
            NVL(cDescMunicipio,''), cNumZona,NVL(vpuesto,''),NVL(vingresomensual,0),NVL(cProfesion,''), NVL(cfechaantiguedtrab,'1995'),
            NVL(cNombreCalleT,''),NVL(cNom_EmpresaT,''),NVL(inumerocasatrabajo,0),NVL(vtelefonotrabajo,''), NVL(cColoniaT,''),
            NVL(cPoblacionT,''),NVL(cDescMunicipioT,''),NVL(cNumZonaT,0),NVL(vclaveconyugefamilia,''),NVL(cNumCteBanco,''),
            NVL(cNombreCompletoConyuge,''),NVL(vtelefonoreferencia,''),NVL(cFechaAltaSolicitud,'01ENE1900'),NVL(vtiendafolio,''),
            NVL(vLimiteCreditoAutori,0),NVL(cSiglas_Ciudad,''),NVL(cPunto_cardinal,'');
    
    END;
    
END PROCEDURE;