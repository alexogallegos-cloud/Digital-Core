CREATE PROCEDURE "informix".sp_rep_prod_upgrade2(pEmpresa CHAR(3),
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
				IF substr(cnomarchivo,1,16) ='CAMBIOPRODTDCREP' THEN
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
				IF substr(cnomarchivo,1,16) ='CAMBIOPRODTDCREP' THEN
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
				IF substr(cnomarchivo,1,16) ='CAMBIOPRODTDCREP' THEN
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
'BD: bdicred';

CREATE PROCEDURE "informix".sp_reporte_bim_bajas_nom()
RETURNING   CHAR(5) 	AS retorno; ---,
            --CHAR(100)   AS mensaje_ret;

--Declaración de variables.
DEFINE v_num_credito             	 CHAR(20);
DEFINE v_num_producto             	 CHAR(4);
DEFINE v_status_cred				 CHAR(2);
DEFINE v_tipo_credito                SMALLINT;
DEFINE v_baja_cred                   CHAR(12);
DEFINE v_tipo_baja_cred              SMALLINT;
DEFINE v_mto_perdonado               DECIMAL(18,2);
DEFINE iSqlErr      				 INTEGER;
DEFINE iIsamErr         			 INTEGER;
DEFINE cErrorInfo       			 CHAR(100);
DEFINE cCodRet          			 CHAR(6);
DEFINE cMensajeRet    				 CHAR(100);
DEFINE pPeriodo              		 DATE;
DEFINE piniPeriodo					 DATE;
DEFINE flag_aniobis					 INTEGER;
DEFINE cRuta CHAR (50);
DEFINE cBitCamp CHAR (50);
DEFINE cCadena  CHAR (1500);

--INICIALIZACION DE VARIABLES
LET v_num_credito             	  ="";
LET v_num_producto             	  ="";
LET v_status_cred				  ="";
LET v_tipo_credito                =0;
LET v_baja_cred                   ="";
LET v_tipo_baja_cred              =0;
LET v_mto_perdonado               =0.00;
LET iSqlErr                         = 0;
LET iIsamErr         				= 0;
LET cErrorInfo       				= "";
LET cCodRet          				= "00000";
LET cMensajeRet    					= "REPORTE BIMESTRAL BAJAS NOMINA se realizó correctamente";
LET cRuta = '';
LET cBitCamp = '';
LET cCadena = '';



BEGIN
    --Errores no controlados.
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;

          RETURN cCodRet; --, cMensajeRet;
    END EXCEPTION;

    --SET DEBUG FILE TO "/ifxsif01/tmp/b_pp/proceso_dic_bajas_nomina/sp_reporte_bimestral_bajas_nom.out";
   -- TRACE ON;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO dirty READ;

   -- LET pPeriodo = mdy(month(today),1,year(today)) - 1 units day;
   --IPCB  Se cambia por consulta a la BD
	SELECT pri_dia_mes-1 units day , pri_dia_mes-2 units month  
	INTO pPeriodo, piniPeriodo
	FROM bdicred:sd_fechas;
	
	LET cRuta="/resplogifx/archivosriesgos/";	
	LET cBitCamp="bim_bajas_nom";
	LET cBitCamp= TRIM(cBitCamp)||'_'||YEAR(today)||LPAD(MONTH(today),2,0)||LPAD(DAY(today),2,0)||'.unl';

--Reproceso de Junio
--LET pPeriodo = mdy('06','30','2018');
--LET piniPeriodo = mdy('05','01','2018');
--Reproceso de Junio	

--Valida Anio Bisiesto
IF mod(year(pPeriodo),4) = 0 AND ((mod(year(pPeriodo),4)) = 0 OR (mod(year(pPeriodo),4) = 0)) THEN
	LET flag_aniobis = 1;
ELSE
	LET flag_aniobis = 0;
END IF;

	
    FOREACH WITH HOLD
        
        SELECT a.num_credito,
		30 as tipo_credito, 
		TO_CHAR(b.fecha_proceso, '%Y/%m/%d') as fecha_proc, 
		case when a.status_cred ='CV' then 50 else 60 end tipo_baja_cred,
		0.00 as mto_perdonado
		--INTO v_num_credito,v_tipo_credito,v_baja_cred,v_tipo_baja_cred,v_mto_perdonado
		FROM sd_maecredcrd a, 
		sd_maecredanexocrd b
		WHERE a.num_credito=b.num_credito
		and a.status_cred IN('FF','CV','FI', 'FC')
		and b.fecha_proceso>=piniPeriodo
		and b.fecha_proceso<=pPeriodo
		and a.num_producto in('6400')
	UNION ALL
		SELECT a.num_credito,
		30 as tipo_credito, 
		TO_CHAR(b.fecha_proceso, '%Y/%m/%d') as fecha_proc,  
		case when a.status_cred ='CV' then 50 else 60 end tipo_baja_cred,
		0.00 as mto_perdonado
		INTO v_num_credito,v_tipo_credito,v_baja_cred,v_tipo_baja_cred,v_mto_perdonado
		FROM sd_maecred a, 
		sd_maecredanexo b
		WHERE a.num_credito=b.num_credito
		and a.status_cred IN('FF','CV','FI', 'FC')
		and b.fecha_proceso>=piniPeriodo
		and b.fecha_proceso<=pPeriodo
		and a.num_producto in('7800')
							
        BEGIN WORK;
            INSERT INTO sd_reporte_bim_bajas_nom (fecha_cierre,num_credito,tipo_credito,fecha_baja_cred,tipo_baja_cred,mto_perdonado)
                 VALUES( pPeriodo,v_num_credito,v_tipo_credito,v_baja_cred,v_tipo_baja_cred,v_mto_perdonado);
      	COMMIT WORK;
	
	END FOREACH; 
	
	LET cCadena = '';
	LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitCamp)  ||'  delimiter '';'' SELECT num_credito,tipo_credito,fecha_baja_cred,tipo_baja_cred,mto_perdonado FROM bdicred:"informix".sd_reporte_bim_bajas_nom WHERE fecha_cierre= ''' ||mdy(month(pPeriodo), day(pPeriodo), year(pPeriodo))|| '''" >'||TRIM(cRuta)||'bim_bajas_nom.sql';
	SYSTEM cCadena;				
	LET cCadena='chmod 777 '|| TRIM(cRuta)||'bim_bajas_nom.sql';
	System cCadena;				
	let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bim_bajas_nom.sql';
	System cCadena;				
	LET cCadena = '' ;
	LET cCadena = 'rm ' || TRIM(cRuta) || 'bim_bajas_nom.sql';
	SYSTEM cCadena;
	
    LET cCodRet     = "00000";
    LET cMensajeRet = "REPORTE BIMESTRAL BAJAS NOMINA OK ";

	RETURN cCodRet; --, cMensajeRet;
END
END PROCEDURE
;