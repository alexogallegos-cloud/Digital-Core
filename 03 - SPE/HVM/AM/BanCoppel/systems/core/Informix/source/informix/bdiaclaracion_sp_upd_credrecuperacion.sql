CREATE PROCEDURE "informix".sp_upd_credrecuperacion(e_folio_csuac CHAR(11))
--V. 5.0.0 (28-01-2019)                                              
RETURNING CHAR(6) AS s_CodRet, CHAR(100) AS s_Mensaje, SMALLINT AS s_Cc,  MONEY AS s_AfectacionC,  VARCHAR(3) AS s_CodleyendaC,
                                                       SMALLINT AS s_Ci,  MONEY AS s_AfectacionI,  VARCHAR(3) AS s_CodleyendaI,
                                                       SMALLINT AS s_Ca,  MONEY AS s_AfectacionA,  VARCHAR(3) AS s_CodleyendaA,
                                                       SMALLINT AS s_Cin, MONEY AS s_AfectacionIn, VARCHAR(3) AS s_CodleyendaIn;

    /* Variables Salida*/
    DEFINE CCodret_c                    CHAR(5);
    DEFINE CMensaje                     CHAR(80);
    DEFINE s_CodRet                     CHAR(6);  
    DEFINE s_Mensaje                    CHAR(100);
    DEFINE s_Mensaje2                   CHAR(30);
    DEFINE s_Cc                         SMALLINT;
    DEFINE s_Ci                         SMALLINT;
    DEFINE s_Ca                         SMALLINT;
    DEFINE s_AfectacionC                MONEY;
    DEFINE s_AfectacionI                MONEY;
    DEFINE s_AfectacionA                MONEY;
    DEFINE s_CodleyendaA                VARCHAR(3);
    DEFINE s_CodleyendaI                VARCHAR(3);
    DEFINE s_CodleyendaC                VARCHAR(3);
  
    --RQM 287
    DEFINE s_Cin                        SMALLINT;
    DEFINE s_AfectacionIn               MONEY;
    DEFINE s_CodleyendaIn               VARCHAR(3);
  
    --RQM 287-3
    DEFINE i_total_interes              MONEY;
    DEFINE i_interes_recuperado         MONEY;
    DEFINE i_interes_afectado           MONEY;
  
    DEFINE i_fin_recuperacion           DATE;
    DEFINE i_exito_cin                  SMALLINT;
    DEFINE i_tipo_movimiento            CHAR(1);
    DEFINE i_importereclamado           MONEY; 
    DEFINE i_fky_regla_negocio          INTEGER;

    DEFINE i_val_exito_cin              SMALLINT;
    DEFINE i_val_tmpIn                  MONEY;

    DEFINE pmotivobloq                  CHAR(2);
  
    /* Variables Internas*/
    /* Variables tabla acl_recuperacion_saldos*/
    DEFINE i_abono_recuperado           MONEY;
    DEFINE i_comision_recuperada        MONEY;
    DEFINE i_iva_recuperada             MONEY;
    DEFINE i_abono_irrecuperable        SMALLINT;
    DEFINE i_cron_activo                SMALLINT;
    DEFINE i_f_recuperacion             DATE;    
    DEFINE i_fechacaptura               DATE;
    DEFINE i_fc_recuperacion            DATETIME YEAR TO FRACTION(5);     
    DEFINE i_fi_recuperacion            DATETIME YEAR TO FRACTION(5);     
    DEFINE i_fa_recuperacion            DATETIME YEAR TO FRACTION(5);  
    DEFINE i_fky_aclaracion             INTEGER;
    DEFINE i_total_abono                MONEY;
    DEFINE i_total_comision             MONEY;
    DEFINE i_total_iva                  MONEY; 
    DEFINE i_exito_ca                   SMALLINT;
    DEFINE i_exito_cc                   SMALLINT;
    DEFINE i_exito_ci                   SMALLINT;
    DEFINE i_pky_recuperacion           INTEGER;      
    /* Variables asignaciones internas*/
    DEFINE i_val_diasnaturales          INTEGER; --> nÃºmero de dÃ­as naturales
    DEFINE i_val_tipoprod               INTEGER; --> asignaciÃ³n al tipo producto
    DEFINE i_val_cuenta                 VARCHAR(20); --> asignaciÃ³n de cuenta
    DEFINE i_val_exito_ca               SMALLINT; --> asignaciÃ³n abono exitoso
    DEFINE i_val_exito_cc               SMALLINT; --> asignaciÃ³n comisiÃ³n exitoso
    DEFINE i_val_exito_ci               SMALLINT; --> asignaciÃ³n iva exitoso
    DEFINE i_val_tmpC                   MONEY; 
    DEFINE i_val_tmpA                   MONEY; 
    DEFINE i_val_tmpI                   MONEY; 
    DEFINE I_estatus_corp               INTEGER;
    DEFINE ia_total_comision            MONEY; 
    DEFINE ia_comision_recuperada       MONEY;
    DEFINE ia_total_iva                 MONEY;
    DEFINE ia_iva_recuperada            MONEY;
    -- MODIFICACION RBU: INTENTO DE CANCELACION
    DEFINE i_val_cta_cancelada          SMALLINT;
    DEFINE i_val_codret_cancela         CHAR(5);
    DEFINE i_val_menret_cancela         CHAR(60);


        
    DEFINE v_resol_abono_irrecuperable      INTEGER;
    DEFINE v_resol_importe_irrecuperable    INTEGER;
    DEFINE v_fky_estatus_aclaracion         INTEGER;
    DEFINE v_fky_estatus_corp_analisis      INTEGER;
    DEFINE V_fky_estatus_corp_general       INTEGER;

    /* Variables obtenciÃ³n Saldo CRÃ¿DITO*/

    DEFINE  linea_disponible        DECIMAL(18,2);

    /* variables obtenciÃ³n de sp cargo abono */
    DEFINE DCodret_a                CHAR(5); 
    DEFINE DTranret_c               CHAR(4);
    DEFINE DFechoy_c                DATE;
    DEFINE  Dlinea_disponible_c     MONEY(14,2);
    DEFINE  DVmontoret_c            MONEY(14,2);
    /* Variables de entrada SP afectacion comision debito*/
    DEFINE CnumTarjeta              CHAR(20);
    DEFINE eEmpresa                 CHAR(3);
    DEFINE vTranCom                 CHAR(4);
    DEFINE v_contador               SMALLINT;
    DEFINE v_fecha_folio            CHAR(10);
    DEFINE eFolio                   CHAR(16);
    DEFINE eSucursal                CHAR(4);
    DEFINE p_Monto                  MONEY(14,2);
    DEFINE pFolioSuacSUC            CHAR(16);
    DEFINE p_transacc               CHAR(4);

/* Variables de salida SP afectacion comision, iva y abono*/

    DEFINE SaldoCom               MONEY(14,2);
    DEFINE MtoCgo                 MONEY(14,2);
    DEFINE MtoCom                 MONEY(14,2);
    DEFINE vIva                   MONEY(14,2);
   
    DEFINE cod_ret_bloq           CHAR(3); 
    DEFINE v_diferencia_fechas    INTEGER;

-- TIPO DE MOVIMIENTO
    DEFINE pFolioSuc            CHAR(20);
    DEFINE pOrigenEvento        INTEGER;
    DEFINE resultado_origen     CHAR (1);
    DEFINE modo_entrada         VARCHAR(2);

    -- Manejo de exceptions
    DEFINE iSqlErr       		INTEGER;
DEFINE wBegin CHAR(1);

    --VARIABLES ACTIVOS RECUPERACIONES OPTIMIZACIÃN 22-ENERO-2019
    DEFINE vRecuperoComIVA INTEGER;
    DEFINE vRecuperoAbono INTEGER;
    DEFINE vRecuperacionComIvaParcial INTEGER;
    DEFINE vMontoRecuperacion MONEY;
--VARIABLE PARA EVITAR EL IF NOT EXIST
    DEFINE vPky_recuperacion_sdos INTEGER;
    LET vRecuperoComIVA = 0;
    LET vRecuperoAbono = 0;
    LET vMontoRecuperacion = 0;
    LET vRecuperacionComIvaParcial = 0;


LET wBegin = 'N';


    --SET DEBUG FILE TO "/home/rtechno/RQM287-3/18-01-2019/CREDITOSALDONV2.out";
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
        
		ON EXCEPTION SET iSqlErr
			  --ROLLBACK WORK;
			  IF (wBegin = "S") THEN
				 BEGIN WORK;
			  END IF;

                RETURN  iSqlErr,'',0,0,'',0,0,'',0,0,'',0,0,''; -- RETURNING
		   END EXCEPTION;

		   ON EXCEPTION IN (-535)
			  LET wBegin = "S";
			  --ROLLBACK WORK;
			  COMMIT WORK;
				SET ISOLATION TO DIRTY READ;
			  --BEGIN WORK;
		   END EXCEPTION WITH RESUME;

       --> Variables Salida
       LET s_CodRet   = '000';
       LET s_Mensaje  = 'AfectaciÃ³n Exitosa';
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
       LET p_transacc = '';
       LET i_importereclamado = 0; 
       LET i_fky_regla_negocio = 0; 

      --RQM 287
       LET s_Cin          = 0;
       LET s_AfectacionIn = 0;
       LET s_CodleyendaIn = 'NA';
     
     LET pmotivobloq = ''; 
       
     --VALIDACION DE ORIGEN DE MOVIMIENTO (NACIONAL/INTERNACIONAL)
     
     -- Tipo de movimiento  V = 45     F = 180    Ã¿    N = INDEFINIDO
     SELECT tipo_movimiento, importereclamado, fky_regla_negocio INTO i_tipo_movimiento, i_importereclamado, i_fky_regla_negocio FROM acl_aclaracion WHERE folio_csuac = e_folio_csuac;

     IF(i_tipo_movimiento == 'N') THEN 

            SELECT movimiento.folio_suc,producto.numero_tarjeta,evento.fky_origen_evento,movimiento.monto_recuperacion
            INTO  pFolioSuc,CnumTarjeta,pOrigenEvento,vMontoRecuperacion
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
     END IF;

     
       LET i_val_exito_cc = 0;
       LET i_pky_recuperacion = (SELECT max (pky_recuperacion) FROM "informix".acl_recuperacion_saldos WHERE folio_csuac = e_folio_csuac);
       LET eEmpresa ='001';
       LET vTranCom = '';
       LET v_contador = 0;

       --IMPORTES IRRECUPERABLES
       LET v_resol_abono_irrecuperable = (select pky_resolucion from acl_resolucion where nombre='abonoIrrecuperable');
       LET v_resol_importe_irrecuperable = (select pky_resolucion from acl_resolucion where nombre='cargoNoRealizado'); --DUDA LUIS


    /* Realizar la consulta a la tabla acl_recuperaciÃ³n saldos para obtener la informaciÃ³n de la recuperacion del folio*/
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
    
    --CREDITO
    SELECT sucursal INTO eSucursal FROM bdinteg:si_ejecut WHERE ejecutivo in(SELECT num_empleado FROM "informix".acl_aclaracion WHERE folio_csuac = e_folio_csuac);
	
	IF eSucursal = '' OR eSucursal IS NULL THEN 
		SELECT sucursal INTO eSucursal FROM bdinteg:si_ejecut WHERE ejecutivo in(Select au.num_empleado from bdiaclaracion:acl_aclaracion ac inner join bdiaclaracion:acl_usuario au on ac.fky_usuario_analista = au.pky_usuario where ac.folio_csuac = e_folio_csuac);
	END IF;
	
    /*Realiza la validaciÃ³n de la columna abono irrecuperable, en caso de que sea cero, indica que el folio aÃºn estÃ¡ en periodo de recuperaciÃ³n.*/
    IF (i_abono_irrecuperable == 0) THEN --> INICIA NÃºmero 1  

            /*Relaiza la validaciÃ³n de la columna f_recuperacion, en caso de que sea mayor a 45, no entra en el proceso de recuperaciÃ³n y actualiza la tabla acl_recuperacion_saldos.*/
            LET v_diferencia_fechas =  DATE(today) - DATE(i_fechacaptura);
            IF ((v_diferencia_fechas) >= i_val_diasnaturales)  THEN --> INICIA NÃºmero 2  
    
    
                    
                    --=========== IF TRANSACCIONES ============================
                    IF i_abono_recuperado = 0 AND i_iva_recuperada = 0 AND i_comision_recuperada = 0 AND i_interes_recuperado = 0 THEN
                        LET I_estatus_corp = 25;
                    ELSE
                        LET I_estatus_corp = 24;
                    END IF;
                    

                      --   VALIDANDO SI EL REGISTRO EXISTE EN CASO DE QUE NO, SE INSERTA NUEVO Y UNICO REGISTRO COMO ABONO IRRECUPERABLE
                    --   DA DE BAJA EL CRON_ACTIVO=0 Y ABONO IRRECUPERABLE=1 Y LAS FECHAS ACTUALES PARA CADA CAMPO DE RECUPERACION
                    --Se comenta el IF NOT EXIST por obsrvaciones de BASE DE DATOS, no estÃ¡ permitido utilizar este tipo de condiciones
                    --IF NOT EXISTS (SELECT 1 FROM ACL_RECUPERACION_SALDOS WHERE fky_aclaracion= i_fky_aclaracion AND folio_csuac=e_folio_csuac AND total_abono=i_total_abono AND abono_recuperado =i_abono_recuperado
                    --               AND abono_afectado='0' AND total_comision = i_total_comision AND comision_recuperada=i_comision_recuperada AND comision_afectada='0' AND total_iva= i_total_iva AND iva_recuperada =i_iva_recuperada               
                    --               AND iva_afectada ='0' AND total_interes = i_total_interes AND interes_recuperado = i_interes_recuperado AND interes_afectado ='0' AND f_recuperacion=i_f_recuperacion AND fc_recuperacion = CURRENT 
                    --               AND fi_recuperacion = CURRENT AND fa_recuperacion = CURRENT AND fin_recuperacion = CURRENT AND abono_irrecuperable='1' AND cron_activo='0' AND exito_ca=i_exito_ca AND exito_cc=i_exito_cc AND exito_ci=i_exito_ci
                    --               AND exito_cin=i_exito_cin AND fky_estatus_corporativo =I_estatus_corp) THEN   
                        
                     SELECT  pky_recuperacion INTO vPky_recuperacion_sdos FROM ACL_RECUPERACION_SALDOS  WHERE fky_aclaracion= i_fky_aclaracion AND folio_csuac=e_folio_csuac AND total_abono=i_total_abono AND abono_recuperado =i_abono_recuperado
                                   AND abono_afectado='0' AND total_comision = i_total_comision AND comision_recuperada=i_comision_recuperada AND comision_afectada='0' AND total_iva= i_total_iva AND iva_recuperada =i_iva_recuperada               
                                   AND iva_afectada ='0' AND total_interes = i_total_interes AND interes_recuperado = i_interes_recuperado AND interes_afectado ='0' AND f_recuperacion=i_f_recuperacion AND fc_recuperacion = CURRENT 
                                   AND fi_recuperacion = CURRENT AND fa_recuperacion = CURRENT AND fin_recuperacion = CURRENT AND abono_irrecuperable='1' AND cron_activo='0' AND exito_ca=i_exito_ca AND exito_cc=i_exito_cc AND exito_ci=i_exito_ci
                                   AND exito_cin=i_exito_cin AND fky_estatus_corporativo =I_estatus_corp;
                     IF vPky_recuperacion_sdos IS NULL THEN
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
                                  I_estatus_corp)
                          RETURNING s_CodRet, s_Mensaje2;
                        
                        UPDATE "informix".acl_aclaracion
                        SET fky_estatus_corp_general = 6,fky_estatus_flujo_causa=I_estatus_corp
                        WHERE folio_csuac = e_folio_csuac AND pky_aclaracion = i_fky_aclaracion;
                        --ACTUALIZA EL CRON ACTIVO PARA LA EJECUCIÃ¿N DESDE EL CRON.
                        UPDATE "informix".acl_recuperacion_saldos SET cron_activo = 0 WHERE folio_csuac = e_folio_csuac;
                        
                        -- CONSULTA NUEVAMENTE POR ACTUALIZACION EN ESTATUS
                            SELECT fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general 
                            INTO v_fky_estatus_aclaracion,v_fky_estatus_corp_analisis,v_fky_estatus_corp_general
                            FROM acl_aclaracion where folio_csuac=e_folio_csuac and pky_aclaracion=i_fky_aclaracion;

                        -- INSERT BITACORA 
                        

                                    -- VALIDACION DE ABONO NO RECUPERADO
                                    IF (i_exito_ca = 0 AND i_total_abono > 0) THEN --INSERT BITACORA POR MONTO NO RECUPERADO

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
                                     
                                    IF (i_exito_cc = 0 AND i_total_comision > 0) THEN  --INSERT BITACORA POR MONTO NO RECUPERADO

                                        INSERT INTO "informix".acl_entrada_bitacora
                                                        VALUES("informix".ENTRADA_BITACORA_SEQ.NEXTVAL, --pky_entrada_bitacora
                                                       'El cargo de la comisiÃ³n por aclaraciÃ³n no procedente no fue realizado.',-- descripcion   
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

                                     IF (i_exito_ci = 0 AND i_total_iva > 0) THEN -- INSERT BITACORA POR MONTO NO RECUPERADO

                                        INSERT INTO "informix".acl_entrada_bitacora
                                                        VALUES("informix".ENTRADA_BITACORA_SEQ.NEXTVAL, --pky_entrada_bitacora
                                                       'El cargo del IVA de la comisiÃ³n por aclaraciÃ³n no procedente no fue realizado.',-- descripcion   
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
                CALL sp_aplicar_cancelacion_por_recuperacion_credDeb(e_folio_csuac,'0' ) RETURNING cod_ret_bloq,s_Mensaje;

                        LET s_CodRet='E-01';
                        LET s_Mensaje='El registro es irrecuperable, por vencimiento de fecha';
                    END IF;     
                    RETURN s_CodRet,s_Mensaje, s_Cc, s_AfectacionC, s_CodleyendaC, s_Ci, s_AfectacionI, s_CodleyendaI, s_Ca, s_AfectacionA, s_CodleyendaA, s_Cin, s_AfectacionIn, s_CodleyendaIn; 

            ELSE /*Relaiza la validaciÃ³n de la columna f_recuperacion, en caso de que sea menor a 45, continua con la validaciÃ³n de filtros.*/
                
                SELECT tp.tipo_producto,p.numero_cuenta, numero_tarjeta 
                INTO i_val_tipoprod, i_val_cuenta, CnumTarjeta
                FROM acl_aclaracion acl
                INNER JOIN acl_producto p ON p.pky_producto = acl.fky_producto
                INNER JOIN acl_tipo_producto tp ON tp.pky_tipo_producto=p.fky_tipo_producto
                WHERE folio_csuac=e_folio_csuac;
                
                SELECT substr((current HOUR TO SECOND),1,2)||substr((current HOUR TO SECOND),4,2)|| LPAD(v_contador,2,0)
                INTO v_fecha_folio FROM bdicred:sd_fechas;
                let pFolioSuacSUC = trim(v_fecha_folio)||lpad(e_folio_csuac,10,0);
               
--COMISION e IVA
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
 /*==== CONSULTA SALDO CREDITO*/

      --DESBLOQUEO CUENTA CREDITO
      CALL bdicred:sp_desbloqueocuenta (eEmpresa,i_val_cuenta,'0','1') RETURNING s_CodRet, s_Mensaje2; --DESBLOQUEO CUENTA
     


            --CONSULTA DE SALDOS

            SELECT (monto_otorgado - sdo_cap_insoluto - sdo_retenido) saldo
            INTO linea_disponible
            FROM bdicred:sd_maesdos WHERE num_credito = i_val_cuenta;

                            
                           -- LET codigo_retorno ='000000';   LET linea_disponible = 2500;  ----- PRUEBAS

                            IF  (linea_disponible > 0 ) THEN --> INICIA NÃºmero 19

                                       IF (i_exito_cc == 0) THEN --> INICIA NÃºmeri_val_tmpCo 20
                                     --***************************************************************************
                                        LET i_val_tmpC = (i_total_comision - i_comision_recuperada);
                                        LET i_val_tmpI = (i_total_iva - i_iva_recuperada);
										
										--Cobro parcial de comisiÃ³n e IVA.
										IF(i_val_tmpC + i_val_tmpI) > linea_disponible THEN
											SELECT trans_no_procede 
                                            INTO p_transacc
                                            FROM acl_tipo_movimiento 
                                            WHERE pky_tipo_movimiento=(SELECT fky_tipo_movimiento FROM acl_movimiento 
                                            WHERE folio_csuac = e_folio_csuac and cargo = 1 and exitoso = 0 and duplicado=0 and fky_padre is not null);
											LET I_estatus_corp = 22;
											LET s_AfectacionC = linea_disponible / (1.16); --CALCULO COBRO COMISIÃN
											--COBRO COMISIÃN E IVA
											CALL bdicred:cargoref_tc_ofi(eEmpresa, eSucursal, user, CnumTarjeta, s_AfectacionC,pFolioSuacSUC, p_transacc)
                                                RETURNING s_CodRet, SaldoCom, MtoCgo, MtoCom, vIva;
											--SI EL COBRO DE LA COMISIÃN E IVA SE REALIZÃ DE MANERA EXITOSA		 
											IF s_CodRet == '000' THEN
												LET s_AfectacionI =  linea_disponible - (s_AfectacionC); --CALCULO COBRO IVA
													LET i_val_tmpC = (i_comision_recuperada + s_AfectacionC);
                                                    LET i_val_tmpI = (i_iva_recuperada + s_AfectacionI);
													--INSERTA EN acl_recuperacion_saldos
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
																									I_estatus_corp)
																					RETURNING s_CodRet, s_Mensaje2;
												    --ACTUALIZACIÃN A acl_movimiento
                                                    IF vMontoRecuperacion <= i_total_comision THEN
                                                        UPDATE "informix".acl_movimiento
                                                                        SET monto_recuperacion = (i_comision_recuperada + s_AfectacionC)
                                                                        WHERE cargo=1
                                                                        AND exitoso = 0
                                                                        AND fky_padre IS NOT NULL
                                                                        AND duplicado = 0
                                                                        AND folio_suc IS NULL    
                                                                        AND folio_csuac=e_folio_csuac;
                                                    END IF;
                                                    LET vRecuperoComIVA = 1;
                                                    --ASIGNAR CÃDIGO DE SALIDA COMISIÃN PACIAL ÃXITOSA
                                                    LET s_CodleyendaC = 'CPC';
                                                    LET s_Cc = 1;
                                                    LET s_AfectacionC = s_AfectacionC;
                                                    --ASIGNAR CÃDIGO DE SALIDA IVA PACIAL ÃXITOSA
                                                    LET s_CodleyendaI = 'CPI';
                                                    LET s_Ci= 1;
                                                    LET s_AfectacionI = s_AfectacionI;
                                                    LET vRecuperacionComIvaParcial = 1;
											ELSE
												RETURN s_CodRet,'No se realizo la afectacion de comision/iva', 0, 0, 'NA', 0, 0, 'NA', 0, 0, 'NA',0,0,'NA'; 
											END IF;		  
										END IF; -- fin cobro parcial comisiÃ³n e iva
                                        IF vRecuperacionComIvaParcial == 0 THEN
                                        IF (i_val_tmpC + i_val_tmpI) <= linea_disponible THEN --- A 1/3
                                            LET p_Monto = i_val_tmpC;
                                            LET I_estatus_corp = 22;
                                            
                                            SELECT trans_no_procede 
                                            INTO p_transacc
                                            FROM acl_tipo_movimiento 
                                            WHERE pky_tipo_movimiento=(SELECT fky_tipo_movimiento FROM acl_movimiento 
                                            WHERE folio_csuac = e_folio_csuac and cargo = 1 and exitoso = 0 and duplicado=0 and fky_padre is not null);
                                            
                                             -- APLICACION DE CARGO COMISION
											 
											     --call sp_cargo_abono_aclara(pEmpresa, CnumCredito, CnumTarjeta, CmontoAcla, user, '9250',ptranaplica,Ccargo ,pFolioSuacSUC)
													--RETURNING CCodret_c, CMensaje;
													
											     call bdicred:sp_cargo_abono_aclara(eEmpresa, i_val_cuenta, CnumTarjeta, p_Monto, user, '9250',p_transacc,1 ,pFolioSuacSUC)
                                                      RETURNING s_CodRet, CMensaje;
                                                
                                               -- CALL bdicred:cargoref_tc_ofi(eEmpresa, eSucursal, user, CnumTarjeta, p_Monto,pFolioSuacSUC, p_transacc)
                                                -- RETURNING s_CodRet, SaldoCom, MtoCgo, MtoCom, vIva;
                                          --     EXECUTE PROCEDURE bdicred:cargoref_tc_ofi('001', '9767', user, '4268070242237891', 200,'1704002610181861',  '5212')

                                                

                                                --LET s_CodRet = '000'; -- ## Pruebas
                                                LET s_AfectacionC = i_total_comision;  --TOTAL DE LA TABLA COMISION
                                                LET s_AfectacionI = i_total_iva;       --- TOTAL DE LA TABLA IVA

                                                    IF s_CodRet == '000' THEN -- C  1/3
                                                        LET i_exito_cc = 1;
                                                        LET i_exito_ci = 1;
                                  
                                                                    LET i_val_tmpC = (i_comision_recuperada + i_val_tmpC);
                                                                    LET i_val_tmpI = (i_iva_recuperada + i_val_tmpI);

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
                                                               I_estatus_corp)
                                                       RETURNING s_CodRet, s_Mensaje2;
                                                                    -- ACTUALIZAR MOVIMIENTO COMISION
                                                                IF vMontoRecuperacion <= i_total_comision THEN
                                                                    let vMontoRecuperacion = i_comision_recuperada + s_AfectacionC;
                                                                        if vMontoRecuperacion < i_total_comision then
                                                                            UPDATE acl_movimiento  
                                                                                    SET exitoso = 1, fecha_afectacion  = CURRENT, 
                                                                                    monto_recuperacion = (i_comision_recuperada + s_AfectacionC) 
                                                                                WHERE cargo=1
                                                                                AND exitoso = 0
                                                                                AND fky_padre IS NOT NULL
                                                                                AND duplicado = 0
                                                                                AND folio_suc IS NULL    
                                                                                AND folio_csuac=e_folio_csuac;
                                                                        else
                                                                            UPDATE acl_movimiento  
                                                                                    SET exitoso = 1, fecha_afectacion  = CURRENT, 
                                                                                    monto_recuperacion = i_total_comision
                                                                                WHERE cargo=1
                                                                                AND exitoso = 0
                                                                                AND fky_padre IS NOT NULL
                                                                                AND duplicado = 0
                                                                                AND folio_suc IS NULL    
                                                                                AND folio_csuac=e_folio_csuac;
                                                                        end if;
                                                                 END IF;
                                                                    -- FIN MOVIMIENTO ACTUALIZADO

                                                                    LET s_CodleyendaC = 'CTC'; --> Mensaje de salida de comision afectada total 
                                                                    LET s_CodleyendaI = 'CTI'; --> Mensaje de salida de IVA afectada total 
                                                                    LET s_Ci= 1;
                                                                    LET s_Cc = 1;

                                                    LET vRecuperoComIVA = 1;          

                                                    ELSE  -- C  1/3
                                                        IF vRecuperoComIVA = 1 THEN
                                                            
                                                            LET s_CodRet = '000000';
                                                            LET s_Mensaje = 'AfectaciÃ³n exitosa'; 
                                                            RETURN s_CodRet, s_Mensaje, s_Cc, i_comision_recuperada, s_CodleyendaC, s_Ci, i_iva_recuperada, s_CodleyendaI, s_Ca, s_AfectacionA, s_CodleyendaA, s_Cin, s_AfectacionIn, s_CodleyendaIn; 
                                                        END IF;
                                                        RETURN s_CodRet,'No se realizÃ³ la afectaciÃ³n de comision/iva', 0, 0, 'NA', 0, 0, 'NA', 0, 0, 'NA',0, 0, 'NA'; 
                                                    END IF; -- C  1/3

                                        END IF; --- A 1/3
                                        END IF;
                                    LET i_fc_recuperacion = CURRENT;
                                    LET i_fi_recuperacion = CURRENT;
                                    LET s_Ci = 1;
                                    LET s_Cc = 1;
                                 END IF; --> FIN NÃºmero 20
                                       
                             ELSE --> INTERMEDIO NÃºmero 19

                             END IF; --> FIN NÃºmero 19
-----------------------------------------------------------

-- ABONO     /*==== CONSULTA SALDO CREDITO*/

                        SELECT (monto_otorgado - sdo_cap_insoluto - sdo_retenido) saldo
		        INTO linea_disponible
		        FROM bdicred:sd_maesdos WHERE num_credito = i_val_cuenta;


                            LET i_pky_recuperacion = (SELECT max (pky_recuperacion) FROM "informix".acl_recuperacion_saldos WHERE folio_csuac = e_folio_csuac);

                            SELECT  exito_ca, exito_cc, exito_ci, exito_cin
                            INTO i_exito_ca, i_exito_ci,i_exito_cc, i_exito_cin 
                            FROM "informix".acl_recuperacion_saldos 
                            WHERE folio_csuac = e_folio_csuac AND pky_recuperacion = i_pky_recuperacion;

/*pruebas*/      --LET linea_disponible = linea_disponible - (s_AfectacionI + s_AfectacionC); ----- PRUEBAS
/*pruebas*/      --LET codigo_retorno = '000000'; ----- PRUEBAS
                                
                               -- LET i_iva_recuperada = i_val_tmpI;
                                --LET i_comision_recuperada = i_val_tmpC;
  

                        --IF (codigo_retorno == '000000') AND (linea_disponible > 0 AND i_exito_cc='1' AND i_exito_ci='1' ) THEN --> INICIA NÃºmero 29  Cobro de abono hasta que se cobre la comision e iva
                                IF (linea_disponible > 0 ) THEN --> INICIA NÃºmero 29  cobro de abono 
                                        
                    --Interes
                    IF (i_exito_cin == 0) THEN
                    
                      LET i_val_tmpIn = (i_total_interes - i_interes_recuperado);
                    
                      --Cambios de validacion para comision e iva 
                      LET i_pky_recuperacion = (SELECT max (pky_recuperacion) FROM acl_recuperacion_saldos WHERE folio_csuac = e_folio_csuac);
                      LET i_iva_recuperada = (SELECT iva_recuperada from acl_recuperacion_saldos where pky_recuperacion=i_pky_recuperacion);
                      LET i_comision_recuperada = (SELECT comision_recuperada  from acl_recuperacion_saldos where pky_recuperacion=i_pky_recuperacion);
                      
                      IF (i_val_tmpIn < linea_disponible) THEN --> INICIA NÃºmero 31
                                            --=================================================================
                                                SELECT substr((current HOUR TO SECOND),1,2)||substr((current HOUR TO SECOND),4,2)|| LPAD(v_contador,2,0)
                                                INTO v_fecha_folio FROM bdicred:sd_fechas;
                                                LET pFolioSuacSUC = trim(v_fecha_folio)||lpad(e_folio_csuac,10,0);
                                                --==== SELECCIONA LA TRANSACCION DE ABONO mediante tipo_movimiento

                                                SELECT trans_no_procede 
                                                INTO p_transacc
                                                FROM acl_tipo_movimiento 
                                                WHERE pky_tipo_movimiento=(
                                                SELECT fky_tipo_movimiento FROM acl_movimiento 
                                                WHERE folio_csuac = e_folio_csuac and cargo = 1 and exitoso = 0 and duplicado=1 and fky_padre is null);      


                                                LET s_AfectacionIn = i_val_tmpIn; --> Saldo de salida de ABONO afectada
                                                LET p_Monto = i_val_tmpIn;

                                                LET i_val_tmpIn = (i_interes_recuperado + i_val_tmpIn);
                                               

                                                     call bdicred:sp_cargo_abono_aclara(eEmpresa, i_val_cuenta, CnumTarjeta, p_monto, user, '9250',p_transacc,1 ,pFolioSuacSUC)
                                                      RETURNING CCodret_c, CMensaje;

                                                      IF (CCodret_c is not null) THEN
                                                        COMMIT WORK;
                                                      END IF;
                                                      
                                                      IF(CCodret_c <> "000") THEN
                                                            --ROLLBACK WORK;
                                                            COMMIT WORK;
                                                            LET wBegin = "S";
                                                            --IF (wBegin = "S") THEN
                                                              --  BEGIN WORK;
                                                            --END IF;
                                                     END IF;  
                                                      
                                                 
                                                --LET s_CodRet ='000'; ----- PRUEBAS
                                                
                                                IF (CCodret_c=='000') THEN 
                                                --LET s_Ca = 1;
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
                                                                                           -- s_Ca,  i_exito_cc,i_exito_ci,23)RETURNING s_CodRet, s_Mensaje2;
                                              i_exito_ca,  
                                              i_exito_cc,
                                              i_exito_ci,
                                              1,
                                              22)
                                            RETURNING s_CodRet, s_Mensaje2; 
                                                    LET s_CodleyendaA = 'CTA'; --> Mensaje de salida de comision afectada total
                                                    -- ACTUALIZA MOVIMIENTO                 

                                                    update "informix".acl_movimiento set exitoso = 1,fecha_afectacion  = CURRENT, monto_recuperacion = (i_val_tmpIn)   
                                                    where cargo=1 
                                                    and exitoso = 0 
                                                    and fky_padre IS NOT NULL 
                                                    and duplicado = 1 
                          AND folio_suc IS NULL
                                                    and folio_csuac=e_folio_csuac;

                                                    -- FINALIZA ACTUALIZA MOVIMIENTO
                                                    --ACTUALIZA ACLARACION 
                                                    --UPDATE "informix".acl_aclaracion SET fky_estatus_flujo_causa = 22 WHERE folio_csuac = e_folio_csuac AND pky_aclaracion = i_fky_aclaracion;

                                             END IF; -- TERMINA VALIDACION SP CARGO INTERES   
                                           
                                            --=================================================================
                                            ELSE  --> ELSE Numero 31 intermedio (Si el saldo es menor a la cantidad de interes por cobrar) ======================================== CARGOS PARCIALES ABONO
                                                
                                                    
                                                        IF (linea_disponible < i_val_tmpIn AND linea_disponible > 0)  THEN --- REALIZA COBROS PARCIALES
                                                
                                                                            SELECT substr((current HOUR TO SECOND),1,2)||substr((current HOUR TO SECOND),4,2)|| LPAD(v_contador,2,0)
                                                                            INTO v_fecha_folio FROM bdicred:sd_fechas;
                                                                            LET pFolioSuacSUC = trim(v_fecha_folio)||lpad(e_folio_csuac,10,0);
                                                                            --==== SELECCIONA LA TRANSACCION DE ABONO mediante tipo_movimiento

                                                                            SELECT trans_no_procede 
                                                                            INTO p_transacc
                                                                            FROM acl_tipo_movimiento 
                                                                            WHERE pky_tipo_movimiento=(
                                                                            SELECT fky_tipo_movimiento FROM acl_movimiento 
                                                                            WHERE folio_csuac = e_folio_csuac and cargo = 1 and exitoso = 0 and duplicado=1 and fky_padre is null);      

                                                                            LET i_val_tmpIn = linea_disponible;
                                                                                
    
                                                                            LET s_AfectacionIn = i_val_tmpIn; --> Saldo de salida de ABONO afectada
                                                                            LET p_Monto = i_val_tmpIn;

                                                                            LET i_val_tmpIn = (i_interes_recuperado + i_val_tmpIn); --Suma abono recuperado + afectado

                                                                        

                                                                              call bdicred:sp_cargo_abono_aclara(eEmpresa, i_val_cuenta, CnumTarjeta, p_monto, user, '9250',p_transacc,1 ,pFolioSuacSUC)
                                                                              RETURNING CCodret_c, CMensaje;

                                                                              
                                                                                IF (CCodret_c is not null) THEN
                                                                                  COMMIT WORK;
                                                                                END IF;

                                                                              IF(CCodret_c <> "000") THEN
                                                                                --ROLLBACK WORK;
                                                                                COMMIT WORK;
                                                                                LET wBegin = "S";
                                                                                --IF (wBegin = "S") THEN
                                                                                  --  BEGIN WORK;
                                                                                --END IF;
                                                                             END IF;  
                                                                              

                                                                            --LET s_CodRet ='000'; ----- PRUEBAS
                                                                            
                                                                          

                                                                            IF (CCodret_c=='000') THEN 
                                                                            --LET s_Ca = 1;
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
                                                                                                                       -- s_Ca,  i_exito_cc,i_exito_ci,23)RETURNING s_CodRet, s_Mensaje2;
                                                            i_exito_ca,  
                                                            i_exito_cc,
                                                            i_exito_ci,
                                                            0,
                                                            22)
                                                      RETURNING s_CodRet, s_Mensaje2; 
                                                                            LET s_CodleyendaA = 'CPA'; --> Mensaje de salida de comision afectada total
                                                                                -- ACTUALIZA MOVIMIENTO                 
                            
                                                                                update "informix".acl_movimiento set exitoso = 0,fecha_afectacion  = CURRENT, monto_recuperacion = (i_val_tmpIn)   
                                                                                where cargo=1 
                                                                                and exitoso = 0 
                                                                                and fky_padre IS NOT NULL 
                                                                                and duplicado = 1 
                                                                                AND folio_suc IS NULL
                                                                                and folio_csuac=e_folio_csuac;

                                                                                -- FINALIZA ACTUALIZA MOVIMIENTO
                                                                                --ACTUALIZA ACLARACION 
                                                                                --UPDATE "informix".acl_aclaracion SET fky_estatus_flujo_causa = 22 WHERE folio_csuac = e_folio_csuac AND pky_aclaracion = i_fky_aclaracion;
                            
                                                                         END IF; -- TERMINA VALIDACION SP CARGO INTERES   

                                            
                                                              END IF; --COBROS PARCIALES ****************         


                      END IF;   --> FIN INTERES
                      
                    END IF;
                    --Interes
                    
                    LET i_interes_recuperado = i_val_tmpIn;
                    
                    LET i_pky_recuperacion = (SELECT max (pky_recuperacion) FROM "informix".acl_recuperacion_saldos WHERE folio_csuac = e_folio_csuac);

                    SELECT  exito_ca, exito_cc, exito_ci, exito_cin
                    INTO i_exito_ca, i_exito_ci,i_exito_cc, i_exito_cin 
                    FROM "informix".acl_recuperacion_saldos 
                    WHERE folio_csuac = e_folio_csuac AND pky_recuperacion = i_pky_recuperacion;
                    
                                                 
                    --Recuperacion del abono
                                       IF (i_exito_ca == 0 and i_exito_cin == 1) THEN --> INICIA NÃºmero 30
                                     --********************************************************************************************************************                               
                                          
                                            LET i_val_tmpA = (i_total_abono - i_abono_recuperado);

                                                --Cambios de validacion para comision e iva 
                                        LET i_pky_recuperacion = (SELECT max (pky_recuperacion) FROM acl_recuperacion_saldos WHERE folio_csuac = e_folio_csuac);
                                        LET i_iva_recuperada = (SELECT iva_recuperada from acl_recuperacion_saldos where pky_recuperacion=i_pky_recuperacion);
                                        LET i_comision_recuperada = (SELECT comision_recuperada  from acl_recuperacion_saldos where pky_recuperacion=i_pky_recuperacion);
                                            

                                            IF (i_val_tmpA <= linea_disponible) THEN --> INICIA NÃºmero 31
                                            --=================================================================
                                                SELECT substr((current HOUR TO SECOND),1,2)||substr((current HOUR TO SECOND),4,2)|| LPAD(v_contador,2,0)
                                                INTO v_fecha_folio FROM bdicred:sd_fechas;
                                                LET pFolioSuacSUC = trim(v_fecha_folio)||lpad(e_folio_csuac,10,0);
                                                --==== SELECCIONA LA TRANSACCION DE ABONO mediante tipo_movimiento

                                                SELECT trans_no_procede 
                                                INTO p_transacc
                                                FROM acl_tipo_movimiento 
                                                WHERE pky_tipo_movimiento=(
                                                SELECT fky_tipo_movimiento FROM acl_movimiento 
                                                WHERE folio_csuac = e_folio_csuac and cargo = 1 and exitoso = 0 and duplicado=1 and fky_padre is null);      


                                                LET s_AfectacionA = i_val_tmpA; --> Saldo de salida de ABONO afectada
                                                LET p_Monto = i_val_tmpA;

                                                LET i_val_tmpA = (i_abono_recuperado + i_val_tmpA);
                                               

                                                     call bdicred:sp_cargo_abono_aclara(eEmpresa, i_val_cuenta, CnumTarjeta, p_monto, user, '9250',p_transacc,1 ,pFolioSuacSUC)
                                                      RETURNING CCodret_c, CMensaje;
                                                      

                                                      IF (CCodret_c is not null) THEN
                                                        COMMIT WORK;
                                                      END IF;

                                                      IF(CCodret_c <> "000") THEN
                                                                                --ROLLBACK WORK;
                                                        COMMIT WORK;
                                                        LET wBegin = "S";
                                                        --IF (wBegin = "S") THEN
                                                          --  BEGIN WORK;
                                                        --END IF;
                                                     END IF;  
                                                 
                                                --LET s_CodRet ='000'; ----- PRUEBAS
                                                
                                                IF (CCodret_c=='000') THEN 
                                                --LET s_Ca = 1;
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
                                                                                           -- s_Ca,  i_exito_cc,i_exito_ci,23)RETURNING s_CodRet, s_Mensaje2;
                                              1,  
                                              i_exito_cc,
                                              i_exito_ci,
                                              i_exito_cin,
                                              23)
                                            RETURNING s_CodRet, s_Mensaje2; 
                                                    LET s_CodleyendaA = 'CTA'; --> Mensaje de salida de comision afectada total
                                                    -- ACTUALIZA MOVIMIENTO                 

                                                    update "informix".acl_movimiento set exitoso = 1,fecha_afectacion  = CURRENT, monto_recuperacion = (i_val_tmpA)   
                                                    where cargo=1 
                                                    and exitoso = 0 
                                                    and fky_padre is null 
                                                    and duplicado = 1 
                                                    and folio_csuac=e_folio_csuac;
                                                    -- FINALIZA ACTUALIZA MOVIMIENTO
                                                    --ACTUALIZA ACLARACION 
                                                    UPDATE "informix".acl_aclaracion SET fky_estatus_flujo_causa = 23 WHERE folio_csuac = e_folio_csuac AND pky_aclaracion = i_fky_aclaracion;
                                             
                                                    LET vRecuperoAbono = 1;
                                             END IF; -- TERMINA VALIDACION SP CARGO ABONO   
                                           
                                            --=================================================================
                                            ELSE  --> ELSE Numero 31 intermedio (Si el saldo es menor a la cantidad de abono por cobrar) ======================================== CARGOS PARCIALES ABONO
                                                
                                                    
                                                        IF (linea_disponible < i_val_tmpA AND linea_disponible > 0)  THEN --- REALIZA COBROS PARCIALES
                                                
                                                                            SELECT substr((current HOUR TO SECOND),1,2)||substr((current HOUR TO SECOND),4,2)|| LPAD(v_contador,2,0)
                                                                            INTO v_fecha_folio FROM bdicred:sd_fechas;
                                                                            LET pFolioSuacSUC = trim(v_fecha_folio)||lpad(e_folio_csuac,10,0);
                                                                            --==== SELECCIONA LA TRANSACCION DE ABONO mediante tipo_movimiento

                                                                            SELECT trans_no_procede 
                                                                            INTO p_transacc
                                                                            FROM acl_tipo_movimiento 
                                                                            WHERE pky_tipo_movimiento=(
                                                                            SELECT fky_tipo_movimiento FROM acl_movimiento 
                                                                            WHERE folio_csuac = e_folio_csuac and cargo = 1 and exitoso = 0 and duplicado=1 and fky_padre is null);      

                                                                            LET i_val_tmpA = linea_disponible;
                                                                                
    
                                                                            LET s_AfectacionA = i_val_tmpA; --> Saldo de salida de ABONO afectada
                                                                            LET p_Monto = i_val_tmpA;

                                                                            LET i_val_tmpA = (i_abono_recuperado + i_val_tmpA); --Suma abono recuperado + afectado

                                                                        

                                                                              call bdicred:sp_cargo_abono_aclara(eEmpresa, i_val_cuenta, CnumTarjeta, p_monto, user, '9250',p_transacc,1 ,pFolioSuacSUC)
                                                                              RETURNING CCodret_c, CMensaje;

                                                                              
                                                      IF (CCodret_c is not null) THEN
                                                        COMMIT WORK;
                                                      END IF;
                                                                              
                                                                              IF(CCodret_c <> "000") THEN
                                                                                --ROLLBACK WORK;
                                                                                COMMIT WORK;
                                                                                LET wBegin = "S";
                                                                                --IF (wBegin = "S") THEN
                                                                                  --  BEGIN WORK;
                                                                                --END IF;
                                                                             END IF;  
                                                                                
                                                                            --LET s_CodRet ='000'; ----- PRUEBAS
                                                                            
                                                                          

                                                                            IF (CCodret_c=='000') THEN 
                                                                            --LET s_Ca = 1;
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
                                                                                                                       -- s_Ca,  i_exito_cc,i_exito_ci,23)RETURNING s_CodRet, s_Mensaje2;
                                                            0,  
                                                            i_exito_cc,
                                                            i_exito_ci,
                                                            i_exito_cin,
                                                            22)
                                                      RETURNING s_CodRet, s_Mensaje2; 
                                                                            LET s_CodleyendaA = 'CPA'; --> Mensaje de salida de comision afectada total
                                                                                -- ACTUALIZA MOVIMIENTO                 
                            
                                                                                update "informix".acl_movimiento set exitoso = 0,fecha_afectacion  = CURRENT, monto_recuperacion = (i_val_tmpA)   
                                                                                where cargo=1 
                                                                                and exitoso = 0 
                                                                                and fky_padre is null 
                                                                                and duplicado = 1 
                                                                                and folio_csuac=e_folio_csuac;
                                                                                -- FINALIZA ACTUALIZA MOVIMIENTO
                                                                                --ACTUALIZA ACLARACION 
                                                                                UPDATE "informix".acl_aclaracion SET fky_estatus_flujo_causa = 22 WHERE folio_csuac = e_folio_csuac AND pky_aclaracion = i_fky_aclaracion;

                                                                         LET vRecuperoAbono = 1;

                                                                         END IF; -- TERMINA VALIDACION SP CARGO ABONO   

                                            
                                                              END IF; --COBROS PARCIALES ****************         


                      END IF;   --> FIN NÃºmero 31 */
                                    --********************************************************************************************************************
                                                
                                       END IF; --> FIN NÃºmero 30

                             ELSE --> INTERMEDIO NÃºmero 29

                             END IF; --> FIN NÃºmero 29
 
            END IF; --> FIN NÃºmero 2    

    END IF; --> FIN NÃºmero 1    

    LET i_pky_recuperacion = (SELECT max (pky_recuperacion) FROM "informix".acl_recuperacion_saldos WHERE folio_csuac = e_folio_csuac);

    SELECT  exito_ca, exito_cc, exito_ci, exito_cin
    INTO i_val_exito_ca, i_val_exito_ci,i_val_exito_cc, i_val_exito_cin 
    FROM "informix".acl_recuperacion_saldos 
    WHERE folio_csuac = e_folio_csuac AND pky_recuperacion = i_pky_recuperacion;

    IF (i_val_exito_ca == 1) AND (i_val_exito_ci == 1) AND (i_val_exito_cc  ==1) AND (i_val_exito_cin  ==1)  THEN --> INICIA NÃºmero 34

        UPDATE "informix".acl_recuperacion_saldos 
        SET  cron_activo= 0,fky_estatus_corporativo = 23   
        WHERE folio_csuac = e_folio_csuac AND fky_aclaracion = i_fky_aclaracion;  

        UPDATE "informix".acl_aclaracion -- Actualizar estatus de aclaraciÃ³n una vez recuperado todos los saldos
        SET fky_estatus_corp_general = 6,  fky_estatus_flujo_causa = 23
        WHERE folio_csuac = e_folio_csuac AND pky_aclaracion = i_fky_aclaracion;

    --DESBLOQUEO CUENTA CREDITO
    CALL bdicred:sp_desbloqueocuenta (eEmpresa,i_val_cuenta,'0','1') RETURNING s_CodRet, s_Mensaje2;

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
            CALL sp_aplicar_cancelacion_por_recuperacion_credDeb(e_folio_csuac,'0') RETURNING cod_ret_bloq,s_Mensaje;
        END IF;
        --------------------------------------------------------------------------------------------------------------------------------------
        -- FIN MODIFICACION: RBU. FLUJO PARA INTENTAR CANCELAR
        --------------------------------------------------------------------------------------------------------------------------------------
    
  ELSE
    --Bloqueo de cuenta
    LET pmotivobloq = '10';
    
    CALL bdicred:sp_bloqueocuenta (eEmpresa,i_val_cuenta,'3',pmotivobloq,'0','1') RETURNING s_CodRet, s_Mensaje2;
    

    END IF; --> INICIA Numero 34

    IF (s_CodleyendaC == 'NA') AND (s_CodleyendaI == 'NA') AND (s_CodleyendaA == 'NA') AND (s_CodleyendaIn == 'NA') THEN   --> INICIA NÃºmero 35
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
  IF vRecuperoAbono = 1 THEN
    LET s_CodRet = '000000'; 
    LET s_Mensaje = 'AfectaciÃ³n exitosa'; 
  END IF;
  IF vRecuperoComIVA = 1 THEN
    LET s_CodRet = '000000'; 
    LET s_Mensaje = 'AfectaciÃ³n exitosa'; 
  END IF;


RETURN s_CodRet,s_Mensaje, s_Cc, s_AfectacionC, s_CodleyendaC, s_Ci, s_AfectacionI, s_CodleyendaI, s_Ca, s_AfectacionA, s_CodleyendaA, s_Cin, s_AfectacionIn, s_CodleyendaIn; 
END;
        
END PROCEDURE;