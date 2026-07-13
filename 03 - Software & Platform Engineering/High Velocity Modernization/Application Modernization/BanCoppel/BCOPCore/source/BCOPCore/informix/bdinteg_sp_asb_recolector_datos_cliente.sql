create procedure "informix".sp_asb_recolector_datos_cliente(pnumcte CHAR(9),
								pcampo1 CHAR(1000), 
								pcampo2 CHAR(1000), 
								pcampo3 CHAR(1000)
								)
returning
    --manejo de errores
    CHAR(5) AS codRet, CHAR(100) AS codRetSec,

    --datos personales
	CHAR(3) AS empresa, CHAR(20) AS numeroClienteCte, CHAR(2) AS statusCte , CHAR(4) AS sucursal, CHAR(8) AS ejecutivo, CHAR(2) AS tpoPersona , CHAR(1)  AS tipoCliente, 
	CHAR(26)  AS apellPaterno, CHAR(26)  AS apellMaterno, CHAR(26)  AS nombre1, CHAR(26)  AS nombre2, CHAR(26) AS razonSocial, CHAR(13)  AS rfc, CHAR(2)  AS sector, 
	CHAR(3)  AS segmento, CHAR(3)  AS actividadPrinc, CHAR(3)  AS grupo, CHAR(3)  AS subgrupo, CHAR(1)  AS residencia, DATE  AS fechaAlta, CHAR(26)  AS apellCasada,
	CHAR(2) AS distrito , CHAR(20)  AS numcteRef, CHAR(20)  AS string1, CHAR(60)  AS string2, SMALLINT  AS numeric1, INTEGER  AS numeric2, MONEY  AS money1 , DATE  AS date1, 
	CHAR(1)  AS puestoPpes, CHAR(1)  AS familiarPpes, CHAR(11)  AS actividadEsp , CHAR(8)  AS ejecutAutoriza, CHAR(8)  AS userInsert, DATE  AS fechaInsert, CHAR(13)  AS rfcAlterno, 
	CHAR(1)  AS tpoBiometria, CHAR(1)  AS clientePros, smallint AS envioMovtos,

    --cliente PF
	CHAR(3)  AS empresaCtePf, CHAR(20)  AS numeroClienteCtePf, DATE  AS fechaNacimientoCtPf, CHAR(2)  AS lugarNacimientoCtePf, CHAR(3)  AS nacionalidadCtePf, CHAR(18)  AS noFm3CtePf, CHAR(2)  AS estadoCivilCtePf, 
	CHAR(1)  AS regimMatrimonioCtePf, CHAR(3)  AS profesionCtePf, CHAR(1)  AS sexoCtePf, CHAR(20)  AS curpCtePf, CHAR(2)  AS codigoDentifiCtePf, CHAR(30)  AS numeroIdentifiCtePf, CHAR(12)  AS noImssCtePf, 
	SMALLINT  AS dependientesCtePf, CHAR(60)  AS tutorCtePf, CHAR(60)  AS nomConyugeCtePf, CHAR(1)  AS seguroDefuncionCtePf, CHAR(2)  AS escolaridadCtePf, CHAR(2)  AS habitaEnCtePf, SMALLINT  AS aniosHabitaCtePf, 
	CHAR(60)  AS nombrePropietarioCtePf, MONEY AS impHipotecaRentaCtePf, CHAR(30)  AS actividadOGiroCtePf,	CHAR(20)  AS numeroIfeCtePf, CHAR(20)  AS numeroTutorCtePf, CHAR(20)  AS numeroConyugeCtePf, CHAR(20)  AS string1CtePf, 
	CHAR(20)  AS string2CtePf, INTEGER  AS numeric1CtePf, INTEGER  AS numeric2CtePf, MONEY AS money1CtePf, DATE  AS date1CtePf, CHAR(8)  AS usuarioInsertoCtePf, DATE  AS fechaInsertoCtePf, CHAR(1)  AS smsCelCtePf, 
	DATETIME YEAR to FRACTION(3)  AS horaInsertoCtePf, CHAR(1)  AS validaCurpCtePf, CHAR(3) AS idPaisCtePf,
	
    --Direcciones
    CHAR(20)  AS numeroClienteDirecciones, INTEGER  AS secuenciaDirecciones, CHAR(1)  AS tipoDirecionDirecciones, CHAR(40)  AS calleDirecciones, CHAR(60)  AS coloniaDirecciones, CHAR(40)  AS entreCallesDirecciones, 
    CHAR(3)  AS paisDirecciones, CHAR(2)  AS estadoDirecciones, CHAR(3)  AS ciudadDirecciones, CHAR(5)  AS municipioDirecciones, CHAR(5)  AS codigoPostalDirecciones, CHAR(11)  AS apartadoPostalDirecciones, 
    CHAR(2)  AS estadoInegiDirecciones , CHAR(3)  AS municipioInegiDirecciones, CHAR(4)  AS localidadInegiDirecciones, SMALLINT  AS numeroCiudadDirecciones, CHAR(10)  AS numeroExteriorCalleDirecciones, 
    CHAR(10)  AS numeroInteriorCalleDirecciones, CHAR(6) AS departamentoDirecciones, INTEGER  AS numeroCalleDirecciones, INTEGER  AS numeroColoniaDirecciones, CHAR(1)  AS puntoCardinalDirecciones, 
    CHAR(1)  AS unidadHabitacionalDirecciones, SMALLINT  AS manzanaDirecciones, SMALLINT  AS otrosDirecciones, SMALLINT  AS andadorDirecciones, SMALLINT  AS etapaDirecciones, SMALLINT  AS loteDirecciones, 
    SMALLINT  AS edificioDirecciones, SMALLINT  AS entradaDirecciones, CHAR(80)  AS observacionesDirecciones, CHAR(8)  AS usuarioInsertoDirecciones, DATE AS fechaInsertoDirecciones, CHAR(1)  AS indCofeteltel1Direcciones, 
    CHAR(1)  AS indCofeteltel2Direcciones, CHAR(1) AS indCofeteltel3Direcciones,

    --correos
    CHAR(3)  AS empresaCorreo, CHAR(20)  AS numeroClienteCorreo, CHAR(100)  AS correoElectronicoCorreo, smallint  AS tipoCorreo, CHAR(1)  AS statusCorreo , smallint  AS secuenciaCorreo,
    smallint  AS canalCorreo, CHAR(23)  AS fechaHoraCorreo, CHAR(8)  AS userInsertCorreo, CHAR(3)  AS validaCorreo , CHAR(1)  AS validoCorreo,datetime year to second AS fechaValidaCorreo
    ,

    --telefonos_actual
    CHAR(3)  AS empresaTelefonos, CHAR(20)  AS numeroClienteTelefonos, CHAR(27)  AS telefonoTelefonos, SMALLINT  AS tipoTelefonoTelefonos, CHAR(1)  AS statusTelefonoTelefonos, SMALLINT  AS secuenciaTelefonos,
    CHAR(5)  AS extensionTelefonos, SMALLINT  AS carrierTelefonos, SMALLINT  AS canalTelefonos, SMALLINT  AS contactoTelefonos, CHAR(1)  AS cofetelTelefonos, DATETIME YEAR to SECOND  AS fechaHoraTelefonos,
    CHAR(8)  AS usuarioInsertoTelefonos, CHAR(1)  AS movilFijoTelefonos, CHAR(1)  AS statusStelTelefonos, CHAR(1)  AS telelefonoConfirmadoTelefonos, DATETIME YEAR to second AS fechaConfirmadoTelefonos,
   
    --Huellas
    char(20) AS numeroCteHuella, smallint AS secuenciaHuella, char(1) AS estatusHuella, smallint AS idTemplateHuella, char(942) AS template1, smallint AS nfiq1, smallint AS minucias1, char(942) AS template2, 
    smallint AS nfiq2, smallint AS minucias2, char(942) AS template3, smallint AS nfiq3, smallint AS minucias3, char(942) AS template4, smallint AS nfiq4, smallint AS minucias4, char(942) AS template5,
    smallint AS nfiq5, smallint AS minucias5, char(942) AS template6, smallint AS nfiq6, smallint AS minucias6, char(942) AS template7, smallint AS nfiq7, smallint AS minucias7, char(942) AS template8, 
    smallint AS nfiq8, smallint AS minucias8, char(942) AS template9, smallint AS nfiq9, smallint AS minucias9, char(942) AS template10, smallint AS nfiq10, smallint AS minucias10, char(5) AS sucursalHuella,
    smallint AS idExcepcionHuella, char(8) AS userInsertHuella, date AS fechaHuella, datetime year to fraction(3) AS fechaInsertHuella,
    
    --campos adicionales
    CHAR(1000) AS campo1, CHAR(1000) AS campo2, CHAR(1000) AS campo3; 
    
--VARIABLES PARA DATOS 
DEFINE cempresa_corr CHAR(3);
DEFINE cnumcte_corr CHAR(20);
DEFINE ccorreo_elec CHAR(100);
DEFINE ctipo_correo SMALLINT;
DEFINE cstatus_correo CHAR(1);
DEFINE csecuencia SMALLINT;
DEFINE ccanal SMALLINT;
DEFINE cfecha_hora CHAR(23);
DEFINE cuser_insert_corr CHAR(8);
DEFINE cvalida_correo CHAR(3);
DEFINE cvalido CHAR(1);
DEFINE cfecha_valida datetime year to second;

-------------------------------------------
DEFINE cempresa_ctepf CHAR(3);
DEFINE cnumcte_ctepf CHAR(20);
DEFINE cfecha_nac DATE;
DEFINE clugar_nac CHAR(2);
DEFINE cnacionalidad CHAR(3);
DEFINE cno_fm3 CHAR(18);
DEFINE cestado_civil CHAR(2);
DEFINE cregim_matrimonio CHAR(1);
DEFINE cprofesion CHAR(3);
DEFINE csexo CHAR(1);
DEFINE ccurp CHAR(20);
DEFINE ccodidentifi CHAR(2);
DEFINE cnumidentifi CHAR(30);
DEFINE cno_imss CHAR(12);
DEFINE cdependientes SMALLINT;
DEFINE ctutor CHAR(60);
DEFINE cnom_conyuge CHAR(60);
DEFINE cseguro_defunc CHAR(1);
DEFINE cescolaridad CHAR(2);
DEFINE chabita_en CHAR(2);
DEFINE canios_habita SMALLINT;
DEFINE cnombre_prop CHAR(60);
DEFINE cimp_hipo_renta MONEY;
DEFINE cactividadogiro CHAR(30);
DEFINE cnumeroife CHAR(20);
DEFINE cnumerotutor CHAR(20);
DEFINE cnumeroconyuge CHAR(20);
DEFINE cstring1_ctepf CHAR(20);
DEFINE cstring2_ctepf CHAR(20);
DEFINE cnumeric1_ctepf INTEGER;
DEFINE cnumeric2_ctepf INTEGER;
DEFINE cmoney1_ctepf MONEY;
DEFINE cdate1_ctepf DATE;
DEFINE cuser_insert_ctepf CHAR(8);
DEFINE cfecha_insert_ctepf DATE;
DEFINE csms_cel CHAR(1);
DEFINE chora_insert DATETIME YEAR to FRACTION(3);
DEFINE cvalidacurp CHAR(1);
DEFINE cid_pais CHAR(3);
-----------------------------------------------------
DEFINE cnumcte_dir CHAR(20);
DEFINE csecuencia_dir INTEGER;
DEFINE ctipo_dir CHAR(1);
DEFINE ccalle CHAR(40);
DEFINE ccolonia CHAR(60);
DEFINE centre_calles CHAR(40);
DEFINE cpais CHAR(3);
DEFINE cestado CHAR(2);
DEFINE cciudad CHAR(3);
DEFINE cmunicipio CHAR(5);
DEFINE ccod_postal CHAR(5);
DEFINE capart_postal CHAR(11);
DEFINE cestado_inegi CHAR(2);
DEFINE cmunicipio_inegi CHAR(3);
DEFINE clocalidad_inegi CHAR(4);
DEFINE cnumerociudad SMALLINT;
DEFINE cnumeroextcalle CHAR(10);
DEFINE cnumerointcalle CHAR(10);
DEFINE cdepartamento CHAR(6);
DEFINE cnumerocalle INTEGER;
DEFINE cnumerocolonia INTEGER;
DEFINE cpuntocardinal CHAR(1);
DEFINE cunidadhabitac CHAR(1);
DEFINE cmanzana SMALLINT;
DEFINE cotros SMALLINT;
DEFINE candador SMALLINT;
DEFINE cetapa SMALLINT;
DEFINE clote SMALLINT;
DEFINE cedificio SMALLINT;
DEFINE centrada SMALLINT;
DEFINE cobservaciones_dir CHAR(80);
DEFINE cuser_insert_dir CHAR(8);
DEFINE cfecha_insert_dir DATE;
DEFINE cind_cofeteltel1 CHAR(1);
DEFINE cind_cofeteltel2 CHAR(1);
DEFINE cind_coffeteltel3 CHAR(1);
---------------------------------------------------
DEFINE cempresa_tel CHAR(3);
DEFINE cnumcte_tel CHAR(20);
DEFINE ctelefono CHAR(27);
DEFINE ctipo_tel SMALLINT;
DEFINE cstatus_tel CHAR(1);
DEFINE csecuencia_tel SMALLINT;
DEFINE cextension CHAR(5);
DEFINE ccarrier SMALLINT;
DEFINE ccanal_tel SMALLINT;
DEFINE ccontacto SMALLINT;
DEFINE ccofetel CHAR(1);
DEFINE cfecha_hora_tel DATETIME YEAR to SECOND;
DEFINE cuser_insert_tel CHAR(8);
DEFINE cmovil_fijo CHAR(1);
DEFINE cstatus_stel CHAR(1);
DEFINE cverificado CHAR(1);
DEFINE cmarcatel CHAR(1);
DEFINE cfecha_actualiza DATE;	--validar
DEFINE ctel_confirmado CHAR(1);
DEFINE cfech_confirmado DATETIME YEAR to SECOND;

DEFINE fechaTelCasa DATETIME YEAR to SECOND;
DEFINE fechaTelCel DATETIME YEAR to SECOND;
-----------------------------------------------------
DEFINE cempresa_cte CHAR(3);
DEFINE cnumcte_cte CHAR(20);
DEFINE cstatus_cte CHAR(2);
DEFINE csucursal_cte CHAR(4);
DEFINE cejecutivo CHAR(8);
DEFINE ctpo_persona CHAR(2);
DEFINE ctipo_cliente CHAR(1);
DEFINE capell_paterno CHAR(26);
DEFINE capell_materno CHAR(26);
DEFINE cnombre1 CHAR(26);
DEFINE cnombre2 CHAR(26);
DEFINE crazon_social CHAR(26);
DEFINE crfc CHAR(13);
DEFINE csector CHAR(2);
DEFINE csegmento CHAR(3);
DEFINE cactividad_princ CHAR(3);
DEFINE cgrupo CHAR(3);
DEFINE csubgrupo CHAR(3);
DEFINE cresidencia CHAR(1);
DEFINE cfecha_alta_cte DATE;
DEFINE capell_casada CHAR(26);
DEFINE cdistrito CHAR(2);
DEFINE cnumcte_ref CHAR(20);
DEFINE cstring1 CHAR(20);
DEFINE cstring2 CHAR(60);
DEFINE cnumeric1 SMALLINT;
DEFINE cnumeric2 INTEGER;
DEFINE cmoney1 MONEY;
DEFINE cdate1 DATE;		--validar
DEFINE cpuesto_ppes CHAR(1);
DEFINE cfamiliar_ppes CHAR(1);
DEFINE cactividad_esp CHAR(11);
DEFINE cajecut_autoriza CHAR(8);
DEFINE cuser_insert_cte CHAR(8);
DEFINE cfecha_insert_cte DATE;
DEFINE crfc_alterno CHAR(13);
DEFINE ctpo_biometria CHAR(1);
DEFINE ccliente_pros CHAR(1);
DEFINE cenvio_movtosc SMALLINT;
-----------------------------------------------------
DEFINE cnumcte_hu char(20);
DEFINE csecuencia_hu smallint;
DEFINE cestatus_hu char(1);
DEFINE cid_template_hu smallint;
DEFINE ctemplate char(942);
DEFINE ctemplate_1 char(942);
DEFINE ctemplate_2 char(942);
DEFINE ctemplate_3 char(942);
DEFINE ctemplate_4 char(942);
DEFINE ctemplate_5 char(942);
DEFINE ctemplate_6 char(942);
DEFINE ctemplate_7 char(942);
DEFINE ctemplate_8 char(942);
DEFINE ctemplate_9 char(942);
DEFINE ctemplate_10 char(942);
DEFINE cnfiq smallint;
DEFINE cminucias smallint;
DEFINE cnfiq_1 smallint;
DEFINE cminucias_1 smallint;
DEFINE cnfiq_2 smallint;
DEFINE cminucias_2 smallint;
DEFINE cnfiq_3 smallint;
DEFINE cminucias_3 smallint;
DEFINE cnfiq_4 smallint;
DEFINE cminucias_4 smallint;
DEFINE cnfiq_5 smallint;
DEFINE cminucias_5 smallint;
DEFINE cnfiq_6 smallint;
DEFINE cminucias_6 smallint;
DEFINE cnfiq_7 smallint;
DEFINE cminucias_7 smallint;
DEFINE cnfiq_8 smallint;
DEFINE cminucias_8 smallint;
DEFINE cnfiq_9 smallint;
DEFINE cminucias_9 smallint;
DEFINE cnfiq_10 smallint;
DEFINE cminucias_10 smallint;
DEFINE csucursal_hu char(5);
DEFINE cid_excepcion_hu smallint;
DEFINE cuser_insert_hu char(8);
DEFINE cfecha_hu date;
DEFINE cfecha_insert_hu datetime year to fraction(3);

DEFINE cCampo1 CHAR(1000);
DEFINE cCampo2 CHAR(1000);
DEFINE cCampo3 CHAR(1000);
DEFINE codRet CHAR(5);
DEFINE codRetSec CHAR(100);
DEFINE sql_err INTEGER;
DEFINE cTelefonoCasa CHAR(13);
DEFINE cTelefonoCelular CHAR(13);



--Inicializacion de variables
LET cempresa_corr ="";                      
LET cnumcte_corr ="000";
LET ccorreo_elec ="000";
LET ctipo_correo =1;
LET cstatus_correo ="0";
LET csecuencia =1;                      
LET ccanal =1;
LET cfecha_hora ="";
LET cuser_insert_corr ="";
LET cvalida_correo ="";
LET cvalido ="";
LET cfecha_valida = '1900-01-01 00:00:00';
------------------------------------------
LET cempresa_ctepf ="";                      
LET cnumcte_ctepf ="000";
LET cfecha_nac ="";
LET clugar_nac ="";
LET cnacionalidad ="";
LET cno_fm3 ="";
LET cestado_civil ="";
LET cregim_matrimonio ="";
LET cprofesion ="";
LET csexo ="";
LET ccurp ="";
LET ccodidentifi ="";
LET cnumidentifi ="";
LET cno_imss ="";
LET cdependientes =0;
LET ctutor ="";
LET cnom_conyuge ="";
LET cseguro_defunc ="";
LET cescolaridad ="";
LET chabita_en ="";
LET canios_habita =0;
LET cnombre_prop ="";
LET cimp_hipo_renta =0.0;
LET cactividadogiro ="";
LET cnumeroife ="";
LET cnumerotutor ="";
LET cnumeroconyuge ="";
LET cstring1_ctepf ="";
LET cstring2_ctepf ="";
LET cnumeric1_ctepf =0;
LET cnumeric2_ctepf =0;
LET cmoney1_ctepf =0.0;
LET cdate1_ctepf ="";
LET cuser_insert_ctepf ="USER";
LET cfecha_insert_ctepf ="";
LET csms_cel ="";
LET chora_insert = '1900-01-01 00:00:00.777';
LET cvalidacurp ="";
LET cid_pais ="";
-----------------------------------------------------------------------------
LET cnumcte_dir ="000";
LET csecuencia_dir =0;                      
LET ctipo_dir ="";
LET ccalle ="";
LET ccolonia ="";
LET centre_calles ="";
LET cpais ="";
LET cestado ="";
LET cciudad ="";
LET cmunicipio ="";
LET ccod_postal ="";
LET capart_postal ="";
LET cestado_inegi ="";
LET cmunicipio_inegi ="";
LET clocalidad_inegi ="";
LET cnumerociudad =1;
LET cnumeroextcalle ="";
LET cnumerointcalle ="";
LET cdepartamento ="";
LET cnumerocalle =0;
LET cnumerocolonia =0;
LET cpuntocardinal ="";
LET cunidadhabitac ="";
LET cmanzana =0;
LET cotros =0;
LET candador =0;
LET cetapa =0;
LET clote =0;
LET cedificio =0;
LET centrada =0;
LET cobservaciones_dir ="";
LET cuser_insert_dir ="USER";
LET cfecha_insert_dir ="";
LET cind_cofeteltel1 ='F';
LET cind_cofeteltel2 ='F';
LET cind_coffeteltel3 ='F';
-------------------------------------------------
LET cempresa_tel ="000";                      
LET cnumcte_tel ="000";
LET ctelefono ="000";
LET ctipo_tel =0;
LET cstatus_tel ="0";
LET csecuencia_tel =0;                      
LET cextension ="";
LET ccarrier =0;
LET ccanal_tel =0;
LET ccontacto =0;
LET ccofetel ="";
LET cfecha_hora_tel ='2023-08-21 14:30:00';
LET cuser_insert_tel ="";
LET cmovil_fijo ='0';
LET cstatus_stel =' ';
LET cverificado ="";
LET cmarcatel ="";
LET cfecha_actualiza = "";
LET ctel_confirmado ="";
LET cfech_confirmado = '2023-08-21 14:30:00';

LET fechaTelCasa = '1900-01-01 00:00:00';
LET fechaTelCel = '1900-01-01 00:00:00';
-----------------------------------------------------
LET cnumcte_hu = "";
LET csecuencia_hu = 0;
LET cestatus_hu = '';
LET cid_template_hu = 0;
LET ctemplate = "";
LET ctemplate_1 = "";
LET ctemplate_2 = "";
LET ctemplate_3 = "";
LET ctemplate_4 = "";
LET ctemplate_5 = "";
LET ctemplate_6 = "";
LET ctemplate_7 = "";
LET ctemplate_8 = "";
LET ctemplate_9 = "";
LET ctemplate_10 = "";
LET cnfiq = 0;
LET cminucias = 0;
LET cnfiq_1 = 0;
LET cminucias_1 = 0;
LET cnfiq_2 = 0;
LET cminucias_2 = 0;
LET cnfiq_3 = 0;
LET cminucias_3 = 0;
LET cnfiq_4 = 0;
LET cminucias_4 = 0;
LET cnfiq_5 = 0;
LET cminucias_5 = 0;
LET cnfiq_6 = 0;
LET cminucias_6 = 0;
LET cnfiq_7 = 0;
LET cminucias_7 = 0;
LET cnfiq_8 = 0;
LET cminucias_8 = 0;
LET cnfiq_9 = 0;
LET cminucias_9 = 0;
LET cnfiq_10 = 0;
LET cminucias_10 = 0;
LET csucursal_hu = "";
LET cid_excepcion_hu = 0;
LET cuser_insert_hu = "";
LET cfecha_hu = '1900-01-01';
LET cfecha_insert_hu = '1900-01-01 00:00:00.777';
----------------------------------------------
LET cempresa_cte ="";                      
LET cnumcte_cte ="000";
LET cstatus_cte ="";
LET csucursal_cte ="";
LET cejecutivo ="";
LET ctpo_persona ="";
LET ctipo_cliente ="";
LET capell_paterno ="";
LET capell_materno ="";
LET cnombre1 ="";
LET cnombre2 ="000000";
LET crazon_social ="0000000";
LET crfc ="";
LET csector ="";
LET csegmento ="";
LET cactividad_princ ="";
LET cgrupo ="";
LET csubgrupo ="";
LET cresidencia ="";
LET cfecha_alta_cte ="";
LET capell_casada ="";
LET cdistrito ="";
LET cnumcte_ref ="";
LET cstring1 ="";
LET cstring2 ="";
LET cnumeric1 =0;
LET cnumeric2 =0;
LET cmoney1 =0.0;
LET cdate1 = "";
LET cpuesto_ppes ="";
LET cfamiliar_ppes ="";
LET cactividad_esp ="";
LET cajecut_autoriza ="";
LET cuser_insert_cte ="USER";
LET cfecha_insert_cte ='1900-01-01';
LET crfc_alterno ="";
LET ctpo_biometria ='0';
LET ccliente_pros =' ';
LET cenvio_movtosc =0;

LET cCampo1 = "";
LET cCampo2 = "";
LET cCampo3 = "";
LET codRet = "00000";
LET codRetSec = "";
LET sql_err = 0;
LET cTelefonoCasa = "";
LET cTelefonoCelular = "";


--Logica del sp donde se realizan las consultas a las tablas correspondientes
begin

   on exception set sql_err
       if sql_err <> 0 then
         let codRet = sql_err;
         let codRetSec = "Ocurrio un error";
         return
            --errores
            codRet, codRetSec,
			--si_cliente
			nvl(cempresa_cte, ""),	nvl(cnumcte_cte, ""),  nvl(cstatus_cte, ""), nvl(csucursal_cte, ""), nvl(cejecutivo, ""), nvl(ctpo_persona, ""), nvl(ctipo_cliente, ""),  nvl(capell_paterno, ""),
			nvl(capell_materno, ""), nvl(cnombre1, ""), nvl(cnombre2, ""), nvl(crazon_social, ""), nvl(crfc, ""), nvl(csector, ""),  nvl(csegmento, ""), nvl(cactividad_princ, ""), nvl(cgrupo, ""),
			nvl(csubgrupo, ""), nvl(cresidencia, ""), nvl(cfecha_alta_cte, '1900-01-01'),  nvl(capell_casada, ""),  nvl(cdistrito, ""), nvl(cnumcte_ref, ""), nvl(cstring1, ""), nvl(cstring2, ""), 
			nvl(cnumeric1, 0),  nvl(cnumeric2, 0),  nvl(cmoney1, 0.0), nvl(cdate1, '1900-01-01'), nvl(cpuesto_ppes, ""), nvl(cfamiliar_ppes, ""), nvl(cactividad_esp, ""),  nvl(cajecut_autoriza, ""), 
			nvl(cuser_insert_cte, "USER"),  nvl(cfecha_insert_cte, '1900-01-01'),  nvl(crfc_alterno, ""), nvl(ctpo_biometria, ""), nvl(ccliente_pros, ""), nvl(cenvio_movtosc, 0),
            --si_ctepf
            nvl(cempresa_ctepf, ""), nvl(cnumcte_ctepf, ""), nvl(cfecha_nac, '1900-01-01'), nvl(clugar_nac, ""), nvl(cnacionalidad, ""), nvl(cno_fm3, ""),                       	    
            nvl(cestado_civil, ""), nvl(cregim_matrimonio, ""), nvl(cprofesion, ""), nvl(csexo, ""), nvl(ccurp, ""), nvl(ccodidentifi, ""),                       
            nvl(cnumidentifi, ""), nvl(cno_imss, ""), nvl(cdependientes, 0), nvl(ctutor, ""), nvl(cnom_conyuge, ""), nvl(cseguro_defunc, ""), nvl(cescolaridad, ""),                       
            nvl(chabita_en, ""),nvl(canios_habita, 0), nvl(cnombre_prop, ""), nvl(cimp_hipo_renta, 0.0), nvl(cactividadogiro, ""), nvl(cnumeroife, ""),                       	    
            nvl(cnumerotutor, ""),nvl(cnumeroconyuge, ""),nvl(cstring1_ctepf, ""),nvl(cstring2_ctepf, ""),nvl(cnumeric1_ctepf, 0),nvl(cnumeric2_ctepf, 0), nvl(cmoney1_ctepf, 0.0), nvl(cdate1_ctepf, '1900-01-01'),                       	
            nvl(cuser_insert_ctepf,"USER"),nvl(cfecha_insert_ctepf, '1900-01-01'), nvl(csms_cel, ""), nvl(chora_insert, '1900-01-01 00:00:00.000'), nvl(cvalidacurp, ""),                       	 
            nvl(cid_pais, ""),
            --si_direcciones
            nvl(cnumcte_dir, ""), nvl(csecuencia_dir, 0), nvl(ctipo_dir, ""), nvl(ccalle, ""), nvl(ccolonia, ""), nvl(centre_calles, ""), nvl(cpais, ""), nvl(cestado, ""), nvl(cciudad, ""), 
            nvl(cmunicipio, ""), nvl(ccod_postal, ""), nvl(capart_postal, ""), nvl(cestado_inegi, ""), nvl(cmunicipio_inegi, ""), nvl(clocalidad_inegi, ""), nvl(cnumerociudad, 1), nvl(cnumeroextcalle, ""), 
            nvl(cnumerointcalle, ""), nvl(cdepartamento, ""), nvl(cnumerocalle, 0), nvl(cnumerocolonia, 0), nvl(cpuntocardinal, ""), nvl(cunidadhabitac, ""), nvl(cmanzana, 0), nvl(cotros, 0), 
            nvl(candador, 0), nvl(cetapa, 0), nvl(clote, 0), nvl(cedificio, 0), nvl(centrada, 0), nvl(cobservaciones_dir, ""), nvl(cuser_insert_dir, "USER"), nvl(cfecha_insert_dir, '1900-01-01'),   
            nvl(cind_cofeteltel1, "F"), nvl(cind_cofeteltel2, "F"), nvl(cind_coffeteltel3, "F"),    
           	--si_correos
            nvl(cempresa_corr, ""), nvl(cnumcte_corr, ""), nvl(ccorreo_elec, ""), nvl(ctipo_correo, 1), nvl(cstatus_correo, ""), nvl(csecuencia, 1),nvl(ccanal, 1), nvl(cfecha_hora, ""), nvl(cuser_insert_corr, ""), 
            nvl(cvalida_correo, ""), nvl(cvalido, ""), nvl(cfecha_valida, '1900-01-01 00:00:00'),
            --si_telefonos_actual
            nvl(cempresa_tel, ""), nvl(cnumcte_tel, ""), nvl(ctelefono, ""), nvl(ctipo_tel, 0), nvl(cstatus_tel, ""), nvl(csecuencia_tel, 0), nvl(cextension, ""), nvl(ccarrier, 0), nvl(ccanal_tel, 0), nvl(ccontacto, 0),          	
            nvl(ccofetel, ""), nvl(cfecha_hora_tel, '1900-01-01 00:00:00'), nvl(cuser_insert_tel, ""), nvl(cmovil_fijo, ""), nvl(cstatus_stel, ""), nvl(ctel_confirmado, ""), nvl(cfech_confirmado, '1900-01-01 00:00:00'),                       	
        	--si_cte_huella_dec
            nvl(cnumcte_hu, ""), nvl(csecuencia_hu, 0), nvl(cestatus_hu, ""), nvl(cid_template_hu, 0), nvl(ctemplate_1, ""),nvl(cnfiq_1, 0), nvl(cminucias_1, 0), nvl(ctemplate_2, ""), nvl(cnfiq_2, 0), nvl(cminucias_2, 0), 
            nvl(ctemplate_3, ""), nvl(cnfiq_3, 0), nvl(cminucias_3, 0), nvl(ctemplate_4, ""), nvl(cnfiq_4, 0), nvl(cminucias_4, 0), nvl(ctemplate_5, ""), nvl(cnfiq_5, 0), nvl(cminucias_5, 0), nvl(ctemplate_6, ""), 
            nvl(cnfiq_6, 0), nvl(cminucias_6, 0), nvl(ctemplate_7, ""), nvl(cnfiq_7, 0), nvl(cminucias_7, 0), nvl(ctemplate_8, ""), nvl(cnfiq_8, 0), nvl(cminucias_8, 0), nvl(ctemplate_9, ""), nvl(cnfiq_9, 0),
            nvl(cminucias_9, 0), nvl(ctemplate_10, ""), nvl(cnfiq_10, 0), nvl(cminucias_10, 0), nvl(csucursal_hu, ""), nvl(cid_excepcion_hu, 0), nvl(cuser_insert_hu, ""), nvl(cfecha_hu, '1900-01-01'), nvl(cfecha_insert_hu, '1900-01-01 00:00:00.000'),
            --campos adicionales
            nvl(cCampo1, ""), nvl(cCampo1, ""), nvl(cCampo1, "");
      end if;
   end exception;
   
   if pnumcte is null then
    LET codRet = "00002";
    LET codRetSec = "Parametro cliente nulo";
    else if pnumcte == "" then
            LET codRet = "00001";
            LET codRetSec = "Parametro cliente vacio";
         end if
   end if;
   
   if codRet > 0 then
         return
            --errores
            codRet, codRetSec,
			--si_cliente
			nvl(cempresa_cte, ""),	nvl(cnumcte_cte, ""),  nvl(cstatus_cte, ""), nvl(csucursal_cte, ""), nvl(cejecutivo, ""), nvl(ctpo_persona, ""), nvl(ctipo_cliente, ""),  nvl(capell_paterno, ""),
			nvl(capell_materno, ""), nvl(cnombre1, ""), nvl(cnombre2, ""), nvl(crazon_social, ""), nvl(crfc, ""), nvl(csector, ""),  nvl(csegmento, ""), nvl(cactividad_princ, ""), nvl(cgrupo, ""),
			nvl(csubgrupo, ""), nvl(cresidencia, ""), nvl(cfecha_alta_cte, '1900-01-01'),  nvl(capell_casada, ""),  nvl(cdistrito, ""), nvl(cnumcte_ref, ""), nvl(cstring1, ""), nvl(cstring2, ""), 
			nvl(cnumeric1, 0),  nvl(cnumeric2, 0),  nvl(cmoney1, 0.0), nvl(cdate1, '1900-01-01'), nvl(cpuesto_ppes, ""), nvl(cfamiliar_ppes, ""), nvl(cactividad_esp, ""),  nvl(cajecut_autoriza, ""), 
			nvl(cuser_insert_cte, "USER"),  nvl(cfecha_insert_cte, ""),  nvl(crfc_alterno, ""), nvl(ctpo_biometria, ""), nvl(ccliente_pros, ""), nvl(cenvio_movtosc, 0),
            --si_ctepf
            nvl(cempresa_ctepf, ""), nvl(cnumcte_ctepf, ""), nvl(cfecha_nac, '1900-01-01'), nvl(clugar_nac, ""), nvl(cnacionalidad, ""), nvl(cno_fm3, ""),                       	    
            nvl(cestado_civil, ""), nvl(cregim_matrimonio, ""), nvl(cprofesion, ""), nvl(csexo, ""), nvl(ccurp, ""), nvl(ccodidentifi, ""),                       
            nvl(cnumidentifi, ""), nvl(cno_imss, ""), nvl(cdependientes, 0), nvl(ctutor, ""), nvl(cnom_conyuge, ""), nvl(cseguro_defunc, ""), nvl(cescolaridad, ""),                       
            nvl(chabita_en, ""),nvl(canios_habita, 0), nvl(cnombre_prop, ""), nvl(cimp_hipo_renta, 0.0), nvl(cactividadogiro, ""), nvl(cnumeroife, ""),                       	    
            nvl(cnumerotutor, ""),nvl(cnumeroconyuge, ""),nvl(cstring1_ctepf, ""),nvl(cstring2_ctepf, ""),nvl(cnumeric1_ctepf, 0),nvl(cnumeric2_ctepf, 0), nvl(cmoney1_ctepf, 0.0), nvl(cdate1_ctepf, '1900-01-01'),                       	
            nvl(cuser_insert_ctepf,"USER"),nvl(cfecha_insert_ctepf, '1900-01-01'), nvl(csms_cel, ""), nvl(chora_insert, '1900-01-01 00:00:00.000'), nvl(cvalidacurp, ""),                       	 
            nvl(cid_pais, ""),
            --si_direcciones
            nvl(cnumcte_dir, ""), nvl(csecuencia_dir, 0), nvl(ctipo_dir, ""), nvl(ccalle, ""), nvl(ccolonia, ""), nvl(centre_calles, ""), nvl(cpais, ""), nvl(cestado, ""), nvl(cciudad, ""), 
            nvl(cmunicipio, ""), nvl(ccod_postal, ""), nvl(capart_postal, ""), nvl(cestado_inegi, ""), nvl(cmunicipio_inegi, ""), nvl(clocalidad_inegi, ""), nvl(cnumerociudad, 1), nvl(cnumeroextcalle, ""), 
            nvl(cnumerointcalle, ""), nvl(cdepartamento, ""), nvl(cnumerocalle, 0), nvl(cnumerocolonia, 0), nvl(cpuntocardinal, ""), nvl(cunidadhabitac, ""), nvl(cmanzana, 0), nvl(cotros, 0), 
            nvl(candador, 0), nvl(cetapa, 0), nvl(clote, 0), nvl(cedificio, 0), nvl(centrada, 0), nvl(cobservaciones_dir, ""), nvl(cuser_insert_dir, "USER"), nvl(cfecha_insert_dir, '1900-01-01'),   
            nvl(cind_cofeteltel1, "F"), nvl(cind_cofeteltel2, "F"), nvl(cind_coffeteltel3, "F"),    
           	--si_correos
            nvl(cempresa_corr, ""), nvl(cnumcte_corr, ""), nvl(ccorreo_elec, ""), nvl(ctipo_correo, 1), nvl(cstatus_correo, ""), nvl(csecuencia, 1),nvl(ccanal, 1), nvl(cfecha_hora, ""), nvl(cuser_insert_corr, ""), 
            nvl(cvalida_correo, ""), nvl(cvalido, ""), nvl(cfecha_valida, '1900-01-01 00:00:00'), 
            --si_telefonos_actual
            nvl(cempresa_tel, ""), nvl(cnumcte_tel, ""), nvl(ctelefono, ""), nvl(ctipo_tel, 0), nvl(cstatus_tel, ""), nvl(csecuencia_tel, 0), nvl(cextension, ""), nvl(ccarrier, 0), nvl(ccanal_tel, 0), nvl(ccontacto, 0),          	
            nvl(ccofetel, ""), nvl(cfecha_hora_tel, '1900-01-01 00:00:00'), nvl(cuser_insert_tel, ""), nvl(cmovil_fijo, ""), nvl(cstatus_stel, ""), nvl(ctel_confirmado, ""), nvl(cfech_confirmado, '1900-01-01 00:00:00'),                       	
        	--si_cte_huella_dec
            nvl(cnumcte_hu, ""), nvl(csecuencia_hu, 0), nvl(cestatus_hu, ""), nvl(cid_template_hu, 0), nvl(ctemplate_1, ""),nvl(cnfiq_1, 0), nvl(cminucias_1, 0), nvl(ctemplate_2, ""), nvl(cnfiq_2, 0), nvl(cminucias_2, 0), 
            nvl(ctemplate_3, ""), nvl(cnfiq_3, 0), nvl(cminucias_3, 0), nvl(ctemplate_4, ""), nvl(cnfiq_4, 0), nvl(cminucias_4, 0), nvl(ctemplate_5, ""), nvl(cnfiq_5, 0), nvl(cminucias_5, 0), nvl(ctemplate_6, ""), 
            nvl(cnfiq_6, 0), nvl(cminucias_6, 0), nvl(ctemplate_7, ""), nvl(cnfiq_7, 0), nvl(cminucias_7, 0), nvl(ctemplate_8, ""), nvl(cnfiq_8, 0), nvl(cminucias_8, 0), nvl(ctemplate_9, ""), nvl(cnfiq_9, 0),
            nvl(cminucias_9, 0), nvl(ctemplate_10, ""), nvl(cnfiq_10, 0), nvl(cminucias_10, 0), nvl(csucursal_hu, ""), nvl(cid_excepcion_hu, 0), nvl(cuser_insert_hu, ""), nvl(cfecha_hu, '1900-01-01'), nvl(cfecha_insert_hu, '1900-01-01 00:00:00.000'),
            --campos adicionales
            nvl(cCampo1, ""), nvl(cCampo1, ""), nvl(cCampo1, "");
   end if
	
	--Nombre de los campos de la tabla bdinteg:si_correos
	select empresa, numcte, correo_elec, tipo_correo, status_correo, secuencia, canal, fecha_hora, user_insert, valida_correo, valido, nvl(fecha_valida,'1900-01-01 00:00:00')
	into cempresa_corr, cnumcte_corr, ccorreo_elec, ctipo_correo, cstatus_correo, csecuencia, ccanal, cfecha_hora, cuser_insert_corr, cvalida_correo, cvalido, cfecha_valida
	from "informix".si_correos 
	WHERE numcte = pnumcte and status_correo = 'A';

  	if nvl(cnumcte_corr, "") == "" then
        LET codRet = "00003";
        LET codRetSec = "Cliente no encontrado en tabla si_correos";
    end if
      
    if(codRet == "00000") then
	    --Nombre de los campos de la tabla bdinteg.si_ctepf
		SELECT empresa, numcte, nvl(fecha_nac,'1900-01-01'), lugar_nac, nacionalidad, no_fm3, estado_civil, regim_matrimonio, profesion, sexo, curp, codidentifi, numidentifi, no_imss, dependientes
				,tutor, nom_conyuge, seguro_defunc, escolaridad, habita_en, anios_habita, nombre_prop, imp_hipo_renta, actividadogiro, numeroife, numerotutor, numeroconyuge, string1, string2
				,numeric1, numeric2, money1, nvl(date1,'1900-01-01'), user_insert, nvl(fecha_insert,'1900-01-01'), sms_cel, nvl(hora_insert,'1900-01-01 00:00:00.777'), validacurp, id_pais 
		--Nombre de las variables  que recibiran esaso datos.
		INTO cempresa_ctepf, cnumcte_ctepf, cfecha_nac, clugar_nac, cnacionalidad, cno_fm3, cestado_civil, cregim_matrimonio, cprofesion, csexo, ccurp, ccodidentifi, cnumidentifi,
		       cno_imss, cdependientes, ctutor, cnom_conyuge, cseguro_defunc, cescolaridad, chabita_en, canios_habita, cnombre_prop, cimp_hipo_renta, cactividadogiro, cnumeroife,
			   cnumerotutor, cnumeroconyuge, cstring1_ctepf, cstring2_ctepf, cnumeric1_ctepf, cnumeric2_ctepf, cmoney1_ctepf, cdate1_ctepf, cuser_insert_ctepf, cfecha_insert_ctepf, csms_cel, chora_insert, cvalidacurp, cid_pais 
		FROM "informix".si_ctepf 
		WHERE numcte = pnumcte limit 1;
	
		if nvl(cnumcte_ctepf, "") == "" then
	        LET codRet = "00004";
	        LET codRetSec = "Cliente no encontrado en tabla si_ctepf";
	    end if
	
	    if(codRet == "00000") then
			--Nombre de los campos de la tabla bdinteg.si_direcciones
			SELECT numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal, estado_inegi, municipio_inegi, localidad_inegi, numerociudad,
					numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones,
					user_insert, nvl(fecha_insert,'1900-01-01 '), ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3 
			--Nombre de las variables  que recibiran esaso datos.
			INTO  cnumcte_dir, csecuencia_dir, ctipo_dir, ccalle, ccolonia, centre_calles, cpais, cestado, cciudad, cmunicipio, ccod_postal, capart_postal, cestado_inegi, cmunicipio_inegi,
			       clocalidad_inegi, cnumerociudad, cnumeroextcalle, cnumerointcalle, cdepartamento, cnumerocalle, cnumerocolonia, cpuntocardinal, cunidadhabitac, cmanzana, cotros, candador,
				   cetapa, clote, cedificio, centrada, cobservaciones_dir, cuser_insert_dir, cfecha_insert_dir, cind_cofeteltel1, cind_cofeteltel2, cind_coffeteltel3
			FROM "informix".si_direcciones_actual 
			WHERE numcte = pnumcte
			and tipo_dir = '1'
			AND secuencia = (SELECT MAX(secuencia)
								FROM "informix".si_direcciones_actual
								WHERE numcte = pnumcte
								and tipo_dir = '1'
							);
			
			if nvl(cnumcte_dir, "") == "" then
		        LET codRet = "00005";
		        LET codRetSec = "Cliente no encontrado en tabla si_direcciones";
		    end if
		
		    if(codRet == "00000") then
			--Nombre de los campos de la tabla bdinteg.si_cliente
				SELECT empresa, numcte, status_cte, sucursal, ejecutivo, tpo_persona, tipo_cliente, apell_paterno, apell_materno, nombre1, nombre2, razon_social, rfc, sector, segmento,
						actividad_princ, grupo, subgrupo, residencia, nvl(fecha_alta,'1900-01-01'), apell_casada, distrito, numcte_ref, string1, string2, numeric1, numeric2, money1, nvl(date1,'1900-01-01'), puesto_ppes, familiar_ppes,
						actividad_esp, ejecut_autoriza, user_insert, fecha_insert, rfc_alterno, tpo_biometria, cliente_pros, envio_movtos 
				--Nombre de las variables  que recibiran esaso datos.
				INTO cempresa_cte, cnumcte_cte, cstatus_cte, csucursal_cte, cejecutivo, ctpo_persona, ctipo_cliente, capell_paterno, capell_materno, cnombre1, cnombre2, crazon_social,
				        crfc, csector, csegmento, cactividad_princ, cgrupo, csubgrupo, cresidencia, cfecha_alta_cte, capell_casada, cdistrito, cnumcte_ref, cstring1, cstring2, cnumeric1,
						cnumeric2, cmoney1, cdate1, cpuesto_ppes, cfamiliar_ppes, cactividad_esp, cajecut_autoriza, cuser_insert_cte, cfecha_insert_cte, crfc_alterno, ctpo_biometria,
						ccliente_pros, cenvio_movtosc
				FROM "informix".si_cliente 
				WHERE numcte = pnumcte;
				
				if nvl(cnumcte_cte, "") == "" then
			        LET codRet = "00006";
			        LET codRetSec = "Cliente no encontrado en tabla si_cliente";
			    end if
			
			    if(codRet == "00000") then
					--Nombre de los campos de la tabla bdinteg.si_telefonos
				    foreach
						SELECT  empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, tel_confirmado, nvl(fech_confirmado,'1900-01-01 00:00:00')
						--Nombre de las variables  que recibiran esaso datos.
						INTO  cempresa_tel, cnumcte_tel, ctelefono, ctipo_tel, cstatus_tel, csecuencia_tel, cextension, ccarrier, ccanal_tel, ccontacto, ccofetel, cfecha_hora_tel, cuser_insert_tel,
						        cmovil_fijo, cstatus_stel, ctel_confirmado, cfech_confirmado
						FROM "informix".si_telefonos_actual
						WHERE numcte = pnumcte
						and status_tel = 'A'
						order by tipo_tel
						IF ctipo_tel == 1 THEN
							LET cTelefonoCasa = ctelefono;
							LET fechaTelCasa = cfecha_hora_tel;
						ELSE IF ctipo_tel == 2 THEN
							LET cTelefonoCelular = ctelefono;
							LET fechaTelCel = cfecha_hora_tel;
							END IF
						END IF
					END foreach;
					LET ctelefono = trim(cTelefonoCasa) || '|' || trim(cTelefonoCelular);
					LET cfecha_hora_tel = fechaTelCasa;
					if (fechaTelCel > fechaTelCasa) then
						LET cfecha_hora_tel = fechaTelCel; 
					end if
					
					/*and secuencia = (select MAX(secuencia)
										from informix.si_telefonos_actual
										where numcte = pnumcte);*/
					if nvl(cnumcte_tel, "") == "" then
				        LET codRet = "00007";
				        LET codRetSec = "Cliente no encontrado en tabla si_telefonos_actual";
				    end if
				
				    if(codRet == "00000") then
						--Nombre de los campos de la tabla bdinteg.si_cte_huella_dec
						foreach
							select numcte as cliente, secuencia, estatus, id_template, template, nfiq, minucias, sucursal, id_excepcion, user_insert, nvl(fecha,'1900-01-01'), nvl(fecha_insert,'1900-01-01 00:00:00.777')
							--Nombre de las variables  que recibiran esaso datos.
							into cnumcte_hu, csecuencia_hu, cestatus_hu, cid_template_hu, ctemplate, cnfiq, cminucias, csucursal_hu, cid_excepcion_hu, cuser_insert_hu, cfecha_hu, cfecha_insert_hu
							from "informix".si_cte_huella_dec
							WHERE  numcte = pnumcte
							and estatus = 'A'
							order by id_template
							
							if cid_template_hu == 1 then 
								let ctemplate_1 = ctemplate;
					        elif cid_template_hu == 2 then
					            let ctemplate_2 = ctemplate;
					        elif cid_template_hu == 3 then
					            let ctemplate_3 = ctemplate;
					        elif cid_template_hu == 4 then
					            let ctemplate_4 = ctemplate;
					        elif cid_template_hu == 5 then
					            let ctemplate_5 = ctemplate;
					        elif cid_template_hu == 6 then
					            let ctemplate_6 = ctemplate;
					        elif cid_template_hu == 7 then
					            let ctemplate_7 = ctemplate;
					        elif cid_template_hu == 8 then
					            let ctemplate_8 = ctemplate;
					        elif cid_template_hu == 9 then
					            let ctemplate_9 = ctemplate;
					        elif cid_template_hu == 10 then
								let ctemplate_10 = ctemplate;
					        end if
						end foreach;
					
						if nvl(cnumcte_hu, "") == "" then
					        LET codRet = "00008";
					        LET codRetSec = "Cliente no encontrado en tabla si_cte_huella_dec";
					    end if
		
		    		end if --validacion telefonos
		    	end if --validacion cliente
		  	end if --validacion direcciones
	    end if --validacion PF
    end if --validaciÃÂ³n de correos
   return  
            --errores
            codRet, codRetSec,
			--si_cliente
			nvl(cempresa_cte, ""),	nvl(cnumcte_cte, ""),  nvl(cstatus_cte, ""), nvl(csucursal_cte, ""), nvl(cejecutivo, ""), nvl(ctpo_persona, ""), nvl(ctipo_cliente, ""),  nvl(capell_paterno, ""),
			nvl(capell_materno, ""), nvl(cnombre1, ""), nvl(cnombre2, ""), nvl(crazon_social, ""), nvl(crfc, ""), nvl(csector, ""),  nvl(csegmento, ""), nvl(cactividad_princ, ""), nvl(cgrupo, ""),
			nvl(csubgrupo, ""), nvl(cresidencia, ""), nvl(cfecha_alta_cte, "1900-01-01"),  nvl(capell_casada, ""),  nvl(cdistrito, ""), nvl(cnumcte_ref, ""), nvl(cstring1, ""), nvl(cstring2, ""), 
			nvl(cnumeric1, 0),  nvl(cnumeric2, 0),  nvl(cmoney1, 0.0), nvl(cdate1, '1900-01-01'), nvl(cpuesto_ppes, ""), nvl(cfamiliar_ppes, ""), nvl(cactividad_esp, ""),  nvl(cajecut_autoriza, ""), 
			nvl(cuser_insert_cte, "USER"),  nvl(cfecha_insert_cte, '1900-01-01'),  nvl(crfc_alterno, ""), nvl(ctpo_biometria, ""), nvl(ccliente_pros, ""), nvl(cenvio_movtosc, 0),
            --si_ctepf
            nvl(cempresa_ctepf, ""), nvl(cnumcte_ctepf, ""), nvl(cfecha_nac, '1900-01-01'), nvl(clugar_nac, ""), nvl(cnacionalidad, ""), nvl(cno_fm3, ""),                       	    
            nvl(cestado_civil, ""), nvl(cregim_matrimonio, ""), nvl(cprofesion, ""), nvl(csexo, ""), nvl(ccurp, ""), nvl(ccodidentifi, ""),                       
            nvl(cnumidentifi, ""), nvl(cno_imss, ""), nvl(cdependientes, 0), nvl(ctutor, ""), nvl(cnom_conyuge, ""), nvl(cseguro_defunc, ""), nvl(cescolaridad, ""),                       
            nvl(chabita_en, ""),nvl(canios_habita, 0), nvl(cnombre_prop, ""), nvl(cimp_hipo_renta, 0.0), nvl(cactividadogiro, ""), nvl(cnumeroife, ""),                       	    
            nvl(cnumerotutor, ""),nvl(cnumeroconyuge, ""),nvl(cstring1_ctepf, ""),nvl(cstring2_ctepf, ""),nvl(cnumeric1_ctepf, 0),nvl(cnumeric2_ctepf, 0), nvl(cmoney1_ctepf, 0.0), nvl(cdate1_ctepf, '1900-01-01'),                       	
            nvl(cuser_insert_ctepf,"USER"), nvl(cfecha_insert_ctepf, '1900-01-01'), nvl(csms_cel, ""), nvl(chora_insert, '1900-01-01 00:00:00.000'),nvl(cvalidacurp, ""),                       	 
            nvl(cid_pais, ""),
            --si_direcciones
            nvl(cnumcte_dir, ""), nvl(csecuencia_dir, 0), nvl(ctipo_dir, ""), nvl(ccalle, ""), nvl(ccolonia, ""), nvl(centre_calles, ""), nvl(cpais, ""), nvl(cestado, ""), nvl(cciudad, ""), 
            nvl(cmunicipio, ""), nvl(ccod_postal, ""), nvl(capart_postal, ""), nvl(cestado_inegi, ""), nvl(cmunicipio_inegi, ""), nvl(clocalidad_inegi, ""), nvl(cnumerociudad, 1), nvl(cnumeroextcalle, ""), 
            nvl(cnumerointcalle, ""), nvl(cdepartamento, ""), nvl(cnumerocalle, 0), nvl(cnumerocolonia, 0), nvl(cpuntocardinal, ""), nvl(cunidadhabitac, ""), nvl(cmanzana, 0), nvl(cotros, 0), 
            nvl(candador, 0), nvl(cetapa, 0), nvl(clote, 0), nvl(cedificio, 0), nvl(centrada, 0), nvl(cobservaciones_dir, ""), nvl(cuser_insert_dir, "USER"), nvl(cfecha_insert_dir, '1900-01-01'),   
            nvl(cind_cofeteltel1, "F"), nvl(cind_cofeteltel2, "F"), nvl(cind_coffeteltel3, "F"),    
           	--si_correos
            nvl(cempresa_corr, ""), nvl(cnumcte_corr, ""), nvl(ccorreo_elec, ""), nvl(ctipo_correo, 1), nvl(cstatus_correo, ""), nvl(csecuencia, 1),nvl(ccanal, 1), nvl(cfecha_hora, ""), nvl(cuser_insert_corr, ""), 
            nvl(cvalida_correo, ""), nvl(cvalido, ""), nvl(cfecha_valida, '1900-01-01 00:00:00'),
            --si_telefonos_actual
            nvl(cempresa_tel, ""), nvl(cnumcte_tel, ""), nvl(ctelefono, ""), nvl(ctipo_tel, 0), nvl(cstatus_tel, ""), nvl(csecuencia_tel, 0), nvl(cextension, ""), nvl(ccarrier, 0), nvl(ccanal_tel, 0), nvl(ccontacto, 0),          	
            nvl(ccofetel, ""), nvl(cfecha_hora_tel, '1900-01-01 00:00:00'), nvl(cuser_insert_tel, ""), nvl(cmovil_fijo, ""), nvl(cstatus_stel, ""), nvl(ctel_confirmado, ""), nvl(cfech_confirmado, '1900-01-01 00:00:00'),                       	
        	--si_cte_huella_dec
            nvl(cnumcte_hu, ""), nvl(csecuencia_hu, 0), nvl(cestatus_hu, ""), nvl(cid_template_hu, 0), nvl(ctemplate_1, ""),nvl(cnfiq_1, 0), nvl(cminucias_1, 0), nvl(ctemplate_2, ""), nvl(cnfiq_2, 0), nvl(cminucias_2, 0), 
            nvl(ctemplate_3, ""), nvl(cnfiq_3, 0), nvl(cminucias_3, 0), nvl(ctemplate_4, ""), nvl(cnfiq_4, 0), nvl(cminucias_4, 0), nvl(ctemplate_5, ""), nvl(cnfiq_5, 0), nvl(cminucias_5, 0), nvl(ctemplate_6, ""), 
            nvl(cnfiq_6, 0), nvl(cminucias_6, 0), nvl(ctemplate_7, ""), nvl(cnfiq_7, 0), nvl(cminucias_7, 0), nvl(ctemplate_8, ""), nvl(cnfiq_8, 0), nvl(cminucias_8, 0), nvl(ctemplate_9, ""), nvl(cnfiq_9, 0),
            nvl(cminucias_9, 0), nvl(ctemplate_10, ""), nvl(cnfiq_10, 0), nvl(cminucias_10, 0), nvl(csucursal_hu, ""), nvl(cid_excepcion_hu, 0), nvl(cuser_insert_hu, ""), nvl(cfecha_hu, '1900-01-01'), nvl(cfecha_insert_hu, '1900-01-01 00:00:00.000'),
	        --campos adicionales
	        nvl(cCampo1, ""), nvl(cCampo1, ""), nvl(cCampo1, "");
end

end procedure;