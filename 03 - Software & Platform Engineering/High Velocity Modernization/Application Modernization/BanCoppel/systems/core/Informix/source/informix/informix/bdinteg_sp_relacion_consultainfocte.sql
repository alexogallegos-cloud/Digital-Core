CREATE PROCEDURE "informix".sp_relacion_consultainfocte (pNumcte CHAR(20))
	RETURNING
	CHAR(6)  AS COD_RET, 
	CHAR(100) AS MENSAJE_RETORNO,
	CHAR(20) AS NUM_CLIENTE,
	CHAR(107) AS NOMBRE_CLIENTE,
	/*CHAR(10)*/ DATE AS FECHA_NAC,
	SMALLINT  AS TIPO_RELACION,
	CHAR(100)  AS DESCRIPCION_TIPO_RELACION,
	CHAR(107) AS NOMBRE_ANALISTA,
	CHAR(20) AS NUM_CLIENTE_COPPEL,
	CHAR(104) AS NOMBRE_CLIENTE_COPPEL,
	CHAR(10) AS FECHA_NAC_COPPEL,
	CHAR(10) AS FECHA_RELACION,
	DECIMAL(5,2) AS EFICIENCIA,
	SMALLINT AS MESES_HISTORIA,
	CHAR(1) AS PUNTUALIDAD,
	DECIMAL(14,6) AS ABONOSVENCIDOS,
	CHAR(1) AS SITUACION_ESPECIAL,
	SMALLINT AS CAUSA_SITESP,
	CHAR(100) AS DESCRIPCION_CAUSA_SITESP,
	CHAR(26) AS nombre1,
	CHAR(26) AS nombre2,
	CHAR(26) AS apell_paterno,
	CHAR(26) AS apell_materno,
	CHAR(4) AS sucursal,
	CHAR(13) AS RFC,
	CHAR(10) AS Fecha_consulta,
	DECIMAL(14,6) AS dabonomes;
	
-- Modificado por: Abrham López López, 26 Marzo 2013 Se modifica el campo FECHA_NAC a DATE 
-- para que ponga correcta la fecha en pantalla con formato dd/mm/aaaa
-- Modificado por Maria Elena Angulo (AAME). 30 Agosto 2013 Se modifica para anexar nuevo campo "dabonomes" para guardar 
-- y retornar el abono Mensual del Cliente.
	
---DECLARACIONES
DEFINE iSqlErr         	INTEGER;
DEFINE iIsamErr        	INTEGER;
DEFINE cErrorInfo      	CHAR(100);
DEFINE cCodRet         	CHAR(6);
DEFINE cMensajeRet     	CHAR(80);

DEFINE cNumcte      	CHAR(20);
DEFINE cNumSol      	CHAR(20);
DEFINE cNombreCte      	CHAR(107);
DEFINE cFechaNac     	CHAR(10);
DEFINE sTipoRel        	SMALLINT;
DEFINE cDesTipoRel      CHAR(100);

DEFINE cNomEmpleado     CHAR(107);
DEFINE cNumRef      	CHAR(20);
DEFINE cNombre_coppel   CHAR(107);
DEFINE cFechaNacCoppel  CHAR(10);
DEFINE cFechaRelacion  CHAR(10);

DEFINE dSituacion_pago  DECIMAL(5,2);
DEFINE sMeses_historia  SMALLINT;
DEFINE cPuntualidad     CHAR(1);
DEFINE dAbonosVen     DECIMAL(14,2);
DEFINE cSituacion_credito  CHAR(1);
DEFINE sCausa 			SMALLINT;
DEFINE cDesCausa   		CHAR(100);

DEFINE cNombre1   		CHAR(26);
DEFINE cNombre2   		CHAR(26);
DEFINE cApellPaterno   	CHAR(26);
DEFINE cApellMaterno   	CHAR(26);

DEFINE cRfc   	CHAR(13);
DEFINE cSucursal   	CHAR(4);
DEFINE dcAbonosVencidos DECIMAL(14,6);
DEFINE dcVencidocoppel DECIMAL(14,6);
DEFINE dtFechaCons CHAR(10);
DEFINE dabonomes DECIMAL(14,6); --AAME. RQM 09 333 Se define variable para el nuevo campo a retornar.
DEFINE dabonbase DECIMAL(14,6);


---INICIALIZACIONES
LET iSqlErr            	= 0;
LET iIsamErr           	= 0;
LET cErrorInfo         	= "";
LET cCodRet            	= "000000";
LET cMensajeRet        	= "PROCESO EXITOSO";   

LET cNumcte      		= "";
LET cNumSol      		= "";
LET cNombreCte      	= "";
LET cFechaNac      	= "";
LET sTipoRel        	= 0;
LET cDesTipoRel     	= "";
LET cNomEmpleado    	= "";
LET cNumRef      		= "";
LET cNombre_coppel  	= "";
LET cFechaNacCoppel    = "";
LET cFechaRelacion     = "";

LET dSituacion_pago 	= 0;
LET sMeses_historia  	= 0;
LET cPuntualidad     	= "";
LET dAbonosVen    	= 0;
LET cSituacion_credito  = "0";
LET sCausa 				= 0;
LET cDesCausa   		= "";
LET cNombre1   		= "";
LET cNombre2   		= "";
LET cApellPaterno   = "";
LET cApellMaterno   = "";

LET cRfc   	= "";
LET cSucursal   = "";
LET dcAbonosVencidos = 0.00;
LET dcVencidocoppel = 0.00;
LET dtFechaCons = "";
LET dabonomes = 0.00; --AAME. RQM 09 333 Se inicia variable para el nuevo campo a retornar.
LET dabonbase = 0.00;
	
BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet,cMensajeRet,"","","",0,"","","","","","",0,0,"",0,"",0,"","","","","","","","",0.00;
		 
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/tmp/mfinis/sp_relacion_consultainfocte.out";
	--TRACE ON;
	
	-- VALIDA LOS PARAMETROS DE ENTRADA
	IF NVL(pNumcte,"") = "" THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Parametros de entrada incompletos,verifique';
	ELSE--obtiene la información del cliente
		
		SELECT a.numcte,a.nombre1,a.nombre2,a.apell_paterno,a.apell_materno,a.numcte_ref,b.fecha_nac,a.rfc,a.sucursal
			INTO cNumcte,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cNumRef,cFechaNac,cRfc,cSucursal
		FROM bdinteg:"informix".si_cliente a,
			 bdinteg:"informix".si_ctepf b 
		WHERE a.empresa = b.empresa
		AND a.numcte = b.numcte
		AND a.numcte = pNumcte;
			
		LET cNombreCte = TRIM(cNombre1)||" "||TRIM(cNombre2)||" "||TRIM(cApellPaterno)||" "||TRIM(cApellMaterno);
		
		IF NVL(cNumcte,"") = "" THEN
			LET cCodRet = '000003';
			LET cMensajeRet = 'Número de cliente no existe, verifique';
		ELIF NVL(cNumRef,"") = "" THEN
			 LET cCodRet = '000002';
			 LET cMensajeRet = 'No se encontro información en Coppel. Favor de Validar el número de Cliente Coppel';
        ELSE	
		
			/*
			IF EXISTS (SELECT nombre_coppel FROM bdisolic:"informix".ss_bitacora_precal WHERE empresa = '001' 	AND num_referencia = cNumRef ) THEN
				
				SELECT nombre_coppel
					INTO cNombre_coppel
				FROM bdisolic:"informix".ss_bitacora_precal 
				WHERE empresa = '001' 
				AND num_referencia = cNumRef 
				AND ROWID = (SELECT MAX(ROWID)
								FROM  bdisolic:"informix".ss_bitacora_precal aux2
								WHERE aux2.empresa = '001' 
								AND aux2.num_referencia = cNumRef);							
			END IF;
			*/
			--
			
			--
			SELECT a.tipo_relacion,b.nombre,a.fecha_insert
				INTO sTipoRel,cNomEmpleado,cFechaRelacion
			FROM bdinteg:"informix".si_relacion_ctebcplcpl a
			LEFT OUTER JOIN bdinteg:"informix".si_ejecut b ON(a.empresa = b.empresa AND a.numempleado =  b.ejecutivo)
			WHERE a.empresa = '001'
			AND numcte_banco = pNumcte
			AND a.cliente = cNumRef	;
			
			SELECT valor_alfabetico
				INTO cDesTipoRel
			FROM  bdicobranza:"informix".cb_param_campania
			WHERE grupo_parametro ="TIPO_RELAC"
			AND valor_numerico = NVL(sTipoRel,0);
			
			IF NVL(sTipoRel,0) = 0 THEN
					LET cNomEmpleado 		= '';
					LET cNumRef 			= '';
					LET cFechaRelacion 	= '';
			END IF;
		END IF;
		IF NVL(sTipoRel,0) <> 3 THEN --VALIDACION DEL TIPO DE RELACION.
				 --valida si el cliente cuenta con solicitudes de credito
				 LET cNomEmpleado 		= '';
			 IF EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_solicitudes WHERE empresa = '001' 	AND        numcte = pNumcte ) THEN
				 SELECT NVL(num_solicitud,"")
				 INTO cNumSol
				 FROM bdisolic:"informix".ss_solicitudes  
				 WHERE empresa = '001'
				 AND numcte = pNumcte
				 AND status_solicitud = 'MC';
				-- AND ROWID = (SELECT MAX(ROWID)
				-- FROM  bdisolic:"informix".ss_solicitudes aux
				-- WHERE aux.empresa = '001'
				 --AND aux.numcte = pNumcte );		

				IF EXISTS (SELECT numcte FROM bdisolic:"informix".ss_respuesta_conscoppel WHERE empresa = '001' 	AND        numcte = pNumcte ) THEN
				--obtiene la información de la ultima consulta a coppel de la solicitud en proceso
					SELECT eficiencia,meseshist,puntualidad,sitespecial,causa,(vdoropa+vdomuebles+vdoprestamos+vdotiempoaire+vdonegociosafi+vdotiemporeestruc),nombrecop,fechanaccop,fecha_consulta,(abonomesropa + abonomesmuebles + abonomesprestamos),(abonomesropa + abonomesmuebles + abonomesprestamos+ abonomestiempoaire + abonomesnegociosafi + abonomestiemporeestruc)
						INTO dSituacion_pago,sMeses_historia, cPuntualidad,cSituacion_credito,sCausa,dcVencidocoppel,cNombre_coppel,cFechaNacCoppel,dtFechaCons,dabonomes,dabonbase -- AAME RQM 09 333 Se agrega nuevo campo para anexar el Abono Mensual del cliente 
					FROM bdisolic:"informix".ss_respuesta_conscoppel
					WHERE empresa = '001'
					AND numcte = pNumcte		
					AND numcte_ref = cNumRef
					AND fecha_insert = (select max(fecha_insert) from bdisolic:"informix".ss_respuesta_conscoppel
					WHERE empresa = '001' AND numcte = pNumcte AND numcte_ref = cNumRef);
				ELSE
					--obtiene la información de la ultima consulta a coppel de la solicitud obtenida anteriormente
					SELECT situacion_pago,meses_historia, puntualidad,situacion_credito,causa,(vencidoropa+vencidomuebles+vencidoprestamos+vencidototalaire+vencidototalafiliados+vencidototalreestructura),(abonomensualropa + abonomensualmuebles + abonomensualprestamos),(abonomensualropa + abonomensualmuebles + abonomensualprestamos+ abonomensualaire + abonomensualafiliados + abonomensualreestructura)
					INTO dSituacion_pago,sMeses_historia, cPuntualidad,cSituacion_credito,sCausa,dcVencidocoppel,dabonomes,dabonbase-- AAME RQM 09 333 Se agrega nuevo campo para anexar el Abono Mensual del cliente 
					FROM  bdisolic:"informix".ss_resum_scor_fin 
					WHERE empresa = '001'
					AND num_solicitud = cNumSol;
				END IF;
					--obtiene la descripcion de la causa 
				SELECT {+INDEX(bdisitesp:se_catsitesp idx_catsitesp)} descripcion
				INTO  cDesCausa
				FROM bdisitesp:"informix".se_catsitesp
				WHERE situacion = TRIM(cSituacion_credito)
				AND causa = sCausa;
			 END IF; --FIN DE VALIDA SI EL CLIENTE CUENTA CON SOLICITUDES DE CREDITO	
		ELSE

			SELECT eficiencia,meseshist,puntualidad,sitespecial,causa,(vdoropa+vdomuebles+vdoprestamos+vdotiempoaire+vdonegociosafi+vdotiemporeestruc),nombrecop,fechanaccop,fecha_consulta,(abonomesropa + abonomesmuebles + abonomesprestamos),(abonomesropa + abonomesmuebles + abonomesprestamos+ abonomestiempoaire + abonomesnegociosafi + abonomestiemporeestruc)
				INTO dSituacion_pago,sMeses_historia, cPuntualidad,cSituacion_credito,sCausa,dcVencidocoppel,cNombre_coppel,cFechaNacCoppel,dtFechaCons,dabonomes,dabonbase -- AAME RQM 09 333 Se agrega nuevo campo para anexar el Abono Mensual del cliente 
			FROM bdisolic:"informix".ss_respuesta_conscoppel
			WHERE empresa = '001'
			AND numcte = pNumcte		
			AND numcte_ref = cNumRef;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET dSituacion_pago ="";
				LET sMeses_historia ="";
				LET cPuntualidad ="";
				LET cSituacion_credito ="";
				LET  sCausa ="";
				LET dcVencidocoppel ="";
				LET cNombre_coppel ="";
				LET cFechaNacCoppel="";
				LET dtFechaCons="";
			ELSE
				IF NVL(cSituacion_credito,'' ) <> '' AND NVL(sCausa,0) <> 0 THEN
			 --obtiene la descripcion de la causa 
					SELECT {+INDEX(bdisitesp:se_catsitesp idx_catsitesp)} descripcion
					INTO  cDesCausa
					FROM bdisitesp:"informix".se_catsitesp
					WHERE situacion = TRIM(cSituacion_credito)
					AND causa = sCausa;						
					
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						SELECT descripcion 
							INTO cDesCausa 
						FROM bdicred:"informix".sd_situacion_cred 
						WHERE situacion = TRIM(cSituacion_credito);		
					END IF; --FIN DE SI ARROJO O NO INFORMACION DE LA CAUSA
				END IF; --FIN DE LA OBTENCIÓN DE DESCRIPCION DE LA CAUSA
			END IF;		END IF;	--FIN DE VALIDACION DEL TIPO DE RELACION
	END IF;	--FIN DE VALIDACION DE LOS PARAMETROS DE ENTRADA
	LET dAbonosVen = CASE WHEN dabonbase <= 0 THEN 0 ELSE dcVencidocoppel / dabonbase END;
		
	RETURN cCodRet,TRIM(cMensajeRet),pNumcte,NVL(cNombreCte,""),NVL(cFechaNac,""),NVL(sTipoRel,0),NVL(cDesTipoRel,""),NVL(cNomEmpleado,""),NVL(cNumRef,''),NVL(cNombre_coppel,""),	
        	NVL(cFechaNacCoppel,""),NVL(cFechaRelacion,""),NVL(dSituacion_pago,0),NVL(sMeses_historia,0), NVL(cPuntualidad,""),NVL(dAbonosVen,0),
			NVL(cSituacion_credito,"0"),NVL(sCausa,0),NVL(cDesCausa,""),NVL(cNombre1,''),NVL(cNombre2,''),NVL(cApellPaterno,''),NVL(cApellMaterno,''),NVL(cSucursal,''),NVL(cRfc,''),NVL(dtFechaCons,''),NVL(dabonomes,0.00);
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta para obtener la información general del cliente en bancoppel y coppel', 
'AUTOR: Jesús Aguilar ',
'FECHA: 26 ABRIL 2012',
'BD: BDINTEG',
'VERSION: 20120426.1641',

'Modificación',
'DESCRIPCION: Se modificó para omitir las consultas a  los campos que son Fecha Nac, Nombre del Cliente', 'Eficiencia, Meses de Historia, Puntualidad, Vencidos UDIS, Situación Especial, Causa y Descripción SE en caso de', 'tener al tipo de relación ?3?', 
'AUTOR: Josué Remberto Zazueta Acosta ',
'FECHA: 28  de Junio 2012',
'BD: BDINTEG',
'VERSION: 20120628.1230',

'Modificación',
'DESCRIPCION: Se modifica para que no regrese nombre del empleado,fecha de relacion y numero de referencia en caso', 'de que la el tipo de relacion sea = 0', 
'AUTOR: Josué Remberto Zazueta Acosta ',
'FECHA: 27  de Julio 2012',
'BD: BDINTEG',
'VERSION: 20120727.0518',

'Modificación',
'DESCRIPCION: Se modifica para eliminar el campo vencidos udis y reemplazarlos por abonos vencidos', 
'AUTOR: Daniel Reyes Guillen',
'FECHA:28/10/2021',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_consultageneralescte_club
(
	pEmpresa 	CHAR(03),
	pNumCte		CHAR(20)
)

RETURNING
	CHAR(06) AS cCodRet,
	CHAR(15) AS cNombreProspecto,
	CHAR(15) AS cApellidoPaterno,
	CHAR(15) AS cApellidoMaterno,
	CHAR(10) AS cFechaNac,
	CHAR(13) AS iTelefonoCasa,
	CHAR(13) AS iTelefonoCelular,
	CHAR(01) AS cSexo,
	CHAR(01) AS cEstadoCivil,
	INTEGER  AS iCuidad,
	INTEGER  AS iColonia,
	INTEGER  AS iCalle,
	INTEGER  AS iCasa,
	CHAR(30) AS cComplemento,
	CHAR(01) AS cRumbo,
	INTEGER  AS iManzana,
	INTEGER  AS iOtros,
	INTEGER  AS iAndador,
	INTEGER  AS iEtapa,
	INTEGER  AS iLote,
	INTEGER  AS iEdificio,
	INTEGER  AS iCentrada,
	CHAR(04) AS cNumDeptoInt

--VARIABLES DE RETORNO
DEFINE rcCodRet				CHAR(06);
DEFINE rcNombreProspecto	CHAR(15);
DEFINE rcApellidoPaterno	CHAR(15);
DEFINE rcApellidoMaterno	CHAR(15);
DEFINE rcFechaNac			CHAR(10);
DEFINE riTelefonoCasa		CHAR(13);
DEFINE riTelefonoCelular	CHAR(13);
DEFINE rcSexo				CHAR(01);
DEFINE rcEstadoCivil		CHAR(02);
DEFINE riCuidad				INTEGER;
DEFINE riColonia			INTEGER;
DEFINE riCalle				INTEGER;
DEFINE riCasa				INTEGER;
DEFINE rcComplemento		CHAR(30);
DEFINE rcRumbo				CHAR(01);
DEFINE riManzana			INTEGER;
DEFINE riAndador			INTEGER;
DEFINE riOtros				INTEGER;
DEFINE riEtapa				INTEGER;
DEFINE riLote				INTEGER;
DEFINE riEdificio			INTEGER;
DEFINE riEntrada			INTEGER;
DEFINE rcNumDeptoInt		CHAR(04);
--VARIABLES LOCALES
DEFINE iSql_err				INTEGER;
DEFINE cNombre1				CHAR(26);
DEFINE cNombre2				CHAR(26);
DEFINE cApellidoPaterno		CHAR(26);
DEFINE cApellidoMaterno		CHAR(26);
DEFINE dFecha_nac			DATE;
DEFINE cSexo				CHAR(01);
DEFINE cEstado_civil		CHAR(02);
DEFINE iNumeroCuidad		INTEGER;
DEFINe iNumeroColonia		INTEGER;
DEFINE iNumeroCalle			INTEGER;
DEFINE cNumeroExtCalle		CHAR(10);
DEFINE cObservaciones		CHAR(80);
DEFINE cPuntoCardinal		CHAR(01);
DEFINE iManzana				INTEGER;
DEFINE iOtros				INTEGER;
DEFINE iAndador				INTEGER;
DEFINE iEtapa				INTEGER;
DEFINE iLote				INTEGER;
DEFINE iEdificio			INTEGER;
DEFINE iEntrada				INTEGER;
DEFINE cNumeroIntCalle		CHAR(10);
DEFINE cSucursal 			CHAR(4);
DEFINE cCiudadSucursal 		CHAR(4);
DEFINE cEstadoSucursal 		CHAR(2);
DEFINE iCiudadCoppel 		INTEGER;
DEFINE iColoniaCoppel 		INTEGER;
DEFINE p_cod_ret			CHAR(1);

--DSB-05/03/2015
DEFINE cTelefonoCasaTemp	CHAR(13);
DEFINE cTelefonoCelularTemp	CHAR(13);

--INICIALIZACIÓN DE VARIABLES
LET rcCodRet			= '000000';
LET rcNombreProspecto	= '';
LET rcApellidoPaterno	= '';
LET rcApellidoMaterno	= '';
LET rcFechaNac			= '';
LET riTelefonoCasa		= '';
LET riTelefonoCelular	= '';
LET rcSexo				= '';
LET rcEstadoCivil		= '';
LET riCuidad			= -1;
LET riColonia			= -1;
LET riCalle				= -1;
LET riCasa				= -1;
LET rcComplemento		= '';
LET rcRumbo				= '';
LET riManzana			= -1;
LET riAndador			= -1;
LET riOtros				= -1;
LET riEtapa				= -1;
LET riLote				= -1;
LET riEdificio			= -1;
LET riEntrada			= -1;
LET rcNumDeptoInt		= '';
LET cSucursal 			= '';
LET cCiudadSucursal 	= '';
LEt cEstadoSucursal 	= '';
LET iCiudadCoppel 		= 0;
LET iColoniaCoppel 		= 0;
LET p_cod_ret = '';
LET cObservaciones		='';
LET cNumeroIntCalle		='';

LET cTelefonoCasaTemp		= '';
LET cTelefonoCelularTemp	= '';

--SET DEBUG FILE TO '/tmp/Victor/sp_consultageneralescte_club_out.sql';
---TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET rcCodRet = iSql_err;
			RETURN rcCodRet, rcNombreProspecto, rcApellidoPaterno, rcApellidoMaterno, rcFechaNac, riTelefonoCasa,
				   riTelefonoCelular, rcSexo, rcEstadoCivil, riCuidad, riColonia, riCalle, riCasa, rcComplemento, rcRumbo,
				   riManzana, riOtros, riAndador, riEtapa, riLote, riEdificio, riEntrada, rcNumDeptoInt;
		END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	--SET LOCK MODE TO WAIT 4;
	SET LOCK MODE TO WAIT 3; -- INC25112021

	--QUITAR ESPACIOS
	LET pEmpresa 	= TRIM(pEmpresa);
	LET pNumCte 	= TRIM(pNumCte);
	
	--VALIDAR PARÁMETROS VACÍOS Y NULOS
	IF NVL(pEmpresa, '') = '' OR NVL(pNumCte, '') = '' THEN
		LET rcCodRet = '000001';
		RETURN rcCodRet, rcNombreProspecto, rcApellidoPaterno, rcApellidoMaterno, rcFechaNac, riTelefonoCasa,
			   riTelefonoCelular, rcSexo, rcEstadoCivil, riCuidad, riColonia, riCalle, riCasa, rcComplemento, rcRumbo,
			   riManzana, riOtros, riAndador, riEtapa, riLote, riEdificio, riEntrada, rcNumDeptoInt;
	END IF;
	
	--BÚSQUEDA DE DATOS
	SELECT nombre1, nombre2, apell_paterno, apell_materno, sucursal
	INTO cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cSucursal
	FROM "informix".si_cliente
	WHERE empresa = pEmpresa AND numcte = pNumCte;
	
	--SI NO REGRESÓ DATOS
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET rcCodRet = '000002';
		RETURN rcCodRet, rcNombreProspecto, rcApellidoPaterno, rcApellidoMaterno, rcFechaNac, riTelefonoCasa,
			   riTelefonoCelular, rcSexo, rcEstadoCivil, riCuidad, riColonia, riCalle, riCasa, rcComplemento, rcRumbo,
			   riManzana, riOtros, riAndador, riEtapa, riLote, riEdificio, riEntrada, rcNumDeptoInt;
	END IF
	
	/*SELECT ciudad, estado
	INTO cCiudadSucursal, cEstadoSucursal
	FROM "informix".si_sucursales
	WHERE sucursal = cSucursal;*/
	
	--CAMBIO
	/*SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)}TRIM(cve_ciudad),TRIM(cve_estado) 
    INTO cCiudadSucursal, cEstadoSucursal
    FROM bdinteg:"informix".si_ptf 
    WHERE id_ptf = cSucursal AND tipo='S';*/
	
	SELECT FIRST 1 {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)}TRIM(cve_ciudad),TRIM(cve_estado) 
    INTO cCiudadSucursal, cEstadoSucursal
    FROM bdinteg:"informix".si_ptf 
    WHERE id_ptf = cSucursal AND (tipo='X' OR tipo='S');   --INC27092021 Se agrega tipo X a la consulta ya que hay veces donde no existe la sucursal
																	 --con el filtro tipo S
	
	--FIN CAMBIO
	SELECT fecha_nac, sexo, estado_civil
	INTO dFecha_nac, cSexo, cEstado_civil
	FROM "informix".si_ctepf
	WHERE empresa = pEmpresa AND numcte = pNumCte;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET rcCodRet = '000002';
		RETURN rcCodRet, rcNombreProspecto, rcApellidoPaterno, rcApellidoMaterno, rcFechaNac, riTelefonoCasa,
			   riTelefonoCelular, rcSexo, rcEstadoCivil, riCuidad, riColonia, riCalle, riCasa, rcComplemento, rcRumbo,
			   riManzana, riOtros, riAndador, riEtapa, riLote, riEdificio, riEntrada, rcNumDeptoInt;
	END IF
	
	SELECT numerociudad, numerocolonia, numerocalle, numeroextcalle, observaciones, puntocardinal, manzana, otros, andador,
	       etapa, lote, edificio, entrada, numerointcalle
	INTO iNumeroCuidad, iNumeroColonia, iNumerocalle, cNumeroExtCalle, cObservaciones, cPuntoCardinal, iManzana, iOtros,
		 iAndador, iEtapa, iLote, iEdificio, iEntrada, cNumeroIntCalle
	FROM "informix".si_direcciones_actual
	WHERE numcte = pNumCte AND tipo_dir = '1';
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET rcCodRet = '000002';
		RETURN rcCodRet, rcNombreProspecto, rcApellidoPaterno, rcApellidoMaterno, rcFechaNac, riTelefonoCasa,
			   riTelefonoCelular, rcSexo, rcEstadoCivil, riCuidad, riColonia, riCalle, riCasa, rcComplemento, rcRumbo,
			   riManzana, riOtros, riAndador, riEtapa, riLote, riEdificio, riEntrada, rcNumDeptoInt;
	END IF
	
	--IF NVL(cNumeroExtCalle,'') = '' OR cNumeroExtCalle = '0' THEN
		--LET cNumeroExtCalle = '1';
	--END IF;
	
	EXECUTE PROCEDURE "informix".sp_esnumerico (cNumeroExtCalle) INTO p_cod_ret;
	
	IF p_cod_ret = 'F' OR (cNumeroExtCalle::int) = 0 THEN
			LET cNumeroExtCalle = '1';
	END IF;
	
	SELECT FIRST 1 numerocoloniacoppel, numerociudadcoppel
	INTO iColoniaCoppel, iCiudadCoppel
	FROM "informix".si_catzonas
	WHERE numerociudad = iNumeroCuidad AND numerocolonia = iNumeroColonia;
	
	/*                    SE COMENTA BLOQUE PARA TOMAR DE MEJOR MANERA LA OBTENCION DE CIUDAD Y COLONIA COPPEL
	IF NVL(iColoniaCoppel,0) = 0 THEN
		SELECT FIRST 1 CASE WHEN "informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
		INTO iColoniaCoppel FROM "informix".si_catzonas WHERE numerociudad = cCiudadSucursal;
	END IF;
	
	--CAMBIO  --INC27092021     
	IF NVL(iColoniaCoppel,0) = 0 THEN
		SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
		INTO iColoniaCoppel FROM bdinteg:"informix".si_catzonas WHERE numerociudad = cCiudadSucursal and numerocoloniacoppel <> 0;
	END IF;

	IF NVL(iColoniaCoppel,0) = 0 THEN
		SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
		INTO iColoniaCoppel FROM bdinteg:"informix".si_catzonas WHERE numerocoloniacoppel <> 0;
	END IF; -- Se agregan estas 2 validaciones al igual que con iCiudadCoppel debido a que faltaban estos filtros para evitar que se vaya en 0 el campo
	--FIN CAMBIO
	IF NVL(iCiudadCoppel,0) = 0 THEN
		SELECT FIRST 1 CASE WHEN "informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END
		INTO iCiudadCoppel FROM "informix".si_catzonas WHERE numerociudad = cCiudadSucursal;
	END IF; 
	
	--DSB 31/07/2017	
	IF NVL(iCiudadCoppel,0) = 0 THEN 
		SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END
		INTO iCiudadCoppel FROM bdinteg:"informix".si_catzonas WHERE numerociudad = cCiudadSucursal and numerociudadcoppel <> 0;
	END IF;

	IF NVL(iCiudadCoppel,0) = 0 THEN
		SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END
		INTO iCiudadCoppel FROM bdinteg:"informix".si_catzonas WHERE numerociudadcoppel <> 0;
	END IF;
	*/ --INC18102021
	------------------------------------------------------------------------------------------------------------
	-- SI NO EXISTE CIUDAD O COLONIA COPPEL RELACIONADAS SE OBTIENEN DE LA SUCURSAL DONDE SE DIO DE ALTA EL CLIENTE
	------------------------------------------------------------------------------------------------------------
		IF NVL(iCiudadCoppel,0) = 0 OR NVL(iColoniaCoppel,0) = 0 THEN
			
			IF NVL(cCiudadSucursal,0) <> 0 THEN
				SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END,
							   CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
				INTO iCiudadCoppel, iColoniaCoppel
				FROM bdinteg:"informix".si_catzonas
				WHERE numerociudad = cCiudadSucursal;
			END IF;

			-----------------------------------------------------------------------------------------------
			-- SI NO EXISTE CIUDAD O COLONIA COPPEL RELACIONADAS SE TOMARA EL PRIMER REGISTRO DEL CATALOGO
			-----------------------------------------------------------------------------------------------
			IF NVL(iCiudadCoppel,0) = 0 OR NVL(iColoniaCoppel,0) = 0 THEN
				SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END,
							   CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
				INTO iCiudadCoppel, iColoniaCoppel
				FROM bdinteg:"informix".si_catzonas
				WHERE numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL
				AND numerocoloniacoppel <> 0 AND numerocoloniacoppel IS NOT NULL;
			END IF;

		END IF;
	-- INC18102021 	"SE AGREGA MODIFICACION"  TERMINA
	
	SELECT telefono
	INTO cTelefonoCasaTemp --DSB-05/03/2015
	FROM "informix".si_telefonos_actual
	WHERE empresa = pEmpresa AND numcte = pNumCte AND tipo_tel = '1';
	
	SELECT telefono
	INTO cTelefonoCelularTemp --DSB-05/03/2015
	FROM "informix".si_telefonos_actual
	WHERE empresa = pEmpresa AND numcte = pNumCte AND tipo_tel = '2';
	
	IF NVL(cNombre1, '') = '' OR NVL(cApellidoPaterno, '') = '' THEN
		LET rcCodRet = '000003';
		RETURN rcCodRet, rcNombreProspecto, rcApellidoPaterno, rcApellidoMaterno, rcFechaNac, riTelefonoCasa,
			   riTelefonoCelular, rcSexo, rcEstadoCivil, riCuidad, riColonia, riCalle, riCasa, rcComplemento, rcRumbo,
			   riManzana, riOtros, riAndador, riEtapa, riLote, riEdificio, riEntrada, rcNumDeptoInt;
	END IF
	
	--DSB-05/03/2015
	EXECUTE PROCEDURE sp_alfanumerico (cTelefonoCasaTemp) INTO cTelefonoCasaTemp;
	EXECUTE PROCEDURE sp_alfanumerico (cTelefonoCelularTemp) INTO cTelefonoCelularTemp;
	
	LET rcNombreProspecto	= SUBSTRING(TRIM(cNombre1) || ' ' || TRIM(NVL(cNombre2, '')) FROM 1 FOR 15);
	LET rcApellidoPaterno	= SUBSTRING(cApellidoPaterno FROM 1 FOR 15);
	LET rcApellidoMaterno	= SUBSTRING(NVL(cApellidoMaterno, '') FROM 1 FOR 15);
	LET rcFechaNac			= TO_CHAR(dFecha_nac,'%Y%m%d');
	LET riTelefonoCasa		= SUBSTRING(TRIM(NVL(cTelefonoCasaTemp, '')) FROM 1 FOR 10);	LET riTelefonoCelular	= SUBSTRING(TRIM(NVL(cTelefonoCelularTemp, '')) FROM 1 FOR 10);	LET rcSexo				= cSexo;
	LET rcEstadoCivil		= SUBSTRING(cEstado_Civil FROM 1 FOR 1);
	LET riCuidad			= iCiudadCoppel;
	LET riColonia			= iColoniaCoppel;
	LET riCalle				= iNumeroCalle; 
	LET riCasa				= cNumeroExtCalle;
	LET rcRumbo				= cPuntoCardinal;
	LET riManzana			= iManzana;
	LET riOtros				= iOtros;
	LET riAndador			= iAndador;
	LET riEtapa				= iEtapa;
	LET riLote				= iLote;
	LET riEdificio			= iEdificio;
	LET riEntrada			= iEntrada;
	
	
	--DSB-17/02/2015
	EXECUTE PROCEDURE sp_alfanumerico (cObservaciones) INTO cObservaciones;
	EXECUTE PROCEDURE sp_alfanumerico (cNumeroIntCalle) INTO cNumeroIntCalle;
	
	LET rcComplemento		= cObservaciones;
	LET rcNumDeptoInt		= cNumeroIntCalle; 
	
	RETURN rcCodRet, rcNombreProspecto, rcApellidoPaterno, rcApellidoMaterno, rcFechaNac, riTelefonoCasa, riTelefonoCelular,
		   rcSexo, rcEstadoCivil, riCuidad, riColonia, riCalle, riCasa, rcComplemento, rcRumbo, riManzana, riOtros, riAndador,
		   riEtapa, riLote, riEdificio, riEntrada, rcNumDeptoInt;
END;
END PROCEDURE

DOCUMENT
'Retorna la descripción para el encabezado y descripción del producto del club de protección.',
'AUTOR : 95579737 - José Ernesto Raygoza Villa',
'FECHA : --/--/2014-04',
'Se agregan validaciones para el correcto envio del servicio.',
'AUTOR : 94379114 - Victor Hugo Nuñez',
'FECHA : 17/02/2015',
'Se agregan validaciones al telefono.',
'AUTOR : 94379114 - Victor Hugo Nuñez',
'FECHA : 06/03/2015',
'Se agregan validaciones para el campo ciudad_coppel que no se valla en 0.',
'AUTOR : 94480389 - Edwin Castro',
'FECHA : 31/07/2017',
'BD    : bdinteg',
'*****************************************************************************************************************************************',
'PROYECTO: INC_CIUDAD_COLONIA_CERO_14',
'FOLIO: 1981',
'DESCRIPCION: Se homologan dos sps sp_consultageneralescte_club y sp_altactecoppelnuevoparametrico_club para la optencion de la Ciudad y colonia',
' Y una modificacion en el where (tipo="X" OR tipo="S") ya que no se esta llenando ese valor por que no existen en algunos casos sucursales con tipo S',
'AUTOR: 98467379 - Hector aguilar',
'ETIQUETA: INC27092021',
'BD: BDINTEG',
'FECHA: 27/09/2021',
'SOLICITA: Fabiola Martinez Mozo Y Federico Magdaleno',
'*****************************************************************************************************************************************',
'PROYECTO: INC_HOMOLOGACION_CIUDAD/COLONIA_14',
'FOLIO: 1984',
'DESCRIPCION: Se homologan tres sps sp_envioparametricocoppel_cteprosp, sp_consultageneralescte_club y sp_altactecoppelnuevoparametrico_club para la obtencion de la Ciudad y colonia',
'AUTOR: 98467379 - Hector aguilar',
'ETIQUETA: INC18102021',
'BD: BDINTEG',
'FECHA: 18/10/2021',
'SOLICITA: Fabiola Martinez Mozo Y Federico Magdaleno',
'*****************************************************************************************************************************************',
'PROYECTO: INC_HOM_INDEX_CIUDAD_COLONIA_14_16',
'FOLIO: 1988',
'DESCRIPCION: Se agregan indices para bajar los costos y se modifica SET LOCK MODE TO WAIT 4 a SET LOCK MODE TO WAIT 3 por peticion de el cliente',
'AUTOR: 98467379 - Hector aguilar',
'ETIQUETA: INC25112021',
'BD: BDINTEG',
'FECHA: 25/11/2021',
'SOLICITA: Fabiola Martinez Mozo Y Federico Magdaleno',
'*****************************************************************************************************************************************';

CREATE PROCEDURE "informix".sp_ht_obtener_tels_sin_guardar()
RETURNING CHAR(6),		-- CODIGO DE RETORNO
          CHAR(13),		-- FOLIO ARCHIVO
		  INT8,			-- TOTAL DE CLIENTES
		  INT8;			-- NUMERO DE TELEFONOS DUPLICADOS
          
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);
    DEFINE cDescRet			CHAR(80);
    
    DEFINE dFechaHoy		DATE;
    DEFINE cHoraMinHoy		CHAR(4);
    DEFINE cCte				CHAR(20);
    DEFINE dtFechaCte		DATE;
    DEFINE cNombre1			CHAR(26);
    DEFINE cNombre2			CHAR(26);
    DEFINE cApellPaterno	CHAR(26);
    DEFINE cApellMaterno	CHAR(26);
    DEFINE cNomEstado		CHAR(30);
    DEFINE cNomCiudad		CHAR(26);
    DEFINE iTipoTel			SMALLINT;
    DEFINE iCarrier			SMALLINT;
    DEFINE cTelefono		CHAR(13);
    DEFINE cFolioArchivo	CHAR(13);
    DEFINE iNumTelsDup		INT8;
    DEFINE iNumSecCte		INT8;
    DEFINE iTotCtes			INT8;
    DEFINE iBandera			SMALLINT;
    DEFINE iExiste			SMALLINT;
    DEFINE cVerificado		CHAR(1);
	DEFINE dFechaAnte		DATE;
    
    LET iSqlErr             = 0;
    LET iIsamErr            = 0;
    LET cErrorInfo          = "";
    LET cCodRet             = "000000";
    LET cDescRet			= "PROCESO EXITOSO";
    
    LET dFechaHoy			= DATE(1);
    LET cHoraMinHoy			= "";
    LET cCte				= "";
    LET dtFechaCte			= DATE(1);
    LET cNombre1			= "";
    LET cNombre2			= "";
    LET cApellPaterno		= "";
    LET cApellMaterno		= "";
    LET cNomEstado			= "";
    LET cNomCiudad			= "";
    LET iTipoTel			= 0;
    LET iCarrier			= 0;
    LET cTelefono			= "";
    LET cFolioArchivo		= "";
    LET iNumTelsDup			= 0;
    LET iNumSecCte			= 1;
    LET iTotCtes			= 0;
    LET iBandera			= 0;
    LET iExiste				= 0;
    LET cVerificado			= "";
	LET dFechaAnte			= DATE(1);

    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cDescRet = cErrorInfo;
            RETURN cCodRet, cFolioArchivo, iTotCtes, iNumTelsDup;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
     --SET DEBUG FILE TO '/informix/moha/sp_ht_obtener_tels_sin_guardar.out';
     --TRACE ON;
    
    --// OBTIENE LA HORA DE HOY
    SELECT fecha_hoy, SUBSTR(CURRENT::DATETIME HOUR TO SECOND,1,2) || SUBSTR(CURRENT::DATETIME HOUR TO SECOND,4,2)
      INTO dFechaHoy, cHoraMinHoy
      FROM "informix".si_fechas
     WHERE empresa = "001";
	
	IF DAY(dFechaHoy) = 22 THEN
		LET dFechaAnte = dFechaHoy - 1 UNITS MONTH;
		LET dFechaAnte = dFechaAnte - 2 UNITS DAY;
	
		--// ACTUALIZA LAS FECHAS QUE YA PASARON
		UPDATE "informix".si_ht_controlproc
		SET status = 1
		WHERE fecha = dFechaAnte;
		
		LET dFechaAnte = dFechaHoy - 2 UNITS DAY;
	
		--// INSERTA EL NUEVO REGISTRO DEL MES
		INSERT INTO "informix".si_ht_controlproc(fecha, status)
		VALUES( dFechaAnte, 0 );
	END IF
	
	LET dFechaAnte = MDY(MONTH(dFechaHoy),20,YEAR(dFechaHoy));
	
	--// VALIDA QUE CORRA EL PROCESO SOLO SI HAY REGISTRO DEL MES ACTUAL
	IF EXISTS(SELECT status FROM "informix".si_ht_controlproc WHERE fecha = dFechaAnte AND status = 0) THEN

		CREATE TEMP TABLE tmp_si_ht_detalle_ctrl_tels
		(
		folio_archivo	char(13), 
		num_cte			char(20), 
		sec_cte			smallint default 1, 
		telefono		char(13),
		PRIMARY KEY(folio_archivo,num_cte,telefono)
		) WITH NO LOG;

		--// CREACION DEL FOLIO
		LET cFolioArchivo =  "137" || SUBSTR(YEAR(dFechaHoy),3,2) || LPAD(MONTH(dFechaHoy),2,"0") || LPAD(DAY(dFechaHoy),2,"0") || cHoraMinHoy;
		
		--// OBTIENE TELEFONOS DE CLIENTES DE CREDITO
		--IFRS Se contemplan los nuevos estatus por etapas  equivalente a vencidos
		SELECT {+INDEX (si_bitacora_tel idx_bitactel_cte)}
			   dos.num_credito, crd.numcte
		  FROM bdicred: "informix".sd_maesdos dos
		 INNER JOIN bdicred: "informix".sd_maecred crd ON (dos.num_credito = crd.num_credito)
		 INNER JOIN "informix".si_bitacora_tel bt ON (bt.numcte = crd.numcte)
		 WHERE crd.status_Cred IN ('BA','BT','E1','E2','E3')
		   AND (dos.monto_vencido + dos.mto_venc_trasp) > 0
		 --WHERE crd.status_cred IN ("BA","BT")
		   AND bt.sucursal = "0000"
		INTO TEMP tmp_ctes_cred WITH NO LOG;
		CREATE INDEX idx_tmp_creds ON tmp_ctes_cred(numcte) USING BTREE FILLFACTOR 99;
		UPDATE STATISTICS HIGH FOR TABLE tmp_ctes_cred;
		
		LET cCte = "";
		
		--// GENERA LA ULTIMA TABLA TEMPORAL DE CREDITO
		SELECT {+INDEX(si_telefonos_actual idx_telact_ctetipo)}
			   cte.numcte, cte.fecha_insert, cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno,
			   edo.nombre, cd.nombreciudad, tel.tipo_tel, tel.carrier, tel.telefono
		  FROM tmp_ctes_cred tmp
		 INNER JOIN "informix".si_cliente cte ON ( tmp.numcte = cte.numcte )
		 INNER JOIN "informix".si_telefonos_actual tel ON ( tel.numcte = cte.numcte AND tel.tipo_tel IN (1,2) AND tel.cofetel = "V" AND LENGTH(tel.telefono) = 10 )
		  LEFT OUTER JOIN "informix".si_direcciones_actual dir ON ( dir.numcte = cte.numcte AND dir.tipo_dir = 1 )
		  LEFT OUTER JOIN "informix".si_catcalles calle ON ( calle.numerocalle = dir.numerocalle )
		  LEFT OUTER JOIN "informix".si_catzonas zona ON ( zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia )
		  LEFT OUTER JOIN "informix".si_catciudades cd ON ( cd.numerociudad = dir.numerociudad )
		  LEFT OUTER JOIN "informix".si_estados edo ON ( edo.estado = dir.estado )
		WHERE cte.fecha_insert < '07012014'
		INTO TEMP tmp_tels_credito WITH NO LOG;
		CREATE INDEX idxtmp_tels_credito_telefono ON tmp_tels_credito(telefono) USING btree fillfactor 99;
		UPDATE STATISTICS HIGH FOR TABLE tmp_tels_credito;
		
		--// LIBERA LA TEMPORAL
		DROP TABLE tmp_ctes_cred;
		
		--// VALIDA QUE NO EXISTAN TELEFONOS EN ARCHIVOS ANTERIORES
		SELECT *
		  FROM tmp_tels_credito
		 WHERE telefono NOT IN( SELECT telefono FROM si_ht_detalle_ctrl_tels )
		INTO TEMP tmp_tels_credito_2 WITH NO LOG;
		CREATE INDEX idxtmp_tels_credito_2_num_cte_tel ON tmp_tels_credito_2(numcte, telefono) USING btree fillfactor 99;
		UPDATE STATISTICS HIGH FOR TABLE tmp_tels_credito_2;
		
		--// LIBERA LA TEMPORAL
		DROP TABLE tmp_tels_credito;
		
		LET cCte = "";
		LET cTelefono = "";
		
		--// BORRA LOS TELEFONOS CELULARES QUE SE REPITEN EN PARTICULARES DEL MISMO CLIENTE
		FOREACH 
			SELECT numcte, telefono
			  INTO cCte, cTelefono
			  FROM tmp_tels_credito_2
			 GROUP BY 1, 2
			HAVING COUNT(*) > 1
			
			DELETE tmp_tels_credito_2 
			 WHERE numcte = cCte 
			   AND telefono = cTelefono 
			   AND tipo_tel = 2;
		END FOREACH
		
		LET cCte = "";
		LET cTelefono = "";
		
		--// CICLO PARA INSERTAR LOS TELEFONOS DE CREDITO
		FOREACH 
			SELECT numcte, fecha_insert, nombre1, nombre2, apell_paterno, apell_materno, nombre, nombreciudad, tipo_tel, carrier, telefono
			  INTO cCte, dtFechaCte, cNombre1, cNombre2, cApellPaterno, cApellMaterno, cNomEstado, cNomCiudad, iTipoTel, iCarrier, cTelefono
			  FROM tmp_tels_credito_2 t1
			 WHERE numcte = numcte 
			   AND telefono = telefono
			
			--// VALIDA EN LA SI TELEFONOS SI VERIFICADO ES NULO ENTONCES NO ESTA VALIDADO
			SELECT LIMIT 1 verificado
			  INTO cVerificado
			  FROM "informix".si_telefonos
			 WHERE numcte = cCte
			   AND telefono = cTelefono 
			   AND tipo_tel = iTipoTel;
			
			IF cVerificado IS NULL THEN
				LET iBandera = 0;
			ELSE
				SELECT 1
				  INTO iBandera
				  FROM "informix".si_tels_invalidos
				 WHERE telefono = cTelefono;
				
				LET iBandera = NVL(iBandera,0);
			END IF
			
			IF iBandera = 0 THEN
				LET iExiste = 0;
				
				SELECT 1
				  INTO iExiste
				  FROM "informix".tmp_si_ht_detalle_ctrl_tels
				 WHERE folio_archivo = cFolioArchivo 
				   AND num_cte = cCte 
				   AND telefono = cTelefono;
				
				LET iExiste = NVL(iExiste,0);
				
				IF iExiste = 0 THEN
					INSERT INTO "informix".tmp_si_ht_detalle_ctrl_tels (folio_archivo, num_cte, telefono)
					VALUES (cFolioArchivo, cCte, cTelefono);
				END IF
			END IF
		END FOREACH
			
		--// LIBERA LA TEMPORAL
		DROP TABLE tmp_tels_credito_2;
		
		LET cTelefono = "";
		
		--// VALIDA CUANTOS CLIENTES COMPARTEN EL MISMO TELEFONO
		FOREACH 
			SELECT telefono
			  INTO cTelefono
			  FROM "informix".tmp_si_ht_detalle_ctrl_tels
			 WHERE folio_archivo = cFolioArchivo
			 GROUP BY 1
			HAVING COUNT(num_cte) > 1
			
			LET cCte = "";
			LET iNumSecCte = 1;
			
			FOREACH 
				SELECT SKIP 1 num_cte
				  INTO cCte
				  FROM "informix".tmp_si_ht_detalle_ctrl_tels
				 WHERE folio_archivo = cFolioArchivo 
				   AND telefono = cTelefono
					
				LET iNumSecCte = iNumSecCte + 1;
				
				UPDATE "informix".tmp_si_ht_detalle_ctrl_tels
				   SET sec_cte = iNumSecCte
				 WHERE folio_archivo = cFolioArchivo 
				   AND num_cte = cCte 
				   AND telefono = cTelefono;
				
				LET iNumTelsDup = iNumTelsDup + 1;
			END FOREACH
		END FOREACH
		
		--// OBTIENE EL NUMERO TOTAL DE CLIENTES
		SELECT COUNT(*)
		  INTO iTotCtes
		  FROM "informix".tmp_si_ht_detalle_ctrl_tels
		 WHERE folio_archivo = cFolioArchivo;
		
		LET iTotCtes = NVL(iTotCtes,0);
		
		DROP TABLE tmp_si_ht_detalle_ctrl_tels;
		
	END IF
    
    RETURN cCodRet, cFolioArchivo, iTotCtes, iNumTelsDup;
    
    END;
    
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Agosto 2014';

CREATE PROCEDURE "informix".sp_ini_session_bex_mx2(pNumCel char(10),pImei CHAR(150), pUdid CHAR(150), pIp char(15))
   RETURNING CHAR(5), CHAR (20), CHAR(26), CHAR(26), CHAR(26), CHAR(26),  VARCHAR(2), DATETIME YEAR TO SECOND, VARCHAR(11), VARCHAR(5),CHAR(20),CHAR(100),money(14,2),DECIMAL(18,2),VARCHAR(2),VARCHAR(2);
   
	DEFINE cCod_ret 			 CHAR(5);
	DEFINE iSql_err 			 INTEGER ;
	DEFINE cNumCliente 			 CHAR (20);
	DEFINE sIdStatus 			 VARCHAR (2);
	DEFINE cNombre1, cNombre2, cApellPaterno, cApellMaterno CHAR (26);
	DEFINE iIdStatusToken 		 INTEGER;
	DEFINE dFecPrimAcceso 		 DATE;
	DEFINE dFecUltAcceso 		 CHAR(19);
	DEFINE dFecha  				 DATETIME YEAR TO SECOND;
	DEFINE vIdUsuario 			 VARCHAR(11);
	DEFINE cPass 				 CHAR(50);
	DEFINE vIntentos			 varchar(1);
	DEFINE vCodRetInt  			 CHAR(5);
	DEFINE vCanal				 CHAR(10);
	DEFINE vCtaAso				 CHAR(20);
	DEFINE pUser 				 INTEGER;
	DEFINE pCanal 				 INTEGER;
	DEFINE vLogCta 				 INTEGER;
	DEFINE vCta					 CHAR(20);
	DEFINE Vsdo 				 money(14,2);
	
	DEFINE cCodRet           	 CHAR(6);
	DEFINE cMensajeRet       	 CHAR(80);
	DEFINE cNumCredito       	 CHAR(20);
	DEFINE cCodTipCred       	 CHAR(2);
	DEFINE dtFechaOrigen     	 DATE;
	DEFINE dtFechaProxPago   	 DATE;
	DEFINE dPagoMinimo       	 DECIMAL(18,2);
	DEFINE dtFechaUltPago    	 DATE;
	DEFINE iPlazo            	 INTEGER;
	DEFINE iPagosRealizados  	 INTEGER;
	DEFINE dLineaOtorgada    	 DECIMAL(18,2);
	DEFINE dTasaInteres      	 DECIMAL(9,6);
	DEFINE dTasaMoratorios   	 DECIMAL(9,6);
	DEFINE dMontoSBC         	 DECIMAL(14,2);
	DEFINE dCapVig           	 DECIMAL(18,2);
	DEFINE dCapTrans         	 DECIMAL(18,2);
	DEFINE dCapVdoExig       	 DECIMAL(18,2);
	DEFINE dCapVdoNoExig     	 DECIMAL(18,2);
	DEFINE dSdoActCap        	 DECIMAL(18,2);
	DEFINE dIntVig           	 DECIMAL(18,2);
	DEFINE dIntVdo           	 DECIMAL(18,2);
	DEFINE dIntMoratorio     	 DECIMAL(18,2);
	DEFINE dIntMoratorio_d	 	 DECIMAL(18,2);
	DEFINE dIntMes           	 DECIMAL(18,2);
	DEFINE dSdoActInt        	 DECIMAL(18,2);
	DEFINE dIvaIntVig        	 DECIMAL(18,2);
	DEFINE dIvaIntVdo        	 DECIMAL(18,2);
	DEFINE dIvaIntMoratorio  	 DECIMAL(18,2);
	DEFINE dIvaIntMes        	 DECIMAL(18,2);
	DEFINE dSdoActIvaInt     	 DECIMAL(18,2);
	DEFINE dComPend          	 DECIMAL(18,2);
	DEFINE dIvaCom           	 DECIMAL(18,2);
	DEFINE dSdoRetenido      	 DECIMAL(18,2);
	DEFINE dSdoTotalLiq      	 DECIMAL(18,2);
	DEFINE dtIvaFechaPag         DATE;
	DEFINE dtFechaCuota          DATE;
	DEFINE dIntDevengado         DECIMAL(18,2);
	DEFINE dIvaIntDevengado      DECIMAL(18,2);
	DEFINE dLineaDisponible      DECIMAL(18,2);
	DEFINE dPagosVdos            DECIMAL(18,2);
	DEFINE cDescBloqueoCta       CHAR(60);
	DEFINE cDescCausaBloqueoCta  CHAR(50);
	DEFINE cSitCte               CHAR(1);
	DEFINE cCausaCte             INTEGER;
	DEFINE cDescSitEspCte        CHAR(75);
	DEFINE cSitCred              CHAR(1);
	DEFINE cCausaCred            INTEGER;
	DEFINE cDescSitEspCred       CHAR(75);
	DEFINE dFactorComision       DECIMAL(18,2);
	DEFINE dtMesiversario        DATE;
	DEFINE dtFechaHoy            DATE;
	DEFINE cTipCred              CHAR(2);
	DEFINE cDescStatusCred   	 CHAR(60);
	DEFINE iIdUnidadProd     	 INTEGER;
	DEFINE cCodCaract2       	 CHAR(3);
	DEFINE nCtaCred				 VARCHAR(2);
	DEFINE nCtaCap				 VARCHAR(2);
	DEFINE vNombre				 CHAR(100);
	
	LET cCodRet               = '';
	LET cMensajeRet           = '';
	LET cNumCredito           = '';
	LET cCodTipCred           = '';
	LET cDescStatusCred       = '';
	LET iIdUnidadProd         = 0;
	LET cCodCaract2           = '';
	LET dtFechaOrigen         = DATE(1);
	LET dtFechaProxPago       = DATE(1);
	LET dPagoMinimo           = 0;
	LET dtFechaUltPago        = DATE(1);
	LET iPlazo                = 0;
	LET iPagosRealizados      = 0;
	LET dLineaOtorgada        = 0;
	LET dTasaInteres          = 0;
	LET dTasaMoratorios       = 0;
	LET dMontoSBC             = 0;
	LET dCapVig               = 0;
	LET dCapTrans             = 0;
	LET dCapVdoExig           = 0;
	LET dCapVdoNoExig         = 0;
	LET dSdoActCap            = 0;
	LET dIntVig               = 0;
	LET dIntVdo               = 0;
	LET dIntMoratorio         = 0;
	LET dIntMoratorio_d       = 0;
	LET dIntMes               = 0;
	LET dSdoActInt            = 0;
	LET dIvaIntVig            = 0;
	LET dIvaIntVdo            = 0;
	LET dIvaIntMoratorio      = 0;
	LET dIvaIntMes            = 0;
	LET dSdoActIvaInt         = 0;
	LET dComPend              = 0;
	LET dIvaCom               = 0;
	LET dSdoRetenido          = 0;
	LET dSdoTotalLiq          = 0;
	LET dtIvaFechaPag         = DATE(1);
	LET dtFechaCuota          = DATE(1);
	LET dIntDevengado         = 0;
	LET dIvaIntDevengado      = 0;
	LET dLineaDisponible      = 0;
	LET dPagosVdos            = 0;
	LET cDescBloqueoCta       = '';
	LET cDescCausaBloqueoCta  = '';
	LET cSitCte               = '';
	LET cCausaCte             = 0;
	LET cDescSitEspCte        = '';
	LET cSitCred              = '';
	LET cCausaCred            = 0;
	LET cDescSitEspCred       = '';
	LET dFactorComision       = 0;
	LET dtMesiversario        = DATE(1);
	LET dtFechaHoy            = DATE(1);
	LET cTipCred              = '';
	LET nCtaCred			  = '0';
	LET nCtaCap				  = '0';
	LET cCod_ret  			  = "00000";
	LET cNumCliente  		  = '';
	LET sIdStatus 			  = '0';
	LET cNombre1 			  = '';
	LET cNombre2 			  = '';
	LET cApellPaterno  		  = '';
	LET cApellMaterno  		  = '';
	LET iIdStatusToken 		  = 0;
	LET dFecUltAcceso 		  = '';
	LET dFecha				  = NULL;
	LET vIdUsuario 			  = '';
	LET cPass 				  = '';
	let vIntentos			  = '0';
	LET vCodRetInt			  = '';
	LET vCanal				  = '';
	LET vCtaAso				  = '';
	LET pUser				  = 0;
	LET pCanal				  = 0;
	LET vCta				  = '';
	LET Vsdo				  = 0;
	LET vNombre				  = '';
		
	
  BEGIN

   ON EXCEPTION SET iSql_err
	  IF iSql_err <> 0 THEN
			LET cCod_ret = iSql_err;
		   RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, dFecUltAcceso,vIdUsuario, vCanal,vCtaAso,vNombre,Vsdo,dSdoActCap, nCtaCap, nCtaCred;
	  END IF ;
   END EXCEPTION ;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT id_usuario, a.num_cliente, 
	a.estatus_servicio,a.fecha_ulti_acceso,	cuenta
	INTO vIdUsuario,cNumCliente, sIdStatus, dFecUltAcceso, vCtaAso
	FROM bdibpi:"informix".bpi_registro_bex a WHERE a.no_celular = pNumCel AND a.estatus_servicio <> '2';
	
	IF dFecUltAcceso IS NULL THEN
		LET dFecUltAcceso=substring (current::varchar(23) from 1 for 19);
	ELSE
		LET dFecUltAcceso= substring (dFecUltAcceso::varchar(23)from 1 for 19);
	END IF;
	
	
	/*SELECT id_usuario, a.num_cliente, a.estatus_servicio,
	CASE WHEN a.fecha_ulti_acceso IS NULL THEN substring (current::varchar(23) from 1 for 19)
	ELSE substring (a.fecha_ulti_acceso::varchar(23)from 1 for 19)
	END fecha_ulti_acceso, cuenta
	INTO vIdUsuario,cNumCliente, sIdStatus, dFecUltAcceso, vCtaAso
	FROM bdibpi:"informix".bpi_registro_bex a WHERE a.no_celular = pNumCel AND a.estatus_servicio <> '2';
	*/
	--Consulta si existe una sesion en otro canal de banca por internet
	SELECT COUNT(canal) INTO pCanal FROM  bpi_doblesesion WHERE numcliente = cNumCliente;
	
	IF pCanal = 1 THEN
		SELECT canal INTO vCanal FROM  bpi_doblesesion WHERE numcliente = cNumCliente;
	END IF;

	IF vCanal = '' THEN 
		LET vCanal = '0';
	ELSE
		IF vCanal = 'PORTALBPI' THEN
			LET vCanal = '1';
		END IF;	
		IF vCanal = 'APPS' THEN
			LET vCanal = '2';
		END IF;	
		IF vCanal = 'BEX' THEN
			LET vCanal = '3';
		END IF;	
		--GM3.PDRH.- INI: Se agrega "vCanal = 4" para tener un cÃ³digo de retorno.
		IF vCanal = 'BMOVI' THEN
			LET vCanal = '4';
		END IF;	
		--GM3.PDRH.- FIN
	END IF;
	
	SELECT COUNT(no_celular) INTO pUser FROM bdibpi:bpi_registro_bex WHERE imei=pImei AND udid=pUdid AND no_celular=pNumCel AND servicio='activo';
	
	IF pUser = 0 THEN
		LET cCod_ret = '00003';
		RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, dFecUltAcceso,vIdUsuario, vCanal,vCtaAso,vNombre,Vsdo,dSdoActCap, nCtaCap, nCtaCred;
	END IF
	
	
	
	IF NVL(cNumCliente,'') != ''  THEN
	
		
		SELECT si.nombre1, si.nombre2, si.apell_paterno, si.apell_materno
		INTO cNombre1, cNombre2, cApellPaterno, cApellMaterno
		FROM bdinteg:"informix".si_cliente si WHERE si.numcte = cNumCliente;
	
		IF sIdStatus = '1' THEN
		
			SELECT numero_intentos INTO vIntentos FROM bdibpi:"informix".bpi_ctl_inicio_sesion_bex b  
			WHERE no_celular = pNumCel  AND id_usuario=vIdUsuario AND  DATE(fecha_inicio_acces) = TODAY;
	
			IF vIntentos = '2' THEN 
			
				UPDATE bdibpi:"informix".bpi_registro_bex SET estatus_servicio = '3', fecha_modificada = CURRENT WHERE no_celular=pNumCel  AND estatus_servicio = '1';
				LET cCod_ret = '00001';
				RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, dFecUltAcceso,vIdUsuario, vCanal,vCtaAso,vNombre,Vsdo,dSdoActCap, nCtaCap, nCtaCred;
			END IF;
			
		--ACTUALIZA ULTIMO ACCESO en bpi_usuario
			IF NVL(vIdUsuario, '') <> '' THEN
				UPDATE bdibpi:"informix".bpi_registro_bex SET fecha_ulti_acceso = CURRENT 
				WHERE id_usuario=vIdUsuario AND num_cliente = cNumCliente AND no_celular = pNumCel AND estatus_servicio = '1';
				LET cCod_ret = '00000';  -- Sesion iniciada
			END IF;
		END IF;			
			
		IF sIdStatus = '3' THEN

			LET cCod_ret = '00001'; --Usuario Bloqueado por numero de intentos
		
		END IF;	
	
	ELSE
		LET cCod_ret = '00002';  -- Usuario invalido
	END IF ;
	
	IF cCod_ret = '00000' THEN
	--IFRS Se contemplan los nuevos estatus por etapas 
	--SELECT COUNT(num_credito) INTO nCtaCred FROM bdicred:sd_maecred WHERE status_cred IN('AA','BA','BT','VP') AND numcte=cNumCliente;
		SELECT COUNT(num_credito) INTO nCtaCred FROM bdicred:sd_maecred WHERE status_cred IN('AA','BA','BT','VP','E1','E2','E3') AND numcte=cNumCliente;

	SELECT COUNT(cuenta) INTO nCtaCap FROM bdicheq:sc_maechq WHERE status_cta not in ('2') AND num_cte=cNumCliente;
	
		LET vLogCta=LENGTH(vCtaAso);
		
		IF vLogCta = 11 THEN 
			
			SELECT mc.cuenta, (mc.sdo_actual-mc.sdo_retenido-mc.sdo_cong-mc.imp_chq_sbg) as sdo
				INTO  vCta, Vsdo  
				FROM bdicheq:"informix".sc_maechq as mc, bdicheq:"informix".sc_producto as pr
				WHERE mc.cuenta = vCtaAso
				AND mc.status_cta not in ('2')
				AND pr.empresa = mc.empresa 
				AND pr.producto = mc.producto;


			SELECT pr.nombre
			INTO vNombre
				FROM bdicheq:"informix".sc_maechq as mc, bdicheq:"informix".sc_producto AS pr
				WHERE mc.num_cte = cNumCliente
				AND mc.cuenta = vCtaAso
				AND mc.status_cta = '1'
				AND pr.empresa = mc.empresa 
				AND pr.producto = mc.producto
				AND mc.producto IN ('2000','1300','1400','1500','1800','1700','1900','2400','2500');
			

				
		END IF;
		
		IF vLogCta = 16 THEN 
			
			SELECT  num_credito INTO vCta 
			FROM bdicred:sd_tarjeta where num_tarjeta = vCtaAso;
			
			EXECUTE PROCEDURE bdicred:sp_consulta_saldos_general('001',vCta) INTO cCodRet, cMensajeRet, cNumCredito, cCodTipCred,dtFechaOrigen,dtFechaProxPago,dPagoMinimo,
				dtFechaUltPago,iPlazo, iPagosRealizados, dLineaOtorgada,dTasaInteres, dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans,dCapVdoExig,dCapVdoNoExig,dSdoActCap,
				dIntVig,dIntVdo,dIntMoratorio,dIntMes,dSdoActInt,dIvaIntVig,dIvaIntVdo,dIvaIntMoratorio,dIvaIntMes,dSdoActIvaInt,dComPend,dIvaCom,dSdoRetenido,dSdoTotalLiq,
				dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,cDescStatusCred,iIdUnidadProd,cDescBloqueoCta,cCodCaract2,cDescCausaBloqueoCta,cSitCte,cCausaCte,
				cDescSitEspCte,cSitCred,cCausaCred,cDescSitEspCred;
			--IFRS Se contemplan los nuevos estatus por etapas 
			SELECT df.nombre_prod
			INTO vNombre 
				FROM bdicred:"informix".sd_maecred mc
				--join bdicred:"informix".sd_tarjeta tr on (tr.empresa = '001' and mc.num_credito = tr.num_credito and tipo_tarjeta = 'T' and mc.status_cred in ('AA','BA','BT') and secuencia = (select max(secuencia) from bdicred:"informix".sd_tarjeta where empresa = '001' and mc.num_credito = num_credito and tipo_tarjeta = 'T'))
				join bdicred:"informix".sd_tarjeta tr on (tr.empresa = '001' and mc.num_credito = tr.num_credito and tipo_tarjeta = 'T' and mc.status_cred in ('AA','BA','BT','E1','E2','E3') and secuencia = (select max(secuencia) from bdicred:"informix".sd_tarjeta where empresa = '001' and mc.num_credito = num_credito and tipo_tarjeta = 'T'))
				join bdicred:"informix".sd_definicion df on (df.num_producto = mc.num_producto)
				WHERE mc.numcte = cNumCliente 
				AND tr.num_tarjeta = vCtaAso
				AND mc.num_producto IN ('6600','7000','8100','6001');
			
		END IF;
			
	END IF;
		
  RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, dFecUltAcceso,vIdUsuario, vCanal,vCtaAso,vNombre,Vsdo,dSdoActCap, nCtaCap, nCtaCred;

END
END PROCEDURE;