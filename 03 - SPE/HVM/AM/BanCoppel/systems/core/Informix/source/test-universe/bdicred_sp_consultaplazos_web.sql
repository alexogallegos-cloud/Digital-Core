CREATE PROCEDURE "informix".sp_consultaplazos_web(pNumPromocion SMALLINT)
	RETURNING CHAR(5) AS CodRetorno, INTEGER AS Plazo, INTEGER AS RegAct, INTEGER AS Tasa;	--DSB20140610

--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE iPlazo  INTEGER;
DEFINE iCanReg INTEGER;
DEFINE iTasa	INTEGER;		--DSB20140610

--Inicializacion de Variables
LET iSqlErr = 0;
LET cCodRet = '00000';
LET iPlazo = 0;
LET iCanReg = 1;
LET iTasa	= 0;				--DSB20140610

--SET DEBUG FILE TO '/tmp/sp_consultaplazos.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iPlazo, iCanReg, iTasa;	--DSB20140610
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	FOREACH
		SELECT plazo, tasa						--DSB20140610
		INTO iPlazo, iTasa
		FROM bdicred:"informix".sd_tasa_plazo
		WHERE num_promo = pNumPromocion ORDER BY plazo
		RETURN cCodRet, iPlazo, iCanReg, iTasa WITH RESUME;		--DSB20140610
	END FOREACH;
	
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Regresa los plazos para las promociones activas',
'AUTOR : Adrian Lara I',
'FECHA : 02/02/2012',
'BD: bdicred',
'SISTEMA : 6',
'-- Folio.........: 1452 - CrediSoluciones',
'-- Autor.........: 95526749 - JesÃºs Horacio LÃ³pez GonzÃ¡lez',
'-- Fecha.........: 10/06/2014 - DSB20140610',
'-- ModificaciÃ³n..: Se modifica para que retorne la tasa de interes y se muestre en la dll de Credisoluciones',
'-- Sustento......: Analisis incidencias credisoluciones.doc',
'-- Solicita......: Faviola Martinez',
'-- BD............: Bdicred';

CREATE PROCEDURE "informix".sp_elimina_adicionales_pendientes_web (pEmpresa char(3),pClienteAdicional char(20),pCredito char(20))
	--DATOS A REGRESAR
	RETURNING 
	CHAR(6) AS cCodRet;
	
--============= DEFINIR VARIABLES =============
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr SMALLINT;
	DEFINE iSamErr SMALLINT;
	DEFINE cErrorInfo CHAR(40);
	DEFINE sClienteTitular CHAR(20);
	
--============= INICIALIZAR VARIABLES ===========
	LET cCodRet = '00000';
	LET sClienteTitular = '';
--==================================================
	BEGIN
		ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
			LET cCodRet = iSqlErr;
			RETURN  cCodRet;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
				
		-- SET DEBUG FILE TO "/respaldosbd/Bryan/sp_elimina_adicionales_pendientes.out";
		-- TRACE ON;
		
		IF NVL(pEmpresa,'') = '' OR NVL(pClienteAdicional,'') = '' OR NVL(pCredito,'') = '' THEN
			LET cCodRet = '00001';
		ELSE
			--Validar que exista el adicional en la tabla de sd_adicionalespendientes
			SELECT LIMIT 1 numctetitular 
			INTO sClienteTitular
			FROM bdicred:"informix".sd_adicionalespendientes
			WHERE empresa = pEmpresa AND numcteadicional = pClienteAdicional 
			AND credito = pCredito;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				--Registro no existe
				LET cCodRet = '00002';
			ELSE
				-- Existe y se elimina el registro
				DELETE FROM bdicred:"informix".sd_adicionalespendientes
				WHERE empresa = pEmpresa AND numcteadicional = pClienteAdicional 
				AND credito = pCredito;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					-- Si existe el registro pero no se elimino 
					LET cCodRet = '00003';
				END IF;
			END IF
		END IF;

		RETURN  cCodRet;
END
END PROCEDURE

DOCUMENT 
'Folio: 226',
'Autor: 93034687 - Bryan Limon',
'Fecha: 15/11/2017',
'ModificaciÃ³n: Crear procedimiento el cÃºal consulte si existe el registro en la tabla sd_adicionalespendientes y eliminarlo',
'Sustento: basado en el requerimiento 10 810 Solicitud de Tarjetas Adicionales Tarjeta de CrÃ©dito',
'Solicita: Abrham Narvaez',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_eliminaadicional_web(pNumeroCuenta char(26), pNumeroCliente char(26),pTipo smallint)
        
	-- DATOS A REGRESAR
        RETURNING
        char(5);        -- Codigo de retorno

        -- Declaracion de variables
        DEFINE vCodRet          char(5);
        DEFINE vsecuencia       smallint;
        DEFINE vnumcte          char(26);
        DEFINE vContador        smallint;
        DEFINE vtipo            smallint;
        DEFINE vNumerocuenta    char(26);

        -- Se Inicializan las Variables
        LET vCodRet  = "00000";
        LET vsecuencia=0;
        LET vnumcte = "";
        LET vContador = 1;

        --SET DEBUG FILE TO '/tmp/SPEliminaAdicional2.OUT';
        --TRACE ON;

	BEGIN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
        IF ptipo=1 THEN -- aDICIONAL DE credito

	 -- Se verifica que exista el nÃÂºmero de cuenta
		IF(SELECT count(numcte)
			FROM bdicred:sd_tarjeta
			WHERE numcte = pNumeroCliente AND num_credito = pNumeroCuenta
			AND secuencia = (SELECT MAX(secuencia)
							FROM bdicred:sd_tarjeta
							WHERE numcte = pNumeroCliente AND tipo_tarjeta='A' AND num_credito = pNumeroCuenta)) > 0 THEN
			SELECT MAX(secuencia)
					INTO Vsecuencia
					FROM bdicred:sd_tarjeta
					WHERE numcte = pNumeroCliente AND num_credito = pNumeroCuenta  AND tipo_tarjeta='A' AND status_tar='A';

			UPDATE bdicred:sd_tarjeta
					SET status_tar = 'C'
			WHERE numcte = pNumeroCliente
					AND  num_credito = pNumeroCuenta
					AND secuencia = vsecuencia;

			LET vCodRet = "00000";
			RETURN vCodRet ;

        ELSE  --Cliente NO EXISTE

                        LET vCodRet="00259";
                        RETURN vCodRet ;

        END IF;
---------------------------------------------------------------------------
        ELSE    --Buscar Datos de DICIONAL DE DEBITO
        let vnumcte = pnumerocliente;
        LET vnumerocuenta = pnumerocuenta;
        let vtipo = ptipo;

                IF(SELECT count(numcte)
                        FROM bdicheq:sc_firmantes
                        WHERE numcte = pNumeroCliente
                                AND cuenta = pNumeroCuenta) > 0 THEN

                        DELETE FROM bdicheq:sc_firmantes
                                WHERE numcte = pNumeroCliente
                                        AND cuenta = pNumeroCuenta;

                        IF(SELECT count(secuencia)
                                  FROM bdicheq:sc_firmantes
                                  WHERE cuenta = pNumeroCuenta
                                  AND secuencia <>1) > 0 THEN

                                UPDATE bdicheq:sc_firmantes SET secuencia = 2
                                WHERE cuenta = pNumeroCuenta
                                AND secuencia <>1;

                        END IF;

                        IF(SELECT count(numcte)
                                FROM  bdicheq:sc_tarjeta
                                WHERE  numcte = pNumeroCliente
                                        AND cuenta = pNumeroCuenta
                                        AND tipo_tarjeta ='A' AND status_tar = 'A') > 0 THEN

                                SELECT MAX(secuencia) INTO vSecuencia
                                        FROM bdicheq:sc_tarjeta
                                        WHERE cuenta = pnumerocuenta
                                                AND numcte = pNumeroCliente
                                                AND tipo_tarjeta='A'
                                                AND status_tar = 'A';

                                UPDATE bdicheq:sc_tarjeta
                                    SET status_tar = 'C'
                                    WHERE numcte = pNumeroCliente
                                        AND cuenta = pNumeroCuenta
                                        AND tipo_tarjeta ='A'
                                        AND secuencia = vSecuencia;

                                LET vCodRet = "00000";
                                RETURN vCodRet ;

                        END IF;

                        LET vCodRet = "00000";
                        RETURN vCodRet ;

                ELSE  --Cliente cLIENTE nO EXISTE

                        LET Vcodret = "00259";
                        RETURN vCodRet ;

                END IF ;

        END IF;
END;
END PROCEDURE

DOCUMENT
"Elaboro : Adrian Acosta Solis",
"FECHA : 15/Marzo/2007",
"Ver.  : 1.1",
"BD    : bdicheq,bdicred",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_actvig_camp_mx() 
RETURNING CHAR(6),CHAR(55);

DEFINE iSqlErr			INTEGER;
DEFINE cCodRet 			CHAR(6);
DEFINE cmensaje 		CHAR(55);
DEFINE cRuta 			CHAR (50);
DEFINE cnom_archivo		CHAR(30);
DEFINE cBitacoraCamp	CHAR (50);
DEFINE cBitacCampSms	CHAR (50);
DEFINE cCadena  		CHAR (500);
DEFINE siPromo 			varchar(5);
DEFINE dtIni_Vig 		DATE;
DEFINE dtFin_Vig 		DATE;
DEFINE dtIni_Vig_min 	DATE; 
DEFINE dtIni_Vig_max 	DATE;
DEFINE siPlazo 			varchar(5);
DEFINE siTasa 			decimal(10,2);
DEFINE wBegin           CHAR(1);
DEFINE cArchivo_dbld    CHAR(50);
DEFINE cArchivo_log     CHAR(50);
DEFINE cfec_arch		CHAR(8);
DEFINE dt_fec_carga 	DATE;
DEFINE sContador		SMALLINT;
DEFINE sContadorAux		SMALLINT;
DEFINE sContadorAux2	SMALLINT;
DEFINE sTasasSms		SMALLINT;
DEFINE iMonto_Ini		DECIMAL(10,2);
DEFINE iMonto_Fin 		DECIMAL(10,2);
DEFINE cMontos			CHAR(21);

LET iSqlErr 		= 0;
LET cCodRet 		= '000001';
LET cmensaje 		= 'Actualizacion de Vigencia Credisoluciones Ok';
LET cCadena 		= '';
LET cRuta 			= '';
LET cnom_archivo	= '';
LET cBitacoraCamp	= '';
LET cBitacCampSms   = '';
LET siPromo 		= 0;
LET dtIni_Vig 		= '';
LET dtFin_Vig 		= '';
LET siPlazo 		= 0;
LET siTasa 			= 0;
LET wBegin 			= '';
LET cfec_arch		= '';
LET sContador		= 0;
LET sContadorAux	= 0;
LET sContadorAux2	= 0;
LET sTasasSms		= 0;
LET cMontos			= '';
LET iMonto_Ini 		= 0;
LET iMonto_Fin		= 0;
LET cArchivo_dbld   = "f_actvig_prosp.com";
LET cArchivo_log    = "f_actvig_prosp.log";

BEGIN

	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
		END IF;
		RETURN cCodRet,cmensaje;
	END EXCEPTION;
   	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;   

	SET DEBUG FILE TO '/tmp/sp_actvig_camp.out';
    TRACE ON;
	
	SELECT year(fecha_hoy)||lpad(month(fecha_hoy),2,0)||lpad(day(fecha_hoy),2,0),fecha_hoy
	  INTO cfec_arch,dt_fec_carga
	  FROM bdicred:sd_fechas;
	
    LET cnom_archivo = "actvig_prospectos_"||cfec_arch||'.txt';
    LET cBitacoraCamp = "bitacora_actvig_prospectos_"||cfec_arch||'.txt';
	LET cBitacCampSms = "bitacora_actvig_prospectos_sms_"||cfec_arch||'.txt';
    LET cRuta = "/resplogifx/archivoscredito/";   

	--DROP TABLE IF EXISTS "informix".sd_actvig_camp;
    DROP TABLE IF EXISTS "informix".sd_actvig_camp;	
	CREATE TABLE sd_actvig_camp (
		camp 		varchar(3),
		f_ini_vig	date,
		f_fin_vig	date,
		plazo	 	varchar(5),
		tasa  		decimal(10,2),
		origen 		char(10),
		montos		char(21)
	);
		
   system ' echo "FILE ' ||  TRIM(cRuta) ||  TRIM(cnom_archivo) ||' DELIMITER '|| "'" || '|' || "'" || ' 7; ' || '">' || TRIM(cRuta) || TRIM(cArchivo_dbld);  
   system ' echo "INSERT INTO sd_actvig_camp;' || '">>' || TRIM(cRuta) || TRIM(cArchivo_dbld);
   system ' chmod 777 ' || TRIM(cRuta) || TRIM(cArchivo_dbld);

	 --system ' echo "date ' || '">' || TRIM(cRuta) || 'dbload_actvig_prosp.sh';
	 --system ' echo "dbload -d bdicred -c ' || TRIM(cRuta) || TRIM(cArchivo_dbld)  ||' -l ' || TRIM(cRuta) || TRIM(cArchivo_log) || ' -n 1000 ' || ' " >> ' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh'; 
	 --system ' echo "date ' || '">>' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';
	 --system ' echo "dbaccess bdicred -<<EOF ' || '">>' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';             
	 --system ' echo "set pdqpriority 0;' || '">>' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';          
	 --system ' echo "update statistics medium for table sd_actvig_camp; ' || '">>' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';           
	 --system ' echo "EOF' || '">>' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';           
	 --system 'chmod 777 ' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';
	
	--system 'chmod 777 /usr/bin/sh ';
	system '/usr/bin/sh ' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';
	
	create index inx1_activ_camp on sd_actvig_camp(origen);
	 
	
	-- Valida que esten correctamente escritas las palabras: sucursal y sms
	LET sContador = 0;
	UPDATE bdicred:sd_actvig_camp SET origen = lower(origen);
	SELECT COUNT(camp) INTO sContador FROM bdicred:sd_actvig_camp WHERE origen != "sucursal" AND origen != "sms";
	IF sContador > 0 THEN
		LET cCodRet = '000003';
		LET cmensaje = 'Banderas de origen (sucursal o sms) son incorrectas.';
		RETURN cCodRet,cmensaje;
	END IF;
	
	-- Valida que los registros marcados como sms no superen los 4 por plazo.
	DROP TABLE IF EXISTS "informix".tmp_plazsms;
	SELECT camp, count(camp) total_p FROM bdicred:sd_actvig_camp WHERE origen = "sms" GROUP BY camp INTO temp tmp_plazsms WITH NO LOG;
	LET sContador = 0;
    SELECT MAX(total_p) INTO sContador FROM tmp_plazsms;

	IF sContador > 4 THEN	-- Maximo 4 plazos por campania.
		LET cCodRet = '000004';
		LET cmensaje = 'Numero de plazos para SMS No debe de ser mayor a 4.';
		RETURN cCodRet,cmensaje;
	END IF;

	-- Valida fechas.
	SELECT min (f_ini_vig), max(f_ini_vig) INTO dtIni_Vig_min, dtIni_Vig_max
	  FROM sd_actvig_camp WHERE origen = 'sucursal';
		
	IF ( dtIni_Vig_min <> dtIni_Vig_max ) THEN
		LET cCodRet = '000001';
		LET cmensaje = 'Diferentes inicios de vigencia';		
	ELIF  ((dtIni_Vig_min <> dt_fec_carga) OR (dtIni_Vig_max <> dt_fec_carga))THEN
		LET cCodRet = '000002';
		LET cmensaje = 'No coincide inicio de vigencia Vs fecha actual';	
	ELSE
		LET cCodRet = '000000';
	END IF;
	
	-- Indentifica si existen registros para SMS Y valida los montos asignados.
	SELECT COUNT(camp) INTO sTasasSms FROM bdicred:sd_actvig_camp WHERE origen = "sms";
	IF sTasasSms > 0 THEN 	-- Existe informacion de sms a cargar
	
		FOREACH WITH HOLD
		 SELECT montos INTO cMontos FROM sd_actvig_camp WHERE origen = 'sms'
		
			LET sContador = CHARINDEX('-',cMontos);
			LET sContadorAux = CHARINDEX('.',cMontos);
			LET sContadorAux2 = CHARINDEX(',',cMontos);

			-- Si: NO existe el guion '-', existe un punto, o existe una comda. Solo se permite el separador guion. 			
			IF sContador <= 0 OR sContadorAux > 0 OR sContadorAux2 > 0 THEN	
				LET cCodRet = '000005';
				LET cmensaje = 'Rango de montos incorrectos.';
				EXIT FOREACH;
			END IF;
			
			-- Valida que solo pueda enviarse una estructura de '500-600' si tiene otro caracter se rechaza.
			IF bdinteg:val_num(SUBSTR(cMontos, 1, (sContador - 1))) = 'f' OR bdinteg:val_num(SUBSTR (cMontos, (sContador + 1), length(cMontos))) = 'f' THEN
				LET cCodRet = '000005';
				LET cmensaje = 'Rango de montos incorrectos.';
				EXIT FOREACH;
			END IF;
			
		END FOREACH;
	END IF;

	IF cCodRet = '000000' THEN 

		-- Actualiza tasas para pagos fijos sucursales.
		FOREACH WITH HOLD
		   SELECT camp,    f_ini_vig, f_fin_vig, plazo,   tasa   --cast(tasa as decimal(18,2))
			 INTO siPromo, dtIni_Vig, dtFin_Vig, siPlazo, siTasa
			 FROM sd_actvig_camp WHERE origen = 'sucursal'

			BEGIN;
				UPDATE "informix".sd_promocion SET fechaini_promo = dtIni_Vig, fechafin_promo = dtFin_Vig WHERE num_promo = siPromo;
				UPDATE "informix".sd_tasa_plazo SET tasa = siTasa WHERE num_promo = siPromo and plazo = siPlazo;
			COMMIT;
		END FOREACH;
		
		-- Genera informacion de plazos y tasas para SMS
		IF sTasasSms > 0 THEN 	-- Existe informacion de sms a cargar
			BEGIN;
				TRUNCATE TABLE bdicred:sd_tasa_plazo_sms;
			COMMIT;
			
			LET cMontos = '';
			FOREACH WITH HOLD
			   SELECT camp,    f_ini_vig, f_fin_vig, plazo,   tasa,   montos   --cast(tasa as decimal(18,2))
				 INTO siPromo, dtIni_Vig, dtFin_Vig, siPlazo, siTasa, cMontos
				 FROM sd_actvig_camp WHERE origen = 'sms'
				 
				 
				LET sContador = CHARINDEX('-',cMontos);
				LET iMonto_Ini = SUBSTR(cMontos, 1, (sContador - 1));
				LET iMonto_Fin = SUBSTR (cMontos, (sContador + 1), length(cMontos));
			
				BEGIN;
					UPDATE "informix".sd_promocion SET fechaini_promo = dtIni_Vig, fechafin_promo = dtFin_Vig WHERE num_promo = siPromo;
					INSERT INTO bdicred:sd_tasa_plazo_sms ( empresa, num_producto, num_promo, tasa  , plazo   , plazo_activo, fecha_insert, monto_ini,  monto_fin ) 
													 VALUES ('001' , '6001'      , siPromo  , siTasa, siPlazo , 1           , today       , iMonto_Ini, iMonto_Fin);
				COMMIT;

			END FOREACH;
		END IF;	
			  
		LET cCadena = '';
		LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitacoraCamp)  ||'  delimiter ''|'' SELECT a.num_promo,fechaini_promo,fechafin_promo,nombre_promo ,plazo,tasa FROM "informix".sd_promocion a inner join "informix".sd_tasa_plazo  b ON a.num_promo = b.num_promo WHERE a.num_promo in (select camp from "informix".sd_actvig_camp where origen = '||'''sucursal''' ||') order by 1,2,3,5;" >'||TRIM(cRuta)||'bit_camp1.sql';
		SYSTEM cCadena;				
		LET cCadena='chmod 777 '|| TRIM(cRuta)||'bit_camp1.sql';
		System cCadena;				
		let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bit_camp1.sql';
		System cCadena;				
		LET cCadena = '' ;
		LET cCadena = 'rm ' || TRIM(cRuta) || 'bit_camp1.sql';
		SYSTEM cCadena;

		LET cCadena = '';
		LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitacCampSms)  ||'  delimiter ''|'' SELECT a.num_promo,fechaini_promo,fechafin_promo,nombre_promo ,plazo,tasa FROM "informix".sd_promocion a inner join "informix".sd_tasa_plazo_sms  b ON a.num_promo = b.num_promo WHERE a.num_promo in (select camp from "informix".sd_actvig_camp where origen = '||'''sms'''||') order by 1,2,3,5;" >'||TRIM(cRuta)||'bit_camp.sql';
		SYSTEM cCadena;				
		LET cCadena='chmod 777 '|| TRIM(cRuta)||'bit_camp.sql';
		System cCadena;				
		let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bit_camp.sql';
		System cCadena;				
		LET cCadena = '' ;
		LET cCadena = 'rm ' || TRIM(cRuta) || 'bit_camp.sql';
		SYSTEM cCadena;
	END IF;
	
	---	DROP TABLE sd_actvig_camp;

	RETURN cCodRet,cmensaje;
END
END PROCEDURE
DOCUMENT
'',
'AUTOR : Pamela Cardenas Balderas',
'FECHA : 30/MAYO/2018',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_calcula_interes_tdc(pEmpresa 				CHAR(3),
														pNumCredito 			CHAR(20),
														pFechaEmision 			DATE,
														pInicioSkip				INTEGER,
														pLimiteRegistros		INTEGER)
RETURNING	CHAR(5)   as codret,
			CHAR(30)  as cFechaCompleta,  
			CHAR(255) as cConcepto,
			CHAR(16)  as cCargo,
			CHAR(16)  as cAbono,
			CHAR(16)  as cSaldoPromedioDiario,
			CHAR(16)  as cSaldoSobCalculoInteres,
			CHAR(5)   as dInteresDiario

--------------------------------------------------------
-- DEFINICION DE VARIABLES 
--------------------------------------------------------
DEFINE sql_err   					SMALLINT;
DEFINE sCodRet   					CHAR(5);
DEFINE sCodRet2   					CHAR(5);
DEFINE sCodRet3   					CHAR(5);

DEFINE dFechaEmision 				DATE ;

DEFINE cSaldoPromedioDiario			CHAR(16);
DEFINE cConcepto 					CHAR(255);
DEFINE cCargo 						CHAR(16); --Compras
DEFINE cAbono 						CHAR(16);

DEFINE cSigFechaMov   				CHAR(9);
DEFINE cFechaMovAnt   				CHAR(9);
DEFINE cConceptoAnt   				CHAR(255);

DEFINE cSaldoPromedioDiarioInt		CHAR(16);
DEFINE cSaldoPromedioDiarioAux		CHAR(16);
DEFINE cUltimoSaldoDiario			CHAR(16);

DEFINE cEsIvaIntereses				CHAR(1);
DEFINE sMesAPoner					SMALLINT;
DEFINE sMesIngresado				SMALLINT;
DEFINE cSaldoDiario 				DECIMAL (14,2);

DEFINE cAnioCorto					CHAR(2);
DEFINE cMesAbreviado				CHAR(3);
DEFINE cDiaActual					CHAR(2);
DEFINE cMesNumero					CHAR(2);
DEFINE cAnioCompleto				CHAR(4);
DEFINE cMesCompleto					CHAR(10);
DEFINE cfechaAuxiliar				CHAR(8);
DEFINE cFechaCompleta				CHAR(30);

DEFINE cSaldoSobCalculoInteres		CHAR(16);
DEFINE cSaldoSobreCalculoInteresAnt	CHAR(16);
DEFINE cUltimoSaldoSobCalcInteres	CHAR(16);
DEFINE dInteresDiarioAux			DECIMAL(14,2);
DEFINE dInteresDiario				CHAR(5);
DEFINE iTamanioFecha				INTEGER;

DEFINE sContador                    SMALLINT;
DEFINE sDias						SMALLINT;
DEFINE sMovtos						SMALLINT;
DEFINE sInter						SMALLINT;
DEFINE cTasaInteres					DECIMAL(15,8);
DEFINE cDiaCorte					SMALLINT;
DEFINE cSaldoInicio					DECIMAL(18,2);
DEFINE cSaldoFin					DECIMAL(18,2);
DEFINE sContFecha					DATE;
DEFINE dFechaMov					DATE;
DEFINE sCargos						DECIMAL(18,2);
DEFINE sAbonos						DECIMAL(18,2);
DEFINE sDescripcion					CHAR(255);
DEFINE cSaldoPromedioDiario_t		DECIMAL(18,2);

--------------------------------------------------------
--	INICIALIZACION DE VARIABLES
--------------------------------------------------------
LET sql_err   					= 0;
LET sCodRet   					= "00000";
LET sCodRet2   					= "00000";
LET sCodRet3   					= "00000";

LET dFechaEmision 				= "";

LET cConcepto 					= "";
LET cCargo 						= "";
LET cAbono 						= "";

LET cSigFechaMov 				= "";
LET cFechaMovAnt  				= "";
LET cConceptoAnt  				= "";

LET cSaldoPromedioDiario 		= "";
LET cSaldoPromedioDiarioInt 	= "";
LET cSaldoPromedioDiarioAux		= "";
LET cUltimoSaldoDiario			= "";

LET cEsIvaIntereses 			= "0"; --Se inicializa en 0
LET sMesAPoner 					= 0;
LET sMesIngresado 				= 0;
LET cSaldoDiario 				= 0;

LET cAnioCorto					= "";
LET cMesAbreviado				= "";
LET cDiaActual					= "";
LET cMesNumero					= "";
LET cAnioCompleto				= "";
LET cMesCompleto				= "";
LET cFechaCompleta 				= "";

LET cSaldoSobCalculoInteres 	= "";
LET cSaldoSobreCalculoInteresAnt = "";
LET cUltimoSaldoSobCalcInteres  ="";
LET dInteresDiarioAux			= 0;
LET dInteresDiario				= "";
LET iTamanioFecha 				= 0;

LET sContador                   = 2;
LET sDias                       = 0;
LET sInter	                    = 0;
LET sMovtos						= 0;
LET cTasaInteres			 	= 0;
LET cDiaCorte					= 0;
LET cSaldoInicio				= 0;
LET cSaldoFin					= 0;
LET sContFecha					= DATE(1);
LET dFechaMov					= DATE(1);
LET sCargos						= 0;
LET sAbonos						= 0;
LET sDescripcion				= "";
LET cSaldoPromedioDiario_t		= 0;


BEGIN

	ON EXCEPTION SET sql_err
      LET sCodRet = sql_err;
	  DROP TABLE tmp_estado;
      RETURN sCodRet, 
		NVL(cFechaCompleta,""), NVL(cConcepto,""),NVL(cCargo,""),
		NVL(cAbono,""),NVL(cSaldoPromedioDiario,""),NVL(cSaldoSobCalculoInteres,""),NVL(dInteresDiario,0);
	END EXCEPTION ;
		
--SET DEBUG FILE TO "/informix/sp_calcula_interes_tdc_jom.out";
--TRACE ON;

	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
		
	select a.tasa_interes, dia_corte, nvl(c.sdo_cap_insoluto,0),  nvl(d.sdo_cap_insoluto,0)
	into cTasaInteres, cDiaCorte, cSaldoInicio, cSaldoFin	
	from bdicred:sd_maecred a
	join bdicred:sd_maecredanexo b on (a.num_credito = b.num_credito)
	left outer join bdicred:sd_maesdoshist c on (a.num_credito = c.num_credito and c.fecha = monthadd(mdy(month(pFechaEmision),dia_corte,year(pFechaEmision)),-1))
	left outer join bdicred:sd_maesdoshist d on (a.num_credito = d.num_credito and d.fecha = mdy(month(pFechaEmision),dia_corte,year(pFechaEmision)))
	where a.num_credito = pNumCredito;
		
	select secuencia, naturaleza, fecha_mov, case when naturaleza = 'C' then monto else 0 end cargo,case when naturaleza <> 'C' then monto else 0 end abono, 
			case when transacc = '8197' AND a.codigo_ref = 1 THEN TRIM(SUBSTRING(folio_suc FROM 6))||" Abono por remesa de BTS" 
				 else case when substr(referencia,1,1) = 'i' then nvl(TRIM(SUBSTRING(referencia FROM 18)),'')|| "  " ||NVL(TRIM(rfc_comer),'')|| "  " ||NVL(TRIM(referencia23),'')
                      else c.descripcion
                 end 
            end descripcion
	from bdicred:sd_movhis a
	left outer join bdicred:sd_transfun b on (a.empresa = b.empresa and a.codigo_fun = b.codigo_fun and a.codigo_ref = b.codigo_ref)
	left outer join bdinteg:si_transacc c on (b.transacc = c.numero)
	where a.empresa = '001'
	  and fecha_mov between monthadd(mdy(month(pFechaEmision),cDiaCorte,year(pFechaEmision)),-1) + 1 units day and mdy(month(pFechaEmision),cDiaCorte,year(pFechaEmision))
	  and reversado = 'N'
	  and se_emite_edocta = 'S'
	  and a.num_credito = pNumCredito
	order by fecha_mov,secuencia			
	into temp tmp_estado with no log;
	
	create index inx_tmp_estado on tmp_estado(fecha_mov);
	update statistics medium for table tmp_estado;
	
	IF (pInicioSkip = 0) THEN	
		RETURN sCodRet, "", "USTED DEBIA",cSaldoInicio, 0,0,0,0 WITH RESUME;
	END IF;
	
	LET sDias = (date(mdy(month(pFechaEmision),cDiaCorte,year(pFechaEmision))) - date(monthadd(mdy(month(pFechaEmision),cDiaCorte,year(pFechaEmision)),-1) + 1 units day))::integer;
	
	LET sContFecha = monthadd(mdy(month(pFechaEmision),cDiaCorte,year(pFechaEmision)),-1) + 1 units day;
	LET cSaldoPromedioDiario_t = cSaldoInicio;
	LET pLimiteRegistros = pInicioSkip + pLimiteRegistros;


	while sDias >= sInter
		select count(fecha_mov)
		  into sMovtos 
		  from tmp_estado
		where fecha_mov = sContFecha;

		LET cMesCompleto = 	DECODE (month(sContFecha),1,'Enero',2,'Febrero',3,'Marzo',4,'Abril',5,'Mayo',6,'Junio',7,'Julio',8,'Agosto',9,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre');
		LET cFechaCompleta = LPAD(day(sContFecha),2,'0')||' de '||trim(cMesCompleto)||' del '||LPAD(year(sContFecha),4,'0');
		
		if (sMovtos > 0) then	
			FOREACH WITH HOLD
				select fecha_mov, cargo, abono, descripcion
				  into dFechaMov, sCargos, sAbonos, sDescripcion
				from tmp_estado
				where fecha_mov = sContFecha 
				order by secuencia	
			
				LET cSaldoPromedioDiario_t = cSaldoPromedioDiario_t + sCargos - sAbonos;				
				
				LET sMovtos = sMovtos - 1;
				
				if (sMovtos = 0) then -- Envia ultimo registro
					IF (cSaldoPromedioDiario_t <= 0) THEN
						LET dInteresDiario = 0;
					ELSE
						LET dInteresDiario = round((cSaldoPromedioDiario_t * cTasaInteres / 100) / 360,2);
					END IF;
					if (sContador >= pInicioSkip) then
						RETURN sCodRet, cFechaCompleta, sDescripcion,sCargos, sAbonos,cSaldoPromedioDiario_t,cSaldoPromedioDiario_t,dInteresDiario WITH RESUME;
					end if;
				else
					if (sContador >= pInicioSkip) then
						RETURN sCodRet, cFechaCompleta, sDescripcion,sCargos, sAbonos,cSaldoPromedioDiario_t,"","" WITH RESUME;
					end if;						
				end if;
				LET sContador = sContador + 1;
				if (sContador > pLimiteRegistros) then
					EXIT FOREACH;
				end if;
			END FOREACH;
		else
			if (sContador >= pInicioSkip) then
				IF (cSaldoPromedioDiario_t <= 0) THEN
					LET dInteresDiario = 0;
				ELSE
					LET dInteresDiario = round((cSaldoPromedioDiario_t * cTasaInteres / 100) / 360,2);
				END IF;
				RETURN sCodRet, cFechaCompleta,"",0, 0,cSaldoPromedioDiario_t,cSaldoPromedioDiario_t,dInteresDiario WITH RESUME;
			end if;
			LET sContador = sContador + 1;
		end if;
		
		if (sContador > pLimiteRegistros) then
			LET sInter = sDias + 1;
		end if;
		
		LET sContFecha = sContFecha + 1 units day;
		LET	sInter = sInter +1;

		IF (sContador = pLimiteRegistros) THEN
			RETURN sCodRet, "", "",cSaldoFin, 0,0,0,0 WITH RESUME;
		END IF;		
		
	END WHILE;
	IF (sContador < pLimiteRegistros) THEN
		RETURN sCodRet, "", "USTED DEBE",cSaldoFin, 0,0,0,0 WITH RESUME;
		END IF;
	DROP TABLE tmp_estado;
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza sp para calcular interes tdc.',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_genrep_cteemp()
RETURNING CHAR(5) AS cod_ret;

--*****************************************************
-- DECLARACION DE VARIABLES
--*****************************************************
DEFINE CodRet		CHAR(5);
DEFINE sql_err		INTEGER;
DEFINE isam_err		INTEGER;
DEFINE CMensaje    CHAR(80);
DEFINE vsql			CHAR(2000);
DEFINE v_DiaActual	INTEGER;
DEFINE v_MesActual	INTEGER;
DEFINE v_AnioActual	INTEGER;
DEFINE v_TotalEmpActivos INTEGER;
DEFINE v_FechaHoy	DATE;
--*****************************************************
--- Inicializar variables
--*****************************************************
LET CodRet		= '';
LET sql_err		= 0 ;
LET isam_err	= 0 ;
LET CMensaje	= '';

	
--SET DEBUG FILE TO "/aplicacion/ifxsif01/Control-M/sp_genrep_cteemp.out";
--TRACE ON;

BEGIN

	ON EXCEPTION SET sql_err,isam_err,CMensaje
		LET CodRet = sql_err;
		RETURN CodRet;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
      
	--- Se obtiene la fecha actual del proceso
	SELECT 	DAY(fecha_hoy),		-- Dia actual
			MONTH(fecha_hoy),	-- Mes actual
			YEAR(fecha_hoy),	-- Año actual
			fecha_hoy			-- Fecha actual
	INTO	v_DiaActual,
			v_MesActual,
			v_AnioActual,
			v_FechaHoy 
	FROM	bdicred:"informix".sd_fechas
	WHERE	empresa = '001';

--- se valida si hay campañas activas en el mes actual
	SELECT COUNT(1)
	into v_TotalEmpActivos														-- Variable para contador de Campañas activas
	FROM bdinteg:"informix".si_rel_cte_empleado
	WHERE empresa = '001' AND status_emp = '1'; 

	--- Se valida si hay empleados activas
	IF	(v_TotalEmpActivos <> 0) THEN			
	
			/*
			-- Creacion de tabla que se va a usar temporalmente
			CREATE TABLE bdicred:"informix".sd_cte_empleado(                             
				numcte_banco	VARCHAR(10),   
				num_empleado	VARCHAR(10));

			select numcte_banco, num_empleado
			FROM bdinteg:"informix".si_rel_cte_empleado
			WHERE empresa = '001' AND status_emp = '1'
			INTO bdicred:"informix".sd_cte_empleado  WITH NO LOG;

			-- Generacion del reporte de empleados activos (RelEmpleadosTDCGC_AAAAMMDD.txt)
			let vsql = '';
			let vsql = 'echo "Empleado|Cliente">/resplogifx/Credito_GC/RelEmpleadosTDCGC_'||year(v_FechaHoy)||LPAD (MONTH(v_FechaHoy),2,"0")||day(v_FechaHoy)||'.txt';  
			system vsql;  
			*/
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/Credito_GC/QA_BajaArchivo.unl select distinct(num_empleado) from bdinteg:"informix".si_rel_cte_empleado where empresa = "001" AND status_emp = "1";">/resplogifx/Credito_GC/QA_BajaScript.sql';      
			system vsql;
					
			let vsql='chmod a+rwx /resplogifx/Credito_GC/QA_BajaScript.sql';
			System vsql;
					
			let vsql = '';
			let vsql= 'dbaccess bdicred /resplogifx/Credito_GC/QA_BajaScript.sql';
			system vsql;
					
			let vsql = vsql;
			let vsql ='rm /resplogifx/Credito_GC/QA_BajaScript.sql';
					
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/Credito_GC/QA_BajaArchivo.unl >>/resplogifx/Credito_GC/RelEmpleadosTDCGC_"||LPAD(MONTH(v_FechaHoy),2,"0")||LPAD(day(v_FechaHoy),2,"0")||year(v_FechaHoy)||'.txt';
			
			system vsql;
			let vsql ='rm /resplogifx/Credito_GC/QA_BajaArchivo.unl';
			system vsql; 
					
			-- Se elimina tabla Temporal
			--DROP TABLE bdicred:"informix".sd_cte_empleado; 
			
		ELSE
			--Generacion de Reporte y Resumen de Campañas de Recompensa Inmediata sin información a reportar
			let vsql = '';
			let vsql = 'echo " <<< No hay información a reportar >>> ">/resplogifx/Credito_GC/RelEmpleadosTDCGC_'||LPAD(MONTH(v_FechaHoy),2,"0")||LPAD(day(v_FechaHoy),2,"0")||year(v_FechaHoy)||'.txt';
			system vsql;
	END IF;	
	
	LET CodRet = '00000'; --> Proceso concluyo exitosamente
	LET CMensaje = 'El archivo se genero correctamente';
	END;
	
	RETURN CodRet;

END PROCEDURE;