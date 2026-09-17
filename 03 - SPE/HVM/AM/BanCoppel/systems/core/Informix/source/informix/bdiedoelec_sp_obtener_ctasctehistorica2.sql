CREATE PROCEDURE "informix".sp_obtener_ctasctehistorica2

(
	pEmpresa CHAR(3),
	pNumCte CHAR(20),
	pOpcion INTEGER,
	pultreg SMALLINT
)
	RETURNING CHAR(6) AS cCodRet, CHAR(20) AS cCuenta;

	--DECLARACION DE VARIABLES
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(6);
	DEFINE cCuenta CHAR(20);
	DEFINE iTotalCuentas INTEGER;
	--24/01/2019
	DEFINE cQuery CHAR(1500);
	DEFINE cNumeroProdusctosTarjetaCredito CHAR(100);
	DEFINE cNumProdTarCre CHAR(100);
	--24/01/2019
	
	--INICIALIZACION DE VARIABLES
	LET iSqlErr=0;
	LET cCodRet = "000000";
	LET cCuenta = "";
	LET iTotalCuentas = 0;

	--24/01/2019
	LET cQuery = '';
	LET cNumeroProdusctosTarjetaCredito = "";
	LET cNumProdTarCre = "";
	--24/01/2019	
	
	BEGIN
    ON EXCEPTION SET iSqlErr
	IF 	iSqlErr <> 0 THEN
		LET cCodRet = iSqlErr;
		RETURN cCodRet,cCuenta;
	END IF
END EXCEPTION;

	--SET DEBUG FILE TO "/respaldosbd/claudio/sp_obtener_ctasctehistorica.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF NVL(pEmpresa,"") = "" OR NVL(pNumCte,"") = "" OR NVL(pOpcion,"") = "" THEN -- Valida Parametros Vacios
		LET cCodRet = "000002";
		RETURN cCodRet, cCuenta;
	ELSE
		IF pOpcion = 1 THEN -- Obtiene Cuentas de ColocaciÃ³n
  
-------------------------------------  24/01/2019
  
				SELECT valor 
				INTO cNumeroProdusctosTarjetaCredito
				FROM bdicred:"informix".sd_param WHERE cod_param IN('058');
				LET cNumProdTarCre = TRIM(cNumeroProdusctosTarjetaCredito);
										
                  LET cQuery = "SELECT cuenta"||
								" FROM bdiedoelec:edelec_alta_serv WHERE numcte = '"||(pNumCte)||"'"||
								" AND producto IN ('6011','6300',"||(cNumProdTarCre)||")"||
								" AND empresa = '"||(pEmpresa)||"' "||
								" AND status_serv_elec ='A' ORDER BY cuenta ASC";							
				
						PREPARE stmtId FROM TRIM(cQuery);
						DECLARE custCur CURSOR FOR stmtId;
						OPEN custCur;
						FETCH custCur INTO cCuenta;
						
						LET iTotalCuentas = iTotalCuentas + 1;
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = "000001";
							RETURN cCodRet,NVL(cCuenta,"") WITH RESUME;
						END IF	
										
					WHILE  SQLCODE= 0 --Si encuentra registros el cursor						
										
					
					RETURN cCodRet,NVL(cCuenta,"") WITH RESUME;								
					FETCH custCur INTO cCuenta;	
					END WHILE;
					CLOSE custCur;
					FREE custCur;
					FREE stmtId;	

		ELIF pOpcion = 2 THEN -- Obtiene Cuentas de Captacion

			FOREACH
				SELECT cuenta
				INTO cCuenta
				FROM "informix".edelec_alta_serv
				WHERE numcte = pNumCte
				AND empresa = pEmpresa
				AND status_serv_elec = 'A'
				AND (cuenta like '1%'OR cuenta like '2%')
				ORDER BY cuenta ASC

				LET iTotalCuentas = iTotalCuentas + 1;
					IF iTotalCuentas <= pultreg THEN
					CONTINUE FOREACH;
				END IF
				RETURN cCodRet, NVL(cCuenta,"") WITH RESUME;

			END FOREACH;
		ELIF pOpcion = 3 THEN -- Obtiene Ambas Cuentas (ColocaciÃ³n y Captacion)
		
--------------	24/01/2019			
			SELECT valor 
			INTO cNumeroProdusctosTarjetaCredito
			FROM bdicred:"informix".sd_param WHERE cod_param IN('058');
			LET cNumProdTarCre = TRIM(cNumeroProdusctosTarjetaCredito);
				
			 LET cQuery = "SELECT (CASE WHEN producto = '6011' THEN cuenta"||
							" WHEN producto = '6300' THEN cuenta"||
							" WHEN producto IN("||(cNumProdTarCre)||") THEN cuenta"||
							" WHEN cuenta LIKE '1%' THEN cuenta WHEN cuenta LIKE '2%' THEN cuenta"||
							" END) AS cuenta"||
							" FROM bdiedoelec:edelec_alta_serv"||
							" WHERE numcte = '"||(pNumCte)||"'"||
							" AND empresa = '"||(pEmpresa)||"'"||
							" AND status_serv_elec = 'A' ORDER BY cuenta ASC";
			
			PREPARE stmtId FROM TRIM(cQuery);
			DECLARE custCur CURSOR FOR stmtId;
			OPEN custCur;
			FETCH custCur INTO cCuenta;
			
			LET iTotalCuentas = iTotalCuentas + 1;
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = "000001";
				
				RETURN cCodRet,NVL(cCuenta,"") WITH RESUME;
			END IF
			
			WHILE SQLCODE = 0 --Si encuentra registros el cursor
				RETURN cCodRet,NVL(cCuenta,"") WITH RESUME;
				FETCH custCur INTO cCuenta;
			END WHILE
			
			CLOSE custCur;
			FREE custCur;
			FREE stmtId;
		
		ELSE
			LET cCodRet = '000003';
			RETURN cCodRet, cCuenta;
		END IF;

		IF iTotalCuentas = 0 THEN
			LET cCodRet = '000001';
			RETURN cCodRet, cCuenta;
		END IF;
	END IF;

END;
END PROCEDURE
DOCUMENT
'Folio:531',
'Autor:98681011 Oscar Marquez',
'Fecha:24/01/2019',
'ModificaciÃ³n: Se crea SP para la obtencion de los datos para las opciones 1 (Obtiene Cuentas de ColocaciÃ³n) y 3 (Obtiene Ambas Cuentas (ColocaciÃ³n y Captacion)) para tomar en cuenta tarjetas oro y platino contemplando futuros productos.',
'Solicita:Cutberto Gonzalez',
'BD:bdiedoelec';

CREATE PROCEDURE "informix".sp_del_solic_const (pempresa char(3)) 
    RETURNING CHAR(5) AS v_sCodRet
	
    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);
		
	DEFINE v_numcte 			CHAR(20);
	DEFINE v_cuenta 			CHAR(20);
	DEFINE v_ejercicio		    CHAR(4);
	DEFINE v_fecha_recepcion    DATE;
	DEFINE v_fecha_hoy			DATE;
	
	-- Optimizacion de SPL declaracion
	define vsflagentransaccion 	char(1);
	define viconsecutivo        integer;
	define vicontadorregistros  integer;
	
    --SET DEBUG FILE TO  "sp_del_solic_const.out"; 
    --TRACE ON;
	
	LET v_sCodRet = '000';
	LET v_numcte = ''; 			
	LET v_cuenta = '';
	LET v_ejercicio = '';	
	LET v_fecha_recepcion = TODAY;
	LET v_fecha_hoy = TODAY;
	
	-- Optimizacion de SPL inicializaciÃ³n
	let vsflagentransaccion = '';
	let viconsecutivo = 0;
	let vicontadorregistros = 0; 
	

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;
		
		SELECT fecha_hoy INTO v_fecha_hoy 
			FROM bdinteg:si_fechas 
				WHERE empresa = '001';
		
		let vsflagentransaccion = 'F';
		
		FOREACH cusor1 with hold for
		--FOREACH WITH HOLD 
			SELECT b.numcte,b.cuenta,b.ejercicio 
					INTO v_numcte,v_cuenta,v_ejercicio
				FROM bdiedoelec:edelec_solic_const a
				    join bdiedoelec:edelec_log_solic_const b 
				      on a.numcte = b.numcte and a.cuenta = b.cuenta
					WHERE 	a.fecha_vigencia < v_fecha_hoy
							AND NOT EXISTS ( SELECT 1 FROM bdiedoelec:edelec_log_solic_const c 
													WHERE 	c.empresa = pempresa
															AND c.numcte = a. numcte 
															AND c.ejercicio = a.ejercicio 
															AND c.status_envio_edocta = 'AE')
				GROUP BY b.numcte,b.cuenta,b.ejercicio 
				ORDER BY ejercicio ASC
			
			/*SELECT b.numcte,b.cuenta,b.ejercicio 
					INTO v_numcte,v_cuenta,v_ejercicio
				FROM bdiedoelec:edelec_solic_const a, bdiedoelec:edelec_log_solic_const b 
					WHERE 	a. numcte = b. numcte
							AND a.cuenta = b.cuenta
							AND a. fecha_vigencia < v_fecha_hoy
							AND NOT EXISTS ( SELECT 1 FROM bdiedoelec:edelec_log_solic_const c 
													WHERE 	c.empresa = pempresa
															AND c.numcte = a. numcte 
															AND c.ejercicio = a.ejercicio 
															AND c.status_envio_edocta = 'AE')
				GROUP BY b.numcte,b.cuenta,b.ejercicio 
				ORDER BY ejercicio ASC*/
				
			if (vsflagentransaccion = 'F') then 
				begin work;
				let vsflagentransaccion = 'V';
			end if;
			
			INSERT INTO bdiedoelec:edelec_solic_const_ne (empresa,numcte,cuenta,ejercicio,fecha_recepcion,fecha_modificacion)
				  VALUES (pempresa,v_numcte,v_cuenta,v_ejercicio,v_fecha_recepcion,TODAY);
			
			DELETE FROM bdiedoelec:edelec_solic_const 
			      WHERE numcte = v_numcte
					AND cuenta = v_cuenta
					AND ejercicio = v_ejercicio;
			
			DELETE FROM bdiedoelec:edelec_log_solic_const
				  WHERE numcte = v_numcte
					AND cuenta = v_cuenta
					AND ejercicio = v_ejercicio;
					
			if (vicontadorregistros = 500) then --verifica si alcanzo el maximo de transacciones por bloque
				commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
				continue foreach;
			end if;
			
		--CONTINUE FOREACH;
		END FOREACH;
		
		if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
			commit work;
			let vsflagentransaccion = 'F';
		end if;	
		
		RETURN v_sCodRet;    
    END
END PROCEDURE;