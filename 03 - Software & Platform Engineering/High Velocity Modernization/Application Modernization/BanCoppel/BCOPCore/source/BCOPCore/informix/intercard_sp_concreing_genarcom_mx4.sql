CREATE PROCEDURE "informix".sp_concreing_genarcom_mx4(
psRuta CHAR(50),
psNomArchivoDeb  char(23),
psNomArchivoCred char(23),
psArchivoOrigenDeb char(3),
psArchivoOrigenCred char(3),
psArchivoOrigenCom  char(3),
psNomArchivoCom char(23),
psBinDeb  char(6),
psBinCred char(6),
psNumEmpleado char(8),
psComisionD money(16,2),
psComisionC money(16,2),
psIvaD money(16,2),
psIvaC money(16,2)
   )
RETURNING VARCHAR(6),VARCHAR(80),INTEGER;

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  P_BANDERA        VARCHAR(1);


DEFINE vsSQL				CHAR (2704);
DEFINE vsSQL1				CHAR(150);
DEFINE vsSQL2 				CHAR(1504);
DEFINE vsSQL3 				CHAR(300);
DEFINE vsSQL4				CHAR(300);
DEFINE vsSQL5				CHAR(300);
DEFINE vsSQL6				CHAR(300);
DEFINE vsSQL7				CHAR(300);
DEFINE vsSQL8				CHAR(300);
DEFINE vsCodRetorno2			CHAR(5);
DEFINE v_TotReg				INTEGER;
DEFINE v_BandBA				CHAR(1);


DEFINE vsTarjeta CHAR (20);
DEFINE vsCuenta CHAR (20); --cuenta
DEFINE vsTxnLiberacion CHAR (4); --transacc_suc
DEFINE vsFolioSIF CHAR (16);
DEFINE vmMontoSIF MONEY(16,6); --MONTO
DEFINE vsTransacC CHAR(4);
DEFINE vsTransacC_ifrs CHAR(4);
DEFINE vdtFecha DATE;
DEFINE vsProdTarjeta CHAR (4);
DEFINE vsCuentaC CHAR (40);
DEFINE vsCuentaA CHAR (40);
DEFINE vsIdTerminal CHAR (4);
DEFINE vSucursal CHAR (4);

DEFINE id_proceso INTEGER;
-- Variables para las transacciones
DEFINE vsCadenaTransacc  Char(30);
DEFINE vsCadenaFun Char(30);
DEFINE vsCadenaRef Char(30);
-- Variables para recuperar las comisiones de corresponsales
DEFINE vmComConsultaDebito Decimal(16,6);
DEFINE vmComConsultaCredito Decimal(16,6);
DEFINE vmComRetiroDebito Decimal (16,6);
DEFINE vmComRetiroCredito Decimal (16,6);
DEFINE vmComTransferencia Decimal (16,6);
DEFINE vmComPagCreditoBCPLEfectiva Decimal (16,6);
DEFINE vmComPagCreditoOtroEfectiva Decimal (16,6);
DEFINE vmComPagCreditoOtroEfectivo Decimal (16,6);
DEFINE vmIVAComConsultaDebito Decimal(16,6);
DEFINE vmIVAComConsultaCredito Decimal(16,6);
DEFINE vmIVAComRetiroDebito Decimal (16,6);
DEFINE vmIVAComRetiroCredito Decimal (16,6);
DEFINE vmIVAComTransferencia Decimal (16,6);
DEFINE vmIVAComPagCreditoBCPLEfectiva Decimal (16,6);
DEFINE vmIVAComPagCreditoOtroEfectiva Decimal (16,6);
DEFINE vmIVAComPagCreditoOtroEfectivo Decimal (16,6);
DEFINE v_TotRegEntrada			INTEGER;
DEFINE v_TotRegSalida			INTEGER;
DEFINE v_TotRegNeutrales		INTEGER;

DEFINE vicontadorSIF integer;
-- Transacciones de Corresponsales
DEFINE vstransaccionDeb1 char(4);
DEFINE vstransaccionDeb2 char(4);
DEFINE vstransaccionDeb3 char(4);
DEFINE vstransaccionDeb4 char(4);
DEFINE vstransaccionCre1 char(4);
DEFINE vstransaccionCre2 char(4);
DEFINE vstransaccionCre3 char(4);
DEFINE vstransaccionCre4 char(4);
DEFINE vstransaccionFunCre1 char(3);
DEFINE vstransaccionFunCre2 char(3);
DEFINE vstransaccionFunCre3 char(3);
DEFINE vstransaccionFunCre4 char(3);
DEFINE vstransaccionRefCre1 char(3);
DEFINE vstransaccionRefCre2 char(1);
DEFINE vstransaccionRefCre3 char(1);

--DEFINE vmComisionCred DECIMAL(16,6);
-- COMISIONES DE TRANSACCIONES DE TRANSFERENCIAS
DEFINE vmComTransPrestamo    Decimal(16,6);
DEFINE vmComTransGtosFun     Decimal(16,6);
DEFINE vmComTransFiniEmp     Decimal(16,6);
DEFINE vmComTransFondoAho    Decimal(16,6);
DEFINE vmComTransReparUti    Decimal(16,6);
DEFINE vmComTransPagoSegV    Decimal(16,6);
DEFINE vmIVAComTransPrestamo Decimal(16,6);
DEFINE vmIVAComTransGtosFun  Decimal(16,6);
DEFINE vmIVAComTransFiniEmp  Decimal(16,6);
DEFINE vmIVAComTransFondoAho Decimal(16,6);
DEFINE vmIVAComTransReparUti Decimal(16,6);
DEFINE vmIVAComTransPagoSegV Decimal(16,6);

-- TRANSACCIONES DE TRANSFERENCIAS
DEFINE vstransaccionTrans1 char(4);
DEFINE vstransaccionTrans2 char(4);
DEFINE vstransaccionTrans3 char(4);
DEFINE vstransaccionTrans4 char(4);
DEFINE vstransaccionTrans5 char(4);
DEFINE vstransaccionTrans6 char(4);

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE,id_proceso;
   END EXCEPTION;


--SET DEBUG FILE TO "/informix/HomeInformix/rrm/Genera_file_comision.out";
--TRACE ON;

   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';
   
   LET id_proceso = 9; -- Numero de elemento en td_elemento
	LET vsTarjeta = '';
	LET vsCuenta = '';
	LET vsTxnLiberacion = '';
	LET vsFolioSIF = '';
	LET vmMontoSIF = 0.00;
	LET vsTransacC = '';
	LET vsTransacC_ifrs = '';
	LET vdtFecha = CURRENT::DATE;
	LET vsProdTarjeta = '';
	LET vsCuentaC = '';
	LET vsCuentaA = '';
	LET vsIdTerminal = '';
	LET v_TotReg = 0;
	
	LET vSucursal = '';
	LET vsSQL= '';
    LET vsSQL1= '';
    LET vsSQL2= '';
    LET vsSQL3= '';
	LET vsSQL4= '';
	LET vsSQL5= '';
	LET vsSQL6= '';
	LET vsSQL7= '';
	LET vsSQL8= '';
	LET vsCodRetorno2= '';
    LET v_BandBA = '';
	
	LET vsCadenaTransacc = '';
	LET vsCadenaFun = '';
	Let vsCadenaRef = '';

	-- Variables para recuperar las comisiones corresponsales
	LET vmComConsultaDebito 			= 0.0;
	LET vmComConsultaCredito 			= 0.0;
	lET vmComRetiroDebito 				= 0.0;
	LET vmComRetiroCredito 				= 0.0;
	LET vmComTransferencia 				= 0.0;
	LET vmComPagCreditoBCPLEfectiva 	= 0.0;
	LET vmComPagCreditoOtroEfectiva 	= 0.0;
	LET vmComPagCreditoOtroEfectivo 	= 0.0;
	LET vmIVAComConsultaDebito 			= 0.0;
	LET vmIVAComConsultaCredito 		= 0.0;
	LET vmIVAComRetiroDebito 			= 0.0;
	LET vmIVAComRetiroCredito 			= 0.0;
	LET vmIVAComTransferencia 			= 0.0;
	LET vmIVAComPagCreditoBCPLEfectiva 	= 0.0;
	LET vmIVAComPagCreditoOtroEfectiva 	= 0.0;
	LET vmIVAComPagCreditoOtroEfectivo 	= 0.0;
	-- Variables de comisiones de transferencias
	LET vmComTransPrestamo = 0.0;
	LET vmComTransGtosFun  = 0.0;
	LET vmComTransFiniEmp  = 0.0;
	LET vmComTransFondoAho = 0.0;
	LET vmComTransReparUti = 0.0;
	LET vmComTransPagoSegV = 0.0;
	LET vmIVAComTransPrestamo = 0.0;
	LET vmIVAComTransGtosFun  = 0.0;
	LET vmIVAComTransFiniEmp  = 0.0;
	LET vmIVAComTransFondoAho = 0.0;
	LET vmIVAComTransReparUti = 0.0;
	LET vmIVAComTransPagoSegV = 0.0;

	LET v_TotRegEntrada	= 0;
	LET v_TotRegSalida	= 0;
	LET v_TotRegNeutrales = 0;

	LET psNomArchivoDeb = UPPER(psNomArchivoDeb); 
	LET psNomArchivoCred = UPPER(psNomArchivoCred); 
	
	let vicontadorsif = 0;
	let vstransaccionDeb1 = '';
	let vstransaccionDeb2 = '';
	let vstransaccionDeb3 = '';
	let vstransaccionDeb4 = '';
	let vstransaccionCre1 = '';
	let vstransaccionCre2 = '';
	let vstransaccionCre3 = '';
	let vstransaccionCre4 = '';
	let vstransaccionFunCre1 = '';
	let vstransaccionFunCre2 = '';
	let vstransaccionFunCre3 = '';
	let vstransaccionFunCre4 = '';
	let vstransaccionRefCre1 = '';
	let vstransaccionRefCre2 = '';
	let vstransaccionRefCre3 = '';
	-- TRANSACCIONES DE TRANSFERENCIAS
	let vstransaccionTrans1 = '';
	let vstransaccionTrans2 = '';
	let vstransaccionTrans3 = '';
	let vstransaccionTrans4 = '';
	let vstransaccionTrans5 = '';
	let vstransaccionTrans6 = '';
	
	-- Recuperar comisiones e IVA de Nuevas transacciones de corresponsales
	set isolation to dirty read; select valor into vmComConsultaDebito 	          from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='311';
	set isolation to dirty read; select valor into vmComConsultaCredito           from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='312';
	set isolation to dirty read; select valor into vmComRetiroDebito              from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='313';
	set isolation to dirty read; select valor into vmComRetiroCredito             from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='314';
	set isolation to dirty read; select valor into vmComTransferencia             from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='315';
	set isolation to dirty read; select valor into vmComPagCreditoBCPLEfectiva    from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='316';
	set isolation to dirty read; select valor into vmComPagCreditoOtroEfectiva    from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='317';
	set isolation to dirty read; select valor into vmComPagCreditoOtroEfectivo    from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='318';
	set isolation to dirty read; select valor into vmIVAComConsultaDebito         from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='331';
	set isolation to dirty read; select valor into vmIVAComConsultaCredito        from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='332';
	set isolation to dirty read; select valor into vmIVAComRetiroDebito           from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='333';
	set isolation to dirty read; select valor into vmIVAComRetiroCredito          from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='334';
	set isolation to dirty read; select valor into vmIVAComTransferencia 		  from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='335';
	set isolation to dirty read; select valor into vmIVAComPagCreditoBCPLEfectiva from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='336';
	set isolation to dirty read; select valor into vmIVAComPagCreditoOtroEfectiva from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='337';
	set isolation to dirty read; select valor into vmIVAComPagCreditoOtroEfectivo from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='338';
	-- Recuperar comisiones e IVA de Nuevas transacciones de transferencias
	set isolation to dirty read; select valor into vmComTransPrestamo    from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='305';
	set isolation to dirty read; select valor into vmComTransGtosFun     from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='319';
	set isolation to dirty read; select valor into vmComTransFiniEmp     from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='320';
	set isolation to dirty read; select valor into vmComTransFondoAho    from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='321';
	set isolation to dirty read; select valor into vmComTransReparUti    from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='322';
	set isolation to dirty read; select valor into vmComTransPagoSegV    from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='323';
	set isolation to dirty read; select valor into vmIVAComTransPrestamo from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='310';
	set isolation to dirty read; select valor into vmIVAComTransGtosFun  from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='339';
	set isolation to dirty read; select valor into vmIVAComTransFiniEmp  from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='340';
	set isolation to dirty read; select valor into vmIVAComTransFondoAho from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='341';
	set isolation to dirty read; select valor into vmIVAComTransReparUti from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='342';
	set isolation to dirty read; select valor into vmIVAComTransPagoSegV from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='343';
	
		IF (psArchivoOrigenCred = 'TCC' OR psArchivoOrigenDeb = 'TCD'  ) THEN --CONADMIN

		 	--IF (psArchivoOrigenCred = 'TCC') THEN
			LET vdtFecha = SUBSTRING(psNomArchivoCred FROM 11 FOR 2) || '/' || SUBSTRING(psNomArchivoCred FROM 9 FOR 2) || '/' || SUBSTRING(psNomArchivoCred FROM 13 FOR 4);
			--ELIF (psArchivoOrigenDeb = 'TCD') THEN
				--LET vdtFecha = SUBSTRING(psNomArchivoDeb FROM 11 FOR 2) || '/' || SUBSTRING(psNomArchivoDeb FROM 9 FOR 2) || '/' || SUBSTRING(psNomArchivoDeb FROM 13 FOR 4);
			--END IF;

			SET LOCK MODE TO WAIT 3 ;
			SET ISOLATION TO DIRTY READ ;
			--OBTIENE TODAS LAS TRANSACCIONES APROBADAS DE POS EN ETIENDAS COPPEL KE NO SE CONCILIARON EL DIA ACTUAL Y KE FUERON REALIZADAS EL DIA ANTERIOR
			INSERT INTO InterCard:"informix".ConAdmIn(
					ArchivOorigen,NomArchivo325,NomArchivocom,FechaRegistro,TipoRegistro,
					Fecha,ProdTarjeta,Tarjeta,Cuenta,TipoMov,Tran_Central,
					Folio325,Monto325,Estatus,TxnLiberacion,CuentaC,
					CuentaA,FolioSIF,MontoSIF,SecIntercard,MontoIntcrd,
					FechaHoraInAuth,IdTerminal,TipoOperacion,Usuario)				
   	        SELECT CASE WHEN (numtarjeta[1,6] IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'D')) THEN psArchivoOrigenDeb
						WHEN (numtarjeta[1,6] IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'C')) THEN psArchivoOrigenCred 
						END ArchivOorigen,
				   CASE WHEN (numtarjeta[1,6] IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'D')) THEN psNomArchivoDeb
						WHEN (numtarjeta[1,6] IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'C')) THEN psNomArchivoCred 
						END NomArchivo325,
						psNomArchivoCom,
						CURRENT::DATE,
						'D',NVL(vdtFecha, CURRENT::DATE),'','','','','','','0.0','','','','','','0.0',
			secuencia, Monto, FechaHoraInAuth, SUBSTRING (IdTerminal FROM 1 FOR 4),'C',psNumEmpleado
			FROM Intercard:"informix".Movimiento
			WHERE FechaHoraInAuth::date = vdtFecha -1 -- FECHA DEL DIAN ANTERIOR EN LA QUE SE REALIZARON LOS MOVIMIENTOS/COMPRAS
			AND TransaccionOrigen = '0003'
			AND CodigoISO = '00'
            AND codreversa = '0'
            AND movreversado = 'F'
			AND secuencia NOT IN ( SELECT SecIntercard FROM InterCard:"informix".ConAdmIn 
									WHERE  NomArchivoCom = psNomArchivoCom
									AND TipoOperacion IS NOT NULL 
									AND Estatus IS NOT NULL 
									AND TipoRegistro = 'D'
								);

		ELIF (psArchivoOrigenDeb IN ('TPD','CCD')) THEN --CONCOR
		
			IF (psArchivoOrigenDeb = 'TPD') THEN
				LET vSucursal = '5006';
				LET vstransaccionTrans1 = '0283';
				LET vstransaccionTrans2 = '0410';
				LET vstransaccionTrans3 = '0411';
				LET vstransaccionTrans4 = '0412';
				LET vstransaccionTrans5 = '0413';
				LET vstransaccionTrans6 = '0414';
				let vsCadenaTransacc = '"'||vstransaccionTrans1||'","'||vstransaccionTrans2||'","'||vstransaccionTrans3||'","'||vstransaccionTrans4||'","'||vstransaccionTrans5||'","'||vstransaccionTrans6||'"';
							
			ELIF (psArchivoOrigenDeb = 'CCD') THEN
				LET vSucursal = '5005';
				let vstransaccionDeb1 = '0282';
				let vstransaccionDeb2 = '0401';
				let vstransaccionDeb3 = '0402';
				let vstransaccionDeb4 = '0404';
				let vsCadenaTransacc = '"'||vstransaccionDeb1||'","'||vstransaccionDeb2||'","'||vstransaccionDeb3||'","'||vstransaccionDeb4||'"';
				
			END IF;

			LET vdtFecha = (SUBSTRING(psNomArchivoDeb FROM 11 FOR 2) || '/' || SUBSTRING(psNomArchivoDeb FROM 9 FOR 2) || '/' || SUBSTRING(psNomArchivoDeb FROM 13 FOR 4));
			
			SET LOCK MODE TO WAIT 3 ;
			SET ISOLATION TO DIRTY READ ;
			SELECT count(*) 
					INTO vicontadorsif
				FROM BdiCheq:"informix".Sc_MovHis
					WHERE Empresa = '001'
					AND Cuenta IS NOT NULL
					AND Folio_Suc NOT IN (SELECT Folio325 FROM Intercard:"informix".ConAdmIn 
												WHERE 	NomArchivo325 = TRIM (NVL(psNomArchivoDeb, '')) AND  
														NomArchivocom = TRIM(NVL(psNomArchivoCom, '')) )
					AND ((transacc = vstransaccionDeb1) or (transacc = vstransaccionDeb2) or (transacc = vstransaccionDeb3) or (transacc = vstransaccionDeb4) or
						(transacc = vstransaccionTrans1)or (transacc = vstransaccionTrans2) or (transacc = vstransaccionTrans3) or (transacc = vstransaccionTrans4) or 
						(transacc = vstransaccionTrans5)or (transacc = vstransaccionTrans6))
					AND Sucursal = vSucursal
					AND Fech_Alt = vdtFecha -1
					AND Cancelad <> 'S';
			
			
			if vicontadorsif > 0 then 
				FOREACH WITH HOLD --PARA ARCHIVOS DE DEBITO CCD,TPD
					SELECT Num_Tarjeta, Cuenta, transacc, Folio_Suc, Monto_Tot, TransacC
						INTO vsTarjeta, vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC
					FROM BdiCheq:"informix".Sc_MovHis
						WHERE Empresa = '001'
						AND Cuenta IS NOT NULL
						AND Folio_Suc NOT IN (SELECT Folio325 FROM Intercard:"informix".ConAdmIn 
													WHERE 	NomArchivo325 = TRIM (NVL(psNomArchivoDeb, '')) AND  
															NomArchivocom = TRIM(NVL(psNomArchivoCom, '')) )
						AND ((transacc = vstransaccionDeb1) or (transacc = vstransaccionDeb2) or (transacc = vstransaccionDeb3) or (transacc = vstransaccionDeb4) or
							(transacc = vstransaccionTrans1)or (transacc = vstransaccionTrans2) or (transacc = vstransaccionTrans3) or (transacc = vstransaccionTrans4) or 
							(transacc = vstransaccionTrans5)or (transacc = vstransaccionTrans6))
						AND Sucursal = vSucursal
						AND Fech_Alt = vdtFecha -1
						AND Cancelad <> 'S'


					LET vsIdTerminal = SUBSTRING(vsFolioSIF FROM 1 FOR 4);

					SET ISOLATION TO DIRTY READ ;
					SET LOCK MODE TO WAIT 3;
					--OBTIENE EL PRODUCTO DE LA TARJETA
					SELECT FIRST 1 ProdTarjeta INTO vsProdTarjeta
					FROM BdiCheq:"informix".Sc_Tarjeta
					WHERE Empresa = '001'
					AND Num_Tarjeta = TRIM(vsTarjeta);


					--NO SE UTILIZAN EN TPD
					IF (psArchivoOrigenDeb = 'TPD') THEN
						LET vsCuentaC = '';
						LET vsCuentaA = '';
					ELSE
						SET ISOLATION TO DIRTY READ ;
						SET LOCK MODE TO WAIT 3;
						--OBTIENE LA RISTA CONTABLE DE LA TRANSACCION ACTUAL
						SELECT FIRST 1 TRIM (c_ccmayor) || '-' || TRIM (c_ccsub) || '-' || TRIM (c_ccsubsub) || '-' || TRIM (c_ccsssub) || '-' || TRIM (c_ccssssub) || '-' || TRIM (c_sector) AS CuentaC,
						TRIM (a_ccmayor) || '-' || TRIM (a_ccsub) || '-' || TRIM (a_ccsubsub) || '-' || TRIM (a_ccsssub) || '-' || TRIM (a_ccssssub) || '-' || TRIM (a_sector)  AS CuentaA
						INTO vsCuentaC, vsCuentaA
						FROM BdInteg:"informix".Si_ProdTran
						WHERE Empresa = '001'
						AND Producto = vsProdTarjeta
						AND Sistema IS NOT NULL
						AND Transaccion = vsTransacC
						AND Secuencia = 1;

					END IF;

					--GUARDA EL REGISTRO EN LA TABLA DE CONCILIACION ADMINISTRATIVA INTERREDES
					INSERT INTO Intercard:"informix".ConAdmIn
					(
						ArchivOorigen,
						NomArchivo325,NomArchivocom,FechaRegistro,TipoRegistro,
						Fecha,ProdTarjeta,Tarjeta,Cuenta,TipoMov,Tran_Central,Folio325,Monto325,
						Estatus,TxnLiberacion,CuentaC,CuentaA,FolioSIF,MontoSIF,SecIntercard,
						MontoIntcrd,FechaHoraInAuth,IdTerminal,TipoOperacion,Usuario
					)
					VALUES
					(
						NVL (psArchivoOrigenDeb, ''),TRIM(NVL (psNomArchivoDeb, '')),TRIM(NVL (psNomArchivoCom, '')),CURRENT::DATE,'D',
						NVL(vdtFecha, CURRENT::DATE),NVL (vsProdTarjeta, ''),NVL (vsTarjeta, ''),NVL (vsCuenta, ''),NVL ('', ''),NVL ('', ''),NVL ('', ''),NVL (0, 0.0),NVL ('', ''),NVL (vsTxnLiberacion, ''),NVL (vsCuentaC, ''),
						NVL (vsCuentaA, ''),NVL (vsFolioSIF, ''),NVL (vmMontoSIF, 0.0),NVL ('', ''),NVL (0, 0.0),
						NVL (CURRENT, CURRENT),NVL (vsIdTerminal, ''),NVL ('', ''),NVL (psNumEmpleado, '')
					);

				END FOREACH;
			end if;

		ELIF (psArchivoOrigenCred = 'CCP') THEN  -- Se cambio un if por elif
				
				LET vdtFecha = SUBSTRING(psNomArchivoCred FROM 11 FOR 2) || '/' || SUBSTRING(psNomArchivoCred FROM 9 FOR 2) || '/' || SUBSTRING(psNomArchivoCred FROM 13 FOR 4);
				
				let vstransaccionCre1 = '6282';
				let vstransaccionCre2 = '8106';
				let vstransaccionCre3 = '8105';
				let vstransaccionCre4 = '8104';

				let vstransaccionFunCre1 = '700';
				let vstransaccionFunCre2 = '002';
				let vstransaccionFunCre3 = '068';
				let vstransaccionFunCre4 = '000';

				let vstransaccionRefCre1 = '109';
				let vstransaccionRefCre2 = '1';
				let vstransaccionRefCre3 = '0';
				
				let vsCadenaTransacc = '"'||vstransaccionCre1||'","'||vstransaccionCre2||'","'||vstransaccionCre3||'","'||vstransaccionCre4||'"';
				let vsCadenaFun = '"'||vstransaccionFunCre1||'","'||vstransaccionFunCre2||'","'||vstransaccionFunCre3||'","'||vstransaccionFunCre4||'"';
				let vsCadenaRef = '"'||vstransaccionRefCre1||'","'||vstransaccionRefCre2||'","'||vstransaccionRefCre3||'"';
				
				SET LOCK MODE TO WAIT 3 ;
				SET ISOLATION TO DIRTY READ ;
				SELECT  count (*)
						INTO vicontadorsif
					FROM Bdicred:"informix".Sd_MovHis
						WHERE 	Empresa = '001'
								AND Num_Credito IS NOT NULL
								AND Folio_Suc NOT IN (SELECT Folio325 FROM Intercard:"informix".ConAdmIn WHERE  NomArchivo325 = UPPER(TRIM(NVL(psNomArchivoCred, ''))) AND NomArchivocom = TRIM(NVL(psNomArchivoCom, '')) )
								AND Sucursal = '5005'
								AND Fecha_Mov = vdtFecha -1
								AND Reversado <> 'S'
								AND ((transacc_suc = vstransaccionCre1) or (transacc_suc = vstransaccionCre2) or (transacc_suc = vstransaccionCre3) or (transacc_suc = vstransaccionCre4))--='6282'
								AND ((codigo_fun = vstransaccionFunCre1) or (codigo_fun = vstransaccionFunCre2) or (codigo_fun = vstransaccionFunCre3) or (codigo_fun = vstransaccionFunCre4)) -- ='700'
								AND ((codigo_ref = vstransaccionRefCre1) or (codigo_ref = vstransaccionRefCre2) or (codigo_ref = vstransaccionRefCre3)); --=1
				
				if  vicontadorsif > 0 then 
						FOREACH WITH HOLD --PARA CREDITO CCP
							SELECT  Nro_Tarjeta, Num_Credito, Transacc_Suc, Folio_Suc, Monto, TransacC_Suc
								INTO vsTarjeta, vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC
							FROM Bdicred:"informix".Sd_MovHis
								WHERE 	Empresa = '001'
										AND Num_Credito IS NOT NULL
										AND Folio_Suc NOT IN (SELECT Folio325 FROM Intercard:"informix".ConAdmIn WHERE  NomArchivo325 = UPPER(TRIM(NVL(psNomArchivoCred, ''))) AND NomArchivocom = TRIM(NVL(psNomArchivoCom, '')) )
										AND Sucursal = '5005'
										AND Fecha_Mov = vdtFecha -1
										AND Reversado <> 'S'
								AND ((transacc_suc = vstransaccionCre1) or (transacc_suc = vstransaccionCre2) or (transacc_suc = vstransaccionCre3) or (transacc_suc = vstransaccionCre4))--='6282'
								AND ((codigo_fun = vstransaccionFunCre1) or (codigo_fun = vstransaccionFunCre2) or (codigo_fun = vstransaccionFunCre3) or (codigo_fun = vstransaccionFunCre4)) -- ='700'
								AND ((codigo_ref = vstransaccionRefCre1) or (codigo_ref = vstransaccionRefCre2) or (codigo_ref = vstransaccionRefCre3)) --=1

							SELECT transacc_ifrs
							  INTO vsTransacC_ifrs
							  FROM bdicred:sd_transfun
							 where transacc = vsTransacC;
							 
							 IF nvl(vsTransacC_ifrs,'') <> '' THEN
								LET vsTransacC = vsTransacC_ifrs;
							 END IF;

							LET vsIdTerminal = SUBSTRING(vsFolioSIF FROM 1 FOR 4);

							SET ISOLATION TO DIRTY READ ;
							SET LOCK MODE TO WAIT 3;
							--OBTIENE EL PRODUCTO DE LA TARJETA
							SELECT FIRST 1 Prodtarjeta INTO vsProdTarjeta
								FROM Bdicred:"informix".Sd_Tarjeta
							WHERE 	Empresa = '001'
									AND Num_Tarjeta = TRIM(vsTarjeta);


							SET ISOLATION TO DIRTY READ ;
							SET LOCK MODE TO WAIT 3;
							--OBTIENE LA RISTA CONTABLE DE LA TRANSACCION ACTUAL
							SELECT FIRST 1 	TRIM (c_ccmayor) || '-' || TRIM (c_ccsub) || '-' || TRIM (c_ccsubsub) || '-' || TRIM (c_ccsssub) || '-' || TRIM (c_ccssssub) || '-' || TRIM (c_sector) AS CuentaC,
											TRIM (a_ccmayor) || '-' || TRIM (a_ccsub) || '-' || TRIM (a_ccsubsub) || '-' || TRIM (a_ccsssub) || '-' || TRIM (a_ccssssub) || '-' || TRIM (a_sector)  AS CuentaA
									INTO vsCuentaC, vsCuentaA
							FROM BdInteg:"informix".Si_ProdTran
								WHERE 	Empresa = '001'
										AND Producto = vsProdTarjeta
										AND Sistema IS NOT NULL
										AND Transaccion = vsTransacC
										AND Secuencia = 1;

							INSERT INTO Intercard:"informix".ConAdmIn
							(
								ArchivOorigen,NomArchivo325,NomArchivocom,FechaRegistro,TipoRegistro,
								Fecha,ProdTarjeta,Tarjeta,Cuenta,TipoMov,Tran_Central,Folio325,
								Monto325,Estatus,TxnLiberacion,CuentaC,CuentaA,FolioSIF,MontoSIF,
								SecIntercard,MontoIntcrd,FechaHoraInAuth,IdTerminal,TipoOperacion,Usuario
							)
							VALUES
							(
								NVL (psArchivoOrigenCred, ''),TRIM(NVL (psNomArchivoCred, '')),TRIM(NVL (psNomArchivoCom, '')),
								CURRENT::DATE,'D',NVL (vdtFecha, CURRENT::DATE),NVL (vsProdTarjeta, ''),NVL (vsTarjeta, ''),
								NVL (vsCuenta, ''),NVL ('', ''),NVL ('', ''),NVL ('', ''),NVL (0, 0.0),NVL ('', ''),
								NVL (vsTxnLiberacion, ''),NVL (vsCuentaC, ''),NVL (vsCuentaA, ''),NVL (vsFolioSIF, ''),
								NVL (vmMontoSIF, 0.0),NVL ('', ''),NVL (0, 0.0),NVL (CURRENT, CURRENT),NVL (vsIdTerminal, ''),
								NVL ('', ''),NVL (psNumEmpleado, '')
							);

						END FOREACH;	
				end if;
		END IF;
		

		--GUARDA EL REGISTRO EN LA TABLA DE CONCILIACION ADMINISTRATIVA INTERREDES CORREPONDIENTE A LOS TOTALES DE LAS TRANSACCIONES DE DEBITO

		SET LOCK MODE TO WAIT 3 ;
		SET ISOLATION TO DIRTY READ ;
		INSERT INTO Intercard:"informix".ConAdmIn
			(
				ArchivOorigen,NomArchivo325,NomArchivocom,FechaRegistro,TipoRegistro,
				Fecha,ProdTarjeta,Tarjeta,Cuenta,TipoMov,Tran_Central,Folio325,
				Monto325,Estatus,TxnLiberacion,CuentaC,CuentaA,
				FolioSIF,MontoSIF,
				SecIntercard,
				MontoIntcrd,FechaHoraInAuth,IdTerminal,TipoOperacion,Usuario
			)
			SELECT 	archivoorigen, NomArchivo325, NomArchivoCom,CURRENT::DATE,'T',
					NVL(vdtFecha, CURRENT::DATE),'','','','','', SUM (CASE WHEN Folio325 <> '' THEN 1 ELSE 0 END ) AS TOTAL_REGISTROS325,
					SUM (CASE WHEN Monto325 > 0.0 THEN Monto325 ELSE 0.0 END ) AS TOTAL_MONTO325,/*32*/	'', '', '', '',
					SUM (CASE WHEN FolioSIF <> '' THEN 1 ELSE 0 END ) AS TOTAL_REGISTROSSIF, SUM (CASE WHEN MontoSIF > 0.0 THEN MontoSIF ELSE 0.0 END ) AS TOTAL_MONTOSIF,  -- SIF
					SUM(CASE WHEN SecIntercard <> '' THEN 1 ELSE 0 END ) AS TOTAL_REGISTROSINTERCARD,
					SUM (CASE WHEN MontoIntcrd > 0.0 THEN MontoIntcrd  ELSE 0.0 END ) AS TOTAL_MONTOINTERCARD, -- INTERCARD
					CURRENT,'','',psNumEmpleado
			FROM InterCard:"informix".ConAdmIn
				WHERE 	NomArchivoCom = psNomArchivoCom
					AND TipoOperacion IS NOT NULL
					AND Estatus IS NOT NULL
					AND TipoRegistro = 'D'
			group by ArchivOorigen, NomArchivo325, NomArchivoCom;

		SET ISOLATION TO DIRTY READ ;
		IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames  WHERE tabname = 'td_tmp_conciliacion' AND dbsname= 'bditarjeta') THEN
			DROP TABLE bditarjeta:td_tmp_conciliacion;
		END IF;
		
		IF (psArchivoOrigenDeb = 'TCD' OR psArchivoOrigenCred = 'TCC'  ) THEN
				CREATE TABLE "informix".td_tmp_conciliacion
				(
					keyx SERIAL,
					IdTerminal CHAR(4),
					Fechamov DATETIME YEAR TO FRACTION(5),
					Monto MONEY(16,6),
					Comision MONEY(16,6),
					ComisionIva MONEY(16,6)
				);
		elif ( psArchivoOrigenDeb = 'TPD' ) then 
				CREATE TABLE "informix".td_tmp_conciliacion
				(
					keyx SERIAL,
					IdTerminal CHAR(4),
					Fechamov DATETIME YEAR TO FRACTION(5),
					Monto MONEY(16,6),
					Comision MONEY(16,6),
					ComisionIva MONEY(16,6)
				);
		ELIF (psArchivoOrigenDeb = 'CCD' OR psArchivoOrigenCred = 'CCP'  ) THEN
					CREATE TABLE "informix".td_tmp_conciliacion
				(
					keyx SERIAL,
					idTpoOperacion char(1),
					IdTerminal CHAR(4),
					Fechamov DATETIME YEAR TO FRACTION(5),
					Monto MONEY(16,6),
					Comision MONEY(16,6),
					ComisionIva MONEY(16,6)
				);
		end if;


		
		IF (psArchivoOrigenDeb = 'TCD' OR psArchivoOrigenCred = 'TCC'  ) THEN
			--GUARDA TOTALES DE MONTOS, COMISIONES E IVA POR TIENDA PARA EL ARCHIVO DE COPPEL
			SET LOCK MODE TO WAIT 3 ;
			SET ISOLATION TO DIRTY READ ;
			INSERT INTO bditarjeta:"informix".td_tmp_conciliacion(IdTerminal, Fechamov, Monto, Comision, ComisionIva)
			SELECT con.IdTerminal, (vdtFecha - 1) as fecha,SUM(con.Monto325),
			sum(CASE WHEN (con.NomArchivo325 = psNomArchivoDeb AND con.TipoOperacion = 'C') THEN psComisionD --ACUMULA EL TOTAL DE LAS COMISIONES DE CRED Y DEB
				 WHEN (con.NomArchivo325 = psNomArchivoCred AND con.TipoOperacion = 'C' ) THEN (con.Monto325 * (psComisionC / 100)) --SOLO TCC SE CALCULA COMISION POR MONTO DE LA OPERACION
				 WHEN (con.TipoOperacion = 'B') THEN  0
			END ) COMISION,
			sum(CASE WHEN (con.NomArchivo325 = psNomArchivoDeb AND con.TipoOperacion = 'C') THEN psComisionD * (psIvaD / 100) --ACUMULA EL TOTAL DEL IVA LAS COMISIONES DE CRED Y DEB
				 WHEN (con.NomArchivo325 = psNomArchivoCred AND con.TipoOperacion = 'C' ) THEN ((con.Monto325 * (psComisionC / 100)) * (psIvaC/100))  --SOLO TCC SE CALCULA IVA COMISION POR MONTO DE LA OPERACION
				 WHEN (con.TipoOperacion = 'B') THEN 0
			END )IVACOMISION
			FROM InterCard:"informix".ConAdmIn  con
			WHERE 	NomArchivoCom = psNomArchivoCom
					AND TipoOperacion IN  ('C','B')
					AND Estatus IN ('C', 'A')
					AND TipoRegistro = 'D'
			GROUP BY 1;
		
		elif (psArchivoOrigenDeb = 'TPD') then 
		
			SET LOCK MODE TO WAIT 3 ;
			SET ISOLATION TO DIRTY READ ;
			INSERT INTO bditarjeta:"informix".td_tmp_conciliacion(IdTerminal, Fechamov, Monto, Comision, ComisionIva)
			SELECT 	con.IdTerminal,
					vdtFecha - 1 as fecha,
					SUM(con.Monto325), 
					SUM (case   when (tran_central = '0283') then vmComTransPrestamo  -- Comision de Transferencia Actual 
								when (tran_central = '0410') then vmComTransGtosFun   -- Comision de Transferencia por Gastos Funerarios
								when (tran_central = '0411') then vmComTransFiniEmp   -- Comision de Transferencia por Finiquito de empleados
								when (tran_central = '0412') then vmComTransFondoAho  -- Comision de Transferencia por Fondos de empleados
								when (tran_central = '0413') then vmComTransReparUti  -- Comision de Transferencia por Reparto de Utilidades de empleados
								when (tran_central = '0414') then vmComTransPagoSegV  -- Comision de Transferencia por Seguro de Vida
							else
								0
								end) as comision, 
					SUM (case   when (tran_central = '0283') then vmComTransPrestamo  * (vmIVAComTransPrestamo/100)	  -- IVA Comision de Transferencia Actual 
								when (tran_central = '0410') then vmComTransGtosFun  * (vmIVAComTransGtosFun/100)  -- Comision de Transferencia por Gastos Funerarios
								when (tran_central = '0411') then vmComTransFiniEmp  * (vmIVAComTransFiniEmp/100)  -- Comision de Transferencia por Finiquito de empleados
								when (tran_central = '0412') then vmComTransFondoAho  * (vmIVAComTransFondoAho/100)  -- Comision de Transferencia por Fondos de empleados
								when (tran_central = '0413') then vmComTransReparUti  * (vmIVAComTransReparUti/100)  -- Comision de Transferencia por Reparto de Utilidades de empleados
								when (tran_central = '0414') then vmComTransPagoSegV  * (vmIVAComTransPagoSegV/100)  -- Comision de Transferencia por Seguro de Vida
							else
								0
								end) AS IVACOMISION 
			FROM Intercard:"informix".ConAdmIn  con
			WHERE NomArchivo325 MATCHES TRIM(psNomArchivoDeb) || '*'
			AND NomArchivoCom = psNomArchivoCom
			AND Monto325 > 0.0
			AND TipoRegistro = 'D'
			GROUP BY IdTerminal;
		
		ELSE --(CCP , CCD)  Se utiliza tabla diferente para poder hacer la diferencia de los tipos de operaciones conforme a la clasificaciÃ³n
			
			--CCD TPD -> DEBITO
			SET LOCK MODE TO WAIT 3 ;
			SET ISOLATION TO DIRTY READ ;
			INSERT INTO bditarjeta:"informix".td_tmp_conciliacion (idTpoOperacion, IdTerminal, Fechamov, Monto, Comision, ComisionIva )
			SELECT 
					con.TipoOperacion, 
					con.IdTerminal, 
					today - 1 as fecha,  
					SUM(con.Monto325), 
					sum(case    when (tran_central = '0282') then psComisionD                  -- Comision de Deposito 
								when (tran_central = '6282') then psComisionC                  -- Comision de Pago 
								when (tran_central = '0407') then vmComPagCreditoOtroEfectivo  -- Comision de Pago de TCD Otro en Efectivo
								when (tran_central = '0402') then vmComRetiroDebito            -- comision por Retiro de Debito
								when (tran_central = '8105') then vmComRetiroCredito           -- comision por retiro de credito
								when (tran_central = '0401') then vmComConsultaDebito          -- comision por consulta de debito
								when (tran_central = '8106') then vmComConsultaCredito         -- comision por consulta de credito
								when (tran_central = '0404') then vmComTransferencia           -- comision por transferencia efectivas
								when (tran_central = '8104') then vmComPagCreditoBCPLEfectiva  -- comision por pago de crÃ©dito BCPL 
								when (tran_central = '0406') then vmComPagCreditoOtroEfectiva  -- comision por pago de credito otro
							else
								0
								end) as comision,
					sum(case    when (tran_central = '0282') then psComisionD * (psIvaD/100)   	
								when (tran_central = '6282') then psComisionC * (psIvaC/100)   	
								when (tran_central = '0407') then vmComPagCreditoOtroEfectivo  * (vmIVAComPagCreditoOtroEfectivo/100)	
								when (tran_central = '0402') then vmComRetiroDebito  * (vmIVAComRetiroDebito/100)       
								when (tran_central = '8105') then vmComRetiroCredito * (vmIVAComRetiroCredito/100)     
								when (tran_central = '0401') then vmComConsultaDebito * (vmIVAComConsultaDebito/100)   
								when (tran_central = '8106') then vmComConsultaCredito * (vmIVAComConsultaCredito/100) 
								when (tran_central = '0404') then vmComTransferencia * (vmIVAComTransferencia/100)     
								when (tran_central = '8104') then vmComPagCreditoBCPLEfectiva * (vmIVAComPagCreditoBCPLEfectiva/100) 
								when (tran_central = '0406') then vmComPagCreditoOtroEfectiva * (vmIVAComPagCreditoOtroEfectiva/100) 
							else
								0
								end ) AS IVACOMISION
			FROM Intercard:"informix".ConAdmIn con
					WHERE NomArchivo325 MATCHES TRIM(psNomArchivoDeb) || '*'
					AND NomArchivoCom = psNomArchivoCom
					AND Monto325 > 0.0
					AND TipoRegistro = 'D'
					GROUP BY 1,2
					ORDER BY 2,1;
					/*SELECT  con.TipoOperacion
					con.IdTerminal, 
					vdtFecha - 1 as fecha,
					SUM(con.Monto325), 
					SUM (psComisionD) AS COMISION, 
					SUM(psComisionD * (psIvaD / 100)) AS IVACOMISION
					
			FROM Intercard:"informix".ConAdmIn con
			WHERE NomArchivo325 MATCHES TRIM(psNomArchivoDeb) || '*'
			AND NomArchivoCom = psNomArchivoCom
			AND Monto325 > 0.0
			AND TipoRegistro = 'D'
			GROUP BY 1,2;*/

			IF (TRIM(NVL(psArchivoOrigenCred, '')) = 'CCP') THEN --SOLO CORRESPONSALES  --
				-- CREDITO
				
				SET LOCK MODE TO WAIT 3 ;
				SET ISOLATION TO DIRTY READ ;
				INSERT INTO bditarjeta:"informix".td_tmp_conciliacion (idTpoOperacion, IdTerminal, Fechamov, Monto, Comision, ComisionIva )
				SELECT 
						con.TipoOperacion, 
						con.IdTerminal, 
						today - 1 as fecha,  
						SUM(con.Monto325), 
						sum(case    when (tran_central = '0282') then psComisionD                  -- Comision de Deposito 
									when (tran_central = '6282') then psComisionC                  -- Comision de Pago 
									when (tran_central = '0407') then vmComPagCreditoOtroEfectivo  -- Comision de Pago de TCD Otro en Efectivo
									when (tran_central = '0402') then vmComRetiroDebito            -- comision por Retiro de Debito
									when (tran_central = '8105') then vmComRetiroCredito           -- comision por retiro de credito
									when (tran_central = '0401') then vmComConsultaDebito          -- comision por consulta de debito
									when (tran_central = '8106') then vmComConsultaCredito         -- comision por consulta de credito
									when (tran_central = '0404') then vmComTransferencia           -- comision por transferencia efectivas
									when (tran_central = '8104') then vmComPagCreditoBCPLEfectiva  -- comision por pago de crÃ©dito BCPL 
									when (tran_central = '0406') then vmComPagCreditoOtroEfectiva  -- comision por pago de credito otro
								else
									0
									end) as comision,
						sum(case    when (tran_central = '0282') then psComisionD * (psIvaD/100)   	
									when (tran_central = '6282') then psComisionC * (psIvaC/100)   	
									when (tran_central = '0407') then vmComPagCreditoOtroEfectivo  * (vmIVAComPagCreditoOtroEfectivo/100)	
									when (tran_central = '0402') then vmComRetiroDebito  * (vmIVAComRetiroDebito/100)       
									when (tran_central = '8105') then vmComRetiroCredito * (vmIVAComRetiroCredito/100)     
									when (tran_central = '0401') then vmComConsultaDebito * (vmIVAComConsultaDebito/100)   
									when (tran_central = '8106') then vmComConsultaCredito * (vmIVAComConsultaCredito/100) 
									when (tran_central = '0404') then vmComTransferencia * (vmIVAComTransferencia/100)     
									when (tran_central = '8104') then vmComPagCreditoBCPLEfectiva * (vmIVAComPagCreditoBCPLEfectiva/100) 
									when (tran_central = '0406') then vmComPagCreditoOtroEfectiva * (vmIVAComPagCreditoOtroEfectiva/100) 
								else
									0
									end ) AS IVACOMISION
				FROM Intercard:"informix".ConAdmIn con
						WHERE NomArchivo325 MATCHES TRIM(psNomArchivoCred) || '*'
						AND NomArchivoCom = psNomArchivoCom
						AND Monto325 > 0.0
						AND TipoRegistro = 'D'
						GROUP BY 1,2
						ORDER BY 2,1;
				/*		
					SET LOCK MODE TO WAIT 3 ;
					SET ISOLATION TO DIRTY READ ;
					--CARGA DE DATOS A TABLA TEMPORAL PARA GENERAR EL ARCHIVO DE COMISIONES. --CREDITO
					INSERT INTO bditarjeta:"informix".td_tmp_conciliacion(IdTerminal, Fechamov, Monto, Comision, ComisionIva)
					SELECT 
							IdTerminal,
							vdtFecha - 1,
							SUM(Monto325), 
							SUM(psComisionC) AS COMISION, 
							SUM((psComisionC) * (psIvaC/100)) AS IVACOMISION
					FROM Intercard:"informix".ConAdmIn
						WHERE NomArchivo325 MATCHES TRIM(psNomArchivoCred) || '*'
						AND NomArchivoCom = psNomArchivoCom
						AND Monto325 > 0.0
						AND TipoRegistro = 'D'
						GROUP BY IdTerminal;*/

			END IF;

		END IF;


		-- TRANSFERIR DE TEMPORAL A FISICA
		IF (psArchivoOrigenDeb = 'TCD' OR psArchivoOrigenCred = 'TCC' or psArchivoOrigenDeb = 'TPD' ) THEN
			SET LOCK MODE TO WAIT 3 ;
			SET ISOLATION TO DIRTY READ ;
			INSERT INTO Intercard:"informix".ConArchcomisiones(ArchivoOrigen, NomArchivocom, IdTerminal, Fechamov, Monto, Comision, ComisionIva)--,idTpoOperacion,fisico) Se quitan 
				SELECT psArchivoOrigenCom,psNomArchivoCom,idterminal,fechamov,SUM(monto),SUM(comision),SUM(comisioniva)--,'',''
				FROM bditarjeta:"informix".td_tmp_conciliacion
				GROUP BY idterminal,fechamov;
		else
			SET LOCK MODE TO WAIT 3 ;
			SET ISOLATION TO DIRTY READ ;
			INSERT INTO Intercard:"informix".ConArchcomisiones(ArchivoOrigen, NomArchivocom, IdTerminal, Fechamov, Monto, Comision, ComisionIva,idTpoOperacion) --, fisico)
				SELECT psArchivoOrigenCom,psNomArchivoCom,idterminal,fechamov,SUM(monto),SUM(comision),SUM(comisioniva),REPLACE(REPLACE(REPLACE(idTpoOperacion,'E','1'),'S','2'),'N','3') --,''
				FROM bditarjeta:"informix".td_tmp_conciliacion
				GROUP BY idTpoOperacion,idterminal,fechamov;
		end if;

		---  SE ACTUALIZA LA FECHA DE LOS MOVIMIENTOS A UN DIA ANTERIOR AL DE LA FECHA DE HOY

        --UPDATE intercard:"informix".conarchcomisiones SET fechamov = vdtFecha  WHERE ArchivoOrigen = psArchivoOrigenCom AND NomArchivocom = psNomArchivoCom AND Fechamov IS NOT NULL;
		
		--TOTALIZAN REGISTROS
		
		IF (psArchivoOrigenDeb = 'TCD' OR psArchivoOrigenCred = 'TCC' or psArchivoOrigenDeb = 'TPD' ) THEN
		
			SELECT COUNT(*) INTO v_TotReg FROM intercard:"informix".conarchcomisiones WHERE ArchivoOrigen = psArchivoOrigenCom AND NomArchivocom = psNomArchivoCom AND Fechamov IS NOT NULL;

			INSERT INTO intercard:"informix".conarchcomisiones(ArchivoOrigen,NomArchivocom, IdTerminal, Fechamov, Monto, Comision, ComisionIva,fisico)
			VALUES (psArchivoOrigenCom,psNomArchivoCom, "0000", NVL(vdtFecha -1, CURRENT::DATE), v_TotReg, 0.0, 0.0,'V');
		
		else
		
			SELECT COUNT(*) INTO v_TotReg FROM intercard:"informix".conarchcomisiones WHERE ArchivoOrigen = psArchivoOrigenCom AND NomArchivocom = psNomArchivoCom AND Fechamov IS NOT NULL;
			SELECT COUNT(*) INTO v_TotRegEntrada FROM intercard:"informix".conarchcomisiones WHERE ArchivoOrigen = psArchivoOrigenCom AND NomArchivocom = psNomArchivoCom AND Fechamov IS NOT NULL and idTpoOperacion ='1';	
			SELECT COUNT(*) INTO v_TotRegSalida FROM intercard:"informix".conarchcomisiones WHERE ArchivoOrigen = psArchivoOrigenCom AND NomArchivocom = psNomArchivoCom AND Fechamov IS NOT NULL and idTpoOperacion ='2';
			SELECT COUNT(*) INTO v_TotRegNeutrales FROM intercard:"informix".conarchcomisiones WHERE ArchivoOrigen = psArchivoOrigenCom AND NomArchivocom = psNomArchivoCom AND Fechamov IS NOT NULL and idTpoOperacion ='3';
			INSERT INTO intercard:"informix".conarchcomisiones(ArchivoOrigen,NomArchivocom, IdTerminal, Fechamov, Monto, Comision, ComisionIva, idTpoOperacion,fisico)
			VALUES (psArchivoOrigenCom,psNomArchivoCom, "0000", NVL(vdtFecha -1, CURRENT::DATE), v_TotReg, v_TotRegEntrada, v_TotRegSalida, v_TotRegNeutrales,'V');
		
		end if;
		
	
		/*
		SELECT COUNT(*) INTO v_TotReg, SUM(monto) INTO v_SumMont, SUM(Comision) INTO v_SumComis, SUM(ComisionIva) INTO v_SumIva
		FROM intercard:"informix".conarchcomisiones WHERE ArchivoOrigen = psArchivoOrigenCom AND NomArchivocom = psNomArchivoCom AND Fechamov IS NOT NULL;
		INSERT INTO intercard:"informix".conarchcomisiones(ArchivoOrigen,NomArchivocom, IdTerminal, Fechamov, Monto, Comision, ComisionIva,fisico)
		VALUES (psArchivoOrigenCom,psNomArchivoCom, v_TotReg, vdtFecha , v_SumMont, v_SumComis, v_SumIva,'');
		-- codigo para agregar totales al archivo de comisiones. falta definir v_SumMont,v_SumComis,v_SumIva.
		*/

		--########################################## GENERA ARCHIVO DE COMISIONES #################################################################
		IF (psArchivoOrigenDeb = 'TCD' OR psArchivoOrigenCred = 'TCC' or psArchivoOrigenDeb = 'TPD' ) THEN
		
			LET vsSQL2 = "SELECT TRIM(idterminal) || '|' ||  TRIM(LPAD(month(fechamov),2,'0') || '/' || LPAD(day(fechamov),2,'0') || '/' ||"
			|| " year(fechamov)) || '|' || TRIM(REPLACE (SUBSTRING (monto FROM 1 FOR 20), '$','')) || '|' ||"
			|| " TRIM(REPLACE (SUBSTRING (comision FROM 1 FOR 20), '$',''))|| '|' || TRIM(REPLACE (SUBSTRING (comisioniva FROM 1 FOR 20), '$', '')) "
			|| " FROM intercard:ConArchcomisiones WHERE  NomArchivocom = '" || psNomArchivoCom || "' AND Fechamov IS NOT NULL ORDER BY KeyX";

			--ajusta el nombre del archivo fisico para que se cree con la fecha de ayer.
			LET psNomArchivoCom = REPLACE (psNomArchivoCom, REPLACE(NVL(vdtFecha , CURRENT::DATE),'/', ''), REPLACE(NVL(vdtFecha -1 , CURRENT::DATE),'/', '') );
		
		else
		
			LET vsSQL2 = "SELECT TRIM(idterminal) || '|' ||  TRIM(LPAD(month(fechamov),2,'0') || '/' || LPAD(day(fechamov),2,'0') || '/' ||"
			|| " year(fechamov)) || '|' || TRIM(REPLACE (SUBSTRING (monto FROM 1 FOR 20), '$','')) || '|' ||"
			|| " TRIM(REPLACE (SUBSTRING (comision FROM 1 FOR 20), '$',''))|| '|' || TRIM(REPLACE (SUBSTRING (comisioniva FROM 1 FOR 20), '$', '')) "
			|| " || '|' || TRIM(REPLACE (SUBSTR (idTpoOperacion,1,10), '$', '')) "
			|| " FROM intercard:ConArchcomisiones WHERE  NomArchivocom = '" || psNomArchivoCom || "' AND Fechamov IS NOT NULL ORDER BY KeyX";

			--ajusta el nombre del archivo fisico para que se cree con la fecha de ayer.
			LET psNomArchivoCom = REPLACE (psNomArchivoCom, REPLACE(NVL(vdtFecha , CURRENT::DATE),'/', ''), REPLACE(NVL(vdtFecha -1 , CURRENT::DATE),'/', '') );

		end if;
		
		IF ( psArchivoOrigenCom = 'ACI') THEN

			LET vsSQL1 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(psRuta)||'/tmp_concitarj.txt DELIMITER ' || '''?''';
			LET vsSQL3 = '">'||TRIM(psRuta)||'/tmp_consiliacion.sql';
			LET vsSQL4 = "chmod 777 " || TRIM(psRuta) || "/tmp_consiliacion.sql";
			LET vsSQL5 = 'dbaccess intercard ' || TRIM(psRuta) ||'/tmp_consiliacion.sql';
			--LET vsSQL6 =  "chmod 777 /home/sysconau/rem_signo.sh ";
			--LET vsSQL7 =  "/home/sysconau/rem_signo.sh";
			--LET psNomArchivoCom = TRIM ('concitarj' || LPAD(Month(vdtFecha -1),2,'0') LPAD(day(vdtFecha -1),2,'0') || year(vdtFecha -1) || '.txt');
			LET vsSQL7 =  "sed 's/?$//g' " || TRIM(psRuta) || '/' || TRIM ('tmp_concitarj.txt') || " > " || TRIM(psRuta) || '/' ||  TRIM (psNomArchivoCom);
			LET vsSQL8 = 'rm ' || TRIM(psRuta) || '/' || TRIM ('tmp_concitarj.txt');

		ELIF ( psArchivoOrigenCom = 'ACC') THEN

			LET vsSQL1 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(psRuta)||'/tmp_concicorr.txt DELIMITER ' || '''?''';
			LET vsSQL3 = '">'||TRIM(psRuta)||'/tmp_conciliacion_corr.sql';
			LET vsSQL4 = "chmod 777 " || TRIM(psRuta)|| "/tmp_conciliacion_corr.sql";
			LET vsSQL5 = 'dbaccess intercard ' || TRIM(psRuta) ||'/tmp_conciliacion_corr.sql';
			--LET vsSQL6 =  "chmod 777 /home/sysconau/rem_signo2.sh ";

			LET vsSQL7 =  "sed 's/?$//g' " || TRIM(psRuta) || '/' || TRIM ('tmp_concicorr.txt') || " > " || TRIM(psRuta) || '/' ||  TRIM (psNomArchivoCom);
			LET vsSQL8 = 'rm ' || TRIM(psRuta) || '/' || TRIM ('tmp_concicorr.txt');

		ELIF ( psArchivoOrigenCom = 'ACT') THEN  --TRANSFERENCIA DE PRESTAMOS

			LET vsSQL1 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(psRuta)||'/tmp_concipres.txt DELIMITER ' || '''?''';
			LET vsSQL3 = '">'||TRIM(psRuta)||'/tmp_conciliacion_pres.sql';
			LET vsSQL4 = "chmod 777 " || TRIM(psRuta) || "/tmp_conciliacion_pres.sql";
			LET vsSQL5 = 'dbaccess intercard ' || TRIM(psRuta) ||'/tmp_conciliacion_pres.sql';
			--LET vsSQL6 =  "chmod 777 /home/sysconau/rem_signo3.sh ";

			LET vsSQL7 =  "sed 's/?$//g' " || TRIM(psRuta) || '/' || TRIM ('tmp_concipres.txt') || " > " || TRIM(psRuta) || '/' ||  TRIM (psNomArchivoCom);
			LET vsSQL8 = 'rm ' || TRIM(psRuta) || '/' || TRIM ('tmp_concipres.txt');


		END IF;


		LET vsSQL1 = TRIM(vsSQL1);
		LET vsSQL3 = TRIM(vsSQL3);
		LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;

		IF ( vsSQL <> '' ) THEN
			SYSTEM vsSQL ;
			SYSTEM vsSQL4;
			SYSTEM vsSQL5;
		END IF;


		--SYSTEM vsSQL6;
		SYSTEM vsSQL7;
		SYSTEM vsSQL8;




		EXECUTE PROCEDURE bditarjeta:"informix".sp_con_buscararchivo(TRIM(psRuta), TRIM(psNomArchivoCom))
		--EXECUTE PROCEDURE bditarjeta:"informix".sp_tef_buscararchivo(TRIM(psRuta), TRIM(psNomArchivoCom))
		INTO vsCodRetorno2, v_BandBA;

		IF (vsCodRetorno2 <> '00000') THEN
			LET P_COD_RET = '00001';
			LET P_MENSAJE = '(' || P_COD_RET || ') Error en sp_con_buscararchivo (' || psRuta || ', ' || psNomArchivoCom || ')';
			ELIF (vsCodRetorno2 = "00000" AND v_BandBA = "F") THEN
				LET P_COD_RET = "00002";
				LET P_MENSAJE = '(' || P_COD_RET || ') No se encontro el archivo ' || psNomArchivoCom || ' en la ruta: ' || psRuta;
			ELIF (vsCodRetorno2 = "00000" AND v_BandBA = "V") THEN
				LET P_COD_RET = P_COD_RET;
				LET P_MENSAJE = '';
		END IF;


   RETURN P_COD_RET,P_MENSAJE,id_proceso;
END
END PROCEDURE
DOCUMENT
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE AJUSTA LA LOGICA PARA EL RECONOCIMIENTO DE LOS BINES DE DEBITO A NIVEL DE REGISTRO.',
'Fecha: 2012/18/18',
'Version: 20120418.1702',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE MODIFICA LA COMPARACION DE BINES DE LAS TARJETAS PARA IMPLEMENTAR EL MODELO MULTIBINES SOLICITADO.',
'Fecha: 2012/04/19',
'Version: 20120419.1016',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE MODIFICA LA LOGICA DE INTERREDES PARA PODER MANEJAR CORRECTAMENTE LOS ARCHIVOS EXTEMPORANEOS.',
'Fecha: 2012/07/04',
'Version: 20120704.1808',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE MODIFICA LA LOGICA PARA SEPARAR LA OBTENCION DE INFORMACION DE CREDITO PARA EL ARCHIVO DE CCP COYO ARCHIVO COMPANERO ES CCD, YA QUE EL ARCHIVO TPD ES UNICAMENTE DE DEBITO.',
'Fecha: 2012/07/05',
'Version: 20120705.1035',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE MODIFICA EL CALCULO DE LAS COMISIONES Y EL IVA DE LAS COMISIONES, ADEMAS DE AJUSTAR EL FLUJO DEL CALCULO DE COMISIONES PARA EL ARCHIVO DE CCP.',
'Fecha: 2012/07/20',
'Version: 20120720.1732',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE AJUSTA LA LOGICA PARA EL CALCULO DEL REGISTRO DE TOTALES Y QUE UTILICE LA INFORMACION EXISTENTE DE LOS REGISTROS A UTILIZAR.',
'Fecha: 2012/07/23',
'Version: 20120723.1142',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE AJUSTA LA LOGICA PARA EL CALCULO COMISIONES PARA EL CASO DE LOS TCC, EN LOS CUALES SE CALCULA LA COMISION EN IVA DE ACUERDO AL MONTO DE LA OPERACION.',
'Fecha: 2012/07/23',
'Version: 20120723.1757',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE AJUSTA LA FECHA QUE SE REGISTRA EN LOS MOVIMINTOS DE DETALLE.',
'Fecha: 2012/07/25',
'Version: 20120725.1130',

'BD: BdiTarjeta',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE MODIFICA EL INSERT DEL REGISTRO DE TOTALES PARA MARCAR EL CAMPO FISICO = V QUE3 INDICA LA GENERACION EXITOSA DEL ARCHIVO.',
'Fecha: 2012/07/26',
'Version: 20120726.1215',
'BD: BdiTarjeta',
'',
'MODIFICACION: CASANOVA EDEZA HECTOR JUAN',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE MODIFICA LA LOGICA PARA QUE EL NOMBREARCHIVO CRED Y DEB SE PASE A MAYUSCULAS PARA QUE COINCIDA CON LO ALMACENADO EN LA TABLA ConAdmIn.',
'Fecha: 2012/08/21',
'Version: 20120821.1821',
'BD: BdiTarjeta',
'',
'MODIFICACION: CASANOVA EDEZA HECTOR JUAN',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE MODIFICA LA LOGICA PARA MODIFICAR LA FECHA CON LA QUE SE GENERAN LOS ARCHIVOS DE COMISIONES, DE LA FECHA ACTUAL POR LA FECHA DE AYER.',
'Fecha: 2012/10/08',
'Version: 20121008.1645',
'BD: BdiTarjeta',
'',
'MODIFICACION: L.I.A. Ricardo ResÃ©ndiz MartÃ­nez',
'Proyecto: Nuevas transacciones de Corresponsales ',
'Solicito: Jose Luis Puebla Salina ',
'Descripcion: Se modifica el proceso de generacion de archivo y se hacen bifurcaciones para lograr armar archivos de comisiones',
'Fecha: 2015/10/05',
'Version: 20151005.1200',
'BD: BdiTarjeta',
'',
'MODIFICACION: L.I.A. Ricardo ResÃ©ndiz MartÃ­nez',
'Proyecto: Nuevas transacciones de transferencias ',
'Solicito: Jose Luis Puebla Salina ',
'Descripcion: Se modifica el proceso para contemplar nuevas transacciones de transferencias',
'Fecha: 2016/10/25',
'Version: 20161025.1900',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_obtienemaquilaauto()
RETURNING CHAR(6);

DEFINE iSqlErr  		INTEGER;
DEFINE cCodRet  		CHAR(6);
DEFINE cSql				CHAR(1000);
DEFINE cRuta			CHAR(50);
DEFINE cSucursal		CHAR(4);
DEFINE cNomSuc 			CHAR(40);
DEFINE cMes				CHAR(2);
DEFINE cDia				CHAR(2);
DEFINE cAnio			CHAR(4);
DEFINE cFechaHoy		CHAR(20);
DEFINE cNomArch			CHAR(100);
DEFINE cRutaArchivo		CHAR(200);
DEFINE iGCB				INTEGER;
DEFINE iNumTarSoli		INTEGER;
DEFINE iNumTarCteNvo	INTEGER;
DEFINE iNumTarRepo		INTEGER;
DEFINE iTotal			INTEGER;
DEFINE cFechaMesAnt		CHAR(20);

LET iSqlErr			= 0;
LET cCodRet 		= '000000';
LET cSql 			= '';
LET cRuta 			= '';
LET cNomSuc			= '';
LET	cSucursal		= '';
LET cFechaHoy		= '';
LET cNomArch		= '';
LET cRutaArchivo	= '';
LET cMes			= '';
LET cDia			= '';
LET cAnio			= '';
LET iGCB			= 0;
LET iNumTarSoli		= 0;
LET iNumTarCteNvo	= 0;
LET iNumTarRepo		= 0;
LET iTotal			= 0;
LET cFechaMesAnt	= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodret = iSqlErr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/home/sysifx/Oscar/736/sp_obtienemaquilaauto.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT valor INTO cRuta FROM bdicred:"informix".sd_param WHERE cod_param = '130' AND empresa = '001';
	SELECT valor INTO cNomArch FROM bdicred:"informix".sd_param WHERE cod_param = '132' AND empresa = '001';
	
	IF TRIM(NVL(cRuta,'')) != '' AND TRIM(NVL(cNomArch,'')) != '' THEN
		SELECT fecha_hoy, ADD_MONTHS(fecha_hoy, -1)
		INTO cFechaHoy, cFechaMesAnt
		FROM bdicred:"informix".sd_fechas 
		WHERE empresa = '001';
		
		LET cDia = LPAD(DAY(cFechaHoy::DATE), 2, '0');
		LET cMes = LPAD(MONTH(cFechaHoy::DATE), 2, '0');
		LET cAnio = YEAR(cFechaHoy);
		
		LET cNomArch = REPLACE(cNomArch,'dd',cDia);
		LET cNomArch = REPLACE(cNomArch,'mm',cMes);
		LET cNomArch = REPLACE(cNomArch,'aaaa',cAnio);
		LET cNomArch = TRIM(cNomArch) || '.txt';
		
		LET cRutaArchivo = TRIM(cRuta) || TRIM(cNomArch);
		
		--Elimina archivo
		LET cSQL = 'rm -rf ' || TRIM(cRutaArchivo);		
		SYSTEM cSQL;	
		--Crea archivo vacio
		LET cSQL = 'touch ' || TRIM(cRutaArchivo);
		SYSTEM cSQL;
		
		FOREACH
			SELECT TRIM(nombre), sucursal ,id_gerencia_rh AS GCB 
			INTO cNomSuc, cSucursal, iGCB
			FROM bdinteg:"informix".si_sucursales 
			WHERE nombre LIKE 'SUC%'
			ORDER BY sucursal
			
			--No. de tarjetas solicitadas
			SELECT lot.cantidadtarjetassol AS TarjetasSolicitadas	
			INTO iNumTarSoli
			FROM intercard:"informix".sucursal suc, intercard:"informix".lote lot , 
				intercard:"informix".flujolote flulot, intercard:"informix".tipotarjeta tipotar 
			WHERE suc.clave_sucursal = cSucursal
			AND suc.clave_sucursal = lot.clave_sucursal 
			AND lot.numerolote = flulot.numerolote
			AND tipotar.clave_tipotarjeta = '007'
			AND lot.clave_tipotarjeta = tipotar.clave_tipotarjeta
			AND lot.fechageneracion::DATE = cFechaMesAnt
			GROUP BY suc.clave_sucursal, lot.cantidadtarjetassol;
			
			--No. de tarjetas entregadas a clientes nuevos
			SELECT COUNT(tar.num_tarjeta)
			INTO iNumTarCteNvo
			FROM bdicred:"informix".sd_tarjeta AS tar
			LEFT JOIN bdicred:"informix".sd_maecred AS cred ON tar.numcte = cred.numcte
			LEFT JOIN bdisolic:"informix".ss_solicitudes AS sol ON sol.numcte = tar.numcte AND sol.num_solicitud = cred.num_credito
			WHERE tar.prodtarjeta = '8100'
			AND sol.status_solicitud = 'AP'
			AND sol.fecha_insert = cFechaMesAnt
			AND sol.sucursal = cSucursal
			GROUP BY sol.sucursal;
			
			--No. de tarjetas entregadas a clientes por reposiciones
			SELECT COUNT(tar.num_tarjeta)
			INTO iNumTarRepo
			FROM bdicred:"informix".sd_tarjeta tar, bdisolic:"informix".ss_solicitudes sol
			WHERE sol.num_solicitud = tar.num_credito
			AND sol.fecha_insert = cFechaMesAnt
			AND tar.prodtarjeta = '8100'
			AND tar.secuencia > 1
			AND sol.sucursal = cSucursal
			AND sol.status_solicitud = 'AP';
			
			LET iTotal = (NVL(iNumTarSoli,0) + NVL(iNumTarCteNvo,0) + NVL(iNumTarRepo,0));
			
			--Escribe en archivo
			LET cSQL = 'echo "' || TRIM(cNomSuc) || ' | ' || TRIM(cSucursal) || ' | ' || NVL(iGCB,0) || ' | ' || NVL(iNumTarSoli,0) || ' | ' || NVL(iNumTarCteNvo,0) || ' | ' || NVL(iNumTarRepo,0) || ' | ' || iTotal || '" >> ' || cRutaArchivo;
			SYSTEM cSQL;
			
		END FOREACH;		
	ELSE
		LET cCodret = '000001';
	END IF;	
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'Se crea SP para la creacion de txt para proceso de abastecimiento automÃ¡tico.',
'AUTOR : Oscar Marquez 98681011',
'FECHA : 08/05/2021',
'BD    : INTERCARD';

CREATE PROCEDURE "informix".sp_monitor_volumen_tablas()
    RETURNING VARCHAR(5) as rCODIGO_RETORNO, VARCHAR (80) as rMENSAJE_RETORNO, 
				DECIMAL(19,2) as rPorcentaje, VARCHAR(100)  as rAcotacion;
	
    DEFINE SQLERR INTEGER;
	DEFINE ISAM_ERR INTEGER;
	DEFINE ERROR_INFO VARCHAR(80);    
    DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(80);
    DEFINE vPrefijoArchivoUNL VARCHAR(10);
    DEFINE vPrefijoScripts VARCHAR(10);
    DEFINE vPrefijoScriptsSalida VARCHAR(10);
    DEFINE vCodigoRetorno VARCHAR(5);
    DEFINE vMensajeRespuesta VARCHAR(80);
    DEFINE vTabId INTEGER;
    DEFINE vGrupoBD VARCHAR(6);
    DEFINE vNombreBD VARCHAR(15);
    DEFINE vNombreTabla VARCHAR(50);
    DEFINE vExecuteSQL LVARCHAR(800);    
    DEFINE vConteoReg INTEGER;
    DEFINE vExisteRegistro INTEGER;
    DEFINE vValorPorcentaje VARCHAR(5);
    DEFINE vIndicadorPorcentaje DECIMAL(19,2);
    DEFINE vDescripcionPorcentaje VARCHAR(100);
    
    LET SQLERR = '';
	LET ISAM_ERR = '';
	LET ERROR_INFO = '';    
    LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';
    LET vCodigoRetorno = '00000';
    LET vMensajeRespuesta = 'Iniciando el proceso';
    LET vTabId = '';
    LET vGrupoBD = '';
    LET vNombreBD = '';
    LET vNombreTabla = '';
    LET vExecuteSQL = '';
    LET vPrefijoArchivoUNL = 'mnt_trx_';
    LET vPrefijoScripts = 'scpt_mnt_';
    LET vPrefijoScriptsSalida = 'scpt_sal_';
    LET vConteoReg = 0;
    LET vExisteRegistro = 0;    
    LET vValorPorcentaje = 0;
    LET vIndicadorPorcentaje = 0;    
    LET vDescripcionPorcentaje = '';
    
    --SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS|| 'debug_sp_monitor_volumen_tablas.out';
    --TRACE ON;
    
	BEGIN
    
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS || "excep_sp_monitor_volumen_tablas.err.out" WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET vCodigoRetorno = SQLERR;
                LET vMensajeRespuesta = vMensajeRespuesta;
                RETURN vCodigoRetorno, vMensajeRespuesta, vIndicadorPorcentaje, vDescripcionPorcentaje;
            END IF;
			
        END EXCEPTION;
		
        SET ISOLATION TO DIRTY READ; 
        SET LOCK MODE TO WAIT 3;
        
        ---Eliminacion de archivos con ejecucion previa del proceso.
        LET vExecuteSQL = '';
        LET vExecuteSQL= 'rm -f ' ||RUTA_UNLOAD_RESPALDOS||vPrefijoScriptsSalida||'*';
        SYSTEM vExecuteSQL;

        ---Inicializar los tabids por si en algún momento las tablas fueron previamente renombradas.
        FOREACH curTabId WITH HOLD FOR 
            
            SELECT {+AVOID_FULL(intercard:"informix".tbl_monitor_tablas_transacc)}
                    grupo_bd, tabid, nombre_bd, nombre_tabla
                INTO vGrupoBD, vTabId, vNombreBD, vNombreTabla
            FROM intercard:"informix".tbl_monitor_tablas_transacc
            ORDER BY nombre_bd, nombre_tabla
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; '||
            '   MERGE INTO intercard:tbl_monitor_tablas_transacc as b ' ||
            '     USING  '||
            '       (  '||
            "         SELECT * "||
            "            FROM "||vNombreBD||":systables   "||
            "         WHERE tabname = '"||vNombreTabla||"'"||
            "           AND owner = 'informix' "||
            '       )as sys  '||
            '       ON (b.nombre_tabla = sys.tabname)  '||
            '   WHEN MATCHED THEN UPDATE  '||
            '    SET b.tabid = sys.tabid;'||
            '" >'||RUTA_UNLOAD_RESPALDOS||vPrefijoScripts||vNombreBD||vNombreTabla||'.sql';
            SYSTEM vExecuteSQL;
            
            LET vExecuteSQL ='';
            LET vExecuteSQL= 'chmod 777 ' ||RUTA_UNLOAD_RESPALDOS||vPrefijoScripts||vNombreBD||vNombreTabla||'.sql';
            SYSTEM vExecuteSQL;

            LET vExecuteSQL ='';
            LET vExecuteSQL= 'dbaccess intercard ' ||RUTA_UNLOAD_RESPALDOS||vPrefijoScripts||vNombreBD||vNombreTabla||'.sql 2>> '||RUTA_UNLOAD_RESPALDOS||vPrefijoScriptsSalida||'curtabid.log';
            SYSTEM vExecuteSQL;
            
            LET vCodigoRetorno ='00000';
            LET vMensajeRespuesta ='Ejec #1:'||vNombreTabla;
            
            LET vExecuteSQL ='';
            LET vExecuteSQL= 'rm -f ' ||RUTA_UNLOAD_RESPALDOS||vPrefijoScripts||vNombreBD||'*';
            SYSTEM vExecuteSQL; 
            
        END FOREACH
        
        FOREACH curTotalReg WITH HOLD FOR 
            
            SELECT {+AVOID_FULL(intercard:"informix".tbl_monitor_tablas_transacc)} 
                    tabid, nombre_bd, nombre_tabla
                INTO vTabId, vNombreBD, vNombreTabla
            FROM intercard:"informix".tbl_monitor_tablas_transacc
                WHERE habilitada = 'S'
            ORDER BY nombre_bd, nombre_tabla
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; '||
            "   UPDATE  intercard:tbl_monitor_tablas_transacc "||
            "      SET total_registros =  (SELECT COUNT(*) as total_registros FROM "||vNombreBD||":"||vNombreTabla||") "||
            "   WHERE nombre_bd = '"||vNombreBD||"' AND  nombre_tabla = '"||vNombreTabla||"'"||
            '  ;'||            
            '" >'||RUTA_UNLOAD_RESPALDOS||vPrefijoScripts||vTabId||'.sql';
            SYSTEM vExecuteSQL;
            
            LET vExecuteSQL ='';
            LET vExecuteSQL= 'chmod 777 ' ||RUTA_UNLOAD_RESPALDOS||vPrefijoScripts||vTabId||'.sql';
            SYSTEM vExecuteSQL;
            
            LET vExecuteSQL ='';
            LET vExecuteSQL= 'dbaccess intercard ' ||RUTA_UNLOAD_RESPALDOS||vPrefijoScripts||vTabId||'.sql  2> '||RUTA_UNLOAD_RESPALDOS||vPrefijoScriptsSalida||'curtotalreg.log';
            SYSTEM vExecuteSQL;
            
            LET vCodigoRetorno = '00000';
            LET vMensajeRespuesta ='Ejec #2:'||vNombreTabla;
            
            LET vExecuteSQL ='';
            LET vExecuteSQL= 'rm -f ' ||RUTA_UNLOAD_RESPALDOS||vPrefijoScripts||vTabId||'*';
            --SYSTEM vExecuteSQL;
            
        END FOREACH
        
        MERGE INTO "informix".tbl_monitor_tablas_transacc as cmp
            USING
                ( 
                SELECT {+AVOID_FULL (sysmaster:systabnames)} 
                        st.tabname, st.dbsname,
                        format_units(SUM(i.ti_nptotal), MAX(sd.pagesize)) total_size,
                        format_units(SUM(i.ti_npused), MAX(sd.pagesize)) used_size
                    FROM
                        sysmaster:systabnames st INNER JOIN intercard:"informix".tbl_monitor_tablas_transacc b
                    ON (st.tabname = b.nombre_tabla AND st.tabname = b.nombre_tabla) INNER JOIN sysmaster:sysdbspaces sd
                        ON (sd.dbsnum = TRUNC(st.partnum/1048576) ) INNER JOIN sysmaster:systabinfo i
                            ON ( st.partnum = i.ti_partnum )
                        WHERE sd.owner = 'informix'
                            AND st.owner = 'informix'
                                AND st.dbsname = b.nombre_bd
                    GROUP BY 1,2
                ) as tmp_reg
                ON tmp_reg.tabname = cmp.nombre_tabla AND tmp_reg.dbsname = cmp.nombre_bd
            WHEN MATCHED THEN
                UPDATE
                    SET cmp.total_size = tmp_reg.total_size, 
                            cmp.used_size = tmp_reg.used_size;

        LET vCodigoRetorno = '00000';
        LET vMensajeRespuesta ='Obtener parametro porcentaje';
        
        SELECT valores
            INTO vValorPorcentaje
        FROM intercard:"informix".tbl_inter_parametros
            WHERE cond_busqueda = 'ind_pcte_vol'
                AND empresa = '001';
        
        LET vCodigoRetorno = '00000';
        LET vMensajeRespuesta ='Obtener descripcion porcentaje';
        
		SELECT descripcion 
			INTO vDescripcionPorcentaje
		FROM tbl_inter_parametros 
			WHERE cond_busqueda = 'msj_monitor_volumen';
            
        LET vIndicadorPorcentaje = vValorPorcentaje::DECIMAL(19,2);

        LET vCodigoRetorno = '00000';
        LET vMensajeRespuesta ='Descargar informacion';
        
        FOREACH curTotalReg WITH HOLD FOR 
        
            SELECT {+AVOID_FULL (intercard:"informix".tbl_monitor_tablas_transacc)}
                   DISTINCT nombre_bd
                INTO vNombreBD
            FROM intercard:"informix".tbl_monitor_tablas_transacc
                WHERE habilitada = 'S'
            
            LET vExecuteSQL	= '';
            LET vExecuteSQL = 'echo " '||
            '  SET ISOLATION TO DIRTY READ; '||
            '  SET LOCK MODE TO WAIT 3; '||
            '    UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||'monitor_tbls_'||vNombreBD||'.unl'||
            '      SELECT nombre_bd, nombre_tabla, total_registros, total_size, used_size, '  ||
            '           SUBSTR(total_size, CHAR_LENGTH(total_size) - 1, CHAR_LENGTH(total_size)) as T, '  ||
            '           SUBSTR(used_size, CHAR_LENGTH(used_size) - 1, CHAR_LENGTH(used_size)) as U, '  ||
            '           '||vIndicadorPorcentaje||
            '      FROM intercard:"informix".tbl_monitor_tablas_transacc ' ||
            "     WHERE nombre_bd = '"||vNombreBD||"'"||
            "       AND habilitada = 'S' "||
            "     ORDER BY 3 DESC "||
             '" >'||RUTA_UNLOAD_RESPALDOS||'ejec_unl_monitor.sql';
            SYSTEM vExecuteSQL;        
            
            LET vExecuteSQL   = '';
            LET vExecuteSQL   = 'dbaccess intercard '||RUTA_UNLOAD_RESPALDOS||'ejec_unl_monitor.sql 2> '||RUTA_UNLOAD_RESPALDOS||vPrefijoScriptsSalida||'err_unload.log';
            SYSTEM vExecuteSQL;
        
            LET vCodigoRetorno = '00000';
            LET vMensajeRespuesta ='Descarga' ||vNombreBD;
        
            LET vExecuteSQL ='';
            LET vExecuteSQL= 'rm -f ' ||RUTA_UNLOAD_RESPALDOS||'ejec_unl_monitor.sql';
            SYSTEM vExecuteSQL;
            
        END FOREACH
        
        LET vCodigoRetorno = '00000';
        LET vMensajeRespuesta ='Proceso Finalizado';
        
        RETURN vCodigoRetorno, vMensajeRespuesta, vIndicadorPorcentaje, vDescripcionPorcentaje;
    END

END PROCEDURE
DOCUMENT
'Armando García Ortiz',
'Monitoreo de Volumen de Informacion | Coordinación de Tarjetas',
'Modificacion...02 de agosto del 2021',
'#2',
'Modificacion...10 de enero del 2022',
'Se agrega el codigo de retorno, respuesta y el archivo de salida en cada ciclo para identificar un posible error de ejecucion',
'#3',
'Modificacion: 18 de enero del 2022',
'Se agrega set isolation y set lock en cada actualizacion de la tabla registrada en el catálogo. Cursor curTotalReg'
;

CREATE PROCEDURE "informix".sp_manntto_bitacoraspinoffline (pe_sysdate DATETIME YEAR TO FRACTION(5))
RETURNING CHAR (5) AS CODIGO_RETORNO, CHAR(300) AS MENSAJE_RETORNO;

    DEFINE SQL_ERR          INTEGER;
    DEFINE ISAM_ERR         INTEGER;
    DEFINE ERROR_INFO       CHAR(40);
    DEFINE CODIGO_RETORNO 	CHAR(5);
    DEFINE MENSAJE_RETORNO 	CHAR(150);
    DEFINE ANIO_MES		CHAR (06);
    DEFINE RUTA_ORIGEN	CHAR (80);
    DEFINE dtfechahoy	DATETIME YEAR TO FRACTION(5);
    DEFINE canio		CHAR (04);
    DEFINE cmes		CHAR (02);
    DEFINE cdia		CHAR (02);
    DEFINE cnombretabla1 	CHAR (50);
    DEFINE cnombretabla2 	CHAR (50);
    DEFINE vExecuteSQL 	CHAR (1500);
    DEFINE cbandera		CHAR (50);
    DEFINE cnombretablapivote1 	CHAR (20);
    DEFINE cnombretablapivote2 	CHAR (20);
    DEFINE crenombratabla1	CHAR (20);
	
    --	SET DEBUG FILE TO '/RESPALDOSNEW/sp_manntto_bitacoraspinoffline.out';
    --	TRACE ON; 
	
    let SQL_ERR = 0;
    let ISAM_ERR = 0;
    let ERROR_INFO = '';
    let CODIGO_RETORNO = '00000';
    let MENSAJE_RETORNO = 'sp_manntto_bitacoraspinoffline ejecutado exitosamente.';
    let dtfechahoy = pe_sysdate;
    let canio = substr (dtfechahoy, 1, 4);
    let cmes = substr (dtfechahoy, 6, 2);
    let cdia = substr (dtfechahoy, 9, 2); 
    let cnombretabla1 = '';
    let cnombretabla2 = '';
    let vExecuteSQL = '';
    let cbandera = '';
    let cnombretablapivote1 = '';
    let cnombretablapivote2 = '';
    let crenombratabla1 = '';
	
BEGIN        
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        SET DEBUG FILE TO '/RESPALDOSNEW/sp_manntto_bitacoraspinoffline.out';
        TRACE ON;
        LET CODIGO_RETORNO = SQL_ERR;
        LET MENSAJE_RETORNO = ISAM_ERR||ERROR_INFO;            
        RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
    END EXCEPTION;        

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
/*
    SELECT 
		fecha_hoy, YEAR (fecha_hoy), month (fecha_hoy), day (fecha_hoy) 
		into dtfechahoy, canio, cmes, cdia
	FROM bdinteg:"informix".si_fechas
	WHERE empresa = '001';
*/
	drop table if exists "informix".bitacorapinoffline_pivoterepo;
	drop table if exists "informix".bitpinoffline_pivoterepo;
		
--	TablaPivote1: bitacorapinoffline_pivoterepo:
	CREATE TABLE "informix".bitacorapinoffline_pivoterepo 
	( 
		numtarjeta       	CHAR(16) NOT NULL,
		fechageneracion  	DATETIME YEAR to FRACTION(5) NOT NULL,
		transaccionorigen	VARCHAR(4) NOT NULL,
		estatusscripting 	INTEGER,
		secuenciaorig    	VARCHAR(6),
		respuestatlv     	VARCHAR(255),
		tag_9f5b         	VARCHAR(11),
		idterminal       	VARCHAR(16),
		PRIMARY KEY(fechageneracion,numtarjeta,transaccionorigen)
	)
	fragment by round robin in 
	dbssc_sdodiarioc01, dbssc_sdodiarioc02, dbssc_sdodiarioc03
	extent size 2781964 next size 1024000
	LOCK MODE ROW;

	
--	TablaPivote2: bitpinoffline_pivoterepo:
	CREATE TABLE "informix".bitpinoffline_pivoterepo 
	( 
		numtarjeta        	CHAR(16) NOT NULL,
		tarjeta_edoinicial	CHAR(1) NOT NULL,
		tarjeta_edofinal  	CHAR(1) NOT NULL,
		sucursal          	CHAR(4) NOT NULL,
		ip_pc             	CHAR(15) NOT NULL,
		ejecutivo         	CHAR(8) NOT NULL,
		fechahora_insert  	DATETIME YEAR to FRACTION(5) NOT NULL,
		PRIMARY KEY(fechahora_insert,numtarjeta)
	)
	fragment by round robin in 
	dbssc_sdodiarioc01, dbssc_sdodiarioc02, dbssc_sdodiarioc03
	extent size 2781964 next size 1024000
	LOCK MODE ROW;


	--	Renombrado de tablas actuales a <_aniomes>:
		let cnombretabla1 = 'bitacorapinoffline_'||canio||cmes; 

		LET vExecuteSQL = '';
		LET vExecuteSQL = 'echo "RENAME TABLE bitacorapinoffline TO "'||cnombretabla1||'> renombratabla1.sql';
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = 'dbaccess intercard renombratabla1.sql';
		SYSTEM vExecuteSQL;

		let cnombretabla2 = 'bitpinoffline_'||canio||cmes; 
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'echo "RENAME TABLE bit_pinoffline TO "'||cnombretabla2||'> renombratabla2.sql';
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = 'dbaccess intercard renombratabla2.sql';
		SYSTEM vExecuteSQL;


	--	Renombrado de tablas pivote a limpias:
			--	LET cnombretablapivote1 = 'bitacorapinoffline';
			LET vExecuteSQL = '';
			LET vExecuteSQL = 'echo "RENAME TABLE bitacorapinoffline_pivoterepo TO bitacorapinoffline"> renombratablapivote1.sql';
			SYSTEM vExecuteSQL;

			LET vExecuteSQL = '';
			LET vExecuteSQL = 'dbaccess intercard renombratablapivote1.sql';
			SYSTEM vExecuteSQL;

			--	LET cnombretablapivote2 = 'bit_pinoffline';
			LET vExecuteSQL = '';
			LET vExecuteSQL = 'echo "RENAME TABLE bitpinoffline_pivoterepo TO bit_pinoffline"> renombratablapivote2.sql';
			SYSTEM vExecuteSQL;

			LET vExecuteSQL = '';
			LET vExecuteSQL = 'dbaccess intercard renombratablapivote2.sql';
			SYSTEM vExecuteSQL;		
			
			LET vExecuteSQL = '';
			LET vExecuteSQL ='rm -f renombratabla1.sql renombratabla2.sql renombratablapivote1.sql renombratablapivote2.sql';
			SYSTEM vExecuteSQL;		
	
	
    RETURN CODIGO_RETORNO, NVL(MENSAJE_RETORNO,'');

    END
END PROCEDURE
DOCUMENT
'AUTOR: FRG',
'Proyecto: RQI nn ccc Depuracion tablas <intercard:bitacorapinoffline> e <intercard:bit_pinoffline>',
'Fecha de creacion: 30.Enero.2021',
'Fecha de modificacion: N/A.',
'Invocacion: execute procedure "informix".sp_manntto_bitacoraspinoffline (current);', 
'Base de datos: intercard'
;

CREATE PROCEDURE "informix".sp_obtiene_cte_contacto_cap ( 
                                                           pNumEmpCoppel   CHAR(9), 
														   pCuenta         VARCHAR(4)
														)

RETURNING VARCHAR(5) AS CODIGO_RETORNO, VARCHAR (50) AS MENSAJE_RETORNO, CHAR(1) as VC_TIPOENVIO, VARCHAR(10) AS ALERTA, VARCHAR(15) AS ID_PLANTILLA, CHAR(20) AS NUMCTE;	
 
	--Definicion de variables
    DEFINE  codigo_retorno      CHAR(5);				
	DEFINE  mensaje_retorno     CHAR(50);
	
	DEFINE SQLERR		INTEGER;
	DEFINE ISAM_ERR		INTEGER;
	DEFINE ERROR_INFO	VARCHAR(80); 
    DEFINE RUTA_DESTINO VARCHAR(80);	
	
	DEFINE valerta1             varchar(10);
    DEFINE valerta2             varchar(10);
	DEFINE ALERTA                varchar(10);
    DEFINE vIdPlantilla1        varchar(15); 
    DEFINE vIdPlantilla2        varchar(15); 
	DEFINE ID_PLANTILLA         varchar(15); 
	DEFINE VC_TIPOENVIO          char(1); 
   
    DEFINE VC_NUMCTE 	        CHAR (20);
    DEFINE vstelefono	        INTEGER;
    DEFINE vscorreo			    INTEGER;
	DEFINE vCuentaComp VARCHAR(13);
	DEFINE vempleado CHAR(9);
	DEFINE vcuenta VARCHAR(13);
	DEFINE vcuentacorta Varchar(4);
	
	LET RUTA_DESTINO  = '/RESPALDOSNEW/';
    LET vstelefono         = 0;
    LET VC_NUMCTE           = '';
    LET vscorreo           = 0;
	LET codigo_retorno  = '00000';
	LET MENSAJE_RETORNO     = '';
	LET VC_TIPOENVIO = '';
	LET vCuentaComp = ''; 
	LET vempleado = '';
	LET vcuenta = '';
	LET vcuentacorta = '';
	
	--SET DEBUG FILE TO RUTA_DESTINO || "sp_obtiene_cte_contacto_cap.out";
    --TRACE ON;        	
	
BEGIN 
	
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_DESTINO || "sp_obtiene_cte_contacto_cap_e.out";
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN			  
			      DROP TABLE IF EXISTS "informix".ctas_nomina_emp_paso;			
                  LET CODIGO_RETORNO = SQLERR;
                  LET MENSAJE_RETORNO = ERROR_INFO;                
                 RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO,VC_TIPOENVIO,ALERTA,vIdPlantilla2,NVL(VC_NUMCTE,'0');
            END IF;
			
        END EXCEPTION;	

	    SET ISOLATION TO DIRTY READ; 
	    SET LOCK MODE TO WAIT 3;
------------------------------------------------------------------------------------------------------------------------
		 LET codigo_retorno  = '00000';
		 LET mensaje_retorno = 'PROCESO EXITOSO';
		 LET vIdPlantilla1 ='D_CAPP_EMAIL';    -- plantilla email   
		 LET valerta1      ='CMPC_BATCH';    -- alerta email 
		
		 LET vIdPlantilla2 ='D_CAPP_SMS';    -- plantilla sms     
         LET valerta2      ='CMPS_BATCH';    -- alerta sms 
		 
		LET ALERTA = '';
     	LET ID_PLANTILLA = '';

		--DROP TABLE IF EXISTS "informix".ctas_nomina_emp_paso;

	   --Creacion de tabla de paso   
	     CREATE TEMP TABLE ctas_nomina_emp_paso
         (
            num_empleado       CHAR(9),
            cuenta             VARCHAR(13),
            cuenta_corta      VARCHAR(4)
         ) WITH NO LOG LOCK MODE ROW;

		    CREATE INDEX "informix".idx_ctas_nomina_emp_paso_1 ON "informix".ctas_nomina_emp_paso(num_empleado) ;
 
		    foreach cur_F1_main WITH hold for
		
		         Select  num_empleado,cuenta INTO vempleado,vcuenta from intercard:ctas_nomina_empleado where num_empleado = pNumEmpCoppel	 
  
		          LET vcuentacorta = SUBSTR(vcuenta,LENGTH(vcuenta)-3,4);
 
			     INSERT INTO "informix".ctas_nomina_emp_paso  (num_empleado,cuenta,cuenta_corta)
		         VALUES  (vempleado,vcuenta,vcuentacorta );

		   end foreach; 
		----------
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".ctas_nomina_emp_paso;  
		----------
		Select limit 1 cuenta into vCuentaComp from ctas_nomina_emp_paso where num_empleado = pNumEmpCoppel and  cuenta_corta  = pCuenta;
		----------
		--Obtiene el num. de cte. 
		----------
		  SELECT limit 1 num_cte  INTO VC_NUMCTE
          FROM bdicheq:sc_maechq 
          WHERE  empresa = '001' 
          AND  cuenta = vCuentaComp; 
		  
		  IF VC_NUMCTE IS NULL THEN 

		                 DROP TABLE IF EXISTS "informix".ctas_nomina_emp_paso;
		  
		  					LET MENSAJE_RETORNO = 'EMP-CTA NO ENCONTRADO EN CATALOGO COPPEL';
							LET VC_TIPOENVIO = '0';
							LET ALERTA = '0';
							LET ID_PLANTILLA = '0';
		      RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO,VC_TIPOENVIO,ALERTA,ID_PLANTILLA,NVL(VC_NUMCTE,'0');
		  END IF;
		  
		----------
		  Select  COUNT(*) INTO  vscorreo
		  from   bdinteg:"informix".si_correos sic 
          Where  sic.tipo_correo = '1'
          and sic.status_correo = 'A'
          and numcte =  VC_NUMCTE; 
 
		  Select  COUNT(*) INTO vstelefono 
          from  bdinteg:"informix".si_telefonos_actual sit 
          where sit.status_tel = 'A' 
          AND sit.tipo_tel = '2'
          AND numcte = VC_NUMCTE ; 
 
            IF    (vscorreo = '0' and vstelefono = '0')   THEN 

							LET MENSAJE_RETORNO = 'CLIENTE SIN DATOS DE CONTACTO';
							LET VC_TIPOENVIO = '0';
							LET ALERTA = '0';
							LET ID_PLANTILLA = '0';
			    
			ELIF ( (vscorreo <> '0' AND vscorreo is not null) ) THEN 	
			       --email 
			            LET  VC_TIPOENVIO   = '1';
						LET  MENSAJE_RETORNO     = 'OK EMAIL';
				     	LET ALERTA = valerta1;
			         	LET ID_PLANTILLA = vIdPlantilla1;
 
            ELIF   ( (vstelefono <> '0' AND vstelefono is not null) ) THEN  
		
					-- sms 
					    LET  VC_TIPOENVIO   = '2';
						LET  MENSAJE_RETORNO     = 'OK SMS';
				     	LET ALERTA = valerta2;
			         	LET ID_PLANTILLA = vIdPlantilla2;
 
			END IF; 
 
           DROP TABLE IF EXISTS "informix".ctas_nomina_emp_paso;
------------------------------------------------------------------------------------------------------------------------

    RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO,VC_TIPOENVIO,ALERTA,ID_PLANTILLA,NVL(VC_NUMCTE,'0');


END;
END PROCEDURE;