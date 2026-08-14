CREATE PROCEDURE "informix".totcomp(o_empresa CHAR(3), o_usuario CHAR(8), o_sucursal CHAR(4), o_num_total SMALLINT)

	RETURNING	CHAR(5),
				CHAR(2),
				MONEY(16, 2),
				MONEY(16, 2),
				MONEY(16, 2),
				MONEY(16, 2),
				CHAR(40),
				INTEGER,
				INTEGER,
				INTEGER,
				INTEGER;

	-- ============================================================================
	-- =                        DEFINICION DE VARIABLES                           =
	-- ============================================================================
	DEFINE v_monto_cargo		MONEY(16, 2);
	DEFINE v_monto_firme		MONEY(16, 2);
	DEFINE v_monto_firme_crd 	MONEY(16, 2);
	DEFINE v_monto_sbc			MONEY(16, 2);
	DEFINE v_monto_rem			MONEY(16, 2);
	DEFINE v_movto_cargo		INTEGER;
	DEFINE v_movto_firme		INTEGER;
	DEFINE v_movto_firme_crd	INTEGER;
	DEFINE v_movto_sbc			INTEGER;
	DEFINE v_movto_rem			INTEGER;
	DEFINE v_descripcion		CHAR(40);
	DEFINE v_contador			SMALLINT;
	DEFINE v_fecha				DATE;
	DEFINE v_row				INTEGER;
	DEFINE v_codret				CHAR(5);
	DEFINE v_empresa			CHAR(3);
	DEFINE w_plaza				CHAR(3);
	DEFINE w_sucursal			CHAR(4);
	DEFINE v_producto			CHAR(4);
	DEFINE v_ciclo				SMALLINT;
	DEFINE v_divisa				CHAR(2);
	DEFINE v_cal_int_chq		CHAR(1);
	DEFINE sql_err				INTEGER;
	DEFINE v_usuario			CHAR(8);
	DEFINE v_existe				CHAR(1);
	DEFINE iContador			INTEGER;

	-- ============================================================================
	-- =                        ASIGNACION DE VALORES                             =
	-- ============================================================================
	LET v_monto_cargo		= 0;
	LET v_monto_firme		= 0;
	LET v_monto_firme_crd 	= 0;
	LET v_monto_sbc			= 0;
	LET v_monto_rem			= 0;
	LET v_movto_cargo		= 0;
	LET v_movto_firme		= 0;
	LET v_movto_firme_crd	= 0;
	LET v_movto_sbc			= 0;
	LET v_movto_rem			= 0;
	LET v_descripcion		= "";
	LET v_contador			= 0;
	LET v_fecha				= DATE(1);
	LET v_row				= 0;
	LET v_codret			= "00000";
	LET v_empresa			= "";
	LET w_plaza				= "";
	LET w_sucursal			= "";
	LET v_producto			= "";
	LET v_ciclo				= 0;
	LET v_divisa			= "";
	LET v_cal_int_chq		= "";
	LET sql_err				= 0;
	LET v_usuario			= "";
	LET v_existe			= "";
	LET iContador			= 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/tmp/totcomp.out";
	--TRACE ON;

	--"223" Efectivo, pago normal.
	--"020" Efectivo, pago anticipado prestamo personal.
	--"221" Efectivo, pago anticipado reestructura.

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_coDret = sql_err;
					RETURN v_codret, v_divisa, v_monto_cargo, v_monto_firme, v_monto_sbc, v_monto_rem, v_descripcion,
					v_movto_cargo, v_movto_firme, v_movto_sbc, v_movto_rem;
			END IF
		END EXCEPTION;

		SELECT {+INDEX(sd_fechas idx_sdfechas)} fecha_hoy INTO v_fecha
		FROM bdicred:sd_fechas WHERE empresa = o_empresa;

		FOREACH WITH HOLD

			SELECT divisa, descripcion INTO v_divisa, v_descripcion
			FROM bdinteg:"informix".si_divisas WHERE divisa = divisa AND empresa = o_empresa

			SELECT {+INDEX(sd_movdia idx_movdia2)}
			NVL(SUM(CASE WHEN codigo_fun = '002' THEN monto END), 0),
			NVL(SUM(CASE WHEN codigo_fun = '002' THEN 1 END), 0),
			NVL(SUM(CASE WHEN codigo_fun IN ('033', '333', '067') THEN monto END), 0),
			NVL(SUM(CASE WHEN codigo_fun IN ('033', '333','067') THEN 1 END), 0),
			NVL(SUM(CASE WHEN codigo_fun = "336" AND codigo_ref = 20 THEN monto END), 0),
			NVL(SUM(CASE WHEN codigo_fun = "336" AND codigo_ref = 20 THEN 1 END), 0)
			INTO v_monto_cargo,
			v_movto_cargo,
			v_monto_firme,
			v_movto_firme,
			v_monto_sbc,
			v_movto_sbc
			FROM bdicred:"informix".sd_movdia a
			WHERE usuario = o_usuario
			AND sucursal = o_sucursal
			AND ((codigo_fun IN ("033", "333", "067") AND codigo_ref = 1)
			OR (codigo_fun = "336" AND codigo_ref = 20)
			OR (codigo_fun = "002" AND codigo_ref IN (50, 60)))
			AND reversado <> "S"
			AND fecha_mov = v_fecha
			AND empresa = o_empresa
			AND divisa = v_divisa;
			--AAME 07/03/2017 RQM 10 282 Se contemplan codigo fun de pagos anticipados de credisolucion 076 y 077 desde la caja
			SELECT {+INDEX(sd_movdiacrd idx_movdiacrd2)}
			NVL(SUM(CASE WHEN codigo_fun IN ('027','028','225','077') THEN monto END), 0),
			NVL(SUM(CASE WHEN codigo_fun IN ('027','028','225','077') THEN 1 END), 0)
			INTO v_monto_firme_crd,
			v_movto_firme_crd
			FROM bdicred:"informix".sd_movdiacrd a
			WHERE usuario = o_usuario
			AND sucursal = o_sucursal
			AND (codigo_fun IN ("027","028","225","077") AND codigo_ref = 1)
			AND reversado <> "S"
			AND fecha_mov = v_fecha
			AND empresa = o_empresa
			AND divisa = v_divisa;

			LET v_monto_firme = NVL(v_monto_firme,0) + NVL(v_monto_firme_crd,0);
			LET v_movto_firme = NVL(v_movto_firme,0) + NVL(v_movto_firme_crd,0);

			IF NOT (v_monto_cargo = 0 AND v_movto_cargo = 0 AND v_monto_firme = 0 AND v_movto_firme= 0
			AND v_monto_sbc = 0 AND v_movto_sbc = 0 ) THEN
				LET iContador = iContador + 1;
				RETURN v_codret, v_divisa, v_monto_cargo, v_monto_firme, v_monto_sbc, v_monto_rem, TRIM(v_descripcion),
				v_movto_cargo, v_movto_firme, v_movto_sbc, v_movto_rem WITH RESUME;
			END IF;
		END FOREACH;    

		--IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		--	LET v_codret = "00001"; --"No existen divisas cargadas en el catalogo para iniciar las consultas.";
		--ELIF iContador = 0 THEN
		--	LET v_codret = "00002"; --"No existe información con las divisas consultadas.";
		--END IF;

		--IF v_codret <> "00000" THEN
		--	RETURN v_codret, v_divisa, v_monto_cargo, v_monto_firme, v_monto_sbc, v_monto_rem, TRIM(v_descripcion),
		--	v_movto_cargo, v_movto_firme, v_movto_sbc, v_movto_rem;
		--END IF;
	END
END PROCEDURE
DOCUMENT
'Fecha: 17/06/2011',
'Modifico: Paul Ivan Quintero Varela',
'Observaciones: Se modifica para contemplar los pagos de préstamo personal',
'pago de anticipo y los pagos de reesturctura para obtener el total de',
'pagos de este proceso del totales de computador.';

CREATE PROCEDURE "informix".sp_gen_arch_auto_sinrecogertc_vencidas(pEmpresa CHAR(3))
RETURNING CHAR(5) AS CodigoRetorno, 
		  CHAR(80) AS Mensaje;	

DEFINE cod_ret     CHAR(5);
DEFINE sql_err     SMALLINT;
DEFINE vMen        CHAR(80);
DEFINE cErrorInfo  CHAR(80);
DEFINE iIsamErr    SMALLINT;
DEFINE  dtFechaHoy     	DATE;
DEFINE  cNomArchivo 	CHAR(50);
DEFINE  cSQL            CHAR(4000);
DEFINE  cSQLEncabezado		CHAR(300);
DEFINE  cSQLEncabezadofin	CHAR(300);
DEFINE  cRuta			CHAR(100);

LET cod_ret        = "00000";
LET sql_err        = 0;
LET vMen           = "El archivo Autorizas_sinrecogerTC_vencidas se generÃ³ correctamente";
LET cErrorInfo     = "";
LET iIsamErr       = 0;
LET dtFechaHoy  = DATE(1);
LET cNomArchivo = '';
LET cSQL        = '';
LET cSQLEncabezado	= '';
LET cSQLEncabezadofin = '';
LET cRuta       = '';

BEGIN
	
	ON EXCEPTION SET sql_err, iIsamErr, cErrorInfo
		IF sql_err != 0 THEN
			LET cod_ret = sql_err;
			LET vMen= 'Error al generar archivo de Autorizas_sinrecogerTC_vencidas ';
        RETURN cod_ret, vMen;	
		END IF;
END EXCEPTION;


--	SET DEBUG FILE TO "sp_genera_archivo_tdcexpiradas.out";
 --   TRACE ON; 
	
	SELECT fecha_hoy - 1 units month
	INTO dtFechaHoy
    FROM bdicred:"informix".sd_fechas
    WHERE empresa = '001';
	
	--let dtFechaHoy = mdy('02','05','2013'); --para pruebas
	LET cRuta = '/resplogifx/archivoscartera/';
	
	---Encabezado de archivo
	
	LET cSql = ' echo "Numero de solicitud;Fecha de solicitud;Fecha de vencimiento;Nombre; Linea de credito autorizada;Estado;Sucursal;Numero cliente;"'||' >'|| TRIM(cRuta)||'Autorizas_sinrecogerTC_vencidas_'||to_char(dtFechaHoy,'%m%Y')||'.txt';		
	SYSTEM cSql;
	--Generacion de archivo Autorizas_sinrecogerTC_vencidas	
			LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || SUBSTR(cRuta,1,LENGTH(cRuta)) ||'Autorizas_sinrecogerTC_vencidas.unl' || ' DELIMITER ' || ''';'''  ||
			' select a.num_solicitud,date(a.fecha_insert - 120 units day),a.fecha_insert,'||
			' TRIM(c.nombre1)||'||''' '''||'||TRIM(c.nombre2)||'||''' '''||'||TRIM(c.apell_paterno)||'||''' '''||'||TRIM(c.apell_materno),'||
			' b.monto_solicitado as Linea_de_credito_solicitada,e.nombre,b.sucursal,c.numcte'|| 
			' from bdisolic:ss_autorizacion a,'||
			' bdisolic:ss_solicitudes b,'||
			' bdinteg:si_cliente c,'||
			' bdinteg:si_direcciones_actual d,'||
			' bdinteg:si_estados e'||
			' where a.empresa = b.empresa'||
			' and c.empresa = b.empresa'||
			' and a.num_solicitud = b.num_solicitud'||
			' and b.numcte = c.numcte'||
			' and d.numcte = b.numcte'||
			' and b.num_producto =''6001'''||
			' and a.status_solicitud =''CN'''||
			' and a.causa_solicitud =''CV'''||
			' and d.tipo_dir = ''1'''||
			' and e.estado = d.estado'||
			' and e.pais = ''001'''||
			' and year (a.fecha_insert) = year('''||dtFechaHoy||''')'||
			' and month (a.fecha_insert) = month('''||dtFechaHoy||''');'||
			'" > '||TRIM(cRuta)||'Autorizas_sinrecogerTC_vencidas.sql';	
 
 
 		
			
            SYSTEM cSql;

            LET cSql = '';
            LET cSql = 'dbaccess bdicred '||TRIM(cRuta)||'Autorizas_sinrecogerTC_vencidas.sql';
            SYSTEM cSql;

            --Se une el encabezado con la informaciÃ³n.
			LET cSql = '';
			LET cSql= "sed 's/;$//g' " ||TRIM(cRuta)||"Autorizas_sinrecogerTC_vencidas.unl"||" >> "||TRIM(cRuta)||'Autorizas_sinrecogerTC_vencidas_'||to_char(dtFechaHoy,'%m%Y')||'.txt';
			SYSTEM cSql;
			
	
			LET cSql ='rm '|| TRIM(cruta)||'Autorizas_sinrecogerTC_vencidas.sql ' ||TRIM(cruta)||'Autorizas_sinrecogerTC_vencidas.unl';
			SYSTEM cSql; 


			LET vMen = 'El archivo Autorizas_sinrecogerTC_vencidas se generÃ³ correctamente';
			LET cod_ret = '00000';	
	
			RETURN cod_ret, vMen;

END;
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento generar archivo con informaciÃ³n de Tarjetas de crÃ©dito autorizadas, pero no han sido recogidas',
'AUTOR : Guadalupe de Jesus Espinoza Valenzuela ',
'FECHA : 01/Abril/2013',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_rep_estadisticas_tdc_latinia()

RETURNING 
          CHAR(06) AS resultado,
          CHAR(80) AS mensaje;
          
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);

DEFINE vnumcte			CHAR(20);
DEFINE vnum_credito		CHAR(20);
DEFINE vtelefono		CHAR(20);
DEFINE vtarjeta 		CHAR(20);
DEFINE vapellido_pat	CHAR(30);
DEFINE vfecha			DATE;
DEFINE dtFecha          DATE;
DEFINE vdia2 			SMALLINT;
DEFINE vdia7			SMALLINT;
DEFINE vdia14			SMALLINT;
DEFINE vdia15			SMALLINT;
DEFINE vdia21			SMALLINT;
DEFINE vdia28			SMALLINT;
define vtotal			integer;
define vtotal2			integer;
define vtotal1			integer;
DEFINE iTotalRegistros  integer;
define vregistros		integer;
define vproceso			char(4);
define vvalor			smallint;
define vcontador		integer;
define vfechas			char(6);
define vpri_dia_mes 	date;
define VlDescripcion    char(50); 
define vlValorAlfa      char(50); 
define vlValorAlfabetico char(50);
define  vlCDummy        integer;

LET vproceso	='2083';
LET iSqlErr    	= 0;
LET iIsamErr   	= 0;
LET cErrorInfo 	= "";
LET cCodRet   	= '000000';
LET cMensajeRet	= 'El proceso se realizÃ³ correctamente';

LET vnumcte			= "";
LET vnum_credito	= "";
LET vtelefono		= "";
LET vtarjeta 		= "";
LET vapellido_pat	= "";
LET vfecha			= DATE(0);  
LET dtFecha    		= DATE(0);  
let vtotal			= 0;
let vtotal1			= 0;
let vdia2 			= 0;
let vdia7			= 0;
let vdia14			= 0;
let vdia15			= 0;
let vdia21			= 0;
let vdia28			= 0;
LET iTotalRegistros = 0;
let vregistros		=0;
let vvalor 			= 0;
let vcontador 		= 0;
let vfechas			 = '';
let vpri_dia_mes	= DATE(0); 
let VlDescripcion   = '';
let vlValorAlfabetico = '';
let vlCDummy = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= 'ERROR en la ejecuciÃ³n';
	 CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensajeRet, '02')RETURNING cCodRet;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensajeRet, '01')RETURNING cCodRet;
    
--SET DEBUG FILE TO "/informix/gpe/Pruebas_de_carta_por_prioridad/sp_rep_estadisticas_tdc_latinia.out";
--TRACE ON;

	SELECT a.fecha_hoy, a.pri_dia_mes
		INTO dtFecha ,vpri_dia_mes
	FROM bdicred:sd_fechas a
	WHERE a.empresa = '001';
--let dtFecha = '04-05-2014';----------------------------------------pruebas
	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;

  	select valor_numerico into vregistros
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 57;
	--Dia nuevos
	select valor_numerico into vdia2
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 70;
	
	select valor_numerico into vdia7
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 64;
	select valor_numerico into vdia14
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 65;
	select valor_numerico into vdia15
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 66;
	--RQM 10 637 20150917 AAME Se agregan 2 parametros nuevos de fecha de envÃ­o
	select valor_numerico into vdia21
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 68;
	select valor_numerico into vdia28
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 69;
	
		
	select count(*) into vtotal
	from bdimnsj:mnsjr_trx_batch 
	where id_mensaje = 'AUT_SINREC' 
	 and to_char(fecha_hora_registro,'%m%Y') = to_char(vpri_dia_mes,'%m%Y') ;
	
	select count(*) into vtotal2
	from bdimnsj:mnsjr_trx_batch_his 
	where id_mensaje = 'AUT_SINREC' 
	  and to_char(fecha_hora_registro,'%m%Y') = to_char(vpri_dia_mes,'%m%Y');
	
	let vtotal = nvl(vtotal,0) + nvl(vtotal2,0);
	if (vtotal < vregistros) then
		LET vtotal1 = vregistros - vtotal;
	end if;
	if (day(dtFecha) = 1 ) then 
		let vtotal1 = vregistros; --delete from bdicobranza:cb_administativa_latinia where num_campania = 1;
	end if;
	select valor into vvalor from bdisolic:ss_param where secuencia = '21';

if (vtotal1  >= 1) then
FOREACH
  
	SELECT /* limit vtotal1 */sol.numcte,/*SUBSTR(tel2.telefono,(LENGTH(tel2.telefono) + 1 - 10),10),*/ --SUBSTR(cte.nombre1,1,10) --cte.nombre1
		CASE WHEN LENGTH(cte.nombre1) <=  3 THEN TRIM(cte.nombre1)||' '||TRIM(SUBSTR(cte.nombre2,1,9 - LENGTH(cte.nombre1))) ELSE
																					SUBSTR(cte.nombre1,1,10) END nombre
			,sol.num_solicitud
		INTO vnumcte, /*vtelefono, */ vapellido_pat,vnum_credito
	FROM bdisolic:ss_solicitudes sol
	JOIN bdinteg:si_cliente cte ON cte.empresa = sol.empresa AND cte.numcte = sol.numcte
	JOIN bdisolic:ss_autorizacion aut ON aut.empresa= sol.empresa and aut.num_solicitud = sol.num_solicitud AND aut.status_solicitud = sol.status_solicitud
		AND (aut.fecha_entrada = date(dtFecha) - vdia2 units day or aut.fecha_entrada = date(dtFecha) - vdia7 units day or aut.fecha_entrada = date(dtFecha) - vdia14 units day or aut.fecha_entrada = date(dtFecha) - vdia21 units day or aut.fecha_entrada = date(dtFecha) - vdia28 units day) 
		AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
                                    FROM bdisolic:"informix".ss_autorizacion aut_aux
                                    WHERE aut_aux.empresa= sol.empresa
                                    AND aut_aux.num_solicitud= sol.num_solicitud
                                    AND aut_aux.status_solicitud= sol.status_solicitud)
	/*join bdinteg:si_telefonos_actual tel2 on (tel2.empresa = sol.empresa and tel2.numcte= sol.numcte and tel2.tipo_tel = 2 and tel2.cofetel ='V' and tel2.status_tel = 'A'
							and tel2.telefono is not null and tel2.telefono <> ''
                            and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = sol.numcte and tipo_tel = 2 and cofetel ='V' and status_tel = 'A'))
	*/WHERE sol.empresa = '001' 
		AND sol.num_solicitud = sol.num_solicitud 
		AND sol.status_solicitud = 'AT'
		and sol.tipo_solicitud = 'T'
	order by sol.monto_autorizado desc
	
	select limit 1 SUBSTR(tel2.telefono,(LENGTH(tel2.telefono) + 1 - 10),10) into vtelefono
	from bdinteg:si_telefonos_actual tel2 
	where tel2.empresa = '001' 
	and tel2.numcte = vnumcte
	and tel2.tipo_tel = 2 and tel2.cofetel ='V' and tel2.status_tel = 'A'
	and tel2.telefono is not null and tel2.telefono <> ''
    and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                        where numcte = vnumcte and tipo_tel = 2 and cofetel ='V' and status_tel = 'A');
	
	if 	(vtelefono is not null and vtelefono <> '') then
	
		let vfecha = date(dtFecha) + vdia15 units day;
		let vfechas = lpad(day(vfecha),2,'0')||'-'|| decode (month(vfecha),01,'Ene',02,'Feb',03,'Mar',04,'Abr',05,'May',06,'Jun',
																   07,'Jul',08,'Ago',09,'Sep',10,'Oct',11,'Nov',12,'Dic');
   
		/*insert into bdicobranza:cb_administativa_latinia(num_campania,numcte,num_credito,telefono,tarjeta ,apellido_pat,fecha,fecha_insert)
		values (1,vnumcte,vnum_credito, vtelefono, '', vapellido_pat, vfecha,today);*/
		call bdimnsj:"informix".sp_registra_evento (2, 'AUT_SINREC' , vnumcte, vnum_credito,'', 2,
							vapellido_pat,vfechas,'','','',0,0,0,0,0, '', '')RETURNING cCodRet;
		let vcontador = vcontador + 1 ;
	end if;
	if (vcontador = vtotal1) then	exit FOREACH; end if;
 End ForEach;
end if;	
  if (day(dtFecha) <= 8 ) then
  
  FOREACH  
    select descripcion,  trim(valor_alfabetico)
      into VlDescripcion, vlValorAlfabetico
      from bdicred:sd_param_campania 
     where tipo_campania = 60  AND GRUPO_PARAMETRO = 'TELSMSFIJO'
	 and num_parametro in (1,2,3)
	 
	 select  count(*) into vlCDummy   
      from bdimnsj:"informix".mnsjr_trx_batch 
     where tipo_mensaje = 2  
      and to_char(fecha_hora_registro,'%m%Y') = to_char( dtFecha,'%m%Y' )
      and id_mensaje  ='AUT_SINREC'
	  and cuenta = vlValorAlfabetico;
      
      if vlCDummy > 0 then continue foreach; end if; 
	 
	 select numcte,num_credito
	  into vnumcte,vnum_credito
	  from bdicred:sd_maecred
	 where num_credito =vlValorAlfabetico;  --in ('600109267697','600030001041','600109267432')
	 

	 
	 select CASE WHEN LENGTH(a.nombre1) <=  3 THEN TRIM(a.nombre1)||' '||TRIM(SUBSTR(a.nombre2,1,9 - LENGTH(a.nombre1))) ELSE
																					SUBSTR(a.nombre1,1,10) END nombre into vapellido_pat
    from bdinteg:si_cliente a where numcte = vnumcte;
	 
	   call bdimnsj:"informix".sp_registra_evento (2, 'AUT_SINREC' , vnumcte, vnum_credito,'', 2,
							vapellido_pat,vfechas,'','','',0,0,0,0,0,'','')RETURNING cCodRet;

  END FOREACH;
	end if;

	/*if (vcontador  >= 1) then 
	CALL bdicobranza:"informix".sp_sms_reporte(1,0,0,0) RETURNING 	cCodRet;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, 'Reporte sms', '02')RETURNING cCodRet;
	end if;*/
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensajeRet, '03')RETURNING cCodRet;
	RETURN cCodRet,cMensajeRet;

END
END PROCEDURE;