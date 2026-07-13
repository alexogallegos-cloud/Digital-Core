CREATE PROCEDURE "informix".sp_orden_supervisionbc(lsecuencia INTEGER)
RETURNING 
char(5) as CodRet,
char(20) as num_solicitud,
integer	as estatusos,
char(40) as observacion1,
char(40) as observacion2,
smallint as tiendafolio,
integer as folio,
char(15) as nombre,
char(15) as apellidopaterno,
char(15) as apellidomaterno,
smallint as ciudad,
smallint as colonia,
integer as calle,
integer as casa,
char(4) as deptoointerior,
char(1) as rumbo,
char(30) as complemento,
smallint as flaguhc,
smallint as uhcmanzana,
smallint as uhcotros,
smallint as uhcandador,
smallint as uhcetapa,
smallint as uhclote,
smallint as uhcedificio,
smallint as uhcentrada,
char(1) as casapropia,
char(1) as sexo,
char(1) as estadocivil,
date as fechanacimiento,
date as fechadesdecuandoviveahi,
smallint as personastrabajan,
decimal(14,2) as ingresomensual,
char(20) as lugartrabajo,
smallint as ciudadtrabajo,
smallint as coloniatrabajo,
integer as calletrabajo,
integer as casatrabajo,
char(4) as deptoointeriortrabajo,
char(1) as rumbotrabajo,
char(30) as complementotrabajo,
smallint as flaguht,
smallint as uhtmanzana,
smallint as uhtotros,
smallint as uhtandador,
smallint as uhtetapa,
smallint as uhtlote,
smallint as uhtedificio,
smallint as uhtentrada,
char(1) as puesto,
date as fechaantiguedadtrabajo,
integer as clienteconyuge,
char(15) as nombreconyuge,
char(15) as apellidopaternoconyuge,
char(15) as apellidomaternoconyuge,
char(1) as claveconyugefamilia, 
smallint as limitecredito,
integer as secuencia,
date as fechasolicitud,
date as fechaaltacliente,
integer as numeroclientebancoppel,
smallint as flagproductocoppel,
char(1) as tipoos,
char(5) as tipoproducto,
char(26) as nombre1,
char(26) as nombre2,
char(26) as apellidopaterno1,
char(26) as apellidomaterno1,
char(26) as nombre1conyuge,
char(26) as nombre2conyuge,
char(26) as apellidopaterno1conyuge,
char(26) as apellidomaterno1conyuge,
char(26) as nombre1referencia,
char(26) as nombre2referencia,
char(26) as apellidopaterno1referencia,
char(26) as apellidomaterno1referencia,
smallint as ciudadcoppel,
smallint as coloniacoppel,
char(32) as nombrezonacoppel,
smallint as ciudadtrabajocoppel,
smallint as coloniatrabajocoppel,
char(32) as nombrezonatrabajocoppel,
char(1) as situacionespecial, 
smallint as causasituacionespecial,
char(18) as curp,
char(1) as claveidentificacion,
char(8) as identificacion,
char(15) as telefonocelular,
char(1) as tiposueldo,
char(15) as nombrereferencia,
char(15) as apellidopaternoreferencia,
char(15) as apellidomaternoreferencia,
decimal(18,0) as telefonoreferencia,
char(15) as telefonocelularreferencia,
char(3) as empresa,
decimal(18,0) as telefono,
decimal(18,0) as telefonotrabajo,
decimal(18,0) as telefonotrabajoconyuge,
decimal(18,0) as telefonocelularconyuge,
char(40) as observacion3;
--char(1) as tiposueldo,
--smallint as numerodependientes,

--DEFINICION DE VARIABLES
--DEFINE cTipoSueldo char(1);
--DEFINE iNumeroDePendientes smallint;
DEFINE cCodRet char(5);
DEFINE sql_err integer;
DEFINE cNum_Solicitud char(20);
DEFINE dFechaSolicitud date;
DEFINE iEstatusos integer;
DEFINE cObservacion1 char(40);
DEFINE cObservacion2 char(40);
DEFINE cObservacion3 char(40); --Contiene Calle y numero de las solicitudes Movil
--DEFINE cClave char(1);
DEFINE iTiendaFolio smallint;
DEFINE iFolio integer;
DEFINE cNombre char(15);
DEFINE cApellidoPaterno char(15);
DEFINE cApellidoMaterno char(15);
DEFINE iCiudad smallint;
DEFINE iColonia smallint;
DEFINE iCalle integer;
DEFINE iCasa integer;
DEFINE cDeptooInterior char(4);
DEFINE cRumbo char(1);
DEFINE cComplemento char(30);
DEFINE iFlaguhc smallint;
DEFINE iUhcmanzana smallint;
DEFINE iUhcotros smallint;
DEFINE iUhcandador smallint;
DEFINE iUhcetapa smallint;
DEFINE iUhclote  smallint;
DEFINE iUhcedificio smallint;
DEFINE iUhcentrada smallint;
DEFINE cCasaPropia char(1);
DEFINE cSexo char(1);
DEFINE cEstadoCivil char(1);
DEFINE dFechaNacimiento date;
DEFINE dFechadesdecuandoviveahi	date;
DEFINE iPersonasTrabajan smallint;
DEFINE dIngresoMensual decimal(14,2);
DEFINE cLugarTrabajo char(20);
DEFINE iCiudadTrabajo smallint;
DEFINE iColoniaTrabajo smallint;
DEFINE iCalleTrabajo integer;
DEFINE iCasaTrabajo integer;
DEFINE cDeptooInteriorTrabajo char(4);
DEFINE cRumboTrabajo char(1);
DEFINE cComplementoTrabajo char(30);
DEFINE iFlaguht smallint;
DEFINE iUhtmanzana smallint;
DEFINE iUhtotros smallint;
DEFINE iUhtandador smallint;
DEFINE iUhtetapa smallint;
DEFINE iUhtlote smallint;
DEFINE iUhtedificio smallint;
DEFINE iUhtentrada smallint;
DEFINE cPuesto char(1);
DEFINE dFechaantiguedadTrabajo date;
DEFINE iClienteConyuge integer;
DEFINE cNombreConyuge char(15);
DEFINE cClaveConyugeFamilia	char(1);
DEFINE cApellidoPaternoConyuge char(15);
DEFINE cApellidoMaternoConyuge char(15);
DEFINE iLimiteCredito smallint;
DEFINE iSecuencia integer;
DEFINE dFechaAltaCliente date;
DEFINE iNumeroClienteBancoppel integer;
DEFINE iFlagProductoCoppel smallint;
DEFINE cTipoos char(1);
DEFINE cTipoProducto char(5);
DEFINE cNombre1 char(26); 
DEFINE cNombre2 char(26);
DEFINE cApellidoPaterno1 char(26);
DEFINE cApellidoMaterno1 char(26);
DEFINE cNombre1Conyuge char(26);
DEFINE cNombre2Conyuge char(26);
DEFINE cApellidoPaterno1Conyuge char(26);
DEFINE cApellidoMaterno1Conyuge char(26);
DEFINE cNombre1Referencia char(26);
DEFINE cNombre2Referencia char(26);
DEFINE cApellidoPaterno1Referencia char(26);
DEFINE cApellidomaterno1Referencia char(26);
DEFINE iCiudadCoppel smallint;
DEFINE iColoniaCoppel smallint;
DEFINE cNombreZonaCoppel char(32);
DEFINE iCiudadTrabajoCoppel smallint;
DEFINE iColoniaTrabajoCoppel smallint;
DEFINE cNombreZonaTrabajoCoppel char(32);
DEFINE cSituacionespecial char(1);
DEFINE iCausasituacionespecial smallint;
DEFINE cCurp char(18);
DEFINE cClaveidentificacion char(1);
DEFINE cIdentificacion char(8);
DEFINE cTelefonocelular char(15);
DEFINE cTiposueldo char(1);
DEFINE cNombrereferencia char(15);
DEFINE cApellidopaternoreferencia char(15);
DEFINE cApellidomaternoreferencia char(15);
DEFINE dTelefonoreferencia decimal(18,0);
DEFINE cTelefonocelularreferencia char(15);
DEFINE cEmpresa char(3);
DEFINE dTelefono decimal(18,0);
DEFINE dTelefonotrabajo decimal(18,0);
DEFINE dTelefonotrabajoconyuge decimal(18,0);
DEFINE dTelefonocelularconyuge decimal(18,0);


--ASIGNACION DE VARIABLES
LET cCodRet = "00000";
LET sql_err = 0;
LET cNum_Solicitud = "";
LET dFechaSolicitud = "";
LET iEstatusos = 0;
LET cObservacion1 = "";
LET cObservacion2 = "";
LET cObservacion3 = "";
--LET cClave = '';
LET iTiendaFolio = 0;
LET iFolio = 0;
LET cNombre = "";
LET cApellidoPaterno = "";
LET cApellidoMaterno = "";
LET iCiudad = 0;
LET iColonia = 0;
LET iCalle = 0;
LET iCasa = 0;
LET cDeptooInterior = "";
LET cRumbo = '';
LET cComplemento = "";
LET iFlaguhc = 0;
LET iUhcmanzana = 0;
LET iUhcotros = 0;
LET iUhcandador = 0;
LET iUhcetapa = 0;
LET iUhclote = 0;
LET iUhcedificio = 0;
LET iUhcentrada = 0;
LET cCasaPropia = '';
LET cSexo = '';
LET cEstadoCivil = '';
LET dFechaNacimiento = "";
LET dFechadesdecuandoviveahi = "";
LET iPersonasTrabajan = 0;
LET dIngresoMensual = 0.0;
LET cLugarTrabajo = "";
LET iCiudadTrabajo = 0;
LET iColoniaTrabajo = 0;
LET iCalleTrabajo = 0;
LET iCasaTrabajo = 0;
LET cDeptooInteriorTrabajo = "";
LET cRumboTrabajo = '';
LET cComplementoTrabajo = "";
LET iFlaguht = 0;
LET iUhtmanzana = 0;
LET iUhtotros = 0;
LET iUhtandador = 0;
LET iUhtetapa = 0;
LET iUhtlote = 0;
LET iUhtedificio = 0;
LET iUhtentrada = 0;
LET cPuesto = '';
LET dFechaantiguedadTrabajo = "";
LET iClienteConyuge = 0;
LET cNombreConyuge = "";
LET cClaveConyugeFamilia = '';
LET cApellidoPaternoConyuge = "";
LET cApellidoMaternoConyuge = "";
LET iLimiteCredito = 0;
LET iSecuencia = 0;
LET dFechaAltaCliente = "";
LET iNumeroClienteBancoppel	= 0;
LET iFlagProductoCoppel = 0;
LET cTipoos = '';
LET cTipoProducto = "";
LET cNombre1 = ""; 
LET cNombre2 = "";
LET cApellidoPaterno1 = "";
LET cApellidoMaterno1 = "";
LET cNombre1Conyuge = "";
LET cNombre2Conyuge = "";
LET cApellidoPaterno1Conyuge = "";
LET cApellidoMaterno1Conyuge = "";
LET cNombre1Referencia = "";
LET cNombre2Referencia = "";
LET cApellidoPaterno1Referencia = "";
LET cApellidomaterno1Referencia = "";
LET iCiudadCoppel = 0;
LET iColoniaCoppel = 0;
LET cNombreZonaCoppel = "";
LET iCiudadTrabajoCoppel = 0;
LET iColoniaTrabajoCoppel = 0;
LET cNombreZonaTrabajoCoppel = "";
LET cSituacionespecial = "";
LET iCausasituacionespecial = 0;
LET cCurp = "";
LET cClaveidentificacion = "";
LET cIdentificacion = "";
LET cTelefonocelular = "";
LET cTiposueldo = "";
LET cNombrereferencia = "";
LET cApellidopaternoreferencia = "";
LET cApellidomaternoreferencia = "";
LET dTelefonoreferencia = 0.0;
LET cTelefonocelularreferencia = "";
LET cEmpresa = "";
LET dTelefono = 0.0;
LET dTelefonotrabajo = 0.0;
LET dTelefonotrabajoconyuge = 0.0;
LET dTelefonocelularconyuge = 0.0;

--SET DEBUG FILE TO "/tem/sp_orden_supervisionbc.out";
--TRACE ON;

BEGIN
		--MANEJO DE EXCEPCIONES (ERRORES) 57 RET
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				let cCodRet = sql_err;
				RETURN cCodRet, '','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','';
			END IF;
		END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;
	
	FOREACH
	Select nvl(num_solicitud,' '), nvl(estatusos,' '), nvl(observacion1,' '), nvl(observacion2,' '), nvl(observacion3,' '), nvl(tiendafolio,0),
	nvl(folio,0),nvl(nombre,' '), nvl(apellidopaterno,' '), nvl(apellidomaterno,' '),nvl(ciudad,0), nvl(colonia,0), 
	nvl(calle,0),nvl(casa,0), nvl(deptoointerior,' '), nvl(rumbo,' '), nvl(complemento, ' '), nvl(flaguhc,0),nvl(uhcmanzana,0), 
	nvl(uhcotros,0), nvl(uhcandador,0), nvl(uhcetapa,0), nvl(uhclote,0), nvl(uhcedificio,0),nvl(uhcentrada,0), nvl(casapropia,' '), 
	nvl(sexo,' '), nvl(estadocivil,' '), fechanacimiento, fechadesdecuandoviveahi, nvl(personastrabajan,0), 
	nvl(ingresomensual::char(16),' '), nvl(lugartrabajo,' '), nvl(ciudadtrabajo,0),nvl(coloniatrabajo,0), nvl(calletrabajo,0), 
	nvl(casatrabajo,0),nvl(deptoointeriortrabajo,' '), nvl(rumbotrabajo,''), nvl(complementotrabajo, ''), nvl(flaguht,0), 
	nvl(uhtmanzana,0),nvl(uhtotros,0), nvl(uhtandador,0), nvl(uhtetapa,0), nvl(uhtlote,0), nvl(uhtedificio,0), 
	nvl(uhtentrada,0),nvl(puesto,'0'), 
	fechaantiguedadtrabajo, nvl(clienteconyuge,0), nvl(nombreconyuge,' '), nvl(apellidopaternoconyuge,' '),
	nvl(apellidomaternoconyuge,' '), nvl(claveconyugefamilia,' '), nvl(limitecredito,0), nvl(secuencia,0), fechasolicitud, 
	fechaaltacliente,  nvl(numeroclientebancoppel,0), nvl(flagproductocoppel,0), nvl(tipoos,' '), nvl(tipoproducto,' '), 
	nvl(nombre1,' '), nvl(nombre2,' '), nvl(apellidopaterno1,' '), nvl(apellidomaterno1,' '), 
	nvl(nombre1conyuge, ' '), nvl(nombre2conyuge, ' '), nvl(apellidopaterno1conyuge, ' '), nvl(apellidomaterno1conyuge, ' '), 
	nvl(nombre1referencia, ' '),nvl(nombre2referencia, ' '), nvl(apellidopaterno1referencia, ' '), 
	nvl(apellidomaterno1referencia, ' '), 
	--NUEVOS CAMPOS
	NVL(ciudadcoppel, 0), NVL(coloniacoppel, 0), NVL(nombrezonacoppel, ' '), NVL(ciudadtrabajocoppel, 0), 
	NVL(coloniatrabajocoppel, 0), NVL(nombrezonatrabajocoppel, ' '), NVL (situacionespecial, ' '), NVL(causasituacionespecial, 0),
	NVL (curp, ' '), NVL (claveidentificacion, ' '), NVL (identificacion, ' '), REPLACE(NVL(TRIM(telefonocelular),''),'',0), NVL (tiposueldo, ' '), NVL (nombrereferencia, ' '),
	NVL (apellidopaternoreferencia, ' '), NVL (apellidomaternoreferencia, ' '), NVL(telefonoreferencia::CHAR(18),'0'), CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(TRIM(telefonocelularreferencia),'')) = 'V' THEN telefonocelularreferencia ELSE '0000000000' END, NVL (empresa, ' '),
	--NUEVOS CAMPOS DSB 04/04/18
	NVL(telefono::CHAR(18),'0'),NVL(telefonotrabajo::CHAR(18),'0'),NVL(telefonotrabajoconyuge::CHAR(18),'0'),NVL(telefonocelularconyuge::CHAR(18),'0')
	INTO cNum_Solicitud, iEstatusos, cObservacion1,cObservacion2,cObservacion3,iTiendaFolio, 
	iFolio, cNombre, cApellidoPaterno, cApellidoMaterno, iCiudad, iColonia, 
	iCalle, iCasa, cDeptooInterior, cRumbo, cComplemento, iFlaguhc,iUhcmanzana, 
	iUhcotros, iUhcandador, iUhcetapa, iUhclote, iUhcedificio, iUhcentrada, cCasaPropia,  
	cSexo, cEstadoCivil, dFechaNacimiento, dFechadesdecuandoviveahi,iPersonasTrabajan, 
	dIngresoMensual, cLugarTrabajo, iCiudadTrabajo,iColoniaTrabajo, iCalleTrabajo, 
	iCasaTrabajo, cDeptooInteriorTrabajo, cRumboTrabajo, cComplementoTrabajo,iFlaguht, 
	iUhtmanzana, iUhtotros, iUhtandador, iUhtetapa, iUhtlote, iUhtedificio, 
	iUhtentrada, cPuesto,
	dFechaantiguedadTrabajo, iClienteConyuge, cNombreConyuge, cApellidoPaternoConyuge, 
	cApellidoMaternoConyuge, cClaveConyugeFamilia, iLimiteCredito, iSecuencia, dFechaSolicitud,
	dFechaAltaCliente, iNumeroClienteBancoppel, iFlagProductoCoppel, cTipoos, cTipoProducto, 
	cNombre1, cNombre2, cApellidoPaterno1,cApellidoMaterno1, 
	cNombre1Conyuge, cNombre2Conyuge, cApellidoPaterno1Conyuge, cApellidoMaterno1Conyuge, 
	cNombre1Referencia,cNombre2Referencia, cApellidoPaterno1Referencia, 
	cApellidomaterno1Referencia,
	--NUEVOS CAMPOS
	iCiudadCoppel, iColoniaCoppel, cNombreZonaCoppel, iCiudadTrabajoCoppel, 
	iColoniaTrabajoCoppel, cNombreZonaTrabajoCoppel, cSituacionespecial, iCausasituacionespecial,
	cCurp, cClaveidentificacion, cIdentificacion, cTelefonocelular, cTiposueldo, cNombrereferencia, 
	cApellidopaternoreferencia, cApellidomaternoreferencia, dTelefonoreferencia, cTelefonocelularreferencia, cEmpresa,
	--NUEVOS CAMPOS DSB 04/04/18
	dTelefono, dTelefonotrabajo, dTelefonotrabajoconyuge, dTelefonocelularconyuge
	From bdisolic:"informix".ss_osclientesupervisar
	Where clave ='' and secuencia > lsecuencia
		and fechasolicitud >= mdy('07','27','2023') AND secuencia < '9000000' -- Se tomaran solo las solicitudes de este anio y con secuencia menor a la que se tiene actualmente en el puente 
	--	and fechasolicitud > mdy('12','01','2021') AND secuencia < '9000000' -- Se tomaran solo las solicitudes de este anio y con secuencia menor a la que se tiene actualmente en el puente 
	-- 18/Nov/2021	AND fechasolicitud > mdy('04','06','2020') AND secuencia < '9000000' -- Se tomaran solo las solicitudes de este anio y con secuencia menor a la que se tiene actualmente en el puente 
	---AND fechasolicitud > mdy('05','22','2019') AND secuencia < '8000000' -- Se tomaran solo las solicitudes de este anio y con secuencia menor a la que se tiene actualmente en el puente 
	---AND fechasolicitud > mdy('01','01','2018') AND secuencia < '9000000' -- Se tomaran solo las solicitudes de este anio y con secuencia menor a la que se tiene actualmente en el puente 
	order by secuencia
	
	RETURN cCodRet, cNum_Solicitud, iEstatusos, cObservacion1,cObservacion2,iTiendaFolio, iFolio, cNombre, 
	cApellidoPaterno, cApellidoMaterno, iCiudad, iColonia, iCalle, iCasa, cDeptooInterior, cRumbo, cComplemento, 
	iFlaguhc,iUhcmanzana, iUhcotros, iUhcandador, iUhcetapa, iUhclote, iUhcedificio, iUhcentrada, cCasaPropia,  cSexo, 
	cEstadoCivil, dFechaNacimiento, dFechadesdecuandoviveahi,iPersonasTrabajan, dIngresoMensual, cLugarTrabajo, 
	iCiudadTrabajo,iColoniaTrabajo, iCalleTrabajo, iCasaTrabajo, cDeptooInteriorTrabajo, cRumboTrabajo, 
	cComplementoTrabajo,iFlaguht, iUhtmanzana, iUhtotros, iUhtandador, iUhtetapa, iUhtlote, iUhtedificio, iUhtentrada, 
	cPuesto,dFechaantiguedadTrabajo, iClienteConyuge, cNombreConyuge, cApellidoPaternoConyuge, cApellidoMaternoConyuge, 
	cClaveConyugeFamilia, iLimiteCredito, iSecuencia, dFechaSolicitud,dFechaAltaCliente, iNumeroClienteBancoppel, 
	iFlagProductoCoppel, cTipoos, cTipoProducto, cNombre1, cNombre2, cApellidoPaterno1,cApellidoMaterno1, 
	cNombre1Conyuge, cNombre2Conyuge, cApellidoPaterno1Conyuge, cApellidoMaterno1Conyuge, cNombre1Referencia,
	cNombre2Referencia, cApellidoPaterno1Referencia, cApellidomaterno1Referencia,iCiudadCoppel, 
	iColoniaCoppel, cNombreZonaCoppel, iCiudadTrabajoCoppel, iColoniaTrabajoCoppel, 
	cNombreZonaTrabajoCoppel, cSituacionespecial, iCausasituacionespecial,
	cCurp, cClaveidentificacion, cIdentificacion, cTelefonocelular, cTiposueldo, cNombrereferencia, 
	cApellidopaternoreferencia, cApellidomaternoreferencia, dTelefonoreferencia, cTelefonocelularreferencia, cEmpresa, 
	dTelefono, dTelefonotrabajo, dTelefonotrabajoconyuge, dTelefonocelularconyuge,cObservacion3 WITH RESUME;
	END FOREACH;
END
END PROCEDURE

