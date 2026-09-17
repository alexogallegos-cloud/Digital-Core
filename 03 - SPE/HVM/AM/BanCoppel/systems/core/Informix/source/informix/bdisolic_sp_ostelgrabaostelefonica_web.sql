CREATE PROCEDURE "informix".sp_ostelgrabaostelefonica_web( pEmpresa char(3), 
                                                       pSolicitudUno char(20), 
                                                       pSolicitudDos char(20), 
                                                       pReferenciaUno integer, 
                                                       pReferenciaDos integer )
returning char(5);

-- 27/12/2008
-- Bernardo Carlos BÃÂ¡ez GonzÃÂ¡lez
-- Generacion de Os Telefonica guardando en ss_ostelrefsolicitud, ss_osclientesupervisartel, ss_osteltelefonos y ss_ostelreferencias
---ModificÃÂ³ : Lorenzo Ibarra GarcÃÂ­a
--Fecha: 26-10-2009
--Se agregaron validaciones para los datos de entrada
--Se modificÃÂ³ para obtener los datos de las referencias por medio de un ciclo
--Se modificÃÂ³ para cuando el cliente no viva en unidad habitacional no se ejecuten los querys que obtienen los datos de esta.
---ModificÃÂ³ : JesÃÂºs Manuel Aguilar Heredia
--Fecha: 03-11-2010
--Se agrega la actualizacion de un campo en la tabla ss_osclientesupervisartel
---ModificÃÂ³ : Antonio Bastiads
--Fecha: 17-12-2010
--Se elimina la extension para telefonos de referencias, execptuando solo el de Oficina

define cBegin char(1);

define cTrama char(7500);
define SQL_ERR integer;
define vCod_Ret char(5);
define iSecuencia integer;
define cSolicitud char(20);
define cManzana char(30);
define cOtros char(30);
define cAndador char(30);
define cEtapa char(30);
define cLote char(30);
define cEdificio char(30);
define cEntrada char(30);
define iSecuenciaTelefono integer;
define cTelefono char(13);
define cTelefono1 char(13);
define cTelefono2 char(13);
define cTelefono3 char(13);
define cDestino char(1);
define cTipo char(1);
define cExtension char(5);
define vLugartrabajo char(60);
define vEstadotrabajo char(5);
define vEstadotrabajo_nombre char(30);
define vMunicipiotrabajo char(5);
define vMunicipiotrabajo_nombre char(30);
define vNumerociudadtrabajo smallint;
define vCiudadtrabajo_nombre char(15);
define vColoniatrabajo integer;
define vColoniatrabajo_nombre char(60);
define vCalletrabajo integer;
define vCalletrabajo_nombre char (40);
define vNumeroextcalletrabajo char(10);
define vnombre1conyuge char(26);
define vnombre2conyuge char(26);
define vapell_paternoconyuge char(26);
define vapell_maternoconyuge char(26);
define vnumcte_banco char(20);
define vFecha date;
define iMANZANA integer;
define iOTROS integer;
define iANDADOR integer;
define iETAPA integer;
define iLOTE integer;
define iEDIFICIO integer;
define iENTRADA integer;
define iclavepuesto integer;
define vNumcte char(20);
define vNombre1 char(26);
define vNombre2 char(26);
define vApell_paterno char(26);
define vApell_materno char(26);
define vNumerocalle integer;
define vNumeroextcalle char(10);
define vNumerocolonia integer;
define vMunicipio char(5);
define vCiudad char(3);
define vPais char(3);
define vEstado char(2);
define vCod_postal char(5);
define vUnidadhabitac char(1);
define vManzana smallint;
define vOtros smallint;
define vAndador smallint;
define vEtapa smallint;
define vLote smallint;
define vEdificio smallint;
define vEntrada smallint;
define vMunicipioNombre char(30);
define vNumerociudad integer;
define vNombreCiudad char(15);
define vAntiguedadCiudad char(1);
define vNombreColonia char(60);
define vNombreCalle char(40);
define vCiudadTrabajo char(3);
define vPaisTrabajo char(3);
define vParentesco char(2);
define vNombreestado char(25);
define vDescripcionParentesco char(20);
define cSucursal char(4);
define cGenera_os_telefonica char(1);

DEFINE bExisteSolicitud BOOLEAN;
DEFINE iNumeroReferenciaObtener INTEGER;
DEFINE bContinuarCiclo BOOLEAN;
DEFINE wBegin CHAR(1);

--Set debug file to '/tmp/sp_OSTelGrabaOsTelefonica.out';
--trace on;

let iMANZANA = 1;
let iOTROS = 2;
let iANDADOR = 3;
let iETAPA = 4;
let iLOTE = 5;
let iEDIFICIO = 6;
let iENTRADA = 7;
Let vCod_Ret = '00000';
let cBegin = '';
let cSolicitud = '';
let cManzana = '';
let cOtros = '';
LET cAndador = '';
let cEtapa = '';
let cLote = '';
let cEdificio = '';
let cManzana = '';
let cEntrada = '';
let cTelefono = '';
let cTelefono1 = '';
let cTelefono2 = '';
let cTelefono3 = '';
let cExtension = '';
let cTrama = '';
let vLugartrabajo = '';
let vEstadotrabajo = '';
let vEstadotrabajo_nombre = '';
let vMunicipiotrabajo = '';
let vMunicipiotrabajo_nombre = '';
let vNumerociudadtrabajo = '';
let vCiudadtrabajo_nombre = '';
let vColoniatrabajo = '';
let vColoniatrabajo_nombre = '';
let vCalletrabajo = '';
let vCalletrabajo_nombre = '';
let vNumeroextcalletrabajo = '';
let vnumcte_banco = '';
let vnombre1conyuge = '';
let vnombre2conyuge = '';
let vapell_paternoconyuge = '';
let vapell_maternoconyuge = '';
let vFecha = current;
let iclavepuesto = 0;
let vNumcte = '';
let vNombre1 = '';
let vNombre2 = '';
let vApell_paterno = '';
let vApell_materno = '';
let vNumerocalle = 0;
let vNumeroextcalle = '';
let vMunicipio = '';
let vCiudad = '';
let vPais = '';
let vEstado = '';
let vCod_postal = '';
let vUnidadhabitac = '';
let vManzana = 0;
let vOtros = 0;
let vAndador = 0;
let vEtapa = 0;
let vLote = 0;
let vEdificio = 0;
let vEntrada = 0;
let vMunicipioNombre = '';
let vNumerociudad = 0;
let vNombreCiudad = '';
let vAntiguedadCiudad = '';
let vNumeroColonia = 0;
let vNombreColonia = '';
let vNombreCalle = '';
let vCiudadTrabajo = '';
let vPaisTrabajo = '';
let vParentesco = '';
let vNombreestado = '';
let vDescripcionParentesco = '';
let iSecuencia = 0;
let cSucursal = '';
let cGenera_os_telefonica = 'F';

LET bExisteSolicitud = 'f';
LET iNumeroReferenciaObtener = 0;
LET bContinuarCiclo = 'f';

BEGIN
    ON EXCEPTION SET SQL_ERR
        IF SQL_ERR <> 0 THEN
            LET vCod_Ret = SQL_ERR;
            DELETE {+INDEX("informix".ss_ostelrefsolicitud secuenciaostel_idx)} FROM "informix".ss_ostelrefsolicitud WHERE secuenciaostel = iSecuencia;
            DELETE {+INDEX("informix".ss_ostelrefsolicitud_pendientes idx_secuenciaostel_pend)} FROM "informix".ss_ostelrefsolicitud_pendientes WHERE secuenciaostel = iSecuencia;
            DELETE FROM "informix".ss_osclientesupervisartel WHERE secuenciaostel = iSecuencia;
            DELETE {+INDEX("informix".ss_osteltelefonos idx_secuenciaostel)} FROM "informix".ss_osteltelefonos WHERE secuenciaostel = iSecuencia;
            DELETE {+INDEX("informix".ss_ostelreferencias idx_secostelref)} FROM "informix".ss_ostelreferencias WHERE secuenciaostel = iSecuencia;
            DELETE FROM "informix".ss_osclientesupervisartel_xml WHERE secuenciaostel = iSecuencia;
            RETURN vCod_Ret;
        END IF;
    END EXCEPTION;

    ON EXCEPTION IN (-535)
      LET wBegin = "S";
      COMMIT WORK;
      BEGIN WORK;
    END EXCEPTION WITH RESUME;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 10;

    --verificar que los datos sean correctos
    IF TRIM(pEmpresa) = '' OR pEmpresa IS NULL OR
        pSolicitudUno IS NULL OR pSolicitudDos IS NULL OR
        pReferenciaUno IS NULL OR pReferenciaUno <= 0 OR
        pReferenciaDos IS NULL OR pReferenciaDos <= 0 THEN

        let vCod_Ret = '00001';
        let cTrama = 'AL MENOS UNO DE LOS PARAMETROS ES INVALIDO';
        RETURN vCod_Ret;
    END IF;

    --verificar que al menos se haya recibido un nÃÂºmero de solicitud
    IF TRIM(pSolicitudUno) = '' AND TRIM(pSolicitudDos) = '' THEN
        let vCod_Ret = '00002';
        let cTrama = 'NO SE RECIBIERON NUMEROS DE SOLICITUD VALIDOS';
        RETURN vCod_Ret;
    END IF;    

    LET wBegin = "N";

    begin work;

        update bdinteg:"informix".si_param set valor = cast(valor as integer) + 1 where empresa = pEmpresa and cod_param = 123;
        SELECT cast(valor as integer) INTO iSecuencia FROM bdinteg:"informix".si_param where empresa = pEmpresa and cod_param = 123;

    commit work;

    if wBegin = 'S' THEN
       begin work;
    end if;

    --Insertar en ss_ostelrefsolicitud
    if(SELECT {+INDEX("informix".ss_solicitudes empsol)} num_solicitud from "informix".ss_solicitudes where empresa = pEmpresa and num_solicitud = pSolicitudUno) > 0 then

        LET bExisteSolicitud = 't';

        insert into "informix".ss_ostelrefsolicitud (num_solicitud, num_referencia, secuenciaostel, resultadofinal)
        values (pSolicitudUno, pReferenciaUno, iSecuencia, '');

        insert into "informix".ss_ostelrefsolicitud_pendientes (num_solicitud, num_referencia, secuenciaostel, resultadofinal)
        values (pSolicitudUno, pReferenciaUno, iSecuencia, '');

        if pReferenciaDos > 0 then

            insert into "informix".ss_ostelrefsolicitud (num_solicitud, num_referencia, secuenciaostel, resultadofinal)
            values (pSolicitudUno, pReferenciaDos, iSecuencia, '');

            insert into "informix".ss_ostelrefsolicitud_pendientes (num_solicitud, num_referencia, secuenciaostel, resultadofinal)
            values (pSolicitudUno, pReferenciaDos, iSecuencia, '');

        end if;
    end if;

    if(SELECT {+INDEX("informix".ss_solicitudes empsol)} num_solicitud from "informix".ss_solicitudes where empresa = pEmpresa and num_solicitud = pSolicitudDos) > 0 then

        LET bExisteSolicitud = 't';

        insert into "informix".ss_ostelrefsolicitud (num_solicitud, num_referencia, secuenciaostel, resultadofinal)
        values (pSolicitudDos, pReferenciaUno, iSecuencia, '');

        insert into "informix".ss_ostelrefsolicitud_pendientes (num_solicitud, num_referencia, secuenciaostel, resultadofinal)
        values (pSolicitudDos, pReferenciaUno, iSecuencia, '');

            if pReferenciaDos > 0 then

            insert into "informix".ss_ostelrefsolicitud (num_solicitud, num_referencia, secuenciaostel, resultadofinal)
            values (pSolicitudDos, pReferenciaDos, iSecuencia, '');

            insert into "informix".ss_ostelrefsolicitud_pendientes (num_solicitud, num_referencia, secuenciaostel, resultadofinal)
            values (pSolicitudDos, pReferenciaDos, iSecuencia, '');

        end if;
    end if;

    --verificar si ninguna de las solicitudes proporcionadas existe.
    IF bExisteSolicitud = 'f' THEN
        let vCod_Ret = '00003';
        let cTrama = 'LOS NUMEROS DE SOLICITUD NO EXISTEN';
        DELETE {+INDEX("informix".ss_ostelrefsolicitud secuenciaostel_idx)} FROM "informix".ss_ostelrefsolicitud WHERE secuenciaostel = iSecuencia;
        DELETE {+INDEX("informix".ss_ostelrefsolicitud_pendientes idx_secuenciaostel_pend)} FROM "informix".ss_ostelrefsolicitud_pendientes WHERE secuenciaostel = iSecuencia;
        RETURN vCod_Ret;
    END IF;

    if pSolicitudUno <> '' then
        let cSolicitud = pSolicitudUno;
    else
        let cSolicitud = pSolicitudDos;
    End if;

    --obtener nÃÂºmero de cliente asignado y sucursal donde fueron las solicitudes
    select numcte, sucursal
    into vNumcte, cSucursal
    from "informix".ss_solicitudes
    where empresa = pEmpresa
    and num_solicitud = cSolicitud;

    --obtener nombre del cliente
    select nombre1, nombre2, apell_paterno, apell_materno
    into vNombre1, vNombre2, vApell_paterno, vApell_materno
    from bdinteg:"informix".si_cliente
    where numcte = vNumcte
    and empresa = pEmpresa;

    --obtener direccion del cliente
    select dir.numerocalle, dir.numeroextcalle, dir.numerocolonia, dir.municipio, dir.ciudad, dir.pais, dir.estado, dir.cod_postal, dir.unidadhabitac,
           dir.manzana, dir.otros, dir.andador, dir.etapa, dir.lote, dir.edificio, dir.entrada, dir.numerociudad,
           case when length(trim(tel1.telefono)) > 10 then substr(trim(tel1.telefono),length(trim(tel1.telefono))-9,10) else tel1.telefono end,
           case when length(trim(tel2.telefono)) > 10 then substr(trim(tel2.telefono),length(trim(tel2.telefono))-9,10) else tel2.telefono end
    into vNumerocalle, vNumeroextcalle, vNumerocolonia, vMunicipio, vCiudad, vPais, vEstado, vCod_postal, vUnidadhabitac,
         vManzana, vOtros, vAndador, vEtapa, vLote, vEdificio, vEntrada, vNumerociudad,
         cTelefono1, cTelefono2
    from bdinteg:"informix".si_direcciones_actual dir
    left outer join bdinteg:"informix".si_telefonos_actual tel1 on ( tel1.numcte = dir.numcte and tel1.tipo_tel = 1 )
    left outer join bdinteg:"informix".si_telefonos_actual tel2 on ( tel2.numcte = dir.numcte and tel2.tipo_tel = 2 )
    where dir.numcte = vNumcte
    and dir.tipo_dir = 1;    

    select nombre
    into vNombreestado
    from bdinteg:"informix".si_estados
    where estado = vEstado;

    select nombre
    into vMunicipioNombre
    from bdinteg:"informix".si_municipios
    where pais = vPais
    and ciudad = vCiudad
    and estado = vEstado
    and municipio = vMunicipio;

    select nombreciudad
    into vNombreCiudad
    from bdinteg:"informix".si_catciudades
    where numerociudad = vNumerociudad;

    SELECT {+INDEX("informix".ss_scoring_porcentajes_ciudad idx_ss_scoring_porcentajes_ciudad)} ciudadantigua
    INTO vAntiguedadCiudad
    FROM "informix".ss_scoring_porcentajes_ciudad
    WHERE numerociudad = vNumerociudad;

    select nombrezona
    into vNombreColonia
    from bdinteg:"informix".si_catzonas
    where numerocolonia = vNumerocolonia
    and numerociudad = vNumerociudad;

    select nombrecalle
    into vNombreCalle
    from bdinteg:"informix".si_catcalles
    where numerocalle = vNumerocalle;

    --insertar en ss_osclientesupervisartel
    insert into "informix".ss_osclientesupervisartel(secuenciaostel, numcte, nombre1, nombre2, apell_paterno, apell_materno, calle,
        calle_nombre, numeroextcalle, colonia, colonia_nombre, municipio, municipio_nombre, numerociudad, ciudad_nombre, pais,
        estado, estado_nombre, cod_postal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, enviada,
        fecha_insert, ciudadantigua)
    values(iSecuencia, vNumcte, vNombre1, vNombre2, vApell_paterno, vApell_materno, vNumerocalle,
        vNombreCalle, vNumeroextcalle, vNumerocolonia, vNombreColonia, vMunicipio, vMunicipioNombre, vNumerociudad, vNombreCiudad, vPais,
        vEstado, vNombreestado, vCod_postal, vUnidadhabitac,vManzana, vOtros, vAndador, vEtapa, vLote, vEdificio, vEntrada,'0',
    current, vAntiguedadCiudad);

    --obtiene datos de trabajo
    select dir.estado, dir.municipio, dir.numerociudad, dir.numerocolonia, dir.numerocalle, dir.numeroextcalle, dir.ciudad, dir.Pais,
           case when length(trim(tel3.telefono)) > 10 then substr(trim(tel3.telefono),length(trim(tel3.telefono))-9,10) else tel3.telefono end, tel3.extension
    into vEstadotrabajo, vMunicipiotrabajo, vNumerociudadtrabajo, vColoniatrabajo, vCalletrabajo, vNumeroextcalletrabajo, vCiudadTrabajo, vPaisTrabajo, 
         cTelefono3, cExtension
    from bdinteg:"informix".si_direcciones_actual dir
    left outer join bdinteg:"informix".si_telefonos_actual tel3 on ( tel3.numcte = dir.numcte and tel3.tipo_tel = 3 )
    where dir.numcte = vNumcte
    and dir.tipo_dir = 2;    

    select nombre
    into vEstadotrabajo_nombre
    from bdinteg:"informix".si_estados
    where estado = vEstadotrabajo;

    select nombre
    into vMunicipiotrabajo_nombre
    from bdinteg:"informix".si_municipios
    where pais = vPaisTrabajo
    and ciudad = vCiudadTrabajo
    and estado = vEstadotrabajo
    and municipio = vMunicipiotrabajo;

    select nombreciudad
    into vCiudadtrabajo_nombre
    from bdinteg:"informix".si_catciudades
    where numerociudad = vNumerociudadtrabajo;

    select nombrezona
    into vColoniatrabajo_nombre
    from bdinteg:"informix".si_catzonas
    where numerocolonia = vColoniatrabajo
    and numerociudad = vNumerociudadtrabajo;

    select {+ INDEX (bdinteg:"informix".si_catcalles idx_catcalles)} nombrecalle
    into vCalletrabajo_nombre
    from bdinteg:"informix".si_catcalles
    where numerocalle = vCalletrabajo;

    --obtener un 1 si los datos del trabajo son del conyuge
    select nombre_empresa, case when clavepuesto = 0 then '1' else '0' end as clavepuesto
    into vLugartrabajo, iclavepuesto
    from bdinteg:"informix".si_ingresos
    where numcte = vNumcte
    and sec_ingreso = (select max(sec_ingreso) from bdinteg:si_ingresos where numcte = vNumcte);

    --obtener nombre del conyuge si este es alguna de las dos referencias
    select {+ INDEX (bdinteg:si_refclientes idx_si_refclientes2)} numcte_banco, apell_paterno, apell_materno, nombre1, nombre2
    into vnumcte_banco, vapell_paternoconyuge, vapell_maternoconyuge, vnombre1conyuge, vnombre2conyuge
    from bdinteg:"informix".si_refclientes
    where secuencia = pReferenciaUno
	AND parentesco ='E';

    if vnumcte_banco is null then
        let vnumcte_banco = '';
    end if;

    if trim(vnumcte_banco) = '' then
        select {+ INDEX (bdinteg:"informix".si_refclientes idx_si_refclientes2)} numcte_banco, apell_paterno, apell_materno, nombre1, nombre2
        into vnumcte_banco, vapell_paternoconyuge, vapell_maternoconyuge, vnombre1conyuge, vnombre2conyuge
        from bdinteg:"informix".si_refclientes
        where secuencia = pReferenciaDos
		AND parentesco ='E';

        if vnumcte_banco is null then
            let vnumcte_banco = '';
        end if;

        if trim(vnumcte_banco) = '' then
            let vapell_paternoconyuge = '';
            let vapell_maternoconyuge = '';
            let vnombre1conyuge = '';
            let vnombre2conyuge = '';
        end if;
    end if;

    --obtener datos de unidad habitacional del cliente si este vive en una
    IF vUnidadhabitac = 'S' THEN

            --obtiene manzana
        select nombredomicilio
        into cManzana
        from bdinteg:"informix".si_catdomicilios a, "informix".ss_osclientesupervisartel b
        where  a.clavedomicilio = iMANZANA
        and a.numerocolonia =  b.colonia
        and a.numerociudad =  b.numerociudad
        and a.complementoclave =  b.manzana
        and b.unidadhabitac = 'S'
        and b.secuenciaostel = iSecuencia;
            --obtiene otros
        select nombredomicilio
        into cOtros
        from bdinteg:"informix".si_catdomicilios a, "informix".ss_osclientesupervisartel b
        where b.unidadhabitac = 'S'
        and b.secuenciaostel = iSecuencia
        and a.clavedomicilio = iOTROS
        and a.numerocolonia =  b.colonia
        and a.numerociudad =  b.numerociudad
        and a.complementoclave =  b.otros;
            --obtiene andador
        select nombredomicilio
        into cAndador
        from bdinteg:"informix".si_catdomicilios a, "informix".ss_osclientesupervisartel b
        where b.unidadhabitac = 'S'
        and b.secuenciaostel = iSecuencia
        and a.clavedomicilio = iANDADOR
        and a.numerocolonia =  b.colonia
        and a.numerociudad =  b.numerociudad
        and a.complementoclave =  b.andador;
            --obtiene Etapa
        select nombredomicilio
        into cEtapa
        from bdinteg:"informix".si_catdomicilios a, "informix".ss_osclientesupervisartel b
        where b.unidadhabitac = 'S'
        and b.secuenciaostel = iSecuencia
        and a.clavedomicilio = iETAPA
        and a.numerocolonia =  b.colonia
        and a.numerociudad =  b.numerociudad
        and a.complementoclave =  b.etapa;
            --obtiene lote
        select nombredomicilio
        into cLote
        from bdinteg:"informix".si_catdomicilios a, "informix".ss_osclientesupervisartel b
        where b.unidadhabitac = 'S'
        and b.secuenciaostel = iSecuencia
        and a.clavedomicilio = iLOTE
        and a.numerocolonia =  b.colonia
        and a.numerociudad =  b.numerociudad
        and a.complementoclave =  b.lote;
            -- obtiene edificio
        select nombredomicilio
        into cEdificio
        from bdinteg:"informix".si_catdomicilios a, "informix".ss_osclientesupervisartel b
        where b.unidadhabitac = 'S'
        and b.secuenciaostel = iSecuencia
        and a.clavedomicilio = iEDIFICIO
        and a.numerocolonia =  b.colonia
        and a.numerociudad =  b.numerociudad
        and a.complementoclave =  b.edificio;
            -- obtiene entrada
        select  nombredomicilio
        into cEntrada
        from bdinteg:"informix".si_catdomicilios a, "informix".ss_osclientesupervisartel b
        where b.unidadhabitac = 'S'
        and b.secuenciaostel = iSecuencia
        and a.clavedomicilio = iENTRADA
        and a.numerocolonia =  b.colonia
        and a.numerociudad =  b.numerociudad
        and a.complementoclave =  b.entrada;
    END IF;

    -- actualiza datos de unidad habitacional, conyuge y trabajo en ss_osclientesupervisartel
    update "informix".ss_osclientesupervisartel set manzana_nombre = nvl(cManzana,''), otros_nombre = nvl(cOtros,''),
    andador_nombre = nvl(cAndador,''), etapa_nombre = nvl(cEtapa,''), lote_nombre = nvl(cLote,''),
    edificio_nombre = nvl(cEdificio,''), entrada_nombre = nvl(cEntrada,''), Lugartrabajo = nvl(vLugartrabajo,''),
    Estadotrabajo = nvl(vEstadotrabajo,''), Estadotrabajo_nombre = nvl(vEstadotrabajo_nombre,''),
    Municipiotrabajo = nvl(vMunicipiotrabajo,''), Municipiotrabajo_nombre = nvl(vMunicipiotrabajo_nombre,''),
    Numerociudadtrabajo = nvl(vNumerociudadtrabajo,''), Ciudadtrabajo_nombre = nvl(vCiudadtrabajo_nombre,''),
    Coloniatrabajo = nvl(vColoniatrabajo,''), Coloniatrabajo_nombre = nvl(vColoniatrabajo_nombre,''),
    Calletrabajo = nvl(vCalletrabajo,''), Calletrabajo_nombre = nvl(vCalletrabajo_nombre,''),
    Numeroextcalletrabajo = nvl(vNumeroextcalletrabajo,''), nombre1conyuge = nvl(vnombre1conyuge,''),
    nombre2conyuge = nvl(vnombre2conyuge,''), apell_paternoconyuge = nvl(vapell_paternoconyuge,''),
    apell_maternoconyuge = nvl(vapell_maternoconyuge,''),conyugetrabaja = nvl(iclavepuesto,'')
    where secuenciaostel = iSecuencia;

    -- inserta telefono del cliente casa
    if trim(cTelefono1) <> '' and cTelefono1 is not null then
        insert into "informix".ss_osteltelefonos ( secuenciaostel, secuencia,
            secuenciatelefono, destino, tipo_telef, telefono, extension, fecha_insert)
        values (iSecuencia, '0',
            nvl((select {+ INDEX (idx_secuenciaostel)} max(secuenciatelefono) + 1 from ss_osteltelefonos where secuenciaostel = iSecuencia),1),
           '1','2', cTelefono1,'', current);
    end if
  
    -- inserta telefono del cliente celular
    if trim(cTelefono2) <> '' and cTelefono2 is not null then
        insert into "informix".ss_osteltelefonos ( secuenciaostel, secuencia,
            secuenciatelefono, destino, tipo_telef, telefono, extension, fecha_insert)
        values (iSecuencia, '0',
            nvl((select {+ INDEX (idx_secuenciaostel)} max(secuenciatelefono) + 1 from ss_osteltelefonos where secuenciaostel = iSecuencia),1),
           '2','1', cTelefono2,'', current);
    end if

    -- inserta telefono del cliente trabajo
    if trim(cTelefono3) <> '' and cTelefono3 is not null then
        insert into "informix".ss_osteltelefonos ( secuenciaostel, secuencia,
            secuenciatelefono, destino, tipo_telef, telefono, extension, fecha_insert)
        values (iSecuencia, '0',
            nvl((select {+ INDEX (idx_secuenciaostel)} max(secuenciatelefono) + 1 from ss_osteltelefonos where secuenciaostel = iSecuencia),1),
           '3','2', cTelefono3, cExtension, current);
    end if;

    --obtener datos de las referencias    
    LET iNumeroReferenciaObtener = pReferenciaUno;
    LET bContinuarCiclo = 't';
    
    WHILE bContinuarCiclo = 't'
        
        --verificar si es el total de referencias para indicarle al ciclo que se detenga
        IF iNumeroReferenciaObtener = pReferenciaDos THEN
            LET bContinuarCiclo = 'f';
        END IF;
        
        let cTelefono1 = '';
        let cTelefono2 = '';
        let cTelefono3 = '';
        let cExtension = '';
        let vNumcte = '';
        let vApell_paterno = '';
        let vApell_materno = '';
        let vNombre1 = '';
        let vNombre2 = '';
        let vPais = '';
        let vEstado = '';
        let vCiudad = '';
        let vMunicipio = '';
        let vNumeroColonia = 0;
        let vNumerocalle = 0;
        let vNumeroextcalle = '';
        let vUnidadhabitac = '';
        let vManzana = 0;
        let vOtros = 0;
        let vAndador = 0;
        let vEtapa = 0;
        let vLote = 0;
        let vEdificio = 0;
        let vEntrada = 0;
        let vNumerociudad = 0;
        let vNombreestado = '';
        let vNombreCalle = '';
        let vNombreColonia = '';
        let vMunicipioNombre = '';
        let vNombreCiudad = '';

        select {+ INDEX (bdinteg:"informix".si_refclientes idx_si_refclientes2)} numcte, apell_paterno, apell_materno, nombre1, nombre2, parentesco
        into vNumcte, vApell_paterno, vApell_materno, vNombre1, vNombre2, vParentesco
        from bdinteg:"informix".si_refclientes
        where secuencia = iNumeroReferenciaObtener;

        select case when length(trim(telefono1)) > 10 then substr(trim(telefono1),length(trim(telefono1))-9,10) else telefono1 end,
            case when length(trim(telefono2)) > 10 then substr(trim(telefono2),length(trim(telefono2))-9,10) else telefono2 end,
            case when length(trim(telefono3)) > 10 then substr(trim(telefono3),length(trim(telefono3))-9,10) else telefono3 end,
            extension, pais, estado, ciudad, municipio, numerocolonia, numerocalle, numeroextcalle, unidadhabitac, manzana,
            otros, andador, etapa, lote, edificio, entrada, numerociudad
        into cTelefono1, cTelefono2, cTelefono3,
            cExtension, vPais, vEstado, vCiudad, vMunicipio, vNumeroColonia, vNumerocalle, vNumeroextcalle, vUnidadhabitac, vManzana,
            vOtros, vAndador, vEtapa, vLote, vEdificio, vEntrada, vNumerociudad
        from bdinteg:"informix".si_refdirecciones
        where numcte = vNumcte
        and secuencia = iNumeroReferenciaObtener;

        select nombre
        into vNombreestado
        from bdinteg:"informix".si_estados
        where estado = vEstado;


        select nombrecalle
        into vNombreCalle
        from bdinteg:"informix".si_catcalles
        where numerocalle = vNumerocalle;

        select descripcion
        into vDescripcionParentesco
        from bdinteg:"informix".si_parentesco
        where empresa = pEmpresa
        and parentesco = vParentesco;

        select nombrezona
        into vNombreColonia
        from bdinteg:"informix".si_catzonas
        where numerociudad = vNumerociudad
        and numerocolonia = vNumeroColonia;

        select nombre
        into vMunicipioNombre
        from bdinteg:"informix".si_municipios
        where pais = vPais
        and ciudad = vCiudad
        and estado = vEstado
        and municipio = vMunicipio;

        select nombreciudad
        into vNombreCiudad
        from bdinteg:"informix".si_catciudades
        where numerociudad = vNumerociudad;

        insert into "informix".ss_ostelreferencias (secuenciaostel, secuencia, apell_paterno, apell_materno, nombre1, nombre2, pais,
        estado, estado_nombre, numerociudad, ciudad_nombre, municipio, municipio_nombre, numerocolonia, colonia_nombre,
        numerocalle, calle_nombre, numeroextcalle, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada,
        parentesco, parentesco_nombre, fecha_insert)
        values (iSecuencia, iNumeroReferenciaObtener, vApell_paterno, vApell_materno, vNombre1, vNombre2, vPais,
        vEstado, vNombreestado, vNumerociudad, vNombreCiudad, vMunicipio, vMunicipioNombre, vNumeroColonia, vNombreColonia,
        vNumerocalle, vNombreCalle, vNumeroextcalle, vUnidadhabitac, vManzana, vOtros, vAndador, vEtapa, vLote, vEdificio, vEntrada,
        vParentesco, vDescripcionParentesco, current);

        --insertar telefono casa de la referencia
        if trim(cTelefono1) <> '' and cTelefono1 is not null then
            insert into "informix".ss_osteltelefonos ( secuenciaostel, secuencia,
                secuenciatelefono, tipo_telef, destino, telefono, extension, fecha_insert)
            values (iSecuencia, iNumeroReferenciaObtener,
                nvl((select {+ INDEX (idx_secuenciaostel)} max(secuenciatelefono) + 1 from ss_osteltelefonos where secuenciaostel = iSecuencia),1),
                '2', '1', cTelefono1 ,'', current);
        end if;

        --insertar telefono celular de la referencia
        if trim(cTelefono2) <> '' and cTelefono2 is not null then
            insert into "informix".ss_osteltelefonos ( secuenciaostel, secuencia,
                secuenciatelefono, tipo_telef, destino, telefono, extension, fecha_insert)
            values (iSecuencia, iNumeroReferenciaObtener,
                nvl((select {+ INDEX (idx_secuenciaostel)} max(secuenciatelefono) + 1 from ss_osteltelefonos where secuenciaostel = iSecuencia),1),
                '1', '2', cTelefono2 ,'', current);
        end if;

        --insertar telefono trabajo de la referencia
        if trim(cTelefono3) <> '' and cTelefono3 is not null then
            insert into "informix".ss_osteltelefonos ( secuenciaostel, secuencia,
                secuenciatelefono, tipo_telef, destino, telefono, extension, fecha_insert)
            values (iSecuencia, iNumeroReferenciaObtener,
                    nvl((select {+ INDEX (idx_secuenciaostel)} max(secuenciatelefono) + 1 from ss_osteltelefonos where secuenciaostel = iSecuencia),1),
                    '2', '3', cTelefono3 ,cExtension, current);
        end if;

        -- obtener datos de unidad habitacional de la referencia si esta vive en una
        IF TRIM(vUnidadhabitac) = 'S' THEN

            let cManzana = '';
            let cOtros = '';
            let cEtapa = '';
            let cLote = '';
            let cEdificio = '';
            let cManzana = '';
            let cEntrada = '';

            select nombredomicilio
            into cManzana
            from bdinteg:"informix".si_catdomicilios a, "informix".ss_ostelreferencias b
            where b.unidadhabitac = 'S'
            and b.secuencia = iNumeroReferenciaObtener
            and b.secuenciaostel = iSecuencia
            and a.clavedomicilio = iMANZANA
            and a.numerocolonia =  b.numerocolonia
            and a.numerociudad =  b.numerociudad
            and a.complementoclave =  b.manzana;
                --obtiene otros
            select nombredomicilio
            into cOtros
            from bdinteg:"informix".si_catdomicilios a, "informix".ss_ostelreferencias b
            where b.unidadhabitac = 'S'
            and b.secuencia = iNumeroReferenciaObtener
            and b.secuenciaostel = iSecuencia
            and a.clavedomicilio = iOTROS
            and a.numerocolonia =  b.numerocolonia
            and a.numerociudad =  b.numerociudad
            and a.complementoclave =  b.otros;
                --obtiene andador
            select nombredomicilio
            into cAndador
            from bdinteg:"informix".si_catdomicilios a, "informix".ss_ostelreferencias b
            where b.unidadhabitac = 'S'
            and b.secuencia = iNumeroReferenciaObtener
            and b.secuenciaostel = iSecuencia
            and a.clavedomicilio = iANDADOR
            and a.numerocolonia =  b.numerocolonia
            and a.numerociudad =  b.numerociudad
            and a.complementoclave =  b.andador;
                --obtiene Etapa
            select nombredomicilio
            into cEtapa
            from bdinteg:"informix".si_catdomicilios a, "informix".ss_ostelreferencias b
            where b.unidadhabitac = 'S'
            and b.secuencia = iNumeroReferenciaObtener
            and b.secuenciaostel = iSecuencia
            and a.clavedomicilio = iETAPA
            and a.numerocolonia =  b.numerocolonia
            and a.numerociudad =  b.numerociudad
            and a.complementoclave =  b.etapa;
                --obtiene lote
            select nombredomicilio
            into cLote
            from bdinteg:"informix".si_catdomicilios a, "informix".ss_ostelreferencias b
            where b.unidadhabitac = 'S'
            and b.secuencia = iNumeroReferenciaObtener
            and b.secuenciaostel = iSecuencia
            and a.clavedomicilio = iLOTE
            and a.numerocolonia =  b.numerocolonia
            and a.numerociudad =  b.numerociudad
            and a.complementoclave =  b.lote;
                -- obtiene edificio
            select nombredomicilio
            into cEdificio
            from bdinteg:"informix".si_catdomicilios a, "informix".ss_ostelreferencias b
            where b.unidadhabitac = 'S'
            and b.secuencia = iNumeroReferenciaObtener
            and b.secuenciaostel = iSecuencia
            and a.clavedomicilio = iEDIFICIO
            and a.numerocolonia =  b.numerocolonia
            and a.numerociudad =  b.numerociudad
            and a.complementoclave =  b.edificio;
                -- obtiene entrada
            select nombredomicilio
            into cEntrada
            from bdinteg:"informix".si_catdomicilios a, "informix".ss_ostelreferencias b
            where b.unidadhabitac = 'S'
            and b.secuencia = iNumeroReferenciaObtener
            and b.secuenciaostel = iSecuencia
            and a.clavedomicilio = iENTRADA
            and a.numerocolonia =  b.numerocolonia
            and a.numerociudad =  b.numerociudad
            and a.complementoclave =  b.entrada;

            -- actualiza datos de unidad habitacional en ss_ostelreferencias
            update {+ INDEX ("informix".ss_ostelreferencias idx_secostelref)} "informix".ss_ostelreferencias set manzana_nombre = cManzana, otros_nombre = cOtros, andador_nombre = cAndador,
            etapa_nombre = cEtapa, lote_nombre = cLote, edificio_nombre = cEdificio, entrada_nombre = cEntrada
            where secuenciaostel = iSecuencia
            and secuencia = iNumeroReferenciaObtener;
        END IF;
        
        --continuar con la siguiente referencia        
        LET iNumeroReferenciaObtener = pReferenciaDos;
        
    END WHILE;

    --armar la trama XML con los datos insertados
    Execute PROCEDURE "informix".sp_OSTelgenerarXML( pEmpresa, iSecuencia )
    into vCod_Ret, cTrama;

    --verificar si se debe enviar a supervisiÃÂ³n la solicitud
    if(select ostelefonica from bditarjcop:"informix".sucursalescajaunica where empresa = pEmpresa and cvesucursal = cSucursal) > 0 then
        select nvl(ostelefonica,'F')
        into cGenera_os_telefonica
        from bditarjcop:"informix".sucursalescajaunica
        where empresa = pEmpresa
        and cvesucursal = cSucursal;
    else
        let cGenera_os_telefonica = 'F';
    end if;

    --insertar la trama
    insert into "informix".ss_osclientesupervisartel_xml( secuenciaostel, tramaxml, generar_OS )
    values (iSecuencia, cTrama, cGenera_os_telefonica);

    update "informix".ss_osclientesupervisartel 
	set tramaxml = cTrama,
		generar_os=cGenera_os_telefonica
	where secuenciaostel = iSecuencia;

    --validar el codigo de retorno del SP sp_OSTelgenerarXML
    if vCod_Ret = '000' then
        
    else
        LET vCod_Ret = vCod_Ret;
        let cTrama = 'ERROR EN SP sp_generarXML_ostel';
        DELETE {+INDEX("informix".ss_ostelrefsolicitud secuenciaostel_idx)} FROM "informix".ss_ostelrefsolicitud WHERE secuenciaostel = iSecuencia;
        DELETE {+INDEX("informix".ss_ostelrefsolicitud_pendientes idx_secuenciaostel_pend)} FROM "informix".ss_ostelrefsolicitud_pendientes WHERE secuenciaostel = iSecuencia;
        DELETE FROM "informix".ss_osclientesupervisartel WHERE secuenciaostel = iSecuencia;
        DELETE {+INDEX("informix".ss_osteltelefonos idx_secuenciaostel)} FROM "informix".ss_osteltelefonos WHERE secuenciaostel = iSecuencia;
        DELETE {+INDEX("informix".ss_ostelreferencias idx_secostelref)} FROM "informix".ss_ostelreferencias WHERE secuenciaostel = iSecuencia;
        DELETE FROM "informix".ss_osclientesupervisartel_xml WHERE secuenciaostel = iSecuencia;
        RETURN vCod_Ret;
    end if;

    RETURN vCod_Ret;
END;
END PROCEDURE
