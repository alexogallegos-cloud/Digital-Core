CREATE PROCEDURE "informix".sp_cnsif_buscacte(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cTBUSQUEDA CHAR(1),cNOMBRE1 CHAR (26),cNOMBRE2 CHAR(26),cAPATERNO CHAR(26),cAMATERNO CHAR(26),dFNACIMIENTO DATE,cRSOCIAL CHAR(60),pNumRegistro INTEGER,pRecuperacion INTEGER)

    RETURNING CHAR(5)  AS Cod_Retorno,
			  CHAR(20) AS Numero_Cliente,
			  CHAR(13) AS RFC,
			  CHAR(1)  AS Id_Num_Consulta,
			  CHAR(26) AS Nombre_1,
			  CHAR(26) AS Nombre_2,
			  CHAR(26) AS Apellido_Paterno,
			  CHAR(26) AS Apellido_Materno,
			  CHAR(60) AS Razon_Social;
								
	--Variables
	DEFINE iexiste 					INT;
	DEFINE cCodRet 					CHAR(5);
	DEFINE iSql_err 				INT;
	DEFINE cNumero_cliente			CHAR(20);
	DEFINE cNombre1_salida			CHAR(26);
	DEFINE cNombre2_salida			CHAR(26);
	DEFINE cAPaterno1				CHAR(26);
	DEFINE cAMaterno1				char(26);
	DEFINE cRSocial1				CHAR(60);
	DEFINE cRFC1 					CHAR(13);
	DEFINE cId_Nconsulta_cliente	CHAR(1);
    DEFINE iCont                    INTEGER;
    DEFINE cRSOCIAL2                CHAR(60);
	DEFINE cTelefono                CHAR(10);


	--inicializando variables
	LET iexiste 	= 0;
	LET cCodRet 	= "00000";	
	LET iSql_err 	= 0;
	LET cNumero_cliente	 = "";
	LET cNombre1_salida	 = "";
	LET cNombre2_salida	 = "";
	LET cAPaterno1	 = "";
	LET cAMaterno1	 = "";
	LET cRSocial1	 = "";
	LET cRFC1	 = "";
	LET cId_Nconsulta_cliente	 = '1';
    LET iCont=0;
    LET cRSOCIAL2="";
	LET cTelefono = "";
	
	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
                
            END IF;
        END EXCEPTION;
		      --SET DEBUG FILE TO "/informix/CHVN/log/sp_cnsif_buscacte.out";
		      --TRACE ON;

        IF pNumRegistro<0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
        ELSE
            IF pRecuperacion<=0 THEN
                LET cCodRet='00098';
                RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
            END IF;
        END IF;    

		IF cTBUSQUEDA <> '1' AND cTBUSQUEDA <> '2' AND cTBUSQUEDA <> '3' THEN 
			LET cCodRet = "00052";
			RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
		END IF; 	
		
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;

		IF cCodRet = '00028' THEN 
			RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
		END IF;		
		
		IF cTBUSQUEDA = 1 THEN
			IF 		cID_USUARIOC ='' 	OR 
					cID_FUNCIONC = '' 	OR 
					cNOMBRE1 ='' 		OR
					cAPATERNO= ''  		THEN
					LET cCodRet = "00054";
					RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
			END IF;		
			IF cID_FUNCIONC='SKI002' THEN
				IF dFNACIMIENTO IS NULL OR dFNACIMIENTO='' THEN
					LET cCodRet = "00360";
					RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
				END IF;
			END IF;
			IF cNOMBRE2  <> '' THEN
				IF cAMATERNO <> '' THEN
					IF dFNACIMIENTO IS NULL THEN 
						FOREACH
                        SELECT FIRST 1 nvl(Count(numcte),0) INTO iexiste  FROM si_cliente WHERE nombre1 =cNOMBRE1 AND nombre2 =cNOMBRE2 AND apell_paterno = cAPATERNO AND apell_materno = cAMATERNO
						UNION
						SELECT nvl(Count(numcte_tf),0) FROM bditransfer:tf_maecte WHERE nombre1 =cNOMBRE1 AND nombre2 =cNOMBRE2 AND apell_paterno = cAPATERNO AND apell_materno = cAMATERNO
						ORDER BY 1 desc
						END FOREACH;
                        IF iexiste = 0 THEN
                            LET cCodRet = "00053";
                            RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
                        END IF;
						set isolation to dirty read;
						FOREACH
							SELECT SKIP pNumRegistro FIRST pRecuperacion CL.numcte,CL.nombre1,CL.nombre2,CL.apell_paterno,CL.apell_materno,CL.rfc_alterno 
							INTO
							cNumero_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRFC1
							FROM  si_cliente CL
							LEFT JOIN si_ctepf PF
							ON PF.numcte = CL.numcte
							WHERE CL.nombre1 = 	cNOMBRE1
							AND CL.nombre2 =	cNOMBRE2
							AND CL.apell_paterno = cAPATERNO
							AND CL.apell_materno = cAMATERNO
							UNION
							SELECT TF.numcte_tf,TF.nombre1,TF.nombre2,TF.apell_paterno,TF.apell_materno,TF.rfc
							FROM bditransfer:tf_maecte TF
							LEFT JOIN si_cliente PF
							ON PF.numcte = TF.numcte
							WHERE TF.nombre1 = 	cNOMBRE1
							AND TF.nombre2 =	cNOMBRE2
							AND TF.apell_paterno = cAPATERNO
							AND TF.apell_materno = cAMATERNO
							AND PF.numcte IS NULL
                            ORDER BY 1
							
                            IF cRFC1='' OR cRFC1 IS NULL THEN
                                SELECT rfc INTO cRFC1 FROM si_cliente WHERE numcte = cNumero_cliente AND empresa = '001';
                            END IF;

                            SELECT NVL(nivel,0) INTO cId_Nconsulta_cliente FROM si_cliente_nivel
                            WHERE numcte=cNumero_cliente;

                            IF cId_Nconsulta_cliente IS NULL THEN
                                LET cId_Nconsulta_cliente=9;
                            END IF;

                            LET iCont=iCont+1;
							RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1 with resume;
						END FOREACH;
                        IF iCont = 0 THEN
                            LET cCodRet = '1001'; 
                            RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
                        END IF 
					ELSE 
						FOREACH
                        SELECT FIRST 1 nvl(Count(CL.numcte),0) INTO iexiste FROM si_cliente CL LEFT JOIN si_ctepf PF ON PF.numcte = CL.numcte WHERE CL.nombre1 = cNOMBRE1 AND CL.nombre2 =cNOMBRE2 AND
                        CL.apell_paterno = cAPATERNO AND CL.apell_materno = cAMATERNO AND PF.fecha_nac = dFNACIMIENTO
						UNION
						SELECT nvl(Count(TF.numcte_tf),0) FROM bditransfer:tf_maecte TF WHERE TF.nombre1 = cNOMBRE1 AND TF.nombre2 =cNOMBRE2 AND
                        TF.apell_paterno = cAPATERNO AND TF.apell_materno = cAMATERNO AND TF.fecha_nac = dFNACIMIENTO
						ORDER BY 1 desc
						END FOREACH;
                        IF iexiste = 0 THEN
                            LET cCodRet = "00053";
                            RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
                        END IF;
						set isolation to dirty read;
						FOREACH
							SELECT SKIP pNumRegistro FIRST pRecuperacion CL.numcte,CL.nombre1,CL.nombre2,CL.apell_paterno,CL.apell_materno,CL.razon_social,CL.rfc_alterno
							INTO
							cNumero_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1,cRFC1
							FROM  si_cliente CL
							LEFT JOIN si_ctepf PF
							ON PF.numcte = CL.numcte
							WHERE CL.nombre1 = 	cNOMBRE1
							AND CL.nombre2 =	cNOMBRE2
							AND CL.apell_paterno = cAPATERNO
							AND CL.apell_materno = cAMATERNO
							AND PF.fecha_nac = dFNACIMIENTO
							UNION
							SELECT TF.numcte_tf,TF.nombre1,TF.nombre2,TF.apell_paterno,TF.apell_materno,'',TF.rfc
							FROM bditransfer:tf_maecte TF
							LEFT JOIN si_cliente PF
							ON PF.numcte = TF.numcte
							WHERE TF.nombre1 = 	cNOMBRE1
							AND TF.nombre2 =	cNOMBRE2
							AND TF.apell_paterno = cAPATERNO
							AND TF.apell_materno = cAMATERNO
							AND TF.fecha_nac = dFNACIMIENTO
							AND PF.numcte IS NULL
                            ORDER BY 1

                            IF cRFC1='' OR cRFC1 IS NULL THEN
                                SELECT rfc INTO cRFC1 FROM si_cliente WHERE numcte = cNumero_cliente AND empresa = '001';
                            END IF;

                            SELECT NVL(nivel,0) INTO cId_Nconsulta_cliente FROM si_cliente_nivel
                            WHERE numcte=cNumero_cliente;

                            IF cId_Nconsulta_cliente IS NULL THEN
                                LET cId_Nconsulta_cliente=9;
                            END IF;
							
                            LET iCont=iCont+1;	
							RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1 with resume;
						END FOREACH;
                        IF iCont = 0 THEN
                            LET cCodRet = '1001'; 
                            RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
                        END IF 	
					END IF;
				ELSE 
					FOREACH
                    SELECT FIRST 1 nvl(Count(numcte),0) INTO iexiste  FROM si_cliente WHERE nombre1 =cNOMBRE1 AND nombre2 =cNOMBRE2 AND apell_paterno = cAPATERNO
					UNION
					SELECT nvl(Count(TF.numcte_tf),0) FROM bditransfer:tf_maecte TF WHERE TF.nombre1 = cNOMBRE1 AND TF.nombre2 =cNOMBRE2 AND TF.apell_paterno = cAPATERNO
					ORDER BY 1 desc
					END FOREACH;
                        IF iexiste = 0 THEN
                            LET cCodRet = "00053";
                            RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
                        END IF;
					IF dFNACIMIENTO IS NULL  THEN
						set isolation to dirty read;
						FOREACH
							SELECT SKIP pNumRegistro FIRST pRecuperacion CL.numcte,CL.nombre1,CL.nombre2,CL.apell_paterno,CL.apell_materno,CL.razon_social,CL.rfc_alterno
							INTO
							cNumero_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1,cRFC1
							FROM  si_cliente CL
							LEFT JOIN si_ctepf PF
							ON PF.numcte = CL.numcte
							WHERE CL.nombre1 = 	cNOMBRE1
							AND CL.nombre2 =	cNOMBRE2
							AND CL.apell_paterno = cAPATERNO
							UNION
							SELECT TF.numcte_tf,TF.nombre1,TF.nombre2,TF.apell_paterno,TF.apell_materno,'',TF.rfc
							FROM bditransfer:tf_maecte TF
							LEFT JOIN si_cliente PF
							ON PF.numcte = TF.numcte
							WHERE TF.nombre1 = cNOMBRE1
							AND TF.nombre2 = cNOMBRE2
							AND TF.apell_paterno = cAPATERNO
							AND PF.numcte IS NULL
							ORDER BY 1

                            IF cRFC1='' OR cRFC1 IS NULL THEN
                                SELECT rfc INTO cRFC1 FROM si_cliente WHERE numcte = cNumero_cliente AND empresa = '001';
                            END IF;

                            SELECT NVL(nivel,0) INTO cId_Nconsulta_cliente FROM si_cliente_nivel
                            WHERE numcte=cNumero_cliente;

                            IF cId_Nconsulta_cliente IS NULL THEN
                                LET cId_Nconsulta_cliente=9;
                            END IF;
							
                            LET iCont=iCont+1;	
							RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1 with resume;
						END FOREACH;
                        IF iCont = 0 THEN
                            LET cCodRet = '1001'; 
                            RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
                        END IF 
					ELSE
                        FOREACH
						SELECT FIRST 1 nvl(Count(CL.numcte),0) INTO iexiste FROM si_cliente CL LEFT JOIN si_ctepf PF ON PF.numcte = CL.numcte WHERE CL.nombre1 = cNOMBRE1 AND CL.nombre2 =cNOMBRE2 AND
                        CL.apell_paterno = cAPATERNO AND PF.fecha_nac = dFNACIMIENTO
						UNION
						SELECT nvl(Count(TF.numcte_tf),0) FROM bditransfer:tf_maecte TF WHERE TF.nombre1 = cNOMBRE1 AND TF.nombre2 =cNOMBRE2 AND
                        TF.apell_paterno = cAPATERNO AND TF.fecha_nac = dFNACIMIENTO
						ORDER BY 1 desc
						END FOREACH;
                            IF iexiste = 0 THEN
                                LET cCodRet = "00053";
                                RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
                            END IF;
						set isolation to dirty read;
						FOREACH
							SELECT SKIP pNumRegistro FIRST pRecuperacion CL.numcte,CL.nombre1,CL.nombre2,CL.apell_paterno,CL.apell_materno,CL.razon_social,CL.rfc_alterno
							INTO
							cNumero_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1,cRFC1
							FROM  si_cliente CL
							LEFT JOIN si_ctepf PF
							ON PF.numcte = CL.numcte
							WHERE CL.nombre1 = 	cNOMBRE1
							AND CL.nombre2 =	cNOMBRE2
							AND CL.apell_paterno = cAPATERNO
							AND PF.fecha_nac = dFNACIMIENTO
                            UNION
							SELECT TF.numcte_tf,TF.nombre1,TF.nombre2,TF.apell_paterno,TF.apell_materno,'',TF.rfc
							FROM bditransfer:tf_maecte TF
							LEFT JOIN si_cliente PF
							ON PF.numcte = TF.numcte
							WHERE TF.nombre1 = cNOMBRE1
							AND TF.nombre2 = cNOMBRE2
							AND TF.apell_paterno = cAPATERNO
							AND TF.fecha_nac = dFNACIMIENTO
							AND PF.numcte IS NULL
                            ORDER BY 1

                            IF cRFC1='' OR cRFC1 IS NULL THEN
                                SELECT rfc INTO cRFC1 FROM si_cliente WHERE numcte = cNumero_cliente AND empresa = '001';
                            END IF;

                            SELECT NVL(nivel,0) INTO cId_Nconsulta_cliente FROM si_cliente_nivel
                            WHERE numcte=cNumero_cliente;

                            IF cId_Nconsulta_cliente IS NULL THEN
                                LET cId_Nconsulta_cliente=9;
                            END IF;
							
                            LET iCont=iCont+1;		
							RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1 with resume;
						END FOREACH;
                        IF iCont = 0 THEN
                            LET cCodRet = '1001'; 
                            RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
                        END IF 
					END IF;	
				END IF;	
			ELSE
				IF cAMATERNO <> '' THEN
					iF dFNACIMIENTO IS NULL  THEN
						FOREACH
                        SELECT FIRST 1 nvl(Count(numcte),0) INTO iexiste  FROM si_cliente WHERE nombre1 =cNOMBRE1 AND apell_paterno = cAPATERNO AND apell_materno = cAMATERNO
						UNION
						SELECT nvl(Count(numcte_tf),0) FROM bditransfer:tf_maecte WHERE nombre1 =cNOMBRE1 AND apell_paterno = cAPATERNO AND apell_materno = cAMATERNO
						ORDER BY 1 desc
						END FOREACH;
                        IF iexiste = 0 THEN
                            LET cCodRet = "00053";
                            RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
                        END IF;
						set isolation to dirty read;
						FOREACH
							SELECT SKIP pNumRegistro FIRST pRecuperacion CL.numcte,CL.nombre1,CL.nombre2,CL.apell_paterno,CL.apell_materno,CL.razon_social,CL.rfc_alterno
							INTO
							cNumero_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1,cRFC1
							FROM  si_cliente CL
							LEFT JOIN si_ctepf PF
							ON PF.numcte = CL.numcte
							WHERE CL.nombre1 = 	cNOMBRE1
							AND CL.apell_paterno = cAPATERNO
							AND CL.apell_materno = cAMATERNO
							UNION
							SELECT TF.numcte_tf, TF.nombre1,TF.nombre2,TF.apell_paterno,TF.apell_materno,'',TF.rfc
							FROM bditransfer:tf_maecte TF
							LEFT JOIN si_cliente PF
							ON PF.numcte = TF.numcte
							WHERE TF.nombre1 = 	cNOMBRE1
							AND TF.apell_paterno = cAPATERNO
							AND TF.apell_materno = cAMATERNO
							AND PF.numcte IS NULL
			                ORDER BY 1

                            IF cRFC1='' OR cRFC1 IS NULL THEN
                                SELECT rfc INTO cRFC1 FROM si_cliente WHERE numcte = cNumero_cliente AND empresa = '001';
                            END IF;

                            SELECT NVL(nivel,0) INTO cId_Nconsulta_cliente FROM si_cliente_nivel
                            WHERE numcte=cNumero_cliente;

                            IF cId_Nconsulta_cliente IS NULL THEN
                                LET cId_Nconsulta_cliente=9;
                            END IF;
							
                            LET iCont=iCont+1;	
							RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1 with resume;
						END FOREACH;
                        IF iCont = 0 THEN
                            LET cCodRet = '1001'; 
                            RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
                        END IF 
					ELSE
						FOREACH
                        SELECT FIRST 1 nvl(Count(CL.numcte),0) INTO iexiste FROM si_cliente CL LEFT JOIN si_ctepf PF ON PF.numcte = CL.numcte WHERE CL.nombre1 = cNOMBRE1 
                        AND CL.apell_paterno = cAPATERNO AND CL.apell_materno = cAMATERNO AND PF.fecha_nac = dFNACIMIENTO
						UNION
						SELECT nvl(Count(TF.numcte_tf),0) FROM bditransfer:tf_maecte TF WHERE TF.nombre1 = cNOMBRE1 
                        AND TF.apell_paterno = cAPATERNO AND TF.apell_materno = cAMATERNO AND TF.fecha_nac = dFNACIMIENTO
						ORDER BY 1 desc
						END FOREACH; 
                        IF iexiste = 0 THEN
                            LET cCodRet = "00053";
                            RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
                        END IF;
						set isolation to dirty read;
						FOREACH
							SELECT SKIP pNumRegistro FIRST pRecuperacion CL.numcte,CL.nombre1,CL.nombre2,CL.apell_paterno,CL.apell_materno,CL.razon_social,CL.rfc_alterno
							INTO
							cNumero_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1,cRFC1
							FROM  si_cliente CL
							LEFT JOIN si_ctepf PF
							ON PF.numcte = CL.numcte
							WHERE CL.nombre1 = 	cNOMBRE1
							AND CL.apell_paterno = cAPATERNO
							AND CL.apell_materno = cAMATERNO
							AND PF.fecha_nac = dFNACIMIENTO	
                            UNION
							SELECT TF.numcte_tf,TF.nombre1,TF.nombre2,TF.apell_paterno,TF.apell_materno,'',TF.rfc
							FROM bditransfer:tf_maecte TF
							LEFT JOIN si_cliente PF
							ON PF.numcte = TF.numcte
							WHERE TF.nombre1 = 	cNOMBRE1
							AND TF.apell_paterno = cAPATERNO
							AND TF.apell_materno = cAMATERNO
							AND TF.fecha_nac = dFNACIMIENTO	
							AND PF.numcte IS NULL
                            ORDER BY 1

                            IF cRFC1='' OR cRFC1 IS NULL THEN
                                SELECT rfc INTO cRFC1 FROM si_cliente WHERE numcte = cNumero_cliente AND empresa = '001';
                            END IF;

                            SELECT NVL(nivel,0) INTO cId_Nconsulta_cliente FROM si_cliente_nivel
                            WHERE numcte=cNumero_cliente;

                            IF cId_Nconsulta_cliente IS NULL THEN
                                LET cId_Nconsulta_cliente=9;
                            END IF;
							
                            LET iCont=iCont+1;	
							RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1 with resume;
						END FOREACH;
                        IF iCont = 0 THEN
                            LET cCodRet = '1001'; 
                            RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
                        END IF 
					END IF;
				ELSE 
					iF dFNACIMIENTO IS NULL  THEN
						FOREACH
						SELECT FIRST 1 nvl(Count(numcte),0) INTO iexiste FROM si_cliente WHERE nombre1 = cNOMBRE1 AND apell_paterno = cAPATERNO
						UNION
						SELECT nvl(Count(numcte_tf),0) FROM bditransfer:tf_maecte WHERE nombre1 = cNOMBRE1 AND apell_paterno = cAPATERNO
						ORDER BY 1 desc
						END FOREACH;
                        IF iexiste = 0 THEN
                            LET cCodRet = "00053";
                            RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
                        END IF;
						set isolation to dirty read;
						FOREACH
							SELECT SKIP pNumRegistro FIRST pRecuperacion CL.numcte,CL.nombre1,CL.nombre2,CL.apell_paterno,CL.apell_materno,CL.razon_social,CL.rfc_alterno
							INTO
							cNumero_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1,cRFC1
							FROM  si_cliente CL
							LEFT JOIN si_ctepf PF
							ON PF.numcte = CL.numcte
							WHERE CL.nombre1 = 	cNOMBRE1
							AND CL.apell_paterno = cAPATERNO
							UNION
							SELECT TF.numcte_tf,TF.nombre1,TF.nombre2,TF.apell_paterno,TF.apell_materno,'',TF.rfc
							FROM bditransfer:tf_maecte TF
							LEFT JOIN si_cliente PF
							ON PF.numcte = TF.numcte
							WHERE TF.nombre1 = 	cNOMBRE1
							AND TF.apell_paterno = cAPATERNO
							AND PF.numcte IS NULL
                            ORDER BY 1

                            IF cRFC1='' OR cRFC1 IS NULL THEN
                                SELECT rfc INTO cRFC1 FROM si_cliente WHERE numcte = cNumero_cliente AND empresa = '001';
                            END IF;

                            SELECT NVL(nivel,0) INTO cId_Nconsulta_cliente FROM si_cliente_nivel
                            WHERE numcte=cNumero_cliente;

                            IF cId_Nconsulta_cliente IS NULL THEN
                                LET cId_Nconsulta_cliente=9;
                            END IF;
							
                            LET iCont=iCont+1;	
							RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1 with resume;
						END FOREACH;
                        IF iCont = 0 THEN
                            LET cCodRet = '1001'; 
                            RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
                        END IF 
					ELSE 
						FOREACH
						SELECT FIRST 1 nvl(Count(CL.numcte),0) INTO iexiste FROM si_cliente CL LEFT JOIN si_ctepf PF ON PF.numcte = CL.numcte WHERE CL.nombre1 = cNOMBRE1 AND 
                        CL.apell_paterno = cAPATERNO AND PF.fecha_nac = dFNACIMIENTO
						UNION
						SELECT nvl(Count(TF.numcte_tf),0) FROM bditransfer:tf_maecte TF WHERE TF.nombre1 = cNOMBRE1 AND 
                        TF.apell_paterno = cAPATERNO AND TF.fecha_nac = dFNACIMIENTO
						ORDER BY 1 desc
						END FOREACH; 
                        IF iexiste = 0 THEN
                            LET cCodRet = "00053";
                            RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
                        END IF;
						set isolation to dirty read;
						FOREACH
							SELECT SKIP pNumRegistro FIRST pRecuperacion CL.numcte,CL.nombre1,CL.nombre2,CL.apell_paterno,CL.apell_materno,CL.razon_social,CL.rfc_alterno
							INTO
							cNumero_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1,cRFC1
							FROM  si_cliente CL
							LEFT JOIN si_ctepf PF
							ON PF.numcte = CL.numcte
							WHERE CL.nombre1 = 	cNOMBRE1
							AND CL.apell_paterno = cAPATERNO
							AND PF.fecha_nac = dFNACIMIENTO	
							UNION
                            SELECT TF.numcte_tf,TF.nombre1,TF.nombre2,TF.apell_paterno,TF.apell_materno,'',TF.rfc
							FROM bditransfer:tf_maecte TF
							LEFT JOIN si_cliente PF
							ON PF.numcte = TF.numcte
							WHERE TF.nombre1 = 	cNOMBRE1
							AND TF.apell_paterno = cAPATERNO
							AND TF.fecha_nac = dFNACIMIENTO	
							AND PF.numcte IS NULL
                            ORDER BY 1

                            IF cRFC1='' OR cRFC1 IS NULL THEN
                                SELECT rfc INTO cRFC1 FROM si_cliente WHERE numcte = cNumero_cliente AND empresa = '001';
                            END IF;

                            SELECT NVL(nivel,0) INTO cId_Nconsulta_cliente FROM si_cliente_nivel
                            WHERE numcte=cNumero_cliente;

                            IF cId_Nconsulta_cliente IS NULL THEN
                                LET cId_Nconsulta_cliente=9;
                            END IF;
							
                            LET iCont=iCont+1;	
							RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1 with resume;
						END FOREACH;
                        IF iCont = 0 THEN
                            LET cCodRet = '1001'; 
                            RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
                        END IF 
					END IF;
				END IF;	
			END IF;
		ELIF  cTBUSQUEDA = 2 THEN
			IF 	cID_USUARIOC ='' 	OR 
				cID_FUNCIONC = '' 	OR 
				cRSOCIAL ='' 		THEN
				LET cCodRet = "00054";
				RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
			END IF;	

            LET cRSOCIAL2=TRIM(cRSOCIAL)||'%';
	
			SELECT {+INDEX (bdinteg:si_cliente idx_razonsocial)} nvl(Count(numcte),0) INTO iexiste  FROM si_cliente where razon_social LIKE cRSOCIAL2;
			IF iexiste = 0 THEN
				LET cCodRet = "00053";
				RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
			END IF;
			SET ISOLATION TO DIRTY READ;	
			FOREACH	
				SELECT {+INDEX (bdinteg:si_cliente idx_razonsocial)} SKIP pNumRegistro FIRST pRecuperacion CL.numcte,CL.razon_social,CL.rfc_alterno
				INTO
				cNumero_cliente,cRSocial1,cRFC1
				FROM  si_cliente CL
                WHERE CL.razon_social LIKE cRSOCIAL2
                ORDER BY 1

                IF cRFC1='' OR cRFC1 IS NULL THEN
                    SELECT rfc INTO cRFC1 FROM si_cliente WHERE numcte = cNumero_cliente AND empresa = '001';
                END IF;

                SELECT NVL(nivel,0) INTO cId_Nconsulta_cliente FROM si_cliente_nivel
                WHERE numcte=cNumero_cliente;

                IF cId_Nconsulta_cliente IS NULL THEN
                    LET cId_Nconsulta_cliente=9;
                END IF;
							
                LET iCont=iCont+1;	
				RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1 with resume;
			END FOREACH;
            IF iCont = 0 THEN
                LET cCodRet = '1001'; 
                RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
            END IF 
		ELIF  cTBUSQUEDA = 3 THEN -- Busqueda por numero de telefono
			IF 	cID_USUARIOC ='' 	OR 
				cID_FUNCIONC = '' 	OR 
				cNOMBRE1 ='' 		THEN
				LET cCodRet = "00054";
				RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
			END IF;	
			
			LET cTelefono = TRIM(cNOMBRE1);
			
			SET ISOLATION TO DIRTY READ;
			SELECT COUNT(numcte) 
			INTO iexiste
			FROM bdinteg:'informix'.si_cliente
			WHERE numcte IN (SELECT numcte
				FROM bdinteg:'informix'.si_telefonos_actual
				WHERE tipo_tel = '2' AND status_tel = 'A'
					AND telefono = cTelefono);
					
			IF iexiste = 0 THEN
				LET cCodRet = "00318";
				RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
			END IF;
			
			FOREACH SELECT {+INDEX (bdinteg:si_cliente idx_notelefono)} SKIP pNumRegistro FIRST pRecuperacion 
					CL.numcte,CL.nombre1,CL.nombre2,CL.apell_paterno,CL.apell_materno,CL.razon_social,CL.rfc_alterno
					INTO cNumero_cliente, cNombre1_salida, cNombre2_salida, cAPaterno1, cAMaterno1, cRSocial1, cRFC1
					FROM bdinteg:'informix'.si_cliente CL
					WHERE CL.numcte IN (SELECT numcte
										FROM bdinteg:'informix'.si_telefonos_actual
										WHERE tipo_tel = '2' AND status_tel = 'A'
										AND telefono = cTelefono)
					ORDER BY 1
					
					LET iCont=iCont+1;	
					RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1 with resume;
				
			END FOREACH;
			
			IF iCont = 0 THEN
                LET cCodRet = '1001'; 
                RETURN cCodRet,cNumero_cliente,cRFC1,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1;
            END IF 

		END IF
	END
END PROCEDURE
DOCUMENT 
"AutOR : Antonio Flores",
"FUNCIONAMIENTO:Este SP servira para la busqueda de clientes segun su nombre su apellido paterno y el tipo de busqueda,",
"los tipos de busqueda son 1.- para persona fisica, 2 .- para personal moral",  
"FECHA : 26-12-2011",
"AutOR : Oscar Flores Conde",
"FUNCIONAMIENTO: Se agrega busqueda por medio del numero de telefono",
"FECHA : 14-12-2015",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_validaestatuspersonal2 (pEmpresa CHAR(3),pSucursal CHAR(4),pCodUsuario CHAR(8))

--DATOS A REGRESAR---
RETURNING
CHAR    (5)   AS cCodRet,
CHAR    (6)   AS sEstatus, 
char    (20)  as cPuesto, 
date          as dFechIns;


--DEFINICION DE VARIABLES--
DEFINE iSql_err       INTEGER;
DEFINE cCodRet        CHAR(5);
DEFINE cEmpleado      CHAR(8);
DEFINE vPassword      VARCHAR (200);
DEFINE cSucursal      CHAR(4);
DEFINE cStatus        CHAR(6);
DEFINE cPuesto     char(20);
DEFINE vfecha_insert  date;

--INICIALIZACION DE VARIABLES--
LET iSql_err           = 0;
LET cCodRet           = '00000';
LET cEmpleado         = '';
LET vPassword         = '';
LET cSucursal         = '';
LET cStatus           = '';
LET cPuesto           = '';
LET vfecha_insert     = '';

   --SET DEBUG FILE TO "/respaldosbd/Martha/sp_validaestatuspersonal.out";
   --TRACE ON;
  
BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,cStatus, cPuesto, vfecha_insert;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION  TO DIRTY READ;
	
	IF NVL(pEmpresa, '') = '' OR NVL(pSucursal, '') = '' OR NVL(pCodUsuario,'') = '' THEN
		
		LET cCodRet = '00001';
		
	ELSE

		SELECT ejecutivo, password, sucursal, NVL(nombramiento,''), fecha_insert 
		INTO cEmpleado, vPassword, cSucursal, cPuesto, vfecha_insert
		FROM bdinteg:"informix".si_ejecut 
		WHERE empresa = pEmpresa
		AND ejecutivo = pCodUsuario;
					
		IF DBINFO("sqlca.sqlerrd2") > 0 THEN
		
			IF TRIM (UPPER(vPassword)) <> "BAJA" THEN
				IF cSucursal = pSucursal THEN
					LET cStatus = 'ACTIVO'; 
				ELSE
					LET cStatus = 'CAMBIO';
				END IF;
			ELSE
				LET cStatus = 'BAJA';
			END IF;
		
		ELSE
			LET cStatus = 'BAJA';
            LET cPuesto = '';
            LET vfecha_insert = '01011900';
		END IF;
		
	END IF;

	RETURN cCodRet,cStatus, cPuesto, vfecha_insert;
	
END
END PROCEDURE

DOCUMENT
"Autor : Martha Aguirre",
"FECHA : 07/09/2012",
"Descripcion: Realiza consulta para validar que el usuario",
"se encuentre activo en la sucursal",
"Ver.  : 1.0",
"BD    : bdinteg";

CREATE PROCEDURE "informix".consnumcte(pempresa char(3),pnumcte char(20))
       returning char(5),char(2),char(4),char(8),
                 char(2),char(1),char(26),char(26),char(26),
                 char(26),char(60),char(13),char(2),char(3),char(3),char(3),
                 char(3),char(1),date,char(26),char(2),char(20),char(20),char(60),
                 smallint,int,money(14,2),date,char(1),char(1),char(11),
                 char(8),
                 date,char(2),char(3),char(18),char(2),char(1),char(3),char(1),
                 char(20),char(2),char(20),char(12),smallint,char(60),char(60),
                 char(60),char(1),char(2),char(2),smallint,char(60),money(16,2),
                 char(30),char(20),char(20),char(20),char(20),char(20),int,int,
                 money(14,2),date;
    
    define vcodret char(5);
    define vesfisica char(1);
    define vlong_cte smallint;
    define vlongitud smallint;
    define vsqlerr integer;
    define vdiacorte smallint;
    
    define vstatus_cte char(2);
    define vsucursal char(4);
    define vejecutivo char(8);
    define vtpo_persona char(2);
    define vtipo_cliente char(1);
    define vapell_paterno char(26);
    define vapell_materno char(26);
    define vnombre1 char(26);
    define vnombre2 char(26);
    define vrazon_social char(60);
    define vrfc char(13);
    define vsector char(2);
    define vsegmento char(3);
    define vactividad_princ char(3);
    define vgrupo char(3);
    define vsubgrupo char(3);
    define vresidencia char(1);
    define vfecha_alta date ;
    define vapell_casada char(26);
    define vdistrito char(2);
    define vnumcte_ref char(20);
    define vstring1 char(20);
    define vstring2 char(60);
    define vnumeric1 smallint ;
    define vnumeric2 int ;
    define vmoney1 money(14,2);
    define vdate1 date ;
    define vpuesto_ppes char(1);
    define vfamiliar_ppes char(1);
    define vactividad_esp char(11);
    define vejecut_autoriza char(8);

    define vpffecha_nac date;
    define vpflugar_nac char(2);
    define vpfnacionalidad char(3);
    define vpfno_fm3 char(18);
    define vpfestado_civil char(2);
    define vpfregim_matrimonio char(1);
    define vpfprofesion char(3);
    define vpfsexo char(1);
    define vpfcurp char(20);
    define vpfcodidentifi char(2);
    define vpfnumidentifi char(20);
    define vpfno_imss char(12);
    define vpfdependientes smallint ;
    define vpftutor char(60);
    define vpfemail char(60);
    define vpfpfnom_conyuge char(60);
    define vpfseguro_defunc char(1);
    define vpfescolaridad char(2);
    define vpfhabita_en char(2);
    define vpfanios_habita smallint ;
    define vpfnombre_prop char(60);
    define vpfimp_hipo_renta money(16,2);
    define vpfactividadogiro char(30);
    define vpfnumeroife char(20);
    define vpfnumerotutor char(20);
    define vpfnumeroconyuge char(20);
    define vpfstring1 char(20);
    define vpfstring2 char(20);
    define vpfnumeric1 int ;
    define vpfnumeric2 int ;
    define vpfmoney1 money(14,2);
    define vpfdate1 date ;
    define vrfc_alterno char(13);
	define vdescripcion char(60);
    
    let vcodret = "";
    let vesfisica = "";
    let vlong_cte = 0;
    let vlongitud = 0;
    let vsqlerr = 0;
    let vdiacorte = 0;
    
    let vstatus_cte  = "";
    let vsucursal = "";
    let vejecutivo = "";
    let vtpo_persona = "";
    let vtipo_cliente = "";
    let vapell_paterno = "";
    let vapell_materno = "";
    let vnombre1 = "";
    let vnombre2 = "";
    let vrazon_social = "";
    let vrfc = "";
    let vsector = "";
    let vsegmento = "";
    let vactividad_princ = "";
    let vgrupo = "";
    let vsubgrupo = "";
    let vresidencia = "";
    let vfecha_alta = "";
    let vapell_casada  = "";
    let vdistrito = "";
    let vnumcte_ref = "";
    let vstring1 = "";
    let vstring2  = "";
    let vnumeric1  = 0;
    let vnumeric2  = 0;
    let vmoney1 = 0;
    let vdate1  = "";
    let vpuesto_ppes = "";
    let vfamiliar_ppes = "";
    let vactividad_esp = "";
    let vejecut_autoriza  = "";
    
    let vpffecha_nac  = "";
    let vpflugar_nac  = "";
    let vpfnacionalidad  = "";
    let vpfno_fm3  = "";
    let vpfestado_civil = "";
    let vpfregim_matrimonio = "";
    let vpfprofesion  = "";
    let vpfsexo = "";
    let vpfcurp  = "";
    let vpfcodidentifi = "";
    let vpfnumidentifi  = "";
    let vpfno_imss  = "";
    let vpfdependientes = 0;
    let vpftutor  = "";
    let vpfemail  = "";
    let vpfpfnom_conyuge  = "";
    let vpfseguro_defunc = "";
    let vpfescolaridad = "";
    let vpfhabita_en = "";
    let vpfanios_habita  = 0;
    let vpfnombre_prop = "";
    let vpfimp_hipo_renta  = 0;
    let vpfactividadogiro = "";
    let vpfnumeroife = "";
    let vpfnumerotutor = "";
    let vpfnumeroconyuge = "";
    let vpfstring1 = "";
    let vpfstring2 = "";
    let vpfnumeric1 = 0;
    let vpfnumeric2 = 0;
    let vpfmoney1 = 0;
    let vpfdate1 = "";
    let vrfc = "";
	let vdescripcion = "";
    
    begin
    
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            RETURN vcodret  ,vstatus_cte ,vsucursal ,vejecutivo ,vtpo_persona ,
                   vtipo_cliente ,vapell_paterno ,vapell_materno ,vnombre1 ,vnombre2 ,
                   vrazon_social ,vrfc ,vsector ,vsegmento ,vactividad_princ ,vgrupo ,vsubgrupo ,
                   vresidencia ,vfecha_alta ,vapell_casada ,vdistrito ,vnumcte_ref ,vstring1,
                   vstring2 ,vnumeric1 ,vnumeric2 ,vmoney1 ,vdate1 ,vpuesto_ppes,
                   vfamiliar_ppes ,vactividad_esp ,vejecut_autoriza,
                   vpffecha_nac  ,vpflugar_nac  ,vpfnacionalidad  ,vpfno_fm3  ,vpfestado_civil,
                   vpfregim_matrimonio ,vpfprofesion  ,vpfsexo  ,vpfcurp  ,vpfcodidentifi,
                   vpfnumidentifi  ,vpfno_imss  ,vpfdependientes  ,vpftutor  ,vpfemail,
                   vpfpfnom_conyuge   ,vpfseguro_defunc ,vpfescolaridad ,vpfhabita_en ,vpfanios_habita,
                   vpfnombre_prop ,vpfimp_hipo_renta ,vpfactividadogiro ,vpfnumeroife ,vpfnumerotutor ,
                   vpfnumeroconyuge ,vpfstring1 ,vpfstring2 ,vpfnumeric1 ,vpfnumeric2 ,vpfmoney1 ,vpfdate1;
        end if
    end exception;
    
SET LOCK MODE TO WAIT 3;
SET ISOLATION  TO DIRTY READ;


    let vcodret = "00000";
    
    select valor 
      into vlong_cte 
      from bdinteg:"informix".si_param 
     where cod_param = 7
       and empresa = pempresa;

    let vlongitud = length(pnumcte);
    
    if vlongitud < vlong_cte then
        foreach
            execute procedure formateo_cte(pnumcte)
            into pnumcte
        end foreach;
    end if

    SELECT c.status_cte ,c.sucursal ,c.ejecutivo ,c.tpo_persona ,
           c.tipo_cliente ,c.apell_paterno ,c.apell_materno ,c.nombre1 ,c.nombre2 ,
           c.razon_social ,c.rfc ,c.sector ,c.segmento ,c.actividad_princ ,c.grupo ,c.subgrupo ,
           c.residencia ,c.fecha_insert ,c.apell_casada ,c.distrito ,c.numcte_ref ,c.string1,
           c.string2 ,c.numeric1 ,c.numeric2 ,c.money1 ,c.date1 ,c.puesto_ppes,
           c.familiar_ppes ,c.actividad_esp ,c.ejecut_autoriza,
           f.fecha_nac  ,f.lugar_nac  ,f.nacionalidad  ,f.no_fm3  ,f.estado_civil,
           f.regim_matrimonio ,f.profesion  ,f.sexo  ,f.curp  ,f.codidentifi,
           f.numidentifi  ,f.no_imss  ,f.dependientes  , f.tutor,
           f.nom_conyuge   ,f.seguro_defunc ,f.escolaridad ,f.habita_en ,f.anios_habita,
           f.nombre_prop ,f.imp_hipo_renta ,f.actividadogiro ,f.numeroife ,f.numerotutor ,
           f.numeroconyuge ,f.string1 ,f.string2 ,f.numeric1 ,f.numeric2 ,f.money1 ,f.date1, c.rfc_alterno
      INTO vstatus_cte ,vsucursal ,vejecutivo ,vtpo_persona ,
           vtipo_cliente ,vapell_paterno ,vapell_materno ,vnombre1 ,vnombre2 ,
           vrazon_social ,vrfc ,vsector ,vsegmento ,vactividad_princ ,vgrupo ,vsubgrupo ,
           vresidencia ,vfecha_alta ,vapell_casada ,vdistrito ,vnumcte_ref ,vstring1,
           vstring2 ,vnumeric1 ,vnumeric2 ,vmoney1 ,vdate1 ,vpuesto_ppes,
           vfamiliar_ppes ,vactividad_esp ,vejecut_autoriza,
           vpffecha_nac  ,vpflugar_nac  ,vpfnacionalidad  ,vpfno_fm3  ,vpfestado_civil,
           vpfregim_matrimonio ,vpfprofesion  ,vpfsexo  ,vpfcurp  ,vpfcodidentifi,
           vpfnumidentifi  ,vpfno_imss  ,vpfdependientes  ,vpftutor,
           vpfpfnom_conyuge   ,vpfseguro_defunc ,vpfescolaridad ,vpfhabita_en ,vpfanios_habita,
           vpfnombre_prop ,vpfimp_hipo_renta ,vpfactividadogiro ,vpfnumeroife ,vpfnumerotutor ,
           vpfnumeroconyuge ,vpfstring1 ,vpfstring2 ,vpfnumeric1 ,vpfnumeric2 ,vpfmoney1 ,vpfdate1, vrfc_alterno
      FROM "informix".si_cliente c,
     outer "informix".si_ctepf f
     WHERE c.numcte = pnumcte 
       and c.empresa = pempresa 
       and c.numcte = f.numcte;
       
		select nvl(correo_elec, ' ')
		into vpfemail
		from "informix".si_correos
		where empresa = '001'
		and numcte = pnumcte
		and status_correo = 'A'
		and secuencia in 
		(select max(secuencia)
		from si_correos
		where  empresa = '001' and 
		numcte = pnumcte
		and status_correo = 'A');
       
    IF vpfemail is null THEN
        LET vpfemail = ' ';
    END IF;

    if vtpo_persona = " " or vtpo_persona is null then
        let vcodret = "800";
        RETURN  vcodret ,vstatus_cte ,vsucursal ,vejecutivo ,vtpo_persona ,
                vtipo_cliente ,vapell_paterno ,vapell_materno ,vnombre1 ,vnombre2 ,
                vrazon_social ,vrfc ,vsector ,vsegmento ,vactividad_princ ,vgrupo ,vsubgrupo ,
                vresidencia ,vfecha_alta ,vapell_casada ,vdistrito ,vnumcte_ref ,vstring1,
                vstring2 ,vnumeric1 ,vnumeric2 ,vmoney1 ,vdate1 ,vpuesto_ppes,
                vfamiliar_ppes ,vactividad_esp ,vejecut_autoriza,
                vpffecha_nac  ,vpflugar_nac  ,vpfnacionalidad  ,vpfno_fm3  ,vpfestado_civil,
                vpfregim_matrimonio ,vpfprofesion  ,vpfsexo  ,vpfcurp  ,vpfcodidentifi,
                vpfnumidentifi  ,vpfno_imss  ,vpfdependientes  ,vpftutor  ,vpfemail,
                vpfpfnom_conyuge   ,vpfseguro_defunc ,vpfescolaridad ,vpfhabita_en ,vpfanios_habita,
                vpfnombre_prop ,vpfimp_hipo_renta ,vpfactividadogiro ,vpfnumeroife ,vpfnumerotutor ,
                vpfnumeroconyuge ,vpfstring1 ,vpfstring2 ,vpfnumeric1 ,vpfnumeric2 ,vpfmoney1 ,vpfdate1;
    else
        select es_fisica 
          into vesfisica 
          from bdinteg:"informix".si_tipper
         where tpo_persona = vtpo_persona;
         
        if vesfisica <> "S" then
            let vapell_paterno = " ";
            let vapell_materno = " ";
            let vnombre1 = " ";
            let vnombre2 = " ";
			select descripcion 
			  into vdescripcion 
			  from bdinteg:"informix".si_ctepm, bdinteg:"informix".si_sufijos 
			 where numcte = pnumcte
			   and codigo = sufijo;
            let vrazon_social = trim(vrazon_social)||" "||trim(vdescripcion);			   
        else
            let vrazon_social = " ";
        end if;

        IF vrfc_alterno is not null and vrfc_alterno <> "" THEN
            LET vrfc = vrfc_alterno;
        END IF;	

        RETURN  vcodret  ,vstatus_cte ,vsucursal ,vejecutivo ,vtpo_persona ,
                vtipo_cliente ,vapell_paterno ,vapell_materno ,vnombre1 ,vnombre2 ,
                vrazon_social ,vrfc ,vsector ,vsegmento ,vactividad_princ ,vgrupo ,vsubgrupo ,
                vresidencia ,vfecha_alta ,vapell_casada ,vdistrito ,vnumcte_ref ,vstring1,
                vstring2 ,vnumeric1 ,vnumeric2 ,vmoney1 ,vdate1 ,vpuesto_ppes,
                vfamiliar_ppes ,vactividad_esp ,vejecut_autoriza,
                vpffecha_nac  ,vpflugar_nac  ,vpfnacionalidad  ,vpfno_fm3  ,vpfestado_civil,
                vpfregim_matrimonio ,vpfprofesion  ,vpfsexo  ,vpfcurp  ,vpfcodidentifi,
                vpfnumidentifi  ,vpfno_imss  ,vpfdependientes  ,vpftutor  ,vpfemail,
                vpfpfnom_conyuge   ,vpfseguro_defunc ,vpfescolaridad ,vpfhabita_en ,vpfanios_habita,
                vpfnombre_prop ,vpfimp_hipo_renta ,vpfactividadogiro ,vpfnumeroife ,vpfnumerotutor ,
                vpfnumeroconyuge ,vpfstring1 ,vpfstring2 ,vpfnumeric1 ,vpfnumeric2 ,vpfmoney1 ,vpfdate1;
    end if;

    end
    
end procedure
 
DOCUMENT
"MODIFICO : Daniel Zambada",
"FECHA : 27/octubre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".conscteppesfamilia(pempresa char(3),
                           pnumcte char(20))

       returning 	char(5), char(3), char(20), smallint, char(20),char(60), char(3), char(8), date;

define vcodret char(5);
define vciclo smallint;
define vsqlerr integer;

define vempresa char(3);
define vnumcte char(20);
define vsecuencia smallint;
define vnumctefamiliar  char(20);
define vnombrefamiliar  char(60);
define vparentesco char(3);
define vuser_insert 	char(8);
define vfecha_insert	date;



let vciclo = 0;                        
let vcodret = "000";
let  vsqlerr = 0;

let vempresa = "";
let vnumcte = "";
let vsecuencia = 0;
let vnumctefamiliar  = "";
let vnombrefamiliar  = "";
let vparentesco = "";
let vuser_insert = "";
let vfecha_insert = "";




begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret, vempresa, vnumcte, vsecuencia , vnumctefamiliar, vnombrefamiliar, vparentesco, vuser_insert, vfecha_insert;

      end if;
   end exception;

SET LOCK MODE TO WAIT 3;
SET ISOLATION  TO DIRTY READ;

   foreach
   
		SELECT empresa, numcte, secuencia, numctefamiliar, nombrefamiliar, parentesco, usuario_insert, fecha_insert 
		INTO vempresa, vnumcte, vsecuencia, vnumctefamiliar, vnombrefamiliar, vparentesco, vuser_insert, vfecha_insert	 	
		FROM si_ppefamilia 
		WHERE numcte = pnumcte 
		order by secuencia
        
         

      return    vcodret, vempresa, vnumcte, vsecuencia, vnumctefamiliar, vnombrefamiliar, vparentesco, vuser_insert, vfecha_insert with resume;

   end foreach;
      
end
end procedure
;