CREATE PROCEDURE "informix".sp_tipospagosdom_web(iRegOmitidos SMALLINT)
RETURNING	CHAR (5)AS Retorno,		--CODIGO DE RETORNO
			CHAR (1)AS Clave ,		--CLAVE A DOMICILIAR
			CHAR (40)AS Descripcion;
				
--DECLARACION DE VARIABLES
	DEFINE sql_err        	 		INTEGER;
	DEFINE cCodret         			CHAR(5);
	DEFINE cClave					CHAR(1)	;
	DEFINE cDescripcion				CHAR(40);
	
--Inicializar Variables
	LET sql_err            			= 0;
	LET cCodret            			= '00000';
	LET cClave						= '';
	LET cDescripcion       			= '';
	
 	--SET debug FILE TO "/tmp/ sp_tipospagosdom.out";
        --Trace ON;
       
	BEGIN 
			--Manejo de excepciones (errores)
			ON EXCEPTION SET sql_err
				IF sql_err <> 0 THEN
					let cCodret = sql_err;
					RETURN cCodret, cClave, cDescripcion; --Regresa Resultados
				END IF;
			END EXCEPTION; 
			
			SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT SKIP iRegOmitidos cve_domiciliar_tc, descripcion 
			INTO cClave, cDescripcion
			FROM bdidomi:dom_cat_imptc
			
			RETURN  cCodret, cClave, cDescripcion WITH RESUME; --Regresa Resultados
		END FOREACH;
				
	END
END PROCEDURE
DOCUMENT
'Autor		: Armida Pazos',
'DescripciÃ³n: Carga el tipo de pago domiciliado.',
'Fecha		: 2010/02/03',
'VersÃ³n		: 20100203.0850',
'BD         : bdidomi';

CREATE PROCEDURE "informix".sp_domi_subirarchivos(p_Tipo CHAR(1), p_CodRuta CHAR(2), p_NombreArchivo VARCHAR(20), p_Usuario CHAR(8))
RETURNING
	CHAR(5), ---cod_ret
	VARCHAR(115); ---descripcion

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;

	DEFINE sDescMensajeError	VARCHAR(95);
	DEFINE sRuta				CHAR(100);
	DEFINE sCadSql				LVARCHAR(1000);
	DEFINE sLinea				LVARCHAR(500);

	--- VARIABLES PARA EL ENCABEZADO
	DEFINE sEncTipoReg				CHAR(2);
	DEFINE sEncNumSec				CHAR(7);
	DEFINE sEncCodOper				CHAR(2);
	DEFINE sEncBanco				CHAR(3);
	DEFINE sEncSentido				CHAR(1);
	DEFINE sEncServicio				CHAR(1);
	DEFINE sEncNumBloque			CHAR(7);
	DEFINE sEncFechaPres			CHAR(8);
	DEFINE sEncCodDivisa			CHAR(2);
	DEFINE sEncCausaRechazo			CHAR(2);
	DEFINE sEncModalidad			CHAR(1);
	DEFINE sEncUsoFuturoCCEN		CHAR(41);
	DEFINE sEncUsoFuturoBANCO		CHAR(345);

	DEFINE cHora				CHAR(8);
	DEFINE cFechaArchivoOUT		CHAR(15);
	DEFINE iPaso				SMALLINT;
	

	--- VARIABLE PARA EL DETALLE
	DEFINE sDetTipoReg				CHAR(2);
	DEFINE sDetNumSec				CHAR(7);
	DEFINE sDetCodOper				CHAR(2);
	DEFINE sDetCodDivisa			CHAR(2);
	DEFINE SDetFechaTrans			CHAR(8);
	DEFINE sDetBancoPres			CHAR(3);
	DEFINE sDetBancoRec				CHAR(3);
	DEFINE sDetImpOperacion			CHAR(15);
	DEFINE sDetUsoFuturoCCEN		CHAR(16);
	DEFINE sDetTipoOperacion		CHAR(2);
	DEFINE sDetFechaApli			CHAR(8);
	DEFINE sDetTipoCtaOrdenante		CHAR(2);
	DEFINE sDetNumCtaOrdenante		CHAR(20);
	DEFINE sDetNombreOrdenante		CHAR(40);
	DEFINE sDetRFCCURPOrdenante		CHAR(18);
	DEFINE sDetTipoCtaReceptor		CHAR(2);
	DEFINE sDetNumCtaReceptor		CHAR(20);
	DEFINE sDetNombreReceptor		CHAR(40);
	DEFINE sDetRFCCURPReceptor		CHAR(18);
	DEFINE sDetRefServEmisor		CHAR(40);
	DEFINE sDetNomTitularServ		CHAR(40);
	DEFINE sDetImpIvaOperacion		CHAR(15);
	DEFINE sDetRefNumOrdenante		CHAR(7);
	DEFINE sDetRefLeyendaOrdenante  CHAR(40);
	DEFINE sDetClaveRastreo			CHAR(30);
	DEFINE sDetMotivoDev			CHAR(2);
	DEFINE sDetFecPresInicial		CHAR(8);
	DEFINE sDetUsoFuturoBanco		CHAR(12);

	--- VARIABLES PARA EL SUMARIO
	DEFINE sSumTipoReg				CHAR(2);
	DEFINE sSumNumSec				CHAR(7);
	DEFINE sSumCodOper				CHAR(2);
	DEFINE sSumNumBloque			CHAR(7);
	DEFINE sSumNumOper				CHAR(7);
	DEFINE sSumImpTotOper			CHAR(18);
	DEFINE sSumUsoFuturoCCEN		CHAR(40);
	DEFINE sSumUsoFuturoBanco		CHAR(339);

	DEFINE bBandArchivo				BOOLEAN;
	DEFINE iNumCaracteres			INTEGER;
	DEFINE iContador				SMALLINT;
	DEFINE iNumReg					INTEGER;
	DEFINE cRutaIfx					CHAR(100);
	DEFINE cMensaje					CHAR(40);
	DEFINE viSqlErr 				INTEGER;

	---INICIALIZACIONES
	LET v_cod_ret 					= '00000';
	LET sRuta						= "";
	LET sLinea						= "";
	LET sDescMensajeError			= "";

	--- INICIALIZACIONES PARA EL ENCABEZADO
	LET sEncTipoReg					= "";
	LET sEncNumSec					= "";
	LET sEncCodOper					= "";
	LET sEncBanco					= "";
	LET sEncSentido					= "";
	LET sEncServicio				= "";
	LET sEncNumBloque				= "";
	LET sEncFechaPres				= "";
	LET sEncCodDivisa				= "";
	LET sEncCausaRechazo			= "";
	LET sEncModalidad				= "";
	LET sEncUsoFuturoCCEN			= "";
	LET sEncUsoFuturoBANCO			= "";

	--- INICIALIZACIONES PARA EL DETALLE
	LET sDetTipoReg					= "";
	LET sDetNumSec					= "";
	LET sDetCodOper					= "";
	LET sDetCodDivisa				= "";
	LET SDetFechaTrans				= "";
	LET sDetBancoPres				= "";
	LET sDetBancoRec				= "";
	LET sDetImpOperacion			= "";
	LET sDetUsoFuturoCCEN			= "";
	LET sDetTipoOperacion			= "";
	LET sDetFechaApli				= "";
	LET sDetTipoCtaOrdenante		= "";
	LET sDetNumCtaOrdenante			= "";
	LET sDetNombreOrdenante			= "";
	LET sDetRFCCURPOrdenante		= "";
	LET sDetTipoCtaReceptor			= "";
	LET sDetNumCtaReceptor			= "";
	LET sDetNombreReceptor			= "";
	LET sDetRFCCURPReceptor			= "";
	LET sDetRefServEmisor			= "";
	LET sDetNomTitularServ			= "";
	LET sDetImpIvaOperacion			= "";
	LET sDetRefNumOrdenante			= "";
	LET sDetRefLeyendaOrdenante  	= "";
	LET sDetClaveRastreo			= "";
	LET sDetMotivoDev				= "";
	LET sDetFecPresInicial			= "";
	LET sDetUsoFuturoBanco			= "";

	--- INICIALIZACIONES PARA EL SUMARIO
	LET sSumTipoReg					= "";
	LET sSumNumSec					= "";
	LET sSumCodOper					= "";
	LET sSumNumBloque				= "";
	LET sSumNumOper					= "";
	LET sSumImpTotOper				= "";
	LET sSumUsoFuturoCCEN			= "";
	LET sSumUsoFuturoBanco			= "";

	LET bBandArchivo				= "f";
	LET iNumCaracteres				= 0;
	LET iContador					= 0;
	LET iNumReg						= 0;

	LET cHora				= TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H:%M:%S');
	LET cFechaArchivoOUT	= YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||SUBSTR(cHora,1,2)||SUBSTR(cHora,4,2)||SUBSTR(cHora,7,2)||'_';
	LET iPaso				= 0;
	
	LET viSqlErr = '0';
	LET cRutaIfx = '';
	LET cMensaje = 'ERROR EN PASO: ';

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
		
		INSERT INTO dom_errores(fecha_error,hora_error,cod_error,nombre_arch,sp_llamado,mensaje_error,user_insert,fecha_insert)
			VALUES (CURRENT,CURRENT HOUR TO FRACTION,viSqlErr,p_NombreArchivo,'sp_domi_cop_generaarchivo',cMensaje||iPaso,USER,CURRENT);	
		
            LET v_cod_ret = iSqlErr;
        END IF;

        RETURN v_cod_ret, NULL;
    END EXCEPTION;

	ON EXCEPTION IN(-668) SET iSqlErr
	
	INSERT INTO dom_errores(fecha_error,hora_error,cod_error,nombre_arch,sp_llamado,mensaje_error,user_insert,fecha_insert)
		VALUES (CURRENT,CURRENT HOUR TO FRACTION,viSqlErr,p_NombreArchivo,'sp_domi_cop_generaarchivo',cMensaje||iPaso,USER,CURRENT);	
			
		IF iPaso NOT IN(10,11,12) THEN 
			LET v_cod_ret = iSqlErr;
			RETURN v_cod_ret, NULL;
		END IF;
	END EXCEPTION WITH RESUME;
	

	--SET DEBUG FILE TO "/home/sysdomi/sp_Domi_SubirArchivos.out";
	--TRACE ON;

	--- VALIDA QUE SEA UNA TIPO DE OPERACION AUTOMATICA O MANUAL
	IF UPPER(p_Tipo) NOT IN ("A","M") THEN
		EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00400") INTO v_cod_ret, sDescMensajeError;
		RETURN v_cod_ret, sDescMensajeError;
	END IF

	--- VALIDA QUE LA RUTA SEA NUMERICA
	EXECUTE PROCEDURE sp_valida_cadena(p_CodRuta,"N") INTO v_cod_ret;

	IF v_cod_ret <> "00000" THEN
		EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00610") INTO v_cod_ret, sDescMensajeError;
		RETURN v_cod_ret, sDescMensajeError;
	END IF

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--- OBTIENE LA RUTA DONDE SE ENCUENTRA EL ARCHIVO
	SELECT TRIM(valor)
	INTO sRuta
	FROM bdidomi: dom_parametros
	WHERE cod_param = p_CodRuta;
	
	SELECT TRIM(valor)
	INTO cRutaIfx
	FROM bdidomi: dom_parametros
	WHERE cod_param = "44";
	
	IF NVL(cRutaIfx,'') = ''THEN
		LET cRutaIfx = '/ifxsif01/bin/dbaccess';
	END IF;

	IF p_CodRuta::SMALLINT NOT IN (1,2,3,4) THEN
		EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00402") INTO v_cod_ret, sDescMensajeError;
		RETURN v_cod_ret, sDescMensajeError;
	END IF

	IF sRuta IS NULL THEN
		EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00403") INTO v_cod_ret, sDescMensajeError;
		RETURN v_cod_ret, sDescMensajeError;
	END IF

	--- PARA UNA OPERACION AUTOMATICA
	IF UPPER(p_Tipo) = "A" THEN
		--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
		IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'dom_tmp_trabajo_aut') THEN
			DROP TABLE dom_tmp_trabajo_aut;
		END IF

		--- CREAR LA TABLA DE TRABAJO
		CREATE TABLE dom_tmp_trabajo_aut
		(linea LVARCHAR(500));

		--- GUARDA LOS NOMBRES DE LOS ARCHIVOS EXISTENTES EN LA RUTA EL CARPETA.CAR
		LET iPaso = 1;
		LET sCadSql = 'ls ' || TRIM(sRuta) || ' > ' || TRIM(sRuta) || cFechaArchivoOUT||'.car';
		SYSTEM sCadSql;

		--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
		LET iPaso = 2;
		LET sCadSql = 'echo "LOAD FROM ' || TRIM(sRuta) || cFechaArchivoOUT||'.car' || ' INSERT INTO dom_tmp_trabajo_aut" > '|| TRIM(sRuta) || cFechaArchivoOUT||'.sql';
		SYSTEM sCadSql;

		--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
		LET iPaso = 3;

		LET sCadSql = TRIM(cRutaIfx)||' bdidomi ' || TRIM(sRuta) || cFechaArchivoOUT||'.sql > '||TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
		SYSTEM sCadSql;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--- CICLO PARA BUSCAR EL NOMBRE DEL ARCHIVO
		FOREACH
			SELECT linea
			INTO sLinea
			FROM  dom_tmp_trabajo_aut

			IF sLinea = p_NombreArchivo THEN
				LET bBandArchivo = "t";
				EXIT FOREACH;
			END IF

		END FOREACH

		--- BORRAR LA TABLA PARA VOLVER A USARLA
		TRUNCATE TABLE dom_tmp_trabajo_aut;

		--- VALIDA QUE EL ARCHIVO EXISTA
		IF bBandArchivo = "f" THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00401") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		ELSE
			--Se crea respaldo del archivo a procesar
			LET iPaso = 4;
			LET sCadSql = 'cp ' || TRIM(sRuta) || p_NombreArchivo  ||' '|| TRIM(sRuta)|| p_NombreArchivo  ||'.resp';
			SYSTEM sCadSql;				

			LET iPaso = 5;
			LET sCadSql = 'rm ' || TRIM(sRuta) || p_NombreArchivo;
			SYSTEM sCadSql;
			
			LET iPaso = 6;
			LET sCadSql = 'cp ' || TRIM(sRuta) || p_NombreArchivo  ||'.resp '|| TRIM(sRuta)|| p_NombreArchivo;
			SYSTEM sCadSql;
			
			-- Se reemplazan diagonal por doble diagonal			
			LET iPaso = 9;
		    LET sCadSql = 'grep -lr -e "1" ' || TRIM(sRuta) || p_NombreArchivo  ||'.resp | xargs sed ''s/\\/\\\\/g'' > '|| TRIM(sRuta)|| p_NombreArchivo;
			SYSTEM sCadSql;				
								
			--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
			LET iPaso = 8;
			LET sCadSql = 'echo "LOAD FROM ' || TRIM(sRuta) || p_NombreArchivo || ' INSERT INTO dom_tmp_trabajo_aut" > '|| TRIM(sRuta) || cFechaArchivoOUT||'.sql';
			SYSTEM sCadSql;

			--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
			LET iPaso = 9;
		    LET sCadSql = TRIM(cRutaIfx)|| ' bdidomi ' || TRIM(sRuta) || cFechaArchivoOUT||'.sql > '||TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
		    SYSTEM sCadSql;
			
			LET iPaso = 10;
			LET sCadSql = 'rm ' || TRIM(sRuta) || cFechaArchivoOUT||'.car';
		    SYSTEM sCadSql;
			
			LET iPaso = 11;
			LET sCadSql = 'rm ' || TRIM(sRuta) || cFechaArchivoOUT||'.sql';
		    SYSTEM sCadSql;

			LET iPaso = 12;
			LET sCadSql = 'rm ' || TRIM(sRuta) || cFechaArchivoOUT||'.out';
		    SYSTEM sCadSql;

			LET iPaso = 13;
			LET sCadSql = 'rm ' || TRIM(sRuta) || p_NombreArchivo  ||'.resp';
		    SYSTEM sCadSql;
			
			FOREACH
				--- CUENTA LA LONGITUD DE CARACTERES DE LAS CADENAS EN LA TABLA
				SELECT DISTINCT LENGTH(REPLACE(linea," ","*"))
				INTO iNumCaracteres
				FROM dom_tmp_trabajo_aut

				LET iContador = iContador + 1;
			END FOREACH;
			--- VALIDA QUE NO EXISTAN DIFERENTES LONGITUDES EN LA TABLA
			IF iContador > 1 THEN
				EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00404") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret, sDescMensajeError;
			--- VALLIDA QUE SI EXISTE EL MISMO NUMERO DE CARACTERES POR LINEA ESTE SEA EL ADECUADO
			ELIF iContador = 1 AND iNumCaracteres NOT IN (422,423)  THEN
				EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00404") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret, sDescMensajeError;
			END IF;

			--- VALIDA QUE NO EXISTAN TIPOS DE REGISTROS AJENOS A LOS AUTORIZADOS
			IF EXISTS(SELECT linea FROM bdidomi: dom_tmp_trabajo_aut WHERE SUBSTR(linea,1,2) NOT IN ("01","02","09")) THEN
				SELECT descripcion
				INTO sDescMensajeError
				FROM bdidomi: dom_cat_rechazos
				WHERE cve_rechazo::SMALLINT = 28;

				LET v_cod_ret = "00028";

				RETURN v_cod_ret, sDescMensajeError;
			END IF

			LET iNumReg		= 0;
			--- OBTENER EL NUMERO DE REGISTROS DE ENCABEZADO
			SELECT COUNT(*)::INTEGER
			INTO iNumReg
			FROM  dom_tmp_trabajo_aut
			WHERE SUBSTR(linea,1,2) = "01";

			IF iNumReg = 0 THEN
				EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00409") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret, sDescMensajeError;
			ELIF iNumReg > 1 THEN
				EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00406") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret, sDescMensajeError;
			END IF

			LET iNumReg		= 0;
			--- OBTENER EL NUMERO DE REGISTROS DE SUMARIO
			SELECT COUNT(*)::INTEGER
			INTO iNumReg
			FROM  dom_tmp_trabajo_aut
			WHERE SUBSTR(linea,1,2) = "09";

			IF iNumReg = 0 THEN
				EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00410") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret, sDescMensajeError;
			ELIF iNumReg > 1 THEN
				EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00407") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret, sDescMensajeError;
			END IF

			LET iNumReg		= 0;
			--- OBTENER EL NUMERO DE REGISTROS DE DETALLE
			SELECT COUNT(*)::INTEGER
			INTO iNumReg
			FROM  dom_tmp_trabajo_aut
			WHERE SUBSTR(linea,1,2) = "02";

			IF iNumReg = 0 THEN
				EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00411") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret, sDescMensajeError;
			END IF

			--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
			IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'dom_tmp_secuencia_aut') THEN
				DROP TABLE dom_tmp_secuencia_aut;
			END IF

			--- CREAR LA TABLA DE TRABAJO
			CREATE TABLE dom_tmp_secuencia_aut
			(secuencia CHAR(7));

			INSERT INTO dom_tmp_secuencia_aut
			SELECT  SUBSTR(linea,3,7) AS SECUENCIA
			FROM  bdidomi: dom_tmp_trabajo_aut
			WHERE SUBSTR(linea,1,2) = "02";
			---VERIFICAR QUE NO VENGAN REPETIDOS LOS NUMEROS DE SECUENCIA
			IF EXISTS(SELECT SECUENCIA FROM dom_tmp_secuencia_aut GROUP BY SECUENCIA HAVING COUNT(*) > 1) THEN
				EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00408") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret, sDescMensajeError;
			END IF

			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT linea
				INTO sLinea
				FROM dom_tmp_trabajo_aut

				IF SUBSTR(sLinea,1,2) = "01" THEN --- ASIGNACIONES PARA ENCABEZADO
					LET sEncTipoReg					= SUBSTR(sLinea,1,2);
					LET sEncNumSec					= SUBSTR(sLinea,3,7);
					LET sEncCodOper					= SUBSTR(sLinea,10,2);
					LET sEncBanco					= SUBSTR(sLinea,12,3);
					LET sEncSentido					= SUBSTR(sLinea,15,1);
					LET sEncServicio				= SUBSTR(sLinea,16,1);
					LET sEncNumBloque				= SUBSTR(sLinea,17,7);
					LET sEncFechaPres				= SUBSTR(sLinea,24,8);
					LET sEncCodDivisa				= SUBSTR(sLinea,32,2);
					LET sEncCausaRechazo			= SUBSTR(sLinea,34,2);
					LET sEncModalidad				= SUBSTR(sLinea,36,1);
					LET sEncUsoFuturoCCEN			= SUBSTR(sLinea,37,41);
					LET sEncUsoFuturoBANCO			= SUBSTR(sLinea,78,345);

					--- INSERTA EN LAS TABLAS DE PASO DESPUES DE VALIDAR LOS TIPOS DE CAMPOS
					INSERT INTO dom_cce_encabezado_paso (nombre_arch,fecha_presentacion,tpo_registro,num_secuencia,cod_operacion,cve_banco,sentido,servicio
														,num_bloque,cod_divisa,cve_rechazo_bl,modalidad,uso_futuro_ccen,uso_futuro_banco,user_insert,fecha_insert)
					VALUES (p_NombreArchivo,sEncFechaPres,sEncTipoReg,sEncNumSec,sEncCodOper,sEncBanco,sEncSentido,sEncServicio,sEncNumBloque
							,sEncCodDivisa,sEncCausaRechazo,sEncModalidad,sEncUsoFuturoCCEN,sEncUsoFuturoBANCO,p_Usuario,CURRENT);

				ELIF SUBSTR(sLinea,1,2) = "02" THEN --- ASIGNACIONES PARA DETALLE
					LET sDetTipoReg					= SUBSTR(sLinea,1,2);
					LET sDetNumSec					= SUBSTR(sLinea,3,7);
					LET sDetCodOper					= SUBSTR(sLinea,10,2);
					LET sDetCodDivisa				= SUBSTR(sLinea,12,2);
					LET SDetFechaTrans				= SUBSTR(sLinea,14,8);
					LET sDetBancoPres				= SUBSTR(sLinea,22,3);
					LET sDetBancoRec				= SUBSTR(sLinea,25,3);
					LET sDetImpOperacion			= SUBSTR(sLinea,28,15);
					LET sDetUsoFuturoCCEN			= SUBSTR(sLinea,43,16);
					LET sDetTipoOperacion			= SUBSTR(sLinea,59,2);
					LET sDetFechaApli				= SUBSTR(sLinea,61,8);
					LET sDetTipoCtaOrdenante		= SUBSTR(sLinea,69,2);
					LET sDetNumCtaOrdenante			= SUBSTR(sLinea,71,20);
					LET sDetNombreOrdenante			= SUBSTR(sLinea,91,40);
					LET sDetRFCCURPOrdenante		= SUBSTR(sLinea,131,18);
					LET sDetTipoCtaReceptor			= SUBSTR(sLinea,149,2);
					LET sDetNumCtaReceptor			= SUBSTR(sLinea,151,20);
					LET sDetNombreReceptor			= SUBSTR(sLinea,171,40);
					LET sDetRFCCURPReceptor			= SUBSTR(sLinea,211,18);
					LET sDetRefServEmisor			= SUBSTR(sLinea,229,40);
					LET sDetNomTitularServ			= SUBSTR(sLinea,269,40);
					LET sDetImpIvaOperacion			= SUBSTR(sLinea,309,15);
					LET sDetRefNumOrdenante			= SUBSTR(sLinea,324,7);
					LET sDetRefLeyendaOrdenante  	= SUBSTR(sLinea,331,40);
					LET sDetClaveRastreo			= SUBSTR(sLinea,371,30);
					LET sDetMotivoDev				= SUBSTR(sLinea,401,2);
					LET sDetFecPresInicial			= SUBSTR(sLinea,403,8);
					LET sDetUsoFuturoBanco			= SUBSTR(sLinea,411,12);

					--- INSERTA EN LAS TABLAS DE PASO DESPUES DE VALIDAR LOS TIPOS DE CAMPOS
					INSERT INTO dom_cce_detalle_paso(nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,fecha_trans,banco_presentador
													,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,nombre_ord,rfc_ord
													,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,ref_leyenda
													,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert)
					VALUES (p_NombreArchivo,sEncFechaPres,sDetTipoReg,sDetNumSec,sDetCodOper,sDetCodDivisa,SDetFechaTrans,sDetBancoPres,sDetBancoRec,sDetImpOperacion,sDetUsoFuturoCCEN
							,sDetTipoOperacion,sDetFechaApli,sDetTipoCtaOrdenante,sDetNumCtaOrdenante,sDetNombreOrdenante,sDetRFCCURPOrdenante,sDetTipoCtaReceptor
							,sDetNumCtaReceptor,sDetNombreReceptor,sDetRFCCURPReceptor,sDetRefServEmisor,sDetNomTitularServ,sDetImpIvaOperacion,sDetRefNumOrdenante
							,sDetRefLeyendaOrdenante,sDetClaveRastreo,sDetMotivoDev,sDetFecPresInicial,sDetUsoFuturoBanco,"00","",p_Usuario,CURRENT);

				ELIF SUBSTR(sLinea,1,2) = "09" THEN--- ASIGNACIONES PARA SUMARIO
					LET sSumTipoReg					= SUBSTR(sLinea,1,2);
					LET sSumNumSec					= SUBSTR(sLinea,3,7);
					LET sSumCodOper					= SUBSTR(sLinea,10,2);
					LET sSumNumBloque				= SUBSTR(sLinea,12,7);
					LET sSumNumOper					= SUBSTR(sLinea,19,7);
					LET sSumImpTotOper				= SUBSTR(sLinea,26,18);
					LET sSumUsoFuturoCCEN			= SUBSTR(sLinea,44,40);
					LET sSumUsoFuturoBanco			= SUBSTR(sLinea,84,339);

					--- INSERTA EN LAS TABLAS DE PASO DESPUES DE VALIDAR LOS TIPOS DE CAMPOS
					INSERT INTO dom_cce_sumario_paso (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,num_bloque,num_operaciones
													,imp_operaciones,uso_futuro_ccen,uso_futuro_banco,user_insert,fecha_insert)
					VALUES (p_NombreArchivo,sEncFechaPres,sSumTipoReg,sSumNumSec,sSumCodOper,sSumNumBloque,sSumNumOper,sSumImpTotOper
							,sSumUsoFuturoCCEN,sSumUsoFuturoBanco,p_Usuario,CURRENT);
				END IF;
			END FOREACH;
		END IF;
	--- PARA UNA OPERACION MANUAL

	ELIF UPPER(p_Tipo) = "M" THEN
		--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
		IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'dom_tmp_trabajo_man') THEN
			DROP TABLE dom_tmp_trabajo_man;
		END IF

		--- CREAR LA TABLA DE TRABAJO
		CREATE TABLE dom_tmp_trabajo_man
		(linea LVARCHAR(500));

		--- GUARDA LOS NOMBRES DE LOS ARCHIVOS EXISTENTES EN LA RUTA EL CARPETA.CAR
		LET iPaso = 14;
		LET sCadSql = 'ls ' || TRIM(sRuta) || ' > ' || TRIM(sRuta) || cFechaArchivoOUT||'.car';
		SYSTEM sCadSql;

		--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
		LET iPaso = 15;
		LET sCadSql = 'echo "LOAD FROM ' || TRIM(sRuta) || cFechaArchivoOUT||'.car' || ' INSERT INTO dom_tmp_trabajo_man" > '|| TRIM(sRuta) || cFechaArchivoOUT||'.sql';
		SYSTEM sCadSql;

		--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
		LET iPaso = 16;
		--Produccion
		LET sCadSql = '/ifxsif01/bin/dbaccess bdidomi ' || TRIM(sRuta) || cFechaArchivoOUT||'.sql > '||TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
		
		--Desarrollo
		--LET sCadSql = '/informix/bin/dbaccess bdidomi ' || TRIM(sRuta) || cFechaArchivoOUT||'.sql > '||TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
		SYSTEM sCadSql;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--- CICLO PARA BUSCAR EL NOMBRE DEL ARCHIVO
		FOREACH
			SELECT linea
			INTO sLinea
			FROM  dom_tmp_trabajo_man

			IF sLinea = p_NombreArchivo THEN
				LET bBandArchivo = "t";
				EXIT FOREACH;
			END IF

		END FOREACH

		--- BORRAR LA TABLA PARA VOLVER A USARLA
		TRUNCATE TABLE dom_tmp_trabajo_man;

		--- VALIDA QUE EL ARCHIVO EXISTA
		IF bBandArchivo = "f" THEN
			EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00401") INTO v_cod_ret, sDescMensajeError;
			RETURN v_cod_ret, sDescMensajeError;
		ELSE
		
			--Se crea respaldo del archivo a procesar
			LET iPaso = 17;
			LET sCadSql = 'cp ' || TRIM(sRuta) || p_NombreArchivo  ||' '|| TRIM(sRuta)|| p_NombreArchivo  ||'.resp';
			SYSTEM sCadSql;

			LET iPaso = 18;
			LET sCadSql = 'rm ' || TRIM(sRuta) || p_NombreArchivo;
			SYSTEM sCadSql;
			
			LET iPaso = 19;
			LET sCadSql = 'cp ' || TRIM(sRuta) || p_NombreArchivo  ||'.resp '|| TRIM(sRuta)|| p_NombreArchivo;
			SYSTEM sCadSql;
			
			-- Se reemplaza diagonal por doble diagonal
			LET iPaso = 20;
		    LET sCadSql = 'grep -lr -e "1" ' || TRIM(sRuta) || p_NombreArchivo  ||'.resp | xargs sed ''s/\\/\\\\/g'' > '|| TRIM(sRuta)|| p_NombreArchivo;
			SYSTEM sCadSql;				
					
			--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
			LET iPaso = 21;
			LET sCadSql = 'echo "LOAD FROM ' || TRIM(sRuta) || p_NombreArchivo || ' INSERT INTO dom_tmp_trabajo_man" > '|| TRIM(sRuta) || cFechaArchivoOUT||'.sql';
			SYSTEM sCadSql;

			--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
			LET iPaso = 22;
			--Produccion
		    LET sCadSql = '/ifxsif01/bin/dbaccess bdidomi ' || TRIM(sRuta) || cFechaArchivoOUT||'.sql > '||TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
			--Desarrollo
		    --LET sCadSql = '/informix/bin/dbaccess bdidomi ' || TRIM(sRuta) || cFechaArchivoOUT||'.sql > '||TRIM(sRuta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
		    SYSTEM sCadSql;

			LET iPaso = 23;
			LET sCadSql = 'rm ' || TRIM(sRuta) || cFechaArchivoOUT||'.car';
		    SYSTEM sCadSql;
			
			LET iPaso = 24;
			LET sCadSql = 'rm ' || TRIM(sRuta) || cFechaArchivoOUT||'.sql';
		    SYSTEM sCadSql;

			LET iPaso = 25;
			LET sCadSql = 'rm ' || TRIM(sRuta) || cFechaArchivoOUT||'.out';
		    SYSTEM sCadSql;
			
			LET iPaso = 26;
			LET sCadSql = 'rm ' || TRIM(sRuta) || p_NombreArchivo  ||'.resp';
		    SYSTEM sCadSql;
			
			LET iContador = 0;

			FOREACH
				--- CUENTA LA LONGITUD DE CARACTERES DE LAS CADENAS EN LA TABLA
				SELECT DISTINCT LENGTH(REPLACE(linea," ","*"))
				INTO iNumCaracteres
				FROM dom_tmp_trabajo_man

				LET iContador = iContador + 1;
			END FOREACH
			--- VALIDA QUE NO EXISTAN DIFERENTES LONGITUDES EN LA TABLA
			IF iContador > 1 THEN
				EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00404") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret, sDescMensajeError;
			--- VALLIDA QUE SI EXISTE EL MISMO NUMERO DE CARACTERES POR LINEA ESTE SEA EL ADECUADO
			ELIF iContador = 1 AND iNumCaracteres NOT IN (422,423) THEN
				EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00404") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret, sDescMensajeError;
			END IF

			LET iNumReg		= 0;
			--- OBTENER EL NUMERO DE REGISTROS DE ENCABEZADO
			SELECT COUNT(*)::INTEGER
			INTO iNumReg
			FROM  dom_tmp_trabajo_man
			WHERE SUBSTR(linea,1,2) = "01";

			IF iNumReg = 0 THEN
				EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00409") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret, sDescMensajeError;
			ELIF iNumReg > 1 THEN
				EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00406") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret, sDescMensajeError;
			END IF

			LET iNumReg		= 0;
			--- OBTENER EL NUMERO DE REGISTROS DE SUMARIO
			SELECT COUNT(*)::INTEGER
			INTO iNumReg
			FROM  dom_tmp_trabajo_man
			WHERE SUBSTR(linea,1,2) = "09";

			IF iNumReg = 0 THEN
				EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00410") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret, sDescMensajeError;
			ELIF iNumReg > 1 THEN
				EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00407") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret, sDescMensajeError;
			END IF

			--- VALIDA QUE NO EXISTAN TIPOS DE REGISTROS AJENOS A LOS AUTORIZADOS
			IF EXISTS(SELECT linea FROM bdidomi: dom_tmp_trabajo_man WHERE SUBSTR(linea,1,2) NOT IN ("01","02","09")) THEN
				SELECT descripcion
				INTO sDescMensajeError
				FROM bdidomi: dom_cat_rechazos
				WHERE cve_rechazo::SMALLINT = 28;

				LET v_cod_ret = "00028";

				RETURN v_cod_ret, sDescMensajeError;
			END IF

			LET iNumReg		= 0;
			--- OBTENER EL NUMERO DE REGISTROS DE DETALLE
			SELECT COUNT(*)::INTEGER
			INTO iNumReg
			FROM  dom_tmp_trabajo_man
			WHERE SUBSTR(linea,1,2) = "02";

			IF iNumReg = 0 THEN
				EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00411") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret, sDescMensajeError;
			END IF

			--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
			IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'dom_tmp_secuencia_man') THEN
				DROP TABLE dom_tmp_secuencia_man;
			END IF

			--- CREAR LA TABLA DE TRABAJO
			CREATE TABLE dom_tmp_secuencia_man
			(secuencia CHAR(7));

			INSERT INTO dom_tmp_secuencia_man
			SELECT  SUBSTR(linea,3,7) AS SECUENCIA
			FROM  bdidomi: dom_tmp_trabajo_man
			WHERE SUBSTR(linea,1,2) = "02";
			---VERIFICAR QUE NO VENGAN REPETIDOS LOS NUMEROS DE SECUENCIA
			IF EXISTS(SELECT SECUENCIA FROM dom_tmp_secuencia_man GROUP BY SECUENCIA HAVING COUNT(*) > 1) THEN
				EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("00408") INTO v_cod_ret, sDescMensajeError;
				RETURN v_cod_ret, sDescMensajeError;
			END IF

			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT linea
				INTO sLinea
				FROM dom_tmp_trabajo_man

				IF SUBSTR(sLinea,1,2) = "01" THEN --- ASIGNACIONES PARA ENCABEZADO
					LET sEncTipoReg					= SUBSTR(sLinea,1,2);
					LET sEncNumSec					= SUBSTR(sLinea,3,7);
					LET sEncCodOper					= SUBSTR(sLinea,10,2);
					LET sEncBanco					= SUBSTR(sLinea,12,3);
					LET sEncSentido					= SUBSTR(sLinea,15,1);
					LET sEncServicio				= SUBSTR(sLinea,16,1);
					LET sEncNumBloque				= SUBSTR(sLinea,17,7);
					LET sEncFechaPres				= SUBSTR(sLinea,24,8);
					LET sEncCodDivisa				= SUBSTR(sLinea,32,2);
					LET sEncCausaRechazo			= SUBSTR(sLinea,34,2);
					LET sEncModalidad				= SUBSTR(sLinea,36,1);
					LET sEncUsoFuturoCCEN			= SUBSTR(sLinea,37,41);
					LET sEncUsoFuturoBANCO			= SUBSTR(sLinea,78,345);

					--- INSERTA EN LAS TABLAS DE PASO DESPUES DE VALIDAR LOS TIPOS DE CAMPOS
					INSERT INTO dom_cce_encabezado_paso (nombre_arch,fecha_presentacion,tpo_registro,num_secuencia,cod_operacion,cve_banco,sentido,servicio
														,num_bloque,cod_divisa,cve_rechazo_bl,modalidad,uso_futuro_ccen,uso_futuro_banco,user_insert,fecha_insert)
					VALUES (p_NombreArchivo,sEncFechaPres,sEncTipoReg,sEncNumSec,sEncCodOper,sEncBanco,sEncSentido,sEncServicio,sEncNumBloque
							,sEncCodDivisa,sEncCausaRechazo,sEncModalidad,sEncUsoFuturoCCEN,sEncUsoFuturoBANCO,p_Usuario,CURRENT);

				ELIF SUBSTR(sLinea,1,2) = "02" THEN --- ASIGNACIONES PARA DETALLE
					LET sDetTipoReg					= SUBSTR(sLinea,1,2);
					LET sDetNumSec					= SUBSTR(sLinea,3,7);
					LET sDetCodOper					= SUBSTR(sLinea,10,2);
					LET sDetCodDivisa				= SUBSTR(sLinea,12,2);
					LET SDetFechaTrans				= SUBSTR(sLinea,14,8);
					LET sDetBancoPres				= SUBSTR(sLinea,22,3);
					LET sDetBancoRec				= SUBSTR(sLinea,25,3);
					LET sDetImpOperacion			= SUBSTR(sLinea,28,15);
					LET sDetUsoFuturoCCEN			= SUBSTR(sLinea,43,16);
					LET sDetTipoOperacion			= SUBSTR(sLinea,59,2);
					LET sDetFechaApli				= SUBSTR(sLinea,61,8);
					LET sDetTipoCtaOrdenante		= SUBSTR(sLinea,69,2);
					LET sDetNumCtaOrdenante			= SUBSTR(sLinea,71,20);
					LET sDetNombreOrdenante			= SUBSTR(sLinea,91,40);
					LET sDetRFCCURPOrdenante		= SUBSTR(sLinea,131,18);
					LET sDetTipoCtaReceptor			= SUBSTR(sLinea,149,2);
					LET sDetNumCtaReceptor			= SUBSTR(sLinea,151,20);
					LET sDetNombreReceptor			= SUBSTR(sLinea,171,40);
					LET sDetRFCCURPReceptor			= SUBSTR(sLinea,211,18);
					LET sDetRefServEmisor			= SUBSTR(sLinea,229,40);
					LET sDetNomTitularServ			= SUBSTR(sLinea,269,40);
					LET sDetImpIvaOperacion			= SUBSTR(sLinea,309,15);
					LET sDetRefNumOrdenante			= SUBSTR(sLinea,324,7);
					LET sDetRefLeyendaOrdenante  	= SUBSTR(sLinea,331,40);
					LET sDetClaveRastreo			= SUBSTR(sLinea,371,30);
					LET sDetMotivoDev				= SUBSTR(sLinea,401,2);
					LET sDetFecPresInicial			= SUBSTR(sLinea,403,8);
					LET sDetUsoFuturoBanco			= SUBSTR(sLinea,411,12);

				--- INSERTA EN LAS TABLAS DE PASO DESPUES DE VALIDAR LOS TIPOS DE CAMPOS
				INSERT INTO dom_cce_detalle_paso(nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,fecha_trans,banco_presentador
												,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,nombre_ord,rfc_ord
												,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,ref_leyenda
												,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert)
				VALUES (p_NombreArchivo,sEncFechaPres,sDetTipoReg,sDetNumSec,sDetCodOper,sDetCodDivisa,SDetFechaTrans,sDetBancoPres,sDetBancoRec,sDetImpOperacion,sDetUsoFuturoCCEN
						,sDetTipoOperacion,sDetFechaApli,sDetTipoCtaOrdenante,sDetNumCtaOrdenante,sDetNombreOrdenante,sDetRFCCURPOrdenante,sDetTipoCtaReceptor
						,sDetNumCtaReceptor,sDetNombreReceptor,sDetRFCCURPReceptor,sDetRefServEmisor,sDetNomTitularServ,sDetImpIvaOperacion,sDetRefNumOrdenante
						,sDetRefLeyendaOrdenante,sDetClaveRastreo,sDetMotivoDev,sDetFecPresInicial,sDetUsoFuturoBanco,"00","",p_Usuario,CURRENT);

				ELIF SUBSTR(sLinea,1,2) = "09" THEN--- ASIGNACIONES PARA SUMARIO
					LET sSumTipoReg					= SUBSTR(sLinea,1,2);
					LET sSumNumSec					= SUBSTR(sLinea,3,7);
					LET sSumCodOper					= SUBSTR(sLinea,10,2);
					LET sSumNumBloque				= SUBSTR(sLinea,12,7);
					LET sSumNumOper					= SUBSTR(sLinea,19,7);
					LET sSumImpTotOper				= SUBSTR(sLinea,26,18);
					LET sSumUsoFuturoCCEN			= SUBSTR(sLinea,44,40);
					LET sSumUsoFuturoBanco			= SUBSTR(sLinea,84,339);

					--- INSERTA EN LAS TABLAS DE PASO DESPUES DE VALIDAR LOS TIPOS DE CAMPOS
					INSERT INTO dom_cce_sumario_paso (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,num_bloque,num_operaciones
													,imp_operaciones,uso_futuro_ccen,uso_futuro_banco,user_insert,fecha_insert)
					VALUES (p_NombreArchivo,sEncFechaPres,sSumTipoReg,sSumNumSec,sSumCodOper,sSumNumBloque,sSumNumOper,sSumImpTotOper
							,sSumUsoFuturoCCEN,sSumUsoFuturoBanco,p_Usuario,CURRENT);
				END IF
			END FOREACH
		END IF
	END IF

	RETURN v_cod_ret, sDescMensajeError;


END;
--##############################################################################
--## Procedimiento   : sp_Domi_SubirArchivos
--## Version         : 1.0
--## Creado por      : Mohamed CarreÃÂ³n
--## Fecha creacion  : Julio de 2009
--##Descripcion :  Procedimiento para realizar la carga de los archivos que se reciben a las tablas de informix
--##############################################################################
END PROCEDURE;