CREATE PROCEDURE "informix".sp_calcprifechabo_sd (	pPeriodicidad CHAR (2), 
													pFechCrea DATE,
													pHoraCrea CHAR(8),
													pDiaDelCobro CHAR(10)) ----vDiaDelCobro CHAR(10) --Incremental 2
	RETURNING CHAR(5), DATE;


    DEFINE vsqlerr          	INTEGER;
    DEFINE iIsamErr         	SMALLINT;
    DEFINE cErrorInfo       	CHAR(80);
	DEFINE vErrorInfo       	CHAR(80);
    DEFINE vCodRet         		CHAR(5);
	
	DEFINE vPrim_abo_auto	DATE;
	DEFINE vDiaSem			INTEGER;
	DEFINE vUlt_dia_mes		DATE;
	DEFINE vPri_dia_mes		DATE;
	DEFINE vDiames			INTEGER;
	DEFINE vAjuste			INTEGER;
	DEFINE vMes				INTEGER;
	DEFINE vDiaDelCobro		CHAR(10);
	DEFINE vDia_vali		INTEGER;
	DEFINE vMes_vali		INTEGER;
	DEFINE vAnio_vali		INTEGER;
	DEFINE vUdia_vali		INTEGER;
	
    LET vsqlerr         	    = 0; 
    LET iIsamErr                = 0;
    LET cErrorInfo              = "";   
    LET vErrorInfo              = "INICIO DEL PROCESO";
    LET vCodRet                 = "00000";
	
	LET vPrim_abo_auto			= "";
	LET vDiaSem					= 0;
	LET vUlt_dia_mes			= "";
	LET vPri_dia_mes			= "";
	LET vDiames					= 0;
	LET vAjuste					= 0;
	LET vMes					= 0;
	LET vDiaDelCobro			= pDiaDelCobro;
	LET vDia_vali				= 0;
	LET vMes_vali				= 0;
	LET vAnio_vali				= 0;
	LET vUdia_vali				= 0;
	
	BEGIN
		ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
			IF  vsqlerr != 0 THEN
				--SET DEBUG FILE TO "/informix/c90186322/trace/sp_calcprifechabo_sd.txt";
				--TRACE ON;
				LET vCodRet    = vsqlerr;
				LET vErrorInfo = cErrorInfo;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/informix/c90186322/trace/sp_calcprifechabo_sd.txt";
		--TRACE ON;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;  

		IF pPeriodicidad = "1" THEN			
			LET vDiaDelCobro = pDiaDelCobro - 1;
		END IF;

		IF 
			vDiaDelCobro IS NOT NULL AND vDiaDelCobro <> "" AND (
				(pPeriodicidad = 1 AND vDiaDelCobro NOT BETWEEN 0 AND 6) OR
				(pPeriodicidad = 2) OR
				(pPeriodicidad = 3 AND vDiaDelCobro NOT BETWEEN 1 AND 30))
		THEN
			LET vCodRet = '000'; --Fecha invalida (El dia de cobro es invalido, debe ser de 1 a 30.)
			RETURN vCodRet, vPrim_abo_auto;
		END IF;

		SELECT pri_dia_mes, ult_dia_mes
		INTO vPri_dia_mes, vUlt_dia_mes
		FROM "informix".sc_fechas;	

		--Valida periodicidad semanal
		IF pPeriodicidad = 1 THEN
			
			SELECT WEEKDAY (pFechCrea) 
			INTO   vDiaSem
			FROM   "informix".sc_fechas;
			
			--El dia de cobro serÃ­a los lunes (por default)
			IF vDiaDelCobro = "" THEN
				--Verifica que dia de la semana es
				IF vDiaSem = 1 THEN --LUNES
					--Verifica la hora de alta
					IF (pHoraCrea < "17:50:00") THEN
						LET vPrim_abo_auto = pFechCrea;
					ELSE
						LET vPrim_abo_auto = pFechCrea + 7;
					END IF;
				END IF;
					
				IF vDiaSem = 2 THEN --MARTES
					LET vPrim_abo_auto = pFechCrea + 6;
				END IF;
					
				IF vDiaSem = 3 THEN --MIERCOLES
					LET vPrim_abo_auto = pFechCrea + 5;
				END IF;

				IF vDiaSem = 4 THEN --JUEVES
					LET vPrim_abo_auto = pFechCrea + 4;
				END IF;
				IF vDiaSem = 5 THEN --VIERNES
					LET vPrim_abo_auto = pFechCrea + 3;
				END IF;
				IF vDiaSem = 6 THEN --SABADO
					LET vPrim_abo_auto = pFechCrea + 2;
				END IF;

				IF vDiaSem = 0 THEN --DOMINGO
					LET vPrim_abo_auto = pFechCrea + 1;
				END IF;
			END IF;

			--El dia de cobro es personalizado
			IF vDiaDelCobro <> "" THEN
				IF vDiaSem = vDiaDelCobro THEN
					--Verifica la hora de alta
					IF (pHoraCrea < "17:50:00") THEN
						LET vPrim_abo_auto = pFechCrea;
					ELSE
						LET vPrim_abo_auto = pFechCrea + ABS(7 - (vDiaSem - vDiaDelCobro));
					END IF;
				END IF;
					
				IF vDiaSem <> vDiaDelCobro THEN
					IF (vDiaSem > vDiaDelCobro) THEN
						LET vPrim_abo_auto = pFechCrea + ABS(7 - ABS(vDiaSem - vDiaDelCobro));
					ELSE
						LET vPrim_abo_auto = pFechCrea + ABS(vDiaSem - vDiaDelCobro);
					END IF;
				END IF;
			END IF;

			LET vDiames	= DAY(vPrim_abo_auto);
			LET vMes 	= MONTH (vPrim_abo_auto);
		END IF;

		--Valida periodicidad quincenal
		IF pPeriodicidad = 2 THEN

			--Saca el dÃ­a del mes
			SELECT DAY(pFechCrea) 
			INTO   vDiames
			FROM   "informix".sc_fechas;
			
			SELECT MONTH(pFechCrea) 
			INTO   vMes
			FROM   "informix".sc_fechas;
			
			IF vDiames = 15 THEN
				IF (pHoraCrea > "17:50:00") THEN	
					LET vPrim_abo_auto = pFechCrea + 15;
					IF vMes = 2 THEN
						LET vPrim_abo_auto = vUlt_dia_mes;
					END IF;			
				ELSE
					LET vPrim_abo_auto = pFechCrea;
				END IF;
			END IF;
			
			IF vDiames = 30 THEN
				IF (pHoraCrea < "17:50:00") THEN
					LET vPrim_abo_auto = pFechCrea;
				ELSE
					LET vPrim_abo_auto = vUlt_dia_mes + 15;
				END IF;
			END IF;
			
			IF vDiames < 15 THEN
				LET vAjuste = 15 - vDiames;
				LET vPrim_abo_auto = pFechCrea + vAjuste;
			END IF;
			
			IF vDiames > 15 AND vDiames < 30 THEN
			
				IF vMes = 2 THEN
					IF (pHoraCrea < "17:50:00") THEN
						LET vPrim_abo_auto = vUlt_dia_mes;
					ELSE
						LET vPrim_abo_auto = vUlt_dia_mes + 15;
					END IF;
				ELSE
					LET vAjuste = 30 - vDiames;
					LET vPrim_abo_auto = pFechCrea + vAjuste;
				END IF;
				
			END IF;
			
			IF vDiames = 31 THEN
				LET vPrim_abo_auto = vUlt_dia_mes + 15;
			END IF;			

		END IF;

		--Valida periodicidad Mensual
		IF pPeriodicidad = 3 THEN
			
			--El dia de cobro serÃ­a los dia primero (por default)
			IF vDiaDelCobro = "" THEN
				IF vPri_dia_mes = pFechCrea THEN
				
					IF (pHoraCrea < "17:50:00") THEN
						LET vPrim_abo_auto = vPri_dia_mes;
					ELSE
						LET vPrim_abo_auto = vUlt_dia_mes + 1;
					END IF;

				ELSE
					LET vPrim_abo_auto = vUlt_dia_mes + 1;
				END IF;
			END IF;

			--El dia de cobro es personalizado
			IF vDiaDelCobro <> "" THEN
				LET vDia_vali = vDiaDelCobro;

				IF vDiaDelCobro = DAY(pFechCrea) AND pHoraCrea < "17:50:00" THEN
					LET vPrim_abo_auto = pFechCrea;
				ELIF vDiaDelCobro > DAY(pFechCrea) THEN
					IF vDiaDelCobro > DAY(vUlt_dia_mes) THEN
						IF MONTH(pFechCrea) = "2" THEN
							IF DAY(pFechCrea) < DAY(vUlt_dia_mes) AND vDiaDelCobro > DAY(vUlt_dia_mes) THEN
								LET vDia_vali = DAY(vUlt_dia_mes);
							END IF;
							IF DAY(pFechCrea) = DAY(vUlt_dia_mes) OR DAY(pFechCrea) > vDiaDelCobro THEN
								LET vMes_vali = MONTH(ADD_MONTHS(pFechCrea, 1));
							END IF;
						ELSE
							LET vDia_vali = DAY(vUlt_dia_mes);
						END IF;
					END IF;
						IF DAY(pFechCrea) = DAY(vUlt_dia_mes) AND vDiaDelCobro > DAY(vUlt_dia_mes) THEN
							LET vMes_vali = MONTH(vUlt_dia_mes+1);
						ELSE
							LET vMes_vali = MONTH(pFechCrea);
						END IF;
						LET vAnio_vali = YEAR(pFechCrea);
						LET vPrim_abo_auto = MDY(vMes_vali, vDia_vali, vAnio_vali);
				ELSE
					IF MONTH(pFechCrea) = "1" AND vDiaDelCobro > DAY(LAST_DAY(vUlt_dia_mes+1)) THEN
						LET vDia_vali = DAY(LAST_DAY(vUlt_dia_mes+1));
						LET vMes_vali = "2";
						LET vAnio_vali = YEAR(pFechCrea);
					ELSE
						LET vMes_vali = MONTH(ADD_MONTHS(pFechCrea, 1));
						LET vAnio_vali = YEAR(ADD_MONTHS(pFechCrea, 1));
					END IF;
					LET vPrim_abo_auto = MDY(vMes_vali, vDia_vali, vAnio_vali);
				END IF;
			END IF;

			LET vDiames	= DAY(vPrim_abo_auto);
			LET vMes 	= MONTH (vPrim_abo_auto);

		END IF;

		IF (vMes = "1" AND vDiames = "1") OR (vMes = "12" AND vDiames = "25") THEN
			LET vPrim_abo_auto = vPrim_abo_auto + 1;
		END IF;

		IF vMes = "2" AND vDiames = "29" AND pPeriodicidad <> 1 THEN
			LET vPrim_abo_auto = vPrim_abo_auto - 1;
		END IF;

		RETURN vCodRet, vPrim_abo_auto;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA CORREGIR EL CALCULO DE PROXIMA FECHA DE ABONO AUTOMATICO LOS DIAS FERIADOS EN LAS PERIODICIDADES SEMANAL Y MENSUAL',
'AUTOR : 95358897 - ISARAI BOJORQUEZ',
'FECHA : 07/02/2023',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_cobroauto_sd(pEmpresa VARCHAR(3)) 
	
	RETURNING CHAR (5);		  
			
    DEFINE vsqlerr         INTEGER;
    DEFINE iIsamErr        SMALLINT;
    DEFINE cErrorInfo      CHAR(80);
	DEFINE vErrorInfo      CHAR(80);
    DEFINE vCodRet         CHAR(5);
	DEFINE vDiaDelCobro	   CHAR(10);
	DEFINE vFecha_hoy      DATE;     
	DEFINE vCuenta_eje     CHAR(20);
	DEFINE vCuenta_sd      CHAR(20);
	DEFINE vMonto_ahor_auto MONEY(14,2);
	DEFINE vPeriodo         INT;
	DEFINE vFecha_meta      DATE;
	DEFINE vMonto_meta      MONEY(14,2);
	DEFINE vMonto_acum      MONEY(14,2);
	DEFINE vMontUlPag       MONEY(14,2);
	DEFINE vEstatus         INT;
	DEFINE vtranret         CHAR(4);
	DEFINE vfechoy          DATE;
	DEFINE vsdodisp         MONEY(14,2);
	DEFINE vmontoret        MONEY(14,2);
	DEFINE vEmpresa         CHAR(3);
	DEFINE vSucursal       CHAR(4);
	DEFINE vUsuario        CHAR(8);
	DEFINE vTranCarsd      CHAR(4);
	DEFINE vNumTRa         CHAR(4);
	DEFINE vFolio          CHAR(16);
	DEFINE vHora           CHAR(12);
	DEFINE vEstaSD         CHAR(1);
	DEFINE VusuMovAbo      CHAR(10);
	DEFINE vFecOper		   DATE;
	DEFINE vHorOper		   CHAR(8);
	DEFINE vTipAh          CHAR(2);
	DEFINE v_c_vcomienza   SMALLINT;
	DEFINE ven_transacc    SMALLINT;
	DEFINE v_c_vcontador   INTEGER;
	DEFINE vCodRet1        CHAR(5);
	DEFINE vRetProxFech    DATE;
	DEFINE vNumCte         CHAR(20);
	DEFINE vNombre_sd	   CHAR(18);
	DEFINE vSp_CodRet      CHAR(5);
	DEFINE mMtoAcumNvo     MONEY(14,2);
	DEFINE vPeriodicidad   CHAR(2);

	---VALIDA SALDO DISPONIBLE
	DEFINE v_ret1        CHAR(5);
    DEFINE v_ret2        CHAR(20);
    DEFINE v_ret3        CHAR(20);
    DEFINE v_ret4        CHAR(26);
    DEFINE v_ret5        CHAR(26);
    DEFINE v_ret6        CHAR(26);
    DEFINE v_ret7        CHAR(26);
    DEFINE v_ret8        CHAR(60);
    DEFINE v_ret9        CHAR(1);
    DEFINE v_ret10       MONEY(14,2);
    DEFINE v_ret11       MONEY(14,2);
    DEFINE v_ret12       MONEY(14,2);
    DEFINE v_ret13       MONEY(14,2);
    DEFINE v_ret14       MONEY(14,2);
    DEFINE v_ret15       CHAR(1);
    DEFINE v_ret16       CHAR(40);
    DEFINE v_ret17       CHAR(40); 
    DEFINE v_ret18       MONEY(14,2);
	DEFINE v_ret19       MONEY(14,2);
	DEFINE v_ret20       MONEY(14,2);
	DEFINE v_ret21       CHAR(8);
	DEFINE v_ret22       DATE;
	DEFINE v_ret23       CHAR(16);
	DEFINE v_ret24       CHAR(18);
	
    LET vsqlerr            = 0; 
    LET iIsamErr           = 0;
    LET cErrorInfo         = "";   
    LET vErrorInfo         = "INICIO DEL PROCESO";
    LET vCodRet            = "00000";
	LET vDiaDelCobro		   = "";
	LET vCuenta_eje        = "";
	LET vCuenta_sd         = "";
	LET vMonto_ahor_auto   = 0.00;
	LET vPeriodo           = 0;
	LET vMonto_meta        = 0;
	LET vMonto_acum        = 0;
	LET mMtoAcumNvo        = 0;
	LET vMontUlPag         = 0;
	LET vEstatus           = 0;
	LET vtranret           = " ";
	LET vfechoy            = " ";
	LET vsdodisp           = 0;
	LET vmontoret          = 0;
	LET vEmpresa           = "001";
	LET vSucursal          = " ";
	LET vUsuario           = 'informix';
	LET vTranCarsd         = " ";
	LET vNumTRa            = " ";
	LET vFolio         	   = " ";
	LET vHora              = '';
	LET VusuMovAbo         = "";
	LET vFecOper           = "";
	LET vHorOper           = "";
	LET vTipAh             = "";
	LET v_c_vcomienza      = -1;
	LET ven_transacc       = 0;
	LET v_c_vcontador      = 0;
    LET vCodRet1           = "";
	LET vRetProxFech       = "";
	LET vNumCte            = "";
	LET vNombre_sd         = "";
	LET vSp_CodRet         = '00000';
	LET vPeriodicidad      ='';

	--VALIDA SALDO DISPONIBLE
	LET v_ret1         = "";
	LET v_ret2         = '';
	LET v_ret3         = '';
	LET v_ret4         = '';
	LET v_ret5         = '';
	LET v_ret6         = '';
	LET v_ret7         = '';
	LET v_ret8         = '';
	LET v_ret9         = '';
	LET v_ret10        = 0 ;
	LET v_ret11        = 0 ;
	LET v_ret12        = 0 ;
	LET v_ret13        = 0 ;
	LET v_ret14        = 0 ;
	LET v_ret15        = " ";
	LET v_ret16        = '';
	LET v_ret17        = "";
	LET v_ret18        = 0 ;
	LET v_ret19        = 0 ;
	LET v_ret20        = 0;
	LET v_ret21        = " ";
	LET v_ret22        = "";
	LET v_ret23        = '';
	LET v_ret24        = "";

    BEGIN
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
	    IF  vsqlerr != 0 THEN
            --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cobroauto_sd.txt";
	 	    --TRACE ON;
			LET vCodRet    = vsqlerr;
            LET vErrorInfo = cErrorInfo;
		    LET vCuenta_eje= vCuenta_eje;
			IF ven_transacc = 1 THEN
               ROLLBACK WORK;
            END IF;
	        RETURN vCodRet;
        END IF;
    END EXCEPTION;
	
   -- SET DEBUG FILE TO '/informix/c90186322/trace/sp_cobroauto_sd.txt';
   -- TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;  
	SET ISOLATION TO committed read;
	
	--SE OBTIENE LA FECHA DEL PROCESO (FECHA DEL DIA ACTUAL)
	SELECT fecha_hoy
	INTO   vFecha_hoy
	FROM   "informix".sc_fechas;
	
	--TRANSACCION 0601 EN PARAMETROS
	SELECT valor  
	INTO   vNumTRa
	FROM   "informix".sc_param 
	WHERE  codparam = 'tranabonosd';
	
	--TRANSACCION 0601 EN SC_TRANSACCION
	SELECT numero
	INTO   vTranCarsd
	FROM   bdinteg: "informix".si_transacc
	WHERE  numero = vNumTRa
	AND    sistema = '01'
	AND    empresa = "001";
	
	--CUANDO EL AHORRO SEA DESDE LA APP, AHORRO SERA SIEPRE 2 = AUTOMATICO
	SELECT  id
	INTO    vTipAh
	FROM    "informix".sc_tipo_ahor
	WHERE   id = "2";	
	
	---INICIALIZA LA TABLA DEL LOG
    DELETE FROM "informix".sc_detauto_sd
	WHERE fech_proc = vFecha_hoy - 1;

	--Se buscan los Sobres que se le hara el cobro automatico 
	--*************************************************************************
	FOREACH WITH HOLD 
		
		SELECT cuenta_eje,  cuenta_sd, monto_ahor_auto,  monto_meta, monto_acum,  periodo,  fecha_meta,  estatus, nombre_sd, periodicidad, dia_del_cobro
			INTO   vCuenta_eje, vCuenta_sd,vMonto_ahor_auto, vMonto_meta,vMonto_acum, vPeriodo, vFecha_meta, vEstaSD, vNombre_sd, vPeriodicidad,vDiaDelCobro
		FROM   "informix".sc_mae_sd
		WHERE  (prox_fech_abo_auto = vFecha_hoy OR fecha_meta = vFecha_hoy)
			AND    tipo_apartado = "1" --Incremental 2
			AND    estatus = "1" AND    periodo > 0
			AND    monto_meta > monto_acum

		-- ABRE LA TRANSACCION 
		IF  (v_c_vcomienza = -1) THEN
			LET v_c_vcomienza = 0;
			LET ven_transacc = 1;
			BEGIN WORK;
		END IF;

		--CALCULO DEL ULTIMO PAGO 
		LET mMtoAcumNvo = NVL(vMonto_acum + vMonto_ahor_auto,0);
					
		IF  vPeriodo = 1 THEN
			IF mMtoAcumNvo > vMonto_meta THEN
				LET vMontUlPag = NVL(vMonto_meta - vMonto_acum,0);
				LET mMtoAcumNvo = NVL(vMonto_acum + vMontUlPag,0);
				LET vMonto_ahor_auto = vMontUlPag;
			ELSE
				LET vMontUlPag = NVL((vMonto_meta - mMtoAcumNvo),0);
				IF vMontUlPag <= 1 THEN
					LET mMtoAcumNvo = mMtoAcumNvo + vMontUlPag;
					LET vMonto_ahor_auto = vMonto_ahor_auto + vMontUlPag;
				END IF;
			END IF;
		END IF;

		--DATOS DE LA CUENTA EJE
		SELECT status_cta, sucursal,   num_cte
		INTO   vEstatus,   vSucursal,  vNumCte
		FROM   "informix".sc_maechq 
		WHERE  cuenta = vCuenta_eje;
			
		--VALIDA EL ESTATUS DE LA CUENTA EJE
		IF  vEstatus = "1" THEN 
					
			--OBTIENE EL SALDO DISPONIBLE DE LA CUENTA EJE
			EXECUTE PROCEDURE "informix".cons_sdos1("001",vCuenta_eje,'')
							INTO v_ret1,v_ret2,v_ret3,v_ret4,v_ret5,v_ret6,v_ret7,v_ret8,v_ret9,v_ret10,v_ret11,v_ret12,v_ret13,v_ret14,
							v_ret15,v_ret16,v_ret17,v_ret18,v_ret19,v_ret20,v_ret21,v_ret22,v_ret23,v_ret24; 
			
			--VALIDA SI LA CUENTA EJE TIENE EL SALDO DISPONIBLE PARA REALIZAR EL AHORRO       
			IF 	v_ret10 >= vMonto_ahor_auto THEN 
			
				-- FOLIO DEL MOVIMIENTO 
				LET vHora  = CURRENT HOUR TO FRACTION;
				LET vFolio = vUsuario||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
														
				--SE INVOCA EL PROCESO PARA RETENER EL SALDO        
				CALL "informix".cargo_ref( vEmpresa,-- empresa
								vSucursal,   -- sucursal
								vUsuario,    -- usuario
								vTranCarsd,  -- transaccion central
								"0000",      -- transaccion sucursal
								vFolio,      -- folio
								vCuenta_eje, -- cuenta
								0,           -- cheque
								vMonto_ahor_auto, -- monto transaccion
								"01",        -- divisa
								"SOBRE DIG RET", -- referencia
								" ",             -- no. tarjeta
								" ")             -- usuario autoriza
								RETURNING  vCodRet, vtranret, vfechoy, vsdodisp, vmontoret;
				
				IF  vCodRet = "000" THEN 
					
					--SE OBTIENE LA PROXIMA FECHA DE ABONO
					EXECUTE PROCEDURE "informix".sp_calcprifechabo_sd(vPeriodicidad,vFecha_hoy,"21:00:00",vDiaDelCobro)
					INTO vCodRet1, vRetProxFech;
					
					LET vPeriodo = NVL((vPeriodo - 1),0);
					
					IF vPeriodo = 0 THEN
						LET vRetProxFech = "";
					END IF;
					
					--ACTUALIZA LA TABLA MESTRA CON EL ABONO
					UPDATE  "informix".sc_mae_sd
					SET     monto_acum = mMtoAcumNvo,	
							periodo    = vPeriodo, 
							ult_fech_abo_auto = vFecha_hoy,	
							prox_fech_abo_auto = vRetProxFech,
							fecha_proc = vFecha_hoy
					WHERE   cuenta_eje = vCuenta_eje AND  cuenta_sd  = vCuenta_sd;
																			
					--CREA EL FOLIO A RETORNAR
					LET VusuMovAbo =  "SD"|| SUBSTR(vFolio,9,8);
					
					--FECHA DEL MOVIMIENTO
					LET vFecOper = vFecha_hoy; 
					
					--HORA DE LA OPERACION 	
					SELECT FIRST 1 CURRENT HOUR TO SECOND as hora_inicio 
					INTO   vHorOper
					FROM   "informix".sc_fechas
					WHERE  empresa = "001";
			
					--INSERTA EL MOVIMIENTO
					INSERT INTO "informix".sc_mov_sd VALUES (vCuenta_eje,vCuenta_sd,VusuMovAbo,1,1,vFecOper,vHorOper,vMonto_ahor_auto,vTipAh);

					IF vPeriodo = "0" THEN 	
						
						IF mMtoAcumNvo =  NVL(vMonto_meta,0) THEN
							UPDATE "informix".sc_mae_sd
							SET estatus = 3,
							periodo = 0,
							prox_fech_abo_auto = ""
							WHERE  cuenta_eje = vCuenta_eje AND cuenta_sd  = vCuenta_sd;
							----NOTIFICACION PUSH
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','PNS_BEX','SD_CUMPP',vNumCte,'','','1','','','','',vNombre_sd,
							'','','','','','','',1,0,0,0,0,'','') INTO vSp_CodRet;
						END IF;
						
					END IF; 
					
					--INSERTA EL REGISTRO EN EL LOG
					INSERT INTO "informix".sc_detauto_sd VALUES (vCuenta_eje,vCuenta_sd,vMonto_ahor_auto,vFecha_hoy,vCodRet||vSp_CodRet);
					
					LET vSp_CodRet = '00000';

				END IF; 
			ELSE
				
				--SE OBTIENE LA PROXIMA FECHA DE ABONO
				EXECUTE PROCEDURE "informix".sp_calcprifechabo_sd(vPeriodicidad,vFecha_hoy,"21:00:00",vDiaDelCobro) INTO vCodRet1, vRetProxFech;
				
				LET vPeriodo = NVL((vPeriodo - 1),0);
					
				IF vPeriodo = 0 THEN
					LET vRetProxFech = "";
				END IF;
										
				UPDATE  "informix".sc_mae_sd
				SET     periodo    = vPeriodo,
						fecha_proc = vFecha_hoy, 
						prox_fech_abo_auto = vRetProxFech								
				WHERE   cuenta_eje = vCuenta_eje
				AND     cuenta_sd  = vCuenta_sd; 
				
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','PNS_BEX','SD_SINRP',vNumCte,'','','1','','','','',vNombre_sd,'','','','','','','',1,0,0,0,0,'','') 
				INTO vSp_CodRet;
				
				--INSERTA EL REGISTRO EN EL LOG 
				--CUENTA EJE SIN SALDO DISPONIBLE 
				INSERT INTO "informix".sc_detauto_sd VALUES (vCuenta_eje,vCuenta_sd,vMonto_ahor_auto,vFecha_hoy,"00021"||vSp_CodRet );
				
				LET vSp_CodRet = '00000';

				CONTINUE FOREACH;
			END IF;		
		END IF;	

		IF (vEstatus <> "1" OR vCodRet <>  "000") THEN

			IF(vEstatus <> "1") THEN
				LET vCodRet = '00002';
			END IF;	

			LET vPeriodo = NVL((vPeriodo - 1),0);
			
			UPDATE  "informix".sc_mae_sd
			SET     periodo    = vPeriodo,
					fecha_proc = vFecha_hoy 					
			WHERE   cuenta_eje = vCuenta_eje AND  cuenta_sd  = vCuenta_sd; 
			
			--INSERTA EL REGISTRO EN EL LOG
			INSERT INTO "informix".sc_detauto_sd VALUES (vCuenta_eje,vCuenta_sd,vMonto_ahor_auto,vFecha_hoy,vCodRet);
			
			CONTINUE FOREACH;
		END IF;	

		LET v_c_vcontador = v_c_vcontador + 1;
		--REALIZA COMMIT CADA 1000 REGISTROS 
		IF (v_c_vcontador >= 1000) THEN
			LET v_c_vcontador = 0;
			COMMIT WORK;
			BEGIN WORK;
		END IF;

	END FOREACH;

    --SI LA TRANSACCION ESTA ABIERTA REALIZA EL COMMIT
	IF  ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;	

  	LET  vCodRet = "00000";
 
RETURN  vCodRet;
END; 
END PROCEDURE
DOCUMENT
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA AGREGAR ESTATUS 3 DE FINALIZADO CUANDO EL APARTADO HA LLEGADO A SU META',
'AUTOR : 95358897 - ISARAI BOJORQUEZ',
'FECHA : 07/02/2023',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_crea_sd(pCuenta_eje CHAR(20), pFechCrea DATE, pHoraCrea CHAR(8), pNombre_sd CHAR (18),
	pIcono CHAR(2), pColor CHAR(2), pMonto_meta MONEY (14,2), pFecha_meta DATE, pPeriodo INTEGER, pMontAboAuto MONEY(14,2),
	pPeriodicidad INTEGER, pCanal CHAR(2), pTipo_apartado CHAR(2), pDia_del_cobro CHAR(10)) --pTipo_apartado CHAR(2), pDia_del_cobro CHAR(10) --Incremental 2
								
	RETURNING CHAR (5),CHAR(20),CHAR(20),DATE,CHAR(8),CHAR(18),CHAR(2),CHAR(2),DATE, MONEY (14,2),
		      MONEY (14,2),	MONEY (14,2),INTEGER,DATE,DATE,INTEGER,CHAR(2),CHAR(2),CHAR(10);
	
		
    DEFINE vsqlerr          	INTEGER;
    DEFINE iIsamErr         	SMALLINT;
    DEFINE cErrorInfo       	CHAR(80);
	DEFINE vErrorInfo       	CHAR(80);
    DEFINE vCodRet         		CHAR(5);
	DEFINE vCuenta_eje			CHAR(20);
	DEFINE vFecha_oper			DATE;
	DEFINE vHora_oper			CHAR(8);
	DEFINE vNombre_sd			CHAR(18);
	DEFINE vIcono				CHAR(2);
	DEFINE vColor				CHAR(2);
	DEFINE vMonto_meta			MONEY(14,2);
	DEFINE vFecha_meta			DATE;
	DEFINE vMonto_acum			MONEY(14,2);
	DEFINE vMontAboAuto		    MONEY(14,2);
	DEFINE vPeriodicidad		INTEGER;		
	DEFINE vProducto			CHAR(4);
	DEFINE vEstatus				CHAR(1);
	DEFINE vCuenta_sd			CHAR(20);
	DEFINE vFechUltAbo	        DATE;
	DEFINE vProxAboAut 	        DATE;
	DEFINE iContSobre			INTEGER;
	DEFINE vEst_sd				INTEGER;
	DEFINE vCanal               CHAR(2);
	DEFINE vConSd               INTEGER;
	DEFINE vLonSD               INTEGER;
	DEFINE vdIFerencia          SMALLINT;
	DEFINE vLoncons             INTEGER;
	DEFINE vValiser             INTEGER;
	DEFINE iContProd            INTEGER;
	DEFINE vFechaHoy            DATE;  
	DEFINE iContIcono           INTEGER;
	DEFINE iContColor           INTEGER;
	DEFINE iContPer             INTEGER;
	DEFINE vDiaPer              INTEGER;
	DEFINE vValPer              INTEGER;
	DEFINE vEsPeriVal           INTEGER;
	DEFINE vNotCuenta           CHAR(8);
	DEFINE vNotMonto            CHAR(9);
	DEFINE vSp_CodRet           CHAR(5);
	DEFINE vIdPlantillaPush		CHAR(12);
	DEFINE vNumCte              CHAR(20);
	DEFINE vFecha_oper_not      CHAR(10);    
	DEFINE vFecha_meta_not      CHAR(10);
    DEFINE vProxAboAut_not      CHAR(10);
	DEFINE vFecha_proc          DATE;
	DEFINE iContDif             SMALLINT;
	DEFINE cNombCanal			CHAR(20);
	DEFINE vTipo_apartado		CHAR(2); 		--Incremental 2
	DEFINE vDia_del_cobro 		CHAR(10); 		--Incremental 2
	DEFINE vFecha_abo_ini       DATE; 			--Incremental 2
	DEFINE vMonto_ini			MONEY(14,2); 	--Incremental 2

	
    LET vsqlerr         	    = 0; 
    LET iIsamErr                = 0;
    LET cErrorInfo              = "";   
    LET vErrorInfo              = "INICIO DEL PROCESO";
    LET vCodRet                 = "00000";
	LET vProducto			    = '';
	LET vEstatus			    = '';
	LET	vFechUltAbo	            = "";
	LET vProxAboAut	            = "";
	LET iContSobre			    = 0;
	LET vEst_sd				    = 1;
    LET vCuenta_sd              = " ";
    LET vMonto_acum             = 0.00;
	LET vConSd                  = 0;
	LET vLonSD                  = 0;
	LET vdIFerencia             = 0;
	LET vLoncons                = 0;
	LET vValiser                = 0; 
	LET iContProd               = 0;
	LET iContIcono              = 0;
	LET iContColor              = 0;
	LET iContPer                = 0;
	LET vDiaPer                 = 0;
	LET vValPer                 = 0;
	LET vEsPeriVal				= 0;
	LET vNotCuenta              = "";
	LET vNotMonto               = "";
	LET vSp_CodRet              = '00000';
	LET vIdPlantillaPush		= "SD_CREAP";
	LET vNumCte                 = "";
	LET vFecha_oper_not         = "";
	LET vFecha_meta_not         = "";
	LET vProxAboAut_not         = "";
    LET vFecha_proc             = "";
	LET iContDif 				= 0;
	LET vFecha_oper			    = TRIM(NVL(pFechCrea,''));
	LET vHora_oper			    = TRIM(NVL(pHoraCrea,''));
	LET vNombre_sd              = TRIM(NVL(pNombre_sd,''));
	LET vIcono                  = TRIM(NVL(pIcono,''));
	LET vColor                	= TRIM(NVL(pColor,''));
	LET vMonto_meta             = NVL(pMonto_meta,0.00);
	LET vFecha_meta             = TRIM(NVL(pFecha_meta,'')); 
	LET vMontAboAuto	        = NVL(pMontAboAuto,0.00);
	LET vPeriodicidad           = NVL(pPeriodicidad,0); 
	LET vCanal                  = TRIM(NVL(pCanal,'')); 
	LET pPeriodo				= NVL(pPeriodo,0);
	LET cNombCanal				= '';
	LET vTipo_apartado          = TRIM(NVL(pTipo_apartado,''));
	LET vDia_del_cobro            = TRIM(NVL(pDia_del_cobro,''));
	LET vFecha_abo_ini          = "";
	LET vMonto_ini 				= 0.00;
	
    BEGIN
		ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
			IF  vsqlerr != 0 THEN
				--SET DEBUG FILE TO "/resplogifx/conciliachq/sp_crea_sd.txt";
				--TRACE ON;
				LET vCodRet    = vsqlerr;
				LET vErrorInfo = cErrorInfo;
				LET vCuenta_eje= pCuenta_eje;
				RETURN vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
					vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro;            
			END IF;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/informix/c90186322/trace/sp_crea_sd.txt';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;  

		--VALORES DE LA CUENTA EJE	
		SELECT TRIM(cuenta), producto,  status_cta, num_cte
		INTO   vCuenta_eje,  vProducto, vEstatus,   vNumCte
		FROM   "informix".sc_maechq
		WHERE  cuenta = pCuenta_eje;
		
		LET vCuenta_eje = TRIM(NVL(vCuenta_eje,''));
		LET vProducto = TRIM(NVL(vProducto,''));
		LET vEstatus = TRIM(NVL(vEstatus,''));
		LET vNumCte = TRIM(NVL(vNumCte,''));
		
		-- IF vTipo_apartado = '' THEN
		-- 	LET vTipo_apartado = '1';
		-- END IF;
		
		--SE VALIDA QUE LA CUENTA EJE EXISTA
		IF  vCuenta_eje = '' THEN
			LET vCodRet = '00001';
			RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
				vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro;            
		END IF;
		
		IF vEstatus <> '1' THEN 
			LET vCodRet = '00002';
			RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
				vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro;   
		END IF;
		
		--SE VALIDA QUE EL PRODUCTO ENTRE DENTRO LOS PARTICIPANTES
		IF NOT EXISTS (SELECT 1 FROM "informix".sc_prodis_sd WHERE producto = vProducto) THEN 
			LET vCodRet = '00003';
			RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
				vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro;   
		END IF;

		--SE VALIDA EL TIPO DE APARTADO
		IF  vTipo_apartado NOT IN('1','2') THEN
			LET vCodRet = '00026'; -- Tipo de apartado invalido
			RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
				vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro;          
		END IF;
		
		--VALIDA QUE EXISTA EL ID DEL ICONO	
		IF  NOT EXISTS (SELECT 1 FROM "informix".sc_ico_sd WHERE id = pIcono) THEN 
			LET vCodRet = '00005';
			RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
				vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro;   
		END IF;
		
		--VALIDA QUE EXISTA EL ID DEL COLOR 
		IF   NOT EXISTS (SELECT 1 FROM "informix".sc_col_sd WHERE id = vColor) THEN 
			LET vCodRet = '00006';
			RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
				vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro;   
		END IF;
		
		--SE VALIDA LA CANTIDAD DE SOBRES ACTIVOS O FINALIZADOS
		SELECT COUNT(*) 
		INTO   iContSobre
		FROM   "informix".sc_mae_sd
		WHERE  cuenta_eje = vCuenta_eje
		AND    estatus IN ('1','3');
				
		IF iContSobre >= 5 THEN 
			LET vCodRet = '00008';
			RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
				vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro;   
		END IF;
		
		--FECHA DEL SISTEMA DE CHEQUES
		SELECT fecha_hoy
		INTO   vFechaHoy
		FROM   "informix".sc_fechas
		WHERE  empresa = "001";

		IF vTipo_apartado = '1' THEN
			--SE VALIDA QUE EXISTA EL ID DE PERIORICIDAD		
			IF  NOT EXISTS(SELECT 1 FROM "informix".sc_peri_sd WHERE id = vPeriodicidad) THEN 
				LET vCodRet = '00007';
				RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
					vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro;   
			END IF;
			
			--SE VALIDA EL MONTO META
			IF  vMonto_meta < 1 OR vMonto_meta > 10000000 THEN
				LET vCodRet = '00004';
				RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
					vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro;   
			END IF;	
			
			--SE CALCULA LA FECHA DEL SIGUIENTE ABONO
			EXECUTE PROCEDURE "informix".sp_calcprifechabo_sd(pPeriodicidad,pFechCrea,pHoraCrea,vDia_del_cobro) --NECESITA TENER YA LOS CAMBIOS DE INCREMENTAL 2 DE ESTE SP
			INTO vCodRet, vProxAboAut;

			IF vPeriodicidad = "2" THEN
				LET vDia_del_cobro = "";
			END IF;

			--VALIDA LA FECHA DE LA CREACION 
			IF  (vFecha_oper < vFechaHoy) OR (vFecha_meta < vFechaHoy) OR (vCodRet = "000") THEN
				LET vCodRet = '00017';
				RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
					vFechUltAbo,"",vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro;   
			END IF;	
			
			--SE OBTIENE PERIODO SEMANAL
			LET vDiaPer =  vFecha_meta - vProxAboAut;
			IF vPeriodicidad = "1" THEN
				LET vValPer  =  (TRUNC(vDiaPer / 7,0));
				--SE VALIDA QUE SEAN MENOS DE 52 SEMANAS
				IF pPeriodo <= 52 AND vValPer <= 52 THEN
					LET vEsPeriVal = 1;
				END IF;
			END IF;
			
			--SE OBTIENE PERIODO QUINCENAL	
			IF vPeriodicidad = "2" THEN
				LET vValPer  =  (TRUNC(vDiaPer / 15,0));
				--SE VALIDA QUE SEAN MENOS DE 24 QUINCENAS
				IF pPeriodo <= 24 AND vValPer <= 24 THEN
					LET vEsPeriVal = 1;
				END IF;
			END IF;
			
			--SE OBTIENE PERIODO MENSUAL
			IF vPeriodicidad = "3" THEN
			LET vValPer  =  (TRUNC(vDiaPer / 30,0));
				--SE VALIDA QUE SEAN MENOS DE 12 MESES
				IF pPeriodo <= 12 AND vValPer <= 12 THEN
					LET vEsPeriVal = 1;
				END IF;
			END IF;

			--SE VALIDA QUE LA CANTIDAD DE PERIODOS RECIBIDA SEA LA MISMA QUE EL CALCULO
			IF vEsPeriVal = 0 OR pPeriodo = 0 OR NOT((pPeriodo = vValPer OR pPeriodo-1 = vValPer) AND pPeriodo-1 = vValPer)	
			THEN	
				LET vCodRet = '00020'; --NÃºmero de periodos invalidos.
				RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
				vFechUltAbo,"",vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro;
			END IF;

		ELSE
			LET vMonto_meta = 0.00;
			LET vFecha_meta = '';
			LET vMontAboAuto = 0.00;
			LET vPeriodicidad = 0;
			LET pPeriodo = 0;
			LET vDia_del_cobro = "";
		END IF;
		
		--CONSECUTIVO DEL SOBRE DIGITAL 
		SELECT TRIM(valor) 
		INTO   vConSd
		FROM   "informix".sc_param
		WHERE  codparam = "concsd";
   
		--INCREMENTA EL CONSECUTIVO
		LET vConSd = NVL(vConSd,0) + 1;
  
		--LONGITUD DEL CONSECUTIVO
		SELECT valor 
		INTO   vLoncons
		FROM   "informix".sc_param
		WHERE  codparam = "concsd";
   
		LET vLoncons = (LEN(TRIM(((NVL(vLoncons,0)::INTEGER) + 1)::CHAR(9)))::INTEGER);
		
		--LONGITUD TOTAL DEL IDENTIFICADOR DEL SOBRE (20)
		SELECT valor
		INTO   vLonSD
		FROM   "informix".sc_param
		WHERE  codparam = "logctasd";
   
		--SE CALCULA LOS CEROS A CONSIDERAR  14 - 11 - LA LONGITUD DEL CONSECUTIVO
		LET vdIFerencia = NVL(vLonSD - 11 - vLoncons,0);
   
		--DIFERENCIA = LA CANTIDAD DE CEROS A AGREGAR 
		IF  vdIFerencia > 0 THEN
			FOR iContDif = 1 TO vdIFerencia
			LET vCuenta_sd = TRIM(vCuenta_sd) || "0" ; 
			END FOR;
		END IF;
   
		--CONCATENA LA CUENTA EJE A LOS CEROS 
		LET  vCuenta_sd = TRIM(vCuenta_eje) || vCuenta_sd; 
	   
		--CONCATENA EL CONCECUTIVO DE SOBRE DIGITAL 
		LET  vCuenta_sd = TRIM(vCuenta_sd) || vConSd;
	 
		--CREA EL SOBRE DIGITAL 
		INSERT INTO "informix".sc_mae_sd VALUES (vCuenta_eje,   vCuenta_sd,   vFecha_oper, vHora_oper, 
												vNombre_sd, vIcono, vColor, vFecha_meta, pPeriodo,
												vMonto_meta,   vMontAboAuto, vMonto_acum, vPeriodicidad,
												vFechUltAbo, vProxAboAut,  vEst_sd, vCanal, vFecha_proc,
												vTipo_apartado, vMonto_ini, vDia_del_cobro, pPeriodo);	
									  
		IF   dbinfo('sqlca.sqlerrd2') > 0 THEN
			LET vValiser = '1';
		END IF;
	
		IF  vValiser = '1' THEN
			UPDATE "informix".sc_param
			SET    valor    = vConSd
			WHERE  empresa = "001" and codparam = "concsd";	
				
			IF vTipo_apartado = "2" THEN
				LET vIdPlantillaPush = "SD_CRSPP";
			END IF;

			--NOTIFICACION POR MAIL 
			LET vNotCuenta = TRIM(NVL(SUBSTR(vCuenta_eje,8,4),''));
			LET vNotMonto  = vMonto_meta;

			--FECHA OPERACION
			LET vFecha_oper_not = TO_CHAR(vFecha_oper, '%d/%m/%Y');
			--FECHA META													
			LET vFecha_meta_not = TO_CHAR(vFecha_meta, '%d/%m/%Y');
			--PROXIMO ABONO													
			LET vProxAboAut_not = TO_CHAR(vProxAboAut, '%d/%m/%Y'); 
			
			IF vCanal = '1' THEN
				LET cNombCanal = 'App Bancoppel';
			END IF;

			IF vTipo_apartado = "1" THEN
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','PORTAL_BPI','SD_CREAM',vNumCte,'','','1',vFecha_oper_not,vNotCuenta,vNotMonto,vFecha_meta_not,vNombre_sd,vProxAboAut_not,cNombCanal,'','','','','',1,0,0,0,0,CURRENT,'') ----NOTIFICACION MAIL
				INTO vSp_CodRet;				
			ELSE
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','PORTAL_BPI','SD_CRSPM',vNumCte,'','','1','',vNotCuenta,'','',vNombre_sd,'',cNombCanal,'','','','','',1,0,0,0,0,CURRENT,'') ----NOTIFICACION MAIL
				INTO vSp_CodRet;
			END IF;

			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','PNS_BEX',vIdPlantillaPush,vNumCte,'','','1','','','','',vNombre_sd,'','','','','','','',1,0,0,0,0,'','') ----NOTIFICACION PUSH
			INTO vSp_CodRet;
			
		END IF;
		
		RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
			vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro;  
		
	END; 
END PROCEDURE
DOCUMENT
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA AGREGAR ESTATUS 3 DE FINALIZADO CUANDO SE CONSULTAN LOS APARTADOS POR CUENTA DE CAPTACION',
'AUTOR : 95358897 - ISARAI BOJORQUEZ',
'FECHA : 07/02/2023',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_edic_sd( pCuenta_eje  CHAR(20), pCuenta_sd CHAR(20), pFechCrea DATE, pHoraCrea CHAR(8),
	pMonto_meta  MONEY (14,2), pFecha_meta  DATE, pPeriodo  INTEGER, pMontAboAuto MONEY(14,2), pPeriodicidad INTEGER,
	pCanal CHAR(2), pDia_del_cobro CHAR(10))
								
	RETURNING   CHAR(5),--codigo retorno
	            CHAR(20),--cuenta_eje
                CHAR(20),--cuenta_sd
                DATE,--fecha_oper
                CHAR(8),--hora_oper
                CHAR(18),--nombre_sd
                CHAR(2),--icono
                CHAR(2),--color
				CHAR(20),--folio_oper
                DATE,--Fecha_meta
                MONEY (14,2),--monto_meta
                MONEY (14,2),--monto ahorro auto
                MONEY (14,2),--monto_acumulado
                INTEGER,--periodicidad
                DATE,--ult_fech_abono_auto
                DATE,--prox_fecha_abo_auto
                INTEGER,--estatus
                CHAR(2),--canal
				CHAR(2),--tipo_apartado
				CHAR(10),--dia_del_cobro
				MONEY(14,2);	
	--CONTROL DE EXCEPCIONES
    DEFINE vsqlerr          	INTEGER;
	DEFINE vPeriodicidad		INTEGER;
	DEFINE vEst_sd				INTEGER;
	DEFINE vPeriodo     		INTEGER;
	DEFINE vDiaPer              INTEGER;
	DEFINE vValPer              INTEGER;
	DEFINE vEsPeriVal           INTEGER;
	DEFINE vEst_sd_ant			INTEGER;
	DEFINE vConPer              INTEGER;


    DEFINE iIsamErr         	SMALLINT;
	DEFINE vProducto			SMALLINT;
	DEFINE vEst_cta				SMALLINT;
	DEFINE vCant_sd				SMALLINT;


    DEFINE cErrorInfo       	CHAR(80);
	DEFINE vErrorInfo       	CHAR(80);
    DEFINE vCodRet         		CHAR(5);
	DEFINE vCuenta_eje			CHAR(20);
	DEFINE vCuenta_sd			CHAR(20);
	DEFINE vHora_oper			CHAR(8);
	DEFINE vNombre_sd			CHAR(18);
	DEFINE vIcono				CHAR(2);
	DEFINE vColor				CHAR(2);
	DEFINE vfolio_oper			CHAR(20);
	DEFINE vCanal               CHAR(2);
	DEFINE vProd                CHAR(4);
	DEFINE vSp_CodRet           CHAR(5);
	DEFINE vIdPlantillaMail		CHAR(12);
	DEFINE vIdPlantillaPush		CHAR(12);
	DEFINE vNumCte              CHAR(20);
	DEFINE vFecha_oper_not      CHAR(10);
	DEFINE vNotCuenta           CHAR(8);
	DEFINE vNotMonto            CHAR(9);
	DEFINE vFecha_meta_not      CHAR(10);
    DEFINE vProxAboAut_not      CHAR(10);
	DEFINE vTipo_apartado 		CHAR(2);
	DEFINE vDia_del_cobro 		CHAR(10);
	DEFINE vMonto_ini			MONEY(14,2);

	DEFINE vFecha_meta			DATE;
	DEFINE vFecha_oper			DATE;
	DEFINE vFechUltAbo	        DATE;
	DEFINE vProxAboAut 	        DATE;
	DEFINE vFechaHoy            DATE;

	DEFINE vMonto_meta			MONEY(14,2);
	DEFINE vMontAboAuto		    MONEY(14,2);
	DEFINE vMonto_acum			MONEY(14,2);


	
    LET vsqlerr         	    = 0;
    LET iIsamErr                = 0;
    LET cErrorInfo              = "";
    LET vErrorInfo              = "INICIO DEL PROCESO";
    LET vCodRet                 = "00000";
	LET vCuenta_eje             = TRIM(pCuenta_eje);
	LET vCuenta_sd              = TRIM(pCuenta_sd);
	LET vFecha_oper			    = pFechCrea;
	LET vHora_oper			    = pHoraCrea;
	LET vNombre_sd              = "";
	LET vIcono                  = "";
    LET vColor                  = "";
	LET vfolio_oper				= "";
	LET vFecha_meta             = pFecha_meta;
    LET vMonto_meta             = pMonto_meta;
	LET vMontAboAuto	        = pMontAboAuto;
	LET vMonto_acum             = 0.00;
	LET vPeriodicidad           = pPeriodicidad;
	LET	vFechUltAbo	            = "";
	LET vProxAboAut	            = "";
	LET vEst_sd				    = 1;
	LET vCanal                  = TRIM(pCanal);
	LET vProducto			    = 0;
	LET vEst_cta			    = 0;
	LET vFechaHoy         		= "";
    LET vPeriodo                = pPeriodo;
	LET vDiaPer                 = 0;
	LET vValPer                 = 0;
    LET vEsPeriVal              = 0;
	LET vProd                   = "";
	LET vEst_sd_ant		    	= 1;
	LET vCant_sd			    = 0;
	LET vConPer                 = 0;
	LET vSp_CodRet              = '00000';
	LET vIdPlantillaMail		= "SD_EDICM";
	LET vIdPlantillaPush		= "SD_EDICP";
	LET vNumCte                 = "";
	LET vFecha_oper_not         = "";
	LET vNotCuenta 				= "";
	LET vNotMonto 				= "";
	LET vFecha_meta_not         = "";
	LET vProxAboAut_not         = "";
	LET vTipo_apartado          = "";
	LET vDia_del_cobro          = TRIM(NVL(pDia_del_cobro,''));
	LET vMonto_ini 				= 0.00;

    BEGIN
		ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
			IF  vsqlerr != 0 THEN
				--SET DEBUG FILE TO "/informix/c90186322/trace/sp_edic_sd_err.txt";
				--TRACE ON;
				LET vCodRet    	= vsqlerr;
				LET vErrorInfo 	= cErrorInfo;
				LET vCuenta_eje	= pCuenta_eje;
				RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vfolio_oper,vFecha_meta,vMonto_meta,
				vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro,vMonto_ini;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/informix/c90186322/trace/sp_edic_sd.txt";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--VALORES DE LA CUENTA EJE
		SELECT TRIM(cuenta), producto,  status_cta, TRIM(num_cte)
		INTO   vCuenta_eje,  vProducto, vEst_cta, 	vNumCte
		FROM   "informix".sc_maechq
		WHERE  cuenta = pCuenta_eje;

		IF vPeriodicidad = "2" THEN
			LET vDia_del_cobro = "";
		END IF;

		--SE VALIDA QUE LA CUENTA EJE EXISTA
		IF vCuenta_eje IS NULL OR vCuenta_eje = "" THEN
			LET vCodRet = '00001'; --Cuenta eje no existe.
			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vfolio_oper,vFecha_meta,vMonto_meta,
				vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro,vMonto_ini;
		END IF;

		--SE VALIDA EL ESTATUS DE LA CUENTA EJE
		IF vEst_cta <> "1" THEN
			LET vCodRet = '00002'; --Estatus de cuenta eje diferente de activo.
			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vfolio_oper,vFecha_meta,vMonto_meta,
				vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro,vMonto_ini;
		END IF;

		--SE VALIDA QUE EL PRODUCTO ENTRE DENTRO LOS PARTICIPANTES
		IF NOT EXISTS (SELECT 1  FROM "informix".sc_prodis_sd WHERE producto = vProducto ) THEN
			LET vCodRet = '00003'; --Producto invalido.
			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vfolio_oper,vFecha_meta,vMonto_meta,
				vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro,vMonto_ini;
		END IF;

		--FECHA DEL SISTEMA DE CHEQUES
		SELECT fecha_hoy
		INTO   vFechaHoy
		FROM   "informix".sc_fechas
		WHERE  empresa = "001";

		--SE VALIDA QUE EXISTA EL ID DE PERIORICIDAD
		IF NOT EXISTS (SELECT 1  FROM "informix".sc_peri_sd WHERE id = vPeriodicidad ) THEN
			LET vCodRet = '00007'; --Id de periodicidad invalida.
			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vfolio_oper,vFecha_meta,vMonto_meta,
				vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro,vMonto_ini;
		END IF;

		IF NVL(vHora_oper, "") = "" THEN
			LET vHora_oper = TO_CHAR(CURRENT, '%H:%M:%S');
		END IF;

		EXECUTE PROCEDURE "informix".sp_calcprifechabo_sd(vPeriodicidad,vFecha_oper,vHora_oper,vDia_del_cobro)
		INTO vCodret, vProxAboAut;

		--VALIDA LA FECHA DE LA EDICION 
		IF (vFecha_oper < vFechaHoy OR vFecha_meta < vFechaHoy) OR (vCodRet = "000") THEN
			LET vCodRet='00017'; --Fecha de edicion invalida.
			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vfolio_oper,vFecha_meta,vMonto_meta,
				vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro,vMonto_ini;
		END IF;
		
		--SE OBTIENE PERIODO SEMANAL
		LET vDiaPer =  vFecha_meta - vProxAboAut;
		IF vPeriodicidad = "1" THEN
            LET vValPer  =  (TRUNC(vDiaPer / 7,0));
			--SE VALIDA QUE SEAN MENOS DE 52 SEMANAS
            IF vPeriodo <= 52 AND vValPer <= 52 THEN
                LET vEsPeriVal = 1;
            END IF;
		END IF;
		
		--SE OBTIENE PERIODO QUINCENAL	
		IF vPeriodicidad = "2" THEN
		    LET vValPer  =  (TRUNC(vDiaPer / 15,0));
			--SE VALIDA QUE SEAN MENOS DE 24 QUINCENAS
            IF vPeriodo <= 24 AND vValPer <= 24 THEN
                LET vEsPeriVal = 1;
            END IF;
		END IF;
		
		--SE OBTIENE PERIODO MENSUAL
		IF vPeriodicidad = "3" THEN
		   LET vValPer  =  (TRUNC(vDiaPer / 30,0));
		   --SE VALIDA QUE SEAN MENOS DE 12 MESES
            IF vPeriodo <= 12 AND vValPer <= 12 THEN
                LET vEsPeriVal = 1;
            END IF;
		END IF;

		--SE VALIDA QUE LA CANTIDAD DE PERIODOS RECIBIDA SEA LA MISMA QUE EL CALCULO
		IF vEsPeriVal = 0 OR pPeriodo = 0 OR NOT((pPeriodo = vValPer OR pPeriodo-1 = vValPer) AND pPeriodo-1 = vValPer)
		THEN
			LET vCodRet = '00020'; --NÃºmero de periodos invalidos.
			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vfolio_oper,vFecha_meta,vMonto_meta,
				vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro,vMonto_ini;
		END IF;

		SELECT monto_acum, estatus, nombre_sd, icono, color , ult_fech_abo_auto, monto_ini, tipo_apartado
		INTO vMonto_acum, vEst_sd_ant, vNombre_sd,vIcono, vColor , vFechUltAbo, vMonto_ini, vTipo_apartado
		FROM "informix".sc_mae_sd
		WHERE cuenta_sd = pCuenta_sd
			AND cuenta_eje = pCuenta_eje
			AND estatus IN (1,3);

		--SE VALIDA SI EL APARTADO EXISTE
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET vCodRet = '00010'; --Apartado no existe o tiene un estatus invalido
			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vfolio_oper,vFecha_meta,vMonto_meta,
				vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro,vMonto_ini;
		END IF;

		--SE VALIDA EL TIPO DE APARTADO
		IF  vTipo_apartado NOT IN('1','2') THEN
			LET vCodRet = '00026'; -- Tipo de apartado invalido
			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vfolio_oper,vFecha_meta,vMonto_meta,
				vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro,vMonto_ini;        
		END IF;

		--SE VALIDA EL MONTO MINIMO y MAXIMO DE APERTURA/EDICION
		IF (NVL(vMonto_meta, 0) < vMonto_acum + 1) OR (NVL(vMonto_meta, 0) > 10000000 OR ROUND((vMonto_meta - vMonto_acum) / vPeriodo,2) != pMontAboAuto ) THEN
			LET vCodRet = '00004'; --Monto de meta invalido.
			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vfolio_oper,vFecha_meta,vMonto_meta,
				vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipo_apartado,vDia_del_cobro,vMonto_ini;
		END IF;

		IF NVL(vMontAboAuto, 0) = 0 THEN
			LET vMontAboAuto = ((vMonto_meta - vMonto_acum)/vPeriodo);
		END IF;

		UPDATE "informix".sc_mae_sd SET 
			fecha_creacion = vFecha_oper,
			hora_creacion = vHora_oper,
			fecha_meta = vFecha_meta,
			periodo = vPeriodo,
			monto_meta = vMonto_meta,
			monto_ahor_auto = vMontAboAuto,
			periodicidad = vPeriodicidad,
			prox_fech_abo_auto = vProxAboAut,
			estatus = 1,
			tipo_apartado = 1,
			dia_del_cobro = vDia_del_cobro,
			periodo_inicial = vPeriodo
		WHERE cuenta_eje = pCuenta_eje AND cuenta_sd = pCuenta_sd;

		IF dbinfo('sqlca.sqlerrd2') > 0 THEN
			IF vEst_sd_ant = "3" THEN
				LET vIdPlantillaMail = "SD_CONTM";
				LET vIdPlantillaPush = "SD_CONTP";
			END IF;

			IF vTipo_apartado = "2" THEN
				LET vIdPlantillaPush = "SD_EDSPP";
			END IF;
			
			--FECHA OPERACION MAIL
			LET vFecha_oper_not = TO_CHAR(vFecha_oper, '%d/%m/%Y');
			--CUENTA EJE MAIL
			LET vNotCuenta = SUBSTR(vCuenta_eje,8,4);
			--MONTO META MAIL
			LET vNotMonto  = vMonto_meta;
			--FECHA META MAIL
			LET vFecha_meta_not = TO_CHAR(vFecha_meta, '%d/%m/%Y');
			--PROXIMO ABONO	MAIL												
			LET vProxAboAut_not = TO_CHAR(vProxAboAut, '%d/%m/%Y');

			--NOTIFICACION MAIL
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','PORTAL_BPI',vIdPlantillaMail,vNumCte,'','','1',vFecha_oper_not,vNotCuenta,vNotMonto,vFecha_meta_not,vNombre_sd,vProxAboAut_not,'','','','','','',1,0,0,0,0,CURRENT,'')
			INTO vSp_CodRet;

			--NOTIFICACION PUSH
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','PNS_BEX',vIdPlantillaPush,vNumCte,'','','1','','','','',vNombre_sd,'','','','','','','',1,0,0,0,0,'','')
			INTO vSp_CodRet;
		END IF;
		
		RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vCuenta_sd,vFecha_meta,vMonto_meta,
			vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,1,vCanal,vTipo_apartado,vDia_del_cobro,vMonto_ini;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento almacenado para la edicion de apartados en la app movil.',
'AUTOR : 90034397 - Brando D. Garcia Lemus',
'FECHA : 13/01/2023',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_obtienegatbasicogeneral()
   RETURNING CHAR(5), CHAR(10),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6);

	DEFINE cod_ret             CHAR(5);
	DEFINE p_mensaje           CHAR(80);
	--DEFINICION VARIABLES EXCEPCION
	DEFINE vsqlerr             	INTEGER;
	DEFINE visamerr            	INTEGER;
	DEFINE vdescerr            	CHAR(50);
	DEFINE vcodret             	CHAR(5);
	DEFINE vcodret2            	CHAR(5);
    DEFINE vcodret3            	CHAR(50);
	--VARIABLES PARA USO EN PROCEDIMIENTO
	DEFINE sFechaPublicacion  CHAR(10);
	DEFINE sGatReal			  DECIMAL(9,6);
	DEFINE sGatNominal		  DECIMAL(9,6);
	DEFINE sTasa1			  DECIMAL(9,6);
	DEFINE sTasa2			  DECIMAL(9,6);
	
	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";
	--ASIGNACION VARIABLES EXCEPCION
	LET vcodret         = "000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
	--ASIGNACION VARIABLES PARA USO EN PROCEDIMIENTO
	LET sFechaPublicacion = '1900-01-30';
	LET sGatReal = 0.00;
	LET sGatNominal = 0.00;
	LET sTasa1 = 0.00;
	LET sTasa2 = 0.00;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
		ON EXCEPTION SET vsqlerr, visamerr, vdescerr
			SET DEBUG FILE TO "/tmp/sp_obtienegatbasicogeneral.err";
			TRACE ON;
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				LET vcodret2 = visamerr;
				LET vcodret3 = vdescerr;
				RETURN vcodret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1, sTasa2;
			END IF
		END EXCEPTION;
		
		SELECT MAX(fecha_publicacion) 
		INTO sFechaPublicacion 
		FROM bdicheq:sc_gat 
		WHERE producto = '1400';
		
		SELECT max(gat_real),max(gat_nominal)
		INTO sGatReal,sGatNominal
		FROM bdicheq:sc_gat
		WHERE producto = '1400' 
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa1
		FROM bdicheq:sc_gat 
		WHERE rango_min = '0.00' 
		AND producto = '1400'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa2
		FROM bdicheq:sc_gat 
		WHERE rango_min = '200.01' 
		AND producto = '1400'
		AND fecha_publicacion = sFechaPublicacion;
		
		
		
		RETURN cod_ret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1, sTasa2;
	
	END;
	
END PROCEDURE

DOCUMENT
'SPL Extrae la Fecha Publicacion, Gat Real, Gat Nominal y Tasa Maximas del Producto',
"MODIFICO : Julian Reyna",
"FECHA : 03/Octubre/2023",
"Ver.  : 1.1",
"BD    : bdicheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_obtienegatefectivacheques()
   RETURNING CHAR(5), CHAR(10),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6);

	DEFINE cod_ret             CHAR(5);
	DEFINE p_mensaje           CHAR(80);
	--DEFINICION VARIABLES EXCEPCION
	DEFINE vsqlerr             	INTEGER;
	DEFINE visamerr            	INTEGER;
	DEFINE vdescerr            	CHAR(50);
	DEFINE vcodret             	CHAR(5);
	DEFINE vcodret2            	CHAR(5);
    DEFINE vcodret3            	CHAR(50);
	--VARIABLES PARA USO EN PROCEDIMIENTO
	DEFINE sFechaPublicacion   CHAR(10);
	DEFINE sGatReal			  DECIMAL(9,6);
	DEFINE sGatNominal		  DECIMAL(9,6);
	DEFINE sTasa1			  DECIMAL(9,6);
	DEFINE sTasa2			  DECIMAL(9,6);
   
	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";
	--ASIGNACION VARIABLES EXCEPCION
	LET vcodret         = "000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
	--ASIGNACION VARIABLES PARA USO EN PROCEDIMIENTO
	LET sFechaPublicacion = '1900-01-30';
	LET sGatReal = 0.00;
	LET sGatNominal = 0.00;
	LET sTasa1 = 0.00;
	LET sTasa2 = 0.00;
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
		ON EXCEPTION SET vsqlerr, visamerr, vdescerr
			SET DEBUG FILE TO "/tmp/sp_obtienegatefectivacheques.err";
			TRACE ON;
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				LET vcodret2 = visamerr;
				LET vcodret3 = vdescerr;
				RETURN vcodret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1, sTasa2;
			END IF
		END EXCEPTION;
		SELECT MAX(fecha_publicacion) 
		INTO sFechaPublicacion 
		FROM bdicheq:sc_gat 
		WHERE producto = '1900';
		
		SELECT MAX(gat_real),max(gat_nominal)
		INTO sGatReal,sGatNominal
		FROM bdicheq:sc_gat
		WHERE producto = '1900' 
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa1
		FROM bdicheq:sc_gat 
		WHERE rango_min = '0.00' 
		AND producto = '1900'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa2
		FROM bdicheq:sc_gat
		WHERE rango_min = '200.01'
		AND producto = '1900'
		AND fecha_publicacion = sFechaPublicacion;

		RETURN cod_ret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1, sTasa2;
	
	END;
	
END PROCEDURE
DOCUMENT
'SPL Extrae la Fecha Publicacion, Gat Real, Gat Nominal y Tasa Maximas del Producto',
"MODIFICO : Julian Reyna",
"FECHA : 03/Octubre/2007",
"Ver.  : 1.1",
"BD    : bdicheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_obtienegatefectivadigital()
   RETURNING CHAR(5), CHAR(10), DECIMAL(9,6), DECIMAL(9,6), DECIMAL(9,6), DECIMAL(9,6);

	DEFINE cod_ret             CHAR(5);
	DEFINE p_mensaje           CHAR(80);
	--DEFINICION VARIABLES EXCEPCION
	DEFINE vsqlerr             INTEGER;
	DEFINE visamerr            INTEGER;
	DEFINE vdescerr            CHAR(50);
	DEFINE vcodret             CHAR(5);
	DEFINE vcodret2            CHAR(5);
    DEFINE vcodret3            CHAR(50);
	--VARIABLES PARA USO EN PROCEDIMIENTO
	DEFINE sFechaPublicacion   CHAR(10);
	DEFINE sGatReal			   DECIMAL(9,6);
	DEFINE sGatNominal		   DECIMAL(9,6);
	DEFINE sTasa1			   DECIMAL(9,6);
	DEFINE sTasa2			   DECIMAL(9,6);

	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";
	--ASIGNACION VARIABLES EXCEPCION
	LET vcodret         = "000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
	--ASIGNACION VARIABLES PARA USO EN PROCEDIMIENTO
	LET sFechaPublicacion = '1900-01-30';
	LET sGatReal = 0.00;
	LET sGatNominal = 0.00;
	LET sTasa1 = 0.00;
	LET sTasa2 = 0.00;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
		ON EXCEPTION SET vsqlerr, visamerr, vdescerr
			SET DEBUG FILE TO "/tmp/sp_obtienegatefectivadigital.err";
			TRACE ON;
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				LET vcodret2 = visamerr;
				LET vcodret3 = vdescerr;
				RETURN vcodret,sFechaPublicacion, sGatReal, sGatNominal, sTasa1, sTasa2;
			END IF
		END EXCEPTION;
		
		SELECT MAX(fecha_publicacion) 
		INTO sFechaPublicacion 
		FROM bdicheq:sc_gat 
		WHERE producto = '2000';
		
		SELECT MAX(gat_real),MAX(gat_nominal)
		INTO sGatReal,sGatNominal
		FROM bdicheq:sc_gat
		WHERE producto = '2000' 
		AND fecha_publicacion = sFechaPublicacion;
	
		SELECT MAX(tasa)
		INTO sTasa1
		FROM bdicheq:sc_gat 
		WHERE rango_min = '0.00' 
		AND producto = '2000'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa2
		FROM bdicheq:sc_gat 
		WHERE rango_min = '200.01' 
		AND producto = '2000'
		AND fecha_publicacion = sFechaPublicacion;
		
		RETURN cod_ret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1, sTasa2;
	END;

END PROCEDURE
DOCUMENT
'SPL Extrae la Fecha Publicacion Maxima del Producto',
"MODIFICO : Julian Reyna",
"FECHA : 03/Octubre/2023",
"Ver.  : 1.1",
"BD    : bdicheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_obtienegatefectivagc()
   RETURNING CHAR(5), CHAR(10), DECIMAL(9,6), DECIMAL(9,6), DECIMAL(9,6);

	DEFINE cod_ret             	CHAR(5);
	DEFINE p_mensaje           	CHAR(80);
	--DEFINICION VARIABLES EXCEPCION
	DEFINE vsqlerr             	INTEGER;
	DEFINE visamerr            	INTEGER;
	DEFINE vdescerr            	CHAR(50);
	DEFINE vcodret             	CHAR(5);
	DEFINE vcodret2            	CHAR(5);
    DEFINE vcodret3            	CHAR(50);
	--VARIABLES PARA USO EN PROCEDIMIENTO
	DEFINE sFechaPublicacion   	CHAR(10);
	DEFINE sGatReal			  	DECIMAL(9,6);
	DEFINE sGatNominal		  	DECIMAL(9,6);
	DEFINE sTasa1			  	DECIMAL(9,6);

	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";
	--ASIGNACION VARIABLES EXCEPCION
	LET vcodret         = "000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
	--ASIGNACION VARIABLES PARA USO EN PROCEDIMIENTO
	LET sFechaPublicacion = '1900-01-30';
	LET sGatReal = 0.00;
	LET sGatNominal = 0.00;
	LET sTasa1 = 0.00;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
		ON EXCEPTION SET vsqlerr, visamerr, vdescerr
			SET DEBUG FILE TO "/tmp/sp_obtienegatefectivaGC.err";
			TRACE ON;
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				LET vcodret2 = visamerr;
				LET vcodret3 = vdescerr;
				RETURN vcodret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1;
			END IF
		END EXCEPTION;
	
		SELECT MAX(fecha_publicacion) 
		INTO sFechaPublicacion 
		FROM bdicheq:sc_gat 
		WHERE producto = '1300';
		
		SELECT MAX(gat_real),MAX(gat_nominal),MAX(tasa)
		INTO sGatReal,sGatNominal,sTasa1
		FROM bdicheq:sc_gat
		WHERE producto = '1300' 
		AND fecha_publicacion = sFechaPublicacion;
		
		RETURN cod_ret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1;
		
	END;
	
END PROCEDURE

DOCUMENT
'SPL Extrae la Fecha Publicacion, Gat Real, Gat Nominal y Tasa Maximas del Producto',
"MODIFICO : Julian Reyna",
"FECHA : 03/Octubre/2023",
"Ver.  : 1.1",
"BD    : bdicheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_obtienegatefectivajovenes()
   RETURNING CHAR(5), CHAR(10),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6);

	DEFINE cod_ret             CHAR(5);
	DEFINE p_mensaje           CHAR(80);
	--DEFINICION VARIABLES EXCEPCION
	DEFINE vsqlerr             	INTEGER;
	DEFINE visamerr            	INTEGER;
	DEFINE vdescerr            	CHAR(50);
	DEFINE vcodret             	CHAR(5);
	DEFINE vcodret2            	CHAR(5);
    DEFINE vcodret3            	CHAR(50);
	--VARIABLES PARA USO EN PROCEDIMIENTO
	DEFINE sFechaPublicacion   CHAR(10);
	DEFINE sGatReal			  DECIMAL(9,6);
	DEFINE sGatNominal		  DECIMAL(9,6);
	DEFINE sTasa1			  DECIMAL(9,6);
	DEFINE sTasa2			  DECIMAL(9,6);
   
	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";
	--ASIGNACION VARIABLES EXCEPCION
	LET vcodret         = "000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
	--ASIGNACION VARIABLES PARA USO EN PROCEDIMIENTO
	LET sFechaPublicacion = '1900-01-30';
	LET sGatReal = 0.00;
	LET sGatNominal = 0.00;
	LET sTasa1 = 0.00;
	LET sTasa2 = 0.00;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
		ON EXCEPTION SET vsqlerr, visamerr, vdescerr
			SET DEBUG FILE TO "/tmp/sp_obtienegatefectivajovenes.err";
			TRACE ON;
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				LET vcodret2 = visamerr;
				LET vcodret3 = vdescerr;
				RETURN vcodret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1, sTasa2;
			END IF
		END EXCEPTION;
		
		SELECT MAX(fecha_publicacion) 
		INTO sFechaPublicacion 
		FROM bdicheq:sc_gat 
		WHERE producto = '2500';
		
		SELECT MAX(gat_real),MAX(gat_nominal)
		INTO sGatReal,sGatNominal
		FROM bdicheq:sc_gat
		WHERE producto = '2500' 
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa1
		FROM bdicheq:sc_gat
		WHERE rango_min = '0.00' 
		AND producto = '1900'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa2
		FROM bdicheq:sc_gat
		WHERE rango_min = '200.01' 
		AND producto = '2500'
		AND fecha_publicacion = sFechaPublicacion;
		
		RETURN cod_ret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1, sTasa2;
	
	END;
	
END PROCEDURE
DOCUMENT
'SPL Extrae la Fecha Publicacion, Gat Real, Gat Nominal y Tasa Maximas del Producto',
"MODIFICO : Julian Reyna",
"FECHA : 03/Octubre/2007",
"Ver.  : 1.1",
"BD    : bdicheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_obtienegatefectivaplatino()
   RETURNING CHAR(5), CHAR(10),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6);

	DEFINE cod_ret             CHAR(5);
	DEFINE p_mensaje           CHAR(80);
	--DEFINICION VARIABLES EXCEPCION
	DEFINE vsqlerr             	INTEGER;
	DEFINE visamerr            	INTEGER;
	DEFINE vdescerr            	CHAR(50);
	DEFINE vcodret             	CHAR(5);
	DEFINE vcodret2            	CHAR(5);
    DEFINE vcodret3            	CHAR(50);
	--VARIABLES PARA USO EN PROCEDIMIENTO
	DEFINE sFechaPublicacion   CHAR(10);
	DEFINE sGatReal			  DECIMAL(9,6);
	DEFINE sGatNominal		  DECIMAL(9,6);
	DEFINE sTasa1			  DECIMAL(9,6);
	DEFINE sTasa2			  DECIMAL(9,6);
	DEFINE sTasa3			  DECIMAL(9,6);
	DEFINE sTasa4			  DECIMAL(9,6);
	DEFINE sTasa5			  DECIMAL(9,6);

	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";
	--ASIGNACION VARIABLES EXCEPCION
	LET vcodret         = "000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
	--ASIGNACION VARIABLES PARA USO EN PROCEDIMIENTO
	LET sFechaPublicacion = '1900-01-30';
	LET sGatReal = 0.00;
	LET sGatNominal = 0.00;
	LET sTasa1 = 0.00;
	LET sTasa2 = 0.00;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
		ON EXCEPTION SET vsqlerr, visamerr, vdescerr
			SET DEBUG FILE TO "/tmp/sp_obtienegatefectivaplatino.err";
			TRACE ON;
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				LET vcodret2 = visamerr;
				LET vcodret3 = vdescerr;
				RETURN vcodret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1, sTasa2, sTasa3, sTasa4, sTasa5;
			END IF
		END EXCEPTION;
		SELECT MAX(fecha_publicacion) 
		INTO sFechaPublicacion 
		FROM bdicheq:sc_gat 
		WHERE producto = '2400';
		
		SELECT max(gat_real),max(gat_nominal)
		INTO sGatReal,sGatNominal
		FROM bdicheq:sc_gat
		WHERE producto = '2400' 
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa1
		FROM bdicheq:sc_gat
		WHERE rango_min = '0.00' 
		AND producto = '2400'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa2
		FROM bdicheq:sc_gat
		WHERE rango_min = '200.01' 
		AND producto = '2400'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa3
		FROM bdicheq:sc_gat
		WHERE rango_min = '100000.01' 
		AND producto = '2400'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa4
		FROM bdicheq:sc_gat
		WHERE rango_min = '500000.01' 
		AND producto = '2400'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa5
		FROM bdicheq:sc_gat 
		WHERE rango_min = '1000000.01' 
		AND producto = '2400'
		AND fecha_publicacion = sFechaPublicacion;
		
		RETURN cod_ret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1, sTasa2, sTasa3, sTasa4, sTasa5;
	
	END;
	
END PROCEDURE

DOCUMENT
'SPL Extrae la Fecha Publicacion, Gat Real, Gat Nominal y Tasa Maximas del Producto',
"MODIFICO : Julian Reyna",
"FECHA : 03/Octubre/2023",
"Ver.  : 1.1",
"BD    : bdicheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_obtienegatefectivaplus()
   RETURNING CHAR(5), CHAR(10), DECIMAL(9,6), DECIMAL(9,6), DECIMAL(9,6);

	DEFINE cod_ret             CHAR(5);
	DEFINE p_mensaje           CHAR(80);
	--DEFINICION VARIABLES EXCEPCION
	DEFINE vsqlerr             	INTEGER;
	DEFINE visamerr            	INTEGER;
	DEFINE vdescerr            	CHAR(50);
	DEFINE vcodret             	CHAR(5);
	DEFINE vcodret2            	CHAR(5);
    DEFINE vcodret3            	CHAR(50);
	--VARIABLES PARA USO EN PROCEDIMIENTO
	DEFINE sFechaPublicacion   CHAR(10);
	DEFINE sGatReal			  DECIMAL(9,6);
	DEFINE sGatNominal		  DECIMAL(9,6);
	DEFINE sTasa1			  DECIMAL(9,6);

	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";
	--ASIGNACION VARIABLES EXCEPCION
	LET vcodret         = "000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
	--ASIGNACION VARIABLES PARA USO EN PROCEDIMIENTO
	LET sFechaPublicacion = '1900-01-30';
	LET sGatReal = 0.00;
	LET sGatNominal = 0.00;
	LET sTasa1 = 0.00;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
		ON EXCEPTION SET vsqlerr, visamerr, vdescerr
			SET DEBUG FILE TO "/tmp/sp_obtienegatefectivaplus.err";
			TRACE ON;
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				LET vcodret2 = visamerr;
				LET vcodret3 = vdescerr;
				RETURN vcodret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1;
			END IF
		END EXCEPTION;
		SELECT MAX(fecha_publicacion) 
		INTO sFechaPublicacion 
		FROM bdicheq:sc_gat 
		WHERE producto = '1800';
		
		SELECT MAX(gat_real),MAX(gat_nominal),MAX(tasa)
		INTO sGatReal,sGatNominal,sTasa1
		FROM bdicheq:sc_gat
		WHERE producto = '1800' 
		AND fecha_publicacion = sFechaPublicacion;
		
		RETURN cod_ret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1;
	
	END;

END PROCEDURE

DOCUMENT
'SPL Extrae la Fecha Publicacion, Gat Real, Gat Nominal y Tasa Maximas del Producto',
"MODIFICO : Julian Reyna",
"FECHA : 03/Octubre/2023",
"Ver.  : 1.1",
"BD    : bdicheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_obtienegatinversioncreciente()
   RETURNING CHAR(5), CHAR(10),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),
   DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6);

	DEFINE cod_ret             	CHAR(5);
	DEFINE p_mensaje           	CHAR(80);
	--DEFINICION VARIABLES EXCEPCION
	DEFINE vsqlerr             	INTEGER;
	DEFINE visamerr            	INTEGER;
	DEFINE vdescerr            	CHAR(50);
	DEFINE vcodret             	CHAR(5);
	DEFINE vcodret2            	CHAR(5);
    DEFINE vcodret3            	CHAR(50);
	--VARIABLES PARA USO EN PROCEDIMIENTO
	DEFINE sFechaPublicacion   	CHAR(10);
	DEFINE sGatReal			  	DECIMAL(9,6);
	DEFINE sGatNominal		  	DECIMAL(9,6);
	DEFINE sMes1				DECIMAL(9,6);
	DEFINE sMes2				DECIMAL(9,6);
	DEFINE sMes3				DECIMAL(9,6);
	DEFINE sMes4				DECIMAL(9,6);
	DEFINE sMes5				DECIMAL(9,6);
	DEFINE sMes6				DECIMAL(9,6);
	DEFINE sMes7				DECIMAL(9,6);
	DEFINE sMes8				DECIMAL(9,6);
	DEFINE sMes9				DECIMAL(9,6);
	DEFINE sMes10			  	DECIMAL(9,6);
	DEFINE sMes11			  	DECIMAL(9,6);
	DEFINE sMes12			  	DECIMAL(9,6);
   
	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";
	--ASIGNACION VARIABLES EXCEPCION
	LET vcodret         = "000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
	--ASIGNACION VARIABLES PARA USO EN PROCEDIMIENTO
	LET sFechaPublicacion = '1900-01-30';
	LET sGatReal = 0.00;
	LET sGatNominal = 0.00;
	LET sMes1 = 0.00;
	LET sMes2 = 0.00;
    LET sMes3 = 0.00;
	LET sMes4 = 0.00;
	LET sMes5 = 0.00;
	LET sMes6 = 0.00;
	LET sMes7 = 0.00;
	LET sMes8 = 0.00;
	LET sMes9 = 0.00;
	LET sMes10= 0.00;
	LET sMes11= 0.00;
	LET sMes12= 0.00;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
		ON EXCEPTION SET vsqlerr, visamerr, vdescerr
			SET DEBUG FILE TO "/tmp/sp_obtienegatinversioncreciente.err";
			TRACE ON;
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				LET vcodret2 = visamerr;
				LET vcodret3 = vdescerr;
				RETURN vcodret, sFechaPublicacion, sGatReal, sGatNominal, sMes1, sMes2, sMes3, sMes4, sMes5, sMes6, sMes7, sMes8, sMes9, sMes10, sMes11, sMes12;
			END IF
		END EXCEPTION;
		
		SELECT MAX(fecha_publicacion) 
		INTO sFechaPublicacion 
		FROM bdicheq:sc_gat 
		WHERE producto = '1100';
		
		SELECT MAX(gat_real),MAX(gat_nominal)
		INTO sGatReal,sGatNominal
		FROM bdicheq:sc_gat
		WHERE producto = '1100' 
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes1
		FROM bdicheq:sc_gat 
		WHERE mes = '1' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes2
		FROM bdicheq:sc_gat 
		WHERE mes = '2' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes3
		FROM bdicheq:sc_gat 
		WHERE mes = '3' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes4
		FROM bdicheq:sc_gat 
		WHERE mes = '4' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes5
		FROM bdicheq:sc_gat 
		WHERE mes = '5' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes6
		FROM bdicheq:sc_gat 
		WHERE mes = '6' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes7
		FROM bdicheq:sc_gat 
		WHERE mes = '7' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes8
		FROM bdicheq:sc_gat 
		WHERE mes = '8' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes9
		FROM bdicheq:sc_gat 
		WHERE mes = '9' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes10
		FROM bdicheq:sc_gat 
		WHERE mes = '10' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes11
		FROM bdicheq:sc_gat 
		WHERE mes = '11' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes12
		FROM bdicheq:sc_gat 
		WHERE mes = '12' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		RETURN cod_ret, sFechaPublicacion, sGatReal, sGatNominal, sMes1, sMes2, sMes3, sMes4, sMes5, sMes6, sMes7, sMes8, sMes9, sMes10, sMes11, sMes12;
	
	END;
	
END PROCEDURE

DOCUMENT
'SPL Extrae la Fecha Publicacion, Gat Real, Gat Nominal y Tasa Maximas del Producto',
"MODIFICO : Julian Reyna",
"FECHA : 03/Octubre/2007",
"Ver.  : 1.1",
"BD    : bdicheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_obtienegatpagare()
   RETURNING CHAR(5), CHAR(10),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),
   DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),
   DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),
   DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6);

	DEFINE cod_ret             	CHAR(5);
	DEFINE p_mensaje           	CHAR(80);
	--DEFINICION VARIABLES EXCEPCION
	DEFINE vsqlerr             	INTEGER;
	DEFINE visamerr            	INTEGER;
	DEFINE vdescerr            	CHAR(50);
	DEFINE vcodret             	CHAR(5);
	DEFINE vcodret2            	CHAR(5);
    DEFINE vcodret3            	CHAR(50);
	--VARIABLES PARA USO EN PROCEDIMIENTO
	DEFINE sFechaPublicacion  CHAR(10);
	DEFINE sGatReal1	  DECIMAL(9,6);
	DEFINE sGatReal2	  DECIMAL(9,6);
	DEFINE sGatReal3	  DECIMAL(9,6);
	DEFINE sGatReal4	  DECIMAL(9,6);
	DEFINE sGatReal5	  DECIMAL(9,6);
	DEFINE sGatReal6	  DECIMAL(9,6);
	DEFINE sGatReal7	  DECIMAL(9,6);
	DEFINE sGatReal8	  DECIMAL(9,6);
	DEFINE sGatReal9	  DECIMAL(9,6);
	DEFINE sGatReal10	  DECIMAL(9,6);
	DEFINE sGatReal11	  DECIMAL(9,6);
	DEFINE sGatNominal1	  DECIMAL(9,6);
	DEFINE sGatNominal2	  DECIMAL(9,6);
	DEFINE sGatNominal3	  DECIMAL(9,6);
	DEFINE sGatNominal4	  DECIMAL(9,6);
	DEFINE sGatNominal5	  DECIMAL(9,6);
	DEFINE sGatNominal6	  DECIMAL(9,6);
	DEFINE sGatNominal7	  DECIMAL(9,6);
	DEFINE sGatNominal8	  DECIMAL(9,6);
	DEFINE sGatNominal9	  DECIMAL(9,6);
	DEFINE sGatNominal10  DECIMAL(9,6);
	DEFINE sGatNominal11  DECIMAL(9,6);
	DEFINE sTasa1		  DECIMAL(9,6);
	DEFINE sTasa2		  DECIMAL(9,6);
	DEFINE sTasa3		  DECIMAL(9,6);
	DEFINE sTasa4		  DECIMAL(9,6);
	DEFINE sTasa5		  DECIMAL(9,6);
	DEFINE sTasa6		  DECIMAL(9,6);
	DEFINE sTasa7		  DECIMAL(9,6);
	DEFINE sTasa8		  DECIMAL(9,6);
	DEFINE sTasa9		  DECIMAL(9,6);
	DEFINE sTasa10		  DECIMAL(9,6);
	DEFINE sTasa11		  DECIMAL(9,6);
	DEFINE sTasa12		  DECIMAL(9,6);
   
	
	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";
	--ASIGNACION VARIABLES EXCEPCION
	LET vcodret         = "000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
	--ASIGNACION VARIABLES PARA USO EN PROCEDIMIENTO
	LET sFechaPublicacion = '1900-01-30';
	LET sTasa1 		 = 0.00;
	LET sTasa2 		 = 0.00;
    LET sTasa3 		 = 0.00;
	LET sTasa4 		 = 0.00;
	LET sTasa5 		 = 0.00;
	LET sTasa6 		 = 0.00;
	LET sTasa7 		 = 0.00;
	LET sTasa8 		 = 0.00;
	LET sTasa9 		 = 0.00;
	LET sTasa10		 = 0.00;
	LET sTasa11		 = 0.00;
	LET sTasa12		 = 0.00;
	LET sGatReal1	 = 0.00;
	LET sGatReal2	 = 0.00;
	LET sGatReal3	 = 0.00;
	LET sGatReal4	 = 0.00;
	LET sGatReal5	 = 0.00;
	LET sGatReal6	 = 0.00;
	LET sGatReal7	 = 0.00;
	LET sGatReal8	 = 0.00;
	LET sGatReal9	 = 0.00;
	LET sGatReal10	 = 0.00;
	LET sGatReal11	 = 0.00;
	LET sGatNominal1 = 0.00;
	LET sGatNominal2 = 0.00;
	LET sGatNominal3 = 0.00;
	LET sGatNominal4 = 0.00;
	LET sGatNominal5 = 0.00;
	LET sGatNominal6 = 0.00;
	LET sGatNominal7 = 0.00;
	LET sGatNominal8 = 0.00;
	LET sGatNominal9 = 0.00;
	LET sGatNominal10= 0.00;
	LET sGatNominal11= 0.00;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
		ON EXCEPTION SET vsqlerr, visamerr, vdescerr
			SET DEBUG FILE TO "/tmp/sp_obtienegatpagare.err";
			TRACE ON;
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				LET vcodret2 = visamerr;
				LET vcodret3 = vdescerr;
				RETURN vcodret, sFechaPublicacion, sTasa1, sTasa2, sTasa3, sTasa4, sTasa5, sTasa6, sTasa7, sTasa8, sTasa9, sTasa10, sTasa11,
				sGatNominal1,sGatNominal2,sGatNominal3,sGatNominal4,sGatNominal5,sGatNominal6,sGatNominal7,sGatNominal8,sGatNominal9,sGatNominal10,sGatNominal11,
				sGatReal1,sGatReal2,sGatReal3,sGatReal4,sGatReal5,sGatReal6,sGatReal7,sGatReal8,sGatReal9,sGatReal10,sGatReal11;
			END IF
		END EXCEPTION;
		
		SELECT MAX(fecha_publicacion) 
		INTO sFechaPublicacion 
		FROM bdinvers:sv_gat;
		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa1, sGatReal1, sGatNominal1
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio = 28 
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 28);

		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa2, sGatReal2, sGatNominal2
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio =  60
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 60);
		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa3, sGatReal3, sGatNominal3
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio = 91 
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 91);
		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa4, sGatReal4, sGatNominal4
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio = 120
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 120);
		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa5, sGatReal5, sGatNominal5
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio = 150 
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 150);
		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa6, sGatReal6, sGatNominal6
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio = 180 
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 180);
		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa7, sGatReal7, sGatNominal7
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio = 210 
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 210);
		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa8, sGatReal8, sGatNominal8
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio = 240 
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 240);
		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa9, sGatReal9, sGatNominal9
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio = 270 
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 270);
		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa10, sGatReal10, sGatNominal10
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio = 300 
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 300);
		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa11, sGatReal11, sGatNominal11
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio = 330
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 330);
		
		RETURN cod_ret, sFechaPublicacion, sTasa1, sTasa2, sTasa3, sTasa4, sTasa5, sTasa6, sTasa7, sTasa8, sTasa9, sTasa10, sTasa11,
		sGatNominal1,sGatNominal2,sGatNominal3,sGatNominal4,sGatNominal5,sGatNominal6,sGatNominal7,sGatNominal8,sGatNominal9,sGatNominal10,sGatNominal11,
		sGatReal1,sGatReal2,sGatReal3,sGatReal4,sGatReal5,sGatReal6,sGatReal7,sGatReal8,sGatReal9,sGatReal10,sGatReal11;
	
	END;
	
END PROCEDURE
DOCUMENT
'SPL Extrae la Fecha Publicacion, Gat Real, Gat Nominal y Tasa Maximas del Producto',
"MODIFICO : Julian Reyna",
"FECHA : 03/Octubre/2007",
"Ver.  : 1.1",
"BD    : bdicheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_dispercionnomina_bpi()

-- ******************************************************************************************
-- Realizo   : Martin Valenzuela Ojeda, Armando Mercado
-- Proyecto  : Dispersion Nomina BanCoppel
-- Actividad : Ejecuta el proceso para la dispersion de la nomina,
--             actualiza el campo status en el detalle de aquellos empleados
--             que si se les ejecuto el pago de la nomina y
--             aquellos que por algun motivo no se les disperso su sueldo.
--             Tambien actualiza el encabezado para aquellos archivos que fueron dispersados,
--             ejecutando las validaciones correspondientes.
--             Este store sera ejecutado para varios archivos en Batch
-- Fecha     : Abril de 2008
-- ******************************************************************************************

RETURNING CHAR(5);

-- // DefiniciÃ³n de Variables
DEFINE GLOBAL mtotalregspei             INTEGER	DEFAULT 0;

DEFINE cNumeroEmpresa                   CHAR(3);
DEFINE dFechaGeneracion                 DATE;
DEFINE IFolioArchivo                    INTEGER;
DEFINE dFechaActual                     DATE;
DEFINE cEstatusCta                      CHAR(1);
DEFINE cNumeroCuentaEmpleado            CHAR(20);
DEFINE cNumeroEmpleado                  CHAR(10);
DEFINE mImporteEmpleado                 MONEY(14,3);
DEFINE dFechaAplicacion                 DATE;
DEFINE cHoraActual                      DATETIME HOUR TO SECOND;
DEFINE cNumeroTarjeta                   CHAR(20);
DEFINE mImporteAbonado                  MONEY(16,3);
DEFINE mImporteNoAbonado                MONEY(16,3);
DEFINE mImporteTotalAplicado            MONEY(16,3);
DEFINE siSaldoDisponible                SMALLINT;
DEFINE mTotalNoPagado                   MONEY(16,3);
DEFINE mTotalComisionDispercionIvaEmp   MONEY(14,3);
DEFINE mImporteTotalEnc                 MONEY(14,3);
DEFINE mSaldoActual                     MONEY(14,3);
DEFINE iNumeroRegistros                 INTEGER;
DEFINE bPrimerEmpleado                  BOOLEAN;
DEFINE bSiguienteEmpleado               BOOLEAN;
DEFINE cCodRet                          CHAR(3);
DEFINE cMensaje                         CHAR(100);
DEFINE mTotaliva                        MONEY(14,3);
DEFINE mTotalComision                   MONEY(14,3);
DEFINE iCodigoEstatus                   INTEGER;
DEFINE vsqlerr                          INTEGER;
DEFINE vcodret                          VARCHAR(6);
DEFINE p_mensaje                        VARCHAR(100);
DEFINE cNumeroFolio                     CHAR(16);
DEFINE cNombreArchivo                   CHAR(30);
DEFINE vtranret                         CHAR(4);
DEFINE vfechoy                          DATE;
DEFINE vsdodisp                         MONEY(14,2);
DEFINE vmontoret                        MONEY(14,2);
DEFINE cFolioDispercion                 CHAR(16);
DEFINE mComisionAplicado                MONEY(16,3);
DEFINE mIvaAplicado                     MONEY(16,3);
DEFINE cNombreArchivoConciliacion       CHAR(20);
DEFINE cCuentaEje                       CHAR(20);
DEFINE cCuentaEjeClabe					CHAR(20);
DEFINE cUsuarioAutoriza                 CHAR(8);
DEFINE siValorStatus					SMALLINT;

-- // Variables del sp: conciliacionDispercionNomina
DEFINE v_cCodRet                        CHAR(5);

-- // Nuevas Variables
DEFINE siValorConcepto                  SMALLINT;
DEFINE siValorConceptoAnterior          SMALLINT;
DEFINE cValorTransaccion                CHAR(4);
DEFINE cValorTipoTransaccion            CHAR(3);
DEFINE cTransaccAbono                   CHAR(4);
DEFINE cTransaccCargo                   CHAR(4);
DEFINE mMontoTransComiDisp              MONEY(16,2);
DEFINE mMontoTransComiAper              MONEY(16,2);
DEFINE mMontoTransIvaDisp               MONEY(16,2);
DEFINE mMontoTransIvaAper               MONEY(16,2);
DEFINE mMontoFijo                       MONEY(16,2);
DEFINE mTotalPagado                     MONEY(16,3);
DEFINE mTotalCargo                      MONEY(16,3);
DEFINE cTransaccComiDisp                CHAR(4);    -- // Aqui se traera el 0394
DEFINE cTransacIvaDisp                  CHAR(4);    -- // Aqui se traera el 0396
DEFINE mImporteEmpleadoCuentaEje        MONEY(16,3);
DEFINE mImporteEmpleadoComisionMasIva   MONEY(16,3);
DEFINE cEstatusCuenta                   CHAR(1);
DEFINE vcodretCargo1                    CHAR(6);
DEFINE vcodretCargo2                    CHAR(6);
DEFINE vcodretCargo3                    CHAR(6);
DEFINE vBegin                           CHAR(1);
DEFINE mIvaPorEmpleado                  MONEY(16,2);
DEFINE siTipoEmpresa                    SMALLINT ;
DEFINE cSucursalAbono                   CHAR(4);
DEFINE cSucursalCargo                   CHAR(4);
DEFINE cRecDatonoUtilizableNOperacion   CHAR(4);
DEFINE siVuelta                         INTEGER ;
DEFINE cCargo               			CHAR(2);
DEFINE cAbono               			CHAR(2);
DEFINE cAceptaProducto         			CHAR(50);
DEFINE iContador						INTEGER;
DEFINE vexiste_encab                    CHAR(17);
DEFINE vexiste_ctaeje                   CHAR(20);
DEFINE vexiste_cta                      CHAR(20);
DEFINE cProducto                        CHAR(20);
DEFINE vexiste_sec                      SMALLINT;
DEFINE iNumeroRegistrosAplicados        INTEGER ;
DEFINE vspei                            CHAR(1);
DEFINE mtotalspei                       MONEY(16,3);
DEFINE mtotalcomspei                    MONEY(16,3);
DEFINE mtotalivaspei                    MONEY(16,3);
DEFINE vcomisionspei                    MONEY(16,3);
DEFINE vcomisionspei_gral               MONEY(16,3);  --aqui
DEFINE vnombre_empresa                  CHAR(40);
DEFINE vnumcte_empresa                  CHAR(20); 
DEFINE vrfc_empresa                     CHAR(13);
DEFINE vnombre_beneficiario             CHAR(40);
DEFINE verror                           CHAR(100);
DEFINE vcverastreo                      CHAR(30);
DEFINE vcvebanco_benef					CHAR(5);
DEFINE vcvebanco_cta					CHAR(3);
DEFINE mDispCtaBcoppel					MONEY;
DEFINE mDispCtaOtroBco					MONEY;
--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
DEFINE vExcentaComision					INTEGER;
DEFINE cProductoEje                     CHAR(20);

-- // VALORES INICIALES
LET siValorStatus = 0;
LET p_mensaje = " ";
LET dFechaActual = '' ;
LET cEstatusCta = '' ;
LET cNumeroCuentaEmpleado = '';
LET cNumeroEmpleado = '';
LET mImporteEmpleado = 0;
LET dFechaAplicacion = '';
LET cHoraActual = '' ;
LET cNumeroTarjeta = '';
LET mImporteAbonado = 0;
LET mImporteNoAbonado = 0;
LET mImporteTotalAplicado = 0;
LET siSaldoDisponible = 0 ;
LET mTotalNoPagado = 0;
LET mTotalComisionDispercionIvaEmp = 0;
LET mImporteTotalEnc = 0;
LET mSaldoActual = 0;
LET iNumeroRegistros = 0;
LET iCodigoEstatus = 0;
LET bPrimerEmpleado = "T" ;
LET bSiguienteEmpleado = "F" ;
LET cNombreArchivo = "";
LET iNumeroRegistrosAplicados = 0;
LET siValorConceptoAnterior = 0;
LET cValorTransaccion = '';
LET cValorTipoTransaccion = '';
LET cTransaccAbono = '';
LET cTransaccCargo = '';
LET mMontoTransComiDisp = 0;
LET mMontoTransComiAper = 0;
LET mMontoTransIvaDisp = 0;
LET mMontoTransIvaAper = 0;
LET mMontoFijo = 0;
LET mTotalPagado = 0;
LET mTotalCargo = 0;
LET cTransaccComiDisp = '';
LET cTransacIvaDisp = '';
LET mImporteTotalEnc = 0;
LET mImporteEmpleadoCuentaEje = 0;
LET mImporteEmpleadoComisionMasIva = 0;
LET cEstatusCuenta = '';
LET vBegin = 'N';
LET mIvaPorEmpleado = 0;
LET siTipoEmpresa = 0;
LET cSucursalAbono = '';
LET cSucursalCargo = '';
LET siVuelta = 0;
LET cCargo='';
LET cAbono='';
LET cAceptaProducto = '';
LET cNumeroFolio = '';
LET iContador = 0;
LET vexiste_encab = '';
LET vexiste_ctaeje = '';
LET vexiste_cta = '';
LET vexiste_sec = 0;
LET vspei = 0;
LET mtotalspei = 0;
LET mtotalregspei = 0;
LET mtotalcomspei = 0;
LET mtotalivaspei = 0;
LET vcomisionspei = 0;
LET vcomisionspei_gral = 0; --aqui
LET vnombre_empresa = ' ';
LET vnumcte_empresa = ' ';
LET vrfc_empresa = ' ';
LET vnombre_beneficiario = ' ';
LET verror = ' ';
LET vcverastreo = ' ';
LET vcvebanco_benef = ' ';
LET vcvebanco_cta = ' ';
LET cproducto = '';
LET mDispCtaBcoppel	= 0.0;
LET mDispCtaOtroBco	= 0.0;

--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
LET vExcentaComision = 0;
LET cProductoEje = '';


--SET DEBUG FILE TO '/home/informix/ivonne/sp_dispercionnomina_bpi.out';
--TRACE ON;

BEGIN

	ON EXCEPTION SET vsqlerr
		IF vsqlerr <> 0 OR vsqlerr <> -206 THEN
			LET vcodret = vsqlerr;  --- Dispercion No Ejecutada
			LET cFolioDispercion = "";
			LET mImporteTotalAplicado = 0;
			LET mComisionAplicado = 0;
			LET mIvaAplicado = 0;
			LET cNombreArchivoConciliacion = "";
			IF vBegin = 'S' THEN
				ROLLBACK WORK;
			END IF;
			RETURN vcodret;
		END IF;
	END EXCEPTION;

	ON EXCEPTION IN (-535)
      LET vBegin = 'S';
      COMMIT WORK;
 	END EXCEPTION WITH RESUME;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;

	SELECT fecha_hoy
	  INTO dFechaActual
	  FROM bdicheq:sc_fechas
	 WHERE empresa = "001";

	SELECT FIRST 1 nombre_archivo
	  INTO vexiste_encab
	  FROM bdicheq:sc_nominaencabezadosumario_bpi
	 WHERE status = '1'
	   AND fecha_aplicacion = dFechaActual;

	IF vexiste_encab IS NULL OR vexiste_encab = '' THEN
		LET vcodret = '805'; --- Dispercion No Ejecutada: No Existe el Encabezado del Archivo Ã?el Estatus No es el Correcto;
		RETURN vcodret;
	END IF

	LET cHoraActual = CURRENT;

	-- // Se borra la tabla de control al inicio de cada ciclo
	--TRUNCATE TABLE bdicheq:sc_nominaresultadosdispercionautomatica;

	SELECT valor
	  INTO mMontoTransIvaDisp
	  FROM bdinteg:si_param
	 WHERE cod_param = 47
	   AND empresa = "001";
	   
	--SELECT mnycomision
	--  INTO vcomisionspei_gral --aqui
	--  FROM bdispei:tblcomision;

	-- OBTIENE EL VALOR DE LA COMISION POR DISPERSION DE CTAS DE OTRO BANCO EN LA TABLA si_transsacc con el numero '3257'
	SELECT monto_fijo 
	  INTO vcomisionspei_gral
	  FROM bdinteg:"informix".si_transacc
	 WHERE sistema = '01' 
	   AND empresa = '001'
	   AND numero = '3257';
	  
	IF (mMontoTransIvaDisp = "") OR (mMontoTransIvaDisp = " ") OR (mMontoTransIvaDisp IS NULL) THEN
		LET vcodret = '855';  --- Dispercion No Ejecutada: El Valor del Iva No es Valido
		RETURN vcodret;
	END IF	
	
	FOREACH WITH HOLD
		SELECT empresa, fecha_gen, folio_archivo, nombre_archivo, cuenta_cargo, fecha_aplicacion, total_registros, importe_tot
		  INTO cNumeroEmpresa, dFechaGeneracion, IFolioArchivo, cNombreArchivo, cCuentaEje, dFechaAplicacion, iNumeroRegistros, mImporteTotalEnc
		  FROM bdicheq:sc_nominaencabezadosumario_bpi
		 WHERE status = '1'
		   AND fecha_aplicacion <= dFechaActual
		 ORDER BY empresa, nombre_archivo

		BEGIN WORK;
		LET vBegin = 'S';
		LET vcodret = '000';

		-- // Consulta el Tipo de empresa
		SELECT tipo_empresa, TRIM(acepta_producto), nombre, numcte
		  INTO siTipoEmpresa, cAceptaProducto, vnombre_empresa, vnumcte_empresa
		  FROM bdicheq:sc_nominaempresas
		 WHERE codigo = cNumeroEmpresa;
		 
		SELECT rfc INTO vrfc_empresa
          FROM bdinteg:si_cliente
         WHERE numcte = vnumcte_empresa;		  

		SELECT LIMIT 1 concepto --, nombre_archivo
		  INTO siValorConcepto --, cNombre
		  FROM bdicheq:sc_nominamovimientos_bpi
		 WHERE nombre_archivo = cNombreArchivo
		   AND status = '0';

		--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
		SELECT cuenta, cuenta_clabe, sdo_actual, producto
		  INTO vexiste_ctaeje, cCuentaEjeClabe, mSaldoActual, cProductoEje
		  FROM bdicheq:sc_maechq
		 WHERE empresa = '001'
		   AND cuenta = cCuentaEje;
		   
		--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
		SELECT COUNT(1) INTO vExcentaComision FROM bdicheq:sc_nominaexcentocomision WHERE producto = cProductoEje;

		IF vexiste_ctaeje IS NULL THEN
			LET vcodret  = "810"; --- La cuenta NO Existe en la Base de Datos

				--// Nueva Instruccion Para actualizar el encabezado y saber porque no se disperso el Archivo
			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = '7', --
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo
			   AND nombre_archivo = cNombreArchivo;
			COMMIT WORK;
				LET vBegin = 'N';
			CONTINUE FOREACH;

		ELSE
			
			CALL sp_dispersionnominavalidacionestatus_bpi (cCuentaEje, cNumeroEmpresa, dFechaGeneracion::CHAR(10), iFolioArchivo, dFechaActual::CHAR(10), cHoraActual::CHAR(8), '', '', 0.0, 0.0, '')
				RETURNING vcodret, cEstatusCuenta, cCargo, mImporteNoAbonado, cSucursalCargo, cRecDatonoUtilizableNOperacion;
			
			IF vcodret <> '000' THEN
				COMMIT WORK;
				LET vBegin = 'N';
				CONTINUE FOREACH;
			END IF
		END IF
		
		--// OBTIENE EL VALOR DE LA COMISION POR DISPERSION DE CTAS DE BANCOPPEL EN LA TABLA MAESTRA DE COMISIONES DE PERSONAS MORALES
		SELECT disp_cta_bcoppel, disp_cta_otrobco
		INTO mDispCtaBcoppel, mDispCtaOtroBco
		FROM "informix".sc_maecomtasserv_pm
		WHERE cuenta = cCuentaEje;
		
		--// OBTIENE EL VALOR DE LA COMISION POR DISPERSION DE CTAS DE OTRO BANCO EN LA TABLA MAESTRA DE COMISIONES DE PERSONAS MORALES
		{
		SELECT disp_cta_otrobco
		INTO mDispCtaOtroBco
		FROM "informix".sc_maecomtasserv_pm
		WHERE cuenta = cCuentaEje;
		}

		LET cUsuarioAutoriza = "informix";
		LET mTotalNoPagado = 0;
		LET mImporteAbonado = 0;
		LET mImporteNoAbonado = 0;
		LET mImporteTotalAplicado = 0;
		LET mTotalPagado = 0;
		LET iNumeroRegistrosAplicados = 0;
		LET mTotalCargo = 0;
		LET mtotalspei = 0;
		LET mtotalregspei = 0;
        LET mtotalcomspei = 0;
        LET mtotalivaspei = 0; 

		IF (cNombreArchivo IS NULL) OR (cNombreArchivo = "") OR (cNombreArchivo = " ") THEN
			LET vcodret = '830';
			LET p_mensaje = "Dispercion No Ejecutada: Existe el Encabezado Pero No Existe el Detalle del Archivo";
			LET cFolioDispercion = "";
			LET mImporteTotalAplicado = 0;
			LET mComisionAplicado = 0;
			LET mIvaAplicado = 0;
			LET cNombreArchivoConciliacion = "";

			LET vcodret = '000'; --- Este codigo se deja en 000 porque el ciclo continua ejecutandose para otro archivo y necesita llevar este valor

			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = '6', --Importe restaurado a la cuenta
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo
			   AND nombre_archivo = cNombreArchivo;

			COMMIT WORK;
			LET vBegin = 'N';
		END IF

		LET siValorConceptoAnterior = 0; --- Aqui inicializo la variable cada vez que se vaya a procesar otro archivo

		-- // Se Limpian las Variables en Cada Vuelta
		LET cTransaccAbono = "";
		LET cTransaccCargo = "";
		LET cTransaccComiDisp = "";
		LET cTransacIvaDisp = "";
		LET vcodret = '000';

		{
		SELECT sdo_actual
		  INTO mSaldoActual
		  FROM bdicheq:sc_maechq
		 WHERE empresa ='001'
		   AND cuenta = cCuentaEje;
		}

		SELECT MIN(importe)
		  INTO mImporteEmpleado
		  FROM bdicheq:sc_nominamovimientos_bpi
		 WHERE nombre_archivo = cNombreArchivo
		   AND status = '0'; --- Con status <> 1 tomo todos los registros que no hayan sido procesados

		--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
		IF vExcentaComision > 0 THEN 
			LET mIvaPorEmpleado = 0;
			LET mTotalComisionDispercionIvaEmp = 0;
			LET mImporteEmpleadoCuentaEje = mImporteEmpleado;
		ELSE
			LET mIvaPorEmpleado = mMontoTransComiDisp * mMontoTransIvaDisp;
			LET mTotalComisionDispercionIvaEmp = mMontoTransComiDisp + mIvaPorEmpleado;
			LET mImporteEmpleadoCuentaEje = mImporteEmpleado + mTotalComisionDispercionIvaEmp;
		END IF

			--- Linea nueva aqui valido que por lo menos exista saldo para pagar a un empleado
		IF (mSaldoActual <= 0) OR (mSaldoActual < mImporteEmpleadoCuentaEje) THEN
			LET siSaldoDisponible = 0;
			LET vcodret = '835';
			LET p_mensaje = "Dispercion No Ejecutada: La Cuenta Eje No Tiene Saldo";
			LET cFolioDispercion = "";
			LET mImporteTotalAplicado = 0;
			LET mComisionAplicado = 0;
			LET mIvaAplicado = 0;
			LET cNombreArchivoConciliacion = "";
			LET vcodret = '000'; --- Este codigo se deja en 000 porque el ciclo continua para otro archivo y necesita llevar este valor

			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = '5', --Saldo insuficiente
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo
			   AND nombre_archivo = cNombreArchivo;

			COMMIT WORK;
			LET vBegin = 'N';
			CONTINUE FOREACH;
		ELSE
			LET siSaldoDisponible = 1;
			LET mImporteEmpleado = 0;
			LET mTotalComisionDispercionIvaEmp = 0;
			LET mImporteEmpleadoCuentaEje = 0;
		END IF

		LET cNumeroEmpresa = cNumeroEmpresa;
		LET siValorConcepto = siValorConcepto;

		-- // CICLO PARA VALIDAR LOS VALORES DE LAS TRANSACCIONES
		--- CALL sp_dispersionnominatransacciones (siTipoEmpresa, cNumeroEmpresa, siValorConcepto)
        CALL sp_dispersionnominatransacciones (siTipoEmpresa, siValorConcepto)
		RETURNING vcodret, cValorTipoTransaccion, cValorTransaccion, mMontoFijo, cTransaccAbono, cTransaccCargo,
				  cTransaccComiDisp, mMontoTransComiDisp, mMontoTransComiAper, cTransacIvaDisp, mMontoTransIvaAper;

		IF vcodret <> '000' THEN
			-- // El Numero De transaccion es Invalido o No Existe
			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = '4', --No aplicado cuenta inexistente
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo
			   AND nombre_archivo = cNombreArchivo;

			COMMIT WORK;
			LET vBegin = 'N';
			CONTINUE FOREACH;
		END IF

		LET siVuelta = 0;
		
		--aqui	
		IF mDispCtaOtroBco IS NOT NULL THEN
			LET vcomisionspei = mDispCtaOtroBco;
		ELSE
            LET vcomisionspei = vcomisionspei_gral;
		END IF		
		
		LET vcomisionspei = NVL(vcomisionspei,0);
		
		--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
		IF vExcentaComision > 0 THEN 
			LET vcomisionspei = 0;
		END IF

		FOREACH WITH HOLD

			SELECT mov.num_empleado, mov.cuenta_abono, mov.importe, mov.concepto,
                   TRIM(nombres)||" "||TRIM(apell_paterno)||" "||TRIM(apell_materno)			
			  INTO cNumeroEmpleado, cNumeroCuentaEmpleado, mImporteEmpleado, siValorConcepto, vnombre_beneficiario
			FROM bdicheq:sc_nominamovimientos_bpi mov
			WHERE mov.nombre_archivo = cNombreArchivo
			  AND mov.status = 0 --- Con status <> 1 tomo todos los registros que no hayan sido procesados
			ORDER BY mov.importe

			LET cProducto = ' ';
			
            IF LENGTH(cNumeroCuentaEmpleado) <> 18 THEN
			   SELECT mae.status_cta, mae.producto
			     INTO siValorStatus, cProducto
			     FROM bdicheq:sc_maechq mae
			    WHERE mae.empresa = '001'
				  AND mae.cuenta = cNumeroCuentaEmpleado;
			   LET vspei = '0';
			ELSE
               LET vspei = '1';
            END IF

			LET siVuelta = siVuelta + 1;
			LET iContador = iContador + 1;

			IF (siValorConcepto <> 0) AND (siValorConceptoAnterior <> siValorConcepto) THEN
				LET siValorConceptoAnterior = siValorConcepto;
			END IF

			-- // CICLO PARA VALIDAR LOS VALORES DE LAS TRANSACCIONES
			--- CALL sp_dispersionnominatransacciones(siTipoEmpresa, cNumeroEmpresa, siValorConcepto)
            CALL sp_dispersionnominatransacciones(siTipoEmpresa, siValorConcepto)
			RETURNING vcodret, cValorTipoTransaccion, cValorTransaccion, mMontoFijo, cTransaccAbono, cTransaccCargo,
					  cTransaccComiDisp, mMontoTransComiDisp, mMontoTransComiAper, cTransacIvaDisp, mMontoTransIvaAper;

			IF vcodret <> '000' THEN
				-- // El Numero De transaccion es Invalido o No Existe
				UPDATE bdicheq:sc_nominaencabezadosumario_bpi
				   SET status = '4', --Error
					   fecha_aplicado = dFechaActual,
					   hora_aplicado = cHoraActual
				 WHERE empresa = cNumeroEmpresa
				   AND fecha_gen = dFechaGeneracion
				   AND folio_archivo = IFolioArchivo
				   AND nombre_archivo = cNombreArchivo;

				COMMIT WORK;
				LET vBegin = 'N';
				LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
				CONTINUE FOREACH;
			END IF

			LET cAceptaProducto = TRIM(cAceptaProducto);

		    IF (cProducto IS NULL OR cProducto = ' ') AND vspei = '0' THEN
				-- // Cuenta no existe
				UPDATE bdicheq:sc_nominamovimientos_bpi
				SET status = '4'
				WHERE nombre_archivo = cNombreArchivo
				AND num_empleado = cNumeroEmpleado;

				LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
				CONTINUE FOREACH;
	        END IF

			--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
			IF vExcentaComision > 0 THEN 
				LET mIvaPorEmpleado = 0;
				LET mTotalComisionDispercionIvaEmp = 0;
				LET mImporteEmpleadoComisionMasIva = mImporteEmpleado;
			ELSE
				-- // Inicio de validacion de tipo de empresa externas
				LET mIvaPorEmpleado = mMontoTransComiDisp * mMontoTransIvaDisp;
				LET mTotalComisionDispercionIvaEmp = mMontoTransComiDisp + mIvaPorEmpleado;
				LET mImporteEmpleadoComisionMasIva = mImporteEmpleado + mTotalComisionDispercionIvaEmp;
			END IF
			
			--- Aqui se le resta 1 centavo, porque cuando el saldo inicial de la cuenta eje
			--- es igual a la suma del  monto a dispersar + su comision + su iva
			--- cuando ya esta en el ultimo empleado el proceso le suma 1 centavo
			--- a mTotalCargo + mImporteEmpleadoComisionMasIva, por lo tango
			--- el mSaldoActual es menor que mTotalCargo + mImporteEmpleadoComisionMasIva,
			--- cuando la realidad es que deben de ser iguales.

			IF siVuelta = iNumeroRegistros THEN
				LET mTotalCargo = mTotalCargo - 0.01;
			END IF

			-- // Si el saldo sobrante que me queda es Mayor o Igual al importe a pagar, le pago al empleado
			IF mSaldoActual >= (mTotalCargo + mImporteEmpleadoComisionMasIva) THEN
				LET bSiguienteEmpleado = "T" ;
				LET siSaldoDisponible = 1;
			ELSE
				LET bSiguienteEmpleado = "F" ;
				LET siSaldoDisponible = 0;
			END IF

			IF (bPrimerEmpleado = "T") OR  (bSiguienteEmpleado = "T") THEN
				IF siValorStatus > 1 THEN
				   IF vspei = '0' THEN
					  CALL sp_dispersionnominavalidacionestatus_bpi
					       (cNumeroCuentaEmpleado, '', '', 0, '', '' ,cNombreArchivo, cNumeroEmpleado, mImporteEmpleado, mImporteNoAbonado, siTipoEmpresa)
					       RETURNING vcodret, cEstatusCta, cAbono, mImporteNoAbonado, cRecDatonoUtilizableNOperacion, cSucursalAbono;
				   END IF
				ELSE
					LET cEstatusCta=1;
				END IF

				LET cSucursalAbono = "9103";
				
				-- // Estatus 1 = Cuenta Activa, Estatus 3 = Cuenta Bloqueada,
				-- // Se modifica IF, se le agrego, que pudiera se abonar a la cuenta bloqueada, si el motivo del bloqueo lo permite
				IF vspei = '0' THEN

					
					IF  ((siSaldoDisponible = 1) AND (cEstatusCta = '1' )) OR ((siSaldoDisponible = 1) AND (cAbono = 'S')) THEN
						SELECT MAX(secuencia)
						INTO vexiste_sec
						FROM bdicheq:sc_tarjeta
						WHERE empresa = '001'
						AND cuenta = cNumeroCuentaEmpleado
						AND tipo_tarjeta = "T"
						AND status_tar = "A";

						IF vexiste_sec IS NOT NULL OR vexiste_sec <> '' OR vexiste_sec > 0 THEN
							SELECT NVL(num_tarjeta, '')
							INTO cNumeroTarjeta
							FROM bdicheq:sc_tarjeta
							WHERE empresa = '001'
							AND cuenta = cNumeroCuentaEmpleado
							AND tipo_tarjeta = "T"
							AND status_tar = "A"
							AND secuencia = vexiste_sec;
						ELSE
							LET cNumeroTarjeta = '';
						END IF

						CALL sp_generafolionomina ("informix")
						RETURNING cCodRet, cNumeroFolio;

						-- // Aqui siempre se mandara la empresa 001 indepENDientemente
						-- // del numero de empresa que se este ejecutando tanto para el abono_ref y el cargo_ref

						CALL abono_ref ("001", cSucursalAbono, "informix", cTransaccAbono, "0000", cNumeroFolio, cNumeroCuentaEmpleado,
										0, mImporteEmpleado, mImporteEmpleado, 0, 0, 0, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
						RETURNING vcodret;

						IF vcodret = '000' THEN
							UPDATE bdicheq:sc_nominamovimientos_bpi
							SET status = '1'  --- Aqui actualizo el status = 1  (Aplicado)
							WHERE nombre_archivo = cNombreArchivo
							AND num_empleado = cNumeroEmpleado;

							LET mImporteAbonado = mImporteAbonado + mImporteEmpleado;

							LET iNumeroRegistrosAplicados = iNumeroRegistrosAplicados +1;

							--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
							IF vExcentaComision > 0 THEN 
								LET mTotalComision = 0;
								LET mTotaliva = 0;
							ELSE
								LET mTotalComision = iNumeroRegistrosAplicados * mMontoTransComiDisp;
								LET mTotaliva = mTotalComision * mMontoTransIvaDisp;  --Nueva Forma de Calcular el Iva
							END IF
							
							LET mTotalPagado = mTotalPagado + mImporteEmpleado;
							LET mTotalCargo = mTotalPagado + mTotalComision + mTotaliva;
						ELSE
							UPDATE bdicheq:sc_nominamovimientos_bpi
							SET status = '9'  --- Aqui actualizo el status = 9  (Error en la transaccion del sp abono_ref)
							WHERE nombre_archivo = cNombreArchivo
							AND num_empleado = cNumeroEmpleado;
							LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
						END IF
					ELSE
						UPDATE bdicheq:sc_nominamovimientos_bpi
						SET status = '5' --- Saldo Insuficiente
						WHERE nombre_archivo = cNombreArchivo
						AND num_empleado = cNumeroEmpleado;
						LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
					END IF
				ELSE
					LET cNumeroFolio = "";
                    CALL sp_generafolionomina ("informix")
						RETURNING cCodRet, cNumeroFolio;
					LET vcvebanco_cta = SUBSTR(cNumeroCuentaEmpleado, 1, 3);
					LET vcvebanco_benef = "40"||TRIM(vcvebanco_cta);
					CALL bdispei:sp_regordenpagospei_pp ("001", "informix", cSucursalAbono, cNumeroFolio, vcvebanco_benef, dFechaActual, 1, 0, mImporteEmpleado, vnombre_empresa, cCuentaEjeClabe, vrfc_empresa, vnombre_beneficiario, cNumeroCuentaEmpleado, " ", 0.00, 0,
                                                 " ", " ", " ", " ", " ", " ", "NOMINA", "0274", 40, 40)
						 RETURNING vcodret, verror, vcverastreo;
                     IF vcodret = "000" THEN
						UPDATE bdicheq:sc_nominamovimientos_bpi
						   SET status = '1'  --- Aqui actualizo el status = 1  (Aplicado)
					  	 WHERE nombre_archivo = cNombreArchivo
						   AND num_empleado = cNumeroEmpleado;
						   
						LET mImporteAbonado = mImporteAbonado + mImporteEmpleado;
						LET iNumeroRegistrosAplicados = iNumeroRegistrosAplicados +1;
							
						--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
						IF vExcentaComision > 0 THEN 
							LET mTotalComision = 0;
							LET mTotaliva = 0;
						ELSE
							LET mTotalComision = iNumeroRegistrosAplicados * mMontoTransComiDisp;
							LET mTotaliva = mTotalComision * mMontoTransIvaDisp;  --Nueva Forma de Calcular el Iva
						END IF
						
						LET mTotalPagado = mTotalPagado + mImporteEmpleado;
						LET mTotalCargo = mTotalPagado + mTotalComision + mTotaliva;					 
						LET mtotalspei = mtotalspei + mImporteEmpleado;
						LET mtotalregspei = mtotalregspei + 1;
						
						-- CARGO POR CADA SPEI A REALIZAR CORRESPONDIENTE A CADA IMPORTE ABONADO
						CALL cargo_ref ("001", cSucursalCargo, "informix", '0274', "0331", cNumeroFolio,
							cCuentaEje, 0, mImporteEmpleado, "01", vcverastreo, cNumeroTarjeta, cUsuarioAutoriza)
							RETURNING vcodretCargo1, vtranret, vfechoy, vsdodisp, vmontoret;
						IF vcodretCargo1 = '000' AND vcomisionspei > 0 THEN
							-- CARGO POR COMISION POR CADA DISPERSION
							CALL cargo_ref ("001", cSucursalCargo, "informix", "3257", "0000", cNumeroFolio,
								cCuentaEje, 0, vcomisionspei, "01", vcverastreo, cNumeroTarjeta, cUsuarioAutoriza)
								RETURNING vcodretCargo2, vtranret, vfechoy, vsdodisp, vmontoret;
							IF vcodretCargo2 = '000' THEN
								-- CARGO POR IVA POR COMISION POR CADA DISPERSION
								CALL cargo_ref ("001", cSucursalCargo, "informix", '0260', "0000", cNumeroFolio,
								cCuentaEje, 0, vcomisionspei *  mMontoTransIvaDisp, "01", vcverastreo, cNumeroTarjeta, cUsuarioAutoriza)
								RETURNING vcodretCargo3,vtranret,vfechoy,vsdodisp,vmontoret;
							END IF
						END IF
 				     ELSE
					 	UPDATE bdicheq:sc_nominamovimientos_bpi
						   SET status = '9'  --- Aqui actualizo el status = 9  (Error al enviar el SPEI)
					     WHERE nombre_archivo = cNombreArchivo
						   AND num_empleado = cNumeroEmpleado;
						LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
					 END IF
                END IF
			END IF  -- // FIN de: IF (bPrimerEmpleado = "T") OR  (bSiguienteEmpleado = "T")

			LET bPrimerEmpleado = "F" ;
		END FOREACH;

		-- // Inicio de validacion de tipo de empresa externas
		CALL sp_generafolionomina ("informix")
			RETURNING cCodRet, cNumeroFolio;
			
		--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
		IF vExcentaComision > 0 THEN 
			LET mTotalComspei = 0;
			LET mTotalivaspei = 0;	
			LET mMontoTransComiDisp = 0;
		ELSE
			--aqui
			LET mTotalComspei = mtotalregspei * vcomisionspei;
			LET mTotalivaspei = mTotalComspei * mMontoTransIvaDisp;	
			IF mDispCtaBcoppel IS NOT NULL THEN
				LET mMontoTransComiDisp = mDispCtaBcoppel;
			END IF
		END IF

			-- // Aqui se manda llamar el sp que obtiene los totales del IVA y de la comision de los empleados Aplicados
		CALL sp_nominatotalivacomision_bpi (cNombreArchivo, mMontoTransIvaDisp, mMontoTransComiDisp) 
			RETURNING cCodRet, cMensaje, mTotaliva, mTotalComision, mTotalPagado, mTotalNoPagado, mTotalCargo;
			

		IF mTotalNoPagado <> 0 THEN
			LET iCodigoEstatus = 3;
		ELSE
			LET iCodigoEstatus = 2;
		END IF

		IF cCodRet = '000' THEN
			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = iCodigoEstatus,
				   importe_aplicado = mTotalPagado,
				   importe_no_aplicado = mTotalNoPagado,
				   folio_dispersion = cNumeroFolio,
				   iva = mTotaliva + mTotalivaspei,
				   comision = mTotalComision + mTotalComspei,
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo
			   AND nombre_archivo = cNombreArchivo;
		ELSE
			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = iCodigoEstatus,
				   importe_no_aplicado = mTotalNoPagado,
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo
			   AND nombre_archivo = cNombreArchivo;
		END IF

		LET cNumeroTarjeta = '';
		LET vcodretCargo1 = '000';
		LET vcodretCargo2 = '000';
		LET vcodretCargo3 = '000';
		
		IF mTotalPagado > 0 or mTotalComision > 0 or mtotalspei > 0 THEN
			IF mTotalPagado - mtotalspei > 0 THEN
				CALL cargo_ref ("001", cSucursalCargo, "informix", cTransaccCargo, "0000", cNumeroFolio,
								cCuentaEje, 0, mTotalPagado - mtotalspei, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
					RETURNING vcodretCargo1, vtranret, vfechoy, vsdodisp, vmontoret;
			ELSE
				LET vcodretCargo1 = '000';
			END IF
			/*
			IF vcodretcargo1 = '000' THEN
				IF mtotalspei > 0 THEN
					CALL cargo_ref ("001", cSucursalCargo, "informix", '0274', "0000", cNumeroFolio,
									cCuentaEje, 0, mtotalspei, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
						RETURNING vcodretCargo1, vtranret, vfechoy, vsdodisp, vmontoret;
				ELSE
					LET vcodretCargo1 = '000';
				END IF
			END IF
			*/
			IF vcodretCargo1 = '000' AND mTotalComision > 0 THEN
				CALL cargo_ref ("001", cSucursalCargo, "informix", cTransaccComiDisp, "0000", cNumeroFolio,
								cCuentaEje, 0, mTotalComision, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
				RETURNING vcodretCargo2, vtranret, vfechoy, vsdodisp, vmontoret;

				IF vcodretCargo2 = '000' THEN
					CALL cargo_ref ("001", cSucursalCargo, "informix", '0260', "0000", cNumeroFolio,
									cCuentaEje, 0, mTotaliva, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
					RETURNING vcodretCargo3,vtranret,vfechoy,vsdodisp,vmontoret;
				END IF
			ElIF (vcodretCargo1 = '000') AND (mTotalComision = 0) THEN
			 	 LET vcodretCargo2 = '000';
				 LET vcodretCargo3 = '000';
			END IF
			
            IF vcodretCargo1 = '000' AND mTotalComspei > 0 THEN
				/*
			     CALL cargo_ref ("001", cSucursalCargo, "informix", "3257", "0000", cNumeroFolio,
								cCuentaEje, 0, mTotalComspei, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
				 RETURNING vcodretCargo2, vtranret, vfechoy, vsdodisp, vmontoret;
				 IF vcodretCargo2 = '000' THEN
				    CALL cargo_ref ("001", cSucursalCargo, "informix", '0260', "0000", cNumeroFolio,
									cCuentaEje, 0, mTotalivaspei, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
					RETURNING vcodretCargo3,vtranret,vfechoy,vsdodisp,vmontoret;
				 END IF	  
				 */
			ElIF (vcodretCargo1 = '000') AND (mTotalComision = 0) THEN
				 LET vcodretCargo2 = '000';
				 LET vcodretCargo3 = '000';
			END IF
		END IF

		IF (vcodretCargo1 = '000') AND (vcodretCargo2 = '000') AND (vcodretCargo3 = '000') THEN
			COMMIT WORK;
		ELSE
			ROLLBACK WORK;

			-- // El archivo no efectuo el cargo y deja movimientos en cero pero actualiza el status de encabezado sumario a 9
			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = '9', --Error del cargo_ref
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = iFolioArchivo;
		END IF

		LET v_cCodret ='00000';
		
		CALL sp_dispersiontraspasomovtos_bpi(cNombreArchivo)
		  RETURNING v_cCodRet;
		
	    IF v_cCodRet <> "00000" AND v_cCodRet <> "00001" THEN
	       LET vcodret = '100'; --los registros ya fueron enviados a la tabla historica
	    END IF;
		
		LET vBegin = 'N';
	CONTINUE FOREACH;
	END FOREACH;

	--LET v_cCodret ='00000';

	--Se Corre este procedimiento para enviar los registros procesados a las tablas historicas.
	--EXECUTE PROCEDURE sp_dispersiontraspasomovtos_bpi()
	--INTO v_cCodRet;

	--IF v_cCodRet <> "00000" AND v_cCodRet <> "00001" THEN
	--   LET vcodret = '100'; --los registros ya fueron enviados a la tabla historica
	--END IF;

	RETURN vcodret;
    
    END;
    
END PROCEDURE;