CREATE PROCEDURE "informix".sp_os_generaos_prospecto_piloto(pNumSolicitud CHAR(20),pFechaSolicitud DATE,pTiendafolio SMALLINT,pNombre1 CHAR(26),pNombre2 CHAR(26),pApellidopaterno CHAR(26),pApellidomaterno CHAR(26),pPersonasvivenendomicilio SMALLINT, pFechaaltacliente DATE,pFechaHora DATE, pEmpresa CHAR(3))
RETURNING CHAR(5),VARCHAR(80);
DEFINE V_NumSolicitud_Cliente LIKE bdisolic:"informix".ss_osclientesupervisar.Num_Solicitud;
DEFINE V_FechaSolicitud_Cliente LIKE bdisolic:"informix".ss_osclientesupervisar.FechaSolicitud;
DEFINE V_FechaImpresion LIKE bdisolic:"informix".ss_osclientesupervisar.FechaImpresion;
DEFINE V_FechaRespuesta LIKE bdisolic:"informix".ss_osclientesupervisar.FechaRespuesta;
DEFINE V_EstatusOs LIKE bdisolic:"informix".ss_osclientesupervisar.EstatusOs;

DEFINE V_Observacion1 LIKE bdisolic:"informix".ss_osclientesupervisar.Observacion1;
DEFINE V_Observacion2 LIKE bdisolic:"informix".ss_osclientesupervisar.Observacion2;
DEFINE V_Observacion3 LIKE bdisolic:"informix".ss_osclientesupervisar.Observacion3;
DEFINE V_Monto_Solicitado LIKE bdisolic:"informix".ss_osclientesupervisar.monto_solicitado;
--Campos del 11 al 20
DEFINE V_numcte     CHAR(20);
DEFINE V_usuariogestor LIKE bdisolic:"informix".ss_osclientesupervisar.usuariogestor;
DEFINE V_clave LIKE bdisolic:"informix".ss_osclientesupervisar.clave;
DEFINE V_folio LIKE bdisolic:"informix".ss_osclientesupervisar.folio;
DEFINE V_nombre LIKE bdisolic:"informix".ss_osclientesupervisar.nombre;
DEFINE V_apellidopaterno1 LIKE bdisolic:"informix".ss_osclientesupervisar.apellidopaterno1;
DEFINE V_apellidomaterno1 LIKE bdisolic:"informix".ss_osclientesupervisar.apellidomaterno1;
DEFINE V_curp LIKE bdisolic:"informix".ss_osclientesupervisar.curp;
DEFINE V_claveelector LIKE bdisolic:"informix".ss_osclientesupervisar.claveelector;
--Campos del 21 al 30
DEFINE V_claveidentificacion LIKE bdisolic:"informix".ss_osclientesupervisar.claveidentificacion;
DEFINE V_identificacion LIKE bdisolic:"informix".ss_osclientesupervisar.identificacion;
DEFINE V_ciudad LIKE bdisolic:"informix".ss_osclientesupervisar.ciudad;
DEFINE V_colonia LIKE bdisolic:"informix".ss_osclientesupervisar.colonia;
DEFINE V_calle LIKE bdisolic:"informix".ss_osclientesupervisar.calle;
DEFINE V_casa LIKE bdisolic:"informix".ss_osclientesupervisar.casa;
DEFINE V_deptoointerior LIKE bdisolic:"informix".ss_osclientesupervisar.deptoointerior;
--DEFINE V_deptoointerior CHAR(4);
DEFINE V_rumbo LIKE bdisolic:"informix".ss_osclientesupervisar.rumbo;
DEFINE V_complemento LIKE bdisolic:"informix".ss_osclientesupervisar.complemento;
DEFINE V_flaguhc LIKE bdisolic:"informix".ss_osclientesupervisar.flaguhc;
--Campos del 31 al 40
DEFINE V_uhcmanzana LIKE bdisolic:"informix".ss_osclientesupervisar.uhcmanzana;
DEFINE V_uhcotros LIKE bdisolic:"informix".ss_osclientesupervisar.uhcotros;
DEFINE V_uhcandador LIKE bdisolic:"informix".ss_osclientesupervisar.uhcandador;
DEFINE V_uhcetapa LIKE bdisolic:"informix".ss_osclientesupervisar.uhcetapa;
DEFINE V_uhclote LIKE bdisolic:"informix".ss_osclientesupervisar.uhclote;
DEFINE V_uhcedificio LIKE bdisolic:"informix".ss_osclientesupervisar.uhcedificio;
DEFINE V_uhcentrada LIKE bdisolic:"informix".ss_osclientesupervisar.uhcentrada;
DEFINE V_telefono LIKE bdisolic:"informix".ss_osclientesupervisar.telefono;
DEFINE V_telefonocelular LIKE bdisolic:"informix".ss_osclientesupervisar.telefonocelular;
DEFINE V_casapropia LIKE bdisolic:"informix".ss_osclientesupervisar.casapropia;
--Campos del 41 al 50
DEFINE V_sexo LIKE bdisolic:"informix".ss_osclientesupervisar.sexo;
DEFINE V_estadocivil LIKE bdisolic:"informix".ss_osclientesupervisar.estadocivil;
DEFINE V_fechanacimiento LIKE bdisolic:"informix".ss_osclientesupervisar.fechanacimiento;
DEFINE V_fechadesdecuandoviveahi LIKE bdisolic:"informix".ss_osclientesupervisar.fechadesdecuandoviveahi;
DEFINE V_escolaridad LIKE bdisolic:"informix".ss_osclientesupervisar.escolaridad;
DEFINE V_tiposueldo LIKE bdisolic:"informix".ss_osclientesupervisar.tiposueldo;
DEFINE V_numerodependientes LIKE bdisolic:"informix".ss_osclientesupervisar.numerodependientes;
DEFINE V_personastrabajan LIKE bdisolic:"informix".ss_osclientesupervisar.personastrabajan;
DEFINE V_ingresomensual LIKE bdisolic:"informix".ss_osclientesupervisar.ingresomensual;
--Campos del 51 al 60
DEFINE V_situacionespecial LIKE bdisolic:"informix".ss_osclientesupervisar.situacionespecial;
DEFINE V_causasituacionespecial LIKE bdisolic:"informix".ss_osclientesupervisar.causasituacionespecial;
DEFINE V_claveautrechaza LIKE bdisolic:"informix".ss_osclientesupervisar.claveautrechaza;
DEFINE V_creditojoven LIKE bdisolic:"informix".ss_osclientesupervisar.creditojoven;
DEFINE V_lugartrabajo LIKE bdisolic:"informix".ss_osclientesupervisar.lugartrabajo;
DEFINE V_ciudadtrabajo LIKE bdisolic:"informix".ss_osclientesupervisar.ciudadtrabajo;
DEFINE V_coloniatrabajo LIKE bdisolic:"informix".ss_osclientesupervisar.coloniatrabajo;
DEFINE V_calletrabajo LIKE bdisolic:"informix".ss_osclientesupervisar.calletrabajo;
DEFINE V_casatrabajo LIKE bdisolic:"informix".ss_osclientesupervisar.casatrabajo;
DEFINE V_deptoointeriortrabajo LIKE bdisolic:"informix".ss_osclientesupervisar.deptoointeriortrabajo;
--Campos del 61 al 70
DEFINE V_rumbotrabajo LIKE bdisolic:"informix".ss_osclientesupervisar.rumbotrabajo;
DEFINE V_complementotrabajo LIKE bdisolic:"informix".ss_osclientesupervisar.complementotrabajo;
DEFINE V_flaguht LIKE bdisolic:"informix".ss_osclientesupervisar.flaguht;
DEFINE V_uhtmanzana LIKE bdisolic:"informix".ss_osclientesupervisar.uhtmanzana;
DEFINE V_uhtotros LIKE bdisolic:"informix".ss_osclientesupervisar.uhtotros;
DEFINE V_uhtandador LIKE bdisolic:"informix".ss_osclientesupervisar.uhtandador;
DEFINE V_uhtetapa LIKE bdisolic:"informix".ss_osclientesupervisar.uhtetapa;
DEFINE V_uhtlote LIKE bdisolic:"informix".ss_osclientesupervisar.uhtlote;
DEFINE V_uhtedificio LIKE bdisolic:"informix".ss_osclientesupervisar.uhtedificio;
DEFINE V_uhtentrada LIKE bdisolic:"informix".ss_osclientesupervisar.uhtentrada;
--Campos del 71 al 80
DEFINE V_telefonotrabajo LIKE bdisolic:"informix".ss_osclientesupervisar.telefonotrabajo;
DEFINE V_extensiontrabajo LIKE bdisolic:"informix".ss_osclientesupervisar.extensiontrabajo;
DEFINE V_puesto LIKE bdisolic:"informix".ss_osclientesupervisar.puesto;
DEFINE V_opcionpuesto LIKE bdisolic:"informix".ss_osclientesupervisar.opcionpuesto;
DEFINE V_fechaantiguedadtrabajo LIKE bdisolic:"informix".ss_osclientesupervisar.fechaantiguedadtrabajo;
DEFINE V_clienteconyuge LIKE bdisolic:"informix".ss_osclientesupervisar.clienteconyuge;
--jom corrige error de datos 18/12/2007
DEFINE V_clienteconyuge_paso VARCHAR(20);
--jom corrige error de datos 18/12/2007

DEFINE V_nombreconyuge LIKE bdisolic:"informix".ss_osclientesupervisar.nombreconyuge;
DEFINE V_nombre1conyuge LIKE bdisolic:"informix".ss_osclientesupervisar.nombre1conyuge;
DEFINE V_nombre2conyuge LIKE bdisolic:"informix".ss_osclientesupervisar.nombre2conyuge;
DEFINE V_apellidopaternoconyuge LIKE bdisolic:"informix".ss_osclientesupervisar.apellidopaternoconyuge;
DEFINE V_apellidomaternoconyuge LIKE bdisolic:"informix".ss_osclientesupervisar.apellidomaternoconyuge;
DEFINE V_lugartrabajoconyuge LIKE bdisolic:"informix".ss_osclientesupervisar.lugartrabajoconyuge;
--Campos del 81 al 90
DEFINE V_ciudadconyuge LIKE bdisolic:"informix".ss_osclientesupervisar.ciudadconyuge;
DEFINE V_coloniaconyuge LIKE bdisolic:"informix".ss_osclientesupervisar.coloniaconyuge;
DEFINE V_calletrabajoconyuge LIKE bdisolic:"informix".ss_osclientesupervisar.calletrabajoconyuge;
DEFINE V_casatrabajoconyuge LIKE bdisolic:"informix".ss_osclientesupervisar.casatrabajoconyuge;

DEFINE V_deptoointeriorconyuge LIKE bdisolic:"informix".ss_osclientesupervisar.deptoointeriorconyuge;
DEFINE V_rumbotrabajoconyuge LIKE bdisolic:"informix".ss_osclientesupervisar.rumbotrabajoconyuge;
DEFINE V_complementoconyuge LIKE bdisolic:"informix".ss_osclientesupervisar.complementoconyuge;
DEFINE V_flaguhy LIKE bdisolic:"informix".ss_osclientesupervisar.flaguhy;
DEFINE V_uhymanzana LIKE bdisolic:"informix".ss_osclientesupervisar.uhymanzana;
DEFINE V_uhyotros LIKE bdisolic:"informix".ss_osclientesupervisar.uhyotros;
--Campos del 91 al 100
DEFINE V_uhyandador LIKE bdisolic:"informix".ss_osclientesupervisar.uhyandador;
DEFINE V_uhyetapa LIKE bdisolic:"informix".ss_osclientesupervisar.uhyetapa;
DEFINE V_uhylote LIKE bdisolic:"informix".ss_osclientesupervisar.uhylote;
DEFINE V_uhyedificio LIKE bdisolic:"informix".ss_osclientesupervisar.uhyedificio;
DEFINE V_uhyentrada LIKE bdisolic:"informix".ss_osclientesupervisar.uhyentrada;
DEFINE V_telefonotrabajoconyuge LIKE bdisolic:"informix".ss_osclientesupervisar.telefonotrabajoconyuge;
DEFINE V_telefonocelularconyuge LIKE bdisolic:"informix".ss_osclientesupervisar.telefonocelularconyuge;
DEFINE V_claveconyugefamilia LIKE bdisolic:"informix".ss_osclientesupervisar.claveconyugefamilia;
DEFINE V_clientereferencia LIKE bdisolic:"informix".ss_osclientesupervisar.clientereferencia;
DEFINE V_nombrereferencia LIKE bdisolic:"informix".ss_osclientesupervisar.nombrereferencia;
DEFINE V_nombre1referencia LIKE bdisolic:"informix".ss_osclientesupervisar.nombre1referencia;
DEFINE V_nombre2referencia LIKE bdisolic:"informix".ss_osclientesupervisar.nombrereferencia;
--Campos del 101 al 110
DEFINE V_apellidopaternoreferencia LIKE bdisolic:"informix".ss_osclientesupervisar.apellidopaternoreferencia;
DEFINE V_apellidomaternoreferencia LIKE bdisolic:"informix".ss_osclientesupervisar.apellidomaternoreferencia;
DEFINE V_ciudadreferencia LIKE bdisolic:"informix".ss_osclientesupervisar.ciudadreferencia;
DEFINE V_coloniareferencia LIKE bdisolic:"informix".ss_osclientesupervisar.coloniareferencia;
DEFINE V_callereferencia LIKE bdisolic:"informix".ss_osclientesupervisar.callereferencia;
DEFINE V_casareferencia LIKE bdisolic:"informix".ss_osclientesupervisar.casareferencia;
DEFINE V_deptoointeriorreferencia LIKE bdisolic:"informix".ss_osclientesupervisar.deptoointeriorreferencia;
DEFINE V_rumboreferencia LIKE bdisolic:"informix".ss_osclientesupervisar.rumboreferencia;
DEFINE V_complementoreferencia LIKE bdisolic:"informix".ss_osclientesupervisar.complementoreferencia;
DEFINE V_flaguhr LIKE bdisolic:"informix".ss_osclientesupervisar.flaguhr;
--Campos del 111 al 120
DEFINE V_uhrmanzana LIKE bdisolic:"informix".ss_osclientesupervisar.uhrmanzana;
DEFINE V_uhrotros LIKE bdisolic:"informix".ss_osclientesupervisar.uhrotros;
DEFINE V_uhrandador LIKE bdisolic:"informix".ss_osclientesupervisar.uhrandador;
DEFINE V_uhretapa LIKE bdisolic:"informix".ss_osclientesupervisar.uhretapa;
DEFINE V_uhrlote LIKE bdisolic:"informix".ss_osclientesupervisar.uhrlote;
DEFINE V_uhredificio LIKE bdisolic:"informix".ss_osclientesupervisar.uhredificio;
DEFINE V_uhrentrada LIKE bdisolic:"informix".ss_osclientesupervisar.uhrentrada;
DEFINE V_telefonoreferencia LIKE bdisolic:"informix".ss_osclientesupervisar.telefonoreferencia;
DEFINE V_telefonocelularreferencia LIKE bdisolic:"informix".ss_osclientesupervisar.telefonocelularreferencia;
DEFINE V_referencia3 LIKE bdisolic:"informix".ss_osclientesupervisar.referencia3;
--Campos del 121 al 124
DEFINE V_referencia4 LIKE bdisolic:"informix".ss_osclientesupervisar.referencia4;
DEFINE V_efectuo LIKE bdisolic:"informix".ss_osclientesupervisar.efectuo;
DEFINE V_fechamovto LIKE bdisolic:"informix".ss_osclientesupervisar.fechamovto;
DEFINE v_limitecredito LIKE bdisolic:"informix".ss_solicitudes.monto_solicitado;
--verificar que el tipo y la longitud de los datos de las diversas tablas sea equivalente al campo donde se INSERTa
--Variables auxiliares
DEFINE aux_numcte_ref LIKE bdisolic:"informix".ss_solicitudes.numcte;
DEFINE aux_claveconyugefamilia CHAR(2);
DEFINE aux_tipo_cliente LIKE bdinteg:"informix".si_cliente.tipo_cliente;
DEFINE aux_telefono_ref LIKE bdinteg:"informix".si_refdirecciones.telefono1;
-- Se agregan las variables V_ciudadCoppel, V_coloniaCoppel y V_NombreZonaCoppel para llenar los campos ciudadcoppel, coloniacoppel y nombrezonacoppel en ss_osclientesupervisar
DEFINE V_ciudadCoppel LIKE bdisolic:"informix".ss_osclientesupervisar.ciudadcoppel;
DEFINE V_coloniaCoppel LIKE bdisolic:"informix".ss_osclientesupervisar.coloniacoppel;
DEFINE V_NombreZonaCoppel LIKE bdisolic:"informix".ss_osclientesupervisar.nombrezonacoppel;

DEFINE V_ciudadtrabajocoppel LIKE bdisolic:"informix".ss_osclientesupervisar.ciudadtrabajocoppel;
DEFINE V_coloniatrabajocoppel LIKE bdisolic:"informix".ss_osclientesupervisar.coloniatrabajocoppel;
DEFINE V_nombrezonatrabajocoppel LIKE bdisolic:"informix".ss_osclientesupervisar.nombrezonatrabajocoppel;
DEFINE v_NumProducto             LIKE bdisolic:"informix".ss_solicitudes.num_producto;
DEFINE v_prefijo_os_prod           CHAR(1);

DEFINE iHayDatosFamiliar, iHayDatosReferencia, iTotalReferencias        INTEGER;
DEFINE vtelefonoCasa, vtelefonotrabajo, aux_telefonotrabajoconyuge    CHAR(13);
DEFINE aux_extension                CHAR(5);
DEFINE aux_status                   CHAR(1);
DEFINE SQL_ERR, ISAM_ERR            INTEGER;
DEFINE ERROR_INFO       VARCHAR(80);
DEFINE P_COD_RET        VARCHAR(5);
DEFINE P_MENSAJE        VARCHAR(80);
DEFINE scod_ret6        VARCHAR(6); --Para recuperar el cÃÂ?ÃÂÃÂ³digo de error de sp_actualiza_status_sol
DEFINE iEncuentraSolic, iCuantos, iAniosHabita, iMax                    INTEGER;
DEFINE wBegin           CHAR(1);

DEFINE iSalMin, iLimInfCL, iAuxCasa, iAuxProvocado          INTEGER;  --Se agrega variable para guardar limite inferior para clientes nuevos
DEFINE vauxcasa, vauxdepto, vauxdeptotrabajo, vauxcasatrabajo          VARCHAR(20);
DEFINE dFechaEnt        DATE;
DEFINE sStatus_solic    VARCHAR(2);
DEFINE iAuxElemento     INTEGER;
DEFINE dFechaSolCred    DATE;
DEFINE vauxinterior     VARCHAR(20);
DEFINE aux_numintcalle  VARCHAR(10);
DEFINE aux_numintrabajo VARCHAR(10);
DEFINE aux_numintrabCon VARCHAR(10);
DEFINE tempv_Casa       VARCHAR(20);
DEFINE iAuxCalleAsignar INTEGER;
DEFINE vvalor_numerico  DECIMAL (18,2);

DEFINE v_flagproductocoppel	SMALLINT;
DEFINE v_tipoos 			CHAR(1);
DEFINE v_tipoproducto 		CHAR(5);
DEFINE v_ProductoCoppel 	CHAR(4);
DEFINE v_secuencia 			INTEGER;
DEFINE v_secuenciaRef2		INTEGER;
DEFINE cSucCajaUnica    CHAR(1);
DEFINE cSucursal    CHAR(4);
DEFINE dtFechaAtualizacion    DATE;
DEFINE V_apellidopaterno1referencia, V_apellidomaterno1referencia, V_apellidopaterno1conyuge, V_apellidomaterno1conyuge   CHAR(26);
DEFINE cNombreCompletoReferencia   CHAR(107);
DEFINE iSoloCoppel  INTEGER;
DEFINE cSucursalCoppel  CHAR(4);
DEFINE V_Empresa CHAR(3);
DEFINE V_casatrabajoconyugeAux Char(10);
DEFINE cCodRetActEst CHAR(6);
DEFINE cStatusCteProsFinal CHAR(2);
DEFINE cNumSolicitud CHAR(20);
DEFINE cAuxStatus CHAR(1);
DEFINE dtFechaHoy DATE;
DEFINE dtFechaSolicitud DATE;
DEFINE cCodRetActEstProspTit CHAR(6);

DEFINE cMensajeRet 	CHAR(80);

DEFINE iMotivoOS        INTEGER;
LET iMotivoOS	= 0;

LET cMensajeRet = "";

LET V_numcte = "";
LET v_flagproductocoppel = 0;
LET	v_tipoos = "S";
LET v_tipoproducto = "";
LET V_apellidopaterno1 = "";
LET V_apellidomaterno1 = "";
LET V_nombre1conyuge = "";
LET V_nombre2conyuge = "";
LET V_nombre1referencia = "";
LET V_nombre2referencia = "";
LET V_NumSolicitud_Cliente  = '';
LET V_FechaSolicitud_Cliente  = DATE(1);
LET cSucCajaUnica       = "";
LET cSucursal       = "";
LET dtFechaAtualizacion   = DATE(1);
LET V_apellidopaterno1referencia  = "";
LET V_apellidomaterno1referencia  = "";
LET V_apellidopaterno1conyuge  = "";
LET V_apellidomaterno1conyuge  = "";
LET cNombreCompletoReferencia  = "";
LET iSoloCoppel  = 0;
LET cSucursalCoppel  = "";
LET vvalor_numerico  =0;

LET V_FechaImpresion = Date(1);
LET V_FechaRespuesta = Date(1);
LET V_EstatusOs = 0;
LET vtelefonotrabajo ='';
LET vtelefonoCasa ='';
LET v_secuencia = 0;
LET vtelefonoCasa ='';
LET vtelefonotrabajo  ='';
LET aux_telefonotrabajoconyuge  ='';
LET V_clave = '';
LET V_telefono = 0;
LET V_telefonocelular = 0;
LET V_fechadesdecuandoviveahi = date(1);
LET V_tiposueldo = '1';
LET V_personastrabajan          = 0;
LET V_situacionespecial         = '';
LET V_causasituacionespecial    = 0;
LET V_claveautrechaza           = '';
LET V_creditojoven              = '';
LET V_telefonotrabajo           = 0;
LET V_fechaantiguedadtrabajo    = Date(1);
LET V_clientereferencia = 0;
LET V_referencia3   = 0;
LET V_referencia4   = '';
LET V_efectuo       = '';
LET v_limitecredito =  0;
LET v_flagproductocoppel = 0;
LET P_cod_ret = '00000';
LET V_Empresa = '';
LET v_numproducto = '';
LET ianioshabita = 0;
LET P_MENSAJE ='';
let v_clienteconyuge = '';
let v_lugartrabajoconyuge ='';
let V_ciudadtrabajocoppel = 0;
let V_coloniatrabajocoppel=0;
LET V_casatrabajoconyugeAux = '';
let V_casatrabajoconyuge = '';
let v_casareferencia ='';
LET cCodRetActEst = ''; ---Se inicializa variable (cCodRetActEst) para validar la ejecucion del sp_ctepr_actualizastatus.
LET cStatusCteProsFinal = ''; ---Se inicializa variable (cStatusCteProsFinal) para obtener para obtener el estatus final despues de las actualizaciones cliente.
LET cNumSolicitud = '';
LET cAuxStatus = '';
LET dtFechaHoy = '';
LET dtFechaSolicitud = '';
LET cCodRetActEstProspTit = '000000';



    BEGIN
        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
           LET P_COD_RET = SQL_ERR;
	       LET P_MENSAJE = ERROR_INFO;
          
           IF SQL_ERR = -1213 THEN
               LET P_MENSAJE = 'Error conversion carÃÂ?ÃÂÃÂ¡cter a nÃÂ?ÃÂÃÂºmerico, probable num de casa cliente incorrecto.';
           END IF;

           RETURN P_COD_RET,P_MENSAJE ;
        END EXCEPTION;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
	-- SE EJECUTARA EL sp_os_integracion SOLO UNA VEZ POR CLIENTE EN VEZ DE POR CADA SOLICITUD

	 SELECT num_solicitud, status,fecha_solicitud
	 INTO  cNumSolicitud, cAuxStatus,dtFechaSolicitud
	 FROM bdiprospectos:"informix".pr_solicitud_os
	 WHERE empresa = '001'
	   AND num_solicitud = pNumSolicitud
	   AND status = 'S';


	LET P_cod_ret = '00000';
	LET P_MENSAJE ='';

	--Se valida el estatus de la solicitud para checar si existe una en proceso continuar con la siguiente solicitud.
	IF NVL(cAuxStatus,'') = '' THEN
		LET P_cod_ret = '00021';
		LET P_MENSAJE = 'No se encuentra registro de la Solicitud en la tabla pr_solicitud_os';
	END IF;



	  SELECT empresa
	    INTO V_Empresa
	  FROM bdisolic:"informix".ss_osclientesupervisar
	 WHERE empresa = '001'
	   AND num_solicitud = pNumSolicitud
	   --AND fechasolicitud = V_FechaSolicitud;
	   	   --AND fechasolicitud > dtFechaHora;--Se quita para corregir error de procesamiendo de solicitudes duplicadas INC 27 059 JMAH
	   AND fechasolicitud = dtFechaSolicitud;

		if V_Empresa <> ''  then
			LET P_cod_ret = '00001';
			LET P_MENSAJE = 'El Cliente ya cuenta con una OS';
			return P_cod_ret,P_MENSAJE;
		end if;


     let V_numcte = substr(pNumSolicitud,2,length(pNumSolicitud)-1);
      SELECT {+FULL} nvl(MAX(secuencia),0), COUNT(*)
	    INTO iMax, iCuantos
		FROM bdisolic:"informix".ss_ossecuencia;
			LET iMax    = iMax + 1;

      select first 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(TRIM(telefono),'')) = 'V' 
			THEN telefono ELSE '0000000000' END
		into  vtelefonoCasa
        from bdiprospectos:pr_telefonos
        where empresa = pEmpresa
         and numcte_pros =pNumSolicitud
         and tipo_tel = 1
         and status_tel ='A'
         and secuencia =  ( select max(secuencia)
                              from bdiprospectos:pr_telefonos
                             where empresa = pEmpresa
		                 and numcte_pros =pNumSolicitud
                               and tipo_tel = 1
                               and status_tel ='A');

	select first 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(TRIM(telefono),'')) = 'V' 
			THEN telefono ELSE '0000000000' END
        into V_telefonocelular 
        from bdiprospectos:pr_telefonos
       where empresa = pEmpresa
         and numcte_pros = pNumSolicitud
         and tipo_tel = 2
         and status_tel ='A'
	  and secuencia =  ( select max(secuencia)
                              from bdiprospectos:pr_telefonos
                             where empresa = pEmpresa
		                 and numcte_pros =pNumSolicitud
                               and tipo_tel = 2
                               and status_tel ='A');
							   
      select first 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(TRIM(telefono),'')) = 'V' 
			THEN telefono ELSE '0000000000' END, extension
        into vtelefonotrabajo , aux_extension
        from bdiprospectos:pr_telefonos
       where empresa = pEmpresa
         and numcte_pros = pNumSolicitud
         and tipo_tel = 3
         and status_tel ='A'
	  and secuencia =  ( select max(secuencia)
                              from bdiprospectos:pr_telefonos
                             where empresa = pEmpresa
		                 and numcte_pros =pNumSolicitud
                               and tipo_tel = 3
                               and status_tel ='A');

		----------REFERENCIAS
      select   first 1 secuencia ,trim(nombre1),trim(nombre2), apell_paterno, apell_materno,  parentesco
        into  v_secuencia, V_nombre1conyuge, V_nombre2conyuge, V_apellidopaternoconyuge, V_apellidomaternoconyuge,V_claveconyugefamilia
       from bdiprospectos:pr_refclientes
       where empresa  = pEmpresa
        and numcte_pros = pNumSolicitud
        and parentesco = 'E';

		let V_nombreconyuge = V_nombre1conyuge ||' ' ||  V_nombre2conyuge;

		let V_apellidopaterno1conyuge = V_apellidopaternoconyuge;
		let V_apellidomaterno1conyuge =V_apellidomaternoconyuge;

      select  --- telefono3 , 
			  CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(TRIM(telefono3),'')) = 'V' 
					THEN telefono3 ELSE '0000000000' END,
			  nvl(numerociudad,0), nvl(numerocolonia,0), nvl(numerocalle,0), TRIM(nvl(numeroextcalle, '')), trim(departamento),
	          TRIM(puntocardinal),TRIM(entre_calles), decode(nvl(unidadhabitac, 'N'), 'S', '1', '0'), manzana,
			  otros, andador, etapa,lote,edificio,entrada, --- telefono2
			  CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(TRIM(telefono2),'')) = 'V' 
					THEN telefono2 ELSE '0000000000' END
        into  aux_telefonotrabajoconyuge,V_ciudadconyuge, V_coloniaconyuge, V_calletrabajoconyuge, V_casatrabajoconyugeAux, V_deptoointeriorconyuge,
		      V_rumbotrabajoconyuge, V_complementoconyuge, V_flaguhy, V_uhymanzana,V_uhyotros, V_uhyandador, V_uhyetapa,
			  V_uhylote, V_uhyedificio, V_uhyentrada,V_telefonocelularconyuge
       from bdiprospectos:pr_refdirecciones
       where numcte_pros = pNumSolicitud
        and secuencia = v_secuencia
        and tipo_dir =1 ;

		if EsNumeroCasa(V_casatrabajoconyugeAux) = 1 then
			let V_casatrabajoconyuge  =V_casatrabajoconyugeAux;
		else
			let V_casatrabajoconyuge  = 0;
		end if;

		LET  V_telefonotrabajoconyuge = aux_telefonotrabajoconyuge;
		IF TRIM(nvl(V_nombreconyuge,'')) = '' THEN LET v_secuencia = 0; END IF;
		----- PRIMER  REFERENCIA
      select   first 1 secuencia, trim(nombre1),  trim(nombre2), apell_paterno, apell_materno
        into  v_secuenciaRef2, V_nombre1referencia, V_nombre2referencia, V_apellidopaternoreferencia, V_apellidomaternoreferencia
       from bdiprospectos:pr_refclientes
       where empresa  = pEmpresa
        and numcte_pros = pNumSolicitud
        and secuencia <> v_secuencia;

		let V_nombrereferencia = V_nombre1referencia || ' ' ||V_nombre2referencia;
		let V_apellidopaterno1referencia  =V_apellidopaternoreferencia;
		let V_apellidomaterno1referencia =V_apellidomaternoreferencia;

	   select  --- telefono1 , 
			  CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(TRIM(telefono1),'')) = 'V' 
					THEN telefono1 ELSE '0000000000' END,
			  nvl(numerociudad,0),  nvl(numerocolonia,0), nvl(numerocalle,0), TRIM(nvl(numeroextcalle, '')), trim(departamento),
	          TRIM(puntocardinal),TRIM(entre_calles), decode(nvl(unidadhabitac, 'N'), 'S', '1', '0'), manzana,
			  otros, andador, etapa,lote,edificio,entrada, ---telefono2
			  CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(TRIM(telefono2),'')) = 'V' 
					THEN telefono2 ELSE '0000000000' END
        into  V_telefonoreferencia, V_ciudadreferencia, V_coloniareferencia, V_callereferencia,V_casatrabajoconyugeAux, V_deptoointeriorreferencia,
		      V_rumboreferencia, V_complementoreferencia, V_flaguhr, V_uhrmanzana, V_uhrotros, V_uhrandador, V_uhretapa,
			  V_uhrlote, V_uhredificio, V_uhrentrada, V_telefonocelularreferencia
       from bdiprospectos:pr_refdirecciones
       where numcte_pros = pNumSolicitud
        and secuencia = v_secuenciaRef2
        and tipo_dir =1 ;

		if EsNumeroCasa(v_casareferencia) = 1 then
			let V_casatrabajoconyuge  =v_casareferencia;
		else
			let V_casatrabajoconyuge  = 0;
		end if;

		--VZRI, Se omite segunda referencia
		-----SEGUNDA REFERENCIA
		 /*IF TRIM(nvl(V_nombreconyuge,'')) = '' THEN
         select  first 1 secuencia ,trim(nombre1),trim(nombre2), apell_paterno, apell_materno,  parentesco
           into  v_secuencia, V_nombre1conyuge, V_nombre2conyuge, V_apellidopaternoconyuge, V_apellidomaternoconyuge,V_claveconyugefamilia
           from bdiprospectos:pr_refclientes
          where empresa  = pEmpresa
           and numcte_pros = pNumSolicitud
           and parentesco <> 'E'
		   and secuencia <> v_secuenciaRef2 ;

		let V_nombreconyuge = V_nombre1conyuge ||' ' ||  V_nombre2conyuge;

		let V_apellidopaterno1conyuge = V_apellidopaternoconyuge;
		let V_apellidomaterno1conyuge =V_apellidomaternoconyuge;

      select   ---telefono3 , 
			  CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(TRIM(telefono3),'')) = 'V' 
					THEN telefono3 ELSE '0000000000' END,
			  nvl(numerociudad,0), nvl(numerocolonia,0), nvl(numerocalle,0), TRIM(nvl(numeroextcalle, '')), trim(departamento),
	          TRIM(puntocardinal),TRIM(entre_calles), decode(nvl(unidadhabitac, 'N'), 'S', '1', '0'), manzana,
			  otros, andador, etapa,lote,edificio,entrada, --- telefono2
			  CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(TRIM(telefono2),'')) = 'V' 
					THEN telefono2 ELSE '0000000000' END
        into  aux_telefonotrabajoconyuge,V_ciudadconyuge, V_coloniaconyuge, V_calletrabajoconyuge, V_casatrabajoconyugeAux, V_deptoointeriorconyuge,
		      V_rumbotrabajoconyuge, V_complementoconyuge, V_flaguhy, V_uhymanzana,V_uhyotros, V_uhyandador, V_uhyetapa,
			  V_uhylote, V_uhyedificio, V_uhyentrada,V_telefonocelularconyuge
       from bdiprospectos:pr_refdirecciones
       where numcte_pros = pNumSolicitud
        and secuencia = v_secuencia
        and tipo_dir =1 ;
        END IF;

		if EsNumeroCasa(V_casatrabajoconyugeAux) = 1 then
			let V_casatrabajoconyuge  = V_casatrabajoconyugeAux;
		else
			let V_casatrabajoconyuge  =0;
		end if;
		*/
		
		
	   --IF (nvl(V_nombre1conyuge,'') = '' or nvl( V_nombrereferencia,'' )=''  ) THEN
	   --IF (nvl(V_nombre1conyuge,'') = '' and nvl( V_nombrereferencia,'' )=''  ) THEN
	   --VZRI, Se agrega validacion para conyuge
	   IF ( nvl( V_nombreconyuge,'' )=''  AND nvl( V_nombrereferencia,'' )=''  ) THEN
					LET P_cod_ret = '00004';    --No tiene referencias
					LET P_MENSAJE = 'No tiene referencias.';
					--continue FOREACH;
	   END IF;

	----------DIRECCION DEL CLIENTE
      select first 1 observaciones, nvl(numerociudad,0), nvl(numerocolonia,0), nvl(numerocalle,0), TRIM(nvl(numeroextcalle, '')), trim(departamento),
            TRIM(puntocardinal),TRIM(entre_calles), decode(nvl(unidadhabitac, 'N'), 'S', '1', '0'), manzana, otros, andador, etapa,
			lote,edificio,entrada, TRIM(nvl(numerointcalle,''))
        into  V_Observacion2, V_ciudad, V_colonia, V_calle,vauxcasa, vauxdepto, V_rumbo, V_complemento,
              V_flaguhc, V_uhcmanzana, V_uhcotros, V_uhcandador, V_uhcetapa, V_uhclote, V_uhcedificio,
              V_uhcentrada, aux_numintcalle
       from bdiprospectos:"informix".pr_direcciones
       where numcte_pros = pNumSolicitud
        and tipo_dir =1
        and secuencia = (select max(secuencia) from  bdiprospectos:pr_direcciones where numcte_pros = pNumSolicitud and tipo_dir =1 );

		
		LET vtelefonoCasa      		= replace(vtelefonoCasa ,'\','');
		LET vtelefonoCasa      		= replace(vtelefonoCasa ,'|','');
		LET vtelefonoCasa      		= replace(vtelefonoCasa ,'''','');
		
		LET V_telefonocelular      	= replace(V_telefonocelular ,'\','');
		LET V_telefonocelular      	= replace(V_telefonocelular ,'|','');
		LET V_telefonocelular      	= replace(V_telefonocelular ,'''','');
	--DSBJAGG12082016 	
		LET vtelefonoCasa				= LPAD(TRIM(NVL(vtelefonoCasa, '')), 10, 0);
		LET V_telefonocelular			= LPAD(TRIM(NVL(V_telefonocelular, '')), 10, 0);
		LET V_telefonoreferencia		= LPAD(TRIM(NVL(V_telefonoreferencia, '')), 10, 0);	
		LET vtelefonotrabajo			= LPAD(TRIM(NVL(vtelefonotrabajo, '')), 10, 0);
		LET aux_telefonotrabajoconyuge	= LPAD(TRIM(NVL(aux_telefonotrabajoconyuge, '')), 10, 0);
		
      --LET V_Observacion1      = SUBSTR(vtelefonoCasa, 1, 10) ||SUBSTR(vtelefonotrabajo, 1, 10) ||SUBSTR(aux_telefonotrabajoconyuge, 1, 10);
	  LET V_Observacion1      = SUBSTR(V_telefonocelular, 1, 10) ||SUBSTR(vtelefonoCasa, 1, 10) ||SUBSTR(V_telefonoreferencia, 1, 10);
      

      LET V_Observacion2      = replace(V_Observacion2 ,'\','/');
      LET V_Observacion2      = replace(V_Observacion2 ,'|',' ');
      LET V_Observacion2      = replace(V_Observacion2 ,'''',' ');



	IF bdisolic:EsNumeroCasa(vauxcasa) = 0 THEN
        IF LENGTH(TRIM (vauxcasa)) > 0 THEN
          LET Vauxcasa = 'CASA:' || TRIM(Vauxcasa) ||',';
	    END IF;
	    LET V_Casa = '0';
	  ELSE
		LET V_Casa = TRIM(Vauxcasa);
		LET Vauxcasa='';
	  END IF;

	  IF LENGTH(TRIM(vauxdepto)) < 5 THEN
        LET V_deptoointerior= TRIM(vauxdepto);
		LET vauxdepto='';
      ELSE
        LET vauxdepto='DEP:'||vauxdepto||',';
        LET V_deptoointerior='';
      END IF;

	  IF LENGTH(TRIM(aux_numintcalle)) > 0 THEN
        IF LENGTH (TRIM(aux_numintcalle))< 5 AND V_deptoointerior='' THEN
          LET V_deptoointerior= TRIM(aux_numintcalle);
          LET aux_numintcalle='';
        ELSE
          LET aux_numintcalle= 'INT:'||TRIM(aux_numintcalle)||',';
        END IF;
      END IF;

      LET V_complemento= TRIM(Vauxcasa)||TRIM(vauxdepto)||TRIM(aux_numintcalle)||TRIM(V_complemento);

	  IF SUBSTR(V_complemento,LENGTH(V_complemento),1)=',' THEN
        LET V_complemento=SUBSTR(V_complemento,1,LENGTH(V_complemento)-1);
      END IF;

      SELECT prefijo_os INTO v_prefijo_os_prod FROM bdicred:"informix".sd_definicion WHERE num_producto = v_NumProducto;

      IF LENGTH(V_complemento) > 28 THEN
        LET V_complemento =  v_prefijo_os_prod || '/' || (SUBSTR(V_complemento,1,LENGTH(V_complemento)-2));
      ELSE
        LET V_complemento =  v_prefijo_os_prod || '/' || V_complemento;
      END IF;

      IF (iAniosHabita = 0) or   (iAniosHabita = -1)  THEN
        LET V_fechadesdecuandoviveahi   = pFechaSolicitud;
      ELSE
        IF day(dFechaSolCred) = 29 AND month(pFechaSolicitud) = 2 AND mod(pFechaSolicitud, 4) <> 0 THEN
		  LET V_fechadesdecuandoviveahi = (pFechaSolicitud - 1) - iAniosHabita units year;
		ELSE
		  LET V_fechadesdecuandoviveahi = pFechaSolicitud - iAniosHabita units year;
		END IF;
      END IF;

	  ---VALIDACION DE ZONA DE COPPEL
 	 SELECT numerocoloniacoppel, nombrezonacoppel, numerociudadcoppel
	    INTO V_coloniaCoppel, V_NombreZonaCoppel, V_ciudadCoppel
 	   FROM bdinteg:"informix".si_catzonas
	   WHERE numerociudad = V_ciudad AND numerocolonia = V_colonia;

	  IF nvl(V_ciudadCoppel,0) =0  or nvl(V_ciudadCoppel,0) = 0
				OR nvl(V_NombreZonaCoppel ,'') = '' THEN
					LET P_cod_ret = '00018';
					LET P_MENSAJE = 'CATALOGO NO RELACIONADO EN CIUDAES Y COLONIAS COPPEL-BANCOPPEL';
					--continue FOREACH;
				--Se ejecuta procedimiento para actualizar el estatus del cliente en la tabla pr_cliente e insertar un registro del estatus
				--en pr_autorizacion el estatus que se almacenara es el "CE" (Catalago de Domicilio en Estudio), solo cuando no exista la
				--relacion con el catalogo coppel.
				EXECUTE PROCEDURE bdiprospectos:"informix".sp_ctepr_actualizastatus("sistema",pNumSolicitud,"CE", "", "")
				INTO cCodRetActEst;

				--Se valida la ejecucion del procedimiento.
				IF cCodRetActEst <> "000000" THEN
					LET P_cod_ret = '00020';
					LET P_MENSAJE = 'OCURRIO UN ERROR EN EL PROCEDIMIENTO bdiprospectos:sp_ctepr_actualizastatus';
				END IF ;

				--SE MANDA A EJECUTAR EL NUEVO PROCEDIMIENTO PARA HEREDAR EL ESTATUS DEL PROSPECTO A TABLAS DE TITULARES.
				EXECUTE PROCEDURE "informix".sp_os_actualizastatusprospectotitular(pEmpresa,pNumSolicitud)
				INTO cCodRetActEstProspTit,cMensajeRet;
				--SE VALIDA LA EJECUCION DEL PROCEDIMIENTO.
				--IF CAST(cCodRetActEstProspTit AS INTEGER) <> 0 THEN
				IF CAST(cCodRetActEstProspTit AS INTEGER) = 1  OR CAST(cCodRetActEstProspTit AS INTEGER) = 3  OR CAST(cCodRetActEstProspTit AS INTEGER) < 0 THEN
					LET P_cod_ret = '00021';
					LET P_MENSAJE = 'OCURRIO UN ERROR EN EL PROCEDIMIENTO bdisolic:sp_os_actualizastatusprospectotitular';
				END IF ;
	  END IF;

	  	------INGRESOS

      select ingreso_mensual, nombre_empresa, puesto, puesto_esp
        into V_ingresomensual, V_lugartrabajo, V_puesto , V_opcionpuesto
        from bdiprospectos:pr_ingresos
       where empresa = pEmpresa
         and numcte_pros  = pNumSolicitud
         and sec_ingreso = (select max(sec_ingreso) from bdiprospectos:pr_ingresos
		                    where empresa =pEmpresa  and  numcte_pros = pNumSolicitud and tipo_ingreso = 'T' );

      SELECT {+INDEX("informix".ss_param idx_ss_param)} nvl(sp.valor,0)*1 as sal_min
        INTO iSalMin
        FROM bdisolic:"informix".ss_param sp
       WHERE sp.secuencia = 303 AND empresa = '001';

	  LET V_ingresomensual            = round(nvl(V_ingresomensual,0)/iSalMin);
      IF ( V_ingresomensual >32000 ) THEN --FMJ AGOSTO 2011
        LET P_cod_ret = '00019';
        LET P_MENSAJE = 'Ingreso Mensual No permitido para OS';
		--continue FOREACH;
      END IF;
	  
	

      IF P_cod_ret = '00000' THEN
	  
	    -----DIRECCION DE TRABAJO
	  SELECT numerociudad, numerocolonia, numerocalle, TRIM(nvl(numeroextcalle,'')), trim(departamento), puntocardinal,
			 TRIM(nvl(entre_calles,'')), decode(nvl(unidadhabitac, 'N'), 'S', '1', '0'), manzana, otros, andador, etapa,
			 lote, edificio, entrada, TRIM(nvl(numerointcalle,''))
			INTO V_ciudadtrabajo, V_coloniatrabajo, V_calletrabajo, Vauxcasatrabajo, vauxdeptotrabajo, V_rumbotrabajo,
				 V_complementotrabajo, V_flaguht, V_uhtmanzana, V_uhtotros, V_uhtandador, V_uhtetapa,
				 V_uhtlote, V_uhtedificio, V_uhtentrada, aux_numintrabajo
	  from bdiprospectos:pr_direcciones
      where numcte_pros = pNumSolicitud
        and tipo_dir =2
        and secuencia = (select max(secuencia) from  bdiprospectos:pr_direcciones where numcte_pros = pNumSolicitud and tipo_dir =2 );

      IF bdisolic:EsNumeroCasa(Vauxcasatrabajo) = 0 THEN
        IF LENGTH(TRIM (Vauxcasatrabajo)) > 0 THEN
          LET Vauxcasatrabajo = 'CASA:'|| TRIM(Vauxcasatrabajo)||',';
        END IF;
	    LET V_casatrabajo= '0';
      ELSE
        LET V_casatrabajo= TRIM(Vauxcasatrabajo);
        LET Vauxcasatrabajo='';
      END IF;

      LET V_extensiontrabajo = 0;
	  IF bdisolic:EsNumerocasa(aux_extension) = 1 THEN
	    IF aux_extension*1 >0 AND aux_extension*1 <= 32767 THEN
		  LET V_extensiontrabajo = aux_extension;
		END IF;
	  END IF;

      IF LENGTH(TRIM(vauxdeptotrabajo)) < 5 THEN
        LET V_deptoointeriortrabajo= TRIM(vauxdeptotrabajo);
		LET vauxdeptotrabajo='';
      ELSE
        LET vauxdeptotrabajo='DEP:'||vauxdeptotrabajo||',';
        LET V_deptoointeriortrabajo='';
      END IF;

			IF LENGTH(TRIM(aux_numintrabajo)) > 0 THEN
				IF LENGTH (TRIM(aux_numintrabajo))< 5 AND V_deptoointeriortrabajo='' THEN
					LET V_deptoointeriortrabajo= TRIM(aux_numintrabajo);
					LET aux_numintrabajo='';
				 ELSE
					LET aux_numintrabajo= 'INT:'||TRIM(aux_numintrabajo)||',';
				END IF;
		   END IF;

		   LET V_complementotrabajo= TRIM(Vauxcasatrabajo)||TRIM(vauxdeptotrabajo)||TRIM(aux_numintrabajo)||TRIM(V_complementotrabajo);

		   IF SUBSTR(V_complementotrabajo,LENGTH(V_complementotrabajo),1)=',' THEN
				LET V_complementotrabajo=SUBSTR(V_complementotrabajo,1,LENGTH(V_complementotrabajo)-1);
		   END IF;

   			SELECT numerociudadcoppel, numerocoloniacoppel, nombrezonacoppel
			INTO V_ciudadtrabajocoppel, V_coloniatrabajocoppel, V_nombrezonatrabajocoppel
			FROM bdinteg:"informix".si_catzonas
			WHERE numerociudad = V_ciudadtrabajo AND numerocolonia = V_coloniatrabajo;

			let V_ciudadtrabajocoppel= nvl(V_ciudadtrabajocoppel,0);
			let V_coloniatrabajocoppel= nvl(V_coloniatrabajocoppel,0);

		----------DATOS DE LA PERSONA FISICA
      select curp,  numeroife, codidentifi, numidentifi, habita_en, sexo, bdisolic:fn_mapea_estado_civil(estado_civil),
             fecha_nac, nvl(anios_habita,0), escolaridad, dependientes , anios_habita
        into V_curp,V_claveelector, V_claveidentificacion, V_identificacion, V_casapropia, V_sexo, V_estadocivil,
             V_fechanacimiento, iAniosHabita, V_escolaridad, V_numerodependientes, iAniosHabita
        from bdiprospectos:pr_ctepf
        where empresa = pEmpresa
          and numcte_pros = pNumSolicitud;

	
	  LET V_nombre = trim(pNombre1) || ' ' || trim(pNombre2);
	  let V_apellidopaterno1 = pApellidopaterno;
	  let V_apellidomaterno1 = pApellidomaterno;
	  
				---Validar que se actualice bien la secuencia ---FAV
				IF iCuantos = 0 THEN
				   INSERT INTO bdisolic:"informix".ss_ossecuencia(secuencia) VALUES(iMax);
				ELSE
				   UPDATE bdisolic:"informix".ss_ossecuencia SET secuencia = iMax;
				END IF;
				LET V_folio = iMax;

				--Se ejecuta procedimiento para actualizar el estatus del cliente en la tabla pr_cliente e insertar un registro del estatus
				--en pr_autorizacion el estatus que se almacenara es el "OS" (Orden de Supervision), solo cuando el estatus este en Estudio de Supervision. XX.
				EXECUTE PROCEDURE bdiprospectos:"informix".sp_ctepr_actualizastatus("sistema",pNumSolicitud,"OS", "", "")
				INTO cCodRetActEst;

				LET v_tipoproducto = "00100"; --Se realiza la marcacion del tipo de producto para diferenciar los clientes tipo prospecto bancoppel.
				--LET v_tipoos = "G";	--Se realiza la marcacion del tipo de solicitud para diferenciar los clientes tipo prospecto bancoppel.
				LET v_tipoos = 'N';	--Se realiza la marcacion del tipo de solicitud para diferenciar los clientes tipo prospecto bancoppel.
				
				
				--Se valida la ejecucion del procedimiento.
				IF cCodRetActEst <> "000000" THEN
					LET P_cod_ret = '00020';
					LET P_MENSAJE = 'OCURRIO UN ERROR EN EL PROCEDIMIENTO bdiprospectos:sp_ctepr_actualizastatus';
					
					UPDATE bdiprospectos:"informix".pr_cliente
					SET estado_os  = 0
					WHERE numcte_pros = pNumSolicitud;
					INSERT INTO bdisolic:"informix".ss_os_errores(num_solicitud, fechasolicitud, Codigo_Error, descripcion_error, FechaProceso )
					VALUES(pNumSolicitud, pFechaSolicitud, P_COD_RET, P_MENSAJE, CURRENT);

					RETURN P_cod_ret,P_MENSAJE;
				END IF ;

				
			IF TRIM(V_NombreZonaCoppel) = "EL RASCÃÂ?ÃÂ?'N (LA LOMA)" THEN
			   LET V_NombreZonaCoppel = "EL RASCON (LA LOMA)";
			END IF;
			
			IF TRIM(V_nombrezonatrabajocoppel) = "EL RASCÃÂ?ÃÂ?'N (LA LOMA)" THEN
			   LET V_nombrezonatrabajocoppel = "EL RASCON (LA LOMA)";
			END IF;
            
			LET V_complementotrabajo = replace(V_complementotrabajo,'''','');
				
				
				INSERT INTO bdisolic:"informix".ss_osclientesupervisar(
					secuencia,    Empresa,     Num_Solicitud,  FechaSolicitud, FechaImpresion,     FechaRespuesta,     EstatusOs, Observacion1,
					Observacion2, clave, tiendafolio, folio, nombre, apellidopaterno, apellidomaterno, curp, claveelector, claveidentificacion,
					identificacion, ciudad, colonia, calle, casa, deptoointerior, rumbo, complemento, flaguhc, uhcmanzana, uhcotros, uhcandador,
					uhcetapa, uhclote, uhcedificio,uhcentrada,telefono,telefonocelular, casapropia, sexo, estadocivil, fechanacimiento,
					fechadesdecuandoviveahi, personasvivenendomicilio, tiposueldo, numerodependientes, personastrabajan, ingresomensual, situacionespecial,
					causasituacionespecial, claveautrechaza, creditojoven, lugartrabajo, ciudadtrabajo, coloniatrabajo, calletrabajo, casatrabajo,
					deptoointeriortrabajo, rumbotrabajo, complementotrabajo, flaguht,uhtmanzana, uhtotros, uhtandador, uhtetapa, uhtlote, uhtedificio,
					uhtentrada, telefonotrabajo, extensiontrabajo, puesto, opcionpuesto, fechaantiguedadtrabajo, clienteconyuge, nombreconyuge,
					apellidopaternoconyuge, apellidomaternoconyuge, lugartrabajoconyuge, ciudadconyuge, coloniaconyuge, calletrabajoconyuge, casatrabajoconyuge,
					deptoointeriorconyuge, rumbotrabajoconyuge, complementoconyuge, flaguhy, uhymanzana, uhyotros, uhyandador, uhyetapa, uhylote,
					uhyedificio, uhyentrada, telefonotrabajoconyuge, telefonocelularconyuge, claveconyugefamilia, clientereferencia, nombrereferencia,
					apellidopaternoreferencia, apellidomaternoreferencia, ciudadreferencia, coloniareferencia, callereferencia, casareferencia,
					deptoointeriorreferencia, rumboreferencia, complementoreferencia, flaguhr, uhrmanzana, uhrotros, uhrandador, uhretapa, uhrlote,
					uhredificio, uhrentrada, telefonoreferencia, telefonocelularreferencia, referencia3, referencia4, efectuo, fechaaltacliente, fechamovto,
					limitecredito, ciudadcoppel, coloniacoppel, nombrezonacoppel, ciudadtrabajocoppel, coloniatrabajocoppel, nombrezonatrabajocoppel,
					numeroclientebancoppel, flagproductocoppel, tipoos, tipoproducto, nombre1, nombre2, apellidopaterno1, apellidomaterno1, nombre1conyuge,
					nombre2conyuge,apellidopaterno1conyuge,apellidomaterno1conyuge,nombre1referencia, nombre2referencia,apellidopaterno1referencia,apellidomaterno1referencia
						)
				VALUES(
					iMax, pEmpresa, pNumSolicitud, dtFechaSolicitud, V_FechaImpresion, V_FechaRespuesta, V_EstatusOs, V_Observacion1,
					V_Observacion2, V_clave, pTiendafolio, V_folio, V_nombre, pApellidopaterno, pApellidomaterno, V_curp, V_claveelector, V_claveidentificacion,
					V_identificacion, V_ciudad, V_colonia, V_calle, V_casa, V_deptoointerior, V_rumbo, V_complemento, V_flaguhc, V_uhcmanzana, V_uhcotros, V_uhcandador,
					V_uhcetapa, V_uhclote, V_uhcedificio,V_uhcentrada, vtelefonoCasa, V_telefonocelular, V_casapropia, V_sexo, V_estadocivil, V_fechanacimiento,
					V_fechadesdecuandoviveahi, pPersonasvivenendomicilio, V_tiposueldo, V_numerodependientes, V_personastrabajan, V_ingresomensual, V_situacionespecial,
					V_causasituacionespecial, V_claveautrechaza, V_creditojoven,V_lugartrabajo, V_ciudadtrabajo, V_coloniatrabajo, V_calletrabajo, V_casatrabajo,
					V_deptoointeriortrabajo, V_rumbotrabajo, V_complementotrabajo, V_flaguht,V_uhtmanzana, V_uhtotros, V_uhtandador, V_uhtetapa, V_uhtlote, V_uhtedificio,
					V_uhtentrada, V_telefonotrabajo, V_extensiontrabajo, V_puesto, V_opcionpuesto, V_fechaantiguedadtrabajo, V_clienteconyuge, V_nombreconyuge,
					V_apellidopaternoconyuge, V_apellidomaternoconyuge, V_lugartrabajoconyuge, V_ciudadconyuge, V_coloniaconyuge, V_calletrabajoconyuge,
					V_casatrabajoconyuge, V_deptoointeriorconyuge, V_rumbotrabajoconyuge, V_complementoconyuge, V_flaguhy, V_uhymanzana, V_uhyotros,
					V_uhyandador, V_uhyetapa, V_uhylote, V_uhyedificio, V_uhyentrada, V_telefonotrabajoconyuge, V_telefonocelularconyuge, V_claveconyugefamilia,
					V_clientereferencia, V_nombrereferencia, V_apellidopaternoreferencia, V_apellidomaternoreferencia, V_ciudadreferencia, V_coloniareferencia, V_callereferencia,
					V_casareferencia, V_deptoointeriorreferencia, V_rumboreferencia, V_complementoreferencia, V_flaguhr, V_uhrmanzana, V_uhrotros, V_uhrandador, V_uhretapa,
					V_uhrlote, V_uhredificio, V_uhrentrada, V_telefonoreferencia, V_telefonocelularreferencia, V_referencia3, V_referencia4, V_efectuo, pFechaaltacliente,
					CURRENT,v_limitecredito, V_ciudadCoppel, V_coloniaCoppel, V_NombreZonaCoppel, V_ciudadtrabajocoppel, V_coloniatrabajocoppel, V_nombrezonatrabajocoppel,
					V_numcte, v_flagproductocoppel, v_tipoos, v_tipoproducto,pNombre1, pNombre2, V_apellidopaterno1, V_apellidomaterno1,
					V_nombre1conyuge, V_nombre2conyuge,V_apellidopaterno1conyuge, V_apellidomaterno1conyuge,
					V_nombre1referencia, V_nombre2referencia,V_apellidopaterno1referencia, V_apellidomaterno1referencia
						);

				--Se consulta de nuevo el estatus del cliente prospecto para verificar que si se genero la orden de supervision.
				SELECT status_numcte_pros
				INTO cStatusCteProsFinal
				FROM bdiprospectos:"informix".pr_cliente
				WHERE tipo_cliente = 3
					--AND estado_os =0
					AND numcte_pros = pNumSolicitud;

				--SE VALIDA QUE SOLO SEA PARA LOS ESTATUS EN ESTUDIO DE SUPERVISION.
				IF cStatusCteProsFinal = "OS" THEN
					UPDATE bdiprospectos:"informix".pr_cliente
					SET estado_os  = 1
					WHERE  numcte_pros = pNumSolicitud;

					-- 08/26/2015 - JOSUE ZAZUETA					
					SELECT num_parametro INTO iMotivoOS FROM ss_param_solicitudes WHERE secuencia = 15 AND grupo_parametro = 'MOTIVOS_OS';
					
					UPDATE bdiprospectos:"informix".pr_solicitud_os
					SET status = 'P',secuenciaos = iMax, motivo_os = NVL(iMotivoOS,0)
					WHERE num_solicitud = pNumSolicitud AND status = 'S';

					--SE MANDA A EJECUTAR EL NUEVO PROCEDIMIENTO PARA HEREDAR EL ESTATUS DEL PROSPECTO A TABLAS DE TITULARES.
					EXECUTE PROCEDURE "informix".sp_os_actualizastatusprospectotitular(pEmpresa,pNumSolicitud)
					INTO cCodRetActEstProspTit, cMensajeRet;
					--SE VALIDA LA EJECUCION DEL PROCEDIMIENTO.
					--IF CAST(cCodRetActEstProspTit AS INTEGER) <> 0 THEN
					IF CAST(cCodRetActEstProspTit AS INTEGER) = 1  OR CAST(cCodRetActEstProspTit AS INTEGER) = 3  OR CAST(cCodRetActEstProspTit AS INTEGER) < 0 THEN
						LET P_cod_ret = '00021';
						LET P_MENSAJE = 'OCURRIO UN ERROR EN EL PROCEDIMIENTO bdisolic:sp_os_actualizastatusprospectotitular';
							UPDATE bdiprospectos:"informix".pr_cliente
							SET estado_os  = 0
							WHERE numcte_pros = pNumSolicitud;
							INSERT INTO bdisolic:"informix".ss_os_errores(num_solicitud, fechasolicitud, Codigo_Error, descripcion_error, FechaProceso )
							VALUES(pNumSolicitud, pFechaSolicitud, P_COD_RET, P_MENSAJE, CURRENT);
							RETURN P_COD_RET,P_MENSAJE;
					END IF ;

				ELSE
					UPDATE bdiprospectos:pr_cliente
					SET estado_os  = 0
					WHERE  numcte_pros = pNumSolicitud;
				END IF

	  ELSE
		UPDATE bdiprospectos:"informix".pr_cliente
		SET estado_os  = 0
		WHERE numcte_pros = pNumSolicitud;
	    INSERT INTO bdisolic:"informix".ss_os_errores(num_solicitud, fechasolicitud, Codigo_Error, descripcion_error, FechaProceso )
	    VALUES(pNumSolicitud, pFechaSolicitud, P_COD_RET, P_MENSAJE, CURRENT);
	  END IF;




    END;
	RETURN P_COD_RET,P_MENSAJE;
END PROCEDURE
