CREATE PROCEDURE "informix".sp_conciliaintercard_mc(
	psCve_usuario 				CHAR (10), 	--USUARIO DEL SISTEMA
	psArchivo_origen 			CHAR (3), 	--TD_ARCHIVO_ORIGEN
	psConciliacionArchivo		CHAR (1),	--TD_ARCHIVO_ORIGEN
	psConciliacion 				CHAR(1),   	-- bditarjeta:td_movimientos_conciliacion_mc
	psConsecutivo 				INTEGER, 	--td_movimientos_conciliacion_mc	CONSECUTIVO
	psNumtarjeta 				CHAR (16), 	--td_movimientos_conciliacion_mc   NUMTARJETA
	psSecuencia325 				CHAR(6),  	--td_movimientos_conciliacion_mc	
	psMonto325 					CHAR(13),	--td_movimientos_conciliacion_mc    Monto de Operacion 
	psMontoCashBack325 			CHAR(13),    --td_movimientos_conciliacion_mc    Monto de Cash Back
	psTipotransaccion325 		CHAR(15),
	psIntegridad 				CHAR(1),    --PARAMETRO INICIAL
	piTipo_LayOut 				INTEGER,	 --BdiTarjeta:Td_Archivo_OrigenTmp ---
	psISO323 					CHAR(2),	--BdiTarjeta:td_movimientos_conciliacion_mc
	psMovRev325 				CHAR(1)	,	--BdiTarjeta:td_movimientos_conciliacion_mc
	psb_aplica 					CHAR(1),	--TForzadas de BdiTarjeta:td_movimientos_conciliacion_mc
	psvssecuencia_ext_archivo 	CHAR(15),	--BdiTarjeta:td_movimientos_conciliacion_mc
	psvsarchivo_origenMC 		CHAR(03),	--BdiTarjeta:td_movimientos_conciliacion_mc
	psIdProcesador 				CHAR(05)	--BdiTarjeta:td_movimientos_conciliacion_mc
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
-- AUTOR : Victoria Quiñones  -----------------------------------------------------------------------
-- FECHA : 11/06/2018  ------------------------------------------------------------------------------
-- BD: bditarjeta  ----------------------------------------------------------------------------------
-- SISTEMA :Conciliacion automatica MasterCard - Oxxo  -----------------
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

/* folio regulatorio */

DEFINE vsfolio_reg      		CHAR(16);


--SET DEBUG FILE TO '/informix/LVRQ/CNC_MC_OXXO/NvoDev/dev/TraceCONCILIAINTERCARD.txt';
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


/* folio regulatorio */

LET vsfolio_reg = '';

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


		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		/*SE VERIFICA LA INTEGRIDAD DEL REGISTRO*/
		
		let vsb_aplica = psb_aplica;
		IF ( psIntegridad = 'V') THEN
			/*CONTINUA FASE 2*/

			/*LECTURA DEL MOVIMIENTO ORIGINAL EN INTERCARD*/
			EXECUTE PROCEDURE bditarjeta:"informix".sp_buscar_mov_intercard_mc  -- Se Modidica retorno para baplica 
			( psCve_usuario, psNumtarjeta , psSecuencia325, psMonto325, psMontoCashBack325,psvssecuencia_ext_archivo,psvsarchivo_origenMC,psIdProcesador) -- Se agrega psmonto325 para validar montos
				INTO vsRetorno, vsSecuenciaorig, vsSecuencia_extendida, vmMontointercard, vmMontointercardCashback, vdFechatransaccion,
				vsInfreceptor, vsIdterminal, vsMetodocaptura, vsMovconciliado, vsMovreversado, vsCodigoiso, vsFormato, vsErrorActividad,
			vsCodReversa, vsCodigoCentral, vscodgironeg,vsfolio_reg; --TFORZADAS
			
			--LET vsErrorActividad = 'CONSULTA MOVIMIENTO INTERCARD' ;


			LET viRetorno = CAST( vsRetorno AS INTEGER);

			IF( viRetorno >= 0  ) THEN
				
				EXECUTE PROCEDURE bditarjeta:"informix".sp_identifica_tipo_conciliacion_mc
				(
					vsRetorno,					--intercard:movimiento
					psConsecutivo,  			--bditarjeta:td_movimientos_conciliacion_mc
					psNumtarjeta,				--bditarjeta:td_movimientos_conciliacion_mc
					psSecuencia325,				--bditarjeta:td_movimientos_conciliacion_mc
					vsMovconciliado,			--intercard:movimiento
					vmMontointercard,			--intercard:movimiento resultado de busca movimiento intercard
					vmMontointercardCashback, 	-- Intercard:movimiento resultado de busca movimiento intercard
					psMonto325,					--bditarjeta:td_movimientos_conciliacion_mc
					vsMontoCashback325,         --bditarjeta:td_movimientos_conciliacion_mc
					--psSumaMonto325,			--bditarjeta:td_movimientos_conciliacion_mc  Suma de monto325
					vmSumaMonto325,				--bditarjeta:td_movimientos_conciliacion_mc  Suma de monto325
					vmSumaMontoCashback325,		--bditarjeta:td_movimientos_conciliacion_mc  Suma de montocashback325
					psTipotransaccion325,  --bditarjeta:td_movimientos_conciliacion_mc
					psConciliacionArchivo,	--bditarjeta:td_archivo_origen

					psConciliacion,   		-- bditarjeta:td_movimientos_conciliacion_mc
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
					psISO323,				--BdiTarjeta:td_movimientos_conciliacion_mc
					psMovRev325,			--BdiTarjeta:td_movimientos_conciliacion_mc
					vsCodReversa, 			--Intercard:Movimiento
					vsCodigoCentral,		--Intercard:Movimiento
					vsfolio_reg				--se genera folio regulatorio
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
				 
				 
				 LET vsb_aplica = vsb_aplica;

				UPDATE BdiTarjeta:"informix".td_movimientos_conciliacion_mc
					SET codgironeg = vscodgironeg,
						b_aplica = vsb_aplica
					WHERE 	NumTarjeta = psNumtarjeta 
					AND Secuencia325 = psSecuencia325 
				AND Consecutivo = psConsecutivo;
				
				--   PROCESO NUEVO PARA IDENTIFICACION  -- agregar variables utilizadas proceso nuevo 
				
			ELSE

				LET vsErrorActividad = 'CONSECUTIVO ' || psConsecutivo || ' OCURRIO UN ERROR NO CONTROLADO AL EJECUTAR sp_buscar_mov_intercard_mc';

			END IF;

		ELIF ( psIntegridad IN ('F','P')) THEN
			/*CONCLUYE LA ETAPA DE CONCILIACION DEL REGISTRO*/

			/*SE DEBE MANTENER P EN CONCILIACION */
			LET vsConciliacion = 'P';
			
			UPDATE bditarjeta:"informix".td_movimientos_conciliacion_mc
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
END PROCEDURE;