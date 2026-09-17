CREATE PROCEDURE "informix".sp_validaradn ( pNumCel  CHAR(20), pSaldo DECIMAL (18,2))
RETURNING CHAR(5),          -- Codigo de Retorno
          VARCHAR(160);      -- Mensaje de Retorno
		  

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

DEFINE cIndCierreCheq 		CHAR(1); --INC 25 097
DEFINE dFechaCierreAdn		DATE; --INC 25 097
DEFINE dFechaHabilAnt		DATE; --INC 25 097
DEFINE cCodRet3 			CHAR(5); --INC 25 097
DEFINE cStatusCierreAdn  	CHAR(1); --INC 25 097
DEFINE vEmpresa             CHAR(3); --INC 25 097
DEFINE dMontoVen			DECIMAL(14,2); --IFRS

--RQI 25 024

DEFINE dtFechaCh			DATE;
DEFINE dtFechaCrd			DATE;
DEFINE cfechhoy			    DATE;
DEFINE cStatusCtaCapta		CHAR(1);


--RQI 09616
DEFINE iTipoNomina,
	   nDiaPago,
	   nDispocion,
	   nDSolicitidas,
	   nDSMovDia,
       dSemana,
       tpId                 INTEGER;
DEFINE fM,
	   fhM                  DATE;
DEFINE dMontoFnc	        DECIMAL(18,2);
DEFINE cMenRet              VARCHAR(160);
DEFINE cCanal               CHAR(1);
DEFINE cNombre              CHAR(26);

-- RQM 09 654

DEFINE ingresoMin			DECIMAL(18,2);
DEFINE ingresoAjustado		DECIMAL(18,2);
DEFINE ultimoMes			DATE;
DEFINE fechaMax				DATETIME YEAR TO SECOND;

-- RQM 09 654

LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "00000";
LET cCod_ret        = "00000";
LET cMen_ret     	= "Proceso Exitoso";


LET sParamVencido     = 0;
LET iValida     	  = 0;
LET dSdo_vencido      = 0;
LET dSdo_vencidocrd   = 0;
LET dMontoMin		  = 0;
LET dMontoMax		  = 0;

LET cNumCte	= "";
LET cCtaNom	= "";
LET cNumSol = "";
LET cActCob	= "";

LET dAnticipo		= 0;
LET dMontoAct		= 0;
LET mMontoAct		= 0;
LET mMontoDisp 		= 0;
LET mMontoDispAux 	= 0;
LET mIvaMontoDisp	= 0;
LET mIvaMontoAct	= 0;
LET cNombreComAct	= "";
LET cNombreComDisp	= "";
LET cNumcred		= "";
LET cProducto		= "";
LET cNumeroFolio	= "";
LET vCveExistente	= 0;
LET dtFechaHoy		= DATE(1);
LET cFechaIni1m		= DATE(1);
LET cHoraIni 		= "";
LET cHoraFin 		= "";
LET cSucursal 		= "";
LET cStatus 		= "";
LET mIvaSuc 		= 0;
LET actCom 			= '0';
LET reverso 		= '0';
LET v_codret		= "00000";
LET iNumReg 		= 0;
LET v_movil_cuenta 	= 0;
LET bandera 		= 0; --INC 25 019

--RQI 25 024
LET dtFechaCh				= DATE(1);
LET dtFechaCrd				= DATE(1);
LET cfechhoy			    = DATE(1);
LET cStatusCtaCapta			= '';

LET cIndCierreCheq			= ""; --INC 25 097
LET dFechaCierreAdn			= DATE(1); --INC 25 097
LET dFechaHabilAnt 			= DATE(1); --INC 25 097
LET cCodRet3				= '00000'; --INC 25 097
LET cStatusCierreAdn    	= ''; --INC 25 097
LET vEmpresa                = '001'; --INC 25 097
LET dMontoVen				= 0; --IFRS

--RQI 09616
LET iTipoNomina = 0;
LET nDiaPago 	= 0;
lET nDispocion 	= 0;
LET nDSolicitidas = 0;
LET fM			= DATE(1);
LET fhM 		= DATE(1);
LET dMontoFnc	= 0;
LET nDSMovDia   = 0;
LET dSemana		= 0;
LET cMenRet     = '';
LET cCanal      = 0;
LET tpId        = 0;
LET cNombre     = '';

-- RQM 09 654

LET ingresoMin		= 0;
LET ingresoAjustado	= 0;
LET ultimoMes		= DATE(1);

-- RQM 09 654

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   
	IF bandera = 1 then --INC 25 019
	    
		ROLLBACK WORK;
		BEGIN WORK;

		UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
		SET activacion_cobrada = cActCob
		WHERE numcte = cNumCte
		AND movil_cuenta  = pNumCel;
		
		COMMIT WORK;
		BEGIN WORK;
		
	ELSE

		UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
		SET activacion_cobrada = cActCob
		WHERE numcte = cNumCte
		AND movil_cuenta  = pNumCel;
	
	END IF;
	
	IF iSqlErr != 0 THEN
		LET cCodRet = iSqlErr;
		RETURN cCodRet,cMenRet;
	END IF;

END EXCEPTION;

   ON EXCEPTION IN (-535) --INC 25 019
      LET bandera = 1; --INC 25 019
      COMMIT WORK;
	  BEGIN WORK;
   END EXCEPTION WITH RESUME;
   
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	 
 	--SET DEBUG FILE TO '/home/sysifx/lalo/sp_validaradn.out';
    --TRACE ON;

	IF NVL(pNumCel,'') = ''  THEN
		RETURN  '00001',cMenRet;
	ELSE
		
		SELECT valor
		INTO sParamVencido
		FROM bdisolic:"informix".ss_param
		WHERE empresa = '001'
		AND secuencia = 350;
		
		SELECT valor
		INTO cHoraIni
		FROM bdisolic:"informix".ss_param
		WHERE empresa = '001'
		AND secuencia = 381;
		
		SELECT valor
		INTO cHoraFin
		FROM bdisolic:"informix".ss_param
		WHERE empresa = '001'
		AND secuencia = 382;
		
		SELECT fecha_hoy
		INTO dtFechaHoy
		FROM  bdicred:"informix".sd_fechas
		WHERE empresa = "001";
		
 		SELECT fecha_hoy
		INTO cfechhoy
		FROM bdinteg:"informix".si_fechas
		WHERE empresa = '001';
		
		select ind_cierre  --INC 25 097
		INTO cIndCierreCheq
		from bdicheq:"informix".sc_fechas
		WHERE empresa = '001';
		
		--validacion del horario para poder realizar las disposiciones
		--IF current hour to second < cHoraIni OR current hour to second >  cHoraFin OR WEEKDAY(dtFechaHoy) in(0,6) THEN
		/*IF current hour to second < cHoraIni OR current hour to second >  cHoraFin  THEN
			--Por el momento no le podemos ofrecer el servicio. Por favor intenta mas tarde.
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_14' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
			RETURN cCodRet ;
		
		END IF*/
		
		/*IF (SELECT  count(a.num_solicitud)
		FROM   bdisolic:"informix".ss_adn_solicitudcuenta a, bdicred:"informix".sd_maecred b, bdicred:"informix".sd_maesdos c
		WHERE movil_cuenta  = pNumCel
		AND a.num_solicitud = b.num_credito
        AND a.num_solicitud = c.num_credito
		and b.empresa ='001')>1 THEN
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_15' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
			RETURN cCodRet;
		END IF;*/

        -- CONSULTA LOS MONTOS MAXIMOS Y MINIMOS QUE SE PUEDEN OTROGAR EN ANTICIPO DE NOMINA -- RQM 09616
        SELECT monto_min_cred, monto_max_cred
		INTO dMontoMin, dMontoMax
		FROM bdicred:"informix".sd_definicion
		WHERE num_producto = '7800';
			
        SELECT   NVL(a.numcte,''), NVL(a.cuenta_nomina,''), NVL(a.num_solicitud,''), NVL(c.monto_otorgado,0), NVL(a.activacion_cobrada,''), NVL(c.sdo_cap_insoluto,0), NVL(b.id_unidad_prod, 0),NVL(b.sucursal,''),NVL(b.status_cred,0),NVL(NVL(monto_vencido,0) + NVL(mto_venc_trasp,0),0), NVL(a.frecuencia_pgo,0), NVL(a.dia_pago,0), NVL(c.monto_financiado,0), d.canal_sol, e.nombre1
        INTO cNumCte, cCtaNom, cNumSol, dAnticipo, cActCob, dMontoAct, vCveExistente, cSucursal, cStatus, dMontoVen, iTipoNomina, nDiaPago, dMontoFnc, cCanal, cNombre --IFRS
        FROM   bdisolic:"informix".ss_adn_solicitudcuenta a, bdicred:"informix".sd_maecred b, bdicred:"informix".sd_maesdos c, bdisolic:ss_solicitudes d, bdinteg:si_cliente e
        WHERE a.movil_cuenta  = pNumCel
        AND a.num_solicitud = b.num_credito
        AND a.num_solicitud = c.num_credito
        AND a.num_solicitud = d.num_solicitud
        AND a.numcte = e.numcte
        and b.empresa = '001';

        IF cCanal IS NULL OR cCanal = '' THEN -- RQM 09616
            SELECT cod_return, mensaje
            INTO cCodRet, cMenRet
            FROM bdisolic:ss_catalogo_mensajes
            WHERE empresa = '001'
            AND cod_msj = 'ADN_15';
            -- Por el momento no podemos ofrecerte el servicio, acude a tu sucursal BanCoppel mas cercana para revisar la situacion de tu cuenta.
            RETURN cCodRet, cMenRet;
        END IF;

        -- RQM 09616
        SELECT tp_id
        INTO tpId
        FROM bdisolic:ss_canal_tiporespuesta
        WHERE empresa = '001'
        AND canal = cCanal;
       
       		-- VALIDAR QUE TENGA UN INGRESO AJUSTADO MINIMO DE N PESOS EN EL MES PREVIO - INICIA RQM 09654
		
	       	SELECT valor
			INTO ingresoMin
			FROM bdisolic:"informix".ss_param
			WHERE empresa = '001'
			AND secuencia = '383';
		
			SELECT MAX(periodo)
			INTO ultimoMes
			FROM bdicheq:"informix".sc_bitacora_movnom
			WHERE id_proceso = 'ingajustado'
			AND fechahora_fin IS NOT NULL;

			SELECT ingreso_ajustado
			INTO ingresoAjustado
			FROM bdicheq:"informix".sc_nom_disp_cte
			WHERE numcte = cNumCte
			AND cuenta = cCtaNom
			AND fecha_pago = ultimoMes;
			
			
			IF NVL(ingresoAjustado,0) < ingresoMin THEN
			
				IF tpId = 1 THEN
	                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('2' , 'ADN_SMS' ,'SM_ADN_NEGA' , cNumCte,'', '','1', ingresoMin, '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;
	                --No pudimos procesar tu Anticipo de Nomina. Tu ingreso nominal debe ser igual o mayor a $2,000. MÃ¡s detalles en bancoppel.com
	                
	                RETURN cCodRet, cMenRet;
					
	            ELIF tpId = 2 THEN
	                SELECT cod_return, mensaje
	                INTO cCodRet, cMenRet
	                FROM bdisolic:ss_catalogo_mensajes
	                WHERE empresa = '001'
	                AND cod_msj = 'ADN_15';
	
	                RETURN cCodRet, cMenRet;
					
	            ELSE
	                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('2' , 'ADN_SMS' ,'SM_ADN_NEGA' , cNumCte,'', '','1', ingresoMin, '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;
	
	                SELECT cod_return, mensaje
	                INTO cCodRet, cMenRet
	                FROM bdisolic:ss_catalogo_mensajes
	                WHERE empresa = '001'
	                AND cod_msj = 'ADN_15';
	                
	                RETURN cCodRet, cMenRet;
	            END IF;
				
			END IF;
			
			-- FIN RQM 09654


        -- VALIDA QUE NO EL MONTO SOLICITADO NO SEA MAYOR A 5 DIGITOS O QUE PIDA MAS DE MONTO MAXIMO -- RQM 09616
        IF pSaldo > dMontoMax THEN

            IF tpId = 1 THEN
                EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('1' , 'ADN_SMS','ADN_SMS_19', cNumCte,'', '','1', TRIM(cNombre), '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0,current, current) INTO cCodRet;
                -- (Nombre), tu solicitud de Anticipo de Nomina no fue procesada. Verifica que la cantidad no exceda el limite de credito y vuelve a intentar.

                IF cCodRet = '000' THEN
                    LET cCodRet = '00000';
                END IF;

                RETURN cCodRet, cMenRet;
            ELIF tpId = 2 THEN
                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_19';

                RETURN cCodRet, (TRIM(cNombre)||cMenRet);
            ELSE
                EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('1' , 'ADN_SMS','ADN_SMS_19', cNumCte,'', '','1', TRIM(cNombre), '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0,current, current) INTO cCodRet;
                --(Nombre), tu solicitud de Anticipo de Nomina no fue procesada. Verifica que la cantidad no exceda el limite de credito y vuelve a intentar.

                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_19';
                
                RETURN cCodRet, (TRIM(cNombre)||cMenRet);
            END IF;
        END IF;

        IF (SELECT  count(a.num_solicitud)
		FROM   bdisolic:"informix".ss_adn_solicitudcuenta a, bdicred:"informix".sd_maecred b, bdicred:"informix".sd_maesdos c
		WHERE movil_cuenta  = pNumCel
		AND a.num_solicitud = b.num_credito
        AND a.num_solicitud = c.num_credito
		and b.empresa ='001')>1 THEN
            IF tpId = 1 THEN
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_15' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;
                
                RETURN cCodRet, cMenRet;
            ELIF tpId = 2 THEN
                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_15';

                RETURN cCodRet, cMenRet;
            ELSE
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_15' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;

                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_15';
                
                RETURN cCodRet, cMenRet;
            END IF;
		END IF;
	
		IF NVL(cActCob,'') = '3' THEN
            IF tpId = 1 THEN
                --Por el momento no le podemos ofrecer el servicio. Por favor intenta mas tarde.
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_14' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
                
                RETURN cCodRet, cMenRet;
            ELIF tpId = 2 THEN
                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_14';

                RETURN cCodRet, cMenRet;
            ELSE
                --Por el momento no le podemos ofrecer el servicio. Por favor intenta mas tarde.
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_14' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;
                
                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_14';
                
                RETURN cCodRet, cMenRet;
            END IF;
		END IF;

         --**OPTIMIZAR
		SELECT COUNT(movil_cuenta) 
		INTO v_movil_cuenta
		FROM bdisolic:"informix".ss_adn_solicitudcuenta
		WHERE movil_cuenta  = pNumCel;
	
        IF (v_movil_cuenta)>0 THEN
		    
		  	BEGIN WORK; --INC 25 019
				UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
				SET activacion_cobrada = '3'--Se utilizara para detectar que ya esta en tramite un anticipo para los casos de sms dobles		
				WHERE numcte = cNumCte
				AND movil_cuenta  = pNumCel
				AND NVL(activacion_cobrada,'')<>'3';
			COMMIT WORK;

			IF (bandera = 1) THEN --INC 25 019
				BEGIN WORK; 
			END IF;
			
			LET iNumReg = dbinfo("sqlca.sqlerrd2");
			
			IF iNumReg = 0 THEN 
                IF tpId = 1 THEN
                    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_5' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
                    
                    RETURN cCodRet, cMenRet;
                ELIF tpId = 2 THEN
                    SELECT cod_return, mensaje
                    INTO cCodRet, cMenRet
                    FROM bdisolic:ss_catalogo_mensajes
                    WHERE empresa = '001'
                    AND cod_msj = 'ADN_5';

                    RETURN cCodRet, cMenRet;
                ELSE
                    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_5' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			

                    SELECT cod_return, mensaje
                    INTO cCodRet, cMenRet
                    FROM bdisolic:ss_catalogo_mensajes
                    WHERE empresa = '001'
                    AND cod_msj = 'ADN_5';
                    
                    RETURN cCodRet, cMenRet;
                END IF;
			END IF; 
		ELSE
            IF tpId = 1 THEN
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_7' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
                
                RETURN cCodRet, cMenRet;
            ELIF tpId = 2 THEN
                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_7';

                RETURN cCodRet, cMenRet;
            ELSE
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_7' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;

                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_7';
                
                RETURN cCodRet, cMenRet;
            END IF;	
		END IF;
		--IFRS Se contemplan los nuevos estatus de credito por etapas de vencido
--        IF (SUBSTR(cStatus,1,1) IN ("B", "F", "C"))  OR (NVL(iact,-1) >=1 and cStatus in ('E1','E2','E3')) THEN  --VALIDA EL STATUS DE LA CUENTA
		IF SUBSTR(cStatus,1,1) IN ("B", "F", "C") or dMontoVen > 0 THEN
            --?Por el momento no podemos ofrecerte el servicio, acude a tu sucursal BanCoppel mas cercana para revisar la situacion de tu cuenta?.				
            UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
			SET activacion_cobrada = cActCob
			WHERE numcte = cNumCte
			AND movil_cuenta  = pNumCel;

            IF tpId = 1 THEN
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_15' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;
                
                RETURN cCodRet, cMenRet;
            ELIF tpId = 2 THEN
                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_15';

                RETURN cCodRet, cMenRet;
            ELSE
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_15' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;

                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_15';
                
                RETURN cCodRet, cMenRet;
            END IF;
            
		END IF;

		--Correccion validacion monto financiado (tiene saldo pendiente a pagar) y saldo activo (que no supere su linea disponible).? -- RQM 09616
		IF dMontoFnc > 0 OR (dMontoAct + pSaldo) > dAnticipo THEN  --Valida que no haya alcanzado el numero maximo de disposiciones o que no pase del limite de linea disponible
			--
			UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
			SET activacion_cobrada = cActCob
			WHERE numcte = cNumCte
			AND movil_cuenta  = pNumCel;

             IF tpId = 1 THEN
                EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('1' , 'ADN_SMS','ADN_SMS_19', cNumCte,'', '','1', TRIM(cNombre), '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0,current, current) INTO cCodRet;
                --(Nombre), tu solicitud de Anticipo de Nomina no fue procesada. Verifica que la cantidad no exceda el limite de credito y vuelve a intentar.
                IF cCodRet = '000' THEN
                    LET cCodRet = '00000';
                END IF;

                RETURN cCodRet, cMenRet;
            ELIF tpId = 2 THEN
                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_19';

                RETURN cCodRet, (TRIM(cNombre)||cMenRet);
            ELSE
                EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('1' , 'ADN_SMS','ADN_SMS_19', cNumCte,'', '','1', TRIM(cNombre), '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0,current, current) INTO cCodRet;
                --(Nombre), tu solicitud de Anticipo de Nomina no fue procesada. Verifica que la cantidad no exceda el limite de credito y vuelve a intentar.
                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_19';
                
                RETURN cCodRet, (TRIM(cNombre)||cMenRet);
            END IF;
		END IF;

		--? Se obtiene la ultima fecha de cobrodbac
        SELECT fecha_ult_pago
        INTO fM
        FROM bdicred:sd_maecredanexo
        WHERE num_credito = cNumSol;
        
        --? Si la columna es nula se resta un mes
        IF (NVL(fM,'') = '') THEN
            LET fhM = dtFechaHoy - 1 UNITS MONTH;
        ELSE
            LET fhM = fM;
        END IF;
        
		--?Correccion rango de fechas para el calculo del numero de disposiciones activas.? --? INC 27 227?
		IF iTipoNomina = 1 THEN
			LET nDispocion = 8;

			-- IF (nDiaPago >= DAY(dtFechaHoy)) THEN
			-- 	LET fM = dtFechaHoy - 1 UNITS MONTH;

			-- 	LET fhM = MDY(MONTH(fM),nDiaPago,YEAR(fM));
			-- ELIF (nDiaPago < DAY(dtFechaHoy)) THEN
			-- 	LET fhM = MDY(MONTH(dtFechaHoy),nDiaPago,YEAR(dtFechaHoy));
			-- END IF;

		ELIF iTipoNomina = 2 THEN
			LET nDispocion = 4;

			-- IF (nDiaPago >= DAY(dtFechaHoy)) THEN
			-- 	LET fM = MDY(MONTH(dtFechaHoy),nDiaPago,YEAR(dtFechaHoy));

			-- 	LET fhM = fM - 15 UNITS DAY;
			-- ELIF (nDiaPago < DAY(dtFechaHoy)) THEN
			-- 	LET fM = dtFechaHoy + 1 UNITS MONTH;

			-- 	LET fhM = MDY(MONTH(fM),nDiaPago,YEAR(fM)) - 15 UNITS DAY;
			-- END IF;

		ELIF iTipoNomina = 3 THEN
			LET nDispocion = 2;

			-- LET dSemana = CASE WHEN WEEKDAY(dtFechaHoy) = 0 THEN 7 ELSE WEEKDAY(dtFechaHoy) END;
			-- LET dSemana = dSemana - nDiaPago;
			-- LET fhM = dtFechaHoy - dSemana UNITS DAY;

		END IF;

		--Se agrego la tabla sd_movdia para el conteo correcto de numero de disposiciones que ha hecho el cliente. -- RQM 09616
		--Correccion rango de fechas para el calculo del numero de disposiciones activas. -- INC 27 227
        --EXTRAER DE MOVDIA PARA SABER SI NO TIENE DISPOSICIONES EN EL Dï¿½A
        SELECT COUNT(secuencia)
        INTO nDSMovDia
        FROM bdicred:sd_movdia
        WHERE num_credito = cNumSol
        AND transacc_suc = "8174"
        AND reversado = 'N'
        AND fecha_mov <= dtFechaHoy;

        --EXTRAER DE MOVHIS PARA SABER SI NO TIENE Mï¿½S DISPOSICIONES
		SELECT COUNT(secuencia)
		INTO nDSolicitidas
		FROM bdicred:sd_movhis
		WHERE num_credito = cNumSol
		AND transacc_suc = "8174"
		AND reversado = 'N'
		AND fecha_mov > fhM
		AND fecha_mov <= dtFechaHoy;
		
		--?Se agrego que si el numero de dispociciones que ha hecho el cliente es igual o mayor al numero asignado por periodicodad de nomina no pueda disponer.? --? RQM 09616?
       	IF nDSMovDia > 0 OR nDSolicitidas >= nDispocion  THEN  --Valida que no haya alcanzado el numero maximo de disposiciones o que no pase del limite de linea disponible
			--?Ya cuentas con tu Anticipo de Nomina, una vez que lo termines de pagar podras solicitar otro?
			UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
			SET activacion_cobrada = cActCob
			WHERE numcte = cNumCte
			AND movil_cuenta  = pNumCel;

			IF tpId = 1 THEN
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_5' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
				
                RETURN cCodRet, cMenRet;
            ELIF tpId = 2 THEN
                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_5';

                RETURN cCodRet, cMenRet;
            ELSE
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_5' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;

                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_5';
                
                RETURN cCodRet, cMenRet;
            END IF;		
		END IF;

        IF NVL(cNumSol,'') =''THEN
		--El numero celular no esta asociado a tu cuenta, acude a tu sucursal BanCoppel mas cercana para asociarlo y puedas solicitar nuevamente tu Anticipo de Nomina?.
			UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
			SET activacion_cobrada = cActCob
			WHERE numcte = cNumCte
			AND movil_cuenta  = pNumCel;
			
            IF tpId = 1 THEN
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_7' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
                
                RETURN cCodRet, cMenRet;
            ELIF tpId = 2 THEN
                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_7';

                RETURN cCodRet, cMenRet;
            ELSE
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_7' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;

                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_7';
                
                RETURN cCodRet, cMenRet;
            END IF;	
		END IF;

        IF vCveExistente > 0 THEN
			--?Por el momento no podemos ofrecerte el servicio, acude a tu sucursal BanCoppel mas cercana para revisar la situacion de tu cuenta?.				
			UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
			SET activacion_cobrada = cActCob
			WHERE numcte = cNumCte
			AND movil_cuenta  = pNumCel;

            IF tpId = 1 THEN
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_15' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;
                
                RETURN cCodRet, cMenRet;
            ELIF tpId = 2 THEN
                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_15';

                RETURN cCodRet, cMenRet;
            ELSE
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_15' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;

                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_15';
                
                RETURN cCodRet, cMenRet;
            END IF;
		END IF;

        -- CONSULTA LOS MONTOS MAXIMOS Y MINIMOS QUE SE PUEDEN OTROGAR EN ANTICIPO DE NOMINA
        -- SELECT monto_min_cred, monto_max_cred 
		-- INTO dMontoMin, dMontoMax
		-- FROM bdicred:"informix".sd_definicion 
		-- WHERE num_producto = '7800';

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
		--Verifica el monto solicitado de tu Anticipo de Nomina e inentalo de nuevo?
			UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
			SET activacion_cobrada = cActCob
			WHERE numcte = cNumCte
			AND movil_cuenta  = pNumCel;

            IF tpId = 1 THEN
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_9' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;
                
                RETURN cCodRet, cMenRet;
            ELIF tpId = 2 THEN
                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_9';

                RETURN cCodRet, cMenRet;
            ELSE
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_9' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;

                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_9';
                
                RETURN cCodRet, cMenRet;
            END IF;
		END IF;
	
		CALL bdicred:"informix".monthadd(dtFechaHoy,- 1) RETURNING cFechaIni1m; 
		
		
		IF (SELECT COUNT(cuenta)		
			FROM bdicheq:"informix".sc_movhis mov
			INNER JOIN bdicred:"informix".sd_transvalprod  tran ON tran.transacc = mov.transacc
			WHERE mov.cuenta = cCtaNom
			AND tran.activo = 2 
			AND mov.cancelad <> 'S'
			AND mov.fech_alt BETWEEN cFechaIni1m AND dtFechaHoy) < 1 THEN 
		
			IF (SELECT COUNT(cuenta)		
				FROM bdicheq:"informix".sc_movhis_old mov
				INNER JOIN bdicred:"informix".sd_transvalprod  tran ON tran.transacc = mov.transacc
				WHERE mov.cuenta = cCtaNom
				AND tran.activo = 2
				AND mov.cancelad <> 'S'
				AND mov.fech_alt BETWEEN cFechaIni1m AND dtFechaHoy) < 1 THEN 
		
			UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
			SET activacion_cobrada = cActCob
			WHERE numcte = cNumCte
			AND movil_cuenta  = pNumCel;

                IF tpId = 1 THEN
                    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_15' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;
                    
                    RETURN cCodRet, cMenRet;
                ELIF tpId = 2 THEN
                    SELECT cod_return, mensaje
                    INTO cCodRet, cMenRet
                    FROM bdisolic:ss_catalogo_mensajes
                    WHERE empresa = '001'
                    AND cod_msj = 'ADN_15';

                    RETURN cCodRet, cMenRet;
                ELSE
                    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_15' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;

                    SELECT cod_return, mensaje
                    INTO cCodRet, cMenRet
                    FROM bdisolic:ss_catalogo_mensajes
                    WHERE empresa = '001'
                    AND cod_msj = 'ADN_15';
                    
                    RETURN cCodRet, cMenRet;
                END IF;
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
				--?Tienes otros creditos en BanCoppel pendientes de pago. Una vez que los liquides podras disponer de tu Anticipo de Nomina?
                    UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
                    SET activacion_cobrada = cActCob
                    WHERE numcte = cNumCte
                    AND movil_cuenta  = pNumCel;

                    IF tpId = 1 THEN
                        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_10' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;
                        
                        RETURN cCodRet, cMenRet;
                    ELIF tpId = 2 THEN
                        SELECT cod_return, mensaje
                        INTO cCodRet, cMenRet
                        FROM bdisolic:ss_catalogo_mensajes
                        WHERE empresa = '001'
                        AND cod_msj = 'ADN_10';

                        RETURN cCodRet, cMenRet;
                    ELSE
                        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_10' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;

                        SELECT cod_return, mensaje
                        INTO cCodRet, cMenRet
                        FROM bdisolic:ss_catalogo_mensajes
                        WHERE empresa = '001'
                        AND cod_msj = 'ADN_10';
                        
                        RETURN cCodRet, cMenRet;
                    END IF;
				END IF;
		END FOREACH;
		
		FOREACH 
           	SELECT num_credito, num_producto
		   	INTO cNumcred, cProducto
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
			   --?Tienes otros creditos en BanCoppel pendientes de pago. Una vez que los liquides podras disponer de tu Anticipo de Nomina?
                    UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
                    SET activacion_cobrada = cActCob
                    WHERE numcte = cNumCte
                    AND movil_cuenta  = pNumCel;

                    IF tpId = 1 THEN
                        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_10' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;
                        
                        RETURN cCodRet, cMenRet;
                    ELIF tpId = 2 THEN
                        SELECT cod_return, mensaje
                        INTO cCodRet, cMenRet
                        FROM bdisolic:ss_catalogo_mensajes
                        WHERE empresa = '001'
                        AND cod_msj = 'ADN_10';

                        RETURN cCodRet, cMenRet;
                    ELSE
                        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_10' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;

                        SELECT cod_return, mensaje
                        INTO cCodRet, cMenRet
                        FROM bdisolic:ss_catalogo_mensajes
                        WHERE empresa = '001'
                        AND cod_msj = 'ADN_10';
                        
                        RETURN cCodRet, cMenRet;
                    END IF;
			   END IF;
		   END IF;
		END FOREACH;
		
		SELECT NVL(a.fecha_proceso, c.fecha_alta), status_cta
		INTO dtFechaCh, cStatusCtaCapta -- Fecha proceso cheques RQI 25 024
		FROM  bdicheq:"informix".sc_maechq a
		INNER JOIN  bdisolic:"informix".ss_adn_solicitudcuenta b ON b.cuenta_nomina = a.cuenta
		INNER JOIN  bdicheq:"informix".sc_maenoc c ON c.cuenta = a.cuenta
		WHERE b.num_solicitud = cNumSol
		AND a.empresa = '001';
		
		
		SELECT fecha_proceso  INTO dtFechaCrd --Fecha proceso credito RQI 25 024
		FROM bdicred:"informix".sd_maecredanexo 
		WHERE empresa = '001'
		AND num_credito = cNumSol;
		
		-- Valida estatus cuenta de nomina. Si esta bloqueada o cancelada rechaza disposicion (1 Vigente, 	4 Inactiva, 	2 Cancelada,	3 Bloqueada).
		IF cStatusCtaCapta NOT IN ('1','4') THEN
		
			UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
			SET activacion_cobrada = cActCob
			WHERE numcte = cNumCte
			AND movil_cuenta  = pNumCel;

            IF tpId = 1 THEN
                --Por el momento no le podemos ofrecer el servicio. Su cuenta de deposito no se encuentra vigente.
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_17' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
                
                RETURN cCodRet, cMenRet;
            ELIF tpId = 2 THEN
                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_17';

                RETURN cCodRet, cMenRet;
            ELSE
                ----Por el momento no le podemos ofrecer el servicio. Su cuenta de deposito no se encuentra vigente.
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_17' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;	

                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_17';
                
                RETURN cCodRet, cMenRet;
            END IF;
		
		END IF;		
		
		
		--IF dtFechaCrd = dtFechaCh AND  cfechhoy <= dtFechaCrd THEN  --RQI 25 024
		
		-- Obtiene fecha del ultimo cierre de Anticipo de Nomina. (Dia habil antes) --INC 25 097				
		SELECT status_proc, fecha INTO cStatusCierreAdn, dFechaCierreAdn FROM bdicred:sd_contproc 
		WHERE proceso = "CierreAdn" AND fecha = (SELECT max(fecha) FROM bdicred:sd_contproc WHERE proceso = "CierreAdn") AND empresa = vEmpresa;

	    -- Obtiene la fecha habil anterior a la fecha integral
		EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil((cfechhoy - 1),'-') INTO cCodRet3, dFechaHabilAnt;			
			
		IF cIndCierreCheq = '1' AND UPPER(cStatusCierreAdn) = 'F' AND dFechaHabilAnt = dFechaCierreAdn THEN  -- Ya concluyeron los cierres de ADN y Cheques 		
		
			-- SE GENERA EL FOLIO
			CALL bdicheq:"informix".sp_generafolionomina('ANTICIPO') 
			RETURNING cCod_ret, cNumeroFolio;


			IF NVL(cActCob,'') = '' AND dMontoAct = 0 THEN 		
			--SE REALIZA EL CARGO DE COMISION POR ACTIVACION
			--Se genera movimiento del saldo dispuesto en la cuenta del credito de nomina
				EXECUTE PROCEDURE bdicred:cargo_cred('001', cNumSol, '9250',
				'ANTICIPO','8170', mMontoAct, cNumeroFolio, '', 0, 0, dtFechaCrd, cNombreComAct, "","") INTO cCod_ret; --RQI 25 024	

				IF  cCod_ret::INTEGER = 0 THEN
					--Se registra en la tabla de comision para la afectacion contable
					INSERT INTO bdicred:"informix".sd_comision_x_apertura_contable
					(empresa ,num_credito ,sucursal,monto_afectacion,monto_aplicado ,aplica_cobro ,afec_pendientes ,user_insert ,fecha_insert)
					VALUES('001', cNumSol,cSucursal, mMontoAct,0,'0',12,USER,TODAY);	
					LET actCom ='1';

				ELSE
					UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
					SET activacion_cobrada = cActCob
					WHERE numcte = cNumCte
					AND movil_cuenta  = pNumCel;	
					RETURN cCod_ret, cMenRet;
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

                        IF tpId = 1 THEN
                            --?ï¿½Felicidades!, tu Anticipo de Nomina de BanCoppel ha sido depositado a tu cuenta terminacion XXXX?.
                            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_11' , cNumCte,'', '','1', SUBSTR(cCtaNom,8,4), '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;
                            
                        ELIF tpId = 2 THEN
                            SELECT cod_return, mensaje||SUBSTR(cCtaNom,8,4)
                            INTO cCodRet, cMenRet
                            FROM bdisolic:ss_catalogo_mensajes
                            WHERE empresa = '001'
                            AND cod_msj = 'ADN_11';

                        ELSE
                            --?ï¿½Felicidades!, tu Anticipo de Nomina de BanCoppel ha sido depositado a tu cuenta terminacion XXXX?.
                            EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_11' , cNumCte,'', '','1', SUBSTR(cCtaNom,8,4), '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;

                            SELECT cod_return, mensaje||SUBSTR(cCtaNom,8,4)
                            INTO cCodRet, cMenRet
                            FROM bdisolic:ss_catalogo_mensajes
                            WHERE empresa = '001'
                            AND cod_msj = 'ADN_11';
                            
                        END IF;
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
					END IF;

					UPDATE bdisolic:"informix".ss_adn_solicitudcuenta
					SET activacion_cobrada = cActCob
					WHERE numcte = cNumCte
					AND movil_cuenta  = pNumCel;
				END IF;
			END IF;        
		ELSE
		
			UPDATE bdisolic:"informix".ss_adn_solicitudcuenta --INC 25 019
			SET activacion_cobrada = cActCob
			WHERE numcte = cNumCte
			AND movil_cuenta  = pNumCel;

		    -- RQI 25 024
			-- Error no cumplir con validaciones de ampliacion de horario. Se envia SMS de error: Por el momento no se puede realizar su peticion. Favor de intentarlo mas tarde.
            IF tpId = 1 THEN
               EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_14' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;
                
                RETURN cCodRet, cMenRet;
            ELIF tpId = 2 THEN
                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_14';

                RETURN cCodRet, cMenRet;
            ELSE
                -- RQI 25 024
                -- Error no cumplir con validaciones de ampliacion de horario. Se envia SMS de error: Por el momento no se puede realizar su peticion. Favor de intentarlo mas tarde.
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_14' , cNumCte,'', '','1', '', '', '', '', '', '', '', '', '', '', '', pNumCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;

                SELECT cod_return, mensaje
                INTO cCodRet, cMenRet
                FROM bdisolic:ss_catalogo_mensajes
                WHERE empresa = '001'
                AND cod_msj = 'ADN_14';
                
                RETURN cCodRet, cMenRet;
            END IF;
			
		END IF;
	END IF;
	
	IF cCodRet='000' THEN
		LET cCodRet='00000';
	END IF;
	
	RETURN cCodRet, cMenRet;
     
END
END PROCEDURE
