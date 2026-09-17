CREATE PROCEDURE "informix".sp_adn_cobroautomatico(pEmpresa CHAR(3))
RETURNING CHAR(6)       AS codigo_retorno,       
          CHAR(125)      AS mens_ret;


DEFINE cCodRet		CHAR(5);
DEFINE cCodRetAux	CHAR(6);
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE cErrorInfo	VARCHAR(80,1);
DEFINE cMensajeRet  CHAR(125);
DEFINE vcproceso    CHAR(15);
DEFINE vcprocesoM1  CHAR(15);

DEFINE cCuenta	CHAR(20);
DEFINE iValida INTEGER;
DEFINE iContador INTEGER;
DEFINE dFechaValida	DATE;
DEFINE dFechaAlta	DATE;
DEFINE dPorcentaje	DECIMAL(18,2);
DEFINE dMontoMin	DECIMAL(18,2);
DEFINE dMontoMax	DECIMAL(18,2);
DEFINE dLinea	DECIMAL(18,2);
DEFINE g_StatusCtaCap CHAR(1) ;
DEFINE g_SdoCta	 DECIMAL(14,2)  ;
DEFINE g_SdoDisp	 DECIMAL(14,2)  ;
DEFINE  g_TranRet	CHAR(4) ;
DEFINE  g_FechaCargo	DATE  ;
DEFINE  dtFechaHoy	DATE  ;
DEFINE  g_MtoRet	 DECIMAL(14,2)  ;
DEFINE  cDivisa	CHAR(2) ;

DEFINE  cNumeroFolio CHAR(16);

DEFINE g_IntMoraCob   MONEY(14,2);
DEFINE g_IntVencCob   MONEY(14,2);
DEFINE g_CapVencCob   MONEY(14,2);
DEFINE g_IntVigCob    MONEY(14,2);
DEFINE g_CapVigCob    MONEY(14,2);
DEFINE g_Impuesto     MONEY(14,2);
DEFINE g_Comision     MONEY(14,2);
DEFINE g_Seguro       MONEY(14,2);
DEFINE g_Remanente    MONEY(14,2);


DEFINE cNumCte   CHAR(20) ;
DEFINE cCtaNom   CHAR(20) ;
DEFINE cNumSol   CHAR(20) ;
DEFINE dAnticipo    MONEY(14,2);
DEFINE dSdo_capital    MONEY(14,2);
DEFINE dMonto_disp    MONEY(14,2);
DEFINE dMonto_disp2    MONEY(14,2);
DEFINE cActCob   CHAR(1) ;
DEFINE  dtFecha_ult_disp	DATE  ;
DEFINE  iFrecuencia	INTEGER  ;
DEFINE  iDiaPago	INTEGER  ;
DEFINE  iDiaPagoAux	INTEGER  ;
DEFINE  iDiaPagoAux2	INTEGER  ;
DEFINE  iDiaPagoAux3	INTEGER  ;
DEFINE  iBandera	INTEGER  ;
DEFINE dFechaCuota                   DATE;
DEFINE dCapitalStatus                CHAR(1);
DEFINE dCapitalDebe                  DECIMAL(18,2);
DEFINE dSdoTrasp                     DECIMAL(18,2);
DEFINE dMontoVencido                     DECIMAL(18,2);
DEFINE dCodRef                     INTEGER;
DEFINE dStatusCred                  CHAR(2);

DEFINE credcontproc                  CHAR(1);
DEFINE intecontproc                  CHAR(1);
DEFINE v_existeM1                   INTEGER;

DEFINE cIdUnidadProd	INTEGER;
DEFINE cNum_credito		INTEGER;
DEFINE ccodRetCanCred	CHAR(5);
DEFINE s_existe_cntrl   SMALLINT;

LET cCodRet			= "00000";
LET cCodRetAux	    = "000000";
LET iSqlErr			= 0;
LET iSamErr			= 0;
LET cErrorInfo		= "";
LET cMensajeRet     = "Se realiza el pago correctamente";
LET vcproceso 		= 'CobroautoADN';
LET vcprocesoM1     =trim(vcproceso)||'1';

LET cCuenta		= "";
LET iContador 	= 0;
LET iValida 	= 0;
LET dFechaValida 	= DATE(1);
LET dFechaAlta 	= DATE(1);
LET dPorcentaje = 0;
LET dMontoMin = 0;
LET dMontoMax = 0;
LET dLinea = 0;

LET g_StatusCtaCap = '';
LET g_SdoCta = 0;

LET  g_SdoCta	 = 0;
LET  g_SdoDisp	 = 0;
LET  g_TranRet	= '';
LET  g_FechaCargo	= DATE(1)  ;
LET  dtFechaHoy	= DATE(1)  ;
LET  g_MtoRet	  = 0;
LET  cDivisa	  = '';
LET  cNumeroFolio	  = '';

LET g_Remanente   = 0;
LET g_IntMoraCob  = 0;
LET g_IntVencCob  = 0;
LET g_CapVencCob  = 0;
LET g_IntVigCob   = 0;
LET g_CapVigCob   = 0;
LET g_Impuesto    = 0;
LET g_Comision    = 0;
LET g_Seguro      = 0;

LET cNumCte   = '';
LET cCtaNom   = '';
LET cNumSol   = '';
LET dAnticipo    = 0;
LET dSdo_capital   = 0;
LET dMonto_disp   = 0;
LET dMonto_disp2   = 0;
LET cActCob    = '';
LET  dtFecha_ult_disp =	DATE (1) ;
LET  iFrecuencia	= 0;
LET  iDiaPago	= 0;
LET  iDiaPagoAux	= 0;
LET  iDiaPagoAux2	= 0;
LET  iDiaPagoAux3	= 0;
LET  iBandera	= 0;
LET dFechaCuota =  DATE(1);
LET dCapitalStatus ="";
LET dCapitalDebe = 0;
LET dSdoTrasp = 0;
LET dMontoVencido = 0;
LET dCodRef = 0;
LET dStatusCred ="";
LET credcontproc          = " ";
LET intecontproc          = " ";

LET cIdUnidadProd = NULL;
LET cNum_credito = 0;
LET ccodRetCanCred	= '';
LET s_existe_cntrl      = 0;

BEGIN
ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
	IF iSqlErr != 0 THEN
		LET cCodRet     = iSqlErr;
		LET cMensajeRet = cErrorInfo;
	END IF;
		UPDATE "informix".sd_contproc
             SET status_proc = "C",
                 hora_fin    = CURRENT,
                 cod_ret     = cCodRet,
                 mensaje     = cMensajeRet
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
      RETURN cCodRet,cMensajeRet;
END EXCEPTION;

--SET DEBUG FILE TO "/informix/sp_adn_cobroautomatico.out";
--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF TRIM(NVL(pEmpresa,"")) = ""  THEN
		LET cCodRet  = "00001";
		LET cMensajeRet  = "No tiene empresa el parametro";
		RETURN cCodRet,cMensajeRet;
	END IF;
	
	SELECT fecha_hoy
		INTO dtFechaHoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa ='001';
	
	SELECT status_proc 
    INTO intecontproc
    FROM bdinteg:sx_contproc
    WHERE fecha= dtFechaHoy 
      and proceso = vcproceso;

    if (intecontproc = 'I') then
        LET cMensajeRet="EXISTE UN PROCESO PREVIO EN EJECUCION";
        RETURN cCodRet,cMensajeRet;
     end if;

    SELECT status_proc  
    INTO credcontproc
    FROM bdicred:sd_contproc
    WHERE fecha= dtFechaHoy 
      and proceso = vcproceso;
	  
	IF (intecontproc IS NULL) THEN
      INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
      VALUES ('001',vcproceso,dtFechaHoy,'06','I','informix',CURRENT,CURRENT,'000');
	ELSE	
		UPDATE bdinteg:sx_contproc 
			SET status_proc='I'
		WHERE fecha= dtFechaHoy 
			and proceso =vcproceso;	
    END IF;  
    
    IF (credcontproc IS NULL) THEN
      INSERT INTO  sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
      VALUES ('001',vcproceso,dtFechaHoy,'I','informix',CURRENT,CURRENT,'000','Iniciamos');
	ELSE
		UPDATE bdicred:sd_contproc 
			SET status_proc='I' ,mensaje = 'Iniciamos'
		WHERE fecha= dtFechaHoy 
			and proceso =vcproceso;	
    END IF;


	FOREACH WITH HOLD

	 SELECT {+INDEX (bdisolic:ss_adn_solicitudcuenta)}
		d.numcte , a.num_credito,d.cuenta_nomina ,a.divisa, b.monto_financiado,status_cred,a.id_unidad_prod
      INTO cNumCte,cNumSol,cCtaNom , cDivisa, dMonto_disp,dStatusCred,cIdUnidadProd
	 FROM "informix".sd_maecred a,
           "informix".sd_maesdos b,
           "informix".sd_maecredanexo c,
           bdisolic:"informix".ss_adn_solicitudcuenta d,
            bdicheq:"informix".sc_maechq e
     WHERE a.empresa       = '001'
       AND a.status_cred   NOT IN ('FF','FC','CV')
       AND b.empresa       = a.empresa
       AND b.num_credito   = a.num_credito
       AND c.num_credito   = b.num_credito
       AND c.empresa       = b.empresa
       AND a.num_producto  = '7800'
       AND a.num_credito = d.num_solicitud
       AND e.cuenta = d.cuenta_nomina
       AND monto_financiado > 0
       AND e.sdo_actual > 0
	   AND e.status_cta ='1'

	   
	   	SELECT  COUNT(*) 
            INTO    s_existe_cntrl
            FROM    bdicheq:"informix".sc_control_cobranza_automatica  
            WHERE   numero_cliente   = cNumCte
            AND     cuenta_captacion = cCtaNom;

		IF s_existe_cntrl >= 1 THEN
			CONTINUE FOREACH;
		
		END IF;
		
		--INC Anticipo se corrige para que no cobre doble
		SELECT count(*)
		INTO dCapitalDebe
		FROM "informix".sd_amortiza_credito a
		WHERE a.empresa     = pEmpresa
		AND a.num_credito = cNumSol
		AND a.capital_status IN ("1", "7", "2", "6")
		AND (a.capital_debe - a.capital_pagado) > 0;	


	   IF dCapitalDebe = 0 THEN
	   		CONTINUE FOREACH;
	   END IF;
		-- Se obtiene el saldo de la cuenta identificada.
		 CALL bdicheq:"informix".cons_saldo(cCtaNom) RETURNING cCodRetAux,g_SdoCta,g_StatusCtaCap;

			IF (cCodRetAux <> "000") THEN
				CONTINUE FOREACH;
			END IF;


			-- Valida el saldo obtenido de la cuenta.
			IF NVL(g_SdoCta,0) <= 0 THEN
				CONTINUE FOREACH;
			END IF;
			LET  iBandera	= 0;
			IF g_SdoCta < dMonto_disp THEN
				LET dMonto_disp = g_SdoCta;
				LET iBandera = 1;
			END IF;


		-- SE GENERA EL FOLIO
		CALL bdicheq:"informix".sp_generafolionomina('ANTICIPO')
		RETURNING cCodRetAux, cNumeroFolio;

		--se realiza el cargo a la cuenta

			EXECUTE PROCEDURE  bdicheq:"informix".cargo_ref('001', '9290', 'informix', '0398', "0000", cNumeroFolio,cCtaNom, 0, dMonto_disp,cDivisa,"", "0", '')
			INTO cCodRetAux, g_TranRet, g_FechaCargo, g_SdoDisp, g_MtoRet;

				IF cCodRetAux <> "000" THEN
				CONTINUE FOREACH;
				END IF

					FOREACH WITH HOLD
						SELECT a.fecha_cuota, a.capital_status,  a.capital_debe - a.capital_pagado
						INTO dFechaCuota, dCapitalStatus, dCapitalDebe
						FROM "informix".sd_amortiza_credito a
						WHERE a.empresa     = pEmpresa
						AND a.num_credito = cNumSol
						AND a.capital_status IN ("1", "7", "2", "6")
						ORDER BY a.num_credito,a.fecha_cuota			


						IF g_SdoCta < dCapitalDebe THEN
							LET dCapitalDebe = g_SdoCta;
							LET iBandera = 1;
						END IF;
			
						--se realiza el pago al credito de nomina

						IF (dStatusCred ='AA' OR dStatusCred ='BA' OR dStatusCred ='BT') THEN
							IF dCapitalStatus = "1" THEN
								LET dCodRef = 10;
							ELIF dCapitalStatus = "7" THEN
								LET dCodRef = 7;
							ELIF dCapitalStatus = "2" THEN 
								LET dCodRef = 8;
							END IF;
						ELIF (dStatusCred ='E3' OR dStatusCred ='E2' OR dStatusCred ='E1') THEN
							IF dCapitalStatus = "1" THEN
								LET dCodRef = 1120; --PAGO NO EXGIBLE E1
							ELIF dCapitalStatus = "7" THEN
								LET dCodRef = 1121;  --PAGO EXGIBLE E1
							ELIF dCapitalStatus = "6" THEN 
								LET dCodRef = 1122;  --PAGO EXGIBLE E3
							END IF;
						END IF;
					

						IF dCapitalDebe > 0 THEN

							IF (dStatusCred ='AA' OR dStatusCred ='BA' OR dStatusCred ='BT') THEN

								UPDATE "informix".sd_maesdos
								SET sdo_cap_insoluto = sdo_cap_insoluto - dCapitalDebe,
								sdo_capital = (CASE WHEN dCapitalStatus = "1" THEN (sdo_capital - dCapitalDebe) ELSE sdo_capital END),
								monto_vencido    = (CASE WHEN dCapitalStatus = "7" THEN (monto_vencido - dCapitalDebe)  ELSE monto_vencido END),
								mto_venc_trasp   = (CASE WHEN dCapitalStatus = "2" THEN (mto_venc_trasp - dCapitalDebe) ELSE mto_venc_trasp END),
								monto_financiado = monto_financiado - dCapitalDebe
								WHERE empresa          = pEmpresa 
								AND num_credito      = cNumSol;

							ELIF (dStatusCred ='E3' OR dStatusCred ='E2' OR dStatusCred ='E1') THEN

								UPDATE "informix".sd_maesdos
								SET sdo_cap_insoluto = sdo_cap_insoluto - dCapitalDebe,
								sdo_capital = (CASE WHEN dCapitalStatus = "1" THEN (sdo_capital - dCapitalDebe) ELSE sdo_capital END),
								monto_vencido    = (CASE WHEN dCapitalStatus IN ("7","6") THEN (monto_vencido - dCapitalDebe)  ELSE monto_vencido END),
								monto_financiado = monto_financiado - dCapitalDebe
								WHERE empresa          = pEmpresa 
								AND num_credito      = cNumSol;

							END IF;

							UPDATE "informix".sd_amortiza_credito
								SET capital_pagado     = capital_pagado + dCapitalDebe,
								capital_fecha_pago = dtFechaHoy,
								capital_status_ant = (CASE WHEN ((capital_pagado + dCapitalDebe) >= capital_debe) THEN capital_status ELSE capital_status_ant END),
								capital_status     = (CASE WHEN ((capital_pagado + dCapitalDebe) >= capital_debe) THEN "5" ELSE capital_status END)
								WHERE empresa            = pEmpresa
								AND num_credito        = cNumSol
								AND fecha_cuota        = dFechaCuota;

							-- Total del Pago
							CALL "informix".GenMov(pEmpresa , cNumSol, '7800', 1,
							'074', dtFechaHoy, dCapitalDebe, cNumeroFolio,          --vtotpag
							'9290', cDivisa, '8175') RETURNING
							cCodRet, cErrorInfo;

							CALL "informix".genmov(pEmpresa, cNumSol, '7800', dCodRef, '074', dtFechaHoy, 
							dCapitalDebe,cNumeroFolio,'9290', cDivisa, '8175')  RETURNING
							cCodRet, cErrorInfo;

							if cCodRet = '00000' then   ---MACF 20190822
							   -- Actualizar sd_indicador_cred
							   UPDATE "informix".sd_indicador_cred
                                  SET fecha_ultimo_pago = dtFechaHoy,
								      monto_ultimo_pago = dCapitalDebe
                                WHERE empresa = pEmpresa
                                  AND num_credito = cNumSol;
								  
							   --- Actualizar sd_maecredanexo   
							   UPDATE "informix".sd_maecredanexo
							      SET fecha_ult_pago = dtFechaHoy
								WHERE empresa = pEmpresa
                                  AND num_credito = cNumSol;

						    end if;
							
						END IF;
					
					END FOREACH;
				 
				 
			IF iBandera =  1 THEN
				UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
					SET activacion_cobrada = '2' , --2 significa que se cobro pero no totalmente
						monto_disp = monto_disp - dMonto_disp
				WHERE numcte = cNumCte
				AND num_solicitud  = cNumSol;
			ELSE

				UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
					SET activacion_cobrada =  '1' ,
						fecha_ult_disp   = ''  ,
						monto_disp = monto_disp - dMonto_disp
					WHERE numcte = cNumCte
					AND num_solicitud  = cNumSol;

				--- Actualizar sd_maecredanexo   
				UPDATE "informix".sd_maecredanexo
					SET fecha_vencto = null
				WHERE empresa = pEmpresa
					AND num_credito = cNumSol;

				UPDATE "informix".sd_maesdos
					SET act = 0
				WHERE empresa = pEmpresa
					AND num_credito = cNumSol;

				IF (cIdUnidadProd != 3) THEN
					LET cIdUnidadProd = NULL;
				END IF;

				IF (dStatusCred ='AA' OR dStatusCred ='BA' OR dStatusCred ='BT') THEN

					UPDATE bdicred:"informix".sd_maecred
						SET id_unidad_prod = cIdUnidadProd, Cod_caract_2 = '', status_cred ='AA'
						WHERE empresa = '001'
						AND num_credito = cNumSol;

				ELIF (dStatusCred ='E1' OR dStatusCred ='E2' OR dStatusCred ='E3') THEN

					UPDATE bdicred:"informix".sd_maecred
						SET id_unidad_prod = cIdUnidadProd, Cod_caract_2 = '', status_cred ='E1'
						WHERE empresa = '001'
						AND num_credito = cNumSol;

					UPDATE bdicred:"informix".sd_indicador_cred
						SET dias_atraso = '0'
						WHERE empresa = '001'
						AND num_credito = cNumSol;

				END IF;

			END IF;
		
		Insert into "informix".sd_log_cobroaut 
		(sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
		values ('06',vcproceso,dtFechaHoy,current,'informix',cNumSol,cCtaNom,0,cNumeroFolio,dMonto_disp,cCodRet,cCodRetAux,cErrorInfo);

	END FOREACH;

	-- CICLO QUE EVALUA SI UN CREDITO SERA CANCELADO
	FOREACH WITH HOLD

		SELECT      a.num_credito
		INTO        cNumSol
		FROM        bdicred:"informix".sd_maecred a
		INNER JOIN  bdicred:"informix".sd_exempleados_adn b ON a.num_credito = b.num_credito
		INNER JOIN  bdicred:"informix".sd_maesdos c ON a.num_credito = c.num_credito
		WHERE       a.id_unidad_prod = 3
		AND         a.status_cred IN ('E1','E2','E3')
		AND			c.sdo_cap_insoluto <= 0

		-- CANCELA EL CREDITO
		CALL sp_adn_cancelacredito(pEmpresa,cNumSol) RETURNING ccodRetCanCred;

	END FOREACH;
	
	SELECT COUNT(*) INTO v_existeM1
		FROM "informix".sd_contproc
		WHERE empresa     = pempresa
		   AND proceso     = vcprocesoM1
		   AND status_proc = "F"
		   AND fecha       = dtFechaHoy;
		   
    IF v_existeM1>0 THEN
        UPDATE "informix".sd_contproc
           SET status_proc = "F",
               hora_fin    = CURRENT,
               cod_ret     = cCodRet,
               mensaje     = cMensajeRet
         WHERE empresa     = pempresa
           AND proceso     = vcproceso
           AND fecha       = dtFechaHoy;
    
        UPDATE bdinteg:sx_contproc
           SET status_proc = "F",
               hora_fin    = CURRENT,
               codret      = cCodRet
         WHERE empresa     = pempresa
           AND proceso     = vcproceso
           AND fecha       = dtFechaHoy;
    ELSE
        UPDATE "informix".sd_contproc
           SET status_proc = "F",
               hora_fin    = CURRENT,
               cod_ret     = cCodRet,
               mensaje     = cMensajeRet,
               proceso     = vcprocesoM1
         WHERE empresa     = pempresa
           AND proceso     = vcproceso
           AND fecha       = dtFechaHoy;
    
        UPDATE bdinteg:sx_contproc
           SET status_proc = "F",
               hora_fin    = CURRENT,
               codret      = cCodRet,
               proceso     = vcprocesoM1
         WHERE empresa     = pempresa
           AND proceso     = vcproceso
           AND fecha       = dtFechaHoy;
    END IF;
	
	
	RETURN cCodRet,cMensajeRet;
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para obtener las cuentas validas de nomina para el producto de Anticipo de Nomina',
'FECHA: 13/Enero/2016',
'BD: bdisolic',
'AUTOR: Jesus Manuel Aguilar Heredia';

CREATE PROCEDURE "informix".sp_depura_sd_movhis_5()
RETURNING CHAR(6);

DEFINE cCodRet      CHAR(6);
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE fFecha       DATE;
DEFINE vFechaD      DATE;

DEFINE vCont        INTEGER;

LET cCodRet      = '000000';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET vNumCred     = '';
LET vNumCredAux  = '';
LET fFecha       = DATE(1);
LET vFechaD      = DATE(1);
LET vCont        = 0;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            ROLLBACK WORK;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

    -- Obtener Ãºltimo procesado
    SELECT num_credito
      INTO vNumCredAux
      FROM informix.sd_param_movhis_dep
     WHERE proceso = 5;

    IF vNumCredAux IS NULL THEN
        LET vNumCredAux = "";
        INSERT INTO informix.sd_param_movhis_dep VALUES (5,'');
    END IF;

    -- Fecha corte
    SELECT fecha_insert
      INTO fFecha
      FROM bdicred:sd_param
     WHERE empresa = '001'
       AND cod_param = '800';
	   
	LET fFecha = mdy(01,01,2024);

BEGIN WORK;
    FOREACH WITH HOLD

        SELECT num_credito, fecha_mov
          INTO vNumCred, vFechaD
          FROM bdicred:"informix".sd_movhis
         WHERE empresa = '001'
           AND fecha_mov < fFecha
         ORDER BY fecha_mov ASC


        INSERT INTO bdicred:sd_movhis_depura
        SELECT *
          FROM bdicred:sd_movhis
         WHERE empresa = '001'
           AND fecha_mov = vFechaD
           AND num_credito = vNumCred;

        DELETE FROM bdicred:sd_movhis
         WHERE empresa = '001'
           AND fecha_mov = vFechaD
           AND num_credito = vNumCred;

        LET vCont = vCont + 1;

        -- ð¥ COMMIT CADA 100 REGISTROS
        IF vCont >= 1000 THEN
            COMMIT WORK;
            BEGIN WORK;
            LET vCont = 0;
        END IF;

    END FOREACH;

    COMMIT WORK;

    RETURN cCodRet;

END;

END PROCEDURE;