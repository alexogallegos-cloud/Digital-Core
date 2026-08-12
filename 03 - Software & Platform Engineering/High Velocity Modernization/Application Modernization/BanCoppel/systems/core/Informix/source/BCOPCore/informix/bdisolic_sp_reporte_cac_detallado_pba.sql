CREATE PROCEDURE "informix".sp_reporte_cac_detallado_pba
(
pFechaInicial CHAR(10),
pFechaFinal CHAR(10)
)
RETURNING
	CHAR(6)			AS cod_ret,
	VARCHAR(80) 	AS descripcion,
	CHAR(10)		AS fecha_autorizacion,
    CHAR(20) 		AS num_solicitud,
    CHAR(4) 		AS num_sucursal,
    CHAR(20) 		AS num_cliente,
    VARCHAR(104) 	AS nombre_cte,
    VARCHAR(2) 		AS comp_ingreso_valido,
    VARCHAR(1) 		AS grupo_cte,
    DECIMAL(20,2) 	AS ingreso_declarado,
    DECIMAL(20,2) 	AS compromisos_sic,
    DECIMAL(20,2) 	AS compromisos_bco,
    DECIMAL(20,2) 	AS compromisos_cop,
    DECIMAL(20,2) 	AS linea_coppel,
    DECIMAL(20,2) 	AS linea_sug,
    DECIMAL(20,2) 	AS ingreso_validoMC,
    DECIMAL(20,2) 	AS linea_sug_mc,
    VARCHAR(20) 	AS Status_final,
    VARCHAR(45) 	AS analista_cac_atend,
    CHAR(300) 		AS observaciones;
	


	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		VARCHAR(80);
    DEFINE cCodRet			CHAR(6);
    DEFINE cMensajeRet		VARCHAR(80);
	
	DEFINE cFecAutotizacion CHAR(10);
    DEFINE cNumSolicitud 	CHAR(20);
    DEFINE cNumSucursal 	CHAR(4);
    DEFINE cNumCliente 		CHAR(20);
    DEFINE vcApellPaterno 	VARCHAR(26);
    DEFINE vcApellMaterno 	VARCHAR(26);
    DEFINE vcNombre 		VARCHAR(52);
    DEFINE vcNombreCte 		VARCHAR(104);
    DEFINE cCompValido 		VARCHAR(2);
    DEFINE cGrupoCte 		VARCHAR(1);
	DEFINE dIngresoDec 		DECIMAL(20,2);
	DEFINE dCompromisosSic	DECIMAL(20,2);
	DEFINE dCompromisosBco	DECIMAL(20,2);
	DEFINE dCompromisosCop	DECIMAL(20,2);
	DEFINE dLlineaCop		DECIMAL(20,2);
	DEFINE dLlineaSug		DECIMAL(20,2);
	DEFINE dIngresoMC		DECIMAL(20,2);
	DEFINE dLlineaSugMC		DECIMAL(20,2);
	DEFINE cStatus			VARCHAR(20);
    DEFINE vcAnalistcacAten VARCHAR(45);
	DEFINE cObservaciones 	CHAR(300);  
	DEFINE cBandExitosa 	CHAR(1);  
 

	
	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '000000';
	LET cMensajeRet			= 'PROCESO EXITOSO';

	LET cFecAutotizacion 	= '';
    LET cNumSolicitud 		= '';
    LET cNumSucursal 		= '';
    LET cNumCliente 		= '';
    LET vcApellPaterno 		= '';
    LET vcApellMaterno 		= '';
    LET vcNombre 			= '';
    LET vcNombreCte 		= '';
    LET cCompValido 		= '';
    LET cGrupoCte 		= '';
	LET dIngresoDec 		= '0';
	LET dCompromisosSic	= '0';
	LET dCompromisosBco	= '0';
	LET dCompromisosCop	= '0';
	LET dLlineaCop		= '0';
	LET dLlineaSug		= '0';
	LET dIngresoMC		= '0';
	LET dLlineaSugMC		= '0';
	LET cStatus			= '';
    LET vcAnalistcacAten = '';
	LET cObservaciones 	= '';
	LET cBandExitosa 	= 'N';

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			
			RETURN TRIM (cCodRet),cMensajeRet, NVl(cFecAutotizacion,''), NVL(cNumSolicitud,''), NVL(cNumSucursal,''), NVL( cNumCliente,''), NVL(vcNombreCte,''), NVL(cCompValido,''), NVL(cGrupoCte,''), NVL(dIngresoDec,0.0), NVL(dCompromisosSic,''), NVL(dCompromisosBco,''), NVL(dCompromisosCop,''), NVL(dLlineaCop,0.0), NVL(dLlineaSug,0.0), NVL(dIngresoMC,0.0),NVL(dLlineaSugMC,0.0),NVL(cStatus,''),NVL(vcAnalistcacAten,''),NVL(cObservaciones,'') WITH RESUME;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/informix/Malena/sp_reporte_cac_detallado.out';
	--TRACE ON;

	-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
    IF NVL(pFechaInicial,'') = '' OR NVL(pFechaFinal,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
	ELSE		
		IF pFechaInicial > pFechaFinal THEN
			LET cCodRet = '000002';
			LET cMensajeRet = 'LA FECHA INICIAL ES MAYOR A LA FECHA FINAL';
		ELSE
		
			let pFechaInicial = pFechaInicial;
			let pFechaFinal = pFechaFinal;
			-- OBTIENE EL REPORTE		
			FOREACH WITH HOLD
				SELECT DAY(a.fecha_determinacion)||'/'||MONTH(a.fecha_determinacion)||'/'||SUBSTR(YEAR(a.fecha_determinacion),3,2),
				a.num_solicitud, a.sucursal, a.numcte,b.monto_solicitado,  
				DECODE(NVL(a.comprobante_valido_cac,''),'S','SI','N','NO'), e.nombre, TRIM(a.observaciones), 
				a.status,a.ingreso_cac,linea_determinada_sistema
				INTO cFecAutotizacion, cNumSolicitud, cNumSucursal, cNumCliente, dLlineaSugMC ,  cCompValido,
				vcAnalistcacAten, cObservaciones, cStatus,dIngresoMC,dLlineaSug
				FROM bdisolic:'informix'.ss_solicitudes_cac a,bdisolic: ss_solicitudes b, bdinteg:'informix'.si_ejecut e			
				WHERE a.empresa = '001'	
				AND a.num_solicitud = b.num_solicitud
				--AND a.num_solicitud > ''  --AAME INC 27 023 Obv. 6 Se agrega nuevo filtro por num_solicitud para ligar con la tabla ss_solicitudes y obtener el monto que autoriza del campo monto_solicitado
				---AND a.fecha_insert::DATE >= pFechaInicial AND a.fecha_insert::DATE <= pFechaFinal
				AND a.fecha_insert >= pFechaInicial AND a.fecha_insert <= pFechaFinal
				AND a.ejecutivo_autoriza = e.ejecutivo
				
				
				SELECT  grupo,ingreso_mensual,pago_minimo,compromisos_bco,abonomensualropa+abonomensualmuebles+abonomensualprestamos,linea_tienda
				INTO cGrupoCte,dIngresoDec,dCompromisosSic,dCompromisosBco,dCompromisosCop,dLlineaCop
				FROM 'informix'.ss_resum_Scor_fin
				WHERE empresa = '001'	
				AND num_solicitud = cNumSolicitud;
				
				SELECT	TRIM(b.apell_paterno), TRIM(b.apell_materno), TRIM(b.nombre1) || ' ' || TRIM(b.nombre2)
					INTO vcApellPaterno, vcApellMaterno, vcNombre
				FROM bdinteg:'informix'.si_cliente b
				WHERE b.empresa = '001'
				AND b.numcte = cNumCliente;
				
				LET  vcNombreCte =  TRIM(vcApellPaterno) || ' ' || TRIM(vcApellMaterno)|| ' ' ||TRIM(vcNombre);
				
				LET cBandExitosa = 'S';
				
		

					RETURN TRIM (cCodRet),cMensajeRet, NVl(cFecAutotizacion,''), NVL(cNumSolicitud,''), NVL(cNumSucursal,''), NVL( cNumCliente,''), NVL(vcNombreCte,''), NVL(cCompValido,''), NVL(cGrupoCte,''), NVL(dIngresoDec,0.0), NVL(dCompromisosSic,''), NVL(dCompromisosBco,''), NVL(dCompromisosCop,''), NVL(dLlineaCop,0.0), NVL(dLlineaSug,0.0), NVL(dIngresoMC,0.0),NVL(dLlineaSugMC,0.0),NVL(cStatus,''),NVL(vcAnalistcacAten,''),NVL(cObservaciones,'') WITH RESUME;
			END FOREACH
		    IF cBandExitosa = 'N' THEN
				LET cCodRet = '000003';
				LET cMensajeRet = 'NO HAY DATOS PARA ESTE REPORTE, VERIFICAR FECHAS';
		    END IF	
		END IF
	END IF    
    
	IF cBandExitosa = 'N' THEN
			RETURN TRIM (cCodRet),cMensajeRet, NVl(cFecAutotizacion,''), NVL(cNumSolicitud,''), NVL(cNumSucursal,''), NVL( cNumCliente,''), NVL(vcNombreCte,''), NVL(cCompValido,''), NVL(cGrupoCte,''), NVL(dIngresoDec,0.0), NVL(dCompromisosSic,''), NVL(dCompromisosBco,''), NVL(dCompromisosCop,''), NVL(dLlineaCop,0.0), NVL(dLlineaSug,0.0), NVL(dIngresoMC,0.0),NVL(dLlineaSugMC,0.0),NVL(cStatus,''),NVL(vcAnalistcacAten,''),NVL(cObservaciones,'') WITH RESUME;
	END IF
END;
END PROCEDURE
