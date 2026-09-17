CREATE PROCEDURE "informix".sp_consulta_datosgeneral(pEmpresa CHAR(3), pNumcte CHAR(20), pTipoIngreso CHAR(1), pTipoOper SMALLINT)

	RETURNING 
	CHAR	(5)		AS	CodigoRetorno,
	CHAR	(3)		AS	Empresa,
	CHAR	(20)	AS	NumCliente,
	CHAR	(1)		AS	TipoCliente,
	CHAR	(26)	AS	ApellidoPat,
	CHAR	(26)	AS	ApellidoMat,
	CHAR	(26)	AS	PrimerNombre,
	CHAR	(26)	AS	SegundoNombre,
	CHAR	(13)	AS	RFC,
	CHAR	(60)	AS	String2,
	Date			AS	FechaNacimiento,
	CHAR	(2)		AS	LugarNacimiento,
	CHAR	(3)		AS	Nacionalidad,
	CHAR	(18)	AS	FM3,
	CHAR	(2)		AS	EstadoCivil,
	CHAR	(1)		AS	Sexo,
	CHAR	(20)	AS	CURP,
	CHAR	(2)		AS	TipoIdentificacion,
	CHAR	(20)	AS	NumeroIdentificacion,
	CHAR	(2)		AS	Escolaridad,
	CHAR	(2)		AS	HabitaEn,
	INTEGER			AS	OpcionPuesto,
	INTEGER			AS	SubOpcionPuesto,
	SMALLINT		AS	Secuencia,
	CHAR	(10)	AS	TelefonoCasa,
	CHAR	(10)	AS	TelefonoCelular,
	CHAR	(30)	AS	CarrierCelular,
	CHAR	(10)	AS	TelefonoTrabajo,
	CHAR	(5)		AS	Extension,
	CHAR	(10)	AS	OtroTelefono,
	CHAR	(100)	AS	CorreoElectronico;

--##############################################################
--##	DefiniciÃ³n principal						          ##
--##############################################################
	DEFINE vcod_ret 		CHAR(5);
	DEFINE vempresa 		CHAR(3);
	DEFINE vnumcte  		CHAR(20);
	DEFINE vtipo_cliente	CHAR(1);
	DEFINE vapell_paterno 	CHAR(26);
	DEFINE vapell_materno 	CHAR(26);
	DEFINE vnombre1 		CHAR(26);
	DEFINE vnombre2 		CHAR(26);
	DEFINE vrfc 			CHAR(13);
	DEFINE vstring2 		CHAR(60);
	DEFINE vfecha_nacimiento    DATE;
	DEFINE vlugar_nacimiento CHAR(2);
	DEFINE vnacionalidad 	 CHAR(3);
	DEFINE vfm3 			CHAR(18);
	DEFINE vpfestado_civil	 CHAR(2);
	DEFINE vpfsexo 			 CHAR(1);
	DEFINE vpfcurp 			CHAR(20);
	DEFINE vpfcodidentifi CHAR(2);
	DEFINE vpfnumidentifi CHAR(20);
	DEFINE vpfescolaridad CHAR(2);
	DEFINE vpfhabita_en CHAR(2);
	DEFINE vopcionPuesto	 INTEGER;
	DEFINE vsubOpcionPuesto  INTEGER;
	DEFINE vsecuencia 		SMALLINT;
	DEFINE vTelefonoCasa     CHAR(10);
	DEFINE vTelefonoCelular  CHAR(10);
	DEFINE vCarrierCelular	 CHAR(30);
	DEFINE vTelefonoTrabajo  CHAR(10);
	DEFINE vExtension        CHAR(5);
	DEFINE vOtroTelefono	 CHAR(10);
	DEFINE vCorreo 			CHAR(100);

--##############################################################
--##	CONSNUMCTE_N     							          ##
--##############################################################
	DEFINE vcodret CHAR(5);
	DEFINE msgError CHAR(100);
    DEFINE vstatus_cte CHAR(2);
    DEFINE vsucursal CHAR(4);
    DEFINE vejecutivo CHAR(8);
    DEFINE vtpo_persona CHAR(2);
    DEFINE vrazon_social CHAR(60);
    DEFINE vsector CHAR(2);
    DEFINE vsegmento CHAR(3);
    DEFINE vactividad_princ CHAR(3);
    DEFINE vgrupo CHAR(3);
    DEFINE vsubgrupo CHAR(3);
    DEFINE vresidencia CHAR(1);
    DEFINE vfecha_alta DATE ;
    DEFINE vapell_casada CHAR(26);
    DEFINE vdistrito CHAR(2);
    DEFINE vnumcte_ref CHAR(20);
    DEFINE vstring1 CHAR(20);
    DEFINE vnumeric1 SMALLINT ;
    DEFINE vnumeric2 INTEGER ;
    DEFINE vmoney1 MONEY(14,2);
    DEFINE vdate1 DATE ;
    DEFINE vpuesto_ppes CHAR(1);
    DEFINE vfamiliar_ppes CHAR(1);
    DEFINE vactividad_esp CHAR(11);
    DEFINE vejecut_autoriza CHAR(8);
    DEFINE vuser_insert CHAR(8);
    DEFINE vfecha_insert DATE;
    DEFINE vrfc_alterno CHAR(13);
    -- si_ctepf
    DEFINE vpfempresa CHAR(3);
    DEFINE vpfnumcte CHAR(20);
    DEFINE vpfregim_matrimonio CHAR(1);
    DEFINE vpfprofesion CHAR(3);
    DEFINE vpfno_imss CHAR(12);
    DEFINE vpfdependientes SMALLINT ;
    DEFINE vpftutor CHAR(60);
    DEFINE vpfemail CHAR(60);
    DEFINE vpfpfnom_conyuge CHAR(60);
    DEFINE vpfseguro_defunc CHAR(1);
    DEFINE vpfanios_habita SMALLINT ;
    DEFINE vpfnombre_prop CHAR(60);
    DEFINE vpfimp_hipo_renta MONEY(16,2);
    DEFINE vpfactividadogiro CHAR(30);
    DEFINE vpfnumeroife CHAR(20);
    DEFINE vpfnumerotutor CHAR(20);
    DEFINE vpfnumeroconyuge CHAR(20);
    DEFINE vpfstring1 CHAR(20);
    DEFINE vpfstring2 CHAR(20);
    DEFINE vpfnumeric1 INTEGER ;
    DEFINE vpfnumeric2 INTEGER ;
    DEFINE vpfmoney1 MONEY(14,2);
    DEFINE vpfdate1 DATE;
    DEFINE vpfuser_insert CHAR(8);
    DEFINE vpffecha_insert DATE;

--##############################################################
--##	SP_CONSULTAINGRESOSCLIENTE					          ##
--##############################################################

	--DEFINE pTipoOper SMALLINT;
	DEFINE cCodRet CHAR(5);
	DEFINE sSecIng	SMALLINT; 
	DEFINE cTipIng CHAR(1);
	DEFINE cNomEmp CHAR(60); 
	DEFINE cPuesto CHAR (3); 
	DEFINE cPutEsp CHAR(2); 
	DEFINE dAntigd DECIMAL(4,2);
	DEFINE cNomDep CHAR(40); 
	DEFINE cJefInm CHAR(60); 
	DEFINE mIngMen MONEY(14,2);
	DEFINE cUsrInt CHAR(8); 
	DEFINE dFecInt DATE; 
	DEFINE iCvePst INTEGER; 
	DEFINE iCveOPt INTEGER; 
	DEFINE iCveSOP INTEGER; 
	DEFINE iSisCot INTEGER; 
	DEFINE iNumELa INTEGER; 
	DEFINE iPerios INTEGER; 
	DEFINE iTipIEx INTEGER;

--##############################################################
--##	SP_CONSULTA_TELEFONOS_REV					          ##
--##############################################################

	DEFINE vcodret1 CHAR(5);
	DEFINE vTipoTel1 SMALLINT;
	DEFINE vValCofetel1  CHAR(1);
	DEFINE vTipoTel2 SMALLINT;
	DEFINE vValCofetel2 CHAR(1);
	DEFINE vTipoTel3 SMALLINT;
	DEFINE vValCofetel3 CHAR(1);
	DEFINE vTipoTel4 SMALLINT;
	DEFINE vValCofetel4 CHAR(1);
	DEFINE vIndTelefono  CHAR(1);
	DEFINE vIndCorreo  CHAR(1);


--##############################################################
--##	InicializaciÃ³n principal						      ##
--##############################################################
	LET vcod_ret = "00000";
	LET vempresa = "";
	LET vnumcte  = "";
	LET vtipo_cliente = "";
	LET vapell_paterno = "";
	LET vapell_materno = "";
	LET vnombre1 = "";
	LET vnombre2 = "";
	LET vrfc = "";
	LET vstring2 = "";
	LET vfecha_nacimiento = DATE(1);
	LET vlugar_nacimiento  = "";
	LET vnacionalidad  = "";
	LET vfm3  = "";
	LET vpfestado_civil  = "";
	LET vpfsexo  = "";
	LET vpfcurp  = "";
	LET vpfcodidentifi  = "";
	LET vpfnumidentifi  = "";
	LET vpfescolaridad  = "";
	LET vpfhabita_en  = "";
	LET vopcionPuesto  = 0;
	LET vsubOpcionPuesto  = 0;
	LET vsecuencia  = 0;
	LET vTelefonoCasa  = "";
	LET vTelefonoCelular  = "";
	LET vCarrierCelular = "";
	LET vTelefonoTrabajo = "";
	LET vExtension  = "";
	LET vOtroTelefono = "";
	LET vCorreo = "";
	
--##############################################################
--##	InicializaciÃ³n CONSNUMCTE_N						      ##
--##############################################################
	LET vcodret = "00000";
	LET msgError = '';
     -- si_cliente
    LET vstatus_cte  = "";
    LET vsucursal = "";
    LET vejecutivo = "";
    LET vtpo_persona = "";
    LET vrazon_social = "";
    LET vsector = "";
    LET vsegmento = "";
    LET vactividad_princ = "";
    LET vgrupo = "";
    LET vsubgrupo = "";
    LET vresidencia = "";
    LET vfecha_alta = "";
    LET vapell_casada  = "";
    LET vdistrito = "";
    LET vnumcte_ref = "";
    LET vstring1 = "";
    LET vnumeric1  = 0;
    LET vnumeric2  = 0;
    LET vmoney1 = 0;
    LET vdate1  = "";
    LET vpuesto_ppes = "";
    LET vfamiliar_ppes = "";
    LET vactividad_esp = "";
    LET vejecut_autoriza  = "";
    LET vuser_insert = "";
    LET vfecha_insert = "";
    LET vrfc_alterno = "";
    -- si_ctepf
    LET vpfempresa  = "";
    LET vpfnumcte  = "";
    --LET vpffecha_nac  = "";
    --LET vpflugar_nac  = "";
    --LET vpfnacionalidad  = "";
    --LET vpfno_fm3  = "";
    LET vpfestado_civil = "";
    LET vpfregim_matrimonio = "";
    LET vpfprofesion  = "";
    LET vpfno_imss  = "";
    LET vpfdependientes = 0;
    LET vpftutor  = "";
    LET vpfemail  = "";
    LET vpfpfnom_conyuge  = "";
    LET vpfseguro_defunc = "";
    LET vpfescolaridad = "";
    LET vpfhabita_en = "";
    LET vpfanios_habita  = 0;
    LET vpfnombre_prop = "";
    LET vpfimp_hipo_renta  = 0;
    LET vpfactividadogiro = "";
    LET vpfnumeroife = "";
    LET vpfnumerotutor = "";
    LET vpfnumeroconyuge = "";
    LET vpfstring1 = "";
    LET vpfstring2 = "";
    LET vpfnumeric1 = 0;
    LET vpfnumeric2 = 0;
    LET vpfmoney1 = 0;
    LET vpfdate1 = "";
    LET vpfuser_insert = "";
    LET vpffecha_insert = "";
	
--##############################################################
--##	InicializaciÃ³n SP_CONSULTAINGRESOSCLIENTE			  ##
--##############################################################
	LET cCodRet = '00000';
	LET cTipIng = '';
	LET cNomEmp = '';
	LET cPuesto = '';
	LET cPutEsp = '';
	LET dAntigd = 0;
	LET cNomDep = '';
	LET cJefInm = '';
	LET mIngMen = 0;
	LET cUsrInt = '';
	LET dFecInt = DATE(1);
	LET iCvePst = 0;
	LET iSisCot = 0;
	LET iNumELa = 0;
	LET iPerios = 0;
	LET iTipIEx = 0;
	
--##############################################################
--##	InicializaciÃ³n SP_CONSULTA_TELEFONOS_REV			  ##
--##############################################################
	LET vcodret1 = '000';   
    LET vTipoTel1        = 0;
    LET vValCofetel1     = '';
    LET vTipoTel2        = 0;
    LET vValCofetel2     = '';
    LET vTipoTel3        = 0;
    LET vValCofetel3     = '';
    LET vTipoTel4        = 0;
    LET vValCofetel4     = '';
    LET vCorreo          = '';
    LET vIndTelefono     = '';
    LET vIndCorreo       = '';

	BEGIN


	--SET DEBUG FILE TO '/informix/sp_consulta_datosgeneral.out';
		--TRACE ON;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

	-- INICIO DEL PROCEDIMIENTO
	
	Call bdinteg:"informix".consnumcte_n(pempresa,pnumcte)
	RETURNING  vcodret,vempresa, vnumcte, vstatus_cte, vsucursal, vejecutivo, vtpo_persona, vtipo_cliente, vapell_paterno, vapell_materno, vnombre1, vnombre2,
			   vrazon_social, vrfc, vsector, vsegmento, vactividad_princ, vgrupo, vsubgrupo, vresidencia, vfecha_alta, vapell_casada, vdistrito, vnumcte_ref,
			   vstring1, vstring2, vnumeric1, vnumeric2, vmoney1, vdate1, vpuesto_ppes, vfamiliar_ppes, vactividad_esp, vejecut_autoriza, vuser_insert, 
			   vfecha_insert, vrfc_alterno,
			   vpfempresa, vpfnumcte, vfecha_nacimiento, vlugar_nacimiento, vnacionalidad, vfm3, vpfestado_civil, vpfregim_matrimonio,
			   vpfprofesion, vpfsexo, vpfcurp, vpfcodidentifi, vpfnumidentifi, vpfno_imss, vpfdependientes, vpftutor, vpfemail, vpfpfnom_conyuge, vpfseguro_defunc,
			   vpfescolaridad,vpfhabita_en, vpfanios_habita, vpfnombre_prop, vpfimp_hipo_renta, vpfactividadogiro, vpfnumeroife, vpfnumerotutor, vpfnumeroconyuge, 
			   vpfstring1, vpfstring2, vpfnumeric1, vpfnumeric2, vpfmoney1, vpfdate1, vpfuser_insert, vpffecha_insert;
	IF vcodret <> 0 THEN
		LET msgError = "Error en la ejecuciÃ³n del consnumcte_n";
		/* 	RETURN vcodret,vempresa,vnumcte,vtipo_cliente,vapell_paterno,vapell_materno,vnombre1,vnombre2,vrfc,vstring2,vfecha_nacimiento,
			vlugar_nacimiento,vnacionalidad,vfm3, vpfestado_civil,vpfsexo, vpfcurp,vpfcodidentifi,vpfnumidentifi,vpfescolaridad,vpfhabita_en,vopcionPuesto,
			vsubOpcionPuesto,vsecuencia, vTelefonoCasa, vTelefonoCelular, vCarrierCelular, vTelefonoTrabajo, vExtension, vOtroTelefono, vCorreo; */
			
			RETURN vcodret,'','','','','','','','','',0,
		'','','', '','', '','','','','',0,
		0,0, '', '', '', '', '', '', '';
		  END IF
	/*
	*/	
	--Let pTipoOper = 1;
	Call bdinteg:"informix".sp_ConsultaIngresosCliente(pTipoOper, pNumCte, pTipoIngreso)	   
	RETURNING cCodRet, vempresa, vnumcte, vsecuencia, cTipIng, cNomEmp, cPuesto, cPutEsp, dAntigd, cNomDep, cJefInm, mIngMen, cUsrInt, dFecInt, 
			  iCvePst, vopcionPuesto, vsubOpcionPuesto, iSisCot, iNumELa, iPerios, iTipIEx;  
	IF cCodRet <> 0 THEN
	LET msgError = "Error en la ejecuciÃ³n del sp_ConsultaIngresosCliente";
		/* RETURN cCodRet,vempresa,vnumcte,vtipo_cliente,vapell_paterno,vapell_materno,vnombre1,vnombre2,vrfc,vstring2,vfecha_nacimiento,
		vlugar_nacimiento,vnacionalidad,vfm3, vpfestado_civil,vpfsexo, vpfcurp,vpfcodidentifi,vpfnumidentifi,vpfescolaridad,vpfhabita_en,vopcionPuesto,
		vsubOpcionPuesto,vsecuencia, vTelefonoCasa, vTelefonoCelular, vCarrierCelular, vTelefonoTrabajo, vExtension, vOtroTelefono, vCorreo; */
			RETURN cCodRet,'','','','','','','','','',0,
		'','','', '','', '','','','','',0,
		0,0, '', '', '', '', '', '', '';

	END IF
	/*
	*/		  
	Call bdinteg:"informix".sp_consulta_telefonos_rev(pNumCte) 
	RETURNING vcodret1, vTelefonoCasa, vTipoTel1, vValCofetel1, vTelefonoCelular, vTipoTel2, vValCofetel2, vTelefonoTrabajo, vTipoTel3, vExtension, vValCofetel3, 
			  vOtroTelefono, vTipoTel4, vValCofetel4, vCorreo, vCarrierCelular, vIndTelefono, vIndCorreo;
	IF vcodret1 <> 0 THEN
	LET msgError = "Error en la ejecuciÃ³n del sp_consulta_telefonos_rev";
		/* RETURN vcodret1,vempresa,vnumcte,vtipo_cliente,vapell_paterno,vapell_materno,vnombre1,vnombre2,vrfc,vstring2,vfecha_nacimiento,
		vlugar_nacimiento,vnacionalidad,vfm3, vpfestado_civil,vpfsexo, vpfcurp,vpfcodidentifi,vpfnumidentifi,vpfescolaridad,vpfhabita_en,vopcionPuesto,
		vsubOpcionPuesto,vsecuencia, vTelefonoCasa, vTelefonoCelular, vCarrierCelular, vTelefonoTrabajo, vExtension, vOtroTelefono, vCorreo; */
			RETURN vcodret1,'','','','','','','','','',0,
		'','','', '','', '','','','','',0,
		0,0, '', '', '', '', '', '', '';
	END IF
	/*
	*/			
	RETURN vcod_ret,vempresa,vnumcte,vtipo_cliente,vapell_paterno,vapell_materno,vnombre1,vnombre2,vrfc,vstring2,vfecha_nacimiento,
	vlugar_nacimiento,vnacionalidad,vfm3, vpfestado_civil,vpfsexo, vpfcurp,vpfcodidentifi,vpfnumidentifi,vpfescolaridad,vpfhabita_en,vopcionPuesto,
	vsubOpcionPuesto,vsecuencia, vTelefonoCasa, vTelefonoCelular, vCarrierCelular, vTelefonoTrabajo, vExtension, vOtroTelefono, vCorreo;

	END
END PROCEDURE
DOCUMENT
"DESCRIPCION: ",
"REALIZÃ: Jorge Lara",
"FECHA: 01/Febrero/2017",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_generainfo_ctes_cap_2() 
RETURNING CHAR(9);
--DEFINICION DE VARIABLES
DEFINE vc_CodRet        CHAR(5);
DEFINE vi_SqlErr        INT;
DEFINE cNumcte          CHAR(20);
DEFINE cNumcte2          CHAR(20);
DEFINE cProducto        CHAR(4);
DEFINE cPaterno         CHAR(26);
DEFINE cMaterno         CHAR(26);
DEFINE cNombre1         CHAR(26);
DEFINE cNombre2         CHAR(26);
DEFINE cProductoB        CHAR(4);
DEFINE cPaternoB         CHAR(26);
DEFINE cMaternoB         CHAR(26);
DEFINE cNombre1B         CHAR(26);
DEFINE cNombre2B         CHAR(26);
DEFINE cRazon           CHAR(60);
DEFINE cTipopersona     CHAR(6);
DEFINE cEstatusCli     CHAR(8);
DEFINE cParticipacion     CHAR(9);
DEFINE cTipocontrato        CHAR(100);
DEFINE dFecharelaccomer DATE;
DEFINE dFechaApertura DATE;
DEFINE dFechacancela DATE;
DEFINE cGradoRiesgo CHAR(11);
DEFINE dFechagradoriesgo DATE;
DEFINE cNacionalidad CHAR(3);
DEFINE cPais CHAR(3);
DEFINE cProfesion CHAR(3);
------------------------
DEFINE cRazonB           CHAR(60);
DEFINE cTipopersonaB     CHAR(6);
DEFINE cEstatusCliB     CHAR(8);
DEFINE cParticipacionB     CHAR(9);
DEFINE cTipocontratoB        CHAR(100);
DEFINE dFecharelaccomerB DATE;
DEFINE dFechaAperturaB DATE;
DEFINE dFechacancelaB DATE;
DEFINE cGradoRiesgoB CHAR(11);
DEFINE dFechagradoriesgoB DATE;
DEFINE cNacionalidadB CHAR(3);
DEFINE cPaisB CHAR(3);
DEFINE cProfesionB CHAR(3);
------------------------
DEFINE iNoRegs		INTEGER;
DEFINE iNoRegs2		INTEGER;
DEFINE iNoRegs3		INTEGER;
DEFINE iNoRegs4		INTEGER;
DEFINE cCuenta		CHAR(20);
DEFINE cCuenta2		CHAR(20);
DEFINE cCuentaB		CHAR(20);
DEFINE cClientefirmante		CHAR(20);
-----
DEFINE iNumerocalle    	INTEGER;
DEFINE    cNumeroextcalle 	CHAR(10);
DEFINE    cNumerointcalle 	CHAR(10);
DEFINE    iNumerocolonia  	INTEGER;
DEFINE    cCod_postal     	CHAR(5);
DEFINE    iNumerociudad   	SMALLINT;
DEFINE    cCiudad         	CHAR(3);
DEFINE    cEstado         	CHAR(2);
DEFINE    cTelefono1         	CHAR(13);
DEFINE    cTelefono2         	CHAR(13);
DEFINE    cTelefono3         	CHAR(13);
DEFINE    cTelefono4         	CHAR(13);
DEFINE	  stipo_tel			SMALLINT;
-------------------------------------------------
DEFINE iNumerocalleB    	INTEGER;
DEFINE    cNumeroextcalleB 	CHAR(10);
DEFINE    cNumerointcalleB 	CHAR(10);
DEFINE    iNumerocoloniaB  	INTEGER;
DEFINE    cCod_postalB     	CHAR(5);
DEFINE    iNumerociudadB   	SMALLINT;
DEFINE    cCiudadB         	CHAR(3);
DEFINE    cEstadoB         	CHAR(2);
DEFINE    cTelefono1B         	CHAR(13);
DEFINE    cTelefono2B         	CHAR(13);
DEFINE    cTelefono3B         	CHAR(13);
DEFINE    cTelefono4B         	CHAR(13);
DEFINE	  stipo_telB			SMALLINT;

-------------------------------------------------
DEFINE cEmail					CHAR(100);
DEFINE cCurp					CHAR(20);
DEFINE dFecha_nac			DATE;
DEFINE cRFC					CHAR(13);

DEFINE cEmailB					CHAR(100);
DEFINE cCurpB					CHAR(20);
DEFINE dFecha_nacB			DATE;
DEFINE cRFCB					CHAR(13);
DEFINE cSucursal					CHAR(4);
DEFINE cEjecutivo					CHAR(8);
DEFINE cNombreejecutivo			CHAR(45);
DEFINE cApoderado			CHAR(104);
DEFINE cNumapoderado			CHAR(20);
--------------------------------------------
DEFINE cSucursalB					CHAR(4);
DEFINE cEjecutivoB					CHAR(8);
DEFINE cNombreejecutivoB			CHAR(45);
DEFINE cApoderadoB			CHAR(104);
DEFINE cNumapoderadoB			CHAR(20);

DEFINE iContador            INTEGER;
DEFINE sCommit              SMALLINT;
DEFINE sParamCta            CHAR(20);
DEFINE cCuentaCancel        CHAR(20);
DEFINE iNoRegs5             INTEGER;
DEFINE cStatus              CHAR(1);
DEFINE cFechaC				DATE;
-------------------------------------------

--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET cNumcte='';
LET cNumcte2='';
LET cProducto='';
LET cPaterno='';
LET cMaterno='';
LET cNombre1='';
LET cNombre2='';
LET cRazon='';
LET cTipopersona='';
LET cEstatusCli='ACTIVO';
LET cParticipacion='';
LET cTipocontrato='CONTRATO MULTIPLE DE PRODUCTOS Y SERVICIOS BANCARIOS DE CAPTACION PARA PERSONAS FISICAS';
LET dFecharelaccomer='';
LET dFechacancela='';
LET cGradoRiesgo='BAJO RIESGO';
LET dFechagradoriesgo='';
LET cNacionalidad='';
LET cPais='';
LET cProfesion='';
LET iNoRegs=0;
LET iNoRegs2=0;
LET iNoRegs3=0;
LET iNoRegs4=0;
LET cCuenta='';
LET cCuenta2='';
LET cCuentaB='';
----
LET iNumerocalle    	=0;
LET    cNumeroextcalle 	='';
LET    cNumerointcalle 	='';
LET    iNumerocolonia  	=0;
LET    cCod_postal     	='';
LET    iNumerociudad   	=0;
LET    cCiudad         	='';
LET    cEstado         	='';

-------
LET    cTelefono1      ='';
LET    cTelefono2      ='';
LET    cTelefono3      ='';
LET    cTelefono4      ='';
LET stipo_tel=0;
LET cEmail='';
LET cCurp				='';
LET dFecha_nac			='';
LET cRFC='';
LET cSucursal					='';
LET cEjecutivo					='';
LET cNombreejecutivo ='';
LET cApoderado='';
LET cNumapoderado='';
LET cClientefirmante='';


---------------------------------------------
LET cProductoB='';
LET cPaternoB='';
LET cMaternoB='';
LET cNombre1B='';
LET cNombre2B='';
LET cRazonB='';
LET cTipopersonaB='';
LET cEstatusCliB='ACTIVO';
LET cParticipacionB='';
LET cTipocontratoB='CONTRATO MULTIPLE DE PRODUCTOS Y SERVICIOS BANCARIOS DE CAPTACION PARA PERSONAS FISICAS';
LET dFecharelaccomerB='';
LET dFechacancelaB='';
LET cGradoRiesgoB='BAJO RIESGO';
LET dFechagradoriesgoB='';
LET cNacionalidadB='';
LET cPaisB='';
LET cProfesionB='';
----
LET iNumerocalleB    	=0;
LET    cNumeroextcalleB 	='';
LET    cNumerointcalleB 	='';
LET    iNumerocoloniaB  	=0;
LET    cCod_postalB     	='';
LET    iNumerociudadB   	=0;
LET    cCiudadB         	='';
LET    cEstadoB         	='';

-------
LET    cTelefono1B      ='';
LET    cTelefono2B      ='';
LET    cTelefono3B      ='';
LET    cTelefono4B      ='';
LET stipo_telB=0;
LET cEmailB='';
LET cCurpB				='';
LET dFecha_nacB			='';
LET cRFCB='';
LET cSucursalB					='';
LET cEjecutivoB					='';
LET cNombreejecutivoB ='';
LET cApoderadoB='';
LET cNumapoderadoB='';
LET dFechaApertura='';
LET dFechaAperturaB='';

LET iContador = 0;
LET sCommit = 0;
LET sParamCta = '';
LET cCuentaCancel ='';
LET iNoRegs5 =0;
LET cStatus ='';
LET cFechaC ='';
--------------------------------------------
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    BEGIN

    ON EXCEPTION SET vi_SqlErr 
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
			UPDATE bdinteg:si_param SET valor = cCuenta WHERE cod_param = 450;
            RETURN vc_CodRet;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/informix/OMC/sp_generainfo_ctes_cap_2.out";
    --TRACE ON;
	
	SELECT valor-1 INTO sParamCta FROM bdinteg:si_param WHERE cod_param = 450;

    SET ISOLATION TO DIRTY READ;
    FOREACH WITH HOLD
		SELECT a.num_cte, a.cuenta, a.producto,b.fecha_alta,a.sucursal,b.ejecutivo, a.status_cta, a.fec_cancelac
		INTO cNumcte, cCuenta, cProducto, dFechaApertura,cSucursal,cEjecutivo,cStatus,cFechaC
		FROM bdicheq:sc_maechq a INNER JOIN bdicheq:sc_maenoc b
		ON a.cuenta = b.cuenta 
		WHERE b.fecha_alta <= '03/31/2017'
		and a.cuenta > sParamCta
		order by a.cuenta
		
		SELECT {+index (si_paso_ctas_cnbv idx_si_paso_ctas_cnbv)} LIMIT 1 cuenta INTO cCuentaCancel FROM si_paso_ctas_cnbv WHERE cuenta=cCuenta;
		LET iNoRegs5 = DBINFO('sqlca.sqlerrd2');

		IF iNoRegs5>0 THEN
			CONTINUE FOREACH;
		END IF;
		IF(cStatus=2 AND cFechaC <'03/31/2016') THEN
			CONTINUE FOREACH;
		END IF;
		
		SELECT apell_paterno,apell_materno,nombre1,nombre2,razon_social,DECODE(tpo_persona,"01","FISICA","02","MORAL"),rfc
        INTO cPaterno,cMaterno,cNombre1,cNombre2,cRazon,cTipopersona,cRFC FROM si_cliente 
		WHERE numcte =cNumcte;

		SELECT nacionalidad,id_pais,profesion,curp,fecha_nac
        INTO cNacionalidad,cPais,cProfesion,cCurp,dFecha_nac FROM si_ctepf 
		WHERE numcte =cNumcte;

		LET cEmail='';
		LET cTipocontrato='CONTRATO MULTIPLE DE PRODUCTOS Y SERVICIOS BANCARIOS DE CAPTACION PARA PERSONAS FISICAS';
		IF cTipopersona='MORAL' THEN
			SELECT fecha_constitct,giro,emailpm,nacionalidad INTO dFecha_nac,cProfesion,cEmail,cNacionalidad FROM si_ctepm WHERE numcte=cNumcte;
			
			SELECT FIRST 1 numcteapoderado INTO cNumapoderado FROM si_apoderado WHERE numcte=cNumcte;

			SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno) INTO cApoderado FROM si_cliente WHERE numcte=cNumapoderado;
			LET cTipocontrato='CONTRATO UNICO DE PRODUCTOS Y SERVICIOS BANCARIOS PARA EMPRESAS';
		END IF;
				

			SELECT count(*) INTO iNoRegs3 FROM bdicheq:sc_maechq a,bdicheq:sc_maenoc b
			WHERE a.cuenta=b.cuenta and a.num_cte=cNumcte;

			--PARTICIPACION CONTRATO
			LET cParticipacion='TITULAR';
			----TIPO CONTRATO

			-----------------------
			--FECHA DE INCIIO DE RELACION COMERCIAL,CONTRATO Y GRADO DE RIESGO
			SELECT MIN(B.fecha_alta) INTO dFecharelaccomer FROM bdicheq:sc_maechq a,bdicheq:sc_maenoc b
			WHERE a.cuenta=b.cuenta and a.num_cte=cNumcte;


	------FECHA DE TERMINO DE RELACION
			IF iNoRegs3=1 THEN
				LET dFechacancela='';
				SELECT FIRST 1 fec_cancelac INTO dFechacancela FROM bdicheq:sc_maechq WHERE cuenta=cCuenta and status_cta=2;

				LET iNoRegs = DBINFO('sqlca.sqlerrd2');
				IF	iNoRegs>0 THEN	
					LET cEstatusCli='INACTIVO';
				ELSE
					LET cEstatusCli='ACTIVO';
				END IF;
			END IF;	
			SELECT FIRST 1 numerocalle,numeroextcalle,numerointcalle,numerocolonia,cod_postal,numerociudad,ciudad,estado 
			INTO iNumerocalle,cNumeroextcalle,cNumerointcalle,iNumerocolonia,cCod_postal,iNumerociudad,cCiudad,cEstado  
			FROM si_direcciones_actual WHERE numcte=cNumcte AND tipo_dir=1;

			SELECT FIRST 1 telefono,tipo_tel INTO cTelefono1,stipo_tel FROM si_telefonos_actual WHERE numcte=cNumcte AND status_tel='A' AND tipo_tel=1;
			SELECT FIRST 1 telefono,tipo_tel INTO cTelefono2,stipo_tel FROM si_telefonos_actual WHERE numcte=cNumcte AND status_tel='A' AND tipo_tel=2;
			SELECT FIRST 1 telefono,tipo_tel INTO cTelefono3,stipo_tel FROM si_telefonos_actual WHERE numcte=cNumcte AND status_tel='A' AND tipo_tel=3;

			IF cEmail='' THEN
				SELECT FIRST 1 correo_elec INTO cEmail FROM si_correos WHERE numcte=cNumcte AND tipo_correo=1 AND status_correo='A';
			END IF;
			SELECT FIRST 1 nombre INTO cNombreejecutivo FROM si_ejecut WHERE ejecutivo=cEjecutivo;
			
			IF (sCommit = 0) THEN
					BEGIN WORK;
					LET iContador = 0;
					LET sCommit = -1;
			END IF;

			INSERT INTO si_infoctescnbv(numcte,cuenta,producto,apell_paterno,apell_materno,nombre1,nombre2,razon_social,tipo_persona,status_cliente,participacion,tipo_contrato,fec_inicio_relac,
			fec_aper_contrato,fec_termino_rel,grado_riesgo,fec_grado_riesgo,nacionalidad,pais,actividad,numerocalle,numeroextcalle,numerointcalle,numerocolonia,cod_postal,numerociudad,ciudad,estado,
			telefono1,telefono2,telefono3,email,curp,fecha_nac,rfc,sucursal,ejecutivo,nombre_ejecutivo,apoderado_legal) 
			VALUES (cNumcte,cCuenta,cProducto,cPaterno,cMaterno,cNombre1,cNombre2,cRazon,cTipopersona,cEstatusCli,cParticipacion,cTipocontrato,dFecharelaccomer,
			dFechaApertura,dFechacancela,cGradoRiesgo,dFechaApertura,cNacionalidad,cPais,cProfesion,iNumerocalle,cNumeroextcalle,cNumerointcalle,iNumerocolonia,cCod_postal,iNumerociudad,cCiudad,cEstado,
			cTelefono1,cTelefono2,cTelefono3,cEmail,cCurp,dFecha_nac,cRFC,cSucursal,cEjecutivo,cNombreejecutivo,cApoderado);
			
			LET iContador = iContador  + 1;	

			--Ejecutar un commit cada 1000 registros.
			IF (iContador >= 5000) THEN
					COMMIT WORK;	
					LET iContador = 0;
					UPDATE bdinteg:si_param SET valor = cCuenta WHERE cod_param = 450;
					BEGIN WORK;
			END IF;	
-----------------------------------------------------------------------------------

			SET ISOLATION TO DIRTY READ;
			FOREACH WITH HOLD
			
				SELECT numcte INTO cClientefirmante FROM bdicheq:sc_firmantes WHERE empresa='001' and cuenta=cCuenta AND secuencia>1

				LET iNoRegs2 = DBINFO('sqlca.sqlerrd2');

				IF iNoRegs2>0 THEN
				   FOREACH c1 FOR
						SELECT numcte,apell_paterno,apell_materno,nombre1,nombre2,razon_social,DECODE(tpo_persona,"01","FISICA","02","MORAL"),rfc
						INTO cNumcte2,cPaternoB,cMaternoB,cNombre1B,cNombre2B,cRazonB,cTipopersonaB,cRFCB FROM si_cliente 
						WHERE numcte=cClientefirmante

						SELECT nacionalidad,id_pais,profesion,curp,fecha_nac
						INTO cNacionalidadB,cPaisB,cProfesionB,cCurpB,dFecha_nacB FROM si_ctepf 
						WHERE numcte =cClientefirmante;

						LET cEmailB='';
						LET cTipocontrato='CONTRATO MULTIPLE DE PRODUCTOS Y SERVICIOS BANCARIOS DE CAPTACION PARA PERSONAS FISICAS';										

							SELECT count(*) INTO iNoRegs3 FROM bdicheq:sc_maechq a,bdicheq:sc_maenoc b
							WHERE a.cuenta=b.cuenta and a.num_cte=cNumcte;

							--PARTICIPACION CONTRATO
							LET cParticipacionB='COTITULAR';
							----TIPO CONTRATO

							
							SELECT FIRST 1 numerocalle,numeroextcalle,numerointcalle,numerocolonia,cod_postal,numerociudad,ciudad,estado 
							INTO iNumerocalleB,cNumeroextcalleB,cNumerointcalleB,iNumerocoloniaB,cCod_postalB,iNumerociudadB,cCiudadB,cEstadoB  
							FROM si_direcciones_actual WHERE numcte=cNumcte2 AND tipo_dir=1;

							SELECT FIRST 1 telefono,tipo_tel INTO cTelefono1B,stipo_telB FROM si_telefonos_actual WHERE numcte=cNumcte2 AND status_tel='A' AND tipo_tel=1;
							SELECT FIRST 1 telefono,tipo_tel INTO cTelefono2B,stipo_telB FROM si_telefonos_actual WHERE numcte=cNumcte2 AND status_tel='A' AND tipo_tel=2;
							SELECT FIRST 1 telefono,tipo_tel INTO cTelefono3B,stipo_telB FROM si_telefonos_actual WHERE numcte=cNumcte2 AND status_tel='A' AND tipo_tel=3;

							--IF cEmailB='' THEN

								SELECT FIRST 1 correo_elec INTO cEmailB FROM si_correos WHERE numcte=cNumcte2 AND tipo_correo=1 AND status_correo='A';
							--END IF;
							SELECT FIRST 1 nombre INTO cNombreejecutivoB FROM si_ejecut WHERE ejecutivo=cEjecutivo;
							
							IF (sCommit = 0) THEN
								BEGIN WORK;
								LET iContador = 0;
								LET sCommit = -1;
							END IF;

							INSERT INTO si_infoctescnbv(numcte,cuenta,producto,apell_paterno,apell_materno,nombre1,nombre2,razon_social,tipo_persona,status_cliente,participacion,tipo_contrato,fec_inicio_relac,
							fec_aper_contrato,fec_termino_rel,grado_riesgo,fec_grado_riesgo,nacionalidad,pais,actividad,numerocalle,numeroextcalle,numerointcalle,numerocolonia,cod_postal,numerociudad,ciudad,estado,
							telefono1,telefono2,telefono3,email,curp,fecha_nac,rfc,sucursal,ejecutivo,nombre_ejecutivo,apoderado_legal) 
							VALUES (cNumcte2,cCuenta,cProducto,cPaternoB,cMaternoB,cNombre1B,cNombre2B,cRazonB,cTipopersonaB,cEstatusCli,cParticipacionB,cTipocontrato,dFecharelaccomer,
							dFechaApertura,dFechacancela,cGradoRiesgo,dFechaApertura,cNacionalidadB,cPaisB,cProfesionB,iNumerocalleB,cNumeroextcalleB,cNumerointcalleB,iNumerocoloniaB,cCod_postalB,iNumerociudadB,cCiudadB,cEstadoB,
							cTelefono1B,cTelefono2B,cTelefono3B,cEmailB,cCurpB,dFecha_nacB,cRFCB,cSucursal,cEjecutivo,cNombreejecutivoB,cApoderado);
							
							LET iContador = iContador  + 1;		
				
							--Ejecutar un commit cada 1000 registros.
							IF (iContador >= 5000) THEN
								COMMIT WORK;	
								LET iContador = 0;
								UPDATE bdinteg:si_param SET valor = cCuentaB WHERE cod_param = 450;
								BEGIN WORK;
							END IF;										
					END FOREACH;
					
					IF sCommit = -1 THEN
							COMMIT WORK;
							UPDATE bdinteg:si_param SET valor = cCuenta WHERE cod_param = 450;							
						END IF;
					LET sCommit = 0;
						
				END IF;
			END FOREACH;
-----------------------------------------------------------------------------------

    END FOREACH;
	
	IF sCommit = -1 THEN
	COMMIT WORK;
	UPDATE bdinteg:si_param SET valor = cCuenta WHERE cod_param = 450;
	END IF;
	LET sCommit = 0;

    RETURN vc_CodRet;

END;
END PROCEDURE;