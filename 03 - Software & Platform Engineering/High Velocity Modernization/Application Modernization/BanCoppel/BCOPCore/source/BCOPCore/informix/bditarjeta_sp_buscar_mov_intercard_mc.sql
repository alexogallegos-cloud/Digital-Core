CREATE PROCEDURE "informix".sp_buscar_mov_intercard_mc(
		psCve_usuario 				CHAR(10),
		psNumtarjeta 				CHAR(16),
		psSecuencia325	 			CHAR(6),
		psMonto325 					CHAR(13),
		psMontoCashBack325 			CHAR(13),
		ps_secuencia_ext_archivo 	CHAR(15),
		ps_archivo_origenMC 		CHAR(03),
		psIdProcesador 				CHAR(05)
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
	CHAR(16) AS folio_reg;

	/*
	*****************************************************************************************************
	-- DESCRIPCION:  OBTIENE EL MOVIMIENTO ORIGINAL DE INTERCARD:MOVIMIENTO  ----------------------------
	-- AUTOR : Mo  -----------------------------------------------------------------------
	-- FECHA : 11/06/2018  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Conciliacion automatica de MasterCard - Oxxo / Conciliacion Intercard  -------------------
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
	
	/* FOLIO REGULATORIO */

	DEFINE vsFechaMov      		CHAR(04);
	DEFINE vsHoraMov      		CHAR(06);
	DEFINE vsvHoraLocalTrx     	CHAR(14);
	DEFINE vsFolio_Reg     		CHAR(16);

	
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
	
	/* FOLIO REGULATORIO */

	LET vsFechaMov  	='';
	LET vsHoraMov   	='';
	LET vsvHoraLocalTrx ='';
	LET vsFolio_Reg 	='';
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
					NVL(vsFolio_Reg,' ');

		END EXCEPTION;

		--SET DEBUG FILE TO '/informix/LVRQ/seven_new/debug/Buscamovintercard.out';
		--TRACE ON;
		
		LET vsSecuencia = "1"||psSecuencia325;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF ( ps_archivo_origenMC IN ('MCO')) THEN 
		
				SELECT FIRST 1 numtarjeta,
					secuencia, 
					secuenciaextendida, 
					(NVL(monto,0) + NVL(montosurcharge,0)),
					montocashback, --Integración de Monto CashBack
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
					codgironeg, --TFORZADA
					fechalocaltransaccion,
					horamov,
					horalocaltransaccion
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
					vsCodGiroNeg, --TFORZADA
					vsFechaMov,
					vsHoraMov,
					vsvHoraLocalTrx
				FROM intercard:"informix".movimiento
				WHERE 	numtarjeta = psNumtarjeta 
				AND secuenciaextendida = ps_secuencia_ext_archivo;
			
			IF ( (vsNumtarjeta IS NULL) OR ( TRIM (vsNumtarjeta) = '') ) THEN
					
				/*NO EXISTE EL MOVIMIENTO ORIGINAL*/
				LET vssqlerr = '00400';
				LET vsErrorActividad = 'NO EXISTE EL MOVIMIENTO INTERCARD';
			
			END IF;
		
			
		END IF;
		-- Para recuperar el monto correcto de la compra POS y la disposicion del efectivo a identificar RRM
		
		/* GENERACION DE FOLIO REGULATORIO */
		
		--TRACE 'psIdProcesador? = '|| psIdProcesador;	
		
			IF (psIdProcesador = 'OXXO' ) THEN
			
				--TRACE 'este es de Oxxo :'||vsFolio_Reg;

				LET vsFolio_Reg = TRIM(SUBSTR (vsInfreceptor,17,6) || vsFechaMov ||SUBSTR (vsvHoraLocalTrx,0,4) ||SUBSTR (vsHoraMov,5,2) ); -- oxxo
				
			ELIF (psIdProcesador = 'SEVEN' ) THEN	
				
				--TRACE 'este es de seven:'||vsFolio_Reg;

				LET vsFolio_Reg = TRIM(SUBSTR (vsIdTerminal,1,5) || vsFechaMov ||SUBSTR (vsvHoraLocalTrx,0,4) ||SUBSTR (vsHoraMov,5,2) ); -- seven
				
			ELSE
				LET vsFolio_Reg = '';
				
			END IF;

		--TRACE 'folio_reg = '|| vsFolio_Reg;	
		
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
			NVL(vsFolio_Reg,'');

	END

END PROCEDURE;