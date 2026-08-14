CREATE PROCEDURE "informix".sp_batch_generarinformacion(pempresa CHAR(3), pFechaAct DATE)
RETURNING CHAR(6);

DEFINE cNoFm3 CHAR(18);
DEFINE cEmail CHAR(60);
DEFINE vcve, varea, vrumbo,vrumbotrab,vrumboref1,vrumboref2,vrumbotrabtmp,vcasapropia,vsexo,vestadocivil,vescolaridad,vtiposueldo,vsitesp,vsitespaux,vcveautRT,
vATsupervisadoRT,vctenuevo,vcreditojoven,vpuesto,cSexoConyuge,vrumbotrabcony,vcveconyugefamilia,cSexoref,  vcveref1 , cSexoref2 ,  vcveref2 , vmarcadatosin ,
 vflagentregotarjeta , vflagnoreconocehuella , vtipo , vTipoOrigen , cBuroPilotoTestig , cModeloCel , cflaguht, cUnidadHabit, cUnidadHabitTrabajo,cTipRechazo,
 cTipRechazoOs,iSecuenciaref1,iSecuenciaref2,vcvefamiliatmp,cSexoConyugetmp, cFlagProspecto, vVigenciaCliente,
 cPuntualidad_ref1, cPuntualidad_ref2,vsitesp_resp CHAR(1);
 
DEFINE vcaja,vuhcmanzana,vuhcotros, vuhcandador,vuhcetapa,vuhclote,vuhcedificio,vuhcentrada,vuhcmanzanaTrabajo,vuhcotrosTrabajo,vuhcandadorTrabajo,
 vuhcetapaTrabajo, vuhcloteTrabajo, vuhcedificioTrabajo, vuhcentradaTrabajo, vnumerodependientes,vpersonastrabajan, vcausasitesp,vcausasitespaux, iPuntuacion, vopcionpuesto,
 vflaguhy, vuhymanzana, vuhyotros, vuhyandador, vuhyetapa, vuhylote, vuhyedificio, vuhyentrada, vcveproducto, vSistsegsocial, vTiposueldoext, vNumEmps,
 vSubopcionpuesto, vPuestoext, vOpcionpuestoext, vNumEmpsext, vSubopcionpuestoext, sPropNegocio, sParceles, sParAltoRiesgo, sParPrestamo, vtiporeposicion,
 vnegocio, vsubnegocio, sFlagTestParam, sFlagCapCobranza, iFlagLineaCredEsp, sFlagCapHuella,vingresomensual,vuhymanzanaref1,vuhymanzanaref2,vuhyotrosref1,
 vuhyotrosref2,vuhyandadorref1,vuhyandadorref2,vuhyetaparef1,vuhyetaparef2,vuhyloteref1,vuhyloteref2,vuhyedificioref1,vuhyedificioref2,vuhyentradaref1,
 vuhyentradaref2,vuhymanzanatmp,vuhyotrostmp,vuhyandadortmp,vuhyetapatmp,vuhylotetmp,vuhyedificiotmp,vuhyentradatmp,cflaguhtconyugue,cflaguhtref1,
 cflaguhtref2,sFlag_altadirecta_asupervisar,sNuevo_puntajefinal,vcausasitesp_resp SMALLINT;
DEFINE vcte_ref,vcte_refcop,vcte_refcop2,vlugartrabajo,vcteconyuge,vlugartrabajoconyuge,vcteref, vnumcte , vcteref2, ccteConyugebcpl, ccteref1bcpl ,
 ccteref2bcpl,cctebcpltmp,vctetmp, vfolio , vnumsolcred, cNumSolRef, vNumCteProspecto CHAR(20);
DEFINE vnombre1,vnombre2,vapell_paterno,vapell_materno, vnombreunoconyuge,vnombredosconyuge,vApellPatCony,vApellMatCony,vnombre1ref,  vnombre2ref,
 vApellPatRef, vApellMatRef,vnombre1ref2, vnombre2ref2, vApellPatRef2, vApellMatRef2,cApellCasada,vnombreunotmp,vnombredostmp,vApellPattmp,vApellMattmp CHAR(26);
DEFINE vciudad,vciudadtmp,vcolonia,vcoloniatmp,vcalle,vciudadTrabajo, vcoloniaTrabajo, vcalleTrabajo, vpersonasvivenendomicilio,vextensiontrabajo,
vciudadconyuge, vcoloniaconyuge, vcalletrabajoconyuge, vflagactualizacion, vref2, vref3, vefectuo,vEfectuoAP,vEfectuoRTOS, vreposicion, vEmpautorizo,
 vfolioanterior, iEmpSubCob, iMontoIngMensual,  iCapSistematicabono, iTopeAbonoCoppel, iLineaCrediTope, iCapMaximaAbono, iCapRealAbono, iLineaCredReal,
 iCompromisosSic, vlimitecredito, iSqlErr, iValor, inumSecuencia, iElemento, vciudadbanco, vcoloniabanco,vciudadbancotmp,vcoloniabancotmp,iContReg, iRowId,
 vfoliotienda,iRefSecusConyugue,iRefSecuencias1,iRefSecuencias2, iGrupo, iTopeMax,vciudadref1,vciudadref2,vcoloniaref1,vcoloniaref2,vcalleref1,
 vcalleref2,vcalletrabajotmp,iSecuenciatmp,iRefSecustmp, iParAltoRiesgoNvo, iPagoUlt12meses, iId_Situaciones, iPuntos_Var_Param,
 iPuntos_Var_SIC, iScore_domicilio INTEGER;
DEFINE iIngreso DECIMAL(18,2);
DEFINE vdeptointerior,vdeptoointeriorconyuge,vdeptointeriorTrabajo,vfolioaut,cNumInterior, cFolioSucursal, vdeptointeriorref1,
vdeptointeriorref2,vdeptoointeriortmp,vtiendafolio, vtdafolioant,vtienda CHAR(4);
DEFINE vcomplemento,vcomplementotrab,vcomplementocony,vcomplementoref1,vcomplementoref2,vcomplementotmp CHAR(80);
DEFINE ventrecalles, ventrecallesconyuge,ventrecallesTrabajo,ventrecallestmp, ventrecallesref1,ventrecallesref2  CHAR(40);
DEFINE vtel, vtelcel,vteltrabajo,vteltrabajoconyuge,vtelcelconyuge,vtelcelref1,vtelcelref2,iEmpGteAutori,vteltrabajotmp,vtelceltmp,vtelreftmp,vteltrabajoref1,
vteltrabajoref2,iNumerocasa,iNumerocasaTrabajo,iNumerocasaconyuge,iNumerocasaref1,iNumerocasaref2,iNumerocasatmp INT8;
DEFINE dFechaConsBuro,vfechanacimiento,vfechaltacte, vFecha_Hoy,dFechaAlta, dfechaaltacte DATE;
DEFINE vniptitular, vnipadicional  CHAR(7);
DEFINE vcveburo,cMarcarConsultado,cFlagConsBuro,vTipo_Dir,cMarcaHit, vcveidentificacion, cStatus, cStatusbcpl, cStatusbcplaux CHAR(2);
DEFINE cfechanac, cfechadecuandovive, cFechAntigTrab,vfolioconcir,cFechaConsBuro,cFecha_hoy CHAR(10);
DEFINE vcurp,vcveelector CHAR(18);
DEFINE videntificacion,cEmpGteAutori CHAR(8);
DEFINE vrfc CHAR(13);
DEFINE vfolioconsulta CHAR(9);
DEFINE cfechamovto CHAR (19);
DEFINE vTipoProducto CHAR(5);
DEFINE cNacionalidad,cPais,cEstado,cDelegMunicip, cMotivobcpl CHAR(3);
DEFINE cObservs char(80);
DEFINE iBandera INTEGER;
DEFINE cNoIMSS CHAR(12);
DEFINE cDescripElemento CHAR(50);
DEFINE vCodRetorno Char(6);
DEFINE bBorrado BOOLEAN;



--DSB20180403
DEFINE cSolicAnt, viNomCteCppl, vNomCteCppl CHAR(20); 
DEFINE bNuevaSolic BOOLEAN;
DEFINE iSkip, iCuantasOS, vCausaSitEspOS, iFolioIns, vAltaMasiva INTEGER;
DEFINE vVigencia, iCntAdiccoppel, iP41, iSitEspAux, iExtRelBcpCpl, tmpCauEsp, bEsCtePros, viCuantasOS, viRevisionCac, iVerifAltaDirecta, vcausasitespPrmtrco/* , viFlagCliente_Pros */ SMALLINT;
DEFINE vFolioOS, vSecuenciaOS CHAR(20);
DEFINE cFechaEntradaEE DATE;
DEFINE vStatusOS, vSitEspOS, tmpSitEsp, vsitespPrmtrco CHAR(1);
DEFINE vNumTienda CHAR(4);
DEFINE vCausaSolic CHAR(3);
DEFINE vStatusCtePros, tmpSolicRT CHAR(2);
--DSB20180411
DEFINE iStatusNoOS SMALLINT;
--DSB20180507
DEFINE iNumSolic SMALLINT;
--DSB20180622
DEFINE biSecuencia INTEGER;
DEFINE bcNumCte CHAR;
--DSB20180815 TIPOORIGEN
DEFINE iSolMov SMALLINT;
-- DSB 2020/03/24
DEFINE cFlagProductoCoppel CHAR(1);
DEFINE sNum_producto_bco					SMALLINT;					--RTV-FOLIO 532
DEFINE cStatus_solicitud_bco				CHAR(2);					--RTV-FOLIO 532
DEFINE dMonto_lc_bco						DECIMAL(18,2);				--RTV-FOLIO 532
DEFINE dtFecha_resp_bco						DATETIME YEAR TO SECOND;	--RTV-FOLIO 532
DEFINE cOrigenSolic							CHAR(1);					--RQM-598.1
DEFINE cGpoEval								CHAR(1);					--RQM-598.1
DEFINE cGpoHit								CHAR(1);					--RQM-598.1
DEFINE dtFechaHoy							DATE;						--RQM-598.1
DEFINE cNumSolicMixta						CHAR(20);
DEFINE sExiste          SMALLINT;
DEFINE cflag_motoscoppel CHAR(1); ---RQM 09 541-2 credito Motos Coppel en Alta unica 06/04/2021
DEFINE cCtepresento_comping CHAR(1); --RQM 09 541-2 credito Motos Coppel en Alta unica 06/04/2021
DEFINE cSucursalSol CHAR(4);


LET iRefSecusConyugue=0;LET iRefSecuencias1 =0;LET iRefSecuencias2 =0;LET vcve = ''; LET vcaja = 100;LET varea = 'N';LET vcte_ref = '0';
LET vcte_refcop = '0'; LET vcte_refcop2 ='0';LET vnombre1 = '';LET vnombre2 = '';LET vapell_paterno = '';LET vapell_materno = '';LET vcurp = '';
LET vcveelector = '';LET vcveidentificacion = '';LET videntificacion = '';LET vciudad = 0;LET vcolonia = 0;LET vcalle = 0;LET iNumerocasa = 0;
LET vdeptointerior = '';LET vrumbo = '';LET vcomplemento = '';LET ventrecalles = '';
LET vuhcmanzana = 0;LET vuhcotros = 0;LET vuhcandador = 0;LET vuhcetapa = 0;LET vuhclote  = 0;LET vuhcedificio = 0;LET vuhcentrada = 0;LET vtel = 0;
LET vtelcel = 0;LET vcasapropia = '';LET vniptitular = '';LET vnipadicional = '';LET vsexo = '';LET vestadocivil = '';LET cfechanac = '1900/01/01';
LET cfechadecuandovive = '1900/01/01';LET vpersonasvivenendomicilio = 0;
LET vescolaridad = '';LET vtiposueldo = '';LET vnumerodependientes = 0;LET vpersonastrabajan = 0;LET vingresomensual = 0;
LET vsitesp = '';LET vsitespaux = ''; LET vcausasitesp = 0;LET vcveautRT = '2';LET vATsupervisadoRT = 'P';LET vctenuevo = 'N';LET vcreditojoven = '';LET vsitesp_resp = '';
LET vcausasitesp_resp = 0; LET vcausasitespaux = 0;
LET vpuesto = '0';LET vopcionpuesto = 0;LET cFechAntigTrab = '1900/01/01';
LET vmarcadatosin = '';LET vtiporeposicion = 0;LET vreposicion = 0;LET vflagentregotarjeta = '';
LET vefectuo = 0; LET vEfectuoRTOS=0; LET vEfectuoAP=0; LET vtiendafolio = '0';LET vfolio = '0';LET dfechaaltacte = DATE(1);LET vflagnoreconocehuella = '';
LET vfoliotienda = 0;LET vrfc = '';LET vcveburo = '';LET vfolioaut = '';LET vfolioconsulta = '';LET vfolioconcir = '';LET vnegocio = 0;LET vsubnegocio = 0;
LET vEmpautorizo = 0;LET vtipo = '';LET cfechamovto = '1900/01/01 01:00:00';
LET vnumsolcred = '';LET vnumcte = '';LET vtdafolioant = '0';LET vfolioanterior = 0;LET vcveproducto = 6500;LET vflagactualizacion = 0;LET vSistsegsocial = 0;LET vTiposueldoext = 0;
LET vNumEmps = 0;LET vSubopcionpuesto = 99;LET vPuestoext = 0;LET vOpcionpuestoext = 0;LET vNumEmpsext = 0;LET vSubopcionpuestoext = 0;LET vTipoOrigen = 'G';LET vTipoProducto = '01000';LET iEmpSubCob = 0;LET sFlagCapHuella = 1;LET cMarcarConsultado = '';LET sFlagCapCobranza = 0;LET iEmpGteAutori = 0;LET cEmpGteAutori ='';LET cFlagConsBuro = '';LET cBuroPilotoTestig = '';LET cNacionalidad = '';LET cNoFm3 = '';LET cEmail = '';LET cApellCasada = '';
LET cPais = '';LET cNoIMSS = '';LET cEstado = '';LET cDelegMunicip = '';LET cNumInterior = '';LET sPropNegocio = 0;LET cModeloCel = '1';LET dFechaConsBuro = DATE(1);LET cFechaConsBuro = '';
LET ccteConyugebcpl = '';
LET ccteref1bcpl = '';LET ccteref2bcpl = '';LET cFolioSucursal = '0'; LET cflaguht = '';
LET vfechanacimiento = DATE(1);LET vfechaltacte = DATE(1); LET cUnidadHabit = '';LET vTipo_Dir = '';
LET vFecha_Hoy = DATE(1);LET vCodRetorno = '000000';LET dFechaAlta = DATE(1);LET iValor = 0;LET iTopeMax=0;LET iIngreso = 0;LET cFecha_hoy = '1900/01/01';LET inumSecuencia= 0;
LET cMarcaHit = '';LET iElemento = 0;LET vciudadbanco = 0;LET vcoloniabanco = 0;LET cDescripElemento = '';LET iContReg = 0;LET cStatus = ''; LET iRowId = 0;
LET cNumSolRef=''; LET cTipRechazoOs='';
LET vciudadtmp=0; LET vcoloniatmp=0;LET vciudadbancotmp=0;LET vcoloniabancotmp=0; LET vcalletrabajotmp=0; LET iNumerocasatmp=0;LET vdeptoointeriortmp=''; LET vrumbotrabtmp='';
LET vcomplementotmp='';LET ventrecallestmp=''; LET vuhymanzanatmp=0; LET vuhyotrostmp=0; LET vuhyandadortmp=0; LET vuhyetapatmp=0; LET vuhylotetmp=0; LET vuhyedificiotmp=0; LET vuhyentradatmp=0;
LET vteltrabajotmp=0; LET vtelceltmp=0; LET vtelreftmp=0; LET iSecuenciatmp=0;LET cctebcpltmp='0';
LET vctetmp='0';LET vnombreunotmp='';LET vnombredostmp='';LET vApellPattmp='';LET vApellMattmp='';LET vcvefamiliatmp='';LET cSexoConyugetmp='';LET iRefSecustmp=0;LET cflaguhtconyugue=0; LET vtienda='0'; LET cStatusbcpl= '';
LET cStatusbcplaux= '';LET cMotivobcpl='';LET cFlagProspecto='1';LET iParAltoRiesgoNvo=-99999;LET iPagoUlt12meses=99999;
LET bBorrado = 'F';LET vvigenciacliente = ''; LET cObservs = '';
LET cflag_motoscoppel='0'; --RQM 09 541-2 credito Motos Coppel en Alta unica 06/04/2021
LET cCtepresento_comping=''; --RQM 09 541-2 credito Motos Coppel en Alta unica 06/04/2021



--DSB20180403
LET cSolicAnt = ''; LET vSitEspOS = ''; LET vCausaSolic = ''; LET tmpSitEsp = ''; LET tmpSolicRT = ''; LET vStatusCtePros = ''; 
LET vsitespPrmtrco = '';
LET bNuevaSolic = 'f';
LET iSkip = 0; LET iCuantasOS = 0; LET vCausaSitEspOS = 0; LET iCntAdiccoppel = 0; LET iP41 = 0; LET iSitEspAux = 0; LET iExtRelBcpCpl = 0; 
LET iFolioIns = 0; LET viCuantasOS = 0; LET tmpCauEsp = 0; LET bEsCtePros = -1; LET vAltaMasiva = 0; LET viRevisionCac = 0; 
LET iVerifAltaDirecta = 0; LET vcausasitespPrmtrco = 0; /* LET viFlagCliente_Pros = 0; */
LET vFolioOS = '0'; LET vSecuenciaOS = '0'; LET viNomCteCppl = '0'; LET vNomCteCppl = '0'; LET vNumTienda = '0';
LET cFechaEntradaEE = DATE(1);
LET vStatusOS = 'P'; 
LET vVigencia = -1;
--DSB20180411
LET iStatusNoOS = 0;
--DSB20180507
LET iNumSolic = 0;
--DSB20180622
LET biSecuencia = 0;
LET bcNumCte = '';
LET iBandera = 0;

--DSB20180815 TIPOORIGEN
LET iSolMov = 0;
LET cFlagProductoCoppel = NULL;
--RQM-598.1 SE INICIALIZAN VARIABLES PARA QUE NO MARQUE ERROR -696
LET iRefSecuencias1 =0; LET iRefSecuencias2 =0;LET iRefSecusConyugue=0;
LET vciudadTrabajo=0; LET vcoloniaTrabajo=0;LET vcalleTrabajo=0; LET iNumerocasaTrabajo=0;LET vdeptointeriorTrabajo='';LET vrumbotrab='';
LET vcomplementotrab=''; LET ventrecallesTrabajo='';LET cUnidadHabitTrabajo='0';LET vuhcmanzanaTrabajo=0;LET vuhcotrosTrabajo=0;
LET vuhcandadorTrabajo=0;LET vuhcetapaTrabajo=0;LET vuhcloteTrabajo=0;LET vuhcedificioTrabajo=0;LET vuhcentradaTrabajo=0;LET vlugartrabajo = '';
LET vcomplementotrab = ''; LET vteltrabajo = 0;LET vextensiontrabajo = 0;  
LET vcteconyuge = '0';LET vnombreunoconyuge = '';LET vnombredosconyuge = '';LET vApellPatCony = '';LET vApellMatCony = '';LET cSexoConyuge = '';
LET vlugartrabajoconyuge = '';LET vciudadconyuge = 0;LET vcoloniaconyuge = 0;LET vcalletrabajoconyuge = 0;LET iNumerocasaconyuge = 0;
LET vdeptoointeriorconyuge = '';LET vrumbotrabcony = '';LET vcomplementocony = 'E';LET ventrecallesconyuge = '';LET vflaguhy = 0;
LET vuhymanzana = 0;LET vuhyotros = 0;LET vuhyandador  = 0;LET vuhyetapa = 0;LET vuhylote = 0;LET vuhyedificio = 0;LET vuhyentrada = 0;
LET vteltrabajoconyuge = 0;LET vtelcelconyuge = 0;LET vcveconyugefamilia = '';LET vcteref = '0';LET vnombre1ref = '';LET vnombre2ref = '';
LET vApellPatRef = '';LET vApellMatRef = '';LET cSexoref = '';LET vcveref1 = '';LET vcteref2 = '0';LET vnombre1ref2 = '';LET vnombre2ref2 = '';
LET vApellPatRef2 = '';LET vApellMatRef2 = '';LET cSexoref2 = '';LET vcveref2 = '';LET vref2 = 0;LET vref3 = 0;LET vciudadref1=0;
LET vciudadref2=0;LET vcoloniaref1=0;LET vcoloniaref2=0;LET vcalleref1=0;LET vcalleref2=0;LET iNumerocasaref1=0;LET iNumerocasaref2=0;
LET vdeptointeriorref1='';LET vdeptointeriorref2='';LET vrumboref1='';LET vrumboref2='';LET vcomplementoref1='E';LET vcomplementoref2='E';
LET ventrecallesref1='';LET ventrecallesref2='';LET cflaguhtref1='';LET cflaguhtref2='';LET vuhymanzanaref1=0;LET vuhymanzanaref2=0;
LET vuhyotrosref1=0;LET vuhyotrosref2=0;LET vuhyandadorref1=0;LET vuhyandadorref2=0;LET vuhyetaparef1=0;LET vuhyetaparef2=0;LET vuhyloteref1=0;
LET vuhyloteref2=0;LET vuhyedificioref1=0;LET vuhyedificioref2=0;LET vuhyentradaref1=0;LET vuhyentradaref2=0;LET vteltrabajoref1=0;
LET vteltrabajoref2=0;LET vtelcelref1=0;LET vtelcelref2=0;LET iSecuenciaref1='';LET iSecuenciaref2=''; LET vNumCteProspecto='';
LET cflaguhtconyugue = 0; LET iFolioIns = 0; LET vfolioanterior = 0; LET vtdafolioant='0'; LET vEfectuoAP=0;					LET vsitespPrmtrco = ''; LET vcausasitespPrmtrco = 0; LET iRowId = -1;
LET iMontoIngMensual = 0; LET iCapSistematicabono = 0; LET iTopeAbonoCoppel = 0; LET iLineaCrediTope = 0; LET iCapMaximaAbono = 0; LET iCapRealAbono = 0; LET iLineaCredReal = 0; LET iCompromisosSic = 0; LET iFlagLineaCredEsp = 0; LET vlimitecredito = 0; LET iPuntuacion = 0; LET cTipRechazo=''; LET iId_Situaciones= 0; LET cPuntualidad_ref1= ''; LET cPuntualidad_ref2= ''; LET sFlagTestParam = 0; LET sFlag_altadirecta_asupervisar= 0; LET iPuntos_Var_Param= 0; LET iPuntos_Var_SIC= 0; LET iScore_domicilio= 0; LET sNuevo_puntajefinal= 0; LET sParceles = 0; LET sParAltoRiesgo = 0; LET sParPrestamo = 0;

LET sNum_producto_bco				= 0;						--RTV-FOLIO 532
LET cStatus_solicitud_bco			= '';						--RTV-FOLIO 532
LET dMonto_lc_bco					= 0.00;						--RTV-FOLIO 532
LET dtFecha_resp_bco				= DATE(1);					--RTV-FOLIO 532
LET pempresa 						= TRIM(NVL(pempresa,''));	--RQM-598.1
LET cOrigenSolic					= '0';						--RQM-598.1
LET cGpoEval						= '0';						--RQM-598.1
LET cGpoHit							= '0';						--RQM-598.1
LET dtFechaHoy						= DATE(1);
LET cNumSolicMixta					= '';
LET sExiste         = 0;
LET cSucursalSol = '';

BEGIN
	ON EXCEPTION
	SET iSqlErr
		LET vnumsolcred = vnumsolcred;
		--SET DEBUG FILE TO '/resplogifx/archivoscartera/altaunica/envios/pruebas_batch.out';
		--TRACE ON;
		
		IF iSqlErr <> 0 THEN
			LET vCodRetorno = iSqlErr;
            INSERT INTO "informix".si_bitacora_errorbatch (numerosolicitud,numcte,error,observaciones,trama,fecha_insert) 
			VALUES (vnumsolcred,vnumcte,iSqlErr,cObservs,'',NVL(vFecha_Hoy,DATE(1)));
			RETURN vCodRetorno;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO "/tmp/sp_batch_generarinformacion.out";
	--TRACE ON;
		
	IF pFechaAct <> MDY(1,1,1900) OR pFechaAct IS NOT NULL THEN
		
		LET vFecha_Hoy = pFechaAct;
		IF vFecha_Hoy = MDY(1,1,1900) OR vFecha_Hoy IS NULL THEN
			LET vCodRetorno = '000002'; LET iContReg = 2;
		ELSE
			LET cObservs = TRIM('Paso 1');
			SELECT FIRST 1 secuencia INTO biSecuencia FROM bdinteg:"informix".si_tramasbatch WHERE fecha_insert <> vFecha_Hoy;
			IF NVL(biSecuencia,0) <> 0 THEN --DSB20180622 Se quita IF EXISTS --DSB20180403 { 
                         SELECT COUNT(tabid)
                           INTO sExiste
                         FROM systables
                         WHERE tabname = "si_tramasbatch";

                         --## IF sExiste > 0 THEN
	                     --## TRUNCATE TABLE si_tramasbatch;
                         --## END IF;

			--- TRUNCATE TABLE bdinteg:"informix".si_tramasbatch;

			END IF;																												-- }
			LET cObservs = TRIM('Paso 1a');
			LET bBorrado = 'T';
            DELETE FROM bdinteg:"informix".si_bitacora_errorbatch WHERE numerosolicitud = numerosolicitud and numcte = numcte and fecha_insert <> vFecha_Hoy;
			LET cObservs = TRIM('Paso 1b');
			SELECT secuencia_max INTO inumSecuencia FROM bdinteg:"informix".si_archivosecuenciamax where empresa = pempresa and secuencia_max = secuencia_max;
			LET cObservs = TRIM('Paso 1c');
			SELECT valor INTO iValor FROM bdisolic:"informix".ss_param WHERE secuencia = 363;
			LET cObservs = TRIM('Paso 1d');
			SELECT valor INTO iTopeMax FROM bdisolic:"informix".ss_param WHERE secuencia = 373;
			LET cObservs = TRIM('Paso 1e');
			-- DSB20180403 {
			FOREACH WITH HOLD
				SELECT TRIM(sss.num_solicitud) as num_solic, sss.numcte, ssa.fecha_entrada, sss.sucursal, sss.fecha_insert,
				ssa.status_solicitud,ssa.ejecutivo_auto, sss.user_insert, ssa.fecha_hora,
				ssa.causa_solicitud, ssa.revision_cac, sss.factor_techo,sss.factor_piso,sss.tasa_piso --, ssa.cliente_pros
				INTO vnumsolcred, vnumcte, vfechaltacte, cFolioSucursal, dFechaAlta,cStatus, cEmpGteAutori,vEfectuoRTOS, cfechamovto, vCausaSolic,
				viRevisionCac, cFlagProductoCoppel,cflag_motoscoppel,cCtepresento_comping--, viFlagCliente_Pros
				FROM bdisolic:"informix".ss_autorizacion ssa
				INNER JOIN bdisolic:"informix".ss_solicitudes sss on (sss.empresa = ssa.empresa AND sss.num_solicitud = ssa.num_solicitud)
				WHERE  ssa.fecha_entrada =  pFechaAct
				AND sss.num_producto = '6500'
				--AND ssa.num_solicitud MATCHES '65*' -- Se comenta para optimizar el SP
				ORDER BY num_solic,ssa.fecha_hora
				
				let cSucursalSol = '';
				
				IF cFolioSucursal = '8503' THEN
					--Se agrega la consulta de sucursal y subcanal para validar que sea 8503 y verificar si viene por un subcanal
					SELECT NVL(sucursal_fisica,'')
					INTO cSucursalSol  
					FROM bdisolic:"informix".ss_prospecteo_solicitudes 
					WHERE empresa = pEmpresa 
					AND num_solicitud = vnumsolcred;
					
					IF cSucursalSol <> '' THEN
						LET cFolioSucursal = cSucursalSol;
					END IF;
					
				END IF;
				
				--Se realiza el trim a la variable para que no se haga en el query
				LET vnumsolcred = TRIM(vnumsolcred);
				
				--Se optimizan las consultas para que sean por indices
				
				--Se valida el origen de la solicitud DSB IDUG INICIA
				SELECT count(numcte) 
				INTO iNumSolic 
				FROM bdisolic:"informix".ss_solicitudes 
				WHERE numcte = vnumcte
				AND num_solicitud = vnumsolcred;
				
				--Se valida que la solicitud sea mÃ³vil
				SELECT count(numcte) 
				INTO iSolMov 
				FROM bdinteg:"informix".si_solicitud_movil 
				WHERE numcte = vnumcte
				AND num_tdc_coppel = vnumsolcred;
				
				IF iNumSolic <> 0 THEN
					LET vTipoOrigen = 'G';
					IF iSolMov <> 0 THEN
						LET vTipoOrigen = 'M';
					END IF;
				ELSE
					LET vTipoOrigen = 'N';
				END IF; 
				
				LET cObservs = TRIM('Paso 2');
				LET bNuevaSolic = 'f';
				LET cFechaEntradaEE = DATE(1);
				IF vnumsolcred <> cSolicAnt THEN
					LET cObservs = TRIM('Paso 2a');
					LET bNuevaSolic = 't';
					LET iSkip = 0; LET iCuantasOS = 0;
					LET cSolicAnt = vnumsolcred;
					LET vStatusOS = ''; LET vFolioOS = '0';
					LET viCuantasOS = -1;
				END IF;
				LET cObservs = TRIM('Paso 3');
				IF cStatus NOT IN ('PC','BC','EC') THEN --Se agrega para optimizar SP
					LET iStatusNoOS = 1;
				ELSE
					LET iStatusNoOS = 0;
				END IF;
				IF viCuantasOS < 0 AND iStatusNoOS = 1 THEN
					LET cObservs = TRIM('Paso 3a');
					SELECT COUNT(num_solicitud) INTO viCuantasOS 
					FROM bdisolic:"informix".ss_solicitud_os 
					WHERE empresa = pempresa AND num_solicitud = vnumsolcred AND fecha_solicitud <= vfechaltacte;
				END IF;
				LET cObservs = TRIM('Paso 4');
				IF (bNuevaSolic = 't' OR cStatus = 'EE') AND viCuantasOS > 0 THEN
					LET cObservs = TRIM('Paso 4a');
					IF cStatus <> 'EE' THEN
						LET cObservs = TRIM('Paso 4b');
						IF iStatusNoOS = 1 THEN
							LET cObservs = TRIM('Paso 4c');
							SELECT MAX(fecha_entrada)
							INTO cFechaEntradaEE
							FROM bdisolic:"informix".ss_autorizacion
							WHERE num_solicitud = vnumsolcred AND status_solicitud = 'EE'AND fecha_hora <= cfechamovto;
						END IF;
					ELSE
						LET cObservs = TRIM('Paso 4d');
						LET cFechaEntradaEE = vfechaltacte;
					END IF;
				END IF;
				LET cObservs = TRIM('Paso 5');
				IF NVL(cFechaEntradaEE, DATE(1)) = DATE(1) AND cStatus IN('OS','AT','AP','RT','CN','OA') AND viCuantasOS > 0 AND vFolioOS = '0' THEN
					LET cObservs = TRIM('Paso 5a');
					IF cStatus = 'OS' THEN
						LET cObservs = TRIM('Paso 5b');
						LET cFechaEntradaEE = vfechaltacte;
					ELSE
						LET cObservs = TRIM('Paso 5c');
						IF viCuantasOS = 1 THEN
							LET cObservs = TRIM('Paso 5d');
							SELECT FIRST 1 fecha_solicitud INTO cFechaEntradaEE
							FROM bdisolic:"informix".ss_solicitud_os
							WHERE num_solicitud = vnumsolcred;
						ELSE
							LET cObservs = TRIM('Paso 5e');
							SELECT MAX(fecha_entrada)
							INTO cFechaEntradaEE
							FROM bdisolic:"informix".ss_autorizacion
							WHERE num_solicitud = vnumsolcred AND status_solicitud = 'EC' AND fecha_hora <= cfechamovto;
						END IF;
					END IF;
				END IF;
				
				LET cObservs = TRIM('Paso 6');
				IF NVL(cFechaEntradaEE, DATE(1)) <> DATE(1) THEN
					LET cObservs = TRIM('Paso 6a');
					FOREACH
						SELECT status, secuenciaos, situacionespecialrespuesta, causasituacionespecialrespuesta --secuenciaos DSB20180410 Se agrega para que en esta consulta se traiga la informacion del registro
						INTO vStatusOS, vFolioOS, vSitEspOS, vCausaSitEspOS
						FROM bdisolic:"informix".ss_solicitud_os
						WHERE empresa = pempresa AND num_solicitud = vnumsolcred AND fecha_solicitud = cFechaEntradaEE
							LET iCuantasOS = iCuantasOs + 1;
					END FOREACH;
					LET cObservs = TRIM('Paso 6b');
					IF iCuantasOS = 0 AND viCuantasOS = 1 THEN
						LET cObservs = TRIM('Paso 6c');
						SELECT FIRST 1 fecha_solicitud INTO cFechaEntradaEE
						FROM bdisolic:"informix".ss_solicitud_os
						WHERE num_solicitud = vnumsolcred;
						LET iCuantasOS = 1;
					END IF;
				ELSE
					LET cObservs = TRIM('Paso 6d');
					LET iCuantasOS = 0;
				END IF;
				
				LET cObservs = TRIM('Paso 7');
				IF iCuantasOS = 0 THEN
					IF bNuevaSolic = 't' THEN
						LET vFolioOS = '0'; LET cTipRechazoOs  = ''; LET vsitesp_resp = ''; LET vcausasitesp_resp = 0;
					END IF;
				ELIF iCuantasOS = 1 AND NVL(vFolioOS,'') = '' THEN --DSB20180410 Se agrega validacion de vFolioOS para que entre solo si en el foreach de arriba no hubo informacion
					LET cObservs = TRIM('Paso 7a');
					SELECT FIRST 1 status, secuenciaos, situacionespecialrespuesta, causasituacionespecialrespuesta
					INTO vStatusOS, vFolioOS, vSitEspOS, vCausaSitEspOS
					FROM bdisolic:"informix".ss_solicitud_os
					WHERE empresa = pempresa AND num_solicitud = vnumsolcred AND fecha_solicitud = cFechaEntradaEE;				ELIF iCuantasOS > 1 THEN --DSB20180410 Se modifica para que solo entre en caso de que haya 2 o mas el mismo dia
					LET cObservs = TRIM('Paso 7b');
					SELECT SKIP iSkip FIRST 1 status, secuenciaos, situacionespecialrespuesta, causasituacionespecialrespuesta
					INTO vStatusOS, vFolioOS, vSitEspOS, vCausaSitEspOS
					FROM bdisolic:"informix".ss_solicitud_os
					WHERE empresa = pempresa AND num_solicitud = vnumsolcred AND fecha_solicitud = cFechaEntradaEE;
					LET iSkip = iSkip + 1;
				END IF;
				LET cObservs = TRIM('Paso 8');
				IF vStatusOS = DECODE(cStatus,'OA','D','AT','A','AP','A','RT','R') THEN
					LET cObservs = TRIM('Paso 8a');
					LET vATsupervisadoRT = vStatusOS; LET vfolio = vFolioOS; LET cTipRechazoOs  = vStatusOS; 
					/* IF viFlagCliente_Pros = 2 AND cStatus IN ('OA','RT') THEN  ** Por si solicitan que quieren las OA con causa/situacion **
						SELECT situacionespecialrespuesta, causasituacionespecialrespuesta 
						INTO vSitEspOS, vCausaSitEspOS
						FROM bdiprospectos:"informix".pr_solicitud_os 
						WHERE secuenciaos = vFolioOS;
					END IF; */
					LET cObservs = TRIM('Paso 8b');
					LET vsitesp_resp = vSitEspOS;
					LET vcausasitesp_resp = vCausaSitEspOS;
				ELSE
					LET cObservs = TRIM('Paso 8c');
					LET vATsupervisadoRT = DECODE(cStatus,'OS','P','PA','A',''); LET vfolio = vFolioOS;
					LET cTipRechazoOs  = vStatusOS;
				END IF;
				-- }
				
				LET cObservs = TRIM('Paso 9');
				--DSB20180403 Defaults
				LET vtipo = 'A'; LET dfechaaltacte = DATE(1); LET inumSecuencia = inumSecuencia + 1; LET sFlagCapCobranza = 0;
				LET vtiendafolio='0'; LET vtienda='0'; LET vcte_refcop2 ='0'; LET vcte_refcop='0'; LET vcte_ref = "0"; --LET vEfectuoRTOS=0; --DSB20180621
				LET iVerifAltaDirecta = 0;
				LET cObservs = TRIM('Paso 9a');
				IF bNuevaSolic = 't' THEN     --DSB20180403
					LET cObservs = TRIM('Paso 9b');
					LET cflaguhtconyugue = 0; LET iFolioIns = 0; LET vfolioanterior = 0; LET vtdafolioant='0'; LET vEfectuoAP=0;					LET vsitespPrmtrco = ''; LET vcausasitespPrmtrco = 0; LET iRowId = -1;
					LET iMontoIngMensual = 0; LET iCapSistematicabono = 0; LET iTopeAbonoCoppel = 0; LET iLineaCrediTope = 0; LET iCapMaximaAbono = 0; LET iCapRealAbono = 0; LET iLineaCredReal = 0; LET iCompromisosSic = 0; LET iFlagLineaCredEsp = 0; LET vlimitecredito = 0; LET iPuntuacion = 0; LET cTipRechazo=''; LET iId_Situaciones= 0; LET cPuntualidad_ref1= ''; LET cPuntualidad_ref2= ''; LET sFlagTestParam = 0; LET sFlag_altadirecta_asupervisar= 0; LET iPuntos_Var_Param= 0; LET iPuntos_Var_SIC= 0; LET iScore_domicilio= 0; LET sNuevo_puntajefinal= 0; LET sParceles = 0; LET sParAltoRiesgo = 0; LET sParPrestamo = 0;
					
					LET cObservs = TRIM('Paso 9c'); LET iRefSecuencias1 =0; LET iRefSecuencias2 =0;LET iRefSecusConyugue=0;
					LET vciudadTrabajo=0; LET vcoloniaTrabajo=0;LET vcalleTrabajo=0; LET iNumerocasaTrabajo=0;LET vdeptointeriorTrabajo='';LET vrumbotrab='';
					LET vcomplementotrab=''; LET ventrecallesTrabajo='';LET cUnidadHabitTrabajo='0';LET vuhcmanzanaTrabajo=0;LET vuhcotrosTrabajo=0;
					LET vuhcandadorTrabajo=0;LET vuhcetapaTrabajo=0;LET vuhcloteTrabajo=0;LET vuhcedificioTrabajo=0;LET vuhcentradaTrabajo=0;LET vlugartrabajo = '';
					LET vcomplementotrab = ''; LET vteltrabajo = 0;LET vextensiontrabajo = 0;  
					LET vcteconyuge = '0';LET vnombreunoconyuge = '';LET vnombredosconyuge = '';LET vApellPatCony = '';LET vApellMatCony = '';LET cSexoConyuge = '';
					LET vlugartrabajoconyuge = '';LET vciudadconyuge = 0;LET vcoloniaconyuge = 0;LET vcalletrabajoconyuge = 0;LET iNumerocasaconyuge = 0;
					LET vdeptoointeriorconyuge = '';LET vrumbotrabcony = '';LET vcomplementocony = 'E';LET ventrecallesconyuge = '';LET vflaguhy = 0;
					LET vuhymanzana = 0;LET vuhyotros = 0;LET vuhyandador  = 0;LET vuhyetapa = 0;LET vuhylote = 0;LET vuhyedificio = 0;LET vuhyentrada = 0;
					LET vteltrabajoconyuge = 0;LET vtelcelconyuge = 0;LET vcveconyugefamilia = '';LET vcteref = '0';LET vnombre1ref = '';LET vnombre2ref = '';
					LET vApellPatRef = '';LET vApellMatRef = '';LET cSexoref = '';LET vcveref1 = '';LET vcteref2 = '0';LET vnombre1ref2 = '';LET vnombre2ref2 = '';
					LET vApellPatRef2 = '';LET vApellMatRef2 = '';LET cSexoref2 = '';LET vcveref2 = '';LET vref2 = 0;LET vref3 = 0;LET vciudadref1=0;
					LET vciudadref2=0;LET vcoloniaref1=0;LET vcoloniaref2=0;LET vcalleref1=0;LET vcalleref2=0;LET iNumerocasaref1=0;LET iNumerocasaref2=0;
					LET vdeptointeriorref1='';LET vdeptointeriorref2='';LET vrumboref1='';LET vrumboref2='';LET vcomplementoref1='E';LET vcomplementoref2='E';
					LET ventrecallesref1='';LET ventrecallesref2='';LET cflaguhtref1='';LET cflaguhtref2='';LET vuhymanzanaref1=0;LET vuhymanzanaref2=0;
					LET vuhyotrosref1=0;LET vuhyotrosref2=0;LET vuhyandadorref1=0;LET vuhyandadorref2=0;LET vuhyetaparef1=0;LET vuhyetaparef2=0;LET vuhyloteref1=0;
					LET vuhyloteref2=0;LET vuhyedificioref1=0;LET vuhyedificioref2=0;LET vuhyentradaref1=0;LET vuhyentradaref2=0;LET vteltrabajoref1=0;
					LET vteltrabajoref2=0;LET vtelcelref1=0;LET vtelcelref2=0;LET iSecuenciaref1='';LET iSecuenciaref2=''; LET vNumCteProspecto='';
	  
					LET cObservs = TRIM('Paso 9d');
					LET cStatusbcpl='';
					LET cMotivobcpl='';

					
				END IF;
				
                LET cObservs = TRIM('Paso 10');
				IF bNuevaSolic = 't' THEN --DSB20180403 {
					LET bEsCtePros = 1; LET cObservs = TRIM('Paso 10a');
					SELECT NVL(numcte_pros, ''), NVL(vigencia, -1), NVL(status_numcte_pros, ''), id_empcob
					INTO vNumCteProspecto, vVigencia, vStatusCtePros, vAltaMasiva
					FROM bdiprospectos:"informix".pr_cliente 
					WHERE numcte = vnumcte;
					LET cObservs = TRIM('Paso 10b');
					IF NVL(vNumCteProspecto, '') = '' THEN
						LET bEsCtePros = 0;
					ELSE
						LET cObservs = TRIM('Paso 10b'); LET vAltaMasiva = NVL(vAltaMasiva, 0);
					END IF;
				END IF;
				
                LET cObservs = TRIM('Paso 10c');
				IF vAltaMasiva <> 0 AND bEsCtePros = 1 AND vVigencia = 1 THEN
					LET cObservs = TRIM('Paso 10d');
					LET sFlagCapCobranza = 1;
				END IF;								--}


                LET cObservs = TRIM('Paso 11');
				IF cStatus = "AP"  THEN
					LET cObservs = TRIM('Paso 11a');
					LET iEmpGteAutori = cEmpGteAutori::INT8;LET vcve = 'A';LET vATsupervisadoRT = 'A';
					
					LET iCntAdiccoppel = 0; LET iP41 = 0; LET iSitEspAux = 0; --DSB20180403 {
					FOREACH
						SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(numctecoppel) = "V" THEN numctecoppel::INT8 ELSE 0 END,numctecoppel,sucursal INTO viNomCteCppl,vNomCteCppl,vNumTienda
						FROM bdinteg:"informix".si_adiccoppel
						WHERE empresa = pempresa AND numcte = vnumcte
						ORDER BY secuencia
						LET cObservs = TRIM('Paso 11b'); LET iCntAdiccoppel = iCntAdiccoppel + 1;
						
						IF iCntAdiccoppel = 1 THEN
							LET cObservs = TRIM('Paso 11c');
							LET vcte_refcop2 = viNomCteCppl;
							LET cObservs = TRIM('Paso 11d');
							LET vcte_refcop = vNomCteCppl;
							LET cObservs = TRIM('Paso 11e');
							LET vtienda = vNumTienda;
						ELSE
							LET cObservs = TRIM('Paso 11f');
							IF viNomCteCppl <> vcte_refcop2 THEN
								LET iP41 = 1;
							END IF;
						END IF;
						LET cObservs = TRIM('Paso 11g');
						IF viNomCteCppl <> vNomCteCppl THEN
							LET iSitEspAux = 1;
						END IF;
					END FOREACH;
					
					LET cObservs = TRIM('Paso 11h');
					IF iP41 = 1 OR iCntAdiccoppel = 0 THEN
						LET cObservs = TRIM('Paso 11i');
						SELECT FIRST 1 cliente INTO bcNumCte FROM bdinteg:"informix".si_relacion_ctebcplcpl 
						WHERE numcte_banco = vnumcte AND tipo_relacion=3;
						IF NVL(bcNumCte,'') <> '' THEN --DSB20180622 Se quita IF EXISTS

								LET cObservs = TRIM('Paso 11j');
								LET iExtRelBcpCpl = 1;	
						END IF;
					END IF;
					LET cObservs = TRIM('Paso 12');
					IF iCntAdiccoppel = 0 THEN
						IF iExtRelBcpCpl = 1 THEN
							LET cObservs = TRIM('Paso 12a');
							UPDATE bdisolic:"informix".ss_resum_scor_fin SET situacion_especial='P', causa_situacion=33 WHERE num_solicitud =vnumsolcred;
						END IF;
						LET cObservs = TRIM('Paso 12b');
						SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(numcte_ref) = "V" THEN numcte_ref::INT8 ELSE 0 END INTO vcte_ref FROM bdinteg:"informix".si_cliente WHERE numcte = vnumcte;
						IF NVL(vcte_ref, '') = '' THEN 
							LET cObservs = TRIM('Paso 12c');
							LET vcte_ref=vcte_refcop;
						END IF;
					ELSE 
						LET cObservs = TRIM('Paso 12d');
						LET vcte_ref=vcte_refcop2;
						IF iP41 = 1 THEN
							IF iExtRelBcpCpl = 1 THEN
								IF vsitesp<>'P' AND vcausasitesp<>33 THEN
									LET cObservs = TRIM('Paso 12e');
									UPDATE bdisolic:"informix".ss_resum_scor_fin SET situacion_especial='P', causa_situacion=33 WHERE num_solicitud =vnumsolcred;
									LET vsitesp='P'; LET vcausasitesp=41;
								END IF;
							END IF;
						END IF;
					END IF;														--}
					
							
					LET cObservs = TRIM('Paso 13');
					SELECT fechaasignacion 
					INTO dfechaaltacte 
					FROM bditarjcop:"informix".tarjetasnumtarcop 
					WHERE empresa=pempresa AND numtarjeta = vcte_ref;
					LET cObservs = TRIM('Paso 13a');
					IF dfechaaltacte IS NULL THEN 
						LET dfechaaltacte = vfechaltacte; 
					END IF;
				ELSE 					--** SI NO ES 'AP' **-- DSB20180403 {
					LET cObservs = TRIM('Paso 14');
					LET vtienda=cFolioSucursal;
					LET cObservs = TRIM('Paso 14a');
					LET vEfectuo=vEfectuoRTOS;
					LET cObservs = TRIM('Paso 14b');
					LET iEmpGteAutori = 0;
					--Valida que si la solicitud viene de un subcanal con el canal origen 4 se envia el usuario efectuo la PC
					IF cSucursalSol <> '' AND cStatus ='PC' THEN 
						LET vEfectuo = cEmpGteAutori::INT8;
					END IF;
					IF vfolio <> '0' AND vfolio <> iFolioIns THEN
						LET cObservs = TRIM('Paso 14c');
						IF viCuantasOS > 1 THEN
							SELECT FIRST 1 folio, tiendafolio  INTO vfolioanterior, vtdafolioant
							FROM bdisolic:"informix".ss_osclientesupervisar
							WHERE num_solicitud = vnumsolcred --INDEX PATH
							AND folio = (SELECT MAX(folio) FROM bdisolic:"informix".ss_osclientesupervisar 
										WHERE num_solicitud = vnumsolcred AND folio < vfolio);
							LET cObservs = TRIM('Paso 14d');
							IF NVL(vfolioanterior, 0) = 0 THEN
								LET cObservs = TRIM('Paso 14e');
								SELECT MAX(secuenciaos) INTO vfolioanterior 
								FROM bdisolic:"informix".ss_solicitud_os
								WHERE num_solicitud = vnumsolcred AND secuenciaos < vfolio;
								LET vtdafolioant = '-1';
							END IF;
							LET cObservs = TRIM('Paso 14f');
							LET vfolioanterior = NVL(vfolioanterior, 0);
							LET vtdafolioant = NVL(vtdafolioant,'0');
						END IF;
					END IF;											--}
					LET cObservs = TRIM('Paso 15');
					IF cStatus = "RT" OR cStatus = "AT" THEN
						LET cObservs = TRIM('Paso 15a');
						LET vcve = 'M';						IF viRevisionCac = 2 AND cStatus = 'AT' THEN --DSB20180403 {
							LET sFlagCapCobranza = 2;
						END IF; 									
					ELIF cStatus = 'PC' THEN
						LET cObservs = TRIM('Paso 15b');
						LET vcve = ' '; LET vtipo = ' '; LET sFlagCapCobranza = 0;
						LET dfechaaltacte = dFechaAlta;
						LET cObservs = TRIM('Paso 15c');
						IF bEsCtePros = 1 AND vVigencia = 1 AND vStatusCtePros NOT IN('RT', 'CN', 'AN') THEN
							--CONTINUE FOREACH; Pendiente
						END IF;											--}
					ELIF cStatus="OS" THEN 
						
						LET cObservs = TRIM('Paso 15d');
					
						IF NVL(vfolio,0) =  0 THEN
							LET cObservs = TRIM('Paso 15e');
							--DSB20180409 Se comenta porque estaba haciendo mal la asignacion de formato de fecha
							--LET vfechaltacte = YEAR(dFechaAlta)||"/"||LPAD(MONTH(dFechaAlta),2,0)||"/"||LPAD(DAY(dFechaAlta),2,0); 
							LET vfechaltacte = dFechaAlta; LET vfolio = 0;
						END IF;
				
						LET vctenuevo = 'N'; LET vcve = 'M';
					ELSE
						LET cObservs = TRIM('Paso 15f');
						IF TRIM(NVL(vfolio,'0')) =  0 THEN 
							LET vfechaltacte =dFechaAlta; LET vfolio = '0'; 
						END IF;
						LET cObservs = TRIM('Paso 15g');
						IF vATsupervisadoRT = 'R' THEN
							LET vATsupervisadoRT = 'H'; 
						END IF; 
						LET vcve = 'M';
						IF cStatus = 'AN' THEN --DSB20180403 {
							LET vtipo = '';
						END IF; 							--}
					END IF;
				END IF;

                LET cObservs = TRIM('Paso 16');
				IF vnumsolcred <> '' OR vnumcte <> '' THEN
					IF bNuevaSolic = 't' THEN --DSB20180403
						LET cObservs = TRIM('Paso 17');
						SELECT nombre1, nombre2, apell_paterno, apell_materno, numcte,CASE WHEN bdinteg:"informix".sp_EsNumerico(user_insert) = 'V' THEN user_insert::INTEGER ELSE 0 END, rfc, CASE WHEN bdinteg:"informix".sp_EsNumerico(string2) = 'V' THEN string2::INTEGER ELSE 0 END, apell_casada, NVL(cliente_pros,'')
						INTO vnombre1, vnombre2, vapell_paterno, vapell_materno, vnumcte, vefectuoAP, vrfc, vpersonasvivenendomicilio, cApellCasada, vVigenciaCliente
						FROM bdinteg:"informix".si_cliente cte
						WHERE empresa = pempresa AND numcte = vnumcte;
						
						LET cObservs = TRIM('Paso 18');
						/*SELECT estado_civil, NVL(TRIM(REPLACE(REPLACE(curp,'|',' '),'//','/')),''), numidentifi, codidentifi, habita_en, sexo, fecha_nac, escolaridad::integer,nacionalidad, no_fm3, no_imss
						INTO vestadocivil, vcurp, vcveelector, vcveidentificacion, vcasapropia, vsexo, vfechanacimiento, vescolaridad,cNacionalidad, cNoFm3, cNoIMSS
						FROM bdinteg:"informix".si_ctepf iden
						WHERE numcte = vnumcte;*/
						
						SELECT estado_civil, NVL(TRIM(REPLACE(REPLACE(curp,'|',' '),'//','/')),''), numidentifi, codidentifi, habita_en, sexo, fecha_nac, nacionalidad, no_fm3, no_imss
						INTO vestadocivil, vcurp, vcveelector, vcveidentificacion, vcasapropia, vsexo, vfechanacimiento, cNacionalidad, cNoFm3, cNoIMSS
						FROM bdinteg:"informix".si_ctepf iden
						WHERE numcte = vnumcte;						
						
						--Nivel de escolaridad se homologa como el sp_envioparametricocoppel
						SELECT elemento 
						INTO vescolaridad
						FROM bdisolic:"informix".ss_scoring_element
						WHERE grupo = 21 AND elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 21 AND num_solicitud = vnumsolcred);
		
						LET cObservs = TRIM('Paso 19');
						SELECT NVL(correo_elec,'') INTO cEmail 	
						FROM bdinteg:"informix".si_correos WHERE numcte = vnumcte AND status_correo = 'A'
						AND ROWID IN (SELECT MAX(ROWID) FROM bdinteg:"informix".si_correos WHERE numcte = vnumcte AND status_correo = 'A');	
						
						IF cEmail IS NULL THEN 
							LET cEmail=''; 
						END IF;
		   
						LET cObservs = TRIM('Paso 20');
						FOREACH WITH HOLD
							SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerociudad) = 'V' THEN dir.numerociudad::INTEGER ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerocolonia) = 'V' THEN dir.numerocolonia::INTEGER ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerocalle) = 'V' THEN dir.numerocalle::INTEGER ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numeroextcalle) = 'V' THEN dir.numeroextcalle::INT8 ELSE 0 END,
							NVL(TRIM(REPLACE(REPLACE(dir.numerointcalle,'|',' '),'//','/')),''),dir.puntocardinal,NVL(TRIM(REPLACE(REPLACE(dir.observaciones,'|',' '),'//','/')),''),NVL(TRIM(REPLACE(REPLACE(dir.entre_calles,'|',' '),'//','/')),''),
							DECODE (dir.unidadhabitac,"S","1","0"),
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.manzana) = 'V' THEN dir.manzana::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.otros) = 'V' THEN dir.otros::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.andador) = 'V' THEN dir.andador::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.etapa) = 'V' THEN dir.etapa::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.lote ) = 'V' THEN dir.lote::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.edificio) = 'V' THEN dir.edificio::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.entrada) = 'V' THEN dir.entrada::SMALLINT ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(tel1.telefono,0)) = 'V' THEN tel1.telefono::INT8 ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(tel2.telefono,0)) = 'V' THEN tel2.telefono::INT8 ELSE 0 END, dir.tipo_dir,
							NVL(TRIM(REPLACE(REPLACE(dir.numerointcalle,'|',' '),'//','/')),''),	dir.pais, dir.estado,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(tel3.telefono,0)) = 'V' THEN tel3.telefono::INT8 ELSE 0 END,
							CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(tel3.extension,0)) = 'V' THEN tel3.extension::INTEGER ELSE 0 END
							INTO vciudadbanco, vcoloniabanco, vcalle, iNumerocasa, vdeptointerior, vrumbo, vcomplemento, ventrecalles, cUnidadHabit, vuhcmanzana,vuhcotros,vuhcandador, vuhcetapa, vuhclote, vuhcedificio, vuhcentrada, vtel, vtelcel, vTipo_Dir, cNumInterior, cPais, cEstado,vteltrabajo,vextensiontrabajo
							FROM bdinteg:"informix".si_direcciones_actual dir
							LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
							LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )
							LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel3 ON ( tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 )
							WHERE dir.numcte = vnumcte AND dir.tipo_dir IN ('1' ,'2')
							AND dir.secuencia = (SELECT MAX(dir2.secuencia) 
													FROM "informix".si_direcciones_actual dir2 
													WHERE dir2.numcte = vnumcte AND dir2.tipo_dir = dir.tipo_dir)
							ORDER BY dir.tipo_dir DESC
	   
							LET cObservs = TRIM('Paso 21');
							SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel,numerocoloniacoppel INTO vciudad, vcolonia
							FROM bdinteg:"informix".si_catzonas
							WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;

							LET cObservs = TRIM('Paso 22');
							--SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
                            SELECT cve_ciudad INTO vciudadbanco FROM bdinteg:"informix".si_ptf WHERE id_ptf = cFolioSucursal AND tipo='S';

							IF NVL(vciudad, 0) = 0 THEN
								LET cObservs = TRIM('Paso 23');
								SELECT FIRST 1 numerociudadcoppel INTO vciudad FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco;
								
								IF NVL(vciudad, 0) = 0 THEN 
									LET cObservs = TRIM('Paso 24');
									SELECT FIRST 1 numerociudadcoppel INTO vciudadtmp FROM bdinteg:"informix".si_catzonas where numerociudadcoppel <> 0; LET vciudad=vciudadtmp; 
								END IF;
							END IF;
							IF NVL(vcolonia, 0) = 0 THEN
								LET cObservs = TRIM('Paso 25');
								SELECT FIRST 1 numerocoloniacoppel INTO vcolonia FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco;
								IF NVL(vcolonia, 0) = 0 THEN 
									LET cObservs = TRIM('Paso 26');
									SELECT FIRST 1 numerocoloniacoppel INTO vcoloniatmp FROM bdinteg:"informix".si_catzonas where numerocoloniacoppel <> 0; LET vcolonia=vcoloniatmp; 
								END IF;
							END IF;
							IF iNumerocasa > 32767 THEN 
								LET iNumerocasa =0;	
							END IF;
							
							IF iNumerocasa = 0 THEN 
								LET iNumerocasa =1;	
							END IF;
							IF NVL(vcomplemento, '') = '' THEN 
								LET vcomplemento = 'E'; 
							END IF;
							IF NVL(vTipo_Dir,'0') ='2' THEN
								LET cObservs = TRIM('Paso 27');
								LET vciudadTrabajo=NVL(vciudad, 0); LET vcoloniaTrabajo=NVL(vcolonia, 0);LET vcalleTrabajo=NVL(vcalle, 0); 
								LET iNumerocasaTrabajo=NVL(iNumerocasa, 0);LET vdeptointeriorTrabajo=TRIM(NVL(vdeptointerior, ''));
								LET vrumbotrab=TRIM(NVL(vrumbo, ''));LET vcomplementotrab=TRIM(NVL(vcomplemento, 'E')); 
								LET ventrecallesTrabajo=TRIM(NVL(ventrecalles, ''));LET cUnidadHabitTrabajo=NVL(cUnidadHabit, '0');
								LET vuhcmanzanaTrabajo=NVL(vuhcmanzana, 0);LET vuhcotrosTrabajo=NVL(vuhcotros, 0);LET vuhcandadorTrabajo=NVL(vuhcandador, 0);
								LET vuhcetapaTrabajo=NVL(vuhcetapa, 0);LET vuhcloteTrabajo=NVL(vuhclote, 0);LET vuhcedificioTrabajo=NVL(vuhcedificio, 0);
								LET vuhcentradaTrabajo=NVL(vuhcentrada, 0);
								LET vteltrabajo=NVL(vteltrabajo, 0);LET vextensiontrabajo=NVL(vextensiontrabajo, 0);		
							END IF;
						END FOREACH;
						
						--DSB Bernardo Baez 01/04/2017 se obtienen los datos de puesto
						LET cObservs = TRIM('Paso 28');
						SELECT ing.nombre_empresa,ing.claveopcionpuesto,ing.clavesubopcionpuesto, puesto INTO vlugartrabajo, vopcionpuesto, vSubopcionpuesto, vpuesto
						FROM bdinteg:"informix".si_ingresos ing WHERE ing.numcte = vnumcte
						AND ing.sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = vnumcte AND tipo_ingreso = 'T');
							
					
						IF NVL(vopcionpuesto, '') = '' THEN 
							LET vopcionpuesto = '0'; 
						END IF;
						IF NVL(vSubopcionpuesto, '') = '' THEN 
							LET vSubopcionpuesto = '99'; 
						END IF;

						LET cObservs = TRIM('Paso 29');					
						SELECT ingreso_mensual,evalua_cc ,tp_ingreso,num_solicitud_ref, situacion_especial,causa_situacion INTO iIngreso,cMarcaHit,vtiposueldo,cNumSolRef, vsitespaux, vcausasitespaux FROM bdisolic:"informix".ss_resum_scor_fin WHERE empresa = pempresa AND num_solicitud = vnumsolcred;   

						
						IF vfechanacimiento >= DATE(1) THEN --DSB20180621						
							LET cfechanac = YEAR(vfechanacimiento)||"/"||LPAD(MONTH(vfechanacimiento),2,0)||"/"||LPAD(DAY(vfechanacimiento),2,0);
						ELSE
							LET cfechanac = '1900/01/01';
						END IF;
						
						LET cFecha_hoy = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0);
						IF NVL(vcomplementotrab, '') = '' THEN 
							LET vcomplementotrab = 'E'; 
						END IF;
						LET ccteConyugebcpl = '0';LET ccteref1bcpl = '0';LET ccteref2bcpl = '0';

						IF NVL(cNumSolRef,'') = '' THEN 
							LET cNumSolRef=vnumsolcred; 
						END IF;

						LET cObservs = TRIM('Paso 30');
						FOREACH WITH HOLD
							SELECT NVL(numcte_banco,'0'),CASE WHEN "informix".sp_EsNumerico(numcte_ref) = "V" THEN numcte_ref::INT8 ELSE 0 END, nombre1, nombre2, apell_paterno, apell_materno, parentesco, sexo,secuencia						
							INTO cctebcpltmp,vctetmp,vnombreunotmp,vnombredostmp,vApellPattmp,vApellMattmp,vcvefamiliatmp,cSexoConyugetmp,iRefSecustmp  
							FROM bdinteg:"informix".si_refclientes cte2
							WHERE empresa = pempresa AND numcte = vnumcte
							AND num_solicitud = cNumSolRef

							LET cObservs = TRIM('Paso 31');
							
							IF NVL(vctetmp,'') = '' THEN 
								LET vctetmp = '0'; 
							END IF; 
							IF NVL(cctebcpltmp,'')='' THEN 
							LET cctebcpltmp='0'; 
							END IF;   
							IF vcvefamiliatmp <> 'E' THEN
								IF NVL(iRefSecuencias1,0) = 0 THEN
									LET ccteref1bcpl=cctebcpltmp; LET vcteref=vctetmp; LET vnombre1ref=vnombreunotmp; 
									 LET vnombre2ref=vnombredostmp; LET vApellPatRef=vApellPattmp; LET vApellMatRef=vApellMattmp; LET vcveref1=vcvefamiliatmp;
									 LET cSexoref=cSexoConyugetmp; LET iRefSecuencias1=iRefSecustmp;	
									 --RQI 23 1635
									 LET vcveconyugefamilia=vcvefamiliatmp;
								ELSE
									 LET vnombre2ref2=vnombredostmp; LET vApellPatRef2=vApellPattmp; LET vApellMatRef2=vApellMattmp; LET vcveref2=vcvefamiliatmp; 
									 LET ccteref2bcpl=cctebcpltmp; LET vcteref2=vctetmp; LET vnombre1ref2=vnombreunotmp; 
									 LET cSexoref2=cSexoConyugetmp; LET iRefSecuencias2=iRefSecustmp;
								END IF;
							ELSE
								/*IF vestadocivil <>'C' THEN 
									let vestadocivil='C';
								END IF;   */
								LET ccteConyugebcpl=cctebcpltmp;LET vcteconyuge=vctetmp;LET vnombreunoconyuge=vnombreunotmp;LET vnombredosconyuge=vnombredostmp;
								LET vApellPatCony=vApellPattmp;LET vApellMatCony=vApellMattmp;LET vcveconyugefamilia=vcvefamiliatmp;LET cSexoConyuge=cSexoConyugetmp;
								LET iRefSecusConyugue=iRefSecustmp;   
	 
								LET cObservs = TRIM('Paso 32');
								SELECT nombre_empresa INTO vlugartrabajoconyuge FROM bdinteg:"informix".si_ingresos
									WHERE numcte = vcteconyuge AND empresa = pempresa AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = vcteconyuge AND empresa = pempresa);
								
								IF DBINFO("sqlca.sqlerrd2") =	0 THEN	
									LET vlugartrabajoconyuge = '';
								END IF;
							END IF;
						END FOREACH;
							
						IF NVL(iRefSecusConyugue,0) <> 0 THEN 
							LET iRefSecuencias2=iRefSecuencias1; LET iRefSecuencias1=iRefSecusConyugue;  
						END IF;

						LET cObservs = TRIM('Paso 33');  
						FOREACH WITH HOLD
							SELECT CASE WHEN "informix".sp_EsNumerico(numerociudad) = 'V' THEN numerociudad::INTEGER ELSE 0 END,
							CASE WHEN "informix".sp_EsNumerico(numerocolonia) = 'V' THEN numerocolonia::INTEGER ELSE 0 END,
							CASE WHEN "informix".sp_EsNumerico(numerocalle) = 'V' THEN numerocalle::INTEGER ELSE 0 END,
							CASE WHEN "informix".sp_EsNumerico(numeroextcalle) = 'V' THEN numeroextcalle::INT8 ELSE 0 END,
							NVL(TRIM(REPLACE(REPLACE(numerointcalle,'|',' '),'//','/')),''),puntocardinal,NVL(TRIM(REPLACE(REPLACE(observaciones,'|',' '),'//','/')),''),NVL(TRIM(REPLACE(REPLACE(entre_calles,'|',' '),'//','/')),''),unidadhabitac,
							CASE WHEN "informix".sp_EsNumerico(manzana) = 'V' THEN manzana::SMALLINT ELSE 0 END,
							CASE WHEN "informix".sp_EsNumerico(otros) = 'V' THEN otros::SMALLINT ELSE 0 END,
							CASE WHEN "informix".sp_EsNumerico(andador) = 'V' THEN andador::SMALLINT ELSE 0 END,
							CASE WHEN "informix".sp_EsNumerico(etapa) = 'V' THEN etapa::SMALLINT ELSE 0 END,
							CASE WHEN "informix".sp_EsNumerico(lote ) = 'V' THEN lote::SMALLINT ELSE 0 END,
							CASE WHEN "informix".sp_EsNumerico(edificio) = 'V' THEN edificio::SMALLINT ELSE 0 END,
							CASE WHEN "informix".sp_EsNumerico(entrada) = 'V' THEN entrada::SMALLINT ELSE 0 END,
							CASE WHEN "informix".sp_EsNumerico(telefono3) = 'V' THEN telefono3::INT8 ELSE 0 END,
							CASE WHEN "informix".sp_EsNumerico(telefono2) = 'V' THEN telefono2::INT8 ELSE 0 END,
							CASE WHEN "informix".sp_EsNumerico(telefono1) = 'V' THEN telefono1::INT8 ELSE 0 END,secuencia
							INTO vciudadbanco,vcoloniabanco,vcalletrabajotmp,iNumerocasatmp,vdeptoointeriortmp,vrumbotrabtmp,vcomplementotmp,ventrecallestmp,cflaguht,vuhymanzanatmp,vuhyotrostmp,vuhyandadortmp,vuhyetapatmp,vuhylotetmp,vuhyedificiotmp,vuhyentradatmp,vteltrabajotmp,vtelceltmp,vtelreftmp,iSecuenciatmp 
							FROM bdinteg:"informix".si_refdirecciones dir2
							WHERE numcte = vnumcte AND secuencia IN(iRefSecuencias1,iRefSecuencias2)

							LET cObservs = TRIM('Paso 34');

							SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel,numerocoloniacoppel
							   INTO vciudadbancotmp, vcoloniabancotmp
							   FROM bdinteg:"informix".si_catzonas
							   WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;

							LET cObservs = TRIM('Paso 35');
							--SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
	   
	                       SELECT cve_ciudad INTO vciudadbanco FROM bdinteg:"informix".si_ptf WHERE id_ptf = cFolioSucursal AND tipo='S';
							IF NVL(vciudadbancotmp, 0) = 0 THEN
								LET cObservs = TRIM('Paso 36');
								SELECT FIRST 1 numerociudadcoppel INTO vciudadtmp FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco;
								IF NVL(vciudadbancotmp, 0) = 0 THEN 
									LET vciudadbancotmp=vciudadtmp; 
								END IF;
							END IF;
							
							IF NVL(vcoloniabancotmp, 0) = 0 THEN
								LET cObservs = TRIM('Paso 37');
								SELECT FIRST 1 numerocoloniacoppel INTO vcoloniatmp FROM bdinteg:"informix".si_catzonas WHERE numerociudad = vciudadbanco;
								IF NVL(vcoloniabancotmp, 0) = 0 THEN 
									LET vcoloniabancotmp=NVL(vcoloniatmp, 0);
								END IF;
							END IF;
							IF cflaguht = 'S' THEN 
								LET vflaguhy = 1; 
							ELSE 
								LET vflaguhy = 0; 
							END IF;
							IF iNumerocasatmp > 32767 THEN 
								LET iNumerocasatmp = 0; 
							END IF;
							
							IF NVL(iNumerocasatmp,0) = 0 THEN 
								LET iNumerocasatmp = 1; 
							END IF;
							IF NVL(vcomplementocony, '') = '' THEN 
								LET vcomplementocony = 'E'; 
							END IF;
							IF (iSecuenciatmp = iRefSecuencias1 AND vestadocivil = 'C') OR (iSecuenciatmp = iRefSecuencias1 AND vestadocivil <> 'C') THEN
								IF NVL(irefsecusconyugue,0)= 0 THEN 
									LET cObservs = TRIM('Paso 38');
									LET vciudadref1=NVL(vciudadbancotmp, 0);LET vcoloniaref1=NVL(vcoloniabancotmp, 0);LET vcalleref1=NVL(vcalletrabajotmp, 0);
									LET iNumerocasaref1=NVL(iNumerocasatmp, 0);LET vdeptointeriorref1=TRIM(NVL(vdeptoointeriortmp, ''));
									LET vrumboref1=TRIM(NVL(vrumbotrabtmp, ''));LET vcomplementoref1=TRIM(NVL(vcomplementotmp, ''));
									LET ventrecallesref1=TRIM(NVL(ventrecallestmp,''));LET cflaguhtref1=NVL(vflaguhy, 0);
									LET vuhymanzanaref1=NVL(vuhymanzanatmp, 0);LET vuhyotrosref1=NVL(vuhyotrostmp, 0);LET vuhyandadorref1=NVL(vuhyandadortmp, 0);
									LET vuhyetaparef1=NVL(vuhyetapatmp, 0);LET vuhyloteref1=NVL(vuhylotetmp, 0);LET vuhyedificioref1=NVL(vuhyedificiotmp, 0);
									LET vuhyentradaref1=NVL(vuhyentradatmp, 0);LET vteltrabajoref1=NVL(vteltrabajotmp, 0);
									LET vtelcelref1=NVL(vtelceltmp, 0);LET iSecuenciaref1=vcveref1;
								ELSE 
									LET cObservs = TRIM('Paso 39');
									LET vciudadconyuge=NVL(vciudadbancotmp, 0);LET vcoloniaconyuge= NVL(vcoloniabancotmp, 0);LET vcalletrabajoconyuge=NVL(vcalletrabajotmp, 0);LET iNumerocasaconyuge=NVL(iNumerocasatmp, 0);LET vdeptoointeriorconyuge=TRIM(NVL(vdeptoointeriortmp, ''));
									LET vrumbotrabcony=TRIM(NVL(vrumbotrabtmp, ''));LET vcomplementocony=TRIM(NVL(vcomplementotmp, ''));LET ventrecallesconyuge=TRIM(NVL(ventrecallestmp,''));LET cflaguhtconyugue=NVL(vflaguhy, 0); LET vuhymanzana=NVL(vuhymanzanatmp, 0); 
									LET vuhyotros= NVL(vuhyotrostmp, 0); LET vuhyandador= NVL(vuhyandadortmp, 0); LET vuhyetapa= NVL(vuhyetapatmp, 0); LET vuhylote= NVL(vuhylotetmp, 0); LET vuhyedificio= NVL(vuhyedificiotmp, 0); LET vuhyentrada= NVL(vuhyentradatmp, 0);										
									LET vteltrabajoconyuge=NVL(vteltrabajotmp, 0); LET vtelcelconyuge=NVL(vtelceltmp, 0); LET vcveconyugefamilia=NVL(vcveconyugefamilia,'');
								END IF;
							ELIF iSecuenciatmp = iRefSecuencias2 THEN
								IF vestadocivil <> 'C' THEN   
									LET cObservs = TRIM('Paso 40');
									LET vciudadref2=NVL(vciudadbancotmp, 0);LET vcoloniaref2=NVL(vcoloniabancotmp, 0);LET vcalleref2=NVL(vcalletrabajotmp, 0);
									LET iNumerocasaref2=NVL(iNumerocasatmp, 0);LET vdeptointeriorref2=TRIM(NVL(vdeptoointeriortmp, ''));LET vrumboref2=TRIM(NVL(vrumbotrabtmp, ''));LET vcomplementoref2=TRIM(NVL(vcomplementotmp, ''));
									LET ventrecallesref2=TRIM(NVL(ventrecallestmp,''));LET cflaguhtref2=NVL(vflaguhy, 0);LET vuhymanzanaref2=NVL(vuhymanzanatmp, 0);
									LET vuhyotrosref2=NVL(vuhyotrostmp, 0);LET vuhyandadorref2=NVL(vuhyandadortmp, 0);LET vuhyetaparef2=NVL(vuhyetapatmp, 0);
									LET vuhyloteref2=NVL(vuhylotetmp, 0);LET vuhyedificioref2=NVL(vuhyedificiotmp, 0);LET vuhyentradaref2=NVL(vuhyentradatmp, 0);
									LET vteltrabajoref2=NVL(vtelreftmp, 0);LET vtelcelref2=NVL(vtelceltmp, 0);
									LET iSecuenciaref2=vcveref2;				
								ELSE
									IF NVL(iRefSecusConyugue,0) <> 0 THEN 
										LET cObservs = TRIM('Paso 41');
										LET vciudadref1=NVL(vciudadbancotmp, 0);LET vcoloniaref1=NVL(vcoloniabancotmp, 0);LET vcalleref1=NVL(vcalletrabajotmp, 0);LET iNumerocasaref1=NVL(iNumerocasatmp, 0);
										LET vdeptointeriorref1=TRIM(NVL(vdeptoointeriortmp, ''));LET vrumboref1=TRIM(NVL(vrumbotrabtmp, ''));LET vcomplementoref1=TRIM(NVL(vcomplementotmp, ''));LET ventrecallesref1=TRIM(NVL(ventrecallestmp,''));
										LET cflaguhtref1=NVL(vflaguhy, 0);LET vuhymanzanaref1=NVL(vuhymanzanatmp, 0);LET vuhyotrosref1=NVL(vuhyotrostmp, 0);
										LET vuhyandadorref1=NVL(vuhyandadortmp, 0);LET vuhyetaparef1=NVL(vuhyetapatmp, 0);LET vuhyloteref1=NVL(vuhylotetmp, 0);
										LET vuhyedificioref1=NVL(vuhyedificiotmp, 0);LET vuhyentradaref1=NVL(vuhyentradatmp, 0);LET vteltrabajoref1=NVL(vteltrabajotmp, 0);
										LET vtelcelref1=NVL(vtelceltmp, 0);LET iSecuenciaref1=vcveref1;					
									ELSE
										LET cObservs = TRIM('Paso 42');
										lET vciudadref2=NVL(vciudadbancotmp, 0);LET vcoloniaref2=NVL(vcoloniabancotmp, 0);LET vcalleref2=NVL(vcalletrabajotmp, 0);
										LET iNumerocasaref2=NVL(iNumerocasatmp, 0);LET vdeptointeriorref2=TRIM(NVL(vdeptoointeriortmp, ''));LET vrumboref2=TRIM(NVL(vrumbotrabtmp, ''));LET vcomplementoref2=TRIM(NVL(vcomplementotmp, ''));
										LET ventrecallesref2=TRIM(NVL(ventrecallestmp,''));LET cflaguhtref2=NVL(vflaguhy, 0);LET vuhymanzanaref2=NVL(vuhymanzanatmp, 0);LET vuhyotrosref2=NVL(vuhyotrostmp, 0);LET vuhyandadorref2=NVL(vuhyandadortmp, 0);
										LET vuhyetaparef2=NVL(vuhyetapatmp, 0);LET vuhyloteref2=NVL(vuhylotetmp, 0);LET vuhyedificioref2=NVL(vuhyedificiotmp, 0);
										LET vuhyentradaref2=NVL(vuhyentradatmp, 0);LET vteltrabajoref2=NVL(vtelreftmp, 0);LET vtelcelref2=NVL(vtelceltmp, 0);LET iSecuenciaref2=vcveref2;						
									END IF;
								END IF;
							END IF;
						END FOREACH;	
							
						LET cObservs = TRIM('Paso 43');
						FOREACH WITH HOLD
							SELECT ele.rango_minimo,det.grupo,ele.descripcion INTO  iElemento,iGrupo,cDescripElemento
							FROM bdisolic:"informix".ss_detalle_scoring det
							INNER JOIN bdisolic:"informix".ss_scoring_element ele ON ( ele.elemento = det.elemento AND activa = 1 AND det.grupo = ele.grupo)
							WHERE num_solicitud = vnumsolcred
							AND det.grupo  IN(11,39,6,8,21) AND det.seccion = 2 AND det.tpo_persona = '01'
							
							LET cObservs = TRIM('Paso 44');
	   
							IF iGrupo = 11 THEN 
								LET cObservs = TRIM('Paso 45');
								LET vnumerodependientes = iElemento;
							ELIF iGrupo = 39 THEN 
									LET cObservs = TRIM('Paso 46');
									LET vpersonastrabajan = iElemento;
							ELIF iGrupo = 6 THEN 
								LET cObservs = TRIM('Paso 47');
								LET cfechadecuandovive = YEAR(vfechaltacte)-iElemento;
								LET cfechadecuandovive = TRIM(cfechadecuandovive)||'/01/01';
							ELIF iGrupo = 8 THEN
								IF iElemento = -1 THEN
									LET cObservs = TRIM('Paso 48');
									SELECT elemento INTO iElemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 7 AND seccion = 2 AND tpo_persona = '01' AND num_solicitud = vnumsolcred;
									IF iElemento = 15 THEN 
										LET cObservs = TRIM('Paso 49');
										LET cFechAntigTrab = cfechanac;
									ELIF iElemento = 12 THEN 
										LET cObservs = TRIM('Paso 50');
										LET cFechAntigTrab =  cfechadecuandovive;LET vlugartrabajo = ""; 
									ELIF iElemento = 6 OR iElemento = 17 THEN 
										LET cObservs = TRIM('Paso 51');
										LET cFechAntigTrab = dfechaaltacte;			
									END IF;
								ELSE  
									LET cObservs = TRIM('Paso 52');
									LET cFechAntigTrab = YEAR(vfechaltacte)-iElemento;
									LET cFechAntigTrab = TRIM(cFechAntigTrab)||'/01/01';
								END IF;
							ELIF iGrupo = 21 THEN
								LET cObservs = TRIM('Paso 53');
								IF TRIM(cDescripElemento) = "No EstudiÃ³" THEN 
									LET vescolaridad = '1';
								ELIF TRIM(cDescripElemento) = "Primaria" THEN 
									LET  vescolaridad = '2';
								ELIF TRIM(cDescripElemento) = "Secundaria" THEN 
									LET vescolaridad = '3';
								ELIF TRIM(cDescripElemento) = "Carrera TÃ©nica" THEN 
									LET vescolaridad = '4';
								ELIF TRIM(cDescripElemento) = "Preparatoria" THEN 
									LET vescolaridad = '5';
								ELIF TRIM(cDescripElemento) = "Licenciatura o Superior" THEN 
									LET vescolaridad = '6';
								END IF;
							END IF;
						END FOREACH;

						LET cObservs = TRIM('Paso 54');
					
						
						LET cObservs = TRIM('Paso 55');
						SELECT NVL(institucion, ''), fecha_sic INTO cFlagConsBuro, dFechaConsBuro FROM bdisolic:"informix".ss_solicitudes_sic
						WHERE numcte = vnumcte AND num_solicitud = vnumsolcred
						AND ROWID = (SELECT MAX(ROWID) FROM bdisolic:"informix".ss_solicitudes_sic WHERE numcte = vnumcte AND num_solicitud = vnumsolcred);
						
						LET cObservs = TRIM('Paso 55a');
						IF cFlagConsBuro = 'BC' OR cFlagConsBuro = 'CC' THEN 
							LET cBuroPilotoTestig = 'P';LET cMarcarConsultado = 'CO'; 
						ELSE 
							LET cBuroPilotoTestig = 'T';LET cMarcarConsultado = 'NC'; 
						END IF;
						LET cObservs = TRIM('Paso 55b');
						IF NVL(dFechaConsBuro, '') <> '' THEN
							LET cFechaConsBuro = YEAR(dFechaConsBuro)||"/"||LPAD(MONTH(dFechaConsBuro),2,0)||"/"||LPAD(DAY(dFechaConsBuro),2,0);
						ELSE 
							LET cObservs = TRIM('Paso 55c');
							LET cFechaConsBuro = YEAR(dFechaConsBuro)||"/"||LPAD(MONTH(dFechaConsBuro),2,0)||"/"||LPAD(DAY(dFechaConsBuro),2,0);
						END IF;
						
						IF TRIM(NVL(cMarcaHit, '')) = 'X' THEN 
							LET cMarcaHit = 'HT'; ELSE LET cMarcaHit = 'NH'; 
						END IF;
					END IF; --Termina Si es Nueva Solic
					IF cStatus NOT IN ('PC','BC') AND iRowId < 0 THEN --DSB20180403
						LET cObservs = TRIM('Paso 56');
						SELECT MAX(ROWID) INTO iRowId FROM bdisolic:"informix".ss_nuevo_parametrico WHERE num_solicitud = vnumsolcred;
						
						LET cObservs = TRIM('Paso 57');
						SELECT  ingreso_mensual,cap_sistematica_abono,tope_abonocoppel,lineacreditotope,capmaxima_abono,capreal_abono,lineacredito_real,compromisossic,flaglineacreditoesp,limitecredito, situacion_especial,causa_sitesp,puntos_parcn,status_solicitud,
						id_situaciones,TRIM(puntualidad_ref1),TRIM(puntualidad_ref2),flagtestigoparametricocn::SMALLINT,flag_altadirecta_asupervisar::SMALLINT,puntos_var_param,puntos_var_sic,score_domicilio,nuevo_puntajefinal,clienteprospecto,
						par_celulares, par_altoriesgo, par_prestamos -- DSB Bernardo Baez 31/03/2017 se agregan los datos par_celulares, par_altoriesgo, par_prestamos 
						INTO iMontoIngMensual, iCapSistematicabono, iTopeAbonoCoppel, iLineaCrediTope, iCapMaximaAbono, iCapRealAbono, iLineaCredReal, iCompromisosSic, iFlagLineaCredEsp,vlimitecredito,vsitespPrmtrco, vcausasitespPrmtrco,iPuntuacion,
						cTipRechazo, iId_Situaciones,cPuntualidad_ref1,cPuntualidad_ref2,sFlagTestParam,sFlag_altadirecta_asupervisar,iPuntos_Var_Param,iPuntos_Var_SIC,iScore_domicilio,sNuevo_puntajefinal,vNumCteProspecto, sParceles, sParAltoRiesgo, sParPrestamo 
						FROM bdisolic:"informix".ss_nuevo_parametrico
						WHERE empresa = pempresa AND ROWID = iRowId;
					END IF;
					IF bNuevaSolic = 't' OR iRowId > 0 THEN --DSB20180403
						IF iIngreso > iTopeMax THEN 
							LET cObservs = TRIM('Paso 58');
							LET iIngreso=iTopeMax; 
							IF iRowId > 0 THEN LET iMontoIngMensual=iTopeMax; END IF; --DSB20180403
						END IF;
						
						LET cObservs = TRIM('Paso 59');
						LET vingresomensual = ((((NVL(iIngreso::DECIMAL(18,2),0))+(iValor/2)))/iValor)::INTEGER;
												
						IF vingresomensual < 1 THEN 
							LET vingresomensual = 1; 
						END IF;
					END IF;
					LET cObservs = TRIM('Paso 59a');
					LET vsitesp = NVL(vsitespPrmtrco,'');			--DSB20180403 {
					LET vcausasitesp = NVL(vcausasitespPrmtrco,0);	--				}
					LET cObservs = TRIM('Paso 59b');
					IF cStatus="AP" THEN 
						LET vEfectuo= CASE WHEN cSucursalSol <> '' THEN vEfectuoRTOS ELSE vefectuoAP END;
						IF iSitEspAux = 1 THEN			--DSB20180403
							LET cObservs = TRIM('Paso 60');
							LET vsitesp = vsitespaux;
							LET vcausasitesp = vcausasitespaux;
						END IF;
						LET cObservs = TRIM('Paso 60a');
						IF dFechaAlta <> pFechaAct OR cTipRechazoOs <> '' THEN	--DSB20180403 {
							LET iVerifAltaDirecta = 1;
						END IF;													--				}
					ELSE  
						LET cObservs = TRIM('Paso 61');
						IF cStatus="RT" THEN --2014/03/25 RQM 18 049->RQI 27 093 
							IF NVL(cTipRechazoOs,'')='R' THEN
								LET vsitesp = vsitesp_resp; LET vcausasitesp = vcausasitesp_resp;
								LET cObservs = TRIM('Paso 62');
							ELSE
								IF NVL(cTipRechazo,'') <>'R' THEN
									LET cObservs = TRIM('Paso 63');
									SELECT situacion_especial,causa_situacion INTO vsitesp, vcausasitesp FROM bdisolic:"informix".ss_resum_scor_fin WHERE num_solicitud =vnumsolcred;
								END IF;
							END IF;
						--ELSE 						DSB20180403 {
						ELIF cStatus = "AT" THEN
							LET cObservs = TRIM('Paso 64');
							SELECT FIRST 1 ss.situacionespecial,ss.causa, NVL(sa.status_solicitud, '0'/*0*/) INTO tmpSitEsp, tmpCauEsp, tmpSolicRT
							FROM bdisolic:"informix".ss_os_solautdirecta ss LEFT OUTER JOIN bdisolic:"informix".ss_autorizacion sa 
							ON (sa.num_solicitud = ss.num_solicitud AND sa.status_solicitud = 'RT')
							WHERE ss.empresa = pEmpresa AND ss.num_solicitud = vnumsolcred;
							LET cObservs = TRIM('Paso 64b');
							IF tmpSolicRT = '0'/*0*/ AND NVL(tmpSitEsp, 'NADA') <> 'NADA' THEN --DSB20180409
								LET cObservs = TRIM('Paso 64c');
								LET vsitesp = NVL(tmpSitEsp,''); 
								LET vcausasitesp = NVL(tmpCauEsp,0);
							END IF;
						END IF;
						LET iVerifAltaDirecta = 1;				--}
					END IF;
					LET cObservs = TRIM('Paso 64d');
					IF iVerifAltaDirecta = 1 THEN		-- DSB20180403 {
						IF vsitesp = 'S' AND vcausasitesp IN (50,51) THEN
							LET vsitesp = ''; LET vcausasitesp = 0; --Solo se envia S-50 o S-51 cuando sea la AP el mismo dia de la solic
						END IF;
					END IF;
					LET cObservs = TRIM('Paso 64e');
					IF vfolio <> '0' /* OR viCuantasOS >= 1  */THEN 
						LET vtiendafolio = cFolioSucursal; 
					ELSE 
						LET vtiendafolio = '0';
					END IF;								-- 		}
					
					
					LET cObservs = TRIM('Paso 64f');
					IF vcve = "" THEN
						IF vVigenciaCliente <> '' then
							IF (dFechaAlta - vfechaltacte) < 60 AND cStatus <> 'PC' THEN  --DSB20180403
								LET vcve = "M";
							END IF;
						END IF;
					END IF;
					
					/*DSB20180403 IF vVigenciaCliente <> '' then 
						IF vcve = 'M' THEN
							IF (dFechaAlta - vfechaltacte) < 60 AND (cTipRechazoOs = 'A' AND cStatus = 'AT') THEN --DSB20180403
								LET vATsupervisadoRT ="A";
							ELSE
								LET vATsupervisadoRT ="P";
								--DSB 30 de Marzo 2017 Bernardo Baez Se modifica para Mandar clave = '' cuando tiene vigencia encida
								LET vcve = '';
							END IF;
						END IF;
					END IF; */
					LET cObservs = TRIM('Paso 64g');
					LET cStatusbcpl = cStatus;
					--SE OBTIENE CAMPO cMotivobcpl
					LET cMotivobcpl = '';
					IF (cStatusbcpl = "AN" OR cStatusbcpl = "PC") THEN
						LET cMotivobcpl = '';
					ELIF cStatusbcpl IN("RT",'CN') THEN
						LET cObservs = TRIM('Paso 65');
						LET cMotivobcpl = NVL(vCausaSolic, ''); --DSB20180403
					ELIF cStatus = "OA" AND cTipRechazoOs = "D" THEN --APR 20160926
						LET cObservs = TRIM('Paso 66');
						LET vsitesp = vsitesp_resp;
						LET vcausasitesp = vcausasitesp_resp;
					END IF;
					LET cObservs = TRIM('Paso 66a');
					LET cStatusbcplaux = cStatus;
					
					IF cStatus = 'OS' THEN
						LET vATsupervisadoRT = 'P';
					ELIF cStatus = 'OA' THEN
						LET vATsupervisadoRT = 'D';
					ELIF cStatus = 'PC' THEN
						LET vATsupervisadoRT = '';
					ELIF cStatus = 'AT' THEN
						LET vATsupervisadoRT = 'A';
					ELIF cStatus = 'RT' THEN
						LET vATsupervisadoRT = 'H';
					END IF;
					
					LET cObservs = TRIM('Paso 67');

						--RQM-598.1	
					SELECT fecha_hoy
					INTO dtFechaHoy
					FROM "informix".si_fechas
					WHERE empresa = pEmpresa;	

					--SELECCIONA SI EL PROCESO DE SOLICITUD COPPEL
					-- FUE MIXTO O UNICO
					SELECT num_solicitud_ref
					INTO cNumSolicMixta
					FROM bdisolic:"informix".ss_resum_scor_fin
					WHERE empresa = pEmpresa
					AND num_solicitud = vnumsolcred; 
					
					--RQM-598.1	
					LET cNumSolicMixta = TRIM(NVL(cNumSolicMixta,''));
					
					IF cNumSolicMixta <> '' THEN
						--PROCESO MIXTO
						--SELECCIONA LOS DATOS DE LA SOLICITUD DE BANCO PARA ENVIAR AL PARAMETRICO DE COPPEL
						
						FOREACH
							SELECT FIRST 1 fecha_hora,status_solicitud
							INTO dtFecha_resp_bco,cStatus_solicitud_bco
							FROM bdisolic: "informix".ss_autorizacion
							WHERE num_solicitud = cNumSolicMixta
							AND status_solicitud != 'BC'
							AND fecha_hora > (SELECT max(fecha_hora)
												FROM bdisolic: "informix". ss_autorizacion
												WHERE num_solicitud = cNumSolicMixta
												AND status_solicitud = 'BC')
							AND status_solicitud NOT IN ('BC','PC','AN','CC')
							GROUP BY fecha_hora,status_solicitud
							ORDER BY fecha_hora ASC
						END FOREACH

					ELSE
						--PROCESO UNICO
						--SELECCIONA LOS DATOS DE ALGUN PRODUCTO DE BANCO PARA ENVIAR AL PARAMETRICO DE COPPEL
						--CON ANTIGUEDAD NO MAYOR A 3 MESES DE LA FECHA ACTUAL
						SELECT FIRST 1 num_solicitud,status_solicitud, fecha_hora
						INTO cNumSolicMixta,cStatus_solicitud_bco,dtFecha_resp_bco
						FROM bdisolic: "informix".ss_solicitudes
						WHERE empresa = pEmpresa
						AND numcte = vnumcte
						AND num_solicitud != vnumsolcred
						AND status_solicitud IN ('AT','AP')
						AND (MONTHS_BETWEEN(dtFechaHoy, fecha_hora)) <= 3;
						
						LET cNumSolicMixta = TRIM(NVL(cNumSolicMixta,''));
					END IF;	
					
					--MONTO DE LA LINEA DE CREDITO DE LA SOLICITU DE BANCO
					SELECT FIRST 1 linea_credito,num_producto
					INTO dMonto_lc_bco,sNum_producto_bco
					FROM bdisolic: "informix".ss_revision_determinacion
					WHERE empresa = pEmpresa
					AND num_solicitud = cNumSolicMixta;
			
					LET cObservs = TRIM('Paso 67a');
	
					SELECT FIRST 1 canal_origensol,grupo_eval, grupo_hit
					INTO cOrigenSolic,cGpoEval, cGpoHit
					FROM bdisolic: "informix".ss_nuevo_parametrico
					WHERE Empresa = pEmpresa
					AND num_solicitud = vnumsolcred;
					
					--RQM-598.1
					--SE INICIALIZAN LOS CAMPOS CON VALOR POR DEFAULT 
					--EN CASO DE ESTAR VACIOS O NULOS
					LET cStatus_solicitud_bco = TRIM(NVL(cStatus_solicitud_bco,''));
					
					IF cStatus_solicitud_bco = '' THEN
						LET sNum_producto_bco = 0;
					END IF;
					
					LET sNum_producto_bco = NVL(sNum_producto_bco,0);
					LET dMonto_lc_bco = NVL(dMonto_lc_bco,0.00);
					LET dtFecha_resp_bco = NVL(dtFecha_resp_bco, DATE(1));
					LET cOrigenSolic = TRIM(NVL(cOrigenSolic,'0'));
					LET cGpoEval = TRIM(NVL(cGpoEval,'0'));
					LET cGpoHit = TRIM(NVL(cGpoHit,'0'));

					--598.1 VALIDAR QUE SI LOS PARAMETROS VIENEN VACIOS GUARDARLOS EN 0
					IF cOrigenSolic = ' '  OR cOrigenSolic = '' THEN
						LET cOrigenSolic = '0';
					END IF;
					IF cGpoEval = ' ' OR cGpoEval = '' THEN
						LET cGpoEval = '0';
					END IF;
					IF cGpoHit = ' ' OR cGpoEval = '' THEN
						LET cGpoHit = '0';
					END IF;
					LET cObservs = TRIM('Paso 67b');
					
					SELECT 1 INTO iBandera FROM bdisolic:"informix".ss_solic_rt WHERE empresa = '001' AND num_solicitud = vnumsolcred AND reevaluado >= '1';
					
					IF iBandera = 1 THEN 
					
						LET cOrigenSolic = '9';
					
					END IF;
					
					INSERT INTO bdinteg:"informix".si_tramasbatch(secuencia,clave, caja, area, cliente, nombre1, nombre2, apellidopaterno, apellidomaterno, curp, claveelector, claveidentificacion, identificacion, ciudad, colonia, calle, casa, deptoointerior, rumbo, complemento, entrecalles, flaguhc, uhcmanzana, uhcotros, uhcandador, uhcetapa, uhclote, uhcedificio, uhcentrada, telefono, telefonocelular, casapropia, niptitular, nipadicional, sexo, estadocivil, fechanacimiento, fechadesdecuandoviveahi, personasvivenendomicilio, escolaridad, tiposueldo, numerodependientes, personastrabajan, limitecredito, ingresomensual, situacionespecial, causasituacionespecial, claveautrechaza, aceptadosupervisadorechazado, clientenuevo, creditojoven, lugartrabajo, ciudadtrabajo, coloniatrabajo, calletrabajo, casatrabajo, deptoointeriortrabajo, rumbotrabajo, complementotrabajo, entrecallestrabajo, flaguht, uhtmanzana, uhtotros, uhtandador, uhtetapa, uhtlote, uhtedificio, uhtentrada, telefonotrabajo, extensiontrabajo, puesto, opcionpuesto, fechaantiguedadtrabajo, clienteconyuge, nombreunoconyuge, nombredosconyuge, apellidopaternoconyuge, apellidomaternoconyuge, sexoconyuge, lugartrabajoconyuge, ciudadconyuge, coloniaconyuge, calletrabajoconyuge, casatrabajoconyuge, deptoointeriorconyuge, rumbotrabajoconyuge, complementoconyuge, entrecallesconyuge, flaguhy, uhymanzana, uhyotros, uhyandador, uhyetapa, uhylote, uhyedificio, uhyentrada, telefonotrabajoconyuge, telefonocelularconyuge, claveconyugefamilia, clientereferencia, nombreunoreferencia, nombredosreferencia, apellidopaternoreferencia, apellidomaternoreferencia, sexoreferencia, ciudadreferencia, coloniareferencia, callereferencia, casareferencia, deptoointeriorreferencia, rumboreferencia, complementoreferencia, entrecallesreferencia1, flaguhr, uhrmanzana, uhrotros, uhrandador, uhretapa, uhrlote, uhredificio, uhrentrada, telefonoreferencia, telefonocelularreferencia, clavereferencia1, clientereferencia2, nombreunoreferencia2, nombredosreferencia2, apellidopaternoreferencia2, apellidomaternoreferencia2, sexoreferencia2, ciudadreferencia2, coloniareferencia2, callereferencia2, casareferencia2, deptoointeriorreferencia2, rumboreferencia2, complementoreferencia2, entrecallesreferencia2, flaguhr2, uhrmanzana2, uhrotros2, uhrandador2, uhretapa2, uhrlote2, uhredificio2, uhrentrada2, telefonoreferencia2, telefonocelularreferencia2, clavereferencia2, referencia2, referencia3, marcadatosin, tiporeposicion, reposicion, flagentregotarjeta, efectuo, tiendafolio, folio, fechaaltacliente, flagnoreconocehuella, foliotienda, rfc, cveburo, folioaut, folioconsulta, folioconcir, negocio, subnegocio, empleadoautorizo, tipo, fechamovto, numerosolicituddecredito, clientebancoppel, tiendafolioanterior, folioanterior, claveproducto, flagactualizacion, sistsegsocial, tiposueldoext, numempleados, subopcionpuesto, puestoext, opcionpuestoext, numempleadosext, subopcionpuestoext, tipoorigen, tipoproducto, tienda, fecha, puntosparcn, marcahit, empleadosupcob, flagcapturohuella, marcarconsultado, flagtestigoparametricocn, flagcapturacobranza, empleadogteautorizo, flagconsultaburo, buropilototestigo, nacionalidad, no_fm3, email, apellido_cas, pais, no_imss, estado, municipio, numinterior, propietarionegocio, parcelulares, paraltoriesgo, parprestamo, modelocelulares, fechaconsultaburo, montoingresomensual, capsistematicaabono, topeabonocoppel, lineadecreditope, capmaximaabono, caprealabono, lineadecreditoreal, compromisossic, flaglineacreditoesp, clienteconyugebcpl, clientereferenciabcpl, clientereferencia2bcpl,sucursal,fecha_insert,
					Statusbcpl, Motivobcpl, FlagProspecto, NumCteProspecto, ParAltoRiesgoNvo, PagoUlt12meses, id_situaciones, puntualidad_ref1, puntualidad_ref2, flag_altadirecta_asupervisar, puntos_var_param, puntos_var_sic, score_domicilio, nuevo_puntajefinal,
					num_producto_bco, status_solicitud_bco, monto_lc_bco, fecha_resp_bco,canal_origensol,grupo_eval,grupo_hit, flag_productocoppel, flag_motoscoppel , ctepresento_comping)
					VALUES(inumSecuencia,vcve, vcaja, TRIM(varea),TRIM(NVL(vcte_ref,'0')),TRIM(NVL(vnombre1, '')), 
					TRIM(NVL(vnombre2, '')), TRIM(NVL(vapell_paterno, '')),TRIM(NVL(vapell_materno, '')),TRIM(NVL(vcurp, '')),TRIM(NVL(vcveelector, '')),
					TRIM(NVL(vcveidentificacion, '')), videntificacion, NVL(vciudad, 0),NVL(vcolonia, 0),NVL(vcalle, 0), NVL(iNumerocasa, 0), 
					TRIM(NVL(vdeptointerior, '')),TRIM(NVL(vrumbo, '')), TRIM(NVL(vcomplemento, ' ')), TRIM(NVL(ventrecalles, '')), NVL(cUnidadHabit, '0'),
					NVL(vuhcmanzana, 0),NVL(vuhcotros, 0), NVL(vuhcandador, 0), NVL(vuhcetapa, 0), NVL(vuhclote, 0), NVL(vuhcedificio, 0), NVL(vuhcentrada, 0),
					NVL(vtel, 0),NVL(vtelcel, 0), TRIM(NVL(vcasapropia, '')),vniptitular, TRIM(vnipadicional), TRIM(NVL(vsexo, '')),
					TRIM(NVL(vestadocivil, '')), TRIM(NVL(cfechanac, '1900/01/01')),TRIM(NVL(cfechadecuandovive, '1900/01/01')), NVL(vpersonasvivenendomicilio, 0), 
					TRIM(NVL(vescolaridad, '')), TRIM(NVL(vtiposueldo, '')),NVL(vnumerodependientes, 0), NVL(vpersonastrabajan, 0), NVL(vlimitecredito, 0),
					NVL(vingresomensual, 0), TRIM(NVL(vsitesp, '')),NVL(vcausasitesp, 0), TRIM(vcveautRT),TRIM(vATsupervisadoRT),
					TRIM(vctenuevo),vcreditojoven,TRIM(NVL(vlugartrabajo, '')),NVL(vciudadTrabajo,0), NVL(vcoloniaTrabajo, 0),NVL(vcalleTrabajo, 0),
					NVL(iNumerocasaTrabajo, 0),TRIM(NVL(vdeptointeriorTrabajo, '')), TRIM(NVL(vrumbotrab, '')), TRIM(NVL(vcomplementotrab, '')),
					TRIM(NVL(ventrecallesTrabajo, '')), NVL(cUnidadHabitTrabajo, '0'), NVL(vuhcmanzanaTrabajo, 0), NVL(vuhcotrosTrabajo, 0), NVL(vuhcandadorTrabajo, 0), 
					NVL(vuhcetapaTrabajo, 0), NVL(vuhcloteTrabajo, 0), NVL(vuhcedificioTrabajo, 0),NVL(vuhcentradaTrabajo, 0),NVL(vteltrabajo, 0), NVL(vextensiontrabajo, 0), 
					TRIM(NVL(vpuesto,'')),NVL(vopcionpuesto, 0), TRIM(NVL(cFechAntigTrab, '1900/01/01')),TRIM(NVL(vcteconyuge,'0')), TRIM(NVL(vnombreunoconyuge, '')),
					TRIM(NVL(vnombredosconyuge, '')),TRIM(NVL(vApellPatCony, '')), TRIM(NVL(vApellMatCony, '')),TRIM(NVL(cSexoConyuge, '')),
					TRIM(NVL(vlugartrabajoconyuge, '')), NVL(vciudadconyuge, 0), NVL(vcoloniaconyuge, 0), NVL(vcalletrabajoconyuge, 0),NVL(iNumerocasaconyuge, 0),
					TRIM(NVL(vdeptoointeriorconyuge, '')), TRIM(NVL(vrumbotrabcony, '')), TRIM(NVL(vcomplementocony, '')),TRIM(NVL(ventrecallesconyuge,'')),
					NVL(cflaguhtconyugue, 0),NVL(vuhymanzana, 0),NVL(vuhyotros, 0), NVL(vuhyandador, 0), NVL(vuhyetapa, 0), NVL(vuhylote, 0), NVL(vuhyedificio, 0),
					NVL(vuhyentrada, 0),NVL(vteltrabajoconyuge, 0),NVL(vtelcelconyuge, 0),NVL(vcveconyugefamilia,''),TRIM(NVL(vcteref,0)),
					TRIM(NVL(vnombre1ref, '')),TRIM(NVL(vnombre2ref, '')), TRIM(NVL(vApellPatRef, '')),TRIM(NVL(vApellMatRef, '')), 
					TRIM(NVL(cSexoref, '')),NVL(vciudadref1,0),NVL(vcoloniaref1,0) ,NVL(vcalleref1,0),NVL(iNumerocasaref1,0),
					NVL(vdeptointeriorref1,''),NVL(vrumboref1,''), NVL(vcomplementoref1,'E'),NVL(ventrecallesref1,''),
					NVL(cflaguhtref1,0),NVL(vuhymanzanaref1,0),NVL(vuhyotrosref1,0),NVL(vuhyandadorref1,0),NVL(vuhyetaparef1,0),
					NVL(vuhyloteref1,0),NVL(vuhyedificioref1,0),NVL(vuhyentradaref1,0),NVL(vteltrabajoref1,0),
					NVL(vtelcelref1,0),NVL(iSecuenciaref1,''),NVL(vcteref2,0), TRIM(NVL(vnombre1ref2, '')),
					TRIM(NVL(vnombre2ref2, '')),TRIM(NVL(vApellPatRef2, '')),TRIM(NVL(vApellMatRef2, '')),
					TRIM(NVL(cSexoref2, '')),NVL(vciudadref2,0),NVL(vcoloniaref2,0),NVL(vcalleref2,0),NVL(iNumerocasaref2,0),
					NVL(vdeptointeriorref2,''),NVL(vrumboref2,''),NVL(vcomplementoref2,'E'),NVL(ventrecallesref2,''),
					NVL(cflaguhtref2,0),NVL(vuhymanzanaref2,0),NVL(vuhyotrosref2,0),NVL(vuhyandadorref2,0),NVL(vuhyetaparef2,0),
					NVL(vuhyloteref2,0),NVL(vuhyedificioref2,0),NVL(vuhyentradaref2,0),NVL(vteltrabajoref2,0),NVL(vtelcelref2,0),
					NVL(iSecuenciaref2,''),vref2, vref3, vmarcadatosin,vtiporeposicion,vreposicion,vflagentregotarjeta,
					NVL(vefectuo, 0),TRIM(NVL(vtiendafolio, '0')),TRIM( NVL(vfolio,'0') ),NVL(dfechaaltacte, DATE(1)),vflagnoreconocehuella,
					vfoliotienda,TRIM(NVL(vrfc, '')),TRIM(vcveburo),vfolioaut,vfolioconsulta,vfolioconcir,vnegocio,vsubnegocio,vEmpautorizo,
					TRIM(vtipo),TRIM(NVL(cfechamovto, '1900/01/01 01:00:00')), TRIM(NVL(vnumsolcred, '')),TRIM(NVL(vnumcte, '')),NVL(vtdafolioant,'0'),
					NVL(vfolioanterior,0),vcveproducto, vflagactualizacion, vSistsegsocial,vTiposueldoext,vNumEmps,vSubopcionpuesto, vPuestoext,
					vOpcionpuestoext,vNumEmpsext,vSubopcionpuestoext, vTipoOrigen,vTipoProducto,TRIM(NVL(vtienda, '0')),
					TRIM(NVL(cFecha_hoy, '1900/01/01')),NVL(iPuntuacion,0),NVL(cMarcaHit,''),iEmpSubCob,sFlagCapHuella,
					TRIM(cMarcarConsultado),NVL(sFlagTestParam,0),sFlagCapCobranza,NVL(iEmpGteAutori,0),NVL(cFlagConsBuro,''),
					NVL(cBuroPilotoTestig,''),TRIM(NVL(cNacionalidad,'')),TRIM(NVL(cNoFm3,'')),TRIM(NVL(cEmail,'')),TRIM(NVL(cApellCasada,'')),TRIM(NVL(cPais,'')),
					TRIM(NVL(cNoIMSS,'')),TRIM(NVL(cEstado,'')),cDelegMunicip,TRIM(NVL(cNumInterior,'')),sPropNegocio, 
					NVL(sParceles,0), NVL(sParAltoRiesgo,0), NVL(sParPrestamo,0),cModeloCel,NVL(cFechaConsBuro, '1900/01/01'),NVL(iMontoIngMensual,0),
					NVL(iCapSistematicabono,0),NVL(iTopeAbonoCoppel,0),NVL(iLineaCrediTope,0),NVL(iCapMaximaAbono,0),NVL(iCapRealAbono,0),NVL(iLineaCredReal,0),
					NVL(iCompromisosSic,0),NVL(iFlagLineaCredEsp,0),TRIM(NVL(ccteConyugebcpl,'0')),TRIM(NVL(ccteref1bcpl,'0')),TRIM(NVL(ccteref2bcpl,'0')),NVL(cFolioSucursal,'0'),NVL(pFechaAct,DATE(1)),
					NVL(cStatusbcplaux,''), NVL(cMotivobcpl,''), cFlagProspecto, NVL(vNumCteProspecto,''), iParAltoRiesgoNvo, iPagoUlt12meses,
					NVL(iId_Situaciones,0), TRIM(NVL(cPuntualidad_ref1, '')), TRIM(NVL(cPuntualidad_ref2, '')), NVL(sFlag_altadirecta_asupervisar,0), NVL(iPuntos_Var_Param,0), NVL(iPuntos_Var_SIC,0), NVL(iScore_domicilio,0), NVL(sNuevo_puntajefinal,0),
					sNum_producto_bco, cStatus_solicitud_bco, dMonto_lc_bco, dtFecha_resp_bco,TRIM(NVL(cOrigenSolic,'0')),cGpoEval,cGpoHit, cFlagProductoCoppel,TRIM(NVL(cflag_motoscoppel,'0')),TRIM(NVL(cCtepresento_comping,'0')));

					LET iContReg = 1;

					LET cObservs = TRIM('Paso 68');
					LET iFolioIns = vfolio;
					LET vEfectuoRTOS=0; --DSB20180621
					LET sNum_producto_bco			= 0;		
					LET cStatus_solicitud_bco		= '';	
					LET dMonto_lc_bco				= 0;		
					LET dtFecha_resp_bco			= DATE(1);	
					LET cOrigenSolic				= '0';						
					LET cGpoEval					= '0';						
					LET cGpoHit						= '0';	
					LET cNumSolicMixta 				= '';
					
				ELSE 
						LET vCodRetorno = '000003';
						LET iContReg = 2;
				END IF;
			END FOREACH;
--EBH 27/11/2019
                        Delete From bdinteg:"informix".si_tramasbatch where statusbcpl='IN';
--EBH 27/11/2019
		END IF;
	
		--Ejecuta el sp para el cliente prospecto
		LET cObservs = TRIM('Paso 69');
		IF bBorrado = 'F' THEN
			TRUNCATE TABLE bdinteg:"informix".si_tramasbatch;
		END IF;
		LET cObservs = TRIM('Paso 70');
		IF inumSecuencia > 0 THEN 
			UPDATE bdinteg:"informix".si_archivosecuenciamax SET secuencia_max=inumSecuencia; 
		END IF;	 
	ELSE 
		LET vCodRetorno = '000001';
		LET iContReg = 2;
	END IF;
	
    LET cObservs = TRIM('Paso 71');
	CALL bdinteg:"informix".sp_genera_archivosbatch_prospecto( pempresa, pFechaAct ) returning vCodRetorno;
	IF vCodRetorno::INTEGER < 0 THEN
		RETURN vCodRetorno;
	END IF;
	
	IF iContReg = 1 THEN	
		LET vCodRetorno = '000000';
	ELIF iContReg = 0 THEN	
		LET vCodRetorno = '000005'; 
	END IF;
	
	RETURN vCodRetorno;
END;
END PROCEDURE
DOCUMENT
'Descripcion: Se agregaron nuevos campos para insertar en la tabla si_tramasbatch',
'Autor: 96292199-Braulio Angulo',
'BD: bdinteg',
'Fecha: 04/02/2016',
'Solicita:Rodolfo Gomez',
'---------------------------------------------------------------------',
'Folio.........: 1875-INC_BATCH',
'Autor.........: 95526749 - Jesus Horacio Lopez Gonzalez',
'Fecha.........: 03/04/2018 - DSB20180403; 09/04/2018 - DSB20180409; 21/06/2018 - DSB20180621; 22/06/2018 - DSB20180622',
'Modificacion..: DSB20180403, Se realiza reingenieria de SP, se modifica para tomar todos los movimientos de la solciitud, para arreglar', 
'............... incidencias de que se enviaba dobles movimientos de Alta o de que no se enviaban solicitudes, entre otras cosas.',
'............... DSB20180409, Se modifica agregando los Pasos al sp a peticion de Abraham y se modifica una validacion que tenia de',
'............... comparar entero con char, y se cambia una asignacion que se hacia de fecha que podria marcar error de conversion de formato.',
'............... DSB20180410, Se modifica para reducir el tiempo de ejecucion del sp y para que traiga un registro de la tabla ss_solicitud_os',
'............... cuando haya 2 registros o mas con la misma secuenciaos',
'Sustento......: Se definio por correo, el dia 22/03/2018, asunto: Re: Envio archivo de pruebas batch con informacion del 11-01-2018.',
'............... DSB20180621, Se modifica para que en caso de que la fechanacimiento sea menor a 1900 mandar fecha default(1900/01/01)',
'............... y para que muestre efectuo correctamente, ya que se enviaba en 0',
'............... DSB20180622, Se modifica para quitar IF EXISTS para bajar los costos del SP',
'Sustento......: DSB20180403- Se definio por correo, el dia 22/03/2018, asunto: Re: Envio archivo de pruebas batch con informacion del 11-01-2018.',
'............... DSB20180622- Se definio por correo, el dia 22/06/2018, asunto: Fwd: Solicitud de costeo en produccion, por anarvaez@bancoppel.com',
'Solicita......: Juan Olivares',
'BD............: bdinteg',
'Modificacion: Irma Ureta',
'Descripcion: Se anexa validacion para el tipo origen de la solicitud, cuando se encuentre dada de alta en la tabla ss_solicitudes y se encuentre dada',
'			     alta en la tabla si_solicitud_movil el tipo origen sera M, si solo de encuentra en la tabla ss_solicitudes el tipo origen sera G y si',
'			     no se encuentra en ninguna de las tablas el tipo origen sera N.',
'Fecha: 21/12/2018',
'BD: bdinteg',
'----------------------------------------------------------------------------------------------------------------',
'Descripcion: Se agregaron nuevos campos para insertar en la tabla si_tramasbatch',
'Autor: Rodolfo Tortolero',
'BD: bdinteg',
'Fecha: 02/04/2019',
'Solicita:Abraham Narvaez',
'----------------------------------------------------------------------------------------------------------------',
'FOLIO: Peticion 598.1 - RQM 09 488-3 IMPLEMENTACIONN - ADENDUM - Homologacion de Clientes BanCoppel - Coppel en alta unica (Mensaje PP y % inicial de pago)',
'MODIFICACION: SE AGREGA VALIDACION PARA IDENTIFICAR EL CANAL DE ORIGEN DE LA SOLICITUD (SUCURSAL, CALLE O COPPEL.COM)',
'AUTOR: ISARAI BOJORQUEZ',
'BD: BDINTEG',
'AUTOR: 23/07/2019',
'EITQUETA: RQM-598.1',
'Modificacion: 97879606 - Adrian Eduardo Lizarraga Cazares',
'Folio: 660',
'RQM: RQM 09 553 Ofertar credito Coppel a todos los solicitantes en Alta unica',
'Descripcion: Se omite la validacion que igual a C el estado civil en caso de ser conyuge, ahora puede ser conyuge en union libre',
'			  a demas, se agregar el campo factor_techo a la consulta de la tabla bdisolic: ss_solicitudes para agregarlo en la tabla',
'			  bdinteg: si_tramasbatch.',
'Fecha: 2020/04/13',
'Solicito: Abraham Narvaez',
'BD: BDINTEG',
'----------------------------------------------------------------------------------------------------------------',
'MODIFICACION: 99802102 - Yonaiker Morillo',
'Folio: 747',
'RQM: RQM 09 541-2 credito Motos Coppel en Alta unica ',
'Descripcion: Se contemplaron los campos "flag_motoscoppel", "ctepresento_comping" para insertar en la tabla si_tramasbatch',
'Fecha: 28/05/2021',
'Solicito: Abraham Narvaez',
'BD: BDINTEG',
'----------------------------------------------------------------------------------------------------------------',
'Folio: 1977',
'Autor: Jesus Ivan Garcia Guicho',
'Fecha: 05/07/2021',
'Descripcion: Se modifica variable vCodRetorno por <> 0 para que retorne el error presentado cuando se ejecute el sp: sp_genera_archivosbatch_prospecto',
'Etiqueta: --DSB20210705 ',
'BD: bdinteg',
'----------------------------------------------------------------------------------------------------------------',
'Descripcion: Se modifica campo numeroextcalle, que cuando este traiga un valor que sobre pase los 32767 y 32767, remplazar por el valor default que en este caso serÃ¡ 0',
'Autor: 95992243 - Trinidad Hernandez',
'BD: bdinteg',
'Fecha: 10/08/2021',
'Solicita: Abraham Narvaez',
'---------------------------------------------------------------------',
'FECHA: 12/09/2024',
'MODIFICACION: Se agrega validacion sobre la sucursal virtual 8503 para recuperar la sucursal fisica donde se origino la solicitud por medio del DUD ',
'SOLICITO: Aracely Urena',
'AUTOR : Jesus Isaias Bueno Castro',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_rep_sem_prospecteo_solicitudes()
RETURNING
    CHAR(6) AS Codigo_retorno;

    DEFINE iSqlErr        INTEGER;
    DEFINE cF_ini         DATE;
    DEFINE cF_fin         DATE;    
    DEFINE cCodRet        CHAR(6);
    DEFINE cRuta          CHAR(100);
    DEFINE cNomArchAux    CHAR(100);
    DEFINE cNomSqlTmp     CHAR(120);
    DEFINE cSql           CHAR(2500);
    DEFINE cConsulta      CHAR(2200);

    LET iSqlErr      = 0;
    LET cCodRet      = '00000';
    LET cF_ini       = '';
    LET cF_fin       = '';
    LET cRuta        = '';
    LET cNomArchAux  = '';
    LET cNomSqlTmp   = '';
    LET cSql         = '';
    LET cConsulta    = '';

BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    SELECT valor
      INTO cRuta
      FROM "informix".si_param  
     WHERE empresa = '001'
       AND cod_param = 482;

    IF dbinfo("sqlca.sqlerrd2") = 0 THEN
        LET cCodRet = '000001';
        RETURN cCodRet;
    END IF;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    LET cF_ini = TODAY - 7;
    LET cF_fin = TODAY - 1;

    -- RQM 1697-2
    LET cConsulta =
        " select b.sucursal as SucSolicitud ,"||
        " d.tipo_cliente as TipoCte ,"|| 
        " b.numcte as NnumCte,"|| 
        " d.fecha_insert as AltaCte,"||
        " e.fecha_alta as fecha_alta_idof,"|| 
        " b.fecha_insert as FecSolProspecto,"|| 
        " b.num_solicitud as NumSolicitud,"|| 
        " b.status_solicitud as Estatus,"||                            
        " c.fecha_hora as FecHora"||  
        " from bdisolic:ss_solicitudes b,"||
        " bdisolic:ss_autorizacion c, bdinteg:si_cliente d,"||
        " outer ( bdidigital@coppelimg_tcp:'informix'.dg_expediente e,"||
        "         bdidigital@coppelimg_tcp:'informix'.dg_grupodocto f,"||
        "         bdidigital@coppelimg_tcp:'informix'.dg_tipodocumento g )"||
        " where c.num_solicitud = (select max(num_solicitud) "||
        "                       from bdisolic:ss_autorizacion "||
        "                      where num_solicitud = b.num_solicitud "||
        "                        and status_solicitud = b.status_solicitud) "||
        " and b.fecha_insert >= '"||cF_ini||"'"||
        " and b.fecha_insert <= '"||cF_fin||"'"||
        " and b.num_solicitud = c.num_solicitud"||
        " and b.status_solicitud = c.status_solicitud"||
        " and b.numcte = d.numcte"||
        " and b.numcte = e.cliente"||
        " and e.fecha_alta = (select min(fecha_alta) "||
        "                     from bdidigital@coppelimg_tcp:'informix'.dg_expediente"||
        "                    where cliente = b.numcte"||
        "                      and producto = b.num_producto)"||
        " and e.secuencia = 1"||
        " and e.cod_docto = g.cod_docto"||
        " and e.cuenta = '99999999999'"||
        " and g.cod_grupo = f.cod_grupo"||
        " and f.cod_grupo = '001'"||
        " order by d.tipo_cliente, b.num_solicitud, c.fecha_hora";
    -- RQM 1697-2

    LET cNomArchAux =
        'RAU_'||TO_CHAR(cF_ini,'%Y%m%d')||'_'||TO_CHAR(cF_fin,'%Y%m%d')||'.txt';

    LET cNomSqlTmp =
        'qryRepPteo_'||TO_CHAR(CURRENT,'%Y%m%d%H%M%S')||'.sql';

    LET cSql =
        'echo "unload to '||TRIM(cRuta)||TRIM(cNomArchAux)||
        ' DELIMITER ''|'' '||TRIM(cConsulta)||'" > '||
        TRIM(cRuta)||TRIM(cNomSqlTmp);
    SYSTEM cSql;

    LET cSql = 'dbaccess bdinteg '||TRIM(cRuta)||TRIM(cNomSqlTmp);
    SYSTEM cSql;

    LET cSql = 'rm -f '||TRIM(cRuta)||TRIM(cNomSqlTmp);
    SYSTEM cSql;

    RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'Folio: RQM 1697-2',
'Autor: 99802161 Narciso IvÃ¡n Cisneros Acosta',
'Fecha: 22/09/2025',
'Modificacion: Se modifica la consulta para quitar la relaciÃ³n con ss_prospecteo que limitaba la cantidad de resultados y no contemplar todas las sucursales',
'Sustento: RQM 1697-2  ActualizaciÃ³n de reportes.',
'Solicita: David GarcÃ­a Jurado LÃ³pez.',
'Base de datos: BDINTEG',
'----------------------------------------------------------------------------',
'Folio: CORIMA 3220482',
'Autor: Eduardo Ãvila PÃ©rez Tagle',
'Fecha: 07/04/2026',
'Modificacion: Se realizan ajustes al procedimiento almacenado para corregir los comandos del sistema operativo ejecutados desde el SP',
'Sustento: AtenciÃ³n al incidente intermitente con error -668 presentado durante la ejecuciÃ³n del Job',
'Solicita: JosÃ© RaÃºl Negrete Llanes',
'----------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_bloqueausuariobpi()
RETURNING VARCHAR(6),VARCHAR(80),INTEGER;

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  v_numcte         VARCHAR(20);
define dfecha date;
define cTipo  varchar(5);
define iDias  integer;
define iBloq  integer;
define iEje  integer;
define iNum  integer;
define iCont  integer;
define iCont2 integer;
define iCont3 integer;

--RealizÃÂ³: Manuel Osuna Valencia
--Fecha: 06/07/2010
--SolicitÃÂ³: Ismael Hernandez
--Actividad: Cambia de estatus del perfil a los usuarios que no cumplan las directivas de la tabla de parametros

Begin
	 ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	      LET P_COD_RET    = SQL_ERR;
	      LET P_MENSAJE  = ERROR_INFO;
	      RETURN P_COD_RET, P_MENSAJE,iCont;
	 END EXCEPTION;

    --SET DEBUG FILE TO "/ifxsif01/JuanRivera/traces/sp_bloqueausuariobpi.out";
    --TRACE ON;
	
	  /*
	  Las instruccciones SEt que me dijo Gaby 
	  son para establecer aislamiento en la estabilidad 
	  del cursor   lectura y bloque en espera
      */	  
	  --- SET ISOLATION TO CURSOR STABILITY;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	LET P_COD_RET = '00000';
	LET P_MENSAJE = 'PROCESO EXITOSO';
	LET iCont = 0;

	select limit 1
		case when id_param = '07' and (valor is null or valor = "" ) then 'Falta Parametro 07' 
		     when id_param = '08' and (valor is null or valor = "" ) then 'Falta Parametro 08' 
		     when id_param = '09' and (valor is null or valor = "" ) then 'Falta Parametro 09' 
		     when id_param = '10' and (valor is null or valor = "" ) then 'Falta Parametro 10' 
		     when id_param = '11' and (valor is null or valor = "" ) then 'Falta Parametro 11' 
		     when id_param = '10' and (select count(*) from bdibpi:bpi_auxparam where id_param = id_param) =0 then 'No existen status en bpi_auxparam' 	
	      	     else "0"
		end into  P_MENSAJE
	from bdibpi:bpi_param  where id_param in ('07','08','09','10','11')
	group by 1;

	IF (P_MENSAJE == "0") THEN 

		
		select valor into cTipo  from bdibpi:bpi_param 	where id_param  = "07" and current between f_inicio and f_fin;
		select 
			sum(case when id_param = '08' then valor::int end),
			sum(case when id_param = '09' then valor::int end),			
			sum(case when id_param = '11' and cTipo = "D"  then 1  
				 when id_param = '11' and cTipo = "S"  and (date(current) - date(f_fin) = 7) then 1  
			         when id_param = '11' and cTipo = "M"  and (date(f_fin + Interval(1) month to month) = date(current)) then 1 
			         else 0	
        	            end) into iDias,iBloq,iEje
	       from bdibpi:bpi_param  where id_param in ('08','09','10','11');
		
	       IF (iEje == 1) THEN

				LET P_MENSAJE = 'PROCESO EXITOSO';
			
				select fecha_ant into dfecha from bdinteg:si_fechas;
		
				select count(*) into iCont from  si_bpiusuarios  
				where id_status in (select a.valor from bdibpi:bpi_param p,bdibpi:bpi_auxparam a
									where a.id_param = p.id_param)
				and nvl(f_ultimo_acceso,null) is null						
				and (date(dfecha) - date(f_registro)) >= iDias;

				IF (iCont > 0) THEN
				
				
					update si_bpiusuarios  set id_status = iBloq
					where id_status in (select a.valor from bdibpi:bpi_param p,bdibpi:bpi_auxparam a
											where a.id_param = p.id_param 	 ) 
					and nvl(f_ultimo_acceso,null) is null	
					and (date(dfecha) - date(f_registro)) >= iDias;						

				ELSE
					LET P_MENSAJE = 'NO EXISTIERON REGISTROS POR ACTUALIZAR';
					
				END IF;
			
			
				select count(*) into iCont from  si_bpiusuarios  
				where id_status in (select a.valor from bdibpi:bpi_param p,bdibpi:bpi_auxparam a
									where a.id_param = p.id_param)			
				and (date(dfecha) - date(f_ultimo_acceso)) >= iDias;

				IF (iCont > 0) THEN
				
				
					update si_bpiusuarios  set id_status = iBloq
					where id_status in (select a.valor from bdibpi:bpi_param p,bdibpi:bpi_auxparam a
											where a.id_param = p.id_param 	 ) 
					and (date(dfecha) - date(f_ultimo_acceso)) >= iDias;						

					

				ELSE
					LET P_MENSAJE = 'NO EXISTIERON REGISTROS POR ACTUALIZAR';
					
				END IF;
			
				update bdibpi:bpi_param set f_inicio = current,f_fin = current where id_param = '11';
				
			    select count(*) into iCont2 from  si_bpiusuarios  
				where id_status in ('1','2','3','4')			
				and nvl(f_ultimo_acceso,null) is null						
				and (date(dfecha) - date(f_registro)) >= iDias;

				IF (iCont2 > 0) THEN
				
				
					update si_bpiusuarios  set id_status = '99'
					where id_status in ('1','2','3','4') 
					and nvl(f_ultimo_acceso,null) is null	
					and (date(dfecha) - date(f_registro)) >= iDias;	
                ELSE
                    LET P_MENSAJE = 'NO EXISTIERON REGISTROS POR CANCELAR';	

                End IF;

                -- Contar registros que cumplen con las condiciones
                SELECT COUNT(DISTINCT b.numcte)
                INTO iCont3
                FROM bdinteg:si_bpiusuarios b
                INNER JOIN bdinteg:si_cambiostcte AS c
                     ON c.numcliente = b.numcte 
                WHERE b.id_status IN ('1', '2', '3', '4')
                  AND c.id_statusanterior = '10';	
           
			   -- Verificar si hay registros para procesar
                IF (iCont3 > 0) THEN
                
                    -- Recorrer los registros que cumplen con las condiciones
                    FOREACH SELECT DISTINCT b.numcte 
					        INTO v_numcte
                            FROM bdinteg:si_bpiusuarios b
                            INNER JOIN bdinteg:si_cambiostcte c 
                                 ON c.numcliente = b.numcte 
                                 WHERE b.id_status IN ('1', '2', '3', '4')
                                 AND c.id_statusanterior = '10'
                
                        -- Verificar si existe un registro en si_cambiostcte con las condiciones dadas
                        IF EXISTS (
                            SELECT 1
                            FROM bdinteg:si_cambiostcte c
                                            WHERE c.numcliente = v_numcte
                              AND c.id_statusanterior = '10'
                        ) THEN
                
                            -- Actualizar el estado en si_bpiusuarios
                            UPDATE si_bpiusuarios
                            SET id_status = '10'
                            WHERE numcte = v_numcte;
                
                        END IF;
                
                    END FOREACH;
                
                ELSE
                    -- Mensaje si no hay registros para actualizar
                    LET P_MENSAJE = 'NO EXISTIERON REGISTROS POR ACTUALIZAR';
                END IF;

			ELSE
				LET P_MENSAJE = 'HOY NO TOCA ACTUALIZAR REGISTROS';		

			END IF;				

		
	ELSE
		LET P_COD_RET = '00001';		
	END IF;
	
	RETURN P_COD_RET,P_MENSAJE,iCont;
	
END;
END PROCEDURE;