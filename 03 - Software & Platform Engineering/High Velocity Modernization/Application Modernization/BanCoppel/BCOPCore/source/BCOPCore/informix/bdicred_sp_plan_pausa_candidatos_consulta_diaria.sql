CREATE PROCEDURE "informix".sp_plan_pausa_candidatos_consulta_diaria(
    ) RETURNING
    CHAR(6)       AS codigo_retorno,
    VARCHAR(100)  AS mError        ;
--
--  CONTROL DE CAMBIOS
---------------------------------------------------------------------------------------------------------------
--Creacion: JBL - SCP
--Descripcion: Procedimiento para generar layout con los clientes prospectos para plan en pausa
--RQM 09 636 Plan en Pausa tarjeta clasica
--Equipo TCCCREDITO 16
--Fecha: 2024/11
--Version: 
--------------------------------------------------------------------------------------------------------------
-- Variables de control de errores
    DEFINE iIsamErr                 INTEGER     ;
    DEFINE iSqlErr                  INTEGER     ;
    DEFINE cErrorInfo               CHAR(80)    ;
    DEFINE cCodRet          	    CHAR(6)     ;
    DEFINE vcDirectorio             VARCHAR(100);
    DEFINE vcNombreArchivoFinal     VARCHAR(100);
    DEFINE cFecha_Actual            CHAR(8)     ;
    DEFINE vcNombreArchivo          VARCHAR(100);
    DEFINE vcNombreArchivov         VARCHAR(100);
    DEFINE mError                   VARCHAR(100);
    -- Variables generales
    DEFINE csSQL                    LVARCHAR(10000);
    DEFINE csSQLAux                 LVARCHAR(10000);
    -- Variables relacionadas con las tablas
    DEFINE cNum_Cte                 CHAR(20);
    DEFINE cNum_Credito             CHAR(20);
    DEFINE cNum_Producto            CHAR(4) ;
    DEFINE vcNombre_Com             VARCHAR(100) ;
    DEFINE dLinea_Credito           DECIMAL(18,2);
    DEFINE dPago_Minimo             DECIMAL(18,2);
    DEFINE dPago_minimo_pendiente   DECIMAL(18,2);
    DEFINE dtFecha_Corte            DATE;
    DEFINE dtFecha_Pago             DATE;
    DEFINE dtFecha_Originacion      DATE;
    DEFINE dSaldo_Revolvente        DECIMAL(18,2);
    DEFINE dSaldo_Para_Plan         DECIMAL(18,2);
    DEFINE iPlazo_Sugerido          INTEGER;
    DEFINE iTasa_Interes            INTEGER;
    DEFINE cNum_Telefono_casa       CHAR(13);
    DEFINE cCanal                   CHAR(3);
    DEFINE cCampania                CHAR(20);
    DEFINE cCalle                   CHAR(40);
    DEFINE cNum_Casa                CHAR(39);
    DEFINE cColonia                 CHAR(60);
    DEFINE cNum_Celular             CHAR(13);
    DEFINE cMunicipio               CHAR(30);
    DEFINE cEstado                  CHAR(30);
    DEFINE cCp                      CHAR(5);
    DEFINE vcEmail                  CHAR(100);
    DEFINE cNum_Credito_Bitac       CHAR(20);
    DEFINE iEstatusBitacora         SMALLINT;
    -- Variables auxiliares
    DEFINE vcAbono_TotalText        VARCHAR(21);
    DEFINE dSaldo_Maesdos           DECIMAL(18,2);
    DEFINE dSaldoVencido_Maesdos    DECIMAL(18,2);
    DEFINE dPlan_12_Aux             DECIMAL(18,2);
    DEFINE dPlan_18_Aux             DECIMAL(18,2);
    DEFINE dPlan_24_Aux             DECIMAL(18,2);
    DEFINE dtFecha_Hoy              DATE;
    DEFINE dtFecha_Liquidacion      DATE;
    -- Variables para proyeccion de credito
    DEFINE cResCodRet12             CHAR(6);
    DEFINE iResPeriodo12            INTEGER;
    DEFINE dtResFechaCouta12        DATE;
    DEFINE dResSdoInicial12         DECIMAL(18,2);
    DEFINE dResMensualidad212       DECIMAL(18,2);
    DEFINE dResIntereses12          DECIMAL(18,2);
    DEFINE dResIvaIn12              DECIMAL(18,2);
    DEFINE dResCapital12            DECIMAL(18,2);
    DEFINE dResSdoFinal12           DECIMAL(18,2);
    DEFINE sResDiasPeriodo12        SMALLINT;
    DEFINE dtResFechaAper12         DATE;
    DEFINE cResPlazo12              CHAR(3);
    -- Variables para plazos 18 y 24 meses (similar a las de 12 meses)
    DEFINE cResCodRet18         CHAR(6);
    DEFINE iResPeriodo18        INTEGER;
    DEFINE dtResFechaCouta18    DATE;
    DEFINE dResSdoInicial18     DECIMAL(18,2);
    DEFINE dResMensualidad218   DECIMAL(18,2);
    DEFINE dResIntereses18      DECIMAL(18,2);
    DEFINE dResIvaIn2418        DECIMAL(18,2);
    DEFINE dResCapital18        DECIMAL(18,2);
    DEFINE dResSdoFinal18       DECIMAL(18,2);
    DEFINE sResDiasPeriodo18    SMALLINT;
    DEFINE dtResFechaAper18     DATE;
    DEFINE cResPlazo18          CHAR(3);
    DEFINE cResCodRet24         CHAR(6);
    DEFINE iResPeriodo24        INTEGER;
    DEFINE dtResFechaCouta24    DATE;
    DEFINE dResSdoInicial24     DECIMAL(18,2);
    DEFINE dResMensualidad224   DECIMAL(18,2);
    DEFINE dResIntereses24      DECIMAL(18,2);
    DEFINE dResIvaIn2424        DECIMAL(18,2);
    DEFINE dResCapital24        DECIMAL(18,2);
    DEFINE dResSdoFinal24       DECIMAL(18,2);
    DEFINE sResDiasPeriodo24    SMALLINT;
    DEFINE dtResFechaAper24     DATE;
    DEFINE cResPlazo24          CHAR(3);
    -- Variables adicionales
    DEFINE cSucursal            CHAR(4);
    DEFINE iNumPromocion        INTEGER;
    DEFINE iPlazo12             INTEGER;
    DEFINE iPlazo18             INTEGER;
    DEFINE iPlazo24             INTEGER;
    --DEFINE dtFechaSistema       DATE;
	DEFINE i_dia_cuota			smallint;
	DEFINE dt_fecha_corte_mas_reciente date;
    DEFINE cBegin               CHAR(1);
    DEFINE iContador            INTEGER;
	DEFINE X 					SMALLINT;
    -- Inicializacion de variables
    LET cNum_Cte             = '';
    LET cNum_Credito         = '';
    LET cNum_Producto        = '';
    LET vcNombre_Com         = '';
    LET dLinea_Credito       = 0.00;
    LET dPago_Minimo         = 0.00;
    LET dtFecha_Corte        = DATE(1);
    LET dtFecha_Pago         = DATE(1);
    LET dtFecha_Originacion  = DATE(1);
    LET dSaldo_Revolvente    = 0.00;
    LET dSaldo_Para_Plan     = 0.00;
    LET iPlazo_Sugerido      = 0;
    LET iTasa_Interes        = 0;
    LET cNum_Telefono_casa   = '';
    LET cCanal               = '';
    LET cCampania            = '';
    LET cCalle               = '';
    LET cNum_Casa            = '';
    LET cColonia             = '';
    LET cNum_Celular         = '';
    LET cMunicipio           = '';
    LET cEstado              = '';
    LET cCp                  = '';
    LET vcEmail              = '';
    LET cNum_Credito_Bitac   = '';
    LET vcAbono_TotalText    = '';
    LET dSaldo_Maesdos       = 0.00;
    LET dPlan_12_Aux         = 0.00;
    LET dPlan_18_Aux         = 0.00;
    LET dPlan_24_Aux         = 0.00;
    LET cSucursal            = '4901';
    LET iNumPromocion        = 11;
    LET iEstatusBitacora     = 0;
    --
    LET  cResCodRet12         ='';
    LET  iResPeriodo12        = 0;
    LET  dtResFechaCouta12    = DATE(1);
    LET  dResSdoInicial12     = 0.0;
    LET  dResMensualidad212   = 0.0;
    LET  dResIntereses12      = 0.0;
    LET  dResIvaIn12          = 0.0;
    LET  dResCapital12        = 0.0;
    LET  dResSdoFinal12       = 0.0;
    LET  sResDiasPeriodo12    = 0;
    LET  dtResFechaAper12     = DATE(1);
    LET  cResPlazo12          = '';
    --
    LET  cResCodRet18            = '';
    LET  iResPeriodo18           = 0;
    LET  dtResFechaCouta18       = DATE(1);
    LET  dResSdoInicial18        = 0.0 ;
    LET  dResMensualidad218      = 0.0 ;
    LET  dResIntereses18         = 0.0 ;
    LET  dResIvaIn2418           = 0.0 ;
    LET  dResCapital18           = 0.0 ;
    LET  dResSdoFinal18          = 0.0 ;
    LET  sResDiasPeriodo18       = 0 ;
    LET  dtResFechaAper18        = DATE(1);
    LET  cResPlazo18             = '';
    LET cResCodRet24             = '';
    LET iResPeriodo24            = 0;
    LET dtResFechaCouta24        = DATE(1);
    LET dResSdoInicial24         = 0.0 ;
    LET dResMensualidad224       = 0.0 ;
    LET dResIntereses24          = 0.0 ;
    LET dResIvaIn2424            = 0.0 ;
    LET dResCapital24            = 0.0 ;
    LET dResSdoFinal24           = 0.0 ;
    LET sResDiasPeriodo24        = 0;
    LET dSaldoVencido_Maesdos    = 0.0 ;
    LET dPago_minimo_pendiente   = 0.0 ;
    LET dtResFechaAper24         = DATE(1);
    LET cResPlazo24              = '';
    LET iPlazo12                 = 12;
    LET iPlazo18                 = 18;
    LET iPlazo24                 = 24;
    --LET dtFechaSistema           = DATE(1);
    LET dtFecha_Hoy              = DATE(1);
    LET dtFecha_Liquidacion      = DATE(1);
    -- Inicializacion de control de errores
    LET iSqlErr               = 0;
    LET iIsamErr              = 0;
    LET cErrorInfo            = '';
    LET cCodRet               = '';
    LET vcDirectorio          = '';
    LET vcNombreArchivo       = '';
    LET vcNombreArchivov      = '';	
    LET vcNombreArchivoFinal  = '';
    LET cFecha_Actual         = '19000101';
    LET csSQLAux              = '';
    LET mError                = '';
    LET iContador             = 0;
    ----------------------------------- 
    BEGIN 
        ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo

            LET cCodRet     = iSqlErr;
            LET mError      = iSqlErr || ' ' || iIsamErr || ' ' ||cErrorInfo;

            IF (cBegin = "S") THEN
                COMMIT WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;

            RETURN cCodRet, mError;

        END EXCEPTION;
        -- 
        ON EXCEPTION IN (-535)
            LET cBegin = "S";
            COMMIT WORK;
            BEGIN WORK;
        END EXCEPTION WITH RESUME;

        -- SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        -- SET DEBUG FILE TO '/informix/planes_recuperacion/trace.out';
        -- TRACE ON;
            LET cBegin = "N";
            LET cCodRet = '00000';
            LET mError = 'PROCESO EXITOSO';

        SELECT valor 
            INTO vcDirectorio
        FROM bdicred:"informix".sd_param 
        WHERE cod_param = '172' 
        AND empresa = '001';
            --
        IF vcDirectorio IS NULL THEN
            LET cCodRet='000001';
            LET mError = 'NO EXISTE INFORMACION DEL PATH EN TABLA';
        RETURN cCodRet, mError;
        END IF;
        
        SELECT valor 
            INTO vcNombreArchivo
        FROM bdicred:"informix".sd_param 
            WHERE cod_param = '173' 
            AND empresa = '001';
            --
        IF vcNombreArchivo IS NULL THEN
            LET cCodRet='000002';
            LET mError = 'NO EXISTE INFORMACION DEL NOMBRE DE ARCHIVO EN TABLA';
            RETURN cCodRet, mError;
        END IF;
        --
        SELECT fecha_hoy 
                INTO dtFecha_Hoy 
        FROM bdicred:"informix".sd_fechas
        WHERE empresa = '001';

        begin work;

        FOREACH WITH HOLD
            SELECT dia_cuota, num_producto  
            INTO i_dia_cuota, cNum_Producto
            FROM bdicred:"informix".sd_definicion 
            WHERE num_producto IN ('6001')-- aquiÂ­ solo agregar los nuevos productos que deben generar candidatos o se meten a una tabla de parametros de control

            IF day(dtFecha_Hoy) <= day(i_dia_cuota) THEN
                let dt_fecha_corte_mas_reciente =  MDY( month(dtFecha_Hoy - 1 UNITS month) ,day(i_dia_cuota), year(dtFecha_Hoy - 1 UNITS month) );
            elif day(dtFecha_Hoy) > day(i_dia_cuota) then
                let dt_fecha_corte_mas_reciente =  MDY( month(dtFecha_Hoy ) ,day(i_dia_cuota), year(dtFecha_Hoy) );
            end if;
            --
            FOREACH WITH HOLD
            -- SELECCION DE TODOS LOS CANDIDATOS AL CORTE MENSUAL
        SELECT  hist.numcte,
                hist.num_credito,
                hist.nombre_com,
                hist.linea_credito,
                hist.pago_minimo,
                hist.fecha_corte,
                hist.fecha_pago,
                hist.fecha_originacion,
                hist.tasa_interes,
                hist.num_celular,
                hist.num_telefono_casa,
                hist.canal,
                hist.campania, 
                hist.calle,
                hist.num_casa,
                hist.colonia,
                hist.municipio,
                hist.estado,
                hist.cp,
                hist.email

                INTO cNum_Cte, cNum_Credito,
                    vcNombre_Com, dLinea_Credito, dPago_Minimo, dtFecha_Corte, dtFecha_Pago, dtFecha_Originacion, 
                        iTasa_Interes, cNum_Celular, cNum_Telefono_casa,
                        cCanal, cCampania, cCalle, cNum_Casa, cColonia, cMunicipio, cEstado, cCp, vcEmail
                FROM 
                    bdicred:"informix".sd_plan_pausa_candidatos_mensual hist 
                    left join bdicred:informix.sd_plan_pausa_layout lay
                    on hist.num_credito = lay.num_credito 
                    AND lay.fecha_corte = dt_fecha_corte_mas_reciente
                WHERE --fecha_corte = dtFecha_consulta_mensual
                hist.fecha_corte = dt_fecha_corte_mas_reciente
                and hist.num_producto = cNum_Producto
                and lay.num_credito is null
                ---- termina select principal
                
                SELECT sdo_cap_insoluto, (monto_vencido + mto_venc_trasp), monto_financiado 
                    INTO dSaldo_Maesdos, dSaldoVencido_Maesdos, dPago_minimo_pendiente
                FROM bdicred:"informix".sd_maesdos
                WHERE num_credito = cNum_Credito;
                LET dSaldo_Revolvente = dSaldo_Maesdos;
                --
                IF dSaldoVencido_Maesdos IS NULL THEN 
                        LET dSaldoVencido_Maesdos = 0;
                END IF;

                IF dSaldo_Maesdos IS NULL THEN 
                        LET dSaldo_Maesdos = 0;
                END IF;
                --
                IF dSaldo_Maesdos < 4000 OR 
                dSaldoVencido_Maesdos > 0 THEN
                    CONTINUE FOREACH;
                END IF;
                --
                SELECT plazo 
                INTO iPlazo_Sugerido
                FROM bdicred:"informix".sd_plan_pausa_plazo_sugerido
                WHERE num_producto = cNum_Producto
                AND rango_superior > dSaldo_Maesdos
                AND rango_inferior <= dSaldo_Maesdos;
                
                IF iPlazo_Sugerido IS NULL then
                    LET cCodRet = '00003';
                    LET mError  = 'NO EXISTE INFORMACION DEL PLAZO PARA EL PLAN EN PAUSA';
                END IF;

                -- REGLA DE EVALUACION PAGO MINIMO
                IF dPago_minimo_pendiente <= 0 THEN
                    LET vcAbono_TotalText = 'PAGO MINIMO REALIZADO';
                ELSE 
                    LET vcAbono_TotalText = 'NO CUMPLE';
                END IF;
                -- SALDO PARA PLAN
                IF  dPago_Minimo = 0 THEN
                    LET dSaldo_Para_Plan = dSaldo_Maesdos;
                ELSE 
                    LET dSaldo_Para_Plan = dSaldo_Maesdos - dPago_minimo_pendiente;
                END IF;
                --    
                SELECT  num_credito, estatus, fecha_liquidacion
                    INTO cNum_Credito_Bitac, iEstatusBitacora, dtFecha_Liquidacion
                FROM bdicred:"informix".sd_plan_pausa_bitacora
                WHERE num_credito = cNum_Credito
                    AND ROWID = (
                        SELECT MAX(ROWID)
                        FROM bdicred:"informix".sd_plan_pausa_bitacora
                        WHERE num_credito = cNum_Credito);
                        
                    --1 EN PROCESO DE VALIDACION PARA CONTRATAR 
                    --2 RECHAZADO EN PROCESO ANTERIOR 
                    --3 POR CONTRATAR(EN SP COMPRA PROMO) 
                    --5 ACTIVO  --6 RECHAZADO BAJO SOLICITUD  
                    --7 LIQUIDADO

                LET X = 0;
                IF cNum_Credito_Bitac IS NOT NULL THEN
                    IF iEstatusBitacora NOT IN ('1','3','5','7')
                        OR (dtFecha_Liquidacion is not null AND 
                            ( iEstatusBitacora = '7' AND (dtFecha_Hoy - NVL(dtFecha_Liquidacion,DATE(1)) )> 365)
                            )
                    THEN
                        LET X = 1;
                    END IF;
                ELSE  --IS NULL, NO HAY HISTORIA DE ALGUN PLAN EN PAUSA
                    LET X = 1;
                END IF;
                
                IF X = 1 THEN
                    -- Obtener montos diferidos para plazos 12, 18 y 24 -- se cambia a sp_proyecta_prest_credisolsam para pruebas
                    EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(dSaldo_Para_Plan, iPlazo12::INTEGER, 0, '6900', cSucursal, 0, 0, cNum_Credito, null, 1, iNumPromocion::INTEGER, '1', iTasa_Interes)
                        INTO cResCodRet12, iResPeriodo12, dtResFechaCouta12, dResSdoInicial12, dResMensualidad212, dResIntereses12, 
                        dResIvaIn12, dResCapital12, dResSdoFinal12, sResDiasPeriodo12, dtResFechaAper12, cResPlazo12;
                        LET dPlan_12_Aux = dResMensualidad212;
                    --
                    EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(dSaldo_Para_Plan, iPlazo18::INTEGER, 0,'6900',cSucursal, 0, 0, cNum_Credito, null, 1, iNumPromocion::INTEGER, '1', iTasa_Interes) 
                        INTO cResCodRet18, iResPeriodo18, dtResFechaCouta18, dResSdoInicial18, dResMensualidad218, dResIntereses18,
                            dResIvaIn2418, dResCapital18, dResSdoFinal18, sResDiasPeriodo18, dtResFechaAper18, cResPlazo18;
                            LET dPlan_18_Aux = dResMensualidad218;
                    --
                    EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(dSaldo_Para_Plan, iPlazo24::INTEGER, 0, '6900', cSucursal, 0, 0, cNum_Credito, null, 1, iNumPromocion::INTEGER, '1', iTasa_Interes) 
                        INTO cResCodRet24, iResPeriodo24, dtResFechaCouta24, dResSdoInicial24, dResMensualidad224, dResIntereses24,
                            dResIvaIn2424, dResCapital24, dResSdoFinal24, sResDiasPeriodo24, dtResFechaAper24, cResPlazo24;
                            LET dPlan_24_Aux = dResMensualidad224;
                    
                    INSERT INTO bdicred:"informix".sd_plan_pausa_layout (
                        fecha_asig, numcte, num_credito, num_producto, nombre_com,
                        linea_credito, pago_minimo, fecha_corte, fecha_pago, fecha_originacion, pm_realizado,
                        saldo_revolvente, saldo_para_plan, plazo_sugerido, tasa_interes, plan_12_meses, plan_18_meses, plan_24_meses, num_celular,
                        num_telefono_casa, canal, campania, calle, num_casa, colonia, municipio, estado, cp, email
                        )
                    VALUES (
                        dtFecha_Hoy, cNum_Cte, cNum_Credito, cNum_Producto, vcNombre_Com,
                        dLinea_Credito, dPago_Minimo, dtFecha_Corte, dtFecha_Pago, dtFecha_Originacion, vcAbono_TotalText,
                        dSaldo_Revolvente, dSaldo_Para_Plan, iPlazo_Sugerido, iTasa_Interes, dPlan_12_Aux, dPlan_18_Aux, dPlan_24_Aux, cNum_Celular,
                        cNum_Telefono_casa, cCanal, cCampania, cCalle, cNum_Casa, cColonia, cMunicipio, cEstado, cCp, vcEmail
                        );
                    LET iContador = iContador + 1;

                    IF iContador >= 1000 THEN
                        COMMIT WORK;
                        BEGIN WORK;
                        LET iContador = 0;
                    END IF;

                END IF;
                --
            END FOREACH;
            -- fin del foreach
            IF iContador > 0 THEN
                COMMIT WORK;
                BEGIN WORK;
            END IF;

        END FOREACH;
        
            LET cFecha_Actual = LPAD(DAY(dtFecha_Hoy),2,0)||LPAD(MONTH(dtFecha_Hoy),2,0)||YEAR(dtFecha_Hoy);
            LET vcNombreArchivov = trim(vcNombreArchivo);
            LET vcNombreArchivoFinal = TRIM(vcDirectorio) || TRIM(vcNombreArchivo) || cFecha_Actual || '.txt';	
            --
            let csSql = 'echo "UNLOAD TO ' || vcNombreArchivoFinal || ' DELIMITER ' || '''|''' ||
            ' SELECT row_number() over(order by numcte), fecha_asig, numcte ,num_credito ,num_producto , trim(nombre_com) ,linea_credito, pago_minimo ,fecha_corte ,fecha_pago ,fecha_originacion ,pm_realizado ,saldo_revolvente , saldo_para_plan, plazo_sugerido ,tasa_interes ,plan_12_meses ,plan_18_meses ,plan_24_meses ,num_celular ,num_telefono_casa ,canal ,campania ,calle ,num_casa ,colonia ,municipio ,estado ,cp ,email FROM bdicred:informix.sd_plan_pausa_layout; TRUNCATE TABLE bdicred:informix.sd_plan_pausa_layout;" | dbaccess bdicred';
            --
            LET csSQLAux = csSql;
            SYSTEM csSQL;
            --
            IF (cBegin = "S") THEN
                COMMIT WORK;
                BEGIN WORK;
            ELSE
                COMMIT WORK;
            END IF;

            --RETURN PRINCIPAL    
        RETURN cCodRet, mError;
        
    END;
--
END PROCEDURE
;