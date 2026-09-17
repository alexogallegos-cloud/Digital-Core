CREATE PROCEDURE "informix".sp_grabadetallearchivotdcoro(pCredito CHAR(20) ,
pNumTar CHAR(20) ,
pproducto CHAR(4),
pTipotar CHAR(3),
pNombre CHAR(107),
pError CHAR(1),
pMarcaje CHAR(3),
pSol_plastico CHAR(2),
pMsj_error CHAR(120),
pUsuario CHAR(8),
pNombreArchivo CHAR(35),
pFechaInsert DATE
)
RETURNING CHAR(6)         AS codigo_retorno,
          VARCHAR(100,1)  AS mensaje_retorno;

DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   VARCHAR(100,1);
DEFINE cTipoArchivo  CHAR(1);
DEFINE dFechaHoy     DATE;
DEFINE cmarcaje		 CHAR(3);
DEFINE csolplastico  CHAR(2);
DEFINE cerror		 CHAR(1);
DEFINE cmsj_error    VARCHAR(100,1);
DEFINE crptupgrade   CHAR(20);
--AAME RQM 10 682-4 Variables para obtener el nombre completo del cte
DEFINE cNumCte  CHAR(107);
DEFINE cnombre1 CHAR(26); 
DEFINE cnombre2 CHAR(26);
DEFINE capell_paterno CHAR(26);             
DEFINE capell_materno CHAR(26);
DEFINE cnumtarjeta CHAR(20);

LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '000000';
LET cMensajeRet   = 'Se realizó la consulta correctamente.';
LET cTipoArchivo  = ''; -- 1 Upgrade , 2  Reposicion
LET dFechaHoy     = DATE(1);
LET cmarcaje      = '';
LET csolplastico  = '';
LET cerror		  = '';
LET cmsj_error    = ''; -- 0 Exito, 1 Error, 3 Cancelar
LET crptupgrade   = '';
--AAME RQM 10 682-4 Variables para obtener el nombre completo del cte
LET cNumCte = '';
LET cnombre1 = ''; 
LET cnombre2 = '';
LET capell_paterno = '';               
LET capell_materno = '';
LET cnumtarjeta ='';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet;
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_grabadetallearchivotdc.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

IF NVL(pUsuario,'') = '' THEN
  LET cCodRet = '000001';
  LET cMensajeRet = 'El parámetro no es valido';
  RETURN cCodRet, cMensajeRet;
END IF;

SELECT fecha_hoy
INTO dFechaHoy
FROM "informix".sd_fechas;
	
IF NVL(pCredito,'') <> '' THEN
	--AAME RQM 10 682-4 Se agrega liga a la tabla bdinteg:si_cliente para extraer el nombre completo del cliente para la reportería

	IF NVL(pTipotar,'') = 'TIT' THEN
		SELECT limit 1 numcte
		INTO cNumCte
		FROM bdicred:"informix".sd_maecred 
		WHERE num_credito = pCredito;
		IF NVL(pNumTar,'') = '' THEN 
			SELECT num_tarjeta
			INTO cnumtarjeta
			FROM bdicred:"informix".sd_tarjeta 
			WHERE num_credito = pCredito AND tipo_tarjeta ='T' AND status_tar ='A';		
		ELSE
			LET cnumtarjeta = pNumTar;			
		END IF;
		
	ELIF NVL(pTipotar,'') = 'ADI' THEN
		SELECT limit 1 numcte,num_tarjeta
		INTO cNumCte, cnumtarjeta
		FROM bdicred:"informix".sd_tarjeta 
		WHERE num_credito = pCredito AND tipo_tarjeta ='A' AND status_tar ='A';	
		IF NVL(pNumTar,'') <> '' THEN 
			LET cnumtarjeta = pNumTar;
		END IF;
	END IF;

	SELECT nombre1, nombre2, apell_paterno, apell_materno 
	INTO cnombre1, cnombre2, capell_paterno, capell_materno
	FROM bdinteg:"informix".si_cliente
	WHERE numcte = cNumCte;
	
	LET pNombre = TRIM(NVL(cnombre1,'')) || " " || TRIM(NVL(cnombre2,'')) || " " || TRIM(NVL(capell_paterno,'')) || " " || TRIM(NVL(capell_materno,''));	
END IF; 

IF 	pError IN (0,1) THEN	
	--cTipoArchivo  1 Upgrade , 2  Reposicion		
	IF substr(pNombreArchivo,1,15) = 'CAMBIO_TDC_INN_' Then
		LET cTipoArchivo = '1';
		LET pMarcaje = 'NO';
		IF pError = '0' THEN			
			LET pSol_plastico = 'SI';
		ELSE
			LET pSol_plastico = 'NO';
		END IF;		
	ELSE
		LET cTipoArchivo = '1';

	END IF;
	
	LET pTipotar = substr(pTipotar,1,1);
	-- RQM 10 682-4 Se contempla la consulta a la tabla de Reportería de la información con los errores presentados al realizar la marca o solicitar plasticos
	SELECT limit 1 num_credito, error_proceso, marcaje, sol_plastico, mensaje_error
	INTO crptupgrade, cerror, cmarcaje, csolplastico,  cmsj_error
	FROM "informix".sd_rep_detallearchivotdc
	WHERE num_tarjeta = cnumtarjeta 
	AND nombre_archivo = pNombreArchivo;
	
	IF NVL(crptupgrade,'') = '' THEN	
		-- SE REGISTRA INFORMACIÓN EN LA TABLA DE REPORTERÍA
		INSERT INTO "informix".sd_rep_detallearchivotdc(num_credito,num_tarjeta,prod_destino,
		tipo_tarjeta,nombre,tipo_archivo,nombre_archivo,error_proceso, marcaje, sol_plastico,mensaje_error,usuario,fecha_insert)
		VALUES (pCredito ,pNumTar, pproducto, pTipotar, pNombre, cTipoArchivo, pNombreArchivo, pError, pMarcaje,
		pSol_plastico, pMsj_error, pUsuario, dFechaHoy);

	ELSE	
		IF cTipoArchivo ='1' AND cmarcaje = 'SI' AND  csolplastico = 'NO'   THEN
			IF pError = '0' THEN
				LET csolplastico = 'SI';
			ELSE 
				LET csolplastico = 'NO';
			END IF;
			/*IF NVL(pCredito,'') <> '' THEN
				UPDATE "informix".sd_rep_detallearchivotdc SET error_proceso = pError, marcaje = cmarcaje, sol_plastico = csolplastico, mensaje_error= pMsj_error 
				WHERE num_credito = pCredito 
				AND num_tarjeta = cnumtarjeta 
				AND nombre_archivo = pNombreArchivo;
			ELIF NVL(pNumTar,'') <> '' THEN*/
			UPDATE "informix".sd_rep_detallearchivotdc SET error_proceso = pError, marcaje = cmarcaje, sol_plastico = csolplastico, mensaje_error= pMsj_error 
			WHERE num_tarjeta = cnumtarjeta   
			AND nombre_archivo = pNombreArchivo;
			--END IF;
			
		ELIF cTipoArchivo ='2' THEN-- RQM 10 682-4 Se contempla solo para solicitud de plástico para reposición
				IF pError = '0' THEN
					LET csolplastico = 'SI';
				ELSE 
					LET csolplastico = 'NO';
				END IF;
				--IF NVL(pCredito,'') <> '' THEN
				UPDATE "informix".sd_rep_detallearchivotdc SET error_proceso = pError, marcaje = 'N/A', sol_plastico = csolplastico, mensaje_error= pMsj_error 
				WHERE num_tarjeta = cnumtarjeta 
				AND nombre_archivo = pNombreArchivo;
				/*ELIF NVL(pNumTar,'') <> '' THEN
					UPDATE "informix".sd_rep_detallearchivotdc SET error_proceso = pError, marcaje = 'N/A', sol_plastico = csolplastico, mensaje_error= pMsj_error 
					WHERE num_tarjeta = pNumTar  
					AND nombre_archivo = pNombreArchivo;					
				END IF;*/
		END IF;
	END IF;
 ELIF pError IN (3) THEN
		-- RQM 10 682-4 Se contempla la opción de error 3 para el borrado de Reportería de la información en caso de que el cliente cancele el procesar.
		DELETE
		FROM "informix".sd_rep_detallearchivotdc
		WHERE nombre_archivo = pNombreArchivo AND fecha_insert = pFechaInsert;
		
 END IF;
	
 RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para grabar la información de reportería referente a la solicitud del upgrade de producto y plásticos para reposición',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 12/02/2019',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 05/05/2021',
'DESCRIPCION: Se modifica para TDC Oro.',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_rep_prod_upgradeoro(pEmpresa CHAR(3),
pFechaIni DATE,
pFechaFin DATE,
pTipo CHAR(1),
pStatus CHAR(1),
pArchivo CHAR(50),
pRegistros INTEGER, 
pRecuperacion INTEGER
)
RETURNING CHAR(6)        AS codigo_retorno,
          VARCHAR(100,1) AS mensaje_retorno,
          VARCHAR(20,1)  AS num_credito,
		  VARCHAR(20,1)  AS num_tarjeta,		  
          VARCHAR(10,1)  AS tipo_tarjeta,
		  VARCHAR(100,1) AS nombre,
		  DATE 			 AS fecha,
          CHAR(15) 		 AS resultado,
		  CHAR(3)        AS marcaje,
		  CHAR(2)		 AS sol_plastico,
		  VARCHAR(100,1) AS mensaje_error;
		  		  
DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   VARCHAR(100,1);
DEFINE cEmpresa      CHAR(3);
DEFINE cNombre       CHAR(100);
DEFINE cNumCredito   CHAR(20);
DEFINE cTipo_Tarjeta  CHAR(10);
DEFINE cfecha		  DATE;
DEFINE cresultado     CHAR(15);
DEFINE cMarcaje 	  CHAR(3);
DEFINE cSolPlastico   CHAR(2);
DEFINE cMensajeError  VARCHAR(100,1);
DEFINE cNumTarjeta    CHAR(20);
DEFINE cTipoArchivo   CHAR(1);
DEFINE cnomarchivo	  CHAR(50);
--AAME 20190624 Se considera nva variable de tipo datetime para la busqueda en la tabla bdicred:sd_credito_upgrade para eliminar el casteo en consulta
DEFINE dtFechaIni 	DATETIME YEAR TO FRACTION;
DEFINE dtFechaFin 	DATETIME YEAR TO FRACTION;

LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '000000';
LET cMensajeRet   = 'Se realizó la consulta correctamente.';

LET cEmpresa      = '';
LET cNombre  = '';
LET cNumCredito = '';
LET cTipo_Tarjeta = '';
LET cfecha = date(1);
LET cresultado = '';
LET cNumTarjeta = '';
LET cMarcaje = '';
LET cSolPlastico = '';
LET cMensajeError = '';
LET cTipoArchivo = '';
LET cnomarchivo = '';
--AAME 20190624
LET dtFechaIni = pFechaIni::DATETIME YEAR TO FRACTION;
LET dtFechaFin = pFechaFin::DATETIME YEAR TO FRACTION;


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'');
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/mfinis/sp_rep_prod_upgrade2.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT empresa
INTO cEmpresa
FROM bdinteg:si_empresas
WHERE empresa= pEmpresa;

IF TRIM(NVL(cEmpresa,'')) = ''    THEN
  LET cCodRet = '000001';
  LET cMensajeRet = 'El parámetro no es valido';
  --RETURN cCodRet, cMensajeRet,"","","","","","";
  RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'');
END IF;

IF  pTipo = '1' then

	IF NVL(pArchivo,'') ='' THEN
		FOREACH WITH HOLD
		-- RQM 10 682-4 Se contempla la consulta a la tabla de Reportería de la información con los errores presentados la realizar la marca o solicitar plasticos
			SELECT SKIP pRegistros FIRST pRecuperacion distinct (nombre_archivo)
			INTO cNombre
			FROM "informix".sd_rep_detallearchivotdc
			WHERE fecha_insert BETWEEN pFechaIni and pFechaFin
		
			--RETURN cCodRet, cMensajeRet,cNombre,"","","","","" WITH resume;
			RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'') WITH resume;

		END FOREACH;
		-- RQM 10 682-4 Se consulta de la tabla de upgrade para los primeros casos en que se libere el cambio y la tabla de reportería no devuelva información de los archivos previos cargados
		IF NVL(cNombre,'') = '' THEN
			FOREACH WITH HOLD
				SELECT SKIP pRegistros FIRST pRecuperacion distinct (nombre_archivo)
				INTO cNombre
				FROM "informix".sd_credito_upgrade
				WHERE empresa = pEmpresa
				AND fecha_insert BETWEEN dtFechaIni and dtFechaFin
			
				--RETURN cCodRet, cMensajeRet,cNombre,"","","","","" WITH resume;
				RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'') WITH resume;

			END FOREACH;			
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			   LET cCodRet= '000002';
			   LET cMensajeRet= 'No existen archivos cargados en el periodo especificado';
			      --RETURN cCodRet, cMensajeRet,"","","","","","";
				  RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'');
			END IF;
			
		END IF;		
				
	ELSE

		FOREACH WITH HOLD
		-- RQM 10 682-4 Se contempla la consulta a la tabla de Reportería de la información con los errores presentados la realizar la marca o solicitar plasticos
			SELECT SKIP pRegistros FIRST pRecuperacion num_credito, num_tarjeta, tipo_tarjeta, nombre, fecha_insert, error_proceso,mensaje_error, tipo_archivo, marcaje 
			INTO  cNumCredito,cNumTarjeta,cTipo_Tarjeta,cNombre,cfecha,cresultado,cMensajeError,cTipoArchivo, cMarcaje
			FROM "informix".sd_rep_detallearchivotdc
			WHERE nombre_archivo = pArchivo
			AND fecha_insert BETWEEN pFechaIni and pFechaFin
			
			IF NVL(cTipo_Tarjeta,'') ='T' THEN
				LET cTipo_Tarjeta = 'TITULAR';
			ELIF NVL(cTipo_Tarjeta,'') ='A' THEN
				LET cTipo_Tarjeta = 'ADICIONAL';
			END IF;
			--cTipoArchivo  1 Upgrade , 2  Reposicion	
			IF NVL(cresultado,'') = '0' THEN
				LET cresultado = 'EXITOSO';
				IF cTipoArchivo = '1' THEN 
					LET cMarcaje = 'SI'; LET cSolPlastico ='SI';
				ELSE
					LET cMarcaje = 'N/A'; LET cSolPlastico ='SI';
				END IF;
				LET cMensajeError = '';
			ELSE
				LET cresultado = 'NO EXITOSO';

				IF NVL(cTipoArchivo,'') = '1' THEN 
					IF NVL(cMarcaje,'') = '' THEN
						LET cMarcaje = 'NO';
					END IF;				
					LET cSolPlastico ='NO';					
				ELSE
					LET cMarcaje = 'N/A'; LET cSolPlastico ='NO';
				END IF;			
				
			END IF;
			
			RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'') WITH resume;
			--RETURN cCodRet, cMensajeRet,cNombre,cNumCredito,cTipo_Tarjeta,cmiembro,cfecha,cresultado WITH resume;

		END FOREACH;
		-- RQM 10 682-4 Se consulta de la tabla de upgrade para los primeros casos en que se libere el cambio y la tabla de reportería no devuelva información de los archivos previos cargados
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			FOREACH WITH HOLD
				SELECT SKIP pRegistros FIRST pRecuperacion num_credito, numerotarjeta, tipoTar, --DECODE(tipoTar,'TIT','TITULAR','ADICIONAL'),
				nombre, fecha_insert, resultado,nombre_archivo--DECODE(Resultado,'0','EXITOSO','1','EXITOSO','NO EXITOSO')
				INTO  cNumCredito,cNumTarjeta,cTipo_Tarjeta,cNombre,cfecha,cresultado,cnomarchivo
				FROM "informix".sd_credito_upgrade
				WHERE empresa = pEmpresa
				AND fecha_insert BETWEEN dtFechaIni and dtFechaFin
				AND nombre_archivo = pArchivo
				
				IF NVL(cTipo_Tarjeta,'') ='TIT' THEN
					LET cTipo_Tarjeta = 'TITULAR';
				ELIF NVL(cTipo_Tarjeta,'') ='ADI' THEN
					LET cTipo_Tarjeta = 'ADICIONAL';
				END IF;				
				
				--Se valida el tipo de Archivo
				IF substr(cnomarchivo,1,16) ='CAMBIO_TDC_INN_' THEN
					LET cTipoArchivo = '2';
				ELSE
					LET cTipoArchivo = '1';
				END IF;
				IF NVL(cresultado,'') IN ('0','1') THEN
					LET cresultado = 'EXITOSO';
				
					IF cTipoArchivo = '1' THEN 
						LET cMarcaje = 'SI'; LET cSolPlastico ='SI';
					ELSE
						LET cMarcaje = 'N/A'; LET cSolPlastico ='SI';
					END IF;
					LET cMensajeError = '';					
				ELSE 
					LET cresultado = 'NO EXITOSO';
					IF NVL(cTipoArchivo,'') = '1' THEN 
						IF NVL(cnomarchivo,'') = '' THEN
							LET cMarcaje = 'NO';
						END IF;				
						LET cSolPlastico ='NO';
					ELSE
						LET cMarcaje = 'N/A'; LET cSolPlastico ='NO';
					END IF;		
				END IF;				

			RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'') WITH resume;
			
			END FOREACH;
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				   LET cCodRet= '000002';
				   LET cMensajeRet= 'No existe información del archivo en el periodo seleccionado';
				   --RETURN cCodRet, cMensajeRet,"","","","","","";
				   RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'');
			END IF;			
		END IF;	

	END IF;
ELIF pTipo = '2' THEN

	--AAME RQM 10 682-4 Valida que se contemple el tipo de estatus que seleccione el cliente para la busqueda 'TODOS'
	IF pStatus = '1' THEN
		FOREACH WITH HOLD
		-- RQM 10 682-4 Se contempla la consulta a la tabla de Reportería de la información con los errores presentados la realizar la marca o solicitar plasticos
			SELECT SKIP pRegistros FIRST pRecuperacion num_credito, num_tarjeta, tipo_tarjeta,--DECODE(tipoTar,'TIT','TITULAR','ADICIONAL'),
			nombre, fecha_insert, error_proceso,mensaje_error, tipo_archivo, marcaje --DECODE(Resultado,'0','EN PROCESO','1','OK','ERROR')
			INTO  cNumCredito,cNumTarjeta,cTipo_Tarjeta,cNombre,cfecha,cresultado,cMensajeError,cTipoArchivo, cMarcaje
			FROM "informix".sd_rep_detallearchivotdc
			WHERE fecha_insert BETWEEN pFechaIni and pFechaFin
			
			IF NVL(cTipo_Tarjeta,'') ='T' THEN
				LET cTipo_Tarjeta = 'TITULAR';
			ELIF NVL(cTipo_Tarjeta,'') ='ADI' THEN
				LET cTipo_Tarjeta = 'ADICIONAL';
			END IF;
			--cTipoArchivo  1 Upgrade , 2  Reposicion	
			IF NVL(cresultado,'') = '0' THEN
				LET cresultado = 'EXITOSO';
				IF cTipoArchivo = '1' THEN 
					LET cMarcaje = 'SI'; LET cSolPlastico ='SI';
				ELSE
					LET cMarcaje = 'N/A'; LET cSolPlastico ='SI';
				END IF;
				LET cMensajeError = '';
			ELSE
				LET cresultado = 'NO EXITOSO';
				IF NVL(cTipoArchivo,'') = '1' THEN 
					IF NVL(cMarcaje,'') = '' THEN
						LET cMarcaje = 'NO';
					END IF;		 
					LET cSolPlastico ='NO';
				ELSE
					LET cMarcaje = 'N/A'; LET cSolPlastico ='NO';
				END IF;			
				
			END IF;
			
			RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'') WITH resume;
			--RETURN cCodRet, cMensajeRet,cNombre,cNumCredito,cTipo_Tarjeta,cmiembro,cfecha,cresultado WITH resume;

		END FOREACH;
			
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		-- RQM 10 682-4 Se consulta de la tabla de upgrade para los primeros casos en que se libere el cambio y la tabla de reportería no devuelva información de los archivos previos cargados
			FOREACH WITH HOLD
				SELECT SKIP pRegistros FIRST pRecuperacion num_credito, numerotarjeta, tipoTar,--DECODE(tipoTar,'TIT','TITULAR','ADICIONAL'),
			    nombre, fecha_insert, Resultado,nombre_archivo--, tipo_archivo --DECODE(Resultado,'0','EN PROCESO','1','OK','ERROR')
			    INTO  cNumCredito,cNumTarjeta,cTipo_Tarjeta,cNombre,cfecha,cresultado,cnomarchivo--,cTipoArchivo
				FROM "informix".sd_credito_upgrade
				WHERE empresa = pEmpresa
				AND fecha_insert BETWEEN dtFechaIni and dtFechaFin
				AND tipo_proceso = 2
				
				IF NVL(cTipo_Tarjeta,'') ='TIT' THEN
					LET cTipo_Tarjeta = 'TITULAR';
				ELIF NVL(cTipo_Tarjeta,'') ='ADI' THEN
					LET cTipo_Tarjeta = 'ADICIONAL';
				END IF;		
				--Se valida el tipo de Archivo
				IF substr(cnomarchivo,1,16) ='CAMBIO_TDC_INN_' THEN
					LET cTipoArchivo = '2';
				ELSE
					LET cTipoArchivo = '1';
				END IF;
				IF NVL(cresultado,'') IN ('0','1') THEN
					LET cresultado = 'EXITOSO';
				
					IF cTipoArchivo = '1' THEN 
						LET cMarcaje = 'SI'; LET cSolPlastico ='SI';
					ELSE
						LET cMarcaje = 'N/A'; LET cSolPlastico ='SI';
					END IF;
					LET cMensajeError = '';					
				ELSE 
					LET cresultado = 'NO EXITOSO';
					IF NVL(cTipoArchivo,'') = '1' THEN 
						IF NVL(cnomarchivo,'') = '' THEN
							LET cMarcaje = 'NO';
						END IF;				
						LET cSolPlastico ='NO';
					ELSE
						LET cMarcaje = 'N/A'; LET cSolPlastico ='NO';
					END IF;		
				END IF;

			RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'') WITH resume;
			
			END FOREACH;
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				   LET cCodRet= '000002';
				   LET cMensajeRet= 'No existe información del archivo en el periodo seleccionado';
				   --RETURN cCodRet, cMensajeRet,"","","","","","";
				   RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'');
			END IF;		
		END IF;	
	ELSE --AAME RQM 10 682-4 Valida que se contemple el tipo de estatus que seleccione el cliente para la busqueda 
		IF pStatus = '2' THEN --EXITO
			LET pStatus = '0'; 
		ELIF pStatus = '3' THEN --NO EXITOSO
			LET pStatus = '1'; 
		END IF;
		FOREACH WITH HOLD
		-- RQM 10 682-4 Se contempla la consulta a la tabla de Reportería de la información con los errores presentados la realizar la marca o solicitar plasticos
			SELECT SKIP pRegistros FIRST pRecuperacion num_credito, num_tarjeta, tipo_tarjeta,--DECODE(tipoTar,'TIT','TITULAR','ADICIONAL'),
			nombre, fecha_insert, error_proceso,mensaje_error, tipo_archivo,marcaje --DECODE(Resultado,'0','EN PROCESO','1','OK','ERROR')
			INTO  cNumCredito,cNumTarjeta,cTipo_Tarjeta,cNombre,cfecha,cresultado,cMensajeError,cTipoArchivo,cMarcaje
			FROM "informix".sd_rep_detallearchivotdc
			WHERE error_proceso = pStatus
			AND fecha_insert BETWEEN pFechaIni and pFechaFin
			
			IF NVL(cTipo_Tarjeta,'') ='T' THEN
				LET cTipo_Tarjeta = 'TITULAR';
			ELIF NVL(cTipo_Tarjeta,'') ='A' THEN
				LET cTipo_Tarjeta = 'ADICIONAL';
			END IF;
			--cTipoArchivo  1 Upgrade , 2  Reposicion	
			IF NVL(cresultado,'') = '0' THEN
				LET cresultado = 'EXITOSO';
				IF cTipoArchivo = '1' THEN 
					LET cMarcaje = 'SI'; LET cSolPlastico ='SI';
				ELSE
					LET cMarcaje = 'N/A'; LET cSolPlastico ='SI';
				END IF;
				LET cMensajeError = '';
			ELSE
				LET cresultado = 'NO EXITOSO';
				IF NVL(cTipoArchivo,'') = '1' THEN 
					IF NVL(cMarcaje,'') = '' THEN
						LET cMarcaje = 'NO';
					END IF;		
					LET cSolPlastico ='NO';
				ELSE
					LET cMarcaje = 'N/A'; LET cSolPlastico ='NO';
				END IF;			
				
			END IF;
			
			RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'') WITH resume;
			--RETURN cCodRet, cMensajeRet,cNombre,cNumCredito,cTipo_Tarjeta,cmiembro,cfecha,cresultado WITH resume;

		END FOREACH;
			
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		-- RQM 10 682-4 Se consulta de la tabla de upgrade para los primeros casos en que se libere el cambio y la tabla de reportería no devuelva información de los archivos previos cargados
			FOREACH WITH HOLD
				SELECT SKIP pRegistros FIRST pRecuperacion num_credito, numerotarjeta, tipoTar,--DECODE(tipoTar,'TIT','TITULAR','ADICIONAL'),
			    nombre, fecha_insert, Resultado,nombre_archivo--, tipo_archivo --DECODE(Resultado,'0','EN PROCESO','1','OK','ERROR')
			    INTO  cNumCredito,cNumTarjeta,cTipo_Tarjeta,cNombre,cfecha,cresultado,cnomarchivo--,cTipoArchivo
				FROM "informix".sd_credito_upgrade
				WHERE empresa = pEmpresa
				AND fecha_insert BETWEEN dtFechaIni and dtFechaFin
				AND Resultado = pStatus
				AND tipo_proceso = 2
				
				IF NVL(cTipo_Tarjeta,'') ='TIT' THEN
					LET cTipo_Tarjeta = 'TITULAR';
				ELIF NVL(cTipo_Tarjeta,'') ='ADI' THEN
					LET cTipo_Tarjeta = 'ADICIONAL';
				END IF;		
				--Se valida el tipo de Archivo
				IF substr(cnomarchivo,1,16) ='CAMBIO_TDC_INN_' THEN
					LET cTipoArchivo = '2';
				ELSE
					LET cTipoArchivo = '1';
				END IF;
				IF NVL(cresultado,'') IN ('0','1') THEN
					LET cresultado = 'EXITOSO';
				
					IF cTipoArchivo = '1' THEN 
						LET cMarcaje = 'SI'; LET cSolPlastico ='SI';
					ELSE
						LET cMarcaje = 'N/A'; LET cSolPlastico ='SI';
					END IF;
					LET cMensajeError = '';					
				ELSE 
					LET cresultado = 'NO EXITOSO';
					IF NVL(cTipoArchivo,'') = '1' THEN 
						IF NVL(cnomarchivo,'') = '' THEN
							LET cMarcaje = 'NO';
						END IF;	
						LET cSolPlastico ='NO';
					ELSE
						LET cMarcaje = 'N/A'; LET cSolPlastico ='NO';
					END IF;		
				END IF;

			RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'') WITH resume;
			
			END FOREACH;
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				   LET cCodRet= '000002';
				   LET cMensajeRet= 'No existe información del archivo en el periodo seleccionado';
				   --RETURN cCodRet, cMensajeRet,"","","","","","";
				   RETURN cCodRet, cMensajeRet, NVL(cNumCredito,''), NVL(cNumTarjeta,''), NVL(cTipo_Tarjeta,''), NVL(cNombre,''), NVL(cfecha,DATE(1)), NVL(cresultado,''), NVL(cMarcaje,''), NVL(cSolPlastico,''), NVL(cMensajeError,'');
			END IF;		
		END IF;
	END IF;
		
END IF;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener información de reportería para de las solicitudes de marca de upgrade de un producto y de solicitud de plásticos personalizados',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 22/02/2016',
'AUTOR: L. Montserrat León Amador',
'FECHA 18/04/2017',
'DESCRIPCION: Se crea SPL clon para el tratado de la paginación.',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 29/04/2021',
'DESCRIPCION: Se modifica spl para TDC Oro',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_chi_ope_carga_sdos_com ()
	RETURNING CHAR(5) as codigo_retorno;

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	--Peticion: RQM 10 1404 - Hipotecario Infonavit
	--Creado por: 98769022 Miguel Alejandro Sánchez Mojica
	--Fecha de creación: 14/05/2021
	--Creación: Se realiza la carga de la información del archivo chi_ope_rep_sdos_com_aaaamm.txt
	--BD: bdicred
	-------------------------------------------------------------------------------------
	--Peticion: RQM 10 1404 - Hipotecario Infonavit
	--Modificado por: 98769022 Miguel Alejandro Sánchez Mojica
	--Fecha de modificación: 10/08/2021
	--Modificación: Se modifica las longitudes de la columna status_operativo de varchar(10) a varchar(20)
	--BD: bdicred
	-------------------------------------------------------------------------------------
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES ERROR                        *
-- ****************************************************************************
    DEFINE     	sql_err                 INTEGER;
    DEFINE     	isam_err                INTEGER;
    DEFINE     	cod_ret                 CHAR(5);
	DEFINE	   	mensaje_ret				VARCHAR(255);
	
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

	DEFINE 		v_empresa 						VARCHAR(3);
	DEFINE 		v_fecha_carga 					DATE;
	DEFINE 		v_producto 						VARCHAR(20);
	DEFINE 		v_periodo 						VARCHAR(10);
	DEFINE 		v_credito 						VARCHAR(20);
	DEFINE 		v_status_operativo 				VARCHAR(20);
	DEFINE 		v_fecha_cesion 					DATE;
	DEFINE 		v_fecha_firma 					DATE;
	DEFINE 		v_regimen 						VARCHAR(5);
	DEFINE 		v_status 						VARCHAR(5);
	DEFINE 		v_com_seguro_vida				DECIMAL(18,2);
	DEFINE		v_iva_com_seguro_vida 			DECIMAL(18,2);
	DEFINE		v_com_infonavit					DECIMAL(18,2);
	DEFINE		v_iva_com_infonavit				DECIMAL(18,2);
	DEFINE		v_com_hito 						DECIMAL(18,2);
	DEFINE		v_iva_com_hito					DECIMAL(18,2);
	DEFINE 		v_count_temp					INTEGER;		-- Variable para contar el número de registros en la tabla temporal y validar si existe información a cargar
	DEFINE 		v_cargar_info					INTEGER;		-- Variable para validar si se cargó información, 1 = Si hay información, 0 = No hay información
	DEFINE 		v_count_info					INTEGER;		-- Variable para validar si hay registros en la tabla de carga con la misma fecha (en caso de haber error en la ejecución anterior del día)
	DEFINE 		v_comienza_commit				INTEGER;		-- Variable para los commits parciales
	DEFINE 		v_suma_registros				INTEGER;		-- Variable para los commits parciales
	
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES RUTAS                        *
-- ****************************************************************************
	DEFINE 		cRuta				    CHAR(100);
	DEFINE 		cSQL                    CHAR(1000);
	DEFINE 		cNomSQL                 CHAR(100);
	DEFINE 		cDia					CHAR(2);
	DEFINE 		cMes					CHAR(2);
	DEFINE 		cYear				    CHAR(4);
	DEFINE 		cMesActual				INTEGER;
	DEFINE 		cArchivo			    CHAR(100);
	DEFINE 		cNombreArchivo		    CHAR(100);
	
-- ****************************************************************************
-- *                INICIALIZACION DE VARIABLES ERRORES                       *
-- ****************************************************************************
	LET 		sql_err      			= 0;
	LET 		isam_err     			= 0;
    LET 	   	cod_ret 				= '00000'; 
	LET 	   	mensaje_ret 			= 'PROCESO EXITOSO';

-- ****************************************************************************
-- *                    INICIALIZACION DE VARIABLES                           *
-- ****************************************************************************
	LET 		v_empresa	   	      	= '001';
	LET 		v_count_temp	   	    = 0;
	LET 		v_cargar_info			= 1;
	LET			v_fecha_carga			= TODAY;
	LET 		v_comienza_commit		= 0;
	LET 		v_suma_registros		= 0;

-- ****************************************************************************
-- *                  INICIALIZACION DE VARIABLES RUTAS                       *
-- ****************************************************************************
	LET 		cRuta		 			= "/resplogifx/hipotecario_infonavit/operaciones/";
	LET 		cSQL					= "";
	LET 		cNomSQL					= "sd_chi_ope_sdos_com_temp.sql";
	LET 		cArchivo				= "chi_ope_rep_sdos_com_";
	LET 		cYear 					= YEAR(v_fecha_carga);
	LET 		cMesActual				= MONTH(v_fecha_carga);
	LET			cNombreArchivo			= "";
	
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

    BEGIN
	
		ON EXCEPTION SET sql_err, isam_err
			IF sql_err != 0 THEN
			
				LET cod_ret = '11111';

				-- Limpiar la tabla de carga 
				TRUNCATE TABLE bdicred:"informix".sd_chi_ope_sdos_diarios;
							
				RETURN cod_ret;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-668) SET sql_err, isam_err
			IF sql_err != 0 THEN
			
				LET cod_ret = '22222';		
				LET mensaje_ret = 'VERIFICAR RUTA DEL ARCHIVO A CARGAR, TIPOS DE DATOS Y LONGITUDES';
				
				-- Limpiar la tabla de carga 
				TRUNCATE TABLE bdicred:"informix".sd_chi_ope_sdos_diarios;
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-1207) SET sql_err, isam_err
			IF sql_err != 0 THEN
			
				LET cod_ret = '33333';		
				LET mensaje_ret = 'VERIFICAR TIPOS DE DATOS Y LONGITUDES';
				
				-- Limpiar la tabla de carga 
				TRUNCATE TABLE bdicred:"informix".sd_chi_ope_sdos_diarios;
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-268) SET sql_err, isam_err
			IF sql_err != 0 THEN
			
				LET cod_ret = '44444';		
				LET mensaje_ret = 'VERIFICAR REGISTROS DUPLICADOS';
				
				-- Limpiar la tabla de carga 
				TRUNCATE TABLE bdicred:"informix".sd_chi_ope_sdos_diarios;
				
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-691) SET sql_err, isam_err
			IF sql_err != 0 THEN
			
				LET cod_ret = '44444';		
				LET mensaje_ret = 'VERIFICAR REGISTROS DUPLICADOS';
				
				-- Limpiar la tabla de carga 
				TRUNCATE TABLE bdicred:"informix".sd_chi_ope_sdos_diarios;
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        --*****************************************************************
        --*						Debug del Procedure                     --*        
        --*****************************************************************
		--SET DEBUG FILE TO '/resplogifx/hipotecario_infonavit/operaciones/sp_chi_ope_carga_sdos_com.out';
		--TRACE ON;                                                     
		
		-- ****************************************************************************
		-- *                        PROGRAMA PRINCIPAL                                *
		-- ****************************************************************************	
		-- ****************************************************************************
		-- *                       IMPORTACION DE ARCHIVO                             *
		-- ****************************************************************************	
    
		-- Limpiar tabla temporal
		DROP TABLE IF EXISTS bdicred:"informix".sd_chi_ope_sdos_com_temp;

		-- Crear tabla temporal
		CREATE TABLE bdicred:"informix".sd_chi_ope_sdos_com_temp(                             
			producto 					VARCHAR(20),
			periodo 					VARCHAR(10),
			credito 					VARCHAR(20),
			status_operativo 			VARCHAR(20),
			fecha_cesion 				DATE,
			fecha_firma 				DATE,
			regimen 					VARCHAR(5),
			status 						VARCHAR(5),
			com_seguro_vida				DECIMAL(18,2),
			iva_com_seguro_vida 		DECIMAL(18,2),
			com_infonavit				DECIMAL(18,2),
			iva_com_infonavit			DECIMAL(18,2),
			com_hito 					DECIMAL(18,2),
			iva_com_hito				DECIMAL(18,2)
		);
		
		-- Calcular mes y año anterior para la búsqueda del archivo con la información
		-- SI el mes actual es 01 (ENERO) asignar en automático el mes 12 y restar un año al año actual, si NO, restar un mes al mes actual
		IF (cMesActual = 1) THEN
			
			LET cMes = '12';
			LET cYear = YEAR(v_fecha_carga) - 1;
			
		ELSE
		
			LET cMes = LPAD(MONTH(v_fecha_carga)-1, 2, '0');
			
		END IF;
		
		
		LET cNombreArchivo = TRIM(cArchivo) || cYear || cMes || '.txt ';
		LET cSQL =  ' echo "SET ISOLATION TO DIRTY READ; LOAD FROM ' || TRIM(cRuta) || TRIM(cNombreArchivo) || 
					' INSERT INTO bdicred:"informix".sd_chi_ope_sdos_com_temp;' || "" || '">'||TRIM(cRuta)|| TRIM(cNomSQL);
		SYSTEM TRIM(cSQL);

		LET cSQL='chmod 777 '|| TRIM(cRuta)|| TRIM(cNomSQL);
		SYSTEM cSQL;

		LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || TRIM(cNomSQL);
		SYSTEM cSQL;
		
		LET cSQL = 'rm ' || TRIM(cRuta) || TRIM(cNomSQL);
		SYSTEM cSQL;
		
		-- Validar si existen registros a cargar
		SELECT 	COUNT(producto)
		INTO	v_count_temp
		FROM 	bdicred:"informix".sd_chi_ope_sdos_com_temp;
		
		-- Si existen registros en la tabla temporal, realizar el proceso de carga
		IF(v_count_temp > 0)	THEN
		
			-- Contar los regtistros de la tabla de carga
			SELECT 	COUNT(producto)
			INTO	v_count_info
			FROM 	bdicred:"informix".sd_chi_ope_sdos_com
			WHERE	empresa = v_empresa AND fecha_carga = v_fecha_carga;
			
			-- Si no existen registros en la tabla de carga con la fecha actual, insertar en tabla histórica; si existen registros, limpiar tabla de carga ya que la ejecución se identifica como re-proceso
			IF(v_count_info = 0) THEN
			
				-- Insertar registros de la tabla de carga a la tabla histórica
				INSERT INTO sd_chi_ope_sdos_com_hist SELECT * FROM sd_chi_ope_sdos_com;
				
			END IF;
			
			-- Limpiar la tabla de carga 
			TRUNCATE TABLE bdicred:"informix".sd_chi_ope_sdos_com;
			
			FOREACH WITH HOLD
				
				-- Seleccionar información de tabla temporal
				SELECT 	producto, periodo, credito, status_operativo, fecha_cesion,
						fecha_firma, regimen, status, com_seguro_vida, iva_com_seguro_vida,
						com_infonavit, iva_com_infonavit, com_hito, iva_com_hito
				INTO 	v_producto, v_periodo, v_credito, v_status_operativo, v_fecha_cesion,
						v_fecha_firma, v_regimen, v_status, v_com_seguro_vida, v_iva_com_seguro_vida,
						v_com_infonavit, v_iva_com_infonavit, v_com_hito, v_iva_com_hito
				FROM 	bdicred:"informix".sd_chi_ope_sdos_com_temp

					-- ABRE COMMIT'S PARCIALES
				IF (v_comienza_commit = 0) THEN
					LET v_comienza_commit = 1;
					BEGIN WORK;
				END IF;
				
				-- Insertar en la tabla principal
				INSERT INTO bdicred:"informix".sd_chi_ope_sdos_com VALUES	(v_empresa, v_fecha_carga, v_producto, v_periodo, v_credito,
																			 v_status_operativo, v_fecha_cesion, v_fecha_firma, v_regimen, v_status,
																			 nvl(v_com_seguro_vida,0), nvl(v_iva_com_seguro_vida,0), nvl(v_com_infonavit,0), 
																			 nvl(v_iva_com_infonavit,0), nvl(v_com_hito,0), nvl(v_iva_com_hito,0));
																			 
				LET v_suma_registros = v_suma_registros + 1;
			
				--REALIZA COMMIT CADA 1,000 REGISTROS
				IF (v_suma_registros >= 1000) THEN
					LET v_suma_registros = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
			
			IF (v_suma_registros > 0) THEN
				COMMIT WORK;
			END IF;
			
		ELSE

			LET v_cargar_info = 0;

		END IF;
		
		-- Ejecuta Stored Procedure para la conciliación de movimientos
		CALL bdicred:sp_chi_ope_concilia_com(v_cargar_info, v_fecha_carga) RETURNING cod_ret;
		
		-- Limpiar tabla temporal
		DROP TABLE IF EXISTS bdicred:"informix".sd_chi_ope_sdos_com_temp;
		
		RETURN cod_ret;	
    END	
END PROCEDURE;