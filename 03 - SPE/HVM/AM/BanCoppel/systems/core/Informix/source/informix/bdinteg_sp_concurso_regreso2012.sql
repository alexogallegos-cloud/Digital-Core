CREATE PROCEDURE "informix".sp_concurso_regreso2012(p_canal INT,p_tpoper INT,p_producto INT, p_numcte CHAR(9),p_sucursal CHAR(4),p_foliosuc CHAR(16),p_importe MONEY(16,2),p_fecha DATE)

RETURNING CHAR(6) AS cCod_Ret,CHAR(16) AS cFolio, CHAR(20) AS cFolio_cupon, CHAR(2) AS cTicket;

--Declaracion de variables

DEFINE cError_Info		VARCHAR(80); 

DEFINE iSql_Err			INTEGER;
DEFINE iIsam_Err		INTEGER;
DEFINE cCod_Ret			VARCHAR(6);
DEFINE cFolio 			CHAR(16);
DEFINE cFolio_cupon		CHAR(20);
DEFINE cTicket			CHAR(2);
DEFINE iNumbol			INTEGER;
DEFINE iNumBolFin		INTEGER;

DEFINE cCvesorteo		VARCHAR(6);
DEFINE cParam			CHAR(5);
DEFINE iPart1			INTEGER;
DEFINE iPart2			INTEGER;
DEFINE iPart3			INTEGER;
DEFINE iPart4			INTEGER;
DEFINE cComienza		CHAR(1);
DEFINE cStatus			CHAR(1);

--Asignacion de variables
LET cError_Info		='';

LET iSql_Err		=0;
LET iIsam_Err		=0;
LET cCod_Ret		='000000'; --todo correcto
LET cFolio 			='';
LET cFolio_cupon	='';
LET cTicket			='';
LET iNumbol			=0;
LET iNumBolFin		=0;

LET cCvesorteo		='';
LET cParam			='';
LET iPart1			=0;
LET iPart2			=0;
LET iPart3			=0;
LET iPart4			=0;
LET cComienza		='N';
LET cStatus			='0';

BEGIN

	ON EXCEPTION SET iSql_Err, iIsam_Err, cError_Info
		LET cCod_Ret    = iSql_Err;
		RETURN cCod_Ret, cFolio,cFolio_cupon,cTicket;
	END EXCEPTION;
	
	ON EXCEPTION IN (-535)
		LET cComienza = "S";
	END EXCEPTION WITH RESUME;
	
	--SET DEBUG FILE TO "/tmp/sp_concurso_regreso2012.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--Verificar si esta activado el sorteo instantaneo
	SELECT valor INTO cParam
	FROM bdinteg:"informix".si_param
	WHERE cod_param = 117;
	
	IF cParam = '1' THEN
		--Verificar la clave del sorteo de las madres
		SELECT valor INTO cParam
		FROM bdinteg:"informix".si_param
		WHERE cod_param = 136; 
		
		--Verificar la fecha se encuentre dentro del rango del sorteo 04 Agosto al 02 de Septiembre y que sea el sorteo indicado
		SELECT {+INDEX (bdinteg:"informix".si_sorteo idx_si_sorteo)}
		cve_sorteo
		INTO cCvesorteo
		FROM bdinteg:"informix".si_sorteo
		WHERE  p_fecha  BETWEEN f_ini AND f_fin
		AND cve_sorteo = cParam;
		
		IF cCvesorteo = '' OR cCvesorteo IS NULL THEN
			--'NO EXISTE SORTEOS ACTIVOS EN ESTA FECHA';
		ELSE
			--Verificar que la persona no es persona fisica y se encuentra dentro del catalogo de personas morales
			IF EXISTS (SELECT {+INDEX (bdinteg:"informix".si_cltenoparticipa idx_si_cltenoparticipa)}numcte, tpo_persona
				FROM bdinteg:"informix".si_cltenoparticipa
				WHERE numcte = p_numcte) THEN
				--'LA PERSONA ES MORAL NO PARTICIPA'
			ELSE
				--Verificar que cumpla con el perfil establecido
				SELECT {+INDEX (bdinteg:"informix".si_participa idx_si_participa)}
				SUM(CASE WHEN tipo_participa = '1' AND id_elemento = p_producto THEN 1 ELSE 0 END) prod, --tipo de producto
				SUM(CASE WHEN tipo_participa = '2' AND id_elemento = p_tpoper THEN 1 ELSE 0 END) trans, --tipo de operacion 
				SUM(CASE WHEN tipo_participa = '3' AND id_elemento = p_canal THEN 1 ELSE 0 END) canal, --tipo de canal
				SUM(CASE WHEN tipo_participa = '4' AND id_elemento = 1 THEN 1 ELSE 0 END) tpo_per, --tipo de persona
				SUM(CASE WHEN tipo_participa = '2' AND id_elemento = p_tpoper AND p_importe >= val_min THEN 1 ELSE 0 END) numbol --cumple con el minimo para entregarle boleto
				INTO iPart1,iPart2,iPart3,iPart4,iNumbol
				FROM bdinteg:"informix".si_participa
				WHERE cve_sorteo = cCvesorteo;
				
				--Si se cumple con el perfil comprobar que no sea empleado
				IF iPart1 = 1 AND iPart2 = 1 AND iPart3 = 1 AND iPart4 = 1 AND iNumbol = 1 THEN
					IF EXISTS(SELECT producto FROM bdicheq:"informix".sc_maechq 
					WHERE num_cte = p_numcte AND producto = '1300' AND empresa = '001') THEN
						--'ES EMPLEADO';
					ELSE
						--Obtener el boleto 
						BEGIN WORK;
							SELECT  {+INDEX (bdinteg:"informix".si_sorteo idx_si_sorteo_cve)} max_boleto, boleto_ini, boleto_fin INTO cFolio, iNumbol, iNumBolFin
							FROM bdinteg:"informix".si_sorteo 
							WHERE cve_sorteo = cCvesorteo;
							
							--Si aun no se ha registrado ningun boleto se asigna el primer boleto
							IF cFolio = '' OR cFolio IS NULL OR cFolio = '0' THEN
								LET cFolio = iNumbol - 1;
								UPDATE {+INDEX (bdinteg:"informix".si_sorteo idx_si_sorteo)} bdinteg:"informix".si_sorteo
								SET max_boleto = cFolio
								WHERE cve_sorteo = cCvesorteo;
							END IF;
							
							--Si el boleto actual es menor al boleto maximo
							IF cFolio <= iNumBolFin THEN
								UPDATE {+INDEX (bdinteg:"informix".si_sorteo idx_si_sorteo)} bdinteg:"informix".si_sorteo
								SET max_boleto = max_boleto + 1
								WHERE cve_sorteo = cCvesorteo;
								
								SELECT {+INDEX (bdinteg:"informix".si_sorteo idx_si_sorteo_cve)} max_boleto INTO cFolio 
								FROM bdinteg:"informix".si_sorteo 
								WHERE cve_sorteo = cCvesorteo ;
							ELSE
								LET cTicket = 3;
							END IF;
							
						COMMIT WORK;
						
						IF cComienza = "S" THEN
							BEGIN WORK;
						END IF;
						
						IF cTicket = '' THEN
							--Selecciona y obtiene la informacion del folio
							SELECT {+INDEX (bdinteg:"informix".si_premios_regreso2012 idx_premios_regreso2012)} folio, folio_cupon, ticket, estatus 
							INTO cFolio, cFolio_cupon, cTicket, cStatus
							FROM bdinteg:"informix".si_premios_regreso2012
							WHERE folio = cFolio;
						END IF;
						
						IF cFolio_cupon IS NULL THEN
							LET cFolio_cupon = '';
						END IF;
						
						IF cTicket = '4' AND p_importe >= 651 AND cStatus = 1 THEN
						
							UPDATE {+INDEX (bdinteg:"informix".si_premios_regreso2012 idx_premios_regreso2012)} bdinteg:"informix".si_premios_regreso2012 
							SET estatus = '2'
							WHERE ticket = '4';
						ELIF cTicket = '4' AND p_importe >= 651 AND cStatus = 2 THEN
						
							LET cTicket = '2';
							
						ELIF cTicket = '4' AND (p_importe >= 650 AND p_importe < 651)	THEN
							UPDATE {+INDEX (bdinteg:"informix".si_premios_regreso2012 idx_premios_regreso2012)} bdinteg:"informix".si_premios_regreso2012 
							SET estatus = '2', foliosuc = p_foliosuc, f_asignado = p_fecha 
							WHERE ticket = '4' AND Folio = cFolio;
							LET cTicket = '2';
							LET cStatus = 2;
						END IF;
						
						IF cStatus = 1 THEN						
							UPDATE {+INDEX (bdinteg:"informix".si_premios_regreso2012 idx_premios_regreso2012)} bdinteg:"informix".si_premios_regreso2012 
							SET estatus = '2', sucursal = p_sucursal,numcte = p_numcte, foliosuc = p_foliosuc, 
							tipo_operacion = p_tpoper, importe = p_importe, f_asignado = p_fecha WHERE folio = cFolio;						
						END IF
					END IF;
				ELSE 
					--'NO CUMPLE CON PARAMETROS';
				END IF;
			END IF;
		END IF;
	ELSE
		--'NO ACTIVADO EL SORTEO INSTANTANEO';
	END IF;
	
	RETURN cCod_Ret, cFolio,cFolio_cupon,cTicket;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Josue Zepeda',
'FECHA: 06/07/2012',
'BD: bdinteg',
'Objetivo: Sorteo Regreso a clases 2012';

CREATE PROCEDURE "informix".sp_cnsif_consulta_saldos_general(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20))
							
				returning CHAR(5)       AS Codigo_Retorno,
						  DATE          AS fecha_origen,
						  DATE          AS fecha_prox_pago,
						  DECIMAL(18,2) AS pago_minimo,
						  DATE          AS fecha_ult_pago,
						  INTEGER       AS plazo,
						  INTEGER       AS pagos_realizados,
						  DECIMAL(18,2) AS linea_otorgada,
						  DECIMAL(9,6)  AS tasa_interes,
						  DECIMAL(9,6)  AS tasa_moratorios,
						  DECIMAL(14,2) AS monto_sbc,
						  DECIMAL(18,2) AS cap_vig,
						  DECIMAL(18,2) AS cap_trans,
						  DECIMAL(18,2) AS cap_vdo_exig,
						  DECIMAL(18,2) AS cap_vdo_no_exig,
						  DECIMAL(18,2) AS sdo_act_total_cap,
						  DECIMAL(18,2) AS int_vig,
						  DECIMAL(18,2) AS int_vdo,
						  DECIMAL(18,2) AS int_moratorios,
						  DECIMAL(18,2) AS int_mes,
						  DECIMAL(18,2) AS sdo_act_total_int,
						  DECIMAL(18,2) AS iva_int_vig,
						  DECIMAL(18,2) AS iva_int_vdo,
						  DECIMAL(18,2) AS iva_int_moratorios,
						  DECIMAL(18,2) AS iva_int_mes,
						  DECIMAL(18,2) AS sdo_act_total_iva,
						  DECIMAL(18,2) AS com_pend,
						  DECIMAL(18,2) AS iva_com,
						  DECIMAL(18,2) AS sdo_retenido,
						  DECIMAL(18,2) AS total_liquidacion,
						  DECIMAL(18,2) AS int_devengado,
						  DECIMAL(18,2) AS iva_int_devengado,
						  DECIMAL(18,2) AS linea_disponible,
						  DECIMAL(18,2) AS pagos_vdos,
						  DECIMAL(18,2) AS pago_inmediato;
						  
							
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;

--VARIABLES PARA EL STORE
DEFINE 	codigo_retorno   	  CHAR(6);
DEFINE 	mensaje_retorno  	  CHAR(80);
DEFINE 	numero_credito   	  CHAR(20);
DEFINE 	codigo_tipcred   	  CHAR(2);         
DEFINE 	fecha_origen     	  DATE;
DEFINE 	fecha_prox_pago  	  DATE;
DEFINE 	pago_minimo      	  DECIMAL(18,2);
DEFINE 	fecha_ult_pago   	  DATE;
DEFINE 	plazo            	  INTEGER;
DEFINE 	pagos_realizados 	  INTEGER;
DEFINE 	linea_otorgada   	  DECIMAL(18,2);
DEFINE 	tasa_interes     	  DECIMAL(9,6);
DEFINE 	tasa_moratorios       DECIMAL(9,6);
DEFINE 	monto_sbc        	  DECIMAL(14,2);
DEFINE 	cap_vig          	  DECIMAL(18,2);
DEFINE 	cap_trans        	  DECIMAL(18,2);
DEFINE 	cap_vdo_exig	 	  DECIMAL(18,2);
DEFINE 	cap_vdo_no_exig  	  DECIMAL(18,2);
DEFINE 	sdo_act_total_cap 	  DECIMAL(18,2);
DEFINE 	int_vig          	  DECIMAL(18,2);
DEFINE 	int_vdo               DECIMAL(18,2);
DEFINE 	int_moratorios   	  DECIMAL(18,2);
DEFINE 	int_mes          	  DECIMAL(18,2);
DEFINE 	sdo_act_total_int 	  DECIMAL(18,2);
DEFINE 	iva_int_vig      	  DECIMAL(18,2);
DEFINE 	iva_int_vdo      	  DECIMAL(18,2);
DEFINE 	iva_int_moratorios 	  DECIMAL(18,2);
DEFINE 	iva_int_mes      	  DECIMAL(18,2);
DEFINE 	sdo_act_total_iva 	  DECIMAL(18,2);
DEFINE 	com_pend              DECIMAL(18,2);
DEFINE 	iva_com          	  DECIMAL(18,2);
DEFINE 	sdo_retenido     	  DECIMAL(18,2);
DEFINE 	total_liquidacion 	  DECIMAL(18,2);
DEFINE 	int_devengado    	  DECIMAL(18,2);
DEFINE 	iva_int_devengado 	  DECIMAL(18,2);
DEFINE 	linea_disponible  	  DECIMAL(18,2);
DEFINE 	pagos_vdos       	  DECIMAL(18,2);
DEFINE 	desc_status_cred	  CHAR(60);
DEFINE 	id_bloqueo_cred  	  INTEGER;
DEFINE 	bloqueo_cta           CHAR(60);
DEFINE 	id_causa_bloqueo_cred CHAR(3);
DEFINE 	causa_bloqueo_cta     CHAR(50);
DEFINE 	id_sit_esp_cte    	  CHAR(1);
DEFINE 	id_causa_esp_cte      INTEGER;
DEFINE 	sit_esp_cte           CHAR(75);
DEFINE 	id_sit_esp_cred       CHAR(1);
DEFINE 	id_causa_esp_cred     INTEGER;
DEFINE 	sit_esp_cred          CHAR(75);

--VARIABLES EXTRAS
DEFINE decPagoInmediato      DECIMAL(18,2);

--inicializando variables
LET  iexiste 			 = 0;
LET cCodRet 	   = "00000";
LET iSql_err 			= 0 ;	

--INICIALIZA VARIABLES STORE
LET codigo_retorno   	  = "";
LET mensaje_retorno  	  = "";
LET numero_credito   	  = "";
LET codigo_tipcred   	  = "";
LET fecha_origen     	  = "";
LET fecha_prox_pago  	  = "";
LET pago_minimo      	  = 0;
LET fecha_ult_pago   	  = "";
LET plazo            	  = 0;
LET pagos_realizados 	  = 0;
LET linea_otorgada   	  = 0;
LET tasa_interes     	  = 0;
LET tasa_moratorios       = 0;
LET monto_sbc        	  = 0;
LET cap_vig          	  = 0;
LET cap_trans        	  = 0;
LET cap_vdo_exig	 	  = 0;
LET cap_vdo_no_exig  	  = 0;
LET sdo_act_total_cap 	  = 0;
LET int_vig          	  = 0;
LET int_vdo               = 0;
LET int_moratorios   	  = 0;
LET int_mes          	  = 0;
LET sdo_act_total_int 	  = 0;
LET iva_int_vig      	  = 0;
LET iva_int_vdo      	  = 0;
LET iva_int_moratorios 	  = 0;
LET iva_int_mes      	  = 0;
LET sdo_act_total_iva 	  = 0;
LET com_pend              = 0;
LET iva_com          	  = 0;
LET sdo_retenido     	  = 0;
LET total_liquidacion 	  = 0;
LET int_devengado    	  = 0;
LET iva_int_devengado 	  = 0;
LET linea_disponible  	  = 0;
LET pagos_vdos       	  = 0;
LET desc_status_cred	  = "";
LET id_bloqueo_cred  	  = 0;
LET bloqueo_cta           = "";
LET id_causa_bloqueo_cred = "";
LET causa_bloqueo_cta     = "";
LET id_sit_esp_cte    	  = "";
LET id_causa_esp_cte      = 0;
LET sit_esp_cte           = "";
LET id_sit_esp_cred       = "";
LET id_causa_esp_cred     = 0;
LET sit_esp_cred          = "";

LET decPagoInmediato     = 0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
			tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, 
			sdo_act_total_int, iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, 
			iva_int_devengado, linea_disponible, pagos_vdos, decPagoInmediato;
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consulta_saldos_general.out";
	--TRACE ON;
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA  = ''	THEN 
		LET cCodRet = "00045";
		RETURN
			cCodRet, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
			tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, 
			sdo_act_total_int, iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, 
			iva_int_devengado, linea_disponible, pagos_vdos, decPagoInmediato;
	END IF;	

	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
		RETURN  
				cCodRet, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
				tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, 
				sdo_act_total_int, iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, 
				iva_int_devengado, linea_disponible, pagos_vdos, decPagoInmediato;
	END IF;
	-- TERMINA VALIDACION	
        FOREACH
            SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS CONT INTO iexiste FROM bdicred:sd_maecred WHERE num_credito  = cNUMCUENTA
            UNION
            SELECT NVL(COUNT(num_credito),0) AS CONT FROM bdicred:sd_maecredcrd WHERE num_credito  = cNUMCUENTA ORDER BY CONT DESC
        END FOREACH;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00046";
			RETURN 
			cCodRet, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
			tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, 
			sdo_act_total_int, iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, 
			iva_int_devengado, linea_disponible, pagos_vdos, decPagoInmediato;
		END IF;
		set isolation to dirty read;
		
		EXECUTE PROCEDURE bdicred:sp_consulta_saldos_general('001',cNUMCUENTA)
		INTO
		codigo_retorno, mensaje_retorno, numero_credito, codigo_tipcred, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
		tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, 
		sdo_act_total_int, iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, 
		iva_int_devengado, linea_disponible, pagos_vdos, desc_status_cred, id_bloqueo_cred, bloqueo_cta, id_causa_bloqueo_cred, causa_bloqueo_cta, id_sit_esp_cte, 
		id_causa_esp_cte, sit_esp_cte, id_sit_esp_cred, id_causa_esp_cred, sit_esp_cred;          
		
		--LET decPagoInmediato = cap_trans + cap_vdo_exig + int_vdo +	int_moratorios + iva_int_vdo + iva_int_moratorios;
		LET decPagoInmediato = pago_minimo + int_vdo +	int_moratorios + iva_int_vdo + iva_int_moratorios;

		LET cCodRet = SUBSTR(codigo_retorno,2,6);
        IF cCodRet='00001' THEN
            LET cCodRet ='00047';
        ELIF cCodRet='00002' THEN    
            LET cCodRet ='00017';
        END IF;
		RETURN 
		    cCodRet, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
			tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, 
			sdo_act_total_int, iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, 
			iva_int_devengado, linea_disponible, pagos_vdos, decPagoInmediato;

END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de la Cuenta de Crédito de una Cliente respecto a:  Capital, Interés, IVA, Devengado, Saldos, Otros y Pago Inmediato. ",
"El SP extraerá la información de la Base de Datos central de Informix, enviando como parámetro el  No. de Cuenta.",
"FECHA : 05-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_consulta_telefonos(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCTE CHAR(20),pNumRegistro INTEGER,pRecuperacion INTEGER)
RETURNING CHAR(5),CHAR(20),SMALLINT,CHAR(13),CHAR(5);
          
    DEFINE iexiste 			INT;
    DEFINE cCodRet 			CHAR(5);
    DEFINE iSql_err 		INT;	
 
    DEFINE cTipoTel         CHAR(20);   
    DEFINE sSecuencia       SMALLINT;
    DEFINE vTelefono        CHAR(13);
    DEFINE vExtension       CHAR(5);
    DEFINE iCont INTEGER;

    LET  iexiste = 0;
    LET cCodRet = "00000";
    LET iSql_err = 0 ;	
    LET cTipoTel       = '';
    LET sSecuencia        =0;
    LET vTelefono         = '';
    LET vExtension      = '';
    LET iCont=0;
    
    BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, cTipoTel, sSecuencia, vTelefono, vExtension;
		END IF;
	END EXCEPTION;
    
    --- SET DEBUG FILE TO "/informix/VH/sp_consulta_telefonos.out";
    --- TRACE ON;

    -- // VALIDA PARAMETROS DE ENTRADA
	IF 	cID_USUARIOC = '' OR
		cID_FUNCIONC = '' OR
		cNUMCTE  = ''     THEN 
        LET cCodRet = "00054";
        RETURN cCodRet, cTipoTel, sSecuencia, vTelefono, vExtension;
	END IF;	

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
        RETURN cCodRet, cTipoTel, sSecuencia, vTelefono, vExtension;
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet, cTipoTel, sSecuencia, vTelefono, vExtension;
        END IF;
    END IF;  
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCTE,'11','2')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet, cTipoTel, sSecuencia, vTelefono, vExtension;
	END IF;
	-- TERMINA VALIDACION
    SELECT NVL(COUNT(numcte),0)  INTO iexiste FROM si_telefonos WHERE numcte = cNUMCTE;
    IF iexiste = 0 THEN 
        LET cCodRet = "00096";
        RETURN cCodRet, cTipoTel, sSecuencia, vTelefono, vExtension;
    END IF;	    
    SET ISOLATION TO DIRTY READ;
    
        FOREACH
            SELECT SKIP pNumRegistro FIRST pRecuperacion 
			   CASE
			   WHEN tipo_tel = 1 THEN 
				'TEL. PARTICULAR'
			   WHEN tipo_tel = 2 THEN 
				'TEL. MOVIL'
			   WHEN tipo_tel = 3 THEN 
				'TEL. TRABAJO'
			   WHEN tipo_tel = 4 THEN 
				'OTRO'
			   ELSE 
				' '
			   END AS tipo_TEL,secuencia,telefono, extension
              INTO cTipoTel, sSecuencia, vTelefono, vExtension
              FROM si_telefonos
             WHERE numcte = cNUMCTE
             ORDER BY secuencia DESC
             
            LET iCont=iCont+1;  
            RETURN cCodRet,cTipoTel, sSecuencia, vTelefono, vExtension WITH RESUME;
        END FOREACH;
        IF iCont = 0 THEN
            LET cCodRet = '1001'; 
            RETURN cCodRet,cTipoTel, sSecuencia, vTelefono, vExtension;
        END IF 	
END
END PROCEDURE;