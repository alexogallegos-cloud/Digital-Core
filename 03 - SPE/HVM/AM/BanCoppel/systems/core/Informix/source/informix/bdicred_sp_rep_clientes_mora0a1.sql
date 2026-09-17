CREATE PROCEDURE "informix".sp_rep_clientes_mora0a1(pEmpresa CHAR(3))

RETURNING 
          CHAR(06) AS resultado,    CHAR(80) AS mensaje;

--GEV Octubre 2014.Reporte de cuentas que pasan de mora 0 a mora 1.

DEFINE pproceso         CHAR(4);
DEFINE cCod_RetIB       CHAR(6);
DEFINE dFechaHoy        DATE;
DEFINE dtFechaFin       DATE;
DEFINE sql_err      	INTEGER;
DEFINE isam_err         INTEGER;
DEFINE error_info       CHAR(80);
DEFINE pCod_ret         CHAR(6); 
DEFINE pMensaje      	CHAR(80);
DEFINE cRutaArch        CHAR(100);
DEFINE cNomArchivo      CHAR(100);
DEFINE cNomArch         CHAR(100);
DEFINE cNomArch1        CHAR(100);
DEFINE cNomArchEjecSql  CHAR(100);
DEFINE cSQL             CHAR(2500);
DEFINE cSQL1            CHAR(500);
DEFINE cSQL2            CHAR(1500);
DEFINE cSQL3            CHAR(500);
DEFINE cNum_cte         CHAR(20);
DEFINE cNum_cred        CHAR(20);
DEFINE cNumTel          CHAR(13);
DEFINE sPaso			SMALLINT;
DEFINE cdelimitador         CHAR(1);
DEFINE cNum_mes         CHAR(2);
DEFINE cNum_anio        CHAR(4);
DEFINE cFecha_corte DATE;
DEFINE cFecha_anterior DATE;

--SET DEBUG FILE TO "/INFORMIXDUMP/sp_rep_clientes_mora0a1.out";
--TRACE ON;

LET pproceso        = '3001';
LET cCod_RetIB      = '000000';
LET dFechaHoy       = DATE(0);
LET pMensaje     = 'PROCESO EXITOSO';
LET sql_err         = 0;
LET isam_err        = 0;
LET error_info      = "";
LET pCod_ret         = '000000';
LET cRutaArch       = '';
LET cNomArchivo     = '';
LET cNomArch        = '';
LET cNomArch1       = '';
LET cNomArchEjecSql = '';
LET cSQL            = '';
LET cSQL1           = '';
LET cSQL2           = '';
LET cSQL3           = '';
LET cNum_cte        = '';
LET cNum_cred       = '';
LET cNumTel         = '';
LET sPaso           = 0;
LET cdelimitador            = "";
LET cNum_mes        = '';
LET cNum_anio       = '';
LET cFecha_corte = DATE(0);
LET cFecha_anterior = DATE(0);


BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
	LET pCod_ret = sql_err;
	LET pMensaje = error_info;
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '02')
	Returning cCod_RetIB;
	
		RETURN pCod_ret,pMensaje;
	END EXCEPTION;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '01')
	Returning cCod_RetIB;
	
	--select fecha_hoy, fecha_hoy - 1 units month into dFechaHoy, dFechaanterior from bdicred:sd_fechas where empresa = '001';
	
	select fecha_hoy into dFechaHoy from bdicred:sd_fechas where empresa = '001';
	
	--LET cNum_dia = lpad(day(dFechaHoy),2,'0');
    LET cNum_mes =  lpad(month(dFechaHoy),2,'0');
    LET cNum_anio = lpad(year(dFechaHoy),4,'0');
    LET cNum_anio = substr(year(dFechaHoy),3,2);
	LET cFecha_corte =mdy(month(dFechaHoy),'20',year(dFechaHoy));
	LET cFecha_anterior = cFecha_corte - 1 units month;
	
	select trim(valor_alfabetico) into cdelimitador 
		from bdicred:"informix".sd_param_campania where empresa = pempresa and tipo_campania = 61 
	and grupo_parametro = 'ARCHIVOSEP' and num_parametro = 336;
	
	
	select valor_alfabetico into cRutaArch 
		from bdicred:sd_param_campania where tipo_campania = 50 and grupo_parametro = 'CAT_PROMOS' 
	and num_parametro = 2;

	/*select num_credito  from bdicred:sd_maesdoshist where fecha = mdy('06','20','2014') and empresa = '001'
	and mto_fin_ven_trasp = 0
	into temp CreditosVigentes with no log;*/

	select a.num_credito,a.mto_fin_ven_trasp  from bdicred:sd_maesdoshist a where a.fecha = cFecha_corte and a.empresa = '001'
	and a.mto_fin_ven_trasp = 1
	and a.num_credito in (select b.num_credito  from bdicred:sd_maesdoshist b where b.fecha = cFecha_anterior and b.empresa = '001'
	and b.mto_fin_ven_trasp = 0)
	into temp CreditosMora1 with no log;
	
	insert into CreditosMora1
	select c.num_credito,c.mto_fin_ven_trasp  
	from bdicred:sd_maesdoshist c where c.fecha = cFecha_corte and c.empresa = '001'
	and c.mto_fin_ven_trasp > 0
	and c.num_credito in ( select d.num_credito from bdicred:sd_clientes_mora_mensual d 
	 where d.fecha_corte = cFecha_anterior 
	and d.mora > 0)	;
	--into temp CreditosMora2 with no log;
		

	--drop table ClientesCiudadMora1;
	select b.numcte  , a.num_credito,  d.numerociudad, a.mto_fin_ven_trasp
	from CreditosMora1 a, bdicred:sd_maecred b , bdinteg:si_direcciones_actual d
	where a.num_credito = b.num_credito 
	  and b.numcte = d.numcte 
	  and d.tipo_dir = 1
	  and d.numerociudad in ( 286,42,41,186,93,40,64,163,319,24,32,174,67,303,5656,106,170,9)
	into temp ClientesCiudadMora1 with no log;

	insert into "informix".sd_clientes_mora_mensual
	select m1.*, cFecha_corte, (select apell_paterno from bdinteg:si_cliente where numcte = m1.numcte), 
	(  monto_vencido + mto_venc_trasp + moratorio + interes_iva +mensualidad_actual ) sdo_tot_liquid, 
	(select max(telefono) from bdinteg:si_telefonos_actual where tipo_tel = 2 and numcte = m1.numcte  and cofetel = 'V'),
	(select correo_elec from bdinteg:si_correos 
		 where numcte = m1.numcte and secuencia = (select max(secuencia) from bdinteg:si_correos where numcte = m1.numcte   )  )
	from ClientesCiudadMora1 m1, bdicred:sd_sdos_cartera_linea lin
	where m1.num_credito = lin.num_credito;
	

--- Genera archivo para clientes con plastico vencido
	
    LET cNomArch1 =  'Clientes_Mora0a1'|| TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
    LET cNomArch  =  'Clientes_Mora0a1_'|| TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
    LET cNomArchEjecSql = 'Rep_clientes_mora.sql';

    LET cSQL = '';
	LET cSQL = ' echo "NÃºmero_de_cliente'|| cdelimitador ||'NÃºmero_de_crÃ©dito'|| cdelimitador ||'NÃºmero_de_ciudad'|| cdelimitador ||'Mora'|| cdelimitador ||
	'Fecha_corte'|| cdelimitador ||'Apellido_paterno'|| cdelimitador ||'Saldo'|| cdelimitador ||
	'NÃºmero_de_celular'|| cdelimitador ||'DirecciÃ³n_de_e-mail'|| cdelimitador ||'"> ' || TRIM(cRutaArch) || TRIM(cNomArch);
	SYSTEM cSQL;

	LET cSQL1 = '';
    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRutaArch) || TRIM(cNomArch1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';

    LET cSQL2 = ''; 
    LET cSQL2 = ' SELECT * FROM "informix".sd_clientes_mora_mensual where fecha_corte = '''||cFecha_corte||'''';
             
    LET cSQL3 = '">' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    SYSTEM cSQL;

    LET cSQL = 'chmod 777 '|| TRIM(cRutaArch)|| TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = 'dbaccess bdicred ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = '';
    LET cSQL = "sed 's/;$//g' "|| TRIM(cRutaArch) || TRIM(cNomArch1) || " >> " || TRIM(cRutaArch) || TRIM(cNomArch);
    SYSTEM cSQL;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cRutaArch) || TRIM(cNomArch1) || ' ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;			
	
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '03')
		Returning cCod_RetIB;

	RETURN pCod_ret,pMensaje;

END
END PROCEDURE;