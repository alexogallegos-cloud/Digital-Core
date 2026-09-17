CREATE PROCEDURE "informix".sp_parsea_cadena_idbx_opt(pnumcte char(9))
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
	DEFINE sSucursal	 		 CHAR(5);
	
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
	LET sSucursal = '';
	
	BEGIN
		
		--SET DEBUG FILE TO '/informix/LIP/parsea_idbx.out';
		--TRACE ON;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
        
        --INICIA PARSEO CADENA DE ANVERSO
		--OBTENEMOS EL MODELO DE LA CREDENCIAL -- 01-02-2018 LIPC
        SELECT FIRST 1 cadena_anverso, cadena_reverso, modelo_ife, sucursal INTO sCadena, sCadenaRev, sModelo_ife, sSucursal FROM si_bitacora_ife WHERE numcte=pnumcte AND fecha = CURRENT;
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
								ELIF SUBSTR(TRIM(cpalabra),1,30)='TEST_GLOBAL_AUTHENTICITY_VALUE' THEN
								
									IF SUBSTR(TRIM(cpalabra),33,2)="OK" THEN
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

CREATE PROCEDURE "informix".sp_ctanvl2_generapdf(pNumCte CHAR(20),pNumCta CHAR(20))
	RETURNING CHAR(5);

	DEFINE iSqlErr INTEGER;
    DEFINE iSamErr INTEGER;
    DEFINE cDesErr CHAR(50);
	DEFINE cCommand CHAR(1000);
	DEFINE cSQL CHAR(500);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE cCodRet CHAR(5);
    DEFINE cCodRet2 CHAR(5);
    DEFINE cCodRet3 CHAR(50);
	DEFINE cRutaArchivo CHAR(100);
	DEFINE cNomReporte CHAR(40);
	--- DEFINE cComponente CHAR(20);
	DEFINE cCmd1 CHAR(500);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cFechaHr CHAR(14);
	DEFINE cNomPortada CHAR(40);
	DEFINE cNomPortadaB CHAR(40);
	DEFINE cNomContrato CHAR(40);
	DEFINE cNomCaratura CHAR(40);

	DEFINE cProducto CHAR(40);
	DEFINE cNombreCte CHAR(107);
	DEFINE cFechaNac CHAR(10);
	DEFINE cRfc CHAR(13);
	DEFINE cSucursal CHAR(50);
	DEFINE cOperacion CHAR(30);
	DEFINE cFechaOpe CHAR(30);
	DEFINE cFolioOpe CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cCtaClabe CHAR(20);
	DEFINE cTitular CHAR(104);
	DEFINE cAutorizaRevoc CHAR(2);
	DEFINE cReca CHAR(100);
	DEFINE cNombreBenef CHAR(104);
	DEFINE cPorcentaje CHAR(10);
	DEFINE cParentesco CHAR(40);
	DEFINE cProdCap CHAR(100);
	DEFINE cProdNom CHAR(100);
	DEFINE cProdGen CHAR(100);
	DEFINE cFecha CHAR(10);
	DEFINE cProd CHAR(4);
	DEFINE cNumCta CHAR(20);
	DEFINE cRutaArchivoImg CHAR(200);
	DEFINE cNombreArchivoImg CHAR(200);
    DEFINE cCorreoElec CHAR(50);
	DEFINE iCounter INTEGER;
	DEFINE cRcan CHAR(50);
	DEFINE cVar1 CHAR(50);
	DEFINE cVar2 CHAR(50);
	DEFINE cVar3 CHAR(50);
	DEFINE cVar4 CHAR(50);
	DEFINE cVar5 CHAR(50);
	DEFINE cVar6 CHAR(80);
	DEFINE cNombre CHAR(200);

	LET iSqlErr = 0;
    LET iSamErr = 0;
    LET cDesErr = '';
	LET cCommand = '';
	LET cSQL = '';
	LET cRutaInformix = '/ifxsif01/bin/';
    --LET cRutaInformix = '';
    LET cUsrBin = '/usr/bin/';
	LET cCodRet = '000';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
	--LET cRutaArchivo = '/tmp/mfinis/caratulasCuentaNivel2/';
    LET cRutaArchivo = '/RESPALDOSNEW/DoctosCtaNvl2/';
	LET cNomReporte = '';
	--- LET cComponente = '';
	LET cCmd1 = '';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cFechaHr = TO_CHAR(CURRENT, '%Y%m%d%H%M%S');
	LET cNomPortada = '';
	LET cNomPortadaB = '';
	LET cNomContrato = '';
	LET cNomCaratura = '';

	LET cProducto = '';
	LET cNombreCte = '';
	LET cFechaNac = '';
	LET cRfc = '';
	LET cSucursal = '';
	LET cOperacion = ' ';
	LET cFechaOpe = '';
	LET cFolioOpe = '';
	LET cCuenta = '';
	LET cCtaClabe = '';
	LET cTitular = '';
	LET cAutorizaRevoc = '';
	LET cReca = '';
	LET cNombreBenef = '';
	LET cPorcentaje = '';
	LET cParentesco = '';
	LET cProdCap = '';
	LET cProdNom = '';
	LET cProdGen = '';
	LET cFecha = '';
	LET cProd = '';
	LET cNumCta =pNumCta;
	LET cRutaArchivoImg = '';
	LET cNombreArchivoImg = '';
    LET cCorreoElec = '';
	LET iCounter = 0;
	LET cRcan = '';
	LET cVar1 = '';
	LET cVar2 = '';
	LET cVar3 = '';
	LET cVar4 = '';
	LET cVar5 = '';
	LET cVar6 = '';
	LET cNombre = '';
	
	BEGIN

    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO '/RESPALDOSNEW/DoctosCtaNvl2/sp_ctanvl2_generapdf.err';
        TRACE ON;
        IF iSqlerr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO '/RESPALDOSNEW/DoctosCtaNvl2/sp_ctanvl2_generapdf.out';
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // VALIDA CAMPOS REQUERIDOS
    IF pNumCte IS NULL OR pNumCte = '' OR pNumCta IS NULL OR pNumCta = '' THEN
        LET cCodRet = '110';
        RETURN cCodRet;
    END IF;
    
    /* ###################################################################
    SELECT {+INDEX (bdinteg:"informix".si_param ix_si_param)} valor 
      INTO cRutaArchivo
      FROM bdinteg:"informix".si_param 
     WHERE cod_param = 487;
    ################################################################### */

    -- // SE DEFINE NOMENCLATURA DEL REPORTE
    LET cNomReporte = 'reportes'||TRIM(pNumCte)||'_'||TRIM(cFechaHr)||'.txt';
    LET cCommand = 'rm -rf '||TRIM(cRutaArchivo)||TRIM(cNomReporte);
    SYSTEM TRIM(cCommand);

    -- // EJECUTA PORTADA
    EXECUTE PROCEDURE bdinteg:"informix".sp_ctanvl2_genportada(pNumCte,pNumCta)
    INTO cCodRetSp,cProducto,cNombreCte,cFechaNac,cRfc,cSucursal,cOperacion,cFechaOpe,cFolioOpe,cCuenta,cCtaClabe,cTitular,cAutorizaRevoc,cReca,cProd;

    LET iCodRetSp = cCodRetSp::INTEGER;
    
    IF iCodRetSp < 0 THEN
        RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_genportada';
    ELIF iCodRetSp = 0 THEN

        DELETE FROM bdinteg:"informix".si_ctanvl2_retornos;
        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
            --- LET cCodRet = '00862';
        END IF;

        LET cNomPortada = 'portada'||TRIM(pNumCte)||'_'||TRIM(cFechaHr)||'.txt';
        LET cCommand = 'rm -rf '||TRIM(cRutaArchivo)||TRIM(cNomPortada);
        SYSTEM TRIM(cCommand);

        INSERT INTO bdinteg:"informix".si_ctanvl2_retornos
        (producto,nombre_cte,fecha_nac,rfc,sucursal,operacion,fecha_ope,folio_ope,cuenta,cta_clabe,titular,autoriza_revoc,reca)
        VALUES
        (cProducto,cNombreCte,cFechaNac,cRfc,cSucursal,cOperacion,cFechaOpe,cFolioOpe,cCuenta,cCtaClabe,cTitular,cAutorizaRevoc,cReca);

        LET cCmd1 ="";
        LET cCmd1 ="SELECT producto,nombre_cte,fecha_nac,rfc,sucursal,operacion,fecha_ope,folio_ope,cuenta,cta_clabe,titular,autoriza_revoc,reca";
        LET cCmd1 =""||TRIM(cCmd1)||" FROM bdinteg:""informix"".si_ctanvl2_retornos;";

        SYSTEM TRIM('echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaArchivo)||TRIM(cNomPortada)||' ' || TRIM(cCmd1)||'" | '||TRIM(cRutaInformix)||'dbaccess bdinteg > /dev/null 2>&1');

        DELETE FROM bdinteg:"informix".si_ctanvl2_retornosbenef;
        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
            --- LET cCodRet = '00862';
        END IF;

        LET cNomPortadaB = 'portadabenef'||TRIM(pNumCte)||'_'||TRIM(cFechaHr)||'.txt';
        LET cCommand = 'rm -rf '||TRIM(cRutaArchivo)||TRIM(cNomPortadaB);
        SYSTEM TRIM(cCommand);

        FOREACH
            EXECUTE PROCEDURE bdinteg:"informix".sp_ctanvl2_genportada_benef(pNumCte,pNumCta)
            INTO cCodRetSp,cNombreBenef,cPorcentaje,cParentesco

            LET iCodRetSp = cCodRetSp::INTEGER;
            IF iCodRetSp < 0 THEN
                RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_genportada_benef';
            ELIF iCodRetSp = 0 THEN
                INSERT INTO bdinteg:"informix".si_ctanvl2_retornosbenef
                (nombre_benef,porcentaje,parentesco)
                VALUES
                (cNombreBenef,cPorcentaje,cParentesco);
                
                LET iCounter = iCounter + 1;
            END IF;
        END FOREACH;


        IF iCounter > 0 THEN
            LET cCmd1 ="";
            LET cCmd1 ="SELECT nombre_benef,porcentaje,parentesco";
            LET cCmd1 =""||TRIM(cCmd1)||" FROM bdinteg:""informix"".si_ctanvl2_retornosbenef;";
            SYSTEM TRIM('echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaArchivo)||TRIM(cNomPortadaB)||' ' || TRIM(cCmd1)||'" | '||TRIM(cRutaInformix)||'dbaccess bdinteg > /dev/null 2>&1');
        END IF;
    END IF;

    -- // EJECUTA CONTRATO
    EXECUTE PROCEDURE bdinteg:"informix".sp_ctanvl2_gencontrato(pNumCte,pNumCta)
    INTO cCodRetSp,cProdCap,cProdNom,cProdGen,cNombreCte,cFecha,cSucursal,cProducto;

    LET iCodRetSp = cCodRetSp::INTEGER;
    
    IF iCodRetSp < 0 THEN
        RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_gencontrato';
    ELIF iCodRetSp = 0 THEN
        DELETE FROM bdinteg:"informix".si_ctanvl2_retornos;
        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
            --- LET cCodRet = '00862';
        END IF;

        LET cNomContrato = 'contrato'||TRIM(pNumCte)||'_'||TRIM(cFechaHr)||'.txt';
        LET cCommand = 'rm -rf '||TRIM(cRutaArchivo)||TRIM(cNomContrato);
        SYSTEM TRIM(cCommand);

        INSERT INTO bdinteg:"informix".si_ctanvl2_retornos
        (prod_cap,prod_nom,prod_gen,nombre_cte,fecha,sucursal,producto)
        VALUES
        (cProdCap,cProdNom,cProdGen,cNombreCte,cFecha,cSucursal,cProducto);

        LET cCmd1 ="";
        LET cCmd1 ="SELECT prod_cap,prod_nom,prod_gen,nombre_cte,fecha,sucursal,producto";
        LET cCmd1 =""||TRIM(cCmd1)||" FROM bdinteg:""informix"".si_ctanvl2_retornos;";

        SYSTEM TRIM('echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaArchivo)||TRIM(cNomContrato)||' ' || TRIM(cCmd1)||'" | '||TRIM(cRutaInformix)||'dbaccess bdinteg > /dev/null 2>&1');
    END IF;

    -- // EJECUTA CARATULA
    EXECUTE PROCEDURE bdinteg:"informix".sp_ctanvl2_gencaratula(pNumCte,pNumCta)
    INTO cCodRetSp,cProducto;

    LET iCodRetSp = cCodRetSp::INTEGER;
    
    IF iCodRetSp < 0 THEN
        RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_gencaratula';
    ELIF iCodRetSp = 0 THEN
        DELETE FROM bdinteg:"informix".si_ctanvl2_retornos;
        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
            --- LET cCodRet = '00862';
        END IF;

        LET cNomCaratura = 'caratula'||TRIM(pNumCte)||'_'||TRIM(cFechaHr)||'.txt';
        LET cCommand = 'rm -rf '||TRIM(cRutaArchivo)||TRIM(cNomCaratura);
        SYSTEM TRIM(cCommand);

        INSERT INTO bdinteg:"informix".si_ctanvl2_retornos
        (producto)
        VALUES
        (cProducto);

        LET cCmd1 ="";
        LET cCmd1 ="SELECT producto";
        LET cCmd1 =""||TRIM(cCmd1)||" FROM bdinteg:""informix"".si_ctanvl2_retornos;";

        SYSTEM TRIM('echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaArchivo)||TRIM(cNomCaratura)||' ' || TRIM(cCmd1)||'" | '||TRIM(cRutaInformix)||'dbaccess bdinteg > /dev/null 2>&1');
    END IF;

    SELECT correo_elec 
      INTO cCorreoElec
      FROM bdinteg:"informix".si_correos 
     WHERE empresa = '001' 
       AND numcte = pNumCte 
       AND status_correo = 'A';
    
    SELECT SUBSTR(valor,62,29) 
      INTO cRcan
      FROM bdinteg:si_param 
     WHERE cod_param = 486;
    
    SELECT valor 
      INTO cVar1
      FROM bdinteg:si_param 
     WHERE cod_param = 496;
    
    SELECT valor 
      INTO cVar2
      FROM bdinteg:si_param 
     WHERE cod_param = 497;
    
    SELECT valor 
      INTO cVar3
      FROM bdinteg:si_param 
     WHERE cod_param = 498;
    
    SELECT valor 
      INTO cVar4
      FROM bdinteg:si_param 
     WHERE cod_param = 499;
    
    SELECT valor 
      INTO cVar5
      FROM bdinteg:si_param 
     WHERE cod_param = 500;
    
    SELECT valor 
      INTO cVar6
      FROM bdinteg:si_param 
     WHERE cod_param = 504;

    SELECT TRIM(NVL(nombre1,'')) || ' ' ||  
        (CASE WHEN TRIM(NVL(nombre2,'')) == '' THEN '' ELSE TRIM(NVL(nombre2,'')) || ' ' END) || ' ' || 
        TRIM(NVL(apell_paterno, '')) || ' ' ||  
        TRIM (NVL(apell_materno,''))
    INTO cNombre
    FROM bdinteg:si_cliente 
    WHERE numcte =  pNumCte;
    
    -- // java7 ---> java8
    --- LET cCommand = "/usr/java7/bin/java -jar /tmp/mfinis/caratulasCuentaNivel2/componente/Caratulas.jar '"||TRIM(pNumCte)||"' '"|| TRIM(pNumCta)||"' > /tmp/mfinis/caratulasCuentaNivel2/reportes.txt";
    LET cCommand = "/usr/java8/bin/java -jar "||TRIM(cRutaArchivo)||"componente/Caratulas.jar '"||TRIM(pNumCte)||"' '"|| TRIM(pNumCta)||"' '"|| TRIM(cNomPortada)||"' '"|| TRIM(cNomPortadaB)||"' '"|| TRIM(cNomContrato)||"' '"|| TRIM(cNomCaratura)||"' '"|| TRIM(cRutaArchivo)||"' '"||TRIM(cNomReporte)||"' '"||TRIM(cCorreoElec)||"' '"||TRIM(cRcan)||"' '"||TRIM(cNombre)||"'";
    SYSTEM(cCommand);

    --- LET cCommand = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaArchivo)||TRIM(cNomReporte);
    --- SYSTEM(cCommand);

    LET cCommand = 'echo "SET ISOLATION TO DIRTY READ; LOAD FROM '||TRIM(cRutaArchivo)||TRIM(cNomReporte)||' DELIMITER ''|'' INSERT INTO si_ctanvl2_ctrlrep(nom_reporte,fecha_gen,error,archivo_log)"  > '||TRIM(cRutaArchivo)||'reportesPDF_'||TRIM(cNomReporte)||'.sql';
    SYSTEM cCommand;

    LET cRutaArchivoImg = TRIM(cRutaArchivo)||'caratulasPDF/imagenes';
    --- LET cRutaArchivoImg = TRIM(cRutaArchivo)||'caratulasPDF';
    LET cRutaArchivoImg = TRIM(cRutaArchivoImg);

    LET cNombreArchivoImg = TRIM(pNumCte)||'_'|| TRIM(cNumCta)||'.txt';
    LET cNombreArchivoImg = TRIM(cNombreArchivoImg);

    LET cCommand = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaArchivo)||'reportesPDF_'||TRIM(cNomReporte)||'.sql';
    SYSTEM(cCommand);

    LET cSQL = TRIM(cRutaInformix)||'dbaccess bdinteg '||TRIM(cRutaArchivo)||'reportesPDF_'||TRIM(cNomReporte)||'.sql';
    SYSTEM cSQL;

    EXECUTE PROCEDURE bdinteg:"informix".sp_insertarimgleerarchivo(cRutaArchivoImg, cNombreArchivoImg) 
    INTO cCodRetSp;

    EXECUTE PROCEDURE bdinteg:"informix".sp_insertarimg(pNumCte, cNumCta, cProd) 
    INTO cCodRetSp;
    
    -- // ---> java8
    LET cCommand = "/usr/java8/bin/java -jar "||TRIM(cRutaArchivo)||"componente/EnvioImagenes.jar '"||TRIM(cRutaArchivoImg)||"' '"|| TRIM(cNombreArchivoImg)||"' '"|| TRIM(cVar6)||"' '"|| TRIM(cVar1)||"' '"|| TRIM(cVar2)||"' '"|| TRIM(cVar3)||"' '"|| TRIM(cVar4)||"' '"||TRIM(cVar5)||"'";
    SYSTEM(cCommand);
    
    RETURN cCodRet;

	END;
    
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 20/07/2020',
'DESCRIPCION: SPL encargado de realizar la ejecucion del componente Caratulas.jar para la generacion de los reportes en formato PDF.',
'BD: bdinteg',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 17/08/2020',
'DESCRIPCION: Se modifica para proporcionar correo electronico al componente de caratulas.jar.',
'BD: bdinteg',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 12/11/2021',
'DESCRIPCION: Se modifica para implementar el servicio web de insersion de imagen',
'BD: bdinteg',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 27/07/2023',
'DESCRIPCION: Se modifica para agregar nombre a caratula',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_exportarcatalogozonas_web(pCatalogo CHAR(1), pFechaAct DATE, pSeparador CHAR(1), pEjecucion CHAR(1))
RETURNING  CHAR(6), CHAR(80);
    
--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE cMensaje                         CHAR(80);
DEFINE cCadena                          CHAR (3000);
DEFINE vFechaArch                       DATE;
DEFINE vNomArch                         CHAR(30);
DEFINE vNomArchAux                      CHAR(40);
DEFINE vPath                            CHAR(50);
------------------------------------------------------------

-- Creado: Josï¿½ de Jesï¿½s Almeida Inzunza
-- Fecha: 19 de octubre de 2009
-- Crear en BDINTEG
-- Se crea con el objetivo de exportar el total o una parcialidad de las zonas del catalogo

-- Modificado por: MACF
-- Fecha: 07/06/2010
-- Agregar parï¿½metro pEjecucion para determinar si es Autmï¿½tica o Manual

LET cCod_ret      = '00000';
LET sql_err       = 0;
LET cMensaje      = '';
LET cCadena       = '';
LET vNomArch      = 'si_catzonas_web';
LET vNomArchAux   = 'si_catzonas_web_Aux';
LET vPath         = '';

      BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

--SET DEBUG FILE TO "/informix/Roberto/sp_ExportarCatalogoZonasWeb.out";
--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy
    INTO   vFechaArch
    FROM   bdinteg:si_fechas WHERE empresa = '001';
    
    if pEjecucion = 'A' then
        select trim(valor) into vPath 
        from bdinteg:si_param_dom 
        where cod_param = 24; ---CAMBIAR PARAMETRO A NUMERO CORRECTO EN PRODUCCION
    else
        select trim(valor) || '/tmp/' into vPath 
        from bdinteg:si_param_dom 
        where cod_param = 24; ---CAMBIAR PARAMETRO A NUMERO CORRECTO EN PRODUCCION
    end if;
    LET vPath = TRIM(vPath);

    LET vNomArchAux = TRIM(vNomArchAux) || TO_CHAR(vFechaArch,'%Y%m%d') || '.txt';    
    LET vNomArchAux = TRIM(vNomArchAux);
    LET vNomArch = TRIM(vNomArch) || TO_CHAR(vFechaArch,'%Y%m%d') || '.txt';    
    LET vNomArch = TRIM(vNomArch);

IF (pCatalogo = 1) THEN
        
          				
		  LET cCadena = 'echo " unload to ' || trim(vPath) || trim(vNomArchAux)  || ' DELIMITER ''' || pSeparador || ''' SELECT a.numerociudad, a.numerocolonia, '
                || 'upper(limpia_cadenaweb(a.nombrezona)), upper(limpia_cadenaweb(a.poblacionzona)), upper(limpia_cadenaweb(a.municipiozona)), nvl(a.codigopostalzona,0) codigopostalzona, '
                || 'a.planozona, upper(limpia_cadenaweb(nvl(a.rumbozona,''''))), '
                || 'nvl(a.supervisorzona,0) supervisorzona, nvl(a.choferzona,0) choferzona, nvl(a.jefegrupozona,0) jefegrupozona, nvl(a.gerentezona,0) gerentezona, '
                || 'nvl(a.abogadozona,0) abogadozona, a.marcaencuesta30dias, nvl(a.numerocalle,0) numerocalle, nvl(a.numerocasa,0) numerocasa, '
                || 'a.marcaunidadhabitacional, nvl(a.numerodivisioncobranzas,0) numerodivisioncobranzas, nvl(a.claveabogado,0) claveabogado, '
                || 'nvl(a.ciudadcobranzas,0) ciudadcobranzas, nvl(a.numerocobranzas,0) numerocobranzas,''1'' clavearagon, nvl(a.centro,0) centro '
                || ' FROM BDINTEG:si_catzonas a '
                --|| ', BDINTEG:si_catsepomex b, BDINTEG:si_estados c, BDINTEG:si_ciudades d  '
				--|| ' where c.estado = d.estado and lpad(a.codigopostalzona,5,''0'') = b.d_codigo and c.estado = b.c_estado and a.numerociudad = d.ciudad_coppel '
                --|| ' and TRIM(a.nomzona_spmx) = b.d_asenta and TRIM(a.mnpio_spmx) = b.d_mnpio and d.ciudad_coppel > 0 and d.elegir IS NULL and nvl(a.nomzona_spmx,'''') <> '''' and nvl(a.pobzona_spmx,'''')<>'''' '
                --|| ' and nvl(a.mnpio_spmx,'''') <>'''' ' --VALIDACION SEPOMEX
                || ' where nvl(a.mnpio_spmx,'''') <>'''' '
		    	|| '" >' || trim(vPath) ||'corre_si_catzonas_web.sql'; 
				
				
          System cCadena;

          let cCadena = 'dbaccess bdinteg ' || trim(vPath) || 'corre_si_catzonas_web.sql';
          System cCadena;

		  
          LET cCadena = "sed 's/"||pSeparador ||"$//g' "|| trim(vPath) || trim(vNomArchAux) || " >> " ||  trim(vPath) || trim(vNomArch);
          SYSTEM cCadena;

          let cCadena = 'rm ' || trim(vPath) || 'corre_si_catzonas_web.sql';
          System cCadena;    
          let cCadena = 'rm ' || trim(vPath) || trim(vNomArchAux );
          System cCadena; 
    
    
ELIF (pCatalogo = 0) THEN
     
LET cCadena = 'echo " unload to ' || trim(vPath) || trim(vNomArchAux)  || ' DELIMITER ''' || pSeparador || ''' SELECT a.numerociudad, a.numerocolonia, '
                || 'upper(limpia_cadenaweb(a.nombrezona)), upper(limpia_cadenaweb(a.poblacionzona)), upper(limpia_cadenaweb(a.municipiozona)), nvl(a.codigopostalzona,0) codigopostalzona, '
                || 'a.planozona, upper(limpia_cadenaweb(nvl(a.rumbozona,''''))), '
                || 'nvl(a.supervisorzona,0) supervisorzona, nvl(a.choferzona,0) choferzona, nvl(a.jefegrupozona,0) jefegrupozona, nvl(a.gerentezona,0) gerentezona, '
                || 'nvl(a.abogadozona,0) abogadozona, a.marcaencuesta30dias, nvl(a.numerocalle,0) numerocalle, nvl(a.numerocasa,0) numerocasa, '
                || 'a.marcaunidadhabitacional, nvl(a.numerodivisioncobranzas,0) numerodivisioncobranzas, nvl(a.claveabogado,0) claveabogado, '
                || 'nvl(a.ciudadcobranzas,0) ciudadcobranzas, nvl(a.numerocobranzas,0) numerocobranzas, ''1'' clavearagon, nvl(a.centro,0) centro '                
				|| ' FROM BDINTEG:si_catzonas a '
				--|| ', BDINTEG:si_catsepomex b, BDINTEG:si_estados c, BDINTEG:si_ciudades d  '
				--|| ' where c.estado = d.estado and lpad(a.codigopostalzona,5,''0'') = b.d_codigo and c.estado = b.c_estado and a.numerociudad = d.ciudad_coppel '
                --|| ' and TRIM(a.nomzona_spmx) = b.d_asenta and TRIM(a.mnpio_spmx) = b.d_mnpio and d.ciudad_coppel > 0 and d.elegir IS NULL and nvl(a.nomzona_spmx,'''') <> '''' and nvl(a.pobzona_spmx,'''')<>'''' '
                --|| ' and nvl(a.mnpio_spmx,'''') <>'''' ' --VALIDACION SEPOMEX
                || ' where nvl(a.mnpio_spmx,'''') <>'''' '
                || ' and f_inserta >= ''' || pFechaAct || ''' '
				|| '" >' || trim(vPath) ||'corre_si_catzonas_web.sql'; 
				
				
          --System cCadena;

          let cCadena = 'dbaccess bdinteg ' || trim(vPath) || 'corre_si_catzonas_web.sql';
          --System cCadena;

		  
          LET cCadena = "sed 's/"||pSeparador ||"$//g' "|| trim(vPath) || trim(vNomArchAux) || " >> " ||  trim(vPath) || trim(vNomArch);
          --SYSTEM cCadena;

          let cCadena = 'rm ' || trim(vPath) || 'corre_si_catzonas_web.sql';
          --System cCadena;    
          let cCadena = 'rm ' || trim(vPath) || trim(vNomArchAux );
          --System cCadena; 

   
ELSE

    LET cCod_ret = '00001';
    LET cMensaje = 'Parï¿½metro de Catï¿½logo Invalido';    
    RETURN cCod_ret, cMensaje;
   
END IF;    

LET cMensaje = TRIM(vNomArch);
RETURN cCod_ret, cMensaje;

END;
END PROCEDURE
DOCUMENT
'MODIFICACION: Victor D. Vazquez',
'FECHA: 2023/04/04',
'DESCRIPCION: Se modifica para agregar la depuraciï¿½n de caracteres especiales en algunos campos para SIWEB',
'BD: bdinteg',
'VERSION:202300404.100';

CREATE PROCEDURE "informix".sp_consulta_datos()
	returning CHAR(5) AS cCodRet;

DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
DEFINE IidErr           INTEGER; 
DEFINE pArchDeclarga1	CHAR(100);
DEFINE pArchDeclarga2   CHAR(100);
DEFINE pArchDeclarga3   CHAR(100);
DEFINE cQuery1          CHAR(10000);
DEFINE cSentencia       CHAR(200);
DEFINE sMes         	CHAR(2);
DEFINE sYear        	CHAR(4);
DEFINE sFechaArch   	CHAR(10);
DEFINE cNum   	   		CHAR(20);
DEFINE csicliente   	CHAR(20);
DEFINE cSecuencia       INTEGER;
DEFINE cCodpostal       CHAR(5);
DEFINE cSexo       		CHAR(1);
DEFINE cFecha_nac       DATE;
DEFINE vsql             CHAR(3000);
DEFINE cDescripcion     CHAR(40);
DEFINE cTipoP           CHAR(2);
DEFINE iCont			SMALLINT;
DEFINE iMaxCommit		INTEGER;

LET cCodRet 			= "00000";
LET IidErr				=0;
LET pArchDeclarga1   	= '';
LET sMes            	= '';
LET sYear           	= '';
LET sFechaArch      	= '';
LET cNum                = '';
LET csicliente 			= '';
LET cSecuencia			= '';
LET cCodpostal          = '';
LET cSexo				= '';
LET cFecha_nac          = '';
LET vsql				= '';
LET cDescripcion        = '';
LET cTipoP 				= '';
LET iCont				= 0;
LET iMaxCommit			= 5000;

	--SET DEBUG FILE TO "/ifxsif01/machavez/salidasp.out";
	--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SE LIMPIA LA TABLAS
	TRUNCATE TABLE td_numCliente;
	TRUNCATE TABLE td_descarga_datos;
	
	LET sMes= month(TODAY);	LET sYear= year(TODAY);	LET sFechaArch=sYear||sMes;
	
	LET pArchDeclarga2='"/RESPALDOSNEW/NumeroCliente'||TRIM(sFechaArch)||'.unl"';
	LET pArchDeclarga3='"/RESPALDOSNEW/"';
		
	LET cSentencia = 'echo "load from ' || TRIM(pArchDeclarga2)|| ' INSERT INTO td_numCliente  " > '|| TRIM(pArchDeclarga3)||'archivoinsert.sql';
	SYSTEM cSentencia;	  
	LET cSentencia = '';
	LET cSentencia = "dbaccess bdinteg " ||TRIM(pArchDeclarga3)||'archivoinsert.sql';
	SYSTEM cSentencia;
	
		BEGIN WORK;
			--create temp table descarga_datos_tmp (numcte char(20), Fecha_nacimiento date, sexo char(1), cod_postal char(5))WITH NO LOG;
			FOREACH WITH HOLD
				SELECT numcte INTO cNum FROM td_numCliente
		
				SELECT numcte, tpo_persona INTO csicliente, cTipoP FROM si_cliente WHERE  numcte = cNum;   
		
				IF (cNum = csicliente ) THEN
					
					LET cDescripcion = '';
					
					SELECT cod_postal, secuencia
					INTO cCodpostal, cSecuencia FROM si_direcciones
					WHERE numcte = csicliente and secuencia =(Select max(secuencia) FROM si_direcciones
															WHERE numcte = csicliente and tipo_dir = '1' group by numcte);
					
					IF ( cTipoP = '01' ) THEN
					
						SELECT  sexo, fecha_nac INTO cSexo, cFecha_nac FROM si_ctepf WHERE numcte = csicliente;
					
					END IF;
				ELSE
					LET cDescripcion = 'No se encontro el numero de cliente';
					LET cCodpostal = '';
					LET cSexo = '';
					LET cFecha_nac = '';
					
					IF (length(cNum) <> 9) THEN
					    LET cDescripcion = 'No corresponde a un numero de cliente';
					END IF;
					
				END IF;
				
				--Inserta los registros obtenidos en la tabla si_detalle_rpt_idbox
				INSERT INTO "informix".td_descarga_datos(numcte,fecha_nac,sexo,cod_postal,descripcion)
				VALUES (cNum,cFecha_nac,cSexo,cCodpostal,cDescripcion);
				
				LET iCont=iCont+1;
				IF iCont >= iMaxCommit THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
			END FOREACH;
	
		COMMIT WORK;
		
		BEGIN WORK;
			--generacion de reporte 
			let vsql ='echo "No_cliente|Fecha_nacimiento|Sexo|Codigo_postal|Descripcion">/RESPALDOSNEW/RPT_Datoscliente'||TRIM(sFechaArch)||'.txt';
			system vsql;
			let vsql='echo "UNLOAD TO /RESPALDOSNEW/TmpDatosCL.txt '||
			'SELECT numcte,fecha_nac,sexo,cod_postal,descripcion '|| 
			'FROM informix.td_descarga_datos;">/RESPALDOSNEW/rpt_Datoscl.sql';
			system vsql;
			system vsql;
			let vsql='dbaccess bdinteg /RESPALDOSNEW/rpt_Datoscl.sql';
			system vsql;
			let vsql ='rm /RESPALDOSNEW/rpt_Datoscl.sql';
			system vsql;
			let vsql ="sed 's/|$//g' /RESPALDOSNEW/TmpDatosCL.txt >>/RESPALDOSNEW/RPT_Datoscliente'"||TRIM(sFechaArch)||"'.txt";
			system vsql;
			let vsql ='rm /RESPALDOSNEW/TmpDatosCL.txt';
			system vsql;
			let cCodRet ='00000';
		COMMIT WORK;
		
		--SE LIMPIA LA TABLAS
		TRUNCATE TABLE td_numCliente;
		TRUNCATE TABLE td_descarga_datos;
	
	RETURN cCodRet;
END;
END PROCEDURE;