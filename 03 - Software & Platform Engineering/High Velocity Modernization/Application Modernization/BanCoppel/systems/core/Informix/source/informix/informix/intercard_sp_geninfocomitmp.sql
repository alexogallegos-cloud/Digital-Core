CREATE PROCEDURE "informix".sp_geninfocomitmp(psNomArchivoCom CHAR(21), psNomArchivoCred CHAR(20), psNomArchivoDeb CHAR(20), pdtFechaReg DATE)
RETURNING CHAR(5) AS Respuesta; 


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
DEFINE vsNomArchivo VARCHAR (21) ;
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
DEFINE vsArchivo			CHAR(21);
DEFINE vsSQL				CHAR (2204);
DEFINE vsSQL1				CHAR(100);
DEFINE vsSQL2 				CHAR(1004);
DEFINE vsSQL3 				CHAR(100);
DEFINE vsSQL4				CHAR(100);
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
DEFINE vsCodRetorno2		CHAR(5);
DEFINE vsRespcomi			CHAR(5);
DEFINE v_BandBA				CHAR(1);
--DEFINE vsMensaje			CHAR (500);
--DEFINE viBitacora			INTEGER;





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

BEGIN
		ON EXCEPTION
		
		SET iSqlErr, iSamErr
		IF iSqlErr <> 0 THEN
				LET vsCodRetorno = iSqlErr;
		END IF;
		RETURN vsCodRetorno;
        END EXCEPTION;

	--- OBTENER EL PARAMETRO DEL VALOR DE LA COMISION DE TARJETA COPPEL DEBITO EN MN
		SELECT FIRST 1 TRIM(valor)
		INTO v_ComisionTCD
		FROM param_conciliacionauto 
		WHERE descripcion = "COMISION TARJETA COPPEL DEBITO";
		
		--- OBTENER EL PARAMETRO DEL PORCENTAJE DE LA COMISION DE TARJETA COPPEL CREDITO
		SELECT FIRST 1 TRIM(valor)
		INTO v_ComisionTCC
		FROM param_conciliacionauto 
		WHERE descripcion = "% COMI. TARJETA COPPEL CREDITO";
		
		LET v_ComisionTCC = v_ComisionTCC / 100;
		
		--- OBTENER EL PARAMETRO DEL VALOR DEL IVA DE TARJETA COPPEL DEBITO 
		SELECT FIRST 1 TRIM(valor)
		INTO v_IVATCD
		FROM  param_conciliacionauto 
		WHERE descripcion = "% IVA TARJETA COPPEL DEBITO";
		
		--- OBTENER EL PARAMETRO DEL VALOR DEL IVA DE TARJETA COPPEL CREDITO 
		SELECT FIRST 1 TRIM(valor)
		INTO v_IVATCC
		FROM  param_conciliacionauto 
		WHERE descripcion = "% IVA TARJETA COPPEL CREDITO";

		LET vsIdTerminal = '';
		LET vmMonto = 0.0;
		LET vmComision = 0.0;
		LET vmIvaComision = 0.0;

		--SUM(ci.monto_comision) AS montocomision, SUM(ci.monto_comision * (ci.iva / 100)) AS montoiva
		--CARGA DE DATOS A TABLA TEMPORAL PARA GENERAR EL ARCHIVO DE COMISIONES.  --DEBITO
		FOREACH SELECT IdTerminal, SUM(Monto325), SUM (v_ComisionTCD) AS COMISION, SUM(v_ComisionTCD * (v_IVATCD / 100)) AS IVACOMISION
			INTO vsIdTerminal, vmMonto, vmComision, vmIvaComision
			FROM InterCard:ConAdmIn 
			WHERE NomArchivo325 = psNomArchivoDeb
			AND NomArchivoCom = psNomArchivoCom
			AND TipoOperacion = 'C'
			AND Estatus IN ('C', 'A')
			AND TipoRegistro = 'D'
			GROUP BY IdTerminal
			
                INSERT INTO Intercard:tmp_conciliacion(IdTerminal, Fechamov, Monto, Comision, ComisionIva)
                VALUES (vsIdTerminal, pdtFechaReg - 1, vmMonto, vmComision, vmIvaComision);
		
        END FOREACH;
		
		LET vsIdTerminal = '';
		LET vmMonto = 0.0;
		LET vmComision = 0.0;
		LET vmIvaComision = 0.0;
		
		--CARGA DE DATOS A TABLA TEMPORAL PARA GENERAR EL ARCHIVO DE COMISIONES.  --DEBITO ( SIN COMISION      -- CASH BACK) 
		FOREACH SELECT IdTerminal, SUM(Monto325), 0, 0
			INTO vsIdTerminal, vmMonto, vmComision, vmIvaComision
			FROM InterCard:ConAdmIn 
			WHERE NomArchivo325 = psNomArchivoDeb
			AND NomArchivoCom = psNomArchivoCom
			AND TipoOperacion = 'B'
			AND Estatus IN ('C', 'A')
			AND TipoRegistro = 'D'
			GROUP BY IdTerminal
			
                INSERT INTO Intercard:tmp_conciliacion(IdTerminal, Fechamov, Monto, Comision, ComisionIva)
                VALUES (vsIdTerminal, pdtFechaReg - 1, vmMonto, vmComision, vmIvaComision);
		
		END FOREACH;
		
		LET vsIdTerminal = '';
		LET vmMonto = 0.0;
		LET vmComision = 0.0;
		LET vmIvaComision = 0.0;
		
		--CARGA DE DATOS A TABLA TEMPORAL PARA GENERAR EL ARCHIVO DE COMISIONES. --CREDITO
		FOREACH SELECT IdTerminal, SUM(Monto325), SUM( v_ComisionTCC * (Monto325)) AS COMISION, SUM((v_ComisionTCC * (Monto325)) * (v_IVATCC/100)) AS IVACOMISION
			INTO vsIdTerminal, vmMonto, vmComision, vmIvaComision
			FROM InterCard:ConAdmIn 
			WHERE NomArchivo325 = psNomArchivoCred
			AND NomArchivoCom = psNomArchivoCom
			AND TipoOperacion = 'C'
			AND Estatus IN ('C', 'A')
			AND TipoRegistro = 'D'
			GROUP BY IdTerminal
			
                INSERT INTO Intercard:tmp_conciliacion(IdTerminal, Fechamov, Monto, Comision, ComisionIva)
                VALUES (vsIdTerminal, pdtFechaReg - 1, vmMonto, vmComision, vmIvaComision);
		
		END FOREACH;
		
		LET vsIdTerminal = '';
		LET vmMonto = 0.0;
		LET vmComision = 0.0;
		LET vmIvaComision = 0.0;
		
		--CARGA DE DATOS A TABLA TEMPORAL PARA GENERAR EL ARCHIVO DE COMISIONES. --CREDITO
		FOREACH SELECT IdTerminal, SUM(Monto325), 0, 0
			INTO vsIdTerminal, vmMonto, vmComision, vmIvaComision
			FROM InterCard:ConAdmIn 
			WHERE NomArchivo325 = psNomArchivoCred
			AND NomArchivoCom = psNomArchivoCom
			AND TipoOperacion = 'B'
			AND Estatus IN ('C', 'A')
			AND TipoRegistro = 'D'
			GROUP BY IdTerminal
			
                INSERT INTO Intercard:tmp_conciliacion(IdTerminal, Fechamov, Monto, Comision, ComisionIva)
                VALUES (vsIdTerminal, pdtFechaReg - 1, vmMonto, vmComision, vmIvaComision);
		
		END FOREACH;
		
		
		--TOTALIOZA LOS REGISTROS Y LOS PASA A UNA SEGUNDA TABLA TEMPORAL
		SET ISOLATION TO DIRTY READ;
		FOREACH WITH HOLD
			SELECT idterminal,fechamov,SUM(monto),SUM(comision),SUM(comisioniva)
			INTO v_Terminal, v_FechaConciliacion, v_Monto, v_MontoComision, v_MontoIva
			FROM tmp_conciliacion
			GROUP BY idterminal,fechamov
			
			--- cambiar la tabla  tmp_conciliacion2 por la  ConArchcomisiones

                INSERT INTO Intercard:ConArchcomisiones(NomArchivocom, IdTerminal, Fechamov, Monto, Comision, ComisionIva,fisico)
                VALUES (psNomArchivoCom, v_Terminal, v_FechaConciliacion, v_Monto, v_MontoComision, v_MontoIva,'');

    
		END FOREACH
		
		---  SE ACTUALIZA LA FECHA DE LOS MOVIMIENTOS A UN DIA ANTERIOR AL DE LA FECHA DE HOY

            UPDATE intercard:conarchcomisiones SET fechamov = TODAY - 1 WHERE NomArchivocom = psNomArchivoCom AND Fechamov IS NOT NULL;

            SELECT COUNT(*) INTO v_TotReg FROM intercard:conarchcomisiones WHERE NomArchivocom = psNomArchivoCom AND Fechamov IS NOT NULL;

            INSERT INTO intercard:conarchcomisiones(NomArchivocom, IdTerminal, Fechamov, Monto, Comision, ComisionIva,fisico)
            VALUES (psNomArchivoCom, "0000", TODAY - 1, v_TotReg, 0.0, 0.0,'');
        
	RETURN vsCodRetorno;
END;

END PROCEDURE;