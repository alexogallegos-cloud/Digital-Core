CREATE PROCEDURE "informix".sp_ctedigital_enviaxml()

--RETORNOS-
RETURNING
CHAR(6)       AS codret,
CHAR(20)      AS numcte,
INTEGER       AS consecutivo,
CHAR(1660)    AS trama_xml;


--DECLARACION DE VARIABLES--
DEFINE iSql_err		    INTEGER; 
DEFINE cCodret		    CHAR(6);
DEFINE cNumcte          CHAR(20);
DEFINE iConsecutivo     INTEGER;
DEFINE cCodRetXml       CHAR(6);
DEFINE cTramaXml        CHAR(1660);
DEFINE cenviar          INTEGER;


--INICIALIZACION DE VARIABLES--
LET iSql_err		    = 0;
LET cCodret		        = '000000';
LET cNumcte             = '';
LET iConsecutivo        = 0;
LET cCodRetXml          = '';
LET cTramaXml           = '';
LET cenviar             = 0;


--INICIO--
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err 
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN TRIM(cCodret), TRIM(NVL(cNumcte,'')), NVL(iConsecutivo,0), TRIM(NVL(cTramaXml,''));
		END IF;
	END EXCEPTION;
		
	--SET DEBUG FILE TO '/tmp/cyrv/sp_ctedigital_enviaxml.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  
	
	----------------CONTROL DE ERRORES POR PARAMETRO----------
	  
	 --************************************************************************************
	 ---------------****************BLOQUE DE CONSULTA*************************************
	 --************************************************************************************

    SELECT valor::INTEGER 
    INTO cenviar
    FROM si_param
    WHERE cod_param = 354;

	FOREACH WITH HOLD --SE AMARRA EL WITH HOLD PARA QUE CONTINUE EL BARRIDO DESPUES DE HACER EL UPDATE
		--SE SELECCIONA DE CADA CLIENTE EL REGISTRO CON EL CONSECUTIVO MAS ALTO, Y LA TRAMA XML RELACIONADA A ESE REGISTRO EN ESPECIFICO	
		SELECT FIRST cenviar a.num_cte_banco, a.consecutivo, a.xml
		INTO cNumcte, iConsecutivo, cTramaXml
		FROM "informix".si_clientes_digital a
		WHERE a.estatus_envio IS NULL
			
		LET cNumcte		= TRIM(cNumcte);
		LET cTramaXml	= TRIM(NVL(cTramaXml,''));
		LET cCodret		= '000000'; --SE INICIALIZA EL CODIGO DE RETORNO
		
		IF NVL(cTramaXml,'') = '' THEN --SI NO TIENE TRAMA GENERADA
			EXECUTE PROCEDURE "informix".sp_ctedigital_generaxml(cNumcte) INTO cCodRetXml, cTramaXml;
				IF cCodRetXml <> '000000' THEN
					CONTINUE FOREACH;
				END IF;
		END IF;
		
		RETURN TRIM(cCodret), NVL(cNumcte,''), NVL(iConsecutivo,0), cTramaXml WITH RESUME;
		
	END FOREACH;
	
	IF DBINFO('sqlca.sqlerrd2') = 0   THEN
		LET cCodret = '000003'; --NO HAY REGISTROS EN LA TABLA QUE ESTEN EN ESTATUS_ENVIO = 0
		RETURN TRIM(cCodret), TRIM(NVL(cNumcte,'')), NVL(iConsecutivo,0), TRIM(NVL(cTramaXml,''));
	END IF;
		
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÓN: PROCEDIMIENTO QUE ES MANDADO LLAMAR POR EL SERVICIO Y QUE LE DEVUELVE TODAS LAS TRAMAS QUE VAN A SER ENVIADAS A e-COMMERCE PARA DARSE DE ALTA EN EL SERVICIO COPPEL.COM.',
'FECHA: 15 DE NOVIEMBRE DE 2013',
'BASE DE DATOS: BDINTEG',
'CREADOR: CARLOS OCHOA VALENZUELA',
'VERSION: 20131115.1630';

CREATE PROCEDURE "informix".sp_cnsif_infoprod2(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cPRODUCTO CHAR(4))
							
				returning CHAR(5)  AS Cod_Retorno,
						  CHAR(4)  AS Codigo_Producto,
						  CHAR(40) AS Producto,
						  CHAR(1)  AS Paga_Interes,
						  CHAR(1)  AS Maneja_Chequera,
						  CHAR(2)  AS Edad_Minima,
						  CHAR(20) AS Desc_Tipo_Persona,
						  MONEY(14,2) AS Monto_Minimo_Apertura;
										
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;							
-- VARIABLES
DEFINE cDescProducto   		CHAR(40);
DEFINE cPagaInteres	   		CHAR(1);
DEFINE cManejaChequera 		CHAR(1);
DEFINE cEdadMinima     		CHAR(2);
DEFINE cCveTipoPersona      CHAR(2);
DEFINE cDescTipoPersona     CHAR(20);
DEFINE mMontoMinimoApertura MONEY(14,2);
 

--inicializando variables
LET  iexiste 			 = 0;
LET cCodRet 	   = "00000";
LET iSql_err 			= 0 ;	

LET cDescProducto	 	= "";
LET cPagaInteres		=  0;
LET cManejaChequera 	= "";
LET cEdadMinima         = "";
LET cCveTipoPersona     = "";
LET cDescTipoPersona    = "";
LET mMontoMinimoApertura = 0;


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet, cPRODUCTO, cDescProducto, cPagaInteres, cManejaChequera, cEdadMinima, cDescTipoPersona, mMontoMinimoApertura;
		END IF;
	END EXCEPTION;
	
	--  SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_infoprod2.out";
	--  TRACE ON;
	
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cPRODUCTO  = ''	THEN 
		LET cCodRet = "00054";
		RETURN
			cCodRet, cPRODUCTO, cDescProducto, cPagaInteres, cManejaChequera, cEdadMinima, cDescTipoPersona, mMontoMinimoApertura;
	END IF;	
    
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;

		IF cCodRet = '00028' THEN 
			RETURN cCodRet, cPRODUCTO, cDescProducto, cPagaInteres, cManejaChequera, cEdadMinima, cDescTipoPersona, mMontoMinimoApertura;
		END IF;			
	
      
            SELECT NVL(COUNT(num_producto),0) into iexiste FROM bdicred:sd_definicion WHERE num_producto= cPRODUCTO;
            IF iexiste  > 0 THEN 
          		
			SELECT nombre_prod,'N' as paga_interes, 'N' as maneja_chequera,edad_min, DECODE(tpo_persona,'1','01','2','02','3','03') as tipo_persona,'0' AS monto_minimo_apertura 
            INTO 
            cDescProducto,cPagaInteres,cManejaChequera,cEdadMinima,cCveTipoPersona,mMontoMinimoApertura
			FROM bdicred:sd_definicion
			Where num_producto = cPRODUCTO;	    

            SELECT descripcion
            INTO cDescTipoPersona
            FROM bdinteg:si_tipper
            WHERE tpo_persona = cCveTipoPersona;

            RETURN cCodRet, cPRODUCTO, cDescProducto, cPagaInteres, cManejaChequera, cEdadMinima, cDescTipoPersona, mMontoMinimoApertura;
			
			ELIF iexiste = 0  THEN            
            SELECT NVL(COUNT(nombre),0) into iexiste FROM bdinvers:sv_instrum Where cod_instrum = cPRODUCTO;
            IF iexiste  > 0 THEN 

            SELECT nombre, 'S' as paga_interes, 'N' as maneja_chequera,'18' as edad_minima, DECODE(tpper_valida,'1','01','2','02','3','03') as tipo_persona,mto_min_recom AS monto_minimo_apertura 
            INTO 
            cDescProducto,cPagaInteres,cManejaChequera,cEdadMinima,cCveTipoPersona,mMontoMinimoApertura
            FROM bdinvers:sv_instrum
            Where cod_instrum = cPRODUCTO;	

            SELECT descripcion
            INTO cDescTipoPersona
            FROM bdinteg:si_tipper
            WHERE tpo_persona = cCveTipoPersona;

            RETURN cCodRet, cPRODUCTO, cDescProducto, cPagaInteres, cManejaChequera, cEdadMinima, cDescTipoPersona, mMontoMinimoApertura;

			ELIF iexiste = 0  THEN  
			
            SELECT NVL(COUNT(producto),0) into iexiste FROM bdicheq:sc_producto WHERE producto  = cPRODUCTO;
            IF iexiste  = 0 THEN 
                LET cCodRet = "00057";
                RETURN 
                cCodRet, cPRODUCTO, cDescProducto, cPagaInteres, cManejaChequera, cEdadMinima, cDescTipoPersona, mMontoMinimoApertura;
            END IF;

            SELECT nombre as nombre_prod, paga_interes as paga_interes, val_chequeras as maneja_chequera,edad_minima, DECODE(tpper_valida,'1','01','2','02','3','03') as tipo_persona,mtominape AS monto_minimo_apertura 
            INTO 
            cDescProducto,cPagaInteres,cManejaChequera,cEdadMinima,cCveTipoPersona,mMontoMinimoApertura
            FROM bdicheq:informix.sc_producto
            Where producto = cPRODUCTO;	

            SELECT descripcion
            INTO cDescTipoPersona
            FROM bdinteg:si_tipper
            WHERE tpo_persona = cCveTipoPersona;

            RETURN cCodRet, cPRODUCTO, cDescProducto, cPagaInteres, cManejaChequera, cEdadMinima, cDescTipoPersona, mMontoMinimoApertura;
			END IF;
        END IF;    
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de los Productos BanCoppel. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  Producto.",
"FECHA : 02-03-2012",
"AUTOR: DANIEL REYES GUILLEN",
"FECHA : 18-04-2022",
"MODIFICACION: Se ajusta el procedimiento para que se busque el producto no solo por el primer digito",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_tasaprod2(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cPRODUCTO CHAR(4))
							
				returning CHAR(5)  AS Cod_Retorno,
						  DECIMAL(14,2) AS Saldo_Minimo,
						  DECIMAL(14,2) AS Saldo_Maximo,
						  DECIMAL(14,2) AS Tasa;
										
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;							
-- VARIABLES
DEFINE cCveTasa         CHAR(8);
DEFINE cRangoTasa       CHAR(1);
DEFINE decSaldoMinimo  	DECIMAL(14,2);
DEFINE decSaldoMaximo	DECIMAL(14,2);
DEFINE decTasa     		DECIMAL(9,6);
DEFINE cClavep              CHAR(1);




--inicializando variables
LET  iexiste 			 = 0;
LET cCodRet 	         = "00000";
LET iSql_err 			 = 0 ;	

LET decSaldoMinimo 	= 0;
LET decSaldoMaximo	= 0;
LET decTasa         = 0;
LET cClavep         ="";


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa;
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/mfinis/sp_cnsif_tasaprod2.out";
	--TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
        
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cPRODUCTO  = ''	THEN 
		LET cCodRet = "00054";
		RETURN
			cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa;
	END IF;	

	EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
	INTO cCodRet;

	IF cCodRet = '00028' THEN 
		RETURN cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa;
	END IF;		
	
    SELECT NVL(COUNT(num_producto),0) into iexiste FROM bdicred:sd_definicion WHERE num_producto= cPRODUCTO;
    
	IF iexiste>0 THEN

		SELECT cod_tasa_base
		INTO 
		cCveTasa
		FROM bdicred:sd_definicion
		WHERE num_producto = cPRODUCTO;

		SELECT rangofecha
		INTO
		cRangoTasa
		FROM si_tiptasa
		WHERE  tasa = cCveTasa;

		IF cRangoTasa = 'F' THEN
		
        	SELECT valor 
			INTO
			decTasa
			FROM si_fechavalor 
			WHERE tasa = cCveTasa
			AND fecha = (SELECT MAX(fecha) FROM si_fechavalor WHERE tasa = cCveTasa);	
				
				IF cPRODUCTO = '8900' THEN 
				LET decTasa = 0;
				END IF;
			
			RETURN 
			cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa;
		ELSE
            SET	ISOLATION TO DIRTY READ;
            FOREACH 		
                SELECT rangomin, rangomax, valor 
				INTO 
				decSaldoMinimo, decSaldoMaximo, decTasa
				FROM si_tasavlor
				WHERE  tasa = cCveTasa
				
				IF cPRODUCTO = '8900' THEN 
				LET decTasa = 0;
				END IF;
					
				RETURN 
				cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa WITH Resume;
					
			END FOREACH;
				
		END IF;	
    ELIF iexiste=0 THEN    
		SELECT NVL(COUNT(nombre),0) into iexiste FROM bdinvers:sv_instrum Where cod_instrum = cPRODUCTO;
		IF iexiste  > 0 THEN 		

       --SELECT mto_min_recom,mto_max_recom INTO decSaldoMinimo, decSaldoMaximo FROM bdinvers:sv_instrum Where cod_instrum = cPRODUCTO;

        FOREACH
        	SELECT valor 
			INTO
			decTasa
			FROM si_fechavalor 
			where tasa LIKE 'P%' ORDER BY valor 
			
				IF cPRODUCTO = '8900' THEN 
				LET decTasa = 0;
				END IF;

            RETURN 
            cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa WITH Resume;
        END FOREACH;

		ELSE
		
		SELECT NVL(COUNT(producto),0) into iexiste FROM bdicheq:sc_producto WHERE producto  = cPRODUCTO;
		
		IF iexiste  = 0 THEN 
			LET cCodRet = "00057";
			RETURN 
			cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa;
		END IF;

		SELECT tasa
		INTO 
		cCveTasa
		FROM bdicheq:sc_producto
		WHERE producto = cPRODUCTO;
			
		IF cCveTasa = 'INVCREC' THEN
    		SELECT valor_tasa
			INTO
			decTasa
			FROM si_tasa_mes
			WHERE tipo_tasa = 'P'
			AND fecha = (SELECT MAX(fecha) FROM si_tasa_mes WHERE tipo_tasa = 'P');
			
				IF cPRODUCTO = '8900' THEN 
				LET decTasa = 0;
				END IF;
				
			RETURN 
			cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa;
					
		END IF;

		SELECT rangofecha
		INTO
		cRangoTasa
		FROM si_tiptasa
		WHERE  tasa = cCveTasa;

		IF cRangoTasa = 'F' THEN
			
        	SELECT valor 
			INTO
			decTasa
			FROM si_fechavalor 
			WHERE tasa = cCveTasa;
			
				IF cPRODUCTO = '8900' THEN 
				LET decTasa = 0;
				END IF;
				
			RETURN 
			cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa;
		ELSE
            SET	ISOLATION TO DIRTY READ;
            FOREACH 		
                SELECT rangomin, rangomax, valor 
				INTO 
				decSaldoMinimo, decSaldoMaximo, decTasa
				FROM si_tasavlor
				WHERE  tasa = cCveTasa
				
				IF cPRODUCTO = '8900' THEN 
				LET decTasa = 0;
				END IF;
					
				RETURN 
				cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa WITH Resume;
					
			END FOREACH;
				
		END IF;	
		
		END IF;

    END IF;
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de las tasas asociadas a los Productos BanCoppel. ",
"El SP obtiene la información de la Base de Datos central de Informix, enviando como parámetro el  Producto.",
"FECHA : 02-03-2012",
"AUTOR: DANIEL REYES GUILLEN",
"FECHA : 18-04-2022",
"MODIFICACION: Se ajusta el procedimiento para que se busque el producto no solo por el primer digito",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_valida_folio_dubplicado(pFolio CHAR(55))
RETURNING CHAR(5) AS CodRet, CHAR(55) AS FolioClaro,  CHAR(55) AS FolioEncriptado;

	DEFINE vc_folioact CHAR(12);
	DEFINE vcCodRet CHAR(5);
	DEFINE viSqlErr INTEGER;
	DEFINE vcMensaje CHAR(55);	
	DEFINE vcValor CHAR(3);
	DEFINE vcNumFol SMALLINT;
	DEFINE vcLetra CHAR(1);
	DEFINE idx SMALLINT;
	DEFINE vn_tamanio SMALLINT;
	DEFINE vc_mensaje CHAR(55);
	DEFINE vFolioclaro CHAR(55);

	LET vcCodRet = '00000';
	LET viSqlErr = 0;
	LET vcMensaje = '';
	LET vcLetra = '';
	LET idx = 1;
	LET vn_tamanio = 0;
	LET vc_mensaje = '';
	LET vFolioclaro ='';
	
	--SET DEBUG FILE TO '/informix/JuanRivera/Traces/sp_valida_folio_dubplicado.out';
	--TRACE ON;
	
	IF NVL(pFolio, '') = '' OR pFolio IS NULL THEN 
		LET vcCodRet = '00003';
		LET vcMensaje = 'Valor Nulo';
		
		RETURN vcCodRet, vFolioclaro, vcMensaje;
	END IF;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
        ON EXCEPTION SET viSqlErr
            IF viSqlErr <> 0 then
                LET vcCodRet = viSqlErr;
                RETURN vcCodRet, vFolioclaro, vcMensaje;
            END IF;	
        END EXCEPTION; 	
         
		
		LET vn_tamanio = length(pFolio);
             
           IF LENGTH(pFolio) > 0 THEN
		     FOR idx in (1 to vn_tamanio)
                    LET vcLetra = SUBSTR(pFolio,idx,1);
                    
                    SELECT valor INTO vcValor 
                      FROM bdibpi:bpi_base_encripta
                     WHERE letra = vcLetra;
                     
                    LET vcMensaje = vcValor || vcMensaje;
                    
                END FOR;
			ELSE
					LET vcCodRet = '00003';
					LET vcMensaje = 'Valor Nulo';  
					LET vFolioclaro='';
					
				END IF;
		
			SELECT COUNT(folio_contrato) INTO vcNumFol 
						FROM bdinteg:si_bpiusuarios 
						WHERE folio_contrato = vcMensaje
						AND empresa ='001';
						
			IF vcNumFol > 0 THEN
				LET vcCodRet ='00002'; --Existe folio duplicado
				LET vc_mensaje = TRIM(vcMensaje);
				LET vFolioclaro= pFolio;
				
				RETURN vcCodRet, vFolioclaro, vcMensaje;
			END IF;	
			
		
		LET vcCodRet ='00000';
		LET vcMensaje = TRIM(vcMensaje);
		LET vFolioclaro=pFolio;
            
	    RETURN vcCodRet, vFolioclaro, vcMensaje;	    
    END;			
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para validar folio duplicado.',
'AUTOR : Juan Rivera',
'FECHA : 14 de Julio 2022',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_ctanvl2_generapdf_exp(pNumCte CHAR(20),pNumCta CHAR(20))
	RETURNING CHAR(5);

	DEFINE iSqlErr INTEGER;
    DEFINE iSamErr INTEGER;
    DEFINE cDesErr CHAR(50);
	DEFINE cCommand CHAR(500);
	DEFINE cSQL CHAR(500);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE cCodRet CHAR(5);
    DEFINE cCodRet2 CHAR(5);
    DEFINE cCodRet3 CHAR(50);
	DEFINE cRutaArchivo CHAR(100);
	DEFINE cNomReporte CHAR(40);
	--- DEFINE cComponente CHAR(20);
	DEFINE cCmd1 CHAR(500);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cFechaHr CHAR(14);
	DEFINE cNomPortada CHAR(40);
	DEFINE cNomPortadaB CHAR(40);
	DEFINE cNomContrato CHAR(40);
	DEFINE cNomCaratura CHAR(40);

	DEFINE cProducto CHAR(40);
	DEFINE cNombreCte CHAR(107);
	DEFINE cFechaNac CHAR(10);
	DEFINE cRfc CHAR(13);
	DEFINE cSucursal CHAR(50);
	DEFINE cOperacion CHAR(30);
	DEFINE cFechaOpe CHAR(30);
	DEFINE cFolioOpe CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cCtaClabe CHAR(20);
	DEFINE cTitular CHAR(104);
	DEFINE cAutorizaRevoc CHAR(2);
	DEFINE cReca CHAR(100);
	DEFINE cNombreBenef CHAR(104);
	DEFINE cPorcentaje CHAR(10);
	DEFINE cParentesco CHAR(40);
	DEFINE cProdCap CHAR(100);
	DEFINE cProdNom CHAR(100);
	DEFINE cProdGen CHAR(100);
	DEFINE cFecha CHAR(10);
	DEFINE cProd CHAR(4);
	DEFINE cNumCta CHAR(20);
	DEFINE cRutaArchivoImg CHAR(200);
	DEFINE cNombreArchivoImg CHAR(200);
    DEFINE cCorreoElec CHAR(50);
	DEFINE iCounter INTEGER;
	DEFINE cRcan CHAR(50);
	DEFINE cVar1 CHAR(50);
	DEFINE cVar2 CHAR(50);
	DEFINE cVar3 CHAR(50);
	DEFINE cVar4 CHAR(50);
	DEFINE cVar5 CHAR(50);
	DEFINE cVar6 CHAR(80);

	LET iSqlErr = 0;
    LET iSamErr = 0;
    LET cDesErr = '';
	LET cCommand = '';
	LET cSQL = '';
	LET cRutaInformix = '/ifxsif01/bin/';
	LET cUsrBin = '/usr/bin/';
	LET cCodRet = '000';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
	LET cRutaArchivo = '/tmp/mfinis/caratulasCuentaNivel2/';
	LET cNomReporte = '';
	--- LET cComponente = '';
	LET cCmd1 = '';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cFechaHr = TO_CHAR(CURRENT, '%Y%m%d%H%M%S');
	LET cNomPortada = '';
	LET cNomPortadaB = '';
	LET cNomContrato = '';
	LET cNomCaratura = '';

	LET cProducto = '';
	LET cNombreCte = '';
	LET cFechaNac = '';
	LET cRfc = '';
	LET cSucursal = '';
	LET cOperacion = ' ';
	LET cFechaOpe = '';
	LET cFolioOpe = '';
	LET cCuenta = '';
	LET cCtaClabe = '';
	LET cTitular = '';
	LET cAutorizaRevoc = '';
	LET cReca = '';
	LET cNombreBenef = '';
	LET cPorcentaje = '';
	LET cParentesco = '';
	LET cProdCap = '';
	LET cProdNom = '';
	LET cProdGen = '';
	LET cFecha = '';
	LET cProd = '';
	LET cNumCta =pNumCta;
	LET cRutaArchivoImg = '';
	LET cNombreArchivoImg = '';
    LET cCorreoElec = '';
	LET iCounter = 0;
	LET cRcan = '';
	LET cVar1 = '';
	LET cVar2 = '';
	LET cVar3 = '';
	LET cVar4 = '';
	LET cVar5 = '';
	LET cVar6 = '';
	
	BEGIN

    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO '/tmp/mfinis/caratulasCuentaNivel2/sp_ctanvl2_generapdf.err';
        TRACE ON;
        IF iSqlerr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO '/tmp/sp_ctanvl2_generapdf.out';
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 10;

    -- // VALIDA CAMPOS REQUERIDOS
    IF pNumCte IS NULL OR pNumCte = '' OR pNumCta IS NULL OR pNumCta = '' THEN
        LET cCodRet = '110';
        RETURN cCodRet;
    END IF;
    
    
    LET cCodRet = '000';
    RETURN cCodRet;

	END;
    
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 20/07/2020',
'DESCRIPCION: SPL encargado de realizar la ejecucion del componente Caratulas.jar para la generacion de los reportes en formato PDF.',
'BD: bdinteg',
'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 17/08/2020',
'DESCRIPCION: Se modifica para proporcionar correo electronico al componente de caratulas.jar.',
'BD: bdinteg',
'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 12/11/2021',
'DESCRIPCION: Se modifica para implementar el servicio web de insersion de imagen',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_adm_consulta_suc_exp(e_mac CHAR(12))  
RETURNING CHAR(5),CHAR(4),CHAR(2),CHAR(3),CHAR(40),CHAR(40),CHAR(40),CHAR(2),CHAR(3),CHAR(3),CHAR(3),INTEGER,CHAR(2),CHAR(60),CHAR(30),CHAR(20);

    DEFINE cod_ret           CHAR(5);
    DEFINE s_paseCont        CHAR(5);
    DEFINE sql_err           INTEGER ;

    DEFINE s_sucursal        CHAR(4);
    DEFINE s_area            CHAR(2);
    DEFINE s_depto           CHAR(3);
    DEFINE s_nombre          CHAR(40);
    DEFINE s_direccion1      CHAR(40);
    DEFINE s_direccion2      CHAR(40);
    DEFINE s_estado          CHAR(2);
    DEFINE s_ciudad          CHAR(3);
    DEFINE s_pais            CHAR(3);
    DEFINE s_plaza           CHAR(3);
    DEFINE s_dias_laborables INTEGER;
    DEFINE s_tpo_sucursal    CHAR(2);

    DEFINE s_fecha           DATE;

    DEFINE s_ciudad_n         CHAR(60);
    DEFINE s_pais_n           CHAR(20);
    DEFINE s_estado_n         CHAR(30);

    LET cod_ret           = "00000";
    LET s_sucursal        = "";
    LET s_area            = "";
    LET s_depto           = "";

    LET s_nombre          = "";
    LET s_direccion1      = "";
    LET s_direccion2      = "";
    LET s_estado          = "";
    LET s_ciudad          = "";
    LET s_pais            = "";
    LET s_plaza           = "";
    LET s_dias_laborables = "";
    LET s_tpo_sucursal    = "";
    LET s_ciudad_n        = "";
    LET s_pais_n          = "";
    LET s_estado_n        = "";

    --SET DEBUG FILE TO '/informix/sp_adm_consulta_suc.out';
    --TRACE ON;    

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
           RETURN  cod_ret,s_sucursal,s_area,s_depto, s_nombre,s_direccion1,s_direccion2,s_estado,s_ciudad,s_pais, s_plaza,s_dias_laborables,s_tpo_sucursal,s_ciudad_n,s_estado_n,s_pais_n;
      END IF ;
   END EXCEPTION ;

   SET LOCK MODE TO WAIT 3;
   SET ISOLATION TO DIRTY READ;	

	IF NVL(e_mac,'') =='' THEN 
	 	  LET cod_ret = '02000'; -- No contiene Dato de MAC
         RETURN  cod_ret,s_sucursal,s_area,s_depto, s_nombre,s_direccion1,s_direccion2,s_estado,s_ciudad,s_pais, s_plaza,s_dias_laborables,s_tpo_sucursal,s_ciudad_n,s_estado_n,s_pais_n;
	END IF;	
	
    SELECT sucursal,area,departamento
    INTO s_sucursal,s_area,s_depto
	FROM bdinteg:"informix".si_sucursalesmaquina
	WHERE mac = e_mac;

    IF NVL(s_sucursal,'') =='' THEN 
	 	  LET cod_ret = '02001'; -- No se encontro Sucursal Relacionada
         RETURN  cod_ret,NVL(s_sucursal,''), NVL(s_area,''),
            NVL( s_depto,''), s_nombre,s_direccion1,s_direccion2,s_estado,s_ciudad,s_pais, s_plaza,  NVL(s_dias_laborables,0),s_tpo_sucursal,
            NVL(s_ciudad_n,''),
            NVL(s_estado_n,''),
            NVL(s_pais_n,'');
	END IF;

    SELECT fecha_hoy
    INTO s_fecha
    FROM bdinteg:"informix".si_fechas;
    
   /* EXECUTE PROCEDURE bdisuc:sp_valida_pasecont(s_sucursal, s_fecha) INTO s_paseCont;
	
    IF s_paseCont = '00000' THEN
         LET cod_ret = '02500'; -- Se tiene ya pase contable
         RETURN  cod_ret,NVL(s_sucursal,''), NVL(s_area,''),
            NVL( s_depto,''), s_nombre,s_direccion1,s_direccion2,s_estado,s_ciudad,s_pais, s_plaza,  NVL(s_dias_laborables,0),s_tpo_sucursal,
            NVL(s_ciudad_n,''),
            NVL(s_estado_n,''),
            NVL(s_pais_n,'');
    END IF;*/

    SELECT  suc.nombre,ptf.calle||' NUM '||ptf.num_ext as direccion1,NVL('COL '||loc.desc_colonia||' C.P. '||loc.cp, '') as direccion2, ptf.cve_estado, ptf.cve_ciudad, ptf.cve_pais, suc.plaza, suc.dias_laborables,suc.tpo_sucursal
    INTO  s_nombre,s_direccion1,s_direccion2,s_estado,s_ciudad,s_pais, s_plaza,s_dias_laborables,s_tpo_sucursal
    FROM    bdinteg: "informix".si_ptf ptf
    INNER JOIN bdinteg:"informix".si_sucursales suc ON ptf.id_ptf =  suc.sucursal AND ptf.tipo = suc.tipo
    LEFT OUTER JOIN "informix".si_localidades loc ON ( loc.cve_estado = ptf.cve_estado AND 
                                                          loc.cve_mun = ptf.cve_mun AND
                                                          loc.cve_localidad_cnbv = ptf.cve_localidad AND 
                                                          loc.cve_col = ptf.cve_col )
    WHERE ptf.id_ptf =s_sucursal AND ptf.tipo = 'S';

    --LEFT OUTER JOIN "informix".si_localidades loc ON ( loc.id > 0 AND
    --                                                      loc.cp = loc.cp AND
    --                                                      loc.cve_estado = ptf.cve_estado AND
    --                                                      loc.cve_mun = ptf.cve_mun AND
    --                                                      loc.cve_localidad_cnbv = ptf.cve_localidad AND
    --                                                      loc.cve_col = ptf.cve_col )
    --WHERE ptf.id_ptf =s_sucursal AND ptf.tipo = 'S';
    

    /*SELECT  suc.nombre,suc.direccion1,suc.direccion2, suc.estado, suc.ciudad, suc.pais, suc.plaza, suc.dias_laborables,suc.tpo_sucursal
    INTO  s_nombre,s_direccion1,s_direccion2,s_estado,s_ciudad,s_pais, s_plaza,s_dias_laborables,s_tpo_sucursal
	FROM 	bdinteg:"informix".si_sucursales suc
    WHERE suc.sucursal =s_sucursal;*/

    SELECT nombre INTO s_pais_n
    FROM SI_paises WHERE pais =s_pais;

    SELECT nombre INTO s_ciudad_n
    FROM si_ciudades WHERE estado=s_estado AND ciudad =s_ciudad;

    SELECT nombre  INTO s_estado_n
    FROM si_estados WHERE estado =s_estado;


	RETURN  cod_ret,NVL(s_sucursal,''),
            NVL(s_area,''),
            NVL( s_depto,''),
            NVL( s_nombre,''),
            NVL(s_direccion1,''),
            NVL(s_direccion2,''),
            NVL(s_estado,''),
            NVL(s_ciudad,''),
            NVL(s_pais,''), 
            NVL(s_plaza,''),
            NVL(s_dias_laborables,0),
            NVL(s_tpo_sucursal,''),
            NVL(s_ciudad_n,''),
            NVL(s_estado_n,''),
            NVL(s_pais_n,'');
END
END PROCEDURE
DOCUMENT
'Proceso que consulta la mac este registrada en la sucursal',
'BD    : BDINTEG';

CREATE PROCEDURE "informix".sp_adm_consulta_suc(e_mac CHAR(12))  
RETURNING CHAR(5),CHAR(4),CHAR(2),CHAR(3),CHAR(40),CHAR(40),CHAR(40),CHAR(2),CHAR(3),CHAR(3),CHAR(3),INTEGER,CHAR(2),CHAR(60),CHAR(30),CHAR(20);

    DEFINE cod_ret           CHAR(5);
    DEFINE s_paseCont        CHAR(5);
    DEFINE sql_err           INTEGER ;

    DEFINE s_sucursal        CHAR(4);
    DEFINE s_area            CHAR(2);
    DEFINE s_depto           CHAR(3);
    DEFINE s_nombre          CHAR(40);
    DEFINE s_direccion1      CHAR(40);
    DEFINE s_direccion2      CHAR(40);
    DEFINE s_estado          CHAR(2);
    DEFINE s_ciudad          CHAR(3);
    DEFINE s_pais            CHAR(3);
    DEFINE s_plaza           CHAR(3);
    DEFINE s_dias_laborables INTEGER;
    DEFINE s_tpo_sucursal    CHAR(2);

    DEFINE s_fecha           DATE;

    DEFINE s_ciudad_n         CHAR(60);
    DEFINE s_pais_n           CHAR(20);
    DEFINE s_estado_n         CHAR(30);

    LET cod_ret           = "00000";
    LET s_sucursal        = "";
    LET s_area            = "";
    LET s_depto           = "";

    LET s_nombre          = "";
    LET s_direccion1      = "";
    LET s_direccion2      = "";
    LET s_estado          = "";
    LET s_ciudad          = "";
    LET s_pais            = "";
    LET s_plaza           = "";
    LET s_dias_laborables = "";
    LET s_tpo_sucursal    = "";
    LET s_ciudad_n        = "";
    LET s_pais_n          = "";
    LET s_estado_n        = "";

    --SET DEBUG FILE TO '/informix/sp_adm_consulta_suc.out';
    --TRACE ON;    

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
           RETURN  cod_ret,s_sucursal,s_area,s_depto, s_nombre,s_direccion1,s_direccion2,s_estado,s_ciudad,s_pais, s_plaza,s_dias_laborables,s_tpo_sucursal,s_ciudad_n,s_estado_n,s_pais_n;
      END IF ;
   END EXCEPTION ;

   SET LOCK MODE TO WAIT 3;
   SET ISOLATION TO DIRTY READ;	

	IF NVL(e_mac,'') =='' THEN 
	 	  LET cod_ret = '02000'; -- No contiene Dato de MAC
         RETURN  cod_ret,s_sucursal,s_area,s_depto, s_nombre,s_direccion1,s_direccion2,s_estado,s_ciudad,s_pais, s_plaza,s_dias_laborables,s_tpo_sucursal,s_ciudad_n,s_estado_n,s_pais_n;
	END IF;	
	
    SELECT sucursal,area,departamento
    INTO s_sucursal,s_area,s_depto
	FROM bdinteg:"informix".si_sucursalesmaquina
	WHERE mac = e_mac;

    IF NVL(s_sucursal,'') =='' THEN 
	 	  LET cod_ret = '02001'; -- No se encontro Sucursal Relacionada
         RETURN  cod_ret,NVL(s_sucursal,''), NVL(s_area,''),
            NVL( s_depto,''), s_nombre,s_direccion1,s_direccion2,s_estado,s_ciudad,s_pais, s_plaza,  NVL(s_dias_laborables,0),s_tpo_sucursal,
            NVL(s_ciudad_n,''),
            NVL(s_estado_n,''),
            NVL(s_pais_n,'');
	END IF;

    SELECT fecha_hoy
    INTO s_fecha
    FROM bdinteg:"informix".si_fechas;
    
   /* EXECUTE PROCEDURE bdisuc:sp_valida_pasecont(s_sucursal, s_fecha) INTO s_paseCont;
	
    IF s_paseCont = '00000' THEN
         LET cod_ret = '02500'; -- Se tiene ya pase contable
         RETURN  cod_ret,NVL(s_sucursal,''), NVL(s_area,''),
            NVL( s_depto,''), s_nombre,s_direccion1,s_direccion2,s_estado,s_ciudad,s_pais, s_plaza,  NVL(s_dias_laborables,0),s_tpo_sucursal,
            NVL(s_ciudad_n,''),
            NVL(s_estado_n,''),
            NVL(s_pais_n,'');
    END IF;*/

    SELECT  suc.nombre,ptf.calle||' NUM '||ptf.num_ext as direccion1,NVL('COL '||loc.desc_colonia||' C.P. '||loc.cp, '') as direccion2, ptf.cve_estado, ptf.cve_ciudad, ptf.cve_pais, suc.plaza, suc.dias_laborables,suc.tpo_sucursal
    INTO  s_nombre,s_direccion1,s_direccion2,s_estado,s_ciudad,s_pais, s_plaza,s_dias_laborables,s_tpo_sucursal
    FROM    bdinteg: "informix".si_ptf ptf
    INNER JOIN bdinteg:"informix".si_sucursales suc ON ptf.id_ptf =  suc.sucursal AND ptf.tipo = suc.tipo
    LEFT OUTER JOIN "informix".si_localidades loc ON ( loc.cve_estado = ptf.cve_estado AND 
                                                          loc.cve_mun = ptf.cve_mun AND
                                                          loc.cve_localidad_cnbv = ptf.cve_localidad AND 
                                                          loc.cve_col = ptf.cve_col )
    WHERE ptf.id_ptf =s_sucursal AND ptf.tipo = 'S';

    --LEFT OUTER JOIN "informix".si_localidades loc ON ( loc.id > 0 AND
    --                                                      loc.cp = loc.cp AND
    --                                                      loc.cve_estado = ptf.cve_estado AND
    --                                                      loc.cve_mun = ptf.cve_mun AND
    --                                                      loc.cve_localidad_cnbv = ptf.cve_localidad AND
    --                                                      loc.cve_col = ptf.cve_col )
    --WHERE ptf.id_ptf =s_sucursal AND ptf.tipo = 'S';
    

    /*SELECT  suc.nombre,suc.direccion1,suc.direccion2, suc.estado, suc.ciudad, suc.pais, suc.plaza, suc.dias_laborables,suc.tpo_sucursal
    INTO  s_nombre,s_direccion1,s_direccion2,s_estado,s_ciudad,s_pais, s_plaza,s_dias_laborables,s_tpo_sucursal
	FROM 	bdinteg:"informix".si_sucursales suc
    WHERE suc.sucursal =s_sucursal;*/

    SELECT nombre INTO s_pais_n
    FROM SI_paises WHERE pais =s_pais;

    SELECT nombre INTO s_ciudad_n
    FROM si_ciudades WHERE estado=s_estado AND ciudad =s_ciudad;

    SELECT nombre  INTO s_estado_n
    FROM si_estados WHERE estado =s_estado;


	RETURN  cod_ret,NVL(s_sucursal,''),
            NVL(s_area,''),
            NVL( s_depto,''),
            NVL( s_nombre,''),
            NVL(s_direccion1,''),
            NVL(s_direccion2,''),
            NVL(s_estado,''),
            NVL(s_ciudad,''),
            NVL(s_pais,''), 
            NVL(s_plaza,''),
            NVL(s_dias_laborables,0),
            NVL(s_tpo_sucursal,''),
            NVL(s_ciudad_n,''),
            NVL(s_estado_n,''),
            NVL(s_pais_n,'');
END
END PROCEDURE
DOCUMENT
'Proceso que consulta la mac este registrada en la sucursal',
'BD    : BDINTEG';

CREATE PROCEDURE "informix".sp_genera_folioactivacion_bpi ()
RETURNING CHAR(5),CHAR(12);

	DEFINE codRet CHAR(5);
    DEFINE viSqlErr INTEGER;
    DEFINE folioClaro CHAR(12);
    DEFINE cFolio0 CHAR(1);
    DEFINE cFolio1 CHAR(1);
    DEFINE cFolio2 CHAR(1);
    DEFINE cFolio3 CHAR(1);
    DEFINE cFolio4 CHAR(1);
    DEFINE cFolio5 CHAR(1);
    DEFINE cFolio6 CHAR(1);
    DEFINE cFolio7 CHAR(1);
    DEFINE cFolio8 CHAR(1);
    DEFINE cFolio9 CHAR(1);
    DEFINE cFolio10 CHAR(1);
    DEFINE cFolio11 CHAR(1);
    DEFINE iFolio0 INTEGER;
    DEFINE iFolio1 INTEGER;
    DEFINE iFolio2 INTEGER;
    DEFINE iFolio3 INTEGER;
    DEFINE iFolio4 INTEGER;
    DEFINE iFolio5 INTEGER;
    DEFINE iFolio6 INTEGER;
    DEFINE iFolio7 INTEGER;
    DEFINE iFolio8 INTEGER;
    DEFINE iFolio9 INTEGER;
    DEFINE iFolio10 INTEGER;
    DEFINE iFolio11 INTEGER;
    DEFINE iAlphaNum0 INTEGER;
    DEFINE iAlphaNum1 INTEGER;
    DEFINE iAlphaNum2 INTEGER;
    DEFINE iAlphaNum3 INTEGER;
    DEFINE iAlphaNum4 INTEGER;
    DEFINE ArregloDetiempo0 CHAR(20);
    DEFINE ArregloDetiempo1 CHAR(20);
    DEFINE ArregloDetiempo2 CHAR(20);
    DEFINE sFecha CHAR(10); 
    DEFINE TestHora INT8; 
    DEFINE TiempoRestar INT8; 
    DEFINE sHora CHAR(10); 
    DEFINE iHoraSumada INT8; 
    DEFINE PrimerValorHora CHAR(20);
    DEFINE SegundoValorHora CHAR(20); 
    DEFINE TercerValorHora INT8;
    DEFINE Intervalo INTEGER;
    DEFINE iRegreso INTEGER;
    DEFINE i INTEGER; 
    DEFINE sNumero CHAR(12);
    DEFINE dValor DECIMAL(10,2);
    DEFINE FechaSistema DATETIME YEAR TO DAY;
    DEFINE Tiempo DATETIME HOUR TO SECOND;
    DEFINE random CHAR(2);


    LET FechaSistema = CURRENT;
    LET Tiempo = CURRENT;
	LET codRet = '00000';
    LET viSqlErr = 0;
    LET folioClaro = '';

    LET cFolio0 = '';
    LET cFolio1 = '';
    LET cFolio2 = '';
    LET cFolio3 = '';
    LET cFolio4 = '';
    LET cFolio5 = '';
    LET cFolio6 = '';
    LET cFolio7 = '';
    LET cFolio8 = '';
    LET cFolio9 = '';
    LET cFolio10 = '';
    LET cFolio11 = '';

    LET iFolio0 = 0;
    LET iFolio1 = 0;
    LET iFolio2 = 0;
    LET iFolio3 = 0;
    LET iFolio4 = 0;
    LET iFolio5 = 0;
    LET iFolio6 = 0;
    LET iFolio7 = 0;
    LET iFolio8 = 0;
    LET iFolio9 = 0;
    LET iFolio10 = 0;
    LET iFolio11 = 0;

    LET iAlphaNum0 = 0;
    LET iAlphaNum1 = 0;
    LET iAlphaNum2 = 0;
    LET iAlphaNum3 = 0;

    LET ArregloDetiempo0 = '';
    LET ArregloDetiempo1 = '';
    LET ArregloDetiempo2 = '';

    LET sFecha = '';
    LET TestHora = 0;
    LET TiempoRestar = 0;
    LET sHora = '';
    LET iHoraSumada = 0;
    LET PrimerValorHora = ''; 
    LET SegundoValorHora = '';
    LET TercerValorHora = 0;
    LET Intervalo = 0;
    LET iRegreso = 0;
    LET i = 0;
    LET sNumero = '';
    LET dValor = 0.00;
    LEt random = '';

--SET DEBUG FILE TO "/informix/JuanRivera/Traces/sp_genera_folioactivacion_bpi.out";
--TRACE ON;	
	 
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    BEGIN
        ON EXCEPTION SET viSqlErr
            IF viSqlErr <> 0 then
                LET codRet = viSqlErr;
                RETURN codRet, folioClaro;
            END IF;	
        END EXCEPTION; 
        

        --Inicia generaciÃÂ³n de folio de activaciÃÂ³n

        LET PrimerValorHora = '0';
        LET sHora = SUBSTR(CAST(Tiempo AS CHAR(10)), 1, 2);
        IF CAST(sHora AS INTEGER) >= 20 THEN
            LET sHora = '0' || SUBSTR(CAST(Tiempo AS CHAR(10)), 8, 1);
        END IF;
        LET TestHora = CAST(sHora AS INT8) * 60;
        LET TercerValorHora = TestHora;

        LET TestHora = TercerValorHora * 60;

        LET sHora = SUBSTR(CAST(Tiempo AS CHAR(10)), 4, 2);
        LET TestHora = TestHora + CAST(sHora AS INTEGER) * 60;

        LET sHora = SUBSTR(CAST(Tiempo AS CHAR(10)), 7, 2);
        LET TestHora = TestHora + CAST(sHora AS INTEGER);
        
        
        IF TestHora <= 25200 THEN
            LET iHoraSumada = TestHora;
            LET dValor = TestHora;
        ELSE
            LET iHoraSumada = TestHora - 25200;
            LET TestHora = TestHora - 25200;
            LET dValor = TestHora;
        END IF;

        IF TestHora >= 46655 THEN
             LET TiempoRestar = TestHora - 46655;
             LET dValor = dValor - TiempoRestar;
        END IF;


        LET dValor = dValor / 1296;
        LET PrimerValorHora = CAST(dValor AS CHAR(20));
        LET PrimerValorHora = SUBSTR(PrimerValorHora, 1, 2); --PRIMER VALOR
        
        IF SUBSTR(PrimerValorHora, 2, 1) = '.' THEN
            LET PrimerValorHora = SUBSTR(PrimerValorHora, 1, 1);
        END IF;

        LET TestHora = iHoraSumada - (CAST(PrimerValorHora AS INTEGER) * 1296);
        IF SUBSTR(TestHora, 1, 1) = '-' THEN
            LET TestHora = SUBSTR(TestHora, 2, 1);
        END IF;
        LET Intervalo = TestHora;
        LET dValor = TestHora / 36;
        LET SegundoValorHora = CAST(dValor AS CHAR(20));
        LET SegundoValorHora = SUBSTR(SegundoValorHora, 1, 2); --SEGUNDO VALOR
        LET TercerValorHora = Intervalo - (CAST(SegundoValorHora AS INTEGER) * 36); --TERCER VALO
        

        IF (CAST(PrimerValorHora AS INTEGER) >= 0 AND CAST(PrimerValorHora AS INTEGER) <= 9) THEN
            LET ArregloDetiempo0 = ASCII(PrimerValorHora);
            LET i = i;
        ELSE
            LET PrimerValorHora = CAST(PrimerValorHora AS INTEGER) - 9 + 64;
            LET i = i;
            LET ArregloDetiempo0 = PrimerValorHora;
        END IF;
        IF (CAST(SegundoValorHora AS INTEGER) >= 0 AND CAST(SegundoValorHora AS INTEGER) <= 9) THEN
            LET i = i + 1;
            LET ArregloDetiempo1 = ASCII(SegundoValorHora);
        ELSE
            LET SegundoValorHora = CAST(SegundoValorHora AS INTEGER) - 9 + 64;
            LET i = i + 1;
            LET ArregloDetiempo1 = SegundoValorHora;
        END IF;
        IF (CAST(TercerValorHora AS INTEGER) >= 0 AND CAST(TercerValorHora AS INTEGER) <= 9) THEN
            LET i = i + 1;
            LET ArregloDetiempo2 = ASCII(CAST(TercerValorHora AS CHAR));
        ELSE
            LET TercerValorHora = CAST(TercerValorHora AS INTEGER) - 9 + 64;
            LET i = i + 1;
            LET ArregloDetiempo2 = CAST(TercerValorHora AS CHAR(20));
        END IF;
        

        LET sFecha = '';
        LET sFecha = SUBSTR(FechaSistema, 9, 2) || SUBSTR(FechaSistema, 6, 2) || SUBSTR(FechaSistema, 3, 2);

        LET i = 0;

        --EXECUTE PROCEDURE bdinteg:"informix".sp_random() INTO random;
        --LET folioClaro = random || SUBSTR(random, -2);
        --LET random = SUBSTR(random, -2);

        WHILE i <= 5
            --IF random >= 0 AND random <= 86 THEN
                --LET random = random + 3;
            --ELSE
                --LET random = random - 85;
            --END IF;

            SELECT contador INTO random FROM bdibpi:"informix".contador_folio;
            IF random  <> '' AND random <> 'NULL' THEN
                IF random >= 0 AND random <= 89 THEN
                    LET random = random + 1;
                    UPDATE bdibpi:"informix".contador_folio SET contador = random;
                ELSE
                    LET random = random - 89;
                    UPDATE bdibpi:"informix".contador_folio SET contador = random;
                END IF;
            ELSE
                INSERT INTO bdibpi:"informix".contador_folio(contador)
                VALUES(0);
                LET random = 0;
            END IF;

            IF (random > 65 AND random < 90) OR (random > 47 AND random < 58) THEN
                IF i = 0 THEN
                    LET iAlphaNum0 = random;
                ELIF i = 1 THEN
                    LET iAlphaNum1 = random;
                ELIF i = 2 THEN
                    LET iAlphaNum2 = random;
                ELIF i = 3 THEN
                    LET iAlphaNum3 = random;
                ELIF i = 4 THEN
                    LET iAlphaNum4 = random;
                END IF;
                LET i = i + 1;
            END IF;
            IF random >= 0 And random <= 9 THEN
                IF i = 0 THEN
                    LET iAlphaNum0 = ASCII(CAST(random AS CHAR));
                ELIF i = 1 THEN
                    LET iAlphaNum1 = ASCII(CAST(random AS CHAR));
                ELIF i = 2 THEN
                    LET iAlphaNum2 = ASCII(CAST(random AS CHAR));
                ELIF i = 3 THEN
                    LET iAlphaNum3 = ASCII(CAST(random AS CHAR));
                ELIF i = 4 THEN
                    LET iAlphaNum4 = ASCII(CAST(random AS CHAR));
                END IF;
                LET i = i + 1;
            END IF;
        END WHILE;
        


        

        LET iFolio0 = CAST(SUBSTR(sFecha, 1, 1) AS INTEGER);
        IF CAST(ArregloDetiempo0 AS INTEGER) >= 65 THEN
            LET iFolio1 = CAST(ArregloDetiempo0 AS INTEGER) - 64;
        ELSE
            LET iFolio1 = CHR(ArregloDetiempo0);
        END IF;
        LET iFolio2 = CAST(SUBSTR(sFecha, 5, 1) AS INTEGER);
        IF iAlphaNum2 > 65 THEN
            LET iFolio3 = iAlphaNum2 - 64;
        ELSE
            LET iFolio3 = CHR(iAlphaNum2);
        END IF;
        LET iFolio4 = CAST(SUBSTR(sFecha, 2, 1) AS INTEGER);
        IF ArregloDetiempo1 >= 65 THEN
            LET iFolio5 =  CAST(ArregloDetiempo1 AS INTEGER) - 64;
        ELSE
            LET iFolio5 = CHR(ArregloDetiempo1);
        END IF;
        LET iFolio6 = CAST(SUBSTR(sFecha, 3, 1) AS INTEGER);
        IF iAlphaNum4 > 65 THEN
            LET iFolio7 = iAlphaNum4 - 64;
        ELSE
            LET iFolio7 = CHR(iAlphaNum4);
        END IF;
        LET iFolio8 = CAST(SUBSTR(sFecha, 6, 1) AS INTEGER);
        IF ArregloDetiempo2 >= 65 THEN
            LET iFolio9 = CAST(ArregloDetiempo2 AS INTEGER) - 64;
        ELSE
            LET iFolio9 = CHR(ArregloDetiempo2);
        END IF;
        LET iFolio10 = CAST(SUBSTR(sFecha, 4, 1) AS INTEGER);

        LET iFolio11 = iFolio11 + (iFolio0 * 1);
        LET iFolio11 = iFolio11 + (iFolio1 * 5);
        LET iFolio11 = iFolio11 + (iFolio2 * 1);
        LET iFolio11 = iFolio11 + (iFolio3 * 5);
        LET iFolio11 = iFolio11 + (iFolio4 * 1);
        LET iFolio11 = iFolio11 + (iFolio5 * 5);
        LET iFolio11 = iFolio11 + (iFolio6 * 1);
        LET iFolio11 = iFolio11 + (iFolio7 * 5);
        LET iFolio11 = iFolio11 + (iFolio8 * 1);
        LET iFolio11 = iFolio11 + (iFolio9 * 5);
        LET iFolio11 = iFolio11 + (iFolio10 * 1);

        LET iFolio11 = iFolio11 + 137;

        LET iFolio11 = MOD(iFolio11, 7);

        LET cFolio0 = SUBSTR(sFecha, 1, 1);
        LET cFolio1 = CHR(ArregloDetiempo0); --INCFOLREP29072022
        LET cFolio2 = SUBSTR(sFecha, 5, 1);
        LET cFolio3 = CHR(iAlphaNum2);
        LET cFolio4 = SUBSTR(sFecha, 2, 1);
        LET cFolio5 = CHR(ArregloDetiempo1);
        LET cFolio6 = SUBSTR(sFecha, 3, 1);
        LET cFolio7 = CHR(iAlphaNum4);
        LET cFolio8 = SUBSTR(sFecha, 6, 1);
        LET cFolio9 = CHR(ArregloDetiempo2);
        LET cFolio10 = SUBSTR(sFecha, 4, 1);
        LET cFolio11 = CAST(iFolio11 AS CHAR(1));
        

        
        LET sNumero = cFolio0 || cFolio1 || cFolio2 || cFolio3 || cFolio4 || cFolio5 || cFolio6 || cFolio7 || cFolio8 || cFolio9 || cFolio10 || cFolio11;
        

        IF LENGTH(sNumero) = 12 THEN
            LET folioClaro = sNumero;
            LET iRegreso = 1;
        END IF;


        RETURN codRet, folioClaro;
    END;
END PROCEDURE;