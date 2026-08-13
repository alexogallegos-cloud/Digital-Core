CREATE PROCEDURE "informix".sp_eliminar_registros_indicadores
(
pAniomes CHAR(6)
)
RETURNING
	CHAR(6) 	AS cod_ret,
	CHAR(80)	AS desc_ret

	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
	DEFINE cDescRet			CHAR(80);

	DEFINE vabierto     CHAR(1);
	DEFINE vcontador3   INTEGER;
	DEFINE idRow		INT8;
	
	
	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	LET cDescRet			= "PROCESO EXITOSO";

	LET vabierto   = '0';
	LET vcontador3 = 0;
	LET idRow 	   = 0;


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescRet = cErrorInfo;
            IF vabierto = '1' THEN
                ROLLBACK WORK;
            END IF;
			RETURN cCodRet, cDescRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/informix/moha/sp_insertar_primer_deposito_sc_movhis.out';
	--TRACE ON;
	
	FOREACH WITH HOLD
		SELECT ROWID
		INTO idRow
		FROM "informix".sc_indicadores
		WHERE anio_mes = pAniomes

		DELETE "informix".sc_indicadores WHERE anio_mes = pAniomes AND ROWID = idRow;
		
		IF vcontador3 = 0 THEN
			BEGIN WORK;
			LET vabierto = '1'; 
		END IF
	
		LET vcontador3 = vcontador3 + 1;
		
		IF vcontador3 = 5000 THEN
			LET vabierto = '0';
			LET vcontador3 = 0;
			COMMIT WORK;
		END IF
		
	END FOREACH

	IF vcontador3 > 0 THEN
		COMMIT WORK;
	END IF	

	RETURN cCodRet, cDescRet;
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para eliminar los registros generados que se quedaron a medias',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Noviembre 2014';

CREATE PROCEDURE "informix".sp_inicializar_mes_registros_indicadores()
RETURNING
	CHAR(6),
	CHAR(80)

	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
	DEFINE cDescRet			CHAR(80);
	DEFINE vabierto     	CHAR(1);
	DEFINE vcontador3   	INTEGER;
	DEFINE cCodRetMesSig	CHAR(5);
	DEFINE iDiasTransc		INTEGER;

	DEFINE cAnioMesActual	CHAR(6);
	DEFINE cAnioMesSig		CHAR(6);
	DEFINE cProducto		CHAR(4);
	DEFINE cCuenta			CHAR(20);
	DEFINE cSucursal		CHAR(4);
	DEFINE dtMesiversario	DATE;
	DEFINE dtFechaApertura	DATE;
	DEFINE dtFechaDepOrig	DATE;
	DEFINE dImporteDepOrig	DECIMAL(14,2);

	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	LET cDescRet			= "PROCESO EXITOSO";
	LET vabierto   			= '0';
	LET vcontador3 			= 0;

	LET cAnioMesActual		= "";
	LET cAnioMesSig			= "";
	LET cProducto			= "";
	LET cCuenta				= "";
	LET cSucursal			= "";
	LET dtMesiversario		= DATE(1);
	LET cCodRetMesSig		= "00000";
	LET iDiasTransc			= 0;
	LET dtFechaApertura		= DATE(1);
	LET dtFechaDepOrig		= DATE(1);
	LET dImporteDepOrig		= 0.0;


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescRet = cErrorInfo;
            IF vabierto = '1' THEN
                ROLLBACK WORK;
            END IF;
			RETURN cCodRet, cDescRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/informix/moha/sp_inicializar_mes_registros_indicadores.out';
	--TRACE ON;
		
	SELECT YEAR(fecha_hoy) || LPAD(MONTH(fecha_hoy),2,"0"), YEAR(fecha_hoy + 1 units MONTH) || LPAD(MONTH(fecha_hoy + 1 units MONTH),2,"0")
	INTO cAnioMesActual, cAnioMesSig
	FROM "informix".sc_fechas
	WHERE empresa = "001";
	
	FOREACH WITH HOLD
		SELECT producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig
		INTO cProducto, cCuenta, dtFechaApertura, cSucursal, dtMesiversario, dtFechaDepOrig, dImporteDepOrig
		FROM "informix".sc_indicadores_paso
		WHERE anio_mes = cAnioMesActual
		
		IF vcontador3 = 0 THEN
			BEGIN WORK;
			LET vabierto = '1'; 
		END IF

		EXECUTE PROCEDURE "informix".sp_mes_siguiente(TODAY, 1, DAY(dtFechaApertura - 1 UNITS DAY))
		INTO cCodRetMesSig, dtMesiversario, iDiasTransc;
		
		INSERT INTO "informix".sc_indicadores_paso
		(empresa, anio_mes, producto, cuenta, fecha_apertura, sucursal_apertura, fecha_mesiversario, fec_prim_deposito_orig, imp_prim_deposito_orig) 
		VALUES("001", cAnioMesSig, cProducto, cCuenta, dtFechaApertura, cSucursal, dtMesiversario, dtFechaDepOrig, dImporteDepOrig);
		
		LET vcontador3 = vcontador3 + 1;
		
		IF vcontador3 = 5000 THEN
			LET vabierto = '0';
			LET vcontador3 = 0;
			COMMIT WORK;
		END IF
	END FOREACH	

	IF vcontador3 > 0 THEN
		COMMIT WORK;
	END IF	
	
	RETURN cCodRet, cDescRet;
    	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para insertar el registro de cada cuenta de los indicadores de captación para el mes actual',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Julio 2014';

CREATE PROCEDURE "informix".sp_ctamec_generarptportada (pEmpresa CHAR(3), pNumCte CHAR(20), pNumCta CHAR(20))

	-- DATOS A REGRESAR --
	RETURNING
	CHAR(5) AS COD_RET,    		-- Codigo de retorno
	CHAR(4) AS COD_PRODUCTO,   	--CODIGO DEL PRODUCTO
	CHAR(40) AS NOM_PRODUCTO, 	--NOMBRE DEL PRODUCTO
	CHAR(104) AS RAZON_SOC, 		--RAZON SOCIAL
	CHAR(20) AS NUM_CLIENTE, 	--NUMERO DEL CLIENTE
	CHAR(20) AS NUM_CUENTA,		--NUMERO DE LA CUENTA
	CHAR(18) AS CLABE,			--NUMERO CLABE
	CHAR(1) AS CLAVE_REGIMEN,	--CLAVE DEL REGIMEN DE FIRMAS
	CHAR(20) AS REGIMEN_FIRMAS,	--REGIMEN DE FIRMAS
	CHAR(20) AS ESPECI_MANEJO,	--ESPECIFICACIONES DE MANEJO, COMBINACION
	CHAR(13) AS RFC,			--RFC
	DATE AS FECHA_OPERACION,	--FECHA DE LA OPERACION
	CHAR(104) AS NOMBRE_FIRMANTE,--NOMBRE DE EL FIRMANTE
	CHAR(1) AS TIPO_FIRMA,		--TIPO DE FIRMA
	CHAR(4)	AS	SUCURSAL,		--NUMERO DE SUCURSAL
	CHAR(40) AS	NOMSUC,			--NOMBRE DE SUCURSAL
	CHAR(60) AS	RECA;			--DESCRIPCION DE RECA
	
	--	VARIABLES CONTROL DE ERRORES --
	DEFINE cCodRet  CHAR(5);
	DEFINE iSqlErr  INTEGER;
	
	-- VARIABLES --
	DEFINE cCodReg	CHAR(2);
	DEFINE cCodProd CHAR(4);
	DEFINE cNomProd CHAR(40);
	DEFINE cRazon CHAR(104);
	DEFINE cNumCte CHAR(20);
	DEFINE cNumCta CHAR(20);
	DEFINE cClabe CHAR(18);
	DEFINE cClaveReg CHAR(1);
	DEFINE cRegimen CHAR(20);
	DEFINE cCombinacion CHAR(20);
	DEFINE cRfc CHAR(13);
	DEFINE dFecha DATE;
	DEFINE cFirmNom CHAR(104);
	DEFINE cTipoFirma CHAR(1);
	DEFINE cNumCteFir CHAR(20);
	DEFINE cProducto CHAR(4);
	DEFINE iParam SMALLINT;
	DEFINE cSuc	CHAR(4);
	DEFINE cNomSuc CHAR(40);
	DEFINE cSufijo CHAR(60);	--DSB 16/05/2013
	DEFINE cReca CHAR(60);

	-- INICIALIZACION DE VARIABLES --
	LET cCodRet  = "000";
	LET cCodReg = "00";
	LET cCodProd = "";
	LET cNomProd = "";
	LET cRazon ="";
	LET cNumCte ="";
	LET cNumCta ="";
	LET cClabe ="";
	LET cClaveReg = "";
	LET cRegimen ="";
	LET cCombinacion ="";
	LET cRfc ="";
	LET dFecha ="";
	LET cFirmNom ="";
	LET cTipoFirma ="";
	LET cNumCteFir="";
	LET cProducto ="";
	LET iParam = 0;
	LET iSqlErr = 0;
	LET cSuc	= "";
	LET cNomSuc	= "";
	LET cSufijo = "";	--DSB 16/05/2013
	LET cReca = "";
		
	--SET DEBUG FILE TO "/respaldosbd/joseluis/sp_ctamec_generarptportada.out";
	--TRACE ON;
	
	-- CONTROL DE ERRORES --	
BEGIN
	ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
        END IF
	END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
/*
	IF NVL(pNumCte,'') = '' THEN --SI NO SE PROPORCIONA EL CLIENTE  
		LET pNumCte = NULL;
	END IF
	
	IF pNumCta = "" THEN --SI NO SE PROPORCIONA CUENTA
		LET pNumCta = NULL;
	END IF
*/	
	IF NVL(pNumCta,'') = '' AND NVL(pNumCte,'') = '' OR NVL(pEmpresa,'') = '' THEN --VERIFICA QUE HAYA ALMENOS UN PARAMETRO DE BUSQUEDA
		LET cCodRet = "110";
		RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
	END IF
	
	IF TRIM(pNumCta) <> '' AND TRIM(pNumCte) <> '' THEN
		LET cCodRet = "310"; -- SOLAMENTE DEBE ENVIAR UN SOLO PARAMETRO.
		RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
	END IF
	
	--OBTENEMOS LA FECHA ACTUAL
	SELECT fecha_hoy 
	INTO dFecha
	FROM bdicheq:"informix".sc_fechas
	WHERE empresa = pEmpresa;
	
	
	IF TRIM(NVL(pNumCta,'')) = '' THEN --OBTENEMOS TODOS LOS FIRMANTES POR CUENTA POR EL NUMERO DEL CLIENTE
		LET cNumCte = pNumCte;
		
		--OBTENEMOS LA RAZON SOCIAL DEL CLIENTE Y EL RFC
		SELECT TRIM(nombre1)|| ' '||TRIM(nombre2)||' '|| TRIM(apell_paterno)||' '||TRIM(apell_materno)||' '||TRIM(razon_social) AS nombre,rfc
		INTO cRazon, cRfc
		FROM bdinteg:"informix".si_cliente 
		WHERE empresa = pEmpresa
		AND numcte = pNumCte;
		
		--DSB 16/05/2013		
		SELECT NVL(descripcion, '')
		INTO cSufijo
		FROM bdinteg:"informix".si_sufijos suf,
		bdinteg:"informix".si_ctepm cte
		WHERE suf.codigo = cte.sufijo
		AND cte.numcte = pNumCte;
		LET cRazon = TRIM(cRazon)||" "||TRIM(NVL(cSufijo,''));
		
		IF NVL(cRfc,'') = '' THEN --NO EXISTE EL CLIENTE 
			LET cCodRet = '104';
			RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
		END IF;
		
		
		FOREACH
		--OBTENEMOS LAS CUENTAS DEL CLIENTE Y LA SUCURSAL DE LAS MISMAS.
			SELECT sc_m.cuenta,sc_m.cuenta_clabe, sc_mn.reg_firmas,sc_m.producto, sc_m.sucursal, si.nombre
			INTO cNumCta,cClabe,cClaveReg, cProducto, cSuc, cNomSuc
			FROM bdicheq:"informix".sc_maechq sc_m,
				 bdicheq:"informix".sc_maenoc sc_mn,
				 bdinteg:"informix".si_sucursales si
			WHERE sc_m.empresa = sc_mn.empresa 
			AND sc_m.empresa = pEmpresa
			AND sc_mn.cuenta = sc_m.cuenta
			AND sc_m.num_cte = pNumCte
			AND sc_m.sucursal = si.sucursal
			
			
			--OBTENEMOS LA DESCRIPCION DEL REGIMEN Y LA COMBINACION
			SELECT descripcion,combinacion
			INTO cRegimen,cCombinacion
			FROM bdicntchq:"informix".sq_catregimen 
			WHERE cve_regimen = cClaveReg;
			
			--OBTENEMOS EL CODIGO DEL PRODUCTO Y SU NOMBRE
			SELECT producto,nombre
			INTO cCodProd,cNomProd
			FROM bdicheq:"informix".sc_producto 
			WHERE empresa = pEmpresa
			AND producto = cProducto;
		
			--OBTENEMOS EL VALOR RECA
			SELECT valor
			INTO cReca
			FROM "informix".sc_param
			WHERE empresa = "001"
			AND codparam = "REKA" || cCodProd;
		
			FOREACH
			--OBTENEMOS A LOS FIRMANTES DE LA CUENTA
				SELECT numcte,tipo_firma
				INTO cNumCteFir, cTipoFirma
				FROM bdicheq:"informix".sc_firmantes
				WHERE empresa = pEmpresa			
				AND cuenta = cNumCta
				ORDER BY tipo_firma, secuencia
			
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '|| TRIM(apell_paterno)||' '||TRIM(apell_materno) AS nombre
				INTO cFirmNom
				FROM bdinteg:"informix".si_cliente
				WHERE empresa = pEmpresa
				AND numcte = cNumCteFir;
			
				LET iparam = 1;
		
		
			RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca) WITH RESUME;
		
			END FOREACH;
		END FOREACH;
		
	ELSE --SE REALIZA LA BUSQUEDA POR CUENTA
	
		LET cNumCta = pNumCta;
		--OBTENEMOS EL NUMERO DE CLIENTE, LA CUENTA CLABE Y EL NUMERO DE SUCURSAL DE LA CUENTA.
		SELECT sc.cuenta, sc.num_cte, sc.cuenta_clabe, sc.producto, sc.sucursal, si.nombre
		INTO cNumCta, cNumCte, cClabe, cCodProd, cSuc, cNomSuc
		FROM bdicheq:"informix".sc_maechq sc,
			 bdinteg:"informix".si_sucursales si	
		WHERE sc.empresa = pEmpresa
		AND sc.cuenta = pNumCta
		AND sc.sucursal = si.sucursal;
		
		IF cNumCte IS NULL THEN --NO EXISTE EL NUMERO DE CUENTA
			LET cCodRet = '200';
			RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
		END IF;
		
		--OBTENEMOS EL NOMBRE DEL PRODUCTO
		SELECT nombre 
		INTO cNomProd
		FROM bdicheq:"informix".sc_producto 
		WHERE empresa= pEmpresa
		AND producto = cCodProd;
		
		IF cNumCte IS NULL THEN --NO EXISTE EL PRODUCTO
			LET cCodRet = '210';
			RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
		END IF;
		
		--OBTENEMOS LA RAZON SOCIAL, Y EL RFC
		SELECT TRIM(nombre1)|| ' '||TRIM(nombre2)||' '|| TRIM(apell_paterno)||' '||TRIM(apell_materno)||' '||TRIM(razon_social) AS nombre,rfc 
		INTO cRazon, cRfc
		FROM bdinteg:"informix".si_cliente 
		WHERE empresa = pEmpresa
		AND	numcte = cNumCte;
		
		--DSB 16/05/2013		
		SELECT NVL(descripcion, '')
		INTO cSufijo
		FROM bdinteg:"informix".si_sufijos suf,
		bdinteg:"informix".si_ctepm cte
		WHERE suf.codigo = cte.sufijo 
		AND cte.numcte = cNumCte;
		LET cRazon = TRIM(cRazon)||" "||TRIM(NVL(cSufijo,''));
		
		IF cRazon IS NULL THEN --NO EXISTE EL NUMERO DE CUENTA
			LET cCodRet = '250';
			RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
		END IF;
		
		--OBTENEMOS EL REGIMEN DE FIRMAS
		SELECT reg_firmas 
		INTO cClaveReg 
		FROM bdicheq:"informix".sc_maenoc
		WHERE empresa = pEmpresa
		AND cuenta = pNumCta;
		
		IF cClaveReg IS NULL THEN --NO EXISTE EL NUMERO DE CUENTA EN TABLA MAENOC
			LET cCodRet = '260';
			RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
		END IF;
	
		--OBTENEMOS LA DESCRIPCION DEL REGIMEN DE FIRMAS Y LA COMBINACION
		SELECT descripcion, combinacion
		INTO cRegimen, cCombinacion
		FROM bdicntchq:"informix".sq_catregimen
		WHERE cve_regimen = cClaveReg;
		
		IF cRegimen IS NULL THEN --NO EXISTE EL TIPO DE REGIMEN
			LET cCodRet = '270';
			RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
		END IF;
		
		--OBTENEMOS EL VALOR RECA
		SELECT valor
		INTO cReca
		FROM "informix".sc_param
		WHERE empresa = "001"
		AND codparam = "REKA" || cCodProd;
	
		--OBTENEMOS A LOS FIRMANTES
		FOREACH
			SELECT numcte,tipo_firma
			INTO cNumCteFir, cTipoFirma
			FROM bdicheq:"informix".sc_firmantes
			WHERE empresa = pEmpresa			
			AND cuenta = pNumCta
			ORDER BY tipo_firma, secuencia
			
			SELECT TRIM(nombre1)|| ' '||TRIM(nombre2)||' '|| TRIM(apell_paterno)||' '||TRIM(apell_materno) AS nombre
			INTO cFirmNom
			FROM bdinteg:"informix".si_cliente
			WHERE empresa = pEmpresa
			AND numcte = cNumCteFir;
			
			LET iparam = 1;

		RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca) WITH RESUME;
		
		END FOREACH;
	
	END IF;
	
	IF iParam = 0 THEN --NO HAY DATOS DE FIRMANTES CON ESOS CRITERIOS
		LET cCodRet = '300';
		RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
	END IF
	
END
END PROCEDURE
DOCUMENT
'Procedimiento   : GenerarRptPortadaCtaEjeEmpresarialChequesSPL',
'Versión         : 1.0',
'Creado por      : Victor Hugo Nuñez Velazquez',
'Fecha creacion  : 13 Junio 2011',
'Descripcion     : Obtiene todos los firmantes de una cuenta en particular y obtiene todos los firmantes por cuentas por el numero del cliente',
'Procedimiento   : GenerarRptPortadaCtaEjeEmpresarialChequesSPL',
'Modificado por  : Armando Morales Barraza',
'Fecha creacion  : 14 Marzo 2012',
'Descripcion     : Obtiene el numero y nombre de sucursal de la cuenta',
'MODIFICO: Jose Luis Polanco B.',
'FECHA: DSB 16/05/2013',
'DESCRIPCION: Se agrega el "sufijo" a la variable de retorno "cRazon" para que aparesca en los reportes';

CREATE PROCEDURE "informix".consctactebeneficiario(pEmpresa CHAR(3), pNumeroTarjeta CHAR(20))
	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
	CHAR(20), -- Numero de Cuenta
	CHAR(20), -- Numero de Cliente
	CHAR(26), -- Apellido Paterno
	CHAR(26), -- Apellido Materno
	CHAR(26), -- Nombre1
	CHAR(26), -- Nombre2
	CHAR(13); -- RFC


	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr INTEGER;
	DEFINE vCodRet CHAR(5);
	DEFINE vNumCuenta CHAR(20);
	DEFINE vNumCliente CHAR(20);
	DEFINE vApePat CHAR(26);
	DEFINE vApeMat CHAR(26);
	DEFINE vNombre1 CHAR(26);
	DEFINE vNombre2 CHAR(26);
	DEFINE vRFC CHAR(13);
	DEFINE cProdTransfer CHAR(4);
	DEFINE cProdTarjeta CHAR(4);
	

	--INICIALIZACION DE VARIABLES--
	LET iSqlErr = 0;
	LET vCodRet = "000";
	LET cProdTransfer = "";
	LET cProdTarjeta = "";
	LET vNumCuenta  = "";
	LET vNumCliente = "";
	LET vApePat = "";
	LET vApeMat = "";
	LET vNombre1 = "";
	LET vNombre2 = "";
	LET vRFC = "";
	
	 BEGIN
        ON EXCEPTION SET iSqlErr
            LET vCodRet = iSqlErr;
            RETURN vCodRet, vNumCuenta, vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC;
        END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;	
	
    -- SET DEBUG FILE TO "/tmp/consctactebeneficiario.out";
	-- TRACE ON;
	  
	-- CONSULTA --
	SELECT
		bdc_sctar.cuenta, bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2, bdi_sicte.rfc
	INTO
		vNumCuenta, vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC
	FROM
		bdicheq:"informix".sc_tarjeta bdc_sctar,
		bdicheq:"informix".sc_maechq dbc_sdmachq,
		bdinteg:"informix".si_cliente bdi_sicte
	WHERE
		bdc_sctar.empresa = pEmpresa AND
		bdc_sctar.tipo_tarjeta = "T" AND
		bdc_sctar.num_tarjeta = pNumeroTarjeta AND
		bdc_sctar.cuenta = dbc_sdmachq.cuenta AND
		dbc_sdmachq.num_cte = bdi_sicte.numcte AND
		bdi_sicte.tpo_persona = "01";


	SELECT valor
	INTO cProdTransfer
	FROM bditransfer:"informix".tf_param 
	WHERE cod_param = 4;

	SELECT prodtarjeta 
	INTO cProdTarjeta
	FROM bdicheq:"informix".sc_tarjeta 
	WHERE num_tarjeta = pNumeroTarjeta;
	
	IF TRIM(cProdTransfer) = TRIM(cProdTarjeta) THEN
			LET vCodRet = "858";
	ELSE
		IF vApePat IS NULL AND vNombre1 IS NULL THEN
			LET vCodRet = "255";
			LET vNumCuenta  = "";
			LET vNumCliente = "";
			LET vApePat		= "";
			LET vApeMat		= "";
			LET vNombre1	= "";
			LET vNombre2	= "";
			LET vRFC		= "";
		END IF
	
	END IF

	RETURN vCodRet, vNumCuenta, vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC;
	
END;
END PROCEDURE
DOCUMENT
"Folio:1636",
"Autor:951421354 Mario Gallardo",
"Fecha:29/08/2014",
"Modificación: Se modifica SP para retornar error 858 en caso de que el producto de la tarjeta sea 8000.",
"Sustento: Cambios_Plataforma_Observaciones.doc",
"Solicita:Berenice Mendez Riveraz ",
"BD: bdicheq";

CREATE PROCEDURE "informix".constarjeta(pEmpresa char(3), pTarjeta  char(20))
	-- DATOS A REGRESAR --
	RETURNING
	char(5),    -- Codigo de retorno
	char(20),   -- Numero Cuenta
	char(20),   -- # Cliente
	char(26),   -- Apellido paterno
	char(26),   -- Apellido materno
	char(26),   -- Nombre 1
	char(26),   -- Nombre 2
	char(13),   -- RFC
	money(14,2), -- Limite de retiro maximo por mes
	char(1),    -- Status tarjeta
	char(8);    -- Tipo de cliente

	-- VARIABLES --
	DEFINE vCodRet  char(5);
	DEFINE vTipCte  char(1);
	DEFINE vNumCta  char(20);
	DEFINE vNumCte	char(20);
	DEFINE vApePat  char(26);
	DEFINE vApeMat  char(26);
	DEFINE vNombre1 char(26);
	DEFINE vNombre2 char(26);
	DEFINE vRFC     char(13);
	DEFINE vNumTarj char(16);
	DEFINE vLimTar  money(14,2);
	DEFINE vTipoCte char(8);
	DEFINE vStatTjt char(1);
	DEFINE vCantReg smallint;
	DEFINE vRFC_alterno char(13);
	DEFINE cProductoTarjeta CHAR(4);
	DEFINE iSqlErr INTEGER;


	-- INICIALIZACION DE VARIABLES --
	LET vCodRet  = "000";
	LET vCantReg = 0;
	LET vRFC_alterno = "";
	LET cProductoTarjeta = "";
	LET iSqlErr = 0;
	LET vNumCte  = "";
	LET vNumCta  = "";
	LET vApePat  = "";
	LET vApeMat  = "";
	LET vNombre1 = "";
	LET vNombre2 = "";
	LET vRFC     = "";
	LET vNumTarj = "";
	LET vLimTar  = 0;
	LET vStatTjt = "";
	LET vTipoCte = "";

	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
			    LET vCodRet = iSqlErr; 
				
				RETURN vCodRet, vNumcta, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC,  vLimTar, vStatTjt, vTipoCte WITH RESUME;	
			END IF;
		END EXCEPTION;
		
	--SET DEBUG FILE TO '/home/tmp/jairo/constarjeta.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- BUSCAR QUE TIPO DE CLIENTE ES [ TITULAR O FIRMANTE] --
	LET	vTipCte = "";

	SELECT
		'T' AS tipo_tarjeta, sc_mcq.numcte
	INTO
		vTipCte, vNumCte
	FROM
		bdicheq:"informix".sc_tarjeta AS sc_mcq
	WHERE
		sc_mcq.empresa = pEmpresa AND
		sc_mcq.num_tarjeta  = pTarjeta;
		
		
			SELECT prodtarjeta
			INTO cProductoTarjeta
			FROM bdicheq:"informix".sc_tarjeta
            WHERE  empresa = pEmpresa
            AND num_tarjeta = pTarjeta;
			
			IF NVL(cProductoTarjeta, "") = "8000" THEN
				LET vCodRet= '00858';
				RETURN NVL(vCodRet,""), NVL(vNumcta,""), NVL(vNumCte,""), NVL(vApePat,""), NVL(vApeMat,""), NVL(vNombre1,""), NVL(vNombre2,""), NVL(vRFC,""),  NVL(vLimTar,""), NVL(vStatTjt,""), NVL(vTipoCte,"");
			END IF;

		
	IF vTipCte = 'T' THEN
		-- CICLO PARA OBTENER AL TITULAR Y LOS FIRMANTES Y LAS TARJETAS DE CREDITO EN CASO DE QUE TENGAN --
		FOREACH
			SELECT DISTINCT
				sc_mcq.cuenta, si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, si_cte.rfc_alterno,'Titular' AS tipo_cliente
			FROM
				bdicheq:"informix".sc_tarjeta AS sc_mcq,
				bdinteg:"informix".si_cliente AS si_cte
			WHERE
				sc_mcq.empresa = pEmpresa AND sc_mcq.num_tarjeta =  pTarjeta AND
				sc_mcq.numcte = si_cte.numcte AND  si_cte.empresa = pEmpresa

			UNION ALL

			SELECT DISTINCT
				sc_fir.cuenta, si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, si_cte.rfc_alterno,'Firmante' AS tipo_cliente
			INTO
				vNumCta, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vRFC_alterno, vTipoCte
			FROM
				bdicheq:"informix".sc_tarjeta AS sc_fir,
				bdinteg:"informix".si_cliente AS si_cte
			WHERE
				sc_fir.empresa =  pEmpresa AND sc_fir.num_tarjeta =  pTarjeta AND sc_fir.numcte != vNumCte AND
				sc_fir.numcte = si_cte.numcte AND si_cte.empresa = pEmpresa

			IF vRFC_alterno IS NOT NULL AND vRFC_alterno <> "" THEN
               LET vRFC = vRFC_alterno;
            END IF;		
			
			-- OBTENER LA TARJETA DEL TITULAR O FIRMANTE --
			SELECT
				sc_tjt.num_tarjeta, sc_tjt.limite_aut, sc_tjt.status_tar
			INTO
				vNumTarj, vLimTar, vStatTjt
			FROM
				bdicheq:"informix".sc_tarjeta AS sc_tjt
			WHERE
				sc_tjt.empresa = pEmpresa AND
				sc_tjt.num_tarjeta = pTarjeta AND
				sc_tjt.numcte = vNumCte AND
				sc_tjt.secuencia = (SELECT MAX(sc_tjt.secuencia) FROM bdicheq:"informix".sc_tarjeta AS sc_tjt WHERE sc_tjt.empresa = pEmpresa AND sc_tjt.num_tarjeta = pTarjeta AND sc_tjt.numcte = vNumCte);

			
			IF vNumTarj IS NULL THEN
				LET vNumTarj = "Sin tarjeta";
				LET vLimTar = 0;
				LET vStatTjt = "";
			END IF

			LET vCantReg = vCantReg + 1;
			
			RETURN vCodRet, vNumCta, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC,  vLimTar, vStatTjt, vTipoCte WITH RESUME;
		END FOREACH;
	ELSE
		-- OBTENER LAS TARJETAS DEL FIRMANTE
		SELECT DISTINCT
			sc_fir.cuenta, si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, si_cte.rfc_alterno, 'Firmante' AS tipo_cliente
		INTO
			vNumCta, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vRFC_alterno, vTipoCte
		FROM
			bdicheq:"informix".sc_tarjeta AS sc_fir,
			bdinteg:"informix".si_cliente AS si_cte
		WHERE
			sc_fir.empresa =  pEmpresa AND sc_fir.num_tarjeta =  pTarjeta AND 
			sc_fir.numcte = si_cte.numcte AND si_cte.empresa = pEmpresa;

		
		-- OBTENER LA TARJETA DEL FIRMANTE --
		SELECT DISTINCT
			sc_tjt.num_tarjeta, sc_tjt.limite_aut, sc_tjt.status_tar
		INTO
			vNumTarj, vLimTar, vStatTjt
		FROM
			bdicheq:"informix".sc_tarjeta AS sc_tjt
		WHERE
			sc_tjt.empresa = pEmpresa AND
			sc_tjt.num_tarjeta = pTarjeta AND
			sc_tjt.numcte = vNumCte AND
			sc_tjt.secuencia = (SELECT MAX(sc_tjt.secuencia) FROM bdicheq:"informix".sc_tarjeta AS sc_tjt WHERE sc_tjt.empresa = pEmpresa AND sc_tjt.num_tarjeta = pTarjeta AND sc_tjt.numcte = vNumCte);

		IF vRFC_alterno IS NOT NULL AND vRFC_alterno <> "" THEN
           LET vRFC = vRFC_alterno;
        END IF;			
			
		IF vNumTarj IS NULL THEN
			LET vNumTarj = "Sin tarjeta";
			LET vLimTar = 0;
			LET vStatTjt = "";
		END IF

		LET vCantReg = vCantReg + 1;
			
		RETURN vCodRet, vNumcta, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC,  vLimTar, vStatTjt, vTipoCte WITH RESUME;
	END IF

	IF vCantReg = 0 THEN
		LET vCodRet  = "101";
		LET vNumCte  = "";
		LET vApePat  = "";
		LET vApeMat  = "";
		LET vNombre1 = "";
		LET vNombre2 = "";
		LET vRFC     = "";
		LET vNumTarj = "";
		LET vLimTar  = 0;
		LET vStatTjt = "";
		LET vTipoCte = "";

		RETURN vCodRet, vNumCta, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vLimTar, vStatTjt, vTipoCte;
	END IF
END
END PROCEDURE                                                     
DOCUMENT
'AUTOR: ???',
'DESCRIPCION: Se añade validacion para el producto 8000 transfer y mande retorno 858',
'FECHA: 28/08/2014',
'MODIFICO: Jairo Valdez Gonzalez',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_conciliachqtf( pempresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
    
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE vcont1       INTEGER;
    DEFINE vcont2       INTEGER;
    DEFINE ven_trx      SMALLINT;
    DEFINE vsql         CHAR(600);
    DEFINE vstmt        CHAR(250);
    DEFINE vfecha_hoy   DATE;
    DEFINE vfecha_ant   DATE;
    DEFINE vproceso     CHAR(14);
    DEFINE vsistema     CHAR(2);
    DEFINE vexiste      INTEGER;
    DEFINE vexisfin     INTEGER;
    DEFINE vusuario     CHAR(10);
    DEFINE vcuenta      CHAR(20);
    DEFINE vnum_cte     CHAR(20);
    DEFINE vsucursal    CHAR(4);
    DEFINE vejecutivo   CHAR(8);
    DEFINE vproducto    CHAR(4);
    DEFINE vcap_ant     MONEY(18,2);
    DEFINE vcap_cal     MONEY(18,2);
    DEFINE vmovs_cgo    MONEY(18,2);
    DEFINE vmovs_abo    MONEY(18,2);
    DEFINE vcap_act     MONEY(18,2);
    DEFINE vdif_cap     MONEY(18,2);
    DEFINE vcta_cgo     CHAR(12);  
    DEFINE vcta_abo     CHAR(12);  
    DEFINE vmonto       MONEY(14,2);
    DEFINE vcta         SMALLINT;
    DEFINE vinteres     MONEY(14,2);
    DEFINE vfecha       CHAR(8);
    
    LET vcodret1   = '000';
    LET vcodret2   = '000';
    LET vcodret3   = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err	   = 0;
    LET isam_err   = 0;
    LET desc_err   = '';
    LET vcont1     = 0;
    LET vcont2     = 0;
    LET ven_trx    = 0; 
    LET vsql       = '';
    LET vstmt      = '';
    LET vfecha_hoy = ''; 
    LET vfecha_ant = '';
    LET vproceso   = 'conciliachqtf';
    LET vsistema   = '01';
    LET vexiste    = 0;
    LET vexisfin   = 0;
    LET vusuario   = user;
    LET vcuenta    = ''; 
    LET vproducto  = '';
    LET vnum_cte   = '';
    LET vsucursal  = '5001';
    LET vejecutivo = '';
    LET vcap_ant   = 0.00;
    LET vcap_cal   = 0.00;
    LET vmovs_cgo  = 0.00;
    LET vmovs_abo  = 0.00;
    LET vcap_act   = 0.00;
    LET vdif_cap   = 0.00;
    LET vcta_cgo   = '';
    LET vcta_abo   = '';
    LET vmonto     = 0.00;
    LET vcta       = 0;
    LET vinteres   = 0.00;
    LET vfecha     = '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_conciliachqtf.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_trx = 1 THEN
                ROLLBACK WORK;
            END IF;
            LET vsql = '';
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'C'||''','||
                       'codret        = '''||vcodret1||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horasconcilchqtf.sql';
            SYSTEM vsql;
            LET vstmt = '';
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchqtf.sql';
            SYSTEM vstmt;
            RETURN vcodret1, vcodret2, vcodret3, vcont1, vcont2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_conciliachqtf.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE LAS FECHAS DEL SISTEMA
    SELECT fecha_hoy, fecha_ant
      INTO vfecha_hoy, vfecha_ant
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    -- // VALIDA LA FECHA DE AYER
    LET vfecha_hoy = vfecha_hoy - 1 UNITS DAY;
    
    CALL sp_valfechabil(vfecha_hoy, '-') 
    RETURNING vcodret1, vfecha_hoy;
    
    -- // VALIDA LA FECHA DE ANTIER
    LET vfecha_ant = vfecha_ant - 1 UNITS DAY;
    
    CALL sp_valfechabil(vfecha_ant, '-') 
    RETURNING vcodret1, vfecha_ant;
     
    -- // GUARDA REGISTRO DE CONTROL EN TABLA DE INTEGRAL
    select count(*)
      into vexiste
      from bdinteg:sx_contproc
     where empresa = pempresa
       and proceso = vproceso
       and fecha   = vfecha_hoy
       and sistema = vsistema;
    
    if vexiste = 0 then
        LET vsql = '';
        LET vsql = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||vproceso||''', '''||vfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||vusuario||''','||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horasconcilchqtf.sql';
        SYSTEM vsql;
        
        LET vstmt = '';
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchqtf.sql';
        SYSTEM vstmt;
    else
        SELECT count(*)
          INTO vexisfin
          FROM bdinteg:sx_contproc
         WHERE empresa     = pempresa
           AND proceso     = vproceso
           AND fecha       = vfecha_hoy
           AND sistema     = vsistema
           AND status_proc = "F";
           
        IF vexisfin = 0 THEN
            LET vsql = '';
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'I'||''','||
                       'codret        = '''||' '||''','||
                       'hora_fin      = '''||' '||''','||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horasconcilchqtf.sql';
            SYSTEM vsql;
            
            LET vstmt = '';
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchqtf.sql';
            SYSTEM vstmt;
        ELSE
            LET vcodret1 = "958";
            LET vcodret2 = "958";
            
            SELECT descripcion
              INTO vcodret3
              FROM bdinteg:si_codret
             WHERE sistema = vsistema
               AND codigo_retorno = vcodret1;
            
            RETURN vcodret1, vcodret2, vcodret3, vcont1, vcont2;
        END IF;
    end if;
    
    -- // ELIMINACION DE TABLAS
    if exists( select dbsname, tabname from sysmaster:systabnames where partnum > 0 and tabname = 'conciliachqtf') then 
        drop table bdicheq:"informix".conciliachqtf;
    end if;
    
    if exists( select dbsname, tabname from sysmaster:systabnames where partnum > 0 and tabname = 'conciliachqtf_dif') then
        drop table bdicheq:"informix".conciliachqtf_dif;
    end if
    
    -- // CREACION DE TABLAS
    create table bdicheq:"informix".conciliachqtf
      (
        fecha                   date,
        cuenta                  char(20),
        producto                char(4),
        num_cte                 char(20),
        sucursal                char(4),
        ejecutivo               char(8),
        capital_anterior        money(18,2),
        movs_cargo              money(18,2),
        movs_abono              money(18,2),
        capital_calculado       money(18,2),
        capital_actual          money(18,2),
        diferencia_capital      money(18,2)
      )    
    extent size 1024 next size 128 lock mode row;
        
    create table bdicheq:"informix".conciliachqtf_dif
      ( 
        fecha                   date,   
        cuenta                  char(20),
        producto                char(4),    
        num_cte                 char(20),   
        sucursal                char(4),    
        ejecutivo               char(8),    
        capital_anterior        money(18,2),
        movs_cargo              money(18,2),
        movs_abono              money(18,2),
        capital_calculado       money(18,2),
        capital_actual          money(18,2),
        diferencia_capital      money(18,2)
      )
    extent size 1024 next size 128 lock mode row;
    
    -- // CREACION DE INDICES
    create index "informix".idx_conciliachqtf_fecha on bdicheq:"informix".conciliachqtf(fecha) in datos03 online;
    create index "informix".idx_conciliachqtf_cuenta on bdicheq:"informix".conciliachqtf(cuenta) in datos03 online;
    create index "informix".idx_conciliachqtfdif_fecha on bdicheq:"informix".conciliachqtf_dif(fecha) in datos03 online;
    create index "informix".idx_conciliachqtfdif_cuenta on bdicheq:"informix".conciliachqtf_dif(cuenta) in datos03 online;
    
    -- // ACTUALIZA ESTADISTICAS
    update statistics medium for table conciliachqtf;
    update statistics medium for table conciliachqtf_dif;
    
    -- // CREACION DE TABLA TEMPORAL DE MOVIMIENTOS
    SELECT { +INDEX(sc_movdia_concil idx_movdiaconc_1), +INDEX(bdinteg:si_transacc idx_si_transacc4), +INDEX(bdinteg:si_prodtran idx01_prodtran) } 
           mov.cuenta, mov.transacc, mov.monto_tot,
           TRIM(prod.c_ccmayor)||TRIM(prod.c_ccsub)||TRIM(prod.c_ccsubsub)||TRIM(prod.c_ccsssub)||TRIM(prod.c_ccssssub) AS cta_cargo,
           TRIM(prod.a_ccmayor)||TRIM(prod.a_ccsub)||TRIM(prod.a_ccsubsub)||TRIM(prod.a_ccsssub)||TRIM(prod.a_ccssssub) AS cta_abono
      FROM sc_movdia_concil mov,
           bdinteg:si_transacc tran,
           bdinteg:si_prodtran prod
     WHERE mov.fech_alt = vfecha_hoy
       AND mov.cancelad != 'S'
       AND mov.cuenta LIKE '8%'
       AND mov.producto = '8000'
       AND tran.empresa = mov.empresa
       AND tran.numero = mov.transacc
       AND tran.se_contabiliza = 'S'
       AND tran.sistema = '01'
       AND prod.transaccion = tran.numero
       AND prod.producto = mov.producto
       AND prod.sistema = tran.sistema
      INTO TEMP tmp_movs_transfer WITH NO LOG;
      
    -- // CREACION DE INDICES
    CREATE INDEX idxtmp_movstrf_cta ON tmp_movs_transfer(cuenta) ONLINE;
    CREATE INDEX idxtmp_movstrf_ctacgo ON tmp_movs_transfer(cuenta, cta_cargo) ONLINE;
    CREATE INDEX idxtmp_movstrf_ctaabo ON tmp_movs_transfer(cuenta, cta_abono) ONLINE;
    
    -- // ACTUALIZA ESTADISTICAS
    UPDATE STATISTICS HIGH FOR TABLE tmp_movs_transfer(cuenta, cta_cargo, cta_abono);
    
    -- // FOREACH CUENTAS TRANSFER
    FOREACH WITH HOLD
        SELECT cuenta_tf, producto, numcte, ejecutivo
          INTO vcuenta, vproducto, vnum_cte, vejecutivo
          FROM bditransfer:tf_maecte 
         WHERE ( telefono is not null OR telefono <> '' )
           AND empresa = '001'
           AND ( status_cta = '1' OR fec_cancelac >= vfecha_hoy )
           
        BEGIN WORK;
        LET ven_trx = 1; 
        
        -- // OBTIENE SALDOS ANTERIORES
        EXECUTE PROCEDURE sp_capintafecha(vcuenta, vfecha_ant) 
        INTO vcodret1, vcap_ant, vinteres;
        
        IF vcodret1 = '100' THEN
            LET vcodret1 = '000';
            LET vcap_ant = 0.00;
        END IF;
        
        LET vcap_cal = vcap_ant;
        
        -- // OBTIENE LOS MOVIMIENTOS DE CAPITAL 
        FOREACH
            SELECT {+INDEX(tmp_movs_transfer idxtmp_movstrf_cta)} 
                   cta_cargo, cta_abono, monto_tot
              INTO vcta_cgo, vcta_abo, vmonto
              FROM tmp_movs_transfer
             WHERE cuenta = vcuenta
             
            IF vcta_cgo IN( SELECT cta_contable FROM sc_ctascontchq WHERE producto = vproducto AND tipo = 'CAPITAL' ) THEN
                LET vcap_cal = vcap_cal - vmonto;
                LET vmovs_cgo = vmovs_cgo + vmonto;
            END IF;
                    
            IF vcta_abo IN( SELECT cta_contable FROM sc_ctascontchq WHERE producto = vproducto AND tipo = 'CAPITAL' ) THEN
                LET vcap_cal = vcap_cal + vmonto;
                LET vmovs_abo = vmovs_abo + vmonto;
            END IF;
            
            LET vcta_cgo   = '';
            LET vcta_abo   = '';
            LET vmonto     = 0.00;
        END FOREACH;
        
        -- // OBTIENE SALDOS ACTUALES
        EXECUTE PROCEDURE sp_capintafecha(vcuenta, vfecha_hoy) 
        INTO vcodret1, vcap_act, vinteres;
        
        IF vcodret1 = '100' THEN
            LET vcodret1 = '000';
            LET vcap_act = 0.00;
        END IF;
        
        -- // OBTIENE DIFERENCIAS
        LET vdif_cap = vcap_act - vcap_cal;
        
        -- // INSERTA EN TABLA DE TODAS LAS CUENTAS
        SELECT COUNT(*)
          INTO vcta
          FROM conciliachqtf
         WHERE cuenta = vcuenta;
         
        IF vcta > 0 THEN
            UPDATE conciliachqtf
               SET fecha              = vfecha_hoy,
                   capital_anterior   = vcap_ant,
                   movs_cargo         = vmovs_cgo,
                   movs_abono         = vmovs_abo,
                   capital_calculado  = vcap_cal,
                   capital_actual     = vcap_act,
                   diferencia_capital = vdif_cap
             WHERE cuenta = vcuenta;
        ELSE
            INSERT INTO conciliachqtf VALUES
            (vfecha_hoy, vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo,
             vcap_ant, vmovs_cgo, vmovs_abo, vcap_cal, vcap_act, vdif_cap);
        END IF;
        
        -- // INSERTA EN TABLA DE DIFERENCIAS
        IF ( vdif_cap <> 0.00 ) THEN
            INSERT INTO conciliachqtf_dif VALUES
            (vfecha_hoy, vcuenta, vproducto, vnum_cte, vsucursal, vejecutivo,
             vcap_ant, vmovs_cgo, vmovs_abo, vcap_cal, vcap_act, vdif_cap); 
             
            LET vcont2 = vcont2 + 1;
        END IF;
        
        LET vcont1 = vcont1 + 1;
        
        COMMIT WORK;
        LET ven_trx = 0;
        
        LET vcuenta    = ''; 
        LET vproducto  = '';
        LET vnum_cte   = '';
        LET vejecutivo = '';
        LET vcap_ant   = 0.00;
        LET vcap_cal   = 0.00;
        LET vmovs_cgo  = 0.00;
        LET vmovs_abo  = 0.00;
        LET vcap_act   = 0.00;
        LET vdif_cap   = 0.00;
        LET vcta       = 0;
        LET vinteres   = 0.00;
    END FOREACH;
    
    IF ven_trx = 1 THEN
        LET ven_trx = 0;
        COMMIT WORK;
    END IF;
    
    -- // ACTUALIZA ESTADISTICAS
    UPDATE STATISTICS MEDIUM FOR TABLE conciliachqtf;
    UPDATE STATISTICS MEDIUM FOR TABLE conciliachqtf_dif;
    
    LET vfecha = TO_CHAR(vfecha_hoy, '%d%m%Y');
    
    -- // GENERA EL ARCHIVO DE TODAS LAS CUENTAS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/conciliachqtf_'||vfecha||'.txt '||
               ' SELECT * FROM conciliachqtf WHERE fecha = '''||vfecha_hoy||''' ORDER BY cuenta" > /resplogifx/conciliachq/conciliatf.sql';
    SYSTEM vsql;
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/conciliatf.sql"; 
    SYSTEM vstmt;
    
    -- // GENERA EL ARCHIVO DE DIFERENCIAS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/conciliachqtfdif_'||vfecha||'.txt '||
               ' SELECT * FROM conciliachqtf_dif WHERE fecha = '''||vfecha_hoy||''' ORDER BY cuenta" > /resplogifx/conciliachq/conciliatf.sql';
    SYSTEM vsql;
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/conciliatf.sql"; 
    SYSTEM vstmt;
    
    -- // GENERA ARCHIVO DE GLOBALES POSITIVOS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/conciliachqtfglob_'||vfecha||'.txt '||
               'SELECT producto, COUNT(*), SUM(capital_anterior), SUM(capital_calculado), SUM(capital_actual) '||
               'FROM conciliachqtf WHERE fecha = '''||vfecha_hoy||''' AND capital_actual >= 0 GROUP BY producto " > /resplogifx/conciliachq/conciliatf.sql';
    SYSTEM vsql;
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/conciliatf.sql"; 
    SYSTEM vstmt;
    
    -- // GENERA ARCHIVO DE GLOBALES NEGATIVOS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/conciliachqtfglobneg_'||vfecha||'.txt '||
               'SELECT producto, COUNT(*), SUM(capital_anterior), SUM(capital_calculado), SUM(capital_actual) '||
               'FROM conciliachqtf WHERE fecha = '''||vfecha_hoy||''' AND capital_actual < 0 GROUP BY producto " > /resplogifx/conciliachq/conciliatf.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/conciliatf.sql"; 
    SYSTEM vsql;
    
    -- // GUARDA HORA FINAL DEL PROCESO
    LET vsql = '';
	LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET ejecutivo = '''||vusuario||''','||
               'status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret1||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horasconcilchqtf.sql';
    SYSTEM vsql;
    
    LET vstmt = '';
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horasconcilchqtf.sql';
    SYSTEM vstmt;
           
    END;
    
    RETURN vcodret1, vcodret2, vcodret3, vcont1, vcont2;
    
END PROCEDURE;