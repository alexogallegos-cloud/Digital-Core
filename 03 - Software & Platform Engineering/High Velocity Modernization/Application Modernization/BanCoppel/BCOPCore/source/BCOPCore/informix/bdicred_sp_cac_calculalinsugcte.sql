CREATE PROCEDURE "informix".sp_cac_calculalinsugcte
													(
														pEmpresa 		CHAR(3),
														pNumSolicitud	CHAR(20),
														pCompIngreso	CHAR(1),
														pIngresoMens	DECIMAL(18,2),
														pOtrosComp		DECIMAL(18,2)
													)
	RETURNING
		CHAR(6) 		AS COD_RET,
		CHAR(80)		AS MENSAJE_RET,
		DECIMAL(18,2)	AS LINEA_SUGERIDA,
		DECIMAL(18,2)	AS MONTO_INCREM,
		DECIMAL(4,2)	AS RAZON_INCREM,
		DECIMAL(5,2)	AS TASAINTERES_ANUAL_INCREM;

	---DECLARACIONES
	DEFINE iSqlErr				INTEGER;
	DEFINE iIsamErr				INTEGER;
	DEFINE cCodRet				CHAR(6);
	DEFINE cMensajeRet			CHAR(80);

	DEFINE dAum1				DECIMAL(18,2);
	DEFINE dAum2				DECIMAL(18,2);
	DEFINE sLineaCredito		SMALLINT;
	DEFINE dMontoOtor			DECIMAL(18,2);
	DEFINE dLineaSugerida		DECIMAL(18,2);
	DEFINE dLineaSolicitada		DECIMAL(18,2);
	DEFINE iNumPagos			INTEGER;
	DEFINE dtFechaNumPagos		DATE;
	DEFINE dtFechaHoy			DATE;
	DEFINE dCTP					DECIMAL(18,2);
	DEFINE dIDP					DECIMAL(18,2);
	DEFINE iPorcIngreso			INTEGER;
	DEFINE dCMA					DECIMAL(18,2);
	DEFINE dFCP					DECIMAL(18,2);
	DEFINE dCRA					DECIMAL(18,2);
	DEFINE dTIP					DECIMAL(18,2);
	DEFINE dPorcTopeValMin		DECIMAL(4,2);
	DEFINE dPorcTopeValMax_cci	DECIMAL(4,2);
	DEFINE dPorcTopeValMax_sci	DECIMAL(4,2);
	DEFINE dPagosRealizados		DECIMAL(18,2);
	DEFINE dCTC					DECIMAL(18,2);
	DEFINE dMontoIncremento		DECIMAL(18,2);
	DEFINE dRazonIncremento		DECIMAL(4,2);
	DEFINE dCompromPagoSIC		DECIMAL(18,2);
	DEFINE cBand1				CHAR(1);
	DEFINE dValorSM				DECIMAL(18,2);
	DEFINE dIngresoMensDec		DECIMAL(18,2);
	DEFINE dIngresoMaximo		DECIMAL(18,2);
	DEFINE dLineaMinima			DECIMAL(18,2);
	DEFINE dLineaMaxima_cci		DECIMAL(18,2);
	DEFINE dLineaMaxima_sci		DECIMAL(18,2);		
	DEFINE mCompromisosbanco    MONEY (14,2);
	DEFINE dImporte_hip		    MONEY (14,2);
	DEFINE dSalarioMin		    DECIMAL (18,2);
	DEFINE dTopeAbono		    DECIMAL (18,2);
	DEFINE dTopeSalMin		    DECIMAL (18,2);
	DEFINE cSucursal			CHAR(80);
	DEFINE dIvaSuc				DECIMAL(18,2);
	DEFINE dTasa_Interes        DECIMAL(9,6);		--	RQM 10 1224
	DEFINE dTasa_Mora           DECIMAL(9,6);	
	DEFINE cCodRetTDif			CHAR(6);

	---INICIALIZACIONES
	LET iSqlErr					= 0;
	LET iIsamErr           		= 0;
	LET cCodRet            		= '000000';
	LET cMensajeRet           	= 'PROCESO EXITOSO';
	LET dAum1					= 0.0;
	LET dAum2					= 0.0;
	LET sLineaCredito			= 0;
	LET dMontoOtor				= 0.0;
	LET dLineaSugerida			= 0.0;
	LET dLineaSolicitada		= 0.0;
	LET iNumPagos				= 0;
	LET dtFechaNumPagos			= DATE(1);
	LET dCTP					= 0.0;
	LET dIDP					= 0.0;
	LET iPorcIngreso			= 0;
	LET dCMA					= 0.0;
	LET dFCP					= 0.0;
	LET dCRA					= 0.0;
	LET dTIP					= 0.0;
	LET dPorcTopeValMin			= 0.0;
	LET dPorcTopeValMax_cci		= 0.0;
	LET dPorcTopeValMax_sci		= 0.0;
	LET dPagosRealizados		= 0.0;
	LET dCTC					= 0.0;
	LET dMontoIncremento		= 0.0;
	LET dRazonIncremento		= 0.0;
	LET dCompromPagoSIC			= 0.0;
	LET cBand1					= '0';
	LET dValorSM				= 0.0;
	LET dIngresoMensDec			= 0;
	LET dIngresoMaximo			= 0;
	LET dLineaMinima 			= 0 ;
	LET dLineaMaxima_cci 		= 0 ;
	LET dLineaMaxima_sci 		= 0 ;		
	LET mCompromisosbanco       = 0;	
	LET dImporte_hip           = 0;	
	LET dSalarioMin            = 0;								
	LET dTopeAbono             = 0;								
	LET dTopeSalMin            = 0;
	LET cSucursal              = '';
	LET dIvaSuc				   = 0.0;
	LET dTasa_Interes		   = 0; 				--	RQM 10 1224
	LET dTasa_Mora             = 0;	
	LET cCodRetTDif			   = 0;

	-- CMA - CAPACIDAD MAXIMA DE ABONOS
	-- CTP - CAPACIDAD TOTAL DE PAGOS
	-- IDP - INGRESO DEMOSTRADO EN PAGOS
	-- FCP - FACTOR PARA CAPACIDAD DE PAGO
	-- CRA - CAPACIDAD REAL DE ABONO

	BEGIN 
		ON EXCEPTION SET iSqlErr, iIsamErr, cMensajeRet
		   IF iSqlErr != 0 THEN
			  LET cCodRet = iSqlErr;
			  RETURN cCodRet, cMensajeRet, dLineaSugerida, dMontoIncremento, dRazonIncremento, dTIP ;
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		 --SET DEBUG FILE TO '/informix/jesus/sp_cac_calculalinsugcte.out';
		 --TRACE ON;

		-- VALIDA QUE LOS PARAMETROS DE ENTRADA NO ESTEN VACIOS
		IF NVL(pEmpresa,'') = '' OR NVL(pNumSolicitud,'') = '' OR NVL(pCompIngreso,'') = ''OR NVL(pIngresoMens,0.0) = 0.0 THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'FALTAN PARAMETROS DE ENTRADA';
		ELSE						
			-- obtencion del porcentaje para calcuar la linea de clientes con su linea actual menor a 1.27 sm 
			SELECT valor 
			INTO dAum2
			FROM bdicred:"informix".sd_param 
			WHERE cod_param = '017'
			AND empresa = pEmpresa;	
			-- validacion de los parametros.
			IF NVL(dAum2,0.0) = 0.0 THEN
				LET cCodRet = '000002';
				LET cMensajeRet = 'ERROR AL OBTENER PORCENTAJE DE INCREMENTO PARA SALARIOS MINIMOS MENORES A 1.27';
			ELSE
				-- obtencion del porcentaje para calcuar la linea de clientes con su linea actual mayor o igual a 1.27 sm 
				SELECT valor 
				INTO dAum1
				FROM bdicred:"informix".sd_param 
				WHERE cod_param = '016'
				AND empresa = pEmpresa;

				-- validacion de los parametros.
				IF NVL(dAum1,0.0) = 0.0 THEN
					LET cCodRet = '000003';
					LET cMensajeRet = 'ERROR OBTENER EL PORCENTAJE DE INCREMENTO DE SALARIOS MINIMOS MAYORES A 1.27';
				ELSE
					-- Compara créd con lín créd MN para increm línea
					SELECT valor 
					INTO sLineaCredito
					FROM bdicred:"informix".sd_param
					WHERE cod_param = '023'
					AND empresa = pEmpresa;

					IF NVL(sLineaCredito,'') = '' THEN
						LET cCodRet = '000004';
						LET cMensajeRet = 'ERROR AL OBTENER LA LINEA DE CREDITO A COMPARAR PARA INCREMENTOS DE LINEA';
					ELSE
						-- OBTIENE LOS DATOS DE LA SOLICTUD DE AUMENTO DE LINEA DE CREDITO
						SELECT a.lincred_actual, a.lincred_solicitada,c.ingreso_mensual,a.compromisos_bco,a.compromisos_hip,a.pago_minimo,a.abonomensual,a.ingreso_idp, a.sucursal										
						INTO dMontoOtor, dLineaSolicitada,dIngresoMensDec,mCompromisosbanco,dImporte_hip,dCompromPagoSIC, dCTC,dIDP, cSucursal
						FROM bdicred:"informix".sd_bitacora_aumlincred a						
						INNER JOIN bdisolic:"informix".ss_resum_scor_fin c ON  c.num_solicitud = a.num_solicitud AND c.empresa = a.empresa	
						WHERE a.empresa = pEmpresa
						AND a.num_solicitud = pNumSolicitud
						AND a.status = 'AC'
						AND a.fecha_insert = a.fecha_insert;
						IF dbinfo('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '000005';
							LET cMensajeRet = 'NO EXISTEN DATOS DE AUMENTO DE LINEA DE CREDITO PARA ESTA SOLICITUD';
						ELSE
						
							
							-- OBTIENE EL VALOR DEL SALARIO MINIMO INCREMENTO DE LINEA
							SELECT TRIM(valor)::DECIMAL(18,2)
							INTO dValorSM
							FROM bdicred:"informix".sd_param
							WHERE empresa = '001'
							AND cod_param = '013';
							
							LET dSalarioMin = ROUND ((dValorSM * 30.42),-2);
							-- TOPA EL INGRESO MENSUAL AL VALOR DEL SALARIO MINIMON DE INCREMENTO DE LINEA CUANDO ESTE ES MENOR A 1 SM
							IF pIngresoMens < dSalarioMin THEN
								LET pIngresoMens = dSalarioMin;
							END IF
							-- VALIDA QUE TIENE COMPROBANTE DE INGRESOS
							IF pCompIngreso = '1' THEN
								IF dIDP > pIngresoMens THEN	
									LET pIngresoMens = dIDP;									
								END IF
							-- VALIDA QUE NO TIENE COMPROBANTE DE INGRESOS
							ELSE											
								
								SELECT TRIM(valor)::DECIMAL(18,2) --se homologa al tope de ingresos demostrado productivo
								INTO dTopeSalMin
								FROM bdisolic:"informix".ss_param 
								WHERE secuencia = '353'
								AND empresa = pEmpresa;	
								
								LET dIngresoMaximo= ROUND(dSalarioMin * dTopeSalMin,-2);
								
								IF dIngresoMensDec > dIngresoMaximo THEN	
									LET pIngresoMens = dIngresoMaximo;									
								END IF	
								
								IF dIDP > pIngresoMens THEN	
									LET pIngresoMens = dIDP;
								ELSE
									LET pIngresoMens = pIngresoMens;
								END IF
							END IF
							-- OBTIENE FACTOR PARA CAPACIDAD DE PAGO
								SELECT TRIM(valor)
								INTO dFCP
								FROM bdicred:"informix".sd_param
								WHERE cod_param = '003'
								AND empresa = pEmpresa;
								
								IF NVL(dFCP,0.0) = 0.0 THEN
									LET cCodRet = '000007';
									LET cMensajeRet = 'ERROR AL OBTENER EL PARAMETRO DE PORCENTAJE DE FACTOR PARA CAPACIDAD DE PAGO';
									LET cBand1 = '1';
								ELSE	
									LET pIngresoMens = pIngresoMens-dImporte_hip;	
									LET dCMA = (pIngresoMens * dFCP) - dCompromPagoSIC - dCTC-mCompromisosbanco - pOtrosComp;
								END IF
							-- VALIDA QUE SI LA BANDERA ES IGUAL A CERO EL FLUJO SIGUE EL CAMINO FELIZ
							
							IF cBand1 = '0' THEN
								-- VALIDA QUE SI ES MENOR SE RECHAZA  POR CAPACIDAD DE PAGO SATURADA  (RCP)
								IF dCMA < -450 THEN
									LET cCodRet = '000008';
									LET cMensajeRet = 'SE RECHAZA EL CALCULO DE LA LINEA SUGERIDA POR CAPACIDAD DE PAGO SATURADA';
								-- SE OTORGARA INCREMENTO MINIMO DE ACUERDO A LOS TOPES SUGERIDOS
								ELIF (dCMA >= -450) THEN										
									-- SE OBTIENE TASA DE INTERES ANUALIZADA PARA INCREMENTO DE LINEA EN SUCURSAL.
									
									/*SELECT TRIM(valor)
									INTO dTIP
									FROM bdicred:"informix".sd_param
									WHERE cod_param = '006'
									AND empresa = pEmpresa;*/
									
									--Lazalde
									SELECT iva INTO dIvaSuc 
									FROM bdinteg:"informix".si_sucursales WHERE empresa = pEmpresa AND sucursal = cSucursal;

									EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas(pEmpresa, pNumSolicitud, '') INTO cCodRetTDif, dTasa_Interes, dTasa_Mora;
									IF cCodRetTDif <> '000000' THEN
										LET cCodRet = '000009';
										LET cMensajeRet = 'ERROR AL OBTENER EL PARÁMETRO DE LA TASA DE INTERÉS DEL PERIODO';
									END IF;
									
									LET dTIP = ((dTasa_Interes) + (dTasa_Interes * dIvaSuc))/100;
									
									IF NVL(dTasa_Interes, 0) = 0 THEN
									
										SELECT ((c.valor) +  (c.valor * dIvaSuc))/100
										INTO  dTIP
											  FROM bdicred:"informix".sd_definicion a,
												   bdinteg:"informix".si_fechavalor c
											 WHERE a.empresa = "001"
											   AND a.num_producto = "6001"
											   AND c.empresa = a.empresa
											   AND c.tasa = a.cod_tasa_base
											   AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r
													   WHERE r.empresa = "001"
														 AND r.tasa = a.cod_tasa_base);
									END IF;
									
									-- VALIDA QUE EXISTA LA TASA DE INTERES ANUALIZADA PARA INCREMENTO DE LINEA
									IF NVL(dTIP,0.0) = 0.0 THEN
										LET cCodRet = '000009';
										LET cMensajeRet = 'ERROR AL OBTENER EL PARÁMETRO DE LA TASA DE INTERÉS DEL PERIODO';									
									ELSE										
										SELECT TRIM(valor)::DECIMAL(18,2)
										INTO dTopeAbono
										FROM bdicred:"informix".sd_param
										WHERE cod_param = '045'
										AND empresa = pEmpresa;
									
										-- OBTIENE LA CAPACIDAD REAL DE ABONO OBTENIENDO EL MENOR DEL 20% DEL INGRESO CONTRA EL LA CAPACIDAD MAXIMA DE ABONO
										IF (pIngresoMens * dTopeAbono) <= dCMA THEN
											LET dCRA = (pIngresoMens * dTopeAbono);
										ELSE
											LET dCRA = dCMA;
										END IF
										-- REALIZA CALCULOS DE LA LINEA SUGERIDA
										LET dLineaSugerida = (dCRA * (1-POW((1+(dTIP/12)),12*-1))) / (dTIP/12);
										-- OBTIENE EL VALOR MINIMO DEL TOPE DE LINEAS
										SELECT  valor_minimo,valor_maximo_cci,valor_maximo_sci
										INTO dPorcTopeValMin,dPorcTopeValMax_cci,dPorcTopeValMax_sci
										FROM bdicred:"informix".sd_topes_suc_aumlincred
										WHERE dMontoOtor BETWEEN linea_actual_valor1 AND linea_actual_valor2;

										LET dLineaMinima = dMontoOtor + (dMontoOtor * dPorcTopeValMin);
										LET dLineaMaxima_cci = dMontoOtor + (dMontoOtor * dPorcTopeValMax_cci);
										LET dLineaMaxima_sci = dMontoOtor + (dMontoOtor * dPorcTopeValMax_sci);
										
										--SE COMPARA LINEA SUGERIDA CONTRA LINEA MAXIMA EXTABLECIDA 
										IF pCompIngreso = '1' THEN
											IF dLineaSugerida >  dLineaMaxima_cci THEN
												LET dLineaSugerida = dLineaMaxima_cci;
											END IF;											
										ELSE
											IF dLineaSugerida >  dLineaMaxima_sci THEN
												LET dLineaSugerida = dLineaMaxima_sci;
											END IF;	
										END IF;
										
										--SE COMPARA LINEA SUGERIDA CONTRA LINEA MINIMA EXTABLECIDA 
										IF dLineaSugerida <  dLineaMinima THEN
											LET dLineaSugerida = dLineaMinima;
										END IF;						
										--SE COMPARA LINEA SUGERIDA CONTRA LO SOLICITADO POR EL CLIENTE
										IF dLineaSugerida > dLineaSolicitada THEN
											LET dLineaSugerida = dLineaSolicitada;
										END IF;
																					
										-- REDONDEA LA LINEA SUGERIDA A CENTENAS
										LET dLineaSugerida = ROUND(dLineaSugerida, - 2);
										-- OBTIENE EL MONTO DEL INCREMENTO DE LA LINEA DE CREDITO
										LET dMontoIncremento = dLineaSugerida - dMontoOtor;
										
										-- OBTIENE EL PORCENTAJE DEL INCREMENTO DE LA LINEA DE CREDITO
										LET dRazonIncremento = (dLineaSugerida / dMontoOtor) - 1;
										IF dLineaSugerida <= dMontoOtor  THEN
											LET dLineaSugerida = 0.0;
											LET dMontoIncremento = 0.0;
											LET dRazonIncremento = 0.0;
											LET cCodRet = '000010';
											LET cMensajeRet = 'LÍNEA SUGERIDA RESULTA MENOR A LA LÍNEA ACTUAL VERIFICAR INGRESO MENSUAL';																		
										END IF
									END IF--dTIP
								END IF--CMA
							END IF--cBand1							
						END IF--Datos
					END IF
				END IF
			END IF
		END IF

		RETURN cCodRet, cMensajeRet, ROUND(dLineaSugerida, - 2), ROUND(dMontoIncremento, - 2), dRazonIncremento, dTIP;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para hacer el recalculo de la linea sugerida para sucursal', 
'AUTOR: Mohamed Carreón ',
'FECHA: Noviembre 2011',
'VERSION: 20111114.1747',
'----------------------------------------------------------------------------------',
'Autor: Josué Remberto Zazueta Acosta',
'Modificación: Se borra código comentado,se agregan informix y bd a las tablas que no tenían,Se implementan reglas', 'de informix',
'Fecha de modificación: 02/Octubre/2012',
'----------------------------------------------------------------------------------',
'Autor: Guadalupe Payan',
'Modificación: Se obtiene pago_minimo y abonomensual de la sd_bitacora_aumlincred y ya no de la tabla ss_resum_scor_fin como se hacia anteriormente.',
'Fecha de modificación: 05/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'Autor: Daniel Lazalde',
'Modificación: Se agrega el calculo para obtener la tasa de interes anualizada para incremento de linea (dTIP) por sucursal.',
'Fecha de modificación: 08/Febrero/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_genera_saldos_previos_edc(pempresa CHAR(3))
        RETURNING CHAR(5)
		
		
		DEFINE v_ruta      	VARCHAR(255);
        DEFINE cod_ret     	CHAR(5);
        DEFINE sql_err     	INTEGER;
        DEFINE v_sql        CHAR(8000);
        DEFINE v_sql1       CHAR(8000);
        DEFINE v_sql2       CHAR(8000);
        DEFINE v_sql3       CHAR(8000);
        DEFINE v_sql4       CHAR(8000);
        DEFINE v_fecha_hoy	DATE;
        DEFINE iFinDiaAnt   INTEGER;
		DEFINE iFinMesAnt   INTEGER;
		DEFINE iFinAnioAnt  INTEGER;
		DEFINE iMesAct   	INTEGER;
		DEFINE iAnioAct  	INTEGER;
		
		LET v_ruta      = "";
        LET v_sql       = "";
        LET v_sql1      = "";
        LET v_sql2      = "";
        LET v_sql3      = "";
        LET v_sql4      = "";
        LET iFinDiaAnt 	= 0;
		LET iFinMesAnt 	= 0;
		LET iFinAnioAnt = 0;
		LET iMesAct 	= 0;
		LET iAnioAct 	= 0;
		LET v_fecha_hoy = DATE(1);
		
/* 		SET DEBUG FILE TO "/informix/Rebeca/sp_genera_saldos_previos_edc.out";
        TRACE ON; */
		
		BEGIN

			ON EXCEPTION SET sql_err
				LET cod_ret = sql_err;
				RETURN cod_ret;
			END EXCEPTION;
			
			LET cod_ret = "00000";
			SELECT TRIM(valor) INTO v_ruta FROM sd_param WHERE empresa = pempresa AND cod_param = '033';
						
			select day(pri_dia_mes-1), month(add_months((pri_dia_mes),-1)) mes_ant, year(add_months((pri_dia_mes),-1)) anio_ant, month(fecha_hoy) mes_act, year(fecha_hoy) anio_act,fecha_hoy 
					into iFinDiaAnt,iFinMesAnt,iFinAnioAnt,iMesAct,iAnioAct,v_fecha_hoy
			from bdicred:sd_fechas; 
			
			LET v_sql1 = 	' echo set isolation to dirty read; ' ||
                            ' echo "UNLOAD TO '||trim(v_ruta)||'SaldosPreviosEdocta'||to_char(v_fecha_hoy,"%m%Y")||'.txt '||
							' select a.num_credito,'||
							'c.capvig21,c.captrans21,c.capvencnoexig21,c.capvenexig21,'||
							'c.capvig22,c.captrans22,c.capvencnoexig22,c.capvenexig22,'||
							'c.capvig23,c.captrans23,c.capvencnoexig23,c.capvenexig23,'||
							'c.capvig24,c.captrans24,c.capvencnoexig24,c.capvenexig24,'||
							'c.capvig25,c.captrans25,c.capvencnoexig25,c.capvenexig25,'||
							'c.capvig26,c.captrans26,c.capvencnoexig26,c.capvenexig26,'||
							'c.capvig27,c.captrans27,c.capvencnoexig27,c.capvenexig27,'||
							'c.capvig28,c.captrans28,c.capvencnoexig28,c.capvenexig28,'||
							'c.capvig29,c.captrans29,c.capvencnoexig29,c.capvenexig29,'||
							'c.capvig30,c.captrans30,c.capvencnoexig30,c.capvenexig30,'||
							'c.capvig29,c.captrans29,c.capvencnoexig29,c.capvenexig29,'||
							'c.capvig30,c.captrans30,c.capvencnoexig30,c.capvenexig30,'||
							'c.capvig31,c.captrans31,c.capvencnoexig31,c.capvenexig31,';
			
			LET v_sql2 =	'b.capvig1,b.captrans1,b.capvencnoexig1,b.capvenexig1,'||
							'b.capvig2,b.captrans2,b.capvencnoexig2,b.capvenexig2,'||
							'b.capvig3,b.captrans3,b.capvencnoexig3,b.capvenexig3,'||
							'b.capvig4,b.captrans4,b.capvencnoexig4,b.capvenexig4,'||
							'b.capvig5,b.captrans5,b.capvencnoexig5,b.capvenexig5,'||
							'b.capvig6,b.captrans6,b.capvencnoexig6,b.capvenexig6,'||
							'b.capvig7,b.captrans7,b.capvencnoexig7,b.capvenexig7,'||
							'b.capvig8,b.captrans8,b.capvencnoexig8,b.capvenexig8,'||
							'b.capvig9,b.captrans9,b.capvencnoexig9,b.capvenexig9,'||
							'b.capvig10,b.captrans10,b.capvencnoexig10,b.capvenexig10,'||
							'b.capvig11,b.captrans11,b.capvencnoexig11,b.capvenexig11,'||
							'b.capvig12,b.captrans12,b.capvencnoexig12,b.capvenexig12,'||
							'b.capvig13,b.captrans13,b.capvencnoexig13,b.capvenexig13,'||
							'b.capvig14,b.captrans14,b.capvencnoexig14,b.capvenexig14,'||
							'b.capvig15,b.captrans15,b.capvencnoexig15,b.capvenexig15,'||
							'b.capvig16,b.captrans16,b.capvencnoexig16,b.capvenexig16,'||
							'b.capvig17,b.captrans17,b.capvencnoexig17,b.capvenexig17,'||
							'b.capvig18,b.captrans18,b.capvencnoexig18,b.capvenexig18,'||
							'b.capvig19,b.captrans19,b.capvencnoexig19,b.capvenexig19,'||
							'b.capvig20,b.captrans20,b.capvencnoexig20,b.capvenexig20, a.tasa_interes '||
							'from bdicred:sd_maecred a ';
			LET v_sql3 = 	'join bdicred:sd_sdodiario b on (b.fecha=mdy('||iMesAct||',01,'||iAnioAct||') and  a.num_credito = b.num_credito) ' ||
							'join bdicred:sd_sdodiario c on (c.fecha=mdy('||iFinMesAnt||',01,'||iFinAnioAnt||') and  a.num_credito = c.num_credito) ' ||
							'where a.empresa = '''||pempresa||''' ' ||
							'and a.status_cred not in (''CV'') ' ||
							'and fecha_apertura <= mdy('|| month(v_fecha_hoy)||','||day(v_fecha_hoy)||','||year(v_fecha_hoy)||') ' ||
							'and a.sucursal = ''0002''" > queryNEC.sql';
			
			LET v_sql = trim(v_sql1)||trim(v_sql2)||' '||trim(v_sql3);
			SYSTEM v_sql;

			LET v_sql = "dbaccess bdicred queryNEC.sql";
			SYSTEM v_sql;
			
			LET v_sql = '';
			LET v_sql = 'rm queryNEC.sql ';
			SYSTEM v_sql;
			
		END;
	RETURN cod_ret;
END PROCEDURE;