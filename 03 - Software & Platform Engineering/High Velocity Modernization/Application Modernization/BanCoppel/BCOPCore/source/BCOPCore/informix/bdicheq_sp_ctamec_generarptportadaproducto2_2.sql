CREATE PROCEDURE "informix".sp_ctamec_generarptportadaproducto2_2(pEmpresa CHAR(3), pNumCte CHAR(20), pNumCta CHAR(20))

	-- DATOS A REGRESAR --
	RETURNING
	CHAR(5) AS COD_RET,    		-- Codigo de retorno
	CHAR(4) AS COD_PRODUCTO,   	--CODIGO DEL PRODUCTO
	CHAR(40) AS NOM_PRODUCTO, 	--NOMBRE DEL PRODUCTO
	CHAR(314) AS RAZON_SOC, 		--RAZON SOCIAL
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
	DEFINE cRazon CHAR(254);
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
	DEFINE cRFCAlt CHAR(13);
	DEFINE cRazonaux CHAR(254);

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
	LET cRFCAlt = "";
	LET cRazonaux = "";		

	--SET DEBUG FILE TO '/tmp/mfinis/Antonio/sp_ctamec_generarptportadaproducto2_2.out';
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
		
		--OBTENEMOS LA RAZON SOCIAL, Y EL RFC
		SELECT TRIM(s.nombre1)|| ' '||TRIM(s.nombre2)||' '|| 
		TRIM(s.apell_paterno)||' '||TRIM(s.apell_materno)||' '||TRIM(NVL(f.nom_razon_soc,'')) AS nombre, s.rfc,s.rfc_alterno
		INTO cRazon, cRfc, cRFCAlt
		FROM bdinteg:"informix".si_cliente s
		LEFT JOIN bdinteg:"informix".si_fiscal f ON s.numcte = f.numcte
		WHERE s.empresa = pEmpresa
		AND	s.numcte = cNumCte;
		
		IF NVL(cRFCAlt,'')<>'' THEN
		 LET cRfc = cRFCAlt;
		END IF;
		
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
		SELECT TRIM(s.nombre1)|| ' '||TRIM(s.nombre2)||' '|| 
		TRIM(s.apell_paterno)||' '||TRIM(s.apell_materno)||' '||TRIM(NVL(f.nom_razon_soc,'')) AS nombre, s.rfc,s.rfc_alterno
		INTO cRazon, cRfc, cRFCAlt
		FROM bdinteg:"informix".si_cliente s
		LEFT JOIN bdinteg:"informix".si_fiscal f ON s.numcte = f.numcte
		WHERE s.empresa = pEmpresa
		AND	s.numcte = cNumCte;
		
		IF NVL(cRFCAlt,'')<>'' THEN
		 LET cRfc = cRFCAlt;
		END IF;
		
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
	
		IF EXISTS(SELECT noproducto FROM bdicnweb:"informix".productos WHERE  activa = 1 AND noproducto = cCodProd) THEN	
		
		ELSE
	
			--OBTENEMOS LA DESCRIPCION DEL REGIMEN DE FIRMAS Y LA COMBINACION
			SELECT descripcion, combinacion
			INTO cRegimen, cCombinacion
			FROM bdicntchq:"informix".sq_catregimen
			WHERE cve_regimen = cClaveReg;
			
			IF cRegimen IS NULL THEN --NO EXISTE EL TIPO DE REGIMEN
				LET cCodRet = '270';
				RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
			END IF;
		END IF;
		
		--OBTENEMOS EL VALOR RECA
		SELECT valor
		INTO cReca
		FROM "informix".sc_param
		WHERE empresa = "001"
		AND codparam = "REKA" || cCodProd;
		
		IF NOT EXISTS(SELECT noproducto FROM bdicnweb:"informix".productos WHERE  activa = 1 AND noproducto = cCodProd) THEN	
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
				
				LET iParam = 1;

			RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca) WITH RESUME;
			
			END FOREACH;
		ELSE
			LET cFirmNom ="";
			LET iParam = 1;
			RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
		END IF;
	
	END IF;
	
	IF iParam = 0 THEN --NO HAY DATOS DE FIRMANTES CON ESOS CRITERIOS
		LET cCodRet = '300';
		RETURN TRIM(cCodRet),TRIM(cCodProd),TRIM (cNomProd),TRIM(cRazon),TRIM(cNumCte),TRIM(cNumCta),TRIM(cClabe),TRIM(cClaveReg),TRIM(cRegimen),TRIM(cCombinacion),TRIM(cRfc),dFecha,TRIM(cFirmNom),TRIM(cTipoFirma), cSuc, TRIM(cNomSuc), TRIM(cReca);
	END IF
	
END
END PROCEDURE
DOCUMENT
'Procedimiento   : GenerarRptPortadaCtaEjeEmpresarialChequesSPL',
'VersiÃ¯Â¿Â½n         : 1.0',
'Creado por      : Victor Hugo NuÃ¯Â¿Â½ez Velazquez',
'Fecha creacion  : 13 Junio 2011',
'Descripcion     : Obtiene todos los firmantes de una cuenta en particular y obtiene todos los firmantes por cuentas por el numero del cliente',
'Procedimiento   : GenerarRptPortadaCtaEjeEmpresarialChequesSPL',
'Modificado por  : Armando Morales Barraza',
'Fecha creacion  : 14 Marzo 2012',
'Descripcion     : Obtiene el numero y nombre de sucursal de la cuenta',
'MODIFICO: Jose Luis Polanco B.',
'FECHA: DSB 16/05/2013',
'DESCRIPCION: Se agrega el "sufijo" a la variable de retorno "cRazon" para que aparesca en los reportes',
'AUTOR MODIFICACION: Uriel CaamaÃ¯Â¿Â½o Mejia',
'BD: bdicheq',
'FECHA: 01/12/2017',
'DESCRIPCION: Se clona el SPL y se agregan nuevas reglas de negocio para el comportamiento de los productos',
'AUTOR MODIFICACION: JosÃÂ© Antonio RamÃÂ­rez Franco',
'BD: bdicheq',
'FECHA: 11/12/2023',
'DESCRIPCION: Se clona el SPL y se agrega la nueva estructura si_fiscal para la recuperaciÃÂ³n de la nueva razÃÂ³n social';

CREATE PROCEDURE "informix".sp_portanom_cargaarchivo(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaRegistro DATE, pRutaArchivo CHAR(50), pArchivo CHAR(50), pCodigoOperacion CHAR(2), pTotalSolicitudes INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(35) AS archivo_respuestas,
				CHAR(50) AS ruta_deposito_archivo_central;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE cArchivoRespuestas CHAR(35);
	DEFINE cRutaCentralRespuesta CHAR(50);
	DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cArchivoRespuestas = '';
	LET cRutaCentralRespuesta = '';
	LET bInTransaction = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;
			RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
		
        --SET DEBUG FILE TO '/tmp/sp_portanom_car.out';
		--SET DEBUG FILE TO '/resplogifx/conciliachq/sp_portanom_cargaarchivo_rr.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pArchivo = '' OR pCodigoOperacion = '' OR pTotalSolicitudes IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
		END IF;
		
		IF pCodigoOperacion NOT IN ('20', '21') THEN
			LET cCodRet = '00102';
			RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
		END IF;
		
		IF pCodigoOperacion = '20' AND pFechaRegistro IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
		ELIF pCodigoOperacion = '21' AND pFechaRegistro IS NULL THEN
			LET pFechaRegistro = CURRENT;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
		END IF;
		
		BEGIN WORK;
		IF bInTransaction = 'f' THEN
			COMMIT WORK;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:'informix'.sp_cargarchivoportab(pFechaRegistro, TRIM(pArchivo), pCodigoOperacion, pTotalSolicitudes)
		INTO cCodRetSp, cArchivoRespuestas, cRutaCentralRespuesta;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:'informix'.sp_cargarchivoportab";
		ELIF iCodRetSp = 191 THEN
			LET cCodRet = '00553';
		ELIF iCodRetSp = 175 THEN -- EXISTE UN TIPO DE REGISTRO QUE NO ES AUTORIZADO
			LET cCodRet = '00687';
		ELIF iCodRetSp = 176 THEN
			LET cCodRet = '00086';
		ELIF iCodRetSp = 177 THEN
			LET cCodRet = '00656';
		ELIF iCodRetSp = 178 THEN
			LET cCodRet = '00657';
		ELIF iCodRetSp = 179 THEN
			LET cCodRet = '00658';
		ELIF iCodRetSp = 180 THEN
			LET cCodRet = '00659';
		ELIF iCodRetSp = 181 THEN -- LA SECUENCIA EN EL DETALLE NO ES CORRECTA
			LET cCodRet = '00688';
		ELIF iCodRetSp = 182 THEN
			LET cCodRet = '00483';
		ELIF iCodRetSp = 200 THEN
			LET cCodRet = '00009';
		ELIF iCodRetSp = 201 THEN
			LET cCodRet = '00104';
		ELIF iCodRetSp = 202 THEN
			LET cCodRet = '00104';
		ELIF iCodRetSp = 203 THEN
			LET cCodRet = '00690';
		ELIF iCodRetSp = 204 THEN
			LET cCodRet = '00691';
		ELIF iCodRetSp = 205 THEN
			LET cCodRet = '00692';
		ELIF iCodRetSp = 333 THEN
			LET cCodRet = '00492';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 08/09/2015',
'MODULO: Operaciones',
'FUNCIONALIDAD: Portabilidad de nomina - Solicitudes',
'DESCRIPCION: Realiza el vaciado de la informaciÃ³n a un archivo',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_valida_status_ppc(pnumcte CHAR(20), pfolioPres CHAR(20), pTarjeta CHAR(4))
       RETURNING CHAR(5) AS cCodRet;

DEFINE cCodRet			CHAR(5); 
DEFINE iSqlErr          INTEGER; 
DEFINE iMonto           MONEY;
DEFINE cCuenta			CHAR(20);
DEFINE cSuc				CHAR(4);
DEFINE cFoliosuc        CHAR(16);

LET cCodRet = "00000";
LET iSqlErr = 0;
LET iMonto = 0;
LET cCuenta = "";
LET cSuc = "";
LET cFoliosuc = "";

BEGIN

   ON EXCEPTION SET iSqlErr
        LET cCodRet=iSqlErr;
        RETURN cCodRet;
    
    END EXCEPTION;
	
	IF pnumcte ='' THEN
	  LET cCodRet='00001'; -- Parametro de entrada vacio
	END IF;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT 
		monto_autorizado
		, sucursal 
	INTO 
		iMonto
		, cSuc 
	FROM 
		bdisolic:ss_prestamoscoppel 
	WHERE 
		numcte = pnumcte 
		AND folio_prestamo = pfolioPres 
		AND status_solicitud='P';
	 
	IF iMonto > 0 or iMonto is not null THEN
			SELECT 
				cuenta 
			INTO  
				cCuenta 
			FROM 
				BDICHEQ:sc_tarjeta 
			WHERE 
				numcte = pnumcte 
				AND substr(num_tarjeta,13,4) = pTarjeta 
				AND status_tar = 'A';
	  
		IF cCuenta is not null or cCuenta <> '' THEN
				SELECT 
					FIRST 1 folio_suc 
				INTO 
					cFoliosuc
				FROM 
					bdicheq:sc_movdia 
				WHERE 
					sucursal = '5006' 
					AND cuenta = cCuenta 
					AND monto_tot = iMonto;
					--AND producto = '2000' 
					--AND substr(referencia,1,16) = 'TIENDA COPPEL PP';
	  	END IF
		
		IF NVL(cFoliosuc,'') = '' THEN
			LET cCodRet='00003'; -- NO se encontro el prestamo			  
            RETURN cCodRet;
			
		ELSE			    
 		    UPDATE 
				bdisolic:informix.ss_prestamoscoppel 
			SET 
				status_solicitud = 'A'
 		    WHERE 
				numcte = pnumcte 
				AND folio_prestamo = pfolioPres 
				AND sucursal= cSuc 
				AND monto_autorizado = iMonto;

			LET cCodRet='00000'; 

     END IF
	ELSE
	 LET cCodRet ='00002'; -- No existe el registro
	END IF;
	RETURN cCodRet;
END;
END PROCEDURE;