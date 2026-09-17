CREATE PROCEDURE "informix".sp_os_integracion(pnum_solicitud CHAR(20),pfechasolicitud DATE)
RETURNING CHAR(5); 
-- utilizar los nuevos catalogos liberados en el paso 2 de Alta unica.
--Modificacion: 19/10/2010: Enrique Lizarraga Lugo: Se agrega una consulta para la referencia, se corrigen datos del conyuge y se hace 
-- validacion para el caso de que no se capture el nombre del conyuge, solo su numero de cliente. Se eliminan todas las validaciones 
-- de zonas y calles replicadas, asiÂ­ como sus respectivas variables debido a que existe otro proceso que ya hace dicha validacion.
--Modificacion 28/10/2010: Enrique Lizarraga Lugo: Se agrega a la consulta del conyuge la extraccion del parentesco hacia 
-- claveconyugefamilia para que se incluya en la OS, en lugar del parentesco de la referencia.
--Modificacion 03/02/2011: Juan Carlos Trujillo. Modificacion en el calculo de la fecha de antiguedad de trabajo
--Modificacion 16/02/2011: Abrham Lopez: Modificacion en la consulta de max.domicilio de la tabla si_direcciones por la de 
-- si_direcciones_actual. Se le modifica para que a los numeros telefonicos de observacion1 que no cumplan con los 10 digitos, 
-- se completen con ceros a la izquierda
--Modificacion 16/06/2011: Mohamed Hassan Carreon Perez
--Modificacion: Se realiza homologacion del proceso productivo con la version para contemplar el producto coppel.
--Modificacion 27/06/2011: Jesus Manuel Aguilar Heredia
--Modificacion: Se eliminan espacios para que no exceda el limite maximo de caracteres permitidos.
--Modificacion 03/10/2011: Jesus Manuel Aguilar Heredia; Modificacion: Se agregra validacion para tomar datos de las referencias de la 
-- tabla ss_refpersonales cuando no se tenga activa cajaunica en la sucursal donde nacio la solicitud, y para cuando si este activa se 
-- tome los datos de la tabla si_refclientes.
--Modificacion 26/10/2011: Jesus Manuel Aguilar Heredia: Modificacion: Se Modifica para enviar la sucursal donde se origino la solicitud, 
--en vez de enviar la sucursal donde se dio de alta el cliente, en el campo tiendafolio.
-- Modificacion 26/01/2012: MAHR Se agrego el prefijo indicando el numero de producto al complemento de la OS (entre calles)
DEFINE sRegresa CHAR(100);
--Declaracion de variables para el registro.
--Campos del 1 al 10
DEFINE V_Empresa LIKE bdisolic:ss_osclientesupervisar.Empresa;
DEFINE V_NumSolicitud LIKE bdisolic:ss_osclientesupervisar.Num_Solicitud;
DEFINE V_NumSolicitud_Cliente LIKE bdisolic:ss_osclientesupervisar.Num_Solicitud;
DEFINE V_FechaSolicitud LIKE bdisolic:ss_osclientesupervisar.FechaSolicitud;
DEFINE V_FechaSolicitud_Cliente LIKE bdisolic:ss_osclientesupervisar.FechaSolicitud;
DEFINE V_FechaImpresion LIKE bdisolic:ss_osclientesupervisar.FechaImpresion;
DEFINE V_FechaRespuesta LIKE bdisolic:ss_osclientesupervisar.FechaRespuesta;
DEFINE V_EstatusOs LIKE bdisolic:ss_osclientesupervisar.EstatusOs;
DEFINE V_Observacion1 LIKE bdisolic:ss_osclientesupervisar.Observacion1;
DEFINE V_Observacion2 LIKE bdisolic:ss_osclientesupervisar.Observacion2;
DEFINE V_Observacion3 LIKE bdisolic:ss_osclientesupervisar.Observacion3;
DEFINE V_Monto_Solicitado LIKE bdisolic:ss_osclientesupervisar.monto_solicitado;
DEFINE V_Monto_Autorizado LIKE bdisolic:ss_solicitudes.monto_autorizado;
--Campos del 11 al 20
DEFINE V_numcte     CHAR(20);
DEFINE V_usuariogestor LIKE bdisolic:ss_osclientesupervisar.usuariogestor;
DEFINE V_clave LIKE bdisolic:ss_osclientesupervisar.clave;
DEFINE V_tiendafolio LIKE bdisolic:ss_osclientesupervisar.tiendafolio;
DEFINE V_folio LIKE bdisolic:ss_osclientesupervisar.folio;
DEFINE V_nombre LIKE bdisolic:ss_osclientesupervisar.nombre;
DEFINE V_nombre1 LIKE bdisolic:ss_osclientesupervisar.nombre1;
DEFINE V_nombre2 LIKE bdisolic:ss_osclientesupervisar.nombre2;
DEFINE V_apellidopaterno1 LIKE bdisolic:ss_osclientesupervisar.apellidopaterno1;
DEFINE V_apellidomaterno1 LIKE bdisolic:ss_osclientesupervisar.apellidomaterno1;
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
--DEFINE V_deptoointerior CHAR(4);
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
--jom corrige error de datos 18/12/2007
DEFINE V_clienteconyuge_paso VARCHAR(20);
--jom corrige error de datos 18/12/2007

DEFINE V_nombreconyuge LIKE bdisolic:ss_osclientesupervisar.nombreconyuge;
DEFINE V_nombre1conyuge LIKE bdisolic:ss_osclientesupervisar.nombre1conyuge;
DEFINE V_nombre2conyuge LIKE bdisolic:ss_osclientesupervisar.nombre2conyuge;
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
DEFINE V_nombre1referencia LIKE bdisolic:ss_osclientesupervisar.nombre1referencia;
DEFINE V_nombre2referencia LIKE bdisolic:ss_osclientesupervisar.nombrereferencia;
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
DEFINE v_limitecredito LIKE bdisolic:ss_solicitudes.monto_solicitado;
--verificar que el tipo y la longitud de los datos de las diversas tablas sea equivalente al campo donde se INSERTa
--Variables auxiliares
DEFINE aux_numcte_ref LIKE bdisolic:ss_solicitudes.numcte;
DEFINE aux_claveconyugefamilia CHAR(2);
DEFINE aux_tipo_cliente LIKE bdinteg:si_cliente.tipo_cliente;
DEFINE aux_telefono_ref LIKE bdinteg:si_refdirecciones.telefono1;
-- Se agregan las variables V_ciudadCoppel, V_coloniaCoppel y V_NombreZonaCoppel para llenar los campos ciudadcoppel, coloniacoppel y nombrezonacoppel en ss_osclientesupervisar
DEFINE V_ciudadCoppel LIKE bdisolic:ss_osclientesupervisar.ciudadcoppel;
DEFINE V_coloniaCoppel LIKE bdisolic:ss_osclientesupervisar.coloniacoppel;
DEFINE V_NombreZonaCoppel LIKE bdisolic:ss_osclientesupervisar.nombrezonacoppel;

DEFINE V_ciudadtrabajocoppel LIKE bdisolic:ss_osclientesupervisar.ciudadtrabajocoppel;
DEFINE V_coloniatrabajocoppel LIKE bdisolic:ss_osclientesupervisar.coloniatrabajocoppel;
DEFINE V_nombrezonatrabajocoppel LIKE bdisolic:ss_osclientesupervisar.nombrezonatrabajocoppel;
DEFINE v_NumProducto             LIKE bdisolic:ss_solicitudes.num_producto;
DEFINE V_factor_piso 				LIKE bdisolic:ss_solicitudes.factor_piso;
DEFINE v_prefijo_os_prod           CHAR(1);

DEFINE iHayDatosFamiliar, iHayDatosReferencia, iTotalReferencias        INTEGER;
DEFINE aux_telefono, aux_telefonotrabajo, aux_telefonotrabajoconyuge    CHAR(13);
DEFINE aux_extension                CHAR(5);
DEFINE aux_status                   CHAR(1);
DEFINE SQL_ERR, ISAM_ERR            INTEGER;
DEFINE ERROR_INFO       VARCHAR(80);
DEFINE P_COD_RET        VARCHAR(5);
DEFINE P_MENSAJE        VARCHAR(80);
DEFINE scod_ret6        VARCHAR(6); --Para recuperar el codigo de error de sp_actualiza_status_sol
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
DEFINE tempv_Casa       VARCHAR(20);
DEFINE iAuxCalleAsignar INTEGER;
DEFINE vvalor_numerico  DECIMAL (18,2);

DEFINE v_flagproductocoppel	SMALLINT;
DEFINE v_tipoos 			CHAR(1);
DEFINE v_tipoproducto 		CHAR(5);
DEFINE v_ProductoCoppel 	CHAR(4);
DEFINE v_secuencia 			INTEGER;
DEFINE cSucCajaUnica    CHAR(1);
DEFINE cSucursal    CHAR(4);
DEFINE dtFechaAtualizacion    DATE;
DEFINE V_apellidopaterno1referencia, V_apellidomaterno1referencia, V_apellidopaterno1conyuge, V_apellidomaterno1conyuge   CHAR(26);
DEFINE cNombreCompletoReferencia   CHAR(107);
DEFINE iSoloCoppel  INTEGER;
DEFINE cSucursalCoppel  CHAR(4);
DEFINE vsecuenciaos  INTEGER;
DEFINE vsecuenciaospro  INTEGER;
DEFINE vnumsolPros  CHAR(20);
DEFINE cNumCteBco CHAR(20);
--IPCB RQM 06 646
DEFINE CodRet_regev    	VARCHAR(6);
--DSB20180816
DEFINE iNumSolic SMALLINT;
DEFINE V_FolioMovil CHAR(12); --387 MANDAR DATOS EN LA TINIA PARA SOLMOVOS
--DSB20181221 TIPOORIGEN
DEFINE iSolMov SMALLINT;
DEFINE vProdAltaMovil CHAR(4); --RQM 09 497
DEFINE vTpProd CHAR(1); --RQM 09 497
DEFINE pEmpresa CHAR(3);
DEFINE cCanal            CHAR(1);
DEFINE cCanalAux            CHAR(1);
DEFINE statusAux			CHAR(1);
DEFINE cbanfamilia			CHAR(3);  --RQM 10 1177

LET V_numcte = "";
LET v_flagproductocoppel = 0;
LET	v_tipoos = "";
LET v_tipoproducto = "";
LET V_nombre1 = "";
LET V_nombre2 = "";
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
LET vsecuenciaos = 0;
LET vsecuenciaospro = 0;
LET vnumsolPros ='';
LET cNumCteBco = '';
LET V_situacionespecial         = '';
LET V_causasituacionespecial    = 0;
--IPCB RQM 06 646
LET CodRet_regev		= '';

--DSB20180816
LET iNumSolic = 0;
LET V_FolioMovil = ''; --IDUG 
LET iSolMov = 0;

LET vProdAltaMovil = ''; --RQM 09 497
LET vTpProd = ''; --RQM 09 497
LET pEmpresa = '001';
LET cCanal                      = '';
LET cCanalAux					= '';
LET statusAux					= '';
LET cbanfamilia					= '';  --RQM 10 1177
LET V_referencia3   = 0; --RQM 09 541-2 CrÃ©dito Motos Coppel en Alta Ãnica 07/04/2021 Jonathan Medina
-- SET debug file to '/pisa/pisabanco/pisa_ftes/credito/coronel/sp_os_integracion_'||pnum_solicitud||'.out';
-- Set debug file to '/INFORMIXDUMP/sp_os_integracion_'||trim(pnum_solicitud)||'.out';
	  --SET DEBUG FILE TO "/ifxsif01/Israel/sp_os_integracion.out";
	  --TRACE ON;
	--SET ISOLATION TO DIRTY READ;
	--SET LOCK MODE TO WAIT 3;

BEGIN

ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET P_COD_RET = SQL_ERR;
	LET P_MENSAJE = ERROR_INFO;
	ROLLBACK WORK;
	IF SQL_ERR = -1213 THEN
		LET P_MENSAJE = 'Error conversion caracter a numerico, probable num de casa cliente incorrecto.';
	END IF;
	BEGIN WORK;
	INSERT INTO "informix".ss_os_errores(num_solicitud, fechasolicitud, Codigo_Error, descripcion_error, FechaProceso )
	VALUES(pnum_solicitud, pfechasolicitud, P_COD_RET, P_MENSAJE, CURRENT);
	COMMIT WORK;
	IF (wBegin = "S") THEN
		BEGIN WORK;
	END IF;
	RETURN P_COD_RET;
END EXCEPTION;

ON EXCEPTION IN (-535)
	LET wBegin = "S";
	COMMIT WORK;
	BEGIN WORK;
END EXCEPTION WITH RESUME;

LET wBegin = "N";
LET iAuxProvocado = 0;
-- Moha
LET v_tipoos = '';
LET v_flagproductocoppel = 0;
LET v_ProductoCoppel = '6500';
LET v_tipoproducto = '00000'; -- Moha fin

BEGIN WORK;

--ASIGNA VALORES A LAS VARIABLES
LET P_COD_RET = '00000';
LET P_MENSAJE = 'PROCESO EXITOSO';

LET iEncuentraSolic = 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT nvl(sp.valor,0)*1 as sal_min
INTO iSalMin
FROM bdisolic:"informix".ss_param sp
WHERE sp.secuencia = 303 AND empresa = '001';

-- para obtener limite inferior para clientes nuevos

SELECT nvl(sp.valor,0)*1 as sal_min
INTO iLimInfCL
FROM bdisolic:"informix".ss_param sp
WHERE sp.secuencia = 313 AND empresa = '001';

IF nvl(iSalMin,0) = 0 THEN
	LET P_cod_ret = '00010';
	LET P_MENSAJE = 'Salario Minimo Mensual de Culiacan, esta sin valor.';
END IF;
-- para identificar cuando no existe limite inferior para clientes nuevos
IF nvl(iLimInfCL,0) = 0 THEN
	LET P_cod_ret = '00010';
	LET P_MENSAJE = 'LIMITE INFERIOR CLIENTES NUEVOS, esta sin valor.';
END IF;

IF P_COD_RET = '00000' THEN
  --SELECT 1
	FOREACH
	SELECT empresa, num_solicitud, fecha_solicitud, status, secuenciaos
	  INTO V_Empresa, V_NumSolicitud, V_FechaSolicitud, aux_status, vsecuenciaos
	  FROM "informix".ss_solicitud_os
	 WHERE empresa = '001'
       AND status = 'S' -- Se agrega filtro para que solo tome las pendientes MAMG
	   AND num_solicitud = pnum_solicitud
	   AND fecha_solicitud = pfechasolicitud	
	   
--	IF EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_os_solautdirecta WHERE empresa = V_Empresa AND num_solicitud = pnum_solicitud) THEN
--		SELECT NVL(situacionespecial,'0'),NVL(causa,'0')
--		INTO 	V_situacionespecial,V_causasituacionespecial
--		FROM bdisolic:"informix".ss_os_solautdirecta 
--		WHERE empresa = V_Empresa AND num_solicitud = pnum_solicitud;	
--	END IF;	
	
	IF EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_nuevo_parametrico WHERE empresa = V_Empresa AND num_solicitud = pnum_solicitud ) THEN
		SELECT NVL(situacion_especial,'0'),NVL(causa_sitesp,'0'),NVL(porc_pagoini,'0')
		INTO V_situacionespecial,V_causasituacionespecial,V_referencia3
		FROM bdisolic:"informix".ss_nuevo_parametrico 
		WHERE empresa = V_Empresa
		AND num_solicitud = pnum_solicitud;	
	END IF;

--Solicitud ya existe en 000la tabla, puede que aun no se enviÂ­e a tienda, o ya este procesada. Aqui eso no importa.
	/*IF aux_status <> 'S' THEN   ****** Se elimina ya que con el cambio de filtro en el cursos no es necesario MAMG
		LET P_cod_ret = '00001';
		LET P_MENSAJE = 'Solicitud en proceso o ya fue procesada, segun status de ss_solicitud_os';
		EXIT FOREACH;
	END IF;*/
--SELECT 2
	LET V_EstatusOs = -1;
	--Verificar si esa solicitud ya esta en proceso, o si ya fue procesada
	LET iCuantos = 0;


	SELECT COUNT(*) INTO iCuantos
	FROM "informix".ss_osclientesupervisar
	WHERE empresa = V_Empresa AND num_solicitud = V_NumSolicitud AND fechasolicitud = V_FechaSolicitud;
	--WHERE con primary key

	IF (iCuantos > 0 )  THEN
		LET P_cod_ret   = '00002';   --Solicitud ya existe en la tabla, puede que aun no se enviÂ­e a tienda, o ya este procesada. Aqui eso no importa.
		LET P_MENSAJE = 'A esta solicitud ya se le solicito OS, en ss_osclientesupervisar';
	ELSE
		LET V_limitecredito = 0;
		LET V_Monto_Autorizado = 0;
		--Obtener numero de cliente en BanCoppel
		FOREACH
			SELECT numcte, NVL(monto_solicitado,0), TRIM(status_solicitud), 
                fecha_INSERT, sucursal, num_producto , NVL(monto_autorizado,0)
			INTO V_numcte, V_limitecredito,  sStatus_solic, dFechaSolCred,cSucursal, v_NumProducto ,V_Monto_Autorizado
			FROM "informix".ss_solicitudes
			WHERE empresa = V_Empresa AND num_solicitud = V_NumSolicitud
				LET iEncuentraSolic = 1;
			--AAME RQM 10 1177 Obtener cve de familia para validar si es un prestamo fijo o digital
			SELECT familia
			INTO cbanfamilia
			FROM bdicred:"informix".sd_definicion 
			WHERE empresa = pEmpresa AND num_producto = v_NumProducto;	
			
			if cbanfamilia IN('002','003')--v_NumProducto IN ('6300','6400','7600','7700','6800')	
			then
			  let V_limitecredito = V_Monto_Autorizado;
			end if;
		END FOREACH;  -- Moha

            select numcte_pros
	         into vnumsolPros
		     from bdiprospectos:pr_cliente
	         where numcte = V_numcte;             

             IF nvl(vnumsolPros,'') <> '' THEN
               select MAX (secuencia)
	           into vsecuenciaospro
	           from bdisolic:"informix".ss_osclientesupervisar
	          where empresa  = '001'
		        and num_solicitud  = vnumsolPros;

               IF ( vsecuenciaospro =  vsecuenciaos) THEN
                 LET V_clave = 'A';
               END IF;
             END IF; 

		IF EXISTS(SELECT num_producto FROM bdisolic:"informix".ss_solicitud_os a, bdisolic:"informix".ss_solicitudes b
					WHERE a.num_solicitud = b.num_solicitud
					AND a.status = 'S'
					AND b.numcte = V_numcte
					AND num_producto = v_ProductoCoppel) THEN
			LET v_flagproductocoppel = 1;			
			LET v_tipoproducto = '01000'; --SOLO PRODUCTO COPPEL
		END IF;

		IF EXISTS(SELECT num_producto FROM bdisolic:"informix".ss_solicitud_os a, bdisolic:"informix".ss_solicitudes b
					WHERE a.num_solicitud = b.num_solicitud
					AND a.status = 'S'
					AND b.numcte = V_numcte
					AND num_producto <> v_ProductoCoppel) THEN

			IF v_flagproductocoppel = 0 THEN
					let v_tipoproducto = '10000'; --SOLO PRODUCTO BANCOPPEL
			ELSE
					let v_tipoproducto = '11000'; --AMBOS PRODUCTOS, COPPEL Y BANCOPPEL										
			END IF;
		ELSE
			LET iSoloCoppel = 1;
		END IF; 
			
		IF iEncuentraSolic = 0 THEN
			Let P_cod_ret = '00006';
			Let P_MENSAJE = 'Solicitud no encontrada en ss_solicitudes.';
			EXIT ForEach;
		ELSE
			IF sStatus_solic NOT IN ('EE', 'CE') THEN
				IF sStatus_solic IN ('OS', 'OA') THEN
					Let P_cod_ret = '00013';
					Let P_MENSAJE = 'Ya hay una orden de supervision en proceso.';
					EXIT ForEach;
				ELSE
					IF sStatus_solic IN ('AT', 'AP') AND SUBSTR(v_tipoproducto,2,1) = '0' THEN
						Let P_cod_ret = '00014';
						Let P_MENSAJE = 'Solicitud ya fue autorizada o cuenta ya aperturada.';
						EXIT ForEach;
					ELSE
					--if exists not (select num_solicitud from bdisolic:ss_os_solautdirecta where num_solicitud = V_NumSolicitud) then
						IF sStatus_solic NOT IN ('AT', 'AP') AND SUBSTR(v_tipoproducto,2,1) = '0' AND vnumsolPros ='' THEN
							Let P_cod_ret = '00015';
							Let P_MENSAJE = 'status de Solicitud '||sStatus_solic ||' no puede solicitar OS.';
							EXIT ForEach;
						END IF;
					END IF;
				END IF;
			END IF;
        END IF; --Moha fin

		IF V_numcte IS NULL THEN --la solicitud no tiene num de cliente
			LET P_cod_ret = '00008';
			LET P_MENSAJE = 'Solicitud sin numero de cliente.';
		ELSE
			LET V_FechaImpresion    = date(1);
			LET V_FechaRespuesta    = date(1);
			LET V_EstatusOs         = 0;
			LET V_Observacion1      = '';
			LET V_Observacion2      = '';
			LET V_Observacion3      = '';
			LET V_usuariogestor     = '';
			--Moha
			IF NVL(V_numcte, '') <> '' THEN
				SELECT sucursal, TRIM(NVL(nombre1,' ')) || ' '|| TRIM(NVL(nombre2,' ')), TRIM(NVL(apell_paterno,' ')), TRIM(NVL(apell_materno,' ')), fecha_alta,
				TRIM(NVL(nombre1,' ')), TRIM(NVL(nombre2,' ')), TRIM(NVL(apell_paterno,' ')), TRIM(NVL(apell_materno,' '))
				INTO V_tiendafolio, V_nombre, V_apellidopaterno, V_apellidomaterno, V_fechaaltacliente,
				V_nombre1, V_nombre2, V_apellidopaterno1, V_apellidomaterno1
				FROM bdinteg:"informix".si_cliente
				WHERE numcte = V_numcte;
			END IF; --Moha fin
			--JMAH
			IF v_flagproductocoppel = 1 AND iSoloCoppel = 0 THEN ---Cambio, para obtener la sucursal en donde se dio de alta la solicitud y asi enviarla a la os calle, sustituyendo el valor de la sucursal donde se dio de alta el cliente
				SELECT limit 1 sucursal --JMAH
					INTO cSucursalCoppel
				FROM bdisolic:"informix".ss_solicitud_os a, bdisolic:"informix".ss_solicitudes b
				WHERE a.num_solicitud = b.num_solicitud
				AND a.status = 'S'
				AND b.numcte = V_numcte
				AND num_producto = v_ProductoCoppel;
				
				LET V_tiendafolio =  cSucursalCoppel;
				LET cSucursal = cSucursalCoppel;
			ELSE
				LET V_tiendafolio =  cSucursal; 
			END IF;
			--JMAH
			IF V_nombre IS NULL THEN    --Valida que exista el cliente
				LET P_cod_ret = '00003';   --Cliente No existe
				LET P_MENSAJE = 'No se encuentra la informacion del cliente: '|| TRIM(V_numcte);
				EXIT FOREACH;
			END IF;
				--validacion para comparar el monto solicitado, con el salario miÂ­nimo mensual de culiacan y con el miÂ­nimo inferior para clientes nuevos
			IF (V_limitecredito < iSalMin) AND (V_limitecredito < iLimInfCL) AND v_NumProducto <> '6500' THEN
				LET P_cod_ret = '00012';
				LET P_MENSAJE = 'Limite de credito es menor a 1 Salario y al limite inferior para clientes nuevos.';
				EXIT FOREACH;
			END IF;

			LET V_limitecredito     = round(V_limitecredito / iSalMin);

			SELECT curp, numeroife, codidentifi, numidentifi, habita_en, sexo,
					fn_mapea_estado_civil(estado_civil), fecha_nac, nvl(anios_habita,0), escolaridad, dependientes
			INTO V_curp, V_claveelector, V_claveidentificacion, V_identificacion, V_casapropia, V_sexo,
				  V_estadocivil, V_fechanacimiento, iAniosHabita, V_escolaridad, V_numerodependientes
			FROM bdinteg:"informix".si_ctepf WHERE numcte = V_numcte;

			LET iAuxElemento = 0;
			SELECT elemento
			INTO iAuxElemento
			FROM bdisolic:"informix".ss_detalle_scoring a
			WHERE grupo = 6
			AND seccion = 2
			AND tpo_persona = '01'
			AND num_solicitud = V_NumSolicitud;

			IF iAuxElemento IS NULL THEN
				LET iAuxElemento = 0;
			END IF;

			IF iAuxElemento =  1    THEN  LET iAniosHabita = 10;
			ELIF iAuxElemento =  2  THEN  LET iAniosHabita = 6;
			ELIF iAuxElemento =  3  THEN  LET iAniosHabita = 3;
			ELIF iAuxElemento =  4  THEN  LET iAniosHabita = 2;
			ELIF iAuxElemento =  5  THEN  LET iAniosHabita = 1;
			ELIF iAuxElemento =  6  THEN  LET iAniosHabita = 0;
			ELIF iAuxElemento =  7  THEN  LET iAniosHabita = 20;
			ELIF iAuxElemento =  8  THEN  LET iAniosHabita = 10;
			ELIF iAuxElemento =  9  THEN  LET iAniosHabita = 8;
			ELIF iAuxElemento =  10 THEN  LET iAniosHabita = 5;
			ELIF iAuxElemento =  11 THEN  LET iAniosHabita = 3;
			ELIF iAuxElemento =  12 THEN  LET iAniosHabita = 2;
			ELIF iAuxElemento =  13 THEN  LET iAniosHabita = 1;
			ELIF iAuxElemento =  14 THEN  LET iAniosHabita = 0;
			ELIF iAuxElemento >  14 THEN  
              select rango_minimo into iAniosHabita
               from ss_scoring_element 
              where grupo = 6 and seccion =2 and elemento =iAuxElemento;
            ELSE LET iAniosHabita = 0;  END IF;

			IF (iAniosHabita = 0) or   (iAniosHabita = -1)  THEN
				LET V_fechadesdecuandoviveahi   = dFechaSolCred;
			ELSE
				IF day(dFechaSolCred) = 29 AND month(dFechaSolCred) = 2 AND mod(iAniosHabita, 4) <> 0 THEN
					LET V_fechadesdecuandoviveahi = (dFechaSolCred - 1) - iAniosHabita units year;
				ELSE
					LET V_fechadesdecuandoviveahi = dFechaSolCred - iAniosHabita units year;
				END IF;
			END IF;
			--Mapear:        -- codidentifi,      --habita_en ok   --estado_civil ok     --escolaridad    --no se esta capturando en el alta de cliente
			LET V_clave             = '';
			LET V_folio             = 0;
--Campos del 21 al 30
			SELECT nvl(d.numerociudad,0) as numerociudad, nvl(d.numerocolonia,0) as numerocolonia, nvl(d.numerocalle,0) as numerocalle, TRIM(nvl(d.numeroextcalle, '')), d.departamento, TRIM(d.puntocardinal),
					TRIM(d.entre_calles), decode(nvl(d.unidadhabitac, 'N'), 'S', '1', '0'), d.manzana, d.otros, d.andador, d.etapa,
					d.lote, d.edificio, d.entrada,CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(TRIM(t1.telefono),'')) = 'V' THEN t1.telefono ELSE '0000000000' END
					, CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(TRIM(t2.telefono),'')) = 'V' THEN t2.telefono ELSE '0000000000' END
					, d.observaciones,TRIM(nvl(d.numerointcalle,''))
			INTO V_ciudad, V_colonia, V_calle, Vauxcasa, vauxdepto, V_rumbo,
				  V_complemento, V_flaguhc, V_uhcmanzana, V_uhcotros, V_uhcandador, V_uhcetapa,
				  V_uhclote, V_uhcedificio, V_uhcentrada, aux_telefono, V_telefonocelular, V_Observacion2,aux_numintcalle
			FROM bdinteg:"informix".si_direcciones_actual d 
                                	LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual t1 ON (d.numcte = t1.numcte AND t1.tipo_tel = 1 AND t1.status_tel = 'A')
                                	LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual t2 ON (d.numcte = t2.numcte AND t2.tipo_tel = 2 AND t2.status_tel = 'A')
			WHERE d.numcte = V_numcte
			AND d.tipo_dir = '1';
			
			--Se realiza el trim a la variable para que no se haga en el query
			LET pnum_solicitud = TRIM(pnum_solicitud);
			
			--Llena V_Observacion3 HSRR 
			SELECT NVL(calle, ''), folio
			INTO V_Observacion3, V_FolioMovil  --Toma el folio para el mensaje de la tinia IDUG
			FROM bdinteg:"informix".si_solicitud_movil 
			WHERE numcte = V_numcte
			AND pnum_solicitud IN (num_tdc_bcoppel, num_tdc_coppel);
			
			IF NVL(V_Observacion3, '') = '' THEN
				LET V_Observacion3 = '';
			END IF;
			
			LET aux_numintcalle      = replace(aux_numintcalle ,'\','/');
            LET aux_numintcalle      = replace(aux_numintcalle ,'|',' '); 
            LET aux_numintcalle      = replace(aux_numintcalle ,'''',' ');		

			SELECT numerocoloniacoppel, nombrezonacoppel, numerociudadcoppel INTO V_coloniaCoppel, V_NombreZonaCoppel, V_ciudadCoppel
			FROM bdinteg:"informix".si_catzonas
			WHERE numerociudad = V_ciudad AND numerocolonia = V_colonia;

                LET V_Observacion2      = replace(V_Observacion2 ,'\','/');
                LET V_Observacion2      = replace(V_Observacion2 ,'|',' '); 
                LET V_Observacion2      = replace(V_Observacion2 ,'''',' '); 

			IF v_ciudad IS NULL OR nvl(v_colonia, 0) = 0 OR nvl(v_calle, 0)= 0 THEN
				LET P_cod_ret = '00009';
                IF (SELECT count(numcte)
							FROM "informix".ss_solicitudes_movil							
							WHERE 	empresa  =  '001'
							AND  numcte = V_numcte
							AND num_solicitud = V_NumSolicitud) >0  THEN 						
                                
							LET P_MENSAJE = 'Solicitud Movil Domicilio de cliente incompleto en calle, colonia o ciudad.';	
                ELSE
					LET P_MENSAJE = 'Domicilio de cliente incompleto en calle, colonia o ciudad.';
                END IF;
				EXIT FOREACH;
			--ELIF V_ciudad = 0 OR V_colonia = 8000 OR V_calle = 800000 THEN
            ELIF V_colonia = 8000 OR V_calle = 800000 THEN
				LET P_cod_ret = '00007';
				LET P_MENSAJE = 'Domicilio de cliente con ciudad, colonia o calle por asignar.';
				EXIT FOREACH;
			END IF;

			IF EsNumeroCasa(vauxcasa) = 0 THEN
				IF LENGTH(TRIM (vauxcasa)) > 0 THEN
					--LET V_complemento = 'CASA ' || TRIM(Vauxcasa) ||' ' || TRIM(V_complemento);
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
--Campos del 31 al 40
--Campos del 41 al 50
		LET V_personasvivenendomicilio = 0;
			LET V_tiposueldo                = '1';
			LET V_personastrabajan          = 0;
            --fmj Octubre 20,2011
           let v_tipoos = 'S';
			select  cajaunica INTO cSucCajaUnica from bditarjcop:sucursalescajaunica 
                 where empresa  = '001' and cvesucursal =cSucursal; --  and cajaunica ='V'
            if  ( cSucCajaUnica = 'V' ) then
              let v_tipoos = 'G';
            end if;
			-- Moha
           --/* 
			SELECT ROUND(NVL(ingreso_mensual,0),2) AS ingreso_mensual --, origen
			INTO V_ingresomensual --, v_tipoos
			FROM bdisolic:"informix".ss_resum_scor_fin
			WHERE empresa = V_Empresa AND num_solicitud = V_NumSolicitud;
			/*
			IF  v_tipoos  = 1 then
				let v_tipoos = 'G';			
			ELSE
				let v_tipoos = 'S';
			END IF; --Moha fin*/
			
			LET V_ingresomensual            = round(nvl(V_ingresomensual,0)/iSalMin);
			IF ( V_ingresomensual >32000 ) THEN --FMJ AGOSTO 2011
			   LET P_cod_ret = '00019';
			   LET P_MENSAJE = 'Ingreso Mensual No permitido para OS';
			   EXIT FOREACH;
			END IF;     

			--Se realiza el trim a la variable para que no se haga en el query
			LET pnum_solicitud = TRIM(pnum_solicitud);
			
			--Se optimizan las consultas para que sean por indices
			
			--Se valida el origen de la solicitud DSB IDUG INICIA 
				
				SELECT count(numcte) 
				INTO iNumSolic 
				FROM bdisolic:"informix".ss_solicitudes 
				WHERE numcte = V_numcte
				AND num_solicitud = pnum_solicitud;
					
				--Se valida que la solicitud sea movil
				SELECT count(numcte) 
				INTO iSolMov 
				FROM bdinteg:"informix".si_solicitud_movil 
				WHERE numcte = V_numcte
				AND pnum_solicitud IN (num_tdc_coppel, num_tdc_bcoppel);
				
				IF iNumSolic <> 0 THEN
					LET v_tipoos = 'G';
					IF iSolMov <> 0 THEN
						LET v_tipoos = 'M';
					END IF;
				ELSE
					LET v_tipoos = 'N';
				END IF;	--FIN IDUG
			
--Campos del 51 al 60

			LET V_claveautrechaza           = '';
			LET V_creditojoven              = '';

			LET V_lugartrabajo                = '';

			SELECT nvl(nombre_empresa,''), puesto*1, puesto_esp
			INTO V_lugartrabajo, V_puesto, V_opcionpuesto
			FROM bdinteg:"informix".si_ingresos
			WHERE --upper(tipo_ingreso) = 'T' --Ingreso del Titular
				sec_ingreso = 1
			AND numcte = V_numcte;
			--Mapear  --Puesto    --son iguales a los de coppel --Puesto_esp-- "     "    "  "   "    "          --Antiguedad
			SELECT d.numerociudad, d.numerocolonia, d.numerocalle, TRIM(nvl(d.numeroextcalle,'')), d.departamento, d.puntocardinal,
					TRIM(nvl(d.entre_calles,'')), decode(nvl(d.unidadhabitac, 'N'), 'S', '1', '0'), d.manzana, d.otros, d.andador, d.etapa,
					d.lote, d.edificio, d.entrada, TRIM(nvl(t3.telefono, '')), t3.extension, TRIM(nvl(d.numerointcalle,''))
			INTO V_ciudadtrabajo, V_coloniatrabajo, V_calletrabajo, Vauxcasatrabajo, vauxdeptotrabajo, V_rumbotrabajo,
				  V_complementotrabajo, V_flaguht, V_uhtmanzana, V_uhtotros, V_uhtandador, V_uhtetapa,
				  V_uhtlote, V_uhtedificio, V_uhtentrada, aux_telefonotrabajo, aux_extension, aux_numintrabajo
			FROM bdinteg:"informix".si_direcciones_actual d
			                     LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual t3 ON (d.numcte = t3.numcte AND t3.tipo_tel = 3 AND t3.status_tel = 'A')
			WHERE d.numcte = V_numcte
			AND d.tipo_dir = 2;

            LET aux_numintrabajo      = replace(aux_numintrabajo ,'\','/');
            LET aux_numintrabajo      = replace(aux_numintrabajo ,'|',' '); 
            LET aux_numintrabajo      = replace(aux_numintrabajo ,'''',' ');				

			SELECT numerociudadcoppel, numerocoloniacoppel, nombrezonacoppel INTO V_ciudadtrabajocoppel, V_coloniatrabajocoppel, V_nombrezonatrabajocoppel
			FROM bdinteg:"informix".si_catzonas
			WHERE numerociudad = V_ciudadtrabajo AND numerocolonia = V_coloniatrabajo;

			LET vauxcasatrabajo      = replace(vauxcasatrabajo ,'\','/');
            LET vauxcasatrabajo      = replace(vauxcasatrabajo ,'|',' '); 
            LET vauxcasatrabajo      = replace(vauxcasatrabajo ,'''',' ');

            LET vauxdeptotrabajo      = replace(vauxdeptotrabajo ,'\','/');
            LET vauxdeptotrabajo      = replace(vauxdeptotrabajo ,'|',' '); 
            LET vauxdeptotrabajo      = replace(vauxdeptotrabajo ,'''',' ');
		
			LET vauxdepto      = replace(vauxdepto ,'\','/');
            LET vauxdepto      = replace(vauxdepto ,'|',' '); 
            LET vauxdepto      = replace(vauxdepto ,'''',' ');
			
			LET aux_telefono      = replace(aux_telefono ,'\','');
			LET aux_telefono      = replace(aux_telefono ,'|',''); 
			LET aux_telefono      = replace(aux_telefono ,'''','');
			
			LET V_telefonocelular      = replace(V_telefonocelular ,'\','');
			LET V_telefonocelular      = replace(V_telefonocelular ,'|',''); 
			LET V_telefonocelular      = replace(V_telefonocelular ,'''','');

			IF EsNumeroCasa(Vauxcasatrabajo) = 0 THEN
				IF LENGTH(TRIM (Vauxcasatrabajo)) > 0 THEN
					--LET V_complementotrabajo = 'CASA '|| TRIM(Vauxcasatrabajo) ||' '|| TRIM(V_complementotrabajo);
					LET Vauxcasatrabajo = 'CASA:'|| TRIM(Vauxcasatrabajo)||',';
				END IF;
				LET V_casatrabajo= '0';
			ELSE
				LET V_casatrabajo= TRIM(Vauxcasatrabajo);
				LET Vauxcasatrabajo='';
			END IF;

			LET V_extensiontrabajo = 0;
			IF EsNumerocasa(aux_extension) = 1 THEN --verificar si es dato numerico
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

			LET iAuxElemento = 0;
			SELECT elemento
			INTO iAuxElemento
			FROM bdisolic:"informix".ss_detalle_scoring a
			WHERE grupo = 8
			AND seccion = 2
			AND tpo_persona = '01'
			AND num_solicitud = V_NumSolicitud;
			IF iAuxElemento IS NULL THEN
				LET iAuxElemento = 0;
			END IF;
			IF iAuxElemento =  1 THEN   LET iAniosHabita = 10;
			ELIF iAuxElemento =  2 THEN LET iAniosHabita = 5;
			ELIF iAuxElemento =  3 THEN LET iAniosHabita = 2;
			ELIF iAuxElemento =  4 THEN LET iAniosHabita = 1;
			ELIF iAuxElemento =  5 THEN LET iAniosHabita = 0;
			ELIF iAuxElemento =  6 THEN LET iAniosHabita = 10;
			ELIF iAuxElemento =  7 THEN LET iAniosHabita = 8;
			ELIF iAuxElemento =  8 THEN LET iAniosHabita = 5;
			ELIF iAuxElemento =  9 THEN LET iAniosHabita = 4;
			ELIF iAuxElemento =  10 THEN LET iAniosHabita = 3;
			ELIF iAuxElemento =  11 THEN LET iAniosHabita = 2;
			ELIF iAuxElemento =  12 THEN LET iAniosHabita = 1;
			ELIF iAuxElemento =  13 THEN LET iAniosHabita = 0;
            ELIF iAuxElemento >  25 THEN  --LET iAniosHabita = vlRango;
              select rango_minimo into iAniosHabita
               from ss_scoring_element 
              where grupo = 8 and seccion =2 and elemento =iAuxElemento;
              LET vvalor_numerico =iAniosHabita;
			ELSE LET iAniosHabita = 0;  END IF;

            IF iAuxElemento <  25 THEN
			  select  valor_numerico -- ,dsc.num_solicitud
			  INTO vvalor_numerico
			  from bdicobranza:"informix".cb_param_campania pc ,
			 		bdisolic:"informix".ss_detalle_scoring dsc
			  where pc.empresa =dsc.empresa
			  and pc.num_parametro =dsc.elemento
			  and pc.empresa = V_Empresa
			  and pc.tipo_campania =  12
			  and pc.grupo_parametro = 'ANTTRAOS'
			  and dsc.seccion =2
			  and dsc.grupo =8
			  and dsc.num_solicitud = V_NumSolicitud;       
            END  IF; 
			IF (vvalor_numerico is null) or (vvalor_numerico = 0) or (vvalor_numerico = -1)  THEN
				LET V_fechaantiguedadtrabajo = date(1);
			ELSE
		                IF day(dFechaSolCred) = 29 AND month(dFechaSolCred) = 2 AND mod(year(dFechaSolCred), 4) = 0 THEN
                		    LET V_fechaantiguedadtrabajo = (dFechaSolCred-1) - vvalor_numerico units year;
		                ELSE
                	    	    LET V_fechaantiguedadtrabajo = dFechaSolCred - vvalor_numerico units year;
	                	END IF;    
			END IF;
	
			LET iHayDatosFamiliar       = 0;
			LET iHayDatosReferencia     = 0;
			LET iTotalReferencias       = 0;

			--Cambio 22-03-2007
			--Criterio : las ref ya no se guardan como clientes
				LET v_claveconyugefamilia       = '00';
				LET V_nombreconyuge             = '';
				LET V_apellidopaternoconyuge    = '';
				LET V_apellidomaternoconyuge    = '';
				LET V_clienteconyuge            = 0;
				LET V_clienteconyuge_paso      = '';
				LET V_ciudadconyuge             = 0;
				LET V_coloniaconyuge            = 0;
				LET V_calletrabajoconyuge       = 0;
				LET V_casatrabajoconyuge        = 0;
				LET V_deptoointeriorconyuge     = '';
				LET V_rumbotrabajoconyuge       = '';
				LET V_complementoconyuge        = '';
				LET V_flaguhy                   = 0;
				LET V_uhymanzana                = 0;
				LET V_uhyotros                  = 0;
				LET V_uhyandador                = 0;
				LET V_uhyetapa                  = 0;
				LET V_uhylote                   = 0;
				LET V_uhyedificio               = 0;
				LET V_uhyentrada                = 0;
				LET aux_telefonotrabajoconyuge  = 0;
				LET V_telefonocelularconyuge    = 0;
				LET V_lugartrabajoconyuge       = '';
				LET aux_telefono_ref            = 0;
				--Datos de la referencia no familiar en blanco
				LET V_clientereferencia         = 0;
				LET V_ciudadreferencia          = 0;
				LET V_coloniareferencia         = 0;
				LET V_callereferencia           = 0;
				LET V_casareferencia            = 0;
				LET V_deptoointeriorreferencia  = '';
				LET V_rumboreferencia           = '';
				LET V_complementoreferencia     = '';
				LET V_flaguhr                   = 0;
				LET V_uhrmanzana                = 0;
				LET V_uhrotros                  = 0;
				LET V_uhrandador                = 0;
				LET V_uhretapa                  = 0;
				LET V_uhrlote                   = 0;
				LET V_uhredificio               = 0;
				LET V_uhrentrada                = 0;
				LET V_telefonoreferencia        = aux_telefono_ref;
				LET V_telefonocelularreferencia = '';
			--JMAH									
			-- Valida si la sucursal puede ofrecer el producto coppel
			/*
		   SELECT cajaunica, fechaactcu  
			 INTO cSucCajaUnica,dtFechaAtualizacion
			 FROM bditarjcop:"informix".sucursalescajaunica
			WHERE empresa = V_Empresa
			  AND cvesucursal = cSucursal;*/

		   IF NVL(cSucCajaUnica,'') = "" THEN
			   LET cSucCajaUnica = 'F';
		   END IF;
		   --JMAH
	       --IF cSucCajaUnica = 'F' OR (cSucCajaUnica = 'V' AND dtFechaAtualizacion > pfechasolicitud) OR v_flagproductocoppel = 0 THEN ---Produccion
	       IF (cSucCajaUnica = 'F')  OR (v_flagproductocoppel = 0) THEN ---Produccion  FMJ Octubre 28,2011
				FOREACH                      
				--ELL Se modifica consulta para enviar el nombre de la referencia en lugar del conyuge 11/10/2010
					SELECT nvl(a.parentesco, '00') as parentesco, ---nombre_ref, replace(telefono_ref,' ','')
					SUBSTR(nombre_ref,1,11), SUBSTR(nombre_ref,12,10), SUBSTR(nombre_ref,22,15),---replace(telefono_ref,' ','')
					CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(TRIM(telefono_ref),'')) = 'V' THEN telefono_ref ELSE '0000000000' END
					INTO aux_claveconyugefamilia,V_nombrereferencia ,V_apellidopaternoreferencia,V_apellidomaternoreferencia,  --aux_nombre_ref, 
						 aux_telefono_ref
					FROM bdisolic:ss_refpersonales a
					WHERE a.empresa = '001'
					AND a.num_solicitud = V_NumSolicitud
					AND a.numcte = V_numcte
					AND TRIM(nvl(nombre_ref, ' ')) <> '' 
					AND a.parentesco <> 'E'  
					AND TRIM(parentesco)<>'05'   

					LET iTotalReferencias = iTotalReferencias + 1;
						--Datos de la referencia familiar en blanco como solo habra 1 referencia, en el caso de los clientes coppel, se mandara sea o no familiar en el lugar de la referencia no familiar, que es la que se imprime.
					LET V_telefonoreferencia        = aux_telefono_ref;    
					IF aux_claveconyugefamilia <> '00' THEN --es familiar
						LET V_claveconyugefamilia = aux_claveconyugefamilia;						
					END IF;
				END FOREACH;    --De las referencias

				--LET V_referencia3   = 0;   --RQM 09 541-2 CrÃ©dito Motos Coppel en Alta Ãnica 07/04/2021 Jonathan Medina
				LET V_referencia4   = '';
				LET V_efectuo       = '';

				LET V_fechamovto        = date(1);

				LET V_telefonocelular  			= lpad(TRIM(nvl(V_telefonocelular, '')), 10, 0);
				LET aux_telefono                = lpad(TRIM(nvl(aux_telefono, '')), 10, 0);
				LET aux_telefono_ref  			= lpad(TRIM(nvl(aux_telefono_ref, '')), 10, 0);
				LET aux_telefonotrabajo         = lpad(TRIM(nvl(aux_telefonotrabajo, '')), 10, 0);
				LET aux_telefonotrabajoconyuge  = lpad(TRIM(nvl(aux_telefonotrabajoconyuge, '')), 10, 0);

				IF LENGTH(V_telefonocelular) > 10 THEN
					LET V_telefonocelular    = SUBSTR(V_telefonocelular, -10);    --Toma los 10 digitos de la derecha
				END IF;

				IF LENGTH(aux_telefono) > 10 THEN
					LET aux_telefono    = SUBSTR(aux_telefono, -10);    --Toma los 10 digitos de la derecha
				END IF;

				IF LENGTH(aux_telefono_ref) > 10 THEN
					LET aux_telefono_ref = SUBSTR(aux_telefono_ref, -10);
				END IF;
	
				IF LENGTH(aux_telefonotrabajo) > 10 THEN
					LET aux_telefonotrabajo = SUBSTR(aux_telefonotrabajo, -10);
				END IF;

				IF LENGTH(aux_telefonotrabajoconyuge) > 10 THEN
					LET aux_telefonotrabajoconyuge = SUBSTR(aux_telefonotrabajoconyuge, -10);
				END IF;

				--LET V_Observacion1      = SUBSTR(aux_telefono, 1, 10) ||SUBSTR(aux_telefonotrabajo, 1, 10) ||SUBSTR(aux_telefonotrabajoconyuge, 1, 10);
				LET V_Observacion1      = SUBSTR(V_telefonocelular, 1, 10) ||SUBSTR(aux_telefono, 1, 10) ||SUBSTR(aux_telefono_ref, 1, 10);

				
				LET V_telefono                  = aux_telefono;
				LET V_telefonotrabajo           = aux_telefonotrabajo;
				LET V_telefonotrabajoconyuge    = aux_telefonotrabajoconyuge;
				LET V_monto_solicitado          = 0;
					--Cambio 14-11-2007
					--Criterio : Se guardaran los datos del conyuge
				--ELL Se modifica consulta para extraer datos del conyuge. En caso de no existir otra referencia
				--se toma al conyuge para llenar los campos de dicha referencia. 11/10/2010
				SELECT LIMIT 1 nvl(a.parentesco, '00') as parentesco, SUBSTR(nombre_ref,1,11), SUBSTR(nombre_ref,12,10), 
				SUBSTR(nombre_ref,22,15), nvl(numcte_ref,0), ---replace(telefono_ref,' ','')
				CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(TRIM(telefono_ref),'')) = 'V' THEN telefono_ref ELSE '0000000000' END
				INTO aux_claveconyugefamilia , V_nombreconyuge, V_apellidopaternoconyuge, V_apellidomaternoconyuge, V_clienteconyuge_paso, aux_telefono_ref
				FROM bdisolic:ss_refpersonales a
				WHERE a.empresa = '001'
				AND a.num_solicitud = V_NumSolicitud
				AND a.numcte = V_numcte
				AND (a.parentesco = 'E' or TRIM(parentesco)='05');
				
				IF aux_claveconyugefamilia = 'E' THEN --es familiar
						LET V_claveconyugefamilia = aux_claveconyugefamilia;       
				ELSE
					 IF aux_claveconyugefamilia = '05' THEN
						LET V_claveconyugefamilia = 'E';
					 END IF;
				END IF;					
							
			--ELL 19/octubre/2010 se agrega la siguiente validacion en caso de que solo exista el numero de cliente del conyuge y no su nombre.
				IF (V_nombreconyuge is null and V_clienteconyuge_paso is not null) THEN
					SELECT apell_paterno , apell_materno , TRIM(NVL(nombre1,' ')) || ' ' || TRIM(NVL(nombre2,''))
					INTO V_apellidopaternoconyuge , V_apellidomaternoconyuge , V_nombreconyuge
					FROM bdinteg:"informix".si_cliente si
					where si.empresa = '001'
					AND si.numcte = V_clienteconyuge_paso;

				END IF;

				-----MACF   20101122
				IF iTotalReferencias > 0  and nvl(V_nombreconyuge, '') = '' then
				  LET V_apellidopaternoconyuge = V_apellidopaternoreferencia;
				  LET V_apellidomaternoconyuge = V_apellidomaternoreferencia;
				  LET V_nombreconyuge = V_nombrereferencia;
				END IF;    


				LET V_clienteconyuge = esnumerocasa(V_clienteconyuge_paso);

                SELECT a.canal_sol
                INTO   cCanal
                FROM bdisolic:ss_prospecteo_solicitudes a ,bdisolic:ss_solicitudes b
                WHERE a.num_solicitud=b.num_solicitud
                and b.num_solicitud= pnum_solicitud
                AND a.canal_sol='4';
                
				Let cCanal=nvl(cCanal,'');
				
                IF cCanal <> '4' THEN

					IF (iTotalReferencias = 0 and V_nombreconyuge is null) THEN
								
						IF (SELECT count(numcte)
								FROM "informix".ss_solicitudes_movil							
								WHERE 	empresa  =  '001'
								AND  numcte = V_numcte
								AND num_solicitud = V_NumSolicitud
								AND status <> '3') =0  THEN 						
		
								LET P_cod_ret = '00004';    --No tiene referencias
								LET P_MENSAJE = 'No tiene referencias.';	
						END IF;
					END IF;
                END IF;

				IF iTotalReferencias = 0 THEN
					LET V_nombrereferencia = V_nombreconyuge;
					LET V_apellidopaternoreferencia = V_apellidopaternoconyuge;
					LET V_apellidomaternoreferencia =V_apellidomaternoconyuge ;
					LET iTotalReferencias = 1;
				END IF;
			ELSE --piloto para paso 5
				 FOREACH
--ELL Se modifica consulta para enviar el nombre de la referencia en lugar del conyuge 11/10/2010
					SELECT secuencia,parentesco,nombre1,nombre2,apell_paterno,apell_materno,TRIM(NVL(nombre1,' ')) || ' ' || TRIM(NVL(nombre2,' '))
					INTO v_secuencia,aux_claveconyugefamilia,V_nombre1referencia,V_nombre2referencia,V_apellidopaternoreferencia,V_apellidomaternoreferencia,V_nombrereferencia
					FROM bdinteg:"informix".si_refclientes
					WHERE empresa = '001'
					AND num_solicitud = V_NumSolicitud
					AND numcte = V_numcte
					AND parentesco <> "E"
					ORDER BY secuencia DESC

					SELECT 
					CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(TRIM(telefono1),'')) = 'V' 
									THEN telefono1 ELSE '0000000000' END,					
					CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(TRIM(telefono2),'')) = 'V' 
									THEN telefono2 ELSE '0000000000' END
					INTO aux_telefono_ref, V_telefonocelularreferencia
					FROM bdinteg:"informix".si_refdirecciones
					WHERE numcte = V_numcte
					AND secuencia = v_secuencia;
					
					LET V_apellidopaterno1referencia = V_apellidopaternoreferencia;
					LET V_apellidomaterno1referencia = V_apellidomaternoreferencia;
					LET iTotalReferencias = iTotalReferencias + 1;

					LET V_claveconyugefamilia = aux_claveconyugefamilia;
					--Datos de la referencia familiar en blanco
					--Como solo habra 1 referencia, en el caso de los clientes coppel, se mandara sea o no familiar en el lugar de la referencia no familiar, que es la que se imprime.
					LET V_telefonoreferencia = aux_telefono_ref;


				END FOREACH;    --De las referencias

				IF iTotalReferencias = 0 THEN
					
						SELECT  limit 1 
						nvl(a.parentesco, '00') as parentesco, ---nombre_ref, replace(telefono_ref,' ','')
						SUBSTR(nombre_ref,1,11), 
						SUBSTR(nombre_ref,12,10), 
						SUBSTR(nombre_ref,22,15),  ---replace(telefono_ref,' ','')
						CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(TRIM(telefono_ref),'')) = 'V' 
									THEN telefono_ref ELSE '0000000000' END
						INTO 	aux_claveconyugefamilia,
								V_nombrereferencia,
								V_apellidopaternoreferencia,
								V_apellidomaternoreferencia,
								aux_telefono_ref
						FROM bdisolic:ss_refpersonales a
						WHERE a.empresa = '001'
						AND a.num_solicitud = V_NumSolicitud
						AND a.numcte = V_numcte
						AND TRIM(nvl(nombre_ref, ' ')) <> '' 
						AND a.parentesco <> 'E'  
						AND TRIM(parentesco)<>'05';
					
						LET iTotalReferencias = iTotalReferencias + 1;
						LET V_telefonoreferencia = aux_telefono_ref;    
						
						IF aux_claveconyugefamilia <> '00' THEN --es familiar
							LET V_claveconyugefamilia = aux_claveconyugefamilia;
						END IF;				
		
				END IF;

				--LET V_referencia3   = 0; --RQM 09 541-2 CrÃ©dito Motos Coppel en Alta Ãnica 07/04/2021 Jonathan Medina
				LET V_referencia4   = '';
				LET V_efectuo       = '';

				LET V_fechamovto        = date(1);

				LET V_telefonocelular  			= lpad(TRIM(nvl(V_telefonocelular, '')), 10, 0);
				LET aux_telefono                = lpad(TRIM(nvl(aux_telefono, '')), 10, 0);
				LET aux_telefono_ref  			= lpad(TRIM(nvl(aux_telefono_ref, '')), 10, 0);
				LET aux_telefonotrabajo         = lpad(TRIM(nvl(aux_telefonotrabajo, '')), 10, 0);
				LET aux_telefonotrabajoconyuge  = lpad(TRIM(nvl(aux_telefonotrabajoconyuge, '')), 10, 0);

				
				IF LENGTH(V_telefonocelular) > 10 THEN
					LET V_telefonocelular    = SUBSTR(V_telefonocelular, -10);    --Toma los 10 digitos de la derecha
				END IF;
				IF LENGTH(aux_telefono) > 10 THEN
					LET aux_telefono    = SUBSTR(aux_telefono, -10);    --Toma los 10 digitos de la derecha
				END IF;

				IF LENGTH(aux_telefono_ref) > 10 THEN
					LET aux_telefono_ref = SUBSTR(aux_telefono_ref, -10);
				END IF;
				
				IF LENGTH(aux_telefonotrabajo) > 10 THEN
					LET aux_telefonotrabajo = SUBSTR(aux_telefonotrabajo, -10);
				END IF;

				IF LENGTH(aux_telefonotrabajoconyuge) > 10 THEN
					LET aux_telefonotrabajoconyuge = SUBSTR(aux_telefonotrabajoconyuge, -10);
				END IF;

				--LET V_Observacion1      = SUBSTR(aux_telefono, 1, 10) ||SUBSTR(aux_telefonotrabajo, 1, 10) ||SUBSTR(aux_telefonotrabajoconyuge, 1, 10);
				LET V_Observacion1      = SUBSTR(V_telefonocelular, 1, 10) ||SUBSTR(aux_telefono, 1, 10) ||SUBSTR(aux_telefono_ref, 1, 10);
                LET V_Observacion1      = replace(V_Observacion1 ,'\','/');
                LET V_Observacion1      = replace(V_Observacion1 ,'|',' '); 
                LET V_Observacion1      = replace(V_Observacion1 ,'''',' '); 
				
				--LET V_Observacion2      = V_monto_solicitado;
				LET V_telefono                  = aux_telefono;
				LET V_telefonotrabajo           = aux_telefonotrabajo;
				LET V_telefonotrabajoconyuge    = aux_telefonotrabajoconyuge;				
				LET V_monto_solicitado          = 0;

				--Cambio 14-11-2007
				--Criterio : Se guardaran los datos del conyuge
--ELL Se modifica consulta para extraer datos del conyuge. En caso de no existir otra referencia
--se toma al conyuge para llenar los campos de dicha referencia. 11/10/2010
				SELECT secuencia,parentesco,nombre1,nombre2,apell_paterno,apell_materno,TRIM(NVL(nombre1,' ')) || ' ' || TRIM(NVL(nombre2,' '))
				INTO v_secuencia,aux_claveconyugefamilia,V_nombre1conyuge,V_nombre2conyuge,V_apellidopaternoconyuge,V_apellidomaternoconyuge,V_nombreconyuge
				FROM bdinteg:"informix".si_refclientes
				WHERE empresa = '001'
				AND num_solicitud = V_NumSolicitud
				AND numcte = V_numcte
				AND parentesco = "E"
                AND secuencia = ( select max(secuencia) from bdinteg:"informix".si_refclientes where empresa = '001'  AND num_solicitud = V_NumSolicitud
                                                                    AND numcte = V_numcte AND parentesco = "E" );
																	
				IF V_nombre1conyuge	IS NULL AND V_apellidopaternoconyuge IS NULL THEN
						
						SELECT LIMIT 1 nvl(a.parentesco, '00') as parentesco, SUBSTR(nombre_ref,1,11), SUBSTR(nombre_ref,12,10), 
						SUBSTR(nombre_ref,22,15), nvl(numcte_ref,0), ---replace(telefono_ref,' ','')
						CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(TRIM(telefono_ref),'')) = 'V' THEN telefono_ref ELSE '0000000000' END
						INTO aux_claveconyugefamilia , V_nombre1conyuge, V_apellidopaternoconyuge, V_apellidomaternoconyuge, V_clienteconyuge_paso, aux_telefono_ref
						FROM bdisolic:ss_refpersonales a
						WHERE a.empresa = '001'
						AND a.num_solicitud = V_NumSolicitud
						AND a.numcte = V_numcte
						AND (a.parentesco = 'E' or TRIM(parentesco)='05');
						
						IF aux_claveconyugefamilia = 'E' THEN --es familiar
								LET V_claveconyugefamilia = aux_claveconyugefamilia;       
						ELSE
							 IF aux_claveconyugefamilia = '05' THEN
								LET V_claveconyugefamilia = 'E';
							 END IF;
						END IF;		
								
				END IF;
																	

				SELECT 
				CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(TRIM(telefono1),'')) = 'V' 
					THEN telefono1 ELSE '0000000000' END,					
				CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(TRIM(telefono2),'')) = 'V' 
					THEN telefono2 ELSE '0000000000' END
				INTO aux_telefono_ref, V_telefonocelularconyuge
				FROM bdinteg:"informix".si_refdirecciones
				WHERE numcte = V_numcte
				AND secuencia = v_secuencia;

				IF aux_claveconyugefamilia = 'E' THEN --es familiar
					LET V_claveconyugefamilia = aux_claveconyugefamilia;
				END IF;
				
--ELL 19/octubre/2010 se agrega la siguiente validacion en caso de que solo exista el numero de cliente del conyuge y no su nombre.
				IF (V_nombreconyuge is null and V_clienteconyuge_paso is not null) THEN
					SELECT apell_paterno , apell_materno ,TRIM(NVL(nombre1,' ')) || ' ' || TRIM(NVL(nombre2,''))
					INTO V_apellidopaternoconyuge , V_apellidomaternoconyuge , V_nombreconyuge
					FROM bdinteg:"informix".si_cliente si
					where si.empresa = '001'
					AND si.numcte = V_clienteconyuge_paso;
				END IF;
				LET V_apellidopaterno1conyuge = V_apellidopaternoconyuge; --JMAH
				LET V_apellidomaterno1conyuge = V_apellidomaternoconyuge; --JMAH

	 -----MACF   20101122
			   IF iTotalReferencias > 0  and nvl(V_nombreconyuge, '') = '' then
			   ---se modifica para aue se guarden los datods de la referencia como el componentente productivo --JMAH
			    LET cNombreCompletoReferencia = TRIM(V_nombrereferencia)|| ' ' ||TRIM(V_apellidopaternoreferencia)|| ' ' ||TRIM(V_apellidomaternoreferencia);
			    LET V_apellidopaternoconyuge = SUBSTR(cNombreCompletoReferencia,12,10);
				LET V_apellidomaternoconyuge = SUBSTR(cNombreCompletoReferencia,22,15);
				LET V_nombreconyuge = 	SUBSTR(cNombreCompletoReferencia,1,11);
			   END IF;


			   LET V_clienteconyuge = esnumerocasa(V_clienteconyuge_paso);

			   IF (iTotalReferencias = 0 and V_nombreconyuge is null) THEN
				LET P_cod_ret = '00004';    --No tiene referencias
				LET P_MENSAJE = 'No tiene referencias.';
			   END IF;
			   IF iTotalReferencias = 0 THEN
				LET V_nombrereferencia = V_nombreconyuge;
				LET V_apellidopaternoreferencia = V_apellidopaternoconyuge;
				LET V_apellidomaternoreferencia =V_apellidomaternoconyuge ;
				LET iTotalReferencias = 1;
			   END IF;
			END IF;			
                   

			IF V_ciudadCoppel IS NULL OR V_ciudadCoppel = 0
				OR V_coloniaCoppel IS NULL OR V_coloniaCoppel = 0
				OR V_NombreZonaCoppel IS NULL OR V_NombreZonaCoppel = '' THEN
					LET P_cod_ret = '00018';
					LET P_MENSAJE = 'CATALOGO NO RELACIONADO EN CIUDAES Y COLONIAS COPPEL-BANCOPPEL';
					EXIT FOREACH;			
			END IF;

			SELECT nvl(MAX(secuencia),0), COUNT(*)
			INTO iMax, iCuantos
			FROM "informix".ss_ossecuencia;

			LET iMax    = iMax + 1;

			IF iCuantos = 0 THEN
				INSERT INTO "informix".ss_ossecuencia(secuencia) VALUES(iMax);
			ELSE
				UPDATE "informix".ss_ossecuencia SET secuencia = iMax;
			END IF;
			LET V_folio = iMax;

            -- Obtiene el sufijo del producto para el complemento (entre calles) dependiendo del numero de producto relacionado a la OS
            SELECT prefijo_os INTO v_prefijo_os_prod FROM bdicred:"informix".sd_definicion WHERE num_producto = v_NumProducto;
            
			SELECT factor_piso INTO V_factor_piso FROM bdisolic:"informix".ss_solicitudes WHERE empresa = '001' AND numcte = V_numcte AND num_solicitud = V_NumSolicitud ;

			IF v_NumProducto = 6500 AND (V_factor_piso = 2 OR V_factor_piso = 3) THEN
						
				IF V_factor_piso = 3 and LENGTH(V_complemento) >= 28 THEN
					LET V_complemento = 10 || '/' || (SUBSTR(V_complemento,1,LENGTH(V_complemento)-3));
				ELIF V_factor_piso = 3 and LENGTH(V_complemento) < 28 THEN
					LET V_complemento = 10 || '/' || V_complemento;
				ELIF V_factor_piso = 2 and LENGTH(V_complemento) > 28 THEN
					LET V_complemento = 9 || '/' || (SUBSTR(V_complemento,1,LENGTH(V_complemento)-2));
				ELSE
					LET V_complemento = 9 || '/' || V_complemento;	
				END IF;
				
			ELSE
			
				IF LENGTH(V_complemento) > 28 THEN
					LET V_complemento =  v_prefijo_os_prod || '/' || (SUBSTR(V_complemento,1,LENGTH(V_complemento)-2));
				ELSE
					LET V_complemento =  v_prefijo_os_prod || '/' || V_complemento;
				END IF;
			
			END IF;
			

			
			IF TRIM(V_NombreZonaCoppel) = "EL RASCÃÂÃÂ??'N (LA LOMA)" THEN
			   LET V_NombreZonaCoppel = "EL RASCON (LA LOMA)";
			END IF;
			
			IF TRIM(V_nombrezonatrabajocoppel) = "EL RASCÃÂÃÂ??'N (LA LOMA)" THEN
			   LET V_nombrezonatrabajocoppel = "EL RASCON (LA LOMA)";
			END IF;
            
            LET V_complemento = replace(nvl(V_complemento,''),'\','/');

        
			---------------------   LINK   -------------------------------------------------------
 		    LET V_complemento = replace(nvl(V_complemento,''),"'",'');
    	  	LET V_complemento = replace(nvl(V_complemento,''),"|",'');
	  		--------------------------------------------------------------------------------------


			SELECT canal_sol,estatus
				INTO   cCanalAux,statusAux
			FROM bdisolic:ss_prospecteo_solicitudes 
				WHERE num_solicitud = V_NumSolicitud;
			
			IF cCanalAux IS NULL THEN
				LEt cCanalAux = '';
			END IF;
			
			IF statusAux IS NULL THEN
				LEt statusAux = '';
			END IF;
			
			IF cCanalAux = '0' AND v_NumProducto = '6500' AND statusAux = 'A' THEN
				LET V_Observacion3 = 'Prospecteo (Continua entrega en tienda)';
								
				UPDATE bdisolic:"informix".ss_prospecteo_solicitudes 
					set status_solicitud = 'OS'  
				where num_solicitud = V_NumSolicitud; 
			END IF;
			

			INSERT INTO "informix".ss_osclientesupervisar(
				secuencia, Empresa, Num_Solicitud, FechaSolicitud, FechaImpresion, FechaRespuesta, EstatusOs, Observacion1, Observacion2, Observacion3, 				--hsrr 387
				clave, tiendafolio, folio, nombre, apellidopaterno, apellidomaterno, curp, claveelector, claveidentificacion, identificacion, ciudad,
				colonia, calle, casa, deptoointerior, rumbo, complemento, flaguhc, uhcmanzana, uhcotros, uhcandador, uhcetapa, uhclote, uhcedificio,
				uhcentrada, telefono, telefonocelular, casapropia, sexo, estadocivil, fechanacimiento, fechadesdecuandoviveahi, personasvivenendomicilio,
				tiposueldo, numerodependientes, personastrabajan, ingresomensual, situacionespecial, causasituacionespecial, claveautrechaza, creditojoven,
				lugartrabajo, ciudadtrabajo, coloniatrabajo, calletrabajo, casatrabajo, deptoointeriortrabajo, rumbotrabajo, complementotrabajo, flaguht,
				uhtmanzana, uhtotros, uhtandador, uhtetapa, uhtlote, uhtedificio, uhtentrada, telefonotrabajo, extensiontrabajo, puesto, opcionpuesto,
				fechaantiguedadtrabajo, clienteconyuge, nombreconyuge, apellidopaternoconyuge, apellidomaternoconyuge, lugartrabajoconyuge, ciudadconyuge,
				coloniaconyuge, calletrabajoconyuge, casatrabajoconyuge, deptoointeriorconyuge, rumbotrabajoconyuge, complementoconyuge, flaguhy, uhymanzana,
				uhyotros, uhyandador, uhyetapa, uhylote, uhyedificio, uhyentrada, telefonotrabajoconyuge, telefonocelularconyuge, claveconyugefamilia,
				clientereferencia, nombrereferencia, apellidopaternoreferencia, apellidomaternoreferencia, ciudadreferencia, coloniareferencia, callereferencia,
				casareferencia, deptoointeriorreferencia, rumboreferencia, complementoreferencia, flaguhr, uhrmanzana, uhrotros, uhrandador, uhretapa,
				uhrlote, uhredificio, uhrentrada, telefonoreferencia, telefonocelularreferencia, referencia3, referencia4, efectuo, fechaaltacliente,
				fechamovto, limitecredito, ciudadcoppel, coloniacoppel, nombrezonacoppel, ciudadtrabajocoppel, coloniatrabajocoppel, nombrezonatrabajocoppel,
				numeroclientebancoppel, flagproductocoppel, tipoos, tipoproducto, nombre1, nombre2, apellidopaterno1, apellidomaterno1, --Moha
				nombre1conyuge, nombre2conyuge,apellidopaterno1conyuge,apellidomaterno1conyuge, nombre1referencia, nombre2referencia,apellidopaterno1referencia,apellidomaterno1referencia)
			VALUES(
				iMax, V_Empresa, V_NumSolicitud, V_FechaSolicitud, V_FechaImpresion, V_FechaRespuesta, V_EstatusOs, V_Observacion1, V_Observacion2, V_Observacion3, 			--hsrr 387
				V_clave, V_tiendafolio, V_folio, V_nombre, V_apellidopaterno, V_apellidomaterno, V_curp, V_claveelector, V_claveidentificacion, V_identificacion, V_ciudad,
				V_colonia, V_calle, V_casa, V_deptoointerior, V_rumbo, V_complemento, V_flaguhc, V_uhcmanzana, V_uhcotros, V_uhcandador, V_uhcetapa, V_uhclote, V_uhcedificio,
				V_uhcentrada, V_telefono, V_telefonocelular, V_casapropia, V_sexo, V_estadocivil, V_fechanacimiento, V_fechadesdecuandoviveahi, V_personasvivenendomicilio,
				V_tiposueldo, V_numerodependientes, V_personastrabajan, V_ingresomensual, V_situacionespecial, V_causasituacionespecial, V_claveautrechaza, V_creditojoven,
				V_lugartrabajo, V_ciudadtrabajo, V_coloniatrabajo, V_calletrabajo, V_casatrabajo, V_deptoointeriortrabajo, V_rumbotrabajo, V_complementotrabajo, V_flaguht,
				V_uhtmanzana, V_uhtotros, V_uhtandador, V_uhtetapa, V_uhtlote, V_uhtedificio, V_uhtentrada, V_telefonotrabajo, V_extensiontrabajo, V_puesto, V_opcionpuesto,
				V_fechaantiguedadtrabajo, V_clienteconyuge, V_nombreconyuge, V_apellidopaternoconyuge, V_apellidomaternoconyuge, V_lugartrabajoconyuge, V_ciudadconyuge,
				V_coloniaconyuge, V_calletrabajoconyuge, V_casatrabajoconyuge, V_deptoointeriorconyuge, V_rumbotrabajoconyuge, V_complementoconyuge, V_flaguhy, V_uhymanzana,
				V_uhyotros, V_uhyandador, V_uhyetapa, V_uhylote, V_uhyedificio, V_uhyentrada, V_telefonotrabajoconyuge, V_telefonocelularconyuge, V_claveconyugefamilia,
				V_clientereferencia, V_nombrereferencia, V_apellidopaternoreferencia, V_apellidomaternoreferencia, V_ciudadreferencia, V_coloniareferencia, V_callereferencia,
				V_casareferencia, V_deptoointeriorreferencia, V_rumboreferencia, V_complementoreferencia, V_flaguhr, V_uhrmanzana, V_uhrotros, V_uhrandador, V_uhretapa,
				V_uhrlote, V_uhredificio, V_uhrentrada, V_telefonoreferencia, V_telefonocelularreferencia, V_referencia3, V_referencia4, V_efectuo, V_fechaaltacliente,
				CURRENT,v_limitecredito, V_ciudadCoppel, V_coloniaCoppel, V_NombreZonaCoppel, V_ciudadtrabajocoppel, V_coloniatrabajocoppel, V_nombrezonatrabajocoppel,
				V_numcte, v_flagproductocoppel, v_tipoos, v_tipoproducto,V_nombre1, V_nombre2, V_apellidopaterno1, V_apellidomaterno1, --Moha
				V_nombre1conyuge, V_nombre2conyuge,V_apellidopaterno1conyuge, V_apellidomaterno1conyuge,V_nombre1referencia, V_nombre2referencia,V_apellidopaterno1referencia, V_apellidomaterno1referencia);
				   -- Se agrega ciclo para actualizar todas la solicitudes del cliente con estatus S no solo la que se esta presesando
			FOREACH

			SELECT a.num_solicitud, a.fecha_solicitud, b.status_solicitud
			INTO V_NumSolicitud_Cliente, V_FechaSolicitud_Cliente, sStatus_solic
			FROM bdisolic:"informix".ss_solicitud_os a, bdisolic:"informix".ss_solicitudes b
			WHERE a.num_solicitud = b.num_solicitud
			AND status = 'S'
			AND numcte = V_numcte

				UPDATE "informix".ss_solicitud_os
				SET status = 'P', secuenciaos = iMax
				WHERE num_solicitud = V_NumSolicitud_Cliente AND fecha_solicitud = V_FechaSolicitud_Cliente AND status = 'S';
				     				
				LET sStatus_solic      = replace(sStatus_solic ,'\','/');
                LET sStatus_solic      = replace(sStatus_solic ,'|',' '); 
                LET sStatus_solic      = replace(sStatus_solic ,'''',' ');

				UPDATE bdisolic:"informix".ss_os_solautdirecta
				SET status = 'P',status_sol = ' '
				WHERE num_solicitud = V_NumSolicitud_Cliente;

				--Avanza solic al nuevo estatus
				--IF sStatus_solic NOT IN('AT', 'AP') THEN
                IF sStatus_solic IN('EE','CE') THEN
					EXECUTE PROCEDURE "informix".sp_actualiza_status_sol('001', 'sistema', V_NumSolicitud_Cliente, 'OS', '','Integracion datos de OS')
					INTO scod_ret6;

					IF scod_ret6 <> '000000' THEN
						IF LENGTH(TRIM(scod_ret6)) = 6 THEN  --No cabe en la long actual de la var p_cod_ret
							LET P_cod_ret = '00017'; --Nota: 00017 Solo si la long del error generado es de 6 caracteres
						Else
							LET P_cod_ret = TRIM(scod_ret6);
						END IF;
						LET P_MENSAJE = scod_ret6 ||' Error al avanzar estatus de solicitud.';
					ELSE  --IPCB RQM 06 646			
						IF (SELECT count(numcte) FROM "informix".ss_solicitudes_movil							
							WHERE 	empresa  =  '001' AND  numcte = V_numcte AND num_solicitud = V_NumSolicitud) >0  THEN
							
							
							IF V_telefonocelular <> "" THEN
							    	SELECT msj_alta_movil  --RQM 09 497
									INTO  vProdAltaMovil
									FROM bdicred:"informix".sd_definicion 						
									WHERE 	empresa  = pEmpresa 
									AND num_producto = '6001';

									SELECT tp_solicitud  --RQM 09 497
									INTO  vTpProd
									FROM bdisolic:"informix".ss_solic_producto
									WHERE num_producto = '6001';
								
								  IF  vProdAltaMovil = '1' AND vTpProd = 'T' THEN
								  		CALL bdimnsj:"informix".sp_registra_evento(2,'CRED_SMS','SOL_MV_OS','000000000','', '',1,V_NumSolicitud, '', '', '', '', '', '', '', '', '', '',V_telefonocelular, 0, 0,0, 0, 0, current, current) 
										RETURNING CodRet_regev;							  								  
								  ELSE
										CALL bdimnsj:"informix".sp_registra_evento(2,'OPER_SMS','OSMOV_VSMS','000000000','', '',1,V_NumSolicitud, '', '', '', '', '', '', '', '', '', '',V_telefonocelular, 0, 0,0, 0, 0, current, current) 
										RETURNING CodRet_regev;
  								  END IF;
							END IF;		
						END IF;		
					END IF;
				END IF;
			END FOREACH;
	     END IF; --valida que exista cliente
	END IF;            
	END FOREACH;    --Principal
END IF;

    IF iEncuentraSolic = 0 AND P_cod_ret = "00000" THEN
        LET P_cod_ret = '00011';
        LET P_MENSAJE = 'SOLICITUD NO ENCONTRADA EN SS_SOLICITUD_OS'; --ERRORES DE GUARDADO ANTES DEL LLAMADO A ESTE PROCEDIMIENTO O ROLLBACK A SESION INTERACT
    END IF;

    IF P_cod_ret = "00000" THEN --no hubo errores
        COMMIT WORK;
    ELSE
        ROLLBACK WORK;
        BEGIN WORK;
            IF P_COD_RET = '00015' THEN
                IF sStatus_solic IN ('RT', 'AN') THEN
                    FOREACH
                    SELECT a.num_solicitud, a.fecha_solicitud
                    INTO V_NumSolicitud_Cliente, V_FechaSolicitud_Cliente
                    FROM bdisolic:"informix".ss_solicitud_os a, bdisolic:"informix".ss_solicitudes b
                    WHERE a.num_solicitud = b.num_solicitud
                        and status = 'S'
                        and numcte = (SELECT numcte FROM bdisolic:"informix".ss_solicitudes WHERE num_solicitud = pnum_solicitud)
                        
                        UPDATE "informix".ss_solicitud_os
                        SET status = 'C' -- Cancelada, para que ya no se vuelva a procesar
                        WHERE num_solicitud = V_NumSolicitud_Cliente and fecha_solicitud = V_FechaSolicitud_Cliente AND status = 'S';                        
                       
                        UPDATE bdisolic:"informix".ss_os_solautdirecta
                        SET status = 'C'
                        WHERE num_solicitud = V_NumSolicitud_Cliente;

                    END FOREACH;

                    LET P_MENSAJE = P_MENSAJE ||' Se Cancela OS.';
                END IF;
            ELIF P_COD_RET = '00018' THEN
              FOREACH
                    SELECT a.num_solicitud, a.fecha_solicitud, status_solicitud 
                    INTO V_NumSolicitud_Cliente, V_FechaSolicitud_Cliente, sStatus_solic
                    FROM bdisolic:"informix".ss_solicitud_os a, bdisolic:"informix".ss_solicitudes b
                    WHERE a.num_solicitud = b.num_solicitud
                        and status = 'S'
                        and numcte = (SELECT numcte FROM bdisolic:"informix".ss_solicitudes WHERE num_solicitud = pnum_solicitud)
						LET V_NumSolicitud_Cliente=V_NumSolicitud_Cliente;
					IF sStatus_solic NOT IN('CE','AP','AT') THEN                    
					  EXECUTE PROCEDURE "informix".sp_actualiza_status_sol('001', 'sistema', V_NumSolicitud_Cliente, 'CE', "",'CATALOGO NO RELACIONADO EN CIUDAES Y COLONIAS COPPEL-BANCOPPEL')
                      INTO scod_ret6;
                   	  IF scod_ret6 <> '000000' THEN
                      	   IF LENGTH(TRIM(scod_ret6)) = 6 THEN  --No cabe en la long actual de la var p_cod_ret
      	                      LET P_cod_ret = '00017'; --Nota: 00017 Solo si la long del error generado es de 6 caracteres
                     	   ELSE
                    	        LET P_cod_ret = TRIM(scod_ret6);
                     	   END IF;
 	                      	  LET P_MENSAJE = scod_ret6 ||' Error al avanzar estatus de solicitud a CE.';
                   	   END IF;				
				  ELSE
				    IF  SUBSTR(v_tipoproducto,2,1) = '1' THEN--solicitudes coppel				
						UPDATE bdisolic:"informix".ss_os_solautdirecta 
							SET status_sol = 'CE',
								flagCE  = 1
						WHERE num_solicitud = V_NumSolicitud;
					END IF;
				  END IF;
              END FOREACH;				  
            END IF;
            INSERT INTO "informix".ss_os_errores(num_solicitud, fechasolicitud, Codigo_Error, descripcion_error, FechaProceso )
            VALUES(pnum_solicitud, pfechasolicitud, P_COD_RET, P_MENSAJE, CURRENT);
        COMMIT WORK;
    END IF;
    IF (wBegin = "S") THEN
        BEGIN WORK;
    END IF;
    RETURN P_cod_ret;
END;
END PROCEDURE


