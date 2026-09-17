CREATE PROCEDURE "informix".sp_rep_cartera_credito()

RETURNING       CHAR(6);

DEFINE cCodret         CHAR(6);
DEFINE sql_err         Integer;
DEFINE cNombre_Archivo CHAR(100);
DEFINE cSql            CHAR(2024);
DEFINE vruta           char(30); 
DEFINE cTipoSolicitud          CHAR(1);  
DEFINE dSeccionAux             DECIMAL(18,2); 
DEFINE iCantidad               INTEGER;
DEFINE dResultadoTotal DECIMAL(18,2);

DEFINE vnumcte			CHAR(20); 
DEFINE vnum_credito			CHAR(20);  
DEFINE vstatus				CHAR(20);
DEFINE vpago_vencido		smallint;
DEFINE vsaldo				decimal(18,2);
DEFINE vsaldo_vigente		decimal(18,2);
DEFINE vsaldo_transitorio	decimal(18,2);
DEFINE vvenc_exigible		decimal(18,2);  
DEFINE vvenc_noexigible		decimal(18,2);
DEFINE vpago_minimo			decimal(18,2);
DEFINE vmonto_otorgado		decimal(18,2);
DEFINE vfilro				CHAR(10);
DEFINE vsituacion_pago		decimal(18,2);
DEFINE vmeses_historia		smallint;
DEFINE vscore1				smallint;
DEFINE vscore2				smallint;
DEFINE vingreso_mensual		decimal(18,2);
DEFINE vfecha_apertura		DATE;
define vfecha				DATE;
define vcampo_trab3 CHAR(1);

LET cCodret         = "000000";
LET sql_err         = 0;
LET cNombre_Archivo = "";
LET cSql            = "";
LET vruta           = "";
LET cTipoSolicitud   = "";
LET dSeccionAux		=0;
LET iCantidad       =0;
LET dResultadoTotal =0;


LET vnumcte		= "";
LET vnum_credito		= "";
LET vstatus				= "";
LET vpago_vencido		= 0;
LET vsaldo				= 0;
LET vsaldo_vigente		= 0;
LET vsaldo_transitorio	= 0;
LET vvenc_exigible		= 0;
LET vvenc_noexigible	= 0;
LET vpago_minimo		= 0;
LET vmonto_otorgado		= 0;
LET vfilro				= "";
LET vsituacion_pago		= 0;
LET vmeses_historia		= 0;
LET vscore1				= 0;
LET vscore2				= 0;
LET vingreso_mensual	= 0;
LET vfecha_apertura		=DATE(1);
let vfecha				= DATE(1);
let vcampo_trab3  = '';

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

 ON EXCEPTION SET sql_err
             LET cCodret = sql_err;
             RETURN cCodret;
  END EXCEPTION;

--SET DEBUG FILE TO "sp_rep_cartera_credito.out";
--TRACE ON;
	select pri_dia_mes - 1 units day into vfecha
	from bdicred:sd_fechas where empresa = '001';
	
	
--asigna nombre del archivo concatenando mes y año 
LET  cNombre_Archivo= 'Reportecred'||to_char(vfecha, '%m%d%Y') || '.txt';

	let vruta = '/resplogifx/';

Set isolation to dirty read;
SET LOCK MODE TO WAIT 3;
	
--valida que no exista la tabla a crear
	IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'temp_cartera_credito' ) THEN
		IF not exists (select fecha_corte from  temp_cartera_credito where fecha_corte = today) THEN
			DROP TABLE temp_cartera_credito;
		END IF;    
	END IF;
	
	IF NOT EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'temp_cartera_credito' ) THEN
		CREATE TABLE  temp_cartera_credito      
		( numcte			CHAR(20), 
		num_credito			CHAR(20),  
		status				CHAR(20),
		pago_vencido		smallint,
		saldo				decimal(18,2),
		saldo_vigente		decimal(18,2),
		saldo_transitorio	decimal(18,2),
		venc_exigible		decimal(18,2), 
		venc_noexigible		decimal(18,2),
		pago_minimo			decimal(18,2),
		monto_otorgado		decimal(18,2),
		filro				CHAR(10),
		situacion_pago		decimal(18,2),
		meses_historia		smallint,
		score1				smallint,
		score2				smallint,
		ingreso_mensual		decimal(18,2),
		fecha_apertura		DATE, fecha_corte date,
    campo_trab3 CHAR(1) ); 
		
		 update statistics medium for table temp_cartera_credito;
	END IF;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
FOREACH WITH HOLD

	select mae.numcte,mae.num_credito,
	case when mae.status_cred = 'AA' then 'VIGENTE'
	     when mae.status_cred = 'BA' then 'TRANSITORIO' 
		 when mae.status_cred = 'E1' then 'ETAPA 1' 
		 when mae.status_cred = 'E2' then 'ETAPA 2' 
		 when mae.status_cred = 'E3' then 'ETAPA 3' 
		 else 'VENCIDO' END status,
	mas.mto_fin_ven_trasp,
	(mas.sdo_capital + mas.cap_tras_no_venci + mas.monto_vencido + mas.mto_venc_trasp),mas.sdo_capital,mas.monto_vencido,mas.mto_venc_trasp,mas.cap_tras_no_venci,
	nvl(re.pago_minimo,0),mas.monto_otorgado,
	(case when fin.evalua_cc = '1' then 'Hit'
	when fin.evalua_cc = '0' then 'Hit' 	when fin.evalua_cc = '2' then 'Hit'
	when fin.evalua_cc = '4' then 'Hit'	when fin.evalua_cc = 'X' then 'No Hit'
	when fin.evalua_cc = '' then 'No Hit' 	when fin.evalua_cc is null then 'No Hit' end) filtro ,
	nvl(fin.situacion_pago,0)situacion_pago ,nvl(fin.meses_historia,0)meses_historia,
	fin.ingreso_mensual,mae.fecha_apertura, case when mae.campo_trab3 = 'BAJA' then 'B' else '' end 
	into vnumcte,vnum_credito,vstatus,vpago_vencido,
	vsaldo,vsaldo_vigente,vsaldo_transitorio,vvenc_exigible,vvenc_noexigible,vpago_minimo,vmonto_otorgado,
	vfilro,vsituacion_pago,vmeses_historia,	vingreso_mensual,vfecha_apertura, vcampo_trab3
	from bdicred:sd_maecredcont mae
	join bdicred:sd_maesdoscont mas on mas.empresa = mae.empresa and mas.num_credito = mae.num_credito
	left join bdisolic:ss_resum_scor_fin fin on fin.empresa='001' and fin.num_solicitud = mae.num_credito
	left join bdicred:sd_hist_reserva re on (re.empresa ='001' and re.num_credito = mae.num_credito 
	and re.fecha_cierre = mas.fecha)
	where mae.empresa='001'
	and mae.status_cred not in ('CV','FF','FC')
	and mae.fecha = mas.fecha
	and mas.fecha = (select pri_dia_mes - 1 from bdicred:sd_fechas) -- fecha del último día del mes que pasó
	and (mas.sdo_capital + mas.cap_tras_no_venci + mas.monto_vencido + mas.mto_venc_trasp) > 0
	and mae.num_credito  not in (select num_credito from  temp_cartera_credito)
	--and mas.sdo_cap_insoluto > 0

	 
	-- Se obtiene las puntuaciones del scoring que se le realizó al cliente.
		SELECT NVL(SUM(DECODE(seccion, '1', NVL(evaluacion,0), 0)),0) AS seccion1,
			   NVL(SUM(DECODE(seccion, '2', NVL(evaluacion,0), 0)),0) AS seccion2,
			   NVL(SUM(NVL(evaluacion, 0)),0) AS suma,
			   COUNT(num_solicitud) AS cantidad
		INTO vscore1,vscore2,dResultadoTotal ,iCantidad
		FROM bdisolic:"informix".ss_resumen_scoring
		WHERE empresa= '001'  AND num_solicitud = vnum_credito   AND seccion IN ('1','2');

		IF iCantidad <> 2 THEN

			LET vscore1= 0;	LET vscore2= 0;
			
			FOREACH
				SELECT   decode(nvl(sg.agrupar, ''),'', SUM(nvl(dc.valor,0)), MAX(nvl(dc.valor,0))) AS suma
				INTO dSeccionAux
				FROM bdisolic:"informix".ss_detalle_scoring dc, bdisolic:"informix".ss_scoring_grupo sg
				WHERE sg.empresa = dc.empresa
				   AND sg.grupo = dc.grupo
				   AND sg.seccion = dc.seccion
				   AND dc.num_solicitud = vnum_credito
				   AND dc.seccion = '2'
				   AND dc.empresa = '001'
				GROUP BY sg.empresa, sg.seccion, sg.agrupar

				LET vscore2= vscore2 + dSeccionAux;
			END FOREACH;
			
			let vscore1 = dResultadoTotal - vscore2;
			
		END IF;

	--carga informacion en la tabla
	begin work;
		INSERT INTO  temp_cartera_credito
		VALUES(vnumcte,vnum_credito,vstatus,vpago_vencido,vsaldo,vsaldo_vigente,vsaldo_transitorio,vvenc_exigible,
		vvenc_noexigible,vpago_minimo,vmonto_otorgado,vfilro,vsituacion_pago,vmeses_historia,vscore1,vscore2,
		vingreso_mensual,vfecha_apertura,today, vcampo_trab3);
	commit work;
END FOREACH;
--Se genera archivo con la informacion del reporte 
LET cSql = '';
LET cSql = 'echo "UNLOAD TO ' || trim(vruta) || 'Reportecartera_credito.unl' || ' DELIMITER ' || '''|'''|| 
           ' select numcte,num_credito,status,pago_vencido,saldo,saldo_vigente,saldo_transitorio,venc_exigible,'|| 
		   ' venc_noexigible,pago_minimo,monto_otorgado,filro,situacion_pago,meses_historia,score1,score2,'||
		   --' ingreso_mensual,fecha_apertura from bdicred:temp_cartera_credito;'||
       ' ingreso_mensual,fecha_apertura, campo_trab3 from bdicred:temp_cartera_credito;'||
           ' " > '|| trim(vruta) || 'ReporteInformacioncartera_credito.sql';
SYSTEM cSql;

LET cSql = '';
LET cSql = 'dbaccess bdicred ' || trim(vruta) || 'ReporteInformacioncartera_credito.sql';
SYSTEM cSql;

LET cSql = '';
LET cSql = "sed 's/|$//g' "|| trim(vruta) ||'Reportecartera_credito.unl' || " > " || trim(vruta) || cNombre_Archivo;
SYSTEM cSql;
     
LET cSql = '';
LET cSQL = 'rm ' || trim(vruta) || 'ReporteInformacioncartera_credito.sql ' || trim(vruta) || 'Reportecartera_credito.unl';
SYSTEM cSql;
         
RETURN cCodret;

DROP TABLE  temp_repinformacionriesgos;  
END
END PROCEDURE
;