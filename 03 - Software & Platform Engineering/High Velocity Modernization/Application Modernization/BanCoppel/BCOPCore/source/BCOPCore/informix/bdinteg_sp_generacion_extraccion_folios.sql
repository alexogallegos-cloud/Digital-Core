CREATE PROCEDURE "informix".sp_generacion_extraccion_folios()
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
DEFINE vcontador					INTEGER;
DEFINE vSaldo_pro_mesant			DECIMAL(14,2);
DEFINE vSaldo_pro_mesact			DECIMAL(14,2);
DEFINE vSaldo_total_mes				DECIMAL(14,2);
DEFINE vNum_folios_por_cliente		INTEGER;
DEFINE vNum_folio 					CHAR(8);
DEFINE vNum_folio_cadena 			CHAR(8);
DEFINE vNum_consecutivo				CHAR(8);
DEFINE vSecuencia					CHAR(8);
DEFINE vMesActualNumero				INTEGER;
DEFINE vNum_sorteo					INTEGER;
DEFINE cQuery			            CHAR(3000);

DEFINE cruta						CHAR(100);
DEFINE pArchDescarga		CHAR(150);
DEFINE cnom_Sql				CHAR(100);
DEFINE cSQL1				CHAR(200);
DEFINE cCons1				CHAR(500);
---------------------------------------
DEFINE vUsuario         CHAR(20);
DEFINE vLLave           CHAR(200);
DEFINE vNomarch         CHAR(100);
DEFINE vRutaOrigen      CHAR(100);
DEFINE vRutaDestino     CHAR(100);
DEFINE vNomarchSalida   CHAR(100);
DEFINE vRutaOriginales  CHAR(100);
DEFINE vNomarch_salida  CHAR(100);

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
LET vSaldo_pro_mesant			= 0.00;
LET vSaldo_pro_mesact			= 0.00;
LET vSaldo_total_mes			= 0.00;
LET vNum_folios_por_cliente		= 0;
LET vNum_folio 					= '1';
LET vNum_folio_cadena			= '';
LET vNum_consecutivo			= '1';
LET vSecuencia					= '1';
LET vMesActualNumero			= 1;
LET vNum_sorteo					= 0;
LET cQuery						= '';
LET cRuta		 				= "/RESPALDOSNEW/Sorteo2024/";
--LET cRuta		 				= "/RESPALDOSNEW/Sorteo2024/encr";
LET cnom_Sql 					= 'Sorteo_bancoppel_';
-----------------------------------------------------------  
  LET vUsuario        = '';
    LET vLLave          = '';
    LET vNomarch        = '';
    LET vRutaOrigen     = '';
    LET vRutaDestino    = '';
    LET vNomarchSalida  = '';
    LET vRutaOriginales = '';
    LET vNomarch_salida = '';


	--SET DEBUG FILE TO  '/RESPALDOSNEW/Sorteo2024/sp_generacion_folios_sorteo_efectivo.out';
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				--insert into "informix".sac_log_errores_sorteo (codigoError,mensaje,fecha)
				--values (cCodRet,vCadena_req,sysdate);
				--COMMIT;
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
	
	  TRUNCATE TABLE "informix".si_detalle_folios;
		

--Se verificara que los clientes cumplan con las reglas para participar

		BEGIN WORK;
			
			INSERT INTO si_detalle_folios
			SELECT s.num_consecutivo, s.estado, t.ciudad, t.sucursal,s.area, s.caja, s.tipo_movimiento, s.numero_folio, 
			s.num_cliente, s.importe_general,t.telefono_casa,t.num_celular,t.nombre_completo, t.domicilio, 
			t.fecha_alta,s.origen, s.secuencia, t.des_estado
			FROM si_sorteo_folios s
			INNER JOIN si_sorteo_info_cliente t ON t.num_cliente =  s.num_cliente
			WHERE s.num_sorteo  = vNum_sorteo;
		
				
		COMMIT WORK;

		BEGIN WORK;
		
		LET cCons1 = "SELECT num_consecutivo, estado, ciudad, sucursal,area, caja, tipo_movimiento, numero_folio, num_cliente, importe_general, telefono_casa, num_celular, trim(nombre_completo), trim(domicilio), to_char(fecha_alta), origen, secuencia, des_estado FROM si_detalle_folios order by num_consecutivo;";
		
		LET pArchDescarga  = cnom_Sql; 
		
		LET cnom_Sql = 'Sorteo_bancoppel.sql';
		LET cSQL1 = '">'||TRIM(cruta)|| cnom_Sql;
		
				
	   -- LET pArchDescarga = TRIM(pArchDescarga)  || lpad(month(dFecha_Max_Procesada),2,'0') || lpad(year(dFecha_Max_Procesada),4,'0') || '.unl';
		LET cQuery = ' echo " UNLOAD TO '|| TRIM(cruta) ||'sorteo_bancoppel.unl '||TRIM(cCons1) || "" || cSQL1;
		SYSTEM TRIM(cQuery);
	
	    LET cQuery='chmod 777 '|| TRIM(cruta)|| cnom_Sql;
		System cQuery;
	
		LET cQuery = 'dbaccess bdinteg ' || TRIM(cruta) || cnom_Sql;
		--LET cQuery =  "/RESPALDOSNEW/Sorteo2024 " || TRIM(cruta)||"Cuerpo.unl > " || TRIM(cruta) || pArchDescarga;
		SYSTEM cQuery;
		
		let cQuery ='';
		let cQuery = "sed 's/|$//g' /RESPALDOSNEW/Sorteo2024/sorteo_bancoppel.unl >>/RESPALDOSNEW/Sorteo2024/Sorteo_bancoppel_"|| lpad(month(dFecha_Max_Procesada),2,'0') || lpad(year(dFecha_Max_Procesada),4,'0') || ".txt";
		system cQuery;
		
		--let cQuery ='';
		--let cQuery = "sed '1d' /RESPALDOSNEW/Sorteo2024/Sorteo_bancoppel_"|| lpad(month(dFecha_Max_Procesada),2,'0') || lpad(year(dFecha_Max_Procesada),4,'0') || ".unl";
		--system cQuery;
		
		LET cQuery='chmod 777 '|| TRIM(cruta)||"Sorteo_bancoppel_"|| lpad(month(dFecha_Max_Procesada),2,'0') || lpad(year(dFecha_Max_Procesada),4,'0') || ".txt";
		System cQuery;
		
		
		LET cQuery = '';
        LET cQuery = 'rm ' || TRIM(cruta) || TRIM(cnom_Sql);
		SYSTEM cQuery;
		LET cQuery = 'rm /RESPALDOSNEW/Sorteo2024/sorteo_bancoppel.unl';
		SYSTEM cQuery;
		
		COMMIT WORK; 
		
		
		BEGIN WORK;
		
		LET cnom_Sql = 'Sorteo_bancoppel_segob_';
		
		LET cCons1 = "SELECT numero_folio, trim(nombre_completo), ciudad, des_estado FROM si_detalle_folios order by num_consecutivo;";
		
		LET pArchDescarga  = cnom_Sql; 
		
		LET cnom_Sql = 'Sorteo_bancoppel.sql';
		LET cSQL1 = '">'||TRIM(cruta)|| cnom_Sql;
		
				
	   -- LET pArchDescarga = TRIM(pArchDescarga)  || lpad(month(dFecha_Max_Procesada),2,'0') || lpad(year(dFecha_Max_Procesada),4,'0') || '.unl';
		LET cQuery = ' echo " UNLOAD TO '|| TRIM(cruta) ||'sorteo_bancoppel_segob.unl '||TRIM(cCons1) || "" || cSQL1;
		SYSTEM TRIM(cQuery);
	
	    LET cQuery='chmod 777 '|| TRIM(cruta)|| cnom_Sql;
		System cQuery;
	
		LET cQuery = 'dbaccess bdinteg ' || TRIM(cruta) || cnom_Sql;
		--LET cQuery =  "/RESPALDOSNEW/Sorteo2024 " || TRIM(cruta)||"Cuerpo.unl > " || TRIM(cruta) || pArchDescarga;
		SYSTEM cQuery;
		
		let cQuery ='';
		let cQuery = "sed 's/|$//g' /RESPALDOSNEW/Sorteo2024/sorteo_bancoppel_segob.unl >>/RESPALDOSNEW/Sorteo2024/Sorteo_bancoppel_segob_"|| lpad(month(dFecha_Max_Procesada),2,'0') || lpad(year(dFecha_Max_Procesada),4,'0') || ".txt";
		system cQuery;
		
		--let cQuery ='';
		--let cQuery = "sed '1d' /RESPALDOSNEW/Sorteo2024/Sorteo_bancoppel_"|| lpad(month(dFecha_Max_Procesada),2,'0') || lpad(year(dFecha_Max_Procesada),4,'0') || ".unl";
		--system cQuery;
		
		LET cQuery='chmod 777 '|| TRIM(cruta)||"Sorteo_bancoppel_segob_"|| lpad(month(dFecha_Max_Procesada),2,'0') || lpad(year(dFecha_Max_Procesada),4,'0') || ".txt";
		System cQuery;
		
		LET cQuery = '';
        LET cQuery = 'rm ' || TRIM(cruta) || TRIM(cnom_Sql);
		SYSTEM cQuery;
		LET cQuery = 'rm /RESPALDOSNEW/Sorteo2024/sorteo_bancoppel_segob.unl';
		SYSTEM cQuery;
		
		COMMIT WORK; 
		
		--------------------------------------------------Encrip------------------------------
	
		
		RETURN cCodRet;
	
	END;
END PROCEDURE;