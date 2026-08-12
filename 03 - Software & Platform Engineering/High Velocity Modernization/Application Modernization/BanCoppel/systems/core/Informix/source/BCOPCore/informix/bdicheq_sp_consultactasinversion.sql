CREATE PROCEDURE "informix".sp_consultactasinversion(pOpticon INTEGER, pNumcte CHAR(20), pCuenta CHAR(20), pSecuencia SMALLINT)
	RETURNING CHAR(6) AS CodRetorno, CHAR(20) AS Cuenta, CHAR(104) AS Nombre, CHAR(1) AS Status;

--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);

DEFINE cNombre1 CHAR(26);
DEFINE cNombre2 CHAR(26);
DEFINE cApellPat CHAR(26);
DEFINE cApellMat CHAR(26);
DEFINE cNomCompleto CHAR(104);
DEFINE cCuenta CHAR(20);
DEFINE sCiclo SMALLINT;
DEFINE cNumProd CHAR(4);
DEFINE cStatus CHAR(1);

--Inicializacion de Variables
LET iSqlErr = 0;
LET cCodRet = '000000';

LET cNombre1 = '';
LET cNombre2 = '';
LET cApellPat = '';
LET cApellMat = '';
LET cNomCompleto = '';
LET cCuenta = '';
LET sCiclo = 0;
LET cNumProd = '';
LET cStatus = '';


--SET DEBUG FILE TO '/respaldosbd/Martha/sp_consultactasinversion.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCuenta, cNomCompleto, cStatus;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF pOpticon = 1 THEN --Consulta Cuenas de Inversion por Numero de cliente
	
		SELECT nombre1, nombre2, apell_paterno, apell_materno
		INTO cNombre1, cNombre2, cApellPat, cApellMat
		FROM bdinteg:"informix".si_cliente WHERE numcte = pNumcte;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '000279';
			RETURN cCodRet, cCuenta, cNomCompleto,cStatus;
		ELSE
			IF cNombre2 = '' THEN
				LET cNomCompleto = TRIM(cNombre1)||" "||TRIM(cApellPat)||" "||TRIM(cApellMat);
			ELSE
				LET cNomCompleto = TRIM(cNombre1)||" "||TRIM(cNombre2)||" "||TRIM(cApellPat)||" "||TRIM(cApellMat);
			END IF;
			
			FOREACH 
				SELECT cuenta INTO cCuenta FROM bdicheq:"informix".sc_maechq WHERE producto = '1100' AND num_cte = pNumcte AND status_cta <> 2
				
				LET sCiclo = sCiclo + 1;			
				IF sCiclo <= pSecuencia THEN
					CONTINUE FOREACH;
				END IF;
				
				RETURN cCodRet, cCuenta, TRIM(cNomCompleto),cStatus WITH RESUME;
				
			END FOREACH;
				
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '000272';
				RETURN cCodRet, cCuenta, cNomCompleto, cStatus;
			END IF;
						
		END IF;
		
	ELIF pOpticon = 2 THEN --Consulta cuentas de inversion y eje por numero de cuenta
		
		SELECT cuenta, producto,status_cta INTO cCuenta, cNumProd,cStatus FROM bdicheq:"informix".sc_maechq WHERE cuenta = pCuenta;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		
			LET cNumProd = SUBSTR(pCuenta,0,4);
			IF cNumProd = '1100' THEN
				LET cCodRet = '000276';
			ELSE
				LET cCodRet = '000278';
			END IF;
			
			RETURN cCodRet, cCuenta, cNomCompleto,cStatus;
					
		END IF;
		
		IF cNumProd = '1100' THEN --Cuentas Eje: si consulta por cuenta de inversion
			FOREACH
				SELECT cuentadep INTO cCuenta FROM bdicheq:"informix".sc_maeinstrucc WHERE empresa="001" and cuenta = pCuenta
			
				LET sCiclo = sCiclo + 1;			
				IF sCiclo <= pSecuencia THEN
					CONTINUE FOREACH;
				END IF;
				
				RETURN cCodRet, cCuenta, cNomCompleto, cStatus WITH RESUME;
			END FOREACH;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '000274';
				RETURN cCodRet, cCuenta, cNomCompleto,cStatus;
			END IF;
			
		ELSE --Cuentas Inversion: si consulta por cuenta eje
			
			FOREACH
				SELECT cuenta INTO cCuenta FROM bdicheq:"informix".sc_maeinstrucc WHERE cuentadep = pCuenta
			
				LET sCiclo = sCiclo + 1;			
				IF sCiclo <= pSecuencia THEN
					CONTINUE FOREACH;
				END IF;
				
				RETURN cCodRet, cCuenta, cNomCompleto,cStatus WITH RESUME;
			END FOREACH;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '000275';
				RETURN cCodRet, cCuenta, cNomCompleto,cStatus;
			END IF;
			
		END IF;
		
	END IF;
		
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Consulta las cuentas de inversion creciente del cliente por medio del numero de cliente, cuenta eje o cuenta creciente',
'AUTOR : Adrian Lara',
'FECHA : 16/05/2012',
'BD: bdicheq',
'SISTEMA : 1';

CREATE PROCEDURE "informix".sp_consinstruvenci(pEmpresa CHAR(3), pCuenta CHAR(20))
	--DATOS A REGRESAR
	RETURNING
	CHAR(5)  AS CodigoRetorno,
	CHAR(40) AS Descripcion;

	DEFINE iSql_err	  	INTEGER;
	DEFINE cCodRet      CHAR(5);
	DEFINE cDescripcion	CHAR(40);
	DEFINE cInstrucc    CHAR(2);
	
	LET iSql_err     = 0;
	LET cCodRet      = '00000';
	LET cDescripcion = '';
	LET cInstrucc    = '';

	--SET DEBUG FILE TO "/respaldosbd/Daniela/sp_consinstruvenci.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet, cDescripcion; 
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pEmpresa IS NULL OR pEmpresa = '' THEN
			LET cCodRet = '00001';  --Falta el Campo Empresa.
        ELIF pCuenta IS NULL OR pCuenta = '' THEN
			LET cCodRet = '00002';  --Falta el Número de Cuenta.
		ELSE
			SELECT instrucc INTO cInstrucc
			FROM bdicheq: "informix".sc_maeinstrucc WHERE empresa = pEmpresa AND cuenta = pCuenta;
			
			IF cInstrucc IS NULL OR cInstrucc = '' THEN
				LET cCodRet = '00003';  --No Existe Intrucción para esa Cuenta.
			ELSE
				SELECT descripcion INTO cDescripcion
				FROM bdicheq: "informix".sc_instrucc WHERE empresa = pEmpresa AND instrucc = cInstrucc;
				
				IF cDescripcion IS NULL OR cDescripcion = '' THEN
					LET cCodRet = '00004';  --No Existe Descripción para esa Intrucción.
				END IF;
			END IF;
		END IF;
		
		RETURN cCodRet, cDescripcion;
		
	END
END PROCEDURE

DOCUMENT
'Consultar la descripción de la instrucción de vencimiento del cliente.',
'Autor :Rodolfo Tortolero Varela',
'FECHA :17/Diciembre/2012',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_consultarinversioncreciente(cNumCta CHAR(20), cEmpresa CHAR(3))
RETURNING CHAR(5),      -- Código de Retorno
          CHAR(104),    -- Nombre del cliente
          CHAR(20),     -- Tipo de persona
          CHAR(40),     -- Producto
          MONEY(14,2),  -- Capital
          DECIMAL(9,6), -- Taza Bruta Meta
          DATE,         -- Fecha de Apertura
          DATE,         -- Fecha Vencimiento
          CHAR(20),     -- Cuenta Referencia
          CHAR(45),     -- Promotor
          CHAR(1),      -- Estatus de la cuenta
		  CHAR(20);		-- Número de Cliente 'DSB 30/07/2012
          
    --DEFINICION DE VARIABLES--
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRet CHAR(5);	
    ---------------------------	
    DEFINE cNomCliente    CHAR(104);
    DEFINE cTipoPersona   CHAR(20);
    DEFINE cDescProducto  CHAR(40);
    DEFINE cProducto      CHAR(4);
    DEFINE mCapital       MONEY(14,2);
    DEFINE dTazaBruta     DECIMAL(9,6);
    DEFINE dFechaAper     DATE;
    DEFINE dFechaVen      DATE;
    DEFINE cCtaReferencia CHAR(20);
    DEFINE cPromotor      CHAR(45);
    DEFINE cEstatusCta    CHAR(1);
    DEFINE cProductoParam CHAR (60);
	DEFINE cNumCte		  CHAR(20); --'DSB 30/07/2012

    --INICIALIZACION DE VARIABLES-- 
    LET iSqlErr        = 0;
    LET cCodRet        = '00000';
    LET cNomCliente    = '';
    LET cTipoPersona   = '';
    LET cDescProducto      = '';
    LET cProducto      = '';
    LET mCapital       = 0;
    LET dTazaBruta     = 0;
    LET dFechaAper      = '';
    LET dFechaVen       = '';
    LET cCtaReferencia = '';
    LET cPromotor      = '';
    LET cEstatusCta    = '';
	LET cNumCte			= ''; --'DSB 30/07/2012

     
	 --SET DEBUG FILE TO "/respaldosbd/Martha/sp_consultarinversioncreciente.out";
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN 
    
    ON EXCEPTION SET iSqlErr 
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cNomCliente, cTipoPersona, cDescProducto, mCapital, dTazaBruta, dFechaAper, dFechaVen, cCtaReferencia, cPromotor, cEstatusCta, cNumCte;   
        END IF;    
    END EXCEPTION;	

    IF cNumCta IS NULL OR cNumCta = '' OR cEmpresa IS NULL OR cEmpresa = '' THEN
        LET cCodRet = "102"; -- Parámetros de entrada vacíos 
    ELSE
        -- Obtiene datos del cliente
        SELECT TRIM(b.nombre1) || ' ' || TRIM(b.nombre2) || ' ' || TRIM(b.apell_paterno) || ' ' || TRIM(b.apell_materno),
               c.descripcion, a.status_cta, a.imp_chq_rem, d.nombre, d.producto, Trim(b.numcte)
          INTO cNomCliente, cTipoPersona, cEstatusCta, mCapital, cDescProducto, cProducto, cNumCte
          FROM bdicheq:"informix".sc_maechq a,
               bdinteg:"informix".si_cliente b,
               bdinteg:"informix".si_tipper c,
               bdicheq:"informix".sc_producto d
         WHERE a.cuenta = cNumCta
           AND a.num_cte = b.numcte           
           AND b.tpo_persona = c.tpo_persona
           AND a.producto = d.producto;

        IF cNomCliente IS NULL OR cNomCliente = '' OR cTipoPersona IS NULL OR cTipoPersona = '' OR 
           cEstatusCta IS NULL OR cEstatusCta = '' OR mCapital IS NULL OR mCapital = '' OR 
           cDescProducto IS NULL OR cDescProducto  = '' OR cProducto IS NULL OR cProducto  = '' THEN
            LET cCodRet = "100"; --  No se encontró información referente a los datos de la cuenta
        ELSE
            -- Consulta de parametro producto inversion creciente 
			  SELECT TRIM(valor)
              INTO cProductoParam
              FROM bdicheq:"informix".sc_param 
             WHERE empresa = cEmpresa 
               AND codparam = 'PRODCREC'; 

            IF cProductoParam IS NULL OR cProductoParam ="" THEN
                LET cCodRet = "101";
            ELSE
                IF cProducto <> cProductoParam THEN
                    LET cCodRet = "104";
                ELSE
                    -- Obtiene Promotor, Fecha de Apertura y Fecha de Vencimiento
                    SELECT a.nombre, b.fecha_alta, b.fecha_mod
                      INTO cPromotor, dFechaAper, dFechaVen
                      FROM bdinteg:"informix".si_ejecut a,
                           bdicheq:"informix".sc_maenoc b
                     WHERE b.empresa = cEmpresa
                       AND b.cuenta = cNumCta
                       AND b.ejecutivo = a.ejecutivo;

                    IF cPromotor IS NULL OR cPromotor = '' OR dFechaAper IS NULL OR dFechaAper = '' OR dFechaVen IS NULL OR dFechaVen = '' THEN
                        LET cCodRet = "101"; -- No se encontró información 
                    ELSE
                        -- Obtiene la Cuenta de Referencia 
                        SELECT cuentadep
                          INTO cCtaReferencia
                          FROM bdicheq:"informix".sc_maeinstrucc
                         WHERE empresa = cEmpresa
                           AND cuenta = cNumCta;

                        IF cCtaReferencia IS NULL OR cCtaReferencia = '' THEN
                            LET cCodRet = "103"; -- No se encontró información
                        ELSE
                            --  Se obtiene el valor de la Taza Bruta Meta 
                            SELECT valor_tasa
                              INTO dTazaBruta
                              FROM bdicheq:"informix".sc_tasa_variable
                             WHERE empresa = cEmpresa
                               AND cuenta = cNumCta
                               AND tipo_tasa = 'P';

                            IF dTazaBruta IS NULL OR dTazaBruta = '' THEN
                                LET cCodRet = "101"; -- No se encontró información
                            END IF;
                        END IF;					
                    END IF;
                END IF;
            END IF;
        END IF;	
    END IF;

    RETURN cCodRet, cNomCliente, cTipoPersona, cDescProducto, mCapital, dTazaBruta, dFechaAper, dFechaVen, cCtaReferencia, cPromotor, cEstatusCta,cNumCte;

    END;
    
END PROCEDURE
DOCUMENT
"Autor : Martha Aguirre",
"FECHA : 25/05/2012",
"Descripcion: Consulta las datos de inversión creciente ",
" cuando la cuenta está en estatus cancelada",
"Ver.  : 1.0",
"BD    : bdicheq",

"Modifico : Daniela Ramirez (DSB 30/07/2012)",
"FECHA : 30/07/2012",
"Descripcion: Se agrega parametro de retorno numero de cliente";

CREATE PROCEDURE "informix".sp_cce_actualizarfechacheques
(
pEmpresa            CHAR(3),
pFechaPresentacion  CHAR(10),
pCtaDelCheque       CHAR(20),
pNumCheque          CHAR(7),
pMonto              DECIMAL(14,2)
)
RETURNING
	CHAR(6) 		AS cod_ret,
    CHAR(80) 		AS desc_ret

	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cDescRet		    CHAR(80);
    DEFINE cCodRet			CHAR(6);

	DEFINE mImporte		    MONEY(14,2);
	DEFINE cNumCuenta		CHAR(20);
	DEFINE cBanco			CHAR(3);
	DEFINE cDescBanco		CHAR(40);
    DEFINE dtFechaHoy       DATE;

	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= "";
    LET cDescRet		    = "PROCESO EXITOSO";
	LET cCodRet				= "000000";

    LET mImporte		    = 0.0;
	LET cNumCuenta			= "";
	LET cBanco				= "";
	LET cDescBanco			= "";
    LET dtFechaHoy          = DATE(1);


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
            LET cDescRet = cErrorInfo;
			RETURN cCodRet,cDescRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/respaldosbd/has/sp_cce_actualizarfechacheques.out';
	--TRACE ON;

	IF NVL(pEmpresa,"") = "" OR NVL(pFechaPresentacion,"") = "" OR NVL(pCtaDelCheque,"") = "" OR NVL(pNumCheque,"") = "" OR pMonto IS NULL THEN
        LET cCodRet = "000001";
        LET cDescRet = "FALTAN PARAMETROS DE ENTRADA";
	ELSE
        SELECT fecha_hoy
        INTO dtFechaHoy
        FROM "informix".sc_fechas
        WHERE empresa = pEmpresa;
    
        UPDATE bditef:"informix".cce_cheques_det
        SET fechapresenta = dtFechaHoy
        WHERE fechapresenta = pFechaPresentacion
        AND presentado = "0"
        AND numcuenta::INT8 = pCtaDelCheque::INT8
        AND numcheque = pNumCheque
        AND monto = pMonto;

        IF dbinfo("sqlca.sqlerrd2") = 0 THEN
            LET cCodRet = "000002";
            LET cDescRet = "NO SE ENCUENTRA EL CHEQUE PARA ACTUALIZAR";
            RETURN cCodRet,cDescRet;
        END IF
	END IF
    
    RETURN cCodRet,cDescRet;
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para actusalizar la fecha de presentacion del cheque para que sea tomado en cuenta por el proceso de la presentacion', 
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Febrero 2013',
'VERSION: 20130226.1911';

CREATE PROCEDURE "informix".sp_cce_consultarchequexpresentar
(
pEmpresa            CHAR(3),
pCtaDeposito        CHAR(20),
pNumCheque          INTEGER,
pFechaPresentacion  CHAR(10)
)
RETURNING
	CHAR(6)         AS cod_ret,
    CHAR(80)        AS desc_ret,
	MONEY(14,2)     AS importe,
	CHAR(20)        AS cuenta_cheque,
    CHAR(3)         AS cve_banco,
	CHAR(40)        AS desc_banco

	---DECLARACIONES
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cErrorInfo       CHAR(80);
    DEFINE cDescRet         CHAR(80);
    DEFINE cCodRet          CHAR(6);

	DEFINE mImporte         MONEY(14,2);
	DEFINE cNumCuenta       CHAR(20);
	DEFINE cBanco           CHAR(3);
	DEFINE cDescBanco       CHAR(40);

	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= "";
    LET cDescRet		    = "PROCESO EXITOSO";
	LET cCodRet				= "000000";

    LET mImporte		    = 0.0;
	LET cNumCuenta			= "";
	LET cBanco				= "";
	LET cDescBanco			= "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
            LET cDescRet = cErrorInfo;
			RETURN cCodRet,cDescRet,mImporte,cNumCuenta,cBanco,cDescBanco;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/respaldosbd/has/sp_cce_consultarchequexpresentar.out';
	--TRACE ON;

	IF NVL(pEmpresa,"") = "" OR NVL(pCtaDeposito,"") = "" OR NVL(pNumCheque,"") = ""  OR NVL(pFechaPresentacion,"") = "" THEN
        LET cCodRet = "000001";
        LET cDescRet = "FALTAN PARAMETROS DE ENTRADA";
		RETURN cCodRet,cDescRet,mImporte,cNumCuenta,cBanco,cDescBanco;
	ELSE
        FOREACH	WITH HOLD
            SELECT doc.monto, doc.numcuenta, ba.banco, ba.descripcion
            INTO mImporte, cNumCuenta, cBanco, cDescBanco
            FROM "informix".sc_docret_sbc doc, bditef:"informix".cce_cheques_det cce, bdinteg:"informix".si_bancos ba
            WHERE doc.empresa = pEmpresa
            AND doc.banco = ba.banco
            AND doc.transacc IN (SELECT transacc FROM bditef:cce_mapeo_cecoban where empresa = pEmpresa and transacc = transacc and tipo_cta_dep = tipo_cta_dep)
            AND doc.cancelado = "T"
            AND doc.banco = cce.cvebanco
            AND doc.numcuenta::INT8 = cce.numcuenta::INT8
            AND doc.num_chq = cce.numcheque::INTEGER
            AND cce.fechapresenta = pFechaPresentacion
            AND cce.presentado = "0"
            AND doc.cuenta::INT8 = pCtaDeposito::INT8
            AND doc.num_chq = pNumCheque
			
            RETURN cCodRet,cDescRet,NVL(mImporte,0),NVL(cNumCuenta,""),NVL(cBanco,""),NVL(cDescBanco,"") WITH RESUME;
        END FOREACH	
        IF dbinfo("sqlca.sqlerrd2") = 0 THEN
            LET cCodRet = "000002";
            LET cDescRet = "NO EXISTEN DATOS";
            RETURN cCodRet,cDescRet,mImporte,cNumCuenta,cBanco,cDescBanco;
        END IF
	END IF
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener los datos de los cheques que no se encuentran presentados porque tienen fecha de presentacion anterior a la fecha de hoy del sistema', 
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Febrero 2013',
'VERSION: 20130222.1720';

CREATE PROCEDURE "informix".sp_cce_consultarchqsxpresentar
(
pEmpresa            CHAR(3)
)
RETURNING
	CHAR(6)         AS cod_ret,
    CHAR(80)        AS desc_ret,
	CHAR(4)         AS sucursal,
	CHAR(40)        AS desc_sucursal,
	CHAR(10)        AS fecha_presentacion,
	CHAR(20)        AS cuenta_deposito,
	CHAR(3)         AS cve_banco,
	CHAR(40)        AS desc_banco,
	CHAR(20)        AS cuenta_cheque,
	INTEGER        	AS numero_cheque,
	MONEY(14,2)     AS importe,
	CHAR(10)		AS fecha_hoy
	
	---DECLARACIONES
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cErrorInfo       CHAR(80);
    DEFINE cDescRet         CHAR(80);
    DEFINE cCodRet          CHAR(6);

	DEFINE cSucursal		CHAR(4);
	DEFINE cDescSucursal	CHAR(40);
	DEFINE cFechaPres		CHAR(10);
	DEFINE cCtaDeposito		CHAR(20);
	DEFINE cBanco           CHAR(3);
	DEFINE cDescBanco       CHAR(40);
	DEFINE cCtaDelCheque    CHAR(20);
	DEFINE iNumCheque    	INTEGER;
	DEFINE mImporte         MONEY(14,2);
	DEFINE cFechaHoy		CHAR(10);

	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= "";
    LET cDescRet		    = "PROCESO EXITOSO";
	LET cCodRet				= "000000";
	
	LET cSucursal			= "";
	LET cDescSucursal		= "";
	LET cFechaPres			= "";
	LET cCtaDeposito		= "";
	LET cBanco				= "";
	LET cDescBanco			= "";
	LET cCtaDelCheque		= "";
	LET iNumCheque    		= 0;
    LET mImporte		    = 0.0;
	LET cFechaHoy			= "";
	


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
            LET cDescRet = cErrorInfo;
			RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/respaldosbd/has/sp_cce_consultarchqsxpresentar.out';
	--TRACE ON;

	IF NVL(pEmpresa,"") = "" THEN
        LET cCodRet = "000001";
        LET cDescRet = "FALTAN PARAMETROS DE ENTRADA";
		RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy;
	ELSE
		--OBTIENE LA FECHA DEL SISTEMA
		SELECT fecha_hoy
		INTO cFechaHoy
		FROM "informix".sc_fechas;
		
        FOREACH	WITH HOLD
			SELECT doc.sucursal, suc.nombre, cce.fechapresenta, doc.cuenta AS CTA_DEPOSITO, ba.banco, ba.descripcion, doc.numcuenta AS CTA_CHEQUE, doc.num_chq, doc.monto
			INTO cSucursal, cDescSucursal, cFechaPres, cCtaDeposito, cBanco, cDescBanco, cCtaDelCheque, iNumCheque, mImporte
			FROM "informix".sc_docret_sbc doc, bditef:"informix".cce_cheques_det cce, bdinteg:"informix".si_bancos ba, bdinteg:"informix".si_sucursales suc
			WHERE doc.empresa = pEmpresa
			AND doc.banco = ba.banco
			AND doc.transacc IN (SELECT transacc FROM bditef:cce_mapeo_cecoban where empresa = pEmpresa and transacc = transacc and tipo_cta_dep = tipo_cta_dep)
			AND doc.cancelado = "T"
			AND doc.banco = cce.cvebanco
			AND doc.numcuenta::INT8 = cce.numcuenta::INT8
			AND doc.num_chq = cce.numcheque::INTEGER
			AND cce.fechapresenta < cFechaHoy
			AND cce.presentado = "0"
			AND doc.sucursal = suc.sucursal
			
            RETURN cCodRet,cDescRet,NVL(cSucursal,""),NVL(cDescSucursal,""),
				SUBSTR(cFechaPres,7,4) || "/" || SUBSTR(cFechaPres,1,2) || "/" || SUBSTR(cFechaPres,4,2),
				NVL(cCtaDeposito,""),NVL(cBanco,""),NVL(cDescBanco,""),NVL(cCtaDelCheque,""),NVL(iNumCheque,0),NVL(mImporte,0.0)
				,NVL(SUBSTR(cFechaHoy,7,4) || "/" || SUBSTR(cFechaHoy,1,2) || "/" || SUBSTR(cFechaHoy,4,2),"") 
			WITH RESUME;
        END FOREACH	
        IF dbinfo("sqlca.sqlerrd2") = 0 THEN
            LET cCodRet = "000002";
            LET cDescRet = "NO EXISTEN DATOS";
            RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy;
        END IF
	END IF
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener los datos de los cheques que no se encuentran presentados porque tienen fecha de presentacion anterior a la fecha de hoy del sistema', 
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Febrero 2013',
'VERSION: 20130222.1720';

CREATE PROCEDURE "informix".sp_actnumcheques() 
RETURNING CHAR(5), CHAR(80);
--DEFINICION DE VARIABLES
DEFINE vc_CodRet			CHAR(5);
DEFINE vi_SqlErr			INTEGER;
DEFINE vi_iSAMErr			INTEGER;
DEFINE vi_iSAMData			CHAR(80);
DEFINE vc_Mensaje			CHAR(80);
DEFINE cCuenta			    CHAR(20);
DEFINE inumeroconteo		INTEGER;
DEFINE inumerochq			INTEGER;
--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET vi_iSAMErr=0;
LET vi_iSAMData="";
LET vc_Mensaje = "EL PROCESO SE EFECTUO CORRECTAMENTE";
LET cCuenta="";
LET inumeroconteo=0;
LET inumerochq=0;


    BEGIN

    ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            LET vc_Mensaje = "ERROR NO CONTROLADO";
            RETURN vc_CodRet, vc_Mensaje;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/informix/VH/chequeras/sp_actnumcheques.out";
    --TRACE ON;

	SET ISOLATION TO DIRTY READ;
	FOREACH

		SELECT cuenta,max(numero) INTO cCuenta,inumeroconteo FROM sc_contch
		WHERE cuenta IN (
		SELECT DISTINCT cuenta FROM sc_contch)
		GROUP BY cuenta
		ORDER BY cuenta

		SELECT ult_chq INTO inumerochq FROM sc_maechq WHERE empresa='001' AND cuenta=cCuenta;
		
		IF inumeroconteo<>inumerochq THEN
			UPDATE "informix".sc_maechq SET ult_chq = inumeroconteo WHERE empresa='001' AND cuenta=cCuenta;
		END IF;

	END FOREACH;  

	RETURN vc_CodRet, vc_Mensaje;
END;
END PROCEDURE;