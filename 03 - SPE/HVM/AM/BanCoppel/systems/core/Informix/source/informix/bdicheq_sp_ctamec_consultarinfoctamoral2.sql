CREATE PROCEDURE "informix".sp_ctamec_consultarinfoctamoral2(pEmpresa CHAR(3), pCuenta CHAR(20))

	-- DATOS A REGRESAR --
	RETURNING 
	CHAR(6) 	AS COD_RET,		-- Codigo de retorno
	CHAR(60) 	AS MENSAJE,	-- Mensaje ejecucion
	CHAR(4)		AS CODIGO_PRODUCTO,		-- Codigo del producto
	CHAR(40)	AS DESC_PRODUCTO,	-- Descripcion del producto
	CHAR(20)	AS NUM_CLIENTE,	-- Numero de cliente poseedor de la cuenta consultada
	CHAR(60)	AS NOMBRE_CLIENTE,	-- Nombre o razon social del cliente poseedor de la cuenta consultada
	CHAR(1)		AS COD_REGIMEN,	-- Codigo del regimen de firmas
	CHAR(20)	AS REGIMEN_DE_FIRMAS,-- Descripcion del regimen de firmas
	SMALLINT	AS NUMERO_FIRMANTES,-- Numero de firmantes de la cuenta
	CHAR(20)	AS CLAVE_FIRMANTE,-- Numero del cliente del firmante relacionado a la cuenta
	CHAR(30)	AS NOMBRE_FIRMANTE,-- Nombre del firmante relacionado a la cuenta
	CHAR(30)	AS APELL_FIRMANTE,--Apellido del firmante 
	SMALLINT	AS SECUENCIA,--Secuencia de los firmantes
	CHAR(1)		AS TIPO_FIRMA,-- Tipo de firma del firmante relacionado a la cuenta
	CHAR(20)	AS COMBINACION,-- Combinacion del regimen de firmas
	CHAR(2)		AS CODIGO_PROCEDENCIA_REC_A,--Codigo de procedencia de los recursos para apertura
	CHAR(60)	AS DESC_PROCEDENCIA_REC_A,--descripcion de procedencia de los recursos para apertura
	CHAR(2)		AS CODIGO_PROCEDENCIA_REC_M,--Codigo para procedencia de los recursos mantenimiento
	CHAR(60)	AS DESC_PROCEDENCIA_REC_M,--Descripcion para procedencia de los recursos mantenimiento
	CHAR(2)		AS COD_NUMERO_DEPOSITO,--Codigo de numero de depositos
	CHAR(60)	AS DESC_NUMERO_DEPOSITO,--Descripcion de numero de depositos
	CHAR(2)		AS COD_NUMERO_RETIRO,--Codigo de numero de retiros
	CHAR(60)	AS DESC_NUMERO_RETIRO,--Descripcion de Numero de retiros
	CHAR(2)		AS COD_MONTO_DEPOSITO,--Codigo Monto de depositos
	CHAR(60)	AS DESC_MONTO_DEPOSITO,--Descripcion de monto de depositos
	CHAR(2)		AS COD_MONTO_RETIRO,--Codigo monto de retiros
	CHAR(60)	AS DESC_MONTO_RETIRO,--Descripcion de monto de retiros
	CHAR(2)		AS COD_MONTO_MENSUAL,--Codigo de monto mensual
	CHAR(60)	AS DESC_MONTO_MENSUAL,--Descripcion de monto mensual
	CHAR(20)	AS NUMERO_CUENTA,--Codigo de numero de cuenta
	CHAR(18)	AS CUENTA_CLABE, --Cuenta Clabe
	CHAR(4)     AS NUMERO_SUCURSAL, --Numero de Sucursal
	CHAR(40)    AS NOMBRE_SUCURSAL; --Nombre de Sucursal
	
	--	VARIABLES CONTROL DE ERRORES --
	DEFINE cCodRet  CHAR(5);
	DEFINE cMensaje CHAR(60);
	DEFINE iSqlErr  INTEGER;

	-- VARIABLES --
	DEFINE	cCodProd		CHAR(4);		-- Codigo del producto
	DEFINE	cDescProd		CHAR(40);	-- Descripcion del producto
	DEFINE	cNumcte1		CHAR(20);	-- Numero de cliente poseedor de la cuenta consultada
	DEFINE	cNombre			CHAR(60);	-- Nombre o razon social del cliente poseedor de la cuenta consultada
	DEFINE	cCodReg			CHAR(1);		-- Codigo del regimen de firmas
	DEFINE	cDescReg		CHAR(20);	-- Descripcion del regimen de firmas
	DEFINE	iNumFirmas		SMALLINT;	-- Numero de firmantes de la cuenta
	DEFINE	cNumCteFir		CHAR(20);	-- Numero del cliente del firmante relacionado a la cuenta
	DEFINE	cNombreFir		CHAR(30);	-- Nombre del firmante relacionado a la cuenta
	DEFINE	cApellFir		CHAR(30);	--Apellido del firmante
	DEFINE	iSecuencia		SMALLINT;	--Secuencia de los firmantes
	DEFINE	cTipoFir		CHAR(1);	-- Tipo de firma del firmante relacionado a la cuenta
	DEFINE	cCombi			CHAR(20);	-- Combinacion del regimen de firmas
	DEFINE	cCodProcRecA	CHAR(2);	--Codigo de procedencia de los recursos para apertura
	DEFINE	cDescProcRecA	CHAR(60);	--descripcion de procedencia de los recursos para apertura
	DEFINE	cCodProcRecM	CHAR(2);	--Codigo para procedencia de los recursos mantenimiento
	DEFINE	cDescProcRecM	CHAR(60);	--Descripcion para procedencia de los recursos mantenimiento
	DEFINE	cCodNumDepo		CHAR(2);	--Codigo de numero de depositos
	DEFINE	cDescNumDepo	CHAR(60);	--Descripcion de numero de depositos
	DEFINE	cCodNumRet		CHAR(2);	--Codigo de numero de retiros
	DEFINE	cDescNumRet		CHAR(60);	--Descripcion de Numero de retiros
	DEFINE	cCodMontoDepo	CHAR(2);	--Codigo Monto de depositos
	DEFINE	cDescMontoDepo	CHAR(60);	--Descripcion de monto de depositos
	DEFINE	cCodMontoRet	CHAR(2);	--Codigo monto de retiros
	DEFINE	cDescMontoRet	CHAR(60);	--Descripcion de monto de retiros
	DEFINE	cCodMontoMes	CHAR(2);	--Codigo de monto mensual
	DEFINE	cDescMontoMes	CHAR(60);	--Descripcion de monto mensual
	DEFINE	cNumCta			CHAR(20);	--Codigo de numero de cuenta
	DEFINE	cNumClabe		CHAR(18);	--Codigo de numero de cuenta CLABE
	DEFINE	iParam 			SMALLINT;	--Bandera para verificar la existncia de datos en bucle
	DEFINE  cNumeroSuc		CHAR(4);   	--Numero de la sucursal
	DEFINE  cNombreSuc		CHAR(40);	--Nombre de la sucursal
	DEFINE	cSufijo         CHAR(60);	--DSB 22/05/2013
		
	-- INICIALIZACION DE VARIABLES --
	
	LET	cCodret = "000";
	LET	cMensaje = "";
	LET	cCodProd = "";
	LET	cDescProd	= "";	
	LET	cNumcte1	= "";	
	LET	cNombre		= "";	
	LET	cCodReg		= "";	
	LET	cDescReg	= "";	
	LET	iNumFirmas	= 0;	
	LET	cNumCteFir	= "";	
	LET	cNombreFir	= "";
	LET cApellFir 	= "";
	LET iSecuencia = 0;
	LET	cTipoFir	= "";	
	LET	cCombi		= "";	
	LET	cCodProcRecA	= "";
	LET	cDescProcRecA = "";	
	LET	cCodProcRecM	= "";
	LET	cDescProcRecM = "";	
	LET	cCodNumDepo	= "";	
	LET	cDescNumDepo = "";	
	LET	cCodNumRet	= "";	
	LET	cDescNumRet	= "";	
	LET	cCodMontoDepo = "";	
	LET	cDescMontoDepo = "";	
	LET	cCodMontoRet = "";	
	LET	cDescMontoRet = "";	
	LET	cCodMontoMes = "";	
	LET	cDescMontoMes = "";	
	LET	cNumCta		= "";	
	LET	cNumClabe = "";	
	LET iParam = 0;
	LET iSqlErr = 0;
	LET cNumeroSuc = "";
	LET cNombreSuc = "";
	LET cSufijo         = '';	--DSB 22/05/2013
	
	--SET DEBUG FILE TO '/informix/vamilan/sp_ctamec_consultarinfoctamoral2.out';
	--TRACE ON;
	
	-- CONTROL DE ERRORES --	
BEGIN
	ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(cCodProd), TRIM(cDescProd), TRIM(cNumcte1), TRIM(cNombre), TRIM(cCodReg), TRIM(cDescReg),
				iNumFirmas, TRIM(cNumCteFir), TRIM(cNombreFir), TRIM(cApellFir),iSecuencia, TRIM(cTipoFir), TRIM(cCombi), TRIM(cCodProcRecA), 
				TRIM(cDescProcRecA), TRIM(cCodProcRecM), TRIM(cDescProcRecM), TRIM(cCodNumDepo), TRIM(cDescNumDepo), TRIM(cCodNumRet), 
				TRIM(cDescNumRet), TRIM(cCodMontoDepo), TRIM(cDescMontoDepo), TRIM(cCodMontoRet), TRIM(cDescMontoRet), TRIM(cCodMontoMes), 
				TRIM(cDescMontoMes), TRIM(cNumCta), TRIM(cNumClabe), cNumeroSuc, cNombreSuc;
        END IF
	END EXCEPTION;
	
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SE VERIFICA QUE SE TENGA AL MENOS UN PARAMETRO
	IF pEmpresa = "" OR pCuenta = "" THEN 
		LET cCodRet = "110"; 	--codigo de falta de parametros??
		LET cMensaje = "Faltan Parametros";
		RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(cCodProd), TRIM(cDescProd), TRIM(cNumcte1), TRIM(cNombre), TRIM(cCodReg), TRIM(cDescReg),
				iNumFirmas, TRIM(cNumCteFir), TRIM(cNombreFir), TRIM(cApellFir),iSecuencia, TRIM(cTipoFir), TRIM(cCombi), TRIM(cCodProcRecA), 
				TRIM(cDescProcRecA), TRIM(cCodProcRecM), TRIM(cDescProcRecM), TRIM(cCodNumDepo), TRIM(cDescNumDepo), TRIM(cCodNumRet), 
				TRIM(cDescNumRet), TRIM(cCodMontoDepo), TRIM(cDescMontoDepo), TRIM(cCodMontoRet), TRIM(cDescMontoRet), TRIM(cCodMontoMes), 
				TRIM(cDescMontoMes), TRIM(cNumCta), TRIM(cNumClabe), cNumeroSuc, cNombreSuc;
	END IF
	
	LET cNumCta = pCuenta;
	
	--OBTENEMOS COD_PRODUCTO, NUM_CTE, PROC_REC_A,PROC_REC_M,NUM_DEPO,MONTO_DEPO,NUM_RET,MONTO_RET,MONTO_MENSUAL,CUENTA_CLABE
	SELECT sc_m.producto, sc_m.num_cte, sc_m.proced_aperturacta, sc_m.proced_mantenercta, sc_m.depositos_cantidad , sc_m.depositos_monto,
		   sc_m.retiros_cantidad, sc_m.retiros_monto, sc_m.monto_mensual, sc_m.cuenta_clabe, si.sucursal, si.nombre
	INTO cCodProd, cNumCte1,cCodProcRecA,cCodProcRecM,cCodNumDepo,cCodMontoDepo,
	     cCodNumRet,cCodMontoRet,cCodMontoMes, cNumClabe, cNumeroSuc, cNombreSuc
	FROM bdicheq:"informix".sc_maechq sc_m,
		 bdinteg:"informix".si_sucursales si
	WHERE sc_m.empresa = pEmpresa
	AND sc_m.cuenta = pCuenta
	AND sc_m.sucursal = si.sucursal;
	
	IF cNumCte1 IS NULL THEN --NO EXISTE LA CUENTA
		LET cCodRet = '120';
		LET cMensaje = "NO EXISTE LA CUENTA";
		RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(cCodProd), TRIM(cDescProd), TRIM(cNumcte1), TRIM(cNombre), TRIM(cCodReg), TRIM(cDescReg),
				iNumFirmas, TRIM(cNumCteFir), TRIM(cNombreFir), TRIM(cApellFir),iSecuencia, TRIM(cTipoFir), TRIM(cCombi), TRIM(cCodProcRecA), 
				TRIM(cDescProcRecA), TRIM(cCodProcRecM), TRIM(cDescProcRecM), TRIM(cCodNumDepo), TRIM(cDescNumDepo), TRIM(cCodNumRet), 
				TRIM(cDescNumRet), TRIM(cCodMontoDepo), TRIM(cDescMontoDepo), TRIM(cCodMontoRet), TRIM(cDescMontoRet), TRIM(cCodMontoMes), 
				TRIM(cDescMontoMes), TRIM(cNumCta), TRIM(cNumClabe), cNumeroSuc, cNombreSuc;
	END IF;		

	--VERIFICAMOS QUE EL PRODUCTO SEA PARA PERSONA MORAL Y OBTENEMOS SU DESCRIPCION
	SELECT sc_p.nombre 
	INTO cDescProd
	FROM bdicheq:"informix".sc_producto sc_p, bdinteg:"informix".si_tipper si_t
	WHERE sc_p.tpper_valida = CAST(si_t.tpo_persona AS SMALLINT)
	AND si_t.es_fisica = 'N'
    AND empresa = pEmpresa
	AND producto = cCodProd;
	
	IF cDescProd IS NULL THEN --NO EXISTE EL PRODUCTO
		LET cCodRet = '200';
		LET cMensaje = "NO EXISTE EL PRODUCTO";
		RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(cCodProd), TRIM(cDescProd), TRIM(cNumcte1), TRIM(cNombre), TRIM(cCodReg), TRIM(cDescReg),
				iNumFirmas, TRIM(cNumCteFir), TRIM(cNombreFir), TRIM(cApellFir),iSecuencia, TRIM(cTipoFir), TRIM(cCombi), TRIM(cCodProcRecA), 
				TRIM(cDescProcRecA), TRIM(cCodProcRecM), TRIM(cDescProcRecM), TRIM(cCodNumDepo), TRIM(cDescNumDepo), TRIM(cCodNumRet), 
				TRIM(cDescNumRet), TRIM(cCodMontoDepo), TRIM(cDescMontoDepo), TRIM(cCodMontoRet), TRIM(cDescMontoRet), TRIM(cCodMontoMes), 
				TRIM(cDescMontoMes), TRIM(cNumCta), TRIM(cNumClabe), cNumeroSuc, cNombreSuc;
	END IF;	
	
	--OBTENEMOS LA RAZON SOCIAL DEL CLIENTE
	SELECT razon_social
	INTO cNombre
	FROM bdinteg:"informix".si_cliente
	WHERE empresa = pEmpresa
	AND numcte =cNumCte1;
	
	--DSB 22/05/2013
	SELECT NVL(descripcion, '')
	INTO cSufijo
	FROM bdinteg:"informix".si_sufijos suf,
	bdinteg:"informix".si_ctepm cte
	WHERE suf.codigo = cte.sufijo 
	AND cte.numcte = cNumCte1;
	LET cNombre = TRIM(cNombre)||" "||TRIM(NVL(cSufijo, ''));
	
	IF cNombre IS NULL THEN --NO EXISTE EL CLIENTE
		LET cCodRet = '210';
		LET cMensaje = "NO EXISTE EL CLIENTE";
		RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(cCodProd), TRIM(cDescProd), TRIM(cNumcte1), TRIM(cNombre), TRIM(cCodReg), TRIM(cDescReg),
				iNumFirmas, TRIM(cNumCteFir), TRIM(cNombreFir), TRIM(cApellFir),iSecuencia, TRIM(cTipoFir), TRIM(cCombi), TRIM(cCodProcRecA), 
				TRIM(cDescProcRecA), TRIM(cCodProcRecM), TRIM(cDescProcRecM), TRIM(cCodNumDepo), TRIM(cDescNumDepo), TRIM(cCodNumRet), 
				TRIM(cDescNumRet), TRIM(cCodMontoDepo), TRIM(cDescMontoDepo), TRIM(cCodMontoRet), TRIM(cDescMontoRet), TRIM(cCodMontoMes), 
				TRIM(cDescMontoMes), TRIM(cNumCta), TRIM(cNumClabe), cNumeroSuc, cNombreSuc;
	END IF;	
	 
	--OBTENEMOS EL REGIMEN DE FIRMAS
	SELECT reg_firmas
	INTO cCodReg
	FROM bdicheq:"informix".sc_maenoc
	WHERE empresa = pEmpresa
	AND cuenta = pCuenta;
	
	IF cCodReg IS NULL THEN --NO EXISTE EL CUENTA EN MAENOC
		LET cCodRet = '220';
		LET cMensaje = "NO EXISTE EL CUENTA EN MAENOC";
		RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(cCodProd), TRIM(cDescProd), TRIM(cNumcte1), TRIM(cNombre), TRIM(cCodReg), TRIM(cDescReg),
				iNumFirmas, TRIM(cNumCteFir), TRIM(cNombreFir), TRIM(cApellFir),iSecuencia, TRIM(cTipoFir), TRIM(cCombi), TRIM(cCodProcRecA), 
				TRIM(cDescProcRecA), TRIM(cCodProcRecM), TRIM(cDescProcRecM), TRIM(cCodNumDepo), TRIM(cDescNumDepo), TRIM(cCodNumRet), 
				TRIM(cDescNumRet), TRIM(cCodMontoDepo), TRIM(cDescMontoDepo), TRIM(cCodMontoRet), TRIM(cDescMontoRet), TRIM(cCodMontoMes), 
				TRIM(cDescMontoMes), TRIM(cNumCta), TRIM(cNumClabe), cNumeroSuc, cNombreSuc;
	END IF;	
	
	--------------------------------------------------------------------------------------------------------------------------------------------
	--OBTENEMOS LA DESCRIPCION DEL REGIMEN DE FIRMAS Y LA COMBINACION
	IF NOT EXISTS(SELECT noproducto FROM bdicnweb:"informix".productos WHERE  activa = 1 AND noproducto = cCodProd) THEN	
		SELECT descripcion, combinacion
		INTO cDescReg,cCombi
		FROM bdicntchq:"informix".sq_catregimen
		WHERE cve_regimen = cCodReg;
		
		IF cDescReg IS NULL THEN --NO EXISTE EL REGIMEN DE FIRMAS
			LET cCodRet = '230';
			LET cMensaje = "NO EXISTE EL REGIMEN DE FIRMAS";
			RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(cCodProd), TRIM(cDescProd), TRIM(cNumcte1), TRIM(cNombre), TRIM(cCodReg), TRIM(cDescReg),
					iNumFirmas, TRIM(cNumCteFir), TRIM(cNombreFir), TRIM(cApellFir),iSecuencia, TRIM(cTipoFir), TRIM(cCombi), TRIM(cCodProcRecA), 
					TRIM(cDescProcRecA), TRIM(cCodProcRecM), TRIM(cDescProcRecM), TRIM(cCodNumDepo), TRIM(cDescNumDepo), TRIM(cCodNumRet), 
					TRIM(cDescNumRet), TRIM(cCodMontoDepo), TRIM(cDescMontoDepo), TRIM(cCodMontoRet), TRIM(cDescMontoRet), TRIM(cCodMontoMes), 
					TRIM(cDescMontoMes), TRIM(cNumCta), TRIM(cNumClabe), cNumeroSuc, cNombreSuc;
		END IF;	
	END IF;	
		
	--OBTENEMOS LA DESCIPCION DE PROCEDENCIA DE LOS RECURSOS APERTURA
	SELECT descripcion
	INTO cDescProcRecA
	FROM bdinteg:"informix".si_tipo_procedencia
	WHERE procedencia = cCodProcRecA;
	
	IF cDescProcRecA IS NULL THEN --NO EXISTE EL TIPO DE PROCEDENCIA ALTA
		LET cCodRet = '240';
		LET cMensaje = "NO EXISTE EL TIPO DE PROCEDENCIA ALTA";
		RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(cCodProd), TRIM(cDescProd), TRIM(cNumcte1), TRIM(cNombre), TRIM(cCodReg), TRIM(cDescReg),
				iNumFirmas, TRIM(cNumCteFir), TRIM(cNombreFir), TRIM(cApellFir),iSecuencia, TRIM(cTipoFir), TRIM(cCombi), TRIM(cCodProcRecA), 
				TRIM(cDescProcRecA), TRIM(cCodProcRecM), TRIM(cDescProcRecM), TRIM(cCodNumDepo), TRIM(cDescNumDepo), TRIM(cCodNumRet), 
				TRIM(cDescNumRet), TRIM(cCodMontoDepo), TRIM(cDescMontoDepo), TRIM(cCodMontoRet), TRIM(cDescMontoRet), TRIM(cCodMontoMes), 
				TRIM(cDescMontoMes), TRIM(cNumCta), TRIM(cNumClabe), cNumeroSuc, cNombreSuc;
	END IF;	
	
	--OBTENEMOS LA DESCIPCION DE PROCEDENCIA DE LOS RECURSOS MANTENIMIENTO
	SELECT descripcion
	INTO cDescProcRecM
	FROM bdinteg:"informix".si_tipo_procedencia
	WHERE procedencia = cCodProcRecM;
	
	IF cDescProcRecM IS NULL THEN --NO EXISTE EL TIPO DE PROCEDENCIA MANTENIMIENTO
		LET cCodRet = '250';
		LET cMensaje = "NO EXISTE EL TIPO DE PROCEDENCIA MANTENIMIENTO";
		RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(cCodProd), TRIM(cDescProd), TRIM(cNumcte1), TRIM(cNombre), TRIM(cCodReg), TRIM(cDescReg),
				iNumFirmas, TRIM(cNumCteFir), TRIM(cNombreFir), TRIM(cApellFir),iSecuencia, TRIM(cTipoFir), TRIM(cCombi), TRIM(cCodProcRecA), 
				TRIM(cDescProcRecA), TRIM(cCodProcRecM), TRIM(cDescProcRecM), TRIM(cCodNumDepo), TRIM(cDescNumDepo), TRIM(cCodNumRet), 
				TRIM(cDescNumRet), TRIM(cCodMontoDepo), TRIM(cDescMontoDepo), TRIM(cCodMontoRet), TRIM(cDescMontoRet), TRIM(cCodMontoMes), 
				TRIM(cDescMontoMes), TRIM(cNumCta), TRIM(cNumClabe), cNumeroSuc, cNombreSuc;
	END IF;	
	
	--OBTENEMOS LA DESCRIPCION DE NUMERO DE DEPOSITOS
	SELECT descripcion 
	INTO cDescNumDepo
	FROM bdinteg:"informix".si_tipo_nummov
	WHERE codnummo = cCodNumDepo;
	
	IF cDescNumDepo IS NULL THEN --NO EXISTE EL CODIGO DE NUMERO DE MOVIMIENTO EN DEPOSITO
		LET cCodRet = '260';
		LET cMensaje = "NO EXISTE EL CODIGO DE NUMERO DE MOVIMIENTOS DEPOSITO";
		RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(cCodProd), TRIM(cDescProd), TRIM(cNumcte1), TRIM(cNombre), TRIM(cCodReg), TRIM(cDescReg),
				iNumFirmas, TRIM(cNumCteFir), TRIM(cNombreFir), TRIM(cApellFir),iSecuencia, TRIM(cTipoFir), TRIM(cCombi), TRIM(cCodProcRecA), 
				TRIM(cDescProcRecA), TRIM(cCodProcRecM), TRIM(cDescProcRecM), TRIM(cCodNumDepo), TRIM(cDescNumDepo), TRIM(cCodNumRet), 
				TRIM(cDescNumRet), TRIM(cCodMontoDepo), TRIM(cDescMontoDepo), TRIM(cCodMontoRet), TRIM(cDescMontoRet), TRIM(cCodMontoMes), 
				TRIM(cDescMontoMes), TRIM(cNumCta), TRIM(cNumClabe), cNumeroSuc, cNombreSuc;
	END IF;	
	
	--OBTENEMOS LA DESCRIPCION DE NUMERO DE RETIRO
	SELECT descripcion 
	INTO cDescNumRet
	FROM bdinteg:"informix".si_tipo_nummov
	WHERE codnummo = cCodNumRet;
	
	IF cDescNumRet IS NULL THEN --NO EXISTE EL CODIGO DE NUMERO DE MOVIMIENTO EN RETIRO
		LET cCodRet = '270';
		LET cMensaje = "NO EXISTE EL CODIGO DE NUMERO DE MOVIMIENTOS RETIRO";
		RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(cCodProd), TRIM(cDescProd), TRIM(cNumcte1), TRIM(cNombre), TRIM(cCodReg), TRIM(cDescReg),
				iNumFirmas, TRIM(cNumCteFir), TRIM(cNombreFir), TRIM(cApellFir),iSecuencia, TRIM(cTipoFir), TRIM(cCombi), TRIM(cCodProcRecA), 
				TRIM(cDescProcRecA), TRIM(cCodProcRecM), TRIM(cDescProcRecM), TRIM(cCodNumDepo), TRIM(cDescNumDepo), TRIM(cCodNumRet), 
				TRIM(cDescNumRet), TRIM(cCodMontoDepo), TRIM(cDescMontoDepo), TRIM(cCodMontoRet), TRIM(cDescMontoRet), TRIM(cCodMontoMes), 
				TRIM(cDescMontoMes), TRIM(cNumCta), TRIM(cNumClabe), cNumeroSuc, cNombreSuc;
	END IF;	
	 
	--OBTENEMOS LA DESCRIPCION DEL MONTO DE DEPOSITO
	SELECT descripcion
	INTO cDescMontoDepo
	FROM bdinteg:"informix".si_tipo_montomov
	WHERE codnummonto = cCodMontoDepo;
	
	IF cDescMontoDepo IS NULL THEN --NO EXISTE EL CODIGO DE MONTO DE MOVIMIENTO EN DEPOSITO
		LET cCodRet = '280';
		LET cMensaje = "NO EXISTE EL CODIGO DE MONTO DE MOVIMIENTO EN DEPOSITO";
		RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(cCodProd), TRIM(cDescProd), TRIM(cNumcte1), TRIM(cNombre), TRIM(cCodReg), TRIM(cDescReg),
				iNumFirmas, TRIM(cNumCteFir), TRIM(cNombreFir), TRIM(cApellFir),iSecuencia, TRIM(cTipoFir), TRIM(cCombi), TRIM(cCodProcRecA), 
				TRIM(cDescProcRecA), TRIM(cCodProcRecM), TRIM(cDescProcRecM), TRIM(cCodNumDepo), TRIM(cDescNumDepo), TRIM(cCodNumRet), 
				TRIM(cDescNumRet), TRIM(cCodMontoDepo), TRIM(cDescMontoDepo), TRIM(cCodMontoRet), TRIM(cDescMontoRet), TRIM(cCodMontoMes), 
				TRIM(cDescMontoMes), TRIM(cNumCta), TRIM(cNumClabe), cNumeroSuc, cNombreSuc;
	END IF;	
	 
	--OBTENEMOS LA DESCRIPCION DEL MONTO DE RETIRO
	SELECT descripcion
	INTO cDescMontoRet
	FROM bdinteg:"informix".si_tipo_montomov
	WHERE codnummonto = cCodMontoRet;
	
	IF cDescMontoRet IS NULL THEN --NO EXISTE EL CODIGO DE MONTO DE MOVIMIENTO EN RETIRO
		LET cCodRet = '290';
		LET cMensaje = "NO EXISTE EL CODIGO DE MONTO DE MOVIMIENTO EN RETIRO";
		RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(cCodProd), TRIM(cDescProd), TRIM(cNumcte1), TRIM(cNombre), TRIM(cCodReg), TRIM(cDescReg),
				iNumFirmas, TRIM(cNumCteFir), TRIM(cNombreFir), TRIM(cApellFir),iSecuencia, TRIM(cTipoFir), TRIM(cCombi), TRIM(cCodProcRecA), 
				TRIM(cDescProcRecA), TRIM(cCodProcRecM), TRIM(cDescProcRecM), TRIM(cCodNumDepo), TRIM(cDescNumDepo), TRIM(cCodNumRet), 
				TRIM(cDescNumRet), TRIM(cCodMontoDepo), TRIM(cDescMontoDepo), TRIM(cCodMontoRet), TRIM(cDescMontoRet), TRIM(cCodMontoMes), 
				TRIM(cDescMontoMes), TRIM(cNumCta), TRIM(cNumClabe), cNumeroSuc, cNombreSuc;
	END IF;	
	
	
	--OBTENEMOS LA DESCRIPCION DEL MONTO MENSUAL
	SELECT descripcion
	INTO cDescMontoMes
	FROM bdinteg:"informix".si_tipo_montomes
	WHERE codigo = cCodMontoMes;
	
	IF cDescMontoMes IS NULL THEN --NO EXISTE EL CODIGO DE MONTO DE MOVIMIENTO MENSUAL
		LET cCodRet = '300';
		LET cMensaje = "NO EXISTE EL CODIGO DE MONTO DE MOVIMIENTO MENSUAL";
		RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(cCodProd), TRIM(cDescProd), TRIM(cNumcte1), TRIM(cNombre), TRIM(cCodReg), TRIM(cDescReg),
				iNumFirmas, TRIM(cNumCteFir), TRIM(cNombreFir), TRIM(cApellFir),iSecuencia, TRIM(cTipoFir), TRIM(cCombi), TRIM(cCodProcRecA), 
				TRIM(cDescProcRecA), TRIM(cCodProcRecM), TRIM(cDescProcRecM), TRIM(cCodNumDepo), TRIM(cDescNumDepo), TRIM(cCodNumRet), 
				TRIM(cDescNumRet), TRIM(cCodMontoDepo), TRIM(cDescMontoDepo), TRIM(cCodMontoRet), TRIM(cDescMontoRet), TRIM(cCodMontoMes), 
				TRIM(cDescMontoMes), TRIM(cNumCta), TRIM(cNumClabe), cNumeroSuc, cNombreSuc;
	END IF;	
	
	IF NOT EXISTS(SELECT noproducto FROM bdicnweb:"informix".productos WHERE  activa = 1 AND noproducto = cCodProd) THEN	
		FOREACH 
			--OBTENEMOS EL NUMERO DEL CLIENTE EL NOMBRE, EL TIPO DE FIRMA Y LA SECUENCIA
			SELECT numcte, nombre, apellidos,tipo_firma,secuencia
			INTO cNumCteFir, cNombreFir,cApellFir,cTipoFir,iSecuencia
			FROM bdicheq:"informix".sc_firmantes
			WHERE cuenta = pCuenta
			
			LET iNumFirmas = iNumFirmas + 1;
			LET iParam = 1;
			
			RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(cCodProd), TRIM(cDescProd), TRIM(cNumcte1), TRIM(cNombre), TRIM(cCodReg), TRIM(cDescReg),
					iNumFirmas, TRIM(cNumCteFir), TRIM(cNombreFir), TRIM(cApellFir), iSecuencia, TRIM(cTipoFir), TRIM(cCombi), TRIM(cCodProcRecA), 
					TRIM(cDescProcRecA), TRIM(cCodProcRecM), TRIM(cDescProcRecM), TRIM(cCodNumDepo), TRIM(cDescNumDepo), TRIM(cCodNumRet), 
					TRIM(cDescNumRet), TRIM(cCodMontoDepo), TRIM(cDescMontoDepo), TRIM(cCodMontoRet), TRIM(cDescMontoRet), TRIM(cCodMontoMes), 
					TRIM(cDescMontoMes), TRIM(cNumCta), TRIM(cNumClabe), cNumeroSuc, cNombreSuc WITH RESUME;
			
		END FOREACH;
	ELSE
		LET	cNumCteFir	= "";	
		LET	cNombreFir	= "";
		LET cApellFir 	= "";
		LET iSecuencia = 0;
		LET	cTipoFir	= "";		
		LET iNumFirmas = 0;
		LET iParam = 1;
		
		RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(cCodProd), TRIM(cDescProd), TRIM(cNumcte1), TRIM(cNombre), TRIM(cCodReg), TRIM(cDescReg),
				iNumFirmas, TRIM(cNumCteFir), TRIM(cNombreFir), TRIM(cApellFir),iSecuencia, TRIM(cTipoFir), TRIM(cCombi), TRIM(cCodProcRecA), 
				TRIM(cDescProcRecA), TRIM(cCodProcRecM), TRIM(cDescProcRecM), TRIM(cCodNumDepo), TRIM(cDescNumDepo), TRIM(cCodNumRet), 
				TRIM(cDescNumRet), TRIM(cCodMontoDepo), TRIM(cDescMontoDepo), TRIM(cCodMontoRet), TRIM(cDescMontoRet), TRIM(cCodMontoMes), 
				TRIM(cDescMontoMes), TRIM(cNumCta), TRIM(cNumClabe), cNumeroSuc, cNombreSuc;
	
	END IF;
		
	IF iParam = 0 THEN --NO EXISTEN FIRMANTES PARA ESA CUENTA
		LET cCodRet = '400';
		LET cMensaje = "NO EXISTEN FIRMANTES PARA ESA CUENTA";
		RETURN TRIM(cCodret), TRIM(cMensaje), TRIM(cCodProd), TRIM(cDescProd), TRIM(cNumcte1), TRIM(cNombre), TRIM(cCodReg), TRIM(cDescReg),
				iNumFirmas, TRIM(cNumCteFir), TRIM(cNombreFir), TRIM(cApellFir),iSecuencia, TRIM(cTipoFir), TRIM(cCombi), TRIM(cCodProcRecA), 
				TRIM(cDescProcRecA), TRIM(cCodProcRecM), TRIM(cDescProcRecM), TRIM(cCodNumDepo), TRIM(cDescNumDepo), TRIM(cCodNumRet), 
				TRIM(cDescNumRet), TRIM(cCodMontoDepo), TRIM(cDescMontoDepo), TRIM(cCodMontoRet), TRIM(cDescMontoRet), TRIM(cCodMontoMes), 
				TRIM(cDescMontoMes), TRIM(cNumCta), TRIM(cNumClabe), cNumeroSuc, cNombreSuc;
	END IF
END
END PROCEDURE
DOCUMENT
'Procedimiento     : ConsultarInfoCuentaMoral',
'Versión           : 1.0',
'Creado por        : Victor Hugo Nuñez Velazquez',
'Fecha creacion    : 16 Junio 2011',
'Descripcion       : Obtiene La informacion de la cuenta moral',
'Fecha Modificacion: 22/03/2012',
'Descripcion       : Se agrega la consulta del numero y nombre de la sucursal del cliente',
'Autor Modificacion: Héctor Manuel Bojorquez Ruelas',
'Base de Datos     : bdicheq',
'Modifico: Jose Luis Polanco B.',
'Fecha: DSB 22/05/2013',
'Descripcion: Se agrega el "sufijo" a la variable de retorno "cNombre" para que aparesca en la aplicacion asociada al procedimiento',
'AUTOR MODIFICACION: Uriel Caamaño Mejia',
'BD: bdicheq',
'FECHA: 01/12/2017',
'DESCRIPCION: Se clona el SPL y se agregan nuevas reglas de negocio para el comportamiento de los productos';

CREATE PROCEDURE "informix".sp_dispercionnomina_bpi(pnombrearchivo CHAR(20))

-- ******************************************************************************************

--Realizo   : Gabriela Aguilar Mendoza
--Actividad : Se clona el spl sp_dispercionnomina_bpi(), para pasar el nombre del archivo y que
--			solo disperse la nomina de los empleados que contiene ese archivo.
-- ******************************************************************************************
returning char(5);

DEFINE vcodret          VARCHAR(5);
DEFINE vcodret2         CHAR(5);
DEFINE cMensaje 		CHAR(50);
DEFINE vsqlerr          INTEGER;

LET cMensaje = " ";
LET vcodret = "00000";
LET vcodret2= " ";



 	--SET debug FILE TO "/home/informix/BereniceOut/sp_dispercionnomina_bpi.out";
	--Trace ON;

	
	
	
	BEGIN 

	ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				--Update bdibpi:"informix".tmp_disp_errchivo, set mensaje=cMensaje where nom_arch=pnombrearchivo;
				RETURN vcodret;
			END IF;
	END EXCEPTION;
		
	COMMIT WORK;
		
 	EXECUTE PROCEDURE "informix".sp_dispercionnomina_bpi('5008',pnombrearchivo) into vcodret;
	
	IF 	vcodret <> "000" THEN	
						LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(sp_dispercionnomina_bpi)';
						
					ELSE
						--LET vcodret = vcodret2;
						LET cMensaje = 'LA APLICACION SE EJECUTO EXITOSAMENTE SC';
					END IF;


		RETURN vcodret;

    END;

END PROCEDURE;