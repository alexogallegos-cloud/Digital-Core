CREATE PROCEDURE "informix".sp_obtclavetarjeta(Tipot CHAR(1), pBin CHAR(6),pSubBin CHAR(2), pCodProdCta CHAR(4), pOperacion CHAR(35), pMigracionVisaActiva CHAR(1))
   RETURNING CHAR(5), CHAR(6), CHAR(3), CHAR(3);
      
   DEFINE cCodRet             CHAR(5);
   DEFINE iSqlErr             INTEGER;
   DEFINE cCodBin             CHAR(6);
   DEFINE cCodProdTar            CHAR(3);
   DEFINE cClave            CHAR(3);


   DEFINE cCodProdPlat          CHAR(4);   
   DEFINE cCodProdORO           CHAR(4);
   DEFINE cSubBinOroN           CHAR(2);
   DEFINE cSubBinPlat          CHAR(2);
   DEFINE cSubBinOroI           CHAR(2);
   DEFINE cClaTipoPlat          CHAR(2);  
   DEFINE cClaTipoOroN          CHAR(2);       
   DEFINE cClaTipoOroI          CHAR(2);   
   DEFINE cClaveOroN            CHAR(3);       
   DEFINE cClaveOroI            CHAR(3);  

   LET cCodRet        ='00000';   
   LET cCodBin        ='000000';
   LET cCodProdTar       ='000';
   LET cClave       ='000';


   LET cCodProdPlat   = '7000';
   LET cCodProdORO    = '8100';
   LET cSubBinOroN    = '05';
   LET cSubBinPlat    = '06';
   LET cSubBinOroI    = '08';
   LET cClaTipoPlat   = '74';
   LET cClaTipoOroN   = '73';
   LET cClaTipoOroI   = '75';
   LET cClaveOroN     = '100';  
   LET cClaveOroI     = '104';  
   
BEGIN
                ON EXCEPTION SET iSqlErr
                      IF iSqlErr <> 0 THEN
                         LET cCodRet = iSqlErr;
                                                               
                         RETURN cCodRet, cCodBin, cCodProdTar, cClave;
                      END IF;
                END EXCEPTION;

                --SET DEBUG FILE TO '/tmp/sp_obtclavetarjeta.out';
	            --TRACE ON;
                
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;
				
				IF pOperacion <> 'Solicitud de Tarjeta Personalizada' THEN

                    IF pMigracionVisaActiva = '1' THEN
                        ----------------------------------------------------------------------------------------------------------------
                        ----------------------------RQM MIGRACIÃN TDC ORO Y PLATINUM MASTERCARD A VISA
                        SELECT b.bin, b.codproductotarjeta, b.clave
                        INTO cCodBin, cCodProdTar, cClave
                        FROM intercard:binproducto a
                        INNER JOIN intercard:Tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
                        WHERE a.bin = pBin 
                        AND a.producto= pSubBin  
                        AND a.codprodcta = pCodProdCta
                        AND b.consecutivo = (
                            CASE 
                                WHEN pCodProdCta = cCodProdPlat AND pSubBin = cSubBinPlat THEN (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin AND  clave_tipotarjeta = cClaTipoPlat)
                                WHEN pCodProdCta = cCodProdORO  AND pSubBin = cSubBinOroI THEN (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin AND  clave_tipotarjeta = cClaTipoOroI) 
                                WHEN pCodProdCta = cCodProdORO  AND pSubBin = cSubBinOroN THEN (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin AND  clave_tipotarjeta = cClaTipoOroN)
                                ELSE                                     (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin)
                            END
                            )           
                        AND b.clave =(
                            CASE  
                                WHEN pCodProdCta = cCodProdORO AND pSubBin = cSubBinOroI THEN cClaveOroI
                                WHEN pCodProdCta = cCodProdORO AND pSubBin = cSubBinOroN THEN cClaveOroN
                                ELSE b.clave 
                            END
                        );
                        ----------------------------------------------------------------------------------------------------------------
                    ELSE
                        -- RQM MIGRACION VISA APAGADA
                        SELECT b.bin, b.codproductotarjeta, clave  
                        INTO cCodBin, cCodProdTar, cClave
                        FROM intercard:binproducto a
                        INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
                        WHERE a.bin = pBin 
                        AND a.producto= pSubBin 
                        AND a.codprodcta = pCodProdCta
                        AND consecutivo = (SELECT max(consecutivo) FROM intercard:tipotarjeta WHERE bin = pBin);

                    END IF;

                ELSE
					IF pCodProdCta NOT IN (cCodProdPlat,cCodProdORO) THEN
						SELECT b.bin, b.codproductotarjeta, clave  
						INTO cCodBin, cCodProdTar, cClave
						FROM intercard:binproducto a
						INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
						WHERE a.bin = pBin 
						AND a.producto= pSubBin 
						AND a.codprodcta = pCodProdCta
						AND consecutivo = (SELECT max(consecutivo) FROM intercard:tipotarjeta WHERE bin = pBin AND descripcion LIKE 'PERSONALIZADO PREDISE%') ;
					ELSE

                        IF pMigracionVisaActiva = '1' THEN
                            ----------------------------RQM MIGRACIÃN TDC ORO Y PLATINUM MASTERCARD A VISA
                            SELECT b.bin, b.codproductotarjeta, b.clave
                            INTO cCodBin, cCodProdTar, cClave
                            FROM intercard:binproducto a
                            INNER JOIN intercard:Tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
                            WHERE a.bin = pBin 
                            AND a.producto= pSubBin  
                            AND a.codprodcta = pCodProdCta
                            AND b.consecutivo = (
                                CASE 
                                    WHEN pCodProdCta = cCodProdPlat AND pSubBin = cSubBinPlat THEN (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin AND  clave_tipotarjeta = cClaTipoPlat)
                                    WHEN pCodProdCta = cCodProdORO  AND pSubBin = cSubBinOroI THEN (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin AND  clave_tipotarjeta = cClaTipoOroI) 
                                    WHEN pCodProdCta = cCodProdORO  AND pSubBin = cSubBinOroN THEN (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin AND  clave_tipotarjeta = cClaTipoOroN)
                                    ELSE                                     (SELECT max(consecutivo) FROM intercard:Tipotarjeta WHERE bin = pBin)
                                END
                                )           
                            AND b.clave =(
                                CASE  
                                    WHEN pCodProdCta = cCodProdORO AND pSubBin = cSubBinOroI THEN cClaveOroI
                                    WHEN pCodProdCta = cCodProdORO AND pSubBin = cSubBinOroN THEN cClaveOroN
                                    ELSE b.clave 
                                END
                                );
                             ----------------------------------------------------------------------------------------------------------------
                        ELSE 
                            -- RQM MIGRACION VISA APAGADA               
                            SELECT b.bin, b.codproductotarjeta, clave  
                            INTO cCodBin, cCodProdTar, cClave
                            FROM intercard:binproducto a
                            INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
                            WHERE a.bin = pBin 
                            AND a.producto= pSubBin 
                            AND a.codprodcta = pCodProdCta
                            AND consecutivo = (SELECT max(consecutivo) FROM intercard:tipotarjeta WHERE bin = pBin);

                        END IF;

					END IF;
				END IF;
        

           IF cCodBin IS NULL or cCodProdTar IS NULL OR cClave IS NULL THEN
                      LET  cCodRet = '00001';
           END IF;

           RETURN cCodRet, cCodBin, cCodProdTar, cClave;
END;
END PROCEDURE;