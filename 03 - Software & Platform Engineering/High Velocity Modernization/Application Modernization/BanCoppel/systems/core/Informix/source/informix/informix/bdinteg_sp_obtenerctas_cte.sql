CREATE PROCEDURE "informix".sp_obtenerctas_cte(pEmpresa CHAR(3),
									 pNumCte CHAR(20),
									 pCuenta CHAR(20),
									 pTarjeta CHAR(20),
									 pTipoCuenta INTEGER)	
--DATOS A REGRESAR---
RETURNING CHAR(6)   AS Retorno,  
		  CHAR(20)  AS Cuenta;
		  
	-- DEFINICION DE VARIABLES
	DEFINE cCod_ret      	 CHAR(6);	
    DEFINE cNumCte      	 CHAR(20);	
    DEFINE cCuenta      	 CHAR(20); 
    DEFINE cStatus      	 CHAR(20);
	DEFINE cTarjeta      	 CHAR(20);	
	DEFINE iSqlErr      	 INTEGER;	

	--INICIALIZACION DE VARIABLES
	LET cCod_ret     	  = "000000";		
	LET cNumCte    	 	  = "";    
    LET cCuenta      	  = "";	
    LET cStatus      	  = "";
	LET cTarjeta     	  = "";	
	LET iSqlErr      	  = 0;	

BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
			    LET cCod_ret = iSqlErr;
				
				RETURN cCod_ret,cCuenta;	
			END IF;
		END EXCEPTION;
		
	--SET DEBUG FILE TO '/tmp/Sp_obtenerctas_cte.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- INICIO DEL PROCEDIMIENTO
	IF NVL(pEmpresa,'') = '' THEN
			LET cCod_ret = '00001';			 
			RETURN cCod_ret,cCuenta;
		ELIF NVL(pNumCte,'') = '' AND (NVL(pCuenta,'') = '' AND NVL(pTarjeta,'') = '') THEN
			LET cCod_ret = '00001';			
			RETURN cCod_ret,cCuenta;		
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
				END IF;
				
			ELIF pTarjeta <> '' THEN
			
				SELECT numcte,cuenta
				INTO cNumCte,cCuenta 
				FROM bdicheq:"informix".sc_tarjeta 
				WHERE empresa = "001"
				AND num_tarjeta = pTarjeta
				AND status_tar = "A";
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					SELECT numcte,num_credito 
					INTO cNumCte,cCuenta 
					FROM bdicred:"informix".sd_tarjeta 
					WHERE num_tarjeta = pTarjeta
					AND status_tar in ('A','I','C');
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
						LET cCod_ret = '00100';						
						RETURN cCod_ret,cCuenta;
					END IF;
				END IF;
				
			ELIF pNumCte <> '' THEN
				LET cNumCte = pNumCte;
			END IF;
			
			SELECT numcte 
			INTO cNumCte 
			FROM bdinteg:"informix".si_cliente 
			WHERE numcte = cNumCte;

			IF cNumCte IS NULL THEN
				LET cCod_ret = "000003";				
				RETURN cCod_ret,cCuenta;
			END IF;
			
			IF pTipoCuenta = "1" THEN
			-- *****************************************************************
			-- Extrae la informacion del Sistema de Cheques
			-- *****************************************************************
				FOREACH
					SELECT DISTINCT	mc.cuenta INTO cCuenta FROM bdicheq:"informix".sc_maechq mc						
					WHERE mc.num_cte = cNumCte AND mc.empresa = pEmpresa AND mc.status_cta IN ('1','3','4','5')					
					ORDER BY cuenta					

					RETURN cCod_ret, NVL(cCuenta,"") WITH RESUME;					
				END FOREACH;
							
			ELIF pTipoCuenta = "2" THEN											
				-- *********************************************************************
				-- Extrae la informacion del Sistema de Credito
				-- *********************************************************************
				
				--FOREACH
				--	SELECT DISTINCT ss.num_solicitud INTO cCuenta FROM bdisolic: ss_solicitudes ss					  
				--	WHERE numcte = cNumCte AND ss.status_solicitud = 'AT' ORDER BY 1
									
				--	RETURN cCod_ret, NVL(cCuenta,"")WITH RESUME;					
				--END FOREACH;
			
				FOREACH
					/*SELECT DISTINCT mc.num_credito INTO cCuenta	FROM bdicred:"informix".sd_maecred mc
					WHERE numcte = cNumCte AND mc.status_cred = 'AA' 
					AND num_producto in ('6001','6600','7000','8100')
					ORDER BY 1	*/
                    --IFRS Se contempla nuevo estatus vigente por Etapas		
                    SELECT DISTINCT mc.num_credito, mc.status_cred 
					INTO cCuenta, cStatus 
					FROM bdicred:"informix".sd_maecred mc
					INNER JOIN bdicred:sd_maesdos dos ON (mc.num_credito = dos.num_credito)
					WHERE numcte = cNumCte 
					AND mc.status_cred IN ('AA','E1')  
					AND (dos.monto_vencido + dos.mto_venc_trasp) = 0
					--WHERE numcte = cNumCte AND mc.status_cred = 'AA' 
					AND num_producto in ('6001','6600','7000','8100','8500')
					ORDER BY 1	                  
				
					RETURN cCod_ret,NVL(cCuenta,"") WITH RESUME;					
				END FOREACH;	

        ELIF pTipoCuenta = "3" THEN
                SELECT numcte,cuenta
				INTO cNumCte,cCuenta 
				FROM bdicheq:"informix".sc_tarjeta 
				WHERE empresa = "001"
				AND num_tarjeta = pTarjeta;
			--	AND status_tar = "A";
			RETURN cCod_ret,NVL(cCuenta,"") WITH RESUME;	

          
        ElIF pTipoCuenta = "4" THEN
	    SELECT numcte,num_credito 
					INTO cNumCte,cCuenta 
					FROM bdicred:"informix".sd_tarjeta 
					WHERE empresa = "001"
			       	AND num_tarjeta = pTarjeta;
			--      	AND status_tar = "A";
	RETURN cCod_ret,NVL(cCuenta,"") WITH RESUME;	



        END IF;	
		END IF;	



	
	END
END PROCEDURE             
DOCUMENT
"DESCRIPCION: Reaaliza consulta de Cliente para regresar la informaciÃ³n de sus cuentas de cheques, crÃ©ditos",
"Folio: 98",
"Autor: 95419888 Elmer LÃ³pez Valenzuela",
"Proyecto Tarjetas Personalizadas: ",
"Fecha: 05-10-2016",
"BD:bdinteg";

CREATE PROCEDURE "informix".sp_obtenerctas_cte3(pEmpresa CHAR(3),
                                                                         pNumCte CHAR(20),
                                                                         pCuenta CHAR(20),
                                                                         pTarjeta CHAR(20),
                                                                         pTipoCuenta INTEGER)
--DATOS A REGRESAR---
RETURNING CHAR(6)   AS Retorno,
                  CHAR(20)  AS Cuenta,
                  CHAR (4) AS producto,
		  CHAR(40) AS Nombreprod,
	          CHAR (20) as numtar,
                  DECIMAL(14,2) as limitecred;

        -- DEFINICION DE VARIABLES
        DEFINE cCod_ret          CHAR(6);
    DEFINE cNumCte               CHAR(20);
    DEFINE cCuenta               CHAR(20);
    DEFINE cStatus               CHAR(20);
        DEFINE cTarjeta          CHAR(20);
        DEFINE iSqlErr           INTEGER;
        DEFINE vProd             CHAR(4);
        DEFINE vNombprod         CHAR (40);
        DEFINE vNumtarjeta       CHAR(20);
	DEFINE vLimiteaut        DECIMAL(14,2);


        --INICIALIZACION DE VARIABLES
        LET cCod_ret              = "000000";
        LET cNumCte               = "";
    LET cCuenta           = "";
    LET cStatus           = "";
        LET cTarjeta              = "";
        LET iSqlErr               = 0;
        LET vProd ='';
        LET vNombprod='';
        LET vNumtarjeta='';
        LET vLimiteaut= 0;

BEGIN
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                            LET cCod_ret = iSqlErr;

                                RETURN cCod_ret,cCuenta,vProd,vNombprod,vNumtarjeta,vLimiteaut;
                        END IF;
                END EXCEPTION;

        --SET DEBUG FILE TO '/tmp/Sp_obtenerctas_cte.out';
        --TRACE ON;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        -- INICIO DEL PROCEDIMIENTO
        IF NVL(pEmpresa,'') = '' THEN
                        LET cCod_ret = '00001';
                        RETURN cCod_ret,cCuenta,vProd,vNombprod,vNumtarjeta,vLimiteaut;
                ELIF NVL(pNumCte,'') = '' AND (NVL(pCuenta,'') = '' AND NVL(pTarjeta,'') = '') THEN
                        LET cCod_ret = '00001';
                        RETURN cCod_ret,cCuenta,vProd,vNombprod,vNumtarjeta,vLimiteaut;
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
                                                RETURN cCod_ret,cCuenta,vProd,vNombprod,vNumtarjeta,vLimiteaut;
                                        END IF;
                                END IF;

                        ELIF pNumCte <> '' THEN
                                LET cNumCte = pNumCte;
                        END IF;

                        SELECT numcte
                        INTO cNumCte
                        FROM bdinteg:"informix".si_cliente
                        WHERE numcte = cNumCte;

                        IF cNumCte IS NULL THEN
                                LET cCod_ret = "000003";
                             --   RETURN cCod_ret,cCuenta,vProd,vNombprod;
                                RETURN cCod_ret,cCuenta,vProd,vNombprod,vNumtarjeta,vLimiteaut;
                        END IF;
                        IF pTipoCuenta = "1" THEN
			-- *****************************************************************
			-- Extrae la informacion del Sistema de Cheques
			-- *****************************************************************
                            FOREACH
                                SELECT DISTINCT	mc.cuenta INTO cCuenta FROM bdicheq:"informix".sc_maechq mc						
                                WHERE mc.num_cte = cNumCte AND mc.empresa = pEmpresa AND mc.status_cta IN ('1','3','4','5')					
                                ORDER BY cuenta				

                                 select num_tarjeta
                                into vNumtarjeta
                                from bdicheq:"informix".sc_tarjeta
                                where numcte=cNumCte 
                                AND cuenta=pCuenta
                                AND status_tar='A';


	

                                RETURN cCod_ret,NVL(cCuenta,""),NVL(vProd,""),NVL(vNombprod,""),NVL(vNumtarjeta,""),NVL(vLimiteaut,0) WITH RESUME;
                        END FOREACH;

                        ELIF pTipoCuenta = "2" THEN
                                -- *********************************************************************
                                -- Extrae la informacion del Sistema de Credito
                                -- *********************************************************************

                                --FOREACH
                                --      SELECT DISTINCT ss.num_solicitud INTO cCuenta FROM bdisolic: ss_solicitudes ss
                                --      WHERE numcte = cNumCte AND ss.status_solicitud = 'AT' ORDER BY 1

                                --      RETURN cCod_ret, NVL(cCuenta,"")WITH RESUME;
                                --END FOREACH;

                                FOREACH
                                        /*SELECT DISTINCT mc.num_credito INTO cCuenta   FROM bdicred:"informix".sd_maecred mc
                                        WHERE numcte = cNumCte AND mc.status_cred = 'AA'
                                        AND num_producto in ('6001','6600','7000','8100','8500')
                                        ORDER BY 1      */
						--IFRS Se contempla nuevo estatus vigente por Etapas	
										SELECT DISTINCT mc.num_credito, mc.status_cred,num_producto INTO cCuenta, cStatus, vProd 
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
				        WHERE num_producto=vProd;
 
                                        SELECT num_tarjeta,limite_aut
					INTO vNumtarjeta, vLimiteaut
	                                FROM  bdicred:"informix".sd_tarjeta 
	                                WHERE num_credito=cCuenta
	                                AND status_tar in ('A')
									AND tipo_tarjeta ='T'; 
                                        
	                               RETURN cCod_ret,NVL(cCuenta,""),NVL(vProd,""),NVL(vNombprod,""),NVL(vNumtarjeta,""),NVL(vLimiteaut,0) WITH RESUME;

                                END FOREACH;




        END IF;
                END IF;




        END;
END PROCEDURE;