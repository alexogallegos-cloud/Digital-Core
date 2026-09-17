CREATE PROCEDURE "informix".sp_batch_generarinformacion_busqueda(pempresa CHAR(3), pFechaAct DATE, pNum_solicitud CHAR(20))
RETURNING CHAR(6);
DEFINE cNoFm3 CHAR(18);
DEFINE cEmail CHAR(60);
DEFINE vcve,vcveant,varea, vrumbo,vrumbotrab,vrumboref1,vrumboref2,vrumbotrabtmp,vcasapropia,vsexo,vestadocivil,vescolaridad,vtiposueldo,vsitesp,vsitespaux,vcveautRT,
vATsupervisadoRT,vctenuevo,vcreditojoven,vpuesto,cSexoConyuge,vrumbotrabcony,vcveconyugefamilia,cSexoref,  vcveref1 , cSexoref2 ,  vcveref2 , vmarcadatosin ,
 vflagentregotarjeta , vflagnoreconocehuella , vtipo , vTipoOrigen , cBuroPilotoTestig , cModeloCel , cflaguht, cUnidadHabit, cUnidadHabitTrabajo,cTipRechazo,
 cTipRechazoOs,iSecuenciaref1,iSecuenciaref2,vcvefamiliatmp,cSexoConyugetmp, cFlagProspecto, vVigenciaStatus, vVigenciaCliente, vaceptadosupervisadorechazado,
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
 vfoliotienda,iRefSecusConyugue,iRefSecuencias1,iRefSecuencias2, iGrupo,iIsamErr,iTopeMax,vciudadref1,vciudadref2,vcoloniaref1,vcoloniaref2,vcalleref1,
 vcalleref2,vcalletrabajotmp,iSecuenciatmp,iRefSecustmp,ibandtdaFolOs , iParAltoRiesgoNvo, iPagoUlt12meses, iId_Situaciones, iPuntos_Var_Param,
 iPuntos_Var_SIC, iScore_domicilio INTEGER;
DEFINE iIngreso DECIMAL(18,2);
DEFINE vdeptointerior,vdeptoointeriorconyuge,vdeptointeriorTrabajo,vfolioaut,cNumInterior, cFolioSucursal,cNumInteriorTrabajo,vdeptointeriorref1,
vdeptointeriorref2,vdeptoointeriortmp,vtiendafolio, vtdafolioant,vtienda CHAR(4);
DEFINE vcomplemento,vcomplementotrab,vcomplementocony,vcomplementoref1,vcomplementoref2,vcomplementotmp CHAR(80);
DEFINE ventrecalles, ventrecallesconyuge,ventrecallesTrabajo,ventrecallestmp,cErrorInfo,cDescError,ventrecallesref1,ventrecallesref2  CHAR(40);
DEFINE vtel, vtelcel,vteltrabajo,vteltrabajoconyuge,vtelcelconyuge,vtelcelref1,vtelcelref2,iEmpGteAutori,vteltrabajotmp,vtelceltmp,vtelreftmp,vteltrabajoref1,
vteltrabajoref2,iNumerocasa,iNumerocasaTrabajo,iNumerocasaconyuge,iNumerocasaref1,iNumerocasaref2,iNumerocasatmp INT8;
DEFINE dFechaConsBuro,vfechanacimiento,vfechaltacte,vfechamovto, vFecha_Hoy,dFechaAlta,dFechaRespuesta,dFechaEntrada,dFechaSalida, dfechaaltacte DATE;
DEFINE vniptitular, vnipadicional  CHAR(7);
DEFINE vcveburo,cMarcarConsultado,cFlagConsBuro,vTipo_Dir,cMarcaHit, vcveidentificacion,cStatus2,cStatus, cStatusPenul,cStatusbcpl, cStatusAntp ,cStatusParam,
 cStatusbcplaux CHAR(2);
DEFINE cfechanac, cfechadecuandovive, cFechAntigTrab,vfolioconcir,cFechaConsBuro,cFecha_hoy CHAR(10);
DEFINE vcurp,vcveelector CHAR(18);
DEFINE videntificacion,cEmpGteAutori CHAR(8);
DEFINE vrfc CHAR(13);
DEFINE vfolioconsulta CHAR(9);
DEFINE cfechamovto CHAR (19);
DEFINE vTipoProducto CHAR(5);
DEFINE cNacionalidad,cPais,cEstado,cDelegMunicip,cPaisTrabajo, cEstadoTrabajo, cMotivobcpl CHAR(3);
DEFINE cObservs char(80);

DEFINE cNoIMSS CHAR(12);
DEFINE vHora DATETIME HOUR TO FRACTION(3);
DEFINE cDescripElemento CHAR(50);
DEFINE vCodRetorno Char(6);
DEFINE bMovimiento, bBorrado BOOLEAN;
DEFINE vFechaHoraP DATETIME  YEAR TO SECOND;
DEFINE vFechaHoraMax DATETIME  YEAR TO SECOND;
DEFINE vFechaHora DATETIME  YEAR TO SECOND;
DEFINE cTrama LVARCHAR (32000);
--INCIDENCIAS
DEFINE vRuta CHAR (90);
DEFINE vsSQL LVARCHAR (32739);
DEFINE cFecha_hoy_inc CHAR(8);
DEFINE sPreNomArchivoFinal VARCHAR(100);
DEFINE sNombreArchivoFinal VARCHAR(100);
DEFINE sAntNomArchivoFinal VARCHAR(100);
DEFINE sAnterNomArchivoFinal VARCHAR(100);

--INCIDENCIAS
LET vsSQL = '' ;
LET cFecha_hoy_inc = '19000101';
LET sPreNomArchivoFinal ='';
LET sNombreArchivoFinal ='';
LET sAntNomArchivoFinal ='';
LET sAnterNomArchivoFinal='';

LET iRefSecusConyugue=0;LET iRefSecuencias1 =0;LET iRefSecuencias2 =0;LET vcve = '';LET vcveant = '';LET vcaja = 100;LET varea = 'N';LET vcte_ref = '0';
LET vcte_refcop = '0'; LET vcte_refcop2 ='0';LET vnombre1 = '';LET vnombre2 = '';LET vapell_paterno = '';LET vapell_materno = '';LET vcurp = '';
LET vcveelector = '';LET vcveidentificacion = '';LET videntificacion = '';LET vciudad = 0;LET vcolonia = 0;LET vcalle = 0;LET iNumerocasa = 0;
LET vdeptointerior = '';LET vrumbo = '';LET vcomplemento = '';LET ventrecalles = '';
LET vuhcmanzana = 0;LET vuhcotros = 0;LET vuhcandador = 0;LET vuhcetapa = 0;LET vuhclote  = 0;LET vuhcedificio = 0;LET vuhcentrada = 0;LET vtel = 0;
LET vtelcel = 0;LET vcasapropia = '';LET vniptitular = '';LET vnipadicional = '';LET vsexo = '';LET vestadocivil = '';LET cfechanac = '1900/01/01';
LET cfechadecuandovive = '1900/01/01';LET vpersonasvivenendomicilio = 0;
LET vescolaridad = '';LET vtiposueldo = '';LET vnumerodependientes = 0;LET vpersonastrabajan = 0;LET vlimitecredito = 0;LET vingresomensual = 0;
LET vsitesp = '';LET vsitespaux = ''; LET vcausasitesp = 0;LET vcveautRT = '2';LET vATsupervisadoRT = 'P';LET vctenuevo = 'N';LET vcreditojoven = '';LET vsitesp_resp = '';
LET vcausasitesp_resp = 0; LET vcausasitespaux = 0;
LET vpuesto = '0';LET vopcionpuesto = 0;LET cFechAntigTrab = '1900/01/01';
LET vmarcadatosin = '';LET vtiporeposicion = 0;LET vreposicion = 0;LET vflagentregotarjeta = '';
LET vefectuo = 0; LET vEfectuoRTOS=0; LET vEfectuoAP=0; LET vtiendafolio = '0';LET vfolio = '0';LET dfechaaltacte = DATE(1);LET vflagnoreconocehuella = '';
LET vfoliotienda = 0;LET vrfc = '';LET vcveburo = '';LET vfolioaut = '';LET vfolioconsulta = '';LET vfolioconcir = '';LET vnegocio = 0;LET vsubnegocio = 0;
LET vEmpautorizo = 0;LET vtipo = '';LET cfechamovto = '1900/01/01 01:00:00';LET dFechaRespuesta=DATE(1);
LET dFechaEntrada = DATE(1);LET dFechaSalida = DATE(1);LET vnumsolcred = '';LET vnumcte = '';LET vtdafolioant = '0';LET vfolioanterior = 0;LET vcveproducto = 6500;LET vflagactualizacion = 0;LET vSistsegsocial = 0;LET vTiposueldoext = 0;
LET vNumEmps = 0;LET vSubopcionpuesto = 99;LET vPuestoext = 0;LET vOpcionpuestoext = 0;LET vNumEmpsext = 0;LET vSubopcionpuestoext = 0;LET vTipoOrigen = 'G';LET vTipoProducto = '01000';LET iEmpSubCob = 0;LET sFlagCapHuella = 1;LET cMarcarConsultado = '';LET sFlagTestParam = 0;LET sFlagCapCobranza = 0;LET iEmpGteAutori = 0;LET cEmpGteAutori ='';LET cFlagConsBuro = '';LET cBuroPilotoTestig = '';LET cNacionalidad = '';LET cNoFm3 = '';LET cEmail = '';LET cApellCasada = '';
LET cPais = '';LET cNoIMSS = '';LET cEstado = '';LET cDelegMunicip = '';LET cNumInterior = '';LET sPropNegocio = 0;LET sParceles = 0;LET sParAltoRiesgo = 0;LET sParPrestamo = 0;LET cModeloCel = '1';LET dFechaConsBuro = DATE(1);LET cFechaConsBuro = '';
LET iMontoIngMensual = 0;LET iCapSistematicabono = 0;LET iTopeAbonoCoppel = 0;LET iLineaCrediTope = 0;LET iCapMaximaAbono = 0;
LET iCapRealAbono = 0;LET iLineaCredReal = 0;LET iCompromisosSic = 0;LET iFlagLineaCredEsp = 0;LET ccteConyugebcpl = '';
LET ccteref1bcpl = '';LET ccteref2bcpl = '';LET cFolioSucursal = '0';LET vHora = '';LET cflaguht = '';
LET vfechanacimiento = DATE(1);LET vfechaltacte = DATE(1);LET vfechamovto = DATE(1);LET cUnidadHabit = '';LET vTipo_Dir = '';
LET vFecha_Hoy = DATE(1);LET vCodRetorno = '000000';LET dFechaAlta = DATE(1);LET iValor = 0;LET iTopeMax=0;LET iIngreso = 0;LET iPuntuacion = 0;LET cFecha_hoy = '1900/01/01';LET inumSecuencia= 0;
LET cMarcaHit = '';LET iElemento = 0;LET vciudadbanco = 0;LET vcoloniabanco = 0;LET cDescripElemento = '';LET iContReg = 0;LET cStatus = '';LET cStatus2 = '';LET iRowId = 0;
LET cNumSolRef='';LET cErrorInfo='';LET iIsamErr='';LET cDescError='';LET cTipRechazo='';LET cTipRechazoOs='';
LET vciudadtmp=0; LET vcoloniatmp=0;LET vciudadbancotmp=0;LET vcoloniabancotmp=0; LET vcalletrabajotmp=0; LET iNumerocasatmp=0;LET vdeptoointeriortmp=''; LET vrumbotrabtmp='';
LET vcomplementotmp='';LET ventrecallestmp=''; LET vuhymanzanatmp=0; LET vuhyotrostmp=0; LET vuhyandadortmp=0; LET vuhyetapatmp=0; LET vuhylotetmp=0; LET vuhyedificiotmp=0; LET vuhyentradatmp=0;
LET vteltrabajotmp=0; LET vtelceltmp=0; LET vtelreftmp=0; LET iSecuenciatmp=0;LET cctebcpltmp='0';
LET vctetmp='0';LET vnombreunotmp='';LET vnombredostmp='';LET vApellPattmp='';LET vApellMattmp='';LET vcvefamiliatmp='';LET cSexoConyugetmp='';LET iRefSecustmp=0;LET cflaguhtconyugue=0; LET vtienda='0';LET ibandtdaFolOs=0;LET cStatusbcpl= '';
LET cStatusbcplaux= '';LET cMotivobcpl='';LET cFlagProspecto='1';LET vNumCteProspecto='';LET iParAltoRiesgoNvo=-99999;LET iPagoUlt12meses=99999;
LET vFechaHoraMax="";LET vFechaHora="";LET vFechaHoraP = "";LET cStatusPenul='';LET cStatusAntp = "";LET cStatusParam = "";LET vVigenciaStatus='';LET vaceptadosupervisadorechazado = 'P';LET bBorrado = 'F';LET vvigenciacliente = ''; LET cObservs = '';

--CAMPOS NUEVOS
LET iId_Situaciones= 0;
LET cPuntualidad_ref1= '';
LET cPuntualidad_ref2= '';
--LET sFlagtestigoparametricocn= 0;
LET sFlag_altadirecta_asupervisar= 0;
LET iPuntos_Var_Param= 0;
LET iPuntos_Var_SIC= 0;
LET iScore_domicilio= 0;
LET sNuevo_puntajefinal= 0;
LET cTrama = '' ;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

--SET ISOLATION COMMITTED READ;

BEGIN
	ON EXCEPTION
	SET iSqlErr,iIsamErr,cErrorInfo
		LET vnumsolcred = vnumsolcred;
		--SET DEBUG FILE TO '/resplogifx/archivoscartera/altaunica/envios/pruebas_batch.out';
		--TRACE ON;
		
		IF iSqlErr <> 0 THEN
			LET vCodRetorno = iSqlErr;
			LET cDescError= cErrorInfo;
			--INCIDENCIAS
            --INSERT INTO "informix".si_bitacora_errorbatch (numerosolicitud,numcte,error,observaciones,trama,fecha_insert) VALUES (vnumsolcred,vnumcte,iSqlErr,cObservs,cTrama,NVL(vFecha_Hoy,DATE(1)));
			RETURN vCodRetorno;
		END IF;
	END EXCEPTION;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO "/tmp/sp_batch_generarinformacion.out";
		--SET DEBUG FILE TO "/pisa/pisabanco/sp_batch_generarinformacion.out";
		--SET DEBUG FILE TO '/informix/PRISCILLA/sp_batch_generarinformacion_busqueda.out';
		--TRACE ON;
		
	IF pFechaAct <> MDY(1,1,1900) OR pFechaAct IS NOT NULL THEN
		SELECT {+INDEX(bdinteg:"informix".si_fechas idx_si_fechas)} fecha_hoy INTO vFecha_Hoy FROM bdinteg:"informix".si_fechas WHERE empresa = pempresa;
		LET vFecha_Hoy = pFechaAct;
		IF vFecha_Hoy = MDY(1,1,1900) OR vFecha_Hoy IS NULL THEN
			LET vCodRetorno = '000002'; LET iContReg = 2;
		ELSE
			--TRUNCATE TABLE "informix".si_tramasbatch;
			--INCIDENCIAS
			--DELETE FROM bdinteg:"informix".si_tramasbatch WHERE secuencia = secuencia AND fecha_insert <> vFecha_Hoy;
			LET bBorrado = 'T';
			--INCIDENCIAS
            --DELETE FROM bdinteg:"informix".si_bitacora_errorbatch WHERE numerosolicitud = numerosolicitud and numcte = numcte and fecha_insert <> vFecha_Hoy;
			SELECT secuencia_max INTO inumSecuencia FROM bdinteg:"informix".si_archivosecuenciamax where empresa = pempresa and secuencia_max = secuencia_max;
			SELECT valor INTO iValor FROM bdisolic:"informix".ss_param WHERE secuencia = 363;
			SELECT valor INTO iTopeMax FROM bdisolic:"informix".ss_param WHERE secuencia = 373;
			
			SELECT NVL(valor,'') INTO cStatusParam FROM bdinteg:"informix".si_param WHERE cod_param=313 AND empresa= pempresa;

			--INCIDENCIAS
			SELECT TRIM(valor)
			INTO vRuta
			FROM bdinteg:"informix".si_param
			WHERE cod_param='193';		
			
            LET cObservs = TRIM('Paso 1');
			FOREACH WITH HOLD
				SELECT DISTINCT sss.num_solicitud, sss.numcte, ssa.fecha_entrada, sss.sucursal, sss.fecha_insert,ssa.status_solicitud, ssos.status, ssos.secuenciaos,ssos.status,ssos.situacionespecialrespuesta,ssos.causasituacionespecialrespuesta, ssos.fecha_respuesta,ssa.ejecutivo_auto, sss.user_insert, ssa.fecha_hora--,NVL(ssa.cliente_pros,''),NVL(ctes.cliente_pros,''),NVL(ssa.fecha_hora,'')
				INTO vnumsolcred, vnumcte, vfechaltacte, cFolioSucursal, dFechaAlta,cStatus, vATsupervisadoRT, vfolio,cTipRechazoOs,vsitesp_resp,vcausasitesp_resp, dFechaRespuesta,cEmpGteAutori,vEfectuoRTOS, cfechamovto--, vVigenciaStatus, vVigenciaCliente, vFechaHora
					FROM bdisolic:"informix".ss_autorizacion ssa
					inner join bdisolic:"informix".ss_solicitudes sss on (sss.empresa = ssa.empresa AND sss.num_solicitud = ssa.num_solicitud)
					LEFT OUTER JOIN bdisolic:"informix".ss_solicitud_os ssos ON (ssos.empresa = sss.empresa AND ssos.status <> 'P' AND ssos.fecha_respuesta = ssa.fecha_entrada AND ssos.num_solicitud = sss.num_solicitud)
					WHERE ssa.ROWID IN (SELECT MIN(ROWID) FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud=ssa.num_solicitud AND status_solicitud NOT IN ('PC','AN','CC','OS','CE','CM','MC','EC') AND fecha_entrada =ssa.fecha_entrada)
						AND ssa.num_solicitud matches '65*'
						AND ssa.fecha_entrada = pFechaAct
						AND ssa.num_solicitud = pNum_solicitud
						
						--INCIDENCIAS     --Se agrego la ultima condicion al foreach
						--AND sss.num_solicitud in('650184546408')
												

                    LET cObservs = TRIM('Paso 2');
				  
				LET vcte_ref = "0";LET inumSecuencia = inumSecuencia + 1;	LET iRefSecuencias1 =0; LET iRefSecuencias2 =0;LET iRefSecusConyugue=0;
				LET vciudadTrabajo=0; LET vcoloniaTrabajo=0;LET vcalleTrabajo=0; LET iNumerocasaTrabajo=0;LET vdeptointeriorTrabajo='';LET vrumbotrab='';
				LET vcomplementotrab=''; LET ventrecallesTrabajo='';LET cUnidadHabitTrabajo='0';LET vuhcmanzanaTrabajo=0;LET vuhcotrosTrabajo=0;
				LET vuhcandadorTrabajo=0;LET vuhcetapaTrabajo=0;LET vuhcloteTrabajo=0;LET vuhcedificioTrabajo=0;LET vuhcentradaTrabajo=0;LET vlugartrabajo = '';
				LET vcomplementotrab = '';LET cNumInteriorTrabajo= '';LET cPaisTrabajo ='';LET cEstadoTrabajo ='';LET vteltrabajo = 0;LET vextensiontrabajo = 0;  
				LET vcteconyuge = '0';LET vnombreunoconyuge = '';LET vnombredosconyuge = '';LET vApellPatCony = '';LET vApellMatCony = '';LET cSexoConyuge = '';
				LET vlugartrabajoconyuge = '';LET vciudadconyuge = 0;LET vcoloniaconyuge = 0;LET vcalletrabajoconyuge = 0;LET iNumerocasaconyuge = 0;
				LET vdeptoointeriorconyuge = '';LET vrumbotrabcony = '';LET vcomplementocony = 'E';LET ventrecallesconyuge = '';LET vflaguhy = 0;
				LET vuhymanzana = 0;LET vuhyotros = 0;LET vuhyandador  = 0;LET vuhyetapa = 0;LET vuhylote = 0;LET vuhyedificio = 0;LET vuhyentrada = 0;
				LET vteltrabajoconyuge = 0;LET vtelcelconyuge = 0;LET vcveconyugefamilia = 'E';LET vcteref = '0';LET vnombre1ref = '';LET vnombre2ref = '';
				LET vApellPatRef = '';LET vApellMatRef = '';LET cSexoref = '';LET vcveref1 = '';LET vcteref2 = '0';LET vnombre1ref2 = '';LET vnombre2ref2 = '';
				LET vApellPatRef2 = '';LET vApellMatRef2 = '';LET cSexoref2 = '';LET vcveref2 = '';LET vref2 = 0;LET vref3 = 0;LET vciudadref1=0;
				LET vciudadref2=0;LET vcoloniaref1=0;LET vcoloniaref2=0;LET vcalleref1=0;LET vcalleref2=0;LET iNumerocasaref1=0;LET iNumerocasaref2=0;
				LET vdeptointeriorref1='';LET vdeptointeriorref2='';LET vrumboref1='';LET vrumboref2='';LET vcomplementoref1='E';LET vcomplementoref2='E';
				LET ventrecallesref1='';LET ventrecallesref2='';LET cflaguhtref1='';LET cflaguhtref2='';LET vuhymanzanaref1=0;LET vuhymanzanaref2=0;
				LET vuhyotrosref1=0;LET vuhyotrosref2=0;LET vuhyandadorref1=0;LET vuhyandadorref2=0;LET vuhyetaparef1=0;LET vuhyetaparef2=0;LET vuhyloteref1=0;
				LET vuhyloteref2=0;LET vuhyedificioref1=0;LET vuhyedificioref2=0;LET vuhyentradaref1=0;LET vuhyentradaref2=0;LET vteltrabajoref1=0;
				LET vteltrabajoref2=0;LET vtelcelref1=0;LET vtelcelref2=0;LET iSecuenciaref1='';LET iSecuenciaref2=''; LET vNumCteProspecto='';
  
				LET bMovimiento="F";	
				LET cStatusbcpl='';
				LET cMotivobcpl='';

                LET cTrama = '' ;
				
                LET cObservs = TRIM('Paso 3');
				IF (cStatus NOT IN ("RT","OS","AT","AP") AND dFechaAlta <> pFechaAct) AND NVL(dFechaRespuesta,DATE(1)) <> pFechaAct THEN
					IF cStatus= 'BC' THEN
						
						SELECT DISTINCT status_solicitud INTO cStatus
						FROM bdisolic:"informix".ss_autorizacion
						WHERE ROWID IN(SELECT MIN(ROWID) FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud=vnumsolcred AND status_solicitud NOT IN ('PC','AN','CC','BC','OS','CE','CM','MC','EC') AND fecha_entrada =pFechaAct)
						AND fecha_entrada =pFechaAct AND num_solicitud=vnumsolcred;
					ELSE 
						CONTINUE FOREACH;
					END IF;
				END IF;
				
				LET vcve = "";
				LET vcveant = "";

				
                LET cObservs = TRIM('Paso 4');
                --DSB 30 de Marzo 2017 Bernardo BÃ¡ez Se modifica para evitar enviar cliente coppel en blanco
				--SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(a.numcte_ref) = "V" THEN a.numcte_ref::INT8 ELSE 0 END,b.numctecoppel,b.sucursal INTO vcte_refcop2,vcte_refcop,vtienda
				--FROM "informix".si_cliente a, "informix".si_adiccoppel b
				--WHERE a.numcte = vnumcte AND a.empresa = pempresa AND b.empresa = pempresa AND a.numcte_ref = b.numctecoppel AND a.numcte = b.numcte;    
                
                SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(numctecoppel) = "V" THEN numctecoppel::INT8 ELSE 0 END,numctecoppel,sucursal INTO vcte_refcop2,vcte_refcop,vtienda
				FROM "informix".si_adiccoppel
				WHERE empresa = pempresa AND numcte = vnumcte;
				
                LET cObservs = TRIM('Paso 5');

				IF  dFechaAlta <> vfechaltacte THEN 
				
					IF cStatus NOT IN ("RT","AT","AP") AND NVL(vfolio,0) = 0  THEN 
						CONTINUE FOREACH; 
					END IF;

                    LET cObservs = TRIM('Paso 6');
					IF cStatus = "RT" OR cStatus = "AT" THEN
                        LET cObservs = TRIM('Paso 7');
                        IF (SELECT COUNT(num_solicitud) FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud = vnumsolcred) > 1 THEN
                            FOREACH
                                SELECT FIRST 1 secuenciaos  INTO vfolioanterior
                                FROM bdisolic:"informix".ss_solicitud_os
                                WHERE num_solicitud = vnumsolcred AND secuenciaos < vfolio ORDER BY secuenciaos DESC
                            END FOREACH
                            LET vtdafolioant = cFolioSucursal;
						END IF;
						LET iEmpGteAutori = 0; LET vcve = 'M';LET vATsupervisadoRT = DECODE (cStatus,"RT","H","AT","A");LET vtienda=cFolioSucursal;
					ELIF cStatus = "AP"  THEN
                        LET cObservs = TRIM('Paso 8');
						LET iEmpGteAutori = cEmpGteAutori::INT8;LET vcve = 'A';LET vATsupervisadoRT = 'A';
						IF NVL(vcte_refcop2, '') = '' THEN--2014-03-25 RQM 18 049->RQI 27 094 
							IF EXISTS(SELECT cliente FROM bdinteg:"informix".si_relacion_ctebcplcpl WHERE numcte_banco = vnumcte AND tipo_relacion=3) THEN
								--INCIDENCIAS
								--UPDATE bdisolic:"informix".ss_resum_scor_fin SET situacion_especial='P', causa_situacion=33 WHERE num_solicitud =vnumsolcred;			
							END IF;
                            LET cObservs = TRIM('Paso 9');
							SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(numcte_ref) = "V" THEN numcte_ref::INT8 ELSE 0 END INTO vcte_ref FROM bdinteg:"informix".si_cliente WHERE numcte = vnumcte;
							--DSB este dato ya se obtiene en anteriror llamado  si_adiccoppel
							--SELECT numctecoppel,sucursal INTO vcte_refcop,vtienda FROM bdinteg:"informix".si_adiccoppel WHERE empresa = pempresa AND numcte = vnumcte;
							IF NVL(vcte_ref, '') = '' THEN 
                                LET cObservs = TRIM('Paso 10');
								LET vcte_ref=vcte_refcop;
							END IF;
						ELSE 
                            LET cObservs = TRIM('Paso 11');
							LET vcte_ref=vcte_refcop2;
						END IF;
						
                        LET cObservs = TRIM('Paso 12');
						SELECT fechaasignacion 
						INTO vfechaltacte 
						FROM bditarjcop:"informix".tarjetasnumtarcop 
						WHERE empresa=pempresa AND cvesucursal=cvesucursal AND numtarjeta = vcte_ref;
     
						IF vfechaltacte IS NULL THEN 
							LET vfechaltacte =dFechaAlta; 
						END IF;
					ELSE
						LET iEmpGteAutori = 0;  LET vtienda=cFolioSucursal; 
						IF TRIM(NVL(vfolio,'0')) =  0 THEN 
							LET vfechaltacte =dFechaAlta;LET vATsupervisadoRT = 'P';LET vfolio = '0';
						END IF;
						IF (SELECT COUNT(num_solicitud) FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud = vnumsolcred) > 1 THEN

                            LET cObservs = TRIM('Paso 13');
							--DSB Bernardo BÃ¡ez se elimina foreach ya que no es necesario porque obtiene un solo dato
							--FOREACH 
							SELECT MIN(secuenciaos)	INTO vfolioanterior FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud = vnumsolcred AND secuenciaos < vfolio;
							
							LET cObservs = TRIM('Paso 14');
							--END FOREACH
							LET vtdafolioant = cFolioSucursal;
						END IF;
						IF vATsupervisadoRT = 'R' THEN	
							LET vATsupervisadoRT = 'H'; 
						END IF; 
						LET vcve = 'M';LET vATsupervisadoRT = "A";
					END IF;
				ELSE
					LET vATsupervisadoRT= 'P';LET iEmpGteAutori = 0;  LET vtienda=cFolioSucursal;
				END IF;
				
				-- Actualizacion de Solicitud
                LET cObservs = TRIM('Paso 15');
				--DSB bernardo baez Se elimina ya que estos datos no son usados porterioromente
				--SELECT NVL(cliente_pros,''), NVL(fecha_hora,'')
				--INTO vVigenciaStatus, vFechaHora
				--FROM bdisolic:"informix".ss_autorizacion 
				--WHERE empresa = '001' AND num_solicitud = vnumsolcred AND status_solicitud = cStatus AND fecha_entrada = vfechaltacte AND ejecutivo_auto = cEmpGteAutori;
				
                LET cObservs = TRIM('Paso 16');
				--DSB Bernardo BÃ¡ez Se elimina para hacerse la consulta en otro punto
				--SELECT NVL(cliente_pros,'')
				--INTO vVigenciaCliente
				--FROM bdinteg:"informix".si_cliente 
				--WHERE numcte = vnumcte;
				/*
				SELECT NVL(MAX(fecha_hora),'') INTO vFechaHoraMax FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud=vnumsolcred AND fecha_entrada=pFechaAct;
				SELECT  FIRST 1 NVL(status_solicitud,'') INTO cStatusPenul FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud= vnumsolcred  AND fecha_hora =(SELECT MAX( fecha_hora )from bdisolic:"informix".ss_autorizacion where num_solicitud =vnumsolcred AND fecha_hora < vFechaHoraMax );
				
				IF EXISTS(SELECT * FROM bdiprospectos:"informix".pr_cliente WHERE numcte = vnumcte AND tipo_cliente = "3") AND (vVigenciaCliente = "1")THEN 
				--No genera registro de alta
				ELSE 
				--ALTA SOLICITUD
				-- OS
					IF NOT EXISTS(SELECT * FROM bdisolic:"informix".ss_autorizacion WHERE status_solicitud="OA" AND fecha_hora < (SELECT fecha_hora FROM bdisolic:"informix".ss_autorizacion WHERE 	status_solicitud="OS" AND num_solicitud=vnumsolcred)AND num_solicitud=vnumsolcred) AND (SELECT COUNT(*) FROM bdisolic:"informix".ss_solicitud_os WHERE status='D' AND num_solicitud=vnumsolcred)<2 AND (cStatus= "OS" AND vFechaHoraMax=vFechaHora) THEN
						LET vcve = "";
						LET bMovimiento = "T";
					--STATUS CE	
					ELIF  cStatus ="CE" AND vFechaHoraMax=vFechaHora THEN
						LET vcve = "";
						LET bMovimiento = "T";
					--STATUS RT Ã?ÃÂ³ CM(ARROJADO POR MC)
					ELIF (cStatus ="RT" OR cStatus ="CM") AND vFechaHoraMax=vFechaHora AND cStatusPenul="CM" THEN
						LET vcve = "";
						LET bMovimiento = "T";
					--STATUS AT
					ELIF EXISTS(SELECT * FROM bdisolic:"informix".ss_os_solautdirecta WHERE situacionespecial='S' AND causa=50 AND status='A' AND num_solicitud=vnumsolcred) AND	cStatus ="AT" AND vFechaHoraMax=vFechaHora THEN
						LET vcve = "";
						LET bMovimiento = "T";
					--STATUS RT(ARROJADO POR EC, POR PARAMETRICO)
					ELIF EXISTS (SELECT * FROM bdisolic:"informix".ss_nuevo_parametrico WHERE status_solicitud='R' AND num_solicitud=vnumsolcred) AND cStatus="RT" AND cStatusPenul="EC" AND vFechaHoraMax=vFechaHora  THEN
						LET vcve = "";
						LET bMovimiento = "T";
					--STATUS RT(ARROJADO POR STATUS PARAMETRIZADO PC O IN)
					ELIF  cStatus="RT" AND cStatusPenul =cStatusParam AND vFechaHoraMax=vFechaHora THEN
						LET vcve = "";
						LET bMovimiento = "T";
					--STATUS AN Ã?? PC
					ELIF ((cStatus="AN" AND cStatusPenul IN("RT", "PC")) OR (cStatus="PC")) AND vFechaHoraMax=vFechaHora THEN
						LET vcve = "";
						LET bMovimiento = "T";
					--STATUS EC
					ELIF cStatus="EC" AND vFechaHoraMax=vFechaHora THEN
						LET vcve = "";
						LET bMovimiento = "T";
					END IF;
				END IF;
			
			--MODIFICACION SOLICITUD			
				SELECT FIRST 1 NVL(status_solicitud,''),NVL(fecha_hora,'')INTO cStatusPenul,vFechaHoraP FROM bdisolic:"informix".ss_autorizacion 
				WHERE num_solicitud =vnumsolcred AND fecha_hora =(SELECT MAX(fecha_hora) FROM bdisolic:"informix".ss_autorizacion
				WHERE num_solicitud =vnumsolcred AND fecha_hora < vFechaHoraMax);
				SELECT FIRST 1 NVL(status_solicitud,'') INTO cStatusAntp FROM bdisolic:"informix".ss_autorizacion 
				WHERE num_solicitud =vnumsolcred AND fecha_hora =(SELECT MAX(fecha_hora) FROM bdisolic:"informix".ss_autorizacion 
				WHERE num_solicitud =vnumsolcred AND fecha_hora < vFechaHoraP);
				--STATUS AT,RT,OA
				IF EXISTS(SELECT * FROM bdisolic:ss_solicitud_os WHERE num_solicitud=vnumsolcred AND status IN('A','R','D')) 
				AND (cStatus IN("AT","RT","OA") AND  vfechaltacte=pFechaAct) AND cStatusPenul="OS" THEN
					LET vcve = "M";
					LET bMovimiento = "T";
					--Validar status= OA para envir  situacion especial y causa
				END IF;
				--STATUS OS(RELANZADA)
				IF (SELECT COUNT(num_solicitud) FROM bdisolic:"informix".ss_solicitud_os WHERE status='D' AND num_solicitud=vnumsolcred)>1 AND cStatusPenul="EE" AND cStatusAntp="OA" AND(cStatus ="OS" AND vfechaltacte=pFechaAct) AND
				(SELECT COUNT(num_solicitud) FROM bdisolic:"informix".ss_solicitud_os WHERE status='D' AND num_solicitud=vnumsolcred AND fecha_solicitud=pFechaAct) >=1 THEN
					LET vcve = "M";
					LET bMovimiento = "T";
				END IF;
				--STATUS CN
				IF EXISTS(SELECT * FROM bdisolic:"informix".ss_autorizacion WHERE causa_solicitud IN('CEC','CEE','COS', 'COA','CCE')AND num_solicitud = vnumsolcred AND fecha_entrada=pFechaAct) AND ( cStatus ="CN" AND vfechaltacte=pFechaAct) THEN
					LET vcve = "M";
					LET bMovimiento = "T";
				END IF;
				--STATUS RT,CM
				IF (EXISTS(SELECT * FROM bdisolic:"informix".ss_autorizacion WHERE status_solicitud ='RT' AND causa_solicitud IN('RCZ','RBE','RSC', 'REC','RMC','RSE','RCE','RVC') AND num_solicitud = vnumsolcred ) AND ( vfechaltacte=pFechaAct AND cStatus ="RT")) OR (EXISTS (SELECT * FROM bdisolic:"informix".ss_autorizacion WHERE  status_solicitud ='CM' AND causa_solicitud in ('CVE','CME','CEV', 'CMC') AND num_solicitud = vnumsolcred AND fecha_entrada=pFechaAct) AND ( vfechaltacte=pFechaAct AND cStatus ="CM") )  THEN
					LET vcve = "M";
					LET bMovimiento = "T";
				END IF;
				--STATUS RT(por parametrico)
				IF EXISTS(SELECT * FROM bdiprospectos:"informix".pr_nuevo_parametrico WHERE status_solicitud="R" AND num_solicitud=vnumsolcred ) AND(	cStatus ="RT" AND vfechaltacte=pFechaAct AND vVigenciaStatus ="1" AND vVigenciaCliente = "1") THEN 
					LET vcve = "M";
					LET bMovimiento = "T";
				END IF;
				--STATUS RT(politicas internas)
				IF (cStatus IN ("RT") AND vfechaltacte=pFechaAct ) AND (cStatusPenul="IN" OR cStatusPenul="BC") AND vVigenciaStatus ="1" AND vVigenciaCliente = "1" THEN
					LET vcve = "M";
					LET bMovimiento = "T";
				--ELIF bMovimiento ="F" THEN
					--CONTINUE FOREACH;
				END IF;
			*/
				IF vnumsolcred <> '' OR vnumcte <> '' THEN

                    LET cObservs = TRIM('Paso 17');
				
					SELECT nombre1, nombre2, apell_paterno, apell_materno, numcte,CASE WHEN bdinteg:"informix".sp_EsNumerico(user_insert) = 'V' THEN user_insert::INTEGER ELSE 0 END, rfc, fecha_insert,CASE WHEN bdinteg:"informix".sp_EsNumerico(string2) = 'V' THEN string2::INTEGER ELSE 0 END, apell_casada, NVL(cliente_pros,'')
					INTO vnombre1, vnombre2, vapell_paterno, vapell_materno, vnumcte, vefectuoAP, vrfc,vfechamovto, vpersonasvivenendomicilio, cApellCasada, vVigenciaCliente
					FROM bdinteg:"informix".si_cliente cte
					WHERE empresa = pempresa AND numcte = vnumcte;
					
                    LET cObservs = TRIM('Paso 18');
   
					SELECT estado_civil, NVL(TRIM(REPLACE(REPLACE(curp,'|',' '),'//','/')),''), numidentifi, codidentifi, habita_en, sexo, fecha_nac, escolaridad::integer,nacionalidad, no_fm3, no_imss
					INTO vestadocivil, vcurp, vcveelector, vcveidentificacion, vcasapropia, vsexo, vfechanacimiento, vescolaridad,cNacionalidad, cNoFm3, cNoIMSS
					FROM bdinteg:"informix".si_ctepf iden
					WHERE numcte = vnumcte;
	
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
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numeroextcalle) = 'V' THEN dir.numeroextcalle::INT8 ELSE 1 END,
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
                            SELECT cve_ciudad INTO vciudadbanco FROM bdinteg:"informix".si_ptf WHERE id_ptf = cFolioSucursal AND tipo = 'S';
                            ------------------------------------------------------------------------------------------------------------------
							--SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
							------------------------------------------------------------------------------------------------------------------
	
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
								LET vuhcentradaTrabajo=NVL(vuhcentrada, 0);LET cNumInteriorTrabajo= NVL(cNumInterior,0); LET cPaisTrabajo=NVL(cPais,'');
								LET cEstadoTrabajo=NVL(cEstado,'');LET vteltrabajo=NVL(vteltrabajo, 0);LET vextensiontrabajo=NVL(vextensiontrabajo, 0);		
							END IF;
					END FOREACH;
					
					--DSB Bernardo BÃ¡ez 01/04/2017 se obtienen los datos de puesto
					
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

										
					SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
					LET cfechanac = YEAR(vfechanacimiento)||"/"||LPAD(MONTH(vfechanacimiento),2,0)||"/"||LPAD(DAY(vfechanacimiento),2,0);
					
					IF cStatus = 'AP' THEN
						LET dfechaaltacte = pFechaAct;
					ELSE
						LET dfechaaltacte = vfechaltacte;
					END IF
					
					
					--IF pFechaAct <> vFecha_Hoy THEN
						--LET cfechamovto = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0)||" "||vHora;
						LET cFecha_hoy = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0);
					--ELSE
					--	LET cfechamovto = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0)||" "||vHora;
					--	LET cFecha_hoy = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0);
					--END IF;
					IF NVL(vcomplementotrab, '') = '' THEN 
						LET vcomplementotrab = 'E'; 
					END IF;
					LET ccteConyugebcpl = '0';LET ccteref1bcpl = '0';LET ccteref2bcpl = '0';
					IF NVL(cNumSolRef,'') = '' THEN 
						LET cNumSolRef=vnumsolcred; 
					END IF;
					
                    LET cObservs = TRIM('Paso 30');
					FOREACH WITH HOLD
						---SELECT NVL(numcte_banco,'0'),NVL(numcte_ref,'0'), nombre1, nombre2, apell_paterno, apell_materno, parentesco, sexo,secuencia
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
							ELSE
								 LET vnombre2ref2=vnombredostmp; LET vApellPatRef2=vApellPattmp; LET vApellMatRef2=vApellMattmp; LET vcveref2=vcvefamiliatmp; 
								 LET ccteref2bcpl=cctebcpltmp; LET vcteref2=vctetmp; LET vnombre1ref2=vnombreunotmp; 
								 LET cSexoref2=cSexoConyugetmp; LET iRefSecuencias2=iRefSecustmp;
							END IF;
						ELSE
							IF vestadocivil <>'C' THEN 
								let vestadocivil='C';
							END IF;   
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
						CASE WHEN "informix".sp_EsNumerico(numeroextcalle) = 'V' THEN numeroextcalle::INT8 ELSE 1 END,
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
                        SELECT cve_ciudad INTO vciudadbanco FROM bdinteg:"informix".si_ptf WHERE id_ptf = cFolioSucursal AND tipo = 'S';
						----------------------------------------------------------------------------------------------------------------
						--SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
						----------------------------------------------------------------------------------------------------------------
   
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
							IF TRIM(cDescripElemento) = "No EstudiÃ?ÃÂ³" THEN 
								LET vescolaridad = '1';
							ELIF TRIM(cDescripElemento) = "Primaria" THEN 
								LET  vescolaridad = '2';
							ELIF TRIM(cDescripElemento) = "Secundaria" THEN 
								LET vescolaridad = '3';
							ELIF TRIM(cDescripElemento) = "Carrera TÃ?ÃÂ©cnica" THEN 
								LET vescolaridad = '4';
							ELIF TRIM(cDescripElemento) = "Preparatoria" THEN 
								LET vescolaridad = '5';
							ELIF TRIM(cDescripElemento) = "Licenciatura o Superior" THEN 
								LET vescolaridad = '6';
							END IF;
						END IF;
					END FOREACH;

                    LET cObservs = TRIM('Paso 54');
					--SELECT FIRST 1 secuenciaos,status INTO  vfolio,cTipRechazoOs FROM bdisolic:"informix".ss_solicitud_os
					-- se modifica para obtener los datos en foreach principal
                    --SELECT FIRST 1 secuenciaos,status,situacionespecialrespuesta,causasituacionespecialrespuesta INTO  vfolio,cTipRechazoOs,vsitesp_resp,vcausasitesp_resp FROM bdisolic:"informix".ss_solicitud_os
					--WHERE empresa = pempresa AND status <> 'P'
					--AND fecha_respuesta IN (SELECT MAX(fecha_respuesta) FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud = vnumsolcred)
					--AND num_solicitud = vnumsolcred;

					IF NVL(vfolio, '') = '' THEN 
						LET vfolio = '0'; 
					END IF; 
					
                    LET cObservs = TRIM('Paso 55');
					SELECT NVL(institucion, ''), fecha_sic INTO cFlagConsBuro, dFechaConsBuro FROM bdisolic:"informix".ss_solicitudes_sic
					WHERE numcte = vnumcte AND num_solicitud = vnumsolcred
					AND ROWID = (SELECT MAX(ROWID) FROM bdisolic:"informix".ss_solicitudes_sic WHERE numcte = vnumcte AND num_solicitud = vnumsolcred);
					
					IF cFlagConsBuro = 'BC' OR cFlagConsBuro = 'CC' THEN 
						LET cBuroPilotoTestig = 'P';LET cMarcarConsultado = 'CO'; 
					ELSE 
						LET cBuroPilotoTestig = 'T';LET cMarcarConsultado = 'NC'; 
					END IF;
					IF NVL(dFechaConsBuro, '') <> '' THEN
						LET cFechaConsBuro = YEAR(dFechaConsBuro)||"/"||LPAD(MONTH(dFechaConsBuro),2,0)||"/"||LPAD(DAY(dFechaConsBuro),2,0);
					ELSE 
						LET cFechaConsBuro = YEAR(dFechaConsBuro)||"/"||LPAD(MONTH(dFechaConsBuro),2,0)||"/"||LPAD(DAY(dFechaConsBuro),2,0);
					END IF;
					
                    LET cObservs = TRIM('Paso 56');
					SELECT MAX(ROWID) INTO iRowId FROM bdisolic:"informix".ss_nuevo_parametrico WHERE num_solicitud = vnumsolcred;
					
                    LET cObservs = TRIM('Paso 57');
					
					

					SELECT  ingreso_mensual,cap_sistematica_abono,tope_abonocoppel,lineacreditotope,capmaxima_abono,capreal_abono,lineacredito_real,compromisossic,flaglineacreditoesp,limitecredito, situacion_especial,causa_sitesp,puntos_parcn,status_solicitud,
					id_situaciones,TRIM(puntualidad_ref1),TRIM(puntualidad_ref2),flagtestigoparametricocn::SMALLINT,flag_altadirecta_asupervisar::SMALLINT,puntos_var_param,puntos_var_sic,score_domicilio,nuevo_puntajefinal,clienteprospecto,
					par_celulares, par_altoriesgo, par_prestamos -- DSB Bernardo BÃ¡ez 31/03/2017 se agregan los datos par_celulares, par_altoriesgo, par_prestamos 
					INTO iMontoIngMensual, iCapSistematicabono, iTopeAbonoCoppel, iLineaCrediTope, iCapMaximaAbono, iCapRealAbono, iLineaCredReal, iCompromisosSic, iFlagLineaCredEsp,vlimitecredito,vsitesp, vcausasitesp,iPuntuacion,cTipRechazo,
					iId_Situaciones,cPuntualidad_ref1,cPuntualidad_ref2,sFlagTestParam,sFlag_altadirecta_asupervisar,iPuntos_Var_Param,iPuntos_Var_SIC,iScore_domicilio,sNuevo_puntajefinal,vNumCteProspecto,
					sParceles, sParAltoRiesgo, sParPrestamo 
					FROM bdisolic:"informix".ss_nuevo_parametrico
					WHERE empresa = pempresa AND ROWID = iRowId;

					IF iIngreso > iTopeMax THEN 
                        LET cObservs = TRIM('Paso 58');
						LET iIngreso=iTopeMax; LET iMontoIngMensual=iTopeMax; 
					END IF;
					
                    LET cObservs = TRIM('Paso 59');
					LET vingresomensual = ((((NVL(iIngreso::DECIMAL(18,2),0))+(iValor/2)))/iValor)::INTEGER;
					
					IF TRIM(NVL(cMarcaHit, '')) = 'X' THEN 
						LET cMarcaHit = 'HT'; ELSE LET cMarcaHit = 'NH'; 
					END IF;
					
					IF vingresomensual < 1 THEN 
						LET vingresomensual = 1; 
					END IF;
					IF cStatus="AP" THEN 
						LET vEfectuo=vefectuoAP;
					IF NVL(vcte_refcop2, '') <> NVL(vcte_refcop,'') THEN  
                        LET cObservs = TRIM('Paso 60');
						--SELECT situacion_especial,causa_situacion INTO vsitesp, vcausasitesp FROM bdisolic:"informix".ss_resum_scor_fin WHERE num_solicitud =vnumsolcred;	
						LET vsitesp = vsitespaux;
						LET vcausasitesp = vcausasitespaux;
					END IF;
				ELSE  
                    LET cObservs = TRIM('Paso 61');
					LET vEfectuo=vEfectuoRTOS;
					IF cStatus="RT" THEN   --2014/03/25 RQM 18 049->RQI 27 093 
						IF NVL(cTipRechazoOs,'')='R' THEN
							SELECT FIRST 1 situacionespecialrespuesta,causasituacionespecialrespuesta INTO vsitesp, vcausasitesp FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud=vnumsolcred AND status='R';
                            LET cObservs = TRIM('Paso 62');
						ELSE
							IF NVL(cTipRechazo,'') <>'R' THEN
                                LET cObservs = TRIM('Paso 63');
								SELECT situacion_especial,causa_situacion INTO vsitesp, vcausasitesp FROM bdisolic:"informix".ss_resum_scor_fin WHERE num_solicitud =vnumsolcred;
							END IF;
						END IF;
					ELSE
						IF (SELECT NVL(COUNT(*), 0) FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud = vnumsolcred AND status_solicitud IN ('RT')) = 0 THEN
							--IF cStatus <> 'BC' THEN --13012016 AAME INC27083 Se modifica para que la trama Alta Solicitud se marque con S 50
								IF (SELECT COUNT(num_solicitud) FROM bdisolic:"informix".ss_os_solautdirecta WHERE empresa = pEmpresa AND num_solicitud = vnumsolcred) >= 1 THEN
                                  LET cObservs = TRIM('Paso 64');
								  SELECT situacionespecial,causa INTO vsitesp,vcausasitesp FROM bdisolic:"informix".ss_os_solautdirecta WHERE empresa = pEmpresa AND num_solicitud = vnumsolcred;
								END IF;
							--END IF;
						END IF;
					END IF;
				END IF;  
  
				IF (SELECT COUNT(num_solicitud) FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud = vnumsolcred) >= 1 THEN 
					LET ibandtdaFolOs=1; 
				END IF;
				IF ibandtdaFolOs=1 THEN 
					LET vtiendafolio = cFolioSucursal; 
				ELSE 
					LET vtiendafolio = '0';
				END IF;
				
                
				--SE OBTIENE CAMPOS vaceptadosupervisadorechazado
				/*IF cStatus = "RT" OR cStatus = "AT" THEN
					LET vATsupervisadoRT = DECODE (cStatus,"RT","H","AT","A");
				ELIF cStatus = "AP"  THEN
					LET vATsupervisadoRT ="";
				END IF;*/
				
				
				IF vcve = "" THEN
					IF vVigenciaCliente <> '' then
						IF (dFechaAlta - vfechaltacte) < 60 THEN
							LET vcve = "M";
						END IF;
					END IF;
				END IF;
				
				IF vVigenciaCliente <> '' then
					IF vcve = 'M' THEN
						IF (dFechaAlta - vfechaltacte) < 60 THEN
							LET vATsupervisadoRT ="A";
						ELSE
							LET vATsupervisadoRT ="P";
                            --DSB 30 de Marzo 2017 Bernardo BÃ¡ez Se modifica para Mandar clave = '' cuando tiene vigencia encida
                            LET vcve = '';
						END IF;
					END IF;
				END IF;
				--SE OBTIENE CAMPO cStatusbcpl
				--SELECT NVL(status_solicitud,'') INTO cStatusbcpl FROM bdisolic:"informix".ss_solicitudes WHERE num_solicitud =vnumsolcred;
				LET cStatusbcpl = cStatus;
				--SE OBTIENE CAMPO cMotivobcpl
			 	
				LET cMotivobcpl = '';
				IF (cStatusbcpl = "AN" OR cStatusbcpl = "PC") THEN
					LET cMotivobcpl = '';
				ELIF vcve = "" AND cStatusbcpl = "RT" THEN
                    LET cObservs = TRIM('Paso 65');
					SELECT NVL(causa_solicitud,'') INTO cMotivobcpl FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud=vnumsolcred
					AND status_solicitud='RT' AND ROWID = (select max(rowid) FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud=vnumsolcred
					AND status_solicitud='RT' );
				ELIF cStatus = "OA" AND cTipRechazoOs = "D" THEN --APR 20160926
                    LET cObservs = TRIM('Paso 66');
                    LET vsitesp = vsitesp_resp;
                    LET vcausasitesp = vcausasitesp_resp;
				END IF;
				
				--IF vcve = "" THEN
				LET cStatusbcplaux = cStatus;
				
				IF cStatus = 'OS' THEN
					LET vATsupervisadoRT = 'P';
				ELIF cStatus = 'OA' THEN
					LET vATsupervisadoRT = 'D';
				ELIF cStatus = 'PC' THEN
					LET vATsupervisadoRT = 'P';
				ELIF cStatus = 'AT' THEN
					LET vATsupervisadoRT = 'A';
				ELIF cStatus = 'RT' THEN
					LET vATsupervisadoRT = 'H';
				END IF;
				
				
				
				
				--ELSE
				--	LET cStatusbcplaux = '';
				--END IF;

			
                LET cTrama = '';
				--INCIDENCIAS
                LET cTrama = vcve||"|"||vcaja||"|"||TRIM(varea)||"|"||TRIM(NVL(vcte_ref,'0'))||"|"||TRIM(REPLACE(NVL(vnombre1, ''),'|',''))
				||"|"||TRIM(REPLACE(NVL(vnombre2, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vapell_paterno, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vapell_materno, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vcurp, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vcveelector, ''),'|',''))
                ||"|"||TRIM(NVL(vcveidentificacion, ''))||"|"||TRIM(REPLACE(videntificacion,'|',''))||"|"||NVL(vciudad, 0)||"|"||NVL(vcolonia, 0)||"|"||NVL(vcalle, 0)||"|"||NVL(iNumerocasa, 0)
                ||"|"||TRIM(REPLACE(NVL(vdeptointerior, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vrumbo, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vcomplemento, ' '),'|',''))||"|"||TRIM(REPLACE(NVL(ventrecalles, ''),'|',''))||"|"||NVL(cUnidadHabit, '0')
                ||"|"||NVL(vuhcmanzana, 0)||"|"||NVL(vuhcotros, 0)||"|"||NVL(vuhcandador, 0)||"|"||NVL(vuhcetapa, 0)||"|"||NVL(vuhclote, 0)||"|"||NVL(vuhcedificio, 0)||"|"||NVL(vuhcentrada, 0)
                ||"|"||NVL(vtel, 0)||"|"||NVL(vtelcel, 0)||"|"||TRIM(NVL(vcasapropia, ''))||"|"||TRIM(REPLACE(vniptitular,'|',''))||"|"||TRIM(REPLACE(vnipadicional,'|',''))||"|"||TRIM(NVL(vsexo, ''))
                ||"|"||TRIM(NVL(vestadocivil, ''))||"|"||TRIM(NVL(cfechanac, '1900/01/01'))||"|"||TRIM(NVL(cfechadecuandovive, '1900/01/01'))||"|"||NVL(vpersonasvivenendomicilio, 0)
                ||"|"||TRIM(NVL(vescolaridad, ''))||"|"||TRIM(NVL(vtiposueldo, ''))||"|"||NVL(vnumerodependientes, 0)||"|"||NVL(vpersonastrabajan, 0)||"|"||NVL(vlimitecredito, 0)
                ||"|"||NVL(vingresomensual, 0)||"|"||TRIM(REPLACE(NVL(vsitesp, ''),'|',''))||"|"||NVL(vcausasitesp, 0)||"|"||TRIM(vcveautRT)||"|"||TRIM(vATsupervisadoRT)
                ||"|"||TRIM(vctenuevo)||"|"||TRIM(NVL(vcreditojoven, ''))||"|"||TRIM(REPLACE(NVL(vlugartrabajo, ''),'|',''))||"|"||NVL(vciudadTrabajo,0)||"|"||NVL(vcoloniaTrabajo, 0)||"|"||NVL(vcalleTrabajo, 0)
                ||"|"||NVL(iNumerocasaTrabajo, 0)||"|"||TRIM(REPLACE(NVL(vdeptointeriorTrabajo, ''),'|',''))||"|"||TRIM(NVL(vrumbotrab, ''))||"|"||TRIM(REPLACE(NVL(vcomplementotrab, ''),'|',''))
                ||"|"||TRIM(REPLACE(NVL(ventrecallesTrabajo, ''),'|',''))||"|"||NVL(cUnidadHabitTrabajo, '0')||"|"||NVL(vuhcmanzanaTrabajo, 0)||"|"||NVL(vuhcotrosTrabajo, 0)||"|"||NVL(vuhcandadorTrabajo, 0)
                ||"|"||NVL(vuhcetapaTrabajo, 0)||"|"||NVL(vuhcloteTrabajo, 0)||"|"||NVL(vuhcedificioTrabajo, 0)||"|"||NVL(vuhcentradaTrabajo, 0)||"|"||NVL(vteltrabajo, 0)||"|"||NVL(vextensiontrabajo, 0)
                ||"|"||TRIM(NVL(vpuesto,''))||"|"||NVL(vopcionpuesto, 0)||"|"||TRIM(NVL(cFechAntigTrab, '1900/01/01'))||"|"||TRIM(NVL(vcteconyuge,'0'))||"|"||TRIM(REPLACE(NVL(vnombreunoconyuge, ''),'|',''))
                ||"|"||TRIM(REPLACE(NVL(vnombredosconyuge, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vApellPatCony, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vApellMatCony, ''),'|',''))||"|"||TRIM(NVL(cSexoConyuge, ''))
                ||"|"||TRIM(REPLACE(NVL(vlugartrabajoconyuge, ''),'|',''))||"|"||NVL(vciudadconyuge, 0)||"|"||NVL(vcoloniaconyuge, 0)||"|"||NVL(vcalletrabajoconyuge, 0)||"|"||NVL(iNumerocasaconyuge, 0)
                ||"|"||TRIM(REPLACE(NVL(vdeptoointeriorconyuge, ''),'|',''))||"|"||TRIM(NVL(vrumbotrabcony, ''))||"|"||TRIM(REPLACE(NVL(vcomplementocony, ''),'|',''))||"|"||TRIM(REPLACE(NVL(ventrecallesconyuge,''),'|',''))
                ||"|"||NVL(cflaguhtconyugue, 0)||"|"||NVL(vuhymanzana, 0)||"|"||NVL(vuhyotros, 0)||"|"||NVL(vuhyandador, 0)||"|"||NVL(vuhyetapa, 0)||"|"||NVL(vuhylote, 0)||"|"||NVL(vuhyedificio, 0)
                ||"|"||NVL(vuhyentrada, 0)||"|"||NVL(vteltrabajoconyuge, 0)||"|"||NVL(vtelcelconyuge, 0)||"|"||NVL(vcveconyugefamilia,'')||"|"||TRIM(NVL(vcteref,0))
                ||"|"||TRIM(REPLACE(NVL(vnombre1ref, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vnombre2ref, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vApellPatRef, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vApellMatRef, ''),'|',''))
                ||"|"||TRIM(NVL(cSexoref, ''))||"|"||NVL(vciudadref1,0)||"|"||NVL(vcoloniaref1,0)||"|"||NVL(vcalleref1,0)||"|"||NVL(iNumerocasaref1,0)
                ||"|"||TRIM(REPLACE(NVL(vdeptointeriorref1,''),'|',''))||"|"||NVL(vrumboref1,'')||"|"||TRIM(REPLACE(NVL(vcomplementoref1,'E'),'|',''))||"|"||TRIM(REPLACE(NVL(ventrecallesref1,''),'|',''))
                ||"|"||NVL(cflaguhtref1,0)||"|"||NVL(vuhymanzanaref1,0)||"|"||NVL(vuhyotrosref1,0)||"|"||NVL(vuhyandadorref1,0)||"|"||NVL(vuhyetaparef1,0)
                ||"|"||NVL(vuhyloteref1,0)||"|"||NVL(vuhyedificioref1,0)||"|"||NVL(vuhyentradaref1,0)||"|"||NVL(vteltrabajoref1,0)
                ||"|"||NVL(vtelcelref1,0)||"|"||NVL(iSecuenciaref1,'')||"|"||TRIM(NVL(vcteref2,0))||"|"||TRIM(REPLACE(NVL(vnombre1ref2, ''),'|',''))
                ||"|"||TRIM(REPLACE(NVL(vnombre2ref2, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vApellPatRef2, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vApellMatRef2, ''),'|',''))
                ||"|"||TRIM(NVL(cSexoref2, ''))||"|"||NVL(vciudadref2,0)||"|"||NVL(vcoloniaref2,0)||"|"||NVL(vcalleref2,0)||"|"||NVL(iNumerocasaref2,0)
                ||"|"||TRIM(REPLACE(NVL(vdeptointeriorref2,''),'|',''))||"|"||NVL(vrumboref2,'')||"|"||TRIM(REPLACE(NVL(vcomplementoref2,'E'),'|',''))||"|"||TRIM(REPLACE(NVL(ventrecallesref2,''),'|',''))
                ||"|"||NVL(cflaguhtref2,0)||"|"||NVL(vuhymanzanaref2,0)||"|"||NVL(vuhyotrosref2,0)||"|"||NVL(vuhyandadorref2,0)||"|"||NVL(vuhyetaparef2,0)
                ||"|"||NVL(vuhyloteref2,0)||"|"||NVL(vuhyedificioref2,0)||"|"||NVL(vuhyentradaref2,0)||"|"||NVL(vteltrabajoref2,0)||"|"||NVL(vtelcelref2,0)
                ||"|"||NVL(iSecuenciaref2,'')||"|"||vref2||"|"||vref3||"|"||TRIM(REPLACE(vmarcadatosin,'|',''))||"|"||vtiporeposicion||"|"||vreposicion||"|"||TRIM(vflagentregotarjeta)
                ||"|"||NVL(vefectuo, 0)||"|"||TRIM(NVL(vtiendafolio, '0'))||"|"||TRIM( NVL(vfolio,'0') )||"|"||NVL(dfechaaltacte, DATE(1))||"|"||TRIM(vflagnoreconocehuella)
                ||"|"||vfoliotienda||"|"||TRIM(REPLACE(NVL(vrfc, ''),'|',''))||"|"||TRIM(vcveburo)||"|"||TRIM(vfolioaut)||"|"||TRIM(REPLACE(vfolioconsulta,'|',''))||"|"||TRIM(REPLACE(vfolioconcir,'|',''))||"|"||vnegocio||"|"||vsubnegocio||"|"||vEmpautorizo
                ||"|"||TRIM(vtipo)||"|"||TRIM(NVL(cfechamovto, '1900/01/01 01:00:00'))||"|"||TRIM(NVL(vnumsolcred, ''))||"|"||TRIM(NVL(vnumcte, ''))||"|"||NVL(vtdafolioant,'0')
                ||"|"||NVL(vfolioanterior,0)||"|"||NVL(vcveproducto,0)||"|"||vflagactualizacion||"|"||vSistsegsocial||"|"||vTiposueldoext||"|"||vNumEmps||"|"||vSubopcionpuesto||"|"||vPuestoext
                ||"|"||vOpcionpuestoext||"|"||vNumEmpsext||"|"||vSubopcionpuestoext||"|"||TRIM(vTipoOrigen)||"|"||TRIM(vTipoProducto)||"|"||TRIM(NVL(vtienda, '0'))
                ||"|"||TRIM(NVL(cFecha_hoy, '1900/01/01'))||"|"||NVL(iPuntuacion,0)||"|"||NVL(cMarcaHit,'')||"|"||NVL(iEmpSubCob,0)||"|"||NVL(sFlagCapHuella,0)
                ||"|"||TRIM(cMarcarConsultado)||"|"||NVL(sFlagTestParam,0)||"|"||NVL(sFlagCapCobranza,0)||"|"||NVL(iEmpGteAutori,0)||"|"||NVL(cFlagConsBuro,'')
                ||"|"||NVL(cBuroPilotoTestig,'')||"|"||TRIM(NVL(cNacionalidad,''))||"|"||TRIM(REPLACE(NVL(cNoFm3,''),'|',''))||"|"||TRIM(REPLACE(NVL(cEmail,''),'|',''))||"|"||TRIM(REPLACE(NVL(cApellCasada,''),'|',''))||"|"||TRIM(NVL(cPais,''))
                ||"|"||TRIM(NVL(cNoIMSS,''))||"|"||TRIM(NVL(cEstado,''))||"|"||TRIM(NVL(cDelegMunicip,''))||"|"||TRIM(REPLACE(NVL(cNumInterior,''),'|',''))||"|"||NVL(sPropNegocio,0)
                ||"|"||NVL(sParceles,0)||"|"||NVL(sParAltoRiesgo,0)||"|"||NVL(sParPrestamo,0)||"|"||NVL(cModeloCel,'')||"|"||NVL(cFechaConsBuro, '1900/01/01')||"|"||NVL(iMontoIngMensual,0)
                ||"|"||NVL(iCapSistematicabono,0)||"|"||NVL(iTopeAbonoCoppel,0)||"|"||NVL(iLineaCrediTope,0)||"|"||NVL(iCapMaximaAbono,0)||"|"||NVL(iCapRealAbono,0)||"|"||NVL(iLineaCredReal,0)
                ||"|"||NVL(iCompromisosSic,0)||"|"||NVL(iFlagLineaCredEsp,0)||"|"||TRIM(NVL(ccteConyugebcpl,'0'))||"|"||TRIM(NVL(ccteref1bcpl,'0'))||"|"||TRIM(NVL(ccteref2bcpl,'0'))--||"|"||NVL(cFolioSucursal,'0')||"|"||NVL(pFechaAct,DATE(1))
                ||"|"||NVL(cStatusbcplaux,'')||"|"||TRIM(NVL(cMotivobcpl,''))||"|"||cFlagProspecto||"|"||TRIM(vNumCteProspecto)||"|"||iParAltoRiesgoNvo||"|"||iPagoUlt12meses
                ||"|"||NVL(iId_Situaciones,0)||"|"||TRIM(NVL(cPuntualidad_ref1, ''))||"|"||TRIM(NVL(cPuntualidad_ref2, ''))||"|"||NVL(sFlag_altadirecta_asupervisar,0)||"|"||NVL(iPuntos_Var_Param,0)||"|"||NVL(iPuntos_Var_SIC,0)||"|"||NVL(iScore_domicilio,0)||"|"||NVL(sNuevo_puntajefinal,0);

                LET cObservs = TRIM('Paso 67');
				
				--INCIDENCIAS
				LET vsSQL = ' echo "' || cTrama || '" >> ' || TRIM(vRuta)|| 'movimientosaltaunicax_batch_inc.unl';
				SYSTEM vsSQL;
				

				--INCIDENCIAS
				/*
				INSERT INTO bdinteg:"informix".si_tramasbatch(secuencia,clave, caja, area, cliente, nombre1, nombre2, apellidopaterno, apellidomaterno, curp, claveelector, claveidentificacion, identificacion, ciudad, colonia, calle, casa, deptoointerior, rumbo, complemento, entrecalles, flaguhc, uhcmanzana, uhcotros, uhcandador, uhcetapa, uhclote, uhcedificio, uhcentrada, telefono, telefonocelular, casapropia, niptitular, nipadicional, sexo, estadocivil, fechanacimiento, fechadesdecuandoviveahi, personasvivenendomicilio, escolaridad, tiposueldo, numerodependientes, personastrabajan, limitecredito, ingresomensual, situacionespecial, causasituacionespecial, claveautrechaza, aceptadosupervisadorechazado, clientenuevo, creditojoven, lugartrabajo, ciudadtrabajo, coloniatrabajo, calletrabajo, casatrabajo, deptoointeriortrabajo, rumbotrabajo, complementotrabajo, entrecallestrabajo, flaguht, uhtmanzana, uhtotros, uhtandador, uhtetapa, uhtlote, uhtedificio, uhtentrada, telefonotrabajo, extensiontrabajo, puesto, opcionpuesto, fechaantiguedadtrabajo, clienteconyuge, nombreunoconyuge, nombredosconyuge, apellidopaternoconyuge, apellidomaternoconyuge, sexoconyuge, lugartrabajoconyuge, ciudadconyuge, coloniaconyuge, calletrabajoconyuge, casatrabajoconyuge, deptoointeriorconyuge, rumbotrabajoconyuge, complementoconyuge, entrecallesconyuge, flaguhy, uhymanzana, uhyotros, uhyandador, uhyetapa, uhylote, uhyedificio, uhyentrada, telefonotrabajoconyuge, telefonocelularconyuge, claveconyugefamilia, clientereferencia, nombreunoreferencia, nombredosreferencia, apellidopaternoreferencia, apellidomaternoreferencia, sexoreferencia, ciudadreferencia, coloniareferencia, callereferencia, casareferencia, deptoointeriorreferencia, rumboreferencia, complementoreferencia, entrecallesreferencia1, flaguhr, uhrmanzana, uhrotros, uhrandador, uhretapa, uhrlote, uhredificio, uhrentrada, telefonoreferencia, telefonocelularreferencia, clavereferencia1, clientereferencia2, nombreunoreferencia2, nombredosreferencia2, apellidopaternoreferencia2, apellidomaternoreferencia2, sexoreferencia2, ciudadreferencia2, coloniareferencia2, callereferencia2, casareferencia2, deptoointeriorreferencia2, rumboreferencia2, complementoreferencia2, entrecallesreferencia2, flaguhr2, uhrmanzana2, uhrotros2, uhrandador2, uhretapa2, uhrlote2, uhredificio2, uhrentrada2, telefonoreferencia2, telefonocelularreferencia2, clavereferencia2, referencia2, referencia3, marcadatosin, tiporeposicion, reposicion, flagentregotarjeta, efectuo, tiendafolio, folio, fechaaltacliente, flagnoreconocehuella, foliotienda, rfc, cveburo, folioaut, folioconsulta, folioconcir, negocio, subnegocio, empleadoautorizo, tipo, fechamovto, numerosolicituddecredito, clientebancoppel, tiendafolioanterior, folioanterior, claveproducto, flagactualizacion, sistsegsocial, tiposueldoext, numempleados, subopcionpuesto, puestoext, opcionpuestoext, numempleadosext, subopcionpuestoext, tipoorigen, tipoproducto, tienda, fecha, puntosparcn, marcahit, empleadosupcob, flagcapturohuella, marcarconsultado, flagtestigoparametricocn, flagcapturacobranza, empleadogteautorizo, flagconsultaburo, buropilototestigo, nacionalidad, no_fm3, email, apellido_cas, pais, no_imss, estado, municipio, numinterior, propietarionegocio, parcelulares, paraltoriesgo, parprestamo, modelocelulares, fechaconsultaburo, montoingresomensual, capsistematicaabono, topeabonocoppel, lineadecreditope, capmaximaabono, caprealabono, lineadecreditoreal, compromisossic, flaglineacreditoesp, clienteconyugebcpl, clientereferenciabcpl, clientereferencia2bcpl,sucursal,fecha_insert,
				Statusbcpl, Motivobcpl, FlagProspecto, NumCteProspecto, ParAltoRiesgoNvo, PagoUlt12meses, id_situaciones, puntualidad_ref1, puntualidad_ref2, flag_altadirecta_asupervisar, puntos_var_param, puntos_var_sic, score_domicilio, nuevo_puntajefinal)
				  VALUES(inumSecuencia,vcve, vcaja, TRIM(varea),TRIM(NVL(vcte_ref,'0')),TRIM(NVL(vnombre1, '')), 
				  TRIM(NVL(vnombre2, '')), TRIM(NVL(vapell_paterno, '')),TRIM(NVL(vapell_materno, '')),TRIM(NVL(vcurp, '')),TRIM(NVL(vcveelector, '')),
				  TRIM(NVL(vcveidentificacion, '')), TRIM(videntificacion), NVL(vciudad, 0),NVL(vcolonia, 0),NVL(vcalle, 0), NVL(iNumerocasa, 0), 
				  TRIM(NVL(vdeptointerior, '')),TRIM(NVL(vrumbo, '')), TRIM(NVL(vcomplemento, ' ')), TRIM(NVL(ventrecalles, '')), NVL(cUnidadHabit, '0'),
				  NVL(vuhcmanzana, 0),NVL(vuhcotros, 0), NVL(vuhcandador, 0), NVL(vuhcetapa, 0), NVL(vuhclote, 0), NVL(vuhcedificio, 0), NVL(vuhcentrada, 0),
				  NVL(vtel, 0),NVL(vtelcel, 0), TRIM(NVL(vcasapropia, '')),TRIM(vniptitular), TRIM(vnipadicional), TRIM(NVL(vsexo, '')),
				  TRIM(NVL(vestadocivil, '')), TRIM(NVL(cfechanac, '1900/01/01')),TRIM(NVL(cfechadecuandovive, '1900/01/01')), NVL(vpersonasvivenendomicilio, 0), 
				  TRIM(NVL(vescolaridad, '')), TRIM(NVL(vtiposueldo, '')),NVL(vnumerodependientes, 0), NVL(vpersonastrabajan, 0), NVL(vlimitecredito, 0),
				  NVL(vingresomensual, 0), TRIM(NVL(vsitesp, '')),NVL(vcausasitesp, 0), TRIM(vcveautRT),TRIM(vATsupervisadoRT),
				  TRIM(vctenuevo),TRIM(NVL(vcreditojoven, '')),TRIM(NVL(vlugartrabajo, '')),NVL(vciudadTrabajo,0), NVL(vcoloniaTrabajo, 0),NVL(vcalleTrabajo, 0),
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
				  NVL(iSecuenciaref2,''),vref2, vref3, TRIM(vmarcadatosin),vtiporeposicion,vreposicion,TRIM(vflagentregotarjeta),
				  NVL(vefectuo, 0),TRIM(NVL(vtiendafolio, '0')),TRIM( NVL(vfolio,'0') ),NVL(dfechaaltacte, DATE(1)),TRIM(vflagnoreconocehuella),
				  vfoliotienda,TRIM(NVL(vrfc, '')),TRIM(vcveburo),TRIM(vfolioaut),TRIM(vfolioconsulta),TRIM(vfolioconcir),vnegocio,vsubnegocio,vEmpautorizo,
				  TRIM(vtipo),TRIM(NVL(cfechamovto, '1900/01/01 01:00:00')), TRIM(NVL(vnumsolcred, '')),TRIM(NVL(vnumcte, '')),NVL(vtdafolioant,'0'),
				  NVL(vfolioanterior,0),NVL(vcveproducto,0), vflagactualizacion, vSistsegsocial,vTiposueldoext,vNumEmps,vSubopcionpuesto, vPuestoext,
				  vOpcionpuestoext,vNumEmpsext,vSubopcionpuestoext, TRIM(vTipoOrigen),TRIM(vTipoProducto),TRIM(NVL(vtienda, '0')),
				  TRIM(NVL(cFecha_hoy, '1900/01/01')),NVL(iPuntuacion,0),NVL(cMarcaHit,''),NVL(iEmpSubCob,0),NVL(sFlagCapHuella,0),
				  TRIM(cMarcarConsultado),NVL(sFlagTestParam,0),NVL(sFlagCapCobranza,0),NVL(iEmpGteAutori,0),NVL(cFlagConsBuro,''),
				  NVL(cBuroPilotoTestig,''),TRIM(NVL(cNacionalidad,'')),TRIM(NVL(cNoFm3,'')),TRIM(NVL(cEmail,'')),TRIM(NVL(cApellCasada,'')),TRIM(NVL(cPais,'')),
				  TRIM(NVL(cNoIMSS,'')),TRIM(NVL(cEstado,'')),TRIM(NVL(cDelegMunicip,'')),TRIM(NVL(cNumInterior,'')),NVL(sPropNegocio,0), 
				  NVL(sParceles,0), NVL(sParAltoRiesgo,0), NVL(sParPrestamo,0),NVL(cModeloCel,''),NVL(cFechaConsBuro, '1900/01/01'),NVL(iMontoIngMensual,0),
				  NVL(iCapSistematicabono,0),NVL(iTopeAbonoCoppel,0),NVL(iLineaCrediTope,0),NVL(iCapMaximaAbono,0),NVL(iCapRealAbono,0),NVL(iLineaCredReal,0),
				  NVL(iCompromisosSic,0),NVL(iFlagLineaCredEsp,0),TRIM(NVL(ccteConyugebcpl,'0')),TRIM(NVL(ccteref1bcpl,'0')),TRIM(NVL(ccteref2bcpl,'0')),NVL(cFolioSucursal,'0'),NVL(pFechaAct,DATE(1)),
				  NVL(cStatusbcplaux,''), NVL(cMotivobcpl,''), cFlagProspecto, vNumCteProspecto, iParAltoRiesgoNvo, iPagoUlt12meses,
				  NVL(iId_Situaciones,0), TRIM(NVL(cPuntualidad_ref1, '')), TRIM(NVL(cPuntualidad_ref2, '')), NVL(sFlag_altadirecta_asupervisar,0), NVL(iPuntos_Var_Param,0), NVL(iPuntos_Var_SIC,0), NVL(iScore_domicilio,0), NVL(sNuevo_puntajefinal,0));
				*/
				  
				  LET iContReg = 1;

                  LET cObservs = TRIM('Paso 68');

				  FOREACH 
					   SELECT  status_solicitud, fecha_entrada,fecha_salida,ejecutivo_auto,fecha_hora
					   INTO cStatus2, dFechaEntrada,dFechaSalida,cEmpGteAutori,cfechamovto
					   FROM bdisolic:"informix".ss_autorizacion
					   WHERE empresa=pempresa
					   AND num_solicitud = vnumsolcred AND status_solicitud IN('RT','OS','AT','AP')
					   AND fecha_entrada = pFechaAct
					
                    LET cObservs = TRIM('Paso 69');
					
					IF vcve = 'M' THEN 
						LET vcveant = vcve;
					END IF;

					IF (dFechaEntrada <> pFechaAct AND cStatus2 <>'OS') THEN 
						CONTINUE FOREACH;
					ELIF (dFechaEntrada <> pFechaAct AND cStatus2 ='OS') AND cStatus = 'OA' THEN 
						CONTINUE FOREACH;
					ELIF (dFechaSalida <> pFechaAct AND cStatus2 ='OS') THEN 
						CONTINUE FOREACH;
					END IF;
					IF cStatus = cStatus2 AND dFechaAlta <> pFechaAct THEN 
						CONTINUE FOREACH; 
					END IF;
					LET inumSecuencia = inumSecuencia + 1;LET vcte_ref = "0"; 
					IF cStatus2 = "RT" OR cStatus2 = "AT" THEN
						LET vcve = 'M';LET vcveautRT = '2';LET vATsupervisadoRT = DECODE(cStatus2,"RT","H","AT","A");LET vctenuevo = 'N';LET iEmpGteAutori = 0; LET vefectuo=vEfectuoRTOS; LET vtienda=cFolioSucursal;	--2014/03/25 RQM 18 049->RQI 27 093 
						IF cStatus2="RT" THEN
							IF NVL(cTipRechazoOs,'') ='R' THEN
                                LET cObservs = TRIM('Paso 70');
								SELECT FIRST 1 situacionespecialrespuesta,causasituacionespecialrespuesta  INTO vsitesp, vcausasitesp FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud=vnumsolcred AND status='R';
							ELSE
								IF NVL(cTipRechazo,'') <>'R' THEN
                                    LET cObservs = TRIM('Paso 71');
									SELECT situacion_especial,causa_situacion INTO vsitesp, vcausasitesp FROM bdisolic:"informix".ss_resum_scor_fin WHERE num_solicitud =vnumsolcred; 
								END IF;
							END IF;
						ELSE	
							IF (SELECT NVL(COUNT(*), 0) FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud = vnumsolcred AND status_solicitud='RT') = 0  THEN
								IF (SELECT COUNT(num_solicitud) FROM bdisolic:"informix".ss_os_solautdirecta WHERE empresa = pEmpresa AND num_solicitud = vnumsolcred) >= 1 THEN
                                  LET cObservs = TRIM('Paso 72');
								  SELECT situacionespecial,causa INTO vsitesp,vcausasitesp FROM bdisolic:"informix".ss_os_solautdirecta WHERE empresa = pEmpresa AND num_solicitud = vnumsolcred;
								END IF;
							END IF;
						END IF;
					ELIF cStatus2 = "AP" THEN     
                    LET cObservs = TRIM('Paso 73');
						LET vEfectuo=vefectuoAP;LET iEmpGteAutori= cEmpGteAutori::INT8;LET vcve = 'A';LET vcveautRT = '2';LET vATsupervisadoRT = 'A';LET vctenuevo = 'N';LET vtiendafolio = cFolioSucursal;    
                        LET cObservs = TRIM('Paso 74');
						SELECT numctecoppel,sucursal INTO  vcte_refcop,vtienda FROM  bdinteg:"informix".si_adiccoppel WHERE empresa = pempresa AND numcte = vnumcte AND secuencia=1;
						IF NVL(vcte_refcop2, '') <> NVL(vcte_refcop,'') THEN--2014-03-25 RQM 18 049->RQI 27 094 	
                            LET cObservs = TRIM('Paso 75');
							LET vcte_ref=vcte_refcop;
							IF EXISTS(SELECT cliente FROM bdinteg:"informix".si_relacion_ctebcplcpl WHERE numcte_banco = vnumcte AND tipo_relacion=3) THEN	  
								IF vsitesp<>'P' AND vcausasitesp<>33 THEN	  
									--INCIDENCIAS
									--UPDATE bdisolic:"informix".ss_resum_scor_fin SET situacion_especial='P', causa_situacion=33 WHERE num_solicitud =vnumsolcred;
									LET vsitesp='P'; LET vcausasitesp=41;
								END IF;
							END IF;
						ELSE 
                            LET cObservs = TRIM('Paso 76');
							LET vcte_ref=vcte_refcop2;	
						END IF;	  
						
                        LET cObservs = TRIM('Paso 77');
						SELECT fechaasignacion INTO vfechaltacte FROM bditarjcop:"informix".tarjetasnumtarcop WHERE empresa=pempresa AND cvesucursal=cvesucursal AND numtarjeta = vcte_ref;
						
						IF vfechaltacte IS NULL THEN 
							LET vfechaltacte =dFechaAlta; 
						END IF;  
					ELSE 
						IF cStatus2="OS" THEN 
                            LET cObservs = TRIM('Paso 78');
							LET vefectuo=vEfectuoRTOS; 
						END IF; 
						LET iEmpGteAutori = 0; 
						
                        LET cObservs = TRIM('Paso 79');
						SELECT FIRST 1 fecha_respuesta, status, secuenciaos INTO  vfechaltacte, vATsupervisadoRT, vfolio
						FROM bdisolic:"informix".ss_solicitud_os 
						WHERE empresa = pempresa AND status <> 'P' AND fecha_respuesta = pFechaAct AND num_solicitud = vnumsolcred;
						
						IF vfechaltacte IS NULL THEN 
							CONTINUE FOREACH; 
						END IF;
						IF NVL(vfolio,0) =  0 THEN
							LET vfechaltacte = YEAR(dFechaAlta)||"/"||LPAD(MONTH(dFechaAlta),2,0)||"/"||LPAD(DAY(dFechaAlta),2,0);LET vATsupervisadoRT = 'P';LET vfolio = 0;
						END IF;
						IF (SELECT COUNT(num_solicitud) FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud = vnumsolcred) > 1 THEN
						
                            LET cObservs = TRIM('Paso 80');
							FOREACH
							SELECT FIRST 1 secuenciaos INTO vfolioanterior
							FROM bdisolic:"informix".ss_solicitud_os
							WHERE num_solicitud = vnumsolcred AND secuenciaos < vfolio ORDER BY secuenciaos DESC

                            LET cObservs = TRIM('Paso 81');

							END FOREACH
							LET vtdafolioant = vtiendafolio;
						END IF;
						IF vATsupervisadoRT = 'R' THEN	LET vATsupervisadoRT = 'H'; END IF; LET vcveautRT = '2';LET vctenuevo = 'N';	LET vcve = 'M';
					END IF;
					IF ibandtdaFolOs=1 THEN 
						LET vtiendafolio = cFolioSucursal; ELSE LET vtiendafolio = '0';
					END IF;   
					
					
					--SE OBTIENE CAMPO cMotivobcpl
					LET cMotivobcpl = '';
					IF cStatusbcpl = "AN" OR cStatusbcpl = "PC" THEN
						LET cMotivobcpl = '';
					ELIF vcve = "" AND cStatusbcpl = "RT" THEN
                        LET cObservs = TRIM('Paso 82');
						SELECT NVL(causa_solicitud,'') INTO cMotivobcpl FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud=vnumsolcred
						AND status_solicitud='RT' AND ROWID = (select max(rowid) FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud=vnumsolcred
						AND status_solicitud='RT' AND fecha_insert <= pFechaAct);
					END IF;
					
					--IF vcve = "" THEN
						--LET cStatusbcplaux = cStatusbcpl;
						LET cStatusbcplaux = cStatus2;

					--ELSE
						--LET cStatusbcplaux = '';
					--END IF;

                    LET cTrama = '';
					--INCIDENCIAS
					LET cTrama = vcve||"|"||vcaja||"|"||TRIM(varea)||"|"||TRIM(NVL(vcte_ref,'0'))||"|"||TRIM(REPLACE(NVL(vnombre1, ''),'|',''))
					||"|"||TRIM(REPLACE(NVL(vnombre2, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vapell_paterno, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vapell_materno, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vcurp, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vcveelector, ''),'|',''))
					||"|"||TRIM(NVL(vcveidentificacion, ''))||"|"||TRIM(REPLACE(videntificacion,'|',''))||"|"||NVL(vciudad, 0)||"|"||NVL(vcolonia, 0)||"|"||NVL(vcalle, 0)||"|"||NVL(iNumerocasa, 0)
					||"|"||TRIM(REPLACE(NVL(vdeptointerior, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vrumbo, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vcomplemento, ' '),'|',''))||"|"||TRIM(REPLACE(NVL(ventrecalles, ''),'|',''))||"|"||NVL(cUnidadHabit, '0')
					||"|"||NVL(vuhcmanzana, 0)||"|"||NVL(vuhcotros, 0)||"|"||NVL(vuhcandador, 0)||"|"||NVL(vuhcetapa, 0)||"|"||NVL(vuhclote, 0)||"|"||NVL(vuhcedificio, 0)||"|"||NVL(vuhcentrada, 0)
					||"|"||NVL(vtel, 0)||"|"||NVL(vtelcel, 0)||"|"||TRIM(NVL(vcasapropia, ''))||"|"||TRIM(REPLACE(vniptitular,'|',''))||"|"||TRIM(REPLACE(vnipadicional,'|',''))||"|"||TRIM(NVL(vsexo, ''))
					||"|"||TRIM(NVL(vestadocivil, ''))||"|"||TRIM(NVL(cfechanac, '1900/01/01'))||"|"||TRIM(NVL(cfechadecuandovive, '1900/01/01'))||"|"||NVL(vpersonasvivenendomicilio, 0)
					||"|"||TRIM(NVL(vescolaridad, ''))||"|"||TRIM(NVL(vtiposueldo, ''))||"|"||NVL(vnumerodependientes, 0)||"|"||NVL(vpersonastrabajan, 0)||"|"||NVL(vlimitecredito, 0)
					||"|"||NVL(vingresomensual, 0)||"|"||TRIM(REPLACE(NVL(vsitesp, ''),'|',''))||"|"||NVL(vcausasitesp, 0)||"|"||TRIM(vcveautRT)||"|"||TRIM(vATsupervisadoRT)
					||"|"||TRIM(vctenuevo)||"|"||TRIM(NVL(vcreditojoven, ''))||"|"||TRIM(REPLACE(NVL(vlugartrabajo, ''),'|',''))||"|"||NVL(vciudadTrabajo,0)||"|"||NVL(vcoloniaTrabajo, 0)||"|"||NVL(vcalleTrabajo, 0)
					||"|"||NVL(iNumerocasaTrabajo, 0)||"|"||TRIM(REPLACE(NVL(vdeptointeriorTrabajo, ''),'|',''))||"|"||TRIM(NVL(vrumbotrab, ''))||"|"||TRIM(REPLACE(NVL(vcomplementotrab, ''),'|',''))
					||"|"||TRIM(REPLACE(NVL(ventrecallesTrabajo, ''),'|',''))||"|"||NVL(cUnidadHabitTrabajo, '0')||"|"||NVL(vuhcmanzanaTrabajo, 0)||"|"||NVL(vuhcotrosTrabajo, 0)||"|"||NVL(vuhcandadorTrabajo, 0)
					||"|"||NVL(vuhcetapaTrabajo, 0)||"|"||NVL(vuhcloteTrabajo, 0)||"|"||NVL(vuhcedificioTrabajo, 0)||"|"||NVL(vuhcentradaTrabajo, 0)||"|"||NVL(vteltrabajo, 0)||"|"||NVL(vextensiontrabajo, 0)
					||"|"||TRIM(NVL(vpuesto,''))||"|"||NVL(vopcionpuesto, 0)||"|"||TRIM(NVL(cFechAntigTrab, '1900/01/01'))||"|"||TRIM(NVL(vcteconyuge,'0'))||"|"||TRIM(REPLACE(NVL(vnombreunoconyuge, ''),'|',''))
					||"|"||TRIM(REPLACE(NVL(vnombredosconyuge, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vApellPatCony, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vApellMatCony, ''),'|',''))||"|"||TRIM(NVL(cSexoConyuge, ''))
					||"|"||TRIM(REPLACE(NVL(vlugartrabajoconyuge, ''),'|',''))||"|"||NVL(vciudadconyuge, 0)||"|"||NVL(vcoloniaconyuge, 0)||"|"||NVL(vcalletrabajoconyuge, 0)||"|"||NVL(iNumerocasaconyuge, 0)
					||"|"||TRIM(REPLACE(NVL(vdeptoointeriorconyuge, ''),'|',''))||"|"||TRIM(NVL(vrumbotrabcony, ''))||"|"||TRIM(REPLACE(NVL(vcomplementocony, ''),'|',''))||"|"||TRIM(REPLACE(NVL(ventrecallesconyuge,''),'|',''))
					||"|"||NVL(vflaguhy, 0)||"|"||NVL(vuhymanzana, 0)||"|"||NVL(vuhyotros, 0)||"|"||NVL(vuhyandador, 0)||"|"||NVL(vuhyetapa, 0)||"|"||NVL(vuhylote, 0)||"|"||NVL(vuhyedificio, 0)
					||"|"||NVL(vuhyentrada, 0)||"|"||NVL(vteltrabajoconyuge, 0)||"|"||NVL(vtelcelconyuge, 0)||"|"||NVL(vcveconyugefamilia,'')||"|"||TRIM(NVL(vcteref,0))
					||"|"||TRIM(REPLACE(NVL(vnombre1ref, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vnombre2ref, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vApellPatRef, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vApellMatRef, ''),'|',''))
					||"|"||TRIM(NVL(cSexoref, ''))||"|"||NVL(vciudadref1,0)||"|"||NVL(vcoloniaref1,0)||"|"||NVL(vcalleref1,0)||"|"||NVL(iNumerocasaref1,0)
					||"|"||TRIM(REPLACE(NVL(vdeptointeriorref1,''),'|',''))||"|"||NVL(vrumboref1,'')||"|"||TRIM(REPLACE(NVL(vcomplementoref1,'E'),'|',''))||"|"||TRIM(REPLACE(NVL(ventrecallesref1,''),'|',''))
					||"|"||NVL(cflaguhtref1,0)||"|"||NVL(vuhymanzanaref1,0)||"|"||NVL(vuhyotrosref1,0)||"|"||NVL(vuhyandadorref1,0)||"|"||NVL(vuhyetaparef1,0)
					||"|"||NVL(vuhyloteref1,0)||"|"||NVL(vuhyedificioref1,0)||"|"||NVL(vuhyentradaref1,0)||"|"||NVL(vteltrabajoref1,0)
					||"|"||NVL(vtelcelref1,0)||"|"||NVL(iSecuenciaref1,'')||"|"||TRIM(NVL(vcteref2,0))||"|"||TRIM(REPLACE(NVL(vnombre1ref2, ''),'|',''))
					||"|"||TRIM(REPLACE(NVL(vnombre2ref2, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vApellPatRef2, ''),'|',''))||"|"||TRIM(REPLACE(NVL(vApellMatRef2, ''),'|',''))
					||"|"||TRIM(NVL(cSexoref2, ''))||"|"||NVL(vciudadref2,0)||"|"||NVL(vcoloniaref2,0)||"|"||NVL(vcalleref2,0)||"|"||NVL(iNumerocasaref2,0)
					||"|"||TRIM(REPLACE(NVL(vdeptointeriorref2,''),'|',''))||"|"||NVL(vrumboref2,'')||"|"||TRIM(REPLACE(NVL(vcomplementoref2,'E'),'|',''))||"|"||TRIM(REPLACE(NVL(ventrecallesref2,''),'|',''))
					||"|"||NVL(cflaguhtref2,0)||"|"||NVL(vuhymanzanaref2,0)||"|"||NVL(vuhyotrosref2,0)||"|"||NVL(vuhyandadorref2,0)||"|"||NVL(vuhyetaparef2,0)
					||"|"||NVL(vuhyloteref2,0)||"|"||NVL(vuhyedificioref2,0)||"|"||NVL(vuhyentradaref2,0)||"|"||NVL(vteltrabajoref2,0)||"|"||NVL(vtelcelref2,0)
					||"|"||NVL(iSecuenciaref2,'')||"|"||vref2||"|"||vref3||"|"||TRIM(REPLACE(vmarcadatosin,'|',''))||"|"||vtiporeposicion||"|"||vreposicion||"|"||TRIM(vflagentregotarjeta)
					||"|"||NVL(vefectuo, 0)||"|"||TRIM(NVL(vtiendafolio, '0'))||"|"||TRIM( NVL(vfolio,'0') )||"|"||NVL(dfechaaltacte, DATE(1))||"|"||TRIM(vflagnoreconocehuella)
					||"|"||vfoliotienda||"|"||TRIM(REPLACE(NVL(vrfc, ''),'|',''))||"|"||TRIM(vcveburo)||"|"||TRIM(vfolioaut)||"|"||TRIM(REPLACE(vfolioconsulta,'|',''))||"|"||TRIM(REPLACE(vfolioconcir,'|',''))||"|"||vnegocio||"|"||vsubnegocio||"|"||vEmpautorizo
					||"|"||TRIM(vtipo)||"|"||TRIM(NVL(cfechamovto, '1900/01/01 01:00:00'))||"|"||TRIM(NVL(vnumsolcred, ''))||"|"||TRIM(NVL(vnumcte, ''))||"|"||NVL(vtdafolioant,'0')
					||"|"||NVL(vfolioanterior,0)||"|"||NVL(vcveproducto,0)||"|"||vflagactualizacion||"|"||vSistsegsocial||"|"||vTiposueldoext||"|"||vNumEmps||"|"||vSubopcionpuesto||"|"||vPuestoext
					||"|"||vOpcionpuestoext||"|"||vNumEmpsext||"|"||vSubopcionpuestoext||"|"||TRIM(vTipoOrigen)||"|"||TRIM(vTipoProducto)||"|"||TRIM(NVL(vtienda, '0'))
					||"|"||TRIM(NVL(cFecha_hoy, '1900/01/01'))||"|"||NVL(iPuntuacion,0)||"|"||NVL(cMarcaHit,'')||"|"||NVL(iEmpSubCob,0)||"|"||NVL(sFlagCapHuella,0)
					||"|"||TRIM(cMarcarConsultado)||"|"||NVL(sFlagTestParam,0)||"|"||NVL(sFlagCapCobranza,0)||"|"||NVL(iEmpGteAutori,0)||"|"||NVL(cFlagConsBuro,'')
					||"|"||NVL(cBuroPilotoTestig,'')||"|"||TRIM(NVL(cNacionalidad,''))||"|"||TRIM(REPLACE(NVL(cNoFm3,''),'|',''))||"|"||TRIM(REPLACE(NVL(cEmail,''),'|',''))||"|"||TRIM(REPLACE(NVL(cApellCasada,''),'|',''))||"|"||TRIM(NVL(cPais,''))
					||"|"||TRIM(NVL(cNoIMSS,''))||"|"||TRIM(NVL(cEstado,''))||"|"||TRIM(NVL(cDelegMunicip,''))||"|"||TRIM(REPLACE(NVL(cNumInterior,''),'|',''))||"|"||NVL(sPropNegocio,0)
					||"|"||NVL(sParceles,0)||"|"||NVL(sParAltoRiesgo,0)||"|"||NVL(sParPrestamo,0)||"|"||NVL(cModeloCel,'')||"|"||NVL(cFechaConsBuro, '1900/01/01')||"|"||NVL(iMontoIngMensual,0)
					||"|"||NVL(iCapSistematicabono,0)||"|"||NVL(iTopeAbonoCoppel,0)||"|"||NVL(iLineaCrediTope,0)||"|"||NVL(iCapMaximaAbono,0)||"|"||NVL(iCapRealAbono,0)||"|"||NVL(iLineaCredReal,0)
					||"|"||NVL(iCompromisosSic,0)||"|"||NVL(iFlagLineaCredEsp,0)||"|"||TRIM(NVL(ccteConyugebcpl,'0'))||"|"||TRIM(NVL(ccteref1bcpl,'0'))||"|"||TRIM(NVL(ccteref2bcpl,'0'))--||"|"||NVL(cFolioSucursal,'0')||"|"||NVL(pFechaAct,DATE(1))
					||"|"||NVL(cStatusbcplaux,'')||"|"||TRIM(NVL(cMotivobcpl,''))||"|"||cFlagProspecto||"|"||TRIM(vNumCteProspecto)||"|"||iParAltoRiesgoNvo||"|"||iPagoUlt12meses
					||"|"||NVL(iId_Situaciones,0)||"|"||TRIM(NVL(cPuntualidad_ref1, ''))||"|"||TRIM(NVL(cPuntualidad_ref2, ''))||"|"||NVL(sFlag_altadirecta_asupervisar,0)||"|"||NVL(iPuntos_Var_Param,0)||"|"||NVL(iPuntos_Var_SIC,0)||"|"||NVL(iScore_domicilio,0)||"|"||NVL(sNuevo_puntajefinal,0);
				
                    LET cObservs = TRIM('Paso 83');
					
					--INCIDENCIAS
					LET vsSQL = ' echo "' || cTrama || '" >> ' || TRIM(vRuta)|| 'movimientosaltaunicax_batch_inc.unl';
					SYSTEM vsSQL;
					
					
                    -- IF (vcveant <> 'M') OR (vcve <> 'M')  THEN  Se comenta codigo para guardar todos los movimientos en la tabla si_tramasbatch DSB20170711
					--INCIDENCIAS
					/*
                        INSERT INTO bdinteg:"informix".si_tramasbatch(secuencia,clave, caja, area, cliente, nombre1, nombre2, apellidopaterno, apellidomaterno, curp, claveelector, claveidentificacion, identificacion, ciudad, colonia, calle, casa, deptoointerior, rumbo, complemento, entrecalles, flaguhc, uhcmanzana, uhcotros, uhcandador, uhcetapa, uhclote, uhcedificio, uhcentrada, telefono, telefonocelular, casapropia, niptitular, nipadicional, sexo, estadocivil, fechanacimiento, fechadesdecuandoviveahi, personasvivenendomicilio, escolaridad, tiposueldo, numerodependientes, personastrabajan, limitecredito, ingresomensual, situacionespecial, causasituacionespecial, claveautrechaza, aceptadosupervisadorechazado, clientenuevo, creditojoven, lugartrabajo, ciudadtrabajo, coloniatrabajo, calletrabajo, casatrabajo, deptoointeriortrabajo, rumbotrabajo, complementotrabajo, entrecallestrabajo, flaguht, uhtmanzana, uhtotros, uhtandador, uhtetapa, uhtlote, uhtedificio, uhtentrada, telefonotrabajo, extensiontrabajo, puesto, opcionpuesto, fechaantiguedadtrabajo, clienteconyuge, nombreunoconyuge, nombredosconyuge, apellidopaternoconyuge, apellidomaternoconyuge, sexoconyuge, lugartrabajoconyuge, ciudadconyuge, coloniaconyuge, calletrabajoconyuge, casatrabajoconyuge, deptoointeriorconyuge, rumbotrabajoconyuge, complementoconyuge, entrecallesconyuge, flaguhy, uhymanzana, uhyotros, uhyandador, uhyetapa, uhylote, uhyedificio, uhyentrada, telefonotrabajoconyuge, telefonocelularconyuge, claveconyugefamilia, clientereferencia, nombreunoreferencia, nombredosreferencia, apellidopaternoreferencia, apellidomaternoreferencia, sexoreferencia, ciudadreferencia, coloniareferencia, callereferencia, casareferencia, deptoointeriorreferencia, rumboreferencia, complementoreferencia, entrecallesreferencia1, flaguhr, uhrmanzana, uhrotros, uhrandador, uhretapa, uhrlote, uhredificio, uhrentrada, telefonoreferencia, telefonocelularreferencia, clavereferencia1, clientereferencia2, nombreunoreferencia2, nombredosreferencia2, apellidopaternoreferencia2, apellidomaternoreferencia2, sexoreferencia2, ciudadreferencia2, coloniareferencia2, callereferencia2, casareferencia2, deptoointeriorreferencia2, rumboreferencia2, complementoreferencia2, entrecallesreferencia2, flaguhr2, uhrmanzana2, uhrotros2, uhrandador2, uhretapa2, uhrlote2, uhredificio2, uhrentrada2, telefonoreferencia2, telefonocelularreferencia2, clavereferencia2, referencia2, referencia3, marcadatosin, tiporeposicion, reposicion, flagentregotarjeta, efectuo, tiendafolio, folio, fechaaltacliente, flagnoreconocehuella, foliotienda, rfc, cveburo, folioaut, folioconsulta, folioconcir, negocio, subnegocio, empleadoautorizo, tipo, fechamovto, numerosolicituddecredito, clientebancoppel, tiendafolioanterior, folioanterior, claveproducto, flagactualizacion, sistsegsocial, tiposueldoext, numempleados, subopcionpuesto, puestoext, opcionpuestoext, numempleadosext, subopcionpuestoext, tipoorigen, tipoproducto, tienda, fecha, puntosparcn, marcahit, empleadosupcob, flagcapturohuella, marcarconsultado, flagtestigoparametricocn, flagcapturacobranza, empleadogteautorizo, flagconsultaburo, buropilototestigo, nacionalidad, no_fm3, email, apellido_cas, pais, no_imss, estado, municipio, numinterior, propietarionegocio, parcelulares, paraltoriesgo, parprestamo, modelocelulares, fechaconsultaburo, montoingresomensual, capsistematicaabono, topeabonocoppel, lineadecreditope, capmaximaabono, caprealabono, lineadecreditoreal, compromisossic, flaglineacreditoesp, clienteconyugebcpl, clientereferenciabcpl, clientereferencia2bcpl,sucursal,fecha_insert,
                        Statusbcpl, Motivobcpl, FlagProspecto, NumCteProspecto, ParAltoRiesgoNvo, PagoUlt12meses,id_situaciones, puntualidad_ref1, puntualidad_ref2, flag_altadirecta_asupervisar, puntos_var_param, puntos_var_sic, score_domicilio, nuevo_puntajefinal)
                            VALUES(inumSecuencia,vcve, vcaja, TRIM(varea),TRIM(NVL(vcte_ref,'0')),TRIM(NVL(vnombre1, '')), 
                            TRIM(NVL(vnombre2, '')), TRIM(NVL(vapell_paterno, '')),TRIM(NVL(vapell_materno, '')),TRIM(NVL(vcurp, '')),TRIM(NVL(vcveelector, '')),
                            TRIM(NVL(vcveidentificacion, '')), TRIM(videntificacion), NVL(vciudad, 0),NVL(vcolonia, 0),NVL(vcalle, 0), NVL(iNumerocasa, 0), 
                           TRIM(NVL(vdeptointerior, '')),TRIM(NVL(vrumbo, '')), TRIM(NVL(vcomplemento, ' ')), TRIM(NVL(ventrecalles, '')), NVL(cUnidadHabit, '0'),
                           NVL(vuhcmanzana, 0),NVL(vuhcotros, 0), NVL(vuhcandador, 0), NVL(vuhcetapa, 0), NVL(vuhclote, 0), NVL(vuhcedificio, 0), NVL(vuhcentrada, 0),
                           NVL(vtel, 0),NVL(vtelcel, 0), TRIM(NVL(vcasapropia, '')),TRIM(vniptitular), TRIM(vnipadicional), TRIM(NVL(vsexo, '')),
                           TRIM(NVL(vestadocivil, '')), TRIM(NVL(cfechanac, '1900/01/01')),TRIM(NVL(cfechadecuandovive, '1900/01/01')), NVL(vpersonasvivenendomicilio, 0), 
                           TRIM(NVL(vescolaridad, '')), TRIM(NVL(vtiposueldo, '')),NVL(vnumerodependientes, 0), NVL(vpersonastrabajan, 0), NVL(vlimitecredito, 0),
                           NVL(vingresomensual, 0), TRIM(NVL(vsitesp, '')),NVL(vcausasitesp, 0), TRIM(vcveautRT),TRIM(vATsupervisadoRT),
                           TRIM(vctenuevo),TRIM(NVL(vcreditojoven, '')),TRIM(NVL(vlugartrabajo, '')),NVL(vciudadTrabajo,0), NVL(vcoloniaTrabajo, 0),NVL(vcalleTrabajo, 0),
                           NVL(iNumerocasaTrabajo, 0),TRIM(NVL(vdeptointeriorTrabajo, '')), TRIM(NVL(vrumbotrab, '')), TRIM(NVL(vcomplementotrab, '')),
                           TRIM(NVL(ventrecallesTrabajo, '')), NVL(cUnidadHabitTrabajo, '0'), NVL(vuhcmanzanaTrabajo, 0), NVL(vuhcotrosTrabajo, 0), NVL(vuhcandadorTrabajo, 0), 
                           NVL(vuhcetapaTrabajo, 0), NVL(vuhcloteTrabajo, 0), NVL(vuhcedificioTrabajo, 0),NVL(vuhcentradaTrabajo, 0),NVL(vteltrabajo, 0), NVL(vextensiontrabajo, 0), 
                           TRIM(NVL(vpuesto,'')),NVL(vopcionpuesto, 0), TRIM(NVL(cFechAntigTrab, '1900/01/01')),TRIM(NVL(vcteconyuge,'0')), TRIM(NVL(vnombreunoconyuge, '')),
                           TRIM(NVL(vnombredosconyuge, '')),TRIM(NVL(vApellPatCony, '')), TRIM(NVL(vApellMatCony, '')),TRIM(NVL(cSexoConyuge, '')),
                           TRIM(NVL(vlugartrabajoconyuge, '')), NVL(vciudadconyuge, 0), NVL(vcoloniaconyuge, 0), NVL(vcalletrabajoconyuge, 0),NVL(iNumerocasaconyuge, 0),
                           TRIM(NVL(vdeptoointeriorconyuge, '')), TRIM(NVL(vrumbotrabcony, '')), TRIM(NVL(vcomplementocony, '')),TRIM(NVL(ventrecallesconyuge,'')),
                           NVL(vflaguhy, 0),NVL(vuhymanzana, 0),NVL(vuhyotros, 0), NVL(vuhyandador, 0), NVL(vuhyetapa, 0), NVL(vuhylote, 0), NVL(vuhyedificio, 0),
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
                           NVL(iSecuenciaref2,''),vref2, vref3, TRIM(vmarcadatosin),vtiporeposicion,vreposicion,TRIM(vflagentregotarjeta),
                           NVL(vefectuo, 0),TRIM(NVL(vtiendafolio, '0')),TRIM( NVL(vfolio,'0') ),NVL(dfechaaltacte, DATE(1)),TRIM(vflagnoreconocehuella),
                           vfoliotienda,TRIM(NVL(vrfc, '')),TRIM(vcveburo),TRIM(vfolioaut),TRIM(vfolioconsulta),TRIM(vfolioconcir),vnegocio,vsubnegocio,vEmpautorizo,
                           TRIM(vtipo),TRIM(NVL(cfechamovto, '1900/01/01 01:00:00')), TRIM(NVL(vnumsolcred, '')),TRIM(NVL(vnumcte, '')),NVL(vtdafolioant,'0'),
                           NVL(vfolioanterior,0),NVL(vcveproducto,0), vflagactualizacion, vSistsegsocial,vTiposueldoext,vNumEmps,vSubopcionpuesto, vPuestoext,
                           vOpcionpuestoext,vNumEmpsext,vSubopcionpuestoext, TRIM(vTipoOrigen),TRIM(vTipoProducto),TRIM(NVL(vtienda, '0')),
                           TRIM(NVL(cFecha_hoy, '1900/01/01')),NVL(iPuntuacion,0),NVL(cMarcaHit,''),NVL(iEmpSubCob,0),NVL(sFlagCapHuella,0),
                           TRIM(cMarcarConsultado),NVL(sFlagTestParam,0),NVL(sFlagCapCobranza,0),NVL(iEmpGteAutori,0),NVL(cFlagConsBuro,''),
                           NVL(cBuroPilotoTestig,''),TRIM(NVL(cNacionalidad,'')),TRIM(NVL(cNoFm3,'')),TRIM(NVL(cEmail,'')),TRIM(NVL(cApellCasada,'')),TRIM(NVL(cPais,'')),
                           TRIM(NVL(cNoIMSS,'')),TRIM(NVL(cEstado,'')),TRIM(NVL(cDelegMunicip,'')),TRIM(NVL(cNumInterior,'')),NVL(sPropNegocio,0), 
                           NVL(sParceles,0), NVL(sParAltoRiesgo,0), NVL(sParPrestamo,0),NVL(cModeloCel,''),NVL(cFechaConsBuro, '1900/01/01'),NVL(iMontoIngMensual,0),
                           NVL(iCapSistematicabono,0),NVL(iTopeAbonoCoppel,0),NVL(iLineaCrediTope,0),NVL(iCapMaximaAbono,0),NVL(iCapRealAbono,0),NVL(iLineaCredReal,0),
                           NVL(iCompromisosSic,0),NVL(iFlagLineaCredEsp,0),TRIM(NVL(ccteConyugebcpl,'0')),TRIM(NVL(ccteref1bcpl,'0')),TRIM(NVL(ccteref2bcpl,'0')),NVL(cFolioSucursal,'0'), NVL(pFechaAct,DATE(1)),
                           NVL(cStatusbcplaux,''), NVL(cMotivobcpl,''), cFlagProspecto, vNumCteProspecto, iParAltoRiesgoNvo, iPagoUlt12meses, 
                           NVL(iId_Situaciones,0), TRIM(NVL(cPuntualidad_ref1, '')),TRIM(NVL(cPuntualidad_ref2, '')), NVL(sFlag_altadirecta_asupervisar,0), NVL(iPuntos_Var_Param,0), NVL(iPuntos_Var_SIC,0), NVL(iScore_domicilio,0), NVL(sNuevo_puntajefinal,0));
                    -- END IF;
					*/
				 END FOREACH;
   
				LET vtdafolioant='0';LET vtiendafolio='0';LET vfolioanterior=0; LET vtienda='0'; LET ibandtdaFolOs=0;
			ELSE LET vCodRetorno = '000003';
				LET iContReg = 2;
			END IF;
			LET vEfectuoRTOS=0;LET vEfectuoAP=0;LET vcte_ref = '0'; LET vcte_refcop2 ='0'; LET vcte_refcop='0';
		END FOREACH;
	END IF;
	
	--Ejecuta el sp para el cliente prospecto
	--INCIDENCIAS
	/*
	IF bBorrado = 'F' THEN
		DELETE bdinteg:"informix".si_tramasbatch WHERE secuencia = secuencia AND fecha_insert = fecha_insert;
	END IF;
	*/
	
	--INCIDENCIAS
	/*
		IF inumSecuencia > 0 THEN 
			UPDATE bdinteg:"informix".si_archivosecuenciamax SET secuencia_max=inumSecuencia; 
		END IF;	
	*/
	ELSE 
		LET vCodRetorno = '000001';
		LET iContReg = 2;
	END IF;
	
    LET cObservs = TRIM('Paso 84');
	
	--INCIDENCIAS
	/*
	CALL bdinteg:"informix".sp_genera_archivosbatch_prospecto( pempresa, pFechaAct ) returning vCodRetorno;
	IF vCodRetorno::INTEGER < 0 THEN
		RETURN vCodRetorno;
	END IF;
	*/
	
	IF iContReg = 1 THEN	
		LET vCodRetorno = '000000';
	ELIF iContReg = 0 THEN	
		LET vCodRetorno = '000005'; 
	END IF;
	
	--INCIDENCIAS
	IF vCodRetorno = '000000' THEN
	
		LET cFecha_hoy_inc = YEAR(pFechaAct)||""||LPAD(MONTH(pFechaAct),2,0)||""||LPAD(DAY(pFechaAct),2,0);
		LET sNombreArchivoFinal = TRIM(vRuta)||'movimientosaltaunica-INCIDENCIAS-'|| cFecha_hoy_inc || '.txt';
		LET sPreNomArchivoFinal = TRIM(vRuta)||'movimientosaltaunica_batch_inc.unl';
		LET sAntNomArchivoFinal = TRIM(vRuta)||'movimientosaltaunica2_batch_inc.unl';
		LET sAnterNomArchivoFinal = TRIM(vRuta)||'movimientosaltaunica3_batch_inc.unl';
			
		LET vsSQL = '';
		LET vsSQL =  "sed 's/\\//g' " || TRIM(vRuta)|| "movimientosaltaunicax_batch_inc.unl > " || sPreNomArchivoFinal;
		SYSTEM vsSQL;					
		LET vsSQL = '';
		LET vsSQL =  "sed 's/|$//g' " || TRIM(vRuta)|| "movimientosaltaunica_batch_inc.unl > " || sAntNomArchivoFinal;
		SYSTEM vsSQL;
		-- AAME RQI 27 067 SE AGREGA ARCHIVO DE PASO PARA AGREGAR ESPACIOS EN BLANCO A LOS CAMPOS VACÃOS
		LET vsSQL = '';
		LET vsSQL =  "sed 's/||/| |/g' " || TRIM(vRuta)|| "movimientosaltaunica2_batch_inc.unl > " || sAnterNomArchivoFinal;
		SYSTEM vsSQL;				
		LET vsSQL = '';
		LET vsSQL =  "sed 's/||/| |/g' " || TRIM(vRuta)|| "movimientosaltaunica3_batch_inc.unl >> " || sNombreArchivoFinal;
		SYSTEM vsSQL;
		
		LET vsSQL = ' echo " " >> ' || sNombreArchivoFinal;
		SYSTEM vsSQL;
				
		--BORRAR LOS ARCHIOVOS DE PASO:		
		LET vsSQL = '' ;
		LET vsSQL = 'rm ' || TRIM(vRuta) || 'movimientosaltaunicax_batch_inc.unl';
		SYSTEM vsSQL ; 
		
		LET vsSQL = '' ;
		LET vsSQL = 'rm ' || TRIM(vRuta) || 'movimientosaltaunica_batch_inc.unl';
		SYSTEM vsSQL ; 
		
		LET vsSQL = '' ;
		LET vsSQL = 'rm ' || TRIM(vRuta) || 'movimientosaltaunica2_batch_inc.unl';
		SYSTEM vsSQL ; 
		
		LET vsSQL = '' ;
		LET vsSQL = 'rm ' || TRIM(vRuta) || 'movimientosaltaunica3_batch_inc.unl';
		SYSTEM vsSQL ; 
		
	END IF;
	
RETURN vCodRetorno;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: 	Se crea clon de procedimiento "sp_batch_generarinformacion" adaptandolo para buscar por numero de solicutud',
'AUTOR: 		94565457-Jose Angel Gaxiola Gaxiola',
'BD: 			bdinteg',
'Fecha: 		15/12/2017',
'Etiqueta:		--INCIDENCIAS',
'Solicita:		Abraham Narvaez';

CREATE PROCEDURE "informix".sp_busca_colonias(pCP CHAR(5),pColonia CHAR(32),pLimiteCaracteres INTEGER,pLimiteResultados INTEGER)

RETURNING CHAR(5) AS CodRet, CHAR(3) AS sPais, CHAR(2) AS sEdo, CHAR(3) AS sCiudad, CHAR (5) AS sCP, CHAR(4) AS sNumCiudad, CHAR(5) AS sColonia, CHAR(32) AS cColonia, CHAR(5) AS sMpo;

DEFINE iSqlErr 	    INTEGER;
DEFINE cCodRet 	    CHAR(5);
DEFINE sPais        CHAR(3);
DEFINE sEdo         CHAR(2);
DEFINE sCiudad      CHAR(3);
DEFINE sCP          CHAR(5);
DEFINE sNumCiudad   CHAR(4);
DEFINE sColonia     CHAR(5);
DEFINE cColonia		CHAR(32);
DEFINE sMpo         CHAR(5);
DEFINE cLike		CHAR(20);
DEFINE iExiste		INTEGER;

LET cCodRet 	= '00000';
LET sPais       = '';
LET sEdo        = '';
LET sCiudad     = '';
LET sCP         = '';
LET sNumCiudad	= '';
LET sColonia    = '';
LET cColonia	= '';
LET sMpo        = '00000';
LET cLike		= '';
LET iExiste		= 0;

BEGIN
-- ERRORES DE INFORMIX
ON EXCEPTION SET iSqlErr
	IF iSqlErr <> 0 THEN
		LET cCodRet = iSqlErr;
		RETURN cCodRet, sPais, sEdo, sCiudad, sCP, sNumCiudad, sColonia, cColonia, sMpo;
	END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/emm/sp_busca_colonia.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	SELECT {+INDEX (bdinteg:si_ciudades ix_2363)}{+INDEX (bdinteg:si_catzonas idx_zona)}
           {+INDEX (bdinteg:si_estados inx_estado)} 
    COUNT(*)
	INTO iExiste
    FROM bdinteg:si_catzonas a inner join bdinteg:si_ciudades b 
      on a.numerociudad=b.ciudad_coppel and a.numerociudad<>0 
    inner join bdinteg:si_estados c on b.estado=c.estado 
    WHERE a.codigopostalzona=pCP;

	IF iExiste > 0 THEN

		LET cLike 		= SUBSTRING (pColonia FROM 1 FOR pLimiteCaracteres);
		LET cLike		= TRIM(cLike)||'%';
		LET cLike		= UPPER(cLike);
		 
		 FOREACH
			
			SELECT LIMIT pLimiteResultados {+INDEX (bdinteg:si_ciudades ix_2363)}{+INDEX (bdinteg:si_catzonas idx_zona)}
				   {+INDEX (bdinteg:si_estados inx_estado)} 
			b.pais, b.estado, b.ciudad, a.codigopostalzona, a.numerociudad, a.numerocolonia, a.nombrezona
			INTO sPais, sEdo, sCiudad, sCP, sNumCiudad, sColonia, cColonia
			FROM bdinteg:si_catzonas a inner join bdinteg:si_ciudades b 
			  on a.numerociudad=b.ciudad_coppel and a.numerociudad<>0 
			inner join bdinteg:si_estados c on b.estado=c.estado 
			WHERE a.codigopostalzona=pCP
				AND a.nombrezona LIKE cLike
			
			IF sEdo='09' THEN
				LET sMpo='00'||sCiudad;
			END IF;
			
			RETURN cCodRet, sPais, sEdo, sCiudad, sCP, sNumCiudad, sColonia, cColonia, sMpo WITH RESUME;
		 END FOREACH;
	 
	ELSE
		LET cCodRet 	= '';
		LET sPais       = '';
		LET sEdo        = '';
		LET sCiudad     = '';
		LET sCP         = '';
		LET sNumCiudad	= '';
		LET sColonia    = '';
		LET cColonia	= '';
		LET sMpo        = '';
		
		RETURN cCodRet, sPais, sEdo, sCiudad, sCP, sNumCiudad, sColonia, cColonia, sMpo;
	
	END IF;
 

END 
END PROCEDURE;