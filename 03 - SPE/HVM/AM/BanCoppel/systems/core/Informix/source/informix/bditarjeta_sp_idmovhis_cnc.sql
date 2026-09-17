CREATE PROCEDURE "informix".sp_idmovhis_cnc(dfechafin date)
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;

	--  Variables de Errores y datos de SP
	define  sql_err          integer;
	define  isam_err         integer;
	define  error_info       varchar(80);
	define  p_cod_ret        varchar(6);
	define  p_mensaje        varchar(80);
	define  vdfechafin       date;	
	define  vFechaFinal      datetime year to fraction(3);
	
   	--  Variables para control de contadores
	define  vsflagentransaccion 	char(1);
	define 	vicontadorregistros 	integer;
	define  vicontadorregistros2 	integer;
    
	--  Variables para datos de primary key
	define  vconsecutivo		integer;
	define 	varchivoorigen  	CHAR(3);
    define 	vfechacarga      	DATETIME YEAR to FRACTION(3);
    define 	vnombrearchivo   	CHAR(23);
			
	--SET DEBUG FILE TO "/home/c90306398/Pase_Historico_sp_idmovhis_cnc/deltdmovhis.out";
	--TRACE ON;

BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET P_COD_RET    = SQL_ERR;
	LET P_MENSAJE  = ERROR_INFO;
	
    RETURN 	P_COD_RET,P_MENSAJE;
		
   END EXCEPTION;

--************************************************************
-- Creado por Ricardo ResÃ©ndiz Martinez 
-- fecha : Nov/2012
-- Funcion: Borrado de registros de tablas productivas   
--************************************************************
	
	let     vconsecutivo = 0;
	let 	varchivoorigen = '';
    let 	vfechacarga = current;
    let 	vnombrearchivo = '';
	let		vFechaFinal = TO_DATE((TO_CHAR((dfechafin), '%Y/%m/%d') || ' 23:59:59'), "%Y/%m/%d %H:%M:%S");
	
	let 	vsflagentransaccion = 'F';
	let		vicontadorregistros = 0;
	let     vicontadorregistros2 = 0;
	
	
	let p_cod_ret = '00000';
	let p_mensaje = 'Proceso Exitoso';

	set isolation to dirty read;
		foreach with hold
				    
			select 	consecutivo, nombrearchivo, archivo_origen, fechacarga 
					into vconsecutivo, vnombrearchivo, varchivoorigen, vfechacarga 
			from bditarjeta:td_movimientos_conciliacion
				where fechacarga <= vFechaFinal
			
			if(vsflagentransaccion = 'F') then
				begin work;
                let vsflagentransaccion = 'V';
            end if;
			
			--  Inserta datos en la tabla historica
		insert into bditarjeta:td_movimientos_conciliacion_his(consecutivo,nombrearchivo,archivo_origen,fechacarga,integridad,integridad_error,numtarjeta,ban_bin,secuencia325,
			   monto325,montocashback325,montosurcharge325,numcuenta,estransfer,idcomercio325,nomcomercio325,tipotransaccion325,referencia23_325,
			   rfc325,divisa325,monto_divisa325,iso323, movrev325,conciliacion,secuencia,secuencia_extendida,codgironeg,montointercard,montocashback,fechatransaccion,
			   infreceptor,idterminal,metodocaptura,movconciliado,movreversado,tipo_mov,folio_mov,fechaconcilia,tipo_conciliacion,
			   desc_conciliacion,b_aplica,aplicacion,transaccion_aplica,bandera_proceso,cod_retorno,fechaaplica,cve_usuario,finalizado,secuencia_ext_archivo,txn_code,indicador_fastfounds,
			   ref_num_fastfounds,diferimiento_promo,parcialiacion_promo,tipo_plan_promo)
		select consecutivo,nombrearchivo,archivo_origen,fechacarga,integridad,integridad_error,numtarjeta,ban_bin,secuencia325,
			   monto325,montocashback325,montosurcharge325,numcuenta, estransfer, idcomercio325,nomcomercio325,tipotransaccion325,referencia23_325,
			   rfc325,divisa325,monto_divisa325,iso323, movrev325,conciliacion,secuencia,secuencia_extendida,codgironeg,montointercard,montocashback,fechatransaccion,
			   infreceptor,idterminal,metodocaptura,movconciliado,movreversado,tipo_mov,folio_mov,fechaconcilia,tipo_conciliacion,
			   desc_conciliacion,b_aplica,aplicacion,transaccion_aplica,bandera_proceso,cod_retorno,fechaaplica,cve_usuario,finalizado,secuencia_ext_archivo,txn_code,indicador_fastfounds,
			   ref_num_fastfounds,diferimiento_promo,parcialiacion_promo,tipo_plan_promo
		from bditarjeta:td_movimientos_conciliacion	  
		where 		consecutivo = vconsecutivo   		and
					nombrearchivo = vnombrearchivo 		and 
					archivo_origen = varchivoorigen 	and 
					fechacarga = vfechacarga;				
			
			--  Borra registro de la Tabla de Movimientos	
			delete from bditarjeta:td_movimientos_conciliacion 
			where 	consecutivo = vconsecutivo   and
					nombrearchivo = vnombrearchivo and 
					archivo_origen = varchivoorigen and 
					fechacarga = vfechacarga;
				
			let vicontadorregistros = vicontadorregistros + 1;
			let vicontadorregistros2 = vicontadorregistros2 + 1;

			if (vicontadorregistros2 = 100000) then 
				update statistics medium for table bditarjeta:td_movimientos_conciliacion;           
				let vicontadorregistros2 = 0;
			end if;

			if (vicontadorregistros = 1000) then
				commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
				continue foreach;
			end if;		
		end foreach;
		
		if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
				commit work;
				update statistics medium for table bditarjeta:td_movimientos_conciliacion;      
				let vsflagentransaccion = 'F';
		end if;
		
	--END IF;
	
	RETURN 	P_COD_RET,P_MENSAJE;

	--END IF;

END;

END PROCEDURE
DOCUMENT
'AUTOR: Ricardo ReseÃ©ndiz Martinez',
'Proyecto: Integracion de Conciliacion de Archivos MasterCard',
'Solicito: Luis Antonio Gomez',
'Descripcion: Se le agrego el campo ban_bin para el proceso de trasferencia de datos historicos',
'Fecha: 2014/03/07',
'Version: 20140307.1625',
'BD: BdiTarjeta',
'',
'Modifico: Ricardo ReseÃ©ndiz Martinez',
'Proyecto: IntegraciÃ³n del campo estransfer bandera',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agrega al proceso el campo es transfer para que el proceso identifique este nuevo campo',
'Fecha: 2014/09/07',
'Version: 20140307.1625',
'BD: BdiTarjeta',
'',
'Modifico: Ricardo ReseÃ©ndiz Martinez',
'Proyecto: RQM 06 384 Proceso de ConciliaciÃ³n de Transacciones Forzadas',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agrega al proceso nuevos campos para el proceso de validacion de transacciones forzadas',
'Fecha: 2015/07/06',
'Version: 20150706.1900',
'BD: BdiTarjeta',
'Modifico: Cristian Ariel Meza Martinez',
'Proyecto: RQI 32 516 ActualizaciÃ³n campos pase histÃ³rico sp_idmovhis_cnc',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agregan al proceso historico campos faltantes de la tabla historica',
'Fecha: 2025/01/28',
'BD: BdiTarjeta',
'Modifico: LGMR',
'Proyecto: RQI 34 062 - ModificaciÃ³n componentes bditarjeta_sp_idmovhis',
'Solicito: ERS',
'Descripcion: Se agregan datos faltantes de la tabla',
'Fecha: 2025/03/11',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_consif
(
	pusuario 				CHAR(9),
	parchivo_origen 		CHAR(3),
	pfecha 					DATE,
	psistema 				CHAR,
	ptran_car 				CHAR(4),
	ptran_lib 				CHAR(4),
	ptran_for 				CHAR(4),
	ptran_abo 				CHAR(4),
	ptran_Extra 			CHAR(4),
	ptran_Extra1 			CHAR (16), --- Transacción de liberación de money gram  ** POSIBLE CAMBIO A 16
	ptipo_conciliacion 		INTEGER,
	pnumtarjeta 			CHAR(16),
	pnumcuenta 				CHAR(20),
	ptipotransaccion325 	CHAR(2),
	pfolio_mov 				CHAR(16),
	pmonto325 				money(16,2),
	pmontoCashBack325 		money(16,2), --- Para el monto de cashback
	pmoneda325 				CHAR(2),
	pnomcomercio325 		CHAR(30),
	prfc325 				CHAR(15),
	preferencia23_325 		CHAR(23),
	pdivisa325 				CHAR(3),
	pmonto_divisa325 		money(16,2),
	pidterminal 			CHAR(16),
	ptipo_mov 				CHAR,
	pconsecutivo 			INTEGER,
	pnombrearchivo 			CHAR(23),
	psecuenciaextendida 	char(15), 
	pestransfer 			char (1),
	pfechaopetransfer 		char(6),
	pidcomercio 			char(9),
	pcuenta 				char(20)
)
RETURNING VARCHAR(6),VARCHAR(80),INTEGER,CHAR(4),INTEGER, VARCHAR(1);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  P_BANDERA        VARCHAR(1);
DEFINE  vtransacion      CHAR(4);
DEFINE  vsistema_aplica  CHAR;
DEFINE  vtransaparencia  VARCHAR(40);
DEFINE  vformaaplica     CHAR;
DEFINE  vid_proceso      INTEGER;
DEFINE vsNuevaSecuencia  VARCHAR(6);
DEFINE vFech_param  	 DATE;
DEFINE vBin              CHAR(6);
DEFINE vBin8             CHAR(8);

-- Para CashBack
DEFINE  vstransaccashback    CHAR(4);
DEFINE  vsTransCarCashBack   CHAR(4);
DEFINE  vsTransLibCashBack   CHAR(4);
DEFINE  vsTransAboCashBack	 CHAR(4);
DEFINE	vsTransForCashBack   CHAR(4);

-- Para Transfer
DEFINE vsmonto325  			char(12);
DEFINE viconcaracteres1 	integer;
DEFINE vsmontocashback325  	char(12);
DEFINE viconcaracteres2 	integer;
DEFINE vssecuencia 			char(6);
DEFINE a					integer;


BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE,vid_proceso,vtransacion, ptipo_conciliacion, P_BANDERA;
   END EXCEPTION;

--*****************************************************************
-- APLICACION DE SALDOS                                         --*
-- Creado por: Manuel Osuna Valencia                            --*
-- Fecha: 20/07/2011                                            --*
-- Funcion: Recibe Registros para Aplicar Saldo  a los   		--*
-- clientes (cargo o abono) en lntegral 						--*
--*****************************************************************
-- Modificado por: Manuel Osuna Valencia                        --*
-- Fecha: 05/10/2011                                            --*
-- Funcion: Se modifico para que contabilizara el numero y saldo--*
-- de cargos o abanos que realizara por cada archivo            --*
--*****************************************************************
-- Modificado por: Manuel Osuna Valencia                        --*
-- Fecha: 17/10/2011                                            --*
-- Funcion: Se modifico para especificar bien el campo en el que--*
-- se estara sumarizando los cargos o abanos que realizara      --*
-- por cada archivo                                             --*
--*****************************************************************
-- Modificado por: Manuel Osuna Valencia                        --*
-- Fecha: 27/03/2012                                            --*
-- Funcion: Se modifico parametro de entrada fecha para que el  --*
-- proceso actualizará, fecha y hora, asi como tambien en el    --*
-- proceso cuando el sistema sea Credito y el tipo de conciliacion
-- sea igual a 1 o 10 la forma aplica sería igual a "B"         --*
--*****************************************************************
--*****************************************************************
-- Modificado por: Arturo Méndez Cárdenas                       --*
-- Fecha: 17/04/2012                                            --*
-- Funcion: Se modifico para que se ejecute el SP conciliadebito--*
-- solo cuando el tipo de conciliacion sea igual a 11 ó 14		--*
--*****************************************************************
-- Modificado por: CASANOVA EDEZA HECTOR JUAN                   --*
-- Fecha: 19/04/2012                                            --*
-- Funcion: SE MODIFICO LA LOGICA PARA LA APLICACION DE LAS     --*
-- DEVOLUCIONES, PARA QUE PERMITA APLICAR TODAS LAS TRANSACCIONES --* 
-- MENOS LOS ABONOS/DEVOLUCIONES CON TIPO_CONCILIACION  10 O 12 --*
--*****************************************************************
-- Modificado por: CASANOVA EDEZA HECTOR JUAN                   --*
-- Fecha: 01/10/2012                                            --*
-- Funcion: SE MODIFICA LA LOGICA PARA PERMITIR LAS 			--*
-- TRANSACCIONES TIPO 20 EN LOS ARCHIVOS VIC(MONEYGRAM) Y 		--*
-- REALIZAR EL ABONO CON LA TRANSACCION CORRESPONDIENTE.		--*
--*****************************************************************

	--SET DEBUG FILE TO "/RESPALDOSNEW/LGMR/bditarjeta/trace_sp_concreing_consif.out"; 
	--TRACE ON;

	LET P_COD_RET = '00000';
	LET P_MENSAJE = 'PROCESO EXITOSO';

	LET vid_proceso = '7';
	LET P_BANDERA = '';

	LET vsistema_aplica = psistema;
	LET vformaaplica = '';
	LET vtransaparencia = '';

	LET vtransacion = '';
   
	LET vsNuevaSecuencia = '';
    LET vFech_param = " ";
    LET vBin = '';
	LET vBin8 = '';
	
	--Para CashBack
	LET vstransaccashback = '';
	LET vsTransCarCashBack = '';
	LET vsTransLibCashBack= '';
	LET vsTransAboCashBack = '';
	LET	vsTransForCashBack = '';

--   PARA DEFINICION DE TRANSACCIONES DE CASH back	
	LET vsTransCarCashBack = TRIM(SUBSTR(ptran_Extra1,1,4));
	LET vsTransLibCashBack = TRIM(SUBSTR(ptran_Extra1,5,4));
	LET	vsTransForCashBack = TRIM(SUBSTR(ptran_Extra1,9,4));
	LET vsTransAboCashBack = TRIM(SUBSTR(ptran_Extra1,13,4));
	
-- Para ciclo de conversion de monto para transfer
	let vsmonto325 = '';
	let viconcaracteres1 = 0;
	let vsmontocashback325 = '';
	let viconcaracteres2 = 0;
	let vssecuencia = '';
	let a = 0; -- Controlador 
	
        
     -- // OBTENGO PARAMETROS
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT FIRST 1 fecha_hoy - 10 UNITS DAY
	INTO vFech_param
	FROM bdinteg:si_fechas
	WHERE empresa = '001';

	IF (NOT((pTipo_Mov = 'A') AND (pTipo_Conciliacion IN ('10','12','25','47')))) THEN 
	--SE APLICAN LOS ABONOS QUE NO TENGAN ESTATUS DEV. CONCILIADA(12) NI DEV. NO APLICADA(10)
				-- SET LOCK MODE TO WAIT 3;
				/*SET ISOLATION TO DIRTY READ; Se quita ya se tienen el dato desde la obtencion del resgitro 
				--OBTIENE EL NUMERO DE CUENTA RELACIONADO A LA TARJETA
				SELECT FIRST 1 NumCuenta
				INTO pnumcuenta
				FROM Intercard:tarjetacuenta
				WHERE numtarjeta = pnumtarjeta;*/
			if pestransfer <> 'V' then 
				IF (ptipo_conciliacion IN (1,2,3,4,5) ) THEN 
					LET vtransacion  =  ptran_car ;

				ELIF (ptipo_conciliacion IN (8,13)) THEN 
					LET vtransacion  =  ptran_for ;

				ELIF (ptipo_conciliacion IN (10,11, 14)) THEN 
					LET vtransacion  =  ptran_abo ;
				
				ELIF (ptipo_conciliacion IN (20,21,22,23,24,36,41,42,43,37,38,39,40,44,45,46)) THEN
					LET vtransacion = ptran_car;
					LET vstransaccashback = vsTransCarCashBack; --vsTransCarCashBack
				
				ELIF (ptipo_conciliacion IN (28,31,33)) THEN
					LET vtransacion  =  ptran_for ;
					LET	vstransaccashback = vsTransForCashBack;  -- vsTransForCashBack
				
				ELIF (ptipo_conciliacion IN ( 48,49)) THEN
					LET vtransacion  =  ptran_abo;
					LET vstransaccashback = vsTransAboCashBack; -- vsTransAboCashBack

				ELIF ( ptipo_conciliacion == 0 AND ptipotransaccion325 == 20) THEN --PNC y VIC (MONEYGRAM)

					LET vtransacion  = CASE WHEN (parchivo_origen = 'PNC') THEN ptran_abo /*PNC*/ 
											WHEN (parchivo_origen = 'VID') THEN ptran_Extra /*VID*/
											ELSE ptran_abo /*DEFAULT*/ END;
					
					LET ptipo_mov = 'A'; -- ABONOS [A]
					
					--SET LOCK MODE TO WAIT 3;
					--SET ISOLATION TO DIRTY READ;
					--OBTIENE UNA SECUENACIA DE AUTORIZACION PARA TRANSACCIONES QUE NO PASAN POR EL AUTORIZADOR
					EXECUTE PROCEDURE Intercard:sp_GetSecuencia (CASE WHEN (parchivo_origen = 'PNC') THEN 22 /*PNC*/ 
																				 WHEN (parchivo_origen = 'VID') THEN 23 /*VID*/
																				 ELSE 22 /*DEFAULT*/ END ) 
					INTO vsNuevaSecuencia; -- GENERA UNA SECUENCIA
					
					--GENERA EL FOLIO_MOV PARA EL PNC [iMMDD3secuencia]
					LET pfolio_mov = 'i' || REPLACE (SUBSTRING (CURRENT::DATE FROM 1 FOR 5), '/', '' ) || REPLACE (SUBSTRING (CURRENT FROM 12 FOR 6), ':', '' ) || '3' || LPAD ( TRIM ( vsNuevaSecuencia ), 6, '0' );
					
					--SET LOCK MODE TO WAIT 3;
					--SET ISOLATION TO DIRTY READ;
					--ACTUALIZA EL NUMERO DE CUENTA DE LOS REGISTROS QUE NO LO TIENEN (POS)
					--Se cambia el orden del where para tomar la llave primaria en lugar de INDICE
					UPDATE BdiTarjeta:Td_Movimientos_Conciliacion
					SET --NumCuenta = pnumcuenta, Se quita la actualización dato que el dato qya existe en la tabla en cuestion -- Transfer
							Tipo_Mov = ptipo_mov, -- ABONOS [A]
							Folio_Mov = pfolio_mov -- FOLIO PARTICULAR PARA PNC
					WHERE consecutivo = pconsecutivo  
					AND nombrearchivo = pnombrearchivo ;
					
					
				ELSE --NINGUN CASO CONCUERDA
					LET vtransacion = '';
					LET psistema = '';
				END IF;
			else				
				IF (ptipo_conciliacion IN (1,2,3,4,5) ) THEN 
					LET vtransacion  =  ptran_lib ;

				ELIF (ptipo_conciliacion IN (8,13)) THEN 
					LET vtransacion  =  ptran_for ;

				ELIF (ptipo_conciliacion IN (10,11, 14)) THEN 
					LET vtransacion  =  ptran_abo ;
				
				ELIF (ptipo_conciliacion IN (20,21,22,23,24,36,41,42,43,37,38,39,40,44,45,46)) THEN
					LET vtransacion = ptran_lib;
					LET vstransaccashback = vsTransCarCashBack; --vsTransCarCashBack
				
				ELIF (ptipo_conciliacion IN (28,31,33)) THEN
					LET vtransacion  =  ptran_for ;
					LET	vstransaccashback = vsTransForCashBack;  -- vsTransForCashBack
				
				ELIF (ptipo_conciliacion IN ( 48,49)) THEN
					LET vtransacion  =  ptran_abo;
					LET vstransaccashback = vsTransAboCashBack; -- vsTransAboCashBack

				ELIF ( ptipo_conciliacion == 0 AND ptipotransaccion325 == 20) THEN --PNC y VIC (MONEYGRAM)

					LET vtransacion  = CASE WHEN (parchivo_origen = 'PNC') THEN ptran_abo /*PNC*/ 
											WHEN (parchivo_origen = 'VID') THEN ptran_Extra /*VID*/
											ELSE ptran_abo /*DEFAULT*/ END;
					
					LET ptipo_mov = 'A'; -- ABONOS [A]
					
					--SET LOCK MODE TO WAIT 3;
					--SET ISOLATION TO DIRTY READ;
					--OBTIENE UNA SECUENACIA DE AUTORIZACION PARA TRANSACCIONES QUE NO PASAN POR EL AUTORIZADOR
					EXECUTE PROCEDURE Intercard:sp_GetSecuencia (CASE WHEN (parchivo_origen = 'PNC') THEN 22 /*PNC*/ 
																				 WHEN (parchivo_origen = 'VID') THEN 23 /*VID*/
																				 ELSE 22 /*DEFAULT*/ END ) 
					INTO vsNuevaSecuencia; -- GENERA UNA SECUENCIA
					
					--GENERA EL FOLIO_MOV PARA EL PNC [iMMDD3secuencia]
					LET pfolio_mov = 'i' || REPLACE (SUBSTRING (CURRENT::DATE FROM 1 FOR 5), '/', '' ) || REPLACE (SUBSTRING (CURRENT FROM 12 FOR 6), ':', '' ) || '3' || LPAD ( TRIM ( vsNuevaSecuencia ), 6, '0' );
					
					--SET LOCK MODE TO WAIT 3;
					--SET ISOLATION TO DIRTY READ;
					--ACTUALIZA EL NUMERO DE CUENTA DE LOS REGISTROS QUE NO LO TIENEN (POS)
					--Se cambia el orden del where para tomar la llave primaria en lugar de INDICE
					UPDATE BdiTarjeta:Td_Movimientos_Conciliacion
					SET --NumCuenta = pnumcuenta, Se quita la actualización dato que el dato qya existe en la tabla en cuestion -- Transfer
							Tipo_Mov = ptipo_mov, -- ABONOS [A]
							Folio_Mov = pfolio_mov -- FOLIO PARTICULAR PARA PNC
					WHERE consecutivo = pconsecutivo 
					AND nombrearchivo = pnombrearchivo;
					
					
				ELSE --NINGUN CASO CONCUERDA
					LET vtransacion = '';
					LET psistema = '';
				END IF;
			end if
				

		--ASEGURA EL BLOQUE TRANSACCION, ANTES DE ABONO_REF Y CARGO_REF
			COMMIT WORK;   -- Para pruebas se comenta 
			BEGIN WORK;
		
		IF ((vtransacion <> '') AND (psistema <> '')) THEN
		
			IF (psistema == "D" ) THEN
			--insert into bditarjeta:td_conciliadebito values ('001',pnumtarjeta,'9290',pusuario,ptipo_mov,vtransacion,pfolio_mov,pmonto325,pmoneda325,pnomcomercio325,'000000000000000',prfc325,preferencia23_325);
				--SET ISOLATION TO DIRTY READ;
				--SET LOCK MODE TO WAIT 3;
				   
				  
				IF (parchivo_origen == 'TCD') THEN --AGREGA COPPEL AL NOMBRE DE COMERCIO PARA LOS ARCHIVOS TCC Y TCD
					LET pnomcomercio325 = 'COPPEL ' || TRIM(pnomcomercio325);
				END IF
				
				-- AQUI SE MODIFICARÁ (EJECUTAR sp CUANDO TIPO_CONCILIACION IN(11,14), 
				-- Y VALIDAR EL RESULTADO(SI ES 15 PONER EL ERROR INESPERADO))
				-- ########## Para partir el proceso y mandarlo directo o por proceso actual TRANSFER  ####################################################
				if ( pestransfer = 'V') then 
					-- ########  Proceso para convertir monto de compra a char  ########
					LET vsmonto325 = CAST(pmonto325 as CHAR(13));
					LET vsmonto325 = REPLACE(REPLACE(vsmonto325,'$',''),'.',''); 
					LET viconcaracteres1 = Length(vsmonto325);
						FOR  a = viconcaracteres1  TO 11 STEP 1
								LET vsmonto325 = '0'||vsmonto325;
						END FOR;
					-- ######## Proceso para convertir monto de cahs back a char #######
					if pmontoCashBack325 > 0 then 
						LET vsmontocashback325 = CAST(pmontoCashBack325 as CHAR(13));
						LET vsmontocashback325 = REPLACE(REPLACE(vsmontocashback325,'$',''),'.',''); 
						LET viconcaracteres2 = Length(vsmonto325);
						FOR  a = viconcaracteres2  TO 11 STEP 1
							LET vsmontocashback325 = '0'||vsmonto325;
						END FOR;
					end if;
					
					if (pmonto325 > 0) and  (pmontoCashBack325 = 0) then -- Transacción de solo compra
						if ptipo_mov = 'A' then 
							execute procedure bditransfer:sp_transfer_in_tfincapture (pnombrearchivo, parchivo_origen, pnumtarjeta, ptipo_conciliacion,	vtransacion, ptipotransaccion325,	psecuenciaextendida, 
																			vsMonto325,	pidcomercio, pfechaopetransfer,	substr(pnomcomercio325,1,26), preferencia23_325,	pdivisa325,	prfc325) into p_cod_ret, p_mensaje;	
							if 	p_cod_ret = '00000' then
								let P_BANDERA = 'C';
								let P_COD_RET = '000';
							end if;
								
						elif ptipo_mov = 'C' then
							execute procedure Bdicheq:sp_transfer_regtrxconciliacion(
																							pfolio_mov, -- Folio suc del registro
																							'9290', -- Numero de la sucursal
																							pusuario, 
																							vtransacion, 
																							pcuenta, 
																							pmonto325, 
																							pnomcomercio325, 
																							pnumtarjeta)INTO P_COD_RET;
																							
							execute procedure bditransfer:sp_transfer_in_tfincapture (pnombrearchivo, parchivo_origen, pnumtarjeta, ptipo_conciliacion,	vtransacion, ptipotransaccion325,	psecuenciaextendida, 
																			vsMonto325,	pidcomercio, pfechaopetransfer,	substr(pnomcomercio325,1,26), preferencia23_325,	pdivisa325,	prfc325) into p_cod_ret, p_mensaje;	
							if 	p_cod_ret = '00000' then
								let P_BANDERA = 'C';
								let P_COD_RET = '000';
							end if;
						end if;
					Elif (pmonto325 = 0) and  (pmontoCashBack325 > 0) then -- Transacción CashAdvance
						if ptipo_mov = 'A' then 
							execute procedure bditransfer:sp_transfer_in_tfincapture (pnombrearchivo, parchivo_origen, pnumtarjeta, ptipo_conciliacion,	vtransacion, ptipotransaccion325,	psecuenciaextendida, 
																			vsmontocashback325,	pidcomercio, pfechaopetransfer,	substr(pnomcomercio325,1,26), preferencia23_325,	pdivisa325,	prfc325) into p_cod_ret, p_mensaje;	
							if 	p_cod_ret = '00000' then
								let P_BANDERA = 'C';
								let P_COD_RET = '000';
							end if;
						elif ptipo_mov = 'C' then
							execute procedure bdicheq:sp_transfer_regtrxconciliacion(	pfolio_mov, -- Folio suc del registro
																							'9290', -- Numero de la sucursal
																							pusuario, 
																							vstransaccashback, 
																							pcuenta, 
																							pmontoCashBack325, 
																							pnomcomercio325, 
																							pnumtarjeta)INTO P_COD_RET;
							execute procedure bditransfer:sp_transfer_in_tfincapture (pnombrearchivo, parchivo_origen, pnumtarjeta, ptipo_conciliacion,	vstransaccashback, ptipotransaccion325,	psecuenciaextendida, 
																			vsmontocashback325,	pidcomercio, pfechaopetransfer,	substr(pnomcomercio325,1,26), preferencia23_325,	pdivisa325,	prfc325) into p_cod_ret, p_mensaje;	
							if 	p_cod_ret = '00000' then
								let P_BANDERA = 'C';
								let P_COD_RET = '000';
							end if;
						end if;					
					Elif (pmonto325 > 0) and  (pmontoCashBack325 > 0) then 	-- Transacción de compra con CashBack		
						IF ptipo_mov = 'A' then 
							-- Para la compra
							execute procedure bditransfer:sp_transfer_in_tfincapture (pnombrearchivo, parchivo_origen, pnumtarjeta, ptipo_conciliacion,	vtransacion, ptipotransaccion325,	psecuenciaextendida, 
																			vsMonto325,	pidcomercio, pfechaopetransfer,	substr(pnomcomercio325,1,26), preferencia23_325,	pdivisa325,	prfc325) into p_cod_ret, p_mensaje;						
							-- Para el Cash back
							execute procedure bditransfer:sp_transfer_in_tfincapture (pnombrearchivo, parchivo_origen, pnumtarjeta, ptipo_conciliacion,	vstransaccashback, ptipotransaccion325,	psecuenciaextendida, 
																			vsmontocashback325,	pidcomercio, pfechaopetransfer,	substr(pnomcomercio325,1,26), preferencia23_325,	pdivisa325,	prfc325) into p_cod_ret, p_mensaje;
							if 	p_cod_ret = '00000' then
								let P_BANDERA = 'C';
								let P_COD_RET = '000';
							end if;

						elif ptipo_mov = 'C' then
							-- Para la compra
							execute procedure Bdicheq:sp_transfer_regtrxconciliacion(	pfolio_mov, -- Folio suc del registro
																							'9290', -- Numero de la sucursal
																							pusuario, 
																							vtransacion, 
																							pcuenta, 
																							pmonto325, 
																							pnomcomercio325, 
																							pnumtarjeta)INTO P_COD_RET;
							-- Para el Cash back
							execute procedure Bdicheq:sp_transfer_regtrxconciliacion(	pfolio_mov, -- Folio suc del registro
																							'9290', -- Numero de la sucursal
																							pusuario, 
																							vstransaccashback, 
																							pcuenta, 
																							pmontoCashBack325, 
																							pnomcomercio325, 
																							pnumtarjeta)INTO P_COD_RET;
							-- Para la compra
							execute procedure bditransfer:sp_transfer_in_tfincapture (pnombrearchivo, parchivo_origen, pnumtarjeta, ptipo_conciliacion,	vtransacion, ptipotransaccion325,	psecuenciaextendida, 
																			vsMonto325,	pidcomercio, pfechaopetransfer,	substr(pnomcomercio325,1,26), preferencia23_325,	pdivisa325,	prfc325) into p_cod_ret, p_mensaje;						
							-- Para el Cash back
							execute procedure bditransfer:sp_transfer_in_tfincapture (pnombrearchivo, parchivo_origen, pnumtarjeta, ptipo_conciliacion,	vstransaccashback, ptipotransaccion325,	psecuenciaextendida, 
																			vsmontocashback325,	pidcomercio, pfechaopetransfer,	substr(pnomcomercio325,1,26), preferencia23_325,	pdivisa325,	prfc325) into p_cod_ret, p_mensaje;	
							if 	p_cod_ret = '00000' then
								let P_BANDERA = 'C';
								let P_COD_RET = '000';
							end if;

						end if;					
					End if;
				else  ---  ##############################   PROCESO ACTUAL DE CONCILIACION   ######################################
				
					IF (pmonto325 > 0) and  (pmontoCashBack325 = 0) then -- Transacción de solo compra
							EXECUTE PROCEDURE bdicheq:conciliadebito(
																	'001',  			-- Numero de la empresa
																	pnumtarjeta,		-- Numero de tarjeta
																	'9290',				-- Numero de la sucursal
																	pusuario,			-- Usuario que ejecuta 
																	ptipo_mov,			-- TIpo de movimiento C ó A
																	vtransacion,		-- Numero de transacción de compra
																	pfolio_mov,			-- Folio suc del registro
																	pmonto325,			-- Monto de la compra
																	pmoneda325,			-- Id de la moneda
																	pnomcomercio325,	-- Nombre del comercio 325
																	'000000000000000',	--
																	prfc325,			-- RFC del comercio 325
																	preferencia23_325	-- Referencia 23-325
																) INTO P_COD_RET,P_BANDERA;
					Elif (pmonto325 = 0) and  (pmontoCashBack325 > 0) then -- Transacción CashAdvance
							EXECUTE PROCEDURE bdicheq:conciliadebito(
																	'001',  			-- Numero de la empresa
																	pnumtarjeta,		-- Numero de tarjeta
																	'9290',				-- Numero de la sucursal
																	pusuario,			-- Usuario que ejecuta 
																	ptipo_mov,			-- TIpo de movimiento C ó A
																	vstransaccashback,		-- Numero de transacción de compra
																	pfolio_mov,			-- Folio suc del registro
																	pmonto325,			-- Monto de la compra
																	pmontoCashBack325,			-- Id de la moneda
																	pnomcomercio325,	-- Nombre del comercio 325
																	'000000000000000',	--
																	prfc325,			-- RFC del comercio 325
																	preferencia23_325	-- Referencia 23-325
																) INTO P_COD_RET,P_BANDERA;
					Elif (pmonto325 > 0) and  (pmontoCashBack325 > 0) then 	-- Transacción de compra con CashBack		
							EXECUTE PROCEDURE bdicheq:conciliadebito(
																	'001',  			-- Numero de la empresa
																	pnumtarjeta,		-- Numero de tarjeta
																	'9290',				-- Numero de la sucursal
																	pusuario,			-- Usuario que ejecuta 
																	ptipo_mov,			-- TIpo de movimiento C ó A
																	vtransacion,		-- Numero de transacción de compra
																	pfolio_mov,			-- Folio suc del registro
																	pmonto325,			-- Monto de la compra
																	pmoneda325,			-- Id de la moneda
																	pnomcomercio325,	-- Nombre del comercio 325
																	'000000000000000',	--
																	prfc325,			-- RFC del comercio 325
																	preferencia23_325	-- Referencia 23-325
																) INTO P_COD_RET,P_BANDERA;
							EXECUTE PROCEDURE bdicheq:conciliadebito(
																	'001',  			-- Numero de la empresa
																	pnumtarjeta,		-- Numero de tarjeta
																	'9290',				-- Numero de la sucursal
																	pusuario,			-- Usuario que ejecuta 
																	ptipo_mov,			-- TIpo de movimiento C ó A
																	vstransaccashback,	-- Numero de transacción de cash back
																	pfolio_mov,			-- Folio suc del registro
																	pmontoCashBack325,	-- Monto de la compra
																	pmoneda325,			-- Id de la moneda
																	pnomcomercio325,	-- Nombre del comercio 325
																	'000000000000000',	--
																	prfc325,			-- RFC del comercio 325
																	preferencia23_325	-- Referencia 23-325
																) INTO P_COD_RET,P_BANDERA;
					End if;
				end if;			
				
				IF (parchivo_origen == 'VND') THEN
					LET vtransaparencia  = TRIM(prfc325) || ' ' || TRIM(pnomcomercio325) ||' ' || SUBSTR(NVL(pfolio_mov,''),11,6);
				ELIF (parchivo_origen == 'VID') THEN
					LET vtransaparencia  = TRIM(pnomcomercio325) || ' ' || SUBSTR(NVL(pfolio_mov,''),11,6)|| ' ' || pmonto_divisa325 || ' ' || pdivisa325;
				ELIF (parchivo_origen == 'MCD') THEN
					LET vtransaparencia  = TRIM(pnomcomercio325) || ' ' || SUBSTR(NVL(pfolio_mov,''),11,6)|| ' ' || pmonto_divisa325 || ' ' || pdivisa325;
				ELIF (parchivo_origen == 'TCD') THEN
					--i123120311794341
					LET vtransaparencia  = TRIM(prfc325) || ' ' || TRIM(pnomcomercio325) || ' ' || SUBSTR(NVL(pfolio_mov,''),11,6);
					
				ELIF (parchivo_origen == 'TMD') THEN

					LET vtransaparencia  = pidterminal;

				END IF;

				IF (TRIM(vtransaparencia) <> '') THEN 
					IF (P_BANDERA == 'C') THEN
						
						--REGISTRA LA REFERENCIA DE LA OPERACION EN MOVHIS
                        IF (parchivo_origen == 'TMD') THEN
                            
							
							UPDATE --{+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
                            bdicheq:sc_movhis  
                            SET  referencia = TRIM(NVL(referencia,'')) || vtransaparencia 
                            --WHERE empresa = '001' and cuenta = TRIM(pnumcuenta) AND folio_suc = TRIM(pfolio_mov);
                            WHERE fech_alt >= vFech_param
                            AND transacc = vtransacion
                            AND empresa = '001'
					        AND cuenta = TRIM(pnumcuenta)					        
					        AND cancelad <> "S"					        
					        AND folio_suc = TRIM(pfolio_mov);
								
                        ELSE						
						
						    UPDATE --{+INDEX(bdicheq:sc_movdia idx_movdia7a)}
                            bdicheq:sc_movdia  
                            SET  referencia = TRIM(NVL(referencia,'')) || vtransaparencia 
                            WHERE folio_suc = TRIM(pfolio_mov) and cuenta = TRIM(pnumcuenta);
							
                        END IF;
						
						
		
					ELIF (P_BANDERA == 'A') THEN
						
						
						--REGISTRA LA REFERENCIA DE LA OPERACION EN MOVDIA
						UPDATE ---{+INDEX(bdicheq:sc_movdia idx_movdia7a)}
                        bdicheq:sc_movdia 
                        SET  referencia = referencia || vtransaparencia 
                        WHERE folio_suc = TRIM(pfolio_mov) and cuenta = TRIM(pnumcuenta);

					END IF;
				END IF;
				
				--ACTUALIZA EL REGISTRO COMO APLICADO
				--Se cambia el orden del where para tomar la llave primaria en lugar de INDICE
				UPDATE bditarjeta:td_movimientos_conciliacion 
                SET  aplicacion = 'V',transaccion_aplica = vtransacion,bandera_proceso = 'C',cod_retorno = '000',fechaaplica = current, cve_usuario = pusuario 
                WHERE consecutivo = pconsecutivo AND nombrearchivo = pnombrearchivo ;
				
				IF ( ptipo_conciliacion IN (8,13) ) THEN

					UPDATE --{+INDEX(bdicheq:sc_movdia idx_movdia7a)}
                    bdicheq:sc_movdia  
                    SET  referencia = preferencia23_325  
                    WHERE folio_suc = TRIM(pfolio_mov) and cuenta = TRIM(pnumcuenta);
					
				ELIF ( ptipo_conciliacion = 0) THEN  --   Para agregar referencia para Money Gram
				
					UPDATE --{+INDEX(bdicheq:sc_movdia idx_movdia7a)}
                    bdicheq:sc_movdia  
                    SET  referencia = SUBSTR(NVL(preferencia23_325,''),15,9) 
                    WHERE folio_suc = TRIM(pfolio_mov) and cuenta = TRIM(pnumcuenta);
				
				-- Se separa Para poner la ley de transparanecia cuando son devoluciones del dia 
				
				ELIF ( ptipo_conciliacion = 11) and (parchivo_origen in ('VID', 'VND', 'MCD') )  THEN

					UPDATE --{+INDEX(bdicheq:sc_movdia idx_movdia7a)}
                    bdicheq:sc_movdia  
                    SET  referencia = TRIM(NVL(referencia,'')) || vtransaparencia
                    WHERE folio_suc = TRIM(pfolio_mov) and cuenta = TRIM(pnumcuenta);
		
				END IF;

				IF (P_COD_RET <> '000') THEN

					--ACTUALIZA EL ESTATUS DE LA APLICACION  
					--Se cambia el orden del where para tomar la llave primaria en lugar de INDICE
					UPDATE bditarjeta:td_movimientos_conciliacion  
							SET tipo_conciliacion = (CASE WHEN((pTipo_Mov = 'A') AND (pTipo_Conciliacion IN ('11','14'))) THEN 15 ELSE tipo_conciliacion END), 
							aplicacion = 'F',transaccion_aplica = vtransacion,bandera_proceso = 'E',fechaaplica = current, cve_usuario = pusuario,cod_retorno = P_COD_RET 
						WHERE consecutivo = pconsecutivo  
					AND nombrearchivo = pnombrearchivo;
					
					LET ptipo_conciliacion = (CASE WHEN((pTipo_Mov = 'A') AND (pTipo_Conciliacion IN ('11','14'))) THEN 15 ELSE ptipo_conciliacion END);
					
				END IF;

		ELIF (psistema == 'C' ) THEN

				--IF ( ptipo_conciliacion == 1  ) THEN
				IF ( ptipo_conciliacion IN (1,2,3,4,5)) THEN 
					LET vformaaplica  =  "B" ;   -- Cuando los datos corresponden completamente 
				--ELIF ( ptipo_conciliacion IN (2,3,4,5,11,14)) THEN 
				ELIF ( ptipo_conciliacion IN (13)) THEN 
					LET vformaaplica  =  "X" ; --Cuando hay diferencias en los montos del 325 a los de Intercard
				ELIF ( ptipo_conciliacion IN (0,8,11,14)) THEN 
					LET vformaaplica  =  "A" ; -- Cuando Hay que aplicar forzados los movimientos 
				END IF;
				
				-- La '6' no se clasifica ya que no debe paras a aplicacion por ser un movimiento que se detecto como previa mente conciliado
				-- La '7' no se clasifica por hacer referencia a una operacion reversada donde el campo formato es igual a 0420
				-- La '9' no se clasifica ya que al estar rechazado el movimiento original no procede su conciliacion para la aplicacion
				-- La '10' no se aplica la devolucion ya que al no cuprir todos los requisitos solamente habre de clasificarse por inprocedencia
				-- La '12' no se clasifica ya que al ser una devolucion que no aplica por errores de integridad
				-- La '13' no se clasifica por hacer referencia a una operacion reversada donde el campo formato es igual a 0220
				-- Lo 15 no se clasifica por estar marcada como error 
				-- La 16 no se aplica por ser de una cartera vendida 

				--insert into bditarjeta:td_conciliatc values ('001',pnumtarjeta,'9290',pusuario,ptipo_mov,vtransacion,pfolio_mov,pmonto325,pmoneda325,pnomcomercio325,'000000000000000',vformaaplica,prfc325,preferencia23_325);
				
				IF (parchivo_origen == 'TCC') THEN --AGREGA COPPEL AL NOMBRE DE COMERCIO PARA LOS ARCHIVOS TCC Y TCD
					LET pnomcomercio325 = 'COPPEL ' || TRIM(pnomcomercio325);
				END IF
			
	/*INICIA VALIDACIÓN BIN SMART VISTA */
	
				IF (parchivo_origen == "VNC") OR (parchivo_origen == "VIC") OR (parchivo_origen == "PNC") THEN
				
					--Validación del bin de UNITY
					LET vBin8 = SUBSTR(pnumtarjeta,1,8);
					
					IF (vBin8 = '42680711') THEN
						LET P_COD_RET = '000';
						LET P_BANDERA =  vformaaplica;
						
				--ACTUALIZA EL REGISTRO COMO APLICADO
						
				UPDATE bditarjeta:td_movimientos_conciliacion  
				SET  aplicacion = 'V', transaccion_aplica = vtransacion, bandera_proceso = 'C', cod_retorno = '000', 
				fechaaplica = current, cve_usuario = pusuario  
				WHERE consecutivo = pconsecutivo  
				AND nombrearchivo = pnombrearchivo;	
								
					ELSE
					
						EXECUTE PROCEDURE bdicred:conciliatc('001',pnumtarjeta,'9290',pusuario,ptipo_mov,vtransacion,pfolio_mov,pmonto325,pmoneda325,pnomcomercio325,'000000000000000',vformaaplica,prfc325,preferencia23_325) INTO P_COD_RET,P_BANDERA;				  
					
					END IF ;
				ELSE
						
				
	/*TERMINA VALIDACIÓN BIN SMART VISTA */			
				

                --Validación del bin de Tarjeta de Crédito Coppel Mastercard
                LET vBin = SUBSTR(pnumtarjeta,1,6);
                
                --validación de Tarjeta de Crédito Coppel - Mastercard 
                IF ( vBin = '514014' ) OR (vBin8 = '42680711') THEN  ---- SE AÑADE BIN SMART
                    LET P_COD_RET = '000';
                    LET P_BANDERA =  vformaaplica;
                ELSE
                
                    EXECUTE PROCEDURE bdicred:conciliatc('001',pnumtarjeta,'9290',pusuario,ptipo_mov,vtransacion,pfolio_mov,pmonto325,pmoneda325,pnomcomercio325,'000000000000000',vformaaplica,prfc325,preferencia23_325) INTO P_COD_RET,P_BANDERA;
               
                 END IF ;
				
			END IF;
                
				IF (parchivo_origen == "VNC") THEN
					LET vtransaparencia  = TRIM(prfc325) || ' ' || TRIM(pnomcomercio325);
				ELIF (parchivo_origen == "VIC") THEN
					LET vtransaparencia  = pmonto_divisa325 || ' ' || pdivisa325;
				ELIF (parchivo_origen == "MCC") THEN
					LET vtransaparencia  = pmonto_divisa325 || ' ' || pdivisa325;
				ELIF (parchivo_origen == 'TCC') THEN
					--i123120311794341
					LET vtransaparencia  = TRIM(pnomcomercio325) || ' ' || SUBSTR(NVL(pfolio_mov,''),11,6);
					
				ELIF (parchivo_origen == "TMC") THEN

					LET vtransaparencia  = pidterminal;

				END IF;

				IF (TRIM(vtransaparencia) <> '') THEN 
					IF (P_BANDERA == "C") THEN
						--REGISTRA LA REFERENCIA DE LA OPERACION EN MOVHIS
						IF(parchivo_origen == 'TMC') THEN
						
                            UPDATE --{+INDEX(bdicred:sd_movhis inx_movhis4)}
                            bdicred:sd_movhis  
                            SET  referencia = TRIM(referencia) || vtransaparencia 
                            WHERE empresa = '001' and fecha_mov is not null and
                            num_credito = TRIM(pnumcuenta) AND folio_suc = TRIM(pfolio_mov);
							
                        ELSE
						
                            UPDATE --{+INDEX(bdicred:sd_movdia mov3)}
                            bdicred:sd_movdia 
                            SET  referencia = referencia || vtransaparencia 
                            WHERE empresa = '001' and num_credito = TRIM(pnumcuenta) AND folio_suc = TRIM(pfolio_mov);
							
						END IF;
						
					
					ELIF (P_BANDERA == "A") THEN
						
						UPDATE --{+INDEX(bdicred:sd_movdia mov3)}
                        bdicred:sd_movdia 
                        SET  referencia = referencia || vtransaparencia 
                        WHERE empresa = '001' and num_credito = TRIM(pnumcuenta) AND folio_suc = TRIM(pfolio_mov);
						
					END IF;
				END IF;

				--ACTUALIZA EL REGISTRO COMO APLICADO
				--Se cambia el orden del where para tomar la llave primaria en lugar de INDICE
				UPDATE bditarjeta:td_movimientos_conciliacion  
                    SET  aplicacion = 'V', transaccion_aplica = vtransacion, 
                            bandera_proceso = 'C', cod_retorno = '000', 
                         fechaaplica = current, cve_usuario = pusuario  
                WHERE consecutivo = pconsecutivo  
                    AND nombrearchivo = pnombrearchivo;				
				
				--   Para aplicar ley de transparencia a los registros de devolucion
				IF ( ptipo_conciliacion == 11 ) and (parchivo_origen IN ('VIC', 'VNC','MCC'))  THEN
						
						UPDATE --{+INDEX(bdicred:sd_movdia mov3)}
                        bdicred:sd_movdia 
                        SET  referencia = referencia || vtransaparencia 
                        WHERE empresa = '001' and num_credito = TRIM(pnumcuenta) AND folio_suc = TRIM(pfolio_mov);

				END IF;	 
				
				IF (P_COD_RET <> "000") THEN
					
					--ACTUALIZA EL ESTATUS DE LA APLICACION
					--Se cambia el orden del where para tomar la llave primaria en lugar de INDICE
					UPDATE bditarjeta:td_movimientos_conciliacion  
							SET tipo_conciliacion = (CASE WHEN((pTipo_Mov = 'A') AND (pTipo_Conciliacion IN ('11','14'))) THEN 15 ELSE tipo_conciliacion END), 
							aplicacion = 'F',
							transaccion_aplica = vtransacion,
							bandera_proceso = 'E',
							fechaaplica = current,
							cve_usuario = pusuario,
							cod_retorno = P_COD_RET 
						WHERE consecutivo = pconsecutivo  
						AND nombrearchivo = pnombrearchivo;
						
					LET ptipo_conciliacion = (CASE WHEN((pTipo_Mov = 'A') AND (pTipo_Conciliacion IN ('11','14'))) THEN 15 ELSE ptipo_conciliacion END);

				END IF;

			END IF;
		   
		   -- Se modifica suma para integrar montos CashBack )
			IF ((P_COD_RET == '000') AND (ptipo_mov == 'C')) THEN --INCREMENTA EL NUMERO DE CARGOS APLICADOS
			
				UPDATE bditarjeta:td_archivos_conciliacion SET num_cargo = num_cargo + 1, monto_cargo = monto_cargo + (pmonto325 + pmontoCashBack325)  WHERE nombrearchivo = pnombrearchivo;
				
			ELIF ((P_COD_RET == '000') AND (ptipo_mov == 'A')) THEN --INCREMENTA EL NUMERO DE ABONOS APLICADOS
			
				UPDATE bditarjeta:td_archivos_conciliacion SET num_abono = num_abono + 1,monto_abono = monto_abono + (pmonto325 + pmontoCashBack325) WHERE nombrearchivo = pnombrearchivo;
				
			END IF;	
			
		ELSE --TRANSACCIONES QUE NO SE PROCESAN (CARGO O ABONO) 
			-- NO REALIZA EL PROCESO DE APLICACION Y ESTABLECE EL REGISTRO COMO FINALIZADO DE PROCESAR
			LET P_COD_RET = '00000'; 
		END IF;
	ELSE -- DEVOLUCIONES QUE NO APLICAN
		-- NO REALIZA EL PROCESO DE APLICACION Y ESTABLECE EL REGISTRO COMO FINALIZADO DE PROCESAR
		LET P_COD_RET = '00000'; 
	END IF;

	
   RETURN LPAD(TRIM(P_COD_RET), 5, '0'),P_MENSAJE,vid_proceso,vtransacion, ptipo_conciliacion, P_BANDERA;
   
END;
END PROCEDURE
DOCUMENT
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE MODIFICO LA LOGICA PARA LA APLICACION DE LAS DEVOLUCIONES, PARA QUE PERMITA APLICAR TODAS LAS TRANSACCIONES MENOS LOS ABONOS/DEVOLUCIONES CON TIPO_CONCILIACION  10 O 12.',
'Fecha: 2012/04/19',
'Version: 20120419.1756',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion -DEVOLUCIONES',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA QUE NO PERMITA PROCESAR LAS OPERACIONES DE TIPOS NO RELACIONADOS CON EL PROCESO DE CARGO Y ABONO.',
'Fecha: 2012/05/21',
'Version: 20120521.1547',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA EL PARAMETRO PARA MANDAR LA TRANSACCION DE CARGO.',
'Fecha: 2012/07/31',
'Version: 20120731.1214',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA LA LOGICA PARA ASIGNAR LOS VALORES REQUERIDOS (TIPO_MOV Y CUENTA) A LOS REGISTROS DE PNC PARA SU APLICACION.',
'Fecha: 2012/08/10',
'Version: 20120810.1051',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA LOGICA PARA GENERAR EL FOLIO_MOV PARA LOS REGISTROS PNC.',
'Fecha: 2012/08/13',
'Version: 20120813.1641',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA ASIGNAR LA LEY DE TRANSPARENCIA PARA LOS REGISTROS DE TIENDAS COPPEL.',
'Fecha: 2012/09/19',
'Version: 20120919.1730',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA OBTENER EL NUMERO DE CUENTA PARA TODOS LOS REGISTROS.',
'Fecha: 2012/09/20',
'Version: 20120920.1755',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA GENERAR CAMPO DE TRANSPARENCIA PARA LOS REGISTROS DE VND Y VNC.',
'Fecha: 2012/09/26',
'Version: 20120926.1031',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA PERMITIR LAS TRANSACCIONES TIPO 20 EN LOS ARCHIVOS VIC(MONEYGRAM) Y REALIZAR EL ABONO CON LA TRANSACCION CORRESPONDIENTE.',
'Fecha: 2012/10/01',
'Version: 20121001.1059',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: HOMOLOGACION DE CODIGO - INDICES',
'Fecha: 2012/10/12',
'Version: 20121012.1030',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martínez',
'Proyecto:  RQI 13 284 Aplicación Ley de transparencia para registros de devoluciones forzadas',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Actualizacion de Ley de transparencia para la devoluciones forzadas',
'Fecha: 2013/02/11',
'Version: 20130205.1600',
'BD: Bditarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martínez',
'Proyecto:  Integración de transacciones CashBack en proceso de conciliacion',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se agrego ciclo para validar aplicación de trasacciones en tres esenarios y formeteo de cadena para las tres transacciones ',
'Fecha: 2013/08/06',
'Version: 20130806.1500',
'BD: Bditarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martínez',
'Proyecto:  Integracion de Ley de transparencia para MASTER CARD ',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se agregaron los filtros pertinentes ',
'Fecha: 2014/04/04',
'Version: 20140404.1840',
'BD: Bditarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martínez',
'Proyecto: RQI 13 276 Transfer',
'Solicito: Jose Luis Puebla Salinas ',
'Descripcion: Se comenta codigo para la recuperacion de cuenta para no repetir procesos y se integra proceso para registro si la operacion es transfer',
'Fecha: 2014/08/28',
'Version: 20140828.1300',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martínez',
'Proyecto: RQI 13 276 Transfer',
'Solicito: Jose Luis Puebla Salinas ',
'Descripcion: Se aplica proceso para identificar las transacciones en el caso de operaciones que sean de Transfer',
'Fecha: 2014/10/08',
'Version: 20141008.1400',
'BD: BdiTarjeta',
'',
'MODIFICACION: CATIT - Christopher Jose Leyva Castro',
'Proyecto: RQI 32 492 Mejora conciliación automática primera parte 2024',
'Solicito: Gerencia de Producción ',
'Descripcion: Se realiza optimización a nivel sintaxis para aprovechar algunas llaves primarias',
'Fecha: 2024/10/22',
'BD: BdiTarjeta',
'MODIFICACION: CATIT - Luis Gerardo Martínez Rangel',
'Proyecto: Exclusión BIN SMARTVISTA de la conciliación ',
'Solicito: José Jaimes Ortiz ',
'Descripcion: Se realiza liberación para la esxclusión del BIN DE SMARTVISTA 42680711 y su aplicación sea en V ',
'Fecha: 2025/09/26',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_bf_extrae_tbl_mov (psFechaInicio VARCHAR(10) , psFechaFin VARCHAR(10))

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
			DEFINE RUTA_DESTINO 		 VARCHAR(80);
			DEFINE TIPO_PLANTILLA		 VARCHAR(30);
			DEFINE vsql					 CHAR(1150);
			DEFINE vExecuteSQL 			 LVARCHAR(1500);

	BEGIN	
		
		ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
				
		  LET CODIGO    = SQL_ERR;
		  LET MENSAJE_RPTA  = ERROR_INFO;
		  
		  RETURN CODIGO, MENSAJE_RPTA;
		  
		END EXCEPTION;
		
			--SET DEBUG FILE TO "/RESPALDOSNEW/Buen_Fin/bf2023_mov_debug.out";
			--TRACE ON;
			
				/* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL
				
				LET CODIGO					= '00000';
				LET MENSAJE_RPTA			= 'PROCESO EXITOSO';
				LET vdFechaInicio			= CURRENT;
				LET vdFechaFin				= CURRENT;
				LET RUTA_DESTINO	 		= '/RESPALDOSNEW/';
				LET TIPO_PLANTILLA	 		= '';
				LET vsql					= '';
				LET vExecuteSQL				= '';

				
			--SET ISOLATION TO dirty READ;
			--SET LOCK MODE TO WAIT 3;	
	
				/* Se da formato de fechahorainauth como se encuentra en movimiento*/
			
			LET vdFechaInicio = psFechaInicio || ' 00:00:00.00000';
			LET vdFechaFin 	  = psFechaFin || ' 23:59:59.99999';
							
				/* SE GENERA TABLA TEMPORAL CON LOS REGISTROS DE LA TABLA DE MOVIMIENTO */
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo "UNLOAD TO '||RUTA_DESTINO||'bf_movimiento.unl'||
		                          ' SELECT secuencia,numtarjeta,NVL (monto ,0 ) AS monto ,secuenciaextendida,fechahorainauth,referencia,prodind,codigoiso,'||
		                          ' movreversado,esnacional,movconciliado,formato,transaccionorigen,NVL (tipotransaccionposdigitada ,\"\" ) AS tipotransaccionposdigitada '||
		                          ' FROM Intercard:movimiento '||
		                          ' WHERE fechahorainauth BETWEEN '||"'"|| vdFechaInicio||"'"||' AND '||"'"|| vdFechaFin ||"'"||
		                          ' AND prodind = \"02\"		 		 	'||
		                          ' AND formato = \"0200\"  	 	 	 	'||
		                          ' AND codigoiso = \"00\"  	 	 	 	'||
		                          ' AND esnacional = \"V\" 		 	 	'||
		                          ' AND transaccionorigen = \"1234\" 	 	'||
		                          ' AND movreversado = \"F\"				'||							
		                          ' AND movconciliado IN (\"P\",\"V\")	'||
		                          ' AND monto >= 250	'||
								  'AND SUBSTRING(numtarjeta FROM 1 FOR 8) IN (SELECT bin FROM bditarjeta:bines_buenfin WHERE participa = \"V\") '||
		                          'AND pcc <> \"02\" '|| --Se excluyen cargos recurrentes
		                          ';" >'|| 
		        RUTA_DESTINO||'bf_mov.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #2
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'dbaccess intercard  '||RUTA_DESTINO||'bf_mov.sql';
				SYSTEM vExecuteSQL;
				
				---Paso #3
				LET vExecuteSQL = '';
				LET vExecuteSQL = "echo "||'"'|| "file '"|| RUTA_DESTINO ||
								  'bf_movimiento.unl' || "' delimiter '|' "|| '14'||
									"; insert into tbl_bf_movimientos_sorteo" || ";"||'"'||' > carga_movimientos.txt';
				SYSTEM vExecuteSQL;
				
				
				---Paso #4
				LET vExecuteSQL = '';
				LET vExecuteSQL = "dbload -d bditarjeta -c carga_movimientos.txt -l err_carga_mov.log -n 5000 -r";
				SYSTEM vExecuteSQL;			
				

				---Paso #5
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f '||RUTA_DESTINO||'bf_movimiento.unl';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm  -f '||RUTA_DESTINO||'bf_mov.sql'; 
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  carga_movimientos.txt';
				SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm -f  err_carga.log';
				SYSTEM vExecuteSQL;

		RETURN CODIGO, MENSAJE_RPTA;
	END
END PROCEDURE;