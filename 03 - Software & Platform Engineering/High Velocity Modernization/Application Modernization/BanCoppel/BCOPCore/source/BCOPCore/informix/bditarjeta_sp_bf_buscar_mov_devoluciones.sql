CREATE PROCEDURE "informix".sp_bf_buscar_mov_devoluciones( psNumtarjeta CHAR(16), psSecuencia CHAR(6), pFechaInicioSorteo DATE)
    RETURNING VARCHAR (5) AS CODIGO_RETORNO, CHAR(1) AS vMovEncontrado;

	
    DEFINE CODIGO_RETORNO CHAR(5);
	DEFINE RUTA_ORIGEN VARCHAR(50);
    DEFINE viCodigo INTEGER;
	DEFINE vsNumtarjeta CHAR(16);
	DEFINE vsSecuenciaorig CHAR(6);
	DEFINE vMovEncontrado CHAR(1);
	
    
BEGIN
    ON EXCEPTION SET viCodigo
        LET CODIGO_RETORNO = viCodigo;
        RETURN CODIGO_RETORNO, NVL(vMovEncontrado,'');
    END EXCEPTION;
    
	LET CODIGO_RETORNO = '00000';
    LET RUTA_ORIGEN = '/resplogifx/';
    LET vMovEncontrado = '';	
	LET viCodigo = 0;
	LET vsNumtarjeta = '';
	LET vsSecuenciaorig = '';
	
    --SET DEBUG FILE TO RUTA_ORIGEN || 'sp_bf_buscar_mov_devoluciones.out';
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;    
    
    SELECT numtarjeta, secuenciaautarchivo
        INTO vsNumtarjeta, vsSecuenciaorig
    FROM bditarjeta:"informix".td_devolucionespos
    WHERE fecha >= pFechaInicioSorteo  --Se pone estas fechas como rango para validar devoluciones
        AND encontrado = 'V'
    AND estado  = 'A'
        AND aplicado = 'V'
    AND numtarjeta = psNumtarjeta
        AND secuenciaautarchivo = psSecuencia;
		
        ---El movimiento fue devuelto
		IF ( (vsNumtarjeta IS NOT NULL) OR ( TRIM (vsNumtarjeta) <> '')) 
                AND ( (vsSecuenciaorig IS NOT NULL) OR ( TRIM (vsSecuenciaorig) <> ''))  THEN			
			LET CODIGO_RETORNO = '00001';
			LET vMovEncontrado = 'V';
        ELSE
            LET CODIGO_RETORNO = '00000';
			LET vMovEncontrado = 'F';
		END IF;

        RETURN CODIGO_RETORNO, NVL(vMovEncontrado,'');
        
	END
END PROCEDURE
DOCUMENT
'AUTOR: Armando Garcia Ortiz',
'Proyecto: Sorteo El Buen Fin',
'Fecha de creación: 30.noviembre.2018',
'Fecha de modificación: 04.diciembre.2019',
'Descripcion: Busca los movimientos que fueron devueltos y en consecuencia no aplicaria el premio',
'Base de datos: bditarjeta'
;

CREATE PROCEDURE "informix".sp_bf_buscar_movintercard( 
    pFechaInicio DATETIME YEAR TO FRACTION(5), 
    pFechaTermino DATETIME YEAR TO FRACTION(5), 
    psNumtarjeta CHAR(16), psSecuencia CHAR(6))
RETURNING 
	CHAR(5) as Retorno,
	CHAR(7) as secuencia,
	CHAR(15) as secuencia_extendida,
	MONEY as montointercard,
	DATETIME YEAR TO FRACTION(5) as fechatransaccion,
	CHAR(12) as numrefintercard,
	CHAR(13) as numcuenta,
	CHAR(13) as statustarjeta,
	CHAR(23) as referencia23_325;


	DEFINE viCodigo INTEGER;
	DEFINE vssqlerr CHAR(5) ;
	DEFINE vsErrorActividad CHAR(250);
    DEFINE RUTA_ORIGEN VARCHAR(50);

	DEFINE vsNumtarjeta CHAR(16);
	DEFINE vsSecuenciaorig CHAR(7);
	DEFINE vsSecuencia_extendida CHAR(15);
	DEFINE vmMontointercard MONEY;
	DEFINE vdFechatransaccion DATETIME YEAR TO FRACTION(5);
	DEFINE vsnumrefintercard CHAR(16);
	DEFINE vsnumcuenta CHAR(13);
	DEFINE vsstatustarjeta CHAR(3);
	DEFINE vsreferencia23_325 char(23);
	DEFINE vsSecuencia CHAR(7);
	DEFINE vmmontoarchivo MONEY;
	
	BEGIN
		ON EXCEPTION SET viCodigo
            LET vssqlerr = viCodigo;
            RETURN vssqlerr, 
                NVL(vsSecuenciaorig,''), 
                NVL(vsSecuencia_extendida,''), 
                NVL(vmMontointercard,0),
                NVL(vdFechatransaccion,CAST('1900-01-01 12:00:00' as DATETIME YEAR TO FRACTION(5))), 
                NVL(vsnumrefintercard,''), 
                NVL(vsnumcuenta,''), 
                NVL(vsstatustarjeta,''),
                NVL(vsreferencia23_325,'');
        END EXCEPTION;
        
        LET viCodigo = 0;
        LET vssqlerr = '00000';
        LET vsErrorActividad = '';
        LET vsNumtarjeta = '';
        LET vsSecuenciaorig = '';
        LET vsSecuencia_extendida = '';
        LET vmMontointercard = 0;
        LET vdFechatransaccion = CAST('1900-01-01 12:00:00' as DATETIME YEAR TO FRACTION(5));
        LET vsnumrefintercard = '';
        LET vsnumcuenta = '';
        LET vsstatustarjeta = '';
        LET vsreferencia23_325 = '';
        
        -- Variables de entrada 
        LET vsSecuencia = '';
        LET vmmontoarchivo = 0;
        LET vsSecuencia = "1"||psSecuencia;        
        --LET RUTA_ORIGEN = '/ifxsif01/_argoz/buenfin/3A/basededatos/informix/bditarjeta/script/';
        LET RUTA_ORIGEN = '/resplogifx/';
		

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        --SET DEBUG FILE TO RUTA_ORIGEN || 'sp_bf_buscar_movintercard.out';
        --TRACE ON;

        EXECUTE PROCEDURE bditarjeta:"informix".sp_bf_info_tarjetas(pFechaInicio , pFechaTermino, psNumtarjeta, vsSecuencia)
            INTO vsNumtarjeta,vsSecuenciaorig, vsSecuencia_extendida, vmMontointercard,	vdFechatransaccion, vsnumrefintercard,	vsnumcuenta, vsstatustarjeta, vsreferencia23_325;
        
        IF ( (vsNumtarjeta IS NULL) OR ( TRIM (vsNumtarjeta) = '') ) THEN
            LET vssqlerr = '00001';
            LET vsErrorActividad = 'No hay informacion registrada con la tarjeta '||psNumtarjeta;
        END IF;

	
        RETURN vssqlerr, 
            NVL(vsSecuenciaorig,''), 
            NVL(vsSecuencia_extendida,''), 
            NVL(vmMontointercard,0),
            NVL(vdFechatransaccion,CAST('1900-01-01 12:00:00' as DATETIME YEAR TO FRACTION(5))), 
            NVL(vsnumrefintercard,''), 
            NVL(vsnumcuenta,''), 
            NVL(vsstatustarjeta,''),
            NVL(vsreferencia23_325,''); 
				
    END
    
END PROCEDURE
DOCUMENT
'AUTOR: Armando Garcia Ortiz',
'Proyecto: Sorteo El Buen Fin',
'Fecha de creacion: 30.noviembre.2018',
'Fecha de modificacion: 17.diciembre.2019',
'Descripcion: Busca el movimiento realizado por la tarjeta y secuencia relacionada con el archivo',
'Base de datos: bditarjeta'
;

CREATE PROCEDURE "informix".sp_bf_validar_integridad_datos_sat  (
    piconsecutivo INTEGER, pstarjeta CHAR(16), psmonto CHAR(12), 
        pssecuencia CHAR(6), psreferencia CHAR(12), psmontopremio CHAR(12), pIdRetailer CHAR(7)
)
RETURNING VARCHAR (5) as CODIGO_RETORNO, VARCHAR(250) as MENSAJE_RETORNO, 
                CHAR(1) as vsvalidacion, CHAR(16) as vNumeroTarjeta;

    DEFINE SQL_ERR INTEGER;
    DEFINE ISAM_ERR INTEGER;
    DEFINE ERROR_INFO VARCHAR(100);
    DEFINE CODIGO_RETORNO 	VARCHAR(5);
    DEFINE MENSAJE_RETORNO 	VARCHAR(250);	
    DEFINE RUTA_ORIGEN      VARCHAR(50);
    DEFINE vNumeroTarjeta   CHAR(16);
    DEFINE vsvalidacion	CHAR(1);
    DEFINE vstarjeta		CHAR(16);
    DEFINE vsmonto			CHAR(12);
    DEFINE vssecuencia		CHAR(6);
    DEFINE vsreferencia	CHAR(12);
    DEFINE vsmontopremio 	CHAR(12);
    DEFINE vsErrorIntegridad CHAR(40);
    DEFINE vsobservacion 	CHAR(250);
    DEFINE vsestarjeta		CHAR(1);
    DEFINE vsesmonto 		CHAR(1);
    DEFINE vsessecuencia 	CHAR(1);
    DEFINE vsesreferencia 	CHAR(1);
    DEFINE vsesmontopremio CHAR(1);
    DEFINE vIdRetailer CHAR(7);

BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET CODIGO_RETORNO   = SQL_ERR;
        LET MENSAJE_RETORNO  = vsErrorIntegridad;
        RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO, vsvalidacion, pstarjeta;

	END EXCEPTION;
	
    LET CODIGO_RETORNO = '00001'; --De manera predeterminada se maneja si existiera un error de integridad.
    LET MENSAJE_RETORNO = 'Integridad de datos correcta.';
    LET RUTA_ORIGEN = '/resplogifx/';
    LET vsvalidacion = 'F';
    
    --SET DEBUG FILE TO RUTA_ORIGEN || 'sp_bf_validar_integridad_datos_sat.out';
    --TRACE ON;

    --Inicializa las Variables de trabajo 
    LET	vstarjeta = pstarjeta;
    LET	vsmonto = psmonto;
    LET	vssecuencia	= pssecuencia;
    LET	vsreferencia = psreferencia;
    LET vsmontopremio = psmontopremio;
    LET vsErrorIntegridad = '';
    LET vsobservacion = '';
    LET vsestarjeta = '';
    LET	vsesmonto = '';
    LET	vsessecuencia = '';
    LET	vsesreferencia = '';
    LET vsesmontopremio = '';
    LET vIdRetailer = '';

	EXECUTE PROCEDURE bditarjeta:"informix".sp_esnumerico (vstarjeta) INTO vsestarjeta;
	EXECUTE PROCEDURE bditarjeta:"informix".sp_esnumerico (vsmonto) INTO vsesmonto;
	EXECUTE PROCEDURE bditarjeta:"informix".sp_esnumerico (vssecuencia) INTO vsessecuencia ;
	EXECUTE PROCEDURE bditarjeta:"informix".sp_esnumerico (vsreferencia) INTO vsesreferencia ;
	EXECUTE PROCEDURE bditarjeta:"informix".sp_esnumerico(vsmontopremio) INTO vsesmontopremio;
	EXECUTE PROCEDURE bditarjeta:"informix".sp_esnumerico(pIdRetailer) INTO vIdRetailer;
            
	IF LENGTH(vstarjeta)!=16 THEN			
			LET vsErrorIntegridad = 'Tamanio incorrecto de tarjeta';
			LET vsobservacion = 'ERROR DE INTEGRIDAD numtarjeta: DEBE SER IGUAL A 16 CARACTERES';
	ELIF (vsestarjeta = 'F') THEN			
			LET vsErrorIntegridad = 'Tarjeta no debe tener letras';
			LET vsobservacion = 'ERROR DE INTEGRIDAD monto: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';
	ELIF TRIM(NVL(vstarjeta,''))= '' THEN			
			LET vsErrorIntegridad = 'Num. Tarjeta no debe ser vacio';
			LET vsobservacion = 'ERROR DE INTEGRIDAD numtarjeta: NO DEBE ESTAR VACIO';
	ELIF vstarjeta = '0000000000000000' THEN			
			LET vsErrorIntegridad = 'Num. Tarjeta no debe ser igual a ceros';
			LET vsobservacion = 'ERROR DE INTEGRIDAD numtarjeta: NO DEBE TENER SOLO CEROS';
	ELIF LENGTH(vssecuencia)!=6 THEN			
			LET vsErrorIntegridad = 'Longuitud de secuencia incorrecto';
			LET vsobservacion = 'ERROR DE INTEGRIDAD secuencia: DEBE SER IGUAL A 6 CARACTERES';
	ELIF TRIM(NVL(vssecuencia,''))='' THEN			
			LET vsErrorIntegridad = 'La secuencia no debe ser vacia';
			LET vsobservacion = 'ERROR DE INTEGRIDAD secuencia: NO DEBE ESTAR VACIO';
	ELIF vssecuencia = '000000' THEN			
			LET vsErrorIntegridad = 'La secuencia no debe ser ceros';
			LET vsobservacion = 'ERROR DE INTEGRIDAD secuencia: NO DEBE TENER SOLO CEROS';
	ELIF TRIM(NVL(vsreferencia,''))='' THEN			
			LET vsErrorIntegridad = 'La secuencia no debe ser vacio';
			LET vsobservacion = 'ERROR DE INTEGRIDAD referencia: NO DEBE ESTAR VACIO';
	ELIF vssecuencia = '000000' THEN			
			LET vsErrorIntegridad = 'Secuencia no debe ser igual a ceros';
			LET vsobservacion = 'ERROR DE INTEGRIDAD referencia: NO DEBE TENER SOLO CEROS';
	ELIF (vsmonto = 0) THEN			
			LET vsErrorIntegridad = 'Monto debe ser mayor a cero';
			LET vsobservacion = 'ERROR DE INTEGRIDAD monto: EL IMPORTE DE TRANSACCION DEBE SER DIFERENTE DE CERO';
	ELIF (vsesmonto = 'F') THEN			
			LET vsErrorIntegridad = 'Valor de monto debe ser numerico';
			LET vsobservacion = 'ERROR DE INTEGRIDAD monto: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';
	ELIF (TRIM(vsmonto)='')	THEN			
			LET vsErrorIntegridad = 'Valor de monto no debe ser vacio';
			LET vsobservacion = 'ERROR DE INTEGRIDAD monto: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';
	ELIF (vsesmontopremio = 'F') THEN
			LET vsErrorIntegridad = 'Monto premio debe ser numerico';
			LET vsobservacion = 'ERROR DE INTEGRIDAD monto: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';
	ELIF (TRIM(vsmontopremio)='')	THEN			
			LET vsErrorIntegridad = 'Monto premio no puedes ser vacio';
			LET vsobservacion = 'ERROR DE INTEGRIDAD monto: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';    
    ELSE
        LET CODIGO_RETORNO = '00000';
        LET vsvalidacion = 'V';
        LET vsErrorIntegridad = 'Validacion Correcta';
	END IF;
	
    
	LET MENSAJE_RETORNO = vsErrorIntegridad;

	UPDATE bditarjeta:"informix".tbl_bf_sorteo_sat
        SET validaciones =  vsvalidacion, 
            observacion = 	vsErrorIntegridad
    WHERE consecutivo = piconsecutivo;
		
	RETURN 	CODIGO_RETORNO, NVL(MENSAJE_RETORNO,''), vsvalidacion, pstarjeta;
END
END PROCEDURE
DOCUMENT
'AUTOR: Armando Garcia Ortiz',
'Proyecto: Sorteo El Buen Fin',
'Fecha de creacion: 30.noviembre.2018',
'Fecha de creacion: 05.noviembre.2019',
'Descripcion: Validar el tipo de los datos previamente almacenados en la',
'tabla tbl_sorteo_sat y sus correspondientes campos',
'Base de datos: bditarjeta'
;

CREATE PROCEDURE "informix".sp_concreing_identificatipoconciliacion (
				psOriginalEncontrado 		CHAR(5),	--intercard:movimiento
				psConsecutivo 				INTEGER,
				psNumtarjeta 				CHAR(16),	--bditarjeta:td_movimientos_conciliacion
				psSecuencia325 				CHAR(6),	--bditarjeta:td_movimientos_conciliacion
				psMovconciliado 			CHAR(1),	--intercard:movimiento
				pmMontointercard 			MONEY,		--intercard:movimiento resultado de busca movimiento intercard
				pmMontointercardCashback 	MONEY, 		--intercard:movimiento resultado de busca movimiento intercard
				psMonto325 					CHAR(13),	--bditarjeta:td_movimientos_conciliacion  Monto325
				psMontoCashback325 			CHAR(13),   --bditarjeta:td_movimientos_conciliacion  MontoCashBack325
				pmSumaMonto325 				MONEY,		--bditarjeta:td_movimientos_conciliacion  Suma de monto325
				pmSumaMontoCashback325 		MONEY,		--bditarjeta:td_movimientos_conciliacion  Suma de montocashback325
				psTipotransaccion325 		CHAR(15),   --bditarjeta:td_movimientos_conciliacion
				psConciliacionArchivo 		CHAR(1),	--bditarjeta:td_archivo_origen
				psConciliacion 				CHAR(1),   	--bditarjeta:td_movimientos_conciliacion
				psSecuenciaorig 			CHAR(7),	--intercard:movimiento
				psSecuencia_extendida 		CHAR(15),	--intercard:movimiento
				pdFechatransaccion 			DATETIME YEAR TO FRACTION(5), 	--intercard:movimiento
				psInfreceptor 				CHAR(40),	--intercard:movimiento
				psIdterminal 				CHAR(16),	--intercard:movimiento
				psMetodocaptura 			CHAR(2),	--intercard:movimiento
				psMovreversado 				CHAR(1),	--intercard:movimiento
				psCodigoiso 				CHAR(2),	--intercard:movimiento
				psFormato 					CHAR(4),	--intercard:movimiento	
				piTipo_LayOut 				INTEGER,	--BdiTarjeta:Td_Archivo_OrigenTmp 
				psISO323 					CHAR(2),	--BdiTarjeta:Td_Movimientos_Conciliacion
				psMovRev325 				CHAR(1),	--BdiTarjeta:Td_Movimientos_Conciliacion
				psCodReversa 				CHAR(1),	--Intercard:Movimiento
				psCodigoCentral 			CHAR(5),	--Intercard:Movimiento
				ps_Txn_code 				CHAR(1),	--BdiTarjeta:Td_Movimientos_Conciliacion
				ps_Indicador_fastfounds 	CHAR(5) 	--BdiTarjeta:Td_Movimientos_Conciliacion
)

	RETURNING CHAR(5) AS Retorno,
	CHAR(1) AS Conciliacion,
	CHAR(7) AS Secuencia,
	CHAR(15) AS Secuencia_extendida,
	MONEY AS Montointercard,
	MONEY AS Montointercardcashback, -- Se agrega por integracion de Cash Back
	DATETIME YEAR TO FRACTION(5) AS FechaTransaccion,
	CHAR(40) AS Infreceptor,
	CHAR(16) AS Idterminal,
	CHAR(2) AS Metodocaptura,
	CHAR(1) AS Movconciliado,
	CHAR(1) AS Movreversado,
	CHAR(1) AS Tipo_mov,
	CHAR(16) AS Folio_mov,
	DATETIME YEAR TO FRACTION(5) AS Fechaconcilia,
	INTEGER AS Tipo_conciliacion,
	CHAR(60) AS Desc_conciliacion,
	CHAR(250) AS ErrorActividad;

	/*
	-- DESCRIPCION:  IDENTIFICA EL TIPO DE CONCILIACION  ------------------------------------------------
	-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
	-- FECHA : 20/06/2011  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Reingenieria de la conciliacion automatica / Validacion de Integridad  -----------------
	-- MODIFICADO: CASANOVA EDEZA HECTOR JUAN. 19/04/2012 	SE MODIFICA LA LOGICA PARA LA CLASIFICACION DE LAS TRANSACCIONES DE DEVOLUCIONES (21) PARA LOS TIPOS DE CONCILIACION 10,11 Y 12. SE AGREGA EL TIPO CONCILIACION 14.
	-- MODIFICADO: CASANOVA EDEZA HECTOR JUAN. 25/06/2012 	SE HACE NUEVAMENTE EL SP, OPTIMIZANDO EL PROCESO EN CUANTO A FUNCIONAMIENTO Y CLARIDAD DEL CODIGO
	-- MODIFICADO: CASANOVA EDEZA HECTOR JUAN. 01/10/2012   SE AJUSTA LA LOGICA PARA CLASIFICAR LAS TRANSACCIONES TIPO 20 EN LOS ARCHIVOS VIC(MONEYGRAM)
	*/

	/*DEFINICION DE VARIABLES*/

	/*VARIABLES DE ERRORES*/
	DEFINE visqlerr INTEGER ;
	DEFINE vssqlerr CHAR(5);
	DEFINE vsErrorActividad CHAR(250);
	DEFINE vsCodRetFecha CHAR(5);
	DEFINE vsFechaHora CHAR(8);
	DEFINE vmMonto325 MONEY;
	DEFINE vmMontoCashBack325 MONEY;

	/*VARIABLES DE RETORNO*/
	DEFINE vsConciliacion CHAR(1);
	DEFINE vdFechaTransaccion DATETIME YEAR TO FRACTION (5);
	DEFINE vsMovconciliado CHAR(1);
	DEFINE vsTipo_mov CHAR(1);
	DEFINE vsFolio_mov CHAR(16);
	DEFINE vdFechaconcilia DATETIME YEAR TO FRACTION (5);
	DEFINE viTipo_Conciliacion INTEGER;
	DEFINE vsDesc_conciliacion CHAR(60);
	
	/*VARIABLES DE ENTORNO*/
	DEFINE StatusTarjeta VARCHAR (3);
	DEFINE numcredito VARCHAR(13);
	DEFINE statuscred CHAR(2);
	DEFINE vsmensaje char(20);
	
	/*Monto Menor a */
	DEFINE vsMontoMenor INT;

--SET DEBUG FILE TO "/informix/LVRQ/debug/TraceIDENTIFICATIPO.out";
--TRACE ON;
	
	/*INICIALIZACION DE VARIABLES*/
	LET visqlerr = 0;
	LET vssqlerr = '00000' ;
	LET vsErrorActividad = '';
	LET vsCodRetFecha='';
	LET vsFechaHora = '';

	/*VARIABLES DE RETORNO*/
	LET vsConciliacion = 'V';  -- PARA TODOS
	LET psSecuenciaorig = NVL(psSecuenciaorig,'');
	LET psSecuencia_extendida = NVL(psSecuencia_extendida,'');
	LET vmMonto325 = ( ( REPLACE( psMonto325,'.',''))::MONEY /100 );
	LET vmMontoCashBack325 = ( ( REPLACE( psMontoCashback325,'.',''))::MONEY /100 ); -- Para integracion de CashBack
	LET pmMontointercard = NVL(pmMontointercard,'');
	LET pmMontointercardCashback = NVL (pmMontointercardCashback,'');
	LET vdFechaTransaccion = NVL(pdFechatransaccion,  CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5)));
	LET psInfreceptor = NVL(psInfreceptor,'');
	LET psIdterminal = NVL(psIdterminal,'');
	LET psMetodocaptura = NVL(psMetodocaptura,'');
	LET vsMovconciliado = NVL(psMovconciliado,'');
	LET psMovreversado = NVL(psMovreversado,'');
	LET vsTipo_mov = '';
	LET vsFolio_mov = '';
	LET vdFechaconcilia = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
	LET viTipo_Conciliacion = 0;
	LET vsDesc_conciliacion = '';
	LET psTipotransaccion325 = TRIM(NVL(psTipotransaccion325,''));

	/*VARIABLES DE ENTORNO*/
	LET StatusTarjeta = '';
	LET numcredito = '';
	LET statuscred = '';
	
	let vsmensaje = '';
	
	
		/*Monto Menor a */
	LET vsMontoMenor = 5000;

	BEGIN

		ON EXCEPTION SET visqlerr   --CACHA EL ERROR EN CASO DE QUE EXISTA Y REGRESA UN VALOR PREDETERMINADO

				LET vssqlerr = visqlerr;
				RETURN vssqlerr,
					NVL(vsConciliacion,''),
					NVL(psSecuenciaorig,''),
					NVL(psSecuencia_extendida,''),
					NVL(pmMontointercard,0),
					NVL(pmMontointercardCashback,0),
					NVL(vdFechaTransaccion,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
					NVL(psInfreceptor,''),
					NVL(psIdterminal,''),
					NVL(psMetodocaptura,''),
					NVL(vsMovconciliado,''),
					NVL(psMovreversado,''),
					NVL(vsTipo_mov,''),
					NVL(vsFolio_mov,''),
					NVL(vdFechaconcilia,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
					NVL(viTipo_Conciliacion,0),
					NVL(vsDesc_conciliacion,''),
					NVL(vsErrorActividad,'');

		END EXCEPTION;



		--------REINGENIERIA-CONCILIACION-AUTOMATICA---------
		--------2012/06/25-MGTI-HECTOR CASANOVA------------------


		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;

		LET vsConciliacion = 'V'; --TODOS V 
		LET vdFechaconcilia = (SELECT DBINFO('utc_to_datetime', Sh_Curtime)::DATETIME YEAR TO FRACTION(5) FROM SysMaster:"informix".Sysshmvals); 
		--SE REQUIERE SOLO UNA VEZ POR EJECUCION
		LET viTipo_Conciliacion = -2; --DEFAULT
	
		
		--IDENTIFICA TIPO DE LAYOUT PARA REALIZAR VALIDACIONES DE MOVIMIENTOS (POS O ATM)
		IF (piTipo_LayOut = 1) or (piTipo_LayOut = 6) THEN --POS POS325 (EGLOBAL, COPPEL)
			
			IF ((vmMonto325 > 0) and (vmMontoCashBack325 = 0)) then
			-- Para agregar validacion de estatus de credito
				IF (SUBSTR (psNumtarjeta, 1, 6 ) = '426807') then 
					
					
					SELECT FIRST 1 numcuenta INTO numcredito 
						FROM Intercard:Tarjetacuenta 
					WHERE NumTarjeta = psNumtarjeta; 
							
					
					
					SELECT FIRST 1 status_cred into statuscred
						FROM Bdicred:sd_maecred
					where 	empresa = '001' and 
							num_credito  = numcredito and
							status_cred =  'CV';
				END IF;

				IF 	( psConciliacionArchivo = 'F' ) THEN
					/* TIPO DE CONCILIACION = 0 */ --NO REQUIERE CONCILIACIÃÂÃÂ??N INTERCARD
					LET viTipo_Conciliacion = -1; -- ES TIPO 0, PARA FINES PRACTICOS, INTERNAMENTE ES -1, EN LA TABLA QUEDA COMO 0
				ELIF ( statuscred = 'CV' ) THEN 
					/* TIPO DE CONCILIACION = 16  */-- No se conciliacia por ser credito vendido
					LET viTipo_Conciliacion = 16;
				ELIF (( psOriginalEncontrado = '00000' ) AND ( LPAD(psCodigoiso,2,'0') != '00' )) THEN
					/* TIPO DE CONCILIACION = 9 */ --MOVIMIENTO ORIGINAL RECHAZADO
					LET viTipo_Conciliacion = 9; 
					
					--TRACE 'FAST FUNDS '|| ps_Txn_code ;
					--TRACE 'FAST FUNDS '|| ps_Indicador_fastfounds ;
					
				ELIF ((psOriginalEncontrado IN ('00400','00000')) AND ( psTipotransaccion325 = '20' ) 
					 AND (ps_Txn_code = '2') AND (ps_Indicador_fastfounds = 'Y')) THEN -- TRANSACCION DE FAST FUNDS (SOLO VID)
					/* TIPO DE CONCILIACION = 62 */ -- ABONO DE TRANSACCIÃÂÃÂN FAST FUNDS
					LET viTipo_Conciliacion = 62;
					LET vsMovconciliado = psMovconciliado;
					
				ELIF ((psOriginalEncontrado = '00400') AND ( psTipotransaccion325 = '20' )) THEN --ORIGINAL NO ENCONTRADO + ABONO DE MONEYGRAM (SOLO VID)
					/* TIPO DE CONCILIACION = 0 */ --NO REQUIERE CONCILIACIÃÂÃÂ??N INTERCARD  ABONO DE MONEYGRAM (SOLO VID)
					LET viTipo_Conciliacion = 0;
				ELIF (( psOriginalEncontrado = '00400' )  AND ( psTipotransaccion325 IN ('01','02'))) THEN  /*MOVIMIENTO NO ENCONTRADO EN INTERCARD CON LA TARJETA Y SECUENCIA DEL REGISTRO 325*/
					/* TIPO DE CONCILIACION = 8 */ --FORZADO (SIN MOVIMIENTO EN INTERCARD)
					LET viTipo_Conciliacion = 8;
				ELIF (( psOriginalEncontrado = '00400') AND ( psTipotransaccion325 = '21' ) AND (vmMonto325 <= vsMontoMenor )) THEN -- DEVOLUCION CON MONTO MENOR NO ENCONTRADA EN INTERCARD
					/* TIPO DE CONCILIACION = 11 */ --DEVOLUCION FORZADA -- MONTO MENOR a 1000 pesos
					LET viTipo_Conciliacion = 11;
				ELIF (( psOriginalEncontrado = '00400') AND ( psTipotransaccion325 = '21' ) AND (vmMonto325 <= vsMontoMenor )
						AND (TRIM(psSecuencia325) IN ('','000000','111111','222222','333333','444444','555555','666666','','888888','999999'))) THEN -- DEVOLUCION CON MONTO MENOR NO ENCONTRADA EN INTERCARD
					/* TIPO DE CONCILIACION = 11 */ --DEVOLUCION FORZADA -- MONTO MENOR a 1000 pesos
					LET viTipo_Conciliacion = 11; 					
				ELIF ((psTipotransaccion325 = '21') AND ((psOriginalEncontrado = '00400')  --ORIGINAL NO ENCONTRADO
					OR (TRIM(psSecuencia325) IN ('','000000','111111','222222','333333','444444','555555','666666','777777','888888','999999')))  -- RECHAZADO POR NUMERO REPETIDOS O EN BLANCO
						) THEN
					/* TIPO DE CONCILIACION = 12 */	--DEVOLUCIÃÂÃÂ??N NO APLICADA
					LET viTipo_Conciliacion = 12; 
				ELIF (( psMovreversado = 'V' ) AND ( NVL (psFormato,'') = '0220' ) AND ( psTipotransaccion325 IN ( '01', '02' ) ) ) THEN
					/* TIPO DE CONCILIACION = 13 */ --FORZADO INTERCARD
					LET viTipo_Conciliacion = 13; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF ( ( psMovreversado = 'V' ) AND ( NVL (psFormato,'') = '0420' )	AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN
					/* TIPO DE CONCILIACION = 7 */ --MOVIMIENTO ORIGINAL REVERSADO
					LET viTipo_Conciliacion = 7; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF ( ( psMovconciliado = 'V')  AND ( psTipotransaccion325 IN ( '01','02')  OR 
					psTipotransaccion325 MATCHES('RETIRO*') OR  psTipotransaccion325 MATCHES('CONSULTA*') OR psTipotransaccion325 MATCHES('CAMB_NIP*') ) ) THEN
					/* TIPO DE CONCILIACION = 6 */ --MOVIMIENTO PREVIAMENTE CONCILIADO
					LET viTipo_Conciliacion = 6; 
					LET vsMovconciliado = psMovconciliado; 
				ELIF (( ( psMovconciliado = 'F') AND ( pmMontointercard = vmMonto325 ) AND ( psTipotransaccion325 IN ('01','02')))
					OR (psTipotransaccion325 MATCHES('RETIRO*') OR  psTipotransaccion325 MATCHES('CONSULTA*') OR psTipotransaccion325 MATCHES('CAMB_NIP*')) ) THEN
					/* TIPO DE CONCILIACION = 1 */ --CONCILIACIÃÂÃÂ??N INTERCARD
					LET viTipo_Conciliacion = 1; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF ( ( psMovconciliado = 'P' ) AND ( vmMonto325 < pmMontointercard ) AND ( pmSumaMonto325 < pmMontointercard )
					AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN  
					/* TIPO DE CONCILIACION = 3 */ --CONCILIADO CON MONTO MENOR    --PARCIALES INCOMPLETOS
					LET viTipo_Conciliacion = 3; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF ( ( psMovconciliado = 'P' ) AND ( vmMonto325 < pmMontointercard ) AND ( pmSumaMonto325 >= pmMontointercard ) AND ( psTipotransaccion325 IN ( '01','02') ) ) THEN
					/* TIPO DE CONCILIACION = 4 */ --CONCILIADO CON MONTO MENOR    --PARCIALES COMPLETOS
					LET viTipo_Conciliacion = 4; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF ( ( psMovconciliado = 'F') AND ( vmMonto325 < pmMontointercard )  AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN
					/* TIPO DE CONCILIACION = 2 */ --CONCILIADO CON MONTO MENOR
					LET viTipo_Conciliacion = 2; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF ( ( psMovconciliado = 'F') AND ( vmMonto325 > pmMontointercard ) AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN
					/* TIPO DE CONCILIACION = 5 */ --CONCILIADO CON MONTO MAYOR
					LET viTipo_Conciliacion = 5; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF ( ((psOriginalEncontrado = '00000') AND ( psTipotransaccion325 = '21' ) AND (psMovconciliado <> 'V')) --MOVIMIENTO NO CONCILIADO
					OR ((psOriginalEncontrado = '00000') AND (vmMonto325 > pmMontointercard)) -- DEVOLUCION CON MONTO MAYOR AL ORIGINAL
					) THEN
					/* TIPO DE CONCILIACION = 10 */ --DEVOLUCIÃÂÃÂ??N CONCILIADA INTERCARD
					LET viTipo_Conciliacion = 10; 
					LET vsMovconciliado = psMovconciliado; 
				ELIF (( psOriginalEncontrado = '00000' ) AND ( psTipotransaccion325 = '21' ) AND (vmMonto325 < pmMontointercard) ) THEN -- DEVOLUCION CON MONTO MENOR AL ORIGINAL
					/* TIPO DE CONCILIACION = 11 */ --DEVOLUCION FORZADA -- MONTO MENOR en intercard
					LET viTipo_Conciliacion = 11; 
				ELIF (( psOriginalEncontrado = '00000' ) AND ( psTipotransaccion325 = '21' ) AND (vmMonto325 = pmMontointercard) AND (psMovconciliado = 'V') ) THEN -- DEVOLUCION CON MONTO IGUAL AL ORIGINAL
					/* TIPO DE CONCILIACION = 14 */ --DEVOLUCIÃÂÃÂ??N APLICADA
					LET viTipo_Conciliacion = 14; 
				ELSE -- ERROR
					--MOV NO CONCUERDA CON NINGUN TIPO
					LET viTipo_Conciliacion = 0; 
				END IF;
			
-- Para combinaciones de CashBack
			ELIF ((vmMonto325 = 0) and (vmMontoCashBack325 > 0)) then
			
				IF 	( psConciliacionArchivo = 'F' ) THEN
					/* TIPO DE CONCILIACION = 0 */ --NO REQUIERE CONCILIACIÃÂÃÂ??N INTERCARD
					LET viTipo_Conciliacion = -1; -- ES TIPO 0, PARA FINES PRACTICOS, INTERNAMENTE ES -1, EN LA TABLA QUEDA COMO 0
				ELIF ( ( psOriginalEncontrado = '00400' )  AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN  /*MOVIMIENTO NO ENCONTRADO EN INTERCARD CON LA TARJETA Y SECUENCIA DEL REGISTRO 325*/
					/* TIPO DE CONCILIACION = 28 */ --FORZADO (SIN MOVIMIENTO EN INTERCARD)
					LET viTipo_Conciliacion = 28; 
				ELIF ( (( psMovconciliado = 'F') OR (psMovconciliado = 'V'))  AND 
						( pmMontointercardCashback = vmMontoCashBack325) AND ( psTipotransaccion325 IN ('01','02'))) THEN
					/* TIPO DE CONCILIACION = 20 */ --CONCILIACIÃÂÃÂ??N INTERCARD CERO CON CASH BACK CORRECTO
					LET viTipo_Conciliacion = 20; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF (( psMovconciliado = 'P' ) AND ( vmMontoCashBack325 < pmMontointercardCashback ) AND (pmSumaMontoCashback325 < pmMontointercardCashback)
					AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN  
					/* TIPO DE CONCILIACION = 21 */ --CONCILIADO CON MONTO CASHBACK MENOR
					LET viTipo_Conciliacion = 21; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF (( psMovconciliado = 'P' ) AND ( vmMontoCashBack325 < pmMontointercardCashback ) AND (pmSumaMontoCashback325 >= pmMontointercardCashback)
					AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN  
					/* TIPO DE CONCILIACION = 22 */ --CONCILIADO CON MONTO325 MENOR Y MONTO CASHBACK MENOR Y COMPLETO
					LET viTipo_Conciliacion = 22; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF ((( psMovconciliado = 'F') OR ( psMovconciliado = 'V'))  AND ( vmMontoCashBack325 < pmMontointercardCashback )
					AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN
					/* TIPO DE CONCILIACION = 23 */ --CONCILIADO CON MONTO MENOR
					LET viTipo_Conciliacion = 23; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF ((( psMovconciliado = 'F') OR ( psMovconciliado = 'V'))  AND ( vmMontoCashBack325 > pmMontointercardCashback )
					AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN
					/* TIPO DE CONCILIACION = 24 */ --CONCILIADO CON MONTOS MAYORES
					LET viTipo_Conciliacion = 24; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELSE -- ERROR
					--MOV NO CONCUERDA CON NINGUN TIPO
					LET viTipo_Conciliacion = 0; 
				END IF;

			ELIF ((vmMonto325 > 0) and (vmMontoCashBack325 > 0)) then
				IF 	( psConciliacionArchivo = 'F' ) THEN
					/* TIPO DE CONCILIACION = 0 */ --NO REQUIERE CONCILIACIÃÂÃÂ??N INTERCARD
					LET viTipo_Conciliacion = -1; -- ES TIPO 0, PARA FINES PRACTICOS, INTERNAMENTE ES -1, EN LA TABLA QUEDA COMO 0
				ELIF (( psOriginalEncontrado = '00000' ) AND ( LPAD(psCodigoiso,2,'0') != '00' )) THEN
					/* TIPO DE CONCILIACION = 30 */ --MOVIMIENTO ORIGINAL RECHAZADO EN INTERCARD CON CASHBACK
					LET viTipo_Conciliacion = 30; 
				ELIF ( ( psOriginalEncontrado = '00400' )  AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN  /*MOVIMIENTO NO ENCONTRADO EN INTERCARD CON LA TARJETA Y SECUENCIA DEL REGISTRO 325*/
					/* TIPO DE CONCILIACION = 31 */ --FORZADO CON CASH BACK (SIN MOVIMIENTO EN INTERCARD)
					LET viTipo_Conciliacion = 31; 
				ELIF ((psTipotransaccion325 = '21' )-- FALTA DEFINIR TRANSACCION 
					AND ((psOriginalEncontrado = '00400')  --ORIGINAL NO ENCONTRADO
					OR (TRIM(psSecuencia325) IN ('','000000','111111','222222','333333','444444','555555','666666','777777','888888','999999')))  -- RECHAZADO POR NUMERO REPETIDOS O EN BLANCO
						) THEN
					/* TIPO DE CONCILIACION = 32 */	--DEVOLUCIÃÂÃÂ??N NO APLICADA CON CASH BACK
					LET viTipo_Conciliacion = 32; 
				ELIF (( psMovreversado = 'V' ) AND ( NVL (psFormato,'') = '0220' ) AND ( psTipotransaccion325 IN ( '21' ) ) ) THEN
					/* TIPO DE CONCILIACION = 33 */ --FORZADO INTERCARD CON CASH BACK
					LET viTipo_Conciliacion = 33; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF (( psMovreversado = 'V' ) AND (NVL (psFormato,'') = '0420' )	AND (psTipotransaccion325 IN ( '01','02' ) ) ) THEN
					/* TIPO DE CONCILIACION = 34 */ --MOVIMIENTO ORIGINAL REVERSADO CON CASH BACK
					LET viTipo_Conciliacion = 34; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF (( psMovconciliado = 'V')  AND ( psTipotransaccion325 IN ( '01','02')  OR 
					psTipotransaccion325 MATCHES('RETIRO*') OR  psTipotransaccion325 MATCHES('CONSULTA*') OR psTipotransaccion325 MATCHES('CAMB_NIP*') ) ) THEN
					/* TIPO DE CONCILIACION = 35 */ --MOVIMIENTO PREVIAMENTE CONCILIADO CON CASH BACK
					LET viTipo_Conciliacion = 35; 
					LET vsMovconciliado = psMovconciliado; 
				ELIF ( ( psMovconciliado = 'F') AND ( pmMontointercard = vmMonto325 ) AND 
						(pmMontointercardCashback = vmMontoCashBack325) AND ( psTipotransaccion325 IN ('01','02'))) THEN
					/* TIPO DE CONCILIACION = 36 */ --CONCILIACIÃÂÃÂ??N INTERCARD CON CASH BACK
					LET viTipo_Conciliacion = 36; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF (( psMovconciliado = 'P') AND (vmMonto325 < pmMontointercard) AND (pmSumaMonto325 < pmMontointercard)
					AND (vmMontoCashBack325 < pmMontointercardCashback) AND (pmSumaMontoCashback325 < pmMontointercardCashback)
					AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN  
					/* TIPO DE CONCILIACION = 37 */ --CONCILIADO CON MONTOS MENORES
					LET viTipo_Conciliacion = 37; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF (( psMovconciliado = 'P' ) AND ( vmMonto325 < pmMontointercard ) AND ( pmSumaMonto325 < pmMontointercard )
					AND ( vmMontoCashBack325 < pmMontointercardCashback ) AND (pmSumaMontoCashback325 >= pmMontointercardCashback)
					AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN  
					/* TIPO DE CONCILIACION = 38 */ --CONCILIADO CON MONTO325 MENOR Y MONTO CASHBACK MENOR Y COMPLETO
					LET viTipo_Conciliacion = 38; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF ( ( psMovconciliado = 'P' ) AND ( vmMonto325 < pmMontointercard ) AND ( pmSumaMonto325 >= pmMontointercard )
					AND ( vmMontoCashBack325 < pmMontointercardCashback ) AND (pmSumaMontoCashback325 < pmMontointercardCashback)
					AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN  
					/* TIPO DE CONCILIACION = 39 */ --CONCILIADO CON MONTO325 CORRECTO Y MONTO CASHBACK MENOR
					LET viTipo_Conciliacion = 39;
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF ( ( psMovconciliado = 'P' ) AND ( vmMonto325 < pmMontointercard ) AND ( pmSumaMonto325 >= pmMontointercard )
					AND ( vmMontoCashBack325 < pmMontointercardCashback ) AND (pmSumaMontoCashback325 >= pmMontointercardCashback)
					AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN  
					/* TIPO DE CONCILIACION = 40 */ --CONCILIADO CON MONTOS MENORES y SUMAS COMPLETAS 
					LET viTipo_Conciliacion = 40; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF (( psMovconciliado = 'F') AND ( vmMonto325 < pmMontointercard )  AND ( vmMontoCashBack325 < pmMontointercardCashback )
					AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN
					/* TIPO DE CONCILIACION = 41 */ --CONCILIADO CON MONTO MENOR
					LET viTipo_Conciliacion = 41; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF ( ( psMovconciliado = 'F') AND ( vmMonto325 < pmMontointercard )  AND ( vmMontoCashBack325 = pmMontointercardCashback )
					AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN
					/* TIPO DE CONCILIACION = 42 */ --CONCILIADO CON MONTO325 MENOR y cash back correcto
					LET viTipo_Conciliacion = 42; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF (( psMovconciliado = 'F') AND (vmMonto325 = pmMontointercard )  AND ( vmMontoCashBack325 < pmMontointercardCashback )
					AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN
					/* TIPO DE CONCILIACION = 43 */ --CONCILIADO CON MONTO325 CORRECTO Y CASH BACK MENOR
					LET viTipo_Conciliacion = 43; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF ( ( psMovconciliado = 'F') AND ( vmMonto325 > pmMontointercard )  AND ( vmMontoCashBack325 > pmMontointercardCashback )
					AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN
					/* TIPO DE CONCILIACION = 44 */ --CONCILIADO CON MONTOS MAYORES
					LET viTipo_Conciliacion = 44; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF ( ( psMovconciliado = 'F') AND ( vmMonto325 > pmMontointercard )  AND ( vmMontoCashBack325 = pmMontointercardCashback )
					AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN
					/* TIPO DE CONCILIACION = 45 */ --CONCILIADO CON MONTO325 MAYOR Y CASH IGUAL
					LET viTipo_Conciliacion = 45; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF ( ( psMovconciliado = 'F') AND ( vmMonto325 = pmMontointercard )  AND ( vmMontoCashBack325 > pmMontointercardCashback )
					AND ( psTipotransaccion325 IN ( '01','02' ) ) ) THEN
					/* TIPO DE CONCILIACION = 46 */ --CONCILIADO CON MONTO325 IGUAL Y CASH IGUAL MAYOR
					LET viTipo_Conciliacion = 46; 
					LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				ELIF ( ((psOriginalEncontrado = '00000') AND ( psTipotransaccion325 = '21' ) AND (psMovconciliado <> 'V')) --MOVIMIENTO NO CONCILIADO
					OR ((psOriginalEncontrado = '00000') AND (vmMonto325 > pmMontointercard) AND ( vmMontoCashBack325 > pmMontointercardCashback )) -- DEVOLUCION CON MONTO MAYOR AL ORIGINAL
					) THEN
					/* TIPO DE CONCILIACION = 47 */ --DEVOLUCIÃÂÃÂ??N CONCILIADA INTERCARD
					LET viTipo_Conciliacion = 47; 
					LET vsMovconciliado = psMovconciliado; 
				ELIF (( psOriginalEncontrado = '00000' ) AND ( psTipotransaccion325 = '21' ) AND (vmMonto325 < pmMontointercard) 
						AND ( vmMontoCashBack325 < pmMontointercardCashback )) THEN -- DEVOLUCION CON MONTO MENOR AL ORIGINAL
					/* TIPO DE CONCILIACION = 48 */ --DEVOLUCIÃÂÃÂ??N FORZADA -- MONTO MENOR
					LET viTipo_Conciliacion = 48; 
				ELIF (( psOriginalEncontrado = '00000' ) AND ( psTipotransaccion325 = '21' ) AND (vmMonto325 = pmMontointercard)
						AND ( vmMontoCashBack325 = pmMontointercardCashback ) AND (psMovconciliado = 'V') ) THEN -- DEVOLUCION CON MONTO IGUAL AL ORIGINAL
					/* TIPO DE CONCILIACION = 49 */ --DEVOLUCIÃÂÃÂ??N APLICADA
					LET viTipo_Conciliacion = 49; 
				ELSE -- ERROR
					--MOV NO CONCUERDA CON NINGUN TIPO
					LET viTipo_Conciliacion = 0; 
				END IF;
			END IF;

		ELIF (piTipo_LayOut IN (2,3,7)) THEN --ATM  STAT07 (2- EGLOBAL, 3-PROSA) LVRQ se agrega layout 7
			
			
			
			--OBTIENE EL ESTATUS DE LA TARJETA
			SELECT FIRST 1 CodStatusTarjeta INTO StatusTarjeta FROM Intercard:Tarjeta WHERE NumTarjeta = psNumtarjeta; 
			
			IF (psOriginalEncontrado <> '00000') THEN -- 
				/* TIPO DE CONCILIACION = 52 */ --ATM NO ENCONTRADO EN INTERCARD
				LET viTipo_Conciliacion = 52; 
				
			ELIF (StatusTarjeta IN ('BLO', 'CAN', 'DES', 'EXT', 'INA', 'ROB') ) THEN --
				/* TIPO DE CONCILIACION = 53 */ --ATM NO CONCILIADA POR IMPROCEDENTE (ESTATUS DE TARJETA)
				--NO CONCILIADA POR BLOQUEO O CANCELACION
				LET viTipo_Conciliacion = 53; 
				
			ELIF (psMovconciliado = 'V') THEN --
				/* TIPO DE CONCILIACION = 54 */ --ATM CONCILIACION CORRECTA (MOVIMINETO PREVIAMENTE CONCILIADO)
				LET viTipo_Conciliacion = 54; 
				
			ELIF (psMovRev325 = 'T') THEN --
				/* TIPO DE CONCILIACION = 55 */ --ATM REVERSA TOTAL
				LET viTipo_Conciliacion = 55; 
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				
			ELIF (psMovRev325 = 'P') THEN --
				/* TIPO DE CONCILIACION = 56 */ --ATM REVERSA PARCIAL
				LET viTipo_Conciliacion = 56; 
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				
			ELIF ((psISO323 = psCodigoiso) AND (psISO323 <> '00') AND (psCodigoCentral <> '00000')) THEN --
				--CONCILIADA CORRECTA RECHAZADA POR AMBOS
				--CONCILIADA CORRECTA (CONSULTA RECHAZADA)
				--CONCILIADA CORRECTA (CAMBIO DE NIP FALLIDO)
				/* TIPO DE CONCILIACION = 57 */ --ATM CONCILIADA CORRECTA (RECHAZADA POR AMBOS)
				LET viTipo_Conciliacion = 57; 
				
			ELIF ((psISO323 <> '00') OR (psCodigoiso <> '00') OR (psCodigoCentral <> '00000')) THEN --
				--SE PUEDE UNIR CON LA VALIDACION ANTERIOR ATRAPARIA TODAS LAS OERACIONES CON ISO Y/O ISO 325 DIFERENTE DE 00
				--NO CONCILIADA POR IMPROCEDENTE
				--NO CONCILIADA POR IMPROCEDENTE (PROSA SI INTERCARD NO)
				--CONCILIADA CORRECTA (CONSULTA RECHAZADA)
				--CONCILIADA CORRECTA (CAMBIO DE NIP FALLIDO)
				/* TIPO DE CONCILIACION = 58 */ --ATM NO CONCILIADA POR IMPROCEDENTE
				LET viTipo_Conciliacion = 58; 
				
			ELIF (psMovreversado = 'V') THEN--
				--MOVIMIENTO ATM ORIGINAL REVERSADO
				/* TIPO DE CONCILIACION = 59 */ --ATM MOVIMIENTO ORIGINAL REVERSADO
				LET viTipo_Conciliacion = 59; 
				
			ELIF ((psTipotransaccion325 MATCHES('CONSULTA*')) AND (psCodigoiso = '00')) THEN --
				--CONCILIADA CORRECTA (CONSULTA APROBADA)
				/* TIPO DE CONCILIACION = 60 */ --ATM CONCILIADA CORRECTA (CONSULTA APROBADA)
				LET viTipo_Conciliacion = 60; 
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				
			ELIF ((psTipotransaccion325 MATCHES('CAMBIO*')) AND (psCodigoiso = '00')) THEN --
				--CONCILIADA CORRECTA (CAMBIO DE NIP EXITOSO)
				/* TIPO DE CONCILIACION = 61 */ --ATM CONCILIADA CORRECTA (CAMBIO DE NIP EXITOSO)
				LET viTipo_Conciliacion = 61; 
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				
			ELIF ((psTipotransaccion325 MATCHES('RETIRO*')) AND (vmMonto325 <> pmMontointercard)) THEN -- 
				--CONCILIADA CON DIFERENCIA DE MONTOS
				/* TIPO DE CONCILIACION = 51 */ --ATM CONCILIADA CON DIFERENCIA DE MONTOS
				LET viTipo_Conciliacion = 51; 
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				
			ELIF ((psTipotransaccion325 MATCHES('RETIRO*')) AND (vmMonto325 = pmMontointercard)) THEN --
				--CONCILIADA CORRECTA (MONTOS IGUALES)
				/* TIPO DE CONCILIACION = 50 */ --ATM CONCILIADA CORRECTA (MONTOS IGUALES)
				LET viTipo_Conciliacion = 50; 
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				
			ELSE --ERROR
				--MOV NO CONCUERDA CON NINGUN TIPO
				LET viTipo_Conciliacion = 0; 
				
			END IF;
			
		END IF;
		
		
		--MENSAJE DE RASTREO
		LET vsErrorActividad  = 'CONSECUTIVO ' || psConsecutivo || ' SE DETECTO EL TIPO CONCILIACION ' || DECODE (viTipo_Conciliacion, -1, 0, viTipo_Conciliacion);
		
		

		--OBTIENE LA DESCRIPCION DEL TIPO DE CONCILIACION 
		SELECT FIRST 1 Desc_Conciliacion INTO vsDesc_Conciliacion FROM BdiTarjeta:"informix".td_Tipo_Conciliacion WHERE Tipo_Conciliacion = viTipo_Conciliacion;

		
		IF (viTipo_Conciliacion IN (8, 11, 12, 14,26,27,31,32,48,49 )) THEN --TIPOS DE CONCILIACION QUE RECALCULAN EL FOLIO_MOV
			-- 8, 11, 12, 14 Conciliacion Norma sin CashBack
			-- 26,27         Conciliacion con CashBack y monto325 en 0
			-- 31,32,48,49	 COnciliaciÃÂÃÂ?ÃÂÃÂÃÂÃÂ³n con CashBack y monto325 mayores a 0
			
			--OBTIENE LA FECHA EN FORMATO ESPECIAL
			EXECUTE PROCEDURE BdiTarjeta:"informix".sp_Concreing_ObtenerFechauHora('15','')	INTO vsCodRetFecha, vsFechaHora;

			IF (vsCodRetFecha = '00000') THEN

				LET vsFolio_mov = 'i' || TRIM(vsFechaHora) || '2' || psSecuencia325;
			ELSE
				/*ERROR AL OBTENER LA FECHA U HORA*/
				LET vssqlerr = '00451';
				LET vsErrorActividad  = 'CONSECUTIVO ' || psConsecutivo || ' ERROR AL OBTENER LA FECHA PROCESO IDENTIFICARTIPOCONCILIACION';
			END IF;
			
		ELSE -- FOLIO_MOV ORIGINAL DE INTERCARD
			-- -1,0,1,2,3,4,5,7,,9,10,13
			LET vsFolio_mov = 'i' || psSecuencia_extendida; 
		END IF;
	

		IF ((viTipo_Conciliacion IN (1,2,3,4,5,7,13)) --POS
			OR (viTipo_Conciliacion IN (36,41,42,43,37,38,39,40,44,45,46,34,33)) --POS CON MONTO325 Y CASHBACK MAYORES A CERO
			OR (viTipo_Conciliacion IN (20,23,21,22,24,26)) --POS CON MONTO325 EN CERO Y CASHBACK MAYOR A CERO
			OR (viTipo_Conciliacion IN (50,51,55,56,57,60,61)) --ATM
			OR (viTipo_Conciliacion IN (62)) -- FAST FUNDS
		) THEN --TIPOS DE CONCILIACION QUE ACTUALIZAN EN REGISTRO ORIGINAL DE INTERCARD
		
			
			--ACTUALIZA EL MOVIMIENTO DE INTERCARD 
			UPDATE Intercard:"informix".Movimiento
			SET MovConciliado = (CASE 
				WHEN (viTipo_Conciliacion IN (2,3,21,23,41,42,43,37,38,39)) THEN 'P' --COMPRAS FRACCIONADAS QUEDAN PENDIENTES[P]
				WHEN (viTipo_Conciliacion IN (1,4,5,7,13,20,22,24,26,27,33,34,36,44,45,46)) THEN 'V' -- COMPRAS NORMALES CONCILIADO [V]
				WHEN (viTipo_Conciliacion IN (50,51,55,56,57,60,61)) THEN 'V' -- ATM CONCILIADO [V]
				WHEN (viTipo_Conciliacion IN (62)) THEN 'V' -- FAST FUNDS CONCILIADO [V]
				ELSE MovConciliado END) --DEFAULT
			--WHERE NumTarjeta = psNumtarjeta AND secuenciaextendida = psSecuencia_extendida ;-- ANTES 
			WHERE NumTarjeta = psNumtarjeta AND secuencia= "1" || psSecuencia325 AND codigoiso = '00'; -- modificacion

		END IF;
		
		IF 	(psTipotransaccion325 IN ('20','21')) THEN  --TRANSACCIONES DE ABONO
			LET vsTipo_mov = 'A'; -- ABONOS [A]
			--ACTUALIZACION PARA TIPOS 0, 10, 11, 12 Y 14
			UPDATE BdiTarjeta:"informix".td_Movimientos_Conciliacion  --12
			SET Tipo_Conciliacion = viTipo_Conciliacion, 
			Desc_Conciliacion = vsDesc_conciliacion, 
			Conciliacion = vsConciliacion, --BANDERA DE QUE FUE TRABAJADO
			FechaConcilia = vdFechaconcilia,
			Folio_Mov = DECODE (psTipotransaccion325, '20', Folio_Mov, vsFolio_mov), --psTipotransaccion325 20 (PNC) NO REQUIEREN ESTE CAMPO.
			Tipo_Mov = vsTipo_mov -- ABONOS [A]
			WHERE NumTarjeta = psNumtarjeta AND Secuencia325 = psSecuencia325 AND Consecutivo = psConsecutivo;
		
		ELSE --TRANSACCIONES DE COMPRA
		
			if viTipo_Conciliacion = 5 then
				let vsmensaje = 'Por monto mayor';
			elif viTipo_Conciliacion = 8  then
				let vsmensaje = 'Aut sin localizar';
			elif viTipo_Conciliacion = 28  then
				let vsmensaje = 'Aut sin localizar CB';
			elif viTipo_Conciliacion = 31  then
				let vsmensaje = 'Aut sin localizar CA';
			else 
				let vsmensaje = '';
			end if;
				
			--ATM ????
			LET vsTipo_mov = 'C'; -- CARGOS [C]
			
			--ACTUALIZACION PARA TIPOS -1, 2, 3, 4, 5, 6, 7, 8, 9 Y 13 [POS]
			--ACTUALIZACION PARA TIPOS -50, 51, 52, 53, 54, 55, 56, 57, 59, 60, 61 [ATM]
			UPDATE BdiTarjeta:"informix".td_Movimientos_Conciliacion
			SET Tipo_Conciliacion = DECODE (viTipo_Conciliacion, -1, 0, viTipo_Conciliacion), --REEMPLAZA EL TIPO -1 POR UN 0 Y DEJA LOS DEMAS TIPOS IGUAL
			Desc_Conciliacion = vsDesc_conciliacion, 
			Conciliacion = vsConciliacion, --BANDERA DE QUE FUE TRABAJADO
			FechaConcilia = vdFechaconcilia,
			Folio_Mov = vsFolio_mov, 
			Tipo_Mov = vsTipo_mov,  -- CARGOS [C]
			Secuencia = psSecuenciaorig, 
			Secuencia_extendida = psSecuencia_extendida, 
			MontoIntercard = pmMontointercard,
			montocashback = pmMontointercardCashback,
			FechaTransaccion = pdFechatransaccion, 
			InfReceptor = psInfreceptor, 
			IdTerminal = psIdterminal,
			MetodoCaptura = psMetodocaptura, 
			MovConciliado = vsMovconciliado, --- puede cambiar ok
			MovReversado = psMovreversado,
			integridad_error = vsmensaje  -- Pone mensaje de tipo de CNC
			WHERE NumTarjeta = psNumtarjeta AND Secuencia325 = psSecuencia325 AND Consecutivo = psConsecutivo;
			
		END IF;


			/*RETORNO DEL PROCEDIMIENTO ALMACENADO*/
		RETURN vssqlerr,
			NVL(vsConciliacion,''),
			NVL(psSecuenciaorig,''),
			NVL(psSecuencia_extendida,''),
			NVL(pmMontointercard,0),
			NVL(pmMontointercardCashback,0),	-- Integracion de CashBack
			NVL(vdFechaTransaccion,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
			NVL(psInfreceptor,''),
			NVL(psIdterminal,''),
			NVL(psMetodocaptura,''),
			NVL(vsMovconciliado,''),
			NVL(psMovreversado,''),
			NVL(vsTipo_mov,''),
			NVL(vsFolio_mov,''),
			NVL(vdFechaconcilia,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
			NVL(viTipo_Conciliacion,0),
			DECODE (vssqlerr, '00000', '', NVL(vsDesc_conciliacion,'')),
			NVL(vsErrorActividad,'');
			
	END
END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: IDENTIFICA EL TIPO DE CONCILIACION.',
'Fecha: 2011/07/06',
'Version: 20110706.1139',
'BD: bditarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA LA CLASIFICACION DE LAS TRANSACCIONES DE DEVOLUCIONES (21) PARA LOS TIPOS DE CONCILIACION 10,11 Y 12. SE AGREGA EL TIPO CONCILIACION 14.',
'Fecha: 2012/04/19',
'Version: 20120419.1110',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA LAS DEVOLUCIONES CON MONTO MAYOR SE RECLASIFICAN A TIPO 10 (ANTERIORMENTE 12).',
'Fecha: 2012/05/21',
'Version: 20120521.1210',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA QUE EN LOS TIPOS DE CONCILIACION 7 Y 13 UTILICE EL CAMPO [FORMATO] PARA VALIDAR LA NATURALEZA DE LA TRANSACCION.',
'Fecha: 2012/05/21',
'Version: 20120521.1445',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE HACE NUEVAMENTE EL SP, OPTIMIZANDO EL PROCESO EN CUANTO A FUNCIONAMIENTO Y CLARIDAD DEL CODIGO.',
'Fecha: 2012/06/25',
'Version: 20120625.1753',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA LOGICA PARA LA CLASIFICACION DE TRANSACCIONES DE ATM.',
'Fecha: 2012/07/27',
'Version: 20120727.1148',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA LA LOGICA PARA LA CLASIFICACION DE TRANSACCIONES DE ATM EN EL CASO DE LAS TARJETAS CON DIF ESTATUS.',
'Fecha: 2012/07/30',
'Version: 20120730.1221',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA LA LOGICA PARA ELIMINAR LA CLASIFICACION DE LOS ARCHIVOS PNC DEL PROCESO PUESTO QUE NO REQUIEREN CLASIFICACION.',
'Fecha: 2012/08/10',
'Version: 20120810.1035',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA LA LOGICA PARA CLASIFICAR LAS TRANSACCIONES TIPO 20 EN LOS ARCHIVOS VIC(MONEYGRAM).',
'Fecha: 2012/10/01',
'Version: 20121001.0955',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA LA LOGICA PARA CLASIFICAR LAS TRANSACCIONES TIPO 21 CON CONSEGUTIVOS DE NUMEROS REPETIDOS. Y HOMOLOGACION DE CODIGO',
'Fecha: 2012/10/12',
'Version: 20121012.1015',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo ResÃÂÃÂÃÂÃÂ©ndiz Martinez',
'Proyecto: INC 13 281 Clasificacion de movimientos por cartera vendida',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se agrego validacion para el status del credito y hacer la validacion correspondiente ',
'Fecha: 2013/02/06',
'Version: 20130206.1400',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo ResÃÂÃÂÃÂÃÂ©ndiz Martinez',
'Proyecto: IntegraciÃÂÃÂÃÂÃÂ³n de CashBack en proceso de conciliacion',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se agregaron nuevas clasificaciones para la integraciÃÂÃÂÃÂÃÂ³n de CashBack en proceso de conciliacion ',
'Fecha: 2013/07/30',
'Version: 20130730.1700',
'BD: BdiTarjeta',
'',
'MODIFICACION: L.I.A. Ricardo ResÃÂÃÂÃÂÃÂ©ndiz Martinez',
'Proyecto: Transacciones Forzadas',
'Solicito: Jose Luis Puebla Salinas',
'Descripcion: Se pone mensaje para identificar el tipo de conciliacion en los casos de mayores y forzadas ',
'Fecha: 2016/02/04',
'Version: 20160204.1300',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_buscar_mov_intercard_mc(
		psCve_usuario 				CHAR(10),
		psNumtarjeta 				CHAR(16),
		psSecuencia325	 			CHAR(6),
		psMonto325 					CHAR(13),
		psMontoCashBack325 			CHAR(13),
		ps_secuencia_ext_archivo 	CHAR(15),
		ps_archivo_origenMC 		CHAR(03),
		psIdProcesador 				CHAR(05)
	)

RETURNING CHAR(5) AS Retorno,
	CHAR(7) AS secuencia,
	CHAR(15) AS secuencia_extendida,
	--MONEY(19,4) AS montointercard,
	MONEY AS montointercard,
	MONEY AS montointercardcashback, -- Integracion de CashBack
	DATETIME YEAR TO FRACTION(5) AS fechatransaccion,
	CHAR(40) AS infreceptor,
	CHAR(16) AS idterminal,
	CHAR(2) AS metodocaptura,
	CHAR(1) AS movconciliado,
	CHAR(1) AS movreversado,
	CHAR(2) AS codigoiso,
	CHAR(4) AS Formato,
	CHAR(250) AS ErrorActividad,
	CHAR(1) AS CodReversa, 
	CHAR(5) AS CodigoCentral,
	CHAR(4) AS Codgironeg,
	CHAR(16) AS folio_reg;

	/*
	*****************************************************************************************************
	-- DESCRIPCION:  OBTIENE EL MOVIMIENTO ORIGINAL DE INTERCARD:MOVIMIENTO  ----------------------------
	-- AUTOR : Mo  -----------------------------------------------------------------------
	-- FECHA : 11/06/2018  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Conciliacion automatica de MasterCard - Oxxo / Conciliacion Intercard  -------------------
	*****************************************************************************************************
	*/

	/*DEFINICION DE VARIABLES*/

	/*VARIABLES DE RETORNO*/
	/*VARIABLES DE ERROR*/
	DEFINE viCodigo INTEGER;
	DEFINE vssqlerr CHAR(5) ;
	DEFINE vsErrorActividad CHAR(250);

	/*VARIABLES DEL MOVIMIENTO ORIGINAL*/
	DEFINE vsNumtarjeta CHAR(16);
	DEFINE vsSecuenciaorig CHAR(7);
	DEFINE vsSecuencia_extendida CHAR(15);
	--DEFINE vmMontointercard MONEY(19,4);
	DEFINE vmMontointercard MONEY;
	DEFINE vmMontointercardcashback money;
	DEFINE vdFechatransaccion DATETIME YEAR TO FRACTION(5);
	DEFINE vsInfreceptor CHAR(40);
	DEFINE vsIdterminal CHAR(16);
	DEFINE vsMetodocaptura CHAR(2);
	DEFINE vsMovconciliado CHAR(1);
	DEFINE vsMovconciliado1 CHAR(1);
	DEFINE vsMovreversado CHAR(1);
	DEFINE vsCodigoiso CHAR(2);
	DEFINE vsFormato VARCHAR(2);
	DEFINE vsCodReversa CHAR(1); 
	DEFINE vsCodigoCentral CHAR(5);	
	DEFINE vsCodgironeg CHAR(4);  -- TFORZADAS

	DEFINE vsSecuencia CHAR(7);
	
	DEFINE vmmonto325 money;
	DEFINE contador integer;
	
	/* FOLIO REGULATORIO */

	DEFINE vsFechaMov      		CHAR(04);
	DEFINE vsHoraMov      		CHAR(06);
	DEFINE vsvHoraLocalTrx     	CHAR(14);
	DEFINE vsFolio_Reg     		CHAR(16);

	
	/*INICIALIZACION DE VARIABLES*/

	LET viCodigo = 0;
	LET vssqlerr = '00000';
	LET vsErrorActividad = '';

	LET vsNumtarjeta = '';
	LET vsSecuenciaorig = '';
	LET vsSecuencia_extendida = '';
	LET vmMontointercard = 0;
	LET vmMontointercardcashback = 0;
	LET vdFechatransaccion = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
	LET vsInfreceptor = '';
	LET vsIdterminal = '';
	LET vsMetodocaptura = '';
	LET vsMovconciliado = '';
	LET vsMovconciliado1 = '';
	LET vsMovreversado = '';
	LET vsCodigoiso = '';
	LET vsCodReversa = '';
	LET vsCodigoCentral = '';
	LET vsCodGiroNeg = ' '; --TFORZADAS

	LET vsFormato = '';
	LET vsSecuencia = '';
	
	LET vmmonto325 = 0;
	LET contador = 0;
	
	/* FOLIO REGULATORIO */

	LET vsFechaMov  	='';
	LET vsHoraMov   	='';
	LET vsvHoraLocalTrx ='';
	LET vsFolio_Reg 	='';
	BEGIN

		ON EXCEPTION SET viCodigo   --cacha el error en caso de que exista y regresa un valor predeterminado

				LET vssqlerr = viCodigo;

				RETURN vssqlerr, 
					NVL(vsSecuenciaorig,''), 
					NVL(vsSecuencia_extendida,''), 
					NVL(vmMontointercard,0),
					NVL(vmMontointercardcashback,0),
					NVL(vdFechatransaccion,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
					NVL(vsInfreceptor,''), 
					NVL(vsIdterminal,''), 
					NVL(vsMetodocaptura,''), 
					NVL(vsMovconciliado,''), 
					NVL(vsMovreversado,''), 
					NVL(vsCodigoiso,''), 
					NVL(vsFormato, ''),
					NVL(vsErrorActividad,''),
					NVL(vsCodReversa, ''),
					NVL(vsCodigoCentral,''),
					NVL(vsCodGiroNeg,' '),
					NVL(vsFolio_Reg,' ');

		END EXCEPTION;

		--SET DEBUG FILE TO '/informix/LVRQ/seven_new/debug/Buscamovintercard.out';
		--TRACE ON;
		
		LET vsSecuencia = "1"||psSecuencia325;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF ( ps_archivo_origenMC IN ('MCO')) THEN 
		
				SELECT FIRST 1 numtarjeta,
					secuencia, 
					secuenciaextendida, 
					(NVL(monto,0) + NVL(montosurcharge,0)),
					montocashback, --Integración de Monto CashBack
					fechahorainauth, 
					infreceptor, 
					idterminal, 
					metodocaptura, 
					movconciliado, 
					movreversado, 
					codigoiso, 
					Formato,
					CodReversa,
					CodigoCentral,
					codgironeg, --TFORZADA
					fechalocaltransaccion,
					horamov,
					horalocaltransaccion
				INTO vsNumtarjeta, 
					vsSecuenciaorig, 
					vsSecuencia_extendida, 
					vmMontointercard,
					vmMontointercardcashback, -- Monto CashBack
					vdFechatransaccion, 
					vsInfreceptor, 
					vsIdterminal, 
					vsMetodocaptura, 
					vsMovconciliado, 
					vsMovreversado, 
					vsCodigoiso, 
					vsFormato,
					vsCodReversa,
					vsCodigoCentral,
					vsCodGiroNeg, --TFORZADA
					vsFechaMov,
					vsHoraMov,
					vsvHoraLocalTrx
				FROM intercard:"informix".movimiento
				WHERE 	numtarjeta = psNumtarjeta 
				AND secuenciaextendida = ps_secuencia_ext_archivo;
			
			IF ( (vsNumtarjeta IS NULL) OR ( TRIM (vsNumtarjeta) = '') ) THEN
					
				/*NO EXISTE EL MOVIMIENTO ORIGINAL*/
				LET vssqlerr = '00400';
				LET vsErrorActividad = 'NO EXISTE EL MOVIMIENTO INTERCARD';
			
			END IF;
		
			
		END IF;
		-- Para recuperar el monto correcto de la compra POS y la disposicion del efectivo a identificar RRM
		
		/* GENERACION DE FOLIO REGULATORIO */
		
		--TRACE 'psIdProcesador? = '|| psIdProcesador;	
		
			IF (psIdProcesador = 'OXXO' ) THEN
			
				--TRACE 'este es de Oxxo :'||vsFolio_Reg;

				LET vsFolio_Reg = TRIM(SUBSTR (vsInfreceptor,17,6) || vsFechaMov ||SUBSTR (vsvHoraLocalTrx,0,4) ||SUBSTR (vsHoraMov,5,2) ); -- oxxo
				
			ELIF (psIdProcesador = 'SEVEN' ) THEN	
				
				--TRACE 'este es de seven:'||vsFolio_Reg;

				LET vsFolio_Reg = TRIM(SUBSTR (vsIdTerminal,1,5) || vsFechaMov ||SUBSTR (vsvHoraLocalTrx,0,4) ||SUBSTR (vsHoraMov,5,2) ); -- seven
				
			ELSE
				LET vsFolio_Reg = '';
				
			END IF;

		--TRACE 'folio_reg = '|| vsFolio_Reg;	
		
		/*RETORNO DEL PROCEDIMIENTO ALMACENADO*/
	
	RETURN vssqlerr, 
			NVL(vsSecuenciaorig,''), 
			NVL(vsSecuencia_extendida,''), 
			NVL(vmMontointercard,0),
			NVL(vmMontointercardcashback,0),
			NVL(vdFechatransaccion,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
			NVL(vsInfreceptor,''), 
			NVL(vsIdterminal,''), 
			NVL(vsMetodocaptura,''), 
			NVL(vsMovconciliado,''), 
			NVL(vsMovreversado,''), 
			NVL(vsCodigoiso,''), 
			NVL(vsFormato, ''),
			NVL(vsErrorActividad,''),
			NVL(vsCodReversa, ''),
			NVL(vsCodigoCentral,''),
			NVL(vsCodGiroNeg,' '),
			NVL(vsFolio_Reg,'');

	END

END PROCEDURE;