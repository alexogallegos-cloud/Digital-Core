CREATE PROCEDURE "informix".sp_validausuarioremesa(pNombre1 CHAR(26), pNombre2 CHAR(26), pApell_paterno CHAR(26), pApell_materno CHAR(26), pFecha_nac DATE)
RETURNING
CHAR(5)  AS  cCodRet,
CHAR(20) AS  cNumcte,
CHAR(1)  AS  iTipoCliente,
CHAR(5)  AS	 cValIne,
CHAR(5)  AS	 cListaNegra,
CHAR(5)	 AS	 cSespecial,
CHAR(13) AS	 cRfc;


DEFINE cCodRet 		CHAR(5);
DEFINE cNumcte		CHAR(20);
DEFINE iTipoCliente	CHAR(1);
DEFINE cValIne		CHAR(5);
DEFINE cResultINE	CHAR(50);
DEFINE cListaNegra	CHAR(5);
DEFINE cSespecial	CHAR(5);
DEFINE cStatuscte	CHAR(1);
DEFINE cRfc			CHAR(13);
DEFINE cCodRetRfc	CHAR(5);

DEFINE iSqlErr      INTEGER; 
DEFINE iIsamErr    	INTEGER; 
DEFINE cInfoErr 	CHAR(10); 

DEFINE icontEsp 	INTEGER;
DEFINE iContList	INTEGER;

--EPG
DEFINE cSituacion   CHAR(5);
DEFINE cCausa       CHAR(5);
DEFINE iContListRfc	INTEGER;
DEFINE cRfccte		CHAR(13);


LET cCodRet	= "00000";
LET cNumcte = "0";
LET iTipoCliente = "0";
LET cValIne = "False";
LET cListaNegra = "False";
LET cSespecial = "False";
LET cStatuscte = "";
LET cRfc = "";
LET icontEsp 	 = 0;
LET iContList 	 = 0;

--EPG
LET cSituacion  = '';
LET cCausa      = '';
LET iContListRfc = 0;
LET cRfcCte      = "";

--SET DEBUG FILE TO '/home/c90303528/sp_validausuarioremesa.log';
--TRACE ON;	

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr::CHAR(5);
			RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
		END IF;
	END EXCEPTION;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	LET pNombre1 = TRIM(pNombre1)||' '||TRIM(pNombre2);
	--LET pNombre2 = TRIM(pNombre2);
	LET pApell_paterno = TRIM(pApell_paterno);
	LET pApell_materno = TRIM(pApell_materno);
	
	EXECUTE PROCEDURE bdinteg:sp_calcularrfc(pApell_paterno,pApell_materno,pNombre1,pFecha_nac) INTO cCodRetRfc, cRfc;
	
	IF NVL(cCodRetRfc,'') <> '00000' THEN
		LET cCodRet = cCodRetRfc;
		RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
	END IF;
	
	SELECT FIRST 1 cterem.numcte, "1", cterem.status_cte, cte.rfc
	INTO cNumcte, iTipoCliente, cStatuscte, cRfcCte
	FROM bdinteg:"informix".si_cliente cte INNER JOIN
	bdinteg:"informix".si_ctepf ctepf ON cte.numcte = ctepf.numcte INNER JOIN
	bdisac:"informix".sac_cte_remesas cterem ON cterem.numcte = cte.numcte
	WHERE cte.rfc = cRfc;
	--WHERE cte.nombre1 = pNombre1 AND cte.nombre2 = pNombre2 AND cte.apell_paterno = pApell_paterno AND cte.apell_materno = pApell_materno AND ctepf.fecha_nac = pFecha_nac;
			
	IF NVL(cNumcte,"") = "" THEN
		SELECT FIRST 1 cte.numcte, "2", cte.rfc
		INTO cNumcte, iTipoCliente, cRfcCte
		FROM bdinteg:"informix".si_cliente cte INNER JOIN
		bdinteg:"informix".si_ctepf ctepf on cte.numcte = ctepf.numcte 
		WHERE cte.rfc = cRfc AND cte.tipo_cliente in("1","2");
		--WHERE cte.nombre1 = pNombre1 AND cte.nombre2 = pNombre2 AND cte.apell_paterno = pApell_paterno AND cte.apell_materno = pApell_materno AND ctepf.fecha_nac = pFecha_nac AND cte.tipo_cliente in("1","2");
		
		IF NVL(cNumcte,"") = "" THEN
			LET cNumcte = "000000000";
			LET iTipoCliente = "3";
			
			SELECT COUNT(*) INTO iContListRfc FROM bdiauditor:"informix".tbl_listainterna  WHERE rfc = cRfc;
			LET iContList = iContList + iContListRfc;
			IF iContList > 0 THEN
				LET cListaNegra = "True";
			    LET iTipoCliente = "2";
				LET cNumcte = "000000001";
			END IF;
	
			RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
		END IF;
	ELSE
		IF TRIM(cStatuscte) <> "A" THEN
			LET cCodRet = "00003";
			RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
		END IF;
	END IF;
	SELECT resultado 
	INTO cResultINE
	FROM bdinteg:"informix".si_bitacora_ife WHERE numcte = cNumcte AND fecha = (SELECT MAX(fecha) FROM bdinteg:"informix".si_bitacora_ife WHERE numcte = cNumcte);
	
	IF (TRIM(NVL(cResultINE,"")) = "") OR (UPPER(TRIM(cResultINE)) = "VERDADERO") OR (UPPER(TRIM(cResultINE)) = "TRUE") THEN
		LET cValIne = "True";
	ELIF (UPPER(TRIM(cResultINE)) = "FALSO") OR (UPPER(TRIM(cResultINE)) = "FALSE") THEN
		LET cValIne = "False";
	END IF;
	
  --IF EXISTS(SELECT * FROM bdiauditor:"informix".tbl_listainterna WHERE numcte = pNumCte) THEN
	SELECT COUNT(*) INTO iContList FROM bdiauditor:"informix".tbl_listainterna WHERE numcte = cNumCte;
	SELECT COUNT(*) INTO iContListRfc FROM bdiauditor:"informix".tbl_listainterna  WHERE rfc = cRfc;
	LET iContList = iContList + iContListRfc;
	 IF iContList > 0 THEN
		LET cListaNegra = "True";
	ELSE
		LET cListaNegra = "False";
	END IF;
	
    --IF EXISTS(SELECT * FROM bdisitesp:"informix".se_ctessitespcte where numcte = pNumCte) THEN
	SELECT COUNT(*) INTO icontEsp FROM bdisitesp:"informix".se_ctessitespcte where numcte = cNumCte;
	IF icontEsp > 0 THEN
		SELECT situacion, causa INTO cSituacion, cCausa FROM bdisitesp:"informix".se_ctessitespcte where numcte = cNumCte;
		LET cSituacion = TRIM(cSituacion)||TRIM(cCausa);
		IF 	cSituacion IN ('F42','P72','P108','U60') THEN
			LET cSespecial = "True";
		ELSE
			LET cSespecial = "False";
		END IF;
	ELSE
		LET cSespecial = "False";
	END IF;
	
	RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
	
END;
END PROCEDURE
DOCUMENT
'Folio: 433 REQ. Base de datos para el alta de usuarios de remesas',
'Autor: 98243217 Marco Rivera ',
'Fecha: 09/08/2018',
'Descripcion: Verifica e identifica el tipo de cliente.',
'Solicita: Leonardo Hernandez',
'BD: bdisac',
'-------------------------------------------------------------------',
'Folio: 496 Homologacion del proyecto RQM 10 784-2 - Base de datos para el alta de usuarios de remesas / Nueva estructura INE',
'Autor: 98243217 Marco Rivera ',
'Fecha: 20/10/2018',
'Descripcion: Se agrega validacion para la busqueda en si_bitacora_ife.',
'Solicita: Leonardo Hernandez',
'BD: bdisac';

CREATE OR REPLACE PROCEDURE "informix".sp_tae_notifications(pFolio_operacion CHAR(18))
    RETURNING CHAR(5);

	DEFINE vCodRet				CHAR(5);
	DEFINE vEmpresa 			CHAR(25);
	DEFINE sqlErr				INTEGER;
	DEFINE vNumCte 				CHAR(20);
	DEFINE vNumCta 				CHAR(20);
	DEFINE cIdPlantilla 		CHAR(10);
	DEFINE cIdMsj 				CHAR(10);
	DEFINE cIdPlantillaPush 	CHAR(11);
	DEFINE cIdMsjPush 			CHAR(10);
	DEFINE cIdPlantillaSms  	CHAR(11);
	DEFINE cIdMsjSms 			CHAR(10);
	DEFINE iEstatus				SMALLINT;
	DEFINE vCodRetInt 			CHAR(5);
	
	--Datos para el mensaje
	DEFINE cCuentaCen			CHAR(30);
	DEFINE cNumeroCelular		CHAR(40);
	DEFINE cNombres				CHAR(30);
	DEFINE cApellidos			CHAR(30);
	DEFINE cImporte				CHAR(40);
	DEFINE cProveedor			CHAR(40);
	DEFINE cNumAutorizacion		CHAR(40);
	DEFINE cTelefonoProveedor	CHAR(40);
	DEFINE vTelefono			CHAR(13);
	DEFINE vCorreo 				VARCHAR(100);

	DEFINE cCategoria			CHAR(2);
	DEFINE cConvenio			CHAR(3);
	DEFINE cTrans_cargo_cte		CHAR(4);

	LET vCodRet 				= "00000";
	LET vEmpresa 				= "";
	LET sqlErr 					= 0;
	LET vNumCte 				= "";
	LET vNumCta 				= "";
	LET cIdPlantilla 			= "";
	LET cIdMsj 					= "";
	LET cIdPlantillaPush 		= "";
	LET cIdMsjPush 				= "";
	LET cIdPlantillaSms 		= "";	
	LET cIdMsjSms 				= "";
	LET iEstatus				= 0;
	LET vCodRetInt 				= "";
	
	LET cNombres				="";
	LET cApellidos				="";
	LET cCuentaCen				="";
	LET cNumeroCelular			="";
	LET cImporte				="";
	LET cProveedor				="";
	LET cNumAutorizacion		="";
	LET cTelefonoProveedor 		="";
	LET vTelefono				="";
	LET vCorreo					="";

	LET cCategoria				="";
	LET cConvenio				="";
	LET cTrans_cargo_cte		="";

	BEGIN
		ON EXCEPTION SET sqlErr
			IF sqlErr <> 0 THEN
				LET vCodRet = sqlErr;
				RETURN vCodRet;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/home/syscybmdp1/Osiel/sp_tae_notifications.out';
	    --TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		

		--LET cIdPlantillaSms 		= "TAE_SMS";
		--LET cIdMsjSms 				= "PORTAL_SMS";

		LET cIdPlantilla 			= "TAE_EMAIL";
		LET cIdMsj 					= "PORTAL_BPI";

		--LET cIdPlantillaPush 		= "TAE_PUSH";
		--LET cIdMsjPush 				= "PNS_BEX";

		SELECT numcategoria, numconvenio, referencia1, referencia2, TRIM(TO_CHAR(importe_pago::INTEGER)), referencia4
		INTO  cCategoria, cConvenio, cNumeroCelular,cProveedor, cImporte, cNumAutorizacion
		FROM "informix".sac_movimientos
		WHERE folio_suc = pFolio_operacion;
				
		SELECT FIRST 1 tlf_compania
		INTO cTelefonoProveedor  
		FROM "informix".sac_catalogos_taecoppel
		WHERE compania = cProveedor;
				
		select 
		  --trim(descripcion),
            TRIM(c.num_cte),
            TRIM(c.cuenta), 
            TRIM(nombre1)||' '||TRIM(nombre2), 
            TRIM(apell_paterno)||' '||TRIM(apell_materno),
            TRIM(t.telefono),
            TRIM(e.correo_elec),
            'xxxxxxxxx-'||right(trim(c.cuenta),3)
        into vNumCte, vNumCta, cNombres, cApellidos, vTelefono, vCorreo, cCuentaCen     
        from bdicheq:sc_movdia a, 
            bdinteg:si_transacc b, 
            bdicheq:sc_maechq c,  
            bdinteg:si_cliente d,
            bdinteg:si_telefonos_actual t,
            bdinteg:si_correos e
        where 
            a.cuenta=c.cuenta 
            and numero=transacc 
            and d.numcte=c.num_cte
            and t.numcte=c.num_cte
            and e.numcte=c.num_cte
            and t.tipo_tel='2'
            and status_tel='A'
            and e.tipo_correo='1'
            and e.status_correo='A'
            and  folio_suc =pFolio_operacion
            and b.naturaleza='C';

		--Envia EMAIL
		EXECUTE PROCEDURE bdimnsj: "informix".sp_registra_evento(1,cIdMsj, cIdPlantilla,vNumCte, cCuentaCen,'', '1', cNombres, cApellidos, cCuentaCen, cNumeroCelular, cImporte, cProveedor, cNumAutorizacion, cTelefonoProveedor, pFolio_operacion, '', '', '', 0, 0, 0, 0, 0,current,current) INTO vCodRetInt;
		
		--SMS	
		--EXECUTE PROCEDURE bdimnsj: "informix".sp_registra_evento(1,cIdMsjSms, cIdPlantillaSms,'000000000', cCuentaCen,'', '1', vNumCta, '', '', '', cImporte, cProveedor, '', cTelefonoProveedor, '', '', '', vTelefono, 0, 0, 0, 0, 0,current,current) INTO vCodRetInt;
		
		--Envia PUSH
		--EXECUTE PROCEDURE bdimnsj: "informix".sp_registra_evento(1,cIdMsjPush, cIdPlantillaPush,vNumCte, cCuentaCen,'', '1', vNumCta, vNumCta, '', '', cImporte, '', '', '', '', '', '', vTelefono, 0, 0, 0, 0, 0,current,current) INTO vCodRetInt;

		RETURN vCodRet; 

	END;
END PROCEDURE
DOCUMENT
'Autor: Jorge Rivas',
'Fecha: 2022/09/14',
'Peticion: PAGO DE SERVICIOS',
'Descripcion: Esta tabla almacena las notificaciones en el proceso de latinia para TAE exitoso',
'---------------------------------------------------------------------------------------------',
'MODIFICO : Christopher Siverio',
'Peticion: PAGO DE SERVICIOS',
'DESCRIPCION: SE MODIFICA PARAMETROS PARA SMS Y EMAIL',
'EJECUTADO O LLAMADO POR: Procesos - Pago de servicios TAECOPPEL',
'Fecha: 2022/11/08',
'---------------------------------------------------------------------------------------------',
'MODIFICO : Jorge Rivas',
'Peticion: PAGO DE SERVICIOS',
'DESCRIPCION: SE MODIFICA QUE TOME SOLO LAS TRANSACCIONES DE CARGO AL CLIENTE',
'EJECUTADO O LLAMADO POR: Procesos - Pago de servicios TAECOPPEL',
'Fecha: 2023/01/12',
'---------------------------------------------------------------------------------------------',
'MODIFICO : Brando Garcia',
'Peticion: PAGO DE SERVICIOS',
'DESCRIPCION: SE MODIFICA QUE LA TRANSACCION DE CARGO AL CLIENTE SEA CONSULTADO POR EL MOVIMIENTO',
'EJECUTADO O LLAMADO POR: Procesos - Pago de servicios TAECOPPEL',
'Fecha: 2023/01/12',
'BD: bdisac',
'---------------------------------------------------------------------------------------------',
'MODIFICO : Brando Garcia',
'Peticion: PAGO DE SERVICIOS',
'DESCRIPCION: SE MODIFICA CONSULTA EN SAC_MOVIMIENTOS PARA QUE EL IMPORTE NO CONTENGA SIGNO DE PESO',
'EJECUTADO O LLAMADO POR: Procesos - Pago de servicios TAECOPPEL',
'Fecha: 2023/07/17',
'BD: bdisac',
'---------------------------------------------------------------------------------------------',
'MODIFICO : Jorge Rivas',
'Peticion: PAGO DE SERVICIOS',
'DESCRIPCION: SE AGREGA FOLIO DE OPERACION PARA ENVIO DE CORREO',
'Fecha: 2024/08/05',
'BD: bdisac',
'---------------------------------------------------------------------------------------------',
'MODIFICO : Jorge Rivas / Leon Fernando',
'Peticion: PAGO DE SERVICIOS',
'DESCRIPCION: Se realiza cambio para optimizar el sp y homologar las consultas en un mismo SELECT',
'Fecha: 2024/09/09',
'BD: bdisac',
'---------------------------------------------------------------------------------------------',
'MODIFICO : Osiel Alfredo Camacho Mendoza',
'Peticion: PAGO DE SERVICIOS',
'DESCRIPCION: Se realiza cambio para optimizar el envio de SMS por medio del inots en latinia',
'Fecha: 2026/04/02',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_app_valmonto_cpl(
	pEmpresa 					CHAR(3),
	pNombre1 					CHAR(40),
	pNombre2 					CHAR(40),
	pApellPat					CHAR(40),
	pApellMat					CHAR(40),
	pFechaNac					CHAR(8),
	pFechaHoy					CHAR(10),
	pMontoPaga 					CHAR(20),
	pSucursal 					CHAR(4),
	p_moneda 					CHAR(3),
	cMontoDolares				Money(16,2),
	pNum_confirmacion			CHAR(16),
	pCodigoEstado				CHAR(3))

	RETURNING 
	CHAR(6) AS CodRet;
	
	
	 --DEFINICION DE VARIABLES--
    DEFINE sql_err      				INTEGER;
    DEFINE cCodRet      				CHAR(6);
	DEFINE vCodRet						CHAR(5);
	DEFINE cAnio						CHAR(4);
	DEFINE cDia							CHAR(2);
	DEFINE cMes             			CHAR(2);
	DEFINE cAnioFecHoy					CHAR(4);
	DEFINE dTotalMensual				DECIMAL(16,2);
	DEFINE dPri_dia_mes					DATE;	
	DEFINE cMaxDiario					DECIMAL(16,2);
	DEFINE cMaxMes						DECIMAL(16,2);
	DEFINE iMaxOperaciones				INTEGER;
	DEFINE cMaxSuc	        			MONEY(16,2); 
	DEFINE dTotalDiario					DECIMAL(8,2);
	DEFINE iCont						INTEGER;
	DEFINE iNumOperDia					INTEGER;	
	DEFINE iNumOperMes					INTEGER;
	DEFINE cImpDia						DECIMAL(16,2);
	DEFINE cImpMes						DECIMAL(16,2);
	DEFINE dMaxDiarioDolar  			DECIMAL(16,2); --222
	DEFINE dImpPagoDolar 				DECIMAL(16,2);
	DEFINE dImpPagoMesDolar 			DECIMAL(16,2);
	DEFINE dMaxMesDolar 				DECIMAL(16,2);
	DEFINE mMaxSucDolar	    			MONEY(16,2);
	DEFINE mMaxEdo						MONEY(16,2);
	DEFINE mMaxEdoDolar	    			MONEY(16,2);
	DEFINE cNumEdo						CHAR(5);
	DEFINE dImpDiaDolar 				DECIMAL(16,2);
	DEFINE mImpMesDolar 				MONEY(16,2);
	DEFINE iNumMovsNoUSDHist			INTEGER;
	DEFINE iNumMovsNoUSD				INTEGER;
	DEFINE cFechaHoy					CHAR(10);
	DEFINE dFechaHoy					DATE;
	DEFINE cRfc							CHAR(13);
	DEFINE cNombres						CHAR(85);
	DEFINE dFechaNac					DATE;
	DEFINE vimporte_pago_dia_usd    	MONEY(16,2);
	DEFINE vimporte_origen_dia_usd  	MONEY(16,2);
	DEFINE vcuenta_dia_usd				INTEGER;
	DEFINE vimporte_pago_dia_no_usd    	MONEY(16,2);
	DEFINE vimporte_origen_dia_no_usd	MONEY(16,2);
	DEFINE vcuenta_dia_no_usd			INTEGER;
	DEFINE vimporte_pago_mes_usd    	MONEY(16,2);
	DEFINE vimporte_origen_mes_usd  	MONEY(16,2);
	DEFINE vcuenta_mes_usd				INTEGER;
	DEFINE vimporte_pago_mes_no_usd    	MONEY(16,2);
	DEFINE vimporte_origen_mes_no_usd	MONEY(16,2);
	DEFINE vcuenta_mes_no_usd			INTEGER;
	DEFINE iCuentasListasNegras			INTEGER;
	DEFINE iRfc_val						INTEGER;
	DEFINE cUsr							CHAR(4);
	LET iCuentasListasNegras			= 0;
	
	--INICIALIZACION DE VARIABLES--
    LET sql_err 						= 0;
    LET cCodRet 						= '000000';
	LET cAnio							= '';
	LET cDia							= '';
	LET cMes            				= '';
	LET cAnioFecHoy						= '';
	LET dTotalMensual     				= 0.00;
	LET dPri_dia_mes					= '';	
	LET cMaxDiario						= 0.00;
	LET cMaxMes							= 0.00;
	LET iMaxOperaciones 				= 0;
	LET cMaxSuc         				= 0.00;
	LET dTotalDiario       				= 0.00;
	LET iCont							= 1;
	LET iNumOperDia						= 0;	
	LET iNumOperMes						= 0;
	LET cImpDia							= 0.00;
	LET cImpMes							= 0.00;
	LET dMaxDiarioDolar 				= 0.00;
	LET dImpPagoDolar 					= 0.00;
	LET dImpPagoMesDolar				= 0.00;
	LET dMaxMesDolar 					=0.00;
	LET mMaxSucDolar    				= 0.00;
	LET mMaxEdo							=0.00;
	LET mMaxEdoDolar					=0.00;
	LET cNumEdo 						='';
	LET dImpDiaDolar 					= 0.00;
	let mImpMesDolar 					= 0.00;
	LET iNumMovsNoUSDHist				= 0;
	LET iNumMovsNoUSD					= 0;
	LET cFechaHoy       				= '';
	LET dFechaHoy						= '';
	LET cRfc							= '';
	LET cNombres						= '';
	LET dFechaNac						= '';
	LET iRfc_val						= 0;
	LET cUsr							= '';
	
	--SET DEBUG FILE TO '/home/c90307738/sp_app_valmonto_cpl.log';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCodRet = sql_err;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Valida Parametros 
		IF NVL(pEmpresa,'') = '' OR NVL(pNombre1,'') = '' OR NVL(pApellPat,'') = '' OR NVL(pFechaNac,'') = '' OR NVL(pFechaHoy,'')='' OR NVL(pMontoPaga,'')='' THEN
			LET cCodRet =   '00170'; --Faltan parametros
			RETURN cCodRet;
		END IF;
		
	-- validar los primeros 4 caracteres correspondan al anio es decir que sea mayor al anio 1900 hasta el anio actual, aaaammdd.
		LET cAnio = SUBSTR(pFechaNac,1,4);
		LET cDia = SUBSTR(pFechaNac,7,2);
		LET cMes = SUBSTR(pFechaNac,5,2);
			
			--PRODUCTIVO
			IF YEAR(pFechaHoy)<= YEAR(CURRENT) THEN
				LET cAnioFecHoy= YEAR(pFechaHoy); --Anio actual
			END IF;
		
			
			IF cAnio BETWEEN 1900 AND cAnioFecHoy AND cMes BETWEEN 01 AND 12 AND cDia BETWEEN 01 AND 31 THEN
			LET cFechaHoy = SUBSTRING(pFechaHoy FROM 5 FOR 4)||SUBSTRING(pFechaHoy FROM 1 FOR 2)||SUBSTRING(pFechaHoy FROM 3 FOR 2);
			SELECT pri_dia_mes 
			INTO dPri_dia_mes
			FROM "informix".sac_fechas;
					
					
				LET cNombres  = TRIM(pNombre1) || " " || TRIM(pNombre2);
				LET dFechaNac = MDY(SUBSTRING(pFechaNac FROM 5 FOR 2) ,SUBSTRING(pFechaNac FROM 7 FOR 2) ,SUBSTRING(pFechaNac FROM 1 FOR 4));
				--Calculo el RFC del beneficiario
				EXECUTE PROCEDURE bdicnweb:"informix".sp_calcularrfc(pApellPat, pApellMat, cNombres, dFechaNac)
				INTO vCodRet, cRfc;
				
				SELECT COUNT(*) INTO iRfc_val FROM bdinteg:"informix".si_cliente WHERE rfc = cRfc;
				
				IF iRfc_val = 0 THEN --Separamos los limites de los clientes y de los usuarios
					--Limites por usuario
					
					SELECT PESOS,USD 
					INTO cMaxDiario,dMaxDiarioDolar
					FROM "informix".sac_limite_monto
					WHERE abreviatura = 'APP_DIA_'
					AND status = 1;
					
					SELECT PESOS,USD 
					INTO cMaxMes,dMaxMesDolar
					FROM "informix".sac_limite_monto
					WHERE abreviatura = 'APP_MES_'
					AND status = 1;
					
					SELECT operaciones 
					INTO iMaxOperaciones
					FROM "informix".sac_limite_monto
					where abreviatura = 'APP_MES_'
					and status = 1;
					
					SELECT pesos,usd 
					INTO cMaxSuc,mMaxSucDolar
					FROM "informix".sac_limite_suc_usuario 
					WHERE abreviatura = 'APP_DIA_' 
					AND sucursal = pSucursal --(buscar la suc
					AND status = 1;
					
					----limite por estado
					--SELECT estado
					--INTO cNumEdo
					--FROM bdinteg:"informix".si_sucursales
					--WHERE sucursal = pSucursal;
					
					SELECT PESOS,USD 
					INTO mMaxEdo, mMaxEdoDolar
					FROM "informix".sac_limite_edo_usuario 
					WHERE abreviatura = 'APP_DIA_'
					AND estado = pCodigoEstado
					AND status = 1;
					
					LET cUsr = '_USR';
					
				ELIF iRfc_val >= 1 THEN --EPG 25032025
					--Limites por cliente
				
					SELECT PESOS,USD 
					INTO cMaxDiario,dMaxDiarioDolar
					FROM "informix".sac_limite_monto
					WHERE abreviatura = 'APP_DIA_'
					AND status = 1;
				
					SELECT PESOS,USD 
					INTO cMaxMes,dMaxMesDolar
					FROM "informix".sac_limite_monto
					WHERE abreviatura = 'APP_MES_'
					AND status = 1;
				
					SELECT operaciones 
					INTO iMaxOperaciones
					FROM "informix".sac_limite_monto
					where abreviatura = 'APP_MES_'
					and status = 1;						
				
					SELECT pesos,usd 
					INTO cMaxSuc,mMaxSucDolar
					FROM "informix".sac_limite_suc 
					WHERE abreviatura = 'APP_DIA_' 
					AND sucursal = pSucursal --(buscar la sucursal en donde se esta realizando la remesa) 
					AND status = 1;
					
					----limite por estado
					--SELECT estado
					--INTO cNumEdo
					--FROM bdinteg:"informix".si_sucursales
					--WHERE sucursal = pSucursal;
					
					SELECT PESOS,USD 
					INTO mMaxEdo, mMaxEdoDolar
					FROM "informix".sac_limite_edo
					WHERE abreviatura = 'APP_DIA_'
					AND estado = pCodigoEstado
					AND status = 1;
					
				END IF; --Fin validacion de limites por ususario y cliente
				
				IF cMaxSuc IS NULL OR cMaxSuc = '' THEN
					LET cMaxSuc = 0;
				END IF;
				
				IF mMaxSucDolar IS NULL OR mMaxSucDolar = '' THEN
					LET mMaxSucDolar = 0;
				END IF;
				
				LET dFechaHoy = TODAY;
				
				
				--Obtengo cifras pagadas durante el mes para el beneficiario
				SELECT NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy THEN importe_pago ELSE 0 END),0) importe_pago_dia_usd,
					   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_dia_usd,
					   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy THEN 1 ELSE 0 END),0) cuenta_dia_usd,
					   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy THEN importe_pago ELSE 0 END),0) importe_pago_dia_no_usd,
					   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_dia_no_usd,
					   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy THEN 1 ELSE 0 END),0) cuenta_dia_no_usd,
					   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy THEN importe_pago ELSE 0 END),0) importe_pago_mes_usd,
					   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_mes_usd,
					   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy THEN 1 ELSE 0 END),0) cuenta_mes_usd,
					   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy THEN importe_pago ELSE 0 END),0) importe_pago_mes_no_usd,
					   NVL(SUM(CASE WHEN moneda_origen != 'USD'  AND fecha_pago != dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_mes_no_usd,
					   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy THEN 1 ELSE 0 END),0) cuenta_mes_no_usd
				INTO   vimporte_pago_dia_usd, vimporte_origen_dia_usd, vcuenta_dia_usd, vimporte_pago_dia_no_usd, vimporte_origen_dia_no_usd, vcuenta_dia_no_usd,
					   vimporte_pago_mes_usd, vimporte_origen_mes_usd, vcuenta_mes_usd, vimporte_pago_mes_no_usd, vimporte_origen_mes_no_usd, vcuenta_mes_no_usd
				FROM   sac_remesas_estadistica
				WHERE  rfc               =  cRfc
				AND    numcategoria      =  '07'
				AND    numconvenio       IN ('009')
				AND    fecha_pago       >=  dPri_dia_mes
				AND    fecha_pago       <=  dFechaHoy
				AND    status_cancelado !=  'S'
				AND    origen            in ('V','T');
				
				--Determino el numero de movimientos hechos en moneda distinta de dolares
				LET iNumMovsNoUSDHist = vcuenta_dia_no_usd + vcuenta_mes_no_usd;
				
				--Determino el numero de operaciones del mes
				LET iNumOperMes	= vcuenta_dia_usd + vcuenta_dia_no_usd + vcuenta_mes_usd + vcuenta_mes_no_usd;
				
				--Determino el numero de operaciones del dia
				LET iNumOperDia = vcuenta_dia_usd + vcuenta_dia_no_usd;
			
				--Reviso si esta en listas negras
				SELECT COUNT(*)
				INTO   iCuentasListasNegras
				FROM   bdiauditor:"informix".tbl_listainterna
				WHERE  rfc = cRfc;
				
				--222 si existe por lo menos uno distintio de USD OBTENEMOS LOS VALORES EN PESOS
				IF iNumMovsNoUSDHist > 0 OR p_moneda <> 'USD' THEN
				
					LET cImpDia	= vimporte_pago_dia_usd + vimporte_pago_dia_no_usd;
					LET cImpMes	= vimporte_pago_mes_usd + vimporte_pago_mes_no_usd;
				
					--Caso de que algun movimiento (incluyendo el de la peticion) sea diferente de dolares
					LET dTotalDiario  = cImpDia + pMontoPaga;
					LET dTotalMensual = cImpMes + dTotalDiario;
					
					--1. Limite por nÃÂ?ÃÂ?ÃÂ?ÃÂÃÂºmero de transacciones (mensual)
					IF iNumOperMes >= iMaxOperaciones THEN --valida numero de operaciones mensuales
						LET cCodRet= '000157';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperMes, cImpMes + cImpDia, 'APP_MES_OPE' || cUsr,pNum_confirmacion);
				
						--2. Limite diario por sucursal pesos
					ELIF cMaxSuc > 0 AND (dTotalDiario > cMaxSuc) THEN  --valida monto diario por sucursal
						LET cCodRet= '000158';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperDia, cImpDia, 'APP_DIA_SUC_MN' || cUsr,pNum_confirmacion);		
				
						--3. Limite por estado pesos
					ELIF mMaxEdo > 0 AND (dTotalDiario > mMaxEdo) THEN  --valida monto diario por 
						LET cCodRet= '000159';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperDia, cImpDia, 'APP_DIA_EDO_MN' || cUsr,pNum_confirmacion);		
					
						--4. Restriccion de listas negras
					ELIF iCuentasListasNegras > 0 THEN
						LET cCodRet= '000160';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperDia, cImpDia, 'APP_LISTA' || cUsr,pNum_confirmacion);			
				
						--5. Limite diario pesos
					ELIF dTotalDiario > cMaxDiario THEN  --valida monto diario					
						LET cCodRet= '000161';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperDia, cImpDia, 'APP_DIA_MN' || cUsr,pNum_confirmacion);			
				
						--6. LiÃÂ?ÃÂÃÂ­mite mensual  pesos
					ELIF dTotalMensual > cMaxMes THEN --valida acumulado mensual
						LET cCodRet= '000162';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperMes, cImpMes + cImpDia, 'APP_MES_MN' || cUsr,pNum_confirmacion);					
					END IF;				
				ELSE
					
					LET dImpDiaDolar = vimporte_origen_dia_usd + vimporte_origen_dia_no_usd;
					LET mImpMesDolar = vimporte_origen_mes_usd + vimporte_origen_mes_no_usd;
															
					LET dImpPagoDolar = dImpDiaDolar + cMontoDolares;
					LET dImpPagoMesDolar = mImpMesDolar + dImpPagoDolar;
					
					IF iNumOperMes >= iMaxOperaciones THEN --valida numero de operaciones mensuales
						LET cCodRet= '000164';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOperMes, mImpMesDolar + dImpDiaDolar, 'APP_MES_OPE' || cUsr,pNum_confirmacion);
						
						--2. LiÃÂ?ÃÂÃÂ­mite diario por sucursal dolares
					ELIF mMaxSucDolar > 0 AND (dImpPagoDolar > mMaxSucDolar) THEN  --valida monto diario por sucursal
						LET cCodRet= '000165';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, cMontoDolares, iNumOperDia, dImpDiaDolar, 'APP_DIA_SUC_USD' || cUsr,pNum_confirmacion);		
				
						--3. Limite por estado dolares
					ELIF mMaxEdoDolar > 0 AND (dImpPagoDolar > mMaxEdoDolar) THEN  --valida monto diario por sucursal
						LET cCodRet= '000166';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, cMontoDolares, iNumOperDia, dImpDiaDolar, 'APP_DIA_EDO_USD' || cUsr,pNum_confirmacion);	
					
						--4. Restriccion de listas negras
					ELIF iCuentasListasNegras > 0 THEN
						LET cCodRet= '000160';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, cMontoDolares, iNumOperDia, dImpDiaDolar, 'APP_LISTA' || cUsr,pNum_confirmacion);
										
						--5. Limite diario dolares
					ELIF dImpPagoDolar > dMaxDiarioDolar THEN  --valida monto diario					
						LET cCodRet= '000167';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, cMontoDolares, iNumOperDia, dImpDiaDolar, 'APP_DIA_USD' || cUsr,pNum_confirmacion);			
				
						--6. LiÃÂ?ÃÂÃÂ­mite mensual dolares
					ELIF dImpPagoMesDolar > dMaxMesDolar THEN --valida acumulado mensual
						LET cCodRet= '000168';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, cMontoDolares, iNumOperMes,mImpMesDolar + dImpDiaDolar, 'APP_MES_USD' || cUsr,pNum_confirmacion);
						
					End if;
				
				END if;
				----7. LiÃÂ?ÃÂÃÂ­mite acumulado en todas las remesas
				IF cCodRet = '000000' THEN						
					EXECUTE PROCEDURE bdisac:"informix".sp_validamontos(pEmpresa,pNombre1,pNombre2,pApellPat,pApellMat,pFechaNac,cFechaHoy,pMontoPaga,pSucursal,p_moneda,cMontoDolares,'APP' || cUsr,pNum_confirmacion,cRfc,dPri_dia_mes)
					INTO cCodRet;
					
					IF cCodRet = '00001' THEN  --Se excedio en dolares
						LET cCodRet = '000169';
					END IF;
					
					IF cCodRet = '00002' THEN  --Se excedio en pesos
						LET cCodRet = '000163';
					END IF;
				END IF;	
						
			ELSE 
				LET cCodRet= '000170';
			END IF;
		RETURN cCodRet;
		
	END 
END PROCEDURE
DOCUMENT
'Obtiene el monto diario y mensual para cobros Appriza',
'AUTOR : Pedro G Jimenez Guzman',
'FECHA : 13-abril-2016',
'BD    : BDISAC',
'Se agrega nueva validacion de dolares y agregan nuevas a pesos',
'AUTOR : Viridiana Paredes Romero',
'FECHA : 29-05-2017',
'BD    : BDISAC',
'Se agrega nueva validacion para los RFC duplicados',
'AUTOR : Eduardo Pineda Guzman',
'FECHA : 25-03-2025',
'BD    : BDISAC';

CREATE PROCEDURE "informix".sp_sac_valida_ctesremesas_ob(pNumCte CHAR(20), pTipoCliente CHAR(1), pRfc CHAR(13))
RETURNING  
            CHAR(5) AS cCodRet,
            CHAR(20) AS cNumcte,
            CHAR(1) AS iTipoCliente,
            CHAR(5) AS cValIne,
            CHAR(5) AS cListaNegra,
            CHAR(5) AS cSespecial,
            INTEGER AS iExistBitaPrincipal;

            DEFINE cCodRet CHAR(5);
            DEFINE cNumcte CHAR(20);
            DEFINE iTipoCliente CHAR(1);
            DEFINE cValIne CHAR(5);
            DEFINE cResultINE CHAR(50);
            DEFINE cListaNegra CHAR(5);
            DEFINE cSespecial CHAR(5);
            DEFINE cStatuscte CHAR(1);
            DEFINE cCodRetRfc CHAR(5);

            DEFINE iSqlErr INTEGER;
            DEFINE iIsamErr INTEGER;
            DEFINE cInfoErr CHAR(10);

            DEFINE icontEsp INTEGER;
            DEFINE iContList INTEGER;

            DEFINE cSituacion CHAR(5);
            DEFINE cCausa CHAR(5);
            DEFINE iContListRfc INTEGER;

            DEFINE iExistBitaPrincipal INTEGER;

            DEFINE iUno INTEGER;

            LET cCodRet = "00000";
            LET cNumcte = "";
            LET iTipoCliente = "";
            LET cValIne = "";
            LET cResultINE = NULL;
            LET cListaNegra = "False";
            LET cSespecial = "";
            LET cStatuscte = "";

            LET icontEsp = 0;
            LET iContList = 0;

            LET cSituacion = '';
            LET cCausa = '';
            LET iContListRfc = 0;

            LET iExistBitaPrincipal = 0;

            
            LET iUno = 1;

          --SET DEBUG FILE TO '/informix/ENP/spHuellas/out/sp_sac_valida_ctesremesas_ob.out';
          --TRACE ON;

BEGIN 
    ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr::CHAR(5);
            RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,iExistBitaPrincipal;
        END IF;
    END EXCEPTION;	

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    LET iTipoCliente = pTipoCliente;
    LET cNumcte = pNumCte;
    ----------------------------------Validacion LISTA NEGRA  -----------------------------------
    IF pRfc <> "" THEN
        SELECT COUNT(*) INTO iContListRfc
        FROM bdiauditor:"informix".tbl_listainterna
        WHERE rfc = pRfc;

        IF pTipoCliente = "3" AND iContListRfc > 0 THEN
            LET iTipoCliente = "2";
            LET cNumcte = "000000001";
        END IF;
    END IF;

    IF pTipoCliente = "1" OR pTipoCliente = "2" THEN
        SELECT COUNT(*) INTO iContList
        FROM bdiauditor:"informix".tbl_listainterna
        WHERE numcte = cNumCte;
    END IF;

    LET iContList = iContList + iContListRfc;
    
    IF iContList > 0 THEN 
        LET cListaNegra = "True";
    END IF;
    -----------------------------------Validacion de INE -----------------------------------
    FOREACH
        SELECT resultado, 1 
        INTO cResultINE, iExistBitaPrincipal
        FROM bdinteg:"informix".si_bitacora_ife
        WHERE numcte = cNumcte
        ORDER BY fecha DESC
        EXIT FOREACH;
    END FOREACH;

    IF iExistBitaPrincipal = 0 THEN
        FOREACH
            SELECT resultado INTO cResultINE
            FROM bdinteg:"informix".si_bitacora_ife_hist3
            WHERE numcte = cNumcte
            ORDER BY fecha DESC
            EXIT FOREACH;
        END FOREACH;
    END IF;
    
    IF ((TRIM(NVL(cResultINE, "")) = "") AND (pTipoCliente = 1 OR pTipoCliente = 2))
        OR (UPPER(TRIM(cResultINE)) = "VERDADERO") OR (UPPER(TRIM(cResultINE)) = "TRUE") THEN 
        LET cValIne = "True";
    ELIF (TRIM(NVL(cResultINE, "")) = "") AND pTipoCliente = 3 THEN 
        LET cValIne = "";
    ELIF (UPPER(TRIM(cResultINE)) = "FALSO") OR (UPPER(TRIM(cResultINE)) = "FALSE") THEN 
        LET cValIne = "False";
    END IF;
    -----------------------------------Validacion SITUACION ESPECIAL -----------------------------------
    SELECT COUNT(*) INTO icontEsp
    FROM bdisitesp:"informix".se_ctessitespcte
    where numcte = cNumCte;

    IF icontEsp > 0 THEN
        SELECT situacion,causa INTO cSituacion,cCausa
        FROM bdisitesp :"informix".se_ctessitespcte
        where numcte = cNumCte;
        LET cSituacion = TRIM(cSituacion) || TRIM(cCausa);

        IF cSituacion IN ('F42', 'P72', 'P108', 'U60') THEN 
            LET cSespecial = "True";
        ELSE 
            LET cSespecial = "False";
        END IF;
    ELSE 
        LET cSespecial = "False";
    END IF;
    RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,iExistBitaPrincipal;
END;
END PROCEDURE

DOCUMENT
'DESCRIPCION: Identifica el tipo de cliente y Valida datos cliente(INE, Lista negra y Situacion especial) por numero de cliente y/o identificacion',
'AUTOR: Aaron QuiÃ±onez',
'SUSTENTO: RQM 10 1534 Envio de remesas outbound',
'FECHA DE CREACION: 12/01/2024',
'SOLICITA: LEONARDO HERNANDEZ',
'----------------------------',
'ACTUALIZACION: Se agrega la consulta a bitacora ine historico y se retorna variable para identificar si existe valor en la bitacora principal',
'AUTOR: Aaron QuiÃ±onez',
'FECHA: 16/04/2026',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_sac_consulta_ctesremesas(
							pIdCanal			CHAR(3),
							pempresa            CHAR(3),
							psucursal           CHAR(4),
							pejecutivo          CHAR(8),
							pNumCte 			CHAR(20),
							pNombre1 			CHAR(26), 
							pNombre2 			CHAR(26), 
							pApell_paterno 		CHAR(26), 
							pApell_materno 		CHAR(26), 
							pFecha_nac 			CHAR(20), 
							pNumIdentificacion 	CHAR(30), 
							pOp1 				CHAR(100),
							pOp2 				CHAR(200),
							pOp3 				CHAR(300))
							
RETURNING  
		CHAR(5)    AS cCodRet,
		CHAR(30)   AS cDescCod,
		CHAR(30)   AS cCodRetSec,       
		CHAR(30)   AS cDescCodSec , 
		CHAR(20)   AS cNumcte,
		CHAR(1)    AS iTipoCliente,
		CHAR(5)    AS cValIne,
		CHAR(5)    AS cListaNegra,
		CHAR(5)    AS cSespecial,
		CHAR(13)   AS cRfc,
		CHAR(200)  AS cCiudadNac,
		CHAR(40)   AS cNombre1,
		CHAR(40)   AS cNombre2,
		CHAR(40)   AS cApellPat,
		CHAR(40)   AS cApellMat,
		CHAR(2)    AS cSexo,
		CHAR(2)    AS cTipoCte,
		CHAR(3)    AS cCodOcupacion,
		CHAR(30)   AS cOcupacion,	
		CHAR(30)   AS cCodIdentificacion,
		CHAR(30)   AS cTipoIdentificacion,
		CHAR(30)   AS cNumIdentificacion,
		CHAR(20)   AS cClaveElector,				
		CHAR(3)    AS cNumEmision,					
		CHAR(3)    AS cIdPaisEmision,
		CHAR(80)   AS cpais_emision,
		CHAR(3)    AS cIdNacionalidad,
		CHAR(80)   AS cNacionalidad,
		CHAR(3)    AS cIdPaisNacimiento,
		CHAR(80)   AS cPaisNac,
		CHAR(3)    AS cIdEstadoNacimiento,
		CHAR(30)   AS cEdoNac,
		CHAR(80)   AS cIdCiudadNac,
		CHAR(3)    AS cIdEstado,
		CHAR(80)   AS cEdo,
		CHAR(3)    AS cIdCiudad,
		CHAR(80)   AS cCiudad,
		CHAR(3)    AS cIdMunicipio,
		CHAR(80)   AS cMunicipio,
		CHAR(80)   AS cColonia,
		CHAR(80)   AS cCalle,
		CHAR(10)   AS cDepartamento,
		CHAR(10)   AS cNroExt,
		CHAR(10)   AS cNroInt,
		CHAR(30)   AS cCodPostal,
		CHAR(30)   AS cTelCasa,
		CHAR(30)   AS cTelCelular,
		CHAR(30)   AS cCorreoElectronico,
		CHAR(3)    AS cIdPaisDomExt,
		CHAR(30)   AS dFechaNac,
		CHAR(30)   AS dFecha_vencimiento,
		INTEGER    AS iNumColonia,
		INTEGER    AS iClavePuesto,
		INTEGER    AS iClaveSubPuesto,
		INTEGER    AS iNumCalle,
		INTEGER    AS iNumCiudad,  
		CHAR(2048)  AS cCadAnverso,    
		CHAR(2048)  AS cCadReverso,    
		CHAR (100) AS cOp1,
		CHAR (200) AS cOp2,
		CHAR (300) AS cOp3;	

        --DECLARACION DE VARIABLES
	DEFINE cCodRet        		CHAR(5);
	DEFINE cDescCod        		CHAR(30);
	DEFINE cCodRetSec			CHAR(5);
	DEFINE cDescCodSec       	CHAR(30);
	DEFINE iSqlErr        		INTEGER;
	DEFINE iIsamErr         	INTEGER;

	DEFINE cCiudadNac		    CHAR(200);
	DEFINE cNombre1				CHAR(40);
	DEFINE cNombre2				CHAR(40);
	DEFINE pNombre3 			CHAR(40);
	DEFINE cApellPat			CHAR(40);
	DEFINE cApellMat			CHAR(40);
	DEFINE dFechaNac			CHAR(40);
	DEFINE cIdNacionalidad      CHAR(3);
	DEFINE cTipoIdentificacion  CHAR(2);
	DEFINE cNumIdentificacion	CHAR(30);
	DEFINE cClaveElector		CHAR(20);
	DEFINE cNumEmision			CHAR(3);
	DEFINE cIdPaisEmision		CHAR(3);
	DEFINE cDepartamento		CHAR(10);
	DEFINE cIdPaisDomExt		CHAR(3);
		
	DEFINE cCodOcupacion        CHAR(3);
	DEFINE cOcupacion			CHAR(30);
	DEFINE cTipoCte				CHAR(2);
	DEFINE cIdEstado			CHAR(2);
	DEFINE cIdCiudad			CHAR(3);
	DEFINE cIdMunicipio			CHAR(5);
		
	DEFINE cIdEstadoNacimiento  CHAR(2);
	DEFINE cIdPaisNacimiento	CHAR(3); 
	
	DEFINE cPais_emision    	CHAR(45);
	DEFINE cNacionalidad		CHAR(50);
	DEFINE cPaisNac				CHAR(30);
	DEFINE cEdoNac				CHAR(30);
	DEFINE cIdCiudadNac			CHAR(30);
	DEFINE cSexo				CHAR(5);
	DEFINE cEdo					CHAR(50);
	DEFINE cCiudad				CHAR(50);
	DEFINE cColonia 			CHAR(80);
	DEFINE cCalle    			CHAR(80);
	DEFINE cNroExt				CHAR(10);
	DEFINE cNroInt				CHAR(10);
	DEFINE cCodPostal			CHAR(5);
	DEFINE cTelCasa				CHAR(15);
	DEFINE cTelCelular			CHAR(15);
	DEFINE cNumCte				CHAR(20);
	DEFINE cCorreoElectronico   CHAR(100);
	
	DEFINE iContAPP	         	INTEGER;	
	DEFINE iContBTS	         	INTEGER;	
	DEFINE iContWU	         	INTEGER;	
    DEFINE iTipoDir				INTEGER;

	DEFINE vexiste				CHAR(2);
	DEFINE dFecha_vencimiento	CHAR(40);

	DEFINE cValIne				CHAR(5);
	DEFINE cListaNegra			CHAR(5);
	DEFINE cSespecial 			CHAR(5);
	DEFINE cCodRetRfc			CHAR(6);
	DEFINE cNumcteRfc			CHAR(10);
	DEFINE iTipoCliente			CHAR(10);
	DEFINE cRfc					CHAR(13);

	DEFINE iNumColonia			INTEGER;
	DEFINE iNumCalle			INTEGER;
	DEFINE iNumCiudad			INTEGER;
	DEFINE iClaveSubPuesto      INTEGER;
	DEFINE iClavePuesto         INTEGER;
    DEFINE cSec_ingreso         CHAR(5);

	DEFINE vcodret 				CHAR(5);	
	DEFINE cCadAnverso  		CHAR(2048);
    DEFINE cCadReverso  		CHAR(2048);
	DEFINE vmapadloc			CHAR(942);
	DEFINE vmapailoc			CHAR(942);

	DEFINE iExistBitaPrincipal  INTEGER;

	DEFINE	cOp1				CHAR (100);
	DEFINE	cOp2				CHAR (200);
	DEFINE	cOp3 				CHAR (300);

	--SET DEBUG FILE TO '/informix/ENP/spHuellas/out/sp_sac_consulta_ctesremesas.out';
	--TRACE ON;
	
	--INICIALIZACION DE VARIABLES
	LET cCodRet	            = "00000";
	LET cDescCod			= "";
	LET cCodRetSec          = "00000";
	LET cDescCodSec 		= "";
	LET iSqlErr       	    = 0;
	LET iIsamErr            = 0;

	LET cCiudadNac	    	= "";
	LET cNombre1		    = "";
	LET cNombre2		    = "";
	LET pNombre3 			= "";
	LET cApellPat		    = "";
	LET cApellMat		    = "";
	LET dFechaNac		    = "";
	LET cIdNacionalidad		= '';
	LET cSexo				= '';
	LET cRfc		       	= '';
	LET cTipoIdentificacion = '';

	LET cDepartamento		= '';
	LET cIdPaisDomExt		= '';
	LET cIdPaisEmision		= '';
	LET cIdPaisNacimiento	= '';
	LET dFecha_vencimiento	= '';
	LET cCodOcupacion		= '';
	LET cOcupacion			= '';
	LET cTipoCte			= '';
	LET cIdEstado			= '';
	LET cIdCiudad			= '';
	LET cIdMunicipio		= '';
	LET iNumColonia			= '';
	LET iNumCalle			= '';
	LET iNumCiudad			= '';
	LET iClavePuesto	    = '';
	LET iClaveSubPuesto	    = '';

	LET vexiste				='';
	LET cNumIdentificacion = "";
	LET cClaveElector	   = "";	
	LET cNumEmision		   = "";
	LET cPais_emision      = "";
	LET cNacionalidad	   = "";
	LET cPaisNac		   = "";
	LET cEdoNac			   = "";
	LET cIdCiudadNac       = "";
	LET cEdo			   = "";
	LET cCiudad			   = "";
	LET cColonia		   = "";
	LET cCalle   		   = "";
	LET cNroExt			   = "";
	LET cNroInt			   = "";
	LET cCodPostal		   = "";
	LET cTelCasa		   = "";
	LET cTelCelular		   = "";
	LET cNumCte			   = "";
	LET cCorreoElectronico		= '';
	LET cIdEstadoNacimiento 	= '';
	LET iContAPP           = "";
	LET iContBTS           = "";
	LET iContWU            = "";
    LET iTipoDir		   = "";
    LET cSec_ingreso       = "";
	
	LET cValIne				= '';
	LET cListaNegra			= '';
	LET cSespecial 			= '';
	LET cCodRetRfc			= '';
	LET cNumcteRfc			= '';
	LET iTipoCliente		= '';

	LET cCadAnverso = "";
    LET cCadReverso = "";

	LET iExistBitaPrincipal = 0;
	
	LET	cOp1				= '';
	LET	cOp2				= '';
	LET	cOp3				= '';

	-- LIMPIA PARAMETRO DE ENTRADA
	LET pNumCte 			= NVL(pNumCte, "");
	LET pNombre1 			= NVL(pNombre1, "");
	LET pNombre2 			= NVL(pNombre2, "");
	LET pApell_paterno 		= NVL(pApell_paterno, "");
	LET pApell_materno 		= NVL(pApell_materno, "");
	LET pFecha_nac 			= NVL(pFecha_nac, "");
	LET pNumIdentificacion	= NVL(pNumIdentificacion, "");

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN
			cCodRet,cDescCod,cCodRetSec,cDescCodSec,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc,cCiudadNac,cNombre1,cNombre2,cApellPat,cApellMat,
			cSexo,cTipoCte,cCodOcupacion,cOcupacion,cTipoIdentificacion,cTipoIdentificacion,cNumIdentificacion,cClaveElector,cNumEmision,cIdPaisEmision,
			cIdPaisEmision,cIdNacionalidad,cNacionalidad,cIdPaisNacimiento,cPaisNac,cIdEstadoNacimiento,cEdoNac,cIdCiudadNac,cIdEstado,cEdo,cIdCiudad,cCiudad,
			cIdMunicipio,cIdMunicipio,cColonia,cCalle,cDepartamento,cNroExt,cNroInt,cCodPostal,cTelCasa,cTelCelular,cCorreoElectronico,cIdPaisDomExt,dFechaNac,
			dFecha_vencimiento,iNumColonia,iClavePuesto,iClaveSubPuesto,iNumCalle,cIdCiudad,cCadAnverso,cCadReverso,cOp1,cOp2,cOp3;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--VALIDACION DEL PARAMETRO DE ENTRADA.
	IF NVL(pNumCte, '') = '' AND NVL(pNumIdentificacion, '') = '' AND  NVL(pNombre1, '') = '' AND NVL(pApell_paterno, '') = '' AND NVL(pFecha_nac::DATE, '') = '' THEN
		LET cCodRet = "00050";
		LET cDescCod ='PARAMETROS VACIOS/INCOMPLETOS ';
		LET cDescCodSec = 'FILTROS: NUMCTE/IDENTIFI/NOMB1,APEPAT,FECNAC';
		RETURN
		cCodRet,cDescCod,cCodRetSec,cDescCodSec,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc,cCiudadNac,cNombre1,cNombre2,cApellPat,cApellMat,
		cSexo,cTipoCte,cCodOcupacion,cOcupacion,cTipoIdentificacion,cTipoIdentificacion,cNumIdentificacion,cClaveElector,cNumEmision,cIdPaisEmision,
		cIdPaisEmision,cIdNacionalidad,cNacionalidad,cIdPaisNacimiento,cPaisNac,cIdEstadoNacimiento,cEdoNac,cIdCiudadNac,cIdEstado,cEdo,cIdCiudad,cCiudad,
		cIdMunicipio,cIdMunicipio,cColonia,cCalle,cDepartamento,cNroExt,cNroInt,cCodPostal,cTelCasa,cTelCelular,cCorreoElectronico,cIdPaisDomExt,dFechaNac,
		dFecha_vencimiento,iNumColonia,iClavePuesto,iClaveSubPuesto,iNumCalle,cIdCiudad,cCadAnverso,cCadReverso,cOp1,cOp2,cOp3;
	END IF;	
			
	SELECT 1 INTO vexiste
	FROM bdinteg:"informix".si_ejecut
	WHERE ejecutivo=pejecutivo;

	IF vexiste IS NULL THEN
		LET cCodRet = '10001';
		LET cDescCod = 'No existe Ejecutivo';
		LET cCodRetSec = '00000';
		let cDescCodSec  ='';
		RETURN
		cCodRet,cDescCod,cCodRetSec,cDescCodSec,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc,cCiudadNac,cNombre1,cNombre2,cApellPat,cApellMat,
		cSexo,cTipoCte,cCodOcupacion,cOcupacion,cTipoIdentificacion,cTipoIdentificacion,cNumIdentificacion,cClaveElector,cNumEmision,cIdPaisEmision,
		cIdPaisEmision,cIdNacionalidad,cNacionalidad,cIdPaisNacimiento,cPaisNac,cIdEstadoNacimiento,cEdoNac,cIdCiudadNac,cIdEstado,cEdo,cIdCiudad,cCiudad,
		cIdMunicipio,cIdMunicipio,cColonia,cCalle,cDepartamento,cNroExt,cNroInt,cCodPostal,cTelCasa,cTelCelular,cCorreoElectronico,cIdPaisDomExt,dFechaNac,
		dFecha_vencimiento,iNumColonia,iClavePuesto,iClaveSubPuesto,iNumCalle,cIdCiudad,cCadAnverso,cCadReverso,cOp1,cOp2,cOp3;	
	END IF;	

	SELECT 1 INTO vexiste
	FROM bdinteg:"informix".si_sucursales
	WHERE sucursal=psucursal;

	IF vexiste IS NULL THEN
		LET cCodRet = '10002';
		LET cDescCod = 'No existe sucursal';
		LET cCodRetSec = '00000';
		let cDescCodSec  ='';
		RETURN
		cCodRet,cDescCod,cCodRetSec,cDescCodSec,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc,cCiudadNac,cNombre1,cNombre2,cApellPat,cApellMat,
		cSexo,cTipoCte,cCodOcupacion,cOcupacion,cTipoIdentificacion,cTipoIdentificacion,cNumIdentificacion,cClaveElector,cNumEmision,cIdPaisEmision,
		cIdPaisEmision,cIdNacionalidad,cNacionalidad,cIdPaisNacimiento,cPaisNac,cIdEstadoNacimiento,cEdoNac,cIdCiudadNac,cIdEstado,cEdo,cIdCiudad,cCiudad,
		cIdMunicipio,cIdMunicipio,cColonia,cCalle,cDepartamento,cNroExt,cNroInt,cCodPostal,cTelCasa,cTelCelular,cCorreoElectronico,cIdPaisDomExt,dFechaNac,
		dFecha_vencimiento,iNumColonia,iClavePuesto,iClaveSubPuesto,iNumCalle,cIdCiudad,cCadAnverso,cCadReverso,cOp1,cOp2,cOp3;
	END IF;

	 -- Busca numero de cliente y RFC por nombres y apellidos. 
    IF pNombre1 <> "" AND pApell_paterno <> "" AND pFecha_nac <> "" THEN
        LET pNombre3 = TRIM(pNombre1)||' '||TRIM(pNombre2);
		
        EXECUTE PROCEDURE bdinteg:sp_calcularrfc(pApell_paterno, pApell_materno, pNombre3, pFecha_nac::DATE) 
		INTO cCodRetRfc, cRfc;

        IF NVL(cCodRetRfc,'') <> '00000' THEN
            LET cCodRet = '00220';
			LET cDescCod = 'No se pudo generar el RFC';
			LET cCodRetSec = "00000";
			LET cDescCodSec  = "";

			RETURN
			cCodRet,cDescCod,cCodRetSec,cDescCodSec,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc,cCiudadNac,cNombre1,cNombre2,cApellPat,cApellMat,
			cSexo,cTipoCte,cCodOcupacion,cOcupacion,cTipoIdentificacion,cTipoIdentificacion,cNumIdentificacion,cClaveElector,cNumEmision,cIdPaisEmision,
			cIdPaisEmision,cIdNacionalidad,cNacionalidad,cIdPaisNacimiento,cPaisNac,cIdEstadoNacimiento,cEdoNac,cIdCiudadNac,cIdEstado,cEdo,cIdCiudad,cCiudad,
			cIdMunicipio,cIdMunicipio,cColonia,cCalle,cDepartamento,cNroExt,cNroInt,cCodPostal,cTelCasa,cTelCelular,cCorreoElectronico,cIdPaisDomExt,dFechaNac,
			dFecha_vencimiento,iNumColonia,iClavePuesto,iClaveSubPuesto,iNumCalle,cIdCiudad,cCadAnverso,cCadReverso,cOp1,cOp2,cOp3;	
        END IF;
                                        
        SELECT ctepf.numcte INTO cNumcte
        FROM bdinteg:"informix".si_cliente cte 
        INNER JOIN bdinteg:"informix".si_ctepf ctepf ON cte.numcte = ctepf.numcte
        AND cte.rfc = cRfc AND cte.tipo_cliente in("1", "2");
	-- Busca numero de cliente por Numero de identificacion.
    ELIF pNumIdentificacion <> "" AND pNumCte = "" THEN
        SELECT ctepf.numcte, cte.rfc INTO cNumcte, cRfc
        FROM bdinteg:"informix".si_cliente cte 
        INNER JOIN bdinteg:"informix".si_ctepf ctepf ON cte.numcte = ctepf.numcte
        WHERE ctepf.numidentifi = pNumIdentificacion AND cte.tipo_cliente in("1", "2");
	-- Busca cliente por Numero de cliente.
	ELSE
		SELECT ctepf.numcte, cte.rfc INTO cNumcte, cRfc
        FROM bdinteg:"informix".si_cliente cte 
        INNER JOIN bdinteg:"informix".si_ctepf ctepf ON cte.numcte = ctepf.numcte
        WHERE ctepf.numcte = pNumCte AND cte.tipo_cliente in("1", "2");
    END IF;

	-- Se Se verifica si el cliente se encuentra enrolado
	IF NVL(cNumcte, "") <> "" THEN
		SELECT "1"
    	INTO iTipoCliente
    	FROM bdisac:"informix".sac_cte_remesas cterem
    	WHERE cterem.numcte = cNumcte;

		IF NVL(iTipoCliente, "") = "" THEN
			LET iTipoCliente = "2";
		END IF;
	ELSE 
		LET iTipoCliente = "3";
		LET cNumcte = "000000000";
	END IF;

	-- Valida si cuenta con Situaciones Espciales o se encuentra en lista negra
	EXECUTE PROCEDURE "informix".sp_sac_valida_ctesremesas_ob(NVL(cNumcte, ""), iTipoCliente, cRfc)
	INTO cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,iExistBitaPrincipal;

	-- CONTROL DE ERRORES sp_sac_valida_ctesremesas
	IF iTipoCliente = 3 THEN
		LET cDescCod ='CTE NO EXISTE';
		LET cCodRet = '00000';
		LET cRfc = '';
	ELIF cListaNegra = '' THEN
		LET cListaNegra = "False";
	ELIF cListaNegra = 'True' THEN
		LET cDescCod ='CTE EN LISTA NEGRA';
		LET cCodRet = '00030';
	ELIF cSespecial = '' THEN
		LET cSespecial = "False";
	ELIF cSespecial = 'True' THEN
		LET cDescCod ='CTE EN S EPECIAL';
		LET cCodRet = '00040';
	END IF;

	IF cListaNegra ='True' OR cSespecial ='True' OR iTipoCliente = 3 THEN
		RETURN cCodRet,cDescCod,cCodRetSec,cDescCodSec,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,'','','','','','','','','','',
				'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',0,0,0,0,'','','','','','';
	END IF;
	
	--- Busqueda de datos ---
	SELECT correo_elec INTO cCorreoElectronico
	FROM bdinteg:"informix".si_correos 
	WHERE numcte = cNumCte and status_correo = 'A' 
	AND secuencia = (SELECT max(secuencia) FROM bdinteg:"informix".si_correos WHERE numcte = cNumCte and status_correo = 'A');

	SELECT claveopcionpuesto, clavesubopcionpuesto, claveopcionpuesto
	INTO iClavePuesto, iClaveSubPuesto, cCodOcupacion
	FROM bdinteg: "informix".si_ingresos 
	WHERE numcte = cNumCte  
	AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = cNumCte);											

	--Se verifica si el cliente tiene tipo de direcion 1, si no busca el tipo 2.
	SELECT  tipo_dir INTO iTipoDir 
	FROM bdinteg:"informix".si_direcciones_actual 
	WHERE numcte = cNumCte AND tipo_dir = 1;
		
	IF NVL(iTipoDir,0) = 0 THEN
		LET iTipoDir = 0;
		SELECT cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, ctepf.fecha_nac, cte.rfc,
			CASE WHEN (ctepf.codidentifi IN("B","A")) THEN ctepf.codidentifi ELSE "" END AS codidentifi, 
			ctepf.numidentifi, cterem.tipo_cte, cterem.claveelector, cterem.pnumemision,
			NVL(cterem.pais_emision,"") AS pais_emision, NVL(cterem.fecha_vencimiento,"") AS fecha_vencimiento,
			ctepf.nacionalidad, NVL(ctepf.id_pais,"") AS PaisNac, ctepf.lugar_nac AS EdoNac, 
			CASE WHEN cterem.ciudadnacimiento IS NOT NULL THEN cterem.ciudadnacimiento ELSE "" END AS LugarNac,
			ctepf.Sexo, NVL(tel1.telefono,"") AS cTelCasa, NVL(tel2.telefono,"") AS Celular, cterem.ocupacion as Ocupacion
		INTO cNombre1, cNombre2, cApellPat, cApellMat, dFechaNac, cRfc, cTipoIdentificacion,
			cNumIdentificacion, cTipoCte, cClaveElector, cNumEmision, cIdPaisEmision,
			dFecha_vencimiento, cIdNacionalidad, cIdPaisNacimiento, cIdEstadoNacimiento,
			cIdCiudadNac, cSexo, cTelCasa, cTelCelular, cOcupacion
		FROM bdinteg:"informix".si_cliente cte 
		INNER JOIN bdinteg:"informix".si_ctepf ctepf ON cte.numcte = ctepf.numcte 
		LEFT JOIN bdisac:"informix".sac_cte_remesas cterem ON cterem.numcte = cte.numcte 
		LEFT JOIN bdinteg:"informix".si_telefonos_actual tel1 ON cte.numcte = tel1.numcte AND tel1.tipo_tel = 1 AND tel1.status_tel = "A" 
		LEFT JOIN bdinteg:"informix".si_telefonos_actual tel2 ON cte.numcte = tel2.numcte AND tel2.tipo_tel = 2 AND tel2.status_tel = "A"
		WHERE cte.numcte = cNumCte;
	END IF;
			
	IF NVL(iTipoDir,0) = 1 THEN
		SELECT cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, ctepf.fecha_nac, cte.rfc,
			CASE WHEN (ctepf.codidentifi IN("B","A")) THEN ctepf.codidentifi ELSE "" END AS codidentifi,
			ctepf.numidentifi, cterem.tipo_cte, cterem.claveelector, cterem.pnumemision,
			NVL(cterem.pais_emision,"") AS pais_emision, NVL(cterem.fecha_vencimiento,"") AS fecha_vencimiento,
			ctepf.nacionalidad, NVL(ctepf.id_pais,"") AS PaisNac, ctepf.lugar_nac AS EdoNac, 
			CASE WHEN cterem.ciudadnacimiento IS NOT NULL THEN cterem.ciudadnacimiento ELSE "" END AS LugarNac,
			dir.municipio, dir.numerocolonia, dir.numerocalle, dir.departamento, dir.pais,
			ctepf.Sexo, dir.estado, dir.ciudad, dir.colonia, dir.calle, dir.numeroextcalle, dir.numerointcalle,
			dir.cod_postal, NVL(tel1.telefono,"") AS cTelCasa, NVL(tel2.telefono,"") AS Celular, cterem.ocupacion as Ocupacion
		INTO cNombre1, cNombre2, cApellPat, cApellMat, dFechaNac, cRfc, cTipoIdentificacion,
			cNumIdentificacion, cTipoCte, cClaveElector, cNumEmision, cIdPaisEmision,
			dFecha_vencimiento, cIdNacionalidad, cIdPaisNacimiento, cIdEstadoNacimiento, cIdCiudadNac,
			cIdMunicipio, iNumColonia, iNumCalle, cDepartamento, cIdPaisDomExt, cSexo, cIdEstado,
			cIdCiudad, cColonia, cCalle, cNroExt, cNroInt, cCodPostal, cTelCasa, cTelCelular, cOcupacion
		FROM bdinteg:"informix".si_cliente cte 
		INNER JOIN bdinteg:"informix".si_ctepf ctepf ON cte.numcte = ctepf.numcte 
		LEFT JOIN bdisac:"informix".sac_cte_remesas cterem ON cterem.numcte = cte.numcte 
		INNER JOIN bdinteg:"informix".si_direcciones_actual dir ON cte.numcte = dir.numcte and dir.fecha_insert = (SELECT MAX(fecha_insert) FROM bdinteg:"informix".si_direcciones_actual dir WHERE numcte = cte.numcte AND tipo_dir = iTipoDir) AND dir.tipo_dir = iTipoDir 
		LEFT JOIN bdinteg:"informix".si_telefonos_actual tel1 ON cte.numcte = tel1.numcte AND tel1.tipo_tel = 1 AND tel1.status_tel = "A" 
		LEFT JOIN bdinteg:"informix".si_telefonos_actual tel2 ON cte.numcte = tel2.numcte AND tel2.tipo_tel = 2 AND tel2.status_tel = "A"
		WHERE cte.numcte = cNumCte;
	END IF;	

	--Busca cadena anverso y reverso
	IF iExistBitaPrincipal = 1 THEN
		FOREACH
			SELECT cadena_anverso, cadena_reverso 
			INTO cCadAnverso, cCadReverso
			FROM bdinteg:"informix".si_bitacora_ife
			WHERE numcte = cNumcte
			ORDER BY fecha DESC
			EXIT FOREACH;
		END FOREACH;
	ELSE
		FOREACH
			SELECT cadena_anverso, cadena_reverso 
			INTO cCadAnverso, cCadReverso
			FROM bdinteg:"informix".si_bitacora_ife_hist3
			WHERE numcte = cNumcte
			ORDER BY fecha DESC
			EXIT FOREACH;
		END FOREACH;
	END IF

	IF (cIdEstado = '9' OR cIdEstado = '09') AND cIdMunicipio = '' THEN
		LET cIdMunicipio = cIdCiudad;
	END IF;

	-- Obtiene descripcion nacionalidad
	SELECT descripcion INTO cNacionalidad FROM bdinteg:"informix".si_nacion WHERE nacion = cIdNacionalidad;
	-- Obtiene descripcion pais
	SELECT nombre INTO cPaisNac FROM  bdinteg:"informix".si_paisnacion	WHERE id_pais = cIdPaisNacimiento;
	-- Obtiene descripcion estado nacimiento
	SELECT nombre INTO cEdoNac FROM bdinteg:"informix".si_estados WHERE pais = cIdNacionalidad AND estado = cIdEstadoNacimiento ;
	-- Obtiene descripcion estado domicilio
	SELECT nombre INTO cEdo FROM bdinteg:"informix".si_estados WHERE pais = cIdNacionalidad AND estado = cIdEstado ;
	-- Obtiene descripcion ciudad domicilio
	SELECT nombre INTO cCiudad FROM bdinteg:"informix".si_ciudades WHERE estado = cIdEstado AND ciudad = cIdCiudad;
	-- Obtiene descripcion ciudad nacimiento
	SELECT nombre INTO cCiudadNac FROM bdinteg:"informix".si_ciudades WHERE estado = cIdEstadoNacimiento AND ciudad = cIdCiudadNac;

	IF cValIne ='False' THEN
		LET cCodRet = '00020';
		let cDescCod ='INE INVALIDA';
		LET cnumidentificacion ='';
		LET dfecha_vencimiento ='';
		LET cclaveelector ='';
		LET cnumemision ='';
		RETURN
		cCodRet,cDescCod,cCodRetSec,cDescCodSec,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc,cCiudadNac,cNombre1,cNombre2,cApellPat,cApellMat,
		cSexo,cTipoCte,cCodOcupacion,cOcupacion,cTipoIdentificacion,cTipoIdentificacion,cNumIdentificacion,cClaveElector,cNumEmision,cIdPaisEmision,
		cIdPaisEmision,cIdNacionalidad,cNacionalidad,cIdPaisNacimiento,cPaisNac,cIdEstadoNacimiento,cEdoNac,cIdCiudadNac,cIdEstado,cEdo,cIdCiudad,cCiudad,
		cIdMunicipio,cIdMunicipio,cColonia,cCalle,cDepartamento,cNroExt,cNroInt,cCodPostal,cTelCasa,cTelCelular,cCorreoElectronico,cIdPaisDomExt,dFechaNac,
		dFecha_vencimiento,iNumColonia,iClavePuesto,iClaveSubPuesto,iNumCalle,cIdCiudad,cCadAnverso,cCadReverso,cOp1,cOp2,cOp3;
	END IF ;

	--SP CONSULTA HUELLA													
	CALL bdinteg:"informix".sp_conhuella(pempresa,psucursal,pejecutivo,cNumCte )
	RETURNING vcodret,vmapadloc,vmapailoc;

	LET cOp1 = vmapadloc;
	LET cOp2 = vmapailoc;

	IF vcodret = 132 OR (vmapadloc IS NULL  AND vmapailoc IS NULL ) THEN
		LET cCodRet = '00000';
		LET cDescCod = 'BUSQUEDA EXITOSA';
		LET cCodRetSec = '00003';
		let cDescCodSec  ='Cliente sin huellas Registradas';
	ELIF iTipoCliente =  1 and dFecha_vencimiento >= TODAY THEN
		LET cCodRet = '00000';
		LET cDescCod = 'BUSQUEDA EXITOSA';
		LET cCodRetSec = '00001';
		LET cDescCodSec = 'Cliente ya ENROLADO';
	ELIF iTipoCliente =  2 AND (dFecha_vencimiento IS NULL OR  NVL(dFecha_vencimiento, "") = "" OR dFecha_vencimiento < TODAY) THEN
		LET cCodRet = '00000';
		LET cDescCod = 'BUSQUEDA EXITOSA';
		LET cCodRetSec = '00002';
		LET cDescCodSec = 'Id Vencida o Campo Vacio';
		IF NVL(pIdCanal,'') <> '2' THEN
		LET cnumidentificacion ='';
		END IF;
		LET dfecha_vencimiento ='';
		LET cclaveelector ='';
		LET cnumemision ='';
	ELIF iTipoCliente =  1 AND (dFecha_vencimiento IS NULL OR  NVL(dFecha_vencimiento, "") = "" OR dFecha_vencimiento < TODAY) THEN
		LET cCodRet = '00000';
		LET cDescCod = 'VERIFIQUE VIGENCIA ID';
		LET cCodRetSec = '00010';
		LET cDescCodSec = 'Id Vencida o Campo Vacio';
		LET cnumidentificacion ='';
		LET dfecha_vencimiento ='';
		LET cclaveelector ='';
		LET cnumemision ='';
		RETURN
		cCodRet,cDescCod,cCodRetSec,cDescCodSec,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc,cCiudadNac,cNombre1,cNombre2,cApellPat,cApellMat,
		cSexo,cTipoCte,cCodOcupacion,cOcupacion,cTipoIdentificacion,cTipoIdentificacion,cNumIdentificacion,cClaveElector,cNumEmision,cIdPaisEmision,
		cIdPaisEmision,cIdNacionalidad,cNacionalidad,cIdPaisNacimiento,cPaisNac,cIdEstadoNacimiento,cEdoNac,cIdCiudadNac,cIdEstado,cEdo,cIdCiudad,cCiudad,
		cIdMunicipio,cIdMunicipio,cColonia,cCalle,cDepartamento,cNroExt,cNroInt,cCodPostal,cTelCasa,cTelCelular,cCorreoElectronico,cIdPaisDomExt,dFechaNac,
		dFecha_vencimiento,iNumColonia,iClavePuesto,iClaveSubPuesto,iNumCalle,cIdCiudad,cCadAnverso,cCadReverso,cOp1,cOp2,cOp3;
	END IF;

	--SP VERIFICA QUE EL CLIENTE YA ESTA VALIDADO ANTE EL INE  		
	IF cTipoIdentificacion = 'A' THEN															
		CALL bdinteg:"informix".sp_valida_huellaine_cte(cNumCte)
		RETURNING cCodRet;
		IF 	cCodRet <> 0 THEN
			LET cCodRet = '00000';														
			LET cCodRetSec = '30001';
			LET cDescCodSec ='Cte no Validado ante el INE';
			RETURN
			cCodRet,cDescCod,cCodRetSec,cDescCodSec,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc,cCiudadNac,cNombre1,cNombre2,cApellPat,cApellMat,
			cSexo,cTipoCte,cCodOcupacion,cOcupacion,cTipoIdentificacion,cTipoIdentificacion,cNumIdentificacion,cClaveElector,cNumEmision,cIdPaisEmision,
			cIdPaisEmision,cIdNacionalidad,cNacionalidad,cIdPaisNacimiento,cPaisNac,cIdEstadoNacimiento,cEdoNac,cIdCiudadNac,cIdEstado,cEdo,cIdCiudad,cCiudad,
			cIdMunicipio,cIdMunicipio,cColonia,cCalle,cDepartamento,cNroExt,cNroInt,cCodPostal,cTelCasa,cTelCelular,cCorreoElectronico,cIdPaisDomExt,dFechaNac,
			dFecha_vencimiento,iNumColonia,iClavePuesto,iClaveSubPuesto,iNumCalle,cIdCiudad,cCadAnverso,cCadReverso,cOp1,cOp2,cOp3;
		END IF;
	END IF;

	RETURN
	cCodRet,cDescCod,cCodRetSec,cDescCodSec,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc,cCiudadNac,cNombre1,cNombre2,cApellPat,cApellMat,
	cSexo,cTipoCte,cCodOcupacion,cOcupacion,cTipoIdentificacion,cTipoIdentificacion,cNumIdentificacion,cClaveElector,cNumEmision,cIdPaisEmision,
	cIdPaisEmision,cIdNacionalidad,cNacionalidad,cIdPaisNacimiento,cPaisNac,cIdEstadoNacimiento,cEdoNac,cIdCiudadNac,cIdEstado,cEdo,cIdCiudad,cCiudad,
	cIdMunicipio,cIdMunicipio,cColonia,cCalle,cDepartamento,cNroExt,cNroInt,cCodPostal,cTelCasa,cTelCelular,cCorreoElectronico,cIdPaisDomExt,dFechaNac,
	dFecha_vencimiento,iNumColonia,iClavePuesto,iClaveSubPuesto,iNumCalle,cIdCiudad,cCadAnverso,cCadReverso,cOp1,cOp2,cOp3;	
END;
END PROCEDURE

DOCUMENT
'ACTUALIZACION: Se agrega la consulta a bitacora ine historico',
'AUTOR: Aaron QuiÃ±onez',
'FECHA: 16/04/2026',
'BD: BDISAC';


CREATE PROCEDURE "informix".sp_reporteliquidacionarabela(cId_Convenio CHAR(5) )
   DEFINE cCodret           CHAR(5);
   DEFINE cCodRet2          CHAR(5);
   DEFINE cAnioMes          CHAR(6);
   DEFINE cInfoErr          CHAR(100);
   DEFINE iSqlErr           INTEGER;
   DEFINE iIsamErr          INTEGER;
   DEFINE iRecEfe           INTEGER;
   DEFINE iRecCC            INTEGER;
   DEFINE iRecMix           INTEGER;
   DEFINE iRecEfeT          INTEGER;
   DEFINE iRecCCT           INTEGER;
   DEFINE iRecMixT          INTEGER;
   DEFINE iRecTot           INTEGER;
   DEFINE iRecAux           INTEGER;
   DEFINE iRecLun           INTEGER;
   DEFINE iRecMAr           INTEGER;
   DEFINE iRecMie           INTEGER;
   DEFINE iRecJue           INTEGER;
   DEFINE iRecVie           INTEGER;
   DEFINE iRecSab           INTEGER;
   DEFINE iRecDom           INTEGER;
   DEFINE iNumOpe           INTEGER;

   DEFINE deLiqlun          MONEY(16,2);
   DEFINE deLiqMar          MONEY(16,2);
   DEFINE deLiqMier         MONEY(16,2);
   DEFINE deLiqJue          MONEY(16,2);
   DEFINE deLiqVie          MONEY(16,2);
   DEFINE deLiqResguardo    MONEY(16,2);
   
   DEFINE deCobEfe          MONEY(16,2);
   DEFINE deCobMix          MONEY(16,2);
   DEFINE deCobCC           MONEY(16,2);
   DEFINE deCobEfeT         MONEY(16,2);
   DEFINE deCobMixT         MONEY(16,2);
   DEFINE deCobCCT          MONEY(16,2);
   DEFINE deCobTot          MONEY(16,2);
   DEFINE deCobAux          MONEY(16,2);
   DEFINE deCobLun          MONEY(16,2);
   DEFINE deCobMar          MONEY(16,2);
   DEFINE deCobMie          MONEY(16,2);
   DEFINE deCobJue          MONEY(16,2);
   DEFINE deCobVie          MONEY(16,2);
   DEFINE deCobSab          MONEY(16,2);
   DEFINE deCobDom          MONEY(16,2);
   DEFINE deTotComision     MONEY(16,2);
   DEFINE deTotIvaCom       MONEY(16,2);
   DEFINE deComision        MONEY(16,2);
   DEFINE deIvaCom          MONEY(16,2);
   
   DEFINE deAcumulado       MONEY(16,2);
  
   DEFINE cCategoria        CHAR(2);
   DEFINE cConvenio         CHAR(3);

   DEFINE dFechaAux         DATE;
   DEFINE dfecha_Hoy        DATE;
   DEFINE dFechaIni         DATE;
   DEFINE dPriDiaMes        DATE;
   DEFINE dUltDiaMes        DATE;
   
   DEFINE iDias             INTEGER;
   DEFINE cFechaLiq         CHAR (10);

   --SET DEBUG FILE TO "/respaldosbd/Dulce/sp_reporteliquidacionARA.out";
   --TRACE ON;
   
   LET cCodRet2        = "00000";
   LET cCodret         = "00000";
   LET cInfoErr        = '';
   LET cAnioMes        = '';
   LET deCobEfe        = 0;
   LET deCobCC         = 0;
   LET deCobMix        = 0;
   LET iRecEfe         = 0;
   LET iRecCC          = 0;
   LET iRecMix         = 0;
   LET deComision      = 0;
   LET deIvaCom        = 0;
   LET deCobEfeT       = 0;
   LET deCobCCT        = 0;
   LET iRecEfeT        = 0;
   LET iRecCCT         = 0;
   LET deTotComision   = 0;                      
   LET deTotIvaCom     = 0;              
   LET iRecLun         = 0;            
   LET deCobLun        = 0;            
   LET iRecMar         = 0;            
   LET deCobMar        = 0;            
   LET iRecMie         = 0;            
   LET deCobMie        = 0;            
   LET iRecJue         = 0;            
   LET deCobJue        = 0;            
   LET iRecVie         = 0;            
   LET deCobVie        = 0;            
   LET iRecSab         = 0;            
   LET deCobSab        = 0;            
   LET iRecDom         = 0;            
   LET deCobDom        = 0;            
   LET cCategoria      = SUBSTRING(cId_Convenio FROM 1 FOR 2);
   LET cConvenio       = SUBSTRING(cId_Convenio FROM 3 FOR 3);
   LET dFechaAux       = '';
   LET dfecha_Hoy      = '';
   LET dFechaIni       = '';
   LET dPriDiaMes	   = '';
   LET dUltDiaMes	   = '';
   LET iNumOpe	       = 0;
   
    LET deLiqlun       = 0;
    LET deLiqMar       = 0;
    LET deLiqMier      = 0;
    LET deLiqJue       = 0;
    LET deLiqVie       = 0;
    LET cFechaLiq      = "";
	LET deLiqResguardo = 0;
	LET deAcumulado    = 0; 
	
   BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;

                    UPDATE sac_controlreportesespeciales
                    SET retorno = cCodRet
                    WHERE numcategoria = cCategoria
                    AND numconvenio = cConvenio;

                    EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacionarabela");
                END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;

        SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
        INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
        FROM bdisac:"informix".sac_fechas;

        IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

            LET dFechaAux = dfecha_Hoy - 6;
            LET dFechaIni = dFechaAux;
			
			SELECT NVL(liq_resguardo ,0)
			INTO deAcumulado
			FROM bdisac:"informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
			                            FROM bdisac:"informix".sac_liquidacionsemanal 
			                            WHERE id_convenio = cCategoria||cConvenio
										AND consecutivo_convenio <> 0);
				
				
			IF 	deAcumulado IS NULL THEN
			    LET deAcumulado = 0;
			END IF;
			
            WHILE dFechaAux <= dfecha_Hoy
                SELECT NVL(SUM(efe),0), NVL(SUM(cc),0), NVL(SUM(mix),0), COUNT(Rec1), COUNT(Rec2), COUNT(Rec3), NVL(SUM(comision), 0), NVL(SUM(iva_com),0)
                INTO deCobEfe, deCobCC, deCobMix, iRecEfe, iRecCC, iRecMix, deComision, deIvaCom
                FROM TABLE(
                    MULTISET(
                        SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
                                CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
                                CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
                                CASE WHEN forma_pago = 3 THEN NVL(importe_pago, 0) END AS mix,
                                CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
                                CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
                                CASE WHEN forma_pago = 3 THEN folio_suc END AS Rec3
                        FROM bdisac:"informix".sac_movimientoshistorial
                        WHERE numcategoria = cCategoria
                        AND numconvenio = cConvenio
                        AND fecha_pago  = dFechaAux
                        AND status_cancelado = 'N'));

                LET deCobEfeT = deCobEfeT + deCobEfe + deCobMix;
                LET deCobCCT = deCobCCT + deCobCC;

                LET iRecEfeT = iRecEfeT + iRecEfe + iRecMix;
                LET iRecCCT = iRecCCT + iRecCC;

                LET deTotComision = deTotComision + deComision;
                LET deTotIvaCom = deTotIvaCom + deIvaCom;

								
				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;
					
				IF CAST(cCodRet2 AS INTEGER) = 0 THEN
						
					LET iDias =  cFechaLiq::date - dFechaAux::date;

	                IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
	                    LET iRecLun = iRecEfe + iRecCC + iRecMix;
	                    LET deCobLun = deCobEfe + deCobCC + deCobMix;
							
						IF iDias = 1 THEN 
							LET deLiqMar = deLiqMar + deCobLun;
							IF deAcumulado <> 0 THEN
								LET deLiqMar = deLiqMar + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET deLiqMier = deLiqMier + deCobLun;
							IF deAcumulado <> 0 THEN
								LET deLiqMier = deLiqMier + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias = 3 THEN 
							LET deLiqJue = deLiqJue + deCobLun;
							IF deAcumulado <> 0 THEN
								LET deLiqJue = deLiqJue + deAcumulado;
							    LET deAcumulado = 0;
							END IF;
						ELIF iDias = 4 THEN
							LET deLiqVie = deLiqVie + deCobLun;
							IF deAcumulado <> 0 THEN
								LET deLiqVie = deLiqVie + deAcumulado;
							    LET deAcumulado = 0;
							END IF;
						ELIF iDias >= 5 AND iDias <= 7 THEN
							LET deLiqlun =  deLiqlun + deCobLun;
							IF deAcumulado <> 0 THEN
								LET deLiqlun = deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobLun;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo = deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						END IF;
					END IF;	
							
	                    
	                IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
	                    LET iRecMar = iRecEfe + iRecCC + iRecMix;
	                    LET deCobMar = deCobEfe + deCobCC + deCobMix;
						
					    IF iDias = 1 THEN 
							LET deLiqMier =  deLiqMier + deCobMar;
							IF deAcumulado <> 0 THEN
							    LET deLiqMier = deLiqMier + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET deLiqJue = deLiqJue + deCobMar;
							IF deAcumulado <> 0 THEN
								LET deLiqJue = deLiqJue + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias = 3 THEN 
							LET deLiqVie = deLiqVie + deCobMar;
							IF deAcumulado <> 0 THEN
								LET deLiqVie = deLiqVie + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias >= 4 AND iDias <= 6 THEN 
							LET deLiqlun =  deLiqlun + deCobMar;
							IF deAcumulado <> 0 THEN
								LET deLiqlun = deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobMar;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo = deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						END IF;
							
	                END IF;
	                
					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
	                    LET iRecMie = iRecEfe + iRecCC + iRecMix;
	                    LET deCobMie = deCobEfe + deCobCC + deCobMix;
							
						IF iDias = 1 THEN 
							LET deLiqJue = deLiqJue + deCobMie;
							IF deAcumulado <> 0 THEN
								LET deLiqJue = deLiqJue + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET deLiqVie = deLiqVie + deCobMie;
							IF deAcumulado <> 0 THEN
								LET deLiqVie = deLiqVie + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias >= 3 AND iDias <= 5 THEN 
							LET deLiqlun =  deLiqlun + deCobMie;
							IF deAcumulado <> 0 THEN
								LET deLiqlun = deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobMie;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo = deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						END IF;
							
							
	                END IF;
					
					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC + iRecMix;
						LET deCobJue = deCobEfe + deCobCC + deCobMix;
						
						IF iDias = 1 THEN 
							LET deLiqVie = deLiqVie + deCobJue;
							IF deAcumulado <> 0 THEN
								LET deLiqVie = deLiqVie + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias >= 2 AND iDias <= 4 THEN
							LET deLiqlun =  deLiqlun + deCobJue;
							IF deAcumulado <> 0 THEN
								LET deLiqlun = deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobJue;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo = deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						END IF;
						
					END IF;
					
					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC + iRecMix;
						LET deCobVie = deCobEfe + deCobCC + deCobMix;
						
						IF iDias >= 1 AND iDias <= 3 THEN 
							LET deLiqlun =  deLiqlun + deCobVie;
							IF deAcumulado <> 0 THEN
								LET deLiqlun = deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobVie;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo =deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
					    END IF;
					END IF;
					
					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC + iRecMix;
						LET deCobSab = deCobEfe + deCobCC + deCobMix;
						
						IF iDias >= 1  AND iDias <= 2 THEN 
							LET deLiqlun =  deLiqlun + deCobSab;
							IF deAcumulado <> 0 THEN
								LET deLiqlun =deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobSab;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo = deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						END IF;

					END IF;
	                    
					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC + iRecMix;
						LET deCobDom = deCobEfe + deCobCC + deCobMix;
						
						IF iDias = 1 THEN 
							LET deLiqlun =  deLiqlun + deCobDom;
							
							IF deAcumulado <> 0 THEN
								LET deLiqlun = deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobDom;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo = deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						END IF;
					END IF;
					
	                LET dFechaAux = dFechaAux + 1;
                
				END IF;
	        END WHILE;
			
			IF CAST(cCodRet2 AS INTEGER) = 0 THEN

	            INSERT INTO bdisac:"informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo,
	                                cob_lunes, cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo,
	                                rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred,
	                                cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred,
	                                liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,
	                                aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
	            VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom,
	                    deCobLun, deCobMar, deCobMie, deCobJue, deCobVie, deCobSab, deCobDom,
	                    iRecEfeT, iRecCCT, 0, 0, 
					   deCobEfeT, deCobCCT, 0, 0,
	                   deLiqlun, deLiqMar, deLiqMier, deLiqJue, deLiqVie,
	                    0, deTotComision, deTotIvaCom, dFechaIni,dfecha_Hoy, deLiqResguardo, (SELECT NVL(MAX(consecutivo_convenio + 1 ),1)
						                                                            FROM bdisac:"informix".sac_liquidacionsemanal
																					WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
	    END IF;
        
        IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
            LET dFechaAux = dPriDiaMes;
            LET deComision =0;
            LET deIvaCom =0;
            LET cAnioMes = to_char(dfecha_Hoy,"%Y%m");

            WHILE dFechaAux <= dfecha_Hoy

                          SELECT COUNT(folio_suc), NVL(SUM(importe_comision_convenio),0), NVL(SUM(iva_comision_convenio),0) 
                          INTO iNumOpe, deComision, deIvaCom
                          FROM bdisac:"informix".sac_movimientoshistorial
                           WHERE numcategoria = cCategoria
                           AND numconvenio = cConvenio
                           AND fecha_pago  = dFechaAux
                           AND status_cancelado = 'N';

                          INSERT INTO bdisac:"informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
                          VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, deComision, deIvaCom, CURRENT);

                          LET dFechaAux = dFechaAux + 1;                         
            END WHILE;
		
        END IF;
       
	    IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
		    LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;
		
	    UPDATE bdisac:"informix".sac_controlreportesespeciales
	    SET retorno = cCodret
	    WHERE numcategoria = cCategoria
	    AND numconvenio = cConvenio;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : Dulce Ramírez',
'DESCRIPCION: Genera la informacion para los Reportes Semanal y Mensual de Pagos ARABELA',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de sp_ProcesoCierreSAC()',
'FECHA : 12 de Septiembre de 2011',
'VERSION: 20110912.1650',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidacioneci(cId_Convenio CHAR(5))

   DEFINE cCodret        CHAR(5);
   DEFINE cCodRet2       CHAR(5);
   DEFINE cAnioMes       CHAR(6);
   DEFINE cInfoErr       CHAR(100);
   DEFINE iSqlErr        INTEGER;
   DEFINE iIsamErr       INTEGER;
   DEFINE iRecEfe        INTEGER;
   DEFINE iRecCC         INTEGER;
   DEFINE iRecMix        INTEGER;
   DEFINE iRecEfeT       INTEGER;
   DEFINE iRecCCT        INTEGER;
   DEFINE iRecMixT       INTEGER;
   DEFINE iRecTot        INTEGER;
   DEFINE iRecAux        INTEGER;
   DEFINE iRecLun        INTEGER;
   DEFINE iRecMAr        INTEGER;
   DEFINE iRecMie        INTEGER;
   DEFINE iRecJue        INTEGER;
   DEFINE iRecVie        INTEGER;
   DEFINE iRecSab        INTEGER;
   DEFINE iRecDom        INTEGER;
   DEFINE iNumOpe        INTEGER;

   DEFINE deLiqlun       MONEY(16,2);
   DEFINE deLiqMar       MONEY(16,2);
   DEFINE deLiqMier      MONEY(16,2);
   DEFINE deLiqJue       MONEY(16,2);
   DEFINE deLiqVie       MONEY(16,2);
   DEFINE deLiqResguardo MONEY(16,2);

   DEFINE deCobEfe          MONEY(16,2);
   DEFINE deCobMix          MONEY(16,2);
   DEFINE deCobCC           MONEY(16,2);
   DEFINE deCobEfeT         MONEY(16,2);
   DEFINE deCobMixT         MONEY(16,2);
   DEFINE deCobCCT          MONEY(16,2);
   DEFINE deCobTot          MONEY(16,2);
   DEFINE deCobAux          MONEY(16,2);
   DEFINE deCobLun          MONEY(16,2);
   DEFINE deCobMar          MONEY(16,2);
   DEFINE deCobMie          MONEY(16,2);
   DEFINE deCobJue          MONEY(16,2);
   DEFINE deCobVie          MONEY(16,2);
   DEFINE deCobSab          MONEY(16,2);
   DEFINE deCobDom          MONEY(16,2);
   DEFINE deTotComision     MONEY(16,2);
   DEFINE deTotIvaCom       MONEY(16,2);
   DEFINE deComision        MONEY(16,2);
   DEFINE deIvaCom          MONEY(16,2);

   DEFINE deAcumulado       MONEY(16,2);

   DEFINE cCategoria         CHAR(2);
   DEFINE cConvenio          CHAR(3);

   DEFINE dFechaAux          DATE;
   DEFINE dfecha_Hoy         DATE;
   DEFINE dFechaIni          DATE;
   DEFINE dPriDiaMes         DATE;
   DEFINE dUltDiaMes         DATE;

   DEFINE iDias              INTEGER;
   DEFINE cFechaLiq          CHAR (10);

   --SET DEBUG FILE TO "/respaldosbd/Dulce/sp_reporteliquidacioneci.out";
   --TRACE ON;

   LET cCodRet2    = "00000";
   LET cCodret     = "00000";
   LET cInfoErr    = '';
   LET cAnioMes    = '';
   LET deCobEfe    = 0;
   LET deCobCC     = 0;
   LET deCobMix    = 0;
   LET iRecEfe     = 0;
   LET iRecCC      = 0;
   LET iRecMix     = 0;
   LET deComision  = 0;
   LET deIvaCom    = 0;
   LET deCobEfeT   = 0;
   LET deCobCCT    = 0;
   LET iRecEfeT    = 0;
   LET iRecCCT       = 0;
   LET deTotComision = 0;
   LET deTotIvaCom   = 0;
   LET iRecLun       = 0;
   LET deCobLun      = 0;
   LET iRecMar       = 0;
   LET deCobMar      = 0;
   LET iRecMie       = 0;
   LET deCobMie      = 0;
   LET iRecJue       = 0;
   LET deCobJue      = 0;
   LET iRecVie       = 0;
   LET deCobVie      = 0;
   LET iRecSab       = 0;
   LET deCobSab      = 0;
   LET iRecDom       = 0;
   LET deCobDom      = 0;
   LET cCategoria    = SUBSTRING(cId_Convenio FROM 1 FOR 2);
   LET cConvenio     = SUBSTRING(cId_Convenio FROM 3 FOR 3);
   LET dFechaAux     = '';
   LET dfecha_Hoy    = '';
   LET dFechaIni     = '';
   LET dPriDiaMes	 = '';
   LET dUltDiaMes	 = '';
   LET iNumOpe	     = 0;

   LET deLiqlun      = 0;
   LET deLiqMar      = 0;
   LET deLiqMier     = 0;
   LET deLiqJue      = 0;
   LET deLiqVie      = 0;
   LET cFechaLiq     = "";
   LET deLiqResguardo = 0;
   LET deAcumulado    = 0;

   BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;

                    UPDATE bdisac:"informix".sac_controlreportesespeciales
                    SET retorno = cCodRet
                    WHERE numcategoria = cCategoria
                    AND numconvenio = cConvenio;

                    EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacioneci");
                END IF;
        END EXCEPTION;

		SET LOCK MODE TO WAIT 3;

        SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
        INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
        FROM bdisac:"informix".sac_fechas;

        IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

            LET dFechaAux = dfecha_Hoy - 6;
            LET dFechaIni = dFechaAux;

			SELECT NVL(liq_resguardo ,0)
			INTO deAcumulado
			FROM bdisac:"informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
			                            FROM bdisac:"informix".sac_liquidacionsemanal
			                            WHERE id_convenio = cCategoria||cConvenio
										AND consecutivo_convenio <> 0);


			IF 	deAcumulado IS NULL THEN
			    LET deAcumulado = 0;
			END IF;

            WHILE dFechaAux <= dfecha_Hoy
                SELECT NVL(SUM(efe),0), NVL(SUM(cc),0), NVL(SUM(mix),0), COUNT(Rec1), COUNT(Rec2), COUNT(Rec3), NVL(SUM(comision), 0), NVL(SUM(iva_com),0)
                INTO deCobEfe, deCobCC, deCobMix, iRecEfe, iRecCC, iRecMix, deComision, deIvaCom
                FROM TABLE(
                    MULTISET(
                        SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
                                CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
                                CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
                                CASE WHEN forma_pago = 3 THEN NVL(importe_pago, 0) END AS mix,
                                CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
                                CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
                                CASE WHEN forma_pago = 3 THEN folio_suc END AS Rec3
                        FROM bdisac:"informix".sac_movimientoshistorial
                        WHERE numcategoria = cCategoria
                        AND numconvenio = cConvenio
                        AND fecha_pago  = dFechaAux
                        AND status_cancelado = 'N'));

                LET deCobEfeT = deCobEfeT + deCobEfe + deCobMix;
                LET deCobCCT = deCobCCT + deCobCC;

                LET iRecEfeT = iRecEfeT + iRecEfe + iRecMix;
                LET iRecCCT = iRecCCT + iRecCC;

                LET deTotComision = deTotComision + deComision;
                LET deTotIvaCom = deTotIvaCom + deIvaCom;


				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::date - dFechaAux::date;

	                IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
	                    LET iRecLun = iRecEfe + iRecCC + iRecMix;
	                    LET deCobLun = deCobEfe + deCobCC + deCobMix;

						IF iDias = 1 THEN
							LET deLiqMar = deLiqMar + deCobLun;
							IF deAcumulado <> 0 THEN
								LET deLiqMar = deLiqMar + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET deLiqMier = deLiqMier + deCobLun;
							IF deAcumulado <> 0 THEN
								LET deLiqMier = deLiqMier + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias = 3 THEN
							LET deLiqJue = deLiqJue + deCobLun;
							IF deAcumulado <> 0 THEN
								LET deLiqJue = deLiqJue + deAcumulado;
							    LET deAcumulado = 0;
							END IF;
						ELIF iDias = 4 THEN
							LET deLiqVie = deLiqVie + deCobLun;
							IF deAcumulado <> 0 THEN
								LET deLiqVie = deLiqVie + deAcumulado;
							    LET deAcumulado = 0;
							END IF;
						ELIF iDias >= 5 AND iDias <= 7 THEN
							LET deLiqlun =  deLiqlun + deCobLun;
							IF deAcumulado <> 0 THEN
								LET deLiqlun = deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobLun;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo = deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						END IF;
					END IF;


	                IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
	                    LET iRecMar = iRecEfe + iRecCC + iRecMix;
	                    LET deCobMar = deCobEfe + deCobCC + deCobMix;

					    IF iDias = 1 THEN
							LET deLiqMier =  deLiqMier + deCobMar;
							IF deAcumulado <> 0 THEN
							    LET deLiqMier = deLiqMier + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET deLiqJue = deLiqJue + deCobMar;
							IF deAcumulado <> 0 THEN
								LET deLiqJue = deLiqJue + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias = 3 THEN
							LET deLiqVie = deLiqVie + deCobMar;
							IF deAcumulado <> 0 THEN
								LET deLiqVie = deLiqVie + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias >= 4 AND iDias <= 6 THEN
							LET deLiqlun =  deLiqlun + deCobMar;
							IF deAcumulado <> 0 THEN
								LET deLiqlun = deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobMar;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo = deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						END IF;

	                END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
	                    LET iRecMie = iRecEfe + iRecCC + iRecMix;
	                    LET deCobMie = deCobEfe + deCobCC + deCobMix;

						IF iDias = 1 THEN
							LET deLiqJue = deLiqJue + deCobMie;
							IF deAcumulado <> 0 THEN
								LET deLiqJue = deLiqJue + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET deLiqVie = deLiqVie + deCobMie;
							IF deAcumulado <> 0 THEN
								LET deLiqVie = deLiqVie + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias >= 3 AND iDias <= 5 THEN
							LET deLiqlun =  deLiqlun + deCobMie;
							IF deAcumulado <> 0 THEN
								LET deLiqlun = deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobMie;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo = deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						END IF;


	                END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC + iRecMix;
						LET deCobJue = deCobEfe + deCobCC + deCobMix;

						IF iDias = 1 THEN
							LET deLiqVie = deLiqVie + deCobJue;
							IF deAcumulado <> 0 THEN
								LET deLiqVie = deLiqVie + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias >= 2 AND iDias <= 4 THEN
							LET deLiqlun =  deLiqlun + deCobJue;
							IF deAcumulado <> 0 THEN
								LET deLiqlun = deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobJue;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo = deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						END IF;

					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC + iRecMix;
						LET deCobVie = deCobEfe + deCobCC + deCobMix;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET deLiqlun =  deLiqlun + deCobVie;
							IF deAcumulado <> 0 THEN
								LET deLiqlun = deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobVie;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo =deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC + iRecMix;
						LET deCobSab = deCobEfe + deCobCC + deCobMix;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET deLiqlun =  deLiqlun + deCobSab;
							IF deAcumulado <> 0 THEN
								LET deLiqlun =deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobSab;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo = deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						END IF;

					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC + iRecMix;
						LET deCobDom = deCobEfe + deCobCC + deCobMix;

						IF iDias = 1 THEN
							LET deLiqlun =  deLiqlun + deCobDom;

							IF deAcumulado <> 0 THEN
								LET deLiqlun = deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobDom;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo = deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						END IF;
					END IF;

	                LET dFechaAux = dFechaAux + 1;

				END IF;
	        END WHILE;

			IF CAST(cCodRet2 AS INTEGER) = 0 THEN

	            INSERT INTO bdisac:"informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo,
	                                cob_lunes, cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo,
	                                rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred,
	                                cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred,
	                                liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,
	                                aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
	            VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom,
	                    deCobLun, deCobMar, deCobMie, deCobJue, deCobVie, deCobSab, deCobDom,
	                    iRecEfeT, iRecCCT, 0, 0,
					   deCobEfeT, deCobCCT, 0, 0,
	                   deLiqlun, deLiqMar, deLiqMier, deLiqJue, deLiqVie,
	                    0, deTotComision, deTotIvaCom, dFechaIni,dfecha_Hoy, deLiqResguardo, (SELECT NVL(MAX(consecutivo_convenio + 1 ),1)
						                                                            FROM bdisac:"informix".sac_liquidacionsemanal
																					WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
	    END IF;

        IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
            LET dFechaAux = dPriDiaMes;
            LET deComision =0;
            LET deIvaCom =0;
            LET cAnioMes = to_char(dfecha_Hoy,"%Y%m");

            WHILE dFechaAux <= dfecha_Hoy

                          SELECT COUNT(folio_suc), NVL(SUM(importe_comision_convenio),0), NVL(SUM(iva_comision_convenio),0)
                          INTO iNumOpe, deComision, deIvaCom
                          FROM bdisac:"informix".sac_movimientoshistorial
                           WHERE numcategoria = cCategoria
                           AND numconvenio = cConvenio
                           AND fecha_pago  = dFechaAux
                           AND status_cancelado = 'N';

                          INSERT INTO bdisac:"informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
                          VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, deComision, deIvaCom, CURRENT);

                          LET dFechaAux = dFechaAux + 1;
            END WHILE;

        END IF;

	    IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
		    LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;

	    UPDATE bdisac:"informix".sac_controlreportesespeciales
	    SET retorno = cCodret
	    WHERE numcategoria = cCategoria
	    AND numconvenio = cConvenio;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : Dulce Ramirez',
'DESCRIPCION: Genera la informacion para los Reportes Semanal y Mensual de Pagos ECI',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de sp_ProcesoCierreSAC()',
'FECHA : 12 de Septiembre de 2011',
'VERSION: 20110912.1650',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidacion_tmp(cId_Convenio CHAR(5))

   DEFINE cCodret        CHAR(5);
   DEFINE cCodRet2       CHAR(5);
   DEFINE cAnioMes       CHAR(6);
   DEFINE cInfoErr       CHAR(100);
   DEFINE iSqlErr        INTEGER;
   DEFINE iIsamErr       INTEGER;
   DEFINE iRecEfe        INTEGER;
   DEFINE iRecCC         INTEGER;
   DEFINE iRecMix        INTEGER;
   DEFINE iRecEfeT       INTEGER;
   DEFINE iRecCCT        INTEGER;
   DEFINE iRecMixT       INTEGER;
   DEFINE iRecTot        INTEGER;
   DEFINE iRecAux        INTEGER;
   DEFINE iRecLun        INTEGER;
   DEFINE iRecMAr        INTEGER;
   DEFINE iRecMie        INTEGER;
   DEFINE iRecJue        INTEGER;
   DEFINE iRecVie        INTEGER;
   DEFINE iRecSab        INTEGER;
   DEFINE iRecDom        INTEGER;
   DEFINE iNumOpe        INTEGER;

   DEFINE deLiqlun       MONEY(16,2);
   DEFINE deLiqMar       MONEY(16,2);
   DEFINE deLiqMier      MONEY(16,2);
   DEFINE deLiqJue       MONEY(16,2);
   DEFINE deLiqVie       MONEY(16,2);
   DEFINE deLiqResguardo MONEY(16,2);

   DEFINE deCobEfe          MONEY(16,2);
   DEFINE deCobMix          MONEY(16,2);
   DEFINE deCobCC           MONEY(16,2);
   DEFINE deCobEfeT         MONEY(16,2);
   DEFINE deCobMixT         MONEY(16,2);
   DEFINE deCobCCT          MONEY(16,2);
   DEFINE deCobTot          MONEY(16,2);
   DEFINE deCobAux          MONEY(16,2);
   DEFINE deCobLun          MONEY(16,2);
   DEFINE deCobMar          MONEY(16,2);
   DEFINE deCobMie          MONEY(16,2);
   DEFINE deCobJue          MONEY(16,2);
   DEFINE deCobVie          MONEY(16,2);
   DEFINE deCobSab          MONEY(16,2);
   DEFINE deCobDom          MONEY(16,2);
   DEFINE deTotComision     MONEY(16,2);
   DEFINE deTotIvaCom       MONEY(16,2);
   DEFINE deComision        MONEY(16,2);
   DEFINE deIvaCom          MONEY(16,2);

   DEFINE deAcumulado       MONEY(16,2);

   DEFINE cCategoria         CHAR(2);
   DEFINE cConvenio          CHAR(3);

   DEFINE dFechaAux          DATE;
   DEFINE dfecha_Hoy         DATE;
   DEFINE dFechaIni          DATE;
   DEFINE dPriDiaMes         DATE;
   DEFINE dUltDiaMes         DATE;

   DEFINE iDias              INTEGER;
   DEFINE cFechaLiq          CHAR (10);

   --SET DEBUG FILE TO "/respaldosbd/Dulce/sp_reporteliquidacioneci.out";
   --TRACE ON;

   LET cCodRet2    = "00000";
   LET cCodret     = "00000";
   LET cInfoErr    = '';
   LET cAnioMes    = '';
   LET deCobEfe    = 0;
   LET deCobCC     = 0;
   LET deCobMix    = 0;
   LET iRecEfe     = 0;
   LET iRecCC      = 0;
   LET iRecMix     = 0;
   LET deComision  = 0;
   LET deIvaCom    = 0;
   LET deCobEfeT   = 0;
   LET deCobCCT    = 0;
   LET iRecEfeT    = 0;
   LET iRecCCT       = 0;
   LET deTotComision = 0;
   LET deTotIvaCom   = 0;
   LET iRecLun       = 0;
   LET deCobLun      = 0;
   LET iRecMar       = 0;
   LET deCobMar      = 0;
   LET iRecMie       = 0;
   LET deCobMie      = 0;
   LET iRecJue       = 0;
   LET deCobJue      = 0;
   LET iRecVie       = 0;
   LET deCobVie      = 0;
   LET iRecSab       = 0;
   LET deCobSab      = 0;
   LET iRecDom       = 0;
   LET deCobDom      = 0;
   LET cCategoria    = SUBSTRING(cId_Convenio FROM 1 FOR 2);
   LET cConvenio     = SUBSTRING(cId_Convenio FROM 3 FOR 3);
   LET dFechaAux     = '';
   LET dfecha_Hoy    = '';
   LET dFechaIni     = '';
   LET dPriDiaMes	 = '';
   LET dUltDiaMes	 = '';
   LET iNumOpe	     = 0;

   LET deLiqlun      = 0;
   LET deLiqMar      = 0;
   LET deLiqMier     = 0;
   LET deLiqJue      = 0;
   LET deLiqVie      = 0;
   LET cFechaLiq     = "";
   LET deLiqResguardo = 0;
   LET deAcumulado    = 0;

   BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;

                    UPDATE bdisac:"informix".sac_controlreportesespeciales
                    SET retorno = cCodRet
                    WHERE numcategoria = cCategoria
                    AND numconvenio = cConvenio;

                    EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacioneci");
                END IF;
        END EXCEPTION;

		SET LOCK MODE TO WAIT 3;

        SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
        INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
        FROM bdisac:"informix".sac_fechas;

		LET dfecha_Hoy = '02-12-2012';
		
        IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

            LET dFechaAux = dfecha_Hoy - 6;
            LET dFechaIni = dFechaAux;

			SELECT NVL(liq_resguardo ,0)
			INTO deAcumulado
			FROM bdisac:"informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
			                            FROM bdisac:"informix".sac_liquidacionsemanal
			                            WHERE id_convenio = cCategoria||cConvenio
										AND consecutivo_convenio <> 0);


			IF 	deAcumulado IS NULL THEN
			    LET deAcumulado = 0;
			END IF;

            WHILE dFechaAux <= dfecha_Hoy
                SELECT NVL(SUM(efe),0), NVL(SUM(cc),0), NVL(SUM(mix),0), COUNT(Rec1), COUNT(Rec2), COUNT(Rec3), NVL(SUM(comision), 0), NVL(SUM(iva_com),0)
                INTO deCobEfe, deCobCC, deCobMix, iRecEfe, iRecCC, iRecMix, deComision, deIvaCom
                FROM TABLE(
                    MULTISET(
                        SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
                                CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
                                CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
                                CASE WHEN forma_pago = 3 THEN NVL(importe_pago, 0) END AS mix,
                                CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
                                CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
                                CASE WHEN forma_pago = 3 THEN folio_suc END AS Rec3
                        FROM bdisac:"informix".sac_movimientoshistorial
                        WHERE numcategoria = cCategoria
                        AND numconvenio = cConvenio
                        AND fecha_pago  = dFechaAux
                        AND status_cancelado = 'N'));

                LET deCobEfeT = deCobEfeT + deCobEfe + deCobMix;
                LET deCobCCT = deCobCCT + deCobCC;

                LET iRecEfeT = iRecEfeT + iRecEfe + iRecMix;
                LET iRecCCT = iRecCCT + iRecCC;

                LET deTotComision = deTotComision + deComision;
                LET deTotIvaCom = deTotIvaCom + deIvaCom;


				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::date - dFechaAux::date;

	                IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
	                    LET iRecLun = iRecEfe + iRecCC + iRecMix;
	                    LET deCobLun = deCobEfe + deCobCC + deCobMix;

						IF iDias = 1 THEN
							LET deLiqMar = deLiqMar + deCobLun;
							IF deAcumulado <> 0 THEN
								LET deLiqMar = deLiqMar + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET deLiqMier = deLiqMier + deCobLun;
							IF deAcumulado <> 0 THEN
								LET deLiqMier = deLiqMier + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias = 3 THEN
							LET deLiqJue = deLiqJue + deCobLun;
							IF deAcumulado <> 0 THEN
								LET deLiqJue = deLiqJue + deAcumulado;
							    LET deAcumulado = 0;
							END IF;
						ELIF iDias = 4 THEN
							LET deLiqVie = deLiqVie + deCobLun;
							IF deAcumulado <> 0 THEN
								LET deLiqVie = deLiqVie + deAcumulado;
							    LET deAcumulado = 0;
							END IF;
						ELIF iDias >= 5 AND iDias <= 7 THEN
							LET deLiqlun =  deLiqlun + deCobLun;
							IF deAcumulado <> 0 THEN
								LET deLiqlun = deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobLun;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo = deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						END IF;
					END IF;


	                IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
	                    LET iRecMar = iRecEfe + iRecCC + iRecMix;
	                    LET deCobMar = deCobEfe + deCobCC + deCobMix;

					    IF iDias = 1 THEN
							LET deLiqMier =  deLiqMier + deCobMar;
							IF deAcumulado <> 0 THEN
							    LET deLiqMier = deLiqMier + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET deLiqJue = deLiqJue + deCobMar;
							IF deAcumulado <> 0 THEN
								LET deLiqJue = deLiqJue + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias = 3 THEN
							LET deLiqVie = deLiqVie + deCobMar;
							IF deAcumulado <> 0 THEN
								LET deLiqVie = deLiqVie + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias >= 4 AND iDias <= 6 THEN
							LET deLiqlun =  deLiqlun + deCobMar;
							IF deAcumulado <> 0 THEN
								LET deLiqlun = deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobMar;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo = deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						END IF;

	                END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
	                    LET iRecMie = iRecEfe + iRecCC + iRecMix;
	                    LET deCobMie = deCobEfe + deCobCC + deCobMix;

						IF iDias = 1 THEN
							LET deLiqJue = deLiqJue + deCobMie;
							IF deAcumulado <> 0 THEN
								LET deLiqJue = deLiqJue + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET deLiqVie = deLiqVie + deCobMie;
							IF deAcumulado <> 0 THEN
								LET deLiqVie = deLiqVie + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias >= 3 AND iDias <= 5 THEN
							LET deLiqlun =  deLiqlun + deCobMie;
							IF deAcumulado <> 0 THEN
								LET deLiqlun = deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobMie;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo = deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						END IF;


	                END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC + iRecMix;
						LET deCobJue = deCobEfe + deCobCC + deCobMix;

						IF iDias = 1 THEN
							LET deLiqVie = deLiqVie + deCobJue;
							IF deAcumulado <> 0 THEN
								LET deLiqVie = deLiqVie + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELIF iDias >= 2 AND iDias <= 4 THEN
							LET deLiqlun =  deLiqlun + deCobJue;
							IF deAcumulado <> 0 THEN
								LET deLiqlun = deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobJue;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo = deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						END IF;

					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC + iRecMix;
						LET deCobVie = deCobEfe + deCobCC + deCobMix;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET deLiqlun =  deLiqlun + deCobVie;
							IF deAcumulado <> 0 THEN
								LET deLiqlun = deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobVie;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo =deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC + iRecMix;
						LET deCobSab = deCobEfe + deCobCC + deCobMix;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET deLiqlun =  deLiqlun + deCobSab;
							IF deAcumulado <> 0 THEN
								LET deLiqlun =deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobSab;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo = deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						END IF;

					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC + iRecMix;
						LET deCobDom = deCobEfe + deCobCC + deCobMix;

						IF iDias = 1 THEN
							LET deLiqlun =  deLiqlun + deCobDom;

							IF deAcumulado <> 0 THEN
								LET deLiqlun = deLiqlun + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						ELSE
							LET deLiqResguardo =  deLiqResguardo + deCobDom;
							IF deAcumulado <> 0 THEN
								LET deLiqResguardo = deLiqResguardo + deAcumulado;
								LET deAcumulado = 0;
							END IF;
						END IF;
					END IF;

	                LET dFechaAux = dFechaAux + 1;

				END IF;
	        END WHILE;

			IF CAST(cCodRet2 AS INTEGER) = 0 THEN

	            INSERT INTO bdisac:"informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo,
	                                cob_lunes, cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo,
	                                rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred,
	                                cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred,
	                                liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,
	                                aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
	            VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom,
	                    deCobLun, deCobMar, deCobMie, deCobJue, deCobVie, deCobSab, deCobDom,
	                    iRecEfeT, iRecCCT, 0, 0,
					   deCobEfeT, deCobCCT, 0, 0,
	                   deLiqlun, deLiqMar, deLiqMier, deLiqJue, deLiqVie,
	                    0, deTotComision, deTotIvaCom, dFechaIni,dfecha_Hoy, deLiqResguardo, (SELECT NVL(MAX(consecutivo_convenio + 1 ),1)
						                                                            FROM bdisac:"informix".sac_liquidacionsemanal
																					WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
	    END IF;

        IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
            LET dFechaAux = dPriDiaMes;
            LET deComision =0;
            LET deIvaCom =0;
            LET cAnioMes = to_char(dfecha_Hoy,"%Y%m");

            WHILE dFechaAux <= dfecha_Hoy

                          SELECT COUNT(folio_suc), NVL(SUM(importe_comision_convenio),0), NVL(SUM(iva_comision_convenio),0)
                          INTO iNumOpe, deComision, deIvaCom
                          FROM bdisac:"informix".sac_movimientoshistorial
                           WHERE numcategoria = cCategoria
                           AND numconvenio = cConvenio
                           AND fecha_pago  = dFechaAux
                           AND status_cancelado = 'N';

                          INSERT INTO bdisac:"informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
                          VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, deComision, deIvaCom, CURRENT);

                          LET dFechaAux = dFechaAux + 1;
            END WHILE;

        END IF;

	    IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
		    LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;

	    UPDATE bdisac:"informix".sac_controlreportesespeciales
	    SET retorno = cCodret
	    WHERE numcategoria = cCategoria
	    AND numconvenio = cConvenio;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : Dulce Ramirez',
'DESCRIPCION: Genera la informacion para los Reportes Semanal y Mensual de Pagos ECI',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de sp_ProcesoCierreSAC()',
'FECHA : 12 de Septiembre de 2011',
'VERSION: 20110912.1650',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidacionavon(pId_Convenio CHAR(5))

--Definicion de Variables
	DEFINE cCodret           CHAR(5);
	DEFINE cCodRet2          CHAR(5);
	DEFINE cAnioMes          CHAR(6);
	DEFINE cInfoErr          CHAR(100);
	DEFINE cCategoria        CHAR(2);
	DEFINE cConvenio         CHAR(3);
	DEFINE cFechaLiq         CHAR(10);
	DEFINE iSqlErr           INTEGER;
	DEFINE iIsamErr          INTEGER;
	DEFINE iRecEfe           INTEGER;
	DEFINE iRecCC            INTEGER;
	DEFINE iRecMix           INTEGER;
	DEFINE iRecEfeT          INTEGER;
	DEFINE iRecCCT           INTEGER;
	DEFINE iRecMixT          INTEGER;
	DEFINE iRecTot           INTEGER;
	DEFINE iRecAux           INTEGER;
	DEFINE iRecLun           INTEGER;
	DEFINE iRecMAr           INTEGER;
	DEFINE iRecMie           INTEGER;
	DEFINE iRecJue           INTEGER;
	DEFINE iRecVie           INTEGER;
	DEFINE iRecSab           INTEGER;
	DEFINE iRecDom           INTEGER;
	DEFINE iNumOpe           INTEGER;
	DEFINE iDias             INTEGER;
	DEFINE mLiqlun           MONEY(16,2);
	DEFINE mLiqMar           MONEY(16,2);
	DEFINE mLiqMier          MONEY(16,2);
	DEFINE mLiqJue           MONEY(16,2);
	DEFINE mLiqVie           MONEY(16,2);
	DEFINE mLiqResguardo     MONEY(16,2);
	DEFINE mCobEfe           MONEY(16,2);
	DEFINE mCobMix           MONEY(16,2);
	DEFINE mCobCC            MONEY(16,2);
	DEFINE mCobEfeT          MONEY(16,2);
	DEFINE mCobMixT          MONEY(16,2);
	DEFINE mCobCCT           MONEY(16,2);
	DEFINE mCobTot           MONEY(16,2);
	DEFINE mCobAux           MONEY(16,2);
	DEFINE mCobLun           MONEY(16,2);
	DEFINE mCobMar           MONEY(16,2);
	DEFINE mCobMie           MONEY(16,2);
	DEFINE mCobJue           MONEY(16,2);
	DEFINE mCobVie           MONEY(16,2);
	DEFINE mCobSab           MONEY(16,2);
	DEFINE mCobDom           MONEY(16,2);
	DEFINE mTotComision      MONEY(16,2);
	DEFINE mTotIvaCom        MONEY(16,2);
	DEFINE mComision         MONEY(16,2);
	DEFINE mIvaCom           MONEY(16,2);  
	DEFINE mAcumulado        MONEY(16,2);
	DEFINE dFechaAux         DATE;
	DEFINE dfecha_Hoy        DATE;
	DEFINE dFechaIni         DATE;
	DEFINE dPriDiaMes        DATE;
	DEFINE dUltDiaMes        DATE;




--Inicializacion de Variables   
	LET cCodRet2       = "00000";
	LET cCodret        = "00000";
	LET cInfoErr       = '';
	LET cAnioMes       = '';
	LET mCobEfe        = 0;
	LET mCobCC         = 0;
	LET mCobMix        = 0;
	LET iRecEfe        = 0;
	LET iRecCC         = 0;
	LET iRecMix        = 0;
	LET mComision      = 0;
	LET mIvaCom        = 0;
	LET mCobEfeT       = 0;
	LET mCobCCT        = 0;
	LET iRecEfeT       = 0;
	LET iRecCCT        = 0;
	LET mTotComision   = 0;                      
	LET mTotIvaCom     = 0;              
	LET iRecLun        = 0;            
	LET mCobLun        = 0;            
	LET iRecMar        = 0;            
	LET mCobMar        = 0;            
	LET iRecMie        = 0;            
	LET mCobMie        = 0;            
	LET iRecJue        = 0;            
	LET mCobJue        = 0;            
	LET iRecVie        = 0;            
	LET mCobVie        = 0;            
	LET iRecSab        = 0;            
	LET mCobSab        = 0;            
	LET iRecDom        = 0;            
	LET mCobDom        = 0;            
	LET cCategoria     = SUBSTRING(pId_Convenio FROM 1 FOR 2);
	LET cConvenio      = SUBSTRING(pId_Convenio FROM 3 FOR 3);
	LET dFechaAux      = '';
	LET dfecha_Hoy     = '';
	LET dFechaIni      = '';
	LET dPriDiaMes	   = '';
	LET dUltDiaMes	   = '';
	LET iNumOpe	       = 0;
	LET mLiqlun        = 0;
	LET mLiqMar        = 0;
	LET mLiqMier       = 0;
	LET mLiqJue        = 0;
	LET mLiqVie        = 0;
	LET cFechaLiq      = "";
	LET mLiqResguardo  = 0;
	LET mAcumulado     = 0; 
	
   --SET DEBUG FILE TO "/tmp/sp_reporteliquidacionavon.out";
   --TRACE ON;
   
   BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;

                    UPDATE sac_controlreportesespeciales
                    SET retorno = cCodRet
                    WHERE numcategoria = cCategoria
                    AND numconvenio = cConvenio;

                    EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacionavon");
                END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;

        SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
        INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
        FROM bdisac:"informix".sac_fechas;

        IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

            LET dFechaAux = dfecha_Hoy - 6;
            LET dFechaIni = dFechaAux;
			
			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM bdisac:"informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
			                            FROM bdisac:"informix".sac_liquidacionsemanal 
			                            WHERE id_convenio = cCategoria||cConvenio
										AND consecutivo_convenio <> 0);
				
				
			IF 	mAcumulado IS NULL THEN
			    LET mAcumulado = 0;
			END IF;
			
            WHILE dFechaAux <= dfecha_Hoy
                SELECT NVL(SUM(efe),0), NVL(SUM(cc),0), NVL(SUM(mix),0), COUNT(Rec1), COUNT(Rec2), COUNT(Rec3), NVL(SUM(comision), 0), NVL(SUM(iva_com),0)
                INTO mCobEfe, mCobCC, mCobMix, iRecEfe, iRecCC, iRecMix, mComision, mIvaCom
                FROM TABLE(
                    MULTISET(
                        SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
                                CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
                                CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
                                CASE WHEN forma_pago = 3 THEN NVL(importe_pago, 0) END AS mix,
                                CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
                                CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
                                CASE WHEN forma_pago = 3 THEN folio_suc END AS Rec3
                        FROM bdisac:"informix".sac_movimientoshistorial
                        WHERE numcategoria = cCategoria
                        AND numconvenio = cConvenio
                        AND fecha_pago  = dFechaAux
                        AND status_cancelado = 'N'));

                LET mCobEfeT = mCobEfeT + mCobEfe + mCobMix;
                LET mCobCCT = mCobCCT + mCobCC;

                LET iRecEfeT = iRecEfeT + iRecEfe + iRecMix;
                LET iRecCCT = iRecCCT + iRecCC;

                LET mTotComision = mTotComision + mComision;
                LET mTotIvaCom = mTotIvaCom + mIvaCom;

								
				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;
					
				IF CAST(cCodRet2 AS INTEGER) = 0 THEN
						
					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

	                IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
	                    LET iRecLun = iRecEfe + iRecCC + iRecMix;
	                    LET mCobLun = mCobEfe + mCobCC + mCobMix;
							
						IF iDias = 1 THEN 
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET mLiqMier = mLiqMier + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 3 THEN 
							LET mLiqJue = mLiqJue + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
							    LET mAcumulado = 0;
							END IF;
						ELIF iDias = 4 THEN
							LET mLiqVie = mLiqVie + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
							    LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 5 AND iDias <= 7 THEN
							LET mLiqlun =  mLiqlun + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;	
							
	                    
	                IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
	                    LET iRecMar = iRecEfe + iRecCC + iRecMix;
	                    LET mCobMar = mCobEfe + mCobCC + mCobMix;
						
					    IF iDias = 1 THEN 
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET mLiqJue = mLiqJue + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 3 THEN 
							LET mLiqVie = mLiqVie + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 4 AND iDias <= 6 THEN 
							LET mLiqlun =  mLiqlun + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;	
	                END IF;
	                
					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
	                    LET iRecMie = iRecEfe + iRecCC + iRecMix;
	                    LET mCobMie = mCobEfe + mCobCC + mCobMix;
							
						IF iDias = 1 THEN 
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET mLiqVie = mLiqVie + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 3 AND iDias <= 5 THEN 
							LET mLiqlun =  mLiqlun + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;	
	                END IF;
					
					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC + iRecMix;
						LET mCobJue = mCobEfe + mCobCC + mCobMix;
						
						IF iDias = 1 THEN 
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 2 AND iDias <= 4 THEN
							LET mLiqlun =  mLiqlun + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;	
					END IF;
					
					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC + iRecMix;
						LET mCobVie = mCobEfe + mCobCC + mCobMix;
						
						IF iDias >= 1 AND iDias <= 3 THEN 
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;
					
					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC + iRecMix;
						LET mCobSab = mCobEfe + mCobCC + mCobMix;
						
						IF iDias >= 1  AND iDias <= 2 THEN 
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;
	                    
					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC + iRecMix;
						LET mCobDom = mCobEfe + mCobCC + mCobMix;
						
						IF iDias = 1 THEN 
							LET mLiqlun =  mLiqlun + mCobDom;
							
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;
					
	                LET dFechaAux = dFechaAux + 1;
                
				END IF;
	        END WHILE;
			
			IF CAST(cCodRet2 AS INTEGER) = 0 THEN

	            INSERT INTO bdisac:"informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo,
																	  cob_lunes, cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo,
																	  rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred,
																	  cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred,
																	  liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,
																	  aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
	            VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom,
	                   mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,
	                   iRecEfeT, iRecCCT, 0, 0, 
					   mCobEfeT, mCobCCT, 0, 0,
	                   mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,
	                   0, mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo, (SELECT NVL(MAX(consecutivo_convenio + 1 ),1)
																						  FROM bdisac:"informix".sac_liquidacionsemanal
																						  WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
	    END IF;
        
        IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
            LET dFechaAux = dPriDiaMes;
            LET mComision = 0;
            LET mIvaCom = 0;
            LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

            WHILE dFechaAux <= dfecha_Hoy

				SELECT COUNT(folio_suc), NVL(SUM(importe_comision_convenio),0), NVL(SUM(iva_comision_convenio),0) 
				INTO iNumOpe, mComision, mIvaCom
				FROM bdisac:"informix".sac_movimientoshistorial
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago  = dFechaAux
				AND status_cancelado = 'N';

				INSERT INTO bdisac:"informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;                         
            END WHILE;
		
        END IF;
       
	    IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
		    LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;
		
	    UPDATE bdisac:"informix".sac_controlreportesespeciales
	    SET retorno = cCodret
	    WHERE numcategoria = cCategoria
	    AND numconvenio = cConvenio;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : Martín Eduardo Miranda',
'DESCRIPCIÓN: Genera la información para los Reportes Semanal y Mensual de Pagos AVON',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de sp_ProcesoCierreSAC()',
'FECHA : 05 Julio 2012',
'VERSIÓN: 20120705.1020',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidaciondyclass(pId_Convenio CHAR(5))

--Definición de Variables
	DEFINE cCodret           CHAR(5);
	DEFINE cCodRet2          CHAR(5);
	DEFINE cAnioMes          CHAR(6);
	DEFINE cInfoErr          CHAR(100);
	DEFINE cCategoria        CHAR(2);
	DEFINE cConvenio         CHAR(3);
	DEFINE cFechaLiq         CHAR(10);
	DEFINE iSqlErr           INTEGER;
	DEFINE iIsamErr          INTEGER;
	DEFINE iRecEfe           INTEGER;
	DEFINE iRecCC            INTEGER;
	DEFINE iRecMix           INTEGER;
	DEFINE iRecEfeT          INTEGER;
	DEFINE iRecCCT           INTEGER;
	DEFINE iRecMixT          INTEGER;
	DEFINE iRecTot           INTEGER;
	DEFINE iRecAux           INTEGER;
	DEFINE iRecLun           INTEGER;
	DEFINE iRecMAr           INTEGER;
	DEFINE iRecMie           INTEGER;
	DEFINE iRecJue           INTEGER;
	DEFINE iRecVie           INTEGER;
	DEFINE iRecSab           INTEGER;
	DEFINE iRecDom           INTEGER;
	DEFINE iNumOpe           INTEGER;
	DEFINE iDias             INTEGER;
	DEFINE mLiqlun           MONEY(16,2);
	DEFINE mLiqMar           MONEY(16,2);
	DEFINE mLiqMier          MONEY(16,2);
	DEFINE mLiqJue           MONEY(16,2);
	DEFINE mLiqVie           MONEY(16,2);
	DEFINE mLiqResguardo     MONEY(16,2);
	DEFINE mCobEfe           MONEY(16,2);
	DEFINE mCobMix           MONEY(16,2);
	DEFINE mCobCC            MONEY(16,2);
	DEFINE mCobEfeT          MONEY(16,2);
	DEFINE mCobMixT          MONEY(16,2);
	DEFINE mCobCCT           MONEY(16,2);
	DEFINE mCobTot           MONEY(16,2);
	DEFINE mCobAux           MONEY(16,2);
	DEFINE mCobLun           MONEY(16,2);
	DEFINE mCobMar           MONEY(16,2);
	DEFINE mCobMie           MONEY(16,2);
	DEFINE mCobJue           MONEY(16,2);
	DEFINE mCobVie           MONEY(16,2);
	DEFINE mCobSab           MONEY(16,2);
	DEFINE mCobDom           MONEY(16,2);
	DEFINE mTotComision      MONEY(16,2);
	DEFINE mTotIvaCom        MONEY(16,2);
	DEFINE mComision         MONEY(16,2);
	DEFINE mIvaCom           MONEY(16,2);  
	DEFINE mAcumulado        MONEY(16,2);
	DEFINE dFechaAux         DATE;
	DEFINE dfecha_Hoy        DATE;
	DEFINE dFechaIni         DATE;
	DEFINE dPriDiaMes        DATE;
	DEFINE dUltDiaMes        DATE;

--Inicialización de Variables   
	LET cCodret        = "00000";
	LET cCodRet2       = "00000";
	LET cInfoErr       = '';
	LET cAnioMes       = '';
	LET mCobEfe        = 0;
	LET mCobCC         = 0;
	LET mCobMix        = 0;
	LET iRecEfe        = 0;
	LET iRecCC         = 0;
	LET iRecMix        = 0;
	LET mComision      = 0;
	LET mIvaCom        = 0;
	LET mCobEfeT       = 0;
	LET mCobCCT        = 0;
	LET iRecEfeT       = 0;
	LET iRecCCT        = 0;
	LET mTotComision   = 0;                      
	LET mTotIvaCom     = 0;              
	LET iRecLun        = 0;            
	LET mCobLun        = 0;            
	LET iRecMar        = 0;            
	LET mCobMar        = 0;            
	LET iRecMie        = 0;            
	LET mCobMie        = 0;            
	LET iRecJue        = 0;            
	LET mCobJue        = 0;            
	LET iRecVie        = 0;            
	LET mCobVie        = 0;            
	LET iRecSab        = 0;            
	LET mCobSab        = 0;            
	LET iRecDom        = 0;            
	LET mCobDom        = 0;            
	LET cCategoria     = SUBSTRING(pId_Convenio FROM 1 FOR 2);
	LET cConvenio      = SUBSTRING(pId_Convenio FROM 3 FOR 3);
	LET dFechaAux      = '';
	LET dfecha_Hoy     = '';
	LET dFechaIni      = '';
	LET dPriDiaMes	   = '';
	LET dUltDiaMes	   = '';
	LET iNumOpe	       = 0;
	LET mLiqlun        = 0;
	LET mLiqMar        = 0;
	LET mLiqMier       = 0;
	LET mLiqJue        = 0;
	LET mLiqVie        = 0;
	LET cFechaLiq      = "";
	LET mLiqResguardo  = 0;
	LET mAcumulado     = 0; 
	
   --SET DEBUG FILE TO "/tmp/sp_reporteliquidaciondyclass.out";
   --TRACE ON;
   
   BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;

                    UPDATE sac_controlreportesespeciales
                    SET retorno = cCodRet
                    WHERE numcategoria = cCategoria
                    AND numconvenio = cConvenio;

                    EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidaciondyclass");
                END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;

        SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
        INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
        FROM bdisac:"informix".sac_fechas;

        IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

            LET dFechaAux = dfecha_Hoy - 6;
            LET dFechaIni = dFechaAux;
			
			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM bdisac:"informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
			                            FROM bdisac:"informix".sac_liquidacionsemanal 
			                            WHERE id_convenio = cCategoria||cConvenio
										AND consecutivo_convenio <> 0);
				
			IF 	mAcumulado IS NULL THEN
			    LET mAcumulado = 0;
			END IF;
			
            WHILE dFechaAux <= dfecha_Hoy
                SELECT NVL(SUM(efe),0), NVL(SUM(cc),0), NVL(SUM(mix),0), COUNT(Rec1), COUNT(Rec2), COUNT(Rec3), NVL(SUM(comision), 0), NVL(SUM(iva_com),0)
                INTO mCobEfe, mCobCC, mCobMix, iRecEfe, iRecCC, iRecMix, mComision, mIvaCom
                FROM TABLE(
                    MULTISET(
                        SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
                               CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
                               CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
                               CASE WHEN forma_pago = 3 THEN NVL(importe_pago, 0) END AS mix,
                               CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
                               CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
                               CASE WHEN forma_pago = 3 THEN folio_suc END AS Rec3
                        FROM bdisac:"informix".sac_movimientoshistorial
                        WHERE numcategoria = cCategoria
                        AND numconvenio = cConvenio
                        AND fecha_pago  = dFechaAux
                        AND status_cancelado = 'N'));

                LET mCobEfeT = mCobEfeT + mCobEfe + mCobMix;
                LET mCobCCT = mCobCCT + mCobCC;

                LET iRecEfeT = iRecEfeT + iRecEfe + iRecMix;
                LET iRecCCT = iRecCCT + iRecCC;

                LET mTotComision = mTotComision + mComision;
                LET mTotIvaCom = mTotIvaCom + mIvaCom;

								
				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;
					
				IF CAST(cCodRet2 AS INTEGER) = 0 THEN
						
					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

	                IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
	                    LET iRecLun = iRecEfe + iRecCC + iRecMix;
	                    LET mCobLun = mCobEfe + mCobCC + mCobMix;
							
						IF iDias = 1 THEN 
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET mLiqMier = mLiqMier + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 3 THEN 
							LET mLiqJue = mLiqJue + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
							    LET mAcumulado = 0;
							END IF;
						ELIF iDias = 4 THEN
							LET mLiqVie = mLiqVie + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
							    LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 5 AND iDias <= 7 THEN
							LET mLiqlun =  mLiqlun + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;	

	                IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
	                    LET iRecMar = iRecEfe + iRecCC + iRecMix;
	                    LET mCobMar = mCobEfe + mCobCC + mCobMix;
						
					    IF iDias = 1 THEN 
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET mLiqJue = mLiqJue + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 3 THEN 
							LET mLiqVie = mLiqVie + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 4 AND iDias <= 6 THEN 
							LET mLiqlun =  mLiqlun + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;	
	                END IF;
	                
					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
	                    LET iRecMie = iRecEfe + iRecCC + iRecMix;
	                    LET mCobMie = mCobEfe + mCobCC + mCobMix;
							
						IF iDias = 1 THEN 
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET mLiqVie = mLiqVie + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 3 AND iDias <= 5 THEN 
							LET mLiqlun =  mLiqlun + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
	                END IF;
					
					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC + iRecMix;
						LET mCobJue = mCobEfe + mCobCC + mCobMix;
						
						IF iDias = 1 THEN 
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 2 AND iDias <= 4 THEN
							LET mLiqlun =  mLiqlun + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;
					
					IF TO_CHAR(dFechaAux,"%A") = "Friday" THEN
						LET iRecVie = iRecEfe + iRecCC + iRecMix;
						LET mCobVie = mCobEfe + mCobCC + mCobMix;
						
						IF iDias >= 1 AND iDias <= 3 THEN 
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;
					
					IF TO_CHAR(dFechaAux,"%A") = "Saturday" THEN
						LET iRecSab = iRecEfe + iRecCC + iRecMix;
						LET mCobSab = mCobEfe + mCobCC + mCobMix;
						
						IF iDias >= 1  AND iDias <= 2 THEN 
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;
	                    
					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC + iRecMix;
						LET mCobDom = mCobEfe + mCobCC + mCobMix;
						
						IF iDias = 1 THEN 
							LET mLiqlun =  mLiqlun + mCobDom;
							
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;
	                LET dFechaAux = dFechaAux + 1;
				END IF;
				
	        END WHILE;
			
			IF CAST(cCodRet2 AS INTEGER) = 0 THEN

	            INSERT INTO bdisac:"informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo,
																	  cob_lunes, cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo,
																	  rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred,
																	  cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred,
																	  liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,
																	  aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
	            VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom,
	                   mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,
	                   iRecEfeT, iRecCCT, 0, 0, 
					   mCobEfeT, mCobCCT, 0, 0,
	                   mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,
	                   0, mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo, (SELECT NVL(MAX(consecutivo_convenio + 1 ),1)
						                                                                  FROM bdisac:"informix".sac_liquidacionsemanal
																					      WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
	    END IF;
        
        IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
            LET dFechaAux = dPriDiaMes;
            LET mComision = 0;
            LET mIvaCom = 0;
            LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

            WHILE dFechaAux <= dfecha_Hoy

				SELECT COUNT(folio_suc), NVL(SUM(importe_comision_convenio),0), NVL(SUM(iva_comision_convenio),0) 
				INTO iNumOpe, mComision, mIvaCom
				FROM bdisac:"informix".sac_movimientoshistorial
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago  = dFechaAux
				AND status_cancelado = 'N';

				INSERT INTO bdisac:"informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;                         
            END WHILE;
			
        END IF;
       
	    IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
		    LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;
		
	    UPDATE bdisac:"informix".sac_controlreportesespeciales
	    SET retorno = cCodret
	    WHERE numcategoria = cCategoria
	    AND numconvenio = cConvenio;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : Martín Eduardo Miranda',
'DESCRIPCIÓN: Genera la información para los Reportes Semanal y Mensual de Pagos DYCLASS',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de sp_ProcesoCierreSAC()',
'FECHA : 05 Julio 2012',
'VERSIÓN: 20120705.1414',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_generaarchivocobranzaeci_pba(cId_Convenio CHAR(5))
   -- DEFINICION DE VARIABLES
   
    DEFINE cCodRet                  CHAR (5);
	DEFINE cCodRet2                 CHAR (5);
    DEFINE iSqlErr                  INTEGER;
    DEFINE cDia                     CHAR (2);
	DEFINE cMes                     CHAR (2);
	DEFINE cAnio                    CHAR (2);
	DEFINE cDiaPag                  CHAR (2);
	DEFINE cMesPag                  CHAR (2);
    DEFINE cAnioPag                 CHAR (4);
    DEFINE cCategoria               CHAR (2);
    DEFINE cConvenio                CHAR (3);
    DEFINE cReferencia1             CHAR (20);
    DEFINE cSucursal                CHAR (4);
    DEFINE cRutaArchEci             CHAR (100);
    DEFINE cStmt                    CHAR (250);
    DEFINE dFechaIni                DATE;
    DEFINE dFecha_Hoy               DATE;
    DEFINE dFechaEntrega            DATE;
    DEFINE cFechaEntrega            CHAR (8);
    DEFINE iImporte_Pago            INTEGER;
    DEFINE cDisponible              CHAR (1);
	DEFINE cFolio                   CHAR (16);
    DEFINE cFlagCen                 INTEGER;
    DEFINE cFlagSuc                 INTEGER;
	DEFINE iCuantos                 INTEGER;
     DEFINE dFecha_Pago               DATE;
  

    --INICIALIZACION DE VARIABLES--
    LET cCodRet       = "00000";
	LET cCodRet2      = "00000";
    LET iSqlErr       = 0;
    LET cCategoria    = SUBSTRING(cId_Convenio FROM 1 FOR 2);
    LET cConvenio     = SUBSTRING(cId_Convenio FROM 3 FOR 3);
    LET cReferencia1  = '';
    LET cDia          = '';
    LET cMes          = '';
    LET cAnio         = '';
	LET cDiaPag       = '';
	LET cMesPag       = '';
	LET cAnioPag      = '';
    LET cDisponible   = '';
    LET cFolio        = '';                 
    LET cFlagCen      = 0;                 
    LET cFlagSuc      = 0;      
	LET cSucursal     = '';
	LET cRutaArchEci  = '';
	LET cStmt         = '';
	LET dFechaIni     = '01-01-1990';
	LET dFecha_Hoy    = '01-01-1990';
	LET dFechaEntrega = '01-01-1990';
	LET cFechaEntrega = '';
	LET iImporte_Pago = 0;
	LET	iCuantos      = 0;
	
    --SET DEBUG FILE TO "/resplogifx/sp_generaarchivocobranzaeci.out";
   -- TRACE ON;

    BEGIN

        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
               
				UPDATE bdisac:"informix".sac_controlarchivoscobranza
                SET retorno = cCodRet
                WHERE numcategoria = cCategoria
                AND   numconvenio = cConvenio;
            END IF;
        END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		
        SELECT fecha_hoy 
		INTO dFecha_Hoy 
		FROM bdisac:"informix".sac_fechas
		WHERE empresa = "001";

        
		SELECT fecha_ultimo_archivo
        INTO dFechaIni
        FROM bdisac:"informix".sac_controlarchivoscobranza
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

        LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
        LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = LPAD(SUBSTRING(YEAR(dFecha_Hoy ::DATE) FROM 3 FOR 2), 2, '0'); 
				
		
		SELECT TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza)
		INTO cRutaArchEci
		FROM bdisac:"informix".sac_convenios
		WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;
     	
		LET cRutaArchEci = REPLACE(cRutaArchEci,'AA',cAnio);
		LET cRutaArchEci = REPLACE(cRutaArchEci,'MM',cMes);
		LET cRutaArchEci = REPLACE(cRutaArchEci,'DD',cDia);
		
        	 
		EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFecha_Hoy) 
		INTO cCodRet2,dFechaEntrega;
		
		IF CAST(cCodRet2 AS INTEGER) = 0 THEN
		
     		LET cFechaEntrega  = SUBSTRING(dFechaEntrega FROM 7 FOR 4) || SUBSTRING(dFechaEntrega FROM 1 FOR 2)
			                    || SUBSTRING(dFechaEntrega FROM 4 FOR 2);
		
		    
			SET ISOLATION TO DIRTY READ;
			
	        FOREACH
	            
				SELECT referencia1, importe_pago * 100, LPAD(id_sucursal,4,'0'), 
				    LPAD(DAY(fecha_pago::DATE), 2, '0'), LPAD(MONTH(fecha_pago::DATE), 2, '0'),	LPAD(YEAR(fecha_pago::DATE), 4, '0'),  
				    flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago
		        INTO  cReferencia1,  iImporte_Pago, cSucursal, cDiaPag, cMesPag, cAnioPag,  cFlagCen, cFlagSuc, cFolio, dFecha_Pago
	            FROM bdisac:"informix".sac_movimientoshistorial
	            WHERE numcategoria = cCategoria
	            AND numconvenio = cConvenio
	            AND fecha_pago > dFechaIni
	            AND fecha_pago <= dFecha_Hoy
	            AND status_cancelado <> 'S'
	            AND (flag_confirmacion_central = 1
	            OR flag_confirmacion_sucursal = 1)
		
            IF cFlagCen = 0 or cFlagSuc =0 THEN
              SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
              IF iCuantos = 0 THEN
                 SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND fech_alt = dFecha_Pago;   
                 IF iCuantos = 0 THEN
                    CONTINUE FOREACH;
                 END IF;
              END IF;
              IF iCuantos > 0 THEN            
                UPDATE bdisac:sac_movimientoshistorial SET flag_confirmacion_sucursal='1'
                    WHERE numcategoria = cCategoria
                    AND numconvenio = cConvenio
                    AND fecha_pago = dFecha_Pago
					AND folio_suc = cFolio
					AND referencia1 = cReferencia1
                    AND status_cancelado <> 'S'
                    AND flag_confirmacion_sucursal = 0;             
              END IF;
            END IF;
			
	            LET cStmt = 'echo "'|| LPAD(TRIM(cDisponible), 4, ' ')|| LPAD(TRIM(cReferencia1), 10, '0') || LPAD(TRIM(cDisponible), 5, ' ')|| 
				                       LPAD(iImporte_Pago, 9, '0') || LPAD(TRIM(cDisponible), 1, ' ')|| cAnioPag || cMesPag || cDiaPag ||   
							           LPAD(TRIM(cDisponible), 1, ' ') || LPAD(TRIM(cSucursal), 4, '0') ||  LPAD(TRIM(cDisponible), 1, ' ') || 
									   cFechaEntrega ||  LPAD(TRIM(cDisponible), 1, ' ') || SUBSTRING(cFolio FROM 7 FOR 10) || '" >> ' || cRutaArchEci;
	            SYSTEM cStmt;
			END FOREACH;
		
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
	            LET cStmt = 'echo "' || "0"  || '" >> ' || cRutaArchEci;
	            SYSTEM cStmt;                 
	        END IF;  
		
	        UPDATE bdisac:"informix".sac_controlarchivoscobranza
	        SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
	        WHERE numcategoria = cCategoria
	        AND numconvenio = cConvenio;
		ELSE
		    LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
			UPDATE bdisac:"informix".sac_controlarchivoscobranza
			SET retorno = cCodRet
			WHERE numcategoria = cCategoria
			AND  numconvenio = cConvenio;
		END IF;
		
		
    END;
END PROCEDURE
DOCUMENT
'AUTOR : Dulce Ramirez',
'DESCRIPCION: Genera el archivo de cobranza ECI de acuerdo al Layout',
'EJECUTADO O LLAMADO POR:sp_genera_ArchivosCobranzaCentral()',
'FECHA : 07 de Septiembre de 2011',
'VERSION: 20110907';

CREATE PROCEDURE "informix".sp_generaarchivocobranzadyclass_pba(pConvenio CHAR(5))
   -- DEFINICION DE VARIABLES
    DEFINE cCodRet                  CHAR(5);
    DEFINE iSqlErr                  INTEGER;
    DEFINE cDia                     CHAR(2);
	DEFINE cMes                     CHAR(2);
	DEFINE cAnio                    CHAR(2);
    DEFINE cDiaPago                 CHAR(2);
	DEFINE cMesPago                 CHAR(2);
    DEFINE cAnioPago                CHAR(4);
    DEFINE cCategoria               CHAR(2);
    DEFINE cConvenio                CHAR(3);                                              
    DEFINE cReferencia1             CHAR(20);
    DEFINE cRutaArchAvon            CHAR(100);
    DEFINE cStmt                    CHAR(250);
    DEFINE cFolio                   CHAR(16);
	DEFINE cTpoOperacion            CHAR(1);
    DEFINE dFechaIni                DATE;
    DEFINE dFecha_Hoy               DATE;
    DEFINE iImporte_Comision        INTEGER;
    DEFINE iSumaImporte_Comision    INTEGER;	
	DEFINE iImporte_IVA_Comision    INTEGER;
	DEFINE iSumaImporte_IVA_Comision INTEGER;		
	DEFINE iImporte_Pago            INTEGER;
	DEFINE iTotal_Pago              INTEGER;
    DEFINE iFlagCen                 INTEGER;
    DEFINE iFlagSuc                 INTEGER;
	DEFINE iCuantos                 INTEGER;
	DEFINE iNumPagos                INTEGER;
    DEFINE iTransac                 INTEGER;
	DEFINE iMonto_tot               INTEGER;
    DEFINE cValor					CHAR(100);
	DEFINE cCuenta_Prestadora       CHAR(20);
	DEFINE mMonto_tot               MONEY(12,2);
    DEFINE dFecha_Pago               DATE;

    --INICIALIZACION DE VARIABLES--
    LET cCodRet       		  = "00000";
    LET iSqlErr       		  = 0;
    LET cCategoria    		  = SUBSTRING(pConvenio FROM 1 FOR 2);
    LET cConvenio     		  = SUBSTRING(pConvenio FROM 3 FOR 3);
    LET cReferencia1  		  = '';
    LET cDia          		  = '';
    LET cMes          		  = '';
    LET cAnio         		  = '';
	LET cDiaPago       		  = '';
	LET cMesPago       		  = '';
    LET cAnioPago      		  = '';
    LET iImporte_Pago 		  = 0;
	LET iImporte_Comision 	  = 0;
	LET iSumaImporte_Comision = 0;
	LET iImporte_IVA_Comision = 0;
	LET iSumaImporte_IVA_Comision = 0;	
	LET iTotal_Pago  		  = 0;
    LET cFolio        		  = '';                 
    LET iFlagCen      		  = 0;                 
    LET iFlagSuc      		  = 0; 
	LET cRutaArchAvon  		  = '';
	LET	iCuantos      		  = 0;
	LET cStmt         		  = '';
	LET dFechaIni     		  = DATE(1);
	LET dFecha_Hoy    		  = DATE(1);
	LET cTpoOperacion         = 'D';  
	LET iNumPagos             = 0;
	LET iTransac		      = 0;
	LET cValor				  = '';
	LET cCuenta_Prestadora    = '';
	LET mMonto_tot            = 0;
	LET iMonto_tot            = 0;
	
	--SET DEBUG FILE TO '/respaldosbd/Dulce/sp_generaarchivocobranzadyclass.out';
	--TRACE ON;

    BEGIN

        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;

				UPDATE bdisac:"informix".sac_controlarchivoscobranza
                SET retorno = cCodRet
                WHERE numcategoria = cCategoria
                AND   numconvenio = cConvenio;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;

        SELECT fecha_hoy 
		INTO dFecha_Hoy 
		FROM bdisac:"informix".sac_fechas
		WHERE empresa = "001";

        
		SELECT fecha_ultimo_archivo
        INTO dFechaIni
        FROM bdisac:"informix".sac_controlarchivoscobranza
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

        LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
        LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = LPAD(SUBSTRING(YEAR(dFecha_Hoy ::DATE) FROM 3 FOR 2), 2, '0'); 
				
		
		SELECT TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza),cuenta_prestadora
		INTO cRutaArchAvon,cCuenta_Prestadora
		FROM bdisac:"informix".sac_convenios
		WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;
     	
		LET cRutaArchAvon = REPLACE(cRutaArchAvon,'AA',cAnio);
		LET cRutaArchAvon = REPLACE(cRutaArchAvon,'MM',cMes);
		LET cRutaArchAvon = REPLACE(cRutaArchAvon,'DD',cDia);

		-- Consulta de la Transacción del Servicio
		LET iTransac = 6017; -- OJO************ CAMBIAR
		SELECT valor 
		  INTO cValor
		  FROM bdisac:"informix".sac_param 
		 WHERE empresa = '001'
		   AND cod_param  = iTransac;

		--Consulta del IDE
		SELECT NVL(monto_tot,0)
		  INTO mMonto_tot
		  FROM bdicheq:"informix".sc_movhis
		 WHERE empresa = '001'
		   AND fech_alt = dFecha_Hoy
		   AND transacc =  cValor
		   AND cuenta = cCuenta_Prestadora;
		   
		IF mMonto_tot IS NULL THEN
			LET mMonto_tot = 0;
		END IF;
		
		LET iMonto_tot = mMonto_tot;
		LET iMonto_tot = iMonto_tot * 100;
		
        SET ISOLATION TO DIRTY READ;
        FOREACH
            
            SELECT LPAD(DAY(fecha_pago::DATE), 2, '0'), 
			       LPAD(MONTH(fecha_pago::DATE), 2, '0'),	
				   LPAD(YEAR(fecha_pago::DATE), 4, '0'),
				   referencia1, 
				   importe_pago * 100,       
				   importe_comision_convenio * 100,
                   iva_comision_convenio * 100,
			       flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago
	        INTO  cDiaPago,cMesPago,cAnioPago,cReferencia1, iImporte_Pago,iImporte_Comision,iImporte_IVA_Comision,iFlagCen,iFlagSuc,cFolio, dFecha_Pago
            FROM bdisac:"informix".sac_movimientoshistorial
            WHERE numcategoria = cCategoria
            AND numconvenio = cConvenio
            AND fecha_pago > dFechaIni
            AND fecha_pago <= dFecha_Hoy
            AND status_cancelado <> 'S'
            AND (flag_confirmacion_central = 1
	        OR flag_confirmacion_sucursal = 1)

            IF iFlagCen = 0 or iFlagSuc =0 THEN
              SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
              IF iCuantos = 0 THEN
                 SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND fech_alt = dFecha_Pago;   
                 IF iCuantos = 0 THEN
                    CONTINUE FOREACH;
                 END IF;
              END IF;
              IF iCuantos > 0 THEN            
                UPDATE bdisac:sac_movimientoshistorial SET flag_confirmacion_sucursal='1'
                    WHERE numcategoria = cCategoria
                    AND numconvenio = cConvenio
                    AND fecha_pago = dFecha_Pago
					AND folio_suc = cFolio
					AND referencia1 = cReferencia1
                    AND status_cancelado <> 'S'
                    AND flag_confirmacion_sucursal = 0;             
              END IF;
            END IF;	
			
			LET iSumaImporte_Comision = iSumaImporte_Comision + iImporte_Comision;
			LET iSumaImporte_IVA_Comision = iSumaImporte_IVA_Comision + iImporte_IVA_Comision;			
			LET iTotal_Pago = iTotal_Pago + iImporte_Pago ;
			LET iNumPagos = iNumPagos + 1;
			
            LET cStmt = 'echo "' || cTpoOperacion || cDiaPago || cMesPago || cAnioPago || LPAD(TRIM(cReferencia1), 7, '0') || LPAD(TRIM(cReferencia1), 9, '0') || LPAD(iImporte_Pago, 10, '0') || LPAD(cFolio, 16, '0') || '" >> ' || cRutaArchAvon;
            SYSTEM cStmt;
        END FOREACH;
        
	   
		LET cReferencia1 = '';
		LET cFolio       = '';
		
		IF iSumaImporte_Comision <> 0 THEN
			LET cTpoOperacion = 'C';  
			LET cStmt = 'echo "' || cTpoOperacion || cDiaPago || cMesPago || cAnioPago || LPAD(TRIM(cReferencia1), 7, '0') || LPAD(TRIM(cReferencia1), 9, '0') || LPAD(iSumaImporte_Comision, 10, '0') || LPAD(TRIM(cFolio), 16, '0') || '" >> ' || cRutaArchAvon;
            SYSTEM cStmt;
		END IF;
		
		IF iSumaImporte_IVA_Comision <> 0 THEN
		    LET cTpoOperacion = 'I';  
			LET cStmt = 'echo "' || cTpoOperacion || cDiaPago || cMesPago || cAnioPago || LPAD(TRIM(cReferencia1), 7, '0') || LPAD(TRIM(cReferencia1), 9, '0') || LPAD(iSumaImporte_IVA_Comision, 10, '0') || LPAD(TRIM(cFolio), 16, '0') || '" >> ' || cRutaArchAvon;
            SYSTEM cStmt;
		END IF;
		
		IF mMonto_tot <> 0 THEN
			LET cTpoOperacion = 'E';  
			LET cStmt = 'echo "' || cTpoOperacion || cDiaPago || cMesPago || cAnioPago || LPAD(TRIM(cReferencia1), 7, '0') || LPAD(TRIM(cReferencia1), 9, '0') || LPAD(iSumaImporte_IVA_Comision, 10, '0') || LPAD(TRIM(cFolio), 16, '0') || '" >> ' || cRutaArchAvon;
			SYSTEM cStmt;
		END IF;
		
		IF iNumPagos <> 0 THEN
			LET cTpoOperacion = 'T';		
			LET iTotal_Pago = ((iTotal_Pago - iSumaImporte_Comision) - iSumaImporte_IVA_Comision) - iMonto_tot;
			
			LET cStmt = 'echo "' || cTpoOperacion || cDiaPago || cMesPago || cAnioPago || LPAD(TRIM(cReferencia1), 7, '0') || LPAD(TRIM(TO_CHAR(iNumPagos)), 9, '0') || LPAD(iTotal_Pago, 10, '0') || LPAD(TRIM(cFolio), 16, '0') || '" >> ' || cRutaArchAvon;
			SYSTEM cStmt;
		END IF;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
		    LET cTpoOperacion = 'T'; 
			LET cStmt = 'echo "' || cTpoOperacion || LPAD(TRIM(cDiaPago),2,'0') || LPAD(TRIM(cMesPago),2,'0') || LPAD(TRIM(cAnioPago),2,'0') || LPAD(TRIM(cReferencia1), 7, '0') || LPAD(TRIM(cReferencia1), 9, '0') || LPAD(iTotal_Pago, 10, '0') || LPAD(TRIM(cFolio), 16, '0') || '" >> ' || cRutaArchAvon;
            SYSTEM cStmt;                 
        END IF;  

		UPDATE bdisac:"informix".sac_controlarchivoscobranza
        SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : Martín Eduardo Miranda',
'DESCRIPCION: Genera el archivo de cobranza Dyclass de acuerdo al Layout',
'EJECUTADO O LLAMADO POR:sp_genera_ArchivosCobranzaCentral()',
'BD: BDISAC',
'FECHA : 06 Julio 2012',
'VERSION: 20120706';

CREATE PROCEDURE "informix".sp_generaarchivocobranzadish_pba(cId_Convenio CHAR(5))
   -- DEFINICION DE VARIABLES
    DEFINE cCodRet                  CHAR(5);
    DEFINE iSqlErr                  INTEGER;

    DEFINE cCveRegistro             CHAR;
    DEFINE cMes, cDia               CHAR(2);
    DEFINE cMesPag, cDiaPag         CHAR(2);
    DEFINE cAnioPag                 CHAR(4);
    DEFINE cCategoria               CHAR(2);
    DEFINE cConvenio                CHAR(3);
    DEFINE cAnio                    CHAR(4);
    ------------------------------------------------------------------------------------
    --	2010-12-28: A petición de MVS, se atualiza el Nombreempresa de DSH a BANCOPPEL -
    --	DEFINE cCveEmpresa              CHAR(3);                                       -
    DEFINE cCveEmpresa              CHAR(9);                                           
    ------------------------------------------------------------------------------------
    DEFINE cReferencia1             CHAR(20);
    DEFINE cSucursal                CHAR(5);
    DEFINE cRutaArchdish            CHAR(100);
    DEFINE cStmt                    CHAR(250);
    DEFINE dFechaIni                DATE;
    DEFINE dFecha_Hoy               DATE;
    DEFINE dFecha_Pago               DATE;
	
    DEFINE iImporte_Pago            INTEGER;
    DEFINE iTotalreg                INTEGER;
    DEFINE iImporteTotal            INTEGER;
    DEFINE iIdTransacc              INTEGER;
    DEFINE mImporteTotal            MONEY(16,2);
	
    DEFINE cFormaPago               CHAR(2);
    DEFINE cHorMinSec               DATETIME  HOUR TO FRACTION;
    DEFINE cConstante               INTEGER;
		
    DEFINE cFolio                   CHAR(16);
    DEFINE cFlagCen                 INTEGER;
    DEFINE cFlagSuc                 INTEGER;
    DEFINE iCuantos                 INTEGER;

    --INICIALIZACION DE VARIABLES--
    LET cCodRet = "00000";
    LET iSqlErr = 0;
    LET cCveEmpresa = '';
    LET cCveRegistro = 'H';
    LET cCategoria  = SUBSTRING(cId_Convenio FROM 1 FOR 2);
    LET cConvenio  = SUBSTRING(cId_Convenio FROM 3 FOR 3);
    LET cReferencia1 = '';
    LET cDia = '';
    LET cMes = '';
    LET cAnio = '';
    LET iImporte_Pago = 0;
    LET iTotalReg = 0;
    LET iImporteTotal = 0;
    LET iIdTransacc = 0;
    LET mImporteTotal = 0;
    LET cConstante = '0';
    LET cFolio = '';                 
    LET cFlagCen = 0;                 
    LET cFlagSuc = 0;      
    LET iCuantos = 0;        
	
    --	SET DEBUG FILE TO "/ids10_uc9/tmp/mvs/sp_generaarchivocobranzadish.out";
    --	TRACE ON;

    BEGIN

        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;

                UPDATE {+INDEX (bdisac:sac_controlarchivoscobranza 104_10)} sac_controlarchivoscobranza
                SET retorno = cCodRet
                WHERE numcategoria = cCategoria
                AND   numconvenio = cConvenio;
            END IF;
        END EXCEPTION;

        SELECT fecha_hoy INTO dFecha_Hoy FROM bdisac:sac_fechas;

        SELECT {+INDEX (bdisac:sac_controlarchivoscobranza 104_10)} fecha_ultimo_archivo
        INTO dFechaIni
        FROM bdisac:sac_controlarchivoscobranza
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

        LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
        LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = LPAD(YEAR(dFecha_Hoy::DATE), 4, '0');
				
		SELECT {+INDEX (bdisac:sac_convenios 103_4)} TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza)
		INTO cRutaArchdish
		FROM bdisac:sac_convenios
		WHERE TRIM(numcategoria)|| TRIM(numconvenio) = cId_Convenio;
 
        SELECT {+INDEX (bdisac:sac_param idxsc_par)} TRIM(valor)
		INTO cCveEmpresa
		FROM bdisac:sac_param 
		WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '1' 
		AND SUBSTRING (cod_param FROM 2 FOR 5)  = cId_Convenio;
		
		LET cRutaArchdish = REPLACE(cRutaArchdish,'YYYY',cAnio);
		LET cRutaArchdish = REPLACE(cRutaArchdish,'MM',cMEs);
		LET cRutaArchdish = REPLACE(cRutaArchdish,'DD',cDia);

		--Encabezado  
        LET cStmt = 'echo "' || cCveRegistro || cDia || cMes || cAnio || cCveEmpresa ||'" > ' || cRutaArchdish;
        SYSTEM cStmt;

        LET cCveRegistro = '0';
        LET cStmt = '';

        --Detalle
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT {+INDEX (bdisac:sac_movimientoshistorial idxsac_movhisfe)} referencia1, importe_pago * 100, LPAD(DAY(fecha_pago::DATE), 2, '0'), LPAD(MONTH(fecha_pago::DATE), 2, '0'),	LPAD(YEAR(fecha_pago::DATE), 4, '0'),  
			  NVL(LPAD(id_sucursal,5,'0'),'00000'), forma_pago , fecha_insert::datetime HOUR TO SECOND,
             flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago
	       INTO   cReferencia1,  iImporte_Pago, cDiaPag, cMesPag, cAnioPag,  cSucursal, cFormaPago, cHorMinSec, cFlagCen, cFlagSuc, cFolio, dFecha_Pago
            FROM bdisac:sac_movimientoshistorial
            WHERE numcategoria = cCategoria
            AND numconvenio = cConvenio
            AND fecha_pago > dFechaIni
            AND fecha_pago <= dFecha_Hoy
            AND status_cancelado <> 'S'
            AND (flag_confirmacion_central = 1
            OR flag_confirmacion_sucursal = 1)
 
            IF TRIM(cFormaPago) = '1' THEN
                LET cFormaPago = 'EF';
			ELIF TRIM(cFormaPago) = '2' THEN	
			    LET cFormaPago = 'CA';
            ELIF TRIM(cFormaPago) = '3' THEN	
			    LET cFormaPago = 'MX';
            END IF;

            IF cFlagCen = 0 or cFlagSuc =0 THEN
              SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
              IF iCuantos = 0 THEN
                 SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND fech_alt = dFecha_Pago;   
                 IF iCuantos = 0 THEN
                    CONTINUE FOREACH;
                 END IF;
              END IF;
              IF iCuantos > 0 THEN            
                UPDATE bdisac:sac_movimientoshistorial SET flag_confirmacion_sucursal='1'
                    WHERE numcategoria = cCategoria
                    AND numconvenio = cConvenio
                    AND fecha_pago = dFecha_Pago
					AND folio_suc = cFolio
					AND referencia1 = cReferencia1
                    AND status_cancelado <> 'S'
                    AND flag_confirmacion_sucursal = 0;             
              END IF;
            END IF;
			
            LET iTotalReg = iTotalReg + 1;
            LET mImporteTotal = mImporteTotal + iImporte_Pago / 100;

            LET cStmt = 'echo "' || cCveRegistro || cConstante || LPAD(trim(cReferencia1), 13, ' ') || LPAD(iImporte_Pago, 6, '0') || cDiaPag || cMesPag || cAnioPag ||  
						 cSucursal || SUBSTRING(cHorMinSec  FROM 1 FOR 2) || SUBSTRING(cHorMinSec  FROM 4 FOR 2) || SUBSTRING(cHorMinSec  FROM 7 FOR 2) || cFormaPago  || '" >> ' || cRutaArchdish;
            SYSTEM cStmt;
        END FOREACH;

        LET iImporteTotal = mImporteTotal * 100;

        -- Sumario
        LET cCveRegistro = 'T';
        LET cStmt = '';

        LET cStmt = 'echo "' || cCveRegistro || cDia || cMes || cAnio || LPAD(iTotalReg, 6, '0') || LPAD(iImporteTotal, 11, '0') || '" >> ' || cRutaArchdish;
        SYSTEM cStmt;

        UPDATE {+INDEX (bdisac:sac_controlarchivoscobranza 104_10)} sac_controlarchivoscobranza
        SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : Dulce Ramirez',
'DESCRIPCION: Genera el archivo de cobranza dish de acuerdo al Layout',
'EJECUTADO O LLAMADO POR:sp_genera_ArchivosCobranzaCentral()',
'FECHA : 06 de Septiembre de 2010',
'VERSION: 20100906';

CREATE PROCEDURE "informix".sp_reporteliquidaciongdf(pId_Convenio CHAR(5))

--Definicion de Variables
	DEFINE cCodret           CHAR(5);
	DEFINE cAnioMes          CHAR(6);
	DEFINE cInfoErr          CHAR(100);
	DEFINE cCategoria        CHAR(2);
	DEFINE cConvenio         CHAR(3);
	DEFINE iSqlErr           INTEGER;
	DEFINE iIsamErr          INTEGER;
	DEFINE iRecEfe           INTEGER;
	DEFINE iRecCC            INTEGER;
	DEFINE iRecMix           INTEGER;
	DEFINE iRecCrd           INTEGER;
	DEFINE iRecEfeT          INTEGER;
	DEFINE iRecCCT           INTEGER;
	DEFINE iRecMixT          INTEGER;
	DEFINE iRecTot           INTEGER;
	DEFINE iRecAux           INTEGER;
	DEFINE iRecLun           INTEGER;
	DEFINE iRecMAr           INTEGER;
	DEFINE iRecMie           INTEGER;
	DEFINE iRecJue           INTEGER;
	DEFINE iRecVie           INTEGER;
	DEFINE iRecSab           INTEGER;
	DEFINE iRecDom           INTEGER;
	DEFINE iNumOpe           INTEGER;
	DEFINE mLiqlun           MONEY(16,2);
	DEFINE mLiqMar           MONEY(16,2);
	DEFINE mLiqMier          MONEY(16,2);
	DEFINE mLiqJue           MONEY(16,2);
	DEFINE mLiqVie           MONEY(16,2);
	DEFINE mLiqSab           MONEY(16,2);
	DEFINE mLiqDom           MONEY(16,2);
	DEFINE mCobEfe           MONEY(16,2);
	DEFINE mCobMix           MONEY(16,2);
	DEFINE mCobCrd           MONEY(16,2);
	DEFINE mCobCC            MONEY(16,2);
	DEFINE mCobEfeT          MONEY(16,2);
	DEFINE mCobCCT           MONEY(16,2);
	DEFINE mCobLun           MONEY(16,2);
	DEFINE mCobMar           MONEY(16,2);
	DEFINE mCobMie           MONEY(16,2);
	DEFINE mCobJue           MONEY(16,2);
	DEFINE mCobVie           MONEY(16,2);
	DEFINE mCobSab           MONEY(16,2);
	DEFINE mCobDom           MONEY(16,2);
	DEFINE mTotComision      MONEY(16,2);
	DEFINE mTotIvaCom        MONEY(16,2);
	DEFINE mComision         MONEY(16,2);
	DEFINE mIvaCom           MONEY(16,2);  
	DEFINE dFechaAux         DATE;
	DEFINE dfecha_Hoy        DATE;
	DEFINE dFechaIni         DATE;
	DEFINE dPriDiaMes        DATE;
	DEFINE dUltDiaMes        DATE;

--Inicializacion de Variables   
	LET cCodret        = "00000";
	LET cInfoErr       = '';
	LET cAnioMes       = '';
	LET mCobEfe        = 0;
	LET mCobCC         = 0;
	LET mCobMix        = 0;
	LET mCobCrd        = 0;
	LET iRecEfe        = 0;
	LET iRecCC         = 0;
	LET iRecMix        = 0;
	LET iRecCrd        = 0;
	LET mComision      = 0;
	LET mIvaCom        = 0;
	LET mCobEfeT       = 0;
	LET mCobCCT        = 0;
	LET iRecEfeT       = 0;
	LET iRecCCT        = 0;
	LET mTotComision   = 0;                      
	LET mTotIvaCom     = 0;              
	LET iRecLun        = 0;            
	LET mCobLun        = 0;            
	LET iRecMar        = 0;            
	LET mCobMar        = 0;            
	LET iRecMie        = 0;            
	LET mCobMie        = 0;            
	LET iRecJue        = 0;            
	LET mCobJue        = 0;            
	LET iRecVie        = 0;            
	LET mCobVie        = 0;            
	LET iRecSab        = 0;            
	LET mCobSab        = 0;            
	LET iRecDom        = 0;            
	LET mCobDom        = 0;            
	LET cCategoria     = SUBSTRING(pId_Convenio FROM 1 FOR 2);
	LET cConvenio      = SUBSTRING(pId_Convenio FROM 3 FOR 3);
	LET dFechaAux      = '';
	LET dfecha_Hoy     = '';
	LET dFechaIni      = '';
	LET dPriDiaMes	   = '';
	LET dUltDiaMes	   = '';
	LET iNumOpe	       = 0;
	LET mLiqlun        = 0;
	LET mLiqMar        = 0;
	LET mLiqMier       = 0;
	LET mLiqJue        = 0;
	LET mLiqVie        = 0;
	LET mLiqSab        = 0;
	LET mLiqDom        = 0;
	
   --SET DEBUG FILE TO "/tmp/sp_reporteliquidaciongdf.out";
   --TRACE ON;
   
   BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;

                    UPDATE sac_controlreportesespeciales
                    SET retorno = cCodRet
                    WHERE numcategoria = cCategoria
                    AND numconvenio = cConvenio;

                    EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidaciongdf");
                END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;

        SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
        INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
        FROM bdisac:"informix".sac_fechas;

        IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

            LET dFechaAux = dfecha_Hoy - 6;
            LET dFechaIni = dFechaAux;
			
			WHILE dFechaAux <= dfecha_Hoy
                SELECT NVL(SUM(efe),0), NVL(SUM(cc),0), NVL(SUM(mix),0), NVL(SUM(crd),0),COUNT(Rec1), COUNT(Rec2), COUNT(Rec3), COUNT(Rec5),NVL(SUM(comision), 0), NVL(SUM(iva_com),0)
                INTO mCobEfe, mCobCC, mCobMix,mCobCrd, iRecEfe, iRecCC, iRecMix,iRecCrd, mComision, mIvaCom
                FROM TABLE(
                    MULTISET(
                        SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
                                CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
                                CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
                                CASE WHEN forma_pago = 3 THEN NVL(importe_pago, 0) END AS mix,
								CASE WHEN forma_pago = 5 THEN NVL(importe_pago, 0) END AS crd,
                                CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
                                CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
                                CASE WHEN forma_pago = 3 THEN folio_suc END AS Rec3,
								CASE WHEN forma_pago = 5 THEN folio_suc END AS Rec5
                        FROM bdisac:"informix".sac_movimientoshistorial
                        WHERE numcategoria = cCategoria
                        AND numconvenio = cConvenio
                        AND fecha_pago  = dFechaAux
                        AND status_cancelado = 'N'));

                LET mCobEfeT = mCobEfeT + mCobEfe + mCobMix + mCobCrd;
                LET mCobCCT = mCobCCT + mCobCC;

                LET iRecEfeT = iRecEfeT + iRecEfe + iRecMix + iRecCrd;
                LET iRecCCT = iRecCCT + iRecCC;

                LET mTotComision = mTotComision + mComision;
                LET mTotIvaCom = mTotIvaCom + mIvaCom;

				
				IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
					LET iRecLun = iRecEfe + iRecCC + iRecMix + iRecCrd;
					LET mCobLun = mCobEfe + mCobCC + mCobMix + mCobCrd;
					LET mLiqMar = mCobLun;
						
				END IF;	
   
				IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
					LET iRecMar = iRecEfe + iRecCC + iRecMix + iRecCrd;
					LET mCobMar = mCobEfe + mCobCC + mCobMix + mCobCrd;
					LET mLiqMier = mCobMar;
				END IF;
				
				IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
					LET iRecMie = iRecEfe + iRecCC + iRecMix + iRecCrd;
					LET mCobMie = mCobEfe + mCobCC + mCobMix + mCobCrd;
					LET mLiqJue = mCobMie;
				END IF;
					
				IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
					LET iRecJue = iRecEfe + iRecCC + iRecMix + iRecCrd;
					LET mCobJue = mCobEfe + mCobCC + mCobMix + mCobCrd;
					LET mLiqVie = mCobJue;
				END IF;
					
				IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
					LET iRecVie = iRecEfe + iRecCC + iRecMix + iRecCrd;
					LET mCobVie = mCobEfe + mCobCC + mCobMix + mCobCrd;
					LET mLiqSab = mCobVie;
				END IF;
					
				IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
					LET iRecSab = iRecEfe + iRecCC + iRecMix + iRecCrd;
					LET mCobSab = mCobEfe + mCobCC + mCobMix + mCobCrd;
					LET mLiqDom = mCobSab;
				END IF;
					
				IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
					LET iRecDom = iRecEfe + iRecCC + iRecMix + iRecCrd;
					LET mCobDom = mCobEfe + mCobCC + mCobMix + mCobCrd;
					LET mLiqlun = mCobDom;
				END IF;
					
				LET dFechaAux = dFechaAux + 1;
				
	        END WHILE;
			
	            INSERT INTO bdisac:"informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo,
																	  cob_lunes, cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo,
																	  rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred,
																	  cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred,
																	  liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,liq_sabado,liq_domingo,
																	  aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
	            VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom,
	                   mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,
	                   iRecEfeT, iRecCCT, 0, 0, 
					   mCobEfeT, mCobCCT, 0, 0,
	                   mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,mLiqSab,mLiqDom,
	                   0, mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, 0 , (SELECT NVL(MAX(consecutivo_convenio + 1 ),1)
																						  FROM bdisac:"informix".sac_liquidacionsemanal
																						  WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
	    END IF;
        
        IF dfecha_Hoy = dUltDiaMes THEN
            LET dFechaAux = dPriDiaMes;
            LET mComision = 0;
            LET mIvaCom = 0;
            LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

            WHILE dFechaAux <= dfecha_Hoy

				SELECT COUNT(folio_suc), NVL(SUM(importe_comision_convenio),0), NVL(SUM(iva_comision_convenio),0) 
				INTO iNumOpe, mComision, mIvaCom
				FROM bdisac:"informix".sac_movimientoshistorial
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago  = dFechaAux
				AND status_cancelado = 'N';

				INSERT INTO bdisac:"informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;                         
            END WHILE;
		
        END IF;
       	
	    UPDATE bdisac:"informix".sac_controlreportesespeciales
	    SET retorno = cCodret
	    WHERE numcategoria = cCategoria
	    AND numconvenio = cConvenio;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : Martín Eduardo Miranda',
'DESCRIPCIÓN: Genera la información para los Reportes Semanal y Mensual de Impuestos del Gobierno del DF',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de sp_ProcesoCierreSAC()',
'FECHA : 27 diciembre 2012',
'VERSIÓN: 20121227.0908',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidacioncam(pId_Convenio CHAR(5) )

--Definicion de Variables
	DEFINE cCodret           CHAR(5);
	DEFINE cCodRet2          CHAR(5);
	DEFINE cAnioMes          CHAR(6);
	DEFINE cInfoErr          CHAR(100);
	DEFINE cCategoria        CHAR(2);
	DEFINE cConvenio         CHAR(3);
	DEFINE cFechaLiq         CHAR(10);
	DEFINE iSqlErr           INTEGER;
	DEFINE iIsamErr          INTEGER;
	DEFINE iRecEfe           INTEGER;
	DEFINE iRecCC            INTEGER;
	DEFINE iRecMix           INTEGER;
	DEFINE iRecEfeT          INTEGER;
	DEFINE iRecCCT           INTEGER;
	DEFINE iRecMixT          INTEGER;
	DEFINE iRecTot           INTEGER;
	DEFINE iRecAux           INTEGER;
	DEFINE iRecLun           INTEGER;
	DEFINE iRecMAr           INTEGER;
	DEFINE iRecMie           INTEGER;
	DEFINE iRecJue           INTEGER;
	DEFINE iRecVie           INTEGER;
	DEFINE iRecSab           INTEGER;
	DEFINE iRecDom           INTEGER;
	DEFINE iNumOpe           INTEGER;
	DEFINE iDias             INTEGER;
	DEFINE mLiqlun           MONEY(16,2);
	DEFINE mLiqMar           MONEY(16,2);
	DEFINE mLiqMier          MONEY(16,2);
	DEFINE mLiqJue           MONEY(16,2);
	DEFINE mLiqVie           MONEY(16,2);
	DEFINE mLiqResguardo     MONEY(16,2);
	DEFINE mCobEfe           MONEY(16,2);
	DEFINE mCobMix           MONEY(16,2);
	DEFINE mCobCC            MONEY(16,2);
	DEFINE mCobEfeT          MONEY(16,2);
	DEFINE mCobMixT          MONEY(16,2);
	DEFINE mCobCCT           MONEY(16,2);
	DEFINE mCobTot           MONEY(16,2);
	DEFINE mCobAux           MONEY(16,2);
	DEFINE mCobLun           MONEY(16,2);
	DEFINE mCobMar           MONEY(16,2);
	DEFINE mCobMie           MONEY(16,2);
	DEFINE mCobJue           MONEY(16,2);
	DEFINE mCobVie           MONEY(16,2);
	DEFINE mCobSab           MONEY(16,2);
	DEFINE mCobDom           MONEY(16,2);
	DEFINE mTotComision      MONEY(16,2);
	DEFINE mTotIvaCom        MONEY(16,2);
	DEFINE mComision         MONEY(16,2);
	DEFINE mIvaCom           MONEY(16,2);
	DEFINE mAcumulado        MONEY(16,2);
	DEFINE dFechaAux         DATE;
	DEFINE dfecha_Hoy        DATE;
	DEFINE dFechaIni         DATE;
	DEFINE dPriDiaMes        DATE;
	DEFINE dUltDiaMes        DATE;




--Inicializacion de Variables
	LET cCodRet2       = "00000";
	LET cCodret        = "00000";
	LET cInfoErr       = '';
	LET cAnioMes       = '';
	LET mCobEfe        = 0;
	LET mCobCC         = 0;
	LET mCobMix        = 0;
	LET iRecEfe        = 0;
	LET iRecCC         = 0;
	LET iRecMix        = 0;
	LET mComision      = 0;
	LET mIvaCom        = 0;
	LET mCobEfeT       = 0;
	LET mCobCCT        = 0;
	LET iRecEfeT       = 0;
	LET iRecCCT        = 0;
	LET mTotComision   = 0;
	LET mTotIvaCom     = 0;
	LET iRecLun        = 0;
	LET mCobLun        = 0;
	LET iRecMar        = 0;
	LET mCobMar        = 0;
	LET iRecMie        = 0;
	LET mCobMie        = 0;
	LET iRecJue        = 0;
	LET mCobJue        = 0;
	LET iRecVie        = 0;
	LET mCobVie        = 0;
	LET iRecSab        = 0;
	LET mCobSab        = 0;
	LET iRecDom        = 0;
	LET mCobDom        = 0;
	LET cCategoria     = SUBSTRING(pId_Convenio FROM 1 FOR 2);
	LET cConvenio      = SUBSTRING(pId_Convenio FROM 3 FOR 3);
	LET dFechaAux      = '';
	LET dfecha_Hoy     = '';
	LET dFechaIni      = '';
	LET dPriDiaMes	   = '';
	LET dUltDiaMes	   = '';
	LET iNumOpe	       = 0;
	LET mLiqlun        = 0;
	LET mLiqMar        = 0;
	LET mLiqMier       = 0;
	LET mLiqJue        = 0;
	LET mLiqVie        = 0;
	LET cFechaLiq      = "";
	LET mLiqResguardo  = 0;
	LET mAcumulado     = 0;

   --SET DEBUG FILE TO "/respaldosbd/eduardo/sp_reporteliquidacioncam.out";
   --TRACE ON;

   BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;

                    UPDATE bdisac:"informix".sac_controlreportesespeciales
                    SET retorno = cCodRet
                    WHERE numcategoria = cCategoria
                    AND numconvenio = cConvenio;

                    EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacioncam");
                END IF;
        END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
			
        SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
        INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
        FROM bdisac:"informix".sac_fechas;

        IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

            LET dFechaAux = dfecha_Hoy - 6;
            LET dFechaIni = dFechaAux;

			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM bdisac:"informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
			                            FROM bdisac:"informix".sac_liquidacionsemanal
			                            WHERE id_convenio = cCategoria||cConvenio
										AND consecutivo_convenio <> 0);


			IF 	mAcumulado IS NULL THEN
			    LET mAcumulado = 0;
			END IF;

            WHILE dFechaAux <= dfecha_Hoy
				SELECT NVL(SUM(efe),0), NVL(SUM(cc),0), COUNT(Rec1), COUNT(Rec2), NVL(SUM(comision), 0), NVL(SUM(iva_com),0)
                INTO mCobEfe, mCobCC, iRecEfe, iRecCC, mComision, mIvaCom
                FROM TABLE(
                    MULTISET(
                        SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
                                CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
                                CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
                                CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
                                CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2
                        FROM bdisac:"informix".sac_movimientoshistorial
                        WHERE numcategoria = cCategoria
                        AND numconvenio = cConvenio
                        AND fecha_pago  = dFechaAux
                        AND status_cancelado = 'N'));

				LET mCobEfeT = mCobEfeT + mCobEfe; 
                LET mCobCCT = mCobCCT + mCobCC;
				
                LET iRecEfeT = iRecEfeT + iRecEfe ;
                LET iRecCCT = iRecCCT + iRecCC;

                LET mTotComision = mTotComision + mComision;
                LET mTotIvaCom = mTotIvaCom + mIvaCom;


				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

	                IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
						 LET iRecLun = iRecEfe + iRecCC ;
						LET mCobLun = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET mLiqMier = mLiqMier + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 3 THEN
							LET mLiqJue = mLiqJue + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
							    LET mAcumulado = 0;
							END IF;
						ELIF iDias = 4 THEN
							LET mLiqVie = mLiqVie + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
							    LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 5 AND iDias <= 7 THEN
							LET mLiqlun =  mLiqlun + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;


	                IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
						LET iRecMar = iRecEfe + iRecCC ;
						LET mCobMar = mCobEfe + mCobCC ;

					    IF iDias = 1 THEN
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET mLiqJue = mLiqJue + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 3 THEN
							LET mLiqVie = mLiqVie + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 4 AND iDias <= 6 THEN
							LET mLiqlun =  mLiqlun + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
	                END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
						LET iRecMie = iRecEfe + iRecCC ;
						LET mCobMie = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET mLiqVie = mLiqVie + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 3 AND iDias <= 5 THEN
							LET mLiqlun =  mLiqlun + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
	                END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC ;
						LET mCobJue = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 2 AND iDias <= 4 THEN
							LET mLiqlun =  mLiqlun + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC ;
						LET mCobVie = mCobEfe + mCobCC ;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC ;
						LET mCobSab = mCobEfe + mCobCC ;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC ;
						LET mCobDom = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqlun =  mLiqlun + mCobDom;

							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

	                LET dFechaAux = dFechaAux + 1;

				END IF;
	        END WHILE;

			IF CAST(cCodRet2 AS INTEGER) = 0 THEN

	            INSERT INTO bdisac:"informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo,
																	  cob_lunes, cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo,
																	  rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred,
																	  cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred,
																	  liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,
																	  aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
	            VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom,
	                   mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,
	                   iRecEfeT, iRecCCT, 0, 0,
					   mCobEfeT, mCobCCT, 0, 0,
	                   mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,
	                   0, mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo, (SELECT NVL(MAX(consecutivo_convenio + 1 ),1)
																						  FROM bdisac:"informix".sac_liquidacionsemanal
																						  WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
	    END IF;

        IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
            LET dFechaAux = dPriDiaMes;
            LET mComision = 0;
            LET mIvaCom = 0;
            LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

            WHILE dFechaAux <= dfecha_Hoy

				SELECT COUNT(folio_suc), NVL(SUM(importe_comision_convenio),0), NVL(SUM(iva_comision_convenio),0)
				INTO iNumOpe, mComision, mIvaCom
				FROM bdisac:"informix".sac_movimientoshistorial
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago  = dFechaAux
				AND status_cancelado = 'N';

				INSERT INTO bdisac:"informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;
            END WHILE;

        END IF;

	    IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
		    LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;

	    UPDATE bdisac:"informix".sac_controlreportesespeciales
	    SET retorno = cCodret
	    WHERE numcategoria = cCategoria
	    AND numconvenio = cConvenio;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : Eduardo López Cuevas',
'DESCRIPCIÓN: Genera la información para los Reportes Semanal y Mensual de Pagos referenciados (CAMINEMOS)',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de sp_ProcesoCierreSAC()',
'FECHA : 23 Mayo 2013',
'VERSIÓN: 20130523.1046',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidacionsuk(pId_Convenio CHAR(5) )

--Definicion de Variables
	DEFINE cCodret           CHAR(5);
	DEFINE cCodRet2          CHAR(5);
	DEFINE cAnioMes          CHAR(6);
	DEFINE cInfoErr          CHAR(100);
	DEFINE cCategoria        CHAR(2);
	DEFINE cConvenio         CHAR(3);
	DEFINE cFechaLiq         CHAR(10);
	DEFINE iSqlErr           INTEGER;
	DEFINE iIsamErr          INTEGER;
	DEFINE iRecEfe           INTEGER;
	DEFINE iRecEfeAux        CHAR(16);
	DEFINE iRecCC            INTEGER;
	DEFINE iRecCCAux         CHAR(16);
	DEFINE iRecMix           INTEGER;
	DEFINE iRecEfeT          INTEGER;
	DEFINE iRecCCT           INTEGER;
	DEFINE iRecMixT          INTEGER;
	DEFINE iRecTot           INTEGER;
	DEFINE iRecAux           INTEGER;
	DEFINE iRecLun           INTEGER;
	DEFINE iRecMAr           INTEGER;
	DEFINE iRecMie           INTEGER;
	DEFINE iRecJue           INTEGER;
	DEFINE iRecVie           INTEGER;
	DEFINE iRecSab           INTEGER;
	DEFINE iRecDom           INTEGER;
	DEFINE iNumOpe           INTEGER;
	DEFINE iDias             INTEGER;
	DEFINE mLiqlun           MONEY(16,2);
	DEFINE mLiqMar           MONEY(16,2);
	DEFINE mLiqMier          MONEY(16,2);
	DEFINE mLiqJue           MONEY(16,2);
	DEFINE mLiqVie           MONEY(16,2);
	DEFINE mLiqResguardo     MONEY(16,2);
	DEFINE mCobEfe           MONEY(16,2);
	DEFINE mCobEfeAux        MONEY(16,2);
	DEFINE mCobMix           MONEY(16,2);
	DEFINE mCobCC            MONEY(16,2);
	DEFINE mCobCCAux         MONEY(16,2);
	DEFINE mCobEfeT          MONEY(16,2);
	DEFINE mCobMixT          MONEY(16,2);
	DEFINE mCobCCT           MONEY(16,2);
	DEFINE mCobTot           MONEY(16,2);
	DEFINE mCobAux           MONEY(16,2);
	DEFINE mCobLun           MONEY(16,2);
	DEFINE mCobMar           MONEY(16,2);
	DEFINE mCobMie           MONEY(16,2);
	DEFINE mCobJue           MONEY(16,2);
	DEFINE mCobVie           MONEY(16,2);
	DEFINE mCobSab           MONEY(16,2);
	DEFINE mCobDom           MONEY(16,2);
	DEFINE mTotComision      MONEY(16,2);
	DEFINE mTotIvaCom        MONEY(16,2);
	DEFINE mComision         MONEY(16,2);
	DEFINE mComisionAux      MONEY(16,2);
	DEFINE mIvaCom           MONEY(16,2);
	DEFINE mIvaComAux        MONEY(16,2);
	DEFINE mAcumulado        MONEY(16,2);
	DEFINE dFechaAux         DATE;
	DEFINE dfecha_Hoy        DATE;
	DEFINE dFechaIni         DATE;
	DEFINE dPriDiaMes        DATE;
	DEFINE dUltDiaMes        DATE;
	DEFINE iFlagCen          INTEGER;
	DEFINE iFlagSuc          INTEGER;
	DEFINE cFolio            CHAR(16);
	DEFINE iCuantos          INTEGER;




--Inicializacion de Variables
	LET cCodRet2       = "00000";
	LET cCodret        = "00000";
	LET cInfoErr       = '';
	LET cAnioMes       = '';
	LET mCobEfe        = 0;
	LET mCobEfeAux     = 0;
	LET mCobCC         = 0;
	LET mCobCCAux      = 0;
	LET mCobMix        = 0;
	LET iRecEfe        = 0;
	LET iRecEfeAux     = '';
	LET iRecCC         = 0;
	LET iRecCCAux      = '';
	LET iRecMix        = 0;
	LET mComision      = 0;
	LET mComisionAux   = 0;
	LET mIvaCom        = 0;
	LET mIvaComAux     = 0;
	LET mCobEfeT       = 0;
	LET mCobCCT        = 0;
	LET iRecEfeT       = 0;
	LET iRecCCT        = 0;
	LET mTotComision   = 0;
	LET mTotIvaCom     = 0;
	LET iRecLun        = 0;
	LET mCobLun        = 0;
	LET iRecMar        = 0;
	LET mCobMar        = 0;
	LET iRecMie        = 0;
	LET mCobMie        = 0;
	LET iRecJue        = 0;
	LET mCobJue        = 0;
	LET iRecVie        = 0;
	LET mCobVie        = 0;
	LET iRecSab        = 0;
	LET mCobSab        = 0;
	LET iRecDom        = 0;
	LET mCobDom        = 0;
	LET cCategoria     = SUBSTRING(pId_Convenio FROM 1 FOR 2);
	LET cConvenio      = SUBSTRING(pId_Convenio FROM 3 FOR 3);
	LET dFechaAux      = '';
	LET dfecha_Hoy     = '';
	LET dFechaIni      = '';
	LET dPriDiaMes	   = '';
	LET dUltDiaMes	   = '';
	LET iNumOpe	       = 0;
	LET mLiqlun        = 0;
	LET mLiqMar        = 0;
	LET mLiqMier       = 0;
	LET mLiqJue        = 0;
	LET mLiqVie        = 0;
	LET cFechaLiq      = "";
	LET mLiqResguardo  = 0;
	LET mAcumulado     = 0;
	LET iFlagCen       = 0; 
	LET iFlagSuc       = 0;
	LET cFolio         = '';
	LET iCuantos	   = 0;

   --SET DEBUG FILE TO "/informix/tmp/sp_reporteliquidacionsuk.out";
   --TRACE ON;

   BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;

                    UPDATE bdisac:"informix".sac_controlreportesespeciales
                    SET retorno = cCodRet
                    WHERE numcategoria = cCategoria
                    AND numconvenio = cConvenio;

                    EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacionsuk");
                END IF;
        END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
			
        SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
        INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
        FROM bdisac:"informix".sac_fechas;

        IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

            LET dFechaAux = dfecha_Hoy - 6;
            LET dFechaIni = dFechaAux;

			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM bdisac:"informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
			                            FROM bdisac:"informix".sac_liquidacionsemanal
			                            WHERE id_convenio = cCategoria||cConvenio
										AND consecutivo_convenio <> 0);


			IF 	mAcumulado IS NULL THEN
			    LET mAcumulado = 0;
			END IF;

            WHILE dFechaAux <= dfecha_Hoy
				
				LET mCobEfe = 0.00;
				LET mCobCC = 0.00;
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iRecEfe = 0;
				LET iRecCC = 0;
				
				FOREACH
					SELECT 
							NVL(efe,0), 
							NVL(cc,0), 
							NVL(Rec1,''),
							NVL(Rec2,""), 
							NVL(comision, 0), 
							NVL(iva_com,0),
							flag_confirmacion_central, 
							flag_confirmacion_sucursal, 
							folio_suc
					INTO 
							mCobEfeAux, 
							mCobCCAux, 
							iRecEfeAux, 
							iRecCCAux, 
							mComisionAux, 
							mIvaComAux,
							iFlagCen,
							iFlagSuc,
							cFolio
					FROM TABLE(
						MULTISET(
							SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
									CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
									CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
									CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
									CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
									flag_confirmacion_central, 
									flag_confirmacion_sucursal, 
									folio_suc
							FROM bdisac:"informix".sac_movimientoshistorial
							WHERE numcategoria = cCategoria
							AND numconvenio = cConvenio
							AND fecha_pago  = dFechaAux
							AND status_cancelado = 'N'
							AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)))
							
					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mCobEfe = mCobEfe + mCobEfeAux;
								LET mCobCC = mCobCC + mCobCCAux;
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
									LET iRecEfe = iRecEfe +1;
								END IF;
								IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
									LET iRecCC = iRecCC +1;
								END IF;
							END IF;
						ELSE
							LET mCobEfe = mCobEfe + mCobEfeAux;
							LET mCobCC = mCobCC + mCobCCAux;
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
								LET iRecEfe = iRecEfe +1;
							END IF;
							IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
								LET iRecCC = iRecCC +1;
							END IF;
						END IF;
					ELSE
						LET mCobEfe = mCobEfe + mCobEfeAux;
						LET mCobCC = mCobCC + mCobCCAux;
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
							LET iRecEfe = iRecEfe +1;
						END IF;
						IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
							LET iRecCC = iRecCC +1;
						END IF;
					END IF;
				END FOREACH;

				LET mCobEfeT = mCobEfeT + mCobEfe; 
                LET mCobCCT = mCobCCT + mCobCC;
				
                LET iRecEfeT = iRecEfeT + iRecEfe ;
                LET iRecCCT = iRecCCT + iRecCC;

                LET mTotComision = mTotComision + mComision;
                LET mTotIvaCom = mTotIvaCom + mIvaCom;


				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

	                IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
						 LET iRecLun = iRecEfe + iRecCC ;
						LET mCobLun = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET mLiqMier = mLiqMier + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 3 THEN
							LET mLiqJue = mLiqJue + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
							    LET mAcumulado = 0;
							END IF;
						ELIF iDias = 4 THEN
							LET mLiqVie = mLiqVie + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
							    LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 5 AND iDias <= 7 THEN
							LET mLiqlun =  mLiqlun + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;


	                IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
						LET iRecMar = iRecEfe + iRecCC ;
						LET mCobMar = mCobEfe + mCobCC ;

					    IF iDias = 1 THEN
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET mLiqJue = mLiqJue + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 3 THEN
							LET mLiqVie = mLiqVie + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 4 AND iDias <= 6 THEN
							LET mLiqlun =  mLiqlun + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
	                END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
						LET iRecMie = iRecEfe + iRecCC ;
						LET mCobMie = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET mLiqVie = mLiqVie + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 3 AND iDias <= 5 THEN
							LET mLiqlun =  mLiqlun + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
	                END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC ;
						LET mCobJue = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 2 AND iDias <= 4 THEN
							LET mLiqlun =  mLiqlun + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC ;
						LET mCobVie = mCobEfe + mCobCC ;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC ;
						LET mCobSab = mCobEfe + mCobCC ;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC ;
						LET mCobDom = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqlun =  mLiqlun + mCobDom;

							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

	                LET dFechaAux = dFechaAux + 1;

				END IF;
	        END WHILE;

			IF CAST(cCodRet2 AS INTEGER) = 0 THEN

	            INSERT INTO bdisac:"informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo,
																	  cob_lunes, cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo,
																	  rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred,
																	  cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred,
																	  liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,
																	  aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
	            VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom,
	                   mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,
	                   iRecEfeT, iRecCCT, 0, 0,
					   mCobEfeT, mCobCCT, 0, 0,
	                   mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,
	                   0, mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo, (SELECT NVL(MAX(consecutivo_convenio + 1 ),1)
																						  FROM bdisac:"informix".sac_liquidacionsemanal
																						  WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
	    END IF;

        IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
            LET dFechaAux = dPriDiaMes;
            LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

            WHILE dFechaAux <= dfecha_Hoy
				
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT 
						NVL(importe_comision_convenio,0), 
						NVL(iva_comision_convenio,0),
						flag_confirmacion_central, 
						flag_confirmacion_sucursal,
						folio_suc
					INTO 
						mComisionAux, 
						mIvaComAux,
						iFlagCen,
						iFlagSuc,
						cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)
					
					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								LET iNumOpe = iNumOpe + 1;
							END IF;
						ELSE
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							LET iNumOpe = iNumOpe + 1;
						END IF;
					ELSE
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						LET iNumOpe = iNumOpe + 1;
					END IF;
					
				END FOREACH;
				

				INSERT INTO bdisac:"informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;
            END WHILE;

        END IF;

	    IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
		    LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;
		
	    UPDATE bdisac:"informix".sac_controlreportesespeciales
	    SET retorno = cCodret
	    WHERE numcategoria = cCategoria
	    AND numconvenio = cConvenio;
		

    END;
END PROCEDURE
DOCUMENT
'AUTOR : Obed Vega',
'DESCRIPCIÓN: Genera la información para los Reportes Semanal y Mensual de Pagos referenciados (SUKARNE)',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de sp_ProcesoCierreSAC()',
'FECHA : 31 Junio 2013',
'VERSIÓN: 20130731.1',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidaciondish(pId_Convenio CHAR(5) )
--Definicion de Variables
	DEFINE cCodret CHAR(5);
	DEFINE cCodRet2 CHAR(5);
	DEFINE cAnioMes CHAR(6);
	DEFINE cInfoErr CHAR(100);
	DEFINE cCategoria CHAR(2);
	DEFINE cConvenio CHAR(3);
	DEFINE cFechaLiq CHAR(10);
	DEFINE iSqlErr INTEGER;
	DEFINE iIsamErr INTEGER;
	DEFINE iRecEfe INTEGER;
	DEFINE iRecEfeAux CHAR(16);
	DEFINE iRecCC INTEGER;
	DEFINE iRecCCAux CHAR(16);
	DEFINE iRecMix INTEGER;
	DEFINE iRecEfeT INTEGER;
	DEFINE iRecCCT INTEGER;
	DEFINE iRecMixT INTEGER;
	DEFINE iRecLun INTEGER;
	DEFINE iRecMar INTEGER;
	DEFINE iRecMie INTEGER;
	DEFINE iRecJue INTEGER;
	DEFINE iRecVie INTEGER;
	DEFINE iRecSab INTEGER;
	DEFINE iRecDom INTEGER;
	DEFINE iNumOpe INTEGER;
	DEFINE iDias INTEGER;
	DEFINE mLiqlun MONEY(16,2);
	DEFINE mLiqMar MONEY(16,2);
	DEFINE mLiqMier MONEY(16,2);
	DEFINE mLiqJue MONEY(16,2);
	DEFINE mLiqVie MONEY(16,2);
	DEFINE mLiqResguardo MONEY(16,2);
	DEFINE mCobEfe MONEY(16,2);
	DEFINE mCobEfeAux MONEY(16,2);
	DEFINE mCobMix MONEY(16,2);
	DEFINE mCobCC MONEY(16,2);
	DEFINE mCobCCAux MONEY(16,2);
	DEFINE mCobEfeT MONEY(16,2);
	DEFINE mCobMixT MONEY(16,2);
	DEFINE mCobCCT MONEY(16,2);
	DEFINE mCobLun MONEY(16,2);
	DEFINE mCobMar MONEY(16,2);
	DEFINE mCobMie MONEY(16,2);
	DEFINE mCobJue MONEY(16,2);
	DEFINE mCobVie MONEY(16,2);
	DEFINE mCobSab MONEY(16,2);
	DEFINE mCobDom MONEY(16,2);
	DEFINE mTotComision MONEY(16,2);
	DEFINE mTotIvaCom MONEY(16,2);
	DEFINE mComision MONEY(16,2);
	DEFINE mComisionAux MONEY(16,2);
	DEFINE mIvaCom MONEY(16,2);
	DEFINE mIvaComAux MONEY(16,2);
	DEFINE mAcumulado MONEY(16,2);
	DEFINE dFechaAux DATE;
	DEFINE dfecha_Hoy DATE;
	DEFINE dFechaIni DATE;
	DEFINE dPriDiaMes DATE;
	DEFINE dUltDiaMes DATE;
	DEFINE iFlagCen INTEGER;
	DEFINE iFlagSuc INTEGER;
	DEFINE cFolio CHAR(16);
	DEFINE iCuantos INTEGER;

--Inicializacion de Variables
	LET cCodRet2 = "00000";
	LET cCodret = "00000";
	LET cInfoErr = '';
	LET cAnioMes = '';
	LET mCobEfe = 0;
	LET mCobEfeAux = 0;
	LET mCobCC = 0;
	LET mCobCCAux = 0;
	LET mCobMix = 0;
	LET iRecEfe = 0;
	LET iRecEfeAux = '';
	LET iRecCC = 0;
	LET iRecCCAux = '';
	LET iRecMix = 0;
	LET mComision = 0;
	LET mComisionAux = 0;
	LET mIvaCom = 0;
	LET mIvaComAux = 0;
	LET mCobEfeT = 0;
	LET mCobCCT = 0;
	LET iRecEfeT = 0;
	LET iRecCCT = 0;
	LET mTotComision = 0;
	LET mTotIvaCom = 0;
	LET iRecLun = 0;
	LET mCobLun = 0;
	LET iRecMar = 0;
	LET mCobMar = 0;
	LET iRecMie = 0;
	LET mCobMie = 0;
	LET iRecJue = 0;
	LET mCobJue = 0;
	LET iRecVie = 0;
	LET mCobVie = 0;
	LET iRecSab = 0;
	LET mCobSab = 0;
	LET iRecDom = 0;
	LET mCobDom = 0;
	LET cCategoria = SUBSTRING(pId_Convenio FROM 1 FOR 2);
	LET cConvenio = SUBSTRING(pId_Convenio FROM 3 FOR 3);
	LET dFechaAux = '';
	LET dfecha_Hoy = '';
	LET dFechaIni = '';
	LET dPriDiaMes = '';
	LET dUltDiaMes = '';
	LET iNumOpe = 0;
	LET mLiqlun = 0;
	LET mLiqMar = 0;
	LET mLiqMier = 0;
	LET mLiqJue = 0;
	LET mLiqVie = 0;
	LET cFechaLiq = "";
	LET mLiqResguardo = 0;
	LET mAcumulado = 0;
	LET iFlagCen = 0; 
	LET iFlagSuc = 0;
	LET cFolio = '';
	LET iCuantos = 0;
    LET iSqlErr = 0;
	LET iIsamErr = 0;
	LET iDias = 0;

   --SET DEBUG FILE TO "/respaldosbd/mario/sp_reporteliquidaciondish.out";
   --TRACE ON;

   BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;

                    UPDATE bdisac:"informix".sac_controlreportesespeciales
                    SET retorno = cCodRet
                    WHERE numcategoria = cCategoria
                    AND numconvenio = cConvenio;

                    EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidaciondish");
                END IF;
        END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
			
        SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
        INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
        FROM bdisac:"informix".sac_fechas;

        IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

            LET dFechaAux = dfecha_Hoy - 6;
            LET dFechaIni = dFechaAux;

			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM bdisac:"informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
			                            FROM bdisac:"informix".sac_liquidacionsemanal
			                            WHERE id_convenio = cCategoria||cConvenio
										AND consecutivo_convenio <> 0);


			IF mAcumulado IS NULL THEN
			    LET mAcumulado = 0;
			END IF;

            WHILE dFechaAux <= dfecha_Hoy
				
				LET mCobEfe = 0.00;
				LET mCobCC = 0.00;
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iRecEfe = 0;
				LET iRecCC = 0;
				
				FOREACH
					SELECT 
							NVL(efe,0), 
							NVL(cc,0), 
							NVL(Rec1,''),
							NVL(Rec2,""), 
							NVL(comision, 0), 
							NVL(iva_com,0),
							flag_confirmacion_central, 
							flag_confirmacion_sucursal, 
							folio_suc
					INTO 
							mCobEfeAux, 
							mCobCCAux, 
							iRecEfeAux, 
							iRecCCAux, 
							mComisionAux, 
							mIvaComAux,
							iFlagCen,
							iFlagSuc,
							cFolio
					FROM TABLE(
						MULTISET(
							SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
									CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
									CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
									CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
									CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
									flag_confirmacion_central, 
									flag_confirmacion_sucursal, 
									folio_suc
							FROM bdisac:"informix".sac_movimientoshistorial
							WHERE numcategoria = cCategoria
							AND numconvenio = cConvenio
							AND fecha_pago  = dFechaAux
							AND status_cancelado = 'N'
							AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)))
							
					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mCobEfe = mCobEfe + mCobEfeAux;
								LET mCobCC = mCobCC + mCobCCAux;
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
									LET iRecEfe = iRecEfe +1;
								END IF;
								IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
									LET iRecCC = iRecCC +1;
								END IF;
							END IF;
						ELSE
							LET mCobEfe = mCobEfe + mCobEfeAux;
							LET mCobCC = mCobCC + mCobCCAux;
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
								LET iRecEfe = iRecEfe +1;
							END IF;
							IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
								LET iRecCC = iRecCC +1;
							END IF;
						END IF;
					ELSE
						LET mCobEfe = mCobEfe + mCobEfeAux;
						LET mCobCC = mCobCC + mCobCCAux;
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
							LET iRecEfe = iRecEfe +1;
						END IF;
						IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
							LET iRecCC = iRecCC +1;
						END IF;
					END IF;
				END FOREACH;

				LET mCobEfeT = mCobEfeT + mCobEfe; 
                LET mCobCCT = mCobCCT + mCobCC;
				
                LET iRecEfeT = iRecEfeT + iRecEfe ;
                LET iRecCCT = iRecCCT + iRecCC;

                LET mTotComision = mTotComision + mComision;
                LET mTotIvaCom = mTotIvaCom + mIvaCom;


				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

	                IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
						 LET iRecLun = iRecEfe + iRecCC ;
						LET mCobLun = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET mLiqMier = mLiqMier + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 3 THEN
							LET mLiqJue = mLiqJue + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
							    LET mAcumulado = 0;
							END IF;
						ELIF iDias = 4 THEN
							LET mLiqVie = mLiqVie + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
							    LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 5 AND iDias <= 7 THEN
							LET mLiqlun =  mLiqlun + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;


	                IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
						LET iRecMar = iRecEfe + iRecCC ;
						LET mCobMar = mCobEfe + mCobCC ;

					    IF iDias = 1 THEN
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET mLiqJue = mLiqJue + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 3 THEN
							LET mLiqVie = mLiqVie + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 4 AND iDias <= 6 THEN
							LET mLiqlun =  mLiqlun + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
	                END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
						LET iRecMie = iRecEfe + iRecCC ;
						LET mCobMie = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET mLiqVie = mLiqVie + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 3 AND iDias <= 5 THEN
							LET mLiqlun =  mLiqlun + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
	                END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC ;
						LET mCobJue = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 2 AND iDias <= 4 THEN
							LET mLiqlun =  mLiqlun + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC ;
						LET mCobVie = mCobEfe + mCobCC ;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC ;
						LET mCobSab = mCobEfe + mCobCC ;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC ;
						LET mCobDom = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqlun =  mLiqlun + mCobDom;

							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

	                LET dFechaAux = dFechaAux + 1;

				END IF;
	        END WHILE;

			IF CAST(cCodRet2 AS INTEGER) = 0 THEN

	            INSERT INTO bdisac:"informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo,
																	  cob_lunes, cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo,
																	  rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred,
																	  cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred,
																	  liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,
																	  aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
	            VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom,
	                   mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,
	                   iRecEfeT, iRecCCT, 0, 0,
					   mCobEfeT, mCobCCT, 0, 0,
	                   mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,
	                   0, mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo, (SELECT NVL(MAX(consecutivo_convenio + 1 ),1)
																						  FROM bdisac:"informix".sac_liquidacionsemanal
																						  WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
	    END IF;

        IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
            LET dFechaAux = dPriDiaMes;
            LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

            WHILE dFechaAux <= dfecha_Hoy
				
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT 
						NVL(importe_comision_convenio,0), 
						NVL(iva_comision_convenio,0),
						flag_confirmacion_central, 
						flag_confirmacion_sucursal,
						folio_suc
					INTO 
						mComisionAux, 
						mIvaComAux,
						iFlagCen,
						iFlagSuc,
						cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)
					
					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								LET iNumOpe = iNumOpe + 1;
							END IF;
						ELSE
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							LET iNumOpe = iNumOpe + 1;
						END IF;
					ELSE
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						LET iNumOpe = iNumOpe + 1;
					END IF;
					
				END FOREACH;
				

				INSERT INTO bdisac:"informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);
				
				INSERT INTO bdisac:"informix".sac_liquidacionmensualdish(aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);
				
				LET dFechaAux = dFechaAux + 1;
            END WHILE;

        END IF;

	    IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
		    LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;
		
	    UPDATE bdisac:"informix".sac_controlreportesespeciales
	    SET retorno = cCodret
	    WHERE numcategoria = cCategoria
	    AND numconvenio = cConvenio;
		

    END;
END PROCEDURE
DOCUMENT
'AUTOR : Dulce Ramírez',
'DESCRIPCION: Genera la informacion para los Reportes Mensual de Pagos dish',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de sp_ProcesoCierreSAC()',
'FECHA : 02 de Septiembre de 2010',
'VERSION: 20100902.1720',
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------',
'Folio:1576',
'Autor:95142134 Mario Gallardo',
'Fecha:15/01/2014',
'Modificación: Se modifica procedimiento para que guarde iformacion en las tablas homologadas y propias sac_liquidacionmensual y sac_liquidacionsemanal.',
'Sustento: RQI 62 078-Optimización Reportes SAC.doc -  (Pagina 2 a 3)',
'Solicita: Jaime Gonzalez',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_reporteliquidacionmastv(pId_Convenio CHAR(5) )
--Definicion de Variables
	DEFINE cCodret CHAR(5);
	DEFINE cCodRet2 CHAR(5);
	DEFINE cAnioMes CHAR(6);
	DEFINE cInfoErr CHAR(100);
	DEFINE cCategoria CHAR(2);
	DEFINE cConvenio CHAR(3);
	DEFINE cFechaLiq CHAR(10);
	DEFINE iSqlErr INTEGER;
	DEFINE iIsamErr INTEGER;
	DEFINE iRecEfe INTEGER;
	DEFINE iRecEfeAux CHAR(16);
	DEFINE iRecCC INTEGER;
	DEFINE iRecCCAux CHAR(16);
	DEFINE iRecMix INTEGER;
	DEFINE iRecEfeT INTEGER;
	DEFINE iRecCCT INTEGER;
	DEFINE iRecMixT INTEGER;
	DEFINE iRecLun INTEGER;
	DEFINE iRecMar INTEGER;
	DEFINE iRecMie INTEGER;
	DEFINE iRecJue INTEGER;
	DEFINE iRecVie INTEGER;
	DEFINE iRecSab INTEGER;
	DEFINE iRecDom INTEGER;
	DEFINE iNumOpe INTEGER;
	DEFINE iDias INTEGER;
	DEFINE mLiqlun MONEY(16,2);
	DEFINE mLiqMar MONEY(16,2);
	DEFINE mLiqMier MONEY(16,2);
	DEFINE mLiqJue MONEY(16,2);
	DEFINE mLiqVie MONEY(16,2);
	DEFINE mLiqResguardo MONEY(16,2);
	DEFINE mCobEfe MONEY(16,2);
	DEFINE mCobEfeAux MONEY(16,2);
	DEFINE mCobMix MONEY(16,2);
	DEFINE mCobCC MONEY(16,2);
	DEFINE mCobCCAux MONEY(16,2);
	DEFINE mCobEfeT MONEY(16,2);
	DEFINE mCobMixT MONEY(16,2);
	DEFINE mCobCCT MONEY(16,2);
	DEFINE mCobLun MONEY(16,2);
	DEFINE mCobMar MONEY(16,2);
	DEFINE mCobMie MONEY(16,2);
	DEFINE mCobJue MONEY(16,2);
	DEFINE mCobVie MONEY(16,2);
	DEFINE mCobSab MONEY(16,2);
	DEFINE mCobDom MONEY(16,2);
	DEFINE mTotComision MONEY(16,2);
	DEFINE mTotIvaCom MONEY(16,2);
	DEFINE mComision MONEY(16,2);
	DEFINE mComisionAux MONEY(16,2);
	DEFINE mIvaCom MONEY(16,2);
	DEFINE mIvaComAux MONEY(16,2);
	DEFINE mAcumulado MONEY(16,2);
	DEFINE dFechaAux DATE;
	DEFINE dfecha_Hoy DATE;
	DEFINE dFechaIni DATE;
	DEFINE dPriDiaMes DATE;
	DEFINE dUltDiaMes DATE;
	DEFINE iFlagCen INTEGER;
	DEFINE iFlagSuc INTEGER;
	DEFINE cFolio CHAR(16);
	DEFINE iCuantos INTEGER;
	
--Inicializacion de Variables
	LET cCodRet2 = "00000";
	LET cCodret = "00000";
	LET cInfoErr = '';
	LET cAnioMes = '';
	LET mCobEfe = 0;
	LET mCobEfeAux = 0;
	LET mCobCC = 0;
	LET mCobCCAux      = 0;
	LET mCobMix = 0;
	LET iRecEfe = 0;
	LET iRecEfeAux = '';
	LET iRecCC = 0;
	LET iRecCCAux = '';
	LET iRecMix = 0;
	LET mComision = 0;
	LET mComisionAux = 0;
	LET mIvaCom = 0;
	LET mIvaComAux = 0;
	LET mCobEfeT = 0;
	LET mCobCCT = 0;
	LET iRecEfeT = 0;
	LET iRecCCT = 0;
	LET mTotComision = 0;
	LET mTotIvaCom = 0;
	LET iRecLun = 0;
	LET mCobLun = 0;
	LET iRecMar = 0;
	LET mCobMar = 0;
	LET iRecMie = 0;
	LET mCobMie = 0;
	LET iRecJue = 0;
	LET mCobJue = 0;
	LET iRecVie = 0;
	LET mCobVie = 0;
	LET iRecSab = 0;
	LET mCobSab = 0;
	LET iRecDom = 0;
	LET mCobDom = 0;
	LET cCategoria = SUBSTRING(pId_Convenio FROM 1 FOR 2);
	LET cConvenio = SUBSTRING(pId_Convenio FROM 3 FOR 3);
	LET dFechaAux = '';
	LET dfecha_Hoy = '';
	LET dFechaIni = '';
	LET dPriDiaMes = '';
	LET dUltDiaMes = '';
	LET iNumOpe = 0;
	LET mLiqlun = 0;
	LET mLiqMar = 0;
	LET mLiqMier = 0;
	LET mLiqJue = 0;
	LET mLiqVie = 0;
	LET cFechaLiq = "";
	LET mLiqResguardo = 0;
	LET mAcumulado = 0;
	LET iFlagCen = 0; 
	LET iFlagSuc = 0;
	LET cFolio = '';
	LET iCuantos = 0;
    LET iSqlErr = 0;
	LET iIsamErr = 0;
	LET iDias = 0;

   --SET DEBUG FILE TO "/respaldosbd/mario/sp_reporteliquidacionmastv.out";
   --TRACE ON;

   BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
                    UPDATE bdisac:"informix".sac_controlreportesespeciales
                    SET retorno = cCodRet
                    WHERE numcategoria = cCategoria
                    AND numconvenio = cConvenio;
                    EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacionmastv");
                END IF;
        END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
			
        SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
        INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
        FROM bdisac:"informix".sac_fechas;

        IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

            LET dFechaAux = dfecha_Hoy - 6;
            LET dFechaIni = dFechaAux;

			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM bdisac:"informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
			                            FROM bdisac:"informix".sac_liquidacionsemanal
			                            WHERE id_convenio = cCategoria||cConvenio
										AND consecutivo_convenio <> 0);


			IF 	mAcumulado IS NULL THEN
			    LET mAcumulado = 0;
			END IF;

            WHILE dFechaAux <= dfecha_Hoy
				
				LET mCobEfe = 0.00;
				LET mCobCC = 0.00;
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iRecEfe = 0;
				LET iRecCC = 0;
				
				FOREACH
					SELECT 
							NVL(efe,0), 
							NVL(cc,0), 
							NVL(Rec1,''),
							NVL(Rec2,""), 
							NVL(comision, 0), 
							NVL(iva_com,0),
							flag_confirmacion_central, 
							flag_confirmacion_sucursal, 
							folio_suc
					INTO 
							mCobEfeAux, 
							mCobCCAux, 
							iRecEfeAux, 
							iRecCCAux, 
							mComisionAux, 
							mIvaComAux,
							iFlagCen,
							iFlagSuc,
							cFolio
					FROM TABLE(
						MULTISET(
							SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
									CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
									CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
									CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
									CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
									flag_confirmacion_central, 
									flag_confirmacion_sucursal, 
									folio_suc
							FROM bdisac:"informix".sac_movimientoshistorial
							WHERE numcategoria = cCategoria
							AND numconvenio = cConvenio
							AND fecha_pago  = dFechaAux
							AND status_cancelado = 'N'
							AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)))
							
					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mCobEfe = mCobEfe + mCobEfeAux;
								LET mCobCC = mCobCC + mCobCCAux;
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
									LET iRecEfe = iRecEfe +1;
								END IF;
								IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
									LET iRecCC = iRecCC +1;
								END IF;
							END IF;
						ELSE
							LET mCobEfe = mCobEfe + mCobEfeAux;
							LET mCobCC = mCobCC + mCobCCAux;
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
								LET iRecEfe = iRecEfe +1;
							END IF;
							IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
								LET iRecCC = iRecCC +1;
							END IF;
						END IF;
					ELSE
						LET mCobEfe = mCobEfe + mCobEfeAux;
						LET mCobCC = mCobCC + mCobCCAux;
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
							LET iRecEfe = iRecEfe +1;
						END IF;
						IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
							LET iRecCC = iRecCC +1;
						END IF;
					END IF;
				END FOREACH;

				LET mCobEfeT = mCobEfeT + mCobEfe; 
                LET mCobCCT = mCobCCT + mCobCC;
				
                LET iRecEfeT = iRecEfeT + iRecEfe ;
                LET iRecCCT = iRecCCT + iRecCC;

                LET mTotComision = mTotComision + mComision;
                LET mTotIvaCom = mTotIvaCom + mIvaCom;


				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

	                IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
						 LET iRecLun = iRecEfe + iRecCC ;
						LET mCobLun = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET mLiqMier = mLiqMier + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 3 THEN
							LET mLiqJue = mLiqJue + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
							    LET mAcumulado = 0;
							END IF;
						ELIF iDias = 4 THEN
							LET mLiqVie = mLiqVie + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
							    LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 5 AND iDias <= 7 THEN
							LET mLiqlun =  mLiqlun + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;


	                IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
						LET iRecMar = iRecEfe + iRecCC ;
						LET mCobMar = mCobEfe + mCobCC ;

					    IF iDias = 1 THEN
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET mLiqJue = mLiqJue + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 3 THEN
							LET mLiqVie = mLiqVie + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 4 AND iDias <= 6 THEN
							LET mLiqlun =  mLiqlun + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
	                END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
						LET iRecMie = iRecEfe + iRecCC ;
						LET mCobMie = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias = 2 THEN
							LET mLiqVie = mLiqVie + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 3 AND iDias <= 5 THEN
							LET mLiqlun =  mLiqlun + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
	                END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC ;
						LET mCobJue = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELIF iDias >= 2 AND iDias <= 4 THEN
							LET mLiqlun =  mLiqlun + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC ;
						LET mCobVie = mCobEfe + mCobCC ;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC ;
						LET mCobSab = mCobEfe + mCobCC ;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC ;
						LET mCobDom = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqlun =  mLiqlun + mCobDom;

							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

	                LET dFechaAux = dFechaAux + 1;

				END IF;
	        END WHILE;

			IF CAST(cCodRet2 AS INTEGER) = 0 THEN

	            INSERT INTO bdisac:"informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo,
																	  cob_lunes, cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo,
																	  rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred,
																	  cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred,
																	  liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,
																	  aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
	            VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom,
	                   mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,
	                   iRecEfeT, iRecCCT, 0, 0,
					   mCobEfeT, mCobCCT, 0, 0,
	                   mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,
	                   0, mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo, (SELECT NVL(MAX(consecutivo_convenio + 1 ),1)
																						  FROM bdisac:"informix".sac_liquidacionsemanal
																						  WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
	    END IF;

        IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
            LET dFechaAux = dPriDiaMes;
            LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

            WHILE dFechaAux <= dfecha_Hoy
				
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT 
						NVL(importe_comision_convenio,0), 
						NVL(iva_comision_convenio,0),
						flag_confirmacion_central, 
						flag_confirmacion_sucursal,
						folio_suc
					INTO 
						mComisionAux, 
						mIvaComAux,
						iFlagCen,
						iFlagSuc,
						cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)
					
					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								LET iNumOpe = iNumOpe + 1;
							END IF;
						ELSE
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							LET iNumOpe = iNumOpe + 1;
						END IF;
					ELSE
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						LET iNumOpe = iNumOpe + 1;
					END IF;
					
				END FOREACH;
				

				INSERT INTO bdisac:"informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);
				
			   INSERT INTO bdisac:"informix".sac_liquidacionmensualmastv(aniomes, fecha,num_operaciones, comision, iva, fecha_insert) 
			   VALUES (cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;
            END WHILE;

        END IF;

	    IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
		    LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;
		
	    UPDATE bdisac:"informix".sac_controlreportesespeciales
	    SET retorno = cCodret
	    WHERE numcategoria = cCategoria
	    AND numconvenio = cConvenio;
		

    END;
END PROCEDURE
DOCUMENT
'AUTOR : Dulce Ramírez',
'DESCRIPCION: Genera la informacion para los Reportes Mensual de Pagos mastv',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual es llamado de sp_ProcesoCierreSAC()',
'FECHA : 02 de Septiembre de 2010',
'VERSION: 20100902.1720',
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------',
'Folio:1576',
'Autor:95142134 Mario Gallardo',
'Fecha:15/01/2014',
'Modificación: Se modifica procedimiento para que guarde iformacion en las tablas homologadas y propias sac_liquidacionmensual y sac_liquidacionsemanal.',
'Sustento: RQI 62 078-Optimización Reportes SAC.doc -  (Pagina 2 a 3)',
'Solicita: Jaime Gonzalez',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_reporteliquidacionsky(cId_Convenio CHAR(5) )
   DEFINE cCodret CHAR(5);
   DEFINE cInfoErr CHAR(100);   
   DEFINE iSqlErr,iIsamErr   INTEGER;
   DEFINE iRecEfe INTEGER;
   DEFINE iRecCC INTEGER;
   DEFINE iRecMix INTEGER;
   DEFINE iRecEfeT INTEGER;
   DEFINE iRecCCT INTEGER;
   DEFINE iRecMixT INTEGER;
   DEFINE iRecTot INTEGER;
   DEFINE iRecAux INTEGER;
   DEFINE iRecLun INTEGER;
   DEFINE iRecMAr INTEGER;
   DEFINE iRecMie INTEGER;
   DEFINE iRecJue INTEGER;
   DEFINE iRecVie INTEGER;
   DEFINE iRecSab INTEGER;
   DEFINE iRecDom INTEGER;
   DEFINE deCobEfe MONEY(16,2);
   DEFINE deCobMix MONEY(16,2);
   DEFINE deCobCC MONEY(16,2);
   DEFINE deCobEfeT MONEY(16,2);
   DEFINE deCobMixT MONEY(16,2);
   DEFINE deCobCCT MONEY(16,2);
   DEFINE deCobTot MONEY(16,2);
   DEFINE deCobAux MONEY(16,2);
   DEFINE deCobLun MONEY(16,2);
   DEFINE deCobMar MONEY(16,2);
   DEFINE deCobMie MONEY(16,2);
   DEFINE deCobJue MONEY(16,2);
   DEFINE deCobVie MONEY(16,2);
   DEFINE deCobSab MONEY(16,2);
   DEFINE deCobDom MONEY(16,2);
   DEFINE deTotComision MONEY(16,2);
   DEFINE deTotIvaCom MONEY(16,2);
   DEFINE deComision MONEY(16,2);
   DEFINE deIvaCom MONEY(16,2);
   DEFINE cCategoria CHAR(2);
   DEFINE cConvenio CHAR(3);
   DEFINE dFechaAux DATE;
   DEFINE dfecha_Hoy DATE;
   DEFINE dFechaIni DATE;
   DEFINE cAnioMes CHAR(6);
   DEFINE iNumOpe INTEGER;
   DEFINE mComision MONEY(16,2);
   DEFINE mComisionAux MONEY(16,2);
   DEFINE mIvaCom MONEY(16,2);
   DEFINE mIvaComAux MONEY(16,2);
   DEFINE iFlagCen INTEGER;
   DEFINE iFlagSuc INTEGER;
   DEFINE cFolio CHAR(16);
   DEFINE iCuantos INTEGER;
   DEFINE dPriDiaMes DATE;
   DEFINE dUltDiaMes DATE;

   
   LET cInfoErr = '';
   LET iSqlErr =0;
   LET iIsamErr   = 0;
   LET iRecEfe = 0;
   LET iRecCC = 0;
   LET iRecMix = 0;
   LET iRecMixT = 0;
   LET iRecTot = 0;
   LET iRecAux = 0;
   LET iRecLun = 0;
   LET iRecMAr = 0;
   LET iRecMie = 0;
   LET iRecJue = 0;
   LET iRecVie = 0;
   LET iRecSab = 0;
   LET iRecDom = 0;
   LET deCobEfe = 0;
   LET deCobMix = 0;
   LET deCobCC = 0;
   LET deCobEfeT = 0;
   LET deCobMixT = 0;
   LET deCobTot = 0;
   LET deCobLun = 0;
   LET deCobMar = 0;
   LET deCobMie = 0;
   LET deCobJue = 0;
   LET deCobVie = 0;
   LET deCobSab = 0;
   LET deCobDom = 0;
   LET deComision = 0;
   LET deIvaCom = 0;
   LET dFechaAux = '';
   LET dfecha_Hoy = '';
   LET dFechaIni = '';
   LET dPriDiaMes = '';
   LET dUltDiaMes = '';
   LET cAnioMes = '';
   LET mComision = 0;
   LET mComisionAux = 0;
   LET mIvaCom = 0;
   LET mIvaComAux = 0;
   LET iNumOpe = 0;
   LET iFlagCen = 0; 
   LET iFlagSuc = 0;
   LET cFolio = '';
   LET iCuantos = 0;
   LET cCodret = "00000";
   LET deCobAux = 0;
   LET decobefet = 0;
   LET iRecEfeT = 0;
   LET deCobCCT = 0;
   LET iRecCCT = 0;
   LET deTotComision = 0;
   LET deTotIvaCom = 0;
   LET cCategoria = SUBSTRING(cId_Convenio FROM 1 FOR 2);
   LET cConvenio = SUBSTRING(cId_Convenio FROM 3 FOR 3);

   
   --SET DEBUG FILE TO "/respaldosbd/mario/sp_reporteliquidacionsky.out";
   --TRACE ON; 
   
   BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;

                    UPDATE bdisac:"informix".sac_controlreportesespeciales
                    SET retorno = cCodRet
                    WHERE numcategoria = cCategoria
                    AND numconvenio = cConvenio;

                    EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacionsky");
                END IF;
        END EXCEPTION;

		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;		
		
        SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
        INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
        FROM bdisac:"informix".sac_fechas;

        IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

                LET dFechaAux = dfecha_Hoy - 6;
                LET dFechaIni = dFechaAux;

                WHILE dFechaAux <= dfecha_Hoy
                      SELECT NVL(SUM(efe),0), NVL(SUM(cc),0), NVL(SUM(mix),0), COUNT(Rec1), COUNT(Rec2), COUNT(Rec3), nvl(SUM(comision), 0), nvl(SUM(iva_com),0)
                      INTO deCobEfe, deCobCC, deCobMix, iRecEfe, iRecCC, iRecMix, deComision, deIvaCom
                      FROM TABLE(
                          MULTISET(
                              SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
                                             CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
                                             CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
                                             CASE WHEN forma_pago = 3 THEN NVL(importe_pago, 0) END AS mix,
                                             CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
                                             CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
                                             CASE WHEN forma_pago = 3 THEN folio_suc END AS Rec3
                              FROM bdisac:"informix".sac_movimientoshistorial
                              WHERE numcategoria = cCategoria
                              AND numconvenio = cConvenio
                              AND fecha_pago  = dFechaAux
                              AND status_cancelado = 'N'));

                      LET deCobEfeT = deCobEfeT + deCobEfe + deCobMix;
                      LET deCobCCT = deCobCCT + deCobCC;

                      LET iRecEfeT = iRecEfeT + iRecEfe + iRecMix;
                      LET iRecCCT = iRecCCT + iRecCC;

                      LET deTotComision = deTotComision + deComision;
                      LET deTotIvaCom = deTotIvaCom + deIvaCom;

                      IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
                           LET iRecLun = iRecEfe + iRecCC + iRecMix;
                           LET deCobLun = deCobEfe + deCobCC + deCobMix;
                      END IF;
                      IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
                          LET iRecMar = iRecEfe + iRecCC + iRecMix;
                          LET deCobMar = deCobEfe + deCobCC + deCobMix;
                      END IF;
                       IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
                           LET iRecMie = iRecEfe + iRecCC + iRecMix;
                          LET deCobMie = deCobEfe + deCobCC + deCobMix;
                      END IF;
                      IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
                          LET iRecJue = iRecEfe + iRecCC + iRecMix;
                          LET deCobJue = deCobEfe + deCobCC + deCobMix;
                      END IF;
                      IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
                          LET iRecVie = iRecEfe + iRecCC + iRecMix;
                          LET deCobVie = deCobEfe + deCobCC + deCobMix;
                      END IF;
                      IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
                          LET iRecSab = iRecEfe + iRecCC + iRecMix;
                          LET deCobSab = deCobEfe + deCobCC + deCobMix;
                      END IF;
                      IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
                          LET iRecDom = iRecEfe + iRecCC + iRecMix;
                          LET deCobDom = deCobEfe + deCobCC + deCobMix;
                      END IF;

                      LET dFechaAux = dFechaAux + 1;

                END WHILE;

                INSERT INTO bdisac:"informix".sac_liquidacionsemanalsky (rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo,
                                                                cob_lunes, cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo,
                                                                rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred,
                                                                cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred,
                                                                liq_miercoles, liq_jueves, liq_viernes,liq_lunes, liq_martes,
                                                                aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, fecha_insert)
                VALUES(iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom,
                       deCobLun, deCobMar, deCobMie, deCobJue, deCobVie, deCobSab, deCobDom,
                       iRecEfeT, iRecCCT, 0, 0,
                       deCobEfeT, deCobCCT, 0, 0,
                       deCobLun, deCobMar, deCobMie, deCobJue, deCobVie + deCobSab + deCobDom,
                       0, deTotComision, deTotIvaCom, dFechaIni,dfecha_Hoy, CURRENT);
					   
	            INSERT INTO bdisac:"informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo,
																	  cob_lunes, cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo,
																	  rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred,
																	  cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred,
																	  liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,
																	  aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
               VALUES(cId_Convenio,iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom,
                       deCobLun, deCobMar, deCobMie, deCobJue, deCobVie, deCobSab, deCobDom,
                       iRecEfeT, iRecCCT, 0, 0,
                       deCobEfeT, deCobCCT, 0, 0,
                       deCobLun, deCobMar, deCobMie, deCobJue, deCobVie + deCobSab + deCobDom,
	                    0, deTotComision, deTotIvaCom, dFechaIni,dfecha_Hoy, 0, (SELECT NVL(MAX(consecutivo_convenio + 1 ),1) FROM bdisac:"informix".sac_liquidacionsemanal WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
						
        END IF;
        
        IF dfecha_Hoy = dUltDiaMes  THEN
            LET dFechaAux = dPriDiaMes;
            LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

            WHILE dFechaAux <= dfecha_Hoy
				
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT 
						NVL(importe_comision_convenio,0), 
						NVL(iva_comision_convenio,0),
						flag_confirmacion_central, 
						flag_confirmacion_sucursal,
						folio_suc
					INTO 
						mComisionAux, 
						mIvaComAux,
						iFlagCen,
						iFlagSuc,
						cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)
					
					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								LET iNumOpe = iNumOpe + 1;
							END IF;
						ELSE
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							LET iNumOpe = iNumOpe + 1;
						END IF;
					ELSE
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						LET iNumOpe = iNumOpe + 1;
					END IF;
					
				END FOREACH;
				

			  INSERT INTO bdisac:"informix".sac_liquidacionmensualsky(aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
			  VALUES(cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);
						  
			INSERT INTO bdisac:"informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
			VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);
				
				LET dFechaAux = dFechaAux + 1;
            END WHILE;

        END IF;
		
	    UPDATE bdisac:"informix".sac_controlreportesespeciales
	    SET retorno = cCodret
	    WHERE numcategoria = cCategoria
	    AND numconvenio = cConvenio;
		
    END;
END PROCEDURE
DOCUMENT
'AUTOR : Saul Ivanhoe Valdespino Hernandez',
'DESCRIPCION: Genera la informacion para los Reportes Semanal y Mensual de Pagos Sky',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de sp_ProcesoCierreSAC()',
'FECHA : 20 de Mayo de 2010',
'VERSION: 20100520.1630',
'BD    : bdisac',
'Modifica: Raul Ruiz',
'Descripcion: Se agrega filtro de movimientos no cancelados',
'Version: 20100724.1406',
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------',
'Folio:1576',
'Autor:95142134 Mario Gallardo',
'Fecha:15/01/2014',
'Modificación: Se modifica procedimiento para que guarde ifnormación en las tablas homologadas y propias sac_liquidacionmensual y sac_liquidacionsemanal.',
'Sustento: RQI 62 078-Optimización Reportes SAC.doc -  (Pagina 2 a 3)',
'Solicita: Jaime Gonzalez',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_reporteliquidaciontelmex(cId_Convenio CHAR(5))
   DEFINE cCodret CHAR(5);
   DEFINE cInfoErr CHAR(100);
   DEFINE iSqlErr INTEGER;
   DEFINE iIsamErr   INTEGER;
   DEFINE iRecEfe INTEGER;
   DEFINE iRecCC INTEGER;
   DEFINE iRecMix INTEGER;
   DEFINE iRecEfeT INTEGER;
   DEFINE iRecCCT INTEGER;
   DEFINE iRecMixT INTEGER;
   DEFINE iRecTot INTEGER;
   DEFINE iRecAux INTEGER;
   DEFINE iRecLun INTEGER;
   DEFINE iRecMAr INTEGER;
   DEFINE iRecMie INTEGER;
   DEFINE iRecJue INTEGER;
   DEFINE iRecVie INTEGER;
   DEFINE iRecSab INTEGER;
   DEFINE iRecDom INTEGER;
   DEFINE deCobEfe MONEY(16,2);
   DEFINE deCobMix MONEY(16,2);
   DEFINE deCobCC MONEY(16,2);
   DEFINE deCobEfeT MONEY(16,2);
   DEFINE deCobMixT MONEY(16,2);
   DEFINE deCobCCT MONEY(16,2);
   DEFINE deCobTot MONEY(16,2);
   DEFINE deCobAux MONEY(16,2);
   DEFINE deCobLun MONEY(16,2);
   DEFINE deCobMar MONEY(16,2);
   DEFINE deCobMie MONEY(16,2);
   DEFINE deCobJue MONEY(16,2);
   DEFINE deCobVie MONEY(16,2);
   DEFINE deCobSab MONEY(16,2);
   DEFINE deCobDom MONEY(16,2);
   DEFINE deTotComision MONEY(16,2);
   DEFINE deTotIvaCom MONEY(16,2);
   DEFINE deComision MONEY(16,2);
   DEFINE deIvaCom MONEY(16,2);
   DEFINE cCategoria CHAR(2);
   DEFINE cConvenio CHAR(3);
   DEFINE dFechaAux DATE;
   DEFINE dfecha_Hoy DATE;
   DEFINE dFechaIni DATE;
   DEFINE cCodRet2 CHAR(5);
   DEFINE cAnioMes CHAR(6);
   DEFINE iNumOpe INTEGER;
   DEFINE mComision MONEY(16,2);
   DEFINE mComisionAux MONEY(16,2);
   DEFINE mIvaCom MONEY(16,2);
   DEFINE mIvaComAux MONEY(16,2);
   DEFINE iFlagCen INTEGER;
   DEFINE iFlagSuc INTEGER;
   DEFINE cFolio CHAR(16);
   DEFINE iCuantos INTEGER;
   DEFINE dPriDiaMes DATE;
   DEFINE dUltDiaMes DATE;

   LET dPriDiaMes = '';
   LET dUltDiaMes = '';
   LET cAnioMes = '';
   LET mComision = 0;
   LET mComisionAux = 0;
   LET mIvaCom = 0;
   LET mIvaComAux = 0;
   LET iNumOpe = 0;
   LET iFlagCen = 0; 
   LET iFlagSuc = 0;
   LET cFolio = '';
   LET iCuantos = 0;
   LET cCodret = "00000";
   LET deCobAux = 0;
   LET decobefet = 0;
   LET iRecEfeT = 0;
   LET deCobCCT = 0;
   LET iRecCCT = 0;
   LET deTotComision = 0;
   LET deTotIvaCom = 0;
   LET cCategoria = SUBSTRING(cId_Convenio FROM 1 FOR 2);
   LET cConvenio = SUBSTRING(cId_Convenio FROM 3 FOR 3);
   LET cInfoErr = '';
   LET iSqlErr =0;
   LET iIsamErr   = 0;
   LET iRecEfe = 0;
   LET iRecCC = 0;
   LET iRecMix = 0;
   LET iRecMixT = 0;
   LET iRecTot = 0;
   LET iRecAux = 0;
   LET iRecLun = 0;
   LET iRecMAr = 0;
   LET iRecMie = 0;
   LET iRecJue = 0;
   LET iRecVie = 0;
   LET iRecSab = 0;
   LET iRecDom = 0;
   LET deCobEfe = 0;
   LET deCobMix = 0;
   LET deCobCC = 0;
   LET deCobEfeT = 0;
   LET deCobMixT = 0;
   LET deCobTot = 0;
   LET deCobLun = 0;
   LET deCobMar = 0;
   LET deCobMie = 0;
   LET deCobJue = 0;
   LET deCobVie = 0;
   LET deCobSab = 0;
   LET deCobDom = 0;
   LET deComision = 0;
   LET deIvaCom = 0;
   LET dFechaAux  = '';
   LET dfecha_Hoy  = '';
   LET dFechaIni  = '';
   LET cCodRet2 = '';
   
   --SET DEBUG FILE TO "/respaldosbd/mario/sp_reporteliquidaciontelmex.out";
   --TRACE ON;

   BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
                    UPDATE bdisac:"informix".sac_controlreportesespeciales
                    SET retorno = cCodRet
                    WHERE numcategoria = cCategoria
                    AND numconvenio = cConvenio;
                    EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidaciontelmex");
                END IF;
        END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		
        SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
        INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
        FROM bdisac:"informix".sac_fechas;

        IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

                LET dFechaAux = dfecha_Hoy - 6;
                LET dFechaIni = dFechaAux;

                WHILE dFechaAux <= dfecha_Hoy
                    SELECT NVL(SUM(efe),0), NVL(SUM(cc),0), NVL(SUM(mix),0), COUNT(Rec1), COUNT(Rec2), COUNT(Rec3), nvl(SUM(comision), 0), nvl(SUM(iva_com),0)
                    INTO deCobEfe, deCobCC, deCobMix, iRecEfe, iRecCC, iRecMix, deComision, deIvaCom
                    FROM TABLE(
                        MULTISET(
                            SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
                            CASE WHEN forma_pago = 1 THEN NVL(importe_pago - importe_comision_cte , 0) END AS efe,
                            CASE WHEN forma_pago = 2 THEN NVL(importe_pago - importe_comision_cte , 0) END AS cc,
                            CASE WHEN forma_pago = 3 THEN NVL(importe_pago - importe_comision_cte , 0) END AS mix,
                            CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
                            CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
                            CASE WHEN forma_pago = 3 THEN folio_suc END AS Rec3
                            FROM bdisac:"informix".sac_movimientoshistorial
                            WHERE numcategoria = cCategoria
                            AND numconvenio = cConvenio
                            AND fecha_pago  = dFechaAux
                            AND status_cancelado <> 'S' ));

                    LET deCobEfeT = deCobEfeT + deCobEfe + deCobMix;
                    LET deCobCCT = deCobCCT + deCobCC;

                    LET iRecEfeT = iRecEfeT + iRecEfe + iRecMix;
                    LET iRecCCT = iRecCCT + iRecCC;

                    LET deTotComision = deTotComision + deComision;
                    LET deTotIvaCom = deTotIvaCom + deIvaCom;


                    IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
                        LET iRecLun = iRecEfe + iRecCC + iRecMix;
                        LET deCobLun = deCobEfe + deCobCC + deCobMix;
                    END IF;
                    IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
                        LET iRecMar = iRecEfe + iRecCC + iRecMix;
                        LET deCobMar = deCobEfe + deCobCC + deCobMix;
                    END IF;
                    IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
                        LET iRecMie = iRecEfe + iRecCC + iRecMix;
                        LET deCobMie = deCobEfe + deCobCC + deCobMix;
                    END IF;
                    IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
                        LET iRecJue = iRecEfe + iRecCC + iRecMix;
                        LET deCobJue = deCobEfe + deCobCC + deCobMix;
                    END IF;
                    IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
                        LET iRecVie = iRecEfe + iRecCC + iRecMix;
                        LET deCobVie = deCobEfe + deCobCC + deCobMix;
                    END IF;
                    IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
                        LET iRecSab = iRecEfe + iRecCC + iRecMix;
                        LET deCobSab = deCobEfe + deCobCC + deCobMix;
                    END IF;
                    IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
                        LET iRecDom = iRecEfe + iRecCC + iRecMix;
                        LET deCobDom = deCobEfe + deCobCC + deCobMix;
                    END IF;

                    LET dFechaAux = dFechaAux + 1;

                END WHILE;

                INSERT INTO bdisac:"informix".sac_liquidacionesTelmex (rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo,
                                                                cob_lunes, cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo,
                                                                rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred,
                                                                cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred,
                                                                liq_miercoles, liq_jueves, liq_viernes,liq_lunes, liq_martes,
                                                                aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, fecha_insert)
                VALUES(iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom,
                       deCobLun, deCobMar, deCobMie, deCobJue, deCobVie, deCobSab, deCobDom,
                       iRecEfeT, iRecCCT, 0, 0,
                       deCobEfeT, deCobCCT, 0, 0,
                       deCobLun, deCobMar, deCobMie, deCobJue, deCobVie + deCobSab + deCobDom,
                       0, deTotComision, deTotIvaCom, dFechaIni,dfecha_Hoy, CURRENT);
					   
	            INSERT INTO bdisac:"informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo,
																	  cob_lunes, cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo,
																	  rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred,
																	  cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred,
																	  liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,
																	  aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
               VALUES(cId_Convenio,iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom,
                       deCobLun, deCobMar, deCobMie, deCobJue, deCobVie, deCobSab, deCobDom,
                       iRecEfeT, iRecCCT, 0, 0,
                       deCobEfeT, deCobCCT, 0, 0,
                       deCobLun, deCobMar, deCobMie, deCobJue, deCobVie + deCobSab + deCobDom,
	                    0, deTotComision, deTotIvaCom, dFechaIni,dfecha_Hoy, 0, (SELECT NVL(MAX(consecutivo_convenio + 1 ),1) FROM bdisac:"informix".sac_liquidacionsemanal WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
					   
        END IF;

        IF dfecha_Hoy = dUltDiaMes  THEN
            LET dFechaAux = dPriDiaMes;
            LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

            WHILE dFechaAux <= dfecha_Hoy
				
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT 
						NVL(importe_comision_convenio,0), 
						NVL(iva_comision_convenio,0),
						flag_confirmacion_central, 
						flag_confirmacion_sucursal,
						folio_suc
					INTO 
						mComisionAux, 
						mIvaComAux,
						iFlagCen,
						iFlagSuc,
						cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)
					
					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								LET iNumOpe = iNumOpe + 1;
							END IF;
						ELSE
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							LET iNumOpe = iNumOpe + 1;
						END IF;
					ELSE
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						LET iNumOpe = iNumOpe + 1;
					END IF;
					
				END FOREACH;
				

				INSERT INTO bdisac:"informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);
				
				LET dFechaAux = dFechaAux + 1;
            END WHILE;

        END IF;

	    IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
		    LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;
		
	    UPDATE bdisac:"informix".sac_controlreportesespeciales
	    SET retorno = cCodret
	    WHERE numcategoria = cCategoria
	    AND numconvenio = cConvenio;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : José Angel López Adams',
'DESCRIPCION: Se encarga calcular totales de captacion de pagos de recibos telmex, siempre y cuando el dia en que se ejecute sea domingo.',
'             Genera, además, los totales filtrando la forma de pago. Tambien calcula los montos de las liquidaciones hechas a Telmex, atendiendo ',
'             las caracteristicas de las mismas solicitadas por la misma empresa ',
'EQUIPO DE TRABAJO: Sucursales',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual a su vez es llamado de sp_ProcesoCierreSAC()',
'FECHA : 05 Octubre de 2008',
'VERSION: 20081005.1250',
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------',
'Folio:1576',
'Autor:95142134 Mario Gallardo',
'Fecha:15/01/2014',
'Modificación: Se modifica procedimiento para que guarde iformacion en las tablas homologadas y propias sac_liquidacionmensual y sac_liquidacionsemanal.',
'Sustento: RQI 62 078-Optimización Reportes SAC.doc -  (Pagina 2 a 3)',
'Solicita: Jaime Gonzalez',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_reporteliquidacionsolfi (pConvenio CHAR(6))

--DEFINICION DE VARIABLES
	DEFINE cCodret           CHAR(5);
	DEFINE cCodRet2          CHAR(5);
	DEFINE cAnioMes          CHAR(6);
	DEFINE cInfoErr          CHAR(100);
	DEFINE cCategoria        CHAR(2);
	DEFINE cConvenio         CHAR(3);
	DEFINE cFechaLiq         CHAR(10);
	DEFINE iSqlErr           INTEGER;
	DEFINE iIsamErr          INTEGER;
	DEFINE iRecEfe           INTEGER;
	DEFINE iRecEfeAux        CHAR(16);
	DEFINE iRecCC            INTEGER;
	DEFINE iRecCCAux         CHAR(16);
	DEFINE iRecMix           INTEGER;
	DEFINE iRecEfeT          INTEGER;
	DEFINE iRecCCT           INTEGER;
	DEFINE iRecMixT          INTEGER;
	DEFINE iRecTot           INTEGER;
	DEFINE iRecAux           INTEGER;
	DEFINE iRecLun           INTEGER;
	DEFINE iRecMAr           INTEGER;
	DEFINE iRecMie           INTEGER;
	DEFINE iRecJue           INTEGER;
	DEFINE iRecVie           INTEGER;
	DEFINE iRecSab           INTEGER;
	DEFINE iRecDom           INTEGER;
	DEFINE iNumOpe           INTEGER;
	DEFINE iDias             INTEGER;
	DEFINE mLiqlun           MONEY(16,2);
	DEFINE mLiqMar           MONEY(16,2);
	DEFINE mLiqMier          MONEY(16,2);
	DEFINE mLiqJue           MONEY(16,2);
	DEFINE mLiqVie           MONEY(16,2);
	DEFINE mLiqResguardo     MONEY(16,2);
	DEFINE mCobEfe           MONEY(16,2);
	DEFINE mCobEfeAux        MONEY(16,2);
	DEFINE mCobMix           MONEY(16,2);
	DEFINE mCobCC            MONEY(16,2);
	DEFINE mCobCCAux         MONEY(16,2);
	DEFINE mCobEfeT          MONEY(16,2);
	DEFINE mCobMixT          MONEY(16,2);
	DEFINE mCobCCT           MONEY(16,2);
	DEFINE mCobTot           MONEY(16,2);
	DEFINE mCobAux           MONEY(16,2);
	DEFINE mCobLun           MONEY(16,2);
	DEFINE mCobMar           MONEY(16,2);
	DEFINE mCobMie           MONEY(16,2);
	DEFINE mCobJue           MONEY(16,2);
	DEFINE mCobVie           MONEY(16,2);
	DEFINE mCobSab           MONEY(16,2);
	DEFINE mCobDom           MONEY(16,2);
	DEFINE mTotComision      MONEY(16,2);
	DEFINE mTotIvaCom        MONEY(16,2);
	DEFINE mComision         MONEY(16,2);
	DEFINE mComisionAux      MONEY(16,2);
	DEFINE mIvaCom           MONEY(16,2);
	DEFINE mIvaComAux        MONEY(16,2);
	DEFINE mAcumulado        MONEY(16,2);
	DEFINE dFechaAux         DATE;
	DEFINE dfecha_Hoy        DATE;
	DEFINE dFechaIni         DATE;
	DEFINE dPriDiaMes        DATE;
	DEFINE dUltDiaMes        DATE;
	DEFINE iFlagCen          INTEGER;
	DEFINE iFlagSuc          INTEGER;
	DEFINE cFolio            CHAR(16);
	DEFINE iCuantos          INTEGER;

--INICIALIZACION DE VARIABLES
	LET cCodRet2       = "00000";
	LET cCodret        = "000000";
	LET cInfoErr       = '';
	LET cAnioMes       = '';
	LET mCobEfe        = 0;
	LET mCobEfeAux     = 0;
	LET mCobCC         = 0;
	LET mCobCCAux      = 0;
	LET mCobMix        = 0;
	LET iRecEfe        = 0;
	LET iRecEfeAux     = '';
	LET iRecCC         = 0;
	LET iRecCCAux      = '';
	LET iRecMix        = 0;
	LET mComision      = 0;
	LET mComisionAux   = 0;
	LET mIvaCom        = 0;
	LET mIvaComAux     = 0;
	LET mCobEfeT       = 0;
	LET mCobCCT        = 0;
	LET iRecEfeT       = 0;
	LET iRecCCT        = 0;
	LET mTotComision   = 0;
	LET mTotIvaCom     = 0;
	LET iRecLun        = 0;
	LET mCobLun        = 0;
	LET iRecMar        = 0;
	LET mCobMar        = 0;
	LET iRecMie        = 0;
	LET mCobMie        = 0;
	LET iRecJue        = 0;
	LET mCobJue        = 0;
	LET iRecVie        = 0;
	LET mCobVie        = 0;
	LET iRecSab        = 0;
	LET mCobSab        = 0;
	LET iRecDom        = 0;
	LET mCobDom        = 0;
	LET cCategoria     = SUBSTRING(pConvenio FROM 1 FOR 2);
	LET cConvenio      = SUBSTRING(pConvenio FROM 3 FOR 3);
	LET dFechaAux      = '';
	LET dfecha_Hoy     = '';
	LET dFechaIni      = '';
	LET dPriDiaMes	   = '';
	LET dUltDiaMes	   = '';
	LET iNumOpe	       = 0;
	LET mLiqlun        = 0;
	LET mLiqMar        = 0;
	LET mLiqMier       = 0;
	LET mLiqJue        = 0;
	LET mLiqVie        = 0;
	LET cFechaLiq      = "";
	LET mLiqResguardo  = 0;
	LET mAcumulado     = 0;
	LET iFlagCen       = 0; 
	LET iFlagSuc       = 0;
	LET cFolio         = '';
	LET iCuantos	   = 0;


		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/respaldosbd/isarai/sp_reporteliquidacionsolfi.out';
		--TRACE ON;
	

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;

				UPDATE "informix".sac_controlreportesespeciales
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio;

				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacionsolfi");
			END IF;
		END EXCEPTION;
			
		SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
		INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
		FROM "informix".sac_fechas;	
		
		IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN
		
			LET dFechaAux = dfecha_Hoy - 6;
			LET dFechaIni = dFechaAux;
		
			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM "informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
										FROM "informix".sac_liquidacionsemanal
										WHERE id_convenio = cCategoria||cConvenio
										AND consecutivo_convenio <> 0);


			IF 	mAcumulado IS NULL THEN
				LET mAcumulado = 0;
			END IF;
		
			WHILE dFechaAux <= dfecha_Hoy
				
				LET mCobEfe = 0.00;
				LET mCobCC = 0.00;
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iRecEfe = 0;
				LET iRecCC = 0;
				
				FOREACH
					SELECT 
							NVL(efe,0), 
							NVL(cc,0), 
							NVL(Rec1,''),
							NVL(Rec2,""), 
							NVL(comision, 0), 
							NVL(iva_com,0),
							flag_confirmacion_central, 
							flag_confirmacion_sucursal, 
							folio_suc
					INTO 
							mCobEfeAux, 
							mCobCCAux, 
							iRecEfeAux, 
							iRecCCAux, 
							mComisionAux, 
							mIvaComAux,
							iFlagCen,
							iFlagSuc,
							cFolio
					FROM TABLE(
						MULTISET(
							SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
									CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
									CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
									CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
									CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
									flag_confirmacion_central, 
									flag_confirmacion_sucursal, 
									folio_suc
							FROM "informix".sac_movimientoshistorial
							WHERE numcategoria = cCategoria
							AND numconvenio = cConvenio
							AND fecha_pago  = dFechaAux
							AND status_cancelado = 'N'
							AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)))
							
					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mCobEfe = mCobEfe + mCobEfeAux;
								LET mCobCC = mCobCC + mCobCCAux;
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
									LET iRecEfe = iRecEfe +1;
								END IF;
								IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
									LET iRecCC = iRecCC +1;
								END IF;
							END IF;
						ELSE
							LET mCobEfe = mCobEfe + mCobEfeAux;
							LET mCobCC = mCobCC + mCobCCAux;
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
								LET iRecEfe = iRecEfe +1;
							END IF;
							IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
								LET iRecCC = iRecCC +1;
							END IF;
						END IF;
					ELSE
						LET mCobEfe = mCobEfe + mCobEfeAux;
						LET mCobCC = mCobCC + mCobCCAux;
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
							LET iRecEfe = iRecEfe +1;
						END IF;
						IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
							LET iRecCC = iRecCC +1;
						END IF;
					END IF;
				END FOREACH;

				LET mCobEfeT = mCobEfeT + mCobEfe; 
                LET mCobCCT = mCobCCT + mCobCC;
				
                LET iRecEfeT = iRecEfeT + iRecEfe ;
                LET iRecCCT = iRecCCT + iRecCC;

                LET mTotComision = mTotComision + mComision;
                LET mTotIvaCom = mTotIvaCom + mIvaCom;


				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

	                IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
						 LET iRecLun = iRecEfe + iRecCC ;
						LET mCobLun = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;


	                IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
						LET iRecMar = iRecEfe + iRecCC ;
						LET mCobMar = mCobEfe + mCobCC ;

					    IF iDias = 1 THEN
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
	                END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
						LET iRecMie = iRecEfe + iRecCC ;
						LET mCobMie = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
	                END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC ;
						LET mCobJue = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC ;
						LET mCobVie = mCobEfe + mCobCC ;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC ;
						LET mCobSab = mCobEfe + mCobCC ;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC ;
						LET mCobDom = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqlun =  mLiqlun + mCobDom;

							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

	                LET dFechaAux = dFechaAux + 1;

				END IF;
	        END WHILE;

			IF cCodRet2::INTEGER = 0 THEN

				INSERT INTO "informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, 				rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, 			 cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, 			   rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, cob_efectivo, 
							  cob_cheqmb,cob_cheqob, cob_tarcred, liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
				VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom, mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,iRecEfeT, iRecCCT,0, 0,  mCobEfeT, mCobCCT, 0, 0,mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,0,mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo,
					  (SELECT NVL(MAX(consecutivo_convenio + 1 ),1) FROM "informix".sac_liquidacionsemanal
					   WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
		END IF;

		IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
			LET dFechaAux = dPriDiaMes;
			LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

			WHILE dFechaAux <= dfecha_Hoy
				
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT NVL(importe_comision_convenio,0),NVL(iva_comision_convenio,0),
						flag_confirmacion_central, flag_confirmacion_sucursal,folio_suc
					INTO mComisionAux, mIvaComAux,iFlagCen,iFlagSuc,cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)
					
					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia 
						WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis 
							WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								LET iNumOpe = iNumOpe + 1;
							END IF;
						ELSE
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							LET iNumOpe = iNumOpe + 1;
						END IF;
					ELSE
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						LET iNumOpe = iNumOpe + 1;
					END IF;
					
				END FOREACH;
				
				INSERT INTO "informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;
			END WHILE;

		END IF;

		IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
			LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;
		
		UPDATE "informix".sac_controlreportesespeciales
		SET retorno = cCodret
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE
DOCUMENT
'AUTOR : Isarai Bojorquez',
'DESCRIPCIÓN: Genera la información para los Reportes Semanal y Mensual de Pagos referenciados (SOLFI)',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de p_ProcesoCierreSAC()',
'FECHA : 23-04-2014',
'VERSIÓN: 20140423.1218',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidacioncarnival(pConvenio CHAR(5))

--DEFINICION DE VARIABLES
DEFINE cCodret           CHAR(5);
DEFINE cCodRet2          CHAR(5);
DEFINE cAnioMes          CHAR(6);
DEFINE cInfoErr          CHAR(100);
DEFINE cCategoria        CHAR(2);
DEFINE cConvenio         CHAR(3);
DEFINE cFechaLiq         CHAR(10);
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE iRecEfe           INTEGER;
DEFINE iRecEfeAux        CHAR(16);
DEFINE iRecCC            INTEGER;
DEFINE iRecCCAux         CHAR(16);
DEFINE iRecMix           INTEGER;
DEFINE iRecEfeT          INTEGER;
DEFINE iRecCCT           INTEGER;
DEFINE iRecMixT          INTEGER;
DEFINE iRecTot           INTEGER;
DEFINE iRecAux           INTEGER;
DEFINE iRecLun           INTEGER;
DEFINE iRecMAr           INTEGER;
DEFINE iRecMie           INTEGER;
DEFINE iRecJue           INTEGER;
DEFINE iRecVie           INTEGER;
DEFINE iRecSab           INTEGER;
DEFINE iRecDom           INTEGER;
DEFINE iNumOpe           INTEGER;
DEFINE iDias             INTEGER;
DEFINE mLiqlun           MONEY(16,2);
DEFINE mLiqMar           MONEY(16,2);
DEFINE mLiqMier          MONEY(16,2);
DEFINE mLiqJue           MONEY(16,2);
DEFINE mLiqVie           MONEY(16,2);
DEFINE mLiqResguardo     MONEY(16,2);
DEFINE mCobEfe           MONEY(16,2);
DEFINE mCobEfeAux        MONEY(16,2);
DEFINE mCobMix           MONEY(16,2);
DEFINE mCobCC            MONEY(16,2);
DEFINE mCobCCAux         MONEY(16,2);
DEFINE mCobEfeT          MONEY(16,2);
DEFINE mCobMixT          MONEY(16,2);
DEFINE mCobCCT           MONEY(16,2);
DEFINE mCobTot           MONEY(16,2);
DEFINE mCobAux           MONEY(16,2);
DEFINE mCobLun           MONEY(16,2);
DEFINE mCobMar           MONEY(16,2);
DEFINE mCobMie           MONEY(16,2);
DEFINE mCobJue           MONEY(16,2);
DEFINE mCobVie           MONEY(16,2);
DEFINE mCobSab           MONEY(16,2);
DEFINE mCobDom           MONEY(16,2);
DEFINE mTotComision      MONEY(16,2);
DEFINE mTotIvaCom        MONEY(16,2);
DEFINE mComision         MONEY(16,2);
DEFINE mComisionAux      MONEY(16,2);
DEFINE mIvaCom           MONEY(16,2);
DEFINE mIvaComAux        MONEY(16,2);
DEFINE mAcumulado        MONEY(16,2);
DEFINE dFechaAux         DATE;
DEFINE dfecha_Hoy        DATE;
DEFINE dFechaIni         DATE;
DEFINE dPriDiaMes        DATE;
DEFINE dUltDiaMes        DATE;
DEFINE iFlagCen          INTEGER;
DEFINE iFlagSuc          INTEGER;
DEFINE cFolio            CHAR(16);
DEFINE iCuantos          INTEGER;

--INICIALIZACION DE VARIABLES
LET cCodRet2	= "00000";
LET cCodret		= "000000";
LET cInfoErr	= '';
LET cAnioMes	= '';
LET mCobEfe		= 0;
LET mCobEfeAux	= 0;
LET mCobCC		= 0;
LET mCobCCAux	= 0;
LET mCobMix		= 0;
LET iRecEfe		= 0;
LET iRecEfeAux	= '';
LET iRecCC		= 0;
LET iRecCCAux	= '';
LET iRecMix		= 0;
LET mComision	= 0;
LET mComisionAux	= 0;
LET mIvaCom		= 0;
LET mIvaComAux	= 0;
LET mCobEfeT	= 0;
LET mCobCCT		= 0;
LET iRecEfeT	= 0;
LET iRecCCT		= 0;
LET mTotComision	= 0;
LET mTotIvaCom	= 0;
LET iRecLun		= 0;
LET mCobLun		= 0;
LET iRecMar		= 0;
LET mCobMar		= 0;
LET iRecMie		= 0;
LET mCobMie		= 0;
LET iRecJue		= 0;
LET mCobJue		= 0;
LET iRecVie		= 0;
LET mCobVie		= 0;
LET iRecSab		= 0;
LET mCobSab		= 0;
LET iRecDom		= 0;
LET mCobDom		= 0;
LET cCategoria	= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio	= SUBSTRING(pConvenio FROM 3 FOR 3);
LET dFechaAux	= '';
LET dfecha_Hoy	= '';
LET dFechaIni	= '';
LET dPriDiaMes	= '';
LET dUltDiaMes	= '';
LET iNumOpe		= 0;
LET mLiqlun		= 0;
LET mLiqMar		= 0;
LET mLiqMier	= 0;
LET mLiqJue		= 0;
LET mLiqVie		= 0;
LET cFechaLiq	= "";
LET mLiqResguardo	= 0;
LET mAcumulado	= 0;
LET iFlagCen	= 0;
LET iFlagSuc	= 0;
LET cFolio		= '';
LET iCuantos	= 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/respaldosbd/hugovaz/sp_reporteliquidacioncarnival.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlreportesespeciales
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio;
				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacioncarnival");
			END IF;
		END EXCEPTION;

		SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
		INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
		FROM "informix".sac_fechas;

		IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

			LET dFechaAux = dfecha_Hoy - 6;
			LET dFechaIni = dFechaAux;

			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM "informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
								FROM "informix".sac_liquidacionsemanal
								WHERE id_convenio = cCategoria||cConvenio
								AND consecutivo_convenio <> 0);

			IF mAcumulado IS NULL THEN
				LET mAcumulado = 0;
			END IF;
			
			WHILE dFechaAux <= dfecha_Hoy

				LET mCobEfe = 0.00;
				LET mCobCC = 0.00;
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iRecEfe = 0;
				LET iRecCC = 0;

				FOREACH
					SELECT
						NVL(efe,0),
						NVL(cc,0),
						NVL(Rec1,''),
						NVL(Rec2,""),
						NVL(comision, 0),
						NVL(iva_com,0),
						flag_confirmacion_central,
						flag_confirmacion_sucursal,
						folio_suc
					INTO
						mCobEfeAux,
						mCobCCAux,
						iRecEfeAux,
						iRecCCAux,
						mComisionAux,
						mIvaComAux,
						iFlagCen,
						iFlagSuc,
						cFolio
					FROM TABLE(
						MULTISET(
							SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
									CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
									CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
									CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
									CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
									flag_confirmacion_central,
									flag_confirmacion_sucursal,
									folio_suc
							FROM "informix".sac_movimientoshistorial
							WHERE numcategoria = cCategoria
							AND numconvenio = cConvenio
							AND fecha_pago  = dFechaAux
							AND status_cancelado = 'N'
							AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)))

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mCobEfe = mCobEfe + mCobEfeAux;
								LET mCobCC = mCobCC + mCobCCAux;
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
									LET iRecEfe = iRecEfe +1;
								END IF;
								IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
									LET iRecCC = iRecCC +1;
								END IF;
							END IF;
						ELSE
							LET mCobEfe = mCobEfe + mCobEfeAux;
							LET mCobCC = mCobCC + mCobCCAux;
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
								LET iRecEfe = iRecEfe +1;
							END IF;
							IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
								LET iRecCC = iRecCC +1;
							END IF;
						END IF;
					ELSE
						LET mCobEfe = mCobEfe + mCobEfeAux;
						LET mCobCC = mCobCC + mCobCCAux;
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
							LET iRecEfe = iRecEfe +1;
						END IF;
						IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
							LET iRecCC = iRecCC +1;
						END IF;
					END IF;
				END FOREACH;

				LET mCobEfeT = mCobEfeT + mCobEfe;
				LET mCobCCT = mCobCCT + mCobCC;
				LET iRecEfeT = iRecEfeT + iRecEfe ;
				LET iRecCCT = iRecCCT + iRecCC;
				LET mTotComision = mTotComision + mComision;
				LET mTotIvaCom = mTotIvaCom + mIvaCom;

				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

					IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
						LET iRecLun = iRecEfe + iRecCC ;
						LET mCobLun = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;


					IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
						LET iRecMar = iRecEfe + iRecCC ;
						LET mCobMar = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
						LET iRecMie = iRecEfe + iRecCC ;
						LET mCobMie = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC ;
						LET mCobJue = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC ;
						LET mCobVie = mCobEfe + mCobCC ;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC ;
						LET mCobSab = mCobEfe + mCobCC ;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC ;
						LET mCobDom = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqlun =  mLiqlun + mCobDom;

							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

				LET dFechaAux = dFechaAux + 1;

				END IF;
			END WHILE;

			IF cCodRet2::INTEGER = 0 THEN

				INSERT INTO "informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, 				rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, 			 cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, 			   rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, cob_efectivo,
							  cob_cheqmb,cob_cheqob, cob_tarcred, liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
				VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom, mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,iRecEfeT, iRecCCT,0, 0,  mCobEfeT, mCobCCT, 0, 0,mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,0,mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo,
					  (SELECT NVL(MAX(consecutivo_convenio + 1 ),1) FROM "informix".sac_liquidacionsemanal
					   WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
		END IF;

		IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
			LET dFechaAux = dPriDiaMes;
			LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

			WHILE dFechaAux <= dfecha_Hoy

				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT NVL(importe_comision_convenio,0),NVL(iva_comision_convenio,0),
						flag_confirmacion_central, flag_confirmacion_sucursal,folio_suc
					INTO mComisionAux, mIvaComAux,iFlagCen,iFlagSuc,cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia
						WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis
							WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								LET iNumOpe = iNumOpe + 1;
							END IF;
						ELSE
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							LET iNumOpe = iNumOpe + 1;
						END IF;
					ELSE
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						LET iNumOpe = iNumOpe + 1;
					END IF;

				END FOREACH;

				INSERT INTO "informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;
			END WHILE;

		END IF;

		IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
			LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;

		UPDATE "informix".sac_controlreportesespeciales
		SET retorno = cCodret
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE
DOCUMENT
'AUTOR: Vazquez Herrera Hugo',
'DESCRIPCIÓN: Genera la información para los Reportes Semanal y Mensual de Pagos referenciados (CARNIVAL)',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de p_ProcesoCierreSAC()',
'FECHA: 25-06-2014',
'VERSIÓN: 20140625.1218',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidacionstanhome(pConvenio CHAR(5))

--DEFINICION DE VARIABLES
DEFINE cCodret           CHAR(5);
DEFINE cCodRet2          CHAR(5);
DEFINE cAnioMes          CHAR(6);
DEFINE cInfoErr          CHAR(100);
DEFINE cCategoria        CHAR(2);
DEFINE cConvenio         CHAR(3);
DEFINE cFechaLiq         CHAR(10);
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE iRecEfe           INTEGER;
DEFINE iRecEfeAux        CHAR(16);
DEFINE iRecCC            INTEGER;
DEFINE iRecCCAux         CHAR(16);
DEFINE iRecMix           INTEGER;
DEFINE iRecEfeT          INTEGER;
DEFINE iRecCCT           INTEGER;
DEFINE iRecMixT          INTEGER;
DEFINE iRecTot           INTEGER;
DEFINE iRecAux           INTEGER;
DEFINE iRecLun           INTEGER;
DEFINE iRecMAr           INTEGER;
DEFINE iRecMie           INTEGER;
DEFINE iRecJue           INTEGER;
DEFINE iRecVie           INTEGER;
DEFINE iRecSab           INTEGER;
DEFINE iRecDom           INTEGER;
DEFINE iNumOpe           INTEGER;
DEFINE iDias             INTEGER;
DEFINE mLiqlun           MONEY(16,2);
DEFINE mLiqMar           MONEY(16,2);
DEFINE mLiqMier          MONEY(16,2);
DEFINE mLiqJue           MONEY(16,2);
DEFINE mLiqVie           MONEY(16,2);
DEFINE mLiqResguardo     MONEY(16,2);
DEFINE mCobEfe           MONEY(16,2);
DEFINE mCobEfeAux        MONEY(16,2);
DEFINE mCobMix           MONEY(16,2);
DEFINE mCobCC            MONEY(16,2);
DEFINE mCobCCAux         MONEY(16,2);
DEFINE mCobEfeT          MONEY(16,2);
DEFINE mCobMixT          MONEY(16,2);
DEFINE mCobCCT           MONEY(16,2);
DEFINE mCobTot           MONEY(16,2);
DEFINE mCobAux           MONEY(16,2);
DEFINE mCobLun           MONEY(16,2);
DEFINE mCobMar           MONEY(16,2);
DEFINE mCobMie           MONEY(16,2);
DEFINE mCobJue           MONEY(16,2);
DEFINE mCobVie           MONEY(16,2);
DEFINE mCobSab           MONEY(16,2);
DEFINE mCobDom           MONEY(16,2);
DEFINE mTotComision      MONEY(16,2);
DEFINE mTotIvaCom        MONEY(16,2);
DEFINE mComision         MONEY(16,2);
DEFINE mComisionAux      MONEY(16,2);
DEFINE mIvaCom           MONEY(16,2);
DEFINE mIvaComAux        MONEY(16,2);
DEFINE mAcumulado        MONEY(16,2);
DEFINE dFechaAux         DATE;
DEFINE dfecha_Hoy        DATE;
DEFINE dFechaIni         DATE;
DEFINE dPriDiaMes        DATE;
DEFINE dUltDiaMes        DATE;
DEFINE iFlagCen          INTEGER;
DEFINE iFlagSuc          INTEGER;
DEFINE cFolio            CHAR(16);
DEFINE iCuantos          INTEGER;

--INICIALIZACION DE VARIABLES
LET cCodRet2	= "00000";
LET cCodret		= "000000";
LET cInfoErr	= '';
LET cAnioMes	= '';
LET mCobEfe		= 0;
LET mCobEfeAux	= 0;
LET mCobCC		= 0;
LET mCobCCAux	= 0;
LET mCobMix		= 0;
LET iRecEfe		= 0;
LET iRecEfeAux	= '';
LET iRecCC		= 0;
LET iRecCCAux	= '';
LET iRecMix		= 0;
LET mComision	= 0;
LET mComisionAux	= 0;
LET mIvaCom		= 0;
LET mIvaComAux	= 0;
LET mCobEfeT	= 0;
LET mCobCCT		= 0;
LET iRecEfeT	= 0;
LET iRecCCT		= 0;
LET mTotComision	= 0;
LET mTotIvaCom	= 0;
LET iRecLun		= 0;
LET mCobLun		= 0;
LET iRecMar		= 0;
LET mCobMar		= 0;
LET iRecMie		= 0;
LET mCobMie		= 0;
LET iRecJue		= 0;
LET mCobJue		= 0;
LET iRecVie		= 0;
LET mCobVie		= 0;
LET iRecSab		= 0;
LET mCobSab		= 0;
LET iRecDom		= 0;
LET mCobDom		= 0;
LET cCategoria	= SUBSTRING(pConvenio FROM 1 FOR 2);  --09
LET cConvenio	= SUBSTRING(pConvenio FROM 3 FOR 3);  --009
LET dFechaAux	= '';
LET dfecha_Hoy	= '';
LET dFechaIni	= '';
LET dPriDiaMes	= '';
LET dUltDiaMes	= '';
LET iNumOpe		= 0;
LET mLiqlun		= 0;
LET mLiqMar		= 0;
LET mLiqMier	= 0;
LET mLiqJue		= 0;
LET mLiqVie		= 0;
LET cFechaLiq	= "";
LET mLiqResguardo	= 0;
LET mAcumulado	= 0;
LET iFlagCen	= 0;
LET iFlagSuc	= 0;
LET cFolio		= '';
LET iCuantos	= 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
--	SET DEBUG FILE TO '/respaldosbd/hugovaz/sp_reporteliquidacionstanhome.out';
--	TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlreportesespeciales
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio;
				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacionstanhome");
			END IF;
		END EXCEPTION;

		SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
		INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
		FROM "informix".sac_fechas;

		IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

			LET dFechaAux = dfecha_Hoy - 6;
			LET dFechaIni = dFechaAux;

			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM "informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
								FROM "informix".sac_liquidacionsemanal
								WHERE id_convenio = cCategoria||cConvenio
								AND consecutivo_convenio <> 0);

			IF mAcumulado IS NULL THEN
				LET mAcumulado = 0;
			END IF;
			
			WHILE dFechaAux <= dfecha_Hoy

				LET mCobEfe = 0.00;
				LET mCobCC = 0.00;
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iRecEfe = 0;
				LET iRecCC = 0;

				FOREACH
					SELECT
						NVL(efe,0),
						NVL(cc,0),
						NVL(Rec1,''),
						NVL(Rec2,""),
						NVL(comision, 0),
						NVL(iva_com,0),
						flag_confirmacion_central,
						flag_confirmacion_sucursal,
						folio_suc
					INTO
						mCobEfeAux,
						mCobCCAux,
						iRecEfeAux,
						iRecCCAux,
						mComisionAux,
						mIvaComAux,
						iFlagCen,
						iFlagSuc,
						cFolio
					FROM TABLE(
						MULTISET(
							SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
									CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
									CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
									CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
									CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
									flag_confirmacion_central,
									flag_confirmacion_sucursal,
									folio_suc
							FROM "informix".sac_movimientoshistorial
							WHERE numcategoria = cCategoria
							AND numconvenio = cConvenio
							AND fecha_pago  = dFechaAux
							AND status_cancelado = 'N'
							AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)))

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mCobEfe = mCobEfe + mCobEfeAux;
								LET mCobCC = mCobCC + mCobCCAux;
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
									LET iRecEfe = iRecEfe +1;
								END IF;
								IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
									LET iRecCC = iRecCC +1;
								END IF;
							END IF;
						ELSE
							LET mCobEfe = mCobEfe + mCobEfeAux;
							LET mCobCC = mCobCC + mCobCCAux;
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
								LET iRecEfe = iRecEfe +1;
							END IF;
							IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
								LET iRecCC = iRecCC +1;
							END IF;
						END IF;
					ELSE
						LET mCobEfe = mCobEfe + mCobEfeAux;
						LET mCobCC = mCobCC + mCobCCAux;
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
							LET iRecEfe = iRecEfe +1;
						END IF;
						IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
							LET iRecCC = iRecCC +1;
						END IF;
					END IF;
				END FOREACH;

				LET mCobEfeT = mCobEfeT + mCobEfe;
				LET mCobCCT = mCobCCT + mCobCC;
				LET iRecEfeT = iRecEfeT + iRecEfe ;
				LET iRecCCT = iRecCCT + iRecCC;
				LET mTotComision = mTotComision + mComision;
				LET mTotIvaCom = mTotIvaCom + mIvaCom;

				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

					IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
						LET iRecLun = iRecEfe + iRecCC ;
						LET mCobLun = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;


					IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
						LET iRecMar = iRecEfe + iRecCC ;
						LET mCobMar = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
						LET iRecMie = iRecEfe + iRecCC ;
						LET mCobMie = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC ;
						LET mCobJue = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC ;
						LET mCobVie = mCobEfe + mCobCC ;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC ;
						LET mCobSab = mCobEfe + mCobCC ;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC ;
						LET mCobDom = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqlun =  mLiqlun + mCobDom;

							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

				LET dFechaAux = dFechaAux + 1;

				END IF;
			END WHILE;

			IF cCodRet2::INTEGER = 0 THEN

				INSERT INTO "informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, 				rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, 			 cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, 			   rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, cob_efectivo,
							  cob_cheqmb,cob_cheqob, cob_tarcred, liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
				VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom, mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,iRecEfeT, iRecCCT,0, 0,  mCobEfeT, mCobCCT, 0, 0,mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,0,mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo,
					  (SELECT NVL(MAX(consecutivo_convenio + 1 ),1) FROM "informix".sac_liquidacionsemanal
					   WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
		END IF;

		IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
			LET dFechaAux = dPriDiaMes;
			LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

			WHILE dFechaAux <= dfecha_Hoy

				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT NVL(importe_comision_convenio,0),NVL(iva_comision_convenio,0),
						flag_confirmacion_central, flag_confirmacion_sucursal,folio_suc
					INTO mComisionAux, mIvaComAux,iFlagCen,iFlagSuc,cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia
						WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis
							WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								LET iNumOpe = iNumOpe + 1;
							END IF;
						ELSE
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							LET iNumOpe = iNumOpe + 1;
						END IF;
					ELSE
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						LET iNumOpe = iNumOpe + 1;
					END IF;

				END FOREACH;

				INSERT INTO "informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;
			END WHILE;

		END IF;

		IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
			LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;

		UPDATE "informix".sac_controlreportesespeciales
		SET retorno = cCodret
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE
DOCUMENT
'AUTOR: Vazquez Herrera Hugo Guadalupe ',
'DESCRIPCIÓN: Genera la información para los Reportes Semanal y Mensual de Pagos referenciados (STAN HOME)',
'SUSTENTO:  ',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de p_ProcesoCierreSAC()',
'FECHA: 15/08/2014',
'VERSIÓN: 201415081433',
'Solicita: Leonardo Hernandez',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidacionyvesroche(pConvenio CHAR(5))
--DEFINICION DE VARIABLES
DEFINE cCodret           CHAR(5);
DEFINE cCodRet2          CHAR(5);
DEFINE cAnioMes          CHAR(6);
DEFINE cInfoErr          CHAR(100);
DEFINE cCategoria        CHAR(2);
DEFINE cConvenio         CHAR(3);
DEFINE cFechaLiq         CHAR(10);
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE iRecEfe           INTEGER;
DEFINE iRecEfeAux        CHAR(16);
DEFINE iRecCC            INTEGER;
DEFINE iRecCCAux         CHAR(16);
DEFINE iRecMix           INTEGER;
DEFINE iRecEfeT          INTEGER;
DEFINE iRecCCT           INTEGER;
DEFINE iRecMixT          INTEGER;
DEFINE iRecTot           INTEGER;
DEFINE iRecAux           INTEGER;
DEFINE iRecLun           INTEGER;
DEFINE iRecMAr           INTEGER;
DEFINE iRecMie           INTEGER;
DEFINE iRecJue           INTEGER;
DEFINE iRecVie           INTEGER;
DEFINE iRecSab           INTEGER;
DEFINE iRecDom           INTEGER;
DEFINE iNumOpe           INTEGER;
DEFINE iDias             INTEGER;
DEFINE mLiqlun           MONEY(16,2);
DEFINE mLiqMar           MONEY(16,2);
DEFINE mLiqMier          MONEY(16,2);
DEFINE mLiqJue           MONEY(16,2);
DEFINE mLiqVie           MONEY(16,2);
DEFINE mLiqResguardo     MONEY(16,2);
DEFINE mCobEfe           MONEY(16,2);
DEFINE mCobEfeAux        MONEY(16,2);
DEFINE mCobMix           MONEY(16,2);
DEFINE mCobCC            MONEY(16,2);
DEFINE mCobCCAux         MONEY(16,2);
DEFINE mCobEfeT          MONEY(16,2);
DEFINE mCobMixT          MONEY(16,2);
DEFINE mCobCCT           MONEY(16,2);
DEFINE mCobTot           MONEY(16,2);
DEFINE mCobAux           MONEY(16,2);
DEFINE mCobLun           MONEY(16,2);
DEFINE mCobMar           MONEY(16,2);
DEFINE mCobMie           MONEY(16,2);
DEFINE mCobJue           MONEY(16,2);
DEFINE mCobVie           MONEY(16,2);
DEFINE mCobSab           MONEY(16,2);
DEFINE mCobDom           MONEY(16,2);
DEFINE mTotComision      MONEY(16,2);
DEFINE mTotIvaCom        MONEY(16,2);
DEFINE mComision         MONEY(16,2);
DEFINE mComisionAux      MONEY(16,2);
DEFINE mIvaCom           MONEY(16,2);
DEFINE mIvaComAux        MONEY(16,2);
DEFINE mAcumulado        MONEY(16,2);
DEFINE dFechaAux         DATE;
DEFINE dfecha_Hoy        DATE;
DEFINE dFechaIni         DATE;
DEFINE dPriDiaMes        DATE;
DEFINE dUltDiaMes        DATE;
DEFINE iFlagCen          INTEGER;
DEFINE iFlagSuc          INTEGER;
DEFINE cFolio            CHAR(16);
DEFINE iCuantos          INTEGER;

--INICIALIZACION DE VARIABLES
LET cCodRet2	= "00000";
LET cCodret		= "000000";
LET cInfoErr	= '';
LET cAnioMes	= '';
LET mCobEfe		= 0;
LET mCobEfeAux	= 0;
LET mCobCC		= 0;
LET mCobCCAux	= 0;
LET mCobMix		= 0;
LET iRecEfe		= 0;
LET iRecEfeAux	= '';
LET iRecCC		= 0;
LET iRecCCAux	= '';
LET iRecMix		= 0;
LET mComision	= 0;
LET mComisionAux	= 0;
LET mIvaCom		= 0;
LET mIvaComAux	= 0;
LET mCobEfeT	= 0;
LET mCobCCT		= 0;
LET iRecEfeT	= 0;
LET iRecCCT		= 0;
LET mTotComision	= 0;
LET mTotIvaCom	= 0;
LET iRecLun		= 0;
LET mCobLun		= 0;
LET iRecMar		= 0;
LET mCobMar		= 0;
LET iRecMie		= 0;
LET mCobMie		= 0;
LET iRecJue		= 0;
LET mCobJue		= 0;
LET iRecVie		= 0;
LET mCobVie		= 0;
LET iRecSab		= 0;
LET mCobSab		= 0;
LET iRecDom		= 0;
LET mCobDom		= 0;
LET cCategoria	= SUBSTRING(pConvenio FROM 1 FOR 2);  --09
LET cConvenio	= SUBSTRING(pConvenio FROM 3 FOR 3);  --009
LET dFechaAux	= '';
LET dfecha_Hoy	= '';
LET dFechaIni	= '';
LET dPriDiaMes	= '';
LET dUltDiaMes	= '';
LET iNumOpe		= 0;
LET mLiqlun		= 0;
LET mLiqMar		= 0;
LET mLiqMier	= 0;
LET mLiqJue		= 0;
LET mLiqVie		= 0;
LET cFechaLiq	= "";
LET mLiqResguardo	= 0;
LET mAcumulado	= 0;
LET iFlagCen	= 0;
LET iFlagSuc	= 0;
LET cFolio		= '';
LET iCuantos	= 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
--	SET DEBUG FILE TO '/respaldosbd/hugovaz/sp_reporteliquidacionyvesrocher.out';
--	TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlreportesespeciales
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio;
				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacionyvesrocher");
			END IF;
		END EXCEPTION;

		SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
		INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
		FROM "informix".sac_fechas;

		IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

			LET dFechaAux = dfecha_Hoy - 6;
			LET dFechaIni = dFechaAux;

			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM "informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
								FROM "informix".sac_liquidacionsemanal
								WHERE id_convenio = cCategoria||cConvenio
								AND consecutivo_convenio <> 0);

			IF mAcumulado IS NULL THEN
				LET mAcumulado = 0;
			END IF;
			
			WHILE dFechaAux <= dfecha_Hoy

				LET mCobEfe = 0.00;
				LET mCobCC = 0.00;
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iRecEfe = 0;
				LET iRecCC = 0;

				FOREACH
					SELECT
						NVL(efe,0),
						NVL(cc,0),
						NVL(Rec1,''),
						NVL(Rec2,""),
						NVL(comision, 0),
						NVL(iva_com,0),
						flag_confirmacion_central,
						flag_confirmacion_sucursal,
						folio_suc
					INTO
						mCobEfeAux,
						mCobCCAux,
						iRecEfeAux,
						iRecCCAux,
						mComisionAux,
						mIvaComAux,
						iFlagCen,
						iFlagSuc,
						cFolio
					FROM TABLE(
						MULTISET(
							SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
									CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
									CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
									CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
									CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
									flag_confirmacion_central,
									flag_confirmacion_sucursal,
									folio_suc
							FROM "informix".sac_movimientoshistorial
							WHERE numcategoria = cCategoria
							AND numconvenio = cConvenio
							AND fecha_pago  = dFechaAux
							AND status_cancelado = 'N'
							AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)))

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mCobEfe = mCobEfe + mCobEfeAux;
								LET mCobCC = mCobCC + mCobCCAux;
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
									LET iRecEfe = iRecEfe +1;
								END IF;
								IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
									LET iRecCC = iRecCC +1;
								END IF;
							END IF;
						ELSE
							LET mCobEfe = mCobEfe + mCobEfeAux;
							LET mCobCC = mCobCC + mCobCCAux;
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
								LET iRecEfe = iRecEfe +1;
							END IF;
							IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
								LET iRecCC = iRecCC +1;
							END IF;
						END IF;
					ELSE
						LET mCobEfe = mCobEfe + mCobEfeAux;
						LET mCobCC = mCobCC + mCobCCAux;
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
							LET iRecEfe = iRecEfe +1;
						END IF;
						IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
							LET iRecCC = iRecCC +1;
						END IF;
					END IF;
				END FOREACH;

				LET mCobEfeT = mCobEfeT + mCobEfe;
				LET mCobCCT = mCobCCT + mCobCC;
				LET iRecEfeT = iRecEfeT + iRecEfe ;
				LET iRecCCT = iRecCCT + iRecCC;
				LET mTotComision = mTotComision + mComision;
				LET mTotIvaCom = mTotIvaCom + mIvaCom;

				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

					IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
						LET iRecLun = iRecEfe + iRecCC ;
						LET mCobLun = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;


					IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
						LET iRecMar = iRecEfe + iRecCC ;
						LET mCobMar = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
						LET iRecMie = iRecEfe + iRecCC ;
						LET mCobMie = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC ;
						LET mCobJue = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC ;
						LET mCobVie = mCobEfe + mCobCC ;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC ;
						LET mCobSab = mCobEfe + mCobCC ;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC ;
						LET mCobDom = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqlun =  mLiqlun + mCobDom;

							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

				LET dFechaAux = dFechaAux + 1;

				END IF;
			END WHILE;

			IF cCodRet2::INTEGER = 0 THEN

				INSERT INTO "informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, 				rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, 			 cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, 			   rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, cob_efectivo,
							  cob_cheqmb,cob_cheqob, cob_tarcred, liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
				VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom, mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,iRecEfeT, iRecCCT,0, 0,  mCobEfeT, mCobCCT, 0, 0,mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,0,mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo,
					  (SELECT NVL(MAX(consecutivo_convenio + 1 ),1) FROM "informix".sac_liquidacionsemanal
					   WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
		END IF;

		IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
			LET dFechaAux = dPriDiaMes;
			LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

			WHILE dFechaAux <= dfecha_Hoy

				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT NVL(importe_comision_convenio,0),NVL(iva_comision_convenio,0),
						flag_confirmacion_central, flag_confirmacion_sucursal,folio_suc
					INTO mComisionAux, mIvaComAux,iFlagCen,iFlagSuc,cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia
						WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis
							WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								LET iNumOpe = iNumOpe + 1;
							END IF;
						ELSE
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							LET iNumOpe = iNumOpe + 1;
						END IF;
					ELSE
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						LET iNumOpe = iNumOpe + 1;
					END IF;

				END FOREACH;

				INSERT INTO "informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;
			END WHILE;

		END IF;

		IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
			LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;

		UPDATE "informix".sac_controlreportesespeciales
		SET retorno = cCodret
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE
DOCUMENT
'AUTOR: Vazquez Herrera Hugo Guadalupe ',
'DESCRIPCIÓN: Genera la información para los Reportes Semanal y Mensual de Pagos referenciados (YVES ROCHER)',
'SUSTENTO: RQM 10 498 PgsRef_YVES ROCHER.doc',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de p_ProcesoCierreSAC()',
'FECHA: 07/08/2014 ',
'VERSIÓN: 201407081043 ',
'Solicita: Leonardo Hernandez',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_generaarchivocobranzaedomex(cId_convenio CHAR(5))
	
	DEFINE cCodRet			CHAR(5);
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cInfoErr			CHAR(100);
	DEFINE cCategoria		CHAR(2);
	DEFINE cConvenio		CHAR(3);
	DEFINE dFechaIni		DATE;
	DEFINE dFecha_Hoy		DATE;
	DEFINE cRutaArch		CHAR(100);
	DEFINE cNomArch			CHAR(30);
	DEFINE cMes				CHAR(2);
	DEFINE cDia				CHAR(2);
	DEFINE cAnio			CHAR(4);
	DEFINE cStmt			CHAR(250);
	DEFINE cCuentaPrestadora CHAR(16);
	DEFINE cFechaPago		CHAR(8);
	DEFINE cReferencia1		CHAR(27);
	DEFINE iImportePago		INTEGER;
	DEFINE cFolioSuc		CHAR(60);
	DEFINE iNumPagos		INTEGER;
	DEFINE iTotalPagado		INTEGER;
	DEFINE cFormaPago		CHAR(2);
	DEFINE cId_sucursal		CHAR(6);
	DEFINE cPrefijo			CHAR(6);
	DEFINE cDescripcion		CHAR(100);
	DEFINE cMedioPagoVen	CHAR(2);
	DEFINE cMedioPago		CHAR(2);
	DEFINE cMedioPagoWeb	CHAR(2);
	DEFINE cSucLinea		CHAR(30);
	
	--SET DEBUG FILE TO '/home/sysifx/JesusBueno/1468/sp_generaarchivocobranzaedomex.out';
	--TRACE ON;

	LET cCategoria	= SUBSTRING(cId_convenio FROM 1 FOR 2);
	LET cConvenio 	= SUBSTRING(cId_convenio FROM 3 FOR 3);
	LET cRutaArch 	= '';
	LET cNomArch 	= '';
	LET cMes 		= '';
	LET cDia 		= '';
	LET cAnio 		= '';
	LET cStmt		= '';
	LET cCuentaPrestadora = '';
	LET cFechaPago 	= '';
	LET cReferencia1	 = '';
	LET iImportePago = 0;
	LET cFolioSuc	=	'';
	LET iNumPagos	= 0;
	LET iTotalPagado = 0;
	LET cFormaPago ='';
	LET cId_sucursal ='';
	LET cPrefijo = '';
	LET cDescripcion ='';
	LET cMedioPagoVen ='';
	LET cMedioPago ='';
	LET cMedioPagoWeb ='';
	LET cSucLinea='';

	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE bdisac:"informix".sac_controlarchivoscobranza
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio;

				EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_generaarchivocobranzaedomex");
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM bdisac:"informix".sac_fechas;

		SELECT fecha_ultimo_archivo
		INTO dFechaIni
		FROM bdisac:"informix".sac_controlarchivoscobranza
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

		LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
		LET cMes = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
		LET cAnio = YEAR(dFecha_Hoy );
		
		SELECT TRIM(ruta_archivo_cobranza), TRIM(nombre_archivo_cobranza)
		INTO cRutaArch, cNomArch
		FROM bdisac:"informix".sac_convenios
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;
		
		LET cNomArch = REPLACE(cNomArch,'AAAA',cAnio);
		LET cNomArch = REPLACE(cNomArch,'MM',cMes);
		LET cNomArch = REPLACE(cNomArch,'DD',cDia);
		
		LET cNomArch = TRIM(cNomArch);
		
		LET cRutaArch = TRIM(cRutaArch) || TRIM(cNomArch);
		
		LET cStmt='echo "H|' || SUBSTR(cNomArch,1,2) || '|' || TRIM(cDia) || TRIM(cMes) ||TRIM(cAnio)||'" >> ' || cRutaArch;
		SYSTEM cStmt;
		
		SELECT TRIM (valor) 
		INTO cMedioPagoVen
		FROM bdisac:"informix".sac_param 
		WHERE cod_param='26';
		
		SELECT TRIM (valor) 
		INTO cMedioPagoWeb
		FROM bdisac:"informix".sac_param 
		WHERE cod_param='27'; 

		SELECT TRIM (valor) 
		INTO cSucLinea
		FROM bdisac:"informix".sac_param 
		WHERE cod_param='28';	
		
		FOREACH
			
			SELECT referencia1,(importe_pago * 100), 
			LPAD(DAY(fecha_pago::DATE), 2, '0') || LPAD(MONTH(fecha_pago::DATE), 2, '0') || LPAD(YEAR(fecha_pago:: DATE), 4, '0'),
			LPAD(TRIM(folio_suc),60,0),id_sucursal,forma_pago
			INTO cReferencia1,iImportePago,cFechaPago,cFolioSuc,cId_sucursal,cFormaPago
			FROM bdisac:"informix".sac_movimientoshistorial
			WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago > dFechaIni
				AND fecha_pago <= dFecha_Hoy
				AND status_cancelado <> 'S'
				AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)
			
			IF cFormaPago = '1' THEN
				LET cFormaPago = '04';
			ELIF cFormaPago = '2' THEN
				LET cFormaPago = '08';
			ELIF cFormaPago = '5' THEN
				LET cFormaPago = '02';
			END IF;
			
			IF fn_instr(cSucLinea,TRIM(cId_sucursal))  <> 0 THEN
				LET cMedioPago = cMedioPagoWeb;
			ELSE 
				LET cMedioPago = cMedioPagoVen;
			END IF;
			
			LET cPrefijo = SUBSTR(cReferencia1,1,6);
			EXECUTE PROCEDURE bdisac:"informix".sp_asignacuenta_edomex(cPrefijo) --Saca la cuenta concentradora
			INTO cCodRet,cDescripcion,cCuentaPrestadora;
			LET cCuentaPrestadora = LPAD(TRIM(cCuentaPrestadora),16,'0');
			LET cId_sucursal = LPAD(TRIM(cId_sucursal),6,'0');
			
			--IMPRIME RENGLON DE LAS OPERACIONES
			LET cStmt = 'echo "D|' || cMedioPago ||'|' || cFormaPago || '|'|| cReferencia1 || '|' || LPAD(iImportePago,16,'0') || '|' || cFechaPago || '|' || cFechaPago || '|' || cFolioSuc || '|00|' || cId_sucursal || '|' || cCuentaPrestadora ||  '" >> ' || cRutaArch;
			SYSTEM cStmt;

			LET iNumPagos = iNumPagos + 1;
			LET iTotalPagado = iTotalPagado + iImportePago;

		END FOREACH;
		
		IF DBINFO("sqlca.sqlerrd2") <> 0 THEN
			--IMPRIME RENGLON DE LAS OPERACIONES
			LET cStmt = 'echo "E|' || LPAD(iNumPagos, 7,'0') || '|' || LPAD(iTotalPagado,16,'0') || '" >> ' || cRutaArch;
			SYSTEM cStmt;
		END IF;

		
	END;
END PROCEDURE
DOCUMENT
'Folio: 1468',
'Autor: 95347143, Jesus Isaias Bueno',
'Fecha: 17/02/2015',
'Descripción: Se crea procedimiento que realiza archivo en txt. de la cobranza generada con los pagos de servicio EDOMEX',
'Sustento: PgImpMex_RQM_10525_PagoImpEdoMex_v1.0.doc',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidacionedomex(pId_Convenio CHAR(5))

--Definicion de Variables
	DEFINE cCodret           CHAR(5);
	DEFINE cAnioMes          CHAR(6);
	DEFINE cInfoErr          CHAR(100);
	DEFINE cCategoria        CHAR(2);
	DEFINE cConvenio         CHAR(3);
	DEFINE iSqlErr           INTEGER;
	DEFINE iIsamErr          INTEGER;
	DEFINE iRecEfe           INTEGER;
	DEFINE iRecCC            INTEGER;
	DEFINE iRecMix           INTEGER;
	DEFINE iRecCrd           INTEGER;
	DEFINE iRecEfeT          INTEGER;
	DEFINE iRecCCT           INTEGER;
	DEFINE iRecMixT          INTEGER;
	DEFINE iRecTot           INTEGER;
	DEFINE iRecAux           INTEGER;
	DEFINE iRecLun           INTEGER;
	DEFINE iRecMAr           INTEGER;
	DEFINE iRecMie           INTEGER;
	DEFINE iRecJue           INTEGER;
	DEFINE iRecVie           INTEGER;
	DEFINE iRecSab           INTEGER;
	DEFINE iRecDom           INTEGER;
	DEFINE iNumOpe           INTEGER;
	DEFINE mLiqlun           MONEY(16,2);
	DEFINE mLiqMar           MONEY(16,2);
	DEFINE mLiqMier          MONEY(16,2);
	DEFINE mLiqJue           MONEY(16,2);
	DEFINE mLiqVie           MONEY(16,2);
	DEFINE mLiqSab           MONEY(16,2);
	DEFINE mLiqDom           MONEY(16,2);
	DEFINE mCobEfe           MONEY(16,2);
	DEFINE mCobMix           MONEY(16,2);
	DEFINE mCobCrd           MONEY(16,2);
	DEFINE mCobCC            MONEY(16,2);
	DEFINE mCobEfeT          MONEY(16,2);
	DEFINE mCobCCT           MONEY(16,2);
	DEFINE mCobLun           MONEY(16,2);
	DEFINE mCobMar           MONEY(16,2);
	DEFINE mCobMie           MONEY(16,2);
	DEFINE mCobJue           MONEY(16,2);
	DEFINE mCobVie           MONEY(16,2);
	DEFINE mCobSab           MONEY(16,2);
	DEFINE mCobDom           MONEY(16,2);
	DEFINE mTotComision      MONEY(16,2);
	DEFINE mTotIvaCom        MONEY(16,2);
	DEFINE mComision         MONEY(16,2);
	DEFINE mIvaCom           MONEY(16,2);  
	DEFINE dFechaAux         DATE;
	DEFINE dfecha_Hoy        DATE;
	DEFINE dFechaIni         DATE;
	DEFINE dPriDiaMes        DATE;
	DEFINE dUltDiaMes        DATE;

--Inicializacion de Variables   
	LET cCodret        = "00000";
	LET cInfoErr       = '';
	LET cAnioMes       = '';
	LET mCobEfe        = 0;
	LET mCobCC         = 0;
	LET mCobMix        = 0;
	LET mCobCrd        = 0;
	LET iRecEfe        = 0;
	LET iRecCC         = 0;
	LET iRecMix        = 0;
	LET iRecCrd        = 0;
	LET mComision      = 0;
	LET mIvaCom        = 0;
	LET mCobEfeT       = 0;
	LET mCobCCT        = 0;
	LET iRecEfeT       = 0;
	LET iRecCCT        = 0;
	LET mTotComision   = 0;                      
	LET mTotIvaCom     = 0;              
	LET iRecLun        = 0;            
	LET mCobLun        = 0;            
	LET iRecMar        = 0;            
	LET mCobMar        = 0;            
	LET iRecMie        = 0;            
	LET mCobMie        = 0;            
	LET iRecJue        = 0;            
	LET mCobJue        = 0;            
	LET iRecVie        = 0;            
	LET mCobVie        = 0;            
	LET iRecSab        = 0;            
	LET mCobSab        = 0;            
	LET iRecDom        = 0;            
	LET mCobDom        = 0;            
	LET cCategoria     = ''; --SUBSTRING(pId_Convenio FROM 1 FOR 2);
	LET cConvenio      = ''; --SUBSTRING(pId_Convenio FROM 3 FOR 3);
	LET dFechaAux      = '';
	LET dfecha_Hoy     = '';
	LET dFechaIni      = '';
	LET dPriDiaMes	   = '';
	LET dUltDiaMes	   = '';
	LET iNumOpe	       = 0;
	LET mLiqlun        = 0;
	LET mLiqMar        = 0;
	LET mLiqMier       = 0;
	LET mLiqJue        = 0;
	LET mLiqVie        = 0;
	LET mLiqSab        = 0;
	LET mLiqDom        = 0;
	
   --SET DEBUG FILE TO "/home/sysifx/JesusBueno/1468/sp_reporteliquidacionedomex.out";
   --TRACE ON;
   
   BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;

                    UPDATE bdisac:"informix".sac_controlreportesespeciales
                    SET retorno = cCodRet
                    WHERE numcategoria = cCategoria
                    AND numconvenio = cConvenio;

                    EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacionedomex");
                END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;

        SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
        INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
        FROM bdisac:"informix".sac_fechas;
		
		LET cCategoria     = SUBSTRING(pId_Convenio FROM 1 FOR 2);
		LET cConvenio      = SUBSTRING(pId_Convenio FROM 3 FOR 3);
		
        IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

            LET dFechaAux = dfecha_Hoy - 6;
            LET dFechaIni = dFechaAux;
			
			WHILE dFechaAux <= dfecha_Hoy
                SELECT NVL(SUM(efe),0), NVL(SUM(cc),0), NVL(SUM(mix),0), NVL(SUM(crd),0),COUNT(Rec1), COUNT(Rec2), COUNT(Rec3), COUNT(Rec5),NVL(SUM(comision), 0), NVL(SUM(iva_com),0)
                INTO mCobEfe, mCobCC, mCobMix,mCobCrd, iRecEfe, iRecCC, iRecMix,iRecCrd, mComision, mIvaCom
                FROM TABLE(
                    MULTISET(
                        SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
                                CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
                                CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
                                CASE WHEN forma_pago = 3 THEN NVL(importe_pago, 0) END AS mix,
								CASE WHEN forma_pago = 5 THEN NVL(importe_pago, 0) END AS crd,
                                CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
                                CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
                                CASE WHEN forma_pago = 3 THEN folio_suc END AS Rec3,
								CASE WHEN forma_pago = 5 THEN folio_suc END AS Rec5
                        FROM bdisac:"informix".sac_movimientoshistorial
                        WHERE numcategoria = cCategoria
                        AND numconvenio = cConvenio
                        AND fecha_pago  = dFechaAux
                        AND status_cancelado = 'N'));

                LET mCobEfeT = mCobEfeT + mCobEfe + mCobMix + mCobCrd;
                LET mCobCCT = mCobCCT + mCobCC;

                LET iRecEfeT = iRecEfeT + iRecEfe + iRecMix + iRecCrd;
                LET iRecCCT = iRecCCT + iRecCC;

                LET mTotComision = mTotComision + mComision;
                LET mTotIvaCom = mTotIvaCom + mIvaCom;

				
				IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
					LET iRecLun = iRecEfe + iRecCC + iRecMix + iRecCrd;
					LET mCobLun = mCobEfe + mCobCC + mCobMix + mCobCrd;
					LET mLiqMar = mCobLun;
						
				END IF;	
   
				IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
					LET iRecMar = iRecEfe + iRecCC + iRecMix + iRecCrd;
					LET mCobMar = mCobEfe + mCobCC + mCobMix + mCobCrd;
					LET mLiqMier = mCobMar;
				END IF;
				
				IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
					LET iRecMie = iRecEfe + iRecCC + iRecMix + iRecCrd;
					LET mCobMie = mCobEfe + mCobCC + mCobMix + mCobCrd;
					LET mLiqJue = mCobMie;
				END IF;
					
				IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
					LET iRecJue = iRecEfe + iRecCC + iRecMix + iRecCrd;
					LET mCobJue = mCobEfe + mCobCC + mCobMix + mCobCrd;
					LET mLiqVie = mCobJue;
				END IF;
					
				IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
					LET iRecVie = iRecEfe + iRecCC + iRecMix + iRecCrd;
					LET mCobVie = mCobEfe + mCobCC + mCobMix + mCobCrd;
					LET mLiqSab = mCobVie;
				END IF;
					
				IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
					LET iRecSab = iRecEfe + iRecCC + iRecMix + iRecCrd;
					LET mCobSab = mCobEfe + mCobCC + mCobMix + mCobCrd;
					LET mLiqDom = mCobSab;
				END IF;
					
				IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
					LET iRecDom = iRecEfe + iRecCC + iRecMix + iRecCrd;
					LET mCobDom = mCobEfe + mCobCC + mCobMix + mCobCrd;
					LET mLiqlun = mCobDom;
				END IF;
					
				LET dFechaAux = dFechaAux + 1;
				
	        END WHILE;
			
	            INSERT INTO bdisac:"informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo,
																	  cob_lunes, cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo,
																	  rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred,
																	  cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred,
																	  liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,liq_sabado,liq_domingo,
																	  aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
	            VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom,
	                   mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,
	                   iRecEfeT, iRecCCT, 0, 0, 
					   mCobEfeT, mCobCCT, 0, 0,
	                   mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,mLiqSab,mLiqDom,
	                   0, mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, 0 , (SELECT NVL(MAX(consecutivo_convenio + 1 ),1)
																						  FROM bdisac:"informix".sac_liquidacionsemanal
																						  WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
	    END IF;
        
        IF dfecha_Hoy = dUltDiaMes THEN
            LET dFechaAux = dPriDiaMes;
            LET mComision = 0;
            LET mIvaCom = 0;
            LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

            WHILE dFechaAux <= dfecha_Hoy

				SELECT COUNT(folio_suc), NVL(SUM(importe_comision_convenio),0), NVL(SUM(iva_comision_convenio),0) 
				INTO iNumOpe, mComision, mIvaCom
				FROM bdisac:"informix".sac_movimientoshistorial
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago  = dFechaAux
				AND status_cancelado = 'N';

				INSERT INTO bdisac:"informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;                         
            END WHILE;
		
        END IF;
       	
	    UPDATE bdisac:"informix".sac_controlreportesespeciales
	    SET retorno = cCodret
	    WHERE numcategoria = cCategoria
	    AND numconvenio = cConvenio;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : Jesus Isaias Bueno',
'DESCRIPCIÓN: Genera la información para los Reportes Semanal y Mensual de pago de servicios edomex',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de sp_ProcesoCierreSAC()',
'FECHA : 16 Febrero 2015',
'VERSIÓN: 20150216.1240',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidacionaxtel(pConvenio CHAR(5))

--DEFINICION DE VARIABLES
DEFINE cCodret           CHAR(5);
DEFINE cCodRet2          CHAR(5);
DEFINE cAnioMes          CHAR(6);
DEFINE cInfoErr          CHAR(100);
DEFINE cCategoria        CHAR(2);
DEFINE cConvenio         CHAR(3);
DEFINE cFechaLiq         CHAR(10);
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE iRecEfe           INTEGER;
DEFINE iRecEfeAux        CHAR(16);
DEFINE iRecCC            INTEGER;
DEFINE iRecCCAux         CHAR(16);
DEFINE iRecMix           INTEGER;
DEFINE iRecEfeT          INTEGER;
DEFINE iRecCCT           INTEGER;
DEFINE iRecMixT          INTEGER;
DEFINE iRecTot           INTEGER;
DEFINE iRecAux           INTEGER;
DEFINE iRecLun           INTEGER;
DEFINE iRecMAr           INTEGER;
DEFINE iRecMie           INTEGER;
DEFINE iRecJue           INTEGER;
DEFINE iRecVie           INTEGER;
DEFINE iRecSab           INTEGER;
DEFINE iRecDom           INTEGER;
DEFINE iNumOpe           INTEGER;
DEFINE iDias             INTEGER;
DEFINE mLiqlun           MONEY(16,2);
DEFINE mLiqMar           MONEY(16,2);
DEFINE mLiqMier          MONEY(16,2);
DEFINE mLiqJue           MONEY(16,2);
DEFINE mLiqVie           MONEY(16,2);
DEFINE mLiqResguardo     MONEY(16,2);
DEFINE mCobEfe           MONEY(16,2);
DEFINE mCobEfeAux        MONEY(16,2);
DEFINE mCobMix           MONEY(16,2);
DEFINE mCobCC            MONEY(16,2);
DEFINE mCobCCAux         MONEY(16,2);
DEFINE mCobEfeT          MONEY(16,2);
DEFINE mCobMixT          MONEY(16,2);
DEFINE mCobCCT           MONEY(16,2);
DEFINE mCobTot           MONEY(16,2);
DEFINE mCobAux           MONEY(16,2);
DEFINE mCobLun           MONEY(16,2);
DEFINE mCobMar           MONEY(16,2);
DEFINE mCobMie           MONEY(16,2);
DEFINE mCobJue           MONEY(16,2);
DEFINE mCobVie           MONEY(16,2);
DEFINE mCobSab           MONEY(16,2);
DEFINE mCobDom           MONEY(16,2);
DEFINE mTotComision      MONEY(16,2);
DEFINE mTotIvaCom        MONEY(16,2);
DEFINE mComision         MONEY(16,2);
DEFINE mComisionAux      MONEY(16,2);
DEFINE mIvaCom           MONEY(16,2);
DEFINE mIvaComAux        MONEY(16,2);
DEFINE mAcumulado        MONEY(16,2);
DEFINE dFechaAux         DATE;
DEFINE dfecha_Hoy        DATE;
DEFINE dFechaIni         DATE;
DEFINE dPriDiaMes        DATE;
DEFINE dUltDiaMes        DATE;
DEFINE iFlagCen          INTEGER;
DEFINE iFlagSuc          INTEGER;
DEFINE cFolio            CHAR(16);
DEFINE iCuantos          INTEGER;

--INICIALIZACION DE VARIABLES
LET cCodRet2	= "00000";
LET cCodret		= "000000";
LET cInfoErr	= '';
LET cAnioMes	= '';
LET mCobEfe		= 0;
LET mCobEfeAux	= 0;
LET mCobCC		= 0;
LET mCobCCAux	= 0;
LET mCobMix		= 0;
LET iRecEfe		= 0;
LET iRecEfeAux	= '';
LET iRecCC		= 0;
LET iRecCCAux	= '';
LET iRecMix		= 0;
LET mComision	= 0;
LET mComisionAux	= 0;
LET mIvaCom		= 0;
LET mIvaComAux	= 0;
LET mCobEfeT	= 0;
LET mCobCCT		= 0;
LET iRecEfeT	= 0;
LET iRecCCT		= 0;
LET mTotComision	= 0;
LET mTotIvaCom	= 0;
LET iRecLun		= 0;
LET mCobLun		= 0;
LET iRecMar		= 0;
LET mCobMar		= 0;
LET iRecMie		= 0;
LET mCobMie		= 0;
LET iRecJue		= 0;
LET mCobJue		= 0;
LET iRecVie		= 0;
LET mCobVie		= 0;
LET iRecSab		= 0;
LET mCobSab		= 0;
LET iRecDom		= 0;
LET mCobDom		= 0;
LET cCategoria	= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio	= SUBSTRING(pConvenio FROM 3 FOR 3);
LET dFechaAux	= '';
LET dfecha_Hoy	= '';
LET dFechaIni	= '';
LET dPriDiaMes	= '';
LET dUltDiaMes	= '';
LET iNumOpe		= 0;
LET mLiqlun		= 0;
LET mLiqMar		= 0;
LET mLiqMier	= 0;
LET mLiqJue		= 0;
LET mLiqVie		= 0;
LET cFechaLiq	= "";
LET mLiqResguardo	= 0;
LET mAcumulado	= 0;
LET iFlagCen	= 0;
LET iFlagSuc	= 0;
LET cFolio		= '';
LET iCuantos	= 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/respaldosbd/hugovaz/sp_reporteliquidacionaxtel.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlreportesespeciales
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio;
				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacionaxtel");
			END IF;
		END EXCEPTION;

		SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
		INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
		FROM "informix".sac_fechas;

		IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

			LET dFechaAux = dfecha_Hoy - 6;
			LET dFechaIni = dFechaAux;

			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM "informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
								FROM "informix".sac_liquidacionsemanal
								WHERE id_convenio = cCategoria||cConvenio
								AND consecutivo_convenio <> 0);

			IF mAcumulado IS NULL THEN
				LET mAcumulado = 0;
			END IF;
			
			WHILE dFechaAux <= dfecha_Hoy

				LET mCobEfe = 0.00;
				LET mCobCC = 0.00;
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iRecEfe = 0;
				LET iRecCC = 0;

				FOREACH
					SELECT
						NVL(efe,0),
						NVL(cc,0),
						NVL(Rec1,''),
						NVL(Rec2,""),
						NVL(comision, 0),
						NVL(iva_com,0),
						flag_confirmacion_central,
						flag_confirmacion_sucursal,
						folio_suc
					INTO
						mCobEfeAux,
						mCobCCAux,
						iRecEfeAux,
						iRecCCAux,
						mComisionAux,
						mIvaComAux,
						iFlagCen,
						iFlagSuc,
						cFolio
					FROM TABLE(
						MULTISET(
							SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
									CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
									CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
									CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
									CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
									flag_confirmacion_central,
									flag_confirmacion_sucursal,
									folio_suc
							FROM "informix".sac_movimientoshistorial
							WHERE numcategoria = cCategoria
							AND numconvenio = cConvenio
							AND fecha_pago  = dFechaAux
							AND status_cancelado = 'N'
							AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)))

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mCobEfe = mCobEfe + mCobEfeAux;
								LET mCobCC = mCobCC + mCobCCAux;
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
									LET iRecEfe = iRecEfe +1;
								END IF;
								IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
									LET iRecCC = iRecCC +1;
								END IF;
							END IF;
						ELSE
							LET mCobEfe = mCobEfe + mCobEfeAux;
							LET mCobCC = mCobCC + mCobCCAux;
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
								LET iRecEfe = iRecEfe +1;
							END IF;
							IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
								LET iRecCC = iRecCC +1;
							END IF;
						END IF;
					ELSE
						LET mCobEfe = mCobEfe + mCobEfeAux;
						LET mCobCC = mCobCC + mCobCCAux;
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
							LET iRecEfe = iRecEfe +1;
						END IF;
						IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
							LET iRecCC = iRecCC +1;
						END IF;
					END IF;
				END FOREACH;

				LET mCobEfeT = mCobEfeT + mCobEfe;
				LET mCobCCT = mCobCCT + mCobCC;
				LET iRecEfeT = iRecEfeT + iRecEfe ;
				LET iRecCCT = iRecCCT + iRecCC;
				LET mTotComision = mTotComision + mComision;
				LET mTotIvaCom = mTotIvaCom + mIvaCom;

				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

					IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
						LET iRecLun = iRecEfe + iRecCC ;
						LET mCobLun = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;


					IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
						LET iRecMar = iRecEfe + iRecCC ;
						LET mCobMar = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
						LET iRecMie = iRecEfe + iRecCC ;
						LET mCobMie = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC ;
						LET mCobJue = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC ;
						LET mCobVie = mCobEfe + mCobCC ;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC ;
						LET mCobSab = mCobEfe + mCobCC ;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC ;
						LET mCobDom = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqlun =  mLiqlun + mCobDom;

							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

				LET dFechaAux = dFechaAux + 1;

				END IF;
			END WHILE;

			IF cCodRet2::INTEGER = 0 THEN

				INSERT INTO "informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, 				rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, 			 cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, 			   rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, cob_efectivo,
							  cob_cheqmb,cob_cheqob, cob_tarcred, liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
				VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom, mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,iRecEfeT, iRecCCT,0, 0,  mCobEfeT, mCobCCT, 0, 0,mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,0,mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo,
					  (SELECT NVL(MAX(consecutivo_convenio + 1 ),1) FROM "informix".sac_liquidacionsemanal
					   WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
		END IF;

		IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
			LET dFechaAux = dPriDiaMes;
			LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

			WHILE dFechaAux <= dfecha_Hoy

				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT NVL(importe_comision_convenio,0),NVL(iva_comision_convenio,0),
						flag_confirmacion_central, flag_confirmacion_sucursal,folio_suc
					INTO mComisionAux, mIvaComAux,iFlagCen,iFlagSuc,cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia
						WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis
							WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								LET iNumOpe = iNumOpe + 1;
							END IF;
						ELSE
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							LET iNumOpe = iNumOpe + 1;
						END IF;
					ELSE
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						LET iNumOpe = iNumOpe + 1;
					END IF;

				END FOREACH;

				INSERT INTO "informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;
			END WHILE;

		END IF;

		IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
			LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;

		UPDATE "informix".sac_controlreportesespeciales
		SET retorno = cCodret
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE
DOCUMENT
'AUTOR: EPG',
'DESCRIPCIÓN: Genera la información para los Reportes Semanal y Mensual de Pagos referenciados (AXTEL)',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de sp_ProcesoCierreSAC()',
'FECHA: 22-04-2015',
'VERSIÓN: 20140625.1218',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidacioncablemas(pConvenio CHAR(5))

--DEFINICION DE VARIABLES
DEFINE cCodret           CHAR(5);
DEFINE cCodRet2          CHAR(5);
DEFINE cAnioMes          CHAR(6);
DEFINE cInfoErr          CHAR(100);
DEFINE cCategoria        CHAR(2);
DEFINE cConvenio         CHAR(3);
DEFINE cFechaLiq         CHAR(10);
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE iRecEfe           INTEGER;
DEFINE iRecEfeAux        CHAR(16);
DEFINE iRecCC            INTEGER;
DEFINE iRecCCAux         CHAR(16);
DEFINE iRecMix           INTEGER;
DEFINE iRecEfeT          INTEGER;
DEFINE iRecCCT           INTEGER;
DEFINE iRecMixT          INTEGER;
DEFINE iRecTot           INTEGER;
DEFINE iRecAux           INTEGER;
DEFINE iRecLun           INTEGER;
DEFINE iRecMAr           INTEGER;
DEFINE iRecMie           INTEGER;
DEFINE iRecJue           INTEGER;
DEFINE iRecVie           INTEGER;
DEFINE iRecSab           INTEGER;
DEFINE iRecDom           INTEGER;
DEFINE iNumOpe           INTEGER;
DEFINE iDias             INTEGER;
DEFINE mLiqlun           MONEY(16,2);
DEFINE mLiqMar           MONEY(16,2);
DEFINE mLiqMier          MONEY(16,2);
DEFINE mLiqJue           MONEY(16,2);
DEFINE mLiqVie           MONEY(16,2);
DEFINE mLiqResguardo     MONEY(16,2);
DEFINE mCobEfe           MONEY(16,2);
DEFINE mCobEfeAux        MONEY(16,2);
DEFINE mCobMix           MONEY(16,2);
DEFINE mCobCC            MONEY(16,2);
DEFINE mCobCCAux         MONEY(16,2);
DEFINE mCobEfeT          MONEY(16,2);
DEFINE mCobMixT          MONEY(16,2);
DEFINE mCobCCT           MONEY(16,2);
DEFINE mCobTot           MONEY(16,2);
DEFINE mCobAux           MONEY(16,2);
DEFINE mCobLun           MONEY(16,2);
DEFINE mCobMar           MONEY(16,2);
DEFINE mCobMie           MONEY(16,2);
DEFINE mCobJue           MONEY(16,2);
DEFINE mCobVie           MONEY(16,2);
DEFINE mCobSab           MONEY(16,2);
DEFINE mCobDom           MONEY(16,2);
DEFINE mTotComision      MONEY(16,2);
DEFINE mTotIvaCom        MONEY(16,2);
DEFINE mComision         MONEY(16,2);
DEFINE mComisionAux      MONEY(16,2);
DEFINE mIvaCom           MONEY(16,2);
DEFINE mIvaComAux        MONEY(16,2);
DEFINE mAcumulado        MONEY(16,2);
DEFINE dFechaAux         DATE;
DEFINE dfecha_Hoy        DATE;
DEFINE dFechaIni         DATE;
DEFINE dPriDiaMes        DATE;
DEFINE dUltDiaMes        DATE;
DEFINE iFlagCen          INTEGER;
DEFINE iFlagSuc          INTEGER;
DEFINE cFolio            CHAR(16);
DEFINE iCuantos          INTEGER;

--INICIALIZACION DE VARIABLES
LET cCodRet2	= "00000";
LET cCodret		= "000000";
LET cInfoErr	= '';
LET cAnioMes	= '';
LET mCobEfe		= 0;
LET mCobEfeAux	= 0;
LET mCobCC		= 0;
LET mCobCCAux	= 0;
LET mCobMix		= 0;
LET iRecEfe		= 0;
LET iRecEfeAux	= '';
LET iRecCC		= 0;
LET iRecCCAux	= '';
LET iRecMix		= 0;
LET mComision	= 0;
LET mComisionAux	= 0;
LET mIvaCom		= 0;
LET mIvaComAux	= 0;
LET mCobEfeT	= 0;
LET mCobCCT		= 0;
LET iRecEfeT	= 0;
LET iRecCCT		= 0;
LET mTotComision	= 0;
LET mTotIvaCom	= 0;
LET iRecLun		= 0;
LET mCobLun		= 0;
LET iRecMar		= 0;
LET mCobMar		= 0;
LET iRecMie		= 0;
LET mCobMie		= 0;
LET iRecJue		= 0;
LET mCobJue		= 0;
LET iRecVie		= 0;
LET mCobVie		= 0;
LET iRecSab		= 0;
LET mCobSab		= 0;
LET iRecDom		= 0;
LET mCobDom		= 0;
LET cCategoria	= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio	= SUBSTRING(pConvenio FROM 3 FOR 3);
LET dFechaAux	= '';
LET dfecha_Hoy	= '';
LET dFechaIni	= '';
LET dPriDiaMes	= '';
LET dUltDiaMes	= '';
LET iNumOpe		= 0;
LET mLiqlun		= 0;
LET mLiqMar		= 0;
LET mLiqMier	= 0;
LET mLiqJue		= 0;
LET mLiqVie		= 0;
LET cFechaLiq	= "";
LET mLiqResguardo	= 0;
LET mAcumulado	= 0;
LET iFlagCen	= 0;
LET iFlagSuc	= 0;
LET cFolio		= '';
LET iCuantos	= 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/respaldosbd/hugovaz/sp_reporteliquidacioncablemas.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlreportesespeciales
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio;
				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacioncablemas");
			END IF;
		END EXCEPTION;

		SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
		INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
		FROM "informix".sac_fechas;

		IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

			LET dFechaAux = dfecha_Hoy - 6;
			LET dFechaIni = dFechaAux;

			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM "informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
								FROM "informix".sac_liquidacionsemanal
								WHERE id_convenio = cCategoria||cConvenio
								AND consecutivo_convenio <> 0);

			IF mAcumulado IS NULL THEN
				LET mAcumulado = 0;
			END IF;
			
			WHILE dFechaAux <= dfecha_Hoy

				LET mCobEfe = 0.00;
				LET mCobCC = 0.00;
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iRecEfe = 0;
				LET iRecCC = 0;

				FOREACH
					SELECT
						NVL(efe,0),
						NVL(cc,0),
						NVL(Rec1,''),
						NVL(Rec2,""),
						NVL(comision, 0),
						NVL(iva_com,0),
						flag_confirmacion_central,
						flag_confirmacion_sucursal,
						folio_suc
					INTO
						mCobEfeAux,
						mCobCCAux,
						iRecEfeAux,
						iRecCCAux,
						mComisionAux,
						mIvaComAux,
						iFlagCen,
						iFlagSuc,
						cFolio
					FROM TABLE(
						MULTISET(
							SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
									CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
									CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
									CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
									CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
									flag_confirmacion_central,
									flag_confirmacion_sucursal,
									folio_suc
							FROM "informix".sac_movimientoshistorial
							WHERE numcategoria = cCategoria
							AND numconvenio = cConvenio
							AND fecha_pago  = dFechaAux
							AND status_cancelado = 'N'
							AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)))

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mCobEfe = mCobEfe + mCobEfeAux;
								LET mCobCC = mCobCC + mCobCCAux;
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
									LET iRecEfe = iRecEfe +1;
								END IF;
								IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
									LET iRecCC = iRecCC +1;
								END IF;
							END IF;
						ELSE
							LET mCobEfe = mCobEfe + mCobEfeAux;
							LET mCobCC = mCobCC + mCobCCAux;
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
								LET iRecEfe = iRecEfe +1;
							END IF;
							IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
								LET iRecCC = iRecCC +1;
							END IF;
						END IF;
					ELSE
						LET mCobEfe = mCobEfe + mCobEfeAux;
						LET mCobCC = mCobCC + mCobCCAux;
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
							LET iRecEfe = iRecEfe +1;
						END IF;
						IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
							LET iRecCC = iRecCC +1;
						END IF;
					END IF;
				END FOREACH;

				LET mCobEfeT = mCobEfeT + mCobEfe;
				LET mCobCCT = mCobCCT + mCobCC;
				LET iRecEfeT = iRecEfeT + iRecEfe ;
				LET iRecCCT = iRecCCT + iRecCC;
				LET mTotComision = mTotComision + mComision;
				LET mTotIvaCom = mTotIvaCom + mIvaCom;

				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

					IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
						LET iRecLun = iRecEfe + iRecCC ;
						LET mCobLun = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;


					IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
						LET iRecMar = iRecEfe + iRecCC ;
						LET mCobMar = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
						LET iRecMie = iRecEfe + iRecCC ;
						LET mCobMie = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC ;
						LET mCobJue = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC ;
						LET mCobVie = mCobEfe + mCobCC ;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC ;
						LET mCobSab = mCobEfe + mCobCC ;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC ;
						LET mCobDom = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqlun =  mLiqlun + mCobDom;

							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

				LET dFechaAux = dFechaAux + 1;

				END IF;
			END WHILE;

			IF cCodRet2::INTEGER = 0 THEN

				INSERT INTO "informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, 				rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, 			 cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, 			   rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, cob_efectivo,
							  cob_cheqmb,cob_cheqob, cob_tarcred, liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
				VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom, mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,iRecEfeT, iRecCCT,0, 0,  mCobEfeT, mCobCCT, 0, 0,mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,0,mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo,
					  (SELECT NVL(MAX(consecutivo_convenio + 1 ),1) FROM "informix".sac_liquidacionsemanal
					   WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
		END IF;

		IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
			LET dFechaAux = dPriDiaMes;
			LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

			WHILE dFechaAux <= dfecha_Hoy

				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT NVL(importe_comision_convenio,0),NVL(iva_comision_convenio,0),
						flag_confirmacion_central, flag_confirmacion_sucursal,folio_suc
					INTO mComisionAux, mIvaComAux,iFlagCen,iFlagSuc,cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia
						WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis
							WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								LET iNumOpe = iNumOpe + 1;
							END IF;
						ELSE
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							LET iNumOpe = iNumOpe + 1;
						END IF;
					ELSE
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						LET iNumOpe = iNumOpe + 1;
					END IF;

				END FOREACH;

				INSERT INTO "informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;
			END WHILE;

		END IF;

		IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
			LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;

		UPDATE "informix".sac_controlreportesespeciales
		SET retorno = cCodret
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE
DOCUMENT
'AUTOR: EPG',
'DESCRIPCIÓN: Genera la información para los Reportes Semanal y Mensual de Pagos referenciados (CABLEMAS)',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de p_ProcesoCierreSAC()',
'FECHA: 22-04-2015',
'VERSIÓN: 20140625.1218',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidacioncfe(pConvenio CHAR(5))

--DEFINICION DE VARIABLES
DEFINE cCodret           CHAR(5);
DEFINE cCodRet2          CHAR(5);
DEFINE cAnioMes          CHAR(6);
DEFINE cInfoErr          CHAR(100);
DEFINE cCategoria        CHAR(2);
DEFINE cConvenio         CHAR(3);
DEFINE cFechaLiq         CHAR(10);
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE iRecEfe           INTEGER;
DEFINE iRecEfeAux        CHAR(16);
DEFINE iRecCC            INTEGER;
DEFINE iRecCCAux         CHAR(16);
DEFINE iRecMix           INTEGER;
DEFINE iRecEfeT          INTEGER;
DEFINE iRecCCT           INTEGER;
DEFINE iRecMixT          INTEGER;
DEFINE iRecTot           INTEGER;
DEFINE iRecAux           INTEGER;
DEFINE iRecLun           INTEGER;
DEFINE iRecMAr           INTEGER;
DEFINE iRecMie           INTEGER;
DEFINE iRecJue           INTEGER;
DEFINE iRecVie           INTEGER;
DEFINE iRecSab           INTEGER;
DEFINE iRecDom           INTEGER;
DEFINE iNumOpe           INTEGER;
DEFINE iDias             INTEGER;
DEFINE mLiqlun           MONEY(16,2);
DEFINE mLiqMar           MONEY(16,2);
DEFINE mLiqMier          MONEY(16,2);
DEFINE mLiqJue           MONEY(16,2);
DEFINE mLiqVie           MONEY(16,2);
DEFINE mLiqResguardo     MONEY(16,2);
DEFINE mCobEfe           MONEY(16,2);
DEFINE mCobEfeAux        MONEY(16,2);
DEFINE mCobMix           MONEY(16,2);
DEFINE mCobCC            MONEY(16,2);
DEFINE mCobCCAux         MONEY(16,2);
DEFINE mCobEfeT          MONEY(16,2);
DEFINE mCobMixT          MONEY(16,2);
DEFINE mCobCCT           MONEY(16,2);
DEFINE mCobTot           MONEY(16,2);
DEFINE mCobAux           MONEY(16,2);
DEFINE mCobLun           MONEY(16,2);
DEFINE mCobMar           MONEY(16,2);
DEFINE mCobMie           MONEY(16,2);
DEFINE mCobJue           MONEY(16,2);
DEFINE mCobVie           MONEY(16,2);
DEFINE mCobSab           MONEY(16,2);
DEFINE mCobDom           MONEY(16,2);
DEFINE mTotComision      MONEY(16,2);
DEFINE mTotIvaCom        MONEY(16,2);
DEFINE mComision         MONEY(16,2);
DEFINE mComisionAux      MONEY(16,2);
DEFINE mIvaCom           MONEY(16,2);
DEFINE mIvaComAux        MONEY(16,2);
DEFINE mAcumulado        MONEY(16,2);
DEFINE dFechaAux         DATE;
DEFINE dfecha_Hoy        DATE;
DEFINE dFechaIni         DATE;
DEFINE dPriDiaMes        DATE;
DEFINE dUltDiaMes        DATE;
DEFINE iFlagCen          INTEGER;
DEFINE iFlagSuc          INTEGER;
DEFINE cFolio            CHAR(16);
DEFINE iCuantos          INTEGER;

--INICIALIZACION DE VARIABLES
LET cCodRet2	= "00000";
LET cCodret		= "000000";
LET cInfoErr	= '';
LET cAnioMes	= '';
LET mCobEfe		= 0;
LET mCobEfeAux	= 0;
LET mCobCC		= 0;
LET mCobCCAux	= 0;
LET mCobMix		= 0;
LET iRecEfe		= 0;
LET iRecEfeAux	= '';
LET iRecCC		= 0;
LET iRecCCAux	= '';
LET iRecMix		= 0;
LET mComision	= 0;
LET mComisionAux	= 0;
LET mIvaCom		= 0;
LET mIvaComAux	= 0;
LET mCobEfeT	= 0;
LET mCobCCT		= 0;
LET iRecEfeT	= 0;
LET iRecCCT		= 0;
LET mTotComision	= 0;
LET mTotIvaCom	= 0;
LET iRecLun		= 0;
LET mCobLun		= 0;
LET iRecMar		= 0;
LET mCobMar		= 0;
LET iRecMie		= 0;
LET mCobMie		= 0;
LET iRecJue		= 0;
LET mCobJue		= 0;
LET iRecVie		= 0;
LET mCobVie		= 0;
LET iRecSab		= 0;
LET mCobSab		= 0;
LET iRecDom		= 0;
LET mCobDom		= 0;
LET cCategoria	= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio	= SUBSTRING(pConvenio FROM 3 FOR 3);
LET dFechaAux	= '';
LET dfecha_Hoy	= '';
LET dFechaIni	= '';
LET dPriDiaMes	= '';
LET dUltDiaMes	= '';
LET iNumOpe		= 0;
LET mLiqlun		= 0;
LET mLiqMar		= 0;
LET mLiqMier	= 0;
LET mLiqJue		= 0;
LET mLiqVie		= 0;
LET cFechaLiq	= "";
LET mLiqResguardo	= 0;
LET mAcumulado	= 0;
LET iFlagCen	= 0;
LET iFlagSuc	= 0;
LET cFolio		= '';
LET iCuantos	= 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/respaldosbd/hugovaz/sp_reporteliquidacioncfe.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlreportesespeciales
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio;
				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacioncfe");
			END IF;
		END EXCEPTION;

		SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
		INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
		FROM "informix".sac_fechas;

		IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

			LET dFechaAux = dfecha_Hoy - 6;
			LET dFechaIni = dFechaAux;

			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM "informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
								FROM "informix".sac_liquidacionsemanal
								WHERE id_convenio = cCategoria||cConvenio
								AND consecutivo_convenio <> 0);

			IF mAcumulado IS NULL THEN
				LET mAcumulado = 0;
			END IF;
			
			WHILE dFechaAux <= dfecha_Hoy

				LET mCobEfe = 0.00;
				LET mCobCC = 0.00;
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iRecEfe = 0;
				LET iRecCC = 0;

				FOREACH
					SELECT
						NVL(efe,0),
						NVL(cc,0),
						NVL(Rec1,''),
						NVL(Rec2,""),
						NVL(comision, 0),
						NVL(iva_com,0),
						flag_confirmacion_central,
						flag_confirmacion_sucursal,
						folio_suc
					INTO
						mCobEfeAux,
						mCobCCAux,
						iRecEfeAux,
						iRecCCAux,
						mComisionAux,
						mIvaComAux,
						iFlagCen,
						iFlagSuc,
						cFolio
					FROM TABLE(
						MULTISET(
							SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
									CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
									CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
									CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
									CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
									flag_confirmacion_central,
									flag_confirmacion_sucursal,
									folio_suc
							FROM "informix".sac_movimientoshistorial
							WHERE numcategoria = cCategoria
							AND numconvenio = cConvenio
							AND fecha_pago  = dFechaAux
							AND status_cancelado = 'N'
							AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)))

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mCobEfe = mCobEfe + mCobEfeAux;
								LET mCobCC = mCobCC + mCobCCAux;
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
									LET iRecEfe = iRecEfe +1;
								END IF;
								IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
									LET iRecCC = iRecCC +1;
								END IF;
							END IF;
						ELSE
							LET mCobEfe = mCobEfe + mCobEfeAux;
							LET mCobCC = mCobCC + mCobCCAux;
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
								LET iRecEfe = iRecEfe +1;
							END IF;
							IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
								LET iRecCC = iRecCC +1;
							END IF;
						END IF;
					ELSE
						LET mCobEfe = mCobEfe + mCobEfeAux;
						LET mCobCC = mCobCC + mCobCCAux;
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
							LET iRecEfe = iRecEfe +1;
						END IF;
						IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
							LET iRecCC = iRecCC +1;
						END IF;
					END IF;
				END FOREACH;

				LET mCobEfeT = mCobEfeT + mCobEfe;
				LET mCobCCT = mCobCCT + mCobCC;
				LET iRecEfeT = iRecEfeT + iRecEfe ;
				LET iRecCCT = iRecCCT + iRecCC;
				LET mTotComision = mTotComision + mComision;
				LET mTotIvaCom = mTotIvaCom + mIvaCom;

				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

					IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
						LET iRecLun = iRecEfe + iRecCC ;
						LET mCobLun = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;


					IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
						LET iRecMar = iRecEfe + iRecCC ;
						LET mCobMar = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
						LET iRecMie = iRecEfe + iRecCC ;
						LET mCobMie = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC ;
						LET mCobJue = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC ;
						LET mCobVie = mCobEfe + mCobCC ;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC ;
						LET mCobSab = mCobEfe + mCobCC ;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC ;
						LET mCobDom = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqlun =  mLiqlun + mCobDom;

							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

				LET dFechaAux = dFechaAux + 1;

				END IF;
			END WHILE;

			IF cCodRet2::INTEGER = 0 THEN

				INSERT INTO "informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, 				rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, 			 cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, 			   rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, cob_efectivo,
							  cob_cheqmb,cob_cheqob, cob_tarcred, liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
				VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom, mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,iRecEfeT, iRecCCT,0, 0,  mCobEfeT, mCobCCT, 0, 0,mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,0,mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo,
					  (SELECT NVL(MAX(consecutivo_convenio + 1 ),1) FROM "informix".sac_liquidacionsemanal
					   WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
		END IF;

		IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
			LET dFechaAux = dPriDiaMes;
			LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

			WHILE dFechaAux <= dfecha_Hoy

				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT NVL(importe_comision_convenio,0),NVL(iva_comision_convenio,0),
						flag_confirmacion_central, flag_confirmacion_sucursal,folio_suc
					INTO mComisionAux, mIvaComAux,iFlagCen,iFlagSuc,cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia
						WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis
							WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								LET iNumOpe = iNumOpe + 1;
							END IF;
						ELSE
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							LET iNumOpe = iNumOpe + 1;
						END IF;
					ELSE
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						LET iNumOpe = iNumOpe + 1;
					END IF;

				END FOREACH;

				INSERT INTO "informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;
			END WHILE;

		END IF;

		IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
			LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;

		UPDATE "informix".sac_controlreportesespeciales
		SET retorno = cCodret
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE
DOCUMENT
'AUTOR: EPG',
'DESCRIPCIÓN: Genera la información para los Reportes Semanal y Mensual de Pagos referenciados (CFE)',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de p_ProcesoCierreSAC()',
'FECHA: 22-04-2015',
'VERSIÓN: 20140625.1218',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidacionjapac(pConvenio CHAR(5))

--DEFINICION DE VARIABLES
DEFINE cCodret           CHAR(5);
DEFINE cCodRet2          CHAR(5);
DEFINE cAnioMes          CHAR(6);
DEFINE cInfoErr          CHAR(100);
DEFINE cCategoria        CHAR(2);
DEFINE cConvenio         CHAR(3);
DEFINE cFechaLiq         CHAR(10);
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE iRecEfe           INTEGER;
DEFINE iRecEfeAux        CHAR(16);
DEFINE iRecCC            INTEGER;
DEFINE iRecCCAux         CHAR(16);
DEFINE iRecMix           INTEGER;
DEFINE iRecEfeT          INTEGER;
DEFINE iRecCCT           INTEGER;
DEFINE iRecMixT          INTEGER;
DEFINE iRecTot           INTEGER;
DEFINE iRecAux           INTEGER;
DEFINE iRecLun           INTEGER;
DEFINE iRecMAr           INTEGER;
DEFINE iRecMie           INTEGER;
DEFINE iRecJue           INTEGER;
DEFINE iRecVie           INTEGER;
DEFINE iRecSab           INTEGER;
DEFINE iRecDom           INTEGER;
DEFINE iNumOpe           INTEGER;
DEFINE iDias             INTEGER;
DEFINE mLiqlun           MONEY(16,2);
DEFINE mLiqMar           MONEY(16,2);
DEFINE mLiqMier          MONEY(16,2);
DEFINE mLiqJue           MONEY(16,2);
DEFINE mLiqVie           MONEY(16,2);
DEFINE mLiqResguardo     MONEY(16,2);
DEFINE mCobEfe           MONEY(16,2);
DEFINE mCobEfeAux        MONEY(16,2);
DEFINE mCobMix           MONEY(16,2);
DEFINE mCobCC            MONEY(16,2);
DEFINE mCobCCAux         MONEY(16,2);
DEFINE mCobEfeT          MONEY(16,2);
DEFINE mCobMixT          MONEY(16,2);
DEFINE mCobCCT           MONEY(16,2);
DEFINE mCobTot           MONEY(16,2);
DEFINE mCobAux           MONEY(16,2);
DEFINE mCobLun           MONEY(16,2);
DEFINE mCobMar           MONEY(16,2);
DEFINE mCobMie           MONEY(16,2);
DEFINE mCobJue           MONEY(16,2);
DEFINE mCobVie           MONEY(16,2);
DEFINE mCobSab           MONEY(16,2);
DEFINE mCobDom           MONEY(16,2);
DEFINE mTotComision      MONEY(16,2);
DEFINE mTotIvaCom        MONEY(16,2);
DEFINE mComision         MONEY(16,2);
DEFINE mComisionAux      MONEY(16,2);
DEFINE mIvaCom           MONEY(16,2);
DEFINE mIvaComAux        MONEY(16,2);
DEFINE mAcumulado        MONEY(16,2);
DEFINE dFechaAux         DATE;
DEFINE dfecha_Hoy        DATE;
DEFINE dFechaIni         DATE;
DEFINE dPriDiaMes        DATE;
DEFINE dUltDiaMes        DATE;
DEFINE iFlagCen          INTEGER;
DEFINE iFlagSuc          INTEGER;
DEFINE cFolio            CHAR(16);
DEFINE iCuantos          INTEGER;

--INICIALIZACION DE VARIABLES
LET cCodRet2	= "00000";
LET cCodret		= "000000";
LET cInfoErr	= '';
LET cAnioMes	= '';
LET mCobEfe		= 0;
LET mCobEfeAux	= 0;
LET mCobCC		= 0;
LET mCobCCAux	= 0;
LET mCobMix		= 0;
LET iRecEfe		= 0;
LET iRecEfeAux	= '';
LET iRecCC		= 0;
LET iRecCCAux	= '';
LET iRecMix		= 0;
LET mComision	= 0;
LET mComisionAux	= 0;
LET mIvaCom		= 0;
LET mIvaComAux	= 0;
LET mCobEfeT	= 0;
LET mCobCCT		= 0;
LET iRecEfeT	= 0;
LET iRecCCT		= 0;
LET mTotComision	= 0;
LET mTotIvaCom	= 0;
LET iRecLun		= 0;
LET mCobLun		= 0;
LET iRecMar		= 0;
LET mCobMar		= 0;
LET iRecMie		= 0;
LET mCobMie		= 0;
LET iRecJue		= 0;
LET mCobJue		= 0;
LET iRecVie		= 0;
LET mCobVie		= 0;
LET iRecSab		= 0;
LET mCobSab		= 0;
LET iRecDom		= 0;
LET mCobDom		= 0;
LET cCategoria	= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio	= SUBSTRING(pConvenio FROM 3 FOR 3);
LET dFechaAux	= '';
LET dfecha_Hoy	= '';
LET dFechaIni	= '';
LET dPriDiaMes	= '';
LET dUltDiaMes	= '';
LET iNumOpe		= 0;
LET mLiqlun		= 0;
LET mLiqMar		= 0;
LET mLiqMier	= 0;
LET mLiqJue		= 0;
LET mLiqVie		= 0;
LET cFechaLiq	= "";
LET mLiqResguardo	= 0;
LET mAcumulado	= 0;
LET iFlagCen	= 0;
LET iFlagSuc	= 0;
LET cFolio		= '';
LET iCuantos	= 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/respaldosbd/hugovaz/sp_reporteliquidacionjapac.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlreportesespeciales
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio;
				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacionjapac");
			END IF;
		END EXCEPTION;

		SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
		INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
		FROM "informix".sac_fechas;

		IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

			LET dFechaAux = dfecha_Hoy - 6;
			LET dFechaIni = dFechaAux;

			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM "informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
								FROM "informix".sac_liquidacionsemanal
								WHERE id_convenio = cCategoria||cConvenio
								AND consecutivo_convenio <> 0);

			IF mAcumulado IS NULL THEN
				LET mAcumulado = 0;
			END IF;
			
			WHILE dFechaAux <= dfecha_Hoy

				LET mCobEfe = 0.00;
				LET mCobCC = 0.00;
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iRecEfe = 0;
				LET iRecCC = 0;

				FOREACH
					SELECT
						NVL(efe,0),
						NVL(cc,0),
						NVL(Rec1,''),
						NVL(Rec2,""),
						NVL(comision, 0),
						NVL(iva_com,0),
						flag_confirmacion_central,
						flag_confirmacion_sucursal,
						folio_suc
					INTO
						mCobEfeAux,
						mCobCCAux,
						iRecEfeAux,
						iRecCCAux,
						mComisionAux,
						mIvaComAux,
						iFlagCen,
						iFlagSuc,
						cFolio
					FROM TABLE(
						MULTISET(
							SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
									CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
									CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
									CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
									CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
									flag_confirmacion_central,
									flag_confirmacion_sucursal,
									folio_suc
							FROM "informix".sac_movimientoshistorial
							WHERE numcategoria = cCategoria
							AND numconvenio = cConvenio
							AND fecha_pago  = dFechaAux
							AND status_cancelado = 'N'
							AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)))

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mCobEfe = mCobEfe + mCobEfeAux;
								LET mCobCC = mCobCC + mCobCCAux;
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
									LET iRecEfe = iRecEfe +1;
								END IF;
								IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
									LET iRecCC = iRecCC +1;
								END IF;
							END IF;
						ELSE
							LET mCobEfe = mCobEfe + mCobEfeAux;
							LET mCobCC = mCobCC + mCobCCAux;
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
								LET iRecEfe = iRecEfe +1;
							END IF;
							IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
								LET iRecCC = iRecCC +1;
							END IF;
						END IF;
					ELSE
						LET mCobEfe = mCobEfe + mCobEfeAux;
						LET mCobCC = mCobCC + mCobCCAux;
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
							LET iRecEfe = iRecEfe +1;
						END IF;
						IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
							LET iRecCC = iRecCC +1;
						END IF;
					END IF;
				END FOREACH;

				LET mCobEfeT = mCobEfeT + mCobEfe;
				LET mCobCCT = mCobCCT + mCobCC;
				LET iRecEfeT = iRecEfeT + iRecEfe ;
				LET iRecCCT = iRecCCT + iRecCC;
				LET mTotComision = mTotComision + mComision;
				LET mTotIvaCom = mTotIvaCom + mIvaCom;

				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

					IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
						LET iRecLun = iRecEfe + iRecCC ;
						LET mCobLun = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;


					IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
						LET iRecMar = iRecEfe + iRecCC ;
						LET mCobMar = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
						LET iRecMie = iRecEfe + iRecCC ;
						LET mCobMie = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC ;
						LET mCobJue = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC ;
						LET mCobVie = mCobEfe + mCobCC ;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC ;
						LET mCobSab = mCobEfe + mCobCC ;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC ;
						LET mCobDom = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqlun =  mLiqlun + mCobDom;

							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

				LET dFechaAux = dFechaAux + 1;

				END IF;
			END WHILE;

			IF cCodRet2::INTEGER = 0 THEN

				INSERT INTO "informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, 				rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, 			 cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, 			   rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, cob_efectivo,
							  cob_cheqmb,cob_cheqob, cob_tarcred, liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
				VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom, mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,iRecEfeT, iRecCCT,0, 0,  mCobEfeT, mCobCCT, 0, 0,mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,0,mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo,
					  (SELECT NVL(MAX(consecutivo_convenio + 1 ),1) FROM "informix".sac_liquidacionsemanal
					   WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
		END IF;

		IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
			LET dFechaAux = dPriDiaMes;
			LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

			WHILE dFechaAux <= dfecha_Hoy

				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT NVL(importe_comision_convenio,0),NVL(iva_comision_convenio,0),
						flag_confirmacion_central, flag_confirmacion_sucursal,folio_suc
					INTO mComisionAux, mIvaComAux,iFlagCen,iFlagSuc,cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia
						WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis
							WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								LET iNumOpe = iNumOpe + 1;
							END IF;
						ELSE
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							LET iNumOpe = iNumOpe + 1;
						END IF;
					ELSE
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						LET iNumOpe = iNumOpe + 1;
					END IF;

				END FOREACH;

				INSERT INTO "informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;
			END WHILE;

		END IF;

		IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
			LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;

		UPDATE "informix".sac_controlreportesespeciales
		SET retorno = cCodret
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE
DOCUMENT
'AUTOR: EPG',
'DESCRIPCIÓN: Genera la información para los Reportes Semanal y Mensual de Pagos referenciados (JAPAC)',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de p_ProcesoCierreSAC()',
'FECHA: 22-04-2015',
'VERSIÓN: 20140625.1218',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_generaarchivocobranzacoppel_pba(cId_convenio CHAR(5))

--DEFINICION DE VARIABLES

    DEFINE cCodRet              CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cInfoErr             CHAR(100);
    DEFINE iSucursal            INTEGER;
    DEFINE iImporte             INTEGER;
    DEFINE iCantidad            INTEGER;
    DEFINE i                    INTEGER;
    DEFINE cClave               CHAR(1);
    DEFINE cCategoria           CHAR(2);
    DEFINE cMes                 CHAR(2);
    DEFINE cDia                 CHAR(2);
    DEFINE cConvenio            CHAR(3);
    DEFINE cAnio                CHAR(4);
    DEFINE cExtUnl              CHAR(4);
    DEFINE cExtTxt              CHAR(4);
    DEFINE cNomArchCPL          CHAR(15);
    DEFINE cNomArchCPLF         CHAR(15);
    DEFINE cNomArchTot          CHAR(15);
    DEFINE cNomArchTotF         CHAR(15);
    DEFINE cRutaArchCoppelTmp   CHAR(20);
    DEFINE cRutaArchTotalTmp    CHAR(25);
    DEFINE cRuta                CHAR(40);
    DEFINE cRutaFC              CHAR(50);
    DEFINE cRutaFT              CHAR(50);
    DEFINE cSql                 CHAR(100);
    DEFINE cStmt                CHAR(100);
    DEFINE cSql_Stmt            CHAR(1250);
    DEFINE dFechaIni            DATE;
    DEFINE dFecha_Hoy           DATE;
    DEFINE bFlagSeguro          BOOLEAN;
    DEFINE bFlagMovto           BOOLEAN;
	DEFINE iFlagCen             INTEGER;
	DEFINE iFlagSuc             INTEGER;
	DEFINE cFolio               CHAR(16);
	DEFINE iCuantos             INTEGER;
	DEFINE dFecha_Pago           DATE;
	DEFINE cReferencia1          CHAR(20);

 --   SET DEBUG FILE TO "/informix/EPG/Coppel.out";
 --   TRACE ON;

    --INICIALIZACION DE VARIABLES
    LET cCodRet = '00000';
    LET cStmt = '' ;
    LET cNomArchCPL = '';
    LET cNomArchCPLF = '';
    LET cRuta = '';
    LET cSql = '';
    LET bFlagSeguro = 'f';
    LET bFlagMovto = 'f';
    LET iImporte = 0;
    LET iCantidad = 0;
    LET cExtUnl = ".unl";
    LET cExtTxt = ".txt";
    LET cCategoria = SUBSTRING(cId_convenio FROM 1 FOR 2);
    LET cConvenio = SUBSTRING(cId_convenio FROM 3 FOR 3);
	LET iFlagCen      = 0;
	LET iFlagSuc      = 0;
	LET cFolio        ='';
	LET iCuantos      = 0;
	LET dFecha_Pago    = DATE(1);
	LET cReferencia1  		  = '';

    BEGIN

        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                DELETE FROM bdisac:tmpSac_MovimientosDetalleHistorial;

                UPDATE sac_controlarchivoscobranza
                SET retorno = cCodRet
                WHERE numcategoria = cCategoria
                AND numconvenio = cConvenio;

                EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_GeneraArchivoCobranzaCoppel");
            END IF;
        END EXCEPTION;

        SELECT fecha_hoy INTO dFecha_Hoy FROM bdisac:sac_fechas;

        SELECT fecha_ultimo_archivo
        INTO dFechaIni
        FROM bdisac:sac_controlarchivoscobranza
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

        INSERT INTO bdisac:tmpSac_MovimientosDetalleHistorial (clave, tipomovimiento, sucursal, ciudad, cliente, clienteetp, caja, recibo, factura, importe, saldoinicial, saldofinal,
                           saldocuenta, vencidoinicial, minimoinicial, montodolar, base, fechasaldacon, importesaldacon, tipoconvenio, subtipoconvenio, plazoconvenio,
                           ejercicio, clavetdaocob, grabacartera, anexo, clavelocal, clientelocalizar, tiposeguro, flagseguroconyugal, movtoseguro, flagmontoseguro,
                           statusseguro, causabaja, cantidadseguros, cantidadsegurosanterior, cantidadmeses, bonificacion, mesesvencidos, fechanacimiento, edad, sexo,
                           areaajuste, fechaabonoajuste, claveajuste, ajuste, sucursalorigen, numerocontrol, comision, clienteremitente, tipogastoviaje, centro, flagincluyerecibo,
                           ruta, folio, cuenta, iva, telefono, compania, contrato, credito, fechavencimiento, fechavencimientoanterior, fecha, efectuo, cajaoriginal, foliosucursal,
                           rpu, flagmovtosupervisor, interes, importeventa, folioanterior, digito, sac, fechadocumento, numerocuenta, numerosubcuenta, numeroconcepto,
                           registropatronal, formaaportacionafore, ipcarteracliente, fechamovto, candidato, statusafore)
        SELECT clave, tipomovimiento, sucursal, ciudad, cliente,clienteetp, caja, recibo, factura,importe * 100, saldoinicial, saldofinal, saldocuenta, vencidoinicial,
        minimoinicial, montodolar, base, fechasaldacon, importesaldacon, tipoconvenio, subtipoconvenio, plazoconvenio,ejercicio, clavetdaocob, grabacartera,
        anexo, clavelocal, clientelocalizar, tiposeguro, flagseguroconyugal, movtoseguro,flagmontoseguro, statusseguro, causabaja, cantidadseguros,
        cantidadsegurosanterior, cantidadmeses, bonificacion, mesesvencidos, fechanacimiento, edad, sexo, areaajuste, fechaabonoajuste, claveajuste,
        ajuste, sucursalorigen, numerocontrol, comision, clienteremitente, tipogastoviaje, centro, flagincluyerecibo, ruta, folio, cuenta, iva, telefono,
        compania, contrato, credito, fechavencimiento, fechavencimientoanterior, fecha, efectuo, cajaoriginal, foliosucursal, rpu, flagmovtosupervisor,
        interes, importeventa, folioanterior, digito, sac, fechadocumento, numerocuenta, numerosubcuenta, numeroconcepto, registropatronal, formaaportacionafore,
        ipcarteracliente, fechamovto, candidato, statusafore
        FROM bdisac:sac_movimientosdetallehistorial a, bdisac:sac_movimientoshistorial b
        ---WHERE a.fecha::date > dFechaIni
        WHERE a.fecha > dFechaIni
        ---AND a.fecha::date <= dFecha_Hoy
        AND a.fecha <= dFecha_Hoy
        AND a.cliente = b.referencia1
        AND a.recibo = b.referencia2
        AND b.numcategoria = cCategoria
        AND b.numconvenio = cConvenio
        AND NOT (status_cancelado = 'S' AND status_coppel = 0);

        LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
        LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = LPAD(YEAR(dFecha_Hoy::DATE) , 4, '0');

        SELECT TRIM(valor)
        INTO cRuta
        FROM bdisac:sac_param
        WHERE cod_param =  3;

        LET cNomArchCPL = "mvb"|| cDia||cMes||cAnio ||cExtUnl;
        LET cNomArchCPLF = "mvb"|| cDia||cMes||cAnio ||cExtTxt;
        LET cNomArchTot = "cfv"|| cDia||cMes||cAnio ||cExtUnl;
        LET cNomArchTotF = "cfv"|| cDia||cMes||cAnio ||cExtTxt;
        LET cRutaFC = TRIM(cRuta) || cNomArchCPL;
        LET cRutaFT = TRIM(cRuta) || cNomArchTot;

        LET cSql_Stmt = 'echo "UNLOAD TO ''' || SUBSTRING(cRutaFC FROM 1 FOR LENGTH(cRutaFC)) ||''' SELECT clave, tipomovimiento, sucursal, ciudad, cliente,clienteetp, caja, recibo, factura, ' ||
                        'importe, saldoinicial, saldofinal, saldocuenta, vencidoinicial, minimoinicial, montodolar, base, fechasaldacon, importesaldacon, '||
                        'tipoconvenio, subtipoconvenio, plazoconvenio,ejercicio, clavetdaocob, grabacartera, anexo, clavelocal, clientelocalizar, tiposeguro, '||
                        'flagseguroconyugal, movtoseguro,flagmontoseguro, statusseguro, causabaja, cantidadseguros, cantidadsegurosanterior, cantidadmeses, '||
                        'bonificacion, mesesvencidos, fechanacimiento, edad, sexo, areaajuste, fechaabonoajuste, claveajuste, ajuste, sucursalorigen, numerocontrol, '||
                        'comision, clienteremitente, tipogastoviaje, centro, flagincluyerecibo, ruta, folio, cuenta, iva, telefono, compania, contrato, credito, '||
                        'fechavencimiento, fechavencimientoanterior, fecha, efectuo, cajaoriginal, foliosucursal, rpu, flagmovtosupervisor, interes, importeventa, '||
                        'folioanterior, digito, sac, fechadocumento, numerocuenta, numerosubcuenta, numeroconcepto, registropatronal, formaaportacionafore, '||
                        'ipcarteracliente, fechamovto, candidato, statusafore FROM bdisac:tmpSac_MovimientosDetalleHistorial ORDER BY sucursal, caja, recibo;"'||
                        '> /tmp/tmp.sql';
        SYSTEM cSql_Stmt;

        LET cStmt = 'dbaccess bdisac /tmp/tmp.sql';
        SYSTEM cStmt;

        LET cSql = "sed 's/|$//g' " || SUBSTRING(cRutaFC FROM 1 FOR LENGTH(cRutaFC)) || " > "|| TRIM(cRuta)||cNomArchCPLF;
        SYSTEM cSql;

        FOREACH
            SELECT DISTINCT(sucursal)
            INTO iSucursal
            FROM tmpSac_MovimientosDetalleHistorial
            ORDER BY sucursal

            FOR i = 1 TO 23
                    IF i = 1 THEN
                        LET bFlagMovto = 't';
                        LET cClave = 'S';
                    ELIF i = 2 THEN
                        LET bFlagMovto = 't';
                        LET cClave = 'I';
                    ELIF i = 3 THEN
                        LET bFlagSeguro = 't';
                        LET bFlagMovto = 't';
                        LET cClave = 'G';
                    ELIF i = 4 THEN
                        LET bFlagSeguro = 't';
                        LET bFlagMovto = 't';
                        LET cClave = 'G';
                    ELIF i = 18 THEN
                        LET bFlagMovto = 't';
                        LET cClave = 'S';
                    ELIF i = 19 THEN
                        LET bFlagMovto = 't';
                        LET cClave = 'S';
                    ELIF i = 21 THEN
                        LET bFlagMovto = 't';
                        LET cClave = 'S';
                    END IF;

                    IF bFlagMovto = 't' THEN
                        IF bFlagSeguro= 't' THEN
                            IF i = 3 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento = '1'
                                                    AND movtoseguro <> 'C'
                                                    AND sucursal = iSucursal));
                            ELIF i = 4 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento = '1'
                                                    AND movtoseguro = 'C'
                                                    AND sucursal = iSucursal));
                            END IF;
                        ELSE
                            IF i = 1 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento IN ('1', '5', '6', '7', 'I', 'J', 'K', 'L', 'R', 'S')
                                                    AND sucursal = iSucursal));
                            ELIF i = 2 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento IN ('1', '2', '3', '4')
                                                    AND sucursal = iSucursal));
                            ELIF i = 18 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento = 'B'
                                                    AND sucursal = iSucursal));
                            ELIF i = 19 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento = 'D'
                                                    AND sucursal = iSucursal));
                            ELIF i = 21 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento = 'C'
                                                    AND sucursal = iSucursal));
                            END IF;
                        END IF;
                    END IF ;
                    INSERT INTO bdisac:sac_totalmovimientosdetallehistorial (tipo, importe, cantidad, sucursal, fecha, fecha_movto)
                    VALUES (i, iImporte, iCantidad, iSucursal, dFecha_hoy, CURRENT);
								
                    LET bFlagMovto = 'f';
                    LET bFlagSeguro= 'f';
                    LET cClave = '';
                    LET iImporte = 0;
                    LET iCantidad = 0;
            END FOR;
		END FOREACH;
		
		FOREACH
			SELECT {+INDEX (bdisac:sac_movimientoshistorial idxsac_movhisfe)} referencia1,flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago
			INTO  cReferencia1, iFlagCen, iFlagSuc, cFolio, dFecha_Pago
			FROM bdisac:sac_movimientoshistorial
			WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago > dFechaIni
				AND fecha_pago <= dFecha_Hoy
				AND status_cancelado <> 'S'
				AND (flag_confirmacion_central = 1
				OR flag_confirmacion_sucursal = 1)
				
			IF iFlagCen = 0 or iFlagSuc =0 THEN
				SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movdia WHERE empresa = '001' AND folio_suc = cFolio
--2014.06.02 FRG-i
				and cancelad <> 'S';
--2014.06.02 FRG-f
				IF iCuantos = 0 THEN
					SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND fech_alt = dFecha_Pago
--2014.06.02 FRG-i
				and cancelad <> 'S';
--2014.06.02 FRG-f
					IF iCuantos = 0 THEN
						CONTINUE FOREACH;
					END IF;
				END IF;
				IF iCuantos > 0 THEN            
					UPDATE bdisac:sac_movimientoshistorial SET flag_confirmacion_sucursal='1'
					WHERE numcategoria = cCategoria
						AND numconvenio = cConvenio
						AND fecha_pago = dFecha_Pago
						AND folio_suc = cFolio
						AND referencia1 = cReferencia1
						AND status_cancelado <> 'S'
						AND flag_confirmacion_sucursal = 0;  

					INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
					VALUES (cCategoria,cConvenio,cReferencia1,cFolio,dFecha_Pago,current);
				END IF;
			END IF;
		END FOREACH;

        LET cSql_Stmt = '';
        LET cSql_Stmt = 'echo "UNLOAD TO ''' || SUBSTRING(cRutaFT FROM 1 FOR LENGTH(cRutaFT)) || ''' SELECT tipo, importe, cantidad, sucursal, fecha, fecha_movto ' ||
                        'FROM bdisac:sac_totalmovimientosdetallehistorial WHERE fecha = (SELECT fecha_hoy FROM bdisac:sac_fechas) " > /tmp/tmp.sql';

        SYSTEM cSql_Stmt;

        LET cStmt = 'dbaccess bdisac /tmp/tmp.sql';
        SYSTEM cStmt;

        LET cSql = "sed 's/|$//g' "|| SUBSTRING(cRutaFT FROM 1 FOR LENGTH(cRutaFT)) || " > " || TRIM(cRuta) || cNomArchTotF;
        SYSTEM cSql;

        DELETE FROM bdisac:tmpSac_MovimientosDetalleHistorial;
        LET cStmt = 'rm -f /tmp/tmp.sql';
        SYSTEM cStmt;

        UPDATE sac_controlarchivoscobranza
        SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : José Angel López Adams',
'DESCRIPCION: Genera el archivo de cobranza Coppel de acuerdo a Layout proporcionado por la misma empresa',
'Sucursales',
'EJECUTADO O LLAMADO POR:',
'sp_genera_ArchivosCobranzaCentral()',
'FECHA : Agosto de 2008',
'VERSION: 200808',
'BD    : bdisac',
'MODIFICACION: Se modifica el criterio de extraccin de la informacion de la tabla temporal para contemplar el numero de convenio coppel',
'FECHA : 01/06/2009',
'AUTOR : José Angel López Adams',
'MODIFICACION: Se modifica para que seleccione todos los movimientos sin importar si estan cancelados o no ',
'FECHA MODIFICACION: 19/06/2009',
'AUTOR MODIFICACION: Dulce Ramírez',
'MODIFICACION: Se modifica al contabilizar el número de movimientos se contemplen los CANCELADOS, pero la sumatoria de importes solo se hará de los ACTIVOS ',
'FECHA MODIFICACION: 17/07/2009',
'AUTOR : José Angel López Adams',
'MODIFICACION: Se modifica para contemplar en el archivo de cobranza los movimientos para tiempo aire y deuda bancoppel',
'FECHA MODIFICACION: 30/07/2009',
'AUTOR : Raul Rene Ruiz Rodriguez',
'MODIFICACION: Se modifica para contabilizar correctamente los movimientos de seguros ya que los movimientos de seguros afirme se estaban contemplando tambien dentro del conteo de los seguros club',
'FECHA MODIFICACION: 16/10/2009',
'AUTOR : José Angel López Adams',
'MODIFICACION: Se modifica para descartar los movimientos que no sean confirmados y esten cancelados(reversos automaticos)',
'FECHA MODIFICACION: 21/10/2009',
'AUTOR : Julio Cesar Polanco Inzunza',
'AUTOR: FRG',
'DESCRIPCIÓN: se agrega condición para considerar registros de cheques que NO estén reversados.',
'FECHA:02/Jun/2014';

CREATE PROCEDURE "informix".sp_generaarchivocobranzajapac(pConvenio CHAR(5))

-- DEFINICION DE VARIABLES
DEFINE cCodRet				CHAR(5);
DEFINE iSqlErr				INTEGER;
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(2);
DEFINE cAnio2				CHAR(4);
DEFINE cDiaI				CHAR(2);
DEFINE cMesI				CHAR(2);
DEFINE cAnioI				CHAR(4);
DEFINE cDiaPago				CHAR(2);
DEFINE cMesPago				CHAR(2);
DEFINE cAnioPago				CHAR(4);
DEFINE cCategoria				CHAR(2);
DEFINE cConvenio				CHAR(3);
DEFINE cReferencia1			CHAR(22);
DEFINE cRutaArchJAPAC		CHAR(100);
DEFINE cStmt				CHAR(250);
DEFINE cFolio				CHAR(16);
DEFINE cTpoOperacion			CHAR(1);
DEFINE dFechaIni				DATE;
DEFINE dFecha_Hoy				DATE;
DEFINE iImporte_Pago			DECIMAL(9,0);
DEFINE iTotal_Pago			DECIMAL(12,0);
DEFINE iFlagCen				INTEGER;
DEFINE iFlagSuc				INTEGER;
DEFINE iCuantos				INTEGER;
DEFINE iNumPagos				INTEGER;
DEFINE cHora				CHAR(2);
DEFINE cMinuto	  			CHAR(2);
DEFINE cSucursal				CHAR(4);
DEFINE dFechaPago				DATE;
DEFINE cNombreSuc			CHAR(25);

--INICIALIZACION DE VARIABLES--
LET cCodRet					= "00000";
LET iSqlErr					= 0;
LET cCategoria				= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio				= SUBSTRING(pConvenio FROM 3 FOR 3);
LET cReferencia1				= '';
LET cDia					= '';
LET cMes					= '';
LET cAnio					= '';
LET cAnio2					= '';
LET cDiaI					= '';
LET cMesI					= '';
LET cAnioI					= '';
LET cDiaPago				= '';
LET cMesPago				= '';
LET cAnioPago				= '';
LET iImporte_Pago				= 0;
LET iTotal_Pago				= 0;
LET cFolio					= '';
LET iFlagCen				= 0;
LET iFlagSuc				= 0;
LET cRutaArchJAPAC			= '';
LET iCuantos				= 0;
LET cStmt					= '';
LET dFechaIni				= DATE(1);
LET dFecha_Hoy				= DATE(1);
LET cTpoOperacion				= '2';
LET iNumPagos				= 0;
LET cHora					= '';
LET cMinuto					= '';
LET cSucursal				= '';
LET dFechaPago				= DATE(1);
LET cNombreSuc				= '';

	--SET DEBUG FILE TO  '/informix/adrian/sp_generaarchivocobranzajapac.out';
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlarchivoscobranza
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND   numconvenio = cConvenio;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM "informix".sac_fechas
		WHERE empresa = "001";
		
		--SELECCIONA LA FECHA DEL ULTIMO ARCHIVO GENERADO
		SELECT fecha_ultimo_archivo
		INTO dFechaIni
		FROM "informix".sac_controlarchivoscobranza
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

		--ASIGNA VALOR PARA FECHA INICIAL
		IF dFechaIni = dFecha_Hoy THEN
			LET cDiaI = LPAD(DAY(dFechaIni::DATE) , 2, '0');
		ELSE
			LET cDiaI = LPAD(DAY((dFechaIni + 1 UNITS DAY)::DATE) , 2, '0');
		END IF;
		LET cMEsI = LPAD(MONTH(dFechaIni::DATE), 2, '0');
		LET cAnioI = LPAD(YEAR(dFechaIni::DATE),4,'0');
		
		--ASIGNA VALOR PARA FECHA FIN
		LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
		LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
		LET cAnio = LPAD(SUBSTRING(YEAR(dFecha_Hoy ::DATE) FROM 3 FOR 2), 2, '0'); 
		LET cAnio2 = YEAR(dFecha_Hoy ::DATE); 

		--SELECCIONA LA RUTA DONDE SE GUARDARA EL ARCHIVO
		SELECT TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza)
		INTO cRutaArchJAPAC
		FROM "informix".sac_convenios
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

		
		LET cRutaArchJAPAC = REPLACE(cRutaArchJAPAC,'DD',cDia);
		LET cRutaArchJAPAC = REPLACE(cRutaArchJAPAC,'MM',cMes);
		LET cRutaArchJAPAC = REPLACE(cRutaArchJAPAC,'AA',cAnio);
	

		--IMPRIME EL ENCABEZADO DEL ARCHIVO
		LET cStmt='echo "' || '1,001 JAPAC           ,' || cAnioI || cMEsI || cDiaI || ',' || cAnio2 || cMes || cDia || '" >> ' || cRutaArchJAPAC;
			SYSTEM cStmt;
			
		FOREACH

			SELECT fecha_pago,
				LPAD(DAY(fecha_pago::DATE), 2, '0'),
				LPAD(MONTH(fecha_pago::DATE), 2, '0'),
				LPAD(YEAR(fecha_pago::DATE), 4, '0'),
				LPAD(SUBSTR(fecha_insert,12,2),2,'0'),
				LPAD(SUBSTR(fecha_insert,15,2),2,'0'),
				case when origen = 'CPL' then LPAD(REPLACE(NVL(sucursal_cpl,''),'','0'),4,'0') else LPAD(REPLACE(NVL(id_sucursal,''),'','0'),4,'0') end,
				NVL(folio_suc,''),
				NVL(referencia1,''),
				NVL(importe_pago,0)*100,
				NVL(flag_confirmacion_central,0),
				NVL(flag_confirmacion_sucursal,0)
				INTO dFechaPago,cDiaPago,cMesPago,cAnioPago,cHora,cMinuto,cSucursal,cFolio,cReferencia1,iImporte_Pago,iFlagCen,iFlagSuc
				FROM "informix".sac_movimientoshistorial
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago > dFechaIni
				AND fecha_pago <= dFecha_Hoy
				AND status_cancelado <> 'S'
				AND (flag_confirmacion_central = 1
				OR flag_confirmacion_sucursal = 1)		
				
				IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_sucursales
					WHERE sucursal = cSucursal) THEN
					SELECT NVL(REPLACE(nombre,',',' '),'')
					INTO cNombreSuc
					FROM bdinteg:"informix".si_sucursales
					WHERE sucursal = cSucursal;
				ELSE
					LET cNombreSuc = '';
				END IF;

				--ACTUALIZACION DE FLAG_CONFIRMACION_SUCURSAL = 1 EN CASO DE QUE NO SE HAYA CONFIRMADO EN SUCURSAL POR ALGUN MOTIVO
				IF iFlagCen = 0 OR iFlagSuc = 0 THEN
					SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S';
					IF iCuantos = 0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S' AND  fech_alt = dFechaPago;
						IF iCuantos = 0 THEN
							CONTINUE FOREACH;
						END IF;
					END IF;
				END IF;

				IF iCuantos > 0 THEN
					UPDATE "informix".sac_movimientoshistorial SET flag_confirmacion_sucursal = '1'
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago = dFechaPago
					AND folio_suc = cFolio
					AND referencia1 = cReferencia1
					AND status_cancelado <> 'S'
					AND flag_confirmacion_sucursal = 0;
				END IF;

				LET iTotal_Pago = iTotal_Pago + iImporte_Pago ;
				LET iNumPagos = iNumPagos + 1;

				--IMPRIME RENGLON DE LAS OPERACIONES
				LET cStmt = 'echo "' || cTpoOperacion || ',' || SUBSTR(cReferencia1,4,9) || ',' || SUBSTR(cReferencia1,13,9) || ',' || LPAD(iImporte_Pago,9,0) || ',' || cAnioPago || cMesPago || cDiaPago || ',' || cHora || cMinuto || '  ,' || cSucursal || ' ' || RPAD(cNombreSuc, 25,' ') || '" >> ' || cRutaArchJAPAC;
				SYSTEM cStmt;
		END FOREACH;		

		--IMPRIME RENGLON DE TOTAL
		LET cTpoOperacion = '3';			
		LET cStmt = 'echo "' || cTpoOperacion || ',' || RPAD((iNumPagos::CHAR), 4, ' ') || ',' || LPAD(iTotal_Pago, 12, 0) || '" >> ' || cRutaArchJAPAC;
		SYSTEM cStmt;
		
		--ACTUALIZA LA FECHA DEL ULTIMO ARCHIVO GENERADO
		UPDATE "informix".sac_controlarchivoscobranza
		SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE;