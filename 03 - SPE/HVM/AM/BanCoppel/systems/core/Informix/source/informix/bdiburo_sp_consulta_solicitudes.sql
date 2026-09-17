CREATE PROCEDURE "informix".sp_consulta_solicitudes( pInstitucion CHAR(2),precuperacion INT)
RETURNING   CHAR(5) AS codret,
			CHAR(2) AS institucion,
			CHAR(25) AS numcte,
			CHAR(25) AS num_solicitud,
			CHAR(255) AS envio,
			CHAR(255) AS envio1,
			CHAR(255) AS envio2,
			CHAR(1) AS status;
			
	--Declaraciones   Generales
	DEFINE inicio INTEGER;
	DEFINE cCodret CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE iNoRegistros INTEGER;
	DEFINE cInstitucion CHAR(2);
	DEFINE cNumcte CHAR(25);
	DEFINE cNum_solicitud CHAR(25) ;
	DEFINE cEnvio CHAR(255);
	DEFINE cEnvio1 CHAR(255);
	DEFINE cEenvio2 CHAR(255); 
	DEFINE cStatus CHAR(1) ;
	DEFINE FechaHoy DATE;
	DEFINE vfechaServ DATE;
	
	
	LET inicio ='';
	LET cCodret ='';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET cInstitucion ='';
	LET cNumcte ='';
	LET cNum_solicitud ='' ;
	LET cEnvio ='';
	LET cEnvio1 ='';
	LET cEenvio2 =''; 
	LET cStatus ='';
	LET FechaHoy = NULL;
	LET vfechaServ = NULL;
    
	BEGIN	
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodret,cInstitucion, cNumcte, cNum_solicitud,cEnvio,cEnvio1,cEenvio2,cStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/Respaldos/ipcb/tasf/sp_consulta_solicitudes.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ; 
		SET LOCK MODE TO WAIT 3;
		
		-- Carga la Fecha del Dia
		SELECT fecha_hoy	
		 INTO FechaHoy
		 FROM bdicred:sd_fechas
		WHERE empresa = '001';
		
		-- Validacion contra fecha del sistema
		SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE 
		INTO vfechaServ
		FROM sysmaster:sysshmvals;
	
		IF FechaHoy < vfechaServ THEN
			LET FechaHoy = vfechaServ;
		END IF;

		
		FOREACH
			select first precuperacion institucion,numcte,num_solicitud, envio, envio1, envio2, status 
			into cInstitucion, cNumcte, cNum_solicitud,cEnvio,cEnvio1,cEenvio2,cStatus
			from bdiburo:br_traslado where  institucion = pInstitucion and status ='0' and fecha_insert = FechaHoy
			
			
			update bdiburo:br_traslado  set status = '1' where num_solicitud = cNum_solicitud
			and  institucion = pInstitucion  and  status ='0'; 
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodret,cInstitucion, cNumcte, cNum_solicitud,cEnvio,cEnvio1,cEenvio2,cStatus WITH RESUME;	
			
		END FOREACH;	
		
		IF iNoRegistros = 0  THEN
				LET cCodRet = '00017';
				RETURN cCodret,cInstitucion, cNumcte, cNum_solicitud,cEnvio,cEnvio1,cEenvio2,cStatus;
		END IF;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez',
'FECHA:14/06/2016',
'MODULO: Demonio  ',
'FUNCIONALIDAD: Consulta de solicitudes Enviadas a BC y CC',
'DESCRIPCION: Consulta de solicitudes Enviadas a Buro y Circulo de Credito.',
'BD: bdiburo',
'------------------------------------------------------------------------------',
'AUTOR: Julio Martinez',
'FECHA:09/12/2019',
'DESCRIPCION: Se modifica la longitud de los campos de',
'Numero cliiente y numero de solicitud de 20 a 25';

CREATE PROCEDURE "informix".sp_estandarizacion_cuentas_motor(pEmpresa CHAR(4), pNumCte CHAR(20) )
    RETURNING
        CHAR(6) as cCodRet,
        INTEGER as iCollectiontradelines,
        INTEGER as iTradelines; 
    
    DEFINE iCollectiontradelines            INTEGER;
    DEFINE iTradelines                      INTEGER;
    DEFINE iHaydatos                        INTEGER; 

    DEFINE cCodigoTpNegocio                 CHAR (2);
    DEFINE cCodigoTpNegocioIq               CHAR (2);

    DEFINE cEmpresa                         CHAR(4);
    DEFINE cNumCte                          CHAR(20);
    DEFINE cTipoResponsabilidad             CHAR(2);
    DEFINE cFlagAutoTradeLine               CHAR(1);
    DEFINE cFlagCollectionTradeLine         CHAR(1);
    DEFINE cFlagLineaComer                  CHAR(1);
    DEFINE cFlagLineaComercioRevolvente     CHAR(1);
    DEFINE cIq01                            CHAR(10);
    DEFINE cTipoNegocio                     CHAR(2);
    DEFINE cTipoNegocioiq                   CHAR(20);
    DEFINE cTipoContrato                    CHAR(2);
    DEFINE cTipoCuenta                      CHAR(2);
    DEFINE iMesesTranscurridos              INTEGER;    DEFINE iMesesFechaApertura              INTEGER;    DEFINE iMesesFechaCierre                INTEGER;    DEFINE iMesesFechaHistMorGrave          INTEGER;    DEFINE iMesesFechaMasRecienteHistPagos  INTEGER;    DEFINE iMesesFechaReporte               INTEGER;    DEFINE iMesesFechaConsultaiq            INTEGER;    DEFINE cTipoMoneda                      CHAR(2);
    DEFINE iMontoNormalizado       INTEGER;    DEFINE iLimiteCreditoEstan     INTEGER;    DEFINE iSaldoActualEstan       INTEGER;    DEFINE iCreditoMaximoEstan     INTEGER;    DEFINE iSaldoMoroMasGraveEstan INTEGER;    DEFINE iSaldoVecidoEstan       INTEGER;    DEFINE iMontoCredito           INTEGER;
    DEFINE iLimiteCredito           INTEGER;
    DEFINE iSaldoActual             INTEGER;
    DEFINE iCreditoMaximo           INTEGER;
    DEFINE iSaldoMoroMasGrave       INTEGER;
    DEFINE iSaldoVecido             INTEGER;

    DEFINE dtFechaSolicitud             DATE;
    DEFINE dtFechaApertura              DATE;
    DEFINE dtFechaCierre                DATE;
    DEFINE dtFechaHistMorGrave          DATE;
    DEFINE dtFechaMasRecienteHistPagos  DATE;
    DEFINE dtFechaReporte               DATE;
    DEFINE dtFechaConsulta              DATE;
    DEFINE dtFechaConsultaiq            DATE;
    DEFINE dtFechaHoy                   DATE;

    DEFINE dtTltl DATE;
    DEFINE cTl00 CHAR(4);
    DEFINE cTl01 CHAR(10);
    DEFINE vTl02 VARCHAR(16);
    DEFINE vTl03 VARCHAR(11);
    DEFINE vTl04 VARCHAR(25);
    DEFINE mTl09 MONEY; 
    DEFINE iTl10 INTEGER; 
    DEFINE cTl11 CHAR(1); 
    DEFINE mTl12 MONEY;
    DEFINE dtTl14 DATE; 
    DEFINE dtTl15 DATE; 
    DEFINE dtTl17 DATE;
    DEFINE cTl18 CHAR(1); 
    DEFINE dtTl19 DATE; 
    DEFINE vTl20 VARCHAR(40); 
    DEFINE iTl25 INTEGER; 
    DEFINE cTl26 CHAR(2);  
    DEFINE vTl27 VARCHAR(24);  
    DEFINE dtTl29 DATE; 
    DEFINE cTl30 CHAR(2);
    DEFINE iTl31 INTEGER;  
    DEFINE iTl32 INTEGER; 
    DEFINE iTl33 INTEGER; 
    DEFINE iTl34 INTEGER; 
    DEFINE iTl35 INTEGER;
    DEFINE cTl38 CHAR(2);
    DEFINE dtTl42 DATE; 

    DEFINE ciq00_std CHAR(4);
    DEFINE viq03_std VARCHAR(11);
    DEFINE ciq04_std CHAR(2);
    DEFINE ciq05_std CHAR(2);
    DEFINE miq06_std MONEY;
    DEFINE ciq07_std CHAR(1);
    DEFINE ciq08_std CHAR(1);
    DEFINE viq09_std VARCHAR(25);

    DEFINE iHaydatosTl INTEGER;
    DEFINE iHaydatosIq INTEGER;


    --DEFINICION DE VARIABLES DE ERROR
    DEFINE MV1  INTEGER;
    DEFINE MV7  INTEGER;
    DEFINE MV9  INTEGER;
    DEFINE MV18 INTEGER;
    DEFINE MV21 INTEGER;

    DEFINE iSqlErr         INTEGER;
    DEFINE iIsamErr        INTEGER;
    DEFINE cCodRet         CHAR(6);
    DEFINE cMensaje_ret    VARCHAR(100,1); 
    
    LET cEmpresa = pEmpresa;
    LET cNumCte = pNumCte;
    LET iCollectiontradelines = 0;
    LET iTradelines           = 0;
    LET cFlagAutoTradeLine           = "";
    LET cFlagCollectionTradeLine           = "";
    LET cFlagLineaComer          = "";

    LET cFlagLineaComercioRevolvente = "";
    LET cTipoResponsabilidad  = "";
    LET cTl01                 = "";
    LET cIq01         = "";
    LET cTipoNegocio  = "";
    LET cTipoNegocioiq = "";
    LET cTipoContrato = "";
    LET cTl30         = "";
    LET iMesesTranscurridos              = 0;
    LET iMesesFechaApertura              = 0;  
    LET iMesesFechaCierre                = 0;  
    LET iMesesFechaHistMorGrave          = 0;
    LET iMesesFechaMasRecienteHistPagos  = 0;
    LET iMesesFechaReporte               = 0;
    LET iMesesFechaConsultaiq            = 0;
    LET cTipoMoneda             = "";
    LET cTipoCuenta             ="";
    LET iMontoNormalizado       = 0;
    LET iLimiteCreditoEstan     = 0;
    LET iSaldoActualEstan       = 0;
    LET iCreditoMaximoEstan     = 0;
    LET iSaldoMoroMasGraveEstan = 0;
    LET iSaldoVecidoEstan       = 0;   
    LET iMontoCredito           = 0;

    LET iLimiteCredito      = 0;    
    LET iSaldoActual        = 0;
    LET iCreditoMaximo      = 0;
    LET iCreditoMaximo      = 0;
    LET iSaldoVecido        = 0;

    LET vTl02 = "";
    LET dtFechaSolicitud           = DATE(1);
    LET dtFechaApertura            = DATE(1);
    LET dtFechaCierre              = DATE(1);
    LET dtFechaHistMorGrave        = DATE(1);
    LET dtFechaMasRecienteHistPagos = DATE(1);
    LET dtFechaReporte             = DATE(1);
    LET dtFechaConsulta            = DATE(1);
    LET dtFechaConsultaiq          = DATE(1);
    LET dtFechaHoy                 = DATE(1);

    LET dtTltl = DATE(1);
    LET cTl00 = "";
    LET vTl03 = "";
    LET vTl04 = "";
    LET mTl09 = 0; 
    LET iTl10 = 0; 
    LET cTl11 = ""; 
    LET mTl12 = 0;
    LET dtTl14 = DATE(1); 
    LET dtTl15 = DATE(1); 
    LET dtTl17 = DATE(1);
    LET cTl18 = ""; 
    LET dtTl19 = DATE(1); 
    LET vTl20 = ""; 
    LET iTl25 = 0; 
    LET cTl26 = "";  
    LET vTl27 = "";  
    LET dtTl29 = DATE(1); 
    LET iTl31 = 0;  
    LET iTl32 = 0; 
    LET iTl33 = 0;
    LET iTl34 = 0; 
    LET iTl35 = 0;
    LET cTl38 = "";
    LET dtTl42 = DATE(1); 

    LET ciq00_std = "";
    LET viq03_std = "";
    LET ciq04_std = "";
    LET ciq05_std = "";
    LET miq06_std = 0;
    LET ciq07_std = "";
    LET ciq08_std = "";
    LET viq09_std = "";

    LET iHaydatosTl = 0;
    LET iHaydatosIq = 0;

    LET cCodigoTpNegocio = "";
    LET cCodigoTpNegocioIq = "";

    --DECLARACION DE VARIABLES DE ERROR
    LET MV1  = 0;
    LET MV7  = 0;
    LET MV9  = 0;
    LET MV18 = 0;
    LET MV21 = 0;

    LET iSqlErr  = 0;
    LET iIsamErr = 0;
    LET cCodRet  ="000000";
    LET cMensaje_ret        = '';

    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr
            IF iSqlErr != 0 THEN
                LET cCodRet = iSqlErr;
                RETURN  cCodRet, iCollectiontradelines, iTradelines;
            END IF;
	    END EXCEPTION;

   
    
        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;

        LET iCollectiontradelines = 0;

        --verificar si existe info cliente
        SELECT count (numcte_std)
                INTO iHaydatosTl
                FROM bdiburo:"informix".br_tl_estand
                WHERE numcte_std = cNumCte;

        SELECT count (numcte_stdiq)
            INTO iHaydatosIq
            FROM bdiburo:"informix".br_iq_estand
            WHERE numcte_stdiq = cNumCte;
        
        IF iHaydatosTl > 0 THEN
            DELETE bdiburo:"informix".br_tl_estand WHERE numcte_std = cNumCte;
        END IF;

        IF iHaydatosIq > 0 THEN
            DELETE bdiburo:"informix".br_iq_estand WHERE numcte_stdiq = cNumCte;
        END IF;

        SELECT fecha_hoy
            INTO dtFechaHoy
            FROM bdicred:"informix".sd_fechas
            WHERE empresa = pEmpresa;


        select valor into MV1  from bdiburo:"informix".br_cat_error_estand where codigo = 'MV1';
        select valor into MV7  from bdiburo:"informix".br_cat_error_estand where codigo = 'MV7';
        select valor into MV9  from bdiburo:"informix".br_cat_error_estand where codigo = 'MV9';
        select valor into MV18 from bdiburo:"informix".br_cat_error_estand where codigo = 'MV18';
        select valor into MV21 from bdiburo:"informix".br_cat_error_estand where codigo = 'MV21';

        foreach
                SELECT LIMIT 1 fecha_insert
                    INTO dtFechaSolicitud
                    FROM bdisolic:"informix".ss_solicitudes
                    WHERE  numcte = cNumCte
                    ORDER BY fecha_insert DESC
        end foreach;

        FOREACH 
          
            SELECT tltl, tl00, tl01, tl02, tl03, tl04, tl05, tl06, tl07, tl08, tl09, tl10, tl11, tl12, tl13, tl14, 
                   tl15, tl16, tl17, tl18, tl19, tl20, tl21, tl22, tl23, tl24, tl25, tl26, tl27, tl28, tl29, tl30, 
                   tl31, tl32, tl33, tl34, tl35, tl36, tl37, tl38, tl42
            INTO   dtTltl, cTl00, cTl01, vTl02, vTl03, vTl04, cTipoResponsabilidad, cTipoCuenta, cTipoContrato,  cTipoMoneda, 
                   mTl09, iTl10, cTl11, mTl12, dtFechaApertura, dtTl14, dtTl15, dtFechaCierre, dtTl17, cTl18, dtTl19, vTl20, 
                   iCreditoMaximo,iSaldoActual, iLimiteCredito, iSaldoVecido, iTl25, cTl26, vTl27,  dtFechaMasRecienteHistPagos, 
                   dtTl29, cTl30, iTl31, iTl32, iTl33, iTl34, iTl35, iSaldoMoroMasGrave, dtFechaHistMorGrave, cTl38, dtTl42 
            FROM bdiburo:"informix".br_tl
            WHERE num_cliente = cNumCte

            

            --Proceso CHECK FOR AUTHORIZED USER TRADE LINE
            LET cFlagAutoTradeLine = 'F';
            IF cTipoResponsabilidad = 'A' THEN
                LET cFlagAutoTradeLine = 'T' ;
            END IF;
            ---

            IF cFlagAutoTradeLine = 'T' THEN
                continue foreach;
            END IF;

            LET cTipoNegocio = '';

            IF nvl(cTl01,'') <> '' THEN
                LET cTipoNegocio = substr(cTl01,1,2);
            ELIF nvl(vTl02,'') <> '' then
                SELECT codigo
                    INTO cCodigoTpNegocio
                    FROM bdiburo:"informix".br_cat_tiponegocio_estand
                    WHERE descripcion = vTl02;
                LET cTipoNegocio = cCodigoTpNegocio;
            END IF;

            --Proceso CHECK FOR COLLECTION TRADE LINE
               LET cFlagCollectionTradeLine = 'F';
            IF cTipoContrato = 'FT' OR cTl30 IN ('CL','PC') OR cTipoNegocio IN ('FT', 'YY') THEN
                LET cFlagCollectionTradeLine = 'T';
            END IF;

            ---

            IF cFlagCollectionTradeLine = 'T' THEN
                LET iCollectiontradelines = iCollectiontradelines + 1; --Contador de cuentas collections del cliente
                ----- Limpiar variables no necesarias para collections
                LET dtTltl                      = DATE(1);
                LET cTipoResponsabilidad        = "";
                LET cTipoCuenta                 ="";
                LET cTipoContrato               = "";
                LET cTipoMoneda                 = "";
                LET dtFechaCierre               = DATE(1);
                LET iCreditoMaximo              = 0;
                LET iSaldoActual                = 0;
                LET iLimiteCredito              = 0;    
                LET iSaldoVecido                = 0;
                LET dtFechaMasRecienteHistPagos = DATE(1);
                LET iSaldoMoroMasGrave          = 0;
                LET dtFechaHistMorGrave         = DATE(1);


                LET iMesesTranscurridos = 0;
                -- Proceso CALCULATE MONTHS ELAPSED SINCE DATE para tl13 iMesesFechaApertura
                IF nvl(dtFechaApertura,'') = '' THEN
                    LET iMesesTranscurridos = MV7;
                ELIF months_between (dtFechaSolicitud,dtFechaApertura) < 0  THEN
                    LET iMesesTranscurridos = MV1;
                ELSE
                    LET iMesesTranscurridos = months_between (dtFechaSolicitud,dtFechaApertura);
                END IF;
                ---
                LET iMesesFechaApertura     = iMesesTranscurridos;
                LET iSaldoActualEstan       = MV18;
                LET iCreditoMaximoEstan     = MV18;
                LET iLimiteCreditoEstan     = MV18; 
                LET iSaldoVecidoEstan       = MV18;
                LET iSaldoMoroMasGraveEstan = MV18;

            ELSE
                LET iTradelines = iTradelines + 1;

                LET iMesesTranscurridos = 0;
                -- Proceso CALCULATE MONTHS ELAPSED SINCE DATE para tl16 iMesesFechaCierre
                IF nvl(dtFechaCierre,'') ='' THEN
                    LET iMesesTranscurridos = MV7;
                ELIF months_between (dtFechaSolicitud,dtFechaCierre) < 0  THEN
                    LET iMesesTranscurridos = MV1;
                ELSE
                    LET iMesesTranscurridos = months_between (dtFechaSolicitud,dtFechaCierre);
                END IF;
                ---
                LET iMesesFechaCierre = iMesesTranscurridos;
                LET iMesesTranscurridos = 0;
                -- Proceso CALCULATE MONTHS ELAPSED SINCE DATE para tl37 iMesesFechaHistMorGrave
                IF nvl(dtFechaHistMorGrave,'') ='' THEN
                    LET iMesesTranscurridos = MV7;
                ELIF months_between (dtFechaSolicitud,dtFechaHistMorGrave) < 0  THEN
                    LET iMesesTranscurridos = MV1;
                ELSE
                    LET iMesesTranscurridos = months_between (dtFechaSolicitud,dtFechaHistMorGrave);
                END IF;
                ----
                LET iMesesFechaHistMorGrave = iMesesTranscurridos;
                LET iMesesTranscurridos = 0;
                -- Proceso CALCULATE MONTHS ELAPSED SINCE DATE para tl28 iMesesFechaMasRecienteHistPagos
                IF nvl(dtFechaMasRecienteHistPagos,'') ='' THEN
                    LET iMesesTranscurridos = MV7;
                ELIF months_between (dtFechaSolicitud,dtFechaMasRecienteHistPagos) < 0  THEN
                    LET iMesesTranscurridos = MV1;
                ELSE
                    LET iMesesTranscurridos = months_between (dtFechaSolicitud,dtFechaMasRecienteHistPagos);
                END IF;
                ----
                LET iMesesFechaMasRecienteHistPagos = iMesesTranscurridos;
                LET iMesesTranscurridos = 0;
                -- Proceso CALCULATE MONTHS ELAPSED SINCE DATE para tl13 iMesesFechaApertura
                IF nvl(dtFechaApertura,'') = '' THEN
                    LET iMesesTranscurridos = MV7;
                ELIF months_between (dtFechaSolicitud,dtFechaApertura) < 0  THEN
                    LET iMesesTranscurridos = MV1;
                ELSE
                    LET iMesesTranscurridos = months_between (dtFechaSolicitud,dtFechaApertura);
                END IF;
                ---
                LET iMesesFechaApertura = iMesesTranscurridos;
                LET iMesesTranscurridos = 0;
                -- Proceso CALCULATE MONTHS ELAPSED SINCE DATE para tl17 iMesesFechaReporte
                IF nvl(dtTl17,'') = '' THEN
                    LET iMesesTranscurridos = MV7;
                ELIF months_between (dtFechaSolicitud, dtTl17) < 0  THEN
                    LET iMesesTranscurridos = MV1;
                ELSE
                    LET iMesesTranscurridos = months_between (dtFechaSolicitud,dtTl17);
                END IF;
                ---
                LET iMesesFechaReporte = iMesesTranscurridos;
                LET iMontoNormalizado = 0;
                -- Proceso NORMALIZE AMOUNT para tl24
                IF iSaldoVecido = ' ' OR cTipoMoneda = ' ' THEN
                    LET iMontoNormalizado = MV18;
                ELIF iSaldoVecido < 0 THEN 
                    LET iMontoNormalizado = 0;
                ELIF cTipoMoneda in ('UD','US') THEN
                    LET iMontoNormalizado = MV21;
                ELIF iSaldoVecido >= 0 AND cTipoMoneda in ('MX','N$') THEN
                    LET iMontoNormalizado = iSaldoVecido;
                ELSE 
                    LET iMontoNormalizado = MV9;
                END IF;
                ----
                LET iSaldoVecidoEstan = iMontoNormalizado;
                LET iMontoNormalizado = 0;
                -- Proceso NORMALIZE AMOUNT para tl23
                IF iLimiteCredito = ' ' OR cTipoMoneda = ' ' THEN
                    LET iMontoNormalizado = MV18;
                ELIF iLimiteCredito < 0 THEN 
                    LET iMontoNormalizado = 0;
                ELIF cTipoMoneda in ('UD','US') THEN
                    LET iMontoNormalizado = MV21;
                ELIF iLimiteCredito >= 0 AND cTipoMoneda in ('MX','N$') THEN
                    LET iMontoNormalizado = iLimiteCredito;
                ELSE 
                    LET iMontoNormalizado = MV9;
                END IF;

                LET iLimiteCreditoEstan = iMontoNormalizado;
                LET iMontoNormalizado = 0;
                -- Proceso NORMALIZE AMOUNT para tl22
                IF iSaldoActual = ' ' OR cTipoMoneda = ' ' THEN
                    LET iMontoNormalizado = MV18;
                ELIF iSaldoActual < 0 THEN 
                    LET iMontoNormalizado = 0;
                ELIF cTipoMoneda in ('UD','US') THEN
                    LET iMontoNormalizado = MV21;
                ELIF iSaldoActual >= 0 AND cTipoMoneda in ('MX','N$') THEN
                    LET iMontoNormalizado = iSaldoActual;
                ELSE 
                    LET iMontoNormalizado = MV9;
                END IF;
                ----
                LET iSaldoActualEstan = iMontoNormalizado;
                LET iMontoNormalizado = 0;
                -- Proceso NORMALIZE AMOUNT para tl21
                IF to_char (iCreditoMaximo)  = ' ' OR cTipoMoneda = ' ' THEN
                    LET iMontoNormalizado = MV18;
                ELIF iCreditoMaximo < 0 THEN 
                    LET iMontoNormalizado = 0;
                ELIF cTipoMoneda in ('UD','US') THEN
                    LET iMontoNormalizado = MV21;
                ELIF iCreditoMaximo >= 0 AND cTipoMoneda in ('MX','N$') THEN
                    LET iMontoNormalizado = iCreditoMaximo;
                ELSE 
                    LET iMontoNormalizado = MV9;
                END IF;
                ----
                LET iCreditoMaximoEstan = iMontoNormalizado;
                LET iMontoNormalizado = 0;
                -- Proceso NORMALIZE AMOUNT para tl36
                IF to_char(iSaldoMoroMasGrave) = ' ' OR cTipoMoneda = ' ' THEN
                    LET iMontoNormalizado = MV18;
                ELIF iSaldoMoroMasGrave < 0 THEN 
                    LET iMontoNormalizado = 0;
                ELIF cTipoMoneda in ('UD','US') THEN
                    LET iMontoNormalizado = MV21;
                ELIF iSaldoMoroMasGrave >= 0 AND cTipoMoneda in ('MX','N$') THEN
                    LET iMontoNormalizado = iSaldoMoroMasGrave;
                ELSE 
                    LET iMontoNormalizado = MV9;
                END IF;
                ----
                LET iSaldoMoroMasGraveEstan = iMontoNormalizado;

                --Proceso CHECK FOR INSTALLMENT TRADE LINE
                LET cFlagLineaComer = 'F';
                IF cTipoCuenta in ( 'I','M') THEN
                    LET cFlagLineaComer = 'T';
                END IF;

                --Proceso CHECK FOR REVOLVING TRADE LINE
                LET cFlagLineaComercioRevolvente = 'F';                IF cTipoCuenta = 'R' AND cTipoContrato in ('CC', 'CL', 'SC', 'TE') AND cTipoNegocio not in ('UT', 'UU') THEN
                    LET cFlagLineaComercioRevolvente = 'T'; --1
                END IF;
                ----
                LET iMontoCredito = 0;
                IF (cFlagLineaComer = 'T') THEN
                    IF iCreditoMaximoEstan = MV18 OR iCreditoMaximoEstan = MV21 OR iCreditoMaximoEstan = MV9 THEN
                        LET iMontoCredito = iLimiteCreditoEstan;
                    ELSE
                        LET iMontoCredito = iCreditoMaximoEstan;
                    END IF;
                    
                ELIF (cFlagLineaComercioRevolvente = 'T') THEN
                
                    IF (iLimiteCreditoEstan = MV18 OR iLimiteCreditoEstan = MV21 OR iLimiteCreditoEstan = MV9 OR iLimiteCreditoEstan <= 100)   THEN  
                
                        LET iMontoCredito = iCreditoMaximoEstan;

                    ELIF iLimiteCreditoEstan > 100 THEN

                         LET iMontoCredito = iLimiteCreditoEstan;
                    
                    END IF;

                ELSE 
                    LET iMontoCredito = MV1;
                END IF;
            END IF;
            -- insert
               INSERT INTO bdiburo:"informix".br_tl_estand (empresa_std, numcte_std, tltl_std, tl00_std, tl01_std, tl02_std, tl03_std, tl04_std, tiporesponsabilidad_std, tipocuenta_std, tipocontrato_std, tipomoneda_std, tl09_std, tl10_std, tl11_std, tl12_std, mesesfechaapertura_std, tl14_std, tl15_std, mesesfechacierre_std, mesesfechareporte_std, tl18_std, tl19_std, ttl20_std, creditomaximoestan_std, saldoactualestan_std, limitecreditoestan_std, saldovecidoestan_std, tl25_std, tl26_std, tl27_std, mesesfechamasrecientehistpagos_std, tl29_std, tl30_std, tl31_std, tl32_std, tl33_std, tl34_std, tl35_std, saldomoromasgraveestan_std, mesesfechahistmorgrave_std, tl37_stand, tl38_std, tl42_std, montocredito_std, bandera_tradeline, bandera_collection, bandera_comercio, bandera_rev)
                values ( pEmpresa, cNumCte, dtTltl, cTl00, cTl01, cTipoNegocio, vTl03, vTl04, cTipoResponsabilidad, cTipoCuenta, cTipoContrato, cTipoMoneda, mTl09, iTl10, cTl11, mTl12, iMesesFechaApertura, dtTl14, dtTl15, iMesesFechaCierre, iMesesFechaReporte, cTl18, dtTl19, vTl20, iCreditoMaximoEstan, iSaldoActualEstan, iLimiteCreditoEstan, iSaldoVecidoEstan, iTl25, cTl26, vTl27, iMesesFechaMasRecienteHistPagos, dtTl29, cTl30, iTl31, iTl32, iTl33, iTl34, iTl35, iSaldoMoroMasGraveEstan, iMesesFechaHistMorGrave, dtFechaHistMorGrave, cTl38, dtTl42, iMontoCredito, cFlagAutoTradeLine, cFlagCollectionTradeLine, cFlagLineaComer,  cFlagLineaComercioRevolvente);
            
        END FOREACH;

        FOREACH
            SELECT iqiq, iq01, iq02, iq03, iq04, iq05, iq06, iq07, iq08, iq09
                INTO dtFechaConsultaiq, cIq01, cTipoNegocioiq, viq03_std, ciq04_std, ciq05_std, miq06_std, ciq07_std, ciq08_std, viq09_std
                FROM bdiburo:"informix".br_iq
                WHERE num_cliente = pNumCte

            IF cTipoNegocioiq = 'BANCOPPEL' and dtFechaConsultaiq = dtFechaSolicitud THEN
            CONTINUE FOREACH;
            END IF;   

            LET cCodigoTpNegocioIq = '';

            IF NVL(cIq01,'') <> '' THEN 
                LET cTipoNegocioiq = substr(cIq01,1,2);
            ELIF NVl(cTipoNegocioiq,'') <> ''  THEN
                SELECT codigo
                    INTO cCodigoTpNegocioIq
                    FROM bdiburo:"informix".br_cat_tiponegocio_estand
                    WHERE descripcion = cTipoNegocioiq;
                    LET cTipoNegocioiq = cCodigoTpNegocioIq;
            END IF;

            IF cCodigoTpNegocioIq IN ('CR', 'SI', 'ZT') THEN
            CONTINUE FOREACH;
            END IF;
            LET iMesesTranscurridos = 0;
            -- Proceso CALCULATE MONTHS ELAPSED SINCE DATE para meses iqiq
                IF nvl(dtFechaConsultaiq,'') = '' THEN
                    LET iMesesTranscurridos = MV7;
                ELIF (dtFechaSolicitud - dtFechaConsultaiq) < 0  THEN
                    LET iMesesTranscurridos = MV1;
                ELSE
                    LET iMesesTranscurridos = ( dtFechaSolicitud - dtFechaConsultaiq);
                END IF;
                ---
            LET iMesesFechaConsultaiq = iMesesTranscurridos;
            --insert
            INSERT INTO bdiburo:"informix".br_iq_estand (empresa_stdiq, numcte_stdiq, mesesfechaconsultaiq, fechaconsultaiq, iq00_std, iq01_std, iq02_std, iq03_std, iq04_std, iq05_std, iq06_std, iq07_std, iq08_std, iq09_std)
            values (cEmpresa, cNumCte, iMesesFechaConsultaiq, dtFechaConsultaiq, ciq00_std, cIq01, cTipoNegocioiq, viq03_std, ciq04_std, ciq05_std, miq06_std, ciq07_std, ciq08_std, viq09_std);

        END FOREACH;

    
        RETURN  cCodRet, iCollectiontradelines, iTradelines;
    END
END PROCEDURE
DOCUMENT 
'----------------------------------------------------------------------------',
'Descripcion : Se crea sp para Estandarizacion de la informacion de las cuentas y consultas en consulta a Sociedades de informaciÃ³n Crediticias  necesario para el armado de variables de recalibracion para motor de evaluacion',
'Modifico    : Vera Mariscal',
'Fecha       : 01/07/2022',
'BD          : BDIBURO';

create procedure "informix".burofisicas_concilia()
       returning char(5);


   define vcodret                   char(5);
   define vsql                      char(1500);
   define iTotalProcesados          integer;
   define iSqlErr                   integer;
   define tb_total_sdo_actual       decimal(20,2);
   define tb_total_sdo_vencido      decimal(20,2);
   define tb_total_seg_tl           decimal(20);
   define tb_total_sdo_actual_bc    decimal(20,2);
   define tb_total_sdo_vencido_bc   decimal(20,2);
   define tb_total_seg_tl_bc        decimal(20);
   define tb_total_cps_bc           integer;
   define tb_total_cns              integer;
   define tb_total_no_procesados    integer;
   define vdia                      char(02);
   define vmes                      char(02);
   define vanio                     char(4);
   define vfecha_cinta              date;
   define vfecha_reporte 			char(08);	
   define vclave_usu                char(10);
   define vclave_usu_bc             char(10);
   define cProceso                  char(4);
   define cMensaje                  char(50);   
   define iIsamErr                  integer;
   define vempresa                  char(3);
   define vcodret2                  char(5);
   define tb_total_seg_tl_bc_2      decimal(20); 
   define tb_total_sdo_actual_bc_2  decimal(20,2);
   define tb_total_sdo_vencido_bc_2 decimal(20,2);
   
   
   let vcodret = "000";
   let cProceso = '0057';
   let cMensaje = '';
   let iIsamErr = 0;
   let vempresa = '001';
   let vcodret2 = '';
   let tb_total_seg_tl_bc_2      = 0;
   let tb_total_sdo_actual_bc_2  = 0;
   let tb_total_sdo_vencido_bc_2 = 0;
   

   
BEGIN

   on exception set iSqlErr, iIsamErr
      if iSqlErr != 0 then
         let vcodret = iSqlErr;
		 
		 let cMensaje = trim(vcodret) || ' - ' || iIsamErr;
	     CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso, vcodret, cMensaje, '02') RETURNING vcodret2;
		 
         return vcodret;
      end if;
   end exception;

   
   let vsql = "";
   let iTotalProcesados = 0;
   let tb_total_sdo_actual     = 0;
   let tb_total_sdo_vencido    = 0;
   let tb_total_seg_tl         = 0;
   let tb_total_seg_tl_bc      = 0;
   let tb_total_sdo_actual_bc  = 0;
   let tb_total_sdo_vencido_bc = 0;
   let tb_total_cps_bc         = 0;
   let tb_total_cns         = 0;
   let tb_total_no_procesados  = 0;
   let vdia  = '';
   let vmes  = '';
   let vanio = '';
   let vfecha_cinta = date(0);
   let vfecha_reporte   = '';	
   let vclave_usu       = '';
   let vclave_usu_bc    = '';
   
   
--SET DEBUG FILE TO "/ifxsif01/macf/sics/burofisicas_concilia_clon.trc";
--TRACE ON; 

set isolation to dirty read;
set lock mode to wait 3;

   CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso, vcodret, cMensaje, '01') RETURNING vcodret2; 

   select upper(valor) into vclave_usu
      from br_param
      where cod_param = 1;

   select upper(valor) into vclave_usu_bc
      from br_param
      where cod_param = 127;

	select  first 1 fecha_reporte  INTO vfecha_reporte
	from br_burofisicas_describe;
	
   let vdia  = substr(vfecha_reporte,1,2);
   let vmes  = substr(vfecha_reporte,3,2);
   let vanio = substr(vfecha_reporte,5,4);
   let vfecha_cinta = mdy(vmes,vdia,vanio);

-- ExtracciÃ³n CÃ­rculo de CrÃ©dito
  let vsql = 'echo " unload to '''|| '/resplogifx/burodecredito/xburofis.unl'''||" delimiter '|' "||
             '" > /resplogifx/burodecredito/genburofis.sql';

  system vsql;
--                  ' trim(replace(replace(registro,'||'''BC30560001'''||','||'''TGD0924BAN'''||'),'||'''3002CV9903FIN'''||','||'''3002NV9903FIN'''||'))::lvarchar ' ||  
  let vsql = 'echo "'||
			 ' select registro from bdiburo:br_burofisicas where numreg=1' ||
             ' union ' ||
             ' select case when substr(a.registro,1,2)='||'''TL'''||' and a.registro matches '||'''*3002CV9903FIN'''||' ' ||  
             ' THEN trim((select registro from bdiburo:br_burofisicas where numreg=a.numreg-3))::lvarchar ||' || 
                  ' trim((select registro from bdiburo:br_burofisicas where numreg=a.numreg-2))::lvarchar ||' ||
                  ' trim((select registro from bdiburo:br_burofisicas where numreg=a.numreg-1))::lvarchar||' || 
--                  ' trim(replace(registro,'||'''BC30560001'''||','||'''TGD0924BAN'''||'))::lvarchar ' ||  
                  ' trim(replace(registro,'''||vclave_usu_bc||''','''||vclave_usu||'''))::lvarchar ' ||  
             ' ELSE trim((select registro from bdiburo:br_burofisicas where numreg=a.numreg-3))::lvarchar||' ||
                  ' trim((select registro from bdiburo:br_burofisicas where numreg=a.numreg-2))::lvarchar||' ||  
                  ' trim((select registro from bdiburo:br_burofisicas where numreg=a.numreg-1))::lvarchar||' ||  
--                 ' trim(replace(registro,'||'''BC30560001'''||','||'''TGD0924BAN'''||'))::lvarchar' ||  
                 ' trim(replace(registro,'''||vclave_usu_bc||''','''||vclave_usu||'''))::lvarchar' ||  
             ' END' ||  
             ' from bdiburo:br_burofisicas a where substr(a.registro,1,2)='||'''TL'''||' '||  
             ' union ' ||  
             ' select '||'''TRLR'''||'||lpad(sum(saldo_actual)::dec(14,0),14,'||'''0'''||')||'||''''''||'||lpad(sum(saldo_venc)::dec(14,0),14,'||'''0'''||')' ||  
             ' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||  ''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||   ''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||
             '''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  			 
             --' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||' ||  
             --' '||'''000000000'''||'||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||'''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  
             ' from bdiburo:br_burofisicas_describe;' ||
             ' " >> /resplogifx/burodecredito/genburofis.sql';

  system vsql;

  let vsql = 'dbaccess bdiburo /resplogifx/burodecredito/genburofis.sql';
  system vsql;

  let vsql = "sed 's/&/ /g' /resplogifx/burodecredito/xburofis.unl > /resplogifx/burodecredito/xburofis1.unl ";
  system vsql;

  let vsql = "sed 's/[~]*|//g' /resplogifx/burodecredito/xburofis1.unl > /resplogifx/burodecredito/xburofis2.unl ";
  system vsql;

  let vsql = "sed 's/|//g' /resplogifx/burodecredito/xburofis2.unl > /resplogifx/burodecredito/xburofis1.unl ";
  system vsql;

  --LET vsql = "cat  /resplogifx/burodecredito/xburofis1.unl | tr -d '\n' > /resplogifx/burodecredito/cinta_circulo"||vfecha_reporte||".txt ";
  LET vsql = "cat  /resplogifx/burodecredito/xburofis1.unl | tr -d '\n' > /resplogifx/burodecredito/cinta_circulo"||vfecha_reporte||".txt ";
  SYSTEM vsql;

  let vsql = "rm /resplogifx/burodecredito/xburofis.unl /resplogifx/burodecredito/xburofis1.unl /resplogifx/burodecredito/xburofis2.unl";     
  system vsql;     

  let vsql = "gzip /resplogifx/burodecredito/cinta_circulo"||vfecha_reporte||".txt ";
  system vsql;

  let vsql = '';

-- ExtracciÃ³n BurÃ³ de CrÃ©dito
  let vsql = 'echo " unload to '''|| '/resplogifx/burodecredito/xburofis_bc.unl'''||" delimiter '|' "||
             '" > /resplogifx/burodecredito/genburofis_bc.sql';

  system vsql;
--                  ' trim(replace(registro,'||'''3002CV9903FIN'''||','||'''3002NV9903FIN'''||'))::lvarchar ' ||  
  let vsql = 'echo "'||
--             ' select replace(registro,'||'''TGD0924BAN'''||','||'''BC30560001'''||') from bdiburo:br_burofisicas where numreg=1' ||
             ' select replace(registro,'''||vclave_usu||''','''||vclave_usu_bc||''') from bdiburo:br_burofisicas where numreg=1' ||
             ' union ' ||
             ' select case when substr(a.registro,1,2)='||'''TL'''||' and a.registro matches '||'''*3002CV9903FIN'''||' ' ||
             ' THEN trim((select registro from bdiburo:br_burofisicas where numreg=a.numreg-3))::lvarchar ||' ||  
                  ' trim((select registro from bdiburo:br_burofisicas where numreg=a.numreg-2))::lvarchar ||' || 
                  ' trim((select registro from bdiburo:br_burofisicas where numreg=a.numreg-1))::lvarchar||' || 
--                  ' trim(replace(registro,'||'''TGD0924BAN'''||','||'''BC30560001'''||'))::lvarchar ' || 
                  ' trim(replace(registro,'''||vclave_usu||''','''||vclave_usu_bc||'''))::lvarchar ' || 
             ' ELSE trim((select registro from bdiburo:br_burofisicas where numreg=a.numreg-3))::lvarchar||' ||  
                  ' trim((select registro from bdiburo:br_burofisicas where numreg=a.numreg-2))::lvarchar||' ||
                  ' trim((select registro from bdiburo:br_burofisicas where numreg=a.numreg-1))::lvarchar||' ||  
--                  ' trim(replace(registro,'||'''TGD0924BAN'''||','||'''BC30560001'''||'))::lvarchar ' ||  
                  ' trim(replace(registro,'''||vclave_usu||''','''||vclave_usu_bc||'''))::lvarchar ' ||  
             ' END' ||  
--             ' from bdiburo:br_burofisicas a where substr(a.registro,1,2)='||'''TL'''||' and substr(registro,11,10)='||'''BC30560001'''||' '||  
             ' from bdiburo:br_burofisicas a where substr(a.registro,1,2)='||'''TL'''||
             ' union ' ||  
             ' select '||'''TRLR'''||'||lpad(sum(saldo_actual)::dec(14,0),14,'||'''0'''||')||'||''''''||'||lpad(sum(saldo_venc)::dec(14,0),14,'||'''0'''||')' ||  
             --' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||' ||  
             --' '||'''000000000'''||'||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||'''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  
             ' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||  ''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||   ''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||
             '''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  			 
--             ' from bdiburo:br_burofisicas_describe where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas where substr(registro,1,2)='||'''TL'''||' and substr(registro,11,10)='||'''BC30560001'''||');' ||
             ' from bdiburo:br_burofisicas_describe '||
             ' " >> /resplogifx/burodecredito/genburofis_bc.sql';

  system vsql;

  let vsql = 'dbaccess bdiburo /resplogifx/burodecredito/genburofis_bc.sql';
  system vsql;

  let vsql = "sed 's/&/ /g' /resplogifx/burodecredito/xburofis_bc.unl > /resplogifx/burodecredito/xburofis1_bc.unl ";
  system vsql;
/*  */
  let vsql = "sed 's/[~]*|//g' /resplogifx/burodecredito/xburofis1_bc.unl > /resplogifx/burodecredito/xburofis2_bc.unl ";
  system vsql;

  let vsql = "sed 's/|//g' /resplogifx/burodecredito/xburofis2_bc.unl > /resplogifx/burodecredito/xburofis1_bc.unl ";
  system vsql;

  --LET vsql = "cat  /resplogifx/burodecredito/xburofis1_bc.unl | tr -d '\n' > /resplogifx/burodecredito/cinta_buro"||vfecha_reporte||".txt ";  --MACF
  LET vsql = "cat  /resplogifx/burodecredito/xburofis1_bc.unl | tr -d '\n' > /resplogifx/burodecredito/cinta_buro"||vfecha_reporte||".txt "; 
  SYSTEM vsql;

  let vsql = "rm /resplogifx/burodecredito/xburofis_bc.unl /resplogifx/burodecredito/xburofis1_bc.unl /resplogifx/burodecredito/xburofis2_bc.unl";   
  system vsql;    

  let vsql = "gzip /resplogifx/burodecredito/cinta_buro"||vfecha_reporte||".txt ";
  system vsql;

  /* Se desactiva, ya que en br_burofisicas_concilia no se estÃ  guardando algo en el proc. burofisicas --- 20200831 MACF
  let vsql = 'echo "------ CIFRAS GENERALES ------" > /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;
  
  select count(*) into tb_total_cns from br_burofisicas_concilia where empresa = '001' and motivo = 'CNS' and fecha_cinta = vfecha_cinta;

  let vsql = 'echo " CrÃ©ditos excluidos por ser Clientes Nuevos = => '||tb_total_cns|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

  select count(*) into tb_total_no_procesados from br_burofisicas_concilia where empresa = '001' and motivo = 'CNP' and fecha_cinta = vfecha_cinta;

  let vsql = 'echo " CrÃ©ditos no procesados = => '||tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

  select int_calculo into iTotalProcesados from br_burofisicas_concilia where empresa = '001' and motivo = 'TCP' and fecha_cinta = vfecha_cinta;
  
  let vsql = 'echo " TOTAL crÃ©ditos procesados = => '||iTotalProcesados|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;
  */
  
  --let vsql = 'echo "------ CIFRAS BURO DE CREDITO ------" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  let vsql = 'echo "------ CIFRAS BURO DE CREDITO ------" > /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

--  select count(*) into tb_total_seg_tl_bc from bdiburo:br_burofisicas_describe where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas where substr(registro,1,2)='TL' and substr(registro,11,10)='BC30560001');
    -- Para segmento de productos sin tarjeta
    select count(*) into tb_total_seg_tl_bc from bdiburo:br_burofisicas_describe where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas where substr(registro,1,2)='TL' and substr(registro,11,10)=vclave_usu);
    -- Para segmento de productos con tarjeta
    select count(*) into tb_total_seg_tl_bc_2 from bdiburo:br_burofisicas_describe where num_tarjeta in (select substr(registro,38,16) from bdiburo:br_burofisicas where substr(registro,1,2)='TL' and substr(registro,11,10) = vclave_usu);


  let vsql = 'echo " CrÃ©ditos reportados = => '||tb_total_seg_tl_bc+tb_total_seg_tl_bc_2|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

  select count(*) into tb_total_cps_bc from br_burofisicas_concilia where empresa = '001' and motivo = 'CPS' and fecha_cinta = vfecha_cinta;

  let vsql = 'echo " CrÃ©ditos excluidos por error en CÃ³digo Postal = => '||tb_total_cps_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " CrÃ©ditos excluidos por ser Clientes Nuevos = => '||tb_total_cns|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " CrÃ©ditos no procesados = => '||tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

--  let vsql = 'echo " TOTAL CrÃ©ditos procesados BurÃ³ de CrÃ©dito = => '||tb_total_seg_tl_bc+tb_total_cps_bc+tb_total_cns+tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  let vsql = 'echo " TOTAL CrÃ©ditos procesados BurÃ³ de CrÃ©dito = => '||tb_total_seg_tl_bc+tb_total_seg_tl_bc_2+tb_total_cns+tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo "------ S a l d o s  Reportados a BurÃ³ de CrÃ©dito------" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

  select lpad(sum(saldo_actual)::dec(14,0),14,"0"),lpad(sum(saldo_venc)::dec(14,0),14,"0") into tb_total_sdo_actual_bc, tb_total_sdo_vencido_bc
  from bdiburo:br_burofisicas_describe where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas where substr(registro,1,2)='TL' and substr(registro,11,10)=vclave_usu);

  select lpad(sum(saldo_actual)::dec(14,0),14,"0"),lpad(sum(saldo_venc)::dec(14,0),14,"0") into tb_total_sdo_actual_bc_2,tb_total_sdo_vencido_bc_2
  from bdiburo:br_burofisicas_describe where num_tarjeta in (select substr(registro,38,16) from bdiburo:br_burofisicas where substr(registro,1,2)='TL' and substr(registro,11,10)=vclave_usu);
--  from bdiburo:br_burofisicas_describe where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas where substr(registro,1,2)='TL' and substr(registro,11,10)='BC30560001');

  let vsql = 'echo " Saldo actual = => '||tb_total_sdo_actual_bc+tb_total_sdo_actual_bc_2|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Saldo vencido = => '||tb_total_sdo_vencido_bc+tb_total_sdo_vencido_bc_2|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo "------ CIFRAS CIRCULO DE CREDITO ------" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

--  select count(*) into tb_total_seg_tl from bdiburo:br_burofisicas_describe; 

--  let vsql = 'echo " CrÃ©ditos reportados = => '||tb_total_seg_tl|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  let vsql = 'echo " CrÃ©ditos reportados = => '||tb_total_seg_tl_bc+tb_total_seg_tl_bc_2|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " CrÃ©ditos excluidos por ser Clientes Nuevos = => '||tb_total_cns|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " CrÃ©ditos no procesados = => '||tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

--  let vsql = 'echo " TOTAL CrÃ©ditos procesados CÃ­rculo de CrÃ©dito = => '||tb_total_seg_tl + tb_total_cns + tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  let vsql = 'echo " TOTAL CrÃ©ditos procesados CÃ­rculo de CrÃ©dito = => '||tb_total_seg_tl_bc+tb_total_seg_tl_bc_2+ tb_total_cns + tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo "------ S a l d o s  Reportados a CÃ­rculo de CrÃ©dito------" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

--  select lpad(sum(saldo_actual)::dec(14,0),14,"0"),lpad(sum(saldo_venc)::dec(14,0),14,"0") into tb_total_sdo_actual,tb_total_sdo_vencido
--  from bdiburo:br_burofisicas_describe;

--  let vsql = 'echo " Saldo actual = => '||tb_total_sdo_actual|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  let vsql = 'echo " Saldo actual = => '||tb_total_sdo_actual_bc+tb_total_sdo_actual_bc_2|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

--  let vsql = 'echo " Saldo vencido = => '||tb_total_sdo_vencido|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  let vsql = 'echo " Saldo vencido = => '||tb_total_sdo_vencido_bc+tb_total_sdo_vencido_bc_2|| '" >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrol'||vfecha_reporte||'.txt';
  system vsql;

  CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso, vcodret, cMensaje, '03') RETURNING vcodret2; 
  
  return vcodret;

END;
end procedure
DOCUMENT
'DESCRIPCION: Modificaciones para RQM 09 502 Reportar por numero TDC a SICs',
'Autor: Marco A. Campos',
'Fecha: 2019/03/21',
'Version: 1.1',
'Autor: Marco A. Campos',
'DescripciÃ³n: Se corrige el contador Segmento TR para contador de PE',
'Fecha: 20230425';

CREATE PROCEDURE "informix".burocred(pempresa CHAR(3),psucursal CHAR(4),pusuario CHAR(8),pSolicitud CHAR(20),pMontoSol MONEY(14,2))
RETURNING  CHAR(05) AS codret;

--EXECUTE PROCEDURE burocred('001','0142','prueba','',1500.00);

---------------DECLARACION DE VARIABLES
	DEFINE vregistro CHAR(255);
	DEFINE vregistro1 CHAR(255);
    DEFINE vregistro2 CHAR(255);
	DEFINE vcliente CHAR(20);
	DEFINE vlen INTEGER;
	DEFINE vpos CHAR(2);
	DEFINE vpo1 CHAR(5);
	DEFINE vdia CHAR(2);
	DEFINE vmes CHAR(2);
	DEFINE vanio CHAR(4);
	-- Variables para ver si se va a Buro o no --
	DEFINE vf1mes DATE;
	DEFINE vstatus CHAR(2);
	DEFINE vcodret CHAR(5);
	DEFINE vecampo1 CHAR(4);
	DEFINE vecampo2 CHAR(2);
	DEFINE vecampo3 CHAR(25);
	DEFINE vecampo4 CHAR(3);
	DEFINE vecampo5 CHAR(2);
	DEFINE vecampo6 CHAR(4);
	DEFINE vecampo7 CHAR(10);
	DEFINE vecampo8 CHAR(8);
	DEFINE vecampo9 CHAR(1);
	DEFINE vecampo10 CHAR(2);
	DEFINE vecampo11 CHAR(2);
	DEFINE vecampo12 CHAR(9);
	DEFINE vecampo13 CHAR(2);
	DEFINE vecampo14 CHAR(2);
	DEFINE vecampo15 CHAR(1);
	DEFINE vecampo16 CHAR(4);
	DEFINE vecampo17 CHAR(7);
	DEFINE vexiste INTEGER;
	DEFINE vcodini INTEGER;
	DEFINE vcodfin INTEGER;
	-- Datos del Cliente --
	DEFINE vdcampo1 CHAR(2);
	DEFINE vdcampo2 CHAR(26);
	DEFINE vdcampo3 CHAR(26);
	DEFINE vdcampo4 CHAR(26);
	DEFINE vdcampo5 CHAR(26);
	DEFINE vdcampo6 CHAR(10);
	DEFINE vdcampo7 CHAR(13);
	DEFINE vdcampo8 CHAR(2);
	DEFINE vdcampo9 CHAR(1);
	DEFINE vdcampo10 CHAR(1);
	DEFINE vdcampo11 CHAR(1);
	DEFINE vdcampo12 CHAR(2);
	DEFINE vscampo1 CHAR(2);
	DEFINE vscampo2 CHAR(40);
	DEFINE vscampo3 CHAR(40);
	DEFINE vscampo3_1 CHAR(40);
	DEFINE vscampo3_2 CHAR(40);
	DEFINE vscampo4 CHAR(40);
	DEFINE vscampo5 CHAR(40);
	DEFINE vscampo6 CHAR(40);
	DEFINE vscampo7 CHAR(4);
	DEFINE vscampo8 CHAR(5);
	DEFINE vscampo8a INTEGER;
	DEFINE vscampo9 CHAR(1);
	DEFINE vexiste1 SMALLINT;
	DEFINE vquita CHAR(40);
	DEFINE vespacio CHAR(1);
	DEFINE vmanzana SMALLINT;
	DEFINE vandador SMALLINT;
	DEFINE vlote SMALLINT;
	DEFINE vedificio SMALLINT;
	DEFINE ventrada SMALLINT;
	DEFINE vsecuencia SMALLINT;
	DEFINE vcomentario CHAR(80);
	DEFINE vhora datetime HOUR TO fraction(3);
	DEFINE vfecha DATE;
	DEFINE status_1      CHAR(2);  ---cambio CAS
	DEFINE status_2      CHAR(2);  ---cambio CAS
	DEFINE producto_sol  CHAR(20);
	DEFINE siglas_producto  CHAR(2);
	DEFINE cResultado  CHAR(6);
	DEFINE cMensajeRes  CHAR(8);
	DEFINE iSql_err      INTEGER;
	
    DEFINE vnumerocalle INTEGER;
	DEFINE iFlag2credito         SMALLINT;
	
	DEFINE valida_hit CHAR(1);
    DEFINE wBegin       CHAR(1);
	
	-- RQM 09 554 - Consulta a las SICÃÂ¯ÃÂ¿ÃÂ½s.
	DEFINE cFlujo_cc CHAR(1);
	DEFINE status_consul           	CHAR(2);
	DEFINE cCanalSol	CHAR (2);
	-- RQI Originacion solicitudes 24 x 7
	DEFINE vfechaServ DATE;
	DEFINE vConsAleat	INTEGER;	DEFINE vFalloSIC	INTEGER;
---------------INICIALIZACION DE VARIABLES
	LET vhora = extend(CURRENT,HOUR TO fraction(3));
	LET vregistro ="";
	LET vregistro1="";
	LET vregistro2="";
	LET vcliente ="";
	LET vlen =0;
	LET vpos="";
	LET vdia="";
	LET vmes="";
	LET vanio="";
	LET vf1mes="";
	LET vstatus="";
	LET vcodret="000";
    LET status_1="00";
    LET status_2="00";
    LET producto_sol = "";
    LET siglas_producto = "";
	LET cResultado = "";
	LET cMensajeRes = "";
	LET iSql_err        = 0 ;
	LET vpo1 = "";
	LET vecampo1 = "";
	LET vecampo2 = "";
	LET vecampo3 = "";
	LET vecampo4 = "";
	LET vecampo5 = "";
	LET vecampo6 = "";
	LET vecampo7 = "";
	LET vecampo8 = "";
	LET vecampo9 = "";
	LET vecampo10 = "";
	LET vecampo11 = "";
	LET vecampo12 = "";
	LET vecampo13 = "";
	LET vecampo14 = "";
	LET vecampo15 = "";
	LET vecampo16 = "";
	LET vecampo17 = "";
	LET vexiste = 0;
	LET vcodini = 0;
	LET vcodfin = 0;
	LET vdcampo1 = "";
	LET vdcampo2 = "";
	LET vdcampo3 = "";
	LET vdcampo4 = "";
	LET vdcampo5 = "";
	LET vdcampo6 = "";
	LET vdcampo7 = "";
	LET vdcampo8 = "";
	LET vdcampo9 = "";
	LET vdcampo10 = "";
	LET vdcampo11 = "";
	LET vdcampo12 = "";
	LET vscampo1 = "";
	LET vscampo2 = "";
	LET vscampo3 = "";
	LET vscampo3_1 = "";
	LET vscampo3_2 = "";
	LET vscampo4 = "";
	LET vscampo5 = "";
	LET vscampo6 = "";
	LET vscampo7 = "";
	LET vscampo8 = "";
	LET vscampo8a = 0;
	LET vscampo9 = "";
	LET vexiste1 = 0;
	LET vquita = "";
	LET vespacio = "";
	LET vmanzana = 0;
	LET vandador = 0;
	LET vlote = 0;
	LET vedificio = 0;
	LET ventrada = 0;
	LET vsecuencia = 0;
	LET vcomentario = "";

    LET vnumerocalle = 0;
	LET iFlag2credito = 0;
	
	LET valida_hit ="";
	LET wBegin = "N";
	
	LET cFlujo_cc = '0';
	LET status_consul           ='';
	LET cCanalSol = '';
	LET vConsAleat	= 0;	LET vFalloSIC	= 0;
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err 
		IF iSql_err <> 0 THEN
			LET vcodret = iSql_err;		
			RETURN vcodret;
		END IF;
	END EXCEPTION;
	
	 ON EXCEPTION IN (-535)
      LET wBegin = "S";
     -- ROLLBACK WORK;
	 commit work;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;
--SET DEBUG FILE TO '/informix/jesus/burocred.out';
--TRACE ON;
--SET DEBUG FILE TO '/RESPALDOS/ipcb/pruebas/burocred_pam.out';   TRACE ON;
begin work;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	
	SELECT fecha_hoy 
	INTO vfecha 
	FROM bdicred:"informix".sd_fechas
  WHERE empresa='001';
  
    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE 
	INTO vfechaServ
	FROM sysmaster:sysshmvals;
	
	IF vfecha < vfechaServ THEN
		LET vfecha = vfechaServ;
	END IF;
	
	IF psucursal = '0001' THEN   -- SE CAMBIA PARA QUE RECIBA 0001 AL IGUAL QUE EL SP QUE LE MANDA ESTA CADENA.
		SELECT numcte,num_producto
		INTO vcliente,producto_sol
		FROM bdicred:"informix".sd_maecred
		WHERE num_credito = pSolicitud
		AND empresa = pempresa;
		
		LET vstatus = pusuario;
	ELSE
SELECT a.numcte,a.num_producto,a.status_solicitud,NVL(c.flag2credito,0)
		INTO vcliente,producto_sol,vstatus, iFlag2credito
		FROM bdisolic:"informix".ss_solicitudes a
		INNER JOIN bdisolic:"informix".ss_resum_scor_fin b ON ( b.num_solicitud = a.num_solicitud) 
		LEFT  JOIN bdisolic:"informix".ss_revision_determinacion c ON ( c.num_solicitud = a.num_solicitud) 
		WHERE a.empresa = "001" 
		AND a.num_solicitud =pSolicitud;
/*
		SELECT numcte,num_producto,status_solicitud 
		INTO vcliente,producto_sol,vstatus
		FROM bdisolic:"informix".ss_solicitudes 
		WHERE empresa = "001" 
		AND num_solicitud =pSolicitud;
*/
			--RQM 09 308 Se agrega validacion para cuando sea una solicitud aperturada se consulte la tabla de incremento
			IF vstatus = "AP" THEN
				/*
				SELECT DISTINCT(numcte),num_producto,status
				INTO vcliente,producto_sol,vstatus
				FROM  bdicred:"informix".sd_bitacora_aumlincred 
				WHERE empresa = "001" AND num_solicitud =pSolicitud;*/
				-- AAME INC 27 042 IncidenciaReenvioIncrementosBCyCC Se Agrega un filtro de Maxima fecha insert
				SELECT DISTINCT(numcte),num_producto,status
				INTO vcliente,producto_sol,vstatus
				FROM  bdicred:"informix".sd_bitacora_aumlincred 
				WHERE empresa = "001" AND num_solicitud =pSolicitud
                AND fecha_insert = (SELECT MAX(fecha_insert)  FROM  bdicred:"informix".sd_bitacora_aumlincred 
                                     WHERE empresa = "001" AND num_solicitud =pSolicitud AND status IN ('BC','CC'));
			END IF;
		
	END IF;
	
	IF vstatus <> "BC" AND vstatus <> "CC" and psucursal = "8503" THEN
	    LET vstatus ="BC";
	END IF;
    IF TRIM(vstatus) = "RR" THEN
           LET vregistro="ERRRUR25";
           LET vcodret="260";
	   RETURN vcodret;
    END IF
   -- Declaracion de Constantes para Generacion de Registros desea ver que significa cada campo
   -- Favor de consultar el manual -->
	LET vecampo1="INTL";
	LET vecampo2="11";
--- COLOCACION DE NUMERO DE SOLICITUD
	LET vecampo3 =pSolicitud||"     ";
	LET vecampo4="001";
	LET vecampo5="MX";
	LET vecampo6="0000";
	LET vecampo7    = "";
	LET vecampo8    = "";
	LET vecampo9="I";
	LET vecampo10="";	LET vecampo11="MX";
	LET vecampo12="0"; --monto solicitado
	LET vecampo13="SP";
	LET vecampo14="03";	LET vecampo15=" ";
	LET vecampo16="    ";
	LET vecampo17="0000000";
	LET vexiste=0;
	LET vcomentario = "";
-- Consulta las siglas correspondientes al producto solicitado
       SELECT codigo
         INTO siglas_producto
         FROM "informix".br_tltco
        WHERE num_producto = producto_sol;

        LET vecampo10 = siglas_producto;
		
--ini CAS consulta de institucion
		
		SELECT canal_sol INTO cCanalSol FROM bdisolic:"informix".ss_solicitudes 
		WHERE numcte = vcliente AND num_solicitud = pSolicitud;
		
		/*SELECT insti1 INTO status_consul FROM bdisolic:"informix".ss_canales_solic 
		WHERE canal_solic = cCanalSol;*/
		
		--Inicio: RQM 09 606 consulta sic aleatorio y Fallo de SIC
		--Tomar la ultima solicitud de la SIC
		SELECT institucion, FalloSIC, consul_aleatoria
			INTO status_consul, vFalloSIC, vConsAleat
			FROM bdisolic:"informix".ss_solicitudes_sic
			WHERE ROWID = (SELECT MAX(rowid)
						   FROM bdisolic:"informix".ss_solicitudes_sic
						   WHERE numcte= vcliente
							AND num_solicitud = pSolicitud);
		
		IF status_consul IS NULL THEN  --Valida que se tenga registro de la solicitud
			LET vregistro="NOSIC";
			LET vcodret="001";			RETURN vcodret;
		END IF;
		--Validar si la solicitud no trae fallo por ser BCScore
		/*IF status_consul = 'CC' AND vFalloSIC = 0 THEN
			--Validar si en el historial tiene envio a BC
			IF EXISTS (SELECT status_solicitud FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud = pSolicitud AND status_solicitud = 'BC') THEN
				LET status_consul = 'BC';--Es respuesta de BCScore
			END IF;
		END IF;*/
		--Fin: RQM 09 606 consulta sic aleatorio y Fallo de SIC
		
		IF status_consul = 'CC' THEN
			LET cFlujo_cc = '1';
		END IF;
		
		IF cFlujo_cc = '1' THEN
			SELECT status_solicitud
			INTO status_2
			FROM bdisolic:"informix".ss_status_sol 
			WHERE empresa=pempresa 
			AND tipo_auto="1";

			SELECT status_solicitud
			INTO status_1
			FROM bdisolic:"informix".ss_status_sol 
			WHERE empresa=pempresa 
			AND tipo_auto="2";
		
		ELSE
			SELECT status_solicitud
			INTO status_2
			FROM bdisolic:"informix".ss_status_sol 
			WHERE empresa=pempresa 
			AND tipo_auto="2";

			SELECT status_solicitud
			INTO status_1
			FROM bdisolic:"informix".ss_status_sol 
			WHERE empresa=pempresa 
			AND tipo_auto="1";
		
		END IF;
		
            IF vstatus="CC" THEN
                SELECT TRIM(valor) INTO vecampo7
                  FROM "informix".br_param
                  WHERE cod_param = 1;
                SELECT TRIM(valor) INTO vecampo8
                  FROM "informix".br_param
                  WHERE cod_param = 2;
--IPCB Marzo2016 RQM 09 398-0 FICO Extended				  
				SELECT  evalua_cc  INTO  valida_hit
                  FROM  bdisolic:ss_resum_scor_fin
                  WHERE num_solicitud = pSolicitud;
				
				--IF  valida_hit <> "X" THEN
				IF  valida_hit IS NULL OR valida_hit <> "X" THEN
--IPCBjul15 --FICO SCORE               
					IF cFlujo_cc = '0' THEN
					   SELECT TRIM(valor)INTO vecampo4
						  FROM bdiburo:br_param
						  WHERE cod_param = 141;
					ELSE
					--Consultar nuevo parametro de consulta a CC
                          /*SELECT TRIM(valor)INTO vecampo4
                              FROM bdiburo:br_param
                              WHERE cod_param = 152;*/
							  
						SELECT prodcc INTO vecampo4
						FROM bdisolic:"informix".ss_canales_solic 
						WHERE canal_solic = cCanalSol;
						
					END IF;
				ELSE 
--IPCB Marzo2016--FICO Extended	
              	SELECT TRIM(valor)INTO vecampo4
                  FROM bdiburo:br_param
                 WHERE cod_param = 142;
				END IF;
            ELIF vstatus='BC' THEN
			
				IF cFlujo_cc = '0' THEN
					SELECT TRIM(valor) INTO vecampo7
					  FROM "informix".br_param
					  WHERE cod_param = 124;
					SELECT TRIM(valor) INTO vecampo8
					  FROM "informix".br_param
					  WHERE cod_param = 125;
				
					IF iFlag2credito =1 THEN
						-- JMAH INI ICC
						SELECT TRIM(valor) INTO vecampo4
						FROM "informix".br_param
						WHERE cod_param = 11;
						-- JMAH INI BCSCORE
					ELSE				
						-- JOM INI BCSCORE
						SELECT TRIM(valor) INTO vecampo4
						FROM "informix".br_param
						WHERE cod_param = 126;

						-- JOM INI BCSCORE
					END IF;
					
				ELSE
					IF iFlag2credito =1 THEN
						SELECT TRIM(valor) INTO vecampo7
						  FROM "informix".br_param
					     WHERE cod_param = 124;
						 
						SELECT TRIM(valor) INTO vecampo8
					      FROM "informix".br_param
					     WHERE cod_param = 125;
						 
						-- JMAH INI ICC
						SELECT TRIM(valor) INTO vecampo4
						FROM "informix".br_param
						WHERE cod_param = 11;
						-- JMAH INI BCSCORE
					ELSE
						--Usuario Prospector
						select trim(valor) into vecampo7
						from bdiburo:br_param
						where cod_param = 154; 
						
						--Password Prospector
						select trim(valor) into vecampo8
						from bdiburo:br_param
						where cod_param = 155;   
						
						--Numero de producto Prospector
						select trim(valor) into vecampo4
						from bdiburo:br_param
						where cod_param = 153;  
					END IF;  
				END IF;
				
            END IF;
			
  LET vecampo12=LPAD(round(pMontoSol,0),9,"0");
  LET vregistro= vecampo1||vecampo2||vecampo3||vecampo4||vecampo5||
	     vecampo6||vecampo7||vecampo8||vecampo9||vecampo10||vecampo11||vecampo12||vecampo13||
	     vecampo14||vecampo15||vecampo16||vecampo17;
	-- Datos del Cliente --
	LET vdcampo1="PN"; --Identificador de cadena--
	LET vdcampo2=""; --Apellido Paterno PN--
	LET vdcampo3=""; --Apellido Materno 00--
	LET vdcampo4=""; --Primer Nombre 02--
	LET vdcampo5=""; --Segundo Nombre 03--
	LET vdcampo6=""; --Fecha de Nacimiento 04--
	LET vdcampo7=""; --RFC 05--
	LET vdcampo8="MX"; --Nacionalidad MX o EX 08--
	LET vdcampo9=""; --Residencia o Tipo Vivienda 09 1=Prop 2=Renta 3=Pension--
	LET vdcampo10=""; --Estado Civil 11 --
	LET vdcampo11=""; --Sexo 12--
	LET vdcampo12=""; --Dependiente 17--
	-- Direccion del Cliente --
	LET vscampo1="PA"; --Identificador de cadena--
	LET vscampo2=""; --Direccion Linea 1 PA--
	LET vscampo3=""; --Direccion Linea 2 00--
	LET vscampo3_1=""; --Direccion Linea 2 00--EXT
	LET vscampo3_2=""; --Direccion Linea 2 00--INT
	LET vscampo4=""; --Colonia o Poblacion 01--
	LET vscampo5=""; --Delegacion o Municipio 02--
	LET vscampo6=""; --Nombre Ciudad 03--
	LET vscampo7=""; --Estado 04--
	LET vscampo8=""; --Codigo Postal 05--
	LET vscampo9=""; --Tipo de Domicilio 10--

	SELECT TRIM(apell_paterno), TRIM(apell_materno), TRIM(nombre1),
  	        TRIM(nombre2),fecha_nac, CASE WHEN LENGTH(trim(rfc_alterno)) = 13 THEN rfc_alterno ELSE rfc END, TRIM(habita_en),
  	         TRIM(estado_civil),TRIM(sexo), NVL(dependientes,"0")
		    INTO vdcampo2,vdcampo3,vdcampo4,
                        vdcampo5,vdcampo6,vdcampo7,vdcampo9,
                        vdcampo10,vdcampo11,vdcampo12
		    FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_ctepf b
		    WHERE a.numcte = b.numcte  AND b.numcte = vcliente;

	  -- Cambia las Ã de los Nombres y Apellidos --
         IF vdcampo2 IS NULL THEN LET vdcampo2 = ""; LET vcomentario = "Apellido paterno nulo"; END IF;
         IF vdcampo3 IS NULL THEN LET vdcampo3 = "NO PROPORCIONADO"; END IF;
         IF vdcampo4 IS NULL THEN LET vdcampo4 = ""; LET vcomentario = TRIM(vcomentario)||" Sin nombre"; END IF;
         IF vdcampo5 IS NULL THEN LET vdcampo5 = ""; END IF;
         IF vdcampo6 IS NULL THEN LET vdcampo6 = ""; END IF;
         IF vdcampo7 IS NULL THEN LET vdcampo7 = ""; END IF;
         IF vdcampo9 IS NULL THEN LET vdcampo9 = ""; END IF;
         IF vdcampo10 IS NULL THEN LET vdcampo10 = ""; END IF;
         IF vdcampo11 IS NULL THEN LET vdcampo11 = ""; END IF;
         IF vdcampo12 IS NULL THEN LET vdcampo12 = "0"; END IF;
         LET vexiste = LENGTH(vdcampo2);
         LET vexiste1 = 0;
         LET vquita = "";
         LET vespacio = " ";
         WHILE vexiste1 < vexiste
           IF vdcampo2[1,1]="~" OR vdcampo2[1,1]=" " OR vdcampo2[1,1]="." OR
           vdcampo2[1,1]="-"  THEN
              LET vespacio = "F";
           ELSE
             IF vespacio = "F" THEN
               IF vdcampo2[1,1] = "#" OR vdcampo2[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||" Ã";
               ELSE
                 LET vquita = TRIM(vquita)||" "||vdcampo2[1,1];
               END IF
               LET vespacio ="";
             ELSE
               IF vdcampo2[1,1] = "#" OR vdcampo2[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||"Ã";
               ELSE
                 LET vquita = TRIM(vquita)||vdcampo2[1,1];
               END IF
             END IF
           END IF;
           LET vdcampo2 = vdcampo2[2,26];
           LET vexiste1 = vexiste1 + 1;
         END WHILE;
         LET vdcampo2 = TRIM(vquita);
         LET vexiste = LENGTH(vdcampo3);
     --- CAMBIO DE APELLIDO MATERNO
         IF vexiste = 0 THEN
            LET vdcampo3 = "NO PROPORCIONADO";
            LET vexiste = LENGTH(vdcampo3);
         END IF
         LET vexiste1 = 0;
         LET vquita = "";
         LET vespacio = " ";
         WHILE vexiste1 < vexiste
           IF vdcampo3[1,1]="~" OR vdcampo3[1,1]=" " OR vdcampo3[1,1]="." OR
            vdcampo3[1,1]="-" THEN
              LET vespacio = "F";
           ELSE
             IF vespacio = "F" THEN
               IF vdcampo3[1,1] = "#" OR vdcampo3[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||" Ã";
               ELSE
                 LET vquita = TRIM(vquita)||" "||vdcampo3[1,1];
               END IF
               LET vespacio ="";
             ELSE
               IF vdcampo3[1,1] = "#" OR vdcampo3[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||"Ã";
               ELSE
                 LET vquita = TRIM(vquita)||vdcampo3[1,1];
               END IF
             END IF
           END IF;
           LET vdcampo3 = vdcampo3[2,26];
           LET vexiste1 = vexiste1 + 1;
         END WHILE;
         LET vdcampo3 = TRIM(vquita);
         LET vexiste = LENGTH(vdcampo4);
         LET vexiste1 = 0;
         LET vquita = "";
         LET vespacio = " ";
         WHILE vexiste1 < vexiste
           IF vdcampo4[1,1]="~" OR vdcampo4[1,1]=" "  OR vdcampo4[1,1]="." OR
            vdcampo4[1,1]="-" THEN
              LET vespacio = "F";
           ELSE
             IF vespacio = "F" THEN
               IF vdcampo4[1,1] = "#" OR vdcampo4[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||" Ã";
               ELSE
                 LET vquita = TRIM(vquita)||" "||vdcampo4[1,1];
               END IF
               LET vespacio ="";
             ELSE
               IF vdcampo4[1,1] = "#" OR vdcampo4[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||"Ã";
               ELSE
                 LET vquita = TRIM(vquita)||vdcampo4[1,1];
               END IF
             END IF
           END IF;
           LET vdcampo4 = vdcampo4[2,26];
           LET vexiste1 = vexiste1 + 1;
         END WHILE;
         LET vdcampo4 = TRIM(vquita);
         LET vexiste = LENGTH(vdcampo5);
         LET vexiste1 = 0;
         LET vquita = "";
         LET vespacio =" ";
         WHILE vexiste1 < vexiste
           IF vdcampo5[1,1]="~" OR vdcampo5[1,1]=" " OR vdcampo5[1,1]="." OR
            vdcampo5[1,1]="-" THEN
              LET vespacio ="F";
           ELSE
            IF vespacio = "F" THEN
               IF vdcampo5[1,1] = "#" OR vdcampo5[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||" Ã";
               ELSE
                 LET vquita = TRIM(vquita)||" "||vdcampo5[1,1];
               END IF
	       LET vespacio ="";
            ELSE
               IF vdcampo5[1,1] = "#" OR vdcampo5[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||"Ã";
               ELSE
                 LET vquita = TRIM(vquita)||vdcampo5[1,1];
               END IF
            END IF
           END IF;
           LET vdcampo5 = vdcampo5[2,26];
           LET vexiste1 = vexiste1 + 1;
         END WHILE;
         LET vdcampo5 = TRIM(vquita);
         IF vdcampo9 ="P" OR vdcampo9 ="G" THEN
	       	   LET vdcampo9="1";
	 ELSE
	   IF vdcampo9 ="R" THEN 
	    LET vdcampo9="2";
	   ELSE
	     IF vdcampo9 ="F"  OR vdcampo9 = "H" THEN 
	       LET vdcampo9="3";
	     ELSE
	      LET vdcampo9="";
	     END IF
	   END IF
	 END IF
         IF vdcampo10 ="D" THEN
	       	   LET vdcampo10="D";
	 ELSE
	   IF vdcampo10 ="U" THEN
	    LET vdcampo10="F";
	   ELSE
	     IF vdcampo10 ="C" THEN
	       LET vdcampo10="M";
	     ELSE
	      IF vdcampo10 ="S" THEN
	         LET vdcampo10="S";
	      ELSE
	         IF vdcampo10 ="V" THEN
		    LET vdcampo10="W";
	         END IF
	      END IF
	     END IF
	   END IF
	 END IF
	-- Carga los datos de la Direccion del Cliente --
    --SELECT MAX(secuencia) INTO vsecuencia
    --  FROM bdinteg:"informix".si_direcciones
	--           WHERE  numcte=vcliente AND tipo_dir='1';


     -- SELECT TRIM(f.nombrecalle),
	  SELECT case when substr(f.nombrecalle,1,1) in('0','1','2','3','4','5','6','7','8','9') then "CALLE "||trim(f.nombrecalle) else trim(f.nombrecalle) end nombrecalle,
          -- REPLACE(NVL(TRIM(a.numeroextcalle)," ")||" "||NVL(TRIM(a.numerointcalle)," "),'	',''),--Se quitan los tabuladores INC 21 119
		   REPLACE(NVL(TRIM(a.numeroextcalle)," "),'	',''),
		   REPLACE(NVL(TRIM(a.numerointcalle)," "),'	',''),
           TRIM(g.nombrezona), 
       TRIM(g.municipiozona), TRIM(c.estado), lpad(TRIM(a.cod_postal),5,"0"), a.tipo_dir,
           manzana,andador,lote,edificio,entrada,codini,codfin, nvl(a.numerocalle,0)
       INTO   vscampo2, vscampo3_1,vscampo3_2, vscampo4,
              vscampo6, vscampo7,vscampo8,vscampo9,
              vmanzana,vandador,vlote,vedificio,ventrada,vcodini,vcodfin, vnumerocalle
       FROM  bdinteg:"informix".si_direcciones_actual as a,
                 bdisolic:"informix".ss_circulo_edos as c,
                 bdinteg:"informix".si_catcalles f,
                 bdinteg:"informix".si_catzonas g
       WHERE  a.numcte=vcliente AND a.tipo_dir = '1' 
         AND c.clave = a.estado 
         AND g.numerociudad = a.numerociudad
         AND g.numerocolonia = a.numerocolonia
         AND f.numerocalle = a.numerocalle;	
	
		IF (vscampo2 is null or vnumerocalle = 0) and (SELECT COUNT(num_solicitud) 					
				FROM bdisolic:"informix".ss_solicitudes_movil							
				WHERE 	empresa  = pEmpresa 
				AND  num_solicitud = pSolicitud
				AND status <> '3' ) > 0 THEN				
				
                --SELECT TRIM(a.calle),
				SELECT case when substr(a.calle,1,1) in('0','1','2','3','4','5','6','7','8','9') then "CALLE "||trim(a.calle) else trim(a.calle) end nombrecalle,
                --REPLACE(NVL(TRIM(a.numeroextcalle)," ")||" "||NVL(TRIM(a.numerointcalle)," "),'	',''),--Se quitan los tabuladores INC 21 119
				REPLACE(NVL(TRIM(a.numeroextcalle)," "),'	',''),
				REPLACE(NVL(TRIM(a.numerointcalle)," "),'	',''),
                TRIM(g.nombrezona), 
                TRIM(g.municipiozona), TRIM(c.estado), lpad(TRIM(a.cod_postal),5,"0"), a.tipo_dir,
                manzana,andador,lote,edificio,entrada,codini,codfin 
                INTO   vscampo2, vscampo3_1,vscampo3_2, vscampo4,
                vscampo6, vscampo7,vscampo8,vscampo9,
                vmanzana,vandador,vlote,vedificio,ventrada,vcodini,vcodfin
                FROM  bdinteg:"informix".si_direcciones_actual as a,
                     bdisolic:"informix".ss_circulo_edos as c,					 
                     bdinteg:"informix".si_catzonas g
                WHERE  a.numcte=vcliente AND a.tipo_dir = '1' 
                AND c.clave = a.estado 
                AND g.numerociudad = a.numerociudad
                AND g.numerocolonia = a.numerocolonia;								
		END IF;		
	
	   	
       IF vscampo2 IS NULL THEN LET vscampo2 = "";  LET vcomentario = TRIM(vcomentario)||" Sin calle "; END IF;
       --IF vscampo3 IS NULL THEN LET vscampo3 = ""; END IF;
	   IF    vscampo3_1 IS NULL     OR nvl(vscampo3_1,'') = ''    OR nvl(vscampo3_1,'') = 'S/N' or
		 nvl(vscampo3_1,'') = 'S/n' or nvl(vscampo3_1,'') = 's/N' or nvl(vscampo3_1,'') = 's/n' or
				vscampo3_1 = '0'   or         vscampo3_1 = '00'  or     vscampo3_1 = '000'     or 
				vscampo3_1 = '0000' THEN  LET vscampo3_1 = "SN"; END IF;
				 
	   IF    vscampo3_2 IS NULL     OR nvl(vscampo3_2,'') = ''    OR nvl(vscampo3_2,'') = 'S/N' or
	     nvl(vscampo3_2,'') = 'S/n' or nvl(vscampo3_2,'') = 's/N' or nvl(vscampo3_2,'') = 's/n' or
                 vscampo3_2 = '0'   or         vscampo3_2 = '00'  or     vscampo3_2 = '000'     or 
				 vscampo3_2 = '0000' THEN  LET vscampo3_2 = "SN"; END IF;
				 
	   LET vscampo3=  REPLACE(NVL(TRIM(vscampo3_1)," ")||" "||NVL(TRIM(vscampo3_2)," "),'	','');
       IF vscampo4 IS NULL THEN LET vscampo4 = ""; END IF;
       IF vscampo5 IS NULL THEN LET vscampo5 = ""; END IF;
       IF vscampo6 IS NULL THEN LET vscampo6 = ""; LET vcomentario = TRIM(vcomentario)||" Sin localidad "; END IF;
       IF vscampo7 IS NULL THEN LET vscampo7 = ""; LET vcomentario = TRIM(vcomentario)||" Sin estado "; END IF;
       IF vscampo8 IS NULL THEN LET vscampo8 = ""; LET vcomentario = TRIM(vcomentario)||" Sin codigo postal "; END IF;
       IF vscampo9 IS NULL THEN LET vscampo9 = ""; END IF;
       LET vscampo2 = TRIM(vscampo2)||" "||TRIM(vscampo3);
       LET vexiste = LENGTH(vscampo2);
       IF vexiste < 40 THEN
         LET vscampo3 = "";
         IF vmanzana > 0 THEN
           LET vscampo3 ="mza "||vmanzana;
         END IF
         IF vandador > 0 THEN
           LET vscampo3 =TRIM(vscampo3)||"AND "||vandador;
         END IF
         IF vlote > 0 THEN
           LET vscampo3 =TRIM(vscampo3)||"lt "||vlote;
         END IF
         IF vedificio > 0 THEN
           LET vscampo3 =TRIM(vscampo3)||"ed "||vedificio;
         END IF
         IF ventrada > 0 THEN
           LET vscampo3 =TRIM(vscampo3)||"ent "||ventrada;
         END IF
       LET vscampo2 = TRIM(vscampo2)||' '||TRIM(vscampo3);
       END IF
       LET vscampo2 = TRIM(vscampo2);
       LET vexiste = LENGTH(vscampo2);
       LET vexiste1 = 0;
       LET vquita = "";
       LET vespacio = " ";
       WHILE vexiste1 < vexiste
        IF vscampo2[1,1]="~" OR vscampo2[1,1]=" " OR vscampo2[1,1]="." OR
         vscampo2[1,1]="-" THEN
           LET vespacio = "F";
        ELSE
          IF vespacio = "F" THEN
            IF vscampo2[1,1] = "#" OR vscampo2[1,1] = "Â¥" THEN
              LET vquita = TRIM(vquita)||" Ã";
            ELSE
              LET vquita = TRIM(vquita)||" "||vscampo2[1,1];
            END IF
            LET vespacio = "";
          ELSE
            IF vscampo2[1,1] = "#" OR vscampo2[1,1] = "Â¥" THEN
              LET vquita = TRIM(vquita)||"Ã";
            ELSE
              LET vquita = TRIM(vquita)||vscampo2[1,1];
            END IF
          END IF
        END IF;
        LET vscampo2 = vscampo2[2,40];
        LET vexiste1 = vexiste1 + 1;
       END WHILE;
       LET vscampo2 = TRIM(vquita);
       IF vscampo9 ="1" THEN
	   LET vscampo9="H";
       ELSE
         IF vscampo9 ="2" THEN
           LET vscampo9="B";
         ELSE
           LET vscampo9="H";
         END IF
       END IF

    LET vregistro=TRIM(vregistro)||vdcampo1;
    LET vlen=LENGTH(vdcampo2);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||vpos||vdcampo2;
    LET vlen=LENGTH(vdcampo3);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"00"||vpos||vdcampo3;
    LET vlen=LENGTH(vdcampo4);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"02"||vpos||vdcampo4;
    LET vlen=LENGTH(vdcampo5);
    LET vpos=LPAD(vlen,2,"0");
    IF vlen  > 0 THEN
      LET vregistro=TRIM(vregistro)||"03"||vpos||vdcampo5;
    END IF

    LET vlen=LENGTH(vdcampo6);
    IF vlen  > 0 THEN
    LET vdia=vdcampo6[4,5];
    LET vdia=LPAD(vdia,2,"0");
    LET vmes=vdcampo6[1,2];
    LET vmes=LPAD(vmes,2,"0");
    LET vanio=vdcampo6[7,10];
    LET vdcampo6=vdia||vmes||vanio;
    LET vlen=LENGTH(vdcampo6);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"04"||vpos||vdcampo6;
    END IF;
    LET vlen=LENGTH(vdcampo7);
    IF vlen  > 0 THEN
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"05"||vpos||vdcampo7;
    END IF;
    LET vlen=LENGTH(vdcampo8);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"08"||vpos||vdcampo8;
 --- Este es el campo correspondiente a la residencia
    IF vdcampo9 = "1" OR vdcampo9 = "2" OR vdcampo9 = "3" THEN
     LET vlen=LENGTH(vdcampo9);
     LET vpos=LPAD(vlen,2,"0");
     LET vregistro=TRIM(vregistro)||"09"||vpos||vdcampo9;
    END IF
    LET vlen =LENGTH(vdcampo10);
    IF vlen  > 0 THEN
      LET vpos=LPAD(vlen,2,"0");
      LET vregistro=TRIM(vregistro)||"11"||vpos||vdcampo10;
    END IF
    LET vlen=LENGTH(vdcampo11);
    IF vlen  > 0 THEN
      LET vpos=LPAD(vlen,2,"0");
      LET vregistro=TRIM(vregistro)||"12"||vpos||vdcampo11;
    END IF
    IF TRIM(vdcampo12) != "0" THEN
       IF LENGTH(TRIM(vdcampo12)) < 2 THEN
         LET vdcampo12 = "0"||TRIM(vdcampo12);
       END IF
       LET vlen=LENGTH(vdcampo12);
       LET vpos=LPAD(vlen,2,"0");
       LET vregistro=TRIM(vregistro)||"17"||vpos||vdcampo12;
    ELSE
       LET vregistro=TRIM(vregistro)||"170201";
    END IF
    LET vregistro=TRIM(vregistro)||vscampo1;
    LET vlen=LENGTH(vscampo2);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro1=vpos||vscampo2;
    LET vscampo3 = "";
    LET vexiste = LENGTH(vscampo3);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
     IF vscampo3[1,1]="~" OR vscampo3[1,1]=" " OR vscampo3[1,1]="." OR
      vscampo3[1,1]="-" THEN
       LET vespacio = "F";
     ELSE
      IF vespacio = "F" THEN
        IF vscampo3[1,1] = "#" OR vscampo3[1,1] = "Â¥" THEN
           LET vquita = TRIM(vquita)||" Ã";
        ELSE
           LET vquita = TRIM(vquita)||" "||vscampo3[1,1];
        END IF
	LET vespacio = "";
      ELSE
        IF vscampo3[1,1] = "#" OR vscampo3[1,1] = "Â¥" THEN
	   LET vquita = TRIM(vquita)||"Ã";
        ELSE
	   LET vquita = TRIM(vquita)||vscampo3[1,1];
        END IF
      END IF
     END IF;
     LET vscampo3 = vscampo3[2,26];
     LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vscampo3 = TRIM(vquita);
    LET vlen=LENGTH(vscampo3);
    LET vpos=LPAD(vlen,2,"0");
    --LET vregistro1='00'||vpos|| vscampo3;
    LET vexiste = LENGTH(vscampo4);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
     IF vscampo4[1,1]="~" OR vscampo4[1,1]=" " OR vscampo4[1,1]="." OR
      vscampo4[1,1]="-" THEN
       LET vespacio = "F";
     ELSE
      IF vespacio = "F" THEN
        IF vscampo4[1,1] = "#" OR vscampo4[1,1] = "Â¥" THEN
	  LET vquita = TRIM(vquita)||" Ã";
        ELSE
	  LET vquita = TRIM(vquita)||" "||vscampo4[1,1];
        END IF
        LET vespacio = "";
      ELSE
        IF vscampo4[1,1] = "#" OR vscampo4[1,1] = "Â¥" THEN
	  LET vquita = TRIM(vquita)||"Ã";
        ELSE
	  LET vquita = TRIM(vquita)||vscampo4[1,1];
        END IF
      END IF
     END IF;
     LET vscampo4 = vscampo4[2,26];
     LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vscampo4= TRIM(vquita);
    LET vlen=LENGTH(vscampo4);
    LET vpos= LPAD(vlen,2,"0");
    IF vlen > 0 THEN
    LET vregistro1= TRIM(vregistro1)||"01"||vpos|| vscampo4;
    END IF
{    LET vexiste = LENGTH(vscampo5);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
     IF vscampo5[1,1]="~" OR vscampo5[1,1]=" " OR vscampo5[1,1]="." THEN
       LET vespacio = "F";
     ELSE
      IF vespacio = "F" THEN
        IF vscampo5[1,1] = "#" OR vscampo5[1,1] = "Â¥" THEN
	  LET vquita = TRIM(vquita)||" Ã ";
	  LET vespacio = "";
        ELSE
	  LET vquita = TRIM(vquita)||" "||vscampo5[1,1];
	  LET vespacio = "";
        END IF
      ELSE
        IF vscampo5[1,1] = "#" OR vscampo5[1,1] = "Â¥" THEN
	  LET vquita = TRIM(vquita)||"Ã";
        ELSE
	  LET vquita = TRIM(vquita)||vscmpo5[1,1];
        END IF
      END IF
     END IF;
     LET vscampo5 = vscampo5[2,26];
     LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vscampo5 = TRIM(vquita);
    LET vlen= LENGTH(vscampo5);
    LET vpos= LPAD(vlen,2,'0');
    LET vregistro1= TRIM(vregistro1)||'02'||vpos||vscampo5;
}
    LET vexiste = LENGTH(vscampo6);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
     IF vscampo6[1,1]="~" OR vscampo6[1,1]=" " OR vscampo6[1,1]="." OR
      vscampo6[1,1]="-" THEN
       LET vespacio = "F";
       LET vexiste1 = vexiste1 + 1;
       LET vscampo6 = vscampo6[2,26];
     ELSE
      IF vespacio = "F" THEN
        IF vscampo6[1,22] = "MUNICIPIO DE ( OTROS )" THEN
	    LET vquita = TRIM(vquita);
            LET vexiste1 = vexiste1 + 22;
            LET vscampo6 = vscampo6[23,26];
        ELSE
          IF vscampo6[1,12] = "MUNICIPIO DE"  THEN
	    LET vquita = TRIM(vquita);
            LET vexiste1 = vexiste1 + 12;
            LET vscampo6 = vscampo6[13,26];
          ELSE
           IF vscampo6[1,1] = "#" OR vscampo6[1,1] = "Â¥" THEN
	     LET vquita = TRIM(vquita)||" Ã";
           ELSE
	     LET vquita = TRIM(vquita)||" "||vscampo6[1,1];
           END IF
	   LET vespacio = "";
           LET vexiste1 = vexiste1 + 1;
           LET vscampo6 = vscampo6[2,26];
          END IF;
        END IF;
      ELSE
        IF vscampo6[1,1] = "#" OR vscampo6[1,1] = "Â¥" THEN
	  LET vquita = TRIM(vquita)||"Ã";
        ELSE
	  LET vquita = TRIM(vquita)||vscampo6[1,1];
        END IF
        LET vexiste1 = vexiste1 + 1;
        LET vscampo6 = vscampo6[2,26];
      END IF
     END IF;
    END WHILE;
    LET vscampo6 = TRIM(vquita);
    LET vlen= LENGTH(vscampo6);
    LET vpos= LPAD(vlen,2,'0');
    LET vregistro1= TRIM(vregistro1)||"03"||vpos||vscampo6;
    LET vexiste = LENGTH(vscampo7);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
     IF vscampo7[1,1]="~" OR vscampo7[1,1]=" " OR vscampo7[1,1]="." OR
      vscampo7[1,1]="-" THEN
       LET vespacio = "F";
     ELSE
      IF vespacio = "F" THEN
        IF vscampo7[1,1] = "#" OR vscampo7[1,1] = "Â¥" THEN
	  LET vquita = TRIM(vquita)||" Ã";
          LET vespacio = "";
        ELSE
	  LET vquita = TRIM(vquita)||" "||vscampo7[1,1];
	  LET vespacio = "";
        END IF
      ELSE
        IF vscampo7[1,1] = "#" OR vscampo7[1,1] = "Â¥" THEN
	   LET vquita = TRIM(vquita)||vscampo7[1,1];
        ELSE
	   LET vquita = TRIM(vquita)||vscampo7[1,1];
        END IF
      END IF
     END IF;
     LET vscampo7 = vscampo7[2,4];
     LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vscampo7 = TRIM(vquita);
    LET vlen= LENGTH(vscampo7);
    LET vpos= LPAD(vlen,2,"0");
    LET vregistro1= TRIM(vregistro1)||"04"||vpos||vscampo7;
{    IF vscampo8[1,1] = 1 OR vscampo8[1,1] = 2 OR vscampo8[1,1] = 3 OR vscampo8[1,1] = 4 OR vscampo8[1,1] = 5 OR vscampo8[1,1] = 6 OR
     vscampo8[1,1] = 7 OR vscampo8[1,1] = 8 OR vscampo8[1,1] = 9  THEN
      LET vscampo8a = vscampo8[1,1] * 10000;
    ELSE
      LET vscampo8a = 0;
    END IF
    IF vscampo8[2,2] = 1 OR vscampo8[2,2] = 2 OR vscampo8[2,2] = 3 OR vscampo8[2,2] = 4 OR vscampo8[2,2] = 5 OR vscampo8[2,2] = 6 OR
     vscampo8[2,2] = 7 OR vscampo8[2,2] = 8 OR vscampo8[2,2] = 9  THEN
      LET vscampo8a = vscampo8a + vscampo8[2,2] * 1000;
    ELSE
      LET vscampo8a = vscampo8a + 0;
    END IF
    IF vscampo8[3,3] = 1 OR vscampo8[3,3] = 2 OR vscampo8[3,3] = 3 OR vscampo8[3,3] = 4 OR vscampo8[3,3] = 5 OR vscampo8[3,3] = 6 OR
     vscampo8[3,3] = 7 OR vscampo8[3,3] = 8 OR vscampo8[3,3] = 9  THEN
      LET vscampo8a = vscampo8a + vscampo8[3,3] * 100;
    ELSE
      LET vscampo8a = vscampo8a + 0;
    END IF
    IF vscampo8[4,4] = 1 OR vscampo8[4,4] = 2 OR vscampo8[4,4] = 3 OR vscampo8[4,4] = 4 OR vscampo8[4,4] = 5 OR vscampo8[4,4] = 6 OR
     vscampo8[4,4] = 7 OR vscampo8[4,4] = 8 OR vscampo8[4,4] = 9  THEN
      LET vscampo8a = vscampo8a + vscampo8[4,4] * 10;
    ELSE
      LET vscampo8a = vscampo8a + 0;
    END IF
    IF vscampo8[5,5] = 1 OR vscampo8[5,5] = 2 OR vscampo8[5,5] = 3 OR vscampo8[5,5] = 4 OR vscampo8[5,5] = 5 OR vscampo8[5,5] = 6 OR
     vscampo8[5,5] = 7 OR vscampo8[5,5] = 8 OR vscampo8[5,5] = 9  THEN
      LET vscampo8a = vscampo8a + vscampo8[5,5] ;
    ELSE
      LET vscampo8a = vscampo8a + 0;
    END IF
    IF vscampo8a < vcodini OR vscampo8a > vcodfin THEN
       LET vscampo8 = LPAD(round(vcodini),5,"0");
    END IF }
    LET vlen= LENGTH(vscampo8);
    LET vpos= LPAD(vlen,2,"0");
    LET vregistro2='05'||vpos||vscampo8;
    LET vlen= LENGTH(vscampo9);
    LET vpos= LPAD(vlen,2,'0');
    LET vregistro2=TRIM(vregistro2)||'10'||vpos||vscampo9;
    -- Marca el FIN de Trailer -->
   LET vlen= LENGTH(vregistro)+LENGTH(vregistro1)+LENGTH(vregistro2);
   LET vlen= TRUNC(vlen + 15);
   LET vpo1= LPAD(vlen,5,'0');
   LET vregistro2=TRIM(vregistro2)||'ES05'||vpo1||'0002**';
--INI CAS CAMBIO DE ORDEN DE CONSULTA BURO Y CIRCULO
   IF vstatus=status_1 THEN
		   ---mandamos llamar el sp para respaldar la informaciÃ³n de la consulta previa a buro del cliente       --JMAH
		    EXECUTE PROCEDURE "informix".sp_generarespaldoshistoricosic(vcliente,pSolicitud,status_1,1) INTO cResultado,cMensajeRes;	
			EXECUTE PROCEDURE "informix".sp_generarespaldoshistoricosic(vcliente,pSolicitud,status_2,1) INTO cResultado,cMensajeRes;
   
				DELETE FROM "informix".br_traslado WHERE num_solicitud = pSolicitud;
				DELETE FROM "informix".sb_regreso WHERE num_solicitud = pSolicitud;
		--IPCB Mayo2016 Reingenieria de Demonios.
				DELETE FROM "informix".br_respuesta WHERE num_solicitud = pSolicitud;
				DELETE FROM "informix".br_respuesta_aprocesar WHERE num_solicitud = pSolicitud;   
				DELETE FROM "informix".br_respuesta_aprocesar_aux WHERE num_solicitud = pSolicitud; 			
		--IPCB Mayo2016 Reingenieria de Demonios.
					   
				--ini cas
				DELETE FROM "informix".br_cr WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_hi WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_hr WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_iq WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_pa WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_pe WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_pn WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_rs WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_sc WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_tl WHERE num_cliente= vcliente;
		  DELETE FROM "informix".br_ar WHERE num_cliente= vcliente;
		  DELETE FROM "informix".br_ur WHERE num_cliente= vcliente;
		  DELETE FROM "informix".br_es WHERE num_cliente= vcliente;
		  DELETE FROM "informix".br_error WHERE num_cliente= vcliente;
			--fin cas
			IF psucursal = "0001" THEN --JMAH
				DELETE FROM "informix".br_cr_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_hi_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_hr_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_iq_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_pa_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_pe_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_pn_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_rs_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_sc_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_tl_bc WHERE institucion = status_2 AND num_cliente= vcliente;  
			END IF;
           UPDATE "informix".br_auditor SET comentario = "" WHERE institucion=status_1 AND solicitud = pSolicitud;

           IF LENGTH(NVL(vcomentario,"")) = 0 THEN
             INSERT INTO "informix".br_traslado(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
              VALUES(status_1,vcliente,pSolicitud,vregistro,vregistro1,vregistro2,0,vfecha);
           ELSE
             INSERT INTO "informix".br_traslado(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
              VALUES(status_1,vcliente,pSolicitud,vregistro,vregistro1,vregistro2,3,vfecha);
             INSERT INTO "informix".br_auditor VALUES(status_1,pSolicitud,vfecha,vhora,vcomentario);
           END IF
    ELSE
			---mandamos llamar el sp para respaldar la informaciÃ³n de la consulta previa a buro del cliente       --JMAH
			EXECUTE PROCEDURE "informix".sp_generarespaldoshistoricosic(vcliente,pSolicitud,status_2,1) INTO cResultado,cMensajeRes;																													  
																														   
			
				DELETE FROM "informix".br_traslado WHERE institucion = status_2 AND num_solicitud = pSolicitud;
				DELETE FROM "informix".sb_regreso WHERE institucion = status_2 AND num_solicitud = pSolicitud;
	--IPCB Mayo2016 Reingenieria de Demonios.
				DELETE FROM "informix".br_respuesta WHERE institucion = status_2 AND num_solicitud = pSolicitud;
				DELETE FROM "informix".br_respuesta_aprocesar WHERE institucion = status_2 AND num_solicitud = pSolicitud;
				DELETE FROM "informix".br_respuesta_aprocesar_aux WHERE institucion = status_2 AND num_solicitud = pSolicitud;		
	--IPCB Mayo2016 Reingenieria de Demonios.		
				
				--ini cas
				DELETE FROM "informix".br_cr WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_hi WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_hr WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_iq WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_pa WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_pe WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_pn WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_rs WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_sc WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_tl WHERE institucion=status_2 AND num_cliente= vcliente;
		  DELETE FROM "informix".br_ar WHERE  institucion=status_2 AND num_cliente= vcliente;
		  DELETE FROM "informix".br_ur WHERE  institucion=status_2 AND num_cliente= vcliente;
		  DELETE FROM "informix".br_es WHERE  institucion=status_2 AND num_cliente= vcliente;
		  DELETE FROM "informix".br_error WHERE institucion=status_2 AND num_cliente= vcliente;
			IF psucursal = "0001" THEN --JMAH
				DELETE FROM "informix".br_cr_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_hi_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_hr_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_iq_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_pa_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_pe_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_pn_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_rs_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_sc_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_tl_bc WHERE institucion = status_2 AND num_cliente= vcliente;
			END IF;
		
           UPDATE "informix".br_auditor set comentario = "" WHERE solicitud = pSolicitud;

           IF LENGTH(NVL(vcomentario,"")) = 0 THEN
             INSERT INTO "informix".br_traslado(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
              VALUES(status_2,vcliente,pSolicitud,vregistro,vregistro1,vregistro2,0,vfecha);
           ELSE
             INSERT INTO "informix".br_traslado(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
              VALUES(status_2,vcliente,pSolicitud,vregistro,vregistro1,vregistro2,3,vfecha);
             INSERT INTO "informix".br_auditor VALUES(status_2,pSolicitud,vfecha,vhora,vcomentario);
           END IF;
    END IF;
--FIN CAS CAMBIO DE ORDEN DE CONSULTA BURO Y CIRCULO
   LET vexiste1 = 0;
   LET vexiste = 10;

	COMMIT WORK;
	IF wbegin = 'S' THEN
	    BEGIN WORK;
	END IF;
RETURN vcodret;

END;
END PROCEDURE
DOCUMENT

' Autor: Viridiana Osobampo' ,
' ModificaciÃ³n: Se valida el dato de tipo de vivienda del cliente en base a los' ,
'               nuevos valores asignados por la migaciÃ³n de catÃ¡logos, anteriormente' ,
'               ese dato contenÃ­a valores numÃ©ricos y cambio el identificador a letra.' ,
' Fecha de nodificaciÃ³n: 05-11-2009' ,
' Proyecto: Alta Ãnica para liberaciÃ³n de paso 2.' ,
'----------------------------------------------------------------------------------' ,
' Autor: Viridiana Osobampo' ,
' ModificaciÃ³n: Se insertan datos a los campos creados en la tabla br_traslado' ,
' Fecha de nodificaciÃ³n: 17-03-2009' ,
' Proyecto: Caja Unica.' ,
'----------------------------------------------------------------------------------' ,
'  ModificÃ³:  Viridiana Osobampo',
 'ModificaciÃ³n: Se obtienen las siglas que corresponden al producto solicitado por ' ,
'                el cliente, mismas que se incluyen en la cadena de informaciÃ³n ' ,
'                enviada a las instituciones crediticias. ' ,
'  Fecha modificaciÃ³n: 14-09-2009.' ,
'  PeticiÃ³n: RQM 10 108 PrÃ©stamo Personal.' ,
'----------------------------------------------------------------------------------' ,
' ModificÃ³: JesÃºs Manuel Aguilar Heredia' ,
' ModificaciÃ³n: Se modifica para que cuando se recibe la sucursal en "0000" consulte la tabla sd_maecred de la base de datos bdicred, para obtener la informaciÃ³n de la solicitud' ,
' Fecha modificaciÃ³n: 01-11-2011.' ,
'PeticiÃ³n: Solicitud de Incremento de LÃ­nea de CrÃ©dito ' ,
'Version 1.00.000' ,
'MODIFICACION: se cambia para que reciba el parametro psucursal en 0001 al igual que el sp ins_consulta_buro que le manda esta cadena.' ,
'----------------------------------------------------------------------------------' ,
'AUTOR: Armando Morales' ,
'FECHA: Junio 2012' ,
'VERSION: 20120612.1010' ,
'BD    : BDIBURO' ,
'----------------------------------------------------------------------------------' ,
'Autor: JosuÃ© Remberto Zazueta Acosta' ,
'ModificaciÃ³n: Se borra cÃ³digo comentado,se agregan informix y bd a las tablas que no tenÃ­an,Se implementan reglas', 'de informix' ,
'Fecha de modificaciÃ³n: 02/Octubre/2012' ,
'BD : bdicred' ,
'----------------------------------------------------------------------------------' ,
'Autor: Marco Antonio Valenzuela LeÃ³n' ,
'ModificaciÃ³n: Se cambia en la parte donde se almacena el RFC para que guarde como primera opciÃ³n el campo rfc_alterno sino trae informaciÃ³n que guarde con el campo rfc como anteriormente lo hacÃ­a' ,
'Fecha de modificaciÃ³n: 22/Marzo/2013' ,
'Version: 20130322.1547' ,
'BD : bdiburo' ,
'----------------------------------------------------------------------------------' ,
'MODIFICO: CARLOS OCHOA VALENZUELA' ,
'DESCRIPCION: SE MODIFICAN VALIDACIONES PARA TRABAJAR CON SOLICITUDES DE INCREMENTO DE LINEA, YA QUE ANTERIORMENTE SE TRABAJABA SOLO CON SOLICITUDES DE CRÃDITO' ,
'FECHA: MAYO-2013',
'------------------------------------------------------------------------------------',
'Autor:  Felix Ignacio Leyva Gamez.',
'Modifica: Se agrega consulta aleatoria a las SICs, ,con las banderas de fallosic y vigencia',
'Fecha: 06-01-2023.',
'Peticion: RQM 09 606 - Consulta aleatoria a las SICs cadena 2x1 - Originacion',
'------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".burocred_oc(pEmpresa CHAR(3), pSucursal CHAR(4), pUsuario CHAR(8), pSolicitud CHAR(20), pNocte CHAR(20))
RETURNING  CHAR(05) AS codret,
		   CHAR(20) AS solicitud,
		   CHAR(20) AS nocte,
		   CHAR(255) AS trama,
		   CHAR(255) AS trama1,
		   CHAR(255) AS trama2;

--EXECUTE PROCEDURE burocred('001','0142','prueba','',1500.00);

---------------DECLARACION DE VARIABLES
	DEFINE vregistro CHAR(255);
	DEFINE vregistro1 CHAR(255);
    DEFINE vregistro2 CHAR(255);
	DEFINE vcliente CHAR(20);
	DEFINE vsolicitud CHAR(20);
	DEFINE vlen INTEGER;
	DEFINE vpos CHAR(2);
	DEFINE vpo1 CHAR(5);
	DEFINE vdia CHAR(2);
	DEFINE vmes CHAR(2);
	DEFINE vanio CHAR(4);
	-- Variables para ver si se va a Buro o no --
	DEFINE vf1mes DATE;
	DEFINE vstatus CHAR(2);
	DEFINE vcodret CHAR(5);
	DEFINE vecampo1 CHAR(4);
	DEFINE vecampo2 CHAR(2);
	DEFINE vecampo3 CHAR(25);
	DEFINE vecampo4 CHAR(3);
	DEFINE vecampo5 CHAR(2);
	DEFINE vecampo6 CHAR(4);
	DEFINE vecampo7 CHAR(10);
	DEFINE vecampo8 CHAR(8);
	DEFINE vecampo9 CHAR(1);
	DEFINE vecampo10 CHAR(2);
	DEFINE vecampo11 CHAR(2);
	DEFINE vecampo12 CHAR(9);
	DEFINE vecampo13 CHAR(2);
	DEFINE vecampo14 CHAR(2);
	DEFINE vecampo15 CHAR(1);
	DEFINE vecampo16 CHAR(4);
	DEFINE vecampo17 CHAR(7);
	DEFINE vexiste INTEGER;
	DEFINE vcodini INTEGER;
	DEFINE vcodfin INTEGER;
	-- Datos del Cliente --
	DEFINE vdcampo1 CHAR(2);
	DEFINE vdcampo2 CHAR(26);
	DEFINE vdcampo3 CHAR(26);
	DEFINE vdcampo4 CHAR(26);
	DEFINE vdcampo5 CHAR(26);
	DEFINE vdcampo6 CHAR(10);
	DEFINE vdcampo7 CHAR(13);
	DEFINE vdcampo8 CHAR(2);
	DEFINE vdcampo9 CHAR(1);
	DEFINE vdcampo10 CHAR(1);
	DEFINE vdcampo11 CHAR(1);
	DEFINE vdcampo12 CHAR(2);
	DEFINE vscampo1 CHAR(2);
	DEFINE vscampo2 CHAR(40);
	DEFINE vscampo3 CHAR(40);
	DEFINE vscampo3_1 CHAR(40);
	DEFINE vscampo3_2 CHAR(40);
	DEFINE vscampo4 CHAR(40);
	DEFINE vscampo5 CHAR(40);
	DEFINE vscampo6 CHAR(40);
	DEFINE vscampo7 CHAR(4);
	DEFINE vscampo8 CHAR(5);
	DEFINE vscampo8a INTEGER;
	DEFINE vscampo9 CHAR(1);
	DEFINE vexiste1 SMALLINT;
	DEFINE vquita CHAR(40);
	DEFINE vespacio CHAR(1);
	DEFINE vmanzana SMALLINT;
	DEFINE vandador SMALLINT;
	DEFINE vlote SMALLINT;
	DEFINE vedificio SMALLINT;
	DEFINE ventrada SMALLINT;
	DEFINE vsecuencia SMALLINT;
	DEFINE vcomentario CHAR(80);
	DEFINE vhora datetime HOUR TO fraction(3);
	DEFINE vfecha DATE;
	DEFINE status_1      CHAR(2);  ---cambio CAS
	DEFINE status_2      CHAR(2);  ---cambio CAS
	DEFINE producto_sol  CHAR(20);
	DEFINE siglas_producto  CHAR(2);
	DEFINE cResultado  CHAR(6);
	DEFINE cMensajeRes  CHAR(8);
	DEFINE iSql_err      INTEGER;
	
    DEFINE vnumerocalle INTEGER;
	DEFINE iFlag2credito         SMALLINT;
	
	DEFINE valida_hit CHAR(1);
    DEFINE wBegin       CHAR(1);
	
	-- RQM 09 554 - Consulta a las SICÃÂ¯ÃÂ¿ÃÂ½s.
	DEFINE cFlujo_cc CHAR(1);
	DEFINE status_consul           	CHAR(2);
	DEFINE cCanalSol	CHAR (2);
	-- RQI Originacion solicitudes 24 x 7
	DEFINE vfechaServ DATE;

---------------INICIALIZACION DE VARIABLES
	LET vhora = extend(CURRENT,HOUR TO fraction(3));
	LET vregistro ="";
	LET vregistro1="";
	LET vregistro2="";
	LET vcliente ="";
	LET vsolicitud ="";
	LET vlen =0;
	LET vpos="";
	LET vdia="";
	LET vmes="";
	LET vanio="";
	LET vf1mes="";
	LET vstatus="";
	LET vcodret="000";
    LET status_1="00";
    LET status_2="00";
    LET producto_sol = "";
    LET siglas_producto = "";
	LET cResultado = "";
	LET cMensajeRes = "";
	LET iSql_err        = 0 ;
	LET vpo1 = "";
	LET vecampo1 = "";
	LET vecampo2 = "";
	LET vecampo3 = "";
	LET vecampo4 = "";
	LET vecampo5 = "";
	LET vecampo6 = "";
	LET vecampo7 = "";
	LET vecampo8 = "";
	LET vecampo9 = "";
	LET vecampo10 = "";
	LET vecampo11 = "";
	LET vecampo12 = "";
	LET vecampo13 = "";
	LET vecampo14 = "";
	LET vecampo15 = "";
	LET vecampo16 = "";
	LET vecampo17 = "";
	LET vexiste = 0;
	LET vcodini = 0;
	LET vcodfin = 0;
	LET vdcampo1 = "";
	LET vdcampo2 = "";
	LET vdcampo3 = "";
	LET vdcampo4 = "";
	LET vdcampo5 = "";
	LET vdcampo6 = "";
	LET vdcampo7 = "";
	LET vdcampo8 = "";
	LET vdcampo9 = "";
	LET vdcampo10 = "";
	LET vdcampo11 = "";
	LET vdcampo12 = "";
	LET vscampo1 = "";
	LET vscampo2 = "";
	LET vscampo3 = "";
	LET vscampo3_1 = "";
	LET vscampo3_2 = "";
	LET vscampo4 = "";
	LET vscampo5 = "";
	LET vscampo6 = "";
	LET vscampo7 = "";
	LET vscampo8 = "";
	LET vscampo8a = 0;
	LET vscampo9 = "";
	LET vexiste1 = 0;
	LET vquita = "";
	LET vespacio = "";
	LET vmanzana = 0;
	LET vandador = 0;
	LET vlote = 0;
	LET vedificio = 0;
	LET ventrada = 0;
	LET vsecuencia = 0;
	LET vcomentario = "";

    LET vnumerocalle = 0;
	LET iFlag2credito = 0;
	
	LET valida_hit ="";
	LET wBegin = "N";
	
	LET cFlujo_cc = '0';
	LET status_consul           ='';
	LET cCanalSol = '';

BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err 
		IF iSql_err <> 0 THEN
			LET vcodret = iSql_err;		
			RETURN vcodret,vcliente,vsolicitud,vregistro,vregistro1,vregistro2;
		END IF;
	END EXCEPTION;
	
	 ON EXCEPTION IN (-535)
      LET wBegin = "S";
     -- ROLLBACK WORK;
		COMMIT WORK;
		BEGIN WORK;
	END EXCEPTION WITH RESUME;
	
	--SET DEBUG FILE TO '/informix/mc/burocred_2.out';
	--TRACE ON;
	--SET DEBUG FILE TO '/RESPALDOS/ipcb/pruebas/burocred_pam.out';   TRACE ON;
	BEGIN WORK;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	
	SELECT fecha_hoy 
	INTO vfecha 
	FROM bdicred:"informix".sd_fechas
	WHERE empresa='001';
  
    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE 
	INTO vfechaServ
	FROM sysmaster:sysshmvals;
	
	IF vfecha < vfechaServ THEN
		LET vfecha = vfechaServ;
	END IF;
	
	IF psucursal = '0001' THEN   -- SE CAMBIA PARA QUE RECIBA 0001 AL IGUAL QUE EL SP QUE LE MANDA ESTA CADENA.
		SELECT numcte,num_producto
		INTO vcliente,producto_sol
		FROM bdicred:"informix".sd_maecred
		WHERE num_credito = pSolicitud
		AND empresa = pempresa;
		
		LET vstatus = pusuario;
	ELSE
		IF pSolicitud != '' THEN
			SELECT a.numcte, a.num_solicitud, a.num_producto,a.status_solicitud,NVL(c.flag2credito,0)
			INTO vcliente,vsolicitud,producto_sol,vstatus,iFlag2credito
			FROM bdisolic:"informix".ss_solicitudes a
			INNER JOIN bdisolic:"informix".ss_resum_scor_fin b ON ( b.num_solicitud = a.num_solicitud) 
			LEFT  JOIN bdisolic:"informix".ss_revision_determinacion c ON ( c.num_solicitud = a.num_solicitud) 
			WHERE a.empresa = "001" 
			AND a.num_solicitud = pSolicitud;
		ELSE
			SELECT D.numcte, D.num_solicitud, D.num_producto, D.status_solicitud, D.flag2credito
			INTO vcliente,vsolicitud,producto_sol,vstatus,iFlag2credito
			FROM
			(SELECT LIMIT 1 a.numcte, a.num_solicitud, a.num_producto,a.status_solicitud,NVL(c.flag2credito,0)
			FROM bdisolic:"informix".ss_solicitudes a
			INNER JOIN bdisolic:"informix".ss_resum_scor_fin b ON ( b.num_solicitud = a.num_solicitud) 
			LEFT  JOIN bdisolic:"informix".ss_revision_determinacion c ON ( c.num_solicitud = a.num_solicitud) 
			WHERE a.empresa = "001" 
			AND a.numcte = pNocte
			ORDER BY a.fecha_insert DESC) AS D;
		END IF;

			--RQM 09 308 Se agrega validacion para cuando sea una solicitud aperturada se consulte la tabla de incremento
			IF vstatus = "AP" THEN
				SELECT DISTINCT(numcte),num_producto,status
				INTO vcliente,producto_sol,vstatus
				FROM  bdicred:"informix".sd_bitacora_aumlincred 
				WHERE empresa = "001" AND num_solicitud = pSolicitud
                AND fecha_insert = (SELECT MAX(fecha_insert)  FROM  bdicred:"informix".sd_bitacora_aumlincred 
                                     WHERE empresa = "001" AND num_solicitud = pSolicitud AND status IN ('BC','CC'));
			END IF;
		
	END IF;
	
	IF vstatus <> "BC" AND vstatus <> "CC" and psucursal = "8503" THEN
	    LET vstatus ="BC";
	END IF;
    IF TRIM(vstatus) = "RR" THEN
           LET vregistro="ERRRUR25";
           LET vcodret="260";
	   RETURN vcodret,vcliente,vsolicitud,vregistro,vregistro1,vregistro2;
    END IF
	-- Declaracion de Constantes para Generacion de Registros desea ver que significa cada campo
	-- Favor de consultar el manual -->
	LET vecampo1="INTL";
	LET vecampo2="11";
	--- COLOCACION DE NUMERO DE SOLICITUD
	LET vecampo3 =pSolicitud||"     ";
	LET vecampo4="001";
	LET vecampo5="MX";
	LET vecampo6="0000";
	LET vecampo7    = "";
	LET vecampo8    = "";
	LET vecampo9="I";
	LET vecampo10="";	LET vecampo11="MX";
	LET vecampo12="000000000"; --monto solicitado
	LET vecampo13="SP";
	LET vecampo14="03";	LET vecampo15=" ";
	LET vecampo16="    ";
	LET vecampo17="0000000";
	LET vexiste=0;
	LET vcomentario = "";
	-- Consulta las siglas correspondientes al producto solicitado
       SELECT codigo
         INTO siglas_producto
         FROM "informix".br_tltco
        WHERE num_producto = producto_sol;

        LET vecampo10 = siglas_producto;
		
	--ini CAS consulta de institucion
		
		SELECT canal_sol INTO cCanalSol FROM bdisolic:"informix".ss_solicitudes 
		WHERE numcte = vcliente AND num_solicitud = pSolicitud;
		
		SELECT insti1 INTO status_consul FROM bdisolic:"informix".ss_canales_solic 
		WHERE canal_solic = cCanalSol;
		
		IF status_consul = 'CC' THEN
			LET cFlujo_cc = '1';
		END IF;
		
		IF cFlujo_cc = '1' THEN
			SELECT status_solicitud
			INTO status_2
			FROM bdisolic:"informix".ss_status_sol 
			WHERE empresa=pempresa 
			AND tipo_auto="1";

			SELECT status_solicitud
			INTO status_1
			FROM bdisolic:"informix".ss_status_sol 
			WHERE empresa=pempresa 
			AND tipo_auto="2";
		
		ELSE
			SELECT status_solicitud
			INTO status_2
			FROM bdisolic:"informix".ss_status_sol 
			WHERE empresa=pempresa 
			AND tipo_auto="2";

			SELECT status_solicitud
			INTO status_1
			FROM bdisolic:"informix".ss_status_sol 
			WHERE empresa=pempresa 
			AND tipo_auto="1";
		
		END IF;
		
            IF vstatus="CC" THEN
                SELECT TRIM(valor) INTO vecampo7
                  FROM "informix".br_param
                  WHERE cod_param = 1;
                SELECT TRIM(valor) INTO vecampo8
                  FROM "informix".br_param
                  WHERE cod_param = 2;
		--IPCB Marzo2016 RQM 09 398-0 FICO Extended				  
				SELECT  evalua_cc  INTO  valida_hit
                  FROM  bdisolic:ss_resum_scor_fin
                  WHERE num_solicitud = pSolicitud;
				
				--IF  valida_hit <> "X" THEN
				IF  valida_hit IS NULL OR valida_hit <> "X" THEN
		--IPCBjul15 --FICO SCORE               
					IF cFlujo_cc = '0' THEN
					   SELECT TRIM(valor)INTO vecampo4
						  FROM bdiburo:br_param
						  WHERE cod_param = 141;
					ELSE
					
						SELECT prodcc INTO vecampo4
						FROM bdisolic:"informix".ss_canales_solic 
						WHERE canal_solic = cCanalSol;
						
					END IF;
				ELSE 
		--IPCB Marzo2016--FICO Extended	
              	SELECT TRIM(valor)INTO vecampo4
                  FROM bdiburo:br_param
                 WHERE cod_param = 142;
				END IF;
            ELIF vstatus='BC' THEN
			
				IF cFlujo_cc = '0' THEN
					SELECT TRIM(valor) INTO vecampo7
					  FROM "informix".br_param
					  WHERE cod_param = 124;
					SELECT TRIM(valor) INTO vecampo8
					  FROM "informix".br_param
					  WHERE cod_param = 125;
				
					IF iFlag2credito =1 THEN
						-- JMAH INI ICC
						SELECT TRIM(valor) INTO vecampo4
						FROM "informix".br_param
						WHERE cod_param = 11;
						-- JMAH INI BCSCORE
					ELSE				
						-- JOM INI BCSCORE
						SELECT TRIM(valor) INTO vecampo4
						FROM "informix".br_param
						WHERE cod_param = 126;

						-- JOM INI BCSCORE
					END IF;
					
				ELSE
					IF iFlag2credito =1 THEN
						SELECT TRIM(valor) INTO vecampo7
						  FROM "informix".br_param
					     WHERE cod_param = 124;
						 
						SELECT TRIM(valor) INTO vecampo8
					      FROM "informix".br_param
					     WHERE cod_param = 125;
						 
						-- JMAH INI ICC
						SELECT TRIM(valor) INTO vecampo4
						FROM "informix".br_param
						WHERE cod_param = 11;
						-- JMAH INI BCSCORE
					ELSE
						--Usuario Prospector
						select trim(valor) into vecampo7
						from bdiburo:br_param
						where cod_param = 154; 
						
						--Password Prospector
						select trim(valor) into vecampo8
						from bdiburo:br_param
						where cod_param = 155;   
						
						--Numero de producto Prospector
						select trim(valor) into vecampo4
						from bdiburo:br_param
						where cod_param = 153;  
					END IF;  
				END IF;
				
            END IF;
			
  --LET vecampo12=LPAD(round(pMontoSol,0),9,"0");
  LET vregistro= vecampo1||vecampo2||vecampo3||vecampo4||vecampo5||
	     vecampo6||vecampo7||vecampo8||vecampo9||vecampo10||vecampo11||vecampo12||vecampo13||
	     vecampo14||vecampo15||vecampo16||vecampo17;
	-- Datos del Cliente --
	LET vdcampo1="PN"; --Identificador de cadena--
	LET vdcampo2=""; --Apellido Paterno PN--
	LET vdcampo3=""; --Apellido Materno 00--
	LET vdcampo4=""; --Primer Nombre 02--
	LET vdcampo5=""; --Segundo Nombre 03--
	LET vdcampo6=""; --Fecha de Nacimiento 04--
	LET vdcampo7=""; --RFC 05--
	LET vdcampo8="MX"; --Nacionalidad MX o EX 08--
	LET vdcampo9=""; --Residencia o Tipo Vivienda 09 1=Prop 2=Renta 3=Pension--
	LET vdcampo10=""; --Estado Civil 11 --
	LET vdcampo11=""; --Sexo 12--
	LET vdcampo12=""; --Dependiente 17--
	-- Direccion del Cliente --
	LET vscampo1="PA"; --Identificador de cadena--
	LET vscampo2=""; --Direccion Linea 1 PA--
	LET vscampo3=""; --Direccion Linea 2 00--
	LET vscampo3_1=""; --Direccion Linea 2 00--EXT
	LET vscampo3_2=""; --Direccion Linea 2 00--INT
	LET vscampo4=""; --Colonia o Poblacion 01--
	LET vscampo5=""; --Delegacion o Municipio 02--
	LET vscampo6=""; --Nombre Ciudad 03--
	LET vscampo7=""; --Estado 04--
	LET vscampo8=""; --Codigo Postal 05--
	LET vscampo9=""; --Tipo de Domicilio 10--

	SELECT TRIM(apell_paterno), TRIM(apell_materno), TRIM(nombre1),
  	        TRIM(nombre2),fecha_nac, CASE WHEN LENGTH(trim(rfc_alterno)) = 13 THEN rfc_alterno ELSE rfc END, TRIM(habita_en),
  	         TRIM(estado_civil),TRIM(sexo), NVL(dependientes,"0")
		    INTO vdcampo2,vdcampo3,vdcampo4,
                        vdcampo5,vdcampo6,vdcampo7,vdcampo9,
                        vdcampo10,vdcampo11,vdcampo12
		    FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_ctepf b
		    WHERE a.numcte = b.numcte  AND b.numcte = vcliente;

	  -- Cambia las Ã de los Nombres y Apellidos --
         IF vdcampo2 IS NULL THEN LET vdcampo2 = ""; LET vcomentario = "Apellido paterno nulo"; END IF;
         IF vdcampo3 IS NULL THEN LET vdcampo3 = "NO PROPORCIONADO"; END IF;
         IF vdcampo4 IS NULL THEN LET vdcampo4 = ""; LET vcomentario = TRIM(vcomentario)||" Sin nombre"; END IF;
         IF vdcampo5 IS NULL THEN LET vdcampo5 = ""; END IF;
         IF vdcampo6 IS NULL THEN LET vdcampo6 = ""; END IF;
         IF vdcampo7 IS NULL THEN LET vdcampo7 = ""; END IF;
         IF vdcampo9 IS NULL THEN LET vdcampo9 = ""; END IF;
         IF vdcampo10 IS NULL THEN LET vdcampo10 = ""; END IF;
         IF vdcampo11 IS NULL THEN LET vdcampo11 = ""; END IF;
         IF vdcampo12 IS NULL THEN LET vdcampo12 = "0"; END IF;
         LET vexiste = LENGTH(vdcampo2);
         LET vexiste1 = 0;
         LET vquita = "";
         LET vespacio = " ";
         WHILE vexiste1 < vexiste
           IF vdcampo2[1,1]="~" OR vdcampo2[1,1]=" " OR vdcampo2[1,1]="." OR
           vdcampo2[1,1]="-"  THEN
              LET vespacio = "F";
           ELSE
             IF vespacio = "F" THEN
               IF vdcampo2[1,1] = "#" OR vdcampo2[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||" Ã";
               ELSE
                 LET vquita = TRIM(vquita)||" "||vdcampo2[1,1];
               END IF
               LET vespacio ="";
             ELSE
               IF vdcampo2[1,1] = "#" OR vdcampo2[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||"Ã";
               ELSE
                 LET vquita = TRIM(vquita)||vdcampo2[1,1];
               END IF
             END IF
           END IF;
           LET vdcampo2 = vdcampo2[2,26];
           LET vexiste1 = vexiste1 + 1;
         END WHILE;
         LET vdcampo2 = TRIM(vquita);
         LET vexiste = LENGTH(vdcampo3);
     --- CAMBIO DE APELLIDO MATERNO
         IF vexiste = 0 THEN
            LET vdcampo3 = "NO PROPORCIONADO";
            LET vexiste = LENGTH(vdcampo3);
         END IF
         LET vexiste1 = 0;
         LET vquita = "";
         LET vespacio = " ";
         WHILE vexiste1 < vexiste
           IF vdcampo3[1,1]="~" OR vdcampo3[1,1]=" " OR vdcampo3[1,1]="." OR
            vdcampo3[1,1]="-" THEN
              LET vespacio = "F";
           ELSE
             IF vespacio = "F" THEN
               IF vdcampo3[1,1] = "#" OR vdcampo3[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||" Ã";
               ELSE
                 LET vquita = TRIM(vquita)||" "||vdcampo3[1,1];
               END IF
               LET vespacio ="";
             ELSE
               IF vdcampo3[1,1] = "#" OR vdcampo3[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||"Ã";
               ELSE
                 LET vquita = TRIM(vquita)||vdcampo3[1,1];
               END IF
             END IF
           END IF;
           LET vdcampo3 = vdcampo3[2,26];
           LET vexiste1 = vexiste1 + 1;
         END WHILE;
         LET vdcampo3 = TRIM(vquita);
         LET vexiste = LENGTH(vdcampo4);
         LET vexiste1 = 0;
         LET vquita = "";
         LET vespacio = " ";
         WHILE vexiste1 < vexiste
           IF vdcampo4[1,1]="~" OR vdcampo4[1,1]=" "  OR vdcampo4[1,1]="." OR
            vdcampo4[1,1]="-" THEN
              LET vespacio = "F";
           ELSE
             IF vespacio = "F" THEN
               IF vdcampo4[1,1] = "#" OR vdcampo4[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||" Ã";
               ELSE
                 LET vquita = TRIM(vquita)||" "||vdcampo4[1,1];
               END IF
               LET vespacio ="";
             ELSE
               IF vdcampo4[1,1] = "#" OR vdcampo4[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||"Ã";
               ELSE
                 LET vquita = TRIM(vquita)||vdcampo4[1,1];
               END IF
             END IF
           END IF;
           LET vdcampo4 = vdcampo4[2,26];
           LET vexiste1 = vexiste1 + 1;
         END WHILE;
         LET vdcampo4 = TRIM(vquita);
         LET vexiste = LENGTH(vdcampo5);
         LET vexiste1 = 0;
         LET vquita = "";
         LET vespacio =" ";
         WHILE vexiste1 < vexiste
           IF vdcampo5[1,1]="~" OR vdcampo5[1,1]=" " OR vdcampo5[1,1]="." OR
            vdcampo5[1,1]="-" THEN
              LET vespacio ="F";
           ELSE
            IF vespacio = "F" THEN
               IF vdcampo5[1,1] = "#" OR vdcampo5[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||" Ã";
               ELSE
                 LET vquita = TRIM(vquita)||" "||vdcampo5[1,1];
               END IF
	       LET vespacio ="";
            ELSE
               IF vdcampo5[1,1] = "#" OR vdcampo5[1,1] = "Â¥" THEN
                 LET vquita = TRIM(vquita)||"Ã";
               ELSE
                 LET vquita = TRIM(vquita)||vdcampo5[1,1];
               END IF
            END IF
           END IF;
           LET vdcampo5 = vdcampo5[2,26];
           LET vexiste1 = vexiste1 + 1;
         END WHILE;
         LET vdcampo5 = TRIM(vquita);
         IF vdcampo9 ="P" OR vdcampo9 ="G" THEN
	       	   LET vdcampo9="1";
	 ELSE
	   IF vdcampo9 ="R" THEN 
	    LET vdcampo9="2";
	   ELSE
	     IF vdcampo9 ="F"  OR vdcampo9 = "H" THEN 
	       LET vdcampo9="3";
	     ELSE
	      LET vdcampo9="";
	     END IF
	   END IF
	 END IF
         IF vdcampo10 ="D" THEN
	       	   LET vdcampo10="D";
	 ELSE
	   IF vdcampo10 ="U" THEN
	    LET vdcampo10="F";
	   ELSE
	     IF vdcampo10 ="C" THEN
	       LET vdcampo10="M";
	     ELSE
	      IF vdcampo10 ="S" THEN
	         LET vdcampo10="S";
	      ELSE
	         IF vdcampo10 ="V" THEN
		    LET vdcampo10="W";
	         END IF
	      END IF
	     END IF
	   END IF
	 END IF
	-- Carga los datos de la Direccion del Cliente --
    --SELECT MAX(secuencia) INTO vsecuencia
    --  FROM bdinteg:"informix".si_direcciones
	--           WHERE  numcte=vcliente AND tipo_dir='1';


     -- SELECT TRIM(f.nombrecalle),
	  SELECT case when substr(f.nombrecalle,1,1) in('0','1','2','3','4','5','6','7','8','9') then "CALLE "||trim(f.nombrecalle) else trim(f.nombrecalle) end nombrecalle,
          -- REPLACE(NVL(TRIM(a.numeroextcalle)," ")||" "||NVL(TRIM(a.numerointcalle)," "),'	',''),--Se quitan los tabuladores INC 21 119
		   REPLACE(NVL(TRIM(a.numeroextcalle)," "),'	',''),
		   REPLACE(NVL(TRIM(a.numerointcalle)," "),'	',''),
           TRIM(g.nombrezona), 
       TRIM(g.municipiozona), TRIM(c.estado), lpad(TRIM(a.cod_postal),5,"0"), a.tipo_dir,
           manzana,andador,lote,edificio,entrada,codini,codfin, nvl(a.numerocalle,0)
       INTO   vscampo2, vscampo3_1,vscampo3_2, vscampo4,
              vscampo6, vscampo7,vscampo8,vscampo9,
              vmanzana,vandador,vlote,vedificio,ventrada,vcodini,vcodfin, vnumerocalle
       FROM  bdinteg:"informix".si_direcciones_actual as a,
                 bdisolic:"informix".ss_circulo_edos as c,
                 bdinteg:"informix".si_catcalles f,
                 bdinteg:"informix".si_catzonas g
       WHERE  a.numcte=vcliente AND a.tipo_dir = '1' 
         AND c.clave = a.estado 
         AND g.numerociudad = a.numerociudad
         AND g.numerocolonia = a.numerocolonia
         AND f.numerocalle = a.numerocalle;	
	
		IF (vscampo2 is null or vnumerocalle = 0) and (SELECT COUNT(num_solicitud) 					
				FROM bdisolic:"informix".ss_solicitudes_movil							
				WHERE 	empresa  = pEmpresa 
				AND  num_solicitud = pSolicitud
				AND status <> '3' ) > 0 THEN				
				
                --SELECT TRIM(a.calle),
				SELECT case when substr(a.calle,1,1) in('0','1','2','3','4','5','6','7','8','9') then "CALLE "||trim(a.calle) else trim(a.calle) end nombrecalle,
                --REPLACE(NVL(TRIM(a.numeroextcalle)," ")||" "||NVL(TRIM(a.numerointcalle)," "),'	',''),--Se quitan los tabuladores INC 21 119
				REPLACE(NVL(TRIM(a.numeroextcalle)," "),'	',''),
				REPLACE(NVL(TRIM(a.numerointcalle)," "),'	',''),
                TRIM(g.nombrezona), 
                TRIM(g.municipiozona), TRIM(c.estado), lpad(TRIM(a.cod_postal),5,"0"), a.tipo_dir,
                manzana,andador,lote,edificio,entrada,codini,codfin 
                INTO   vscampo2, vscampo3_1,vscampo3_2, vscampo4,
                vscampo6, vscampo7,vscampo8,vscampo9,
                vmanzana,vandador,vlote,vedificio,ventrada,vcodini,vcodfin
                FROM  bdinteg:"informix".si_direcciones_actual as a,
                     bdisolic:"informix".ss_circulo_edos as c,					 
                     bdinteg:"informix".si_catzonas g
                WHERE  a.numcte=vcliente AND a.tipo_dir = '1' 
                AND c.clave = a.estado 
                AND g.numerociudad = a.numerociudad
                AND g.numerocolonia = a.numerocolonia;								
		END IF;		
	
	   	
       IF vscampo2 IS NULL THEN LET vscampo2 = "";  LET vcomentario = TRIM(vcomentario)||" Sin calle "; END IF;
       --IF vscampo3 IS NULL THEN LET vscampo3 = ""; END IF;
	   IF    vscampo3_1 IS NULL     OR nvl(vscampo3_1,'') = ''    OR nvl(vscampo3_1,'') = 'S/N' or
		 nvl(vscampo3_1,'') = 'S/n' or nvl(vscampo3_1,'') = 's/N' or nvl(vscampo3_1,'') = 's/n' or
				vscampo3_1 = '0'   or         vscampo3_1 = '00'  or     vscampo3_1 = '000'     or 
				vscampo3_1 = '0000' THEN  LET vscampo3_1 = "SN"; END IF;
				 
	   IF    vscampo3_2 IS NULL     OR nvl(vscampo3_2,'') = ''    OR nvl(vscampo3_2,'') = 'S/N' or
	     nvl(vscampo3_2,'') = 'S/n' or nvl(vscampo3_2,'') = 's/N' or nvl(vscampo3_2,'') = 's/n' or
                 vscampo3_2 = '0'   or         vscampo3_2 = '00'  or     vscampo3_2 = '000'     or 
				 vscampo3_2 = '0000' THEN  LET vscampo3_2 = "SN"; END IF;
				 
	   LET vscampo3=  REPLACE(NVL(TRIM(vscampo3_1)," ")||" "||NVL(TRIM(vscampo3_2)," "),'	','');
       IF vscampo4 IS NULL THEN LET vscampo4 = ""; END IF;
       IF vscampo5 IS NULL THEN LET vscampo5 = ""; END IF;
       IF vscampo6 IS NULL THEN LET vscampo6 = ""; LET vcomentario = TRIM(vcomentario)||" Sin localidad "; END IF;
       IF vscampo7 IS NULL THEN LET vscampo7 = ""; LET vcomentario = TRIM(vcomentario)||" Sin estado "; END IF;
       IF vscampo8 IS NULL THEN LET vscampo8 = ""; LET vcomentario = TRIM(vcomentario)||" Sin codigo postal "; END IF;
       IF vscampo9 IS NULL THEN LET vscampo9 = ""; END IF;
       LET vscampo2 = TRIM(vscampo2)||" "||TRIM(vscampo3);
       LET vexiste = LENGTH(vscampo2);
       IF vexiste < 40 THEN
         LET vscampo3 = "";
         IF vmanzana > 0 THEN
           LET vscampo3 ="mza "||vmanzana;
         END IF
         IF vandador > 0 THEN
           LET vscampo3 =TRIM(vscampo3)||"AND "||vandador;
         END IF
         IF vlote > 0 THEN
           LET vscampo3 =TRIM(vscampo3)||"lt "||vlote;
         END IF
         IF vedificio > 0 THEN
           LET vscampo3 =TRIM(vscampo3)||"ed "||vedificio;
         END IF
         IF ventrada > 0 THEN
           LET vscampo3 =TRIM(vscampo3)||"ent "||ventrada;
         END IF
       LET vscampo2 = TRIM(vscampo2)||' '||TRIM(vscampo3);
       END IF
       LET vscampo2 = TRIM(vscampo2);
       LET vexiste = LENGTH(vscampo2);
       LET vexiste1 = 0;
       LET vquita = "";
       LET vespacio = " ";
       WHILE vexiste1 < vexiste
        IF vscampo2[1,1]="~" OR vscampo2[1,1]=" " OR vscampo2[1,1]="." OR
         vscampo2[1,1]="-" THEN
           LET vespacio = "F";
        ELSE
          IF vespacio = "F" THEN
            IF vscampo2[1,1] = "#" OR vscampo2[1,1] = "Â¥" THEN
              LET vquita = TRIM(vquita)||" Ã";
            ELSE
              LET vquita = TRIM(vquita)||" "||vscampo2[1,1];
            END IF
            LET vespacio = "";
          ELSE
            IF vscampo2[1,1] = "#" OR vscampo2[1,1] = "Â¥" THEN
              LET vquita = TRIM(vquita)||"Ã";
            ELSE
              LET vquita = TRIM(vquita)||vscampo2[1,1];
            END IF
          END IF
        END IF;
        LET vscampo2 = vscampo2[2,40];
        LET vexiste1 = vexiste1 + 1;
       END WHILE;
       LET vscampo2 = TRIM(vquita);
       IF vscampo9 ="1" THEN
	   LET vscampo9="H";
       ELSE
         IF vscampo9 ="2" THEN
           LET vscampo9="B";
         ELSE
           LET vscampo9="H";
         END IF
       END IF

    LET vregistro=TRIM(vregistro)||vdcampo1;
    LET vlen=LENGTH(vdcampo2);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||vpos||vdcampo2;
    LET vlen=LENGTH(vdcampo3);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"00"||vpos||vdcampo3;
    LET vlen=LENGTH(vdcampo4);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"02"||vpos||vdcampo4;
    LET vlen=LENGTH(vdcampo5);
    LET vpos=LPAD(vlen,2,"0");
    IF vlen  > 0 THEN
      LET vregistro=TRIM(vregistro)||"03"||vpos||vdcampo5;
    END IF

    LET vlen=LENGTH(vdcampo6);
    IF vlen  > 0 THEN
    LET vdia=vdcampo6[4,5];
    LET vdia=LPAD(vdia,2,"0");
    LET vmes=vdcampo6[1,2];
    LET vmes=LPAD(vmes,2,"0");
    LET vanio=vdcampo6[7,10];
    LET vdcampo6=vdia||vmes||vanio;
    LET vlen=LENGTH(vdcampo6);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"04"||vpos||vdcampo6;
    END IF;
    LET vlen=LENGTH(vdcampo7);
    IF vlen  > 0 THEN
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"05"||vpos||vdcampo7;
    END IF;
    LET vlen=LENGTH(vdcampo8);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"08"||vpos||vdcampo8;
 --- Este es el campo correspondiente a la residencia
    IF vdcampo9 = "1" OR vdcampo9 = "2" OR vdcampo9 = "3" THEN
     LET vlen=LENGTH(vdcampo9);
     LET vpos=LPAD(vlen,2,"0");
     LET vregistro=TRIM(vregistro)||"09"||vpos||vdcampo9;
    END IF
    LET vlen =LENGTH(vdcampo10);
    IF vlen  > 0 THEN
      LET vpos=LPAD(vlen,2,"0");
      LET vregistro=TRIM(vregistro)||"11"||vpos||vdcampo10;
    END IF
    LET vlen=LENGTH(vdcampo11);
    IF vlen  > 0 THEN
      LET vpos=LPAD(vlen,2,"0");
      LET vregistro=TRIM(vregistro)||"12"||vpos||vdcampo11;
    END IF
    IF TRIM(vdcampo12) != "0" THEN
       IF LENGTH(TRIM(vdcampo12)) < 2 THEN
         LET vdcampo12 = "0"||TRIM(vdcampo12);
       END IF
       LET vlen=LENGTH(vdcampo12);
       LET vpos=LPAD(vlen,2,"0");
       LET vregistro=TRIM(vregistro)||"17"||vpos||vdcampo12;
    ELSE
       LET vregistro=TRIM(vregistro)||"170201";
    END IF
    LET vregistro=TRIM(vregistro)||vscampo1;
    LET vlen=LENGTH(vscampo2);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro1=vpos||vscampo2;
    LET vscampo3 = "";
    LET vexiste = LENGTH(vscampo3);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
     IF vscampo3[1,1]="~" OR vscampo3[1,1]=" " OR vscampo3[1,1]="." OR
      vscampo3[1,1]="-" THEN
       LET vespacio = "F";
     ELSE
      IF vespacio = "F" THEN
        IF vscampo3[1,1] = "#" OR vscampo3[1,1] = "Â¥" THEN
           LET vquita = TRIM(vquita)||" Ã";
        ELSE
           LET vquita = TRIM(vquita)||" "||vscampo3[1,1];
        END IF
	LET vespacio = "";
      ELSE
        IF vscampo3[1,1] = "#" OR vscampo3[1,1] = "Â¥" THEN
	   LET vquita = TRIM(vquita)||"Ã";
        ELSE
	   LET vquita = TRIM(vquita)||vscampo3[1,1];
        END IF
      END IF
     END IF;
     LET vscampo3 = vscampo3[2,26];
     LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vscampo3 = TRIM(vquita);
    LET vlen=LENGTH(vscampo3);
    LET vpos=LPAD(vlen,2,"0");
    --LET vregistro1='00'||vpos|| vscampo3;
    LET vexiste = LENGTH(vscampo4);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
     IF vscampo4[1,1]="~" OR vscampo4[1,1]=" " OR vscampo4[1,1]="." OR
      vscampo4[1,1]="-" THEN
       LET vespacio = "F";
     ELSE
      IF vespacio = "F" THEN
        IF vscampo4[1,1] = "#" OR vscampo4[1,1] = "Â¥" THEN
	  LET vquita = TRIM(vquita)||" Ã";
        ELSE
	  LET vquita = TRIM(vquita)||" "||vscampo4[1,1];
        END IF
        LET vespacio = "";
      ELSE
        IF vscampo4[1,1] = "#" OR vscampo4[1,1] = "Â¥" THEN
	  LET vquita = TRIM(vquita)||"Ã";
        ELSE
	  LET vquita = TRIM(vquita)||vscampo4[1,1];
        END IF
      END IF
     END IF;
     LET vscampo4 = vscampo4[2,26];
     LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vscampo4= TRIM(vquita);
    LET vlen=LENGTH(vscampo4);
    LET vpos= LPAD(vlen,2,"0");
    IF vlen > 0 THEN
    LET vregistro1= TRIM(vregistro1)||"01"||vpos|| vscampo4;
    END IF
{    LET vexiste = LENGTH(vscampo5);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
     IF vscampo5[1,1]="~" OR vscampo5[1,1]=" " OR vscampo5[1,1]="." THEN
       LET vespacio = "F";
     ELSE
      IF vespacio = "F" THEN
        IF vscampo5[1,1] = "#" OR vscampo5[1,1] = "Â¥" THEN
	  LET vquita = TRIM(vquita)||" Ã ";
	  LET vespacio = "";
        ELSE
	  LET vquita = TRIM(vquita)||" "||vscampo5[1,1];
	  LET vespacio = "";
        END IF
      ELSE
        IF vscampo5[1,1] = "#" OR vscampo5[1,1] = "Â¥" THEN
	  LET vquita = TRIM(vquita)||"Ã";
        ELSE
	  LET vquita = TRIM(vquita)||vscmpo5[1,1];
        END IF
      END IF
     END IF;
     LET vscampo5 = vscampo5[2,26];
     LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vscampo5 = TRIM(vquita);
    LET vlen= LENGTH(vscampo5);
    LET vpos= LPAD(vlen,2,'0');
    LET vregistro1= TRIM(vregistro1)||'02'||vpos||vscampo5;
}
    LET vexiste = LENGTH(vscampo6);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
     IF vscampo6[1,1]="~" OR vscampo6[1,1]=" " OR vscampo6[1,1]="." OR
      vscampo6[1,1]="-" THEN
       LET vespacio = "F";
       LET vexiste1 = vexiste1 + 1;
       LET vscampo6 = vscampo6[2,26];
     ELSE
      IF vespacio = "F" THEN
        IF vscampo6[1,22] = "MUNICIPIO DE ( OTROS )" THEN
	    LET vquita = TRIM(vquita);
            LET vexiste1 = vexiste1 + 22;
            LET vscampo6 = vscampo6[23,26];
        ELSE
          IF vscampo6[1,12] = "MUNICIPIO DE"  THEN
	    LET vquita = TRIM(vquita);
            LET vexiste1 = vexiste1 + 12;
            LET vscampo6 = vscampo6[13,26];
          ELSE
           IF vscampo6[1,1] = "#" OR vscampo6[1,1] = "Â¥" THEN
	     LET vquita = TRIM(vquita)||" Ã";
           ELSE
	     LET vquita = TRIM(vquita)||" "||vscampo6[1,1];
           END IF
	   LET vespacio = "";
           LET vexiste1 = vexiste1 + 1;
           LET vscampo6 = vscampo6[2,26];
          END IF;
        END IF;
      ELSE
        IF vscampo6[1,1] = "#" OR vscampo6[1,1] = "Â¥" THEN
	  LET vquita = TRIM(vquita)||"Ã";
        ELSE
	  LET vquita = TRIM(vquita)||vscampo6[1,1];
        END IF
        LET vexiste1 = vexiste1 + 1;
        LET vscampo6 = vscampo6[2,26];
      END IF
     END IF;
    END WHILE;
    LET vscampo6 = TRIM(vquita);
    LET vlen= LENGTH(vscampo6);
    LET vpos= LPAD(vlen,2,'0');
    LET vregistro1= TRIM(vregistro1)||"03"||vpos||vscampo6;
    LET vexiste = LENGTH(vscampo7);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
     IF vscampo7[1,1]="~" OR vscampo7[1,1]=" " OR vscampo7[1,1]="." OR
      vscampo7[1,1]="-" THEN
       LET vespacio = "F";
     ELSE
      IF vespacio = "F" THEN
        IF vscampo7[1,1] = "#" OR vscampo7[1,1] = "Â¥" THEN
	  LET vquita = TRIM(vquita)||" Ã";
          LET vespacio = "";
        ELSE
	  LET vquita = TRIM(vquita)||" "||vscampo7[1,1];
	  LET vespacio = "";
        END IF
      ELSE
        IF vscampo7[1,1] = "#" OR vscampo7[1,1] = "Â¥" THEN
	   LET vquita = TRIM(vquita)||vscampo7[1,1];
        ELSE
	   LET vquita = TRIM(vquita)||vscampo7[1,1];
        END IF
      END IF
     END IF;
     LET vscampo7 = vscampo7[2,4];
     LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vscampo7 = TRIM(vquita);
    LET vlen= LENGTH(vscampo7);
    LET vpos= LPAD(vlen,2,"0");
    LET vregistro1= TRIM(vregistro1)||"04"||vpos||vscampo7;
{    IF vscampo8[1,1] = 1 OR vscampo8[1,1] = 2 OR vscampo8[1,1] = 3 OR vscampo8[1,1] = 4 OR vscampo8[1,1] = 5 OR vscampo8[1,1] = 6 OR
     vscampo8[1,1] = 7 OR vscampo8[1,1] = 8 OR vscampo8[1,1] = 9  THEN
      LET vscampo8a = vscampo8[1,1] * 10000;
    ELSE
      LET vscampo8a = 0;
    END IF
    IF vscampo8[2,2] = 1 OR vscampo8[2,2] = 2 OR vscampo8[2,2] = 3 OR vscampo8[2,2] = 4 OR vscampo8[2,2] = 5 OR vscampo8[2,2] = 6 OR
     vscampo8[2,2] = 7 OR vscampo8[2,2] = 8 OR vscampo8[2,2] = 9  THEN
      LET vscampo8a = vscampo8a + vscampo8[2,2] * 1000;
    ELSE
      LET vscampo8a = vscampo8a + 0;
    END IF
    IF vscampo8[3,3] = 1 OR vscampo8[3,3] = 2 OR vscampo8[3,3] = 3 OR vscampo8[3,3] = 4 OR vscampo8[3,3] = 5 OR vscampo8[3,3] = 6 OR
     vscampo8[3,3] = 7 OR vscampo8[3,3] = 8 OR vscampo8[3,3] = 9  THEN
      LET vscampo8a = vscampo8a + vscampo8[3,3] * 100;
    ELSE
      LET vscampo8a = vscampo8a + 0;
    END IF
    IF vscampo8[4,4] = 1 OR vscampo8[4,4] = 2 OR vscampo8[4,4] = 3 OR vscampo8[4,4] = 4 OR vscampo8[4,4] = 5 OR vscampo8[4,4] = 6 OR
     vscampo8[4,4] = 7 OR vscampo8[4,4] = 8 OR vscampo8[4,4] = 9  THEN
      LET vscampo8a = vscampo8a + vscampo8[4,4] * 10;
    ELSE
      LET vscampo8a = vscampo8a + 0;
    END IF
    IF vscampo8[5,5] = 1 OR vscampo8[5,5] = 2 OR vscampo8[5,5] = 3 OR vscampo8[5,5] = 4 OR vscampo8[5,5] = 5 OR vscampo8[5,5] = 6 OR
     vscampo8[5,5] = 7 OR vscampo8[5,5] = 8 OR vscampo8[5,5] = 9  THEN
      LET vscampo8a = vscampo8a + vscampo8[5,5] ;
    ELSE
      LET vscampo8a = vscampo8a + 0;
    END IF
    IF vscampo8a < vcodini OR vscampo8a > vcodfin THEN
       LET vscampo8 = LPAD(round(vcodini),5,"0");
    END IF }
    LET vlen= LENGTH(vscampo8);
    LET vpos= LPAD(vlen,2,"0");
    LET vregistro2='05'||vpos||vscampo8;
    LET vlen= LENGTH(vscampo9);
    LET vpos= LPAD(vlen,2,'0');
    LET vregistro2=TRIM(vregistro2)||'10'||vpos||vscampo9;
    -- Marca el FIN de Trailer -->
   LET vlen= LENGTH(vregistro)+LENGTH(vregistro1)+LENGTH(vregistro2);
   LET vlen= TRUNC(vlen + 15);
   LET vpo1= LPAD(vlen,5,'0');
   LET vregistro2=TRIM(vregistro2)||'ES05'||vpo1||'0002**';
--INI CAS CAMBIO DE ORDEN DE CONSULTA BURO Y CIRCULO
   IF vstatus=status_1 THEN
		   ---mandamos llamar el sp para respaldar la informaciÃ³n de la consulta previa a buro del cliente       --JMAH
		    EXECUTE PROCEDURE "informix".sp_generarespaldoshistoricosic(vcliente,pSolicitud,status_1,1) INTO cResultado,cMensajeRes;	
			EXECUTE PROCEDURE "informix".sp_generarespaldoshistoricosic(vcliente,pSolicitud,status_2,1) INTO cResultado,cMensajeRes;
   
				DELETE FROM "informix".br_traslado WHERE num_solicitud = pSolicitud;
				DELETE FROM "informix".sb_regreso WHERE num_solicitud = pSolicitud;
		--IPCB Mayo2016 Reingenieria de Demonios.
				DELETE FROM "informix".br_respuesta WHERE num_solicitud = pSolicitud;
				DELETE FROM "informix".br_respuesta_aprocesar WHERE num_solicitud = pSolicitud;   
				DELETE FROM "informix".br_respuesta_aprocesar_aux WHERE num_solicitud = pSolicitud; 			
		--IPCB Mayo2016 Reingenieria de Demonios.
					   
				--ini cas
				DELETE FROM "informix".br_cr WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_hi WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_hr WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_iq WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_pa WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_pe WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_pn WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_rs WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_sc WHERE num_cliente= vcliente;
				DELETE FROM "informix".br_tl WHERE num_cliente= vcliente;
		  DELETE FROM "informix".br_ar WHERE num_cliente= vcliente;
		  DELETE FROM "informix".br_ur WHERE num_cliente= vcliente;
		  DELETE FROM "informix".br_es WHERE num_cliente= vcliente;
		  DELETE FROM "informix".br_error WHERE num_cliente= vcliente;
			--fin cas
			IF psucursal = "0001" THEN --JMAH
				DELETE FROM "informix".br_cr_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_hi_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_hr_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_iq_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_pa_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_pe_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_pn_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_rs_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_sc_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_tl_bc WHERE institucion = status_2 AND num_cliente= vcliente;  
			END IF;
           UPDATE "informix".br_auditor SET comentario = "" WHERE institucion=status_1 AND solicitud = pSolicitud;

           IF LENGTH(NVL(vcomentario,"")) = 0 THEN
             INSERT INTO "informix".br_traslado(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
              VALUES(status_1,vcliente,pSolicitud,vregistro,vregistro1,vregistro2,5,vfecha);
           ELSE
             INSERT INTO "informix".br_traslado(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
              VALUES(status_1,vcliente,pSolicitud,vregistro,vregistro1,vregistro2,6,vfecha);
             INSERT INTO "informix".br_auditor VALUES(status_1,pSolicitud,vfecha,vhora,vcomentario);
           END IF
    ELSE
			---mandamos llamar el sp para respaldar la informaciÃ³n de la consulta previa a buro del cliente       --JMAH
			EXECUTE PROCEDURE "informix".sp_generarespaldoshistoricosic(vcliente,pSolicitud,status_2,1) INTO cResultado,cMensajeRes;																													  
																														   
			
				DELETE FROM "informix".br_traslado WHERE institucion = status_2 AND num_solicitud = pSolicitud;
				DELETE FROM "informix".sb_regreso WHERE institucion = status_2 AND num_solicitud = pSolicitud;
	--IPCB Mayo2016 Reingenieria de Demonios.
				DELETE FROM "informix".br_respuesta WHERE institucion = status_2 AND num_solicitud = pSolicitud;
				DELETE FROM "informix".br_respuesta_aprocesar WHERE institucion = status_2 AND num_solicitud = pSolicitud;
				DELETE FROM "informix".br_respuesta_aprocesar_aux WHERE institucion = status_2 AND num_solicitud = pSolicitud;		
	--IPCB Mayo2016 Reingenieria de Demonios.		
				
				--ini cas
				DELETE FROM "informix".br_cr WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_hi WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_hr WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_iq WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_pa WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_pe WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_pn WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_rs WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_sc WHERE institucion=status_2 AND num_cliente= vcliente;
				DELETE FROM "informix".br_tl WHERE institucion=status_2 AND num_cliente= vcliente;
		  DELETE FROM "informix".br_ar WHERE  institucion=status_2 AND num_cliente= vcliente;
		  DELETE FROM "informix".br_ur WHERE  institucion=status_2 AND num_cliente= vcliente;
		  DELETE FROM "informix".br_es WHERE  institucion=status_2 AND num_cliente= vcliente;
		  DELETE FROM "informix".br_error WHERE institucion=status_2 AND num_cliente= vcliente;
			IF psucursal = "0001" THEN --JMAH
				DELETE FROM "informix".br_cr_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_hi_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_hr_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_iq_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_pa_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_pe_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_pn_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_rs_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_sc_bc WHERE institucion = status_2 AND numcte= vcliente;
				DELETE FROM "informix".br_tl_bc WHERE institucion = status_2 AND num_cliente= vcliente;
			END IF;
		
           UPDATE "informix".br_auditor set comentario = "" WHERE solicitud = pSolicitud;

           IF LENGTH(NVL(vcomentario,"")) = 0 THEN
             INSERT INTO "informix".br_traslado(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
              VALUES(status_2,vcliente,pSolicitud,vregistro,vregistro1,vregistro2,5,vfecha);
           ELSE
             INSERT INTO "informix".br_traslado(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
              VALUES(status_2,vcliente,pSolicitud,vregistro,vregistro1,vregistro2,6,vfecha);
             INSERT INTO "informix".br_auditor VALUES(status_2,pSolicitud,vfecha,vhora,vcomentario);
           END IF;
    END IF;
	--FIN CAS CAMBIO DE ORDEN DE CONSULTA BURO Y CIRCULO
   LET vexiste1 = 0;
   LET vexiste = 10;

	COMMIT WORK;
	IF wbegin = 'S' THEN
	    BEGIN WORK;
	END IF;
RETURN vcodret,vcliente,vsolicitud,vregistro,vregistro1,vregistro2;

END;
END PROCEDURE
DOCUMENT
' Autor: Johnattan Esquivel SÃ¡nchez' ,
' ModificaciÃ³n: Se clona el procedimiento burocred para agregar el cliente como parametro de entrada.' ,
' Fecha de nodificaciÃ³n: 15-07-2022' ,
' Proyecto: Servicio Consulta Buro en Liena.';

CREATE PROCEDURE "informix".ins_buro_credito( pInstitucion CHAR(2),pempresa CHAR(3), 
pnum_solicitud CHAR(20), pnum_cliente CHAR(20),pfecha DATE, pfecha_hoy DATE, pcadena CHAR(250), pitem_cadena INT, ppaso VARCHAR(10), pRelanzar SMALLINT)
RETURNING CHAR(1); -- Bandera si continua o espera a Buro
--------------------------------------------------------------------------------
-- Autor: Viridiana Osobampo.
-- Modificacion: Al enviarse una solicitud de cliente a consulta a una segunda
--               institucion, se actualzia el nuevo estatus a todas la solicitudes
--               que el cliente tenga en el estatus anterior.
-- Fecha de modificaciÃÂ?ÃÂÃÂ³n: 13-03-2009
--------------------------------------------------------------------------------
-- Modificacion: Maria Elena Angulo Aispuro.
-- Proyecto: Caja Unica. 
-- Fecha de Modificacion: 28-08-2018
-- Descripcion: Se inhabilita el bloque de FICO Extended
-- RQ: RQI27201
-- CC Rational: 26072
--------------------------------------------------------------------------------
-- Autor:  Francisco Javier Peraza.
-- Modifica: Se modifica orden de consulta a las instituciones de credito
-- Fecha: 15-04-2020.
-- Peticion: RQM 09 554 - Consulta a las SICs.
------------------------------------------------------------------------------------
---------------------------------------------------------------------------------
-- Autor: Luis AÂngel Juarez Vazquez, Gustavo Fuentes Lopez
-- Modificacion: Se ha agregado la validacion de producto para realizar nueva evaluacion de parametros .
-- Fecha de Modificacion: 20-08-2022.
-- Peticion: Prestamo Personal
---------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- Autor:  Felix Ignacio Leyva Gamez.
-- Modifica: Se agrega consulta aleatoria a las SICs, ,con las banderas de fallosic y vigencia
-- Fecha: 06-01-2023.
-- Peticion: RQM 09 606 - Consulta aleatoria a las SIC's cadena 2x1 - Originacion
------------------------------------------------------------------------------------
-- Cambio
DEFINE mIngresoMensual money(14,2);
DEFINE dCompromisos DECIMAL(14,2);
DEFINE vMensaje     VARCHAR(255);
DEFINE cCalifica    CHAR(1);
DEFINE sql_err      INT;
DEFINE cod_ret      CHAR(6);
DEFINE s_regreso    CHAR(1);
DEFINE iMontoBuro   INT;
DEFINE usuario_cir  VARCHAR(50);
DEFINE passwd_cir   VARCHAR(50);
DEFINE usuario_bur  VARCHAR(50);
DEFINE passwd_bur   VARCHAR(50);
DEFINE usu_orden1   CHAR(10);
DEFINE usu_orden2   CHAR(10);
DEFINE pass_orden1  CHAR(8);
DEFINE pass_orden2  CHAR(8);
DEFINE status_1      CHAR(2);
DEFINE status_2      CHAR(2);
DEFINE mensaje_orden VARCHAR(255,1);
DEFINE Relanzar SMALLINT;
DEFINE cuenta_solproc INTEGER;
-- ini caja unica. Viridiana
DEFINE csolicitud    CHAR(20);
DEFINE corigen       CHAR(1);
DEFINE cEnvio        CHAR(1);
DEFINE v_mod_parame  CHAR(1);

-- fin caja unica. Viridiana
-- JOM INI BCSCORE
DEFINE tipo_acceso_bc CHAR (03);
-- JOM FIN BCSCORE
DEFINE iDiasVigencia  INTEGER;
DEFINE iRenviar  INTEGER;
DEFINE cNumSolSIC  CHAR(20);
DEFINE cNumSolSIC2  CHAR(20);
DEFINE sSolincremento SMALLINT;
--IPCB Marzo2015 RQM 09 384-0 FICO SCORE Se requiere el grupo
DEFINE cgrupo       CHAR(1);
DEFINE v_valor_1s   DECIMAL(14,2);
DEFINE v_valor_2s   DECIMAL(14,2);
DEFINE v_tpsol                CHAR(1);
DEFINE v_bcs_min,v_bcs_max  INTEGER;
DEFINE tipo_acceso_cc  CHAR (03);
--IPCB Marzo2016 RQM 09 398-0 FICO Extended
DEFINE v_scor_prop_min DECIMAL(14,2);
DEFINE v_meses                SMALLINT;
DEFINE vAntiguedad            CHAR(1);
DEFINE v_cuantos              SMALLINT;
DEFINE v_lineaban             DECIMAL(14,2);
DEFINE v_capacidad_pago        MONEY(14,2);
DEFINE iPlazo                  INTEGER;
DEFINE v_producto			  CHAR(4);
DEFINE v_sol_sic    CHAR(20);
--RQM 09 554
DEFINE cFlujo_cc CHAR(1);
DEFINE status_consul           	CHAR(2);
DEFINE cCanalSol	CHAR (2);

DEFINE vTipoHit  			INTEGER;	
DEFINE iNewMPP  			INTEGER;	
DEFINE vCuentasPF 			SMALLINT;
--RQM 09 606
DEFINE vFalloSIC	INTEGER;


--set debug file to "/informix/Malena/ins_buro_credito.unl";
--trace on;
LET s_regreso = '0';
LET status_1='00';
LET status_2='00';
LET Relanzar=pRelanzar;
-- ini caja unica. Viridiana
LET csolicitud = "";
LET corigen    = "";
LET cEnvio     = "0";
-- fin caja unica. Viridiana
LET v_mod_parame="";

-- JOM INI BCSCORE
LET tipo_acceso_bc = "";
-- JOM FIN BCSCORE
LET cuenta_solproc = 0;
LET iDiasVigencia = 0;
LET cNumSolSIC = "";
LET cNumSolSIC2 = "";
LET iRenviar = 0;
LET sSolincremento = 0;
--IPCB Marzo2015 RQM 09 384-0 FICO SCORE
LET cgrupo     = "";
LET v_valor_1s = 0;
LET v_valor_2s = 0;
LET v_tpsol    = "";
LET v_bcs_min  = 0;
LET v_bcs_max  = 0;
LET tipo_acceso_cc = "";
--IPCB Marzo2016 RQM 09 398-0 FICO Extended
LET v_scor_prop_min = 0;
LET v_meses=0;
LET vAntiguedad  = "?";
LET v_cuantos    = 0;
LET v_lineaban   = 0;	 
LET v_capacidad_pago        = 0; 
LET iPlazo                  = 0;
LET v_producto  ="";
LET v_sol_sic = "";
--RQM 09 554
LET cFlujo_cc = '1';
LET status_consul = '';
LET cCanalSol = '';
--RQM 09 613
LET vTipoHit  = 0;	
LET vCuentasPF =0;
LET iNewMPP =0;
--RQM 09 606
LET vFalloSIC	= 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	SELECT count(*)
	INTO cuenta_solproc
	FROM bdisolic:"informix".ss_solicitudes
	WHERE empresa = pEmpresa
	AND num_solicitud = pnum_solicitud
	AND status_solicitud  IN (SELECT status_solicitud FROM bdisolic:"informix".ss_status_sol WHERE tipo_auto IN (1,2));
	
  	--RQM 09 308 Se agrega validacion para identificar si se trata de un incremento o solicitud normal.
	IF cuenta_solproc = 0 THEN		
		SELECT COUNT(*)
		INTO cuenta_solproc
		FROM bdicred:"informix".sd_bitacora_aumlincred 
		WHERE empresa = '001'
		AND num_solicitud = pnum_solicitud
		AND status  IN (SELECT status_solicitud FROM bdisolic:"informix".ss_status_sol WHERE tipo_auto IN (1,2));
		
		LET sSolincremento = 1;
		
	END IF;
	
       IF cuenta_solproc=0 THEN
          RETURN '9';
       END IF;
	   
   
---clave de circulo
SELECT valor
INTO usuario_cir  
FROM "informix".br_param
WHERE cod_param=1;

SELECT valor
INTO passwd_cir 
FROM "informix".br_param
WHERE cod_param=2;

--FJPR
SELECT canal_sol INTO cCanalSol FROM bdisolic:"informix".ss_solicitudes 
WHERE numcte = pnum_cliente AND num_solicitud = pnum_solicitud;

/*SELECT insti1 INTO status_consul FROM bdisolic:"informix".ss_canales_solic 
WHERE canal_solic = cCanalSol;*/
------------------------------------------------------------------------------------------------------------------------------------------------
--Inicio: RQM 09 606 consulta sic aleatorio y Fallo de SIC
--Tomar la ultima solicitud de la SIC
SELECT institucion, NVL(FalloSIC,0)
	INTO status_consul, vFalloSIC
	FROM bdisolic:"informix".ss_solicitudes_sic
	WHERE ROWID = (SELECT MAX(rowid)
				   FROM bdisolic:"informix".ss_solicitudes_sic
				   WHERE numcte= pnum_cliente
					AND num_solicitud = pnum_solicitud);

IF status_consul IS NULL THEN  --Valida que se tenga registro de la solicitud
	LET s_regreso = '1';	RETURN s_regreso;
	
END IF;
--Validar si la solicitud no trae fallo por ser BCScore
/*IF status_consul = 'CC' AND vFalloSIC = 0 THEN
	--Validar si en el historial tiene envio a BC
	IF EXISTS (SELECT status_solicitud FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud = pnum_solicitud AND status_solicitud = 'BC') THEN
		LET status_consul = 'BC';--Es respuesta de BCScore
	END IF;
END IF;*/
--Fin: RQM 09 606 consulta sic aleatorio y Fallo de SIC
------------------------------------------------------------------------------------------------------------------------------------------------

IF status_consul = 'CC' THEN
	LET cflujo_cc = '1';
ELSE
	LET cflujo_cc = '0';
END IF;

-- FJPR fin

--ini CAS se adapta para hacer un cambio de orden entre buro y circulo.
	IF cflujo_cc = '1' THEN
        SELECT status_solicitud
        INTO status_1
        FROM bdisolic:"informix".ss_status_sol 
        WHERE empresa=pempresa 
        AND tipo_auto='2';  --Status_1 = CC

        SELECT status_solicitud
        INTO status_2
        FROM bdisolic:"informix".ss_status_sol 
        WHERE empresa=pempresa 
        AND tipo_auto='1';   --status_2 = BC
		
		---clave de buro Prospector
		SELECT valor
		INTO usuario_bur
		FROM "informix".br_param
		WHERE cod_param=154;

		SELECT valor
		INTO passwd_bur  
		FROM "informix".br_param
		WHERE cod_param=155;
		
	ELSE
	    SELECT status_solicitud
        INTO status_1
        FROM bdisolic:"informix".ss_status_sol 
        WHERE empresa=pempresa 
        AND tipo_auto='1';   --Status_1 = BC

        SELECT status_solicitud
        INTO status_2
        FROM bdisolic:"informix".ss_status_sol 
        WHERE empresa=pempresa 
        AND tipo_auto='2';   ----status_2 = CC
		
		---clave de buro consulta consolidada (2x1)
		SELECT valor
		INTO usuario_bur
		FROM "informix".br_param
		WHERE cod_param=124;

		SELECT valor
		INTO passwd_bur  
		FROM "informix".br_param
		WHERE cod_param=125;
	END IF;

        IF status_1='BC' THEN
            LET usu_orden1=usuario_bur;
            LET usu_orden2=usuario_cir;
            LET pass_orden1=passwd_bur;
            LET pass_orden2=passwd_cir;
			--Numero de producto, consulta consolidada Buro 007
			select trim(valor) into tipo_acceso_bc
			from bdiburo:br_param
			where cod_param = 126;  
        ELSE
            LET usu_orden1=usuario_cir;
            LET usu_orden2=usuario_bur;
            LET pass_orden1=passwd_cir;
            LET pass_orden2=passwd_bur;
			--Numero de producto, prospector 107
			select trim(valor) into tipo_acceso_bc
			from bdiburo:br_param
			where cod_param = 153;  
       END IF;
--ini CAS se adapta para hacer un cambio de orden entre buro y circulo.
BEGIN
    ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
          INSERT INTO "informix".br_cadena_error VALUES (pInstitucion,pnum_cliente,pfecha, sql_err,ppaso,
          pitem_cadena,SUBSTR(pcadena,1,pitem_cadena + 10),pfecha_hoy);
          RETURN '9';
       END IF
    END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/ins_buro_credito.out";
	--TRACE ON;

	
    IF pRelanzar = 0 AND pInstitucion = status_1 THEN

        SELECT NVL(ingreso_mensual,0) INTO mIngresoMensual
        FROM bdisolic:"informix".ss_resum_scor_fin WHERE empresa = pempresa AND num_solicitud = pnum_solicitud;

        SELECT valor::int  INTO iMontoBuro  FROM bdisolic:"informix".ss_param WHERE secuencia = '326';

        IF NVL(mIngresoMensual,0) >= iMontoBuro AND pInstitucion = status_1 THEN  

-- Se obtienen las solicitudes que el cliente tiene en espera de ser calificada con la respuesta de Buro y/o Circulo
-- de credito y se evalua cada una respecto al producto de credito que se trate y continua su flujo una solicitud 
-- independiente de la otra. 
   FOREACH
--IPCB Marzo2015 RQM 09 384-0 FICO SCORE- Se modifica Query para extraer el tipo de solicitud y validar la puntuacion conforme a esto.   
            SELECT num_solicitud,TRIM(tipo_calculo),tipo_solicitud,num_producto
              INTO csolicitud,v_mod_parame,v_tpsol,v_producto
              FROM bdisolic:"informix".ss_solicitudes
             WHERE empresa = pEmpresa
--               AND numcte = pnum_cliente
                 and num_solicitud = pnum_solicitud
               AND status_solicitud = pInstitucion
             ORDER BY num_producto

--IPCB Marzo2015 RQM 09 384-0 FICO SCORE  Se modifica query para extraer el grupo
--IPCB Marzo2016 RQM 09 398-0 FICO Extended Se incluye la extraccion de los meses de historia para el Fico Extended
           SELECT origen,grupo,meses_historia
             INTO corigen, cgrupo, v_meses
             FROM bdisolic:"informix".ss_resum_scor_fin
            WHERE empresa = pempresa
              AND num_solicitud = csolicitud;

            IF nvl(corigen,'') = "" THEN
				LET corigen = '0';
            END IF

			IF corigen = '1' THEN
				EXECUTE PROCEDURE bdisolic:"informix".cal_circulocredito_cjunk(pempresa, pnum_cliente,csolicitud)
				INTO cod_ret, cCalifica, dCompromisos, vMensaje;
			ELSE
				EXECUTE PROCEDURE bdisolic:"informix".cal_circulocredito(pempresa, pnum_cliente, pnum_solicitud)
				INTO cod_ret, cCalifica, dCompromisos, vMensaje;
			END IF

            IF cod_ret <> "000" THEN
				RETURN '9';
			END IF 		
			
			--RQM 09 554 y RQM 09 606 FalloSIC
			IF cflujo_cc = '1' AND cCalifica <> 'X' AND vFalloSIC = 0 THEN
				
			--buenos antecedentes o malos antecedentes
				--Numero de producto
				select trim(valor) into tipo_acceso_bc
				from bdiburo:br_param
				where cod_param = 153;  

				--Usuario Prospector
				select trim(valor) into usu_orden2
				from bdiburo:br_param
				where cod_param = 154;   
				
				--Password Prospector
				select trim(valor) into pass_orden2
				from bdiburo:br_param
				where cod_param = 155;                           

				INSERT INTO br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
				SELECT status_2, pnum_cliente,csolicitud,  substr(envio,1,31)||tipo_acceso_bc||substr(envio,35,6)||trim(usu_orden2)||trim(pass_orden2)||trim(substr(envio,59,1000)), envio1, envio2, '0',pfecha_hoy FROM br_traslado WHERE institucion = status_1 AND
				num_solicitud = pnum_solicitud;
				
				IF v_producto <> '6500' THEN
				
					LET mensaje_orden='SOLICITUD ENVIADA A BURO DE CREDITO';
					EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(pempresa, 'sistema', csolicitud, status_2, "", mensaje_orden)
						INTO cod_ret;
					
				END IF;	
				
					IF csolicitud = pnum_solicitud THEN
						let s_regreso = '1';
					ELSE
						let s_regreso = '0';
					END IF;

			END IF			
		--REM Inicio para Inhabilitar todo el bloque de FICO SCORE Y FICO EXTEND
--IPCB Marzo2015 RQM 09 384-0 FICO SCORE Grupo 3 y 5 Hit--  se cambia condicion y se activa bloque para Fico Score	
--IPCB Octubre2015 RQM 09 384-3 FICO SCORE--Incluir grupos 1,A,2, Hit. --Se incluyen en el cgrupo
        /* IF (v_mod_parame in('2') AND  cCalifica = "0"  AND cgrupo in ('1','2','3','5','A','8') AND v_tpsol IN ( 'T','P') ) AND cflujo_cc = '0' THEN
			SELECT sc01::INTEGER INTO v_valor_1s
			  FROM bdiburo:"informix".br_sc a
			 WHERE a.rowid = (SELECT MAX(b.rowid) FROM bdiburo:"informix".br_sc b WHERE institucion = 'BC' AND b.num_cliente= pnum_cliente AND sc00 <> "004")
              AND institucion = 'BC'
			  AND num_cliente=pnum_cliente
			  AND sc00 <> "004";
			  
			SELECT unique bc_scoremin, bc_scoremax
			  INTO v_bcs_min,v_bcs_max
			  FROM bdisolic:ss_scoring_modelo2
			 WHERE tp_solicitud IN ( 'T','P')
			   AND tp_solicitud = v_tpsol
			   AND grupo = cgrupo
			   AND grupo in ('1','2','3','5','A','8') 
			   AND fc_score_max > 0
			   AND status_sol = 'RT'
			   and num_producto = v_producto;

         --END IF;
			 		
			IF(v_valor_1s >= v_bcs_min and v_valor_1s <= v_bcs_max) THEN
                    IF s_regreso = '0' THEN            

-- JOM INI BCSCORE
                        if (status_2='BC') THEN
                            select trim(valor) into tipo_acceso_bc
                              from bdiburo:br_param
                              where cod_param = 126;                            

                            INSERT INTO br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
                            SELECT status_2, pnum_cliente,csolicitud,  substr(envio,1,31)||tipo_acceso_bc||substr(envio,35,6)||trim(usu_orden2)||trim(pass_orden2)||trim(substr(envio,59,1000)), envio1, envio2, '0',pfecha_hoy FROM br_traslado WHERE institucion = status_1 AND
                            num_solicitud = pnum_solicitud;
                        else
						     select trim(valor) into tipo_acceso_cc
                              from bdiburo:br_param
                              where cod_param = 141; 
							  
							select num_solicitud_sic   INTO v_sol_sic  from bdisolic:"informix".ss_solicitudes_sic 
                            where numcte = pnum_cliente
							and num_solicitud = pnum_solicitud; 
							
							IF (pnum_solicitud = v_sol_sic ) then							
								INSERT INTO br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
								SELECT status_2, pnum_cliente,csolicitud,  substr(envio,1,31)||tipo_acceso_cc||substr(envio,35,6)||trim(usu_orden2)||trim(pass_orden2)||trim(substr(envio,59,1000)), envio1, envio2, '0',pfecha_hoy FROM br_traslado WHERE institucion = status_1 AND
								num_solicitud = pnum_solicitud;
							ELSE
							   INSERT INTO br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
							   SELECT status_2, pnum_cliente,csolicitud,  replace(substr(envio,1,31)||tipo_acceso_cc||substr(envio,35,6)||trim(usu_orden2)||trim(pass_orden2)||trim(substr(envio,59,1000)),trim(v_sol_sic),trim(pnum_solicitud)), envio1, envio2, '0',pfecha_hoy FROM br_traslado WHERE institucion = status_1 AND
							   num_solicitud = v_sol_sic;   
							END IF;
                        end if;
-- JOM FIN BCSCORE

                       IF status_2='CC' THEN
                         LET mensaje_orden='SOLICITUD ENVIADA A CIRCULO DE CREDITO';
                       ELSE 
                         LET mensaje_orden='SOLICITUD ENVIADA A BURO DE CREDITO';
                       END IF;

                        EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(pempresa, 'sistema', csolicitud, status_2, "", mensaje_orden)
                        INTO cod_ret;

                        IF csolicitud = pnum_solicitud THEN
                            let s_regreso = '1';
                        ELSE
                            let s_regreso = '0';
                        END IF;
					
                    ELIF s_regreso = '1' THEN
		
						EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(pempresa, 'sistema', csolicitud, status_2, "", mensaje_orden)
							INTO cod_ret;
					END IF
			END IF


--IPCB Marzo2016 --RQM 09 398 FICO Extended  --INICIO 
-- AAME 20180828 [RQI27201] Se inhabilita el bloque de FICO Extended INICIO{ 			  	
		 
		 ELIF  (v_mod_parame in('2') AND  cCalifica = "X"   AND cgrupo in ('1','2','3','5','A','8') AND v_tpsol IN ( 'T','P') ) AND cflujo_cc = '0' THEN
		 
			EXECUTE PROCEDURE bdisolic:"informix".sp_calculo_scpropietario(pempresa,csolicitud,cgrupo,v_tpsol,cCalifica,v_meses,v_producto) 	
			INTO v_valor_2s;
			
			SELECT unique NVL(pro_scormin,0)  --Extrae el valor minimo pra ser aprobado por score propietario
				 INTO v_scor_prop_min
			   FROM bdisolic:"informix".ss_scoring_modelo2
			WHERE tp_solicitud IN ( 'T','P')
				  AND tp_solicitud = v_tpsol
				  AND respuesta_sic = DECODE(cCalifica,"X","X","0","0","2","1","3","1","4","1","1")
				  AND grupo = cgrupo
				  AND grupo in ('1','2','3','5','A','8') 
				  AND status_sol = 'AT'



				  and num_producto= v_producto AND tp_parametrico=v_mod_parame;
				  
			IF(v_valor_2s <  v_scor_prop_min) THEN
				IF s_regreso = '0' THEN            
					IF(status_2='BC') THEN
						select trim(valor) into tipo_acceso_bc
						  from bdiburo:br_param
						 where cod_param = 126;                            

						INSERT INTO br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
						SELECT status_2, pnum_cliente,csolicitud,  substr(envio,1,31)||tipo_acceso_bc||substr(envio,35,6)||trim(usu_orden2)||trim(pass_orden2)||trim(substr(envio,59,1000)), envio1, envio2, '0',pfecha_hoy FROM br_traslado WHERE institucion = status_1 AND
						num_solicitud = pnum_solicitud;
					--ELSE -- AAME 20180828 [RQI27201] INI
						--select trim(valor) into tipo_acceso_cc
                        --  from bdiburo:br_param
                        -- where cod_param = 142; 
					
						--select num_solicitud_sic   INTO v_sol_sic  from bdisolic:"informix".ss_solicitudes_sic 
                        --    where numcte = pnum_cliente
						--	and num_solicitud = pnum_solicitud;
							 
					    --IF (pnum_solicitud = v_sol_sic ) then
						--   INSERT INTO br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
						--   SELECT status_2, pnum_cliente,csolicitud,  substr(envio,1,31)||tipo_acceso_cc||substr(envio,35,6)||trim(usu_orden2)||trim(pass_orden2)||trim(substr(envio,59,1000)), envio1, envio2, '0',pfecha_hoy FROM br_traslado WHERE institucion = status_1 AND
						--   num_solicitud = pnum_solicitud;
						--ELSE
						--   INSERT INTO br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
						--   SELECT status_2, pnum_cliente,csolicitud,  replace(substr(envio,1,31)||tipo_acceso_cc||substr(envio,35,6)||trim(usu_orden2)||trim(pass_orden2)||trim(substr(envio,59,1000)),trim(v_sol_sic),trim(pnum_solicitud)), envio1, envio2, '0',pfecha_hoy FROM br_traslado WHERE institucion = status_1 AND
						--   num_solicitud = v_sol_sic;

						   
						--END IF;   -- AAME 20180828 [RQI27201] 
					END IF;

					IF status_2='CC' THEN
						--LET mensaje_orden='SOLICITUD ENVIADA A CIRCULO DE CREDITO'; -- AAME 20180828 [RQI27201] Se comenta para que no mande a Circulo para FICO EXTEND cuando sea No HIT
						let s_regreso = '0';
					ELSE 
						LET mensaje_orden='SOLICITUD ENVIADA A BURO DE CREDITO';
					--END IF;-- AAME 20180828 [RQI27201]

						EXECUTE PROCEDURE bdisolic:sp_actualiza_status_sol(pempresa, 'sistema', csolicitud, status_2, "", mensaje_orden)
						INTO cod_ret;
					

						IF csolicitud = pnum_solicitud THEN
							let s_regreso = '1';
						ELSE
							let s_regreso = '0';
						END IF;
					END IF;				ELIF s_regreso = '1' THEN
		
					EXECUTE PROCEDURE bdisolic:sp_actualiza_status_sol(pempresa, 'sistema', csolicitud, status_2, "", mensaje_orden)
					INTO cod_ret;
				END IF;
			END IF; 
			
-- }FIN AAME 20180828 [RQI27201] Se inhabilita el bloque de FICO Extended
--IPCB Marzo2016 --RQM 09 398 FICO Extended  --FIN	

        END IF;	*/	-- REM Fin para Inhabilitar todo el bloque de FICO SCORE Y FICO EXTEND		
--IPCB Marzo2015 RQM 09 384-0 FICO SCORE  cierre bloque para Fico Score
     END FOREACH

-- fin caja unica
	END IF
	END IF;
    IF pRelanzar = 1 THEN --se valida si ya tiene un envio con vigencia a la espera de la respuesta de las SIC's

--set debug file to "/RESPALDOS/ipcb/pruebas/ins_buro_credito.unl";trace on; 

------consultas SIC --JMAH --se valida si el cliente tiene una respuesta pendiente.
	
		SELECT num_solicitud_sic
			INTO cNumSolSIC
		FROM bdisolic:"informix".ss_solicitudes_sic
		WHERE numcte= pnum_cliente	
		AND num_solicitud = pnum_solicitud
		AND fecha_sic IS NULL;		
			
			
		IF cNumSolSIC IS NULL  THEN--Cuando no tenga un envio pendiente
			LET iRenviar = 1;
		ELIF cNumSolSIC = pnum_solicitud  THEN --cuando la solicitud sea la misma que tengo pendiente
			LET iRenviar = 1;
		ELIF cNumSolSIC <>  pnum_solicitud THEN		
			--se valida que la solicitud se encuentre todavia en estatus de consulta
			SELECT count(*)
			INTO cuenta_solproc
			FROM bdisolic:ss_solicitudes
			WHERE empresa = pempresa
			AND num_solicitud = cNumSolSIC
			AND status_solicitud  IN (select status_solicitud from bdisolic:ss_status_sol where tipo_auto in (1,2));

			IF cuenta_solproc=0 THEN --cuando la solicitud sea diferente a la que esta pendiente, pero esta ya no se encuenta en estatus valido de consulta se reenvia
				LET iRenviar = 1;				
			ELIF cuenta_solproc = 1 THEN ----cuando la solicitud sea diferente a la que esta pendiente, pero esta se encuenta en estatus valido de consulta no se reenvia
				LET iRenviar = 0;	
			END IF;
		END IF


		IF iRenviar = 1  THEN
--IPCB agosto 2015 // Se quita el insert a la solicitudes sic por que en algunos casos genera registro duplicado en dicha tabla		
			IF cNumSolSIC IS NOT NULL THEN			
				UPDATE bdisolic:"informix".ss_solicitudes_sic
					SET num_solicitud_sic = pnum_solicitud					
				WHERE numcte= pnum_cliente				
				AND fecha_sic IS NULL
				AND num_solicitud = pnum_solicitud;				
			END IF;

			IF pInstitucion = status_1 THEN
				CALL "informix".burocred (pempresa, "0000", USER, pnum_solicitud, 0)
				RETURNING cod_ret;
					IF status_1='CC' THEN
					 LET mensaje_orden='SOLICITUD ENVIADA A CIRCULO DE CREDITO';
					ELSE 
					 LET mensaje_orden='SOLICITUD ENVIADA A BURO DE CREDITO';
					END IF;
					--RQM 09 308 Se agrega validacion para que no se ejecute el procedimiento que actualiza el estatus.
					IF sSolincremento = 0 THEN					
						EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(pempresa, 'sistema', pnum_solicitud, status_1, "", mensaje_orden)
						INTO cod_ret;
					END IF;

				LET s_regreso = '1';
			ELSE 
			   IF pRelanzar = 1 AND pInstitucion = status_2 THEN
					DELETE FROM "informix".br_traslado WHERE institucion = status_2 AND num_solicitud = pnum_solicitud;
					DELETE FROM "informix".sb_regreso WHERE institucion = status_2 AND num_solicitud = pnum_solicitud;
--IPCB Mayo2016 Reingenieria de Demonios.
                    DELETE FROM "informix".br_respuesta WHERE institucion = status_2 AND num_solicitud = pnum_solicitud;
                    DELETE FROM "informix".br_respuesta_aprocesar WHERE institucion = status_2 AND num_solicitud = pnum_solicitud;    
					DELETE FROM "informix".br_respuesta_aprocesar_aux WHERE institucion = status_2 AND num_solicitud = pnum_solicitud;  
--IPCB Mayo2016 Reingenieria de Demonios.
					--ini cas
					   DELETE FROM "informix".br_cr WHERE institucion = status_2 AND num_cliente= pnum_cliente;
					   DELETE FROM "informix".br_hi WHERE institucion = status_2 AND num_cliente= pnum_cliente;
					   DELETE FROM "informix".br_hr WHERE institucion = status_2 AND num_cliente= pnum_cliente;
					   DELETE FROM "informix".br_iq WHERE institucion = status_2 AND num_cliente= pnum_cliente;
					   DELETE FROM "informix".br_pa WHERE institucion = status_2 AND num_cliente= pnum_cliente;
					   DELETE FROM "informix".br_pe WHERE institucion = status_2 AND num_cliente= pnum_cliente;
					   DELETE FROM "informix".br_pn WHERE institucion = status_2 AND num_cliente= pnum_cliente;
					   DELETE FROM "informix".br_rs WHERE institucion = status_2 AND num_cliente= pnum_cliente;
					   DELETE FROM "informix".br_sc WHERE institucion = status_2 AND num_cliente= pnum_cliente;
					   DELETE FROM "informix".br_tl WHERE institucion = status_2 AND num_cliente= pnum_cliente;
					--fin cas
					UPDATE "informix".br_auditor SET comentario = "" WHERE institucion = status_2 AND solicitud = pnum_solicitud;
					--IPCB 12Abr21 Se corrige insert para el reenvio de BC con producto prospector
					--INSERT INTO "informix".br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
					--SELECT status_2, pnum_cliente,num_solicitud,  TRIM(SUBSTR(envio,1,40))||TRIM(usu_orden2)||TRIM(pass_orden2)||TRIM(SUBSTR(envio,59,1000)), envio1, envio2, '0',pfecha_hoy FROM "informix".br_traslado WHERE institucion = status_1 AND
					--num_solicitud = pnum_solicitud;
					
					
					INSERT INTO "informix".br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
						SELECT status_2, pnum_cliente,num_solicitud,  substr(envio,1,31)||tipo_acceso_bc||substr(envio,35,6)||trim(usu_orden2)||trim(pass_orden2)||trim(substr(envio,59,1000)), envio1, envio2, '0',pfecha_hoy FROM "informix".br_traslado WHERE institucion = status_1 AND
						num_solicitud = pnum_solicitud;

					   IF status_2='CC' THEN
						 LET mensaje_orden='SOLICITUD ENVIADA A CIRCULO DE CREDITO';
					   ELSE 
						 LET mensaje_orden='SOLICITUD ENVIADA A BURO DE CREDITO';
					   END IF;
						--RQM 09 308 Se agrega validacion para que no se ejecute el procedimiento que actualiza el estatus.
					   IF sSolincremento = 0 THEN					   
						 EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(pempresa, 'sistema', pnum_solicitud, status_2, "", mensaje_orden)
						INTO cod_ret;
					   END IF;
						LET s_regreso = '1';
			   END IF
			END IF
		ELSE			
		let s_regreso = '1';
		END IF;	
	END IF;
RETURN s_regreso;
END;
END PROCEDURE DOCUMENT "Version 1.00.000",
"MODIFICO: CARLOS OCHOA",
"DESCRIPCION: SE AGREGAN VALIDACIONES PARA QUE TRABAJE CON SOLICITUDES DE INCREMENTO DE LINEA";

create procedure "informix".burofisicas_concilia_cnr()
--EXECUTE PROCEDURE burofisicas_concilia_cnr();
       returning char(5);


   define vcodret                   char(5);
   define vsql                      char(1500);
   define iTotalProcesados          integer;
   define iSqlErr                   integer;
   define tb_total_sdo_actual       decimal(20,2);
   define tb_total_sdo_vencido      decimal(20,2);
   define tb_total_seg_tl           decimal(20);
   define tb_total_sdo_actual_bc    decimal(20,2);
   define tb_total_sdo_vencido_bc   decimal(20,2);
   define tb_total_seg_tl_bc        decimal(20);
   define tb_total_cps_bc           integer;
   define tb_total_cns              integer;
   define tb_total_no_procesados    integer;
   define vdia                      char(02);
   define vmes                      char(02);
   define vanio                     char(4);
   define vfecha_cinta              date;
   define vfecha_reporte 			char(08);   
   define vclave_usu                char(10);
   define vclave_usu_bc             char(10);

BEGIN

   on exception set iSqlErr
      if iSqlErr != 0 then
         let vcodret = iSqlErr;
         return vcodret;
      end if;
   end exception;

   let vcodret = "000";
   let vsql = "";
   let iTotalProcesados = 0;
   let tb_total_sdo_actual     = 0;
   let tb_total_sdo_vencido    = 0;
   let tb_total_seg_tl         = 0;
   let tb_total_seg_tl_bc      = 0;
   let tb_total_sdo_actual_bc  = 0;
   let tb_total_sdo_vencido_bc = 0;
   let tb_total_cps_bc         = 0;
   let tb_total_cns         = 0;
   let tb_total_no_procesados  = 0;
   let vdia  = '';
   let vmes  = '';
   let vanio = '';
   let vfecha_cinta = date(0);
   let vfecha_reporte = '';
   let vclave_usu   = '';
   let vclave_usu_bc    = '';

--SET DEBUG FILE TO "burofisicas_concilia_cnr.out";
--TRACE ON; 

set isolation to dirty read;
set lock mode to wait 3;

   select upper(valor) into vclave_usu
      from br_param
      where cod_param = 1;

   select upper(valor) into vclave_usu_bc
      from br_param
      where cod_param = 128;

	select  first 1 fecha_reporte  INTO vfecha_reporte
	from br_burofisicas_describe_cnr;

   let vdia  = substr(vfecha_reporte,1,2);
   let vmes  = substr(vfecha_reporte,3,2);
   let vanio = substr(vfecha_reporte,5,4);
   let vfecha_cinta = mdy(vmes,vdia,vanio);



-- Extracción Círculo de Crédito
  let vsql = 'echo " unload to '''|| '/resplogifx/burodecredito/xburofiscnr.unl'''||" delimiter '|' "||
             '" > /resplogifx/burodecredito/genburofiscnr.sql';
  system vsql;

  let vsql = 'echo "'||
             ' select registro from bdiburo:br_burofisicas_cnr where numreg=1' ||
             ' union ' ||
             ' select case when substr(a.registro,1,2)='||'''TL'''||' and a.registro matches '||'''*3002CV9903FIN'''||' ' ||  
             ' THEN trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-3))::lvarchar ||' || 
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-2))::lvarchar ||' ||
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-1))::lvarchar||' || 
--                  ' trim(replace(registro,'||'''BY30560001'''||','||'''TGD0924BAN'''||'))::lvarchar ' ||  
                  ' trim(replace(registro,'''||vclave_usu_bc||''','''||vclave_usu||'''))::lvarchar ' ||  
             ' ELSE trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-3))::lvarchar||' ||  
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-2))::lvarchar||' ||  
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-1))::lvarchar||' ||
--                 ' trim(replace(registro,'||'''BY30560001'''||','||'''TGD0924BAN'''||'))::lvarchar' ||  
                 ' trim(replace(registro,'''||vclave_usu_bc||''','''||vclave_usu||'''))::lvarchar' ||  
             ' END' ||  
             ' from bdiburo:br_burofisicas_cnr a where substr(a.registro,1,2)='||'''TL'''||' '||  
             ' union ' ||  
             ' select '||'''TRLR'''||'||lpad(sum(saldo_actual)::dec(14,0),14,'||'''0'''||')||'||''''''||'||lpad(sum(saldo_venc)::dec(14,0),14,'||'''0'''||')' ||  
			 ' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||  ''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||   ''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||
             '''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  			 
             --' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||' ||  
             --' '||'''000000000'''||'||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||'''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  
             ' from bdiburo:br_burofisicas_describe_cnr where fecha_reporte = '''|| vfecha_reporte ||''';' ||
             ' " >> /resplogifx/burodecredito/genburofiscnr.sql';
 system vsql;

  let vsql = 'dbaccess bdiburo /resplogifx/burodecredito/genburofiscnr.sql';
  system vsql;

  let vsql = "sed 's/&/ /g' /resplogifx/burodecredito/xburofiscnr.unl > /resplogifx/burodecredito/xburofis1cnr.unl ";
  system vsql;

  let vsql = "sed 's/[~]*|//g' /resplogifx/burodecredito/xburofis1cnr.unl > /resplogifx/burodecredito/xburofis2cnr.unl ";
  system vsql;

  let vsql = "sed 's/|//g' /resplogifx/burodecredito/xburofis2cnr.unl > /resplogifx/burodecredito/xburofis1cnr.unl ";
  system vsql;

  LET vsql = "cat  /resplogifx/burodecredito/xburofis1cnr.unl | tr -d '\n' > /resplogifx/burodecredito/cinta_circulocnr"||vfecha_reporte||".txt ";
  SYSTEM vsql;

  let vsql = "gzip /resplogifx/burodecredito/cinta_circulocnr"||vfecha_reporte||".txt ";
  system vsql;

  let vsql = "rm /resplogifx/burodecredito/xburofiscnr.unl /resplogifx/burodecredito/xburofis1cnr.unl /resplogifx/burodecredito/xburofis2cnr.unl";    
  system vsql;   

  let vsql = '';


-- Extracción Buró de Crédito
  let vsql = 'echo " unload to '''|| '/resplogifx/burodecredito/xburofis_bccnr.unl'''||" delimiter '|' "||
             '" > /resplogifx/burodecredito/genburofis_bccnr.sql';
  system vsql;

  let vsql = 'echo "'||
--             ' select replace(registro,'||'''TGD0924BAN'''||','||'''BY30560001'''||') from bdiburo:br_burofisicas_cnr where numreg=1' ||
             ' select replace(registro,'''||vclave_usu||''','''||vclave_usu_bc||''') from bdiburo:br_burofisicas_cnr where numreg=1' ||
             ' union ' ||
/*
             ' select case when a.registro matches '||'''*0208CONOCIDO*'''||' ' ||  
                   ' THEN trim(replace(registro,'||'''0208CONOCIDO'''||','||''''''||'))::lvarchar ' ||  
             ' else a.registro END ' ||
             '   from bdiburo:br_burofisicas_cnr a where substr(a.registro,1,2)='||'''PA'''||' ' ||  
             ' union ' ||
*/
             ' select case when substr(a.registro,1,2)='||'''TL'''||' and a.registro matches '||'''*3002CV9903FIN'''||' ' ||  
             ' THEN trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-3))::lvarchar ||' ||
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-2))::lvarchar||' || 
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-1))::lvarchar||' || 
--                  ' trim(replace(registro,'||'''3002CV9903FIN'''||','||'''3002CV9903FIN'''||'))::lvarchar ' ||  
--                 ' trim(replace(registro,'||'''TGD0924BAN'''||','||'''BY30560001'''||'))::lvarchar' ||  
                 ' trim(replace(registro,'''||vclave_usu||''','''||vclave_usu_bc||'''))::lvarchar' ||  
             ' ELSE trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-3))::lvarchar||' ||
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-2))::lvarchar||' ||  
                  ' trim((select registro from bdiburo:br_burofisicas_cnr where numreg=a.numreg-1))::lvarchar||' ||  
--                 ' trim(registro)::lvarchar' ||  
--                 ' trim(replace(registro,'||'''TGD0924BAN'''||','||'''BY30560001'''||'))::lvarchar' ||  
                 ' trim(replace(registro,'''||vclave_usu||''','''||vclave_usu_bc||'''))::lvarchar' ||  
             ' END' ||  
             ' from bdiburo:br_burofisicas_cnr a where substr(a.registro,1,2)='||'''TL'''||' '||  
             ' union ' ||  
             ' select '||'''TRLR'''||'||lpad(sum(saldo_actual)::dec(14,0),14,'||'''0'''||')||'||''''''||'||lpad(sum(saldo_venc)::dec(14,0),14,'||'''0'''||')' ||  
             --' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||' ||  
             --' '||'''000000000'''||'||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||'''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  
             ' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||  ''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||   ''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||
             '''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  			 
             ' from bdiburo:br_burofisicas_describe_cnr where fecha_reporte = '''|| vfecha_reporte ||'''' ||
             ' " >> /resplogifx/burodecredito/genburofis_bccnr.sql';
 system vsql;

  let vsql = 'dbaccess bdiburo /resplogifx/burodecredito/genburofis_bccnr.sql';
  system vsql;

  let vsql = "sed 's/&/ /g' /resplogifx/burodecredito/xburofis_bccnr.unl > /resplogifx/burodecredito/xburofis1_bccnr.unl ";
  system vsql;

  let vsql = "sed 's/[~]*|//g' /resplogifx/burodecredito/xburofis1_bccnr.unl > /resplogifx/burodecredito/xburofis2_bccnr.unl ";
  system vsql;

  let vsql = "sed 's/|//g' /resplogifx/burodecredito/xburofis2_bccnr.unl > /resplogifx/burodecredito/xburofis1_bccnr.unl ";
  system vsql;

  LET vsql = "cat  /resplogifx/burodecredito/xburofis1_bccnr.unl | tr -d '\n' > /resplogifx/burodecredito/cinta_burocnr"||vfecha_reporte||".txt ";
  SYSTEM vsql;

  let vsql = "rm /resplogifx/burodecredito/xburofis_bccnr.unl /resplogifx/burodecredito/xburofis1_bccnr.unl /resplogifx/burodecredito/xburofis2_bccnr.unl";   
  system vsql;    

  let vsql = "gzip /resplogifx/burodecredito/cinta_burocnr"||vfecha_reporte||".txt ";
  system vsql;

  let vsql = 'echo "------ CIFRAS GENERALES ------" > /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  select count(*) into tb_total_cns from br_burofisicas_concilia_cnr where empresa = '001' and motivo = 'CNS' and fecha_cinta = vfecha_cinta;

  let vsql = 'echo " Créditos excluidos por ser Clientes Nuevos = => '||tb_total_cns|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  select count(*) into tb_total_no_procesados from br_burofisicas_concilia_cnr where empresa = '001' and motivo = 'CNP' and fecha_cinta = vfecha_cinta;

  let vsql = 'echo " Créditos no procesados = => '||tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  select int_calculo into iTotalProcesados from br_burofisicas_concilia_cnr where empresa = '001' and motivo = 'TCP' and fecha_cinta = vfecha_cinta;
  
  let vsql = 'echo " TOTAL créditos procesados = => '||iTotalProcesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo "------ CIFRAS BURO DE CREDITO ------" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

	

	SELECT --{+INDEX(br_burofisicas_cnr idx_burofisicas_cnr_reg)} 
		registro FROM bdiburo:br_burofisicas_cnr INTO TEMP reg_tl WITH NO LOG; -- ** RQI 21 331 

--  select count(*) into tb_total_seg_tl_bc from bdiburo:br_burofisicas_describe_cnr where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas_cnr where substr(registro,1,2)='TL' and substr(registro,11,10)='BY30560001');
  --select count(*) into tb_total_seg_tl_bc from bdiburo:br_burofisicas_describe_cnr where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas_cnr where substr(registro,1,2)='TL' and substr(registro,11,10)=vclave_usu);
  select count(*) into tb_total_seg_tl_bc from bdiburo:br_burofisicas_describe_cnr where num_credito in (select substr(registro,38,12) from reg_tl where substr(registro,1,2)='TL' and substr(registro,11,10)=vclave_usu);

  let vsql = 'echo " Créditos reportados = => '||tb_total_seg_tl_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  select count(*) into tb_total_cps_bc from br_burofisicas_concilia_cnr where empresa = '001' and motivo = 'CPS' and fecha_cinta = vfecha_cinta;

  let vsql = 'echo " Créditos excluidos por error en CÃ?Â³digo Postal = => '||tb_total_cps_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Créditos excluidos por ser Clientes Nuevos = => '||tb_total_cns|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Créditos no procesados = => '||tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

--  let vsql = 'echo " TOTAL Créditos procesados Buró de Crédito = => '||tb_total_seg_tl_bc+tb_total_cps_bc+tb_total_cns+tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  let vsql = 'echo " TOTAL Créditos procesados Buró de Crédito = => '||tb_total_seg_tl_bc+tb_total_cns+tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo "------ S a l d o s  Reportados a Buró de Crédito------" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  --select lpad(sum(saldo_actual)::dec(14,0),14,"0"),lpad(sum(saldo_venc)::dec(14,0),14,"0") into tb_total_sdo_actual_bc,tb_total_sdo_vencido_bc
  --from bdiburo:br_burofisicas_describe_cnr where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas_cnr where substr(registro,1,2)='TL' and substr(registro,11,10)=vclave_usu);
  select lpad(sum(saldo_actual)::dec(14,0),14,"0"),lpad(sum(saldo_venc)::dec(14,0),14,"0") into tb_total_sdo_actual_bc,tb_total_sdo_vencido_bc
  from bdiburo:br_burofisicas_describe_cnr where num_credito in (select substr(registro,38,12) from reg_tl where substr(registro,1,2)='TL' and substr(registro,11,10)=vclave_usu);
--  from bdiburo:br_burofisicas_describe_cnr where num_credito in (select substr(registro,38,12) from bdiburo:br_burofisicas_cnr where substr(registro,1,2)='TL' and substr(registro,11,10)='BY30560001');

  let vsql = 'echo " Saldo actual = => '||tb_total_sdo_actual_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Saldo vencido = => '||tb_total_sdo_vencido_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo "------ CIFRAS CIRCULO DE CREDITO ------" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

--  select count(*) into tb_total_seg_tl from bdiburo:br_burofisicas_describe_cnr; 

--  let vsql = 'echo " Créditos reportados = => '||tb_total_seg_tl|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  let vsql = 'echo " Créditos reportados = => '||tb_total_seg_tl_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Créditos excluidos por ser Clientes Nuevos = => '||tb_total_cns|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " Créditos no procesados = => '||tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

--  let vsql = 'echo " TOTAL Créditos procesados Círculo de Crédito = => '||tb_total_seg_tl + tb_total_cns + tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  let vsql = 'echo " TOTAL Créditos procesados Círculo de Crédito = => '||tb_total_seg_tl_bc + tb_total_cns + tb_total_no_procesados|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo "------ S a l d o s  Reportados a Círculo de Crédito------" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

--  select lpad(sum(saldo_actual)::dec(14,0),14,"0"),lpad(sum(saldo_venc)::dec(14,0),14,"0") into tb_total_sdo_actual,tb_total_sdo_vencido
--  from bdiburo:br_burofisicas_describe_cnr;

--  let vsql = 'echo " Saldo actual = => '||tb_total_sdo_actual|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  let vsql = 'echo " Saldo actual = => '||tb_total_sdo_actual_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

--  let vsql = 'echo " Saldo vencido = => '||tb_total_sdo_vencido|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  let vsql = 'echo " Saldo vencido = => '||tb_total_sdo_vencido_bc|| '" >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;

  let vsql = 'echo " " >> /resplogifx/burodecredito/cifrasdecontrolcnr'||vfecha_reporte||'.txt';
  system vsql;
  
	BEGIN;
		DROP INDEX "informix".idx_burofisicas_cnr_reg;
	COMMIT;
	
	UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_burofisicas_cnr;

  return vcodret;

END;
end procedure;