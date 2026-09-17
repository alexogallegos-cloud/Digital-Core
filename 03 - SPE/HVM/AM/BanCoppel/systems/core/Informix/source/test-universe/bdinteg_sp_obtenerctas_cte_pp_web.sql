CREATE PROCEDURE "informix".sp_obtenerctas_cte_pp_web(pEmpresa CHAR(3),
                                                pNumCte CHAR(20),
                                                pCuenta CHAR(20),
                                                pTarjeta CHAR(20),
                                                pTipoCuenta INTEGER)
--DATOS A REGRESAR---
RETURNING CHAR(5)   AS Retorno,
          CHAR(20)  AS Cuenta,
          CHAR(4)   AS producto,
		  CHAR(40)  AS Nombreprod,
	      CHAR(20)  AS numtar,
          DECIMAL(14,2) as limitecred,
		  CHAR(20)	AS clabeInter;

-- DEFINICION DE VARIABLES
    DEFINE cCod_ret          CHAR(5);
    DEFINE cNumCte           CHAR(20);
    DEFINE cCuenta           CHAR(20);
	DEFINE cCLABE            CHAR(20);
    DEFINE cStatus           CHAR(20);
    DEFINE cTarjeta          CHAR(20);
    DEFINE iSqlErr           INTEGER;
    DEFINE vProd             CHAR(4);
    DEFINE vNombprod         CHAR (40);
    DEFINE vNumtarjeta       CHAR(20);
	DEFINE vLimiteaut        DECIMAL(14,2);


--INICIALIZACION DE VARIABLES
    LET cCod_ret          = "00000";
    LET cNumCte           = "";
    LET cCuenta           = "";
	LET cCLABE            = "";
    LET cStatus           = "";
    LET cTarjeta          = "";
    LET iSqlErr           = 0;
    LET vProd 			  = '';
    LET vNombprod         = '';
    LET vNumtarjeta       = '';
    LET vLimiteaut        = 0;

	BEGIN
        ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCod_ret = iSqlErr;
					RETURN cCod_ret,cCuenta,vProd,vNombprod,vNumtarjeta,vLimiteaut,cCLABE;
                END IF;
        END EXCEPTION;

        --SET DEBUG FILE TO '/tmp/sp_obtenerctas_cte_pp_web.out';
        --TRACE ON;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        -- INICIO DEL PROCEDIMIENTO
        IF NVL(pEmpresa,'') = '' THEN
            LET cCod_ret = '00001';
            RETURN cCod_ret,cCuenta,vProd,vNombprod,vNumtarjeta,vLimiteaut,cCLABE;
        ELIF NVL(pNumCte,'') = '' AND (NVL(pCuenta,'') = '' AND NVL(pTarjeta,'') = '') THEN
			LET cCod_ret = '00001';
			RETURN cCod_ret,cCuenta,vProd,vNombprod,vNumtarjeta,vLimiteaut,cCLABE;
        ELSE
			IF pCuenta <> '' THEN
				
				SELECT num_cte,cuenta
                INTO cNumCte,cCuenta
                FROM bdicheq:"informix".sc_maechq
                WHERE cuenta = pCuenta;

				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					SELECT numcte,num_credito
                    INTO cNumCte,cCuenta
                    FROM bdicred:"informix".sd_maecred
                    WHERE num_credito = pCuenta;

                    IF dbinfo("sqlca.sqlerrd2") = 0 THEN
                        SELECT numcte,num_credito
                        INTO cNumCte,cCuenta
                        FROM bdicred:"informix".sd_maecredcrd
                        WHERE num_credito = pCuenta;
                    END IF;

                END IF;

            ELIF pTarjeta <> '' THEN

                    SELECT numcte,cuenta
                    INTO cNumCte,cCuenta
                    FROM bdicheq:"informix".sc_tarjeta
                    WHERE empresa = "001"
                    AND num_tarjeta = pTarjeta
                    AND status_tar = "A";

					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						SELECT numcte,num_credito,num_tarjeta,limite_aut
						INTO cNumCte,cCuenta,vNumtarjeta,vLimiteaut
                        FROM bdicred:"informix".sd_tarjeta
                        WHERE num_tarjeta = pTarjeta
                        AND status_tar in ('A');

						IF dbinfo("sqlca.sqlerrd2") = 0 THEN
							LET cCod_ret = '00100';
                            RETURN cCod_ret,cCuenta,vProd,vNombprod,vNumtarjeta,vLimiteaut,cCLABE;
                        END IF;
                    END IF;

            ELIF pNumCte <> '' THEN
				LET cNumCte = pNumCte;
            END IF;

            SELECT numcte
            INTO cNumCte
            FROM bdinteg:"informix".si_cliente
            WHERE numcte = pNumCte;

            IF (cNumCte IS NULL AND (pTipoCuenta <> "3" AND pTipoCuenta <> "4")) THEN
				LET cCod_ret = "00003";
                RETURN cCod_ret,cCuenta,vProd,vNombprod,vNumtarjeta,vLimiteaut,cCLABE;
            END IF;
            
            IF pTipoCuenta = "1" THEN
			-- *****************************************************************
			-- Extrae la informacion del Sistema de Cheques
			-- *****************************************************************
                 
				FOREACH
					SELECT DISTINCT	mc.cuenta, mc.cuenta_clabe, mc.producto
					INTO cCuenta, cCLABE, vProd
					FROM bdicheq:"informix".sc_maechq mc						
                    WHERE mc.num_cte = cNumCte 
					AND mc.empresa = pEmpresa 
					AND mc.cuenta = pCuenta 
					AND mc.status_cta IN ('1','3','4','5')					
                    ORDER BY cuenta			

					SELECT nombre 
					INTO vNombprod
					FROM bdicheq:sc_producto 
					WHERE producto = vProd;				

                    SELECT num_tarjeta
                    INTO vNumtarjeta
                    FROM bdicheq:"informix".sc_tarjeta
                    WHERE numcte = cNumCte 
                    AND cuenta = pCuenta
                    AND status_tar = 'A';

					RETURN cCod_ret,NVL(cCuenta,""),NVL(vProd,""),NVL(vNombprod,""),NVL(vNumtarjeta,""),NVL(vLimiteaut,0),NVL(cCLABE,"") WITH RESUME;
                END FOREACH;

            ELIF pTipoCuenta = "2" THEN
            -- *********************************************************************
            -- Extrae la informacion del Sistema de Credito (Tarjeta)
            -- *********************************************************************
				--IFRS Se contempla nuevo estatus vigente por Etapas	
                FOREACH
					SELECT DISTINCT mc.num_credito, mc.status_cred, mc.num_producto, mc.cuenta_clabe
					INTO cCuenta, cStatus, vProd, cCLABE
					FROM bdicred:"informix".sd_maecred mc
					INNER JOIN bdicred:sd_maesdos dos ON (mc.num_credito = dos.num_credito)
					WHERE numcte = cNumCte 
					AND mc.status_cred IN ('AA','E1')  
					AND (dos.monto_vencido + dos.mto_venc_trasp) = 0
                    --WHERE numcte = cNumCte AND mc.status_cred in ('AA')
                    AND num_producto in ('6001','6600','7000','8100','8500')
                    ORDER BY 1
					
					SELECT nombre_prod 
					INTO vNombprod 
					FROM bdicred:"informix".sd_definicion 
				    WHERE num_producto = vProd;
 
                    SELECT num_tarjeta,limite_aut
					INTO vNumtarjeta, vLimiteaut
	                FROM  bdicred:"informix".sd_tarjeta 
	                WHERE num_credito = cCuenta
	                AND status_tar in ('A')
					AND tipo_tarjeta ='T'; 
                                        
	                RETURN cCod_ret,NVL(cCuenta,""),NVL(vProd,""),NVL(vNombprod,""),NVL(vNumtarjeta,""),NVL(vLimiteaut,0),NVL(cCLABE,"") WITH RESUME;

				END FOREACH;
				
			ELIF pTipoCuenta = "3" THEN
            -- *********************************************************************
            -- Extrae la informacion del Sistema de Credito (Prestamos)
            -- *********************************************************************
			    IF pNumCte <> '' THEN
					--IFRS Se contempla nuevo estatus vigente por Etapas	
					FOREACH

						SELECT DISTINCT mc.num_credito, mc.status_cred, mc.num_producto, mc.cuenta_clabe
                        INTO cCuenta, cStatus, vProd, cCLABE
                        FROM bdicred:"informix".sd_maecredcrd mc
						INNER JOIN bdicred:sd_maesdoscrd dos ON (mc.num_credito = dos.num_credito)
						WHERE numcte = cNumCte 
						AND mc.status_cred IN ('AA','E1')  
						AND (dos.monto_vencido + dos.mto_venc_trasp) = 0
						--WHERE numcte = cNumCte AND mc.status_cred in ('AA')
                        AND num_producto in ('6300','6800','7600','7700')

						SELECT nombre_prod 
						INTO vNombprod 
						FROM bdicred:"informix".sd_definicion 
						WHERE num_producto = vProd;
	 
						SELECT num_tarjeta,limite_aut
						INTO vNumtarjeta, vLimiteaut
						FROM  bdicred:"informix".sd_tarjeta 
						WHERE num_credito = cCuenta
						AND status_tar in ('A')
						AND tipo_tarjeta ='T'; 
											
						RETURN cCod_ret,NVL(cCuenta,""),NVL(vProd,""),NVL(vNombprod,""),NVL(vNumtarjeta,""),NVL(vLimiteaut,0),NVL(cCLABE,"") WITH RESUME;
					END FOREACH;

				ELIF pCuenta <> '' THEN
					--IFRS Se contempla nuevo estatus vigente por Etapas	
					FOREACH
						SELECT DISTINCT mc.num_credito, mc.status_cred, mc.num_producto, mc.cuenta_clabe
                        INTO cCuenta, cStatus, vProd, cCLABE
                        FROM bdicred:"informix".sd_maecredcrd mc
						INNER JOIN bdicred:sd_maesdoscrd dos ON (mc.num_credito = dos.num_credito)
						WHERE num_credito = pCuenta 
						AND mc.status_cred IN ('AA','E1')  
						AND (dos.monto_vencido + dos.mto_venc_trasp) = 0
						--WHERE num_credito = pCuenta AND mc.status_cred in ('AA')						
                        AND num_producto in ('6300','6800','7600','7700')

						SELECT nombre_prod 
						INTO vNombprod 
						FROM bdicred:"informix".sd_definicion 
						WHERE num_producto = vProd;
	 
						SELECT num_tarjeta,limite_aut
						INTO vNumtarjeta, vLimiteaut
						FROM  bdicred:"informix".sd_tarjeta 
						WHERE num_credito = cCuenta
						AND status_tar in ('A')
						AND tipo_tarjeta ='T'; 
											
						RETURN cCod_ret,NVL(cCuenta,""),NVL(vProd,""),NVL(vNombprod,""),NVL(vNumtarjeta,""),NVL(vLimiteaut,0),NVL(cCLABE,"") WITH RESUME;

					END FOREACH;
					
				END IF;
                ELIF pTipoCuenta = "4" THEN
            -- *********************************************************************
            -- Extrae la informacion del Sistema de Credito (Prestamos)
            -- *********************************************************************
			    IF pCuenta <> '' THEN
					--IFRS Se contempla nuevo estatus vigente por Etapas	
					FOREACH
						SELECT DISTINCT mc.num_credito, mc.status_cred, mc.num_producto, mc.cuenta_clabe, mc.numcte
						INTO cCuenta, cStatus, vProd, cCLABE, pNumCte
						FROM bdicred:"informix".sd_maecredcrd mc
						INNER JOIN bdicred:sd_maesdoscrd dos ON (mc.num_credito = dos.num_credito)
						WHERE num_credito = pCuenta 
						AND mc.status_cred IN ('AA','E1')  
						AND (dos.monto_vencido + dos.mto_venc_trasp) = 0
						--WHERE num_credito = pCuenta AND mc.status_cred in ('AA')							
						AND num_producto in ('6300','6800','7600','7700')

						SELECT nombre_prod 
						INTO vNombprod 
						FROM bdicred:"informix".sd_definicion 
						WHERE num_producto = vProd;
	 										
						RETURN cCod_ret,NVL(cCuenta,""),NVL(vProd,""),NVL(vNombprod,""),NVL(vNumtarjeta,""),NVL(vLimiteaut,0),NVL(cCLABE,"") WITH RESUME;

					END FOREACH;
					
				END IF;
			END IF;
        END IF;
    END;
END PROCEDURE;