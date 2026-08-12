CREATE PROCEDURE "informix".sp_reportes_cobranza_resultados_campanias()
RETURNING CHAR(6) AS Cod_Ret, CHAR(100) AS Mens_Ret;
--  execute PROCEDURE "informix".sp_reportes_cobranza_resultados_campanias();
--Declaración de variables.
DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr         	INTEGER;
DEFINE cCodRet      		CHAR(06);
DEFINE cMensajePagoMin  	CHAR(150);
DEFINE cErrorInfo       	CHAR(100);
DEFINE cMensajeRet    		CHAR(100);
DEFINE cEmpresa				CHAR(3);
DEFINE vFechaCorte			date;
DEFINE vMora				SMALLINT;
DEFINE vTipoCobranza		CHAR(1);
DEFINE cNumCte				CHAR(20);
DEFINE vTelVal				INTEGER;
DEFINE i					INTEGER;
DEFINE vTotCte_Y			INTEGER;
DEFINE Y 					INTEGER;
DEFINE vTotCte_O			INTEGER;
DEFINE O					INTEGER;
DEFINE vCteSinDatos			INTEGER;
DEFINE vSinDat				INTEGER;
DEFINE vDia 				CHAR(2);
DEFINE vMes 				CHAR(2);
DEFINE vAnio 				CHAR(4);
DEFINE vsql                 CHAR(1024);
DEFINE vConCel				INTEGER;
DEFINE vCteConCel 			INTEGER;
DEFINE vConTelCasaYCel		INTEGER;
DEFINE vCteConTelCasaYCel	INTEGER;
DEFINE vTelCasa_SinCel		INTEGER;
DEFINE vCte_TelCasa_SinCel	INTEGER;
DEFINE vSin_Tel				INTEGER;
DEFINE vCteSin_Tel			INTEGER;
DEFINE vCodigo_Retorno      CHAR(6);
DEFINE vMensaje_Retorno     CHAR(80);
DEFINE vTotCte				INTEGER;
DEFINE vPagoMinimo			DECIMAL(18,2);
DEFINE vTotalPagoMinin		DECIMAL(18,2);
DEFINE vIntVdo				DECIMAL(18,2);
DEFINE vIntMoratorio		DECIMAL(18,2);
DEFINE vIvaIntVdo			DECIMAL(18,2);
DEFINE vPagosVdos			DECIMAL(18,2);
DEFINE vIvaIntMoratorio		DECIMAL(18,2);
DEFINE vIntMes				DECIMAL(18,2);
DEFINE vIvaIntMes			DECIMAL(18,2);
DEFINE vIntVig				DECIMAL(18,2);
DEFINE vIvaIntVig			DECIMAL(18,2);
DEFINE vPteMesAnt			DECIMAL(18,2);
DEFINE vTotalIntPeriodo     DECIMAL(18,2);
DEFINE vTotalIntMoratorio	DECIMAL(18,2);
DEFINE vSaldoTotal			DECIMAL(18,2);
DEFINE vSdoTotal			DECIMAL(18,2);

DEFINE dPagoNoGeneraInt     DECIMAL(18,2);
DEFINE dPagoMinimo          DECIMAL(18,2);
DEFINE dSdoCapInsoluto		DECIMAL(18,2);
DEFINE dSdoRetenido			DECIMAL(18,2);
DEFINE dIntVdo				DECIMAL(18,2);
DEFINE dIntMoratorio		DECIMAL(18,2);
DEFINE dIvaIntVdo			DECIMAL(18,2);
DEFINE dPagosVdos			DECIMAL(18,2);
DEFINE dIvaIntMoratorio		DECIMAL(18,2);
DEFINE dIntMes				DECIMAL(18,2);
DEFINE dIvaIntMes			DECIMAL(18,2);
DEFINE dIntVig				DECIMAL(18,2);
DEFINE dIvaIntVig			DECIMAL(18,2);
DEFINE dMontoIntIva			DECIMAL(18,2);
DEFINE iNumCtes				INTEGER;
DEFINE dCapitalMtoCuota			DECIMAL(18,2);
DEFINE dCapitalMtoCuotaTotal	DECIMAL(18,2);
DEFINE dCapitalMtoCuotaAnts		DECIMAL(18,2);
DEFINE dCapitalMtoCuotaAntsTotal	DECIMAL(18,2);
DEFINE dInteresesMes		DECIMAL(18,2);
DEFINE dInteresesMesTotal	DECIMAL(18,2);
DEFINE dIntMoratorioTotal	DECIMAL(18,2);
DEFINE dTotalPago			DECIMAL(18,2);
DEFINE dPagoParaliquidar	DECIMAL(18,2);

DEFINE iPagoVenc				SMALLINT;
DEFINE sSecuenciaTel			SMALLINT;
DEFINE sSecuenciaMail			SMALLINT;
DEFINE iContadorTelValido		INTEGER;
DEFINE iContadorTelyMail		INTEGER;
DEFINE iContadorTeloMail		INTEGER;
DEFINE iContadorCtesSinDatos	INTEGER;

DEFINE sSecuenciaTelCel			SMALLINT;
DEFINE sSecuenciaTelCasa		SMALLINT;
DEFINE iContadorTelCelValido	INTEGER;
DEFINE iContadorTelCelyTelCasa	INTEGER;
DEFINE iContadorTelCeloTelCasa	INTEGER;
DEFINE cNumCredito		CHAR(20);
DEFINE cProceso         CHAR(4);
DEFINE cMensaje         VARCHAR(150);

DEFINE vNum_Tarjeta		CHAR(20);
DEFINE vMoratorio		DECIMAL(18,2);
DEFINE vSdoTotLiquidar	DECIMAL(18,2);
DEFINE vSdoVencTot		DECIMAL(18,2);
DEFINE vMensualidadActual DECIMAL(18,2);
DEFINE vStatusCred		CHAR(2);
DEFINE vFechUltPago		DATE;
DEFINE vPagoUnaMora		DECIMAL(18,2);
DEFINE vNumProducto		CHAR(4);
DEFINE vNoVencidoIni    INTEGER;
DEFINE vNoVencidoFin	INTEGER;
DEFINE vNumCiudad		SMALLINT;
DEFINE vNombreCiudad	CHAR(30);
DEFINE vNombreRegion	CHAR(30);
DEFINE vFechaCorteAnterior date;
DEFINE vNumeroDePagos	INTEGER;
DEFINE vMontoDePagos    DECIMAL(18,2);
DEFINE vResultadoGestion smallint;
DEFINE vDescripcion		CHAR(50);

--Inicialización de variables.
LET iSqlErr                 = 0;
LET iIsamErr              	= 0;
LET cErrorInfo            	= "";
LET cCodRet           	= "000000";
LET cMensajePagoMin			= '';
LET cCodRet              	= "000000";
LET cMensajeRet      		= "El proceso de REPORTES RESULTADO COBRANZA se realizó correctamente";
LET cEmpresa				= '001';
LET vFechaCorte 			= DATE(1);
LET vMora					= 0;
LET vTipoCobranza			='';
LET cNumCte					='';
LET vTelVal					= 0;
LET i						= 0;
LET vTotCte_Y				= 0;
LET Y						= 0;
LET vTotCte_O				= 0;
LET O						= 0;
LET vCteSinDatos			= 0;
LET vSinDat					= 0;
LET vDia 					= "";
LET vMes 					= "";
LET vAnio 					= "";
LET vsql 					= '';
LET vConCel					= 0;
LET vCteConCel   			= 0;
LET vConTelCasaYCel			= 0;
LET vCteConTelCasaYCel		= 0;
LET vTelCasa_SinCel			= 0;
LET vCte_TelCasa_SinCel		= 0;
LET vSin_Tel				= 0;
LET vCteSin_Tel				= 0;
LET vCodigo_Retorno      	= '';
LET vMensaje_Retorno     	= '';
LET vTotCte					= 0;
LET vPagoMinimo				= 0;
LET vTotalPagoMinin			= 0;
LET vIntVdo					= 0;
LET vIntMoratorio			= 0;
LET vIvaIntVdo				= 0;
LET vPagosVdos				= 0;
LET vIvaIntMoratorio		= 0;
LET vIntMes					= 0;
LET vIvaIntMes				= 0;
LET vIntVig					= 0;
LET vIvaIntVig				= 0;
LET vPteMesAnt				= 0;
LET vTotalIntPeriodo		= 0;
LET vTotalIntMoratorio		= 0;
LET vSaldoTotal				= 0;
LET vSdoTotal				= 0;

LET iPagoVenc				= 0;
LET sSecuenciaTel			= 0;
LET sSecuenciaMail			= 0;
LET iContadorTelValido		= 0;
LET iContadorTelyMail		= 0;
LET iContadorTeloMail		= 0;
LET iContadorCtesSinDatos	= 0;

LET sSecuenciaTelCel		= 0;
LET sSecuenciaTelCasa		= 0;
LET iContadorTelCelValido	= 0;
LET iContadorTelCelyTelCasa	= 0;
LET iContadorTelCeloTelCasa	= 0;

LET dPagoNoGeneraInt    = 0;
LET dPagoMinimo         = 0;
LET dSdoCapInsoluto		= 0;
LET dSdoRetenido		= 0;
LET dIntVdo				= 0;
LET dIntMoratorio		= 0;
LET dIvaIntVdo			= 0;
LET dPagosVdos			= 0;
LET dIvaIntMoratorio	= 0;
LET dIntMes				= 0;
LET dIvaIntMes			= 0;
LET dIntVig				= 0;
LET dIvaIntVig			= 0;
LET dSdoCapInsoluto		= 0;
LET dSdoRetenido		= 0;
LET dMontoIntIva		= 0;
LET iNumCtes			= 0;
LET dCapitalMtoCuota	= 0;
LET dCapitalMtoCuotaTotal	= 0;
LET dCapitalMtoCuotaAnts	= 0;
LET dCapitalMtoCuotaAntsTotal	= 0;
LET dInteresesMes		= 0;
LET dInteresesMesTotal	= 0;
LET dIntMoratorioTotal	= 0;
LET dTotalPago			= 0;
LET dPagoParaliquidar	= 0;
LET cNumCredito			= '';
LET cProceso			= '2096';
LET cMensaje            = '';

LET vNum_Tarjeta		='';
LET vMoratorio			= 0;
LET vSdoTotLiquidar		= 0;
LET vSdoVencTot			= 0;
LET vMensualidadActual  = 0;
LET vStatusCred			= '';
LET vFechUltPago		= date(1);
LET vPagoUnaMora		= 0;
LET vNumProducto		= '';
LET vNoVencidoIni		= 0;
LET vNoVencidoFin       = 0;
LET vNumCiudad			= 0;
LET vNombreCiudad		= '';
LET vNombreRegion		= '';
LET vFechaCorteAnterior	= DATE(1);
LET vNumeroDePagos      = 0;
LET vMontoDePagos		= 0;
LET vResultadoGestion	= 0;
LET vDescripcion		= 0;


BEGIN
--Errores no controlados.
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    LET cCodRet= iSqlErr;
    LET cMensajeRet= cErrorInfo;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, cMensajeRet, '02')RETURNING cCodRet;
    RETURN cCodRet, cMensajeRet;
END EXCEPTION;

	--Rastrea actividad.
	--SET DEBUG FILE TO "/informix/ALL/sp_reportes_cobranza_resultados_campanias.out";
	--TRACE ON;

CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, cMensaje, '01')RETURNING cCodRet;

if cCodRet != '000000' then
--    let cCodRet = cCodRet;
--    let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
    let cMensajeRet  = 'Error en el llamado al sp_inserta_bitacora_cob.';
    RETURN cCodRet, cMensajeRet;
end if;


SET LOCK MODE TO WAIT 3;
SET ISOLATION DIRTY READ;

--Sacamos la fecha suponiendo que se va a correr el dia 21
select fecha_hoy
into vFechaCorte
from bdicred:sd_fechas where empresa = cEmpresa;

let vFechaCorte = MDY(month(vFechaCorte),'20',year(vFechaCorte));


IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'tmp_resultados_cobranza' ) THEN
	truncate table tmp_resultados_cobranza drop storage;
ELSE
	CREATE TABLE "informix".tmp_resultados_cobranza(reporte CHAR(40), mora SMALLINT, num_ctes_1tel_valido INTEGER, num_ctes_y INTEGER, num_ctes_o INTEGER, num_ctes_sindatos INTEGER) EXTENT SIZE 32 NEXT SIZE 32;
	CREATE INDEX tmp_idx_reporte ON tmp_resultados_cobranza(reporte);
	UPDATE STATISTICS HIGH FOR TABLE tmp_resultados_cobranza;
END IF;

select num_credito,numcte,pago_venc
  from bdicobranza:cb_cat_directorio_cte
 where empresa = cEmpresa
   and tipo_cobranza = 'A'
   and numcte !=''
   and fecha_insert = vFechaCorte
   and num_producto = '6001'
into temp ctes_aprocesar with no log;

CREATE INDEX tmp_idx_numcte_mora ON ctes_aprocesar(numcte,pago_venc);
UPDATE STATISTICS HIGH FOR TABLE ctes_aprocesar;

--Genera mensaje de monitoreo
let cMensaje = 'Generando Reporte de cartera vencida vs. datos registrados ';
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING cCodRet;
--Genera mensaje de monitoreo

------------------------------Reporte de cartera vencida vs. datos registrados-----------------------------------------------------
--Sacamos el numero de moras existentes.
FOREACH WITH HOLD
	select distinct pago_venc
	into iPagoVenc
	from ctes_aprocesar

	FOREACH WITH HOLD
		select numcte
		  into cNumCte
		  from ctes_aprocesar
		where pago_venc = iPagoVenc

		select limit 1 secuencia
		  into sSecuenciaTel
		  from bdinteg:si_telefonos_actual
		 where numcte 		= cNumCte
		   and tipo_tel 	in (1,2,3,4)
		   and status_tel	= 'A';
		/* and cofetel 		= 'V';*/ --RQM 09 598"

		if sSecuenciaTel is null or sSecuenciaTel = '' then let sSecuenciaTel = 0; end if;

		select limit 1 secuencia
		  into sSecuenciaMail
		  from bdinteg:si_correos
		 where numcte = cNumCte
		   and tipo_correo in (1,2,3)
		   and status_correo ='A';

		if sSecuenciaMail is null or sSecuenciaMail = '' then let sSecuenciaMail = 0; end if;

		if sSecuenciaTel > 0 then let iContadorTelValido = iContadorTelValido + 1; end if;
		if sSecuenciaTel > 0 and sSecuenciaMail > 0 then let iContadorTelyMail = iContadorTelyMail + 1; end if;
		if sSecuenciaTel = 0 and sSecuenciaMail > 0 then let iContadorTeloMail = iContadorTeloMail + 1; end if;
		if sSecuenciaTel = 0 and sSecuenciaMail = 0 then let iContadorCtesSinDatos = iContadorCtesSinDatos + 1; end if;

	END FOREACH;
--Insertamos en tabla los datos para generar el reporte.
	begin work;
	insert into tmp_resultados_cobranza (reporte, mora, num_ctes_1tel_valido, num_ctes_y, num_ctes_o, num_ctes_sindatos )
								 values ('cartera_vencida_VS_datos_registrados', iPagoVenc, iContadorTelValido, iContadorTelyMail, iContadorTeloMail, iContadorCtesSinDatos);
	commit work;
--Insertamos en tabla los totales para generar el reporte.

--Limpiamos Variables.
LET iPagoVenc				= 0;
	LET sSecuenciaTel			= 0;
	LET sSecuenciaMail			= 0;
	LET iContadorTelValido		= 0;
	LET iContadorTelyMail		= 0;
	LET iContadorTeloMail		= 0;
	LET iContadorCtesSinDatos	= 0;
END FOREACH;

--Insertamos en tabla los totales para generar el reporte.
	begin work;
	select sum(num_ctes_1tel_valido), sum(num_ctes_y),sum(num_ctes_o),sum(num_ctes_sindatos)
	  into iContadorTelValido, iContadorTelyMail, iContadorTeloMail, iContadorCtesSinDatos
	  from tmp_resultados_cobranza
	 where reporte = 'cartera_vencida_VS_datos_registrados';

	insert into tmp_resultados_cobranza (reporte, mora, num_ctes_1tel_valido, num_ctes_y, num_ctes_o, num_ctes_sindatos )
								 values ('cartera_vencida_VS_datos_registrados', null, iContadorTelValido, iContadorTelyMail, iContadorTeloMail, iContadorCtesSinDatos);
	commit work;
--Insertamos en tabla los totales para generar el reporte.

-- Se genera un archivo plano con la información de reservas que inserta en la tabla sd_hist_reserva.
LET vDia = lpad(DAY(vFechaCorte),2,'00');
LET vMes = lpad(MONTH(vFechaCorte),2,'00');
LET vAnio = YEAR(vFechaCorte);

LET vsql = 'echo " unload to '''|| '/resplogifx/archivoscartera/reporte1.unl'''||" delimiter '|' "||
             '" > /resplogifx/archivoscartera/reporte1.sql';
system vsql;

LET vsql = 'echo "'||
             ' select mora, num_ctes_1tel_valido, num_ctes_y, num_ctes_o, num_ctes_sindatos from tmp_resultados_cobranza where reporte = ''cartera_vencida_VS_datos_registrados'' order by rowid  '||
             ' " >> /resplogifx/archivoscartera/reporte1.sql';
system trim(vsql);

LET vsql = 'dbaccess bdicobranza /resplogifx/archivoscartera/reporte1.sql';
system vsql;

LET vsql = "cp /resplogifx/archivoscartera/reporte1.unl /resplogifx/archivoscartera/rep_cartera_vencida_vs_dat_reg_"|| vDia || vMes || vAnio ||".txt ";
system vsql;

--LET vsql = "gzip /resplogifx/archivoscartera/rep_cartera_vencida_vs_dat_reg_"|| vDia || vMes || vAnio ||".txt ";
--system vsql;

LET vsql = "rm /resplogifx/archivoscartera/reporte1.unl ";
system vsql;

LET vsql = "rm /resplogifx/archivoscartera/reporte1.sql ";
system vsql;

--Genera mensaje de monitoreo
let cMensaje = 'Detalle de Telefonos Validos por Cofetel de Cartera Vencida ';
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING cCodRet;
--Genera mensaje de monitoreo

--Limpiamos Variables.
LET iPagoVenc				= 0;
LET sSecuenciaTel			= 0;
LET sSecuenciaMail			= 0;
LET iContadorTelValido		= 0;
LET iContadorTelyMail		= 0;
LET iContadorTeloMail		= 0;
LET iContadorCtesSinDatos	= 0;

------------------------------Detalle de Telefonos Validos por Cofetel de Cartera Vencida-----------------------------------------------------
--Sacamos el numero de moras existentes.
FOREACH WITH HOLD
	select distinct pago_venc
	into iPagoVenc
	from ctes_aprocesar

	FOREACH WITH HOLD
		select numcte
		  into cNumCte
		  from ctes_aprocesar
		where pago_venc = iPagoVenc

		select limit 1 secuencia
		  into sSecuenciaTelCel
		  from bdinteg:si_telefonos_actual
		 where numcte 		= cNumCte
		   and tipo_tel 	= 2
		   and status_tel	= 'A';
		/* and cofetel 		= 'V';*/--RQM 09 598"

		if sSecuenciaTelCel is null or sSecuenciaTelCel = '' then let sSecuenciaTelCel = 0; end if;

		select limit 1 secuencia
		  into sSecuenciaTelCasa
		  from bdinteg:si_telefonos_actual
		 where numcte 		= cNumCte
		   and tipo_tel 	= 1
		   and status_tel	= 'A';
		/* and cofetel 		= 'V';*/ --RQM 09 598"

		if sSecuenciaTelCasa is null or sSecuenciaTelCasa = '' then let sSecuenciaTelCasa = 0; end if;

		if sSecuenciaTelCel > 0 then let iContadorTelCelValido = iContadorTelCelValido + 1; end if;
		if sSecuenciaTelCel > 0 and sSecuenciaTelCasa > 0 then let iContadorTelCelyTelCasa = iContadorTelCelyTelCasa + 1; end if;
		if sSecuenciaTelCel = 0 and sSecuenciaTelCasa > 0 then let iContadorTelCeloTelCasa = iContadorTelCeloTelCasa + 1; end if;
		if sSecuenciaTelCel = 0 and sSecuenciaTelCasa = 0 then let iContadorCtesSinDatos = iContadorCtesSinDatos + 1; end if;

	END FOREACH;
--Insertamos en tabla los datos para generar el reporte.
	begin work;
	insert into tmp_resultados_cobranza (reporte, mora, num_ctes_1tel_valido, num_ctes_y, num_ctes_o, num_ctes_sindatos )
								 values ('telefonos_cartera_vencida', iPagoVenc, iContadorTelCelValido, iContadorTelCelyTelCasa, iContadorTelCeloTelCasa, iContadorCtesSinDatos);
	commit work;
--Insertamos en tabla los totales para generar el reporte.

--Limpiamos Variables.
	LET iPagoVenc				= 0;
	LET sSecuenciaTelCel		= 0;
	LET sSecuenciaTelCasa		= 0;
	LET iContadorTelCelValido	= 0;
	LET iContadorTelCelyTelCasa	= 0;
	LET iContadorTelCeloTelCasa	= 0;
	LET iContadorCtesSinDatos	= 0;
END FOREACH;

--Insertamos en tabla los totales para generar el reporte.
	begin work;
	select sum(num_ctes_1tel_valido), sum(num_ctes_y),sum(num_ctes_o),sum(num_ctes_sindatos)
	  into iContadorTelCelValido, iContadorTelCelyTelCasa, iContadorTelCeloTelCasa, iContadorCtesSinDatos
	  from tmp_resultados_cobranza
	 where reporte = 'telefonos_cartera_vencida';

	insert into tmp_resultados_cobranza (reporte, mora, num_ctes_1tel_valido, num_ctes_y, num_ctes_o, num_ctes_sindatos )
								 values ('telefonos_cartera_vencida', null, iContadorTelCelValido, iContadorTelCelyTelCasa, iContadorTelCeloTelCasa, iContadorCtesSinDatos);
	commit work;
--Insertamos en tabla los totales para generar el reporte.

-- Se genera un archivo plano con la información de reservas que inserta en la tabla sd_hist_reserva.
	LET vDia = lpad(DAY(vFechaCorte),2,'00');
	LET vMes = lpad(MONTH(vFechaCorte),2,'00');
	LET vAnio = YEAR(vFechaCorte);

	LET vsql = 'echo " unload to '''|| '/resplogifx/archivoscartera/reporte2.unl'''||" delimiter '|' "||
             '" > /resplogifx/archivoscartera/reporte2.sql';
    system vsql;

    LET vsql = 'echo "'||
             ' select mora, num_ctes_1tel_valido, num_ctes_y, num_ctes_o, num_ctes_sindatos FROM tmp_resultados_cobranza where reporte = ''telefonos_cartera_vencida'' order by rowid '||
             ' " >> /resplogifx/archivoscartera/reporte2.sql';
    system trim(vsql);

    LET vsql = 'dbaccess bdicobranza /resplogifx/archivoscartera/reporte2.sql';
    system vsql;

    LET vsql = "cp /resplogifx/archivoscartera/reporte2.unl /resplogifx/archivoscartera/rep_detalles_telefonos_"|| vDia || vMes || vAnio ||".txt ";
    system vsql;

    --let vsql = "gzip /resplogifx/archivoscartera/rep_detalles_telefonos_"|| vDia || vMes || vAnio ||".txt ";
    --system vsql;

    LET vsql = "rm /resplogifx/archivoscartera/reporte2.unl ";
    system vsql;

	LET vsql = "rm /resplogifx/archivoscartera/reporte2.sql ";
    system vsql;

--Genera mensaje de monitoreo

let cMensaje = 'Detalle de Cartera Enviada ';
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING cCodRet;
--Genera mensaje de monitoreo

--Limpiamos Variables.
LET iPagoVenc				= 0;
LET sSecuenciaTelCel		= 0;
LET sSecuenciaTelCasa		= 0;
LET iContadorTelCelValido	= 0;
LET iContadorTelCelyTelCasa	= 0;
LET iContadorTelCeloTelCasa	= 0;
LET iContadorCtesSinDatos	= 0;

---------------------------------------------------------Detalle de Cartera Enviada---------------------------------------------------------------
	IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'tmp_detalle_cartera_enviada' ) THEN
		truncate table tmp_detalle_cartera_enviada drop storage;
	ELSE
		CREATE TABLE "informix".tmp_detalle_cartera_enviada(mora INTEGER, total_ctes INTEGER, pago_min_periodo DECIMAL(18,2), pago_min_periodos_ants DECIMAL(18,2),
											intereses_periodo DECIMAL(18,2), intereses_moratorios DECIMAL(18,2), total_pago DECIMAL(18,2), pago_paraliquidar DECIMAL(18,2));
	END IF;

--Sacamos el numero de moras existentes.
FOREACH WITH HOLD
	select distinct pago_venc
	into iPagoVenc
	from ctes_aprocesar

	FOREACH WITH HOLD
		select num_credito
		  into cNumCredito
		  from ctes_aprocesar
		where pago_venc = iPagoVenc

		let iNumCtes = iNumCtes + 1;

--Cálulo del pago mínimo y pago total para liquidar
		SELECT sdo_cap_insoluto, sdo_retenido
		  INTO dSdoCapInsoluto, dSdoRetenido
		  FROM bdicred:sd_maesdos
		 WHERE empresa     = cEmpresa
           AND num_credito = cNumCredito;

		CALL bdicred:sp_obtener_pagomin(cEmpresa,cNumCredito) RETURNING cCodRet, cMensajePagoMin, dPagoMinimo, dIntVdo, dIntMoratorio,
                                                                         dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig;

		IF cCodRet != '000000' THEN RETURN cCodRet,cMensajePagoMin;	END IF;

		LET dPagoNoGeneraInt = NVL(dSdoCapInsoluto,0) + NVL(dIntVdo,0) + NVL(dIvaIntVdo,0) + NVL(dIntMoratorio,0) + NVL(dIvaIntMoratorio,0) + NVL(dSdoRetenido,0) - NVL(dMontoIntIva,0);
--Cálulo del pago mínimo y pago total para liquidar

		let dTotalPago = dTotalPago + dPagoMinimo;
		let dPagoParaliquidar = dPagoParaliquidar + dPagoNoGeneraInt;

		let dIntMoratorioTotal = dIntMoratorioTotal + (dIntMoratorio + dIvaIntMoratorio);

		select limit 1 capital_mto_cuota, (interes_debe - interes_pagado) + (iva_debe - iva_pagado)
		  into dCapitalMtoCuota, dInteresesMes
		  from bdicred:sd_amortiza_credito
		 where empresa		= cEmpresa
		   and num_credito	= cNumCredito
		   and fecha_cuota	= vFechaCorte;

		if dCapitalMtoCuota is null or dCapitalMtoCuota = '' then let dCapitalMtoCuota = 0; end if;
		if dInteresesMes is null or dInteresesMes = '' then let dInteresesMes = 0; end if;

		let dCapitalMtoCuotaTotal = dCapitalMtoCuotaTotal + dCapitalMtoCuota;
		let dInteresesMesTotal = dInteresesMesTotal + dInteresesMes;

		select sum(capital_mto_cuota)
		  into dCapitalMtoCuotaAnts
		  from bdicred:sd_amortiza_credito
		 where empresa		= cEmpresa
		   and num_credito	= cNumCredito
		   and capital_status in ('2','7');

		if dCapitalMtoCuotaAnts is null or dCapitalMtoCuotaAnts = '' then let dCapitalMtoCuotaAnts = 0; end if;

		let dCapitalMtoCuotaAntsTotal = dCapitalMtoCuotaAntsTotal + dCapitalMtoCuotaAnts;

		END FOREACH;
--Insertamos en tabla los datos para generar el reporte.
	begin work;
	insert into tmp_detalle_cartera_enviada(mora, total_ctes, pago_min_periodo, pago_min_periodos_ants, intereses_periodo, intereses_moratorios, total_pago, pago_paraliquidar)
								 values (iPagoVenc, iNumCtes, dCapitalMtoCuotaTotal, dCapitalMtoCuotaAntsTotal, dInteresesMesTotal, dIntMoratorioTotal, dTotalPago, dPagoParaliquidar);
	commit work;
--Insertamos en tabla los totales para generar el reporte.

--Limpiamos Variables.
	LET dPagoNoGeneraInt    = 0;
	LET dPagoMinimo         = 0;
	LET dSdoCapInsoluto		= 0;
	LET dSdoRetenido		= 0;
	LET dIntVdo				= 0;
	LET dIntMoratorio		= 0;
	LET dIvaIntVdo			= 0;
	LET dPagosVdos			= 0;
	LET dIvaIntMoratorio	= 0;
	LET dIntMes				= 0;
	LET dIvaIntMes			= 0;
	LET dIntVig				= 0;
	LET dIvaIntVig			= 0;
	LET dSdoCapInsoluto		= 0;
	LET dSdoRetenido		= 0;
	LET dMontoIntIva		= 0;
	LET iNumCtes			= 0;
	LET dCapitalMtoCuota	= 0;
	LET dCapitalMtoCuotaTotal	= 0;
	LET dCapitalMtoCuotaAnts	= 0;
	LET dCapitalMtoCuotaAntsTotal	= 0;
	LET dInteresesMes		= 0;
	LET dInteresesMesTotal	= 0;
	LET dIntMoratorioTotal	= 0;
	LET dTotalPago			= 0;
	LET dPagoParaliquidar	= 0;
END FOREACH;

--Insertamos en tabla los totales para generar el reporte.
	begin work;
	select sum(total_ctes), sum(pago_min_periodo), sum(pago_min_periodos_ants), sum(intereses_periodo), sum(intereses_moratorios), sum(total_pago), sum(pago_paraliquidar)
	  into iNumCtes, dCapitalMtoCuotaTotal, dCapitalMtoCuotaAntsTotal, dInteresesMesTotal, dIntMoratorioTotal, dTotalPago, dPagoParaliquidar
	  from tmp_detalle_cartera_enviada;

	insert into tmp_detalle_cartera_enviada(mora, total_ctes, pago_min_periodo, pago_min_periodos_ants, intereses_periodo, intereses_moratorios, total_pago, pago_paraliquidar)
								 values (null, iNumCtes, dCapitalMtoCuotaTotal, dCapitalMtoCuotaAntsTotal, dInteresesMesTotal, dIntMoratorioTotal, dTotalPago, dPagoParaliquidar);
	commit work;
--Insertamos en tabla los totales para generar el reporte.

	-- Se genera un archivo plano con la información de reservas que inserta en la tabla sd_hist_reserva.
	LET vDia = lpad(DAY(vFechaCorte),2,'00');
	LET vMes = lpad(MONTH(vFechaCorte),2,'00');
	LET vAnio = YEAR(vFechaCorte);

	LET vsql = 'echo " unload to '''|| '/resplogifx/archivoscartera/reporte3.unl'''||" delimiter '|' "||
             '" > /resplogifx/archivoscartera/reporte3.sql';
    system vsql;

    LET vsql = 'echo "'||
             ' select * FROM tmp_detalle_cartera_enviada '||
             ' " >> /resplogifx/archivoscartera/reporte3.sql';
    system trim(vsql);

    LET vsql = 'dbaccess bdicobranza /resplogifx/archivoscartera/reporte3.sql';
    system vsql;

    LET vsql = "cp /resplogifx/archivoscartera/reporte3.unl /resplogifx/archivoscartera/rep_detalle_de_cartera_enviada_"|| vDia || vMes || vAnio ||".txt ";
    system vsql;

    --let vsql = "gzip /resplogifx/archivoscartera/rep_detalle_de_cartera_enviada_"|| vDia || vMes || vAnio ||".txt ";
    --system vsql;

    LET vsql = "rm /resplogifx/archivoscartera/reporte3.unl ";
    system vsql;

	LET vsql = "rm /resplogifx/archivoscartera/reporte3.sql ";
    system vsql;
	
--Genera mensaje de monitoreo
let cMensaje = 'Resultado Cartera Enviada CAT ';
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING cCodRet;
--Genera mensaje de monitoreo

--Limpiamos Variables.
LET dPagoNoGeneraInt    = 0;
LET dPagoMinimo         = 0;
LET dSdoCapInsoluto		= 0;
LET dSdoRetenido		= 0;
LET dIntVdo				= 0;
LET dIntMoratorio		= 0;
LET dIvaIntVdo			= 0;
LET dPagosVdos			= 0;
LET dIvaIntMoratorio	= 0;
LET dIntMes				= 0;
LET dIvaIntMes			= 0;
LET dIntVig				= 0;
LET dIvaIntVig			= 0;
LET dSdoCapInsoluto		= 0;
LET dSdoRetenido		= 0;
LET dMontoIntIva		= 0;
LET iNumCtes			= 0;
LET dCapitalMtoCuota	= 0;
LET dCapitalMtoCuotaTotal	= 0;
LET dCapitalMtoCuotaAnts	= 0;
LET dCapitalMtoCuotaAntsTotal	= 0;
LET dInteresesMes		= 0;
LET dInteresesMesTotal	= 0;
LET dIntMoratorioTotal	= 0;
LET dTotalPago			= 0;
LET dPagoParaliquidar	= 0;

LET cNumCte			= '';
LET cNumCredito		= '';

---------------------------------------------Reporte 4 tmp_resultado_cartera_enviada_cat---------------------------------------------------------------------------
	IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'tmp_resultado_cartera_enviada_cat' ) THEN
		truncate table tmp_resultado_cartera_enviada_cat drop storage;
	ELSE
		CREATE TABLE "informix".tmp_resultado_cartera_enviada_cat(numcte char(20), num_credito char(20), num_tarjeta char(20), moratorio DECIMAL(18,2), sdo_tot_liquid DECIMAL(18,2), sdo_venc_tot DECIMAL(18,2), pago_minimo DECIMAL(18,2), mensualidad_actual DECIMAL(18,2),
												no_ven_ini integer, no_ven_fin integer, status_cred CHAR(2), fecha_ult_pago DATE, pago_una_mora DECIMAL(18,2),
												numerociudad SMALLINT, nombreciudad CHAR(30), nombre_region CHAR(30), num_producto CHAR(4), num_pagos INTEGER, monto_pagos DECIMAL(18,2), resultado_gestion smallint, descripcion CHAR(50) );
	END IF;
	
	FOREACH WITH HOLD

		select  numcte, num_credito
		  into cNumCte, cNumCredito
		  from ctes_aprocesar

		  SELECT num_tarjeta, moratorio,
				(sdo_capital +  monto_vencido + mto_venc_trasp + cap_tras_no_venci + moratorio + interes_iva ) sdo_tot_liquid,
				(monto_vencido + mto_venc_trasp + moratorio + interes_iva) sdo_venc_tot, mensualidad_actual,
				status_cred, fecha_ult_pago, pago_una_mora, num_producto
			into vNum_Tarjeta, vMoratorio, vSdoTotLiquidar, vSdoVencTot, vMensualidadActual, vStatusCred, vFechUltPago, vPagoUnaMora, vNumProducto
			FROM bdicred:sd_sdos_cartera_linea
			WHERE num_credito = cNumCredito and num_producto = '6001';

		CALL bdicred:sp_obtener_pagomin(cEmpresa,cNumCredito) RETURNING cCodRet, cMensajePagoMin, dPagoMinimo, dIntVdo, dIntMoratorio,
                                                                         dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig;

		IF cCodRet != '000000' THEN RETURN cCodRet,cMensajePagoMin;	END IF;

		LET vFechaCorteAnterior = vFechaCorte - 1 units month;

		select limit 1 pago_venc
		  into vNoVencidoIni
		  from bdicobranza:cb_cat_directorio_cte_his
		where empresa = cEmpresa
		  and tipo_cobranza = 'A'
		  and fecha_insert = vFechaCorteAnterior --'2016-01-20'
		  and num_credito = cNumCredito
		  and num_producto = '6001';

		   select limit 1 pago_venc
		     into vNoVencidoFin
		     from bdicobranza:cb_cat_directorio_cte
		   where empresa = cEmpresa
		     and tipo_cobranza = 'A'
		     and fecha_insert = vFechaCorte --'2016-01-20'
			 and num_credito = cNumCredito
		     and num_producto = '6001';

		select cds.numerociudad, cds.nombreciudad, reg.nombre_region
		into vNumCiudad, vNombreCiudad, vNombreRegion
		FROM bdicobranza:cb_cat_directorio_cte a
		JOIN bdinteg:si_cliente cte ON (a.empresa = cte.empresa and  a.numcte = cte.numcte)
		JOIN bdinteg:si_direcciones_actual dir ON (a.numcte = dir.numcte and dir.tipo_dir = '1')
		JOIN bdinteg:si_catciudades cds on ( dir.numerociudad = cds.numerociudad )
		JOIN bdinteg:si_regiones reg on cds.numero_region = reg.numero_region
		where a.empresa = cEmpresa and a.tipo_cobranza = 'A'and a.fecha_insert = vFechaCorte
		and a.num_credito = cNumCredito;

		if vNombreCiudad is null then let vNombreCiudad = ''; end if;

		select count(*), sum(a.monto)
		into vNumeroDePagos, vMontoDePagos
		from bdicred:sd_movhis a
		--LEFT OUTER JOIN bdicred:sd_transfun b ON (a.empresa = b.empresa AND a.codigo_fun = b.codigo_fun AND a.codigo_ref = b.codigo_ref)
		where a.empresa = cEmpresa
		and a.fecha_mov between vFechaCorteAnterior +1 units day and vFechaCorte
		and a.num_credito = cNumCredito
		and a.codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual)
		and a.codigo_ref = 1
		and a.reversado = 'N';

		if vMontoDePagos is null or vMontoDePagos = '' then let vMontoDePagos = 0; end if;

		select limit 1 b.tipomovimiento, d.descripcion
		into vResultadoGestion, vDescripcion
		from bdicobranza:cb_cat_directorio_cte a
		join bdicobranza:cb_cat_movimientos b on (a.tipo_cobranza = b.tipocobranza and a.tipo_logica = 	b.tipologica and a.numcte = b.cliente)
        join bdicobranza:cb_cat_tipo_resultado d on (b.tipomovimiento = d.codigo_resultado)
        where a.empresa = cEmpresa
		and a.tipo_cobranza = 'A'
		and a.fecha_insert between vFechaCorteAnterior +1 units day and vFechaCorte
		and a.num_credito = cNumCredito
		--and a.fecha_insert = vFechaCorteAnterior
		and a.num_producto = '6001';

		if vResultadoGestion is null or vResultadoGestion = '' then let vResultadoGestion = 0; end if;

	begin work;
	insert into tmp_resultado_cartera_enviada_cat(numcte, num_credito, num_tarjeta, moratorio, sdo_tot_liquid, sdo_venc_tot, pago_minimo, mensualidad_actual,
													no_ven_ini, no_ven_fin, status_cred, fecha_ult_pago, pago_una_mora, numerociudad, nombreciudad, nombre_region,
													num_producto, num_pagos, monto_pagos, resultado_gestion, descripcion )
								 values (cNumCte, cNumCredito, vNum_Tarjeta, vMoratorio, vSdoTotLiquidar, vSdoVencTot, dPagoMinimo, vMensualidadActual,
											vNoVencidoIni, vNoVencidoFin, vStatusCred, vFechUltPago, vPagoUnaMora, vNumCiudad, vNombreCiudad, vNombreRegion,
											vNumProducto, vNumeroDePagos, vMontoDePagos, vResultadoGestion, vDescripcion );
	commit work;

	--END FOREACH;

  --LImpiamos las variables
	LET cNumCte			= '';
	LET cNumCredito		= '';
	LET vNum_Tarjeta 	= '';
	LET vMoratorio		= 0;
	LET vSdoTotLiquidar = 0;
	LET vSdoVencTot		= 0;
	LET dPagoMinimo 	= 0;
	LET vMensualidadActual = 0;
	LET vNoVencidoIni 	= 0;
	LET vNoVencidoFin 	= 0;
	LET vStatusCred		= '';
	LET vFechUltPago	= '';
	LET vPagoUnaMora	= 0;
	LET vNumCiudad		= 0;
	LET vNombreCiudad 	= '';
	LET vNombreRegion	= '';
	LET vNumProducto	= '';
	LET vNumeroDePagos  = 0;
	LET vMontoDePagos	= 0;
	LET vResultadoGestion = 0;
	LET vDescripcion 	= '';

	END FOREACH;
	
	-- Se genera un archivo plano con la información de reservas que inserta en la tabla sd_hist_reserva.
	LET vDia = lpad(DAY(vFechaCorte),2,'00');
	LET vMes = lpad(MONTH(vFechaCorte),2,'00');
	LET vAnio = YEAR(vFechaCorte);

	LET vsql = 'echo " unload to '''|| '/resplogifx/archivoscartera/reporte4.unl'''||" delimiter '|' "||
             '" > /resplogifx/archivoscartera/reporte4.sql';
    system vsql;

    LET vsql = 'echo "'||
             ' select * FROM tmp_resultado_cartera_enviada_cat '||
             ' " >> /resplogifx/archivoscartera/reporte4.sql';
    system trim(vsql);

    LET vsql = 'dbaccess bdicobranza /resplogifx/archivoscartera/reporte4.sql';
    system vsql;

    LET vsql = "cp /resplogifx/archivoscartera/reporte4.unl /resplogifx/archivoscartera/rep_resultado_cartera_enviada_cat_"|| vDia || vMes || vAnio ||".txt ";
    system vsql;

    --let vsql = "gzip /resplogifx/archivoscartera/rep_resultado_cartera_enviada_cat_"|| vDia || vMes || vAnio ||".txt ";
    --system vsql;

    LET vsql = "rm /resplogifx/archivoscartera/reporte4.unl ";
    system vsql;

	LET vsql = "rm /resplogifx/archivoscartera/reporte4.sql ";
    system vsql;
	
--Genera mensaje de monitoreo
--let cMensaje = 'Resultado Cartera Enviada CAT ';
--CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING cCodRet;
--Genera mensaje de monitoreo

CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, cMensaje, '03') RETURNING cCodRet;

if cCodRet != '000000' then
    let cMensajeRet  = 'Error en el llamado al sp_inserta_bitacora_cob.';
    RETURN cCodRet, cMensajeRet;
end if;

RETURN cCodRet, cMensajeRet;
END;

END PROCEDURE;