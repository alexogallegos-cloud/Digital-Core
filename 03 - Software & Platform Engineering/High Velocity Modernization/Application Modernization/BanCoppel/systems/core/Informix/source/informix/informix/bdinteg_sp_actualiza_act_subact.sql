CREATE PROCEDURE "informix".sp_actualiza_act_subact()
	RETURNING 
	CHAR(6), 
	CHAR(100);

	--Definicion de Variables
	DEFINE iSqlErr          	INTEGER;
	DEFINE iSamErr 				INTEGER;
	DEFINE cVarDataErr			CHAR(100);
	DEFINE cCodRet          	CHAR(6);
	
	DEFINE sNumcte	        	CHAR(20);
	DEFINE iact      			INTEGER;
	DEFINE isubact      		INTEGER;
	DEFINE iactualizado 		INTEGER;
	DEFINE iCount 				INTEGER;
	DEFINE iCountSec			INTEGER;
	DEFINE ibandera 			INTEGER;

	DEFINE v_empresa             	CHAR(3);
	DEFINE v_numcte              	CHAR(20);
	DEFINE v_sec_ingreso         	SMALLINT;
	DEFINE v_tipo_ingreso        	CHAR(1);
	DEFINE v_nombre_empresa      	CHAR(60);
	DEFINE v_puesto              	CHAR(3);
	DEFINE v_puesto_esp          	CHAR(2);
	DEFINE v_antiguedad          	DECIMAL(4,2);
	DEFINE v_nombre_depto        	CHAR(40);
	DEFINE v_jefe_inmediato      	CHAR(60);
	DEFINE v_ingreso_mensual     	MONEY;
	DEFINE v_user_insert         	CHAR(8);
	DEFINE v_fecha_insert        	DATE;
	DEFINE v_clavepuesto         	INTEGER;
	DEFINE v_claveopcionpuesto   	INTEGER;
	DEFINE v_clavesubopcionpuesto	INTEGER;
	DEFINE v_sis_cotiza          	INTEGER;
	DEFINE v_num_emp_lab         	INTEGER;
	DEFINE v_periosidad          	INTEGER;
	DEFINE v_tipo_ingreso_ext    	INTEGER;
	
	--Inicializa Variables
	LET cCodRet 		= '000000';
	LET cVarDataErr 	= 'EJECUCION EXITOSA';
	LET sNumcte 		= '';
	LET iact				= 0;
	LET isubact			= 0;
	LET iactualizado	= 0;
	LET iCount		 	= 0;
	LET iCountSec	 	= 0;
	LET ibandera 	 	= 0;
	
	LET v_empresa             	= '001';
	LET v_sec_ingreso         	= 0;
	LET v_tipo_ingreso        	= 'T';
	LET v_nombre_empresa      	= '';
	LET v_puesto              	= '0';
	LET v_puesto_esp          	= '0';
	LET v_antiguedad          	= 0;
	LET v_nombre_depto        	= '';
	LET v_jefe_inmediato      	= '';
	LET v_ingreso_mensual     	= 0;
	LET v_user_insert         	= 'informix';
	LET v_fecha_insert        	= CURRENT;
	LET v_clavepuesto         	= 0;
	LET v_claveopcionpuesto   	= 0;
	LET v_clavesubopcionpuesto	= 0;
	LET v_sis_cotiza          	= 0;
	LET v_num_emp_lab         	= 0;
	LET v_periosidad          	= 0;
	LET v_tipo_ingreso_ext    	= 0;
	
	--SET DEBUG FILE TO "/respaldosbd/Pedro/1509/sp_monitorear_indicadores_sucursal.out";
	--TRACE ON;
BEGIN
	--Manejo del error
	ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
		IF iSqlErr <> 0 THEN
			LET cCodRet=iSqlErr;
			
			COMMIT WORK;
				
			RETURN cCodRet, iSamErr || ' ' ||cVarDataErr;
		END IF;
	END EXCEPTION;
			
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN WORK;
	
	FOREACH WITH HOLD
		Select {+INDEX ("informix".tmp_cte_act_subact_x_act idx_tmp_cte_act_subact_x_act3)}
			numcte, act, subact
		Into sNumcte, iact, isubact
		From "informix".tmp_cte_act_subact_x_act
		Where actualizado = 0
		
		LET iCount = iCount + 1;
		LET ibandera = 0;
		
		IF EXISTS(Select 1 From bdinteg:"informix".si_ingresos Where numcte = sNumcte) THEN
			LET iCountSec = 0;
	
			FOREACH WITH HOLD
				Select empresa, sec_ingreso, tipo_ingreso, nombre_empresa, puesto, puesto_esp, antiguedad, nombre_depto, jefe_inmediato, ingreso_mensual, user_insert, 
						clavepuesto, NVL(claveopcionpuesto, '300'), NVL(clavesubopcionpuesto, '300'), sis_cotiza, num_emp_lab, periosidad, tipo_ingreso_ext
				Into v_empresa, v_sec_ingreso, v_tipo_ingreso, v_nombre_empresa, v_puesto, v_puesto_esp, v_antiguedad, v_nombre_depto, v_jefe_inmediato, v_ingreso_mensual, v_user_insert, 
						v_clavepuesto, v_claveopcionpuesto, v_clavesubopcionpuesto, v_sis_cotiza, v_num_emp_lab, v_periosidad, v_tipo_ingreso_ext
				From "informix".si_ingresos
				Where numcte = sNumcte
				Order By sec_ingreso DESC
				
				IF iCountSec = 0 THEN
					LET iCountSec = v_sec_ingreso + 1;
				END IF;
				
				IF v_claveopcionpuesto = 300 OR v_clavesubopcionpuesto = 300 THEN
					LET ibandera = 1;
					CONTINUE FOREACH;
				ELSE	
					IF NOT EXISTS(Select 1 From "informix".si_actsubact Where id_act = v_claveopcionpuesto AND id_subact = v_claveopcionpuesto) THEN
						LET v_claveopcionpuesto = iact;
						LET v_clavesubopcionpuesto = isubact;
					END IF;
					
					LET ibandera = 0;
					
					EXIT FOREACH;
				END IF;

			END FOREACH;
			
			LET v_sec_ingreso = iCountSec;
		ELSE
			LET v_sec_ingreso = 1;
			LET ibandera = 1;
		END IF;
		
		LET v_user_insert = 'informix';
		LET v_fecha_insert = CURRENT;
		
		IF ibandera = 1 THEN
			LET v_empresa             	= '001';
			LET v_tipo_ingreso        	= 'T';
			LET v_nombre_empresa      	= '';
			LET v_puesto              	= '0';
			LET v_puesto_esp          	= '0';
			LET v_antiguedad          	= 0;
			LET v_nombre_depto        	= '';
			LET v_jefe_inmediato      	= '';
			LET v_ingreso_mensual     	= 0;
			LET v_clavepuesto         	= 0;
			LET v_claveopcionpuesto   	= iact;
			LET v_clavesubopcionpuesto	= isubact;
			LET v_sis_cotiza          	= 0;
			LET v_num_emp_lab         	= 0;
			LET v_periosidad          	= 0;
			LET v_tipo_ingreso_ext    	= 0;
		END IF;
		
		
		INSERT INTO "informix".si_ingresos(empresa, numcte, sec_ingreso, tipo_ingreso, nombre_empresa, puesto, puesto_esp, antiguedad, nombre_depto, jefe_inmediato, 
											ingreso_mensual, user_insert, fecha_insert, clavepuesto, claveopcionpuesto, clavesubopcionpuesto, sis_cotiza, num_emp_lab, 
											periosidad, tipo_ingreso_ext)
									VALUES(v_empresa, sNumcte, v_sec_ingreso, v_tipo_ingreso, v_nombre_empresa, v_puesto, v_puesto_esp, v_antiguedad, v_nombre_depto, v_jefe_inmediato, 
											v_ingreso_mensual, v_user_insert, v_fecha_insert, v_clavepuesto, v_claveopcionpuesto, v_clavesubopcionpuesto, v_sis_cotiza, v_num_emp_lab, 
											v_periosidad, v_tipo_ingreso_ext);
		
		UPDATE "informix".tmp_cte_act_subact_x_act
		SET actualizado = 1
		WHERE numcte = sNumcte;
		
		IF iCount >= 1000 THEN
			COMMIT WORK;
			LET iCount = 0;
			BEGIN WORK;
		END IF;
		
	END FOREACH;
	
	COMMIT WORK;
	
	RETURN cCodRet,cVarDataErr;		
END;
END PROCEDURE
DOCUMENT
'AUTOR: 90238760 - Uriel Amador Islas',
'FECHA: 06/11/2015',
'DESCRIPCIÃN: Se crea para la insercion o actualizacion de actividad economica y subactividad economica',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_invitacion_sorteo_efectivo(pNumero integer)
RETURNING CHAR(5);
-- DEFINICION DE VARIABLES
DEFINE cCodRet						CHAR(5);
DEFINE iSqlErr						INTEGER;
DEFINE cDia							CHAR(2);
DEFINE cMes							CHAR(2);
DEFINE cAnio						CHAR(4);
DEFINE cMes_Mes_Anterior			CHAR(2);
DEFINE cAnio_Mes_Anterior			CHAR(4);
DEFINE vCadena_req					CHAR(334);


DEFINE dFecha_Hoy					DATE;
DEFINE dFecha_Max_Procesada			DATE;
DEFINE dFecha_Mes_Anterior			DATE;
DEFINE vFecha_alta					DATE;
DEFINE vMesActualNumero				INTEGER;
DEFINE vNum_cte						CHAR(20);
DEFINE vCuenta						CHAR(20);
DEFINE vAnio						CHAR(4);
DEFINE vNum_producto				CHAR(4);
DEFINE vMesActualCadena				CHAR(6);
DEFINE vMesAnteriorCadena			CHAR(6);
DEFINE vCta_cheques					CHAR(20);
DEFINE vCapvig1						DECIMAL(14,2);
DEFINE vCapvig2						DECIMAL(14,2);
DEFINE vCapvig3						DECIMAL(14,2);
DEFINE vCapvig4						DECIMAL(14,2);
DEFINE vCapvig5						DECIMAL(14,2);
DEFINE vCapvig6						DECIMAL(14,2);
DEFINE vCapvig7						DECIMAL(14,2);
DEFINE vCapvig8						DECIMAL(14,2);
DEFINE vCapvig9						DECIMAL(14,2);
DEFINE vCapvig10					DECIMAL(14,2);
DEFINE vCapvig11					DECIMAL(14,2);
DEFINE vCapvig12					DECIMAL(14,2);
DEFINE vCapitalmesanterior			DECIMAL(14,2);
DEFINE vCapitalmesactual			DECIMAL(14,2);
DEFINE vcontador					integer;
DEFINE vCta_eje_inver				CHAR(20);
DEFINE vNum_tarjeta					CHAR(20);
DEFINE v_cliente_inicial            CHAR(20);
DEFINE v_cliente_final              CHAR(20);
DEFINE v_cte_cuenta					CHAR(20);
DEFINE v_cheques					CHAR(1);
DEFINE v_pagare						CHAR(1);
--INICIALIZACION DE VARIABLES--
LET cCodRet						= "00000";
LET iSqlErr						= 0;
LET cDia						= '';
LET cMes						= '';
LET cAnio						= '';
LET cMes_Mes_Anterior			= '';
LET cAnio_Mes_Anterior			= '';
LET vCadena_req					= '';
LET dFecha_Max_Procesada		= MDY('01','01','1900');
LET dFecha_Mes_Anterior			= MDY('01','01','1900');
LET vMesActualNumero			= 0;
LET vNum_cte					= '';
LET vCuenta						= '';
LET vAnio						= '';
LET vNum_producto				= '';
LET vMesActualCadena			= '';
LET vMesAnteriorCadena			= '';
LET vCta_cheques				= '';
LET vCapvig1					= 0.00;
LET vCapvig2					= 0.00;
LET vCapvig3					= 0.00;
LET vCapvig4					= 0.00;
LET vCapvig5					= 0.00;
LET vCapvig6					= 0.00;
LET vCapvig7					= 0.00;
LET vCapvig8					= 0.00;
LET vCapvig9					= 0.00;
LET vCapvig10					= 0.00;
LET vCapvig11					= 0.00;
LET vCapvig12					= 0.00;
LET vCapitalmesanterior			= 0.00;
LET vCapitalmesactual			= 0.00;
LET vcontador					= 0;
LET vCta_eje_inver				= '';
LET vNum_tarjeta				= '';
LET v_cliente_inicial           = '';
LET v_cliente_final             = '';
LET v_cte_cuenta				= '';

	--SET DEBUG FILE TO  '/informix/RESPALDOSNEW/RD/sp_invitacion_sorteo_efectivo.out';
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
					--insert into bdinteg:"informix".si_errores_sorteo (codigoerror,descripcion,fecha)
					--values (cCodRet,vNum_cte,sysdate);
				ROLLBACK WORK;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
--Consulta que regresa la fecha del dia actual
		SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM bdinteg:"informix".si_fechas
		WHERE empresa = "001";
		

--Se inicializa la variable dFecha_Max_Procesada con el valor dFecha_Hoy
		LET dFecha_Max_Procesada = EXTEND(dFecha_Hoy, YEAR TO DAY) - 1 UNITS MONTH;
		
--Se asignan los valores a las variables cDia,cMes,cAnio, vMesActualCadena

		LET cDia = LPAD(DAY(dFecha_Max_Procesada::DATE), 2, '0');
		LET cMes = LPAD(MONTH(dFecha_Max_Procesada::DATE), 2, '0'); 
		LET cAnio = LPAD(YEAR(dFecha_Max_Procesada::DATE),4,'0');
		LET vMesActualCadena = cAnio || cMes;

--Se recupera mes en entero para traer el monto del mes actual y el mes anterior

		LET vMesActualNumero = cast(cMes as INTEGER);

		LET dFecha_Mes_Anterior = EXTEND(dFecha_Max_Procesada, YEAR TO DAY) - 1 UNITS MONTH;
		
--Se asignan los valores a las variables cMes_Mes_Anterior,cAnio_Mes_Anterior,vMesAnteriorCadena

		LET cMes_Mes_Anterior = LPAD(MONTH(dFecha_Mes_Anterior::DATE), 2, '0'); 
		LET cAnio_Mes_Anterior = LPAD(YEAR(dFecha_Mes_Anterior::DATE),4,'0');

		LET vMesAnteriorCadena = cAnio_Mes_Anterior|| cMes_Mes_Anterior;

--Recupera listado de cuentas participantes de los productos participantes

		SELECT cliente_inicial, cliente_final, cte_cuenta, pagare, cheques
			INTO v_cliente_inicial, v_cliente_final, v_cte_cuenta, v_pagare, v_cheques
		FROM "informix".si_sorteo_hilos WHERE numero_proceso = pNumero;
		
		IF v_cte_cuenta  > '0' THEN
			LET v_cliente_inicial = v_cte_cuenta + 1;
		END IF;
		
		IF v_cheques = '0' THEN
		------------------------- INICIA OBTENCION DE CUENTAS DE PRODUCTO 2000 ----------------------------------------------
			BEGIN WORK;
			
				--Insert into si_control_ejecucion(numero, inicio, fecha) values('1', '0', sysdate);
				
				FOREACH WITH HOLD
			
					SELECT  num_cte, cuenta, producto
						INTO vNum_cte, vCuenta, vNum_producto
						FROM bdicheq:"informix".sc_maechq
						WHERE producto IN ('2000', '2900', '1100')
						AND status_cta in( '1', '3') AND num_cte BETWEEN v_cliente_inicial AND v_cliente_final
		
					
					IF vNum_producto = '1100' THEN
						SELECT FIRST 1 cuentadep 
							INTO  vNum_tarjeta
						FROM bdicheq:"informix".sc_maeinstrucc WHERE cuenta = vCuenta;
					
					
							/*SELECT FIRST 1 num_tarjeta
							INTO vNum_tarjeta
							FROM bdicheq:"informix".sc_tarjeta 
							WHERE cuenta = vCta_eje_inver AND numcte = vNum_cte
							AND status_tar = 'A';*/
					ELSE
					
						SELECT FIRST 1 num_tarjeta
							INTO vNum_tarjeta
							FROM bdicheq:"informix".sc_tarjeta 
							WHERE cuenta = vCuenta AND numcte = vNum_cte
							AND status_tar = 'A';
							--ORDER BY secuencia desc;
					END IF;
					
		
					IF vMesActualNumero = 1 OR vMesActualNumero = 2 OR vMesActualNumero = 3	THEN
		
						SELECT capvigprom4, capvigprom5, capvigprom6, capvigprom7, capvigprom8, capvigprom9, capvigprom10, capvigprom11, capvigprom12
						--capvig4, capvig5, capvig6, capvig7, capvig8, 
						--		capvig9, capvig10, capvig11, capvig12
								INTO vCapvig4, vCapvig5, vCapvig6, vCapvig7, vCapvig8, vCapvig9, vCapvig10, vCapvig11, vCapvig12
							FROM bdicheq:"informix".sc_sdomensualc
								WHERE cuenta = vCuenta AND anio = cAnio_Mes_Anterior;
		
						
		
						SELECT capvigprom1, capvigprom2, capvigprom3
						--capvig1, capvig2, capvig3
								INTO vCapvig1, vCapvig2, vCapvig3
							FROM bdicheq:"informix".sc_sdomensualc
								WHERE cuenta = vCuenta AND anio = cAnio;
		
					ELSE
		
						SELECT capvigprom4, capvigprom5, capvigprom6, capvigprom7, capvigprom8, capvigprom9, capvigprom10, capvigprom11, capvigprom12
						--capvig4, capvig5, capvig6, capvig7, capvig8, capvig9, capvig10, capvig11, capvig12
								INTO vCapvig4, vCapvig5, vCapvig6, vCapvig7, vCapvig8, vCapvig9, vCapvig10, vCapvig11, vCapvig12
								FROM bdicheq:"informix".sc_sdomensualc
								WHERE cuenta = vCuenta AND anio = cAnio;
		
		
					END IF;
		
		
					CASE vMesActualNumero
						WHEN 5 THEN
							LET vCapitalmesanterior = vCapvig4;
							LET vCapitalmesactual = vCapvig5;
						WHEN 6 THEN
							LET vCapitalmesanterior = vCapvig5;
							LET vCapitalmesactual = vCapvig6;
						WHEN 7 THEN
							LET vCapitalmesanterior = vCapvig6;
							LET vCapitalmesactual = vCapvig7;
						WHEN 8 THEN
							LET vCapitalmesanterior = vCapvig7;
							LET vCapitalmesactual = vCapvig8;
						WHEN 9 THEN
							LET vCapitalmesanterior = vCapvig8;
							LET vCapitalmesactual = vCapvig9;
						WHEN 10 THEN
							LET vCapitalmesanterior = vCapvig9;
							LET vCapitalmesactual = vCapvig10;
						WHEN 11 THEN
							LET vCapitalmesanterior = vCapvig10;
							LET vCapitalmesactual = vCapvig11;
						WHEN 12 THEN
							LET vCapitalmesanterior = vCapvig11;
							LET vCapitalmesactual = vCapvig12;
						WHEN 1 THEN 
							LET vCapitalmesanterior = vCapvig12;
							LET vCapitalmesactual = vCapvig1;
						WHEN 2 THEN
							LET vCapitalmesanterior = vCapvig1;
							LET vCapitalmesactual = vCapvig2;
						WHEN 3 THEN
							LET vCapitalmesanterior = vCapvig2;
							LET vCapitalmesactual = vCapvig3;
					END CASE;
		
					IF vCapitalmesactual > vCapitalmesanterior THEN
						INSERT INTO bdinteg:"informix".si_sorteos_cuentas_participantes(num_cliente, num_cuenta, num_tarjeta, mes, anio, num_producto, saldo_pro_mesant, saldo_pro_mesact) 
						VALUES(vNum_cte, vCuenta, vNum_tarjeta, cMes, cAnio, vNum_producto, vCapitalmesanterior, vCapitalmesactual);
					END IF;
					
						LET vcontador = vcontador + 1;
		
					IF vcontador = 1000 THEN
						COMMIT WORK;
							UPDATE "informix".si_sorteo_hilos SET cte_cuenta = vNum_cte where numero_proceso = pNumero;
						LET vcontador = 0;
						BEGIN WORK;
					END IF;
			
				END FOREACH;
				
				--Insert into si_control_ejecucion(numero, inicio, fecha) values('1', '1', sysdate);
			COMMIT WORK;
			------------------------- INICIA OBTENCION DE CUENTAS DE PRODUCTO 2900 ----------------------------------------------
			LET vcontador = 0;
			UPDATE "informix".si_sorteo_hilos SET cheques = '1', mes_ejecucion = cMes , cte_cuenta = '0' where numero_proceso = pNumero;
		END IF;
	
		IF v_pagare = '0' then	
			BEGIN WORK;
				--Insert into si_control_ejecucion(numero, inicio, fecha) values('2', '0', sysdate);
			
				FOREACH WITH HOLD
		
					SELECT cuenta, cod_instrum, num_cte, cta_cheques--, fecha_alta
							INTO vCuenta, vNum_producto, vNum_cte, vNum_tarjeta--, vFecha_alta
							FROM bdinvers:"informix".sv_maeinv 
							WHERE cod_instrum = '3000' AND status_cta = '1' and num_cte BETWEEN v_cliente_inicial AND v_cliente_final
		
					SELECT cap_prom
					--cap_cierre
							INTO vCapitalmesanterior
							FROM bdinvers:"informix".sv_provmes
							WHERE cuenta = vCuenta 
							AND aniomes = vMesAnteriorCadena
							AND cap_cierre > 0;
		
					SELECT cap_prom
					--cap_cierre
							INTO vCapitalmesactual
							FROM bdinvers:"informix".sv_provmes
							WHERE cuenta = vCuenta 
							AND aniomes = vMesActualCadena
							AND cap_cierre > 0;
		
					/*SELECT FIRST 1 num_tarjeta
							INTO vNum_tarjeta
							FROM bdicheq:"informix".sc_tarjeta 
							WHERE cuenta = vCta_cheques AND numcte = vNum_cte
							AND status_tar = 'A';
							--ORDER BY secuencia desc;*/
					
					IF vCapitalmesactual > vCapitalmesanterior THEN
						INSERT INTO bdinteg:"informix".si_sorteos_cuentas_participantes 
							(num_cliente, num_cuenta, num_tarjeta, mes, anio, num_producto, saldo_pro_mesant, saldo_pro_mesact)
						VALUES
							(vNum_cte, vCuenta, vNum_tarjeta, cMes, cAnio, vNum_producto, vCapitalmesanterior, vCapitalmesactual);
					END IF;
					
					LET vcontador = vcontador + 1;
							
						IF vcontador = 1000 THEN
							COMMIT WORK;
								UPDATE "informix".si_sorteo_hilos SET cte_cuenta = vNum_cte, mes_ejecucion = cMes where numero_proceso = pNumero;
							LET vcontador = 0;
							BEGIN WORK;
						END IF;	
						
				END FOREACH;
			--Insert into si_control_ejecucion(numero, inicio, fecha) values('2', '1', sysdate);
			
			COMMIT WORK;
			UPDATE "informix".si_sorteo_hilos SET pagare = '1', cte_cuenta = '0' where numero_proceso = pNumero;
		END IF;
		RETURN cCodRet;
	
	END;
END PROCEDURE;