CREATE PROCEDURE "informix".sp_concreing_conciliaintercard_pba(
	psCve_usuario char (10), 		--USUARIO DEL SISTEMA
	psArchivo_origen CHAR (3), 		--TD_ARCHIVO_ORIGEN
	psConciliacionArchivo CHAR (1),	--TD_ARCHIVO_ORIGEN
	psConciliacion CHAR(1),   		-- bditarjeta:td_movimientos_conciliacion
	psConsecutivo INTEGER, 			--TD_MOVIMIENTOS_CONCILIACION	CONSECUTIVO
	psNumtarjeta CHAR (16), 		--TD_MOVIMIENTOS_CONCILIACION   NUMTARJETA
	psSecuencia325 CHAR(6),  		--TD_MOVIMIENTOS_CONCILIACION	
	psMonto325 CHAR(13),			--TD_MOVIMIENTOS_CONCILIACION    Monto de Operacion 
	psMontoCashBack325 CHAR(13),    --TD_MOVIMIENTOS_CONCILIACION    Monto de Cash Back
	psTipotransaccion325 CHAR(15),
	psIntegridad CHAR(1),         	--PARAMETRO INICIAL
	piTipo_LayOut INTEGER,			--BdiTarjeta:Td_Archivo_OrigenTmp ---
	psISO323 CHAR(2),				--BdiTarjeta:Td_Movimientos_Conciliacion
	psMovRev325 CHAR(1)	,	     	--BdiTarjeta:Td_Movimientos_Conciliacion
	psb_aplica char(1)	,			--TForzadas de BdiTarjeta:Td_Movimientos_Conciliacion
	ps_secuencia_ext_archivo char(15),--secuencia de BdiTarjeta:Td_Movimientos_Conciliacion
	ps_ArchivoOriIST char(3)			--archivo_origen de BdiTarjeta:Td_Movimientos_Conciliacion
)

	RETURNING   CHAR(5) AS Retorno,
				CHAR(1) AS Conciliacion ,
				CHAR(7) AS Secuencia,
				CHAR(15) AS Secuencia_extendida,
				CHAR(4) AS CodGiroNeg, --TFORZADAS
				MONEY AS Montointercard,
				MONEY AS Montointercardcashback,
				DATETIME YEAR TO FRACTION(5) AS FechaTransaccion,
				CHAR(40) AS Infreceptor,
				CHAR(16) AS Idterminal,
				CHAR(2) AS Metodocaptura,
				CHAR(1) AS Movconciliado,
				CHAR(1) AS Movreversado,
				CHAR(1) AS Tipo_mov,
				CHAR(1) AS b_aplica, --TFORZADAS
				CHAR(16) AS Folio_mov,
				DATETIME YEAR TO FRACTION(5) AS Fechaconcilia,
				INTEGER AS Tipo_conciliacion,
				CHAR(60) AS Desc_conciliacion,
				CHAR(250) AS ErrorActividad,
				INTEGER AS Elemento,
				INTEGER AS Actualizacion;

/*
*****************************************************************************************************
-- DESCRIPCION:  CONCILIACION INTERCARD  ------------------------------------------------------------
-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
-- FECHA : 20/06/2011  ------------------------------------------------------------------------------
-- BD: bditarjeta  ----------------------------------------------------------------------------------
-- SISTEMA : Reingenieria de la conciliacion automatica / Validacion de Integridad  -----------------
*****************************************************************************************************
*//*DEFINICION DE VARIABLES*/
/*VARIABLES DE RETORNO*/
DEFINE viCodigo INTEGER;
DEFINE vssqlerr CHAR(5) ;
define vsretvm char(5);

DEFINE vsErrorActividad CHAR (250) ;
DEFINE viElemento INTEGER;
DEFINE viActualizacion INTEGER;

/*VARIABLES QUE CONTIENEN AL MOVIMIENTO DE INTERCARD*/
DEFINE vsRetorno CHAR(5);
DEFINE viRetorno INTEGER;
DEFINE vsSecuenciaorig CHAR(7);
DEFINE vsSecuencia_extendida CHAR(15);
DEFINE vmMontointercard MONEY;
DEFINE vmMontointercardCashback MONEY; --Integracion de CashBack
DEFINE vdFechatransaccion DATETIME YEAR TO FRACTION(5);
DEFINE vsInfreceptor CHAR(40);
DEFINE vsIdterminal CHAR(16);
DEFINE vsMetodocaptura CHAR(2);
DEFINE vsMovconciliado CHAR(1);
DEFINE vsMovreversado CHAR(1);
DEFINE vsCodigoiso CHAR(2);

DEFINE vmSumaMonto325 MONEY;
DEFINE vmMonto325 MONEY;
-- Varibles para manejo de Cashback fraccionado
DEFINE vmSumaMontoCashback325 MONEY;
DEFINE VMMontoCashback325 MONEY; 

DEFINE vsConciliacion CHAR(1);
DEFINE vsSecuencia CHAR(7);

DEFINE vsTipo_mov CHAR(1);
DEFINE vsFolio_mov CHAR(16);
DEFINE vdFechaconcilia DATETIME YEAR TO FRACTION(5);
DEFINE viTipo_conciliacion INTEGER;
DEFINE vsDesc_conciliacion CHAR(60);

/*VARIABLES DE RETORNO DE sp_cidentifica_tipoconciliacion*/
DEFINE vsRetornor CHAR(5);
DEFINE vsConciliacionr CHAR(1);
DEFINE vsSecuencia_extendidar CHAR(16);
DEFINE vsMonto325 CHAR(13);
DEFINE vsMontoCashBack325 CHAR(13); --- Monto CashBack
DEFINE vmMontointercardr MONEY;
DEFINE vmMontointercardCashbackr MONEY; -- Integracion de CashBack
DEFINE vdFechatransaccionr DATETIME YEAR TO FRACTION(5);
DEFINE vsInfreceptorr CHAR(40);
DEFINE vsIdterminalr CHAR(16);
DEFINE vsMetodocapturar CHAR(2);
DEFINE vsMovconciliador CHAR(1);
DEFINE vsMovreversador CHAR(1);
DEFINE vsFormato VARCHAR(4);

DEFINE vsNumCuenta CHAR(20);

DEFINE vsCodReversa CHAR(1); 	--Intercard:Movimiento
DEFINE vsCodigoCentral CHAR(5);	--Intercard:Movimiento

/* Proceso de actualizacion de montos en Bditarjeta:td_movimientos_conciliación*/
DEFINE vmregistromontototal 	money;
DEFINE vmmontocompra 			money;
DEFINE vmmontocashback 			money;
DEFINE vsRegistroComprareal		char(13);
DEFINE vsRegistroCashreal		char(13);
DEFINE viconcaracteres1			integer;
DEFINE viconcaracteres2			integer;
DEFINE a						integer;
DEFINE b						integer;

--  Para la bandera de aplicacion TFORZADAS
DEFINE vsb_aplica 			char(1); -- TFORZADAS
DEFINE vscodgironeg 		char(4); -- TFORZADAS
DEFINE vfporcentaje			float;
DEFINE vsvalor      		char(10);
DEFINE vmmontototal 		money;
DEFINE vmmontoporcentaje 	money;
DEFINE vmmontototalmaximo 	money;

--SET DEBUG FILE TO '/informix/LVRQ/DEBUG/TraceCONCILIAINTERCARD.txt';
--TRACE ON;
/*INICIALIZACION DE VARIABLES*/

LET viCodigo = 0;
LET vssqlerr = '00000';
let vsretvm = '';

LET vsErrorActividad = '';
LET viElemento = 4;
LET viActualizacion = 0;

LET vsConciliacion = psConciliacion;

/*VARIABLES QUE CONTIENEN AL MOVIMIENTO DE INTERCARD*/
LET vsRetorno = '00000';
LET viRetorno = 0;
LET vsSecuenciaorig = '';
LET vsSecuencia_extendida = '';

LET vmMontointercard = 0;
LET vmMontointercardCashback = 0;
LET vdFechatransaccion = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
LET vsInfreceptor = '';
LET vsIdterminal = '';
LET vsMetodocaptura = '';
LET vsMovconciliado = '';
LET vsMovreversado = '';
LET vsCodigoiso = '';

 
LET vmSumaMonto325 = 0;
LET vmSumaMontoCashback325 = 0; -- Para suma de CashBack


LET vsSecuencia = '';
LET vsTipo_mov = '';
LET vsFolio_mov = '';
LET vdFechaconcilia = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
LET viTipo_conciliacion = 0;
LET vsDesc_conciliacion = '';

/*VARIABLES DE RETORNO DE sp_cidentifica_tipoconciliacion*/
LET vsRetornor = '00000';
LET vsConciliacionr = psConciliacion;
LET vsSecuencia_extendidar = '';
LET vmMontointercardr = 0;
LET vmMontointercardCashbackr = 0;
LET vdFechatransaccionr = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
LET vsInfreceptorr = '';
LET vsIdterminalr = '';
LET vsMetodocapturar = '';
LET vsMovconciliador = '';
LET vsMovreversador = '';
LET vsFormato = '';

LET vsNumCuenta  = '';

LET vsCodReversa = '';
LET vsCodigoCentral = '';

-- Proceso de Forzadas
LET vsb_aplica 			= '';
LET vscodgironeg 		= '';
LET vfporcentaje		= 0.0;
LET vsvalor      		= '';
LET vmmontototal 		= 0;
LET vmmontoporcentaje 	= 0;
LET vmmontototalmaximo 	= 0;


/* Proceso de actualizacion de montos en Bditarjeta:td_movimientos_conciliación*/
LET vmregistromontototal = 0;
LET vmmontocompra  = 0;
LET vmmontocashback = 0;
LET vsRegistroComprareal = '';
LET vsRegistroCashreal = '';
LET viconcaracteres1 = 0;
LET viconcaracteres2 = 0;
LET a = 0;
LET b = 0;

--LET vmMonto325 = 0;
LET vmMonto325 = ( ( REPLACE( psMonto325,'.',''))::MONEY /100 );
LET vsMonto325 = CAST(vmMonto325 AS CHAR(13));
LET vmSumaMonto325 = 0;

LET vmMontoCashback325 = ((REPLACE( psMontoCashBack325,'.',''))::MONEY /100 ); 
LET vsMontoCashback325 = CAST(vmMontoCashback325 AS CHAR(13));
LET vmSumaMontoCashback325 = 0; -- Para suma de CashBack


BEGIN

ON EXCEPTION SET viCodigo   --cacha el error en caso de que exista y regresa un valor predeterminado

LET vssqlerr = viCodigo;
RETURN	vssqlerr,
	NVL(vsConciliacion,''),
	NVL(vsSecuencia,''),
	NVL(vsSecuencia_extendida,''),
	NVL(vsCodgironeg,''), -- TFORZADAS
	NVL(vmMontointercard,0),
	NVL(vmMontointercardCashback,0),
	NVL(vdFechaTransaccion,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
	NVL(vsInfreceptor,''),
	NVL(vsIdterminal,''),
	NVL(vsMetodocaptura,''),
	NVL(vsMovconciliado,''),
	NVL(vsMovreversado,''),
	NVL(vsTipo_mov,''),
	NVL(vsb_aplica,''), --TFORZADAS
	NVL(vsFolio_mov,''),
	NVL(vdFechaconcilia,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
	NVL(viTipo_conciliacion,0),
	NVL(vsDesc_conciliacion,''),
	NVL(vsErrorActividad,''),
	NVL(viElemento,4),
	NVL(viActualizacion,0);
	

END EXCEPTION;




	/*SE VERIFICA LA INTEGRIDAD DEL REGISTRO*/
	
	let vsb_aplica = psb_aplica;
	IF ( psIntegridad = 'V') THEN
		/*CONTINUA FASE 2*/

		/*LECTURA DEL MOVIMIENTO ORIGINAL EN INTERCARD*/
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_buscarmovimientointercard  -- Se Modidica retorno para baplica 
		( psCve_usuario, psNumtarjeta , psSecuencia325, psMonto325, psMontoCashBack325,ps_secuencia_ext_archivo,ps_ArchivoOriIST) -- Se agrega psmonto325 para validar montos
		INTO vsRetorno, vsSecuenciaorig, vsSecuencia_extendida, vmMontointercard, vmMontointercardCashback, vdFechatransaccion,
			vsInfreceptor, vsIdterminal, vsMetodocaptura, vsMovconciliado, vsMovreversado, vsCodigoiso, vsFormato, vsErrorActividad,
			vsCodReversa, vsCodigoCentral, vscodgironeg; --TFORZADAS
		
		--LET vsErrorActividad = 'CONSULTA MOVIMIENTO INTERCARD' ;


		LET viRetorno = CAST( vsRetorno AS INTEGER);

		IF( viRetorno >= 0  ) THEN
			-- ###############################################################################################################
			-- Para actualizar el monto en caso de que el registro tenga Cash Back y no sea entregada asi por el adquirente
			IF  ((vmMontointercardcashback >0) AND (psMontoCashBack325 = '0000000000000')) THEN
				LET vmregistromontototal = (( REPLACE( psMonto325,'.',''))::MONEY /100 );
				LET vmmontocompra = vmregistromontototal - vmMontointercardcashback;
				LET vmmontocashback = vmMontointercardcashback;
				
				-- Convierte a string el monto325 que debe mandar a identificarse
				LET vsRegistroComprareal = CAST(vmmontocompra as CHAR(13));
				LET vsRegistroComprareal = REPLACE(REPLACE(vsRegistroComprareal,'$',''),'.',''); 
				LET viconcaracteres1 = Length(vsRegistroComprareal);
				FOR  a = viconcaracteres1  TO 12 STEP 1
						LET vsRegistroComprareal = '0'||vsRegistroComprareal;
				END FOR;
				
				UPDATE BdiTarjeta:"informix".Td_Movimientos_Conciliacion
					set monto325 = vsRegistroComprareal
				WHERE Consecutivo = psConsecutivo;
				
				LET vmMonto325 = ( ( REPLACE( vsRegistroComprareal,'.',''))::MONEY /100 );
				LET vsMonto325 = CAST(vmMonto325 AS CHAR(13));
				LET vmSumaMonto325 = 0;
				
				-- Convierte a string el montocashback325 que debe mandar a identificarse
				LET vsRegistroCashreal = CAST(vmmontocashback as CHAR(13));
				LET vsRegistroCashreal = REPLACE(REPLACE(vsRegistroCashreal,'$',''),'.',''); 
				LET viconcaracteres2 = Length(vsRegistroCashreal);
				FOR  b = viconcaracteres2  TO 12 STEP 1
						LET vsRegistroCashreal = '0'||vsRegistroCashreal;
				END FOR;
				
				UPDATE BdiTarjeta:"informix".Td_Movimientos_Conciliacion
					set montocashback325 = vsRegistroCashreal,
						iso323 = 'CC'
				WHERE Consecutivo = psConsecutivo;
				
				LET vmMontoCashback325 = ((REPLACE( vsRegistroCashreal,'.',''))::MONEY /100 ); 
				LET vsMontoCashback325 = CAST(vmMontoCashback325 AS CHAR(13));
				LET vmSumaMontoCashback325 = 0; -- Para suma de CashBack
			
				LET viActualizacion = 1;
			end if;
			---    #############################################   EXCEPCIONES CUANDO MONTO CASHBACK ESTA ERRONERO   ########################################
			IF  (  vmMontoCashback325 < vmMontointercardcashback ) THEN
			
				LET vmregistromontototal = ((( REPLACE( psMonto325,'.',''))::MONEY /100 ) + (( REPLACE( psMontoCashBack325,'.',''))::MONEY /100 )); -- Monto de la transaccion real
				LET vmmontocompra = vmregistromontototal - vmMontointercardcashback;
				LET vmmontocashback = vmMontointercardcashback;
				
				-- Convierte a string el monto325 que debe mandar a identificarse
				LET vsRegistroComprareal = CAST(vmmontocompra as CHAR(13));
				LET vsRegistroComprareal = REPLACE(REPLACE(vsRegistroComprareal,'$',''),'.',''); 
				LET viconcaracteres1 = Length(vsRegistroComprareal);
				FOR  a = viconcaracteres1  TO 12 STEP 1
						LET vsRegistroComprareal = '0'||vsRegistroComprareal;
				END FOR;
				
				UPDATE BdiTarjeta:"informix".Td_Movimientos_Conciliacion
					set monto325 = vsRegistroComprareal
				WHERE Consecutivo = psConsecutivo;
				
				LET vmMonto325 = ( ( REPLACE( vsRegistroComprareal,'.',''))::MONEY /100 );
				LET vsMonto325 = CAST(vmMonto325 AS CHAR(13));
				LET vmSumaMonto325 = 0;
				
				-- Convierte a string el montocashback325 que debe mandar a identificarse
				LET vsRegistroCashreal = CAST(vmmontocashback as CHAR(13));
				LET vsRegistroCashreal = REPLACE(REPLACE(vsRegistroCashreal,'$',''),'.',''); 
				LET viconcaracteres2 = Length(vsRegistroCashreal);
				FOR  b = viconcaracteres2  TO 12 STEP 1
						LET vsRegistroCashreal = '0'||vsRegistroCashreal;
				END FOR;
				
				UPDATE BdiTarjeta:"informix".Td_Movimientos_Conciliacion
					set montocashback325 = vsRegistroCashreal,
						iso323 = 'CE'
				WHERE Consecutivo = psConsecutivo;
				
				LET vmMontoCashback325 = ((REPLACE( vsRegistroCashreal,'.',''))::MONEY /100 ); 
				LET vsMontoCashback325 = CAST(vmMontoCashback325 AS CHAR(13));
				LET vmSumaMontoCashback325 = 0; -- Para suma de CashBack
				
				LET viActualizacion = 1;
			end if;
			
			
			-- ###########################################################################################################################
		-- Estructura montos de fraccionadas para ir armando su acumulado correspondiente
			IF ( vmMonto325 < vmMontointercard) THEN
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ ;
				--SUMA EL MONTO DE LAS TRANSACCIONES FRACCIONADAS QUE YA FUERON APLICADAS
				SELECT SUM( ( ( REPLACE( monto325,'.',''))::MONEY/100 )) AS MONTO325
				INTO vmSumaMonto325
				FROM bditarjeta:"informix".td_movimientos_conciliacion
				WHERE numtarjeta = psNumtarjeta 
				AND secuencia325 = psSecuencia325
				AND Aplicacion = 'V'
				AND Finalizado = 'V';
				
				--AGREGA EL MONTO DE LA OPERACION ACTUAL PARA EFECTOS DE CALCULO
				LET vmSumaMonto325 = vmSumaMonto325 + vmMonto325;
			END IF;
			
			IF (vmMontoCashback325 < vmMontointercardCashback) then
				
				
				--SUMA EL MONTO DE LAS TRANSACCIONES FRACCIONADAS casos cashback QUE YA FUERON APLICADAS
				SELECT SUM( ( ( REPLACE( montocashback,'.',''))::MONEY/100 )) AS MONTOCASHBACK325
				INTO vmSumaMontoCashback325
				FROM bditarjeta:"informix".td_movimientos_conciliacion
				WHERE numtarjeta = psNumtarjeta 
				AND secuencia325 = psSecuencia325
				AND Aplicacion = 'V'
				AND Finalizado = 'V';
				
				--AGREGA EL MONTO DE LA OPERACION ACTUAL PARA EFECTOS DE CALCULO
				LET vmSumaMontoCashback325 = vmSumaMontoCashback325 + vmMontoCashBack325;
			END IF;
		
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_identificatipoconciliacion
			(
				vsRetorno,					--intercard:movimiento
				psConsecutivo,  			--bditarjeta:td_movimientos_conciliacion
				psNumtarjeta,				--bditarjeta:td_movimientos_conciliacion
				psSecuencia325,				--bditarjeta:td_movimientos_conciliacion
				vsMovconciliado,			--intercard:movimiento
				vmMontointercard,			--intercard:movimiento resultado de busca movimiento intercard
				vmMontointercardCashback, 	-- Intercard:movimiento resultado de busca movimiento intercard
				vsMonto325,					--bditarjeta:td_movimientos_conciliacion
				vsMontoCashback325,         --bditarjeta:td_movimientos_conciliacion
				--psSumaMonto325,			--bditarjeta:td_movimientos_conciliacion  Suma de monto325
				vmSumaMonto325,				--bditarjeta:td_movimientos_conciliacion  Suma de monto325
				vmSumaMontoCashback325,		--bditarjeta:td_movimientos_conciliacion  Suma de montocashback325
				psTipotransaccion325,  --bditarjeta:td_movimientos_conciliacion
				psConciliacionArchivo,	--bditarjeta:td_archivo_origen

				psConciliacion,   		-- bditarjeta:td_movimientos_conciliacion
				vsSecuenciaorig,		--intercard:movimiento
				vsSecuencia_extendida,	--intercard:movimiento
				vdFechatransaccion, 	--intercard:movimiento
				vsInfreceptor,			--intercard:movimiento
				vsIdterminal,			--intercard:movimiento
				vsMetodocaptura,		--intercard:movimiento
				vsMovreversado,			--intercard:movimiento
				vsCodigoiso,			--intercard:movimiento
				vsFormato,				--intercard:movimiento
				
				piTipo_LayOut,			--BdiTarjeta:Td_Archivo_OrigenTmp ---
				psISO323,				--BdiTarjeta:Td_Movimientos_Conciliacion
				psMovRev325,			--BdiTarjeta:Td_Movimientos_Conciliacion
				vsCodReversa, 			--Intercard:Movimiento
				vsCodigoCentral			--Intercard:Movimiento
			)
			INTO
				vsRetornor,              	-- Valor de retorno
				vsConciliacion,
				vsSecuencia,				-- Secuencia de trasaccion
				vsSecuencia_extendidar,  	-- Extendida de la transaccion
				vmMontointercardr,       	--
				vmMontointercardCashbackr,
				vdFechatransaccionr,     --
				vsInfreceptorr,          --
				vsIdterminalr,           --
				vsMetodocapturar,        --
				vsMovconciliador,        --
				vsMovreversador,         --
				vsTipo_mov,
				vsFolio_mov,
				vdFechaconcilia,
				viTipo_conciliacion,
				vsDesc_conciliacion,
				vsErrorActividad;

			LET vssqlerr = vsRetornor;
			LET viRetorno = CAST( vsRetornor AS INTEGER );

			IF ( viRetorno < 0  ) THEN
				LET vsErrorActividad = 'CONSECUTIVO ' || psConsecutivo || ' OCURRIO UN ERROR NO CONTROLADO AL EJECUTAR sp_concreing_identificatipoconciliacion' ;
			ELIF ( viRetorno >= 0  ) THEN
				
				LET vsSecuencia_extendida = vsSecuencia_extendidar;
				LET vmMontointercard = vmMontointercardr;
				LET vmMontointercardCashback = vmMontointercardCashbackr;
				LET vdFechatransaccion = vdFechatransaccionr;
				LET vsInfreceptor = vsInfreceptorr;
				LET vsIdterminal = vsIdterminalr;
				LET vsMetodocaptura = vsMetodocapturar;
				LET vsMovconciliado = vsMovconciliador;
				LET vsMovreversado = vsMovconciliador;
				
			END IF;
			 
			--   PROCESO NUEVO PARA IDENTIFICACION DE MONTOS MAYORES Y TRANSACCIONES FORZADAS*
			if vsb_aplica = 'P' then
				
				if viTipo_conciliacion = 5 then
						
						if psArchivo_origen in ('VIC', 'VID', 'MCC', 'MCD') then -- Porcentaje fijo para Internacionales
							set isolation to dirty read;
							select valor into vsvalor from bditarjeta:"informix".td_param_conciliacion_concreing
								where codigo = '750';
							let vfporcentaje = TRIM(NVL(vsvalor, 0.00));
							
						elif psArchivo_origen in ('VNC', 'VND') then  -- Porcentaje en Base a Nacionales y giros
						
							set isolation to dirty read;
							select porcentaje 
								into vfporcentaje 
							from bditarjeta:"informix".td_parametros_montosmayores
								where codigo_negocio = vscodgironeg;
								
						end if;
								
							
						if (vfporcentaje is null) or (vfporcentaje = '')  then -- Agregar validacion de Archivo origen 
							
							let vfporcentaje = 0.00;
							
						end if
						
						let vmmontototal = vmMontointercard + vmMontointercardCashback;
						let vmmontoporcentaje = vmmontototal * vfporcentaje;
						let vmmontototalmaximo = vmmontototal + vmmontoporcentaje;
											
						if ((vmMonto325 + vmMontoCashback325) > vmmontototalmaximo)  then 
							let vsb_aplica = 'F';
						else
							let vsb_aplica = 'V';
						end if;											
						
				elif viTipo_conciliacion in (8,28,31,33) then 
				
						let vsb_aplica = 'F';
				
				elif viTipo_conciliacion not in (8,28,31,33,5) then 
				
						let vsb_aplica = 'V';
						
				end if;
			else 
				let vsb_aplica = vsb_aplica;
			end if;
				
			UPDATE BdiTarjeta:"informix".td_Movimientos_Conciliacion
				SET codgironeg = vscodgironeg,
					b_aplica = vsb_aplica
				WHERE 	NumTarjeta = psNumtarjeta 
						AND Secuencia325 = psSecuencia325 
						AND Consecutivo = psConsecutivo;
			
			--   PROCESO NUEVO PARA IDENTIFICACION  -- agregar variables utilizadas proceso nuevo 
			
		ELSE

			LET vsErrorActividad = 'CONSECUTIVO ' || psConsecutivo || ' OCURRIO UN ERROR NO CONTROLADO AL EJECUTAR sp_concreing_buscarmovimientointercard';

		END IF;

	ELIF ( psIntegridad IN ('F','P')) THEN
		/*CONCLUYE LA ETAPA DE CONCILIACION DEL REGISTRO*/

		/*SE DEBE MANTENER P EN CONCILIACION */
		LET vsConciliacion = 'P';
		
		
		
		UPDATE bditarjeta:"informix".td_movimientos_conciliacion
		SET conciliacion = 'P'
		WHERE numtarjeta = psNumtarjeta AND secuencia325 = psSecuencia325 AND consecutivo = psConsecutivo;

		LET vssqlerr = '00402';

		LET vsErrorActividad = 'CONSECUTIVO ' || psConsecutivo || ' EL REGISTRO NO PRESENTA INTEGRIDAD CORRECTA';

	END IF;



	/*RETORNO DEL PROCEDIMIENTO ALMACENADO*/
	RETURN	vssqlerr,
		NVL(vsConciliacion,''),
		NVL(vsSecuencia,''),
		NVL(vsSecuencia_extendida,''),
		NVL(vsCodgironeg,''), -- TFORZADAS
		NVL(vmMontointercard,0),
		NVL(vmMontointercardCashback,0),
		NVL(vdFechaTransaccion,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
		NVL(vsInfreceptor,''),
		NVL(vsIdterminal,''),
		NVL(vsMetodocaptura,''),
		NVL(vsMovconciliado,''),
		NVL(vsMovreversado,''),
		NVL(vsTipo_mov,''),
		NVL(vsb_aplica,''), --TFORZADAS
		NVL(vsFolio_mov,''),
		NVL(vdFechaconcilia,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
		NVL(viTipo_conciliacion,0),
		NVL(vsDesc_conciliacion,''),
		NVL(vsErrorActividad,''),
		NVL(viElemento,4),
		NVL(viActualizacion,1);
		


END;
END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: Conciliacion intercard.',
'Fecha: 2011/06/20',
'Version: 20110620.0901',
'BD: bditarjeta',
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agregó consulta para actualizar el campo numtarjeta de td_movimientos_conciliacion .',
'Fecha: 2011/10/05',
'Version: 20111005.1101',
'BD: bditarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA LA CONSULTA PARA OBTENER EL NUMERO DE CUENTA PARA LAS TRANSACCIONES POS.',
'Fecha: 2011/10/17',
'Version: 20111017.1048',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion -DEVOLUCIONES',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA EL CODIGO PARA MANEJAR EL NUEVO CAMPO DE FORMATO PARA LA CLASIFICACION DE DEVOLUCIONES.',
'Fecha: 2012/05/21',
'Version: 20120521.1239',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion ',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA EL CODIGO PARA CONTEMPLAR LOS CAMPOS CodReversa Y CodigoCentral ASI COMO LOS PARAMETROS piTipo_LayOut, psISO323 Y psMovRev325 PARA LAS CONCILIACION DE ATM.',
'Fecha: 2012/07/27',
'Version: 20120727.1437',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA LA LOGICA PARA ELIMINAR LA CLASIFICACION DE LOS ARCHIVOS PNC DEL PROCESO PUESTO QUE NO REQUIEREN CLASIFICACION.',
'Fecha: 2012/08/10',
'Version: 20120810.1039',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA LA LOGICA PARA CALCULAR CORRECTAMENTE EL MONTO DE LAS OPERACIONES FRACCIONADAS.',
'Fecha: 2012/08/10',
'Version: 20120810.1145',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martinez',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Antonio Gomez',
'Descripcion: Se modificación llamado a sp_concreing_buscarmovimientointercard, por cambio de entrada de integro psmonto325',
'Fecha: 2013/05/30',
'Version: 20130530.1400',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martinez',
'Proyecto: Integracion de CashBack proceso de conciliacion',
'Solicito: Luis Antonio Gomez',
'Descripcion: Se modificación llamado a sp_concreing_buscarmovimientointercard y sp_concreing_identificatipoconciliacion, por cambio de entrada al integrar monto cashBack',
'Fecha: 2013/07/30',
'Version: 20130730.1720',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martinez',
'Proyecto: Integracion proceso especial cuando no se envie el monto de CashBack',
'Solicito: Luis Antonio Gomez',
'Descripcion: Se integra proceso para actualizar monto325 y montocashback325 en caso de que este ultimo sea enviado con ceros en archivo 325',
'Fecha: 2013/09/18',
'Version: 20130918.1200',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martinez',
'Proyecto: Integracion proceso especial cuando el monto CASH BACK el adquirente lo mande menor',
'Solicito: Jose Luis Puebla',
'Descripcion: Se integra proceso para actualizar monto325 y montocashback325 en caso de que este ultimo sea enviado con un monto menor al que le corresponde en el archivo 325',
'Fecha: 2014/01/13',
'Version: 20140113.1600',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martínez',
'Proyecto: RQM 06 384 Proceso de Conciliación de Transacciones Forzadas',
'Solicito: Jose Luis Puebla Salinas ',
'Descripcion: Se agrega proceso determinar si Monto mayor es permitido y bloqueo de transacciones forzadas ',
'Fecha: 2015/07/07',
'Version: 20150707.1500',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_dep_atm (psCve_Usuario VARCHAR(10) , piHorario INTEGER)

		RETURNING VARCHAR (5)   AS CODIGO, VARCHAR (150) AS MENSAJE_RPTA;
		
		 /*  DEFINICION DE VARIABLES */

			-- CONTROL DE ERRORES
			
		    DEFINE  SQL_ERR          INTEGER;
			DEFINE  ISAM_ERR         INTEGER;
			DEFINE  ERROR_INFO       VARCHAR(80);
			
			--CONTROL GENERAL
			
			DEFINE CODIGO				 CHAR (6);
			DEFINE MENSAJE_RPTA			 CHAR (80);
			DEFINE vdFechaInicio		 DATETIME YEAR TO FRACTION (5);
			DEFINE vdFechaFin			 DATETIME YEAR TO FRACTION (5);
			DEFINE vsFechaArchivo		 CHAR (10);
			DEFINE vsFechaArchivoTMO	 CHAR (06);
			DEFINE vsNombreArchivo		 VARCHAR (30);
			DEFINE vsProceso			 CHAR (01);
			DEFINE vsFechaHorainAuthini	 CHAR (10);
			DEFINE vsFechaHorainAuthfin	 CHAR (10);
			DEFINE vsConAdmin			 CHAR (01);
			DEFINE RUTA_DESTINO 		 VARCHAR(80);
			DEFINE TIPO_PLANTILLA		 VARCHAR(30);
			DEFINE TIPO_PLANTILLA_TOTAL	 VARCHAR(30);
			DEFINE vsql					 CHAR(1150);
			DEFINE vExecuteSQL 			 LVARCHAR(1500);
			
			
			
	BEGIN	
		
		ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
				
		  LET CODIGO    = SQL_ERR;
		  LET MENSAJE_RPTA  = ERROR_INFO;
		  
		  RETURN CODIGO, MENSAJE_RPTA;
		  
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/informix/LVRQ/dep_atm/debug/CNC_ATMS_DEP.out";
		--TRACE ON;
		
			/* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL
			
			LET CODIGO					= '00000';
			LET MENSAJE_RPTA			= 'PROCESO EXITOSO';
			LET vdFechaInicio			= CURRENT;
			LET vdFechaFin				= CURRENT;
			LET vsFechaArchivo			= '';
			LET vsFechaArchivoTMO		= '';
			LET vsNombreArchivo			= '';
			LET vsProceso				= '';
			LET vsFechaHorainAuthini	= '';
			LET vsFechaHorainAuthfin	= '';
			LET vsConAdmin				= '';
			LET RUTA_DESTINO	 		= '/RESPALDOSNEW/Depositadores_atm/';
			LET TIPO_PLANTILLA	 		= 'ATM_DEP_VS_MOVHIS_';
			LET TIPO_PLANTILLA_TOTAL	= 'TOTAL_CAJEROS_IST_'; -- QUITAR
			LET vsql					='';
			LET vExecuteSQL				='';

		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;	

		--TRACE 'ES CNC DE nueva inicio';
			IF ( (SELECT COUNT(*) FROM bditarjeta:td_archivos_conciliacion_dep_atm 	
					WHERE archivo_origen = 'DEP'
					AND conadmin = '') = 0 ) THEN
					
					LET CODIGO = '00001';
					LET MENSAJE_RPTA = 'NO SE ENCONTRO ARCHIVO PARA SER CONCILIADO';
					
					RETURN CODIGO, MENSAJE_RPTA;
				          
			END IF;
			--TRACE 'ES CNC DE nueva fin';

		   IF ( (SELECT COUNT(*) FROM bditarjeta:systables WHERE tabname = 'tmp_paso_movhis_cnc_atm') = 1 ) THEN

					TRUNCATE TABLE tmp_paso_dep_atm DROP STORAGE;
					TRUNCATE TABLE tmp_paso_mov_vs_dep DROP STORAGE;
					TRUNCATE TABLE tmp_paso_movhis_cnc_atm DROP STORAGE;

			END IF;
			
		
			FOREACH cursor_cnc FOR
			
				/* Campos utilizados para obtener los archivos que se deban procesar para la conciliacion */

				SELECT nombrearchivo,TO_CHAR((fecha_archivo)-1, '%m-%d-%Y'),TO_CHAR((fecha_archivo), '%m-%d-%Y'),
					   fecha_archivo,TO_CHAR((fecha_archivo)-1, '%d%m%y'),proceso,conadmin
				INTO vsNombreArchivo,vsFechaHorainAuthini,vsFechaHorainAuthfin,vsFechaArchivo,vsFechaArchivoTMO,vsProceso,vsConAdmin
					FROM bditarjeta:td_archivos_conciliacion_dep_atm
					WHERE archivo_origen = 'DEP'
					AND conadmin = ''
			
		
				/* SE GENERA TABLA TEMPORAL CON LOS REGISTROS DE LA TABLA DE MOVIMIENTO HISTORICOS */
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo " SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;'||
								  ' UNLOAD TO /RESPALDOSNEW/Depositadores_atm/dep_atm_movhis.unl'||
								  ' SELECT cuenta,monto_tot,transacc_suc,fech_oper,usuario,fech_alt,sucursal,folio_suc,referencia'||
							' FROM bdicheq:sc_movhis '||
							' WHERE fech_alt BETWEEN '||"'"|| vsFechaHorainAuthini||"'"||' AND '||"'"|| vsFechaHorainAuthini ||"'"||
							' AND transacc = \"0318\"		 	AND '||
							' sucursal = \"8502\"  '||
							';" >'|| 
							' /RESPALDOSNEW/Depositadores_atm/'||'movhis_DepAtm.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #2
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'dbaccess bdicheq '||'/RESPALDOSNEW/Depositadores_atm/'||'movhis_DepAtm.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #3
				LET vExecuteSQL = '';
				LET vExecuteSQL = "echo "||'"'|| "file '"|| '/RESPALDOSNEW/Depositadores_atm' ||
						"/" || 'dep_atm_movhis.unl' || "' delimiter '|' "|| '9'||
							"; insert into tmp_paso_movhis_cnc_atm" || ";"||'"'||' > /RESPALDOSNEW/Depositadores_atm/carga_movhis.txt';
					SYSTEM vExecuteSQL;
				
				---Paso #4
				LET vExecuteSQL = '';
				LET vExecuteSQL = "dbload -d bditarjeta -c /RESPALDOSNEW/Depositadores_atm/carga_movhis.txt -l err_carga.log -n 1000 -k";
				SYSTEM vExecuteSQL;			
				

					---Paso #5
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f /RESPALDOSNEW/Depositadores_atm/dep_atm_movhis.unl';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f /RESPALDOSNEW/Depositadores_atm/movhis_DepAtm.sql'; 
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  carga_movhis.txt';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  err_carga.log';
				SYSTEM vExecuteSQL;
				
				
				/* SE GENERA TABLA TEMPORAL CON LOS REGISTROS DE LA TABLA CONCILIACION_ATM_STAT06_DEPOSITADORES */
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo " SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;'||
								' UNLOAD TO /RESPALDOSNEW/Depositadores_atm/DepAtm_stat06.unl'||
								' SELECT nombrearchivo,num_cuenta,monto_deposito,fecha,hora,tipo_txn,'||
								' descripcion,folio_dep,sec_extendida_archivo,cajero'||
								' FROM Intercard:conciliacion_atm_stat06_depositadores '||
								' WHERE nombrearchivo = ' ||"'"||vsNombreArchivo||"'"||
								' AND tipo_txn =\"D\"'||
								';" >'|| 
							' /RESPALDOSNEW/Depositadores_atm/'||'DepAtm_cnc.sql';
				SYSTEM vExecuteSQL;
				
				
				---Paso #2
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'dbaccess intercard '||'/RESPALDOSNEW/Depositadores_atm/'||'DepAtm_cnc.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #3
				LET vExecuteSQL = '';
				LET vExecuteSQL = "echo "||'"'|| "file '"|| '/RESPALDOSNEW/Depositadores_atm' ||
						"/" || 'DepAtm_stat06.unl' || "' delimiter '|' "|| '10'||
							"; insert into tmp_paso_dep_atm" || ";"||'"'||' > /RESPALDOSNEW/Depositadores_atm/carga_dep_stat.txt';
				SYSTEM vExecuteSQL;
				
				---Paso #4
				LET vExecuteSQL = '';
				LET vExecuteSQL = "dbload -d bditarjeta -c /RESPALDOSNEW/Depositadores_atm/carga_dep_stat.txt -l err_carga.log -n 1000 -k";
				SYSTEM vExecuteSQL;

				---Paso #5
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f /RESPALDOSNEW/Depositadores_atm/DepAtm_stat06.unl';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f /RESPALDOSNEW/Depositadores_atm/DepAtm_cnc.sql'; 
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  carga_dep_stat.txt';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  err_carga.log';
				SYSTEM vExecuteSQL;				
			
				
				SELECT cnc.nombrearchivo,cnc.num_cuenta,his.cuenta,cnc.monto_deposito,his.monto_tot,his.transacc_suc,
						cnc.tipo_txn,his.sucursal,cnc.fecha,his.fech_oper,cnc.hora,his.fech_alt,cnc.descripcion,cnc.folio_dep,
						his.folio_suc,cnc.sec_extendida_archivo,cnc.cajero,his.usuario,his.referencia
					FROM tmp_paso_movhis_cnc_atm his
					full OUTER JOIN tmp_paso_dep_atm cnc
					ON cnc.num_cuenta = his.cuenta 
					and cnc.folio_dep = his.folio_suc
				INTO temp tb_full_stat_movhis WITH NO LOG ;
				
				
				SELECT *,
					CASE
						WHEN num_cuenta IS NULL THEN cuenta
						ELSE num_cuenta
					END fn_num_cuenta,

					CASE 
						WHEN folio_suc IS NULL then 'F'
						ELSE 'V'
					END  ok_movhis,

					CASE 
						WHEN folio_dep IS NULL then 'F'
						ELSE 'V'
					END ok_atm_dep

					FROM tb_full_stat_movhis
				INTO temp tb_full_stat_movhis_2 WITH NO LOG ;
				
				--- Aqui me quede
				
				SELECT tbl1.fn_num_cuenta,tbl1.folio_suc,tbl1.folio_dep
					FROM tb_full_stat_movhis_2 tbl1
					JOIN bditarjeta:dep_atm_stat06_vs_movhis tbl2
					ON tbl1.fn_num_cuenta=tbl2.fn_num_cuenta 
					AND tbl1.folio_suc = tbl2.folio_suc
					AND tbl1.folio_dep = tbl2.folio_dep
				INTO temp tb_duplicados_dep WITH NO LOG ;
				
				DELETE FROM tb_full_stat_movhis_2 tbl3
					WHERE (tbl3.fn_num_cuenta IN(SELECT tbl4.fn_num_cuenta FROM tb_duplicados_dep tbl4)
				AND tbl3.folio_dep IN (SELECT tbl4.folio_dep FROM tb_duplicados_dep tbl4)
				);
				
				
				/* TBL DE PASO CON LAS TXN DE MOVIMIENTO VS IST */
				
				INSERT INTO tmp_paso_mov_vs_dep  --- nuevo
				SELECT  * FROM tb_full_stat_movhis_2;

				---Paso #1
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo " SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;'||
								  ' UNLOAD TO /RESPALDOSNEW/Depositadores_atm/txn_movhis_vs_stat.unl'||
								' SELECT nombrearchivo,num_cuenta,cuenta,monto_deposito,monto_tot, transacc_suc,tipo_txn,sucursal,fecha,'||
								' fech_oper, hora,fech_alt,descripcion,folio_dep, folio_suc, sec_extendida_archivo,cajero,usuario,'||
								' referencia,fn_num_cuenta,ok_movhis,ok_atm_dep'||
								' FROM bditarjeta:tmp_paso_mov_vs_dep '||
								';" >'|| 
							' /RESPALDOSNEW/Depositadores_atm/'||'DepAtm_movhis_stat06.sql';
				SYSTEM vExecuteSQL;
				
				
				---Paso #2
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'dbaccess bditarjeta '||'/RESPALDOSNEW/Depositadores_atm/'||'DepAtm_movhis_stat06.sql';
				SYSTEM vExecuteSQL;

				---Paso #3
				LET vExecuteSQL = '';
				LET vExecuteSQL = "echo "||'"'|| "file '"|| '/RESPALDOSNEW/Depositadores_atm' ||
						"/" || 'txn_movhis_vs_stat.unl' || "' delimiter '|' "|| '22'||
							"; insert into dep_atm_stat06_vs_movhis " || ";"||'"'||' > /RESPALDOSNEW/Depositadores_atm/carga_dep_stat_final.txt';
				SYSTEM vExecuteSQL;
				
				---Paso #4
				LET vExecuteSQL = '';
				LET vExecuteSQL = "dbload -d bditarjeta -c /RESPALDOSNEW/Depositadores_atm/carga_dep_stat_final.txt -l err_carga.log -n 1000 -k";
				SYSTEM vExecuteSQL;
				
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f /RESPALDOSNEW/Depositadores_atm/txn_movhis_vs_stat.unl';
				SYSTEM vExecuteSQL;
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  /RESPALDOSNEW/Depositadores_atm/carga_dep_stat_final.txt';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  err_carga.log';
				SYSTEM vExecuteSQL;		
				
				
				UPDATE bditarjeta:td_archivos_conciliacion_dep_atm
					SET conadmin = 'V'
					WHERE nombrearchivo = vsNombreArchivo
				AND conadmin='';
				
				/* Tablas Fisicas Temporales */
				
				TRUNCATE TABLE tmp_paso_dep_atm DROP STORAGE;
				TRUNCATE TABLE tmp_paso_mov_vs_dep DROP STORAGE;
				TRUNCATE TABLE tmp_paso_movhis_cnc_atm DROP STORAGE;
				
				/* Tablas temporales */
				
				DROP TABLE IF EXISTS tb_full_stat_movhis;
				DROP TABLE IF EXISTS tb_full_stat_movhis_2;
				DROP TABLE IF EXISTS tb_duplicados_dep;
				
				--- Reporte de conciliacion entre movimiento vs el archivo IST con el Core Bancario
			
				LET vsql = ''; 	   
				LET vsql = 'echo "nombrearchivo|num_cuenta|cuenta|monto_deposito|monto_tot|transacc_suc|tipo_txn|sucursal|'||
						   ' fecha|fech_oper|hora|fech_alt|descripcion|folio_dep|folio_suc|sec_extendida_archivo|cajero| '||
						   ' usuario|referencia|fn_num_cuenta|ok_movhis|ok_atm_dep " > '||
							RUTA_DESTINO||TIPO_PLANTILLA||LPAD (DAY(vsFechaArchivo),2,"0")||
							LPAD (MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo) ||'.unl';
				system vsql;
				
								LET vsql = '';
				LET vsql = 'echo " SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; ' ||
						   ' UNLOAD TO ' ||RUTA_DESTINO||TIPO_PLANTILLA||LPAD (DAY(vsFechaArchivo),2,"0")||LPAD (MONTH(vsFechaArchivo),2,"0")||
							year(vsFechaArchivo)||'_01.unl'||
						   ' SELECT nombrearchivo,num_cuenta,cuenta,monto_deposito,monto_tot,transacc_suc,tipo_txn,sucursal,'||
						   ' fecha,fech_oper,hora,fech_alt,descripcion,folio_dep,folio_suc,sec_extendida_archivo,cajero,'||
						   ' usuario,referencia,fn_num_cuenta,ok_movhis,ok_atm_dep'||
						   ' from bditarjeta:dep_atm_stat06_vs_movhis '||
						   ' WHERE nombrearchivo = ' ||"'"||vsNombreArchivo||"'"||
						   ';">'||RUTA_DESTINO||TIPO_PLANTILLA||LPAD (DAY(vsFechaArchivo),2,"0")||LPAD (MONTH(vsFechaArchivo),2,"0")||
							year(vsFechaArchivo)||'.sql'; 
				system vsql;
				
				LET vsql ='';
				LET vsql= 'chmod 777 ' ||RUTA_DESTINO||TIPO_PLANTILLA||
						  LPAD (DAY(vsFechaArchivo),2,"0")||LPAD (MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo)||'.sql';
				system vsql;
				
				LET vsql ='';
				LET vsql= 'dbaccess bditarjeta ' ||RUTA_DESTINO||TIPO_PLANTILLA||LPAD (DAY(vsFechaArchivo),2,"0")||
						   LPAD (MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo)||'.sql';
				system vsql;
				
				LET vsql = '';
				LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA||LPAD (DAY(vsFechaArchivo),2,"0")||LPAD(MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo)||'.sql';
				system vsql;
				
				LET vsql = '';
				LET vsql = "sed 's/|$//g' "||RUTA_DESTINO||TIPO_PLANTILLA||LPAD (DAY(vsFechaArchivo),2,"0")||
						   LPAD (MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo)||"_01.unl >>"||RUTA_DESTINO||TIPO_PLANTILLA||
						   LPAD (DAY(vsFechaArchivo),2,"0")||LPAD (MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo)||".unl";
				system vsql;
				
				LET vsql = '';
				LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA||LPAD (DAY(vsFechaArchivo),2,"0")||LPAD (MONTH(vsFechaArchivo),2,"0")||year(vsFechaArchivo)||'_01.unl';
				system vsql;
				

			END FOREACH; -- CICLO DE OBTENCION DE REGISTROS	
			
		RETURN CODIGO, MENSAJE_RPTA;
	END
END PROCEDURE;