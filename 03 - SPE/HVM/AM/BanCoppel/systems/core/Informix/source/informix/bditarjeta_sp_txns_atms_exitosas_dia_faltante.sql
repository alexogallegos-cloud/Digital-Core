CREATE PROCEDURE "informix".sp_txns_atms_exitosas_dia_faltante()
RETURNING       CHAR (5) AS COD_RET,
                CHAR(150) AS MENSAJE;

--- Variables de control de errores ---

DEFINE  vContadorDelete                 INTEGER;
DEFINE  vContadorInsert                 INTEGER;
DEFINE  iSqlErr                 		INTEGER;
DEFINE  iIsamErr                		INTEGER;
DEFINE  vErrorInfo              		VARCHAR(80);
DEFINE  CVarDataErr      				CHAR(150);
DEFINE  CCodret          				CHAR(5);
DEFINE  CMENSAJE                 		CHAR(150);
DEFINE  vpaso                   		INTEGER;

--- Variables ---

DEFINE Vsumamis 						DECIMAL(19,4);
DEFINE vsumasus 						DECIMAL(19,4);
DEFINE vsumatotal 						DECIMAL(19,4);

--- Variables de totales ---

DEFINE vmonto_retiro_bd 				DECIMAL(19,4);
DEFINE vmonto_retiro_bc 				DECIMAL(19,4);
DEFINE vmonto_retiro_od 				DECIMAL(19,4);
DEFINE vmonto_retiro_oc 				DECIMAL(19,4);
DEFINE vmaest 							DECIMAL(19,4);

--- Variables de fechas ---

DEFINE vfecharep 						DATE;
DEFINE vfecha_hoy 						DATE;
DEFINE vano     						VARCHAR (4);
DEFINE vmesdia     						VARCHAR (4);
DEFINE vano2 							VARCHAR (4);
DEFINE vmes     						VARCHAR (2);
DEFINE vdia 							VARCHAR (2);
DEFINE vdma 							VARCHAR (8);
DEFINE vdmar 							VARCHAR (10);
DEFINE vdmar2 							VARCHAR (8);
DEFINE vfechadelete 					DATETIME YEAR TO FRACTION(5);
DEFINE vfecharep_inimov 				DATETIME YEAR TO FRACTION(5);
DEFINE vfecharep_finmov 				DATETIME YEAR TO FRACTION(5);
DEFINE vfecharep_inistat        		DATETIME YEAR TO FRACTION(5);
DEFINE vfecharep_finstat        		DATETIME YEAR TO FRACTION(5);
DEFINE vcontadortxnexi 					INTEGER;
DEFINE vcontadorstat 					INTEGER;
DEFINE vcontadortdmovcon 				INTEGER;
DEFINE vfecharephoy						VARCHAR (10); --> Variable para fecha en formato DD/MM/AAAA
DEFINE vanohoy 							VARCHAR (4);
DEFINE vmeshoy 							VARCHAR (2);
DEFINE vdiahoy 							VARCHAR (2);

--- Variables de archivo ---

DEFINE vsFlagEnTransaccion				CHAR(5);
DEFINE vsecuencia 						VARCHAR(7);
DEFINE vtarjeta 						VARCHAR (16);
DEFINE vNombreArchivo					VARCHAR (50);

---Variables Foreach

DEFINE viContadorRegistros  			INTEGER;
DEFINE vsFlagEnTransaccionFor  			CHAR(1);
DEFINE vconsecutivo 					INTEGER;
DEFINE vfechaproceso 					DATETIME YEAR TO FRACTION(5);
DEFINE vfechahoramov 					DATETIME YEAR TO FRACTION(5);
DEFINE vsecuenciaFor 					VARCHAR(7);
DEFINE vnumtarjetamovi 					VARCHAR(16);
DEFINE vnumtarjetastat06 				VARCHAR(16);
DEFINE vbin 							VARCHAR(6);
DEFINE vidterminal 						VARCHAR(16);
DEFINE vtipotran 						VARCHAR(2);
DEFINE vcodtran 						VARCHAR(2);
DEFINE vesnacional 						VARCHAR(4);
DEFINE vtransaccionorigen 				VARCHAR(4);
DEFINE vidreceptor 						VARCHAR(4);
DEFINE vcodreversa 						VARCHAR(1);
DEFINE vmovconciliado 					VARCHAR(1);
DEFINE vmovreversado 					VARCHAR(1);
DEFINE vtrancajeropropio 				VARCHAR(1);
DEFINE vformato 						VARCHAR(4);
DEFINE varchivoorigen 					VARCHAR(3);
DEFINE vcreditodebito 					VARCHAR(1);
DEFINE vmarca 							VARCHAR(1);
DEFINE vmonto 							DECIMAL(19,4);
DEFINE vmontorealrevfzda 				DECIMAL(19,4);
DEFINE vmontosurcharge 					DECIMAL(19,4);
DEFINE vmontocomision 					DECIMAL(19,4);
DEFINE vinternacional 					VARCHAR(7);
--DEFINE dDia_Faltante_Calcular DATE;

DEFINE dFecha_inicio_Mes 				DATE;
DEFINE dFecha_fin_Mes 					DATE;
DEFINE dFecha_primer_dia 				DATE;
DEFINE dFecha_ultimo_dia 				DATE;
DEFINE iDia 							INTEGER;
DEFINE iExisten_registros 				INTEGER;
DEFINE dFech_inicio_horamov 			VARCHAR(50);
DEFINE dFech_fin_horamov 				VARCHAR(50);
DEFINE vMes_falt 						VARCHAR(2);
DEFINE vAnio_falt 						VARCHAR(4);
DEFINE vDia_falt 						VARCHAR(2);
DEFINE dfecha_faltante 					DATE;
DEFINE dfech_a_procesar 				DATE;
DEFINE dfech_a_procesar2 				VARCHAR(10);
DEFINE iNum_dias_falt 					INTEGER;
DEFINE iNum_renglon 					INTEGER;
DEFINE vAnio 							VARCHAR(4);
DEFINE dFechaprocesar 					DATE;
DEFINE vFecha_concilia					DATETIME YEAR TO FRACTION(5);
DEFINE vFecha_mov_cajero				VARCHAR(8);
DEFINE vFecha_mov_cajero_2				VARCHAR(10);
DEFINE vFech_hora_movimiento			DATE;


--- Inicializando variables ---

LET vfecharep ='';
LET vfecha_hoy = '';

LET vsumamis = 0;
LET vsumasus = 0;
LET vsumatotal = 0;
LET vsFlagEnTransaccion = 'F';
LET vContadorDelete = 0;
LET vContadorInsert = 0;

let vmonto_retiro_bd = 0;
let vmonto_retiro_bc = 0;
let vmonto_retiro_od = 0;
let vmonto_retiro_oc = 0;
let vmaest = 0;
let vcontadortxnexi = 0;
let vcontadorstat = 0;
let vcontadortdmovcon = 0;

LET vsFlagEnTransaccionFor = 'F';
LET viContadorRegistros = 0;


/*
DEFINE vfechaproceso DATETIME YEAR TO FRACTION(5);
DEFINE vfechahoramov DATETIME YEAR TO FRACTION(5); */
LET vconsecutivo = 0;
LET vsecuencia ='';
LET vnumtarjetamovi='';
LET vnumtarjetastat06= '';
LET vbin='';
LET vidterminal='';
LET vtipotran='';
LET vcodtran='';
LET vesnacional='';
LET vtransaccionorigen='';
LET vidreceptor='';
LET vcodreversa='';
LET vmovconciliado='';
LET vmovreversado='';
LET vtrancajeropropio='';
LET vformato='';
LET varchivoorigen='';
LET vcreditodebito='';
LET vmarca='';
LET vmonto=0;
LET vmontorealrevfzda=0;
LET vmontosurcharge=0;
LET vmontocomision=0;
LET vinternacional='';
--LET dDia_Faltante_Calcular = pDiaCalcular;
LET dFecha_inicio_Mes='';
LET dFecha_fin_Mes='';
LET dFecha_ultimo_dia='';
LET dFecha_primer_dia='';
LET iExisten_registros=0;
LET dFech_inicio_horamov = '';
LET dFech_fin_horamov = '';
LET vMes_falt = '';
LET vAnio_falt = '';
LET vDia_falt = '';
LET dfecha_faltante='';
LET dfech_a_procesar='';
LET iNum_dias_falt=0;
LET iNum_renglon = 0;
LET vAnio = '';
LET dFechaprocesar = '';
LET dfech_a_procesar2 = '';
LET vFecha_concilia = '';
LET vFecha_mov_cajero = '';
LET vFech_hora_movimiento = '';
LET vFecha_mov_cajero_2 = '';

--SET DEBUG FILE TO "/ifxsif01/ilopez/TXNS_CALCULAR_DIA_FALTANTE/sp_txns_atms_exitosas_dia_faltante.out";
--TRACE ON;

BEGIN

                ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
                IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
                                LET CCodret = iSqlErr;
                                LET CMENSAJE = vErrorInfo;
                                --insert into bditarjeta:"informix".td_bitacora_procesos (consecutivo,idproceso,fechahora,no_error,descripcion)
                                --VALUES(0,'01',current,CCodret,vErrorInfo);
                END IF;
                END EXCEPTION;


--- Obtiene la fecha del dia para generar el reporte ---

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

--Obtenemos dÃ­a de actual
--SELECT fecha_hoy INTO vfecha_hoy 
--FROM  bdinteg:"informix".si_fechas;

--/Fecha primer dÃ­a del Mes y DÃ­a Ãºltimo de Mes
LET dFecha_inicio_Mes = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
LET dFecha_inicio_Mes = dFecha_inicio_mes -1 UNITS MONTH;	
--LET dFecha_inicio_Mes = dFecha_inicio_mes -2 UNITS MONTH;	
LET dFecha_primer_dia = DAY(dFecha_inicio_Mes);

LET dFecha_fin_Mes = LPAD(MONTH(TODAY),2,0)||'/'||DAY(TODAY)||'/'||YEAR(TODAY);
LET dFecha_fin_Mes = dFecha_fin_Mes -1 UNITS MONTH;
--LET dFecha_fin_Mes = dFecha_fin_Mes -2 UNITS MONTH;
LET dFecha_fin_Mes = LPAD(MONTH(dFecha_fin_Mes),2,0)||'/'||DAY(LAST_DAY(dFecha_fin_Mes))||'/'||YEAR(dFecha_fin_Mes);
LET dFecha_ultimo_dia = DAY(dFecha_fin_Mes);

--10 REGISTROS
DROP TABLE IF EXISTS fechas_faltantes_txns_exitosas;

CREATE TABLE fechas_faltantes_txns_exitosas(

fech_faltante	DATE PRIMARY KEY
);

LET iDia=1;
-------------------------------------------------------------------- ENCONTRAMOS FECHAS FALTANTES -------------------------------------------------------------------------------
WHILE ( iDia <=dFecha_ultimo_dia ) LOOP
		
		LET vDia_falt = iDia;
		LET dFech_inicio_horamov = YEAR(dFecha_inicio_Mes) || '-' || LPAD ( MONTH(dFecha_inicio_Mes), 2,'0') || '-' ||
								LPAD (vDia_falt, 2,'0') || ' 00:00:00.00000';  
		
		
		
		LET dFech_fin_horamov = YEAR(dFecha_inicio_Mes) || '-' || LPAD ( MONTH(dFecha_inicio_Mes), 2,'0') || '-' ||
								LPAD (vDia_falt, 2,'0') || ' 23:59:59.00000';  
			
		SELECT COUNT(*)
		INTO iExisten_registros
		FROM bditarjeta:td_txns_atms_exitosas
		WHERE fechahoramov >= dFech_inicio_horamov 
		AND fechahoramov <= dFech_fin_horamov;
		
		IF iExisten_registros = 0 THEN 
			
			LET dfecha_faltante =  LPAD(MONTH(dFecha_inicio_Mes),2,0)||'/'||LPAD(vDia_falt,2,0)||'/'||YEAR(dFecha_inicio_Mes);
			LET dfecha_faltante = dfecha_faltante;
			
			--INSERTAMOS FECHA FALTANTE DE REGISTROS EN LA TABLA bditarjeta:td_txns_atms_exitosas
			INSERT INTO fechas_faltantes_txns_exitosas (fech_faltante) 
						VALUES(dfecha_faltante);
						
		
		END IF;

		
		LET iDia = iDia + 1 ;
		
END LOOP;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--////GENERAMOS LOS REGISTROS DEL DÃA FALTANTE EXCEPTO 25 DE DIC Y 01 ENERO //---------------------------------------------------------------------------------------------

--/CONTAMOS CUANTAS FECHAS HACEN FALTA POR PROCESAR--
SELECT COUNT(*)
INTO iNum_dias_falt
FROM  bditarjeta:fechas_faltantes_txns_exitosas;

--//SI NO EXISTEN FECHAS FALTANTES HACEMOS RETURN
IF iNum_dias_falt = 0 THEN			

LET cCodRet = '00000'; --NO HAY FECHAS POR ACTUALIZAR EN LA TABLA bditarjeta:td_txns_atms_exitosas
LET CMENSAJE='NO HAY FECHAS FALTANTES, PROCESO EXITOSO';


RETURN cCodRet,CMENSAJE;
END IF;

LET iNum_renglon = 0;

--//INICIO PARA GENERAR REGISTROS DE FECHA FALTANTE EN bditarjeta:td_txns_atms_exitosas---------------------------------------------------------------------------------------------------------------
WHILE ( iNum_renglon <= iNum_dias_falt - 1) LOOP
			
			SELECT SKIP iNum_renglon FIRST 1 fech_faltante 
			INTO dfech_a_procesar 
			FROM  bditarjeta:fechas_faltantes_txns_exitosas;
			
			--BUSCAMOS LA FECHA DEL MOVIMIENTO DE LA TARJETA
			LET dfech_a_procesar2 = SUBSTR(dfech_a_procesar,4,2)||'/'||SUBSTR(dfech_a_procesar,1,2)||'/'||SUBSTR(dfech_a_procesar,9,2);			
			
			SELECT  FIRST 1 fechaconciliacion ,fecha
			INTO vFecha_concilia,vFecha_mov_cajero --FORMATO DD/MM/AA
			FROM intercard:conciliacion_atm_stat06
			WHERE fecha = dfech_a_procesar2;			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
				LET cCodRet = '00020'; --NO HAY FECHA DE CONCILIACION EN LA TABLA intercard:conciliacion_atm_stat06
				LET CMENSAJE='NO HAY FECHA CONCILIACION EN LA TABLA conciliacion_atm_stat06';
				RETURN cCodRet,CMENSAJE;
			END IF; 
			
			LET vFecha_mov_cajero_2 = SUBSTR(vFecha_mov_cajero,4,2)||'/'||SUBSTR(vFecha_mov_cajero,1,2)||'/'||'20'||SUBSTR(vFecha_mov_cajero,7,2);			

			--//CREAMOS EL RANGO DE FECHA DE MOVIMIENTO EN EL CAJERO DEL DÃA FALTANTE
			LET vfecharep_inimov = SUBSTR(vFecha_mov_cajero_2,7,4)||'-'||SUBSTR(vFecha_mov_cajero_2,1,2)||'-'||SUBSTR(vFecha_mov_cajero_2,4,2) || ' 00:00:00';

			LET vfecharep_finmov = SUBSTR(vFecha_mov_cajero_2,7,4)||'-'||SUBSTR(vFecha_mov_cajero_2,1,2)||'-'||SUBSTR(vFecha_mov_cajero_2,4,2) || ' 23:59:59';

			
			--//CREAMOSEL REANGO DE FECHA DE CONCILIACIÃN 
			LET vfecharep_inistat= SUBSTRING(vFecha_concilia FROM  1 FOR 10) || ' 00:00:00';
			---vfecharep_inistat='2016-11-15 00:00:00'

			LET vfecharep_finstat = SUBSTRING(vFecha_concilia FROM  1 FOR 10) || ' 23:59:59';
			
			LET vanohoy = RIGHT(vFecha_mov_cajero_2,2);
			LET vmeshoy = LEFT(vFecha_mov_cajero_2,2);
			LET vdiahoy = SUBSTR(vFecha_mov_cajero_2,4,2);

			--LET vanohoy = RIGHT(vanohoy,2);
			LET vfecharephoy = vdiahoy||'/'||vmeshoy||'/'||vanohoy; --> Fecha en formato DD/MM/AA
			LET vmesdia = vmeshoy || vdiahoy;  

			
			SELECT COUNT(*) INTO vcontadortxnexi from bditarjeta:"informix".td_txns_atms_exitosas where fechahoramov between vfecharep_inimov and vfecharep_finmov;

			IF	(vcontadortxnexi > 0) THEN

			FOREACH WITH HOLD 

			SELECT FIRST 1 fechahoramov INTO vfechadelete from bditarjeta:"informix".td_txns_atms_exitosas where fechahoramov between vfecharep_inimov and vfecharep_finmov

			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION	
			IF (vsFlagEnTransaccionFor = 'F') THEN
				BEGIN WORK;
				LET vsFlagEnTransaccionFor = 'V';
			END IF;
			--BORRADO DEL DÃA A PROCESAR --SEQUENTIAL SCAN
			DELETE bditarjeta:"informix".td_txns_atms_exitosas 
			WHERE fechahoramov between vfecharep_inimov and vfecharep_finmov; 

			LET vContadorDelete = vContadorDelete + 1;

			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vContadorDelete = 500) THEN --VERIFICA SI ALCANZO EL MAXIMO DE TRANSACCIONES POR BLOQUE
					COMMIT WORK;
					LET vsFlagEnTransaccionFor = 'F';
					LET vContadorDelete = 0;
					CONTINUE FOREACH;
			END IF;

			END FOREACH;

			IF ((vContadorDelete > 0) OR (vsFlagEnTransaccionFor = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
					COMMIT WORK;
					LET vsFlagEnTransaccionFor = 'F';
			END IF;
				
			END IF;

			--- Valida que no existan las siguientes tablas temporales--- 
			DROP TABLE IF EXISTS movimientoist;
			
			DROP TABLE IF EXISTS td_sus_en_mis_exi;			
			
			DROP TABLE IF EXISTS td_sus_en_mis_exi2;
			
			DROP TABLE IF EXISTS reversossusenmis;
			
			DROP TABLE IF EXISTS revparist;
		
			DROP TABLE IF EXISTS revpar_movimientoist;
			

			--- Obtiene las transacciones exitosas del dÃÂ­a, de la tabla 'Movimiento' a la tabla 'movimientoist' ---

			let vpaso= 1;

			SELECT * FROM intercard:movimiento mv
			where mv.fechahorainauth BETWEEN vfecharep_inimov AND vfecharep_finmov
			--mv.fechahorainauth between '2017-11-17 00:00:00' and '2017-11-17 23:59:59'
			and mv.codigoiso = '00'
			and mv.codtran in ('31','01')
			and mv.horalocaltransaccion BETWEEN '000000' AND '235959'
			and mv.prodind = '01'
			and mv.movreversado = 'F'
			and mv.formato in ('0200')
			and mv.codreversa in ('0')
			INTO temp movimientoist WITH NO LOG;
			CREATE INDEX idxtmp_movimientoist ON movimientoist(fechahorainauth) USING BTREE;
			CREATE INDEX idxtmp_movimientoist_2 ON movimientoist(numtarjeta) USING BTREE;
			UPDATE STATISTICS MEDIUM FOR TABLE movimientoist;
			--- Obtiene las transacciones exitosas del dÃÂ­a que cuenten con reversos parciales, de la tabla 'Movimiento' a la tabla 'revpar_movimientoist' ---

			let vpaso= 2;

			select * from intercard:movimiento mv
			where mv.fechahorainauth BETWEEN vfecharep_inimov AND vfecharep_finmov
			--mv.fechahorainauth between '2017-11-17 00:00:00' and '2017-11-17 23:59:59'
			and codigoiso = '00'
			and codtran in ('31','01')
			--and mv.fechalocaltransaccion = vmesdia
			and mv.horalocaltransaccion BETWEEN '000000' AND '235959'
			and prodind = '01'
			and formato = '0420'
			and codreversa = '2'
			INTO temp revpar_movimientoist WITH NO LOG;
			CREATE INDEX idxtmp_revpar_movimientoist ON revpar_movimientoist(fechahorainauth) USING BTREE;
			CREATE INDEX idxtmp_revpar_movimientoist_2 ON revpar_movimientoist(numtarjeta) USING BTREE;
			UPDATE STATISTICS MEDIUM FOR TABLE revpar_movimientoist;

			--- Obtiene e inserta en la tabla 'td_txns_atms_exitosas' las transacciones exitosas del dÃÂ­a entre las tablas 'movimientoist' y 'conciliacion_atm_stat06' del tipo 'MIS en MIS' Y 'MIS en SUS' ('IST') ---
			----------INSERT 1 

			let vpaso= 3;

			FOREACH CURSOR1 WITH HOLD FOR

			select-- count(*)
			0, con.fechaconciliacion as fechaproceso,mv.fechahorainauth as fechahoramov,mv.secuencia,mv.numtarjeta as numtarjetamovi,con.numtarjeta as numtarjetastat06,
			SUBSTR (mv.numtarjeta,0,6) AS BIN,trim(mv.idterminal),
			case
			 WHEN transaccionorigen='0010'  THEN "MM"
			 WHEN transaccionorigen='1234'  and trancajeropropio = 'V' and esnacional ='V'  THEN "MM"
			 WHEN transaccionorigen='1234'  and trancajeropropio = 'F' and esnacional ='V'  THEN "MS"
			 WHEN transaccionorigen='1234'  and trancajeropropio = 'F' and esnacional ='F'  THEN "MS"
			ELSE ''
			END AS tipotran,
			mv.codtran,
			mv.esnacional,
			mv.transaccionorigen,
			mv.idreceptor,
			mv.codreversa,
			case
			WHEN movconciliado ='F' THEN "V"
			ELSE "V"
			END AS movconciliado,
			mv.movreversado,
			mv.trancajeropropio,
			mv.formato,
			con.archivoorigen,
			case
			 WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT BIN FROM INTERCARD:BINES WHERE creditodebito ='C') THEN "C"
			 WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT BIN FROM INTERCARD:BINES WHERE creditodebito ='D') THEN "D"
			ELSE ''
			END AS creditodebito,
			case
			 WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='D' and MARCA ='MC') THEN "M"
			 WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='D' and MARCA ='VS') THEN "V"
			 WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='C' and MARCA ='MC') THEN "M"
			 WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='C' and MARCA ='VS') THEN "V"
			ELSE ''
			END AS marca,mv.monto,mv.montorealrevfzda,mv.montosurcharge,mv.montocomision,con.red

			INTO vconsecutivo, vfechaproceso, vfechahoramov, vsecuenciaFor, vnumtarjetamovi, vnumtarjetastat06, vbin,vidterminal, vtipotran, vcodtran, vesnacional, vtransaccionorigen, vidreceptor, vcodreversa, vmovconciliado,vmovreversado,vtrancajeropropio,vformato,varchivoorigen,vcreditodebito,
			vmarca,vmonto,vmontorealrevfzda,vmontosurcharge,vmontocomision,vinternacional
			from  intercard:movimientoist mv,intercard:conciliacion_atm_stat06 con
			where mv.fechahorainauth between vfecharep_inimov and vfecharep_finmov
			--where mv.fechahorainauth BETWEEN vfecharep_inimov AND vfecharep_finmov
			and mv.prodind='01'
			and  mv.numtarjeta =con.numtarjeta
			and SUBSTR (mv.secuencia,2,7)=con.autorizacion
			and mv.idterminal=con.numcajero
			and con.archivoorigen in ('IST')
			--and con.fecha = '05/05/21'
			and con.fechaconciliacion BETWEEN vfecharep_inistat and vfecharep_finstat  
			--and con.fechaconciliacion between vfecharep_inistat and vfecharep_finstat
			and con.indicadordereversa =''
			and mv.codigoiso='00'
			and mv.codreversa ='0'
			and mv.formato='0200'
			and mv.codigoiso='00'
			and mv.transaccionorigen='0010'
			order by mv.numtarjeta

			INSERT INTO bditarjeta:"informix".td_txns_atms_exitosas(consecutivo, fechaproceso, fechahoramov, secuencia, numtarjetamovi, numtarjetastat06, bin,idterminal, tipotran, codtran, esnacional, transaccionorigen, idreceptor, codreversa,movconciliado,movreversado,trancajeropropio,formato,archivoorigen,creditodebito,
			marca,monto,montorealrevfzda,montosurcharge,montocomision,internacional) VALUES (vconsecutivo, vfechaproceso, vfechahoramov, vsecuenciaFor, vnumtarjetamovi, vnumtarjetastat06, vbin,vidterminal, vtipotran, vcodtran, vesnacional, vtransaccionorigen, vidreceptor, vcodreversa, vmovconciliado,vmovreversado,vtrancajeropropio,vformato,varchivoorigen,vcreditodebito,
			vmarca,vmonto,vmontorealrevfzda,vmontosurcharge,vmontocomision,vinternacional);

			--- Obtiene e inserta en la tabla 'td_txns_atms_exitosas' las transacciones exitosas del dÃÂ­a entre las tablas 'movimientoist' y 'td_movimientos_conciliacion' del tipo 'MIS en MIS' Y 'MIS en SUS' ('TMC','TMD') ---


				IF (vsFlagEnTransaccionFor = 'F') THEN
					 BEGIN WORK;
					 LET vsFlagEnTransaccionFor = 'V';
				END IF;	 

				LET viContadorRegistros = viContadorRegistros + 1;

				--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
				   IF (viContadorRegistros = 500) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
					COMMIT WORK;
					LET vsFlagEnTransaccionFor = 'F';
					LET viContadorRegistros = 0;
					CONTINUE FOREACH;
				   END IF;
				   
			 END FOREACH;
				 
				   -- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
				IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccionFor = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
					COMMIT WORK;
					LET vsFlagEnTransaccionFor = 'F';
				END IF;

			LET vsFlagEnTransaccionFor = 'F';
			LET viContadorRegistros = 0;
			LET vconsecutivo = 0;
			LET vsecuencia ='';
			LET vnumtarjetamovi='';
			LET vnumtarjetastat06= '';
			LET vbin='';
			LET vidterminal='';
			LET vtipotran='';
			LET vcodtran='';
			LET vesnacional='';
			LET vtransaccionorigen='';
			LET vidreceptor='';
			LET vcodreversa='';
			LET vmovconciliado='';
			LET vmovreversado='';
			LET vtrancajeropropio='';
			LET vformato='';
			LET varchivoorigen='';
			LET vcreditodebito='';
			LET vmarca='';
			LET vmonto=0;
			LET vmontorealrevfzda=0;
			LET vmontosurcharge=0;
			LET vmontocomision=0;
			LET vinternacional='';

			----------INSERT 2 

			let vpaso= 4;


			FOREACH CURSOR2 WITH HOLD FOR


			select 0, con.fechacarga as fechaproceso,mv.fechahorainauth as fechahoramov,mv.secuencia,mv.numtarjeta as numtarjetamovi,con.numtarjeta as numtarjetastat06,
			SUBSTR (mv.numtarjeta,0,6) AS BIN,trim(mv.idterminal),
			case
			 WHEN transaccionorigen='1234'  and trancajeropropio = 'V' and esnacional ='V'  THEN "MM"
			 WHEN transaccionorigen='1234'  and trancajeropropio = 'F' and esnacional ='V'  THEN "MS"
			 WHEN transaccionorigen='1234'  and trancajeropropio = 'F' and esnacional ='F'  THEN "MS"
			ELSE ''
			END AS tipotran,
			mv.codtran,
			mv.esnacional,
			mv.transaccionorigen,
			mv.idreceptor,
			mv.codreversa,
			mv.movconciliado,
			mv.movreversado,
			mv.trancajeropropio,
			mv.formato,
			con.archivo_origen,
			case
			 WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT BIN FROM INTERCARD:BINES WHERE creditodebito ='C') THEN "C"
			 WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT BIN FROM INTERCARD:BINES WHERE creditodebito ='D') THEN "D"
			ELSE ''
			END AS creditodebito,
			case
			 WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='D' and MARCA ='MC') THEN "M"
			 WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='D' and MARCA ='VS') THEN "V"
			 WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='C' and MARCA ='MC') THEN "M"
			 WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='C' and MARCA ='VS') THEN "V"
			ELSE ''
			END AS marca,mv.monto,mv.montorealrevfzda,mv.montosurcharge,mv.montocomision,'EGLOBAL'

			INTO vconsecutivo, vfechaproceso, vfechahoramov, vsecuenciaFor, vnumtarjetamovi, vnumtarjetastat06, vbin,vidterminal, vtipotran, vcodtran, vesnacional, vtransaccionorigen, vidreceptor, vcodreversa, vmovconciliado,vmovreversado,vtrancajeropropio,vformato,varchivoorigen,vcreditodebito,
			vmarca,vmonto,vmontorealrevfzda,vmontosurcharge,vmontocomision,vinternacional

			from  intercard:movimientoist mv,bditarjeta:td_movimientos_conciliacion con
			--where mv.fechahorainauth between '2016-11-15 00:00:00' and '2016-11-15 23:59:59'
			where mv.fechahorainauth between vfecharep_inimov and vfecharep_finmov
			and mv.prodind='01'
			and  mv.numtarjeta =con.numtarjeta
			and SUBSTR (mv.secuencia,2,7)=con.secuencia325
			and mv.idterminal=con.idterminal
			and con.archivo_origen in ('TMC','TMD')
			and con.fechatransaccion BETWEEN vfecharep_inistat and vfecharep_finstat
			--and mv.fechahorainauth between '2021-05-06 00:00:00' and '2021-05-06 23:59:59'
			and mv.codigoiso='00'
			and mv.codreversa ='0'
			and mv.formato='0200'
			and mv.codigoiso='00'
			and con.iso323='00'
			and mv.transaccionorigen='1234'
			AND con.movrev325='F'
			order by mv.numtarjeta

			INSERT INTO bditarjeta:"informix".td_txns_atms_exitosas(consecutivo, fechaproceso, fechahoramov, secuencia, numtarjetamovi, numtarjetastat06, bin,idterminal, tipotran, codtran, esnacional, transaccionorigen, idreceptor, codreversa,movconciliado,movreversado,trancajeropropio,formato,archivoorigen,creditodebito,
			marca,monto,montorealrevfzda,montosurcharge,montocomision,internacional) VALUES (vconsecutivo, vfechaproceso, vfechahoramov, vsecuenciaFor, vnumtarjetamovi, vnumtarjetastat06, vbin,vidterminal, vtipotran, vcodtran, vesnacional, vtransaccionorigen, vidreceptor, vcodreversa, vmovconciliado,vmovreversado,vtrancajeropropio,vformato,varchivoorigen,vcreditodebito,
			vmarca,vmonto,vmontorealrevfzda,vmontosurcharge,vmontocomision,vinternacional);
			--- Obtiene e inserta en la tabla 'td_txns_atms_exitosas' las transacciones exitosas del dÃÂ­a con reversos parciales entre las tablas 'movimientoist' y 'td_movimientos_conciliacion' del tipo 'MIS en MIS' Y 'MIS en SUS' ('TMC','TMD') ---
			
				IF (vsFlagEnTransaccionFor = 'F') THEN
					 BEGIN WORK;
					 LET vsFlagEnTransaccionFor = 'V';
				END IF;	 

				LET viContadorRegistros = viContadorRegistros + 1;

				--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
				   IF (viContadorRegistros = 500) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
					COMMIT WORK;
					LET vsFlagEnTransaccionFor = 'F';
					LET viContadorRegistros = 0;
					CONTINUE FOREACH;
				   END IF;
				   
			 END FOREACH;
				 
				   -- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
				IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccionFor = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
					COMMIT WORK;
					LET vsFlagEnTransaccionFor = 'F';
				END IF;

			LET vsFlagEnTransaccionFor = 'F';
			LET viContadorRegistros = 0;
			LET vconsecutivo = 0;
			LET vsecuencia ='';
			LET vnumtarjetamovi='';
			LET vnumtarjetastat06= '';
			LET vbin='';
			LET vidterminal='';
			LET vtipotran='';
			LET vcodtran='';
			LET vesnacional='';
			LET vtransaccionorigen='';
			LET vidreceptor='';
			LET vcodreversa='';
			LET vmovconciliado='';
			LET vmovreversado='';
			LET vtrancajeropropio='';
			LET vformato='';
			LET varchivoorigen='';
			LET vcreditodebito='';
			LET vmarca='';
			LET vmonto=0;
			LET vmontorealrevfzda=0;
			LET vmontosurcharge=0;
			LET vmontocomision=0;
			LET vinternacional='';

			----------FIN 

			----------INSERT 3 

			let vpaso= 5;

			FOREACH CURSOR3 WITH HOLD FOR

			select 0, con.fechacarga as fechaproceso,mv.fechahorainauth as fechahoramov,mv.secuencia,mv.numtarjeta as numtarjetamovi,con.numtarjeta as numtarjetastat06,
			SUBSTR (mv.numtarjeta,0,6) AS BIN,trim(mv.idterminal),
			case
			 WHEN transaccionorigen='1234'  and trancajeropropio = 'V' and esnacional ='V'  THEN "MM"
			 WHEN transaccionorigen='1234'  and trancajeropropio = 'F' and esnacional ='V'  THEN "MS"
			 WHEN transaccionorigen='1234'  and trancajeropropio = 'F' and esnacional ='F'  THEN "MS"
			ELSE ''
			END AS tipotran,
			mv.codtran,
			mv.esnacional,
			mv.transaccionorigen,
			mv.idreceptor,
			mv.codreversa,
			con.movconciliado,
			mv.movreversado,
			mv.trancajeropropio,
			mv.formato,
			con.archivo_origen,
			case
			 WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT BIN FROM INTERCARD:BINES WHERE creditodebito ='C') THEN "C"
			 WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT BIN FROM INTERCARD:BINES WHERE creditodebito ='D') THEN "D"
			ELSE ''
			END AS creditodebito,
			case
			 WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='D' and MARCA ='MC') THEN "M"
			 WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='D' and MARCA ='VS') THEN "V"
			 WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='C' and MARCA ='MC') THEN "M"
			 WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='C' and MARCA ='VS') THEN "V"
			ELSE ''
			END AS marca,montorealrevfzda as monto,'0' as montorealrevfzda,mv.montosurcharge,mv.montocomision,'EGLOBAL'

			INTO vconsecutivo, vfechaproceso, vfechahoramov, vsecuenciaFor, vnumtarjetamovi, vnumtarjetastat06, vbin,vidterminal, vtipotran, vcodtran, vesnacional, vtransaccionorigen, vidreceptor, vcodreversa, vmovconciliado,vmovreversado,vtrancajeropropio,vformato,varchivoorigen,vcreditodebito,
			vmarca,vmonto,vmontorealrevfzda,vmontosurcharge,vmontocomision,vinternacional

			from  intercard:revpar_movimientoist mv, bditarjeta:td_movimientos_conciliacion con
			where mv.fechahorainauth between vfecharep_inimov and vfecharep_finmov
			--where mv.fechahorainauth BETWEEN 2021-10-16 00:00:00.00000 AND 2021-10-16 23:59:59.00000
			and mv.prodind='01'
			and con.fechatransaccion BETWEEN vfecharep_inimov AND vfecharep_finmov
			--and con.fechacarga between '2016-11-16 00:00:00' and '2016-11-16 23:59:59'
			and  mv.numtarjeta =con.numtarjeta
			and SUBSTR (mv.secuenciaorig,2,7)=con.secuencia325--Se modifica para encontrar la operaciÃÂ³n original UJAA
			and mv.idterminal=con.idterminal--Se modifica para encontrar la operaciÃÂ³n original UJAA
			and desc_conciliacion like 'ATM reversa parcial                                         %'
			and con.archivo_origen in ('TMC','TMD')
			and con.movrev325='P'--Verifica si es un reverso parcial en la tabla bditarjeta:td_movimientos_conciliacion con
			and mv.codigoiso='00'
			and mv.codreversa ='2'
			and mv.formato='0420'
			and mv.codigoiso='00'
			and mv.transaccionorigen='1234'
			order by mv.numtarjeta

			INSERT INTO bditarjeta:"informix".td_txns_atms_exitosas(consecutivo, fechaproceso, fechahoramov, secuencia, numtarjetamovi, numtarjetastat06, bin,idterminal, tipotran, codtran, esnacional, transaccionorigen, idreceptor, codreversa,movconciliado,movreversado,trancajeropropio,formato,archivoorigen,creditodebito,
			marca,monto,montorealrevfzda,montosurcharge,montocomision,internacional)VALUES (vconsecutivo, vfechaproceso, vfechahoramov, vsecuenciaFor, vnumtarjetamovi, vnumtarjetastat06, vbin,vidterminal, vtipotran, vcodtran, vesnacional, vtransaccionorigen, vidreceptor, vcodreversa, vmovconciliado,vmovreversado,vtrancajeropropio,vformato,varchivoorigen,vcreditodebito,
			vmarca,vmonto,vmontorealrevfzda,vmontosurcharge,vmontocomision,vinternacional);
			--- Obtiene e inserta en la tabla 'td_txns_atms_exitosas' las transacciones exitosas del dÃÂ­a con reversos parciales entre las tablas 'movimientoist' y 'td_movimientos_conciliacion' del tipo 'MIS en MIS' Y 'MIS en SUS' ('TMC','TMD') ---

				IF (vsFlagEnTransaccionFor = 'F') THEN
					 BEGIN WORK;
					 LET vsFlagEnTransaccionFor = 'V';
				END IF;	 

				LET viContadorRegistros = viContadorRegistros + 1;

				--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
				   IF (viContadorRegistros = 500) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
					COMMIT WORK;
					LET vsFlagEnTransaccionFor = 'F';
					LET viContadorRegistros = 0;
					CONTINUE FOREACH;
				   END IF;
				   
			 END FOREACH;
				 
				   -- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
				IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccionFor = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
					COMMIT WORK;
					LET vsFlagEnTransaccionFor = 'F';
				END IF;

			LET vsFlagEnTransaccionFor = 'F';
			LET viContadorRegistros = 0;
			LET vconsecutivo = 0;
			LET vsecuencia ='';
			LET vnumtarjetamovi='';
			LET vnumtarjetastat06= '';
			LET vbin='';
			LET vidterminal='';
			LET vtipotran='';
			LET vcodtran='';
			LET vesnacional='';
			LET vtransaccionorigen='';
			LET vidreceptor='';
			LET vcodreversa='';
			LET vmovconciliado='';
			LET vmovreversado='';
			LET vtrancajeropropio='';
			LET vformato='';
			LET varchivoorigen='';
			LET vcreditodebito='';
			LET vmarca='';
			LET vmonto=0;
			LET vmontorealrevfzda=0;
			LET vmontosurcharge=0;
			LET vmontocomision=0;
			LET vinternacional='';


			--- Obtiene las transacciones exitosas del dÃÂ­a sin reversos, de la tabla 'conciliacion_atm_stat06' a la tabla 'td_sus_en_mis_exi' del tipo 'SUS en MIS' ---
			----------FIN INSERT 3 

			let vpaso= 6;

			SELECT * from intercard:conciliacion_atm_stat06 con
			WHERE  fechaconciliacion between vfecharep_inistat and vfecharep_finstat
			--and con.fecha = '29/09/21'
			AND con.fecha = vfecharephoy	
			AND compania IN ('BNC','BND')
			--and archivoorigen in ('TMO','IST')
			AND archivoorigen in ('IST')
			AND codigoiso in ('00','01')
			AND (indicadordereversa <>'REVERSAL'
			AND indicadordereversa <> 'REVERSAL          P')
			INTO temp td_sus_en_mis_exi  WITH NO LOG;
			CREATE INDEX informix.td_sus_en_mis_exi_01 ON informix.td_sus_en_mis_exi(numtarjeta);
			CREATE INDEX informix.td_sus_en_mis_exi_02	ON informix.td_sus_en_mis_exi(numtarjeta, codigoiso, respuesta);
			CREATE INDEX informix.td_sus_en_mis_exi_04	ON informix.td_sus_en_mis_exi(numcuenta);
			CREATE INDEX informix.td_sus_en_mis_exi_03	ON informix.td_sus_en_mis_exi(fechaconciliacion, keyx);
			CREATE INDEX informix.td_sus_en_mis_exi_05	ON informix.td_sus_en_mis_exi(indicadordereversa);
			UPDATE STATISTICS MEDIUM FOR TABLE td_sus_en_mis_exi;

			--- Obtiene las transacciones exitosas del dÃÂ­a, de la tabla 'conciliacion_atm_stat06' a la tabla 'td_sus_en_mis_exi2' del tipo 'SUS en MIS' ---

			let vpaso= 7;

			SELECT * from intercard:conciliacion_atm_stat06 con
			WHERE  fechaconciliacion between vfecharep_inistat and vfecharep_finstat
			AND con.fecha = vfecharephoy
			AND compania IN ('BNC','BND')
			AND archivoorigen in ('IST')
			AND codigoiso in ('00','01')
			INTO temp td_sus_en_mis_exi2  WITH NO LOG;
			CREATE INDEX informix.td_sus_en_mis_exi2_01 ON informix.td_sus_en_mis_exi2(numtarjeta);
			CREATE INDEX informix.td_sus_en_mis_exi2_02	ON informix.td_sus_en_mis_exi2(numtarjeta, codigoiso, respuesta);
			CREATE INDEX informix.td_sus_en_mis_exi2_04	ON informix.td_sus_en_mis_exi2(numcuenta);
			CREATE INDEX informix.td_sus_en_mis_exi2_03	ON informix.td_sus_en_mis_exi2(fechaconciliacion, keyx);
			CREATE INDEX informix.td_sus_en_mis_exi2_05	ON informix.td_sus_en_mis_exi2(indicadordereversa);
			UPDATE STATISTICS MEDIUM FOR TABLE td_sus_en_mis_exi2;

			--- Obtiene las transacciones exitosas del dÃÂ­a con reversos parciales y totales, de la tabla 'conciliacion_atm_stat06' a la tabla 'reversossusenmis' del tipo 'SUS en MIS' ---

			let vpaso= 8;

			SELECT *  from intercard:conciliacion_atm_stat06 con
			where  fechaconciliacion between vfecharep_inistat and vfecharep_finstat
			AND con.fecha = vfecharephoy 	
			AND compania IN ('BNC','BND')
			AND archivoorigen in ('IST')
			AND (trim(indicadordereversa)= 'REVERSAL          P'
			OR trim(indicadordereversa)= 'REVERSAL')
			AND codigoiso in ('00','01')
			INTO temp reversossusenmis  WITH NO LOG;
			CREATE INDEX informix.reversossusenmis_01 ON informix.reversossusenmis(numtarjeta);
			CREATE INDEX informix.reversossusenmis_02	ON informix.reversossusenmis(numtarjeta, codigoiso, respuesta);
			CREATE INDEX informix.reversossusenmis_04	ON informix.reversossusenmis(numcuenta);
			CREATE INDEX informix.reversossusenmis_03	ON informix.reversossusenmis(fechaconciliacion, keyx);
			CREATE INDEX informix.reversossusenmis_05	ON informix.reversossusenmis(indicadordereversa);
			UPDATE STATISTICS MEDIUM FOR TABLE reversossusenmis;


			--- Borra las trancciones con reversos totales de la tabla 'td_sus_en_mis_exi' provenientes del IST ---

			LET vpaso= 9;

			delete from intercard:td_sus_en_mis_exi
			where autorizacion in ((select a.autorizacion from intercard:reversossusenmis a ,intercard:td_sus_en_mis_exi b
			where a.autorizacion=b.autorizacion
			and   a.numtarjeta = b.numtarjeta
			and   a.secuencia=b.secuencia
			and   a.fecha=b.fecha
			and  a.archivoorigen=b.archivoorigen
			and a.monto=b.monto
			and a.emisor=b.emisor
			and b.archivoorigen='IST'
			and trim(a.indicadordereversa) ='REVERSAL'))
			and numtarjeta in ((select a.numtarjeta
			from intercard:reversossusenmis a ,intercard:td_sus_en_mis_exi b
			where a.autorizacion=b.autorizacion
			and   a.numtarjeta = b.numtarjeta
			and   a.secuencia=b.secuencia
			and   a.fecha=b.fecha
			and  a.archivoorigen=b.archivoorigen
			and a.monto=b.monto
			and a.emisor=b.emisor
			and b.archivoorigen='IST'
			and trim(a.indicadordereversa) ='REVERSAL'))
			and archivoorigen='IST';

			--- Borra las trancciones con reversos parciales de la tabla 'td_sus_en_mis_exi' provenientes del IST

			let vpaso= 10;

			delete from intercard:td_sus_en_mis_exi
			where autorizacion in ((select a.autorizacion from intercard:reversossusenmis a ,intercard:td_sus_en_mis_exi2 b
			where a.autorizacion=b.autorizacion
			and   a.numtarjeta = b.numtarjeta
			and   a.secuencia=b.secuencia
			and   a.fecha=b.fecha
			and  a.archivoorigen=b.archivoorigen
			and a.monto=b.monto
			and a.emisor=b.emisor
			and b.archivoorigen='IST'
			and trim(a.indicadordereversa) ='REVERSAL          P'))
			and numtarjeta in ((select a.numtarjeta
			from intercard:reversossusenmis a ,intercard:td_sus_en_mis_exi2 b
			where a.autorizacion=b.autorizacion
			and   a.numtarjeta = b.numtarjeta
			and   a.secuencia=b.secuencia
			and   a.fecha=b.fecha
			and  a.archivoorigen=b.archivoorigen
			and a.monto=b.monto
			and a.emisor=b.emisor
			and b.archivoorigen='IST'
			and trim(a.indicadordereversa) ='REVERSAL          P'))
			and archivoorigen='IST';

			let vpaso= 11;

			--- Obtiene las trancciones reversos parciales provenientes del IST ---
			select
			con2.keyx,con2.fechaconciliacion,con2.archivoorigen,con2.nombrearchivo,con2.emisor,con2.numcajero,con2.numtarjeta,
			con2.numcuenta,con2.indicadordereversa,con2.descripcion,con2.respuesta,con2.codigoiso,con2.secuencia,con2.fecha,con2.hora,con2.orden,con2.red,
			(con1.monto-con2.monto-con1.comisionsurcharge) as monto,con2.dolares,con2.comisionsurcharge,
			con2.donativo,con2.emp,con2.autorizacion,con2.compania,con2.comision_loyaltyfee,con2.comision_usolinea,
			con2.pos_entry_mode,con2.service_code,con2.terminal_capability,con2.arqc,con2.arpc,con2.arqc_verify
			from intercard:td_sus_en_mis_exi2 con1 ,intercard:reversossusenmis con2
			where con1.autorizacion=con2.autorizacion
			and con1.fechaconciliacion=con2.fechaconciliacion
			and con1.archivoorigen in ('IST')
			and con2.archivoorigen in ('IST')
			and con1.codigoiso in ('00','01')
			and con2.codigoiso in ('00','01')
			and trim(con2.indicadordereversa)= 'REVERSAL          P'
			INTO temp revparist  WITH NO LOG;
			CREATE INDEX informix.revparist_01 ON informix.revparist(numtarjeta);
			CREATE INDEX informix.revparist_02	ON informix.revparist(numtarjeta, codigoiso, respuesta);
			CREATE INDEX informix.revparist_04	ON informix.revparist(numcuenta);
			CREATE INDEX informix.revparist_03	ON informix.revparist(fechaconciliacion, keyx);
			CREATE INDEX informix.revparist_05	ON informix.revparist(indicadordereversa);
			UPDATE STATISTICS MEDIUM FOR TABLE revparist;

			let vpaso= 12;
			--- Obtiene e inserta las transacciones exitosas del dÃÂ­a con reversos parciales del IST, de la tabla 'revparist' a la tabla 'td_txns_atms_exitosas' ---

			FOREACH CURSOR4 WITH HOLD FOR

			select 0, fechaconciliacion as fechaproceso,substr(to_DATE (fecha ,'%d/%m/%y'),0,11)||hora||'.00000' as fechahoramov,autorizacion as secuencia,'' as numtarjetamovi,numtarjeta as numtarjetastat06,SUBSTR (numtarjeta,0,6) AS BIN,trim(numcajero) as idterminal,'SM' as tipotran,
			case
			WHEN descripcion like 'CONSULTA%' AND monto = '0' THEN "31"
			WHEN descripcion like 'CONSULTA%' AND monto = '8' THEN "02"
			WHEN descripcion like 'CONSULTA%' AND monto = '5' THEN "02"
			ELSE "01"
			END as codtran,
			case
			 WHEN emisor in ('VISA','MDS') THEN "F"
			ELSE "V"
			END AS esnacional,
			'0010' as transaccionorigen,'' as idreceptor, '2' as codreversa, 'V' as movconciliado, 'F' as movreversado,'V' as trancajeropropio,'0420' as formato,archivoorigen,
			case
			 WHEN SUBSTR (numtarjeta,0,6) IN (SELECT BIN FROM BDICHEQ:SC_BINES WHERE creditodebito ='c') THEN "C"
			 WHEN SUBSTR (numtarjeta,0,6) IN (SELECT BIN FROM BDICHEQ:SC_BINES WHERE creditodebito ='d') THEN "D"
				 ---RQI 15 060 ModificaciÃ³n al  calculo de retiros exitosos en cajeros-----
			 WHEN p.compania ='BND' THEN "D"
			 WHEN p.compania ='BNC' THEN "C"
			ELSE ''
			END AS creditodebito,
			case
			 WHEN SUBSTR (p.numtarjeta,0,1) IN  (SELECT SUBSTR (bin,0,1) FROM bdicheq:sc_bines WHERE creditodebito ='d' and SUBSTR (bin,0,1) ='4') THEN "V"
			 WHEN SUBSTR (p.numtarjeta,0,1) IN  (SELECT SUBSTR (bin,0,1) FROM bdicheq:sc_bines WHERE creditodebito ='c' and SUBSTR (bin,0,1) ='4') THEN "V"
			 WHEN SUBSTR (p.numtarjeta,0,1) IN  (SELECT SUBSTR (bin,0,1) FROM bdicheq:sc_bines WHERE creditodebito ='d' and SUBSTR (bin,0,1) ='5') THEN "M"
			 WHEN SUBSTR (p.numtarjeta,0,1) IN  (SELECT SUBSTR (bin,0,1) FROM bdicheq:sc_bines WHERE creditodebito ='c' and SUBSTR (bin,0,1) ='5') THEN "M"
			ELSE ''
			END AS marca,monto as monto,'0' as montorealrevfzda,comisionsurcharge as montosurcharge,'0' as montocomision,red

			INTO vconsecutivo, vfechaproceso, vfechahoramov, vsecuenciaFor, vnumtarjetamovi, vnumtarjetastat06, vbin,vidterminal, vtipotran, vcodtran, vesnacional, vtransaccionorigen, vidreceptor, vcodreversa, vmovconciliado,vmovreversado,vtrancajeropropio,vformato,varchivoorigen,vcreditodebito,
			vmarca,vmonto,vmontorealrevfzda,vmontosurcharge,vmontocomision,vinternacional

			from intercard:revparist p 

			INSERT INTO bditarjeta:"informix".td_txns_atms_exitosas(consecutivo, fechaproceso, fechahoramov, secuencia, numtarjetamovi, numtarjetastat06, bin,idterminal, tipotran, codtran, esnacional,
			transaccionorigen, idreceptor, codreversa,movconciliado,movreversado,trancajeropropio,formato,archivoorigen,creditodebito,marca,monto,montorealrevfzda,montosurcharge,montocomision,internacional)
			VALUES (vconsecutivo, vfechaproceso, vfechahoramov, vsecuenciaFor, vnumtarjetamovi, vnumtarjetastat06, vbin,vidterminal, vtipotran, vcodtran, vesnacional, vtransaccionorigen, vidreceptor, vcodreversa, vmovconciliado,vmovreversado,vtrancajeropropio,vformato,varchivoorigen,vcreditodebito,
			vmarca,vmonto,vmontorealrevfzda,vmontosurcharge,vmontocomision,vinternacional);

			IF (vsFlagEnTransaccionFor = 'F') THEN
					 BEGIN WORK;
					 LET vsFlagEnTransaccionFor = 'V';
				END IF;	 

				LET viContadorRegistros = viContadorRegistros + 1;

				--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
				   IF (viContadorRegistros = 500) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
					COMMIT WORK;
					LET vsFlagEnTransaccionFor = 'F';
					LET viContadorRegistros = 0;
					CONTINUE FOREACH;
				   END IF;
				   
			 END FOREACH;
				 
				   -- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
				IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccionFor = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
					COMMIT WORK;
					LET vsFlagEnTransaccionFor = 'F';
				END IF;

			LET vsFlagEnTransaccionFor = 'F';
			LET viContadorRegistros = 0;
			LET vconsecutivo = 0;
			LET vsecuencia ='';
			LET vnumtarjetamovi='';
			LET vnumtarjetastat06= '';
			LET vbin='';
			LET vidterminal='';
			LET vtipotran='';
			LET vcodtran='';
			LET vesnacional='';
			LET vtransaccionorigen='';
			LET vidreceptor='';
			LET vcodreversa='';
			LET vmovconciliado='';
			LET vmovreversado='';
			LET vtrancajeropropio='';
			LET vformato='';
			LET varchivoorigen='';
			LET vcreditodebito='';
			LET vmarca='';
			LET vmonto=0;
			LET vmontorealrevfzda=0;
			LET vmontosurcharge=0;
			LET vmontocomision=0;
			LET vinternacional='';


			let vpaso= 13;

			--- Obtiene e inserta en la tabla 'td_txns_atms_exitosas' las transacciones exitosas del dÃÂ­a, de la tabla 'td_sus_en_mis_exi' del tipo 'SUS en MIS' del IST y TMO ---

			FOREACH CURSOR5 WITH HOLD FOR

			select 0, fechaconciliacion as fechaproceso,substr(to_DATE (fecha ,'%d/%m/%y'),0,11)||hora||'.00000' as fechahoramov,autorizacion as secuencia,'' as numtarjetamovi,numtarjeta as numtarjetastat06,SUBSTR (numtarjeta,0,6) AS BIN,trim(numcajero) as idterminal,'SM' as tipotran,--'01' as codtran,
			case
			WHEN descripcion like 'CONSULTA%' AND monto = '0' THEN "31"
			WHEN descripcion like 'CONSULTA%' AND monto = '8' THEN "02"
			WHEN descripcion like 'CONSULTA%' AND monto = '5' THEN "02"
			ELSE "01"
			END as codtran,
			case
			 WHEN emisor in ('VISA','MDS') THEN "F"
			ELSE "V"
			END AS esnacional,
			case
			WHEN archivoorigen ='TMO' THEN '1234'
			WHEN archivoorigen ='IST' THEN '0010'
			ELSE ''
			end as transaccionorigen,'' as idreceptor, '0' as codreversa, 'V' as movconciliado, 'F' as movreversado,'V' as trancajeropropio,'0200' as formato,archivoorigen,
			case
			 WHEN SUBSTR (numtarjeta,0,6) IN (SELECT BIN FROM BDICHEQ:SC_BINES WHERE creditodebito ='c') THEN "C"
			 WHEN SUBSTR (numtarjeta,0,6) IN (SELECT BIN FROM BDICHEQ:SC_BINES WHERE creditodebito ='d') THEN "D"
				 ---RQI 15 060 ModificaciÃ³n al  calculo de retiros exitosos en cajeros-----
			 WHEN compania ='BND' THEN "D"
			 WHEN compania ='BNC' THEN "C"
			ELSE ''
			END AS creditodebito,
			case
			 WHEN SUBSTR (numtarjeta,0,1) IN  (SELECT SUBSTR (bin,0,1) FROM bdicheq:sc_bines WHERE creditodebito ='d' and SUBSTR (bin,0,1) ='4') THEN "V"
			 WHEN SUBSTR (numtarjeta,0,1) IN  (SELECT SUBSTR (bin,0,1) FROM bdicheq:sc_bines WHERE creditodebito ='c' and SUBSTR (bin,0,1) ='4') THEN "V"
			 WHEN SUBSTR (numtarjeta,0,1) IN  (SELECT SUBSTR (bin,0,1) FROM bdicheq:sc_bines WHERE creditodebito ='d' and SUBSTR (bin,0,1) ='5') THEN "M"
			 WHEN SUBSTR (numtarjeta,0,1) IN  (SELECT SUBSTR (bin,0,1) FROM bdicheq:sc_bines WHERE creditodebito ='c' and SUBSTR (bin,0,1) ='5') THEN "M"
			ELSE ''
			END AS marca,monto as monto,'0' as montorealrevfzda,comisionsurcharge as montosurcharge,'0' as montocomision,red

			INTO vconsecutivo, vfechaproceso, vfechahoramov, vsecuenciaFor, vnumtarjetamovi, vnumtarjetastat06, vbin,vidterminal, vtipotran, vcodtran, vesnacional, vtransaccionorigen, vidreceptor, vcodreversa, vmovconciliado,vmovreversado,vtrancajeropropio,vformato,varchivoorigen,vcreditodebito,
			vmarca,vmonto,vmontorealrevfzda,vmontosurcharge,vmontocomision,vinternacional

			from intercard:td_sus_en_mis_exi

			INSERT INTO bditarjeta:"informix".td_txns_atms_exitosas(consecutivo, fechaproceso, fechahoramov, secuencia, numtarjetamovi, numtarjetastat06, bin,idterminal, tipotran, codtran, esnacional,
			transaccionorigen, idreceptor, codreversa,movconciliado,movreversado,trancajeropropio,formato,archivoorigen,creditodebito,marca,monto,montorealrevfzda,montosurcharge,montocomision,internacional)VALUES (vconsecutivo, vfechaproceso, vfechahoramov, vsecuenciaFor, vnumtarjetamovi, vnumtarjetastat06, vbin,vidterminal, vtipotran, vcodtran, vesnacional, vtransaccionorigen, vidreceptor, vcodreversa, vmovconciliado,vmovreversado,vtrancajeropropio,vformato,varchivoorigen,vcreditodebito,
			vmarca,vmonto,vmontorealrevfzda,vmontosurcharge,vmontocomision,vinternacional);

			IF (vsFlagEnTransaccionFor = 'F') THEN
					 BEGIN WORK;
					 LET vsFlagEnTransaccionFor = 'V';
				END IF;	 

				LET viContadorRegistros = viContadorRegistros + 1;

				--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
				   IF (viContadorRegistros = 500) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
					COMMIT WORK;
					LET vsFlagEnTransaccionFor = 'F';
					LET viContadorRegistros = 0;
					CONTINUE FOREACH;
				   END IF;
				   
			 END FOREACH;
				 
				   -- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
				IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccionFor = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
					COMMIT WORK;
					LET vsFlagEnTransaccionFor = 'F';
				END IF;

			LET vsFlagEnTransaccionFor = 'F';
			LET viContadorRegistros = 0;
			LET vconsecutivo = 0;
			LET vsecuencia ='';
			LET vnumtarjetamovi='';
			LET vnumtarjetastat06= '';
			LET vbin='';
			LET vidterminal='';
			LET vtipotran='';
			LET vcodtran='';
			LET vesnacional='';
			LET vtransaccionorigen='';
			LET vidreceptor='';
			LET vcodreversa='';
			LET vmovconciliado='';
			LET vmovreversado='';
			LET vtrancajeropropio='';
			LET vformato='';
			LET varchivoorigen='';
			LET vcreditodebito='';
			LET vmarca='';
			LET vmonto=0;
			LET vmontorealrevfzda=0;
			LET vmontosurcharge=0;
			LET vmontocomision=0;
			LET vinternacional='';

			let vpaso= 14;

			--BEGIN;

			UPDATE bditarjeta:td_txns_atms_exitosas --SEQUENTIAL SCAN
			SET montocomision = '0'
			WHERE fechahoramov between vfecharep_inimov and vfecharep_finmov
			and montocomision is null;

			--commit;

			--- Se eliminan laa tablas temporales creadas ---
			let vpaso= 15;

			DROP table movimientoist;
			DROP table td_sus_en_mis_exi;
			DROP table td_sus_en_mis_exi2;
			DROP table reversossusenmis;
			DROP table revparist;
			DROP table revpar_movimientoist;


			LET iNum_renglon = iNum_renglon + 1;
			
END LOOP;
--//FIN PARA GENERAR REGISTROS DE FECHA FALTANTE EN bditarjeta:td_txns_atms_exitosas---------------------------------------------------------------------------------------------------------------
LET cCodret = '00000';
LET CMENSAJE = 'PROCESO EXITOSO';	
  
RETURN cCodret,CMENSAJE;
END
END PROCEDURE
DOCUMENT 'AUTOR: IVAN LOPEZ ESCORZA',
'FECHA: 25/NOV/2021',
'MODULO: CAJEROS',
'DESCRIPCION: SPL encargado de generar Info de la Fecha faltante en la tabla bditarjeta:td_txns_atms_exitosas',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_cargaarchivos_colaborapp ( 
psRuta_Repositorio VARCHAR (90), 
psNomArchivo VARCHAR (30), 
psArchivoOrigen VARCHAR(3), 
piTipoLayOut INTEGER, 
psSistema VARCHAR(1) 
)

RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta, INTEGER AS Tot_Registros, MONEY AS Tot_Monto, INTEGER AS Elemento;

--DEFINICION DE VARIABLES  
DEFINE vsSQL 				VARCHAR (200) ;
DEFINE viSQLerr 			INTEGER ;
DEFINE vsCodRet 			VARCHAR(5);
DEFINE vsMensaje_Respuesta 	VARCHAR(250);
DEFINE viTotalRegistros 	INTEGER;
DEFINE vmTotalMonto 		MONEY;
DEFINE viInicioCadena_Reg	INTEGER;
DEFINE viPosMontoReg_Ini 	INTEGER;
DEFINE viPosMontoReg_Fin 	INTEGER;
DEFINE viInicioCadena_Monto	INTEGER;
DEFINE vsTipoSumario 		VARCHAR(35);
DEFINE vsposicion_Regtxn	INTEGER;
DEFINE vsposicion_Montotxn	INTEGER;
DEFINE vsRegistros_txn		VARCHAR(12);
DEFINE vsMonto_txn			VARCHAR(15);
DEFINE vdRegistros_txn		VARCHAR(01);
DEFINE vdsMonto_txn			VARCHAR(01);
DEFINE vsEnc_Monto_Total    MONEY;
DEFINE vregistro            CHAR(600);
DEFINE vregistro2            CHAR(600);
DEFINE vregistro3           CHAR(600);
DEFINE vmonto_row           MONEY;

    --SET DEBUG FILE TO "/informix/mgap/trace_carga_colaborapp.out";
 	--TRACE ON;

/* INICIALIZACION DE VARIABLES */
LET vsSQL 					= '' ;
LET viSQLerr 				= 0;      
LET vsCodRet 				= '00000';
LET vsMensaje_Respuesta	 	= 'PROCESO EXITOSO';
LET viTotalRegistros 		= 0;
LET vmTotalMonto 			= 0.0;
LET viPosMontoReg_Ini 		= 0;
LET viPosMontoReg_Fin 		= 0;
LET viInicioCadena_Monto	= 0;
LET vsTipoSumario 			= '';
LET vsposicion_Regtxn		= 9;
LET vsposicion_Montotxn		= 18;
LET vsRegistros_txn	 		= ''; 
LET vsMonto_txn				= '';  
LET vdRegistros_txn			= '';
LET vdsMonto_txn			= '';
LET vsEnc_Monto_Total       = 0.0;	
LET vregistro               = ''; 
LET vregistro2               = ''; 
LET vregistro3              = '';  
LET vmonto_row              = 0.0;	
	
	
	BEGIN

		ON EXCEPTION SET viSQLerr
			--LIMPIA LA TABLA
			DELETE FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp;
			LET vsCodRet = '00108';
			RETURN vsCodRet, ('[' || vsCodRet ||  '] ERROR NO CONTROLADO (' || viSQLerr || '). ARCHIVO (' || psNomArchivo || ') ' || TRIM(vsMensaje_Respuesta) ), 0, 0.0, 1;
			
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;		
		
		LET vsMensaje_Respuesta = 'GENERAR COMANDO DE CARGA';
		
        EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_dbload_archivos
		   (psRuta_Repositorio, psNomArchivo, psArchivoOrigen , piTipoLayOut , psSistema)
            INTO vsCodRet, vsMensaje_Respuesta;
            
        IF ( vsCodRet  <> '00000' ) THEN

		    LET vsMensaje_Respuesta = 'ERROR EN LA CARGA';
		    RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta), NVL(viTotalRegistros, 0), NVL((vsMonto_txn), 0.0), 1;
            
        END IF

		IF (NOT EXISTS (SELECT Registro FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp  
		WHERE Registro MATCHES 'HEADER*')) THEN  
 
			LET vsTipoSumario = 'ERROR HEADER';

		ELIF (NOT EXISTS (SELECT Registro FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp  
		WHERE Registro MATCHES 'TRAILER*')) THEN  
 
			LET vsTipoSumario = 'ERROR TRAILER';	

			-- ########################### Layout de Depositos Colaborapp   ##########################################
			
		ELIF (piTipoLayOut = 9) THEN 

			SELECT FIRST 1 
				( SUBSTR(Registro, vsposicion_Regtxn, 8)) AS Registros_txn,  --TOTAL REGISTROS 
				--( SUBSTR(Registro, vsposicion_Montotxn, 15)) AS Monto_txn	--MONTO TOTAL
                 --((( SUBSTR(Registro, vsposicion_Montotxn, 15))::MONEY)/100) AS Monto_txn	--MONTO TOTAL				
				 SUBSTR(Registro, vsposicion_Montotxn, 15) AS Monto_txn	--MONTO TOTAL
				INTO 
				vsRegistros_txn,
				vsMonto_txn
				FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp 
				WHERE Registro MATCHES 'TRAILER*';

			    --BORRA LOS REGISTROS DE ENCABEZADO		
			     DELETE FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp WHERE (Registro MATCHES 'HEADER*');

			    ---COSECHA MARCOS  BORRA EL TRAILER 
	      	    DELETE FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp WHERE (Registro MATCHES 'TRAILER*');
				 
		ELSE -- ERROR EN CASO QUE NO SE ENCUENTRE ALGUN LAYOUT
		
			LET vsTipoSumario = 'ERROR LAYOUT';
  	
		END IF; -- IF (1)
 
        LET vsTipoSumario = vsTipoSumario;
		---------------------------
		LET vsMensaje_Respuesta = 'PROCESO EXITOSO';
		IF (TRIM(vsTipoSumario) = 'ERROR HEADER') THEN  

			LET vsCodRet = '00100';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CONTIENE EL ENCABEZADO CORRESPONDIENTE AL TIPO LAYOUT: ' || piTipoLayOut || '.';
		
		ELIF (TRIM(vsTipoSumario) = 'ERROR TRAILER') THEN 	
		 	
			LET vsCodRet = '00101';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CONTIENE EL TRAILER CORRESPONDIENTE AL TIPO LAYOUT: ' || piTipoLayOut || '.';
 
		ELIF (TRIM(vsTipoSumario) = 'ERROR LAYOUT') THEN  
			
			LET vsCodRet = '00102';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CORRESPONDE A NINGUN TIPO DE LAYOUT REGISTRADO.';
			
		ELIF (NOT EXISTS (SELECT TRIM(Registro) FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp WHERE Registro MATCHES (vsTipoSumario || '*'))) THEN --NO CONTIENE REGISTRO DE SUMARIO
		    
            IF  vsRegistros_txn > 0 then
			
			  LET vsCodRet = '00103';
			  LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CONTIENE REGISTRO DE SUMARIO/TRAILER.';
			END IF;
			
		ELSE
		
		    LET vsMensaje_Respuesta = 'VALIDAR REGISTROS EN SUMARIO/TRAILER SON NUMERICOS.';
			
			EXECUTE PROCEDURE BdiTarjeta:"informix".sp_ConcReing_EsNumerico( vsRegistros_txn ) INTO vdRegistros_txn;
			EXECUTE PROCEDURE BdiTarjeta:"informix".sp_ConcReing_EsNumerico( vsMonto_txn  )    INTO vdsMonto_txn;  
		
		END IF; -- IF (2)	


		 IF ( vsCodRet  <> '00000' ) THEN

		    RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta), NVL(viTotalRegistros, 0), NVL((vsMonto_txn), 0.0), 1;
            
        END IF
		
		IF (vdRegistros_txn = 'F' ) THEN --ERROR TOTAL REGISTROS NO ES NUMERICO -- IF (2.3)
			
			LET vsCodRet = '00104';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') CONTIENE UN TOTAL REGISTRO NO NUMERICO.';
			RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta), NVL(viTotalRegistros, 0), NVL((vsMonto_txn), 0.0), 1;
			
		ELIF (vdsMonto_txn = 'F') THEN --ERROR MONTO TOTAL NO ES NUMERICO
			
			LET vsCodRet = '00105';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') CONTIENE UN MONTO TOTAL NO NUMERICO.';
		    RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta), NVL(viTotalRegistros, 0), NVL((vsMonto_txn), 0.0), 1;
		
		ELSE -- SI TODO LOS REGISTROS SON NUMERICOS SE REALIZA LO SIGUIENTE:
	
			LET vsMensaje_Respuesta = 'TODOS SOMOS NUMEROS';
	
		END IF; -- IF (2.3)
 
		    --Obtiene el numero de registros del archivo y las compara con el total 
			select count(registro) into vitotalregistros from bditarjeta:"informix".td_carga_archivo_colaborapp;
			let vsmensaje_respuesta = 'Validar discrepancias en el total sumario/trailer vs archivo.';
			if ((vitotalregistros) <> (vsRegistros_txn) ) then --valida lo reportado en el sumario con el contenido el archivo
				let vscodret = '00106'; --cantidades distintas de registros
				let vsmensaje_respuesta = '[' || vscodret ||  ']El archivo (' || trim(psnomarchivo) || ') contiene discrepancias en el total de registros reportados '|| vitotalregistros ||' y los contenidos '|| vsRegistros_txn ||' en el archivo.';
				let vitotalregistros = 0;
				 RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta), NVL(viTotalRegistros, 0), NVL((vsMonto_txn), 0.0), 1;
			End if;
	 
	        --VALIDA DIFERENCIAS EN EL MONTO DEL ARCHIVO
		    	 -- respaldo SELECT SUM((((SUBSTR(registro,23,13))::MONEY)/100)) INTO vsEnc_Monto_Total FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp; 
				
				LET vsMonto_txn =  ((vsMonto_txn::MONEY)/100); 
				
				FOREACH cursor_money WITH HOLD FOR 
				
				          SELECT Registro INTO vregistro FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp
						  
				            LET  vmonto_row = NVL(((SUBSTR(vregistro,23,13))::MONEY)/100,0);
				            LET  vsEnc_Monto_Total = vsEnc_Monto_Total + vmonto_row;
			 	
				END FOREACH;				
				 ---------------
			  	IF (vsMonto_txn <> vsEnc_Monto_Total)  THEN --VALIDA QUE EL MONTO REPORTADO EN EL SUMARIO CON EL CONTENIDO EL ARCHIVO 
						LET vsCodRet = '00107'; --CANTIDADES DISTINTAS DE MONTOS
						LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || trim(psNomArchivo) || ') CONTIENE DISCREPANCIAS EN EL MONTO TOTAL REPORTADO Y EL CONTENIDO(' || vsEnc_Monto_Total || ').';
				END IF;
	            ---------------
				FOREACH cursor_form_date WITH HOLD FOR 
				 
						  SELECT  TRIM(SUBSTRING (Registro FROM 74 FOR 2 )),  --  Fecha_consumo (DD)  	  
						          TRIM(SUBSTRING (Registro FROM 76 FOR 2 )),  --  Fecha_consumo (MM)  	  
						          TRIM(SUBSTRING (Registro FROM 78 FOR 2 ))  --  Fecha_consumo (AA)
								  INTO vregistro,vregistro2, vregistro3	  
				          FROM BdiTarjeta:"informix".td_carga_archivo_colaborapp
                            
                          IF vregistro between '01' and '31' THEN 
						     ELSE 							 
							 LET vsCodRet = '00109';
			                 LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') CONTIENE FORMATO DE FECHA INCORRECTA';
						  END IF; 	
							
						  IF (vregistro2 between '01' and '12') THEN 
						     ELSE 
							  LET vsCodRet = '00109';
			                  LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') CONTIENE FORMATO DE FECHA INCORRECTA';
                          END IF; 	
							  
                          IF vregistro3 >= '21' THEN  
						     ELSE 							 
							 LET vsCodRet = '00109';
			                 LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ')  CONTIENE FORMATO DE FECHA INCORRECTA';
						  END IF; 	 
				END FOREACH;	
				--------------
		  RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta), NVL(viTotalRegistros, 0), NVL((vsMonto_txn), 0.0), 1;
		
	END

END PROCEDURE;