CREATE PROCEDURE "informix".sp_consulta_incremento_linea_tc(
	cNumCredito CHAR(20),	-- Numero de credito.
	cNumTarjeta CHAR(20), 	-- Numero de tarjeta.
	cCanal CHAR(2)			-- Canal de aceptacion del incremento.
)
RETURNING  
	CHAR(5) 		AS cCodRet, 
	CHAR(1)			AS cIncrementoActivo, 
	DECIMAL(18,2)	AS cLineaCredito, 
	CHAR(10)		AS cFinVigencia, 
	CHAR(20)		AS cNumCte, 
	CHAR(20)		AS cNumCredito;

-- CONTROL DE CAMBIOS:
---------------------------------------------------------------------------------
-- Autor: Miguel Angel Felix Lopez.
-- Modificacion: Tiene como objetivo consultar  la informacion  del incremento linea de credito para notificar el aumento.
-- Fecha de Modificacion: 13-08-2024.
-- Peticion: RQM 10 1647 â Incremento  linea de credito TDC por inflacion.
---------------------------------------------------------------------------------
-- Autor: LERS 
-- Modificacion: Se agragan validaciones para la linea actual
-- Fecha de Modificacion: 31/07/2025
-- Peticion: RQM 10 1647 â Incremento  linea de credito TDC por inflacion.
---------------------------------------------------------------------------------
-- Autor: LERS 
-- Modificacion: Se modifica la longitud del tipo de dato a char(2) para el campo cCanal
-- Fecha de Modificacion: 04/11/2025
-- Peticion: RQM 10 1647 â Incremento  linea de credito TDC por inflacion.
---------------------------------------------------------------------------------
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************	
DEFINE cCodRet								CHAR(5);
DEFINE cIncrementoActivo 					CHAR(1);        	-- Bandera para saber si el cliente cuenta con un incremento por inflacion pendiente de aceptar.    
DEFINE cLineaCredito 						DECIMAL (18,2);	    -- Linea de credito final a retornar.
DEFINE cLinea_actual 						DECIMAL (18,2);     -- Linea de credito actual sin aumento por inflacion.
DEFINE cLinea_sugerida 						DECIMAL (18,2);     -- Linea de credito ya con el aumento por inflacion.
DEFINE cPorcentajeInflacion 				DECIMAL(18,2);      -- Porcentaje de inflacion anual.
DEFINE vFechaHoy							DATE;               -- Fecha del dia. 
DEFINE vFecha_Limite						DATE;           	-- Fecha limite para aceptar el incremento por inflacion.
DEFINE vsqlerr 								INTEGER;
DEFINE cNum_producto 						CHAR(20);
DEFINE cLinea_maxima  						DECIMAL(18,2);
DEFINE cLinea_minima  						DECIMAL(18,2);
DEFINE cConfirma_incremento 				CHAR(1);
DEFINE cNumCte								CHAR(20);
DEFINE dFecha_ultimo_ofertamiento_sucursal 	DATE;
DEFINE cCodretConBue 						CHAR(5);
DEFINE cMensaje 							CHAR(80); 
DEFINE cIsCtePros 							CHAR(1);
DEFINE c_num_cte 							CHAR(20); 
DEFINE cNombre 								CHAR(120);
DEFINE cRFC 								CHAR(13);
DEFINE dtFechaSol 							DATE;
DEFINE dtFechaAut 							DATE; 
DEFINE dLinCredAct 							DECIMAL(18,2);
DEFINE dLinCredCal 							DECIMAL (18,2);
DEFINE cOrigen 								CHAR(1);
DEFINE cStatus 								CHAR(2);
DEFINE cDescStatus 							CHAR(40);
DEFINE cComentario 							CHAR(80);
DEFINE cNumSol 								CHAR(20);
DEFINE cFinVigencia 						CHAR(10);
DEFINE cDia_fin_vigencia 					CHAR(2);
DEFINE cMes_fin_vigencia 					CHAR(2);
DEFINE cAnio_fin_vigencia 					CHAR(4);
DEFINE vExiste 								INTEGER;


-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET cCodRet 								= "00000";
LET cIncrementoActivo 						= "0";
LET cLineaCredito 							= 0;
LET cLinea_actual 							= 0;
LET cLinea_sugerida 						= 0;
LET cPorcentajeInflacion 					= 0; 
LET vFechaHoy 								= '';
LET vFecha_Limite 							= '';
LET cNum_producto 							= "0";
LET cLinea_maxima 							= 0;
LET cLinea_minima 							= 0;
LET cConfirma_incremento 					= "";
LET cNumCte 								= '';
LET dFecha_ultimo_ofertamiento_sucursal		= '';
LET cCodretConBue 							= "";
LET cMensaje 								= "";
LET cIsCtePros 								= "";
LET c_num_cte 								= ""; 
LET cNombre 								= "";
LET cRFC 									= "";
LET dtFechaSol 								= '';
LET dtFechaAut 								= ''; 
LET dLinCredAct 							= 0;
LET dLinCredCal 							= 0;
LET cOrigen 								= '';
LET cStatus 								= '';
LET cDescStatus 							= '';
LET cComentario 							= '';
LET cNumSol 								= '';
LET cFinVigencia 							= ''; 
LET cDia_fin_vigencia 						= '';
LET cMes_fin_vigencia 						= '';
LET cAnio_fin_vigencia 						= '';
LET vExiste 								= 0;



-- SET DEBUG FILE TO '/home/TRACE/Consulta/'||TRIM(cNumCredito)||'.out'; 
-- TRACE ON;


-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

BEGIN
	ON EXCEPTION SET vsqlerr       		 
		IF vsqlerr != 0 THEN
			LET cCodRet = vsqlerr;
			RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	-- **********************************************************************
    -- *                        PROGRAMA PRINCIPAL
    -- **********************************************************************

	-- Si el nuemero de credito y nuemero de tarjeta viene vacio.
	IF NVL(cNumCredito, '') = '' AND  NVL(cNumTarjeta, '') = '' THEN
		LET cCodRet = "00001";
		RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;
	END IF;

	-- Si el numero de credito viene vacio, se busca el cliente por el numero de tarjeta.
	IF NVL(cNumCredito,'') = '' THEN 
		SELECT num_credito 
			INTO cNumCredito
			FROM bdicred:"informix".sd_tarjeta
			WHERE num_tarjeta = cNumTarjeta;
		-- LERS 31/072025 - Se valida si el numero de credito no se encontro con el numero de tarjeta
		IF cNumCredito IS NULL OR cNumCredito = '' THEN
            LET cCodRet = '00009'; -- Numero de credito no encontrado por tarjeta
            LET cIncrementoActivo = '0';
            RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;
        END IF;
	END IF;

	-- Obtiene la fecha del dia. 
    SELECT fecha_hoy
		INTO vFechaHoy
		FROM bdicred:"informix".sd_fechas;

	-- Obtiene el monto otorgado del cliente
	SELECT monto_otorgado  	
		INTO cLinea_actual  --Linea actual del cliente sin el aumento por inflacion.
		FROM bdicred:"informix".sd_maesdos
		WHERE num_credito = cNumCredito;

    -- LERS 31/072025 - Validacion para no activar el incremento si la linea actual es NULL O cero
	IF cLinea_actual IS NULL OR cLinea_actual = 0 THEN
        LET cCodRet = '00006'; -- linea actual es nula o cero, no activa elincremento
        LET cIncrementoActivo = '0';
        RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;
    END IF;
	-- Obtiene la informacion del cliente, validando que la linea de credito este vigente.
	SELECT num_cliente, nueva_linea_credito, fin_vigencia,  fecha_ultimo_ofertamiento_sucursal, porcentaje_de_inflacion    
		INTO cNumCte, cLinea_sugerida, vFecha_Limite, dFecha_ultimo_ofertamiento_sucursal, cPorcentajeInflacion      --Linea del cliente ya con el aumento por inflacion.
		FROM bdicred:"informix".sd_bitacora_incremento_inflacion
		WHERE num_credito = cNumCredito
		AND Confirma_incremento <> "1" 
		AND fin_vigencia >= vFechaHoy;

	-- LERS 04/11/2025 - Se valida que se haya encontrado un registro con un incremento activo.
	IF cNumCte IS NULL OR cNumCte = '' THEN
        LET cCodRet = "00003"; -- No se encontro un incremento activo para el credito.
        RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;
    END IF;

	-- Obtiene el numero de producto asociado al credito.
	SELECT num_producto
		INTO cNum_producto
		FROM bdicred:"informix".sd_maecred
		WHERE num_credito = cNumCredito;
	-- LERS 04/11/2025 - Se valida el numero de producto nulo o vacio, asociado al credito.
	IF cNum_producto IS NULL OR cNum_producto = '' THEN
        LET cCodRet = '00002'; -- producto no encontrado no identificado o encontrado.
        RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;
    END IF;

	-- Obtiene el limite de credito maximo y minima asociado a un producto.
	SELECT linea_credito_maxima,linea_credito_minima
		INTO cLinea_maxima,cLinea_minima
		FROM bdicred:"informix".sd_param_incremento_inf_tc
		WHERE producto = cNum_producto;
		-- LERS 31/072025 - Valida monto maximo y minimo permitido es 0  o nulo 
        IF (cLinea_maxima = 0 OR cLinea_minima = 0) OR (cLinea_maxima IS NULL OR cLinea_minima IS NULL) THEN 
            LET cCodRet = "00007"; -- Limites de credito maximo o minimo no encontrados para el producto.
            RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;
        END IF;

	-- LERS 31/072025 - Valida que la linea de credito no sea por debajo del minimo para incremnto
    IF cLinea_actual < cLinea_minima THEN
        LET cCodRet = "00008"; -- Linea de credito por debajo del limite minimo para incremento
        RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;
    END IF;
	--Se valida si el credito esta en la bitacora de candidatos a incrementos por inflacion y no haya aceptado exitosamente el incremento con anterioridad.
	SELECT COUNT(num_credito) 
		INTO vExiste 
		FROM bdicred:"informix".sd_bitacora_incremento_inflacion
		WHERE num_credito = cNumCredito 
		AND Confirma_incremento <> "1"
		AND fin_vigencia >= vFechaHoy; 
	
	IF vExiste = 1 THEN
		--Verifica que no tenga un aumento por buen comportamiento pendiente
		EXECUTE PROCEDURE bdicred:"informix".sp_consultarctesincrementolincred_web("001",cNumCte,"","","1","",0,0) 
			INTO cCodretConBue, cMensaje, cIsCtePros, c_num_cte, cNombre, cRFC, dtFechaSol, dtFechaAut, dLinCredAct, dLinCredCal, cOrigen, cStatus, cDescStatus, cComentario, cNumSol;

		--Si tiene un aumento por buen comportamiento pendiente regresa como falso el incremento por inflacion
        IF cCodretConBue = "00000" THEN
			LET cCodRet  = '00004'; 
			RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;
        END IF;

		-- Verifica que no se muestre mas de una vez al dia el pop up, si el canal viene vacio significa que se esta ejecutando desde el SP sp_envio_sms_inc_tc.
		IF cCanal = '1' THEN 
			IF vFechaHoy <= dFecha_ultimo_ofertamiento_sucursal THEN
				LET cCodRet  = '00005'; 
				RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;
			END IF;
		END IF;

		LET cIncrementoActivo = "1";

		IF cLinea_actual > cLinea_sugerida THEN -- Si la linea actual es mayor se hace vuelve a calcular la linea con el aumento por inflacion.
			-- Calculo de la nueva linea de credito con redondeo a 2 cifras.		
			LET cLineaCredito = ROUND(cLinea_actual + (cLinea_actual * (cPorcentajeInflacion / 100)),-2);

			-- Revisar que no pase el tope limite permitido por producto.
			IF cLineaCredito >  cLinea_maxima THEN
				LET cLineaCredito = cLinea_maxima;
			END IF;

			-- Se actualiza la nueva linea de credito en la bitacora.
			UPDATE bdicred:"informix".sd_bitacora_incremento_inflacion
				SET nueva_linea_credito = cLineaCredito,
					linea_oferta = cLineaCredito
				WHERE num_credito = cNumCredito
				AND Confirma_incremento <> "1"
				AND fin_vigencia >= vFechaHoy;
			
		ELSE 		
			LET cLineaCredito = cLinea_sugerida;
		END IF;

		IF  cCanal = '1' THEN 
			-- Actualiza La fecha de ofertamiento en la bitacora cuando venga por algun canal diferente a vacio.
			UPDATE bdicred:"informix".sd_bitacora_incremento_inflacion 
				SET fecha_ultimo_ofertamiento_sucursal = vFechaHoy
				WHERE num_credito = cNumCredito 
				AND Confirma_incremento <> "1"
				AND fin_vigencia >= vFechaHoy;
		END IF;
		
		-- Se actualiza el canal por el cual se le notifica al cliente el aumento.
			UPDATE bdicred:"informix".sd_bitacora_incremento_inflacion
				SET canal_notificacion_cliente = cCanal
				WHERE num_credito = cNumCredito
				AND Confirma_incremento <> "1"
				AND fin_vigencia >= vFechaHoy;
				
		    UPDATE bdicred:"informix".sd_certificar_reglas_negocio
				SET canal_notificacion_cliente = cCanal
				WHERE num_credito = cNumCredito
				AND Confirma_incremento <> "1"
				AND fin_vigencia >= vFechaHoy; 
			--Se regresa la fecha en formato DIA/MES/ANIO para usarse en el pop up
			LET cDia_fin_vigencia  = DAY(vFecha_Limite);
			LET cMes_fin_vigencia  = MONTH(vFecha_Limite);
	
			IF cDia_fin_vigencia < 10 THEN
				LET cDia_fin_vigencia = "0" || cDia_fin_vigencia;
        	END IF;

			IF cMes_fin_vigencia < 10 THEN
				LET cMes_fin_vigencia = "0" || cMes_fin_vigencia ;
        	END IF;
			LET cAnio_fin_vigencia = YEAR(vFecha_Limite);
			LET cFinVigencia = TRIM(cDia_fin_vigencia)||'/'||TRIM(cMes_fin_vigencia)||'/'||TRIM(cAnio_fin_vigencia);

	END IF;

	RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;

END


END PROCEDURE
DOCUMENT 
'----------------------------------------------------------------------------',
'Descripcion : Tiene como objetivo consultar  la informacion  del incremento linea de credito para notificar el aumento.',
'Modifico    : MAFL',
'Fecha       : 07/10/2024',
'BD          : BDICRED',
'----------------------------------------------------------------------------',
'Descripcion : Validacion de la linea de credito actual',
'Modifico    : LERS',
'Fecha       : 07/31/2025',
'BD          : BDICRED',
'----------------------------------------------------------------------------',
'Descripcion : Cambio de longitud del campo cCanal, valicacion 00002 y 00003',
'Modifico    : LERS',
'Fecha       : 04/11/2025',
'BD          : BDICRED',
'----------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_actvig_camp() 
RETURNING CHAR(6),CHAR(55);

DEFINE iSqlErr			INTEGER;
DEFINE isam_err         INTEGER;
DEFINE error_info       VARCHAR(80);
DEFINE cCodRet 			CHAR(6);
DEFINE cmensaje 		CHAR(55);
DEFINE cRuta 			CHAR (50);
DEFINE cnom_archivo		CHAR(30);
DEFINE cBitacoraCamp	CHAR (50);
DEFINE cBitacCampSms	CHAR (50);
DEFINE cBitacCampApp    CHAR (50);
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
DEFINE sTasasApp		SMALLINT;
DEFINE iMonto_Ini		DECIMAL(10,2);
DEFINE iMonto_Fin 		DECIMAL(10,2);
DEFINE cMontos			CHAR(21);
--Agregar nuevos campos del Requerimiento 10 1365
DEFINE iCodigo		SMALLINT;
DEFINE cOrigen 		CHAR(10);
DEFINE cContadorAux3		SMALLINT;
DEFINE dtInicio		DATE;
DEFINE dtFin		DATE;
DEFINE cCampana		SMALLINT;
DEFINE cnombre		CHAR(100);
DEFINE cnomarchivo	CHAR(100);
DEFINE cnomarchivol	CHAR(100);
DEFINE cnomarchivoEjecSql	CHAR(100);
DEFINE cSQL			CHAR(2204);
DEFINE cSQL1		CHAR(200);
DEFINE cSQL2		CHAR(2004);
DEFINE cSQL3		CHAR(100);
DEFINE cRuta2		CHAR(100);
DEFINE cFechaGenArchivo		CHAR(8);
DEFINE cProceso		CHAR(4);
DEFINE cFechaCorte	DATE;
DEFINE bValidaArchivo		CHAR(1);

DEFINE iNumProducto CHAR(5);
DEFINE dIdentificador CHAR(6);
DEFINE iEmpresa CHAR(3);

LET iSqlErr 		= 0;
LET cCodRet 		= '000000';
LET cmensaje 		= '';
LET cCadena 		= '';
LET cRuta 			= '';
LET cnom_archivo	= '';
LET cBitacoraCamp	= '';
LET cBitacCampSms   = '';
LET cBitacCampApp   = '';
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
LET sTasasApp		= 0;
LET cMontos			= '';
LET iMonto_Ini 		= 0;
LET iMonto_Fin		= 0;
LET cArchivo_dbld   = "f_actvig_prosp.com";
LET cArchivo_log    = "f_actvig_prosp.log";
--Agregar nuevos campos del Requerimiento 10 1365
LET iCodigo = 0;
LET cContadorAux3 = 0;
LET dtInicio = '';
LET cOrigen = '';
LET dtFin = '';
LET cCampana = 0;
LET cnombre			= "PagosFijos_Con_";
LET cnomarchivo		= "";
LET cnomarchivol	= "";
LET cnomarchivoEjecSql	= "";
LET cSQL			= "";
LET cSQL1			= "";
LET cSQL2			= "";
LET cSQL3			= "";
LET cRuta2			= "/resplogifx/archivoscredito/";

--LET cProceso		= "";
LET bValidaArchivo		= 'N';
LET iNumProducto = "";
LET dIdentificador = "";
LET iEmpresa = '001';

BEGIN

	ON EXCEPTION
		SET iSqlErr, isam_err, error_info
		
		IF bValidaArchivo = 'N' THEN
			LET cCodRet = '000000';
			LET cmensaje = 'No se encuentra el archivo de vigencias de campanas';
			
			RETURN cCodRet,cmensaje;
		END IF;
		
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cmensaje = error_info;
		END IF;
		RETURN cCodRet,cmensaje;
	END EXCEPTION;
   	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;   

	--SET DEBUG FILE TO 'sp_actvig_camp.out';
	--TRACE ON;
	
	SELECT year(fecha_hoy)||lpad(month(fecha_hoy),2,0)||lpad(day(fecha_hoy),2,0),fecha_hoy
	  INTO cfec_arch,dt_fec_carga
	  FROM bdicred:sd_fechas;
	
    LET cnom_archivo = "actvig_prospectos_"||cfec_arch||'.txt';
    LET cBitacoraCamp = "bitacora_actvig_prospectos_"||cfec_arch||'.txt';
	LET cBitacCampSms = "bitacora_actvig_prospectos_sms_"||cfec_arch||'.txt';
	LET cBitacCampApp = "bitacora_actvig_prospectos_app_"||cfec_arch||'.txt';

    LET cRuta = "/resplogifx/archivoscredito/";   
		
	--Se valida que el archivo exista en la carpeta
	system ' cat ' || TRIM(cRuta) || cnom_archivo;
	
	LET bValidaArchivo = 'S'; --Si existe el archivo se modifica la bandera

	--DROP TABLE IF EXISTS "informix".sd_actvig_camp;
    DROP TABLE IF EXISTS "informix".tmp_sd_actvig_camp;	
	CREATE TABLE tmp_sd_actvig_camp (
		camp 		varchar(3),
		f_ini_vig	date,
		f_fin_vig	date,
		plazo	 	varchar(5),
		tasa  		decimal(10,2),
		origen 		char(10),
		montos		char(21),
		tipo_compra char(1),
		identificador char(6),
		giro		char(2),
		tipo		char(10),
		bloqueo		char(1),
		desbloqueo  char(3),
		carga		char(1),
		prioridad	char(1)
	);
		
   system ' echo "FILE ' ||  TRIM(cRuta) ||  TRIM(cnom_archivo) ||' DELIMITER '|| "'" || '|' || "'" || ' 15; ' || '">' || TRIM(cRuta) || TRIM(cArchivo_dbld);  
   system ' echo "INSERT INTO tmp_sd_actvig_camp;' || '">>' || TRIM(cRuta) || TRIM(cArchivo_dbld);
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
	
	create index inx1_activ_camp_tmp on tmp_sd_actvig_camp(origen);
	 
	--Se agrega campo para saber si una campaÃ±a fue cargada o no
	alter table tmp_sd_actvig_camp add cargado char(1);
	
	-- Valida que esten correctamente escritas las palabras: sucursal y sms
	LET sContador = 0;
	UPDATE tmp_sd_actvig_camp SET origen = lower(origen);
	-- CAMBIO AGREGAR APP 12-05-25
	SELECT COUNT(camp) INTO sContador FROM tmp_sd_actvig_camp WHERE origen != "sucursal" AND origen != "sms" AND origen != "app";
	IF sContador > 0 THEN
		LET cCodRet = '000003';
		LET cmensaje = 'Banderas de origen (sucursal, sms o app) son incorrectas.';
		RETURN cCodRet,cmensaje;
	END IF;
	
		-- Validar que el plazo no sea repetido
	LET sContador = 0;
	FOREACH
		SELECT origen, camp, plazo, COUNT(plazo) INTO cOrigen, cCampana, siPlazo, sContador FROM tmp_sd_actvig_camp WHERE origen IN ("sms", "app") GROUP BY origen, camp, plazo
		IF sContador > 1 THEN
			LET cCodRet = '000007';
			LET cmensaje = 'Existe un plazo duplicado [' || siPlazo || '] de la camp [' || cCampana || '] del origen [' || TRIM(cOrigen) || '].';
			RETURN cCodRet, cmensaje;
		END IF;
	END FOREACH;
	
	--Valida que las fechas no se traslapen
	FOREACH
		select distinct(camp) into cCampana from tmp_sd_actvig_camp
		FOREACH
			select rowid, camp, f_ini_vig, f_fin_vig, plazo, tasa, origen into iCodigo, cCampana, dtInicio, dtFin, siPlazo, siTasa, cOrigen  from tmp_sd_actvig_camp where camp = cCampana

			if(dtInicio >= dtFin) THEN
				LET cCodRet = '000006';
				LET cmensaje = 'La fecha fin vigencia debe ser mayor que fecha inicio';
				RETURN cCodRet,cmensaje;
			else
				select count(camp) into cContadorAux3 from tmp_sd_actvig_camp where dtInicio >= f_ini_vig and dtInicio < f_fin_vig and camp = cCampana and plazo = siPlazo and tasa = siTasa and origen = cOrigen and cargado = 1;

				if(cContadorAux3 > 0 ) THEN
					update tmp_sd_actvig_camp set cargado = '0' where camp = cCampana and f_ini_vig = dtInicio and f_fin_vig = dtFin and plazo = siPlazo and tasa = siTasa and origen = cOrigen and rowid = iCodigo;
				else
					update tmp_sd_actvig_camp set cargado = '1' where camp = cCampana and f_ini_vig = dtInicio and f_fin_vig = dtFin and plazo = siPlazo and tasa = siTasa and origen = cOrigen and rowid = iCodigo;
				end if;
			end if;
		END FOREACH;
	END FOREACH;
	
	--Pasar campaÃ±as con el campo cargado en 1
	DROP TABLE IF EXISTS "informix".sd_actvig_camp;
	CREATE TABLE sd_actvig_camp (
		camp 		varchar(3),
		f_ini_vig	date,
		f_fin_vig	date,
		plazo	 	varchar(5),
		tasa  		decimal(10,2),
		origen 		char(10),
		montos		char(21),
		tipo_compra char(1),
		identificador char(6),
		giro		char(2),
		tipo		char(10),
		bloqueo		char(1),
		desbloqueo  char(3),
		carga		char(1),
		prioridad	char(1)
	);
	
	insert into sd_actvig_camp (camp, f_ini_vig, f_fin_vig, plazo, tasa, origen, montos, tipo_compra, identificador, giro, tipo, bloqueo, desbloqueo, carga, prioridad)
	select camp, f_ini_vig, f_fin_vig, plazo, tasa, origen, montos, tipo_compra, identificador, giro, tipo, bloqueo, desbloqueo, carga, prioridad from tmp_sd_actvig_camp where cargado = "1";
	
	create index inx1_activ_camp on sd_actvig_camp(origen);
	
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

	
	-- Indentifica si existen registros para SMS Y valida los montos asignados.
	SELECT COUNT(camp) INTO sTasasSms FROM bdicred:sd_actvig_camp WHERE origen = "sms";
	IF sTasasSms > 0 THEN 	-- Existe informacion de sms a cargar
	
		FOREACH WITH HOLD
		 SELECT montos INTO cMontos FROM sd_actvig_camp WHERE origen = 'sms'
		
			LET sContador = CHARINDEX('-',cMontos);
			LET sContadorAux = CHARINDEX('.',cMontos);
			LET sContadorAux2 = CHARINDEX(',',cMontos);

			-- Si: NO existe el guion '-', existe un punto, o existe una coma. Solo se permite el separador guion. 			
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
	
	
	-- Identificar si existe informacion correcta desde app para cargar y valida montos.
	SELECT COUNT(camp) INTO sTasasApp FROM bdicred:sd_actvig_camp WHERE origen = "app";
	IF sTasasApp > 0 THEN 	-- Existe informacion de app a cargar
	
		FOREACH WITH HOLD
		 SELECT montos INTO cMontos FROM sd_actvig_camp WHERE origen = 'app'
		
			LET sContador = CHARINDEX('-',cMontos);
			LET sContadorAux = CHARINDEX('.',cMontos);
			LET sContadorAux2 = CHARINDEX(',',cMontos);

			-- Si: NO existe el guion '-', existe un punto, o existe una coma. Solo se permite el separador guion. 			
			IF sContador <= 0 OR sContadorAux > 0 OR sContadorAux2 > 0 THEN	
				LET cCodRet = '000005';
				LET cmensaje = 'Rango de montos incorrectos. Formato correcto: ''500-600''. Solo se permite el separador guion.';
				EXIT FOREACH;
			END IF;
			
			-- Valida que solo pueda enviarse una estructura de '500-600' si tiene otro caracter se rechaza.
			IF bdinteg:val_num(SUBSTR(cMontos, 1, (sContador - 1))) = 'f' OR bdinteg:val_num(SUBSTR (cMontos, (sContador + 1), length(cMontos))) = 'f' THEN
				LET cCodRet = '000005';
				LET cmensaje = 'Rango de montos incorrectos. Formato correcto: ''500-600''.';
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
				--Se agregan los productos de TDC para los que aplicaran las campaÃ±as
				BEGIN;
					UPDATE "informix".sd_promocion SET fechaini_promo = dtIni_Vig, fechafin_promo = dtFin_Vig WHERE num_promo = siPromo;
					INSERT INTO bdicred:sd_tasa_plazo_sms ( empresa, num_producto, num_promo, tasa  , plazo   , plazo_activo, fecha_insert, monto_ini,  monto_fin ) 
													 VALUES ('001' , '6001'      , siPromo  , siTasa, siPlazo , 1           , today       , iMonto_Ini, iMonto_Fin);
					INSERT INTO bdicred:sd_tasa_plazo_sms ( empresa, num_producto, num_promo, tasa  , plazo   , plazo_activo, fecha_insert, monto_ini,  monto_fin ) 
													 VALUES ('001' , '7000'      , siPromo  , siTasa, siPlazo , 1           , today       , iMonto_Ini, iMonto_Fin);
					INSERT INTO bdicred:sd_tasa_plazo_sms ( empresa, num_producto, num_promo, tasa  , plazo   , plazo_activo, fecha_insert, monto_ini,  monto_fin ) 
													 VALUES ('001' , '8100'      , siPromo  , siTasa, siPlazo , 1           , today       , iMonto_Ini, iMonto_Fin);
					INSERT INTO bdicred:sd_tasa_plazo_sms ( empresa, num_producto, num_promo, tasa  , plazo   , plazo_activo, fecha_insert, monto_ini,  monto_fin ) 
													 VALUES ('001' , '8500'      , siPromo  , siTasa, siPlazo , 1           , today       , iMonto_Ini, iMonto_Fin);
				COMMIT;

			END FOREACH;
		END IF;	
		
		
		-- Genera informacion de plazos y tasas para APP
		IF sTasasApp > 0 THEN 	-- Existe informacion de app a cargar
			BEGIN;
				DELETE FROM bdicred:sd_tasa_plazo_app WHERE num_promo IN (SELECT DISTINCT camp FROM bdicred:sd_actvig_camp WHERE origen = "app");
			COMMIT;
			
			LET cMontos = '';
			FOREACH WITH HOLD
			   SELECT camp,    f_ini_vig, f_fin_vig, plazo,   tasa,   montos, identificador   --cast(tasa as decimal(18,2))
				 INTO siPromo, dtIni_Vig, dtFin_Vig, siPlazo, siTasa, cMontos, dIdentificador
				 FROM sd_actvig_camp WHERE origen = 'app'
				 
				 
				LET iNumProducto = SUBSTR(dIdentificador, (CHARINDEX('-', dIdentificador) + 1), length(dIdentificador)); 
				LET sContador = CHARINDEX('-',cMontos);
				LET iMonto_Ini = SUBSTR(cMontos, 1, (sContador - 1));
				LET iMonto_Fin = SUBSTR (cMontos, (sContador + 1), length(cMontos));
				
				--Se agregan los productos de TDC para los que aplicaran las campaÃ±as
				BEGIN;
					UPDATE "informix".sd_promocion SET fechaini_promo = dtIni_Vig, fechafin_promo = dtFin_Vig WHERE num_promo = siPromo;
					INSERT INTO bdicred:sd_tasa_plazo_app (empresa, num_producto, num_promo, tasa  , plazo   , plazo_activo, fecha_insert, monto_ini,  monto_fin ) 
													 VALUES (iEmpresa ,iNumProducto, siPromo  , siTasa, siPlazo , 1           , today       , iMonto_Ini, iMonto_Fin);
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
		--LET cCadena = 'rm ' || TRIM(cRuta) || 'bit_camp1.sql';
		SYSTEM cCadena;

		LET cCadena = '';
		LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitacCampSms)  ||'  delimiter ''|'' SELECT a.num_promo,fechaini_promo,fechafin_promo,nombre_promo ,plazo,tasa FROM "informix".sd_promocion a inner join "informix".sd_tasa_plazo_sms  b ON a.num_promo = b.num_promo WHERE a.num_promo in (select camp from "informix".sd_actvig_camp where origen = '||'''sms'''||') order by 1,2,3,5;" >'||TRIM(cRuta)||'bit_camp.sql';
		SYSTEM cCadena;				
		LET cCadena='chmod 777 '|| TRIM(cRuta)||'bit_camp.sql';
		System cCadena;				
		let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bit_camp.sql';
		System cCadena;				
		LET cCadena = '' ;
		--LET cCadena = 'rm ' || TRIM(cRuta) || 'bit_camp.sql';
		SYSTEM cCadena;
		
		
		LET cCadena = '';
		LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitacCampApp)  ||'  delimiter ''|'' SELECT a.num_promo,fechaini_promo,fechafin_promo,nombre_promo ,plazo,tasa FROM "informix".sd_promocion a inner join "informix".sd_tasa_plazo_app  b ON a.num_promo = b.num_promo WHERE a.num_promo in (select camp from "informix".sd_actvig_camp where origen = '||'''app'''||') order by 1,2,3,5;" >'||TRIM(cRuta)||'bit_camp_app.sql';
		SYSTEM cCadena;				
		LET cCadena='chmod 777 '|| TRIM(cRuta)||'bit_camp_app.sql';
		System cCadena;				
		let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bit_camp_app.sql';
		System cCadena;				
		LET cCadena = '' ;
		--LET cCadena = 'rm ' || TRIM(cRuta) || 'bit_camp.sql';
		SYSTEM cCadena;
		
	END IF;
	LET cFechaGenArchivo = to_char(dt_fec_carga, '%d%m%Y');
		--LET cFechaCorte = cfec_arch;
		
		--LET cnomarchivol = TRIM(cnombre)||cFechaGenArchivo||'_Aux_'||'.txt';
		LET cnomarchivol = TRIM(cnombre)||cFechaGenArchivo||'.txt';
		LET cnomarchivoEjecSql = 'Exec_Rep_Con_6900' || '.sql';
		
		LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta2) || TRIM(cnomarchivol);
		LET cSQL2 = " SELECT camp, f_ini_vig, f_fin_vig, plazo, tasa, origen, montos, tipo_compra, identificador, giro, tipo, bloqueo, desbloqueo, carga, prioridad, cargado FROM bdicred:tmp_sd_actvig_camp;";
		
		LET cSQL3 = '">'||TRIM(cRuta2)|| cnomarchivoEjecSql;
		LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
		System cSQL;

		LET cSQL='chmod 777 '|| TRIM(cRuta2)|| cnomarchivoEjecSql;
		System cSQL;

		let cSQL = 'dbaccess bdicred ' || TRIM(cRuta2) || cnomarchivoEjecSql;
		System cSQL;

		--LET cSql = cSql;
		--LET cSql = "sed 's/|$//g' "|| TRIM(cRuta2) || TRIM(cnomarchivol) || " >> " || TRIM(cRuta2) || TRIM(cnomarchivol);
		SYSTEM cSql;

		--Borra el archivo de control.
		LET cSQL = '' ;
		--LET cSQL = 'rm ' || TRIM(cRuta2) || cnomarchivoejecsql || ' ' || TRIM(cRuta2) || cnomarchivol;
		LET cSQL = 'rm ' || TRIM(cRuta2) || cnomarchivoejecsql;
		SYSTEM cSQL;

		--LET cCod_Ret = '000000';
		--LET cMensaje = 'PROCESO EXITOSO';

		--CALL bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCod_ret, 'TERMINA CREACION REPORTE', '02') Returning cCod_RetIB;
	
	DROP TABLE tmp_sd_actvig_camp;

	LET cmensaje = 'Actualizacion de Vigencia Pagos Fijos Ok';

	RETURN cCodRet,cmensaje;
END
END PROCEDURE
DOCUMENT
'',
'AUTOR : Pamela Cardenas Balderas',
'FECHA : 30/MAYO/2018',
'BD    : BDICRED',
'AUTOR: Andrea Mariana Urrea Urias',
'CAMBIOS 13-05-25, ACEPTAR ORIGEN PROMO APP Y INSERTAR NO DE PRODUCTO DESDE LAYOUT',
'FECHA : 13/MAYO/2025',
'BD    : BDICRED',
'AUTOR: Luis German Diep Rendon',
'CAMBIOS 13-05-25, VALIDACION PARA PLAZOS DUPLICADOS EN ORIGEN APP Y SMS',
'FECHA : 10/SEPTIEMBRE/2025',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_apercred1_credisol(
			 pEmpresa       VARCHAR(3), 	-- EMPRESA
             pSolicitud     VARCHAR(20), 	-- NUMERO DE SOLICITUD
		 	 pEjecutivo     CHAR(8),		-- EJECUTIVO
			 pPlazo			INTEGER,		-- PLAZO EN MESES PARA PAGAR EL CREDITO
			 pNombrePres	CHAR(50),		-- NOMBRE DEL PRESTAMO
			 pMonto			DECIMAL(18,2),	-- MONTO APROBADO
			 pCuentaCap		CHAR(20),		-- CUENTA DE CAPTACION
			 pMensualidad	MONEY(18,2),		-- IMPORTE MENSUAL
			 pCanal 		SMALLINT  	DEFAULT 0 -- CANAL       
			 )

RETURNING CHAR(6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),CHAR(1);


--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se modificÃ³ para realizar la validaciÃ³n de los dÃ­as inhabiles.
--Fecha: 2010/01/27
--Version: 20100127.1100

--MODIFICO: JesÃºs Manuel Aguilar Heredia
--Descripcion: Se modificÃ³ para implemtentar la apertura de credisoluciones
--Fecha: 2012/01/12
--Version: 20120112.1100

--MODIFICO: Andrea Mariana Urrea Urias 
--Descripcion: Se agrego adecuaciones para permitir las promociones desde otros canales (bdinteg:si_canales)
--Fecha:2025/07/30
--Version: 20250730.1100

--*****************************************************
--DECLARACION DE VARIABLES
--*****************************************************
DEFINE cCodRet				VARCHAR(6);		-- CODIGO DE RETORNO
DEFINE cErrorInfo           VARCHAR(80);	-- MENSAJE DE ERROR
DEFINE mTasaInteres         DECIMAL(18,2);	-- TASA DE INTERES
DEFINE mTasaMora            DECIMAL(18,2);	-- TASA MORATORIA
DEFINE mSobreTasa           DECIMAL(18,2);	-- SOBRETASA
DEFINE mTasaFavor           DECIMAL(18,2);	-- TASA A FAVOR
DEFINE mSobreTasaFAV        DECIMAL(18,2);	-- SOBRETASA A FAVOR DEL CLIENTE
DEFINE cFactor	            CHAR(1);		-- FACTOR
DEFINE dFechaApert          DATE;			-- FECHA DE INICIO DEL PRESTAMO
DEFINE dFechaVenc           DATE;			-- FECHA DE TERMINACIÃN DEL PRESTAMO
DEFINE iSqlErr              INTEGER;		-- CODIGO DE ERROR
DEFINE iIsamError           INTEGER;		-- CODIGO DE ERROR
DEFINE cNumCte              CHAR(20);		-- NUMERO DE CLIENTE
DEFINE cTpCte               CHAR(1);		-- TIPO DE CLIENTE
DEFINE mIngreso             DECIMAL(18,2);	-- INGRESO DEL CLIENTE
DEFINE cFactorFAV           CHAR(1);		-- FACTOR A FAVOR DEL CLIENTE
DEFINE cProducto            CHAR(4);		-- CODIGO DE PRODUCTO
DEFINE cDivisa              CHAR(2);		-- DIVISA
DEFINE cSucursal            CHAR(4);		-- CODIGO DE SUCURSAL
DEFINE cFolio	            CHAR(16);		-- FOLIO PARA GENERACION DE MOVIMIENTOS DIARIOS
DEFINE cMensaje             CHAR(200);		-- MENSAJE MAS NOMBRE DE EJECUTIVO
DEFINE dFechaT              DATE;			-- FECHA DEL MES POSTERIOR A LA APERTURA
DEFINE sDiaCorte            SMALLINT;		-- DIA DE CORTE
DEFINE i		     		SMALLINT;		-- VARIABLE PARA ITERACION
DEFINE mCatIva		    	DECIMAL(18,2);	-- VALOR DEL CAT DEL IVA
DEFINE cMercadeo            CHAR(1);		-- PUBLICACION
DEFINE sSecIngreso 			SMALLINT;		-- SECUENCIA DE INGRESOS

DEFINE mTasaInteresProd		DECIMAL(18,2);	-- TASA DE INTERES DEL PRODUCTO
DEFINE mTasaMoraProd		DECIMAL(18,2);	-- TASA DE INTERES DEL PRODUCTO
DEFINE cPeriodoPag			CHAR(1);		-- PERIODICIDAD DEL PAGO
DEFINE iDiasTraspCap		INTEGER;		-- DIAS PARA TRASPASO DE CAPITAL
DEFINE iDiasTraspInt		INTEGER;		-- DIAS PARA TRASPASO DE INTERESES
DEFINE cNumeroFolio 		CHAR(16);		-- FOLIO PARA REGISTRAR EL ABONO
DEFINE cTransacc 			CHAR(4);	 	-- FOLIO DE TRANSACCION DEL ABONO
DEFINE iNumReg				INTEGER;		-- NUMERO DE REGISTROS DE UNA OPERACION
DEFINE dIvaSuc              DECIMAL(5,3);   -- IVA DE LA SUCURSAL DONDE SE GENERÃ LA SOLICITUD
DEFINE idAbono              CHAR(1);
DEFINE bandesp              SMALLINT;
DEFINE v_tasainteres        DECIMAL(18,2);   
DEFINE sCountExist          SMALLINT;
DEFINE sContPaso	        SMALLINT;
DEFINE sNumPromocion		SMALLINT;
DEFINE sCountExstCred		SMALLINT;
DEFINE sCountExstDos		SMALLINT;
DEFINE sCountExstAnexo		SMALLINT;
DEFINE sCountCtasCarg		SMALLINT;
DEFINE sCountAmortiz		SMALLINT;
DEFINE sCountAutoriz		SMALLINT;
DEFINE sCountExistSms		SMALLINT;
DEFINE cStatus_cred 		CHAR(2);
DEFINE cIFRS				CHAR(1);
DEFINE iAtr_Act_ifrs		INTEGER;
DEFINE iDisposicionEfectivoApp      SMALLINT;  
DEFINE iComprasApp          SMALLINT; 
DEFINE iCanalApp			SMALLINT;
DEFINE pNumCredito         	CHAR(20);
DEFINE pPromo              	INTEGER;
DEFINE tasaPref 			DECIMAL(18,6);


--***********************
--INICIALIZA VARIABLES
--***********************

LET cCodRet      		= '000000';
LET cErrorInfo    		= 'PROCESO EXITOSO';
LET mTasaInteres 		= 0;
LET mTasaMora 			= 0;
LET mSobreTasa   		= 0;
LET mTasaFavor   		= 0;
LET mSobreTasaFAV		= 0;
LET cFactor	  			= "";
LET dFechaApert 		= DATE(1);
LET dFechaVenc 			= DATE(1);
LET iSqlErr    			= 0;
LET iIsamError 			= 0;
LET cErrorInfo 			= "";
LET cNumCte    			= "";
LET cTpCte     			= "";
LET mIngreso   			= 0;
LET cFactorFAV 			= "";
LET cProducto  			= "";
LET cDivisa    			= "";
LET cSucursal			= "";
LET cFolio				= "";
LET cMensaje 			= "";
LET dFechaT  			= DATE(1);
LET sDiaCorte			= 0;
LET i 					= 0;
LET mCatIva				= 0;
LET cMercadeo 			= "";
LET sSecIngreso			= 0;

LET mTasaInteresProd	= 0;
LET cPeriodoPag			= "";
LET iDiasTraspCap		= 0;
LET iDiasTraspInt		= 0;
LET cNumeroFolio		= "";
LET cTransacc			= "";
LET iNumReg				= 0;

LET dIvaSuc             = 0;
LET idAbono             = "N";
LET bandesp             = 0;
LET v_tasainteres       = 0;
LET sCountExist			= 0;
LET sContPaso	        = 0;
LET sNumPromocion		= 0;
LET sCountExstCred		= 0;
LET sCountExstDos		= 0;
LET sCountExstAnexo		= 0;
LET sCountCtasCarg		= 0;
LET sCountAmortiz		= 0;
LET sCountAutoriz		= 0;
LET sCountExistSms		= 0;
LET cIFRS				= '';
LET iAtr_Act_ifrs		= 0;
LET cStatus_cred 		= '';
LET iDisposicionEfectivoApp = 7;
LET iComprasApp 		= 8;
LET iCanalApp 			= 17;
LET pNumCredito         = '';
LET pPromo              = 0;
LET tasaPref 			= 0;



--Set debug file to  '/tmp/apercred_pp.out';
--trace on;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
		LET cErrorInfo  = cErrorInfo;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		

		DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
        IF idAbono = "S" THEN
             CALL bdicheq:reversion(pEmpresa,cSucursal,pEjecutivo,cNumeroFolio,'R') RETURNING cCodRet;
             IF cCodRet <> "000" THEN
                LET cCodRet    = "000004";
             END IF;
        END IF;
        LET cCodRet    = iSqlErr;
        RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
    END EXCEPTION;
	
	
	SELECT NVL(valor,'I') INTO cIFRS FROM bdicred:sd_param WHERE cod_param = '700';
	IF cIFRS = 'A' THEN
		LET cStatus_cred = 'E1';
		LET iAtr_Act_ifrs = 0;
	ELSE
		LET cStatus_cred = 'AA';
		LET iAtr_Act_ifrs = NULL;
	END IF;	

	--SE VALIDA QUE LOS DATOS DE ENTRADA SEAN CORRECTOS
    IF pSolicitud > '690000000000' THEN
        IF NVL(pEmpresa,"") = "" OR NVL(pSolicitud,"") = "" OR NVL(pEjecutivo,"") = "" OR NVL(pPlazo,0) = 0 OR NVL(pNombrePres,"") = "" OR
           NVL(pMonto,0) = 0 THEN
            LET cCodRet = "000002";
            RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
        END IF
    ELSE
        IF NVL(pEmpresa,"") = "" OR NVL(pSolicitud,"") = "" OR NVL(pEjecutivo,"") = "" OR NVL(pPlazo,0) = 0 OR NVL(pNombrePres,"") = "" OR
           NVL(pMonto,0) = 0 OR NVL(pCuentaCap,"") = "" THEN
            LET cCodRet = "000002";
            RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
        END IF
    END IF;

-- SE OBTIENEN LAS FECHAS DE INICIO, Y FIN DEL PRESTAMO Y LA FECHA DEL SIGUIENTE MES DESPUES DE LA APERTURA DEL CREDITO
    SELECT fecha_hoy INTO dFechaApert FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;

    CALL bdicred:"informix".monthadd(dFechaApert,pPlazo) RETURNING dFechaVenc;

	CALL bdicred:"informix".monthadd(dFechaApert,1) RETURNING dFechaT;
    CALL bdicred:"informix".sp_valfechabil(dFechaT,'+') RETURNING cCodRet, dFechaT;

    IF cCodRet <> "000" THEN
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
    END IF;

	--SE VALIDA QUE NO EXISTA EL CREDITO
	SELECT count(num_credito) INTO sCountExstCred FROM bdicred:"informix".SD_MAECREDCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	SELECT count(num_credito) INTO sCountExstDos FROM bdicred:"informix".SD_MAESDOSCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	SELECT count(num_credito) INTO sCountExstAnexo FROM bdicred:"informix".SD_MAECREDANEXOCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	SELECT count(num_credito) INTO sCountCtasCarg FROM bdicred:"informix".sd_ctascarg WHERE empresa = pEmpresa AND Naturaleza = 'A' AND num_credito = pSolicitud;
	SELECT count(num_credito) INTO sCountAmortiz FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND fecha_cuota = dFechaT AND num_credito = pSolicitud;
	SELECT count(num_solicitud) INTO sCountAutoriz FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
	


	--IF EXISTS (SELECT num_credito FROM bdicred:"informix".SD_MAECREDCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud) THEN
	IF sCountExstCred >= 1 THEN
		LET cCodRet = "000001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM bdicred:"informix".SD_MAESDOSCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud) THEN
	ELIF sCountExstDos >= 1 THEN
		LET cCodRet = "000001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM bdicred:"informix".SD_MAECREDANEXOCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud) THEN
	ELIF sCountExstAnexo >= 1 THEN
		LET cCodRet = "000001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM bdicred:"informix".sd_ctascarg WHERE empresa = pEmpresa AND Naturaleza = 'A' AND num_credito = pSolicitud) THEN
	ELIF sCountCtasCarg >= 1 THEN
		LET cCodRet = "000001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND fecha_cuota = dFechaT AND num_credito = pSolicitud) THEN
	ELIF sCountAmortiz >= 1 THEN
		LET cCodRet = "000001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP") THEN
	ELIF sCountAutoriz >= 1 THEN
		LET cCodRet = "000001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF;

	--   Asigna el Valor del CAT con IVA para el Contrato TC MEL 15 May 2008
	SELECT valor INTO mCatIva
	FROM  bdicred:'informix'.sd_param
	WHERE  cod_param = '034';
	IF mCatIva IS NULL THEN
	   LET mCatIva = 0;
	END IF
	
	---Validar que el credito exista en las tablas de promociones, en casod e existir se se tomara la informacion de las tablas de promociones.
	SELECT count(num_sol_prestamo) INTO sCountExist FROM bdicred:"informix".sd_promocion_credito WHERE num_sol_prestamo = pSolicitud;
	
	--IF EXISTS (SELECT num_sol_prestamo  FROM bdicred:"informix".sd_promocion_credito WHERE num_sol_prestamo = pSolicitud) THEN
	IF sCountExist > 0 THEN
		-- SE DETERMINAN LAS DIFERENTES TASAS DE INTERES		
		
		-- Valida si son credisoluciones por medio de SMS
		SELECT num_promo INTO sNumPromocion FROM bdicred:"informix".sd_promocion_credito WHERE num_sol_prestamo = pSolicitud;
		IF sNumPromocion in (2, 5, 8) THEN
		
			SELECT COUNT(a.tasa) INTO sCountExistSms FROM sd_promocion_credito_sms a INNER JOIN sd_promocion_credito b ON (a.num_credito = b.num_credito and a.folio_compra_sms = b.folio_movto)
			 WHERE b.num_sol_prestamo = pSolicitud and a.mnto_compra = pMonto;
			IF sCountExistSms > 0 THEN
				SELECT first 1 a.tasa INTO v_tasainteres FROM sd_promocion_credito_sms a INNER JOIN sd_promocion_credito b ON (a.num_credito = b.num_credito and a.folio_compra_sms = b.folio_movto)
				WHERE b.num_sol_prestamo = pSolicitud and a.mnto_compra = pMonto;
				LET bandesp = 1;
			END IF;
		ELIF sNumPromocion in (3, 6, 9) THEN
		
			SELECT COUNT(a.tasa) INTO sCountExistSms FROM bdicred:sd_promocion_credito_sms a JOIN bdicred:sd_promocion_credito b ON (a.num_credito = b.num_credito and a.num_promo = b.num_promo and mnto_compra = monto_actual and a.plazo = b.plazo )
			 WHERE num_sol_prestamo = pSolicitud;
			IF sCountExistSms > 0 THEN
				SELECT first 1 a.tasa INTO v_tasainteres
				  FROM bdicred:sd_promocion_credito_sms a JOIN bdicred:sd_promocion_credito b ON (a.num_credito = b.num_credito and a.num_promo = b.num_promo and mnto_compra = monto_actual and a.plazo = b.plazo )
				  WHERE num_sol_prestamo = pSolicitud;
				  LET bandesp = 1;
			END IF;
		END IF;	
		--IF NVL(v_tasainteres, 0) != 0 THEN
		--	LET bandesp = 1;		
		--END IF;
		
		-- Valida si son credisoluciones por carga de archivo 
		SELECT COUNT(a.tasa) INTO sContPaso FROM sd_credpaso a INNER JOIN sd_promocion_credito b ON a.num_credito = b.num_credito WHERE b.num_sol_prestamo = pSolicitud and a.monto_actual = pMonto;
        --IF EXISTS(SELECT a.tasa FROM sd_credpaso a INNER JOIN sd_promocion_credito b  ON a.num_credito=b.num_credito WHERE b.num_sol_prestamo = pSolicitud and a.monto_actual = pMonto) THEN
		IF sContPaso > 0 THEN
            SELECT first 1 a.tasa INTO v_tasainteres FROM sd_credpaso a INNER JOIN sd_promocion_credito b  ON a.num_credito=b.num_credito WHERE b.num_sol_prestamo=pSolicitud and a.monto_actual=pMonto; 
            LET bandesp=1;
        END IF;
		
		
		
		--Correccion
		IF (snumpromocion IN (iDisposicionEfectivoApp, iComprasApp) AND pCanal == iCanalApp) THEN		
		
			SELECT c.tasa, a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.periodo_plazo,b.num_credito,b.num_promo 
			INTO mTasaInteres, cFactor, mSobreTasa, sDiaCorte, cPeriodoPag, pNumCredito, pPromo
			FROM bdicred:"informix".sd_definicion a
			   INNER JOIN bdicred:"informix".sd_promocion_credito b ON b.empresa = a.empresa AND b.num_pro_prestamo = a.num_producto
			   INNER JOIN bdicred:"informix".sd_maecred mae ON b.num_credito = mae.num_credito
			   INNER JOIN bdicred:"informix".sd_tasa_plazo_app c ON (c.plazo = b.plazo AND b.num_promo = c.num_promo AND c.plazo_activo = 1  AND c.num_producto = mae.num_producto)
			WHERE b.empresa = pEmpresa AND b.num_sol_prestamo = pSolicitud;

			-- BUSCAMOS EN LA sd_prospectos SI LA TASA ES MAYOR A 0
				  SELECT NVL(tasa, 0.00) INTO tasaPref
				  FROM "informix".sd_prospectos
				  WHERE empresa = pEmpresa
				  AND num_credito = pNumCredito
				  AND num_producto = '6900'
				  AND num_promo = pPromo;
				  
			if tasaPref > 0 THEN 
				LET mTasaInteres = tasaPref;
			END IF;
		
		ELSE
				
			--INTERES ORDINARIO --se liga con la tabla sd_promocion_credito
			SELECT c.tasa, a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.periodo_plazo
			INTO mTasaInteres, cFactor, mSobreTasa, sDiaCorte, cPeriodoPag
			FROM bdicred:"informix".sd_definicion a
				INNER JOIN bdicred:"informix".sd_promocion_credito b ON b.empresa = a.empresa AND b.num_pro_prestamo = a.num_producto
				INNER JOIN bdicred:"informix".sd_tasa_plazo c ON (c.plazo = b.plazo AND b.num_promo =c.num_promo AND c.plazo_activo = 1 )
			WHERE b.empresa = pEmpresa AND b.num_sol_prestamo = pSolicitud;

		END IF;



        IF (bandesp=1 AND pCanal <> iCanalApp) THEN 
            LET mTasaInteresProd = v_tasainteres;
            LET mTasaInteres = v_tasainteres;

			IF NVL(cPeriodoPag,'') = '' THEN		-- Si el plazo no existe, es sms y ya cambiaron los plazos.
				SELECT a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.periodo_plazo
				INTO   cFactor           , mSobreTasa , sDiaCorte  , cPeriodoPag
				FROM bdicred:"informix".sd_definicion a
					INNER JOIN bdicred:"informix".sd_promocion_credito b ON b.empresa = a.empresa AND b.num_pro_prestamo = a.num_producto
				WHERE b.empresa = pEmpresa AND b.num_sol_prestamo = pSolicitud;			
			END IF;
        ELSE
			LET mTasaInteresProd = mTasaInteres;
        END IF;

		IF cFactor = "+" THEN
			LET mTasaInteres = mTasaInteres + mSobreTasa;
		ELIF cFactor = "-" THEN
			LET mTasaInteres = mTasaInteres - mSobreTasa;
		ELIF cFactor = "*" THEN
			LET mTasaInteres = mTasaInteres * mSobreTasa;
		ELSE
			LET mTasaInteres = mTasaInteres / mSobreTasa;
		END IF

		--INTERES MORATORIO
		SELECT c.valor, a.fact_sobret_mora, a.sobretasa_mora
		INTO mTasaMora, cFactor, mSobreTasa
		FROM bdicred:"informix".sd_definicion a
			INNER JOIN bdicred:"informix".sd_promocion_credito b ON b.empresa = a.empresa AND b.num_pro_prestamo = a.num_producto
			INNER JOIN bdinteg:"informix".si_fechavalor c ON c.empresa = a.empresa AND c.tasa = a.cod_tasa_mora
		WHERE b.empresa = pEmpresa AND b.num_sol_prestamo = pSolicitud
		AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r WHERE r.empresa = pEmpresa AND r.tasa = a.cod_tasa_mora);

		LET mTasaMoraProd = mTasaMora;

		IF cFactor = "+" THEN
				LET mTasaMora = mTasaMora + mSobreTasa;
		ELIF cFactor = "-" THEN
				LET mTasaMora = mTasaMora - mSobreTasa;
		ELIF cFactor = "*" THEN
				LET mTasaMora = mTasaMora * mSobreTasa;
		ELSE
				LET mTasaMora = mTasaMora / mSobreTasa;
		END IF

		--INTERES A FAVOR DEL CLIENTE
		SELECT c.valor, a.factor_sobretasa, a.sobretasa
		INTO mTasaFavor, cFactorFAV, mSobreTasaFAV
		FROM bdicred:"informix".sd_anexodefinicion a
			INNER JOIN bdicred:"informix".sd_promocion_credito b ON b.empresa = a.empresa AND b.num_pro_prestamo = a.num_producto
			INNER JOIN bdinteg:"informix".si_fechavalor c ON c.empresa = a.empresa AND c.tasa = a.cod_tasa_base
		WHERE b.empresa = pEmpresa AND b.num_sol_prestamo = pSolicitud
		AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r WHERE r.empresa = pEmpresa AND r.tasa = a.cod_tasa_base);


		IF cFactorFAV = "+" THEN
				LET mTasaFavor = mTasaFavor + mSobreTasaFAV;
		ELIF cFactorFAV = "-" THEN
				LET mTasaFavor = mTasaFavor - mSobreTasaFAV;
		ELIF cFactorFAV = "*" THEN
				LET mTasaFavor = mTasaFavor * mSobreTasaFAV;
		ELSE
				LET mTasaFavor = mTasaFavor / mSobreTasaFAV;
		END IF

		-- SE OBTIENE LA CLAVE DEL PRODUCTO, EL CODIGO DE DIVISA, EL MONTO DEL PRESTAMO SOLICITADO Y LA SUCURSAL
		SELECT a.num_producto, a.divisa, b.sucursal
		INTO cProducto, cDivisa, cSucursal
		FROM bdicred:"informix".sd_promocion_credito b
		  INNER JOIN bdicred:"informix".sd_definicion a ON a.empresa = b.empresa AND a.num_producto = b.num_pro_prestamo
		WHERE b.empresa = pEmpresa AND b.num_sol_prestamo = pSolicitud;

		SELECT a.iva
			INTO dIvaSuc
		FROM bdinteg:"informix".si_sucursales a
		WHERE a.sucursal = cSucursal
		AND a.empresa  = pEmpresa;

		  --***** SE INSERTA INFORMACION EN SD_MAECREDCRD
		INSERT INTO bdicred:"informix".sd_maecredcrd
			   (empresa,                        num_credito,
				num_producto,                   ejecutivo,
				numcte,                         aval_cte,
				aval_linea,                     divisa,
				sucursal,                       id_origen,
				origen,                         cod_tipo_linea,
				cod_linea,                      status_cred,
				bandera_renovac,                bandera_prorroga,
				periodo_plazo,                  plazo,
				fecha_apertura,                 fecha_vencim,
				period_pago_cap,                period_pag_int,
				dias_trasp_cap,                 dias_trasp_int,
				tasa_fija_o_var,                cod_tasa_base,
				factor_sobretasa,               sobretasa,
				tasa_interes,                   cod_tasa_mora,
				sobretasa_mora,                 fact_sobret_mora,
				tasa_moratorios,                tasa_preferencial,
				sobretasa_preferencial,         factor_preferencial,
				valor_preferencial,             fecha_pago_cap,
				fecha_pago_int,                 es_fisica,
				bandera_fi_fo,                  actividad,
				tipo_calculo,                   num_aper_ant,
				rev_tasa_var_per,               dia_para_revisar,
				cod_prod,                       bandera_ministra,
				credito_externo,                califica_riesgo,
				cod_agricola,                   pagos_sostenidos,
				campo_trab1,                    campo_trab2,
				campo_trab3,                    campo_trab4
			   )
		SELECT  sol.empresa                		,pSolicitud
			   ,sol.num_pro_prestamo            ,pEjecutivo
			   ,sol.num_cte                      ,''
			   ,''                              ,NVL(def.divisa,1)
			   ,NVL(sol.sucursal,'')            ,''
			   ,''                              ,''
			   --IFRS,''                              ,'AA'
			   ,''								,cStatus_cred
			   ,'S'                             ,'N'
			   ,NVL(def.periodo_plazo,'')       ,pPlazo
			   ,dFechaApert  					,dFechaVenc
			   ,NVL(def.period_pago_cap,'')     ,NVL(def.period_pag_int,'')
			   ,NVL(def.dias_traspaso_cap,0)    ,NVL(def.dias_traspaso_int,0)
			   ,NVL(def.tasa_fija_o_var,'')     ,NVL(def.cod_tasa_base,'')
			   ,NVL(def.factor_sobretasa,'')    ,NVL(def.sobretasa,'')
			   ,mTasaInteresProd                ,NVL(def.cod_tasa_mora,'')
			   ,NVL(def.sobretasa_mora,0)       ,NVL(def.fact_sobret_mora,'')
			   ,NVL(mTasaMoraProd,0)            ,''
			   ,0                               ,''
			   ,0                               ,dFechaT
			   ,dFechaT							,NVL(tip.es_fisica,'')
			   ,''                              ,''
			   ,NVL(def.tipo_calculo,'')        ,dIvaSuc
			   ,''                              ,NVL(def.dia_para_revisar,0)
			   ,''                              ,cPeriodoPag
			   ,''                              ,''
			   ,''                              ,0
			   ,0                               ,0
			   ,''                              ,''
		FROM bdicred:"informix".sd_promocion_credito sol
		INNER JOIN bdicred:"informix".sd_definicion def ON def.empresa = sol.empresa AND def.num_producto = sol.num_pro_prestamo
		INNER JOIN bdinteg:"informix".si_cliente cli ON cli.empresa = sol.empresa AND cli.numcte = sol.num_cte
		INNER JOIN bdinteg:"informix".si_tipper tip ON tip.tpo_persona = cli.tpo_persona
		WHERE  sol.num_sol_prestamo = pSolicitud AND sol.empresa = pEmpresa;


		LET iNumReg = dbinfo("sqlca.sqlerrd2");

		IF iNumReg = 0 THEN
			LET cCodRet = "000003";
			DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF;

		 --***** SE INSERTA INFORMACION EN SD_MAECREDANEXOCRD (DATOS PARA TARJETA DE CREDITO)
		BEGIN
			ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
				 LET cCodRet    = iSqlErr;

				 LET cErrorInfo  = cErrorInfo;
				 RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END EXCEPTION;


			INSERT INTO bdicred:"informix".sd_maecredanexocrd
				(empresa, 				 		num_credito,
				 localidad,              		dia_corte,
				 dias_gracia_mora, 		 		tp_dias_calc_mora,
				 dias_fecha_max_pago,	 		tp_dias_fecha_pago,
				 cod_tasa_base_cte, 	 		factor_sobretasa_cte,
				 sobretasa_cte, 		 		tasa_interes_cte,
				 fecha_vencto, 			 		prox_fecha_pago,
				 fecha_proceso,			 		fecha_ult_pago,
				 nombre_pres)
			SELECT pEmpresa              		,pSolicitud,
				   ""                    		,DAY(dFechaApert),
				   NVL(def.gracia_calc_mora,0)  ,'',
				   DAY(dFechaApert)      		,NVL(def.maneja_linea,''),
				   NVL(def.cod_tasa_base,'')	,NVL(def.factor_sobretasa,''),
				   NVL(def.sobretasa,0)    		,mTasaInteresProd,
				   ""                    		,dFechaT,
				   dFechaApert           		,"",
				   pNombrePres
			FROM bdicred:"informix".sd_definicion def
				INNER JOIN bdicred:"informix".sd_promocion_credito c ON c.empresa = def.empresa AND c.num_pro_prestamo = def.num_producto
			WHERE c.empresa = pEmpresa AND c.num_sol_prestamo = pSolicitud;
		END;
		  --***** SE INSERTA INFORMACION EN SD_MAESDOSCRD

		LET iNumReg = dbinfo("sqlca.sqlerrd2");

		IF iNumReg = 0 THEN
			LET cCodRet = "000003";

			DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF;


		BEGIN
			ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
				 LET cCodRet    = iSqlErr;
				 LET cErrorInfo  = cErrorInfo;
				 RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END EXCEPTION;

			INSERT INTO bdicred:"informix".sd_maesdoscrd
					(
						empresa, 			num_credito,		fecha_ult_mov, 		sdo_int_anticip,
						sdo_int_ant_dev, 	sdo_intereses,		sdo_dia_ant_int, 	sdo_mes_ant_int,
						sdo_acum_mes_int, 	sdo_retenido,		sdo_acum_cap_int, 	sdo_exig_int,
						sdo_no_exig, 		provision_normal,	dias_acum_int, 		sdo_moratorio,
						sdo_dia_ant_mor, 	sdo_mes_ant_mor,	sdo_contab_mora, 	dias_acum_mora,
						sdo_capital, 		sdo_cap_insoluto,	sdo_dia_ant_cap, 	sdo_mes_ant_cap,
						sdo_acum_mes_cap, 	mto_capitalizado,	mto_ministra_cap, 	cargos_dia_cap,
						abonos_dia_cap, 	cargos_mes_cap,		abonos_mes_cap, 	dias_acum_cap,
						monto_vencido, 		mto_venc_trasp,		monto_financiado, 	monto_reservado,
						sdo_acum_vencido, 	dias_acum_intper,	sdo_global_int, 	sdo_acum_intper,
						monto_otorgado, 	provi_venc_normal,	provi_venc_anticip, cap_tras_no_venci,
						mto_venc_int, 		mto_venc_tra_int,	mto_finan_vdo, 		mto_reser_int,
						mto_fin_ven_trasp, 	mto_fin_vig_trasp,	int_tra_no_exig, 	sdo_trab4,
						atr
					)
			VALUES
					(
						pEmpresa                ,pSolicitud, 	dFechaApert            ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,pMonto                 ,pMonto			,0                      ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,pMonto					,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,iAtr_Act_ifrs
					);
		END;

		LET iNumReg = dbinfo("sqlca.sqlerrd2");
		IF iNumReg = 0 THEN
			LET cCodRet = "000003";

			DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF;

		-- SE GENERA EL FOLIO
		CALL bdicheq:"informix".sp_generafolionomina(pEjecutivo) RETURNING cCodRet, cNumeroFolio;

		-- SE ASIGNA EL FOLIO DE LA TRANSACCION
		LET cTransacc = "0247";

		EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa         , pSolicitud,	cProducto        , 3,
									"001"            , dFechaApert,
									pMonto           , cNumeroFolio,
									cSucursal        , cDivisa,
									"0000",'APERTURA','')
		INTO cCodRet, cErrorInfo;

		IF cCodRet <> "000000" THEN
			DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF

		EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa         , pSolicitud,
									cProducto        , 66,
									"002"            , dFechaApert,
									pMonto           , cNumeroFolio,
									cSucursal        , cDivisa,
									"0000",'DISPOSICION','')
		INTO cCodRet, cErrorInfo;

		IF cCodRet <> "000000" THEN
			DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF


		-- SE INSERTA INSERTA INFORMACION EN LA TABLA DE AMORTIZACIONES
		INSERT INTO bdicred:"informix".sd_amortiza_creditocrd
			(
				empresa, 			num_credito,
				fecha_cuota, 		tipo_cuota,
				capital_mto_cuota, 	capital_debe,
				capital_pagado, 	capital_status,
				capital_status_ant, capital_fecha_pago,
				interes_debe, 		interes_pagado,
				interes_status, 	interes_status_ant,
				interes_fecha_pago, iva_debe,
				iva_pagado, 		iva_status,
				iva_status_ant, 	iva_fecha_pago,
				mora_provi_ordi, 	mora_provi_cope,
				mora_sdo_ordi, 		mora_sdo_ordi_pag,
				mora_sdo_cope, 		mora_sdo_cope_pag,
				mora_bonificado, 	mora_status,
				mora_iva_debe, 		mora_iva_pagado,
				mora_iva_status, 	mora_iva_fecha_pago,
				num_pago, 			campo_trabajo1,
				campo_trabajo2, 	campo_trabajo3,
				campo_trabajo4
			)
		VALUES
			(
				pEmpresa,			pSolicitud,
				dFechaT,			"3",
				pMensualidad,		0,
				0,					"3",
				"3",				"",
				0,					0,
				"1",				"1",
				"",					0,
				0,					"1",
				"1",				"",
				0,					0,
				0,					0,
				0,					0,
				0,					"1",
				0,					0,
				"1",				"",
				1,					0,
				0,					"",
				""
			);

	ELSE---proceso productivo de apertura de prestamos...	o se sigue el flujo normal....

		    -- SE DETERMINAN LAS DIFERENTES TASAS DE INTERES

			--INTERES ORDINARIO
			SELECT c.valor, a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.periodo_plazo
			INTO mTasaInteres, cFactor, mSobreTasa, sDiaCorte, cPeriodoPag
			FROM bdicred:"informix".sd_definicion a
				INNER JOIN bdisolic:"informix".ss_solicitudes b ON b.empresa = a.empresa AND b.num_producto = a.num_producto
				INNER JOIN bdinteg:"informix".si_fechavalor c ON c.empresa = a.empresa AND c.tasa = a.cod_tasa_base
			WHERE b.empresa = pEmpresa AND b.num_solicitud = pSolicitud
				AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r WHERE r.empresa = pEmpresa AND r.tasa = a.cod_tasa_base);

			LET mTasaInteresProd = mTasaInteres;

			IF cFactor = "+" THEN
				LET mTasaInteres = mTasaInteres + mSobreTasa;
			ELIF cFactor = "-" THEN
				LET mTasaInteres = mTasaInteres - mSobreTasa;
			ELIF cFactor = "*" THEN
				LET mTasaInteres = mTasaInteres * mSobreTasa;
			ELSE
				LET mTasaInteres = mTasaInteres / mSobreTasa;
			END IF

			--INTERES MORATORIO
			SELECT c.valor, a.fact_sobret_mora, a.sobretasa_mora
			INTO mTasaMora, cFactor, mSobreTasa
			FROM bdicred:"informix".sd_definicion a
			    INNER JOIN bdisolic:"informix".ss_solicitudes b ON b.empresa = a.empresa AND b.num_producto = a.num_producto
				INNER JOIN bdinteg:"informix".si_fechavalor c ON c.empresa = a.empresa AND c.tasa = a.cod_tasa_mora
			WHERE b.empresa = pEmpresa AND num_solicitud = pSolicitud
			    AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r WHERE r.empresa = pEmpresa AND r.tasa = a.cod_tasa_mora);

			LET mTasaMoraProd = mTasaMora;

			IF cFactor = "+" THEN
					LET mTasaMora = mTasaMora + mSobreTasa;
			ELIF cFactor = "-" THEN
					LET mTasaMora = mTasaMora - mSobreTasa;
			ELIF cFactor = "*" THEN
					LET mTasaMora = mTasaMora * mSobreTasa;
			ELSE
					LET mTasaMora = mTasaMora / mSobreTasa;
			END IF

			--INTERES A FAVOR DEL CLIENTE
			SELECT c.valor, a.factor_sobretasa, a.sobretasa
			INTO mTasaFavor, cFactorFAV, mSobreTasaFAV
			FROM bdicred:"informix".sd_anexodefinicion a
				INNER JOIN bdisolic:"informix".ss_solicitudes b ON b.empresa = a.empresa AND b.num_producto = a.num_producto
				INNER JOIN bdinteg:"informix".si_fechavalor c ON c.empresa = a.empresa AND c.tasa = a.cod_tasa_base
			WHERE b.empresa = pEmpresa AND num_solicitud = pSolicitud
				AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r WHERE r.empresa = pEmpresa AND r.tasa = a.cod_tasa_base);

			IF cFactorFAV = "+" THEN
					LET mTasaFavor = mTasaFavor + mSobreTasaFAV;
			ELIF cFactorFAV = "-" THEN
					LET mTasaFavor = mTasaFavor - mSobreTasaFAV;
			ELIF cFactorFAV = "*" THEN
					LET mTasaFavor = mTasaFavor * mSobreTasaFAV;
			ELSE
					LET mTasaFavor = mTasaFavor / mSobreTasaFAV;
			END IF

			-- SE OBTIENE LA CLAVE DEL PRODUCTO, EL CODIGO DE DIVISA, EL MONTO DEL PRESTAMO SOLICITADO Y LA SUCURSAL
			SELECT a.num_producto, a.divisa, b.sucursal
			INTO cProducto, cDivisa, cSucursal
			FROM bdisolic:"informix".ss_solicitudes b
			  INNER JOIN bdicred:"informix".sd_definicion a ON a.empresa = b.empresa AND a.num_producto = b.num_producto
			WHERE b.empresa = pEmpresa AND b.num_solicitud = pSolicitud;

		       SELECT a.iva
		         INTO dIvaSuc
		         FROM bdinteg:"informix".si_sucursales a
		        WHERE a.sucursal = cSucursal
		          AND a.empresa  = pEmpresa;

		      --***** SE INSERTA INFORMACION EN SD_MAECREDCRD
			INSERT INTO bdicred:"informix".sd_maecredcrd
				   (empresa,                        num_credito,
					num_producto,                   ejecutivo,
					numcte,                         aval_cte,
					aval_linea,                     divisa,
					sucursal,                       id_origen,
					origen,                         cod_tipo_linea,
					cod_linea,                      status_cred,
					bandera_renovac,                bandera_prorroga,
					periodo_plazo,                  plazo,
					fecha_apertura,                 fecha_vencim,
					period_pago_cap,                period_pag_int,
					dias_trasp_cap,                 dias_trasp_int,
					tasa_fija_o_var,                cod_tasa_base,
					factor_sobretasa,               sobretasa,
					tasa_interes,                   cod_tasa_mora,
					sobretasa_mora,                 fact_sobret_mora,
					tasa_moratorios,                tasa_preferencial,
					sobretasa_preferencial,         factor_preferencial,
					valor_preferencial,             fecha_pago_cap,
					fecha_pago_int,                 es_fisica,
					bandera_fi_fo,                  actividad,
					tipo_calculo,                   num_aper_ant,
					rev_tasa_var_per,               dia_para_revisar,
					cod_prod,                       bandera_ministra,
					credito_externo,                califica_riesgo,
					cod_agricola,                   pagos_sostenidos,
					campo_trab1,                    campo_trab2,
					campo_trab3,                    campo_trab4
				   )
			SELECT  sol.empresa                		,pSolicitud
				   ,sol.num_producto                ,NVL(anx.ejecutivo_sol,'')
				   ,sol.numcte                      ,''
				   ,''                              ,NVL(def.divisa,1)
				   ,NVL(sol.sucursal,'')            ,''
				   ,''                              ,''
				   --IFRS,''                              ,'AA'
				   ,''                              ,cStatus_cred
				   ,'S'                             ,'N'
				   ,NVL(def.periodo_plazo,'')       ,pPlazo
				   ,dFechaApert  					,dFechaVenc
				   ,NVL(def.period_pago_cap,'')     ,NVL(def.period_pag_int,'')
				   ,NVL(def.dias_traspaso_cap,0)    ,NVL(def.dias_traspaso_int,0)
				   ,NVL(def.tasa_fija_o_var,'')     ,NVL(def.cod_tasa_base,'')
				   ,NVL(def.factor_sobretasa,'')    ,NVL(def.sobretasa,'')
				   ,mTasaInteresProd                ,NVL(def.cod_tasa_mora,'')
				   ,NVL(def.sobretasa_mora,0)       ,NVL(def.fact_sobret_mora,'')
				   ,NVL(mTasaMoraProd,0)            ,''
				   ,0                               ,''
				   ,0                               ,dFechaT
				   ,dFechaT							,NVL(tip.es_fisica,'')
				   ,''                              ,''
				   ,NVL(def.tipo_calculo,'')        ,dIvaSuc
				   ,''                              ,NVL(def.dia_para_revisar,0)
				   ,''                              ,cPeriodoPag
				   ,''                              ,''
				   ,''                              ,0
				   ,0                               ,0
				   ,''                              ,''
			FROM bdisolic:"informix".ss_solicitudes sol
				INNER JOIN bdicred:"informix".sd_definicion def ON def.empresa = sol.empresa AND def.num_producto = sol.num_producto
				INNER JOIN bdisolic:"informix".ss_anexosol anx ON anx.num_solicitud = sol.num_solicitud AND anx.empresa = sol.empresa
				INNER JOIN bdinteg:"informix".si_cliente cli ON cli.empresa = sol.empresa AND cli.numcte = sol.numcte
				INNER JOIN bdinteg:"informix".si_tipper tip ON tip.tpo_persona = cli.tpo_persona
				WHERE  sol.num_solicitud = pSolicitud AND sol.empresa = pEmpresa;

			LET iNumReg = dbinfo("sqlca.sqlerrd2");

			IF iNumReg = 0 THEN
				LET cCodRet = "000003";
				DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
			    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
                DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF;

		     --***** SE INSERTA INFORMACION EN SD_MAECREDANEXOCRD (DATOS PARA TARJETA DE CREDITO)
		    BEGIN
			    ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
			         LET cCodRet    = iSqlErr;

			         LET cErrorInfo  = cErrorInfo;
			         RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			    END EXCEPTION;


				INSERT INTO bdicred:"informix".sd_maecredanexocrd
					(empresa, 				 		num_credito,
					 localidad,              		dia_corte,
			         dias_gracia_mora, 		 		tp_dias_calc_mora,
			         dias_fecha_max_pago,	 		tp_dias_fecha_pago,
			         cod_tasa_base_cte, 	 		factor_sobretasa_cte,
			         sobretasa_cte, 		 		tasa_interes_cte,
			         fecha_vencto, 			 		prox_fecha_pago,
			         fecha_proceso,			 		fecha_ult_pago,
			         nombre_pres)
				SELECT pEmpresa              		,pSolicitud,
		               ""                    		,DAY(dFechaApert),
					   NVL(def.gracia_calc_mora,0)  ,'',
					   DAY(dFechaApert)      		,NVL(def.maneja_linea,''),
					   NVL(def.cod_tasa_base,'')	,NVL(def.factor_sobretasa,''),
					   NVL(def.sobretasa,0)    		,mTasaInteresProd,
					   ""                    		,dFechaT,
					   dFechaApert           		,"",
					   pNombrePres
				FROM bdicred:"informix".sd_definicion def
		            INNER JOIN bdisolic:"informix".ss_solicitudes c ON c.empresa = def.empresa AND c.num_producto = def.num_producto
		     --       INNER JOIN bdicred:"informix".sd_anexodefinicion b ON b.empresa = def.empresa AND b.num_producto = c.num_producto
			--			AND b.cod_prod = def.cod_tipcred
				WHERE c.empresa = pEmpresa AND c.num_solicitud = pSolicitud;
		    END;
		      --***** SE INSERTA INFORMACION EN SD_MAESDOSCRD

			LET iNumReg = dbinfo("sqlca.sqlerrd2");

			IF iNumReg = 0 THEN
				LET cCodRet = "000003";
				DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
			    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
                DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF;


		    BEGIN
			    ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
			         LET cCodRet    = iSqlErr;
			         LET cErrorInfo  = cErrorInfo;
			         RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			    END EXCEPTION;

		        INSERT INTO bdicred:"informix".sd_maesdoscrd
						(
							empresa, 			num_credito,
							fecha_ult_mov, 		sdo_int_anticip,
							sdo_int_ant_dev, 	sdo_intereses,
							sdo_dia_ant_int, 	sdo_mes_ant_int,
							sdo_acum_mes_int, 	sdo_retenido,
							sdo_acum_cap_int, 	sdo_exig_int,
							sdo_no_exig, 		provision_normal,
							dias_acum_int, 		sdo_moratorio,
							sdo_dia_ant_mor, 	sdo_mes_ant_mor,
							sdo_contab_mora, 	dias_acum_mora,
							sdo_capital, 		sdo_cap_insoluto,
							sdo_dia_ant_cap, 	sdo_mes_ant_cap,
							sdo_acum_mes_cap, 	mto_capitalizado,
							mto_ministra_cap, 	cargos_dia_cap,
							abonos_dia_cap, 	cargos_mes_cap,
							abonos_mes_cap, 	dias_acum_cap,
							monto_vencido, 		mto_venc_trasp,
							monto_financiado, 	monto_reservado,
							sdo_acum_vencido, 	dias_acum_intper,
							sdo_global_int, 	sdo_acum_intper,
							monto_otorgado, 	provi_venc_normal,
							provi_venc_anticip, cap_tras_no_venci,
							mto_venc_int, 		mto_venc_tra_int,
							mto_finan_vdo, 		mto_reser_int,
							mto_fin_ven_trasp, 	mto_fin_vig_trasp,
							int_tra_no_exig, 	sdo_trab4,
							atr
		                )
		        SELECT 		 sol.empresa             ,pSolicitud
							,dFechaApert            ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,pMonto                 ,pMonto
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,pMonto					,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,iAtr_Act_ifrs
				FROM   bdisolic:"informix".ss_solicitudes sol
				WHERE  sol.num_solicitud = pSolicitud AND sol.empresa = pEmpresa;
			END;

			IF iNumReg = 0 THEN
				LET cCodRet = "000003";
				DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
			    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
                DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF;

			-- SE GENERA EL FOLIO
			CALL bdicheq:"informix".sp_generafolionomina(pEjecutivo) RETURNING cCodRet, cNumeroFolio;

			-- SE ASIGNA EL FOLIO DE LA TRANSACCION
			LET cTransacc = "0247";

		    EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa         , pSolicitud,
										cProducto        , 3,
		                                "001"            , dFechaApert,
		                                pMonto           , cNumeroFolio,
		                                cSucursal        , cDivisa,
		                                "0000",'APERTURA','')
			INTO cCodRet, cErrorInfo;

			IF cCodRet <> "000000" THEN
				DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
			    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
                DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF

		    EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa         , pSolicitud,
										cProducto        , 66,
		                                "002"            , dFechaApert,
		                                pMonto           , cNumeroFolio,
		                                cSucursal        , cDivisa,
		                                "0000",'DISPOSICION','')
			INTO cCodRet, cErrorInfo;

			IF cCodRet <> "000000" THEN
				DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
			    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
                DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF


			-- SE INSERTA INSERTA INFORMACION EN LA TABLA DE AMORTIZACIONES
			INSERT INTO bdicred:"informix".sd_amortiza_creditocrd
				(
					empresa, 			num_credito,
					fecha_cuota, 		tipo_cuota,
					capital_mto_cuota, 	capital_debe,
					capital_pagado, 	capital_status,
					capital_status_ant, capital_fecha_pago,
					interes_debe, 		interes_pagado,
					interes_status, 	interes_status_ant,
					interes_fecha_pago, iva_debe,
					iva_pagado, 		iva_status,
					iva_status_ant, 	iva_fecha_pago,
					mora_provi_ordi, 	mora_provi_cope,
					mora_sdo_ordi, 		mora_sdo_ordi_pag,
					mora_sdo_cope, 		mora_sdo_cope_pag,
					mora_bonificado, 	mora_status,
					mora_iva_debe, 		mora_iva_pagado,
					mora_iva_status, 	mora_iva_fecha_pago,
					num_pago, 			campo_trabajo1,
					campo_trabajo2, 	campo_trabajo3,
					campo_trabajo4
				)
			VALUES
				(
					pEmpresa,			pSolicitud,
					dFechaT,			"3",
					pMensualidad,		0,
					0,					"3",
					"3",				"",
					0,					0,
					"1",				"1",
					"",					0,
					0,					"1",
					"1",				"",
					0,					0,
					0,					0,
					0,					0,
					0,					"1",
					0,					0,
					"1",				"",
					1,					0,
					0,					"",
					""
				);

			--SE INSERTA EN LA TABLA bdicred:"informix".sd_ctascarg
			INSERT INTO bdicred:"informix".sd_ctascarg (empresa, numero, con_cap_inte, naturaleza, num_credito, tipo_cta, num_cta, num_nomina)
			VALUES(pEmpresa,0,'','A',pSolicitud,'',pCuentaCap,'');

		    -- SE ACTUALIZA EL ESTATUS DE LA SOLICITUD
		    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AP"
		    WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;

            --FMV 23abr13: Inserta cascaron para indicadores de prestamo a plazo
            INSERT INTO bdicred:sd_indicador_cred_crd
                        (empresa, num_credito, fecha_alta)
                VALUES (pEmpresa, pSolicitud, dFechaApert);



		    SELECT nombre INTO cMensaje FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = pEjecutivo AND empresa = pEmpresa;

		    LET cMensaje = "Apertura de Credito Autorizada por: " || TRIM(cMensaje);

			-- SE INSERTA EN LA TABLA DE AUTORIZACIONES DE SOLICITUD
		    INSERT INTO bdisolic:"informix".ss_autorizacion
				(empresa, ejecutivo_auto, num_solicitud, status_solicitud, comentario, fecha_entrada, fecha_salida, user_insert, fecha_insert)
		     VALUES(pEmpresa, pEjecutivo, pSolicitud, "AP", cMensaje, dFechaApert, dFechaApert, USER, TODAY);

			-- SE GENERA EL ABONO
			CALL bdicheq:"informix".abono_ref (pEmpresa, cSucursal, pEjecutivo, cTransacc, cTransacc, cNumeroFolio, pCuentaCap, 0,
				pMonto, pMonto, 0, 0, 0, "01", pNombrePres, '0', pEjecutivo) RETURNING cCodRet;

			-- SI NO SE PUDO GENERAR EL ABONO SE REVERSAN TODOS LOS MOVIMIENTOS QUE SE HABIAN ECHO
			IF cCodRet <> "000" THEN
				DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
			    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
                DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		    ELSE
		        LET idAbono = "S";
			END IF;

			 -- SE ACTUALIZAN LOS DATOS DEL CLIENTE
			SELECT a.numcte, tipo_cliente, NVL(ingreso_mensual,0)
			INTO cNumCte, cTpCte, mIngreso
			FROM bdinteg:"informix".si_cliente a
				INNER JOIN bdisolic:"informix".ss_solicitudes b ON b.numcte = a.numcte
				INNER JOIN bdisolic:"informix".ss_resum_scor_fin c ON c.empresa = b.empresa AND c.num_solicitud = b.num_solicitud
			WHERE b.empresa = pEmpresa AND b.num_solicitud = pSolicitud;
			 -- Saca la Publicacion de si_ctepf Jose Luis Puebla
		    SELECT string1 INTO cMercadeo
		    FROM   bdinteg:"informix".si_ctepf
		    WHERE  numcte = cNumCte;

		    IF cTpCte = "1" THEN
				SELECT MAX(sec_ingreso) INTO sSecIngreso FROM bdinteg:"informix".si_ingresos WHERE empresa = pEmpresa AND numcte = cNumCte AND tipo_ingreso = 'T';

				UPDATE bdinteg:"informix".si_ingresos SET ingreso_mensual = mIngreso
				WHERE empresa = pEmpresa AND numcte = cNumCte AND tipo_ingreso = "T" AND sec_ingreso = sSecIngreso;
		    ELSE

				UPDATE bdinteg:"informix".si_cliente SET tipo_cliente = "1" WHERE numcte = cNumCte;

				SELECT NVL(MAX(sec_ingreso), 0) + 1 INTO sSecIngreso
				FROM bdinteg:"informix".si_ingresos
				WHERE empresa = pEmpresa AND numcte = cNumCte AND tipo_ingreso = "T";

				INSERT INTO bdinteg:"informix".si_ingresos (empresa, numcte, sec_ingreso, tipo_ingreso, ingreso_mensual)
				VALUES (pEmpresa, cNumCte, sSecIngreso, "T", mIngreso);
		    END IF

	END IF;

    -- Resta el Valor de la Tasa Moratoria con la de Intereses
    -- Solicitado por el Banco JLP 23May2008
    LET mTasaMora = mTasaMora - mTasaInteres;
    IF mTasaMora < 0 THEN --Si es Menor a Cero la vuelve Positivo
       LET mTasaMora = mTasaMora * -1;
    END IF
    RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
END;
END PROCEDURE;