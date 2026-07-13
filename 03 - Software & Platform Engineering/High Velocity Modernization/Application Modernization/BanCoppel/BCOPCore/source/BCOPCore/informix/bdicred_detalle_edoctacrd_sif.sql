CREATE PROCEDURE "informix".detalle_edoctacrd_sif(cEmpresa CHAR(3), cNumCredito CHAR(20), pemision CHAR(8))

    RETURNING CHAR(5), DATE, CHAR(50),DECIMAL(14,2), DECIMAL(14,2);


    -- DECLARACION DE VARIABLES --
    DEFINE sSqlErr SMALLINT;
    DEFINE cCodRet CHAR(5);
    DEFINE dFechaDeEmision DATE;
    DEFINE cNumeroCredito CHAR(20);
    DEFINE sSecuencia SMALLINT;
    DEFINE sNumLinea SMALLINT;
    DEFINE dFechaMovimiento DATE;
    DEFINE dcUstedDebia DECIMAL(14,2);
    DEFINE dcMasDisposicion DECIMAL(14,2);
    DEFINE dcMasInteres DECIMAL(14,2);
    DEFINE dcMasIvaInteres DECIMAL(14,2);
    DEFINE dcMenosAbonos DECIMAL(14,2);
    DEFINE dcUstedDebe DECIMAL(14,2);
    DEFINE dcAbonoCapitalVigente DECIMAL(14,2);
    DEFINE dcInteresVigente DECIMAL(14,2);
    DEFINE dcIvaInteresVigente DECIMAL(14,2);
    DEFINE dcAbonoCapitalVencido DECIMAL(14,2);
    DEFINE dcInteresVencido DECIMAL(14,2);
    DEFINE dcIvaInteresVencido DECIMAL(14,2);
    DEFINE cNumeroPago CHAR(9);
    DEFINE sRegistros SMALLINT;
------------------------------------------------
    DEFINE dConcepto CHAR(50);
    DEFINE dCargos   DECIMAL(14,2);
    DEFINE dAbonos   DECIMAL(14,2);
    DEFINE sNumRegistros smallint;  
    DEFINE v_fecha_emision 		DATE ;  



    -- INICIALIZACION DE VARIABLES --
    LET sSqlErr = 0;
    LET cCodRet = '000';
    LET dFechaDeEmision = '';
    LET cNumeroCredito = '';
    LET sSecuencia = 0;
    LET sNumLinea = 0;
    LET dFechaMovimiento = '';
    LET dcUstedDebia = 0;
    LET dcMasDisposicion = 0;
    LET dcMasInteres = 0;
    LET dcMasIvaInteres = 0;
    LET dcMenosAbonos = 0;
    LET dcUstedDebe = 0;
    LET dcAbonoCapitalVigente = 0;
    LET dcInteresVigente = 0;
    LET dcIvaInteresVigente = 0;
    LET dcAbonoCapitalVencido = 0;
    LET dcInteresVencido = 0;
    LET dcIvaInteresVencido = 0;
    LET cNumeroPago = '';
    LET sRegistros = 0;
-----------------------------------------
    LET dConcepto = "";
    LET dCargos   = 0;
    LET dAbonos   = 0;
    LET sNumRegistros = 0;
    LET v_fecha_emision  = " ";
    --SET DEBUG FILE TO "/tmp/detalle_edoctacrd.out";
    --TRACE ON;

    BEGIN
        ON EXCEPTION SET sSqlErr
            LET cCodRet = sSqlErr;
            RETURN cCodRet, dFechaMovimiento,dConcepto,dCargos,dAbonos;
        END EXCEPTION;

        -- Generación de los Detalles de Movimientos del Estado de Cuenta

    LET v_fecha_emision = MDY(SUBSTR(pEmision,1,2),SUBSTR(pEmision,3,2),SUBSTR(pEmision,5,4));


        FOREACH
            SELECT fecha_emision, num_credito, secuencia, nlinea, fecha_mov,
                   concepto, cargos, abonos
            INTO dFechaDeEmision, cNumeroCredito, sSecuencia, sNumLinea, dFechaMovimiento,
                 dConcepto, dCargos, dAbonos
            FROM sd_detalle_edoctacrd
            WHERE fecha_emision = v_fecha_emision AND num_credito = cNumCredito
            ORDER BY secuencia, nlinea

            LET sRegistros = sRegistros + 1;
            IF sRegistros <= sNumRegistros THEN
                CONTINUE FOREACH;
            END IF

            IF cNumeroCredito IS NULL THEN
                LET cCodRet = '185';
                RETURN cCodRet, dFechaMovimiento,dConcepto,dCargos,dAbonos;
            END IF

            RETURN cCodRet,NVL(dFechaMovimiento, ""), NVL(dConcepto, 0), NVL(dCargos, 0), NVL(dAbonos, 0)
              WITH RESUME;
        END FOREACH
    END;
END PROCEDURE
DOCUMENT
"Genera el Detalle de los Movimientos del Estado de Cuenta de Crédito Reestructurado",
"AUTOR: Iris Arias Zazueta",
"FECHA: 06/08/2009",
"BD: bdicred";

CREATE PROCEDURE "informix".aclaraciones_edoctacrd_sif(cEmpresa CHAR(3), cNumCredito CHAR(20), pemision CHAR(8))

    RETURNING CHAR(5), DATE, CHAR(16), DATE, CHAR(50),DECIMAL(14,2);

    -- DECLARACION DE VARIABLES --
    DEFINE sSqlErr SMALLINT;
    DEFINE cCodRet CHAR(5);
    DEFINE dFechaDeEmision DATE;
    DEFINE cNumeroCredito CHAR(20);
    DEFINE sSecuencia SMALLINT;
    DEFINE sNumLinea SMALLINT;
    DEFINE dFechaMovimiento DATE;
    DEFINE dfecha_aclara    DATE;
    DEFINE dfolio           CHAR(16);
    DEFINE dcUstedDebia DECIMAL(14,2);
    DEFINE dcMasDisposicion DECIMAL(14,2);
    DEFINE dcMasInteres DECIMAL(14,2);
    DEFINE dcMasIvaInteres DECIMAL(14,2);
    DEFINE dcMenosAbonos DECIMAL(14,2);
    DEFINE dcUstedDebe DECIMAL(14,2);
    DEFINE dcAbonoCapitalVigente DECIMAL(14,2);
    DEFINE dcInteresVigente DECIMAL(14,2);
    DEFINE dcIvaInteresVigente DECIMAL(14,2);
    DEFINE dcAbonoCapitalVencido DECIMAL(14,2);
    DEFINE dcInteresVencido DECIMAL(14,2);
    DEFINE dcIvaInteresVencido DECIMAL(14,2);
    DEFINE cNumeroPago CHAR(9);
    DEFINE sRegistros SMALLINT;
------------------------------------------------
    DEFINE dConcepto CHAR(50);
    DEFINE dimporte   DECIMAL(14,2);
    DEFINE dAbonos   DECIMAL(14,2);
    DEFINE sNumRegistros smallint;  
    DEFINE v_fecha_emision 		DATE ;  



    -- INICIALIZACION DE VARIABLES --
    LET sSqlErr = 0;
    LET cCodRet = '000';
    LET dFechaDeEmision = '';
    LET cNumeroCredito = '';
    LET sSecuencia = 0;
    LET sNumLinea = 0;
    LET dFechaMovimiento = '';
    LET dfecha_aclara = '';
    LET dfolio        = '';
    LET dcUstedDebia = 0;
    LET dcMasDisposicion = 0;
    LET dcMasInteres = 0;
    LET dcMasIvaInteres = 0;
    LET dcMenosAbonos = 0;
    LET dcUstedDebe = 0;
    LET dcAbonoCapitalVigente = 0;
    LET dcInteresVigente = 0;
    LET dcIvaInteresVigente = 0;
    LET dcAbonoCapitalVencido = 0;
    LET dcInteresVencido = 0;
    LET dcIvaInteresVencido = 0;
    LET cNumeroPago = '';
    LET sRegistros = 0;
-----------------------------------------
    LET dConcepto = "";
    LET dimporte   = 0;
    LET dAbonos   = 0;
    LET sNumRegistros = 0;
    LET v_fecha_emision  = " ";
--    SET DEBUG FILE TO "/pisa/leo/aclaraciones_edoctacrd.out";
--    TRACE ON;

    BEGIN
        ON EXCEPTION SET sSqlErr
            LET cCodRet = sSqlErr;
            RETURN cCodRet, dfecha_aclara,dfolio, dFechaMovimiento,dConcepto,dimporte;
        END EXCEPTION;

        -- Generación de los Detalles de Movimientos del Estado de Cuenta

    LET v_fecha_emision = MDY(SUBSTR(pEmision,1,2),SUBSTR(pEmision,3,2),SUBSTR(pEmision,5,4));


        FOREACH
            SELECT fecha_emision, num_credito,     secuencia, nlinea,     fecha_aclara,folio_suc,fecha_mov,       descripcion,importe
            INTO dFechaDeEmision, cNumeroCredito, sSecuencia, sNumLinea, dfecha_aclara,dfolio,   dFechaMovimiento,dConcepto,   dimporte
            FROM sd_aclaraciones_edoctacrd
            WHERE fecha_emision = v_fecha_emision AND num_credito = cNumCredito
            ORDER BY secuencia, nlinea

            LET sRegistros = sRegistros + 1;
            IF sRegistros <= sNumRegistros THEN
                CONTINUE FOREACH;
            END IF

            IF cNumeroCredito IS NULL THEN
                LET cCodRet = '185';
                RETURN cCodRet, dfecha_aclara,dfolio, dFechaMovimiento,dConcepto,dimporte;
            END IF

            RETURN cCodRet,NVL(dfecha_aclara,""),nvl(dfolio,""),NVL(dFechaMovimiento, ""), NVL(dConcepto, 0), NVL(dimporte, 0)
              WITH RESUME;
        END FOREACH
    END;
END PROCEDURE
DOCUMENT
"Genera el Detalle de los Movimientos del Estado de Cuenta de Crédito Reestructurado",
"AUTOR: Iris Arias Zazueta",
"FECHA: 06/08/2009",
"BD: bdicred";

CREATE PROCEDURE "informix".sp_consultacredbloqfallecimiento(pNumcte CHAR(20), pNumcredito CHAR(20), pFechainicial CHAR(10), pFechafinal CHAR (10))

--PARAMETROS QUE DEVUELVE
RETURNING
CHAR(6)        AS CODIGO_RETORNO,      --Codigo de Retorno
CHAR(80)       AS MENSAJE,             --Mensaje Descriptivo
CHAR(20)       AS NUM_CTE,             --Numero de cliente
CHAR(26)       AS APELL_PATERNO,       --Apellido Paterno
CHAR(26)       AS APELL_MATERNO,       --Apellido Materno
CHAR(26)       AS NOMBRE,              --Nombre 1
CHAR(26)       AS NOMBRE2,             --Nombre 2
CHAR(20)       AS NUM_CREDITO,         --Numero de Crédito
DATE           AS FECHA_BLOQUEO,       --Fecha de Bloqueo de la cuenta
CHAR(2)        AS STATUS,              --Status de la cuenta en número
CHAR(60)       AS DESCRIPCION,         --Descripcion del estatus de la cuenta
DECIMAL (18,2) AS CAPITAL_VIGENTE,     --Capital Vigente o saldo capital
DECIMAL (18,2) AS CAPITAL_VENCIDO,     --Capital Vencido o monto vencido traspasado
DECIMAL (18,2) AS VENCIDO_NO_EXIGIBLE, --Capital Vencido no exigible 
DECIMAL (18,2) AS TRANSITORIO,         --Transitorio o monto vencido
DECIMAL (18,2) AS TOTAL_QUEBRANTADO;    --Total quebrantado

---DECLARACION DE VARIABLES
DEFINE cCodret				  CHAR(6);
DEFINE cMensaje				  CHAR(80);
DEFINE iSql_err				  INTEGER; 
DEFINE iIsamErr               INTEGER;
DEFINE cErrorInfo             CHAR(80);
DEFINE cNumcte				  CHAR(20);
DEFINE cApell_paterno		  CHAR(26);
DEFINE cApell_materno		  CHAR (26);
DEFINE cNombre1               CHAR (26);
DEFINE cNombre2               CHAR (26);
DEFINE cNum_credito           CHAR (20);
DEFINE dFecha_bloqueo         DATE;
DEFINE cStatus                CHAR(2);
DEFINE cDescripcion           CHAR(60);
DEFINE dCapital_Vigente       DECIMAL (18, 2);
DEFINE dCapital_Vencido       DECIMAL (18, 2);
DEFINE dVencido_No_Exigible   DECIMAL (18, 2);
DEFINE dTransitorio           DECIMAL (18, 2);
DEFINE dTotal_Quebrantado     DECIMAL (18, 2);
DEFINE cCod_caract_2          CHAR(20);
DEFINE ibandera               INTEGER;

--INICIALIZACION DE VARIABLES
LET cCodret                = '000000';
LET cMensaje               = 'EJECUCION EXITOSA';
LET iIsamErr               = 0 ;
LET iSql_err               = 0 ;  
LET cErrorInfo             = '' ;
LET cNumcte                = '' ;
LET cApell_paterno         = '' ;
LET cApell_materno         = '' ;
LET cNombre1               = '' ;
LET cNombre2               = '' ;
LET cNum_credito           = ''; 
LET dFecha_bloqueo         = DATE(1);
LET cStatus                = '' ;
LET cDescripcion           = '' ;
LET dCapital_Vigente       = 0.00 ; 
LET dCapital_Vencido       = 0.00 ;
LET dVencido_No_Exigible   = 0.00 ;
LET dTransitorio           = 0.00 ;
LET dTotal_Quebrantado     = 0.00 ;
LET cCod_caract_2          = '';
LET ibandera               = 0;

--INICIO--
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err , iIsamErr, cErrorInfo
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			LET cMensaje = cErrorInfo;
			RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(NVL(cNumcte, '')), TRIM(NVL(cApell_paterno, '')), TRIM(NVL(cApell_materno, '')), TRIM(NVL(cNombre1, '')),TRIM(NVL(cNombre2, '')), TRIM(NVL(cNum_credito, '')), NVL(dFecha_bloqueo,'01-01-1900'),TRIM(NVL(cStatus, '')), TRIM(NVL(cDescripcion, '')), NVL(dCapital_Vigente, 0.00), NVL(dCapital_Vencido, 0.00), NVL(dVencido_No_Exigible, 0.00), NVL(dTransitorio, 0.00), NVL(dTotal_Quebrantado, 0.00);
		END IF;
	END EXCEPTION;
		
	 --SET DEBUG FILE TO '/dbexportb/carlos/sp_consultacredbloqfallecimiento.out';
     --TRACE ON;
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;

	---CONTROL DE ERRORES EN CASO QUE NO SE PROPORCIONE NINGÚN PARÁMETRO--
	IF NVL(pNumcte, '') = '' AND NVL(pNumcredito, '') = '' AND NVL(pFechainicial, '') = '' AND NVL(pFechafinal, '') = ''  THEN
		LET cCodret  = '110';
		LET cMensaje = 'ERROR EN LOS PARAMETROS';
		RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(NVL(cNumcte, '')), TRIM(NVL(cApell_paterno,'')), TRIM(NVL(cApell_materno,'')), TRIM(NVL(cNombre1, '')), TRIM(NVL(cNombre2, '')), TRIM(NVL(cNum_credito, '')), NVL(dFecha_bloqueo, '01-01-1900'), NVL(cStatus, ''), NVL(cDescripcion, ''), NVL(dCapital_Vigente, 0.00), NVL(dCapital_Vencido, 0.00), NVL(dVencido_No_Exigible, 0.00), NVL(dTransitorio, 0.00), NVL(dTotal_Quebrantado, 0.00);
	END IF;

---------------BLOQUE DE CONSULTA POR NÚMERO DE CLIENTE---------------
	IF pNumcte <> ''  AND NVL(pNumcredito, '') = '' AND NVL(pFechainicial, '') = '' AND NVL(pFechafinal, '') = ''  THEN		
	
		FOREACH
			--SE OBTIENE EL NÚMERO DE CRÉDITO Y EL ESTATUS CREDITICIO USANDO EL NUMERO DE CLIENTE
			SELECT TRIM(num_credito), TRIM(status_cred), TRIM(cod_caract_2)
			INTO cNum_credito, cStatus, cCod_caract_2
			FROM "informix".sd_maecred
			WHERE numcte = pNumcte
			ORDER BY num_credito
			
			--VERIFICA SI EL NÚMERO DE CRÉDITO ESTA  DADO DE ALTA COMO 04 (BLOQUEADO POR FALLECIMIENTO)
			IF NVL(cCod_caract_2, '') <> '04' THEN
				CONTINUE FOREACH;			
			END IF;
			
			LET ibandera = 1;
			
			--SELECCIONA LA FECHA DE BLOQUEO MÁS ACTUAL DE LA CUENTA SELECCIONADA
			SELECT fecha
			INTO dFecha_bloqueo
			FROM "informix".sd_bitacorabloqueocta a
			WHERE a.cuenta = TRIM(cNum_credito)
			AND a.tipo_movimiento = 'B'
			AND a.cve_causa = TRIM(cCod_caract_2)
			AND a.id = (SELECT MAX(b.id) FROM "informix".sd_bitacorabloqueocta b WHERE b.cuenta = TRIM(cNum_credito)
			AND b.tipo_movimiento = 'B'
			AND b.cve_causa = TRIM(cCod_caract_2));
			
			--SELECCIONA LOS MONTOS DE LA CUENTA
			SELECT sdo_capital, mto_venc_trasp, cap_tras_no_venci, monto_vencido
			INTO dCapital_Vigente, dCapital_Vencido, dVencido_No_Exigible, dTransitorio
			FROM "informix".sd_maesdos
			WHERE num_credito = TRIM(cNum_credito);
			
			--SELECCIONA LOS DATOS PERSONALES DEL TITULAR DE LA CUENTA
			SELECT TRIM(nombre1), TRIM(nombre2), TRIM(apell_paterno), TRIM(apell_materno)
			INTO cNombre1, cNombre2, cApell_paterno, cApell_materno
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = TRIM(pNumcte);
			
			--OBTIENE LA DESCRIPCION DEL ESTATUS CREDITICIO
			SELECT TRIM(descripcion)
			INTO cDescripcion
			FROM "informix".sd_tipocartera
			WHERE status_cred = TRIM(cStatus);
						  
			--HACE EL CÁLCULO DEL TOTAL QUEBRANTADO USANDO LOS SALDOS OBTENIDOS PREVIAMENTE			  
			LET dTotal_Quebrantado = dCapital_Vigente + dCapital_Vencido + dVencido_No_Exigible + dTransitorio;
			
			--REGRESA EL CONJUNTO DE DATOS OBTENIDOS
			RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(pNumcte), TRIM(cApell_paterno), TRIM(cApell_materno), TRIM(cNombre1), TRIM(cNombre2), TRIM(cNum_credito), dFecha_bloqueo, TRIM(cStatus), TRIM(cDescripcion), NVL(dCapital_Vigente, 0.00), NVL(dCapital_Vencido, 0.00), NVL(dVencido_No_Exigible, 0.00), NVL(dTransitorio, 0.00), NVL(dTotal_Quebrantado, 0.00) WITH RESUME;
					
	 	END FOREACH;
		
        --SI LA CONSULTA NO DEVUELVE NINGÚN RESULTADO MANDA EL SIGUIENTE CODIGO DE RETORNO, MENSAJE Y DATOS.		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			LET cCodret = '433';
			LET cMensaje = 'EL CLIENTE NO EXISTE EN LA BASE DE DATOS';
			RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(NVL(cNumcte, '')), TRIM(NVL(cApell_paterno, '')), TRIM(NVL(cApell_materno, '')), TRIM(NVL(cNombre1, '')), TRIM(NVL(cNombre2, '')), TRIM(NVL(cNum_credito, '')), NVL(dFecha_bloqueo, '01-01-1900'), NVL(cStatus, ''), NVL(cDescripcion, ''), NVL(dCapital_Vigente, 0.00), NVL(dCapital_Vencido, 0.00), NVL(dVencido_No_Exigible, 0.00), NVL(dTransitorio, 0.00), NVL(dTotal_Quebrantado, 0.00);
		
		--SI EL NUMERO DE CLIENTE USADO EXISTE PERO NO TIENE CRÉDITOS, O NO TIENE CRÉDITOS BLOQUEADOS POR FALLECIMIENTO
		ELIF ibandera = 0 THEN
			LET cCodret = '434';
			LET cMensaje = 'EL CLIENTE NO CUENTA CON CREDITOS BLOQUEADOS POR FALLECIMIENTO';
			RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(NVL(cNumcte, '')), TRIM(NVL(cApell_paterno, '')), TRIM(NVL(cApell_materno, '')), TRIM(NVL(cNombre1, '')), TRIM(NVL(cNombre2, '')), TRIM(NVL(cNum_credito, '')), NVL(dFecha_bloqueo, '01-01-1900'), NVL(cStatus, ''), NVL(cDescripcion, ''), NVL(dCapital_Vigente, 0.00), NVL(dCapital_Vencido, 0.00), NVL(dVencido_No_Exigible, 0.00), NVL(dTransitorio, 0.00), NVL(dTotal_Quebrantado, 0.00);		
		END IF
		
---------------BLOQUE DE CONSULTA POR NÚMERO DE CRÉDITO---------------
	ELIF pNumcredito <> '' AND NVL(pNumcte, '') = '' AND NVL(pFechainicial, '') = '' AND NVL(pFechafinal, '') = ''  THEN 
	--SE OBTIENE EL NÚMERO DE CLIENTE Y ESTATUS CREDITICIO USANDO EL NUMERO DE CRÉDITO
		SELECT  num_credito, numcte, status_cred, TRIM(cod_caract_2)
		INTO cNum_credito, cNumcte, cStatus, cCod_caract_2
		FROM "informix".sd_maecred 
		WHERE num_credito = TRIM(pNumcredito);
		
		--SI LA CONSULTA NO DEVUELVE NINGÚN RESULTADO MANDA EL SIGUIENTE CODIGO DE RETORNO, MENSAJE Y DATOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret= '432';
			LET cMensaje = 'EL NUMERO DE CREDITO NO EXISTE EN LA BASE DE DATOS';
			RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(NVL(cNumcte, '')), TRIM(NVL(cApell_paterno, '')), TRIM(NVL(cApell_materno,'')), TRIM(NVL(cNombre1, '')),TRIM(NVL(cNombre2, '')), TRIM(NVL(cNum_credito, '')), NVL(dFecha_bloqueo,'01-01-1900'), NVL(cStatus, ''), NVL(cDescripcion, ''), NVL(dCapital_Vigente, 0.00), NVL(dCapital_Vencido, 0.00), NVL(dVencido_No_Exigible, 0.00), NVL(dTransitorio, 0.00), NVL(dTotal_Quebrantado, 0.00);
		
		--SI EL NUMERO DE CRÉDITO USADO EXISTE PERO NO ESTA BLOQUEADO POR FALLECIMIENTO
		ELIF NVL(cCod_caract_2, '') <> '04' THEN
			LET cCodret= '434';
			LET cMensaje = 'EL NUMERO DE CREDITO NO SE ENCUENTRA BLOQUEADO POR FALLECIMIENTO';
			RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(NVL(cNumcte, '')), TRIM(NVL(cApell_paterno, '')), TRIM(NVL(cApell_materno,'')), TRIM(NVL(cNombre1, '')),TRIM(NVL(cNombre2, '')), TRIM(NVL(cNum_credito, '')), NVL(dFecha_bloqueo,'01-01-1900'), NVL(cStatus, ''), NVL(cDescripcion, ''), NVL(dCapital_Vigente, 0.00), NVL(dCapital_Vencido, 0.00), NVL(dVencido_No_Exigible, 0.00), NVL(dTransitorio, 0.00), NVL(dTotal_Quebrantado, 0.00);		
		END IF;
        
		--SELECCIONA LA FECHA DE BLOQUEO
		SELECT fecha
		INTO dFecha_bloqueo
		FROM "informix".sd_bitacorabloqueocta a
		WHERE a.cuenta = TRIM(cNum_credito)
		AND a.tipo_movimiento = 'B'
		AND a.cve_causa = TRIM(cCod_caract_2)
		AND a.id = (SELECT MAX(b.id) FROM "informix".sd_bitacorabloqueocta b WHERE b.cuenta = TRIM(cNum_credito)
		AND b.tipo_movimiento = 'B'
		AND b.cve_causa = TRIM(cCod_caract_2));
        
		--OBTIENE LOS MONTOS DE LA CUENTA
		SELECT sdo_capital, mto_venc_trasp, cap_tras_no_venci, monto_vencido
		INTO dCapital_Vigente, dCapital_Vencido, dVencido_No_Exigible, dTransitorio
		FROM "informix".sd_maesdos 
		WHERE num_credito = TRIM(cNum_credito);
		
		--OBTIENE LOS DATOS PERSONALES DEL TITULAR DEL CRÉDITO
		SELECT nombre1, nombre2, apell_paterno, apell_materno
		INTO cNombre1, cNombre2, cApell_paterno, cApell_materno
		FROM bdinteg:"informix".si_cliente
		WHERE numcte= TRIM(cNumcte);

		--OBTIENE LA DESCRIPCIÓN CORRESPONDIENTE AL ESTATUS CREDITICIO OBTENIDO
		SELECT TRIM(descripcion)
		INTO cDescripcion
		FROM "informix".sd_tipocartera
		WHERE status_cred = TRIM(cStatus);
		
        --HACE EL CÁLCULO DEL TOTAL QUEBRANTADO USANDO LOS SALDOS OBTENIDOS PREVIAMENTE			
		LET dTotal_Quebrantado = dCapital_Vigente + dCapital_Vencido + dVencido_No_Exigible + dTransitorio;

		--REGRESA EL CONJUNTO DE DATOS OBTENIDOS
		RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(cNumcte), TRIM(cApell_paterno), TRIM(cApell_materno), TRIM(cNombre1), TRIM(cNombre2), TRIM(cNum_credito), dFecha_bloqueo, TRIM(cStatus), TRIM(cDescripcion), NVL(dCapital_Vigente, 0.00), NVL(dCapital_Vencido, 0.00), NVL(dVencido_No_Exigible, 0.00), NVL(dTransitorio, 0.00), NVL(dTotal_Quebrantado, 0.00) WITH RESUME;
				 
---------------BLOQUE DE CONSULTA POR RANGO DE FECHAS---------------
	ELIF pFechainicial IS NOT NULL AND pFechafinal IS NOT NULL AND NVL(pNumcte, '') = '' AND NVL(pNumcredito, '') = '' THEN
		FOREACH
		    --SELECCIONA LOS NÚMEROS DE CRÉDITO QUE SE ENCUENTRAN ENTRE EL RANGO DE FECHA SIEMPRE Y CUANDO ESTEN BLOQUEADOS Y LA CAUSA DE BLOQUEO SEA POR FALLECIMIENTO
			SELECT DISTINCT cta.cuenta,fecha, TRIM(numcte), TRIM(status_cred)
			INTO cNum_credito, dFecha_bloqueo,cNumcte, cStatus
			FROM "informix".sd_bitacorabloqueocta  cta
			INNER JOIN "informix".sd_maecred mae ON (mae.empresa = '001' AND mae.num_credito= cta.cuenta and mae.cod_caract_2 = cta.cve_causa )
			WHERE cta.fecha BETWEEN TO_DATE(pFechainicial,'%Y/%m/%d') AND TO_DATE(pFechafinal,'%Y/%m/%d')
			AND cta.tipo_movimiento = 'B'
			AND cta.cve_causa = TRIM('04')
			AND cta.id = (SELECT MAX(b.id) FROM "informix".sd_bitacorabloqueocta b 
							WHERE b.cuenta = cta.cuenta)
			GROUP BY 1,2,3,4
			ORDER BY 2 DESC
			
			
			--OBTIENE LOS MONTOS CORRESPONDIENTES A LAS CUENTAS
			SELECT sdo_capital, mto_venc_trasp, cap_tras_no_venci, monto_vencido
			INTO dCapital_Vigente, dCapital_Vencido, dVencido_No_Exigible, dTransitorio
			FROM "informix".sd_maesdos 
			WHERE num_credito = TRIM(cNum_credito);
			
			--OBTIENE LOS DATOS PERSONALES DE LOS TITULARES DE LA CUENTA
			SELECT nombre1, nombre2, apell_paterno, apell_materno
			INTO cNombre1, cNombre2, cApell_paterno, cApell_materno
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = TRIM(cNumcte);

			--SELECCIONA LAS DESCRIPCIÓNES CORRESPONDIENTE A LOS ESTATUS CREDITICIOS 
			SELECT TRIM(descripcion)
			INTO cDescripcion
			FROM "informix".sd_tipocartera
			WHERE status_cred = TRIM(cStatus);		
			
            --HACE EL CÁLCULO DEL TOTAL QUEBRANTADO USANDO LOS SALDOS OBTENIDOS PREVIAMENTE				
			LET dTotal_Quebrantado = dCapital_Vigente + dCapital_Vencido + dVencido_No_Exigible + dTransitorio;
			
            --REGRESA EL CONJUNTO DE DATOS OBTENIDOS
			RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(cNumcte), TRIM(cApell_paterno), TRIM(cApell_materno), TRIM(cNombre1), TRIM(cNombre2), TRIM(cNum_credito), dFecha_bloqueo, TRIM(cStatus), TRIM(cDescripcion), NVL(dCapital_Vigente, 0.00), NVL(dCapital_Vencido, 0.00), NVL(dVencido_No_Exigible, 0.00), NVL(dTransitorio, 0.00), NVL(dTotal_Quebrantado, 0.00) WITH RESUME;
		END FOREACH;	
		
		--SI LA CONSULTA NO DEVUELVE NINGÚN RESULTADO MANDA EL SIGUIENTE CODIGO DE RETORNO, MENSAJE Y DATOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '434';
			LET cMensaje = 'NO HAY DATOS PARA MOSTRAR EN EL RANGO DE FECHA SELECCIONADO';
			RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(NVL(cNumcte, '')), TRIM(NVL(cApell_paterno, '')), TRIM(NVL(cApell_materno, '')), TRIM(NVL(cNombre1, '')), TRIM(NVL(cNombre2, '')), TRIM(NVL(cNum_credito, '')), NVL(dFecha_bloqueo, '01-01-1900'), NVL(cStatus, ''), NVL(cDescripcion, ''), NVL(dCapital_Vigente, 0.00), NVL(dCapital_Vencido, 0.00), NVL(dVencido_No_Exigible, 0.00), NVL(dTransitorio, 0.00), NVL(dTotal_Quebrantado, 0.00);
		END IF	 
	END IF
 END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÓN: PROCEDURE QUE HACE CONSULTA DE LOS CRÉDITOS QUEBRANTADOS POR FALLECIMIENTO A TRAVÉS DE 3 DIFERENTES FILTROS O CRITERIOS(NUMERO DE CLIENTE,NUMERO DE CRÉDITO,RANGO DE FECHA) ', 
'FECHA DE CREACIÓN: 21 de Noviembre del 2012',
'BASE DE DATOS: BDICRED',
'CREADOR: CARLOS OCHOA',
'VERSION: 20121121.1659';

CREATE PROCEDURE "informix".sp_cac_obtencausastatusaumlincred
(
pEmpresa CHAR(3), 
pStatus CHAR(2)
)
RETURNING
CHAR(6) 	AS COD_RET,
CHAR(80) 	AS MENSAJE_RET,
CHAR(3) 	AS CAUSA_STATUS,
CHAR(100) 	AS DESC_CAUSA;

---DECLARACIONES
DEFINE iSqlErr         	INTEGER;
DEFINE iIsamErr        	INTEGER;
DEFINE cCodRet        	CHAR(6);
DEFINE cCausa			CHAR(3);
DEFINE cDescCausa		CHAR(100);
DEFINE cMensajeRet		CHAR(80);
DEFINE iContador       	INTEGER;
---INICIALIZACIONES
LET iSqlErr            	= 0;
LET iIsamErr           	= 0;
LET cCodRet            	= '000000';
LET cMensajeRet        	= 'Proceso exitoso';
LET cCausa				= '';
LET cDescCausa			= '';
LET iContador			= 0;

BEGIN    
    ON EXCEPTION SET iSqlErr, iIsamErr, cMensajeRet
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet,cMensajeRet,NULL,NULL;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	---SET DEBUG FILE TO "/home/sysifx/has/sp_cac_obtencausastatusaumlincred.out";
	---TRACE ON;
	
	-- pBandAumLinCred = 1 (BANDERA ACTIVADA, MUESTRA SOLAMENTE LAS CAUSAS RELACIONADAS PARA EL AUMENTO )
	-- pBandAumLinCred = 0 (BANDERA DE AUMENTO DE LINEA DE CREDITO DESACTIVADA)
	
	IF NVL(pEmpresa,'') = '' OR NVL(pStatus,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'FALTAN UNO O MAS PARAMETROS';
	ELSE
		IF NOT EXISTS (SELECT empresa FROM bdinteg:'informix'.si_empresas WHERE empresa = pEmpresa) THEN
			LET cCodRet = '000002';
			LET cMensajeRet = 'PARAMETRO DE EMPRESA NO ES VALIDO';
		ELSE
			IF NOT EXISTS (SELECT status FROM bdicred:'informix'.sd_status_aumlincred WHERE empresa = pEmpresa AND status = pStatus) THEN
		        LET cCodRet = '000003';
				LET cMensajeRet = 'ESTATUS NO ES VALIDO PARA EL CATALOGO DE STATUS DE INCREMENTO DE LINEA';
			ELSE
				FOREACH 
					SELECT causa_status, descripcion
					INTO cCausa, cDescCausa
					FROM bdicred:'informix'.sd_causas_aumlincred 
					WHERE empresa = pEmpresa
					AND status = pStatus
					AND causa_status = causa_status
					AND incremento = 1
					LET iContador = iContador + 1;
					RETURN cCodRet,cMensajeRet,cCausa,cDescCausa  WITH RESUME;	
				END FOREACH
				
			    IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			        LET cCodRet = '000004';
					LET cMensajeRet = 'NO HAY REGISTROS PARA EL ESTATUS EN EL CATALOGO DE CAUSAS DE INCREMENTO DE LINEA';
					
			    END IF
			END IF
		END IF
	END IF
    IF iContador = 0 THEN
		RETURN cCodRet,cMensajeRet,cCausa,cDescCausa;
	END IF;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: PROCEDIMIENTO PARA OBTENER LAS CAUSAS PERTENECIENTES A LOS STATUS DE AUMENTO DE LINEA DE CREDITO', 
'AUTOR: Mohamed Carreón ',
'FECHA: Septiembre 2010',
'VERSION: 20111107.1105';

CREATE PROCEDURE "informix".sp_cac_obtenstatusaumlincred(pEmpresa     CHAR(3),
                                                          pStatus      CHAR(2),
														  pDescripcion VARCHAR(50,1))
														  
RETURNING CHAR(6)           AS cod_ret,
          VARCHAR(100,1)    AS mensaje_ret,
          CHAR(2)           AS status,
          VARCHAR(50,1)     AS descripcion;

DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cErrorInfo      VARCHAR(255,1);
DEFINE cCodRet         CHAR(6);
DEFINE cMensajeRet     VARCHAR(100,1);
DEFINE cEmpresa        CHAR(3);
DEFINE cStatus         CHAR(2);
DEFINE cDescripcion    VARCHAR(50,1);
DEFINE iNumReg         INTEGER;

LET iSqlErr            = 0;
LET iIsamErr           = 0;
LET cErrorInfo         = "";
LET cCodRet            = "000000";
LET cMensajeRet        = "Consulta exitosa";
LET cEmpresa           = "";
LET cStatus            = "";
LET cDescripcion       = "";
LET iNumReg            = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet     = iSqlErr;
	 LET cMensajeRet = cErrorInfo;
     RETURN cCodRet,cMensajeRet,cStatus,cDescripcion;
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/home/sysifx/paulq/sp_cac_obtenstatusaumlincred.out';
--TRACE ON;

IF pStatus IS NULL THEN
 LET pStatus = "";
END IF;

IF pDescripcion IS NULL THEN
 LET pDescripcion = "";
END IF;

FOREACH WITH HOLD

   SELECT status, descripcion
     INTO cStatus, cDescripcion
     FROM "informix".sd_status_aumlincred
	WHERE status      = (CASE WHEN pStatus = "" THEN status ELSE pStatus END)
	  AND empresa     = pEmpresa
	  AND descripcion = (CASE WHEN pDescripcion = "" THEN descripcion ELSE pDescripcion END)
	ORDER BY status

	  RETURN cCodRet,cMensajeRet,cStatus,cDescripcion WITH RESUME;
END FOREACH;

LET iNumReg = DBINFO("sqlca.sqlerrd2");
IF iNumReg = 0 THEN
   LET cCodRet     = "000002";
   LET cMensajeRet = "No hay información con los filtros indicados";
   RETURN cCodRet,cMensajeRet,cStatus,cDescripcion;
END IF;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para la obtencion',
'de los diferentes tipos de estatus de incrementos',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 06/SEPT/2011',
'BD: BDICRED',
'VERSION:20110906.1107';

CREATE PROCEDURE "informix".sp_consulta_info_ctescoppel()
RETURNING
	CHAR(6) AS COD_RET,
	CHAR(80) AS DESCRIPCION,
	CHAR(20) AS NUMCTE_REF,
	CHAR(4) AS SUCURSAL,
	CHAR(8) AS NUMEMPLEADO; 

	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);
    DEFINE cMensajeRet		CHAR(80);
	DEFINE cNumCteRef		CHAR(20);
	DEFINE cSucursal        CHAR(4);
	DEFINE cNumEmpleado		CHAR(8);	
	
	---INICIALIZACIONES
    LET iSqlErr				= 0;
    LET iIsamErr			= 0;
    LET cErrorInfo			= '';
    LET cCodRet				= '000000';
    LET cMensajeRet			= 'Proceso Exitoso';
	LET cNumCteRef			= '';
	LET cSucursal           = '';
	LET cNumEmpleado		= '';

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet, cMensajeRet, cNumCteRef, cSucursal, cNumEmpleado;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	---SET DEBUG FILE TO "/respaldosbd/Malena/sp_consulta_info_ctescoppel.out";
	---TRACE ON;
	
		-- BARRE LOS CLIENTES A CONSULTAR EN COPPEL
		FOREACH WITH HOLD
			SELECT numcte_ref, sucursal,user_tramite
			INTO cNumCteRef,cSucursal,cNumEmpleado
			FROM bdicred:'informix'.sd_consultar_infoctecoppel
			WHERE status_envio=0
  				
			RETURN cCodRet, cMensajeRet, cNumCteRef, cSucursal, cNumEmpleado WITH RESUME;
		END FOREACH
		-- VALIDA SI EXISTEN CLIENTES A CONSULTAR A COPPEL.
	    IF dbinfo('sqlca.sqlerrd2') = 0 THEN
	        LET cCodRet = '000001';
	        LET cMensajeRet = 'NO EXISTEN CLIENTES PARA CONSULTAR EN COPPEL';
			RETURN cCodRet, cMensajeRet, cNumCteRef, cSucursal, cNumEmpleado;
	    END IF; 
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para obtener los clientes que serán consultados a coppel', 
'AUTOR: Maria Elena Angulo',
'FECHA: Noviembre 2011',
'VERSION: 20111128.1645';

CREATE PROCEDURE "informix".sp_consultar_origen_aumlincred()
RETURNING 
CHAR(6)		AS codigo_retorno,
CHAR(80)	AS mensaje_retorno,	
CHAR(2)		AS origen,
CHAR(40)	AS desc_status; 

---DECLARACIONES
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cDescripcion		CHAR(40);
DEFINE cOrigen			CHAR(2);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = '';
LET cCodRet             = '000000';
LET cMensajeRet         = 'SE REALIZÓ LA CONSULTA CORRECTAMENTE';
LET cOrigen				= '';
LET cDescripcion		= '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
     RETURN cCodRet, cMensajeRet,cOrigen,cDescripcion;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO 'sp_consultar_origen_aumlincred.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	FOREACH WITH HOLD
		SELECT origen,TRIM(descripcion)
		INTO cOrigen,cDescripcion
		FROM bdicred:'informix'.sd_aumlincred_origen
		ORDER BY origen	
					
		RETURN cCodRet,cMensajeRet,cOrigen,cDescripcion WITH RESUME;
	END FOREACH;		

    IF dbinfo("sqlca.sqlerrd2") = 0 THEN
        LET cCodRet = '000001';
        LET cMensajeRet = 'NO HAY INFORMACIÓN DEL CATÁLOGO DE ORIGEN DE AUMENTO DE LÍNEA DE CRÉDITO';
		RETURN cCodRet,cMensajeRet,cOrigen,cDescripcion;
    END IF
	
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para la obtencion de los origenes de incrementos de linea de crédito',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 08/03/2011',
'BD    : BDICRED',
'Version: 20110926.1246',
'MODIFICADO POR : Mohamed Carreón',
'----------------------------------------------------------------------------------',
'Autor: Josué Remberto Zazueta Acosta',
'Modificación: Se borra código comentado,se agregan informix y bd a las tablas que no tenían,Se implementan reglas', 'de informix',
'Fecha de modificación: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_reenvio_consulta_info_ctescoppel()
RETURNING
	CHAR(6) AS COD_RET,
	CHAR(80) AS DESCRIPCION; 

	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);
    DEFINE cMensajeRet		CHAR(80);

	
	---INICIALIZACIONES
    LET iSqlErr				= 0;
    LET iIsamErr			= 0;
    LET cErrorInfo			= '';
    LET cCodRet				= '000000';
    LET cMensajeRet			= 'Proceso Exitoso';


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet, cMensajeRet;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	---SET DEBUG FILE TO "/respaldosbd/Malena/sp_reenvio_consulta_info_ctescoppel.out";
	---TRACE ON;
	
	--ACTUALIZAR LOS CLIENTES CON ESTATUS DE ERROR A ESTATUS NORMAL PARA QUE LAS TOME DE NUEVO EL SERVICIO.
	UPDATE bdicred:'informix'.sd_consultar_infoctecoppel 
	SET status_envio=0
	WHERE status_envio=2;		

	RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para actualizar los clientes que se encuentren con estatus de error a estatus normal para que se vuelvan a tomar al consultar a coppel ', 
'AUTOR: Maria Elena Angulo',
'FECHA: Noviembre 2011',
'VERSION: 20111129.1645';

CREATE PROCEDURE "informix".sp_registrarbitacora_ofi(pEmpresa CHAR (3), pNumCredito CHAR(20),pSucursal CHAR (4))
RETURNING CHAR(6)  AS codigo_retorno,
		  CHAR(80) AS mensaje_retorno; 
		  
---DECLARACIONES         
DEFINE cCodRet               CHAR(6); 
DEFINE cMensajeRet           CHAR(80);
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE cNumCte              CHAR(20);
DEFINE cRiesgo      	   	CHAR(2);
DEFINE dMontoOtor          	DECIMAL(18,2);
DEFINE cNumprod        	    CHAR(4);   
DEFINE cUser        	    CHAR(20);
---INICIALIZACIONES
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";
LET cCodRet              = "000000";
LET cMensajeRet          = "PROCESO EXITOSO";
LET cNumCte 			 = "";
LET cRiesgo      	 	 = "";
LET dMontoOtor        	 = 0;
LET cNumprod        	 = "";  
LET cUser                = USER;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet     = iSqlErr;
	 LET cMensajeRet = cErrorInfo;
     RETURN cCodRet,cMensajeRet;
   END IF;	
END EXCEPTION;

--SET DEBUG FILE TO 'sp_registrarbitacora_ofi.out';
--TRACE ON;

--se validan los parametros de entrada.
	IF NVL(pEmpresa,"") = "" THEN
		LET cCodRet = "000001";
		LET cMensajeRet = "Falta parámetro de empresa";
	ELIF NVL(pNumCredito,"") = "" THEN
		LET cCodRet = "000002";
		LET cMensajeRet = "Falta parámetro requerido de numero de credito para realizar la consulta";
	ELSE 
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		SELECT a.numcte, b.monto_otorgado, a.num_producto
	      INTO  cNumCte, dMontoOtor, cNumprod
		  FROM bdicred:"informix".sd_maecred a 
		  INNER JOIN bdicred:"informix".sd_maesdos b ON a.empresa = b.empresa AND a.num_credito = b.num_credito
		  WHERE a.empresa     = pEmpresa
	       AND a.num_credito = pNumCredito;
			
	        INSERT INTO bdicred:"informix".sd_bitacora_aumlincred
			(empresa, num_solicitud, numcte, num_producto, status, causa_status, fecha_status, hora_status, sucursal,lincred_actual,origen, user_insert, fecha_insert) 
	        VALUES(pEmpresa, pNumCredito, cNumCte, cNumprod, "AN",'',CURRENT, CURRENT,pSucursal, dMontoOtor,"S", cUser, CURRENT);
	        
			INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred
			(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
	        VALUES(pEmpresa, pNumCredito, "AN", '', cUser, CURRENT, CURRENT, 0);		

	END IF;
	RETURN cCodRet, cMensajeRet; 		
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para realizar registro de anulacion de la solicitud en bitacora.',
'AUTOR : Maria Elena Angulo Aispuro,Jesús Manuel Aguilar Heredia',
'FECHA : 10/Oct/2011',
'BD    : BDICRED',
'Version: 20111010.1051';

CREATE PROCEDURE "informix".sp_rep_gral_aumlincred_auto_hist()
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;           
---DECLARACIONES      
DEFINE cCodRet               CHAR(6); 
DEFINE cMensajeRet           CHAR(80);
DEFINE cComentario           CHAR(80);
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE dtFechaHoy 			DATE;
DEFINE dtFechaAnt12m 		DATE;
---INICIALIZACIONES
LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = "";
LET cCodRet                  = "000000";
LET cMensajeRet              = "SE REALIZÓ LA CONSULTA CORRECTAMENTE";
LET dtFechaHoy 			= DATE(1);
LET dtFechaAnt12m 		= DATE(1);


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
	 LET cMensajeRet = TRIM(NVL(cErrorInfo,''));
	 ROLLBACK WORK;
     RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cMensajeRet,''));
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO 'sp_rep_gral_aumlincred_auto_hist.out';
--TRACE ON;

SELECT fecha_hoy 
  INTO dtFechaHoy
  FROM bdicred:"informix".sd_fechas
 WHERE empresa = '001';
 
CALL bdicred:"informix".monthadd(dtFechaHoy,-12) RETURNING dtFechaAnt12m; -- 12 meses

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
	
	BEGIN WORK;
	
	INSERT INTO bdicred:"informix".sd_rep_gral_aumlincred_auto_hist
	   (fecha_origen, num_solicitud,origen ,numcte,num_credito,apell_paterno ,apell_materno ,nombre,lincred_actual,lincred_sugerida,	
	   porcentaje_incremento,status,analistaCac,analista2nivel,analista3nivel,analista4nivel,motivo,incrementoautomatico,user_insert,fecha_insert,revisioncac)
	SELECT  fecha_origen, num_solicitud,origen ,numcte,num_credito,apell_paterno ,apell_materno ,nombre,lincred_actual,lincred_sugerida,	
	   porcentaje_incremento,status,analistaCac,analista2nivel,analista3nivel,analista4nivel,motivo,incrementoautomatico,user_insert,fecha_insert,revisioncac
	FROM  bdicred:"informix".sd_rep_gral_aumlincred_auto 
	WHERE fecha_insert <=dtFechaAnt12m;

	COMMIT WORK; 
		   
  RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cMensajeRet,''));
		
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para migrar la información de los clientes prospectos a un incremento en su linea de crédito',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 04/03/2010',
'BD    : BDICRED',
'Version: 20110304.1210',
'Se modifica para agregar nuevos campos usados para la reporteria',
'MODIFICO : Jesús Manuel Aguilar Heredia',
'FECHA : 04/03/2010',
'BD    : BDICRED',
'Version: 20110304.1210',
'----------------------------------------------------------------------------------',
'Autor: Josué Remberto Zazueta Acosta',
'Modificación: Se borra código comentado,se agregan informix y bd a las tablas que no tenían,Se implementan reglas', 'de informix',
'Fecha de modificación: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_restablecerrevisionsolicitud
(
pEmpresa     	CHAR(3),
pNumCredito 	CHAR(20),
pUsuario 	  	CHAR(8),
pMismoUsuario	CHAR(1)
)

-- pMismoUsuario
-- 0: SE TRATA DE  ESTABLECER LA SOLICITUD DE MANERA NORMAL
-- 1: SE TRATA DE RESTABLECER UNA  SOLICITUD CUANDO UN MISMO USUARIO VOLVIO A TRABAJARLA
--2: casos de error
														   
RETURNING 
CHAR(6)           AS COD_RET,
VARCHAR(107,1)    AS MENSAJE_RET;

DEFINE iSqlErr          INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       VARCHAR(255,1);
DEFINE cCodRet          CHAR(6);
DEFINE cMensajeRet      VARCHAR(107,1);
DEFINE iRevisionCac    	INTEGER;
DEFINE iNivelAuto    	INTEGER;

LET iSqlErr            = 0;
LET iIsamErr           = 0;
LET cErrorInfo         = '';
LET cCodRet            = '000000';
LET cMensajeRet        = 'PROCESO EXITOSO';
LET iRevisionCac       = 0;
LET iNivelAuto         = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet     = iSqlErr;
	 LET cMensajeRet = cErrorInfo;
     RETURN cCodRet,cMensajeRet;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/home/sysifx/has/sp_restablecerrevisionsolicitud.out';
	--TRACE ON;

	IF NVL(pEmpresa,'') = '' OR NVL(pNumCredito,'') = '' OR NVL(pUsuario,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'PARAMETROS DE ENTRADA INVALIDOS';
		RETURN cCodRet,cMensajeRet;
	END IF;
	
	IF pMismoUsuario = '1' THEN
		-- BORRA LA SOLICITUD QUE SE HABIA QUEDADO COLGADA POR UNA RAZON DE FUERZA MAYOR
		DELETE FROM bdicred:'informix'.sd_sol_procesando_aumlincred
		WHERE num_credito = pNumCredito;
	ELSE
		--SE OBTIENE EL NIVEL DE AUTORIZACIÓN ACTUAL DE LA SOLICITUD.
		SELECT revision_cac
		INTO iRevisionCac
		FROM bdicred:'informix'.sd_autorizacion_aumlincred
		WHERE empresa = '001'
		AND num_solicitud = pNumCredito
		AND status = 'AC'
		AND fecha_insert = fecha_insert;	
		
		
		--SE OBTIENE EL NIVEL DE AUTORIZACIÓN 	
		SELECT per.nivel
		INTO iNivelAuto
		FROM bdicred:'informix'.sd_historica_cac_aumlincred his, bdicred:'informix'.sd_perfiles_cac_aumlincred per
		WHERE his.solicitud = pNumCredito
		AND his.ejecutivo = per.ejecutivo
		AND his.puesto = per.puesto
		AND his.rango_autorizacion = per.rango_autorizacion
		AND his.ejecutivo = pUsuario;
				
		--SE CHECA SI NO CAMBIO EL NIVEL DE AUTORIZACION DE LA SOLICITUD			
		IF iNivelAuto = iRevisionCac THEN
			DELETE FROM bdicred:'informix'.sd_historica_cac_aumlincred 
			WHERE solicitud = pNumCredito
			AND ejecutivo = pUsuario;
			
			DELETE FROM bdicred:'informix'.sd_sol_procesando_aumlincred
			WHERE num_credito = pNumCredito;
			
			IF pMismoUsuario = 2 THEN
				LET iRevisionCac = iRevisionCac+1;
			END IF;
			
			--SI SE CUMPLE LA CONDICIÓN SE REESTABLECE LA SOLICITUD A SU NIVEL DE AUTORIZACION ANTERIOR
			IF iRevisionCac = 1 THEN
				UPDATE bdicred:'informix'.sd_autorizacion_aumlincred
				SET revision_cac = iRevisionCac-1
				WHERE num_solicitud = pNumCredito
				AND status = 'AC';
			END IF;
		END IF;
		
	END IF;
	RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cMensajeRet,''));
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para la desasignación de solicitudes de incremento de líneas de crédito.',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 10/OCT/2011',
'BD: BDICRED',
'VERSION:20111010.1107',
'MODIFICO: Mohamed Carreón',
'DESCRIPCION: Se modificó el proceso para cumplir con las reglas de programacion',
'FECHA: 11/NOV/2011',
'----------------------------------------------------------------------------------',
'Autor: Josué Remberto Zazueta Acosta',
'Modificación: Se borra código comentado,se agregan informix y bd a las tablas que no tenían,Se implementan reglas', 'de informix',
'Fecha de modificación: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_consulta_sbc_retenido_general(pEmpresa CHAR(3),
                                                             pNumcred CHAR(20))
RETURNING
          CHAR(6)        AS resultado,
          CHAR(80)       AS mensaje,
          INTEGER        AS consulta,
          CHAR(40)       AS banco,
          CHAR(4)        AS sucursal,
          CHAR(10)       AS fecha_alta,
          DECIMAL(18,2)  AS monto,
          INTEGER        AS num_cheque,
          CHAR(16)       AS folio_sucursal,
          DATE           AS fecha_ret,
          CHAR(16)       AS folio_sucursal_ret,
          DECIMAL(18,2)  AS monto_ret,
          CHAR(40)       AS referencia,
          INTEGER        AS dias_ret,
		  INTEGER		 AS dias_rest;

DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE cCodRet               CHAR(6);
DEFINE cMensajeRet           CHAR(80);

DEFINE iResultado            INTEGER;
DEFINE cNombreBanco          CHAR(40);
DEFINE cSucursal             CHAR(4);
DEFINE cFechaAlta            CHAR(10);
DEFINE dMonto                DECIMAL(18,2);
DEFINE iNumCheq              INTEGER;
DEFINE cFolioSuc             CHAR(16);

DEFINE dFechaRetenido        DATE;
DEFINE cReferencia           CHAR(40);
DEFINE iDiasRetenido         INTEGER;
DEFINE iContado              INTEGER;
DEFINE cTipCred              CHAR(2);
DEFINE iDiasRestantes		 INTEGER;


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet, cMensajeRet, iResultado, cNombreBanco, cSucursal, cFechaAlta, dMonto, iNumCheq, cFolioSuc, dFechaRetenido,
           cFolioSuc, dMonto, cReferencia, iDiasRetenido, iDiasRestantes ;
   END IF;
END EXCEPTION;

SET ISOLATION TO dirty READ;

--SET DEBUG FILE TO '/tmp/sp_consulta_sbc_retenido_general.out';
--TRACE ON;

LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = '';
LET cCodRet                  = '000000';
LET cMensajeRet              = 'Se realizó la consulta correctamente';
LET cSucursal                = '';
LET cFechaAlta               = '';
LET cNombreBanco             = '';
LET dMonto                   = 0;
LET iNumCheq                 = 0;
LET cFolioSuc                = '';

LET dFechaRetenido           = DATE(0);
LET cReferencia              = '';
LET iDiasRetenido            = 0;
LET iResultado               = 1;
LET iContado                 = 0;
LET cTipCred                 = '';
LET iDiasRestantes			 = 0;

IF NVL(TRIM(pEmpresa),'') ='' OR NVL(TRIM(pNumcred),'')='' THEN
    LET cCodRet     = '000001';
    LET cMensajeRet = "Faltan parámetros para ejecución";
 RETURN cCodRet, cMensajeRet, NVL(iResultado,0), NVL(cNombreBanco,''),NVL(cSucursal,''),
        NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dFechaRetenido,DATE(1)),
        NVL(cFolioSuc,''), NVL(dMonto,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), NVL(iDiasRestantes,0) ;
END IF;

   --Obtiene tipo de credito
    SELECT b.cod_prod
      INTO cTipCred
      FROM bdicred:sd_maecred a,
           bdicred:sd_tipprod b
     WHERE a.num_credito = pNumcred
       AND a.empresa=pEmpresa
       AND a.empresa=b.empresa 
       AND a.num_producto=b.abrevia_prod;

    IF cTipCred IS NULL THEN
	
    SELECT b.cod_prod
      INTO cTipCred
      FROM bdicred:sd_maecredcrd a,
           bdicred:sd_tipprod b
     WHERE a.num_credito = pNumcred
       AND a.empresa=pEmpresa
       AND a.empresa=b.empresa 
       AND a.num_producto=b.abrevia_prod;

      IF cTipCred IS NULL THEN
	    LET cCodRet= '000002';
		LET cMensajeRet= 'No hay información para realizar la consulta';
        RETURN cCodRet, cMensajeRet, NVL(iResultado,0), NVL(cNombreBanco,''),NVL(cSucursal,''),
                NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dFechaRetenido,DATE(1)),
                NVL(cFolioSuc,''), NVL(dMonto,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), NVL(iDiasRestantes,0) ;
      END IF;
	END IF;
	
	IF cTipCred='T' THEN  --Obtiene salvo buen cobro  para tarjeta de credito
			FOREACH
			    SELECT  bco.descripcion,
			            a.sucursal,
			            TO_CHAR(a.fecha_alta) fecha_alta,
			            a.monto,
			            a.num_chq,
			            a.folio_suc
			       INTO cNombreBanco,
			            cSucursal,
			            cFechaAlta,
			            dMonto,
			            iNumCheq,
			            cFolioSuc
			       FROM bdicheq:sc_docret_sbc a,   --MOHA
			            bdicred:sd_tarjeta b,
			            bdinteg:si_bancos bco
			      WHERE a.siglas = 'SD'
			        AND a.cancelado ='T'
			        AND b.num_credito = pNumcred
			        AND a.cuenta = b.num_tarjeta
			        AND bco.banco =a.banco
			        AND b.tipo_tarjeta= 'T'
			        AND b.status_tar = 'A'
			   ORDER BY 3 DESC
			   
			       LET iContado = iContado + 1;

			       RETURN cCodRet, cMensajeRet, NVL(iResultado,0), NVL(cNombreBanco,''),NVL(cSucursal,''),
			              NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dFechaRetenido,DATE(1)),
			              NVL(cFolioSuc,''), NVL(dMonto,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), NVL(iDiasRestantes,0)  WITH RESUME;

			END FOREACH;

			LET iResultado = 2;
			LET cNombreBanco = '';
			LET cSucursal = '';
			LET cFechaAlta = '';
			LET dMonto = 0;
			LET iNumCheq = 0;
			LET cFolioSuc = '';

			FOREACH   --Obtiene movimientos retenidos
			    SELECT fecha,
			           folio_suc,
			           monto,
			           referencia,
					   dias_ret,
			           fecha + dias_ret - (SELECT fecha_hoy FROM bdicred:sd_fechas WHERE empresa = pEmpresa)
			      INTO dFechaRetenido,
			           cFolioSuc,
			           dMonto,
			           cReferencia,
			           iDiasRetenido,
					   iDiasRestantes
			      FROM bdicred:sd_maeretenido
			     WHERE empresa      = pEmpresa
			       AND num_credito  = pNumcred
			       AND estatus = 'P'
			  ORDER BY 1 DESC

			       LET iContado = iContado + 1;
				   
				   IF iDiasRestantes < 0 THEN
						LET iDiasRestantes = 0;
				   END IF;
				   
			       RETURN cCodRet, cMensajeRet, NVL(iResultado,0), NVL(cNombreBanco,''),NVL(cSucursal,''),
			              NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dFechaRetenido,DATE(1)),
			              NVL(cFolioSuc,''), NVL(dMonto,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), NVL(iDiasRestantes,0) WITH RESUME;
			END FOREACH
			
    ELIF cTipCred IN ('P','R') THEN  --Obtiene salvo buen cobro para prestamo y reestructura
	
	     FOREACH
			    SELECT  bco.descripcion,
			            a.sucursal,
			            TO_CHAR(a.fecha_alta) fecha_alta,
			            a.monto,
			            a.num_chq,
			            a.folio_suc
			       INTO cNombreBanco,
			            cSucursal,
			            cFechaAlta,
			            dMonto,
			            iNumCheq,
			            cFolioSuc
			       FROM bdicheq:sc_docret_sbc a,   --MOHA
			            bdinteg:si_bancos bco
			      WHERE a.siglas = 'SD'
			        AND a.cancelado ='T'
					AND a.cuenta = pNumcred
			        AND bco.banco =a.banco
			   ORDER BY 3 DESC
			   
			       LET iContado = iContado + 1;

			       RETURN cCodRet, cMensajeRet, NVL(iResultado,0), NVL(cNombreBanco,''),NVL(cSucursal,''),
			              NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dFechaRetenido,DATE(1)),
			              NVL(cFolioSuc,''), NVL(dMonto,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), NVL(iDiasRestantes,0)  WITH RESUME;

			END FOREACH;

			LET iResultado = 2;
			LET cNombreBanco = '';
			LET cSucursal = '';
			LET cFechaAlta = '';
			LET dMonto = 0;
			LET iNumCheq = 0;
			LET cFolioSuc = '';
	    
	END IF;
	
IF iContado = 0 THEN
   LET cCodRet      = '000002';
   LET cMensajeRet  = 'Sin resultados';

RETURN cCodRet, cMensajeRet, NVL(iResultado,0), NVL(cNombreBanco,''),NVL(cSucursal,''),
      NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dFechaRetenido,DATE(1)),
      NVL(cFolioSuc,''), NVL(dMonto,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), NVL(iDiasRestantes,0) ;

END IF;

END
END PROCEDURE
DOCUMENT
'SE REALIZA PROCEDIMIENTO PARA OBTENER EL SALVO BUEN COBRO Y LOS MOVIMIENTOS RETENIDOS',
'AUTOR : ABIGAIL VASAVILBAZO CAÑEDO',
'MODIFICACION: SE AGREGA DIAS RESTANTES',
'BD: BDICRED',
'VERSION: 20110419.1040';

CREATE PROCEDURE "informix".sp_consulta_sbc_retenido_general(pEmpresa CHAR(3),
                                                             pNumcred CHAR(20),
															 pCredSol smallint)
	RETURNING
			  CHAR(6)        AS resultado,
			  CHAR(80)       AS mensaje,
			  INTEGER        AS consulta,
			  CHAR(40)       AS banco,
			  CHAR(4)        AS sucursal,
			  CHAR(10)       AS fecha_alta,
			  DECIMAL(18,2)  AS monto,
			  INTEGER        AS num_cheque,
			  CHAR(16)       AS folio_sucursal,
			  DATE           AS fecha_ret,
			  CHAR(16)       AS folio_sucursal_ret,
			  DECIMAL(18,2)  AS monto_ret,
			  CHAR(40)       AS referencia,
			  INTEGER        AS dias_ret,
			  INTEGER		 AS dias_rest,
			  DATE			 AS FechaCompra,
			  CHAR(20)		 AS NumPrestamo,
			  CHAR(50) 		 AS Concepto,
			  SMALLINT       AS Plazo,
			  INTEGER		 AS NumPago,	 		 	 		 		 		 		  			 	
	 		  DECIMAL(20,2)  AS MontoRemanente,
			  DECIMAL(20,2)  AS MontoOriginal;
	 	 	 

	DEFINE iSqlErr      	     INTEGER;
	DEFINE iIsamErr              INTEGER;
	DEFINE cErrorInfo            CHAR(80);
	DEFINE cCodRet               CHAR(6);
	DEFINE cMensajeRet           CHAR(80);

	DEFINE iResultado            INTEGER;
	DEFINE cNombreBanco          CHAR(40);
	DEFINE cSucursal             CHAR(4);
	DEFINE cFechaAlta            CHAR(10);
	DEFINE dMonto                DECIMAL(18,2);
	DEFINE iNumCheq              INTEGER;
	DEFINE cFolioSuc             CHAR(16);

	DEFINE dtFechaRetenido       DATE;
	DEFINE cReferencia           CHAR(40);
	DEFINE iDiasRetenido         INTEGER;
	DEFINE iContado              INTEGER;
	DEFINE cTipCred              CHAR(2);
	DEFINE iDiasRestantes		 INTEGER;
	
	DEFINE dtFechaCompra		 DATE;
	DEFINE cNumPrestamo		 	 CHAR(20);
	DEFINE cConcepto		 	 CHAR(50);
	DEFINE sPlazo 			 	 SMALLINT;
	DEFINE iNumPag			 	 INTEGER;
	DEFINE dMontoRemanente	 	 DECIMAL(20,2);
	DEFINE dMontoOriginal	 	 DECIMAL(20,2);

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		   IF iSqlErr != 0 THEN
			  LET cCodRet= iSqlErr;
			  LET cMensajeRet= cErrorInfo;
			  RETURN cCodRet, cMensajeRet, iResultado, cNombreBanco, cSucursal, cFechaAlta, dMonto, iNumCheq, cFolioSuc, dtFechaRetenido,
				   cFolioSuc, dMonto, cReferencia, iDiasRetenido, iDiasRestantes,dtFechaCompra,cNumPrestamo,cConcepto,sPlazo,
				   iNumPag,dMontoRemanente,dMontoOriginal;
		   END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;		
		SET ISOLATION TO DIRTY READ;	
--		SET DEBUG FILE TO '/pisa/leo/sp_consulta_sbc_retenido_general.out';
--		TRACE ON;

		LET iSqlErr                  = 0;
		LET iIsamErr                 = 0;
		LET cErrorInfo               = '';
		LET cCodRet                  = '000000';
		LET cMensajeRet              = 'Se realizó la consulta correctamente';
		LET cSucursal                = '';
		LET cFechaAlta               = '';
		LET cNombreBanco             = '';
		LET dMonto                   = 0;
		LET iNumCheq                 = 0;
		LET cFolioSuc                = '';

		LET dtFechaRetenido           = DATE(0);
		LET cReferencia              = '';
		LET iDiasRetenido            = 0;
		LET iResultado               = 1;
		LET iContado                 = 0;
		LET cTipCred                 = '';
		LET iDiasRestantes			 = 0;
		
		LET dtFechaCompra 			 = DATE(1);
		LET cNumPrestamo 			 = '';
		LET cConcepto 			     = '';
		LET sPlazo	 			     = 0;
		LET iNumPag 			     = 0;
		LET dMontoRemanente 		 = 0.00;
		LET dMontoOriginal 		 	 = 0.00;
		

		IF NVL(TRIM(pEmpresa),'') ='' OR NVL(TRIM(pNumcred),'')='' THEN
			LET cCodRet     = '000001';
			LET cMensajeRet = "Faltan parámetros para ejecución";
			RETURN cCodRet, cMensajeRet, NVL(iResultado,0), NVL(cNombreBanco,''),NVL(cSucursal,''),
				NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dtFechaRetenido,DATE(1)),
				NVL(cFolioSuc,''), NVL(dMonto,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), NVL(iDiasRestantes,0),
				NVL(dtFechaCompra,DATE(1)),TRIM(NVL(cNumPrestamo,'')),TRIM(NVL(cConcepto,'')),NVL(sPlazo,0),NVL(iNumPag,0),
				NVL(dMontoRemanente,0.00),NVL(dMontoOriginal,0.00);
		END IF;

		--Obtiene tipo de credito
		SELECT b.cod_prod
		INTO cTipCred
		FROM bdicred:"informix".sd_maecred a,
		   bdicred:"informix".sd_tipprod b
		WHERE a.num_credito 	= 	pNumcred
		   AND a.empresa		=	pEmpresa
		   AND a.empresa		=	b.empresa 
		   AND a.num_producto	=	b.abrevia_prod;
		  
		IF cTipCred IS NULL THEN	
			SELECT b.cod_prod
			INTO cTipCred
			FROM bdicred:"informix".sd_maecredcrd a,
			   bdicred:"informix".sd_tipprod b
			WHERE a.num_credito = pNumcred
			   AND a.empresa=pEmpresa
			   AND a.empresa=b.empresa 
			   AND a.num_producto=b.abrevia_prod;
			IF cTipCred IS NULL THEN
				LET cCodRet= '000002';
				LET cMensajeRet= 'No hay información para realizar la consulta';
				RETURN cCodRet, cMensajeRet, NVL(iResultado,0), NVL(cNombreBanco,''),NVL(cSucursal,''),
					NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dtFechaRetenido,DATE(1)),
					NVL(cFolioSuc,''), NVL(dMonto,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), NVL(iDiasRestantes,0),
					NVL(dtFechaCompra,DATE(1)),TRIM(NVL(cNumPrestamo,'')),TRIM(NVL(cConcepto,'')),NVL(sPlazo,0),NVL(iNumPag,0),
					NVL(dMontoRemanente,0.00),NVL(dMontoOriginal,0.00);
			END IF;
		END IF;
			
		IF cTipCred='T' THEN  --Obtiene salvo buen cobro  para tarjeta de credito
			FOREACH
				SELECT  bco.descripcion,
						a.sucursal,
						TO_CHAR(a.fecha_alta) fecha_alta,
						a.monto,
						a.num_chq,
						a.folio_suc
				INTO cNombreBanco,
					cSucursal,
					cFechaAlta,
					dMonto,
					iNumCheq,
					cFolioSuc
				FROM bdicheq:"informix".sc_docret a,
					bdicred:"informix".sd_tarjeta b,
					bdinteg:"informix".si_bancos bco
				WHERE a.siglas = 'SD'
					AND a.cancelado ='T'
					AND b.num_credito = pNumcred
					AND a.cuenta = b.num_tarjeta
					AND bco.banco =a.referencia[1,3]
					AND b.tipo_tarjeta= 'T'
					AND b.status_tar = 'A'
				ORDER BY 3 DESC
			   
				LET iContado = iContado + 1;
											
				RETURN cCodRet, cMensajeRet, NVL(iResultado,0), NVL(cNombreBanco,''),NVL(cSucursal,''),
					NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dtFechaRetenido,DATE(1)),
					NVL(cFolioSuc,''), NVL(dMonto,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), NVL(iDiasRestantes,0),
					NVL(dtFechaCompra,DATE(1)),TRIM(NVL(cNumPrestamo,'')),TRIM(NVL(cConcepto,'')),NVL(sPlazo,0),NVL(iNumPag,0),
					NVL(dMontoRemanente,0.00),NVL(dMontoOriginal,0.00) WITH RESUME;
			END FOREACH;

			--SE INICIALIZAN VARIABLES PARA EL TIPO DE CONSULTA 2.
			LET iResultado = 2;
			LET cNombreBanco = '';
			LET cSucursal = '';
			LET cFechaAlta = '';
			LET dMonto = 0;
			LET iNumCheq = 0;
			LET cFolioSuc = '';			
			
			FOREACH   --Obtiene movimientos retenidos
				SELECT fecha,
					   folio_suc,
					   monto,
					   referencia,
					   dias_ret,
					   fecha + dias_ret - (SELECT fecha_hoy FROM bdicred:sd_fechas WHERE empresa = pEmpresa)
				INTO dtFechaRetenido,
				   cFolioSuc,
				   dMonto,
				   cReferencia,
				   iDiasRetenido,
				   iDiasRestantes
				FROM bdicred:"informix".sd_maeretenido
				WHERE empresa      = pEmpresa
					AND num_credito  = pNumcred
--					AND estatus = 'P'
					AND estatus IN ('P','R')
				ORDER BY 1 DESC

				LET iContado = iContado + 1;

				IF iDiasRestantes < 0 THEN
					LET iDiasRestantes = 0;
				END IF;
				   
				RETURN cCodRet, cMensajeRet, NVL(iResultado,0), NVL(cNombreBanco,''),NVL(cSucursal,''),
					NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dtFechaRetenido,DATE(1)),
					NVL(cFolioSuc,''), NVL(dMonto,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), NVL(iDiasRestantes,0),
					NVL(dtFechaCompra,DATE(1)),TRIM(NVL(cNumPrestamo,'')),TRIM(NVL(cConcepto,'')),NVL(sPlazo,0),NVL(iNumPag,0),
					NVL(dMontoRemanente,0.00),NVL(dMontoOriginal,0.00) WITH RESUME;
			END FOREACH
					
		ELIF cTipCred IN ('P','R') THEN  --Obtiene salvo buen cobro para prestamo y reestructura
			
			FOREACH
				SELECT  bco.descripcion,
					a.sucursal,
					TO_CHAR(a.fecha_alta) fecha_alta,
					a.monto,
					a.num_chq,
					a.folio_suc
				INTO cNombreBanco,
					cSucursal,
					cFechaAlta,
					dMonto,
					iNumCheq,
					cFolioSuc
				FROM bdicheq:"informix".sc_docret a,
					bdinteg:"informix".si_bancos bco
				WHERE a.siglas = 'SD'
					AND a.cancelado ='T'
					AND a.cuenta = pNumcred
					AND bco.banco =a.referencia[1,3]
				ORDER BY 3 DESC
			   
				LET iContado = iContado + 1;
								
				RETURN cCodRet, cMensajeRet, NVL(iResultado,0), NVL(cNombreBanco,''),NVL(cSucursal,''),
					NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dtFechaRetenido,DATE(1)),
					NVL(cFolioSuc,''), NVL(dMonto,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), NVL(iDiasRestantes,0),
					NVL(dtFechaCompra,DATE(1)),TRIM(NVL(cNumPrestamo,'')),TRIM(NVL(cConcepto,'')),NVL(sPlazo,0),NVL(iNumPag,0),
					NVL(dMontoRemanente,0.00),NVL(dMontoOriginal,0.00) WITH RESUME;
			END FOREACH;
				--SE INICIALIZAN VARIABLES PARA EL TIPO DE CONSULTA 2.
				LET iResultado = 2;
				LET cNombreBanco = '';
				LET cSucursal = '';
				LET cFechaAlta = '';
				LET dMonto = 0;
				LET iNumCheq = 0;
				LET cFolioSuc = '';							
		END IF;
		
		--SE INICIALIZAN VARIABLES PARA EL TIPO DE CONSULTA 3.
		LET iResultado = 3;
		LET cNombreBanco = '';
		LET cSucursal = '';
		LET cFechaAlta = '';
		LET dMonto = 0;
		LET iNumCheq = 0;
		LET cFolioSuc = '';
		
		LET dtFechaRetenido = DATE(1);						
		LET cReferencia = '';
		LET iDiasRetenido = 0;
		LET iDiasRestantes = 0;
				
		
		FOREACH

			--SE OBTIENE LOS SALDOS DIFERIDOS/PLAZO.
			SELECT a.fecha,a.num_sol_prestamo,a.nombre_promo,a.plazo,a.monto_int_iva + a.monto_actual,b.monto_otorgado
			INTO dtFechaCompra,cNumPrestamo,cConcepto,sPlazo,dMontoRemanente,dMontoOriginal
			FROM bdicred:'informix'.sd_promocion_credito a,
				bdicred:'informix'.sd_maesdoscrd b
			WHERE a.empresa 	= 	b.empresa
		  	  AND a.num_credito = pNumcred
              AND a.num_sol_prestamo = b.num_credito
              AND a.status = 2



			SELECT MAX(num_pago) 
			INTO iNumPag 
			FROM bdicred:'informix'.sd_amortiza_creditocrd
			WHERE capital_status='5' 
				AND  num_credito = cNumPrestamo;
			
			LET iContado = iContado + 1;

			RETURN cCodRet, cMensajeRet, NVL(iResultado,0), NVL(cNombreBanco,''),NVL(cSucursal,''),
				NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dtFechaRetenido,DATE(1)),
				NVL(cFolioSuc,''), NVL(dMonto,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), NVL(iDiasRestantes,0),
				NVL(dtFechaCompra,DATE(1)),TRIM(NVL(cNumPrestamo,'')),TRIM(NVL(cConcepto,'')),NVL(sPlazo,0),NVL(iNumPag,0),
				NVL(dMontoRemanente,0.00),NVL(dMontoOriginal,0.00) WITH RESUME;
					
		END FOREACH;
									
		IF iContado = 0 THEN
			LET cCodRet      = '000002';
			LET cMensajeRet  = 'Sin resultados';
			RETURN cCodRet, cMensajeRet, NVL(iResultado,0), NVL(cNombreBanco,''),NVL(cSucursal,''),
				NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dtFechaRetenido,DATE(1)),
				NVL(cFolioSuc,''), NVL(dMonto,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), NVL(iDiasRestantes,0),
				NVL(dtFechaCompra,DATE(1)),TRIM(NVL(cNumPrestamo,'')),TRIM(NVL(cConcepto,'')),NVL(sPlazo,0),NVL(iNumPag,0),
				NVL(dMontoRemanente,0.00),NVL(dMontoOriginal,0.00);
		END IF;
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que obtiene el salvo buen cobro y los movimientos retenidos',
'AUTOR: Abigail Vasavilbazo Cañedo',
'FECHA DE CREACION: 19 de Abril del 2011',
'MODIFICACION: Se agrega consulta para obtener los saldos diferidos/plazos por numero de credito',
'MODIFICO: Guadalupe Payan',
'FECHA DE MODIFICACION: 08 de Febrero de 2012',
'VERSION: 20120208.1630',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_consultar_status_aumlincred()
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,	
		  CHAR(2) AS status,
		  CHAR(40) AS desc_status; 
---DECLARACIONES
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cComentario      CHAR(80);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cDescripcion		CHAR(40);
DEFINE cStatus			CHAR(2);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizó la consulta correctamente";
LET cStatus				= "";
LET cDescripcion			= "";
       
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
     RETURN cCodRet, cMensajeRet,cStatus,cDescripcion;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO 'sp_consultar_status_aumlincred.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	FOREACH
		SELECT status,TRIM(descripcion)
		INTO cStatus,cDescripcion
		FROM  bdicred:sd_status_aumlincred
		ORDER BY status	
					
		 RETURN cCodRet, cMensajeRet,cStatus,cDescripcion WITH RESUME;
	END FOREACH;		
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para la obtencion de los status de incrementos de linea de crédito',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 08/03/2011',
'BD    : BDICRED',
'Version: 20110308.1210';

CREATE PROCEDURE "informix".sp_rep_gral_aumlincred_auto()
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;           
          
DEFINE cCodRet               CHAR(6); 
DEFINE cMensajeRet           CHAR(80);
DEFINE cComentario           CHAR(80);
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);

DEFINE dtFechaInsert 		DATE;
DEFINE cNumSol 				VARCHAR(20);
DEFINE orcOrigenigen  		CHAR(1);
DEFINE cNumCte 				VARCHAR(20);
DEFINE cApellPaterno		VARCHAR(26);
DEFINE cApellMaterno 		VARCHAR(26);
DEFINE cNombre 				VARCHAR(53);
DEFINE dLinCredAct 		    DECIMAL(18,2);
DEFINE dLinCredCal 	     	DECIMAL(18,2);
DEFINE dIncremento			DECIMAL(18,2);
DEFINE dMontoIncremento		DECIMAL(18,2);
DEFINE cStatus 				CHAR(2);
DEFINE cCausa 				CHAR(3);
DEFINE cAnalista1Niv		VARCHAR(45);
DEFINE cAnalista2Niv 		VARCHAR(45);
DEFINE cAnalista3Niv 		VARCHAR(45);
DEFINE cAnalista4Niv 		VARCHAR(45);
DEFINE cMotivo 				VARCHAR(106);
DEFINE cUser 				CHAR(8);
DEFINE cOrigen 				CHAR(1);
DEFINE dtFechaHoy 			DATE;
DEFINE dtFechaAnt12m 		DATE;
DEFINE cIncreAuto 			CHAR(1);
DEFINE cBandera 			CHAR(1);
DEFINE iRevisionCAC			INTEGER;
DEFINE cNomEjecutivo		CHAR(45);
DEFINE iNivel				INTEGER;
DEFINE cEjecutivoNivel		CHAR(8);
DEFINE iContador			INTEGER;
DEFINE iLineaCreditoCAC		INT8;

LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = '';
LET cCodRet                  = '000000';
LET cMensajeRet              = 'Se realizó la consulta correctamente';

LET dtFechaInsert 		 = DATE(1);
LET cNumSol 			 = '';
LET orcOrigenigen  		 = '';
LET cNumCte 			 = '';
LET cApellPaterno		 = '';
LET cApellMaterno 		 = '';
LET cNombre 			 = '';
LET dLinCredAct 		 = 0;
LET dLinCredCal 	     = 0;
LET dIncremento			 = 0;
LET cStatus 			 = '';
LET cCausa 				 = '';
LET cAnalista1Niv		 = '';
LET cAnalista2Niv 		 = '';
LET cAnalista3Niv 		 = '';
LET cAnalista4Niv 		 = '';
LET cMotivo 			 = '';
LET cUser 				 = USER;
LET cOrigen 			 = '';
LET dtFechaHoy 			= DATE(1);
LET dtFechaAnt12m 		= DATE(1);
LET cIncreAuto 			 = '';
LET cBandera 			 = 'N';
LET iRevisionCAC		= 0;
LET cNomEjecutivo		= '';
LET iNivel				= 0;
LET cEjecutivoNivel		= '';
LET iContador			= 0;
LET iLineaCreditoCAC	= 0;
LET dMontoIncremento	= 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
	 IF  cBandera = 'S' THEN
		ROLLBACK WORK;
	 END IF;
	 RETURN cCodRet, cErrorInfo;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/resplogifx/archivoscartera/sp_rep_gral_aumlincred_auto.out';
--TRACE ON;

SELECT fecha_hoy 
  INTO dtFechaHoy
  FROM bdicred:'informix'.sd_fechas
 WHERE empresa = '001';
 
CALL bdicred:'informix'.monthadd(dtFechaHoy,-12) RETURNING dtFechaAnt12m; -- 360 días
 
-- SET ISOLATION TO DIRTY READ;
-- SET LOCK MODE TO WAIT 3;
--se manda llamar al procedimiento que hara el respaldo del ultimo mes de la consulta previa


	EXECUTE PROCEDURE 'informix'.sp_rep_gral_aumlincred_auto_hist() INTO cCodRet, cMensajeRet;

	IF cCodRet <> '000000' THEN
		LET cCodRet =  '000001';
		LET cMensajeRet =  'No se pudo realizar el respaldo correspondiente';		
	END IF;
	DELETE bdicred:'informix'.sd_rep_gral_aumlincred_auto;
	BEGIN WORK;
	LET cBandera = 'S';

	FOREACH WITH HOLD
		SELECT a.numcte,TRIM(NVL(a.nombre1, ''))||' '||TRIM(NVL(a.nombre2,'')),TRIM(NVL(a.apell_paterno, '')),TRIM(NVL(a.apell_materno, '')) ,
                b.fecha_insert, b.lincred_actual, b.lincred_sugerida, b.origen, b.status, b.causa_status, b.num_solicitud, c.ajuste_de_cuota, b.revisioncac
		INTO cNumCte, cNombre, cApellPaterno, cApellMaterno, dtFechaInsert, dLinCredAct, dLinCredCal, cOrigen, cStatus,cCausa, cNumSol,cIncreAuto, iRevisionCAC
		FROM  bdicred:'informix'.sd_bitacora_aumlincred b
		INNER JOIN bdinteg:'informix'.si_cliente a ON (a.empresa = b.empresa AND a.numcte = b.numcte)
		INNER JOIN bdisolic:'informix'.ss_solicitudes c on c.empresa = a.empresa AND c.num_solicitud = b.num_solicitud 
		WHERE b.empresa = '001' 
		AND b.fecha_insert >= dtFechaAnt12m AND b.fecha_insert <= dtFechaHoy
		
		--se calcula el porcentaje del incremento
			LET dMontoIncremento = dLinCredCal - dLinCredAct;
		IF dMontoIncremento > 0 AND dLinCredAct > 0 THEN		
	 		LET dIncremento = ROUND( dMontoIncremento/ dLinCredAct) * 100;
		ELSE
			LET dIncremento = 0;
		END IF;
		IF iRevisionCAC = 1 THEN
			FOREACH WITH HOLD
				SELECT b.nombre
				INTO cNomEjecutivo
				FROM bdicred:"informix".sd_historica_cac_aumlincred a
				INNER JOIN bdinteg:"informix".si_ejecut b ON (b.ejecutivo = a.ejecutivo)
				WHERE a.solicitud = cNumSol
				ORDER BY a.puesto		
				
				LET iContador = iContador+1;
				
				IF iContador = 1 THEN
					LET cAnalista1Niv = cNomEjecutivo;
				ELIF iContador = 2 THEN
					LET cAnalista2Niv = cNomEjecutivo;
				ELIF iContador = 3 THEN
					LET cAnalista3Niv = cNomEjecutivo;
				ELIF iContador = 4 THEN
					LET cAnalista4Niv = cNomEjecutivo;
				END IF
				
			END FOREACH
		END IF
		
		--se obtiene la descripcion del motivo de rechazo o cancelacion
		IF EXISTS (SELECT status FROM bdicred:'informix'.sd_causas_aumlincred WHERE status = cStatus) THEN
			SELECT causa_status||' - '||TRIM(descripcion)
			INTO cMotivo
			FROM bdicred:'informix'.sd_causas_aumlincred
			WHERE status = cStatus
			AND causa_status = cCausa;			
		END IF;

	
	INSERT INTO bdicred:'informix'.sd_rep_gral_aumlincred_auto
			(fecha_origen, num_solicitud,origen ,numcte,num_credito,apell_paterno ,apell_materno ,nombre,lincred_actual,lincred_sugerida,	
			porcentaje_incremento,status,analistaCac,analista2nivel,analista3nivel,analista4nivel,motivo,incrementoautomatico,user_insert,fecha_insert,revisioncac)
	VALUES (dtFechaInsert,cNumSol,cOrigen,cNumCte,'',cApellPaterno,cApellMaterno,cNombre, dLinCredAct, dLinCredCal,dIncremento, cStatus,
			cAnalista1Niv,cAnalista2Niv,cAnalista3Niv,cAnalista4Niv,NVL(cMotivo,''),cIncreAuto,cUser,CURRENT,iRevisionCAC);
	 LET cAnalista1Niv =''; 
	 LET cAnalista2Niv ='';
	 LET cAnalista3Niv =''; 
	 LET cAnalista4Niv ='';
	 LET cMotivo='';
	 LET iContador = 0;
	END FOREACH;  
	
	COMMIT WORK;   
 RETURN cCodRet, cMensajeRet;
		
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para migrar la información de los clientes prospectos a un incremento en su linea de crédito',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 04/03/2010',
'BD    : BDICRED',
'Version: 20110304.1210',
'-------------------------',
'MODIFICO : Mohamed Carreón',
'DESCRIPCION : Se agregan los campos de los nombres de los analistas de los que han trabajado la solicitud',
'Version: 20111110.1729';

CREATE PROCEDURE "informix".pie_edocta(pEmpresa CHAR(3),pNumCredito CHAR(20),pFechaEmision DATE)
       RETURNING CHAR(5),DATE ,CHAR(20),CHAR(8),CHAR(8),CHAR(8),CHAR(20),CHAR(3),DECIMAL(14,2),DECIMAL(14,2);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE sql_err              SMALLINT;
DEFINE sCodRet              CHAR(5);
DEFINE v_fecha_emision 	    DATE ;
DEFINE v_num_credito 	    CHAR(20);
DEFINE v_tasa_mensual 	    CHAR(8);
DEFINE v_tasa_anual 	    CHAR(8);
DEFINE v_cat 			    CHAR(8);
DEFINE v_saldo_promedio     CHAR(20);
DEFINE v_dias_periodo 	    CHAR(3);
DEFINE v_tasa_mora 		    DECIMAL(14,2);
DEFINE v_tasa_mensual_mora 	DECIMAL(14,2);



--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
LET sql_err   = 0;
LET sCodRet   = '000';
LET v_fecha_emision 		= " ";
LET v_num_credito 			= "";
LET v_tasa_mensual 			= "";
LET v_tasa_anual 			= "";
LET v_cat 					= "";
LET v_saldo_promedio 		= "";
LET v_dias_periodo 			= "";
LET v_tasa_mora 			= 0;
LET v_tasa_mensual_mora     = 0;

--SET DEBUG FILE TO "pie_edocta.out";
--TRACE ON;

BEGIN
  	  ON EXCEPTION SET sql_err
      LET sCodRet = sql_err;
      RETURN sCodRet, 
				NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""),	NVL(v_tasa_mensual,""),
				NVL(v_tasa_anual,""),	     NVL(v_cat,""),			NVL(v_saldo_promedio,""),
				NVL(v_dias_periodo,""),	     NVL(v_tasa_mora,0),	NVL(v_tasa_mensual_mora,0);
     END EXCEPTION ;


  -------------------------------------------------------------
  --GENERACION ENCABEZADO EDO CUENTA
  -------------------------------------------------------------
    SELECT 	fecha_emision, num_credito, tasa_mensual, tasa_anual, cat, saldo_promedio,
			dias_periodo, tasa_mora, tasa_mensual_mora 
      INTO 	v_fecha_emision, v_num_credito,	v_tasa_mensual, v_tasa_anual, v_cat, v_saldo_promedio,
			v_dias_periodo,	v_tasa_mora, v_tasa_mensual_mora
	  FROM  bdicred@pld_tcp:sd_pie_edocta
	 WHERE fecha_emision = pFechaEmision 
	   AND num_credito = pNumCredito;

	IF v_num_credito IS NULL THEN
		LET sCodRet = "185";
      RETURN sCodRet, 
				NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""),	NVL(v_tasa_mensual,""),
				NVL(v_tasa_anual,""),	     NVL(v_cat,""),			NVL(v_saldo_promedio,""),
				NVL(v_dias_periodo,""),	     NVL(v_tasa_mora,0),	NVL(v_tasa_mensual_mora,0);
	END IF

  RETURN sCodRet, 
				v_fecha_emision,         NVL(v_num_credito,""),	NVL(v_tasa_mensual,""),
				NVL(v_tasa_anual,""),	 NVL(v_cat,""),			NVL(v_saldo_promedio,""),
				NVL(v_dias_periodo,""),	 NVL(v_tasa_mora,0),	NVL(v_tasa_mensual_mora,0);

END;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".aclaraciones_edocta(
                                pEmpresa CHAR(3),
                                pNumCredito CHAR(20),
                                pFechaEmision DATE,
                                pNumRegistros SMALLINT)

RETURNING CHAR(5), DATE , CHAR(20),SMALLINT,SMALLINT,CHAR(10),CHAR(12),CHAR(12),CHAR(255), DECIMAL(14,2);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE sql_err             SMALLINT;
DEFINE sCodRet             CHAR(5);
DEFINE v_fecha_emision 	   DATE ;
DEFINE v_num_credito 	   CHAR(20);
DEFINE v_secuencia 		   SMALLINT;
DEFINE v_nlinea 		   SMALLINT;
DEFINE v_fecha_aclara 	   CHAR(10);
DEFINE v_descripcion 	   CHAR(255);
DEFINE v_importe 	       DECIMAL(14,2);
DEFINE v_Registros         SMALLINT;
DEFINE v_folio             CHAR(12);
DEFINE v_fecha_mov         CHAR(10);


--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
LET sql_err   = 0;
LET sCodRet   = '000';

LET v_fecha_emision = " ";
LET v_num_credito 	= "";

LET v_secuencia 	= 0;
LET v_nlinea 		= 0;
LET v_fecha_aclara 	= "";
LET v_descripcion 	= "";
LET v_importe 		= 0;
LET v_Registros    	= 0;
LET v_folio         = "";
LET v_fecha_mov     = "";

--SET DEBUG FILE TO "aclaraciones_edocta.out";
--TRACE ON;

BEGIN

		ON EXCEPTION SET sql_err
      LET sCodRet = sql_err;
      RETURN sCodRet,NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0),
						NVL(v_nlinea,0), NVL(v_fecha_aclara,""), NVL(v_folio,""),
                        NVL(v_fecha_mov,""), NVL(v_descripcion,""),
						NVL(v_importe,0);
		END EXCEPTION ;


  -------------------------------------------------------------
  --GENERACION ENCABEZADO EDO CUENTA
  -------------------------------------------------------------
	FOREACH
		SELECT	fecha_emision, num_credito,	secuencia,
				nlinea,	fecha_aclara, folio, fecha_movimiento,
                descripcion, importe
		INTO	v_fecha_emision, v_num_credito,	v_secuencia,
				v_nlinea, v_fecha_aclara, v_folio, v_fecha_mov,
                v_descripcion, v_importe

		 --FROM sd_aclaraciones_edocta
		 FROM bdicred@pld_tcp:sd_aclaraciones_edocta
		 WHERE fecha_emision = pFechaEmision AND num_credito = pNumCredito
		 ORDER BY secuencia,nlinea


		LET v_Registros = v_Registros + 1;
		IF v_Registros <= pNumRegistros THEN
				CONTINUE FOREACH;
		END IF

		IF v_num_credito IS NULL THEN
			LET sCodRet = "185";
      RETURN sCodRet,  	NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0),
						NVL(v_nlinea,0), NVL(v_fecha_aclara,""), NVL(v_folio,""),
                        NVL(v_fecha_mov,""), NVL(v_descripcion,""),
						NVL(v_importe,0);
		END IF

      RETURN sCodRet,
						v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0),
						NVL(v_nlinea,0), NVL(v_fecha_aclara,""), NVL(v_folio,""),
                        NVL(v_fecha_mov,""), NVL(v_descripcion,""),
						NVL(v_importe,0) WITH RESUME;

	END FOREACH

END;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".encabezado2_edocta(pEmpresa CHAR(3),pNumCredito CHAR(20),pFechaEmision char(10))

RETURNING CHAR(5),          DATE ,    			CHAR(20),    		DECIMAL(14,2),
		                    DECIMAL(14,2),	    DECIMAL(14,2),	    DATE,
		                    DATE,				DECIMAL(14,2),		DECIMAL(14,2),
                            DECIMAL(14,2),	    DECIMAL(14,2),		DECIMAL(14,2),
					        DECIMAL(14,2),	    DECIMAL(14,2),		DECIMAL(14,2),
                            DECIMAL(14,2),      DECIMAL(14,2),		CHAR(560),
                            DECIMAL(14,2),      DECIMAL(14,2),		DECIMAL(14,2),
                            DECIMAL(14,2),      DECIMAL(14,2),		DECIMAL(14,2),
                            DECIMAL(14,2),      DECIMAL(14,2),		DECIMAL(14,2),
                            DECIMAL(14,2),      DATE,			    DATE,
                            CHAR(255),          DECIMAL(14,2),      DECIMAL(14,2),
                            DECIMAL(14,2),      DECIMAL(14,2),      DECIMAL(14,2),
                            DECIMAL(14,2);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE sql_err   SMALLINT;
DEFINE sCodRet   CHAR(5);

DEFINE v_fecha_emision 		DATE ;
DEFINE v_num_credito 			CHAR(20);

DEFINE v_sdo_pagar 						DECIMAL(14,2);
DEFINE v_sdo_debe 						DECIMAL(14,2);
DEFINE v_sdo_disponible 			DECIMAL(14,2);
DEFINE v_pago_antes_de 				DATE;
DEFINE v_fecha_corte 					DATE;
DEFINE v_usted_debia 					DECIMAL(14,2);
DEFINE v_menos_abonos 				DECIMAL(14,2);
DEFINE v_menos_o_abonos 			DECIMAL(14,2);
DEFINE v_mas_compras 					DECIMAL(14,2);
DEFINE v_mas_o_cargos 				DECIMAL(14,2);
DEFINE v_mas_disp_efectivo 		DECIMAL(14,2);
DEFINE v_mas_intereses 				DECIMAL(14,2);
DEFINE v_mas_iva 							DECIMAL(14,2);
DEFINE v_usted_debe 					DECIMAL(14,2);
DEFINE v_mas_rendimientos 		DECIMAL(14,2);
DEFINE v_mensajes 						CHAR(560);
DEFINE v_capital_tc 					DECIMAL(14,2);
DEFINE v_interes_tc 					DECIMAL(14,2);
DEFINE v_iva_interes_tc 			DECIMAL(14,2);
DEFINE v_capital_ven_tc 			DECIMAL(14,2);
DEFINE v_interes_ven_tc 			DECIMAL(14,2);
DEFINE v_iva_interes_ven_tc 	DECIMAL(14,2);
DEFINE v_moratorios_tc 				DECIMAL(14,2);
DEFINE v_iva_moratorios_tc 		DECIMAL(14,2);
DEFINE v_interes_pago_total_tc DECIMAL(14,2);
DEFINE v_limite_tc 						DECIMAL(14,2);
DEFINE v_periodo_tc_ini 			DATE;
DEFINE v_periodo_tc_fin 			DATE;
DEFINE v_dias_periodo_tc 			CHAR(255);
DEFINE v_sus_comisiones				DECIMAL(14,2);
--INICIO-----LHM 
DEFINE v_comisiones_iva      DECIMAL(14,2);
DEFINE v_intereses_iva       DECIMAL(14,2);
DEFINE v_intereses_pag       DECIMAL(14,2);
DEFINE v_saldos_menos_pag    DECIMAL(14,2);
DEFINE v_compras_disp        DECIMAL(14,2);
--FIN--------LHM


--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
LET sql_err   = 0;
LET sCodRet   = '000';

LET v_fecha_emision 		= " ";
LET v_num_credito 			= "";

LET v_sdo_pagar 				= 0;
LET v_sdo_debe 					= 0;
LET v_sdo_disponible 		= 0;
LET v_pago_antes_de 		= " ";
LET v_fecha_corte 			= " ";
LET v_usted_debia 			= 0;
LET v_menos_abonos 			= 0;
LET v_menos_o_abonos 		= 0;
LET v_mas_compras 			= 0;
LET v_mas_o_cargos 			= 0;
LET v_mas_disp_efectivo = 0;
LET v_mas_intereses 		= 0;
LET v_mas_iva 					= 0;
LET v_usted_debe 				= 0;
LET v_mas_rendimientos 	= 0;
LET v_mensajes 					= "";
LET v_capital_tc 				= 0;
LET v_interes_tc 				= 0;
LET v_iva_interes_tc 		= 0;
LET v_capital_ven_tc 		= 0;
LET v_interes_ven_tc 		= 0;
LET v_iva_interes_ven_tc = 0;
LET v_moratorios_tc 		= 0;
LET v_iva_moratorios_tc = 0;
LET v_interes_pago_total_tc = 0;
LET v_limite_tc 				= 0;
LET v_periodo_tc_ini 		= " ";
LET v_periodo_tc_fin 		= " ";
LET v_dias_periodo_tc 	= "";
LET v_sus_comisiones		= 0;
--INICIO-----LHM 
LET v_comisiones_iva     = 0;
LET v_intereses_iva      = 0;
LET v_intereses_pag      = 0;
LET v_saldos_menos_pag   = 0;
LET v_compras_disp       = 0;



--SET DEBUG FILE TO "encabezado2_edocta.out";
--TRACE ON;

BEGIN

		ON EXCEPTION SET sql_err
      LET sCodRet = sql_err;
      RETURN sCodRet, 
				nvl(v_fecha_emision,date(1)),NVL(v_num_credito,""),				NVL(v_sdo_pagar,0),
				NVL(v_sdo_debe,0),			NVL(v_sdo_disponible,0),			NVL(v_pago_antes_de,0),
				nvl(v_fecha_corte,date(1)),				NVL(v_usted_debia,0),				NVL(v_menos_abonos,0),
				NVL(v_menos_o_abonos,0),	NVL(v_mas_compras,0),				NVL(v_mas_o_cargos,0),
				NVL(v_mas_disp_efectivo,0),	NVL(v_mas_intereses,0),             NVL(v_mas_iva,0),
				NVL(v_usted_debe,0),		NVL(v_mas_rendimientos,0),          NVL(v_mensajes,""),
				NVL(v_capital_tc,0),		NVL(v_interes_tc,0),				NVL(v_iva_interes_tc,0),
				NVL(v_capital_ven_tc,0),	NVL(v_interes_ven_tc,0),			NVL(v_iva_interes_ven_tc,0),
				NVL(v_moratorios_tc,0),		NVL(v_iva_moratorios_tc,0),         NVL(v_interes_pago_total_tc,0),
				NVL(v_limite_tc,0),			NVL(v_periodo_tc_ini,DATE(1)),		NVL(v_periodo_tc_fin,DATE(1)),
				NVL(v_dias_periodo_tc,""),	NVL(v_sus_comisiones,0),            NVL(v_comisiones_iva,0),
                NVL(v_intereses_iva,0),     NVL(v_intereses_pag,0),             NVL(v_saldos_menos_pag,0),
                NVL(v_compras_disp,0);
     END EXCEPTION ;


  -------------------------------------------------------------
  --GENERACION ENCABEZADO EDO CUENTA
  -------------------------------------------------------------
	SELECT		fecha_emision,		   num_credito,				sdo_pagar,
				sdo_debe,			   sdo_disponible,			pago_antes_de,
				fecha_corte,		   usted_debia,				menos_abonos,
				menos_o_abonos,		   mas_compras,				mas_o_cargos,
				mas_disp_efectivo,	   mas_intereses,			mas_iva,
				usted_debe,			   mas_rendimientos,		mensajes,
				capital_tc,			   interes_tc,				iva_interes_tc,
				capital_ven_tc,		   interes_ven_tc,			iva_interes_ven_tc,
				moratorios_tc,		   iva_moratorios_tc,	    interes_pago_total_tc,
				limite_tc,			   periodo_tc_ini,			periodo_tc_fin,
				dias_periodo_tc,	   sus_comisiones,          comisiones_iva,
                intereses_iva,         intereses_pag,           saldo_menos_pag,
                compras_disp
	INTO		v_fecha_emision,	   v_num_credito,			v_sdo_pagar,
				v_sdo_debe,			   v_sdo_disponible,		v_pago_antes_de,
				v_fecha_corte,		   v_usted_debia,			v_menos_abonos,
				v_menos_o_abonos,	   v_mas_compras,			v_mas_o_cargos,
				v_mas_disp_efectivo,   v_mas_intereses,			v_mas_iva,
				v_usted_debe,		   v_mas_rendimientos,		v_mensajes,
				v_capital_tc,		   v_interes_tc,			v_iva_interes_tc,
				v_capital_ven_tc,	   v_interes_ven_tc,		v_iva_interes_ven_tc,
				v_moratorios_tc,	   v_iva_moratorios_tc,	    v_interes_pago_total_tc,
				v_limite_tc,		   v_periodo_tc_ini,		v_periodo_tc_fin,
				v_dias_periodo_tc,	   v_sus_comisiones,         v_comisiones_iva,
                v_intereses_iva,       v_intereses_pag,         v_saldos_menos_pag,
                v_compras_disp

	 --FROM sd_encabezado2_edocta
	 FROM bdicred@pld_tcp:sd_encabezado2_edocta
	 WHERE fecha_emision = pFechaEmision 
	 		AND num_credito = pNumCredito;

	IF v_num_credito IS NULL THEN
		LET sCodRet = "185";
      RETURN sCodRet, 
				nvl(v_fecha_emision,date(1)),NVL(v_num_credito,""),				NVL(v_sdo_pagar,0),
				NVL(v_sdo_debe,0),			NVL(v_sdo_disponible,0),			NVL(v_pago_antes_de,0),
				nvl(v_fecha_corte,date(1)),				NVL(v_usted_debia,0),				NVL(v_menos_abonos,0),
				NVL(v_menos_o_abonos,0),	NVL(v_mas_compras,0),				NVL(v_mas_o_cargos,0),
				NVL(v_mas_disp_efectivo,0),	NVL(v_mas_intereses,0),             NVL(v_mas_iva,0),
				NVL(v_usted_debe,0),		NVL(v_mas_rendimientos,0),          NVL(v_mensajes,""),
				NVL(v_capital_tc,0),		NVL(v_interes_tc,0),				NVL(v_iva_interes_tc,0),
				NVL(v_capital_ven_tc,0),	NVL(v_interes_ven_tc,0),			NVL(v_iva_interes_ven_tc,0),
				NVL(v_moratorios_tc,0),		NVL(v_iva_moratorios_tc,0),         NVL(v_interes_pago_total_tc,0),
				NVL(v_limite_tc,0),			NVL(v_periodo_tc_ini,DATE(1)),		NVL(v_periodo_tc_fin,DATE(1)),
				NVL(v_dias_periodo_tc,""),	NVL(v_sus_comisiones,0),            NVL(v_comisiones_iva,0),
                NVL(v_intereses_iva,0),     NVL(v_intereses_pag,0),             NVL(v_saldos_menos_pag,0),
                NVL(v_compras_disp,0);
	END IF

  RETURN sCodRet, 
				v_fecha_emision,			NVL(v_num_credito,""),				NVL(v_sdo_pagar,0),
				NVL(v_sdo_debe,0),			NVL(v_sdo_disponible,0),			NVL(v_pago_antes_de,0),
				v_fecha_corte,				NVL(v_usted_debia,0),				NVL(v_menos_abonos,0),
				NVL(v_menos_o_abonos,0),	NVL(v_mas_compras,0),				NVL(v_mas_o_cargos,0),
				NVL(v_mas_disp_efectivo,0),	NVL(v_mas_intereses,0),             NVL(v_mas_iva,0),
				NVL(v_usted_debe,0),		NVL(v_mas_rendimientos,0),          NVL(v_mensajes,""),
				NVL(v_capital_tc,0),		NVL(v_interes_tc,0),				NVL(v_iva_interes_tc,0),
				NVL(v_capital_ven_tc,0),	NVL(v_interes_ven_tc,0),			NVL(v_iva_interes_ven_tc,0),
				NVL(v_moratorios_tc,0),		NVL(v_iva_moratorios_tc,0),         NVL(v_interes_pago_total_tc,0),
				NVL(v_limite_tc,0),			NVL(v_periodo_tc_ini,DATE(1)),		NVL(v_periodo_tc_fin,DATE(1)),
				NVL(v_dias_periodo_tc,""),	NVL(v_sus_comisiones,0),            NVL(v_comisiones_iva,0),
                NVL(v_intereses_iva,0),     NVL(v_intereses_pag,0),             NVL(v_saldos_menos_pag,0),
                NVL(v_compras_disp,0);

END;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_genarch_aumlcr_real (pempresa CHAR(3), pfechacorte date)

RETURNING CHAR(6);

----------------------------------------------------------------------------------------------------------------
-- Creado por: Martha A. Hernandez 
-- 06 Octubre 2011
-- Proceso para la creacion del archivo con los aumentos de lcr aceptadoss por los clientes en el mes anterior
----------------------------------------------------------------------------------------------------------------

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE vproceso				CHAR(30);
DEFINE vprocesoIncLcr		CHAR(30);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cSQL                 CHAR(8204);
DEFINE cSQL1                CHAR(6204);
DEFINE cSQL2                CHAR(6204);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cCod_RetIB           CHAR(6);
DEFINE dFechaProcIni        DATE;
DEFINE dFechaProcFin        DATE;
DEFINE dFechaHoy            DATE;
DEFINE cCodRetMesAnt        CHAR(6);
DEFINE cFechaMesAnt         DATE;
DEFINE sDiasTransMesAnt     INT;


--SET DEBUG FILE TO "/informix/mahr/sp_genarch_aumlcr_real.out";
--TRACE ON;

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0021';  -- proceso de incrementos realizados en el mes previo.
LET vprocesoIncLcr			= '0104';  -- proceso de incremento de lcr preautorizado ( sp_cat_genarch_aumlincred ) (ant 0020)
LET cruta                   = "";
LET cnombre					= "";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET cdelimitador            = "";
LET cCod_RetIB              = "000000";
LET dFechaProcIni           = DATE(1);
LET dFechaProcFin           = DATE(1);
LET cCodRetMesAnt           = "";
LET sDiasTransMesAnt        = 0;

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
                Returning cCod_RetIB;
        RETURN cCod_ret;
    END EXCEPTION;
	
    --Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '01')
            Returning cCod_RetIB;

	-- Validacion de parámetros de entrada
    IF NVL(pEmpresa,"") = "" OR NVL(pfechacorte, "") = "" THEN
        LET cCod_Ret= "104001";

        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3  AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
            Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

	--Validación de la empresa
    SELECT empresa INTO cempresa
        FROM bdinteg:"informix".si_empresas WHERE empresa = pempresa;

        IF NVL (cempresa, '') = '' OR cempresa IS NULL THEN
        LET cCod_Ret= '104002';
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
            Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

    -- Obtiene las fechas para obtener la consulta de los datos entregados como preautorizados en el mes anterior.
    SELECT pri_dia_mes, fecha_hoy INTO dFechaProcIni, dFechaProcFin
      FROM bdinteg:"informix".si_fechas  WHERE empresa = pempresa;

    IF dFechaProcIni IS NULL OR dFechaProcFin IS NULL THEN
        LET cCod_Ret=  '20013';
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 2 AND codigo_error = cCod_Ret;
        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
            Returning cCod_RetIB;
        Return cCod_Ret;
    END IF
    LET dFechaHoy = dFechaProcFin; --dFechaHoy fecha de ejecucion y que lleve la fecha en el nombre del arch

    --LET dFechaProcIni = dFechaHoy - 1 UNITS MONTH;
    EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(dFechaHoy, -1 , day(dFechaHoy)) INTO cCodRetMesAnt, cFechaMesAnt, sDiasTransMesAnt;
    LET dFechaProcIni = cFechaMesAnt;

    LET dFechaProcIni = MDY(MONTH(dFechaProcIni),1, YEAR(dFechaProcIni)); -- 1er dia del mes anterior. 

            --obtiene la ultima fecha_OK de proceso de incrementos preautorizados del mes anterior.
    SELECT MAX(fecha_ejecucion) INTO dFechaProcFin FROM bdicobranza:"informix".cb_bitacora
        WHERE empresa = pempresa AND num_proceso = vprocesoIncLcr 
            AND (fecha_ejecucion >= dFechaProcIni AND fecha_ejecucion <= cFechaMesAnt ) --(dFechaHoy - 1 UNITS MONTH))
        AND cod_ret = '000000' and mensaje = 'PROCESO FINALIZADO';

    IF dFechaProcFin IS NULL THEN
            -- en caso de NO obtener la ultima fecha OK del mes anterior. Fecha fin = Hoy - 1 mes
        LET dFechaProcFin = cFechaMesAnt; -- dFechaHoy - 1 UNITS MONTH;
    END IF;
   
	--Obtener caracter delimitador  (mismo que el arch con el aum de lcr preautorizados)
    SELECT trim(valor_alfabetico)  INTO cdelimitador
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pempresa AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS' AND num_parametro = 26;   

                            --Valida que exista el caracter
	IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        
        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
            Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

	--Obtener ruta del archivo:  /resplogifx/archivoscartera/   (mismo que el arch con el aum de lcr preautorizados)
    SELECT TRIM(valor_alfabetico) INTO cruta
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pempresa AND tipo_campania = 1 
        AND grupo_parametro = 'ARCHIVOS' AND num_parametro = 36; 

                    --Valida que exista la carpeta
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion INTO cMensaje 
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3 AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02')
            Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

	--Obtener el nombre del archivo
    SELECT TRIM(valor_alfabetico) INTO cnombre
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pempresa AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS' AND num_parametro = 37; --

		--Validar que existe el archivo
    LET cnomarchivo1 =  trim(cnombre)||'Aux'||substr(year(dFechaHoy),3)||to_char(dFechaHoy,'%m%d')||'.txt';
    LET cnomarchivo =  trim(cnombre)||substr(year(dFechaHoy),3)||to_char(dFechaHoy,'%m%d')||'.txt';

	--se ejecuta para ponerle el encabezado
	LET cSql='';
    LET cSql = 'echo "cliente' || cdelimitador || 'tarjeta' || cdelimitador || 'lcr_anterior' || cdelimitador || 'lcr_actual' || 
                    cdelimitador || 'sucursal' || ' " >' ||TRIM(cruta)|| cnomarchivo;
	system csql;
	
	LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';

    --      Cliente || Tarjeta || LCR Anterior || LCR Actual || Sucursal

    LET cSQL2 = " SELECT trim(aum.numcte) AS Cliente, substr(trim(t.num_tarjeta),13) AS Tarjeta, "
        || " aum.lincred_actual AS LCR_Anterior, dos.monto_otorgado AS LCR_actual, trim(aum.sucursal) AS Sucursal "
        || " FROM bdicred:sd_bitacora_aumlincred aum, "
        || " bdicred:sd_tarjeta t, "
        || " bdicred:sd_maesdos dos "
        || " WHERE "
        || " (aum.dfecha_cobranza >= mdy(" || month(dFechaProcIni) || "," || day(dFechaProcIni) || "," ||
                                       year(dFechaProcIni)
        || ") and aum.dfecha_cobranza <= mdy(" || month(dFechaProcFin) || "," || day(dFechaProcFin)
        || "," || year(dFechaProcFin) || ")) AND "
        || " aum.num_solicitud = t.num_credito AND "
--        || " aum.status = 'AP'  AND "
        || " aum.empresa = t.empresa AND aum.numcte = t.numcte AND "
        || " t.secuencia = (Select max(secuencia) from bdicred:sd_tarjeta "      
        || " Where empresa = aum.empresa and num_credito = aum.num_solicitud and "
        || " numcte = aum.numcte  and tipo_tarjeta = 'T' and status_tar = 'A' ) AND "
        || " dos.empresa = aum.empresa AND dos.num_credito = aum.num_solicitud ";
 

	LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_resp_aumlcr.sql';
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_resp_aumlcr.sql';
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta_resp_aumlcr.sql';
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;

	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_resp_aumlcr.sql';
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '03')
        Returning cCod_RetIB;

	RETURN cCod_ret;

END;
END PROCEDURE;