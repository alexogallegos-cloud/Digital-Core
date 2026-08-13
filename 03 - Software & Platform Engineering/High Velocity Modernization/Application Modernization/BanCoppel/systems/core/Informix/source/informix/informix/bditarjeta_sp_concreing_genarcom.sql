CREATE PROCEDURE "informix".sp_concreing_genarcom(
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
	
	SET LOCK MODE TO WAIT 3 ;
	SET ISOLATION TO DIRTY READ ;
	
	-- Recuperar comisiones e IVA de Nuevas transacciones de corresponsales
	/*set isolation to dirty read; */select valor into vmComConsultaDebito 	          from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='311';
	/*set isolation to dirty read; */select valor into vmComConsultaCredito           from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='312';
	/*set isolation to dirty read; */select valor into vmComRetiroDebito              from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='313';
	/*set isolation to dirty read; */select valor into vmComRetiroCredito             from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='314';
	/*set isolation to dirty read; */select valor into vmComTransferencia             from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='315';
	/*set isolation to dirty read; */select valor into vmComPagCreditoBCPLEfectiva    from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='316';
	/*set isolation to dirty read; */select valor into vmComPagCreditoOtroEfectiva    from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='317';
	/*set isolation to dirty read; */select valor into vmComPagCreditoOtroEfectivo    from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='318';
	/*set isolation to dirty read; */select valor into vmIVAComConsultaDebito         from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='331';
	/*set isolation to dirty read; */select valor into vmIVAComConsultaCredito        from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='332';
	/*set isolation to dirty read; */select valor into vmIVAComRetiroDebito           from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='333';
	/*set isolation to dirty read; */select valor into vmIVAComRetiroCredito          from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='334';
	/*set isolation to dirty read; */select valor into vmIVAComTransferencia 		  from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='335';
	/*set isolation to dirty read; */select valor into vmIVAComPagCreditoBCPLEfectiva from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='336';
	/*set isolation to dirty read; */select valor into vmIVAComPagCreditoOtroEfectiva from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='337';
	/*set isolation to dirty read; */select valor into vmIVAComPagCreditoOtroEfectivo from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='338';
	-- Recuperar comisiones e IVA de Nuevas transacciones de transferencias
	/*set isolation to dirty read; */select valor into vmComTransPrestamo    from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='305';
	/*set isolation to dirty read; */select valor into vmComTransGtosFun     from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='319';
	/*set isolation to dirty read; */select valor into vmComTransFiniEmp     from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='320';
	/*set isolation to dirty read; */select valor into vmComTransFondoAho    from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='321';
	/*set isolation to dirty read; */select valor into vmComTransReparUti    from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='322';
	/*set isolation to dirty read; */select valor into vmComTransPagoSegV    from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='323';
	/*set isolation to dirty read; */select valor into vmIVAComTransPrestamo from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='310';
	/*set isolation to dirty read; */select valor into vmIVAComTransGtosFun  from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='339';
	/*set isolation to dirty read; */select valor into vmIVAComTransFiniEmp  from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='340';
	/*set isolation to dirty read; */select valor into vmIVAComTransFondoAho from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='341';
	/*set isolation to dirty read; */select valor into vmIVAComTransReparUti from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='342';
	/*set isolation to dirty read; */select valor into vmIVAComTransPagoSegV from bditarjeta:"informix".td_param_conciliacion_concreing where codigo ='343';
	
		IF (psArchivoOrigenCred = 'TCC' OR psArchivoOrigenDeb = 'TCD'  ) THEN --CONADMIN

		 	--IF (psArchivoOrigenCred = 'TCC') THEN
			LET vdtFecha = SUBSTRING(psNomArchivoCred FROM 11 FOR 2) || '/' || SUBSTRING(psNomArchivoCred FROM 9 FOR 2) || '/' || SUBSTRING(psNomArchivoCred FROM 13 FOR 4);
			--ELIF (psArchivoOrigenDeb = 'TCD') THEN
				--LET vdtFecha = SUBSTRING(psNomArchivoDeb FROM 11 FOR 2) || '/' || SUBSTRING(psNomArchivoDeb FROM 9 FOR 2) || '/' || SUBSTRING(psNomArchivoDeb FROM 13 FOR 4);
			--END IF;

			-- SET LOCK MODE TO WAIT 3 ;
			-- SET ISOLATION TO DIRTY READ ;
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
			
			-- SET LOCK MODE TO WAIT 3 ;
			-- SET ISOLATION TO DIRTY READ ;
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

					-- SET ISOLATION TO DIRTY READ ;
					-- SET LOCK MODE TO WAIT 3;
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
						-- SET ISOLATION TO DIRTY READ ;
						-- SET LOCK MODE TO WAIT 3;
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
				
				-- SET LOCK MODE TO WAIT 3 ;
				-- SET ISOLATION TO DIRTY READ ;
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

							LET vsIdTerminal = SUBSTRING(vsFolioSIF FROM 1 FOR 4);

							-- SET ISOLATION TO DIRTY READ ;
							-- SET LOCK MODE TO WAIT 3;
							--OBTIENE EL PRODUCTO DE LA TARJETA
							SELECT FIRST 1 Prodtarjeta INTO vsProdTarjeta
								FROM Bdicred:"informix".Sd_Tarjeta
							WHERE 	Empresa = '001'
									AND Num_Tarjeta = TRIM(vsTarjeta);


							-- SET ISOLATION TO DIRTY READ ;
							-- SET LOCK MODE TO WAIT 3;
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

		-- SET LOCK MODE TO WAIT 3 ;
		-- SET ISOLATION TO DIRTY READ ;
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

		-- SET ISOLATION TO DIRTY READ ;
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
			-- SET LOCK MODE TO WAIT 3 ;
			-- SET ISOLATION TO DIRTY READ ;
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
		
			-- SET LOCK MODE TO WAIT 3 ;
			-- SET ISOLATION TO DIRTY READ ;
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
			-- SET LOCK MODE TO WAIT 3 ;
			-- SET ISOLATION TO DIRTY READ ;
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
				
				-- SET LOCK MODE TO WAIT 3 ;
				-- SET ISOLATION TO DIRTY READ ;
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
			-- SET LOCK MODE TO WAIT 3 ;
			-- SET ISOLATION TO DIRTY READ ;
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
'BD: BdiTarjeta',
'',
'MODIFICACION: L.I.A. Ricardo ResÃ©ndiz MartÃ­nez',
'Proyecto: Nuevas transacciones de transferencias ',
'Solicito: Jose Luis Puebla Salina ',
'Descripcion: Se modifica el proceso para contemplar nuevas transacciones de transferencias',
'Fecha: 2016/10/25',
'Version: 20161025.1900',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_cnc_stat06
(
	psCve_Usuario VARCHAR(10), 
	piHorario INTEGER
)

    RETURNING VARCHAR (5) AS CodRet, VARCHAR (150) AS Mensaje_Respuesta ;
    
    /*  DEFINICION DE VARIABLES */
	
    --CONTROL GENERAL
    DEFINE viSQLerr 						INTEGER;
    DEFINE vsCodRet 						VARCHAR(5);
    DEFINE vsCodRet2 						VARCHAR(5);
    DEFINE vsMensaje_Respuesta 				VARCHAR (250);
    DEFINE viElemento 						INTEGER;
    DEFINE viActualizacion 					INTEGER;
    DEFINE dtFecha_Hoy_Integral 			DATE;
    DEFINE vsBinCredito 					VARCHAR(6);
    DEFINE vsBinDebito 						VARCHAR(6);
    DEFINE viContadorErroresCon 			INTEGER;
    DEFINE viContadorErrores_Pase_Credito 	INTEGER;
    DEFINE viContadorErrores_Pase_Debito 	INTEGER;
    DEFINE vmComisionDeb 					DECIMAL(16,6);
    DEFINE vmComisionCred 					DECIMAL(16,6);
    DEFINE vmIVAComisionDeb 				DECIMAL(16,6);
    DEFINE vmIVAComisionCred 				DECIMAL(16,6);
    DEFINE vsFlag_Error_Reg 				VARCHAR(1);
	DEFINE vdDiaHora						DATETIME YEAR TO FRACTION(5);
	DEFINE vdFechaDeHoy						DATE;
	
    --DATOS MOVIMIENTOS_CONCILIACION
	DEFINE vsConadmin 						VARCHAR (3);
    DEFINE vsNombreArchivo 					VARCHAR (23);
    DEFINE vsArchivo_Origen 				VARCHAR (3);
    DEFINE vsArchivoOriIST 					VARCHAR (3);
    DEFINE vdtFecha_Archivo 				DATE;
    DEFINE vsCarga 							VARCHAR (3);
    DEFINE vsPrefijo_Archivo 				VARCHAR (15);
    DEFINE vsSistema 						VARCHAR (1);
    DEFINE vsConciliacion_Inter 			VARCHAR(1);
	
    --DEFINE vsConciliacion_SIF VARCHAR(1);
    DEFINE vsConciliacion_Admin 			VARCHAR(1);
    DEFINE viBorra_Archivo_Fisico 			INTEGER;
    DEFINE vsTransaccion_Compra 			VARCHAR (4);
    DEFINE vsTransaccion_Liberacion 		VARCHAR (4);
    DEFINE vsTransaccion_Forzada 			VARCHAR (4);
    DEFINE vsTransaccion_Abono 				VARCHAR (4);
    DEFINE vsTransaccionMoneyGram 			VARCHAR (4);
    DEFINE vsTransaccionCashBack 			VARCHAR (16); 
    DEFINE vsRep_Aix 						VARCHAR (50);
    DEFINE vsRep_Win 						VARCHAR (50);
    DEFINE vsArchivo_Companero 				VARCHAR(3);
    DEFINE vsArchivo_Report_Comisiones 		VARCHAR(3);
    DEFINE viTipo_LayOut 					INTEGER;
    DEFINE vsRuta_Archivo_Comisiones 		VARCHAR(50);
	
    --DATOS CONADMIN
    DEFINE vsNombreArchivo_Comi 			VARCHAR(23);
    DEFINE vsNombreArchivoCompanero 		VARCHAR(23);
	
    --DATOS ARCHIVO_CONCILIACION
    DEFINE viTot_Registros 					INTEGER;
    DEFINE vmTot_Monto 						MONEY;
    DEFINE viNum_Cargo 						INTEGER;
    DEFINE vmMonto_Cargo 					MONEY;
    DEFINE viNum_Abono 						INTEGER;
    DEFINE vmMonto_Abono 					MONEY;
	
    --CONTROL CICLOS
    DEFINE vsFlag_Ciclo_BusrcarArch 		VARCHAR (1);
    DEFINE vsFlag_ArchPendiente 			VARCHAR(1);
    DEFINE vsFlag_Ciclo_BusrcarReg 			VARCHAR (1);
	
    --DATOS MOVIMIENTOS_CONCILIACION
    DEFINE viConsecutivo 					INTEGER;
    DEFINE vsNumTarjeta 					VARCHAR (16);
    DEFINE vsTipoTransaccion325 			VARCHAR (15);
    DEFINE vsMonto325 						VARCHAR (13);
    DEFINE vsMontoCashBack325 				VARCHAR (13);
    DEFINE vsCuenta 						varchar(20); 
    define vsestransfer 					varchar(1);
    DEFINE vsFechaopetransfer 				char(6);
    DEFINE vsIdcomercio325 					VARCHAR (15);
    DEFINE vsNomcomercio325 				VARCHAR (30);
    DEFINE vsReferencia23_325 				VARCHAR (23);
    DEFINE vsSecuencia325 					VARCHAR (6);
    DEFINE vsDivisa325 						VARCHAR (3);
    DEFINE vsRfc325 						VARCHAR (15);
    DEFINE vsSecuencia 						VARCHAR(7);
    DEFINE vsSecuencia_Extendida 			VARCHAR(15);
    DEFINE vmMontoIntercard 				MONEY;
    DEFINE vmMontoCashBack 					MONEY;
    DEFINE vsFechaTransaccion 				DATETIME YEAR TO FRACTION (5);
    DEFINE vsInfReceptor 					VARCHAR(40);
    DEFINE vsIdTerminal 					VARCHAR(16);
    DEFINE vsMetodoCaptura 					VARCHAR(2);
    DEFINE vsMovConciliado 					VARCHAR(1);
    DEFINE vsMovReversado 					VARCHAR(1);
    DEFINE vsTipo_Mov 						VARCHAR(1);
    DEFINE vsFolio_Mov 						VARCHAR(16);
    DEFINE vdFechaConcilia 					DATETIME YEAR TO FRACTION (5);
    DEFINE viTipo_Conciliacion 				INTEGER;
    DEFINE vsDesc_Conciliacion 				VARCHAR(60);
    DEFINE vsConciliacion_Reg 				VARCHAR(1);
    DEFINE vsNumCuenta 						VARCHAR(20);
    DEFINE vsMonto_Divisa325 				VARCHAR(13);
    DEFINE vsISO323							CHAR(2);
    DEFINE vsMovRev325 						CHAR(1);
    DEFINE vsTipoMov 						VARCHAR(1);
    DEFINE vsAplicacion 					VARCHAR(1);
    DEFINE vsBandera_Proceso 				VARCHAR(1);
    DEFINE vsTransaccion_Aplica 			VARCHAR(4);
    DEFINE vsSistema_Registro 				VARCHAR(1);
    DEFINE vsFlagIntegridad 				VARCHAR(1);
    DEFINE vscodgironeg 					CHAR(4);    
    DEFINE vsb_aplica 						CHAR(1);    
    DEFINE vssecuencia_ext_archivo 			CHAR(15);    
	
    --CONTROL DE TRANSACCIONALIDAD
    DEFINE vsFlagEnTransaccion VARCHAR (1);
    DEFINE viContadorRegistros INTEGER;
    
	/*Coppel BOT*/
	DEFINE txn_CoppelBot VARCHAR(4);
	DEFINE vsNomArch_ComiBot VARCHAR(35);
	
    DEFINE vsConciliacionAdminAtm CHAR(1);
	
	/* VARIABLES DE FAST FUNDS*/
	DEFINE vsTxn_code				VARCHAR(1);
	DEFINE vsIndicador_fastfounds	VARCHAR(1);
	DEFINE vsRef_num_fastfounds		VARCHAR(1);
	
	/* VARIEBLES PARA MSI */
	DEFINE vspromoMSI				VARCHAR(02);
	DEFINE vsMSi					VARCHAR(02);
    
    /* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL
    LET viSQLerr = 0;    
    LET vsCodRet = '00000';
    LET vsCodRet2 = '00000';
    LET vsMensaje_Respuesta = '';
    LET viElemento = 0;
    LET viActualizacion = 0;
    LET dtFecha_Hoy_Integral = CURRENT::DATE;
    LET vsBinCredito = '';
    LET vsBinDebito = '';
    LET viContadorErroresCon = 0;
    LET viContadorErrores_Pase_Credito = 0;
    LET viContadorErrores_Pase_Debito = 0;
    LET vmComisionDeb = 0.0;
    LET vmComisionCred = 0.0;
    LET vmIVAComisionDeb = 0.0;
    LET vmIVAComisionCred = 0.0;
    LET vsFlag_Error_Reg = '';
	
    --DATOS ARCHIVO_ORIGEN
	LET vsConadmin = '';
    LET vsNombreArchivo = '';
    LET vsArchivo_Origen = '';
    LET vsArchivoOriIST = '';
    LET vdtFecha_Archivo = CURRENT::DATE;
	LET vdFechaDeHoy = CURRENT::DATE;
    LET vsCarga = '';
    LET vsPrefijo_Archivo = '';
    LET vsSistema = '';
    LET vsConciliacion_Inter = '';
	
    --LET vsConciliacion_SIF = '';
    LET vsConciliacion_Admin = '';
    LET viBorra_Archivo_Fisico = 0;
    LET vsTransaccion_Compra = '';
    LET vsTransaccion_Liberacion = '';
    LET vsTransaccion_Forzada = '';
    LET vsTransaccion_Abono = '';
    LET vsTransaccionMoneyGram = '';
    LET vsTransaccionCashBack = ''; -- Inicializacion de Variable de para transacciones Cash Back
    LET vsRep_Aix = '';
    LET vsRep_Win = '';
    LET vsArchivo_Companero = '';
    LET vsArchivo_Report_Comisiones = '';
    LET viTipo_LayOut = 0;
    LET vsRuta_Archivo_Comisiones = '';
	
    --DATOS CONADMIN
    LET vsNombreArchivo_Comi = '';
    LET vsNombreArchivoCompanero = '';
	
    --DATOS ARCHIVO_CONCILIACION
    LET viTot_Registros = 0;
    LET vmTot_Monto = 0.0;
    LET viNum_Cargo = 0;
    LET vmMonto_Cargo = 0.0;
    LET viNum_Abono = 0;
    LET vmMonto_Abono = 0.0;
	
    --CONTROL CICLOS
    LET vsFlag_Ciclo_BusrcarArch = 'V';
    LET vsFlag_ArchPendiente = 'F';
    LET vsFlag_Ciclo_BusrcarReg = 'V';
	
    --DATOS MOVIMIENTOS_CONCILIACION
    LET viConsecutivo = 0;
    LET vsNumTarjeta = '';
    LET vsTipoTransaccion325 = '';
    LET vsMonto325 = '';
    LET vsMontoCashBack325 = '';
    LET vscuenta = ''; -- Integracion Transfer
    LET vsestransfer = '';
    LET vsfechaopetransfer = '';
    LET vsIdcomercio325 = '';
    LET vsNomcomercio325 = '';
    LET vsReferencia23_325 = '';
    LET vsSecuencia325 = '';
    LET vsDivisa325 = '';
    LET vsRfc325 = '';
    LET vsSecuencia = '';
    LET vsSecuencia_Extendida = '';
    LET vmMontoIntercard = 0.0;
    LET vmMontoCashBack = 0.0;
    LET vsFechaTransaccion = CURRENT;
    LET vsInfReceptor = '';
    LET vsIdTerminal = '';
    LET vsMetodoCaptura = '';
    LET vsMovConciliado = '';
    LET vsMovReversado = '';
    LET vsTipo_Mov = '';
    LET vsFolio_Mov = '';
    LET vdFechaConcilia = CURRENT;
    LET viTipo_Conciliacion = 0;
    LET vsDesc_Conciliacion = '';
    LET vsNumCuenta = '';
    LET vsMonto_Divisa325 = '';
    LET vsISO323 = '';
    LET vsMovRev325 = '';
    LET vsConciliacion_Reg = '';
    LET vsTipoMov = '';
    LET vsAplicacion = '';
    LET vsBandera_Proceso = '';
    LET vsTransaccion_Aplica = '';
    LET vsSistema_Registro = '';
    LET vsFlagIntegridad = '';
    LET vscodgironeg = '';  -- TFORZADAS
    LET vsb_aplica = ''; --TFORZADAS
    LET vssecuencia_ext_archivo = ''; --TFORZADAS
    --CONTROL DE TRANSACCIONALIDAD
    LET vsFlagEnTransaccion = '';
    LET viContadorRegistros = 0;
	LET vdDiaHora = CURRENT;
    
    LET vsConciliacionAdminAtm = NULL;
	
	/*Coppel BOT*/
	LET txn_CoppelBot 	  = '';
	LET vsNomArch_ComiBot = '';
	
	/* VARIABLES DE FAST FUNDS*/
	LET vsTxn_code				= '';
	LET vsIndicador_fastfounds	= '';
	LET vsRef_num_fastfounds	= '';
	
	/* VARIEBLES PARA MSI */
	LET vsMSi = '';
	LET vspromoMSI = '';
 
	-- SET DEBUG FILE TO "/home/c90296115/sp_cnc_stat06.out";
	-- TRACE ON;
	 
	BEGIN
		ON EXCEPTION SET viSQLerr
			-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
			IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
			END IF;
			
			-- LIBERA LA BANDERA DE CONCILIACION EN EJECUCION
			UPDATE BdiTarjeta:"informix".td_param_conciliacion_atm_stat06 
			SET Valor = 'F', 
				Fecha_Modificacion = 
				(
					SELECT DBINFO('utc_to_datetime', Sh_Curtime)::DATETIME YEAR TO FRACTION(5) 
					FROM SysMaster:"informix".Sysshmvals
				)
			WHERE Codigo = '001' 
			AND Descripcion = 'CONCILIACION STAT06 EN  EJECUCION' 
			AND TRIM(Valor) = 'V';
			
			LET viElemento = 0;
			LET vsCodRet = '00020';
			LET vsMensaje_Respuesta = 'ERROR NO CONTROLADO (' || viSQLerr || '). ' || TRIM(vsMensaje_Respuesta);
			
			EXECUTE PROCEDURE BdiTarjeta:"informix".sp_cnc_guardabitacora_stat06 (viElemento, '(' || vsCodRet || ') ' || vsMensaje_Respuesta, psCve_usuario) INTO vsCodRet2;
			RETURN vsCodRet, vsMensaje_Respuesta;
			
		END EXCEPTION;
    
		-- EN CASO DE TRANSACCION ABIERTA Y TRATAR DE ABRIR OTRA
		ON EXCEPTION IN (-535)
			COMMIT WORK; -- TERMINA LA TRANSACCION ACTUAL Y CONTINUA
		END EXCEPTION WITH RESUME;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		-- OBTIENE LA FECHA HOY DEL SISTEMA CENTRAL INTEGRAL
		SELECT LIMIT 1 Fecha_Hoy 
		INTO dtFecha_Hoy_Integral 
		FROM bdinteg:"informix".Si_Fechas WHERE empresa = '001';
		
		IF (EXISTS (SELECT Descripcion FROM BdiTarjeta:"informix".td_param_conciliacion_atm_stat06 WHERE Codigo = '001' AND Descripcion = 'CONCILIACION STAT06 EN EJECUCION' AND TRIM(Valor) = 'V') ) THEN --VALIDA QUE NO EXISTA UNA CONCILIACION EN EJECUCION (CONCREING)
			
			LET vsCodRet = '00001'; --CONCILIACION EN EJECUCION --CONCREIN
			LET vsMensaje_Respuesta = 'CONCILIACION STAT06 EN EJECUCION';
		
		ELIF (dtFecha_Hoy_Integral < CURRENT::DATE) THEN -- VALIDA QUE EL SISTEMA DE INTEGRA ESTE A CORDE A LA DEL SERVIDOR
			
			LET vsCodRet = '00003'; --FECHAS INTEGRAR-SERVIDOR DESFASADAS 
			LET vsMensaje_Respuesta = 'FECHAS INTEGRAR-SERVIDOR DESFASADAS.';
		
		ELIF (NOT EXISTS (SELECT Archivo_Origen FROM BdiTarjeta:"informix".td_archivo_origen_atm_stat06 WHERE Horario_Ejecucion_Hoy = piHorario OR Horario_Ejecucion_Ext = piHorario)) THEN --VALIDA QUE EL CRON/EJECUCION ESTE CONTEMPLADAPARA ALGUNO DE LOS ARCHIVOS
			
			LET vsCodRet = '00005'; --CRON NO CONTEMPLADO EN NINGUN ARCHIVO
			LET vsMensaje_Respuesta = 'CRON NO CONTEMPLADO EN NINGUN ARCHIVO.';
		
		ELSE -- OK
		
			LET vsMensaje_Respuesta = 'MARCAR CONCILIACION EN EJECUCION';
			
			--MARCA LA BANDERA DE CONCILIACION EN EJECUCION
			UPDATE BdiTarjeta:"informix".td_param_conciliacion_atm_stat06
			SET Valor = 'V',  
				Fecha_Modificacion = current
			WHERE Codigo = '001'
			AND Descripcion = 'CONCILIACION SAT06 EN EJECUCION'
			AND TRIM(Valor) = 'F';

			LET vsFlag_Ciclo_BusrcarArch = 'V'; -- ACTIVAR PARA BUSCAR UN ARCHIVO.
			
			WHILE (vsFlag_Ciclo_BusrcarArch = 'V')  -- CICLO DE BUSQUEDA DE ARCHIVOS PENDIENTES.
				
				--PERMANECE DESACTIVADO EL CICLO EN CASO DE NO ENCONTRAR OTRO REGISTRO.
				LET vsFlag_Ciclo_BusrcarArch = 'F';
				LET vsFlag_ArchPendiente = 'F';
				LET viElemento = 0;
				LET vsCodRet = '00000';
				LET viTot_Registros = 0;
				LET vmTot_Monto = 0.0;
				LET viNum_Cargo = 0;
				LET vmMonto_Cargo = 0.0;
				LET viNum_Abono = 0;
				LET vmMonto_Abono = 0.0;
				LET vsMensaje_Respuesta = 'OBTENER ARCHIVOS POR CONCILIAR.';

				-------------Obtiene Datos del Archivo a conciliar 
				SELECT Horario_Ejecucion_Ext, orden_proceso, 'V' AS Flag_ArchPendiente, ArchCon.NombreArchivo, ArchCon.Archivo_Origen, 
					ArchCon.Fecha_Archivo, ArchCon.Carga,ArchOri.Prefijo_Archivo, ArchOri.Sistema, 
					ArchOri.Conciliacion_Inter, ArchOri.conciliacion_admin_atm,ArchOri.conciliacion_admin,ArchOri.Borra_Archivo_Fisico,
					ArchOri.Transaccion_Compra, ArchOri.Transaccion_Liberacion, ArchOri.Transaccion_Forzada, ArchOri.Transaccion_Abono,
					ArchOri.Rep_Aix, ArchOri.Rep_Win, ArchOri.Archivo_Companero, ArchOri.Archivo_Report_Comisiones, ArchOri.Tipo_LayOut
				FROM bditarjeta:"informix".td_archivos_conciliacion_atm_stat06 AS ArchCon 
				LEFT JOIN bditarjeta:"informix".td_archivo_origen_atm_stat06 AS ArchOri 
				ON ArchCon.Archivo_Origen = ArchOri.Archivo_Origen
				WHERE ArchCon.Proceso = 'P'
				AND ArchCon.Fecha_Archivo = (dtFecha_Hoy_Integral::DATE - ArchOri.Dias_Desfase)::DATE 
				AND Horario_Ejecucion_Hoy <= piHorario
				ORDER BY Horario_Ejecucion_Ext, orden_proceso ASC
				INTO temp tb_config_archivo_normal WITH NO LOG ;
					
				-- SE OBTIENE DATOS PARA ARCHIVO NORMAL
				LET vsMensaje_Respuesta = 'Inserta Datos de Tab_Tem a Vars';

				SELECT FIRST 1
						Flag_ArchPendiente, 
						NombreArchivo, 
						Archivo_Origen,
						Fecha_Archivo,
						Carga, 
						Prefijo_Archivo,
						Sistema,
						Conciliacion_Inter,
						conciliacion_admin_atm,
						Conciliacion_Admin,
						Borra_Archivo_Fisico,
						Transaccion_Compra,
						Transaccion_Liberacion,
						Transaccion_Forzada, 
						Transaccion_Abono,
						Rep_Aix, 
						Rep_Win,
						Archivo_Companero, 
						Archivo_Report_Comisiones,
						Tipo_LayOut
				INTO 
					vsFlag_ArchPendiente, 
					vsNombreArchivo, 
					vsArchivo_Origen,
					vdtFecha_Archivo, 
					vsCarga, 
					vsPrefijo_Archivo,
					vsSistema,
					vsConciliacion_Inter,
					vsConciliacionAdminAtm,
					vsConciliacion_Admin,
					viBorra_Archivo_Fisico,
					vsTransaccion_Compra, 
					vsTransaccion_Liberacion, 
					vsTransaccion_Forzada, 
					vsTransaccion_Abono,
					vsRep_Aix,
					vsRep_Win,  
					vsArchivo_Companero,
					vsArchivo_Report_Comisiones,
					viTipo_LayOut
				FROM tb_config_archivo_normal ;
						
				IF (NVL(vsFlag_ArchPendiente, 'F') <> 'V') THEN -- NO ENCONTRO MOVIMIENTO NORMAL 
					-- BUSCA EXTEMPORANEO
					LET vsMensaje_Respuesta = 'OBTENER ARCHIVOS A CONCILIAR EXTEMPORANEO.';
					
					SELECT Horario_Ejecucion_Ext, orden_proceso, 'V' AS Flag_ArchPendiente, ArchCon.NombreArchivo, ArchCon.Archivo_Origen, 
						ArchCon.Fecha_Archivo, ArchCon.Carga,ArchOri.Prefijo_Archivo, ArchOri.Sistema,  
						ArchOri.Conciliacion_Inter, ArchOri.conciliacion_admin_atm,ArchOri.conciliacion_admin,ArchOri.Borra_Archivo_Fisico,
						ArchOri.Transaccion_Compra, ArchOri.Transaccion_Liberacion, ArchOri.Transaccion_Forzada, ArchOri.Transaccion_Abono,
						ArchOri.Rep_Aix, ArchOri.Rep_Win, ArchOri.Archivo_Companero, ArchOri.Archivo_Report_Comisiones, ArchOri.Tipo_LayOut
					FROM bditarjeta:"informix".td_archivos_conciliacion_atm_stat06 AS ArchCon 
					LEFT JOIN bditarjeta:"informix".td_archivo_origen_atm_stat06 AS ArchOri 
					ON ArchCon.Archivo_Origen = ArchOri.Archivo_Origen
					WHERE ArchCon.Proceso = 'P'
					AND ArchCon.Fecha_Archivo <= (dtFecha_Hoy_Integral::DATE - ArchOri.Dias_Desfase)::DATE
					AND Horario_Ejecucion_Ext <= piHorario
					ORDER BY Horario_Ejecucion_Ext, orden_proceso ASC
					INTO temp tb_config_archivo_extenporaneo  WITH NO LOG ;
					
					SELECT FIRST 1
						Flag_ArchPendiente, 
						NombreArchivo, 
						Archivo_Origen,
						Fecha_Archivo,
						Carga, 
						Prefijo_Archivo,
						Sistema,
						Conciliacion_Inter,
						conciliacion_admin_atm,
						Conciliacion_Admin,
						Borra_Archivo_Fisico,
						Transaccion_Compra,
						Transaccion_Liberacion,
						Transaccion_Forzada, 
						Transaccion_Abono,
						Rep_Aix, 
						Rep_Win,
						Archivo_Companero, 
						Archivo_Report_Comisiones,
						Tipo_LayOut
					INTO 
						vsFlag_ArchPendiente, 
						vsNombreArchivo, 
						vsArchivo_Origen,
						vdtFecha_Archivo, 
						vsCarga, 
						vsPrefijo_Archivo,
						vsSistema,
						vsConciliacion_Inter,
						vsConciliacionAdminAtm,
						vsConciliacion_Admin,
						viBorra_Archivo_Fisico,
						vsTransaccion_Compra, 
						vsTransaccion_Liberacion, 
						vsTransaccion_Forzada, 
						vsTransaccion_Abono,
						vsRep_Aix,
						vsRep_Win,  
						vsArchivo_Companero,
						vsArchivo_Report_Comisiones,
						viTipo_LayOut
					FROM tb_config_archivo_extenporaneo ;
				END IF; --IF(1)
				
						
				IF (NVL(vsFlag_ArchPendiente, 'F') = 'V') THEN -- EXISTEN ARCHIVOS PENDIENTE POR PROCESAR
				
					LET vsFlag_Ciclo_BusrcarArch = 'V'; -- ENCONTRO UN REGISTRO, ACTIVAR PARA BUSCAR EL SIGUIENTE
					LET vsFlag_Error_Reg = 'F';
				  

					IF ( vsSistema = 'A' ) THEN
						LET vdDiaHora = CURRENT;
					
						-- ACTUALIZA LA HORA DE INICIO DE PROCESO DEL ARCHIVO
						UPDATE bditarjeta:"informix".td_archivos_conciliacion_atm_stat06
						SET Fecha_Hora_Ini_Proceso = vdDiaHora,
							Fecha_Proceso = vdFechaDeHoy
						WHERE NombreArchivo = vsNombreArchivo 
						AND Archivo_Origen = vsArchivo_Origen 
						AND Fecha_Archivo = vdtFecha_Archivo;
		  
						IF (vsCarga <> 'V') THEN -- VALIDA QUE LA CARGA DEL ARCHIVO NO FUE REALIZADA PREVIAMENTE
							
							-- CARGA EL ARCHIVO A LA TABLA DE PASO
							EXECUTE PROCEDURE BdiTarjeta:"informix".sp_cnc_cga_stat06 ( vsRep_Aix, vsNombreArchivo, vsArchivo_Origen, viTipo_LayOut, vsSistema, vsRep_Aix)
							INTO vsCodRet, vsMensaje_Respuesta, viTot_Registros, vmTot_Monto, viElemento;
							
							LET vdDiaHora = CURRENT;
							
							-- ACTUALIZA LA HORA DE FIN DE LA CARGAR DE ARCHIVO A LA BD
							UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_atm_stat06
							SET Fecha_Hora_Carga_Archivo = vdDiaHora
							WHERE NombreArchivo = vsNombreArchivo 
							AND Archivo_Origen = vsArchivo_Origen 
							AND Fecha_Archivo = vdtFecha_Archivo;
							
						END IF; -- (2.1.1) Cierre del IF (vsCarga <> 'V') THEN --VALIDA QUE LA CARGA DEL ARCHIVO NO FUE REALIZADA PREVIAMENTE
						
						IF (vsCodRet = '00000') THEN --VALIDA SI EL ARCHIVO SE CARGO A LA TABLA DE PASO.
						
							IF (vsCarga <> 'V') THEN --VALIDA QUE LA CARGA DEL ARCHIVO NO FUE REALIZADA PREVIAMENTE
							
								-- CARGA LA INFORMACION SIGNIFICATIVA DE LOS REGISTROS A LA TABLA TD_MOVIMIENTOS_CONCILIACION
								EXECUTE PROCEDURE BdiTarjeta:"informix".sp_cnc_obtenerregistroarchivo_stat06 (vsNombreArchivo, vsArchivo_Origen, viTipo_LayOut, psCve_Usuario )
								INTO vsCodRet, vsMensaje_Respuesta, viElemento;
							
								-- ACTUALIZA LA HORA DE FIN DE LA CARGAR DE LA TABLA Td_Movimientos_Conciliacion
								 LET vdDiaHora = CURRENT;
								
								UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_atm_stat06
								SET Fecha_Hora_Carga_Tabla = vdDiaHora,
									Num_Registros325 = viTot_Registros, 
									Monto325 = vmTot_Monto,
									Carga = DECODE(vsCodRet, '00000', 'V', 'F')                                
								WHERE NombreArchivo = vsNombreArchivo 
								AND Archivo_Origen = vsArchivo_Origen 
								AND Fecha_Archivo = vdtFecha_Archivo;
									
							END IF;  -- IF(2.1.2.A) Cierre del segundo IF IF (vsCarga <> 'V') THEN --VALIDA QUE LA CARGA DEL ARCHIVO NO FUE REALIZADA PREVIAMENTE
							
							
							-- VALIDA SI SE PASO LA INFORMACION A LA TABLA DE TD_MOVIMIENTOS_CONCILIACION
							IF (vsCodRet = '00000') THEN -- IF(2.1.2.B)
								
								LET vdDiaHora = CURRENT;
								-- ACTUALIZA LA HORA DE INICIO DE LA CONCILIACION DE LOS REGISTROS
								UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_atm_stat06
								SET Fecha_Hora_Ini_Concilia_Reg = vdDiaHora
								WHERE NombreArchivo = vsNombreArchivo 
								AND Archivo_Origen = vsArchivo_Origen 
								AND Fecha_Archivo = vdtFecha_Archivo;
									
								LET vsFlagEnTransaccion = 'F';
								LET viContadorRegistros = 0;
								LET vsFlag_Ciclo_BusrcarReg = 'V'; -- ARCTIVAR PARA BUSCAR UN REGISTRO.
								
								WHILE (vsFlag_Ciclo_BusrcarReg = 'V')  -- CICLO DE BUSQUEDA DE REGISTROS PENDIENTES.
									
									-- ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
									IF (vsFlagEnTransaccion = 'F') THEN
										BEGIN WORK;
										LET vsFlagEnTransaccion = 'V';
									END IF;
									
									LET vsFlag_Ciclo_BusrcarReg = 'F'; -- PERMANECE DESACTIVADO EL CICLO EN CASO DE NO ENCONTRAR OTRO REGISTRO.
									LET vsFlagIntegridad = '';
									LET vsCodRet = '00000';
									LET vsTipoMov = '';
									LET vsAplicacion = '';
									LET vsBandera_Proceso = '';
									LET vsTransaccion_Aplica = '';
									LET vsMensaje_Respuesta = 'OBTENER REGISTROS A CONCILIAR.';

									-- OBTIENE LOS REGISTROS PERTENECIENTES AL ARCHIVO ACTUAL

									SELECT {+AVOID_FULL(bditarjeta:td_movimientos_conciliacion)} FIRST 1 'V' AS Ciclo_BusrcarReg, Consecutivo, NumTarjeta, TipoTransaccion325, Monto325, montocashback325, numcuenta,
										estransfer, Idcomercio325, 	Nomcomercio325, Referencia23_325, Secuencia325, Divisa325, Rfc325, NumCuenta, Monto_Divisa325,
										Conciliacion, Secuencia, Secuencia_Extendida, MontoIntercard, MontoCashback, FechaTransaccion, 
										InfReceptor, IdTerminal, MetodoCaptura, MovConciliado, MovReversado, Tipo_Mov, Folio_Mov, 
										FechaConcilia, Tipo_Conciliacion, Desc_Conciliacion, ISO323, MovRev325,
										Transaccion_Aplica, Bandera_Proceso, b_aplica,secuencia_ext_archivo,archivo_origen,
										txn_code,indicador_fastfounds,ref_num_fastfounds,parcialiacion_promo,tipo_plan_promo
									INTO vsFlag_Ciclo_BusrcarReg, viConsecutivo, vsNumTarjeta, vsTipoTransaccion325, vsMonto325,vsMontoCashBack325, vsCuenta,
										vsestransfer, vsIdcomercio325, vsNomcomercio325, vsReferencia23_325, vsSecuencia325, vsDivisa325, vsRfc325, vsNumCuenta, vsMonto_Divisa325, 
										vsConciliacion_Reg, vsSecuencia, vsSecuencia_Extendida, vmMontoIntercard, vmMontoCashBack, vsFechaTransaccion, 
										vsInfReceptor, vsIdTerminal, vsMetodoCaptura, vsMovConciliado, vsMovReversado, vsTipo_Mov, vsFolio_Mov, 
										vdFechaConcilia, viTipo_Conciliacion, vsDesc_Conciliacion, vsISO323, vsMovRev325,
										vsTransaccion_Aplica, vsBandera_Proceso, vsb_aplica,vssecuencia_ext_archivo,vsArchivoOriIST,
										vsTxn_code,vsIndicador_fastfounds,vsRef_num_fastfounds,vspromoMSI,vsMSi
									FROM BdiTarjeta:"informix".Td_Movimientos_Conciliacion
									WHERE NombreArchivo = vsNombreArchivo
									AND Archivo_Origen = vsArchivo_Origen
									AND Finalizado = 'F';
									
									IF (vsFlag_Ciclo_BusrcarReg = 'V') THEN --VALIDA SI EXISTE REGISTRO PARA PROCESAR
									
										SELECT FIRST 1 NVL(CreditoDebito,'') 
										INTO vsSistema_Registro
										FROM Intercard:"informix".Bines 
										WHERE Bin = SUBSTR(vsNumTarjeta, 1, 6); --OBTIENE EL BIN CORRESPONDIENTE DE LA TARJETA
											
										IF (NVL(vsSistema_Registro,'') = '') THEN --LA TARJETA NO CONTIENE BIN VALIDO
											LET vsSistema_Registro = '';
										END IF;
										
										LET vsMensaje_Respuesta = 'VALIDAR INTEGRIDAD DEL REGISTRO.';
										
										-- VALIDA LA INTEGRIDAD DE LOS REGISTROS INDIVIDUALES --07/2013 Se integra nuevo campo de validacion vsmontocashback325, elemento 3
										EXECUTE PROCEDURE BdiTarjeta:"informix".sp_concreing_validaintegridad_stat06( vsArchivo_Origen, viConsecutivo, vsNumTarjeta, vsTipotransaccion325, vsMonto325, vsMontoCashBack325, vsIdcomercio325, vsNomcomercio325, vsReferencia23_325, vsSecuencia325, vsDivisa325, vsRfc325, vsBinDebito, vsBinCredito, vsSistema)
										INTO vsCodRet, vsFlagIntegridad, vsMensaje_Respuesta, viElemento;
											
										-- VALIDA SI AL REGISTRO LE CORRESPONDE CONCILIACION INTERCARD Y QUE LA INTEGRIDAD SEA CORRECTA
										IF ((vsConciliacion_Inter = 'V') AND (vsCodRet = '00000') AND (viTipo_Conciliacion = 0)) THEN
											
											LET vsMensaje_Respuesta = 'CONCILIACION INTERCARD.';

											-- Se modifica llamado por integracion de operaciones con cash back (vsmontocashback325)
											EXECUTE PROCEDURE BdiTarjeta:"informix".Sp_ConcReing_ConciliaIntercard ( psCve_usuario, vsArchivo_Origen, vsConciliacion_Inter, vsConciliacion_Reg,
												viConsecutivo, vsNumtarjeta, vsSecuencia325, vsMonto325,vsMontoCashBack325, vsTipotransaccion325, vsFlagIntegridad, viTipo_LayOut, vsISO323,
												vsMovRev325, vsb_aplica,vssecuencia_ext_archivo,vsArchivoOriIST,vsTxn_code,vsIndicador_fastfounds,vsMSi,vspromoMSI) --TFROZADAS
											INTO vsCodRet, vsConciliacion_Reg, vsSecuencia, vsSecuencia_Extendida,vscodgironeg, vmMontoIntercard, vmMontoCashBack, vsFechaTransaccion, 
												vsInfReceptor, vsIdTerminal, vsMetodoCaptura, vsMovConciliado, vsMovReversado, vsTipo_Mov, vsb_aplica, vsFolio_Mov, 
												vdFechaConcilia, viTipo_Conciliacion, vsDesc_Conciliacion, vsMensaje_Respuesta, viElemento, viActualizacion; -- Se modifica retorno TForzadas 
										END IF
									
										-- Validacion para cajeros automaticos
										IF ( (vsConciliacionAdminAtm = 'V') AND (vsCodRet = '00000') ) THEN

											EXECUTE PROCEDURE BdiTarjeta:"informix".Sp_ConcReing_ConAdmin_Atms 
											( 
												vsSistema_Registro, 
												vdtFecha_Archivo, --FECHA DEL ARCHIVO PARA MANEJO CORRECTO DE EXTEMPORANEOS
												vsMovReversado, 
												vsNumTarjeta, 
												vsFolio_Mov, --REQUIERE CONCILIACION INTERCARD
												vsArchivo_Origen, 
												vsNombreArchivo, 
												vsTipo_Mov, --REQUIERE CONCILIACION INTERCARD
												((vsMonto325::MONEY)/100), 
												vsSecuencia_Extendida, --REQUIERE CONCILIACION INTERCARD
												vsFechaTransaccion, --REQUIERE CONCILIACION INTERCARD
												vmMontoIntercard,  --REQUIERE CONCILIACION INTERCARD
												vsIdTerminal, --REQUIERE CONCILIACION INTERCARD
												vsTransaccion_Aplica, 
												vsNombreArchivo_Comi, 
												psCve_usuario 
											) 
											INTO vsCodRet, vsMensaje_Respuesta, viElemento;
											
											END IF; --(vsConciliacion_Admin = 'V') AND (vsCodRet = '00000')
										
										IF (vsCodRet <> '00000') THEN --VALIDA QUE TODOS LOS PROCESOS PARA EL REGISTRO SEAN CORRECTOS
											--LET vsMensaje_Respuesta = 'ACTUALIZA EL ESTATUS DEL REGISTRO.';
											--NIVEL DE REGISTRO
											LET vsFlag_Error_Reg = 'V';
											
											--GUARDA EN BITACORA REGIOSTRO DEL ERROR EN CASO DE QUE EXISTA
											EXECUTE PROCEDURE BdiTarjeta:"informix".sp_cnc_guardabitacora_stat06 (viElemento, '(' || vsCodRet || ') [' || vsNombreArchivo || ']' || vsMensaje_Respuesta, psCve_usuario) INTO vsCodRet2;
										
										END IF;

										LET vdDiaHora = CURRENT;
										
										--ACTUALIZA EL ESTATUS DEL REGISTRO A PROCESADO COMPLETAMENTE
										UPDATE BdiTarjeta:"informix".Td_Movimientos_Conciliacion
										SET Finalizado = DECODE(vsCodRet, '00000', 'V'/*OK*/, 'E'/*ERROR*/)
										WHERE Consecutivo = viConsecutivo
										AND NombreArchivo = vsNombreArchivo
										AND Archivo_Origen = vsArchivo_Origen
										AND Finalizado = 'F';
						   
									END IF;
									
									LET viContadorRegistros = viContadorRegistros + 1;
									
									-- TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
									IF (viContadorRegistros = 1000) THEN -- VERIFICA SI ALCANZO EL MAXIMO DE TRANSACCIONES POR BLOQUE
										COMMIT WORK;
										LET vsFlagEnTransaccion = 'F';
										LET viContadorRegistros = 0;
									END IF;
								
									IF (vsTransaccion_Aplica = '0417' ) THEN
									
									LET txn_CoppelBot = vsTransaccion_Aplica;
									
									LET vsNomArch_ComiBot = 'conciWas'|| SUBSTR(vsNombreArchivo,11,2) || SUBSTR(vsNombreArchivo,9,2)  || SUBSTR(vsNombreArchivo,13,4) || '.txt'; 
									
									END IF;
								END WHILE; -- REGISTRO

								LET vsMensaje_Respuesta = 'ACTUALIZA LA HORA DE FIN DE LA CONCILIACION DE LOS REGISTROS Y TOTALES.';

								LET vdDiaHora = CURRENT;
								
								-- ACTUALIZA LA HORA DE FIN DE LA CONCILIACION DE LOS REGISTROS
								UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_atm_stat06
								SET Fecha_Hora_Fin_Concilia_Reg =
								(
									SELECT DBINFO('utc_to_datetime', Sh_Curtime)::DATETIME YEAR TO FRACTION(5) 
									FROM SysMaster:"informix".Sysshmvals
								) 
								WHERE NombreArchivo = vsNombreArchivo 
								AND Archivo_Origen = vsArchivo_Origen 
								AND Fecha_Archivo = vdtFecha_Archivo;
								
								-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
								IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
									COMMIT WORK;
									LET vsFlagEnTransaccion = 'F';
								END IF;
							END IF; -- IF(2.1.2.B)
						END IF;
					END IF; -- IF(2.1)

					LET vdDiaHora = CURRENT;
					
					-- ACTUALIZA LA HORA DE FIN DE PROCESO DEL ARCHIVO
					UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_atm_stat06
					SET Fecha_Hora_Fin_Proceso = vdDiaHora,
					Proceso =
					(
						CASE 
							WHEN vsCodRet IN ('00006', '00007') 
								THEN 'X'  --PENDIENTE PARA EL PROX CRON ()
							WHEN vsCodRet IN  ('00000') 
								THEN 'T'  --TRABAJADO
							ELSE 'E' 
						END
					) --ERROR DE CARGA 1-2
					WHERE NombreArchivo = vsNombreArchivo 
					AND Archivo_Origen = vsArchivo_Origen 
					AND Fecha_Archivo = vdtFecha_Archivo;		
				END IF; -- IF(2)
				
				--Vacia las tablas Tmp
				DROP TABLE IF EXISTS tb_config_archivo_extenporaneo;
				DROP TABLE IF EXISTS tb_config_archivo_normal;
				
				IF (vsCodRet <> '00000') THEN
				
					-- NIVEL DE ARCHIVO
					-- GUARDA EN BITACORA REGISTRO DEL ERROR EN CASO DE QUE EXISTA
					EXECUTE PROCEDURE BdiTarjeta:"informix".sp_cnc_guardabitacora_stat06 (viElemento, '(' || vsCodRet || ') ' || vsMensaje_Respuesta, psCve_usuario) INTO vsCodRet2;
					
					LET viContadorErroresCon = viContadorErroresCon + 1;
				
				END IF;
				
				IF 
				( EXISTS (
					SELECT Descripcion 
					FROM BdiTarjeta:"informix".td_param_conciliacion_atm_stat06 
					WHERE Codigo = '002' 
					AND Descripcion = 'PARO DE EMERGENCIA DE CONCILIACION' 
					AND TRIM(Valor) = 'V'
				) ) THEN --VALIDA QUE SI EXISTE UNA ORDEN DE DETENER LA CONCILIACION (CONCREIN)
					LET vsMensaje_Respuesta = 'PARO DE EMERGENCIA DE CONCILIACION.';
					
					LET vdDiaHora = CURRENT;
					--LIBERA LA BANDERA DE PARO DE EMERGENCIA DE CONCILIACION
					UPDATE BdiTarjeta:"informix".td_param_conciliacion_atm_stat06
					SET Valor = 'F', Fecha_Modificacion = (SELECT DBINFO('utc_to_datetime', Sh_Curtime)::DATETIME YEAR TO FRACTION(5) FROM SysMaster:"informix".Sysshmvals) 
					WHERE Codigo = '002' 
					AND Descripcion = 'PARO DE EMERGENCIA DE CONCILIACION'
					AND TRIM(Valor) = 'V';
						
					LET vsFlag_ArchPendiente = 'F'; 
					LET vsFlag_Ciclo_BusrcarArch = 'F'; --TERMINA EL CICLO 
					LET vsCodRet = '00010'; --CONCILIACION DETENIDA --CONCREIN
					LET vsMensaje_Respuesta = 'CONCILIACION DETENIDA POR EL USUARIO.';
					
				END IF;
			END WHILE; -- ARCHIVO
			
			-- VALIDA SI ESXISTEN ARCHIVOS CON ESTATUS 'X'
			IF 
			(EXISTS (
				SELECT NombreArchivo 
				FROM BdiTarjeta:"informix".td_archivos_conciliacion_atm_stat06 
				WHERE Proceso = 'X'
			)) THEN
				
				LET vdDiaHora = CURRENT;
				
				-- MARCA DISPONIBLES LOS REGISTROS QUE NO SE PROCESARON POR PASES DE CRED O DEB
				UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_atm_stat06
				SET Fecha_Hora_Fin_Proceso = vdDiaHora,
				Proceso = 'P'
				WHERE Proceso = 'X'; 

			END IF;

			LET vdDiaHora = CURRENT;
			
			--LIBERA LA BANDERA DE CONCILIACION EN EJECUCION
			UPDATE BdiTarjeta:"informix".td_param_conciliacion_atm_stat06 
			SET Valor = 'F',
				Fecha_Modificacion = vdDiaHora
			WHERE Codigo = '001' 
			AND Descripcion = 'CONCILIACION EN EJECUCION' 
			AND TRIM(Valor) = 'V';
			
		END IF;
		
		IF (vsCodRet <> '00000') THEN
		
			-- NIVEL DE PROCESO
			-- GUARDA EN BITACORA REGIOSTRO DEL ERROR EN CASO DE QUE EXISTA
			EXECUTE PROCEDURE BdiTarjeta:"informix".sp_cnc_guardabitacora_stat06 (viElemento, '(' || vsCodRet || ') ' || vsMensaje_Respuesta, psCve_usuario) INTO vsCodRet2;
		
		ELSE
			
			LET vsMensaje_Respuesta = 'CONCILIACION FINALIZADA.' 
			|| DECODE ((viContadorErroresCon - (viContadorErrores_Pase_Credito + viContadorErrores_Pase_Debito)), 0, '', ' -- SE PRESENTARON [' || (viContadorErroresCon - (viContadorErrores_Pase_Credito + viContadorErrores_Pase_Debito)) || '] ERRORES DE PROCESO DE ARCHIVO.' )
			|| DECODE (viContadorErrores_Pase_Credito, 0, '', ' -- NO SE PROCESARON [' || viContadorErrores_Pase_Credito || '] ARCHIVOS POR LA FALTA DEL PASE DE CREDITO.' )
			|| DECODE (viContadorErrores_Pase_Debito, 0, '', ' -- NO SE PROCESARON [' || viContadorErrores_Pase_Debito || '] ARCHIVOS POR LA FALTA DEL PASE DE DEBITO.' );
			
		END IF;
	RETURN vsCodRet, vsMensaje_Respuesta;
END
END PROCEDURE
DOCUMENT
'Autor: Miguel Angel Lopez Galvan',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerancia de Produccion y Base de Datos Centrales',
'Descripcion: Proceso que se encarga de la ejecucion principal de la conciliacion de ATM STAT06',
'Fecha: 2023/12/06',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_cnc_cga_stat06 ( 
    psRuta_Repositorio 	VARCHAR (90), 
    psNomArchivo 		VARCHAR (30), 
    psArchivoOrigen 	VARCHAR (3), 
    piTipoLayOut 		INTEGER, 
    psSistema 			VARCHAR (1),
    psRuta_Procesos 	VARCHAR (90) 
)
RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta, INTEGER AS Tot_Registros, MONEY AS Tot_Monto, INTEGER AS Elemento;

    DEFINE vsSQL 				VARCHAR (200) ;
    DEFINE viSQLerr 			INTEGER ;
    DEFINE vsCodRet 			VARCHAR(5);
	DEFINE vCodRetAux 			VARCHAR(5);
    DEFINE vsMensaje_Respuesta 	VARCHAR(250);
    DEFINE viTotalRegistros 	INTEGER;
    DEFINE vmTotalMonto 		MONEY;
    DEFINE viInicioCadena_Reg	INTEGER;
    DEFINE viPosMontoReg_Ini 	INTEGER;
    DEFINE viPosMontoReg_Fin 	INTEGER;
    DEFINE viInicioCadena_Monto	INTEGER;
    DEFINE vsTipoSumario 		VARCHAR(35);
    DEFINE vsposicion_Regtxn	INTEGER;
    DEFINE vsposicion_Montotxn	INTEGER;
    DEFINE vsRegistros_txn		VARCHAR(12);
    DEFINE vsMonto_txn			VARCHAR(12);
    DEFINE vdRegistros_txn		VARCHAR(01);
    DEFINE vdMonto_txn			VARCHAR(01);
	
	----Monitoreo 
	DEFINE vFlagProceso VARCHAR(22);

    LET vsSQL 					= '' ;
    LET viSQLerr 				= 0;
    LET vsCodRet 				= '00000';
	LET vCodRetAux 				= '00000';
    LET vsMensaje_Respuesta	 	= 'PROCESO EXITOSO';	
    LET viTotalRegistros 		= 0;
    LET vmTotalMonto 			= 0.0;
    LET viPosMontoReg_Ini 		= 0;
    LET viPosMontoReg_Fin 		= 0;
    LET viInicioCadena_Monto	= 0;
	LET vsTipoSumario = '*Total de Transacciones:*';
    LET vsposicion_Regtxn		= 35;
    LET vsposicion_Montotxn		= 68;
    LET vsRegistros_txn	 		= ''; 
    LET vsMonto_txn				= ''; 
    LET vdRegistros_txn			= '';
    LET vdMonto_txn			= '';
	LET viPosMontoReg_Ini = 181;  --10
	LET viPosMontoReg_Fin = 10;
	
	 --SET DEBUG FILE TO "/RESPALDOSNEW/MALG/sp_cga_atm_stat06.out";
	 --TRACE ON;
    
	BEGIN
	
		ON EXCEPTION SET viSQLerr

            -- SET DEBUG FILE TO "/RESPALDOSNEW/MALG/excep_sp_cargaarchivos_stat06.out" WITH APPEND;
            -- TRACE ON;
    
			TRUNCATE TABLE bditarjeta:"informix".td_carga_archivo_stat06 DROP STORAGE;
            
			LET vsCodRet = '00107';
			
			RETURN vsCodRet, ('[' || vsCodRet ||  '] ERROR NO CONTROLADO (' || viSQLerr || '). ARCHIVO (' || psNomArchivo || ') ' || TRIM(vsMensaje_Respuesta) ), 0, 0.0, 1;
			
		END EXCEPTION;
		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_dbload_archivos_stat06(psRuta_Repositorio, psNomArchivo, psArchivoOrigen , piTipoLayOut ,  psSistema)
        INTO vsCodRet, vsMensaje_Respuesta;
            
		IF ( vsCodRet  <> '00000' ) THEN
		
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , 'CodigoRetorno: ' || vsCodRet || ' Mensaje: ' || vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
			
            RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta || ' CÃÂ³digo Bitacora Final: ' || vCodRetAux), NVL(viTotalRegistros, 0), NVL((vmTotalMonto), 0.0), 1;          
			
        END IF

		IF 
		( NOT EXISTS 
			(
				SELECT Registro 
				FROM bditarjeta:"informix".td_carga_archivo_stat06  
                WHERE Registro MATCHES '*REGISTRO DETALLADO DE TRANSACCIONES POR CAJERO*'
			)
		) THEN -- IF (1)
            
            LET vsTipoSumario 			= 'ERROR HEADER';
            LET viInicioCadena_Reg 		= -1;
            LET viInicioCadena_Monto 	= -1;
            LET viPosMontoReg_Ini 		= -1;
            LET viPosMontoReg_Fin 		= -1;
			
			LET vsCodRet = '00101';
            LET vsMensaje_Respuesta = '[' || vsCodRet ||  '] NO SE PROCESO EL ARCHIVO ESPERADO (' || psNomArchivo || ').';		
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;

		ELIF 
		( NOT EXISTS 
			(
				SELECT TRIM(Registro) 
				FROM bditarjeta:"informix".td_carga_archivo_stat06 
				WHERE Registro MATCHES vsTipoSumario 
			)
		) THEN --NO CONTIENE REGISTRO DE SUMARIO

            LET vsCodRet = '00102';
            LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CONTIENE REGISTRO DE SUMARIO/TRAILER.';		
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;

		ELIF( 	(piTipoLayOut = 4) -- PRS_STAT06  PROSA  // TARJETAS DE OTROS BANCOS EN NUESTROS CAJEROS
				OR 
				(piTipoLayOut = 7)
			) THEN  --ELIF (1.1)

			SELECT FIRST 1 
			( SUBSTR(Registro, vsposicion_Regtxn, 12) ) AS Registros_txn,  -- TOTAL REGISTROS 
			( SUBSTR(Registro, vsposicion_Montotxn, 12) ) AS Monto_txn	-- MONTO TOTAL
			INTO vsRegistros_txn, vsMonto_txn
			FROM bditarjeta:"informix".td_carga_archivo_stat06 
			WHERE Registro MATCHES '*Total de Transacciones:*';

			-- BORRA LOS REGISTROS DE ENCABEZADO
			DELETE FROM BdiTarjeta:"informix".td_carga_archivo_stat06 
			WHERE ((Registro MATCHES '  Adquirente*') 
			OR (Registro MATCHES '===============*') 
			OR (Registro MATCHES '*Institucion            Clave:*') 
			OR (Registro MATCHES '*Codigo: STAT0*') 
			OR (Registro MATCHES '    *' ) 
			OR (Registro MATCHES '   ' ) 
			OR (Registro MATCHES '  Emisor*' ) 
			OR (Registro = '' ) ) 
			AND NOT (Registro MATCHES '        Total de Transacciones: *' );

		ELSE -- ERROR EN CASO QUE NO SE ENCUENTRE ALGUN LAYOUT

            LET vsTipoSumario 			= 'ERROR LAYOUT';
            LET viInicioCadena_Reg 		= 0;
            LET viInicioCadena_Monto 	= 0;
            LET viPosMontoReg_Ini 		= 0;
            LET viPosMontoReg_Fin 		= 0;
			
			LET vsCodRet = '00103';
            LET vsMensaje_Respuesta = '[' || vsCodRet ||  '] NO SE ESPECIFICO EL TIPO DE LAYOUT DEL ARCHIVO (' || psNomArchivo || ').';		
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;

		END IF; -- IF (1)
		
		LET vsMensaje_Respuesta = 'PROCESO EXITOSO';
		
		IF (TRIM(vsTipoSumario) = 'ERROR HEADER') THEN --ERROR. NO CONTIENE EL ENCABEZADO CORRESPONDIENTE IF (2)
			
			LET vsCodRet = '00104';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CONTIENE EL ENCABEZADO CORRESPONDIENTE AL TIPO LAYOUT: ' || piTipoLayOut || '.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
			
		ELIF (TRIM(vsTipoSumario) = 'ERROR LAYOUT') THEN --ERROR. NO CORRESPONDE A NINGUN LAYOUT
			
			LET vsCodRet = '00105';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CORRESPONDE A NINGUN TIPO DE LAYOUT REGISTRADO.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
			
		ELSE
		
            LET vsMensaje_Respuesta = 'VALIDANDO REGISTROS EN SUMARIO/TRAILER SON NUMERICOS.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_ConcReing_EsNumerico( vsRegistros_txn ) INTO vdRegistros_txn;
			EXECUTE PROCEDURE bditarjeta:"informix".sp_ConcReing_EsNumerico( vsMonto_txn ) INTO vdMonto_txn;
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , 'CodigoRetorno: ' || vsCodRet || ' Mensaje: ' || vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
		
		END IF; -- IF (2)	

		IF ( vdRegistros_txn = 'F' ) THEN --ERROR TOTAL REGISTROS NO ES NUMERICO -- IF (2.3)
			
			LET vsCodRet = '00106';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') CONTIENE UN TOTAL REGISTROS NO NUMERICO.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
			
		ELIF ( vdMonto_txn = 'F' ) THEN --ERROR MONTO TOTAL NO ES NUMERICO
			
			LET vsCodRet = '00107';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') CONTIENE UN MONTO TOTAL NO NUMERICO.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
		
		ELIF ( vdRegistros_txn = 'V'  AND vdMonto_txn = 'V' ) THEN -- SI TODO LOS REGISTROS SON NUMERICOS SE REALIZA LO SIGUIENTE:
		
			LET vsMensaje_Respuesta = 'SE VÃÂLIDO QUE SE TIENEN NÃÂMEROS EN LAS TXN DE REGISTROS Y MONTO';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , 'CodigoRetorno: ' || vsCodRet || ' Mensaje: ' || vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
		
		ELSE 
	
			LET vsCodRet = '00108';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CONTIENE INFORMACIÃÂN O PRESENTA ALGUNA INCONSISTENCIA.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , 'CodigoRetorno: ' || vsCodRet || ' Mensaje: ' || vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
	
		END IF; -- IF (2.3)

	RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta || ' CÃÂ³digo Bitacora Final: ' || vCodRetAux), NVL(vsRegistros_txn, 0), NVL((vsMonto_txn), 0.0), 1;
END
END PROCEDURE
DOCUMENT
'Autor: Miguel Angel Lopez Galvan',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerancia de Produccion y Base de Datos Centrales',
'Descripcion: Proceso que se encarga de obtener los datos principales del archivo de conciliacion ATM STAT06 y validar su integridad/estructura',
'Fecha: 2023/12/06',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_cnc_dbload_archivos_stat06
(
	psRuta_Repositorio VARCHAR (90),
	psNomArchivo VARCHAR (30),
	psArchivoOrigen VARCHAR(3), 
	piTipoLayOut INTEGER,
	psSistema VARCHAR(1)
)

RETURNING VARCHAR (5) AS rCodigoRetorno, VARCHAR(250) AS rMensajeRespuesta;

    DEFINE SQLERR 					INTEGER;
	DEFINE ISAM_ERR 				INTEGER;
	DEFINE ERROR_INFO 				VARCHAR(250);    
    DEFINE vCODIGO_RETORNO 			VARCHAR(5);
    DEFINE vMENSAJE_RETORNO 		VARCHAR(250);
    DEFINE CONTADOR_TRANSACCIONES 	SMALLINT;
    DEFINE RUTA_ORIGEN 				VARCHAR(100);
    DEFINE vExecuteSQL 				LVARCHAR(1000);
    DEFINE vNombreTablaCarga 		VARCHAR(90);
    DEFINE vCaracterDelimitador 	CHAR(1);    
    DEFINE vNomCarga_DBLOAD 		VARCHAR(20);
    DEFINE vNomError_DBLOAD 		VARCHAR(20);
    DEFINE vNomError_Ejecucion 		VARCHAR(16);
    DEFINE vNombreArchivo 			VARCHAR(23);
    DEFINE vNombreCompScript 		VARCHAR(113); -- suma de psRuta_Repositorio + vNomCarga_DBLOAD + psArchivoOrigen
    DEFINE vNombreCompTXT 			VARCHAR(113);
    DEFINE vNombreCompLog 			VARCHAR(113);
    DEFINE vNombreEjecucionLog 		VARCHAR(113);
    DEFINE vNombreArchivoLog 		VARCHAR(113);
    
	LET SQLERR = '';
	LET ISAM_ERR = '';
	LET ERROR_INFO = '';
    LET vCODIGO_RETORNO = '';
    LET vMENSAJE_RETORNO = '';
    LET CONTADOR_TRANSACCIONES = 1000;
    LET RUTA_ORIGEN = '/RESPALDOSNEW/';
    LET vExecuteSQL = '';    
	LET vNombreTablaCarga = '';
    LET vCaracterDelimitador = '';
	LET vNomCarga_DBLOAD = 'dbload_carga_';
	LET vNomError_DBLOAD = 'dbload_error_';    
	LET vNomError_Ejecucion = 'error_ejecucion_';    
    
    LET vNombreCompScript = TRIM(psRuta_Repositorio)||'/'||vNomCarga_DBLOAD||LOWER(psArchivoOrigen)||'.sql';
	LET vNombreCompTXT = TRIM(psRuta_Repositorio)||'/'||vNomCarga_DBLOAD||LOWER(psArchivoOrigen)||'.txt';
	LET vNombreCompLog = TRIM(psRuta_Repositorio)||'/'||vNomError_DBLOAD||LOWER(psArchivoOrigen)||'.log';
	LET vNombreEjecucionLog = TRIM(psRuta_Repositorio)||'/'||vNomError_Ejecucion||LOWER(psArchivoOrigen)||'.log';
	LET vNombreArchivoLog = vNomError_Ejecucion||LOWER(psArchivoOrigen)||'.log';
    
    LET vNombreArchivo = psNomArchivo;
    
    -- SET DEBUG FILE TO RUTA_ORIGEN||"debug_sp_cnc_dbload_archivos.out";
    -- TRACE ON;

	BEGIN
        
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            -- SET DEBUG FILE TO RUTA_ORIGEN||"excep_sp_cnc_dbload_archivos.err.out" WITH APPEND;
            -- TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN                
                LET vMENSAJE_RETORNO = 'Archivo '||vNombreArchivo||' Proceso '||vCODIGO_RETORNO||' SQL_ERR '||SQLERR||' '||'Leer archivo '||vNombreArchivoLog||' '||current;
                LET vCODIGO_RETORNO = SQLERR;
                RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
            END IF;
			
        END EXCEPTION
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        LET vCaracterDelimitador = '+';
        LET vNombreTablaCarga = 'td_carga_archivo_stat06';        
        LET vNomCarga_DBLOAD = 'dbload_carga_';
        LET vNomError_DBLOAD = 'dbload_error_';        
        
        LET vCODIGO_RETORNO = '00001';
        LET vMENSAJE_RETORNO = 'LIMPIAR TABLA DE TRABAJO.';

        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo truncate table bditarjeta:'||vNombreTablaCarga||' drop storage  > '|| vNombreCompScript;
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'dbaccess bditarjeta '||vNombreCompScript;
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "rm -f "||vNombreCompScript;
        SYSTEM vExecuteSQL;        
        
        LET vCODIGO_RETORNO = '00002';        
        LET vMENSAJE_RETORNO = 'GENERAR COMANDO DE CARGA.';
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "FILE '"|| TRIM(psRuta_Repositorio) || '/' || TRIM(psNomArchivo)|| "' delimiter '"||vCaracterDelimitador||"' "|| '1'||
                    "; INSERT INTO "||vNombreTablaCarga|| ";"||'"'||' > '||vNombreCompTXT;
        SYSTEM vExecuteSQL;
        
        LET vCODIGO_RETORNO = '00003';        
        LET vMENSAJE_RETORNO = 'EJECUTAR CARGA DE ARCHIVO.';
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d bditarjeta -c "||vNombreCompTXT||" -l "||vNombreCompLog||" -n "||CONTADOR_TRANSACCIONES||" -r > "||vNombreEjecucionLog;
        SYSTEM vExecuteSQL;        
        
        LET vCODIGO_RETORNO = '00004';        
        LET vMENSAJE_RETORNO = 'BORRAR ARCHIVOS DE DBLOAD CARGA | ERROR CARGA | DE EJECUCION';
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'rm -f '||vNombreCompTXT ||' '||vNombreCompLog||' '||vNombreEjecucionLog;
        SYSTEM vExecuteSQL;        
    
        LET vCODIGO_RETORNO = '00000';
        LET vMENSAJE_RETORNO = 'CARGA DE ARCHIVO EXITOSA.'||psNomArchivo;

        RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
	
    END

END PROCEDURE
DOCUMENT
'Autor: Miguel Angel Lopez Galvan',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerancia de Produccion y Base de Datos Centrales',
'Descripcion: Proceso que se encarga de carga la informacion en bruto a una tabla de paso del archivo de conciliacion de ATM STAT06',
'Fecha: 2023/12/06',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_cnc_obtenerregistroarchivo_stat06 
(
	psNomArchivo VARCHAR (23),     --  Nombre del archivo el cual se esta cargando
	psArchivoOrigen VARCHAR(3),    --  Abreviatura del archivo
	piTipoLayOut INTEGER, 		   --  Tipo de layout
	psCve_Usuario VARCHAR(10)      --  Usuario del sistema 
)

RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta, INTEGER AS Elemento;

	/*  DEFINICION DE VARIABLES */
	DEFINE viSQLerr 				INTEGER ;
	DEFINE vsCodRet 				VARCHAR(5);
	DEFINE vsMensaje_Respuesta 		VARCHAR(250);	
	DEFINE vsRegistro 				CHAR(500);  		-- Se actualizo de 325 a 500
	DEFINE vsfechalocaldia 			CHAR(2);  			
	DEFINE vsfechalocalmes 			CHAR(2);  			
	DEFINE vshoralocalhr 			CHAR(2);  			
	DEFINE vshoralocalmin  			CHAR(2);  			
	DEFINE vsIDSecuencia 			CHAR(1);  			
	DEFINE vsSecuencia 				CHAR(6);  			
	DEFINE vsSecuencia_extendida 	CHAR(15);  			

	-- Para CashBack
	DEFINE vsRegistroMontototal 		Char(13);
	DEFINE vsRegistroMontoCashBack 		Char (13);
	DEFINE vsRegistroComprareal 		Char(13);
	DEFINE viconcaracteres 				integer;
	define a 							integer;
	DEFINE vmRegistroMontototal 		money;
	DEFINE vmRegistroMontoCashBack 		money;
	DEFINE vmRegistroComprareal 		money;

	DEFINE vsFlagEnTransaccion 			VARCHAR (1);
	DEFINE viContadorRegistros 			INTEGER;

	-- Para identificar el tipo de bin 
	DEFINE vsbin 					char (6);
	DEFINE vsbbin 					char (3);
	DEFINE vstpotarjeta 			char(1);
	DEFINE vsprefijo 				char(10);
	DEFINE vsfoliocorresponsales 	char(16); -- Para extraer folio suc
	DEFINE vsnumtarjeta 			char(16);
	DEFINE vsnocredito 				char(20);
	DEFINE vsinicredito 			char(1);

	-- Para recuperar desde carga nÃÂÃÂºmero de cuenta Proceso Transfer
	Define vscuenta 				char (12);
	define vsnumtarjetaini 			char(16);
	define vsvalor 					char(90);
	define vsestransfer 			char(1);

	/* Variable para cajeros idenfificar bines no propios */
	DEFINE vsCompania 				CHAR (01);

	--Fechas para identificar procesos en layout 1 y 6 Coppel Pay
	DEFINE dFechaProceso 			DATETIME YEAR to SECOND;
	DEFINE dFechaReproceso 			DATETIME YEAR to SECOND;
	DEFINE dFechaProcesoAux 		DATETIME YEAR to SECOND;
	DEFINE iTotRegistrosAux 		INTEGER;
	DEFINE iTotRegEglobal 			INTEGER;	

	-- SET DEBUG FILE TO "/informix/LVRQ/SecuenciayATM/debug/obtieneregistro.out";
	-- TRACE ON;

	/* INICIALIZACION DE VARIABLES */
	LET viSQLerr 				= 0;    
	 
	LET vsCodRet 				= '00000';
	LET vsMensaje_Respuesta 	= '';
	LET vsRegistro  			= '';
	LET vsfechalocaldia 		= '';  
	LET vsfechalocalmes 		= '';  
	LET vshoralocalhr 			= '';  
	LET vshoralocalmin 			= '';  
	LET vsIDSecuencia 			= '1';  
	LET vsSecuencia 			= '';  
	LET vsSecuencia_extendida 	= '';  


	--Para CashBack
	LET vsRegistroMontototal 	= '';
	LET vsRegistroMontoCashBack = '';
	LET vsRegistroComprareal 	= '';
	LET viconcaracteres 		= 0;
	let a 						= 0;
	LET vmRegistroMontototal 	= 0.0;
	LET vmRegistroMontoCashBack = 0.0;
	LET vmRegistroComprareal 	= 0.0;

	LET vsFlagEnTransaccion 	= '';
	LET viContadorRegistros 	= 0;

	-- Para identificar el tipo de bin 
	LET vsbin 						= '';
	LET vsbbin 						= '';
	LET vstpotarjeta 				= '';
	LET vsprefijo 					= '';
	LET vsfoliocorresponsales 		= '';
	LET vsnumtarjeta 				= '';
	let vsnocredito 				= '';
	let vsinicredito 				= '';

	-- Para recuperar desde carga numero de cuenta
	let vscuenta 			= '';
	let vsnumtarjetaini 	= '';
	let vsvalor 			= '';
	let	vsestransfer 		= '';

	/* Variable para cajeros idenfificar bines no propios */
	LET vsCompania 	= '';

	--Fechas para identificar procesos en layout 1 y 6 Coppel Pay
	LET dFechaProceso = CURRENT;
	LET dFechaReproceso = CURRENT;
	LET iTotRegistrosAux = 0;
	LET iTotRegEglobal = 0;

	BEGIN

	ON EXCEPTION SET viSQLerr
		-- SET DEBUG FILE TO "/home/c90296115/exc_sp_cnc_obtener_registro_archivo.out" WITH APPEND;
		-- TRACE ON;
		
		TRUNCATE TABLE bditarjeta:"informix".td_carga_archivo_stat06 DROP STORAGE;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		BEGIN WORK;
		
		DELETE FROM BdiTarjeta:"informix".Td_Movimientos_Conciliacion 
		WHERE NombreArchivo = psNomArchivo 
		AND Archivo_Origen = psArchivoOrigen;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCIONPENDIENTE PARA TABLA td_movimientos_cnc_coppel_pay.								
		DELETE FROM BdiTarjeta:"informix".td_movimientos_cnc_coppel_pay 
		WHERE NombreArchivo = psNomArchivo 
		AND Archivo_Origen = psArchivoOrigen; 
		
		COMMIT WORK;
		
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
		
		BEGIN WORK;
		
		-- BORRA LOS REGISTROS DEL ARCHIVO ALMACENADOS EN LA TABLA DE CARGA
		TRUNCATE TABLE BdiTarjeta:"informix".td_carga_archivo_stat06;
		COMMIT WORK;
		
		BEGIN WORK;
		
		-- BORRA LOS REGISTROS QUE SE INSERTARON EN LA TABLA.
		DELETE FROM BdiTarjeta:"informix".Td_Movimientos_Conciliacion WHERE NombreArchivo = psNomArchivo AND Archivo_Origen = psArchivoOrigen;
		
		LET vsCodRet = '00200';	
		
		RETURN vsCodRet, ('[' || vsCodRet ||  ']ERROR NO CONTROLADO (' || viSQLerr || '). ARCHIVO (' || psNomArchivo || ') ' || TRIM(vsMensaje_Respuesta) ), 2;
	
	END EXCEPTION;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET vsFlagEnTransaccion = 'F';
	LET viContadorRegistros = 0;
	
	-- Se elimina el registro con el detalle total de tsn y monto
	DELETE FROM BdiTarjeta:"informix".td_carga_archivo_stat06 
	WHERE (Registro MATCHES '        Total de Transacciones: *' );
	
	SELECT COUNT(*) 
	INTO iTotRegistrosAux
	FROM Td_Movimientos_Conciliacion 
	WHERE NombreArchivo = psNomArchivo 
	AND Archivo_Origen = psArchivoOrigen;

	IF iTotRegistrosAux = iTotRegEglobal AND iTotRegEglobal <> 0 THEN
	
		--REPROCESO.
		DELETE FROM Td_Movimientos_Conciliacion 
		WHERE NombreArchivo = psNomArchivo 
		AND Archivo_Origen = psArchivoOrigen;
		
		DELETE FROM td_movimientos_cnc_coppel_pay 
		WHERE NombreArchivo = psNomArchivo 
		AND Archivo_Origen = psArchivoOrigen;
	end if
	
    FOREACH WITH HOLD

		-- RECORRE LA TABLA PARA OBTENER LOS REGISTROS
		-- Esta tabla es de paso, y se emplea para carga la informacion de los archivos de conciliacion
		-- solo tiene un campo, por tanto es esperado el sequential scan
		SELECT Registro
		INTO vsRegistro
		FROM BdiTarjeta:"informix".td_carga_archivo_stat06
		
		IF (vsFlagEnTransaccion = 'F') THEN 
			BEGIN WORK;
			LET vsFlagEnTransaccion = 'V';
		END IF;

		IF ((piTipoLayOut = 4) or (piTipoLayOut = 7)) THEN -- ATM BANCOPPEL y ATM IST
			LET vsbin =  TRIM(SUBSTR (vsRegistro,37,6));
			LET vsnumtarjetaini = TRIM(SUBSTR (vsRegistro,37,16));
		END IF;
			
		-- OBTENCION DE NUMERO CUENTA DEBIDO A QUE TRAIA MAS DE UNA CUENTA EL REGISTRO 
		SELECT FIRST 1 numcuenta  
		INTO vscuenta 
		FROM Intercard:"informix".tarjetacuenta
		where  numcuenta != ''
		AND numtarjeta = vsnumtarjetaini;
	
		if vscuenta is null or vscuenta = '' then
			let vscuenta = '000000000000';
		END IF;
		
		if (vsbin <> 'NPT')  then
			select creditodebito, prefijo 
			into vstpotarjeta, vsprefijo 
			from Intercard:"informix".bines 
			where bin = vsbin;
		END IF;

		if ((vsbin <> '') and (vsbin <> 'NPT')) then
			LET vsbbin = 	
				CASE 	
					WHEN (vstpotarjeta = 'D') and (vsprefijo = 'DEBC') THEN 
						'VDE' 	--VISA DEBITO
					WHEN (vstpotarjeta = 'C') and (vsprefijo = 'CRED') THEN 
						'VCR'	-- VISA CREDITO
					WHEN ((vstpotarjeta = 'D') and (vsprefijo = 'MDP')) OR ((vstpotarjeta = 'D') and (vsprefijo = 'MPG')) THEN 
						'MDE'	--  MASTERCARD DEBITO
					WHEN ((vstpotarjeta = 'C') and (vsprefijo = 'MPL')) OR ((vstpotarjeta = 'C') and (vsprefijo = 'MSC')) OR  ((vstpotarjeta = 'C') and (vsprefijo = 'MCPL'))THEN 
						'MCR'	--  MASTERCARD CREDITO
					ELSE 
						'BNI'
				END;
		elif vsbin = 'NPT' then
			LET vsbbin = 'NPT';
		else
			LET vsbbin = 'BNI';
		end if;
		
		LET vsMensaje_Respuesta = 'INSERTAR REGISTRO EN LA TABLA CONCILIACION_ATM_STAT06.';
		
		IF (piTipoLayOut = 7) THEN 
			
			LET vsfechalocaldia = TRIM(SUBSTRING (vsRegistro FROM 150 FOR 2 )); --FECHA_dia
			LET vsfechalocalmes = TRIM(SUBSTRING (vsRegistro FROM 153 FOR 2 )); --FECHA_mes
			LET vshoralocalhr = TRIM(SUBSTRING (vsRegistro FROM 159 FOR 2 )); --hora
			LET vshoralocalmin = TRIM(SUBSTRING (vsRegistro FROM 162 FOR 2 )); -- minutos
			LET vsSecuencia = TRIM(SUBSTRING (vsRegistro FROM 227 FOR 6 )); -- autorizacion
			
			LET vsSecuencia_extendida = vsfechalocalmes||vsfechalocaldia||vshoralocalhr||vshoralocalmin||vsIDSecuencia||vsSecuencia;
			
			LET vsCompania = TRIM(SUBSTRING (vsRegistro FROM 234 FOR 1 ));
			
			IF (vsbbin = 'BNI') THEN 
			
				IF (vsCompania = 'D') THEN
				
					LET vsbbin ='BND';
				
				ELIF (vsCompania ='C') THEN
				
					LET vsbbin ='BNC';
				
				END IF;
			 
			END IF;
			
			INSERT INTO Intercard:"informix".Conciliacion_ATM_Stat06 
			( 
				FechaConciliacion, 
				ArchivoOrigen, 
				NombreArchivo, 
				Emisor, 
				NumCajero, 
				NumTarjeta, 
				NumCuenta, 
				IndicadordeReversa, 
				Descripcion, 
				Respuesta, 
				CodigoISO, 
				Secuencia, 
				Fecha, 
				Hora, 
				Orden, 
				Red, 
				Monto, 
				Dolares, 
				ComisionSurcharge, 
				Donativo, 
				Emp, 
				Autorizacion, 
				Compania, 
				Comision_LoyaltyFee, 
				Comision_UsoLinea,
				pos_entry_mode,
				service_code,
				terminal_capability,
				arqc, 
				arpc,
				arqc_verify,
				secuenciaextendida
			)
			VALUES 
			(
				CURRENT,
				psArchivoOrigen,
				TRIM(psNomArchivo),
				TRIM(SUBSTRING (vsRegistro FROM 3 FOR 4 )), --EMISOR
				TRIM(SUBSTRING (vsRegistro FROM 25 FOR 12 )), --NUMCANERO
				TRIM(SUBSTRING (vsRegistro FROM 37 FOR 16 )), -- NUMTARJETA
				TRIM(SUBSTRING (vsRegistro FROM 60 FOR 20 )),	--NUMCUENTA
				TRIM(SUBSTRING (vsRegistro FROM 82 FOR 19 )), --INDICADORDEREVERSA
				TRIM(SUBSTRING (vsRegistro FROM 103 FOR 15 )), --DESCRIPCION
				TRIM(SUBSTRING (vsRegistro FROM 121 FOR 6 )), --RESPUESTA
				TRIM(SUBSTRING (vsRegistro FROM 128 FOR 2 )), --CODIGOISO
				TRIM(SUBSTRING (vsRegistro FROM 133 FOR 12 )), --SECUENCIA
				TRIM(SUBSTRING (vsRegistro FROM 150 FOR 8 )), --FECHA
				TRIM(SUBSTRING (vsRegistro FROM 159 FOR 8 )), --HORA
				TRIM(SUBSTRING (vsRegistro FROM 170 FOR 6 )), --ORDEN
				TRIM(SUBSTRING (vsRegistro FROM 176 FOR 4 )), --RED 
				TRIM(SUBSTRING (vsRegistro FROM 181 FOR 10 )),  --MONTO
				TRIM(SUBSTRING (vsRegistro FROM 192 FOR 7 )),  --DOLARES
				TRIM(SUBSTRING (vsRegistro FROM 200 FOR 10 )),  --COMISIONSURCHARGE
				TRIM(SUBSTRING (vsRegistro FROM 211 FOR 10 )),  --DONATIVO
				TRIM(SUBSTRING (vsRegistro FROM 222 FOR 4 )),  --EMP
				TRIM(SUBSTRING (vsRegistro FROM 227 FOR 6 )),  --AUTORIZACION
				vsbbin,  --TRIM(SUBSTRING (vsRegistro FROM 234 FOR 10 )), --COMPAÃÂ?IA  -- SE QUITA Y PONE BANDERA DE BIN
				TRIM(SUBSTRING (vsRegistro FROM 245 FOR 10 )),  --COMISION_LOYALTYFEE
				TRIM(SUBSTRING (vsRegistro FROM 256 FOR 10 )),  --COMISION_USOLINEA
				TRIM(SUBSTR(vsRegistro, 271, 3)), -- POS ENTRY MODE
				TRIM(SUBSTR(vsRegistro, 275, 1)), -- SERVICE CODE
				TRIM(SUBSTR(vsRegistro, 277, 8)), -- Terminal capability
				TRIM(SUBSTR(vsRegistro, 286, 16)), -- ARQC
				TRIM(SUBSTR(vsRegistro, 303, 32)), -- ARPC
				TRIM(SUBSTR(vsRegistro, 336, 1)), -- ARQC verification
				vsSecuencia_extendida -- secuencia extendida generada del archivo
			);				
			
			LET vsMensaje_Respuesta = 'INSERTAR REGISTRO EN LA TABLA TD_MOVIMIENTOS_CONCILIACION';	
			
			--Se agrega la InserciÃÂÃÂ³n en td_movimientos_conciliaciÃÂÃÂ³n para registros del Stat06 LAGS
			INSERT INTO BdiTarjeta:"informix".Td_Movimientos_Conciliacion 
			(
				NombreArchivo,
				Archivo_Origen,
				NumTarjeta,
				ban_bin,
				Secuencia325,
				Monto325,
				MontoSurcharge325,
				NumCuenta,
				estransfer,
				IdComercio325,
				NomComercio325,
				TipoTransaccion325,
				Referencia23_325,
				RFC325,
				Divisa325,
				Monto_Divisa325,
				ISO323, 
				MovRev325,
				Cve_Usuario,
				secuencia_ext_archivo
			)
			VALUES
			(
				psNomArchivo,
				psArchivoOrigen,
				TRIM(SUBSTRING (vsRegistro FROM 37 FOR 16 )),  --NUMTARJETA
				vsbbin,
				TRIM(SUBSTRING (vsRegistro FROM 227 FOR 6 )), --SECUENCIAAUTH 
				TRIM(SUBSTRING (vsRegistro FROM 181 FOR 10 )),  --MONTO
				TRIM(SUBSTRING (vsRegistro FROM 200 FOR 10 )),  --MONTOSURCHARGE
				TRIM(SUBSTRING (vsRegistro FROM 60 FOR 20 )),	--NUMCUENTA LVRQ se obtiene de archivo
				trim(vsestransfer),
				'',  --IDCOMERCIO
				'',  --NOMCOMERCIO
				TRIM(SUBSTRING (vsRegistro FROM 103 FOR 15 )), --TIPOTRANSACCION
				'',  --REFTRANSACCION
				'',  --RFC
				'',  --DIVISA
				'',  --MONTODIVISA
				TRIM(SUBSTRING (vsRegistro FROM 128 FOR 2 )), --ISO325 
				TRIM(SUBSTRING (vsRegistro FROM 82 FOR 19 )), --MOVREV325 
				psCve_Usuario,
				vsSecuencia_extendida
			);
		END IF;
		
		IF (piTipoLayOut = 7) THEN
			LET viContadorRegistros = viContadorRegistros + 2;
		ELSE 
			LET viContadorRegistros = viContadorRegistros + 1;		
		END IF;
		
		LET vsMensaje_Respuesta = 'TERMINAR TRANSACCION';
		
		-- TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (viContadorRegistros >= 1000) THEN                
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
		END IF;
	END FOREACH;

	LET vsMensaje_Respuesta = 'TERMINAR TRANSACCION';
	
	-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
	
	IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN -- VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
		COMMIT WORK;
		LET vsFlagEnTransaccion = 'F';
        LET viContadorRegistros = 0;
	END IF;
	
	LET vsMensaje_Respuesta = 'BORRAR CONTENIDO DE TD_CARGA_ARCHIVO_STAT06.';
	
	BEGIN WORK;	
	
	LET vsFlagEnTransaccion = 'V';

	-- BORRA LOS REGISTROS DEL ARCHIVO ALMACENADOS EN LA TABLA DE CARGA
    TRUNCATE TABLE BdiTarjeta:"informix".td_carga_archivo_stat06 DROP STORAGE;

	COMMIT WORK;
	
	LET vsFlagEnTransaccion = 'F';
	LET vsMensaje_Respuesta = '';

	RETURN vsCodRet, vsMensaje_Respuesta, 2;
END
END PROCEDURE
DOCUMENT
'Autor: Miguel Angel Lopez Galvan',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerancia de Produccion y Base de Datos Centrales',
'Descripcion: Proceso que se encarga de parsear la ifnromacion del archivo de conciliacion ATM STAT06 para guardar los datos en la tabla principal de la conciliacion',
'Fecha: 2023/12/06',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_validaintegridad_stat06 
( 
	psArchivo_origen CHAR (3), 
	psConsecutivo INTEGER,
	psNumTarjeta CHAR(16),
	psTipotransaccion325 CHAR(15),
	pmMonto325 CHAR(13),
	pmMontoCashBack325 CHAR (13), 
	psIdcomercio325 CHAR(15), 
	psNomcomercio325 CHAR(30),
	psReferencia23_325 CHAR(23),
	psSecuencia325 CHAR(6),
	psDivisa325 CHAR(3), 
	psRfc325 CHAR(16),
	psBinDebito CHAR(6), 
	psBinCredito CHAR(6),
	psSistema CHAR(1)
)

RETURNING CHAR (5) AS Retorno, CHAR (1) AS Integridad, CHAR(250) AS ErrorActividad, INTEGER AS Elemento;

	/*VARIABLES DE ERRORES*/
	DEFINE vsIntegridad	CHAR(1);
	DEFINE vsErrorIntegridad CHAR(20);
	DEFINE vsErrorActividad	CHAR(250);

	DEFINE viCodigo INTEGER;
	DEFINE vssqlerr CHAR(5) ;
	DEFINE vsFlagError CHAR (1) ;

	DEFINE vsEsNumTarjeta	CHAR(1);
	DEFINE vsEsIdComercio	CHAR(1);
	DEFINE vsEsReferencia23_325	CHAR(1);
	DEFINE vsEsSecuencia325	CHAR(1);
	DEFINE vsEsDivisa325	CHAR(1);
	DEFINE vsEsMonto		CHAR(1);
	--DEFINE vmMonto325 MONEY(19,4);
	DEFINE vmMonto325 MONEY;
	DEFINE vsEsMontoCashBack325 CHAR(1);
	DEFINE vmMontoCashBack325 MONEY;

	DEFINE vsBine	CHAR(6);

	/* INICIALIZACION DE VARIABLES */
	LET vsIntegridad = '';
	LET vsErrorIntegridad = '';
	LET vsErrorActividad = '';

	LET vsEsNumTarjeta = '';
	LET vsEsIdComercio = '';
	LET vsEsReferencia23_325 = '';
	LET vsEsSecuencia325 = '';
	LET vsEsDivisa325 = '';
	LET vsEsMonto = '';
	LET vmMonto325 = 0;
	LET vsEsMontoCashBack325 = '';
	LET vmMontoCashBack325 = 0;
	
	LET vsBine = '';

	LET viCodigo = 0;
	LET vssqlerr = '00000';
	LET vsFlagError = '' ;

	BEGIN

		ON EXCEPTION SET viCodigo   --cacha el error en caso de que exista y regresa un valor predeterminado

				LET vssqlerr = viCodigo;
				LET vsFlagError = 'F';

				RETURN vssqlerr, vsFlagError, vsErrorActividad, 3;

		END EXCEPTION;

		--SET DEBUG FILE TO '/home/c90296115/TraceINTEGRIDAD_mike.out';
		--TRACE ON;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;

		/*OBTENIENDO LA CIFRA DEL BIN DE LA TARJETA*/
		
		LET vsBine = NVL(SUBSTRING (psNumTarjeta FROM 1 FOR 6),'');
		LET vmMonto325 = ( ( REPLACE( pmMonto325,'.',''))::MONEY/100 );
		LET vmMontoCashBack325 = ((REPLACE (pmMontoCashBack325,'.',''))::MONEY/100); --Conversion de string de monto cashback a money
		
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico ( psNumTarjeta ) INTO vsEsNumTarjeta;

		-- VALIDACION DE INTEGRIDAD DE REGISTROS - ARCHIVOS E-GLOBAL VENTAS INTERNACIONALES
		-- BCPLVID Y BCPLVIC
		IF TRIM(NVL(psArchivo_origen,''))='' THEN
			
			LET vssqlerr = '00307';
			LET vsErrorActividad = 'ERROR DE INTEGRIDAD archivo_origen: EL VALOR DEL ARCHIVO ORIGEN ES INCORRECTO';

		-- VALIDACION DE INTEGRIDAD DE REGISTROS - ARCHIVOS PROSA
		-- BCPL_ATMOL Y BCPL_ATMPL
		ELIF ( ( psArchivo_origen = 'TMO' ) OR ( psArchivo_origen = 'TMP' ) OR ( psArchivo_origen = 'IST' ) ) THEN
			LET vssqlerr = '00305';
			--VALIDANDO QUE LOS CAMPOS SEAN NUMERICOS

			--VALIDACION DEL NUMERO DE TARJETA
			IF LENGTH(psNumTarjeta)!=16 THEN
			
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR1 numtarjeta';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: DEBE SER IGUAL A 16 CARACTERES';
				
			ELIF TRIM(NVL(psNumTarjeta,''))='' THEN
			
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR2 numtarjeta';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: NO DEBE ESTAR VACIO';
				
			ELIF (vsEsNumTarjeta != 'V' ) THEN
			
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR3 numtarjeta';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: SOLO DEBE CONTENER DIGITOS';
				
			ELIF psNumTarjeta = '0000000000000000' THEN
			
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR4 numtarjeta';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: NO DEBE TENER SOLO CEROS';
				
			ELSE
			
				LET vssqlerr = '00000';

				LET vsIntegridad = 'V';
				LET vsErrorIntegridad = '';

			END IF;

		ELSE
			LET vssqlerr = '00306';
			
			/*SE HA MANDADO COMO PARAMETRO OTRO TIPO DE ARCHIVO*/
			LET vsIntegridad = 'F';
			LET vsErrorIntegridad = 'ERROR archivo_origen';
			LET vsErrorActividad = 'ERROR DE INTEGRIDAD archivo_origen: EL VALOR DEL ARCHIVO ORIGEN ES INCORRECTO';
			
		END IF;

			/*ACTUALIZAR VARIABLES DE RETORNO*/
			LET vsFlagError = vsIntegridad;
		
			UPDATE bditarjeta:"informix".td_movimientos_conciliacion
			SET integridad = vsIntegridad, integridad_error = vsErrorIntegridad
			WHERE consecutivo = psConsecutivo;

			IF (vsIntegridad NOT IN ('V')) THEN

				LET vsErrorActividad ='CONSECUTIVO '|| psConsecutivo || ' CONTIENE ' || vsErrorActividad;
				
				IF (vssqlerr = '00305') THEN 
					EXECUTE PROCEDURE BdiTarjeta:"informix".sp_cnc_guardabitacora_stat06 ('3', '(' || psConsecutivo || ') ' || vsErrorActividad, 'sysconau');
					LET vssqlerr = '00000';
				END IF;
				
			END IF;

		RETURN vssqlerr, NVL(vsFlagError,''),'', 3 ;

	END

END PROCEDURE
DOCUMENT
'Autor: Miguel Angel Lopez Galvan',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerancia de Produccion y Base de Datos Centrales',
'Descripcion: Proceso que se encarga de valdiar la integridad de los registros del archivo de conciliacion de ATM STAT06',
'Fecha: 2023/12/06',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_cnc_guardabitacora_stat06
(
	psElemento INTEGER,
	psActividad CHAR(150),
	psCve_usuario CHAR(10)
)

	RETURNING CHAR(5) AS Retorno;

	/*DEFINICION DE VARIABLES*/

	/*VARIABLES DE RETORNO*/
	DEFINE visqlerr INTEGER ;
	DEFINE vssqlerr CHAR(5);
	DEFINE vsFechaHora DATETIME YEAR TO FRACTION(5);

	/*INICIALIZACION DE VARIABLES*/
	LET visqlerr = 0;
	LET vssqlerr = '00000';
	LET vsFechaHora = CURRENT;

	BEGIN

		ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado

				LET vssqlerr = visqlerr;
				RETURN vssqlerr;

		END EXCEPTION;

		
		-- SET DEBUG FILE TO '/home/c90296115/guardaBitacoraDep.txt';
		-- TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;

		INSERT INTO bditarjeta:"informix".td_bitacora_conciliacion_atm_stat06 (elemento, fecha_hora, actividad, cve_usuario)
		VALUES (psElemento,vsFechaHora,psActividad,psCve_usuario);

		LET vssqlerr = '00000';

	RETURN vssqlerr;

	END

END PROCEDURE
DOCUMENT
'Autor: Miguel Angel Lopez Galvan',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerancia de Produccion y Base de Datos Centrales',
'Descripcion: Bitacora conciliacion ATM STAT06',
'Fecha: 2023/12/06',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_cnc_obt_archivo_stat06()

	RETURNING VARCHAR (5) AS CODIGO, VARCHAR (150) AS MENSAJE_RPTA;
	
	/* DEFINICION DE VARIABLES */

	-- CONTROL DE ERRORES
		
	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
		
	--CONTROL GENERAL
	
	DEFINE CODIGO				CHAR (6);
	DEFINE MENSAJE_RPTA			CHAR (80);
	DEFINE vRUTA_ESTAT_06		CHAR (33);
	DEFINE vCodigo				CHAR (6);
	DEFINE vListArchivo			CHAR (20);
	DEFINE vArchiBat			CHAR (20);
	DEFINE vExecuteSQL 			CHAR (300);
	DEFINE vsNombreArchivo 		CHAR (30);
	DEFINE dsFechaArchivo 		CHAR (10);
	DEFINE FlagTrace 		CHAR (10);
			
	BEGIN	
				
		ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
			
			LET CODIGO    		= SQL_ERR;
			LET MENSAJE_RPTA  	= ERROR_INFO;

			DELETE FROM bditarjeta:"informix".td_cga_nombre_archivo_atm_stat06;
			
			RETURN CODIGO, MENSAJE_RPTA;
		  
		END EXCEPTION;
				
		--SET DEBUG FILE TO "/home/c90296115/nombre_archivo_atm_stat06.out";
		--TRACE ON;
				
		/* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL
		
		LET CODIGO					= '00000';
		LET MENSAJE_RPTA			= 'PROCESO EXITOSO';
		LET vRUTA_ESTAT_06			= '';
		LET vCodigo					= '00000';
		LET vListArchivo			= 'listado_archivos.txt';
		LET vArchiBat				= 'bat_stat06.bat';
		LET vExecuteSQL				= '';
		LET vsNombreArchivo			= '';
		LET dsFechaArchivo			= '';
		LET FlagTrace				= '';
		
		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		LET FlagTrace = 'Se inicializan excepciones ';
		
		-- ELIMINA LOS RESGISTROS DE LA TABLA CARGADOS ANTERIORMENTE
		DELETE FROM bditarjeta:"informix".td_cga_nombre_archivo_atm_stat06;
					
		---DEFINE  Ruta de obtencion  
		SELECT rep_aix
		INTO vRUTA_ESTAT_06
		FROM bditarjeta:td_archivo_origen_atm_stat06
		WHERE archivo_origen = "IST";
		
		
	LET FlagTrace = 'Se obtuvo la ruta de la tabla ';	 
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'echo "ls '|| vRUTA_ESTAT_06|| '| grep BCPL_STAT06_ " > ' || vRUTA_ESTAT_06||'/'||vArchiBat;
		SYSTEM vExecuteSQL;
	LET FlagTrace = 'Paso 1';	
		LET vExecuteSQL ='';
		LET vExecuteSQL= 'chmod 777 ' || vRUTA_ESTAT_06||'/'||vArchiBat;
		system vExecuteSQL;
	LET FlagTrace = 'Paso 2';	
		LET vExecuteSQL = ''; 
		LET vExecuteSQL =  vRUTA_ESTAT_06||'/'||vArchiBat ||'>'|| vRUTA_ESTAT_06||'/'||vListArchivo; 
		SYSTEM vExecuteSQL; 
	LET FlagTrace = 'Paso 3';
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'rm '||vRUTA_ESTAT_06||'/'||vArchiBat;
		system vExecuteSQL;
	LET FlagTrace = 'Paso 4';
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'echo "LOAD FROM '|| TRIM(vRUTA_ESTAT_06) || '/' || TRIM(vListArchivo) ||
						 ' INSERT INTO bditarjeta:td_cga_nombre_archivo_atm_stat06;" > ' || TRIM(vRUTA_ESTAT_06) ||  '/load_nombre_archivo.sql';
		SYSTEM vExecuteSQL;
	LET FlagTrace = 'Paso 5';
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'dbaccess bditarjeta ' || TRIM(vRUTA_ESTAT_06) ||  '/load_nombre_archivo.sql';
		SYSTEM vExecuteSQL;
	LET FlagTrace = 'Paso 6';
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'rm '||vRUTA_ESTAT_06||'/'||vListArchivo;
		system vExecuteSQL;
		
				
		FOREACH cursor_archivo FOR
				
			SELECT nom_archivo_stat06
				INTO vsNombreArchivo
			FROM bditarjeta:"informix".td_cga_nombre_archivo_atm_stat06
			                       
			IF SUBSTR(vsNombreArchivo,19,4) = '.txt' THEN
			
				EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , 'Registrando archivo ' || vsNombreArchivo || 'para procesar.' , 'sysconau')
				INTO vCodigo;
				
				LET dsFechaArchivo = TRIM(SUBSTR (vsNombreArchivo,13,6));
				LET dsFechaArchivo = SUBSTR(dsFechaArchivo,3,2)||'/'||SUBSTR(dsFechaArchivo,1,2)||'/'||SUBSTR(dsFechaArchivo,5,2);
				LET dsFechaArchivo = dsFechaArchivo::DATE;
				LET FlagTrace = 'Proceso el nombre del archivo para inserta';			
				-- TRACE 'SOY FECHA ARCHIVO '||dsFechaArchivo;
			
				INSERT INTO bditarjeta:"informix".td_archivos_conciliacion_atm_stat06
					(nombrearchivo,
					archivo_origen,
					fecha_archivo,
					num_registros325,
					monto325,
					fecha_proceso,
					fecha_hora_transferencia, 
					fecha_hora_ini_proceso, 
					fecha_hora_carga_archivo, 
					fecha_hora_carga_tabla,					
					fecha_hora_ini_concilia_reg, 
					fecha_hora_fin_concilia_reg,
					fecha_hora_fin_proceso,
					fecha_hora_fin_conadminatm_intercard, 
					transferencia,
					carga,
					conciliacion_inter,
					conciliacion_admin_atm, 
					conciliacion_admin,
					traspaso_historico, 
					num_cargo, 
					monto_cargo,
					num_abono,
					monto_abono, 
					proceso) 
					VALUES( vsNombreArchivo, 'IST', dsFechaArchivo, 0, 0, CURRENT, CURRENT, '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0',
						'1900-01-01 00:00:00.0','1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', 'V', 'F', 'V', 'V','F','F' ,0, 0, 0, 0, 'P');
			ELSE
			
				EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , 'El archivo de conciliacion STAT06 < ' || vsNombreArchivo || ' > no se puede procesar por el formato.', 'sysconau')
				INTO vCodigo;
				
				LET CODIGO = '00001';
				
			END IF
					
		END FOREACH; -- CICLO DE OBTENCION DE REGISTROS DEL NOMBRE DEL ARCHIVO STAT06 ATM	

		IF CODIGO = '00001' THEN
		
			LET MENSAJE_RPTA = MENSAJE_RPTA || ' Se intento procesar un archivo con formato diferente. Numero de archivos procesados: ' || ( SELECT COUNT(*) FROM bditarjeta:"informix".td_cga_nombre_archivo_atm_stat06 );
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , MENSAJE_RPTA, 'sysconau')
			INTO vCodigo;
				
		ELSE
		
			LET MENSAJE_RPTA = MENSAJE_RPTA || ' Numero de archivos procesados: ' || ( SELECT COUNT(*) FROM bditarjeta:"informix".td_cga_nombre_archivo_atm_stat06 );
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , MENSAJE_RPTA, 'sysconau')
			INTO vCodigo;
			LET CODIGO = '00000';
		END IF
		RETURN CODIGO, MENSAJE_RPTA;
	END
END PROCEDURE 
DOCUMENT
'Autor: Miguel Angel Lopez Galvan',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerancia de Produccion y Base de Datos Centrales',
'Descripcion: Proceso que se encarga de obtener el archivo del STAT06',
'Fecha: 2023/12/13',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_mueve_archivo_atm_stat06_resp ()

		RETURNING VARCHAR (5)   AS CODIGO, VARCHAR (150) AS MENSAJE_RPTA;
		
		 /*  DEFINICION DE VARIABLES */

			-- CONTROL DE ERRORES
			
		    DEFINE  SQL_ERR          INTEGER;
			DEFINE  ISAM_ERR         INTEGER;
			DEFINE  ERROR_INFO       VARCHAR(80);
			
			--CONTROL GENERAL
			
			DEFINE CODIGO				CHAR (6);
			DEFINE MENSAJE_RPTA			CHAR (80);
			DEFINE vRUTA_STAT06			CHAR (34);
			DEFINE vRuta_Resp			CHAR (44);
			DEFINE vListArchivo			CHAR (20);
			DEFINE vArchiBat			CHAR (20);
			DEFINE vExecuteSQL 			CHAR (300);
			DEFINE vsNombreArchivo 		CHAR (30);
			DEFINE dsFechaArchivo 		CHAR (10);
			
		BEGIN	
			
			ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
			
			  LET CODIGO    = SQL_ERR;
			  LET MENSAJE_RPTA  = ERROR_INFO;
			  
			  RETURN CODIGO, MENSAJE_RPTA;
			  
			END EXCEPTION;
			
			--SET DEBUG FILE TO "/home/c98188925/debug/mov_archivo_dep_atm.out";
			--TRACE ON;
			
				/* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL
				
				LET CODIGO					= '00000';
				LET MENSAJE_RPTA			= 'PROCESO EXITOSO';
				LET vRUTA_STAT06				= '';
				LET vRuta_Resp				= '/home/sysconau/conciliacion/istsw/Respaldo';
				LET vListArchivo			= 'hay_archivos.txt';
				LET vArchiBat				= 'archivos_atm_stat06.bat';
				LET vExecuteSQL				= '';
				LET vsNombreArchivo			= '';
				LET dsFechaArchivo			= '';
				
				
			SET ISOLATION TO dirty READ;
			SET LOCK MODE TO WAIT 3;
			
				SELECT rep_aix
				INTO vRUTA_STAT06
				FROM BdiTarjeta:"informix".td_archivo_origen_atm_stat06
				WHERE archivo_origen='IST';
				

			FOREACH cursor_move FOR	
			
				SELECT nombrearchivo
					INTO vsNombreArchivo
				FROM BdiTarjeta:"informix".td_archivos_conciliacion_atm_stat06
				WHERE fecha_proceso = today 
				AND proceso='T'
				
				LET vExecuteSQL  = '';
				LET vExecuteSQL  = ' if  [ -f '||TRIM(vRUTA_STAT06)||'/'||TRIM(vsNombreArchivo)||' ]; ' ||     
				  ' then ' ||     
					' mv '||TRIM(vRUTA_STAT06)||'/'||TRIM(vsNombreArchivo)|| ' ' ||vRuta_Resp||';'||  
				 ' fi  >' ||TRIM(vRUTA_STAT06)||'/'||vArchiBat;
				 SYSTEM vExecuteSQL;
				
				LET vExecuteSQL  = '';
				LET vExecuteSQL  = ' chmod 777 '||TRIM(vRUTA_STAT06)||'/'||vArchiBat;
				SYSTEM vExecuteSQL;
				
				LET vExecuteSQL  = '';
				LET vExecuteSQL  = TRIM(vRUTA_STAT06)||'/'||vArchiBat;
				SYSTEM vExecuteSQL;
				
				LET vExecuteSQL  = '';
				LET vExecuteSQL  = 'rm -f '||TRIM(vRUTA_STAT06)||'/'||vArchiBat;
				SYSTEM vExecuteSQL;
	

			END FOREACH; -- CICLO DE OBTENCION DE REGISTROS DEL NOMBRE DEL ARCHIVO DE MASTER CARD
			
			RETURN CODIGO, MENSAJE_RPTA;
		END
	END PROCEDURE
	DOCUMENT
'Autor: Maria Fernanda Ortiz Figueroa',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerencia de Produccion y Base de Datos Centrales',
'Descripcion: Proceso que se encarga de realizar el respaldo del archivo de la conciliacion de ATM STAT06',
'Fecha: 2023/12/13',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_carga_buen_fin_cnc(vArchivoDBLOAD CHAR(100), RUTA CHAR(100))

	RETURNING CHAR(5) AS CodigoRetorno, CHAR(160) AS mensaje;
	
	-- Define Var Init Var Control 
	DEFINE vIntervaloCommit		INTEGER;
	DEFINE vExecuteSQL		    LVARCHAR(1000);
	DEFINE vNombreCompTXT		VARCHAR(100);
	DEFINE vNombreCompLog		VARCHAR(100);
	DEFINE vNombreEjecucionLog  VARCHAR(100);
	DEFINE nomArch              VARCHAR(100);
	DEFINE nomRut		    	VARCHAR(100);
	
	-- Define Var EXCEPTION
	DEFINE vCodigoRetorno		CHAR(5);
	DEFINE vMensaje 			CHAR(160);
	DEFINE SQLERR 				INTEGER;
    DEFINE ISAM_ERR 			INTEGER;
   	DEFINE ERROR_INFO 			VARCHAR(80);
	
	-- Init Var Control
	LET nomRut = TRIM(RUTA);
	LET nomArch = vArchivoDBLOAD;
	LET vIntervaloCommit = 1000;
	LET vExecuteSQL	='';
	LET vNombreCompTXT = TRIM(nomRut) || "/extraccion_tbl_bf_movs_cnc_sorteo_2023.txt";
	LET vNombreCompLog = TRIM(nomRut) || "/extraccion_tbl_bf_movs_cnc_sorteo_2023_log.log";
	LET vNombreEjecucionLog = TRIM(nomRut) || "/extraccion_tbl_bf_movs_cnc_sorteo_2023.log";
	
	-- Init Var Exception
	LET vCodigoRetorno = '00000';
	LET vMensaje = '';
	LET SQLERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
	
	
	BEGIN 
		-- Flujo de Excepciones
		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
					
			SET DEBUG FILE TO RUTA || "carga_.err.out";
			TRACE ON;
			
			IF ( SQLERR <> 0 ) THEN
				LET vCodigoRetorno = SQLERR;
				LET vMensaje = ERROR_INFO;                
				RETURN vCodigoRetorno, vMensaje;
			END IF;
					
		END EXCEPTION;
	
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--Termina Flujo de Exepciones 			
		
		-- Comienza Load de archivo 
		LET vCodigoRetorno = '00001';        
		LET vMensaje = 'GENERAR COMANDO DE CARGA.';
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = "echo "||'"'|| "FILE '"|| TRIM(nomRut) || '/' || TRIM(nomArch)|| "' delimiter '"|| '|' ||"' "|| '17'||
					"; INSERT INTO "|| 'tbl_bf_movs_cnc_sorteo' || ";"||'"'||' > '|| vNombreCompTXT;
		SYSTEM vExecuteSQL;
		
		LET vCodigoRetorno = '00002';        
		LET vMensaje = 'EJECUTAR CARGA DE ARCHIVO.';
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = "dbload -d bditarjeta -c " || vNombreCompTXT || " -l " || vNombreCompLog || " -n " || vIntervaloCommit ||" -r > "||vNombreEjecucionLog;
		SYSTEM vExecuteSQL; 
		
		LET vCodigoRetorno = '00000';        
		LET vMensaje = 'ARCHIVO CARGADO';

		RETURN vCodigoRetorno, vMensaje;
	END;
END PROCEDURE;