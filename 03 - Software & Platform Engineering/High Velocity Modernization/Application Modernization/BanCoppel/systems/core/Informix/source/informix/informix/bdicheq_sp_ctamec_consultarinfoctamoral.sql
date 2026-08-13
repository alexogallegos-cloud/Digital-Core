CREATE PROCEDURE "informix".sp_ctamec_consultarinfoctamoral(pEmpresa CHAR(3), pCuenta CHAR(20))

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
	
	--SET DEBUG FILE TO "/respaldosbd/hectorb/sp_ctamec_consultarinfoctamoral.out";
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
	
	--OBTENEMOS LA DESCRIPCION DEL REGIMEN DE FIRMAS Y LA COMBINACION
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
'Descripcion: Se agrega el "sufijo" a la variable de retorno "cNombre" para que aparesca en la aplicacion asociada al procedimiento';

CREATE PROCEDURE "informix".sp_ctamec_generarrpthojadefirmas (pEmpresa CHAR(3), pCuenta CHAR(20))

	-- DATOS A REGRESAR --
RETURNING	CHAR(6)		AS COD_RET,			 -- Codigo de retorno
			CHAR(60)	AS MENSAJE_EJEC,	 -- Mensaje de la ejecucion
			CHAR(40)	AS DESC_PRODUCTO,	 -- Descripcion del producto
			CHAR(20)	AS NUM_CTE,			 -- Numero de cliente
			CHAR(104) 	AS NOMBRE_CTE,    	 -- Nombre de cliente
			CHAR(4)		AS COD_SUCURSAL,	 -- Codigo de sucursal
			CHAR(30)	AS DESC_MONEDA,		 -- Descripcion de la moneda
			DATE		AS FECHA_ALTA,		 -- Fecha de alta de la cuenta
			DATE		AS FECHA_MODIFIC,	 -- Fecha de modificacion de firmantes
			CHAR(20)	AS REGIMEN,			 -- Regimen de firma relacionado a la cuenta
			CHAR(20)    AS ESPECIF_MANEJO,	 -- Especificaciones de manejo del regimen de la firma
			CHAR(104)	AS NOMBRE_FIRMANTE1,  -- Nombre del firmante	
			CHAR(20)    AS FIRMANTE1,
			CHAR(104)	AS NOMBRE_FIRMANTE2,  -- Nombre del firmante	
			CHAR(20)    AS FIRMANTE2,
			CHAR(104)	AS NOMBRE_FIRMANTE3,  -- Nombre del firmante	
			CHAR(20)    AS FIRMANTE3,
			CHAR(104)	AS NOMBRE_FIRMANTE4,  -- Nombre del firmante	
			CHAR(20)    AS FIRMANTE4;
	
	--	VARIABLES CONTROL DE ERRORES --
	
	DEFINE cCodRet			CHAR(6);
	DEFINE sql_err			INTEGER;
	DEFINE cMensaje			CHAR(60);
	
	-- VARIABLES --
	
	DEFINE cNumcte			CHAR(20);
	DEFINE cNombre			CHAR(104);
	DEFINE cCodSuc			CHAR(4);	
	DEFINE cCodProd			CHAR(4);
	DEFINE cNomProd			CHAR(40);
	DEFINE cCodMoneda		CHAR(2);
	DEFINE dfecha_alta		DATE;
	DEFINE cCodRegimen		CHAR(1);
	DEFINE cDescRegimen		CHAR(20);
	DEFINE cCombinacion		CHAR(20);
	DEFINE cDescMoneda		CHAR(30);
	DEFINE dUltModif		DATE;
	DEFINE cNumcteFirm		CHAR(20);
	DEFINE cNombreFirm		CHAR(104);
	DEFINE cNombreFirm1		CHAR(104);
	DEFINE cFirma1          CHAR(20);
	DEFINE cNombreFirm2		CHAR(104);
	DEFINE cFirma2          CHAR(20);
	DEFINE cNombreFirm3		CHAR(104);
	DEFINE cFirma3          CHAR(20);
	DEFINE cNombreFirm4		CHAR(104);
	DEFINE cFirma4          CHAR(20);
    DEFINE sSecuencia       SMALLINT;
    DEFINE iNumRegs         INTEGER;
    DEFINE iContador        INTEGER;
	DEFINE cSufijo          CHAR(60);	--DSB 16/05/2013
	
	-- INICIALIZACION DE VARIABLES --
	
	LET cCodRet			= '000000';
	LET cMensaje		= 'LA EJECUCION SE REALIZO EXITOSAMENTE';
	LET cCodSuc			= '';
	LET cNumcte			= '';
	LET cCodProd		= '';
	LET cNomProd		= '';
	LET cCodMoneda		= '';
	LET cNombre			= '';
	LET dfecha_alta		= '';
	LET cCodRegimen		= '';
	LET cDescRegimen	= '';
	LET cCombinacion	= '';
	LET cDescMoneda		= '';
	LET dUltModif		= '01/01/2000';
	LET cNumcteFirm		= '';
	LET cNombreFirm     = '';
	LET cNombreFirm1    = '';
	LET cFirma1         = 'C A N C E L A D O';
	LET cNombreFirm2    = '';
	LET cFirma2         = 'C A N C E L A D O';
	LET cNombreFirm3    = '';
	LET cFirma3         = 'C A N C E L A D O';
    LET cNombreFirm4    = '';
    LET cFirma4         = 'C A N C E L A D O';
    LET sSecuencia      = 0;
    LET iNumRegs        = 0;
    LET iContador       = 0;
	LET cSufijo         = '';	--DSB 16/05/2013

	-- CONTROL DE ERRORES --	
	BEGIN
	ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCodRet = sql_err;
            LET cMensaje = 'ERROR INESPERADO EN LA EJECUCION';
			
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
        END IF
	END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    --SET DEBUG FILE TO "/respaldosbd/joseluis/sp_ctamec_generarrpthojadefirmas.out";
    --TRACE ON;
	
	-- VALIDACION DE PARAMETROS
	IF pEmpresa = '' OR pEmpresa IS NULL OR pCuenta = '' OR pCuenta IS NULL THEN
		LET cCodRet = '100';
		LET cMensaje = 'ERROR EN LOS PARAMETROS; AMBOS PARAMETROS SON OBLIGATORIOS';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
					
	ELIF LENGTH(pEmpresa) <> 3 OR pEmpresa <> '001' THEN
		LET cCodRet = '500';
		LET cMensaje = 'PARAMETRO EMPRESA NO VALIDO; VERIFIQUE';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	END IF;
	
	-- CONSULTA DE INFORMACION DE LA CUENTA
	SELECT sucursal, num_cte, producto
	INTO cCodSuc, cNumcte, cCodProd
	FROM bdicheq:'informix'.sc_maechq
	WHERE empresa = pEmpresa
	AND cuenta = pCuenta;
	
	-- SE VALIDA SI LA CUENTA EXISTE
	IF cNumcte IS NULL OR cNumcte = '' THEN
		LET cCodRet = '200';
		LET cMensaje = 'ERROR; NO EXISTE LA CUENTA';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	END IF;
	
	-- SE TOMA INFORMACION DE LA MONEDA
	SELECT nombre, divisa
	INTO cNomProd, cCodMoneda
	FROM bdicheq:'informix'.sc_producto
	WHERE empresa = pEmpresa
	AND producto = cCodProd;
	
	-- SE VALIDA SI EL PRODUCTO EXISTE
	IF cNomProd IS NULL OR cNomProd = '' THEN
		LET cCodRet = '210';
		LET cMensaje = 'ERROR; NO EXISTE EL PRODUCTO';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	END IF;

	-- SE TOMA EL NOMBRE DEL CLIENTE .. YA SEA PERSONA FISICA O MORAL
	SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno) || ' ' || TRIM(razon_social)
	INTO cNombre
	FROM bdinteg:'informix'.si_cliente
	WHERE empresa = pEmpresa
	AND numcte = cNumcte;	
	
	--DSB 16/05/2013
	SELECT NVL(descripcion, '')
	INTO cSufijo
	FROM bdinteg:"informix".si_sufijos suf,
	bdinteg:"informix".si_ctepm cte
	WHERE suf.codigo = cte.sufijo 
	AND cte.numcte = cNumCte;
	LET cNombre = TRIM(cNombre)||" "||TRIM(NVL(cSufijo, ''));
	
	-- SE CONSULTA INFORMACION DE LA CUENTA
	SELECT fecha_alta, reg_firmas
	INTO dfecha_alta, cCodRegimen
	FROM bdicheq:'informix'.sc_maenoc
	WHERE empresa = pEmpresa
	AND cuenta = pCuenta;
	
	-- SE CONSULTA INFORMACION DEL REGIMEN DE FIRMA RELACIONADO CON LA CUENTA
	SELECT descripcion, combinacion
	INTO cDescRegimen, cCombinacion
	FROM bdicntchq:'informix'.sq_catregimen
	WHERE cve_regimen = cCodRegimen;
	
	-- SE VALIDA QUE EL REGIMEN ES CORRECTO
	IF cDescRegimen IS NULL OR cDescRegimen = '' THEN
		LET cCodRet = '220';
		LET cMensaje = 'ERROR; NO EXISTE EL REGIMEN DE FIRMAS';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	END IF;
	
	-- SE TOMA INFORMACION DE LA MONEDA
	SELECT descripcion
	INTO cDescMoneda
	FROM bdinteg:'informix'.si_divisas
	WHERE divisa = cCodMoneda;
	
	-- SE VALIDA QUE LA MONEDA EXISTE
	IF cDescMoneda IS NULL OR cDescMoneda = '' THEN
		LET cCodRet = '230';
		LET cMensaje = 'ERROR; NO EXISTE LA MONEDA';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	END IF;
	
	-- SE TOMA LA FECHA DEL MAS RECIENTE REGISTRO DE FIRMANTES
	SELECT MAX(fecha_insert)
	INTO dUltModif
	FROM bdinteg:'informix'.si_cterelacionado
	WHERE empresa = pEmpresa
	AND cuenta = pCuenta;
	
	-- SE VALIDA QUE EXISTAN FIRMANTES
	IF dUltModif IS NULL OR dUltModif = '' THEN
		LET cCodRet = '333';
		LET cMensaje = 'LA CUENTA NO TIENE FIRMANTES RELACIONADOS';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	
	ELIF dfecha_alta = dUltModif THEN -- NO EXISTE FECHA DE MODIFICACION, SOLO DE CREACION
		LET dUltModif = '01/01/2000';	
	END IF;
	
	-- SE HACE MAYUSCULA LA DESCRIPCION DEL REGIMEN
	LET cDescRegimen = UPPER(cDescRegimen);	
  
	-- SE CONSULTAN LOS FIRMANTES RELACIONADOS CON LA CUENTA
	FOREACH
		SELECT numcte, secuencia
		INTO cNumcteFirm, sSecuencia
		FROM bdicheq:'informix'.sc_firmantes
		WHERE empresa = pEmpresa
		AND cuenta = pCuenta
		ORDER BY secuencia
		
		-- SE INCREMENTA CONTADOR PARA IDENTIFICAR LA POSICION QUE OCUPARA EN EL REPORTE
		LET iContador = iContador + 1;
		
		-- SE CONSULTA EL NOMBRE DEL FIRMANTE .. SOLO PERSONA FISICA
		SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno)
		INTO cNombreFirm
		FROM bdinteg:'informix'.si_cliente
		WHERE empresa = pEmpresa
		AND numcte = cNumcteFirm;
		
			-- SE VALIDA SI ES EL FIRMANTE TITULAR DE LA CUENTA
			IF iContador = 1 THEN
			   LET cNombreFirm1 = cNombreFirm;
			   IF cNombreFirm1 <> '' THEN
			       LET cFirma1 = '';
			   END IF;
			   
			ELIF iContador = 2 THEN -- SE VALIDA SI ES EL FIRMANTE ADICIONAL 1 DE LA CUENTA
			   LET cNombreFirm2 = cNombreFirm;
			   IF cNombreFirm2 <> '' THEN
			       LET cFirma2 = '';
			   END IF;
			   
			ELIF iContador = 3 THEN -- SE VALIDA SI ES EL FIRMANTE ADICIONAL 2 DE LA CUENTA
			   LET cNombreFirm3 = cNombreFirm;
			   IF cNombreFirm3 <> '' THEN
			       LET cFirma3 = '';
			   END IF;
			   
			ELIF iContador = 4 THEN -- SE VALIDA SI ES EL FIRMANTE ADICIONAL 3 DE LA CUENTA
			   LET cNombreFirm4 = cNombreFirm;
			   IF cNombreFirm4 <> '' THEN
			       LET cFirma4 = '';
			   END IF;

			END IF;
            
	END FOREACH;
		-- SE REALIZA SOLO UN RETORNO QUE INCLUYE TODA LA INFORMACION DE LA CUENTA.
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	
END
END PROCEDURE 
DOCUMENT
'MODIFICO: Valentin Lopez',
'FECHA: 20 de Junio del 2011',
'DESCRIPCION: Procedimiento que llena el reporte de hoja de firmas.',
'VERSION: 20110620.1042',
'BD: BDICHEQ',
'Modifico: Jose Luis Polanco B.',
'Fecha: DSB 16/05/2013',
'Descripcion: Se agrega el "sufijo" a la variable de retorno "cNombre" para que aparesca en los reportes';

CREATE PROCEDURE "informix".pasamovshistold_temp(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER, INTEGER;
    
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha_ant       DATE;
    DEFINE vfecha_nva       CHAR(10);
    DEFINE vexiste          SMALLINT;
    DEFINE vexistefin       SMALLINT;
    DEFINE vfechaproc       DATE;
    DEFINE vsql             char(600);
    DEFINE vstmt            char(250);
    DEFINE vexistefinproc   CHAR(1);
    DEFINE vproceso         CHAR(15);
    DEFINE vsistema         CHAR(2);
    DEFINE vusuario         CHAR(10);
    DEFINE vexiste_fecha    SMALLINT;
    
    DEFINE vno_regs         INTEGER;
    DEFINE vcodretparam     CHAR(5);
    DEFINE vserial_final    INTEGER;
    DEFINE vcomienza        INTEGER;
    DEFINE vcont_commit     INTEGER;
    DEFINE vnum_serial      INTEGER;
    DEFINE vfincomp1        SMALLINT;
    DEFINE vfincomp2        SMALLINT;
    
    LET vcodret1        = '000';
    LET vcodret2        = '000';
    LET sql_err	        = 0;
    LET isam_err        = 0;
    LET vcontador1      = 0;
    LET vcontador2      = 0;
    LET vcontador3      = 0;
    LET ven_transacc    = 0; 
    
    LET vfecha_hoy      = ''; 
    LET vfecha_ant      = '';
    LET vfecha_nva      = '';
    LET vexiste         = 0;
    LET vexistefin      = 0;
    LET vfechaproc      = '';
    LET vsql            = '';
    LET vstmt           = '';
    LET vexistefinproc  = '';
    LET vproceso        = 'PasaMovsHistOld';
    LET vsistema        = '01';
    LET vusuario        = user;
    LET vexiste_fecha   = 0;
    
    LET vno_regs        = 0;
    LET vcodretparam    = '';   
    LET vserial_final   = 0;
    LET vcomienza       = -1;
    LET vcont_commit    = 0;
    LET vnum_serial     = 0;
    LET vfincomp1       = 0;
    LET vfincomp2       = 0;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/pasamovshistold.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'C'||''','||
                       'codret        = '''||vcodret1||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold.sql';
            SYSTEM vstmt;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/pasamovshistold.out";
    --- TRACE ON;
    
    SET OPTIMIZATION HIGH;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE LAS FECHAS DEL SISTEMA
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    SELECT valor
      INTO vfecha_ant
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'PasoMovhis_MovhisOld';
     
    -- // Guarda inicio de proceso     
    SELECT COUNT(*)
      INTO vexiste
      FROM bdinteg:sx_contproc
     WHERE empresa = pempresa
       AND proceso = vproceso
       AND fecha   = vfecha_hoy
       AND sistema = vsistema;

    IF vexiste = 0 THEN
        LET vsql = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||vproceso||''', '''||vfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||vusuario||''','||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horaspasamovsold.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold.sql';
        SYSTEM vstmt;
    ELSE
        SELECT COUNT(*)
          INTO vexistefin
          FROM bdinteg:sx_contproc
         WHERE empresa = pempresa
           AND proceso = vproceso
           AND fecha   = vfecha_hoy
           AND sistema = vsistema
           AND status_proc = "F";
           
        IF vexistefin = 0 THEN
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'I'||''','||
                       'codret        = '''||' '||''','||
                       'hora_fin      = '''||' '||''','||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold.sql';
            SYSTEM vstmt;
        ELSE
            SELECT "1"
              INTO vexistefinproc
              FROM sc_contproc
             WHERE empresa = pempresa
               AND proceso = "pasomovshistold"
               AND fecha = vfecha_ant;
               
            IF vexistefinproc = "1" THEN
                LET vcodret1 = "958";
                RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
            END IF
        END IF;
    END IF;
    
    -- // OBTIENE NUMERO DE REGISTROS A TRASPASAR
    SELECT COUNT(*)
      INTO vexiste_fecha
      FROM sc_trasp_movhis_movhisold
     WHERE fecha = vfecha_ant;
     
    IF vexiste_fecha = 0 THEN
        SELECT {+INDEX(sc_movhis idx_movhis_serial)} 
               COUNT(*)
          INTO vno_regs
          FROM sc_movhis
         WHERE fech_alt = vfecha_ant
           AND num_serial > 0; 
         
        INSERT INTO sc_trasp_movhis_movhisold(fecha, no_regs)
        VALUES(vfecha_ant, vno_regs);
    ELSE
        SELECT no_regs
          INTO vno_regs
          FROM sc_trasp_movhis_movhisold
         WHERE fecha = vfecha_ant;
    END IF;
    
    -- // INVOCA PROCESO PARA ACTUALIZAR PARAMETROS DE NUMEROS DE SERIALES
    ---EXECUTE PROCEDURE "informix".sp_actparampasomovshisold(pempresa, vfecha_ant)
    ---INTO vcodretparam;
    
    ---IF vcodretparam <> '000' THEN
        ---LET vcodret1 = '975';
        ---LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   ---'SET ejecutivo = '''||vusuario||''','||
                   ---'status_proc   = '''||'C'||''','||
                   ---'codret        = '''||vcodret1||''','||
                   ---'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   ---'WHERE empresa = '''||pempresa||''' '||
                   ---'AND proceso   = '''||vproceso||''' '||
                   ---'AND fecha     = '''||vfecha_hoy||''' '||
                   ---'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold.sql';
        ---SYSTEM vsql;
        ---LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold.sql';
        ---SYSTEM vstmt;
        ---RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
    ---END IF;
    
    -- // ACTUALIZA BANDERA DE INICIO DE PROCESO
    UPDATE sc_contproc
       SET fecha = vfecha_ant
     WHERE empresa = pempresa
       AND proceso = 'ini_pasomovshistold';
    
    -- // OBTIENE VALORES PARA RANGO DE SERIALES A PROCESAR
    SELECT valor::integer
      INTO vserial_final
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'SerIniPasoMovHisOld1';
       
    -- // OBTIENE EL NUMERO DE REGISTROS A TRASPASAR
    SELECT {+INDEX(sc_movhis idx_movhis_serial)} 
           COUNT(*)
      INTO vcontador1
      FROM sc_movhis
     WHERE fech_alt = vfecha_ant
       AND num_serial < vserial_final;
    
    -- // TRASPASO DE REGISTROS DE MOVDIA A MOVHIS
    FOREACH WITH HOLD 
        SELECT {+INDEX(sc_movhis idx_movhis_serial)} 
               num_serial
          INTO vnum_serial
          FROM sc_movhis
         WHERE fech_alt = vfecha_ant
           AND num_serial < vserial_final
          
        /*
        IF vcomienza = -1 THEN
            BEGIN WORK;
            LET vcomienza = 0;
            LET ven_transacc = 1;
        END IF;
        */
        
        BEGIN WORK;
        LET ven_transacc = 1;
        
        INSERT INTO sc_movhis_old
        SELECT {+INDEX(sc_movhis idx_movhis_serial)} 
               mov.*
          FROM sc_movhis mov
         WHERE mov.fech_alt = vfecha_ant
           AND mov.num_serial = vnum_serial;
         
        DELETE {+INDEX(sc_movhis idx_movhis_serial)}
          FROM sc_movhis
         WHERE fech_alt = vfecha_ant
           AND num_serial = vnum_serial;
         
        LET vcont_commit = vcont_commit + 1;
        
        COMMIT WORK;
        LET ven_transacc = 0;
        
        /*
        IF vcont_commit >= 5000 THEN
            COMMIT WORK;
            BEGIN WORK;
            LET vcont_commit = 0;
        END IF;
        */
    END FOREACH;
    
    /*
    IF ven_transacc = 1 THEN
        COMMIT WORK;
        LET ven_transacc = 0;
    END IF;
    */
    
    SELECT {+INDEX(sc_movhis_old idx_movhis_serial_old)}
           COUNT(*)
      INTO vcontador2
      FROM sc_movhis_old
     WHERE fech_alt = vfecha_ant
       AND num_serial < vserial_final;
     
    SELECT {+INDEX(sc_movhis idx_movhis_serial)}
           COUNT(*)
      INTO vcontador3
      FROM sc_movhis
     WHERE fech_alt = vfecha_ant
       AND num_serial < vserial_final;
       
    IF vcontador1 = vcontador2 THEN        
        WHILE ( vfincomp1 = 0 OR vfincomp2 = 0 )
            SET ISOLATION TO DIRTY READ;
            
            SELECT COUNT(*)
              INTO vfincomp1
              FROM sc_contproc
             WHERE proceso = 'pasomovshistoldcomp1'
               AND fecha = vfecha_ant;
               
            SELECT COUNT(*)
              INTO vfincomp2
              FROM sc_contproc
             WHERE proceso = 'pasomovshistoldcomp2'
               AND fecha = vfecha_ant;
        END WHILE;
        
        LET vfecha_nva = to_char(vfecha_ant + 1 UNITS DAY, '%m/%d/%Y');
    
        UPDATE sc_param
           SET valor = vfecha_nva
         WHERE empresa = pempresa
           AND codparam = 'fechcon_movhis';
           
        UPDATE sc_param
           SET valor = vfecha_nva
         WHERE empresa = pempresa
           AND codparam = 'PasoMovhis_MovhisOld';
        
        LET vcodret1 = '000'; -- // PROCESO CONCLUIDO SATISFACTORIAMENTE
        LET vcodret2 = '000';
        
        LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET ejecutivo = '''||vusuario||''','||
                   'status_proc   = '''||'F'||''','||
                   'codret        = '''||vcodret1||''','||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vfecha_hoy||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold.sql';
        SYSTEM vstmt;
           
        UPDATE sc_contproc
           SET fecha   = vfecha_ant
         WHERE empresa = pempresa
           AND proceso = 'pasomovshistold';
    ELSE
        LET vcodret1 = '999'; -- // LOS MOVIMIENTOS TRASPASADOS NO COINCIDEN CON LOS MOVIMIENTOS A TRASPASAR
        LET vcodret2 = '999';
        
        LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET status_proc   = '''||'C'||''','||
                   'codret        = '''||vcodret1||''','||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vfecha_hoy||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horaspasamovsold.sql';
        SYSTEM vsql;
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaspasamovsold.sql';
        SYSTEM vstmt;
    END IF;
       
    END;
    
    RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
    
END PROCEDURE;