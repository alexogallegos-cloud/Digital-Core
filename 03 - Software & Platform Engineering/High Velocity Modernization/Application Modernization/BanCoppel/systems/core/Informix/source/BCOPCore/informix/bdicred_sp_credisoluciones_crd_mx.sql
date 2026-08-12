CREATE PROCEDURE "informix".sp_credisoluciones_crd_mx(pempresa CHAR(3), pproducto CHAR(4))
   RETURNING CHAR(6), CHAR(80);

DEFINE iSqlErr                       INTEGER;
DEFINE iIsamErr                      INTEGER;
DEFINE cErrorInfo                    CHAR(100);
DEFINE CodRet                        CHAR(6);
DEFINE Mensaje                       CHAR(80);
DEFINE cNumCreditocrd                CHAR(20);
DEFINE cCredito_promo                CHAR(20);
DEFINE cfolio_suc_promo              CHAR(16);
DEFINE cfolio_mov_promo              CHAR(16);
DEFINE dtFechaHoy                    DATE;
DEFINE dtFechaMesiversario  DATE;
DEFINE vdia_corte_cs        INTEGER;
DEFINE vmto_finan_cs        DECIMAL(14,2);
DEFINE v_capital_cs			DECIMAL(14,2);
DEFINE v_interes_cs         DECIMAL(14,2);
DEFINE v_iva_cs             DECIMAL(14,2);
DEFINE v_capitalori_cs      DECIMAL(14,2);
DEFINE v_total_cap_cs       DECIMAL(14,2);
DEFINE v_total_mto_cs       DECIMAL(14,2);
DEFINE v_mto_pag_cs         DECIMAL(14,2);
DEFINE cFolio               CHAR(16);
DEFINE cBegin               CHAR(1);
DEFINE credcontproc         CHAR(1);
DEFINE intecontproc         CHAR(1);
DEFINE vcproceso            CHAR(15);
DEFINE vcargoserr           SMALLINT;
DEFINE  vlStatusCred        CHAR(2);
DEFINE wBegin               CHAR(1);
DEFINE wTran                SMALLINT;
DEFINE wErr                 SMALLINT;
--FMV 21JUL14: Se reaseigna valor de la variable
DEFINE GLOBAL g_dtFechaHoy           DATE           DEFAULT "";

LET vlStatusCred    = '';
LET wTran=0;
LET wErr=0;
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
          LET CodRet     = iSqlErr;
          LET Mensaje = cErrorInfo;

      ROLLBACK WORK;

	 IF (wBegin = "S") THEN
         BEGIN WORK;
     END IF;
	 
	 INSERT INTO "informix".sd_log_cobroaut (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
      VALUES ('06','CobroAutCs_Ex',dtFechaHoy,current,'informix',cNumCreditocrd,'',wErr,'',v_iva_cs,CodRet,'',cErrorInfo);

	  UPDATE "informix".sd_contproc
		 SET status_proc = "C",
			 hora_fin    = CURRENT,
			 cod_ret     = CodRet,
			 mensaje     = Mensaje
	   WHERE empresa     = pempresa
		 AND proceso     = vcproceso
		 AND fecha       = dtFechaHoy;

	  UPDATE bdinteg:sx_contproc
		 SET status_proc = "C",
			 hora_fin    = CURRENT,
			 codret      = CodRet
	   WHERE empresa     = pempresa
		 AND proceso     = vcproceso
		 AND fecha       = dtFechaHoy;

       RETURN CodRet,Mensaje;
   END IF;
END EXCEPTION;

ON EXCEPTION IN (-535)
      LET wBegin = "S";
      COMMIT WORK;
--      BEGIN WORK;
   END EXCEPTION WITH RESUME;

LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET CodRet              = "000000";
LET Mensaje   = "Se realizó el proceso exitosamente";
LET cNumCreditocrd      = '';
LET cCredito_promo      = '';
LET cfolio_suc_promo    = '';
LET cfolio_mov_promo    = '';
LET dtFechaHoy          = DATE(1);
LET dtFechaMesiversario = DATE(1);
LET cCredito_promo = "";
LET vdia_corte_cs    = 0;
LET vmto_finan_cs    = 0;
LET v_capital_cs     = 0;
LET v_interes_cs     = 0;
LET v_iva_cs         = 0;
LET v_capitalori_cs  = 0;
LET v_total_cap_cs   = 0;
LET v_total_mto_cs   = 0;
LET v_mto_pag_cs     = 0;
LET cfolio_suc_promo = "";
LET cfolio_mov_promo = "";
LET cFolio           = "";
LET cBegin           = "N";
LET credcontproc     = "";
LET intecontproc     = "";
LET vcproceso        = "CobrCredsol-CRD";
LET vcargoserr       = 0;


-- SET DEBUG FILE TO "/tmp/sp_credisoluciones_crd18092019.out";
-- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    --SET PDQPRIORITY 10;
	
	LET wBegin = "N";
    BEGIN WORK;
	IF (wBegin = "N") THEN
		COMMIT WORK;
	END IF;

        SELECT a.fecha_hoy, USER||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(CURRENT,3,2)
                                ||SUBSTR(CURRENT,12,2)||SUBSTR(CURRENT,15,2)
                                ||SUBSTR(CURRENT,18,2)
          INTO dtFechaHoy, cFolio
          FROM "informix".sd_fechas a
         WHERE a.empresa = pempresa;

          --FMV 21Jul14: Reasignacion de la variable global para generar los movimientos en la fecha correcta.
          LET g_dtFechaHoy = dtFechaHoy;


        SELECT status_proc
          INTO intecontproc
          FROM bdinteg:sx_contproc
         WHERE fecha= dtFechaHoy
           AND proceso = vcproceso;

        SELECT status_proc
          INTO credcontproc
          FROM bdicred:sd_contproc
         WHERE fecha= dtFechaHoy
           AND proceso = vcproceso;
		   
		BEGIN WORK;
			IF (intecontproc IS NULL) THEN
			  INSERT INTO bdinteg:"informix".sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret)
			  VALUES ('001',vcproceso,dtFechaHoy,'06','I','informix',CURRENT,CURRENT,'000');
			ELSE
			  DELETE FROM bdinteg:"informix".sx_contproc
					WHERE empresa = '001'
					  AND proceso = vcproceso
					  AND fecha = dtFechaHoy;
			  INSERT INTO bdinteg:"informix".sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret)
			  VALUES ('001',vcproceso,dtFechaHoy,'06','I','informix',CURRENT,CURRENT,'000');
			END IF;

			IF (credcontproc IS NULL) THEN
				INSERT INTO  bdicred:"informix".sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
				VALUES ('001',vcproceso,dtFechaHoy,'I','informix',CURRENT,CURRENT,'000','Iniciamos');
			ELSE
				DELETE FROM bdicred:"informix".sd_contproc
					  WHERE empresa = '001'
						AND proceso = vcproceso
						AND fecha = dtFechaHoy;
				INSERT INTO  bdicred:"informix".sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
				VALUES ('001',vcproceso,dtFechaHoy,'I','informix',CURRENT,CURRENT,'000','Iniciamos');
			END IF;

			DELETE FROM "informix".sd_log_cobroaut
				  WHERE proceso = 'CobroAutCs'
					AND fecha_proceso = dtFechaHoy
					AND num_credito > '690000000000';
		COMMIT WORK;
		
    FOREACH WITH HOLD  --FMV 15JUL14: Se adiciona with hold, ya que solo cobraba 1 credisolucion en vencimiento.
        SELECT  a.num_credito,
           fecha_cuota,
           sum(capital_debe - capital_pagado) + SUM(interes_debe - interes_pagado) + SUM(iva_debe -iva_pagado),
           sum(capital_debe - capital_pagado),
           SUM(interes_debe - interes_pagado),
           SUM(iva_debe -iva_pagado)
        INTO cNumCreditocrd,
           dtFechaMesiversario,
           v_mto_pag_cs,
           v_capital_cs,
           v_interes_cs,
           v_iva_cs
        FROM bdicred:sd_maecredcrd a,
           bdicred:sd_amortiza_creditocrd b
        WHERE a.empresa = pempresa
        AND a.empresa = b.empresa
        AND a.num_credito = b.num_credito
        AND a.num_producto = pproducto
        AND a.status_cred IN ('AA','E1')
        AND capital_status = '1'
        group by 1,2


        SELECT a.num_credito,a.folio_suc,a.folio_movto, c.prox_fecha_pago
        INTO cCredito_promo,cfolio_suc_promo,cfolio_mov_promo,dtFechaMesiversario
        FROM bdicred:sd_promocion_credito a, bdicred:sd_maecredcrd b, bdicred:sd_maecredanexocrd c, bdicred:sd_maecred d
        WHERE a.empresa = pempresa
        AND a.empresa = b.empresa
        AND a.empresa = c.empresa
        and a.num_sol_prestamo = cNumCreditocrd
        AND a.num_credito=d.num_credito
        AND a.num_sol_prestamo = b.num_credito
        AND a.num_sol_prestamo = c.num_credito
        AND num_pro_prestamo = pproducto
        AND a.status = 2
        --AND b.status_cred = 'AA'
        AND d.status_cred IN ('AA','BA','E1');

		BEGIN WORK;
		
        IF ( cCredito_promo is not null ) THEN

            --SE REALIZA EL PAGO POR EL MONTO CORRESPONDIENTE AL MES CORRIENTE DE CREDISOLUCIONES
            --FMV & FMJ 18ago14: Se adiciona al parametros de referencia del sp_cargo_abono_palzo el numero de credisolucion para agrupar movtos en Edos_ctas
            

            IF v_mto_pag_cs > 0 THEN
                CALL "informix".sp_cargo_abono_palzo(pempresa,cNumCreditocrd,'',v_mto_pag_cs,USER,'9290','4230',2,cNumCreditocrd) --FMV 18Ago14
                   RETURNING CodRet, Mensaje;
                IF (CodRet <> "000000") THEN
                    LET CodRet      = "000016";
                    LET Mensaje = "Ocurrió un error realizar el pago mensual de credisoluciones";
                    ROLLBACK WORK;
                    INSERT INTO "informix".sd_log_cobroaut (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
                    VALUES ('06','CobroAutCs',dtFechaHoy,current,'informix',cNumCreditocrd,'','','monto pago',v_mto_pag_cs,CodRet,'','monto pago '||Mensaje);
                    RETURN CodRet,Mensaje;
                ELSE
                    INSERT INTO "informix".sd_log_cobroaut (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
                    VALUES ('06','CobroAutCs',dtFechaHoy,current,'informix',cNumCreditocrd,'','','monto pago',v_mto_pag_cs,CodRet,'','Pago Exitoso');
                END IF;

                IF v_iva_cs <> 0 THEN
                    CALL "informix".sp_cargo_abono_palzo(pempresa,cCredito_promo,'',v_iva_cs,USER,'9290','4202',1,cNumCreditocrd)
                        RETURNING CodRet, Mensaje;
                    IF (CodRet <> "000000") THEN
                           LET CodRet      = "000016";
                           LET Mensaje = "Ocurrió un error realizar el cargo de iva credisoluciones";
                           ROLLBACK WORK;
                           INSERT INTO "informix".sd_log_cobroaut (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
                                VALUES ('06','CobroAutCs',dtFechaHoy,current,'informix',cNumCreditocrd,'','','iva pago',v_iva_cs,CodRet,'','iva '||Mensaje);
                           RETURN CodRet,Mensaje;
                    END IF;

                    INSERT INTO "informix".sd_log_cobroaut (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
                         VALUES ('06','CobroAutCs',dtFechaHoy,current,'informix',cNumCreditocrd,'','','iva pago',v_iva_cs,CodRet,'','Pago Exitoso');

                    IF EXISTS(SELECT monto FROM bdicred:sd_maeretenido WHERE empresa = '001'
                              AND num_credito = cCredito_promo AND folio_suc = cfolio_mov_promo AND estatus = 'R') THEN                      
                                    UPDATE bdicred:sd_maeretenido
                                       SET monto = monto - v_iva_cs
                                    WHERE empresa = '001'
                                      AND num_credito = cCredito_promo
                                      AND folio_suc = cfolio_mov_promo
                                      AND estatus = 'R';
                    ELSE
                                    UPDATE bdicred:sd_maeretenido
                                       SET monto = monto - v_iva_cs
                                    WHERE empresa = '001'
                                      AND num_credito = cCredito_promo
                                      AND folio_suc = cfolio_suc_promo 
                                      AND estatus = 'R';
                    END IF;
                    UPDATE bdicred:sd_maesdos
                       SET sdo_retenido = sdo_retenido - v_iva_cs
                     WHERE empresa = '001'
                       AND num_credito = cCredito_promo;

                    UPDATE bdicred:sd_promocion_credito
                       SET monto_int_iva = monto_int_iva - v_iva_cs
                     WHERE empresa = '001'
                       AND num_sol_prestamo = cNumCreditocrd;
                END IF;

                IF v_interes_cs <> 0 THEN
                    CALL "informix".sp_cargo_abono_palzo(pempresa,cCredito_promo,'',v_interes_cs,USER,'9290','4201',1,cNumCreditocrd)
                            RETURNING CodRet, Mensaje;
                        IF (CodRet <> "000000") THEN
                               LET CodRet      = "000016";
                               LET Mensaje = "Ocurrió un error realizar el cargo de interes credisoluciones";
                               ROLLBACK WORK;
                               INSERT INTO "informix".sd_log_cobroaut (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
                               VALUES ('06','CobroAutCs',dtFechaHoy,current,'informix',cNumCreditocrd,'','','interes pago',v_interes_cs,CodRet,'','interes '||Mensaje);
                               RETURN CodRet,Mensaje;
                        END IF;

                        INSERT INTO "informix".sd_log_cobroaut (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
                             VALUES ('06','CobroAutCs',dtFechaHoy,current,'informix',cNumCreditocrd,'','','interes pago',v_interes_cs,CodRet,'','Pago Exitoso');

                        IF CodRet = "000000" THEN
                            IF EXISTS(SELECT monto FROM bdicred:sd_maeretenido WHERE empresa = '001'
                              AND num_credito = cCredito_promo AND folio_suc = cfolio_mov_promo AND estatus = 'R') THEN 
                                UPDATE bdicred:sd_maeretenido
                                  SET monto = monto - v_interes_cs
                                WHERE empresa = '001'
                                  AND num_credito = cCredito_promo
                                  AND folio_suc = cfolio_mov_promo
                                  AND estatus = 'R';
                            ELSE
                                UPDATE bdicred:sd_maeretenido
                                  SET monto = monto - v_interes_cs
                                WHERE empresa = '001'
                                  AND num_credito = cCredito_promo
                                  AND folio_suc = cfolio_suc_promo --cfolio_mov_promo
                                  AND estatus = 'R';
                            END IF;

                           UPDATE bdicred:sd_maesdos
                              SET sdo_retenido = sdo_retenido - v_interes_cs
                            WHERE empresa = '001'
                              AND num_credito = cCredito_promo;

                           UPDATE bdicred:sd_promocion_credito
                              SET monto_int_iva = monto_int_iva - v_interes_cs
                            WHERE empresa = '001'
                              AND num_sol_prestamo = cNumCreditocrd;
                       END IF;
                END IF;

                IF v_capital_cs <> 0 THEN
                    CALL "informix".sp_cargo_abono_palzo(pempresa,cCredito_promo,'',v_capital_cs,USER,'9290','4200',1,cNumCreditocrd)
                        RETURNING CodRet, Mensaje;
                    IF (CodRet <> "000000") THEN
                           LET CodRet      = "000016";
                           LET Mensaje = "Ocurrió un error realizar el cargo de iva credisoluciones";
                           ROLLBACK WORK;
                           INSERT INTO "informix".sd_log_cobroaut (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
                           VALUES ('06','CobroAutCs',dtFechaHoy,current,'informix',cNumCreditocrd,'','','capital_pago',v_capital_cs,CodRet,'','capital '||Mensaje);
                           RETURN CodRet,Mensaje;
                    END IF;

                    INSERT INTO "informix".sd_log_cobroaut (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
                         VALUES ('06','CobroAutCs',dtFechaHoy,current,'informix',cNumCreditocrd,'','','capital_pago',v_capital_cs,CodRet,'','Pago Exitoso');

                    IF CodRet = "000000" THEN
                       UPDATE bdicred:sd_maeretenido
                          SET monto = monto - v_capital_cs
                        WHERE empresa = '001'
                          AND num_credito = cCredito_promo
                          AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
                          AND nvl(substr(referencia,1,16),'') <> folio_suc;

                       UPDATE bdicred:sd_maesdos
                          SET sdo_retenido = sdo_retenido - v_capital_cs
                        WHERE empresa = '001'
                          AND num_credito = cCredito_promo;

                        UPDATE bdicred:sd_promocion_credito
                           SET monto_actual = monto_actual - v_capital_cs
                         WHERE empresa = '001'
                           AND num_sol_prestamo = cNumCreditocrd;
                    END IF;
                END IF;
            ELIF v_mto_pag_cs IS NULL OR v_mto_pag_cs = '' THEN
                IF EXISTS (SELECT * FROM "informix".sd_log_cobroaut
                                WHERE proceso = 'CobroAutCs'
                                  AND fecha_proceso = dtFechaHoy
                                  AND num_credito = cNumCreditocrd ) THEN
                        DELETE FROM "informix".sd_log_cobroaut
                              WHERE proceso = 'CobroAutCs'
                                AND fecha_proceso = dtFechaHoy
                                AND num_credito = cNumCreditocrd;
                    INSERT INTO "informix".sd_log_cobroaut (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
                         VALUES ('06','CobroAutCs',dtFechaHoy,current,'informix',cNumCreditocrd,'','','',v_capital_cs,CodRet,'','Monto Pago null');
                ELSE
                    INSERT INTO "informix".sd_log_cobroaut (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
                        VALUES ('06','CobroAutCs',dtFechaHoy,current,'informix',cNumCreditocrd,'','','',v_capital_cs,CodRet,'','Monto Pago null');
                END IF;
                LET vcargoserr = 1;
            END IF;
        END IF;

        ----Seccion para Quitar Retenido Excedente
        SELECT status_cred INTO vlStatusCred 
        FROM bdicred:sd_maecredcrd 
        WHERE num_credito = cNumCreditocrd;

        IF vlStatusCred = 'FF' THEN
            LET wErr=1;
            IF EXISTS(select monto FROM bdicred:sd_maeretenido                         
                WHERE empresa = '001' AND num_credito = cCredito_promo 
                AND folio_suc = cfolio_mov_promo
                AND estatus = 'R') THEN

                select  monto into  v_iva_cs
                FROM bdicred:sd_maeretenido                         
                WHERE empresa = '001'
                 AND num_credito = cCredito_promo
                 AND folio_suc = cfolio_mov_promo
                 AND estatus = 'R';
            ELSE
                select  monto into  v_iva_cs
                FROM bdicred:sd_maeretenido                         
                WHERE empresa = '001'
                 AND num_credito = cCredito_promo
                 AND folio_suc = cfolio_suc_promo --cfolio_mov_promo
                 AND estatus = 'R';
            END IF;
             
             LET wErr=2;
            UPDATE bdicred:sd_maesdos
            SET sdo_retenido = sdo_retenido - nvl(v_iva_cs,0)
            WHERE empresa = '001'
             AND num_credito = cCredito_promo;

             LET wErr=3;
            UPDATE bdicred:sd_promocion_credito
             SET monto_int_iva = monto_int_iva - nvl(v_iva_cs,0), status = 6
            WHERE empresa = '001'
             AND num_sol_prestamo = cNumCreditocrd;

             
             LET wErr=4;
           IF EXISTS(select monto FROM bdicred:sd_maeretenido                         
             WHERE empresa = '001' AND num_credito = cCredito_promo 
               AND folio_suc = cfolio_mov_promo
               AND estatus = 'R') THEN

                UPDATE bdicred:sd_maeretenido
                 SET monto = 0
                WHERE empresa = '001'
                 AND num_credito = cCredito_promo
                 AND folio_suc = cfolio_mov_promo
                 AND estatus = 'R';   
            ELSE
                UPDATE bdicred:sd_maeretenido
                 SET monto = 0
                WHERE empresa = '001'
                 AND num_credito = cCredito_promo
                 AND folio_suc = cfolio_suc_promo --cfolio_mov_promo
                 AND estatus = 'R';
           END IF;
        END IF;

        LET cfolio_suc_promo = "";
        LET cfolio_mov_promo = "";
        LET v_capital_cs	 = 0;
        LET v_interes_cs     = 0;
        LET v_iva_cs         = 0;
        LET v_mto_pag_cs     = 0;
		COMMIT WORK;

    END FOREACH;


    LET CodRet = "000000";
    LET Mensaje   = "Se realizó el proceso exitosamente";

    IF vcargoserr <> 0 THEN
        LET CodRet = "000001";
        LET Mensaje = "Error en algun(os) pagos credisoluciones";
    END IF;


    UPDATE "informix".sd_contproc
           SET status_proc = "F",
               hora_fin    = CURRENT,
               cod_ret     = CodRet,
               mensaje     = Mensaje
         WHERE empresa     = pempresa
           AND proceso     = vcproceso
           AND fecha       = dtFechaHoy;

    UPDATE bdinteg:sx_contproc
           SET status_proc = "F",
               hora_fin    = CURRENT,
               codret      = CodRet
         WHERE empresa     = pempresa
           AND proceso     = vcproceso
           AND fecha       = dtFechaHoy;

		   
    IF (wBegin = "S") THEN		   
		BEGIN WORK;
	END IF;
		   
	RETURN CodRet,Mensaje;

END;
END PROCEDURE;