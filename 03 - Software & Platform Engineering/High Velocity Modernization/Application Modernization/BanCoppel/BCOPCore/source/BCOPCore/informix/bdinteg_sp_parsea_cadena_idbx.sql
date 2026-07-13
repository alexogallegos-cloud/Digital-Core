CREATE PROCEDURE "informix".sp_parsea_cadena_idbx(pnumcte char(9))
	RETURNING LVARCHAR AS CodRet;
	
	DEFINE tPalabra 			 LVARCHAR;
	DEFINE i 					 INTEGER;
	DEFINE iTamCad 				 INTEGER;
	DEFINE iInicioCadena 		 INTEGER;
	DEFINE iRecuperarCaracteres  INTEGER;
	DEFINE cCaracter 			 CHAR(1);	
	DEFINE cPalabra 			 LVARCHAR;
	DEFINE sCadena 				 CHAR(10000);
	DEFINE sCadenaRev 			 CHAR(10000);
	DEFINE sDelimitador 		 CHAR(1);
	DEFINE sResultado	 		 CHAR(10);
	DEFINE iContOK 		  		 INTEGER;
	DEFINE sMensaje 		  	 CHAR(1000);
    DEFINE sCadenaAux            CHAR(10000);
    DEFINE sCadenaAux2           CHAR(1000);
    DEFINE iAuxParseo            INT;
    DEFINE sCodRet               CHAR(5);
    DEFINE dFecha                DATE;
	DEFINE sModelo_ife         	 CHAR(25);
	DEFINE sTestUvReflecAnv  	 CHAR(4);
	DEFINE sTestUvShapeAnv   	 CHAR(4);
	DEFINE sTestIrInkAnv     	 CHAR(4);
	DEFINE sTestUvReflectanceRev CHAR(4);
	DEFINE sTestIrInkRev 		 CHAR(4);
	
	LET tPalabra = '';
	LET cCaracter = '';
	LET cPalabra = '';
	LET iInicioCadena = 1;
	LET iRecuperarCaracteres = 0;
	LET sCadena ='';
	LET sCadenaRev ='';
	LET sDelimitador='#';
	LET sResultado='';
	LET iContOK=0;
	LET sMensaje='';
    LET sCadenaAux='';
    LET sCadenaAux2='';
    LET iAuxParseo=0;
    LET sCodRet='00000';
    LET dFecha=current;
	LET sModelo_ife = '';
	LET sTestUvReflecAnv = '0';
	LET sTestUvShapeAnv = '0';
	LET sTestIrInkAnv = '0';
	LET sTestUvReflectanceRev = '0';
	LET sTestIrInkRev = '0';
	
	BEGIN
		--SET DEBUG FILE TO '/informix/LIP/parsea_idbx.out';
		--TRACE ON;
	
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
        
        --INICIA PARSEO CADENA DE ANVERSO
		--OBTENEMOS EL MODELO DE LA CREDENCIAL -- 01-02-2018 LIPC
        SELECT FIRST 1 cadena_anverso, cadena_reverso, modelo_ife INTO sCadena, sCadenaRev, sModelo_ife FROM si_bitacora_ife WHERE numcte=pnumcte AND fecha = CURRENT;
		LET sCadena = TRIM(sCadena);
		LET sCadenaRev = TRIM(sCadenaRev);
		LET iTamCad = LENGTH(TRIM(sCadena));

		--OBTENEMOS EL MODELO DE LA CREDENCIAL -- 01-02-2018 LIPC
        IF iTamCad>0 THEN
                FOR i IN (1 TO iTamCad) LOOP

                    LET cCaracter = SUBSTR(TRIM(sCadena), i, 1);
                    LET iRecuperarCaracteres = iRecuperarCaracteres + 1;

                    IF cCaracter = sDelimitador THEN
                        LET iRecuperarCaracteres = iRecuperarCaracteres - 1;

                        --TRACE iInicioCadena||' -> '|| iRecuperarCaracteres;
                        LET cPalabra = SUBSTR(TRIM(sCadena), iInicioCadena, iRecuperarCaracteres);
                        LET iInicioCadena = i + 1;
                        LET iRecuperarCaracteres = 0;

                        IF cPalabra <> '' THEN
                            --TRACE ON;
                            IF SUBSTR(TRIM(cpalabra),1,25)='TEST_UV_PAPER_REFLECTANCE' THEN
                                IF SUBSTR(TRIM(cpalabra),28,2)="OK" THEN
                                    LET iContOK=iContOK+1;
									LET sTestUvReflecAnv = 'OK';
                                ELSE
									LET sTestUvReflecAnv = 'FAIL';
                                END IF;
                                --TRACE OFF;
                                --RETURN TRIM(cPalabra) WITH RESUME;
                            ELIF SUBSTR(TRIM(cpalabra),1,18)='TEST_UV_TEXT_SHAPE' THEN
                                IF SUBSTR(TRIM(cpalabra),21,2)="OK" THEN
                                    LET iContOK=iContOK+1;
									LET sTestUvShapeAnv = 'OK';
                                ELSE
									LET sTestUvShapeAnv = 'FAIL';
                                END IF;
                                --RETURN TRIM(cPalabra) WITH RESUME;
                            ELIF SUBSTR(TRIM(cpalabra),1,11)='TEST_IR_INK' THEN
							
								IF (TRIM(sModelo_ife)='PAMEXI1') THEN
								
									LET iContOK=iContOK+1;
									LET sTestIrInkAnv = 'OK';
								
								ELSE
							
										IF SUBSTR(TRIM(cpalabra),14,2)="OK" THEN
										LET iContOK=iContOK+1;
										LET sTestIrInkAnv = 'OK';
										ELSE
											LET sTestIrInkAnv = 'FAIL';
										END IF;
										--RETURN TRIM(cPalabra) WITH RESUME;
								END IF;
								
                            END IF;
                            LET sMensaje="EL RESULTADO DE OK ES: " || iContOK;
                            --TRACE OFF;
                        END IF;
                    END IF;

                END LOOP;
                --FIN DEL PARSEO CADENA DE ANVERSO


                --INICIA PARSEO CADENA DE REVERSO
                --TRACE ON;
                LET sCadena = sCadenaRev;
                LET iTamCad = LENGTH(TRIM(sCadena));
                --REINICIANDO VARIABLES
                LET iInicioCadena=1;
                LET iRecuperarCaracteres = 0;
                LET iAuxParseo=0;

                        IF EXISTS(SELECT 1 FROM si_fechas WHERE scadena NOT MATCHES '*:*') THEN
                            FOR i IN (1 TO iTamCad) LOOP 
                                LET cCaracter = SUBSTR(TRIM(sCadena), i, 1);
                                LET iRecuperarCaracteres = iRecuperarCaracteres + 1;


                                IF cCaracter = sDelimitador THEN
                                    LET iRecuperarCaracteres = iRecuperarCaracteres - 1;
                                    LET iAuxParseo=iAuxParseo+1;
                                    --TRACE iInicioCadena||' -> '|| iRecuperarCaracteres;
                                    LET cPalabra = SUBSTR(TRIM(sCadena), iInicioCadena, iRecuperarCaracteres);
                                    LET iInicioCadena = i + 1;
                                    LET iRecuperarCaracteres = 0;


                                    IF iAuxParseo=1 THEN
                                        LET sCadenaAux = 'TYPE: ' || TRIM(cPalabra) || ' # ';
                                    ELIF iAuxParseo=2 THEN 
                                        LET sCadenaAux=TRIM(sCadenaAux) || 'SIDE: ' || TRIM(cPalabra) || ' # ';
                                    ELIF iAuxParseo=3 THEN    
                                        LET sCadenaAux=TRIM(sCadenaAux) || ' EXPEDITOR: ' || TRIM(cPalabra) || ' # ';
                                    ELIF iAuxParseo=4 THEN    
                                        LET sCadenaAux=TRIM(sCadenaAux) || ' NATIONALITY: ' || TRIM(cPalabra) || ' # ';
                                    ELIF iAuxParseo=5 THEN    
                                        LET sCadenaAux=TRIM(sCadenaAux) || ' CRC_SECTION: ' || TRIM(cPalabra) || ' # ';
                                    ELIF iAuxParseo=6 THEN    
                                        LET sCadenaAux=TRIM(sCadenaAux) || ' BARCODE_CODE128: ' || TRIM(cPalabra) || ' # ';
                                    ELIF iAuxParseo=7 THEN    
                                        LET sCadenaAux=TRIM(sCadenaAux) || ' TEST_UV_PAPER_REFLECTANCE: ' || TRIM(cPalabra) || ' # ';
                                    ELIF iAuxParseo=8 THEN   
                                        LET sCadenaAux=TRIM(sCadenaAux) || ' TEST_IR_INK: ' || TRIM(cPalabra) || ' # ';
                                    ELIF iAuxParseo=9 THEN    
                                        LET sCadenaAux=TRIM(sCadenaAux) || ' TEST_IR_FIELDS_VIZ_INK: ' || TRIM(cPalabra) || ' # ';
                                    ELIF iAuxParseo=10 THEN     
                                        LET sCadenaAux=TRIM(sCadenaAux) || ' MODEL_ID: ' || TRIM(cPalabra) || ' # ';
                                    END IF;

                                END IF;

                            END LOOP;
                            --RETURN TRIM(sCadenaAux);
                            LET sCadena=TRIM(sCadenaAux);
                            --TRACE OFF;
                        END IF;


                --LET sCadena=(select first 1 cadena_reverso from si_bitacora_ife where numcte=pnumcte);
                LET iTamCad = LENGTH(TRIM(sCadena));
                FOR i IN (1 TO iTamCad) LOOP

                    LET cCaracter = SUBSTR(TRIM(sCadena), i, 1);
                    LET iRecuperarCaracteres = iRecuperarCaracteres + 1;

                    IF cCaracter = sDelimitador THEN
                        LET iRecuperarCaracteres = iRecuperarCaracteres - 1;

                        --TRACE iInicioCadena||' -> '|| iRecuperarCaracteres;
                        LET cPalabra = SUBSTR(TRIM(sCadena), iInicioCadena, iRecuperarCaracteres);
                        LET iInicioCadena = i + 1;
                        LET iRecuperarCaracteres = 0;

                        IF cPalabra <> '' THEN
                            --TRACE ON;
                            --TEST_UV_PAPER_REFLECTANCE2
                            IF SUBSTR(TRIM(cpalabra),1,25)='TEST_UV_PAPER_REFLECTANCE' THEN
                                IF SUBSTR(TRIM(cpalabra),28,2)="OK" THEN
                                    LET iContOK=iContOK+1;
									LET sTestUvReflectanceRev = 'OK';
                                ELSE
									LET sTestUvReflectanceRev = 'FAIL';
                                END IF;
                                --TRACE OFF;
                                --RETURN TRIM(cPalabra) WITH RESUME;
                            --TEST_IR_INK2
                            ELIF SUBSTR(TRIM(cpalabra),1,11)='TEST_IR_INK' THEN
                                IF SUBSTR(TRIM(cpalabra),14,2)="OK" THEN
                                    LET iContOK=iContOK+1;
									LET sTestIrInkRev = 'OK';
                                ELSE
									LET sTestIrInkRev = 'FAIL';
                                END IF;
                                --RETURN TRIM(cPalabra) WITH RESUME;
                            END IF;
                            LET sMensaje="EL RESULTADO DE OK ES: " || iContOK;
                            --TRACE OFF;
                        END IF;
                    END IF;

                END LOOP;
                --FIN DEL PARSEO CADENA DE REVERSO
				 --PARA LOS PASAPORTES DEBEN SER OK LAS DOS PRUEBAS --420
				IF (SUBSTR(TRIM(sModelo_ife),0,2)='PA') THEN

					IF iContOK>=2 THEN
						UPDATE "informix".si_bitacora_ife SET resultado='Verdadero', TEST_UV_REFLEC_ANV = sTestUvReflecAnv, TEST_IR_INK_ANV = sTestIrInkAnv WHERE numcte=pnumcte  
						AND fecha = CURRENT;

					ELSE
						UPDATE "informix".si_bitacora_ife SET resultado='Falso', causa_rechazo='Menor cantidad de campos en OK', TEST_UV_REFLEC_ANV = sTestUvReflecAnv, TEST_IR_INK_ANV = sTestIrInkAnv 
						WHERE numcte=pnumcte  AND fecha = CURRENT;

					  END IF;
								
				ELSE
				
					IF (sTestUvShapeAnv = '0') THEN
						LET iContOK=iContOK+1;
				    END IF;
					
					IF iContOK>=3 THEN
						UPDATE "informix".si_bitacora_ife
						SET resultado = 'Verdadero',
						TEST_UV_REFLEC_ANV = sTestUvReflecAnv, 
						TEST_UV_SHAPE_ANV = sTestUvShapeAnv, TEST_IR_INK_ANV = sTestIrInkAnv, 
						TEST_UV_REFLECTANCE_REV = sTestUvReflectanceRev, TEST_IR_INK_REV = sTestIrInkRev
						WHERE numcte = pnumcte AND fecha = CURRENT;
					ELSE
						UPDATE "informix".si_bitacora_ife
						SET resultado = 'Falso', causa_rechazo = 'Menor cantidad de campos en OK',
						TEST_UV_REFLEC_ANV = sTestUvReflecAnv, 
						TEST_UV_SHAPE_ANV = sTestUvShapeAnv, TEST_IR_INK_ANV = sTestIrInkAnv,
						TEST_UV_REFLECTANCE_REV=sTestUvReflectanceRev, TEST_IR_INK_REV=sTestIrInkRev
						WHERE numcte = pnumcte AND fecha = CURRENT;
					END IF;
				END IF;

                LET cPalabra = SUBSTR(TRIM(sCadena), iInicioCadena, iRecuperarCaracteres);
                IF cPalabra <> '' THEN
                    --RETURN TRIM(cPalabra);
                END IF;
        
        END IF;

        RETURN sCodRet;

	END;
	
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se modifica procedimiento para el caso de pasaporte se considere que con al menos 1 prueba luz sea verdadera ' ,
'AUTOR:VIRIDIANA PAREDES ROMERO ',   
'FECHA DE CREACION: 14/06/2018',
'FOLIO: 420',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_bloqueacuentascte(pNumCte CHAR (10),pNumCuenta CHAR(20),pClaveBloqueo INTEGER,pTipoBloqueo INTEGER,
												 pCausaBloqueo CHAR(3),pOpcionBloqueo CHAR(3),pAreaBloqueo CHAR(3),pEjecutivo CHAR(8),
												 pEmpresa CHAR(3),pTipoCuenta INTEGER) 
												 
												 	
																

																
														
	RETURNING CHAR(25);

	DEFINE cCodRet 			CHAR(25);	
	DEFINE iSqlErr 			INTEGER;
	DEFINE vCodSP  			CHAR(6);
	DEFINE CcodArea 		CHAR(1);
	DEFINE Ccodtipobloq 	CHAR(1);
	DEFINE Cfolio_suc 		CHAR(25);
	DEFINE Cfecha			CHAR(25);
	DEFINE fecha_w			CHAR(15);
	DEFINE status2_w 		CHAR(1);
	DEFINE mov 				CHAR(1);
	DEFINE v_transacc 		CHAR(5);
	DEFINE v_mesdia         CHAR(4);
	DEFINE hora_w           CHAR(15);
	DEFINE v_clave          CHAR(4);
	DEFINE suc_w            CHAR (4);
	DEFINE prod_w           CHAR (4);
	DEFINE sdod_w           MONEY (14,2);
	DEFINE vfecha_operacion DATE;
	DEFINE status_w         CHAR(1);
	DEFINE vFecha        	DATE;
	DEFINE Iexiste          INTEGER;
	DEFINE cTipoBloqueo     CHAR(2);


	
	LET Cfolio_suc		 ='';
	LET Cfecha			 ='';
	LET cCodRet  		 ='00000';
	LET iSqlErr 		 =0;
	LET vCodSP           ='';
	LET CcodArea 		 ='';
	LET Ccodtipobloq	 ='';
	LET fecha_w			 ='';
	LET status2_w		 ='';
	LET mov 			 ='';
	LET v_transacc		 ='';
	LET v_mesdia  		 ='';
	LET hora_w  		 ='';
	LET v_clave  		 ='';
	LET suc_w 			 ='';
	LET prod_w 			 ='';
	LET sdod_w       	 =0.00;
	LET vfecha_operacion =TODAY;
	LET status_w  		 ='';
	LET vFecha           = DATE(1);
	LET Iexiste			 = 0;
	LET cTipoBloqueo     = CONCAT('0',CAST(pTipoBloqueo as CHAR(2)));
	
--	SET DEBUG FILE TO '/home/sysifx/VIRIDIANA2/SP_BLOQUEACUENTASCTE.out';
--	TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
	
		SELECT fecha_hoy
		INTO vFecha
		FROM bdicred:"informix".sd_fechas
		WHERE empresa = pEmpresa;
		
		--quitar pruebas
	--	let cTipoBloqueo = cTipoBloqueo ;
	--	let pAreaBloqueo =pAreaBloqueo;
		
	IF pTipoCuenta = 1 THEN
		EXECUTE PROCEDURE bdicred:"informix".sp_validacredito (pEmpresa, pNumCuenta) 
		INTO vCodSP;
		
		IF vCodSP::INTEGER = 0 THEN
			
			--SI ES BLOQUEO POR INE SE DEFINE CLAVE DE BLOQUEO = 3
			IF(pCausaBloqueo = '91' AND pClaveBloqueo = 1) THEN LET pClaveBloqueo = 3; END IF
			
			INSERT INTO  bdicred:"informix".sd_bitacorabloqueocta(cuenta,cve_bloqueo,cve_causa,cve_bloqueanterior,cve_causa_anterior,ejecutivo,fecha,tipo_bloqueo,tipo_movimiento)
			VALUES (pNumCuenta,pClaveBloqueo,pCausaBloqueo, NULL, NULL,pEjecutivo,vFecha,pTipoBloqueo,'B');   
			
			UPDATE bdicred:"informix".sd_maecred
			SET id_unidad_prod = pClaveBloqueo, Cod_caract_2 = pCausaBloqueo
			WHERE empresa = pEmpresa
			AND num_credito = pNumCuenta;
		END IF
		
		
	ELIF pTipoCuenta = 2 THEN
		--Validar que exista la cuenta en la tabla 
			
			SELECT COUNT(num_cte) INTO Iexiste
			FROM bdicheq:"informix".sc_maechq 
			where cuenta =pNumCuenta and num_cte=pNumCte;
		
		IF (Iexiste) > 0 THEN
			
			-- // Obtiene la fecha del sistema
				select fecha_hoy 
				into fecha_w 
				from bdicheq:"informix".sc_fechas 
				where empresa = pempresa;
				
				-- // Obtiene datos de la cuenta
				select sucursal, producto, status_cta, ( sdo_actual - ( sdo_cong + sdo_retenido + imp_chq_sbg ) )
				into  suc_w, prod_w, status_w, sdod_w
				from bdicheq:"informix".sc_maechq
				where cuenta = pNumCuenta;
			
			if pClaveBloqueo <> 00 then 
				
				let status2_w = '3';
				let mov = 'B';
				let v_transacc ='3353';
				
				let Cfecha  = current hour to fraction;
				let Cfecha  = Cfecha[1,2]||Cfecha[4,5]||Cfecha[7,8]||Cfecha[10,11];
				let Cfolio_suc = trim(pEjecutivo)||Cfecha;
				
				let v_mesdia = trim(month(fecha_w) || day(fecha_w));
				let hora_w = trim(Cfecha[4,5]||Cfecha[7,8]);
				let v_clave = trim(v_mesdia)||trim(hora_w);
				
					
				SELECT codigo  into CcodArea FROM bdicheq:"informix".sc_areabloqueo WHERE clave = pAreaBloqueo;
				SELECT codigo into Ccodtipobloq FROM bdicheq:"informix".sc_tipobloqueo WHERE clave = cTipoBloqueo;
				
				-- // Inserta registro en historico de bloqueos
				insert into bdicheq:"informix".sc_histbloq(empresa,cuenta,tipo_mov,motivo,opcion,importe,usuario,fecha,hora,clave,status_blo,folio_suc,
							referencia,cve_area,cod_area,cve_tipobloq,cod_tipobloq )
				values(pempresa,pNumCuenta,mov,pClaveBloqueo,pOpcionBloqueo,0.00,pEjecutivo,fecha_w,current hour to fraction,v_clave, 
				mov,Cfolio_suc,"",pAreaBloqueo,CcodArea,cTipoBloqueo,Ccodtipobloq );
				
				 
				 --Insertar registro en la tabla bdicheq: sc_ctabloqueo:
				 INSERT INTO bdicheq:"informix". sc_ctabloqueo (cuenta,clave,opcion,cve_area,cod_area,cve_tipobloq,cod_tipobloq)
				 VALUES (pNumCuenta,pClaveBloqueo,pOpcionBloqueo,pAreaBloqueo,CcodArea,cTipoBloqueo,Ccodtipobloq);

				 --Insertar registro en la tabla bdicheq: sc_ctabloqueohist:
				 INSERT INTO  bdicheq:"informix".  sc_ctabloqueohist (cuenta,clave,opcion) 
				 VALUES (pNumCuenta,pClaveBloqueo,pOpcionBloqueo);
				
				--Insertar registro en la tabla bdicheq: sc_movdia:
				INSERT INTO  bdicheq: "informix". sc_movdia (folio_suc,sucursal,usuario,fech_alt,fech_val,fech_hor,transacc,suc_cuen,producto,empresa,
							cuenta,causa_dev,num_cheq,monto_tot,
							firme,en_sbc,remesas,dias_ret,cancelad,
							edo_cta,sdo_cuenta,transacc_suc,referencia,
							tasa_aplicada,num_tarjeta,usuautoriza,referencia_23,fech_oper) 
				VALUES (Cfolio_suc,suc_w,pEjecutivo,fecha_w,fecha_w, current hour to fraction,'3353',suc_w,prod_w,pEmpresa,pNumCuenta,
						'',0,0.00,0,0,0,0," ",status_w,sdod_w,'0000', '',0,'','','',vfecha_operacion);
				
				
				--Actualizar el estatus de la cuenta en la tabla bdicheq: sc_maechq
				UPDATE bdicheq: "informix". sc_maechq 
				SET fec_cancelac=fecha_w,status_cta=status2_w,motivo=pClaveBloqueo,fecha_proceso= fecha_w
				WHERE cuenta= pNumCuenta AND num_cte=pNumCte;
			END IF
		END IF
	
	END IF
	
	
	RETURN cCodRet;
	
END;
END PROCEDURE;