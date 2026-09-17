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