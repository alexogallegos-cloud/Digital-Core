CREATE PROCEDURE "informix".sp_concreing_conadmin(
   psistema char(1),
   pfecha_archivo date,
   pbandera_proceso char(1),
   pnumtarjeta char(16),
   pfolio_mov char(16),
   parchivo_origen char(3),
   pnombrearchivo char(23),
   ptipo_mov      char(1),
   pmonto325      money(16,2),
   psecuencia_extendida char(15),
   pfechatransaccion DATETIME YEAR TO FRACTION (5) ,
   pmontointercard money(16,2),
   pidterminal char(16),
   ptransacion_aplica char(4),
   pnomArchivoCom CHAR(23),
   pnumempleado CHAR (8)
)
RETURNING VARCHAR(6),VARCHAR(80),INTEGER;

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  P_BANDERA        VARCHAR(1);
DEFINE  id_proceso       INTEGER;


DEFINE vsTarjeta CHAR (20);
DEFINE vsCuenta CHAR (20);
DEFINE vsTxnLiberacion CHAR (4);
DEFINE vsFolioSIF CHAR (16);
DEFINE vmMontoSIF MONEY(16,6);
DEFINE vsTransacC CHAR(4);
DEFINE vsTransacC_ifrs CHAR(4);
DEFINE vsSecuenciaAut CHAR(15);
DEFINE vsProdTarjeta CHAR (4);
DEFINE vsCuentaC CHAR (40);
DEFINE vsCuentaA CHAR (40);
DEFINE vsSucursal CHAR (4);
DEFINE vsTipoOperacion CHAR (1);
DEFINE vsIdTerminal CHAR (4);
DEFINE vsSecIntercard CHAR (15);
DEFINE vdtFechaHoraInAuth DATETIME YEAR TO FRACTION (5) ;
DEFINE vmMontoIntercard MONEY(16,6);

DEFINE dtFecha_Hoy_Integral DATE;


BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE,id_proceso;
   END EXCEPTION;

--*****************************************************************
-- CONCILIACION ADMINISTRATIVA                                  --*
-- Creado por: Manuel Osuna Valencia                            --*
-- Fecha: 20/07/2011                                            --*
-- Funcion: Recibe Registros para Conciliar con los movimientos --*
-- de integral                                                  --*
--*****************************************************************
-- CONCILIACION ADMINISTRATIVA                                  --*
-- Creado por: Juan Fco. Ponce Damian                           --*
-- Fecha: 28/03/2012                                            --*
-- modificación: se modifico la parte de conciliacion de        --*
-- corresponsales, se modifico fecha y folio_suc.               --*
--*****************************************************************
--SET DEBUG FILE TO "/informix/HomeInformix/rrm/CONADMIN.out";
--TRACE ON;
	LET id_proceso = 8;

	LET P_COD_RET = '00000';
	LET P_MENSAJE = 'PROCESO EXITOSO';

	LET vsCuenta = '';
	LET vsTxnLiberacion = '';
	LET vsFolioSIF = '';
	LET vmMontoSIF = 0.00;
	LET vsSecuenciaAut = '';

	LET vsTransacC = '';
	LET vsTransacC_ifrs = '';
	LET vsProdTarjeta = '';
	LET vsCuentaC = '';
	LET vsCuentaA = '';
	LET vsTarjeta = '';

	LET vsTipoOperacion = '';
	LET vsIdTerminal = '';
	LET vsSecIntercard = '';
	LET vdtFechaHoraInAuth = CURRENT;
	LET vmMontoIntercard = 0.00;
	
	LET dtFecha_Hoy_Integral = CURRENT::DATE;

	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--OBTIENE LA FECHA HOY DEL SISTEMA CENTRAL INTEGRAL
	SELECT LIMIT 1 Fecha_Hoy INTO dtFecha_Hoy_Integral FROM bdinteg:"informix".Si_Fechas;

	IF (parchivo_origen IN ('TCC', 'TCD')) THEN  -- INTERREDES

	   LET vsTarjeta = pnumtarjeta;

		IF (psistema == 'D') THEN --DEBITO
			-- 28/06/2023 Se retiran sentencias repetidas ya que solo deben ir una vez al inicio del SP
			-- SET LOCK MODE TO WAIT 3 ;
			-- SET ISOLATION TO DIRTY READ ;
			SELECT FIRST 1 Cuenta, ProdTarjeta
			INTO vsCuenta, vsProdTarjeta
			FROM BdiCheq:"informix".Sc_Tarjeta
			WHERE Empresa = '001' AND Num_Tarjeta = vsTarjeta;
		ELSE -- 'C' -- CREDITO
			LET vsProdTarjeta = '6001';		END IF;


		
		
		IF (pbandera_proceso IN ('C', 'A')) THEN --MOVIMIENTO CONCILIADO, APLICADO O FORZADO
			--OBTIENE EL MOVIMIENTO DE LAS TABLAS DEL SIF (MOVDIA)
			IF (psistema == 'D') THEN

				--IF (pfecha_archivo = dtFecha_Hoy_Integral) THEN --DIA ACTUAL
					-- 28/06/2023 Se retiran sentencias repetidas ya que solo deben ir una vez al inicio del SP
					-- SET LOCK MODE TO WAIT 3 ;
					-- SET ISOLATION TO DIRTY READ ;
					SELECT FIRST 1 Cuenta, Transacc_Suc, Folio_Suc, Monto_Tot, TransacC
					INTO vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC
					FROM BdiCheq:"informix".Sc_MovDia
					WHERE Empresa = '001'
					AND cuenta=vsCuenta
					AND Folio_Suc = pfolio_mov
					AND transacc NOT IN('0260','3259','3357'); --NO CONSIDERA LAS TRANSACCIONES DE IVA Y COMISIONES POR TDD CON CHIP
													-- Excluye la transaccion de uso de sobre giro
				/*ELSE --EXTEMPORANEO
					
					SET LOCK MODE TO WAIT 3 ;
					SET ISOLATION TO DIRTY READ ;
					SELECT FIRST 1 Cuenta, Transacc_Suc, Folio_Suc, Monto_Tot, TransacC
					INTO vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC
					FROM BdiCheq:"informix".Sc_MovHis
					WHERE Empresa = '001'
					AND cuenta=vsCuenta
					AND Folio_Suc = pfolio_mov
					AND transacc NOT IN('0260','3259','3357'); --NO CONSIDERA LAS TRANSACCIONES DE IVA Y COMISIONES POR TDD CON CHIP 
					--	SE AGREGA PARA CUANDO EXISTEN SOBREGIROS PARA EXCLUIRLOS
				END IF;*/
				
			ELIF (psistema == 'C') THEN

				--IF (pfecha_archivo = dtFecha_Hoy_Integral) THEN --DIA ACTUAL
					-- 28/06/2023 Se retiran sentencias repetidas ya que solo deben ir una vez al inicio del SP
					-- SET LOCK MODE TO WAIT 3 ;
					-- SET ISOLATION TO DIRTY READ ;
					SELECT FIRST 1 Num_Credito, Transacc_Suc, Folio_Suc, Monto, TransacC_Suc
					INTO vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC
					FROM BdiCred:"informix".Sd_MovDia
					WHERE Empresa = '001'
					AND Folio_Suc = pfolio_mov
					AND Nro_Tarjeta = vsTarjeta;
				
				/*ELSE --EXTEMPORANEO
					
					SET LOCK MODE TO WAIT 3 ;
					SET ISOLATION TO DIRTY READ ;
					SELECT FIRST 1 Num_Credito, Transacc_Suc, Folio_Suc, Monto, TransacC_Suc
					INTO vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC
					FROM BdiCred:"informix".Sd_MovHis
					WHERE Empresa = '001'
					AND Folio_Suc = pfolio_mov
					AND Nro_Tarjeta = vsTarjeta;
					
				END IF;*/

			END IF;

		ELIF (pbandera_proceso = 'E') THEN --MOVIMIENTO CON ERROR
			LET vsTxnLiberacion = '';
			LET vsFolioSIF = '';
			LET vmMontoSIF = 0.00;
			LET vsTransacC = '';
		ELSE --MOVIMIENTO PENDIENTE / SIN PROCESAR
			LET vsTxnLiberacion = '';
			LET vsFolioSIF = '';
			LET vmMontoSIF = 0.00;
			LET vsTransacC = '';
		END IF;


		--IDENTIFICA SI LA TRANSACCION FUE CONCILIADA O FORZADA
		--mmddhhmm2######  -- SecuenciaExtendida
		IF (SUBSTRING (pSecuencia_Extendida FROM 9 FOR 1) = '1') THEN --ENCONTRADA EN INTERCARD  --1
			LET vsTipoOperacion = 'C'; --COMPRA
			LET vsIdTerminal = SUBSTRING (pidterminal FROM 1 FOR 4);
			LET vsSecIntercard = SUBSTRING (pSecuencia_Extendida FROM 9 FOR 7);
			LET vdtFechaHoraInAuth = pfechatransaccion;
			LET vmMontoIntercard = pmontointercard;
			
		ELSE --NO IDENTIFICADO ERROR
			LET vsTipoOperacion = 'E'; --ERROR
			LET vsIdTerminal = '';
			LET vsSecIntercard = '';
			LET vdtFechaHoraInAuth = "1900-01-01 00:00:00";
			LET vmMontoIntercard = 0.00;
		END IF;


	ELIF (pArchivo_Origen IN ('CCP', 'CCD', 'TPD') ) THEN   --CORRESPONSALES Y TRANSFERENCIAS PRESTAMOS
		--EN CCP, CCD Y TPD EN EL CAMPO TARJETA SE ENCUENTRA EL FOLIO_MOV
		LET pfolio_mov = TRIM(pnumtarjeta);     --se modifico 
		LET psecuencia_extendida = TRIM(pnumtarjeta);
		--select fecha_archivo into pfecha_archivo from td_archivos_conciliacion   --se agrego
		--where nombrearchivo = pnombrearchivo ;
		--LET pfecha_archivo = SUBSTRING(pnombrearchivo FROM 11 FOR 2) || '/' || SUBSTRING(pnombrearchivo FROM 9 FOR 2) || '/' || SUBSTRING(pnombrearchivo FROM 13 FOR 4);
		--immddhhmm2######  -- Folio_Mov
		LET vsIdTerminal = SUBSTRING(pfolio_mov FROM 1 FOR 4); 

		--OBTIENE EL MOVIMIENTO DE LAS TABLAS DEL SIF (MOVHIS)
		IF (psistema == 'D') THEN -- DEBITO
			
			-- 28/06/2023 Se retiran sentencias repetidas ya que solo deben ir una vez al inicio del SP
			-- SET ISOLATION TO DIRTY READ ;
			-- SET LOCK MODE TO WAIT 3;
			SELECT FIRST 1 Num_Tarjeta, Cuenta, transacc, Folio_Suc, Monto_Tot, TransacC
				INTO vsTarjeta, vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC
			FROM BdiCheq:"informix".Sc_MovHis
				WHERE 	Empresa = '001'
						AND Cuenta IS NOT NULL
						AND Folio_Suc = pfolio_mov
						AND Sucursal = (CASE	WHEN (pArchivo_Origen = 'TPD') THEN '5006' 
												WHEN (pArchivo_Origen IN ('CCP', 'CCD')) THEN '5005' 
												ELSE 
													'0000' 
										END) --SUCURSAL VIRTUAL
						AND transacc =  ptransacion_aplica -- Se pone ya que previamente se mando la transaccion correcta y se quita hardcode  
										
			/* 	(CASE 	WHEN (pArchivo_Origen = 'TPD') THEN '0283' 
									WHEN (pArchivo_Origen = 'CCD') THEN '0282' 
									WHEN (pArchivo_Origen = 'CCP') THEN '6282' 
									ELSE '0000' 
									END) --PARA TRANSACCION CORRECTA*/
						AND Fech_Alt = pfecha_archivo -1
						AND Cancelad <> 'S';
			
			-- 28/06/2023 Se retiran sentencias repetidas ya que solo deben ir una vez al inicio del SP
			--SET ISOLATION TO DIRTY READ ;
			--SET LOCK MODE TO WAIT 3;
			--OBTIENE EL PRODUCTO DE LA TARJETA
			SELECT FIRST 1 ProdTarjeta 
				INTO vsProdTarjeta
			FROM BdiCheq:"informix".Sc_Tarjeta
				WHERE Empresa = '001'
				AND Num_Tarjeta = TRIM(vsTarjeta);
			
			-- Para poder Clasificar las transacciones conforme a su origen
			if ptransacion_aplica in ('0282', '0407') then
				let vsTipoOperacion = 'E';	-- Abreviatura de Entrada de Efectivo
			elif ptransacion_aplica in ('0402')  then 
				let vsTipoOperacion = 'S'; 	-- Salida de Efectivo 
			elif ptransacion_aplica in ('0401', '0404') then
				let vsTipoOperacion = 'N';   -- Neutral sin manejo de efectivo
			else 
				let vsTipoOperacion = 'I';  -- Se pone como para identificarlo como improcedente 
			end if;
				

		ELIF (psistema == 'C') THEN --CREDITO
			
			if ptransacion_aplica in ('6282', '8105', '8104', '8106') then
				-- 28/06/2023 Se retiran sentencias repetidas ya que solo deben ir una vez al inicio del SP
				-- SET ISOLATION TO DIRTY READ ;
				-- SET LOCK MODE TO WAIT 3;
				SELECT FIRST 1 Nro_Tarjeta, Num_Credito, Transacc_Suc, Folio_Suc, Monto, TransacC_Suc
					INTO vsTarjeta, vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC
				FROM Bdicred:"informix".Sd_MovHis
					WHERE 	Empresa = '001'
							AND Num_Credito IS NOT NULL
							AND Folio_Suc = pfolio_mov
							AND Sucursal = (CASE 	WHEN 	(pArchivo_Origen = 'TPD') THEN '5006' 
													WHEN 	(pArchivo_Origen IN ('CCP', 'CCD'))THEN '5005' 
													ELSE 
															'0000'
													END) --SUCURSAL VIRTUAL
							AND Fecha_Mov = pfecha_archivo -1
							AND Reversado <> 'S'
							AND transacc_suc = ptransacion_aplica -- Se pone por integracion de nuevas operaciones de corresponsales --'6282' --FIJO
							AND codigo_fun = ( CASE	WHEN ( ptransacion_aplica = '6282') THEN '700'
													WHEN ( ptransacion_aplica = '8105') THEN '002'
													WHEN ( ptransacion_aplica = '8104') THEN '068'
													WHEN ( ptransacion_aplica = '8106') THEN '000'
													END)
							AND codigo_ref = ( CASE	WHEN ( ptransacion_aplica = '6282') THEN 1   	-- Pago de tarjeta de credito
													WHEN ( ptransacion_aplica = '8105') THEN 109 	-- Disposición de efectivo
													WHEN ( ptransacion_aplica = '8104') THEN 1  	-- Pago de tarjeta desde cta. Efectiva
													WHEN ( ptransacion_aplica = '8106') THEN 0  	-- Consulta de Saldo 
													END); --FIJO   0
			elif ptransacion_aplica in ('0406', '0407' ) then
				-- 28/06/2023 Se retiran sentencias repetidas ya que solo deben ir una vez al inicio del SP
				-- SET ISOLATION TO DIRTY READ ;
				-- SET LOCK MODE TO WAIT 3;
				SELECT FIRST 1 Num_Tarjeta, Cuenta, transacc, Folio_Suc, Monto_Tot, TransacC
					INTO vsTarjeta, vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC
				FROM BdiCheq:"informix".Sc_MovHis
					WHERE 	Empresa = '001'
							AND Cuenta IS NOT NULL
							AND Folio_Suc = pfolio_mov
							AND Sucursal = '5005' --SUCURSAL VIRTUAL
							AND transacc =  ptransacion_aplica -- Se pone ya que previamente se mando la transaccion correcta y se quita hardcode  
							AND Fech_Alt =  pfecha_archivo -1
							AND Cancelad <> 'S';
				
				-- 28/06/2023 Se retiran sentencias repetidas ya que solo deben ir una vez al inicio del SP
				-- SET ISOLATION TO DIRTY READ ;
				-- SET LOCK MODE TO WAIT 3;
				--OBTIENE EL PRODUCTO DE LA TARJETA
				SELECT FIRST 1 ProdTarjeta 
					INTO vsProdTarjeta
				FROM BdiCheq:"informix".Sc_Tarjeta
					WHERE Empresa = '001'
						AND Num_Tarjeta = TRIM(vsTarjeta);			
			end if;
			
			-- Para poder Clasificar las transacciones conforme a su origen
			if ptransacion_aplica in ('6282','0407') then
				let vsTipoOperacion = 'E';	-- Abreviatura de Entrada de Efectivo
			elif ptransacion_aplica in ('8105')  then 
				let vsTipoOperacion = 'S'; 	-- Salida de Efectivo 
			elif ptransacion_aplica in ('8106', '8104', '0406') then
				let vsTipoOperacion = 'N';   -- Neutral sin manejo de efectivo
			else 
				let vsTipoOperacion = 'I';  -- Se pone como para identificarlo como improcedente 
			
			end if;
			
		END IF;
	END IF;
-- Ver diferencia cuando hay saldo a favor 


	IF (pArchivo_Origen <> 'TPD' ) THEN --SOLO EN LAS TRANFERENCIAS NO SE CONSULTAN LAS RISTRAS CONTABLES

		IF (psistema == 'C') THEN
			SELECT transacc_ifrs
			  INTO vsTransacC_ifrs
			  FROM bdicred:sd_transfun
			 where transacc = vsTransacC;
			 
			 IF nvl(vsTransacC_ifrs,'') <> '' THEN
				LET vsTransacC = vsTransacC_ifrs;
			 END IF;
		END IF;

	  	--OBTIENE LA RISTA CONTABLE DE LA TRANSACCION ACTUAL
		-- 28/06/2023 Se retiran sentencias repetidas ya que solo deben ir una vez al inicio del SP
		-- SET LOCK MODE TO WAIT 3 ;
		-- SET ISOLATION TO DIRTY READ ;
		SELECT FIRST 1 TRIM (c_ccmayor) || '-' || TRIM (c_ccsub) || '-' || TRIM (c_ccsubsub) || '-' || TRIM (c_ccsssub) || '-' || TRIM (c_ccssssub) || '-' || TRIM (c_sector) AS CuentaC,
		TRIM (a_ccmayor) || '-' || TRIM (a_ccsub) || '-' || TRIM (a_ccsubsub) || '-' || TRIM (a_ccsssub) || '-' || TRIM (a_ccssssub) || '-' || TRIM (a_sector)  AS CuentaA
		INTO vsCuentaC, vsCuentaA
		FROM BdInteg:"informix".Si_ProdTran
		WHERE Empresa = '001'
		AND Producto = vsProdTarjeta
		AND Sistema IS NOT NULL
		AND Transaccion = vsTransacC
		AND Secuencia = 1;

		IF (psistema == 'C') THEN  --SE CONSULTA EL PRODUCTO EN CREDITO POR QUE PUEDE TRAER 0001 QUE SON REPOSICIONES
			--OBTIENE EL PRODUCTO DE LA TARJETA
			-- 28/06/2023 Se retiran sentencias repetidas ya que solo deben ir una vez al inicio del SP
			-- SET LOCK MODE TO WAIT 3 ;
			-- SET ISOLATION TO DIRTY READ ;
			SELECT FIRST 1 ProdTarjeta INTO vsProdTarjeta
			FROM BdiCred:"informix".Sd_Tarjeta
			WHERE Empresa = '001'
			AND Num_Tarjeta = TRIM(vsTarjeta);

		END IF;

	END IF;



	-- 28/06/2023 El alto costo en este insert se justifica debido a la informacion que contiene la misma
	-- Es importante mencionar que la misma tiene solo datos de los ultimos 30 dias, y por ende se encuentra con un proceso automatico
	-- por tanto, depurar los datos para minimizar el cosoto no es viable
	--GUARDA EL REGISTRO EN LA TABLA DE CONCILIACION ADMINISTRATIVA INTERREDES
	INSERT INTO InterCard:"informix".ConAdmIn
	(
		ArchivOorigen,
		NomArchivo325,
		NomArchivocom,
		FechaRegistro,
		TipoRegistro,
		Fecha,
		ProdTarjeta,
		Tarjeta,
		Cuenta,
		TipoMov,
		Tran_Central,
		Folio325,
		Monto325,
		Estatus,
		TxnLiberacion,
		CuentaC,
		CuentaA,
		FolioSIF,
		MontoSIF,
		SecIntercard,
		MontoIntcrd,
		FechaHoraInAuth,
		IdTerminal,
		TipoOperacion,
		Usuario
	)
	VALUES
	(
		NVL (parchivo_origen, ''),
		UPPER (TRIM(NVL (pnombrearchivo, ''))),
		TRIM(NVL (pnomArchivoCom, '')),
		CURRENT::DATE,
		'D', --DETALLE
		NVL (pfecha_archivo, CURRENT::DATE),
		NVL (vsProdTarjeta, ''),
		NVL (vsTarjeta, ''),
		NVL (vsCuenta, ''),
		NVL (ptipo_mov, ''),
		NVL (ptransacion_aplica, ''),
		NVL (pfolio_mov, ''),
		NVL (pmonto325, 0.0),
		NVL (pbandera_proceso, ''),
		NVL (vsTxnLiberacion, ''),
		NVL (vsCuentaC, ''),
		NVL (vsCuentaA, ''),
		NVL (vsFolioSIF, ''),
		NVL (vmMontoSIF, 0.0),
		NVL (vsSecIntercard, ''),
		NVL (vmMontoIntercard, 0.0),
		NVL (vdtFechaHoraInAuth, CURRENT),
		NVL (vsIdTerminal, ''),
		NVL (vsTipoOperacion, ''),
		NVL (pnumempleado, '')
	);


   RETURN P_COD_RET, P_MENSAJE, id_proceso;

END;
END PROCEDURE
DOCUMENT
'MODIFICACION: CASANOVA EDEZA HECTOR JUAN',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE AGREGO LOGICA PARA MANEJAR LOS ARCHIVOS EXTEMPORANES Y BUSQUEN SUS MOVIMIENTOS EN LA MOVHIS Y NO EN LA MOV DIA.',
'Fecha: 2012/07/20',
'Version: 20120720.1700',
'BD: BdiTarjeta',
'',
'MODIFICACION: CASANOVA EDEZA HECTOR JUAN',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE MODIFICA LA LOGICA PARA QUE EL NOMBREARCHIVO SE GUARDE TODO EN MAYUSCULAS EN AL TABLA DE ConAdmIn.',
'Fecha: 2012/08/21',
'Version: 20120821.1821',
'BD: BdiTarjeta',
'',
'MODIFICACION: CASANOVA EDEZA HECTOR JUAN',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE MODIFICA LA LOGICA PARA FILTRAR LAS OPERACIONES DEL MOVHIS PARA CORRESPONSALES DEBITO.',
'Fecha: 2012/09/26',
'Version: 20120926.1018',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martínez',
'Proyecto: Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: Se incluye filtrado de transaccion de uso de sobre giro para la conadmin de debito de interredes ',
'Fecha: 2013/06/21',
'Version: 20130621.1700',
'BD: BdiTarjeta',
'',
'MODIFICACION: L.I.A. Ricardo Reséndiz Martínez',
'Proyecto: Conciliación de Nuevas transacciones de Corresponsales',
'Solicito: Jose Luis Puebla Salinas',
'Descripcion: Se modifica para agregar para buscar los nuevos movimientos y agregar la busqueda en Historico de Cheques de los pagos a otros bancos',
'Fecha: 2013/06/21',
'Version: 20130621.1700',
'BD: BdiTarjeta',
'',
'MODIFICACION: Maria Fernanda Ortiz Figueroa',
'Proyecto: Optimizaciones a nivel sintaxis',
'Solicito: Base de Datos por observacion de altos costos',
'Descripcion: Se retiran directivas/sentencias repertidas, se justifica alto costo en insert y sequential',
'Fecha: 2023/06/28',
'Version: 20130621.1700',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_conadmin_atms(
           psistema char(1),
           pfecha_archivo date,
           pbandera_reverso char(1),
           pnumtarjeta char(16),
           pfolio_mov char(16),
           parchivo_origen char(3),
           pnombrearchivo char(23),
           ptipo_mov      char(1),
           pmonto325      money(16,2),
           psecuencia_extendida char(15),
           pfechatransaccion DATETIME YEAR TO FRACTION (5) ,
           pmontointercard money(16,2),
           pidterminal char(16),
           ptransacion_aplica char(4),
           pnomArchivoCom CHAR(23),
           pnumempleado CHAR (8)
    )
    RETURNING VARCHAR(6), VARCHAR(80), INTEGER;

    DEFINE  SQL_ERR          INTEGER;
    DEFINE  ISAM_ERR         INTEGER;
    DEFINE  ERROR_INFO       VARCHAR(80);
    DEFINE  P_COD_RET        VARCHAR(6);
    DEFINE  P_MENSAJE        VARCHAR(80);
    DEFINE  P_BANDERA        VARCHAR(1);
    DEFINE  id_proceso       INTEGER;


    DEFINE vsTarjeta CHAR (20);
    DEFINE vsCuenta CHAR (20);
    DEFINE vsTxnLiberacion CHAR (4);
    DEFINE vsFolioSIF CHAR (16);
    DEFINE vmMontoSIF MONEY(16,6);
    DEFINE vsTransacC CHAR(4);
    DEFINE vsSecuenciaAut CHAR(15);
    DEFINE vsProdTarjeta CHAR (4);
    DEFINE vsCuentaC CHAR (40);
    DEFINE vsCuentaA CHAR (40);
    DEFINE vsSucursal CHAR (4);
    DEFINE vsTipoOperacion CHAR (1);
    DEFINE vsIdTerminal CHAR (4);
    DEFINE vsSecIntercard CHAR (15);
    DEFINE vdtFechaHoraInAuth DATETIME YEAR TO FRACTION (5) ;
    DEFINE vmMontoIntercard MONEY(16,6);
    DEFINE dtFecha_Hoy_Integral DATE;
	DEFINE vsProducto CHAR(1);


    BEGIN
        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
          LET P_COD_RET    = SQL_ERR;
          LET P_MENSAJE  = ERROR_INFO;
          RETURN P_COD_RET, P_MENSAJE,id_proceso;
        END EXCEPTION;

        --SET DEBUG FILE TO "/ifxsif01/LVRQ/debug/CONADMIN.out";
        --TRACE ON;

        LET id_proceso = 8;
        LET P_COD_RET = '00000';
        LET P_MENSAJE = 'PROCESO EXITOSO';
        LET vsCuenta = '';
        LET vsTxnLiberacion = '';
        LET vsFolioSIF = '';
        LET vmMontoSIF = 0.00;
        LET vsSecuenciaAut = '';
        LET vsTransacC = '';
        LET vsProdTarjeta = '';
        LET vsCuentaC = '';
        LET vsCuentaA = '';
        LET vsTarjeta = '';
        LET vsTipoOperacion = '';
        LET vsIdTerminal = '';
        LET vsSecIntercard = '';
        LET vdtFechaHoraInAuth = CURRENT;
        LET vmMontoIntercard = 0.00;
        LET dtFecha_Hoy_Integral = '';
		LET vsProducto = ''; 

		
		--TRACE 'Esto es Folio Suc '||  pfolio_mov||psecuencia_extendida||'monto ' || pmontointercard;
		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        --OBTIENE LA FECHA HOY DEL SISTEMA CENTRAL INTEGRAL
        SELECT LIMIT 1 Fecha_Hoy 
            INTO dtFecha_Hoy_Integral 
                FROM bdinteg:"informix".Si_Fechas
                    WHERE empresa = '001';
                    
        LET dtFecha_Hoy_Integral = CURRENT::DATE;
	
 
        IF (parchivo_origen <> 'IST' ) THEN  -- TXN ATM'S
            
            LET P_COD_RET = '00001';
            LET P_MENSAJE = 'Registro no corresponde a IST o el monto es menor o igual a cero';
            
            RETURN P_COD_RET, P_MENSAJE, id_proceso;
			
        END IF;
   
   
        LET vsTarjeta = pnumtarjeta;
		
	--TRACE 'Aqui esta tarjeta '|| pnumtarjeta;
	--TRACE 'Aqui esta reverso** '|| pbandera_reverso||'*** aqui';
	--TRACE 'Aqui esta monto ** '|| pmontointercard;
	
	
	IF ( pmontointercard > 0.00 AND pbandera_reverso != 'F') THEN
	
        IF (psistema == 'D') THEN --DEBITO
            
			SELECT FIRST 1 Cuenta, ProdTarjeta, psistema
                INTO vsCuenta, vsProdTarjeta,vsProducto
            FROM BdiCheq:"informix".Sc_Tarjeta
                WHERE Empresa = '001' 
                AND Num_Tarjeta = vsTarjeta;
					
			SELECT FIRST 1 Cuenta, Transacc_Suc, Folio_Suc, Monto_Tot, TransacC,cancelad
					INTO vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC,pbandera_reverso
			FROM BdiCheq:"informix".Sc_Movhis
				WHERE Empresa = '001'
				AND transacc = '0952'
				AND cuenta = vsCuenta
				AND Folio_Suc = pfolio_mov;
                
		ELSE  -- 'C' -- CREDITO
			SELECT FIRST 1 num_credito, ProdTarjeta, psistema
			INTO vsCuenta, vsProdTarjeta, vsProducto
			FROM BdiCred:"informix".Sd_Tarjeta
			WHERE Empresa = '001' 
			AND Num_Tarjeta = vsTarjeta;
			
		
			SELECT  '6952', folio_suc, reversado, sum(Monto)
			INTO vsTxnLiberacion, vsFolioSIF, pbandera_reverso, vmMontoSIF
			FROM BdiCred:"informix".Sd_Movhis
			WHERE codigo_fun = '002'
			and codigo_ref in (113,114)
			and num_credito = vsCuenta
			AND Folio_Suc = pfolio_mov
			AND Nro_Tarjeta = vsTarjeta
			group by 1,2,3;
            
		END IF;
	
            --GUARDA EL REGISTRO EN LA TABLA DE CONCILIACION ADMINISTRATIVA INTERREDES
            INSERT INTO InterCard:"informix".atm_conciliacion_admin
            (
                ArchivOorigen,
                NomArchivo325,
                NomArchivocom,
                FechaRegistro,
                Producto,
                Fecha,
                ProdTarjeta,
                Tarjeta,
                Cuenta,
                TipoMov,
                Tran_Central,
                Folio325,
                Monto325,
                Estatus,
                TxnLiberacion,
                CuentaC,
                CuentaA,
                FolioSIF,
                MontoSIF,
                SecIntercard,
                MontoIntcrd,
                FechaHoraInAuth,
                IdTerminal,
                TipoOperacion,
                Usuario
            )
            VALUES
            (
                NVL (parchivo_origen, ''),
                (TRIM(NVL (pnombrearchivo, ''))),
                TRIM(NVL (pnomArchivoCom, '')),
                CURRENT::DATE,
                NVL (vsProducto, ''),
                NVL (pfecha_archivo, CURRENT::DATE),
                NVL (vsProdTarjeta, ''),
                NVL (vsTarjeta, ''),
                NVL (vsCuenta, ''),
                NVL (ptipo_mov, ''),
                NVL (ptransacion_aplica, ''),
                NVL (pfolio_mov, ''),
                NVL (pmonto325, 0.0),
                NVL (pbandera_reverso, ''),
                NVL (vsTxnLiberacion, ''),
                NVL (vsCuentaC, ''),
                NVL (vsCuentaA, ''),
                NVL (vsFolioSIF, ''),
                NVL (vmMontoSIF, 0.0),
                NVL (vsSecIntercard, ''),
                NVL (vmMontoIntercard, 0.0),
                NVL (vdtFechaHoraInAuth, CURRENT),
                NVL (vsIdTerminal, ''),
                NVL (vsTipoOperacion, ''),
                NVL (pnumempleado, '')
            );
         
	END IF;
		
		RETURN P_COD_RET, P_MENSAJE, id_proceso;
		
    END

END PROCEDURE;