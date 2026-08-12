CREATE PROCEDURE "informix".sp_obtener_ctasctehistorica_web
(
	pEmpresa CHAR(3),
	pNumCte CHAR(20),
	pOpcion INTEGER,
	pultreg SMALLINT
)
	RETURNING CHAR(5) AS cCodRet, CHAR(20) AS cCuenta;

	--DECLARACION DE VARIABLES
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cCuenta CHAR(20);
	DEFINE iTotalCuentas INTEGER;

	--INICIALIZACION DE VARIABLES
	LET iSqlErr=0;
	LET cCodRet = "00000";
	LET cCuenta = "";
	LET iTotalCuentas = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
		IF 	iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCuenta;
		END IF
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO "/home/tmp/jairo/sp_obtener_ctasctehistorica.out";
		--TRACE ON;

		IF NVL(pEmpresa,"") = "" OR NVL(pNumCte,"") = "" OR NVL(pOpcion,"") = "" THEN -- Valida Parametros Vacios
			LET cCodRet = "00002";
			RETURN cCodRet, cCuenta;
		ELSE
			IF pOpcion = 1 THEN -- Obtiene Cuentas de ColocaciÃ³n

				FOREACH
					SELECT cuenta INTO cCuenta
					FROM bdiedoelec:"informix".edelec_alta_serv
					WHERE numcte = pNumCte
					AND producto IN ('6011','6300','6001')
					AND empresa = pEmpresa
					AND status_serv_elec = 'A'
					ORDER BY cuenta ASC

					LET iTotalCuentas = iTotalCuentas + 1;
					
					IF iTotalCuentas <= pultreg THEN
						CONTINUE FOREACH;
					END IF
					
					RETURN cCodRet, NVL(cCuenta,"") WITH RESUME;

				END FOREACH;
			ELIF pOpcion = 2 THEN -- Obtiene Cuentas de Captacion

				FOREACH
					SELECT cuenta
					INTO cCuenta
					FROM bdiedoelec:"informix".edelec_alta_serv
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

				FOREACH
					SELECT (CASE WHEN producto = '6011' THEN cuenta
					WHEN producto = '6300' THEN cuenta
					WHEN producto = '6001' THEN cuenta
					WHEN cuenta LIKE '1%' THEN cuenta WHEN cuenta LIKE '2%' THEN cuenta
					END) AS cuenta
					INTO cCuenta
					FROM bdiedoelec:"informix".edelec_alta_serv
					WHERE numcte = pNumCte
					AND empresa = pEmpresa
					AND status_serv_elec = 'A'
					ORDER BY cuenta ASC

					LET iTotalCuentas = iTotalCuentas + 1;
					IF iTotalCuentas <= pultreg THEN
						CONTINUE FOREACH;
					END IF
					RETURN cCodRet, NVL(cCuenta,"") WITH RESUME;

				END FOREACH;
			ELSE
				LET cCodRet = '00003';
				RETURN cCodRet, cCuenta;
			END IF;

			IF iTotalCuentas = 0 THEN
				LET cCodRet = '00001';
				RETURN cCodRet, cCuenta;
			END IF;
		END IF;
END;
END PROCEDURE
DOCUMENT
'Folio:1602',
'Autor:95975071 Jairo Valdez Gonzalez',
'Fecha:25/04/2014',
'ModificaciÃ³n:Se crea sp para traer el historial de cuentas de los clientes que tengan servicio activo',
'Sustento:12 231 Edo Cta EmisiÃ³n Consulta DisponibilizaciÃ³n y Respaldo OFI_final_07-02-2014.pdf',
'Solicita:Rodolfo GÃ³mez Hernandez',
'BD:bdiedoelec';

CREATE PROCEDURE "informix".sp_obtener_edosctas_historica_web
(
	pEmpresa CHAR(3),
	pNoCliente CHAR(9),
	pNoCuenta CHAR(20),
	pFechaInicio DATE,
	pFechaHoy DATE
)
RETURNING 
CHAR(5) AS codRetorno,
CHAR(20) AS cuenta,
CHAR(20) AS tarjeta,
CHAR(4) AS sucursal,
CHAR(45) AS producto,
DATE AS fecha_emision,
CHAR(20) AS estatus;


DEFINE cCodRet CHAR(5);
DEFINE cCuenta CHAR(20);
DEFINE cTarjeta CHAR(20);
DEFINE cSucursal CHAR(4);
DEFINE cProducto  CHAR(45);
DEFINE dFecha_emision DATE;
DEFINE cEstatus CHAR(20);
DEFINE iSql_err INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE cTipoCuenta CHAR(2);

LET cCodRet = '00000';
LET cCuenta = '';
LET cTarjeta = '';
LET cSucursal = '';
LET cProducto  = '';
LET dFecha_emision = TODAY;
LET cEstatus = '';
LET cTipoCuenta = '';
LET iSql_err	 = 0;
LET iIsamErr	 = 0;


BEGIN
    
    ON EXCEPTION SET iSql_err,iIsamErr
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
            RETURN cCodRet,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus;
        END IF;
    END EXCEPTION;  
    
      --SET DEBUG FILE TO "/respaldosbd/mario/sp_obtener_edosctas_historica.out";
      --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;	

	IF NVL(pEmpresa,'') <> '' AND NVL(pNoCliente,'') <> '' AND NVL(pNoCuenta,'') <> '' AND NVL(pFechaInicio,'') <> '' AND NVL(pFechaHoy,'') <> '' THEN	
		LET cTipoCuenta = SUBSTR(pNoCuenta,1,2);
		IF cTipoCuenta = '60' THEN	
		
			FOREACH 
				SELECT a.cuenta, c.num_tarjeta, e.sucursal, a.producto||' '||d.nombre_prod, b.fecha_emision, 'EMITIDO' as estatus 
				INTO cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus
				FROM bdiedoelec:"informix".edelec_alta_serv a, bdicred:"informix".sd_encabezado2_edocta b, bdicred:"informix".sd_tarjeta c, bdicred:"informix".sd_definicion d, bdicred:"informix".sd_maecred e 
				WHERE a.empresa = pEmpresa AND  c.empresa = pEmpresa AND  d.empresa = pEmpresa AND e.empresa = pEmpresa AND a.cuenta = b.num_credito 
				AND b.num_credito = a.cuenta AND b.num_credito = c.num_credito AND a.producto = d.num_producto 
				AND e.num_credito = a.cuenta AND a.cuenta = pNoCuenta AND c.secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta WHERE numcte = pNoCliente AND num_credito = pNoCuenta AND tipo_tarjeta = 'T')
				AND b.fecha_emision BETWEEN pFechaInicio AND pFechaHoy 
				ORDER BY b.fecha_emision
			
				RETURN cCodRet,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus WITH RESUME;
				
			END FOREACH;
				
		ELIF cTipoCuenta = '61' OR cTipoCuenta = '63' THEN
		
			FOREACH 
				SELECT a.cuenta, e.sucursal, a.producto||' '||d.nombre_prod,b.fecha_emision, 'EMITIDO' as estatus INTO cCuenta,cSucursal,cProducto,dFecha_emision,cEstatus 
				FROM bdiedoelec:"informix".edelec_alta_serv a, bdicred:"informix".sd_encabezado2_edoctacrd b, bdicred:"informix".sd_definicion d, bdicred:"informix".sd_maecredcrd e  
				WHERE a.cuenta = b.num_credito AND b.num_credito = a.cuenta  AND a.producto = d.num_producto AND e.num_credito = a.cuenta  AND a.cuenta =pNoCuenta   AND b.fecha_emision BETWEEN pFechaInicio AND pFechaHoy 
				ORDER BY b.fecha_emision 

				RETURN cCodRet,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus WITH RESUME;
				
			END FOREACH;
			
		ELIF cTipoCuenta <> '61' AND cTipoCuenta <> '63' AND cTipoCuenta <> '60' THEN
		
			FOREACH 
				SELECT UNIQUE a.cuenta,b.num_tarjeta,a.sucursal,a.producto||' '||c.nombre,b.fechafin,'EMITIDO' as estatus 
				INTO cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus 
				FROM bdicheq:"informix".sc_maechq a, bdicheq:"informix".sc_maehis b, bdicheq:"informix".sc_producto c 
				WHERE a.num_cte = b.num_cte AND a.cuenta = b.cuenta AND a.producto = c.producto AND a.status_cta IN (1,3,4,5) AND a.num_cte = pNoCliente AND b.cuenta = pNoCuenta AND b.fechafin BETWEEN pFechaInicio AND pFechaHoy 
				ORDER BY fechafin ASC

				RETURN cCodRet,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus WITH RESUME;
				
			END FOREACH;
			
		END IF
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '00003';
		END IF;
		
	ELSE
		LET cCodRet = '00002';
	END IF;
	IF cCodret <> '00000' THEN
		RETURN cCodRet,cCuenta,cTarjeta,cSucursal,cProducto,dFecha_emision,cEstatus;
	END IF;

END;
END PROCEDURE
DOCUMENT
"Folio:",
"Autor:95142134 Mario Gallardo",
"Fecha:15/04/2014",
"Modificaci??",
"Sustento: ",
"Solicita:  ",
"BD:bdiedoelec";

CREATE PROCEDURE "informix".sp_del_serv_solic (pempresa char(3)) 
    RETURNING CHAR(5) AS v_sCodRet
	
    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);
	DEFINE v_pass_second_part   CHAR (4);
	DEFINE encry_pass           VARCHAR(20);
	
	DEFINE v_numcte 			CHAR(20);
	DEFINE v_cuenta 			CHAR(20);
	DEFINE v_producto 			CHAR(4);
	DEFINE v_fecha_corte	    DATE;
	DEFINE v_fecha_recepcion    DATE;
	
SET DEBUG FILE TO  "/home/sysdba/salida_trace/sp_del_serv_solic.out"; 
TRACE ON;
	
	LET v_sCodRet = '000';
	LET v_numcte = ''; 			
	LET v_cuenta = '';
	LET v_producto = '';	
	LET v_fecha_corte = TODAY;
	LET v_fecha_recepcion = TODAY;
		
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;
		
		FOREACH WITH HOLD 
			SELECT b.numcte,b.cuenta,b.producto,b.fecha_corte 
		      INTO v_numcte,v_cuenta,v_producto,v_fecha_corte
			  FROM bdiedoelec:edelec_serv_solic a, bdiedoelec:edelec_log_serv_solic b 
			 WHERE a. numcte = b. numcte
			   AND a.cuenta = b.cuenta
			   AND a.producto = b.producto
			   AND a. fecha_vigencia < (select fecha_hoy from bdinteg:si_fechas)
               AND NOT EXISTS ( SELECT 1 FROM bdiedoelec:edelec_log_serv_solic c 
			                            WHERE c.empresa = pempresa
										  AND c.numcte = a. numcte 
										  AND c.producto = a.producto
                                          AND c.fecha_corte = a.fecha_corte 
										  AND c.status_envio_edocta = 'AE')
		  GROUP BY b.numcte,b.cuenta,b.producto,b.fecha_corte 
		  ORDER BY fecha_corte ASC
			
			INSERT INTO bdiedoelec:edelec_serv_solic_ne (empresa,numcte,cuenta,producto,fecha_corte,fecha_recepcion,fecha_modificacion)
				  VALUES (pempresa,v_numcte,v_cuenta,v_producto,v_fecha_corte,v_fecha_recepcion,TODAY);
			
			DELETE FROM bdiedoelec:edelec_serv_solic 
			      WHERE numcte = v_numcte
					AND cuenta = v_cuenta
					AND producto = v_producto 
					AND fecha_corte = v_fecha_corte;
			
			DELETE FROM bdiedoelec:edelec_log_serv_solic
				  WHERE numcte = v_numcte
					AND cuenta = v_cuenta
					AND producto = v_producto 
					AND fecha_corte = v_fecha_corte;
			
		CONTINUE FOREACH;
		END FOREACH;
		
		RETURN v_sCodRet;    
    END
END PROCEDURE;