CREATE PROCEDURE "informix".sp_concreing_validaintegridad ( 
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
								psSistema CHAR(1))

	RETURNING CHAR (5) AS Retorno, CHAR (1) AS Integridad, CHAR(250) AS ErrorActividad, INTEGER AS Elemento;

	/*
	*****************************************************************************************************
	-----------------------------------------------------------------------------------------------------
	-- DESCRIPCION:  VALIDA LA INTEGRIDAD DE LOS CAMPOS NECESARIOS PARA LA CONCILIACION  ----------------
	-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
	-- FECHA : 01/07/2011  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Reingenieria de la conciliacion automatica / Validacion de Integridad  -----------------
	-----------------------------------------------------------------------------------------------------
	-- MODIFICACION: COMPARACIÃ?N DE BIN PARAMETRIZADA  --------------------------------------------------
	-- MODIFICACION: RETORNO DE ACTIVIDADERROR  ---------------------------------------------------------
	-- MODIFICACION: SE MODIFICA LA COMPARACION DE BINES DE LAS TARJETAS PARA IMPLEMENTAR AL MODELO MULTIBINES SOLICITADO.
	-----------------------------------------------------------------------------------------------------
	-- MODIFICACION: SE MODIFICA LOGICA PARA PERMITIR LAS TRANSACCIONES TIPO 20 EN LOS ARCHIVOS VIC(MONEYGRAM).
	*****************************************************************************************************
	*/

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

		--SET DEBUG FILE TO '/informix/HomeInformix/rrm/TraceINTEGRIDAD.out';
		--TRACE ON;
		--SET DEBUG FILE TO '/RESPALDOSNEW/Pruebas_Conciliacion/Salidas_ejecuciones/debug_sp_concreing_validaintegridad.out';
		--TRACE ON;
		
		-----------------------------------------------------
		--------REINGENIERIA-CONCILIACION-AUTOMATICA---------
		--------2011/06/20-ING-ALFONSO-CRUZ------------------
		-----------------------------------------------------

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;

		/*OBTENIENDO LA CIFRA DEL BIN DE LA TARJETA*/
		LET vsBine = NVL(SUBSTRING (psNumTarjeta FROM 1 FOR 6),'');
		--LET vmMonto325 = ( ( REPLACE( pmMonto325,'.',''))::MONEY (19,4)/100 );
		LET vmMonto325 = ( ( REPLACE( pmMonto325,'.',''))::MONEY/100 );
		LET vmMontoCashBack325 = ((REPLACE (pmMontoCashBack325,'.',''))::MONEY/100); --Conversion de string de monto cashback a money
		
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico ( psNumTarjeta ) INTO vsEsNumTarjeta;

		--VALIDACION DE INTEGRIDAD DE REGISTROS - ARCHIVOS E-GLOBAL VENTAS INTERNACIONALES
		-- BCPLVID Y BCPLVIC
		IF TRIM(NVL(psArchivo_origen,''))='' THEN
			
			LET vssqlerr = '00307';
			LET vsErrorActividad = 'ERROR DE INTEGRIDAD archivo_origen: EL VALOR DEL ARCHIVO ORIGEN ES INCORRECTO';

		ELIF ( ( psArchivo_origen = 'MCD' ) OR ( psArchivo_origen = 'MCC' ) ) THEN
			LET vssqlerr = '00300';
			--VALIDANDO QUE LOS CAMPOS SEAN NUMERICOS

			--EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico (psNumTarjeta) INTO vsEsNumTarjeta;
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico (psIdcomercio325) INTO vsEsIdComercio ;
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico (psSecuencia325) INTO vsEsSecuencia325 ;
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico (psDivisa325) INTO vsEsDivisa325 ;
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico(pmMonto325) INTO vsEsMonto;

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
			ELIF  ( ( psArchivo_origen = 'MCD' ) AND ( (vsBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'D')) OR ( psSistema != 'D' ) ) )THEN-- BIN 400819 EN VID
					LET vsIntegridad = 'F';
					LET vsErrorIntegridad = 'ERROR5 numtarjeta';
					LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: EL BIN DEL REGISTRO NO COINCIDE';

			ELIF ( ( psArchivo_origen = 'MCC' ) AND ((vsBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'C')) OR ( psSistema != 'C' ) ) )  THEN -- BIN 426807 EN VIC
					LET vsIntegridad = 'F';
					LET vsErrorIntegridad = 'ERROR6 numtarjeta';
					LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: EL BIN DEL REGISTRO NO COINCIDE';

			ELIF ( (psTipotransaccion325  NOT IN ( '01','02','05','06','07','21' ))
			AND (NOT(( psArchivo_origen = 'VID' ) AND (psTipotransaccion325 = '20')) ) ) THEN  --VIC CON PSTIPOTRANSACCION325 = 20  ES PARA MONEYGRAM

				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR tipotransac';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD tipotransaccion325: EL TIPO DE TRANSACCION ES INCORRECTO';

			ELIF (vmMonto325 = 0) THEN

				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR EN MONTO325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD monto325: EL IMPORTE DE TRANSACCION DEBE SER DIFERENTE DE CERO';
			ELIF (vsEsMonto = 'F') THEN

				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR EN MONTO325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD monto325: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';

			ELIF (TRIM(pmMonto325)='')	THEN

				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR2 EN MONTO325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD monto325: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';

			ELIF (vsEsIdComercio != 'V' ) THEN

				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR1 idcomercio325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD idcomercio325: LA CLAVE DE COMERCIO DEBE SER NUMERICA';


			ELIF (TRIM(psNomcomercio325)='') THEN

				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR nomcomercio325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD nomcomercio325: EL NOMBRE DE COMERCIO NO DEBE VENIR EN BLANCO';

			ELIF LENGTH(psSecuencia325)!=6 THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR1 secuencia325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD secuencia325: EL NUMERO DE AUTORIZACION DEBE CONTENER 6 DIGITOS';
			ELIF (vsEsSecuencia325 != 'V' ) THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR2 secuencia325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD secuencia325: EL NUMERO DE AUTORIZACION SOLO DEBE CONTENER DIGITOS';
			ELIF psSecuencia325 = '000000' THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR3 secuencia325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD secuencia325: DEBER SE DIFERENTE A 000000';
			ELIF ( vsEsDivisa325!='V' ) OR (psDivisa325='000') THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR divisa325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD divisa325: EL CODIGO DE LA MONEDA SOLO DEBE CONTENER DIGITOS';
			ELIF ( LENGTH(TRIM(psDivisa325))!=3 )  THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR2 divisa325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD divisa325: EL CODIGO DE LA MONEDA DEBE CONTENER 3 DIGITOS';
			ELSE
				LET vssqlerr = '00000';

				LET vsIntegridad = 'V';
				LET vsErrorIntegridad = '';


			END IF;

		ELIF ( ( psArchivo_origen = 'VID' ) OR ( psArchivo_origen = 'VIC' ) ) THEN
			LET vssqlerr = '00300';
			--VALIDANDO QUE LOS CAMPOS SEAN NUMERICOS

			--EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico (psNumTarjeta) INTO vsEsNumTarjeta;
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico (psIdcomercio325) INTO vsEsIdComercio ;
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico (psSecuencia325) INTO vsEsSecuencia325 ;
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico (psDivisa325) INTO vsEsDivisa325 ;
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico(pmMonto325) INTO vsEsMonto;

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
			ELIF  ( ( psArchivo_origen = 'VID' ) AND ( (vsBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'D')) OR ( psSistema != 'D' ) ) )THEN-- BIN 400819 EN VID
			--ELIF  ( ( psArchivo_origen = 'VID' ) AND ( ( vsBine!= psBinDebito ) OR ( psSistema != 'D' ) ) )THEN-- BIN 400819 EN VID
					
					LET vsIntegridad = 'F';
					LET vsErrorIntegridad = 'ERROR5 numtarjeta';
					LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: EL BIN DEL REGISTRO NO COINCIDE';

			ELIF ( ( psArchivo_origen = 'VIC' ) AND ((vsBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'C')) OR ( psSistema != 'C' ) ) )  THEN -- BIN 426807 EN VIC
			--ELIF ( ( psArchivo_origen = 'VIC' ) AND ( ( vsBine != psBinCredito) OR ( psSistema != 'C' ) ) )  THEN -- BIN 426807 EN VIC

					LET vsIntegridad = 'F';
					LET vsErrorIntegridad = 'ERROR6 numtarjeta';
					LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: EL BIN DEL REGISTRO NO COINCIDE';

			ELIF ( (psTipotransaccion325  NOT IN ( '01','02','05','06','07','21' ))
			AND (NOT(( psArchivo_origen = 'VID' ) AND (psTipotransaccion325 = '20')) ) ) THEN  --VIC CON PSTIPOTRANSACCION325 = 20  ES PARA MONEYGRAM

				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR tipotransac';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD tipotransaccion325: EL TIPO DE TRANSACCION ES INCORRECTO';

			ELIF (vmMonto325 = 0) THEN

				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR EN MONTO325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD monto325: EL IMPORTE DE TRANSACCION DEBE SER DIFERENTE DE CERO';
			ELIF (vsEsMonto = 'F') THEN

				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR EN MONTO325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD monto325: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';

			ELIF (TRIM(pmMonto325)='')	THEN

				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR2 EN MONTO325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD monto325: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';
			ELIF (vsEsIdComercio != 'V' ) THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR1 idcomercio325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD idcomercio325: LA CLAVE DE COMERCIO DEBE SER NUMERICA';
			ELIF LENGTH(TRIM(psIdcomercio325)) < 9 THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR2 idcomercio325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD idcomercio325: LA CLAVE DE COMERCIO DEBE SER NUMERICA CON 9 DIGITOS';
			ELIF (TRIM(psNomcomercio325)='') THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR nomcomercio325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD nomcomercio325: EL NOMBRE DE COMERCIO NO DEBE VENIR EN BLANCO';
			ELIF LENGTH(psSecuencia325)!=6 THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR1 secuencia325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD secuencia325: EL NUMERO DE AUTORIZACION DEBE CONTENER 6 DIGITOS';
			ELIF (vsEsSecuencia325 != 'V' ) THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR2 secuencia325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD secuencia325: EL NUMERO DE AUTORIZACION SOLO DEBE CONTENER DIGITOS';
			ELIF (psSecuencia325 = '000000' ) THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR3 secuencia325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD secuencia325: EL NUMERO DE AUTORIZACION DEBE SER DIFERENTE A 000000';
			ELIF ( vsEsDivisa325!='V' ) OR (psDivisa325='000') THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR divisa325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD divisa325: EL CODIGO DE LA MONEDA SOLO DEBE CONTENER DIGITOS';
			ELIF ( LENGTH(TRIM(psDivisa325))!=3 )  THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR2 divisa325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD divisa325: EL CODIGO DE LA MONEDA DEBE CONTENER 3 DIGITOS';
			ELSE
				LET vssqlerr = '00000';

				LET vsIntegridad = 'V';
				LET vsErrorIntegridad = '';


			END IF;




		--VALIDACION DE INTEGRIDAD DE REGISTROS - ARCHIVOS E-GLOBAL VENTAS NACIONALES Y ARCHIVOS COPPEL INTERREDES
		-- BCPLVND , BCPLVNC , BCPLTCD Y BCPLTCC

		ELIF ( ( psArchivo_origen = 'VND' ) OR ( psArchivo_origen = 'VNC' ) OR
		( psArchivo_origen = 'TCD' ) OR ( psArchivo_origen = 'TCC' ) ) THEN
			LET vssqlerr = '00301';
			--VALIDANDO QUE LOS CAMPOS SEAN NUMERICOS

			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico (psIdcomercio325) INTO vsEsIdComercio ;
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico (psSecuencia325) INTO vsEsSecuencia325 ;
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico (psReferencia23_325) INTO vsEsReferencia23_325 ;
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico(pmMonto325) INTO vsEsMonto;
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico(pmMontoCashBack325) INTO vsEsMontoCashBack325;
			--VALIDACION DEL NUMERO DE TARJETA
			IF LENGTH(TRIM(psNumTarjeta))!=16 THEN
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
			ELIF ( ( ( psArchivo_origen = 'VND' ) OR ( psArchivo_origen = 'TCD' ) ) AND ( (vsBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'D'))  OR ( psSistema != 'D' ) ) ) THEN-- BIN 400819 EN VID
			--ELIF ( ( ( psArchivo_origen = 'VND' ) OR ( psArchivo_origen = 'TCD' ) ) AND ( ( vsBine != psBinDebito )  OR ( psSistema != 'D' ) ) ) THEN-- BIN 400819 EN VID
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR4 numtarjeta';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: EL BIN DEL REGISTRO NO COINCIDE';
			ELIF ( ( ( psArchivo_origen = 'VNC' ) OR  ( psArchivo_origen = 'TCC' ) ) AND ( (vsBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'C')) OR ( psSistema != 'C' ) ) ) THEN -- BIN 426807 EN VIC
			--ELIF ( ( ( psArchivo_origen = 'VNC' ) OR  ( psArchivo_origen = 'TCC' ) ) AND ( ( vsBine != psBinCredito ) OR ( psSistema != 'C' ) ) ) THEN -- BIN 426807 EN VIC
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR5 numtarjeta';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: EL BIN DEL REGISTRO NO COINCIDE';
			/*ELIF ( ( psTipotransaccion325 != '01' ) AND ( psTipotransaccion325 != '02' ) AND
			( psTipotransaccion325 != '20' ) AND ( psTipotransaccion325 != '21' ) ) THEN*/
			ELIF ( psTipotransaccion325  NOT IN ( '01','02','20','21' ) ) THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR tipotransac';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD tipotransaccion325: EL TIPO DE TRANSACCION ES INCORRECTO';
			/*ELIF (vmMonto325=0) THEN -- Se quita por aquellas transacciones que lleguen en 0 pero monto cash back >0
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR EN MONTO325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD monto325: EL IMPORTE DE TRANSACCION DEBE SER DIFERENTE DE CERO';*/
			ELIF (vsEsMonto = 'F') THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR EN MONTO325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD monto325: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';
			ELIF (TRIM(pmMonto325)='')	THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR2 EN MONTO325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD monto325: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';
			ELIF (vsEsMontoCashBack325 = 'F') THEN -- Intregracion de CashBack RRM
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR EN MONTO325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD monto325: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';
			ELIF (TRIM(pmMontoCashBack325)='')	THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR2 EN MONTO325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD monto325: EL IMPORTE DE TRANSACCION NO DEBE SER VACIO';
			ELIF (vmMonto325 + vmMontoCashBack325 = 0) THEN -- Valida que monto325 y montocashback325 sean mayores a 0
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR EN MONTO325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD monto325: EL IMPORTE DE TRANSACCION DEBE SER DIFERENTE DE CERO';
			ELIF (vsEsIdComercio != 'V' ) THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR1 idcomercio325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD idcomercio325: LA CLAVE DE COMERCIO DEBE SER NUMERICA';
			ELIF LENGTH(TRIM(psIdcomercio325)) < 9 THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR2 idcomercio325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD idcomercio325: LA CLAVE DE COMERCIO DEBE SER NUMERICA CON 9 DIGITOS';
			ELIF (TRIM(psNomcomercio325)='') THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR nomcomercio325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD nomcomercio325: EL NOMBRE DE COMERCIO NO DEBE VENIR EN BLANCO';
			ELIF (vsEsReferencia23_325!='V') THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR referencia23';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD referencia23_325: LA REFERENCIA DEBE SER NUMERICA';
			/*ELIF (LENGTH(TRIM(psReferencia23_325))!=23) THEN   ------------------------------------ESTA VALIDACION NO SE SOLICITA
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR2 referencia23';	*/
			ELIF LENGTH(psSecuencia325)!=6 THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR1 secuencia325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD secuencia325: EL NUMERO DE AUTORIZACION DEBE CONTENER 6 DIGITOS';
			ELIF (vsEsSecuencia325 != 'V' ) THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR2 secuencia325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD secuencia325: EL NUMERO DE AUTORIZACION SOLO DEBE CONTENER DIGITOS';
			ELIF (psSecuencia325 = '000000' ) THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR3 secuencia325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD secuencia325: EL NUMERO DE AUTORIZACION DEBE SER DIFERENTE A 000000';
			ELIF ( (LENGTH(TRIM(psRfc325)) < 12) or (LENGTH(TRIM(psRfc325)) > 13) ) THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR Rfc325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD referencia23_325: EL RFC DEBE CONTENER 12 o 13 CARACTERES';
			ELSE
				LET vssqlerr = '00000';

				LET vsIntegridad = 'V';
				LET vsErrorIntegridad = '';


			END IF;


		--VALIDACION DE INTEGRIDAD DE REGISTROS - ARCHIVOS E-GLOBAL CAJEROS AUTOMATICOS
		-- BCPL_ATMD Y BCPL_ATMC
		ELIF ( ( psArchivo_origen = 'TMD' ) OR ( psArchivo_origen = 'TMC' ) ) THEN
			LET vssqlerr = '00302';

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
			ELIF ( ( psArchivo_origen = 'TMD' ) AND ( (vsBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'D')) OR ( psSistema != 'D' )  ) ) THEN-- BIN 400819 EN VID
			--ELIF ( ( psArchivo_origen = 'TMD' ) AND ( (vsBine!=psBinDebito) OR ( psSistema != 'D' )  ) ) THEN-- BIN 400819 EN VID
					LET vsIntegridad = 'F';
					LET vsErrorIntegridad = 'ERROR4 numtarjeta';
					LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: EL BIN DEL REGISTRO NO COINCIDE';
			ELIF ( ( psArchivo_origen = 'TMC' ) AND ( (vsBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'C')) OR ( psSistema != 'C' ) ) ) THEN -- BIN 426807 EN VIC
			--ELIF ( ( psArchivo_origen = 'TMC' ) AND ( ( vsBine!=psBinCredito) OR ( psSistema != 'C' ) ) ) THEN -- BIN 426807 EN VIC
					LET vsIntegridad = 'F';
					LET vsErrorIntegridad = 'ERROR5 numtarjeta';
					LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: EL BIN DEL REGISTRO NO COINCIDE';
			ELSE
				LET vssqlerr = '00000';

				LET vsIntegridad = 'V';
				LET vsErrorIntegridad = '';


			END IF;

		--VALIDACION DE INTEGRIDAD DE REGISTROS - ARCHIVOS E-GLOBAL PAGOS INTERBANCARIOS
		-- BCPLPNC
		ELIF ( ( psArchivo_origen = 'PNC' ) ) THEN
			LET vssqlerr = '00303';

			--VALIDANDO QUE LOS CAMPOS SEAN NUMERICOS

			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico(pmMonto325) INTO vsEsMonto;

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
			ELIF ( ( psArchivo_origen = 'PNC' ) AND ( (vsBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'C')) OR ( psSistema != 'C' ) ) ) THEN -- BIN 426807 EN VIC
			--ELIF ( ( psArchivo_origen = 'PNC' ) AND ( ( vsBine != psBinCredito) OR ( psSistema != 'C' ) ) ) THEN -- BIN 426807 EN VIC
					LET vsIntegridad = 'F';
					LET vsErrorIntegridad = 'ERROR5 numtarjeta';
					LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: EL BIN DEL REGISTRO NO COINCIDE';
			ELIF ( ( psTipotransaccion325 != '20' ) ) THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR tipotransac';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD tipotransaccion325: EL TIPO DE TRANSACCION ES INCORRECTO';
			ELIF (vmMonto325=0) THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR EN MONTO325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD monto325: EL IMPORTE DE TRANSACCION DEBE SER DIFERENTE DE CERO';
			ELIF (vsEsMonto = 'F') THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR EN MONTO325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD monto325: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';
			ELIF (TRIM(pmMonto325)='')	THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR2 EN MONTO325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD monto325: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';
			ELSE
				LET vssqlerr = '00000';

				LET vsIntegridad = 'V';
				LET vsErrorIntegridad = '';


			END IF;




		--VALIDACION DE INTEGRIDAD DE REGISTROS - ARCHIVOS COPPEL CORRESPONSALES
		-- BCPLCCD Y BCPLCCP
		ELIF ( ( psArchivo_origen = 'CCD' ) OR ( psArchivo_origen = 'CCP' ) OR ( psArchivo_origen = 'TPD' ) ) THEN
			LET vssqlerr = '00304';
			--VALIDANDO QUE LOS CAMPOS SEAN NUMERICOS
			EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico(pmMonto325) INTO vsEsMonto;


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
			/*ELIF (vmMonto325=0) THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR EN MONTO325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD monto325: EL IMPORTE DE TRANSACCION DEBE SER DIFERENTE DE CERO';*/
			ELIF (vsEsMonto = 'F') THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR EN MONTO325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD monto325: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';
			ELIF (TRIM(pmMonto325)='')	THEN
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR2 EN MONTO325';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD monto325: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';
			ELSE
				LET vssqlerr = '00000';

				LET vsIntegridad = 'V';
				LET vsErrorIntegridad = '';


			END IF;

		--VALIDACION DE INTEGRIDAD DE REGISTROS - ARCHIVOS PROSA
		-- BCPL_ATMOL Y BCPL_ATMPL
		--ELIF ( ( psArchivo_origen = 'MOL' ) OR ( psArchivo_origen = 'MPL' )) THEN
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
			--LET vsMensajeError = vsErrorActividad;


	       /*SE COMENTA EL SET LOCK PARA NO TENER DUPLICIDAD LFC*/

			--SET LOCK MODE TO WAIT 3;
			--SET ISOLATION TO DIRTY READ;

			/*ACTUALIZANDO LOS VALORES DE INTEGRIDAD DEL REGISTRO*/
			/*UPDATE bditarjeta:"informix".td_movimientos_conciliacion
			SET integridad = vsIntegridad, integridad_error = vsErrorIntegridad
			WHERE --archivo_origen = psArchivo_origen AND
			numtarjeta = psNumTarjeta
			AND secuencia325 = psSecuencia325
			AND consecutivo = psConsecutivo;*/
			
			UPDATE bditarjeta:"informix".td_movimientos_conciliacion
			SET integridad = vsIntegridad, integridad_error = vsErrorIntegridad
			WHERE consecutivo = psConsecutivo;


			IF (vsIntegridad NOT IN ('V')) THEN

				LET vsErrorActividad ='CONSECUTIVO '|| psConsecutivo || ' CONTIENE ' || vsErrorActividad;

			END IF;


		RETURN vssqlerr, NVL(vsFlagError,''), NVL(vsErrorActividad,''), 3 ;

	END

END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Reingenieria de la Conciliacion Automatica',
'Solicito: ',
'Descripcion: VALIDA LA INTEGRIDAD DE LOS CAMPOS NECESARIOS PARA LA CONCILIACION.',
'Fecha: 2011/07/01',
'Version: 20110701.1712',
'BD: bditarjeta',
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Reingenieria de la Conciliacion Automatica',
'Solicito: ',
'Descripcion: AHORA SE ACTUALIZA LA INTEGRIDAD TOMANDO EN CUENTA SÓLO EL CONSECUTIVO.',
'Fecha: 2011/11/24',
'Version: 20111124.0942',
'BD: bditarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE MODIFICA LA COMPARACION DE BINES DE LAS TARJETAS PARA IMPLEMENTAR AL MODELO MULTIBINES SOLICITADO.',
'Fecha: 2012/04/20',
'Version: 20120420.1050',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE MODIFICA LOGICA PARA PERMITIR LAS TRANSACCIONES TIPO 20 EN LOS ARCHIVOS VIC(MONEYGRAM).',
'Fecha: 2012/10/01',
'Version: 20121001.0941',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martínez',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE MODIFICA PARA VALIDAR LAS TRANSACCIONES CON CASH BACK EN LOS ARCHIVOS VND.',
'Fecha: 2013/07/29',
'Version: 20130729.1250',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martínez',
'Proyecto: Conciliacion de archivos Mastercard',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE agrega ciclo de validacion para los archivos de Mastercard.',
'Fecha: 2014/03/06',
'Version: 20140306.1740',
'BD: BdiTarjeta',
'',
'MODIFICACION: L.I.A. Ricardo Reséndiz Martínez',
'Proyecto: Nuevas transacciones de corresponsales ',
'Solicito: Luis Gomez Santiago',
'Descripcion: Se quita validaciones de monto de la operación ya que para consultas el monto si puede ser 0',
'Fecha: 2015/10/06',
'Version: 20151006.1400',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ana Lidia Rubio Salazar',
'Proyecto: Conciliacion de archivos',
'Solicito: Luis Gomez Santiago',
'Descripcion: Se modifica la validación para el RFC325, que acepte registros de 12 y 13 posiciones.',
'Fecha: 2015/10/29',
'Version: 20151029.1300',
'BD: BdiTarjeta',
'',
'MODIFICACION: L.I.A. Ricardo Reséndiz Martínez',
'Proyecto: Validacion de secuencias en 000000 ',
'Solicito: Luis Gomez Santiago',
'Descripcion: Se agrega validación para ver si el numero de secuencia sea diferente a 000000',
'Fecha: 2015/11/15',
'Version: 20151115.1400',
'BD: BdiTarjeta',
'',
'MODIFICACION: Maria Fernanda Ortiz Figueroa',
'Proyecto: Optimizacion SP Conciliacion Automatica',
'Solicito: Produccion y BD',
'Descripcion: Se mejor quitaron directivas SET',
'Fecha: 2023/07/20',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_cargaarchivos_mc ( 
    psRuta_Repositorio VARCHAR (90), 
    psNomArchivo VARCHAR (30), 
    psArchivoOrigen VARCHAR(3), 
    piTipoLayOut INTEGER, 
    psSistema VARCHAR(1),
    psRuta_Procesos VARCHAR (90) )

RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta, INTEGER AS Tot_Registros, MONEY AS Tot_Monto, INTEGER AS Elemento;

    DEFINE vsSQL 						VARCHAR (200) ;
    DEFINE viSQLerr 					INTEGER ;
        
    DEFINE vsCodRet 					VARCHAR(5);
    DEFINE vsMensaje_Respuesta 			VARCHAR(250);
    DEFINE viTotalRegistros 			INTEGER;
    DEFINE vmTotalMonto 				MONEY;
    DEFINE vsRegistro 					CHAR(250);
    DEFINE viIdHeaderMasterCard			VARCHAR(10);
    DEFINE viIdTrailerMasterCard		VARCHAR(10);
    DEFINE viTipoStrl					VARCHAR(01);
    DEFINE vsHeader						VARCHAR(250);
    DEFINE vsTrailer					VARCHAR(250);
    DEFINE vsStrl						VARCHAR(250);
    DEFINE viInicioCadena_Reg	 		INTEGER;
    DEFINE viInicioCadena_Reg_deb 		INTEGER;
    DEFINE viInicioCadena_Reg_cre		INTEGER;
    DEFINE viInicioCadena_Monto			INTEGER;
    DEFINE viInicioCadena_Monto_deb		INTEGER;
    DEFINE viInicioCadena_Monto_cre		INTEGER;
    DEFINE viPosMontoReg_Ini 			INTEGER;
    DEFINE viPosMontoReg_Fin 			INTEGER;
    DEFINE vsTipoSumario 				VARCHAR(35);
    DEFINE vsTipoSTRL	 				CHAR(04);
    DEFINE vsEnc_Total_Registros		VARCHAR(08);
    DEFINE vsEnc_Total_Registros_deb	VARCHAR(08);
    DEFINE vsEnc_Monto_Total_deb		VARCHAR(14); 
    DEFINE vsEnc_Total_Registros_cre	VARCHAR(08);
    DEFINE vsEnc_Monto_Total_cre		VARCHAR(14); 
    DEFINE vsEnc_Monto_Total			VARCHAR(14);
    DEFINE vsFlagNumerico_Reg_deb		VARCHAR(1);
    DEFINE vsFlagNumerico_Reg_cre		VARCHAR(1);
    DEFINE vsFlagNumerico_Monto_deb		VARCHAR(1);
    DEFINE vsFlagNumerico_Monto_cre		VARCHAR(1);
    DEFINE vsFlagNumerico_Monto 		VARCHAR(1);
    DEFINE RUTA_ORIGEN VARCHAR(100);
    
    LET vsSQL = '' ;
    LET viSQLerr = 0;    
      
    LET vsCodRet = '00000';
    LET vsMensaje_Respuesta = 'PROCESO EXITOSO';
    LET viTotalRegistros = 0;
    LET vmTotalMonto = 0.0;
    LET vsRegistro = '';
    LET viIdHeaderMasterCard = '';
    LET viIdTrailerMasterCard = '';
    LET viTipoStrl = '';
    LET vsHeader = '';
    LET vsTrailer ='';
    LET vsStrl ='';
    LET viInicioCadena_Reg_deb = 0;
    LET viInicioCadena_Reg_cre = 0;
    LET viInicioCadena_Monto_deb = 0;
    LET viInicioCadena_Monto_cre = 0;
    LET viPosMontoReg_Ini = 0;
    LET viPosMontoReg_Fin = 0;
    LET vsTipoSumario = '';
    LET vsTipoSTRL = '';
    LET vsEnc_Total_Registros = '';
    LET vsEnc_Total_Registros_deb = '';
    LET vsEnc_Monto_Total_deb = '';	
    LET vsEnc_Total_Registros_cre = '';
    LET vsEnc_Monto_Total_cre = '';	
    LET vsEnc_Monto_Total = '';			
    LET vsFlagNumerico_Reg_deb = '';			
    LET vsFlagNumerico_Reg_cre = '';
    LET vsFlagNumerico_Monto_deb = '';				
    LET vsFlagNumerico_Monto_cre = '';	
    LET vsFlagNumerico_Monto = ''; 		
	LET RUTA_ORIGEN = '/RESPALDOSNEW/';
	
	BEGIN

	
		ON EXCEPTION SET viSQLerr
			
            --SET DEBUG FILE TO RUTA_ORIGEN||"excep_sp_carga_archivos_mc.err.out" WITH APPEND; --Se apaga trace de error por que anteriormente se encontraba prendido.
            --TRACE ON;
            
			TRUNCATE TABLE bditarjeta:"informix".td_carga_archivo_mc  DROP STORAGE;
            
			LET vsCodRet = '00107';
			RETURN vsCodRet, ('[' || vsCodRet ||  '] ERROR NO CONTROLADO (' || viSQLerr || '). ARCHIVO (' || psNomArchivo || ') ' || TRIM(vsMensaje_Respuesta) ), 0, 0.0, 1;
			
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;		
		
        --SET DEBUG FILE TO RUTA_ORIGEN||"debug_sp_carga_archivos_mc.out";
        --TRACE ON;
    
        
        EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_dbload_archivos(psRuta_Repositorio, psNomArchivo, psArchivoOrigen , piTipoLayOut ,  psSistema)
            INTO vsCodRet, vsMensaje_Respuesta;
            
        IF ( vsCodRet  <> '00000' ) THEN
        
            RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta), NVL(viTotalRegistros, 0), NVL((vmTotalMonto), 0.0), 1;
            
        END IF   

		IF (NOT EXISTS (SELECT Registro FROM BdiTarjeta:"informix".Td_Carga_Archivo_mc  WHERE Registro MATCHES 'FHDR*')) THEN -- IF (1)
		
		
			LET vsTipoSumario = 'ERROR HEADER';
			
			LET viInicioCadena_Reg = -1;
			LET viInicioCadena_Monto = -1;
			LET viPosMontoReg_Ini = -1;
			LET viPosMontoReg_Fin = -1;
			
			-- ########################### Layout de MASTERCARD - OXXO   ##########################################
			
		ELIF (piTipoLayOut = 1) THEN --ELIF (1.1)
		
			-- SE registran valores de encabezado
			
			LET vsHeader = (SELECT TRIM(Registro) FROM BdiTarjeta:"informix".Td_Carga_Archivo_mc  WHERE Registro MATCHES 'FHDR*');
			
			LET viIdHeaderMasterCard = SUBSTR(vsHeader,11,10);
			
			--BORRA LOS REGISTROS DE ENCABEZADO
		
			 LET vsTrailer = (SELECT TRIM(Registro) FROM BdiTarjeta:"informix".Td_Carga_Archivo_mc  WHERE Registro MATCHES 'FTRL*');
			 
			 LET viIdTrailerMasterCard = SUBSTR(vsTrailer,5,10);
			 
			 LET vsStrl = (SELECT FIRST 1 TRIM(Registro) FROM BdiTarjeta:"informix".Td_Carga_Archivo_mc  WHERE Registro MATCHES 'STRL*');
			 
			 LET viTipoStrl = SUBSTR(vsStrl,16,1);
			 LET vsTipoSTRL = SUBSTR(vsStrl,1,4);
		
		
			LET vsTipoSumario = 'FTRL';
		
			-- datos del STRL (trailer de la txn Finnacieras)
			-- Registros TXN
			LET viInicioCadena_Reg_deb = 41; -- 8 caracteres
			LET viInicioCadena_Reg_cre = 63; -- 8 caracteres
			-- Montos
			LET viInicioCadena_Monto_deb = 27; -- 14 caracteres
			LET viInicioCadena_Monto_cre = 49; -- 14 caracteres
			LET viInicioCadena_Monto = 164; -- 14 caracteres
			
			-- Son para Monto total del archivo, extrayendo datos de detalle
		
			LET viPosMontoReg_Ini = 176;  -- Inicio de monto en el detalle de txt (FREC)
			LET viPosMontoReg_Fin = 12;  -- Cantidad de caracteres del monto 
			
			-- END ELIF (1.1)

		ELSE -- ERROR EN CASO QUE NO SE ENCUENTRE ALGUN LAYOUT
		
			LET vsTipoSumario = 'ERROR LAYOUT';
			LET viInicioCadena_Reg = 0;
			LET viInicioCadena_Monto = 0;
			LET viPosMontoReg_Ini = 0;
			LET viPosMontoReg_Fin = 0;
			
		END IF; -- IF (1)
	
		
		IF (TRIM(vsTipoSumario) = 'ERROR HEADER') THEN --ERROR. NO CONTIENE EL ENCABEZADO CORRESPONDIENTE IF (2)
			LET vsCodRet = '00100';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CONTIENE EL ENCABEZADO CORRESPONDIENTE AL TIPO LAYOUT: ' || piTipoLayOut || '.';
        ELIF (TRIM(vsTipoSumario) = 'ERROR LAYOUT') THEN --ERROR. NO CORRESPONDE A NINGUN LAYOUT
			LET vsCodRet = '00101';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CORRESPONDE A NINGUN TIPO DE LAYOUT REGISTRADO.';
        ELIF (NOT EXISTS (SELECT TRIM(Registro) FROM BdiTarjeta:"informix".Td_Carga_Archivo_mc WHERE Registro MATCHES (vsTipoSumario || '*'))) THEN --NO CONTIENE REGISTRO DE SUMARIO
			LET vsCodRet = '00102';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CONTIENE REGISTRO DE SUMARIO/TRAILER.';
		ELSE 
			--- VALIDA TRAILER
			LET vsMensaje_Respuesta = 'OBTENER REGISTRO DE SUMARIO/TRAILER.';
			
			IF piTipoLayOut = '1'  THEN -- IF (2.1)
			
				SELECT FIRST 1 TRIM(Registro), 
						( SUBSTR(Registro, viInicioCadena_Reg_deb, 8)) AS Enc_Total_Registros_deb,  --TOTAL REGISTROS DE DEBITO STRL 
						( SUBSTR(Registro, viInicioCadena_Reg_cre, 8)) AS Enc_Total_Registros_cre,  --TOTAL REGISTROS DE CREDITO STRL 
						( SUBSTR(Registro, viInicioCadena_Monto_deb, 14) ) AS Enc_Monto_Total_deb, 	--MONTO TOTAL DE COMPRAS DEBITO
						( SUBSTR(Registro, viInicioCadena_Monto_cre, 14) ) AS Enc_Monto_Total_cre, 	--MONTO TOTAL DE COMPRAS CREDITO
						( SUBSTR(Registro, viInicioCadena_Monto, 14) ) AS Enc_Monto_Total 	--MONTO TOTAL DE COMPRAS CREDITO				
					INTO vsRegistro,
							vsEnc_Total_Registros_deb,
								vsEnc_Total_Registros_cre,
									vsEnc_Monto_Total_deb,
										vsEnc_Monto_Total_cre,
											vsEnc_Monto_Total
				FROM BdiTarjeta:"informix".Td_Carga_Archivo_mc 
					WHERE Registro MATCHES (vsTipoSTRL || '*')
				AND SUBSTR(Registro,16,1)= viTipoStrl;
				
			ELSE
			
				LET vsMensaje_Respuesta = 'NO SE OBTUVO REGISTRO DE SUMARIO/TRAILER STRL.';
				
			END IF; -- IF (2.1)
			
			LET vsMensaje_Respuesta = 'VALIDAR TOTAL REGISTROS EN SUMARIO/TRAILER.';
			
			--VALIDA QUE CONTENGA SOLO NUMEROS TOTAL REGISTROS
			
			EXECUTE PROCEDURE BdiTarjeta:"informix".sp_ConcReing_EsNumerico( vsEnc_Total_Registros_deb ) INTO vsFlagNumerico_Reg_deb;
			EXECUTE PROCEDURE BdiTarjeta:"informix".sp_ConcReing_EsNumerico( vsEnc_Total_Registros_cre ) INTO vsFlagNumerico_Reg_cre;
			
			IF ( piTipoLayOut = 1) THEN -- SE VALIDA MONTO DE STRL TOTAL -- #### IF (2.2)
			
				LET vsMensaje_Respuesta = 'VALIDAR MONTO TOTAL EN SUMARIO/TRAILER.';
				
				--VALIDA QUE CONTENGA SOLO NUMEROS TOTAL MONTO TOTAL DE STRL
				
				EXECUTE PROCEDURE BdiTarjeta:"informix".sp_ConcReing_EsNumerico( vsEnc_Monto_Total ) INTO vsFlagNumerico_Monto;

				IF ((vsFlagNumerico_Monto = 'V') AND (piTipoLayOut = 1) AND (psSistema = 'A')) THEN -- IF (2.2.1)
					--SOLO CUANDO EL SISTEMA SEA "A" MEZCLADO CREDITO Y DEBITO

					--VALIDA QUE CONTENGA SOLO NUMEROS TOTAL MONTO
					EXECUTE PROCEDURE BdiTarjeta:"informix".sp_ConcReing_EsNumerico( vsEnc_Monto_Total_deb ) INTO vsFlagNumerico_Monto_deb;
					-- Para validar montos de dispocisiones
					EXECUTE PROCEDURE BdiTarjeta:"informix".sp_ConcReing_EsNumerico( vsEnc_Monto_Total_cre ) INTO vsFlagNumerico_Monto_cre;
					
				END IF; -- IF (2.2.1)
			
			ELSE
			
				LET vsFlagNumerico_Monto = 'V';
				
			END IF; -- IF (2.2)
			
			IF (vsFlagNumerico_Reg_deb = 'F' AND vsFlagNumerico_Reg_cre = 'F' ) THEN --ERROR TOTAL REGISTROS NO ES NUMERICO -- IF (2.3)
                LET vsCodRet = '00103';
                LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') CONTIENE UN TOTAL REGISTROS NO NUMERICO.';
            ELIF (vsFlagNumerico_Monto = 'F') THEN --ERROR MONTO TOTAL NO ES NUMERICO
                LET vsCodRet = '00104';
                LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') CONTIENE UN MONTO TOTAL NO NUMERICO.';
            ELIF (vsFlagNumerico_Monto_deb = 'F' AND vsFlagNumerico_Monto_deb = 'F') THEN --ERROR MONTO TOTAL NO ES NUMERICO
                LET vsCodRet = '00105';
                LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') CONTIENE UN MONTO TOTAL NO NUMERICO.';
			
			ELSE -- SI TODO LOS REGISTROS SON NUMERICOS SE REALIZA LO SIGUIENTE:
			
                LET vsMensaje_Respuesta = 'TODOS SOMOS NUMEROS';
			
				IF (viIdHeaderMasterCard = viIdTrailerMasterCard) THEN -- IF (2.3.1)
				
					
					LET vsMensaje_Respuesta = 'SI SON IGUALES';
					
                    BEGIN WORK;
                        DELETE FROM BdiTarjeta:"informix".Td_Carga_Archivo_mc WHERE Registro MATCHES 'FHDR*';
                        DELETE FROM BdiTarjeta:"informix".Td_Carga_Archivo_mc WHERE Registro MATCHES 'SHDR*';
                        DELETE FROM BdiTarjeta:"informix".Td_Carga_Archivo_mc WHERE Registro MATCHES 'STRL*';
                        DELETE FROM BdiTarjeta:"informix".Td_Carga_Archivo_mc WHERE Registro MATCHES 'FTRL*';
                        DELETE FROM BdiTarjeta:"informix".Td_Carga_Archivo_mc WHERE Registro MATCHES 'NREC*';
                        DELETE FROM BdiTarjeta:"informix".Td_Carga_Archivo_mc WHERE Registro MATCHES 'FPST*';
						DELETE FROM BdiTarjeta:"informix".Td_Carga_Archivo_mc WHERE Registro MATCHES 'FPS2*';
						DELETE FROM BdiTarjeta:"informix".Td_Carga_Archivo_mc WHERE Registro MATCHES 'EREC*';
					COMMIT WORK;
                    
					--- Recuentro de los registros de CREDITO y DEBITO
					SELECT COUNT(Registro) INTO viTotalRegistros FROM BdiTarjeta:"informix".Td_Carga_Archivo_mc;
					
					LET vsEnc_Total_Registros_deb = (TRIM(vsEnc_Total_Registros_deb)::INTEGER);
					LET vsEnc_Total_Registros_cre = (TRIM(vsEnc_Total_Registros_cre)::INTEGER);
					LET vsEnc_Total_Registros = (vsEnc_Total_Registros_deb + vsEnc_Total_Registros_cre);
					
					IF ((viTotalRegistros) <> (TRIM(vsEnc_Total_Registros)::INTEGER) ) THEN -- IF (2.3.1.a)
						
						--VALIDA LO REPORTADO EN EL SUMARIO CON EL CONTENIDO EL ARCHIVO
						
						LET vsCodRet = '00105'; --CANTIDADES DISTINTAS DE REGISTROS
						LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || trim(psNomArchivo) || ')'
						||' CONTIENE DISCREPANCIAS EN EL TOTAL DE REGISTROS REPORTADOS Y LOS CONTENIDOS EN EL ARCHIVO.';
						LET viTotalRegistros = 0;
					
					END IF;	-- IF (2.3.1.a)
					
					IF (vsCodRet = '00000') THEN -- IF (2.3.1.b)
						LET vsMensaje_Respuesta = 'CALCULAR MONTO TOTAL EN EL ARCHIVO.';
						--OBTIENE EL MONTO DEL ARCHIVO
						SELECT NVL(SUM((REPLACE(SUBSTR(Registro, viPosMontoReg_Ini, viPosMontoReg_Fin),'.',''))::MONEY)/100, 0.0) 
                            INTO vmTotalMonto FROM BdiTarjeta:"informix".Td_Carga_Archivo_mc;
						
						LET vsEnc_Monto_Total_deb = (vsEnc_Monto_Total_deb::MONEY)/100;
						LET vsEnc_Monto_Total_cre = (vsEnc_Monto_Total_cre::MONEY)/100;
						
						LET vsEnc_Monto_Total = vsEnc_Monto_Total_deb + vsEnc_Monto_Total_cre;
						

						--VALIDA QUE EL MONTO REPORTADO EN EL SUMARIO CON EL CONTENIDO EL ARCHIVO 
						IF (vmTotalMonto <> vsEnc_Monto_Total )  THEN 
                            LET vsCodRet = '00106';
                            LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || trim(psNomArchivo) || 
                                                      ') CONTIENE DISCREPANCIAS EN EL MONTO TOTAL REPORTADO Y EL CONTENIDO(' || vmTotalMonto || ').';
						END IF;

					END IF;	-- IF (2.3.1.b)
					
				END IF; -- IF (2.3.1)
			
			END IF; -- IF (2.3)

		END IF; -- IF (2)
					
		RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta), NVL(viTotalRegistros, 0), NVL((vmTotalMonto), 0.0), 1;
		
	END

END PROCEDURE
DOCUMENT
'MODIFICO: Victoria QuiÃÂ±ones',
'Proyecto: ',
'Solicito: Jose Luis Puebla',
'Descripcion: ConciliaciÃÂ³n MASTERCARD - OXXO ',
'Fecha: 2018/06/05',
'Version: 20170605.1000',
'BD: BdiTarjeta',
'#2 ',
'Armando Garcia ',
'Coord. Admon. Tarjetas - Gerencia I ',
'Descripcion: Es incluido el nuevo sp para cargar y registrar la informacion del archivo recibido por Mastercard-Corresponsales',
'Fecha de modificaciÃÂ³n: 05 de agosto del 2021',
'BD: BdiTarjeta',
'#3 ',
'Luis Daniel Bautista Zamora ',
'Coord. Admon. Tarjetas - Gerencia I ',
'Descripcion: Se agrega DELETE para quitar nueva linea(FPS2) agregada por MC al archivo',
'Fecha de modificaciÃÂ³n: 03 de julio del 2023',
'BD: BdiTarjeta',
'4 ',
'Luis Gerardo MartÃ­nez Rangel ',
'Coord. Admon. Tarjetas - Gerencia I ',
'Descripcion: Se agrega DELETE para quitar nueva linea(EREC) agregada por MC al archivo como soluciÃ³n temporal',
'Fecha de modificaciÃÂ³n: 09 de Agosto del 2023',
'BD: bditarjeta'
;

CREATE PROCEDURE "informix".sp_concreing_buscarmovimientointercard(
		psCve_usuario 			 CHAR(10),
		psNumtarjeta 			 CHAR(16),
		psSecuencia325 			 CHAR(6),
		psMonto325 				 CHAR(13),
		psMontoCashBack325 		 CHAR(13),
		ps_secuencia_ext_archivo CHAR (15),
		ps_ArchivoOriIST 		 CHAR (3),
		ps_MSI			 		 VARCHAR (02),
		ps_vspromoMSI	 		 VARCHAR (02)
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
	INTEGER AS Tipo_cnc_msi;

	/*
	*****************************************************************************************************
	-- DESCRIPCION:  OBTIENE EL MOVIMIENTO ORIGINAL DE INTERCARD:MOVIMIENTO  ----------------------------
	-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
	-- FECHA : 24/06/2011  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Reingenieria de la conciliacion automatica / Conciliacion Intercard  -------------------
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
	DEFINE contador_msi integer;
	DEFINE vsTipo_cnc_msi integer;
	DEFINE msi_secuencia_extendida VARCHAR(16);
	
	DEFINE vsnum_credito_msi CHAR(20);
	DEFINE vsnumcte_msi CHAR(20);
	DEFINE vmmonto325_msi money;
	
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
	LET contador_msi = 0;
	LET vsTipo_cnc_msi = 0;
	LET msi_secuencia_extendida = '';
	
	LET vsnum_credito_msi = '';
	LET vsnumcte_msi = '';
	LET vmmonto325_msi = 0;
	
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
					NVL(vsTipo_cnc_msi,0);

		END EXCEPTION;

		--SET DEBUG FILE TO '/RESPALDOSNEW/__argoz/cnc/cnc_msi/sp_concreing_buscarmovimientointercard.out';
		--TRACE ON;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		-----------------------------------------------------
		--------REINGENIERIA-CONCILIACION-AUTOMATICA---------
		--------2011/06/24-ING-ALFONSO-CRUZ------------------
		-----------------------------------------------------
		IF ( ps_ArchivoOriIST IN ('IST')) THEN 
		
			SELECT FIRST 1 numtarjeta,
				secuencia, 
				secuenciaextendida, 
				(NVL(monto,0) + NVL(montosurcharge,0)),
				montocashback, --IntegraciÃ³n de Monto CashBack
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
				codgironeg --TFORZADA
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
				vsCodGiroNeg --TFORZADA
			FROM intercard:"informix".movimiento
			WHERE 	numtarjeta = psNumtarjeta AND 
					secuenciaextendida = ps_secuencia_ext_archivo;
					
					
			IF ( (vsNumtarjeta IS NULL) OR ( TRIM (vsNumtarjeta) = '') ) THEN
					
				/*NO EXISTE EL MOVIMIENTO ORIGINAL*/
				LET vssqlerr = '00400';
				LET vsErrorActividad = 'NO EXISTE EL MOVIMIENTO INTERCARD';
			
			end if;
			
		
		ELSE		
	
			LET vsSecuencia = "1"||psSecuencia325;
			
			select 
				count(*) into contador
			from intercard:"informix".movimiento
				where 	numtarjeta = psNumtarjeta AND 
						secuencia = vsSecuencia;

			if (contador = 1) then 			
					SELECT FIRST 1 numtarjeta,
						secuencia, 
						secuenciaextendida, 
						(NVL(monto,0) + NVL(montosurcharge,0)),
						montocashback, --IntegraciÃ³n de Monto CashBack
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
						codgironeg --TFORZADA
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
						vsCodGiroNeg --TFORZADA
					FROM intercard:"informix".movimiento
					WHERE 	numtarjeta = psNumtarjeta 
					AND secuencia = vsSecuencia
				AND codigoiso = '00';
				
			elif (contador >= 2) then 
				
				SELECT limit 1 numtarjeta,
						secuencia, 
						secuenciaextendida, 
						(NVL(monto,0) + NVL(montosurcharge,0)),
						montocashback,
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
						codgironeg --TFORZADA
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
						vsCodGiroNeg
					FROM intercard:"informix".movimiento
					WHERE 	numtarjeta = psNumtarjeta AND 
							secuencia = vsSecuencia AND
							movconciliado = 'F' AND
							codigoiso = '00';

			END IF;
			
			
			IF ( (vsNumtarjeta IS NULL) OR ( TRIM (vsNumtarjeta) = '') ) THEN
			
				LET vmMonto325 = ( ( REPLACE( psMonto325,'.',''))::MONEY /100 );
				SELECT limit 1 numtarjeta,
						secuencia, 
						secuenciaextendida, 
						(NVL(monto,0) + NVL(montosurcharge,0)),
						montocashback,
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
						codgironeg --TFORZADA
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
						vsCodGiroNeg
					FROM intercard:"informix".movimiento
					WHERE 	numtarjeta = psNumtarjeta AND 
							secuencia = vsSecuencia AND
							movconciliado = 'P' AND
							codigoiso = '00' AND							
							monto >= vmMonto325;
							
					IF ( (vsNumtarjeta IS NULL) OR ( TRIM (vsNumtarjeta) = '') ) THEN
							
					/*NO EXISTE EL MOVIMIENTO ORIGINAL*/
					LET vssqlerr = '00400';
					LET vsErrorActividad = 'NO EXISTE EL MOVIMIENTO INTERCARD';
					
					end if;
				
			END IF;
			
			IF ( ps_MSI <> '00' ) THEN

				LET vmMonto325_msi = ( ( REPLACE( psMonto325,'.',''))::MONEY /100 );

				SELECT COUNT (*), secuenciaextendida
                    INTO contador_msi, msi_secuencia_extendida
                FROM intercard:"informix".bitacora_msi 
					WHERE 	numtarjeta = psNumtarjeta 
				AND secuencia = vsSecuencia
                    GROUP BY secuenciaextendida;
				
				SELECT LIMIT 1 num_credito,numcte
					INTO vsnum_credito_msi,vsnumcte_msi
					FROM bdicred:"informix".sd_tarjeta 
					WHERE empresa ='001' AND tipo_tarjeta IN ('T' , 'A')
				AND num_tarjeta = psNumtarjeta;
				
				IF (contador_msi > 0) THEN
				
					UPDATE intercard:"informix".bitacora_msi 
                        SET movconciliado = 'V' 
                    WHERE secuenciaextendida = msi_secuencia_extendida;
					
					LET vsTipo_cnc_msi =1; -- Se encuentra transaccion en bitacora_msi

				INSERT INTO bdicred:sd_promocion_credito
							(empresa,sistema,num_promo,fecha,ejecutivo,num_cte,num_credito,num_tarjeta,plazo,folio_suc,monto_actual,monto_int_iva,mensualidad,status,nombre_promo,sucursal,num_sol_prestamo,num_pro_prestamo,folio_movto) 
					 VALUES ('001','06',10, TODAY, 'informix', vsnumcte_msi, vsnum_credito_msi,psNumtarjeta ,ps_vspromoMSI ,'i'||vsSecuencia_extendida,vmMonto325_msi ,0,0,0, 'COMPRA MESES SIN INTERESES', '0001', '' ,'8900', 'i'||vsSecuencia_extendida);
					 
				
				END IF;
			
			END IF;
		
			-- Para recuperar el monto correcto de la compra POS y la disposicion del efectivo a identificar RRM
			
			IF vmMontointercardcashback > 0 THEN
				LET vmMontointercard = vmMontointercard - vmMontointercardcashback;
			END IF;	

		END IF;
		
		

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
			NVL(vsTipo_cnc_msi,0);

	END

END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Reingenieria de la Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: OBTIENE EL MOVIMIENTO ORIGINAL DE INTERCARD:MOVIMIENTO.',
'Fecha: 2011/06/24',
'Version: 20110624.1601',
'BD: bditarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion -DEVOLUCIONES',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA EL CAMPO DE [FORMATO] A LA CONSULTA Y EL RETORNO DEL SP.',
'Fecha: 2012/05/21',
'Version: 20120521.1231',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion ',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA LA OBTENCION DE LOS CAMPOS CodReversa Y CodigoCentral PARA LAS CONCILIACION DE ATM.',
'Fecha: 2012/07/27',
'Version: 20120727.1433',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion ',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA EL MONTOSURCHARGE AL MOTO DE LA OPERACION.',
'Fecha: 2012/08/24',
'Version: 20120824.1703',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo ResÃ©ndiz Martinez',
'Proyecto: Reingenieria Conciliacion ',
'Solicito: Luis Antonio Gomez',
'Descripcion: Se agrega validaciÃ³n para contemplar secuencias iguales a una tarjeta de operaciones diferentes ',
'Fecha: 2013/05/30',
'Version: 20130530.1400',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo ResÃ©ndiz Martinez',
'Proyecto: Reingenieria Conciliacion ',
'Solicito: Luis Antonio Gomez',
'Descripcion: Se agrega Extraccion de columna del Monto CashBack ',
'Fecha: 2013/07/29',
'Version: 20130729.1416',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo ResÃ©ndiz Martinez',
'Proyecto: Reingenieria Conciliacion ',
'Solicito: Luis Antonio Gomez',
'Descripcion: Se agrega Modificacion del monto Intercard Recuperado cuando el monto cash Back es Mayor a 0',
'Fecha: 2013/09/18',
'Version: 20130918.1900',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo ResÃ©ndiz Martinez',
'Proyecto: Reingenieria Conciliacion ',
'Solicito: Jose Luis Puebla ',
'Descripcion: Se agrega Modificacion del monto Intercard Recuperado cuando el monto cash Back es Mayor a 0',
'Fecha: 2015/07/08',
'Version: 20150708.1200',
'BD: BdiTarjeta',
'',
'MODIFICACION: L.I.A. Ricardo ResÃ©ndiz MartÃ­nez',
'Proyecto: RQM 06 384 Proceso de ConciliaciÃ³n de Transacciones Forzadas',
'Solicito: Jose Luis Puebla Salinas ',
'Descripcion: Se agrega proceso para recuperacion de campo Codigo Giro Negocio y verificaciÃ³n para cuando hay mas de registros por cantidades diferentes ',
'Fecha: 2015/09/17',
'Version: 20150917.1220',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_clasifica_devpos
(
	psNomArchivo VARCHAR(23), 
	psArchivoOrigen VARCHAR(3), 
	pdtFecha_Archivo DATE, 
	psSistema VARCHAR(1), --TipoArchivo,
	psNumTarjeta VARCHAR(20), 
	psSecuencia325 VARCHAR(6), --SecuenciaAutArchivo
	psMonto325 VARCHAR(13), --MontoArchivo
	psMontoCashBack325 VARCHAR(13), --Monto cash Back Archivo
	psNomcomercio325 VARCHAR(30), --NomComercio
	psReferencia23_325 VARCHAR(23), --Referencia
	pmMontoIntercard MONEY, --MontoIntercard
	pmMontoCashBack MONEY, --Monto Cash Back Intercard
	piTipo_Conciliacion INTEGER
)

RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta, INTEGER AS Elemento;
		  
--****************************************************************************************************
-- DESCRIPCION: GUARDA REGISTRO DE LOS TIPOS DE DEVOLUCIONES PROCESADAS EN LA REINGENIERIA DE LA CONCILIACION PARA ADMINISTRAR SU CORRECTA APLICACION.
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 07/05/2012
-- BD: BdiTarjeta
-- SISTEMA : Reingenieria Conciliacion -- DEVOLUCIONES
-- MODIFICADO : Casanova Edeza Hector Juan  21/05/2012  SE MODIFICO LA LOGICA DE CLASIFICACION DE LAS DEVOLUCIONES Y LOS MENSAJES RELACIONADOS PARA CADA TIPO DE CLASIFICACION.
--***************************************************************************************************


/*  DEFINICION DE VARIABLES */
DEFINE viSQLerr INTEGER;
DEFINE vsCodRet VARCHAR(5);
DEFINE vsMensaje_Respuesta VARCHAR(250);
DEFINE vsEstado VARCHAR(1);
DEFINE vsMotivo VARCHAR(60);
DEFINE vsFileName VARCHAR(23);
DEFINE vsEncontrado VARCHAR(1);

DEFINE vsAplicado VARCHAR(1);

/* INICIALIZACION DE VARIABLES */
LET viSQLerr = 0;
LET vsCodRet = '00000';
LET vsMensaje_Respuesta = '';
LET vsEstado = '';
LET vsMotivo = '';
LET vsFileName = '';
LET vsEncontrado = 'F';

LET vsAplicado = '';

BEGIN

	ON EXCEPTION SET viSQLerr
		
		-- Se comentan instrucciones ya que solo basta con indicarlas una vez al inicio del proceso 07/09/2023
		-- SET LOCK MODE TO WAIT 3;
		-- SET ISOLATION TO DIRTY READ;
		
		LET vsCodRet = '01500';
		LET vsMensaje_Respuesta = '[' || vsCodRet ||  '] ERROR NO CONTROLADO (' || viSQLerr || ').  ARCHIVO: ['|| psNomArchivo ||'] TARJETA: ['|| psNumTarjeta ||'] SECUENCIA: ['|| psSecuencia325 ||']' ;
		
		RETURN vsCodRet, vsMensaje_Respuesta, 15;
		
	END EXCEPTION;

	--SET DEBUG FILE TO "/informix/HomeInformix/rrm/DEVPOS.out";
	--TRACE ON;
	
	--VALORES POR DEFAULT EN CASO DE NO CONTENER INFORMACION/NULL
	LET pdtFecha_Archivo = NVL(pdtFecha_Archivo,CURRENT::DATE);
	LET psMonto325 = NVL(psMonto325, '0000000000000');
	LET psMontoCashBack325 = NVL (psMontoCashBack325, '0000000000000'); --- Por cash Back
	LET psNomcomercio325 = NVL(psNomcomercio325, '');
	LET psReferencia23_325 = NVL(psReferencia23_325, '');
	LET pmMontoIntercard = NVL(pmMontoIntercard, 0.0);
	LET pmMontoCashBack = NVL(pmMontoCashBack, 0.0);
	 
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF (piTipo_Conciliacion = 0) THEN --CONCILIADA INTERCARD
		LET vsEncontrado = 'F';
		LET vsEstado = 'P';
		LET vsAplicado = 'E';
		LET vsMotivo = 'Devolución no aplicada por integridad';	
	
	ELIF (piTipo_Conciliacion in ( 10,47,25 )) THEN --CONCILIADA INTERCARD
		
		LET vsEncontrado = 'V';
		LET vsEstado = 'P';
		
		IF ((((psMonto325::MONEY)/100) > pmMontoIntercard) or (((psMontoCashBack325::MONEY)/100) > pmMontoCashBack)) THEN  --MONTO MAYOR
			LET vsAplicado = 'F';
			LET vsMotivo = 'Devolución con monto mayor a la compra original';
		ELSE -- MOVCONCILIADO F
			LET vsAplicado = 'E';
			LET vsMotivo = 'La compra original todavía no esta marcada como conciliada';
		END IF;
		
	ELIF (piTipo_Conciliacion in (12, 32)) THEN --NO APLICADA
		
		LET vsEncontrado = 'F';
		LET vsEstado = 'P';
		LET vsAplicado = 'F'; 
		LET vsMotivo = 'Devolución no aplicada al cliente por inconsistencia';
		
	ELIF (piTipo_Conciliacion = 15) THEN --ERROR DE APLICACION
		
		LET vsEncontrado = 'V';
		LET vsEstado = DECODE(((psMonto325::MONEY)/100), pmMontoIntercard, 'A', 'F');  --APLICADO / FORZADO
		LET vsAplicado = 'E';
		LET vsMotivo = 'Devolución correcta no abonada por problemas en sistema';
		
	ELIF (piTipo_Conciliacion in (11, 48, 26)) THEN --FORZADA
		--MONTO MENOR AL REPORTADO EN LA TRANSACCION ORIGINAL.
		--APLICACION FORZADA
		
		LET vsEncontrado = 'V';
		LET vsEstado = 'F'; --FORZADO
		LET vsAplicado = 'V';	
		LET vsMotivo = 'La devolución se abono con monto menor';
		
	ELIF (piTipo_Conciliacion in  (14, 49, 27)) THEN --APLICADA
		--CONCILIADA (OK), SE APLICA
		
		LET vsEncontrado = 'V';
		LET vsEstado = 'A'; --APLICADO
		LET vsAplicado = 'V';
		LET vsMotivo = 'La devolución se abono al cliente';
		
	ELSE
		--TIPO DE DEVOLUCION INVALIDO
		LET vsEstado = ''; 
		LET vsAplicado = '';
		LET vsCodRet = '01501';
		LET vsMensaje_Respuesta = 'TIPO DE CONCILIACIÓN INVALIDO [' || piTipo_Conciliacion || '] ARCHIVO: [' || psNomArchivo || '] TARJETA: [' || psNumTarjeta || '] SECUENCIA: [' || psSecuencia325 || ']';
	END IF;
	
	IF (vsCodRet = '00000') THEN --VALIDA QUE EL TIPO DE DEVOLUCION SEA UNO VALIDO
		
		--GENERA CONTENIDO DEL CAMPO FILENAME
		LET vsFileName = NVL(psArchivoOrigen,'') 
			|| LPAD(DAY(pdtFecha_Archivo), 2, '0') --DIA
			|| LPAD(MONTH(pdtFecha_Archivo), 2, '0') --MES
			|| (YEAR(pdtFecha_Archivo))::VARCHAR(4); --AÑO
		
		LET vsEncontrado = DECODE (NVL(pmMontoIntercard, 0.0), 0.0, 'F', 'V');
		
		-- Se comentan instrucciones ya que solo basta con indicarlas una vez al inicio del proceso 07/09/2023
		-- SET LOCK MODE TO WAIT 3;
		-- SET ISOLATION TO DIRTY READ;
		
		--VALIDA SI EXISTE EL MOVIMIENTO EN LA TABLA
		IF ( EXISTS(
			SELECT NomArchivo 
			FROM BdiTarjeta:"informix".Td_DevolucionesPOS   
			WHERE NomArchivo = NVL(psNomArchivo,'')
			AND ArchivoOrigen = NVL(psArchivoOrigen,'')
			AND Fecha = NVL(pdtFecha_Archivo,CURRENT::DATE)
			AND NumTarjeta = NVL(psNumTarjeta, '')
			AND SecuenciaAutArchivo = NVL(psSecuencia325, '')
		)) THEN
		
			--ACTUALIZA EL REGISTRO EXISTENTE DE DEVOLUCION
			-- SET LOCK MODE TO WAIT 3;
			-- SET ISOLATION TO DIRTY READ;
			UPDATE BdiTarjeta:"informix".Td_DevolucionesPOS SET
				NomArchivo = NVL(psNomArchivo,''),
				ArchivoOrigen = NVL(psArchivoOrigen,''), 
				Fecha = NVL(pdtFecha_Archivo,CURRENT::DATE), 
				FileName = NVL(vsFileName,''),
				TipoArchivo = NVL(psSistema,''), 
				NumTarjeta = NVL(psNumTarjeta, ''), 
				SecuenciaAutArchivo = NVL(psSecuencia325, ''), 
				MontoArchivo = NVL(((psMonto325::MONEY)/100), 0.0), 
				montocashbackarchivo = NVL(((psMontoCashBack325::MONEY)/100), 0.0), -- Por Cash Back 
				NomComercio = NVL(psNomcomercio325, ''), 
				Referencia = NVL(psReferencia23_325, ''), 
				Encontrado = NVL(vsEncontrado, ''), 
				MontoIntercard = NVL(pmMontoIntercard, 0.0),
				montocashbackintercard = NVL(pmMontoCashBack, 0.0), -- Por Monto Cash Back
				Motivo = NVL(vsMotivo, ''),
				Estado = NVL(vsEstado, ''),
				Aplicado = NVL(vsAplicado, '')
			WHERE NomArchivo = NVL(psNomArchivo,'')
			AND ArchivoOrigen = NVL(psArchivoOrigen,'')
			AND Fecha = NVL(pdtFecha_Archivo,CURRENT::DATE)
			AND NumTarjeta = NVL(psNumTarjeta, '')
			AND SecuenciaAutArchivo = NVL(psSecuencia325, '');
			
		
		ELSE
			-- Se comentan instrucciones ya que solo basta con indicarlas una vez al inicio del proceso 07/09/2023
			-- SET LOCK MODE TO WAIT 3;
			-- SET ISOLATION TO DIRTY READ;
			
			-- INSERTA EL NUEVO REGISTRO DE DEVOLUCION
			INSERT INTO BdiTarjeta:"informix".Td_DevolucionesPOS 
			(
				NomArchivo, 
				ArchivoOrigen, 
				Fecha, 
				FileName,
				TipoArchivo, 
				NumTarjeta, 
				SecuenciaAutArchivo, 
				MontoArchivo, 
				montocashbackarchivo, --Se agrega para monto cash back de archivo 325
				NomComercio, 
				Referencia, 
				Encontrado, 
				MontoIntercard, 
				montocashbackintercard, --Se agrega por monto cashback de Intercard
				Motivo,
				Estado,
				Aplicado
			) 
			VALUES 
			(
				NVL(psNomArchivo,''), 
				NVL(psArchivoOrigen,''), 
				NVL(pdtFecha_Archivo, CURRENT::DATE),  --FECHA
				NVL(vsFileName,''), --FileName
				NVL(psSistema,''),  --TIPOARCHIVO
				NVL(psNumTarjeta, ''), --NumTarjeta
				NVL(psSecuencia325, ''), --SecuenciaAutArchivo
				NVL(((psMonto325::MONEY)/100), 0.0),  --MontoArchivo
				NVL(((pmMontoCashBack::MONEY)/100), 0.0), --Monto Cash Back del 325
				NVL(psNomcomercio325, ''), --NomComercio
				NVL(psReferencia23_325, ''), --Referencia23
				NVL(vsEncontrado, ''), --Encontrado
				NVL(pmMontoIntercard, 0.0), --MontoIntercard
				NVL(pmMontoCashBack, 0.0), --MontoCashBack
				NVL(vsMotivo, ''), 
				NVL(vsEstado, ''),
				NVL(vsAplicado, '')
			);
		END IF;
	END IF;
	
	RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta), 15;

END;

END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion - DEVOLUCIONES',
'Solicito: Jose Luis Puebla',
'Descripcion: GUARDA REGISTRO DE LOS TIPOS DE DEVOLUCIONES PROCESADAS EN LA REINGENIERIA DE LA CONCILIACION PARA ADMINISTRAR SU CORRECTA APLICACION.',
'Fecha: 2012/05/07',
'Version: 20120507.0957',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion - DEVOLUCIONES',
'Solicito: Luis Gomez Santiago',
'Descripcion: SE MODIFICO LA LOGICA DE CLASIFICACION DE LAS DEVOLUCIONES Y LOS MENSAJES RELACIONADOS PARA CADA TIPO DE CLASIFICACION.',
'Fecha: 2012/05/21',
'Version: 20120521.1200',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martínez',
'Proyecto: Reingenieria Conciliacion - DEVOLUCIONES',
'Solicito: Luis Gomez Santiago',
'Descripcion: Se modifica por la integración del Monto Cash Back y los nuevos tipos de devoluciones .',
'Fecha: 2013/08/02',
'Version: 20130802.1300',
'BD: BdiTarjeta',
'',
'MODIFICACION: Maria Fernanda Ortiz Figueroa',
'Proyecto: Optimizacion Conciliacion Automatica',
'Solicito: Gerencia de Produccion y Base de Datos',
'Descripcion: Se eliminan instrucciones SET a lo largo del proceso, ya que solo deben indicarse una vez al inicio del proceso.',
'Fecha: 07/09/2033',
'Version: 20230907.1',
'BD: bditarjeta';

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