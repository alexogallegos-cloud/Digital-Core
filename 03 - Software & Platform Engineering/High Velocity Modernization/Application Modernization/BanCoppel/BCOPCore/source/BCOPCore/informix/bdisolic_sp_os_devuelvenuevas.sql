CREATE procedure "informix".sp_os_devuelvenuevas(iSecuenciaMax integer)
--(
--    pempresa char(3),
--    pnum_solicitud char(20),
--    pfecha date
--) 
returning 
    char(5),    --codigo de error  
    --char(3),    --Empresa 
    char(20),   --NumSolicitud
    --date,       --FechaSolicitud;
    --date,       --FechaImpresion;
    --date,       --FechaRespuesta;
    integer,    --estatusos integer default 0 not null ,
    char(40),   --observacion1 char(40) default '',
    char(40),   --observacion2 char(40) default '',
    --char(40),   --observacion3 char(40) default '',
    --char(40),   --usuariogestor char(40) default '',
    --decimal(18,2),  --monto_solicitado decimal(18,2) default 0 not null,
    --char(1),    --clave char(1) default '' not null ,
    smallint,   --tiendafolio smallint default 0 not null ,
    integer,    --folio integer default 0 not null ,
    char(15),   --nombre char(15) default '' not null ,
    char(15),   --apellidopaterno char(15) default '' not null ,
    char(15),   --apellidomaterno char(15) default '' not null ,
    --char(18),   --curp char(18) default '',
    --char(18),   --claveelector char(18) default '',
    --char(1),    --claveidentificacion char(1) default '' not null ,
    --char(8),    --identificacion char(8) default '',
    smallint,   --ciudad smallint default 0 not null ,
    smallint,   --colonia smallint default 0 not null ,
    integer,    --calle integer default 0 not null ,
    integer,    --casa integer default 0,
    char(4),    --deptoointerior char(4) default '',
    char(1),    --rumbo char(1) default '',
    char(3),    --complemento char(3) default '',
    smallint,   --flaguhc smallint default 0,
    smallint,   --uhcmanzana smallint default 0,
    smallint,   --uhcotros smallint default 0,
    smallint,   --uhcandador smallint default 0,
    smallint,   --uhcetapa smallint default 0,
    smallint,   --uhclote smallint default 0,
    smallint,   --uhcedificio smallint default 0,
    smallint,   --uhcentrada smallint default 0,
    --numeric(18,0),  --telefono numeric(18,0) default 0,
    --char(15),   --telefonocelular char(15) default '',
    char(1),    --casapropia char(1) default '',
    char(1),    --sexo char(1) default '',
    char(1),    --estadocivil char(1) default '',
    date,       --fechanacimiento date,
    date,       --fechadesdecuandoviveahi date,
    --smallint,   --personasvivenendomicilio smallint default 0,
    --char(1),    --escolaridad char(1) default '',
    --char(1),    --tiposueldo char(1) default '',
    --smallint,   --numerodependientes smallint default 0,
    smallint,   --personastrabajan smallint default 0,
    char(16), --numeric(14,2),  --ingresomensual numeric(14,2) default 0,
    --char(1),    --situacionespecial char(1) default '',
    --smallint,   --causasituacionespecial smallint default 0,
    --char(1),    --claveautrechaza char(1) default '',
    --char(1),    --creditojoven char(1) default '',
    char(20),   --lugartrabajo char(20) default '',
    smallint,   --ciudadtrabajo smallint default 0,
    smallint,   --coloniatrabajo smallint default 0,
    integer,    --calletrabajo integer default 0,
    integer,    --casatrabajo integer default 0,
    char(4),    --deptoointeriortrabajo char(4) default '',
    char(1),    --rumbotrabajo char(1) default '',
    char(30),   --complementotrabajo char(30) default '',
    smallint,   --flaguht smallint default 0,
    smallint,   --uhtmanzana smallint default 0,
    smallint,   --uhtotros smallint default 0,
    smallint,   --uhtandador smallint default 0,
    smallint,   --uhtetapa smallint default 0,
    smallint,   --uhtlote smallint default 0,
    smallint,   --uhtedificio smallint default 0,
    smallint,   --uhtentrada smallint default 0,
    --numeric(18,0),  --telefonotrabajo numeric(18,0) default 0,
    --smallint,   --extensiontrabajo smallint default 0,
    char(1),    --puesto char(1) default '0',
    --smallint,   --opcionpuesto smallint default 0,
    date,       --fechaantiguedadtrabajo date,
    integer,    --clienteconyuge integer default 0,
    char(15),   --nombreconyuge char(15) default '',
    char(15),   --apellidopaternoconyuge char(15) default '',
    char(15),   --apellidomaternoconyuge char(15) default '',
    --char(20),   --lugartrabajoconyuge char(20) default '',
    --smallint,   --ciudadconyuge smallint default 0,
    --smallint,   --coloniaconyuge smallint default 0,
    --integer,    --calletrabajoconyuge integer default 0,
    --integer,    --casatrabajoconyuge integer default 0,
    --char(4),    --deptoointeriorconyuge char(4) default '',
    --char(1),    --rumbotrabajoconyuge char(1) default '',
    --char(30),   --complementoconyuge char(30) default '',
    --smallint,   --flaguhy smallint default 0,
    --smallint,   --uhymanzana smallint default 0,
    --smallint,   --uhyotros smallint default 0,
    --smallint,   --uhyandador smallint default 0,
    --smallint,   --uhyetapa smallint default 0,
    --smallint,   --uhylote smallint default 0,
    --smallint,   --uhyedificio smallint default 0,
    --smallint,   --uhyentrada smallint default 0,
    --numeric(18,0),  --telefonotrabajoconyuge numeric(18,0) default 0,
    --decimal(16),    --telefonocelularconyuge decimal(16) default 0,
    char(1),    --claveconyugefamilia char(1) default '',
    --integer,    --clientereferencia integer default 0,
    --char(15),   --nombrereferencia char(15) default '',
    --char(15),   --apellidopaternoreferencia char(15) default '',
    --char(15),   --apellidomaternoreferencia char(15) default '',
    --smallint,   --ciudadreferencia smallint default 0,
    --smallint,   --coloniareferencia smallint default 0,
    --integer,    --callereferencia integer default 0,
    --integer,    --casareferencia integer default 0,
    --char(4),    --deptoointeriorreferencia char(4) default '',
    --char(1),    --rumboreferencia char(1) default '',
    --char(30),    --complementoreferencia char(30) default '',
    --smallint,   --flaguhr smallint default 0,
    --smallint,   --uhrmanzana smallint default 0,
    --smallint,   --uhrotros smallint default 0,
    --smallint,   --uhrandador smallint default 0,
    --smallint,   --uhretapa smallint default 0,
    --smallint,   --uhrlote smallint default 0,
    --smallint,   --uhredificio smallint default 0,
    --smallint,   --uhrentrada smallint default 0,
    --numeric(18,0),  --telefonoreferencia numeric(18,0) default 0,
    --char(15),   --telefonocelularreferencia char(15) default '',
    --integer,    --referencia3 integer default 0,
    --char(7),    --referencia4 char(7) default '',
    --integer,    --efectuo integer default 0,
    --datetime year to fraction(5);   --fechamovto datetime year to fraction(5),
    smallint, --limitecredito smallint default 0,
    integer,  --secuencia integer default 0;  
    date;       --fechaaltacliente date,

define sRegresa char(100);
--Declaracion de variables para el registro.
--Campos del 1 al 10
    DEFINE V_Empresa LIKE bdisolic:ss_osclientesupervisar.Empresa;
    DEFINE V_NumSolicitud LIKE bdisolic:ss_osclientesupervisar.Num_Solicitud;
    DEFINE V_FechaSolicitud LIKE bdisolic:ss_osclientesupervisar.FechaSolicitud;
    DEFINE V_FechaImpresion LIKE bdisolic:ss_osclientesupervisar.FechaImpresion;
    DEFINE V_FechaRespuesta LIKE bdisolic:ss_osclientesupervisar.FechaRespuesta;
    DEFINE V_EstatusOs LIKE bdisolic:ss_osclientesupervisar.EstatusOs;
    DEFINE V_Observacion1 LIKE bdisolic:ss_osclientesupervisar.Observacion1;
    DEFINE V_Observacion2 LIKE bdisolic:ss_osclientesupervisar.Observacion2;
    DEFINE V_Observacion3 LIKE bdisolic:ss_osclientesupervisar.Observacion3;
    DEFINE V_Monto_Solicitado Like bdisolic:ss_osclientesupervisar.monto_solicitado;
--Campos del 11 al 20
    define V_numcte     char(20);
    DEFINE V_usuariogestor LIKE bdisolic:ss_osclientesupervisar.usuariogestor;
    DEFINE V_clave LIKE bdisolic:ss_osclientesupervisar.clave;
    DEFINE V_tiendafolio LIKE bdisolic:ss_osclientesupervisar.tiendafolio;
    DEFINE V_folio LIKE bdisolic:ss_osclientesupervisar.folio;
    DEFINE V_nombre LIKE bdisolic:ss_osclientesupervisar.nombre;
    DEFINE V_apellidopaterno LIKE bdisolic:ss_osclientesupervisar.apellidopaterno;
    DEFINE V_apellidomaterno LIKE bdisolic:ss_osclientesupervisar.apellidomaterno;
    DEFINE V_curp LIKE bdisolic:ss_osclientesupervisar.curp;
    DEFINE V_claveelector LIKE bdisolic:ss_osclientesupervisar.claveelector;
--Campos del 21 al 30
    DEFINE V_claveidentificacion LIKE bdisolic:ss_osclientesupervisar.claveidentificacion;
    DEFINE V_identificacion LIKE bdisolic:ss_osclientesupervisar.identificacion;
    DEFINE V_ciudad LIKE bdisolic:ss_osclientesupervisar.ciudad;
    DEFINE V_colonia LIKE bdisolic:ss_osclientesupervisar.colonia;
    DEFINE V_calle LIKE bdisolic:ss_osclientesupervisar.calle;
    DEFINE V_casa LIKE bdisolic:ss_osclientesupervisar.casa;
    DEFINE V_deptoointerior LIKE bdisolic:ss_osclientesupervisar.deptoointerior;
    --define V_deptoointerior char(4);
    DEFINE V_rumbo LIKE bdisolic:ss_osclientesupervisar.rumbo;
    DEFINE V_complemento LIKE bdisolic:ss_osclientesupervisar.complemento;
    DEFINE V_flaguhc LIKE bdisolic:ss_osclientesupervisar.flaguhc;
--Campos del 31 al 40
    DEFINE V_uhcmanzana LIKE bdisolic:ss_osclientesupervisar.uhcmanzana;
    DEFINE V_uhcotros LIKE bdisolic:ss_osclientesupervisar.uhcotros;
    DEFINE V_uhcandador LIKE bdisolic:ss_osclientesupervisar.uhcandador;
    DEFINE V_uhcetapa LIKE bdisolic:ss_osclientesupervisar.uhcetapa;
    DEFINE V_uhclote LIKE bdisolic:ss_osclientesupervisar.uhclote;
    DEFINE V_uhcedificio LIKE bdisolic:ss_osclientesupervisar.uhcedificio;
    DEFINE V_uhcentrada LIKE bdisolic:ss_osclientesupervisar.uhcentrada;
    DEFINE V_telefono LIKE bdisolic:ss_osclientesupervisar.telefono;
    DEFINE V_telefonocelular LIKE bdisolic:ss_osclientesupervisar.telefonocelular;
    DEFINE V_casapropia LIKE bdisolic:ss_osclientesupervisar.casapropia;
--Campos del 41 al 50
    DEFINE V_sexo LIKE bdisolic:ss_osclientesupervisar.sexo;
    DEFINE V_estadocivil LIKE bdisolic:ss_osclientesupervisar.estadocivil;
    DEFINE V_fechanacimiento LIKE bdisolic:ss_osclientesupervisar.fechanacimiento;
    DEFINE V_fechadesdecuandoviveahi LIKE bdisolic:ss_osclientesupervisar.fechadesdecuandoviveahi;
    DEFINE V_personasvivenendomicilio LIKE bdisolic:ss_osclientesupervisar.personasvivenendomicilio;
    DEFINE V_escolaridad LIKE bdisolic:ss_osclientesupervisar.escolaridad;
    DEFINE V_tiposueldo LIKE bdisolic:ss_osclientesupervisar.tiposueldo;
    DEFINE V_numerodependientes LIKE bdisolic:ss_osclientesupervisar.numerodependientes;
    DEFINE V_personastrabajan LIKE bdisolic:ss_osclientesupervisar.personastrabajan;
    DEFINE V_ingresomensual LIKE bdisolic:ss_osclientesupervisar.ingresomensual;
--Campos del 51 al 60
    DEFINE V_situacionespecial LIKE bdisolic:ss_osclientesupervisar.situacionespecial;
    DEFINE V_causasituacionespecial LIKE bdisolic:ss_osclientesupervisar.causasituacionespecial;
    DEFINE V_claveautrechaza LIKE bdisolic:ss_osclientesupervisar.claveautrechaza;
    DEFINE V_creditojoven LIKE bdisolic:ss_osclientesupervisar.creditojoven;
    DEFINE V_lugartrabajo LIKE bdisolic:ss_osclientesupervisar.lugartrabajo;
    DEFINE V_ciudadtrabajo LIKE bdisolic:ss_osclientesupervisar.ciudadtrabajo;
    DEFINE V_coloniatrabajo LIKE bdisolic:ss_osclientesupervisar.coloniatrabajo;
    DEFINE V_calletrabajo LIKE bdisolic:ss_osclientesupervisar.calletrabajo;
    DEFINE V_casatrabajo LIKE bdisolic:ss_osclientesupervisar.casatrabajo;
    DEFINE V_deptoointeriortrabajo LIKE bdisolic:ss_osclientesupervisar.deptoointeriortrabajo;
--Campos del 61 al 70
    DEFINE V_rumbotrabajo LIKE bdisolic:ss_osclientesupervisar.rumbotrabajo;
    DEFINE V_complementotrabajo LIKE bdisolic:ss_osclientesupervisar.complementotrabajo;
    DEFINE V_flaguht LIKE bdisolic:ss_osclientesupervisar.flaguht;
    DEFINE V_uhtmanzana LIKE bdisolic:ss_osclientesupervisar.uhtmanzana;
    DEFINE V_uhtotros LIKE bdisolic:ss_osclientesupervisar.uhtotros;
    DEFINE V_uhtandador LIKE bdisolic:ss_osclientesupervisar.uhtandador;
    DEFINE V_uhtetapa LIKE bdisolic:ss_osclientesupervisar.uhtetapa;
    DEFINE V_uhtlote LIKE bdisolic:ss_osclientesupervisar.uhtlote;
    DEFINE V_uhtedificio LIKE bdisolic:ss_osclientesupervisar.uhtedificio;
    DEFINE V_uhtentrada LIKE bdisolic:ss_osclientesupervisar.uhtentrada;
--Campos del 71 al 80
    DEFINE V_telefonotrabajo LIKE bdisolic:ss_osclientesupervisar.telefonotrabajo;
    DEFINE V_extensiontrabajo LIKE bdisolic:ss_osclientesupervisar.extensiontrabajo;
    DEFINE V_puesto LIKE bdisolic:ss_osclientesupervisar.puesto;
    DEFINE V_opcionpuesto LIKE bdisolic:ss_osclientesupervisar.opcionpuesto;
    DEFINE V_fechaantiguedadtrabajo LIKE bdisolic:ss_osclientesupervisar.fechaantiguedadtrabajo;
    DEFINE V_clienteconyuge LIKE bdisolic:ss_osclientesupervisar.clienteconyuge;
    DEFINE V_nombreconyuge LIKE bdisolic:ss_osclientesupervisar.nombreconyuge;
    DEFINE V_apellidopaternoconyuge LIKE bdisolic:ss_osclientesupervisar.apellidopaternoconyuge;
    DEFINE V_apellidomaternoconyuge LIKE bdisolic:ss_osclientesupervisar.apellidomaternoconyuge;
    DEFINE V_lugartrabajoconyuge LIKE bdisolic:ss_osclientesupervisar.lugartrabajoconyuge;
--Campos del 81 al 90
    DEFINE V_ciudadconyuge LIKE bdisolic:ss_osclientesupervisar.ciudadconyuge;
    DEFINE V_coloniaconyuge LIKE bdisolic:ss_osclientesupervisar.coloniaconyuge;
    DEFINE V_calletrabajoconyuge LIKE bdisolic:ss_osclientesupervisar.calletrabajoconyuge;
    DEFINE V_casatrabajoconyuge LIKE bdisolic:ss_osclientesupervisar.casatrabajoconyuge;
    DEFINE V_deptoointeriorconyuge LIKE bdisolic:ss_osclientesupervisar.deptoointeriorconyuge;
    DEFINE V_rumbotrabajoconyuge LIKE bdisolic:ss_osclientesupervisar.rumbotrabajoconyuge;
    DEFINE V_complementoconyuge LIKE bdisolic:ss_osclientesupervisar.complementoconyuge;
    DEFINE V_flaguhy LIKE bdisolic:ss_osclientesupervisar.flaguhy;
    DEFINE V_uhymanzana LIKE bdisolic:ss_osclientesupervisar.uhymanzana;
    DEFINE V_uhyotros LIKE bdisolic:ss_osclientesupervisar.uhyotros;
--Campos del 91 al 100
    DEFINE V_uhyandador LIKE bdisolic:ss_osclientesupervisar.uhyandador;
    DEFINE V_uhyetapa LIKE bdisolic:ss_osclientesupervisar.uhyetapa;
    DEFINE V_uhylote LIKE bdisolic:ss_osclientesupervisar.uhylote;
    DEFINE V_uhyedificio LIKE bdisolic:ss_osclientesupervisar.uhyedificio;
    DEFINE V_uhyentrada LIKE bdisolic:ss_osclientesupervisar.uhyentrada;
    DEFINE V_telefonotrabajoconyuge LIKE bdisolic:ss_osclientesupervisar.telefonotrabajoconyuge;
    DEFINE V_telefonocelularconyuge LIKE bdisolic:ss_osclientesupervisar.telefonocelularconyuge;
    DEFINE V_claveconyugefamilia LIKE bdisolic:ss_osclientesupervisar.claveconyugefamilia;
    DEFINE V_clientereferencia LIKE bdisolic:ss_osclientesupervisar.clientereferencia;
    DEFINE V_nombrereferencia LIKE bdisolic:ss_osclientesupervisar.nombrereferencia;
--Campos del 101 al 110
    DEFINE V_apellidopaternoreferencia LIKE bdisolic:ss_osclientesupervisar.apellidopaternoreferencia;
    DEFINE V_apellidomaternoreferencia LIKE bdisolic:ss_osclientesupervisar.apellidomaternoreferencia;
    DEFINE V_ciudadreferencia LIKE bdisolic:ss_osclientesupervisar.ciudadreferencia;
    DEFINE V_coloniareferencia LIKE bdisolic:ss_osclientesupervisar.coloniareferencia;
    DEFINE V_callereferencia LIKE bdisolic:ss_osclientesupervisar.callereferencia;
    DEFINE V_casareferencia LIKE bdisolic:ss_osclientesupervisar.casareferencia;
    DEFINE V_deptoointeriorreferencia LIKE bdisolic:ss_osclientesupervisar.deptoointeriorreferencia;
    DEFINE V_rumboreferencia LIKE bdisolic:ss_osclientesupervisar.rumboreferencia;
    DEFINE V_complementoreferencia LIKE bdisolic:ss_osclientesupervisar.complementoreferencia;
    DEFINE V_flaguhr LIKE bdisolic:ss_osclientesupervisar.flaguhr;
--Campos del 111 al 120
    DEFINE V_uhrmanzana LIKE bdisolic:ss_osclientesupervisar.uhrmanzana;
    DEFINE V_uhrotros LIKE bdisolic:ss_osclientesupervisar.uhrotros;
    DEFINE V_uhrandador LIKE bdisolic:ss_osclientesupervisar.uhrandador;
    DEFINE V_uhretapa LIKE bdisolic:ss_osclientesupervisar.uhretapa;
    DEFINE V_uhrlote LIKE bdisolic:ss_osclientesupervisar.uhrlote;
    DEFINE V_uhredificio LIKE bdisolic:ss_osclientesupervisar.uhredificio;
    DEFINE V_uhrentrada LIKE bdisolic:ss_osclientesupervisar.uhrentrada;
    DEFINE V_telefonoreferencia LIKE bdisolic:ss_osclientesupervisar.telefonoreferencia;
    DEFINE V_telefonocelularreferencia LIKE bdisolic:ss_osclientesupervisar.telefonocelularreferencia;
    DEFINE V_referencia3 LIKE bdisolic:ss_osclientesupervisar.referencia3;
--Campos del 121 al 124
    DEFINE V_referencia4 LIKE bdisolic:ss_osclientesupervisar.referencia4;
    DEFINE V_efectuo LIKE bdisolic:ss_osclientesupervisar.efectuo;
    DEFINE V_fechaaltacliente LIKE bdisolic:ss_osclientesupervisar.fechaaltacliente;
    DEFINE V_fechamovto LIKE bdisolic:ss_osclientesupervisar.fechamovto;
    DEFINE v_limitecredito LIKE bdisolic:ss_osclientesupervisar.limitecredito;
    define v_secuencia  like bdisolic:ss_osclientesupervisar.secuencia;

--Variables auxiliares
    define aux_numcte_ref like bdisolic:ss_solicitudes.numcte;
    define aux_claveconyugefamilia char(2);
    define aux_tipo_cliente like bdinteg:si_cliente.tipo_cliente;

    define iHayDatosFamiliar    INTEGER;
    define iHayDatosReferencia  INTEGER;
    define iTotalReferencias    INTEGER; 

    DEFINE   SQL_ERR     INTEGER;
    DEFINE   ISAM_ERR    INTEGER;
    DEFINE   ERROR_INFO  VARCHAR(80);
    DEFINE P_COD_RET VARCHAR(5);
    DEFINE P_MENSAJE VARCHAR(80);

    Define iEncuentraSolic  Integer;
    Define iCuantos         Integer;
    define iAniosHabita     Integer;



BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        --ROLLBACK WORK;
        Let v_numsolicitud  = '';
        Let v_estatusos     = '';
        Let v_observacion1  = '';
        Let v_observacion2  = '';
        Let v_tiendafolio   = 0;
        Let v_folio         = 0;
        Let v_nombre        = 0;
        Let v_apellidopaterno   = '';
        Let v_apellidomaterno   = '';
        Let v_ciudad            = 0;
        Let v_colonia           = 0;
        Let v_calle             = 0;
        Let v_casa              = 0;
        Let v_deptoointerior    = '';
        Let v_rumbo             = '';
        Let v_complemento       = '';
        Let v_flaguhc           = 0;
        Let v_uhcmanzana        = 0;
        Let v_uhcotros          = 0;
        Let v_uhcandador        = 0;
        Let v_uhcetapa          = 0;
        Let v_uhclote           = 0;
        Let v_uhcedificio       = 0;
        Let v_uhcentrada        = 0;
        Let v_casapropia        = 0;
        Let v_sexo              = '';
        Let v_estadocivil       = '';
        Let v_fechanacimiento   = '';
        Let v_fechadesdecuandoviveahi   = '';
        Let v_personastrabajan          = 0;
        Let v_ingresomensual            = 0;
        Let v_lugartrabajo              = '';
        Let v_ciudadtrabajo             = '';
        Let v_coloniatrabajo            = 0;
        Let v_calletrabajo      = 0;
        Let v_casatrabajo       = 0;
        Let v_deptoointeriortrabajo = '';
        Let v_rumbotrabajo      = '';
        Let v_complementotrabajo= '';
        Let v_flaguht   = 0;
        Let v_uhtmanzana= 0;
        Let v_uhtotros  = 0;
        Let v_uhtandador= 0;
        Let v_uhtetapa  = 0;
        Let v_uhtlote   = 0;
        Let v_uhtedificio=0;
        Let v_uhtentrada = '';
        Let v_puesto    = '';
        Let v_fechaantiguedadtrabajo = '';
        Let v_clienteconyuge    = 0;
        Let v_nombreconyuge     = '';
        Let v_apellidopaternoconyuge = '';
        Let v_apellidomaternoconyuge = '';
        Let v_claveconyugefamilia = '';
        Let v_limitecredito = 0;
        Let v_secuencia     = 0;

        RETURN 
            P_COD_RET, 
            v_numsolicitud,
            v_estatusos, v_observacion1, v_observacion2, 
            v_tiendafolio, v_folio, 
            v_nombre, v_apellidopaterno, v_apellidomaterno, 
            v_ciudad, v_colonia, v_calle,
            v_casa, v_deptoointerior, v_rumbo, v_complemento, v_flaguhc, 
            v_uhcmanzana, v_uhcotros, v_uhcandador, v_uhcetapa, v_uhclote,
            v_uhcedificio, v_uhcentrada, 
            v_casapropia,
            v_sexo, v_estadocivil, v_fechanacimiento, v_fechadesdecuandoviveahi, 
            v_personastrabajan,         v_ingresomensual::char(16),
            v_lugartrabajo, v_ciudadtrabajo, v_coloniatrabajo, v_calletrabajo, v_casatrabajo,
            v_deptoointeriortrabajo, v_rumbotrabajo, v_complementotrabajo, v_flaguht, v_uhtmanzana,
            v_uhtotros, v_uhtandador, v_uhtetapa, v_uhtlote, v_uhtedificio,
            v_uhtentrada, 
            v_puesto, 
            v_fechaantiguedadtrabajo, v_clienteconyuge, v_nombreconyuge, v_apellidopaternoconyuge,
            v_apellidomaternoconyuge, 
            v_claveconyugefamilia, v_limitecredito, v_secuencia, v_fechaaltacliente ;
    END EXCEPTION;

        Let v_numsolicitud  = '';
        Let v_estatusos     = '';
        Let v_observacion1  = '';
        Let v_observacion2  = '';
        Let v_tiendafolio   = 0;
        Let v_folio         = 0;
        Let v_nombre        = 0;
        Let v_apellidopaterno   = '';
        Let v_apellidomaterno   = '';
        Let v_ciudad            = 0;
        Let v_colonia           = 0;
        Let v_calle             = 0;
        Let v_casa              = 0;
        Let v_deptoointerior    = '';
        Let v_rumbo             = '';
        Let v_complemento       = '';
        Let v_flaguhc           = 0;
        Let v_uhcmanzana        = 0;
        Let v_uhcotros          = 0;
        Let v_uhcandador        = 0;
        Let v_uhcetapa          = 0;
        Let v_uhclote           = 0;
        Let v_uhcedificio       = 0;
        Let v_uhcentrada        = 0;
        Let v_casapropia        = 0;
        Let v_sexo              = '';
        Let v_estadocivil       = '';
        Let v_fechanacimiento   = '';
        Let v_fechadesdecuandoviveahi   = '';
        Let v_personastrabajan          = 0;
        Let v_ingresomensual            = 0;
        Let v_lugartrabajo              = '';
        Let v_ciudadtrabajo             = '';
        Let v_coloniatrabajo            = 0;
        Let v_calletrabajo      = 0;
        Let v_casatrabajo       = 0;
        Let v_deptoointeriortrabajo = '';
        Let v_rumbotrabajo      = '';
        Let v_complementotrabajo= '';
        Let v_flaguht   = 0;
        Let v_uhtmanzana= 0;
        Let v_uhtotros  = 0;
        Let v_uhtandador= 0;
        Let v_uhtetapa  = 0;
        Let v_uhtlote   = 0;
        Let v_uhtedificio=0;
        Let v_uhtentrada = '';
        Let v_puesto    = '';
        Let v_fechaantiguedadtrabajo = '';
        Let v_clienteconyuge    = 0;
        Let v_nombreconyuge     = '';
        Let v_apellidopaternoconyuge = '';
        Let v_apellidomaternoconyuge = '';
        Let v_claveconyugefamilia = '';
        Let v_limitecredito = 0;
        Let v_secuencia     = 0;


  --ASIGNA VALORES A LAS VARIABLES
    LET P_COD_RET = '00000';
    LET P_MENSAJE = 'PROCESO EXITOSO';
    Let iEncuentraSolic = 0;

    ForEach
    Select empresa, num_solicitud, fechasolicitud, fechaimpresion, fecharespuesta,
            estatusos, observacion1, observacion2, observacion3, monto_solicitado,
            usuariogestor, clave, tiendafolio, folio,
            nombre, apellidopaterno, apellidomaterno, curp, claveelector,
            claveidentificacion, identificacion, ciudad, colonia, calle,
            casa, deptoointerior, rumbo, complemento, flaguhc,
            uhcmanzana, uhcotros, uhcandador, uhcetapa, uhclote,
            uhcedificio, uhcentrada, telefono, telefonocelular, casapropia,
            sexo, estadocivil, fechanacimiento, fechadesdecuandoviveahi, personasvivenendomicilio,
            escolaridad, tiposueldo, numerodependientes, personastrabajan, ingresomensual,
            situacionespecial, causasituacionespecial, claveautrechaza, creditojoven, 
            lugartrabajo, ciudadtrabajo, coloniatrabajo, calletrabajo, casatrabajo,
            deptoointeriortrabajo, rumbotrabajo, complementotrabajo, flaguht, uhtmanzana,
            uhtotros, uhtandador, uhtetapa, uhtlote, uhtedificio,
            uhtentrada, telefonotrabajo, extensiontrabajo, puesto, opcionpuesto,
            fechaantiguedadtrabajo, clienteconyuge, nombreconyuge, apellidopaternoconyuge,
            apellidomaternoconyuge, lugartrabajoconyuge, ciudadconyuge, coloniaconyuge,
            calletrabajoconyuge, casatrabajoconyuge, deptoointeriorconyuge, rumbotrabajoconyuge, complementoconyuge,
            flaguhy, uhymanzana, uhyotros, uhyandador, uhyetapa, uhylote,
            uhyedificio, uhyentrada, telefonotrabajoconyuge, telefonocelularconyuge,claveconyugefamilia,
            clientereferencia, nombrereferencia, apellidopaternoreferencia, apellidomaternoreferencia, ciudadreferencia,
            coloniareferencia, callereferencia, casareferencia, deptoointeriorreferencia,
            rumboreferencia, complementoreferencia, flaguhr, uhrmanzana, uhrotros, uhrandador,
            uhretapa, uhrlote, uhredificio, uhrentrada, telefonoreferencia,
            telefonocelularreferencia, referencia3, referencia4, efectuo, 
            fechaaltacliente, fechamovto, limitecredito, secuencia
    Into 
        v_empresa, v_numsolicitud, v_fechasolicitud, v_fechaimpresion, v_fecharespuesta,
        v_estatusos, v_observacion1, v_observacion2, v_observacion3, v_monto_solicitado,
        v_usuariogestor, v_clave, v_tiendafolio, v_folio,
        v_nombre, v_apellidopaterno, v_apellidomaterno, v_curp, v_claveelector,
        v_claveidentificacion, v_identificacion,  v_ciudad, v_colonia, v_calle,
        v_casa, v_deptoointerior, v_rumbo, v_complemento, v_flaguhc, 
        v_uhcmanzana, v_uhcotros, v_uhcandador, v_uhcetapa, v_uhclote,
        v_uhcedificio, v_uhcentrada, v_telefono, v_telefonocelular, v_casapropia,
        v_sexo, v_estadocivil, v_fechanacimiento, v_fechadesdecuandoviveahi, v_personasvivenendomicilio,
        v_escolaridad, v_tiposueldo, v_numerodependientes, v_personastrabajan, v_ingresomensual,
        v_situacionespecial, v_causasituacionespecial, v_claveautrechaza, v_creditojoven,
        v_lugartrabajo, v_ciudadtrabajo, v_coloniatrabajo, v_calletrabajo, v_casatrabajo,
        v_deptoointeriortrabajo, v_rumbotrabajo, v_complementotrabajo, v_flaguht, v_uhtmanzana,
        v_uhtotros, v_uhtandador, v_uhtetapa, v_uhtlote, v_uhtedificio,
        v_uhtentrada, v_telefonotrabajo, v_extensiontrabajo, v_puesto, v_opcionpuesto,
        v_fechaantiguedadtrabajo, v_clienteconyuge, v_nombreconyuge, v_apellidopaternoconyuge,
        v_apellidomaternoconyuge, v_lugartrabajoconyuge, v_ciudadconyuge, v_coloniaconyuge,
        v_calletrabajoconyuge, v_casatrabajoconyuge, v_deptoointeriorconyuge, v_rumbotrabajoconyuge, v_complementoconyuge,
        v_flaguhy, v_uhymanzana, v_uhyotros, v_uhyandador, v_uhyetapa, v_uhylote,
        v_uhyedificio, v_uhyentrada, v_telefonotrabajoconyuge, v_telefonocelularconyuge, v_claveconyugefamilia,
        v_clientereferencia, v_nombrereferencia, v_apellidopaternoreferencia, v_apellidomaternoreferencia, v_ciudadreferencia,
        v_coloniareferencia, v_callereferencia, v_casareferencia, v_deptoointeriorreferencia,
        v_rumboreferencia, v_complementoreferencia, v_flaguhr, v_uhrmanzana, v_uhrotros, v_uhrandador,
        v_uhretapa, v_uhrlote, v_uhredificio, v_uhrentrada, v_telefonoreferencia,
        v_telefonocelularreferencia, v_referencia3, v_referencia4, v_efectuo,
        v_fechaaltacliente, v_fechamovto, v_limitecredito, v_secuencia
    From ss_osclientesupervisar
    Where (nvl(clave, '') <> 'R' and nvl(clave, '') <> 'A') and secuencia > iSecuenciaMax --and estatusos = 0 
    order by secuencia

        return 
            P_COD_RET, 
            /* --v_empresa, */
            v_numsolicitud, /*--v_fechasolicitud, v_fechaimpresion, v_fecharespuesta, */
            v_estatusos, v_observacion1, v_observacion2, /*--v_observacion3, v_monto_solicitado, */
/*          v_usuariogestor, v_clave, */
            v_tiendafolio, v_folio, 
            v_nombre, v_apellidopaterno, v_apellidomaterno, /* --v_curp, v_claveelector, */
/*            --v_claveidentificacion, v_identificacion,  */
            nvl(v_ciudad,0), nvl(v_colonia,0), nvl(v_calle,0),
            nvl(v_casa,0), nvl(v_deptoointerior,''), nvl(v_rumbo,''), nvl(v_complemento, ''), nvl(v_flaguhc,0), 
            nvl(v_uhcmanzana,0), nvl(v_uhcotros,0), nvl(v_uhcandador,0), nvl(v_uhcetapa,0), nvl(v_uhclote,0),
            nvl(v_uhcedificio,0), nvl(v_uhcentrada,0), /* --v_telefono, v_telefonocelular,  */
            v_casapropia,
            v_sexo, v_estadocivil, v_fechanacimiento, v_fechadesdecuandoviveahi, /* --v_personasvivenendomicilio, */
/*            --v_escolaridad, v_tiposueldo, v_numerodependientes,  */
            nvl(v_personastrabajan,0),         v_ingresomensual::char(16),
/*
            --v_situacionespecial, v_causasituacionespecial, v_claveautrechaza, v_creditojoven, 
*/
            v_lugartrabajo, nvl(v_ciudadtrabajo,0), nvl(v_coloniatrabajo,0), nvl(v_calletrabajo,0), nvl(v_casatrabajo,0),
            nvl(v_deptoointeriortrabajo, ''), nvl(v_rumbotrabajo,''), nvl(v_complementotrabajo, ''), nvl(v_flaguht,0), nvl(v_uhtmanzana,0),
            nvl(v_uhtotros,0), nvl(v_uhtandador,0), nvl(v_uhtetapa,0), nvl(v_uhtlote,0), nvl(v_uhtedificio,0),
            v_uhtentrada, /* --v_telefonotrabajo, v_extensiontrabajo, */
            nvl(v_puesto,0), /* --v_opcionpuesto, */
            v_fechaantiguedadtrabajo, v_clienteconyuge, v_nombreconyuge, v_apellidopaternoconyuge,
            v_apellidomaternoconyuge, 
/*            --v_lugartrabajoconyuge, v_ciudadconyuge, v_coloniaconyuge, 
            --v_calletrabajoconyuge, v_casatrabajoconyuge, v_deptoointeriorconyuge, v_rumbotrabajoconyuge, v_complementoconyuge,
            --v_flaguhy, v_uhymanzana, v_uhyotros, v_uhyandador, v_uhyetapa, v_uhylote,
            --v_uhyedificio, v_uhyentrada, v_telefonotrabajoconyuge, v_telefonocelularconyuge, */
            v_claveconyugefamilia, v_limitecredito, v_secuencia, v_fechaaltacliente 
/*            --v_clientereferencia, v_nombrereferencia, v_apellidopaternoreferencia, v_apellidomaternoreferencia, v_ciudadreferencia,
            --v_coloniareferencia, v_callereferencia, v_casareferencia, v_deptoointeriorreferencia,
            --v_rumboreferencia, v_complementoreferencia, v_flaguhr, v_uhrmanzana, v_uhrotros, v_uhrandador,
            --v_uhretapa, v_uhrlote, v_uhredificio, v_uhrentrada, v_telefonoreferencia,
            --v_telefonocelularreferencia, v_referencia3, v_referencia4, v_efectuo,
            --, v_fechamovto  */
            WITH RESUME;
    End foreach;

END;

END procedure
;