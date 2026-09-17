CREATE PROCEDURE "informix".sp_generacion_folios_sorteo_efectivo()
RETURNING CHAR(5) AS cCod_Ret;
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
DEFINE vNum_cte						CHAR(20);
DEFINE vcontador					integer;
DEFINE vcontador_cliente					INT8;
DEFINE vSaldo_pro_mesant			DECIMAL(14,2);
DEFINE vSaldo_pro_mesact			DECIMAL(14,2);
DEFINE vSaldo_total_mes				DECIMAL(14,2);
DEFINE vNum_folios_por_cliente		INTEGER;
DEFINE vNum_folio 					INT8;
DEFINE vNum_folio_cadena 			CHAR(8);
DEFINE vNum_consecutivo				INT8;
DEFINE vSecuencia					INT8;
DEFINE vMesActualNumero				INTEGER;
DEFINE vNum_sorteo					INTEGER;
DEFINE cQuery			            CHAR(3000);

DEFINE cruta						CHAR(100);
DEFINE pArchDescarga		CHAR(150);
DEFINE cnom_Sql				CHAR(100);
DEFINE cSQL1				CHAR(200);
DEFINE cCons1				CHAR(500);
DEFINE v_saldo_general		INT8;
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
LET vNum_cte					= '';
LET vcontador					= 0;
LET vcontador_cliente			= 0;
LET vSaldo_pro_mesant			= 0.00;
LET vSaldo_pro_mesact			= 0.00;
LET vSaldo_total_mes			= 0.00;
LET vNum_folios_por_cliente		= 0;
LET vNum_folio 					= 1;
LET vNum_folio_cadena			= '0';
LET vNum_consecutivo			= 1;
LET vSecuencia					= 0;
LET vMesActualNumero			= 1;
LET vNum_sorteo					= 0;
LET cQuery						= '';
LET cRuta		 				= "/RESPALDOSNEW/Sorteo2024/";
LET cnom_Sql 					= 'Sorteo_bancoppel_';
LET v_saldo_general				= 0;

	 --SET DEBUG FILE TO  '/ifxsif01/sor/sp_generacion_folios_sorteo_efectivo.out';
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				--insert into "informix".sac_log_errores_sorteo (codigoError,mensaje,fecha)
				--values (cCodRet,vCadena_req,sysdate);
				COMMIT;
			RETURN cCodRet;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
--Consulta que regresa la fecha del dia actual
		SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM "informix".si_fechas
		WHERE empresa = "001";
		
--Se inicializa la variable dFecha_Max_Procesada con el valor dFecha_Hoy
		LET dFecha_Max_Procesada = EXTEND(dFecha_Hoy, YEAR TO DAY) - 1 UNITS MONTH;
		
--Se asignan los valores a las variables cDia,cMes,cAnio, vMesActualCadena

		LET cDia = LPAD(DAY(dFecha_Max_Procesada::DATE), 2, '0');
		LET cMes = LPAD(MONTH(dFecha_Max_Procesada::DATE), 2, '0'); 
		LET cAnio = LPAD(YEAR(dFecha_Max_Procesada::DATE),4,'0');

--Se recupera mes en entero para calcular el numero de sorteo

		LET vMesActualNumero = cast(cMes as INTEGER);

		CASE vMesActualNumero
			WHEN 5 THEN
				LET vNum_sorteo = 1;
			WHEN 6 THEN
				LET vNum_sorteo = 2;
			WHEN 7 THEN
				LET vNum_sorteo = 3;
			WHEN 8 THEN
				LET vNum_sorteo = 4;
			WHEN 9 THEN
				LET vNum_sorteo = 5;
			WHEN 10 THEN
				LET vNum_sorteo = 6;
			WHEN 11 THEN
				LET vNum_sorteo = 7;
			WHEN 12 THEN
				LET vNum_sorteo = 8;
			WHEN 1 THEN 
				LET vNum_sorteo = 9;
			WHEN 2 THEN
				LET vNum_sorteo = 10;
			WHEN 3 THEN
				LET vNum_sorteo = 11;
			WHEN 4 THEN
				LET vNum_sorteo = 12;
		END CASE;

		

--Se verificara que los clientes cumplan con las reglas para participar

		BEGIN WORK;

			FOREACH WITH HOLD

				SELECT DISTINCT num_cliente
				INTO vNum_cte
				FROM "informix".si_sorteos_cuentas_participantes WHERE num_cliente is not null and mes = cMes  

				-- Calcular el cierre por mes de cada cliente
				SELECT sum(saldo_pro_mesant), sum(saldo_pro_mesact)
				INTO vSaldo_pro_mesant, vSaldo_pro_mesact 
				FROM "informix".si_sorteos_cuentas_participantes
				WHERE num_cliente = vNum_cte and mes = cMes;

				-- Validar la diferencia del mes anterior al actual
				LET vSaldo_total_mes = (vSaldo_pro_mesact - vSaldo_pro_mesant) ;
				LET v_saldo_general = cast(vSaldo_pro_mesact as INT8);
				--Limite 330 folios por cliente
				-- Folios inician del 00000001 en adelante
				
				IF vSaldo_total_mes > 0 THEN

					LET vNum_folios_por_cliente = (vSaldo_total_mes / 2500);

					-- Calculamos si el numero de folios excede el limite

					IF vNum_folios_por_cliente > 300 THEN

						LET vNum_folios_por_cliente = 300;

					END IF;
					
					
					IF vNum_folios_por_cliente > 0 THEN
					
						LET vcontador_cliente =  vcontador_cliente + 1;
					
					END IF;
					
					WHILE vNum_folios_por_cliente > 0

						LET vNum_folio_cadena = LPAD(vNum_folio,'8','0');

						INSERT INTO si_sorteo_folios (num_consecutivo, estado, area, caja, tipo_movimiento, numero_folio, num_cliente, importe_general, origen, secuencia, num_sorteo, ganador)
						VALUES (vNum_consecutivo, 2, 'B', 1, 10, vNum_folio_cadena, vNum_cte, v_saldo_general, '0000000', vcontador_cliente, vNum_sorteo, '0');

						LET vNum_consecutivo = vNum_consecutivo + 1;
						LET vNum_folios_por_cliente = vNum_folios_por_cliente -1;
						LET vNum_folio = vNum_folio + 1;

					END WHILE;

					
				END IF;

				LET vcontador = vcontador + 1;
	
				IF vcontador = 1000 THEN
					COMMIT WORK;
					LET vcontador = 0;
					BEGIN WORK;
				END IF;
		
			END FOREACH;
		COMMIT WORK;

		
		
		RETURN cCodRet;
	
	END;
END PROCEDURE;