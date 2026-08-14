CREATE PROCEDURE "informix".sp_importarcofetel_mib()
	
	--DATOS A REGRESAR
	RETURNING CHAR(5);

	--DEFINICIÓN DE VARIABLES
	DEFINE cCodret 	CHAR(5);
	DEFINE iSqlErr 	INTEGER;
	DEFINE cSql 	CHAR(200);
	DEFINE cRuta 	VARCHAR(200);
	DEFINE vExiste	INTEGER;

	--INICIALIZA VARIABLES
	LET cCodret ='000';
	LET iSqlErr = 0;
	LET cSql 	= '';
	LET cRuta 	= '';
	LET vExiste = 0;

	SET DEBUG FILE TO "/tmp/sp_importarcofetel.out";
	TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
		
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN cCodret;
			END IF;

		END EXCEPTION;

		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		SELECT TRIM(valor)
		INTO cRuta
		FROM bdinteg:"informix".si_param
		WHERE cod_param = "58";

		if (cRuta IS NULL) OR (cRuta = '') THEN

			LET cCodret = '001';

		END IF;

		--- VERIFICA SI EXISTE LA TABLA TEMPORAL PARA BORRARLA
		SELECT count(*) 
		into vExiste 
		FROM "informix".tmp_si_cattelefono_mib;

		IF (vExiste > 0) THEN

			LET cSql = '';
			LET cSql = 'echo "unload to  '|| cRuta || 'resp_telefonos.unl' || ' SELECT * FROM tmp_si_cattelefono_mib" > ' || cRuta || 'instruccion1.sql';
			SYSTEM cSql;
			LET cSql = '';
			LET cSql = "chmod 777 " || cRuta || 'instruccion1.sql';
			SYSTEM cSql;

			LET cSql = '';
			LET cSql = 'dbaccess bdinteg '|| cRuta || 'instruccion1.sql';
			SYSTEM cSql;

			LET cSql = '';
			LET cSql = "chmod 777 " || cRuta || 'resp_telefonos.unl';
			SYSTEM cSql;

			truncate table "informix".tmp_si_cattelefono_mib;

		END IF;

		LET cSql = '';
		LET cSql = 'echo "LOAD FROM '|| cRuta || 'telefonos.sql' || ' DELIMITER ' || '''|''' || ' INSERT INTO tmp_si_cattelefono_mib" > ' || cRuta || 'instruccion.sql';
		SYSTEM cSql;
		LET cSql = '';
		LET cSql = "chmod 777 " || cRuta || 'instruccion.sql';
		SYSTEM cSql;

		LET cSql = '';
		LET cSql = 'dbaccess bdinteg '|| cRuta || 'instruccion.sql';
		SYSTEM cSql;

		RETURN cCodret;

	END
END PROCEDURE

DOCUMENT
'REALIZO:	Carmén Orozco',
'FECHA:		27-12-2008',
'FUNCION:	Carga el archivo de la COFETEL a la tabla  si_cattelefonos',
'BDD:		bdinteg',

'MODIFICO:	Mohamed Carreón',
'FECHA:		17-02-2009',
'FUNCION:	Carga el archivo de la COFETEL a la tabla  temporal tmp_si_cattelefonos y no a la tabla  si_cattelefonos',
'BDD:		bdinteg',

'MODIFICO:	Frank Gaxiola',
'FECHA:		17-11-2009',
'FUNCION:	Se modifica para que la ruta del servidor sea tomada de un parametro',
'BDD:		bdinteg',

'MODIFICO:	Daniela Ramírez',
'FECHA:		31-01-2012',
'FUNCION:	Se aplican reglas de informix',
'BDD:		bdinteg';

CREATE PROCEDURE "informix".sp_cnsif_consulta_saldos_general2(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20))
							
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
						  DECIMAL(18,2) AS pago_inmediato,
                          DATE          AS Fecha_Cartera_Vendida;
						  
							
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
DEFINE  dFechCartVendida      DATE;


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
LET dFechCartVendida     ="";

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
			tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, 
			sdo_act_total_int, iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, 
			iva_int_devengado, linea_disponible, pagos_vdos, decPagoInmediato,dFechCartVendida;
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
			iva_int_devengado, linea_disponible, pagos_vdos, decPagoInmediato,dFechCartVendida;
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
				iva_int_devengado, linea_disponible, pagos_vdos, decPagoInmediato,dFechCartVendida;
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
			iva_int_devengado, linea_disponible, pagos_vdos, decPagoInmediato,dFechCartVendida;
		END IF;
		set isolation to dirty read;
		
		EXECUTE PROCEDURE bdicred:sp_consulta_saldos_general('001',cNUMCUENTA)

		INTO
		codigo_retorno, mensaje_retorno, numero_credito, codigo_tipcred, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
		tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, 
		sdo_act_total_int, iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, 
		iva_int_devengado, linea_disponible, pagos_vdos, desc_status_cred, id_bloqueo_cred, bloqueo_cta, id_causa_bloqueo_cred, causa_bloqueo_cta, id_sit_esp_cte, 
		id_causa_esp_cte, sit_esp_cte, id_sit_esp_cred, id_causa_esp_cred, sit_esp_cred;          
		
		IF pago_minimo < 0 then
            Let pago_minimo = 0;
        END IF;
		--LET decPagoInmediato = cap_trans + cap_vdo_exig + int_vdo +	int_moratorios + iva_int_vdo + iva_int_moratorios;
		LET decPagoInmediato = pago_minimo + int_vdo +	int_moratorios + iva_int_vdo + iva_int_moratorios;

		LET cCodRet = SUBSTR(codigo_retorno,2,6);
        IF cCodRet='00001' THEN
            LET cCodRet ='00047';
        ELIF cCodRet='00002' THEN    
            LET cCodRet ='00017';
        END IF;

        FOREACH
            SELECT LIMIT 1 fecha INTO dFechCartVendida FROM bdicred:sd_maecred_vendida WHERE num_credito  = cNUMCUENTA
            UNION
            SELECT fecha FROM bdicred:sd_maecredcrd_vendida WHERE num_credito  = cNUMCUENTA
        END FOREACH;



		RETURN 
		    cCodRet, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
			tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, 
			sdo_act_total_int, iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, 
			iva_int_devengado, linea_disponible, pagos_vdos, decPagoInmediato,dFechCartVendida;

END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÃA",
"FUNCIONAMIENTO:Obtener la informaciÃ³n de la Cuenta de CrÃ©dito de una Cliente respecto a:  Capital, InterÃ©s, IVA, Devengado, Saldos, Otros y Pago Inmediato. ",
"El SP extraerÃ¡ la informaciÃ³n de la Base de Datos central de Informix, enviando como parÃ¡metro el  No. de Cuenta.",
"FECHA : 05-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_consultamotivocancelacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistemaCuenta CHAR(2), pCliente CHAR(20), pCuenta CHAR(20))
	RETURNING 
		CHAR(5) AS codret,
		CHAR(40) AS motivo_cancelacion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cMotivoCancelacion CHAR(40);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET cMotivoCancelacion = '';
	LET iSqlErr = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN				
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cMotivoCancelacion;			
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/tmp/mfinis/sp_consultamotivocancelacion.out";
	    --TRACE ON;
		
		IF pCliente = '' OR pCuenta = '' OR pSistemaCuenta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cMotivoCancelacion;
		END IF;
		
		IF pSistemaCuenta NOT IN ('01', '03', '06') THEN
			LET cCodRet = '00037';
			RETURN cCodRet, cMotivoCancelacion;
		END IF;
		
		
		
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(pUsuario,pIdFuncion, pCliente, pSistemaCuenta,'2')INTO cCodRet;
		
		IF (cCodRet != '00000')  THEN
			RETURN cCodRet, cMotivoCancelacion;
		END IF;
		
		IF pSistemaCuenta = '01' THEN
			
			SET ISOLATION TO DIRTY READ;
			
			SELECT descripcion
				INTO cMotivoCancelacion 
			FROM bdicheq:"informix".sc_maechq ma
			LEFT JOIN bdicheq:"informix".sc_motivocancel mb 
				ON ma.empresa = mb.empresa
				AND ma.motivo = mb.clave
			WHERE ma.empresa = '001' 
				AND ma.num_cte = pCliente
				AND ma.cuenta = pCuenta;		
			
		END IF;
		
		RETURN cCodRet, cMotivoCancelacion;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 21/04/2017',
'MODULO: Consultas ',
'FUNCIONALIDAD: Cintilla Cuentas CaptaciÃ³n',
'DESCRIPCION: Spl quee realiza la consulta del motivo de cancelaciÃ³n',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_consultacta_club_pba1(pEmpresa CHAR(3), pCliente CHAR(20), pPoliza CHAR(20),pCteCoppel CHAR(20))
RETURNING CHAR(6) as CodRet, CHAR(1) AS Domiciliada, CHAR(20) AS NumCta, CHAR(20) AS NumTarjeta, CHAR(4) AS SucOperante, CHAR(8) AS NumPromotor, CHAR(16) AS FolioOperacion, CHAR(1) AS Respuesta;

--DEFINICION DE VARIABLES
DEFINE cCodret CHAR(6);
DEFINE iSqlErr INTEGER;
DEFINE cDomiciliada CHAR(1);
DEFINE cNumCta CHAR(20);
DEFINE cNumTarjeta CHAR(20);
DEFINE cSucOperante CHAR(4);
DEFINE cNumPromotor CHAR(8);
DEFINE cFolioOperacion CHAR(16);
DEFINE cTipoPago CHAR(1);
DEFINE dFecha DATETIME YEAR TO SECOND;
DEFINE cRespuesta CHAR(1);
--INICIALIZACION DE VARIABLES 
LET cCodret	= "000000";
LET iSqlErr = 0;
LET cDomiciliada = '';
LET cNumCta='';
LET cNumTarjeta='';
LET cSucOperante='';
LET cNumPromotor='';
LET cFolioOperacion='';
LET cRespuesta='';

--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_consultacta_club.out';
    --TRACE ON;
	
BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN cCodret, cDomiciliada, cNumCta, cNumTarjeta, cSucOperante,cNumPromotor,cFolioOperacion,cRespuesta;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		IF TRIM(NVL(pEmpresa,''))='' OR TRIM(NVL(pCliente,''))='' OR TRIM(NVL(pPoliza,''))='' THEN
			LET cCodret	= "000001";
		ELSE
			SELECT  MAX(fecha)
			INTO dFecha
			FROM "informix".si_club_bitacora 
			WHERE numcte=pCliente 
			AND numcte_coppel=pCteCoppel 
			AND empresa=pEmpresa;
			
			SELECT respuesta
			INTO cRespuesta
			FROM "informix".si_club_bitacora 
			WHERE numcte=pCliente 
			AND numcte_coppel=pCteCoppel 
			AND empresa=pEmpresa
			AND fecha=dFecha;
		
			SELECT suc_alta, ejecutivo, tipo_pago, num_tarjeta, num_cta,foliooperacion
			INTO cSucOperante,cNumPromotor,cTipoPago,cNumTarjeta,cNumCta,cFolioOperacion
			FROM  "informix".si_club_proteccion
			WHERE empresa= pEmpresa AND numcte=pCliente;
			--AND num_poliza= pPoliza;
		
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodret	= "000002";
			ELSE
				IF TRIM(NVL(cTipoPago,''))='1' THEN
					LET cDomiciliada = 'S';
				ELSE 
					LET cDomiciliada = 'N';
					LET cNumCta='';
					LET cNumTarjeta='';
				END IF
			END IF
		END IF
		
RETURN cCodret, cDomiciliada, cNumCta, cNumTarjeta, cSucOperante,cNumPromotor,cFolioOperacion,cRespuesta;
END
END PROCEDURE

DOCUMENT
"Descripción: Retorna la cuenta domiciliada para el Club de protección.",
"Autor : Leslie Rendón",
"FECHA : 07/07/2014",
"BD    : bdinteg",

'Descripción: Se comenta filtro num_poliza = pPoliza para que no se realice la comparacion en la tabla si_club_proteccion',
'Autor : Bryan Limon',
'FECHA : 16/05/2017',
'BD    : bdinteg'
;

CREATE PROCEDURE "informix".sp_actualiza_rep_ctas_tel_mail()
RETURNING 
CHAR(5) AS CodRet,
CHAR(50) AS Mensaje;

----------------DEFINE VARIABLES----------------------
DEFINE cCodRet        	  CHAR(5);
DEFINE iSqlErr	       	  INTEGER;
DEFINE cDesc          	  CHAR(50);
DEFINE cNumcte            CHAR(20);
DEFINE cCorreo            CHAR(100);
DEFINE cTelefono          CHAR(10);
DEFINE sCommit            SMALLINT;
DEFINE iContador          INTEGER;
DEFINE cCuenta		      CHAR(20);

----------------INICIALIZA VARIABLES------------------
LET cCodRet             ='00000';
LET iSqlErr	            = 0;
LET cDesc               ='';
LET cNumcte             ='';
LET cCorreo             ='';
LET cTelefono           ='';
LET sCommit             = 0;
LET iContador           = 0;
LET cCuenta             ='';

BEGIN

    ----------ERRORES DE INFORMIX-------------------------
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cDesc='Error no controlado';
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    FOREACH WITH HOLD
    SELECT {+INDEX ("informix".si_rep_ctas_tel_mail idx_rep_ctas_tel_mail)} cuenta
	INTO cCuenta
	FROM si_rep_ctas_tel_mail
		
        SELECT LIMIT 1 num_cte INTO cNumcte FROM bdicheq:sc_maechq WHERE cuenta = cCuenta;        
        SELECT LIMIT 1 correo_elec INTO cCorreo FROM si_correos WHERE status_correo = 'A' AND numcte = cNumcte AND secuencia = (select max(secuencia) from si_correos where  numcte = cNumcte); 
        SELECT LIMIT 1 telefono INTO cTelefono FROM si_telefonos_actual WHERE status_tel='A' AND tipo_tel=2 AND numcte = cNumcte;               

        IF (sCommit = 0) THEN
            BEGIN WORK;
            LET iContador = 0;
            LET sCommit = -1;
        END IF;			        

        UPDATE si_rep_ctas_tel_mail SET numcte = NVL(cNumcte,''), correo = NVL(cCorreo,''), celular = NVL(cTelefono,'')
        WHERE cuenta = cCuenta;

        --Ejecutar un commit cada 1000 registros.
        IF (iContador >= 5000) THEN
            COMMIT WORK;	
            LET iContador = 0;            
            BEGIN WORK;
        END IF;	

    END FOREACH;
	
	IF sCommit = -1 THEN
        COMMIT WORK;        
        END IF;
	LET sCommit = 0;

	LET cDesc = 'Proceso Correcto';
    RETURN cCodRet, cDesc;

END;
END PROCEDURE;