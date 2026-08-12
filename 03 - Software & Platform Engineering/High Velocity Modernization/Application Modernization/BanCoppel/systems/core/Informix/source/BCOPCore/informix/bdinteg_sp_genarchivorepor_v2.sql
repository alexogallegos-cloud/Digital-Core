CREATE PROCEDURE "informix".sp_genarchivorepor_v2(pdcve_sorteo char(5), pdFechaBusqueda DATE)
	RETURNING CHAR(5) AS CodRetorno,
              CHAR(5) AS Clave_Sorteo,
             CHAR(80) AS Mensaje;
	--DECLARACION
	DEFINE visqlerr INTEGER;
	DEFINE vsCodRetorno CHAR (5);
	DEFINE vsMensajeRetorno CHAR (80);
	DEFINE vsRepositorio CHAR (100);
	DEFINE vsCve_Sorteo CHAR (5);
	DEFINE vsFlagEsEmpleado CHAR (5);
	DEFINE vsArchTemporal CHAR (15);
	DEFINE vsNomArchivo CHAR (30);
	DEFINE vsSQL CHAR (1500);
	DEFINE vsSQL1 CHAR (200);
	DEFINE vsSQL2 CHAR (900);
	DEFINE vsSQL3 CHAR (200);
    DEFINE vi_valor CHAR (50);
    DEFINE pdrepositorio CHAR (50);
	DEFINE contfile INT;
	DEFINE numfile FLOAT;
	DEFINE numreg INT;
	DEFINE limitmin INT;
	DEFINE limitmax INT;
	DEFINE vflag_sort INT;
	DEFINE vruta_sorteo CHAR (100);
	DEFINE vboletos INT;
	--INICIALIZACION
--SET DEBUG FILE TO "/informix/ifg/salida/sp_genarchivorepor.out";
--TRACE ON;
	LET vsCodRetorno = '00000';
	LET vsMensajeRetorno = '';
	LET vsRepositorio = '';
	LET vsCve_Sorteo = '';
	LET vsFlagEsEmpleado = '';
	LET vsArchTemporal = '';
	LET vsNomArchivo = '';
	LET vsSQL = '';
	LET vsSQL1 = '';
	LET vsSQL2 = '';
	LET vsSQL3 = '';
	LET visqlerr = 0;
	LET contfile = 0;
	LET vflag_sort = 0;
	LET vruta_sorteo = '';
	LET vboletos = 0;

	-- Gari Almaraz 16-12-2019
 	-- Permite generar el reporte a peticion del usuario con una 
 	-- fecha determinada.

	BEGIN
		ON EXCEPTION SET visqlerr --Control de errores.
			LET vsMensajeRetorno = 'ERROR NO CONTROLADO: ' || visqlerr ;
			RETURN visqlerr, '00000', vsMensajeRetorno;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT {+index (si_sorteo idx_si_sorteo_cve)} flag_sort
		INTO vflag_sort
       	FROM bdinteg:si_sorteo 
       	WHERE cve_sorteo = pdcve_sorteo 
       		AND pdFechaBusqueda BETWEEN  f_ini AND f_fin 
       		AND flag_sort = 2;


        IF vflag_sort > 0 THEN
			SELECT {+index (si_param 194_429)} valor
	   			INTO vi_valor
		   	FROM si_param
		   	WHERE empresa = '001'
		   		AND cod_param = '112';

	   		-- Busca ruta para archivos
	   		SELECT {+index (si_param 194_429)} valor
	   		INTO vruta_sorteo
			FROM si_param
			WHERE empresa = '001' 
			    AND cod_param = '112';

			IF (TRIM(vruta_sorteo) = '') THEN
				LET vsCodRetorno = "00042";
				LET vsMensajeRetorno = "Error: No Existe ruta de deposito!";
				RETURN vsCodRetorno, pdcve_sorteo, vsMensajeRetorno;
			END IF;

		  	LET pdrepositorio = vi_valor;
			
			--se valida lso datos de entradas
			IF (pdcve_sorteo =  '') or (pdcve_sorteo is null) THEN
				LET vsCodRetorno = '00002';
				LET vsMensajeRetorno = 'NUMERO DE SORTEO INVALIDO';
				RETURN vsCodRetorno, pdcve_sorteo, vsMensajeRetorno;
			END IF;

			SELECT {+INDEX (si_boleto_temp idx_si_boleto_temp)} COUNT(*)
				INTO vboletos
			FROM bdinteg:si_boleto_temp
			WHERE cve_sorteo = pdcve_sorteo
				AND fecha BETWEEN pdFechaBusqueda AND pdFechaBusqueda;

			IF vboletos <= 0 THEN
				LET vsCodRetorno = '00004';
				LET vsMensajeRetorno = 'NO EXISTEN DATOS CON LOS PARAMETROS DADOS';
				RETURN vsCodRetorno, pdcve_sorteo, vsMensajeRetorno;
			END IF;

			SELECT MAX(consecutivo)
				INTO numreg
		 	FROM si_boleto_temp;

			LET numfile = numreg /450000;
			LET limitmin = 0;
			LET limitmax = 0;

			IF (numfile < 1)  THEN 
				LET numfile = 1;
			END IF;
					
					 IF (contfile <  numfile) or (contfile = numfile) THEN
							LET contfile = contfile + 1;
							LET limitmin = limitmin + 1;
							LET limitmax = numreg;
							
							LET vsArchTemporal = 'temporal.txt';
							LET vsNomArchivo = 'BANCOPPELSORTEO_' || SUBSTRING (pdFechaBusqueda FROM 9 FOR 2) || SUBSTRING (pdFechaBusqueda FROM 1 FOR 2) || SUBSTRING (pdFechaBusqueda FROM 4 FOR 2) ||'_'||contfile|| '.txt' ;
							--GENERA EL ARCHIVO DE INTERCAMBIO
							LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(pdrepositorio) || '/' || TRIM(vsArchTemporal) || ' DELIMITER ' || '''?''';
							
							
							LET vsSQL2 = "SELECT {+ INDEX (bdinteg:si_boleto_temp)idx_si_boleto_temp} ( NVL(Boleto, 0) ||'|'|| NVL(Estado, 0) ||'|'|| NVL(TRIM(ciudad), '')||'|'|| NVL(TRIM(Sucursal), '') ||'|'|| NVL(TRIM(Area), '')||'|'|| NVL(Caja, 0) ||'|'|| "
							|| "NVL(TRIM(TipoMov), '') ||'|'|| NVL(TRIM(SUBSTRING ( FolioSuc FROM 9 FOR 8)), '') ||'|'|| NVL(TRIM(NumCte), '') ||'|'||  NVL(Importe::INTEGER, 0) ||'|'|| NVL(TRIM(Telefono1), '') ||'|'|| NVL(TRIM(Telefono2), '') ||'|'||"
							|| "NVL(TRIM(Nombre), '') ||'|'|| NVL(TRIM(Domicilio), '') ||'|'|| NVL(f_registro, CURRENT) ||'|'|| NVL(TRIM(Origen), '') ||'|'|| NVL(Secuencia, 0) ||'|'|| NVL(TRIM(ent_fed), '')) "
							|| "FROM bdinteg:si_boleto_temp "
							|| "WHERE ciudad <> '' AND domicilio <> '' AND ent_fed <> '' AND Cve_Sorteo = '" || pdcve_sorteo ||	"'AND NumCte <> '' AND Estado <> 101 AND  consecutivo BETWEEN "|| limitmin || " AND " || limitmax 
							|| " AND Fecha = '" || pdFechaBusqueda || "' ;";
							
							LET vsSQL3 = ' " > '|| TRIM(pdrepositorio) || '/control_reporte.sql';
							LET vsSQL1 = TRIM(vsSQL1);
							LET vsSQL2 = TRIM(vsSQL2);
							LET vsSQL3 = TRIM(vsSQL3);
							LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
							LET vsSQL = TRIM(vsSQL); 
							--CHECA QUE NO ESTE VACIA LA CONSULTA
							IF ( vsSQL <> '' ) THEN
								SYSTEM vsSQL ;
								--Permiso para la creacion de archivo.
								LET vsSQL = '' ;
								LET vsSQL = 'chmod 666 ' || TRIM(pdrepositorio) || '/control_reporte.sql' ;
								LET vsSQL = '' ;
								LET vsSQL = 'dbaccess BdInteg ' || TRIM(pdrepositorio) || '/control_reporte.sql' ;
								SYSTEM vsSQL ;
								--Borra el archivo de control.
								LET vsSQL = '' ;
								LET vsSQL = 'rm ' || TRIM(pdrepositorio) || '/control_reporte.sql';
								SYSTEM vsSQL ;
								--Elimina el caracter delimitador '?'.
								LET vsSQL = '' ;
								LET vsSQL =  "sed 's/?$//g' " || TRIM(pdrepositorio) || '/' || TRIM (vsArchTemporal) || " > " || TRIM(pdrepositorio) || '/' ||
								TRIM (vsNomArchivo);
								SYSTEM vsSQL;
								--Borra el archivo de control.
								LET vsSQL = '' ;
								LET vsSQL = 'rm ' || TRIM(pdrepositorio) || '/' || TRIM (vsArchTemporal);
								SYSTEM vsSQL ;
								LET vsMensajeRetorno = 'GENERACION DEL ARCHIVO ' || vsNomArchivo || ' FINALIZADA';
								--RETURN vsCodRetorno, pdcve_sorteo, vsMensajeRetorno;

							
							END IF;
					END IF;
					RETURN vsCodRetorno, pdcve_sorteo, vsMensajeRetorno;
		ELSE
		LET vsCodRetorno = "22222";
        LET vsMensajeRetorno = "ÃÂÃÂ¡EL SORTEO NAVIDEÃÂO NO ESTA ACTIVO!";
		RETURN vsCodRetorno, pdcve_sorteo, vsMensajeRetorno;
	END IF;	
	END;
END PROCEDURE
DOCUMENT
'SPL original -> sp_genarchivorepor',
'Se modifica para generar reporte por solicitud',
'No depente del proceso automatico del sorteo',
'BD: BdInteg';

CREATE PROCEDURE "informix".sp_genarepctescoppelbancoppelctas()
    RETURNING CHAR(5) AS codret;
	
	--DeclaraciÃ³n de variables
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE cNumcteBanco CHAR(20);	DEFINE cCliente CHAR(20);	DEFINE bTieneIdentDigital BOOLEAN;	DEFINE cTpoBiometria CHAR(1);	DEFINE bTieneTarDeb BOOLEAN;	DEFINE bTieneTarCred BOOLEAN;	DEFINE cStatusTarDeb CHAR(1);	DEFINE cStatusTarCred CHAR(1);	DEFINE iRegCommit INTEGER;
	DEFINE iCont INTEGER;
	DEFINE cNumcteBancoAux CHAR(20);
	
	--InicializaciÃ³n de variables
	LET iSqlErr = 0;
	LET cCodRet = '00000';
	LET bInTransaction = 'f';
	LET cNumcteBanco = '';
	LET cCliente = '';
	LET bTieneIdentDigital = 'f';
	LET bTieneTarDeb = 'f';
	LET bTieneTarCred = 'f';
	LET cStatusTarDeb = '';
	LET cStatusTarCred = '';
	LET iRegCommit = 5000;
	LET iCont = 0;
	LET cNumcteBancoAux = null;
	LET cTpoBiometria = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genarepctescoppelbancoppelctas.out';
		--TRACE ON;
		
		
		LET iCont = 0;
		BEGIN WORK;	
		FOREACH WITH HOLD
			SELECT 
			{+INDEX (bdinteg:"informix".tmp_rep_cte_coppel_bancoppel_ctas "informix".idx_tmp_rep_cte_coppel_bancoppel_ctas_numcte_banco)} cliente
			INTO cCliente
			 FROM bdinteg:"informix".tmp_rep_cte_coppel_bancoppel_ctas reg
			WHERE reg.numcte_banco IS NULL OR reg.numcte_banco=''
			
			--Se consulta el nÃºmero de cliente bancoppel
			SELECT 
			FIRST 1 numcte_banco
			INTO cNumcteBanco
			FROM bdinteg:"informix".si_relacion_ctebcplcpl
			WHERE CLIENTE = cCliente--'100391'
			;
			
			IF cNumcteBanco IS NOT NULL AND cNumcteBanco!='' THEN
				
				--Se consulta si se tiene registrada su identificaciÃ³n del cliente digitalizada en el sistema
				SELECT 
				FIRST 1 cliente
				INTO cNumcteBancoAux
				FROM bdidigital@coppelimg_tcp:dg_expediente ex
				INNER JOIN bdidigital@coppelimg_tcp:"informix".dg_tipodocumento tdoc ON tdoc.cod_docto=ex.cod_docto
				WHERE 
				ex.cliente=cNumcteBanco
				AND tdoc.cod_grupo='001';
				
				IF cNumcteBancoAux IS NOT NULL AND cNumcteBancoAux !='' THEN
					LET bTieneIdentDigital = 't';
				END IF;
				
				--Se consulta si se tiene registrado en el sistema la biometria facial del cliente
				SELECT cte.tpo_biometria
				INTO cTpoBiometria
				FROM bdinteg:"informix".si_cliente cte
				WHERE cte.numcte = cNumcteBanco
				;
				
				--Se consulta si cuenta con tarjeta de debito y su estatus actual
				SELECT 
				FIRST 1 status_tar 
				INTO cStatusTarDeb
				FROM bdicheq:"informix".sc_tarjeta t1
				WHERE t1.numcte=cNumcteBanco
				AND t1.secuencia=
				(   
					SELECT MAX(t2.secuencia) FROM bdicheq:"informix".sc_tarjeta t2
					WHERE t2.numcte=t1.numcte
				)
				;		
				
				IF cStatusTarDeb IS NOT NULL AND cStatusTarDeb != '' THEN
					LET bTieneTarDeb = 't';
				END IF;
				
				--Se consulta si cuenta con tarjeta de credito y su estatus actual
				SELECT 
				FIRST 1 status_tar
				INTO cStatusTarCred
				FROM bdicred:"informix".sd_tarjeta t1
				WHERE t1.numcte=cNumcteBanco
				AND t1.secuencia=
				(   SELECT 
					MAX(t2.secuencia)
					FROM bdicred:"informix".sd_tarjeta t2
					WHERE t2.numcte=t1.numcte
				)
				;
				IF cStatusTarCred IS NOT NULL AND cStatusTarCred != '' THEN
					LET bTieneTarCred = 't';
				END IF;
				
				UPDATE {+INDEX (bdinteg:"informix".tmp_rep_cte_coppel_bancoppel_ctas "informix".idx_tmp_rep_cte_coppel_bancoppel_ctas_cliente)} "informix".tmp_rep_cte_coppel_bancoppel_ctas
				SET numcte_banco=cNumcteBanco, tiene_ident_digital=bTieneIdentDigital, tpo_biometria=cTpoBiometria, tiene_tar_deb=bTieneTarDeb, status_tar_deb=cStatusTarDeb, tiene_tar_cred=bTieneTarCred, status_tar_cred=cStatusTarCred
				WHERE cliente=cCliente
				;
				
				LET cNumcteBanco = '';
				LET cCliente = '';
				LET bTieneIdentDigital = 'f';
				LET bTieneTarDeb = 'f';
				LET bTieneTarCred = 'f';
				LET cStatusTarDeb = '';
				LET cStatusTarCred = '';
				LET cNumcteBancoAux = null;
				LET cTpoBiometria = '';

				LET iCont = iCont + 1;
				
				IF iCont >= iRegCommit THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
			END IF;
			
		END FOREACH;
		COMMIT WORK;	-- Prueba!!
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Jorge GarcÃ­a',
'FECHA 26/12/2019',
'FUNCIONALIDAD: GeneraciÃ³n de reporte de los clientes Coppel que tambien son clientes BanCoppel y ademas cuentan con tarjeta de debito y credito',
'DESCRIPCION: SPL encargado generar los reportes en formato xls.';

CREATE PROCEDURE "informix".sp_reporte_clientes_titulares_upgrade_2() RETURNING CHAR(5), CHAR(100);


--DEFINICION DE VARIABLES
DEFINE vcodRet 		    VARCHAR(6); 	-- CODIGO DE RETORNO
DEFINE cMsjCodRet 	    VARCHAR(100);
DEFINE cMensaje		    VARCHAR(100);
DEFINE vsqlerr 			INTEGER;		-- VARIABLE PARA CACHAR EL CODIGO DE ERRORDEFINE vsqlerr integer;
DEFINE iIsamErr 		INTEGER;	 	-- VARIABLE PARA CACHAR EL CODIGO DE ERROR
DEFINE cErrorInfo 		VARCHAR(80);  	-- VARIABLE PARA CACHAR LA DESCRIPCION DEL ERROR

DEFINE cRutaRepor		VARCHAR(50);
DEFINE cNombreRepExc	VARCHAR(50);   
DEFINE cRutaEjecc 		VARCHAR(50); 
DEFINE cSystem			LVARCHAR (2000);
DEFINE iPaso			SMALLINT;
DEFINE dFechaActual	  	DATE;
DEFINE nContador        INT;
DEFINE nContador2       INT;
DEFINE dFechaHoy		DATE;
DEFINE cYear			CHAR(4);
DEFINE cMes 			CHAR(2);
DEFINE cDia 			CHAR(2);


--INICIALIZACION DE VARIABLES
LET vcodRet 			= '00000';
LET cMsjCodRet 		    = 'EL REPORTE DE CLIENTES TITULARES SE HA GENERADO CORRECTAMENTE';
LET cMensaje		    = 'ERROR EN PASO: ';
LET vsqlerr 			= 0;
LET iIsamErr 			= 0;
LET cErrorInfo 			= "";
LET cSystem				= '';
LET iPaso               = 0;
LET dFechaActual		= TODAY -20;  
LET nContador       	= 0;
LET nContador2     		= 0;
LET dFechaHoy			= '';
LET cYear				= '';
LET cMes 				= '';
LET cDia 				= '';

--DESARROLLO
--LET cRutaRepor		= '/home/procesos/';
--PRODUCCION
LET cRutaRepor			= '/RESPALDOSNEW/procesos/';
--DESARROLLO
--LET cRutaEjecc        = '/informix/bin/dbaccess bdinteg ';
--PRODUCCION
LET cRutaEjecc        	= '/ifxsif01/bin/dbaccess bdinteg ';
LET cNombreRepExc 		= 'REPORTE_CLIENTES_TITULARES_UPGRADE.csv';



BEGIN

	ON EXCEPTION  SET vsqlerr, iIsamErr, cErrorInfo
	
		IF vsqlerr <> 0  THEN
		
			LET  vCodRet  = vsqlerr;
			LET cMensaje = TRIM( cMensaje ) || iPaso;
			RETURN vCodRet, cMensaje;

		END IF;
	END  EXCEPTION
	
	--SET DEBUG FILE TO "/tmp/ingrid/sp_reporte_clientes_titulares_upgrade.out";
	--TRACE ON;
	
	--OBTENCION DE FECHA DEL DIA DE HOY
		/*SELECT fecha_hoy
		INTO dFechaHoy
		FROM bdinteg:"informix".si_fechas;*/
		
		LET cYear = LPAD(YEAR(dFechaActual), 4, 0);
		LET cMes = LPAD(MONTH(dFechaActual), 2, 0);
		LET cDia = LPAD(DAY(dFechaActual), 2, 0);
		
		LET cNombreRepExc = 'REPORTE_CLIENTES_TITULARES_UPGRADE_'||cYear||cMes||cDia||'.csv';
	
	LET iPaso = 0;
	
		LET cSystem = 'rm -f ' || cRutaRepor || cNombreRepExc;
		SYSTEM cSystem; 
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
	LET iPaso = 1;
	
		DROP TABLE IF EXISTS TMP_CLIENTES_TIT_1;
		DROP TABLE IF EXISTS TMP_CLIENTES_TIT_2;
		
		LET cSystem =  'echo "' || 'FECHA' || ',' || 'CLIENTES TITULARES' || ',' || 'UPGRADE' || ',' || 'TOTAL DE CLIENTES TITULARES' || ',' || 'P-109' || ',' || 'U-3' || ',' || 'U-60' || ',' || 'U-61' || ',' || 'U-62' || ',' || 'TOTAL DE SITUACIONES ESPECIALES' /*|| ',' || 'CLIENTES PROSPECTO POR SOLICITUDES DE COBRANZA' || ',' || 'CLIENTES PROSPECTO POR SOLICITUDES DE ALTA WEB' || ',' || 'CLIENTES TOTAL PROSPECTO'*/ || '" >> ' || TRIM(cRutaRepor) || TRIM(cNombreRepExc);
		SYSTEM cSystem;
	
	LET iPaso = 2;

		--CLIENTES TITULARES
		SELECT numcte, '     ' AS SITESP
		FROM bdinteg:"informix".si_cliente
		WHERE fecha_insert = dFechaActual
		AND fecha_alta = fecha_insert
		AND tipo_cliente = '1'
		INTO TEMP TMP_CLIENTES_TIT_1 WITH NO LOG;
		
		CREATE INDEX "informix".idx_TMP_CLIENTES_TIT_1 ON TMP_CLIENTES_TIT_1(numcte);
	
	LET iPaso = 3;

		--CLIENTES UPGRADE
		SELECT DISTINCT cte.numcte, '     ' AS SITESP
		--INSTANCIA DESARROLLO
		--FROM bdidigital@coppelimg_tcp:"informix".dg_expediente ex JOIN bdinteg:"informix".si_cliente cte
		--INSTANCIA PRODUCTIVA
		FROM bdidigital@coppelimg_tcp:"informix".dg_expediente ex JOIN bdinteg:"informix".si_cliente cte
		ON ex.cliente = cte.numcte
		AND cte.tipo_cliente = '1'
		AND ex.fecha_alta <> cte.fecha_insert
		WHERE ex.fecha_alta = dFechaActual
		AND ex.cod_docto IN ('0012','0015','0016','0017','0018','0031','0032','0033','0001','0003','0013','0014','0022','0027','0028','0029','0030','0939','0940','0047','0048','0049','0050','0061','0083','0084','0085','0086','0087','0088','0089','0090','0091','0092','0938')
		AND ex.secuencia = 1
		AND ex.prod_nombre IN (TRIM('ALTA CLIENTES'), TRIM('ALTA CLIENTES MENORES DE EDAD'))
		AND ex.empresa = '001'		
		INTO TEMP TMP_CLIENTES_TIT_2 WITH NO LOG;
		
		CREATE INDEX "informix".idx_TMP_CLIENTES_TIT_2 ON TMP_CLIENTES_TIT_2(numcte);
	
	LET iPaso = 4;

		--CLIENTE TITULARES
		SELECT COUNT(*) INTO nContador FROM TMP_CLIENTES_TIT_1;

		LET cSystem =  'echo "' || TRIM( TO_CHAR(dFechaActual, '%d/%m/%Y')) || ',';
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador ) ) || ',';
	
	LET iPaso = 5;

		--CLIENTE UPGRADE
		SELECT COUNT(*) INTO nContador FROM TMP_CLIENTES_TIT_2;
		
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador ) ) || ',';
	
	LET iPaso = 6;

		--CLIENTE TITULARES + UPGRADE
		SELECT SUM(NUMCTE)
		INTO nContador
		FROM
		(SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_1
		 UNION
	     SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_2);
	
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador ) ) || ',';
	
	LET iPaso = 7;

		UPDATE TMP_CLIENTES_TIT_1
		SET SITESP = ( SELECT X.SITUACION||X.CAUSA FROM BDISITESP:SE_CTESSITESPCTE X WHERE X.NUMCTE = TMP_CLIENTES_TIT_1.NUMCTE );
	
	LET iPaso = 8;

		UPDATE TMP_CLIENTES_TIT_2
		SET SITESP = ( SELECT X.SITUACION||X.CAUSA FROM BDISITESP:SE_CTESSITESPCTE X WHERE X.NUMCTE = TMP_CLIENTES_TIT_2.NUMCTE );
	
	LET iPaso = 9;

		--SITUACION P109
		SELECT SUM(NUMCTE) INTO nContador
		FROM
		(SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_1 WHERE SITESP = 'P109'
		 UNION
		 SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_2 WHERE SITESP = 'P109');
		
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador ) ) || ',';

	LET iPaso = 10;
	
		--SITUACION U3
		SELECT SUM(NUMCTE) INTO nContador
		FROM
		(SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_1 WHERE SITESP = 'U3'
		 UNION
	     SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_2 WHERE SITESP = 'U3');
		
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador ) ) || ',';

	LET iPaso = 11;
	
		--SITUACION U60
		SELECT SUM(NUMCTE) INTO nContador
		FROM
		(SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_1 WHERE SITESP = 'U60'
		 UNION
		 SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_2 WHERE SITESP = 'U60');
		
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador ) ) || ',';

	LET iPaso = 12;
	
		--SITUACION U61
		SELECT SUM(NUMCTE) INTO nContador
		FROM
		(SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_1 WHERE SITESP = 'U61'
		 UNION
		 SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_2 WHERE SITESP = 'U61');
		
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador ) ) || ',';
	
	LET iPaso = 13;

		--SITUACION U62
		SELECT SUM(NUMCTE) INTO nContador
		FROM
		(SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_1 WHERE SITESP = 'U62'
		 UNION
		 SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_2 WHERE SITESP = 'U62');
		
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador ) ) || ',';
	
	LET iPaso = 14;

		--SUMA DE SITUACIONES
		SELECT SUM(NUMCTE) INTO nContador
		FROM
		(SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_1 WHERE SITESP IN( 'P109', 'U3', 'U60', 'U61', 'U62' )
		 UNION
		 SELECT COUNT(*) AS NUMCTE FROM TMP_CLIENTES_TIT_2 WHERE SITESP IN( 'P109', 'U3', 'U60', 'U61', 'U62' ));
		
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador ) );
	
	/*LET iPaso = 15;

		SELECT COUNT(*) INTO nContador
		FROM bdinteg:"informix".si_cliente A JOIN BDIPROSPECTOS:pr_cliente B
		ON A.NUMCTE = B.NUMCTE
		WHERE A.fecha_insert = dFechaActual
		AND A.tipo_cliente = '2'
		AND B.sucursal = '0800';
		
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador ) ) || ',';
	
	LET iPaso = 16;

		SELECT COUNT(*) INTO nContador2
		FROM bdinteg:"informix".si_cliente A JOIN BDIPROSPECTOS:pr_cliente B
		ON A.NUMCTE = B.NUMCTE
		WHERE A.fecha_insert = dFechaActual
		AND A.tipo_cliente = '2'
		AND B.sucursal != '0800';
		
		LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador2 ) ) || ',';*/
	
	
	LET iPaso = 17;
	
		--LET cSystem =  TRIM( cSystem ) || TRIM( TO_CHAR( nContador + nContador2 ) ) || '" >> ' || TRIM(cRutaRepor) || TRIM(cNombreRepExc);
		LET cSystem =  TRIM( cSystem ) || '" >> ' || TRIM(cRutaRepor) || TRIM(cNombreRepExc);
		SYSTEM cSystem;
	
	LET iPaso = 18;

		RETURN vCodRet, cMsjCodRet;

END;
END PROCEDURE;