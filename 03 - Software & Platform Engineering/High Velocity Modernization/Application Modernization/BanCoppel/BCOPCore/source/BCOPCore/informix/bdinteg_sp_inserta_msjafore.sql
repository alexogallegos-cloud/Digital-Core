CREATE PROCEDURE "informix".sp_inserta_msjafore(pNumcte CHAR(20), pCuenta_tarjeta CHAR(20), pSucursal CHAR(4), pDebito CHAR(8))

RETURNING CHAR(5)  AS cCodRet;

--Definicion de Variables
DEFINE cCodRet			CHAR(5);
DEFINE iSqlErr 			INTEGER;

DEFINE cCurp			CHAR(20);
DEFINE cApell_paterno	CHAR(26);
DEFINE cApell_materno	CHAR(26);
DEFINE cNombre1			CHAR(26);
DEFINE cNombre2			CHAR(26);
DEFINE cFecha_nac		DATE;
DEFINE cLugar_nac		CHAR(2);
DEFINE cSexo			CHAR(1);
DEFINE cNroCta_tarj		CHAR(20);

--Inicializacion de Variables
LET cCodRet    		= '00000';
LET iSqlErr 		= 0;

LET cCurp			= '';
LET cApell_paterno	= '';
LET cApell_materno	= '';
LET cNombre1		= '';
LET cNombre2		= '';
LET cFecha_nac		= NULL;
LET cLugar_nac		= '';
LET cSexo			= '';
LET cNroCta_tarj 	= '';


--SET DEBUG FILE TO '/ifxsif01/LIP/sp_inserta_msjafore.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	--Sucursal y empleado
	IF ((pSucursal IS NOT NULL AND pSucursal <> '') AND (pDebito IS NOT NULL AND pDebito <> '')) THEN


		--Numero de cliente
		IF (pNumcte IS NOT NULL AND pNumcte <> '') THEN
		
			SELECT pf.curp, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, pf.fecha_nac, pf.lugar_nac, pf.sexo
			INTO cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo
			FROM bdinteg:si_cliente cte
					INNER JOIN bdinteg:si_ctepf pf ON cte.numcte = pf.numcte
			WHERE cte.numcte = pNumcte;


			INSERT INTO bdinteg:si_ws_mensajeafore(numcte, ejecutivo, sucursal, curp, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, lugar_nac, sexo, fecha_insert)
			VALUES(pNumcte, pDebito, pSucursal, cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo, CURRENT);
					
			RETURN cCodRet;
		
		END IF;
		
		--Numero de cuenta o tarjeta
		IF (pCuenta_tarjeta IS NOT NULL AND pCuenta_tarjeta <> '') THEN
			--Tarjeta
			IF(LENGTH(TRIM(pCuenta_tarjeta)) = 16) THEN
				
				
					--debito
					SELECT FIRST 1 numcte
					INTO pNumcte
					FROM bdicheq:sc_tarjeta 
					WHERE num_tarjeta = pCuenta_tarjeta;
					
					IF(pNumcte IS NOT NULL AND pNumcte <> '') THEN
					
						SELECT pf.curp, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, pf.fecha_nac, pf.lugar_nac, pf.sexo
						INTO cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo
						FROM bdinteg:si_cliente cte
								INNER JOIN bdinteg:si_ctepf pf ON cte.numcte = pf.numcte
						WHERE cte.numcte = pNumcte;
						

						INSERT INTO bdinteg:si_ws_mensajeafore(numcte, ejecutivo, sucursal, curp, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, lugar_nac, sexo, fecha_insert)
						VALUES(pNumcte, pDebito, pSucursal, cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo, CURRENT);
								
						RETURN cCodRet;
					
					END IF;
				
				
					--credito
					SELECT FIRST 1 numcte
					INTO pNumcte
					FROM bdicred:sd_tarjeta 
					WHERE num_tarjeta = pCuenta_tarjeta;
					
					IF(pNumcte IS NOT NULL AND pNumcte <> '') THEN
					
						SELECT pf.curp, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, pf.fecha_nac, pf.lugar_nac, pf.sexo
						INTO cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo
						FROM bdinteg:si_cliente cte
								INNER JOIN bdinteg:si_ctepf pf ON cte.numcte = pf.numcte
						WHERE cte.numcte = pNumcte;
						
				
						INSERT INTO bdinteg:si_ws_mensajeafore(numcte, ejecutivo, sucursal, curp, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, lugar_nac, sexo, fecha_insert)
						VALUES(pNumcte, pDebito, pSucursal, cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo, CURRENT);
							
						RETURN cCodRet;
				
					END IF;
				
			
			--Cuenta
			ELSE
			
				
					--debito
					SELECT FIRST 1 num_cte
					INTO pNumcte
					FROM bdicheq:sc_maechq 
					WHERE cuenta = pCuenta_tarjeta;
					
					IF(pNumcte IS NOT NULL AND pNumcte <> '') THEN
					
						SELECT pf.curp, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, pf.fecha_nac, pf.lugar_nac, pf.sexo
						INTO cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo
						FROM bdinteg:si_cliente cte
								INNER JOIN bdinteg:si_ctepf pf ON cte.numcte = pf.numcte
						WHERE cte.numcte = pNumcte;
						

						INSERT INTO bdinteg:si_ws_mensajeafore(numcte, ejecutivo, sucursal, curp, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, lugar_nac, sexo, fecha_insert)
						VALUES(pNumcte, pDebito, pSucursal, cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo, CURRENT);
								
						RETURN cCodRet;
					
					END IF;
				
				
					--credito
					SELECT FIRST 1 numcte
					INTO pNumcte
					FROM bdicred:sd_maecred 
					WHERE num_credito = pCuenta_tarjeta;
					
					IF(pNumcte IS NOT NULL AND pNumcte <> '') THEN
					
						SELECT pf.curp, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, pf.fecha_nac, pf.lugar_nac, pf.sexo
						INTO cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo
						FROM bdinteg:si_cliente cte
								INNER JOIN bdinteg:si_ctepf pf ON cte.numcte = pf.numcte
						WHERE cte.numcte = pNumcte;
					
				
						INSERT INTO bdinteg:si_ws_mensajeafore(numcte, ejecutivo, sucursal, curp, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, lugar_nac, sexo, fecha_insert)
						VALUES(pNumcte, pDebito, pSucursal, cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo, CURRENT);
							
						RETURN cCodRet;
					
					END IF;
				
			
			END IF;
			
		
		END IF;

	END IF;

	RETURN cCodRet;
END;

END PROCEDURE;