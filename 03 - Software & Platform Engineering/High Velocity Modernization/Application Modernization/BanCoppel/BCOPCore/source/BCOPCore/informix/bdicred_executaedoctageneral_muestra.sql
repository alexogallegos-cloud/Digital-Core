CREATE PROCEDURE "informix".executaedoctageneral_muestra(pEmpresa CHAR(3),pFecha	date)/*, pFechaCorte DATE/*, pFechaCorteAnt DATE*/
--EXECUTE PROCEDURE executaedoctageneral_muestra('001',MDY('12','20','2020'));
RETURNING CHAR (6) AS Codret  ,CHAR(100) AS Descripcion;

--'DESCRIPCION: Se realiza procedimiento para la obtencion de una muestra creditos '
--'AUTOR : Maria Elena Angulo Aispuro'--'FECHA : 01/AGOSTO/2011'--'BD: BDICRED'
--'MODIFICADO: Maria Elizabeth Anzures Ibarguen'--'FECHA: 28-SEPTIEMBRE-2011'
--'DESCRIPCION: Se agregaron 16 conusultas mas para la obtencion de muestras'
	
---Definicion de Variables          
DEFINE cCodRet CHAR(6);
DEFINE cMensajeRet CHAR(100);  
DEFINE iSqlErr INTEGER;
DEFINE iIsamErr  INTEGER; 
DEFINE scont INT8; 
DEFINE cErrorInfo  CHAR(80);  
DEFINE iMuestra	 INTEGER; 
DEFINE iFlagGeneracion  INTEGER; 
DEFINE dtFechaHoy DATE;
DEFINE sMesHoy SMALLINT;   
DEFINE sDiaHoy SMALLINT;   
DEFINE sAnioHoy SMALLINT;
DEFINE dtCorteActual	DATE;
DEFINE dtCorteAnterior	DATE;
DEFINE pFechaCorte DATE;
DEFINE pFechaCorteAnt DATE;

--Se definen variables para almacenar informaciÃÂ³n de la tabla bdicred:sd_muestra_edocta
--21/12/20 Juan RomÃÂ¡n VelÃÂ¡zquez Toledo
DEFINE cEmpresa CHAR(3);
DEFINE cNumClie CHAR(20);
DEFINE cNumCredito CHAR(20);
DEFINE cFechaCorte DATE;
DEFINE cTipoLogica CHAR(2);
DEFINE cNumTarjeta CHAR(20);
DEFINE cStatusMesAnterior CHAR(2);
DEFINE cStatusMesActual CHAR(2);
DEFINE cFlagAutomatico SMALLINT;
DEFINE cFlagGeneracion SMALLINT;
DEFINE cFechaInsert DATE;
DEFINE cUsuarioInsert CHAR(8);

---Inicializaciones
LET iSqlErr    = 0; 
LET iIsamErr   = 0; 
LET cErrorInfo  = ""; 
LET scont	 = 0; 
LET cCodRet  = "000000"; 
LET cMensajeRet  = "Se realizÃÂ³ la consulta correctamente";  
LET iMuestra	  = 0; 
LET iFlagGeneracion   = 0;
LET dtFechaHoy	= DATE(1);
LET sMesHoy = 0; 
LET sDiaHoy = 0; 
LET sAnioHoy = 0;
LET dtCorteActual		= DATE(1);
LET dtCorteAnterior		= DATE(1);
LET pFechaCorte = DATE(1);
LET pFechaCorteAnt = DATE(1);

--Se inicalizan variables para almacenar informaciÃÂ³n de la tabla bdicred:sd_muestra_edocta
--21/12/20 Juan RomÃÂ¡n VelÃÂ¡zquez Toledo
LET cEmpresa = '';
LET cNumClie = '';
LET cNumCredito = '';
LET cFechaCorte = DATE(1);
LET cTipoLogica = '';
LET cNumTarjeta = '';
LET cStatusMesAnterior = '';
LET cStatusMesActual = '';
LET cFlagAutomatico = 0;
LET cFlagGeneracion = 0;
LET cFechaInsert = DATE(1);
LET cUsuarioInsert = '';

BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
	 LET cMensajeRet=cErrorInfo;
     RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2000',cCodRet,cMensajeRet,'01')	INTO cCodRet;
--SET DEBUG FILE TO '/home/informix/Elizabeth/mec.out';
--TRACE ON;
	
	-- SE OBTIENE LA FECHA DEL SISTEMA Y SE VALIDA QUE NO SEA UNA FECHA ANTERIOS AL CORTE , SE CALCULA LA FECHA DEL MES ANTERIOR
	-- OBTIENE LA FECHA DEL SISTEMA
	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM 'informix'.sd_fechas
	WHERE empresa = pEmpresa;
	
	--Se obtiene numero de muestras de valores aleatorios a obtener.
		SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";
	
	--- VALIDA QUE LA FECHA DEL SISTEMA NO ESTE VACIA
	IF NVL(dtFechaHoy,DATE(1)) = DATE(1) THEN
		LET cCodRet = '000003';
		LET cMensajeRet = 'LA FECHA DEL SISTEMA ESTA VACIA';
		RETURN cCodRet,cMensajeRet;
	END IF
	
	LET sMesHoy = MONTH(dtFechaHoy);
	LET sDiaHoy = DAY(dtFechaHoy);
	LET sAnioHoy = YEAR(dtFechaHoy);
	
	--- VALIDA QUE NO SEA UNA FECHA ANTES DEL CORTE
	IF sDiaHoy < 20 THEN
		LET cCodRet = '000004';
		LET cMensajeRet = 'LA FECHA DEL SISTEMA ES MENOR AL DIA DEL CORTE';
		RETURN cCodRet,cMensajeRet;
	END IF
	
	--- OBTIENE LA FECHA DEL CORTE ACTUAL Y DEL CORTE ANTERIOR
	LET dtCorteActual		= MDY(sMesHoy,20,sAnioHoy);
	LET dtCorteAnterior		=  dtFechaHoy - 1 UNITS MONTH;
	LET dtCorteAnterior		=  MDY(MONTH(dtCorteAnterior),20,YEAR(dtCorteAnterior));
	
	LET pFechaCorteAnt = dtCorteAnterior;
	LET pFechaCorte = dtCorteActual;
			
	--Validacion de parametros de entrada
	IF (pEmpresa='') OR /*(pFechaCorte='') OR (pFechaCorteAnt='') OR */ 
	   (pEmpresa IS NULL) /*OR (pFechaCorte IS NULL) OR (pFechaCorteAnt IS NULL)*/  THEN
		LET cCodRet = "000001";
		LET cMensajeRet="Uno o mas parametros de entrada son invalidos";
	 
	ELSE
		------------------------------VENCIDO A VIGENTE-----------------------------------------------------------------------
		--Se obtiene valor que contENDrÃÂ¡ el campo flag_generacion al insertar el registro muestra.
		/*SELECT TRIM(valor)::INTEGER
		INTO iFlagGeneracion
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "127";	*/
--Se obtienen los crÃÂ©ditos que se van a excluir para ser enviados por correo.
		
		select cuenta from bdiedoelec:"informix".edelec_alta_serv
											where status_serv_elec = 'A'
											and producto in ('6001','6600','7000')
											and cuenta in 
											(select a.num_credito 
											   from bdicred:sd_maecred a,
											        bdicred:sd_maesdos b
											  where a.num_credito = b.num_credito
											    and a.status_cred IN ('AA','E1')
												and (b.monto_vencido + b.mto_venc_trasp) = 0)
			into temp sd_edelec_alta_serv_muestras with no log;
			
			CREATE INDEX alta_serv_muestras_dt on sd_edelec_alta_serv_muestras(cuenta);
			
			update statistics medium for table sd_edelec_alta_serv_muestras;
		
				--Se obtiene numero de muestras de valores aleatorios a obtener.
		/*SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";*/
		
	--Se consulta la informaciÃÂ³n de los clientes que cumplen con el estatus de vigente a vigente sin pagos.
	--Se realiza modificaciÃÂ³n para relizar primero el select y despuÃÂ©s el insert. 21/12/20
		FOREACH
			select first iMuestra
				a.empresa, c.numcte , a.num_credito,b.fecha, '01', c.num_tarjeta, 'E3','E1','1','0', today, user
			into cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert
			from bdicred:sd_maesdoshist a,
				bdicred:sd_tarjeta c,
				bdicred:sd_maesdoshist b
			where a.empresa = '001'
				and a.fecha = pFechaCorteAnt
				and b.fecha = pFechaCorte
				and a.empresa = b.empresa
				and a.empresa = c.empresa
				and a.num_credito = b.num_credito
				and a.num_credito = c.num_credito
				and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
				and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
				and c.secuencia = (select max(tar.secuencia)
									from bdicred:sd_tarjeta tar
									where tar.empresa = a.empresa
									and tar.num_credito = a.num_credito
									and tar.tipo_tarjeta ='T'
									and tar.status_tar = 'A')
				and c.tipo_tarjeta ='T'
				and c.status_tar = 'A'
				and (a.mto_venc_trasp > 0 or nvl(a.act,-1) > 3)
				and b.monto_vencido + b.mto_venc_trasp = 0
				
				insert into bdicred:sd_muestra_edocta (empresa, numcte, num_credito, fecha_corte, tipo_logica, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, flag_automatico, flag_generacion, fecha_insert, usuario_insert)
						values (cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert);
		END FOREACH;
		/*select first iMuestra
			a.empresa, c.numcte , a.num_credito,b.fecha, '01', c.num_tarjeta, 'BT','AA','1','0', today, user
		from bdicred:sd_maesdoshist a,
			bdicred:sd_tarjeta c,
			bdicred:sd_maesdoshist b
		where a.empresa = '001'
			and a.fecha = pFechaCorteAnt
			and b.fecha = pFechaCorte
			and a.empresa = b.empresa
			and a.empresa = c.empresa
			and a.num_credito = b.num_credito
			and a.num_credito = c.num_credito
			and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
			and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
			and c.secuencia = (select max(tar.secuencia)
								from bdicred:sd_tarjeta tar
								where tar.empresa = a.empresa
								and tar.num_credito = a.num_credito
								and tar.tipo_tarjeta ='T'
								and tar.status_tar = 'A')
			and c.tipo_tarjeta ='T'
			and c.status_tar = 'A'
			and a.mto_venc_trasp > 0
			and b.monto_vencido + b.mto_venc_trasp = 0;*/
				
		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay InformaciÃÂ³n de clientes con estatus vencido a vigente';
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2101',cCodRet,cMensajeRet,'02') INTO cCodRet; 
		ELSE
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2101',cCodRet,cMensajeRet,'02') INTO cCodRet; 				
		END IF;		
	-------------------------------VENCIDO A VENCIDO CON PAGOS-----------------------------------------------------------
	--se inicializan variables para vuelta de uso
	LET scont	 = 0;	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realizÃÂ³ la consulta correctamente";	--LET iMuestra = 0;
	--Se obtiene numero de muestras de valores aleatorios a obtener.
		/*SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";*/
	--Se consulta la informaciÃÂ³n de los clientes que cumplen con el estatus de vigente a vigente sin pagos.	
	
	FOREACH
		select first iMuestra
			a.empresa, c.numcte , a.num_credito,b.fecha, '02', c.num_tarjeta, 'E3','E3','1','0', today, user
		into cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert
		from bdicred:sd_maesdoshist a,
			bdicred:sd_tarjeta c,
			bdicred:sd_maesdoshist b,
			bdicred:sd_maecredanexo d
		where a.empresa = '001'
			and a.fecha = pFechaCorteAnt
			and b.fecha = pFechaCorte
			and a.empresa = b.empresa
			and a.empresa = c.empresa
			and a.empresa = d.empresa
			and a.num_credito = b.num_credito
			and a.num_credito = c.num_credito
			and a.num_credito = d.num_credito
			and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
			and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
			and c.secuencia = (select max(tar.secuencia)
						from bdicred:sd_tarjeta tar
						where tar.empresa = a.empresa
						  and tar.num_credito = a.num_credito
						  and tar.tipo_tarjeta ='T'
						  and tar.status_tar = 'A')
			and c.tipo_tarjeta ='T' 
			and c.status_tar = 'A'
			and (a.mto_venc_trasp + a.cap_tras_no_venci > 0 or nvl(a.act,-1) > 3)
			and (b.mto_venc_trasp + b.cap_tras_no_venci > 0 or nvl(b.act,-1) > 3)
			and d.fecha_ult_pago > a.fecha
			and d.fecha_ult_pago <= b.fecha
		
		insert into bdicred:sd_muestra_edocta (empresa, numcte, num_credito, fecha_corte, tipo_logica, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, flag_automatico, flag_generacion, fecha_insert, usuario_insert)
						values (cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert);
	END FOREACH;
	/*select first iMuestra
		a.empresa, c.numcte , a.num_credito,b.fecha, '02', c.num_tarjeta, 'BT','BT','1','0', today, user
	from bdicred:sd_maesdoshist a,
		bdicred:sd_tarjeta c,
		bdicred:sd_maesdoshist b,
		bdicred:sd_maecredanexo d
	where a.empresa = '001'
		and a.fecha = pFechaCorteAnt
		and b.fecha = pFechaCorte
		and a.empresa = b.empresa
		and a.empresa = c.empresa
		and a.empresa = d.empresa
		and a.num_credito = b.num_credito
		and a.num_credito = c.num_credito
		and a.num_credito = d.num_credito
		and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
		and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
		and c.secuencia = (select max(tar.secuencia)
                    from bdicred:sd_tarjeta tar
                    where tar.empresa = a.empresa
                      and tar.num_credito = a.num_credito
                      and tar.tipo_tarjeta ='T'
                      and tar.status_tar = 'A')
		and c.tipo_tarjeta ='T' 
		and c.status_tar = 'A'
		and a.mto_venc_trasp + a.cap_tras_no_venci > 0
		and b.mto_venc_trasp + b.cap_tras_no_venci > 0
		and d.fecha_ult_pago > a.fecha
		and d.fecha_ult_pago <= b.fecha;*/

		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay InformaciÃÂ³n de clientes con estatus vencido a vencido con pagos';
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2102',cCodRet,cMensajeRet,'02') INTO cCodRet; 
		ELSE
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2102',cCodRet,cMensajeRet,'02') INTO cCodRet; 				
		END IF;		
	---------------------------------------VENCIDO A VENCIDO SIN PAGOS-------------------------------------------------
	--se inicializan variables para vuelta de uso
	LET scont	 = 0;	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realizÃÂ³ la consulta correctamente";	--LET iMuestra = 0;
	--Se obtiene numero de muestras de valores aleatorios a obtener.
		/*SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";*/
		
	--Se consulta la informaciÃÂ³n de los clientes que cumplen con el estatus de vencido a vencido sin pagos.
	FOREACH
		select first iMuestra
			a.empresa, c.numcte , a.num_credito,b.fecha, '03', c.num_tarjeta, 'E3','E3','1','0', today, user
		into cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert
		from bdicred:sd_maesdoshist a,
			bdicred:sd_tarjeta c,
			bdicred:sd_maesdoshist b,
			bdicred:sd_maecredanexo d
		where a.empresa = '001'
			and a.fecha = pFechaCorteAnt
			and b.fecha = pFechaCorte
			and a.empresa = b.empresa
			and a.empresa = c.empresa
			and a.empresa = d.empresa
			and a.num_credito = b.num_credito
			and a.num_credito = c.num_credito
			and a.num_credito = d.num_credito
			and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
			and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
			and c.secuencia = (select max(tar.secuencia)
							from bdicred:sd_tarjeta tar
							where tar.empresa = a.empresa
							and tar.num_credito = a.num_credito
							and tar.tipo_tarjeta ='T'
							and tar.status_tar = 'A')
			and c.tipo_tarjeta ='T' 
			and c.status_tar = 'A'
			and (a.mto_venc_trasp + a.cap_tras_no_venci > 0 or nvl(a.act,-1) > 3)
			and (b.mto_venc_trasp + b.cap_tras_no_venci > 0 or nvl(b.act,-1) > 3)
			and nvl(fecha_ult_pago,date(1)) <= a.fecha
		
		insert into bdicred:sd_muestra_edocta (empresa, numcte, num_credito, fecha_corte, tipo_logica, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, flag_automatico, flag_generacion, fecha_insert, usuario_insert)
						values (cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert);
	END FOREACH;
	/*select first iMuestra
		a.empresa, c.numcte , a.num_credito,b.fecha, '03', c.num_tarjeta, 'BT','BT','1','0', today, user
	from bdicred:sd_maesdoshist a,
		bdicred:sd_tarjeta c,
		bdicred:sd_maesdoshist b,
		bdicred:sd_maecredanexo d
	where a.empresa = '001'
		and a.fecha = pFechaCorteAnt
		and b.fecha = pFechaCorte
		and a.empresa = b.empresa
		and a.empresa = c.empresa
		and a.empresa = d.empresa
		and a.num_credito = b.num_credito
		and a.num_credito = c.num_credito
		and a.num_credito = d.num_credito
		and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
		and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
		and c.secuencia = (select max(tar.secuencia)
						from bdicred:sd_tarjeta tar
						where tar.empresa = a.empresa
						and tar.num_credito = a.num_credito
						and tar.tipo_tarjeta ='T'
						and tar.status_tar = 'A')
		and c.tipo_tarjeta ='T' 
		and c.status_tar = 'A'
		and a.mto_venc_trasp + a.cap_tras_no_venci > 0
		and b.mto_venc_trasp + b.cap_tras_no_venci > 0
		and nvl(fecha_ult_pago,date(1)) <= a.fecha;*/

		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay InformaciÃÂ³n de clientes con estatus vencido a vencido sin pagos';
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2103',cCodRet,cMensajeRet,'02') INTO cCodRet; 
		ELSE
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2103',cCodRet,cMensajeRet,'02') INTO cCodRet; 				
		END IF;	
		---------------------------------------VENCIDO A TRANSITORIO-------------------------------------------------
	--se inicializan variables para vuelta de uso
	LET scont	 = 0;	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realizÃÂ³ la consulta correctamente";	--LET iMuestra = 0;
	--Se obtiene numero de muestras de valores aleatorios a obtener.
		/*SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";*/
		
	--Se consulta la informaciÃÂ³n de los clientes que cumplen con el estatus de vencido a vencido sin pagos.	
	FOREACH
		select first iMuestra
			a.empresa, c.numcte , a.num_credito,b.fecha, '04', c.num_tarjeta, 'E3','E1','1','0', today, user
		into cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert
		from bdicred:sd_maesdoshist a,
			bdicred:sd_tarjeta c,
			bdicred:sd_maesdoshist b
		where a.empresa = '001'
			and a.fecha = pFechaCorteAnt
			and b.fecha = pFechaCorte
			and a.empresa = b.empresa
			and a.empresa = c.empresa
			and a.num_credito = b.num_credito
			and a.num_credito = c.num_credito
			and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
			and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
			and c.secuencia = (select max(tar.secuencia)
							from bdicred:sd_tarjeta tar
							where tar.empresa = a.empresa
							and tar.num_credito = a.num_credito
							and tar.tipo_tarjeta ='T'
							and tar.status_tar = 'A')
			and c.tipo_tarjeta ='T' 
			and c.status_tar = 'A'
			and (a.mto_venc_trasp > 0 or nvl(a.act,-1) > 3)
			and (b.monto_vencido  > 0 or nvl(b.act,-1) = 1)
		
		insert into bdicred:sd_muestra_edocta (empresa, numcte, num_credito, fecha_corte, tipo_logica, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, flag_automatico, flag_generacion, fecha_insert, usuario_insert)
						values (cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert);
	END FOREACH; 
	/*select first iMuestra
		a.empresa, c.numcte , a.num_credito,b.fecha, '04', c.num_tarjeta, 'BT','BA','1','0', today, user
	from bdicred:sd_maesdoshist a,
		bdicred:sd_tarjeta c,
		bdicred:sd_maesdoshist b
	where a.empresa = '001'
		and a.fecha = pFechaCorteAnt
		and b.fecha = pFechaCorte
		and a.empresa = b.empresa
		and a.empresa = c.empresa
		and a.num_credito = b.num_credito
		and a.num_credito = c.num_credito
		and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
		and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
		and c.secuencia = (select max(tar.secuencia)
						from bdicred:sd_tarjeta tar
						where tar.empresa = a.empresa
						and tar.num_credito = a.num_credito
						and tar.tipo_tarjeta ='T'
						and tar.status_tar = 'A')
		and c.tipo_tarjeta ='T' 
		and c.status_tar = 'A'
		and a.mto_venc_trasp > 0
		and b.monto_vencido > 0;*/
				
		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay InformaciÃÂ³n de clientes con estatus vencido a transitorio';
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2104',cCodRet,cMensajeRet,'02') INTO cCodRet; 
		ELSE
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2104',cCodRet,cMensajeRet,'02') INTO cCodRet; 				
		END IF;	
			---------------------------------------TRANSITORIO A VIGENTE-------------------------------------------------
	--se inicializan variables para vuelta de uso
	LET scont	 = 0;	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realizÃÂ³ la consulta correctamente";	--LET iMuestra = 0;
	--Se obtiene numero de muestras de valores aleatorios a obtener.
		/*SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";*/
		
	--Se consulta la informaciÃÂ³n de los clientes que cumplen con el estatus de vencido a vencido sin pagos.
		FOREACH
			select first iMuestra
				a.empresa, c.numcte , a.num_credito,b.fecha, '05', c.num_tarjeta, 'E1','E1','1','0', today, user
			into cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert
			from bdicred:sd_maesdoshist a,
				bdicred:sd_tarjeta c,
				bdicred:sd_maesdoshist b
			where a.empresa = '001'
				and a.fecha = pFechaCorteAnt
				and b.fecha = pFechaCorte
				and a.empresa = b.empresa
				and a.empresa = c.empresa
				and a.num_credito = b.num_credito
				and a.num_credito = c.num_credito
				and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
				and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
				and c.secuencia = (select max(tar.secuencia)
								from bdicred:sd_tarjeta tar
								where tar.empresa = a.empresa
								and tar.num_credito = a.num_credito
								and tar.tipo_tarjeta ='T'
								and tar.status_tar = 'A')
				and c.tipo_tarjeta ='T' 
				and c.status_tar = 'A'
				and (a.monto_vencido > 0 or nvl(a.act,-1) = 1)
				and b.monto_vencido + b.mto_venc_trasp  = 0
			
			insert into bdicred:sd_muestra_edocta (empresa, numcte, num_credito, fecha_corte, tipo_logica, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, flag_automatico, flag_generacion, fecha_insert, usuario_insert)
						values (cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert);
		END FOREACH;
	
		/*insert into bdicred:sd_muestra_edocta 
		select first iMuestra
			a.empresa, c.numcte , a.num_credito,b.fecha, '05', c.num_tarjeta, 'BA','AA','1','0', today, user
		from bdicred:sd_maesdoshist a,
			bdicred:sd_tarjeta c,
			bdicred:sd_maesdoshist b
		where a.empresa = '001'
			and a.fecha = pFechaCorteAnt
			and b.fecha = pFechaCorte
			and a.empresa = b.empresa
			and a.empresa = c.empresa
			and a.num_credito = b.num_credito
			and a.num_credito = c.num_credito
			and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
			and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
			and c.secuencia = (select max(tar.secuencia)
							from bdicred:sd_tarjeta tar
							where tar.empresa = a.empresa
							and tar.num_credito = a.num_credito
							and tar.tipo_tarjeta ='T'
							and tar.status_tar = 'A')
			and c.tipo_tarjeta ='T' 
			and c.status_tar = 'A'
			and a.monto_vencido > 0
			and b.monto_vencido + b.mto_venc_trasp  = 0;*/
					
		
		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay InformaciÃÂ³n de clientes con estatus transitorio a vigente';
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2105',cCodRet,cMensajeRet,'02') INTO cCodRet; 
		ELSE
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2105',cCodRet,cMensajeRet,'02') INTO cCodRet; 				
		END IF;	
	--------------------------------------VIGENTE A VIGENTE CON PAGOS--------------------------------------------
--se inicializan variables para vuelta de uso
	LET scont	 = 0;	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realizÃÂ³ la consulta correctamente";	--LET iMuestra = 0;
	--Se obtiene numero de muestras de valores aleatorios a obtener.
		/*SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";*/
		
		--Se consulta la informaciÃÂ³n de los clientes que cumplen con el estatus de vigente a vigente con pagos.		
		FOREACH
			select first iMuestra
				a.empresa, c.numcte , a.num_credito,b.fecha, '06', c.num_tarjeta, 'E1','E1','1','0', today, user
				into cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert
			from bdicred:sd_maesdoshist a,
				bdicred:sd_tarjeta c,
				bdicred:sd_maesdoshist b
			where a.empresa = '001'
				and a.fecha = pFechaCorteAnt
				and b.fecha = pFechaCorte
				and a.empresa = b.empresa
				and a.empresa = c.empresa
				and a.num_credito = b.num_credito
				and a.num_credito = c.num_credito
				and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
				and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
				and c.secuencia = (select max(tar.secuencia)
							from bdicred:sd_tarjeta tar
							where tar.empresa = a.empresa
							and tar.num_credito = a.num_credito
							and tar.tipo_tarjeta ='T'
							and tar.status_tar = 'A')
				and c.tipo_tarjeta ='T'  and c.status_tar = 'A'
				and a.monto_vencido + a.mto_venc_trasp  = 0
				and b.sdo_cap_insoluto <= 0
				and (select count(d.empresa)
						from bdicred:sd_movhis d
						where d.empresa = b.empresa
				and d.fecha_mov > a.fecha
				and d.fecha_mov <= b.fecha
				and d.num_credito = b.num_credito
				and d.codigo_fun = '002'
				and d.codigo_ref in (37,57,937,938)
				and d.reversado = 'N') >= 1
			
				insert into bdicred:sd_muestra_edocta (empresa, numcte, num_credito, fecha_corte, tipo_logica, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, flag_automatico, flag_generacion, fecha_insert, usuario_insert)
							values (cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert);
		END FOREACH;
		--insert into bdicred:sd_muestra_edocta 
		

		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay InformaciÃÂ³n de clientes con estatus vigente vigente con pagos';
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2106',cCodRet,cMensajeRet,'02') INTO cCodRet; 
		ELSE
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2106',cCodRet,cMensajeRet,'02') INTO cCodRet; 				
		END IF;	
	--------------------------------------VIGENTE A VIGENTE SIN PAGOS--------------------------------------------
	--se inicializan variables para vuelta de uso
	LET scont	 = 0;	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realizÃÂ³ la consulta correctamente";	--LET iMuestra = 0;
	--Se obtiene numero de muestras de valores aleatorios a obtener.
		/*SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";*/
		
		--Se consulta la informaciÃÂ³n de los clientes que cumplen con el estatus de vigente a vigente con pagos.		
		FOREACH
			select first iMuestra
			a.empresa, c.numcte , a.num_credito,b.fecha, '07', c.num_tarjeta, 'E1','E1','1','0', today, user
			into cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert
			from bdicred:sd_maesdoshist a,
				bdicred:sd_tarjeta c,
				bdicred:sd_maesdoshist b,
				bdicred:sd_maecredanexo d
			where a.empresa = '001'
				and a.fecha = pFechaCorteAnt
				and b.fecha = pFechaCorte
				and a.empresa = b.empresa
				and a.empresa = c.empresa
				and a.empresa = d.empresa
				and a.num_credito = b.num_credito
				and a.num_credito = c.num_credito
				and a.num_credito = d.num_credito
				and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
				and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
				and c.secuencia = (select max(tar.secuencia)
								from bdicred:sd_tarjeta tar
								where tar.empresa = a.empresa
								and tar.num_credito = a.num_credito
								and tar.tipo_tarjeta ='T'
								and tar.status_tar = 'A')
				and c.tipo_tarjeta ='T'  and c.status_tar = 'A'
				and a.monto_vencido + a.mto_venc_trasp  = 0
				and b.monto_vencido + b.mto_venc_trasp  = 0
				AND b.SDO_CAPITAL > 0
				and (select count(e.empresa)
					from bdicred:sd_movhis e
					where e.empresa = b.empresa
					and  e.num_credito = b.num_credito
					and e.codigo_fun = '002'
					and e.codigo_ref in (37,57,937,938)
					and e.fecha_mov > a.fecha
					and e.fecha_mov <= b.fecha
					and e.reversado = 'N') > 1
				and d.fecha_ult_pago > a.fecha
				and d.fecha_ult_pago <= b.fecha
				
				insert into bdicred:sd_muestra_edocta (empresa, numcte, num_credito, fecha_corte, tipo_logica, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, flag_automatico, flag_generacion, fecha_insert, usuario_insert)
							values (cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert);
		END FOREACH;
		--insert into bdicred:sd_muestra_edocta 
		

		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay InformaciÃÂ³n de clientes con estatus vigente a vigente sin pagos';
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2107',cCodRet,cMensajeRet,'02') INTO cCodRet; 
		ELSE
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2107',cCodRet,cMensajeRet,'02') INTO cCodRet; 				
		END IF;		
			--------------------------------------VIGENTE A VIGENTE SIN MOVIMIENTOS--------------------------------------------
	--se inicializan variables para vuelta de uso
	LET scont	 = 0;	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realizÃÂ³ la consulta correctamente";	
	--LET iMuestra = 0;
	--Se obtiene numero de muestras de valores aleatorios a obtener.
		/*SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";*/
		
	--Se consulta la informaciÃÂ³n de los clientes que cumplen con el estatus de vigente a vigente sin movimientos.
	FOREACH
		select first iMuestra
		a.empresa, c.numcte , a.num_credito,b.fecha, '08', c.num_tarjeta, 'E1','E1','1','0', today, user
		into cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert
	from bdicred:sd_maesdoshist a,
		bdicred:sd_tarjeta c,
		bdicred:sd_maesdoshist b,
		bdicred:sd_maecredanexo d
	where a.empresa = '001'
		and a.fecha = pFechaCorteAnt
		and b.fecha = pFechaCorte
		and a.empresa = b.empresa
		and a.empresa = c.empresa
		and a.empresa = d.empresa
		and a.num_credito = b.num_credito
		and a.num_credito = c.num_credito
		and a.num_credito = d.num_credito
		and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
		and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
		and c.secuencia = (select max(tar.secuencia)
						from bdicred:sd_tarjeta tar
						where tar.empresa = a.empresa
						and tar.num_credito = a.num_credito
						and tar.tipo_tarjeta ='T'
						and tar.status_tar = 'A')
		and c.tipo_tarjeta ='T'  and c.status_tar = 'A'
		and a.monto_vencido + a.mto_venc_trasp  = 0
		and b.monto_vencido + b.mto_venc_trasp  = 0
		and d.fecha_ult_pago <= a.fecha
		and (select count(d.empresa)
			from bdicred:sd_movhis d
			where d.empresa = b.empresa
			and d.fecha_mov > a.fecha
			and d.fecha_mov <= b.fecha
			and d.num_credito = b.num_credito
			and d.codigo_fun = '002'
			and d.codigo_ref NOT in (30,34,35,36,37,38,39,40,41,42,50,57,60,61,62,63,64,65,937,938)
			and d.reversado = 'N') = 0
			
			insert into bdicred:sd_muestra_edocta (empresa, numcte, num_credito, fecha_corte, tipo_logica, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, flag_automatico, flag_generacion, fecha_insert, usuario_insert)
							values (cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert);
	END FOREACH;
	--insert into bdicred:sd_muestra_edocta 
	
		
		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay InformaciÃÂ³n de clientes con estatus vigente a vigente sin movimientos';
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2108',cCodRet,cMensajeRet,'02') INTO cCodRet; 
		ELSE
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2108',cCodRet,cMensajeRet,'02') INTO cCodRet; 				
		END IF;	
	
			--------------------------------------VIGENTE A TRANSITORIO CON PAGOS--------------------------------------------
	--se inicializan variables para vuelta de uso
	LET scont	 = 0;	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realizÃÂ³ la consulta correctamente";	--LET iMuestra = 0;
	--Se obtiene numero de muestras de valores aleatorios a obtener.
		/*SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";*/
		
	--- OBTIENE EL UNIVERSO DEL PROCESO 2109 E INSERTA LA INFORMACION EN LA TABLA DE TRABAJO
	FOREACH
		select first iMuestra
			a.empresa, c.numcte , a.num_credito,b.fecha, '10', c.num_tarjeta, 'E1','E1','1','0', today, user
			into cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert
		from bdicred:sd_maesdoshist a,
			 bdicred:sd_tarjeta c ,
			 bdicred:sd_maesdoshist b, bdicred:sd_maecredanexo d
		where a.empresa = '001'
			and a.fecha = pFechaCorteAnt
			and b.fecha = pFechaCorte
			and a.empresa = b.empresa
			and a.empresa = c.empresa
			and a.empresa = d.empresa
			and a.num_credito = b.num_credito
			and a.num_credito = c.num_credito
			and a.num_credito = d.num_credito
			and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
			and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
			and c.secuencia = (select max(tar.secuencia)
						   from bdicred:sd_tarjeta tar
						   where tar.empresa = a.empresa
						   and tar.num_credito = a.num_credito
						   and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
			and c.tipo_tarjeta ='T'  and c.status_tar = 'A'
			and a.monto_vencido + a.mto_venc_trasp = 0
			and b.monto_vencido  > 0
			and (nvl((select  count(*)
				from bdicred:sd_movhis
				where empresa = '001'
				and fecha_mov > a.fecha
				and fecha_mov <=  b.fecha
				and num_credito = b.num_credito
				and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual)
				and codigo_ref = 1
				and reversado = 'N'),0)) > 0
			and d.fecha_ult_pago > a.fecha 
			and d.fecha_ult_pago <= b.fecha
			
			insert into bdicred:sd_muestra_edocta (empresa, numcte, num_credito, fecha_corte, tipo_logica, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, flag_automatico, flag_generacion, fecha_insert, usuario_insert)
							values (cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert);
	END FOREACH;
	--insert into bdicred:sd_muestra_edocta 


		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay InformaciÃÂ³n de clientes con estatus vigente a transitorio con pagos';
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2110',cCodRet,cMensajeRet,'02') INTO cCodRet; 
		ELSE
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2110',cCodRet,cMensajeRet,'02') INTO cCodRet; 				
		END IF;		
					--------------------------------------VIGENTE A TRANSITORIO SIN PAGOS--------------------------------------------
	--se inicializan variables para vuelta de uso
	LET scont	 = 0;	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realizÃÂ³ la consulta correctamente";	--LET iMuestra = 0;
	--Se obtiene numero de muestras de valores aleatorios a obtener.
		/*SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";*/
		
	--- OBTIENE EL UNIVERSO DEL PROCESO 2109 E INSERTA LA INFORMACION EN LA TABLA DE TRABAJO
	FOREACH
		select first iMuestra
			a.empresa, c.numcte , a.num_credito,b.fecha, '11', c.num_tarjeta, 'E1','E1','1','0', today, user
			into cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert
		from bdicred:sd_maesdoshist a,
			 bdicred:sd_tarjeta c ,
			 bdicred:sd_maecredanexo pag ,
			 bdicred:sd_maesdoshist b
		where a.empresa = '001'
			and a.fecha = pFechaCorteAnt
			and b.fecha = pFechaCorte
			and a.empresa = b.empresa
			and a.empresa = c.empresa
			and a.empresa = pag.empresa
			and a.num_credito = b.num_credito
			and a.num_credito = c.num_credito
			and a.num_credito = pag.num_credito
			and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
			and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
			and c.secuencia = (select max(tar.secuencia)
							from bdicred:sd_tarjeta tar
							where tar.empresa = a.empresa
							and tar.num_credito = a.num_credito
							and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
			and c.tipo_tarjeta ='T'  and c.status_tar = 'A'
			and a.monto_vencido + a.mto_venc_trasp = 0
			and b.monto_vencido  > 0
			and nvl(pag.fecha_ult_pago,date(1)) <= a.fecha
			
			insert into bdicred:sd_muestra_edocta (empresa, numcte, num_credito, fecha_corte, tipo_logica, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, flag_automatico, flag_generacion, fecha_insert, usuario_insert)
							values (cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert);
	END FOREACH;
	--insert into bdicred:sd_muestra_edocta 

	
		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay InformaciÃÂ³n de clientes con estatus vigente a transitorio sin pago';
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2111',cCodRet,cMensajeRet,'02') INTO cCodRet; 
		ELSE
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2111',cCodRet,cMensajeRet,'02') INTO cCodRet; 				
		END IF;
	--------------------------------------TRANSITORIO A VENCIDO CON PAGOS--------------------------------------------
	--se inicializan variables para vuelta de uso
	LET scont	 = 0;	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realizÃÂ³ la consulta correctamente";	--LET iMuestra = 0;
	--Se obtiene numero de muestras de valores aleatorios a obtener.
		/*SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";*/
		
	--- OBTIENE EL UNIVERSO DEL PROCESO 2109 E INSERTA LA INFORMACION EN LA TABLA DE TRABAJO
	FOREACH
		select first iMuestra
          a.empresa, c.numcte , a.num_credito,b.fecha, '12', c.num_tarjeta, 'E2','E3','1','0', today, user
		  into cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert
    from bdicred:sd_maesdoshist a,
         bdicred:sd_tarjeta c ,
         bdicred:sd_maecredanexo pag ,
         bdicred:sd_maesdoshist b
    where a.empresa = '001'
        and a.fecha = pFechaCorteAnt
		and b.fecha = pFechaCorte
        and a.empresa = b.empresa
        and a.empresa = c.empresa
        and a.empresa = pag.empresa
        and a.num_credito = b.num_credito
        and a.num_credito = c.num_credito
        and a.num_credito = pag.num_credito
        and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
		and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
        and c.secuencia = (select max(tar.secuencia)
                    from bdicred:sd_tarjeta tar
                    where tar.empresa = a.empresa
                    and tar.num_credito = a.num_credito
                    and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
        and c.tipo_tarjeta ='T'  and c.status_tar = 'A'
        and (a.monto_vencido  > 0 or nvl(a.act,-1) = 3)
        and (b.mto_venc_trasp > 0 or nvl(b.act,-1) > 3)
        and pag.fecha_ult_pago > a.fecha
        and pag.fecha_ult_pago <= b.fecha
		
		insert into bdicred:sd_muestra_edocta (empresa, numcte, num_credito, fecha_corte, tipo_logica, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, flag_automatico, flag_generacion, fecha_insert, usuario_insert)
							values (cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert);
	END FOREACH;
	 --insert into bdicred:sd_muestra_edocta 
    


		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay InformaciÃÂ³n de clientes con estatus transitorio a vencido con pagos';
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2112',cCodRet,cMensajeRet,'02') INTO cCodRet; 
		ELSE
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2112',cCodRet,cMensajeRet,'02') INTO cCodRet; 				
		END IF;	
		--------------------------------------TRANSITORIO A VENCIDO SIN PAGOS--------------------------------------------
	--se inicializan variables para vuelta de uso
	LET scont	 = 0;	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realizÃÂ³ la consulta correctamente";	--LET iMuestra = 0;
	--Se obtiene numero de muestras de valores aleatorios a obtener.
		/*SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";*/
		
		--- OBTIENE EL UNIVERSO DEL PROCESO 2109 E INSERTA LA INFORMACION EN LA TABLA DE TRABAJO
		FOREACH
		
			select first iMuestra
				  a.empresa, c.numcte , a.num_credito,b.fecha, '13', c.num_tarjeta, 'E2','E3','1','0', today, user
				  into cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert
			from bdicred:sd_maesdoshist a, bdicred:sd_tarjeta c , bdicred:sd_maecredanexo pag ,
				 bdicred:sd_maesdoshist b
			where a.empresa = '001'
				and a.fecha = pFechaCorteAnt
				and b.fecha = pFechaCorte
				and a.empresa = b.empresa
				and a.empresa = c.empresa
				and a.empresa = pag.empresa
				and a.num_credito = b.num_credito
				and a.num_credito = c.num_credito
				and a.num_credito = pag.num_credito
				and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
				and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
				and c.secuencia = (select max(tar.secuencia)
							 from bdicred:sd_tarjeta tar
							  where tar.empresa = a.empresa
							 and tar.num_credito = a.num_credito
							 and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
				and c.tipo_tarjeta ='T'  and c.status_tar = 'A'
				and (a.monto_vencido  > 0 or nvl(a.act,-1) = 3)
				and (b.mto_venc_trasp > 0 or nvl(b.act,-1) > 3)
				and nvl(pag.fecha_ult_pago,date(1)) <= a.fecha
				
				insert into bdicred:sd_muestra_edocta (empresa, numcte, num_credito, fecha_corte, tipo_logica, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, flag_automatico, flag_generacion, fecha_insert, usuario_insert)
							values (cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert);
		END FOREACH;
	--insert into bdicred:sd_muestra_edocta 
    

		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay InformaciÃÂ³n de clientes con estatus transitorio a vencido sin pagos';
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2113',cCodRet,cMensajeRet,'02') INTO cCodRet; 
		ELSE
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2113',cCodRet,cMensajeRet,'02') INTO cCodRet; 				
		END IF;
		
	
		------------------------------TOTALERO A VIGENTE NO TOTALERO CON PAGOS-----------------------------------------------------------------------
		--se inicializan variables para vuelta de uso
	LET scont	 = 0;	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realizÃÂ³ la consulta correctamente";	--LET iMuestra = 0;
	--Se obtiene numero de muestras de valores aleatorios a obtener.
		/*SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";*/
		
		--- OBTIENE EL UNIVERSO DEL PROCESO 2109 E INSERTA LA INFORMACION EN LA TABLA DE TRABAJO
		select first iMuestra
          a.empresa, a.num_credito,b.fecha, '14' as tipo_logica,
          'E1' as status_anterior ,'E1' as status_actual,'1' as flag_automatico,'0' as flag_generacion, today as fecha_insert, user as usuario
   from bdicred:sd_maesdoshist a,
         bdicred:sd_maesdoshist b
         ,bdicred:sd_maecredanexo d
    where a.empresa = '001'
        and a.fecha = pFechaCorteAnt
		and b.fecha = pFechaCorte
        and a.empresa = b.empresa
        and a.empresa = d.empresa
        and a.num_credito = b.num_credito
        and a.num_credito = d.num_credito 
        and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
		and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
        and a.sdo_cap_insoluto <= 0
        and b.sdo_cap_insoluto > 0
        and d.fecha_ult_pago > a.fecha
        and d.fecha_ult_pago <= b.fecha
        and a.sdo_cap_insoluto <= 
            (select sum(monto)
            from bdicred:sd_movhis
            where empresa = '001'
            and a.num_credito = num_credito
            and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual)
            and codigo_ref = 1
            and fecha_mov > a.fecha - 1 UNITS MONTH
            and fecha_mov <=  a.fecha
            and reversado = 'N') 
		INTO temp tabla14 with no log;

	FOREACH
		select a.empresa,t.numcte ,a.num_credito,a.fecha,a.tipo_logica,t.num_tarjeta,a.status_anterior,a.status_actual,a.flag_automatico, a.flag_generacion,a.fecha_insert ,a.usuario 
				into cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert
		from tabla14 a ,bdicred:sd_tarjeta t
	where a.empresa = t.empresa
		and a.num_credito = t.num_credito
		and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
		and t.secuencia = (select max(tar.secuencia)
                    from bdicred:sd_tarjeta tar
                    where tar.empresa = a.empresa
                    and tar.num_credito = a.num_credito
                    and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
        and t.tipo_tarjeta ='T'  and t.status_tar = 'A'
		
		insert into bdicred:sd_muestra_edocta (empresa, numcte, num_credito, fecha_corte, tipo_logica, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, flag_automatico, flag_generacion, fecha_insert, usuario_insert)
							values (cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert);
	END FOREACH;
    --insert into bdicred:sd_muestra_edocta
	
	
		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay InformaciÃÂ³n de clientes con estatus totalero a vigente no totalero con pagos';
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2114',cCodRet,cMensajeRet,'02') INTO cCodRet; 
		ELSE
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2114',cCodRet,cMensajeRet,'02') INTO cCodRet; 				
		END IF;	
	-------------------------------------------TOTALERO A VIGENTE NO TOTALERO SIN PAGOS-----------------------------------------------
	--se inicializan variables para vuelta de uso
	LET scont	 = 0;	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realizÃÂ³ la consulta correctamente";	--LET iMuestra = 0;
	--Se obtiene numero de muestras de valores aleatorios a obtener.
		/*SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";*/

		--- OBTIENE EL UNIVERSO DEL PROCESO 2109 E INSERTA LA INFORMACION EN LA TABLA DE TRABAJO
		
	select first iMuestra
          a.empresa,  a.num_credito,b.fecha, '15' as tipo_logica,
          'E1' as status_anterior ,'E1' as status_actual,'1' as flag_automatico,'0' as flag_generacion, today as fecha_insert, user as usuario
    from bdicred:sd_maesdoshist a,
          bdicred:sd_maesdoshist b
         ,bdicred:sd_maecredanexo d
    where a.empresa = '001'
        and a.fecha = pFechaCorteAnt
		and b.fecha = pFechaCorte 
        and a.empresa = b.empresa
        and a.empresa = d.empresa
        and a.num_credito = b.num_credito
        and a.num_credito = d.num_credito 
        and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte >b.fecha - 1 units year)
		and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
        and a.sdo_cap_insoluto <= 0
        and b.sdo_cap_insoluto > 0
        and d.fecha_ult_pago <= a.fecha
        and a.sdo_cap_insoluto <= 
            (select sum(monto)
            from bdicred:sd_movhis
            where empresa = '001'
            and a.num_credito = num_credito
            and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual)
            and codigo_ref = 1
            and fecha_mov > a.fecha - 1 UNITS MONTH
            and fecha_mov <=  a.fecha
            and reversado = 'N') 
    into temp tabla15 with no log;
     
	FOREACH
		select a.empresa,t.numcte ,a.num_credito,a.fecha,a.tipo_logica,t.num_tarjeta,a.status_anterior,a.status_actual,a.flag_automatico, a.flag_generacion,a.fecha_insert ,a.usuario 
		into cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert
		from tabla15 a ,bdicred:sd_tarjeta t
	where a.empresa = t.empresa
		and a.num_credito = t.num_credito
		and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
		and t.secuencia = (select max(tar.secuencia)
                    from bdicred:sd_tarjeta tar
                    where tar.empresa = a.empresa
                    and tar.num_credito = a.num_credito
                    and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
        and t.tipo_tarjeta ='T'  and t.status_tar = 'A'
		
		insert into bdicred:sd_muestra_edocta (empresa, numcte, num_credito, fecha_corte, tipo_logica, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, flag_automatico, flag_generacion, fecha_insert, usuario_insert)
							values (cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert);
	END FOREACH;
    --insert into bdicred:sd_muestra_edocta
	
		
		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay InformaciÃÂ³n de clientes con estatus totalero a vigente no totalero sin pagos';
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2115',cCodRet,cMensajeRet,'02') INTO cCodRet; 
		ELSE
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2115',cCodRet,cMensajeRet,'02') INTO cCodRet; 				
		END IF;	
	-------------------------------VENCIDO A TOTALERO-----------------------------------------------------------
	--se inicializan variables para vuelta de uso
	LET scont	 = 0;	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realizÃÂ³ la consulta correctamente";	--LET iMuestra = 0;
	--Se obtiene numero de muestras de valores aleatorios a obtener.
		/*SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";*/
	
	--- OBTIENE EL UNIVERSO DEL PROCESO 2109 E INSERTA LA INFORMACION EN LA TABLA DE TRABAJO
	
	select first iMuestra
          a.empresa, a.num_credito,b.fecha, '16' as tipo_logica,
         'E3' as status_anterior ,'E1' as status_actual,'1' as flag_automatico,'0' as flag_generacion, today as fecha_insert, user as usuario
    from bdicred:sd_maesdoshist a,
         bdicred:sd_maesdoshist b
    where a.empresa = '001'
        and a.fecha = pFechaCorteAnt
		and b.fecha = pFechaCorte
        and a.empresa = b.empresa
        and a.num_credito = b.num_credito
        and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
		and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
        and (a.mto_venc_trasp + a.cap_tras_no_venci > 0 or nvl(a.act,-1) > 3)
        and b.sdo_cap_insoluto <= 0
       into temp tabla16 with no log;

	FOREACH
		select a.empresa,t.numcte ,a.num_credito,a.fecha,a.tipo_logica,t.num_tarjeta,a.status_anterior,a.status_actual,a.flag_automatico, a.flag_generacion,a.fecha_insert ,a.usuario 
		into cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert
		from tabla16 a ,bdicred:sd_tarjeta t
		where a.empresa = t.empresa
			and a.num_credito = t.num_credito
			and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
			and t.secuencia = (select max(tar.secuencia)
						from bdicred:sd_tarjeta tar
						where tar.empresa = a.empresa
						and tar.num_credito = a.num_credito
						and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
			and t.tipo_tarjeta ='T'  and t.status_tar = 'A'
			
			insert into bdicred:sd_muestra_edocta (empresa, numcte, num_credito, fecha_corte, tipo_logica, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, flag_automatico, flag_generacion, fecha_insert, usuario_insert)
							values (cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert);
	END FOREACH;
	--insert into bdicred:sd_muestra_edocta
	
	
	 
		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay InformaciÃÂ³n de clientes con estatus vencido a totalero';
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2116',cCodRet,cMensajeRet,'02') INTO cCodRet; 
		ELSE
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2116',cCodRet,cMensajeRet,'02') INTO cCodRet; 				
		END IF;	
-------------------------------TRANSITORIO A TOTALERO-----------------------------------------------------------
	--se inicializan variables para vuelta de uso
	LET scont	 = 0;	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realizÃÂ³ la consulta correctamente";	--LET iMuestra = 0;
	--Se obtiene numero de muestras de valores aleatorios a obtener.
		/*SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";*/
	
	--- OBTIENE EL UNIVERSO DEL PROCESO 2109 E INSERTA LA INFORMACION EN LA TABLA DE TRABAJO
	FOREACH
		select first iMuestra
          a.empresa, c.numcte , a.num_credito,b.fecha, '17', c.num_tarjeta, 'E1','E1','1','0', today, user
		  into cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert
    from bdicred:sd_maesdoshist a,
         bdicred:sd_tarjeta c,
         bdicred:sd_maesdoshist b
    where a.empresa = '001'
        and a.fecha = pFechaCorteAnt
		and b.fecha = pFechaCorte
        and a.empresa = b.empresa
        and a.empresa = c.empresa
        and a.num_credito = b.num_credito
        and a.num_credito = c.num_credito
        and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
		and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
        and c.secuencia = (select max(tar.secuencia)
                  from bdicred:sd_tarjeta tar
                  where tar.empresa = a.empresa
                  and tar.num_credito = a.num_credito
                  and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
        and c.tipo_tarjeta ='T'  and c.status_tar = 'A'
        and (a.monto_vencido > 0 or nvl(a.act,-1) = 1)
        and b.monto_vencido + b.mto_venc_trasp = 0
        and b.sdo_cap_insoluto <= 0
			
			insert into bdicred:sd_muestra_edocta (empresa, numcte, num_credito, fecha_corte, tipo_logica, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, flag_automatico, flag_generacion, fecha_insert, usuario_insert)
							values (cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert);
	END FOREACH;
	  -- insert into bdicred:sd_muestra_edocta 
    

		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay InformaciÃÂ³n de clientes con estatus vencido a vigente';
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2117',cCodRet,cMensajeRet,'02') INTO cCodRet; 
		ELSE
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2117',cCodRet,cMensajeRet,'02') INTO cCodRet; 				
		END IF;	
							--------------------------------------TOTALERO A TOTALERO--------------------------------------------
	--se inicializan variables para vuelta de uso
	LET scont	 = 0;	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realizÃÂ³ la consulta correctamente";	--LET iMuestra = 0;
	--Se obtiene numero de muestras de valores aleatorios a obtener.
		/*SELECT TRIM(valor)::INTEGER
		INTO iMuestra
		FROM bdicred:"informix".sd_param 
		WHERE empresa = "001" 
		AND cod_param = "128";*/
		
	--Se consulta la informaciÃÂ³n de los clientes que cumplen con el estatus de totalero a totalero.		
	select first iMuestra
          a.empresa, a.num_credito,b.fecha, '09' as tipo_logica, 'E1' as status_anterior ,'E1' as status_actual,'1' as
            flag_automatico,'0' as flag_generacion, today as fecha_insert, user as usuario
   from bdicred:sd_maesdoshist a,
         bdicred:sd_maesdoshist b
    where a.empresa = '001'
		and a.fecha = pFechaCorteAnt
		and b.fecha = pFechaCorte
        and a.empresa = b.empresa
        and a.num_credito = b.num_credito
        and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
		and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
        and a.sdo_cap_insoluto <= 0
        and b.sdo_cap_insoluto <= 0
        and (select count(empresa)
            from bdicred:sd_movhis 
            where empresa = a.empresa
             and fecha_mov > a.fecha - 1 UNITS MONTH
             and fecha_mov <= a.fecha
             and num_credito = a.num_credito
             and codigo_fun = '002'
             and codigo_ref in(30,34,35,36,37,38,39,40,41,42,50,57,60,61,62,63,64,65,937,938)
             and reversado = 'N') >= 1
        and (select count(empresa)
            from bdicred:sd_movhis 
            where empresa = a.empresa
             and fecha_mov > a.fecha 
             and fecha_mov <= b.fecha
             and num_credito = a.num_credito
             and codigo_fun = '002'
             and codigo_ref in(30,34,35,36,37,38,39,40,41,42,50,57,60,61,62,63,64,65,937,938)
             and reversado = 'N')>= 1
		into temp tabla9 with no log;

	FOREACH
		select a.empresa,t.numcte ,a.num_credito,a.fecha,a.tipo_logica,t.num_tarjeta,a.status_anterior,a.status_actual,a.flag_automatico, a.flag_generacion,a.fecha_insert ,a.usuario 
		into cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert
		from tabla9 a ,bdicred:sd_tarjeta t
	where a.empresa = t.empresa
		and a.num_credito = t.num_credito
		and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
		and t.secuencia = (select max(tar.secuencia)
                    from bdicred:sd_tarjeta tar
                    where tar.empresa = a.empresa
                    and tar.num_credito = a.num_credito
                    and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
        and t.tipo_tarjeta ='T'  and t.status_tar = 'A'
		
		insert into bdicred:sd_muestra_edocta (empresa, numcte, num_credito, fecha_corte, tipo_logica, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, flag_automatico, flag_generacion, fecha_insert, usuario_insert)
							values (cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert);
	END FOREACH;
    --insert into bdicred:sd_muestra_edocta
	

		LET scont = dbinfo("sqlca.sqlerrd2");
		IF scont = 0 THEN
			LET cCodRet= '000002';
			LET cMensajeRet= 'No hay InformaciÃÂ³n de clientes con estatus vencido a vigente';
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2109',cCodRet,cMensajeRet,'02') INTO cCodRet; 
		ELSE
			EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2109',cCodRet,cMensajeRet,'02') INTO cCodRet; 				
		END IF;
		
	END IF;	
	
--- SE AGREGAN LOGICAS DE ETAPAS
-- ETAPA E1 A E2

		---------------------------------------ETAPA 1 A ETAPA 2-------------------------------------------------

	LET scont	 = 0;	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realiza la consulta correctamente";	

	FOREACH
		select first iMuestra
			a.empresa, c.numcte , a.num_credito,b.fecha, '19', c.num_tarjeta, 'E1','E2','1','0', today, user
		into cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert
		from bdicred:sd_maesdoshist a,
			bdicred:sd_tarjeta c,
			bdicred:sd_maesdoshist b
		where a.empresa = '001'
			and a.fecha = pFechaCorteAnt
			and b.fecha = pFechaCorte
			and a.empresa = b.empresa
			and a.empresa = c.empresa
			and a.num_credito = b.num_credito
			and a.num_credito = c.num_credito
			and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
			and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
			and c.secuencia = (select max(tar.secuencia)
							from bdicred:sd_tarjeta tar
							where tar.empresa = a.empresa
							and tar.num_credito = a.num_credito
							and tar.tipo_tarjeta ='T'
							and tar.status_tar = 'A')
			and c.tipo_tarjeta ='T' 
			and c.status_tar = 'A'
			and nvl(a.act,-1) = 1
			and nvl(b.act,-1) = 2
		
		insert into bdicred:sd_muestra_edocta (empresa, numcte, num_credito, fecha_corte, tipo_logica, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, flag_automatico, flag_generacion, fecha_insert, usuario_insert)
						values (cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert);
	END FOREACH; 
				
	LET scont = dbinfo("sqlca.sqlerrd2");
	IF scont = 0 THEN
		LET cCodRet= '000002';
		LET cMensajeRet= 'No hay informacion de clientes con estatus E1 A E2';
		EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2110',cCodRet,cMensajeRet,'02') INTO cCodRet; 
	ELSE
		EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2110',cCodRet,cMensajeRet,'02') INTO cCodRet; 				
	END IF;	
	
-- ETAPA E2 A E2	
	LET scont	 = 0;	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realiza la consulta correctamente";	

	FOREACH
		select first iMuestra
			a.empresa, c.numcte , a.num_credito,b.fecha, '20', c.num_tarjeta, 'E2','E2','1','0', today, user
		into cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert
		from bdicred:sd_maesdoshist a,
			bdicred:sd_tarjeta c,
			bdicred:sd_maesdoshist b
		where a.empresa = '001'
			and a.fecha = pFechaCorteAnt
			and b.fecha = pFechaCorte
			and a.empresa = b.empresa
			and a.empresa = c.empresa
			and a.num_credito = b.num_credito
			and a.num_credito = c.num_credito
			and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
			and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
			and c.secuencia = (select max(tar.secuencia)
							from bdicred:sd_tarjeta tar
							where tar.empresa = a.empresa
							and tar.num_credito = a.num_credito
							and tar.tipo_tarjeta ='T'
							and tar.status_tar = 'A')
			and c.tipo_tarjeta ='T' 
			and c.status_tar = 'A'
			and nvl(a.act,-1) = 2
			and nvl(b.act,-1) = 3
		
		insert into bdicred:sd_muestra_edocta (empresa, numcte, num_credito, fecha_corte, tipo_logica, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, flag_automatico, flag_generacion, fecha_insert, usuario_insert)
						values (cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert);
	END FOREACH; 
				
	LET scont = dbinfo("sqlca.sqlerrd2");
	IF scont = 0 THEN
		LET cCodRet= '000002';
		LET cMensajeRet= 'No hay informacion de clientes con estatus E2 A E2';
		EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2111',cCodRet,cMensajeRet,'02') INTO cCodRet; 
	ELSE
		EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2111',cCodRet,cMensajeRet,'02') INTO cCodRet; 				
	END IF;		

-- ETAPA E2 A E3

		---------------------------------------ETAPA 2 A ETAPA 3-------------------------------------------------

	LET scont	 = 0;	LET cCodRet  = "000000";	LET cMensajeRet  = "Se realiza la consulta correctamente";	

	FOREACH
		select first iMuestra
			a.empresa, c.numcte , a.num_credito,b.fecha, '21', c.num_tarjeta, 'E2','E3','1','0', today, user
		into cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert
		from bdicred:sd_maesdoshist a,
			bdicred:sd_tarjeta c,
			bdicred:sd_maesdoshist b
		where a.empresa = '001'
			and a.fecha = pFechaCorteAnt
			and b.fecha = pFechaCorte
			and a.empresa = b.empresa
			and a.empresa = c.empresa
			and a.num_credito = b.num_credito
			and a.num_credito = c.num_credito
			and a.num_credito not in (select num_credito from bdicred:sd_muestra_edocta where a.empresa = empresa and fecha_corte > b.fecha - 1 units year)
			and a.num_credito not in (select cuenta from sd_edelec_alta_serv_muestras)
			and c.secuencia = (select max(tar.secuencia)
							from bdicred:sd_tarjeta tar
							where tar.empresa = a.empresa
							and tar.num_credito = a.num_credito
							and tar.tipo_tarjeta ='T'
							and tar.status_tar = 'A')
			and c.tipo_tarjeta ='T' 
			and c.status_tar = 'A'
			and nvl(a.act,-1) = 3
			and nvl(b.act,-1) > 3
		
		insert into bdicred:sd_muestra_edocta (empresa, numcte, num_credito, fecha_corte, tipo_logica, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, flag_automatico, flag_generacion, fecha_insert, usuario_insert)
						values (cEmpresa, cNumClie, cNumCredito, cFechaCorte, cTipoLogica, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cFlagAutomatico, cFlagGeneracion, cFechaInsert, cUsuarioInsert);
	END FOREACH; 
				
	LET scont = dbinfo("sqlca.sqlerrd2");
	IF scont = 0 THEN
		LET cCodRet= '000002';
		LET cMensajeRet= 'No hay informacion de clientes con estatus E2 A E3';
		EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2112',cCodRet,cMensajeRet,'02') INTO cCodRet; 
	ELSE
		EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2112',cCodRet,cMensajeRet,'02') INTO cCodRet; 				
	END IF;	


-- FIN SE AGREGAN ETAPA

	
	-- SE LIMPIA LA TABLA DE RESPALDO DE MUESTRAS
	DELETE bdicred:'informix'.sd_resp_muestra_edocta;
	
	-- SE REALIZA EL RESPALDO DE LAS MUESTRAS PARA SU POSTERIOR CONVERSION EN ARCHIVO XLS EN LA APLICACION
	FOREACH
		SELECT num_credito, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, tipo_logica, fecha_corte
		into cNumCredito, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cTipoLogica, cFechaCorte
		FROM bdicred:'informix'.sd_muestra_edocta
		WHERE fecha_corte = pFechaCorte
	
		INSERT INTO bdicred:'informix'.sd_resp_muestra_edocta(num_credito, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, tipo_logica, fecha_corte)
		values (cNumCredito, cNumTarjeta, cStatusMesAnterior, cStatusMesActual, cTipoLogica, cFechaCorte);
	END FOREACH;
	
	
	
	

	
	EXECUTE PROCEDURE 'informix'.sp_inserta_bitacora(pEmpresa,'2000',cCodRet,cMensajeRet,'03')		INTO cCodRet;
	RETURN cCodRet,cMensajeRet;
END;
END PROCEDURE;