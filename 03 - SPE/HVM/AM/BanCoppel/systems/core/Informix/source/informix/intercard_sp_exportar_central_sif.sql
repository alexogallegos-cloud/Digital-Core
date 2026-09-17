CREATE PROCEDURE "informix".sp_exportar_central_sif ( psArchivoOrigen CHAR (3), psNomArchivo CHAR(30))
RETURNING INTEGER AS CodRetorno, CHAR (13)  AS NomArchivo, INTEGER AS TotalRegistros ;

--****************************************************************************************************
-- DESCRIPCION: PASA LOS DATOS DE LA CONCILIACION INTERCARD A LA CONCILIACION SIF
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 03/06/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO : 15/01/2010 Se modifico la logica de consulta de los selects para que tome en consideracion el campo NombreArchivo.
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsArchivoOrigen CHAR (3) ;
DEFINE vsBin CHAR (6);
DEFINE vsParamSucursal CHAR (3);
DEFINE vsUsuario CHAR (8);

DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER;

DEFINE viTipoMovA INTEGER ;
DEFINE viTipoMovC INTEGER ;
DEFINE viTipoMovR INTEGER ;

DEFINE viKeyx INTEGER;
DEFINE vsIdArchivoCentral CHAR (13);
DEFINE vsDoctoOrig CHAR (7) ;
DEFINE vsDocumento CHAR (16) ;
DEFINE vsFolioOrig CHAR (16) ;
DEFINE vsFolioSucursal CHAR (16) ;
DEFINE vsIdent_Det CHAR (1) ;
DEFINE vmImporte MONEY ;
DEFINE vsMoneda CHAR (3) ;
DEFINE vmMontoOriginal MONEY ;
DEFINE vsNumTarjeta CHAR (16) ;
DEFINE vsReferencia CHAR (40) ;
DEFINE vsRefTransaccion CHAR (23) ;
DEFINE vsRFC CHAR (16) ;
DEFINE vsSucursal CHAR (4) ;
DEFINE vsTipoMov CHAR (1) ;
DEFINE vsTransaccion CHAR (4) ;
DEFINE vsTransaccionOrig CHAR (4) ;
DEFINE vsDivisa CHAR (3) ;
DEFINE vmMontoDivisa MONEY ;
DEFINE vsNumCajero CHAR (14) ;
DEFINE vsConvenio CHAR (10) ;
DEFINE vsTipoTransInterEmpresa CHAR (4) ;
DEFINE vmMontoComInterEmpresa MONEY ;
DEFINE vsFormadePago CHAR (1) ;
DEFINE vsControl CHAR (1) ;

DEFINE vdtFechaConciliacion DATETIME YEAR TO FRACTION ;
DEFINE vdtFechaConciliacion2 DATETIME YEAR TO FRACTION ;
DEFINE viContadorArchivo INTEGER ;
DEFINE vsFechaAuxiliar CHAR (30) ;

DEFINE vsFlag CHAR (1);


DEFINE viAux INTEGER;

DEFINE viContadorReg INTEGER ;
DEFINE visqlerr INTEGER ;
/* INICIALIZACION DE VARIABLES */
LET vsArchivoOrigen = '' ;
LET vsBin = '' ;
LET vsParamSucursal = '' ;
LET vsUsuario = '' ;

LET vsFlagEnTransaccion = '';
LET viContadorRegistros = 0;

LET viTipoMovA = 0 ;
LET viTipoMovC = 0 ;
LET viTipoMovR  = 0 ;

LET viKeyx = 0;
LET vsIdArchivoCentral = '' ;
LET vsDoctoOrig = '' ;
LET vsDocumento = '' ;
LET vsFolioOrig = '' ;
LET vsFolioSucursal = '' ;
LET vsIdent_Det  = '' ;
LET vmImporte   = 0.0 ;
LET vsMoneda = '' ;
LET vmMontoOriginal = 0.0 ;
LET vsNumTarjeta = '' ;
LET vsReferencia = '' ;
LET vsRefTransaccion = '' ;
LET vsRFC = '' ;
LET vsSucursal = '' ;
LET vsTipoMov = '' ;
LET vsTransaccion = '' ;
LET vsTransaccionOrig = '' ;
LET vsDivisa = '' ;
LET vmMontoDivisa = 0.0 ;
LET vsNumCajero  = '' ;
LET vsConvenio  = '' ;
LET vsTipoTransInterEmpresa = '' ;
LET vmMontoComInterEmpresa = 0.0 ;
LET vsFormadePago = '' ;
LET vsControl = '' ;

LET vdtFechaConciliacion = CURRENT ;
LET vdtFechaConciliacion2 = CURRENT ;
LET viContadorArchivo = 0 ;
LET vsFechaAuxiliar = '' ;

LET vsFlag = 'F';

LET viAux = 0;

LET viContadorReg = 0 ;
LET visqlerr = 0 ;
BEGIN

	ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
		IF visqlerr <> 0 THEN             
			
			-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
			IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
			END IF;
			
			
			EXECUTE PROCEDURE Intercard:sp_Insertar_Bitacora( 'CONAUT', psArchivoOrigen, 'EXPORTAR CENTRAL' , 'ERROR DE INFORMIX NO CONTROLADO (' || visqlerr || ')') INTO visqlerr ;
			--ROLLBACK WORK ;
			DELETE FROM bditarjeta:td_pasoconcilia WHERE FileName = vsIdArchivoCentral ; 
			
			RETURN visqlerr, vsIdArchivoCentral, viContadorReg  ;
			
		END IF; 
	END EXCEPTION;

	ON EXCEPTION IN (-535)
		EXECUTE PROCEDURE Intercard:sp_Insertar_Bitacora ( '00000', '000',  'sp_exportar_central_sif', 'ERROR (-535) SE DEJO UNA TRANSACCION ABIERTA EN OTRO PROCESO.' ) INTO viAux; 
		LET vsFlagEnTransaccion = 'V';
	END EXCEPTION WITH RESUME;
	

	--SET DEBUG FILE TO '/tmp/conciliacion/TraceConciliacionEXPORTAR.txt';
	--TRACE ON ;
	--BCPLTPD_  --TPD TRANSFERENCIAS 

	
	
	IF ((psArchivoOrigen = 'TPD' ) AND (EXISTS (SELECT Valor FROM Intercard:Param_ConciliacionAuto WHERE Descripcion = 'NOMBRE_ARCHIVO' AND Valor MATCHES 'BCPLTPD_*'))) THEN
		LET vsArchivoOrigen = psArchivoOrigen; --DEJA EL MISMO ARCHIVO ORIGEN 
		LET vsFlag = 'F';
	ELIF ( (psArchivoOrigen = 'TPC' ) OR (psArchivoOrigen = 'TPD' ) ) THEN  --PERTENECEN A TMP
		LET vsArchivoOrigen = 'TMP' ; --cambia el TPC Y PTD por el TMP
		LET vsFlag = 'V';
	ELSE
		LET vsArchivoOrigen = psArchivoOrigen; --deja el mismo archivo origen 
		LET vsFlag = 'F';
	END IF ;

	--obtiene la fecha del ultimo registro conciliado
	
	--SET ISOLATION TO DIRTY READ ;
	--SELECT MAX (FechaConciliacion) INTO vdtFechaConciliacion FROM Intercard:Central WHERE ArchivoOrigen = vsArchivoOrigen ;
	
	LET vdtFechaConciliacion = SUBSTRING (CURRENT FROM 1 FOR 10 ) || ' 00:00:00';
	LET vdtFechaConciliacion2 = CURRENT + Interval(1) day to day;
	LET vdtFechaConciliacion2 = SUBSTRING (vdtFechaConciliacion2 FROM 1 FOR 10 ) || ' 00:00:00';
	
	
	/*SELECT COUNT (KeyX) INTO viContadorArchivo FROM Bitacora_Conciliacion WHERE ArchivoOrigen = vsArchivoOrigen 
	AND FechaConciliacion >= SUBSTRING (CURRENT FROM 1 FOR 10 ) || ' 00:00:00' AND FlagError = 'F' 
	AND ((Actividad = 'CONCILIACION EXITOSA') OR ( Actividgfhad = 'CONCILIACIONAUTO EXITOSA')) ;
	*/
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;
	SELECT COUNT (KeyX) INTO viContadorArchivo FROM Intercard:Bitacora_Conciliacion WHERE fechaconciliacion BETWEEN  vdtFechaConciliacion AND vdtFechaConciliacion2 
	AND ArchivoOrigen = vsArchivoOrigen AND (Actividad = 'EXPORTAR CENTRAL') AND FlagError = 'F' ;
	
	IF ( viContadorArchivo IS NULL ) OR ( viContadorArchivo = 0 ) THEN 
		LET viContadorArchivo = 1 ;
	ELIF ( viContadorArchivo >= 9 ) THEN 
		LET viContadorArchivo = 0 ;
	ELSE
		LET viContadorArchivo = viContadorArchivo + 1 ;
	END IF ;
	
	IF ( viContadorArchivo IS NULL) THEN 
		LET viContadorArchivo = 0 ;
	END IF ;

	
	--crea el id del archivo
	--TMC1_MMDDAAAA
	--2008 05 29 00:00:00
	--LET vsIdArchivoCentral = psArchivoOrigen  || viContadorArchivo || SUBSTRING ( vdtFechaConciliacion FROM 6 FOR 2 ) 
		--|| SUBSTRING ( vdtFechaConciliacion FROM 9 FOR 2 ) || SUBSTRING ( vdtFechaConciliacion FROM 1 FOR 4 ) ;
	LET vsIdArchivoCentral = psArchivoOrigen  || viContadorArchivo || REPLACE (SUBSTRING (CURRENT::DATE FROM 1 FOR 10), '/', '' );
	


	IF ( ((psArchivoOrigen = 'TPC' ) OR (psArchivoOrigen = 'TPD' )) AND (vsFlag = 'V' ) ) THEN  --PERTENECEN A TMP        

		IF (psArchivoOrigen = 'TPC' ) THEN 
			SELECT LIMIT 1 Bin INTO vsBin FROM Intercard:Bines WHERE Prefijo = 'CRED' ;
		ELSE
			SELECT LIMIT 1 Bin INTO vsBin FROM Intercard:Bines WHERE Prefijo = 'DEB' ;
		END IF ;
		
		
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ ;
		FOREACH WITH HOLD
		SELECT Keyx, DoctoOrig, Documento,  FolioOrig, FolioSucursal, Ident_Det, Importe, Moneda, MontoOriginal, NumTarjeta, 
			Referencia, RefTransaccion, RFC, Sucursal, TipoMov,  Transaccion, TransaccionOrig, Divisa, MontoDivisa, NumCajero, Convenio, 
			TipoTransInterEmpresa, MontoComInterEmpresa, FormadePago, Control
			INTO viKeyx, vsDoctoOrig, vsDocumento, vsFolioOrig, vsFolioSucursal, vsIdent_Det, vmImporte,  vsMoneda, vmMontoOriginal, vsNumTarjeta, vsReferencia, 
			vsRefTransaccion, vsRFC, vsSucursal, vsTipoMov, vsTransaccion, vsTransaccionOrig, vsDivisa, vmMontoDivisa, vsNumCajero, vsConvenio,
			vsTipoTransInterEmpresa, vmMontoComInterEmpresa, vsFormadePago, vsControl
			FROM Intercard:Central 
			WHERE fechaconciliacion BETWEEN  vdtFechaConciliacion AND vdtFechaConciliacion2 
			AND ArchivoOrigen = vsArchivoOrigen 
			--AND NombreArchivo = psNomArchivo
			AND NombreArchivo MATCHES psNomArchivo || '*'
			AND Tipomov <> ''
			AND NumTarjeta MATCHES vsBin || '*'
			AND FolioSucursal <> ''
			AND IdArchivoCental = ''
			
			
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN 
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION DIRTY READ ;
			INSERT INTO BdiTarjeta:Td_PasoConcilia ( FileName,   
				tp_Renglon, tp_Movto, Tran_Central, Tran_Sucursal, Folio_Mov, Cuenta, Tran_Secuencia, Monto,     
				Moneda, Referencia, Folio_Original, Documento, Cod_Autorizacion, Campo_Trabajo, RFC_Comer, Referencia23,   
				Divisa, monto_Divisa, Num_Cajero, Convenio, Tipo_Tran_Emp, Monto_Com_Emp, Forma_Pago,  
				Bandera_Proceso)  
				VALUES ( vsIdArchivoCentral,  
				vsIdent_det, vsTipoMov, vsTransaccion, vsSucursal, vsFolioSucursal, vsNumTarjeta, vsDocumento, vmImporte,  
				vsMoneda, vsReferencia, vsFolioOrig, vsDoctoOrig, vsTransaccionOrig, vmMontoOriginal, vsRFC, vsRefTransaccion,  
				vsDivisa, vmMontoDivisa, vsNumCajero, vsTipoTransInterEmpresa, vsConvenio, vmMontoComInterEmpresa, vsFormadePago,  
				vsControl );
				
			LET viContadorReg = viContadorReg +1 ;
			
			--ACTUALIZA EL CAMPO DE NOMBRE DE ARCHIVO CENTRAL AL KE FUE RELACIONADO EL REGISTRO
			UPDATE Intercard:Central SET IdArchivoCental = TRIM(vsIdArchivoCentral)
			WHERE fechaconciliacion BETWEEN  vdtFechaConciliacion AND vdtFechaConciliacion2 
			AND ArchivoOrigen = vsArchivoOrigen 
			--AND NombreArchivo = psNomArchivo
			AND NombreArchivo MATCHES psNomArchivo || '*'
			AND Tipomov = vsTipoMov
			AND NumTarjeta = vsNumTarjeta
			AND FolioSucursal = vsFolioSucursal
			AND IdArchivoCental = ''
			AND Keyx = viKeyx;
			
			LET viContadorRegistros = viContadorRegistros + 1;
			
			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;
			
		END FOREACH ;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ ;
		--OBTIENE EL TOTAL DE TRANSACCIONES DE TIPO ABONO
		SET ISOLATION TO DIRTY READ ;
		SELECT COUNT( tipomov ) INTO viTipoMovA FROM Intercard:Central  
		WHERE fechaconciliacion BETWEEN  vdtFechaConciliacion AND vdtFechaConciliacion2 
		AND ArchivoOrigen = vsArchivoOrigen
		--AND NombreArchivo = psNomArchivo
		AND NombreArchivo MATCHES psNomArchivo || '*'
		AND Tipomov = 'A'  
		AND NumTarjeta MATCHES vsBin || '*'
		AND FolioSucursal <> ''
		AND TRIM(IdArchivoCental) = TRIM(vsIdArchivoCentral) ;
		--AND CAST(TO_CHAR(fechaconciliacion, '%Y%m%d') as char(8)) LIKE '' || CAST(TO_CHAR(current, '%Y%m%d') as char(8)) || '%' 
		
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ ;
		--OBTIENE EL TOTAL DE TRANSACCIONES DE TIPO CARGO
		SET ISOLATION TO DIRTY READ ;
		SELECT COUNT( tipomov ) INTO viTipoMovC FROM Intercard:Central  
		WHERE fechaconciliacion BETWEEN  vdtFechaConciliacion AND vdtFechaConciliacion2 
		AND ArchivoOrigen = vsArchivoOrigen
		--AND NombreArchivo = psNomArchivo
		AND NombreArchivo MATCHES psNomArchivo || '*'
		AND Tipomov = 'C'
		AND NumTarjeta MATCHES vsBin || '*'
		AND FolioSucursal <> ''
		AND TRIM(IdArchivoCental) = TRIM(vsIdArchivoCentral) ;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ ;
		--OBTIENE EL TOTAL DE TRANSACCIONES DE TIPO REVERSO
		SET ISOLATION TO DIRTY READ ;
		SELECT COUNT( tipomov ) INTO viTipoMovR FROM Intercard:Central  
		WHERE fechaconciliacion BETWEEN  vdtFechaConciliacion AND vdtFechaConciliacion2 
		AND ArchivoOrigen = vsArchivoOrigen
		--AND NombreArchivo = psNomArchivo
		AND NombreArchivo MATCHES psNomArchivo || '*'
		AND Tipomov = 'R'
		AND NumTarjeta MATCHES vsBin || '*'
		AND FolioSucursal <> ''
		AND TRIM(IdArchivoCental) = TRIM(vsIdArchivoCentral) ;
		
	ELSE
		
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		
		FOREACH WITH HOLD
		SELECT Keyx, DoctoOrig, Documento,  FolioOrig, FolioSucursal, Ident_Det, Importe, Moneda, MontoOriginal, NumTarjeta, 
			Referencia, RefTransaccion, RFC, Sucursal, TipoMov,  Transaccion, TransaccionOrig, Divisa, MontoDivisa, NumCajero, Convenio, 
			TipoTransInterEmpresa, MontoComInterEmpresa, FormadePago, Control
			INTO viKeyx, vsDoctoOrig, vsDocumento, vsFolioOrig, vsFolioSucursal, vsIdent_Det, vmImporte,  vsMoneda, vmMontoOriginal, vsNumTarjeta, vsReferencia, 
			vsRefTransaccion, vsRFC, vsSucursal, vsTipoMov, vsTransaccion, vsTransaccionOrig, vsDivisa, vmMontoDivisa, vsNumCajero, vsConvenio,
			vsTipoTransInterEmpresa, vmMontoComInterEmpresa, vsFormadePago, vsControl
			FROM Intercard:Central 
			WHERE fechaconciliacion BETWEEN  vdtFechaConciliacion AND vdtFechaConciliacion2 
			AND ArchivoOrigen = vsArchivoOrigen 
			--AND NombreArchivo = psNomArchivo
			AND NombreArchivo MATCHES psNomArchivo || '*'
			AND Tipomov <> ''
			AND NumTarjeta  <> ''
			AND FolioSucursal <> ''
			AND IdArchivoCental = ''
			
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN 
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION DIRTY READ ;
			INSERT INTO BdiTarjeta:Td_PasoConcilia ( FileName,   
				tp_Renglon, tp_Movto, Tran_Central, Tran_Sucursal, Folio_Mov, Cuenta, Tran_Secuencia, Monto,     
				Moneda, Referencia, Folio_Original, Documento, Cod_Autorizacion, Campo_Trabajo, RFC_Comer, Referencia23,   
				Divisa, monto_Divisa, Num_Cajero, Convenio, Tipo_Tran_Emp, Monto_Com_Emp, Forma_Pago,  
				Bandera_Proceso)  
				VALUES ( vsIdArchivoCentral,  
				vsIdent_det, DECODE (vsTipoMov,'D','A',vsTipoMov), vsTransaccion, vsSucursal, vsFolioSucursal, vsNumTarjeta, vsDocumento, vmImporte,  
				vsMoneda, vsReferencia, vsFolioOrig, vsDoctoOrig, vsTransaccionOrig, vmMontoOriginal, vsRFC, vsRefTransaccion,  
				vsDivisa, vmMontoDivisa, vsNumCajero, vsTipoTransInterEmpresa, vsConvenio, vmMontoComInterEmpresa, vsFormadePago,  
				DECODE (vsControl,'D','0',vsControl ));
				
				LET viContadorReg = viContadorReg +1 ;
			
			--ACTUALIZA EL CAMPO DE NOMBRE DE ARCHIVO CENTRAL AL KE FUE RELACIONADO EL REGISTRO
			
            UPDATE Intercard:Central SET IdArchivoCental = TRIM(vsIdArchivoCentral), TipoMov = DECODE(vsTipoMov,'D','A', vsTipoMov),
			Control = DECODE(vsControl, 'D', '0', vsControl)
			WHERE fechaconciliacion BETWEEN  vdtFechaConciliacion AND vdtFechaConciliacion2 
			AND ArchivoOrigen = vsArchivoOrigen 
			--AND NombreArchivo = psNomArchivo
			AND NombreArchivo MATCHES psNomArchivo || '*'
			AND Tipomov = vsTipoMov
			AND NumTarjeta = vsNumTarjeta
			AND FolioSucursal = vsFolioSucursal
			AND IdArchivoCental = ''
			AND Keyx = viKeyx;
			
			LET viContadorRegistros = viContadorRegistros + 1;
			
			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;
		
		END FOREACH ;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ ;
		--OBTIENE EL TOTAL DE TRANSACCIONES DE TIPO ABONO
		SET ISOLATION TO DIRTY READ ;
		SELECT COUNT( tipomov ) INTO viTipoMovA FROM Intercard:Central  
		WHERE fechaconciliacion BETWEEN  vdtFechaConciliacion AND vdtFechaConciliacion2 
		AND ArchivoOrigen = vsArchivoOrigen

		--AND NombreArchivo = psNomArchivo
		AND NombreArchivo MATCHES psNomArchivo || '*'
		AND Tipomov = 'A' 
		AND NumTarjeta <> ''
		AND FolioSucursal <> ''
		AND TRIM(IdArchivoCental) = TRIM(vsIdArchivoCentral) ;
		
		
		/*WHERE tipomov = 'A'  AND fechaconciliacion = vdtFechaConciliacion 
		AND CAST(TO_CHAR(fechaconciliacion, '%Y%m%d') as char(8)) LIKE '' || CAST(TO_CHAR(current, '%Y%m%d') as char(8)) || '%' 
		AND ArchivoOrigen = psArchivoOrigen;
		*/
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ ;
		--OBTIENE EL TOTAL DE TRANSACCIONES DE TIPO CARGO
		SET ISOLATION TO DIRTY READ ;
		SELECT COUNT( tipomov ) INTO viTipoMovC FROM Intercard:Central  
		WHERE fechaconciliacion BETWEEN  vdtFechaConciliacion AND vdtFechaConciliacion2 
		AND ArchivoOrigen = vsArchivoOrigen
		--AND NombreArchivo = psNomArchivo
		AND NombreArchivo MATCHES psNomArchivo || '*'
		AND Tipomov = 'C'
		AND NumTarjeta <> ''
		AND FolioSucursal <> ''
		AND TRIM(IdArchivoCental) = TRIM(vsIdArchivoCentral) ;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ ;
		--OBTIENE EL TOTAL DE TRANSACCIONES DE TIPO REVERSO
		SET ISOLATION TO DIRTY READ ;
		SELECT COUNT( tipomov ) INTO viTipoMovR FROM Intercard:Central  
		WHERE fechaconciliacion BETWEEN  vdtFechaConciliacion AND vdtFechaConciliacion2 
		AND ArchivoOrigen = vsArchivoOrigen
		--AND NombreArchivo = psNomArchivo
		AND NombreArchivo MATCHES psNomArchivo || '*'
		AND Tipomov = 'R'
		AND NumTarjeta <> ''
		AND FolioSucursal <> ''
		AND TRIM(IdArchivoCental) = TRIM(vsIdArchivoCentral) ;
		
	END IF ;
	
        ----DEVOLUCIONES
	--ACTUALIZA EL ID DE LOS CARGOS PARA CENTRAL --DEVOLUCIONES
	IF (vsArchivoOrigen IN ('VNC', 'VND', 'VIC', 'VID')) THEN 
		UPDATE BdiTarjeta:Td_DevolucionesPOS SET FileName = vsIdArchivoCentral
		WHERE NomArchivo MATCHES psNomArchivo || '*'
		AND ArchivoOrigen = vsArchivoOrigen
		AND Fecha = SUBSTR(psNomArchivo,11,2) || '/' || (SUBSTR(psNomArchivo,9,2) || '/' || SUBSTR(psNomArchivo,13,4));
	END IF;

	LET vsFechaAuxiliar = REPLACE (SUBSTRING (CURRENT::DATE FROM 1 FOR 10), '/', '' );
	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ ;
	SELECT LIMIT 1 Sucursal, Usuario INTO vsParamSucursal, vsUsuario FROM Intercard:Parametros ;
	
	LET vsIdent_det = 'E' ;
	LET vsTipoMov = '' ; --  vsParamSucursal ;
	LET vsTransaccion = '' ;
	LET vsSucursal = '' ; --vsFechaAuxiliar ;
	LET vsFolioSucursal = viTipoMovA + viTipoMovC + viTipoMovR ;
	LET vsNumTarjeta = viTipoMovC ;
	LET vsDocumento = viTipoMovA ;
	LET vmImporte = viTipoMovR ; 
	LET vsMoneda = '0' ;
	LET vsReferencia = '' ;
	LET vsFolioOrig = '' ;
	LET vsDoctoOrig = '0' ;
	LET vsTransaccionOrig = '' ;
	LET vmMontoOriginal = 0.0 ;
	LET vsRFC = '' ;
	LET vsRefTransaccion  = '' ;
	LET vsDivisa = '' ;
	LET vmMontoDivisa = 0.0 ;
	LET vsNumCajero  = '' ;
	LET vsTipoTransInterEmpresa = '' ;
	LET vsConvenio = '' ;
	LET vmMontoComInterEmpresa = 0.0 ;
	LET vsFormadePago = '' ;
	LET vsControl = '0' ;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ ;
	-- GUARDA EL REGISTRO CON EL TOTAL DE LA OPERACION
	INSERT INTO bditarjeta:Td_PasoConcilia ( FileName,   
		tp_Renglon, tp_Movto, Tran_Central, Tran_Sucursal, Folio_Mov, Cuenta, Tran_Secuencia, Monto,     
		Moneda, Referencia, Folio_Original, Documento, Cod_Autorizacion, Campo_Trabajo, RFC_Comer, Referencia23,   
		Divisa, monto_Divisa, Num_Cajero, Convenio, Tipo_Tran_Emp, Monto_Com_Emp, Forma_Pago,
		Bandera_Proceso)  
		VALUES ( vsIdArchivoCentral,  
		vsIdent_det, vsParamSucursal , vsUsuario, vsFechaAuxiliar, vsFolioSucursal, vsNumTarjeta, vsDocumento, vmImporte,  
		vsMoneda, vsReferencia, vsFolioOrig, vsDoctoOrig, vsTransaccionOrig, vmMontoOriginal, vsRFC, vsRefTransaccion,  
		vsDivisa, vmMontoDivisa, vsNumCajero, vsTipoTransInterEmpresa, vsConvenio, vmMontoComInterEmpresa, vsFormadePago,  
		vsControl );

	EXECUTE PROCEDURE Intercard:sp_Insertar_Bitacora( 'CONAUT', psArchivoOrigen, 'EXPORTAR CENTRAL' , '') INTO visqlerr ;

	RETURN  visqlerr, vsIdArchivoCentral, viContadorReg  ;

END
END PROCEDURE;