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
DEFINE vsTransacC_ifrs CHAR(4); -- IFRS
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

CREATE PROCEDURE "informix".sp_reproceso_mensual_stock (pFecha DATE)
    RETURNING VARCHAR(5) AS CodRetorno, VARCHAR(60) AS DescRetorno;

    /*VARIABLES PARA RETORNO*/
    DEFINE CodRetorno               	 VARCHAR(5);
    DEFINE DescRetorno              	 VARCHAR(60);

    /*VARIABLES PARA CONTROL DE ERRORES*/
    DEFINE viSqlErr                 	 INTEGER;
    DEFINE viSamErr                      INTEGER;

    /*VARIABLES PARA EL CONTROL DE CONTADORES*/
    DEFINE  vsflagentransaccion     	 CHAR(1);

    /*VARIABLES PARA OPERACIÓN DE FECHAS*/
    DEFINE vfecha_hoy               	 DATE;
    DEFINE vultimo_dia_mes_ante_anterior DATE;
    DEFINE vprimer_dia_mes_ante_anterior DATE; 
    DEFINE vultimo_dia_mes_anterior      DATE;
    DEFINE vprimer_dia_mes_anterior      DATE;
    DEFINE vultimo_dia_mes_actual 		 DATE;
    DEFINE vprimer_dia_mes_actual	     DATE;

    DEFINE vultimo_dia_mes_ante_anterior_hora DATETIME YEAR TO FRACTION(5);
    DEFINE vprimer_dia_mes_ante_anterior_hora DATETIME YEAR TO FRACTION(5);
    DEFINE vultimo_dia_mes_anterior_hora      DATETIME YEAR TO FRACTION(5);
    DEFINE vprimer_dia_mes_anterior_hora      DATETIME YEAR TO FRACTION(5);
    DEFINE vultimo_dia_mes_hora_actual 	      DATETIME YEAR TO FRACTION(5);
    DEFINE vprimer_dia_mes_hora_actual 	      DATETIME YEAR TO FRACTION(5);
    DEFINE vPeriodoActual 			          VARCHAR(6);
    DEFINE vPeriodoAnterior			          VARCHAR(6);
    DEFINE vPeriodoAnteAnterior		          VARCHAR(6);
    DEFINE v_ultimo_Periodo			          VARCHAR(6);
    DEFINE vsql                               char(1150);

    /*VARIABLES PARA FUNCIONALIDAD DE QUERY */
    DEFINE  vsucursal               	INTEGER;
    DEFINE  vdiseno                		INTEGER;
    DEFINE  vtotal                  	INTEGER;
    define  vmaxnumregistros        	INTEGER;

	 /*   SET DEBUG FILE TO "/informix/yuliette/sp_reproceso_mensual_stock.out";
    TRACE ON;*/
	
    /*INICIALIZACION VARIABLES*/

    LET 	CodRetorno = '00000';
    LET 	DescRetorno = 'Ejecución de proceso exitosa.';
    LET     viSqlErr = 0;
    LET 	viSamErr = 0;
    LET 	vsflagentransaccion = 'F';
    LET  	vsucursal = 0;
    LET  	vdiseno    = 0;
    LET  	vtotal     = 0;
    LET     vmaxnumregistros=0;

    LET     vPeriodoActual = '';
    LET     vPeriodoAnterior = '';
    LET     vPeriodoAnteAnterior = '';
    LET     v_ultimo_Periodo = '';  

/*OBTENER FECHA PERIODO A REPROCESAR*/
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
let vfecha_hoy = pFecha;

    /*OBTENER EL ULTIMO DÍA DEL MES PREVIO AL ANTERIOR A LA EJECUCIÓN*/  
    LET vultimo_dia_mes_ante_anterior = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
    LET vultimo_dia_mes_ante_anterior_hora = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
    LET vultimo_dia_mes_ante_anterior_hora = SUBSTRING(vultimo_dia_mes_ante_anterior_hora FROM  1 FOR 10) || ' 23:59:59'; 
         
    /*OBTENER EL PRIMER DÍA DEL MES PREVIO AL ANTERIOR A LA EJECUCIÓN*/
    LET vprimer_dia_mes_ante_anterior = extend(extend(vfecha_hoy - 2 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY); 
    LET vprimer_dia_mes_ante_anterior_hora = extend(extend(vfecha_hoy - 2 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
    LET vprimer_dia_mes_ante_anterior_hora= SUBSTRING(vprimer_dia_mes_ante_anterior_hora FROM  1 FOR 10) || ' 00:00:00'; 

    /*OBTENER EL ULTIMO DÍA DEL MES ANTERIOR A LA EJECUCIÓN*/  
    LET vultimo_dia_mes_anterior = extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
    LET vultimo_dia_mes_anterior_hora = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
    LET vultimo_dia_mes_anterior_hora = SUBSTRING(vultimo_dia_mes_anterior_hora FROM  1 FOR 10) || ' 23:59:59'; 
         
    /*OBTENER EL PRIMER DÍA DEL MES ANTERIOR A LA EJECUCIÓN*/
    LET vprimer_dia_mes_anterior = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY); 
    LET vprimer_dia_mes_anterior_hora = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
    LET vprimer_dia_mes_anterior_hora= SUBSTRING(vprimer_dia_mes_anterior_hora FROM  1 FOR 10) || ' 00:00:00'; 

    /*OBTENER EL ULTIMO DÍA DEL MES ACTUAL*/ 
    LET vultimo_dia_mes_actual = extend(extend(vfecha_hoy + 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
    LET vultimo_dia_mes_hora_actual= extend(extend(vfecha_hoy + 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
    LET vultimo_dia_mes_hora_actual= SUBSTRING(vultimo_dia_mes_hora_actual FROM  1 FOR 10) || ' 23:59:59'; 

    /*OBTENER EL PRIMER DÍA DEL MES ACTUAL*/ 
    LET vprimer_dia_mes_actual = extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY; 
    LET vprimer_dia_mes_hora_actual= extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
    LET vprimer_dia_mes_hora_actual = SUBSTRING(vprimer_dia_mes_hora_actual FROM  1 FOR 10) || ' 00:00:00'; 

    --Periodo a ejecutar debe ser el periodo del mes anterior al mes actual
    LET vPeriodoActual       =  YEAR(vfecha_hoy)|| LPAD(MONTH(vfecha_hoy),2,0);
    LET vPeriodoAnterior     =  YEAR(vprimer_dia_mes_anterior)|| LPAD(MONTH(vprimer_dia_mes_anterior),2,0);
    LET vPeriodoAnteAnterior =  YEAR(vprimer_dia_mes_ante_anterior)|| LPAD(MONTH(vprimer_dia_mes_ante_anterior),2,0);

    
    
BEGIN

	ON EXCEPTION
		SET viSqlErr, viSamErr
        
        
        LET vsql = '';
        LET vsql = ' rm -f /RESPALDOS/suc_tipo_tarjeta.unl';
        SYSTEM vsql;
        
        LET vsql = '';
        LET vsql = ' rm -f /resplogifx/script_suc_tipo_tarjeta.sql';
        SYSTEM vsql;
        
        LET vsql = '';
        LET vsql = ' rm -f err_carga.log';
        SYSTEM vsql;
        
        LET vsql = '';
        LET vsql = ' rm -f reg_stock_vta.txt';
        SYSTEM vsql;
        
        
		LET CodRetorno = viSqlErr;
		LET DescRetorno = viSamErr;
		RETURN CodRetorno, DescRetorno;
	END EXCEPTION;
	
	
       /*Elimina el Periodo a Reprocesar*/		
        Delete "informix".rpt_stock_venta_tp
	where clave_tipotarjeta = '14' and
              periodo = vPeriodoAnterior;		
	
	
	
	
	
	--Ingresa los registros para las sucursales con existencias de los tipos de tarjetas 14 y 15
    LET vsql  = '';    
    LET vsql  = 'echo "UNLOAD TO /RESPALDOS/suc_tipo_tarjeta.unl ' ||
        " SELECT '"||vPeriodoAnterior||"', tpo.clave_tipotarjeta , suc.clave_sucursal, suc.nombre_sucursal, img.id_diseno, img.descripcion_diseno, 0, 0, 0, 0, 0, 0" ||
        ' FROM intercard:"informix".sucursal_tipotarjeta tpo, intercard:"informix".cat_imagenespredisenadas img, intercard:"informix".sucursal suc ' ||
        ' where tpo.clave_tipotarjeta  = "14" and ' ||
        ' tpo.clave_sucursal = suc.clave_sucursal and  ' ||
        ' (tpo.existencia > 0 or tpo.solicitadas > 0) and img.activa = "1" ' ||
        ' order by tpo.clave_sucursal, img.id_diseno; ' ||
        ' "> /resplogifx/script_suc_tipo_tarjeta.sql';
    SYSTEM vsql;
                
    LET vsql = '';
    LET vsql = ' dbaccess bditarjeta /resplogifx/script_suc_tipo_tarjeta.sql';
    SYSTEM vsql;
        
    LET vsql = '';
    LET vsql = "echo "||'"'|| "file '"||'/RESPALDOS/'||
                          'suc_tipo_tarjeta.unl' || "' delimiter '|' "|| '12'||
                          "; INSERT INTO rpt_stock_venta_tp" || ";"||'"'||' > reg_stock_vta.txt';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "dbload -d bditarjeta -c reg_stock_vta.txt -l err_carga.log -n 1000 -k";
    SYSTEM vsql;

    
    LET vsql = '';
    LET vsql = ' rm -f /RESPALDOS/suc_tipo_tarjeta.unl';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = ' rm -f /resplogifx/script_suc_tipo_tarjeta.sql';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = ' rm -f err_carga.log';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = ' rm -f reg_stock_vta.txt';
    SYSTEM vsql;
    
	-- *** PROCEDIMIENTO PARA LLENADO DE REPORTE DE TARJETAS TIPO 14 PERSONALIZAS STOCK ***
	--Descarga los Stock Nuevos de Tarjetas que se recibieron en sucursal durante el mes

    select (year(flt.fecha)|| LPAD(month(flt.fecha),2,0)) as periodo,        
         lte.clave_sucursal as sucursal, suc.nombre_sucursal as nombre_sucursal, 
         det.id_diseno as imagen, img.descripcion_diseno as descripcion, count(det.numtarjeta) as nuevo
    from intercard:"informix".lote lte, intercard:"informix".detalle_maquila det, intercard:"informix".sucursal suc, intercard:"informix".cat_imagenespredisenadas img,
         intercard:"informix".flujolote flt
    where lte.numerolote = det.numlote and
         lte.clave_sucursal = suc.clave_sucursal and
         img.id_diseno = det.id_diseno and
         flt.numerolote = lte.numerolote and
         flt.codflujo = 'RES' and 
         flt.fecha >= vprimer_dia_mes_anterior_hora and
         flt.fecha <= vultimo_dia_mes_anterior_hora and
         lte.clave_tipotarjeta = '14'       
    group by 1,2,3,4,5
	into temp tt_stock_nuevo with no log;
	
	---Creación de índices en periodo, sucursal e imagen.
    CREATE INDEX "informix".idx_tt_stock_nuevo_periodo
        ON "informix".tt_stock_nuevo(periodo) ONLINE;
    CREATE INDEX "informix".idx_tt_stock_nuevo_sucursal
        ON "informix".tt_stock_nuevo(sucursal) ONLINE;
    CREATE INDEX "informix".idx_tt_stock_nuevo_imagen
        ON "informix".tt_stock_nuevo(imagen) ONLINE;

	--Integración de Registros de Stock Nuevo a reporte rpt_stock_venta_tp
	update rpt_stock_venta_tp inv
    set inv.stock_nuevo  = (
        select stk.nuevo from tt_stock_nuevo stk
        where inv.periodo = stk.periodo and
              inv.clave_sucursal = stk.sucursal and
              inv.id_diseno = stk.imagen)
    where inv.periodo = (select stk.periodo from tt_stock_nuevo stk
                         where inv.periodo = stk.periodo and
                               inv.clave_sucursal = stk.sucursal and
                               inv.id_diseno = stk.imagen) and
          inv.clave_sucursal = (select stk.sucursal from tt_stock_nuevo stk
                         where inv.periodo = stk.periodo and
                               inv.clave_sucursal = stk.sucursal and
                               inv.id_diseno = stk.imagen) and
          inv.id_diseno = (select stk.imagen from tt_stock_nuevo stk
                         where inv.periodo = stk.periodo and
                               inv.clave_sucursal = stk.sucursal and
                               inv.id_diseno = stk.imagen) and
          inv.clave_tipotarjeta = '14' and
	      inv.periodo = vPeriodoAnterior;
	  
	 --Descarga de Asignaciones de Tarjetas 

    select  (year(tjt.fechaasignacion)|| LPAD(month(tjt.fechaasignacion),2,0)) as periodo, lte.clave_sucursal as sucursal, suc.nombre_sucursal as nombre_sucursal, 
       det.id_diseno as imagen, img.descripcion_diseno as descripcion, count(distinct(det.numtarjeta)) as asignacion
       from intercard:"informix".lote lte, intercard:"informix".detalle_maquila det, intercard:"informix".sucursal suc, intercard:"informix".cat_imagenespredisenadas img,
            intercard:"informix".tarjeta tjt, intercard:"informix".flujolote flt
      where lte.numerolote = det.numlote and
            tjt.numerolote = det.numlote and
            tjt.numerolote = lte.numerolote and
            flt.numerolote = lte.numerolote and
            lte.clave_sucursal = suc.clave_sucursal and
            tjt.numtarjeta = det.numtarjeta and
            img.id_diseno = det.id_diseno and
            lte.clave_tipotarjeta = '14' and            
            tjt.fechaasignacion  >= vprimer_dia_mes_anterior_hora and
            tjt.fechaasignacion  <= vultimo_dia_mes_anterior_hora
            group by 1,2,3,4,5
            order by 1,2,3,4,5
    INTO temp tt_asignacion with no log;
    
    ---Creación de índices en periodo, sucursal e imagen.
    CREATE INDEX "informix".idx_tt_asignacion_periodo
        ON "informix".tt_asignacion(periodo) ONLINE;
    CREATE INDEX "informix".idx_tt_asignacion_sucursal
        ON "informix".tt_asignacion(sucursal) ONLINE;
    CREATE INDEX "informix".idx_tt_asignacion_imagen
        ON "informix".tt_asignacion(imagen) ONLINE;
    
	--Integracion de Registros de Asignación de Tarjetas a Estructura rpt_stock_venta_tp
	update rpt_stock_venta_tp inv
    set inv.asignacion = (
    select asg.asignacion from tt_asignacion asg
    where inv.periodo = asg.periodo and
          inv.clave_sucursal = asg.sucursal and
          inv.id_diseno = asg.imagen)
                    where inv.periodo = (
                    select asg.periodo from tt_asignacion asg
                        where inv.periodo = asg.periodo and
                              inv.clave_sucursal = asg.sucursal and
                              inv.id_diseno = asg.imagen) and
          inv.clave_sucursal = (select asg.sucursal from tt_asignacion asg
                        where inv.periodo = asg.periodo and
                              inv.clave_sucursal = asg.sucursal and
                              inv.id_diseno = asg.imagen) and
          inv.id_diseno = (select asg.imagen from tt_asignacion asg
                        where inv.periodo = asg.periodo and
                              inv.clave_sucursal = asg.sucursal and
                              inv.id_diseno = asg.imagen) and
         inv.clave_tipotarjeta = '14' and
	     inv.periodo = vPeriodoAnterior;
		  
    --8) Descarga de Reposiciones de Tarjetas (que fueron sustitución)
	--Se busca primero las tarjetas que corresponden a reposiciones
	
    select (year(tjt.fechaasignacion)|| LPAD(month(tjt.fechaasignacion),2,0)) as periodo, lte.clave_sucursal as clave_sucursal, suc.nombre_sucursal as nombre_sucursal, 
       det.id_diseno as imagen, img.descripcion_diseno as descripcion, count(distinct(det.numtarjeta)) as reposicion
       from intercard:"informix".lote lte, intercard:"informix".detalle_maquila det, intercard:"informix".sucursal suc, intercard:"informix".cat_imagenespredisenadas img,
            intercard:"informix".tarjeta tjt, intercard:"informix".flujolote flt
       where lte.numerolote = det.numlote and
            tjt.numerolote = det.numlote and
            tjt.numerolote = lte.numerolote and
            flt.numerolote = lte.numerolote and
            lte.clave_sucursal = suc.clave_sucursal and            
            tjt.numtarjeta = det.numtarjeta and
            img.id_diseno = det.id_diseno and
            lte.clave_tipotarjeta = '14' and
            tjt.numtarjeta in(	
								select tjt1.numtarjetasustituta
								from intercard:"informix".tarjeta tjt1
								where tjt1.numtarjetasustituta is not null and                    --*************************************************
								  tjt1.fechaasignacion  >= vprimer_dia_mes_anterior_hora and      --*************************************************
								  tjt1.fechaasignacion  <= vultimo_dia_mes_anterior_hora and
								  tjt1.numtarjetasustituta in(
								  select tjt.numtarjeta
										from intercard:"informix".lote lte, intercard:"informix".detalle_maquila det, intercard:"informix".sucursal suc, 
										     intercard:"informix".cat_imagenespredisenadas img,	intercard:"informix".tarjeta tjt, intercard:"informix".flujolote flt
										where lte.numerolote = det.numlote and
											tjt.numerolote = det.numlote and
											tjt.numerolote = lte.numerolote and
											flt.numerolote = lte.numerolote and
											lte.clave_sucursal = suc.clave_sucursal and            
											tjt.numtarjeta = det.numtarjeta and
											img.id_diseno = det.id_diseno and
											lte.clave_tipotarjeta = '14'))  
	group by 1,2,3,4,5
    order by 1,2,3,4,5
    into temp tt_reposicion with no log;

    
    CREATE INDEX "informix".idx_tt_reposicion_periodo
        ON "informix".tt_reposicion(periodo) ONLINE;
    CREATE INDEX "informix".idx_tt_reposicion_cve_sucursal
        ON "informix".tt_reposicion(clave_sucursal) ONLINE;    
    CREATE INDEX "informix".idx_tt_reposicion_imagen
        ON "informix".tt_reposicion(imagen) ONLINE;
        
	--Integración de Registros de Reposicion de Tarjetas a Estructura rpt_stock_venta_tp

    update rpt_stock_venta_tp inv
    set inv.reposicion = (
    select rep.reposicion from tt_reposicion rep
         where inv.periodo = rep.periodo and
               inv.clave_sucursal = rep.clave_sucursal and
               inv.id_diseno = rep.imagen)
    where inv.periodo = (
                    select rep.periodo from tt_reposicion rep
                        where inv.periodo = rep.periodo and
                              inv.clave_sucursal = rep.clave_sucursal and
                              inv.id_diseno = rep.imagen) and
                 inv.clave_sucursal = (select rep.clave_sucursal from tt_reposicion rep
                        where inv.periodo = rep.periodo and
                              inv.clave_sucursal = rep.clave_sucursal and
                              inv.id_diseno = rep.imagen) and
                 inv.id_diseno = (select rep.imagen from tt_reposicion rep
                        where inv.periodo = rep.periodo and
                              inv.clave_sucursal = rep.clave_sucursal and
                              inv.id_diseno = rep.imagen) and
                 inv.clave_tipotarjeta = '14' and
	             inv.periodo = vPeriodoAnterior;
			
    --Creamos una copia de rpt_stock_venta_tp para actualizacion de reposiciones / asignaciones para el tipo tarjeta y periodo requerido

    select * from rpt_stock_venta_tp
	         where periodo = vPeriodoAnterior and
			       clave_tipotarjeta = '14' and
				   periodo = vPeriodoAnterior
    into temp tt_reposicion_asignacion with no log;	

    
    CREATE INDEX "informix".idx_tt_reposicion_asig_cve_tipotarjeta
        ON "informix".tt_reposicion_asignacion(clave_tipotarjeta) ONLINE;
    CREATE INDEX "informix".idx_tt_reposicion_asig_cve_sucursal
        ON "informix".tt_reposicion_asignacion(clave_sucursal) ONLINE;    
    CREATE INDEX "informix".idx_tt_reposicion_asig_id_diseno
        ON "informix".tt_reposicion_asignacion(id_diseno) ONLINE;
    
	--Ajuste de Registros de Reposicion  = Asignacion = Asignacion - Reposicion

    update rpt_stock_venta_tp inv
    set inv.asignacion = 
                (select rep.asignacion - rep.reposicion  from tt_reposicion_asignacion rep
                 where inv.periodo = rep.periodo and
                       inv.clave_sucursal = rep.clave_sucursal and
                       inv.id_diseno = rep.id_diseno and
                       inv.clave_tipotarjeta = rep.clave_tipotarjeta and
                       inv.clave_tipotarjeta = '14')    
    where inv.periodo = (select rep.periodo from tt_reposicion_asignacion rep
                         where inv.periodo = rep.periodo and
                               inv.clave_sucursal = rep.clave_sucursal and
                               inv.id_diseno = rep.id_diseno and
                               rep.clave_tipotarjeta = '14' ) and
          inv.clave_sucursal = (select rep.clave_sucursal from tt_reposicion_asignacion rep
                         where inv.periodo = rep.periodo and
                               inv.clave_sucursal = rep.clave_sucursal and
                               inv.id_diseno = rep.id_diseno and
                               rep.clave_tipotarjeta = '14') and
          inv.id_diseno = (select rep.id_diseno from tt_reposicion_asignacion rep
                         where inv.periodo = rep.periodo and
                               inv.clave_sucursal = rep.clave_sucursal and
                               inv.id_diseno = rep.id_diseno and
                               rep.clave_tipotarjeta = '14') and
          inv.clave_tipotarjeta = '14' and
		  inv.periodo = vPeriodoAnterior;

   --Ajuste de Registros de Venta  = Asignacion + Reposicion

    update rpt_stock_venta_tp inv
    set inv.venta = inv.asignacion + inv.reposicion
    where  inv.clave_tipotarjeta = '14' and
	       inv.periodo = vPeriodoAnterior;
		   
    --Se actualiza el inventario inicial del periodo en ejecución VPeriodoAnterior
	select * from rpt_stock_venta_tp
	where periodo = vPeriodoAnteAnterior and
	      clave_tipotarjeta = '14'
    into temp tt_inventario_personalizadas2 with no log;

    update rpt_stock_venta_tp inv
    set inv.stock_inicio = (
    select fin.stock_final from tt_inventario_personalizadas2 fin
           where fin.periodo = vPeriodoAnteAnterior and  --Periodo Anterior        
                 fin.clave_tipotarjeta = '14' and
                 inv.clave_sucursal = fin.clave_sucursal and
	             inv.id_diseno = fin.id_diseno)
    where inv.clave_tipotarjeta = '14' and
          inv.periodo = vPeriodoAnterior and 
          inv.clave_sucursal = (select fin.clave_sucursal from tt_inventario_personalizadas2 fin
                        where fin.periodo = vPeriodoAnteAnterior and --Periodo Anterior
                              inv.clave_sucursal = fin.clave_sucursal and
                              inv.id_diseno = fin.id_diseno and
                              fin.clave_tipotarjeta = '14') and
          inv.id_diseno = (select fin.id_diseno from tt_inventario_personalizadas2 fin
                        where fin.periodo = vPeriodoAnteAnterior and  --Periodo Anterior   ***********************************************
                              inv.clave_sucursal = fin.clave_sucursal and
                              inv.id_diseno = fin.id_diseno and
                              fin.clave_tipotarjeta = '14');
      
    update rpt_stock_venta_tp inv
    set inv.stock_final = inv.stock_inicio + inv.stock_nuevo - inv.venta
    where inv.periodo = vPeriodoAnterior and inv.clave_tipotarjeta = '14'; --Periodo en Ejecución vPeriodoAnterior

    UPDATE STATISTICS MEDIUM FOR TABLE "informix".rpt_stock_venta_tp;  
	 				
		let vsql = ''; 	   
		let vsql = 'echo "Periodo|TipoTarjeta|Sucursal|Nombre de Sucursal|Imagen|Nombre de la Imagen|Stock Inicio|Stock Nuevo|Venta|Asignacion|Reposicion|Stock Final">/RESPALDOS/REPstockimagen_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.unl';
		system vsql;
		let vsql = '';
		let vsql = '';
	    let vsql=  'echo "UNLOAD TO /RESPALDOS/REPstockimagen.unl select * from rpt_stock_venta_tp where clave_tipotarjeta = 14 and periodo = ' 
			|| vPeriodoAnterior || ';">/RESPALDOS/REPstockimagen.sql'; 
		system vsql;
		let vsql ='';
		let vsql= 'chmod 777 /RESPALDOS/REPstockimagen.sql';
		system vsql;
		let vsql ='';
		let vsql= 'dbaccess bditarjeta /RESPALDOS/REPstockimagen.sql';
		system vsql;
		let vsql = '';
		let vsql ='rm /RESPALDOS/REPstockimagen.sql';
		system vsql;
		let vsql ='';
		let vsql = "sed 's/|$//g' /RESPALDOS/REPstockimagen.unl >>/RESPALDOS/REPstockimagen_"|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".unl";
		system vsql;
		let vsql ='rm /RESPALDOS/REPstockimagen.unl';
		system vsql;		
									 	
		RETURN CodRetorno, DescRetorno;
END;

END PROCEDURE
--****************************************************************************************************
--DESCRIPCION: REPORTES MENSUALES STOCK TARJETAS PERSONALIZADAS:
--AUTOR : LUIS ANTONIO GOMEZ SANTIAGO / YULIETTE PEREZ LOPEZ
--FECHA : 14/06/2018
--BD: BDITARJETA
--****************************************************************************************************
;

CREATE PROCEDURE "informix".sp_reportes_mensuales_tp_pbajj()
RETURNING VARCHAR(5) AS CodRetorno, VARCHAR(60) AS DescRetorno;

--****************************************************************************************************
--DESCRIPCION: REPORTES MENSUALES TARJETAS PERSONALIZADAS:
--AUTOR : LUIS ANTONIO GOMEZ SANTIAGO
--MODIFICADO POR: KITZIA MIRLETH IRIBE CASTAÑEDA
--FECHA : 19/06/2018
--FECHA MODIFICACION: 06/08/2019
--BD: BDITARJETA
--****************************************************************************************************


/*VARIABLES PARA RETORNO*/
DEFINE CodRetorno               	 VARCHAR(5);
DEFINE DescRetorno              	 VARCHAR(60);

/*VARIABLES PARA CONTROL DE ERRORES*/
DEFINE viSqlErr                 	 INTEGER;
DEFINE viSamErr                      INTEGER;

/*VARIABLES PARA EL CONTROL DE CONTADORES*/
DEFINE  vsflagentransaccion     	 CHAR(1);
DEFINE 	vicontadorregistros 		 INTEGER;
DEFINE  vicontadorregistros2 		 INTEGER;

/*VARIABLES PARA OPERACIÃ?N DE FECHAS*/
DEFINE vfecha_hoy               	 DATE;
DEFINE vultimo_dia_mes_ante_anterior DATE;
DEFINE vprimer_dia_mes_ante_anterior DATE; 
DEFINE vultimo_dia_mes_anterior      DATE;
DEFINE vprimer_dia_mes_anterior      DATE;
DEFINE vultimo_dia_mes_actual 		 DATE;
DEFINE vprimer_dia_mes_actual	     DATE;

DEFINE vultimo_dia_mes_ante_anterior_hora DATETIME YEAR TO FRACTION(5);
DEFINE vprimer_dia_mes_ante_anterior_hora DATETIME YEAR TO FRACTION(5);
DEFINE vultimo_dia_mes_anterior_hora      DATETIME YEAR TO FRACTION(5);
DEFINE vprimer_dia_mes_anterior_hora      DATETIME YEAR TO FRACTION(5);
DEFINE vultimo_dia_mes_hora_actual 	      DATETIME YEAR TO FRACTION(5);
DEFINE vprimer_dia_mes_hora_actual 	      DATETIME YEAR TO FRACTION(5);
DEFINE vPeriodoActual 			          VARCHAR(6);
DEFINE vPeriodoAnterior			          VARCHAR(6);
DEFINE vPeriodoAnteAnterior		          VARCHAR(6);
DEFINE v_ultimo_Periodo			          VARCHAR(6);
DEFINE vsql                               char(1150);

DEFINE v_clave_sucursal   varchar(5);			
DEFINE v_nombre_sucursal  varchar(50);
DEFINE v_subbin       	  char(2);
DEFINE v_descripcion      varchar(28);
DEFINE v_no_tarjetas      integer;
DEFINE v_no_txns          integer;
DEFINE v_impote_total     decimal(19,4);
DEFINE v_txns_promedio    decimal(19,4);
DEFINE v_importe_promedio decimal(19,4);

/*
SET DEBUG FILE TO "/resplogifx/sp_reportes_mensuales_tp.out";
TRACE ON;
*/

/*INICIALIZACION VARIABLES*/

LET 	CodRetorno = '00000';
LET 	DescRetorno = 'Ejecucion de proceso exitoso.';
LET     viSqlErr = 0;
LET 	viSamErr = 0;
LET 	vsflagentransaccion = 'F';
LET		vicontadorregistros = 0;
LET     vicontadorregistros2 = 0;	

LET v_clave_sucursal   = '';
LET v_nombre_sucursal  = '';
LET v_subbin       	   = '';
LET v_descripcion      = '';
LET v_no_tarjetas      = 0;
LET v_no_txns          = 0;
LET v_impote_total     = 0.0;
LET v_txns_promedio    = 0.0;
LET v_importe_promedio = 0.0;

LET     vPeriodoActual = '';
LET     vPeriodoAnterior = '';
LET     vPeriodoAnteAnterior = '';
LET     v_ultimo_Periodo = '';  

/*OBTENER FECHA ACTUAL*/

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT fecha_hoy INTO vfecha_hoy FROM  bdinteg:si_fechas WHERE empresa='001';	

/*OBTENER EL ULTIMO DÃA DEL MES PREVIO AL ANTERIOR A LA EJECUCIÃ?N*/  
LET vultimo_dia_mes_ante_anterior = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
LET vultimo_dia_mes_ante_anterior_hora = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
LET vultimo_dia_mes_ante_anterior_hora = SUBSTRING(vultimo_dia_mes_ante_anterior_hora FROM  1 FOR 10) || ' 23:59:59'; 
	 
/*OBTENER EL PRIMER DÃA DEL MES PREVIO AL ANTERIOR A LA EJECUCIÃ?N*/
LET vprimer_dia_mes_ante_anterior = extend(extend(vfecha_hoy - 2 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY); 
LET vprimer_dia_mes_ante_anterior_hora = extend(extend(vfecha_hoy - 2 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
LET vprimer_dia_mes_ante_anterior_hora= SUBSTRING(vprimer_dia_mes_ante_anterior_hora FROM  1 FOR 10) || ' 00:00:00'; 

/*OBTENER EL ULTIMO DÃA DEL MES ANTERIOR A LA EJECUCIÃ?N*/  
LET vultimo_dia_mes_anterior = extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
LET vultimo_dia_mes_anterior_hora = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
LET vultimo_dia_mes_anterior_hora = SUBSTRING(vultimo_dia_mes_anterior_hora FROM  1 FOR 10) || ' 23:59:59'; 
	 
/*OBTENER EL PRIMER DÃA DEL MES ANTERIOR A LA EJECUCIÃ?N*/
LET vprimer_dia_mes_anterior = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY); 
LET vprimer_dia_mes_anterior_hora = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
LET vprimer_dia_mes_anterior_hora= SUBSTRING(vprimer_dia_mes_anterior_hora FROM  1 FOR 10) || ' 00:00:00'; 

/*OBTENER EL ULTIMO DÃA DEL MES ACTUAL*/ 
LET vultimo_dia_mes_actual = extend(extend(vfecha_hoy + 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
LET vultimo_dia_mes_hora_actual= extend(extend(vfecha_hoy + 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
LET vultimo_dia_mes_hora_actual= SUBSTRING(vultimo_dia_mes_hora_actual FROM  1 FOR 10) || ' 23:59:59'; 

/*OBTENER EL PRIMER DÃA DEL MES ACTUAL*/ 
LET vprimer_dia_mes_actual = extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY; 
LET vprimer_dia_mes_hora_actual= extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
LET vprimer_dia_mes_hora_actual = SUBSTRING(vprimer_dia_mes_hora_actual FROM  1 FOR 10) || ' 00:00:00'; 

--Periodo a ejecutar debe ser el periodo del mes anterior al mes actual
LET vPeriodoActual       =  YEAR(vfecha_hoy)|| LPAD(MONTH(vfecha_hoy),2,0);
LET vPeriodoAnterior     =  YEAR(vprimer_dia_mes_anterior)|| LPAD(MONTH(vprimer_dia_mes_anterior),2,0);
LET vPeriodoAnteAnterior =  YEAR(vprimer_dia_mes_ante_anterior)|| LPAD(MONTH(vprimer_dia_mes_ante_anterior),2,0);

BEGIN

	ON EXCEPTION
		SET viSqlErr, viSamErr
		LET CodRetorno = viSqlErr;
		LET DescRetorno = viSamErr;
		RETURN CodRetorno, DescRetorno;
	END EXCEPTION;	

	--Reporte Stock tipo '14'  
	LET v_ultimo_Periodo = '';
	select max(periodo)
	into v_ultimo_Periodo
	from "informix".rpt_stock_venta_tp
	where clave_tipotarjeta = '14';	
	
	IF (vPeriodoAnterior = v_ultimo_Periodo) THEN -- El proceso ya se ejecutÃ³ para el periodo del mes Anterior
		LET CodRetorno = '00002';
		LET DescRetorno = 'El Reporte Tarjetas Stock ya se ejecuto para el periodo ' || vPeriodoAnterior;		
    ELSE
        EXECUTE PROCEDURE bditarjeta:"informix".sp_reporte_mensual_stock() INTO CodRetorno, DescRetorno;		
	END IF;
	
	INSERT INTO "informix".td_bitacora_procesos(idproceso, fechahora, no_error, descripcion)
   	VALUES ('02', current, CodRetorno, DescRetorno);

	--Reporte Stock tipo '15'  
	LET v_ultimo_Periodo = '';
	select max(periodo)
	into v_ultimo_Periodo
	from "informix".rpt_stock_venta_tp
	where clave_tipotarjeta = '15';		
		
	IF (vPeriodoAnterior = v_ultimo_Periodo) THEN -- El proceso ya se ejecutÃ³ para el periodo del mes Anterior
		LET CodRetorno = '00003';
		LET DescRetorno = 'El Reporte Tarjetas Personalizadas ya se ejecuto para el periodo ' || vPeriodoAnterior;		
    ELSE
        EXECUTE PROCEDURE bditarjeta:"informix".sp_reporte_mensual_personalizadas() INTO CodRetorno, DescRetorno;	 
	END IF;
	
	INSERT INTO "informix".td_bitacora_procesos(idproceso, fechahora, no_error, descripcion)
   	VALUES ('03', current, CodRetorno, DescRetorno);	
	
	--Reporte PenetraciÃ³n Mercado 
	LET v_ultimo_Periodo = '';
	select max(periodo)
	into v_ultimo_Periodo
	from "informix".rpt_penetracion_mercado_tp;
		
	IF (vPeriodoAnterior = v_ultimo_Periodo) THEN -- El proceso ya se ejecutÃ³ para el periodo del mes Anterior
		LET CodRetorno = '00004';
		LET DescRetorno = 'El Reporte PenetraciÃ³n Mercado ya se ejecuto para el periodo ' || vPeriodoAnterior;		
    ELSE
        EXECUTE PROCEDURE bditarjeta:"informix".sp_penetracion_mercado() INTO CodRetorno, DescRetorno;	 
	END IF;
	
	INSERT INTO "informix".td_bitacora_procesos(idproceso, fechahora, no_error, descripcion)
   	VALUES ('04', current, CodRetorno, DescRetorno);	
	
	--Reporte Frecuencia de Uso 
	LET v_ultimo_Periodo = '';
	select max(periodo)
	into v_ultimo_Periodo
	from "informix".rpt_frecuencia_uso_tp;
		
	IF (vPeriodoAnterior = v_ultimo_Periodo) THEN -- El proceso ya se ejecutÃ³ para el periodo del mes Anterior
		LET CodRetorno = '00005';
		LET DescRetorno = 'El Reporte Frecuencia de Uso ya se ejecuto para el periodo ' || vPeriodoAnterior;		
    ELSE
        EXECUTE PROCEDURE bditarjeta:"informix".sp_frecuencia_uso() INTO CodRetorno, DescRetorno; 
	END IF;		

	INSERT INTO "informix".td_bitacora_procesos(idproceso, fechahora, no_error, descripcion)
   	VALUES ('05', current, CodRetorno, DescRetorno);		
			
	RETURN CodRetorno, DescRetorno;
END;
END PROCEDURE;