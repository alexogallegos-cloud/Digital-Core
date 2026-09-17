CREATE PROCEDURE "informix".sp_cnsif_saldos(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCTE CHAR(20))
							
				returning CHAR(5)     AS Cod_Retorno,
						  MONEY(14,2) AS Saldo,
						  MONEY(14,2) AS Saldo_Plazo,
						  MONEY(14,2) AS Saldo_Credito;
												
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;							

DEFINE mSaldo_vista			MONEY(14,2);
DEFINE mSaldo_plaza			MONEY(14,2);
DEFINE mSaldo_credito		MONEY(14,2);
DEFINE mSaldo_credito2		MONEY(14,2);
DEFINE mSaldo_credito3		MONEY(14,2);
DEFINE cNumero_credito		CHAR(20);
DEFINE iTpo_cliente			INT;
DEFINE cNumCtePrincipal CHAR(20);
DEFINE cNumero_cuenta 		CHAR(20);

--inicializando variables
LET  iexiste = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ;	

LET mSaldo_vista	= 0;	
LET mSaldo_plaza	= 0;
LET mSaldo_credito	= 0;
LET mSaldo_credito2 = 0;
LET mSaldo_credito3 = 0;
LET cNumero_credito	="";
LET iTpo_cliente=0;
LET cNumCtePrincipal = "";
LET cNumero_cuenta 	= "" ;


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet,mSaldo_vista,mSaldo_plaza,mSaldo_credito;
		END IF;
	END EXCEPTION;
	--  SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_saldos_2.out";
	-- TRACE ON;
	IF 	cID_USUARIOC = '' OR
		cID_FUNCIONC = '' OR
		cNUMCTE  = ''	   THEN 
		LET cCodRet = "00054";
		RETURN
		cCodRet,mSaldo_vista,mSaldo_plaza,mSaldo_credito;
	END IF;	

	EXECUTE PROCEDURE bdicnweb:"informix".sp_validacte_transfer(cNUMCTE) INTO cCodRet,iTpo_cliente,cNumCtePrincipal;
	IF cNumCtePrincipal IS NOT NULL THEN
		LET cNUMCTE = cNumCtePrincipal;
	END IF;

	FOREACH
	SELECT LIMIT 1 nvl(COUNT(numcte),0) INTO iexiste FROM si_cliente WHERE numcte = cNUMCTE
	UNION
	SELECT nvl(COUNT(numcte_tf),0) FROM bditransfer:tf_maecte WHERE numcte_tf = cNUMCTE
	ORDER BY 1 desc
	END FOREACH;

	IF iexiste = 0 THEN 
		LET cCodRet = "00055";
		RETURN cCodRet,mSaldo_vista,mSaldo_plaza,mSaldo_credito;
	END IF;	
	
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCTE,'01','2')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet,mSaldo_vista,mSaldo_plaza,mSaldo_credito;
	END IF;
	-- TERMINA VALIDACION

    SET ISOLATION TO DIRTY READ;
	SELECT nvl(SUM(ME.sdo_cap_insoluto),0) as Saldo 
	INTO mSaldo_credito
	FROM bdicred:sd_maesdos ME,
		 bdicred:sd_maecred MC
	WHERE MC.numcte =  cNUMCTE 
	AND MC.num_credito = ME.num_credito;

    SET ISOLATION TO DIRTY READ;
	SELECT nvl(SUM(ME.sdo_cap_insoluto),0) as Saldo 
	INTO mSaldo_credito2
	FROM bdicred:sd_maesdoscrd ME,
		 bdicred:sd_maecredcrd MC
	WHERE MC.numcte =  cNUMCTE 
	AND MC.num_credito = ME.num_credito;

    LET mSaldo_credito3= mSaldo_credito + mSaldo_credito2;
	
	IF iTpo_cliente = 1 THEN
		SELECT FIRST 1 cuenta_tf
		INTO cNumero_cuenta
		FROM bditransfer:tf_maecte 
		WHERE numcte_tf = cNUMCTE
		AND status_cta <> '2';
	
	ELSE 
	
		SELECT FIRST 1 cuenta_tf
		INTO cNumero_cuenta
		FROM bditransfer:tf_maecte 
		WHERE numcte = cNUMCTE
		AND status_cta <> '2';
	
	END IF;

	/* 
		SELECT FIRST 1 cuenta_tf
		INTO cNumero_cuenta
		FROM bditransfer:tf_maecte 
		WHERE CASE WHEN iTpo_cliente = 1 THEN numcte_tf ELSE numcte END = cNUMCTE
		AND status_cta <> '2'; 

	*/
	
	
	
    SET ISOLATION TO DIRTY READ;
	FOREACH
	SELECT SUM(SALDO) 
	INTO mSaldo_vista  
	--RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DHG 
	FROM (SELECT nvl(SUM(sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc + saldo_sbc)),0) AS SALDO
	FROM bdicheq:sc_maechq 
	WHERE num_cte = cNUMCTE
	UNION ALL
	SELECT SUM(sdo_cta) AS SALDO
	FROM bditransfer:tf_account_balance_customer
	WHERE cuenta = cNumero_cuenta
	AND fecha_proceso = (SELECT MAX(fecha_proceso) FROM bditransfer:tf_account_balance_customer WHERE cuenta = cNumero_cuenta))
	END FOREACH;
	
    SET ISOLATION TO DIRTY READ;
	SELECT nvl(SUM(capital),0) 
	INTO  mSaldo_plaza
	FROM  bdinvers:sv_maeinv 
	WHERE num_cte = cNUMCTE AND status_cta='1';

	RETURN
	cCodRet,mSaldo_vista,mSaldo_plaza,mSaldo_credito3;	
END
END PROCEDURE
DOCUMENT
"AutOR : Antonio Flores",
"FUNCIONAMIENTO:Este sp realizara el caluclo de los saldos generales por numero de cliente el saldo de credito, captacion e inversiones ",
"FECHA : 04-01-2012",
"BD    : bdinteg",
"VER   : 1.0",
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 10-06-2025',
'MODIFICACION: Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.2';

CREATE PROCEDURE "informix".sp_cnsif_consprodctekiosko(cID_USUARIOC char(10),cNUMCTE CHAR(20),iTpo_cliente INTEGER)
				returning 
				CHAR(5)     AS Cod_Retorno;


DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE cIProducto_chequera	CHAR(1);
DEFINE cScuenta				CHAR(2);
DEFINE cNo_cuenta			CHAR(20);
DEFINE cNo_tarjeta			CHAR(20);
DEFINE cClave_producto		CHAR(4);
DEFINE cNombre_producto		CHAR(40);
DEFINE cCuenta_clabe		CHAR(18);
DEFINE dFecha_apertura		DATE;
DEFINE cStatus_tarjeta		CHAR(15);
DEFINE cStatus_cuenta		CHAR(60);
DEFINE dFecha_status		DATE;
DEFINE cClave_sucursal		CHAR(4);
DEFINE cEjecutivo 			CHAR(8);
DEFINE mSaldo_actual		MONEY(14,2);
DEFINE dFecha_aperturaO_inv DATE;
DEFINE dFecha_max			DATE;
DEFINE dFecha_min			DATE;
DEFINE cNumero_cuenta 		CHAR(20);
DEFINE dFecha 				DATE;
DEFINE iCont                INTEGER;
DEFINE iMaxSec              INTEGER;
DEFINE cCtaInv              CHAR(20);
DEFINE cDiaCorte            SMALLINT;
DEFINE dFecha_cancelacion	DATE;
--DEFINE iTpo_cliente			INT;
DEFINE cNumCtePrincipal 	CHAR(20);
DEFINE cNumCteTf			CHAR(20);
DEFINE cStatus				CHAR(50);
DEFINE cProdDebito			CHAR(200);
DEFINE cProdCredito			CHAR(200);
DEFINE cQuery CHAR(1500);


--inicializando variables
LET  iexiste = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ;
--SISTEMA DE CUENTA 01 VARIABLES
LET cIProducto_chequera	 = "";
LET cScuenta		 = "";
LET cNo_cuenta		 = "";
LET cNo_tarjeta			 = "";
LET cClave_producto		 = "";
LET cNombre_producto		 = "";
LET cCuenta_clabe		 = "";
LET dFecha_apertura		 = "";
LET cStatus_tarjeta		 = "";
LET cStatus_cuenta		 = "";
LET dFecha_status		 = "";
LET cClave_sucursal		 = "";
LET cEjecutivo 			 = "";
LET mSaldo_actual		= 0;
LET dFecha_aperturaO_inv = "";
LET dFecha_max			="";
LET dFecha_min			="";
LET cNumero_cuenta 	= "" ;
LET iCont=0;
LET iMaxSec=0;
LET cCtaInv='';
LET cDiaCorte           =0;
LET dFecha_cancelacion = "";
--LET iTpo_cliente=0;
LET cNumCteTf = "";
LET cNumCtePrincipal = "";
LET cStatus = "";
LET cProdDebito = "";
LET cProdCredito = "";
LET cQuery = '';

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
   --SET DEBUG FILE TO "/home/c90402536/Traza/sp_cnsif_consprodctekiosko_modif.out";
   --TRACE ON; 
    
	
	SET ISOLATION TO DIRTY READ;
	
	SELECT valor
	INTO cStatus
	FROM si_param
	WHERE cod_param = 338;
	
	SELECT valor
	INTO cProdDebito
	FROM si_param
	WHERE cod_param = 339;
	
	SELECT valor
	INTO cProdCredito
	FROM si_param
	WHERE cod_param = 340;
	
	select first 1 NVL(COUNT(cuenta),0)  into iexiste FROM bdicheq:sc_maechq WHERE num_cte = cNUMCTE;
	IF iexiste = 0 THEN 
		FOREACH
			SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS cant  INTO iexiste FROM bdicred:"informix".sd_maecred WHERE numcte = cNUMCTE
			UNION
			SELECT NVL(COUNT(num_credito),0) AS cant FROM bdicred:"informix".sd_maecredcrd WHERE numcte = cNUMCTE ORDER BY CANT DESC
		END FOREACH;
		IF iexiste = 0 THEN 
			LET cCodRet = "00024";
			RETURN cCodRet;
		END IF;
	END IF;	

	LET cQuery = "SELECT cuenta FROM bdicheq:sc_maechq WHERE num_cte = '"||TRIM(cNUMCTE)||"' AND status_cta NOT IN ("||TRIM(cStatus)||")";
	LET cQuery = TRIM(cQuery)||" AND producto IN ("||TRIM(cProdDebito)||") ORDER BY cuenta";
	
	DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} from "informix".si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
	SET ISOLATION TO DIRTY READ;
	PREPARE stmtId FROM TRIM(cQuery);
	DECLARE custCur CURSOR FOR stmtId;
	OPEN custCur;
	FETCH custCur INTO cNumero_cuenta;
	WHILE(SQLCODE == 0)
		--RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DFTL 
		SELECT DECODE(MC.producto,"2200","S","1900","S","N"),'01',cNumero_cuenta, MC.producto,PR.nombre, MC.cuenta_clabe,UPPER(ES.descripcion),
		MC.fec_cancelac, MC.sucursal,MC.sdo_actual - (MC.sdo_retenido + MC.sdo_cong + MC.imp_sbg_ccc + MC.saldo_sbc)AS SALDO 
		INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,cCuenta_clabe,cStatus_cuenta, dFecha_status,cClave_sucursal,
		mSaldo_actual
		FROM bdicheq:"informix".sc_maechq MC,
		bdicheq:"informix".sc_producto PR,
		bdicheq:"informix".sc_mae_estatus ES
		WHERE MC.cuenta = cNumero_cuenta 
		AND	PR.producto = MC.producto
		AND MC.status_cta = ES.cod_estatus;

		SELECT fecha_alta, ejecutivo
		INTO dFecha_apertura,cEjecutivo
		FROM bdicheq:"informix".sc_maenoc
		WHERE cuenta =cNumero_cuenta;
			
		SELECT num_tarjeta
		INTO cNo_tarjeta
		FROM  bdicheq:"informix".sc_tarjeta
		WHERE cuenta = cNumero_cuenta
		AND numcte = cNUMCTE
		AND tipo_tarjeta='T' AND secuencia IN (SELECT max(secuencia) FROM  bdicheq:"informix".sc_tarjeta
		WHERE cuenta = cNumero_cuenta
		AND numcte = cNUMCTE
		AND tipo_tarjeta='T');

		SELECT LIMIT 1 {+INDEX (intercard:tarjeta idx_numcte)} NVL(UPPER(B.descstatustarjeta),"") INTO cStatus_tarjeta FROM intercard:tarjeta A
		LEFT JOIN intercard:statustarjeta B
		ON A.codstatustarjeta = B.codstatustarjeta
		WHERE A.numcliente= cNUMCTE
		AND A.numtarjeta= cNo_tarjeta;

		IF cClave_producto='1100' THEN
			SELECT fec_ult_mov INTO dFecha_status FROM bdicheq:"informix".sc_maechq WHERE cuenta = cNumero_cuenta AND empresa='001' and status_cta='2';
		END IF;

		LET cDiaCorte=SUBSTR(dFecha_apertura,4,2); 
		
		INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
		fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,dia_corte) 
		values (cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
		cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC,cDiaCorte);
		
		FETCH custCur INTO cNumero_cuenta;
	END WHILE;
	CLOSE custCur;
	FREE custCur;
	FREE stmtId;

	LET cQuery = "SELECT num_credito FROM bdicred:sd_maecred WHERE numcte = '"||TRIM(cNUMCTE)||"' AND num_producto IN ("||TRIM(cProdCredito)||")";
	LET cQuery = TRIM(cQuery)||" UNION SELECT num_credito FROM bdicred:sd_maecredcrd WHERE numcte = '"||TRIM(cNUMCTE)||"' AND";
	LET cQuery = TRIM(cQuery)||" num_producto IN ("||TRIM(cProdCredito)||") order by num_credito";
	
	SET ISOLATION TO DIRTY READ;
	PREPARE stmtId FROM TRIM(cQuery);
	DECLARE custCur CURSOR FOR stmtId;
	OPEN custCur;
	FETCH custCur INTO cNumero_cuenta;
	WHILE(SQLCODE == 0)
		SET ISOLATION TO DIRTY READ;
		SELECT MAX(fecha) INTO dFecha FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cNumero_cuenta;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH
		SELECT 'N','06',MC.num_credito, MC.num_producto,DE.nombre_prod,MC.fecha_apertura,
		TC.descripcion,	MC.sucursal,MC.ejecutivo, dFecha
		INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,
		cStatus_cuenta,cClave_sucursal,cEjecutivo,dFecha_status
		FROM bdicred:"informix".sd_maecred MC,
		bdicred:"informix".sd_tipocartera TC,
		bdicred:"informix".sd_definicion DE
		WHERE MC. num_credito  = cNumero_cuenta 
		AND	DE.num_producto = MC.num_producto
		AND MC.status_cred = TC.status_cred
		UNION
		SELECT 'N','06',MC.num_credito, MC.num_producto,DE.nombre_prod,MC.fecha_apertura,
		TC.descripcion,	MC.sucursal,MC.ejecutivo, dFecha
		FROM bdicred:"informix".sd_maecredcrd MC,
		bdicred:"informix".sd_tipocartera TC,
		bdicred:"informix".sd_definicion DE
		WHERE MC. num_credito  = cNumero_cuenta 
		AND	DE.num_producto = MC.num_producto
		AND MC.status_cred = TC.status_cred
		END FOREACH;

		SET ISOLATION TO DIRTY READ;
		FOREACH
		SELECT sdo_cap_insoluto as Saldo
		INTO mSaldo_actual
		FROM bdicred:"informix".sd_maesdos
		WHERE num_credito =cNumero_cuenta
		UNION
		SELECT sdo_cap_insoluto AS Saldo
		FROM bdicred:"informix".sd_maesdoscrd
		WHERE num_credito =cNumero_cuenta
		END FOREACH;
		
		SET ISOLATION TO DIRTY READ;
		SELECT num_tarjeta
		INTO cNo_tarjeta
		FROM bdicred:"informix".sd_tarjeta 
		WHERE num_credito = cNumero_cuenta
		AND tipo_tarjeta='T' AND SECUENCIA IN (SELECT max(secuencia) FROM bdicred:"informix".sd_tarjeta
		WHERE num_credito = cNumero_cuenta
		AND numcte = cNUMCTE
		AND tipo_tarjeta='T');

		SELECT LIMIT 1 {+INDEX (intercard:tarjeta idx_numcte)} NVL(UPPER(B.descstatustarjeta),"") INTO cStatus_tarjeta FROM intercard:tarjeta A
		LEFT JOIN intercard:statustarjeta B
		ON A.codstatustarjeta = B.codstatustarjeta
		WHERE A.numcliente= cNUMCTE
		AND A.numtarjeta= cNo_tarjeta;

		IF cClave_producto IN ('6001','6600','7000') THEN
			SELECT dia_cuota
			INTO cDiaCorte
			FROM bdicred:sd_definicion
			WHERE num_producto = cClave_producto; 
		ELIF cClave_producto='6300' THEN    
			LET cDiaCorte=SUBSTR(dFecha_apertura,4,2); 
		ELIF cClave_producto='6400' THEN    
			LET cDiaCorte='20'; 
		ELIF cClave_producto='6011' THEN    
			LET cDiaCorte=SUBSTR(dFecha_apertura,4,2); 
			IF cDiaCorte>=3 AND cDiaCorte<17 THEN
				LET cDiaCorte=2;
			ELIF cDiaCorte IN (1,2) OR cDiaCorte>=17 THEN
				LET cDiaCorte=17;
			ELSE
				LET cDiaCorte=0;
			END IF;
		END IF;

		INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
		fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,dia_corte) 
		values (cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
		cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC,cDiaCorte);

		FETCH custCur INTO cNumero_cuenta;

	END WHILE;
	CLOSE custCur;
	FREE custCur;
	FREE stmtId;
	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
"AUTOR : Cesar Velazquez",
"FUNCIONAMIENTO:Este sp realizara la busqueda de cuentas que se presentaran en KIOSKO",
"FECHA : 06-04-2015",
"BD    : bdinteg",
"VER   : 1.0",
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/01',
'RAZON:                 Se agrega la nueva variable saldo_sbc (inmovilizacion por concepto de credito)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdinteg',
'VER:                   1.2';

CREATE PROCEDURE "informix".sp_cnsif_consprodcte_aclaraciones(cID_USUARIOC char(10),cID_FUNCIONC CHAR(10),cNUMCTE CHAR(20),cSISTEMACUENTA CHAR(2),pNumRegistro INTEGER,pRecuperacion INTEGER)
				returning 
				CHAR(5)     AS Cod_Retorno,
				CHAR(1)     AS Producto,
				CHAR(2)     AS Sistema_Cuenta,
				CHAR(20)    AS Numero_Cuenta,
				CHAR(4)     AS Cve_Producto,
				CHAR(40)    AS Nombre_Producto,
				DATE        AS Fecha_Apertura,
				CHAR(60)    AS Status_Cuenta,
				DATE        AS Fecha_Status,
				CHAR(4)     AS Clave_Sucursal,
				CHAR(8)     AS Ejecutivo,
				MONEY(14,2) AS Saldo_Actual,
                CHAR(20)    AS Numero_Tarjeta,
				CHAR(15)    AS Status_Tarjeta,
				CHAR(18)    AS Cuenta_CLABE,
				DATE        AS Fecha_Apertura_Inversion,
				DATE		AS Fecha_Cancelacion,
				CHAR(2)     AS Cod_Status_Cta;


DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE cIProducto_chequera	CHAR(1);
DEFINE cScuenta				CHAR(2);
DEFINE cNo_cuenta			CHAR(20);
DEFINE cNo_tarjeta			CHAR(20);
DEFINE cClave_producto		CHAR(4);
DEFINE cNombre_producto		CHAR(40);
DEFINE cCuenta_clabe		CHAR(18);
DEFINE dFecha_apertura		DATE;
DEFINE cStatus_tarjeta		CHAR(15);
DEFINE cStatus_cuenta		CHAR(60);
DEFINE dFecha_status		DATE;
DEFINE cClave_sucursal		CHAR(4);
DEFINE cEjecutivo 			CHAR(8);
DEFINE mSaldo_actual		MONEY(14,2);
DEFINE dFecha_aperturaO_inv DATE;
DEFINE dFechaCancelacion	DATE;
DEFINE dFecha_max			DATE;
DEFINE dFecha_min			DATE;
DEFINE cNumero_cuenta 		CHAR(20);
DEFINE dFecha 				DATE;
DEFINE iCont                INTEGER;
DEFINE iMaxSec              INTEGER;
DEFINE cCtaInv              CHAR(20);
DEFINE iTpo_cliente			INT;
DEFINE cNumCtePrincipal CHAR(20);
DEFINE cNumCteTf			CHAR(20);
DEFINE cIdStatusCuenta      CHAR(2);

--inicializando variables
LET  iexiste = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ;
--SISTEMA DE CUENTA 01 VARIABLES
LET cIProducto_chequera	 = "";
LET cScuenta		 = "";
LET cNo_cuenta		 = "";
LET cNo_tarjeta			 = "";
LET cClave_producto		 = "";
LET cNombre_producto		 = "";
LET cCuenta_clabe		 = "";
LET dFecha_apertura		 = "";
LET dFechaCancelacion	 = "";
LET cStatus_tarjeta		 = "";
LET cStatus_cuenta		 = "";
LET dFecha_status		 = "";
LET cClave_sucursal		 = "";
LET cEjecutivo 			 = "";
LET mSaldo_actual		= 0;
LET dFecha_aperturaO_inv = "";
LET dFecha_max			="";
LET dFecha_min			="";
LET cNumero_cuenta 	= "" ;
LET iCont=0;
LET iMaxSec=0;
LET cCtaInv='';
LET iTpo_cliente=0;
LET cNumCtePrincipal = "";
LET cNumCteTf="";
LET cIdStatusCuenta = "";


    BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN
			cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cNo_tarjeta,cClave_producto,cNombre_producto,cCuenta_clabe,dFecha_apertura,
			cStatus_tarjeta,cStatus_cuenta,dFecha_status,cClave_sucursal,cEjecutivo,mSaldo_actual,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
		END IF;
	END EXCEPTION;
            --SET DEBUG FILE TO "/home/c90402536/Traza/sp_cnsif_consprodcte_aclaraciones_modif.out";
            --TRACE ON; 
	IF 	cID_USUARIOC = '' OR
		cID_FUNCIONC = '' OR
		cNUMCTE  = ''	  OR
		cSISTEMACUENTA = '' THEN
		LET cCodRet = "00036";
		RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
        cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;

	END IF;
	IF cSISTEMACUENTA <> '01' AND cSISTEMACUENTA <> '06'  AND cSISTEMACUENTA <> '03' AND cSISTEMACUENTA <> '00'  THEN
		LET cCodRet = "00037";
		RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
        cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
	END IF;

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
		RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
        cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;				
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
        END IF;
    END IF;    	
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCTE,cSISTEMACUENTA,'2')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
		RETURN 
		cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cNo_tarjeta,cClave_producto,cNombre_producto,cCuenta_clabe,dFecha_apertura,
		cStatus_tarjeta,cStatus_cuenta,dFecha_status,cClave_sucursal,cEjecutivo,mSaldo_actual,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
	END IF;
	-- TERMINA VALIDACION	
	
--TRANSFER
	EXECUTE PROCEDURE bdicnweb:"informix".sp_validacte_transfer(cNUMCTE) INTO cCodRet,iTpo_cliente,cNumCtePrincipal;
	IF cNumCtePrincipal IS NOT NULL THEN
		LET cNUMCTE = cNumCtePrincipal;
	END IF;
--TRANSFER	

	IF cSISTEMACUENTA = '01' THEN
--TRANSFER
		FOREACH
		select FIRST 1 NVL(COUNT(cuenta),0)  INTO iexiste FROM bdicheq:"informix".sc_maechq WHERE num_cte = cNUMCTE
		UNION
		select NVL(COUNT(cuenta_tf),0) FROM bditransfer:"informix".tf_maecte WHERE CASE WHEN iTpo_cliente = 1 THEN numcte_tf ELSE numcte END = cNUMCTE
		order by 1 desc
		END FOREACH;
--TRANSFER
		IF iexiste = 0 THEN 
			LET cCodRet = "00024";
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
		END IF;	

		SET ISOLATION TO DIRTY READ;
		FOREACH
            SELECT SKIP pNumRegistro FIRST pRecuperacion a.cuenta,b.num_tarjeta,DECODE(b.status_tar,"A","ACTIVA","C","CANCELADA","")
            INTO cNumero_cuenta,cNo_tarjeta,cStatus_tarjeta
            FROM bdicheq:"informix".sc_maechq a
            LEFT JOIN bdicheq:"informix".sc_tarjeta b
            ON b.cuenta= a.cuenta
            WHERE a.num_cte = cNUMCTE ORDER BY a.cuenta
--TRANSFER
			FOREACH
			--RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DFTL 
			SELECT DECODE(MC.producto,"2200","S","1900","S","N"),cSISTEMACUENTA,cNumero_cuenta, MC.producto,PR.nombre,
			MC.cuenta_clabe,DECODE(MC.status_cta,"1","ACTIVA","2","CANCELADA","3","BLOQUEADA","4","INACTIVA","5","INFORMADA","6","CONCENTRADA","7","BENEFICIENCIA","8","DESCONCENTRADA"),
			MC.fec_cancelac, MC.sucursal,MC.sdo_actual - (MC.sdo_retenido + MC.sdo_cong + MC.imp_sbg_ccc + MC.saldo_sbc)AS SALDO,MC.status_cta
			INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,cCuenta_clabe,cStatus_cuenta,
			dFecha_status,cClave_sucursal,mSaldo_actual,cIdStatusCuenta
			FROM bdicheq:"informix".sc_maechq MC,
			bdicheq:"informix".sc_producto PR
			WHERE MC.cuenta = cNumero_cuenta AND
			PR.producto = MC.producto
			UNION
			SELECT "N","01",cNumero_cuenta, MC.producto,PR.nombre,
			MC.cta_clabe,DECODE(MC.status_cta,"1","ACTIVA","2","CANCELADA","3","BLOQUEADA","4","INACTIVA","5","INFORMADA","6","CONCENTRADA","7","BENEFICIENCIA","8","DESCONCENTRADA"),
			MC.fec_cancelac, '',SDO.sdo_cta AS SALDO,MC.status_cta
			FROM bditransfer:"informix".tf_maecte MC,
			bdicheq:"informix".sc_producto PR, bditransfer:tf_account_balance_customer SDO
			WHERE MC.cuenta_tf = cNumero_cuenta AND
			PR.producto = MC.producto AND
			MC.cuenta_tf = SDO.cuenta
			END FOREACH;
--TRANSFER			
--TRANSFER
			FOREACH
			SELECT fecha_alta, ejecutivo
			INTO dFecha_apertura,cEjecutivo
			FROM bdicheq:"informix".sc_maenoc
			WHERE cuenta =cNumero_cuenta
			UNION
			SELECT fec_alta, ''
			FROM bditransfer:"informix".tf_maecte
			WHERE cuenta_tf =cNumero_cuenta
			END FOREACH;
--TRANSFER
--TRANSFER
			SELECT numcte_tf, fec_cancelac
			INTO cNumCteTf, dFechaCancelacion
			FROM bditransfer:"informix".tf_maecte
			WHERE cuenta_tf = cNumero_cuenta;
			
			IF cNumCteTf IS NOT NULL THEN
				LET cNUMCTE = cNumCteTf;
			END IF;
--TRANSFER			
/*
			SELECT num_tarjeta,DECODE(status_tar,"A","ACTIVA","C","CANCELADA","DESCONOCIDO")
			INTO cNo_tarjeta,cStatus_tarjeta
			FROM  bdicheq:sc_tarjeta
			WHERE cuenta = cNumero_cuenta
			AND numcte = cNUMCTE
			AND status_tar = 'A' AND tipo_tarjeta='T'; */
			
			LET iCont=iCont+1;	
			
			-- FECHA DE CANCELACION
			IF cNumCteTf IS NULL THEN
				EXECUTE PROCEDURE sp_consultafechacancelacioncta(cNo_cuenta, cScuenta) INTO cCodRet, dFechaCancelacion;
			END IF;
			
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta WITH resume;
		END FOREACH;
        IF iCont = 0 THEN
            DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} FROM "informix".si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
            LET cCodRet = '1001'; 
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
        END IF 
	ELIF cSISTEMACUENTA = '03' THEN
		SELECT NVL(COUNT(cuenta),0)  INTO iexiste FROM bdinvers:"informix".sv_maeinv WHERE num_cte = cNUMCTE;
		
		IF iexiste = 0 THEN 
			LET cCodRet = "00024";
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
		END IF;	

		SET ISOLATION TO DIRTY READ;
		FOREACH
            SELECT SKIP pNumRegistro FIRST pRecuperacion DISTINCT cuenta INTO cCtaInv FROM bdinvers:"informix".sv_maeinv
            WHERE num_cte=cNUMCTE ORDER BY cuenta

			SELECT NVL(MAX(secuencia),0) INTO iMaxSec FROM bdinvers:"informix".sv_maeinv WHERE CUENTA=cCtaInv;

			SELECT {+INDEX (bdinvers:sv_instrum idx_instrum)} 'N',cSISTEMACUENTA,MI.cuenta,MI.cod_instrum,IT.nombre,MI.fecha_alta,
			DECODE(MI.status_cta,"1","ACTIVA","2","CANCELADA","4","REINVERSION"),
            MI.adicionado,DECODE(MI.status_cta,"2",0,MI.capital),MI.sucursal,MI.fec_cancelac,MI.status_cta
			--MI.adicionado,MI.capital,MI.sucursal,MI.fec_cancelac
			INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,cEjecutivo,
			mSaldo_actual,cClave_sucursal,dFecha_status,cIdStatusCuenta
			FROM bdinvers:"informix".sv_maeinv MI,
			bdinvers:"informix".sv_instrum IT
			WHERE MI.num_cte = cNUMCTE  AND IT.cod_instrum  = MI.cod_instrum
            AND MI.cuenta=cCtaInv
            and secuencia = iMaxSec;

            SELECT MIN(fecha_alta) INTO dFecha_aperturaO_inv FROM bdinvers:"informix".sv_maeinv WHERE num_cte = cNUMCTE and cuenta=cNo_cuenta;

            LET iCont=iCont+1;
			
			-- FECHA DE CANCELACION
			EXECUTE PROCEDURE "informix".sp_consultafechacancelacioncta(cNo_cuenta, cScuenta) INTO cCodRet, dFechaCancelacion;
			
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta WITH resume;
		END FOREACH;
        IF iCont = 0 THEN
            DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} from "informix".si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
			
            LET cCodRet = '1001'; 
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
        END IF 	
	ELIF cSISTEMACUENTA = '06' THEN
    IF pNumRegistro=0 THEN
        DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} FROM si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH
            SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS cant  INTO iexiste FROM bdicred:"informix".sd_maecred WHERE numcte = cNUMCTE
            UNION
            SELECT NVL(COUNT(num_credito),0) as cant FROM bdicred:"informix".sd_maecredcrd WHERE numcte = cNUMCTE ORDER BY CANT DESC
        END FOREACH;
		IF iexiste = 0 THEN 
			LET cCodRet = "00024";
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
		END IF;	

		SET ISOLATION TO DIRTY READ;
		FOREACH

            SELECT a.num_credito,b.num_tarjeta,DECODE(b.status_tar,"A","ACTIVA","C","CANCELADA","")
            INTO cNumero_cuenta,cNo_tarjeta,cStatus_tarjeta
            FROM bdicred:"informix".sd_maecred a
            LEFT JOIN bdicred:"informix".sd_tarjeta b
            ON b.num_credito= a.num_credito
            WHERE a.numcte = cNUMCTE ORDER BY a.num_credito

			/*SELECT num_credito into cNumero_cuenta
			FROM bdicred:sd_maecred
			WHERE numcte = cNUMCTE order by num_credito*/

			SELECT  MAX(fecha) INTO dFecha FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cNumero_cuenta;
			
			SELECT 'N',cSISTEMACUENTA,MC.num_credito, MC.num_producto,DE.nombre_prod,MC.fecha_apertura,
			TC.descripcion,	MC.sucursal,MC.ejecutivo, dFecha, TC.status_cred
			INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,
			cStatus_cuenta,cClave_sucursal,cEjecutivo,dFecha_status,cIdStatusCuenta
			FROM bdicred:"informix".sd_maecred MC,
			bdicred:"informix".sd_tipocartera TC,
			bdicred:"informix".sd_definicion DE
			WHERE MC. num_credito  = cNumero_cuenta 
			AND	DE.num_producto = MC.num_producto
			AND MC.status_cred = TC.status_cred;

			SELECT sdo_cap_insoluto + sdo_exig_int + sdo_no_exig + sdo_moratorio as Saldo
			INTO mSaldo_actual
			FROM bdicred:"informix".sd_maesdos
			WHERE num_credito =cNumero_cuenta;

			/*SELECT num_tarjeta,DECODE(status_tar,"A","ACTIVA","C","CANCELADA","DESCONOCIDO")
			INTO cNo_tarjeta,cStatus_tarjeta
			FROM bdicred:sd_tarjeta TA
			WHERE TA.num_credito = cNumero_cuenta
			AND TA.status_tar ='A' AND tipo_tarjeta='T';*/

            INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
            fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,cod_statuscta) 
			values (cCodRet,cIProducto_chequera,
            cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC,cIdStatusCuenta);
		END FOREACH;

		SET ISOLATION TO DIRTY READ;
		FOREACH
			/*SELECT num_credito into cNumero_cuenta
			FROM bdicred:sd_maecredcrd
			WHERE numcte = cNUMCTE order by num_credito*/

            SELECT a.num_credito,b.num_tarjeta,DECODE(b.status_tar,"A","ACTIVA","C","CANCELADA","")
            INTO cNumero_cuenta,cNo_tarjeta,cStatus_tarjeta
            FROM bdicred:"informix".sd_maecredcrd a
            LEFT JOIN bdicred:"informix".sd_tarjeta b
            ON b.num_credito= a.num_credito
            WHERE a.numcte = cNUMCTE ORDER BY a.num_credito

			SELECT  MAX(fecha) INTO dFecha FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cNumero_cuenta;
					
			SELECT 'N',cSISTEMACUENTA,MC.num_credito, MC.num_producto,DE.nombre_prod,MC.fecha_apertura,
			TC.descripcion,	MC.sucursal,MC.ejecutivo, dFecha,TC.status_cred
			INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,
			cStatus_cuenta,cClave_sucursal,cEjecutivo,dFecha_status,cIdStatusCuenta
			FROM bdicred:"informix".sd_maecredcrd MC,
			bdicred:"informix".sd_tipocartera TC,
			bdicred:"informix".sd_definicion DE
			WHERE MC. num_credito  = cNumero_cuenta 
			AND	DE.num_producto = MC.num_producto
			AND MC.status_cred = TC.status_cred;

			SELECT sdo_cap_insoluto + sdo_exig_int + sdo_no_exig + sdo_moratorio as Saldo
			INTO mSaldo_actual
			FROM bdicred:"informix".sd_maesdoscrd
			WHERE num_credito =cNumero_cuenta;

			/*SELECT num_tarjeta,DECODE(status_tar,"A","ACTIVA","C","CANCELADA","DESCONOCIDO")
			INTO cNo_tarjeta,cStatus_tarjeta
			FROM bdicred:sd_tarjeta TA
			WHERE TA.num_credito = cNumero_cuenta
			AND TA.status_tar ='A' AND tipo_tarjeta='T';*/

            INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
            fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,cod_statuscta) values (cCodRet,cIProducto_chequera,
            cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC,cIdStatusCuenta);
		END FOREACH;
      END IF;  
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} SKIP pNumRegistro FIRST pRecuperacion codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,nvl(status_cuenta,''),
                        fecha_status,clave_sucursal,ejecutivo,saldo_actual,nvl(no_tarjeta,''),nvl(status_tarjeta,''),cuenta_clabe,fecha_apertura_inv,cod_statuscta 
						into cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
                        cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cIdStatusCuenta
            FROM "informix".si_tempoctas
            WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC ORDER BY scuenta,no_cuenta 
            
            LET iCont=iCont+1;
			
			-- FECHA DE CANCELACION
			EXECUTE PROCEDURE "informix".sp_consultafechacancelacioncta(cNo_cuenta, cScuenta) INTO cCodRet, dFechaCancelacion;

            RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta WITH resume;
        END FOREACH;
        IF iCont = 0 THEN
            DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} from "informix".si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
			
            LET cCodRet = '1001'; 
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
        END IF 	
	ELIF cSISTEMACUENTA = '00' THEN
--TRANSFER
		FOREACH
		select FIRST 1 NVL(COUNT(cuenta),0)  into iexiste FROM bdicheq:"informix".sc_maechq WHERE num_cte = cNUMCTE
		UNION
		select NVL(COUNT(cuenta_tf),0)  FROM bditransfer:"informix".tf_maecte WHERE CASE WHEN iTpo_cliente = 1 THEN numcte_tf ELSE numcte END = cNUMCTE
		ORDER BY 1 DESC
		END FOREACH;
--TRANSFER		
		
		IF iexiste = 0 THEN 
			SET ISOLATION TO DIRTY READ;
            FOREACH
                SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS cant  INTO iexiste FROM bdicred:"informix".sd_maecred WHERE numcte = cNUMCTE
                UNION
                SELECT NVL(COUNT(num_credito),0) AS cant FROM bdicred:"informix".sd_maecredcrd WHERE numcte = cNUMCTE ORDER BY CANT DESC
            END FOREACH;
            IF iexiste = 0 THEN 
                SELECT nvl(COUNT(cuenta),0)  INTO iexiste FROM bdinvers:"informix".sv_maeinv WHERE num_cte = cNUMCTE;
				
                IF iexiste = 0 THEN 
                    LET cCodRet = "00024";
                    RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
                    cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
                END IF;
            END IF;
		END IF;	
    
        IF pNumRegistro=0 THEN
                DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} from "informix".si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
				
                SET ISOLATION TO DIRTY READ;
                FOREACH

                    SELECT a.cuenta,b.num_tarjeta,DECODE(b.status_tar,"A","ACTIVA","C","CANCELADA","")
                    INTO cNumero_cuenta,cNo_tarjeta,cStatus_tarjeta
                    FROM bdicheq:"informix".sc_maechq a
                    LEFT JOIN bdicheq:"informix".sc_tarjeta b
                    ON b.cuenta= a.cuenta
                    WHERE a.num_cte = cNUMCTE 
				    UNION
	                SELECT a.cuenta_tf,b.num_tarjeta,DECODE(b.status_tar,"A","ACTIVA","C","CANCELADA","")
                    FROM bditransfer:"informix".tf_maecte a
                    LEFT JOIN bdicheq:"informix".sc_tarjeta b
                    ON b.cuenta = a.cuenta_tf
                    WHERE CASE WHEN iTpo_cliente = 1 THEN a.numcte_tf ELSE a.numcte END = cNUMCTE
					ORDER BY 1

--TRANSFER
                   /* SELECT cuenta into cNumero_cuenta
                    FROM bdicheq:sc_maechq
                    WHERE num_cte = cNUMCTE order by cuenta*/
                    FOREACH
			        --RQM 09 704. Se agrega el campo saldo_sbc al calculo del saldo disponible. DFTL 

                    SELECT DECODE(MC.producto,"2200","S","1900","S","N"),'01',cNumero_cuenta, MC.producto,PR.nombre,
                    MC.cuenta_clabe,DECODE(MC.status_cta,"1","ACTIVA","2","CANCELADA","3","BLOQUEADA","4","CONGELADA","5","INFORMADA","6","CONCENTRADA","7","BENEFICIENCIA","8","DESCONCENTRADA"),
			        MC.fec_cancelac, MC.sucursal,MC.sdo_actual - (MC.sdo_retenido + MC.sdo_cong + MC.imp_sbg_ccc + MC.saldo_sbc)AS SALDO,MC.status_cta
			        INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,cCuenta_clabe,cStatus_cuenta,
			        dFecha_status,cClave_sucursal,mSaldo_actual,cIdStatusCuenta
                    FROM bdicheq:"informix".sc_maechq MC,
                    bdicheq:"informix".sc_producto PR
                    WHERE MC.cuenta = cNumero_cuenta AND
                    PR.producto = MC.producto
					UNION
					SELECT "N","01",cNumero_cuenta, MC.producto,PR.nombre,
					MC.cta_clabe,DECODE(MC.status_cta,"1","ACTIVA","2","CANCELADA","3","BLOQUEADA","4","INACTIVA","5","INFORMADA","6","CONCENTRADA","7","BENEFICIENCIA","8","DESCONCENTRADA"),
					MC.fec_cancelac, '',SDO.sdo_cta AS SALDO,MC.status_cta
					FROM bditransfer:"informix".tf_maecte MC,
					bdicheq:"informix".sc_producto PR, bditransfer:tf_account_balance_customer SDO
					WHERE MC.cuenta_tf = cNumero_cuenta AND
					PR.producto = MC.producto AND
					MC.cuenta_tf = SDO.cuenta
					END FOREACH;

					FOREACH
                    SELECT fecha_alta, ejecutivo
                    INTO dFecha_apertura,cEjecutivo
                    FROM bdicheq:"informix".sc_maenoc
					WHERE cuenta =cNumero_cuenta
					UNION
					SELECT fec_alta, ''
					FROM bditransfer:"informix".tf_maecte
					WHERE cuenta_tf =cNumero_cuenta
					END FOREACH;
--TRANSFER

                    /*SELECT num_tarjeta,DECODE(status_tar,"A","ACTIVA","C","CANCELADA","DESCONOCIDO")
                    INTO cNo_tarjeta,cStatus_tarjeta
                    FROM  bdicheq:sc_tarjeta
                    WHERE cuenta = cNumero_cuenta
                    AND numcte = cNUMCTE
                    AND status_tar = 'A' AND tipo_tarjeta='T';*/

                    INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
                    fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,cod_statuscta) values (cCodRet,cIProducto_chequera,
                    cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
                    cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC, cIdStatusCuenta);
                END FOREACH;

                SET ISOLATION TO DIRTY READ;
                FOREACH

                    SELECT {+INDEX (bdinvers:sv_instrum idx_instrum)} 'N','03',MI.cuenta,MI.cod_instrum,IT.nombre,MI.fecha_alta,
                    DECODE(MI.status_cta,"1","ACTIVA","2","CANCELADA","4","REINVERSION"),
                    MI.adicionado,DECODE(MI.status_cta,"2",0,MI.capital),MI.sucursal,MI.fec_cancelac,MI.status_cta
                    --MI.adicionado,MI.capital,MI.sucursal,MI.fec_cancelac
                    INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,cEjecutivo,
                    mSaldo_actual,cClave_sucursal,dFecha_status,cIdStatusCuenta
                    FROM bdinvers:"informix".sv_maeinv MI,
                    bdinvers:"informix".sv_instrum IT
                    WHERE MI.num_cte = cNUMCTE AND IT.cod_instrum  = MI.cod_instrum ORDER BY MI.cuenta

                    SELECT MIN(fecha_alta) INTO dFecha_aperturaO_inv FROM bdinvers:"informix".sv_maeinv WHERE num_cte = cNUMCTE and cuenta=cNo_cuenta;

                    INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
                    fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,cod_statuscta) values (cCodRet,cIProducto_chequera,
                    cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
                    cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC,cIdStatusCuenta);
                END FOREACH;

                SET ISOLATION TO DIRTY READ;
                FOREACH

                    SELECT a.num_credito,b.num_tarjeta,DECODE(b.status_tar,"A","ACTIVA","C","CANCELADA","")
                    INTO cNumero_cuenta,cNo_tarjeta,cStatus_tarjeta
                    FROM bdicred:"informix".sd_maecred a
                    LEFT JOIN bdicred:"informix".sd_tarjeta b
                    ON b.num_credito= a.num_credito
                    WHERE a.numcte = cNUMCTE ORDER BY a.num_credito

                    /*SELECT num_credito into cNumero_cuenta
                    FROM bdicred:sd_maecred
                    WHERE numcte = cNUMCTE order by num_credito*/

                    SELECT  MAX(fecha) INTO dFecha FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cNumero_cuenta;
					                 
                    SELECT 'N','06',MC.num_credito, MC.num_producto,DE.nombre_prod,MC.fecha_apertura,
                    TC.descripcion,	MC.sucursal,MC.ejecutivo, dFecha,TC.status_cred
                    INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,
                    cStatus_cuenta,cClave_sucursal,cEjecutivo,dFecha_status,cIdStatusCuenta
                    FROM bdicred:"informix".sd_maecred MC,
                    bdicred:"informix".sd_tipocartera TC,
                    bdicred:"informix".sd_definicion DE
                    WHERE MC. num_credito  = cNumero_cuenta 
                    AND	DE.num_producto = MC.num_producto
                    AND MC.status_cred = TC.status_cred;
                  
                    SELECT sdo_cap_insoluto + sdo_exig_int + sdo_no_exig + sdo_moratorio as Saldo
                    INTO mSaldo_actual
                    FROM bdicred:"informix".sd_maesdos
                    WHERE num_credito =cNumero_cuenta;

                    /*SELECT num_tarjeta,DECODE(status_tar,"A","ACTIVA","C","CANCELADA","DESCONOCIDO")
                    INTO cNo_tarjeta,cStatus_tarjeta
                    FROM bdicred:sd_tarjeta TA
                    WHERE TA.num_credito = cNumero_cuenta 
                    AND TA.status_tar ='A' AND tipo_tarjeta='T';*/

                    INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
                    fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,cod_statuscta) values (cCodRet,cIProducto_chequera,
                    cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
                    cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC,cIdStatusCuenta);
                END FOREACH;

                SET ISOLATION TO DIRTY READ;
                FOREACH

                    SELECT a.num_credito,b.num_tarjeta,DECODE(b.status_tar,"A","ACTIVA","C","CANCELADA","")
                    INTO cNumero_cuenta,cNo_tarjeta,cStatus_tarjeta
                    FROM bdicred:"informix".sd_maecredcrd a
                    LEFT JOIN bdicred:"informix".sd_tarjeta b
                    ON b.num_credito= a.num_credito
                    WHERE a.numcte = cNUMCTE ORDER BY a.num_credito

                    /*SELECT num_credito INTO cNumero_cuenta
                    FROM bdicred:sd_maecredcrd
                    WHERE numcte = cNUMCTE ORDER BY num_credito*/

                    SELECT  MAX(fecha) INTO dFecha FROM bdicred:sd_bitacorabloqueocta WHERE cuenta = cNumero_cuenta;

                    SELECT 'N','06',MC.num_credito, MC.num_producto,DE.nombre_prod,MC.fecha_apertura,
                    TC.descripcion,	MC.sucursal,MC.ejecutivo, dFecha,TC.status_cred
                    INTO cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,
                    cStatus_cuenta,cClave_sucursal,cEjecutivo,dFecha_status,cIdStatusCuenta
                    FROM bdicred:"informix".sd_maecredcrd MC,
                    bdicred:"informix".sd_tipocartera TC,
                    bdicred:"informix".sd_definicion DE
                    WHERE MC. num_credito  = cNumero_cuenta 
                    AND	DE.num_producto = MC.num_producto
                    AND MC.status_cred = TC.status_cred;

                    SELECT sdo_cap_insoluto + sdo_exig_int + sdo_no_exig + sdo_moratorio AS Saldo
                    INTO mSaldo_actual
                    FROM bdicred:"informix".sd_maesdoscrd
                    WHERE num_credito =cNumero_cuenta;

                    /*SELECT num_tarjeta,DECODE(status_tar,"A","ACTIVA","C","CANCELADA","DESCONOCIDO")
                    INTO cNo_tarjeta,cStatus_tarjeta
                    FROM bdicred:sd_tarjeta TA
                    WHERE TA.num_credito = cNumero_cuenta 
                    AND TA.status_tar ='A' AND tipo_tarjeta='T';*/


                    INSERT INTO "informix".si_tempoctas (codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,status_cuenta,
                    fecha_status,clave_sucursal,ejecutivo,saldo_actual,no_tarjeta,status_tarjeta,cuenta_clabe,fecha_apertura_inv,numcte,ejecutivosif,cod_statuscta) values (cCodRet,cIProducto_chequera,
                    cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
                    cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cNUMCTE,cID_USUARIOC,cIdStatusCuenta);
                END FOREACH;

        END IF 

        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} SKIP pNumRegistro FIRST pRecuperacion codret,producto_chequera,scuenta,no_cuenta,clave_producto,nombre_producto,fecha_apertura,nvl(status_cuenta,''),
                        fecha_status,clave_sucursal,ejecutivo,saldo_actual,nvl(no_tarjeta,''),nvl(status_tarjeta,''),cuenta_clabe,fecha_apertura_inv,cod_statuscta into cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
                        cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,cIdStatusCuenta
            FROM "informix".si_tempoctas
            WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC ORDER BY scuenta,no_cuenta,fecha_apertura 
            
            LET iCont=iCont+1;
			
			
			-- FECHA DE CANCELACION
			EXECUTE PROCEDURE "informix".sp_consultafechacancelacioncta(cNo_cuenta, cScuenta) INTO cCodRet, dFechaCancelacion;

            RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta WITH resume;
        END FOREACH;
        IF iCont = 0 THEN
            DELETE {+INDEX (bdinteg:si_tempoctas idx_tempoctas)} FROM "informix".si_tempoctas WHERE numcte = cNUMCTE AND ejecutivosif= cID_USUARIOC;
			
            LET cCodRet = '1001'; 
			RETURN cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
            cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,dFechaCancelacion,cIdStatusCuenta;
        END IF 
	END IF
END
END PROCEDURE
DOCUMENT
"AutOR : Antonio Flores",
"FUNCIONAMIENTO:Este sp realizara la busqueda por tipo de cuenta, dependiendo de tipo de cuenta regresara los datos correspondientes, para captacion o cuenta de cheques",
"para cuentas tipo credito 06 que seran de credito y las cuentas tipo 03 que son de  tipo inversiones",
"FECHA : 04-01-2012",
"BD    : bdinteg",
"Modifico : Victor Hugo Sanchez",
"MODIFICACION : Se almacenan los datos de las cuentas en tabla de paso y se agrega la paginacion",
"Modifico : Oscar Flores Conde",
"MODIFICACION : Se agrega la fecha de cancelacion de la cuenta",
"FECHA : 10-08-2015",
"Modifico : Oscar Flores Conde",
"MODIFICACION : Se agrega el estatus de la cuenta para saber si es cancelada o no",
"VER   : 1.0",
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/01',
'RAZON:                 Se agrega la nueva variable saldo_sbc (inmovilizacion por concepto de credito)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdinteg',
'VER:                   1.2';

CREATE PROCEDURE "informix".sp_desbctasfus_consctas(pNumeroCliente CHAR(20), pAnalista CHAR (20))
RETURNING CHAR(5), CHAR(20), CHAR(20), CHAR(4), CHAR(40), CHAR(2), MONEY(10,2), CHAR(10), DATE, CHAR(10), DATE,CHAR(1);
--DEFINICION DE VARIABLES
DEFINE cCodRet        			CHAR(5);
DEFINE cNumeroCte     			CHAR(20);
DEFINE cCuenta        			CHAR(20);
DEFINE cProducto      			CHAR(4);
DEFINE cDescProducto  			CHAR(40);
DEFINE dFechaAlta     			DATE;
DEFINE cStatusCta     			CHAR(2);
DEFINE cDescStatus    			CHAR(50);
DEFINE dFechaUltMov   			DATE;
DEFINE mSaldo         			MONEY(10,2);
DEFINE iSqlErr        			INTEGER;
DEFINE cEmpresa      			CHAR(3);
DEFINE cUsuario_bloqueo   		CHAR(10);
DEFINE dFecha_bloqueo     		DATE;
DEFINE cSupervisor_desbloqueo  	CHAR(10);
DEFINE dFecha_desbloqueo      	DATE;
DEFINE cValidaNumCte			CHAR(20);	--DSB20130911
DEFINE cValidaNumCta			CHAR (20);	--DSB20130911
DEFINE iNumRows					INTEGER;	--DSB20130911
DEFINE dMaxFecha				DATE;
DEFINE dtHora					DATETIME HOUR TO FRACTION(3);
DEFINE dMaxFechaDesb			DATE;
DEFINE dtHoraDesb				DATETIME HOUR TO FRACTION(3);
DEFINE bBloqueo					CHAR(1);
--RQM 09 704. Se agregan las siguientes variable DFTL 
DEFINE mSdoActual              MONEY(14,2);
DEFINE mSdoRetenido        	   MONEY(14,2);
DEFINE mSdoCongelado           MONEY(14,2);
DEFINE mSaldoSbc               MONEY(14,2);
DEFINE mImpChqSbg              MONEY(14,2); 
DEFINE cCodRetConsSdo          CHAR(5); --Codigo de retorno de SP de consulta de saldo.
DEFINE cMensajeRetConsSdo      CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
--INICIALIZACION DE VARIABLES
LET cCodRet 					= "00000";
LET cNumeroCte 					= "";
LET cCuenta 					= "";
LET cProducto 					= "";
LET cDescProducto 				= "";
LET dFechaAlta 					= "";
LET cStatusCta 					= "";
LET cDescStatus 				= "";
LET dFechaUltMov 				= "";
LET mSaldo 						= 0.00;
LET iSqlErr 					= 0;
LET cEmpresa 					= "001";
LET cUsuario_bloqueo 			= "";
LET dFecha_bloqueo 				= "";
LET cSupervisor_desbloqueo		= "";
LET dFecha_desbloqueo 			= "";
LET cValidaNumCte 				= '';		--DSB20130911
LET cValidaNumCta 				= '';		--DSB20130911
LET iNumRows					= 0;		--DSB20130911
LET dMaxFecha					= CURRENT;
LET dtHora						= '00:00:00';
LET dMaxFechaDesb				= CURRENT;
LET dtHoraDesb					= '00:00:00';
LET bBloqueo					="";
--RQM 09 704. Se agregan las siguientes variable DFTL
LET mSdoActual         			= 0;
LET mSdoRetenido           		= 0;
LET mSdoCongelado          		= 0;
LET mSaldoSbc           		= 0;
LET mImpChqSbg      			= 0;
LET cCodRetConsSdo      		= '00000';
LET cMensajeRetConsSdo  		= '';

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO '/informix/VH/decli/sp_desbctasfus_consctas.out';
    --TRACE ON;
BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, pNumeroCliente, cCuenta, cProducto, cDescProducto, cStatusCta, mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,bBloqueo;
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	DELETE {+INDEX(bdinteg:"informix".si_desbctasfus_cuentas idx_desbctasfus)} FROM bdinteg:"informix".si_desbctasfus_cuentas where analista=pAnalista AND cuenta=cuenta;	-- Sustituciï¿½n de la tabla temporal. Borra los registros de la tabla que antes era temporal.	--DSB20130911{
	
	SELECT FIRST 1 num_cte INTO cValidaNumCte
	FROM bdicheq:"informix".sc_maechq 
	WHERE num_cte = pNumeroCliente AND status_cta IN (1,3); --and motivo = '09')		--DSB20130805
	LET iNumRows = DBINFO("sqlca.sqlerrd2");
	IF(iNumRows = 0) THEN
		SELECT FIRST 1 numcte INTO cValidaNumCte
		FROM bdicred:"informix".sd_maecred
		WHERE numcte = pNumeroCliente;
		LET iNumRows = DBINFO("sqlca.sqlerrd2");
		IF(iNumRows = 0) THEN								--DSB20130911}
			LET cCodRet = "00100";
			RETURN cCodRet, pNumeroCliente, cCuenta, cProducto, cDescProducto, cStatusCta, mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,bBloqueo;
		END IF;
    END IF;

	SELECT FIRST 1 chq.num_cte INTO cValidaNumCte			--DSB20130911{
	FROM bdicheq:"informix".sc_maechq chq, bdicheq:"informix".sc_histbloq bloq 
	WHERE chq.num_cte = pNumeroCliente AND chq.status_cta IN (1,3) AND chq.cuenta = bloq.cuenta AND bloq.usuario = pAnalista AND bloq.tipo_mov = 'B';
	LET iNumRows = DBINFO("sqlca.sqlerrd2");
	IF(iNumRows = 0) THEN
		SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} FIRST 1 numcte INTO cValidaNumCte
		FROM bdicred:"informix".sd_maecred cred, bdicred:"informix".sd_bitacorabloqueocta bloq 
		WHERE cred.numcte = pNumeroCliente
		AND bloq.ejecutivo = pAnalista AND cred.num_credito = bloq.cuenta AND bloq.tipo_movimiento = 'B' AND bloq.cuenta = bloq.cuenta;
		LET iNumRows = DBINFO("sqlca.sqlerrd2");
		IF(iNumRows = 0) THEN
			SELECT FIRST 1 num_cte INTO cValidaNumCte
			FROM bdicheq:"informix".sc_maechq
			WHERE num_cte = pNumeroCliente;
			LET iNumRows = DBINFO("sqlca.sqlerrd2");
			IF(iNumRows > 0) THEN							--DSB20130911{
				FOREACH
					SELECT mae.cuenta AS cuenta, mae.producto AS producto, prod.nombre AS nombre, NVL(mae.status_cta, "00") AS status,
					mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, mae.saldo_sbc 
					INTO cCuenta, cProducto, cDescProducto,  cStatusCta, mSdoActual, mSdoRetenido, mSdoCongelado, mImpChqSbg, mSaldoSbc
					FROM bdicheq:"informix".sc_maechq mae , bdicheq:"informix".sc_producto prod 
					WHERE mae.num_cte = pNumeroCliente 
					AND mae.producto = prod.producto

					--RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL
					EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCongelado, mSaldoSbc, mImpChqSbg, null, null, 'F', 1)
					INTO cCodRetConsSdo, cMensajeRetConsSdo, mSaldo;

					SELECT FIRST 1 cuenta INTO cValidaNumCta	--DSB20130911{
					FROM bdicheq:"informix".sc_histbloq
					WHERE cuenta = cCuenta AND tipo_mov = 'B';
					LET iNumRows = DBINFO("sqlca.sqlerrd2");
					IF(iNumRows > 0) THEN						--DSB20130911}
						SELECT MAX(fecha) INTO dMaxFecha FROM bdicheq:"informix".sc_histbloq WHERE cuenta =  cCuenta AND tipo_mov = 'B';
					
						SELECT MAX(hora) INTO dtHora FROM bdicheq:"informix".sc_histbloq  
						WHERE cuenta = cCuenta AND fecha = dMaxFecha;
						
						SELECT FIRST 1 usuario AS usuario_bloq ,fecha AS fecha_bloq 
						INTO cUsuario_bloqueo,dFecha_bloqueo
						FROM bdicheq:"informix".sc_histbloq  
						WHERE cuenta = cCuenta AND fecha = dMaxFecha AND hora = dtHora;
						
					ELSE
						LET cUsuario_bloqueo = '';
						LET dFecha_bloqueo = '';
					END IF;

						SELECT MAX(fecha) INTO dFecha_desbloqueo FROM bdicheq:"informix".sc_histbloq WHERE cuenta =  cCuenta AND tipo_mov = 'D';
					
						SELECT MAX(hora) INTO dtHoraDesb FROM bdicheq:"informix".sc_histbloq  
						WHERE cuenta = cCuenta AND fecha = dFecha_desbloqueo AND tipo_mov = 'D';

						SELECT FIRST 1 usuario AS supervisor_desb
						INTO cSupervisor_desbloqueo
						FROM bdicheq:"informix".sc_histbloq WHERE cuenta = cCuenta AND fecha = dFecha_desbloqueo AND tipo_mov = 'D';


--					SELECT MAX(fecha) INTO dMaxFechaDesb FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta =  cCuenta;
--					SELECT MAX(hora) INTO dtHoraDesb FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb;
					/*
					SELECT usuario AS supervisor_desb,fecha AS fecha_desb
					INTO cSupervisor_desbloqueo,dFecha_desbloqueo
					FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb AND hora = dtHoraDesb;
					*/

					
					INSERT INTO bdinteg:"informix".si_desbctasfus_cuentas(cuenta, producto, nombre, status, saldo,usuario_bloqueo, fecha_bloqueo, supervisor_desbloqueo, fecha_desbloqueo,analista)	--DSB20130911
					VALUES(cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,pAnalista);
					
					LET cCodRet = '00200';
					
				END FOREACH;
			END IF;
			
			SELECT FIRST 1 numcte INTO cValidaNumCte															--DSB20130911{
			FROM bdicred:"informix".sd_maecred
			WHERE numcte = pNumeroCliente;
			LET iNumRows = DBINFO("sqlca.sqlerrd2");
			IF(iNumRows > 0) THEN																				--DSB20130911}
				FOREACH
					SELECT cred.num_credito AS cuenta, cred.num_producto AS producto, def.nombre_prod AS nombre, cred.status_cred AS status, (dos.sdo_capital + dos.monto_vencido + dos.mto_venc_trasp + dos.cap_tras_no_venci) AS saldo 
					INTO cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo 
					FROM bdicred:"informix".sd_maecred cred, bdicred:"informix".sd_maesdos dos, bdicred:"informix".sd_definicion def 
					WHERE cred.numcte = pNumeroCliente AND dos.empresa = cEmpresa AND dos.num_credito = cred.num_credito AND
					def.empresa = cEmpresa AND def.num_producto = cred.num_producto
					
					SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} FIRST 1 cuenta INTO cValidaNumCta													--DSB20130911{
					FROM bdicred:"informix".sd_bitacorabloqueocta
					WHERE cuenta = cCuenta AND tipo_movimiento = 'B';
					LET iNumRows = DBINFO("sqlca.sqlerrd2");
					IF(iNumRows > 0) THEN																		--DSB20130911}
						SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} ejecutivo AS usuario_bloq, fecha AS fecha_bloq
						INTO cUsuario_bloqueo,dFecha_bloqueo
						FROM bdicred:"informix".sd_bitacorabloqueocta
						WHERE id = (SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} MAX(id) FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cCuenta AND tipo_movimiento = 'B');
					ELSE
						LET cUsuario_bloqueo = '';
						LET dFecha_bloqueo = '';
					END IF;
					
					SELECT MAX(fecha) INTO dMaxFechaDesb FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta =  cCuenta AND tipo_movimiento = 'D';
					--SELECT MAX(hora) INTO dtHoraDesb FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb AND tipo_movimiento = 'D';
					/*SELECT usuario AS supervisor_desb,fecha AS fecha_desb
					INTO cSupervisor_desbloqueo,dFecha_desbloqueo
					FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb AND hora = dtHoraDesb;*/


						SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} FIRST 1 ejecutivo AS usuario_bloq, fecha AS fecha_bloq
						INTO cSupervisor_desbloqueo,dFecha_desbloqueo
						FROM bdicred:"informix".sd_bitacorabloqueocta
						WHERE id = (SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} MAX(id) FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cCuenta AND tipo_movimiento = 'D');



					
					INSERT INTO bdinteg:"informix".si_desbctasfus_cuentas(cuenta, producto, nombre, status, saldo,usuario_bloqueo, fecha_bloqueo, supervisor_desbloqueo, fecha_desbloqueo,analista )	--DSB20130911
					VALUES(cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,pAnalista );
					
					LET cCodRet = '00200';
					
				END FOREACH;
			END IF;
		END IF
    END IF;
	--DSB20130805 }
	
	--	Dï¿½bito	
	SELECT FIRST 1 num_cte INTO cValidaNumCte									--DSB20130911{
	FROM bdicheq:"informix".sc_maechq
	WHERE num_cte = pNumeroCliente AND motivo = '09';
	LET iNumRows = DBINFO("sqlca.sqlerrd2");
	IF(iNumRows > 0) THEN														--DSB20130911}
		FOREACH
			SELECT DISTINCT(mae.cuenta) AS cuenta, mae.producto AS producto, prod.nombre AS nombre, NVL(mae.status_cta, "00") AS status, mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, mae.saldo_sbc, bloq.usuario AS usuario_bloq ,bloq.fecha AS fecha_bloq
			INTO cCuenta, cProducto, cDescProducto,  cStatusCta,mSdoActual, mSdoRetenido, mSdoCongelado, mImpChqSbg, mSaldoSbc, cUsuario_bloqueo,dFecha_bloqueo
			FROM bdicheq:"informix".sc_maechq mae, bdicheq:"informix".sc_maenoc noc, bdicheq:"informix".sc_producto prod ,bdicheq:"informix".sc_histbloq bloq
			WHERE mae.num_cte = pNumeroCliente AND noc.cuenta = mae.cuenta AND mae.producto = prod.producto AND mae.cuenta = bloq.cuenta
			AND mae.status_cta IN (1,3) AND bloq.cve_tipobloq = '12' AND bloq.cod_tipobloq = 'Z' AND mae.motivo = '09'	AND bloq.tipo_mov = 'B'--DSB20130805
			AND bloq.fecha in( SELECT MAX(fecha) FROM bdicheq:"informix".sc_histbloq WHERE cuenta =  mae.cuenta 
			AND tipo_mov = 'B' )		--DSB20130805
			--RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL
			EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCongelado, mSaldoSbc, mImpChqSbg, null, null, 'F', 1)
			INTO cCodRetConsSdo, cMensajeRetConsSdo, mSaldo;
		/*	SELECT MAX(fecha) INTO dMaxFechaDesb FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta =  cCuenta;
			SELECT MAX(hora) INTO dtHoraDesb FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb;
			
			SELECT usuario AS supervisor_desb,fecha AS fecha_desb
			INTO cSupervisor_desbloqueo,dFecha_desbloqueo
			FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb AND hora = dtHoraDesb;
		*/

			SELECT MAX(fecha) INTO dFecha_desbloqueo FROM bdicheq:"informix".sc_histbloq WHERE cuenta =  cCuenta AND tipo_mov = 'B';

			SELECT MAX(hora) INTO dtHoraDesb FROM bdicheq:"informix".sc_histbloq  
			WHERE cuenta = cCuenta AND fecha = dFecha_desbloqueo AND tipo_mov = 'B';

			SELECT FIRST 1 usuario AS supervisor_desb
			INTO cSupervisor_desbloqueo
			FROM bdicheq:"informix".sc_histbloq WHERE cuenta = cCuenta AND fecha = dFecha_desbloqueo AND tipo_mov = 'B';

			IF cUsuario_bloqueo = pAnalista THEN
				INSERT INTO bdinteg:"informix".si_desbctasfus_cuentas(cuenta, producto, nombre, status, saldo,usuario_bloqueo, fecha_bloqueo, supervisor_desbloqueo, fecha_desbloqueo,analista)	--DSB20130911
				VALUES(cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,pAnalista);
			END IF
		END FOREACH;
		
		SELECT FIRST 1 num_cte INTO cValidaNumCte								--DSB20130911{
		FROM bdicheq:"informix".sc_maechq
		WHERE num_cte = pNumeroCliente AND motivo <> '09';
		LET iNumRows = DBINFO("sqlca.sqlerrd2");
		IF(iNumRows > 0) THEN													--DSB20130911}				
			FOREACH
				SELECT DISTINCT(mae.cuenta) AS cuenta, mae.producto AS producto, prod.nombre AS nombre, NVL(mae.status_cta, "00") AS status, mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, mae.saldo_sbc, bloq.usuario AS usuario_bloq ,bloq.fecha AS fecha_bloq
				INTO cCuenta, cProducto, cDescProducto,  cStatusCta, mSdoActual, mSdoRetenido, mSdoCongelado, mImpChqSbg, mSaldoSbc, cUsuario_bloqueo,dFecha_bloqueo
				FROM bdicheq:"informix".sc_maechq mae, bdicheq:"informix".sc_maenoc noc, bdicheq:"informix".sc_producto prod ,bdicheq:"informix".sc_histbloq bloq
				WHERE mae.num_cte = pNumeroCliente AND noc.cuenta = mae.cuenta AND mae.producto = prod.producto AND mae.cuenta = bloq.cuenta
				AND mae.status_cta IN (1,3) AND bloq.cve_tipobloq = '12' AND bloq.cod_tipobloq = 'Z' AND mae.motivo <> '09' AND bloq.tipo_mov = 'B'
				AND bloq.fecha in( SELECT MAX(fecha) FROM bdicheq:"informix".sc_histbloq WHERE cuenta =  mae.cuenta 
				AND tipo_mov = 'B' )
				--RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL
				EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCongelado, mSaldoSbc, mImpChqSbg, null, null, 'F', 1)
				INTO cCodRetConsSdo, cMensajeRetConsSdo, mSaldo;
/*				
				SELECT MAX(fecha) INTO dMaxFechaDesb FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta =  cCuenta;
				SELECT MAX(hora) INTO dtHoraDesb FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb;
				
				SELECT usuario AS supervisor_desb,fecha AS fecha_desb
				INTO cSupervisor_desbloqueo,dFecha_desbloqueo
				FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb AND hora = dtHoraDesb;
*/

				SELECT MAX(fecha) INTO dFecha_desbloqueo FROM bdicheq:"informix".sc_histbloq WHERE cuenta =  cCuenta AND tipo_mov = 'D';

				SELECT MAX(hora) INTO dtHoraDesb FROM bdicheq:"informix".sc_histbloq  
				WHERE cuenta = cCuenta AND fecha = dFecha_desbloqueo AND tipo_mov = 'D';

				SELECT FIRST 1 usuario AS supervisor_desb
				INTO cSupervisor_desbloqueo
				FROM bdicheq:"informix".sc_histbloq WHERE cuenta = cCuenta AND fecha = dFecha_desbloqueo AND tipo_mov = 'D';
			
				IF cUsuario_bloqueo = pAnalista THEN
					INSERT INTO bdinteg:"informix".si_desbctasfus_cuentas(cuenta, producto, nombre, status, saldo,usuario_bloqueo, fecha_bloqueo, supervisor_desbloqueo, fecha_desbloqueo,analista)	--DSB20130911
					VALUES(cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,pAnalista);
				END IF
			END FOREACH;
		END IF;
	ELSE
		FOREACH  --DSB23082013
			SELECT DISTINCT(mae.cuenta) AS cuenta, mae.producto AS producto, prod.nombre AS nombre, NVL(mae.status_cta, "00") AS status, mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, mae.saldo_sbc, bloq.usuario AS usuario_bloq ,bloq.fecha AS fecha_bloq
			INTO cCuenta, cProducto, cDescProducto,  cStatusCta, mSdoActual, mSdoRetenido, mSdoCongelado, mImpChqSbg, mSaldoSbc, cUsuario_bloqueo,dFecha_bloqueo
			FROM bdicheq:"informix".sc_maechq mae, bdicheq:"informix".sc_maenoc noc, bdicheq:"informix".sc_producto prod ,bdicheq:"informix".sc_histbloq bloq
			WHERE mae.num_cte = pNumeroCliente AND noc.cuenta = mae.cuenta AND mae.producto = prod.producto AND mae.cuenta = bloq.cuenta
			AND mae.status_cta IN (1,3) AND bloq.cve_tipobloq = '12' AND bloq.cod_tipobloq = 'Z' AND tipo_mov = 'B'--AND mae.motivo = '09'
			AND bloq.fecha in( SELECT MAX(fecha) FROM bdicheq:"informix".sc_histbloq WHERE cuenta =  mae.cuenta 
			AND tipo_mov = 'B' )
			--RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL
			EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCongelado, mSaldoSbc, mImpChqSbg, null, null, 'F', 1)
			INTO cCodRetConsSdo, cMensajeRetConsSdo, mSaldo;
		/*	
			SELECT MAX(fecha) INTO dMaxFechaDesb FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta =  cCuenta;
			SELECT MAX(hora) INTO dtHoraDesb FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb;

			SELECT usuario AS supervisor_desb,fecha AS fecha_desb
			INTO cSupervisor_desbloqueo,dFecha_desbloqueo
			FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb AND hora = dtHoraDesb;
*/

			SELECT MAX(fecha) INTO dFecha_desbloqueo FROM bdicheq:"informix".sc_histbloq WHERE cuenta =  cCuenta AND tipo_mov = 'B';

			SELECT MAX(hora) INTO dtHoraDesb FROM bdicheq:"informix".sc_histbloq  
			WHERE cuenta = cCuenta AND fecha = dFecha_desbloqueo AND tipo_mov = 'B';

			SELECT FIRST 1 usuario AS supervisor_desb
			INTO cSupervisor_desbloqueo
			FROM bdicheq:"informix".sc_histbloq WHERE cuenta = cCuenta AND fecha = dFecha_desbloqueo AND tipo_mov = 'B';

			IF cUsuario_bloqueo = pAnalista THEN
				INSERT INTO bdinteg:"informix".si_desbctasfus_cuentas(cuenta, producto, nombre, status, saldo,usuario_bloqueo, fecha_bloqueo, supervisor_desbloqueo, fecha_desbloqueo,analista)	--DSB20130911
				VALUES(cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,pAnalista);
			END IF
		END FOREACH;
	END IF;

	-- Crï¿½dito
	SELECT FIRST 1 numcte INTO cValidaNumCte									--DSB20130911{
	FROM bdicred:"informix".sd_maecred
	WHERE numcte = pNumeroCliente  AND cod_caract_2 = '09';
	LET iNumRows = DBINFO("sqlca.sqlerrd2");
	IF(iNumRows > 0) THEN														--DSB20130911}
		FOREACH
			SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} cred.num_credito AS cuenta, cred.num_producto AS producto, def.nombre_prod AS nombre, cred.status_cred AS status, (dos.sdo_capital + dos.monto_vencido + dos.mto_venc_trasp + dos.cap_tras_no_venci) AS saldo ,
			bloq.ejecutivo AS usuario_bloq ,bloq.fecha AS fecha_bloq
			INTO cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo ,cUsuario_bloqueo,dFecha_bloqueo
			FROM bdicred:"informix".sd_maecred cred, bdicred:"informix".sd_maesdos dos, bdicred:"informix".sd_definicion def ,
			bdicred:"informix".sd_bitacorabloqueocta bloq
			WHERE cred.numcte = pNumeroCliente AND dos.empresa = cEmpresa AND dos.num_credito = cred.num_credito AND
			def.empresa = cEmpresa AND def.num_producto = cred.num_producto AND cred.num_credito = bloq.cuenta 
			AND cred.id_unidad_prod = 3 AND cred.cod_caract_2 = '09' 			 		--DSB20130805
			AND id = (SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} MAX(id) FROM bdicred:"informix".sd_bitacorabloqueocta 		--DSB20130805
			WHERE cuenta = cred.num_credito AND tipo_movimiento = 'B' AND ejecutivo = pAnalista) --DSB20130805

			--LET cStatusCta='B';

			SELECT MAX(fecha) INTO dMaxFechaDesb FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta =  cCuenta AND tipo_movimiento = 'B';
			--SELECT MAX(hora) INTO dtHoraDesb FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb AND tipo_movimiento = 'B';
			
			/*SELECT usuario AS supervisor_desb,fecha AS fecha_desb
			INTO cSupervisor_desbloqueo,dFecha_desbloqueo
			FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb AND hora = dtHoraDesb;*/

			SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} FIRST 1 ejecutivo AS usuario_bloq, fecha AS fecha_bloq
			INTO cSupervisor_desbloqueo,dFecha_desbloqueo
			FROM bdicred:"informix".sd_bitacorabloqueocta
			WHERE id = (SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} MAX(id) FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cCuenta AND tipo_movimiento = 'B');


			IF cUsuario_bloqueo = pAnalista THEN
				INSERT INTO bdinteg:"informix".si_desbctasfus_cuentas(cuenta, producto, nombre, status, saldo,usuario_bloqueo, fecha_bloqueo, supervisor_desbloqueo, fecha_desbloqueo,analista,bloq_cred )	--DSB20130911
				VALUES(cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,pAnalista,'B' );
			END IF
		END FOREACH;
			SELECT FIRST 1 numcte INTO cValidaNumCte								--DSB20130911{
			FROM bdicred:"informix".sd_maecred
			WHERE numcte = pNumeroCliente  AND NVL(cod_caract_2,'') <> '09';
			LET iNumRows = DBINFO("sqlca.sqlerrd2");
			IF(iNumRows > 0) THEN													--DSB20130911}
				FOREACH
					SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} cred.num_credito AS cuenta, cred.num_producto AS producto, def.nombre_prod AS nombre, cred.status_cred AS status, (dos.sdo_capital + dos.monto_vencido + dos.mto_venc_trasp + dos.cap_tras_no_venci) AS saldo ,
					bloq.ejecutivo AS usuario_bloq ,bloq.fecha AS fecha_bloq
					INTO cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo ,cUsuario_bloqueo,dFecha_bloqueo
					FROM bdicred:"informix".sd_maecred cred, bdicred:"informix".sd_maesdos dos, bdicred:"informix".sd_definicion def ,
					bdicred:"informix".sd_bitacorabloqueocta bloq
					WHERE cred.numcte = pNumeroCliente AND dos.empresa = cEmpresa AND dos.num_credito = cred.num_credito AND
					def.empresa = cEmpresa AND def.num_producto = cred.num_producto AND cred.num_credito = bloq.cuenta 
					--AND cred.id_unidad_prod = 3 
					AND NVL(cred.cod_caract_2,'') <> '09'
					AND id = (SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} MAX(id) FROM bdicred:"informix".sd_bitacorabloqueocta
					WHERE cuenta = cred.num_credito AND tipo_movimiento = 'B' AND ejecutivo = pAnalista)
				
				/*	SELECT usuario AS supervisor_desb,fecha AS fecha_desb
					INTO cSupervisor_desbloqueo,dFecha_desbloqueo
					FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE  cuenta = cCuenta;*/

						SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} FIRST 1 ejecutivo AS usuario_bloq, fecha AS fecha_bloq
						INTO cSupervisor_desbloqueo,dFecha_desbloqueo
						FROM bdicred:"informix".sd_bitacorabloqueocta
						WHERE id = (SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} MAX(id) FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cCuenta AND tipo_movimiento = 'D');


					IF cUsuario_bloqueo = pAnalista THEN
						INSERT INTO bdinteg:"informix".si_desbctasfus_cuentas(cuenta, producto, nombre, status, saldo,usuario_bloqueo, fecha_bloqueo, supervisor_desbloqueo, fecha_desbloqueo,analista )	--DSB20130911
						VALUES(cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,pAnalista );
					END IF
				END FOREACH;
			END IF;
	ELSE
		FOREACH  --DSB23082013
			SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} cred.num_credito AS cuenta, cred.num_producto AS producto, def.nombre_prod AS nombre, cred.status_cred AS status, (dos.sdo_capital + dos.monto_vencido + dos.mto_venc_trasp + dos.cap_tras_no_venci) AS saldo ,
			bloq.ejecutivo AS usuario_bloq ,bloq.fecha AS fecha_bloq
			INTO cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo ,cUsuario_bloqueo,dFecha_bloqueo
			FROM bdicred:"informix".sd_maecred cred, bdicred:"informix".sd_maesdos dos, bdicred:"informix".sd_definicion def ,
			bdicred:"informix".sd_bitacorabloqueocta bloq
			WHERE cred.numcte = pNumeroCliente AND dos.empresa = cEmpresa AND dos.num_credito = cred.num_credito AND
			def.empresa = cEmpresa AND def.num_producto = cred.num_producto AND cred.num_credito = bloq.cuenta 
			AND id = (SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} MAX(id) FROM bdicred:"informix".sd_bitacorabloqueocta
			WHERE cuenta = cred.num_credito AND tipo_movimiento = 'B' AND ejecutivo = pAnalista)
			
			SELECT MAX(fecha) INTO dFecha_desbloqueo FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta =  cCuenta AND tipo_movimiento = 'B';
			--SELECT MAX(hora) INTO dtHoraDesb FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cCuenta AND fecha = dFecha_desbloqueo AND tipo_movimiento = 'B';
			
		/*	SELECT usuario AS supervisor_desb,fecha AS fecha_desb
			INTO cSupervisor_desbloqueo,dFecha_desbloqueo
			FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta = cCuenta AND fecha = dMaxFechaDesb AND hora = dtHoraDesb;*/

			SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} FIRST 1 ejecutivo AS usuario_bloq, fecha AS fecha_bloq
			INTO cSupervisor_desbloqueo,dFecha_desbloqueo
			FROM bdicred:"informix".sd_bitacorabloqueocta
			WHERE id = (SELECT {+INDEX(bdicred:"informix".sd_bitacorabloqueocta idx_bitcta)} MAX(id) FROM bdicred:"informix".sd_bitacorabloqueocta WHERE cuenta = cCuenta AND tipo_movimiento = 'B');

			
			IF cUsuario_bloqueo = pAnalista THEN
				INSERT INTO bdinteg:"informix".si_desbctasfus_cuentas(cuenta, producto, nombre, status, saldo,usuario_bloqueo, fecha_bloqueo, supervisor_desbloqueo, fecha_desbloqueo,analista )	--DSB20130911
				VALUES(cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,pAnalista );
			END IF
		END FOREACH;
	END IF;

	FOREACH
		SELECT cuenta, producto, nombre, status, saldo,usuario_bloqueo, fecha_bloqueo, supervisor_desbloqueo, fecha_desbloqueo,bloq_cred
		INTO cCuenta, cProducto, cDescProducto,  cStatusCta,  mSaldo,cUsuario_bloqueo,dFecha_bloqueo,cSupervisor_desbloqueo,dFecha_desbloqueo,bBloqueo 
		FROM bdinteg:"informix".si_desbctasfus_cuentas WHERE analista=pAnalista ORDER BY cuenta

		RETURN cCodRet, pNumeroCliente, cCuenta, cProducto, cDescProducto, cStatusCta, mSaldo, NVL(cUsuario_bloqueo,''), NVL(dFecha_bloqueo,''),
		NVL(cSupervisor_desbloqueo,''), NVL(dFecha_desbloqueo,''),nvl(bBloqueo,'')  WITH RESUME;
	END FOREACH;
	
	--DELETE FROM bdinteg:"informix".si_desbctasfus_cuentas WHERE analista=pAnalista;
END; 
END PROCEDURE
DOCUMENT
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/07',
'RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdinteg',
'VER:                   1.2';

CREATE PROCEDURE "informix".bm_obten_lista_cuentas( pSessionToken INTEGER,   --- Session Token
                                                    pTipoCuenta   CHAR(10) ) --- Tipo de Cuentas
RETURNING CHAR(5)  AS vCodRet1,        --- Codigo de Retorno
          CHAR(2)  AS vStatus,         --- Status
          CHAR(25) AS vStatusDesc,     --- Descripcion del Status
           
          CHAR(16) AS vCuenta1,               --- Cuenta 
          CHAR(4)  AS vTermCta1,              --- Terminacion Cuenta 
          CHAR(7)  AS vNombreCta1,            --- Producto Cuenta 
          DECIMAL(12,2) AS vSdoDispCta1,      --- Saldo Disponible
          DECIMAL(12,2) AS vSdoCorteCta1,     --- Saldo al Corte
          DECIMAL(12,2) AS vPagoMinCta1,      --- Pago Minimo
          DECIMAL(12,2) AS vPagoNoGenIntCta1, --- Pago No Genera Interes
          CHAR(10) AS vFechaLimPagoCta1,      --- Fecha Limite Pago
          
          CHAR(16) AS vCuenta2,               --- Cuenta 
          CHAR(4)  AS vTermCta2,              --- Terminacion Cuenta 
          CHAR(7)  AS vNombreCta2,            --- Producto Cuenta 
          DECIMAL(12,2) AS vSdoDispCta2,      --- Saldo Disponible
          DECIMAL(12,2) AS vSdoCorteCta2,     --- Saldo al Corte
          DECIMAL(12,2) AS vPagoMinCta2,      --- Pago Minimo
          DECIMAL(12,2) AS vPagoNoGenIntCta2, --- Pago No Genera Interes
          CHAR(10) AS vFechaLimPagoCta2,      --- Fecha Limite Pago
          
          CHAR(16) AS vCuenta3,               --- Cuenta 
          CHAR(4)  AS vTermCta3,              --- Terminacion Cuenta 
          CHAR(7)  AS vNombreCta3,            --- Producto Cuenta 
          DECIMAL(12,2) AS vSdoDispCta3,      --- Saldo Disponible
          DECIMAL(12,2) AS vSdoCorteCta3,     --- Saldo al Corte
          DECIMAL(12,2) AS vPagoMinCta3,      --- Pago Minimo
          DECIMAL(12,2) AS vPagoNoGenIntCta3, --- Pago No Genera Interes
          CHAR(10) AS vFechaLimPagoCta3,      --- Fecha Limite Pago
          
          CHAR(16) AS vCuenta4,               --- Cuenta 
          CHAR(4)  AS vTermCta4,              --- Terminacion Cuenta 
          CHAR(7)  AS vNombreCta4,            --- Producto Cuenta 
          DECIMAL(12,2) AS vSdoDispCta4,      --- Saldo Disponible
          DECIMAL(12,2) AS vSdoCorteCta4,     --- Saldo al Corte
          DECIMAL(12,2) AS vPagoMinCta4,      --- Pago Minimo
          DECIMAL(12,2) AS vPagoNoGenIntCta4, --- Pago No Genera Interes
          CHAR(10) AS vFechaLimPagoCta4,      --- Fecha Limite Pago
          
          CHAR(16) AS vCuenta5,               --- Cuenta 
          CHAR(4)  AS vTermCta5,              --- Terminacion Cuenta 
          CHAR(7)  AS vNombreCta5,            --- Producto Cuenta 
          DECIMAL(12,2) AS vSdoDispCta5,      --- Saldo Disponible
          DECIMAL(12,2) AS vSdoCorteCta5,     --- Saldo al Corte
          DECIMAL(12,2) AS vPagoMinCta5,      --- Pago Minimo
          DECIMAL(12,2) AS vPagoNoGenIntCta5, --- Pago No Genera Interes
          CHAR(10) AS vFechaLimPagoCta5,      --- Fecha Limite Pago
          
          CHAR(16) AS vCuenta6,               --- Cuenta 
          CHAR(4)  AS vTermCta6,              --- Terminacion Cuenta 
          CHAR(7)  AS vNombreCta6,            --- Producto Cuenta 
          DECIMAL(12,2) AS vSdoDispCta6,      --- Saldo Disponible
          DECIMAL(12,2) AS vSdoCorteCta6,     --- Saldo al Corte
          DECIMAL(12,2) AS vPagoMinCta6,      --- Pago Minimo
          DECIMAL(12,2) AS vPagoNoGenIntCta6, --- Pago No Genera Interes
          CHAR(10) AS vFechaLimPagoCta6,      --- Fecha Limite Pago
          
          CHAR(16) AS vCuenta7,               --- Cuenta 
          CHAR(4)  AS vTermCta7,              --- Terminacion Cuenta 
          CHAR(7)  AS vNombreCta,             --- Producto Cuenta 
          DECIMAL(12,2) AS vSdoDispCta7,      --- Saldo Disponible
          DECIMAL(12,2) AS vSdoCorteCta7,     --- Saldo al Corte
          DECIMAL(12,2) AS vPagoMinCta7,      --- Pago Minimo
          DECIMAL(12,2) AS vPagoNoGenIntCta7, --- Pago No Genera Interes
          CHAR(10) AS vFechaLimPagoCta7,      --- Fecha Limite Pago
          
          CHAR(16) AS vCuenta8,               --- Cuenta 
          CHAR(4)  AS vTermCta8,              --- Terminacion Cuenta 
          CHAR(7)  AS vNombreCta8,            --- Producto Cuenta 
          DECIMAL(12,2) AS vSdoDispCta8,      --- Saldo Disponible
          DECIMAL(12,2) AS vSdoCorteCta8,     --- Saldo al Corte
          DECIMAL(12,2) AS vPagoMinCta8,      --- Pago Minimo
          DECIMAL(12,2) AS vPagoNoGenIntCta8, --- Pago No Genera Interes
          CHAR(10) AS vFechaLimPagoCta8,      --- Fecha Limite Pago
          
          CHAR(16) AS vCuenta9,               --- Cuenta 
          CHAR(4)  AS vTermCta9,              --- Terminacion Cuenta 
          CHAR(7)  AS vNombreCta9,            --- Producto Cuenta 
          DECIMAL(12,2) AS vSdoDispCta9,      --- Saldo Disponible
          DECIMAL(12,2) AS vSdoCorteCta9,     --- Saldo al Corte
          DECIMAL(12,2) AS vPagoMinCta9,      --- Pago Minimo
          DECIMAL(12,2) AS vPagoNoGenIntCta9, --- Pago No Genera Interes
          CHAR(10) AS vFechaLimPagoCta9,      --- Fecha Limite Pago
          
          CHAR(16) AS vCuenta10,               --- Cuenta 
          CHAR(4)  AS vTermCta10,              --- Terminacion Cuenta 
          CHAR(7)  AS vNombreCta10,            --- Producto Cuenta 
          DECIMAL(12,2) AS vSdoDispCta10,      --- Saldo Disponible
          DECIMAL(12,2) AS vSdoCorteCta10,     --- Saldo al Corte
          DECIMAL(12,2) AS vPagoMinCta10,      --- Pago Minimo
          DECIMAL(12,2) AS vPagoNoGenIntCta10, --- Pago No Genera Interes
          CHAR(10) AS vFechaLimPagoCta10;      --- Fecha Limite Pago

    
    DEFINE Sql_Err      INTEGER;
    DEFINE Isam_Err     INTEGER;
    DEFINE Desc_Err     CHAR(50);
    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(50);
    DEFINE vStatus      CHAR(2);
    DEFINE vStatusDesc  CHAR(25);

    DEFINE vCuenta1             CHAR(16);
    DEFINE vTermCta1            CHAR(4);
    DEFINE vNombreCta1          CHAR(7);
    DEFINE vSdoDispCta1         DECIMAL(12,2);
    DEFINE vSdoCorteCta1        DECIMAL(12,2);
    DEFINE vPagoMinCta1         DECIMAL(12,2);
    DEFINE vPagoNoGenIntCta1    DECIMAL(12,2);
    DEFINE vFechaLimPagoCta1    CHAR(10);
          
    DEFINE vCuenta2             CHAR(16);
    DEFINE vTermCta2            CHAR(4);
    DEFINE vNombreCta2          CHAR(7);
    DEFINE vSdoDispCta2         DECIMAL(12,2);
    DEFINE vSdoCorteCta2        DECIMAL(12,2);
    DEFINE vPagoMinCta2         DECIMAL(12,2);
    DEFINE vPagoNoGenIntCta2    DECIMAL(12,2);
    DEFINE vFechaLimPagoCta2    CHAR(10);
    
    DEFINE vCuenta3             CHAR(16);
    DEFINE vTermCta3            CHAR(4);
    DEFINE vNombreCta3          CHAR(7);
    DEFINE vSdoDispCta3         DECIMAL(12,2);
    DEFINE vSdoCorteCta3        DECIMAL(12,2);
    DEFINE vPagoMinCta3         DECIMAL(12,2);
    DEFINE vPagoNoGenIntCta3    DECIMAL(12,2);
    DEFINE vFechaLimPagoCta3    CHAR(10);
    
    DEFINE vCuenta4             CHAR(16);
    DEFINE vTermCta4            CHAR(4);
    DEFINE vNombreCta4          CHAR(7);
    DEFINE vSdoDispCta4         DECIMAL(12,2);
    DEFINE vSdoCorteCta4        DECIMAL(12,2);
    DEFINE vPagoMinCta4         DECIMAL(12,2);
    DEFINE vPagoNoGenIntCta4    DECIMAL(12,2);
    DEFINE vFechaLimPagoCta4    CHAR(10);
    
    DEFINE vCuenta5             CHAR(16);
    DEFINE vTermCta5            CHAR(4);
    DEFINE vNombreCta5          CHAR(7);
    DEFINE vSdoDispCta5         DECIMAL(12,2);
    DEFINE vSdoCorteCta5        DECIMAL(12,2);
    DEFINE vPagoMinCta5         DECIMAL(12,2);
    DEFINE vPagoNoGenIntCta5    DECIMAL(12,2);
    DEFINE vFechaLimPagoCta5    CHAR(10);
    
    DEFINE vCuenta6             CHAR(16);
    DEFINE vTermCta6            CHAR(4);
    DEFINE vNombreCta6          CHAR(7);
    DEFINE vSdoDispCta6         DECIMAL(12,2);
    DEFINE vSdoCorteCta6        DECIMAL(12,2);
    DEFINE vPagoMinCta6         DECIMAL(12,2);
    DEFINE vPagoNoGenIntCta6    DECIMAL(12,2);
    DEFINE vFechaLimPagoCta6    CHAR(10);
    
    DEFINE vCuenta7             CHAR(16);
    DEFINE vTermCta7            CHAR(4);
    DEFINE vNombreCta7          CHAR(7);
    DEFINE vSdoDispCta7         DECIMAL(12,2);
    DEFINE vSdoCorteCta7        DECIMAL(12,2);
    DEFINE vPagoMinCta7         DECIMAL(12,2);
    DEFINE vPagoNoGenIntCta7    DECIMAL(12,2);
    DEFINE vFechaLimPagoCta7    CHAR(10);
    
    DEFINE vCuenta8             CHAR(16);
    DEFINE vTermCta8            CHAR(4);
    DEFINE vNombreCta8          CHAR(7);
    DEFINE vSdoDispCta8         DECIMAL(12,2);
    DEFINE vSdoCorteCta8        DECIMAL(12,2);
    DEFINE vPagoMinCta8         DECIMAL(12,2);
    DEFINE vPagoNoGenIntCta8    DECIMAL(12,2);
    DEFINE vFechaLimPagoCta8    CHAR(10);
    
    DEFINE vCuenta9             CHAR(16);
    DEFINE vTermCta9            CHAR(4);
    DEFINE vNombreCta9          CHAR(7);
    DEFINE vSdoDispCta9         DECIMAL(12,2);
    DEFINE vSdoCorteCta9        DECIMAL(12,2);
    DEFINE vPagoMinCta9         DECIMAL(12,2);
    DEFINE vPagoNoGenIntCta9    DECIMAL(12,2);
    DEFINE vFechaLimPagoCta9    CHAR(10);
    
    DEFINE vCuenta10            CHAR(16);
    DEFINE vTermCta10           CHAR(4);
    DEFINE vNombreCta10         CHAR(7);
    DEFINE vSdoDispCta10        DECIMAL(12,2);
    DEFINE vSdoCorteCta10       DECIMAL(12,2);
    DEFINE vPagoMinCta10        DECIMAL(12,2);
    DEFINE vPagoNoGenIntCta10   DECIMAL(12,2);
    DEFINE vFechaLimPagoCta10   CHAR(10);
    
    DEFINE vnumcte          CHAR(20);
    DEFINE vnumcel          CHAR(15);
    DEFINE vsecmax          INTEGER;
    DEFINE vid_oper         CHAR(4);
    DEFINE vcont            SMALLINT;
    DEFINE vcuenta          CHAR(20);
    DEFINE vsdo_disp        DECIMAL(12,2);
    DEFINE vprod            CHAR(7);
    DEFINE vnum_credito     CHAR(20);
    DEFINE vproducto        CHAR(4);
    DEFINE vnombre_prod     CHAR(7);
    DEFINE vnum_tarjeta     CHAR(16);
    DEFINE vsdo_corte       DECIMAL(12,2);
    DEFINE vpago_min        DECIMAL(12,2);
    DEFINE vpagonogenint    DECIMAL(12,2);
    DEFINE vfechlimpago     CHAR(10);
    
    DEFINE vcodret_dat      CHAR(6);
    DEFINE vmensaje_dat     CHAR(80);
    DEFINE vnum_credito_dat CHAR(20);
    DEFINE vnumcte_dat      CHAR(20);
    DEFINE vnombre_prod_dat CHAR(40);
    DEFINE vnum_tarjeta_dat CHAR(20);
    DEFINE vcliente_dat     CHAR(150);
    
    DEFINE vcodret_sdos             CHAR(6);
    DEFINE vmensaje_sdos            CHAR(80);
    DEFINE vnumcredito              CHAR(20);
    DEFINE vcodigo_tipcred          CHAR(2);
    DEFINE vfecha_origen            DATE;
    DEFINE vfecha_prox_pago         DATE;
    DEFINE vpago_minimo             DECIMAL(18,2);
    DEFINE vfecha_ult_pago          DATE;
    DEFINE vplazo                   INTEGER;
    DEFINE vpagos_realizados        INTEGER;
    DEFINE vlinea_otorgada          DECIMAL(18,2);
    DEFINE vtasa_interes            DECIMAL(9,6);
    DEFINE vtasa_moratorios         DECIMAL(9,6);
    DEFINE vmonto_sbc               DECIMAL(14,2);
    DEFINE vcap_vig                 DECIMAL(18,2);
    DEFINE vcap_trans               DECIMAL(18,2);
    DEFINE vcap_vdo_exig            DECIMAL(18,2);
    DEFINE vcap_vdo_no_exig         DECIMAL(18,2);
    DEFINE vsdo_act_total_cap       DECIMAL(18,2);
    DEFINE vint_vig                 DECIMAL(18,2);
    DEFINE vint_vdo                 DECIMAL(18,2);
    DEFINE vint_moratorios          DECIMAL(18,2);
    DEFINE vint_mes                 DECIMAL(18,2);
    DEFINE vsdo_act_total_int       DECIMAL(18,2);
    DEFINE viva_int_vig             DECIMAL(18,2);
    DEFINE viva_int_vdo             DECIMAL(18,2);
    DEFINE viva_int_moratorios      DECIMAL(18,2);
    DEFINE viva_int_mes             DECIMAL(18,2);
    DEFINE vsdo_act_total_iva       DECIMAL(18,2);
    DEFINE vcom_pend                DECIMAL(18,2);
    DEFINE viva_com                 DECIMAL(18,2);
    DEFINE vsdo_retenido            DECIMAL(18,2);
    DEFINE vtotal_liquidacion       DECIMAL(18,2);
    DEFINE vint_devengado           DECIMAL(18,2);
    DEFINE viva_int_devengado       DECIMAL(18,2);
    DEFINE vlinea_disponible        DECIMAL(18,2);
    DEFINE vpagos_vdos              DECIMAL(18,2);
    DEFINE vdesc_status_cred        CHAR(60);
    DEFINE vid_bloqueo_cred         INTEGER;
    DEFINE vbloqueo_cta             CHAR(60);
    DEFINE vid_causa_bloqueo_cred   CHAR(3);
    DEFINE vcausa_bloqueo_cta       CHAR(50);
    DEFINE vid_sit_esp_cte          CHAR(1);
    DEFINE vid_causa_esp_cte        INTEGER;
    DEFINE vsit_esp_cte             CHAR(75);
    DEFINE vid_sit_esp_cred         CHAR(1);
    DEFINE vid_causa_esp_cred       INTEGER;
    DEFINE vsit_esp_cred            CHAR(75);
    DEFINE vstatus_cred             CHAR(2);
    DEFINE vtransaccion             INTEGER;
    DEFINE vCodRetSdoCorte          CHAR(5);
    DEFINE vSdoAlCorte              DECIMAL(18,2);
    DEFINE vSdoNoGenInt             DECIMAL(18,2);
    --RQM 09 704. Se agregan las siguientes variable DFTL 
    DEFINE mSdoActual              MONEY(14,2);
    DEFINE mSdoRetenido        	   MONEY(14,2);
    DEFINE mSdoCongelado           MONEY(14,2);
    DEFINE mSaldoSbc               MONEY(14,2);
    DEFINE mImpChqSbg              MONEY(14,2); 
    DEFINE cCodRetConsSdo          CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo      CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '00000';
    LET vCodRet2     = '00000';
    LET vCodRet3     = '';
    LET vStatus      = '00';
    LET vStatusDesc  = '';

    LET vCuenta1          = '';
    LET vTermCta1         = '';
    LET vNombreCta1       = '';
    LET vSdoDispCta1      = 0.00;
    LET vSdoCorteCta1     = 0.00;
    LET vPagoMinCta1      = 0.00;
    LET vPagoNoGenIntCta1 = 0.00;
    LET vFechaLimPagoCta1 = '';
    
    LET vCuenta2          = '';
    LET vTermCta2         = '';
    LET vNombreCta2       = '';
    LET vSdoDispCta2      = 0.00;
    LET vSdoCorteCta2     = 0.00;
    LET vPagoMinCta2      = 0.00;
    LET vPagoNoGenIntCta2 = 0.00;
    LET vFechaLimPagoCta2 = '';
    
    LET vCuenta3          = '';
    LET vTermCta3         = '';
    LET vNombreCta3       = '';
    LET vSdoDispCta3      = 0.00;
    LET vSdoCorteCta3     = 0.00;
    LET vPagoMinCta3      = 0.00;
    LET vPagoNoGenIntCta3 = 0.00;
    LET vFechaLimPagoCta3 = '';
    
    LET vCuenta4          = '';
    LET vTermCta4         = '';
    LET vNombreCta4       = '';
    LET vSdoDispCta4      = 0.00;
    LET vSdoCorteCta4     = 0.00;
    LET vPagoMinCta4      = 0.00;
    LET vPagoNoGenIntCta4 = 0.00;
    LET vFechaLimPagoCta4 = '';
    
    LET vCuenta5          = '';
    LET vTermCta5         = '';
    LET vNombreCta5       = '';
    LET vSdoDispCta5      = 0.00;
    LET vSdoCorteCta5     = 0.00;
    LET vPagoMinCta5      = 0.00;
    LET vPagoNoGenIntCta5 = 0.00;
    LET vFechaLimPagoCta5 = '';
    
    LET vCuenta6          = '';
    LET vTermCta6         = '';
    LET vNombreCta6       = '';
    LET vSdoDispCta6      = 0.00;
    LET vSdoCorteCta6     = 0.00;
    LET vPagoMinCta6      = 0.00;
    LET vPagoNoGenIntCta6 = 0.00;
    LET vFechaLimPagoCta6 = '';
    
    LET vCuenta7          = '';
    LET vTermCta7         = '';
    LET vNombreCta7       = '';
    LET vSdoDispCta7      = 0.00;
    LET vSdoCorteCta7     = 0.00;
    LET vPagoMinCta7      = 0.00;
    LET vPagoNoGenIntCta7 = 0.00;
    LET vFechaLimPagoCta7 = '';
    
    LET vCuenta8          = '';
    LET vTermCta8         = '';
    LET vNombreCta8       = '';
    LET vSdoDispCta8      = 0.00;
    LET vSdoCorteCta8     = 0.00;
    LET vPagoMinCta8      = 0.00;
    LET vPagoNoGenIntCta8 = 0.00;
    LET vFechaLimPagoCta8 = '';
    
    LET vCuenta9          = '';
    LET vTermCta9         = '';
    LET vNombreCta9       = '';
    LET vSdoDispCta9      = 0.00;
    LET vSdoCorteCta9     = 0.00;
    LET vPagoMinCta9      = 0.00;
    LET vPagoNoGenIntCta9 = 0.00;
    LET vFechaLimPagoCta9 = '';
    
    LET vCuenta10          = '';
    LET vTermCta10         = '';
    LET vNombreCta10       = '';
    LET vSdoDispCta10      = 0.00;
    LET vSdoCorteCta10     = 0.00;
    LET vPagoMinCta10      = 0.00;
    LET vPagoNoGenIntCta10 = 0.00;
    LET vFechaLimPagoCta10 = '';
    
    LET vnumcte = '';
    LET vnumcel = '';
    LET vsecmax = 0;
    LET vid_oper = '';
    LET vcont = 0;
    LET vcuenta = '';
    LET vsdo_disp = 0.00;
    LET vprod = '';
    LET vnum_credito = '';
    LET vproducto = '';
    LET vnombre_prod = '';
    LET vnum_tarjeta = '';
    LET vsdo_corte = 0.00;
    LET vpago_min = 0.00;
    LET vpagonogenint = 0.00;
    LET vfechlimpago = '';
    
    LET vcodret_dat      = '';
    LET vmensaje_dat     = '';
    LET vnum_credito_dat = '';
    LET vnumcte_dat      = '';
    LET vnombre_prod_dat = '';
    LET vnum_tarjeta_dat = '';
    LET vcliente_dat     = '';
    
    LET vcodret_sdos           = '';
    LET vmensaje_sdos          = '';
    LET vnumcredito            = '';
    LET vcodigo_tipcred        = '';
    LET vfecha_origen          = '';
    LET vfecha_prox_pago       = '';
    LET vpago_minimo           = 0;
    LET vfecha_ult_pago        = '';
    LET vplazo                 = 0;
    LET vpagos_realizados      = 0;
    LET vlinea_otorgada        = 0;
    LET vtasa_interes          = 0;
    LET vtasa_moratorios       = 0;
    LET vmonto_sbc             = 0;
    LET vcap_vig               = 0;
    LET vcap_trans             = 0;
    LET vcap_vdo_exig          = 0;
    LET vcap_vdo_no_exig       = 0;
    LET vsdo_act_total_cap     = 0;
    LET vint_vig               = 0;
    LET vint_vdo               = 0;
    LET vint_moratorios        = 0;
    LET vint_mes               = 0;
    LET vsdo_act_total_int     = 0;
    LET viva_int_vig           = 0;
    LET viva_int_vdo           = 0;
    LET viva_int_moratorios    = 0;
    LET viva_int_mes           = 0;
    LET vsdo_act_total_iva     = 0;
    LET vcom_pend              = 0;
    LET viva_com               = 0;
    LET vsdo_retenido          = 0;
    LET vtotal_liquidacion     = 0;
    LET vint_devengado         = 0;
    LET viva_int_devengado     = 0;
    LET vlinea_disponible      = 0;
    LET vpagos_vdos            = 0;
    LET vdesc_status_cred      = '';
    LET vid_bloqueo_cred       = 0;
    LET vbloqueo_cta           = '';
    LET vid_causa_bloqueo_cred = '';
    LET vcausa_bloqueo_cta     = '';
    LET vid_sit_esp_cte        = '';
    LET vid_causa_esp_cte      = 0;
    LET vsit_esp_cte           = '';
    LET vid_sit_esp_cred       = '';
    LET vid_causa_esp_cred     = 0;
    LET vsit_esp_cred          = '';
    LET vstatus_cred           = '';
    LET vtransaccion           = 0;
    LET vCodRetSdoCorte        = '';
    LET vSdoAlCorte            = 0.00;
    LET vSdoNoGenInt           = 0.00;
    --RQM 09 704. Se agregan las siguientes variable DFTL
    LET mSdoActual         			= 0;
    LET mSdoRetenido           		= 0;
    LET mSdoCongelado          		= 0;
    LET mSaldoSbc           		= 0;
    LET mImpChqSbg      			= 0;
    LET cCodRetConsSdo      		= '00000';
    LET cMensajeRetConsSdo  		= '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_obten_lista_cuentas.err";
        --- TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vStatus, vStatusDesc, 
                   vCuenta1, vTermCta1, vNombreCta1, vSdoDispCta1, vSdoCorteCta1, vPagoMinCta1, vPagoNoGenIntCta1, vFechaLimPagoCta1,
                   vCuenta2, vTermCta2, vNombreCta2, vSdoDispCta2, vSdoCorteCta2, vPagoMinCta2, vPagoNoGenIntCta2, vFechaLimPagoCta2,
                   vCuenta3, vTermCta3, vNombreCta3, vSdoDispCta3, vSdoCorteCta3, vPagoMinCta3, vPagoNoGenIntCta3, vFechaLimPagoCta3,
                   vCuenta4, vTermCta4, vNombreCta4, vSdoDispCta4, vSdoCorteCta4, vPagoMinCta4, vPagoNoGenIntCta4, vFechaLimPagoCta4,
                   vCuenta5, vTermCta5, vNombreCta5, vSdoDispCta5, vSdoCorteCta5, vPagoMinCta5, vPagoNoGenIntCta5, vFechaLimPagoCta5,
                   vCuenta6, vTermCta6, vNombreCta6, vSdoDispCta6, vSdoCorteCta6, vPagoMinCta6, vPagoNoGenIntCta6, vFechaLimPagoCta6,
                   vCuenta7, vTermCta7, vNombreCta7, vSdoDispCta7, vSdoCorteCta7, vPagoMinCta7, vPagoNoGenIntCta7, vFechaLimPagoCta7,
                   vCuenta8, vTermCta8, vNombreCta8, vSdoDispCta8, vSdoCorteCta8, vPagoMinCta8, vPagoNoGenIntCta8, vFechaLimPagoCta8,
                   vCuenta9, vTermCta9, vNombreCta9, vSdoDispCta9, vSdoCorteCta9, vPagoMinCta9, vPagoNoGenIntCta9, vFechaLimPagoCta9,
                   vCuenta10, vTermCta10, vNombreCta10, vSdoDispCta10, vSdoCorteCta10, vPagoMinCta10, vPagoNoGenIntCta10, vFechaLimPagoCta10;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_obten_lista_cuentas.out";
    --- TRACE ON;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pSessionToken is null OR pSessionToken = 0) OR
       (pTipoCuenta is null OR pTipoCuenta = '') THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Error en aplicativo.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, 
               vCuenta1, vTermCta1, vNombreCta1, vSdoDispCta1, vSdoCorteCta1, vPagoMinCta1, vPagoNoGenIntCta1, vFechaLimPagoCta1,
               vCuenta2, vTermCta2, vNombreCta2, vSdoDispCta2, vSdoCorteCta2, vPagoMinCta2, vPagoNoGenIntCta2, vFechaLimPagoCta2,
               vCuenta3, vTermCta3, vNombreCta3, vSdoDispCta3, vSdoCorteCta3, vPagoMinCta3, vPagoNoGenIntCta3, vFechaLimPagoCta3,
               vCuenta4, vTermCta4, vNombreCta4, vSdoDispCta4, vSdoCorteCta4, vPagoMinCta4, vPagoNoGenIntCta4, vFechaLimPagoCta4,
               vCuenta5, vTermCta5, vNombreCta5, vSdoDispCta5, vSdoCorteCta5, vPagoMinCta5, vPagoNoGenIntCta5, vFechaLimPagoCta5,
               vCuenta6, vTermCta6, vNombreCta6, vSdoDispCta6, vSdoCorteCta6, vPagoMinCta6, vPagoNoGenIntCta6, vFechaLimPagoCta6,
               vCuenta7, vTermCta7, vNombreCta7, vSdoDispCta7, vSdoCorteCta7, vPagoMinCta7, vPagoNoGenIntCta7, vFechaLimPagoCta7,
               vCuenta8, vTermCta8, vNombreCta8, vSdoDispCta8, vSdoCorteCta8, vPagoMinCta8, vPagoNoGenIntCta8, vFechaLimPagoCta8,
               vCuenta9, vTermCta9, vNombreCta9, vSdoDispCta9, vSdoCorteCta9, vPagoMinCta9, vPagoNoGenIntCta9, vFechaLimPagoCta9,
               vCuenta10, vTermCta10, vNombreCta10, vSdoDispCta10, vSdoCorteCta10, vPagoMinCta10, vPagoNoGenIntCta10, vFechaLimPagoCta10;
    END IF;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE MAXIMA SECUENCIA DEL CLIENTE EN LA BITACORA
    SELECT MAX(secuencia)
      INTO vsecmax
      FROM bdinteg:"informix".si_bm_bitacora
     WHERE DATE(fech_oper) = CURRENT::DATE
       AND id_session = pSessionToken;
       
    IF vsecmax is null THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario no firmado.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, 
               vCuenta1, vTermCta1, vNombreCta1, vSdoDispCta1, vSdoCorteCta1, vPagoMinCta1, vPagoNoGenIntCta1, vFechaLimPagoCta1,
               vCuenta2, vTermCta2, vNombreCta2, vSdoDispCta2, vSdoCorteCta2, vPagoMinCta2, vPagoNoGenIntCta2, vFechaLimPagoCta2,
               vCuenta3, vTermCta3, vNombreCta3, vSdoDispCta3, vSdoCorteCta3, vPagoMinCta3, vPagoNoGenIntCta3, vFechaLimPagoCta3,
               vCuenta4, vTermCta4, vNombreCta4, vSdoDispCta4, vSdoCorteCta4, vPagoMinCta4, vPagoNoGenIntCta4, vFechaLimPagoCta4,
               vCuenta5, vTermCta5, vNombreCta5, vSdoDispCta5, vSdoCorteCta5, vPagoMinCta5, vPagoNoGenIntCta5, vFechaLimPagoCta5,
               vCuenta6, vTermCta6, vNombreCta6, vSdoDispCta6, vSdoCorteCta6, vPagoMinCta6, vPagoNoGenIntCta6, vFechaLimPagoCta6,
               vCuenta7, vTermCta7, vNombreCta7, vSdoDispCta7, vSdoCorteCta7, vPagoMinCta7, vPagoNoGenIntCta7, vFechaLimPagoCta7,
               vCuenta8, vTermCta8, vNombreCta8, vSdoDispCta8, vSdoCorteCta8, vPagoMinCta8, vPagoNoGenIntCta8, vFechaLimPagoCta8,
               vCuenta9, vTermCta9, vNombreCta9, vSdoDispCta9, vSdoCorteCta9, vPagoMinCta9, vPagoNoGenIntCta9, vFechaLimPagoCta9,
               vCuenta10, vTermCta10, vNombreCta10, vSdoDispCta10, vSdoCorteCta10, vPagoMinCta10, vPagoNoGenIntCta10, vFechaLimPagoCta10;
    END IF;
       
    SELECT id_oper, numcte, numcel
      INTO vid_oper, vnumcte, vnumcel
      FROM bdinteg:"informix".si_bm_bitacora
     WHERE DATE(fech_oper) = CURRENT::DATE
       AND id_session = pSessionToken
       AND secuencia = vsecmax;
       
    IF vid_oper is null OR vid_oper = '' THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario no firmado.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, 
               vCuenta1, vTermCta1, vNombreCta1, vSdoDispCta1, vSdoCorteCta1, vPagoMinCta1, vPagoNoGenIntCta1, vFechaLimPagoCta1,
               vCuenta2, vTermCta2, vNombreCta2, vSdoDispCta2, vSdoCorteCta2, vPagoMinCta2, vPagoNoGenIntCta2, vFechaLimPagoCta2,
               vCuenta3, vTermCta3, vNombreCta3, vSdoDispCta3, vSdoCorteCta3, vPagoMinCta3, vPagoNoGenIntCta3, vFechaLimPagoCta3,
               vCuenta4, vTermCta4, vNombreCta4, vSdoDispCta4, vSdoCorteCta4, vPagoMinCta4, vPagoNoGenIntCta4, vFechaLimPagoCta4,
               vCuenta5, vTermCta5, vNombreCta5, vSdoDispCta5, vSdoCorteCta5, vPagoMinCta5, vPagoNoGenIntCta5, vFechaLimPagoCta5,
               vCuenta6, vTermCta6, vNombreCta6, vSdoDispCta6, vSdoCorteCta6, vPagoMinCta6, vPagoNoGenIntCta6, vFechaLimPagoCta6,
               vCuenta7, vTermCta7, vNombreCta7, vSdoDispCta7, vSdoCorteCta7, vPagoMinCta7, vPagoNoGenIntCta7, vFechaLimPagoCta7,
               vCuenta8, vTermCta8, vNombreCta8, vSdoDispCta8, vSdoCorteCta8, vPagoMinCta8, vPagoNoGenIntCta8, vFechaLimPagoCta8,
               vCuenta9, vTermCta9, vNombreCta9, vSdoDispCta9, vSdoCorteCta9, vPagoMinCta9, vPagoNoGenIntCta9, vFechaLimPagoCta9,
               vCuenta10, vTermCta10, vNombreCta10, vSdoDispCta10, vSdoCorteCta10, vPagoMinCta10, vPagoNoGenIntCta10, vFechaLimPagoCta10;
    END IF;   
    
    IF vid_oper = '1001' THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario no firmado.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, 
               vCuenta1, vTermCta1, vNombreCta1, vSdoDispCta1, vSdoCorteCta1, vPagoMinCta1, vPagoNoGenIntCta1, vFechaLimPagoCta1,
               vCuenta2, vTermCta2, vNombreCta2, vSdoDispCta2, vSdoCorteCta2, vPagoMinCta2, vPagoNoGenIntCta2, vFechaLimPagoCta2,
               vCuenta3, vTermCta3, vNombreCta3, vSdoDispCta3, vSdoCorteCta3, vPagoMinCta3, vPagoNoGenIntCta3, vFechaLimPagoCta3,
               vCuenta4, vTermCta4, vNombreCta4, vSdoDispCta4, vSdoCorteCta4, vPagoMinCta4, vPagoNoGenIntCta4, vFechaLimPagoCta4,
               vCuenta5, vTermCta5, vNombreCta5, vSdoDispCta5, vSdoCorteCta5, vPagoMinCta5, vPagoNoGenIntCta5, vFechaLimPagoCta5,
               vCuenta6, vTermCta6, vNombreCta6, vSdoDispCta6, vSdoCorteCta6, vPagoMinCta6, vPagoNoGenIntCta6, vFechaLimPagoCta6,
               vCuenta7, vTermCta7, vNombreCta7, vSdoDispCta7, vSdoCorteCta7, vPagoMinCta7, vPagoNoGenIntCta7, vFechaLimPagoCta7,
               vCuenta8, vTermCta8, vNombreCta8, vSdoDispCta8, vSdoCorteCta8, vPagoMinCta8, vPagoNoGenIntCta8, vFechaLimPagoCta8,
               vCuenta9, vTermCta9, vNombreCta9, vSdoDispCta9, vSdoCorteCta9, vPagoMinCta9, vPagoNoGenIntCta9, vFechaLimPagoCta9,
               vCuenta10, vTermCta10, vNombreCta10, vSdoDispCta10, vSdoCorteCta10, vPagoMinCta10, vPagoNoGenIntCta10, vFechaLimPagoCta10;
    END IF;
    
    IF vid_oper IN('1000', '1002', '1003', '1004', '1005') THEN
    
        -- // OBTIENE INFORMACION DE LAS CUENTAS DE DEBITO
        IF pTipoCuenta = 'DEBITO' THEN
        
            LET vcont = 1;
            
            FOREACH
                SELECT mae.cuenta, mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, mae.producto, mae.saldo_sbc
                  INTO vcuenta, mSdoActual, mSdoRetenido, mSdoCongelado, mImpChqSbg, vprod, mSaldoSbc
                  FROM bdicheq:"informix".sc_maechq mae
                 WHERE mae.num_cte = vnumcte
                   AND mae.status_cta <> '2'
                   AND mae.producto NOT IN('2300')
                 ORDER BY mae.cuenta

                --RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL
			    EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCongelado, mSaldoSbc, mImpChqSbg, null, null, 'F', 1)
				INTO cCodRetConsSdo, cMensajeRetConsSdo, vsdo_disp;
                 
                SELECT nombre
                  INTO vnombre_prod
                  FROM bdinteg:"informix".si_bm_productos
                 WHERE producto = vprod;
                 
                IF vcont = 1 THEN
                    LET vCuenta1          = vcuenta;
                    LET vTermCta1         = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
                    LET vNombreCta1       = vnombre_prod;
                    LET vSdoDispCta1      = vsdo_disp;
                    LET vSdoCorteCta1     = 0.00;
                    LET vPagoMinCta1      = 0.00;
                    LET vPagoNoGenIntCta1 = 0.00;
                    LET vFechaLimPagoCta1 = ' ';
                ELIF vcont = 2 THEN
                    LET vCuenta2          = vcuenta;
                    LET vTermCta2         = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
                    LET vNombreCta2       = vnombre_prod;
                    LET vSdoDispCta2      = vsdo_disp;
                    LET vSdoCorteCta2     = 0.00;
                    LET vPagoMinCta2      = 0.00;
                    LET vPagoNoGenIntCta2 = 0.00;
                    LET vFechaLimPagoCta2 = ' ';
                ELIF vcont = 3 THEN
                    LET vCuenta3          = vcuenta;
                    LET vTermCta3         = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
                    LET vNombreCta3       = vnombre_prod;
                    LET vSdoDispCta3      = vsdo_disp;
                    LET vSdoCorteCta3     = 0.00;
                    LET vPagoMinCta3      = 0.00;
                    LET vPagoNoGenIntCta3 = 0.00;
                    LET vFechaLimPagoCta3 = ' ';
                ELIF vcont = 4 THEN
                    LET vCuenta4          = vcuenta;
                    LET vTermCta4         = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
                    LET vNombreCta4       = vnombre_prod;
                    LET vSdoDispCta4      = vsdo_disp;
                    LET vSdoCorteCta4     = 0.00;
                    LET vPagoMinCta4      = 0.00;
                    LET vPagoNoGenIntCta4 = 0.00;
                    LET vFechaLimPagoCta4 = ' ';
                ELIF vcont = 5 THEN
                    LET vCuenta5          = vcuenta;
                    LET vTermCta5         = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
                    LET vNombreCta5       = vnombre_prod;
                    LET vSdoDispCta5      = vsdo_disp;
                    LET vSdoCorteCta5     = 0.00;
                    LET vPagoMinCta5      = 0.00;
                    LET vPagoNoGenIntCta5 = 0.00;
                    LET vFechaLimPagoCta5 = ' ';
                ELIF vcont = 6 THEN
                    LET vCuenta6          = vcuenta;
                    LET vTermCta6         = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
                    LET vNombreCta6       = vnombre_prod;
                    LET vSdoDispCta6      = vsdo_disp;
                    LET vSdoCorteCta6     = 0.00;
                    LET vPagoMinCta6      = 0.00;
                    LET vPagoNoGenIntCta6 = 0.00;
                    LET vFechaLimPagoCta6 = ' ';
                ELIF vcont = 7 THEN
                    LET vCuenta7          = vcuenta;
                    LET vTermCta7         = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
                    LET vNombreCta7       = vnombre_prod;
                    LET vSdoDispCta7      = vsdo_disp;
                    LET vSdoCorteCta7     = 0.00;
                    LET vPagoMinCta7      = 0.00;
                    LET vPagoNoGenIntCta7 = 0.00;
                    LET vFechaLimPagoCta7 = ' ';
                ELIF vcont = 8 THEN
                    LET vCuenta8          = vcuenta;
                    LET vTermCta8         = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
                    LET vNombreCta8       = vnombre_prod;
                    LET vSdoDispCta8      = vsdo_disp;
                    LET vSdoCorteCta8     = 0.00;
                    LET vPagoMinCta8      = 0.00;
                    LET vPagoNoGenIntCta8 = 0.00;
                    LET vFechaLimPagoCta8 = ' ';
                ELIF vcont = 9 THEN
                    LET vCuenta9          = vcuenta;
                    LET vTermCta9         = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
                    LET vNombreCta9       = vnombre_prod;
                    LET vSdoDispCta9      = vsdo_disp;
                    LET vSdoCorteCta9     = 0.00;
                    LET vPagoMinCta9      = 0.00;
                    LET vPagoNoGenIntCta9 = 0.00;
                    LET vFechaLimPagoCta9 = ' ';
                ELIF vcont = 10 THEN
                    LET vCuenta10          = vcuenta;
                    LET vTermCta10         = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
                    LET vNombreCta10       = vnombre_prod;
                    LET vSdoDispCta10      = vsdo_disp;
                    LET vSdoCorteCta10     = 0.00;
                    LET vPagoMinCta10      = 0.00;
                    LET vPagoNoGenIntCta10 = 0.00;
                    LET vFechaLimPagoCta10 = ' ';            
                END IF;
                
                LET vcont = vcont + 1;
                
                IF vcont >= 10 THEN
                    EXIT FOREACH;
                END IF;
                
                LET vcuenta = '';
                LET vsdo_disp = 0.00;
                LET vprod = '';
                LET vnombre_prod = '';
            END FOREACH;
        
            -- // GENERA REGISTRO EN BITACORA 
            SELECT MAX(secuencia)
              INTO vsecmax
              FROM bdinteg:"informix".si_bm_bitacora
             WHERE DATE(fech_oper) = CURRENT::DATE
               AND id_session = pSessionToken;
               
            LET vsecmax = vsecmax + 1;
            
            INSERT INTO bdinteg:"informix".si_bm_bitacora(id_session, fech_oper, numcte, secuencia, id_oper, numcel, cuenta, foliosol)
            VALUES(pSessionToken, current, vnumcte, vsecmax, '1002', vnumcel, null, null);
            
            IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                LET vCodRet1 = '11111';
                LET vStatus = '';
                LET vStatusDesc = 'Error en aplicativo.';
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                RETURN vCodRet1, vStatus, vStatusDesc, 
                       vCuenta1, vTermCta1, vNombreCta1, vSdoDispCta1, vSdoCorteCta1, vPagoMinCta1, vPagoNoGenIntCta1, vFechaLimPagoCta1,
                       vCuenta2, vTermCta2, vNombreCta2, vSdoDispCta2, vSdoCorteCta2, vPagoMinCta2, vPagoNoGenIntCta2, vFechaLimPagoCta2,
                       vCuenta3, vTermCta3, vNombreCta3, vSdoDispCta3, vSdoCorteCta3, vPagoMinCta3, vPagoNoGenIntCta3, vFechaLimPagoCta3,
                       vCuenta4, vTermCta4, vNombreCta4, vSdoDispCta4, vSdoCorteCta4, vPagoMinCta4, vPagoNoGenIntCta4, vFechaLimPagoCta4,
                       vCuenta5, vTermCta5, vNombreCta5, vSdoDispCta5, vSdoCorteCta5, vPagoMinCta5, vPagoNoGenIntCta5, vFechaLimPagoCta5,
                       vCuenta6, vTermCta6, vNombreCta6, vSdoDispCta6, vSdoCorteCta6, vPagoMinCta6, vPagoNoGenIntCta6, vFechaLimPagoCta6,
                       vCuenta7, vTermCta7, vNombreCta7, vSdoDispCta7, vSdoCorteCta7, vPagoMinCta7, vPagoNoGenIntCta7, vFechaLimPagoCta7,
                       vCuenta8, vTermCta8, vNombreCta8, vSdoDispCta8, vSdoCorteCta8, vPagoMinCta8, vPagoNoGenIntCta8, vFechaLimPagoCta8,
                       vCuenta9, vTermCta9, vNombreCta9, vSdoDispCta9, vSdoCorteCta9, vPagoMinCta9, vPagoNoGenIntCta9, vFechaLimPagoCta9,
                       vCuenta10, vTermCta10, vNombreCta10, vSdoDispCta10, vSdoCorteCta10, vPagoMinCta10, vPagoNoGenIntCta10, vFechaLimPagoCta10;
            END IF;
            
        ELIF pTipoCuenta = 'CREDITO' THEN
        
            LET vcont = 1;
            
            FOREACH
                EXECUTE PROCEDURE bdicred:"informix".sp_consulta_datos_general('001', vnumcte, '', '', '', '', '')
                INTO vcodret_dat, vmensaje_dat, vnum_credito_dat, vnumcte_dat, vnombre_prod_dat, vnum_tarjeta_dat, vcliente_dat
                
                IF vcodret_dat <> '000000' OR vnum_credito_dat is null OR vnum_credito_dat = '' THEN 
                    CONTINUE FOREACH;
                END IF;
                
                -- // OBTIENE EL NUMERO DE TARJETA O CREDITO
                LET vnum_credito = vnum_credito_dat;
                LET vnum_tarjeta = vnum_tarjeta_dat;
                
                IF vnum_tarjeta is null OR vnum_tarjeta = '' THEN
                    LET vnum_tarjeta = vnum_credito;
                END IF;
                
                -- // VALIDA EL STATUS DEL CREDITO Y OBTIENE EL TIPO DE PRODUCTO
                SELECT status_cred, num_producto
                  INTO vstatus_cred, vproducto
                  FROM bdicred:"informix".sd_maecred
                 WHERE num_credito = vnum_credito;
                 
                IF (vstatus_cred is null OR vstatus_cred = '') OR 
                   (vproducto is null OR vproducto = '') THEN
                    SELECT status_cred, num_producto
                      INTO vstatus_cred, vproducto
                      FROM bdicred:"informix".sd_maecredcrd
                     WHERE num_credito = vnum_credito
                       AND empresa = '001';
                END IF;
                
				--IFRS Se modifica estatus por etapas
                --IF vstatus_cred is null OR vstatus_cred = '' OR vstatus_cred NOT IN('AA','BA','BT','VP') THEN
				IF vstatus_cred is null OR vstatus_cred = '' OR vstatus_cred NOT IN('AA','BA','BT','VP','E1','E2','E3') THEN
                    CONTINUE FOREACH;
                END IF;
                 
                SELECT nombre
                  INTO vnombre_prod
                  FROM bdinteg:"informix".si_bm_productos
                 WHERE producto = vproducto;
                
                -- // OBTIENE LOS SALDOS DEL CREDITO 
                EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general('001', vnum_credito)
                INTO vcodret_sdos, vmensaje_sdos, vnumcredito, vcodigo_tipcred, vfecha_origen, vfecha_prox_pago, 
                     vpago_minimo, vfecha_ult_pago, vplazo, vpagos_realizados, vlinea_otorgada, vtasa_interes,
                     vtasa_moratorios, vmonto_sbc, vcap_vig, vcap_trans, vcap_vdo_exig, vcap_vdo_no_exig, vsdo_act_total_cap,
                     vint_vig, vint_vdo, vint_moratorios, vint_mes, vsdo_act_total_int, viva_int_vig, viva_int_vdo, viva_int_moratorios,
                     viva_int_mes, vsdo_act_total_iva, vcom_pend, viva_com, vsdo_retenido, vtotal_liquidacion, vint_devengado, viva_int_devengado, 
                     vlinea_disponible, vpagos_vdos, vdesc_status_cred, vid_bloqueo_cred, vbloqueo_cta, vid_causa_bloqueo_cred, vcausa_bloqueo_cta, 
                     vid_sit_esp_cte, vid_causa_esp_cte, vsit_esp_cte, vid_sit_esp_cred, vid_causa_esp_cred, vsit_esp_cred;
                         
                -- // SALDO DISPONIBLE AL DIA DE HOY
                LET vsdo_disp = vtotal_liquidacion;
                
                IF vsdo_disp is null OR vsdo_disp < 0.00 THEN 
                    LET vsdo_disp = 0.00; 
                END IF;
                
                -- // SALDO AL CORTE
                EXECUTE PROCEDURE bdicred:"informix".sp_consultasaldocorte('001', vnum_credito, 1)
                INTO vCodRetSdoCorte, vSdoAlCorte;
                
                LET vsdo_corte = vlinea_disponible;
                
                IF vsdo_corte is null OR vsdo_corte < 0 THEN
                    LET vsdo_corte = 0.00;
                END IF;
                
                -- // PAGO MINIMO
                LET vpago_min = vpago_minimo;
                
                IF vpago_min < 0 THEN 
                    LET vpago_min = 0.00; 
                END IF;
                
                -- // PAGO PARA NO GENERAR INTERESES
                EXECUTE PROCEDURE bdicred:"informix".sp_consultasaldocorte('001', vnum_credito, 0)
                INTO vCodRetSdoCorte, vSdoNoGenInt;
                
                LET vpagonogenint = vSdoNoGenInt;
                
                IF vpagonogenint is null THEN 
                    LET vpagonogenint = 0.00; 
                END IF;
                
                -- // FECHA LIMITE DE PAGO 
                LET vfechlimpago = TO_CHAR(vfecha_prox_pago, '%d/%m/%Y');
                                 
                IF vcont = 1 THEN 
                    LET vCuenta1          = vnum_tarjeta;
                    LET vTermCta1         = SUBSTR(vnum_tarjeta,LENGTH(vnum_tarjeta)-3,4);
                    LET vNombreCta1       = vnombre_prod;
                    LET vSdoDispCta1      = vsdo_disp;
                    LET vSdoCorteCta1     = vsdo_corte;
                    LET vPagoMinCta1      = vpago_min;
                    LET vPagoNoGenIntCta1 = vpagonogenint;
                    LET vFechaLimPagoCta1 = vfechlimpago;
                ELIF vcont = 2 THEN
                    LET vCuenta2          = vnum_tarjeta;
                    LET vTermCta2         = SUBSTR(vnum_tarjeta,LENGTH(vnum_tarjeta)-3,4);
                    LET vNombreCta2       = vnombre_prod;
                    LET vSdoDispCta2      = vsdo_disp;
                    LET vSdoCorteCta2     = vsdo_corte;
                    LET vPagoMinCta2      = vpago_min;
                    LET vPagoNoGenIntCta2 = vpagonogenint;
                    LET vFechaLimPagoCta2 = vfechlimpago;
                ELIF vcont = 3 THEN
                    LET vCuenta3          = vnum_tarjeta;
                    LET vTermCta3         = SUBSTR(vnum_tarjeta,LENGTH(vnum_tarjeta)-3,4);
                    LET vNombreCta3       = vnombre_prod;
                    LET vSdoDispCta3      = vsdo_disp;
                    LET vSdoCorteCta3     = vsdo_corte;
                    LET vPagoMinCta3      = vpago_min;
                    LET vPagoNoGenIntCta3 = vpagonogenint;
                    LET vFechaLimPagoCta3 = vfechlimpago;
                ELIF vcont = 4 THEN
                    LET vCuenta4          = vnum_tarjeta;
                    LET vTermCta4         = SUBSTR(vnum_tarjeta,LENGTH(vnum_tarjeta)-3,4);
                    LET vNombreCta4       = vnombre_prod;
                    LET vSdoDispCta4      = vsdo_disp;
                    LET vSdoCorteCta4     = vsdo_corte;
                    LET vPagoMinCta4      = vpago_min;
                    LET vPagoNoGenIntCta4 = vpagonogenint;
                    LET vFechaLimPagoCta4 = vfechlimpago;
                ELIF vcont = 5 THEN
                    LET vCuenta5          = vnum_tarjeta;
                    LET vTermCta5         = SUBSTR(vnum_tarjeta,LENGTH(vnum_tarjeta)-3,4);
                    LET vNombreCta5       = vnombre_prod;
                    LET vSdoDispCta5      = vsdo_disp;
                    LET vSdoCorteCta5     = vsdo_corte;
                    LET vPagoMinCta5      = vpago_min;
                    LET vPagoNoGenIntCta5 = vpagonogenint;
                    LET vFechaLimPagoCta5 = vfechlimpago;
                ELIF vcont = 6 THEN
                    LET vCuenta6          = vnum_tarjeta;
                    LET vTermCta6         = SUBSTR(vnum_tarjeta,LENGTH(vnum_tarjeta)-3,4);
                    LET vNombreCta6       = vnombre_prod;
                    LET vSdoDispCta6      = vsdo_disp;
                    LET vSdoCorteCta6     = vsdo_corte;
                    LET vPagoMinCta6      = vpago_min;
                    LET vPagoNoGenIntCta6 = vpagonogenint;
                    LET vFechaLimPagoCta6 = vfechlimpago;
                ELIF vcont = 7 THEN
                    LET vCuenta7          = vnum_tarjeta;
                    LET vTermCta7         = SUBSTR(vnum_tarjeta,LENGTH(vnum_tarjeta)-3,4);
                    LET vNombreCta7       = vnombre_prod;
                    LET vSdoDispCta7      = vsdo_disp;
                    LET vSdoCorteCta7     = vsdo_corte;
                    LET vPagoMinCta7      = vpago_min;
                    LET vPagoNoGenIntCta7 = vpagonogenint;
                    LET vFechaLimPagoCta7 = vfechlimpago;
                ELIF vcont = 8 THEN
                    LET vCuenta8          = vnum_tarjeta;
                    LET vTermCta8         = SUBSTR(vnum_tarjeta,LENGTH(vnum_tarjeta)-3,4);
                    LET vNombreCta8       = vnombre_prod;
                    LET vSdoDispCta8      = vsdo_disp;
                    LET vSdoCorteCta8     = vsdo_corte;
                    LET vPagoMinCta8      = vpago_min;
                    LET vPagoNoGenIntCta8 = vpagonogenint;
                    LET vFechaLimPagoCta8 = vfechlimpago;
                ELIF vcont = 9 THEN
                    LET vCuenta9          = vnum_tarjeta;
                    LET vTermCta9         = SUBSTR(vnum_tarjeta,LENGTH(vnum_tarjeta)-3,4);
                    LET vNombreCta9       = vnombre_prod;
                    LET vSdoDispCta9      = vsdo_disp;
                    LET vSdoCorteCta9     = vsdo_corte;
                    LET vPagoMinCta9      = vpago_min;
                    LET vPagoNoGenIntCta9 = vpagonogenint;
                    LET vFechaLimPagoCta9 = vfechlimpago;
                ELIF vcont = 10 THEN
                    LET vCuenta10          = vnum_tarjeta;
                    LET vTermCta10         = SUBSTR(vnum_tarjeta,LENGTH(vnum_tarjeta)-3,4);
                    LET vNombreCta10       = vnombre_prod;
                    LET vSdoDispCta10      = vsdo_disp;
                    LET vSdoCorteCta10     = vsdo_corte;
                    LET vPagoMinCta10      = vpago_min;
                    LET vPagoNoGenIntCta10 = vpagonogenint;
                    LET vFechaLimPagoCta10 = vfechlimpago;            
                END IF;
                
                LET vcont = vcont + 1;
                
                IF vcont >= 10 THEN
                    EXIT FOREACH;
                END IF;
                
                LET vnum_credito = '';
                LET vproducto = '';
                LET vnombre_prod = '';
                LET vnum_tarjeta = '';
                LET vsdo_disp = 0.00;
                LET vsdo_corte = 0.00;
                LET vpago_min = 0.00;
                LET vpagonogenint = 0.00;
                LET vfechlimpago = '';
                LET vstatus_cred = '';
            END FOREACH;
            
            -- // GENERA REGISTRO EN BITACORA 
            SELECT MAX(secuencia)
              INTO vsecmax
              FROM bdinteg:"informix".si_bm_bitacora
             WHERE DATE(fech_oper) = CURRENT::DATE
               AND id_session = pSessionToken;
               
            LET vsecmax = vsecmax + 1;
            
            INSERT INTO bdinteg:"informix".si_bm_bitacora(id_session, fech_oper, numcte, secuencia, id_oper, numcel, cuenta, foliosol)
            VALUES(pSessionToken, current, vnumcte, vsecmax, '1003', vnumcel, null, null);
            
            IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                LET vCodRet1 = '11111';
                LET vStatus = '';
                LET vStatusDesc = 'Error en aplicativo.';
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                RETURN vCodRet1, vStatus, vStatusDesc, 
                       vCuenta1, vTermCta1, vNombreCta1, vSdoDispCta1, vSdoCorteCta1, vPagoMinCta1, vPagoNoGenIntCta1, vFechaLimPagoCta1,
                       vCuenta2, vTermCta2, vNombreCta2, vSdoDispCta2, vSdoCorteCta2, vPagoMinCta2, vPagoNoGenIntCta2, vFechaLimPagoCta2,
                       vCuenta3, vTermCta3, vNombreCta3, vSdoDispCta3, vSdoCorteCta3, vPagoMinCta3, vPagoNoGenIntCta3, vFechaLimPagoCta3,
                       vCuenta4, vTermCta4, vNombreCta4, vSdoDispCta4, vSdoCorteCta4, vPagoMinCta4, vPagoNoGenIntCta4, vFechaLimPagoCta4,
                       vCuenta5, vTermCta5, vNombreCta5, vSdoDispCta5, vSdoCorteCta5, vPagoMinCta5, vPagoNoGenIntCta5, vFechaLimPagoCta5,
                       vCuenta6, vTermCta6, vNombreCta6, vSdoDispCta6, vSdoCorteCta6, vPagoMinCta6, vPagoNoGenIntCta6, vFechaLimPagoCta6,
                       vCuenta7, vTermCta7, vNombreCta7, vSdoDispCta7, vSdoCorteCta7, vPagoMinCta7, vPagoNoGenIntCta7, vFechaLimPagoCta7,
                       vCuenta8, vTermCta8, vNombreCta8, vSdoDispCta8, vSdoCorteCta8, vPagoMinCta8, vPagoNoGenIntCta8, vFechaLimPagoCta8,
                       vCuenta9, vTermCta9, vNombreCta9, vSdoDispCta9, vSdoCorteCta9, vPagoMinCta9, vPagoNoGenIntCta9, vFechaLimPagoCta9,
                       vCuenta10, vTermCta10, vNombreCta10, vSdoDispCta10, vSdoCorteCta10, vPagoMinCta10, vPagoNoGenIntCta10, vFechaLimPagoCta10;
            END IF;
        END IF;
    ELSE
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario no firmado.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, 
               vCuenta1, vTermCta1, vNombreCta1, vSdoDispCta1, vSdoCorteCta1, vPagoMinCta1, vPagoNoGenIntCta1, vFechaLimPagoCta1,
               vCuenta2, vTermCta2, vNombreCta2, vSdoDispCta2, vSdoCorteCta2, vPagoMinCta2, vPagoNoGenIntCta2, vFechaLimPagoCta2,
               vCuenta3, vTermCta3, vNombreCta3, vSdoDispCta3, vSdoCorteCta3, vPagoMinCta3, vPagoNoGenIntCta3, vFechaLimPagoCta3,
               vCuenta4, vTermCta4, vNombreCta4, vSdoDispCta4, vSdoCorteCta4, vPagoMinCta4, vPagoNoGenIntCta4, vFechaLimPagoCta4,
               vCuenta5, vTermCta5, vNombreCta5, vSdoDispCta5, vSdoCorteCta5, vPagoMinCta5, vPagoNoGenIntCta5, vFechaLimPagoCta5,
               vCuenta6, vTermCta6, vNombreCta6, vSdoDispCta6, vSdoCorteCta6, vPagoMinCta6, vPagoNoGenIntCta6, vFechaLimPagoCta6,
               vCuenta7, vTermCta7, vNombreCta7, vSdoDispCta7, vSdoCorteCta7, vPagoMinCta7, vPagoNoGenIntCta7, vFechaLimPagoCta7,
               vCuenta8, vTermCta8, vNombreCta8, vSdoDispCta8, vSdoCorteCta8, vPagoMinCta8, vPagoNoGenIntCta8, vFechaLimPagoCta8,
               vCuenta9, vTermCta9, vNombreCta9, vSdoDispCta9, vSdoCorteCta9, vPagoMinCta9, vPagoNoGenIntCta9, vFechaLimPagoCta9,
               vCuenta10, vTermCta10, vNombreCta10, vSdoDispCta10, vSdoCorteCta10, vPagoMinCta10, vPagoNoGenIntCta10, vFechaLimPagoCta10;
    END IF;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;

    RETURN vCodRet1, vStatus, vStatusDesc, 
           vCuenta1, vTermCta1, vNombreCta1, vSdoDispCta1, vSdoCorteCta1, vPagoMinCta1, vPagoNoGenIntCta1, vFechaLimPagoCta1,
           vCuenta2, vTermCta2, vNombreCta2, vSdoDispCta2, vSdoCorteCta2, vPagoMinCta2, vPagoNoGenIntCta2, vFechaLimPagoCta2,
           vCuenta3, vTermCta3, vNombreCta3, vSdoDispCta3, vSdoCorteCta3, vPagoMinCta3, vPagoNoGenIntCta3, vFechaLimPagoCta3,
           vCuenta4, vTermCta4, vNombreCta4, vSdoDispCta4, vSdoCorteCta4, vPagoMinCta4, vPagoNoGenIntCta4, vFechaLimPagoCta4,
           vCuenta5, vTermCta5, vNombreCta5, vSdoDispCta5, vSdoCorteCta5, vPagoMinCta5, vPagoNoGenIntCta5, vFechaLimPagoCta5,
           vCuenta6, vTermCta6, vNombreCta6, vSdoDispCta6, vSdoCorteCta6, vPagoMinCta6, vPagoNoGenIntCta6, vFechaLimPagoCta6,
           vCuenta7, vTermCta7, vNombreCta7, vSdoDispCta7, vSdoCorteCta7, vPagoMinCta7, vPagoNoGenIntCta7, vFechaLimPagoCta7,
           vCuenta8, vTermCta8, vNombreCta8, vSdoDispCta8, vSdoCorteCta8, vPagoMinCta8, vPagoNoGenIntCta8, vFechaLimPagoCta8,
           vCuenta9, vTermCta9, vNombreCta9, vSdoDispCta9, vSdoCorteCta9, vPagoMinCta9, vPagoNoGenIntCta9, vFechaLimPagoCta9,
           vCuenta10, vTermCta10, vNombreCta10, vSdoDispCta10, vSdoCorteCta10, vPagoMinCta10, vPagoNoGenIntCta10, vFechaLimPagoCta10;
    
    END;
    
END PROCEDURE
DOCUMENT
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/09',
'RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdinteg',
'VER:                   1.2';

CREATE PROCEDURE "informix".sp_alta_solicitud_movil_online_pba_1_jlh(
pproductos         	CHAR(120),
pnumcte            	CHAR(20),
pap_nombre1        	CHAR(26),
pap_nombre2        	CHAR(26),
pap_apell_paterno  	CHAR(26),
pap_apell_materno  	CHAR(26),
pap_sexo           	CHAR(1),
pap_fecha_nac      	CHAR(10),
pap_rfc            	CHAR(13),
pemail             	CHAR(100),
ptelefono_casa     	CHAR(10),
ptelefono          	CHAR(10),
pcarrier           	CHAR(1),
ppais_nac          	CHAR(3),
pap_cod_postal     	CHAR(5),
pap_id_estado         	CHAR(2),
pap_id_ciudad         	CHAR(3),
pap_id_colonia        	CHAR(10),
pap_id_municipio      	CHAR(5),
pap_id_calle          	CHAR(40),
pnumero_exterior	CHAR(10),
pnumero_interior	CHAR(10),
pentre_calles		CHAR(40),
pcomplemento		CHAR(80),
ptarjeta_de_credito_activa	CHAR(1),
pultimos_cuatro_digitos	CHAR(4),
pcredito_hipotecario	CHAR(1),
pcredito_automotriz		CHAR(1),
pfirma_buro        	CHAR(1),
pescolaridad       	CHAR(2),
pestado_civil       CHAR(1),
ptpo_edo_civil     	CHAR(2),
pmeses_edo_civil   	CHAR(2),
ptipo_residencia   	CHAR(1),
ptiempo_domicilio  	CHAR(2),
ppers_domicilio    	CHAR(2),
ppers_trabajan     	CHAR(2),
ppers_dependen     	CHAR(2),
pempresa           	CHAR(60),
ptiempo_trabajo    	CHAR(2),
ptiempo_trab_ant   	CHAR(2),
pactividad         	CHAR(2),
psubactividad      	CHAR(2),
pnivel_ingresos    	CHAR(8),
ptel_trabajo       	CHAR(10),
pprimer_nombre_referencia	CHAR(26),
psegundo_nombre_referencia	CHAR(26),	
pprimer_apellido_referencia	CHAR(26),
psegundo_apellido_referencia	CHAR(26),
pfecha_de_nacimiento_referencia	DATE,
pgenero_referencia				CHAR(1),
pparentesco_referencia			CHAR(2),
ptelefono_celular_referencia	CHAR(13),
pejecutivo         	CHAR(8),
pnumero_control         	CHAR(25),
pfecha_hora        	DATETIME YEAR to FRACTION(5)
)

    RETURNING 
          CHAR(4)       as vcodret1,
		  CHAR(120)     as vmsjresp,
		  CHAR(2)       as vcodsolbcpl,
		  CHAR(40)      as vdescsolbcpl,
		  CHAR(255)     as vmotivobcpl,
		  CHAR(4)       as vproductobcpl,
		  CHAR(20)      as vfoliobcpl,
		  CHAR(2)       as vcodsolcpl,
		  CHAR(40)      as vdescsolcpl,
		  CHAR(255)     as vmotivocpl,
		  CHAR(4)       as vproductocpl,
		  CHAR(20)      as vfoliocpl;
         
    DEFINE vcodret1 CHAR(4);
	DEFINE vmsjresp CHAR(120);
	DEFINE vcodsolbcpl CHAR(2);
	DEFINE vdescsolbcpl CHAR(40);
	DEFINE vmotivobcpl CHAR(255);
	DEFINE vproductobcpl CHAR(4);
	DEFINE vfoliobcpl CHAR(20);
	DEFINE vcodsolcpl CHAR(2);
	DEFINE vdescsolcpl CHAR(40);
	DEFINE vmotivocpl CHAR(255);
	DEFINE vproductocpl CHAR(4);
	DEFINE vfoliocpl CHAR(20);
	
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
	
    LET vcodret1 = '0000';
	LET vmsjresp = 'Consulta exitosa';
	LET vcodsolbcpl = 'PA';
	LET vdescsolbcpl = 'Pre autorizada';
	LET vmotivobcpl = '';
	LET vproductobcpl = '6001';
	LET vfoliobcpl = '11111111';
	LET vcodsolcpl = 'PA';
	LET vdescsolcpl = 'Pre autorizada';
	LET vmotivocpl = '';
	LET vproductocpl = '6500';
	LET vfoliocpl = '55555555';
	
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';

    BEGIN
	
		ON EXCEPTION SET sql_err, isam_err, desc_err
			--SET DEBUG FILE TO "/informix/LIP/sp_alta_solicitud_movil_online.out";
			--TRACE ON;
			IF sql_err <> 0 THEN
				LET vcodret1 = sql_err;
				LET vmsjresp = isam_err;
				--LET vmsjresp = desc_err;
				RETURN vcodret1,vmsjresp,vcodsolbcpl,vdescsolbcpl,vmotivobcpl,vproductobcpl,vfoliobcpl,vcodsolcpl,vdescsolcpl,vmotivocpl,vproductocpl,vfoliocpl;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/informix/LIP/logs/sp_alta_solicitud_movil_online.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		INSERT INTO informix.si_solicitud_movil_online(productos, numcte, ap_nombre1, ap_nombre2, ap_apell_paterno, ap_apell_materno, ap_sexo, ap_fecha_nac, ap_rfc, email, telefono_casa, telefono, carrier, pais_nac, ap_cod_postal, ap_id_estado, ap_id_ciudad, ap_id_colonia, ap_id_municipio, ap_id_calle, num_exterior, num_interior, entre_calles, complemento, tdc_activa, cuatro_digitos, credito_hipotecario, credito_automotriz, firma_buro, escolaridad, estado_civil, tpo_edo_civil, meses_edo_civil, tipo_residencia, tpo_domicilio, pers_domicilio, pers_trabajan, pers_dependen, empresa, tpo_trabajo, tpo_trab_ant, actividad, subactividad, nivel_ingresos, tel_trabajo, nombre1_ref, nombre2_ref, apell_paterno_ref, apell_materno_ref, fech_nac_ref, genero_ref, parentesco_ref, tel_celular_ref, ejecutivo, numero_control, fecha_hora)
		VALUES(pproductos,pnumcte,pap_nombre1,pap_nombre2,pap_apell_paterno,pap_apell_materno,pap_sexo,pap_fecha_nac,pap_rfc,pemail,ptelefono_casa,ptelefono,
				pcarrier,ppais_nac,pap_cod_postal,pap_id_estado,pap_id_ciudad,pap_id_colonia,pap_id_municipio,pap_id_calle,pnumero_exterior,pnumero_interior,
				pentre_calles,pcomplemento,ptarjeta_de_credito_activa,pultimos_cuatro_digitos,pcredito_hipotecario,pcredito_automotriz,pfirma_buro,pescolaridad,
				pestado_civil,ptpo_edo_civil,pmeses_edo_civil,ptipo_residencia,ptiempo_domicilio,ppers_domicilio,ppers_trabajan,ppers_dependen,pempresa,ptiempo_trabajo,
				ptiempo_trab_ant,pactividad,psubactividad,pnivel_ingresos,ptel_trabajo,pprimer_nombre_referencia,psegundo_nombre_referencia,pprimer_apellido_referencia,
				psegundo_apellido_referencia,pfecha_de_nacimiento_referencia,pgenero_referencia,pparentesco_referencia,ptelefono_celular_referencia,pejecutivo,pnumero_control,pfecha_hora);

		
		RETURN vcodret1,vmsjresp,vcodsolbcpl,vdescsolbcpl,vmotivobcpl,vproductobcpl,vfoliobcpl,vcodsolcpl,vdescsolcpl,vmotivocpl,vproductocpl,vfoliocpl;
	
	END;
	
END PROCEDURE;