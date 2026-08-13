CREATE PROCEDURE "informix".consultacatmensajesmaestro2
(
	iTipoConsulta	INTEGER,
	iTipoProceso	INTEGER,
	sAuxiliar1		CHAR(20), --Auxiliar1 sSituacionEspecial - sNumero_Solicitud - sPuntualidad - Comprobante domicilio digitalizado tipoconsulta = 2
	sAuxiliar2		CHAR(20), --Auxiliar2 sCausa
	sAuxiliar3		CHAR(20)  --Auxiliar3 Numcte
)

RETURNING	CHAR(5)		AS retorno,
			SMALLINT	AS nummensaje,
			SMALLINT	AS secuenciamensaje,
			CHAR(100)	AS mensaje;

-- Variables de REGRESO del type de la funcion en Postgres
-- (codret int4,
-- nummensaje int2,
-- secuencia int2,
-- descripcion text);

--DOCUMENTACION
-----------------------------------------------------------------------------------------------------------------------------------------
--Mensaje para Clientes Z de acuerdo al RQM 10 031
--Modifico: Iris Arias
--Fecha: 08/11/2008
-----------------------------------------------------------------------------------------------------------------------------------------
--ModificÃÂ³: Viridiana Osobampo.
--ModificaciÃÂ³n: Se descarta la validaciÃÂ³n de la eficiencia del cliente y se genera
--              registro en la bitÃÂ¡cora de precalificaciÃÂ³n cuando un cte presenta
--              situaciÃÂ³n especial con motivo de rechazo.
--PeticiÃÂ³n: RQM 10 108 PrÃÂ©stamo Personal.
--Fecha: 15-09-09.
-----------------------------------------------------------------------------------------------------------------------------------------
--ModificÃÂ³: Viridiana Osobampo.
--ModificaciÃÂ³n: Se modifica para insertar solo un registro en las situaciones especiales: U,F,P,Y.
--              y para no mostrar el mensaje de eficiencia, por ultimo se modifica para contemplar
--              mas informaciÃÂ³n en la bitacora.
--PeticiÃÂ³n: RQM 10 108 PrÃÂ©stamo Personal.
--Fecha: 25-09-09.
-----------------------------------------------------------------------------------------------------------------------------------------
--ModificÃÂ³: Viridiana Osobampo.
--ModificaciÃÂ³n: Se agregan validaciones para un tipo de consulta y proceso distintos a los actuales.
--PeticiÃÂ³n: Alta Ã?nica paso 04
--Fecha: 23-06-10.
-----------------------------------------------------------------------------------------------------------------------------------------
--ModificÃÂ³: JesÃÂºs Manuel Aguilar Heredia
--ModificaciÃÂ³n: Se agregan y eliminan algunas causas para algunos tipos de consultas, 
--PeticiÃÂ³n: Alta Ã?nica paso 04
--Fecha: 09-12-10.
-----------------------------------------------------------------------------------------------------------------------------------------
--ModificÃÂ³: JesÃÂºs Manuel Aguilar Heredia
--ModificaciÃÂ³n: Se modifica para que no se muestre mensaje  ala situacion especial M
--PeticiÃÂ³n: Alta Ã?nica paso 04 , observiaciones en pruebas
--Fecha: 11-01-11.
-----------------------------------------------------------------------------------------------------------------------------------------
--ModificÃÂ³: JesÃÂºs Manuel Aguilar Heredia
--ModificaciÃÂ³n: Se modifica para  se muestre mensaje de productos en tramite coppel
--PeticiÃÂ³n: Alta Ã?nica paso 05 , observiaciones en pruebas
--Fecha: 08-07-11.
-----------------------------------------------------------------------------------------------------------------------------------------
--ModificÃÂ³: JesÃÂºs Manuel Aguilar Heredia
--ModificaciÃÂ³n: Se modifica para mostrar mensaje informativo cuando el cliente cuente con 5 o mÃÂ¡s prestamos personales activos
--PeticiÃÂ³n: RQM 09 306
--Fecha: 12-11-2012
-----------------------------------------------------------------------------------------------------------------------------------------
--ModificÃÂ³: Carlos Aguirre Vega
--DescripciÃÂ³n: Se agrega status EC - "Evaluacion Coppel" en las consultas de solicitudes
--Peticion: RQM 18 023 - EstatusSolicitudCoppelEC
--Fecha de modificaciÃÂ³n: 22-04-2013
-----------------------------------------------------------------------------------------------------------------------------------------
--ModificÃÂ³: Marco Beltran
--DescripciÃÂ³n: Se modifica mensaje informativo cuando el cliente cuente con rechazo
--Peticion: RQM 18 077 - Cambios para optimizar el proceso de alta unica
--Fecha de modificaciÃÂ³n: 10-10-2015
--DEFINICION DE VARIABLES
DEFINE cCodRet					CHAR(5);
DEFINE i16NumMensaje			SMALLINT;
DEFINE i16Secuencia				SMALLINT;
DEFINE cDescripcion				CHAR(100);
DEFINE cDescripcionproductos	CHAR(100);
DEFINE cDescripcionproductosAT	CHAR(100);
DEFINE cDescripcionproductosRT	CHAR(100);
DEFINE cDescripcionproductosTRA	CHAR(100);
DEFINE cDescripcionproductosAP	CHAR(100);

DEFINE vsqlerr 		INTEGER;
DEFINE siBandera	SMALLINT;

--Estas variables son para el tipo de proceso numero 2, cuando iTipoProceso = 2
--Se usan para la pantalla Asignacion de Tarjeta de Credito (APERTC)
DEFINE i16Causa             SMALLINT;
DEFINE i16EvaluacionScore   DECIMAL(5,2);
DEFINE cEstatusSolicitud    CHAR(2);
DEFINE cEstatusNuevo        CHAR(2);
DEFINE siValorMaximo        SMALLINT ;
DEFINE siNumRegistros       SMALLINT ;
DEFINE siBanderaCirculo     SMALLINT ;
DEFINE cNombreCte           CHAR(104);
DEFINE cMotivo              CHAR(1);
DEFINE cTpoRechazo          CHAR(1);
DEFINE cMensaje             CHAR(50);
DEFINE cRechazo             CHAR(1);
DEFINE dtFechahoy           DATE;
DEFINE cEmpresa             CHAR(3);
DEFINE cNumRef              CHAR(20);
DEFINE cBitacora            CHAR(1);
DEFINE cSucursal            CHAR(4);
DEFINE sExiste              SMALLINT;
DEFINE iEdadMin             INTEGER; 
DEFINE iEdadMax             INTEGER;
DEFINE cnomcte              CHAR(104);
DEFINE sedadcte             SMALLINT;
DEFINE cStatusSol           CHAR(2);
DEFINE iMensaje             INTEGER;
DEFINE iSolAuto             INTEGER; 
DEFINE iSolRt               INTEGER; 
DEFINE iSolAp               INTEGER; 
DEFINE iSolTramite          INTEGER;
DEFINE iSolAperPP         	INTEGER;
DEFINE cCausasol            CHAR(3);
DEFINE cNumprod             CHAR(4);
DEFINE cNombre_prod         CHAR(40);
DEFINE cMotivorechazo 		CHAR(1);
DEFINE iNumMensaje			INTEGER;
DEFINE cTp_solicitud		CHAR(1);
DEFINE iProdActPP			INTEGER;
DEFINE iPrestamosActivos	INTEGER;
DEFINE nCuentas_aper        INTEGER;
-- BCPL Cliente Prospecto Tipo 3
DEFINE cCteProsp			CHAR(20);
DEFINE dFechaRespOSCalle	DATE;
DEFINE cClave				CHAR(1);
DEFINE iDiasTrans			INTEGER;
DEFINE siDiasVigencia		SMALLINT;

DEFINE cRFC					CHAR(13);
DEFINE cCodigoRet 			CHAR(6);
DEFINE cFechaUltimoPago 	CHAR(13); 
DEFINE cPrestamoAutorizado 	CHAR(1); 
DEFINE iMontoAutorizado 	INT8; 
DEFINE iReprestamo 			INT8; 
--RQI 23 559
DEFINE ssDiasVigencia		INTEGER;
DEFINE dtFechaInsert       	DATE;
DEFINE iDiasTransApertura	INTEGER;
DEFINE cNumSolicitud 		CHAR(20);

DEFINE cB_ife            CHAR(1); --420
DEFINE cB_valida_ife     CHAR(1); --420
DEFINE FechaInePendiente  datetime year to fraction(3);
DEFINE FechaBitacoraIfe   datetime year to fraction(3);

--INICIALIZACION DE VARIABLES
LET cCodRet                 = '1';
LET i16NumMensaje           = 0;
LET i16Secuencia            = 0;
LET cDescripcion            = '';
LET cDescripcionproductos   = '';
LET cDescripcionproductosAT = '';
LET cDescripcionproductosRT	= '';
LET cDescripcionproductosTRA = '';
LET cDescripcionproductosAP = '';
LET i16Causa                = 0;
LET i16EvaluacionScore      = 0;
LET cEstatusSolicitud       = '';
LET cEstatusNuevo           = '';
LET siBandera               = 0;
LET siValorMaximo           = 0;
LET siNumRegistros          = 0;
LET siBanderaCirculo        = 0;
LET cNombreCte              = "";
LET cMotivo                 = "";
LET cTpoRechazo             = "";
LET cMensaje                = "";
LET cRechazo                = "0";
LET dtFechahoy              = DATE(1);
LET cEmpresa                = "";
LET cNumRef                 = "";
LET cBitacora               = "0";
LET cSucursal               = "";
LET sExiste                 = 0;
LET iEdadMin                = 0; 
LET iEdadMax                = 0;
LET cnomcte                 = "";
LET sedadcte                = 0;
LET cStatusSol              = "";
LET iMensaje                = 0;
LET iSolAuto                = 0;
LET iSolRt                  = 0;
LET iSolAp                  = 0;
LET iSolTramite             = 0;
LET iSolAperPP             	= 0;
LET cCausasol               = "";
LET cNumprod               	= "";
LET cNombre_prod            = "";
LET cMotivorechazo          = "";
LET iNumMensaje             = 0;
LET cTp_solicitud           = "";
LET iProdActPP           	= 0;
LET iPrestamosActivos       = 0;
LET nCuentas_aper 			= 0;
-- BCPL Cliente Prospecto Tipo 3
LET cCteProsp				= '';
LET dFechaRespOSCalle		= MDY(1,1,1900);
LET cClave					= '';
LET iDiasTrans				= 0;
LET siDiasVigencia			= 0;
--RQI 23 559
LET ssDiasVigencia			= 0;
LET dtFechaInsert			= '';
LET iDiasTransApertura		= 0;
LET cNumSolicitud			= '';

LET cB_ife                   =''; --420
LET cB_valida_ife            =''; --420

LET FechaInePendiente		 ='' ;
LET FechaBitacoraIfe  		 ='';


--SET DEBUG FILE TO "/tmp/consultacatmensajesmaestro.out";
--TRACE ON;

LET cRFC =""; 
LET cCodigoRet ="";
LET cFechaUltimoPago =""; 
LET cPrestamoAutorizado =""; 
LET iMontoAutorizado ="";
LET iReprestamo ="";
BEGIN
	ON EXCEPTION SET vsqlerr
		IF vsqlerr != 0 THEN
			LET cCodRet = vsqlerr;
			SELECT COUNT(tabname) INTO sExiste FROM systables WHERE tabname = "tmp_mensajes";
			IF sExiste > 0 THEN
				DROP TABLE tmp_mensajes;
			END IF;
			RETURN cCodRet, i16NumMensaje, i16Secuencia, cDescripcion;
		END IF ;
	END EXCEPTION ;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT COUNT(tabname) INTO sExiste FROM systables WHERE tabname = "tmp_mensajes";

	IF sExiste > 0 THEN
		DROP TABLE tmp_mensajes;
	END IF;

	SELECT valor INTO iPrestamosActivos FROM bdisolic:"informix".ss_param WHERE secuencia = '365' AND empresa = '001';

	LET sExiste = 0;

	IF (iTipoConsulta >= 1) AND (iTipoProceso >= 1) THEN

		IF iTipoConsulta = 2 AND iTipoProceso = 1 THEN

			CREATE TEMP TABLE tmp_mensajes
			(
				empresa CHAR(3),
				nummensaje INTEGER,
				productos CHAR(100)
			);

			--420			
			SELECT COUNT(numcte) INTO sExiste FROM bdinteg:"informix".si_ctepf WHERE numcte = sAuxiliar3 AND  codidentifi IN ('A','B');		
			
			IF sExiste > 0 THEN
				-- Extrae bandera de validacaiÃÂ³n de IFE
				SELECT nvl(valor,'')
				INTO cB_valida_ife
				FROM bdisolic:"informix".ss_param
				WHERE empresa = '001'
				AND secuencia = 376;
				
				
				
				SELECT MAX(fecha_insert) INTO FechaInePendiente FROM bdinteg:"informix".si_consulta_ine_pendiente WHERE numcte = sAuxiliar3;
				SELECT MAX(fecha) INTO FechaBitacoraIfe FROM bdinteg:"informix".si_bitacora_ife WHERE numcte = sAuxiliar3;
				
				
				IF FechaBitacoraIfe > FechaInePendiente THEN

					-- Valida IFE/INE
					IF (cB_valida_ife = '1') THEN
						select nvl(case when upper(resultado) = 'VERDADERO' then '1' else '0' end,'1')
						into cB_ife
						from bdinteg:"informix".si_bitacora_ife 
						where numcte = sAuxiliar3 and fecha = (select max(fecha) from bdinteg:"informix".si_bitacora_ife where numcte = sAuxiliar3);

						IF ( cB_ife <> '1') THEN
							INSERT INTO tmp_mensajes VALUES ("001",14,'');
						END IF;
					END IF;
				
				END IF; 
				
				
			END IF;
			
			LET sExiste = 0;
			--420
			

			IF sAuxiliar1 = "1" THEN -- Se envÃÂ­a 1 cuando el cliente no tiene comprobante de domicilio digitalizado en sucursal
				/*SELECT LIMIT 1 1 INTO sExiste
				FROM bdidigital@coppelimg_tcp:"informix".dg_expediente
				WHERE empresa = "001" AND cliente = sAuxiliar3
				AND cod_docto IN("0012","0015","0016","0017","0018","0031","0032","0033");
				
				IF sExiste = 1 THEN*/
					INSERT INTO tmp_mensajes VALUES ("001",1,'');
				--END IF;
				
			END IF;

			EXECUTE PROCEDURE "informix".consedadcte("001", sAuxiliar3)
				INTO cCodRet, cnomcte, sedadcte;						   

			SELECT NVL(edad_min,0), NVL(edad_max,0) INTO iEdadMin, iEdadMax
			FROM bdicred:"informix".sd_definicion WHERE num_producto = "6001";

			IF NVL(sedadcte,0) < iEdadMin THEN
				INSERT INTO tmp_mensajes VALUES ("001",2,'');
			END IF;

			IF NVL(sedadcte,0) > iEdadMax THEN
				INSERT INTO tmp_mensajes VALUES ("001",5,'');
			END IF;
			
			--RQI 23 559 Obtiene los dÃÂ­as de vigencia
			SELECT valor::INTEGER INTO ssDiasVigencia 
			FROM bdisolic:"informix".ss_param 
			WHERE empresa= '001' AND secuencia = '25';

			FOREACH
				--RQI 23 559
				--SELECT status_solicitud, num_producto, tipo_solicitud INTO cStatusSol, cNumprod, cTp_solicitud
				--FROM bdisolic:"informix".ss_solicitudes WHERE empresa = "001" AND numcte = sAuxiliar3   
				
				SELECT num_solicitud,status_solicitud, num_producto, tipo_solicitud INTO cNumSolicitud,cStatusSol, cNumprod, cTp_solicitud
				FROM bdisolic:"informix".ss_solicitudes WHERE empresa = "001" AND numcte = sAuxiliar3   
				
				IF cNumprod = '6500' THEN 
					SELECT descripcion INTO cNombre_prod
					FROM bdisolic:"informix".ss_tp_solicitud WHERE tp_solicitud = cTp_solicitud;
				ELSE
					SELECT nombre_prod INTO cNombre_prod
					FROM bdicred:"informix".sd_definicion WHERE num_producto = cNumprod;
				END IF;	

				IF cStatusSol = "AT" THEN
					-- VALIDAR SITUACION DE LA TDC INI
					SELECT COUNT(*) INTO nCuentas_aper
					FROM bdicred:"informix".sd_maecred
					WHERE empresa = "001" AND numcte = sAuxiliar3 AND status_cred <> 'FF';
					-- VALIDAR SITUACION DE LA TDC FIN
					IF ncuentas_aper > 0 THEN
						LET iSolAuto = 1;						
						IF cDescripcionproductosAT <> "" THEN
							LET cDescripcionproductosAT = TRIM(cDescripcionproductosAT)||',';	
						END IF;
						LET cDescripcionproductosAT = TRIM(cDescripcionproductosAT)||TRIM(cNombre_prod);
					END IF;
				END IF;

				IF cStatusSol = "RT" THEN
					LET iSolRt = 1;
					IF cDescripcionproductosRT <> "" THEN
						LET cDescripcionproductosRT = TRIM(cDescripcionproductosRT)||',';	
					END IF;
					LET cDescripcionproductosRT = TRIM(cDescripcionproductosRT)||TRIM(cNombre_prod);
				END IF;

				IF cStatusSol IN ("EA","EE","CC","OA","OS","BC","ST","CE","MC","EC","PA","IN") THEN--JMAH RQM 09 279
					LET iSolTramite = 1;
					IF cDescripcionproductosTRA <> "" THEN
						LET cDescripcionproductosTRA = TRIM(cDescripcionproductosTRA)||',';	
					END IF;
					LET cDescripcionproductosTRA = TRIM(cDescripcionproductosTRA)||TRIM(cNombre_prod);
				END IF;

				IF cStatusSol = "AP" AND cNumprod <> '6500' AND cNumprod <> '7800' THEN
					SELECT LIMIT 1 fecha_insert 
					INTO dtFechaInsert
					FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud = cNumSolicitud
					AND status_solicitud = 'AP';
					--ORDER BY fecha_insert DESC;
					
					SELECT fecha_hoy INTO dtFechahoy
					FROM bdinteg:"informix".si_fechas;
					--WHERE empresa = pEmpresa;

					--Calculamos los dÃÂ­as que tiene la solcitud en estatus AP.
					LET iDiasTransApertura = dtFechahoy - dtFechaInsert;

					--Si la soliclitud tiene 90 dÃÂ­as o menos, no se ofertarÃÂ¡ ningÃÂºn crÃÂ©dito de banco, excepto la TDC Coppel.
					IF iDiasTransApertura <= ssDiasVigencia THEN
						LET iSolAp = 1;
						IF cDescripcionproductosAP <> "" THEN
							LET cDescripcionproductosAP = TRIM(cDescripcionproductosAP)||',';	
						END IF;
						LET cDescripcionproductosAP = TRIM(cDescripcionproductosAP)||TRIM(cNombre_prod);
					END IF;
				END IF;
			END FOREACH;

			{SELECT COUNT(SolAut),COUNT(SolRt), COUNT(SolTramite)
			INTO iSolAuto, iSolRt, iSolTramite
			FROM TABLE (MULTISET (
				SELECT 
					CASE WHEN status_solicitud = "AT" THEN status_solicitud END AS SolAut,
					CASE WHEN status_solicitud = "RT" THEN status_solicitud END AS SolRt,
					CASE WHEN status_solicitud IN ("EA","EE","CC","OA","OS","BC","ST","CE","EC","PA","IN") THEN status_solicitud END AS SolTramite --RQM 18 023
                    CASE WHEN status_solicitud = "AP" THEN status_solicitud END AS SolAp,
				FROM bdisolic:"informix".ss_solicitudes
				WHERE empresa = "001"
				AND numcte = sAuxiliar3));}      

			IF iSolAuto > 0 THEN
				INSERT INTO tmp_mensajes VALUES ("001",3,cDescripcionproductosAT);          
			END IF;

			IF iSolRt > 0 THEN
				INSERT INTO tmp_mensajes VALUES ("001",6,cDescripcionproductosRT);          
			END IF;

			IF iSolTramite > 0 THEN
				INSERT INTO tmp_mensajes VALUES ("001",4,cDescripcionproductosTRA);
			END IF;

			IF iSolAp > 0 THEN
				INSERT INTO tmp_mensajes VALUES ("001",15,cDescripcionproductosAP);          
			END IF;
			
			-- AAME 20150303 RQM 10 550 Se agregan nuevos productos de prestamo, considerando que se limitarÃÂ¡n al numero de prestamos activos que puede tener el cliente sobre prestamo personal actual (6300)  
			--JMAH				
			--AAME RQM 10 1177 Se agrega modificaciÃ³n para contemplar los productos de prÃ©stamos existentes y nuevos correspondientes a familia 002 y 003
			SELECT COUNT(num_credito) INTO iProdActPP
			FROM bdicred:"informix".sd_maecredcrd
			WHERE empresa = '001' AND numcte = sAuxiliar3 
			AND num_producto IN (SELECT num_producto FROM bdicred:"informix".sd_definicion WHERE familia IN('002','003')) AND status_cred IN ('AA','BA','BT','E1','E2','E3');
			--IFRS Se modifica el estatus de crÃ©dito por Etapas
			--AND num_producto IN (SELECT num_producto FROM bdicred:"informix".sd_definicion WHERE familia IN('002','003')) AND status_cred IN ('AA','BA','BT');
			--AND num_producto IN ('6300','7600','7700','6800','7100') AND status_cred IN ('AA','BA','BT');

			IF iProdActPP >= iPrestamosActivos THEN
				INSERT INTO tmp_mensajes VALUES ("001",8,'');
			END IF;			
			--JMAH

			FOREACH
				SELECT nummensaje, NVL(productos,'')
				INTO iMensaje, cDescripcionproductos
				FROM tmp_mensajes
				ORDER BY nummensaje

				FOREACH
					SELECT nummensaje, secuencia, descripcion
					INTO i16NumMensaje, i16Secuencia, cDescripcion
					FROM "informix".si_catmensajesmaestro
					WHERE tipoconsulta = iTipoConsulta AND tipoproceso = iTipoProceso
					AND nummensaje = iMensaje AND flaguso = 1
					ORDER BY secuencia 

					LET cCodRet = '2';

					RETURN cCodRet, i16NumMensaje, i16Secuencia, cDescripcion WITH RESUME;
				END FOREACH;        

				IF cDescripcionproductos <> '' THEN
					RETURN cCodRet, i16NumMensaje, i16Secuencia+1, cDescripcionproductos WITH RESUME;	
				END IF;
			END FOREACH;

			-- BCPL Cliente Prospecto Tipo 3
			SELECT numcte_pros INTO cCteProsp FROM bdiprospectos:"informix".pr_cliente WHERE numcte = sAuxiliar3;
			IF NVL(cCteProsp,'') <> '' THEN
				SELECT fecharespuesta, clave INTO dFechaRespOSCalle, cClave
				FROM bdisolic:"informix".ss_osclientesupervisar WHERE num_solicitud = cCteProsp
				AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar WHERE num_solicitud = cCteProsp);

				IF NVL(cClave,'') = 'R' THEN
					SELECT MAX(fecha_hoy) - MIN(dFechaRespOSCalle) INTO iDiasTrans FROM bdinteg:"informix".si_fechas;
					FOREACH
						SELECT clave_producto INTO cNumprod FROM bdisolic:"informix".ss_oscalle_vigencia WHERE vigrespos_oferta = 1

						SELECT dias_vigencia INTO siDiasVigencia FROM bdisolic:"informix".ss_oscalle_plazovigencia 
						WHERE clave_producto = cNumprod AND resp_oscalle = cClave;

						IF NVL(iDiasTrans,0) <= NVL(siDiasVigencia,0) THEN
							SELECT nombre_prod INTO cNombre_prod FROM bdicred:"informix".sd_definicion WHERE num_producto = cNumprod;

							LET siNumRegistros = siNumRegistros + 1;

							INSERT INTO tmp_mensajes VALUES ("001",siNumRegistros,TRIM(cNombre_prod));
						END IF;
					END FOREACH;

					IF NVL(siNumRegistros,0) > 0 THEN
						FOREACH
							SELECT nummensaje, secuencia, descripcion 
							INTO i16NumMensaje, i16Secuencia, cDescripcion
							FROM bdinteg:"informix".si_catmensajesmaestro
							WHERE tipoconsulta = iTipoConsulta AND tipoproceso = iTipoProceso 
							AND nummensaje = 9 AND flaguso = 1
							ORDER BY secuencia 

							LET cCodRet = '2';

							RETURN cCodRet, i16NumMensaje, i16Secuencia, cDescripcion WITH RESUME;
						END FOREACH;
						FOREACH
							SELECT nummensaje, NVL(productos,'')
							INTO iMensaje, cDescripcionproductos
							FROM tmp_mensajes
							ORDER BY nummensaje

							RETURN cCodRet, i16NumMensaje, i16Secuencia+iMensaje, cDescripcionproductos WITH RESUME;
						END FOREACH;
					END IF;
				END IF;
			END IF;

			DROP TABLE tmp_mensajes;
		END IF;
	-- *************************************
	-- EM  25/05/2017 Consulta RFC *
	-- *************************************

		SELECT RFC
			INTO cRFC
		FROM bdinteg:"informix".si_cliente
		WHERE numcte = sAuxiliar3;
			
		IF cRFC <> "" THEN

			EXECUTE PROCEDURE bdisolic:"informix".sp_valida_cliente_coppel('3','',cRFC,'','','','','','','','','','','','','','','','','','','','','')
			INTO cCodigoRet, cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo;
		ELSE
			LET cFechaUltimoPago = '1900-01-01';
			LET cPrestamoAutorizado = '0';
			LET iMontoAutorizado = '0';
			LET iRePrestamo = '0';
			LET cCodigoRet = '000000';
		END IF;
		IF sAuxiliar1 <> 'M' THEN
			IF (iTipoConsulta = 1 AND iTipoProceso = 1) THEN

				IF sAuxiliar2 IN (9,10,18,19,22,33,51,41,16,83,85,86,87,88,89,90,91,92,93,94,96,97,98) THEN  --sCausa , se agregan las causas 83,85,86,87,88,89,90,91,92,93,94,96,97,98 rqm ajustes alta unica paso4
					LET i16NumMensaje = 1;  -- se quitan causas (8,11,24,36,40,53,54,71) a peticion RQM 09 214
					LET siBandera = 1;
					ELIF sAuxiliar2 IN (20,21,31,46,49,72) THEN --se eliminan las causas 8,9,10,11,18,19,22,24,33,36,  51, 53, 54, 71 y se agregan al mensaje 1 de la consulta 1 y proceso 1
					LET i16NumMensaje = 2; -- se quitan causas (14,28,39,47,55) a peticion RQM 09 214
					LET siBandera = 1;
					ELIF sAuxiliar2 IN (7) THEN --(1,2,4,5,15,6)se quitan a peticion de RQM 09 172  (1,2,4,5,6,7,15,50) 
					LET i16NumMensaje = 3; -- se quita causa (50) a peticion RQM 09 214
					LET siBandera = 1;
					ELIF sAuxiliar2 IN (42) THEN
					LET i16NumMensaje = 5;
					LET siBandera = 1;
					ELIF sAuxiliar2 IN (3,58,59,60) THEN
					LET i16NumMensaje = 6;
					LET siBandera = 1;
					ELIF sAuxiliar2 = 0  and sAuxiliar1 = 'Q' THEN
					LET i16NumMensaje = 9;
					LET siBandera = 1;
				END IF;
				-- se consulta a la tabla de puntualidad para identificar si es una puntualidad lo que recibio en el parametro sAuxiliar1.
				IF EXISTS (SELECT puntualidad FROM bdicred:"informix".sd_puntualidad WHERE empresa ='001' AND puntualidad = sAuxiliar1) THEN  --sPuntualidad
					SELECT motivo_rechazo_sol,nummensaje INTO cMotivorechazo, iNumMensaje
					FROM bdicred:"informix".sd_puntualidad	
					WHERE empresa ='001' AND puntualidad = sAuxiliar1;

					IF cMotivorechazo = '1' THEN
						LET i16NumMensaje = iNumMensaje;
					END IF;
				END IF;

				IF siBandera=1 or cMotivorechazo = '1' THEN
					SELECT fecha_hoy INTO dtFechahoy
					FROM bdinteg:"informix".si_fechas;

					SELECT empresa, sucursal, TRIM(TRIM(nombre1)||" "|| TRIM(nombre2)||" "|| TRIM(apell_paterno)||" "|| TRIM(apell_materno)), NVL(TRIM(numcte_ref),"")
					INTO cEmpresa,cSucursal,cNombreCte,cNumRef
					FROM bdinteg:"informix".si_cliente
					WHERE empresa = '001' AND numcte = sAuxiliar3;

					IF NVL(cNumRef,'') = '' THEN
						LET cNumRef = sAuxiliar3;
					END IF;

					IF cMotivorechazo = '1' THEN
						LET cCausasol = "PCC";
						LET cCodRet = '00002';
						IF cEmpresa IS NOT NULL THEN
							INSERT INTO bdisolic:"informix".ss_bitacora_precal
							(empresa,fecha,sucursal,nombre,num_referencia,ejecutivo,situacion,causa,motivo,tipo_rechazo,codret,mensaje,causa_solicitud,puntualidad,fechaultimopago,prestamoautorizado,montoautorizado,represtamo)
								VALUES (cEmpresa,dtFechahoy,cSucursal,cNombreCte,cNumRef,USER,'',sAuxiliar2,cMotivo,cTpoRechazo,cCodRet,cMensaje,cCausasol,sAuxiliar1,cFechaUltimoPago, cPrestamoAutorizado,iMontoAutorizado,iRePrestamo);
						END IF;
					ELSE   
						SELECT motivo_rechazo_sol, tipo_rechazo,descripcion
						INTO cMotivo, cTpoRechazo, cMensaje
						FROM bdicred:sd_situacion_cred
						WHERE empresa = cEmpresa AND situacion = sAuxiliar1;

						IF cMotivo IS NULL THEN
							LET cMotivo ='0';
						END IF
						IF cTpoRechazo IS NULL THEN
							LET cTpoRechazo = '0';
						END IF;

						LET cCausasol = "SE";
						IF cMotivo = '1' OR cTpoRechazo = '1' THEN
							LET cCodRet = '00003';
							IF cEmpresa IS NOT NULL THEN
								INSERT INTO bdisolic:"informix".ss_bitacora_precal
								(empresa,fecha,sucursal,nombre,num_referencia,ejecutivo,situacion,causa,motivo,tipo_rechazo,codret,mensaje,causa_solicitud,fechaultimopago,prestamoautorizado,montoautorizado,represtamo)
									VALUES (cEmpresa,dtFechahoy,cSucursal,cNombreCte,cNumRef,USER,sAuxiliar1,sAuxiliar2,cMotivo,cTpoRechazo,cCodRet,cMensaje,cCausasol,cFechaUltimoPago, cPrestamoAutorizado,iMontoAutorizado,iRePrestamo);
							END IF;
						ELSE
							SELECT motivo_rechazo_sol, descripcion INTO cMotivo, cMensaje
							FROM bdicred:"informix".sd_causas_cte_coppel
							WHERE empresa = cEmpresa AND situacion = sAuxiliar1 AND causa = sAuxiliar2;
							LET cCodRet = '00004';

							IF cEmpresa IS NOT NULL THEN
								INSERT INTO bdisolic:"informix".ss_bitacora_precal
								(empresa,fecha,sucursal,nombre,num_referencia,ejecutivo,situacion,causa,motivo,tipo_rechazo,codret,mensaje,causa_solicitud,fechaultimopago,prestamoautorizado,montoautorizado,represtamo)
									VALUES (cEmpresa,dtFechahoy,cSucursal,cNombreCte,cNumRef,USER,sAuxiliar1,sAuxiliar2,cMotivo,cTpoRechazo,cCodRet,cMensaje,cCausasol,cFechaUltimoPago, cPrestamoAutorizado,iMontoAutorizado,iRePrestamo);
							END IF;
						END IF;
					END IF;
				END IF;

				FOREACH
					SELECT nummensaje, secuencia, descripcion 
					INTO i16NumMensaje, i16Secuencia, cDescripcion
					FROM bdinteg:"informix".si_catmensajesmaestro
					WHERE tipoconsulta = iTipoConsulta AND tipoproceso = iTipoProceso
					AND nummensaje = i16NumMensaje AND flaguso = 1
					ORDER BY secuencia 

					LET cCodRet = '2';
					RETURN cCodRet, i16NumMensaje, i16Secuencia, cDescripcion WITH RESUME;
				END FOREACH;

			ELIF (iTipoConsulta = 1) AND (iTipoProceso = 2) Then     --ESTO ES PARA LA PANTALLA DE ASIGNACION DE TARJETA DE CREDITO
				--Para el Circulo de CrÃÂ©dito, en base al tipo de estatus
				--If cStatusSolicitud In ("DS", "FD", "FR", "IR", "MD", "PL", "PS", "SP", "VR", "RO") Then
					--LET i16NumMensaje = 1;
				--End IF
				--Para el Circulo de CrÃÂ©dito, en base a estas validaciones   sAuxiliar1 = ''600000035250' '
				SELECT COUNT(solic.num_solicitud) INTO siNumRegistros
				FROM bdisolic:"informix".ss_solicitudes AS solic, bdisolic:"informix".ss_autorizacion AS aut
				WHERE solic.num_solicitud = sAuxiliar1 AND aut.num_solicitud = sAuxiliar1
				AND solic.status_solicitud = "RT" AND aut.status_solicitud = "RT"
				AND aut.comentario = "Evaluacion en Circulo de Credito Negativa, Solicitud No Aprobada"
				AND NOT EXISTS (SELECT esp.num_solicitud
								FROM bdisolic:"informix".ss_autorizacion_especial AS esp
								WHERE esp.num_solicitud = sAuxiliar1);

				IF siNumRegistros > 0 THEN     --Si Existe
					LET i16NumMensaje = 1;
					LET siBanderaCirculo = 1;
				END IF

				IF siBanderaCirculo = 0 THEN  --Esto es porque no encotro en num_solicitud en la cosulta anterior
					SELECT sol.causasituacionespecial, res.evaluacion, solic.status_solicitud
					INTO i16Causa, i16EvaluacionScore, cEstatusSolicitud
					FROM bdisolic:"informix".ss_solicitud_os AS sol,
						bdisolic:"informix".ss_resumen_scoring AS res,
						bdisolic:"informix".ss_solicitudes AS solic
					WHERE sol.num_solicitud = sAuxiliar1 
					AND res.num_solicitud = sAuxiliar1
					AND solic.num_solicitud = sAuxiliar1;        --sAuxiliar1 = NumeroReferencia

					--Para los Rechazos del CAC y el Score < 60  puntos
					IF (cEstatusSolicitud = "RT") AND (i16Causa NOT IN (1, 2, 4, 5, 6, 7, 15, 103)) THEN
						SELECT NVL(MAX(secuencia),0) INTO siValorMaximo   ---Esto es del CAC
						FROM bdisolic:"informix".ss_autorizacion_especial
						WHERE num_solicitud = sAuxiliar1;

						IF siValorMaximo > 0 THEN
							SELECT status_nvo INTO cEstatusNuevo
							FROM bdisolic:"informix".ss_autorizacion_especial
							WHERE num_solicitud = sAuxiliar1 -- sAuxiliar1 = NumeroReferencia
							AND secuencia = siValorMaximo;
						END IF

						IF cEstatusNuevo IS NULL THEN
							LET cEstatusNuevo = "XX";
						END IF
					END IF

					--Para la Causa
					IF i16Causa IN (1, 2, 4, 5, 6, 7, 15, 103) THEN
						LET i16NumMensaje = 2;
					END IF

					IF (i16EvaluacionScore < 60) OR (cEstatusNuevo = "RT") THEN
						LET i16NumMensaje = 3;
					END IF
				END IF  -- Este es del  siBanderaCirculo = 0

				FOREACH
					SELECT nummensaje, secuencia, descripcion
					INTO i16NumMensaje, i16Secuencia, cDescripcion
					FROM bdinteg:"informix".si_catmensajesmaestro
					WHERE tipoconsulta = iTipoConsulta  AND tipoproceso = iTipoProceso 
					AND nummensaje = i16NumMensaje AND flaguso = 1
					ORDER BY secuencia ASC

					LET cCodRet = '2';
					RETURN cCodRet, i16NumMensaje, i16Secuencia, cDescripcion WITH RESUME;
				END FOREACH;
			END IF
		/*/		Se comenta este codigo para que no se muestre ningun mensaje cuando se reciba una M en el parametro sAuxiliar1
		ELSE
			FOREACH                                                                  
				SELECT nummensaje, secuencia, descripcion
				INTO i16NumMensaje, i16Secuencia, cDescripcion
				FROM bdinteg:"informix".si_catmensajesmaestro
				WHERE tipoconsulta = iTipoConsulta AND tipoproceso = iTipoProceso
				AND nummensaje = sAuxiliar2 AND flaguso = 1
				Order by secuencia 

				LET cCodRet = '2';
				RETURN cCodRet, i16NumMensaje, i16Secuencia, cDescripcion WITH RESUME;
			END FOREACH;/*/
		END IF
	END IF  --Es del Principal

	--Esta validacion es porque cuando entra en algun ForEach ya esta arrojando los registros y
	--despues de salir del ciclo For venia y ejecutaba este Return y volvia a mandar el ultimo registro del Select.
	IF cCodRet <> '2' THEN
		RETURN cCodRet, i16NumMensaje, i16Secuencia, cDescripcion;
	END IF;
END;
END PROCEDURE
DOCUMENT
'MODIFICO: ANTONIO CEBREROS PEREZ.',
'FECHA: 10/04/2015',
'BD: BDINTEG',
'DESCRIPCION: Se agrega filtro de busqueda en consulta a cliente prospecto tipo 3.',
'FECHA: 14/05/2015',
'SOLICITO: ANGELES PEREZ.',
'DESCRIPCION: SOLICITO ANGELEZ PEREZ BORRAR EL CAMPO O FILTRO EL ESTADO = 1 DE LA CONSULTA A LA TABLA PR_CLIENTE.',
'FECHA: 09/06/2015',
'DESCRIPCION: SE CAMBIÃ? VALIDACIÃ?N PARA MOSTRAR MENSAJE.',
'MODIFICO: CAROLINA VERDUGO.',
'FECHA: 17/12/2015',
'BD: BDINTEG',
'DESCRIPCION: Agregar mensaje 9 de la tabla si_catmensajesmaestro para mostrarse desde componente soltarcr.exe al realizar la primera pre calificaciÃÂ³n del cliente, .',
'----------------------------------------------------------------------------',
'Descripcion : Se modifica para que se guarden los campos cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo en la tabla ss_bitacora_precal',
'Modifico    : 95451706 - Efrain Miranda',
'Fecha       : 29/05/2017',
'BD          : Badinteg',
'----------------------------------------------------------------------------',
'Descripcion : Se Realizo homologaciÃÂ³n Folio 230-Productivo',
'Modifico    : 97839523 - Jose Luis Garcia',
'Fecha       : 22/07/2017',
'BD          : Badinteg',
'----------------------------------------------------------------------------',
'Descripcion : Se realiza HomologaciÃÂ³n Prestamo Personal para clientes A',
'Modifico    : 95992243 - Trinidad Hernandez',
'Folio		 : 449',
'Fecha       : 17/07/2018',
'BD          : Badinteg';

CREATE PROCEDURE "informix".sp_busca_producto_cred_cliente(p_sNumeroCliente CHAR(20), p_skip INT)

     RETURNING	CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta;

	--definicion de variables--	    
    DEFINE resultado_numeroProducto CHAR(6);
	DEFINE resultado_nombreProducto 	CHAR(60);
	DEFINE resultado_numeroCuenta           CHAR(30);
	DEFINE resultado_numeroTarjeta          CHAR(30);
	DEFINE iSqlErr                          INTEGER;
	
     -- InicializaciÃÂ³n de las variables.
     LET resultado_numeroProducto ='';
	LET resultado_nombreProducto = '';
	LET resultado_numeroCuenta = '';
	LET resultado_numeroTarjeta = '';

    SET ISOLATION TO DIRTY READ;
			
	BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto = '';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_numeroTarjeta = '';
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta;
            END IF;
        END EXCEPTION;

		FOREACH
			SELECT SKIP p_skip DISTINCT bdicred:sd_maecred.num_producto as numeroProducto, nombre_prod AS nombreProducto, num_credito AS cuentaProducto, numtarjeta AS tarjetaProducto
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta
			FROM bdicred:sd_maecred 
                LEFT JOIN bdicred:sd_definicion ON (bdicred:sd_maecred.empresa = bdicred:sd_definicion.empresa and bdicred:sd_maecred.num_producto = bdicred:sd_definicion.num_producto) 
                LEFT JOIN intercard:tarjetacuenta ON (bdicred:sd_maecred.num_credito = intercard:tarjetacuenta.numcuenta)
            WHERE bdicred:sd_maecred.numcte = p_sNumeroCliente 
            AND bdicred:sd_maecred.status_cred IN ('AA','BA','BT','E1','E2','E3') -- Solo tomar en cuenta crÃ©ditos con los estatus 
			--IFRS Se contemplan los nuevos estatus por Etapas			
            --AND bdicred:sd_maecred.status_cred IN ('AA','BA','BT') -- Solo tomar en cuenta crÃ©ditos con los estatus 
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta WITH RESUME;
		END FOREACH;
	END
END PROCEDURE;