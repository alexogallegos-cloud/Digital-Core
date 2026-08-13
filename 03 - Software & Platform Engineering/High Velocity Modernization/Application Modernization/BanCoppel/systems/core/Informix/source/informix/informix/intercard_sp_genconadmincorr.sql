CREATE PROCEDURE "informix".sp_genconadmincorr(psNumEmpleado CHAR (8), psNomArchivoCom CHAR(23), psNomArchivoCred CHAR(23), psNomArchivoDeb CHAR(23), psRuta_Repositorio_AIX CHAR(100), pdtFechaReg DATE)

RETURNING CHAR(5) AS Respuesta, INTEGER AS Total_Registros, CHAR(1000) AS Mensaje_Respuesta;

--****************************************************************************************************
-- DESCRIPCION: CONCENTRA LA INFORMACION DE Intercard, BDITARJETA, DBICHEQ Y BDICRED CORRESPONDIENTE AL DETALLE DE LAS TRANSACCIONES DE COMPRAS DE TIENDAS COPPEL Y SE GENERA EL ARCHIVO DE COMISIONES EN BASE A ESTA INFORMACION
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 23/04/2010
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard  -- Conciliacion Administrativa
-- MODIFICADO : 26/05/2011 CASANOVA EDEZA HECTOR JUAN 
-- ESCRIPCION: Se agrega la funcionalidad de la conciliacion administrativa para el archivo de TPD.
--***************************************************************************************************

DEFINE vsFlagCorresponsales CHAR(1);

DEFINE vsIdArchivoCental CHAR(20);
--CONPOS

DEFINE vdtFecha DATE;
DEFINE vsTarjeta CHAR (20);
DEFINE vsTp_Movto CHAR (1);
DEFINE vsTran_Central CHAR (4);
DEFINE vsFolio325 CHAR (16);
DEFINE vmMonto325 MONEY(16,6);
DEFINE vsEstatus CHAR (1);
DEFINE vsSecuenciaAut CHAR(7);
--MOV_DIA Y MOV_HIST
DEFINE vsCuenta CHAR (20); --cuenta
DEFINE vsTxnLiberacion CHAR (4); --transacc_suc
DEFINE vsFolioSIF CHAR (16);
DEFINE vmMontoSIF MONEY(16,6); --MONTO
--MOVIMIENTOS
DEFINE vsTipoOperacion CHAR (1);
DEFINE vsIdTerminal CHAR (4);
DEFINE vsSecIntercard CHAR (7);
DEFINE vdtFechaHoraInAuth DATETIME YEAR TO FRACTION (5) ;
DEFINE vmMontoIntercard MONEY(16,6);
DEFINE vs_NumTransacc CHAR (4);
DEFINE vsCodigo_Fun INTEGER;
DEFINE vsCodigo_Ref INTEGER;
-- Si_ProdTran
DEFINE vsCuentaC CHAR (40);
DEFINE vsCuentaA CHAR (40);
DEFINE vsArchivoOrigen CHAR (3);
DEFINE vsProdTarjeta CHAR (4);

DEFINE vmMonto MONEY(16,6);
DEFINE vmComision MONEY(16,6);
DEFINE vmIvaComision MONEY(16,6);

DEFINE vsTotal_RegistrosIntercard INTEGER;
DEFINE vsTotal_MontoIntercard MONEY(16,6);
DEFINE vsTotal_RegistrosSIF INTEGER;
DEFINE vsTotal_MontoSIF MONEY(16,6);
DEFINE vsTotal_Registros325 INTEGER;
DEFINE vsTotal_Monto325 MONEY(16,6);

DEFINE vdtFechaInicio DATETIME YEAR TO FRACTION (5) ;
DEFINE vdtFechaFin DATETIME YEAR TO FRACTION (5) ;
DEFINE vsBinTarjeta CHAR(6);
DEFINE vsTransacC CHAR(4);

DEFINE dtFechaConciliacion DATETIME YEAR TO FRACTION (5);  -- YYYY-MM-DD HH:MM:SS
DEFINE vsMensajeError CHAR(1000);
DEFINE vdtFechaTransArchivo DATETIME YEAR TO FRACTION (5);  -- YYYY-MM-DD HH:MM:SS
DEFINE vsFlagErrorTransferencia CHAR (1) ;
DEFINE vsTransArchivoAIX CHAR(1);
DEFINE vsNomArchivo VARCHAR (23) ;
DEFINE vsLoadArchivo CHAR (1) ;
DEFINE dtHoraLoadArchivo DATETIME YEAR TO FRACTION (5);  -- YYYY-MM-DD HH:MM:SS
DEFINE vsIntegridad CHAR (1) ;
DEFINE dtHoraIntegridad DATETIME YEAR TO FRACTION (5);  -- YYYY-MM-DD HH:MM:SS
DEFINE vsCargarTabla CHAR (1) ;
DEFINE dtHoraCargarTabla DATETIME YEAR TO FRACTION (5);  -- YYYY-MM-DD HH:MM:SS
DEFINE viNumRegistrosArchivo INTEGER ;
DEFINE vsConciliacion CHAR (1) ;
DEFINE dtHoraConciliacion DATETIME YEAR TO FRACTION (5);  -- YYYY-MM-DD HH:MM:SS
DEFINE viNumRegistrosConciliados INTEGER ;
DEFINE vsExportarRegistrosCentral CHAR (1) ;
DEFINE dtHoraExportarRegistrosCentral DATETIME YEAR TO FRACTION (5);  -- YYYY-MM-DD HH:MM:SS
DEFINE viNumRegistrosExportados INTEGER ;
DEFINE vsConfigurarCentral CHAR (1) ;
DEFINE dtHoraConfigurarCentral DATETIME YEAR TO FRACTION (5);  -- YYYY-MM-DD HH:MM:SS
DEFINE vsAplicarSaldos CHAR (1) ;
DEFINE dtHoraAplicarSaldos DATETIME YEAR TO FRACTION (5);  -- YYYY-MM-DD HH:MM:SS
DEFINE dtHoraTermino DATETIME YEAR TO FRACTION (5);  -- YYYY-MM-DD HH:MM:SS
DEFINE vsFlagFinExito CHAR (1) ;
DEFINE vsActividad CHAR (25);


	---DECLARACIONES
DEFINE vsCodRetorno            CHAR(5);
DEFINE iSqlErr              INTEGER;
DEFINE iSamErr              INTEGER;

DEFINE sDescMensajeError	VARCHAR(95);
DEFINE vsRepositorio 		CHAR(100);
DEFINE vsArchivo			CHAR(23);
DEFINE vsSQL				CHAR (2204);
DEFINE vsSQL1				CHAR(100);
DEFINE vsSQL2 				CHAR(1004);
DEFINE vsSQL3 				CHAR(100);
DEFINE vsSQL4				CHAR(200);
DEFINE v_Terminal			CHAR(4);
DEFINE v_FechaConciliacion	DATETIME YEAR TO FRACTION (5);
DEFINE v_Monto				MONEY(16,6);
DEFINE v_MontoComision		MONEY(16,6);
DEFINE v_MontoIva			MONEY(16,6);
DEFINE v_TotReg				INTEGER;
DEFINE v_ComisionTCD		DECIMAL(16,6);
DEFINE v_ComisionTCC		DECIMAL(16,6);
DEFINE v_IVATCD				DECIMAL(16,6);
DEFINE v_IVATCC				DECIMAL(16,6);
DEFINE vsCodRetorno2			CHAR(5);
DEFINE v_BandBA				CHAR(1);

DEFINE vsNomArchivoAUX CHAR(23);
DEFINE vsRuta_Repositorio_AIXAUX CHAR(90);
DEFINE vsArchivoOrigenAUX CHAR(3);
DEFINE vsRuta_Repositorio_WINAUX CHAR(90);
DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER;


LET vsFlagCorresponsales = 'V';

LET vsIdArchivoCental = '';
LET vdtFecha = CURRENT::DATE;
LET vsTarjeta = '';
LET vsTp_Movto = '';
LET vsTran_Central = '';
LET vsFolio325 = '';
LET vmMonto325 = 0.00;
LET vsEstatus = '';
LET vsSecuenciaAut = '';
LET vsCuenta = '';
LET vsTxnLiberacion = '';
LET vsFolioSIF = '';
LET vmMontoSIF = 0.00;
LET vsTipoOperacion = '';
LET vsIdTerminal = '';
LET vsSecIntercard = '';
LET vdtFechaHoraInAuth = CURRENT;
LET vmMontoIntercard = 0.00;
LET vs_NumTransacc = '';
LET vsCodigo_Fun = 0;
LET vsCodigo_Ref = 0;
LET vsCuentaC = '';
LET vsCuentaA = '';
LET vsArchivoOrigen = '';
LET vsProdTarjeta = '';

LET vmMonto = 0.0;
LET vmComision = 0.0;
LET vmIvaComision = 0.0;

LET vsTotal_RegistrosIntercard = 0;
LET vsTotal_MontoIntercard = 0.0;
LET vsTotal_RegistrosSIF = 0;
LET vsTotal_MontoSIF = 0.0;
LET vsTotal_Registros325 = 0;
LET vsTotal_Monto325 = 0.0;
LET vdtFechaInicio = CURRENT;
LET vdtFechaFin = CURRENT;
LET vsBinTarjeta = '';
LET vsTransacC = '';

LET dtFechaConciliacion = '1900-01-01 00:00:00' ;
LET vsMensajeError = '';
LET vdtFechaTransArchivo = '1900-01-01 00:00:00' ;
LET vsFlagErrorTransferencia = '' ;	
LET vsTransArchivoAIX = '' ;
LET vsNomArchivo = '' ;
LET vsLoadArchivo = '' ;
LET dtHoraLoadArchivo = '1900-01-01 00:00:00' ;
LET vsIntegridad = '' ;
LET dtHoraIntegridad = '1900-01-01 00:00:00' ;
LET vsCargarTabla = '' ;
LET dtHoraCargarTabla = '1900-01-01 00:00:00' ;
LET viNumRegistrosArchivo = 0 ;
LET vsConciliacion = '' ;
LET dtHoraConciliacion = '1900-01-01 00:00:00' ;
LET viNumRegistrosConciliados = 0 ;
LET vsExportarRegistrosCentral = '' ;
LET dtHoraExportarRegistrosCentral = '1900-01-01 00:00:00' ;
LET viNumRegistrosExportados = 0 ;
LET vsConfigurarCentral = '' ;
LET dtHoraConfigurarCentral = '1900-01-01 00:00:00' ;
LET vsAplicarSaldos = '' ;
LET dtHoraAplicarSaldos = '1900-01-01 00:00:00' ;
LET vsActividad = '' ;
LET vsMensajeError = '' ;
LET dtHoraTermino = '1900-01-01 00:00:00' ;
LET vsFlagFinExito = '';

---INICIALIZACIONES
LET vsCodRetorno 				= '00000';
LET sDescMensajeError		= "";
LET vsRepositorio 			= "";
LET vsArchivo = 'concitarj'||REPLACE (SUBSTRING (CURRENT::DATE - 1 FROM 1 FOR 10), '/', '' )||'.txt';
LET vsSQL					= "";
LET vsSQL1					= "";
LET vsSQL2 					= "";
LET vsSQL3 					= "";
LET vsSQL4					= "";
LET v_Terminal				= "";
LET v_FechaConciliacion		= MDY(1,1,1900);
LET v_Monto					= 0.0;
LET v_MontoComision			= 0.0;
LET v_MontoIva				= 0.0;
LET v_TotReg				= 0;
LET v_ComisionTCD			= 0.0;
LET v_ComisionTCC			= 0.0;
LET v_IVATCD				= 0.0;
LET v_IVATCC				= 0.0;
LET vsCodRetorno2				= "00000";
LET v_BandBA				= "";

LET vsNomArchivoAUX = '';
LET vsRuta_Repositorio_AIXAUX = '';
LET vsArchivoOrigenAUX = '';
LET vsRuta_Repositorio_WINAUX = '';
LET vsFlagEnTransaccion = '';
LET viContadorRegistros = 0;

--SET DEBUG FILE TO "/informixuc7/perifericos/TRACE_sp_genconadmincorr.sql";
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr, iSamErr
		IF iSqlErr <> 0 THEN
			LET vsCodRetorno = iSqlErr;
		END IF;
		
		IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames  WHERE tabname = 'tmp_conciliacion_corr' AND dbsname= 'intercard') THEN
			DROP TABLE Intercard:tmp_conciliacion_corr;
		END IF;
		
		LET vsMensajeError = '('||vsCodRetorno||')  ('||iSamErr||') ERROR NO CONTROLADO INFORMIX --' || vsMensajeError;
		LET vsArchivoOrigen = 'ACC';
		--ACTUALIZA EL STATUS DE LA CONCILIACION DEL ARCHIVO
		EXECUTE PROCEDURE Intercard:sp_GuardarStatusConciliacion
		(
			vsArchivoOrigen,
			dtFechaConciliacion,
			psNumEmpleado,
			vsNomArchivo,
			vsTransArchivoAIX,
			vdtFechaTransArchivo,
			vsLoadArchivo,
			dtHoraLoadArchivo,
			vsIntegridad,
			dtHoraIntegridad,
			vsCargarTabla,
			dtHoraCargarTabla,
			viNumRegistrosArchivo,
			vsConciliacion,
			dtHoraConciliacion,
			viNumRegistrosConciliados,
			vsExportarRegistrosCentral,
			dtHoraExportarRegistrosCentral,
			viNumRegistrosExportados,
			vsConfigurarCentral, 
			dtHoraConfigurarCentral,
			vsAplicarSaldos,
			dtHoraAplicarSaldos,
			dtHoraTermino,
			vsActividad,
			vsMensajeError,
			vsFlagFinExito
		) INTO iSamErr; --ERROR EN EL PROCESO DE CONCILIACION AUTOMATICA
		RETURN vsCodRetorno, v_TotReg, vsMensajeError;
	END EXCEPTION;
	
	LET vsMensajeError = 'ELIMINAR TABLA TEMPORAL tmp_conciliacion_corr';
	
	LET vdtFechaInicio = CURRENT - Interval(1) day to day;
	LET vdtFechaFin = CURRENT - Interval(1) day to day;
	
	LET vdtFechaInicio = SUBSTRING (vdtFechaInicio FROM 1 FOR 10) || ' 00:00:00' ;
	LET vdtFechaFin = SUBSTRING (vdtFechaFin FROM 1 FOR 10) || ' 23:59:59' ;
		
	--VALIDACION DE TABLAS TEMPORALES
	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames  WHERE tabname = 'tmp_conciliacion_corr' AND dbsname= 'intercard') THEN
		DROP TABLE Intercard:tmp_conciliacion_corr;
	END IF;
	CREATE TABLE Intercard:tmp_conciliacion_corr(
		keyx SERIAL,
		IdTerminal CHAR(4),
		Fechamov DATETIME YEAR TO FRACTION(5),
		Monto MONEY(16,6),
		Comision MONEY(16,6),
		ComisionIva MONEY(16,6)
	);
	
	
	--PODRA HABER CAMBIOS CON RESPECTO A LOS PARAMETROS QUE SE VALIDAN ACONTINUACION.
	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	
	IF (TRIM(NVL(psNomArchivoCred, '')) = 'TPD') THEN --TRANSFERENCIA DE PAGOS COPPEL
		
		LET vsFlagCorresponsales = 'F';
		IF (pdtFechaReg > CURRENT::DATE) THEN
			LET vsCodRetorno = '00030'; --LA FECHA ES NO PUEDE SER SUPERIOR A LA ACTUAL
			LET vsMensajeError = '(' || vsCodRetorno || ') LA FECHA ES NO PUEDE SER SUPERIOR A LA ACTUAL' ;
		ELIF ( LENGTH (TRIM(psNomArchivoDeb)) < 20 ) THEN
			LET vsCodRetorno = '00031'; --EL ARCHIVO DE DEDITO NO POSEE LA EXTENCION CORRECTA
			LET vsMensajeError = '(' || vsCodRetorno || ') EL ARCHIVO DE TRASFERENCIAS NO POSEE LA EXTENCION CORRECTA' ;
		ELIF (EXISTS ( SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionAut WHERE Nom_Archivo = psNomArchivoCom) )  THEN --VALIDA KE NO EXISTA EL REGISTRO DE GAT TRANSFERENCIAS 
			LET vsCodRetorno = '00032'; --PROCESAMIENTO REALIZADO PREVIAMENTE
			LET vsMensajeError = '(' || vsCodRetorno || ') YA SE GENERO LA CONCILIACION ADMINISTRATIVA PREVIAMENTE PARA EL ARCHIVO (' || psNomArchivoCom || ')';
		ELIF ( LENGTH (TRIM(psRuta_Repositorio_AIX)) < 1) THEN 
			LET vsCodRetorno = '00033'; -- EL PARAMETRO DE RUTA NO PUEDE SER VACIO
			LET vsMensajeError = '(' || vsCodRetorno || ') EL PARAMETRO DE LA RUTA DEL REPOSITORIO NO PUEDE SER VACIO.' ;
		ELIF (NOT EXISTS (SELECT nom_archivo FROM Intercard:monitor_conciliacionaut WHERE nom_archivo = UPPER(TRIM(psNomArchivoDeb)) AND aplicar_saldos = 'V') 
			AND NOT EXISTS (SELECT nom_archivo FROM Intercard:monitor_conciliacionman WHERE nom_archivo = TRIM(psNomArchivoDeb) AND aplicar_saldos = 'V')) THEN 
			LET vsCodRetorno = '00034'; --EL ARCHIVO DE TRANSFERENCIAS NO SE ENCUENTRA CONCILIADO.
			LET vsMensajeError = '(' || vsCodRetorno || ') EL ARCHIVO DE TRANSFERENCIAS NO SE ENCUENTRA CONCILIADO.' ;
		END IF;
		
	ELSE
		LET vsFlagCorresponsales = 'V';
		
		IF NOT EXISTS (SELECT Valor FROM Intercard:Param_ConciliacionAuto WHERE Descripcion = "COMISION PAGO CORRESPONSAL") THEN 
			LET vsCodRetorno = '00010'; --REGISTRO DE PARAMETRO DE COMISION PAGO CORRESPONSAL NO ENCONTRADO
			LET vsMensajeError = '(' || vsCodRetorno || ') REGISTRO DE PARAMETRO DE COMISION PAGO CORRESPONSAL NO ENCONTRADO' ;
		ELIF NOT EXISTS (SELECT Valor FROM Intercard:Param_ConciliacionAuto WHERE Descripcion = "IVA COMISION PAGO CORRESPONSAL") THEN 
			LET vsCodRetorno = '00011'; --REGISTRO DE PARAMETRO IVA COMISION PAGO CORRESPONSAL NO ENCONTRADO
			LET vsMensajeError = '(' || vsCodRetorno || ') REGISTRO DE PARAMETRO IVA COMISION PAGO CORRESPONSAL NO ENCONTRADO' ;
		ELIF NOT EXISTS (SELECT Valor FROM Intercard:Param_ConciliacionAuto WHERE Descripcion = "COMISION DEPOSITO CORRESPONSAL") THEN 
			LET vsCodRetorno = '00012'; --REGISTRO DE PARAMETRO COMISION DEPOSITO CORRESPONSAL NO ENCONTRADO
			LET vsMensajeError = '(' || vsCodRetorno || ') REGISTRO DE PARAMETRO COMISION DEPOSITO CORRESPONSAL NO ENCONTRADO' ;
		ELIF NOT EXISTS (SELECT Valor FROM Intercard:Param_ConciliacionAuto WHERE Descripcion = "IVA COMISION DEP. CORRESPONSAL") THEN 
			LET vsCodRetorno = '00013'; --REGISTRO DE PARAMETRO IVA COMISION DEP. CORRESPONSAL NO ENCONTRADO
			LET vsMensajeError = '(' || vsCodRetorno || ') REGISTRO DE PARAMETRO IVA COMISION DEP. CORRESPONSAL NO ENCONTRADO' ;
		ELIF (pdtFechaReg > CURRENT::DATE) THEN
			LET vsCodRetorno = '00014'; --LA FECHA REG NO PUEDE SER SUPERIOR A LA ACTUAL
			LET vsMensajeError = '(' || vsCodRetorno || ') LA FECHA REG NO PUEDE SER SUPERIOR A LA ACTUAL' ;
		ELIF ( LENGTH (TRIM(psNomArchivoCred)) < 20 ) THEN
			LET vsCodRetorno = '00015'; --EL ARCHIVO DE CREDITO NO POSEE LA EXTENCION CORRECTA
			LET vsMensajeError = '(' || vsCodRetorno || ') EL ARCHIVO DE CREDITO NO POSEE LA EXTENCION CORRECTA' ;
		ELIF ( LENGTH (TRIM(psNomArchivoDeb)) < 20 ) THEN
			LET vsCodRetorno = '00016'; --EL ARCHIVO DE DEDITO NO POSEE LA EXTENCION CORRECTA
			LET vsMensajeError = '(' || vsCodRetorno || ') EL ARCHIVO DE DEDITO NO POSEE LA EXTENCION CORRECTA' ;
		ELIF ( SUBSTRING (TRIM(psNomArchivoDeb) FROM 9 FOR 8) <> SUBSTRING (TRIM(psNomArchivoCred) FROM 9 FOR 8) ) THEN
			LET vsCodRetorno = '00017'; --LOS ARCHIVOS DE CREDITO Y DEBITO POSEEN FECHAS DISTINTAS
			LET vsMensajeError = '(' || vsCodRetorno || ') LOS ARCHIVOS DE CREDITO Y DEBITO POSEEN FECHAS DISTINTAS' ;
		ELIF (EXISTS ( SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionAut WHERE Nom_Archivo = psNomArchivoCom) )  THEN --VALIDA QUE NO EXISTA EL REGISTRO DE GAC 
			LET vsCodRetorno = '00018'; --PROCESAMIENTO REALIZADO PREVIAMENTE
			LET vsMensajeError = '(' || vsCodRetorno || ') YA SE GENERO LA CONCILIACION ADMINISTRATIVA PREVIAMENTE PARA EL ARCHIVO (' || psNomArchivoCom || ')';
		ELIF (EXISTS ( SELECT ArchivOorigen FROM Intercard:ConAdmIn WHERE NomArchivo325 MATCHES TRIM(psNomArchivoCred) || '*' ) )  THEN --VALIDA QUE EL ARCHIVO DE CREDITO NO FUE PROCESADO ANTERIORMENTE
			LET vsCodRetorno = '00019'; --ARCHIVO DE CREDITO PROCESADO ANTERIORMENTE
			LET vsMensajeError = '(' || vsCodRetorno || ') EL ARCHIVO DE CREDITO FUE PROCESADO ANTERIORMENTE (' || TRIM(psNomArchivoCred) || ')';
		ELIF (EXISTS ( SELECT ArchivOorigen FROM Intercard:ConAdmIn WHERE NomArchivo325 MATCHES TRIM(psNomArchivoDeb) || '*' ) )  THEN --VALIDA QUE EL ARCHIVO DE DEBITO NO FUE PROCESADO ANTERIORMENTE
			LET vsCodRetorno = '00020'; --ARCHIVO DE DEBITO PROCESADO ANTERIORMENTE
			LET vsMensajeError = '(' || vsCodRetorno || ') EL ARCHIVO DE DEBITO FUE PROCESADO ANTERIORMENTE (' || TRIM(psNomArchivoDeb) || ')';
		ELIF ( LENGTH (TRIM(psRuta_Repositorio_AIX)) < 1) THEN 
			LET vsCodRetorno = '00021'; -- EL PARAMETRO DE RUTA NO PUEDE SER VACIO
			LET vsMensajeError = '(' || vsCodRetorno || ') EL PARAMETRO DE LA RUTA DEL REPOSITORIO NO PUEDE SER VACIO.' ;
		ELIF (NOT EXISTS (SELECT nom_archivo FROM Intercard:monitor_conciliacionaut WHERE nom_archivo = UPPER(TRIM(psNomArchivoCred)) AND aplicar_saldos = 'V') 
			AND NOT EXISTS (SELECT nom_archivo FROM Intercard:monitor_conciliacionman WHERE nom_archivo = TRIM(psNomArchivoCred) AND aplicar_saldos = 'V')) THEN 
			LET vsCodRetorno = '00022'; --EL ARCHIVO DE PAGOS NO SE ENCUENTRA CONCILIADO.
			LET vsMensajeError = '(' || vsCodRetorno || ') EL ARCHIVO DE PAGOS NO SE ENCUENTRA CONCILIADO.' ;
		ELIF (NOT EXISTS (SELECT nom_archivo FROM Intercard:monitor_conciliacionaut WHERE nom_archivo = UPPER(TRIM(psNomArchivoDeb)) AND aplicar_saldos = 'V') 
			AND NOT EXISTS (SELECT nom_archivo FROM Intercard:monitor_conciliacionman WHERE nom_archivo = TRIM(psNomArchivoDeb) AND aplicar_saldos = 'V')) THEN 
			LET vsCodRetorno = '00023'; --EL ARCHIVO DE ABONOS NO SE ENCUENTRA CONCILIADO.
			LET vsMensajeError = '(' || vsCodRetorno || ') EL ARCHIVO DE ABONOS NO SE ENCUENTRA CONCILIADO.' ;
		END IF;
	END IF;
	
	
	IF (vsCodRetorno = '00000') THEN -- OK
		LET vsMensajeError = 'OBTENER FECHA DEL SERVIDOR';
		--OBTIENE LA FECHA Y HORA ACTUAL DEL SERVIDOR
		EXECUTE PROCEDURE Intercard:sp_ObtFechaHoraServidor  (psRuta_Repositorio_AIX) INTO iSamErr, dtFechaConciliacion ;
		
		LET vsMensajeError = 'OBTENCION DE PARAMETROS CONCILIACION ADMINISTRATIVA';
		
		IF (vsFlagCorresponsales = 'F') THEN -- TRANSFERENCIA DE PAGOS
		
			--- OBTENER EL PARAMETRO DEL VALOR DEL IVA Y COMISION DE TARJETA COPPEL DEBITO 
			SELECT FIRST 1 TRIM(valor)
			INTO v_IVATCD
			FROM Intercard:Param_ConciliacionAuto 
			WHERE descripcion = "IVA COMISION DEP. CORRESPONSAL";
			
			SELECT FIRST 1 TRIM(valor)
			INTO v_ComisionTCD
			FROM Intercard:Param_ConciliacionAuto 
			WHERE descripcion = "COMISION DEPOSITO CORRESPONSAL";
			
			LET vsMensajeError = 'OBTIENE NOMBRE DEL ID CON EL QUE SE MANDAN LOS REGISTROS CONCILIADOS A PASO CONCILIA ';
			SET ISOLATION TO DIRTY READ ;
			SET LOCK MODE TO WAIT 3;
			SELECT FIRST 1 IdArchivoCental INTO vsIdArchivoCental FROM Intercard:Central WHERE NombreArchivo MATCHES SUBSTRING( TRIM(psNomArchivoDeb) FROM 1 FOR 16)||'*';
			
			--OBTINENE EL TIPO DEL ARCHIVO   --BCPLTPD_
			LET vsArchivoOrigen = SUBSTRING (psNomArchivoDeb FROM 5 FOR 3);
			LET vdtFecha = SUBSTRING(psNomArchivoDeb FROM 11 FOR 2) || '/' || SUBSTRING(psNomArchivoDeb FROM 9 FOR 2) || '/' || SUBSTRING(psNomArchivoDeb FROM 13 FOR 4);
			
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
			--OBTIENE TODOS LOS REGISTROS QUE SE MANDARON A APLICAR A LA APLICACION DE SALDOS 
			FOREACH WITH HOLD
			--CUENTA CONTIENE EL FOLIO_MOV PARA CORRESPONSALES/TRAMSFERENCIAS
			SELECT Tp_Movto, Tran_Central, Cuenta, Monto, bandera_proceso AS Estatus, Documento AS SecuenciaAut
				INTO vsTp_Movto, vsTran_Central, vsFolio325, vmMonto325, vsEstatus, vsSecuenciaAut
				FROM  BdiTarjeta:Td_ConTPD WHERE Empresa = '001' AND Archivo = TRIM(vsIdArchivoCental)
			
				
				LET vsIdTerminal = SUBSTRING(vsFolio325 FROM 1 FOR 4);
				
				SET ISOLATION TO DIRTY READ ;
				SET LOCK MODE TO WAIT 3;
				SELECT FIRST 1 Num_Tarjeta, Cuenta, transacc, Folio_Suc, Monto_Tot, TransacC
				INTO vsTarjeta, vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC
				FROM BdiCheq:Sc_MovHis
				WHERE Empresa = '001'
				AND Cuenta IS NOT NULL
				AND Folio_Suc = vsFolio325
				AND Sucursal = '5006'
				AND Fech_Alt = vdtFecha -1
				AND Cancelad <> 'S'
                AND transacc not in('0260','3259'); --No considera las transacciones de IVA y Comisiones por TDD con Chip
				
				SET ISOLATION TO DIRTY READ ;
				SET LOCK MODE TO WAIT 3;
				--OBTIENE EL PRODUCTO DE LA TARJETA
				SELECT FIRST 1 ProdTarjeta INTO vsProdTarjeta
				FROM BdiCheq:Sc_Tarjeta 
				WHERE Empresa = '001'
				AND Num_Tarjeta = TRIM(vsTarjeta);
				
				LET vsMensajeError = 'OBTENCION DE RISTAS CONTABLES';
				--NO SE UTILIZAN EN TPD
				LET vsCuentaC = '';
				LET vsCuentaA = '';

				--GUARDA EL REGISTRO EN LA TABLA DE CONCILIACION ADMINISTRATIVA INTERREDES
				INSERT INTO Intercard:ConAdmIn
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
					NVL (vsArchivoOrigen, ''),
					TRIM(NVL (psNomArchivoDeb, '')),
					TRIM(NVL (psNomArchivoCom, '')),
					CURRENT::DATE,
					'D', --DETALLE
					NVL (vdtFecha, CURRENT::DATE),
					NVL (vsProdTarjeta, ''),
					NVL (vsTarjeta, ''),
					NVL (vsCuenta, ''),
					NVL (vsTp_Movto, ''),
					NVL (vsTran_Central, ''),
					NVL (vsFolio325, ''),
					NVL (vmMonto325, 0.0),
					NVL (vsEstatus, ''),
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
					NVL (psNumEmpleado, '')
				);
				
				
			END FOREACH;
			
			
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
			--SE OBTIENE LAS TRANSACCIONES DE CORRESPONSALES QUE NO FUERON REPORTADAS EN EL ARCHIVO.
			FOREACH WITH HOLD
				SELECT Num_Tarjeta, Cuenta, transacc, Folio_Suc, Monto_Tot, TransacC
				INTO vsTarjeta, vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC
				FROM BdiCheq:Sc_MovHis
				WHERE Empresa = '001'
				AND Cuenta IS NOT NULL
				AND Folio_Suc NOT IN (SELECT Folio325 FROM Intercard:ConAdmIn WHERE ArchivOorigen = NVL(vsArchivoOrigen, '') AND NomArchivo325 = TRIM(NVL(psNomArchivoDeb, '')) AND NomArchivocom = TRIM(NVL(psNomArchivoCom, '')) AND FechaRegistro = CURRENT::DATE)
				AND Sucursal = '5006'
				AND Fech_Alt = vdtFecha -1
				AND Cancelad <> 'S'
                AND transacc not in('0260','3259') --No considera las transacciones de IVA y Comisiones por TDD con Chip
				
				
				LET vsIdTerminal = SUBSTRING(vsFolioSIF FROM 1 FOR 4);
				
				SET ISOLATION TO DIRTY READ ;
				SET LOCK MODE TO WAIT 3;
				--OBTIENE EL PRODUCTO DE LA TARJETA
				SELECT FIRST 1 ProdTarjeta INTO vsProdTarjeta
				FROM BdiCheq:Sc_Tarjeta 
				WHERE Empresa = '001'
				AND Num_Tarjeta = TRIM(vsTarjeta);
				
				LET vsMensajeError = 'OBTENCION DE RISTAS CONTABLES';
				--NO SE UTILIZAN EN TPD
				LET vsCuentaC = '';
				LET vsCuentaA = '';
				
				--GUARDA EL REGISTRO EN LA TABLA DE CONCILIACION ADMINISTRATIVA INTERREDES
				INSERT INTO Intercard:ConAdmIn
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
					NVL (vsArchivoOrigen, ''),
					TRIM(NVL (psNomArchivoDeb, '')),
					TRIM(NVL (psNomArchivoCom, '')),
					CURRENT::DATE,
					'D', --DETALLE
					NVL (vdtFecha, CURRENT::DATE),
					NVL (vsProdTarjeta, ''),
					NVL (vsTarjeta, ''),
					NVL (vsCuenta, ''),
					NVL ('', ''),
					NVL ('', ''),
					NVL ('', ''),
					NVL (0, 0.0),
					NVL ('', ''),
					NVL (vsTxnLiberacion, ''),
					NVL (vsCuentaC, ''),
					NVL (vsCuentaA, ''),
					NVL (vsFolioSIF, ''),
					NVL (vmMontoSIF, 0.0),
					NVL ('', ''),
					NVL (0, 0.0),
					--NVL ('1900-01-01 00:00:00', CURRENT),
					NVL (CURRENT, CURRENT),
					NVL (vsIdTerminal, ''),
					NVL ('', ''),
					NVL (psNumEmpleado, '')
				);
				
			END FOREACH;
			
			
			LET vsBinTarjeta = '';
			
			SET ISOLATION TO DIRTY READ ;
			SET LOCK MODE TO WAIT 3;
			--OBTIENE EL BIN DE LAS TARJETAS DE DEBITO
			--SELECT FIRST 1 Bin INTO vsBinTarjeta FROM Intercard:Bines WHERE Prefijo = 'DEB' ;	
            --Ya no se usa first 1 de BINES ya que requiere traer todos los bines de productos de débito
			
			SET ISOLATION TO DIRTY READ ;
			SET LOCK MODE TO WAIT 3;
			--GUARDA EL REGISTRO EN LA TABLA DE CONCILIACION ADMINISTRATIVA CORRESPONSALES CORRESPONDIENTE A LOS TOTALES DE LAS TRANSACCIONES DE DEBITO
			SELECT SUM (CASE WHEN SecIntercard <> '' THEN 1 ELSE 0 END ) AS TOTAL_REGISTROSIntercard, SUM (CASE WHEN MontoIntcrd > 0.0 THEN MontoIntcrd  ELSE 0.0 END ) AS TOTAL_MONTOIntercard, -- Intercard NO APLICA
			SUM (CASE WHEN FolioSIF <> '' THEN 1 ELSE 0 END ) AS TOTAL_REGISTROSSIF, SUM (CASE WHEN MontoSIF > 0.0 THEN MontoSIF ELSE 0.0 END ) AS TOTAL_MONTOSIF,  -- SIF MOVHIS
			SUM (CASE WHEN Folio325 <> '' THEN 1 ELSE 0 END ) AS TOTAL_REGISTROS325, SUM (CASE WHEN Monto325 > 0.0 THEN Monto325 ELSE 0.0 END ) AS TOTAL_MONTO325  -- 325 CONCORRD
			INTO vsTotal_RegistrosIntercard, vsTotal_MontoIntercard, vsTotal_RegistrosSIF, vsTotal_MontoSIF, vsTotal_Registros325, vsTotal_Monto325 
			FROM Intercard:ConAdmIn 
			WHERE NomArchivo325 MATCHES TRIM(psNomArchivoDeb) || '*'
			AND NomArchivoCom = psNomArchivoCom
			AND TipoOperacion IS NOT NULL
			AND Estatus IS NOT NULL 
			AND TipoRegistro = 'D';
			
			
			INSERT INTO Intercard:ConAdmIn
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
				--Intercard
				SecIntercard,
				MontoIntcrd,
				FechaHoraInAuth,
				IdTerminal,
				TipoOperacion,
				Usuario
			)
			VALUES
			(
				NVL (vsArchivoOrigen, ''),
				TRIM(NVL (psNomArchivoDeb, '')),
				TRIM(NVL (psNomArchivoCom, '')),
				CURRENT::DATE,
				'T', --TOTALES
				NVL (CURRENT::DATE, CURRENT::DATE),
				NVL ('', ''),
				NVL ('', ''),
				NVL ('', ''),
				NVL ('', ''),
				NVL ('', ''),
				NVL (vsTotal_Registros325, ''), -- TOTAL OPERACIONES 325
				NVL (vsTotal_Monto325, 0.0), -- MONTO 325
				NVL ('', ''),
				NVL ('', ''),
				NVL ('', ''),
				NVL ('', ''),
				NVL (vsTotal_RegistrosSIF, ''), -- TOTAL OPERACIONES SIF
				NVL (vsTotal_MontoSIF, 0.0), -- MONTO SIF
				NVL (vsTotal_RegistrosIntercard, ''), -- TOTAL OPERACIONES Intercard
				NVL (vsTotal_MontoIntercard, 0.0), --  MONTO Intercard
				NVL (CURRENT, CURRENT),
				NVL ('', ''),
				NVL ('', ''),
				NVL (psNumEmpleado, '')
			);
		
		ELIF (vsFlagCorresponsales = 'V') THEN -- CORRESPONSALES
		
			SET ISOLATION TO DIRTY READ ;
			SET LOCK MODE TO WAIT 3;
			--- OBTENER EL PARAMETRO DEL VALOR DE LA COMISION DE TARJETA COPPEL DEBITO EN MN
			SELECT FIRST 1 TRIM(valor)
			INTO v_ComisionTCD
			FROM Intercard:Param_ConciliacionAuto 
			WHERE descripcion = "COMISION DEPOSITO CORRESPONSAL";
		
			SET ISOLATION TO DIRTY READ ;
			SET LOCK MODE TO WAIT 3;
			--- OBTENER EL PARAMETRO DEL PORCENTAJE DE LA COMISION DE TARJETA COPPEL CREDITO
			SELECT FIRST 1 TRIM(valor)
			INTO v_ComisionTCC
			FROM Intercard:Param_ConciliacionAuto 
			WHERE descripcion = "COMISION PAGO CORRESPONSAL";
			
			SET ISOLATION TO DIRTY READ ;
			SET LOCK MODE TO WAIT 3;
			--- OBTENER EL PARAMETRO DEL VALOR DEL IVA DE TARJETA COPPEL DEBITO 
			SELECT FIRST 1 TRIM(valor)
			INTO v_IVATCD
			FROM Intercard:Param_ConciliacionAuto 
			WHERE descripcion = "IVA COMISION DEP. CORRESPONSAL";
			
			SET ISOLATION TO DIRTY READ ;
			SET LOCK MODE TO WAIT 3;
			--- OBTENER EL PARAMETRO DEL VALOR DEL IVA DE TARJETA COPPEL CREDITO 
			SELECT FIRST 1 TRIM(valor)
			INTO v_IVATCC
			FROM Intercard:Param_ConciliacionAuto 
			WHERE descripcion = "IVA COMISION PAGO CORRESPONSAL";
			
			LET vsMensajeError = 'OBTIENE NOMBRE DEL ID CON EL QUE SE MANDAN LOS REGISTROS CONCILIADOS A PASO CONCILIA ';
			SET ISOLATION TO DIRTY READ ;
			SET LOCK MODE TO WAIT 3;
			--// SE OMITE PORQUE TOMA EN CUENTA TXT EN MAYUSCULAS
			SELECT FIRST 1 IdArchivoCental INTO vsIdArchivoCental FROM Intercard:Central WHERE NombreArchivo MATCHES SUBSTRING( TRIM(psNomArchivoDeb) FROM 1 FOR 16)||'*';
			
			--OBTINENE EL TIPO DEL ARCHIVO   --BCPLCCD_
			LET vsArchivoOrigen = SUBSTRING (psNomArchivoDeb FROM 5 FOR 3);
			LET vdtFecha = SUBSTRING(psNomArchivoDeb FROM 11 FOR 2) || '/' || SUBSTRING(psNomArchivoDeb FROM 9 FOR 2) || '/' || SUBSTRING(psNomArchivoDeb FROM 13 FOR 4);
			
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
			--OBTIENE TODOS LOS REGISTROS QUE SE MANDARON A APLICAR A LA APLICACION DE SALDOS 
			FOREACH WITH HOLD --CUENTA CONTIENE EL FOLIO_MOV PARA CORRESPONSALES
			SELECT Tp_Movto, Tran_Central, Cuenta, Monto, bandera_proceso AS Estatus, Documento AS SecuenciaAut
				INTO vsTp_Movto, vsTran_Central, vsFolio325, vmMonto325, vsEstatus, vsSecuenciaAut
				FROM  BdiTarjeta:td_concorrd WHERE Empresa = '001' AND Archivo = TRIM(vsIdArchivoCental)
				
				
				LET vsIdTerminal = SUBSTRING(vsFolio325 FROM 1 FOR 4);
				
				SET ISOLATION TO DIRTY READ ;
				SET LOCK MODE TO WAIT 3;
				SELECT FIRST 1 Num_Tarjeta, Cuenta, transacc, Folio_Suc, Monto_Tot, TransacC
				INTO vsTarjeta, vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC
				FROM BdiCheq:Sc_MovHis
				WHERE Empresa = '001'
				AND Cuenta IS NOT NULL
				AND Folio_Suc = vsFolio325
				AND Sucursal = '5005'
				AND Fech_Alt = vdtFecha -1
				AND Cancelad <> 'S'                
                AND transacc not in('0260','3259'); --No considera las transacciones de IVA y Comisiones por TDD con Chip
				
				SET ISOLATION TO DIRTY READ ;
				SET LOCK MODE TO WAIT 3;
				--OBTIENE EL PRODUCTO DE LA TARJETA
				SELECT FIRST 1 ProdTarjeta INTO vsProdTarjeta
				FROM BdiCheq:Sc_Tarjeta 
				WHERE Empresa = '001'
				AND Num_Tarjeta = TRIM(vsTarjeta);
				
				LET vsMensajeError = 'OBTENCION DE RISTAS CONTABLES';
				
				SET ISOLATION TO DIRTY READ ;
				SET LOCK MODE TO WAIT 3;
				--OBTIENE LA RISTA CONTABLE DE LA TRANSACCION ACTUAL
				SELECT FIRST 1 TRIM (c_ccmayor) || '-' || TRIM (c_ccsub) || '-' || TRIM (c_ccsubsub) || '-' || TRIM (c_ccsssub) || '-' || TRIM (c_ccssssub) || '-' || TRIM (c_sector) AS CuentaC,
				TRIM (a_ccmayor) || '-' || TRIM (a_ccsub) || '-' || TRIM (a_ccsubsub) || '-' || TRIM (a_ccsssub) || '-' || TRIM (a_ccssssub) || '-' || TRIM (a_sector)  AS CuentaA
				INTO vsCuentaC, vsCuentaA
				FROM BdInteg:Si_ProdTran
				WHERE Empresa = '001'
				AND Producto = vsProdTarjeta
				AND Sistema IS NOT NULL
				AND Transaccion = vsTransacC
				AND Secuencia = 1;

				--GUARDA EL REGISTRO EN LA TABLA DE CONCILIACION ADMINISTRATIVA INTERREDES
				INSERT INTO Intercard:ConAdmIn
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
					NVL (vsArchivoOrigen, ''),
					TRIM(NVL (psNomArchivoDeb, '')),
					TRIM(NVL (psNomArchivoCom, '')),
					CURRENT::DATE,
					'D', --DETALLE
					NVL (vdtFecha, CURRENT::DATE),
					NVL (vsProdTarjeta, ''),
					NVL (vsTarjeta, ''),
					NVL (vsCuenta, ''),
					NVL (vsTp_Movto, ''),
					NVL (vsTran_Central, ''),
					NVL (vsFolio325, ''),
					NVL (vmMonto325, 0.0),
					NVL (vsEstatus, ''),
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
					NVL (psNumEmpleado, '')
				);
				
				
			END FOREACH;
			
			
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
			--SE OBTIENE LAS TRANSACCIONES DE CORRESPONSALES QUE NO FUERON REPORTADAS EN EL ARCHIVO.
			FOREACH WITH HOLD
				SELECT Num_Tarjeta, Cuenta, transacc, Folio_Suc, Monto_Tot, TransacC
				INTO vsTarjeta, vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC
				FROM BdiCheq:Sc_MovHis
				WHERE Empresa = '001'
				AND Cuenta IS NOT NULL
				AND Folio_Suc NOT IN (SELECT Folio325 FROM Intercard:ConAdmIn WHERE ArchivOorigen = NVL(vsArchivoOrigen, '') AND NomArchivo325 = TRIM(NVL(psNomArchivoDeb, '')) AND NomArchivocom = TRIM(NVL(psNomArchivoCom, '')) AND FechaRegistro = CURRENT::DATE)
				AND Sucursal = '5005'
				AND Fech_Alt = vdtFecha -1
				AND Cancelad <> 'S'
                AND transacc not in('0260','3259') --No considera las transacciones de IVA y Comisiones por TDD con Chip
				
				
				LET vsIdTerminal = SUBSTRING(vsFolioSIF FROM 1 FOR 4);
				
				SET ISOLATION TO DIRTY READ ;
				SET LOCK MODE TO WAIT 3;
				--OBTIENE EL PRODUCTO DE LA TARJETA
				SELECT FIRST 1 ProdTarjeta INTO vsProdTarjeta
				FROM BdiCheq:Sc_Tarjeta 
				WHERE Empresa = '001'
				AND Num_Tarjeta = TRIM(vsTarjeta);
				
				LET vsMensajeError = 'OBTENCION DE RISTAS CONTABLES';
				
				SET ISOLATION TO DIRTY READ ;
				SET LOCK MODE TO WAIT 3;
				--OBTIENE LA RISTA CONTABLE DE LA TRANSACCION ACTUAL
				SELECT FIRST 1 TRIM (c_ccmayor) || '-' || TRIM (c_ccsub) || '-' || TRIM (c_ccsubsub) || '-' || TRIM (c_ccsssub) || '-' || TRIM (c_ccssssub) || '-' || TRIM (c_sector) AS CuentaC,
				TRIM (a_ccmayor) || '-' || TRIM (a_ccsub) || '-' || TRIM (a_ccsubsub) || '-' || TRIM (a_ccsssub) || '-' || TRIM (a_ccssssub) || '-' || TRIM (a_sector)  AS CuentaA
				INTO vsCuentaC, vsCuentaA
				FROM BdInteg:Si_ProdTran
				WHERE Empresa = '001'
				AND Producto = vsProdTarjeta
				AND Sistema IS NOT NULL
				AND Transaccion = vsTransacC
				AND Secuencia = 1;
				
				--GUARDA EL REGISTRO EN LA TABLA DE CONCILIACION ADMINISTRATIVA INTERREDES
				INSERT INTO Intercard:ConAdmIn
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
					NVL (vsArchivoOrigen, ''),
					TRIM(NVL (psNomArchivoDeb, '')),
					TRIM(NVL (psNomArchivoCom, '')),
					CURRENT::DATE,
					'D', --DETALLE
					NVL (vdtFecha, CURRENT::DATE),
					NVL (vsProdTarjeta, ''),
					NVL (vsTarjeta, ''),
					NVL (vsCuenta, ''),
					NVL ('', ''),
					NVL ('', ''),
					NVL ('', ''),
					NVL (0, 0.0),
					NVL ('', ''),
					NVL (vsTxnLiberacion, ''),
					NVL (vsCuentaC, ''),
					NVL (vsCuentaA, ''),
					NVL (vsFolioSIF, ''),
					NVL (vmMontoSIF, 0.0),
					NVL ('', ''),
					NVL (0, 0.0),
					--NVL ('1900-01-01 00:00:00', CURRENT),
					NVL (CURRENT, CURRENT),
					NVL (vsIdTerminal, ''),
					NVL ('', ''),
					NVL (psNumEmpleado, '')
				);
				
			END FOREACH;
			
			
			LET vsBinTarjeta = '';
			
			SET ISOLATION TO DIRTY READ ;
			SET LOCK MODE TO WAIT 3;
			--OBTIENE EL BIN DE LAS TARJETAS DE DEBITO
			--SELECT FIRST 1 Bin INTO vsBinTarjeta FROM Intercard:Bines WHERE Prefijo = 'DEB' ;	
            --Ya no se usa frist 1 de BINES ya que requiere traer todos los bines de productos de débito
			
			SET ISOLATION TO DIRTY READ ;
			SET LOCK MODE TO WAIT 3;
			--GUARDA EL REGISTRO EN LA TABLA DE CONCILIACION ADMINISTRATIVA CORRESPONSALES CORRESPONDIENTE A LOS TOTALES DE LAS TRANSACCIONES DE DEBITO
			SELECT SUM (CASE WHEN SecIntercard <> '' THEN 1 ELSE 0 END ) AS TOTAL_REGISTROSIntercard, SUM (CASE WHEN MontoIntcrd > 0.0 THEN MontoIntcrd  ELSE 0.0 END ) AS TOTAL_MONTOIntercard, -- Intercard NO APLICA
			SUM (CASE WHEN FolioSIF <> '' THEN 1 ELSE 0 END ) AS TOTAL_REGISTROSSIF, SUM (CASE WHEN MontoSIF > 0.0 THEN MontoSIF ELSE 0.0 END ) AS TOTAL_MONTOSIF,  -- SIF MOVHIS
			SUM (CASE WHEN Folio325 <> '' THEN 1 ELSE 0 END ) AS TOTAL_REGISTROS325, SUM (CASE WHEN Monto325 > 0.0 THEN Monto325 ELSE 0.0 END ) AS TOTAL_MONTO325  -- 325 CONCORRD
			INTO vsTotal_RegistrosIntercard, vsTotal_MontoIntercard, vsTotal_RegistrosSIF, vsTotal_MontoSIF, vsTotal_Registros325, vsTotal_Monto325 
			FROM Intercard:ConAdmIn 
			WHERE NomArchivo325 MATCHES TRIM(psNomArchivoDeb) || '*'
			AND NomArchivoCom = psNomArchivoCom
			AND TipoOperacion IS NOT NULL
			AND Estatus IS NOT NULL 
			AND TipoRegistro = 'D';
			
			
			INSERT INTO Intercard:ConAdmIn
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
				--Intercard
				SecIntercard,
				MontoIntcrd,
				FechaHoraInAuth,
				IdTerminal,
				TipoOperacion,
				Usuario
			)
			VALUES
			(
				NVL (vsArchivoOrigen, ''),
				TRIM(NVL (psNomArchivoDeb, '')),
				TRIM(NVL (psNomArchivoCom, '')),
				CURRENT::DATE,
				'T', --TOTALES
				NVL (CURRENT::DATE, CURRENT::DATE),
				NVL ('', ''),
				NVL ('', ''),
				NVL ('', ''),
				NVL ('', ''),
				NVL ('', ''),
				NVL (vsTotal_Registros325, ''), -- TOTAL OPERACIONES 325
				NVL (vsTotal_Monto325, 0.0), -- MONTO 325
				NVL ('', ''),
				NVL ('', ''),
				NVL ('', ''),
				NVL ('', ''),
				NVL (vsTotal_RegistrosSIF, ''), -- TOTAL OPERACIONES SIF
				NVL (vsTotal_MontoSIF, 0.0), -- MONTO SIF
				NVL (vsTotal_RegistrosIntercard, ''), -- TOTAL OPERACIONES Intercard
				NVL (vsTotal_MontoIntercard, 0.0), --  MONTO Intercard
				NVL (CURRENT, CURRENT),
				NVL ('', ''),
				NVL ('', ''),
				NVL (psNumEmpleado, '')
			);
			
			---CREDITO-------
			
			LET vsMensajeError = 'OBTIENE NOMBRE DEL ID CON EL QUE SE MANDAN LOS REGISTROS CONCILIADOS A PASO CONCILIA.';
			
			SET ISOLATION TO DIRTY READ ;
			SET LOCK MODE TO WAIT 3;
			--// SE OMITE PORQUE TOMA EN CUENTA TXT EN MAYUSCULAS
			SELECT FIRST 1 IdArchivoCental INTO vsIdArchivoCental FROM Intercard:Central WHERE NombreArchivo matches SUBSTRING( TRIM(psNomArchivoCred) FROM 1 FOR 16)||'*';
			
			--OBTINENE EL TIPO DEL ARCHIVO   --BCPLTCC_
			LET vsArchivoOrigen = SUBSTRING (psNomArchivoCred FROM 5 FOR 3);
			LET vdtFecha = SUBSTRING(psNomArchivoCred FROM 11 FOR 2) || '/' || SUBSTRING(psNomArchivoCred FROM 9 FOR 2) || '/' || SUBSTRING(psNomArchivoCred FROM 13 FOR 4);
			
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
			--OBTIENE TODOS LOS REGISTROS QUE SE MANDARON A APLICAR A LA APLICACION DE SALDOS 
			FOREACH WITH HOLD --Cuenta contiene el folio_mov para corresponsales
			SELECT Tp_Movto, Tran_Central, Cuenta, Monto, bandera_proceso AS Estatus, Documento AS SecuenciaAut
				INTO vsTp_Movto, vsTran_Central, vsFolio325, vmMonto325, vsEstatus, vsSecuenciaAut
				FROM BdiTarjeta:td_concorrp WHERE Empresa = '001' AND Archivo = TRIM(vsIdArchivoCental)
				
				
				LET vsIdTerminal = SUBSTRING(vsFolio325 FROM 1 FOR 4);
				
				SET ISOLATION TO DIRTY READ ;
				SET LOCK MODE TO WAIT 3;
				SELECT FIRST 1 Nro_Tarjeta, Num_Credito, Transacc_Suc, Folio_Suc, Monto, TransacC_Suc
				INTO vsTarjeta, vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC
				FROM Bdicred:Sd_MovHis
				WHERE Empresa = '001'
				AND Num_Credito IS NOT NULL
				AND Folio_Suc = vsFolio325
				AND Sucursal = '5005'
				AND Fecha_Mov = vdtFecha -1
				AND Reversado <> 'S'
				AND transacc_suc='6282'
				AND codigo_fun='700'
				AND codigo_ref=1;
				
				SET ISOLATION TO DIRTY READ ;
				SET LOCK MODE TO WAIT 3;
				--OBTIENE EL PRODUCTO DE LA TARJETA
				SELECT FIRST 1 Prodtarjeta INTO vsProdTarjeta
				FROM Bdicred:Sd_Tarjeta 
				WHERE Empresa = '001'
				AND Num_Tarjeta = TRIM(vsTarjeta);
				
				LET vsMensajeError = 'OBTENCION DE RISTAS CONTABLES';
				
				SET ISOLATION TO DIRTY READ ;
				SET LOCK MODE TO WAIT 3;
				--OBTIENE LA RISTA CONTABLE DE LA TRANSACCION ACTUAL
				SELECT FIRST 1 TRIM (c_ccmayor) || '-' || TRIM (c_ccsub) || '-' || TRIM (c_ccsubsub) || '-' || TRIM (c_ccsssub) || '-' || TRIM (c_ccssssub) || '-' || TRIM (c_sector) AS CuentaC,
				TRIM (a_ccmayor) || '-' || TRIM (a_ccsub) || '-' || TRIM (a_ccsubsub) || '-' || TRIM (a_ccsssub) || '-' || TRIM (a_ccssssub) || '-' || TRIM (a_sector)  AS CuentaA
				INTO vsCuentaC, vsCuentaA
				FROM BdInteg:Si_ProdTran
				WHERE Empresa = '001'
				AND Producto = '6001' --// SE DEJA EL PRODUCTO 6001 FIJO, X QUE EN REPOSICIONES SE COLOCA 0001
				AND Sistema IS NOT NULL
				AND Transaccion = vsTransacC
				AND Secuencia = 1;
				
				--GUARDA EL REGISTRO EN LA TABLA DE CONCILIACION ADMINISTRATIVA INTERREDES
				INSERT INTO Intercard:ConAdmIn
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
					NVL (vsArchivoOrigen, ''),
					TRIM(NVL (psNomArchivoCred, '')),
					TRIM(NVL (psNomArchivoCom, '')),
					CURRENT::DATE,
					'D', --DETALLE
					NVL (vdtFecha, CURRENT::DATE),
					NVL (vsProdTarjeta, ''),
					NVL (vsTarjeta, ''),
					NVL (vsCuenta, ''),
					NVL (vsTp_Movto, ''),
					NVL (vsTran_Central, ''),
					NVL (vsFolio325, ''),
					NVL (vmMonto325, 0.0),
					NVL (vsEstatus, ''),
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
					NVL (psNumEmpleado, '')
				);
				
			END FOREACH;
			
			
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
			
			SET LOCK MODE TO WAIT 3 ;
			SET ISOLATION TO DIRTY READ ;
			--SE OBTIENE LAS TRANSACCIONES DE CORRESPONSALES QUE NO FUERON REPORTADAS EN EL ARCHIVO.
			FOREACH WITH HOLD
				SELECT  Nro_Tarjeta, Num_Credito, Transacc_Suc, Folio_Suc, Monto, TransacC_Suc
				INTO vsTarjeta, vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC
				FROM Bdicred:Sd_MovHis
				WHERE Empresa = '001'
				AND Num_Credito IS NOT NULL
				AND Folio_Suc NOT IN (SELECT Folio325 FROM Intercard:ConAdmIn WHERE ArchivOorigen = NVL(vsArchivoOrigen, '') AND NomArchivo325 = TRIM(NVL(psNomArchivoCred, '')) AND NomArchivocom = TRIM(NVL(psNomArchivoCom, '')) AND FechaRegistro = CURRENT::DATE)
				AND Sucursal = '5005'
				AND Fecha_Mov = vdtFecha -1
				AND Reversado <> 'S'
				AND transacc_suc='6282'
				AND codigo_fun='700'
				AND codigo_ref=1			
				
				LET vsIdTerminal = SUBSTRING(vsFolioSIF FROM 1 FOR 4);
				
				SET ISOLATION TO DIRTY READ ;
				SET LOCK MODE TO WAIT 3;
				--OBTIENE EL PRODUCTO DE LA TARJETA
				SELECT FIRST 1 Prodtarjeta INTO vsProdTarjeta
				FROM Bdicred:Sd_Tarjeta 
				WHERE Empresa = '001'
				AND Num_Tarjeta = TRIM(vsTarjeta);
				
				LET vsMensajeError = 'OBTENCION DE RISTAS CONTABLES';
				
				SET ISOLATION TO DIRTY READ ;
				SET LOCK MODE TO WAIT 3;
				--OBTIENE LA RISTA CONTABLE DE LA TRANSACCION ACTUAL
				SELECT FIRST 1 TRIM (c_ccmayor) || '-' || TRIM (c_ccsub) || '-' || TRIM (c_ccsubsub) || '-' || TRIM (c_ccsssub) || '-' || TRIM (c_ccssssub) || '-' || TRIM (c_sector) AS CuentaC,
				TRIM (a_ccmayor) || '-' || TRIM (a_ccsub) || '-' || TRIM (a_ccsubsub) || '-' || TRIM (a_ccsssub) || '-' || TRIM (a_ccssssub) || '-' || TRIM (a_sector)  AS CuentaA
				INTO vsCuentaC, vsCuentaA
				FROM BdInteg:Si_ProdTran
				WHERE Empresa = '001'
				AND Producto = vsProdTarjeta
				AND Sistema IS NOT NULL
				AND Transaccion = vsTransacC
				AND Secuencia = 1;
				
				INSERT INTO Intercard:ConAdmIn
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
					NVL (vsArchivoOrigen, ''),
					TRIM(NVL (psNomArchivoCred, '')),
					TRIM(NVL (psNomArchivoCom, '')),
					CURRENT::DATE,
					'D', --DETALLE
					NVL (vdtFecha, CURRENT::DATE),
					NVL (vsProdTarjeta, ''),
					NVL (vsTarjeta, ''),
					NVL (vsCuenta, ''),
					NVL ('', ''),
					NVL ('', ''),
					NVL ('', ''),
					NVL (0, 0.0),
					NVL ('', ''),
					NVL (vsTxnLiberacion, ''),
					NVL (vsCuentaC, ''),
					NVL (vsCuentaA, ''),
					NVL (vsFolioSIF, ''),
					NVL (vmMontoSIF, 0.0),
					NVL ('', ''),
					NVL (0, 0.0),
					NVL (CURRENT, CURRENT),
					NVL (vsIdTerminal, ''),
					NVL ('', ''),
					NVL (psNumEmpleado, '')
				);
				
			END FOREACH;
			
			
			
			LET vsBinTarjeta = '';
			
			SET ISOLATION TO DIRTY READ ;
			SET LOCK MODE TO WAIT 3;
			--OBTIENE EL BIN DE LAS TARJETAS DE CREDITO
			--SELECT FIRST 1 Bin INTO vsBinTarjeta FROM Intercard:Bines WHERE Prefijo = 'CRED' ;	
            --Ya no se usa frist 1 de BINES ya que requiere traer todos los bines de productos de débito
			
			SET ISOLATION TO DIRTY READ ;
			SET LOCK MODE TO WAIT 3;
			--GUARDA EL REGISTRO EN LA TABLA DE CONCILIACION ADMINISTRATIVA INTERREDES CORREPONDIENTE A LOS TOTALES DE LAS TRANSACCIONES DE DEBITO
			SELECT SUM (CASE WHEN SecIntercard <> '' THEN 1 ELSE 0 END ) AS TOTAL_REGISTROSIntercard, SUM (CASE WHEN MontoIntcrd > 0.0 THEN MontoIntcrd  ELSE 0.0 END ) AS TOTAL_MONTOIntercard, -- Intercard
			SUM (CASE WHEN FolioSIF <> '' THEN 1 ELSE 0 END ) AS TOTAL_REGISTROSSIF, SUM (CASE WHEN MontoSIF > 0.0 THEN MontoSIF ELSE 0.0 END ) AS TOTAL_MONTOSIF,  -- SIF
			SUM (CASE WHEN Folio325 <> '' THEN 1 ELSE 0 END ) AS TOTAL_REGISTROS325, SUM (CASE WHEN Monto325 > 0.0 THEN Monto325 ELSE 0.0 END ) AS TOTAL_MONTO325  -- 32
			INTO vsTotal_RegistrosIntercard, vsTotal_MontoIntercard, vsTotal_RegistrosSIF, vsTotal_MontoSIF, vsTotal_Registros325, vsTotal_Monto325 
			FROM Intercard:ConAdmIn 
			WHERE NomArchivo325 MATCHES TRIM(psNomArchivoCred) || '*'
			AND NomArchivoCom = psNomArchivoCom
			AND TipoOperacion IS NOT NULL
			AND Estatus IS NOT NULL 
			AND TipoRegistro = 'D';
			
			--VALIDA SI LOS MONTOS SON IGUALES
			IF ((vsTotal_MontoIntercard = vsTotal_MontoSIF) AND (vsTotal_MontoSIF = vsTotal_Monto325)) THEN -- TODO CUADRA (JAMAS PASARA)
			ELIF (vsTotal_MontoIntercard > vsTotal_MontoSIF) THEN  -- EXISTE MAYOR MONTO EN Intercard QUE EL REPORTADO
			ELIF (vsTotal_MontoSIF > vsTotal_MontoIntercard) THEN --EXISTE MAYOR MONTO REPORTADO QUE EL CORRESPONDIENTE PARA EL DIA
			END IF;
			
			INSERT INTO Intercard:ConAdmIn
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
				--Intercard
				SecIntercard,
				MontoIntcrd,
				FechaHoraInAuth,
				IdTerminal,
				TipoOperacion,
				Usuario
			)
			VALUES
			(
				NVL (vsArchivoOrigen, ''),
				TRIM(NVL (psNomArchivoCred, '')),
				TRIM(NVL (psNomArchivoCom, '')),
				CURRENT::DATE,
				'T', --TOTALES
				NVL (CURRENT::DATE, CURRENT::DATE),
				NVL ('', ''),
				NVL ('', ''),
				NVL ('', ''),
				NVL ('', ''),
				NVL ('', ''),
				NVL (vsTotal_Registros325, ''), -- TOTAL OPERACIONES 325
				NVL (vsTotal_Monto325, 0.0), -- MONTO 325
				NVL ('', ''),
				NVL ('', ''),
				NVL ('', ''),
				NVL ('', ''),
				NVL (vsTotal_RegistrosSIF, ''), -- TOTAL OPERACIONES SIF
				NVL (vsTotal_MontoSIF, 0.0), -- MONTO SIF
				NVL (vsTotal_RegistrosIntercard, ''), -- TOTAL OPERACIONES Intercard
				NVL (vsTotal_MontoIntercard, 0.0), --  MONTO Intercard
				NVL (CURRENT, CURRENT),
				NVL ('', ''),
				NVL ('', ''),
				NVL (psNumEmpleado, '')
			);
			
		END IF;
		
		
		
		LET vsIdTerminal = '';
		LET vmMonto = 0.0;
		LET vmComision = 0.0;
		LET vmIvaComision = 0.0;
		
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
		
		SET LOCK MODE TO WAIT  ;
		SET ISOLATION TO DIRTY READ ;
		
		--CARGA DE DATOS A TABLA TEMPORAL PARA GENERAR EL ARCHIVO DE COMISIONES.  --DEBITO
		FOREACH SELECT IdTerminal, SUM(Monto325), SUM (v_ComisionTCD) AS COMISION, SUM(v_ComisionTCD * (v_IVATCD / 100)) AS IVACOMISION
			INTO vsIdTerminal, vmMonto, vmComision, vmIvaComision
			FROM Intercard:ConAdmIn 
			WHERE NomArchivo325 MATCHES TRIM(psNomArchivoDeb) || '*'
			AND NomArchivoCom = psNomArchivoCom
			AND Monto325 > 0.0
			AND TipoRegistro = 'D'
			GROUP BY IdTerminal
			
			INSERT INTO Intercard:tmp_conciliacion_corr(IdTerminal, Fechamov, Monto, Comision, ComisionIva)
			VALUES (vsIdTerminal, pdtFechaReg - 1, vmMonto, vmComision, vmIvaComision);
			
		END FOREACH;
		
		
		IF (TRIM(NVL(psNomArchivoCred, '')) <> 'TPD') THEN --SOLO CORRESPONSALES
			LET vsIdTerminal = '';
			LET vmMonto = 0.0;
			LET vmComision = 0.0;
			LET vmIvaComision = 0.0;
			
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
			
			SET LOCK MODE TO WAIT 3 ;
			SET ISOLATION TO DIRTY READ ;
			--CARGA DE DATOS A TABLA TEMPORAL PARA GENERAR EL ARCHIVO DE COMISIONES. --CREDITO
			FOREACH SELECT IdTerminal, SUM(Monto325), SUM(v_ComisionTCC) AS COMISION, SUM((v_ComisionTCC) * (v_IVATCC/100)) AS IVACOMISION
				INTO vsIdTerminal, vmMonto, vmComision, vmIvaComision
				FROM Intercard:ConAdmIn 
				WHERE NomArchivo325 MATCHES TRIM(psNomArchivoCred) || '*'
				AND NomArchivoCom = psNomArchivoCom
				AND Monto325 > 0.0
				AND TipoRegistro = 'D'
				GROUP BY IdTerminal
				
				
				INSERT INTO Intercard:tmp_conciliacion_corr(IdTerminal, Fechamov, Monto, Comision, ComisionIva)
				VALUES (vsIdTerminal, pdtFechaReg - 1, vmMonto, vmComision, vmIvaComision);
				
			END FOREACH;
			
		END IF;
		
		--END IF;
		
		EXECUTE PROCEDURE Intercard:sp_ObtenerNombreArchivo (DECODE(vsFlagCorresponsales, 'V',71/*CORR*/,72/*TPD*/)) INTO vsNomArchivoAUX, vsRuta_Repositorio_AIXAUX, vsArchivoOrigenAUX, vsRuta_Repositorio_WINAUX;
		
		--TOTALIZA LOS REGISTROS Y LOS PASA A UNA SEGUNDA TABLA TEMPORAL
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
		
		SET LOCK MODE TO WAIT 3 ;
		SET ISOLATION TO DIRTY READ ;
		FOREACH WITH HOLD
			SELECT idterminal,fechamov,SUM(monto),SUM(comision),SUM(comisioniva)
			INTO v_Terminal, v_FechaConciliacion, v_Monto, v_MontoComision, v_MontoIva
			FROM Intercard:tmp_conciliacion_corr
			GROUP BY idterminal,fechamov
			
			--- cambiar la tabla  tmp_conciliacion2 por la  ConArchcomisiones
			INSERT INTO Intercard:ConArchcomisiones(ArchivoOrigen, NomArchivocom, IdTerminal, Fechamov, Monto, Comision, ComisionIva,fisico)
			VALUES (vsArchivoOrigenAUX, psNomArchivoCom, v_Terminal, v_FechaConciliacion, v_Monto, v_MontoComision, v_MontoIva,'');
		
			
		END FOREACH;
		
		
		---  SE ACTUALIZA LA FECHA DE LOS MOVIMIENTOS A UN DIA ANTERIOR AL DE LA FECHA DE HOY
		UPDATE Intercard:ConArchcomisiones SET fechamov = TODAY - 1 WHERE ArchivoOrigen = vsArchivoOrigenAUX AND NomArchivocom = psNomArchivoCom AND Fechamov IS NOT NULL;
		
		SET ISOLATION TO DIRTY READ ;
		SET LOCK MODE TO WAIT 3;
		SELECT COUNT(*) INTO v_TotReg FROM Intercard:ConArchcomisiones WHERE ArchivoOrigen = vsArchivoOrigenAUX AND NomArchivocom = psNomArchivoCom AND Fechamov IS NOT NULL;
		
		INSERT INTO Intercard:ConArchcomisiones(ArchivoOrigen, NomArchivocom, IdTerminal, Fechamov, Monto, Comision, ComisionIva,fisico)
		VALUES (vsArchivoOrigenAUX, psNomArchivoCom, "0000", TODAY - 1, v_TotReg, 0.0, 0.0,'');
		
	END IF;
	
	IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames  WHERE tabname = 'tmp_conciliacion_corr' AND dbsname= 'intercard') THEN
		DROP TABLE Intercard:tmp_conciliacion_corr;
	END IF;
	
	RETURN vsCodRetorno, v_TotReg, vsMensajeError;
	
END;

END PROCEDURE
/*DOCUMENT
'AUTOR: Rochin Rocha Edgar Ivan',
'Proyecto: Conciliacion Automatica',
'Descripcion: Consulta de administracion de corresponsales, obtiene informacion de tabla conarchcomisiones.',
'Fecha: 04/26/2010',
'Version: 20100426.1025',
'BD: Intercard',
'',
'MODIFICO: Casanova Edeza Hector Juan',
'Proyecto: Conciliacion Automatica',
'Descripcion: Se corrige el nombre del archivo con el que se registran las transacciones de pago no reportadas en el archivo.',
'Fecha: 06/03/2010',
'Version: 20100603.0940',
'BD: Intercard',
'',
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: TRANSFERENCIA DE PRESTAMOS COPPEL',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agrega la funcionalidad de la conciliacion administrativa para el archivo de TPD.',
'Fecha: 2011/05/26',
'Version: 20110526.1700',
'BD: Intercard'; */                                                                                                                                                                                                                                                  ;

CREATE PROCEDURE "informix".sp_consultaconadmin(
psArchivoOrigen CHAR(3),
pdFecha DATE
)

RETURNING	CHAR(3) AS archivoorigen, CHAR(23) AS nomarchivo325, CHAR(23) AS nomarchivocom, DATE AS fecharegistro, DATE AS fecha, CHAR(4) AS prodtarjeta, CHAR(16) AS tarjeta,
			CHAR(12) AS cuenta, CHAR(1) AS tipomov, CHAR(4) AS tran_central, CHAR(15) AS folio325, MONEY(16,6) AS monto325, CHAR(1) AS estatus, CHAR(4) AS txnliberacion, CHAR(19) AS cuentac,
			CHAR(19) AS cuentaa, CHAR(15) AS foliosif, MONEY(16,6) AS montosif, CHAR(7) AS secintercard, MONEY(16,6) AS montointcrd, DATETIME YEAR TO FRACTION(5) AS fechahorainauth, CHAR(4) AS idterminal,
			CHAR(1) AS tipooperacion, CHAR(8) AS usuario, DATETIME YEAR TO FRACTION(5) AS fechamov, MONEY(16,6) AS monto, MONEY(16,6) AS comision, MONEY(16,6) AS comisioniva;

--****************************************************************************************************
-- DESCRIPCION: Consulta de administracion de interredes, obtiene informacion de tabla conadmin y conarchcomisiones.
-- AUTOR : Rochin Rocha Edgar Ivan 
-- FECHA : 01/19/2010
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica
--****************************************************************************************************
--DECLARA VARIABLES
DEFINE vsarchivoorigen		CHAR(3);
DEFINE vsnomarchivo325		CHAR(23);
DEFINE vsnomarchivo			CHAR(23);
DEFINE vsnomarchivocom		CHAR(23);
DEFINE vdfecharegistro		DATE;
DEFINE vdfecha				DATE;
DEFINE vsprodtarjeta		CHAR(4);
DEFINE vstarjeta			CHAR(16);
DEFINE vscuenta				CHAR(12);
DEFINE vstipomov			CHAR(1);
DEFINE vstran_central		CHAR(4);
DEFINE vsfolio325			CHAR(15);
DEFINE vmmonto325			MONEY(16,6);
DEFINE vsestatus			CHAR(1);
DEFINE vstxnliberacion		CHAR(4);
DEFINE vscuentac			CHAR(19);
DEFINE vscuentaa			CHAR(19);
DEFINE vsfoliosif			CHAR(15);
DEFINE vmmontosif			MONEY(16,6);
DEFINE vssecintercard		CHAR(7);
DEFINE vmmontointcrd		MONEY(16,6);
DEFINE vdfechahorainauth	DATETIME YEAR TO FRACTION(5);
DEFINE vsidterminal			CHAR(4);
DEFINE vstipooperacion		CHAR(1);
DEFINE vsusuario			CHAR(8);

DEFINE vdfechamov			DATETIME YEAR TO FRACTION(5);
DEFINE vmmonto				MONEY(16,6);
DEFINE vmcomision			MONEY(16,6);
DEFINE vmcomisioniva		MONEY(16,6);


DEFINE viSqlErr				INTEGER;

--INICIA VARIABLES
LET vsarchivoorigen = '';
LET vsnomarchivo325 = '';
LET vsnomarchivo	= '';
LET vsnomarchivocom = '';
LET vdfecharegistro = CURRENT;
LET vdfecha = CURRENT;
LET vsprodtarjeta = '';
LET vstarjeta = '';
LET vscuenta = '';
LET vstipomov = '';
LET vstran_central = '';
LET vsfolio325 = '';
LET vmmonto325 = 0.0;
LET vsestatus = '';
LET vstxnliberacion = '';
LET vscuentac = '';
LET vscuentaa = '';
LET vsfoliosif = '';
LET vmmontosif = 0.0;
LET vssecintercard = '';
LET vmmontointcrd = 0.0;
LET vdfechahorainauth = CURRENT;
LET vsidterminal = '';
LET vstipooperacion = '';
LET vsusuario = '';

LET vdfechamov = CURRENT;
LET vmmonto = 0.0;
LET vmcomision = 0.0;
LET vmcomisioniva = 0.0;

LET viSqlErr = 0;

--set debug file to "/informixuc7/perifericos/prueba.out";
--Trace on;

BEGIN

ON EXCEPTION SET viSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
	RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
		   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vssecintercard, vmmontointcrd, vdfechahorainauth, vsidterminal, vstipooperacion, vsusuario, '', '', '', '' WITH RESUME;
	END IF; 
END EXCEPTION ;

SET ISOLATION TO DIRTY READ ;
SET LOCK MODE TO WAIT 3;
--Verifica si el parametro archivo origen fue proporcionado en blanco o nulo.
IF(psArchivoOrigen = "") OR (psArchivoOrigen IS NULL)THEN
	--El campo archivo origen esta en blanco o nulo.
	LET vsarchivoorigen = '001';
	RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
		   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vssecintercard, vmmontointcrd, vdfechahorainauth, vsidterminal, vstipooperacion, vsusuario, '', '', '', '';
--Verifica si el parametro fecha fue proporcionado en blanco o nulo.
ELIF(pdFecha = "") OR (pdFecha IS NULL)THEN
	--El campo fecha esta en blanco o nulo.
	LET vsarchivoorigen = '002';
	RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
		   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vssecintercard, vmmontointcrd, vdfechahorainauth, vsidterminal, vstipooperacion, vsusuario, '', '', '', '';
ELSE
	--Verifica si el archivoorigen proporcionado fue archivo de comisiones(ADC).
	IF(psArchivoOrigen = 'ADC')THEN
        LET pdFecha = MDY(Month(pdFecha),day(pdFecha),year(pdFecha)) -1 units day;
        FOREACH
		SELECT idterminal, fechamov, monto, comision, comisioniva
		INTO   vsidterminal, vdfechamov, vmmonto, vmcomision, vmcomisioniva
		FROM   intercard:conarchcomisiones
        WHERE  fechamov::DATE = pdFecha ORDER BY keyx ASC
		RETURN '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
			   NVL(vsidterminal,''), '', '', NVL(vdfechamov,CURRENT), NVL(vmmonto,0.0), NVL(vmcomision,0.0), NVL(vmcomisioniva,0.0) WITH RESUME;
		END FOREACH
	ELSE
		IF (psArchivoOrigen = 'TCD') THEN
			LET vsnomarchivo = TRIM ('BCPLTCD_' || LPAD(day(pdFecha),2,'0') || LPAD(Month(pdFecha),2,'0') || year(pdFecha) || '.TXT');
		ELSE
			LET vsnomarchivo = TRIM ('BCPLTCC_' || LPAD(day(pdFecha),2,'0') || LPAD(Month(pdFecha),2,'0') || year(pdFecha) || '.TXT');
		END IF;	
	
		FOREACH
		SELECT {+index (intercard:conadmin idx_conadmin4)} archivoorigen, nomarchivo325, nomarchivocom, fecharegistro, fecha, prodtarjeta, tarjeta, cuenta, tipomov, tran_central, folio325, monto325, estatus, txnliberacion,
			   cuentac, cuentaa, foliosif, montosif, secintercard, montointcrd, fechahorainauth, idterminal, tipooperacion, usuario
		INTO   vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
			   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vssecintercard, vmmontointcrd, vdfechahorainauth, vsidterminal, vstipooperacion, vsusuario
		FROM   intercard:conadmin
		WHERE  archivoorigen = psArchivoOrigen and nomarchivo325 = vsnomarchivo ORDER BY keyx ASC

		RETURN vsarchivoorigen, vsnomarchivo325, vsnomarchivocom, vdfecharegistro, vdfecha, vsprodtarjeta, vstarjeta, vscuenta, vstipomov, vstran_central, vsfolio325,
			   vmmonto325, vsestatus, vstxnliberacion, vscuentac, vscuentaa, vsfoliosif, vmmontosif, vssecintercard, vmmontointcrd, vdfechahorainauth, vsidterminal, vstipooperacion, vsusuario, '', '', '', '' WITH RESUME;
               
        END FOREACH
	END IF;
END IF;

END
END PROCEDURE
/*DOCUMENT
'AUTOR: Rochin Rocha Edgar Ivan',
'Proyecto: Conciliacion Automatica',
'Descripcion: Consulta de administracion de interredes, obtiene informacion de tabla conadmin y conarchcomisiones.',
'Fecha: 01/19/2010',
'Version: 20100119.1025',
'BD: Intercard',
'',
'Modificado: Rochin Rocha Edgar Ivan',
'Proyecto: Conciliacion Automatica',
'Descripcion: En caso de que se consulte por archivo de comisiones(ADC) realizara la busqueda en tabla conarchcomisiones.',
'Fecha: 02/05/2010',
'Version: 20100205.1745',
'BD: Intercard''',
'Modificado: Javier Chavez BANCOPPEL',
'Proyecto: Conciliacion Automatica',
'Descripcion: Le dan formato al parametro de fecha justo despues de validar si es consulta por archivo de comisiones(ADC).Cambian el between por una comparacion simple entre la fechamov y el parametro de entrada fecha(esto solo lo realizaron en caso de ser ADC).',
'Fecha: 02/19/2010',
'Version: 20100219.1645',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de las variables de NombreArchivo a 23 caracteres.',
'Fecha: 2010/04/14',
'Version: 20100414.1137',
'BD: Intercard',
'',
'Modificado: Ponce Damian Juan Fco.',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Solicito: Luis Antonio Gomez',
'Descripcion: Se modifica la consulta de interredes para su optización.',
'Fecha: 2012/07/11',
'Version: 20120711.1730',
'BD: Intercard'*/
;

CREATE PROCEDURE "informix".sp_interepor(pcodgironeg varchar(1),pidreceptor varchar(40),paniome varchar(6))
RETURNING varchar(6), varchar(80);
----------Variables-------------------------------
DEFINE  error_info              varchar(80);
DEFINE  isam_err                integer;
DEFINE  vsqlerr                 integer;
DEFINE  vcodret                 varchar(6);
DEFINE  p_mensaje               varchar(80);
DEFINE  vsql                    char(1150);
DEFINE  vcodgironegs            varchar(1);
DEFINE  vinfreceptor            varchar(40);
DEFINE  vaniomes                varchar(6);


-------------- control de errores---------

--SET DEBUG FILE TO "/informix/resplogifx/interepor.out";
--TRACE ON;

BEGIN 
 ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr <> 0 then
                let vcodret = vsqlerr;
                let p_mensaje = error_info;
                  RETURN vcodret, p_mensaje;
            END IF;
 END EXCEPTION; 
 
ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr = -958  then	
                  if error_info ='informix.pasoprincipal' then
				     drop table pasoprincipal;
				  end if			
	              if error_info ='informix.paso2' then
				     drop table paso2;
				  end if			   
                  if error_info ='informix.paso3' then
				     drop table paso3;					  
				  end if
				  if error_info ='informix.paso_nego' then
				     drop table paso_nego;					  
				  end if
				   if error_info ='informix.paso_estab' then
				     drop table paso_estab;					  
				  end if
				  if error_info ='informix.paso_camp' then
				     drop table paso_camp;
				  end if		     
				  				   
		    END IF;    
 END EXCEPTION WITH RESUME;
    

LET  vcodgironegs = pcodgironeg;   
LET  vinfreceptor = pidreceptor; 
LET  vaniomes = paniome;


-------Cuerpo de SP Consulta Seguimiento a Campaña.
  IF (vcodgironegs = '' and vinfreceptor = '' and  vaniomes = '' )THEN
 
      EXECUTE PROCEDURE intercard:sp_reportenegocio() INTO vcodret,p_mensaje;
	  
	    return vcodret, p_mensaje;
	
	ELIF ((vcodgironegs is not null) and (vinfreceptor is not null) and ( vaniomes  is not null) ) THEN
	
	  EXECUTE PROCEDURE intercard:sp_segcamp (vcodgironegs,vinfreceptor,vaniomes) INTO vcodret,p_mensaje;

        return vcodret, p_mensaje;
	  
  ELSE
    LET vcodret = '0003';
    LET  p_mensaje  = 'Existe un error';
    return vcodret, p_mensaje;
	 
  END IF;
end;
END PROCEDURE;