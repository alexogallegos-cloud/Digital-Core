CREATE PROCEDURE "informix".sp_validaradn_pba ( pNumCel  CHAR(20), pSaldo DECIMAL (18,2))	
RETURNING CHAR(5);       -- Codigo de Retorno
		  

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet      CHAR(6);
DEFINE cCod_ret      CHAR(6);
DEFINE v_codret CHAR(6);
DEFINE cMen_ret CHAR(80);

DEFINE sParamVencido        SMALLINT;
DEFINE iValida        SMALLINT;
DEFINE dSdo_vencido         DECIMAL(18,2);
DEFINE dSdo_vencidocrd      DECIMAL(18,2);
DEFINE dMontoMin	DECIMAL(18,2);
DEFINE dMontoMax	DECIMAL(18,2);

DEFINE cNumCte	CHAR(20);
DEFINE cCtaNom	CHAR(20);
DEFINE cNumSol	CHAR(20);
DEFINE cActCob	CHAR(1);

DEFINE dAnticipo	DECIMAL(18,2);
DEFINE dMontoAct	DECIMAL(18,2);
DEFINE mMontoAct	DECIMAL(18,2);
DEFINE mMontoDisp	DECIMAL(18,2);
DEFINE mMontoDispAux	DECIMAL(18,2);
DEFINE mIvaMontoDisp	 DECIMAL(14,2);
DEFINE mIvaMontoAct	 DECIMAL(14,2);
DEFINE cNombreComAct	CHAR(50);
DEFINE cNombreComDisp	CHAR(50);
DEFINE cNumcred	CHAR(20);
DEFINE cProducto	CHAR(4);
DEFINE cNumeroFolio 		CHAR(16);
DEFINE vCveExistente 		INTEGER;
DEFINE dtFechaHoy 		DATE;
DEFINE cFechaIni1m 		DATE;
DEFINE cHoraIni 		CHAR(8);
DEFINE cHoraFin 		CHAR(8);
DEFINE cSucursal 		CHAR(4);
DEFINE cStatus    CHAR(2);
DEFINE mIvaSuc	 DECIMAL(14,2);
DEFINE actCom CHAR(1);
DEFINE reverso CHAR(1);
DEFINE iNumReg SMALLINT;
DEFINE v_movil_cuenta SMALLINT;
DEFINE bandera SMALLINT; --INC 25 019
--RQI 25 024

DEFINE dtFechaCh			DATE;
DEFINE dtFechaCrd			DATE;
DEFINE cfechhoy			    DATE;

LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "00000";
LET cCod_ret         = "00000";
LET cMen_ret     = "Proceso Exitoso";


LET sParamVencido     = 0;
LET iValida     = 0;
LET dSdo_vencido      = 0;
LET dSdo_vencidocrd   = 0;
LET dMontoMin	= 0;
LET dMontoMax	= 0;

LET cNumCte	= "";
LET cCtaNom	= "";
LET cNumSol = "";
LET cActCob	= "";

LET dAnticipo	= 0;
LET dMontoAct	= 0;
LET mMontoAct	= 0;
LET mMontoDisp = 0;
LET mMontoDispAux = 0;
LET mIvaMontoDisp	= 0;
LET mIvaMontoAct	 = 0;
LET cNombreComAct	= "";
LET cNombreComDisp	= "";
LET cNumcred	= "";
LET cProducto	= "";
LET cNumeroFolio	= "";
LET vCveExistente	= 0;
LET dtFechaHoy	= DATE(1);
LET cFechaIni1m	= DATE(1);
LET cHoraIni = "";
LET cHoraFin = "";
LET cSucursal = "";
LET cStatus = "";
LET mIvaSuc = 0;
LET actCom ='0';
LET reverso ='0';
LET v_codret="00000";
LET iNumReg = 0;
LET v_movil_cuenta =0;
LET bandera = 0; --INC 25 019

--RQI 25 024
LET dtFechaCh				=DATE(1);
LET dtFechaCrd				=DATE(1);
LET cfechhoy			    =DATE(1);

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo

   IF bandera = 1 then
        ROLLBACK WORK;
   END IF;
   IF iSqlErr != 0 THEN
		RETURN cCodRet ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

  	SET DEBUG FILE TO '/controlcambios/P-BC-20190518-01/bdisolic/sp_validaradn.out';
	TRACE ON; 

	IF NVL(pNumCel,'') = ''  THEN
		RETURN  '00001' ;
	ELSE
		
		SELECT valor
		INTO sParamVencido
		FROM bdisolic:"informix".ss_param
		WHERE empresa = '001'
		AND secuencia= 350;
		
		SELECT valor
		INTO cHoraIni
		FROM bdisolic:"informix".ss_param
		WHERE empresa = '001'
		AND secuencia= 381;
		
		SELECT valor
		INTO cHoraFin
		FROM bdisolic:"informix".ss_param
		WHERE empresa = '001'
		AND secuencia= 382;
		
		SELECT fecha_hoy  
		INTO dtFechaHoy 
		FROM  bdicred:"informix".sd_fechas; 
		
		select fecha_hoy INTO cfechhoy -- RQI 25 024
		from bdinteg:"informix".si_fechas 
		WHERE empresa = '001';
		
		--validacion del horario para poder realizar las disposiciones
		--IF current hour to second < cHoraIni OR current hour to second >  cHoraFin OR WEEKDAY(dtFechaHoy) in(0,6) THEN
		/*IF current hour to second < cHoraIni OR current hour to second >  cHoraFin  THEN
			--Por el momento no le podemos ofrecer el servicio. Por favor intenta mÃÂ¡s tarde.
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_14' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
			RETURN cCodRet ;
		
		END IF*/
		
		IF (SELECT  count(a.num_solicitud)
		FROM   bdisolic:"informix".ss_adn_solicitudcuenta a, bdicred:"informix".sd_maecred b, bdicred:"informix".sd_maesdos c
		WHERE movil_cuenta  = pNumCel
		AND a.num_solicitud = b.num_credito
        AND a.num_solicitud = c.num_credito
		and b.empresa ='001')>1 THEN
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_15' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
			RETURN cCodRet;
		END IF;
			
        SELECT   NVL(a.numcte,''),NVL(a.cuenta_nomina,''),NVL(a.num_solicitud,''),NVL(c.monto_otorgado,0),NVL(a.activacion_cobrada,''),NVL(c.sdo_cap_insoluto,0),NVL(b.id_unidad_prod, 0),NVL(b.sucursal,''),NVL(b.status_cred,0)
		INTO cNumCte, cCtaNom,cNumSol,dAnticipo, cActCob, dMontoAct,vCveExistente, cSucursal, cStatus
		FROM   bdisolic:"informix".ss_adn_solicitudcuenta a, bdicred:"informix".sd_maecred b, bdicred:"informix".sd_maesdos c
		WHERE movil_cuenta  = pNumCel
		AND a.num_solicitud = b.num_credito
        AND a.num_solicitud = c.num_credito
		and b.empresa ='001';

		IF NVL(cActCob,'') = '3' THEN
			--Por el momento no le podemos ofrecer el servicio. Por favor intenta mÃÂ¡s tarde.
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_14' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
			RETURN cCodRet ;
		END IF;

		SELECT COUNT(movil_cuenta) 
		INTO v_movil_cuenta
		FROM bdisolic:"informix".ss_adn_solicitudcuenta WHERE movil_cuenta  = pNumCel;
	
        IF (v_movil_cuenta)>0 THEN
		  	BEGIN WORK; --INC 25 019
			LET bandera = 1;
				UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
				SET activacion_cobrada = '3'--Se utilizara para detectar que ya esta en tramite un anticipo para los casos de sms dobles		
				WHERE numcte = cNumCte
				AND movil_cuenta  = pNumCel
				AND NVL(activacion_cobrada,'')<>'3';
			COMMIT WORK; --INC 25 019 
		    LET bandera = 0;
			
			LET iNumReg = dbinfo("sqlca.sqlerrd2");
			
			IF iNumReg = 0 THEN 
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_5' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
				RETURN cCodRet ;
			END IF; 
		ELSE
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_7' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
			RETURN cCodRet ;
		END IF;
		
        IF (SUBSTR(cStatus,1,1) IN ("B", "F", "C"))  THEN  --VALIDA EL STATUS DE LA CUENTA
            --?Por el momento no podemos ofrecerte el servicio, acude a tu sucursal BanCoppel mÃÂ¡s cercana para revisar la situaciÃÂ³n de tu cuenta?.				
            UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
			SET activacion_cobrada = cActCob
			WHERE numcte = cNumCte
			AND movil_cuenta  = pNumCel;

            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_15' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
			RETURN cCodRet ;	
        END IF

        IF dMontoAct > 0  THEN  --VALIDA QUE NO TENGA OTRO ANTICIPO 
			--?Ya cuentas con tu Anticipo de NÃÂ³mina, una vez que lo termines de pagar podrÃÂ¡s solicitar otro?
			UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
			SET activacion_cobrada = cActCob
			WHERE numcte = cNumCte
			AND movil_cuenta  = pNumCel;

				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_5' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
					RETURN cCodRet ;	
		END IF;	

        IF NVL(cNumSol,'') =''THEN
		--El nÃÂºmero celular no estÃÂ¡ asociado a tu cuenta, acude a tu sucursal BanCoppel mÃÂ¡s cercana para asociarlo y puedas solicitar nuevamente tu Anticipo de NÃÂ³mina?.
			UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
			SET activacion_cobrada = cActCob
			WHERE numcte = cNumCte
			AND movil_cuenta  = pNumCel;
			
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_7' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
			RETURN cCodRet ;
		END IF;

        IF vCveExistente > 0 THEN
			--?Por el momento no podemos ofrecerte el servicio, acude a tu sucursal BanCoppel mÃÂ¡s cercana para revisar la situaciÃÂ³n de tu cuenta?.				
			UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
			SET activacion_cobrada = cActCob
			WHERE numcte = cNumCte
			AND movil_cuenta  = pNumCel;

			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_15' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
						RETURN cCodRet ;	
		END IF;

        -- CONSULTA LOS MONTOS MAXIMOS Y MINIMOS QUE SE PUEDEN OTROGAR EN ANTICIPO DE NOMINA
        SELECT monto_min_cred, monto_max_cred 
		INTO dMontoMin, dMontoMax
		FROM bdicred:"informix".sd_definicion 
		WHERE num_producto ='7800';	

        --CONSULTA EL IVA DE SUCURSAL Y LAS COMISIONES POR ACTIVACION Y DISPOSICION
        SELECT iva INTO mIvaSuc
        FROM bdinteg:"informix".si_sucursales 
        WHERE sucursal=cSucursal;
		
		IF NVL(cActCob,'') = '' THEN 
			--comision por activacion
				SELECT monto, nombre_com
				INTO mMontoAct , cNombreComAct
				FROM  bdicred:"informix".sd_tpcomis 
				WHERE empresa = '001' 
				AND cod_comis = '8170';  

				LET mIvaMontoAct = mMontoAct * mIvaSuc ;
		END IF

        --comision por disposicion
        SELECT monto, nombre_com
        INTO mMontoDisp , cNombreComDisp
        FROM  bdicred:"informix".sd_tpcomis 
        WHERE empresa = '001'  
        AND cod_comis = '8172';
        LET mMontoDispAux  =  pSaldo * (mMontoDisp/100) ;
        LET mIvaMontoDisp = mMontoDispAux * mIvaSuc ;

        -- VALIDA QUE EL SALDO SOLICITADO + COMISIONES E IVAS ESTEN ENTRE LOS MONTOS MINIMOS Y MAXIMOS Y ASI MISMO NO SOBREPASEN EL SALDO DISPONIBLE
        IF NVL(pSaldo,0) < NVL(dMontoMin,0) OR  (NVL(pSaldo,0) + NVL(mMontoAct,0) + NVL(mMontoDispAux,0) +NVL(mIvaMontoAct,0) +NVL(mIvaMontoDisp,0)) >  NVL(dMontoMax,0) OR  (NVL(pSaldo,0) + NVL(mMontoAct,0) + NVL(mMontoDispAux,0) +NVL(mIvaMontoAct,0) +NVL(mIvaMontoDisp,0)) >  NVL(dAnticipo,0)  THEN
		--Verifica el monto solicitado de tu Anticipo de NÃÂ³mina e intÃÂ©ntalo de nuevo?
			UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
			SET activacion_cobrada = cActCob
			WHERE numcte = cNumCte
			AND movil_cuenta  = pNumCel;

			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_9' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
			RETURN cCodRet ;
		END IF;
	
		CALL bdicred:"informix".monthadd(dtFechaHoy,- 1) RETURNING cFechaIni1m; 
		
		
		IF (SELECT COUNT(cuenta)		
			FROM bdicheq:"informix".sc_movhis mov
			INNER JOIN bdicred:"informix".sd_transvalprod  tran ON (tran.transacc = mov.transacc AND tran.activo = 2)
			WHERE cuenta = cCtaNom 
			AND cancelad <> 'S'
			AND fech_alt BETWEEN cFechaIni1m AND dtFechaHoy) < 1 THEN 
		
			IF (SELECT COUNT(cuenta)		
				FROM bdicheq:"informix".sc_movhis_old mov
				INNER JOIN bdicred:"informix".sd_transvalprod  tran ON (tran.transacc = mov.transacc AND tran.activo = 2)
				WHERE cuenta = cCtaNom 
				AND cancelad <> 'S'
				AND fech_alt BETWEEN cFechaIni1m AND dtFechaHoy) < 1 THEN 
		
			UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
			SET activacion_cobrada = cActCob
			WHERE numcte = cNumCte
			AND movil_cuenta  = pNumCel;

			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_15' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
					RETURN cCodRet ;
			END IF;
		END IF;	
		
					
	   FOREACH
            SELECT num_credito
              INTO cNumcred
              FROM bdicred:"informix".sd_maecred
             WHERE empresa = '001'
               AND numcte = cNumCte
               AND status_cred NOT IN ("CC","FF")               

               SELECT NVL(SUM(NVL(monto_vencido,0) + NVL(mto_venc_trasp,0)),0)
                 INTO dSdo_vencido
                FROM bdicred:"informix".sd_maesdos
                WHERE empresa = '001'
                  AND num_credito = cNumcred;
	  
				IF (NVL(dSdo_vencido,0) >= sParamVencido) THEN
				--?Tienes otros crÃÂ©ditos en BanCoppel pendientes de pago. Una vez que los liquides podrÃÂ¡s disponer de tu Anticipo de NÃÂ³mina?
                    UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
                    SET activacion_cobrada = cActCob
                    WHERE numcte = cNumCte
                    AND movil_cuenta  = pNumCel;

					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_10' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
					RETURN cCodRet ;
				END IF;
		END FOREACH;
		
		FOREACH 
           SELECT num_credito,  num_producto
		   INTO cNumcred,  cProducto
             FROM bdicred:"informix".sd_maecredcrd
            WHERE empresa = '001'
              AND numcte = cNumCte
              AND status_cred <> "FF"

           IF cProducto <> '6011' THEN
               SELECT NVL(SUM(NVL(monto_vencido,0) + NVL(mto_venc_trasp,0)),0)
                 INTO dSdo_vencidocrd
                 FROM bdicred:"informix".sd_maesdoscrd
                WHERE empresa = '001'
                  AND num_credito = cNumcred;

               IF (NVL(dSdo_vencidocrd,0) >= sParamVencido) THEN
			   --?Tienes otros crÃÂ©ditos en BanCoppel pendientes de pago. Una vez que los liquides podrÃÂ¡s disponer de tu Anticipo de NÃÂ³mina?
                    UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
                    SET activacion_cobrada = cActCob
                    WHERE numcte = cNumCte
                    AND movil_cuenta  = pNumCel;

                    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_10' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
					RETURN cCodRet ;
			   END IF;
		   END IF;
		END FOREACH;
		
		SELECT nvl(a.fecha_proceso,c.fecha_alta) INTO dtFechaCh --Fecha proceso cheques RQI 25 024
		FROM  bdicheq:"informix".sc_maechq a
		JOIN  bdisolic:"informix".ss_adn_solicitudcuenta b ON a.cuenta = b.cuenta_nomina
		JOIN  bdicheq:"informix".sc_maenoc c ON a.cuenta = c.cuenta
		WHERE a.empresa = '001'
		AND num_solicitud = cNumSol;
		
		
		SELECT fecha_proceso  INTO dtFechaCrd --Fecha proceso credito RQI 25 024
		FROM bdicred:"informix".sd_maecredanexo 
		WHERE empresa = '001'
		AND num_credito = cNumSol;
		
		IF dtFechaCrd = dtFechaCh AND  cfechhoy <= dtFechaCrd THEN  --RQI 25 024
			-- SE GENERA EL FOLIO
			CALL bdicheq:"informix".sp_generafolionomina('ANTICIPO') 
			RETURNING cCod_ret, cNumeroFolio;


			IF NVL(cActCob,'') = '' AND dMontoAct = 0 THEN 		
			--SE REALIZA EL CARGO DE COMISION POR ACTIVACION
			--Se genera movimiento del saldo dispuesto en la cuenta del credito de nomina
				EXECUTE PROCEDURE bdicred:cargo_cred('001', cNumSol, '9250',
				'ANTICIPO','8170', mMontoAct, cNumeroFolio, '', 0, 0, dtFechaCrd, cNombreComAct, "","")INTO cCod_ret; --RQI 25 024	

				IF  cCod_ret::INTEGER = 0 THEN
					--Se registra en la tabla de comisiÃÂ³n para la afectacion contable
					INSERT INTO bdicred:"informix".sd_comision_x_apertura_contable
					(empresa ,num_credito ,sucursal,monto_afectacion,monto_aplicado ,aplica_cobro ,afec_pendientes ,user_insert ,fecha_insert)
					VALUES('001', cNumSol,cSucursal, mMontoAct,0,'0',12,USER,TODAY);	
					LET actCom ='1';

				ELSE
					UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
					SET activacion_cobrada = cActCob
					WHERE numcte = cNumCte
					AND movil_cuenta  = pNumCel;	
					RETURN cCod_ret ;
				END IF;				

			END IF; --TERMINA COBRO DE COMISION POR ACTIVACION
				
			--SE REALIZA EL CARGO POR MONTO DE LA DISPOSICION 
			--Se genera movimiento del saldo dispuesto en la cuenta del credito de nomina
			EXECUTE PROCEDURE bdicred:cargo_cred('001', cNumSol, '9250','ANTICIPO','8174', pSaldo, cNumeroFolio, '', 0, 0, dtFechaCrd, "DISPOSICION", "","")INTO cCod_ret;	--RQI 25 024

			IF cCod_ret::INTEGER = 0 THEN
				--SE REALIZA EL CARGO DE COMISION POR DISPOSICION
				EXECUTE PROCEDURE bdicred:cargo_cred('001', cNumSol, '9250','ANTICIPO','8172', mMontoDispAux,cNumeroFolio, '', 0,0, dtFechaCrd, cNombreComDisp, "","")INTO cCod_ret; --RQI 25 024	
			   
				IF cCod_ret::INTEGER = 0 THEN
					--SE REALIZA ABONO A LA CUENTA DE NOMINA
					CALL bdicheq:"informix".abono_ref ('001', '9250', 'ANTICIPO', '0399', '0399', cNumeroFolio, cCtaNom, 0,
					pSaldo, pSaldo, 0, 0, 0, "01", cNumSol||" "||"Abono Anticipo", '0', 'ANTICIPO') RETURNING cCodRet;
					
					IF  cCodRet::INTEGER = 0 THEN 
						   UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
						   SET activacion_cobrada = '1',
							   fecha_ult_disp =dtFechaCrd , --RQI 25 024
							   monto_disp =  pSaldo + mMontoAct + mMontoDispAux +mIvaMontoAct +mIvaMontoDisp
						 WHERE numcte = cNumCte
						   AND movil_cuenta  = pNumCel;

						--?ÃÂ¡Felicidades!, tu Anticipo de NÃÂ³mina de BanCoppel ha sido depositado a tu cuenta terminaciÃÂ³n XXXX?.
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_11' , '000000000','', '','1', SUBSTR(cCtaNom,8,4), '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;					
					ELSE
						LET reverso ='1';                
					END IF;
				ELSE
					LET reverso ='1';                
				END IF;
			ELSE
				LET reverso ='1';   -- RQI 25 024
			END IF; 

			IF reverso ='1' THEN
				EXECUTE PROCEDURE bdicred:"informix".reversion('001', cSucursal, 'sistema', cNumeroFolio, 'A') INTO v_codret;
				IF v_codret = '000' THEN
					IF actCom='1' THEN
						DELETE FROM bdicred:"informix".sd_comision_x_apertura_contable 
						WHERE empresa='001' AND num_credito=cNumSol AND sucursal=cSucursal AND monto_afectacion=mMontoAct AND fecha_insert= dtFechaCrd;  --RQI 25 024
					END IF

					UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
					SET activacion_cobrada = cActCob
					WHERE numcte = cNumCte
					AND movil_cuenta  = pNumCel;
				END IF;
			END IF;        
		ELSE
		    -- RQI 25 024
			-- Error no cumplir con validaciones de ampliacion de horario. Se envia SMS de error: Por el momento no se puede realizar su peticion. Favor de intentarlo mas tarde.
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_14' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
			RETURN cCodRet ;
			
		END IF;

	END IF;
	
	IF cCodRet='000' THEN
		LET cCodRet='00000';
	END IF;
	
	RETURN cCodRet;
     
END
END PROCEDURE
