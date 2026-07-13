CREATE PROCEDURE "informix".sp_generarepopertef(pSucursal CHAR (4),
                                                pFechaConsulta DATE,
						                        pRegistros INTEGER)
--1 CVE RASTREO
--2 CTA 
--3 TARJETA

 RETURNING
 --CHAR(5), CHAR(10), CHAR (30), CHAR (30), CHAR (20), CHAR (10), 	
 CHAR(5), DATE, CHAR (30), CHAR (30), CHAR (20), CHAR (10),  
 CHAR (20), CHAR (50), CHAR (8), CHAR (9); 
				   
				   
--DEFINICION DE VARIABLES
    DEFINE iSqlErr               INTEGER;
    DEFINE cCodRet               CHAR (5);
	
    DEFINE cNombre_Cte_Ord       CHAR (30);
	DEFINE cNum_Cta_Ord          CHAR (20);
	DEFINE cImporte_Tef          CHAR (10);
	DEFINE cClave_Rastreo        CHAR (30);
	DEFINE cStatusPago           CHAR (2);
	DEFINE cDescStatusPago       CHAR (20);
	DEFINE cDescMotivoDev        CHAR (50);
	DEFINE cMotivoDev            CHAR (2);
	DEFINE iContador             INTEGER;
	DEFINE cNumCte               CHAR (9);
	DEFINE cUsuario              CHAR (8);
	DEFINE dFecha                CHAR (10);
	
	
	-- SET DEBUG FILE TO "/respaldosbd/Dulce/sp_GeneraRepOperTEF.out";
    -- TRACE ON;
	 
--INICIALIZACION DE VARIABLES
    LET cCodRet              = "00000";
	LET iSqlErr              = 0;
	LET cClave_Rastreo       = "";
	LET cNum_Cta_Ord         = "";
	LET cNombre_Cte_Ord      = "";
	LET cImporte_Tef         = "0.00";
	LET cStatusPago          = "";
	LET cDescStatusPago      = "";
	LET cMotivoDev           = "";
	LET cDescMotivoDev       = "";
	LET iContador            = 0;
	LET cNumCte              = "";
	LET cUsuario             = "";
    LET dFecha               = "01-01-1900";
	
     

 BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			RETURN cCodRet, dFecha, cClave_Rastreo, cNombre_Cte_Ord, cNum_Cta_Ord, cImporte_Tef,
               cDescStatusPago, cDescMotivoDev, cUsuario, cNumCte;  
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF pSucursal IS NULL OR pSucursal = "" OR pFechaConsulta IS NULL OR pFechaConsulta = "" OR
	    pRegistros IS NULL OR pRegistros = "" THEN
	    LET cCodRet = "00001";
		RETURN cCodRet, dFecha, cClave_Rastreo, cNombre_Cte_Ord, cNum_Cta_Ord, cImporte_Tef,
               cDescStatusPago, cDescMotivoDev, cUsuario, cNumCte;   
		
	END IF;


	    FOREACH
				
			SELECT fecha_trans, clave_rastreo, nombre_cte_ord, num_cta_ord, importe_tef, 
			      cve_status, motivo_dev, user_insert 
			INTO dFecha, cClave_Rastreo, cNombre_Cte_Ord, cNum_Cta_Ord, cImporte_Tef,
                   cStatusPago, cMotivoDev, cUsuario			
			FROM bditef:"informix".tef_operaciones
			WHERE sucursal = pSucursal
			AND cve_status <> '04'
			AND fecha_trans  = pFechaConsulta
			
			
			SELECT descripcion
			INTO cDescStatusPago
			FROM bditef:"informix".tef_status_pago 
			WHERE  cve_status = cStatusPago;
			
			
			SELECT descripcion
			INTO cDescMotivoDev
			FROM bditef:"informix".tef_cat_devoluciones 
			WHERE  motivo_dev = cMotivoDev;
			
			
			SELECT num_cte 
			INTO cNumCte
			FROM bdicheq:"informix".sc_maechq
			WHERE cuenta = TRIM(cNum_Cta_Ord);
			
			LET iContador = iContador + 1;
				
			IF iContador <= pRegistros THEN
	            CONTINUE FOREACH;
	        END IF;
				
			RETURN cCodRet, dFecha, cClave_Rastreo, cNombre_Cte_Ord, cNum_Cta_Ord, cImporte_Tef,
               cDescStatusPago, cDescMotivoDev, cUsuario, cNumCte WITH RESUME;   
				
		END FOREACH;

 END;
			   
END PROCEDURE
DOCUMENT
    'AUTOR : Dulce Ramirez',
    'DESCRIPCION: Se encarga de obtener los datos para el reporte de operaciones TEF',
    'EJECUTADO O LLAMADO POR: ',
    'FECHA : MARZO 2011',
    'VERSION: 20110401',
    'BD    : bditef';

CREATE PROCEDURE "informix".sp_obtenerinformaciontef(pTipoBusqueda CHAR(1),
						pCve_Tarj_Cta CHAR(30),
						pFechaActual DATE,
						pRegistros INTEGER)
--1 CVE RASTREO
--2 CTA 
--3 TARJETA

 RETURNING
 	
 CHAR(5), CHAR (30), CHAR (9), CHAR (30), CHAR (20), CHAR (30), CHAR (20), CHAR (20) , CHAR (10), 
			       CHAR (50), CHAR (7), CHAR (40), CHAR (6), CHAR (50), CHAR (20); 
				   

--DEFINICION DE VARIABLES
    DEFINE iSqlErr               INTEGER;
    DEFINE cCodRet               CHAR (5);
	DEFINE cCodRet1              CHAR (5);
	DEFINE cCodRet2              CHAR (5);
	DEFINE cClave_Rastreo        CHAR (30);
    DEFINE cNombre_Cte_Ord       CHAR (30);
	DEFINE cNum_Cta_Ord          CHAR (20);
	DEFINE cNombre_Ben           CHAR (30);
	DEFINE cNum_Cuenta_Tarj_Ben  CHAR (20);
	DEFINE cTipo_Cta_Ord         CHAR (2); 
	DEFINE cDescTipo_Cta_Ord      CHAR (20);
	DEFINE cImporte_Tef          CHAR (10);
	DEFINE cConcepto_Pago        CHAR (50);
	DEFINE cRef_Num              CHAR (7);
	DEFINE cHora_insert          CHAR (6);
	DEFINE cBanco                CHAR (3);
	DEFINE cDescBanco            CHAR (40);
	DEFINE cStatus               CHAR (2);
	DEFINE cDescStatus           CHAR (20);
	DEFINE cMot_Dev              CHAR (2);
	DEFINE cDescMot_Dev          CHAR (50);
	DEFINE iContador             INTEGER;
	DEFINE cNumCte               CHAR (9);
    DEFINE cDias                 CHAR (3);
	DEFINE dFechaInicial         DATE;
	DEFINE ilongitud             INTEGER;

--INICIALIZACION DE VARIABLES
    LET iSqlErr              = 0;
    LET cCodRet              = "00000";
	LET cCodRet1             = "00000";
	LET cCodRet2             = "00000";
	LET cClave_Rastreo       = "";
	LET cNombre_Cte_Ord      = "";
	LET cNum_Cta_Ord         = "";
	LET cNombre_Ben          = "";
	LET cNum_Cuenta_Tarj_Ben = "";
	LET cTipo_Cta_Ord        = "";
	LET cDescTipo_Cta_Ord    = "";
	LET cImporte_Tef         = "";
	LET cConcepto_Pago       = "";
	LET cRef_Num             = "";
	LET cHora_insert         = "";
	LET cBanco               = "";
	LET cDescBanco           = "";
	LET cStatus              = "";
	LET cDescStatus          = "";
	LET cMot_Dev             = "";
	LET cDescMot_Dev         = "";
	LET iContador            = 0;
	LET cNumCte              = "";
	LET cDias                = "";
	LET dFechaInicial        = "01/01/1900";
	LET ilongitud            = 0;
	
  --    SET DEBUG FILE TO "/respaldosbd/Dulce/sp_ObtenerInformacionTEF.out";
  --   TRACE ON;

 BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			RETURN cCodRet, cClave_Rastreo, cNumCte, cNombre_Cte_Ord, cNum_Cta_Ord, cNombre_Ben, cNum_Cuenta_Tarj_Ben, cDescTipo_Cta_Ord , cImporte_Tef, 
			       cConcepto_Pago, cRef_Num, cDescBanco, cHora_insert, cDescMot_Dev, cDescStatus;
        END IF;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;

	IF pTipoBusqueda IS NULL OR pTipoBusqueda = "" OR pCve_Tarj_Cta IS NULL OR pCve_Tarj_Cta = "" OR
	   pFechaActual IS NULL OR pFechaActual = ""  OR pRegistros IS NULL OR pRegistros = "" THEN
	       LET cCodRet = "00003";
		RETURN cCodRet, cClave_Rastreo, cNumCte, cNombre_Cte_Ord, cNum_Cta_Ord, cNombre_Ben, cNum_Cuenta_Tarj_Ben, cDescTipo_Cta_Ord , cImporte_Tef, 
			       cConcepto_Pago, cRef_Num, cDescBanco, cHora_insert, cDescMot_Dev, cDescStatus;
		
	END IF;
					
						
	EXECUTE PROCEDURE BDITEF:"informix".sp_ObtieneParamTEF('03')
	INTO cCodRet1,  cDias;
	
	
	IF cCodRet1 <> "00000" THEN
	    LET cCodRet  = cCodRet1;
	    RETURN cCodRet, cClave_Rastreo, cNumCte, cNombre_Cte_Ord, cNum_Cta_Ord, cNombre_Ben, cNum_Cuenta_Tarj_Ben, cDescTipo_Cta_Ord , cImporte_Tef, 
			    cConcepto_Pago, cRef_Num, cDescBanco, cHora_insert, cDescMot_Dev, cDescStatus;
    END IF;
 
	
	LET dFechaInicial = pFechaActual - cDias::INTEGER;
	
	
	IF pTipoBusqueda = '1' THEN --Cve Rastreo
	
	  	SELECT NVL(valor,'')::INT
        INTO ilongitud
	    FROM bditef:"informix".tef_parametros
	    WHERE cod_param = '10';
	
	    IF LENGTH(TRIM(pCve_Tarj_Cta)) <>  ilongitud THEN
		    LET cCodRet = '00006';	 --longitud invalida
		    RETURN cCodRet, cClave_Rastreo, cNumCte, cNombre_Cte_Ord, cNum_Cta_Ord, cNombre_Ben, cNum_Cuenta_Tarj_Ben, cDescTipo_Cta_Ord , cImporte_Tef, 
			      cConcepto_Pago, cRef_Num, cDescBanco, cHora_insert, cDescMot_Dev, cDescStatus;
		END IF;
		
	    FOREACH
		    SELECT clave_rastreo, nombre_cte_ord, num_cta_ord, nombre_ben, tipo_cta_ord, num_cuenta_tarj_ben, 
			    importe_tef, concepto_pago, ref_num, hora_insert, cve_banco_rec, cve_status, motivo_dev  
			INTO cClave_Rastreo, cNombre_Cte_Ord, cNum_Cta_Ord, cNombre_Ben, cTipo_Cta_Ord, cNum_Cuenta_Tarj_Ben, 
				cImporte_Tef, cConcepto_Pago, cRef_Num, cHora_insert, cBanco, cStatus, cMot_Dev	
            FROM bditef:"informix".tef_operaciones
		    WHERE fecha_trans BETWEEN dFechaInicial AND pFechaActual
			AND clave_rastreo = pCve_Tarj_Cta
			AND num_serial <> ""
			
			SELECT descripcion
			INTO cDescBanco
			FROM bdinteg:"informix".si_bancos
			WHERE banco = cBanco;
		
		    SELECT descripcion
			INTO  cDescMot_Dev
			FROM bditef:"informix".tef_cat_devoluciones
			WHERE motivo_dev = cMot_Dev;
			
			SELECT descripcion
			INTO  cDescStatus
			FROM bditef:"informix".tef_status_pago
			WHERE cve_status = cStatus;
			
			SELECT descripcion
			INTO cDescTipo_Cta_Ord
			FROM bditef:"informix".tef_tipo_cta
			WHERE tipo_cta = cTipo_Cta_Ord;
			
		
			SELECT num_cte 
			INTO cNumCte
			FROM bdicheq:"informix".sc_maechq
			WHERE cuenta = TRIM(cNum_Cta_Ord);
			
			LET iContador = iContador + 1;
				
			IF iContador <= pRegistros THEN
	            CONTINUE FOREACH;
	        END IF;
				
			RETURN cCodRet, cClave_Rastreo, cNumCte, cNombre_Cte_Ord, cNum_Cta_Ord, cNombre_Ben, cNum_Cuenta_Tarj_Ben, cDescTipo_Cta_Ord , cImporte_Tef, 
			       cConcepto_Pago, cRef_Num, cDescBanco, cHora_insert, cDescMot_Dev, cDescStatus WITH RESUME;   
				
		END FOREACH;
	ELIF pTipoBusqueda = '2' OR pTipoBusqueda = '3' THEN --2 CTA 3 TARJETA
	    IF pTipoBusqueda = '3' THEN
		    SELECT NVL(valor,'')::INT
	        INTO ilongitud
		    FROM bditef:"informix".tef_parametros
		    WHERE cod_param = '09';
			
		    IF LENGTH(TRIM(pCve_Tarj_Cta)) <> 16 THEN
			    LET cCodRet = '00006';	 --longitud invalida
				RETURN cCodRet, cClave_Rastreo, cNumCte, cNombre_Cte_Ord, cNum_Cta_Ord, cNombre_Ben, cNum_Cuenta_Tarj_Ben, cDescTipo_Cta_Ord , cImporte_Tef, 
			       cConcepto_Pago, cRef_Num, cDescBanco, cHora_insert, cDescMot_Dev, cDescStatus;
			END IF;
		
			SELECT cuenta
			INTO pCve_Tarj_Cta
			FROM bdicheq:"informix".sc_tarjeta
			WHERE empresa = '001'
			AND num_tarjeta = TRIM(pCve_Tarj_Cta)
			AND status_tar = 'A';
			
            IF TRIM(pCve_Tarj_Cta) = '' OR pCve_Tarj_Cta IS NULL THEN
                LET cCodRet = '00004';
                RETURN cCodRet, cClave_Rastreo, cNumCte, cNombre_Cte_Ord, cNum_Cta_Ord, cNombre_Ben, cNum_Cuenta_Tarj_Ben, cDescTipo_Cta_Ord , cImporte_Tef, 
			       cConcepto_Pago, cRef_Num, cDescBanco, cHora_insert, cDescMot_Dev, cDescStatus;
            END IF;
		ELSE
		    --SELECT {+INDEX(sc_param idx_param1)} ,valor::INT
			SELECT valor::INT
			INTO ilongitud
			FROM bdicheq:"informix".sc_param 
			WHERE empresa = "001"
			AND codparam = 'longcta'; 
	  
            IF LENGTH(TRIM(pCve_Tarj_Cta)) <> 11 THEN
			    LET cCodRet = '00006';	 --longitud invalida
				RETURN cCodRet, cClave_Rastreo, cNumCte, cNombre_Cte_Ord, cNum_Cta_Ord, cNombre_Ben, cNum_Cuenta_Tarj_Ben, cDescTipo_Cta_Ord , cImporte_Tef, 
			       cConcepto_Pago, cRef_Num, cDescBanco, cHora_insert, cDescMot_Dev, cDescStatus;
		    END IF;		
		END IF;
        
	    
    	FOREACH
			
			
			SELECT clave_rastreo, nombre_cte_ord, num_cta_ord, nombre_ben, tipo_cta_ord, num_cuenta_tarj_ben, 
			    importe_tef, concepto_pago, ref_num, hora_insert, cve_banco_rec, cve_status, motivo_dev  
			INTO cClave_Rastreo, cNombre_Cte_Ord, cNum_Cta_Ord, cNombre_Ben, cTipo_Cta_Ord, cNum_Cuenta_Tarj_Ben, 
				cImporte_Tef, cConcepto_Pago, cRef_Num, cHora_insert, cBanco, cStatus, cMot_Dev	
            FROM bditef:"informix".tef_operaciones
			WHERE fecha_trans BETWEEN dFechaInicial AND pFechaActual
		    AND num_cta_ord = pCve_Tarj_Cta
			AND num_serial <> ""
			--AND  status_cta = 1;
			
			SELECT descripcion
			INTO cDescBanco
			FROM bdinteg:"informix".si_bancos
			WHERE banco = cBanco;
		
		    SELECT descripcion
			INTO  cDescMot_Dev
			FROM bditef:"informix".tef_cat_devoluciones
			WHERE motivo_dev = cMot_Dev;
			
			SELECT descripcion
			INTO  cDescStatus
			FROM bditef:"informix".tef_status_pago
			WHERE cve_status = cStatus;
			
			SELECT descripcion
			INTO cDescTipo_Cta_Ord
			FROM bditef:"informix".tef_tipo_cta
			WHERE tipo_cta = cTipo_Cta_Ord;
			
			
			SELECT num_cte 
			INTO cNumCte
			FROM bdicheq:"informix".sc_maechq
			WHERE cuenta = TRIM(cNum_Cta_Ord);
			
			LET iContador = iContador + 1;
			
			IF iContador <= pRegistros THEN
				CONTINUE FOREACH;
			END IF;
			
			RETURN cCodRet, cClave_Rastreo, cNumCte, cNombre_Cte_Ord, cNum_Cta_Ord, cNombre_Ben, cNum_Cuenta_Tarj_Ben, cDescTipo_Cta_Ord , cImporte_Tef, 
			       cConcepto_Pago, cRef_Num, cDescBanco, cHora_insert, cDescMot_Dev, cDescStatus WITH RESUME;
			
			
		END FOREACH;	
	        
    		     
	ELSE
	    LET cCodRet = '00005';	 --Tipo de bùsqueda invalido
		RETURN cCodRet, cClave_Rastreo, cNumCte, cNombre_Cte_Ord, cNum_Cta_Ord, cNombre_Ben, cNum_Cuenta_Tarj_Ben, cDescTipo_Cta_Ord , cImporte_Tef, 
			       cConcepto_Pago, cRef_Num, cDescBanco, cHora_insert, cDescMot_Dev, cDescStatus;
	END IF;

	
 END;
END PROCEDURE
DOCUMENT
    'AUTOR : Dulce Ramirez',
    'DESCRIPCION: Se encarga de obtener la informacion de las operaciones TEF',
    'EJECUTADO O LLAMADO POR: ',
    'FECHA : MARZO 2011',
    'VERSION: 20110311',
    'BD    : bditef';

CREATE PROCEDURE "informix".sp_obtenernomarch_tef
(
piTipoArchivo INTEGER
)

RETURNING CHAR(5) AS CodRet, CHAR(20) AS NomArchivo;

--*********************************************************************************************************
-- DESCRIPCION: Arma los nombres de los archivos correspondientes para su carga y proceso manual.
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 2011/03/21
-- BD: bditef
-- SISTEMA : Transferencia Electronica de Fondos
--*********************************************************************************************************

DEFINE vsCodBanco CHAR(3);
DEFINE viTipoArchivo SMALLINT;
DEFINE vsNomArchivo CHAR(20);
DEFINE vdtFecha DATE;
DEFINE vsDia CHAR(2);
DEFINE vsMes CHAR(2);
DEFINE vsAno CHAR(4);

DEFINE vsCodRet CHAR(5);
DEFINE viSqlErr INTEGER;

LET vsCodBanco = "";
LET viTipoArchivo = 0;
LET vsNomArchivo = "";
LET vdtFecha = CURRENT::DATE;
LET vsDia = "";
LET vsMes = "";
LET vsAno = "";

LET vsCodRet = "";
LET viSqlErr = 0;

--SET DEBUG FILE TO "/tmp/TEF/trace/sp_obtenernomarch_tef.sql";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
		RETURN viSqlErr, vsNomArchivo;
	END IF;
END EXCEPTION;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;
SELECT FIRST 1 Fecha_Hoy INTO vdtFecha FROM bdinteg:"informix".si_fechas;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;
SELECT FIRST 1 TRIM(valor) INTO vsCodBanco FROM bditef:"informix".tef_parametros WHERE cod_param = '75';

/*IF(piTipoArchivo = 7)THEN
	LET vdtFecha = vdtFecha::DATE + 1;
	EXECUTE PROCEDURE bditef:"informix".sp_valida_fecha(LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0')) INTO vsCodRet;
	WHILE vsCodRet = "01601"
		LET vdtFecha = vdtFecha::DATE + 1;
		EXECUTE PROCEDURE bditef:"informix".sp_valida_fecha(LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0')) INTO vsCodRet;
	END WHILE;
ELSE*/
EXECUTE PROCEDURE bditef:"informix".sp_valida_fecha(LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0')) INTO vsCodRet;
--END IF;

IF(vsCodRet = "00000")THEN
	IF((piTipoArchivo = 1) OR (piTipoArchivo = 2))THEN
		IF (piTipoArchivo = 1) THEN --ARCHIVO 60
			LET viTipoArchivo = 60;
		ELIF (piTipoArchivo = 2) THEN -- ARCHIVO 10
			LET viTipoArchivo = 10;
		ELSE --NINGUN TIPO DEFINIDO
			LET viTipoArchivo = 0;
		END IF;

		LET vsNomArchivo = 'S' --CONSTANTE
						|| '01'--CONSTANTE
						|| TRIM(vsCodBanco) --ID BANCARIA BANCOPPEL 137
						|| 'A' --CONSTANTE
						|| '2' --SERVICIO TEF  [2 ? TRANSFERENCIA ELECTRÓNICA DE FONDOS]
						|| '.' --CONSTANTE
						|| 'A' --ARCHIVO DE DATOS
						|| viTipoArchivo::CHAR(2) 
						|| LPAD(DAY(vdtFecha), 2, '0') --FECHA DEL ARCHIVO DIA DEL MES --DD--
						|| '98'; --SECUENCIA DEL ARCHIVO 98 PARA AUTOMATICO
	ELIF((piTipoArchivo >= 3) AND (piTipoArchivo <= 5))THEN
		IF (piTipoArchivo = 3) THEN -- ARCHIVO 61
			LET viTipoArchivo = 61;
		ELIF (piTipoArchivo = 4) THEN -- ARCHIVO 62
			LET viTipoArchivo = 62;
		ELIF (piTipoArchivo = 5) THEN -- ARCHIVO 63
			LET viTipoArchivo = 63;
		ELSE --NINGUN TIPO DEFINIDO
			LET viTipoArchivo = 0;
		END IF;
			
		LET vsDia = LPAD (DAY(vdtFecha), 2, '0');
		-- Se asigna a variable el nombre completo del archivo.
		LET vsNomArchivo = 'S' --CONSTANTE
						|| '01' --PLAZA DE LA CÁMARA DE COMPENSACIÓN ELECTRÓNICA NACIONAL.
						|| TRIM(vsCodBanco)--BANCOPEL ID
						|| 'A' --CARÁCTER QUE IDENTIFICA EL BUZÓN (CONSTANTE)
						|| '2' --SERVICIO TEF  [2 ? TRANSFERENCIA ELECTRÓNICA DE FONDOS]
						|| '.' --CONSTANTE
						|| 'A' -- TIPO DE ARCHIVO [A o H]
						|| viTipoArchivo::CHAR(2) --TIPO DE ARCHIVO  [60]
						|| vsDia --DIA DE PROCESO
						|| '98'; 
	ELIF(piTipoArchivo = 6)THEN 
		--Se arma la fecha dia mes y año para el armado completo del nombre de archivo.
		LET vsDia = LPAD (DAY(vdtFecha), 2, '0');
		LET vsMes = LPAD (MONTH(vdtFecha), 2, '0');
		LET vsAno = LPAD (YEAR(vdtFecha), 4, '0');
		LET viTipoArchivo = 60;
		-- Se asigna a variable el nombre completo del archivo.
		LET vsNomArchivo = 'E' --CONSTANTE
							|| TRIM(vsCodBanco)--CONSTANTE
							|| vsDia
							|| vsMes
							|| vsAno
							|| '.' --CONSTANTE
							|| viTipoArchivo::CHAR(2)
							|| '01'; --SECUENCIA DEL ARCHIVO 01 PARA AUTOMATICO
	ELIF(piTipoArchivo = 7)THEN
		--Se arma la fecha dia mes y año para el armado completo del nombre de archivo.
		LET vsDia = LPAD (DAY(vdtFecha), 2, '0');
		LET vsMes = LPAD (MONTH(vdtFecha), 2, '0');
		LET vsAno = LPAD (YEAR(vdtFecha), 4, '0');
		LET viTipoArchivo = 63;
		-- Se asigna a variable el nombre completo del archivo.
		LET vsNomArchivo = 'E' --CONSTANTE
							|| TRIM(vsCodBanco)--CONSTANTE
							|| vsDia
							|| vsMes
							|| vsAno
							|| '.' --CONSTANTE
							|| viTipoArchivo::CHAR(2)
							|| '01'; --SECUENCIA DEL ARCHIVO 98 PARA AUTOMATICO
	END IF;
ELSE
	LET vsCodRet = "00001";
END IF;

RETURN vsCodRet, vsNomArchivo;


END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Arma los nombres de los archivos correspondientes para su carga, proceso y generación manual.',
'Fecha: 2011/03/21',
'Version: 20110321.1800',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_obtienebancostef(pRegistros INTEGER)

 RETURNING
 CHAR(5), CHAR (3), CHAR (40);

--DEFINICION DE VARIABLES
    DEFINE iSqlErr       INTEGER;
    DEFINE cCodRet       CHAR (5);
    DEFINE cBanco        CHAR (3);
    DEFINE cDescripcion  CHAR (40);
    DEFINE iCiclo        INTEGER;

--INICIALIZACION DE VARIABLES
    LET cCodRet      = "00000";
    LET iCiclo       = 0;
	LET cBanco       = "";
	LET cDescripcion = "";
	
	
     --SET DEBUG FILE TO "/respaldosbd/Dulce/sp_ObtieneBancosTEF.out";
     --TRACE ON;

 BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			RETURN cCodRet, cBanco, cDescripcion;
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF pRegistros IS NULL OR pRegistros = "" THEN
	    LET cCodRet = "00001";
	    RETURN cCodRet, cBanco, cDescripcion;
		
	END IF;

	FOREACH

		SELECT {+INDEX(bdinteg:"informix".si_bancos idx_banco)}  banco, descripcion 
		INTO cBanco, cDescripcion
		FROM  bdinteg:"informix".si_bancos
		WHERE flg_tef_r = "1"
		AND banco <> "137"
        ORDER BY banco
		
	    LET iCiclo = iCiclo + 1;

-- PAGINACION
	IF iCiclo <= pRegistros THEN
		CONTINUE FOREACH;
	END IF;
	
	   RETURN cCodRet, cBanco, cDescripcion WITH RESUME;
    END FOREACH;

 END;
END PROCEDURE
DOCUMENT
    'AUTOR : Dulce Ramirez',
    'DESCRIPCION: Se encarga de obtener los bancos para TEF',
    'EJECUTADO O LLAMADO POR: ',
    'FECHA : MARZO 2011',
    'VERSION: 20110309',
    'BD    : bditef';

CREATE PROCEDURE "informix".sp_obtienecveratreo(pSucursal CHAR(4), pUsuarios CHAR (8))


 RETURNING
   CHAR(5), CHAR (30);

--DEFINICION DE VARIABLES
    DEFINE iSqlErr             INTEGER;
    DEFINE cCodRet             CHAR (5);
	DEFINE cCodRet1            CHAR (5);
	DEFINE cCodRet2            CHAR (5);
	DEFINE cCveBcpTEF          CHAR (50);
	
	DEFINE cCveRastreo         CHAR (30);
    DEFINE iConsecutivo        INTEGER;
	DEFINE cConsecutivo        CHAR (50);
	DEFINE cCodigo             CHAR (50);
	
--INICIALIZACION DE VARIABLES
    LET  cCodRet      = "00000";
	LET iSqlErr       = 0;
	LET  cCodigo      = "";
	LET  cCveRastreo  = "";
    LET iConsecutivo  = 0;
	
    
	
	
  --  SET DEBUG FILE TO "/respaldosbd/Dulce/sp_ObtieneCveRatreo.out";
  --  TRACE ON;

 BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			 RETURN cCodRet, cCveRastreo;
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF pSucursal  IS NULL OR pSucursal = "" OR pUsuarios IS NULL OR pUsuarios = ""   THEN
	    LET cCodRet = "00003";
        RETURN cCodRet, cCveRastreo;
	END IF;
	
	EXECUTE PROCEDURE  BDITEF:"informix".sp_ObtieneParamTEF('02')  --Se obtiene la clave
	INTO cCodRet1, cCveBcpTEF;

	
	IF CAST(cCodRet1 AS INTEGER) <> 0 THEN
	    LET cCodRet  = cCodRet1;
	ELSE
	    SET LOCK MODE TO WAIT 3;
		SELECT valor
        INTO cConsecutivo
        FROM bditef:"informix".tef_parametros
        WHERE cod_param = "05";
		IF cConsecutivo IS NOT NULL AND cConsecutivo <> "" THEN
		    LET iConsecutivo = CAST (cConsecutivo AS INTEGER) + 1;
		    SET LOCK MODE TO WAIT 3;
			UPDATE bditef:"informix".tef_parametros 
			SET valor = iConsecutivo 
			WHERE cod_param = "05";
		
			LET cCveRastreo = TRIM(cCveBcpTEF) || LPAD(TRIM(pSucursal),4,'0') || pUsuarios || LPAD(TRIM(cConsecutivo),8,'0');
		ELSE
		    LET cCodRet = "00004";
		END IF;
	
	END IF;
	
	RETURN cCodRet, cCveRastreo;
	
 END;
END PROCEDURE
DOCUMENT
    'AUTOR : Dulce Ramirez',
    'DESCRIPCION: Se encarga de obtener la clave de rastreo para las operaciones TEF',
    'EJECUTADO O LLAMADO POR: ',
    'FECHA : MARZO 2011',
    'VERSION: 20110311',
    'BD    : bditef';

CREATE PROCEDURE "informix".sp_obtieneparamtef(pParametro CHAR(2))

 RETURNING
 CHAR(5), CHAR (100);

--DEFINICION DE VARIABLES
    DEFINE iSqlErr  INTEGER;
    DEFINE cCodRet  CHAR (5);
    DEFINE cValor   CHAR (100);


--INICIALIZACION DE VARIABLES
    LET iSqlErr = 0;
    LET cCodRet = "00000";
    LET cValor  = "";

     --SET DEBUG FILE TO "/respaldosbd/Dulce/sp_ObtieneParamTEF.out";
     --TRACE ON;


 BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			RETURN cCodret, cValor;
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF pParametro IS NULL OR pParametro = "" THEN
	    LET cCodRet = "00001";
		 RETURN cCodret, cValor;
	END IF;
	
    SELECT NVL(valor,'')
    INTO cValor
    FROM bditef:"informix".tef_parametros
    WHERE cod_param = pParametro;
    
	IF cValor = "" OR cValor IS NULL THEN
	    LET cCodRet = "00002";
		LET cValor  = "";
	END IF;

    RETURN cCodret, cValor;

 END;
END PROCEDURE
DOCUMENT
    'AUTOR : Dulce Ramirez',
    'DESCRIPCION: Se encarga de obtener el valor del parametro recibido',
    'EJECUTADO O LLAMADO POR: ',
    'FECHA : MARZO 2011',
    'VERSION: 20110309',
    'BD    : bditef';

CREATE PROCEDURE "informix".sp_obtienetipoctastef(pTipo CHAR (1), pCuentas CHAR (20), pRegistros SMALLINT )

 RETURNING
 CHAR(5), CHAR (2), CHAR (20);
 
--DEFINICION DE VARIABLES
    DEFINE iSqlErr       INTEGER;
    DEFINE cCodRet       CHAR (5);
    DEFINE cTipo_Cta     CHAR (2);
	DEFINE cDescripcion  CHAR (20);
    DEFINE iCiclo        INTEGER;
	DEFINE cCuentas      CHAR (60);
	DEFINE i             INTEGER;
	DEFINE iLongitud     INTEGER;

--INICIALIZACION DE VARIABLES
    LET cCodRet      = "00000";
    LET iCiclo      = 0;
	LET cTipo_Cta    = "";
	LET cDescripcion = "";
    LET i = 1;
	LET iLongitud    = 0;
	LET cCuentas = "";
	
    -- SET DEBUG FILE TO "/respaldosbd/Dulce/sp_ObtieneTipoCtasTEF.out";
    -- TRACE ON;

 BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			RETURN cCodRet, cTipo_Cta, cDescripcion;
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF pRegistros IS NULL OR pRegistros = "" OR pCuentas IS NULL OR pCuentas = "" THEN
	    LET cCodRet = "00001";
	    RETURN cCodRet, cTipo_Cta, cDescripcion;
		
	END IF;
	
	LET pCuentas = TRIM(pCuentas);
	LET iLongitud = LENGTH(pCuentas);
	
	IF pTipo = "1" THEN
	
		WHILE i <= iLongitud 
			
			IF MOD(i , 3) <> 0 THEN
				LET cCuentas = SUBSTRING(TRIM(pCuentas) FROM i FOR 2);
				LET i = i + 3;
			
				SELECT {+INDEX(bditef:"informix".tef_tipo_cta idx_tef_tipo_cta)} tipo_cta, descripcion
				INTO cTipo_Cta, cDescripcion
				FROM  bditef:"informix".tef_tipo_cta
				WHERE tipo_cta = cCuentas
				AND receptor = "1";

				IF cTipo_Cta IS NULL THEN
					LET cCodRet = '00002';
					LET cTipo_Cta = '';
					LET cDescripcion = '';
				END IF;
			
				LET iCiclo = iCiclo + 1;
			
				IF iCiclo > pRegistros THEN
					RETURN cCodRet, cTipo_Cta, cDescripcion WITH RESUME;
				END IF;   
		
			END IF;
		END WHILE;
	ELIF pTipo = "2" THEN
	
	
	    WHILE i <= iLongitud 
			
			IF MOD(i , 3) <> 0 THEN
				LET cCuentas = SUBSTRING(TRIM(pCuentas) FROM i FOR 2);
				LET i = i + 3;
			
				SELECT {+INDEX(bditef:"informix".tef_tipo_cta idx_tef_tipo_cta_ord)} tipo_cta, descripcion
		        INTO cTipo_Cta, cDescripcion
		        FROM  bditef:"informix".tef_tipo_cta
		        WHERE tipo_cta = cCuentas
		        AND ordenante = "1";

				IF cTipo_Cta IS NULL THEN
					LET cCodRet = '00002';
					LET cTipo_Cta = '';
					LET cDescripcion = '';
				END IF;
			
				LET iCiclo = iCiclo + 1;
			
				IF iCiclo > pRegistros THEN
					RETURN cCodRet, cTipo_Cta, cDescripcion WITH RESUME;
				END IF;   
		
			END IF;
		END WHILE;
					
					
	ELSE
	    LET cCodRet = "00003";
		RETURN cCodRet, cTipo_Cta, cDescripcion;
    END IF;	
	 
 END;
END PROCEDURE
DOCUMENT
    'AUTOR : Dulce Ramirez',
    'DESCRIPCION: Se encarga de obtener los tipos de cuenta para banco receptor',
    'EJECUTADO O LLAMADO POR: ',
    'FECHA : MARZO 2011',
    'VERSION: 20110328',
    'BD    : bditef';

CREATE PROCEDURE "informix".sp_obtienetipoopertef(pRegistros INTEGER)


 RETURNING
   CHAR(5), CHAR (2), CHAR (30), CHAR (20);

--DEFINICION DE VARIABLES
    DEFINE iSqlErr             INTEGER;
    DEFINE cCodRet             CHAR (5);
	
	DEFINE cCodigo             CHAR (2);
	DEFINE cDescripcion        CHAR (30);
	DEFINE cTipo_Cta_Aplica    CHAR (20);
	DEFINE iContador           INTEGER;
	
--INICIALIZACION DE VARIABLES
    LET  cCodRet      = "00000";
	LET iSqlErr  = 0;
	LET  cCodigo      = "";
	LET  cDescripcion = "";
	LET  cTipo_Cta_Aplica = "";
    LET iContador = 0;
	
		
   -- SET DEBUG FILE TO "/respaldosbd/Dulce/sp_ObtieneTipoOperTEF.out";
   -- TRACE ON;

 BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodigo, cDescripcion, cTipo_Cta_Aplica;
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
    IF pRegistros IS NULL OR pRegistros = "" THEN
	    LET cCodRet = "00001";
	    RETURN cCodRet, cCodigo, cDescripcion, cTipo_Cta_Aplica;
	END IF;
	
	FOREACH
	    SELECT codigo, descripcion, tipo_cta_aplica 
		INTO cCodigo, cDescripcion, cTipo_Cta_Aplica
		FROM bditef:"informix".tef_tipo_oper 
		WHERE codigo <> ""--IS NOT NULL
		
		LET iContador = iContador + 1;
		 
		IF iContador <= pRegistros THEN
		    CONTINUE FOREACH;
	    END IF;
			
		RETURN cCodRet, cCodigo, cDescripcion, cTipo_Cta_Aplica WITH RESUME;
			
	END FOREACH
	
 END;
END PROCEDURE
DOCUMENT
    'AUTOR : Dulce Ramirez',
    'DESCRIPCION: Se obtener los tipos de operaciones TEF',
    'EJECUTADO O LLAMADO POR: ',
    'FECHA : MARZO 2011',
    'VERSION: 20110328',
    'BD    : bditef';

CREATE PROCEDURE "informix".sp_revoperacionestef(pFolioSuc CHAR (16), pFecha DATE, pSucursal CHAR (4))
 RETURNING
 	
 CHAR(5); 
				   
				   
--DEFINICION DE VARIABLES
    DEFINE iSqlErr         INTEGER;
    DEFINE cCodRet         CHAR (5);
	DEFINE cCodRet1        CHAR (5);
	DEFINE cCodRet2        CHAR (5);
  
	--DEFINE cStatusProceso   CHAR (1);
	DEFINE cStatusPago     CHAR (2);
	DEFINE cHoraMax        CHAR (5);
	
	
	--SET DEBUG FILE TO "/respaldosbd/Dulce/sp_RevOperacionesTEF.out";
    --TRACE ON;
	 
--INICIALIZACION DE VARIABLES
    LET cCodRet            = "00000";
	LET iSqlErr            = 0;
	LET cCodRet1           = "00000";
	LET cCodRet2           = "00000";
	--LET cStatusProceso       = "";
	LET cStatusPago        = "";
	LET cHoraMax           = "";

 BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			RETURN cCodRet;  
        END IF;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;

	IF pFolioSuc IS NULL OR pFolioSuc = "" OR pFecha IS NULL OR pFecha = "" 
	    OR pSucursal IS NULL OR pSucursal = "" THEN
	    LET cCodRet = "00003";	--Parámetros invalidos
		RETURN cCodRet; 
	END IF;

	SELECT cve_status 
    INTO cStatusPago
	FROM bditef:"informix".tef_operaciones 
	WHERE folio_suc = pFolioSuc
	AND fecha_trans = pFecha
	AND sucursal = pSucursal;
	
		 
	IF cStatusPago IS NOT NULL OR cStatusPago <> "" THEN
		
		IF 	cStatusPago <> "PE" THEN
			LET cCodRet = "00004";	--estatus inválido para reversión
		ELSE
			EXECUTE PROCEDURE  bditef:"informix".sp_ValidaHorarioTEF()
			INTO cCodRet1, cCodRet2;
			IF CAST(cCodRet1 AS INTEGER) <> 0 THEN
				LET cCodRet  = cCodRet1;
			ELIF CAST(cCodRet2 AS INTEGER) <> 0 THEN
				LET cCodRet = cCodRet2;
			ELSE
			 
				IF EXISTS (SELECT estatus FROM bditef:"informix".tef_procesos  WHERE tipo_proceso = "A" AND fecha_proceso = pFecha AND cve_proceso = "GENARCH_60.01") THEN
				    LET cCodRet = "00005";  --El proceso de generación de archivo ya inició / está en proceso
				END IF;
				
			END IF;
		END IF;	
		
    END IF;		
				
		
			
				
	RETURN cCodRet;   

 END;
END PROCEDURE
DOCUMENT
    'AUTOR : Dulce Ramirez',
    'DESCRIPCION: Se encarga de validar si la operacion TEF puede ser reversada',
    'EJECUTADO O LLAMADO POR: ',
    'FECHA : MARZO 2011',
    'VERSION: 20110401',
    'BD    : bditef';

CREATE PROCEDURE "informix".sp_tef_actualizar_cte_detalle(psNombre_Arch CHAR(20),psFecha_Presente CHAR(8))
RETURNING CHAR(5) AS CodRet;


--****************************************************************************************************
-- DESCRIPCION:  ACTUALIZA LOS CAMPOS Nombre_Arch_CCE, FECHA_PRESETACION_CCE, TIPO_REGISTRO_CCE Y NUMERO_SECUENCIA_CCE DE LA TABLA TEF_CTE_DETALLE, DESPUES DE PROCESAR EL 60.
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 09/03/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************


--DECLARACION DE VARIABLES GLOBALES
DEFINE vsCodRet CHAR(5);
DEFINE viSql_Err INTEGER;
DEFINE vsRFC_Rec CHAR(18);
DEFINE vsCveEstatus CHAR(2);
DEFINE vsNumSecuencia CHAR(7);

--INICIALIZACION DE VARIABLES GLOBALES
LET vsCodRet = "";
LET vsRFC_Rec = "";
LET vsCveEstatus = "";
LET vsNumSecuencia = "";

	
BEGIN
ON EXCEPTION SET viSql_Err
	IF (viSql_Err <> 0) THEN
		LET vsCodRet = viSql_Err;
		RETURN vsCodRet;
	END IF;
END EXCEPTION;


--SET DEBUG FILE TO "/dbexport/TEF/trace/sp_tef_actualizar_cte_detalle.out";
--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	LET vsCodRet = "00000";
	
	IF EXISTS(SELECT cod_operacion FROM BdiTef:"informix".Tef_Cce_Detalle_Paso WHERE Nombre_Arch = psNombre_Arch AND fecha_presentacion = psFecha_Presente) THEN
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT RFC_Rec,Cve_Status,Num_Secuencia
			INTO vsRFC_Rec,vsCveEstatus,vsNumSecuencia
			FROM BdiTef:"informix".Tef_Cce_Detalle_Paso
			WHERE Nombre_Arch = psNombre_Arch
			AND Fecha_Presentacion = psFecha_Presente
			
			LET vsCodRet = "00000";
			
		END FOREACH;
		
	ELSE
		--no existe el archivo en la de detalle
		LET vsCodRet = "00800";
	END IF;


RETURN vsCodRet;

END;

END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: ACTUALIZA LOS CAMPOS Nombre_Arch_CCE, FECHA_PRESETACION_CCE, TIPO_REGISTRO_CCE Y NUMERO_SECUENCIA_CCE DE LA TABLA TEF_CTE_DETALLE, DESPUES DE PROCESAR EL 60.',
'Fecha: 2011/03/09',
'Version: 20110309.1815',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_tef_generararchivo63(psNombreArchivo63 CHAR(20),psFechaPresentacion CHAR(8), psUsuario CHAR(8))
RETURNING CHAR(5) AS CodRet;

--****************************************************************************************************
-- DESCRIPCION:  GENERA REGISTROS DEL ARCHIVO 63.
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 27/04/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************

--DEFINICION DE VARIABLES.
DEFINE vsCodRet CHAR(5);
DEFINE vsCodRet2 CHAR(5);
DEFINE vsCodRet3 CHAR(5);

DEFINE viContadorSecuencia63 INTEGER;
DEFINE viImporteTotalArchivo63 INTEGER;
DEFINE vsFecha_Presentacion_Gen CHAR(8);
DEFINE vsFechaManana CHAR(8);

DEFINE vsPrefijoTarjeta CHAR(100);
DEFINE vsBancoPresentador CHAR (3);

DEFINE vsCuenta CHAR(11);
DEFINE vsStatus_Cta CHAR (1);
DEFINE vsProductosNoPermitidos CHAR (100);
DEFINE vsProducto CHAR (4);
DEFINE vdFecha_Hoy DATE;
DEFINE vdFecha_Manana DATE;

DEFINE vsNombre_Arch CHAR(20);
DEFINE vsFecha_Presentacion CHAR(8);
DEFINE vsTipo_Registro CHAR(2);
DEFINE vsNum_Secuencia CHAR(7);
DEFINE vsCod_Operacion CHAR(2);
DEFINE vsCod_Divisa CHAR(2);
DEFINE vsFecha_Trans CHAR(8);
DEFINE vsBanco_Presentador CHAR(3);
DEFINE vsBanco_Receptor CHAR(3);
DEFINE vsImporte CHAR(15);
DEFINE vsUso_Futuro_ccen CHAR(16);
DEFINE vsTipo_Operacion CHAR(2);
DEFINE vsFecha_Aplica CHAR(8);
DEFINE vsTipo_Cta_Ord CHAR(2);
DEFINE vsNum_Cta_Ord CHAR(20);
DEFINE vsNombre_Ord CHAR(40);
DEFINE vsRfc_Ord CHAR(18);
DEFINE vsTipo_Cta_Rec CHAR(2);
DEFINE vsNum_Cta_Rec CHAR(20);
DEFINE vsNombre_Rec CHAR(40);
DEFINE vsRfc_Rec CHAR(18);
DEFINE vsRef_Servicio CHAR(40);
DEFINE vsNombre_Titular_Serv CHAR(40);
DEFINE vsImporte_Iva CHAR(15);
DEFINE vsRef_Numerica CHAR(7);
DEFINE vsRef_Leyenda CHAR(40);
DEFINE vsClave_Rastreo CHAR(30);
DEFINE vsMotivo_Dev CHAR(2);
DEFINE vsFecha_Pres_Ini CHAR(8);
DEFINE vsSolicitud_Confirmacion CHAR(1);
DEFINE vsUso_Futuro_Banco CHAR(11);
DEFINE vsRef_Confirmacion CHAR(30); 
DEFINE vsUso_Futuro_Cce CHAR(1);
DEFINE vsTasa_Tiie_Prom CHAR(7);
DEFINE vsDias_Retraso CHAR(3);
DEFINE vsImp_Tot_Int CHAR(15);
DEFINE vsCve_Estatus CHAR(11);
DEFINE vsFolio_Suc CHAR(30);


DEFINE vsNum_Secuencia_S CHAR(7);
DEFINE vsNum_Operaciones_S CHAR(18);

--TRANSACCIONES
DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER;

DEFINE iSQLerr INTEGER;

--INICIALIZACION DE VARIABLES.
LET vsCodRet = '';
LET vsCodRet2 = '';
LET vsCodRet3 = '';

LET viContadorSecuencia63 = 0;
LET viImporteTotalArchivo63 = 0;
LET vsFecha_Presentacion_Gen = '';
LET vsFechaManana = '';

LET vsPrefijoTarjeta = '';
LET vsBancoPresentador = '';

LET vsCuenta = '';
LET vsStatus_Cta = '';
LET vsProducto = '';
LET vsProductosNoPermitidos = '';
LET vdFecha_Hoy = CURRENT;
LET vdFecha_Manana = CURRENT;

LET vsNombre_Arch = '';
LET vsFecha_Presentacion = '';
LET vsTipo_Registro = '';
LET vsNum_Secuencia = '';
LET vsCod_Operacion = '';
LET vsCod_Divisa = '';
LET vsFecha_Trans = '';
LET vsBanco_Presentador = '';
LET vsBanco_Receptor = '';
LET vsImporte = '';
LET vsUso_Futuro_ccen = '';
LET vsTipo_Operacion = '';
LET vsFecha_Aplica = '';
LET vsTipo_Cta_Ord = '';
LET vsNum_Cta_Ord = '';
LET vsNombre_Ord = '';
LET vsRfc_Ord = '';
LET vsTipo_Cta_Rec = '';
LET vsNum_Cta_Rec = '';
LET vsNombre_Rec = '';
LET vsRfc_Rec = '';
LET vsRef_Servicio = '';
LET vsNombre_Titular_Serv = '';
LET vsImporte_Iva = '';
LET vsRef_Numerica = '';
LET vsRef_Leyenda = '';
LET vsClave_Rastreo = '';
LET vsMotivo_Dev = '';
LET vsFecha_Pres_Ini = '';
LET vsSolicitud_Confirmacion = '';
LET vsUso_Futuro_Banco = '';
LET vsRef_Confirmacion = ''; 
LET vsUso_Futuro_Cce = '';
LET vsTasa_Tiie_Prom = '';
LET vsDias_Retraso = '';
LET vsImp_Tot_Int = '';
LET vsCve_Estatus = '';
LET vsFolio_Suc = '';

LET vsNum_Secuencia_S = '';
LET vsNum_Operaciones_S = '';

--TRANSACCIONES
LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;

LET iSQLerr = 0;

--SET DEBUG FILE TO "/dbexport/TEF/trace/sp_tef_generararchivo63.out";
--TRACE ON;

BEGIN
ON EXCEPTION SET iSQLerr
	IF iSQLerr <> 0 THEN
		LET vsCodRet = iSQLerr;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
		
		RETURN vsCodRet;
	END IF;
END EXCEPTION;

	
	ON EXCEPTION IN (-535)
		COMMIT WORK;
	END EXCEPTION WITH RESUME;
	
	-------SE OBTIENEN LOS PARAMETROS----
	
	--OBTIENE LA CLAVE DEL BANCO PRESENTADOR
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO vsBancoPresentador FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '75'; --C LAVE BANCOPPEL 137
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO vsPrefijoTarjeta FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '76'; -- PREFIJO TARJETA
	
	--SET LOCK MODE TO WAIT 3;
	--SET ISOLATION TO DIRTY READ;
	--SELECT FIRST 1 Valor INTO vsProductosNoPermitidos FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '82'; --PRODUCTOS NO PERMITIDOS
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Fecha_Hoy INTO vdFecha_Hoy FROM BdiCheq:"informix".Sc_Fechas; -- FECHA_HOY
	
	
	--AUMENTA UN DIA LA FECHA ACTUAL (PRESENTACION) PARA SER LA FECHA CARGO/PROGRAMACION
	LET vdFecha_Manana = vdFecha_Hoy + 1;
	
	--ASIGNA UN FORMATO DE FECHA PARA FUTURA FECHA DE PRESENTACION
	LET vsFecha_Presentacion_Gen = YEAR(vdFecha_Hoy)|| LPAD(MONTH (vdFecha_Hoy),2,'0') || LPAD(DAY (vdFecha_Hoy),2,'0');
	
	
	--VALIDA/PROPORCIONA LA FECHA T+1
	EXECUTE PROCEDURE BdInteg:"informix".sp_Valfecha_Banca('001', vdFecha_Manana, 0 ) INTO vsCodRet2,vdFecha_Manana;
	--VALIDA LA FECHA ACTUAL
	EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Fecha(vsFecha_Presentacion_Gen) INTO vsCodRet3;
	
	--ASIGNA UN FORMATO DE FECHA 
	LET vsFechaManana = YEAR(vdFecha_Manana )|| LPAD(MONTH (vdFecha_Manana ),2,'0') || LPAD(DAY (vdFecha_Manana ),2,'0');
		
	--VALIDA LA FECHA MANANA
	EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Fecha(vsFechaManana) INTO vsCodRet;
	
	IF (vsCodRet <> '00000') THEN -- VALIDA KE LA FECHA MANANA SEA VALIDA
		LET vsCodRet = '01700';
	ELIF (vsCodRet2 <> '000') THEN -- VALIDA KE LA FECHA MANANA SEA UN DIA HABIL
		LET vsCodRet = '01701';
	ELIF (vsCodRet3 <> '00000') THEN -- VALIDA KE LA FECHA HOY SEA VALIDA
		LET vsCodRet = '01702';
	ELSE 
		
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
		
		LET viContadorSecuencia63 = 1;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--OBTIENE LOS REGISTROS DEL ARCHIVO PARA PROCESAR
		FOREACH WITH HOLD
		SELECT 
		Nombre_Arch, Fecha_Presentacion, Tipo_Registro, Num_Secuencia, Cod_Operacion, Cod_Divisa, Fecha_Trans, 
		Banco_Presentador, Banco_Receptor, Importe, Uso_Futuro_ccen, Tipo_Operacion, Fecha_Aplica, Tipo_Cta_Ord, 
		Num_Cta_Ord, Nombre_Ord, Rfc_Ord, Tipo_Cta_Rec, Num_Cta_Rec, Nombre_Rec, Rfc_Rec, Ref_Servicio, 
		Nombre_Titular_Serv, Importe_Iva, Ref_Numerica, Ref_Leyenda, Clave_Rastreo, Motivo_Dev, Fecha_Pres_Ini, 
		Solicitud_Confirmacion, Uso_Futuro_Banco, Ref_Confirmacion, Uso_Futuro_Cce, Tasa_Tiie_Prom, Dias_Retraso, 
		Imp_Tot_Int, Cve_Status, Folio_Suc
		INTO 
		vsNombre_Arch, vsFecha_Presentacion, vsTipo_Registro, vsNum_Secuencia, vsCod_Operacion, vsCod_Divisa, vsFecha_Trans, 
		vsBanco_Presentador, vsBanco_Receptor, vsImporte, vsUso_Futuro_ccen, vsTipo_Operacion, vsFecha_Aplica, vsTipo_Cta_Ord, 
		vsNum_Cta_Ord, vsNombre_Ord, vsRfc_Ord, vsTipo_Cta_Rec, vsNum_Cta_Rec, vsNombre_Rec, vsRfc_Rec, vsRef_Servicio, 
		vsNombre_Titular_Serv, vsImporte_Iva, vsRef_Numerica, vsRef_Leyenda, vsClave_Rastreo, vsMotivo_Dev, vsFecha_Pres_Ini, 
		vsSolicitud_Confirmacion, vsUso_Futuro_Banco, vsRef_Confirmacion, vsUso_Futuro_Cce, vsTasa_Tiie_Prom, vsDias_Retraso, 
		vsImp_Tot_Int, vsCve_Estatus, vsFolio_Suc
		FROM BdiTef:"informix".Tef_Cce_Detalle
		WHERE Cod_operacion = '60' 
		AND Cve_Status = '03'
		AND banco_receptor = '137'/*DEVOLUCIONES*/
			
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN 
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;
			
			LET viContadorSecuencia63 = viContadorSecuencia63 +1;
			LET viImporteTotalArchivo63 = viImporteTotalArchivo63 + NVL(vsImporte,0)::INTEGER;
			
			--GUARDA EL REGISTRO DE LA INTRUCCION DE CARGO EN LA TABLA DE PASO
			INSERT INTO BdiTef:"informix".Tef_Cce_Detalle_Paso
			(
				Nombre_Arch,
				Fecha_Presentacion,
				Tipo_Registro,
				Num_Secuencia,
				Cod_Operacion,
				Cod_Divisa,
				Fecha_Trans,
				Banco_Presentador,
				Banco_Receptor,
				Importe,
				Uso_Futuro_Ccen,
				Tipo_Operacion,
				Fecha_Aplica,
				Tipo_Cta_Ord,
				Num_Cta_Ord,
				Nombre_Ord,
				Rfc_Ord,
				Tipo_Cta_Rec,
				Num_Cta_Rec,
				Nombre_Rec,
				Rfc_Rec,
				Ref_Servicio,
				Nombre_Titular_Serv,
				Importe_Iva,
				Ref_Numerica,
				Ref_Leyenda,
				Clave_Rastreo,
				Motivo_Dev,
				Fecha_Pres_Ini,
				Solicitud_Confirmacion,
				Uso_Futuro_Banco,
				Ref_Confirmacion, 
				Uso_Futuro_Cce,
				Tasa_Tiie_Prom,
				Dias_Retraso,
				Imp_Tot_Int,
				Cve_Status,
				Folio_Suc,
				User_Insert,
				Fecha_Insert
			)
			VALUES 
			(
				NVL(psNombreArchivo63,''),
				--NVL(vsFecha_Presentacion_Gen,''), --psFechaPresentacion, -- FECHA PRESENTACION --
                NVL(vsFechaManana,''), --psFechaPresentacion, -- FECHA PRESENTACION --
				NVL(vsTipo_Registro,''),
				NVL(LPAD(viContadorSecuencia63,7,'0'),''),--NUM_SECUENCIA
				'63', --CODIGO DE OPERACION / ARCHIVO
				NVL(vsCod_Divisa,''),
				NVL(vsFechaManana,''), -- VSFECHA_TRANS --T+1
				NVL(vsBanco_Receptor,''),  --BANCO PRESENTADOR
				NVL(vsBanco_Presentador,''),  --BANCO RECEPTOR
				NVL(vsImporte,''),
				NVL(vsUso_Futuro_Ccen,''),
				NVL(vsTipo_Operacion,''),
				NVL(vsFecha_Aplica,''),
				NVL(vsTipo_Cta_Ord,''),
				NVL(vsNum_Cta_Ord,''),
				NVL(vsNombre_Ord,''),
				NVL(vsRfc_Ord,''),
				NVL(vsTipo_Cta_Rec,''),
				NVL(vsNum_Cta_Rec,''),
				NVL(vsNombre_Rec,''),
				NVL(vsRfc_Rec,''),
				NVL(vsRef_Servicio,''),
				NVL(vsNombre_Titular_Serv,''),
				NVL(vsImporte_Iva,''),
				NVL(vsRef_Numerica,''),
				NVL(vsRef_Leyenda,''),
				NVL(vsClave_Rastreo,''),
				NVL(vsMotivo_Dev,''), --MOTIVO DEVOLUCION
				NVL(vsFecha_Pres_Ini,''),
				NVL(vsSolicitud_Confirmacion,''),
				NVL(vsUso_Futuro_Banco,''),
				NVL(vsRef_Confirmacion,''),
				NVL(vsUso_Futuro_Cce,''),
				NVL(vsTasa_Tiie_Prom,''),
				NVL(vsDias_Retraso,''),
				NVL(vsImp_Tot_Int,''),
				NVL(vsCve_Estatus,''),
				NVL(vsFolio_Suc,''), -- FOLIO_SUC
				psUsuario, --USUARIO_INSERT
				CURRENT::DATE --FECHA_INSERT
			);
			
			--ACTUALIZA EL REGISTRO DEL  ARCHIVO 60
			UPDATE BdiTef:"informix".Tef_Cce_Detalle
			SET Cve_Status = '02'
			WHERE Nombre_Arch = vsNombre_Arch 
			AND Cod_operacion = '60' 
			AND Banco_Presentador = vsBanco_Presentador
			AND Banco_Receptor = vsBanco_Receptor
			AND Importe = vsImporte
			AND Fecha_Aplica = vsFecha_Aplica
			AND Num_Cta_Ord = vsNum_Cta_Ord
			AND Rfc_Ord = vsRfc_Ord
			AND Tipo_Cta_Rec = vsTipo_Cta_Rec
			AND Ref_Leyenda = vsRef_Leyenda
			AND Num_Secuencia = vsNum_Secuencia;
			
			LET viContadorRegistros = viContadorRegistros + 1;
			
			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;
			
		END FOREACH;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
		
		--IF (viContadorSecuencia63 > 1) THEN --VALIDA SI EXISTEN REGISTROS PARA EL ARCHIVO 61
			
			--FORMA EL REGISTRO DE ENCABEZADO
			--ENCABEZADO
			INSERT INTO BdiTef:"informix".Tef_Cce_Encabezado_Paso
			(
				Nombre_Arch,
				Fecha_Presentacion,
				Tpo_Registro,
				Num_Secuencia,
				Cod_Operacion,
				Cve_Banco,
				Sentido,
				Servicio,
				Num_Bloque,
				Cod_Divisa,
				Cve_Rechazo_bl,
				Modalidad,
				Uso_Futuro_Ccen,
				Uso_Futuro_Banco,
				User_Insert,
				Fecha_Insert
			)
			VALUES
			(
				NVL(psNombreArchivo63,''),
				--NVL(vsFecha_Presentacion_Gen,''),
                NVL(vsFechaManana,''),
				'01', --TIPO REGISTRO
				LPAD('1',7,'0'), --'0000001', --SECUENCIA
				'63', --ARCHIVO
				NVL(vsBancoPresentador,''), --BANCOPEL 137 
				'E', --SENTIDO
				'2', --SERVICIO
				--NVL(LPAD(DAY(vdFecha_Hoy),2,'0') || LPAD((SUBSTR(psNombreArchivo63,(LENGTH(TRIM(psNombreArchivo63)) - 1), 2)),5,'0'),''), --NUM BLOQUE
                NVL(LPAD(DAY(vdFecha_Manana),2,'0') || LPAD((SUBSTR(psNombreArchivo63,(LENGTH(TRIM(psNombreArchivo63)) - 1), 2)),5,'0'),''), --NUM BLOQUE
				'01', --DIVISA
				'00',--CVE_RECHAZO_BL
				'2',--MODALIDAD
				LPAD('',41,' '),--USO_FUTURO_CCEN
				LPAD('',370,' '),--USO_FUTURO_BANCO
				psUsuario,
				CURRENT::DATE
			);
			
			
			--FORMA EL REGISTRO DE SUMARIO
			--SUMARIO
			INSERT INTO BdiTef:"informix".Tef_Cce_Sumario_Paso
			(
				Nombre_Arch,
				Fecha_Presentacion,
				Tipo_Registro,
				Num_Secuencia,
				Cod_Operacion,
				Num_Bloque,
				Num_Operaciones,
				Imp_Operaciones,
				Uso_Futuro_ccen,
				Uso_Futuro_banco,
				User_Insert,
				Fecha_Insert
			)
			VALUES
			(
				NVL(psNombreArchivo63,''), --NOMBRE_ARCH
				--NVL(vsFecha_Presentacion_Gen,''), --FECHA_PRESENTACION
                NVL(vsFechaManana,''), --FECHA_PRESENTACION
				'09', --TIPO_REGISTRO
				NVL(LPAD((viContadorSecuencia63+1),7,'0'),''), --SECUENCIA
				'63', --COD_OPERACION
				--NVL(LPAD(DAY(vdFecha_Hoy),2,'0') || LPAD((SUBSTR(psNombreArchivo63,(LENGTH(TRIM(psNombreArchivo63)) - 1), 2)),5,'0'),''), --NUM BLOQUE
                NVL(LPAD(DAY(vdFecha_Manana),2,'0') || LPAD((SUBSTR(psNombreArchivo63,(LENGTH(TRIM(psNombreArchivo63)) - 1), 2)),5,'0'),''), --NUM BLOQUE
				NVL(LPAD((viContadorSecuencia63-1),7,'0'),''),--NUM_OPERACIONES -- REGISTROS EN EL DETALLE
				NVL(LPAD(viImporteTotalArchivo63,18,'0'),''),--IMPORTE TOTAL DE OPERACIONES
				LPAD('',40,' '),--USO_FUTURO_CCEN
				LPAD('',364,' '),--USO_FUTURO_BANCO
				psUsuario, --USUARIO_INSERT
				CURRENT::DATE --FECHA_INSERT
			);
			
		--END IF;
		
	END IF;
	
	RETURN vsCodRet;
	
END
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: GENERA REGISTROS DEL ARCHIVO 63.',
'Fecha: 2011/04/27',
'Version: 20110427.1800',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_tef_guardarccearchivos(psUsuario CHAR(8), psNomArchivo VARCHAR(20), psFechaPres CHAR(8), psCveStatus CHAR(2))
RETURNING CHAR(5) AS CodRet; 

--****************************************************************************************************
-- DESCRIPCION:  GUARDAR REGISTRO DE LA OPERACION EN CCEARCHIVOS.
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 09/03/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************

---DECLARACIONES
DEFINE vsCodRet CHAR(5);
DEFINE viSqlErr INTEGER;
DEFINE viSamErr INTEGER;

DEFINE vsDescMensajeError VARCHAR(95);
DEFINE viTotReg INTEGER;
DEFINE vsFechaAplicacion CHAR(8);
DEFINE vdFechaAplicacion DATE;

---INICIALIZACIONES
LET vsCodRet = '00000';
LET vsDescMensajeError = "";
LET vsFechaAplicacion ="";
LET vdFechaAplicacion = CURRENT;

LET viTotReg = 0;

--SET DEBUG FILE TO "/dbexport/TEF/trace/sp_tef_GuardarCCEArchivos.out";
--TRACE ON;

BEGIN
ON EXCEPTION
	SET viSqlErr, viSamErr
	IF (viSqlErr <> 0) THEN
		LET vsCodRet = viSqlErr;
	END IF;

	RETURN vsCodRet;
END EXCEPTION;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

	IF (psCveStatus <> '11') THEN
	
		IF (psCveStatus = '02') THEN
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			
			SELECT FIRST 1 NVL(Num_Operaciones, '0')::INTEGER 
			INTO viTotReg
			FROM BdiTef:"informix".Tef_Cce_Sumario
			WHERE Nombre_Arch = psNomArchivo
			AND Fecha_Presentacion = psFechaPres;

			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			
			--SELECT  LIMIT 1 SUBSTR(Fecha_Aplica,5,2)||SUBSTR(Fecha_Aplica,7,2)||SUBSTR(Fecha_Aplica,1,4)
			SELECT  FIRST 1 NVL(Fecha_Aplica,'')
			INTO vsFechaAplicacion
			FROM BdiTef:"informix".Tef_Cce_Detalle  
			WHERE Nombre_Arch = psNomArchivo
            AND Fecha_Presentacion = psFechaPres;

		ELSE
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			
			SELECT FIRST 1 NVL(Num_Operaciones, '0')::INTEGER 
			INTO viTotReg
			FROM BdiTef:"informix".Tef_Cce_Sumario_paso 
			WHERE Nombre_Arch = psNomArchivo
            AND Fecha_Presentacion = psFechaPres;
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			
			--SELECT  LIMIT 1 SUBSTR(Fecha_Aplica,5,2)||SUBSTR(Fecha_Aplica,7,2)||SUBSTR(Fecha_Aplica,1,4)
			SELECT  FIRST 1 NVL(Fecha_Aplica,'')
			INTO vsFechaAplicacion
			FROM BdiTef:"informix".Tef_Cce_Detalle_paso
			WHERE Nombre_Arch = psNomArchivo
            AND Fecha_Presentacion = psFechaPres;
			
		END IF;
		
		IF (NVL(vsFechaAplicacion,'') = '') THEN
			LET vsFechaAplicacion =  LPAD(YEAR(CURRENT),4,'0') || LPAD(MONTH(CURRENT),2,'0') ||  LPAD(DAY(CURRENT),2,'0');
		END IF;
		
		LET vdFechaAplicacion = SUBSTR(vsFechaAplicacion, 5,2)/*MES*/ || '/' || SUBSTR(vsFechaAplicacion, 7,2)/*DIA*/ || '/' || SUBSTR(vsFechaAplicacion, 1,4)/*ANO*/ ;
		
		
		IF (viTotReg IS NULL ) THEN
			LET viTotReg = 0;
		END IF;
		
		IF (NOT EXISTS(SELECT Nombre_Arch FROM BdiTef:"informix".Tef_Cce_Archivos WHERE Nombre_Arch = psNomArchivo   AND Fecha_Presentacion = psFechaPres)) THEN
			
			LET vsFechaAplicacion = NVL(psNomArchivo, '') || ' ' ||
					NVL(psFechaPres, '') ||  ' ' ||
					NVL(vdFechaAplicacion, CURRENT) ||  ' ' ||
					NVL(psCveStatus, '')  ||  ' ' ||
					NVL(viTotReg, 0)  ||  ' ' ||
					NVL(psUsuario, '');
			
			INSERT INTO BdiTef:"informix".Tef_Cce_Archivos(Nombre_Arch,Fecha_Presentacion,Fecha_Aplicacion,Cve_Status,Tot_Registros,User_Insert,Fecha_Insert)
			VALUES (
				NVL(psNomArchivo, ''),
				NVL(psFechaPres, ''),
				NVL(vdFechaAplicacion, CURRENT),
				NVL(psCveStatus, ''),
				NVL(viTotReg, 0),
				NVL(psUsuario, ''),
			CURRENT);
		ELSE
			UPDATE BdiTef:"informix".Tef_Cce_Archivos
			SET Cve_Status = NVL(psCveStatus, ''), 
			Fecha_Aplicacion = NVL(vdFechaAplicacion, CURRENT), 
			User_Insert = NVL(psUsuario, ''), 
			Tot_Registros = NVL(viTotReg, 0)
			WHERE Nombre_Arch = psNomArchivo AND Fecha_Presentacion = psFechaPres;
		END IF;
	END IF;

	RETURN vsCodRet;

END;

END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: GUARDAR REGISTRO DE LA OPERACION EN CCEARCHIVOS.',
'Fecha: 2011/03/09',
'Version: 20110309.1800',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_tef_moverarchivos(psNomArchivo CHAR(20),pRutaInicio CHAR(2), pRutaFin CHAR(2))
RETURNING CHAR(5) AS CodRet;

DEFINE	vsCodRet CHAR(5);
DEFINE	viSql_Err INTEGER;
DEFINE 	vsRutaInicio CHAR(50);
DEFINE 	vsRutaFin CHAR(50);
DEFINE 	vsSQL CHAR(120);

LET vsCodRet = '00000';
LET vsSQL = "";

--SET DEBUG FILE TO "/dbexport/TEF/trace/Sp_tef_MoverArchivos.out";
--TRACE ON;

BEGIN
ON EXCEPTION SET viSql_Err
	IF (viSql_Err <> 0) THEN
			LET vsCodRet = viSql_Err;
			RETURN vsCodRet;
	END IF;
END EXCEPTION;


	--se obtienen los parametros de rutas
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO vsRutaInicio FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = pRutaInicio;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO vsRutaFin FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = pRutaFin;

	LET vsSQL = "";
	LET vsSQL  = 'cp' || ' ' || TRIM(vsRutaInicio) || TRIM(psNomArchivo) || ' ' || TRIM(vsRutaFin) || TRIM(psNomArchivo);
	SYSTEM vsSQL;

	LET vsSQL  = 'rm -f ' || ' ' || TRIM(vsRutaInicio) || TRIM(psNomArchivo);
	SYSTEM vsSQL;

	LET vsSQL = "";
	
	RETURN vsCodRet;
	END;

END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: PROCEDIMIENTO PARA MOVER DE DIRECTORIO ARCHIVOS DE TEF.',
'Fecha: 2011/03/15',
'Version: 20110315.1520',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_tef_moverregistroshist(psNombreArchivo CHAR(20),psFecha CHAR(8), psTipo CHAR(1), psCve_Estatus CHAR(2) )
RETURNING CHAR(5) AS CodRet;

--****************************************************************************************************
-- DESCRIPCION:  ESTE PROCEDIMIENTO SE ENCARGA DE PASAR/BORRAR LOS DATOS QUE SE ENCUENTRAN EN LAS TABLAS DE PASO A LAS TABLAS MAESTRAS EN BASE AL NOMBRE DE ARCHIVO Y LA FECHA
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 27/04/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica sde Fondos
--****************************************************************************************************

--DEFINICION DE VARIABLES.
DEFINE vsCodRet CHAR(5);


--DETALLE
DEFINE vsNombre_Arch CHAR(20);
DEFINE vsFecha_Presentacion CHAR(8);
DEFINE vsTipo_Registro CHAR(2);
DEFINE vsNum_Secuencia CHAR(7);
DEFINE vsCod_Operacion CHAR(2);
DEFINE vsCod_Divisa CHAR(2);
DEFINE vsFecha_Trans CHAR(8);
DEFINE vsBanco_Presentador CHAR(3);
DEFINE vsBanco_Receptor CHAR(3);
DEFINE vsImporte CHAR(15);
DEFINE vsUso_Futuro_ccen CHAR(16);
DEFINE vsTipo_Operacion CHAR(2);
DEFINE vsFecha_Aplica CHAR(8);
DEFINE vsTipo_Cta_Ord CHAR(2);
DEFINE vsNum_Cta_Ord CHAR(20);
DEFINE vsNombre_Ord CHAR(40);
DEFINE vsRfc_Ord CHAR(18);
DEFINE vsTipo_Cta_Rec CHAR(2);
DEFINE vsNum_Cta_Rec CHAR(20);
DEFINE vsNombre_Rec CHAR(40);
DEFINE vsRfc_Rec CHAR(18);
DEFINE vsRef_Servicio CHAR(40);
DEFINE vsNombre_Titular_Serv CHAR(40);
DEFINE vsImporte_Iva CHAR(15);
DEFINE vsRef_Numerica CHAR(7);
DEFINE vsRef_Leyenda CHAR(40);
DEFINE vsClave_Rastreo CHAR(30);
DEFINE vsMotivo_Dev CHAR(2);
DEFINE vsFecha_Pres_Ini CHAR(8);
DEFINE vsSolicitud_Confirmacion CHAR(1);
DEFINE vsUso_Futuro_Banco CHAR(11);
DEFINE vsRef_Confirmacion CHAR(30);
DEFINE vsUso_Futuro_Cce CHAR(1);
DEFINE vsTasa_Tiie_Prom CHAR(7);
DEFINE vsDias_Retraso CHAR(3);
DEFINE vsImp_Tot_Int CHAR(15);
DEFINE vsCve_Estatus CHAR(2);
DEFINE vsFolio_Suc CHAR(16);
DEFINE vsUser_Insert CHAR(8);
DEFINE vdFecha_Insert DATE;


--ENCABEZADO
DEFINE vsNombre_Arch_E CHAR(20);
DEFINE vsFecha_Presentacion_E CHAR(8);
DEFINE vsTpo_Registro_E CHAR(2);
DEFINE vsNum_Secuencia_E CHAR(7);
DEFINE vsCod_Operacion_E CHAR(2);
DEFINE vsCve_Banco_E CHAR(3);
DEFINE vsSentido_E CHAR(1);
DEFINE vsServicio_E CHAR(1);
DEFINE vsNum_Bloque_E CHAR(7);
DEFINE vsCod_Divisa_E CHAR(2);
DEFINE vsCve_Rechazo_bl_E CHAR(2);
DEFINE vsModalidad_E CHAR(1);
DEFINE vsUso_Futuro_Ccen_E CHAR(41);
DEFINE vsUso_Futuro_Banco_E CHAR(370);
DEFINE vsUser_Insert_E CHAR(8);
DEFINE vdFecha_Insert_E DATE;


--SUMARIO
DEFINE vsNombre_Arch_S CHAR(20);
DEFINE vsFecha_Presentacion_S CHAR(8);
DEFINE vsTipo_Registro_S CHAR(2);
DEFINE vsNum_Secuencia_S CHAR(7);
DEFINE vsCod_Operacion_S CHAR(2);
DEFINE vsNum_Bloque_S CHAR(7);
DEFINE vsNum_Operaciones_S CHAR(7);
DEFINE vsImp_Operaciones_S CHAR(18);
DEFINE vsUso_Futuro_ccen_S CHAR(40);
DEFINE vsUso_Futuro_banco_S CHAR(364);
DEFINE vsUser_Insert_S CHAR(8);
DEFINE vdFecha_Insert_S DATE;



--BORRADO
DEFINE viTamBloque INTEGER;
DEFINE viBloque INTEGER;

--TRANSACCIONES
DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER;

DEFINE iSQLerr INTEGER;

--INICIALIZACION DE VARIABLES.
LET vsCodRet = '00000';

--DETALLE
LET vsNombre_Arch = '';
LET vsFecha_Presentacion = '';
LET vsTipo_Registro = '';
LET vsNum_Secuencia = '';
LET vsCod_Operacion = '';
LET vsCod_Divisa = '';
LET vsFecha_Trans = '';
LET vsBanco_Presentador = '';
LET vsBanco_Receptor = '';
LET vsImporte = '';
LET vsUso_Futuro_ccen = '';
LET vsTipo_Operacion = '';
LET vsFecha_Aplica = '';
LET vsTipo_Cta_Ord = '';
LET vsNum_Cta_Ord = '';
LET vsNombre_Ord = '';
LET vsRfc_Ord = '';
LET vsTipo_Cta_Rec = '';
LET vsNum_Cta_Rec = '';
LET vsNombre_Rec = '';
LET vsRfc_Rec = '';
LET vsRef_Servicio = '';
LET vsNombre_Titular_Serv = '';
LET vsImporte_Iva = '';
LET vsRef_Numerica = '';
LET vsRef_Leyenda = '';
LET vsClave_Rastreo = '';
LET vsMotivo_Dev = '';
LET vsFecha_Pres_Ini = '';
LET vsSolicitud_Confirmacion = '';
LET vsUso_Futuro_Banco = '';
LET vsRef_Confirmacion = '';
LET vsUso_Futuro_Cce = '';
LET vsTasa_Tiie_Prom = '';
LET vsDias_Retraso = '';
LET vsImp_Tot_Int = '';
LET vsCve_Estatus = '';
LET vsFolio_Suc = '';
LET vsUser_Insert = '';
LET vdFecha_Insert = CURRENT;



--ENCABEZADO
LET vsNombre_Arch_E = '';
LET vsFecha_Presentacion_E = '';
LET vsTpo_Registro_E = '';
LET vsNum_Secuencia_E = '';
LET vsCod_Operacion_E = '';
LET vsCve_Banco_E = '';
LET vsSentido_E = '';
LET vsServicio_E = '';
LET vsNum_Bloque_E = '';
LET vsCod_Divisa_E = '';
LET vsCve_Rechazo_bl_E = '';
LET vsModalidad_E = '';
LET vsUso_Futuro_Ccen_E = '';
LET vsUso_Futuro_Banco_E = '';
LET vsUser_Insert_E = '';
LET vdFecha_Insert_E = CURRENT;


--SUMARIO
LET vsNombre_Arch_S = '';
LET vsFecha_Presentacion_S = '';
LET vsTipo_Registro_S = '';
LET vsNum_Secuencia_S = '';
LET vsCod_Operacion_S = '';
LET vsNum_Bloque_S = '';
LET vsNum_Operaciones_S = '';
LET vsImp_Operaciones_S = '';
LET vsUso_Futuro_ccen_S = '';
LET vsUso_Futuro_banco_S = '';
LET vsUser_Insert_S = '';
LET vdFecha_Insert_S = CURRENT;



--BORRADO
LET viTamBloque = 30;
LET viBloque = 0;


--TRANSACCIONES
LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;

LET iSQLerr = 0;

--SET DEBUG FILE TO "/dbexport/TEF/trace/sp_tef_moverregistroshist.out";
--TRACE ON;

BEGIN
ON EXCEPTION SET iSQLerr
	IF iSQLerr <> 0 THEN
		LET vsCodRet = iSQLerr;

		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;

		RETURN vsCodRet;
	END IF;
END EXCEPTION;



	ON EXCEPTION IN (-535)
		COMMIT WORK;
	END EXCEPTION WITH RESUME;


	IF  (UPPER(psTipo) NOT IN ('T', 'B')) THEN --VALIDA QUE LOS TIPOS DE OPERACION SEAN DE SOLO TRANSFERENCIA O BORRADO
		LET vsCodRet = '01300';
	END IF;


	IF (UPPER(psTipo) = 'T') THEN --TRANSFERIR A TABLA MAESTRA


		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--OBTIENE LOS DATOS DEL REGISTRO DE ENCABEZADO
		SELECT FIRST 1 Nombre_Arch, Fecha_Presentacion, Tpo_Registro, Num_Secuencia, Cod_Operacion,
		Cve_Banco, Sentido, Servicio, Num_Bloque, Cod_Divisa, Cve_Rechazo_bl, Modalidad,
		Uso_Futuro_Ccen, Uso_Futuro_Banco, User_Insert, Fecha_Insert
		INTO vsNombre_Arch_E, vsFecha_Presentacion_E, vsTpo_Registro_E, vsNum_Secuencia_E, vsCod_Operacion_E,
		vsCve_Banco_E, vsSentido_E, vsServicio_E, vsNum_Bloque_E, vsCod_Divisa_E, vsCve_Rechazo_bl_E, vsModalidad_E,
		vsUso_Futuro_Ccen_E, vsUso_Futuro_Banco_E, vsUser_Insert_E, vdFecha_Insert_E
		FROM BdiTef:"informix".Tef_Cce_Encabezado_Paso
		WHERE Nombre_Arch = psNombreArchivo
		AND Fecha_presentacion = psFecha;


		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--OBTIENE LOS DATOS DEL REGISTRO DE SUMARIO
		SELECT FIRST 1 Nombre_Arch, Fecha_Presentacion, Tipo_Registro, Num_Secuencia,
		Cod_Operacion, Num_Bloque, Num_Operaciones, Imp_Operaciones, Uso_Futuro_ccen,
		Uso_Futuro_banco, User_Insert, Fecha_Insert
		INTO vsNombre_Arch_S, vsFecha_Presentacion_S, vsTipo_Registro_S, vsNum_Secuencia_S,
		vsCod_Operacion_S, vsNum_Bloque_S, vsNum_Operaciones_S, vsImp_Operaciones_S, vsUso_Futuro_ccen_S,
		vsUso_Futuro_banco_S, vsUser_Insert_S, vdFecha_Insert_S
		FROM BdiTef:"informix".Tef_Cce_Sumario_Paso
		WHERE Nombre_Arch = psNombreArchivo
		AND Fecha_presentacion = psFecha;


		--ENCABEZADO
		INSERT INTO BdiTef:"informix".Tef_Cce_Encabezado
		(
			Nombre_Arch,
			Fecha_Presentacion,
			Tpo_Registro,
			Num_Secuencia,
			Cod_Operacion,
			Cve_Banco,
			Sentido,
			Servicio,
			Num_Bloque,
			Cod_Divisa,
			Cve_Rechazo_bl,
			Modalidad,
			Uso_Futuro_Ccen,
			Uso_Futuro_Banco,
			User_Insert,
			Fecha_Insert
		)
		VALUES
		(
			vsNombre_Arch_E,
			vsFecha_Presentacion_E,
			vsTpo_Registro_E,
			vsNum_Secuencia_E,
			vsCod_Operacion_E,
			vsCve_Banco_E,
			vsSentido_E,
			vsServicio_E,
			vsNum_Bloque_E,
			vsCod_Divisa_E,
			vsCve_Rechazo_bl_E,
			vsModalidad_E,
			vsUso_Futuro_Ccen_E,
			vsUso_Futuro_Banco_E,
			vsUser_Insert_E,
			vdFecha_Insert_E
		);


		--SUMARIO
		INSERT INTO BdiTef:"informix".Tef_Cce_Sumario
		(
			Nombre_Arch,
			Fecha_Presentacion,
			Tipo_Registro,
			Num_Secuencia,
			Cod_Operacion,
			Num_Bloque,
			Num_Operaciones,
			Imp_Operaciones,
			Uso_Futuro_ccen,
			Uso_Futuro_banco,
			User_Insert,
			Fecha_Insert
		)
		VALUES
		(
			vsNombre_Arch_S,
			vsFecha_Presentacion_S,
			vsTipo_Registro_S,
			vsNum_Secuencia_S,
			vsCod_Operacion_S,
			vsNum_Bloque_S,
			vsNum_Operaciones_S,
			vsImp_Operaciones_S,
			vsUso_Futuro_ccen_S,
			vsUso_Futuro_banco_S,
			vsUser_Insert_S,
			vdFecha_Insert_S
		);

		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--OBTIENE LOS REGISTROS VALIDOS DEL ARCHIVO 60 PARA PROCESAR
		FOREACH WITH HOLD
		SELECT
		Nombre_Arch, Fecha_Presentacion, Tipo_Registro, Num_Secuencia, Cod_Operacion, Cod_Divisa, Fecha_Trans,
		Banco_Presentador, Banco_Receptor, Importe, Uso_Futuro_ccen, Tipo_Operacion, Fecha_Aplica, Tipo_Cta_Ord,
		Num_Cta_Ord, Nombre_Ord, Rfc_Ord, Tipo_Cta_Rec, Num_Cta_Rec, Nombre_Rec, Rfc_Rec, Ref_Servicio,
		Nombre_Titular_Serv, Importe_Iva, Ref_Numerica, Ref_Leyenda, Clave_Rastreo, Motivo_Dev, Fecha_Pres_Ini,
		Solicitud_Confirmacion, Uso_Futuro_Banco, Ref_Confirmacion, Uso_Futuro_Cce, Tasa_Tiie_Prom, Dias_Retraso,
		Imp_Tot_Int, Cve_Status, Folio_Suc, User_Insert, Fecha_Insert
		INTO
		vsNombre_Arch, vsFecha_Presentacion, vsTipo_Registro, vsNum_Secuencia, vsCod_Operacion, vsCod_Divisa, vsFecha_Trans,
		vsBanco_Presentador, vsBanco_Receptor, vsImporte, vsUso_Futuro_ccen, vsTipo_Operacion, vsFecha_Aplica, vsTipo_Cta_Ord,
		vsNum_Cta_Ord, vsNombre_Ord, vsRfc_Ord, vsTipo_Cta_Rec, vsNum_Cta_Rec, vsNombre_Rec, vsRfc_Rec, vsRef_Servicio,
		vsNombre_Titular_Serv, vsImporte_Iva, vsRef_Numerica, vsRef_Leyenda, vsClave_Rastreo, vsMotivo_Dev, vsFecha_Pres_Ini,
		vsSolicitud_Confirmacion, vsUso_Futuro_Banco, vsRef_Confirmacion, vsUso_Futuro_Cce, vsTasa_Tiie_Prom, vsDias_Retraso,
		vsImp_Tot_Int, vsCve_Estatus, vsFolio_Suc, vsUser_Insert, vdFecha_Insert
		FROM BdiTef:"informix".Tef_Cce_Detalle_Paso
		WHERE Nombre_Arch = psNombreArchivo
		AND Fecha_presentacion = psFecha

			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;

			--INSERTA EL REGISTRO EN LA TABLA MAESTRA
			INSERT INTO BdiTef:"informix".Tef_Cce_Detalle
			(
				Nombre_Arch,
				Fecha_Presentacion,
				Tipo_Registro,
				Num_Secuencia,
				Cod_Operacion,
				Cod_Divisa,
				Fecha_Trans,
				Banco_Presentador,
				Banco_Receptor,
				Importe,
				Uso_Futuro_Ccen,
				Tipo_Operacion,
				Fecha_Aplica,
				Tipo_Cta_Ord,
				Num_Cta_Ord,
				Nombre_Ord,
				Rfc_Ord,
				Tipo_Cta_Rec,
				Num_Cta_Rec,
				Nombre_Rec,
				Rfc_Rec,
				Ref_Servicio,
				Nombre_Titular_Serv,
				Importe_Iva,
				Ref_Numerica,
				Ref_Leyenda,
				Clave_Rastreo,
				Motivo_Dev,
				Fecha_Pres_Ini,
				Solicitud_Confirmacion,
				Uso_Futuro_Banco,
				Ref_Confirmacion,
				Uso_Futuro_Cce,
				Tasa_Tiie_Prom,
				Dias_Retraso,
				Imp_Tot_Int,
				Cve_Status,
				Folio_Suc,
				User_Insert,
				Fecha_Insert
			)
			VALUES
			(
				vsNombre_Arch,
				vsFecha_Presentacion,
				vsTipo_Registro,
				vsNum_Secuencia,
				vsCod_Operacion,
				vsCod_Divisa,
				vsFecha_Trans,
				vsBanco_Presentador,
				vsBanco_Receptor,
				vsImporte,
				vsUso_Futuro_Ccen,
				vsTipo_Operacion,
				vsFecha_Aplica,
				vsTipo_Cta_Ord,
				vsNum_Cta_Ord,
				vsNombre_Ord,
				vsRfc_Ord,
				vsTipo_Cta_Rec,
				vsNum_Cta_Rec,
				vsNombre_Rec,
				vsRfc_Rec,
				vsRef_Servicio,
				vsNombre_Titular_Serv,
				vsImporte_Iva,
				vsRef_Numerica,
				vsRef_Leyenda,
				vsClave_Rastreo,
				vsMotivo_Dev,
				vsFecha_Pres_Ini,
				vsSolicitud_Confirmacion,
				vsUso_Futuro_Banco,
				vsRef_Confirmacion,
				vsUso_Futuro_Cce,
				vsTasa_Tiie_Prom,
				vsDias_Retraso,
				vsImp_Tot_Int,
				DECODE (TRIM(NVL(psCve_Estatus, '')), '', vsCve_Estatus, psCve_Estatus),
				vsFolio_Suc,
				vsUser_Insert,
				vdFecha_Insert
			);

			LET viContadorRegistros = viContadorRegistros + 1;

			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;

		END FOREACH;

		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
	END IF;


	IF (UPPER(psTipo) IN ('T', 'B')) THEN --BORRAR DE TABLA DE PASO

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--OBTIENE EL NUM. DE TRANSACCIONES DEL ARCHIVO
		SELECT MAX(Num_Secuencia::INTEGER) INTO vsNum_Operaciones_S  FROM BdiTef:"informix".Tef_Cce_Detalle_Paso
		WHERE Nombre_Arch = psNombreArchivo;
		--AND Fecha_Presentacion = psFecha;

		LET viBloque = 0;

		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;

		WHILE ((viTamBloque * viBloque) < vsNum_Operaciones_S::INTEGER) --CICLO PARA BORRAR EN BLOQUES DE 30 LOS REGISTROS DEL DETALLE

			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;

			LET viBloque = viBloque + 1;

			--BORRA DETALLE
			DELETE FROM BdiTef:"informix".Tef_Cce_Detalle_Paso
			WHERE Nombre_Arch = psNombreArchivo
			--AND Fecha_Presentacion = psFecha--
			AND Num_Secuencia BETWEEN LPAD((viTamBloque * (viBloque-1)),7,'0') AND LPAD((viTamBloque * viBloque),7,'0');

			LET viContadorRegistros = viContadorRegistros + 1;

			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros = 10) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
			END IF;

		END WHILE;

		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;

		--BORRA SUMARIO
		DELETE FROM BdiTef:"informix".Tef_Cce_Sumario_Paso
		WHERE Nombre_Arch = psNombreArchivo;
		--AND Fecha_Presentacion = psFecha;--

		--BORRA ENCABEZADO
		DELETE FROM BdiTef:"informix".Tef_Cce_Encabezado_Paso
		WHERE Nombre_Arch = psNombreArchivo;
		--AND Fecha_Presentacion = psFecha;--

		LET vsCodRet = '00000';

	END IF;

RETURN vsCodRet;

END
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: ESTE PROCEDIMIENTO SE ENCARGA DE PASAR/BORRAR LOS DATOS QUE SE ENCUENTRAN EN LAS TABLAS DE PASO A LAS TABLAS MAESTRAS EN BASE AL NOMBRE DE ARCHIVO Y LA FECHA.',
'Fecha: 2011/04/27',
'Version: 20110427.1221',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_tef_presentador_g(psNombreArchivo CHAR(20), psNumEmpleado CHAR (8))

RETURNING CHAR (20) AS Nom_Archivo, CHAR (5) AS Codigo_Respuesta, CHAR (100) AS Mensaje_Respuesta;

--****************************************************************************************************
-- DESCRIPCION:  SP PRINCIPAL DE TEF -- PRESENTADOR GENERADOR ARCH. 10 Y 60
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 08/03/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************

--DEFINICION DE VARIABLES.
DEFINE vsFlagTipoProceso 		CHAR(1);
DEFINE vsNomProceso 			CHAR(20);
DEFINE vsDescripcionProceso 	CHAR(60);
DEFINE sGENERANDO 				CHAR(1);
DEFINE sFINALIZADO				CHAR(1);
DEFINE sERROR 					CHAR(1);
DEFINE visqlerr 				INTEGER;
DEFINE vsNomArchivo 			CHAR(20);
DEFINE vsFechaPresentacion 		CHAR(8);
DEFINE vsFechaPresentacion1		CHAR(8);
DEFINE vsCodRetorno 			CHAR(5);
DEFINE vsCodRetorno2 			CHAR(5);
DEFINE vsCodRetorno3 			CHAR(5);
DEFINE vdtFecha 				DATE;
DEFINE vdtFechaInsert 			DATE;
DEFINE vsMensajeRespuesta 		CHAR (100);
DEFINE viContador 				INTEGER;
DEFINE viTipoArchivo 			INTEGER;
DEFINE vsDia 					CHAR(2);
DEFINE vsMes 					CHAR(2);
DEFINE vsAno 					CHAR(4);
DEFINE vsSpLlamado 				CHAR(24);
DEFINE vsCveBanc 				CHAR(3);

--INICIALIZACION DE VARIABLES.
LET vsFlagTipoProceso			= '';
LET vsNomProceso				= '';
LET vsDescripcionProceso		= '';
LET sGENERANDO					= '0';
LET sFINALIZADO					= '1';
LET sERROR						= '3';
LET visqlerr					= 0;
LET vsNomArchivo				= '';
LET vsFechaPresentacion			= '';
LET vsFechaPresentacion1		= '';
LET vsCodRetorno				= '';
LET vsCodRetorno2				= '';
LET vsCodRetorno3				= '';
LET vdtFecha					= CURRENT::DATE;
LET vdtFechaInsert				= CURRENT::DATE;
LET vsMensajeRespuesta			= '';
LET viContador					= 0;
LET viTipoArchivo				= 0;
LET vsDia						= '';
LET vsMes						= '';
LET vsAno						= '';
LET vsSpLlamado					= '';
LET vsCveBanc					= '';

--SET DEBUG FILE TO "/tmp/TEF/respuesta/sp_Tef_Presentador_G.sql";
--TRACE ON;

BEGIN
ON EXCEPTION SET visqlerr --Control de errores.
	EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
	sERROR, visqlerr, psNumEmpleado, 'ERROR NO CONTROLADO', TRIM(vsNomArchivo), vsFechaPresentacion, '11') INTO vsCodRetorno;
	LET vsMensajeRespuesta = 'ERROR NO CONTROLADO(' || visqlerr || ') ARCHIVO: ' || TRIM(vsNomArchivo) || ' PROCESO: ' || TRIM(vsDescripcionProceso) ;
	RETURN  vsNomArchivo, visqlerr, vsMensajeRespuesta;
END EXCEPTION;



	LET vsDescripcionProceso = 'Validacion de numero de empleado.';
	EXECUTE PROCEDURE BdiTef:"informix".Sp_Valida_Cadena(TRIM(psNumEmpleado),'N') INTO vsCodRetorno;

	LET vsDescripcionProceso = 'Validacion de parametros.';
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	IF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '71') THEN -- Valida que exista el parametro RUTA ARCHIVO PROCESAR.
		LET vsCodRetorno = '00100';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '72') THEN -- Valida que exista el parametro RUTA ARCHIVO RESPUESTA.
		LET vsCodRetorno = '00101';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '73') THEN -- Valida que exista el parametro RUTA ARCHIVOS PROCESADOS.
		LET vsCodRetorno = '00102';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '74') THEN -- Valida que exista el parametro RUTA ARCHIVOS ERRONEOS.
		LET vsCodRetorno = '00103';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '75') THEN -- Valida que exista el parametro CLAVE BANCARIA BANCOPPEL.
		LET vsCodRetorno = '00104';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '76') THEN -- Valida que exista el parametro BIN CORRESPONDIENTE TARJETA DEBITO.
		LET vsCodRetorno = '00105';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '77') THEN -- Valida que exista el parametro SUCURSAL CONTABLE TEF.
		LET vsCodRetorno = '00106';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '78') THEN -- Valida que exista el parametro TRANSACCION DE CARGO POR TEF.
		LET vsCodRetorno = '00107';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '79') THEN -- Valida que exista el parametro TRANSACCION DE ABONO.
		LET vsCodRetorno = '00108';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '80') THEN -- Valida que exista el parametro IMPORTE MAXIMO CECOBAN.
		LET vsCodRetorno = '00109';
	ELIF(NOT EXISTS (SELECT Cve_Producto FROM BdiTef:"informix".Tef_Prod_Permitidos WHERE Cve_Producto <> '') ) THEN--Valida que existan PRODUCTOS PERMITIDOS PARA TEF.
	--ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '82') THEN -- Valida que exista el parametro PRODUCTOS PERMITIDOS PARA TEF.
		LET vsCodRetorno = '00111';
	ELIF NOT EXISTS (SELECT Fecha_Hoy FROM BdiCheq:"informix".Sc_Fechas) THEN -- Valida que exista el parametro de la fecha actual.
		LET vsCodRetorno = '00113';
	ELIF (TRIM(psNumEmpleado) = '') THEN --NUMERO DE EMPLEADO VACIO.
		LET vsCodRetorno = '00114';
	ELIF (LENGTH(TRIM(psNumEmpleado)) < 8 ) THEN --NUMERO DE EMPLEADO NO CONTIENE LOS 8 DIGITOS REQUERIDOS.
		LET vsCodRetorno = '00115';
	ELIF (vsCodRetorno <> '00000') THEN --ERROR EL NUMERO DE EMPLEADO CONTIENE  CARACTERES INVALIDOS.
		LET vsCodRetorno = '00116';
	ELIF NOT EXISTS(SELECT Ejecutivo FROM BdInteg:"informix".Si_Ejecut WHERE Ejecutivo = psNumEmpleado) THEN --EL NUM EMPLEADO NO EXISTE EN SI_EJECUT
		LET vsCodRetorno = '00117';
	ELSE
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--Se obtiene la fecha del dia actual.
		SELECT LIMIT 1 Fecha_Hoy INTO vdtFecha FROM BdiCheq:"informix".Sc_Fechas;
		--Valida que la fecha actual sea dia laboral.
		EXECUTE PROCEDURE BdiTef:"informix".Sp_Valida_Fecha(LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0')) INTO vsCodRetorno;
			--Valida si el codigo de retorno es diferente a '00000' el dia es no laboral.
			IF(vsCodRetorno <> '00000') THEN
				--El dia no es laboral.
				LET vsCodRetorno = '00112';
			ELSE --DIA LABORAL.
				LET vsCodRetorno = '00000';
			END IF;
	END IF;

	--Valida si todos los parametros existen y si la fecha con la que se generaran los archivos corresponde a un dia habil.
	IF(vsCodRetorno = '00000')THEN
		--Se inicializa contador en cero para realizar procedimiento automatico archivo 60 tambien se marca con 'A' de automatico el tipoflag.
		LET viContador = 0;
		LET vsFlagTipoProceso = 'A';
		--Se guarda en variable la clave bancaria correspondiente con la que se generaran archivos.
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT valor INTO vsCveBanc FROM BdiTef:"informix".Tef_Parametros  WHERE cod_param = '75';
		--Mientras el contador sea menor a 1 y el flagproceso sea 'A' automatico.
		WHILE ((viContador < 1) AND (vsFlagTipoProceso = 'A'))  -- Archivos 10 y 60
			
			LET vsCodRetorno = '00000';
			LET vsCodRetorno3 = '00000';
			
			LET vsDescripcionProceso = 'Obtencion de nombre de archivo';
			--Valida que el nombre del archivo se recibe en blanco.
			IF(TRIM(psNombreArchivo) = '') THEN
				--Se arma la fecha dia mes y año para el armado completo del nombre de archivo.
				LET vsDia = LPAD (DAY(vdtFecha), 2, '0');
				LET vsMes = LPAD (MONTH(vdtFecha), 2, '0');
				LET vsAno = LPAD (YEAR(vdtFecha), 4, '0');
				LET vsFechaPresentacion = vsAno || vsMes || vsDia;
				LET viTipoArchivo = 60;
				--Ebbbddmmyyyy.oocc
				-- Se asigna a variable el nombre completo del archivo.
				LET vsNomArchivo = 'E' --CONSTANTE
									|| TRIM(vsCveBanc)--CONSTANTE
									|| vsDia
									|| vsMes
									|| vsAno
									|| '.' --CONSTANTE
									|| viTipoArchivo::CHAR(2)
									|| '01'; --SECUENCIA DEL ARCHIVO 01 PARA AUTOMATICO
			ELIF(TRIM(psNombreArchivo) <> '')THEN
				--Se marca el proceso como manual.
				LET vsFlagTipoProceso = 'M';
				LET vsNomArchivo = psNombreArchivo;
				LET vsDia = LPAD (DAY(vdtFecha), 2, '0');
				LET vsMes = LPAD (MONTH(vdtFecha), 2, '0');
				LET vsAno = LPAD (YEAR(vdtFecha), 4, '0');
				LET vsFechaPresentacion = vsAno || vsMes || vsDia;
				IF( SUBSTRING (TRIM(vsNomArchivo) FROM 14 FOR 2) = '60' ) THEN --ARCHIVO 60
					LET viTipoArchivo = 60;
				--Archivo no valido.
				ELSE
					LET viTipoArchivo = 0;
				END IF;
			END IF;
			
			--VALIDA QUE EL NOMBRE DEL ARCHIVO POSEA LA EXTENSION ADECUADA.
			IF (LENGTH (TRIM(vsNomArchivo)) = 17 )THEN
					LET vsNomProceso = 'GENARCH_' || LPAD (viTipoArchivo, 2, '0') || '.' || SUBSTRING (TRIM(vsNomArchivo) FROM 16 FOR 2);
			ELSE --ERROR DE LONGITUD DEL ARCHIVO ARCHIVO NO RECONOCIDO.
					LET vsNomProceso = 'GENARCH_' || LPAD (viTipoArchivo, 2, '0') || '.' || '00';
			END IF ;

			LET vsDescripcionProceso = 'Validacion nombre archivo.';
			--Valida la integridad del nombre de archivo.
			EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_ValidarNombreArchivos(viTipoArchivo, 'E', vsNomArchivo) INTO vsCodRetorno;
			
			--Valida si el nombre del archivo fue integro.
			IF(vsCodRetorno = '00000')THEN
				LET vsDescripcionProceso = 'Validacion de generaciones previas.';
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				IF EXISTS(SELECT descripcion FROM BdiTef:"informix".Tef_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sFINALIZADO ) THEN  --EL ARCHIVO FUE GENERADO PREVIAMENTE
					LET vsCodRetorno3 = vsCodRetorno;
					LET vsCodRetorno = '00118';
					EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensajeRespuesta;
					INSERT INTO BdiTef:"informix".Tef_Errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
					VALUES (CURRENT, CURRENT HOUR TO FRACTION, vsCodRetorno, vsNomArchivo, 'sp_Tef_Presentador_G', vsMensajeRespuesta, psNumEmpleado, CURRENT);
				ELIF EXISTS(SELECT descripcion FROM BdiTef:"informix".Tef_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sGENERANDO ) THEN  --EL ARCHIVO SE ENCUENTRA GENERANDO
					LET vsCodRetorno3 = vsCodRetorno;
					LET vsCodRetorno = '00119';
					EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensajeRespuesta;
					INSERT INTO BdiTef:"informix".Tef_Errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
					VALUES (CURRENT, CURRENT HOUR TO FRACTION, vsCodRetorno, vsNomArchivo, 'sp_Tef_Presentador_G', vsMensajeRespuesta, psNumEmpleado, CURRENT);
				ELIF NOT EXISTS(SELECT descripcion FROM BdiTef:"informix".Tef_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sERROR ) THEN  --EL ARCHIVO FUE GENERADO CON ERROR
					--Crea registro de generacion de archivo.
					LET vsDescripcionProceso = 'Registro de generacion del archivo.';
					EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
					sGENERANDO, vsCodRetorno, psNumEmpleado, 'sp_Tef_Presentador_G', TRIM(vsNomArchivo), vsFechaPresentacion, '11') INTO vsCodRetorno2;
					LET vsCodRetorno = '00000';
				ELSE
					LET vsDescripcionProceso = 'Registro de regeneracion del archivo.';
					EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
					sGENERANDO, vsCodRetorno, psNumEmpleado, 'sp_Tef_Presentador_G', TRIM(vsNomArchivo) , vsFechaPresentacion, '11' ) INTO vsCodRetorno2;
					LET vsCodRetorno = '00000';
				END IF;
					IF(vsCodRetorno = '00000')THEN
						LET vsDescripcionProceso = 'Borrado de tablas de paso.';
						--Limpia las tablas de paso para generar el nuevo archivo.
						EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist (TRIM (vsNomArchivo), '', 'B', '') INTO vsCodRetorno;
						--Valida que las tablas se limpiaron correctamente.
						IF(vsCodRetorno = '00000')THEN
							LET vsDescripcionProceso = 'Generar informacion a tablas de paso.';
							--IF(viTipoArchivo = 10)THEN
								--EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_GenerarArchivo10(vsNomArchivo, psNumEmpleado) INTO vsCodRetorno;
								--LET vsSpLlamado = 'Sp_Tef_GenerarArchivo10';
							IF(viTipoArchivo = 60)THEN
								EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_GenerarArchivo60(vsNomArchivo, psNumEmpleado) INTO vsCodRetorno;
								LET vsSpLlamado = 'Sp_Tef_GenerarArchivo60';
							END IF;
							--Valida que se genero la informacion correctamente.
							IF(vsCodRetorno = '00000') THEN
								LET vsDescripcionProceso = 'Verificar existencia de registros.';
								IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_Cce_Encabezado_Paso WHERE nombre_arch = TRIM(vsNomArchivo))THEN
									IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_Cce_Detalle_Paso WHERE nombre_arch = TRIM(vsNomArchivo))THEN
										IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_Cce_Sumario_Paso WHERE nombre_arch = TRIM(vsNomArchivo))THEN
											LET vsDescripcionProceso = 'Descargar archivo a repositorio.';
											SET LOCK MODE TO WAIT 3;
											SET ISOLATION TO DIRTY READ;
											SELECT Fecha_Presentacion INTO vsFechaPresentacion1 FROM BdiTef:"informix".Tef_Cce_Encabezado_Paso WHERE nombre_arch = TRIM(vsNomArchivo) ;
											EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_GeneraArchivo(60, vsNomArchivo, vsFechaPresentacion1, '72') INTO vsCodRetorno;
											--Verifica si se genero el archivo correctamente.
											IF (vsCodRetorno = '00000')THEN
												LET vsDescripcionProceso = 'Guardar en ccearchivos.';
												EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_GuardarCCEArchivos (psNumEmpleado, TRIM (vsNomArchivo), vsFechaPresentacion, '01') INTO vsCodRetorno;
												--Verifica si guardo en ccearchivos correctamente.
												IF (vsCodRetorno = '00000')THEN
													--Verifica si es un archivo 60 el que se genero, en ese caso se actualiza la tabla cte detalle.
													LET vsDescripcionProceso = 'Guardar historico.';
													--EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist (TRIM (vsNomArchivo), vsFechaPresentacion1, 'T', '02') INTO vsCodRetorno;
													EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist (TRIM (vsNomArchivo), vsFechaPresentacion1, 'T', '01') INTO vsCodRetorno;
													--Vallida que se paso informacion a historico correctamente.
													IF (vsCodRetorno = '00000')THEN
														--Guarda bitacora exito.
														LET vsDescripcionProceso = 'Generacion de archivo exitosa.';
														EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
														sFINALIZADO, vsCodRetorno, psNumEmpleado, 'sp_Tef_Presentador_G', TRIM(vsNomArchivo) , vsFechaPresentacion, '02') INTO vsCodRetorno2;
														--sFINALIZADO, vsCodRetorno, psNumEmpleado, 'sp_Tef_Presentador_G', TRIM(vsNomArchivo) , vsFechaPresentacion, '01') INTO vsCodRetorno2;
													--Error al guardar informacion a tablas historico.
													ELSE														
														EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
														sERROR, vsCodRetorno, psNumEmpleado, 'sp_Tef_MoverRegistrosHist', TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
														LET vsCodRetorno3 = vsCodRetorno;
														LET vsCodRetorno = '00129';
													END IF;
												--Error al descargar archivo a repositorio.
												ELSE
													
													EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
													sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Tef_GuardarCCEArchivos', TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
													LET vsCodRetorno3 = vsCodRetorno;
													LET vsCodRetorno = '00128';
												END IF;
											ELSE
												
												EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
												sERROR, vsCodRetorno, psNumEmpleado, 'sp_Tef_GeneraArchivo', TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
												LET vsCodRetorno3 = vsCodRetorno;
												LET vsCodRetorno = '00127';
											END IF;
										--No se puede descargar el archivo por que no existen registros para el nombre de archivo indicado en tabla sumario.
										ELSE
											
											EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
											sERROR, vsCodRetorno, psNumEmpleado, '', TRIM(vsNomArchivo) , vsFechaPresentacion, '11' ) INTO vsCodRetorno2;
											LET vsCodRetorno3 = vsCodRetorno;
											LET vsCodRetorno = '00126';
										END IF;
									--No se puede descargar el archivo por que no existen registros para el nombre de archivo indicado en tabla detalle.
									ELSE
										
										EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
										sERROR, vsCodRetorno, psNumEmpleado, '', TRIM(vsNomArchivo) , vsFechaPresentacion, '11' ) INTO vsCodRetorno2;
										LET vsCodRetorno3 = vsCodRetorno;
										LET vsCodRetorno = '00125';
									END IF;
								--No se puede descargar el archivo por que no existen registros para el nombre de archivo indicado en tabla encabezado.
								ELSE
									
									EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
									sERROR, vsCodRetorno, psNumEmpleado, '', TRIM(vsNomArchivo) , vsFechaPresentacion, '11' ) INTO vsCodRetorno2;
									LET vsCodRetorno3 = vsCodRetorno;
									LET vsCodRetorno = '00124';
								END IF;
							--Error al generar informacion a tablas de paso.
							ELSE
								EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
								sERROR, vsCodRetorno, psNumEmpleado, vsSpLlamado, TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
								
								LET vsCodRetorno3 = vsCodRetorno;
								LET vsCodRetorno = '00123';
							END IF;
						--Error al limpiar las tablas de paso.
						ELSE
							
							EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
							sERROR, vsCodRetorno, psNumEmpleado, 'sp_Tef_MoverRegistrosHist', TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
							
							LET vsCodRetorno3 = vsCodRetorno;
							LET vsCodRetorno = '00122';
						END IF;
					--El archivo ya fue generado previamente o el archivo se encuentra generando.
					END IF;
			--Error al validar la integridad del nombre del archivo.
			ELSE
				
				EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
				sERROR, vsCodRetorno, psNumEmpleado, 'sp_Tef_ValidarNombreArchivos', TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
				LET vsCodRetorno3 = vsCodRetorno;
				LET vsCodRetorno = '00121';
			END IF;
			
			IF EXISTS(SELECT descripcion FROM BdiTef:"informix".Tef_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sGENERANDO ) THEN  --EL ARCHIVO SE ENCUENTRA GENERANDO
				IF(vsCodRetorno <> '00119') THEN --VALIDA SI EL ERROR ES DISTINTO DE 'GENERANDO'
					UPDATE BdiTef:"informix".Tef_Procesos SET Estatus = sERROR WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sGENERANDO ;
				END IF;
			END IF;
			
			EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensajeRespuesta;
			RETURN vsNomArchivo, vsCodRetorno, (TRIM(vsMensajeRespuesta) || DECODE (vsCodRetorno3, '00000', '', ' (' || vsCodRetorno3 || ')') ) WITH RESUME;
			LET viContador = viCOntador + 1;
			
		END WHILE;
	--Error en la validacion de parametros.
	ELSE
		LET vsCodRetorno = vsCodRetorno;
		EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensajeRespuesta;
		RETURN 'GENERAL', vsCodRetorno, vsMensajeRespuesta;
	END IF;

END

END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: SP PRINCIPAL DE TEF -- PRESENTADOR GENERADOR ARCH. 60.',
'Fecha: 2011/03/08',
'Version: 20110608.1145',
'BD: BdiTef',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: SE MODIFICO LA VALIDACION DE TAMANO DEL NOMBRE DE ARCHIVO DE 16 A 17 CARACTERES.',
'Fecha: 2011/06/29',
'Version: 20110629.1226',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_tef_presentador_r ( psNomArchivo CHAR(20), psNumEmpleado CHAR (8))

RETURNING CHAR (20) AS Nom_Archivo, CHAR (5) AS Codigo_Respuesta, CHAR (100) AS Mensaje_Respuesta;

--****************************************************************************************************
-- DESCRIPCION:  SP PRINCIPAL DE TEF -- PRESENTADOR RECEPTOR ARCH.  61, 62 Y 63
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 10/03/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE sPROCESANDO CHAR(1);
DEFINE sERROR CHAR(1);
DEFINE sFINALIZADO CHAR(1);
DEFINE vsDescripcionProceso CHAR (60);
DEFINE vsFlagTipoProceso CHAR (1);
DEFINE viTipoArchivo SMALLINT ;
DEFINE vsFlagUnico CHAR (1);
DEFINE vsBloque CHAR (2);
DEFINE vsFecha_Presentacion CHAR (8);
DEFINE vSFecha_aplica CHAR(8);
DEFINE vdFecha_aplicaDe DATE;
DEFINE vsMensaje CHAR (80) ;
DEFINE vsRuta CHAR (100);

DEFINE vsDia CHAR(2);

DEFINE vsCodRetorno CHAR (5);
DEFINE vsCodRetorno2 CHAR (5);
DEFINE vsCodRetorno3 CHAR (5);
DEFINE vsMensaje_Respuesta CHAR (100);
DEFINE vsCveBanc CHAR (100);
DEFINE vsNomArchivo CHAR (20);
DEFINE vsNomArchivo11 CHAR (20);
DEFINE vsNomArchivo61 CHAR (20);
DEFINE vsNomArchivo62 CHAR (20);
DEFINE viContador INTEGER;
DEFINE vdtFecha DATE;
DEFINE visqlerr INTEGER ;

DEFINE vsNomProceso CHAR (20);
DEFINE vsEstatusTemp CHAR(1);


/* INICIALIZACION DE VARIABLES */
--VARIABLES DE MONITOR
LET sPROCESANDO = '0';
LET sFINALIZADO = '1';
LET sERROR = '3';
LET vsDescripcionProceso = '';
LET vsFlagTipoProceso = '';
LET viTipoArchivo = 0;
LET vsFlagUnico = 'F';
LET vsBloque = '00';
LET vsFecha_Presentacion = '';
LET vSFecha_aplica = '';
LET vsMensaje = '';
LET vsRuta = '';

LET vsCodRetorno = '';
LET vsCodRetorno2 = '';
LET vsCodRetorno3 = '';
LET vsMensaje_Respuesta = '';
LET vsCveBanc = '';
LET vsNomArchivo = '';
LET vsNomArchivo11 = '';
LET vsNomArchivo61 = '';
LET vsNomArchivo62 = '';
LET viContador = 0;
LET vdtFecha = CURRENT::DATE;
LET vdFecha_aplicaDe = CURRENT::DATE;

LET vsDia = '';

LET vsNomProceso = '';
LET vsEstatusTemp = '';

LET visqlerr = 0;

--SET DEBUG FILE TO "/tmp/TEF/procesar/sp_Tef_Presentador_R.out";
--TRACE ON;
BEGIN

ON EXCEPTION SET visqlerr   --CONTROL DE ERRORES
 
	EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomArchivo), vsDescripcionProceso, 
	sERROR, visqlerr, psNumEmpleado, 'ERROR NO CONTROLADO', TRIM(vsNomArchivo), vsFecha_Presentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
	
	LET vsMensaje_Respuesta = 'ERROR NO CONTROLADO(' || visqlerr || ') ARCHIVO: ' || TRIM(vsNomArchivo) || 'PROCESO: ' || TRIM(vsDescripcionProceso) ;
	
	RETURN vsNomArchivo, visqlerr, vsMensaje_Respuesta ;
	
END EXCEPTION;
	

	
	LET vsDescripcionProceso = 'Validacion de numero de empleado.';
	EXECUTE PROCEDURE BdiTef:"informix".Sp_Valida_Cadena(TRIM(psNumEmpleado),'N') INTO vsCodRetorno;
	
	LET vsDescripcionProceso = 'Validacion de parametros.';
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	IF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '71') THEN -- Valida que exista el parametro RUTA ARCHIVO PROCESAR
		LET vsCodRetorno = '00201';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '72') THEN -- Valida que exista el parametro RUTA ARCHIVO RESPUESTA
		LET vsCodRetorno = '00202';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '73') THEN -- Valida que exista el parametro RUTA ARCHIVOS PROCESADOS
		LET vsCodRetorno = '00203';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '74') THEN -- Valida que exista el parametro RUTA ARCHIVOS ERRONEOS
		LET vsCodRetorno = '00204';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '75') THEN -- Valida que exista el parametro CLAVE BANCARIA BANCOPPEL
		LET vsCodRetorno = '00205';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '76') THEN -- Valida que exista el parametro BIN CORRESPONDIENTE TARJETA DEBITO
		LET vsCodRetorno = '10106';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '77') THEN -- Valida que exista el parametro SUCURSAL CONTABLE TEF
		LET vsCodRetorno = '00207';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '78') THEN -- Valida que exista el parametro TRANSACCION DE CARGO POR TEF
		LET vsCodRetorno = '00208';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '79') THEN -- Valida que exista el parametro TRANSACCION DE ABONO
		LET vsCodRetorno = '00209';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '80') THEN -- Valida que exista el parametro IMPORTE MAXIMO CECOBAN
		LET vsCodRetorno = '00210';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '72') THEN -- Valida que exista el parametro PRODUCTOS PERMITIDOS PARA TEF
		LET vsCodRetorno = '00212';
	ELIF NOT EXISTS (SELECT Fecha_Hoy FROM BdiCheq:"informix".Sc_Fechas) THEN -- Valida que exista el parametro de la fecha actual.
		LET vsCodRetorno = '00214';
	ELIF (TRIM(psNumEmpleado) = '') THEN --NUMERO DE EMPRLEADO VACIO
		LET vsCodRetorno = '00215';
	ELIF (LENGTH(TRIM(psNumEmpleado)) < 8 ) THEN --NUMERO DE EMPLEADO NO CONTIENE LOS 8 DIGITOS REQUERIDOS
		LET vsCodRetorno = '00216';
	ELIF (vsCodRetorno <> '00000') THEN --ERROR EL NUMERO DE EMPLEADO CONTIENE  CARACTERES INVALIDOS
		LET vsCodRetorno = '00217';
	ELIF NOT EXISTS (SELECT Ejecutivo FROM BdInteg:Si_Ejecut WHERE Ejecutivo = TRIM(psNumEmpleado)) THEN -- Valida que exista el empleado en al si_ejecut
		LET vsCodRetorno = '00162';
	ELSE --TODO LOS PARAMETROS EXISTEN
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT LIMIT 1 Fecha_Hoy INTO vdtFecha FROM BdiCheq:"informix".Sc_Fechas; 
		
		SELECT LIMIT 1 TRIM(valor) INTO vsCveBanc FROM BdiTef:"informix". Tef_Parametros WHERE cod_param = '75';
		
		EXECUTE PROCEDURE BdiTef:"informix".Sp_Valida_Fecha(LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0')) INTO vsCodRetorno;
		
		LET vsFecha_Presentacion = LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0');
		
		IF (vsCodRetorno <> '00000') THEN --DIA NO LABORAL
			LET vsCodRetorno = '00213';
		ELSE --DIA LABORAL
			LET vsCodRetorno = '00000';
		END IF;
		
	END IF;
	
	IF (vsCodRetorno = '00000') THEN --TODO LOS PARAMETROS EXISTEN

		LET viContador = 0;
		LET vsFlagTipoProceso = 'A';
		
		WHILE ((viContador < 3) AND (vsFlagTipoProceso = 'A'))  --VERIFICA LA EXISTENCIA DE LOS 2 TIPOS DE ARCHIVO A PROCESAR
			
			LET vsCodRetorno = '00000';
			LET vsCodRetorno3 = '00000';
			
			LET vsDescripcionProceso = 'Obtencion de nombre de Archivo';
			LET vsNomProceso = '';
			LET viContador = viContador + 1;
			
			IF (TRIM(psNomArchivo) = '') THEN --Valida si es una corrida Automatica. --SIN NOMBRE DE ARCHIVO
				--OBTIENE EL NOPMBRE DEL ARCHIVO ESPERADO
				
				LET vsFlagTipoProceso = 'A'; --AUTOMATICO
				
				
				IF (viContador = 1) THEN -- ARCHIVO 61
					LET viTipoArchivo = 61;
				ELIF (viContador = 2) THEN -- ARCHIVO 62
					LET viTipoArchivo = 62;
				ELIF (viContador = 3) THEN -- ARCHIVO 63
					LET viTipoArchivo = 63;
				ELSE --NINGUN TIPO DEFINIDO
					LET viTipoArchivo = 0;
				END IF;
					
				LET vsDia = LPAD (DAY(vdtFecha), 2, '0');
				
				-- Se asigna a variable el nombre completo del archivo.
				LET vsNomArchivo = 'S' --CONSTANTE
								|| '01' --PLAZA DE LA CÁMARA DE COMPENSACIÓN ELECTRÓNICA NACIONAL.
								|| TRIM(vsCveBanc)--BANCOPEL ID
								|| 'A' --CARÁCTER QUE IDENTIFICA EL BUZÓN (CONSTANTE)
								|| '2' --SERVICIO TEF  [2 . TRANSFERENCIA ELECTRÓNICA DE FONDOS]
								|| '.' --CONSTANTE
								|| 'A' -- TIPO DE ARCHIVO [A o H]
								|| viTipoArchivo::CHAR(2) --TIPO DE ARCHIVO  [60]
								|| vsDia --DIA DE PROCESO
								|| '98'; 
						
			ELSE -- Corrida Manual.  -- INDICA EL NOMBRE DEL ARCHIVO.
				
				LET vsFlagTipoProceso = 'M'; --MANUAL
				
				IF ( SUBSTRING (TRIM(psNomArchivo) FROM 11 FOR 2) = '61' ) THEN --ARCHIVO 61
					LET viTipoArchivo = 61;
				ELIF ( SUBSTRING (TRIM(psNomArchivo) FROM 11 FOR 2) = '62' ) THEN --ARCHIVO 62
					LET viTipoArchivo = 62;
				ELIF ( SUBSTRING (TRIM(psNomArchivo) FROM 11 FOR 2) = '63' ) THEN --ARCHIVO 63
					LET viTipoArchivo = 63;
				ELSE --ARCHIVO NO VALIDO
					LET viTipoArchivo = 0;
				END IF;
					
				LET vsNomArchivo = TRIM(psNomArchivo);
				
			END IF;
			
			IF (LENGTH (TRIM(psNomArchivo)) = 16) THEN --VALIDA EL EL NOMBRE DEL ARCHIVO POSEA LA EXTENCION ADECUADA
				LET vsNomProceso = 'RECARCH_' || LPAD (viTipoArchivo, 2, '0') || '.' || SUBSTRING (TRIM(psNomArchivo) FROM 15 FOR 2);
			ELSE -- ERROR DE LONGITUD DE NOMBRE DE ARCHIVO, ARCHIVO NO RECONOCIDO
				LET vsNomProceso = 'RECARCH_' || LPAD (viTipoArchivo, 2, '0') || '.' || '00';
			END IF ;
			
			LET vsDescripcionProceso = 'Validacion de nombre de archivo';
			--VALIDA LA INTEGRIDAD DEL NOMBRE DEL ARCHIVO
			EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_ValidarNombreArchivos( viTipoArchivo, 'S', vsNomArchivo) INTO vsCodRetorno;
			
			IF (vsCodRetorno = '00000') THEN --NOMBRE DE ARCHIVO OK
			
				LET vsDescripcionProceso = 'Validacion de procesamientos previos.';
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				IF EXISTS(SELECT Cve_Proceso FROM BdiTef:"informix".Tef_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) ) THEN  --VALIDA SI EXISTE EL REGISTRO DE LA OPERACION
					
					SELECT LIMIT 1 Estatus INTO vsEstatusTemp FROM BdiTef:"informix".Tef_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso);
					
					IF (vsEstatusTemp = sFINALIZADO) THEN --EL ARCHIVO FUE PROCESADO PREVIAMENTE
						LET vsCodRetorno = '00219';
						EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;
					
						INSERT INTO BdiTef:"informix".Tef_Errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
						VALUES (CURRENT, CURRENT HOUR TO FRACTION, vsCodRetorno, vsNomArchivo, 'sp_tef_presentador_r', vsMensaje_Respuesta, psNumEmpleado, CURRENT);
						
					ELIF (vsEstatusTemp = sPROCESANDO) THEN --EL ARCHIVO SE ENCUENTRA PROCESANDO
						LET vsCodRetorno = '00220';
						
						EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;
					
						INSERT INTO BdiTef:"informix".Tef_Errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
						VALUES (CURRENT, CURRENT HOUR TO FRACTION, vsCodRetorno, vsNomArchivo, 'sp_tef_presentador_r', vsMensaje_Respuesta, psNumEmpleado, CURRENT);
						
					ELIF (vsEstatusTemp = sERROR) THEN --EL ARCHIVOFUE PROCESADO CON ERROR 
						--CREA REGISTRO DEL PROCESO DEL ARCHIVO
						LET vsDescripcionProceso = 'Registro de Reproceso del Archivo.';
						
						EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
						sPROCESANDO, vsCodRetorno, psNumEmpleado, 'sp_tef_presentador_r', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
					END IF;
				
				ELSE --EL REGISTRO NO EXISTE
					--CREA REGISTRO DEL PROCESO DEL ARCHIVO
					LET vsDescripcionProceso = 'Registro de Procesamiento del Archivo.';
					
					EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
					sPROCESANDO, vsCodRetorno, psNumEmpleado, 'sp_tef_presentador_r', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/*NO GUARDAR CCE_ARCHIVO*/) INTO vsCodRetorno2;
					
				END IF;
				
				IF (vsCodRetorno = '00000') THEN -- VALIDA SI EL ARCHIVO ES APTO ´PARA SER PROCESADO
				
					LET vsDescripcionProceso = 'Borrado de tablas de paso';
					--LIMPIA LAS TABLAS DE PARA PROCESAR EL NUEVOA ARCHIVO
					EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist (TRIM (vsNomArchivo), '', 'B', '') INTO vsCodRetorno;
					
					IF (vsCodRetorno = '00000') THEN -- VALIDA KE LAS TABLAS SE LIMPIARON CORRECTAMENTE 
					
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
						SELECT LIMIT 1 Valor INTO vsRuta FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '71'; -- RUTA ARCHIVO PROCESAR
						
						--VALIDA QUE EL ARCHIVO EXISTA EN EL REPOSITORIO DE PROCESO
						EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_BuscarArchivo( TRIM(vsRuta), TRIM(vsNomArchivo)) INTO vsCodRetorno, vsFlagUnico;
						
						IF ((vsCodRetorno = '00000') AND (vsFlagUnico = 'V')) THEN --VALIDA QUE EXISTA EL ARCHIVO EN EL REPOSITORIO
						
							LET vsDescripcionProceso = 'Carga del archivo a las tablas de paso';
							--CARGA EL ARCHIVO A LAS TABLAS
							EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_SubirArchivos(vsFlagTipoProceso, '71'/*RUTA ARCHIVO PROCESAR*/, TRIM(vsNomArchivo), psNumEmpleado) INTO vsCodRetorno, vsMensaje;
							
							IF (vsCodRetorno = '00000') THEN -- VALIDA KE EL ARCHIVO SE CARGO CORRECTAMENTE A LAS TABLAS
								
								SET LOCK MODE TO WAIT 3;
								SET ISOLATION TO DIRTY READ;
								SELECT LIMIT 1 Fecha_Presentacion INTO vsFecha_Presentacion FROM BdiTef:"informix".Tef_cce_Encabezado_Paso WHERE Nombre_Arch = TRIM(vsNomArchivo) ;
								
								UPDATE BdiTef:"informix".Tef_Cce_Archivos SET fecha_presentacion = vsFecha_Presentacion where Nombre_Arch = TRIM(vsNomArchivo) AND fecha_presentacion = "";
								LET vsDescripcionProceso = 'Validacion de Integridad del Archivo.';
								--INTEGRIDAD DEL ARCHIVO
								EXECUTE PROCEDURE BdiTef:"informix".sp_tef_valida_datos( TRIM(vsNomArchivo), vsFecha_Presentacion, 'S' /*SALIDA CECOBAN*/, viTipoArchivo, 'R' /*RECEPTOR*/, TRIM(vsNomProceso) ) INTO vsCodRetorno, vsBloque;
								
								IF (vsCodRetorno = '00000') THEN --VALIDA LA INTEGRIDAD DEL ARCHIVO
									
									SELECT unique(fecha_aplica) INTO vSFecha_aplica 
									FROM BdiTef:"informix".Tef_Cce_Detalle_Paso WHERE Nombre_Arch = TRIM(vsNomArchivo)  AND fecha_presentacion = vsFecha_Presentacion;
									LET vdFecha_aplicaDe = Substr(vSFecha_aplica,5,2) || "/" || Substr(vSFecha_aplica,7,2) || "/" || Substr(vSFecha_aplica,1,4);
									
									UPDATE BdiTef:"informix". Tef_Cce_Archivos SET fecha_aplicacion = vdFecha_aplicaDe 
									WHERE Nombre_Arch = TRIM(vsNomArchivo)  AND fecha_presentacion = vsFecha_Presentacion;
										
									LET vsDescripcionProceso = 'Procesamiento del Archivo Original.';
									IF (viTipoArchivo = 11) THEN --ARCHIVO 11
										--NO SE USA ARCHIVO 11 EN TEF
										--EXECUTE PROCEDURE BdiTef:"informix".Sp_Domi_ProcesarArchivo11 ('02', TRIM(vsNomArchivo), psNumEmpleado) INTO vsCodRetorno, vsMensaje;
										--UPDATE BdiTef:"informix".Tef_Cce_Detalle_Paso SET cve_Estatus = '01' WHERE Nombre_Arch = TRIM(vsNomArchivo) AND motivo_dev = '99' ;
										--UPDATE BdiTef:"informix".Tef_Cce_Detalle_Paso SET cve_Estatus = '02' WHERE Nombre_Arch = TRIM(vsNomArchivo) AND motivo_dev <> '99';
									ELIF (viTipoArchivo = 61) THEN --ARCHIVO 61 
										
										EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_ProcesarArchivo61(TRIM(vsNomArchivo), vsFecha_Presentacion, psNumEmpleado) INTO vsCodRetorno;
										--UPDATE BdiTef:"informix".Tef_Cce_Detalle_Paso SET cve_Status = '02' WHERE Nombre_Arch = TRIM(vsNomArchivo) ;										
									ELIF (viTipoArchivo = 62) THEN --ARCHIVO 62
										
										EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_ProcesarArchivo62 (TRIM(vsNomArchivo), psNumEmpleado) INTO vsCodRetorno;
										UPDATE BdiTef:"informix".Tef_Cce_Detalle_Paso SET cve_Status = '01' WHERE Nombre_Arch = TRIM(vsNomArchivo) ;
									ELIF (viTipoArchivo = 63) THEN --ARCHIVO 63
										
										EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_ProcesarArchivo63 (TRIM(vsNomArchivo), vsFecha_Presentacion, psNumEmpleado) INTO vsCodRetorno;
										IF (vsCodRetorno = '00000') THEN
											UPDATE BdiTef:"informix".Tef_Cce_Detalle_Paso SET cve_Status = '01' WHERE Nombre_Arch = TRIM(vsNomArchivo) ;
										END IF ;
									END IF;
									
									IF (vsCodRetorno = '00000') THEN --VALIDA KE EL ARCHIVO SE PROCESO CORRECTAMENTE
										
										LET vsDescripcionProceso = 'Mover Registros Procesados a la Tabla de Historico.';
										--ARCHIVO ORIGINAL
										EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist (TRIM (vsNomArchivo), vsFecha_Presentacion, 'T', DECODE(viTipoArchivo, 62, '01', '02' /*61 Y 63*/ )) INTO vsCodRetorno;
										
										IF (vsCodRetorno = '00000') THEN -- VALIDA QUE LOS DATOS DEL ARCHIVO SE TRANSFIRIERON CORRECTAMENTE A LOS HISTORICOS
											
											LET vsDescripcionProceso = 'Mover Archivo Procesado al Repositorio Historico.';
											EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_MoverArchivos (TRIM (vsNomArchivo), '71' /*RUTA  ARCHIVO PROCESAR*/, '73' /*RUTA ARCVHIVOS PROCESADOS*/ ) INTO vsCodRetorno;
											
											IF (vsCodRetorno = '00000') THEN -- VALIDA KE EL ARCHIVO ORIGINAL SE PASO CORRECTAMENTE AL REPOSITORIO HISTORICO
												--GUARDA BITACORA EXITO
												LET vsDescripcionProceso = 'Transferencia Electrónica de Fondos Exitosa.';
												LET vsCodRetorno = '00000';
												EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
												sFINALIZADO, vsCodRetorno, psNumEmpleado, 'sp_tef_presentador_r', TRIM(vsNomArchivo), vsFecha_Presentacion, '02'/*EXITO*/ ) INTO vsCodRetorno2;
												
												EXECUTE PROCEDURE bditef:"informix".Sp_Tef_GuardarCCEArchivos (psNumEmpleado, TRIM (vsNomArchivo), vsFecha_Presentacion, '02') INTO vsCodRetorno2;
												
											ELSE --ERROR DE PASO DE ARCHIVO ORIGINAL AL REPOSITORIO DE HISTORICO
												--GUARDAR BITACORA
												EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
												sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Tef_MoverArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/* GUARDAR CCE_ARCHIVO*/) INTO vsCodRetorno2;
												LET vsCodRetorno3 = vsCodRetorno;
												LET vsCodRetorno = '00230';
											END IF;
											
										ELSE --ERROR AL MOVER LOS REGISTROS DEL ARCHIVO ORIGINAL AL HITORICO
											--GUARDAR BITACORA
											EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
											sERROR, vsCodRetorno, psNumEmpleado, 'sp_Tef_MoverRegistrosHist', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/* GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
											LET vsCodRetorno3 = vsCodRetorno;
											LET vsCodRetorno = '00224';
										END IF;
										
									ELSE --ERROR AL PROCESAR EL ARCHIVO
										
										--GUARDAR BITACORA
										EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
											sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Tef_ProcesarArchivo' || viTipoArchivo::CHAR(2), TRIM(vsNomArchivo), vsFecha_Presentacion, '03'/* RECHAZADO*/ ) INTO vsCodRetorno2;
										LET vsCodRetorno3 = vsCodRetorno;
										LET vsCodRetorno = '00223';
									END IF;
									
								ELSE --ERROR DE INTEGRIDAD EN EL ARCHIVO
									--GUARDAR BITACORA
									EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
									sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Tef_Valida_Datos', TRIM(vsNomArchivo), vsFecha_Presentacion, '03'/* RECHAZADO*/) INTO vsCodRetorno2;
									
									EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_MoverArchivos (TRIM (vsNomArchivo), '71' /*RUTA  ARCHIVO PROCESAR*/, '74' /*RUTA ARCVHIVOS ERRONEOS*/ ) INTO vsCodRetorno;
									
									IF (vsCodRetorno <> '00000') THEN --ERROR DE TRANSFERENCIA DE ARCHIVO
										EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
										sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Tef_ValidarNombreArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '03'/*RECHAZADO*/ ) INTO vsCodRetorno2;
									END IF; 
									LET vsCodRetorno3 = vsCodRetorno;
									LET vsCodRetorno = '00222';
								END IF;
								
							ELSE -- ERROR AL CARGAR EL ARCHIVO A LAS TABLAS DE PASO
								--GUARDAR BITACORA
								EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
								sERROR, vsCodRetorno, psNumEmpleado, 'sp_Tef_SubirArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/*GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
								LET vsCodRetorno3 = vsCodRetorno;
								LET vsCodRetorno = '00221';
							END IF;
						
						ELSE --NO EXISTE EL ARCHIVO
							EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
							sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Tef_BuscarArchivo', TRIM(vsNomArchivo) , vsFecha_Presentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
							LET vsCodRetorno3 = vsCodRetorno;
							LET vsCodRetorno = '00226';
						END IF;
					ELSE -- ERROR AL LIMPIAR LAS TABLAS
						--GUARDAR BITACORA
						EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
						sERROR, vsCodRetorno, psNumEmpleado, 'sp_Tef_SubirArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/*GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
						LET vsCodRetorno3 = vsCodRetorno;
						LET vsCodRetorno = '00225';
					END IF; 
				ELSE --EL ARCHIVO NO ES APTO PARA SER PROCESADO
				
				END IF;
			ELSE -- NOMBRE DE ARCHIVO ERRONEO
				--GRABAR EN LA BITACORA  vsCodRetorno
				EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
				sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Tef_ValidarNombreArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/*GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
				
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				SELECT LIMIT 1 Valor INTO vsRuta FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '71'; -- RUTA ARCHIVO PROCESAR
				
				--VALIDA QUE EL ARCHIVO EXISTA EN EL REPOSITORIO DE PROCESO
				EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_BuscarArchivo( TRIM(vsRuta), TRIM(vsNomArchivo)) INTO vsCodRetorno, vsFlagUnico;
				
				IF ((vsCodRetorno = '00000') AND (vsFlagUnico = 'V')) THEN --VALIDA QUE EXISTA EL ARCHIVO EN EL REPOSITORIO
					
					EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_MoverArchivos (TRIM (vsNomArchivo), '71' /*RUTA  ARCHIVO PROCESAR*/, '74' /*RUTA ARCVHIVOS ERRONEOS*/ ) INTO vsCodRetorno;
					
					IF (vsCodRetorno <> '00000') THEN --ERROR DE TRANSFERENCIA DE ARCHIVO
						EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
						sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Tef_ValidarNombreArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '03'/*RECHAZADO*/ ) INTO vsCodRetorno2;
					END IF; 
				END IF;
				LET vsCodRetorno3 = vsCodRetorno;
				LET vsCodRetorno = '00218';
				
			END IF;
		
			EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;
			--RETURN vsNomArchivo, vsCodRetorno, vsMensaje_Respuesta WITH RESUME; 
			RETURN vsNomArchivo, vsCodRetorno, (TRIM(vsMensaje_Respuesta) || DECODE (vsCodRetorno3, '00000', '', ' (' || vsCodRetorno3 || ')') ) WITH RESUME;
			
			IF EXISTS(SELECT descripcion FROM BdiTef:"informix".Tef_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sPROCESANDO ) THEN  --EL ARCHIVO SE ENCUENTRA PROCESANDO
				IF (vsCodRetorno <> '00220') THEN --VALIDA SI EL ERROR ES DISTINTO DE 'PROCESANDO'
					UPDATE BdiTef:"informix".Tef_Procesos SET Estatus = sERROR WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sPROCESANDO ;
				END IF;
			END IF;
			
		END WHILE;
	
	ELSE -- PARAMETRO NO ENCONTRADO
		EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;
		RETURN 'GENERAL', vsCodRetorno, vsMensaje_Respuesta;
		--LET vsCodRetorno = '00261'
	END IF;
	
END

END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: SP PRINCIPAL DE TEF -- PRESENTADOR RECEPTOR ARCH.  61, 62 Y 63.',
'Fecha: 2011/03/10',
'Version: 20110610.1200',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_tef_procesararchivo10(psNombreArchivo CHAR(20),psNombreArchivo11 CHAR(20))

RETURNING CHAR(5) AS CodRet;

--****************************************************************************************************
-- DESCRIPCION:  PROCESA Y VALIDA LOS DATOS DE LAS CUENTAS DEL ARCHIVO 10 PARA GENERAR EL 11.
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 29/03/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************

--DEFINICION DE VARIABLES.
DEFINE vsCodRet CHAR(5);
DEFINE vsCodRet2 CHAR(5);
DEFINE vsCodRet3 CHAR(5);


DEFINE vsPrefijoTarjeta CHAR(100);
DEFINE vsBancoPresentador CHAR (3);
DEFINE vsFecha_Presentacion_Gen CHAR(8);
DEFINE vsFechaManana CHAR(8);


--DEFINE vsMotivo_dev CHAR(2);
DEFINE vsCuenta CHAR(11);
DEFINE vsStatus_Cta CHAR (1);
DEFINE vsProductosNoPermitidos CHAR (100);
DEFINE vsProducto CHAR (4);
DEFINE vdFecha_Hoy DATE;
DEFINE vdFecha_Manana DATE;

DEFINE vsNombre_Arch CHAR(20);
DEFINE vsFecha_Presentacion CHAR(8);
DEFINE vsTipo_Registro CHAR(2);
DEFINE vsNum_Secuencia CHAR(7);
DEFINE vsCod_Operacion CHAR(2);
DEFINE vsCod_Divisa CHAR(2);
DEFINE vsFecha_Trans CHAR(8);
DEFINE vsBanco_Presentador CHAR(3);
DEFINE vsBanco_Receptor CHAR(3);
DEFINE vsImporte CHAR(15);
DEFINE vsUso_Futuro_ccen CHAR(16);
DEFINE vsTipo_Operacion CHAR(2);
DEFINE vsFecha_Aplica CHAR(8);
DEFINE vsTipo_Cta_Ord CHAR(2);
DEFINE vsNum_Cta_Ord CHAR(20);
DEFINE vsNombre_Ord CHAR(40);
DEFINE vsRfc_Ord CHAR(18);
DEFINE vsTipo_Cta_Rec CHAR(2);
DEFINE vsNum_Cta_Rec CHAR(20);
DEFINE vsNombre_Rec CHAR(40);
DEFINE vsRfc_Rec CHAR(18);
DEFINE vsRef_Servicio CHAR(40);
DEFINE vsNombre_Titular_Serv CHAR(40);
DEFINE vsImporte_Iva CHAR(15);
DEFINE vsRef_Numerica CHAR(7);
DEFINE vsRef_Leyenda CHAR(40);
DEFINE vsClave_Rastreo CHAR(30);
DEFINE vsMotivo_Dev CHAR(2);
DEFINE vsFecha_Pres_Ini CHAR(8);
DEFINE vsSolicitud_Confirmacion CHAR(1);
DEFINE vsUso_Futuro_Banco CHAR(11);
DEFINE vsRef_Confirmacion CHAR(30); 
DEFINE vsUso_Futuro_Cce CHAR(1);
DEFINE vsTasa_Tiie_Prom CHAR(7);
DEFINE vsDias_Retraso CHAR(3);
DEFINE vsImp_Tot_Int CHAR(15);
DEFINE vsCve_Estatus CHAR(11);
DEFINE vsFolio_Suc CHAR(30);
DEFINE vsUser_Insert CHAR(8);


DEFINE vsNum_Secuencia_S CHAR(7);
DEFINE vsNum_Operaciones_S CHAR(18);

--TRANSACCIONES
DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER;


DEFINE iSQLerr INTEGER;

--INICIALIZACION DE VARIABLES.
LET vsCodRet = '';
LET vsCodRet2 = '';
LET vsCodRet3 = '';

LET vsPrefijoTarjeta = '';
LET vsBancoPresentador = '';
LET vsFecha_Presentacion_Gen = '';
LET vsFechaManana = '';

LET vsMotivo_dev = '';
LET vsCuenta = '';
LET vsStatus_Cta = '';
LET vsProducto = '';
LET vsProductosNoPermitidos = '';
LET vdFecha_Hoy = CURRENT;
LET vdFecha_Manana = CURRENT;

LET vsNombre_Arch = '';
LET vsFecha_Presentacion = '';
LET vsTipo_Registro = '';
LET vsNum_Secuencia = '';
LET vsCod_Operacion = '';
LET vsCod_Divisa = '';
LET vsFecha_Trans = '';
LET vsBanco_Presentador = '';
LET vsBanco_Receptor = '';
LET vsImporte = '';
LET vsUso_Futuro_ccen = '';
LET vsTipo_Operacion = '';
LET vsFecha_Aplica = '';
LET vsTipo_Cta_Ord = '';
LET vsNum_Cta_Ord = '';
LET vsNombre_Ord = '';
LET vsRfc_Ord = '';
LET vsTipo_Cta_Rec = '';
LET vsNum_Cta_Rec = '';
LET vsNombre_Rec = '';
LET vsRfc_Rec = '';
LET vsRef_Servicio = '';
LET vsNombre_Titular_Serv = '';
LET vsImporte_Iva = '';
LET vsRef_Numerica = '';
LET vsRef_Leyenda = '';
LET vsClave_Rastreo = '';
LET vsMotivo_Dev = '';
LET vsFecha_Pres_Ini = '';
LET vsSolicitud_Confirmacion = '';
LET vsUso_Futuro_Banco = '';
LET vsRef_Confirmacion = ''; 
LET vsUso_Futuro_Cce = '';
LET vsTasa_Tiie_Prom = '';
LET vsDias_Retraso = '';
LET vsImp_Tot_Int = '';
LET vsCve_Estatus = '';
LET vsFolio_Suc = '';
LET vsUser_Insert = '';

LET vsNum_Secuencia_S = '';
LET vsNum_Operaciones_S = '';

--TRANSACCIONES
LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;

LET iSQLerr = 0;

--SET DEBUG FILE TO "/bdexport/TEF/trace/sp_tef_procesararchivo10.sql";
--TRACE ON;

BEGIN
ON EXCEPTION SET iSQLerr
	IF iSQLerr <> 0 THEN
	
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
		
		LET vsCodRet = iSQLerr;
		RETURN vsCodRet;
	END IF;
END EXCEPTION;
	
	
	ON EXCEPTION IN (-535)
		COMMIT WORK;
	END EXCEPTION WITH RESUME;
	
	-------SE OBTIENEN LOS PARAMETROS----
	
	--OBTIENE LA CLAVE DEL BANCO PRESENTADOR
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO vsBancoPresentador FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '75'; --C LAVE BANCOPPEL 137
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO vsPrefijoTarjeta FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '76'; -- PREFIJO TARJETA
	
	--SET LOCK MODE TO WAIT 3;
	--SET ISOLATION TO DIRTY READ;
	--SELECT FIRST 1 Valor INTO vsProductosNoPermitidos FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '82'; --PRODUCTOS NO PERMITIDOS
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Fecha_Hoy INTO vdFecha_Hoy FROM BdiCheq:"informix".Sc_Fechas; -- FECHA_HOY
	
	
	--AUMENTA UN DIA LA FECHA ACTUAL (PRESENTACION) PARA SER LA FECHA CARGO/PROGRAMACION
	LET vdFecha_Manana = vdFecha_Hoy + 1;
	
	--ASIGNA UN FORMATO DE FECHA PARA FUTURA FECHA DE PRESENTACION
	LET vsFecha_Presentacion_Gen = YEAR(vdFecha_Hoy)|| LPAD(MONTH (vdFecha_Hoy),2,'0') || LPAD(DAY (vdFecha_Hoy),2,'0');
	
	
	--VALIDA/PROPORCIONA LA FECHA T+1
	EXECUTE PROCEDURE BdInteg:"informix".sp_Valfecha_Banca('001', vdFecha_Manana, 0 ) INTO vsCodRet2,vdFecha_Manana;
	--VALIDA LA FECHA ACTUAL
	EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Fecha(vsFecha_Presentacion_Gen) INTO vsCodRet3;
	
	--ASIGNA UN FORMATO DE FECHA 
	LET vsFechaManana = YEAR(vdFecha_Manana )|| LPAD(MONTH (vdFecha_Manana ),2,'0') || LPAD(DAY (vdFecha_Manana ),2,'0');
		
	--VALIDA LA FECHA MANANA
	EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Fecha(vsFechaManana) INTO vsCodRet;
	
	IF (vsCodRet <> '00000') THEN -- VALIDA KE LA FECHA MANANA SEA VALIDA
		LET vsCodRet = '01900';
	ELIF (vsCodRet2 <> '000') THEN -- VALIDA KE LA FECHA MANANA SEA UN DIA HABIL
		LET vsCodRet = '01901';
	ELIF (vsCodRet3 <> '00000') THEN -- VALIDA KE LA FECHA HOY SEA VALIDA
		LET vsCodRet = '01902';
	ELSE 
		
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--OBTIENE LOS REGISTROS DEL ARCHIVO PARA PROCESAR
		FOREACH WITH HOLD
		SELECT 
		Nombre_Arch, Fecha_Presentacion, Tipo_Registro, Num_Secuencia, Cod_Operacion, Cod_Divisa, Fecha_Trans, 
		Banco_Presentador, Banco_Receptor, Importe, Uso_Futuro_ccen, Tipo_Operacion, Fecha_Aplica, Tipo_Cta_Ord, 
		Num_Cta_Ord, Nombre_Ord, Rfc_Ord, Tipo_Cta_Rec, Num_Cta_Rec, Nombre_Rec, Rfc_Rec, Ref_Servicio, 
		Nombre_Titular_Serv, Importe_Iva, Ref_Numerica, Ref_Leyenda, Clave_Rastreo, Motivo_Dev, Fecha_Pres_Ini, 
		Solicitud_Confirmacion, Uso_Futuro_Banco, Ref_Confirmacion, Uso_Futuro_Cce, Tasa_Tiie_Prom, Dias_Retraso, 
		Imp_Tot_Int, Cve_Status, Folio_Suc, User_Insert
		INTO 
		vsNombre_Arch, vsFecha_Presentacion, vsTipo_Registro, vsNum_Secuencia, vsCod_Operacion, vsCod_Divisa, vsFecha_Trans, 
		vsBanco_Presentador, vsBanco_Receptor, vsImporte, vsUso_Futuro_ccen, vsTipo_Operacion, vsFecha_Aplica, vsTipo_Cta_Ord, 
		vsNum_Cta_Ord, vsNombre_Ord, vsRfc_Ord, vsTipo_Cta_Rec, vsNum_Cta_Rec, vsNombre_Rec, vsRfc_Rec, vsRef_Servicio, 
		vsNombre_Titular_Serv, vsImporte_Iva, vsRef_Numerica, vsRef_Leyenda, vsClave_Rastreo, vsMotivo_Dev, vsFecha_Pres_Ini, 
		vsSolicitud_Confirmacion, vsUso_Futuro_Banco, vsRef_Confirmacion, vsUso_Futuro_Cce, vsTasa_Tiie_Prom, vsDias_Retraso, 
		vsImp_Tot_Int, vsCve_Estatus, vsFolio_Suc, vsUser_Insert
		FROM BdiTef:"informix".Tef_Cce_Detalle_Paso 
		WHERE Nombre_Arch = psNombreArchivo AND Cod_operacion = '10'
			
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN 
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;
			
			LET vsMotivo_dev = '99'; -- OK
			LET vsStatus_Cta = '';
			
			-- 1.- Motivo 06 "CUENTA NO PERTENECE AL BANCO RECEPTOR" --
			--IF ((SUBSTR(vsNum_Cta_Rec,5,6) <> TRIM(vsPrefijoTarjeta)) --VALIDA TARJETA
			IF( (TRIM(vsPrefijoTarjeta) NOT MATCHES '*'|| (SUBSTR(vsNum_Cta_Rec,5,6) || '*'))
			AND (SUBSTR(vsNum_Cta_Rec,3,3) <> TRIM(vsBancoPresentador)) --VALIDA BANCO - CUENTA
			AND (NOT EXISTS (SELECT Num_Credito FROM BdiCred:Sd_MaeCred WHERE Empresa = '001' AND Num_Credito = vsNum_Cta_Rec)) --VALIDA NUMERO DE CREDITO
			)THEN -- VALIDA QUE SEA UNA CUENTA O UNA TARJETA DE BANCOPPEL
				LET vsMotivo_dev = '06'; --CUENTA NO PERTENECE AL BANCO RECEPTOR
			ELSE --OK
				--IF (SUBSTR(vsNum_Cta_Rec,5,6) = TRIM(vsPrefijoTarjeta)) THEN --ES UNA TARJETA
				IF( TRIM(vsPrefijoTarjeta) MATCHES '*'|| SUBSTR(vsNum_Cta_Rec,5,6) ||'*')THEN --ES UNA TARJETA
					
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
					--SE OBTIENE LA CUENTA RELACIONADA A LA TARJETA
					SELECT FIRST 1 NVL(Cuenta,'') INTO vsCuenta FROM BdiCheq:"informix".Sc_Tarjeta WHERE Empresa = '001' AND Num_Tarjeta = SUBSTR(TRIM(vsNum_Cta_Rec),5,16);
					
				ELSE
					LET vsCuenta = SUBSTR(vsNum_Cta_Rec,9,11); --CUENTA
				END IF;
				
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				--OBTIENE DATOS DE LA CUENTA
				SELECT FIRST 1 NVL(Status_Cta, ''), NVL(Producto, '') INTO vsStatus_Cta, vsProducto FROM BdiCheq:"informix".Sc_MaeChq WHERE Empresa = '001' AND Cuenta = vsCuenta;
				
				--IF (NVL(vsProducto, '') LIKE '%' || TRIM(vsProductosNoPermitidos) || '%' ) THEN --VALIDA QUE SEA UN PRODUCTO NO PERMITIDO
				IF (NOT EXISTS (SELECT Cve_Producto FROM BdiTef:"informix".Tef_Prod_Permitidos WHERE Cve_Producto = vsProducto) ) THEN --VALIDA QUE SEA UN PRODUCTO NO PERMITIDO
					LET vsMotivo_dev = '06'; --CLIENTE NO TIENE AUTORIZADO EL SERVICIO
				ELIF (NVL(vsStatus_Cta, '') = '') THEN --VALIDA KE EXISTA LA CUENTA
					LET vsMotivo_dev = '01'; --CUENTA INEXISTENTE
				ELIF (vsStatus_Cta = '3') THEN --VALIDA KE  LA CUENTA NO ESTE BLOQUEADA
					LET vsMotivo_dev = '02';
				ELIF (vsStatus_Cta = '2') THEN --VALIDA KE  LA CUENTA NO ESTE CANCELADA
					LET vsMotivo_dev = '03';
				END IF;
				
			END IF;
			
			--ACTUALIZA EL REGISTRO ORIGINAL
			UPDATE BdiTef:"informix".Tef_Cce_Detalle_Paso 
            SET Cve_Status = DECODE(vsMotivo_dev, '99', '01'/*OK*/, '02'/*ERROR*/), motivo_dev = vsMotivo_dev
			WHERE Nombre_Arch = psNombreArchivo 
			AND Fecha_Presentacion = vsFecha_Presentacion
			AND Tipo_registro = vsTipo_Registro 
			AND Num_secuencia = vsNum_Secuencia 
			AND cod_operacion = '10';
			
			--GUARDA EL REGISTRO DE LA INTRUCCION DE CARGO EN LA TABLA DE PASO
			INSERT INTO BdiTef:"informix".Tef_Cce_Detalle_Paso
			(
				Nombre_Arch,
				Fecha_Presentacion,
				Tipo_Registro,
				Num_Secuencia,
				Cod_Operacion,
				Cod_Divisa,
				Fecha_Trans,
				Banco_Presentador,
				Banco_Receptor,
				Importe,
				Uso_Futuro_Ccen,
				Tipo_Operacion,
				Fecha_Aplica,
				Tipo_Cta_Ord,
				Num_Cta_Ord,
				Nombre_Ord,
				Rfc_Ord,
				Tipo_Cta_Rec,
				Num_Cta_Rec,
				Nombre_Rec,
				Rfc_Rec,
				Ref_Servicio,
				Nombre_Titular_Serv,
				Importe_Iva,
				Ref_Numerica,
				Ref_Leyenda,
				Clave_Rastreo,
				Motivo_Dev,
				Fecha_Pres_Ini,
				Solicitud_Confirmacion,
				Uso_Futuro_Banco,
				Ref_Confirmacion, 
				Uso_Futuro_Cce,
				Tasa_Tiie_Prom,
				Dias_Retraso,
				Imp_Tot_Int,
				Cve_Status,
				Folio_Suc,
				User_Insert,
				Fecha_Insert
			)
			VALUES 
			(
				NVL(psNombreArchivo11,''), 
				--NVL(vsFecha_Presentacion_Gen,''), --FECHA PRESENTACION
                NVL(vsFechaManana,''), --FECHA PRESENTACION
				NVL(vsTipo_Registro,''), --TIPO REGISTRO
				NVL(vsNum_Secuencia,''),--NUM_SECUENCIA
				'11', --CODIGO DE OPERACION
				NVL(vsCod_Divisa,''), --DIVISA
				NVL(vsFechaManana,''), --FECHA_TRANS    -------------
				NVL(vsBanco_Receptor,''), --BANCO_PRESENTADOR   ---SE INTERCAMBIAN LOS BANCOS PARA EL ARCHIVO DE RESPUESTA
				NVL(vsBanco_Presentador,''), --BANCO_RECEPTOR
				NVL(vsImporte,''), -- IMPORTE
				NVL(LPAD(vsUso_Futuro_ccen,16,' '),''), -- USO_FUTURO_CCE
				NVL(vsTipo_Operacion,''), --TIPO OPERACION ???11
				NVL(vsFechaManana,''), --FECHA APLICACION  ---------
				NVL(vsTipo_Cta_Ord,''),--'40',  --TIPO CUENTA ORDENANTE
				NVL(vsNum_Cta_Ord,''), --NUM_CTA_ORD
				NVL(vsNombre_Ord,''), --NOMBRE CLIENTE ORD
				NVL(vsRfc_Ord,''), --RFC ORDENANTE
				NVL(vsTipo_Cta_Rec,''), --TIPO_CTA_REC
				NVL(vsNum_Cta_Rec,''), -- NUM_CTA_REC
				NVL(vsNombre_Rec,''), --NOMBRE_REC
				NVL(vsRfc_Rec,''), -- RFC_REC
				NVL(vsRef_Servicio,''), --REF_SERVICIO
				NVL(vsNombre_Titular_Serv,''), --NOMBRE_TITULAR
				NVL(vsImporte_Iva,''), --IMPORTE IVA
				NVL(vsRef_Numerica,''), --REF_NUMERICA
				NVL(vsRef_Leyenda,''), --REF_LEYENDA
				NVL(vsClave_Rastreo,''),--CLAVE_RASTREO
				NVL(vsMotivo_Dev,''), --MOTIVO_DEVOLUCION
				--NVL(vsFecha_Presentacion_Gen,''), --FECHA_PRESENTACION_INI  --DEBE SER IGUAL A FECHA PRESENTACION
                NVL(vsFecha_Pres_Ini,''), --FECHA_PRESENTACION_INI  --DEBE SER IGUAL A FECHA PRESENTACION
				NVL(vsSolicitud_Confirmacion,''), --SOLICITUD CONFIRMACION (1)
				NVL(LPAD(vsUso_Futuro_Banco,11,' '),''), --USO FUTURO  BANCO
				NVL(LPAD(vsRef_Confirmacion,30,' '),''), --CONFIRMACION
				NVL(LPAD(vsUso_Futuro_Cce,1,' '),''), --USO_FUTURO_CCE
				NVL(LPAD(vsTasa_Tiie_Prom,7,' '),''), --TASA TIIE PROM
				NVL(LPAD(vsDias_Retraso,3,' '),''), --DIAS_RETRASO
				NVL(LPAD(vsImp_Tot_Int,15,' '),''), --IMP_TOT_INT
				NVL(vsCve_Estatus,''), --CVE_ESTATUS
				NVL(vsFolio_Suc,''), -- FOLIO_SUC
				vsUser_Insert, --USUARIO_INSERT
				CURRENT::DATE --FECHA_INSERT
			);
			
			LET viContadorRegistros = viContadorRegistros + 1;
			
			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;
			
		END FOREACH;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
		
		--FORMA EL REGISTRO DE ENCABEZADO
		--ENCABEZADO
		INSERT INTO BdiTef:"informix".Tef_Cce_Encabezado_Paso
		(
			Nombre_Arch,
			Fecha_Presentacion,
			Tpo_Registro,
			Num_Secuencia,
			Cod_Operacion,
			Cve_Banco,
			Sentido,
			Servicio,
			Num_Bloque,
			Cod_Divisa,
			Cve_Rechazo_bl,
			Modalidad,
			Uso_Futuro_Ccen,
			Uso_Futuro_Banco,
			User_Insert,
			Fecha_Insert
		)
		VALUES
		(
			NVL(psNombreArchivo11,''),
			--NVL(vsFecha_Presentacion_Gen,''),
            nvl(vsFechaManana,''),
			'01', --TIPO REGISTRO
			LPAD('1',7,'0'), --'0000001', --SECUENCIA
			'11', --ARCHIVO
			NVL(vsBancoPresentador,''), --BANCOPEL 137 
			'E', --SENTIDO
			'2', --SERVICIO
			--NVL(LPAD(DAY(vdFecha_Hoy),2,'0') || LPAD((SUBSTR(psNombreArchivo11,(LENGTH(TRIM(psNombreArchivo11)) - 1), 2)),5,'0'),''), --NUM BLOQUE
            NVL(LPAD(DAY(vdFecha_Manana),2,'0') || LPAD((SUBSTR(psNombreArchivo11,(LENGTH(TRIM(psNombreArchivo11)) - 1), 2)),5,'0'),''), --NUM BLOQUE
			'01', --DIVISA
			'00',--CVE_RECHAZO_BL
			'2',--MODALIDAD
			LPAD('',41,' '),--USO_FUTURO_CCEN
			LPAD('',370,' '),--USO_FUTURO_BANCO
			vsUser_Insert,
			CURRENT::DATE
		);
		
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--OBTIENE LOS DATOS DEL SUMADIO ORIGINAL
		SELECT FIRST 1 Num_Secuencia, Num_Operaciones
		INTO vsNum_Secuencia_S, vsNum_Operaciones_S
		FROM BdiTef:"informix".Tef_Cce_Sumario_Paso 
		WHERE Nombre_Arch = psNombreArchivo 
		AND Cod_Operacion = '10';
		
		--FORMA EL REGISTRO DE SUMARIO
		--SUMARIO
		INSERT INTO BdiTef:"informix".Tef_Cce_Sumario_Paso
		(
			Nombre_Arch,
			Fecha_Presentacion,
			Tipo_Registro,
			Num_Secuencia,
			Cod_Operacion,
			Num_Bloque,
			Num_Operaciones,
			Imp_Operaciones,
			Uso_Futuro_ccen,
			Uso_Futuro_banco,
			User_Insert,
			Fecha_Insert
		)
		VALUES
		(
			psNombreArchivo11, --NOMBRE_ARCH
			--NVL(vsFecha_Presentacion_Gen,''), --FECHA_PRESENTACION
            NVL(vsFechaManana,''), --FECHA_PRESENTACION
			'09', --TIPO_REGISTRO
			NVL(vsNum_Secuencia_S,''),--NUM_SECUENCIA
			'11', --COD_OPERACION
			--NVL(LPAD(DAY(vdFecha_Hoy),2,'0') || LPAD((SUBSTR(psNombreArchivo11,(LENGTH(TRIM(psNombreArchivo11)) - 1), 2)),5,'0'),''), --NUM BLOQUE
            NVL(LPAD(DAY(vdFecha_Manana),2,'0') || LPAD((SUBSTR(psNombreArchivo11,(LENGTH(TRIM(psNombreArchivo11)) - 1), 2)),5,'0'),''), --NUM BLOQUE
			NVL(vsNum_Operaciones_S,''),--NUM_OPERACIONES -- REGISTROS EN EL DETALLE
			LPAD('0',18,'0'),--IMPORTE TOTAL DE OPERACIONES
			LPAD('',40,' '),--USO_FUTURO_CCEN
			LPAD('',364,' '),--USO_FUTURO_BANCO
			vsUser_Insert, --USUARIO_INSERT
			CURRENT::DATE --FECHA_INSERT
		);
		
	END IF;
	
	RETURN vsCodRet;
	
END
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: PROCESA Y VALIDA LOS DATOS DE LAS CUENTAS DEL ARCHIVO 10 PARA GENERAR EL 11.',
'Fecha: 2011/03/29',
'Version: 20110329.1120',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_tef_validarnombrearchivos(piCodOperacion SMALLINT, psSentido CHAR(1), psNombreArchivo VARCHAR(20))
RETURNING CHAR(5) AS CodRet;


--****************************************************************************************************
-- DESCRIPCION:  PROCEDIMIENTO PARA VALIDAR LA ESTRUCTURA DEL NOMBRE DE LOS ARCHIVOS A RECIBIR POR PARTE DE CECOBAN, ARCHIVOS CODIGO 10, 11 Y CODIGO 60, 61, 62, 63
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 08/03/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************


---DECLARACIONES
DEFINE vsCodRet            CHAR(5);
DEFINE iSqlErr              INTEGER;
DEFINE iSamErr              INTEGER;

DEFINE vsDescMensajeError	VARCHAR(95);
DEFINE iNumDia				SMALLINT;
DEFINE iNumMes				SMALLINT;
DEFINE iNumAnio				SMALLINT;
DEFINE vsCodBanco			CHAR(3);
DEFINE sCodRetFecha			VARCHAR(5);
DEFINE dFechaHoy				DATE;
DEFINE dFechaHabil				DATE;

DEFINE vsTipoArchivo CHAR(1);


---INICIALIZACIONES
LET vsCodRet 				= "00000";
LET vsDescMensajeError		= "";
LET iNumDia					= 0;
LET iNumMes					= 0;
LET iNumAnio				= 0;
LET vsCodBanco				= "";
LET sCodRetFecha			= "00000";
LET dFechaHoy				= MDY(1,1,1900);
LET dFechaHabil				= MDY(1,1,1900);

LET vsTipoArchivo = '';

--SET DEBUG FILE TO "/bdexport/TEF/trace/sp_tef_validarnombrearchivos.sql";
--TRACE ON;

BEGIN
ON EXCEPTION
	SET iSqlErr, iSamErr
	IF iSqlErr <> 0 THEN
		LET vsCodRet = iSqlErr;
	END IF;

	RETURN vsCodRet;
END EXCEPTION;


--- VALIDA QUE SEA UN CODIGO DE OPERACION LEGAL
IF (piCodOperacion NOT IN (SELECT cod_operacion FROM BdiTef:"informix".Tef_Codigo_Oper)) THEN
	LET vsCodRet = '01400';
ELSE
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--- OBTIENE CODIGO DE BANCOPPEL
	SELECT FIRST 1 TRIM(Valor) INTO vsCodBanco FROM BdiTef:"informix".Tef_Parametros WHERE cod_param = "75";
	
	--- OBTIENE EL NUMERO DE DIA, MES Y AÑO DE LA FECHA DEL SISTEMA
	
	--- SE VALIDA LA FECHA T +1 SOLAMENTE EN EL CASO DEL ARCHIVO CODIGO 63 DE SENTIDO 'E'
	IF ((piCodOperacion = '63') AND (psSentido = 'E')) THEN
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT FIRST 1 Fecha_Hoy
		INTO dFechaHoy
		FROM BdiCheq:"informix".Sc_Fechas;
		
		--- SE OBTIENE LA FECHA VALIDA MAS PROXIMA
		EXECUTE FUNCTION BdInteg:"informix".SplValFecha('001',(dFechaHoy) + 1 ,0) INTO sCodRetFecha,dFechaHabil;
		
		IF (sCodRetFecha::INTEGER = 0) THEN
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT FIRST 1 DAY(dFechaHabil), MONTH(dFechaHabil), YEAR(dFechaHabil)
			INTO iNumDia, iNumMes, iNumAnio
			FROM BdiCheq:"informix".Sc_Fechas;
			
		END IF;
	ELSE
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT FIRST 1 DAY(Fecha_Hoy), MONTH(Fecha_Hoy), YEAR(Fecha_Hoy)
		INTO iNumDia, iNumMes, iNumAnio
		FROM BdiCheq:"informix".Sc_Fechas;
	END IF;
	
	--GENERADOS POR CECOBAN
	--IF (piCodOperacion <> 63) THEN --FORMATO DE NOMBRE DE ARCHIVO NORMAL
	IF (psSentido = 'S') THEN --FORMATO DE NOMBRE DE ARCHIVO NORMAL ( ENTRADA PARA CECOBAN )  -- RESPUESTAS DE BANCO
		LET vsTipoArchivo = '';
			/*
			E01bbbAs.tffddcc
			E            =         Envío (Sentido del Archivo: Bancos . CCE)
			01          =         Plaza de la Cámara de Compensación Electrónica Nacional.
			bbb         =         Clave de identificación de los distintos bancos para su diferencia
			A            =         Carácter que identifica el buzón (Constante)
			S            =         Servicio TEF   2 . Transferencia Electrónica de Fondos
			.            =          Constante (punto)
			t           =           Tipo de archivo  A . Archivo de Datos (salida)  H . Reporte Hcom
			ff         =           Para Archivos de Datos, indica Código de Operación  
					 10 . Verificación de Cuentas Presentadas
					 11 . Verificación de Cuentas Devueltas
					 60 . Operaciones de Abono Presentadas
					 61 . Operaciones de Abono Devueltas
					 62 . Confirmaciones de Abonos
					 63 . Devoluciones de Abonos extemporáneos
			dd             =          Día de Proceso
			cc          =       Consecutivo de archivo en dos dígitos (los dos últimos dígitos del número de bloque considerando lo mencionado en la nota del registro sumario del diccionario campos)
			*/
		
		-- VALIDA CONSECUTIVO
		EXECUTE PROCEDURE BdiTef:"informix".sp_valida_cadena(SUBSTR(psNombreArchivo,15,2),"N") INTO vsCodRet;
		
		--- VALIDA LOS ARCHIVOS DE ENTRADA DE CECOBAN
		IF (LENGTH(psNombreArchivo) <> 16) THEN--- VALIDA LA LONGITUD DEL NOMBRE
			LET vsCodRet = '01401';
		ELIF (SUBSTR(psNombreArchivo,1,1) <> UPPER(psSentido)) THEN	--- VALIDA SENTIDO DEL ARCHIVO
			LET vsCodRet = '01402';
		ELIF (SUBSTR(psNombreArchivo,2,2) <> '01') THEN --VALIDA PLAZA DE LA CÁMARA DE COMPENSACIÓN ELECTRÓNICA NACIONAL.
			LET vsCodRet = '01403';
		ELIF (SUBSTR(psNombreArchivo,4,3) <> vsCodBanco) THEN --- VALIDA CLAVE DE BANCOPPEL
			LET vsCodRet = '01404';
		ELIF (SUBSTR(psNombreArchivo,7,1) <> 'A') THEN	--- VALIDA EL CARÁCTER QUE IDENTIFICA EL BUZÓN (CONSTANTE)
			LET vsCodRet = '01405';
		ELIF (SUBSTR(psNombreArchivo,8,1) <> '2') THEN	--- VALIDA EL SERVICIO TEF  [2 . TRANSFERENCIA ELECTRÓNICA DE FONDOS]
			LET vsCodRet = '01406';
		ELIF (SUBSTR(psNombreArchivo,9,1) <> '.') THEN	--- VALIDA EL PUNTO (CONSTANTE)
			LET vsCodRet = '01407';
		ELIF (SUBSTR(psNombreArchivo,10,1) <> 'A') THEN	--- VALIDA EL TIPO DE ARCHIVO  [A - H]
			--LET vsCodRet = '01408';
		ELIF (SUBSTR(psNombreArchivo,11,2) <> piCodOperacion) THEN --- VALIDA CODIGO DE OPERACION
			LET vsCodRet = '01409';
		--COMENTADO A PETICION DE JAIME GONZALEZ PARA LA FASE 2 DE PRUEBAS CON CECOBAN
		--PERMITIR EL PROCESO DE ARCHIVOS DE FECHA DISTINTA A LA ACTUAL
		--ELIF (SUBSTR(psNombreArchivo,13,2)::SMALLINT <> iNumDia) THEN --- VALIDA DIA DEL PROCESO
			--LET vsCodRet = '01410';
		ELIF (vsCodRet <> '00000') THEN -- VALIDA CONSECUTIVO
			LET vsCodRet = '01413';
		ELSE -- OK
			LET vsCodRet = '00000';
		END IF;
		
	--GENERADOS POR BANCOPPEL
	--ELIF (piCodOperacion = 63) THEN --FORMATO DE NOMBRE DE ARCHIVO 63
	ELIF (psSentido = 'E') THEN --FORMATO DE NOMBRE DE ARCHIVO NORMAL ( SALIDA DE CECOBAN )
		
		/*
		Ebbbddmmyyyy.oocc
		E		=	Entrada (Sentido del Archivo Bancoppel . CCEN).
		bbb		=	Clave que identifica a Bancoppel como una institución bancaria, este campo debe de contener el valor: 137.
		dd		=	Día del proceso, este dato debe de corresponder al día de la fecha correspondiente al día .T + 1..
		mm		=	El valor que debe de contener este campo corresponde al mes de la fecha .T + 1..
		yyyy	=	Año correspondiente a la fecha .T + 1..
		.		=	Punto (Constante).
		oo		= 	Código de la Operación, el valor que debe de contener este campo es .63..
		cc		=	Consecutivo del archivo en dos dígitos.
		*/
		
		-- VALIDA CONSECUTIVO
		EXECUTE PROCEDURE BdiTef:"informix".sp_valida_cadena(SUBSTR(psNombreArchivo,16,2),"N") INTO vsCodRet;
		
		IF (LENGTH(psNombreArchivo) <> 17) THEN--- VALIDA LA LONGITUD DEL NOMBRE
			LET vsCodRet = '01401';
		ELIF (SUBSTR(psNombreArchivo,1,1) <> UPPER(psSentido)) THEN	--- VALIDA SENTIDO DEL ARCHIVO
			LET vsCodRet = '01402';
		ELIF SUBSTR(psNombreArchivo,2,3) <> vsCodBanco THEN --- VALIDA CLAVE DE BANCOPPEL
			LET vsCodRet = '01404';
		--COMENTADO A PETICION DE JAIME GONZALEZ PARA LA FASE 2 DE PRUEBAS CON CECOBAN
		--PERMITIR EL PROCESO DE ARCHIVOS DE FECHA DISTINTA A LA ACTUAL
		--ELIF (SUBSTR(psNombreArchivo,5,2)::SMALLINT <> iNumDia) THEN --- VALIDA DIA DEL PROCESO
			--LET vsCodRet = '01410';
		ELIF (SUBSTR(psNombreArchivo,7,2)::SMALLINT <> iNumMes) THEN --- VALIDA MES DEL PROCESO
			LET vsCodRet = '01411';
		ELIF (SUBSTR(psNombreArchivo,9,4)::SMALLINT <> iNumAnio) THEN --- VALIDA AÑO DEL PROCESO
			LET vsCodRet = '01412';
		ELIF (SUBSTR(psNombreArchivo,13,1) <> '.') THEN	--- VALIDA EL PUNTO (CONSTANTE)
			LET vsCodRet = '01407';
		ELIF (SUBSTR(psNombreArchivo,14,2) <> piCodOperacion) THEN --- VALIDA CODIGO DE OPERACION 63
			LET vsCodRet = '01409';
		ELIF (vsCodRet <> '00000') THEN -- VALIDA CONSECUTIVO
			LET vsCodRet = '01413';
		ELSE -- OK
			LET vsCodRet = '00000';
		END IF;
	END IF;
			
END IF;

RETURN vsCodRet;
	
END;

END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: PROCEDIMIENTO PARA VALIDAR LA ESTRUCTURA DEL NOMBRE DE LOS ARCHIVOS A RECIBIR POR PARTE DE CECOBAN, ARCHIVOS CODIGO 10, 11 Y CODIGO 60, 61, 62, 63.',
'Fecha: 2011/03/08',
'Version: 20110308.1833',
'BD: BdiTef',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: MODIFICADO A PETICION DE JAIME GONZALEZ PARA LA FASE 2 DE PRUEBAS CON CECOBAN.',
'Fecha: 2011/09/29',
'Version: 20110929.1359',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_valida_cadena(psCadena LVARCHAR(345),psTipo CHAR(1))
RETURNING CHAR(5) AS CodRet;

--****************************************************************************************************
-- DESCRIPCION:  VALIDA QUE LA CADENA NO CONTENGA CARACTERES ESPECIALES
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 09/03/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************


DEFINE vsCodRet  CHAR(5);
DEFINE viLongitud INTEGER;
DEFINE vsCadena2 CHAR(20);
DEFINE viInicio INTEGER;
DEFINE vsFinCiclo CHAR(1);
DEFINE vsValor CHAR(1);

DEFINE iSqlErr INTEGER;

LET vsCadena2 = '';
LET vsFinCiclo = '';
LET vsCodRet = '';
LET vsValor = '';

LET iSqlErr = 0;

--SET DEBUG FILE TO "/bdexport/TEF/trace/sp_valida_cadena.sql";
--TRACE ON;

BEGIN
ON EXCEPTION
	SET iSqlErr
	IF iSqlErr <> 0 THEN
		LET vsCodRet = iSqlErr;
	END IF;

	RETURN vsCodRet;
END EXCEPTION;

	LET vsCodRet = '00000';
	
	IF ((psTipo <> 'A') AND (psTipo <> 'N') AND (psTipo <> 'B') AND (psTipo <> 'P') AND (psTipo <> 'T')) THEN
		LET vsCodRet = '01500';
		
	ELIF ((psTipo = 'N') OR (psTipo = 'A') OR (psTipo = 'T')) AND (NVL(psCadena,'') = '') THEN
		LET vsCodRet = '01501';
		
	ELIF (psTipo = 'A') THEN  --VALIDA QUE LA CADENA SEA ALFANUMERICO
		LET viLongitud = LENGTH(psCadena);
		LET viInicio = 1;
		LET vsFinCiclo = 'F';
		
		WHILE ((viInicio <= viLongitud) AND (vsFinCiclo = 'F'))
			LET vsCadena2 = SUBSTR(psCadena,viInicio,1);
			IF ((vsCadena2 >= 'A') AND (vsCadena2 <= 'Z')) OR ((vsCadena2 >= 'a') AND (vsCadena2 <= 'z')) OR ((vsCadena2 >= '0')  AND (vsCadena2 <= '9'))THEN
				LET vsValor = 'A';
			ELSE
				LET vsValor = 'B';
				LET vsFinCiclo = 'T';
			END IF;
			LET viInicio = (viInicio + 1);
		END WHILE;
		
		IF (vsValor = 'B') THEN
			LET vsCodRet = '01502';
		END IF;
	
	ELIF (psTipo = 'N') THEN --VALIDA QUE LA CADENA SEA NUMERICO

		LET viLongitud = LENGTH(psCadena);
		LET viInicio = 1;
		LET vsFinCiclo = 'F';
		
		WHILE ((viInicio <= viLongitud) AND (vsFinCiclo = 'F'))
			LET vsCadena2 = SUBSTR(psCadena,viInicio,1);
			IF ((vsCadena2 >= '0')  AND (vsCadena2 <= '9'))THEN
				LET vsValor = 'A';
			ELSE
				LET vsValor = 'B';
				LET vsFinCiclo = 'T';
			END IF;
			LET viInicio = (viInicio + 1);
		END WHILE;

		IF (vsValor = 'B') THEN
			LET vsCodRet = '01503';
		END IF;

	ELIF (psTipo = 'B') THEN
		
		LET viLongitud = LENGTH(psCadena);
		LET viInicio = 1;
		LET vsFinCiclo = 'F';
		
		WHILE ((viInicio <= viLongitud) AND (vsFinCiclo = 'F'))
			LET vsCadena2 = SUBSTR(psCadena,viInicio,1);
			IF (vsCadena2 = ' ') THEN
				LET vsValor = 'A';
			ELSE
				LET vsValor = 'B';
				LET vsFinCiclo = 'T';
			END IF;
			LET viInicio = (viInicio + 1);
		END WHILE;

		IF (vsValor = 'B') THEN
			LET vsCodRet = '01504';
		END IF;

	ELIF (psTipo = 'T') THEN --VALIDA CON LA TABLA DE CARACTERES VALIDOS EN LA CCE(CHEQUES,TEF)

		LET viLongitud = LENGTH(psCadena);
		LET viInicio = 1;
		LET vsFinCiclo = 'F';
		
		WHILE ((viInicio <= viLongitud) AND (vsFinCiclo = 'F'))
			LET vsCadena2 = SUBSTR(psCadena,viInicio,1);
			IF (((vsCadena2 >= ' ') AND (vsCadena2 <= ';'))
				OR ((vsCadena2 >= '?')  AND (vsCadena2 <= 'Z'))
				OR (vsCadena2 >= '\')
				OR (vsCadena2 >= '_')
				OR ((vsCadena2 >= 'a')  AND (vsCadena2 <= 'z'))
				OR (vsCadena2 >= 'é')
				OR ((vsCadena2 >= 'á')  AND (vsCadena2 <= 'Ñ'))
				OR (vsCadena2 >= '¿')
				OR (vsCadena2 >= '¡')) THEN
				LET vsValor = 'A';
			ELSE
				LET vsValor = 'B';
				LET vsFinCiclo = 'T';
			END IF;
			LET viInicio = (viInicio + 1);
		END WHILE;

		IF (vsValor = 'B') THEN
			LET vsCodRet = '01505';
		END IF;

	ELIF (psTipo = 'P') THEN --VALIDA CON RESPECTO A LOS CARACTERES PERMITIDOS EN LA NOMENCLATURA DE ARCHIVOS DE ENTRADA

		LET viLongitud = LENGTH(psCadena);
		LET viInicio = 1;
		LET vsFinCiclo = 'F';
		
		WHILE ((viInicio <= viLongitud) AND (vsFinCiclo = 'F'))
			LET vsCadena2 = SUBSTR(psCadena,viInicio,1);
			IF ((vsCadena2 >= '0') AND (vsCadena2 <= 'z'))OR (vsCadena2 >= '.')THEN
				LET vsValor = 'A';
			ELSE
				LET vsValor = 'B';
				LET vsFinCiclo = 'T';
			END IF;
			LET viInicio = (viInicio + 1);
		END WHILE;

		IF (vsValor = 'B') THEN
			LET vsCodRet = '01506';
		END IF;
	END IF;

	
	RETURN vsCodRet;

END;
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: VALIDA QUE LA CADENA NO CONTENGA CARACTERES ESPECIALES.',
'Fecha: 2011/03/09',
'Version: 20110309.1112',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_valida_fecha(psFecha CHAR(8))
 RETURNING CHAR(5) AS CodRet;
 
--****************************************************************************************************
-- DESCRIPCION:  VALIDA QUE LA FECHA SEA LA CORRECTA
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 09/03/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************

DEFINE	vsCodRet CHAR(5);
DEFINE	viSqlErr INTEGER;
DEFINE vsRespSP  CHAR(5);
DEFINE vdtFechaSp DATE;
DEFINE vsRetCodSP CHAR(5);
DEFINE vdtFechaReSp DATE;
DEFINE vsFecha_Dia CHAR(2);
DEFINE vsFecha_Mes CHAR(2);
DEFINE vsFecha_Ano CHAR(4);
DEFINE vsFecha_Dia_Len INTEGER;
DEFINE vsFecha_Mes_Len INTEGER;
DEFINE vsFecha_Ano_Len INTEGER;

LET vsCodRet = '00000';
LET vsRespSP = '';
LET vsRetCodSP = '';
LET vsFecha_Dia = '';
LET vsFecha_Mes = '';
LET vsFecha_Ano = '';


--SET DEBUG FILE TO "/bdexport/TEF/trace/sp_valida_fecha.sql";
--TRACE ON;

BEGIN
ON EXCEPTION SET viSqlErr
	IF (viSqlErr <> 0) THEN
		
		LET vsCodRet = viSqlErr;
		
		IF (vsCodRet = -1218) THEN
			LET vsCodRet = '01601';
		END IF;
		
		RETURN vsCodRet;
	END IF;
END EXCEPTION;

	EXECUTE PROCEDURE BdiTef:"informix".Sp_Valida_Cadena(psFecha,'N') INTO vsRespSP;
	
	IF (vsRespSP <> '00000') THEN --VALIDA 
		LET vsCodRet = '01601';
		RETURN vsCodRet;
	ELSE
		
		LET vsFecha_Dia  = (SUBSTR(psFecha,7,2));
		LET vsFecha_Dia_Len = LENGTH(vsFecha_Dia);
		
		IF (vsFecha_Dia_Len <> 2) THEN
			LET vsCodRet = '01601';
			RETURN vsCodRet;
		END IF;
		
		LET vsFecha_Dia = vsFecha_Dia::INTEGER;

		LET vsFecha_Mes  = (SUBSTR(psFecha,5,2));
		LET vsFecha_Mes_Len = LENGTH(vsFecha_Mes);
		
		IF (vsFecha_Mes_Len <> 2) THEN
			LET vsCodRet = '01601';
			RETURN vsCodRet;
		END IF;
		
		LET vsFecha_Mes = vsFecha_Mes::INTEGER;

		LET vsFecha_Ano = (SUBSTR(psFecha,1,4));
		LET vsFecha_Ano_Len = LENGTH(vsFecha_Ano);
		
		IF (vsFecha_Ano_Len <> 4) THEN
			LET vsCodRet = '01601';
			RETURN vsCodRet;
		END IF;
		
		LET vsFecha_Ano = vsFecha_Ano::INTEGER;

		--SE VALIDA QUE EL DIA SEA CORRECTO
		IF  ((vsFecha_Dia < 1) OR (vsFecha_Dia > 31)) THEN
			LET vsCodRet = '01601';
			RETURN vsCodRet;
		END IF;
		--SE VALIDA QUE EL MES SEA CORRECTO
		IF ((vsFecha_Mes < 1) OR (vsFecha_Mes > 12)) THEN
			LET vsCodRet = '01601';
			RETURN vsCodRet;
		END IF;
		
		--SE VALIDA QUE EL ANO SEA CORRECTO
		IF ((vsFecha_Ano < 1900) OR (vsFecha_Ano > 2900)) THEN
			LET vsCodRet = '01601';
			RETURN vsCodRet;
		END IF;
		
		---SE VALIDA QUE LA FECHA SEA UNA FECHA HABIL
		LET vdtFechaSp = SUBSTR(psFecha,5,2) || '/' || SUBSTR(psFecha,7,2) || '/' || SUBSTR(psFecha,1,4);
		
		--SE VALIDA QUE LA FECHA NO SEA UN DIA INABIL
		EXECUTE FUNCTION bdinteg:"informix".splvalfecha('001', vdtFechaSp, 0 ) INTO vsRetCodSP,vdtFechaReSp;
		
		--SE VALIDA QUE LA FECHA DE PROCESO SEA IGUAL FECHA HABIL
		IF NOT vdtFechaSp = vdtFechaReSp THEN
			LET vsCodRet = '01601';
			RETURN vsCodRet;
		END IF;
		
	END IF;
	RETURN vsCodRet;
	
END;
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: VALIDA QUE LA FECHA SEA LA CORRECTA.',
'Fecha: 2011/03/09',
'Version: 20110309.1130',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_validadiahabiltef(pFecha CHAR(10))
   	RETURNING CHAR(5), CHAR(5);  

   DEFINE cCodRet1 	  CHAR(5);
   DEFINE cCodRet2 	  CHAR(5);
   DEFINE cEsFeriado  CHAR(1);
   DEFINE dFecha	  DATE;
   DEFINE iSql_Err    INT;   
   DEFINE iSam_Err    INT; 

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET iSql_Err   = 0;    
   LET iSam_Err   = 0; 
   LET cCodRet1   = "00000";
   LET cCodRet2   = "00000";
   LET cEsFeriado = "0";
   LET dFecha     = "01/01/1900";
   
     --SET DEBUG FILE TO "/respaldosbd/Dulce/sp_ValidaDiaHabilTEF.out";
     --TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_Err, iSam_Err
	IF iSql_Err <> 0 OR iSam_Err <> 0 THEN
	    LET cCodRet1 = iSql_Err;
	    RETURN cCodRet1, cCodRet2;
	END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	
	IF  pFecha IS NULL OR pFecha = "" THEN
		LET cCodRet2 = "00001"; 
		RETURN cCodRet1, cCodRet2; 
	END IF;
	
	LET dFecha = TO_DATE(pFecha,"%m/%d/%Y");

	
	SELECT "1"
	INTO cEsFeriado
	FROM bdinteg:"informix".si_feriado
	WHERE fecha = dFecha
	AND pais = "001";
	
	IF cEsFeriado is null THEN
		LET cEsFeriado = "0";
	END IF

	IF cEsFeriado <> "1" THEN
      	IF TO_CHAR(dFecha,"%A") = "Saturday" OR TO_CHAR(dFecha,"%A") = "Sunday"  THEN
		    LET cCodRet2 = "00002";
		END IF
	ELSE 
     	LET cCodRet2 = "00002";
	END IF;

END;    

RETURN cCodRet1, cCodRet2;

END PROCEDURE
DOCUMENT
    'AUTOR : Dulce Ramirez',
    'DESCRIPCION: Se encarga de validar si la fecha enviada es un dia habil bancario',
    'EJECUTADO O LLAMADO POR: ',
    'FECHA : MARZO 2011',
    'VERSION: 20110309',
    'BD    : bditef';

CREATE PROCEDURE "informix".sp_validahorariotef()

 RETURNING
 CHAR(5), CHAR(5);

--DEFINICION DE VARIABLES
    DEFINE iSqlErr      INTEGER;
    DEFINE cCodRet1     CHAR (5);
	DEFINE cCodRet2     CHAR (5);
    DEFINE cHoraActual  CHAR (5);
    DEFINE cHoraAParam  CHAR (5);

--INICIALIZACION DE VARIABLES
    LET iSqlErr      = 0;
    LET cCodRet1     = "00000";
	LET cCodRet2     = "00000";
    LET cHoraActual  = "";
	LET cHoraAParam  = "";

    -- SET DEBUG FILE TO "/respaldosbd/Dulce/sp_ValidaHorarioTEF.out";
    -- TRACE ON;


 BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
			RETURN cCodret1, cCodret2;
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
		
    SELECT (CURRENT HOUR TO MINUTE), NVL(valor,'')
    INTO cHoraActual, cHoraAParam
    FROM bditef:"informix".tef_parametros
    WHERE cod_param = "01";
	
	
	IF cHoraActual = "" OR cHoraActual IS NULL OR cHoraAParam = "" OR cHoraAParam IS NULL THEN
	    LET cCodRet2 = "00001";
	ELSE
	    IF CAST(SUBSTR(cHoraActual,1,2) AS INTEGER) > CAST(SUBSTR(cHoraAParam,1,2) AS INTEGER) THEN
			LET cCodRet2 = "00002";  --Esta fuera del horario
		ELSE
			IF CAST(SUBSTR(cHoraActual,1,2)  AS INTEGER) = CAST(SUBSTR(cHoraAParam,1,2) AS INTEGER) THEN
	    					
				IF CAST(SUBSTR(cHoraActual,4,2) AS INTEGER) > CAST(SUBSTR(cHoraAParam,4,2) AS INTEGER) THEN
					LET cCodRet2 = "00002";  --Esta fuera del horario
				END IF;
			END IF;	
		END IF;	
	END IF;

    RETURN cCodret1, cCodret2;

 END;
END PROCEDURE
DOCUMENT
    'AUTOR : Dulce Ramirez',
    'DESCRIPCION: Se encarga de validar si es un horario permitido para las operaciones TEF',
    'EJECUTADO O LLAMADO POR: ',
    'FECHA : MARZO 2011',
    'VERSION: 20110309',
    'BD    : bditef';

CREATE PROCEDURE "informix".sp_validaproductopermitido(pProducto CHAR(4), pNumCte CHAR (9))
 RETURNING
 CHAR(5), DECIMAL(6,2), CHAR (13);

--DEFINICION DE VARIABLES
    DEFINE iSqlErr           INTEGER;
    DEFINE cCodRet           CHAR (5);
    DEFINE cCobraComision    CHAR (1);
	DEFINE dImporteComision  DECIMAL(6,2);
    DEFINE cPermitido        CHAR (1);
	DEFINE cRFC              CHAR (13);

--INICIALIZACION DE VARIABLES
    LET cCodRet            = "00000";
	LET iSqlErr            = 0;
	LET cCobraComision     = "";
	LET dImporteComision   = 0.00;
    LET cPermitido         = "";
	LET cRFC               = "";
	
	
    -- SET DEBUG FILE TO "/respaldosbd/Dulce/sp_ValidaProductoPermitido.out";
    --TRACE ON;

 BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			RETURN cCodRet, dImporteComision, cRFC;
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF pProducto IS NULL OR pProducto = "" OR pNumCte IS NULL OR pNumCte = "" THEN
	    LET cCodRet = "00001";
	    RETURN cCodRet, dImporteComision, cRFC;
	END IF;
	
	SELECT cobra_comision, importe_comision, permitido
	INTO cCobraComision, dImporteComision, cPermitido
    FROM bditef:"informix".tef_prod_permitidos
    WHERE cve_producto = pProducto;
	
	IF cPermitido IS NULL OR cPermitido <> "S" THEN
	    LET cCodRet = "00002"; --NO ES PRODUCTO PERMITIDO
		LET dImporteComision = 0.00;
	ELSE
		IF cCobraComision <> "S" THEN
			LET dImporteComision = 0.00;
		END IF;
		
		SELECT NVL(rfc,'') 
		INTO cRFC
		FROM bdinteg:"informix".si_cliente
        WHERE numcte = pNumCte;

	END IF;
		
		
	RETURN cCodRet, dImporteComision, cRFC;

 END;
END PROCEDURE
DOCUMENT
    'AUTOR : Dulce Ramirez',
    'DESCRIPCION: Se encarga de validar si el producto es permitido, si cobra comision y la cantidad y regresa RFC del cliente',
    'EJECUTADO O LLAMADO POR: ',
    'FECHA : MARZO 2011',
    'VERSION: 20110317',
    'BD    : bditef';

CREATE PROCEDURE "informix".sp_consultarepop_tef
(
psConsClienMovs CHAR(1),
psTipoConsulta CHAR(1),
psDatoBusqueda CHAR(20),
psFechaInicio CHAR(8),
psFechaFin CHAR(8)
)

RETURNING CHAR(5) AS cod_ret, CHAR(10) AS fecha_operacion, CHAR(104) AS no_cuenta, CHAR(13) AS tipo_operacion, CHAR(16) AS importe, CHAR(40) AS referencia, CHAR(81) AS bancorecpres, CHAR(20) AS estatus, CHAR(100) AS causa_rechazo;

--*********************************************************************************************************
-- DESCRIPCION: Realiza consulta por tipo de busqueda Cliente, Cuenta, Tarjeta y movimientos relacionados a las cuentas.
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 2011/04/01
-- BD: bditef
-- SISTEMA : Transferencia Electronica de Fondos
--*********************************************************************************************************

DEFINE vsNoCliente CHAR(9);
DEFINE vsNombre1 CHAR(26);
DEFINE vsNombre2 CHAR(26);
DEFINE vsApellPaterno CHAR(26);
DEFINE vsApellMaterno CHAR(26);
DEFINE vsNombre CHAR(104);
DEFINE vsRFC CHAR(13);
DEFINE vsCuenta CHAR(20);
DEFINE vsTarjeta CHAR(20);
DEFINE vsFechaTrans CHAR(10);
DEFINE vsNumCtaOrdRec CHAR(20);
DEFINE vsCargoAbono CHAR(1);
DEFINE vsImporte CHAR(16);
DEFINE vsFolioSuc CHAR(40);
DEFINE vsBancoRec CHAR(35);
DEFINE vsBancoPres CHAR(35);
DEFINE vsBancoRecPres CHAR(81);
DEFINE vsDescStatPago CHAR(20);
DEFINE vsDescCatRechazo CHAR(100);
DEFINE vsNumTarjeta CHAR(16);

DEFINE viSqlErr INTEGER;
DEFINE vsCodRet CHAR(5);

LET vsNoCliente = "";
LET vsNombre1 = "";
LET vsNombre2 = "";
LET vsApellPaterno = "";
LET vsApellMaterno = "";
LET vsNombre = "";
LET vsRFC = "";
LET vsCuenta = "";
LET vsTarjeta = "";
LET vsFechaTrans = "";
LET vsNumCtaOrdRec = "";
LET vsCargoAbono = "";
LET vsImporte = "";
LET vsFolioSuc = "";
LET vsBancoRec = "";
LET vsBancoPres = "";
LET vsDescStatPago = "";
LET vsDescCatRechazo = "";
LET vsNumTarjeta = "";

LET viSqlErr = 0;
LET vsCodRet = '';

--SET DEBUG FILE TO "/dbexport/sp_consultarepop_tef.sql";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
		RETURN viSqlErr, vsNoCliente, vsNombre, vsRFC, '', '', '', '', '';
	END IF;
END EXCEPTION;
--Consulta clientes.
IF(psConsClienMovs == 1)THEN
	--Consulta por Cuenta
	IF (psTipoConsulta == 1)THEN
		--Verifica que la cuenta sea válida
		IF EXISTS(SELECT {+index (bdicheq:sc_maechq idx_maechq1)} cuenta FROM bdicheq:"informix".sc_maechq WHERE empresa='001' AND cuenta = psDatoBusqueda)THEN
			--Obtiene numero de cliente para despues obtener los datos del cliente.
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT {+index (bdicheq:sc_maechq idx_maechq1)} FIRST 1 num_cte INTO vsNoCliente FROM bdicheq:"informix".sc_maechq WHERE empresa='001' AND cuenta = psDatoBusqueda;
			--Obtiene nombres, apellidos y rfc de cliente.
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT {+index (bdinteg:si_cliente idx_si_cliente5)} FIRST 1 nombre1, nombre2, apell_paterno, apell_materno, rfc
			INTO vsNombre1, vsNombre2, vsApellPaterno, vsApellMaterno, vsRFC
			FROM bdinteg:"informix".si_cliente WHERE empresa='001' AND numcte = vsNoCliente;
			--Se concatenan campos en una sola variable.
			LET vsNombre = TRIM(vsNombre1) || " " || TRIM(vsNombre2) || " " || TRIM(vsApellPaterno) || " " || TRIM(vsApellMaterno);
			LET vsCodRet = '00000';
		--No es una cuenta válida.
		ELSE
			LET vsCodRet = '00001';
		END IF;
	--Consulta por Cliente
	ELIF (psTipoConsulta == 2)THEN
		--Verifica que el número de cliente sea válido
		IF EXISTS(SELECT {+index (bdinteg:si_cliente idx_si_cliente5)} numcte FROM bdinteg:"informix".si_cliente WHERE empresa='001' AND numcte = psDatoBusqueda)THEN
			--Obtiene número de cliente.
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT {+index (bdinteg:si_cliente idx_si_cliente5)} FIRST 1 numcte INTO vsNoCliente FROM bdinteg:"informix".si_cliente WHERE empresa='001' AND numcte = psDatoBusqueda;
			--Obtiene nombres, apellidos y rfc de cliente.
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT {+index (bdinteg:si_cliente idx_si_cliente5)} FIRST 1 nombre1, nombre2, apell_paterno, apell_materno, rfc
			INTO vsNombre1, vsNombre2, vsApellPaterno, vsApellMaterno, vsRFC
			FROM bdinteg:"informix".si_cliente WHERE empresa='001' AND numcte = vsNoCliente;
			LET vsNombre = TRIM(vsNombre1) || " " || TRIM(vsNombre2) || " " || TRIM(vsApellPaterno) || " " || TRIM(vsApellMaterno);
			LET vsCodRet = '00000';
		--No es un número de cliente válido.
		ELSE
			LET vsCodRet = '00001';
		END IF;
	--Consulta por Tarjeta
	ELIF (psTipoConsulta == 4)THEN
		--Verifica que el número de tarjeta sea válido y que sea titular.
		IF EXISTS(SELECT {+index (bdicheq:sc_tarjeta ix_tarjeta2)} num_tarjeta FROM bdicheq:"informix".sc_tarjeta WHERE num_tarjeta = psDatoBusqueda AND empresa = '001' AND tipo_tarjeta = 'T')THEN
			--Obtiene el número de cliente.
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT {+index (bdicheq:sc_tarjeta ix_tarjeta2)} FIRST 1 numcte INTO vsNoCliente FROM bdicheq:"informix".sc_tarjeta WHERE num_tarjeta = psDatoBusqueda AND empresa = '001' AND tipo_tarjeta = 'T';
			--Obtiene nombres, apellidos y rfc de cliente.
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT {+index (bdinteg:si_cliente idx_si_cliente5)} FIRST 1 nombre1, nombre2, apell_paterno, apell_materno, rfc
			INTO vsNombre1, vsNombre2, vsApellPaterno, vsApellMaterno, vsRFC
			FROM bdinteg:"informix".si_cliente WHERE empresa='001' AND numcte = vsNoCliente;
			LET vsNombre = TRIM(vsNombre1) || " " || TRIM(vsNombre2) || " " || TRIM(vsApellPaterno) || " " || TRIM(vsApellMaterno);
			LET vsCodRet = '00000';
		--No es un número de tarjeta válido.
		ELSE
			LET vsCodRet = '00001';
		END IF;
	--Consulta Cuentas
	ELIF (psTipoConsulta == 5)THEN
		--Obtiene cuentas relacionadas a cliente.
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT {+index (bdicheq:sc_maechq mae1)} cuenta INTO vsCuenta FROM bdicheq:"informix".sc_maechq WHERE num_cte = psDatoBusqueda
			RETURN vsCodRet, '', vsCuenta, '', '', '', '', '', '' WITH RESUME;
		END FOREACH;
		--Obtiene cuenta relacionada a tarjeta.
	ELIF (psTipoConsulta == 6)THEN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT {+index (bdicheq:sc_tarjeta ix_tarjeta2)} FIRST 1 cuenta INTO vsCuenta FROM bdicheq:"informix".sc_tarjeta WHERE num_tarjeta = psDatoBusqueda AND empresa = '001' AND tipo_tarjeta = 'T';
		RETURN vsCodRet, '', vsCuenta, '', '', '', '', '', '';
	END IF;
RETURN vsCodRet, vsNoCliente, vsNombre, vsRFC, '', '', '', '', '';
--Consulta movimientos operaciones.
ELIF(psConsClienMovs == 2)THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT {+index (bdicheq:sc_tarjeta ix_tarjeta4)} FIRST 1 num_tarjeta INTO vsNumTarjeta FROM bdicheq:"informix".sc_tarjeta WHERE cuenta = psDatoBusqueda AND empresa = '001'; 
	--Consulta movimientos de cargo.
	IF(psTipoConsulta == 1)THEN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT ccedet.fecha_trans, ccedet.num_cta_ord, 'C', ccedet.importe, ccedet.folio_suc, siban.descripcion, siban1.descripcion, statp.descripcion, catr.descripcion
			INTO vsFechaTrans, vsNumCtaOrdRec, vsCargoAbono, vsImporte, vsFolioSuc, vsBancoRec, vsBancoPres, vsDescStatPago, vsDescCatRechazo
			FROM bditef:"informix".tef_cce_detalle AS ccedet, bdinteg:"informix".si_bancos AS siban, bdinteg:"informix".si_bancos AS siban1, bditef:"informix".tef_status_pago AS statp, bditef:"informix".tef_cat_rechazos AS catr
			WHERE ccedet.cod_operacion = '60'
			AND ccedet.fecha_trans BETWEEN psFechaInicio AND psFechaFin
			AND ccedet.banco_receptor = siban.banco
			AND ccedet.banco_presentador = siban1.banco
			AND ccedet.cve_status = statp.cve_status
			AND ccedet.motivo_dev = catr.cve_rechazo
			AND ((SUBSTRING(ccedet.num_cta_ord FROM 9 FOR 11) = psDatoBusqueda) OR (SUBSTRING(ccedet.num_cta_ord FROM 5 FOR 16) = vsNumTarjeta))
            order by ccedet.fecha_trans, ccedet.importe
			LET vsCodRet = "00000";
			LET vsFechaTrans = SUBSTRING(vsFechaTrans FROM 7 FOR 2) || "/" || SUBSTRING(vsFechaTrans FROM 5 FOR 2) || "/" || SUBSTRING(vsFechaTrans FROM 1 FOR 4);
			LET vsImporte = "$" || round(vsImporte / 100, 2);
			LET vsFolioSuc = TRIM(vsFolioSuc);
			LET vsBancoRecPres = TRIM(vsBancoRec) || "/" || TRIM(vsBancoPres);
			RETURN vsCodRet, vsFechaTrans, vsNumCtaOrdRec, vsCargoAbono, vsImporte, vsFolioSuc, vsBancoRecPres, vsDescStatPago, vsDescCatRechazo WITH RESUME;
		END FOREACH
	--Consulta movimientos de abono.
	ELIF(psTipoConsulta == 2)THEN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT ccedet.fecha_trans, ccedet.num_cta_rec, 'A', ccedet.importe, ccedet.folio_suc, siban.descripcion, siban1.descripcion, statp.descripcion, catr.descripcion
			INTO vsFechaTrans, vsNumCtaOrdRec, vsCargoAbono, vsImporte, vsFolioSuc, vsBancoRec, vsBancoPres, vsDescStatPago, vsDescCatRechazo
			FROM bditef:"informix".tef_cce_detalle AS ccedet, bdinteg:"informix".si_bancos AS siban, bdinteg:"informix".si_bancos AS siban1, bditef:"informix".tef_status_pago AS statp, bditef:"informix".tef_cat_rechazos AS catr
			WHERE ccedet.cod_operacion = '60'
			AND ccedet.fecha_trans BETWEEN psFechaInicio AND psFechaFin
			AND ccedet.banco_receptor = siban.banco
			AND ccedet.banco_presentador = siban1.banco
			AND ccedet.cve_status = statp.cve_status
			AND ccedet.motivo_dev = catr.cve_rechazo
			AND ((SUBSTRING(ccedet.num_cta_rec FROM 9 FOR 11) = psDatoBusqueda) OR (SUBSTRING(ccedet.num_cta_rec FROM 5 FOR 16) = vsNumTarjeta))
            order by ccedet.fecha_trans, ccedet.importe
			LET vsCodRet = "00000";
			LET vsFechaTrans = SUBSTRING(vsFechaTrans FROM 7 FOR 2) || "/" || SUBSTRING(vsFechaTrans FROM 5 FOR 2) || "/" || SUBSTRING(vsFechaTrans FROM 1 FOR 4);
			LET vsImporte = "$" || round (vsImporte / 100, 2);
			LET vsFolioSuc = TRIM(vsFolioSuc);
			LET vsBancoRecPres = TRIM(vsBancoRec) || "/" || TRIM(vsBancoPres);
			RETURN vsCodRet, vsFechaTrans, vsNumCtaOrdRec, vsCargoAbono, vsImporte, vsFolioSuc, vsBancoRecPres, vsDescStatPago, vsDescCatRechazo WITH RESUME;
		END FOREACH
	END IF;
END IF;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Consulta, datos del cliente, cuentas, y movimientos de operaciones TEF.',
'Fecha: 2011/04/01',
'Version: 20110401.1800',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_tef_consnombrenumcte(pEmpresa CHAR(3),
						pNombre1 CHAR(26),
						pNombre2 CHAR(26),
                        pPaterno CHAR(26),
                        pMaterno CHAR(26),
						pFechaNac DATE,
						pNo_Rfc CHAR(13),
						pRazon CHAR(60),
                        pSecuencia SMALLINT)

RETURNING CHAR(5),CHAR(60),CHAR(20),CHAR(13);

DEFINE sql_err 									  INTEGER;
DEFINE v_longitud,v_ciclo 					      SMALLINT;
DEFINE v_nombre_completo 						  CHAR(63);
DEFINE v_nombre1, v_nombre2, v_paterno, v_materno CHAR(26);
DEFINE v_numcte 								  CHAR(20);
DEFINE v_cod_ret 								  CHAR(5);
DEFINE v_razon_soc 								  CHAR(60);
DEFINE v_rfc 									  CHAR(13);

--set debug file to "/dbexport/sp_tef_consnombrenumcte.sql";
--trace on;

LET v_cod_ret = "00000";
LET v_ciclo = 0;
LET v_nombre_completo = "";
LET v_numcte = "0000000000";
LET v_rfc = "";

BEGIN
  ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
   	     LET v_cod_ret = sql_err;
	     RETURN v_cod_ret, v_nombre_completo, v_numcte, v_rfc;
     END IF;
   END EXCEPTION;

IF NVL(pEmpresa,'') = ''  THEN
	LET v_cod_ret = "00001";
	LET v_nombre_completo = 'Parámetros incompletos';
	RETURN v_cod_ret, v_nombre_completo, v_numcte, v_rfc;
END IF;

--Para borrar las tablas temporales en caso de que existan
IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames WHERE tabname = 'tmp_razon_soc') THEN
	DROP TABLE tmp_razon_soc;
END IF;
IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames WHERE tabname = 'tmp_no_rfc') THEN	
	DROP TABLE tmp_no_rfc;
END IF;	
IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames WHERE tabname = 'tmp_fecha_nac') THEN	
	DROP TABLE tmp_fecha_nac;
END IF;	
IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames WHERE tabname = 'tmp_fechanac2') THEN	
	DROP TABLE tmp_fechanac2;
END IF;	

IF pRazon IS NOT NULL AND pRazon !="" THEN
	--Se crea tabla temporal para reducir costos
	SELECT {+index (bdinteg:si_cliente idx_si_cliente5)} 
	razon_social,numcte,rfc
	FROM bdinteg:"informix".si_cliente
	WHERE razon_social = prazon	
	AND empresa='001'
	INTO TEMP tmp_razon_soc
	WITH NO LOG;

    FOREACH
        SELECT razon_social,numcte,rfc
 	    INTO v_razon_soc,v_numcte,v_rfc
        FROM tmp_razon_soc
		ORDER BY numcte
		
        LET v_ciclo = v_ciclo+1;
        IF v_ciclo <= psecuencia THEN
 	        CONTINUE FOREACH;
        END IF;
        
		LET v_nombre_completo = v_razon_soc;
        RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc WITH RESUME;
    END FOREACH;
	DROP TABLE tmp_razon_soc;
ELSE

    IF pNo_Rfc IS NOT NULL AND pNo_Rfc != "" THEN
		--Se crea tabla temporal para reducir costos
        SELECT nombre1,nombre2,apell_paterno,apell_materno,pf.numcte,rfc
		FROM bdinteg:"informix".si_ctepf pf, bdinteg:"informix".si_cliente cl
   	    WHERE rfc = pno_rfc AND cl.numcte = pf.numcte AND empresa = '001'
		INTO TEMP tmp_no_rfc
		WITH NO LOG;
		
        FOREACH
            SELECT nombre1,nombre2,apell_paterno,apell_materno,numcte,rfc
	        INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc
      	    FROM tmp_no_rfc
			ORDER BY numcte
			
      	    LET v_ciclo = v_ciclo+1;
      	    IF v_ciclo <= psecuencia THEN
	           CONTINUE FOREACH;
      	    END IF;
	        
			LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(v_materno)
             || " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
	        RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc WITH RESUME;
        END FOREACH;
		DROP TABLE tmp_no_rfc;
    ELSE

   ---VALIDA PARAMETROS

		IF NVL(pPaterno,'') = '' AND NVL(pMaterno,'') = '' THEN
			LET v_cod_ret = "00002";
			LET v_nombre_completo = 'Debe capturar al menos uno de los dos apellidos';
			RETURN v_cod_ret, v_nombre_completo, v_numcte, v_rfc;
		ELIF NVL(pNombre1,'') = '' AND NVL(pNombre2,'') = '' THEN
			LET v_cod_ret = "00003";
			LET v_nombre_completo = 'Debe capturar al menos uno de los dos nombres';
			RETURN v_cod_ret, v_nombre_completo, v_numcte,v_rfc;
		ELSE

			LET pPaterno = TRIM(pPaterno)||"*";
			LET pMaterno = TRIM(pMaterno)||"*";
			LET pNombre1 = TRIM(pNombre1)||"*";
			LET pNombre2 = TRIM(pNombre2)||"*";

			IF NVL(pFechaNac,'') <> '' THEN
				--Se crea tabla temporal para reducir costos
				SELECT nombre1,nombre2,apell_paterno,apell_materno,cl.numcte,rfc
				FROM bdinteg:"informix".si_ctepf pf, bdinteg:"informix".si_cliente cl
				WHERE cl.apell_paterno matches ppaterno
				AND cl.apell_materno matches pmaterno
				AND cl.nombre1 matches pNombre1
				AND cl.nombre2 matches pNombre2
				AND pf.fecha_nac = pFechaNac
				AND cl.numcte = pf.numcte
				INTO TEMP tmp_fecha_nac
				WITH NO LOG;
			
				FOREACH
					SELECT nombre1,nombre2,apell_paterno,apell_materno,numcte,rfc
					INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc
					FROM tmp_fecha_nac
					ORDER BY apell_paterno, apell_materno, nombre1, nombre2
					
					LET v_ciclo = v_ciclo + 1;

					IF v_ciclo <= psecuencia THEN
						CONTINUE FOREACH;
					END IF;

					LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(v_materno)
							|| " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
					RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc WITH RESUME;
				END FOREACH;
				DROP TABLE tmp_fecha_nac;

		ELSE
				--Se crea tabla temporal para reducir costos
				SELECT {+index (bdinteg:si_cliente idx_si_cliente5)} 
				nombre1,nombre2,apell_paterno,apell_materno,numcte,rfc
				FROM bdinteg:"informix".si_cliente
				WHERE apell_paterno matches ppaterno
				AND apell_materno matches pmaterno
				AND nombre1 matches pNombre1
				AND nombre2 matches pNombre2
				INTO TEMP tmp_fechanac2
				WITH NO LOG;
			FOREACH
				SELECT nombre1,nombre2,apell_paterno,apell_materno,numcte,rfc
				INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc
				FROM tmp_fechanac2
				ORDER BY apell_paterno, apell_materno, nombre1, nombre2

				LET v_ciclo = v_ciclo+1;

				IF v_ciclo <= psecuencia THEN
					CONTINUE FOREACH;
				END IF;

				LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(UPPER(v_materno))
						|| " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
				RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc WITH RESUME;
			END FOREACH;
			DROP TABLE tmp_fechanac2;
		END IF;
        END IF;
    END IF;
END IF;

END;
END PROCEDURE
DOCUMENT
'Consulta clientes por nombre(s) y apellido(s) y por fecha de nacimiento si asi se requiere',
'AUTOR : Dulce Ramirez',
'FECHA : 01/Junio/2009',
'Se modifico para reducir los costos del proceso',
'MODIFICACION: Hector Bojorquez',
'FECHA MODIFICACION: 02/Septiembre/2009',
'Ver.  : 1.1',
'BD    : bdinteg',
'VER   : 1.1';

CREATE PROCEDURE "informix".sp_actualizaestatusimagencheque( pEmpleado CHAR(10), pCodbanco CHAR(3), pCuenta CHAR(20), 
                                                             pNumcheque CHAR(7), pFechapresenta DATE, pLado CHAR(1) )
	RETURNING
		CHAR(6) AS COD_RET;		

		---DECLARACIONES
		DEFINE iSqlErr				INTEGER;    
		DEFINE sNRows				SMALLINT;    
		DEFINE cCodRet         		CHAR(6);
		DEFINE cArchivo      		CHAR(100);
		DEFINE cRuta      			CHAR(60);
				
		---INICIALIZACIONES
		LET iSqlErr            		= 0;
		LET sNRows            		= 0;
		LET cCodRet            		= '000000';
		LET cArchivo            	= '';
		LET cRuta            		= '';

	BEGIN
		
		ON EXCEPTION SET iSqlErr
		   IF iSqlErr != 0 THEN
			  LET cCodRet = iSqlErr;
			  RETURN TRIM (cCodRet);
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/sp_actualizaestatusimagencheque.out';
		--TRACE ON;		
		
		--SE VALIDA QUE TODOS LOS PARAMETROS CONTENGAN VALOR.
		IF NVL(pEmpleado, '') = '' OR NVL(pCodbanco, '') = '' OR NVL(pCuenta, '') = '' OR NVL(pNumcheque, '') = '' OR
		   NVL(pFechapresenta, '') = '' OR NVL(pLado, '') = '' THEN
		   
		    LET cCodRet = '000001'; --FALTA PROPORCIONAR AL MENOS UN PARAMETRO.
			RETURN cCodRet;
			
		END IF;
		
		LET pLado = UPPER(pLado);
		
		--SE VALIDA EL LADO DEL CHEQUE.		
		IF pLado = 'A' OR pLado = 'B' THEN
		
			-- SE TOMA LA RUTA DONDE SE UBICA LA IMAGEN EN BLANCO.
			SELECT TRIM(valor)
			INTO cRuta
			FROM Bdicheq:"informix".sc_param
			WHERE empresa = '001'
			AND codparam = 'path_rpt';

			IF NVL(cRuta, '') = '' THEN
				LET cCodRet = "000002"; --NO EXISTE PARAMETRO.
				RETURN cCodRet;
			END IF;

			--SE FORMA CADENA CON EL NOMBRE DEL ARCHIVO NO DISPONIBLE.
			LET cArchivo = TRIM(cRuta) || "PlantillaChq.jpg";
			
			-- ACTUALIZA STATUS IMAGEN DAÑADA.
			UPDATE Bditef:"informix".cce_reportes_cheques SET
				status_img = 2,
				archivo = TRIM(cArchivo)
			WHERE empleado = pEmpleado 
			AND codbanco = pCodbanco AND cuenta = TRIM(pCuenta) AND numerocheque = TRIM(pNumcheque)
			AND fechapresenta = pFechapresenta AND lado = pLado;

			LET sNRows = dbinfo("sqlca.sqlerrd2");		
			
			IF sNRows = 0 THEN
				LET cCodRet = "000003"; --NO SE REALIZO LA ACTUALIZACION.										
			END IF;
		ELSE
		    LET cCodRet = "000004"; --LADO NO VALIDO.									
		END IF;
			
		RETURN cCodRet;			
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que actualiza el estado de la imagen dañada de un cheque devuelto', 
'AUTOR: Guadalupe Payan ',
'FECHA DE CREACION: 08 de Noviembre del 2011',
'VERSION: 2011108.1101',
'BD: Bditef;';

CREATE PROCEDURE "informix".sp_grabaimageneschqdevueltos( pEmpleado CHAR(10), pCodBanco CHAR(3), pCuenta CHAR(20),
														  pNumCheque CHAR(7), pFechaPresenta DATE, pArchivo CHAR(100),
														  pLado CHAR(1), pStatusImg SMALLINT, pLimpia CHAR(1) )
	-- DATOS A REGRESAR 
    RETURNING
	CHAR(6) AS CodRet,          -- Codigo de Retorno
	CHAR(50) AS MensajeRetorno 	-- Mensaje de Resultados
    
    -- DEFINICION DE VARIABLES 
	DEFINE iSqlErr          INT;
	DEFINE cCodRet          CHAR(5);
	DEFINE cMensaje         CHAR(50);
	
	--INICIALIZACION DE VARIABLES 
	LET iSqlErr 	= 	     0;
	LET cCodRet 	= 	 	'000000';
	LET cMensaje 	=      	'Insercion Exitosa.';
	
   -- SET DEBUG FILE TO "/tmp/sp_grabaimageneschqdevueltos.out";
   -- TRACE ON;

BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			LET cMensaje = 'Error no controlado.';
            RETURN TRIM(cCodRet), TRIM(cMensaje);
        END IF;
    END EXCEPTION;
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- SE VALIDAN TODOS LOS PARAMETROS    
	IF	NVL(pEmpleado, '') = ''      OR NVL(pCodBanco, '') = '' OR NVL(pCuenta, '') = '' OR NVL(pNumCheque, '') = '' OR
		NVL(pFechaPresenta, '') = '' OR NVL(pArchivo, '') = ''  OR NVL(pLado, '') = ''   OR NVL(pStatusImg, 0) = 0   OR
		NVL(pLimpia, '') = '' THEN
		
		LET cCodRet = '000001';
		LET cMensaje = 'Faltan parametros para su ejecucion.';		
	ELSE
		IF pLimpia = '1' THEN
			-- BORRA TODOS LOS REGISTROS QUE SE ENCUENTRAN DEL EMPLEADO QUE ESTA EJECUTANDO EL PROCESO.
			DELETE FROM Bditef:"informix".cce_reportes_cheques WHERE Empleado = pEmpleado;
		END IF;

		-- REGISTRA LAS IMAGENES DE LOS CHEQUES DEVUELTOS
		INSERT INTO Bditef:"informix".cce_reportes_cheques( empleado, codbanco, cuenta, numerocheque, fechapresenta, archivo, lado, status_img )
		VALUES ( TRIM(pEmpleado), TRIM(pCodBanco), TRIM(pCuenta), TRIM(pNumCheque), pFechaPresenta, TRIM(pArchivo), TRIM(pLado), pStatusImg );
		
	END IF;
	
	RETURN TRIM(cCodRet), TRIM(cMensaje);
END;
END PROCEDURE
DOCUMENT
'AUTOR INICIAL: Valentin Lopez',
'DESCRIPCIÓN: Realiza un registro de las imagenes que se descargaron en la pc para generar el reporte',
'FECHA CREACIÓN: 28-Julio-2011 ',
'AUTOR MODIFICACIÓN: Clemente Angulo Ballardo',
'DESCRIPCIÓN MODIFICACIÓN: Se incluyen los nuevos campos de la tabla',
'FECHA DE MODIFICACIÓN: 08 de Noviembre del 2011',
'BD    : Bditef';

CREATE PROCEDURE "informix".sp_consultarimageneschqdevueltos( pEmpleado CHAR(10) )

  -- DATOS A REGRESAR 
    RETURNING
		CHAR(5)   AS CODRET,
		CHAR(50)  AS MENSAJE_EJECUCION,
		CHAR(10)  AS EMPLEADO,
		CHAR(3)   AS CODIGO_BANCO,
		CHAR(20)  AS CUENTA,
		CHAR(7)   AS NUMERO_CHEQUE,
		DATE      AS FECHA_PRESENTA,
		CHAR(100) AS RUTA_ARCHIVO,	
		CHAR(1)   AS LADO_CHEQUE,
		SMALLINT  AS STATUS_IMAGEN;
	
  -- DEFINICION DE VARIABLES 
	DEFINE iSqlErr        	INT;
	DEFINE cCodRet        	CHAR(5);
	DEFINE cMensaje       	CHAR(50);
	
	DEFINE cEmpleado      	CHAR(10);
	DEFINE cCodBanco      	CHAR(3);
	DEFINE cCuenta        	CHAR(20);
	DEFINE cNumChq        	CHAR(7);
	DEFINE dFecPresenta		DATE;
	DEFINE cRutaArchivo   	CHAR(100);	
	DEFINE cLado          	CHAR(1);
	DEFINE sStatusImg      	SMALLINT;
	DEFINE sContador      	SMALLINT;
	
   --INICIALIZACION DE VARIABLES 
	LET iSqlErr 	  = 0;
	LET cCodRet 	  = '000';
	LET cMensaje 	  = 'CONSULTA REALIZADA EXITOSAMENTE';
	LET cEmpleado     = '';	
	LET cCodBanco     = '';
	LET cCuenta       = '';
	LET cNumChq       = '';	
	LET dFecPresenta  = '';
	LET cRutaArchivo  = '';
	LET cLado         = '';		
	LET sStatusImg    = 0;
	LET sContador     = 0;
	
    -- SET DEBUG FILE TO "/tmp/sp_consultarimageneschqdevueltos.out";
    -- TRACE ON;

BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			LET cMensaje = 'ERROR NO CONTROLADO';
            RETURN TRIM(cCodRet), TRIM(cMensaje), TRIM(cEmpleado), TRIM(cCodBanco), TRIM(cCuenta), TRIM(cNumChq), dFecPresenta,
			       TRIM(cRutaArchivo), TRIM(cLado), sStatusImg;
        END IF;
    END EXCEPTION;
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--VALIDA QUE NO VENGA EL PARAMETRO NULO
	IF NVL(pEmpleado, '') = '' THEN
	
	   LET cCodRet = '001';
	   LET cMensaje = 'FALTAN PARAMETROS PARA SU EJECUCION';
	   
	   RETURN TRIM(cCodRet), TRIM(cMensaje), TRIM(cEmpleado), TRIM(cCodBanco), TRIM(cCuenta), TRIM(cNumChq), dFecPresenta,
			  TRIM(cRutaArchivo), TRIM(cLado), sStatusImg;
	ELSE	  
		FOREACH 
			-- OBTIENE UN LISTADO DE LAS IMAGENES DE LOS CHEQUES DEVUELTOS POR EL CLIENTE
			SELECT empleado, codbanco, cuenta, numerocheque, fechapresenta, archivo, lado, status_img
			INTO cEmpleado, cCodBanco, cCuenta, cNumChq, dFecPresenta, cRutaArchivo, cLado, sStatusImg
			FROM Bditef:"informix".cce_reportes_cheques
			WHERE Empleado = pEmpleado
		   
			LET sContador = 1;
		   
			RETURN TRIM(cCodRet), TRIM(cMensaje), TRIM(cEmpleado), TRIM(cCodBanco), TRIM(cCuenta), TRIM(cNumChq), dFecPresenta,
			       TRIM(cRutaArchivo), TRIM(cLado), sStatusImg WITH RESUME;
		   
		END FOREACH;	  
	END IF;
	
	-- VALIDA SI NO SE ENCUENTRAN REGISTROS
    IF sContador = 0 THEN
	
		LET cCodRet = '002';
		LET cMensaje = 'NO EXISTEN IMAGENES DE CHEQUES DEVUELTOS';

		RETURN TRIM(cCodRet), TRIM(cMensaje), TRIM(cEmpleado), TRIM(cCodBanco), TRIM(cCuenta), TRIM(cNumChq), dFecPresenta,
		       TRIM(cRutaArchivo), TRIM(cLado), sStatusImg;
	END IF;	
END;
END PROCEDURE
DOCUMENT
'AUTOR INICIAL: Valentin Lopez',
'DESCRIPCIÓN: Consulta los registros de las imagenes de los cheques devueltos',
'FECHA DE CREACIÓN: 01-Agosto-2011',
'AUTOR MODIFICACIÓN: Clemente Angulo Ballardo',
'DESCRIPCIÓN MODIFICACIÓN: Se incluyen los nuevos campos de la tabla y se corrige uso de bandera',
'FECHA DE MODIFICACIÓN: 08 de Noviembre del 2011',
'BD    : Bditef';

CREATE PROCEDURE "informix".sp_consultageneralcheques(pCveBanco CHAR(3),pNumCuenta CHAR(20),pNumCheque CHAR(7),pFechaPresenta DATE)
	RETURNING
			CHAR(6) 		AS COD_RET, 
			CHAR(3) 		AS CVEBANCO, 
			CHAR(40) 		AS DESCBANCO, 
			CHAR(20) 		AS NUMCUENTA, 
			CHAR(7) 		AS NUMCHEQUE,
			DATE 			AS FECHAPRESENTA, 
			CHAR(20) 		AS NUMCTE, 
			CHAR(20) 		AS CTADEPOSITO, 
			DECIMAL(18, 2) 	AS MONTO, 
			CHAR(2) 		AS MOTIVO,
			CHAR(35) 		AS DESCMOTIVO;	
					
		---DECLARACIONES
		DEFINE iSqlErr				INTEGER;
		DEFINE cCodRet         		CHAR(6);		
		DEFINE cCvebanco			CHAR(3);
		DEFINE cNumCuenta			CHAR(20);
		DEFINE cNumCheque			CHAR(7);
		DEFINE dFechaPresenta		DATE;
		DEFINE cNumCte				CHAR(20);
		DEFINE cCtaDeposito			CHAR(20);
		DEFINE dcMonto			    DECIMAL(18,2);
		DEFINE cMotivo			    CHAR(2);
		DEFINE cDescBanco		    CHAR(40);
		DEFINE cDescMotivo		    CHAR(35);
				
		---INICIALIZACIONES
		LET iSqlErr            		= 0;
		LET cCodRet            		= '000000';								
		LET cCvebanco				= '';
		LET cNumCuenta				= '';
		LET cNumCheque				= '';
		LET dFechaPresenta			= '';
		LET cNumCte					= '';
		LET cCtaDeposito			= '';
		LET dcMonto					= 0.00;
		LET cMotivo					= '';
		LET cDescBanco				= '';
		LET cDescMotivo				= '';		

	BEGIN
		
		ON EXCEPTION SET iSqlErr
		   IF iSqlErr != 0 THEN
			  LET cCodRet = iSqlErr;
			  RETURN TRIM(cCodRet), TRIM(cCvebanco, ''), TRIM(cDescBanco, ''), TRIM(cNumCuenta, ''), TRIM(cNumCheque, ''),
			         dFechaPresenta, TRIM(cNumCte, ''), TRIM(cCtaDeposito, ''), dcMonto, TRIM(cMotivo, ''), TRIM(cDescMotivo, '');
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		---SET DEBUG FILE TO '/tmp/sp_consultageneralcheques.out';
		---TRACE ON;		
		
		--SE VALIDA QUE TODOS LOS PARAMETROS CONTENGAN VALOR.
		IF NVL(pCveBanco, '') = '' OR NVL(pNumCuenta, '') = '' OR NVL(pNumCheque, '') = '' OR NVL(pFechaPresenta, '') = '' THEN
		   
		    LET cCodRet = '000001'; --FALTA PROPORCIONAR ALMENOS UN PARAMETRO.
			
			 RETURN cCodRet, NVL(cCvebanco, ''), NVL(cDescBanco, ''), NVL(cNumCuenta, ''), NVL(cNumCheque, ''),
					dFechaPresenta, NVL(cNumCte, ''), NVL(cCtaDeposito, ''), dcMonto, NVL(cMotivo, ''), NVL(cDescMotivo, '');			
		END IF;
				
		--SE OBTIENE LA INFORMACION DEL CHEQUE.
		SELECT TRIM(cvebanco), TRIM(numcuenta), TRIM(numcheque), fechapresenta, TRIM(cta_deposito), 
			   TRIM(numcte), monto, TRIM(motivo)
		INTO cCvebanco, cNumCuenta, cNumCheque, dFechaPresenta, cCtaDeposito, 
			 cNumCte, dcMonto, cMotivo
		FROM bditef:'informix'.cce_cheques_dev
		WHERE empresa = '001' AND cvebanco = pCveBanco AND numcuenta = pNumCuenta 
			  AND numcheque = pNumCheque AND fechapresenta = pFechaPresenta;
			  
		IF NVL(cCvebanco, '') = '' THEN
			LET cCodRet = "000002"; --NO SE ENCONTRO INFORMACION.						
			RETURN cCodRet, NVL(cCvebanco, ''), NVL(cDescBanco, ''), NVL(cNumCuenta, ''), NVL(cNumCheque, ''), NVL(dFechaPresenta, ''),
			       NVL(cNumCte, ''), NVL(cCtaDeposito, ''), NVL(dcMonto, 0.00), NVL(cMotivo,''), NVL(cDescMotivo,'');
		END IF;

		--SE OBTIENE EL NOMBRE DEL BANCO.
		SELECT TRIM(descripcion) 
		INTO cDescBanco
		FROM bdinteg:"informix".si_bancos
		WHERE banco = cCvebanco;
		
		--SE OBTIENE LA DESCRIPCION DEL MOTIVO.
		SELECT TRIM(descripcion)
		INTO cDescMotivo
		FROM bdinteg:"informix".si_coddevcam
		WHERE sistema_rel = '01'
		AND codigo = cMotivo;

		RETURN cCodRet, NVL(cCvebanco, ''), NVL(cDescBanco, ''), NVL(cNumCuenta, ''), NVL(cNumCheque, ''), NVL(dFechaPresenta, ''),
			   NVL(cNumCte, ''), NVL(cCtaDeposito, ''),NVL(dcMonto, 0.00), NVL(cMotivo, ''), NVL(cDescMotivo, '');		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que consulta la informacion de un cheque', 
'AUTOR: Guadalupe Payan ',
'FECHA: Noviembre 2011',
'VERSION: 20111103.1650',
'BD: Bditef;';

CREATE PROCEDURE "informix".sp_tef_generararchivo60 (psNombre_Archivo CHAR(20),psUsuario CHAR(8))
RETURNING CHAR(5) AS CodRet;

--****************************************************************************************************
-- DESCRIPCION:  GENERA LAS INSTRUCCIONES DE CARGOS PARA FORMAR EL ARCHIVOS 60 Y PREPARA LAS TABLAS PARA QUE LOS VALIDE CCE.
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 16/03/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************

--DEFINICION DE VARIABLES.
DEFINE vdFecha_hoy				DATE;
DEFINE vdFecha_Manana   		DATE;
DEFINE vdFechaEnvioProveedor	DATE;
DEFINE iSQLerr					INTEGER;
DEFINE iExiste					INTEGER;

DEFINE viImporteAux INTEGER;
DEFINE viIva_Tef_Aux INTEGER;

DEFINE vdtFecha_Trans DATETIME YEAR TO FRACTION (5);
DEFINE vsFolio_Suc CHAR(16);
DEFINE vsNum_Serial CHAR(12);
DEFINE vsNum_Cta_Ord CHAR(20);
DEFINE vsTipo_Cta_Ord CHAR(2);
DEFINE vdFecha_Programacion DATE;
DEFINE vsTipo_Operacion CHAR(2);
DEFINE vsClave_Rastreo CHAR(30);
DEFINE vsNombre_Cte_Ord CHAR(30);
DEFINE vsRfc_Cte_Ord CHAR(15);
DEFINE vsImporte_Tef CHAR(10);
DEFINE vsComision_Tef CHAR(5);
DEFINE vsIva_Tef CHAR(5);
DEFINE vsImporte_Tot_Tef CHAR(10);
DEFINE vsTipo_Cta_Ben CHAR(2);
DEFINE vsNombre_Ben CHAR(30);
DEFINE vsNum_Cuenta_Tarj_Ben CHAR(20);
DEFINE vsCve_Banco_Rec CHAR(3);
DEFINE vsRfc_Ben CHAR(15);
DEFINE vsConcepto_Pago CHAR(50);
DEFINE vsRef_Num CHAR(7);
DEFINE vsReferencia CHAR(40);
DEFINE vsCve_Canal CHAR(2);
DEFINE vsCve_Status CHAR(2);
DEFINE vsMotivo_Dev CHAR(2);
DEFINE vsNombre_Arch CHAR(20);
DEFINE vsFecha_Presentacion CHAR(8);
DEFINE vsFecha_Programacion CHAR(8);

DEFINE vsCodRet CHAR(5) ;
DEFINE vsCodRet2 CHAR(5) ;
DEFINE vsCodRet3 CHAR(5) ;
DEFINE vsFecha_Presentacion_Gen CHAR (8);
DEFINE vsFechaManana CHAR (8);
DEFINE vsBancoPresentador CHAR (3);
DEFINE vsCuenta_Clabe_Ord CHAR (20);
DEFINE viContadorSecuencia INTEGER;
DEFINE viImporteTotal INTEGER;

--DEFINE vsBancoPresentador2 CHAR();
DEFINE vsFecha_Programacion2 CHAR(8);
DEFINE vsFecha_Presentacion2 CHAR(8);
DEFINE vsImporte_Tef2 CHAR(10);
DEFINE Num_Cta_Rec2 CHAR(20);
DEFINE vsRfc_Ord2 CHAR(15);
DEFINE vsNum_Cta_Ord2 CHAR(20);
DEFINE vsReferencia2 CHAR(40);
DEFINE vsClave_Rastreo2 CHAR(30);

--TRANSACCIONES
DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER;



--INICIALIZACION DE VARIABLES.

LET viImporteAux = 0;
LET viIva_Tef_Aux = 0;

LET vdtFecha_Trans = CURRENT;
LET vsFolio_Suc = '';
LET vsNum_Serial = '';
LET vsNum_Cta_Ord = '';
LET vsTipo_Cta_Ord = '';
LET vdFecha_Programacion = '';
LET vsTipo_Operacion = '';
LET vsClave_Rastreo = '';
LET vsNombre_Cte_Ord = '';
LET vsRfc_Cte_Ord = '';
LET vsImporte_Tef = '';
LET vsComision_Tef = '';
LET vsIva_Tef = '';
LET vsImporte_Tot_Tef = '';
LET vsTipo_Cta_Ben = '';
LET vsNombre_Ben = '';
LET vsNum_Cuenta_Tarj_Ben = '';
LET vsCve_Banco_Rec = '';
LET vsRfc_Ben = '';
LET vsConcepto_Pago = '';
LET vsRef_Num = '';
LET vsReferencia = '';
LET vsCve_Canal = '';
LET vsCve_Status = '';
LET vsMotivo_Dev = '';
LET vsNombre_Arch = '';
LET vsFecha_Presentacion = '';
LET vsFecha_Programacion = '';


LET vsCodRet = '00000';
LET vsCodRet2 = '00000';
LET vsCodRet3 = '00000';
LET vsFecha_Presentacion_Gen = '';
LET vsFechaManana = '';
LET vsBancoPresentador = '';
LET vsCuenta_Clabe_Ord = '';
LET viContadorSecuencia = 0;
LET viImporteTotal = 0;


LET vsFecha_Programacion2 = '';
LET vsFecha_Presentacion2 = '';
LET vsImporte_Tef2 = '';
LET Num_Cta_Rec2 = '';
LET vsRfc_Ord2 = '';
LET vsNum_Cta_Ord2 = '';
LET vsReferencia2 = '';
LET vsClave_Rastreo2 = '';


--TRANSACCIONES
LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;

--SET DEBUG FILE TO "/tmp/TEF/respuesta/sp_tef_generararchivo60.out";
--TRACE ON;

BEGIN
ON EXCEPTION SET iSQLerr
	IF iSQLerr <> 0 THEN

		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;

		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--REVERSAR LOS ESTATUS DE LA TABLA DE TEF_OPERACIONES
		FOREACH WITH HOLD SELECT Folio_Suc INTO vsFolio_Suc
		FROM BdiTef:"informix".Tef_Cce_Detalle_Paso
		WHERE Nombre_Arch = psNombre_Archivo
		AND Fecha_Presentacion = vsFecha_Presentacion_Gen

			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;

			--ACTUALIZA EL REGISTRO ORIGINAL DE TEF_OPERACIONES Y LO MARCA COMO ENVIADO
			--UPDATE BdiTef:"informix".Tef_Operaciones SET Cve_Status = 'PE'
			UPDATE BdiTef:"informix".Tef_Operaciones SET Cve_Status = 'PE'
			WHERE Fecha_Programacion = vdFecha_Manana
			AND Cve_Status = '00'
			AND Folio_Suc = vsFolio_Suc;

			LET viContadorRegistros = viContadorRegistros + 1;

			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;

		END FOREACH;

		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;


		--BORRA LA TABLA DE PASO PARA EL ARCHIVO 60
		EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist(psNombre_Archivo, vsFecha_Presentacion_Gen, 'B', '') INTO vsCodRet;

		LET vsCodRet = iSQLerr;
		RETURN vsCodRet;
	END IF;
END EXCEPTION;


	ON EXCEPTION IN (-535)
		COMMIT WORK;
	END EXCEPTION WITH RESUME;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	--EXTRAE LA FECHA HOY EN EL SISTEMA
	SELECT FIRST 1 Fecha_hoy INTO vdFecha_hoy FROM BdiCheq:"informix".sc_fechas;

	--AUMENTA UN DIA LA FECHA ACTUAL (PRESENTACION) PARA SER LA FECHA CARGO/PROGRAMACION
	LET vdFecha_Manana = vdFecha_hoy + 1;

	--ASIGNA UN FORMATO DE FECHA PARA FUTURA FECHA DE PRESENTACION
	LET vsFecha_Presentacion_Gen = YEAR(vdFecha_hoy)|| LPAD(MONTH (vdFecha_hoy),2,'0') || LPAD(DAY (vdFecha_hoy),2,'0');


	--VALIDA/PROPORCIONA LA FECHA T+1
	EXECUTE PROCEDURE BdInteg:"informix".sp_Valfecha_Banca('001', vdFecha_Manana, 0 ) INTO vsCodRet2,vdFecha_Manana;
	--VALIDA LA FECHA ACTUAL
	EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Fecha(vsFecha_Presentacion_Gen) INTO vsCodRet3;

	--ASIGNA UN FORMATO DE FECHA
	LET vsFechaManana = YEAR(vdFecha_Manana )|| LPAD(MONTH (vdFecha_Manana ),2,'0') || LPAD(DAY (vdFecha_Manana ),2,'0');

	--VALIDA LA FECHA MANANA
	EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Fecha(vsFechaManana) INTO vsCodRet;

	LET psUsuario = DECODE(TRIM(psUsuario),'', 'informix', TRIM(psUsuario));

	IF (LENGTH(TRIM(psUsuario)) < 8 ) THEN --NUMERO DE EMPLEADO NO CONTIENE LOS 8 DIGITOS REQUERIDOS.
		LET vsCodRet = '01800';
	ELIF (LENGTH(TRIM(psNombre_Archivo)) < 16 ) THEN --NOMBRE DE ARCHIVO NO POSEE LA LONGITUD REQUERIDA   E01bbbA2.A60ddcc
		LET vsCodRet = '01801';
	ELIF (NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '75')) THEN -- Valida que exista el parametro CLAVE BANCARIA BANCOPPEL.
		LET vsCodRet = '01802';
	ELIF (NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '76')) THEN -- Valida que exista el parametro BIN CORRESPONDIENTE TARJETA DEBITO.
		LET vsCodRet = '01803';
	ELIF (vsCodRet <> '00000') THEN -- VALIDA KE LA FECHA MANANA SEA VALIDA
		LET vsCodRet = '01804';
	ELIF (vsCodRet2 <> '000') THEN -- VALIDA KE LA FECHA MANANA SEA UN DIA HABIL
		LET vsCodRet = '01805';
	ELIF (vsCodRet3 <> '00000') THEN -- VALIDA KE LA FECHA HOY SEA VALIDA
		LET vsCodRet = '01806';
	ELIF (NOT EXISTS (SELECT Fecha_Programacion FROM BdiTef:"informix".Tef_Operaciones WHERE Fecha_Programacion = vdFecha_Manana AND Cve_Status = 'PE')) THEN --VALIDA QUE EXISTAN INSTRUCCIONES DE ABONO A CUENTAS DE OTROS BANCOS PENDIENTES PARA EL DIA T+1
		LET vsCodRet = '01807';
	ELSE --OK

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		--OBTIENE LA CLAVE DEL BANCO PRESENTADOR
		SELECT FIRST 1 Valor INTO vsBancoPresentador FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '75';

		--INICIALIZA EL CONTADOR DE LA SECUENCIA EN 1 PARA EL ENCABEZADO
		LET viContadorSecuencia = 1;

		LET viImporteTotal = 0;

		--ENCABEZADO
		INSERT INTO BdiTef:"informix".Tef_Cce_Encabezado_Paso
		(
			Nombre_Arch,
			Fecha_Presentacion,
			Tpo_Registro,
			Num_Secuencia,
			Cod_Operacion,
			Cve_Banco,
			Sentido,
			Servicio,
			Num_Bloque,
			Cod_Divisa,
			Cve_Rechazo_bl,
			Modalidad,
			Uso_Futuro_Ccen,
			Uso_Futuro_Banco,
			User_Insert,
			Fecha_Insert
		)
		VALUES
		(
			NVL(psNombre_Archivo,''),
			NVL(vsFecha_Presentacion_Gen,''),
			'01', --TIPO REGISTRO
			LPAD(viContadorSecuencia,7,'0'), --'0000001', --SECUENCIA
			'60', --ARCHIVO
			NVL(vsBancoPresentador,''), --BANCOPEL 137
			'E', --SENTIDO
			'2', --SERVICIO
			NVL(LPAD(DAY(vdFecha_Hoy),2,'0') || LPAD((SUBSTR(psNombre_Archivo,(LENGTH(TRIM(psNombre_Archivo)) - 1), 2)),5,'0'),''), --NUM BLOQUE
			'01', --DIVISA
			'00',--CVE_RECHAZO_BL
			'2',--MODALIDAD
			LPAD('',41,' '),--USO_FUTURO_CCEN
			LPAD('',370,' '),--USO_FUTURO_BANCO
			psUsuario,
			CURRENT::DATE
		);

		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--OBTIENE LAS INSTRUCCIONES DE ABONO A CUENTAS DE OTROS BANCOS PENDIENTES.
		FOREACH WITH HOLD
		SELECT Fecha_Trans, Folio_Suc, Num_Serial, Num_Cta_Ord, Tipo_Cta_Ord,
		(YEAR(Fecha_Programacion )|| LPAD(MONTH (Fecha_Programacion ),2,'0') || LPAD(DAY (Fecha_Programacion ),2,'0')) AS Fecha_Programacion,
		Tipo_Operacion, Clave_Rastreo,
		Nombre_Cte_Ord, Rfc_Cte_Ord, NVL(Importe_Tef, '0'), Comision_Tef, Iva_Tef, Importe_Tot_Tef, Tipo_Cta_Ben, Nombre_Ben,
		Num_CUenta_Tarj_Ben, Cve_Banco_Rec, Rfc_Ben, Concepto_Pago, Ref_Num, Referencia, Cve_Canal, Cve_Status,
		Motivo_Dev, Nombre_Arch, NVL(Fecha_Presentacion, vsFecha_Presentacion_Gen)
		INTO vdtFecha_Trans, vsFolio_Suc, vsNum_Serial, vsNum_Cta_Ord, vsTipo_Cta_Ord, vsFecha_Programacion, vsTipo_Operacion, vsClave_Rastreo,
		vsNombre_Cte_Ord, vsRfc_Cte_Ord, vsImporte_Tef, vsComision_Tef, vsIva_Tef, vsImporte_Tot_Tef, vsTipo_Cta_Ben, vsNombre_Ben,
		vsNum_Cuenta_Tarj_Ben, vsCve_Banco_Rec, vsRfc_Ben, vsConcepto_Pago, vsRef_Num, vsReferencia, vsCve_Canal, vsCve_Status,
		vsMotivo_Dev, vsNombre_Arch, vsFecha_Presentacion
		FROM BdiTef:"informix".Tef_Operaciones
		WHERE Fecha_Programacion = vdFecha_Manana
		AND Cve_Status = 'PE'
		ORDER BY vsNum_CUenta_Tarj_Ben, Importe_Tef ASC

			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;


			IF (NOT (vsFecha_Programacion2 = vsFecha_Programacion
				AND vsFecha_Presentacion2 = vsFecha_Presentacion
				AND vsImporte_Tef2 = vsImporte_Tef
				AND Num_Cta_Rec2 = vsNum_Cuenta_Tarj_Ben
				AND vsRfc_Ord2 = vsRfc_Cte_Ord
				AND vsNum_Cta_Ord2 = vsNum_Cta_Ord
				AND vsReferencia2 = vsReferencia
				AND vsClave_Rastreo2 = vsClave_Rastreo
			)) THEN --VALIDA SI ES DISTINTO DEL REGISTRO ANTERIOR -- DISTINTO CONTINUA   IGUAL LO OMITE

				--ACTUALIZA LOS VALORES PARA LA COMPARACION DEL SIGUIENTE REGISTRO
				LET vsFecha_Programacion2 = vsFecha_Programacion;
				LET vsFecha_Presentacion2 = vsFecha_Presentacion;
				LET vsImporte_Tef2 = vsImporte_Tef;
				LET Num_Cta_Rec2 = vsNum_Cuenta_Tarj_Ben;
				LET vsRfc_Ord2 = vsRfc_Cte_Ord;
				LET vsNum_Cta_Ord2 = vsNum_Cta_Ord;
				LET vsReferencia2 = vsReferencia;
				LET vsClave_Rastreo2 = vsClave_Rastreo;


				--AUMENTA EL CONTADOR DE LA SECUENCIA
				LET viContadorSecuencia = viContadorSecuencia + 1;


				--ACUMULA LOS IMPORTES DE TODAS LAS TRANSACCIONES
				LET viImporteAux = NVL(vsImporte_Tef, '0') * 100;
				LET viIva_Tef_Aux = NVL(vSIva_Tef, '0') * 100;
				LET viImporteTotal = viImporteTotal + viImporteAux;



				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				--OBTIENE LA CUENTA CLABE
				SELECT NVL(Cuenta_Clabe, '000') INTO vsCuenta_Clabe_Ord
				FROM BdiCheq:"informix".Sc_Maechq
				WHERE Empresa = '001' AND Cuenta = TRIM(vsNum_Cta_Ord); --SUBSTR(vsNum_Cta_Ord,9,11) ;

				--GUARDA EL REGISTRO DE LA INTRUCCION DE CARGO EN LA TABLA DE PASO
				INSERT INTO BdiTef:"informix".Tef_Cce_Detalle_Paso
				(
					Nombre_Arch,
					Fecha_Presentacion,
					Tipo_Registro,
					Num_Secuencia,
					Cod_Operacion,
					Cod_Divisa,
					Fecha_Trans,
					Banco_Presentador,
					Banco_Receptor,
					Importe,
					Uso_Futuro_Ccen,
					Tipo_Operacion,
					Fecha_Aplica,
					Tipo_Cta_Ord,
					Num_Cta_Ord,
					Nombre_Ord,
					Rfc_Ord,
					Tipo_Cta_Rec,
					Num_Cta_Rec,
					Nombre_Rec,
					Rfc_Rec,
					Ref_Servicio,
					Nombre_Titular_Serv,
					Importe_Iva,
					Ref_Numerica,
					Ref_Leyenda,
					Clave_Rastreo,
					Motivo_Dev,
					Fecha_Pres_Ini,
					Solicitud_Confirmacion,
					Uso_Futuro_Banco,
					Ref_Confirmacion,
					Uso_Futuro_Cce,
					Tasa_Tiie_Prom,
					Dias_Retraso,
					Imp_Tot_Int,
					Cve_Status,
					Folio_Suc,
					User_Insert,
					Fecha_Insert
				)
				VALUES
				(
					NVL(psNombre_Archivo,''),
					NVL(vsFecha_Presentacion_Gen,''),
					'02', --TIPO REGISTRO
					NVL(LPAD(viContadorSecuencia,7,'0'),''),--NUM_SECUENCIA
					'60', --TIPO ARCHIVO
					'01', --DIVISA
					NVL(vsFechaManana,''), --FECHA_TRANS
					NVL(vsBancoPresentador,''), --BANCO_PRESENTADOR
					NVL(vsCve_Banco_Rec,''), --BANCO_RECEPTOR
					NVL(LPAD ((viImporteAux), 15, '0'),''), -- IMPORTE
					LPAD('',16,' '), -- USO_FUTURO_CCE
					NVL(vsTipo_Operacion,''), --'60', --TIPO OPERACION
					NVL(vsFecha_Programacion,''), --vsFecha_Presentacion_Gen, --FECHA APLICACION
					NVL(vsTipo_Cta_Ord,''),			--'40',  --TIPO CUENTA ORDENANTE ----??????
					NVL(LPAD(TRIM(vsCuenta_Clabe_Ord),20,'0'),''), --NUM_CTA_ORD
					NVL(vsNombre_Cte_Ord,''), --NOMBRE CLIENTE ORD
					NVL(vsRfc_Cte_Ord,''), --RFC ORDENANTE
					NVL(vsTipo_Cta_Ben,''), --TIPO_CTA_REC
					NVL(LPAD(TRIM(vsNum_Cuenta_Tarj_Ben),20,'0'),''), -- NUM_CTA_REC
					NVL(vsNombre_Ben,''), --NOMBRE_REC
					NVL(vsRfc_Ben,''), -- RFC_REC
					LPAD('',40,' '), --REF_SERVICIO
					LPAD('',40,' '), --NOMBRE_TITULAR
					NVL(LPAD(viIva_Tef_Aux, 15, '0'),''), --IMPORTE IVA
					NVL(vsRef_Num,''), --REF_NUMERICA
					NVL(vsConcepto_Pago,''), --REF_LEYENDA
					NVL(vsClave_Rastreo,''),--CLAVE_RASTREO
					NVL(vsMotivo_Dev,''), --MOTIVO_DEVOLUCION
					NVL(vsFecha_Presentacion,''), --FECHA_PRESENTACION
					'1', --SOLICITUD CONFIRMACION (1)
					LPAD('',11,' '), --USO FUTURO  BANCO
					LPAD('',30,' '), --CONFIRMACION
					LPAD('',1,' '), --USO_FUTURO_CCE
					LPAD('',7,' '), --TASA TIIE PROM
					LPAD('',3,' '), --DIAS_RETRASO
					LPAD('',15,' '), --IMP_TOT_INT
					'00', --CVE_STATUS
					NVL(vsFolio_Suc,''), -- FOLIO_SUC
					NVL(psUsuario,''), --USUARIO_INSERT
					CURRENT::DATE --FECHA_INSERT
				);

				--ACTUALIZA EL REGISTRO ORIGINAL DE TEF_OPERACIONES Y LO MARCA COMO ENVIADO
				UPDATE BdiTef:"informix".Tef_Operaciones SET Cve_Status = '00', Fecha_Presentacion = vsFecha_Presentacion, nombre_arch = psNombre_Archivo
				--WHERE Fecha_Programacion = vdFecha_Manana
				where Cve_Status = 'PE'
				AND Fecha_Trans = vdtFecha_Trans
				AND Folio_Suc = vsFolio_Suc
				AND Num_Serial = vsNum_Serial
				AND Num_Cta_Ord = vsNum_Cta_Ord;

			END IF;

			LET viContadorRegistros = viContadorRegistros + 1;

			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;

		END FOREACH;

		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;

		--INCREMENTA EL CONTADOR DE LA SECUENCIA PARA EL SUMARIO
		LET viContadorSecuencia = viContadorSecuencia + 1;

		--SUMARIO
		INSERT INTO BdiTef:"informix".Tef_Cce_Sumario_Paso
		(
			Nombre_Arch,
			Fecha_Presentacion,
			Tipo_Registro,
			Num_Secuencia,
			Cod_Operacion,
			Num_Bloque,
			Num_Operaciones,
			Imp_Operaciones,
			Uso_Futuro_ccen,
			Uso_Futuro_banco,
			User_Insert,
			Fecha_Insert
		)
		VALUES
		(
			NVL(psNombre_Archivo,''), --NOMBRE_ARCH
			NVL(vsFecha_Presentacion_Gen,''), --FECHA_PRESENTACION
			'09', --TIPO_REGISTRO
			NVL(LPAD(viContadorSecuencia,7,'0'),''),--NUM_SECUENCIA
			'60', --COD_OPERACION
			NVL(LPAD(DAY(vdFecha_Hoy),2,'0') || LPAD((SUBSTR(psNombre_Archivo,(LENGTH(TRIM(psNombre_Archivo)) - 1), 2)),5,'0'),''), --NUM BLOQUE
			NVL(LPAD((viContadorSecuencia-2),7,'0'),''),--NUM_OPERACIONES -- REGISTROS EN EL DETALLE
			NVL(LPAD(viImporteTotal,18,'0'),''),--IMPORTE TOTAL DE OPERACIONES
			LPAD('',40,' '),--USO_FUTURO_CCEN
			LPAD('',364,' '),--USO_FUTURO_BANCO
			psUsuario, --USUARIO_INSERT
			CURRENT::DATE --FECHA_INSERT
		);

		LET vsCodRet = '00000'; --OK

	END IF;

	RETURN vsCodRet;

END
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: GENERA LAS INSTRUCCIONES DE CARGOS PARA FORMAR EL ARCHIVOS 60 Y PREPARA LAS TABLAS PARA QUE LOS VALIDE CCE.',
'Fecha: 2011/03/16',
'Version: 20110316.1220',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_validaimagencheque(pCveBanco CHAR(3), pCuenta CHAR(20),pNumCheque CHAR(7)) 
RETURNING  CHAR(5) ,CHAR(50), CHAR(3);

DEFINE cCodRet 			CHAR(5);
DEFINE iSqlErr 			INTEGER;
DEFINE cMensaje         CHAR(50);
DEFINE cImagen	        BLOB;
DEFINE iTamImg          INTEGER;
DEFINE cImgFormato 			CHAR(3);


LET cCodRet 			= '00000';
LET cMensaje            = 'Ejecucion Exitosa';
LET iTamImg			    = 0;
LET cImgFormato 		= '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			RETURN cCodRet,cMensaje,cImgFormato;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/respaldosbd/VLV/sp_ValidaImagenCheque.out";
	--TRACE ON;	 
	
	IF pCuenta = '' OR pNumCheque = '' OR pCveBanco = '' THEN
		LET cCodRet = '00001';
		LET cMensaje = 'Faltan Parametros para su ejecucion';
		LET cImgFormato 		= '';
		RETURN cCodRet,cMensaje,cImgFormato;
	END IF;
	
	SELECT FIRST 1 Imagen, imagen_tam, imagen_formato
	INTO cImagen, iTamImg, cImgFormato
	FROM  bditef:cce_cheques_img	
	WHERE numcuenta = pCuenta	
	AND cvebanco= pCveBanco
	AND numcheque = pNumCheque
	AND empresa='001';
	
	IF cImagen IS NULL THEN
		LET cCodRet = '00002';
		LET cMensaje = 'No existe la imagen del cheque';
		LET cImgFormato 		= '';
	   RETURN cCodRet,cMensaje,cImgFormato;
	END IF;
	
	RETURN cCodRet,cMensaje,cImgFormato;
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Verifica si existe la imagen del cheque en la tabla cce_cheques_img', 
'AUTOR: Valentin Lopez',
'FECHA: 15 de Febrero del 2011',
'VERSION: 20110215.1745',
'BD: BDITEF';

CREATE PROCEDURE "informix".sp_validaimagencheque_dev(pCveBanco CHAR(3), pCuenta CHAR(20), pNumCheque CHAR(7), pLadoFt CHAR(1), dFechaPresenta DATE) 
	RETURNING
		CHAR(5)	  AS COD_RET,
		CHAR(50)  AS MENSAJE_EJECUCION,
		CHAR(3)   AS FORMATO_IMG;

	--DECLARACION DE VARIABLES.
	DEFINE cCodRet 			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cMensaje         CHAR(50);
	DEFINE bImagen	        BLOB;
	DEFINE cImgFormato 		CHAR(3);
	DEFINE cCveBanco 		CHAR(3);
	DEFINE cNumCheque 		CHAR(7);
	
	--INICIALIZACION DE VARIABLES.
	LET cCodRet 			= '00000';
	LET iSqlErr          	= 0;
	LET cMensaje            = 'EJECUCION EXITOSA';
	LET bImagen  			= NULL;
	LET cImgFormato 		= '';
	LET cCveBanco			= '';
	LET cNumCheque			= '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = 'ERROR NO CONTROLADO';
				RETURN TRIM(cCodRet), TRIM(cMensaje), TRIM(cImgFormato);
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
		
		-- SET DEBUG FILE TO "/tmp/sp_validaimagencheque_dev.out";
		-- TRACE ON;	 
		
		IF NVL(pCuenta, '') = '' OR NVL(pNumCheque, '') = '' OR NVL(pCveBanco, '') = '' OR NVL(pLadoFt, '') = '' OR
		   NVL(dFechaPresenta, '') = '' THEN
			LET cCodRet = '00001';
			LET cMensaje = 'FALTAN PARAMETROS PARA SU EJECUCION';			
			RETURN cCodRet, TRIM(cMensaje), TRIM(cImgFormato);
		END IF;
		
		--SE OBTIENE EL FORMATO DE LA IMAGEN.
		SELECT cvebanco, imagen, imagen_formato
		INTO cCveBanco, bImagen, cImgFormato
		FROM bditef:"informix".cce_cheques_img	
		WHERE cvebanco = pCveBanco AND numcuenta = pCuenta
		  AND numcheque = pNumCheque AND lado_ft = pLadoFt
		  AND fechapresenta = dFechaPresenta;
				
		--SE VALIDA QUE EXISTA EL REGISTRO DE LA IMAGEN.
		IF NVL(cCveBanco, '') = '' THEN	
			
			LET cCodRet = '00002';
			LET cMensaje = 'NO EXISTE EL REGISTRO DEL CHEQUE';
			LET cImgFormato = '';
			RETURN cCodRet, TRIM(cMensaje), TRIM(cImgFormato);				
			
		END IF;
				
		--SE VALIDA SI EXISTE LA IMAGEN.		
		IF bImagen IS NULL Then 		
			--SE DETERMINA QUE LA IMAGEN NO EXISTE.				  			
			LET cCodRet = '00003';
			LET cMensaje = 'NO EXISTE IMAGEN DEL CHEQUE';
			LET cImgFormato = '';
			
		End If 
													
		RETURN cCodRet, TRIM(cMensaje), TRIM(cImgFormato);
		
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Verifica si existe la imagen del cheque en la tabla cce_cheques_img', 
'AUTOR: Valentin Lopez',
'FECHA DE CREACION: 15 de Febrero del 2011',
'VERSION: 20110215.1745',
'MODIFICACION: Se incluyo validacion para saber si el cheque tiene detalle', 
'MODIFICO: Guadalupe Payan',
'FECHA DE MODIFICACION: 04 de Noviembre del 2011',
'VERSION: 20111104.1306',
'MODIFICACION: Se quito la validacion para saber si el cheque tiene detalle ya que se determino que no era necesario por logica del procedimiento', 
'MODIFICO: Guadalupe Payan',
'FECHA DE MODIFICACION: 08 de Noviembre del 2011',
'VERSION: 20111108.1700',
'BD: BDITEF';

CREATE PROCEDURE "informix".sp_obtbines_sif(pTarjeta CHAR(20))
RETURNING CHAR(5) AS COD_RET,
		  CHAR(100)AS COD_MENS,
		  CHAR(3)AS CVE_BCO;

--DECLARACION DE VARIABLES
DEFINE cCodRet CHAR(5);
DEFINE cCodRet1 CHAR(5);
DEFINE cMensaje CHAR(100);
DEFINE iSqlErr INTEGER ;
DEFINE cBanco CHAR(3);
DEFINE cTipo CHAR(1);

--INICIALIZAR VALORES A VARIABLES;
LET cCodRet='00000';
LET cCodRet1='00000';
LET cMensaje='PROCESO EXITOSO';
LET iSqlErr=0;
LET cBanco='';
LET cTipo='';

BEGIN
	ON EXCEPTION SET iSqlErr
	  IF iSqlErr <> 0 THEN
			let cCodRet = iSqlErr;
			RETURN cCodRet,cMensaje,cBanco;
	  END IF ;
	END EXCEPTION ;
	
	IF NVL(pTarjeta,"") = "" THEN
		LET cCodRet='00001';
		LET cMensaje ="Faltan parámetros de entrada, verifique...";		
	ELSE
		LET pTarjeta = SUBSTR(pTarjeta,1,6);
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT creditodebito,cve_banco INTO cTipo,cBanco FROM  bdicheq:"informix".sc_bines WHERE bin= TRIM(pTarjeta);
		IF(cTipo<>'')THEN
			IF(cTipo='d')THEN
				LET cCodRet='00000';			
				LET cMensaje ="PROCESO EXITOSO";
			END IF;
			IF(cTipo='c')THEN
				LET cCodRet='00002';
				EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret("01","574")
								INTO cCodRet1,cMensaje;		
			END IF;
		ELSE
				LET cCodRet='00003'; --No existe el bin
				LET cMensaje ="Tarjeta invalida, verifique.";
		END IF
	  -- Valida que la tarjeta no sea Bancoppel
		IF TRIM(cBanco) = "137" THEN
			LET cCodRet='00004';
			EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret("01","572")
								INTO cCodRet1,cMensaje;						
		END IF
	END IF
	
	RETURN cCodRet,cMensaje,cBanco;
	
END;
END PROCEDURE
DOCUMENT
'AUTOR: Jesús Manuel Aguilar Heredia',
'DESCRIPCION: Procedimiento que valida el bin de la tarjeta y obtiene la clave del banco.',
'FECHA: Julio 2012',
'BASE DE DATOS: BDITEF',
'VERSION: 20120730.1105';

CREATE PROCEDURE "informix".sp_tef_buscaoperacion(pfecha DATE,
												  pSucursal CHAR(4),
												  pEjecutivo CHAR(8),
												  pFolioSuc VARCHAR(16))  
RETURNING
CHAR(6) 		AS cod_ret,
VARCHAR(80) 	AS desc_ret,
VARCHAR(16) 	AS folio_suc,
VARCHAR(20)		AS num_cta_ord, 
VARCHAR(40)		AS referencia,
CHAR(10)		AS importe_tef, 
CHAR(2)		    AS reversado;  

---DECLARACIONES
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			VARCHAR(80);
DEFINE cCodRet				CHAR(6);
DEFINE cMensajeRet			VARCHAR(80);

DEFINE cFolioSuc			VARCHAR(16);
DEFINE cNumCtaOrd			VARCHAR(20);
DEFINE cReferencia			VARCHAR(40);
DEFINE cImporte			    CHAR(10);
DEFINE cReversado			CHAR(2);
	
---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '000000';
LET cMensajeRet			= 'PROCESO EXITOSO';

LET cFolioSuc			= '';
LET cNumCtaOrd			= '';
LET cReferencia			= '';
LET cImporte			= '';
LET cReversado			= '';


	
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, TRIM(cMensajeRet),'','','','','';
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_tef_buscaoperacion.out';
	--TRACE ON;


	-- VALIDA QUE LOS parámetros NO VENGAN VACIOS
    IF NVL(pfecha,"") = "" OR NVL(pSucursal,"") = "" OR NVL(pEjecutivo,"") = "" OR NVL(pFolioSuc,"") = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Falta uno o mas parámetros';
	ELSE
		IF pfecha::DATE <> (SELECT fecha_hoy FROM  bdicheq:"informix".sc_fechas) THEN
			LET cCodRet = '000002';
			LET cMensajeRet = 'Fecha invalida, verifique...';
		ELSE
			IF EXISTS (SELECT folio_suc FROM bditef:"informix".tef_operaciones
					   WHERE fecha_trans = pfecha AND folio_suc = pFolioSuc
						AND sucursal = pSucursal AND user_insert = pEjecutivo) THEN
						
				SELECT folio_suc, num_cta_ord, referencia, importe_tef, DECODE(cve_status,"PE","N","05","S","")
					INTO cFolioSuc,cNumCtaOrd,cReferencia,cImporte,cReversado
				FROM bditef:"informix".tef_operaciones
				WHERE fecha_trans = pfecha
				AND folio_suc = pFolioSuc
				AND sucursal = pSucursal
				AND user_insert = pEjecutivo;
			ELSE
				LET cCodRet = '000003';
				LET cMensajeRet = 'No se encuentran registros en base a los datos indicados. Favor de validar.';
			END IF			
		END IF
    END IF;	

	RETURN cCodRet, TRIM(cMensajeRet),TRIM(cFolioSuc),TRIM(cNumCtaOrd),TRIM(cReferencia),TRIM(cImporte),cReversado;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para obtener la informacion de alta operaciones TEF en central, para ser reversados', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120626.1021';

CREATE PROCEDURE "informix".sp_tef_grabaoperacion(  pTipo CHAR(1), 
													pEmpresa CHAR(3),
													pFecha_Trans DATE,
													pFolio_Suc CHAR(16),
													pSucursal CHAR(4), 
													pNum_Cta_Ord CHAR(20),
													pTipo_Cta_Ord CHAR(2),
													pFecha_Prog DATE,
													pTipo_Oper CHAR(2),
													pCve_Rastreo CHAR(30),
													pNombre_Cte_Ord CHAR(30),
													pRfc_Cte_Ord CHAR(15),
													pImp_Tef CHAR(10),
													pComision_Tef CHAR(5),
													pIva_Tef CHAR(5),
													pImp_Tot_Tef CHAR(10),
													pTipo_Cta_Ben CHAR(2),
													pNombre_Ben CHAR(30),
													pNum_Cta_Tarj_Ben CHAR(20),
													pCve_Banco_Rec CHAR(3),
													pRfc_Ben CHAR(15),
													pConcep_Pago CHAR(50),
													pRef_Num CHAR(7),
													pReferencia CHAR(40),
													pCve_Canal CHAR(2),
													pMotivo_Dev CHAR(2), 
													pDivisa CHAR(2),
													pTransacSuc CHAR(4),
													pNumTarjeta  CHAR(16),
													pUsuario CHAR (8))				
 RETURNING
CHAR(6) 		AS cod_ret,
VARCHAR(100) 	AS desc_ret;

--DEFINICION DE VARIABLES
DEFINE iSqlErr       INTEGER;
DEFINE cCodRet1      CHAR (6); --Código Retorno
DEFINE cCodRet2      CHAR (6); --Código Retorno controlado para arma envios
DEFINE cCodRet3      CHAR (6); --Código Retorno 1 para sp de parámetros
DEFINE cNumSerial    CHAR (12);

DEFINE cTrans        CHAR(4);
DEFINE dtFecha        DATE;
DEFINE mSaldo        MONEY(14,2);
DEFINE mMonto        MONEY(14,2);
DEFINE iTransaccion  INTEGER;
DEFINE cTranscargo   CHAR(4);
DEFINE cComis        CHAR(4);
DEFINE cIvaComis     CHAR(4);
DEFINE cNumTran      CHAR(4);
DEFINE cMensaje      CHAR(100);
DEFINE cMensajeRet	 VARCHAR(100);

DEFINE cCodretVal   CHAR(5);
DEFINE cTpo_Proc CHAR(1); 
DEFINE cFech_Proc CHAR(10);
DEFINE cCve_Proc CHAR(20);
DEFINE cDescripcion CHAR(60);
DEFINE cEstatus CHAR(1);

--INICIALIZACION DE VARIABLES
LET iSqlErr      = 0;
LET cCodRet1     = "00000";
LET cCodRet2     = "00000";
LET cCodRet3     = "000000";

LET cNumSerial   = "";

LET iTransaccion = 0;
LET cTrans       = "";
LET dtFecha       = '01/01/1900';
LET mSaldo       = 0.00;
LET mMonto       = 0.00;
LET cTranscargo  = "";
LET cComis       = "";
LET cIvaComis    = "";
LET cNumTran     = "";
LET cMensaje     = "";
LET cMensajeRet	 = 'PROCESO EXITOSO';
    
LET cCodretVal   = "";
LET cTpo_Proc    = "";
LET cFech_Proc   = "";
LET cCve_Proc    = "";
LET cDescripcion = "";
LET cEstatus     = "";
	
--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_tef_grabaoperacion.out';
--TRACE ON;
 BEGIN
	
	ON EXCEPTION SET iSqlErr --Manejador de Errores
        IF iSqlErr <> 0 then
            LET cCodRet1 = iSqlErr;
            IF iTransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            RETURN cCodRet1, "Error de informix";
        END IF;
    END EXCEPTION;
	
	
	
    ON EXCEPTION IN (-535)
        LET iTransaccion = 1;
    END EXCEPTION WITH RESUME;

    IF iTransaccion = 1 THEN
         COMMIT WORK;
         BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF NVL(pFecha_Trans,"") = "" OR NVL(pFolio_Suc,"") = "" OR NVL(pSucursal,"") = "" OR NVL(pNum_Cta_Ord,"") = "" OR
	   NVL(pTipo_Cta_Ord,"") = "" OR NVL(pFecha_Prog,"") = "" OR  NVL(pTipo_Oper,"") = "" OR NVL(pCve_Rastreo,"") = "" OR
	   NVL(pNombre_Cte_Ord,"") = "" OR NVL(pRfc_Cte_Ord,"") = "" OR  NVL(pImp_Tef,"") = "" OR NVL(pComision_Tef,"") = "" OR
	   NVL(pIva_Tef,"") = "" OR NVL(pImp_Tot_Tef,"") = "" OR NVL(pTipo_Cta_Ben,"") = "" OR NVL(pNombre_Ben,"") = "" OR
	   NVL( pNum_Cta_Tarj_Ben,"") = "" OR NVL(pConcep_Pago,"") = "" OR  NVL(pRef_Num,"") = ""  OR NVL(pCve_Canal,"") = "" OR
	   NVL(pMotivo_Dev ,"")= "" OR NVL(pUsuario,"") = "" OR NVL(pReferencia,"") = "" THEN
		   LET cCodRet1 = "000004";
		   LET cMensajeRet = "Parámetros invalidos, verifique...";
		   RETURN cCodRet1, TRIM(cMensajeRet);			
	END IF;
	
	
	SELECT TRIM(valor) 
	INTO cTranscargo  --transacción cargo
	FROM bditef:"informix".tef_parametros
	WHERE cod_param = '06';	
	SELECT fecha_hoy INTO dtFecha FROM  bdicheq:"informix".sc_fechas;
	
	IF cTranscargo IS NULL OR cTranscargo = '' THEN
		LET cCodRet1 = '000001'; --Falta parámetros de transacción cargo.
		LET cMensajeRet = "Falta parámetros de transacción cargo, verifique...";
		RETURN cCodRet1, TRIM(cMensajeRet);
	END IF;	
	
	EXECUTE PROCEDURE  bditef:"informix".sp_tef_validahorario(CURRENT HOUR TO SECOND)
		INTO cCodRet3, cMensaje;
	IF CAST(cCodRet3 AS INTEGER) <> 0 THEN
		LET cCodRet1 = "000002";
		LET cMensajeRet = cMensaje;	
	ELSE	
	    EXECUTE PROCEDURE sp_tef_validarchcod60('', "GENARCH_60.01") 
		INTO cCodretVal, cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus;		
		
		IF cCodretVal::integer <> 0 THEN					
			LET cCodRet1 = '000003';
			LET cMensajeRet = 'No es posible registrar la operación TEF. El proceso de generación de archivo ya ha iniciado.';							
		ELSE	
				
			IF pTipo = 1 THEN --Aplicar cargo			
				
					--validar si se va a cobrar comisión
				
					SELECT TRIM(valor)  
					INTO cComis --transacción cargo comisión
					FROM bditef:"informix".tef_parametros
					WHERE cod_param = '07';
				
					IF cComis IS NULL OR cComis = '' THEN
						LET cCodRet1 = '000005'; --Falta parámetros de transacción comisión.
						LET cMensajeRet = "Falta parámetros de transacción comisión, verifique...";
						RETURN cCodRet1, TRIM(cMensajeRet);
					END IF;
						
					SELECT TRIM(valor)  
					INTO cIvaComis --transacción cargo iva
					FROM bditef:"informix".tef_parametros
					WHERE cod_param = '08';
					
					IF cIvaComis IS NULL OR cIvaComis = '' THEN
						LET cCodRet1 = '000006'; --Falta parámetros de transacción iva.
						LET cMensajeRet = "Falta parámetros de transacción iva, verifique...";
						RETURN cCodRet1, TRIM(cMensajeRet);
					END IF;
					
					---Se aplica cargo por importe operación TEF
					EXECUTE PROCEDURE bdicheq:"informix".cargo_ref (pEmpresa, pSucursal, pUsuario, cTranscargo, pTransacSuc, pFolio_Suc, pNum_Cta_Ord, 0,  pImp_Tef,  pDivisa, pCve_Rastreo, pNumTarjeta, pUsuario)
					INTO cCodRet2, cTrans, dtFecha, mSaldo, mMonto;
					IF CAST(cCodRet2 AS INT) <> 0 THEN
						IF iTransaccion = 1 THEN
							ROLLBACK WORK;
							BEGIN WORK;
						ELSE
							ROLLBACK WORK;
						END IF;
						EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret("01",cCodRet2)
						INTO cCodRet1,cMensajeRet;
					ELSE
						---Se aplica cargo por comisión en caso de que la comisión sea mayor que 0
						
						
						IF CAST(pComision_Tef AS MONEY(14,2)) > 0 THEN
							EXECUTE PROCEDURE bdicheq:"informix".cargo_ref (pEmpresa, pSucursal, pUsuario, cComis, pTransacSuc, pFolio_Suc, pNum_Cta_Ord, 0, pComision_Tef, pDivisa, pCve_Rastreo, pNumTarjeta, pUsuario)
							INTO cCodRet2, cTrans, dtFecha, mSaldo, mMonto;
							IF CAST(cCodRet2 AS INT) <> 0 THEN
								IF iTransaccion = 1 THEN
									ROLLBACK WORK;
									BEGIN WORK;
								ELSE
									ROLLBACK WORK;
								END IF;
								EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret("01",cCodRet2)
								INTO cCodRet1,cMensajeRet;
							ELSE
								---Se aplica cargo por iva comisión
								EXECUTE PROCEDURE bdicheq:"informix".cargo_ref (pEmpresa, pSucursal, pUsuario, cIvaComis, pTransacSuc, pFolio_Suc, pNum_Cta_Ord, 0, pIva_Tef,  pDivisa, pCve_Rastreo, pNumTarjeta, pUsuario)
								INTO cCodRet2, cTrans, dtFecha, mSaldo, mMonto;
								IF CAST(cCodRet2 AS INT) <> 0 THEN
									IF iTransaccion = 1 THEN
										ROLLBACK WORK;
										BEGIN WORK;
									ELSE
										ROLLBACK WORK;
									END IF;			
								EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret("01",cCodRet2)
								INTO cCodRet1,cMensajeRet;
								END IF;
							END IF;
						END IF;
					END IF;
			ELIF pTipo = 2 THEN --Grabar en TEF
										
					SELECT num_serial 
					INTO cNumSerial 
					FROM bdicheq:"informix".sc_movdia
					WHERE folio_suc = pFolio_Suc
					AND empresa = pEmpresa
					AND transacc = cTranscargo;
					
					IF cNumSerial IS NULL OR cNumSerial = "" THEN
						 LET cCodRet1 = "000011"; --NO EXISTE FOLIO SUCURSAL
						 LET cMensajeRet = "No existe folio sucursal, verifique...";
						 RETURN cCodRet1, TRIM(cMensajeRet);		 
					ELSE										
							  
						INSERT INTO bditef:"informix".tef_operaciones(fecha_trans,folio_suc,num_serial, sucursal, num_cta_ord,tipo_cta_ord,fecha_programacion,
							tipo_operacion,clave_rastreo,nombre_cte_ord,rfc_cte_ord,importe_tef,comision_tef,iva_tef,importe_tot_tef,
							tipo_cta_ben,nombre_ben,num_cuenta_tarj_ben,cve_banco_rec,rfc_ben,concepto_pago,ref_num,referencia,cve_canal,
							cve_status, motivo_dev, hora_insert, user_insert,fecha_insert)
							
						VALUES(pFecha_Trans,pFolio_Suc, cNumSerial, pSucursal, pNum_Cta_Ord, pTipo_Cta_Ord, pFecha_Prog,
							pTipo_Oper, pCve_Rastreo, pNombre_Cte_Ord, pRfc_Cte_Ord, pImp_Tef, pComision_Tef, pIva_Tef,	pImp_Tot_Tef,
							pTipo_Cta_Ben, pNombre_Ben, pNum_Cta_Tarj_Ben, pCve_Banco_Rec, pRfc_Ben, pConcep_Pago, pRef_Num, pReferencia, pCve_Canal,
							'PE', pMotivo_Dev, SUBSTR(CURRENT HOUR TO SECOND,1,2)||SUBSTR(CURRENT HOUR TO SECOND,4,2)||SUBSTR(CURRENT HOUR TO SECOND,7,2), pUsuario, CURRENT);
						
						
					END IF;			ELSE --validacion de tipo de operación
				LET cCodRet1 = "000013";
				LET cMensajeRet = "Tipo de operación invalida, verifique...";
			END IF; 
		END IF--VALIDACION DE ARCHIVO
	END IF;	IF cCodRet1::INTEGER = 0 THEN
		COMMIT WORK;	
	END IF
RETURN cCodRet1, TRIM(cMensajeRet);
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para dar de alta operaciones TEF en central', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120619.1021';

CREATE PROCEDURE "informix".sp_tef_obtcodbanco(ptipo INTEGER, pCuenta CHAR (20) )
RETURNING
CHAR(6) 		AS cod_ret,
VARCHAR(80) 	AS desc_ret,
CHAR(3)		    AS Codigo_banco, 
VARCHAR(40)		AS Descripcion;	  
	
---DECLARACIONES
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			VARCHAR(80);
DEFINE cCodRet				CHAR(6);
DEFINE cMensajeRet			VARCHAR(80);
DEFINE cBanco			CHAR(3);
DEFINE cDescripcion			VARCHAR(40);	
DEFINE iContador			INTEGER;	

---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '000000';
LET cMensajeRet			= 'PROCESO EXITOSO';
LET cBanco			= '';
LET cDescripcion		= '';
LET iContador		= 0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, cMensajeRet, '', '';
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_tef_obtcodbanco.out';
	--TRACE ON;

	-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
    IF NVL(ptipo,0) NOT IN (1,2,3) OR (NVL(pCuenta,"") = "" AND  NVL(ptipo,0) IN (0,2,3)) THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Parametro Invalido, Verifique...';
    END IF;
	
	IF ptipo = 1 THEN --créditos hipotecarios crédito automotriz, hipotecario ó personal		
		FOREACH 
			SELECT banco,descripcion
				INTO cBanco , cDescripcion
			FROM bdinteg:"informix".si_bancos
			WHERE banco <> '137'			
			AND flg_tef_r = '1'
			
			LET iContador= iContador+1;
			
			RETURN cCodRet, cMensajeRet, cBanco, TRIM(cDescripcion) WITH RESUME;
		END FOREACH;
		
	ELIF ptipo = 2 THEN --Tarjeta de débito
		--Selección de Num. Tarjeta de Débito
		SELECT cve_banco,banco_prosa
			INTO cBanco , cDescripcion
		FROM bdicheq:"informix".sc_bines
		WHERE bin = SUBSTR(pCuenta, 1,6);		
		
	ELIF ptipo = 3 THEN --Cuenta CLABE
		SELECT banco,descripcion
			INTO cBanco , cDescripcion
		FROM bdinteg:"informix".si_bancos
		WHERE banco = SUBSTR(pCuenta,1,3)
		AND flg_tef_r = '1';				
	END IF;				
	
	IF iContador = 0 AND ptipo = 1  THEN
		LET cCodRet = '000002';
		LET cMensajeRet = 'NO EXISTE INFORMACION, VERIFIQUE...';
		RETURN cCodRet, cMensajeRet, cBanco, cDescripcion;
	ELIF iContador = 0 AND ptipo <> 1  THEN
		RETURN cCodRet, cMensajeRet, cBanco, TRIM(cDescripcion);
	END IF;
	
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso obtiene los codigos de banco para operaciones TEF en central', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120619.1021',
'DESCRIPCION: Se modifica procedimiento ya que regresaba dos veces el banco "021-HSBC MEXICO, S.A."', 
'AUTOR: Armando Morales Barraza',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120710.1021';

CREATE PROCEDURE "informix".sp_tef_obtinforpt(pClaveRastreo CHAR(30))
RETURNING
CHAR(6) 		AS cod_ret,
VARCHAR(80) 	AS desc_ret,
DATE 			AS fecha_trans,
CHAR(30)		AS clave_rastreo,
CHAR(10) 		AS importe_tef,
DATE 			AS fecha_programacion,
CHAR(45)		AS nombre_usuario,
CHAR(16)		AS folio_suc,
CHAR(30)		AS nombre_cte_ord,
CHAR(20)		AS numcte_ord,
CHAR(20)		AS num_cta_ord,
CHAR(30)		AS tipo_cta_ord_desc,
CHAR(5)			AS comision_tef,
CHAR(5)			AS iva_tef ,
CHAR(30)		AS nombre_ben,
CHAR(30)		AS tipo_cta_ben,
CHAR(20)		AS num_cuenta_tarj_ben,
CHAR(15)		AS rfc_ben,
CHAR(50)		AS concepto_pago,
CHAR(7)			AS ref_num,
CHAR(8)			AS hora_trans;  

---DECLARACIONES
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			VARCHAR(80);
DEFINE cCodRet				CHAR(6);
DEFINE cMensajeRet			VARCHAR(80);	
	
DEFINE dtFecha_trans		DATE;
DEFINE cClave_rastreo 		CHAR(30);
DEFINE cImporte_tef 		CHAR(10) ;
DEFINE dtFecha_programacion DATE;
DEFINE cNombre_usuario 		CHAR(45);
DEFINE cFolio_suc 			CHAR(16);
DEFINE cNombre_cte_ord		CHAR(30);
DEFINE cNumcte_ord 			CHAR(20);
DEFINE cNum_cta_ord 		CHAR(20);
DEFINE cTipo_cta_ord 		CHAR(2);
DEFINE cTipo_cta_ord_desc	CHAR(30);
DEFINE cComision_tef 		CHAR(5);
DEFINE cIva_tef 			CHAR(5)	;
DEFINE cNombre_ben 			CHAR(30);
DEFINE cTipo_cta_ben 		CHAR(2);
DEFINE cTipo_cta_ben_des 	CHAR(30);
DEFINE cNum_cuenta_tarj_ben CHAR(20);
DEFINE cRfc_ben 			CHAR(15);
DEFINE cConcepto_pago 		CHAR(50);
DEFINE cRef_num 			CHAR(7)	;  
DEFINE cUsuario 			CHAR(8)	;  
DEFINE cHoraTrans 			CHAR(8)	;  
---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '000000';
LET cMensajeRet			= 'PROCESO EXITOSO';
	
LET dtFecha_trans		 = "";
LET cClave_rastreo 		 = "";
LET cImporte_tef 		 = "";
LET dtFecha_programacion = "";
LET cNombre_usuario 	 = "";
LET cFolio_suc 			 = "";
LET cNombre_cte_ord		 = "";
LET cNumcte_ord 		 = "";
LET cNum_cta_ord 		 = "";
LET cTipo_cta_ord 		 = "";
LET cTipo_cta_ord_desc 	 = "";
LET cComision_tef 		 = "";
LET cIva_tef 			 = "";
LET cNombre_ben 		 = "";
LET cTipo_cta_ben 		 = "";
LET cTipo_cta_ben_des 	 = "";
LET cNum_cuenta_tarj_ben = "";
LET cRfc_ben 			 = "";
LET cConcepto_pago 		 = "";
LET cRef_num 			 = "";
LET cUsuario 			 = "";
LET cHoraTrans 			 = "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, cMensajeRet, ''	,'' ,'','','' ,'','','','' ,'','','','','','','','','','';
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_tef_obtinforpt.out';
	--TRACE ON;

	-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
    IF NVL(pClaveRastreo,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
	ELSE	
		
		IF EXISTS (SELECT  clave_rastreo FROM bditef:"informix".tef_operaciones	WHERE clave_rastreo = pClaveRastreo) THEN
			SELECT  fecha_trans, clave_rastreo, importe_tef,fecha_programacion,  folio_suc,nombre_cte_ord,
			num_cta_ord, tipo_cta_ord, comision_tef,iva_tef , nombre_ben,tipo_cta_ben, num_cuenta_tarj_ben,rfc_ben,
			concepto_pago, ref_num, user_insert,SUBSTR(hora_insert,1,2)||":"||SUBSTR(hora_insert,3,2)||":"||SUBSTR(hora_insert,5,2)
			INTO dtFecha_trans	,cClave_rastreo ,cImporte_tef,dtFecha_programacion,cFolio_suc,cNombre_cte_ord,
			cNum_cta_ord ,cTipo_cta_ord,cComision_tef,cIva_tef,cNombre_ben,cTipo_cta_ben,cNum_cuenta_tarj_ben,cRfc_ben,
			cConcepto_pago,cRef_num,cUsuario,cHoraTrans
			FROM bditef:"informix".tef_operaciones
			WHERE clave_rastreo = pClaveRastreo;
			
			
			SELECT num_cte
				INTO cNumcte_ord
			FROM bdicheq:"informix".sc_maechq
			WHERE empresa = '001'
			AND cuenta = cNum_cta_ord;
			
			SELECT descripcion
				INTO cTipo_cta_ben_des
			FROM bditef:"informix".tef_tipo_cta
			WHERE tipo_cta = cTipo_cta_ben;
			
			SELECT descripcion
				INTO cTipo_cta_ord_desc
			FROM bditef:"informix".tef_tipo_cta
			WHERE tipo_cta = cTipo_cta_ord;
			
			SELECT nombre
			INTO cNombre_usuario
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo = cUsuario;
			
		ELSE
			LET cCodRet = '000002';
			LET cMensajeRet = 'NO EXISTE INFORMACION, VERIFIQUE';
		END IF;		
    END IF;
	IF NVL(cRfc_ben,"") = "" THEN
		LET cRfc_ben ="NO DISPONIBLE";
	END IF;	
	
	RETURN cCodRet, cMensajeRet, dtFecha_trans	,cClave_rastreo ,cImporte_tef,dtFecha_programacion,cNombre_usuario ,cFolio_suc,cNombre_cte_ord,cNumcte_ord 	,cNum_cta_ord ,cTipo_cta_ord_desc,
		cComision_tef,cIva_tef,cNombre_ben,cTipo_cta_ben_des,cNum_cuenta_tarj_ben,cRfc_ben,cConcepto_pago,cRef_num,cHoraTrans;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para obtener la informacion para visualizar el reporte de alta operaciones TEF en central', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120625.1021';

CREATE PROCEDURE "informix".sp_tef_obttipocta()
RETURNING
CHAR(6) 		AS cod_ret,
VARCHAR(80) 	AS desc_ret,
VARCHAR(2)		AS tipo_cuenta, 
VARCHAR(20)		AS descripcion_cuenta;
	
---DECLARACIONES
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			VARCHAR(80);
DEFINE cCodRet				CHAR(6);
DEFINE cMensajeRet			VARCHAR(80);
DEFINE cTipo_cta			CHAR(2);
DEFINE cDescripcion			VARCHAR(20);
	
---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '000000';
LET cMensajeRet			= 'PROCESO EXITOSO';
LET cTipo_cta			= '';
LET cDescripcion		= '';
	
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, TRIM(cMensajeRet), '', '';
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_tef_obttipocta.out';
	--TRACE ON;

	FOREACH 
		 SELECT tipo_cta, descripcion
		 INTO cTipo_cta, cDescripcion
		 FROM bditef:"informix".tef_tipo_cta
		 ORDER BY tipo_cta
		 
		 RETURN cCodRet, TRIM(cMensajeRet), cTipo_cta, TRIM(cDescripcion) WITH RESUME;
	END FOREACH;
	
	IF DBINFO("sqlca.sqlerrd2")= 0 THEN
	 LET cCodRet = '000001';
	 LET cMensajeRet = 'NO SE OBTUVIERON RESULTADOS';
	 RETURN cCodRet, TRIM(cMensajeRet), cTipo_cta, TRIM(cDescripcion) ;
	END IF;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que obtiene los tipos de cuentas para operaciones TEF en central', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120619.1021';

CREATE PROCEDURE "informix".sp_tef_reversoperacion(pfecha DATE,
												  pSucursal CHAR(4),
												  pEjecutivo CHAR(8),
												  pFolioSuc VARCHAR(16))  
RETURNING
CHAR(6) 		AS cod_ret,
VARCHAR(100) 	AS desc_ret;  

---DECLARACIONES
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			VARCHAR(80);
DEFINE cCodRet				CHAR(6);
DEFINE cCodretRev			CHAR(5);
DEFINE cMensajeRet			VARCHAR(100);

DEFINE cFolioSuc			VARCHAR(16);
DEFINE cNumCtaOrd			VARCHAR(20);
DEFINE cReferencia			VARCHAR(40);
DEFINE cImporte			    CHAR(10);
DEFINE cReversado			CHAR(2);

DEFINE cCodretVal   CHAR(5);
DEFINE cTpo_Proc CHAR(1); 
DEFINE cFech_Proc CHAR(10);
DEFINE cCve_Proc CHAR(20);
DEFINE cDescripcion CHAR(60);
DEFINE cEstatus CHAR(1);	
---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '000000';
LET cCodretRev			= '00000';
LET cMensajeRet			= 'PROCESO EXITOSO';

LET cFolioSuc			= '';
LET cNumCtaOrd			= '';
LET cReferencia			= '';
LET cImporte			= '';
LET cReversado			= '';

LET cCodretVal   = "";
LET cTpo_Proc    = "";
LET cFech_Proc   = "";
LET cCve_Proc    = "";
LET cDescripcion = "";
LET cEstatus     = "";

	
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, cMensajeRet;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_tef_reversoperacion.out';
	--TRACE ON;

	-- VALIDA QUE LOS parámetros NO VENGAN VACIOS
    IF NVL(pfecha,"") = "" OR NVL(pSucursal,"") = "" OR NVL(pEjecutivo,"") = "" OR NVL(pFolioSuc,"") = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Falta uno o mas parámetros';
	ELSE
		IF pfecha::DATE <> (SELECT fecha_hoy FROM  bdicheq:"informix".sc_fechas) THEN
			LET cCodRet = '000002';
			LET cMensajeRet = 'Fecha invalida, verifique...';
		ELSE
			IF EXISTS (SELECT folio_suc FROM bditef:"informix".tef_operaciones
					   WHERE fecha_trans = pfecha AND folio_suc = pFolioSuc
						AND sucursal = pSucursal AND user_insert = pEjecutivo ) THEN
						
				SELECT  DECODE(cve_status,"PE","N","05","S","")	
					INTO cReversado
				FROM bditef:"informix".tef_operaciones
				WHERE fecha_trans = pfecha
				AND folio_suc = pFolioSuc
				AND sucursal = pSucursal
				AND user_insert = pEjecutivo;
				
				IF cReversado = "S" THEN
					LET cCodRet = '000003';
					LET cMensajeRet = 'Folio proporcionado ya fue reversado, verifique...';
				ELIF cReversado = "" THEN
					LET cCodRet = '000004';
					LET cMensajeRet = 'Folio se encuentra en estatus invalido, verifique...';
				ELSE
					EXECUTE PROCEDURE  bditef:"informix".sp_tef_validahorario(CURRENT HOUR TO SECOND)
						INTO cCodRet, cMensajeRet;
					IF CAST(cCodRet AS INTEGER) <> 0 THEN --SE VALIDA QUE EL HORARIO SE ENCUENTRE EN EL RANGO PERMITIDO
						LET cCodRet = "000002";
						LET cMensajeRet = cMensajeRet;	
					ELSE										
						EXECUTE PROCEDURE bditef:"informix".sp_tef_validarchcod60('', "GENARCH_60.01") 
						INTO cCodretVal, cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus;		
						
						IF cCodretVal::integer <> 0 THEN					
							LET cCodRet = '000003';
							LET cMensajeRet = 'No es posible registrar la operación TEF. El proceso de generación de archivo ya ha iniciado.';							
						ELSE							
							EXECUTE PROCEDURE bdicheq:"informix".reversion_sif('001',pSucursal,pEjecutivo,pFolioSuc,'A') INTO cCodretRev;
							
							IF cCodretRev::INTEGER <> 0 THEN
								LET cCodRet = '000006';
								LET cMensajeRet = 'Ocurrio un error al realizar la reversion, verifique...';							
							END IF
						END IF
					END IF
				END IF
				
			ELSE
				LET cCodRet = '000007';
				LET cMensajeRet = 'no se encontro informacion, verifique...';
			END IF			
		END IF
    END IF;	

	RETURN cCodRet, cMensajeRet;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para reversar la informacion de alta operaciones TEF en central', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120626.1021',
'DESCRIPCION: Se cambia el nombre al llamado del procedimiento "reversion" por "reversion_sif"', 
'AUTOR: Armando Morales Barraza',
'BASE DE DATOS: bditef',
'FECHA: Julio 2012',
'VERSION: 20120717.0921';

CREATE PROCEDURE "informix".sp_tef_validahorario(pHorario DATETIME HOUR TO MINUTE)
RETURNING
	CHAR(6) 		AS cod_ret,
	VARCHAR(100) 	AS desc_ret;  
	
---DECLARACIONES
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(100);
DEFINE cCodRet      CHAR(6);
DEFINE cMensajeRet  VARCHAR(100);
DEFINE dtHorarioMax DATETIME HOUR TO MINUTE;

---INICIALIZACIONES
LET iSqlErr			= 0;
LET iIsamErr		= 0;
LET cErrorInfo		= '';
LET cCodRet			= '000000';
LET cMensajeRet		= 'PROCESO EXITOSO';
LET dtHorarioMax	= '';

	
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, TRIM(cMensajeRet);
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_tef_validahorario.out';
	--TRACE ON;	
	--se obtiene la hora maxima permitida
	 IF NVL(pHorario,"") = ""  THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'PARAMETRO INVALIDO, VERIFIQUE...';
     END IF;
	 
	SELECT valor INTO  dtHorarioMax FROM  bditef:"informix".tef_parametros
	WHERE cod_param = '11';	
	
	IF pHorario >= dtHorarioMax THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'No es posible registrar la operación TEF. El horario excede del tiempo máximo establecido.';
	END IF;

	RETURN cCodRet, TRIM(cMensajeRet);

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que realiza la validación del horario permitido para operaciones TEF en central', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120619.1021';

CREATE PROCEDURE "informix".sp_tef_validarchcod60(pTpo_Proc CHAR(1), pCve_Proceso CHAR(20))

RETURNING CHAR(5), CHAR(1), CHAR(10), CHAR(20), CHAR(60), CHAR(1);

---Declaración de Variables
DEFINE cCodret   CHAR(5);
DEFINE sql_err   INTEGER;
DEFINE cTpo_Proc CHAR(1); 
DEFINE cFech_Proc CHAR(10);
DEFINE cCve_Proc CHAR(20);
DEFINE cDescripcion CHAR(60);
DEFINE cEstatus CHAR(1);
DEFINE cFecha_hoy CHAR(10);

---Inicialización de Variables
LET cCodret = '00000';
LET sql_err = 0;
LET cTpo_Proc = "";
LET cFech_Proc = DATE(1);
LET cCve_Proc = "";
LET cDescripcion = "";
LET cEstatus = "";
LET cFecha_hoy = DATE(1);
	   

    -- SET DEBUG FILE TO "/respaldosbd/hectorb/sp_tef_validarchcod60.out";
    -- TRACE ON;	   
	   


BEGIN

	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodret = sql_err;
			RETURN cCodret, cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus;
		END IF;
	END EXCEPTION;
	
	IF pTpo_Proc <> "" OR pCve_Proceso <> "" THEN
		IF pTpo_Proc <> "" AND pCve_Proceso <> "" THEN
			LET cCodret = "00001";
			RETURN cCodret, cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus;
		ELSE
			SELECT fecha_hoy
			INTO cFecha_hoy
			FROM bdicheq:"informix".sc_fechas;
			
			
			IF pTpo_Proc <> "" THEN
				FOREACH
					SELECT tipo_proceso, fecha_proceso, cve_proceso, descripcion, estatus
					INTO cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus
					FROM bditef:"informix".tef_procesos
					WHERE tipo_proceso = pTpo_Proc
					
					LET cCodret = "00003";	
					RETURN cCodret, cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus WITH RESUME;
				END FOREACH
			ELIF pCve_Proceso <> "" THEN
				FOREACH
					SELECT tipo_proceso, fecha_proceso, cve_proceso, descripcion, estatus
					INTO cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus
					FROM bditef:"informix".tef_procesos
					WHERE  fecha_proceso = cFecha_hoy
					AND cve_proceso = pCve_Proceso
					
					LET cCodret = "00002";
					RETURN cCodret, cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus WITH RESUME;
				END FOREACH

			END IF;
		END IF;	
	END IF;
	
     
	RETURN cCodret, cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus;

END;

END PROCEDURE
DOCUMENT
'AUTOR : Héctor Manuel Bojorquez Ruelas',
'DESCRIPCION: Validar si incio o no la generación del Archivo Código 60',
'FECHA : 28/06/2012',
'BD    : bditef';

CREATE PROCEDURE "informix".sp_tef_validarecepcion(ptipo INTEGER, pCuenta CHAR (20) )
RETURNING
CHAR(6) 		AS cod_ret,
VARCHAR(80) 	AS desc_ret;

---DECLARACIONES
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			CHAR(80);
DEFINE cCodRet				CHAR(6);
DEFINE cCodRet1				CHAR(6);
DEFINE vMensajeRet			VARCHAR(80);
DEFINE sBandera			    SMALLINT;
DEFINE cBanco 				CHAR(3);

---INICIALIZACIONES
LET iSqlErr					= 0;
LET iIsamErr				= 0;
LET cErrorInfo				= '';
LET cCodRet					= '000000';
LET cCodRet1				= '000000';
LET vMensajeRet				= 'PROCESO EXITOSO';
LET sBandera		    	= 0;
LET cBanco					= '';

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET vMensajeRet = cErrorInfo;
			RETURN cCodRet, TRIM(vMensajeRet);
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/home/sysifx/vlv/sp_tef_validarecepcion.out';
	--TRACE ON;

	-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
    IF (NVL(pCuenta,"") = "" OR NVL(ptipo,0) NOT IN (2,3)) THEN
		LET cCodRet = '000001';
		LET vMensajeRet = 'Parámetros inválidos';
    END IF;

    IF ptipo = 2 THEN --Tarjeta de débito	
			IF NOT EXISTS (SELECT banco	
							FROM bdinteg:"informix".si_bancos
							WHERE banco = (SELECT cve_banco	
							   			FROM bdicheq:"informix".sc_bines 
										WHERE bin = SUBSTR(pCuenta, 1,6) AND UPPER(creditodebito) = 'D')
 							AND flg_tef_r = '1') THEN
				LET sBandera=1;				
			END IF;	
	
	ELIF ptipo = 3 THEN --Cuenta CLABE
		SELECT banco 
		INTO cBanco 
		FROM bdinteg:"informix".si_bancos WHERE banco = SUBSTR(pCuenta,1,3)	AND flg_tef_r = '1';
		
		IF TRIM(NVL(cBanco, '')) = '' THEN		
			LET sBandera=1;
		ELIF TRIM(NVL(cBanco, '')) = '137' THEN
			LET sBandera=2;	
		END IF;	
		
	END IF;
	
	IF sBandera = 1 THEN	
		LET cCodRet = '000002';
		EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret("01","099")
									INTO cCodRet1,vMensajeRet;	
	ELIF sBandera = 2 THEN
		LET cCodRet = '000003';
		EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret("01","573")
									INTO cCodRet1,vMensajeRet;	
	END IF;			
    
	RETURN cCodRet, TRIM(vMensajeRet);

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que valida que la cuenta sea valida para recepcion de operaciones TEF en central',
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120619.1021',
'MODIFICO: Valentin Lopez Valenzuela.',
'DESCRIPCION: Se agrego una validación para no permitir realizar transferencia de envio de fondos a BANCOPPEL. (ptipo = 3) ',
'BASE DE DATOS: bditef',
'FECHA: Agosto 2012',
'VERSION: 20120809.1544';

create procedure "informix".stat_cheque (
                    pempresa    char(3),
                    pcuenta     char(20),
                    pnrocheque  integer)
       returning    char(5),    --codret
                    char(2);    --motdevol

    -- v1.0 validacion extra cuando el cheque no ha sido
    -- aplicado pero ya esta en la base de datos
    -- lalo jun10
                    
    -- v1.0 version inicial
    -- eduardo espinosa oct09
    -- devuelve el status de la cuenta/cheque

                    
    define vsqlerr      integer;
    define vcodret      char(5);
    define vmotdevol    char(2);
    define vcuenta      char(20);
    define vstatuscta   char(1);
    define vmotivo      char(2);
    define vchequestat  char(1); 
    define vcargo       char(1);
    
    let vcodret     = "000";
    let vmotdevol   = "00";
    let vcargo      = "S";

    
    
--set debug file to "/pisa/liberoltp/pisa_ftes/cecoban/stat_cheque.txt";
--trace on;
        
begin
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret,vmotdevol;
        end if
    end exception;

    --- valida que la cta/numcheque no venga vacio
    if  trim(pcuenta) = "" or pcuenta is null 
        or pnrocheque = "" or pnrocheque < 1 then
            let vcodret = "100";
            return vcodret,vmotdevol;
    end if



    -- MOTIVO 02 No tiene cuenta con nosotros el librador
    -- Valida que Exista la Cuenta de Cheques 
    -- o que si la cuenta esta cancelada (status_cta="2")
    
    select  cuenta, status_cta,motivo
    into    vcuenta, vstatuscta, vmotivo
    from    bdicheq:sc_maechq
    where   cuenta = pcuenta;
    
    
    if dbinfo("sqlca.sqlerrd2") = 0 or vstatuscta = "2" then
    
            let vmotdevol   = "02";
            return vcodret,vmotdevol;
            
    else
    
        -- cta bloqueada pero acepta cargos
        if  vstatuscta = "3" then
            select  cargo 
            into    vcargo
            from    bdicheq:sc_bloqueo
            where   codigo = vmotivo;

            if vcargo = "N" then
                let vmotdevol   = "09"; -- cta bloqueada
                return vcodret,vmotdevol;
            end if
        end if        


        
        -- cuenta bloqueada no hacer nada
        -- validar los status del cheque
        
        if vcargo = "S" then
        
            select  estado
            into    vchequestat
            from    bdicheq:sc_contch
            where   empresa = pempresa
            and     cuenta  = pcuenta
            and     numero  = pnrocheque;

            -- no encontro registros
            -- La numeración del cheque no corresponde 
            
            if dbinfo("sqlca.sqlerrd2") = 0 then 
                let vmotdevol   = "51";       
            end if

            -- activo (cheque para intentar cargarle)
            if vchequestat = "A" or vchequestat = "U" then
                -- cta OK  
            end if

            -- ya pagado
            if vchequestat = "P" or vchequestat = "M" then
                let vmotdevol   = "16";
            end if 
            
            -- presentado por camara
            if vchequestat = "N"  then
                let vmotdevol   = "18";
            end if             

            -- revocado
            if vchequestat = "R"  then
                let vmotdevol   = "08";
            end if                

            -- cancelado
            -- CHEQUE EXTRAVIADO
            if vchequestat = "C"  then
                let vmotdevol   = "52";
            end if 

            -- incompleto
            if vchequestat = "I"  then
                let vmotdevol   = "51";
            end if 

            -- destruido
            if vchequestat = "D"   then
                let vmotdevol   = "23";
            end if 
            
            -- bloqueado orden jud
            -- TENEMOS ORDEN JUDICIAL DE NO PAGAR
            if vchequestat = "J"  then
                let vmotdevol   = "07";
            end if 

            -- bloqueado autoridades
            if vchequestat = "B"  then
                let vmotdevol   = "09";
            end if 
            
            
            -- validacion extra 
            
            if exists (select c_cuenta from cce_propios_det
                        where c_cuenta = pcuenta 
                        and c_cheque = pnrocheque
				and status = '01') then
                        
                let vmotdevol   = "16";
            end if 
            
            

        end if --validar los status del cheque


                
    end if    --cuenta, sdo_actual
 

    return vcodret,vmotdevol;    
    
end

END PROCEDURE;