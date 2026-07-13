create procedure "informix".sp_transfer_obtenerregistroarchivo (
psnomarchivo varchar (50), 
psarchivoorigen varchar(3), 
pitipolayout integer, 
pscve_usuario varchar(10) 
)

returning 	varchar (5) as codret, 
			varchar(250) as mensaje_respuesta, 
			integer as Elemento;


/*  DEFINICION DE VARIABLES */

DEFINE viSQLerr INTEGER ;
DEFINE vsCodRet VARCHAR(5);
DEFINE vsMensaje_Respuesta VARCHAR(250);	
DEFINE vsRegistro CHAR(1650);

DEFINE vsFlagEnTransaccion VARCHAR (1);
DEFINE viContadorRegistros INTEGER;

-- Controlador de fases
define 	vielemento 			integer;
BEGIN

ON EXCEPTION SET viSQLerr
	-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
	IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
		COMMIT WORK;
		LET vsFlagEnTransaccion = 'F';
	END IF;
	BEGIN WORK;
	--BORRA LOS REGISTROS DEL ARCHIVO ALMACENADOS EN LA TABLA DE CARGA
	DELETE FROM bditransfer:"informix".tf_carga_transfer;
	COMMIT WORK;
	BEGIN WORK;
	--BORRA LOS REGISTROS QUE SE INSERTARON EN LA TABLA.
	IF (piTipoLayOut = 1) THEN
		DELETE FROM bditransfer:"informix".tf_account_balance_customer WHERE nombrearchivo = psNomArchivo AND Archivo_Origen = psArchivoOrigen;
	ELIF (piTipoLayOut = 2) THEN
		DELETE FROM bditransfer:"informix".tf_all_transaction WHERE NombreArchivo = psNomArchivo AND Archivo_Origen = psArchivoOrigen;
	ELIF (piTipoLayOut = 10) THEN
		DELETE FROM bditransfer:"informix".tf_user_transfer WHERE NombreArchivo = psNomArchivo AND Archivo_Origen = psArchivoOrigen;
	ELIF (piTipoLayOut = 12) THEN
		DELETE FROM bditransfer:"informix".tf_assign_nip WHERE NombreArchivo = psNomArchivo AND Archivo_Origen = psArchivoOrigen;
	ELIF (piTipoLayOut = 4) THEN
		DELETE FROM bditransfer:"informix".tf_comision_transac WHERE NombreArchivo = psNomArchivo AND Archivo_Origen = psArchivoOrigen;
	ELIF (piTipoLayOut = 11) THEN
		DELETE FROM bditransfer:"informix".tf_retire_customer WHERE NombreArchivo = psNomArchivo AND Archivo_Origen = psArchivoOrigen;
	ELIF (piTipoLayOut = 5) THEN
		DELETE FROM bditransfer:"informix".tf_success_transac WHERE NombreArchivo = psNomArchivo AND Archivo_Origen = psArchivoOrigen;
	ELIF (piTipoLayOut = 6) THEN
		DELETE FROM bditransfer:"informix".tf_unresolved_transac WHERE NombreArchivo = psNomArchivo AND Archivo_Origen = psArchivoOrigen;
	ELIF (piTipoLayOut = 3) THEN
		DELETE FROM bditransfer:"informix".tf_top_up WHERE NombreArchivo = psNomArchivo AND Archivo_Origen = psArchivoOrigen;
	ELIF (piTipoLayOut = 7) THEN
		DELETE FROM bditransfer:"informix".tf_settlement WHERE NombreArchivo = psNomArchivo AND Archivo_Origen = psArchivoOrigen;
	ELIF (piTipoLayOut = 15) THEN
		DELETE FROM bditransfer:"informix".tf_association_card WHERE NombreArchivo = psNomArchivo AND Archivo_Origen = psArchivoOrigen;
	ELIF (piTipoLayOut = 16) THEN
		DELETE FROM bditransfer:"informix".tf_cancelation_card WHERE NombreArchivo = psNomArchivo AND Archivo_Origen = psArchivoOrigen;
	ELIF (piTipoLayOut = 8) THEN
		DELETE FROM bditransfer:"informix".tf_outcapture WHERE NombreArchivo = psNomArchivo AND Archivo_Origen = psArchivoOrigen;
	ELIF (piTipoLayOut = 20) THEN
		DELETE FROM bditransfer:"informix".tf_administrative_transac WHERE NombreArchivo = psNomArchivo AND Archivo_Origen = psArchivoOrigen;
	ELIF (piTipoLayOut = 21) THEN
		DELETE FROM bditransfer:"informix".tf_settlement_bank WHERE NombreArchivo = psNomArchivo AND Archivo_Origen = psArchivoOrigen;	
	END IF;	
	COMMIT WORK;
	
	LET vsCodRet = '00200';	
	RETURN 	vsCodRet, 
			('ERROR NO CONTROLADO ' || viSQLerr || '. ARCHIVO ' || psNomArchivo || ' ' || TRIM(vsMensaje_Respuesta) ),
			vielemento;
	
END EXCEPTION;

--set debug file to "/informix/HomeInformix/rrm/sp_transfer_obtenerregistroarchivo.out";
--trace on;

/* INICIALIZACION DE VARIABLES */
LET viSQLerr = 0;    
 
LET vsCodRet = '00000';
LET vsMensaje_Respuesta = 'CARGA DE LAYOUT ' || piTipoLayOut ;
LET vsRegistro  = '';

LET vsFlagEnTransaccion = '';
LET viContadorRegistros = 0;

-- Controlador de fases
let vielemento = 0;


LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;
	
SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;
--RECORRE LA TABLA PARA OBTENER LOS REGISTROS
FOREACH WITH HOLD 
	SELECT Registro	INTO vsRegistro
	FROM bditransfer:"informix".tf_carga_transfer
		
		--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (vsFlagEnTransaccion = 'F') THEN 
			
			BEGIN WORK;
			 LET vsFlagEnTransaccion = 'V';
		END IF;
		
	IF (piTipoLayOut = 1) THEN -- tf_account_balance_customer ###"CBA"###
	 
		INSERT INTO bditransfer:"informix".tf_account_balance_customer 
			(	nombrearchivo,archivo_origen,cuenta,sdo_cta,fecha_proceso,fech_ult_mov,telefono,numtarjeta	)
			VALUES
			(
				psNomArchivo,
				psArchivoOrigen,
				TRIM(SUBSTR(vsregistro,3,11)),  --CUENTA
				((TRIM(SUBSTR(vsregistro,14,17))::MONEY)/100), --SALDO DE LA CUENTA ( ( REPLACE( psMonto325,'.',''))::MONEY /100 );
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 31,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,35,2)||'-'||SUBSTR(vsregistro,37,2)||'-'||SUBSTR(vsregistro,31,4))  --FECHA PROCESO
							ELSE 
								'01-01-1900'
							END, 
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 39,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,43,2)||'-'||SUBSTR(vsregistro,45,2)||'-'||SUBSTR(vsregistro,39,4))  --FECHA ULTIMO MOVIMIENTO
							ELSE 
								'01-01-1900'
							END, 
				TRIM(SUBSTR(vsregistro,47,10)),  --TELEFONO
				TRIM(SUBSTR(vsregistro,57,16)) --NUM TARJETA */
			);
	ELIF (piTipoLayOut = 2) THEN -- tf_all_transaction  ### ALT ###
		INSERT INTO bditransfer:"informix".tf_all_transaction 
			(	nombrearchivo,archivo_origen,cuenta,transacc,fech_alt,fech_hor_ini,fech_hor_fin,secuencia,id_banco_origen,tpo_id_origen,id_cuenta_origen,monto,
			id_banco_destino ,tpo_id_destino ,id_cuenta_destino,metodo_acceso,tpo_acceso,estatus_transac,sdo_cuenta_origen,sdo_cuenta_destino,motivo,		
			/*referencia,*/comision,iva,tasa_iva,id_transac,id_reverso,naturaleza,id_transacc_mps,id_receptor,id_devolucion,clave_rastreo,numero_referencia,concepto_pago,nombre_completo_spei )
			VALUES
			(
				psNomArchivo,
				psArchivoOrigen,
				TRIM(SUBSTR(vsregistro,3,11)),  --CUENTA
				TRIM(SUBSTR(vsregistro,14,4)),  --NUMERO DE TRANSACCION
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 18,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,22,2)||'-'||SUBSTR(vsregistro,24,2)||'-'||SUBSTR(vsregistro,18,4))  --FECHA DE REGISTRO
							ELSE 
								'01-01-1900'
							END, 
				TRIM('1900-01-01 '||SUBSTR(vsregistro,26,8)),  --HORA DE INICIO DE LA TRANSACCION
				TRIM('1900-01-01 '||SUBSTR(vsregistro,34,8)),  --HORA DE FIN DE LA TRANSACCION
				TRIM(SUBSTR(vsregistro,42,8)),  --NUMERO DE AUTORIZACION DE 6 MAS 2 CEROS A LA IZQ.
				TRIM(SUBSTR(vsregistro,50,3)),  --ID DE BANCO ORIGEN
				TRIM(SUBSTR(vsregistro,53,2)),  --ID DE CUENTA ORIGEN
				TRIM(SUBSTR(vsregistro,55,18)),  --clave cuenta origen  ( CLABE, Número de tarjeta, MSISDN).
				(((SUBSTR(vsregistro,73,17))::MONEY)/100), --MONTO DE LA TRANSACCION
				TRIM(SUBSTR(vsregistro,90,3)),  --ID DE BANCO DESTINO
				TRIM(SUBSTR(vsregistro,93,2)),  --ID DE CUENTA DESTINO
				TRIM(SUBSTR(vsregistro,95,18)),  --clave cuenta destino  ( CLABE, Número de tarjeta, MSISDN).
				TRIM(SUBSTR(vsregistro,113,3)),  --METODO DE ACCESO -- ##### RQM 10 651 Se amplia recuperación de 2 a 3 #####
				TRIM(SUBSTR(vsregistro,116,2)),  --TIPO DE ACCESO
				TRIM(SUBSTR(vsregistro,147,2)),  --ESTATUS DE LA TRANSACCION
				(((SUBSTR(vsregistro,149,17))::MONEY)/100), --SALDO CUENTA ORIGEN
				(((SUBSTR(vsregistro,166,17))::MONEY)/100), --SALDO CUENTA DESTINO
				TRIM(SUBSTR(vsregistro,183,20)),  --MENSAJE DE ERROR
				--TRIM('00000000000000000000000'), ---  --REFERENCIA 23    ---- Se omite " RQM 10 730 " 
				(((SUBSTR(vsregistro,226,17))::MONEY)/100),  --COMISION
				(((SUBSTR(vsregistro,243,17))::MONEY)/100),  --IVA
				TRIM(SUBSTR(vsregistro,260,2)),  --TASA IVA %
				TRIM(SUBSTR(vsregistro,262,15)),  --ID DE LA TRANSACCION BANCO
				TRIM(SUBSTR(vsregistro,277,20)),  --ID REVERSO
				TRIM(SUBSTR(vsregistro,297,1)),  --NATURALEZA DE LA TRANSACCION
				TRIM(SUBSTR(vsregistro,298,20)),  --ID DE LA TRANSACCION MPS
				TRIM(SUBSTR(vsregistro,318,16)),  --ID DE LA TIENDA
				TRIM(SUBSTR(vsregistro,334,20)),  --ID DE LA TRANSACCION ORIGEN A REVERSAR	
                --- Añadir campos para el rastreo SPEI "RQM 10 730  "
                TRIM(SUBSTR(vsregistro,354,30)),      ---- Cve Rastreo 
                TRIM(SUBSTR(vsregistro,384,7)),      ---- Numero_referencia 
                TRIM(SUBSTR(vsregistro,391,40)),      ---- Concepto_pago  
				 --- Nuevo campo - RQM 10 1098 Cuenta Móvil-Actualizacion de Reportes
				TRIM(SUBSTR(vsregistro,471,60))      ---- nombre_completo_spei				
			);						                
			
	ELIF (piTipoLayOut = 10) THEN --  tf_user_transfer  ### ACT ###
	 
		INSERT INTO bditransfer:"informix".tf_user_transfer 
			(nombrearchivo,archivo_origen,cuenta,numcte,rfc,telefono,no_clave,numtarjeta,tpo_tarjeta ,cta_fondeo,nom_cliente,fecha_nac,calle,no_ext,no_int,colonia,
			poblacion,estado,pais,cod_postal,email,tpo_cta,status_cta,status_serv ,status_tarj ,sdo_cta,fecha_sdo,no_aclaracion,transac_one,fecha_alta,fecha_baja,
			fecha_alta_serv,fecha_baja_serv ,fecha_alta_tar,fecha_baja_tar,fecha_ult_transac,fecha_corte ,sucursal_ori,id_external,metodo_acceso,asigna_nip,password,
			hora_alta,fecha_mod,hora_mod,curp,fecha_valida_ren,estatus_renapo,no_valida_ren ,desc_renapo,no_mod,sexo,estado_alta,tpo_actualiza,no_actualiza, folio_operacion)
			VALUES
			(
				psNomArchivo,
				psArchivoOrigen,
				TRIM(SUBSTR(vsregistro,2,11)),  --CUENTA
				TRIM(SUBSTR(vsregistro,14,12)),  --NUMERO DE CLIENTE
				TRIM(SUBSTR(vsregistro,26,13)),  --RFC
				TRIM(SUBSTR(vsregistro,39,10)),  --TELEFONO
				TRIM(SUBSTR(vsregistro,49,18)),  --CUENTA CLABE
				SUBSTR(vsregistro,67,16),  --NUMERO DE TARJETA 
				SUBSTR(vsregistro,83,2),  --TIPO DE TARJETA 
				TRIM(SUBSTR(vsregistro,85,12)),  --CUENTA DE FONDEO
				TRIM(SUBSTR(vsregistro,97,200)),  --NOMBRE DEL CLIENTE (Nombre(s)/Apellido Paterno, Apellido Materno.).
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 297,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,301,2)||'-'||SUBSTR(vsregistro,303,2)||'-'||SUBSTR(vsregistro,297,4))  --FECHA DE NACIMIENTO
							ELSE 
								'01-01-1900'
							END, 
				TRIM(SUBSTR(vsregistro,305,200)),  --CALLE
				TRIM(SUBSTR(vsregistro,505,9)),  --NUMERO DE EXTERIOR
				TRIM(SUBSTR(vsregistro,514,10)),  --NUMERO DE INTERIOR
				TRIM(SUBSTR(vsregistro,524,100)),  --COLONIA
				TRIM(SUBSTR(vsregistro,624,50)),  --POBLACION
				TRIM(SUBSTR(vsregistro,674,9))::INTEGER,  --ESTADO
				TRIM(SUBSTR(vsregistro,683,9))::INTEGER,  --PAIS
				TRIM(SUBSTR(vsregistro,692,6)),  --CODIGO POSTAL
				TRIM(SUBSTR(vsregistro,698,50)),  --E MAIL
				SUBSTR(vsregistro,748,2),  --TIPO DE CUENTA
				SUBSTR(vsregistro,750,2),  --ESTATUS CUENTA
				SUBSTR(vsregistro,752,2),  --ESTATUS SERVICIO
				SUBSTR(vsregistro,754,2),  --ESTATUS TARJETA
				(((SUBSTR(vsregistro,756,17))::MONEY)/100), --SALDO DE LA CUENTA 
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 773,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,777,2)||'-'||SUBSTR(vsregistro,779,2)||'-'||SUBSTR(vsregistro,773,4))  --FECHA DEL SALDO
							ELSE 
								'01-01-1900'
							END, 				
				(SUBSTR(vsregistro,781,2)),  --NUMERO DE ACLARACION
				(SUBSTR(vsregistro,783,4)),  --ID PRIMERA TXN
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 787,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,791,2)||'-'||SUBSTR(vsregistro,793,2)||'-'||SUBSTR(vsregistro,787,4))  --FECHA DEL REGISTRO DE LA CUENTA
							ELSE 
								'01-01-1900'
							END, 				
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 795,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,799,2)||'-'||SUBSTR(vsregistro,801,2)||'-'||SUBSTR(vsregistro,795,4))  --FECHA DE CANCELACION DE CUENTA
							ELSE 
								'01-01-1900'
							END, 				
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 803,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,807,2)||'-'||SUBSTR(vsregistro,809,2)||'-'||SUBSTR(vsregistro,803,4))  --FECHA DE ALTA TELEFONO.
							ELSE 
								'01-01-1900'
							END, 				
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 811,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,815,2)||'-'||SUBSTR(vsregistro,817,2)||'-'||SUBSTR(vsregistro,811,4))  --FECHA DE BAJA TELEFONO
							ELSE 
								'01-01-1900'
							END, 				
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 819,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,823,2)||'-'||SUBSTR(vsregistro,825,2)||'-'||SUBSTR(vsregistro,819,4))  --FECHA DE ALTA TARJETA
							ELSE 
								'01-01-1900'
							END, 				
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 827,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,831,2)||'-'||SUBSTR(vsregistro,833,2)||'-'||SUBSTR(vsregistro,827,4))  --FECHA DE BAJA TARJETA
							ELSE 
								'01-01-1900'
							END, 		
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 835,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,839,2)||'-'||SUBSTR(vsregistro,841,2)||'-'||SUBSTR(vsregistro,835,4))  --FECHA DE ULTIMA TRANSACCION
							ELSE 
								'01-01-1900'
							END, 		
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 843,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,847,2)||'-'||SUBSTR(vsregistro,849,2)||'-'||SUBSTR(vsregistro,843,4))  --FECHA DE GENERACION DE ESTADO DE CUENTA
							ELSE 
								'01-01-1900'
							END, 		
				TRIM(SUBSTR(vsregistro,1468,16)),  --SUCURSAL ORIGEN
				(SUBSTR(vsregistro,1484,12)),  --ID EXTERNO
				(SUBSTR(vsregistro,1496,2)),  --METODO DE ACCESO
				(SUBSTR(vsregistro,1498,1)),  --TIENE NIP ASIGNADO
				(SUBSTR(vsregistro,1499,1)),  --TIENE PASSWORD ASIGNADO
				TRIM('1900-01-01 '||SUBSTR(vsregistro,1500,2)||':'||SUBSTR(vsregistro,1502,2)||':'||SUBSTR(vsregistro,1504,2)),  --HORA EN QUE SE CREO LA CUENTA
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 1506,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,1510,2)||'-'||SUBSTR(vsregistro,1512,2))||'-'||SUBSTR(vsregistro,1506,4)  --FECHA EVOLUCION CLIENTE
							ELSE 
								'01-01-1900'
							END, 		
				TRIM('1900-01-01 '||SUBSTR(vsregistro,1514,8)),  --HORA DE EVOUCION DE LA CUENTA
				(SUBSTR(vsregistro,1522,18)),  --CURP
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 1546,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,1543,2)||'-'||SUBSTR(vsregistro,1540,2)||'-'||SUBSTR(vsregistro,1546,4))  --FECHA VALIDACION CONTRA RENAPO
							ELSE 
								'01-01-1900'
							END, 		
				TRIM(SUBSTR(vsregistro,1550,3)),  --ESTATUS RENAPO
				TRIM(SUBSTR(vsregistro,1553,1)),  --NUMERO DE VALIDACIONES RENAPO
				TRIM(SUBSTR(vsregistro,1554,40)),  --OBSERVACIONES RENAPO
				TRIM(SUBSTR(vsregistro,1592,3))::INTEGER,  --NUMERO DE MODIFICACION
				(SUBSTR(vsregistro,1595,1)),  --GENERO
				(SUBSTR(vsregistro,1596,20)),  --ENTIDAD FEDERATIVA
				(SUBSTR(vsregistro,1616,1)),  --TIPO IDENTIFICACION
				(SUBSTR(vsregistro,1618,13)),  --NUMERO DE IDENTIFICACION 
				(SUBSTR(vsregistro,1631,12))   -- FOLIO OPERACION ADMINISTRATIVA
			);
	ELIF (piTipoLayOut = 12) THEN --  tf_assign_nip   ### SCN ###
	 
	    INSERT INTO bditransfer:"informix".tf_assign_nip
			(	nombrearchivo,archivo_origen,cuenta,telefono,numcte,asigna_nip,no_nip,fech_alta_nip,status_cta,status_serv,status_nip,fech_mod_nip)
			VALUES
			(
				psNomArchivo,                                            
				psArchivoOrigen,                                         
				TRIM(SUBSTR(vsregistro,2,11)) ,   --CUENTA                   
				TRIM(SUBSTR(vsregistro,14,10)),  --TELEFONO                
				TRIM(SUBSTR(vsregistro,24,12)),  --NUMERO DE CLIENTE       
				TRIM(SUBSTR(vsregistro,36,2)) ,   --TIENE NIP ASIGNADO	   
		        ' ',  --NO_NIP         
			    CASE WHEN (TRIM(SUBSTR(vsRegistro, 38,8))) <> '00000000' THEN   
			     (SUBSTR(vsregistro,40,2)||'-'||SUBSTR(vsregistro,38,2)||'-'||SUBSTR(vsregistro,42,4))  --FECHA ALTA NIP 
			      ELSE 
                     '01-01-1900'
				  END,
				TRIM(SUBSTR(vsregistro,46,2)) ,   --ESTATUS CUENTA      
				TRIM(SUBSTR(vsregistro,48,2)) ,   --ESTATUS SERVICIO    
				TRIM(SUBSTR(vsregistro,50,2)) ,    --ESTATUS DEL NIP  
		        	CASE WHEN (TRIM(SUBSTR(vsRegistro, 52,8))) <> '00000000' THEN   
			     (SUBSTR(vsregistro,54,2)||'-'||SUBSTR(vsregistro,52,2)||'-'||SUBSTR(vsregistro,56,4))  --FECHA MOD. NIP  
			      ELSE 
                     '01-01-1900'
				  END
			);

			
	ELIF (piTipoLayOut = 4) THEN --  tf_comision_transac   ### TEC ###
	 
		INSERT INTO bditransfer:"informix".tf_comision_transac
			(	nombrearchivo,archivo_origen,tpo_cta,fecha_alt,monto,cant_transac,comision,iva)
			VALUES
			(
				psNomArchivo,
				psArchivoOrigen,
				TRIM(SUBSTR(vsregistro,2,4)),  --TIPO DE TRANSACCION
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 6,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,10,2)||'-'||SUBSTR(vsregistro,12,2)||'-'||SUBSTR(vsregistro,6,4))  --FECHA DE LA TRANSACCION
							ELSE 
								'01-01-1900'
							END, 		
				(((SUBSTR(vsregistro,14,17))::MONEY)/100),  --MONTO
				SUBSTR(vsregistro,31,6)::INTEGER, --CANTIDAD DE TRANSACCIONES
				(((SUBSTR(vsregistro,37,17))::MONEY)/100),  --COMISION
				(((SUBSTR(vsregistro,54,17))::MONEY)/100)  --IVA
			);
			
	ELIF (piTipoLayOut = 11) THEN -- tf_retire_customer   ### BCT ###
	 
		INSERT INTO bditransfer:"informix".tf_retire_customer
			(	nombrearchivo,archivo_origen,cuenta,fecha_cancela,hora_cancela,telefono,numtarjeta,metodo_cancela, no_aut_cliente_cancelado, renapo_estatus,folio_operacion, 
			    monto_transfertobank, fecha_transfertobank, motivo_cancelacion,id_txn_transfertobank) -- new
			VALUES
			(
				psNomArchivo,
				psArchivoOrigen,
				TRIM(SUBSTR(vsregistro,3,11)),  --CUENTA
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 14,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,18,2)||'-'||SUBSTR(vsregistro,20,2)||'-'||SUBSTR(vsregistro,14,4))  --FECHA DE LA CANCELACION
							ELSE 
								'01-01-1900'
							END, 		
				TRIM('1900-01-01 '||SUBSTR(vsregistro,22,2)||':'||SUBSTR(vsregistro,24,2)||':'||SUBSTR(vsregistro,26,2)),  --HORA EN QUE SE CANCELO LA CUENTA
				SUBSTR(vsregistro,28,10), --TELEFONO			
				SUBSTR(vsregistro,38,16),  --NUM TARJETA
				SUBSTR(vsregistro,54,4),  --METODO CANCELACION
				SUBSTR(vsregistro,58,8),    --no_aut_cliente_cancelado
				SUBSTR(vsregistro,66,3), 	--renapo_estatus
				SUBSTR(vsregistro,69,12), 	--folio_operacion_administrativa
						--- Nuevos campos - RQM 10 1098 Cuenta Móvil-Actualizacion de Reportes
				(((SUBSTR(vsregistro,81,18))::MONEY)/100), --monto_transfertobank				
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 99,8))) <> '00000000' THEN    
								(SUBSTR(vsregistro,103,2)||'-'||SUBSTR(vsregistro,105,2)||'-'||SUBSTR(vsregistro,99,4))  --fecha_transfertobank
							ELSE 
								'01-01-1900'
							END, 						
				SUBSTR(vsregistro,107,3), 	--motivo_cancelacion   
				SUBSTR(vsregistro,110,20) 	--id_txn_transfertobank   
			);
	
	ELIF (piTipoLayOut = 5) THEN --  tf_success_transac  ### TME ###
	 
		INSERT INTO bditransfer:"informix".tf_success_transac
			(	nombrearchivo,archivo_origen,cuenta,transacc,fecha_alt,fech_hor_ini,fech_hor_fin,secuencia,id_banco_origen,tpo_id_origen,
				id_cuenta_origen ,monto,id_banco_destino,tpo_id_destino ,id_cuenta_destino,metodo_acceso,tpo_acceso,estatus_transac,
				sdo_cuenta_origen,sdo_cuenta_destino,referencia,comision,iva,tasa_iva,id_transac,id_reverso,tpo_mov,id_transacc_mps,id_receptor, folio_suc)
			VALUES
			(
				psNomArchivo,
				psArchivoOrigen,
				TRIM(SUBSTR(vsregistro,3,11)),  --CUENTA
				TRIM(SUBSTR(vsregistro,14,4)), -- NUMERO DE TRANSACCION
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 18,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,22,2)||'-'||SUBSTR(vsregistro,24,2)||'-'||SUBSTR(vsregistro,18,4))  --FECHA DE TRANSACCION
							ELSE 
								'01-01-1900'
							END, 		
				('1900-01-01 '||SUBSTR(vsregistro,26,8)), --HORA INICIO TRANSACCION
				('1900-01-01 '||SUBSTR(vsregistro,34,8)), --HORA FIN TRANSACCION
				TRIM(SUBSTR(vsregistro,42,8)), --SECUENCIA
				TRIM(SUBSTR(vsregistro,50,3)), --ID BANCO ORIGEN
				TRIM(SUBSTR(vsregistro,53,2)), --TIPO DE ID BANCO ORIGEN
				TRIM(SUBSTR(vsregistro,55,18)), --CUENTA ORIGEN
				(((SUBSTR(vsregistro,73,17))::MONEY)/100), --MONTO
				TRIM(SUBSTR(vsregistro,90,3)), --ID BANCO DESTINO
				TRIM(SUBSTR(vsregistro,93,2)), --TIPO DE ID BANCO DESTINO
				TRIM(SUBSTR(vsregistro,95,18)), --CUENTA DESTINO
				TRIM(SUBSTR(vsregistro,113,3)), --METODO DE ACCESO    -- ##### RQM 10 651 Se amplia recuperación de 2 a 3 #####
				TRIM(SUBSTR(vsregistro,116,2)), --TIPO ACCESO
				TRIM(SUBSTR(vsregistro,147,2)), --ESTATUS TRANSACCION
				(((SUBSTR(vsregistro,149,17))::MONEY)/100), --SALDO CUENTA ORIGEN
				(((SUBSTR(vsregistro,166,17))::MONEY)/100), --SALDO CUENTA DESTINO
				TRIM(SUBSTR(vsregistro,203,23)), --REFERENCIA
				(((SUBSTR(vsregistro,226,17))::MONEY)/100), --COMISION
				(((SUBSTR(vsregistro,243,17))::MONEY)/100), --IVA
				TRIM(SUBSTR(vsregistro,260,2)), --TASA IVA
				TRIM(SUBSTR(vsregistro,262,15)), --ID TRANSAC
				TRIM(SUBSTR(vsregistro,277,20)), --ID REVERSO
				SUBSTR(vsregistro,297,1), --TIPO DE MOVIMIENTO
				(SUBSTR(vsregistro,298,20)), --ID TRANSACCION MPS
				SUBSTR(vsregistro,318,16), --TIPO DE MOVIMIENTO
				TRIM('t'||SUBSTR(vsregistro,22,2)||SUBSTR(vsregistro,24,2)||SUBSTR(vsregistro,26,2)||SUBSTR(vsregistro,29,2)||SUBSTR(vsregistro,44,6))  -- Folio_SUC
			);
	
	ELIF (piTipoLayOut = 6) THEN --  tf_unresolved_transac   ### TMF ###
	 
		INSERT INTO bditransfer:"informix".tf_unresolved_transac
			(	nombrearchivo,archivo_origen,cuenta,transacc,fecha_alt,fech_hor_ini,fech_hor_fin,secuencia,id_banco_origen,tpo_id_origen,
				id_cuenta_origen ,monto,id_banco_destino,tpo_id_destino ,id_cuenta_destino,metodo_acceso,tpo_acceso,estatus_transac,
				sdo_cuenta_origen,sdo_cuenta_destino,motivo,referencia,comision,iva,tasa_iva,id_transac,id_reverso,tpo_mov,id_transacc_mps,id_receptor,clave_rastreo,numero_referencia,concepto_pago	)
			VALUES
			(
				psNomArchivo,
				psArchivoOrigen,
				TRIM(SUBSTR(vsregistro,3,11)),  --CUENTA
				TRIM(SUBSTR(vsregistro,14,4)), -- NUMERO DE TRANSACCION
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 18,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,22,2)||'-'||SUBSTR(vsregistro,24,2)||'-'||SUBSTR(vsregistro,18,4))  --FECHA DE TRANSACCION
							ELSE 
								'01-01-1900'
							END, 		
				('1900-01-01 '||SUBSTR(vsregistro,26,8)), --HORA INICIO TRANSACCION
				('1900-01-01 '||SUBSTR(vsregistro,34,8)), --HORA FIN TRANSACCION
				TRIM(SUBSTR(vsregistro,42,8)), --SECUENCIA
				TRIM(SUBSTR(vsregistro,50,3)), --ID BANCO ORIGEN
				TRIM(SUBSTR(vsregistro,53,2)), --TIPO DE ID BANCO ORIGEN
				TRIM(SUBSTR(vsregistro,55,18)), --CUENTA ORIGEN
				(((SUBSTR(vsregistro,73,17))::MONEY)/100), --MONTO
				TRIM(SUBSTR(vsregistro,90,3)), --ID BANCO DESTINO
				TRIM(SUBSTR(vsregistro,93,2)), --TIPO DE ID BANCO DESTINO
				TRIM(SUBSTR(vsregistro,95,18)), --CUENTA DESTINO
				TRIM(SUBSTR(vsregistro,113,3)), --METODO DE ACCESO  -- ##### RQM 10 651 Se amplia recuperación de 2 a 3 #####
				TRIM(SUBSTR(vsregistro,116,2)), --TIPO ACCESO
				TRIM(SUBSTR(vsregistro,147,2)), --ESTATUS TRANSACCION
				(((SUBSTR(vsregistro,149,17))::MONEY)/100), --SALDO CUENTA ORIGEN
				(((SUBSTR(vsregistro,166,17))::MONEY)/100), --SALDO CUENTA DESTINO
				SUBSTR(vsregistro,183,20), --MOTIVO DEL ERROR **_**
				TRIM(SUBSTR(vsregistro,203,23)), --REFERENCIA
				(((SUBSTR(vsregistro,226,17))::MONEY)/100), --COMISION
				(((SUBSTR(vsregistro,243,17))::MONEY)/100), --IVA
				TRIM(SUBSTR(vsregistro,260,2)), --TASA IVA
				TRIM(SUBSTR(vsregistro,262,15)), --ID TRANSAC
				TRIM(SUBSTR(vsregistro,277,20)), --ID REVERSO
				SUBSTR(vsregistro,297,1), --TIPO DE MOVIMIENTO
				(SUBSTR(vsregistro,298,20)), --ID TRANSACCION MPS
				SUBSTR(vsregistro,318,16), --ID receptor
				-- Añadir campos para el rastreo SPEI "RQM 10 730  "
                TRIM(SUBSTR(vsregistro,334,30)),      ---- Cve Rastreo 
                TRIM(SUBSTR(vsregistro,364,7)),      ---- Numero_referencia 
                TRIM(SUBSTR(vsregistro,371,40))      ---- Concepto_pago  
			);
			
	ELIF (piTipoLayOut = 3) THEN --  tf_top_up (TIEMPO AIRE)  ### TTE ###
	 
		INSERT INTO bditransfer:"informix".tf_top_up
			(nombrearchivo,archivo_origen,cod_proceso,secuencia,fech_alt,fech_hor_ini,idcadena,idretailer,idterminal,
			moneda,monto,telefono,no_txn_telcel)
			VALUES
			(
				psNomArchivo,
				psArchivoOrigen,
				SUBSTR(vsregistro,1,6), -- CODIGO DE PROCESO
				TRIM(SUBSTR(vsregistro,7,10)),  --SECUENCIA
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 17,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,21,2)||'-'||SUBSTR(vsregistro,23,2)||'-'||SUBSTR(vsregistro,17,4))  --FECHA DE TRANSACCION
							ELSE 
								'01-01-1900'
							END, 		
				TRIM('1900-01-01 '||SUBSTR(vsregistro,25,2)||':'||SUBSTR(vsregistro,27,2)||':'||SUBSTR(vsregistro,29,2)),  --HORA TRANSACCION
				TRIM(SUBSTR(vsregistro,31,10)),  --ID DE LA CADENA COMERCIAL
				TRIM(SUBSTR(vsregistro,41,5)),  --ID DEL COMERCIO
				TRIM(SUBSTR(vsregistro,46,10)),  --ID POS
				SUBSTR(vsregistro,56,3), -- MONEDA
				(((SUBSTR(vsregistro,59,10))::MONEY)/100), --MONTO DE LA TRANSACCION
				SUBSTR(vsregistro,69,10), -- TELEFONO
				SUBSTR(vsregistro,79,6) -- NUMERO DE TRANSACION TELCEL
			);
			
	ELIF (piTipoLayOut = 7) THEN -- tf_settlement  ### TIE ###
	 
		INSERT INTO bditransfer:"informix".tf_settlement  
			(nombrearchivo,archivo_origen,fech_alt,id_cuenta_origen,id_banco_origen,id_cuenta_destino,id_banco_destino,monto,id_transacc_mps,
			tpo_id_origen,tpo_id_destino)
			VALUES
			(
				psNomArchivo,
				psArchivoOrigen,
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 1,4))) <> '0000' THEN 
								SUBSTR(vsregistro,1,4)||'-'||(SUBSTR(vsregistro,5,2)||'-'||SUBSTR(vsregistro,7,2)||' '||SUBSTR(vsregistro,9,2)||':'||SUBSTR(vsregistro,11,2)||':00') --FECHA DE LA TRANSACCION SON SEGUNDOS.
							ELSE 
								'01-01-1900 00:00:00'
							END, 		
				TRIM(SUBSTR(vsregistro,13,18)),  --CUENTA ORIGEN
				TRIM(SUBSTR(vsregistro,31,3)),  --ID BANCO ORIGEN
				TRIM(SUBSTR(vsregistro,34,18)),  --CUENTA DESTINO
				TRIM(SUBSTR(vsregistro,52,3)),  --ID BANCO DESTINO
				(((SUBSTR(vsregistro,55,17))::MONEY)/100), --MONTO DE LA TRANSACCION
				SUBSTR(vsregistro,72,12), --ID TRANSACCION MPS
				SUBSTR(vsregistro,84,2), -- TIPO ID ORIGEN
				SUBSTR(vsregistro,86,2) -- TIPO ID DESTINO
			);
			
	ELIF (piTipoLayOut = 15) THEN -- tf_association_card   ### RAT ###
	 
		INSERT INTO bditransfer:"informix".tf_association_card
			(nombrearchivo,archivo_origen,id_asociacion,numtarjeta,fech_alt,fech_hor_ini,cuenta,metodo_acceso,razon_asoc)
			VALUES
			(
				psNomArchivo,
				psArchivoOrigen,
				TRIM(SUBSTR(vsregistro,10,4)),  --ID DE ASOCIACION
				TRIM(SUBSTR(vsregistro,14,16)),  --NUMERO DE TARJETA
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 30,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,34,2)||'-'||SUBSTR(vsregistro,36,2)||'-'||SUBSTR(vsregistro,30,4))  --FECHA DE TRANSACCION
							ELSE 
								'01-01-1900'
							END, 		
				TRIM('1900-01-01 '||SUBSTR(vsregistro,38,8)),  --HORA DE LA TRANSACCION
				TRIM(SUBSTR(vsregistro,227,11)),  -- NUMERO DE CUENTA
				TRIM(SUBSTR(vsregistro,238,2)),  -- METODO DE ACCESO
				TRIM(SUBSTR(vsregistro,240,20))  -- RAZON DE LA ASOCIACION
			);
	ELIF (piTipoLayOut = 16) THEN -- tf_cancelation_card ###  RCT ###
	 
		INSERT INTO bditransfer:"informix".tf_cancelation_card
			(nombrearchivo,archivo_origen,id_cancelacion,numtarjeta,fech_alt,fech_hor_ini,cuenta)
			VALUES
			(
				psNomArchivo,
				psArchivoOrigen,
				TRIM(SUBSTR(vsregistro,10,4)),  --ID DE CANCELACION
				TRIM(SUBSTR(vsregistro,14,16)),  --NUMERO DE TARJETA
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 33,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,37,2)||'-'||SUBSTR(vsregistro,39,2)||'-'||SUBSTR(vsregistro,33,4))
							ELSE 
								'01-01-1900'
							END, 		
				TRIM('1900-01-01 '||SUBSTR(vsregistro,41,8)),  --HORA DE LA TRANSACCION
				TRIM(SUBSTR(vsregistro,230,11))  -- NUMERO DE CUENTA
			);
			
	ELIF (piTipoLayOut = 8) THEN --  tf_outcapture  ### TAT ###
	 
		INSERT INTO bditransfer:"informix".tf_outcapture
			(nombrearchivo,archivo_origen,id_banco,status,cuenta,secuencia,monto,id_negocio,referencia_batch,limite_piso,dias_ajuste,
			fecha_alta,inf_comercio,poblacion,tpo_batch,califica,secuencia_txn,reservado1,referencia_23,num_busca,monto_dlr,monto_dev,
			reservado3,pais,tpo_negocio,cargos_parc,rembolso,monedero_elect,cve_esp,reservado4,moneda_liq,moneda_txn,fecha_conv,
			tpo_cambio,mensual,id_transp,rfc,cod_error,msn_error,id_transacc_mps, id_payment_transacc_mps) --MPS PAYMENT TRANSACTION ID
			VALUES
			(
				psNomArchivo,
				psArchivoOrigen,
				TRIM(SUBSTR(vsregistro,1,7)),  --ID DE Banco
				SUBSTR(vsregistro,9,1),  --ESTATUS
				TRIM(SUBSTR(vsregistro,10,20)),  --CUENTA
				TRIM(SUBSTR(vsregistro,30,6)),  --SECUENCIA
				(((SUBSTR(vsregistro,36,12))::MONEY)/100), --MONTO DE LA TRANSACCION
				TRIM(SUBSTR(vsregistro,48,9)),  --ID DEL NEGOCIO
				TRIM(SUBSTR(vsregistro,57,5)),  --REFERENCIA BATCH
				TRIM(SUBSTR(vsregistro,62,3)),  --LIMITE DE PISO
				TRIM(SUBSTR(vsregistro,65,2)),  --DIAS DE AJUSTE
				TRIM(SUBSTR(vsregistro,67,6)),  --FECHA DE LA TRANSAC   -- Se modifico JFPD
				TRIM(SUBSTR(vsregistro,73,26)),  --INFORMACION DE COMERCIO
				TRIM(SUBSTR(vsregistro,99,14)),  --UBICACION DE COMERCIO
				TRIM(SUBSTR(vsregistro,113,2)),  --TIPO BATCH
				TRIM(SUBSTR(vsregistro,115,1)),  --CODIGO DE CALIFICACION
				TRIM(SUBSTR(vsregistro,116,1)),  --FLAG TRANSACCION
				TRIM(SUBSTR(vsregistro,117,6)),  --CAMPO RESERVADO 1
				TRIM(SUBSTR(vsregistro,123,23)),  --REFERENCIA 23
				TRIM(SUBSTR(vsregistro,146,6)),  --NUMERO DE BUSCA
				(((SUBSTR(vsregistro,152,10))::MONEY)/100), --MONTO EN DOLARES DE LA TRANSACCION 
				(((SUBSTR(vsregistro,162,5))::MONEY)/100), --MONTO DEVOLUCION DE EFECTIVO
				TRIM(SUBSTR(vsregistro,167,1)),  --REVERSADO
				TRIM(SUBSTR(vsregistro,168,3)),  --PAIS
				TRIM(SUBSTR(vsregistro,171,4)),  --CATEGORIA DEL COMERCIO
				TRIM(SUBSTR(vsregistro,175,2)),  --CARGO PARCIAL
				TRIM(SUBSTR(vsregistro,177,1)),  --RE EN BOLSO
				TRIM(SUBSTR(vsregistro,178,1)),  --MONEDERO ELECTRONICO
				TRIM(SUBSTR(vsregistro,179,2)),  --CODIGO ESPECIAL
				TRIM(SUBSTR(vsregistro,181,7)),  --RESERVADO 4
				TRIM(SUBSTR(vsregistro,188,3)),  --TIPO DE MONEDA DE LIQUIDACION
				TRIM(SUBSTR(vsregistro,191,3)),  --TIPO DE MONEDA DE LA TRANSACCION
				TRIM(SUBSTR(vsregistro,194,4)),  --FECHA DEL CONVENIO
				TRIM(SUBSTR(vsregistro,198,7)),  --TIPO DE CAMBIO
				TRIM(SUBSTR(vsregistro,205,1)),  --ES MENSUAL
				TRIM(SUBSTR(vsregistro,206,1)),  --ID TRANSPARECIA
				TRIM(SUBSTR(vsregistro,207,13)),  --RFC
				TRIM(SUBSTR(vsregistro,220,6)),  --CODIGO DE ERROR
				TRIM(SUBSTR(vsregistro,226,256)),  --MENSAJE DE ERROR
				TRIM(SUBSTR(vsregistro,482,12)), --ID TRANSACCION MPS				
				TRIM(SUBSTR(vsregistro,494,12)) -- ID DE MPS de compra POS  o ID CASH BACK
			);
		ELIF (piTipoLayOut = 20) THEN  -- tf_administrative_transac  --TAD 
			insert into bditransfer:"informix".tf_administrative_transac
				(nombrearchivo, archivo_origen, cuenta, codigo_operacion, fecha_operacion, folio_operacion, clv_mediooperacion, id_ejecutivo, id_sucursal)
			values
				(
				psNomArchivo,
				psArchivoOrigen,
				TRIM(SUBSTR(vsregistro,3,11)),  --CUENTA
				TRIM(SUBSTR(vsregistro,14,4)),	-- CODIGO DE LA OPERACION
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 18,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,22,2)||'-'||SUBSTR(vsregistro,24,2)||'-'||SUBSTR(vsregistro,18,4))
							ELSE 
								'01-01-1900'
							END, 	 			-- FECHA DE LA OPERACION RECUPERANDO YYYYMMDD
				TRIM(SUBSTR(vsregistro,26,12)),	-- FOLIO DE LA OPERACION
				TRIM(SUBSTR(vsregistro,38,2)),  -- CLAVE DEL MEDIO DE OPERACION
				TRIM(SUBSTR(vsregistro,40,15)), -- ID DEL EJECUTIVO
				TRIM(SUBSTR(vsregistro,55,16))  -- ID DE LA SUCURSAL 
				);
				
				
		ELIF (piTipoLayOut = 21) THEN -- tf_settlement_bank  ### TIB ###
	 
		INSERT INTO bditransfer:"informix".tf_settlement_bank  
			(nombrearchivo,archivo_origen,fech_recepcion,hora_recepcion,fech_alt,hora_alt,fech_dev,hora_dev,estatus,causa_dev,tipo_pago,
			tpo_id_origen,id_cuenta_origen,id_banco_origen,rfc_curp_origen,nombre_cte_origen,tpo_id_destino,id_cuenta_destino,
			cel_destino,nombre_cte_destino,monto,id_transacc_mps,clave_rastreo,referencia_1,referencia_2)
			VALUES
			(
				psNomArchivo,
				psArchivoOrigen,
                CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 1,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,1,2)||'-'||SUBSTR(vsregistro,3,2)||'-'||SUBSTR(vsregistro,5,4))
							ELSE 
								'01-01-1900'
							END, 	                                                                                     -- fech_recepcion
							
				TRIM('1900-01-01 '||SUBSTR(vsregistro,9,2)||':'||SUBSTR(vsregistro,11,2)||':'||SUBSTR(vsregistro,13,2)), -- hora_recepcion 
				
                CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 15,8))) <> '00000000' THEN 
								(SUBSTR(vsregistro,15,2)||'-'||SUBSTR(vsregistro,17,2)||'-'||SUBSTR(vsregistro,19,4))
							ELSE 
								'01-01-1900'
							END, 	                                                                                      -- fech_alt
							
				TRIM('1900-01-01 '||SUBSTR(vsregistro,23,2)||':'||SUBSTR(vsregistro,25,2)||':'||SUBSTR(vsregistro,27,2)), -- hora_alt 	
				
                CASE 	WHEN (TRIM(SUBSTR(vsRegistro,29,8))) <> '' THEN  -- Revisar si es correcta puedan contener espacios en blanco. 
								(SUBSTR(vsregistro,29,2)||'-'||SUBSTR(vsregistro,31,2)||'-'||SUBSTR(vsregistro,33,4))
							ELSE 
								'01-01-1900'
							END, 	                                                                                                   -- fech_dev
							
				CASE 	WHEN (TRIM(SUBSTR(vsRegistro, 37,6))) <> '' THEN   -- Revisar si es correcta puedan contener espacios en blanco. 
				              TRIM('1900-01-01 '||SUBSTR(vsregistro,37,2)||':'||SUBSTR(vsregistro,39,2)||':'||SUBSTR(vsregistro,41,2)) -- hora_dev 
                            ELSE 
								'1970-01-01 00:00:00'
							END,
              
			    TRIM(SUBSTR(vsregistro,43,2)), --  estatus
				TRIM(SUBSTR(vsregistro,45,2)), --  causa_dev
				TRIM(SUBSTR(vsregistro,47,2)), --  tipo_pago
				TRIM(SUBSTR(vsregistro,49,2)),  -- tpo_id_origen
				TRIM(SUBSTR(vsregistro,51,18)), -- id_cuenta_origen
				TRIM(SUBSTR(vsregistro,69,3)),  -- id_banco_origen
				TRIM(SUBSTR(vsregistro,72,18)),  -- rfc_curp_origen
				TRIM(SUBSTR(vsregistro,90,100)), -- nombre_cte_origen
				TRIM(SUBSTR(vsregistro,190,2)),  -- tpo_id_destino
				TRIM(SUBSTR(vsregistro,192,18)),  -- id_cuenta_destino
				TRIM(SUBSTR(vsregistro,210,12)),  -- cel_destino
				TRIM(SUBSTR(vsregistro,222,100)),  -- nombre_cte_destino
				(((SUBSTR(vsregistro,322,17))::MONEY)/100), -- monto
				TRIM(SUBSTR(vsregistro,339,12)),  -- id_transacc_mps
				TRIM(SUBSTR(vsregistro,351,30)),  -- clave_rastreo
				TRIM(SUBSTR(vsregistro,381,7)),  -- referencia_1
				TRIM(SUBSTR(vsregistro,388,40))  -- referencia_2
			);		  
	END IF;
		
	LET viContadorRegistros = viContadorRegistros + 1;
	LET vsMensaje_Respuesta = 'TERMINAR TRANSACCION';
	--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
	IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
		COMMIT WORK;
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
		CONTINUE FOREACH;
	END IF;
		
END FOREACH;
	
LET vsMensaje_Respuesta = 'TERMINAR TRANSACCION';
-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
	COMMIT WORK;
	LET vsFlagEnTransaccion = 'F';
END IF;

LET vsMensaje_Respuesta = 'BORRAR CONTENIDO DE tf_carga_transfer.';
BEGIN WORK;	
	LET vsFlagEnTransaccion = 'V';
	--BORRA LOS REGISTROS DEL ARCHIVO ALMACENADOS EN LA TABLA DE CARGA
	DELETE FROM bditransfer:"informix".tf_carga_transfer;
COMMIT WORK;
	
LET vsFlagEnTransaccion = 'F';
LET vsMensaje_Respuesta = 'Proceso de Integracion sin validacion de Integridad';
Let vielemento = 2;
	
RETURN 
		vsCodRet,
		vsMensaje_Respuesta, 
		vielemento;

END

END PROCEDURE
DOCUMENT
'AUTOR: JUAN FCO. PONCE DAMIAN',
'Proyecto: Proyecto de Integracion Transfer',
'Solicito: Jose Luis Puebla',
'Descripcion: CARGA LA INFORMACION A TABLAS QUE LE CORRESPONDAN SEGUN EL TIPO DE LAYOUT',
'Fecha: 2014/07/15',
'Version: 20140715.1115',
'BD: BdiTransfer',
'',
'Modifico: Ricardo Reséndiz Martinez',
'Proyecto: Proyecto de Integracion Transfer',
'Solicito: Jose Luis Puebla',
'Descripcion: Proceso de validación de fechas para cuando transfer las manda con cadenas de ceros',
'Fecha: 2014/09/29',
'Version: 20140929.1300',
'BD: Bditransfer',
'',
'Modifico: L.I.A. Ricardo Reséndiz Martinez',
'Proyecto: RQM 10 615 Proyecto de Modificacion de OutCapture',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agrega integracion de id_payment_transacc_mps como parte de segunda etapa de proyecto transfer ',
'Fecha: 2015/04/10',
'Version: 20150410.1400',
'BD: Bditransfer',
'',
'Modifico: L.I.A. Ricardo Reséndiz Martinez',
'Proyecto: RQM 10 651 Cambio en Layout reportes Transfer',
'Solicito: Jose Luis Puebla',
'Descripcion: Se modifica recuperacion del campo  metodo de acceso para que sea de 3 caracteres en vez de 2',
'Fecha: 2015/08/24',
'Version: 20150824.1800',
'BD: Bditransfer',
'',
'Modifico: L.I.A. Ricardo Reséndiz Martinez',
'Proyecto: RQM 10 650 Folio operaciones administrativas',
'Solicito: Jose Luis Puebla',
'Descripcion: Se modifica proceso de recuperacion de datos en Newregistration y Retirecostumer',
'Fecha: 2015/08/26',
'Version: 20150824.1500',
'BD: Bditransfer',
'',
'Modifico: L.I Ayala Ponce Marcos Gerardo',
'Proyecto: RQM 10 698 Implementar Transfer VR14 Modificaciones Archivo PIN',
'Solicito: Productos',
'Descripcion: Se modifico layout 12 integrandose la obtención de la fecha de modificación del PIN',
'Fecha: 2015/12/10',
'Version: 20151209.1800',
'BD: Bditransfer',
'',
'Modifico: L.I.A.  Ricardo Reséndiz Martínez',
'Proyecto: RQM 06 481 - Reportes Conciliación Transfer',
'Solicito: Operaciones',
'Descripcion: Se agrega proceso para armar el folio_soc de la tabla tf_success_transac',
'Fecha: 2016/06/20',
'Version: 20160620.1800',
'BD: Bditransfer',
'',
'MODIFICO: L.I. Marcos Gerardo Ayala Ponce',
'Proyecto: RQM 10 721-2 - Transfer OPM SPEI',
'Solicito: Jose Luis Puebla Salinas',
'Descripcion: Se integra layout 21 Transacciones OPM-SPEI para la tabla tf_settlement_bank',
'Fecha: 2016/08/18',
'Version: 20160818.1800',
'BD: Bditransfer',
'',
'MODIFICO: L.I. Marcos Gerardo Ayala Ponce',
'Proyecto: RQM 10 1098 Cuenta Móvil-Actualizacion de Reportes',
'Solicito: Productos',
'Descripcion: Se modifican layouts 2 y 11 con nuevos campos por actualizacion de reportes',
'Fecha: 2018/06/18',
'Version: 20180618.1800',
'BD: Bditransfer';