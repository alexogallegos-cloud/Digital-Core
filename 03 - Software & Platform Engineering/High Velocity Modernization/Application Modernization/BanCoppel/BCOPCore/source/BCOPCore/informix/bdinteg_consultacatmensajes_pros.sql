CREATE PROCEDURE "informix".consultacatmensajes_pros
(
	iTipoConsulta	INTEGER,
	iTipoProceso	INTEGER,	
	sAuxiliar3		CHAR(20)  --Auxiliar3 Numcte
)

RETURNING	CHAR(5)		AS retorno,
			SMALLINT	AS nummensaje,
			SMALLINT	AS secuenciamensaje,
			CHAR(100)	AS mensaje;


--DEFINICION DE VARIABLES
DEFINE cCodRet					CHAR(5);
DEFINE i16NumMensaje			SMALLINT;
DEFINE i16Secuencia				SMALLINT;
DEFINE cDescripcion				CHAR(100);
DEFINE cDescripcionproductos	CHAR(100);
DEFINE cDescripcionproductosAT	CHAR(100);
DEFINE cDescripcionproductosRT	CHAR(100);
DEFINE cDescripcionproductosTRA	CHAR(100);

DEFINE vsqlerr 				INTEGER;
DEFINE i16Causa             SMALLINT;
DEFINE i16EvaluacionScore   DECIMAL(5,2);
DEFINE cEstatusSolicitud    CHAR(2);
DEFINE cEstatusNuevo        CHAR(2);
DEFINE siValorMaximo        SMALLINT ;
DEFINE siNumRegistros       SMALLINT ;
DEFINE sExiste              SMALLINT;
DEFINE cStatusSol           CHAR(2);
DEFINE iMensaje             INTEGER;
DEFINE iSolAuto             INTEGER; 
DEFINE iSolRt               INTEGER; 
DEFINE iSolTramite          INTEGER;
DEFINE cNumprod             CHAR(4);
DEFINE cNombre_prod         CHAR(40);
DEFINE cTp_solicitud		CHAR(1);
DEFINE nCuentas_aper        INTEGER;
DEFINE cCteProsp			CHAR(20);
DEFINE dFechaRespOSCalle	DATE;
DEFINE cClave				CHAR(1);
DEFINE iDiasTrans			INTEGER;
DEFINE siDiasVigencia		SMALLINT;

--INICIALIZACION DE VARIABLES
LET cCodRet                 = '1';
LET i16NumMensaje           = 0;
LET i16Secuencia            = 0;
LET cDescripcion            = '';
LET cDescripcionproductos   = '';
LET cDescripcionproductosAT = '';
LET cDescripcionproductosRT	= '';
LET cDescripcionproductosTRA = '';
LET i16Causa                = 0;
LET i16EvaluacionScore      = 0;
LET cEstatusSolicitud       = '';
LET cEstatusNuevo           = '';
LET siValorMaximo           = 0;
LET siNumRegistros          = 0;
LET sExiste                 = 0;
LET cStatusSol              = "";
LET iMensaje                = 0;
LET iSolAuto                = 0;
LET iSolRt                  = 0;
LET iSolTramite             = 0;
LET cNumprod               	= "";
LET cNombre_prod            = "";
LET cTp_solicitud           = "";
LET nCuentas_aper 			= 0;
LET cCteProsp				= '';
LET dFechaRespOSCalle		= MDY(1,1,1900);
LET cClave					= '';
LET iDiasTrans				= 0;
LET siDiasVigencia			= 0;

--SET DEBUG FILE TO "/tmp/consultacatmensajesmaestro.out";
--TRACE ON;

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

	LET sExiste = 0;

	IF (iTipoConsulta >= 1) AND (iTipoProceso >= 1) THEN

		IF iTipoConsulta = 2 AND iTipoProceso = 1 THEN

			CREATE TEMP TABLE tmp_mensajes
			(
				empresa CHAR(3),
				nummensaje INTEGER,
				productos CHAR(100)
			);		

			FOREACH
				SELECT status_solicitud, num_producto, tipo_solicitud INTO cStatusSol, cNumprod, cTp_solicitud
				FROM bdisolic:"informix".ss_solicitudes WHERE empresa = "001" AND numcte = sAuxiliar3   

				IF cNumprod = '6500' THEN 
					SELECT descripcion INTO cNombre_prod
					FROM bdisolic:"informix".ss_tp_solicitud WHERE tp_solicitud = cTp_solicitud;
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

				IF cStatusSol IN ("EA","EE","CC","OA","OS","BC","ST","CE","MC","EC","PA") THEN--JMAH RQM 09 279
					LET iSolTramite = 1;
					IF cDescripcionproductosTRA <> "" THEN
						LET cDescripcionproductosTRA = TRIM(cDescripcionproductosTRA)||',';	
					END IF;
					LET cDescripcionproductosTRA = TRIM(cDescripcionproductosTRA)||TRIM(cNombre_prod);
				END IF;
			END FOREACH;

			{SELECT COUNT(SolAut),COUNT(SolRt), COUNT(SolTramite)
			INTO iSolAuto, iSolRt, iSolTramite
			FROM TABLE (MULTISET (
				SELECT 
					CASE WHEN status_solicitud = "AT" THEN status_solicitud END AS SolAut,
					CASE WHEN status_solicitud = "RT" THEN status_solicitud END AS SolRt,
					CASE WHEN status_solicitud IN ("EA","EE","CC","OA","OS","BC","ST","CE","EC","PA") THEN status_solicitud END AS SolTramite --RQM 18 023
				FROM bdisolic:"informix".ss_solicitudes
				WHERE empresa = "001"
				AND numcte = sAuxiliar3));}      

			IF iSolAuto > 0 THEN
				INSERT INTO tmp_mensajes VALUES ("001",12,cDescripcionproductosAT);          
			END IF;

			IF iSolRt > 0 THEN
				INSERT INTO tmp_mensajes VALUES ("001",11,cDescripcionproductosRT);          
			END IF;

			IF iSolTramite > 0 THEN
				INSERT INTO tmp_mensajes VALUES ("001",10,cDescripcionproductosTRA);
			END IF;
			
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
					SELECT MAX(fecha_hoy) - MIN(dFechaRespOSCalle) INTO iDiasTrans FROM "informix".si_fechas;
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
							FROM "informix".si_catmensajesmaestro
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
	END IF  --Es del Principal

	--Esta validacion es porque cuando entra en algun ForEach ya esta arrojando los registros y
	--despues de salir del ciclo For venia y ejecutaba este Return y volvia a mandar el ultimo registro del Select.
	IF cCodRet <> '2' THEN
		RETURN cCodRet, i16NumMensaje, i16Secuencia, cDescripcion;
	END IF;
END;
END PROCEDURE
DOCUMENT
'MODIFICO: CONCEPCION ALVAREZ CARRILLO',
'FECHA: Julio/2016',
'BD: BDINTEG',
'DESCRIPCION: Validaciones para mostrar mensaje.';

CREATE PROCEDURE "informix".sp_consbco_dirtel( pEmpresa CHAR(3), pNumCte CHAR(20), pTipoDir SMALLINT )
RETURNING CHAR(5),      -- CODIGO DE RETORNO
          CHAR(20),     -- NO. CLIENTE
          CHAR(2),      -- ESTADO
          SMALLINT,     -- NUMERO CIUDAD
          CHAR(5),      -- DELEGACION
          INTEGER,      -- COLONIA
          INTEGER,      -- CALLE
          CHAR(10),     -- NUM EXTERIOR
          CHAR(10),     -- NUM INTERIOR
          CHAR(6),      -- DEPARTAMENTO
          CHAR(5),      -- CODIGO POSTAL
          CHAR(1),      -- PUNTO CARDINAL
          SMALLINT,     -- MANZANA
          SMALLINT,     -- OTROS
          SMALLINT,     -- ANDADOR
          SMALLINT,     -- ETAPA
          SMALLINT,     -- EDIFICIO
          SMALLINT,     -- ENTRADA
          SMALLINT,     -- LOTE
          CHAR(80),     -- OBSERVACIONES
          CHAR(40),     -- ENTRE CALLES
          CHAR(13),     -- TELEFONO CASA
          CHAR(13),     -- TELEFONO CELULAR
          SMALLINT,     -- CARRIER
          CHAR(13),     -- TELEFONO TRABAJO
          CHAR(5),      -- EXTENSION TRABAJO
          CHAR(3),      -- CIUDAD
          CHAR(1);      -- UNIDAD HABITACIONAL
          
    DEFINE viSqlErr         INTEGER;
    DEFINE viIsamErr        INTEGER;
    DEFINE vcDescErr        CHAR(50);
    DEFINE vcCodRet         CHAR(5);
    DEFINE vcCodRet2        CHAR(5);
    DEFINE vcCodRet3        CHAR(50);
    
    DEFINE vcNumPros        CHAR(20);
    DEFINE vcEstado         CHAR(2);
    DEFINE viCiudad         SMALLINT;
    DEFINE vcMunicipio      CHAR(5);
    DEFINE viColonia        INTEGER;
    DEFINE viCalle          INTEGER;
    DEFINE vcNumExt         CHAR(10);
    DEFINE vcNumInt         CHAR(10);
    DEFINE vcDepto          CHAR(6);
    DEFINE vcCodPos         CHAR(5);
    DEFINE vcPuntoCard      CHAR(1);
    DEFINE viManzana        SMALLINT;
    DEFINE viOtros          SMALLINT;
    DEFINE viAndador        SMALLINT;
    DEFINE viEtapa          SMALLINT;
    DEFINE viEdificio       SMALLINT;
    DEFINE viEntrada        SMALLINT;
    DEFINE viLote           SMALLINT;
    DEFINE vcObservaciones  CHAR(80);
    DEFINE vcEntreCalles    CHAR(40);
    DEFINE vcTelCasa        CHAR(13);
    DEFINE vcTelCelular     CHAR(13);
    DEFINE viCarrier        SMALLINT;
    DEFINE vcTelTrabajo     CHAR(13);
    DEFINE vcExtTrabajo     CHAR(5);
    DEFINE vcCiudad         CHAR(3);
    DEFINE vcUnidadHab      CHAR(1);
    
    LET viSqlErr       = 0;
    LET viIsamErr      = 0;
    LET vcDescErr      = 0;
    LET vcCodRet       = '00000';
    LET vcCodRet2      = '';
    LET vcCodRet3      = '';
    
    LET vcNumPros       = '';
    LET vcEstado        = ''; 
    LET viCiudad        = 0; 
    LET vcMunicipio     = ''; 
    LET viColonia       = 0; 
    LET viCalle         = 0; 
    LET vcNumExt        = ''; 
    LET vcNumInt        = ''; 
    LET vcDepto         = ''; 
    LET vcCodPos        = ''; 
    LET vcPuntoCard     = ''; 
    LET viManzana       = 0;  
    LET viOtros         = 0;  
    LET viAndador       = 0;  
    LET viEtapa         = 0;  
    LET viEdificio      = 0;  
    LET viEntrada       = 0;  
    LET viLote          = 0;  
    LET vcObservaciones = '';
    LET vcEntreCalles   = ''; 
    LET vcTelCasa       = ''; 
    LET vcTelCelular    = ''; 
    LET viCarrier       = 0;  
    LET vcTelTrabajo    = '';
    LET vcExtTrabajo    = '';
    LET vcCiudad        = '';
    LET vcUnidadHab     = '';

    --- SET DEBUG FILE TO "/tmp/sp_conspros_dirtel.out";
    --- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        --SET DEBUG FILE TO "/tmp/sp_conspros_dirtel.err";
        --TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet  = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            LET vcNumPros  = '';
            RETURN vcCodRet, vcNumPros, vcEstado, viCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos, vcPuntoCard, viManzana, viOtros, viAndador, 
                   viEtapa, viEdificio, viEntrada, viLote, vcObservaciones, vcEntreCalles, vcTelCasa, vcTelCelular, viCarrier, vcTelTrabajo, vcExtTrabajo, vcCiudad, vcUnidadHab;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pEmpresa is null OR pEmpresa = '' ) OR ( pNumCte  is null OR pNumCte = '' ) OR ( pTipoDir is null OR pTipoDir = 0 ) THEN
        LET vcCodRet = '00110';
        LET vcNumPros = '';
        RETURN vcCodRet, vcNumPros, vcEstado, viCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos, vcPuntoCard, viManzana, viOtros, viAndador, 
               viEtapa, viEdificio, viEntrada, viLote, vcObservaciones, vcEntreCalles, vcTelCasa, vcTelCelular, viCarrier, vcTelTrabajo, vcExtTrabajo, vcCiudad, vcUnidadHab;
    END IF;
    
    SELECT numcte
      INTO vcNumPros
      FROM si_cliente
     WHERE numcte = pNumCte;
     
    IF vcNumPros is null OR vcNumPros = '' OR vcNumPros <> pNumCte THEN
        LET vcCodRet = '00110';
        LET vcNumPros = '';
        RETURN vcCodRet, vcNumPros, vcEstado, viCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos, vcPuntoCard, viManzana, viOtros, viAndador, 
               viEtapa, viEdificio, viEntrada, viLote, vcObservaciones, vcEntreCalles, vcTelCasa, vcTelCelular, viCarrier, vcTelTrabajo, vcExtTrabajo, vcCiudad, vcUnidadHab;
    END IF;
    
    SELECT estado, numerociudad, municipio, numerocolonia, numerocalle, numeroextcalle, numerointcalle, departamento, cod_postal, 
           puntocardinal, manzana, otros, andador, etapa, edificio, entrada, lote, observaciones, entre_calles, ciudad, unidadhabitac
      INTO vcEstado, viCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos, 
           vcPuntoCard, viManzana, viOtros, viAndador, viEtapa, viEdificio, viEntrada, viLote, vcObservaciones, vcEntreCalles, vcCiudad, vcUnidadHab
      FROM si_direcciones_actual 
     WHERE numcte = vcNumPros
       AND tipo_dir = pTipoDir;
       --AND secuencia = (SELECT MAX(secuencia) FROM pr_direcciones WHERE numcte_pros = vcNumPros AND tipo_dir = pTipoDir);
	   
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET vcCodRet = '00111';	--El Cliente No tiene direccion en la tabla pr_direcciones
		RETURN vcCodRet, vcNumPros, vcEstado, viCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos, vcPuntoCard, viManzana, viOtros, viAndador, 
               viEtapa, viEdificio, viEntrada, viLote, vcObservaciones, vcEntreCalles, vcTelCasa, vcTelCelular, viCarrier, vcTelTrabajo, vcExtTrabajo, vcCiudad, vcUnidadHab;
	END IF;
     
    SELECT telefono
      INTO vcTelCasa
      FROM si_telefonos  
     WHERE numcte = vcNumPros
       AND tipo_tel = 1
       AND status_tel = 'A'
       AND secuencia = ( SELECT MAX(secuencia) FROM si_telefonos WHERE numcte = vcNumPros AND tipo_tel = 1 );
       
    SELECT telefono, carrier
      INTO vcTelCelular, viCarrier
      FROM si_telefonos  
     WHERE numcte = vcNumPros
       AND tipo_tel = 2
       AND status_tel = 'A'
       AND secuencia = ( SELECT MAX(secuencia) FROM si_telefonos WHERE numcte = vcNumPros AND tipo_tel = 2 );
    
    SELECT telefono, extension
      INTO vcTelTrabajo, vcExtTrabajo
      FROM si_telefonos  
     WHERE numcte = vcNumPros
       AND tipo_tel = 3
       AND status_tel = 'A'
       AND secuencia = ( SELECT MAX(secuencia) FROM si_telefonos WHERE numcte = vcNumPros AND tipo_tel = 3 );
    
    RETURN vcCodRet, nvl(vcNumPros,''), nvl(vcEstado,''), nvl(viCiudad,0), nvl(vcMunicipio,''), nvl(viColonia,0), nvl(viCalle,0), nvl(vcNumExt,''), nvl(vcNumInt,''), nvl(vcDepto,''), 
		nvl(vcCodPos,''), nvl(vcPuntoCard,''), nvl(viManzana,0), nvl(viOtros,0), nvl(viAndador,0), nvl(viEtapa,0), nvl(viEdificio,0), nvl(viEntrada,''), nvl(viLote,0), 
		nvl(vcObservaciones,''), nvl(vcEntreCalles,''), nvl(vcTelCasa,''), nvl(vcTelCelular,''), nvl(viCarrier,0), nvl(vcTelTrabajo,''), nvl(vcExtTrabajo,''), nvl(vcCiudad,''), 
		nvl(vcUnidadHab,'');
    
    END;
    
END PROCEDURE;