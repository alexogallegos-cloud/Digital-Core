CREATE PROCEDURE "informix".sp_cobro_automatico_pp_6400(pempresa  char(3))
RETURNING  CHAR(5)        AS cod_ret,       
           CHAR(125)      AS mens_ret

DEFINE iSqlErr                       INTEGER;
DEFINE iIsamErr                      INTEGER;
DEFINE cErrorInfo                    CHAR(80);
DEFINE cCodRet                       CHAR(5);
DEFINE cCodRetCtrl                   CHAR(5);
DEFINE cCodRetAux                    CHAR(6);
DEFINE cMensajeRet                   CHAR(125);
DEFINE cMensaje                      CHAR(125);
DEFINE DecAux                        DECIMAL(18,2);
DEFINE ChaAux                        CHAR(20);
DEFINE dMontoInt                     DECIMAL(18,2);
DEFINE dCuentaCap                    CHAR(20);

DEFINE dAplicaReverso                INTEGER;
DEFINE dSeAplicoReverso              INTEGER;
DEFINE dMontoPag                     DECIMAL(18,2); 

DEFINE credcontproc                  CHAR(1);
DEFINE intecontproc                  CHAR(1);
DEFINE dtFechaHoy                    DATE;

DEFINE vcproceso                    CHAR(15); --FMV 29-FEB-2012
DEFINE vcprocesoM1                  CHAR(15); 
--------------------------------------------------------------------------------------------

DEFINE TOTdMontoIntMora 			DECIMAL(18,2);
DEFINE dMontoIntMoraIva 			DECIMAL(18,2);
DEFINE TOTdMontoIntMoraIVA 			DECIMAL(18,2);
DEFINE TOTdMontoInt 				DECIMAL(18,2);
DEFINE dMontoIntMora				DECIMAL(18,2);

--------------------------------------------------------------------------------------------
--Juan Roman Velazquez Toledo 05/01/2021
DEFINE vExiste              SMALLINT;
--------------------------------------------------------------------------------------------
----------------------- Datos General --------------------------------
DEFINE GLOBAL g_Empresa              CHAR(3)        DEFAULT "001";
DEFINE GLOBAL g_NumCred              CHAR(20)       DEFAULT "";
DEFINE GLOBAL g_Sucursal             CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_NumProd              CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_Divisa               CHAR(2)        DEFAULT "";
DEFINE GLOBAL g_dtFechaHoy           DATE           DEFAULT "";
DEFINE GLOBAL g_CodFun               CHAR(3)        DEFAULT "";
DEFINE GLOBAL g_Folio                CHAR(16)       DEFAULT "";
DEFINE GLOBAL g_TransaccSuc          CHAR(4)        DEFAULT "0000";

DEFINE GLOBAL g_StatusCred           CHAR(2)        DEFAULT "";
DEFINE GLOBAL g_montofinanciado      MONEY(14,2)  DEFAULT 0;
DEFINE GLOBAL g_FechaApertura        DATE           DEFAULT "";
DEFINE GLOBAL g_FechaProxPago        DATE           DEFAULT "";
DEFINE GLOBAL g_MontoVencido         MONEY(14,2)  DEFAULT 0;
DEFINE GLOBAL g_SdoTrasp             DECIMAL(18,2)  DEFAULT 0;
DEFINE GLOBAL g_IvaSuc               DECIMAL(5,3)   DEFAULT 0;
DEFINE GLOBAL g_Cuentamens           INTEGER        DEFAULT 0;
DEFINE GLOBAL g_ProvIntFinMes        DECIMAL(18,2)  DEFAULT 0;
DEFINE GLOBAL g_ProvIvaFinMes        DECIMAL(18,2)  DEFAULT 0;
DEFINE  dtFVenta                     DATE;
DEFINE g_campo_trab3                 CHAR(10);
DEFINE  vlFechaBaja                  DATE;
DEFINE v_existeM1                   INTEGER;

DEFINE wbandera_apoyo				INT;
DEFINE numcte_apoyo					CHAR(9);
DEFINE cIdUnidadProd				INTEGER;
DEFINE vcprocesoADN					CHAR(15);
DEFINE cNumeroFolio					CHAR(16);
--RQM 09704 
DEFINE cActRetenido					CHAR(1);
DEFINE dMontoRetenido				DECIMAL(18,2);
DEFINE dPagoMinAct					DECIMAL(18,2);
DEFINE Val_existe					SMALLINT;
DEFINE cfolio_adn                   CHAR (16);
DEFINE xsiretencion                 CHAR (1);

DEFINE mMontoRetenidoCtrl			MONEY(14,2);
DEFINE mMontoPendientexPagar 		MONEY(14,2);
DEFINE mPendienteARetener	 		MONEY(14,2);
DEFINE cCodRetSpReten				CHAR(5);
DEFINE cMensajeRetSpReten			CHAR(150);
DEFINE cEstatus                 	INTEGER; 

--------------------------------------------------------------------------------------------


LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = "";
LET cCodRet               = "00000";
LET cCodRetCtrl           = "00000";
LET cMensajeRet           = "Se realizo el pago correctamente";
LET cMensaje           	  = "Se realizo el Proceso correctamente";
LET cCodRetAux            = "000000";
LET dCuentaCap            = "";
LET dAplicaReverso        = 0;
LET dSeAplicoReverso      = 0;
LET dMontoPag             = 0;
LET credcontproc          = " ";
LET intecontproc          = " ";
LET g_ProvIntFinMes       = 0;
LET g_ProvIvaFinMes       = 0;
LET dtFVenta              = DATE(1);
LET g_campo_trab3         = '';
LET vlFechaBaja           = DATE(1);

LET vcproceso = 'CobroautoPP'|| '-' || trim('6400');  -- ELS 05-Nov-24
LET vcprocesoM1 = trim(vcproceso)|| '1';	
-----------------------------------------------------------------------
LET TOTdMontoIntMora = 0;
LET dMontoIntMoraIva = 0;
LET TOTdMontoIntMoraIVA = 0;
LET TOTdMontoInt = 0;
LET dMontoIntMora=0;
LET v_existeM1 = 0;

LET wbandera_apoyo = 0;
LET numcte_apoyo = '';
LET vExiste = 0;

LET cIdUnidadProd 		= NULL;
LET vcprocesoADN 		= '';
LET cNumeroFolio 		= '';
--RQM 09704 
LET cActRetenido 		= '0';
LET dMontoRetenido 		= 0;
LET dPagoMinAct  		= 0;
LET Val_existe 			= 0;
LET xsiretencion        ='F';

LET mMontoRetenidoCtrl    = 0.00;
LET mMontoPendientexPagar = 0.00;
LET mPendienteARetener    = 0.00;
LET cCodRetSpReten		  ='00000';
LET cMensajeRetSpReten	  ='';
LET cEstatus              =0;

LET cfolio_adn			='';

BEGIN


ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensaje = cErrorInfo;
   END IF;
          UPDATE "informix".sd_contproc
             SET status_proc = "C",
                 hora_fin    = CURRENT,
                 cod_ret     = cCodRet,
                 mensaje     = cMensaje
           WHERE empresa     = pempresa
             AND proceso     = vcproceso
             AND fecha       = dtFechaHoy;

          UPDATE bdinteg:sx_contproc
             SET status_proc = "C",
                 hora_fin    = CURRENT,
                 codret      = cCodRet
           WHERE empresa     = pempresa
             AND proceso     = vcproceso
             AND fecha       = dtFechaHoy;
		
			DROP TABLE IF EXISTS tmp_creditos_cobr_6400;
			DROP TABLE IF EXISTS tmp_creditos_cobr_7800;
			DROP TABLE IF EXISTS pa_sucursales;

      RETURN cCodRet,cMensaje;

END EXCEPTION;




--	SET DEBUG FILE TO "/ifxsif01/sp_cobro_automatico_6400.out";
 
--	TRACE ON;
 

    set isolation to dirty read;
    set lock mode to wait 3;

    SELECT fecha_hoy 
		INTO dtFechaHoy
    FROM sd_fechas
    WHERE empresa=pempresa;
     
	--LET dtFechaHoy='11032019';
	
-- Creo: Eduardo Lira Silva
-- Fecha: 25/09/2024
-- Comentario: Se crea para separar el cobro normal del Producto 6400 del cobro automatico
-- *******************************************************
-- *         INSERTA PARA EJECUCION DE PROCESO           *
-- *******************************************************
-- INI CAS

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

    IF (intecontproc = 'I') THEN
		LET cMensaje="EXISTE UN PROCESO PREVIO EN EJECUCION";
        RETURN cCodRet,cMensaje;
    END IF;	 

    IF (intecontproc IS NULL) THEN
		INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
		VALUES ('001',vcproceso,dtFechaHoy,'06','I','informix',CURRENT,CURRENT,'000');
	ELSE 
		UPDATE bdinteg:sx_contproc 
			SET status_proc='I'
		WHERE fecha= dtFechaHoy 
		AND proceso =vcproceso;
    END IF;

	IF (credcontproc IS NULL) THEN
		INSERT INTO  sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
		VALUES ('001',vcproceso,dtFechaHoy,'I','informix',CURRENT,CURRENT,'000','Iniciamos');
    ELSE
		UPDATE bdicred:sd_contproc 
			SET status_proc='I' ,mensaje = 'Iniciamos'
		WHERE fecha= dtFechaHoy 
		AND proceso =vcproceso;
	END IF;
    	
--FIN CAS

    set isolation to dirty read;
    set lock mode to wait 3;

	
    SELECT
        'cobroapp'||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(current,3,2)||
        SUBSTR(CURRENT,12,2)||substr(current,15,2)
        ||SUBSTR(current,18,2)
    INTO g_Folio
    FROM dual;

	 SELECT
        'ANTICIPO'||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(current,3,2)||
        SUBSTR(CURRENT,12,2)||substr(current,15,2)
        ||SUBSTR(current,18,2)
    INTO cfolio_adn
    FROM dual;

    LET g_Empresa = pempresa;
	
	-- Se eliminan registros del dia anterior ya que el proceso corre cada hora y debemos de tener la bitacora del dia
    DELETE FROM sd_log_cobroaut WHERE fecha_proceso=dtFechaHoy-1 AND proceso IN ('Cobro6400', 'CobroautoA');

	DROP TABLE IF EXISTS pa_sucursales;

	
    SELECT {+INDEX (bdinteg:si_sucursales)}
		empresa,sucursal,iva FROM bdinteg:si_sucursales
    WHERE tpo_sucursal = "S"
    INTO TEMP pa_sucursales with no log;

    CREATE INDEX pasucursal on pa_sucursales (empresa, sucursal);
	
	DROP TABLE IF EXISTS tmp_creditos_cobr_6400;
	DROP TABLE IF EXISTS tmp_creditos_cobr_7800;
	
	SELECT --{+INDEX (sd_maesdoscrd)}
		a.num_credito, a.status_cred, a.sucursal, a.num_producto, a.divisa, 
		b.monto_financiado, a.fecha_apertura, (b.monto_vencido + b.mto_venc_trasp) MontoVencido, b.cap_tras_no_venci,
		b.provision_normal, b.sdo_global_int, a.campo_trab3, a.numcte, a.empresa
	FROM "informix".sd_maecredcrd a
	INNER JOIN "informix".sd_maesdoscrd b ON a.num_credito = b.num_credito
	--    INNER JOIN "informix".sd_maecredanexocrd c ON a.num_credito = c.num_credito
	--    INNER JOIN "informix".sd_ctascarg d ON a.num_credito = d.num_credito and d.naturaleza='A'
	--    INNER JOIN bdicheq:"informix".sc_maechq e ON d.num_cta = e.cuenta and e.sdo_actual > 0
	WHERE a.num_producto = '6400'
		AND a.status_cred NOT IN ('FF','FC','CV')  
		AND ((b.monto_financiado > 0 OR (b.monto_vencido + b.mto_venc_trasp) > 0)	
			OR (a.status_cred in ('E1','E2','E3') AND a.num_producto IN ('6400') AND b.sdo_cap_insoluto=0 ))
	INTO TEMP tmp_creditos_cobr_6400 with no log;
	
	CREATE INDEX numcredito_auto_6400 on tmp_creditos_cobr_6400 (num_credito,empresa);
	
	UPDATE STATISTICS MEDIUM FOR TABLE tmp_creditos_cobr_6400;
	
	--Revision de retenido
	SELECT activo_retenido INTO cActRetenido
	FROM "informix".sd_definicion
	WHERE num_producto = '6400';	
	
FOREACH WITH HOLD
	SELECT	a.num_credito, a.status_cred, a.sucursal, a.num_producto, a.divisa, c.fecha_proceso,
			a.monto_financiado, a.fecha_apertura, c.prox_fecha_pago, a.MontoVencido, a.cap_tras_no_venci,
			a.provision_normal, a.sdo_global_int, a.campo_trab3, a.numcte
		INTO g_NumCred, g_StatusCred, g_Sucursal, g_NumProd, g_Divisa, g_dtFechaHoy,
            g_montofinanciado,g_FechaApertura,g_FechaProxPago,g_MontoVencido,g_SdoTrasp,
            g_ProvIntFinMes, g_ProvIvaFinMes, g_campo_trab3, numcte_apoyo
	FROM tmp_creditos_cobr_6400 a
		INNER JOIN "informix".sd_maecredanexocrd c ON a.num_credito = c.num_credito AND a.empresa=c.empresa
		INNER JOIN "informix".sd_ctascarg d ON a.num_credito = d.num_credito AND d.naturaleza='A'
		INNER JOIN bdicheq:"informix".sc_maechq e ON d.num_cta = e.cuenta AND e.sdo_actual > 0
		
		
    /*SELECT {+INDEX (sd_maesdoscrd)}
		   a.num_credito,a.status_cred,a.sucursal,a.num_producto, a.divisa, c.fecha_proceso,
           b.monto_financiado,a.fecha_apertura,c.prox_fecha_pago,(b.monto_vencido + b.mto_venc_trasp),cap_tras_no_venci,
           provision_normal,sdo_global_int, a.campo_trab3,a.numcte
      INTO g_NumCred, g_StatusCred, g_Sucursal, g_NumProd, g_Divisa, g_dtFechaHoy,
             g_montofinanciado,g_FechaApertura,g_FechaProxPago,g_MontoVencido,g_SdoTrasp,
           g_ProvIntFinMes, g_ProvIvaFinMes, g_campo_trab3, numcte_apoyo
      FROM "informix".sd_maecredcrd a,
           "informix".sd_maesdoscrd b,
           "informix".sd_maecredanexocrd c,
           "informix".sd_ctascarg d,
            bdicheq:"informix".sc_maechq e
     WHERE a.empresa       = '001'
       AND a.status_cred   NOT IN ('FF','FC','CV')
       AND b.empresa       = a.empresa
       AND b.num_credito   = a.num_credito
       AND c.num_credito   = b.num_credito
       AND c.empresa       = b.empresa
       AND a.num_producto  NOT IN ('6011','6900','8600','8900')
       AND a.num_credito = d.num_credito
       AND d.naturaleza='A'
       AND e.cuenta = d.num_cta
       AND ((monto_financiado > 0 OR (b.monto_vencido + b.mto_venc_trasp) > 0)	
	   		OR (a.status_cred in ('E1','E2','E3') AND a.num_producto IN ('7600','7700','6300') AND b.sdo_cap_insoluto=0 )) ---- casos con deuda de int o retenido
       AND e.sdo_actual > 0 */
	   
	   
    -- Se agrega la siguiente validacion 05/01/2021 Juan Roman Velazquez Toledo
    SELECT COUNT(b.num_credito) 
		INTO vExiste
    FROM sd_bitacora_quitacondonacion AS b 
    WHERE b.estatus_proceso = 'PR' AND b.num_credito = g_NumCred;
	   
	IF vExiste > 0 THEN
		CONTINUE FOREACH;
	END IF;
	
		--   --- PROGRAMA DE APOYO 2020
		--   SELECT count (*) INTO wbandera_apoyo
		--	FROM sd_diferir
		--   WHERE numcte = numcte_apoyo;
		--   
		--	--- SE EXLUYE DEL COBRO SI EXISTE EN sd_programa_apoyo2020crd 
		--   	IF wbandera_apoyo > 0 THEN 
		--
		--	   SELECT count (*) INTO wbandera_apoyo
		--		FROM sd_programa_apoyo2020crd
		--	   WHERE num_credito = g_NumCred
		--		AND bandera = 'A';
		--
		--		IF wbandera_apoyo > 0 THEN 
		--			CONTINUE FOREACH;
		--		END IF;
		--			
		--	END IF;
				
			   
	IF g_campo_trab3 = 'BAJA' THEN 
		SELECT max(fecha_baja)
			INTO vlFechaBaja
		FROM bdicobranza:cb_rep_cart_quebrantar
		WHERE num_credito = g_NumCred
			AND Fecha_baja IS NOT NULL;  --fmv 26feb14
		IF ( nvl(vlFechaBaja, date(1)) = dtFechaHoy   ) THEN
			CONTINUE FOREACH;
		END IF;
	END IF;

	LET dAplicaReverso = 0;
				
	SELECT iva
		INTO g_IvaSuc
	FROM pa_sucursales
	WHERE empresa=g_Empresa
		AND sucursal=g_Sucursal;


	LET g_Cuentamens = 0;
	LET TOTdMontoIntMora = 0;
	LET dMontoIntMoraIva = 0; 
	LET TOTdMontoIntMoraIVA = 0; 
	LET TOTdMontoInt = 0; 
	LET dMontoInt=0;
	LET dMontoIntMora=0;
			  

	FOREACH
		SELECT nvl((interes_debe - interes_pagado + iva_debe - iva_pagado),0), 
			nvl((mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag),0)
		INTO dMontoInt, dMontoIntMora
		FROM "informix".sd_amortiza_creditocrd
		WHERE empresa     = g_Empresa
			AND num_credito = g_NumCred
		    AND capital_status IN ('2','7','1','6')
		   
	   LET g_Cuentamens = g_Cuentamens + 1;
	   LET TOTdMontoIntMora = TOTdMontoIntMora + dMontoIntMora;
	   LET dMontoIntMoraIva = dMontoIntMora * g_IvaSuc;
	   LET TOTdMontoIntMoraIVA = TOTdMontoIntMoraIVA + dMontoIntMoraIva;
	   LET TOTdMontoInt = TOTdMontoInt + dMontoInt;
		   
	END FOREACH   
				
    LET g_montofinanciado = g_montofinanciado + TOTdMontoInt + TOTdMontoIntMora + TOTdMontoIntMoraIVA;

    IF g_montofinanciado > 0 and g_Cuentamens > 0 THEN

		-- RQM 09704 Inicio	De ejecucion del desretenido 		
		IF cActRetenido = '1' THEN
            
			LET xsiretencion = 'F';
			LET dMontoRetenido = 0;

      		SELECT 	num_cta INTO dCuentaCap
			FROM 	bdicred:"informix".sd_ctascarg 
			WHERE 	num_credito = g_NumCred;  

			SELECT 	NVL(monto_retenido,0), monto_pendiente_por_pagar, pendiente_a_retener, estatus
			INTO    mMontoRetenidoCtrl, mMontoPendientexPagar, mPendienteARetener, cEstatus
			FROM 	bdicheq:"informix".sc_control_cobranza_automatica  
			WHERE 	numero_cliente				= numcte_apoyo 
			AND 	cuenta_captacion			= dCuentaCap 
			AND 	monto_pendiente_por_pagar	> 0;

			IF g_montofinanciado >= mMontoRetenidoCtrl THEN 			
				LET dMontoRetenido = mMontoRetenidoCtrl;
			ELSE 
				LET dMontoRetenido = g_montofinanciado;
			END IF;

			IF dMontoRetenido > 0 THEN 
                    
				EXECUTE PROCEDURE bdicheq:"informix".sp_desretencion_cobranza_automatica(
					numcte_apoyo, -- Numero de cliente
					dCuentaCap, -- Numero de cuenta de captacion.
					dMontoRetenido -- Monto a des retener. 
				) INTO cCodRetCtrl,cMensajeRet;

                IF cCodRetCtrl <> '00000' THEN

				INSERT INTO "informix".sd_log_cobroaut 
				(sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
				VALUES ('06','Cobro6400',dtFechaHoy,current,'informix',g_NumCred,dCuentaCap,dSeAplicoReverso,g_Folio||substr(current,15,2)||SUBSTR(current,18,2),dMontoPag,cCodRetCtrl,'000',cMensajeRet);
					
                    CONTINUE FOREACH;
                ELSE
                    LET xsiretencion = 'T';
                END IF;
        
			END IF;				
		
            -- RQM 09704 Fin
            EXECUTE PROCEDURE "informix".sp_principal_pp(g_Empresa, g_NumCred, 2, g_montofinanciado, 'informix', '9290', g_Folio, '7506')
            INTO cCodRetCtrl,cMensajeRet,DecAux,DecAux,DecAux,DecAux, DecAux, DecAux, DecAux, DecAux, DecAux, DecAux, dMontoPag,dCuentaCap, DecAux, DecAux, ChaAux;

   
            IF  cCodRetCtrl = "00000" THEN

                SELECT 	COUNT(*) INTO Val_existe
                FROM 	bdicheq:sc_control_cobranza_automatica  
                WHERE 	numero_cliente 				= numcte_apoyo 
                AND 	cuenta_captacion 			= dCuentaCap 
                AND 	monto_pendiente_por_pagar 	> 0;

                IF Val_existe > 0 THEN 

                    LET mMontoPendientexPagar = mMontoPendientexPagar - dMontoPag;  
					LET dMontoRetenido = mMontoRetenidoCtrl - dMontoRetenido;   
					LET mPendienteARetener = mMontoPendientexPagar - dMontoRetenido;

					IF mMontoPendientexPagar <= 0 THEN
						LET cEstatus = 3;
					END IF;

					IF cEstatus = 3 AND dMontoRetenido > 0 THEN

						EXECUTE PROCEDURE bdicheq:"informix".sp_desretencion_cobranza_automatica(
							numcte_apoyo, -- Numero de cliente
							dCuentaCap, -- Numero de cuenta de captacion.
							dMontoRetenido -- Monto a des retener. 
							) INTO cCodRetCtrl,cMensajeRet;

						IF cCodRetCtrl = '00000' THEN
							LET dMontoRetenido = 0;
						END IF
					END IF;


					UPDATE  bdicheq:"informix".sc_control_cobranza_automatica 
                    SET     monto_pendiente_por_pagar 	= CASE WHEN mMontoPendientexPagar < 0 THEN 0 ELSE mMontoPendientexPagar END, 
                            pendiente_a_retener 		= CASE WHEN mPendienteARetener < 0 THEN 0 ELSE mPendienteARetener END,
                            monto_retenido 				= CASE WHEN dMontoRetenido < 0 THEN 0 ELSE dMontoRetenido END, 
                            estatus 					= cEstatus,
	                        fecha_modificacion 			= CURRENT
                    WHERE   numero_cliente = numcte_apoyo 
                    AND     cuenta_captacion = dCuentaCap;

                END IF;
            ELIF cCodRetCtrl <> "00000"  THEN

                SELECT aplica_reverso
                    INTO dAplicaReverso
                FROM sd_reversa_error
                WHERE num_producto=g_NumProd
                    AND codigo=cCodRetCtrl;

                IF dAplicaReverso is null THEN
                    LET dAplicaReverso = 0;
                END IF;
   			
                IF (xsiretencion = 'T') THEN
                    UPDATE  bdicheq:"informix".sc_control_cobranza_automatica 
                    SET     monto_pendiente_por_pagar 	= monto_pendiente_por_pagar,
                            pendiente_a_retener 		= pendiente_a_retener + dMontoRetenido,
                            monto_retenido 				= monto_retenido - dMontoRetenido,
                            estatus 					= 2,
                            fecha_modificacion 			= CURRENT
                    WHERE   numero_cliente = numcte_apoyo 
                    AND     cuenta_captacion = dCuentaCap;  

					EXECUTE PROCEDURE bdicheq:"informix".sp_retencion_cobranza_automatica(numcte_apoyo,dCuentaCap,'') INTO cCodRetSpReten,cMensajeRetSpReten;
                END IF;	
            END IF;

		ELSE

            EXECUTE PROCEDURE "informix".sp_principal_pp(g_Empresa, g_NumCred, 2, g_montofinanciado, 'informix', '9290', g_Folio, '7506')
            INTO cCodRetCtrl,cMensajeRet,DecAux,DecAux,DecAux,DecAux, DecAux, DecAux, DecAux, DecAux, DecAux, DecAux, dMontoPag,dCuentaCap, DecAux, DecAux, ChaAux;

            IF cCodRetCtrl <> "00000" THEN 

                SELECT aplica_reverso
                    INTO dAplicaReverso
                FROM sd_reversa_error
                WHERE num_producto=g_NumProd
                    AND codigo=cCodRetCtrl;

                IF dAplicaReverso is null THEN
                    LET dAplicaReverso = 0;
                END IF;

            END IF;

        END IF;

		INSERT INTO "informix".sd_log_cobroaut 
		(sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
		VALUES ('06','Cobro6400',dtFechaHoy,current,'informix',g_NumCred,dCuentaCap,dSeAplicoReverso,g_Folio||substr(current,15,2)||SUBSTR(current,18,2),dMontoPag,cCodRetCtrl,cCodRetAux,cMensajeRet);
		
    END IF;
    
END FOREACH;
	
	--RQM 09704 Inicio Mandar ejecutar el cobro ADN automatico por cuenta para su ejecucion x hora
		--Revision de retenido
	SELECT 	activo_retenido INTO cActRetenido
	FROM 	"informix".sd_definicion
	WHERE 	num_producto = '7800';

	SELECT 	a.empresa, d.numcte, a.num_credito, d.cuenta_nomina, a.divisa, b.monto_financiado, status_cred, a.id_unidad_prod
	FROM		bdicred:"informix".sd_maecred a
	INNER JOIN	bdicred:"informix".sd_maesdos b 				ON a.empresa = b.empresa AND a.num_credito = b.num_credito
	INNER JOIN	bdicred:"informix".sd_maecredanexo c			ON a.empresa = c.empresa AND a.num_credito = c.num_credito
	INNER JOIN	bdisolic:"informix".ss_adn_solicitudcuenta d	ON a.empresa = d.empresa AND a.num_credito = d.num_solicitud
	INNER JOIN	bdicheq:"informix".sc_maechq e					ON a.empresa = e.empresa AND d.cuenta_nomina = e.cuenta
	WHERE	a.empresa 		= g_Empresa
	AND 	a.status_cred   NOT IN ('FF','FC','CV')
	AND		a.num_producto  = '7800'
	AND 	monto_financiado > 0
	AND 	e.sdo_actual > 0
	AND 	e.status_cta ='1'	
	INTO TEMP tmp_creditos_cobr_7800 WITH NO LOG;
	
	CREATE INDEX numcredito_auto_7800 ON tmp_creditos_cobr_7800 (numcte, empresa);
	
	UPDATE STATISTICS MEDIUM FOR TABLE tmp_creditos_cobr_7800;	   
	
	FOREACH WITH HOLD
		SELECT 	numcte, 		num_credito, 	cuenta_nomina, 	divisa, 	monto_financiado, 	status_cred, 	id_unidad_prod
		INTO 	numcte_apoyo, 	g_NumCred, 		dCuentaCap , 	g_Divisa, 	g_montofinanciado, 	g_StatusCred,	cIdUnidadProd
		FROM 	tmp_creditos_cobr_7800
		WHERE 	empresa = g_Empresa

		--SE VERIFICA EL RETENIDO		
		IF cActRetenido = '1' THEN

			SELECT 	NVL(monto_retenido,0), monto_pendiente_por_pagar, pendiente_a_retener, estatus
			INTO    mMontoRetenidoCtrl, mMontoPendientexPagar, mPendienteARetener, cEstatus 
			FROM 	bdicheq:"informix".sc_control_cobranza_automatica  
			WHERE 	numero_cliente 				= numcte_apoyo 
			AND 	cuenta_captacion 			= dCuentaCap 
			AND 	monto_pendiente_por_pagar	> 0;

        	IF g_montofinanciado >= mMontoRetenidoCtrl THEN 			
				LET dMontoRetenido = mMontoRetenidoCtrl;
			ELSE 
				LET dMontoRetenido = g_montofinanciado;
			END IF;

			IF dMontoRetenido > 0 THEN
				EXECUTE PROCEDURE bdicheq:"informix".sp_desretencion_cobranza_automatica(
				numcte_apoyo, -- Numero de cliente
				dCuentaCap, -- Numero de cuenta de captacion.
				dMontoRetenido -- Monto a des retener. 
				) INTO cCodRetCtrl,cMensajeRet;

                IF cCodRetCtrl <> '00000' THEN

					INSERT INTO "informix".sd_log_cobroaut 
					(sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
					VALUES ('06','CobroautoA', dtFechaHoy,current,'informix',g_NumCred,dCuentaCap,0,cfolio_adn||substr(current,15,2)||SUBSTR(current,18,2),g_montofinanciado,cCodRetCtrl,'000',cMensajeRet);
				
                    CONTINUE FOREACH;
                ELSE
                    LET xsiretencion = 'T';
                END IF;
			END IF;

            --Nuevo procedimiento para cobro por Credito
            EXECUTE PROCEDURE bdicred:"informix".sp_cobro_automatico_adn(g_Empresa, numcte_apoyo, g_NumCred, dCuentaCap, g_Divisa, g_montofinanciado, g_StatusCred, cIdUnidadProd)
            INTO cCodRetCtrl, cMensaje, vcprocesoADN, cNumeroFolio, cCodRetAux, cErrorInfo, dPagoMinAct;

            --Se obtiene info para actualizar el desretenido 		
            IF cCodRetCtrl = '00000' THEN

                SELECT 	COUNT(*) INTO Val_existe
                FROM 	bdicheq:"informix".sc_control_cobranza_automatica  
                WHERE 	numero_cliente = numcte_apoyo AND cuenta_captacion = dCuentaCap AND monto_pendiente_por_pagar > 0;

                IF Val_existe >= 1 THEN		
								
					LET mMontoPendientexPagar = mMontoPendientexPagar - g_montofinanciado + dPagoMinAct; 
					LET dMontoRetenido = mMontoRetenidoCtrl - dMontoRetenido; 
					LET mPendienteARetener = mMontoPendientexPagar - dMontoRetenido; 

					IF mMontoPendientexPagar <= 0 THEN
						LET cEstatus = 3; 
					END IF;

					IF cEstatus = 3 AND dMontoRetenido > 0 THEN

						EXECUTE PROCEDURE bdicheq:"informix".sp_desretencion_cobranza_automatica(
							numcte_apoyo, -- Numero de cliente
							dCuentaCap, -- Numero de cuenta de captacion.
							dMontoRetenido -- Monto a des retener. 
							) INTO cCodRetCtrl,cMensajeRet;

						IF cCodRetCtrl = '00000' THEN
							LET dMontoRetenido = 0;
						END IF
					END IF;

					UPDATE  bdicheq:"informix".sc_control_cobranza_automatica 
                    SET     monto_pendiente_por_pagar 	= CASE WHEN mMontoPendientexPagar < 0 THEN 0 ELSE mMontoPendientexPagar END,
                            pendiente_a_retener 		= CASE WHEN mPendienteARetener < 0 THEN 0 ELSE mPendienteARetener END,
                            monto_retenido 				= CASE WHEN dMontoRetenido < 0 THEN 0 ELSE dMontoRetenido END, 
                            estatus 					= cEstatus,
                            fecha_modificacion 			= CURRENT   
                    WHERE   numero_cliente = numcte_apoyo 
                    AND     cuenta_captacion = dCuentaCap;
					
				END IF;

            ELIF cCodRetCtrl <> "00000"  THEN

                IF (xsiretencion = 'T') THEN
                    UPDATE  bdicheq:"informix".sc_control_cobranza_automatica 
                    SET     monto_pendiente_por_pagar 	= monto_pendiente_por_pagar,  
                            pendiente_a_retener 		= pendiente_a_retener + dMontoRetenido,
                            monto_retenido 				= monto_retenido - dMontoRetenido,
                            estatus 					= 2,
                            fecha_modificacion 			= CURRENT
                    WHERE   numero_cliente = numcte_apoyo 
                    AND     cuenta_captacion = dCuentaCap;  

					EXECUTE PROCEDURE bdicheq:"informix".sp_retencion_cobranza_automatica(numcte_apoyo,dCuentaCap,'') INTO cCodRetSpReten,cMensajeRetSpReten;

                END IF;

            END IF;	
        ELSE 
            EXECUTE PROCEDURE bdicred:"informix".sp_cobro_automatico_adn(g_Empresa, numcte_apoyo, g_NumCred, dCuentaCap, g_Divisa, g_montofinanciado, g_StatusCred, cIdUnidadProd)
            INTO cCodRetCtrl, cMensaje, vcprocesoADN, cNumeroFolio, cCodRetAux, cErrorInfo, dPagoMinAct;
        END IF;

		INSERT INTO "informix".sd_log_cobroaut 
		(sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
		VALUES ('06','CobroautoA', dtFechaHoy,current,'informix',g_NumCred,dCuentaCap,0,cfolio_adn||substr(current,15,2)||SUBSTR(current,18,2),g_montofinanciado,cCodRetCtrl,cCodRetAux,cErrorInfo);

	END FOREACH;

	UPDATE bdinteg:sx_contproc
		SET status_proc = "F", hora_fin = CURRENT, codret = cCodRet
	WHERE empresa   = pempresa
	AND proceso     = vcproceso
	AND fecha       = dtFechaHoy;
	
	UPDATE "informix".sd_contproc
	SET status_proc = "F",
		hora_fin    = CURRENT,
		cod_ret     = cCodRet,
		mensaje     = cMensaje
	WHERE empresa   = pempresa
	AND proceso     = vcproceso
	AND fecha       = dtFechaHoy;

		
	DROP TABLE IF EXISTS tmp_creditos_cobr_6400;
	DROP TABLE IF EXISTS tmp_creditos_cobr_7800;
	DROP TABLE IF EXISTS pa_sucursales;


RETURN cCodRet,cMensaje;

END
END PROCEDURE;