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
'Versiï¿½n         : 1.0',
'Creado por      : Victor Hugo Nuï¿½ez Velazquez',
'Fecha creacion  : 13 Junio 2011',
'Descripcion     : Obtiene todos los firmantes de una cuenta en particular y obtiene todos los firmantes por cuentas por el numero del cliente',
'Procedimiento   : GenerarRptPortadaCtaEjeEmpresarialChequesSPL',
'Modificado por  : Armando Morales Barraza',
'Fecha creacion  : 14 Marzo 2012',
'Descripcion     : Obtiene el numero y nombre de sucursal de la cuenta',
'MODIFICO: Jose Luis Polanco B.',
'FECHA: DSB 16/05/2013',
'DESCRIPCION: Se agrega el "sufijo" a la variable de retorno "cRazon" para que aparesca en los reportes',
'AUTOR MODIFICACION: Uriel Caamaï¿½o Mejia',
'BD: bdicheq',
'FECHA: 01/12/2017',
'DESCRIPCION: Se clona el SPL y se agregan nuevas reglas de negocio para el comportamiento de los productos',
'AUTOR MODIFICACION: JosÃ© Antonio RamÃ­rez Franco',
'BD: bdicheq',
'FECHA: 11/12/2023',
'DESCRIPCION: Se clona el SPL y se agrega la nueva estructura si_fiscal para la recuperaciÃ³n de la nueva razÃ³n social';

CREATE PROCEDURE "informix".sp_obtclavetarjeta(Tipot CHAR(1), pBin CHAR(6),pSubBin CHAR(2), pCodProdCta CHAR(4), pOperacion CHAR(35), pMigracionVisaActiva CHAR(1))
   RETURNING CHAR(5), CHAR(6), CHAR(3), CHAR(3);
      
   DEFINE cCodRet             CHAR(5);
   DEFINE iSqlErr             INTEGER;
   DEFINE cCodBin             CHAR(6);
   DEFINE cCodProdTar            CHAR(3);
   DEFINE cClave            CHAR(3);


   DEFINE cCodProdPlat          CHAR(4);   
   DEFINE cCodProdORO           CHAR(4);
   DEFINE cSubBinOroN           CHAR(2);
   DEFINE cSubBinPlat          CHAR(2);
   DEFINE cSubBinOroI           CHAR(2);
   DEFINE cClaTipoPlat          CHAR(2);  
   DEFINE cClaTipoOroN          CHAR(2);       
   DEFINE cClaTipoOroI          CHAR(2);   
   DEFINE cClaveOroN            CHAR(3);       
   DEFINE cClaveOroI            CHAR(3);  

   LET cCodRet        ='00000';   
   LET cCodBin        ='000000';
   LET cCodProdTar       ='000';
   LET cClave       ='000';


   LET cCodProdPlat   = '7000';
   LET cCodProdORO    = '8100';
   LET cSubBinOroN    = '05';
   LET cSubBinPlat    = '06';
   LET cSubBinOroI    = '08';
   LET cClaTipoPlat   = '74';
   LET cClaTipoOroN   = '73';
   LET cClaTipoOroI   = '75';
   LET cClaveOroN     = '100';  
   LET cClaveOroI     = '104';  
   
BEGIN
                ON EXCEPTION SET iSqlErr
                      IF iSqlErr <> 0 THEN
                         LET cCodRet = iSqlErr;
                                                               
                         RETURN cCodRet, cCodBin, cCodProdTar, cClave;
                      END IF;
                END EXCEPTION;

                --SET DEBUG FILE TO '/tmp/sp_obtclavetarjeta.out';
	            --TRACE ON;
                
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;
				
				IF pOperacion <> 'Solicitud de Tarjeta Personalizada' THEN

                    IF pMigracionVisaActiva = '1' THEN
                        ----------------------------------------------------------------------------------------------------------------
                        ----------------------------RQM MIGRACIÃN TDC ORO Y PLATINUM MASTERCARD A VISA
                        SELECT b.bin, b.codproductotarjeta, b.clave
                        INTO cCodBin, cCodProdTar, cClave
                        FROM intercard:binproducto a
                        INNER JOIN intercard:Tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
                        WHERE a.bin = pBin 
                        AND a.producto= pSubBin  
                        AND a.codprodcta = pCodProdCta
                        AND b.consecutivo = (
                            CASE 
                                WHEN pCodProdCta = cCodProdPlat AND pSubBin = cSubBinPlat THEN (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin AND  clave_tipotarjeta = cClaTipoPlat)
                                WHEN pCodProdCta = cCodProdORO  AND pSubBin = cSubBinOroI THEN (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin AND  clave_tipotarjeta = cClaTipoOroI) 
                                WHEN pCodProdCta = cCodProdORO  AND pSubBin = cSubBinOroN THEN (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin AND  clave_tipotarjeta = cClaTipoOroN)
                                ELSE                                     (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin)
                            END
                            )           
                        AND b.clave =(
                            CASE  
                                WHEN pCodProdCta = cCodProdORO AND pSubBin = cSubBinOroI THEN cClaveOroI
                                WHEN pCodProdCta = cCodProdORO AND pSubBin = cSubBinOroN THEN cClaveOroN
                                ELSE b.clave 
                            END
                        );
                        ----------------------------------------------------------------------------------------------------------------
                    ELSE
                        -- RQM MIGRACION VISA APAGADA
                        SELECT b.bin, b.codproductotarjeta, clave  
                        INTO cCodBin, cCodProdTar, cClave
                        FROM intercard:binproducto a
                        INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
                        WHERE a.bin = pBin 
                        AND a.producto= pSubBin 
                        AND a.codprodcta = pCodProdCta
                        AND consecutivo = (SELECT max(consecutivo) FROM intercard:tipotarjeta WHERE bin = pBin);

                    END IF;

                ELSE
					IF pCodProdCta NOT IN (cCodProdPlat,cCodProdORO) THEN
						SELECT b.bin, b.codproductotarjeta, clave  
						INTO cCodBin, cCodProdTar, cClave
						FROM intercard:binproducto a
						INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
						WHERE a.bin = pBin 
						AND a.producto= pSubBin 
						AND a.codprodcta = pCodProdCta
						AND consecutivo = (SELECT max(consecutivo) FROM intercard:tipotarjeta WHERE bin = pBin AND descripcion LIKE 'PERSONALIZADO PREDISE%') ;
					ELSE

                        IF pMigracionVisaActiva = '1' THEN
                            ----------------------------RQM MIGRACIÃN TDC ORO Y PLATINUM MASTERCARD A VISA
                            SELECT b.bin, b.codproductotarjeta, b.clave
                            INTO cCodBin, cCodProdTar, cClave
                            FROM intercard:binproducto a
                            INNER JOIN intercard:Tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
                            WHERE a.bin = pBin 
                            AND a.producto= pSubBin  
                            AND a.codprodcta = pCodProdCta
                            AND b.consecutivo = (
                                CASE 
                                    WHEN pCodProdCta = cCodProdPlat AND pSubBin = cSubBinPlat THEN (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin AND  clave_tipotarjeta = cClaTipoPlat)
                                    WHEN pCodProdCta = cCodProdORO  AND pSubBin = cSubBinOroI THEN (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin AND  clave_tipotarjeta = cClaTipoOroI) 
                                    WHEN pCodProdCta = cCodProdORO  AND pSubBin = cSubBinOroN THEN (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin AND  clave_tipotarjeta = cClaTipoOroN)
                                    ELSE                                     (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin)
                                END
                                )           
                            AND b.clave =(
                                CASE  
                                    WHEN pCodProdCta = cCodProdORO AND pSubBin = cSubBinOroI THEN cClaveOroI
                                    WHEN pCodProdCta = cCodProdORO AND pSubBin = cSubBinOroN THEN cClaveOroN
                                    ELSE b.clave 
                                END
                                );
                             ----------------------------------------------------------------------------------------------------------------
                        ELSE 
                            -- RQM MIGRACION VISA APAGADA               
                            SELECT b.bin, b.codproductotarjeta, clave  
                            INTO cCodBin, cCodProdTar, cClave
                            FROM intercard:binproducto a
                            INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
                            WHERE a.bin = pBin 
                            AND a.producto= pSubBin 
                            AND a.codprodcta = pCodProdCta
                            AND consecutivo = (SELECT max(consecutivo) FROM intercard:tipotarjeta WHERE bin = pBin);

                        END IF;

					END IF;
				END IF;
        

           IF cCodBin IS NULL or cCodProdTar IS NULL OR cClave IS NULL THEN
                      LET  cCodRet = '00001';
           END IF;

           RETURN cCodRet, cCodBin, cCodProdTar, cClave;
END;
END PROCEDURE;