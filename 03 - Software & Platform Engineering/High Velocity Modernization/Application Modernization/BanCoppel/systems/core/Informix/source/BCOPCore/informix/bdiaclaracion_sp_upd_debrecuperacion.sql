CREATE PROCEDURE "informix".sp_upd_debrecuperacion(e_folio_csuac CHAR(11)) 
--V. 2.0.3                                                        
RETURNING CHAR(6) AS s_CodRet, CHAR(100) AS s_Mensaje, SMALLINT AS s_Cc, MONEY AS s_AfectacionC, VARCHAR(3) AS s_CodleyendaC,
                                                       SMALLINT AS s_Ci, MONEY AS s_AfectacionI, VARCHAR(3) AS s_CodleyendaI,
                                                       SMALLINT AS s_Ca, MONEY AS s_AfectacionA, VARCHAR(3) AS s_CodleyendaA,
                                                       SMALLINT AS s_Cin, MONEY AS s_AfectacionIn, VARCHAR(3) AS s_CodleyendaIn;

    /* Variables Salida*/ 
    DEFINE s_CodRet             CHAR(6);  
    DEFINE s_Mensaje            CHAR(100);
    DEFINE s_Mensaje2           CHAR(30);
    DEFINE s_Cc                 SMALLINT;
    DEFINE s_Ci                 SMALLINT;
    DEFINE s_Ca                 SMALLINT;
    DEFINE s_AfectacionC        MONEY;
    DEFINE s_AfectacionI        MONEY;
    DEFINE s_AfectacionA        MONEY;
    DEFINE s_CodleyendaA        VARCHAR(3);
    DEFINE s_CodleyendaI        VARCHAR(3);
    DEFINE s_CodleyendaC        VARCHAR(3);
    
    --RQM 287
    DEFINE s_Cin                SMALLINT;
    DEFINE s_AfectacionIn       MONEY;
    DEFINE s_CodleyendaIn       VARCHAR(3);
    
     

    /* Variables Internas*/
    /* Variables tabla acl_recuperacion_saldos*/
    DEFINE i_abono_recuperado       MONEY;
    DEFINE i_comision_recuperada    MONEY;
    DEFINE i_iva_recuperada         MONEY;
    DEFINE i_abono_irrecuperable    SMALLINT;
    DEFINE i_cron_activo            SMALLINT;
    DEFINE i_f_recuperacion         DATE;
    DEFINE i_fechacaptura           DATE;
    DEFINE i_fc_recuperacion        DATE;     
    DEFINE i_fi_recuperacion        DATE;     
    DEFINE i_fa_recuperacion        DATE;  
    DEFINE i_fky_aclaracion         INTEGER;
    DEFINE i_total_abono            MONEY;
    DEFINE i_total_comision         MONEY;
    DEFINE i_total_iva              MONEY; 
    DEFINE i_exito_ca               SMALLINT;
    DEFINE i_exito_cc               SMALLINT;
    DEFINE i_exito_ci               SMALLINT;
    DEFINE i_pky_recuperacion       INTEGER;      
    
    --RQM 287-3
    DEFINE i_total_interes          MONEY;
    DEFINE i_interes_recuperado     MONEY;
    DEFINE i_interes_afectado       MONEY;

    DEFINE i_fin_recuperacion       DATE;
    DEFINE i_exito_cin              SMALLINT;
    DEFINE i_tipo_movimiento        CHAR(1);
    DEFINE i_importereclamado       MONEY; 
    DEFINE i_fky_regla_negocio      INTEGER;
    
    /* Variables asignaciones internas*/
    DEFINE i_val_diasnaturales      INTEGER; --> numero de dias naturales
    DEFINE i_val_empresa            VARCHAR(3); --> numero de empresa
    DEFINE i_val_tipoprod           INTEGER; --> asignacion al tipo producto
    DEFINE i_val_cuenta             VARCHAR(12); --> asignacion de cuenta
    DEFINE i_val_exito_ca           SMALLINT; --> asignacion abono exitoso
    DEFINE i_val_exito_cc           SMALLINT; --> asignacion comision exitoso
    DEFINE i_val_exito_ci           SMALLINT; --> asignacion iva exitoso
    
    DEFINE i_val_exito_cin          SMALLINT;
    
    DEFINE i_val_tmpC               MONEY; 
    DEFINE i_val_tmpA               MONEY; 
    DEFINE i_val_tmpI               MONEY;

    DEFINE i_val_tmpIn              MONEY;
    
    DEFINE i_val_recTrans           INTEGER;
    DEFINE ia_total_comision        MONEY; 
    DEFINE ia_comision_recuperada   MONEY;
    DEFINE ia_total_iva             MONEY;
    DEFINE ia_iva_recuperada        MONEY;
    DEFINE i_temporal2              INTEGER;

    -- MODIFICACION RBU: INTENTO DE CANCELACION
    DEFINE i_val_cta_cancelada      SMALLINT;

    /* Variables obtencion Saldo Debito*/
    DEFINE vcodret                  CHAR(5);
    DEFINE vsdodisp                 MONEY(16,2);
    DEFINE vstatuscta               CHAR(1);
    /* variables obtencion de sp cargo abono */
    DEFINE DCodret_a                CHAR(5); 
    DEFINE DTranret_c               CHAR(4);
    DEFINE DFechoy_c                DATE;
    DEFINE  DVsdodisp_c             MONEY(14,2);
    DEFINE  DVmontoret_c            MONEY(14,2);
    /* Variables de entrada SP afectacion comision debito*/
    DEFINE eEmpresa                CHAR(3);
    DEFINE eSucursal               CHAR(4);
    DEFINE vTranCom                CHAR(4);
    DEFINE vTranIva                CHAR(4);
    DEFINE vTranAbono              CHAR(4);  
    DEFINE eFolio                  CHAR(16);
    DEFINE eCuenta                 CHAR(20);
	DEFINE v_descripion            CHAR(200);
    DEFINE eCheque                 INTEGER;
    DEFINE eDivisa                 CHAR(2);
    DEFINE v_fecha_folio           CHAR(10);
    DEFINE v_contador              SMALLINT;
    DEFINE pFolioSuacSUC           CHAR(16);
    DEFINE CnumTarjeta             CHAR(20);
    
    DEFINE v_resol_abono_irrecuperable      INTEGER;
    DEFINE v_resol_importe_irrecuperable    INTEGER;
    DEFINE v_fky_estatus_aclaracion         INTEGER;
    DEFINE v_fky_estatus_corp_analisis      INTEGER;
    DEFINE V_fky_estatus_corp_general       INTEGER;
        
        --RQM 287-3
        -- Variables retorno bloqueo
    DEFINE cod_ret_bloq         CHAR(3); 
    DEFINE codeRet2             CHAR(5);
       
    DEFINE resultado_saldo_congelado  MONEY;
    DEFINE v_diferencia_fechas        INTEGER;

        -- TIPO DE MOVIMIENTO
    DEFINE pFolioSuc            CHAR(20);
    DEFINE pOrigenEvento        INTEGER;
    DEFINE resultado_origen     CHAR (1);
    DEFINE modo_entrada         VARCHAR(2);
    
        -- Manejo de exceptions
    DEFINE iSqlErr       		INTEGER;
    
    --SET DEBUG FILE TO "/resplogifx/repaclaraciones/RQM732-1/DEBSALDOS.out";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN
        
            ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                RETURN  iSqlErr,'',0,0,'',0,0,'',0,0,'',0,0,''; -- RETURNING
			END IF;
        END EXCEPTION;

		   ON EXCEPTION IN (-535)
			  --ROLLBACK WORK;
			  COMMIT WORK;
				--SET ISOLATION TO DIRTY READ;
			  --BEGIN WORK;
		   END EXCEPTION WITH RESUME;

		   ON EXCEPTION IN (-255)
			  --ROLLBACK WORK;
			   BEGIN WORK;
               COMMIT WORK;
				--SET ISOLATION TO DIRTY READ;
			  --BEGIN WORK;
		   END EXCEPTION WITH RESUME;
       --> Variables Salida
       LET s_CodRet   = '000';
       LET s_Mensaje  = 'Afectacion Exitosa'; 
       LET s_Cc = 0;
       LET s_Ci = 0;
       LET s_Ca = 0;
       LET s_AfectacionC = 0;
       LET s_AfectacionI = 0;
       LET s_AfectacionA = 0;
       LET s_CodleyendaA = 'NA';
       LET s_CodleyendaI = 'NA';
       LET s_CodleyendaC = 'NA';
       LET CnumTarjeta      = '';
       LET i_val_cuenta ='';

        --RQM 287
       LET s_Cin          = 0;
       LET s_AfectacionIn = 0;
       LET s_CodleyendaIn = 'NA';
       LET i_importereclamado = 0; 
       LET i_fky_regla_negocio = 0;

    
       
       -- Tipo de movimiento  V = 45     F = 180    Ã??Ã??    N = INDEFINIDO
       SELECT tipo_movimiento, importereclamado, fky_regla_negocio INTO i_tipo_movimiento, i_importereclamado, i_fky_regla_negocio FROM acl_aclaracion WHERE folio_csuac = e_folio_csuac;

       IF(i_tipo_movimiento == 'N') THEN 

            SELECT movimiento.folio_suc,producto.numero_tarjeta,evento.fky_origen_evento
            INTO  pFolioSuc,CnumTarjeta,pOrigenEvento
            FROM acl_aclaracion acl
            LEFT JOIN acl_producto producto ON producto.pky_producto = acl.fky_producto
            LEFT JOIN acl_tipo_evento evento ON evento.pky_tipo_evento = acl.fky_tipo_evento
            LEFT JOIN acl_movimiento movimiento ON movimiento.fky_aclaracion=acl.pky_aclaracion
            WHERE acl.folio_csuac=e_folio_csuac AND movimiento.fky_padre IS NULL;
                
            --CONSULTANDO TIPO DE MOVIMIENTO
            CALL sp_consulta_tipo_movimiento(pFolioSuc,CnumTarjeta,pOrigenEvento)RETURNING resultado_origen, modo_entrada;
            LET i_tipo_movimiento = resultado_origen;
            
            IF (i_tipo_movimiento == 'N') THEN -- EN CASO DE NO ENCONTRAR  UNA TIPO MOVIMIENTO
            
                LET i_tipo_movimiento  = 'V'; -- POR DEFAULT SE TOMARA COMO FOLIO NACIONAL
                UPDATE acl_aclaracion SET tipo_movimiento = i_tipo_movimiento WHERE folio_csuac=e_folio_csuac;
            END IF;
     END IF;
       

       
       IF (i_tipo_movimiento == 'V') THEN
            SELECT resp_estimada_cierre_nacional INTO i_val_diasnaturales FROM acl_rango_importe WHERE fky_id_regla = i_fky_regla_negocio and rango_menor <= i_importereclamado and rango_mayor >= i_importereclamado;
       ELIF (i_tipo_movimiento == 'F') THEN    
            SELECT resp_estimada_cierre_intl INTO i_val_diasnaturales FROM acl_rango_importe WHERE fky_id_regla = i_fky_regla_negocio and rango_menor <= i_importereclamado and rango_mayor >= i_importereclamado;
       END IF
       
       
       --> Variables Internas
       --LET i_val_diasnaturales = 45;
       LET i_val_empresa = '001';
       LET i_val_exito_cc = 0; 
       LET i_pky_recuperacion = (SELECT max (pky_recuperacion) FROM "informix".acl_recuperacion_saldos WHERE folio_csuac = e_folio_csuac);        
       LET eEmpresa ='001';
       LET vTranCom = '';
       LET eCheque =0;
       LET eDivisa= '01';
       LET v_contador = 0;

        --IMPORTES IRRECUPERABLES
       LET v_resol_abono_irrecuperable = (select pky_resolucion from acl_resolucion where nombre='abonoIrrecuperable');
       LET v_resol_importe_irrecuperable = (select pky_resolucion from acl_resolucion where nombre='cargoNoRealizado');

    /* Realizar la consulta a la tabla acl_recuperacion saldos para obtener la informacion de la recuperacion del folio*/
     SELECT fky_aclaracion, total_abono, abono_recuperado, total_comision, comision_recuperada, 
             total_iva,iva_recuperada, f_recuperacion, fc_recuperacion, fi_recuperacion, fa_recuperacion, 
                abono_irrecuperable, cron_activo, exito_ca, exito_cc, exito_ci, total_interes, interes_recuperado, fin_recuperacion, exito_cin
     
     INTO i_fky_aclaracion, i_total_abono, i_abono_recuperado, i_total_comision, i_comision_recuperada,
         i_total_iva, i_iva_recuperada, i_f_recuperacion, i_fc_recuperacion, i_fi_recuperacion,
         i_fa_recuperacion, i_abono_irrecuperable, i_cron_activo, i_exito_ca, i_exito_cc, i_exito_ci,
         i_total_interes, i_interes_recuperado, i_fin_recuperacion, i_exito_cin
     FROM "informix".acl_recuperacion_saldos 
     WHERE folio_csuac = e_folio_csuac AND pky_recuperacion = i_pky_recuperacion;


     SELECT fechacaptura 
     INTO i_fechacaptura
    FROM "informix".acl_aclaracion where folio_csuac=e_folio_csuac;

    LET i_val_tmpC = i_comision_recuperada;
    LET i_val_tmpI = i_iva_recuperada;
    LET i_val_tmpIn = i_interes_recuperado;
    
    LET s_Cc = i_exito_cc;
    LET s_Ci = i_exito_ci;
    LET s_Ca = i_exito_ca;
    LET s_Cin = i_exito_cin;

    SELECT sucursal INTO eSucursal FROM bdinteg:si_ejecut WHERE ejecutivo in(SELECT num_empleado FROM "informix".acl_aclaracion WHERE folio_csuac = e_folio_csuac);
	
	IF eSucursal = '' OR eSucursal IS NULL THEN
		SELECT sucursal INTO eSucursal FROM bdinteg:si_ejecut WHERE ejecutivo in(Select au.num_empleado from bdiaclaracion:acl_aclaracion ac inner join bdiaclaracion:acl_usuario au on ac.fky_usuario_analista = au.pky_usuario where ac.folio_csuac = e_folio_csuac);
	END IF;
	
	--SELECT num_empleado FROM "informix".acl_aclaracion WHERE folio_csuac = e_folio_csuac);

    /*Realiza la VALIDACION PARA SALDOS IRRECUPERABLES, en caso de que sea cero, indica que el folio aun esta en periodo de recuperacion.*/
--BEGIN WORK;
    IF (i_abono_irrecuperable == 0) THEN --> INICIA Numero 1  
    
----call DBMS_OUTPUT.PUT_LINE('------estoy en abono irrecuperable: ' || e_folio_csuac );
            /*Realiza la validacion de la columna f_recuperacion, en caso de que sea mayor a 45, no entra en el proceso de recuperacion y actualiza la tabla acl_recuperacion_saldos.*/
            --IF ((SELECT DATE(today) - DATE(i_fechacaptura)  FROM (SELECT LIMIT 1 1 FROM systables)) > 45)  THEN --> INICIA Numero 2   
            LET v_diferencia_fechas =  DATE(today) - DATE(i_fechacaptura);
            IF ((v_diferencia_fechas) >= i_val_diasnaturales)  THEN --> INICIA Numero 2   
                                   --=========== IF TRANSACCIONES ============================
                    IF i_abono_recuperado = 0 AND i_iva_recuperada = 0 AND i_comision_recuperada = 0 AND i_interes_recuperado = 0 THEN
                        LET i_val_recTrans = 25;
                    ELSE
                        LET i_val_recTrans = 24;
                    END IF;
                    --================== END TRANSACCIONES ===========================================
                    --   VALIDANDO SI EL REGISTRO EXISTE EN CASO DE QUE NO, SE INSERTA NUEVO Y UNICO REGISTRO COMO ABONO IRRECUPERABLE
                    --   DA DE BAJA EL CRON_ACTIVO=0 Y ABONO IRRECUPERABLE=1 Y LAS FECHAS ACTUALES PARA CADA CAMPO DE RECUPERACION
                    IF NOT EXISTS (SELECT 1 FROM ACL_RECUPERACION_SALDOS 
                                    WHERE fky_aclaracion= i_fky_aclaracion
                                        AND folio_csuac=e_folio_csuac 
                                        AND total_abono=i_total_abono
                                        AND abono_recuperado =i_abono_recuperado 
                                        AND abono_afectado='0' 
                                        AND total_comision = i_total_comision 
                                        AND comision_recuperada=i_comision_recuperada
                                        AND comision_afectada='0' 
                                        AND total_iva= i_total_iva 
                                        AND iva_recuperada =i_iva_recuperada 
                                        AND iva_afectada ='0' 

                                        AND total_interes = i_total_interes
                                        AND interes_recuperado = i_interes_recuperado
                                        AND interes_afectado ='0'

                                        AND f_recuperacion=i_f_recuperacion 
                                        AND fc_recuperacion = CURRENT 
                                        AND fi_recuperacion = CURRENT 
                                        AND fa_recuperacion = CURRENT

                                        AND fin_recuperacion = CURRENT

                                        AND abono_irrecuperable='1' 
                                        AND cron_activo='0' 
                                        AND exito_ca=i_exito_ca 
                                        AND exito_cc=i_exito_cc 
                                        AND exito_ci=i_exito_ci
                                        AND exito_cin=i_exito_cin

                                        AND fky_estatus_corporativo =i_val_recTrans) THEN   
                    
                    CALL "informix".sp_Ins_Recuperacion_Saldos(i_fky_aclaracion, 
                                                                e_folio_csuac,
                                                                i_total_abono, 
                                                                i_abono_recuperado, 
                                                                0,
                                                                i_total_comision, 
                                                                i_comision_recuperada, 
                                                                0,
                                                                i_total_iva, 
                                                                i_iva_recuperada, 
                                                                0,
                                                                i_total_interes,
                                                                i_interes_recuperado,
                                                                0,
                                                                i_f_recuperacion, 
                                                                CURRENT, 
                                                                CURRENT, 
                                                                CURRENT,
                                                                CURRENT, 
                                                                1, 
                                                                0, 
                                                                i_exito_ca, 
                                                                i_exito_cc, 
                                                                i_exito_ci,
                                                                i_exito_cin,
                                                                i_val_recTrans)
                                                RETURNING s_CodRet, s_Mensaje2;
                    UPDATE "informix".acl_aclaracion
                    SET fky_estatus_corp_general = 6,fky_estatus_flujo_causa=i_val_recTrans
                    WHERE folio_csuac = e_folio_csuac AND pky_aclaracion = i_fky_aclaracion;
                    --ACTUALIZA EL CRON ACTIVO PARA LA EJECUCIÃ??Ã??N DESDE EL CRON.
                    UPDATE "informix".acl_recuperacion_saldos SET cron_activo = 0 WHERE folio_csuac = e_folio_csuac;
                    -- CONSULTA NUEVAMENTE POR ACTUALIZACION EN ESTATUS
                            SELECT fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general 
                            INTO v_fky_estatus_aclaracion,v_fky_estatus_corp_analisis,v_fky_estatus_corp_general
                            FROM acl_aclaracion where folio_csuac=e_folio_csuac and pky_aclaracion=i_fky_aclaracion;

                        -- INSERT BITACORA 
                        

                                    -- VALIDACION DE ABONO NO RECUPERADO
                                    IF (i_exito_ca = 0 AND i_total_abono > '0') THEN --INSERT BITACORA POR MONTO NO RECUPERADO
                                        INSERT INTO "informix".acl_entrada_bitacora
                                                        VALUES("informix".ENTRADA_BITACORA_SEQ.NEXTVAL, --pky_entrada_bitacora
                                                       'El importe abonado temporalmente no ha podido ser recuperado.',-- descripcion   
                                                       CURRENT,                      -- fechaHOra
                                                       e_folio_csuac,                -- folio_csuac   
                                                       v_resol_abono_irrecuperable,  -- accion/acl_resolucion 
                                                       i_fky_aclaracion,             -- pky_aclaracion
                                                       NULL,                         -- fky_area
                                                       v_fky_estatus_aclaracion,     -- fky_estatus_aclaracion
                                                       v_fky_estatus_corp_analisis,  -- fky_estatus_corp_analisis
                                                       v_fky_estatus_corp_general,   -- fky_estatus_corp_general
                                                       '0');                         -- Usuario   
                                                       
                                     END IF;                  
                                     
                                    IF (i_exito_cc = 0 AND i_total_comision > '0') THEN  --INSERT BITACORA POR MONTO NO RECUPERADO
                                        INSERT INTO "informix".acl_entrada_bitacora
                                                        VALUES("informix".ENTRADA_BITACORA_SEQ.NEXTVAL, --pky_entrada_bitacora
                                                       'El cargo de la comision por aclaracion no procedente no fue realizado.',-- descripcion   
                                                       CURRENT,                      -- fechaHOra
                                                       e_folio_csuac,                -- folio_csuac   
                                                       v_resol_importe_irrecuperable,  -- accion/acl_resolucion 
                                                       i_fky_aclaracion,             -- pky_aclaracion
                                                       NULL,                         -- fky_area
                                                       v_fky_estatus_aclaracion,     -- fky_estatus_aclaracion
                                                       v_fky_estatus_corp_analisis,  -- fky_estatus_corp_analisis
                                                       v_fky_estatus_corp_general,   -- fky_estatus_corp_general
                                                       '0');                         -- Usuario   
                                     END IF;   

                                     IF (i_exito_ci = 0 AND i_total_iva > '0') THEN -- INSERT BITACORA POR MONTO NO RECUPERADO
                                        INSERT INTO "informix".acl_entrada_bitacora
                                                        VALUES("informix".ENTRADA_BITACORA_SEQ.NEXTVAL, --pky_entrada_bitacora
                                                       'El cargo del IVA de la comision por aclaracion no procedente no fue realizado.',-- descripcion   
                                                       CURRENT,                      -- fechaHOra
                                                       e_folio_csuac,                -- folio_csuac   
                                                       v_resol_importe_irrecuperable,  -- accion/acl_resolucion 
                                                       i_fky_aclaracion,             -- pky_aclaracion
                                                       NULL,                         -- fky_area
                                                       v_fky_estatus_aclaracion,     -- fky_estatus_aclaracion
                                                       v_fky_estatus_corp_analisis,  -- fky_estatus_corp_analisis
                                                       v_fky_estatus_corp_general,   -- fky_estatus_corp_general
                                                       '0');                         -- Usuario   
                                     END IF;   
                                     
                                     IF (i_exito_cin = 0 AND i_total_interes > '0') THEN
                                        INSERT INTO "informix".acl_entrada_bitacora
                                                        VALUES("informix".ENTRADA_BITACORA_SEQ.NEXTVAL, --pky_entrada_bitacora
                                                       'El cargo del interes de la aclaracion no procedente no fue realizado.',-- descripcion   
                                                       CURRENT,                      -- fechaHOra
                                                       e_folio_csuac,                -- folio_csuac   
                                                       v_resol_importe_irrecuperable,  -- accion/acl_resolucion 
                                                       i_fky_aclaracion,             -- pky_aclaracion
                                                       NULL,                         -- fky_area
                                                       v_fky_estatus_aclaracion,     -- fky_estatus_aclaracion
                                                       v_fky_estatus_corp_analisis,  -- fky_estatus_corp_analisis
                                                       v_fky_estatus_corp_general,   -- fky_estatus_corp_general
                                                       '0');                         -- Usuario
                                     END IF;
                                     
                            
                            /* Realiza la cancelacion de la cuenta*/
                            CALL "informix".sp_aplicar_cancelacion_por_recuperacion_credDeb(e_folio_csuac,'0' ) RETURNING cod_ret_bloq,s_Mensaje;
                    
                    
                    LET s_CodRet='E-01';
                    LET s_Mensaje='El registro es irrecuperable, por vencimiento de fecha';

END IF;
--COMMIT WORK;
                    RETURN s_CodRet,s_Mensaje, s_Cc, s_AfectacionC, s_CodleyendaC, s_Ci, s_AfectacionI, s_CodleyendaI, s_Ca, s_AfectacionA, s_CodleyendaA, s_Cin, s_AfectacionIn, s_CodleyendaIn; 

              ELSE /*Relaiza la validacion de la columna f_recuperacion, en caso de que sea menor a 45, continua con la validacion de filtros.*/
----call DBMS_OUTPUT.PUT_LINE('------ NO estoy en abono irrecuperable: ' || e_folio_csuac );
                SELECT tp.tipo_producto,p.numero_cuenta, numero_tarjeta 
                INTO i_val_tipoprod, i_val_cuenta, CnumTarjeta
                FROM acl_aclaracion acl
                INNER JOIN acl_producto p ON p.pky_producto = acl.fky_producto
                INNER JOIN acl_tipo_producto tp ON tp.pky_tipo_producto=p.fky_tipo_producto
                WHERE folio_csuac=e_folio_csuac;
    
                SELECT transacc_com, transacc_iva INTO vTranCom, vTranIva
                FROM bdicheq:sc_comisiones WHERE empresa = eEmpresa AND comision = '0343';

                SELECT substr((current HOUR TO SECOND),1,2)||substr((CURRENT HOUR TO SECOND),4,2)|| LPAD(v_contador,2,0)
                INTO v_fecha_folio FROM bdicheq:sc_fechas;

                LET eFolio = trim(v_fecha_folio)||lpad(e_folio_csuac,10,0);                             

--COMISION e IVA
--------------------------------------------------------------------------------
                            SELECT sdo_cong
                            INTO resultado_saldo_congelado
                            FROM bdicheq:"informix".sc_maechq
                            WHERE cuenta = i_val_cuenta;

                            --Desbloqueo de cuenta
                            IF (resultado_saldo_congelado > 0) THEN
                                -- Desbloqueo por monto
                                CALL bdicheq:"informix".bloqueo_cta(eEmpresa,i_val_cuenta, resultado_saldo_congelado, '00', 0, today, '0', '4469', '07', 'A', '09', 'P' ) RETURNING cod_ret_bloq,codeRet2;
                            ELIF (resultado_saldo_congelado == 0) THEN
                                -- Desbloqueo por 0                                                                                                 
                                CALL bdicheq:"informix".bloqueo_cta(eEmpresa,i_val_cuenta,0,'00',0,today,'0','4469','07','A','09','P' ) RETURNING cod_ret_bloq,codeRet2;
                            END IF

                           CALL bdicheq:cons_saldo (i_val_cuenta) RETURNING  vcodret,vsdodisp,vstatuscta;
----call DBMS_OUTPUT.PUT_LINE('------validando saldo en comision e iva para el folio : ' || e_folio_csuac || i_val_cuenta || vcodret ||vsdodisp || vstatuscta );
                           --LET vcodret ='000';   LET vsdodisp = 31;  ----- PRUEBAS

                            IF (vcodret == '000') AND (vsdodisp > 0 ) AND (vstatuscta == '1') THEN --> INICIA Numero 19
----call DBMS_OUTPUT.PUT_LINE('------pasando primer validacion en comision e iva : ' || e_folio_csuac);
                                       IF (i_exito_cc == 0) THEN --> INICIA Numero 20
                                     --**********************************************************************
----call DBMS_OUTPUT.PUT_LINE('------pasando 2DA validacion en comision e iva : ' || e_folio_csuac);
                                        LET i_val_tmpC = (i_total_comision - i_comision_recuperada);
                                        LET i_val_tmpI = (i_total_iva - i_iva_recuperada);

                                        IF (i_val_tmpC + i_val_tmpI) > vsdodisp THEN --- A 1/3
                                        LET i_val_recTrans = 22;

                                            IF i_val_tmpC > i_val_tmpI THEN  --- B 1/3
                                                                                                                                 LET s_AfectacionC = vsdodisp / (1.16);
                                                                 LET s_AfectacionI = vsdodisp - (s_AfectacionC);
                                            ELSE  --- B 1/3
                                                                                                                                 LET s_AfectacionC = vsdodisp / (1.16);
                                                                 LET s_AfectacionI = vsdodisp - (s_AfectacionC);
                                               END if;  --- B 1/3
                                            
											LET v_descripion = '';
											LET v_descripion = 'Recuperacion_saldos: '||eSucursal||' '||e_folio_csuac||' '||user||' '||vTranCom||' '||eFolio||' '||i_val_cuenta||' '||eCheque||' '||s_AfectacionC||' '||eDivisa;
											 
											INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)  VALUES('000', 0, v_descripion, 'cargo_ref', CURRENT,CURRENT);
                                             
											 CALL bdicheq:cargo_ref(eEmpresa, eSucursal, user, vTranCom, "0000", eFolio, i_val_cuenta, eCheque, s_AfectacionC, eDivisa, "","","")
                                             RETURNING s_CodRet, DTranret_c, DFechoy_c, DVsdodisp_c, DVmontoret_c;
											
                                            
											LET v_descripion = '';
											LET v_descripion = 'Recuperacion_saldos:'||' '||e_folio_csuac||' '||DTranret_c||' '||DVsdodisp_c||' '||DVmontoret_c;
											 
											--IF s_CodRet <> '000' THEN
											INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)  VALUES(s_CodRet, 0, v_descripion, 'cargo_ref', DFechoy_c,CURRENT);
											--END IF;
											
											IF (s_CodRet is not null) THEN
                                                        COMMIT WORK;
                                            END IF;
                                             --CALL bdicheq:cargon_ref(eEmpresa, eSucursal, user, vTranCom, "0000", eFolio, i_val_cuenta, eCheque, s_AfectacionC, eDivisa, "","","")
                                             --RETURNING s_CodRet, s_Mensaje2;    
--call DBMS_OUTPUT.PUT_LINE('------realiza cargo de abono e iva  1: ' || e_folio_csuac); 

                                             --LET s_CodRet = '000';   
--call DBMS_OUTPUT.PUT_LINE('------codifo de retorno exitoso en cargo e iva : ' || e_folio_csuac);
                                                    IF s_CodRet == '000' THEN -- C  1/3
                                               
											LET v_descripion = '';
											LET v_descripion = 'Recuperacion_saldos: '||eSucursal||' '||e_folio_csuac||' '||user||' '||vTranIva||' '||eFolio||' '||i_val_cuenta||' '||eCheque||' '||s_AfectacionI||' '||eDivisa;
											 
											INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)  VALUES('000', 0, v_descripion, 'cargo_ref', CURRENT,CURRENT);
                                             											   
                                             CALL bdicheq:cargo_ref(eEmpresa, eSucursal, user, vTranIva, "0000", eFolio, i_val_cuenta, eCheque, s_AfectacionI, eDivisa, "","","")
                                             RETURNING DCodret_a, DTranret_c, DFechoy_c, DVsdodisp_c, DVmontoret_c;
											 
											LET v_descripion = '';
											LET v_descripion = 'Recuperacion_saldos:'||' '||e_folio_csuac||' '||DTranret_c||' '||DVsdodisp_c||' '||DVmontoret_c;
											 
											-- IF s_CodRet <> '000' THEN
											 INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)  VALUES(s_CodRet, 0, v_descripion, 'cargo_ref', DFechoy_c,CURRENT);
                                            -- END IF;   
											IF (DCodret_a is not null) THEN
                                                        COMMIT WORK;
                                            END IF;											
                                                        --CALL bdicheq:cargon_ref(eEmpresa, eSucursal, user, vTranIva, "0000", eFolio, i_val_cuenta, eCheque, s_AfectacionI, eDivisa, "","","")
                                                        --RETURNING s_CodRet, s_Mensaje2;                                    
                                                                --BEGIN WORK;
                                                                 IF s_CodRet == '000' THEN  -- D  1/3

                                                                    LET i_val_tmpC = (i_comision_recuperada + s_AfectacionC);
                                                                    LET i_val_tmpI = (i_iva_recuperada + s_AfectacionI);
                                                                 
                                                                    /* CALL "informix".sp_Ins_Recuperacion_Saldos(i_fky_aclaracion, e_folio_csuac,
                                                                                                                             i_total_abono, i_abono_recuperado, 0,
                                                                                                                             i_total_comision, i_val_tmpC, s_AfectacionC,
                                                                                                                             i_total_iva, i_val_tmpI, s_AfectacionI,
                                                                                                                             i_f_recuperacion, CURRENT, CURRENT, i_fa_recuperacion, 
                                                                                                                             i_abono_irrecuperable, i_cron_activo, 
                                                                                                                             i_exito_ca, i_exito_cc, i_exito_ci,i_val_recTrans)
                                                                                                                             RETURNING s_CodRet, s_Mensaje2; */

                                                                    CALL "informix".sp_Ins_Recuperacion_Saldos(i_fky_aclaracion, 
                                                                                                                                    e_folio_csuac,
                                                                                                                                    i_total_abono, 
                                                                                                                                    i_abono_recuperado, 
                                                                                                                                    0,
                                                                                                                                    i_total_comision, 
                                                                                                                                    i_val_tmpC, 
                                                                                                                                    s_AfectacionC,
                                                                                                                                    i_total_iva, 
                                                                                                                                    i_val_tmpI, 
                                                                                                                                    s_AfectacionI,
                                                                                                                                    i_total_interes,
                                                                                                                                    i_interes_recuperado,
                                                                                                                                    0,
                                                                                                                                    i_f_recuperacion, 
                                                                                                                                    CURRENT, 
                                                                                                                                    CURRENT, 
                                                                                                                                    i_fa_recuperacion,
                                                                                                                                    i_fin_recuperacion, 
                                                                                                                                    i_abono_irrecuperable, 
                                                                                                                                    i_cron_activo, 
                                                                                                                                    i_exito_ca, 
                                                                                                                                    i_exito_cc, 
                                                                                                                                    i_exito_ci,
                                                                                                                                    i_exito_cin,
                                                                                                                                    i_val_recTrans)
                                                                                                                    RETURNING s_CodRet, s_Mensaje2;
--call DBMS_OUTPUT.PUT_LINE('------actualizacion de recuperacion de saldos CARGO E IVA exitosa : ' || e_folio_csuac);
                                                                    ------------> actualizacion acl_movimiento                                                          
                                                                   UPDATE "informix".acl_movimiento
                                                                    SET monto_recuperacion = (i_comision_recuperada + s_AfectacionC)
                                                                    WHERE cargo=1
                                                                    AND exitoso = 0
                                                                    AND fky_padre IS NOT NULL
                                                                    AND duplicado = 0
                                                                    AND folio_suc IS NULL    
                                                                    AND folio_csuac=e_folio_csuac;
--call DBMS_OUTPUT.PUT_LINE('------actualizacion de MOVIMIENTOS CARGO E IVA de saldos exitosa : ' || e_folio_csuac);
                                                                    ------------> actualizacion acl_movimiento 

                                                                    LET s_CodleyendaC = 'CPC'; --> Mensaje de salida de comision afectada total 
                                                                    LET s_CodleyendaI = 'CPI'; --> Mensaje de salida de comision afectada total 
                                                                        

                                                                 ELSE -- D  1/3
--call DBMS_OUTPUT.PUT_LINE('------ERROR EN AFERCTACION DE COMISION E IVA 1 : ' || e_folio_csuac);
                                                                     RETURN s_CodRet,'No se realizo la afectacion de comision/iva', 0, 0, 'NA', 0, 0, 'NA', 0, 0, 'NA',0,0,'NA'; 

                                                                 END IF; -- D 1/3
                                                                 --COMMIT WORK;

                                                    ELSE  -- C  1/3
--call DBMS_OUTPUT.PUT_LINE('------ERROR EN AFERCTACION DE COMISION E IVA 2 : ' || e_folio_csuac);
                                                        RETURN s_CodRet,'No se realizo la afectacion de comision/iva', 0, 0, 'NA', 0, 0, 'NA', 0, 0, 'NA',0,0,'NA'; 

                                                    END IF; -- C  1/3
                                                                                     
                                        ELSE --- A 1/3
                                            LET i_val_recTrans = 22;
                                            LET i_val_tmpC = (i_total_comision - i_comision_recuperada);
                                            LET i_val_tmpI = (i_total_iva - i_iva_recuperada);
                                            LET s_AfectacionC = i_val_tmpC;
                                            LET s_AfectacionI = i_val_tmpI;                                             
											
											LET v_descripion = '';
											LET v_descripion = 'Recuperacion_saldos: '||eSucursal||' '||e_folio_csuac||' '||user||' '||vTranCom||' '||eFolio||' '||i_val_cuenta||' '||eCheque||' '||s_AfectacionC||' '||eDivisa;
											 
											INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)  VALUES('000', 0, v_descripion, 'cargo_ref', CURRENT,CURRENT);
                                             	
                                             CALL bdicheq:cargo_ref(eEmpresa, eSucursal, user, vTranCom, "0000", eFolio, i_val_cuenta, eCheque, s_AfectacionC, eDivisa, "","","")
                                             RETURNING s_CodRet, DTranret_c, DFechoy_c, DVsdodisp_c, DVmontoret_c;
											
											LET v_descripion = '';
											LET v_descripion = 'Recuperacion_saldos:'||' '||e_folio_csuac||' '||DTranret_c||' '||DVsdodisp_c||' '||DVmontoret_c;
											 
											--IF s_CodRet <> '000' THEN									
											INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)  VALUES(s_CodRet, 0, v_descripion, 'cargo_ref', DFechoy_c,CURRENT);
										--	END IF;
										
											IF (s_CodRet is not null) THEN
                                                        COMMIT WORK;
                                            END IF;
                                                --CALL bdicheq:cargon_ref(eEmpresa, eSucursal, user, vTranCom, "0000", eFolio, i_val_cuenta, eCheque, s_AfectacionC, eDivisa, "","","")
                                               --RETURNING s_CodRet, s_Mensaje2;    

                                              -- LET DCodret_a = '000';
                                                    IF s_CodRet == '000' THEN -- C  1/3
                                                        LET i_exito_cc = 1;  
														
											LET v_descripion = '';
											LET v_descripion = 'Recuperacion_saldos: '||eSucursal||' '||e_folio_csuac||' '||user||' '||vTranIva||' '||eFolio||' '||i_val_cuenta||' '||eCheque||' '||s_AfectacionI||' '||eDivisa;
											 INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)  VALUES('000', 0, v_descripion, 'cargo_ref', CURRENT,CURRENT);
                                             
											 
                                             CALL bdicheq:cargo_ref(eEmpresa, eSucursal, user, vTranIva, "0000", eFolio, i_val_cuenta, eCheque, s_AfectacionI, eDivisa, "","","")
                                             RETURNING s_CodRet, DTranret_c, DFechoy_c, DVsdodisp_c, DVmontoret_c;
											
											 LET v_descripion = '';
											LET v_descripion = 'Recuperacion_saldos:'||' '||e_folio_csuac||' '||DTranret_c||' '||DVsdodisp_c||' '||DVmontoret_c;
											 
											 
											--IF s_CodRet <> '000' THEN
											INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)  VALUES(s_CodRet, 0, v_descripion, 'cargo_ref', DFechoy_c,CURRENT);
                                            --END IF;   
											 IF (s_CodRet is not null) THEN
                                                        COMMIT WORK;
                                            END IF;
                                                        --CALL bdicheq:cargon_ref(eEmpresa, eSucursal, user, vTranIva, "0000", eFolio, i_val_cuenta, eCheque, s_AfectacionI, eDivisa, "","","")
                                                        --RETURNING s_CodRet, s_Mensaje2;                                      

                                                                 IF s_CodRet == '000' THEN  -- D  1/3
                                                                    LET i_exito_ci = 1;
                                                                    
                                                                    LET i_val_tmpC = (i_comision_recuperada + i_val_tmpC);
                                                                    LET i_val_tmpI = (i_iva_recuperada + i_val_tmpI);

                                                                    /*CALL "informix".sp_Ins_Recuperacion_Saldos(i_fky_aclaracion, e_folio_csuac,
                                                                                                                             i_total_abono, i_abono_recuperado, 0,
                                                                                                                             i_total_comision, i_val_tmpC, s_AfectacionC,
                                                                                                                             i_total_iva, i_val_tmpI, s_AfectacionI,
                                                                                                                             i_f_recuperacion, CURRENT, CURRENT, i_fa_recuperacion, 
                                                                                                                             i_abono_irrecuperable, i_cron_activo, 
                                                                                                                             i_exito_ca, i_exito_cc, i_exito_ci,i_val_recTrans)
                                                                                                                             RETURNING s_CodRet, s_Mensaje2;*/
                                                                                                                             
                                                                    CALL "informix".sp_Ins_Recuperacion_Saldos(i_fky_aclaracion, 
                                                                                                                e_folio_csuac,
                                                                                                                i_total_abono, 
                                                                                                                i_abono_recuperado, 
                                                                                                                0,
                                                                                                                i_total_comision, 
                                                                                                                i_val_tmpC, 
                                                                                                                s_AfectacionC,
                                                                                                                i_total_iva, 
                                                                                                                i_val_tmpI, 
                                                                                                                s_AfectacionI,
                                                                                                                i_total_interes,
                                                                                                                i_interes_recuperado,
                                                                                                                0,
                                                                                                                i_f_recuperacion, 
                                                                                                                CURRENT, 
                                                                                                                CURRENT, 
                                                                                                                i_fa_recuperacion,
                                                                                                                i_fin_recuperacion, 
                                                                                                                i_abono_irrecuperable, 
                                                                                                                i_cron_activo, 
                                                                                                                i_exito_ca, 
                                                                                                                i_exito_cc, 
                                                                                                                i_exito_ci,
                                                                                                                i_exito_cin,
                                                                                                                i_val_recTrans)
                                                                                                       RETURNING s_CodRet, s_Mensaje2;
                                                                                                                    
                                                                    -- ACTUALIZAR MOVIMIENTO COMISION
                                                                    UPDATE acl_movimiento SET exitoso = 1,fecha_afectacion  = CURRENT, monto_recuperacion = (i_comision_recuperada + s_AfectacionC) 
                                                                    WHERE cargo=1
                                                                    AND exitoso = 0
                                                                    AND fky_padre IS NOT NULL
                                                                    AND duplicado = 0
                                                                    AND folio_suc IS NULL    
                                                                    AND folio_csuac=e_folio_csuac;
                                                                    -- FIN MOVIMIENTO ACTUALIZADO
                                                                    LET s_CodleyendaC = 'CTC'; --> Mensaje de salida de comision afectada total 
                                                                    LET s_CodleyendaI = 'CTI'; --> Mensaje de salida de comision afectada total 

                                                                 ELSE -- D  1/3
--call DBMS_OUTPUT.PUT_LINE('------ERROR EN AFERCTACION DE COMISION E IVA 3 : ' || e_folio_csuac);
                                                                     RETURN s_CodRet,'No se realizo la afectacion de iva', 0, 0, 'NA', 0, 0, 'NA', 0, 0, 'NA', 0, 0, 'NA';
                                                                 END IF; -- D 1/3

                                                    ELSE  -- C  1/3
--call DBMS_OUTPUT.PUT_LINE('------ERROR EN AFERCTACION DE COMISION E IVA 4 : ' || e_folio_csuac);
                                                        RETURN s_CodRet,'No se realizo la afectacion de iva', 0, 0, 'NA', 0, 0, 'NA', 0, 0, 'NA', 0, 0, 'NA'; 
                                                    END IF; -- C  1/3

                                        END IF; --- A 1/3

                                    LET i_fc_recuperacion = CURRENT;
                                    LET i_fi_recuperacion = CURRENT;
                                    LET s_Ci = 1;
                                    LET s_Cc = 1;

                                    --*****************************************************************
                                       END IF; --> FIN Numero 20
                                       
                                       -- fecha y exito                                   

                             ELSE --> INTERMEDIO Numero 19

                             END IF; --> FIN Numero 19

                                ------------------------- ABONO------------------------------------------------------------
--call DBMS_OUTPUT.PUT_LINE('------LLEGANDO A CARGOS PARA ABONO : ' || e_folio_csuac);
                                CALL bdicheq:cons_saldo (i_val_cuenta) RETURNING  vcodret,vsdodisp,vstatuscta;
--call DBMS_OUTPUT.PUT_LINE('------CONSULTANDO SALDOS PARA CARGO DE ABONO : ' || e_folio_csuac || i_val_cuenta || vcodret || vsdodisp || vstatuscta );                                
                                LET i_pky_recuperacion = (SELECT max (pky_recuperacion) FROM "informix".acl_recuperacion_saldos WHERE folio_csuac = e_folio_csuac);

                                SELECT  exito_ca, exito_cc, exito_ci, exito_cin
                                INTO i_exito_ca, i_exito_ci,i_exito_cc, i_exito_cin 
                                FROM "informix".acl_recuperacion_saldos 
                                WHERE folio_csuac = e_folio_csuac AND pky_recuperacion = i_pky_recuperacion;

                                    LET i_iva_recuperada = i_val_tmpI;
                                    LET i_comision_recuperada = i_val_tmpC;
                                    


                                SELECT substr((current HOUR TO SECOND),1,2)||substr((CURRENT HOUR TO SECOND),4,2)|| LPAD(v_contador,2,0)
                                INTO v_fecha_folio  FROM bdicheq:sc_fechas;

                                LET pFolioSuacSUC = trim(v_fecha_folio)||lpad(e_folio_csuac,10,0); --Genera el FolioSuc
                                --==== SELECCIONA LA TRANSACCION DE ABONO mediante tipo_movimiento
                                SELECT trans_no_procede 
                                INTO vTranAbono
                                FROM acl_tipo_movimiento 
                                WHERE pky_tipo_movimiento=(SELECT fky_tipo_movimiento FROM acl_movimiento WHERE
                                folio_csuac = e_folio_csuac
                                AND cargo=0 and exitoso=1
                                AND folio_suc is not null 
                                AND duplicado=0
                                AND fky_aclaracion IS NOT NULL
                                AND fky_padre IS NULL);
  
                    
                                IF (vcodret == '000') AND (vsdodisp > 0) AND (vstatuscta == '1') THEN --> INICIA Numero 29                                         
                                       --Interes
                                        IF (i_exito_cin == 0) THEN 
                                        
                                            CALL bdicheq:cons_saldo (i_val_cuenta) RETURNING  vcodret,vsdodisp,vstatuscta;
                                            
                                            LET i_val_tmpIn = (i_total_interes - i_interes_recuperado);
                                        
                                            IF (i_val_tmpIn > vsdodisp) THEN 
                                            
                                                LET i_val_tmpIn = vsdodisp;
                                                LET s_AfectacionIn = i_val_tmpIn; --> Saldo de salida de interes afectada
                                                
                                                LET i_val_tmpIn = (i_interes_recuperado + i_val_tmpIn);                                             
                                                    
											LET v_descripion = '';
											LET v_descripion = 'Recuperacion_saldos: '||eSucursal||' '||e_folio_csuac||' '||user||' '||vTranAbono||' '||pFolioSuacSUC||' '||i_val_cuenta||' '||s_AfectacionIn||' '||CnumTarjeta;
											 
											INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)  VALUES('000', 0, v_descripion, 'cargo_ref', CURRENT,CURRENT);
                                             	
                                                CALL bdicheq:cargo_ref(eEmpresa, '9250', user, vTranAbono, '0000', pFolioSuacSUC, i_val_cuenta, 0, s_AfectacionIn, '01', e_folio_csuac, CnumTarjeta, user)
                                                RETURNING DCodret_a, DTranret_c, DFechoy_c, DVsdodisp_c, DVmontoret_c;
						
											LET v_descripion = '';
											LET v_descripion = 'Recuperacion_saldos:'||' '||e_folio_csuac||' '||DTranret_c||' '||DVsdodisp_c||' '||DVmontoret_c;
                                               -- IF DCodret_a <> '000' THEN
												INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)  VALUES(DCodret_a, 0, v_descripion, 'cargo_ref', DFechoy_c,CURRENT);
                                               -- END IF;
											   	IF (DCodret_a is not null) THEN
                                                        COMMIT WORK;
                                                END IF;
												IF (DCodret_a=='000') THEN 
                                                    LET s_Cin = 1;
                                                    
                                                    IF(i_val_tmpIn == i_total_interes ) THEN
                                                        CALL "informix".sp_Ins_Recuperacion_Saldos(i_fky_aclaracion, 
                                                                                            e_folio_csuac,
                                                                                            i_total_abono, 
                                                                                            i_abono_recuperado, 
                                                                                            0,
                                                                                            i_total_comision, 
                                                                                            i_comision_recuperada, 
                                                                                            0,
                                                                                            i_total_iva, 
                                                                                            i_iva_recuperada, 
                                                                                            0,
                                                                                            i_total_interes,
                                                                                            i_val_tmpIn,
                                                                                            s_AfectacionIn,
                                                                                            i_f_recuperacion, 
                                                                                            i_fc_recuperacion, 
                                                                                            i_fi_recuperacion, 
                                                                                            i_fa_recuperacion,
                                                                                            CURRENT, 
                                                                                            i_abono_irrecuperable, 
                                                                                            i_cron_activo, 
                                                                                            i_exito_ca, 
                                                                                            i_exito_cc, 
                                                                                            i_exito_ci,
                                                                                            s_Cin,
                                                                                            22)
                                                                            RETURNING s_CodRet, s_Mensaje2;

                                                        LET s_CodleyendaIn = 'CTA'; --> Mensaje de salida de interes afectada total
                                                        -- ACTUALIZA MOVIMIENTO 
                                                        update "informix".acl_movimiento set exitoso = 1,fecha_afectacion  = CURRENT, monto_recuperacion = (i_interes_recuperado +  s_AfectacionIn)    
                                                        WHERE cargo=1
                                                            AND exitoso = 0
                                                            AND fky_padre IS NOT NULL
                                                            AND duplicado = 1
                                                            AND folio_suc IS NULL    
                                                            AND folio_csuac=e_folio_csuac;
                                                        -- FINALIZA ACTUALIZA MOVIMIENTO
                                                        --ACTUALIZA ACLARACION 
                                                        UPDATE "informix".acl_aclaracion SET fky_estatus_flujo_causa = 22 WHERE folio_csuac = e_folio_csuac AND pky_aclaracion = i_fky_aclaracion;
                                                    ELSE
                                                    
                                                        CALL "informix".sp_Ins_Recuperacion_Saldos(i_fky_aclaracion, 
                                                                                            e_folio_csuac,
                                                                                            i_total_abono, 
                                                                                            i_abono_recuperado, 
                                                                                            0,
                                                                                            i_total_comision, 
                                                                                            i_comision_recuperada, 
                                                                                            0,
                                                                                            i_total_iva, 
                                                                                            i_iva_recuperada, 
                                                                                            0,
                                                                                            i_total_interes,
                                                                                            i_val_tmpIn,
                                                                                            s_AfectacionIn,
                                                                                            i_f_recuperacion, 
                                                                                            i_fc_recuperacion, 
                                                                                            i_fi_recuperacion, 
                                                                                            i_fa_recuperacion,
                                                                                            CURRENT, 
                                                                                            i_abono_irrecuperable, 
                                                                                            i_cron_activo, 
                                                                                            i_exito_ca, 
                                                                                            i_exito_cc, 
                                                                                            i_exito_ci,
                                                                                            i_exito_cin,
                                                                                            22)
                                                                            RETURNING s_CodRet, s_Mensaje2;
                                                         LET s_CodleyendaIn = 'CPA'; --> Mensaje de salida de interes afectada parcial
                                                        
                                                        -- ACTUALIZA MOVIMIENTO                 
                                                            update acl_movimiento set monto_recuperacion = (i_interes_recuperado +  s_AfectacionIn) 
                                                            WHERE cargo=1
                                                            AND exitoso = 0
                                                            AND fky_padre IS NOT NULL
                                                            AND duplicado = 1
                                                            AND folio_suc IS NULL    
                                                            AND folio_csuac=e_folio_csuac;
                                                            -- FINALIZA ACTUALIZA MOVIMIENTO
                                                            
                                                             --ACTUALIZA ACLARACION
                                                            UPDATE "informix".acl_aclaracion SET fky_estatus_flujo_causa = 22 WHERE folio_csuac = e_folio_csuac AND pky_aclaracion = i_fky_aclaracion;
                                                        -- FINALIZA ACTUALIZACION DE ACLARACION
                                                    END IF;
                                                END IF;  -- TERMINA VALIDACION SP CARGO ABONO
                                                
                                            ELSE
                                                LET s_AfectacionIn = i_val_tmpIn;
                                                LET s_Cin = 1;
                                                LET i_val_tmpIn = (i_interes_recuperado + i_val_tmpIn);
												
												LET v_descripion = '';
												LET v_descripion = 'Recuperacion_saldos: '||eSucursal||' '||e_folio_csuac||' '||user||' '||vTranAbono||' '||pFolioSuacSUC||' '||i_val_cuenta||' '||s_AfectacionIn||' '||CnumTarjeta;
											 
												INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)  VALUES('000', 0, v_descripion, 'cargo_ref', CURRENT,CURRENT);
                                             	
                                                                                                
                                                CALL bdicheq:cargo_ref(eEmpresa, '9250', user, vTranAbono, '0000', pFolioSuacSUC, i_val_cuenta, 0, s_AfectacionIn, '01', e_folio_csuac, CnumTarjeta, user)
                                                RETURNING DCodret_a, DTranret_c, DFechoy_c, DVsdodisp_c, DVmontoret_c;
												
												LET v_descripion = '';
												LET v_descripion = 'Recuperacion_saldos: '||e_folio_csuac||' '||DTranret_c||' '||DVsdodisp_c||' '||DVmontoret_c;
												
												--IF DCodret_a <> '000' THEN
												INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)  VALUES(DCodret_a, 0, v_descripion, 'cargo_ref', DFechoy_c,CURRENT);
                                                --END IF;
												IF (DCodret_a is not null) THEN
                                                        COMMIT WORK;
                                                END IF;
												
												--LET DCodret_a ='000';  ----- PRUEBAS

                                                IF(DCodret_a == '000') THEN -- INICIA VALIDACION SP CARGO 
                                                    LET s_Cin = 1;
                                                        IF(i_val_tmpIn == i_total_interes) THEN
                                                            
                                                            CALL "informix".sp_Ins_Recuperacion_Saldos(i_fky_aclaracion, 
                                                                                                e_folio_csuac,
                                                                                                i_total_abono, 
                                                                                                i_abono_recuperado, 
                                                                                                0,
                                                                                                i_total_comision, 
                                                                                                i_comision_recuperada, 
                                                                                                0,
                                                                                                i_total_iva, 
                                                                                                i_iva_recuperada, 
                                                                                                0,
                                                                                                i_total_interes,
                                                                                                i_val_tmpIn,
                                                                                                s_AfectacionIn,
                                                                                                i_f_recuperacion, 
                                                                                                i_fc_recuperacion, 
                                                                                                i_fi_recuperacion, 
                                                                                                i_fa_recuperacion,
                                                                                                CURRENT, 
                                                                                                i_abono_irrecuperable, 
                                                                                                i_cron_activo, 
                                                                                                i_exito_ca, 
                                                                                                i_exito_cc, 
                                                                                                i_exito_ci,
                                                                                                s_Cin,
                                                                                                22)
                                                                                RETURNING s_CodRet, s_Mensaje2;
                                                                                
                                                            LET s_CodleyendaIn = 'CTA'; --> Mensaje de salida de interes afectada total
                                                        
                                                            -- ACTUALIZA MOVIMIENTO
                                                            update acl_movimiento set exitoso = 1,fecha_afectacion  = CURRENT, monto_recuperacion = (i_interes_recuperado + s_AfectacionIn)  
                                                            WHERE cargo=1
                                                            AND exitoso = 0
                                                            AND fky_padre IS NOT NULL
                                                            AND duplicado = 1
                                                            AND folio_suc IS NULL    
                                                            AND folio_csuac=e_folio_csuac;
                                                            -- FINALIZA ACTUALIZA MOVIMIENTO
                                                            
                                                            --ACTUALIZA ACLARACION
                                                            UPDATE "informix".acl_aclaracion SET fky_estatus_flujo_causa = 22 WHERE folio_csuac = e_folio_csuac AND pky_aclaracion = i_fky_aclaracion;
                                                            -- FINALIZA ACTUALIZACION DE ACLARACION
                                                        ELSE
                                                        
                                                            CALL "informix".sp_Ins_Recuperacion_Saldos(i_fky_aclaracion, 
                                                                                                e_folio_csuac,
                                                                                                i_total_abono, 
                                                                                                i_abono_recuperado, 
                                                                                                0,
                                                                                                i_total_comision, 
                                                                                                i_comision_recuperada, 
                                                                                                0,
                                                                                                i_total_iva, 
                                                                                                i_iva_recuperada, 
                                                                                                0,
                                                                                                i_total_interes,
                                                                                                i_val_tmpIn,
                                                                                                s_AfectacionIn,
                                                                                                i_f_recuperacion, 
                                                                                                i_fc_recuperacion, 
                                                                                                i_fi_recuperacion, 
                                                                                                i_fa_recuperacion,
                                                                                                CURRENT, 
                                                                                                i_abono_irrecuperable, 
                                                                                                i_cron_activo, 
                                                                                                i_exito_ca, 
                                                                                                i_exito_cc, 
                                                                                                i_exito_ci,
                                                                                                i_exito_cin,
                                                                                                22)
                                                                                RETURNING s_CodRet, s_Mensaje2;
                                                                                
                                                            LET s_CodleyendaA = 'CPA'; --> Mensaje de salida de interes afectada parcial                
                                                            
                                                            -- ACTUALIZA MOVIMIENTO                 
                                                            update acl_movimiento set monto_recuperacion = (i_interes_recuperado + s_AfectacionIn)   
                                                            WHERE cargo=1
                                                            AND exitoso = 0
                                                            AND fky_padre IS NOT NULL
                                                            AND duplicado = 1
                                                            AND folio_suc IS NULL    
                                                            AND folio_csuac=e_folio_csuac;
                                                            -- FINALIZA ACTUALIZA MOVIMIENTO
                                                            
                                                            --ACTUALIZA ACLARACION
                                                            UPDATE "informix".acl_aclaracion SET fky_estatus_flujo_causa = 22 WHERE folio_csuac = e_folio_csuac AND pky_aclaracion = i_fky_aclaracion;
                                                            -- FINALIZA ACTUALIZACION DE ACLARACION                                                         
                                                        END IF;
                                                END IF; --TERMINA VALIDACION SP CARGO ABONO                                         
                                            
                                            END IF;
                                            
                                        END IF;
                                        
                                        LET i_interes_recuperado = i_val_tmpIn;
                                        
                                        LET i_pky_recuperacion = (SELECT max (pky_recuperacion) FROM "informix".acl_recuperacion_saldos WHERE folio_csuac = e_folio_csuac);

                                        SELECT  exito_ca, exito_cc, exito_ci, exito_cin
                                        INTO i_exito_ca, i_exito_ci,i_exito_cc, i_exito_cin 
                                        FROM "informix".acl_recuperacion_saldos 
                                        WHERE folio_csuac = e_folio_csuac AND pky_recuperacion = i_pky_recuperacion;
                                        
                                        --Recuperacion del abono 
                                             -- --call DBMS_OUTPUT.PUT_LINE('------PASE LA VALIDACION DE SALDO Y CUENTA EN ABONO : ' || e_folio_csuac || );               
                                       IF (i_exito_ca == 0 and i_exito_cin == 1) THEN --> INICIA Numero 30
                                     --**************************************************************************************
                                            LET i_val_tmpA = (i_total_abono - i_abono_recuperado);
                                            

                                            IF (i_val_tmpA > vsdodisp) THEN --> INICIA Numero 31
                                            -- ---------------------------------------------------------------------
                                                LET i_val_tmpA = vsdodisp;
                                                LET s_AfectacionA = i_val_tmpA; --> Saldo de salida de comision afectada
                                                
                                                LET i_val_tmpA = (i_abono_recuperado + i_val_tmpA);
												
												LET v_descripion = '';
												LET v_descripion = 'Recuperacion_saldos: '||eSucursal||' '||e_folio_csuac||' '||user||' '||vTranAbono||' '||pFolioSuacSUC||' '||i_val_cuenta||' '||s_AfectacionA||' '||CnumTarjeta;
											 
												INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)  VALUES('000', 0, v_descripion, 'cargo_ref', CURRENT,CURRENT);
                                             	                                                
                                                CALL bdicheq:cargo_ref(eEmpresa, '9250', user, vTranAbono, '0000', pFolioSuacSUC, i_val_cuenta, 0, s_AfectacionA, '01', e_folio_csuac, CnumTarjeta, user)
                                                RETURNING DCodret_a, DTranret_c, DFechoy_c, DVsdodisp_c, DVmontoret_c;
												
												LET v_descripion = '';
												LET v_descripion = 'Recuperacion_saldos: '||e_folio_csuac||' '||DTranret_c||' '||DVsdodisp_c||' '||DVmontoret_c;
												
												--IF DCodret_a <> '000' THEN
												INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)  VALUES(DCodret_a, 0, v_descripion, 'cargo_ref', DFechoy_c,CURRENT);
                                               -- END IF;
											    IF (DCodret_a is not null) THEN
                                                        COMMIT WORK;
                                                END IF;
												--    LET DCodret_a ='000'; ----- PRUEBAS
                                                IF (DCodret_a=='000') THEN 
                                                LET s_Ca = 1;
                                                IF(i_val_tmpA == i_total_abono) THEN --> INICIA Numero 32 
--21
                                                    /*CALL "informix".sp_Ins_Recuperacion_Saldos(
                                                                                            i_fky_aclaracion, e_folio_csuac,
                                                                                            i_total_abono, i_val_tmpA, s_AfectacionA,
                                                                                            i_total_comision,i_comision_recuperada, 0,
                                                                                            i_total_iva, i_iva_recuperada, 0,
                                                                                            i_f_recuperacion, i_fc_recuperacion, i_fi_recuperacion, CURRENT, 
                                                                                            i_abono_irrecuperable, i_cron_activo,   
                                                                                            s_Ca,  i_exito_cc,i_exito_ci,22)RETURNING s_CodRet, s_Mensaje2;*/
                                                                                            
                                                    CALL "informix".sp_Ins_Recuperacion_Saldos(i_fky_aclaracion, 
                                                                                                e_folio_csuac,
                                                                                                i_total_abono, 
                                                                                                i_val_tmpA, 
                                                                                                s_AfectacionA,
                                                                                                i_total_comision, 
                                                                                                i_comision_recuperada, 
                                                                                                0,
                                                                                                i_total_iva, 
                                                                                                i_iva_recuperada, 
                                                                                                0,
                                                                                                i_total_interes,
                                                                                                i_interes_recuperado,
                                                                                                0,
                                                                                                i_f_recuperacion, 
                                                                                                i_fc_recuperacion, 
                                                                                                i_fi_recuperacion, 
                                                                                                CURRENT,
                                                                                                i_fin_recuperacion, 
                                                                                                i_abono_irrecuperable, 
                                                                                                i_cron_activo, 
                                                                                                s_Ca, 
                                                                                                i_exito_cc, 
                                                                                                i_exito_ci,
                                                                                                i_exito_cin,
                                                                                                22)
                                                                                RETURNING s_CodRet, s_Mensaje2;

                                                    LET s_CodleyendaA = 'CTA'; --> Mensaje de salida de comision afectada total
                                                    -- ACTUALIZA MOVIMIENTO                 
                                                    update "informix".acl_movimiento set exitoso = 1,fecha_afectacion  = CURRENT, monto_recuperacion = (i_abono_recuperado +  s_AfectacionA)   
                                                    where cargo=1 
                                                    and exitoso = 0 
                                                    and fky_padre is null 
                                                    and duplicado = 1 
                                                    and folio_csuac=e_folio_csuac;
                                                    -- FINALIZA ACTUALIZA MOVIMIENTO
                                                    --ACTUALIZA ACLARACION 
                                                    UPDATE "informix".acl_aclaracion SET fky_estatus_flujo_causa = 22 WHERE folio_csuac = e_folio_csuac AND pky_aclaracion = i_fky_aclaracion;
                                                ELSE --> INTERMEDIO Numero 32  
--22
                                                    /*CALL "informix".sp_Ins_Recuperacion_Saldos(
                                                                                            i_fky_aclaracion, e_folio_csuac,
                                                                                            i_total_abono, i_val_tmpA, s_AfectacionA,
                                                                                            --i_total_comision,i_comision_recuperada, s_AfectacionC, 
                                                                                            i_total_comision,i_comision_recuperada, 0, 
                                                                                            --i_total_iva, i_iva_recuperada, s_AfectacionI,
                                                                                            i_total_iva, i_iva_recuperada, 0,
                                                                                            i_f_recuperacion, i_fc_recuperacion, i_fi_recuperacion, CURRENT, 
                                                                                            i_abono_irrecuperable, i_cron_activo,   
                                                                                            i_exito_ca, i_exito_cc, i_exito_ci,22)RETURNING s_CodRet, s_Mensaje2;*/
                                                                                            
                                                    CALL "informix".sp_Ins_Recuperacion_Saldos(i_fky_aclaracion, 
                                                                                                e_folio_csuac,
                                                                                                i_total_abono, 
                                                                                                i_val_tmpA, 
                                                                                                s_AfectacionA,
                                                                                                i_total_comision, 
                                                                                                i_comision_recuperada, 
                                                                                                0,
                                                                                                i_total_iva, 
                                                                                                i_iva_recuperada, 
                                                                                                0,
                                                                                                i_total_interes,
                                                                                                i_interes_recuperado,
                                                                                                0,
                                                                                                i_f_recuperacion, 
                                                                                                i_fc_recuperacion, 
                                                                                                i_fi_recuperacion, 
                                                                                                CURRENT,
                                                                                                i_fin_recuperacion, 
                                                                                                i_abono_irrecuperable, 
                                                                                                i_cron_activo, 
                                                                                                i_exito_ca, 
                                                                                                i_exito_cc, 
                                                                                                i_exito_ci,
                                                                                                i_exito_cin,
                                                                                                22)
                                                                                RETURNING s_CodRet, s_Mensaje2;

                                                    LET s_CodleyendaA = 'CPA'; --> Mensaje de salida de comision afectada parcial

                                                    -- ACTUALIZA MOVIMIENTO                 
                                                    update acl_movimiento set monto_recuperacion = (i_abono_recuperado +  s_AfectacionA)   
                                                    where cargo=1 
                                                    and exitoso = 0 
                                                    and fky_padre is null 
                                                    and duplicado = 1 
                                                    and folio_csuac=e_folio_csuac;
                                                    -- FINALIZA ACTUALIZA MOVIMIENTO

                                                    --ACTUALIZA ACLARACION
                                                    UPDATE "informix".acl_aclaracion SET fky_estatus_flujo_causa = 22 WHERE folio_csuac = e_folio_csuac AND pky_aclaracion = i_fky_aclaracion;
                                                    -- FINALIZA ACTUALIZACION DE ACLARACION
                                                END IF; --> FIN Numero 32   
                                             END IF -- TERMINA VALIDACION SP CARGO ABONO   
                                            --=================================================================
                                            ELSE --> INTERMEDIO Numero 31
                                            --=================================================================
                                                LET s_AfectacionA = i_val_tmpA;
                                                LET s_Ca = 1;
                                                LET i_val_tmpA = (i_abono_recuperado + i_val_tmpA);

                                                LET v_descripion = '';
												LET v_descripion = 'Recuperacion_saldos: '||eSucursal||' '||e_folio_csuac||' '||user||' '||vTranAbono||' '||pFolioSuacSUC||' '||i_val_cuenta||' '||s_AfectacionA||' '||CnumTarjeta;
											 
												INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)  VALUES('000', 0, v_descripion, 'cargo_ref', CURRENT,CURRENT);
                                             	  
												
                                                CALL bdicheq:cargo_ref(eEmpresa, '9250', user, vTranAbono, '0000', pFolioSuacSUC, i_val_cuenta, 0, s_AfectacionA, '01', e_folio_csuac, CnumTarjeta, user)
                                                RETURNING DCodret_a, DTranret_c, DFechoy_c, DVsdodisp_c, DVmontoret_c;
												
												LET v_descripion = '';
												LET v_descripion = 'Recuperacion_saldos: '||e_folio_csuac||' '||DTranret_c||' '||DVsdodisp_c||' '||DVmontoret_c;
                                                --LET DCodret_a ='000';  ----- PRUEBAS
												--IF DCodret_a <> '000' THEN
												INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)  VALUES(DCodret_a, 0, v_descripion, 'cargo_ref', DFechoy_c,CURRENT);
												--END IF;
												IF (DCodret_a is not null) THEN
                                                        COMMIT WORK;
                                                END IF;
/* SP CARGO ABONO*/              IF(DCodret_a == '000') THEN -- INICIA VALIDACION SP CARGO 
                                                LET s_Ca = 1;
                                                IF(i_val_tmpA == i_total_abono) THEN --> INICIA Numero 33
--23
                                                    /*CALL "informix".sp_Ins_Recuperacion_Saldos(
                                                                                            i_fky_aclaracion, e_folio_csuac,
                                                                                            i_total_abono, i_val_tmpA, s_AfectacionA,
                                                                                            --i_total_comision,i_comision_recuperada, s_AfectacionC,
                                                                                           -- i_total_iva, i_iva_recuperada, s_AfectacionI,
                                                                                            i_total_comision,i_comision_recuperada, 0,
                                                                                            i_total_iva, i_iva_recuperada, 0,
                                                                                            i_f_recuperacion, i_fc_recuperacion, i_fi_recuperacion, CURRENT, 
                                                                                            i_abono_irrecuperable, i_cron_activo,   
                                                                                             s_Ca,  i_exito_cc,i_exito_ci,22)RETURNING s_CodRet, s_Mensaje2;*/
                                                    
                                                    CALL "informix".sp_Ins_Recuperacion_Saldos(i_fky_aclaracion, 
                                                                                                e_folio_csuac,
                                                                                                i_total_abono, 
                                                                                                i_val_tmpA, 
                                                                                                s_AfectacionA,
                                                                                                i_total_comision, 
                                                                                                i_comision_recuperada, 
                                                                                                0,
                                                                                                i_total_iva, 
                                                                                                i_iva_recuperada, 
                                                                                                0,
                                                                                                i_total_interes,
                                                                                                i_interes_recuperado,
                                                                                                0,
                                                                                                i_f_recuperacion, 
                                                                                                i_fc_recuperacion, 
                                                                                                i_fi_recuperacion, 
                                                                                                CURRENT,
                                                                                                i_fin_recuperacion, 
                                                                                                i_abono_irrecuperable, 
                                                                                                i_cron_activo, 
                                                                                                s_Ca, 
                                                                                                i_exito_cc, 
                                                                                                i_exito_ci,
                                                                                                i_exito_cin,
                                                                                                22)
                                                                                RETURNING s_CodRet, s_Mensaje2;

                                                    LET s_CodleyendaA = 'CTA'; --> Mensaje de salida de comision afectada total
                                                        
                                                    -- ACTUALIZA MOVIMIENTO                 
                                                    update acl_movimiento set exitoso = 1,fecha_afectacion  = CURRENT, monto_recuperacion = (i_abono_recuperado +  s_AfectacionA)   
                                                    where cargo=1 
                                                    and exitoso = 0 
                                                    and fky_padre is null 
                                                    and duplicado = 1 
                                                    and folio_csuac=e_folio_csuac;
                                                    -- FINALIZA ACTUALIZA MOVIMIENTO

                                                    --ACTUALIZA ACLARACION
                                                    UPDATE "informix".acl_aclaracion SET fky_estatus_flujo_causa = 22 WHERE folio_csuac = e_folio_csuac AND pky_aclaracion = i_fky_aclaracion;
                                                    -- FINALIZA ACTUALIZACION DE ACLARACION
                                                ELSE --> INTERMEDIO Numero 33   
--24
                                                    /*CALL "informix".sp_Ins_Recuperacion_Saldos(
                                                                                            i_fky_aclaracion, e_folio_csuac,
                                                                                            i_total_abono, i_val_tmpA, s_AfectacionA,
                                                                                            --i_total_comision,i_comision_recuperada, s_AfectacionC,
                                                                                            i_total_comision,i_comision_recuperada, 0,
                                                                                            --i_total_iva, i_iva_recuperada, s_AfectacionI,
                                                                                            i_total_iva, i_iva_recuperada, 0,
                                                                                            i_f_recuperacion, i_fc_recuperacion, i_fi_recuperacion, CURRENT, 
                                                                                            i_abono_irrecuperable, i_cron_activo,   
                                                                                           i_exito_ca, i_exito_cc, i_exito_ci,22)RETURNING s_CodRet, s_Mensaje2;*/

                                                    CALL "informix".sp_Ins_Recuperacion_Saldos(i_fky_aclaracion, 
                                                                                                e_folio_csuac,
                                                                                                i_total_abono, 
                                                                                                i_val_tmpA, 
                                                                                                s_AfectacionA,
                                                                                                i_total_comision, 
                                                                                                i_comision_recuperada, 
                                                                                                0,
                                                                                                i_total_iva, 
                                                                                                i_iva_recuperada, 
                                                                                                0,
                                                                                                i_total_interes,
                                                                                                i_interes_recuperado,
                                                                                                0,
                                                                                                i_f_recuperacion, 
                                                                                                i_fc_recuperacion, 
                                                                                                i_fi_recuperacion, 
                                                                                                CURRENT,
                                                                                                i_fin_recuperacion, 
                                                                                                i_abono_irrecuperable, 
                                                                                                i_cron_activo, 
                                                                                                i_exito_ca, 
                                                                                                i_exito_cc, 
                                                                                                i_exito_ci,
                                                                                                i_exito_cin,
                                                                                                22)
                                                                                RETURNING s_CodRet, s_Mensaje2;                                    
                                                                                         
                                                   LET s_CodleyendaA = 'CPA'; --> Mensaje de salida de comision afectada parcial

                                                    -- ACTUALIZA MOVIMIENTO                 
                                                    update acl_movimiento set monto_recuperacion = (i_abono_recuperado +  s_AfectacionA)   
                                                    where cargo=1 
                                                    and exitoso = 0 
                                                    and fky_padre is null 
                                                    and duplicado = 1 
                                                    and folio_csuac=e_folio_csuac;
                                                    -- FINALIZA ACTUALIZA MOVIMIENTO

                                                    --ACTUALIZA ACLARACION
                                                    UPDATE "informix".acl_aclaracion SET fky_estatus_flujo_causa = 22 WHERE folio_csuac = e_folio_csuac AND pky_aclaracion = i_fky_aclaracion;
                                                    -- FINALIZA ACTUALIZACION DE ACLARACION
                                                END IF; --> FIN Numero 33
                                                END IF --TERMINA VALIDACION SP CARGO ABONO
                                            --=================================================================
                                            END IF; --> FIN Numero 31
                                    --********************************************************************************************************************
                                                
                                       END IF; --> FIN Numero 30                                                                    

                             ELSE --> INTERMEDIO Numero 29

                             END IF; --> FIN Numero 29
 
            END IF; --> FIN Numero 2    
                            
    END IF; --> FIN Numero 1    

    LET i_pky_recuperacion = (SELECT max (pky_recuperacion) FROM "informix".acl_recuperacion_saldos WHERE folio_csuac = e_folio_csuac);

    SELECT  exito_ca, exito_cc, exito_ci, exito_cin
    INTO i_val_exito_ca, i_val_exito_ci,i_val_exito_cc, i_val_exito_cin 
    FROM "informix".acl_recuperacion_saldos 
    WHERE folio_csuac = e_folio_csuac AND pky_recuperacion = i_pky_recuperacion;

    
    
    IF (i_val_exito_ca == 1) AND (i_val_exito_ci == 1) AND (i_val_exito_cc  ==1) AND (i_val_exito_cin  ==1)   THEN --> INICIA Numero 34
        UPDATE "informix".acl_recuperacion_saldos 
        SET  cron_activo= 0,fky_estatus_corporativo = 23   
        WHERE folio_csuac = e_folio_csuac AND fky_aclaracion = i_fky_aclaracion;  

        UPDATE "informix".acl_aclaracion -- Actualizar estatus de aclaracion una vez recuperado todos los saldos
        SET fky_estatus_corp_general = 6,  fky_estatus_flujo_causa = 23
        WHERE folio_csuac = e_folio_csuac AND pky_aclaracion = i_fky_aclaracion;


        SELECT sdo_cong
        INTO resultado_saldo_congelado
        FROM bdicheq:"informix".sc_maechq
        WHERE cuenta = i_val_cuenta;
        
       --Desbloqueo de cuenta
        IF (resultado_saldo_congelado > 0) THEN
            -- Desbloqueo por monto
            CALL bdicheq:"informix".bloqueo_cta(eEmpresa,i_val_cuenta, resultado_saldo_congelado, '00', 0, today, '0', '4469', '07', 'A', '09', 'P' ) RETURNING cod_ret_bloq,codeRet2;
        ELIF (resultado_saldo_congelado == 0) THEN
            -- Desbloqueo por 0                                                                                                 
            CALL bdicheq:"informix".bloqueo_cta(eEmpresa,i_val_cuenta,0,'00',0,today,'0','4469','07','A','09','P' ) RETURNING cod_ret_bloq,codeRet2;
        END IF;

        --------------------------------------------------------------------------------------------------------------------------------------
        -- MODIFICACION: RBU. FLUJO PARA INTENTAR CANCELAR LA CUENTA
        -- MODIFICACION: SE AGREGA VALIDACION PARA CONSULTAR LA TABLA acl_control_cuentas_pendientes_cancelar
        --------------------------------------------------------------------------------------------------------------------------------------
        SELECT p.numero_cuenta
        INTO i_val_cuenta
        FROM acl_aclaracion acl
        INNER JOIN acl_producto p ON p.pky_producto = acl.fky_producto
        INNER JOIN acl_tipo_producto tp ON tp.pky_tipo_producto=p.fky_tipo_producto
        WHERE folio_csuac=e_folio_csuac;

        SELECT cancelada  INTO i_val_cta_cancelada FROM acl_control_cuentas_pendientes_cancelar WHERE num_cta = i_val_cuenta;
        IF i_val_cta_cancelada == 0 THEN
        -- SE REALIZA EL INTENTO DE CANCELACION
            CALL bdiaclaracion:"informix".sp_aplicar_cancelacion_por_recuperacion_credDeb(e_folio_csuac,'0')  RETURNING cod_ret_bloq,s_Mensaje;
        END IF;

        --------------------------------------------------------------------------------------------------------------------------------------
        -- FIN MODIFICACION: RBU. FLUJO PARA INTENTAR CANCELAR
        --------------------------------------------------------------------------------------------------------------------------------------
        
    ELSE
        --Bloqueo de Cuenta
        --Consulta saldo
        CALL bdicheq:cons_saldo (i_val_cuenta) RETURNING  vcodret,vsdodisp,vstatuscta;
            
        IF (vsdodisp > 0 ) THEN
            --Bloqueo de cuenta por saldo mayor a 0                                      '56'
            CALL bdicheq:"informix".bloqueo_cta(eEmpresa,i_val_cuenta, vsdodisp, '56', 1, today , '0','','07','A','09','P'  ) RETURNING cod_ret_bloq,codeRet2;
            
            --CALL bdicheq:"informix".bloqueo_cta(empresa,TRIM(pcuenta),pmonto , pmotivobloq, pTipobloqueo, pfechabloq, pusuario, pclave, pAreaSolic, pCodArea,pTipoBloq, pCodTipoBloq)         
        ELIF (vsdodisp == 0 ) THEN
            --Bloqueo de cuenta por monto 0 
            CALL bdicheq:"informix".bloqueo_cta(eEmpresa,i_val_cuenta, 0, '56', 3, today , '0','','07','A','09','P'  ) RETURNING cod_ret_bloq,codeRet2;
            
            --CALL bdicheq:"informix".bloqueo_cta('001',TRIM(i_val_cuenta), 0, '56', 3, TODAY , '0', '', '07', 'A', '09', 'P' ) RETURNING RETURNING codRet, v_clave;;
        END IF
        
    END IF; --> INICIA Numero 34
    
    

    IF (s_CodleyendaC == 'NA') AND (s_CodleyendaI == 'NA') AND (s_CodleyendaA == 'NA') AND (s_CodleyendaIn == 'NA') THEN --> INICIA Numero 35
        LET s_CodRet = 'E-02'; 
        LET s_Mensaje = 'El cliente no cuenta con saldo suficiente para cobro'; 
    END IF; --> FIN Numero 35
   
    IF (s_CodleyendaA == 'NA') THEN --> INICIA Numero 36 
        LET s_Ca= 0;
    ELSE --> INTERMEDIO Numero 36
        LET s_Ca= 1;
    END IF; --> FIN Numero 36

    IF (s_CodleyendaC == 'NA') THEN --> INICIA Numero 37  
        LET s_Cc= 0;
    ELSE --> INTERMEDIO Numero 37
        LET s_Cc= 1;
    END IF; --> FIN Numero 37

    IF (s_CodleyendaI == 'NA') THEN --> INICIA Numero 38 
        LET s_Ci= 0;
    ELSE --> INTERMEDIO Numero 38
        LET s_Ci= 1;
    END IF; --> FIN Numero 38
    
    IF (s_CodleyendaIn == 'NA') THEN 
        LET s_Cin= 0;
    ELSE 
        LET s_Cin= 1;
    END IF; 
--COMMIT WORK;
RETURN s_CodRet,s_Mensaje, s_Cc, s_AfectacionC, s_CodleyendaC, s_Ci, s_AfectacionI, s_CodleyendaI, s_Ca, s_AfectacionA, s_CodleyendaA, s_Cin, s_AfectacionIn, s_CodleyendaIn; 
END;
END PROCEDURE;