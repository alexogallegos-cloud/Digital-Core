CREATE PROCEDURE "informix".sp_calculo_cat_publicidad(cProducto DECIMAL,cCredito DECIMAL, cTasa DECIMAL)
RETURNING CHAR(5) AS CodRet,DECIMAL AS cat,DECIMAL AS Comision,DECIMAL AS Anualidad;
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRet CHAR(5);
    
    DEFINE cComision    DECIMAL;
    DEFINE cAnualidad   DECIMAL;
  
    DEFINE  i               INTEGER;
    
    DEFINE  vPmin           DECIMAL;
    DEFINE  vCod_comision   DECIMAL;   
    DEFINE  vComision       DECIMAL;
    DEFINE  vAnualidad      DECIMAL;
    DEFINE  vCobranza       DECIMAL;
    DEFINE  vSaldo          FLOAT;
    DEFINE  vIntereses      FLOAT;
    DEFINE  vSaldos         FLOAT;
    DEFINE  vPago           FLOAT;
    DEFINE  vDisposicion	FLOAT;
    DEFINE  vFlujo_Neto     FLOAT;

    
    DEFINE guess            DECIMAL(20, 5);
    DEFINE epsilon          DECIMAL(20, 5);
    DEFINE iterations       INTEGER;
    DEFINE npv              DECIMAL(32, 5);
    DEFINE tir              DECIMAL(20, 5);
    DEFINE cat              DECIMAL(32, 5);

	DEFINE vBanderaComisionApertura	CHAR(1);

     -- Establecer valores iniciales
    LET guess = 0.1;        -- Valor inicial 
    LET epsilon = 0.00001;  -- Valor segun necesidades
    LET iterations = 100;   -- Valor segun necesidades
    
    
    LET cCodRet     = '00000';
    LET cat         = '00000';
    LET cComision   = '00000';
    --LET cTasa       = '00000';
    LET cAnualidad  = '00000';
	LET vBanderaComisionApertura = '0';

    BEGIN
        
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;

                RETURN cCodRet,cat,cComision,cAnualidad;
            END IF;
        END EXCEPTION;
        
        --SET DEBUG FILE TO '/home/e99805728/sp_calculo_cat_publicidad.out';
		--SET DEBUG FILE TO '/ifxsif01/aastorga/sp_calculo_cat_publicidad2.out';
        --TRACE ON;

        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;


        TRUNCATE TABLE sd_calc_cat_calculo;

        ----------MES 1 Periodo 0 , 
        ----------------------------
        INSERT INTO sd_calc_cat_calculo ( Mes, Periodo, Linea, Comision, Anualidad, Cobranza, Saldo, Intereses, Saldos, Pago, Disposicion, Flujo_Neto )
        VALUES (1,0,cCredito,0,0,0,0,0,0,0,cCredito,-cCredito);  
        ----------------------------
        ----------------------------
              
        
        IF cProducto = 6600 THEN
           LET vAnualidad = 0 ;
        ELSE
            SELECT monto    -- Anualidad
            INTO cAnualidad
            FROM sd_tpcomis
            WHERE cod_comis = 
                CASE cProducto
                    WHEN 8500 THEN 'CATG'
                    WHEN 8100 THEN 'CAOT'
                    WHEN 7000 THEN 'CAPT'
                    WHEN 6001 THEN 'CAVT'
		    WHEN 5400 THEN 'CA54'
                END; 
        END IF;
        
        --Agregar validacion de bandera para definir monto a cobrar por anualidad
		
        SELECT d.factor_pago_min,d.cod_comision_apertura, d.cobro_comis_apertura, NVL(t.monto,0.00)  
        INTO vPmin,vCod_comision, vBanderaComisionApertura, vComision
        FROM sd_definicion d            
        LEFT JOIN sd_tpcomis t
        ON (t.cod_comis = d.cod_comision_apertura
			AND t.empresa = d.empresa)
        WHERE  d.num_producto = cProducto
		AND d.empresa = '001';
        
        LET cComision = 0;
        LET vCobranza = 0;

        IF vComision > 0.00 THEN 
            LET cComision = vComision;
        END IF ;
		
		IF vBanderaComisionApertura = '1' THEN
			LET cAnualidad = 0;
		END IF;
		
        -- i = Periodos
        FOR i = 1 TO 36
            IF i IN (1, 13, 25) THEN
             LET vAnualidad = cAnualidad;
            ELSE
                LET vAnualidad = 0 ;
            END IF ; 
            
            SELECT Saldos,Pago,Disposicion 
            INTO vSaldos,vPago,vDisposicion
            FROM sd_calc_cat_calculo
            WHERE Mes = i;
            
            LET vSaldo  = ROUND (vSaldos - vPago + vDisposicion, 6);
            LET vIntereses = ROUND ((((vSaldo * cTasa ) / 360)*30)/100, 6);
            LET vSaldos = ROUND (vComision + vAnualidad + vCobranza + vSaldo + vIntereses, 6);
        
            IF i = 36 THEN
             
                LET vPago = vSaldos;                
                LET vDisposicion = 0;
                
            ELSE
                LET vPago = ROUND ((vSaldos  * vPmin)/100, 6);
                
                IF cCredito < (vSaldos - vPago ) THEN
                 
                    LET vDisposicion = 0;
                ELSE
                
                    LET vDisposicion = ROUND (cCredito - (vSaldos - vPago ), 6);
                END IF;    
            END IF;            
        
            LET vFlujo_Neto = ROUND(vPago - vDisposicion,6);
            
            INSERT INTO sd_calc_cat_calculo( Mes, Periodo, Linea, Comision, Anualidad, Cobranza, Saldo, Intereses, Saldos, Pago, Disposicion, Flujo_Neto )
            VALUES (i+1,i,cCredito,vComision,vAnualidad,vCobranza,vSaldo,vIntereses,vSaldos,vPago,vDisposicion,vFlujo_Neto);         
        
            LET vComision = 0 ;
            
        END FOR;

            -- Calcular la TIR utilizando el metodo de Newton-Raphson
        LET tir = guess;
        LET npv = (SELECT SUM(flujo_neto / POWER(1 + tir, mes)) FROM sd_calc_cat_calculo);
        LET iterations = iterations - 1;

        WHILE ABS(npv) > epsilon AND iterations > 0
            LET tir = tir - npv / (SELECT SUM(-mes * flujo_neto / POWER(1 + tir, mes + 1)) FROM sd_calc_cat_calculo);
            LET npv = (SELECT SUM(flujo_neto / POWER(1 + tir, mes)) FROM sd_calc_cat_calculo);
            LET iterations = iterations - 1;
        END WHILE;

        LET cat = POWER(1 + tir,12) - 1;

        RETURN cCodRet,cat,cComision,cAnualidad;
    END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento que devuelve el CAT del producto con el limite recibido', 
'AUTOR : Adrian Curiel',
'Folio: RQM 10 1491 Automatizacion Calculo de CAT publicitario',
'Solicita: Christian Yair Rojas Velazquez',
'FECHA : 25/01/2024',

'MODIFICO :Jorge Arturo Astorga Martinez',
'DESCRIPCION:  Se agrego validacion de la bandera cobro_comis_apertura.',
'FECHA : 18/06/2024',

'MODIFICO :Jorge Arturo Astorga Matinez',
'DESCRIPCION:  En la consulta donde se recupera el monto de la anulidad se agrego < WHEN 5400 THEN CA54 >,', 
'tambien, se agrego un join para realizar la asignacion de forma correcta',
'FECHA : 11/07/2024',

'MODIFICO :Keevyn Adrian Gil Valenzuela',
'DESCRIPCION: Se corrige validaciÃ³n para cuando la bandera cobro_comis_apertura estÃ© encendida, se cobra $0 de anualidad,', 
'Se recibe parametro de la tasa del credito',
'FECHA : 20/11/2024';

CREATE PROCEDURE "informix".sp_buscarctesamigrar_web(pnumcte CHAR(20),iOpcion INTEGER, pSucursal CHAR(4), pNombreEmbozado CHAR(60), pNumEjecutivo CHAR(8), pMigracionVisaActiva CHAR(1))
RETURNING	 CHAR(6), --Codigo Retorno
             CHAR(20), --Numero de Cliente
			 CHAR(20), --Numero de Credito
			 CHAR(60), --Direccion de la sucursal
			 CHAR(4), --Sucursal
			 CHAR(1), -- Bandera Verifica Estatus
			 CHAR(20),--Descripcion Estatus
			 CHAR(20),-- Fecha de solicitud
			 CHAR(10),--MONTO LINEA
			 CHAR(10),--IVA
			 CHAR(10),--INTERES MORATORIO
			 CHAR(10),--INTERES ORDINARIO
			 CHAR(6),--BIN
			 CHAR(8),--CODIGO DEL PRODUCTO
			 CHAR(8); --CLAVE TAJETA
			
             										 
DEFINE iSqlerr				INTEGER;
DEFINE iExiste				INTEGER;
DEFINE cCodret				CHAR(5);
DEFINE cCliente     		CHAR(20);
DEFINE cSucursal    		CHAR(20);
DEFINE iFlagstatus  		CHAR(1);
DEFINE cStatus      		CHAR(20);
DEFINE cFchsoli     		CHAR(20);
DEFINE cNomSuc      		CHAR(60);
DEFINE cLineaCredito 		CHAR(10);
DEFINE cCat          		CHAR(10);
DEFINE cInteresOrdinario 	CHAR(10);
DEFINE cInteresMoratorio 	CHAR(10);
DEFINE cCodBin      		CHAR(6);
DEFINE cCodProd 			CHAR(8);
DEFINE cCodClaveTar 		CHAR(8);
DEFINE cNumCredito 			CHAR(20);
DEFINE cDireccionSucursal 	CHAR(80);
DEFINE cSolOro 				VARCHAR(20);
DEFINE cLineaTeorica 		DECIMAL(18,2);
DEFINE v_valor		 		MONEY(14,2);
DEFINE v_capacidad_pago 	MONEY(14,2);
DEFINE iPlazo 				INTEGER; 
DEFINE sNombreCliente 		CHAR(100);
DEFINE sNumTarjeta			CHAR(16);
DEFINE sMiembro				CHAR(2);
DEFINE sCodRetOro           CHAR(6);
DEFINE sMsjRetOro           VARCHAR(100);

LET sCodRetOro              = '';
LET sMsjRetOro              = '';
--INICIALIZANDO VARIABLES
LET iSqlerr    			= 0;
LET iExiste	   			= 0;
LET cCodret    			= "00000";
LET cCliente  	 		= "";
LET iFlagstatus			= "";
LET cStatus    			= "";
LET cFchsoli   			= "";
LET cSucursal  			= "";
LET cNomSuc    			= "";
LET cLineaCredito		= "";
LET cCat                = "";
LET cInteresOrdinario	= "";
LET cInteresMoratorio	= "";
LET cCodBin				= "";
LET cCodProd			= "";
LET cCodClaveTar		= "";
LET cNumCredito 		= "";
LET cDireccionSucursal 	= "";
LET cSolOro 			= "";
LET cLineaTeorica 		= "";
LET v_valor		  		= 0;
LET v_capacidad_pago 	= 0;
LET iPlazo 		  		= 0;
LET sNombreCliente		= "";
LET sNumTarjeta			= "";
LET sMiembro			= "";


BEGIN
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCodret = iSqlerr;
			RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/home/sysifx/Oscar/736/sp_buscarctesamigrar.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF pnumcte IS NULL OR pnumcte = '' OR iOpcion is NULL  THEN
		LET cCodret="00100";
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
	

	SELECT numcte,num_credito,nomsuc,sucursal,flagstatussol,status,fchsoli 
	INTO cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli
	FROM bdicred:"informix".sd_ctesamigrar WHERE numcte = TRIM(pnumcte);
   
	IF iOpcion=0  THEN
		IF DBINFO("sqlca.sqlerrd2") = '0' THEN -- No existe el cliente
			LET cCodret="00001";
			RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
		ELSE
			IF (iFlagstatus IS NULL OR iFlagstatus='' OR iFlagstatus=3) THEN
				RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
			END IF;
		END IF;
	END IF;
	
	IF iOpcion=1  THEN -- Solicitud Rechazada
		IF NVL(pSucursal,'') = '' THEN
			LET cCodret="00100";
		ELSE
			SELECT TRIM(suc.nombre), (TRIM(nvl(suc.direccion1,'')) || ", " || TRIM(nvl(suc.direccion2,'')) || ", " || TRIM(nvl(ciu.nombre,'')) || ", " || TRIM(nvl(est.nombre,''))) As Direccion  -- CAX se modifica para evitar error en update sd_ctesamigrar
			INTO cNomSuc,cDireccionSucursal
			FROM bdinteg: "informix".si_sucursales suc
			LEFT JOIN bdinteg: "informix".si_estados est
			ON est.estado = suc.estado
			LEFT JOIN bdinteg: "informix".si_ciudades ciu
			ON suc.ciudad = ciu.ciudad and suc.estado = ciu.estado
			WHERE  suc.empresa = '001'
			AND sucursal = pSucursal
			AND suc.tpo_sucursal = 'S';
			
			UPDATE  bdicred:"informix".sd_ctesamigrar SET  flagstatussol='3',status="Rechazada",fchsoli=TO_CHAR(current), sucursal = pSucursal, nomsuc =  cNomSuc, domsuc = TRIM(cDireccionSucursal) WHERE numcte=pnumcte;
		END IF;
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
   
	IF iOpcion=2 THEN -- Solicitud Aceptada
		IF NVL(pSucursal, '') = '' OR NVL(pNombreEmbozado,'') = '' OR NVL(pNumEjecutivo,'') = '' THEN
			LET cCodret="00100";
		ELSE
			SELECT TRIM(suc.nombre), (TRIM(nvl(suc.direccion1,'')) || ", " || TRIM(nvl(suc.direccion2,'')) || ", " || TRIM(nvl(ciu.nombre,'')) || ", " || TRIM(nvl(est.nombre,''))) As Direccion -- CAX se modifica para evitar error en update sd_ctesamigrar
			INTO cNomSuc,cDireccionSucursal
			FROM bdinteg: "informix".si_sucursales suc
			LEFT JOIN bdinteg: "informix".si_estados est
			ON est.estado = suc.estado
			LEFT JOIN bdinteg: "informix".si_ciudades ciu
			ON suc.ciudad = ciu.ciudad and suc.estado = ciu.estado
			WHERE  suc.empresa = '001'
			AND sucursal = pSucursal
			AND suc.tpo_sucursal = 'S';			
			
			SELECT TRIM(apell_paterno) || " " || TRIM(apell_materno) || " " || TRIM(nombre1) || " " || TRIM(nombre2) AS Nombre, b.num_tarjeta , SUBSTR(YEAR(c.fecha_apertura),3,2)
			INTO sNombreCliente, sNumTarjeta, sMiembro
			FROM bdicred:"informix".sd_ctesamigrar a			
			INNER JOIN bdicred:"informix".sd_tarjeta b ON a.num_credito = b.num_credito
			INNER JOIN bdicred:"informix".sd_maecred c ON c.num_credito = a.num_credito
			WHERE a.numcte = pnumcte 
			AND a.num_credito = cNumCredito 
			AND b.numcte = a.numcte
			AND c.numcte = b.numcte
			AND b.status_tar in ('A','C') 
			AND b.secuencia = (select max(secuencia) from bdicred:"informix".sd_tarjeta b WHERE B.num_credito = cNumCredito);  
			
			UPDATE  bdicred:"informix".sd_ctesamigrar SET  flagstatussol = '1',status = "Aceptada", fchsoli = TO_CHAR(current), sucursal = pSucursal, nomsuc =  cNomSuc, domsuc = TRIM(cDireccionSucursal) 
			WHERE numcte = pnumcte;
			
			LET sNombreCliente = REPLACE(sNombreCliente,"  ", " ");
			
			--INSERT INTO bdicred:"informix".sd_credito_upgrade(empresa, num_credito, numcte, numerotarjeta, numero_credito_upgrade, numerotarjeta_upgrade, num_producto_upgrade, tipotar, nombre, nombre_embosado, bandtarjpersonal, tipo_proceso, nombre_archivo, master, tipo_dom, miembro, resultado, bclonadocompleto, user_insert, fecha_insert, fecha_cancelaupgrade)
			--VALUES('001', cNumCredito, pnumcte, sNumTarjeta, '', '', '8100', 'TIT', TRIM(sNombreCliente), TRIM(pNombreEmbozado), '1', '1', '', '1', '1', sMiembro, '0', '0', pNumEjecutivo,CURRENT,NULL);

            EXECUTE PROCEDURE "informix".sp_graba_prod_upgrade('001', cNumCredito, pnumcte, sNumTarjeta, 'TIT', TRIM(sNombreCliente), 
             TRIM(pNombreEmbozado), '1', '1', pNumEjecutivo, '3', '', '8100') INTO sCodRetOro, sMsjRetOro;
			 LET sCodRetOro = SUBSTR(sCodRetOro, 2,5);
		
		    IF sCodRetOro <> "00000" THEN  -- Error en sp_graba_prod_upgrade
                LET cCodret = sCodRetOro;    
                UPDATE  bdicred:"informix".sd_ctesamigrar SET  flagstatussol = null,status = '', fchsoli = '' 
                WHERE numcte = pnumcte;
                    
                RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
            END IF
			
		END IF;		
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
  
	IF iOpcion=3 THEN
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
  
	IF iOpcion=4 THEN
	  --SE OBTIENE EL VALOR DE LA TASA DE INTERES ORDINARIO
	  SELECT a.valor,b.cat_caratula,b.monto_min_cred INTO cInteresOrdinario,Ccat,cLineaCredito
	  FROM bdinteg:"informix".si_fechavalor AS a,bdicred:"informix".sd_definicion AS b
	  WHERE a.tasa = b.cod_tasa_base AND fecha = (SELECT MAX(fecha)
	  FROM bdinteg:"informix".si_fechavalor
	  WHERE  tasa=b.cod_tasa_base)    --
	  AND b.num_producto = '8100';

	--SE OBTIENE EL VALOR DE LA TASA DE INTERES MORATORIO
	  SELECT a.valor INTO cInteresMoratorio
	  FROM bdinteg:"informix".si_fechavalor AS a, bdicred:"informix".sd_definicion AS b
	  WHERE a.tasa = b.cod_tasa_mora AND fecha = (SELECT MAX(fecha)
	  FROM bdinteg:"informix".si_fechavalor 
	  WHERE  tasa=b.cod_tasa_mora) AND b.num_producto = '8100';  -- FMV 13-MAY-11 SE OMITE a.tasa para mostrar las tasas en reporte
	  LET cInteresMoratorio = cInteresMoratorio - cInteresOrdinario;
		IF cInteresMoratorio < 0 THEN
				LET cInteresMoratorio= cInteresMoratorio * -1;
		END IF;
	RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
 
	IF iOpcion=5 then
		if pMigracionVisaActiva = '1' then
			let cCodProd = '008';
			let cCodClaveTar = '100';
		else 
			let cCodProd = '005';
			let cCodClaveTar = '007';
		end if;

		SELECT codproductotarjeta,clave_tipotarjeta,bin  
		INTO cCodProd,cCodClaveTar,cCodBin 
		FROM intercard:"informix".tipotarjeta 
		WHERE codproductotarjeta = cCodProd
		AND Tipo = 'C'
		AND clave = cCodClaveTar;
		
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
	
	IF iOpcion = 6 THEN
		IF NVL(pnumcte,'') = '' THEN
			LET cCodret="00100";
		ELSE
			DELETE bdicred:"informix".sd_credito_upgrade WHERE numcte = pnumcte AND num_credito = cNumCredito;		
			UPDATE bdicred:"informix".sd_ctesamigrar SET sucursal = '',nomsuc = '',domsuc = '',flagstatussol = null,status = '',fchsoli = '' WHERE numcte = pnumcte;
			RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
		END IF;
	END IF;
	
  
END;
END PROCEDURE
DOCUMENT
'Se crea SP para consultar los  de clientes candidatos a actualizar su Tarjeta de Credito Visa Bancoppel a Tarjeta de Credito Oro Bancoppel',
'asi como actualizar su estatus (Aceptada, Rechazada) e insertar la solicitud.',
'AUTOR : Oscar Marquez 98681011',
'FECHA : 26/03/2021',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_reporte_pagos_atm()
RETURNING CHAR(5),     -- Codigo de Retorno
          CHAR(80);   -- Mensaje de retorno
		    

---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(5);
DEFINE cMensajeRet		CHAR(80);

DEFINE cRuta 			CHAR(80);
---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_bloqueocuenta
DEFINE cBCCodret		CHAR(6);   
DEFINE CBCMensajeRet	CHAR(80); 

DEFINE cSql            	CHAR(2600);
DEFINE cNombreArchivo  	CHAR(100);
DEFINE cNombreArchivo1  CHAR(100);
DEFINE cConsulta		CHAR(2300);
DEFINE cEncabezado		CHAR(2300);


---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET iSecuencia			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '00000';
LET cMensajeRet			= 'Proceso Exitoso';
LET cRuta 				= "";
---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_bloqueocuenta
LET cBCCodret		= "";
LET CBCMensajeRet   = "";
LET cSql			= '';
LET cNombreArchivo  = '';
LET cNombreArchivo1  = '';
LET cConsulta		= '';
LET cEncabezado		= '';

BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr
   IF iSqlErr != 0 THEN
	  LET cCodRet = iSqlErr;
	  LET cMensajeRet = iIsamErr;
	  RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/informix/IvanZazueta/sp_reporte_pagos_atm.out";
--TRACE ON;

SET ISOLATION TO dirty READ;
SET LOCK MODE TO WAIT 3;
--SET ISOLATION COMMITTED READ;
--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

--RUTA PARA GENERAR EL ARCHIVO
SELECT valor
INTO cRuta
FROM "informix".sd_param  
WHERE empresa = '001' 
AND cod_param='49';

--SINO EXISTE LA RUTA DEL ARCHIVO	
IF dbinfo("sqlca.sqlerrd2") = 0 THEN
	LET cCodRet = '00001';
	LET cMensajeRet ='NO EXISTE PARAMETRO DE LA RUTA PARA GENERAR EL ARCHIVO';
	RETURN cCodRet,cMensajeRet;
END IF;	 

--GENERA EL NOMBRE DEL ARCHIVO
LET cNombreArchivo = TRIM('concil_cob_atm_')||TO_CHAR(TODAY - 1,'%y%m%d')|| '.txt';
--LET cNombreArchivo1 = TRIM('SaldosInmateriales_aux')||TO_CHAR(TODAY,'%d%m%y')|| '.txt';
		
--SELECCIONA LOS DATOS QUE FUERON INSERTADOS EN LA TABLA 
LET cConsulta = "SELECT a.fecha, a.cajero, a.hora, a.folio, a.num_credito, a.monto_pagado, " 
				|| "CASE WHEN a.transacc IN ('0555', '0556', '0557', '0558', '0559', '0560', '0561') THEN " || "'Pago en Efectivo'" || " ELSE " 
                || " a.num_cuenta_tdd " || " END, " 
                || "CASE WHEN a.transacc IN ('0555', '0556', '0557', '0558', '0559', '0560', '0561') THEN " || "0.00" || " ELSE " 
                || " a.monto_pagado " || " END,0 " 
				|| "FROM bdicred:sd_pagos_reporte_atm a INNER JOIN bdicred:sd_definicion b ON b.num_producto = a.num_producto " 
				|| "WHERE fecha = TODAY - 1 AND a.codigo_retorno_bd = '00000' ORDER BY a.secuencia; " ;

--CREACION DE TEMPORALESS USADOS PARA LA CREACION DE ARCHIVO
LET cSql = '';
LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRuta)||TRIM(cNombreArchivo)||' DELIMITER '||'''|'''||' '||TRIM(cConsulta)||' "> '|| TRIM(cRuta) ||'pagos_atm.sql';
SYSTEM TRIM(cSql);

LET cSql = '';
LET cSql = "dbaccess bdicred "|| TRIM(cRuta) || "pagos_atm.sql";
SYSTEM TRIM(cSql);

/*
LET cSql = cSql;
LET cSql = "sed 's/|$SYSTEM cSql;
*/
	
--BORRADO DE TEMPORALES QUE FUERON USADOS PARA LA CREACION DE ARCHIVO
LET cSql = '';
LET cSQL = "rm "||TRIM(cRuta)||'pagos_atm.sql';		
SYSTEM TRIM(cSql); 
/*
LET cSQL = '' ;
LET cSQL = 'rm ' || TRIM(cruta) || cNombreArchivo1;
SYSTEM cSQL;   
*/
RETURN cCodRet,cMensajeRet;

END
END PROCEDURE
;