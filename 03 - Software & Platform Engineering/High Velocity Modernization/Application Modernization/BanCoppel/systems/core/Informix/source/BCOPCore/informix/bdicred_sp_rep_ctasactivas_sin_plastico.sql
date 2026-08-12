CREATE PROCEDURE "informix".sp_rep_ctasactivas_sin_plastico(pEmpresa CHAR(3))

RETURNING 
          CHAR(06) AS resultado,    CHAR(80) AS mensaje;

--GEV Julio 2014.Reporte de cuentas activas con plastico vencido.
--1-Que cuentas no tienen plÃ¡stico activo por que se les asigno uno pero nunca completaron el proceso de activaciÃ³n 
--2-Que cuentas solicitaron la reposiciÃ³n (por cualquier causa) pero nunca solicitaron el plÃ¡stico nuevo 
--3-Que cuentas no tienen plÃ¡stico activo por que ya paso la fecha de vencimiento y nunca fueron por el nuevo. 


DEFINE pproceso         CHAR(4);
DEFINE cCod_RetIB       CHAR(6);
DEFINE dFechaHoy        DATE;
DEFINE dtFechaFin       DATE;
DEFINE sql_err      	INTEGER;
DEFINE isam_err         INTEGER;
DEFINE error_info       CHAR(80);
DEFINE pCod_ret          CHAR(6); 
DEFINE pMensaje      CHAR(80);
DEFINE cRutaArch        CHAR(100);
DEFINE cNomArchivo      CHAR(100);
DEFINE cNomArch         CHAR(100);
DEFINE cNomArch1        CHAR(100);
DEFINE cNomArchEjecSql  CHAR(100);
DEFINE cSQL             CHAR(2500);
DEFINE cSQL1            CHAR(500);
DEFINE cSQL2            CHAR(1500);
DEFINE cSQL3            CHAR(500);
DEFINE sDiasVig         SMALLINT;
DEFINE sDiasVige        SMALLINT;
DEFINE cNum_dia         CHAR(2);
DEFINE cNum_mes         CHAR(2);
DEFINE cNum_anio        CHAR(4);
DEFINE cNum_cte         CHAR(20);
DEFINE cNum_cred        CHAR(20);
DEFINE cNumTel          CHAR(13);
DEFINE vRegistrosLimit	INTEGER;
DEFINE vTot_Registros   INTEGER;
DEFINE viPrioridad      INTEGER;
DEFINE sPaso			SMALLINT;
DEFINE cdelimitador     CHAR(1);
DEFINE v_sucursal		LIKE bdicred:"informix".sd_maecred.sucursal;
DEFINE v_numcredito		LIKE bdicred:"informix".sd_maecred.num_credito;
DEFINE v_numcte			LIKE bdicred:"informix".sd_maecred.numcte;
DEFINE v_nombre			VARCHAR(55,1);
DEFINE v_apell_paterno	VARCHAR(26,1);
DEFINE v_apell_materno	VARCHAR(26,1);
DEFINE v_monto			LIKE bdicred:"informix".sd_maesdos.monto_otorgado;
DEFINE v_fechaapertura	LIKE bdicred:"informix".sd_maecred.fecha_apertura;
DEFINE v_fechaultcompra DATE;
DEFINE v_expiracion		DATE;
DEFINE v_constatustar	CHAR(3);
DEFINE v_secuencia		SMALLINT;
DEFINE v_nombre_estado 	CHAR(30);
DEFINE v_fechamod		DATE;
DEFINE v_usuariomod		CHAR(9);
DEFINE v_fechaasigna	DATE;
DEFINE v_sdocapital		DECIMAL(18,2);
DEFINE v_correo			VARCHAR(100,1);
DEFINE v_telefono		CHAR(13);
DEFINE v_noempleado		CHAR(9);

--SET DEBUG FILE TO "sp_rep_ctasactivas_sin_plastico.out";
--TRACE ON;

LET pproceso        = '3400';
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
LET sDiasVig        = 0;
LET sDiasVige       = 0;
LET cNum_dia        = '';
LET cNum_mes        = '';
LET cNum_anio       = '';
LET cNum_cte        = '';
LET cNum_cred       = '';
LET cNumTel         = '';
LET vRegistrosLimit = 0;
LET vTot_Registros  = 0;
LET sPaso           = 0;
LET viPrioridad     = 0;
LET cdelimitador            = "";
LET v_sucursal		= '';
LET v_numcredito	= '';
LET v_numcte		= '';
LET v_nombre		= '';
LET v_apell_paterno	= '';
LET v_apell_materno = '';
LET v_monto			= 0;
LET v_fechaapertura	= DATE(0);
LET v_fechaultcompra= DATE(0);
LET v_expiracion	= DATE(0);
LET v_constatustar	= '';
LET v_secuencia		= 0;
LET v_nombre_estado = '';
LET v_fechamod		= DATE(0);
LET v_usuariomod	= '';
LET v_fechaasigna	= DATE(0);
LET v_sdocapital	= 0.0;
LET v_correo		= '';
LET v_telefono		= '';
LET v_noempleado	= '';

BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET pCod_ret = sql_err;
		LET pMensaje = error_info;
		CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '02')
		Returning cCod_RetIB;
	END EXCEPTION;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '01')
	Returning cCod_RetIB;
	
	select fecha_hoy into dFechaHoy from bdicred:sd_fechas where empresa = '001';
	
	--let dFechaHoy = mdy(10,03,2017); 
	
	LET cNum_dia = lpad(day(dFechaHoy),2,'0');
    LET cNum_mes =  lpad(month(dFechaHoy),2,'0');
    LET cNum_anio = lpad(year(dFechaHoy),4,'0');
    LET cNum_anio = substr(year(dFechaHoy),3,2);
	
	SELECT TRIM(valor_alfabetico) INTO cdelimitador 
		FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa AND tipo_campania = 61 
	AND grupo_parametro = 'ARCHIVOSEP' AND num_parametro = 336;
	
	
	SELECT valor_alfabetico INTO cRutaArch 
	FROM bdicred:sd_param_campania WHERE tipo_campania = 50 AND grupo_parametro = 'CAT_PROMOS' 
	AND num_parametro = 2;
	
	TRUNCATE TABLE "informix".sd_ctasactivas_sinplastico;

	
	select mae.num_credito,mae.fecha_apertura,mae.sucursal,ind.fecha_ultima_compra,sdo.sdo_cap_insoluto,sdo.monto_otorgado
	from bdicred:sd_maecred mae 
	join bdicred:sd_indicador_cred ind on (mae.num_credito = ind.num_credito and mae.empresa = ind.empresa)
	join bdicred:sd_maesdos sdo on (mae.num_credito = sdo.num_credito and mae.empresa = sdo.empresa)
    where mae.empresa = '001'
	and mae.status_cred  IN ('AA','E1')
	AND (sdo.monto_vencido + sdo.mto_venc_trasp) = 0
	and mae.num_producto = '6001'
	into temp credActivos with no log;

	create index inx_credActivos on credActivos(num_credito);
	update statistics medium for table credActivos;

	select a.*,b.expiracion,b.numcte,b.secuencia,b.num_tarjeta,c.codstatustarjeta,c.fechaultmodif,c.usuarioultmodif,c.fechaasignacion
	from credActivos a
	join bdicred:sd_tarjeta b on (a.num_credito = b.num_credito)
	join intercard:tarjeta c on (b.num_tarjeta = c.numtarjeta)
	where b.tipo_tarjeta = 'T'
	and b.secuencia = (select max(tar2.secuencia) from bdicred:sd_tarjeta tar2 where tar2.num_credito = a.num_credito
						and tar2.status_tar <>  'A' and tar2.tipo_tarjeta ='T')
	into temp credActivosFinal with no log;
	
	select num_credito from bdicred:sd_tarjeta 
	where num_credito in ( select num_credito from credActivosFinal  )
	and status_tar ='A' 
	into temp CreditosconTA with no log;

	delete from credActivosFinal  
	where num_credito in ( select num_credito from CreditosconTA);

	FOREACH
		select t1.sucursal,t1.num_credito,t1.numcte,trim(trim(cte.nombre1) ||' '|| trim(cte.nombre2))
        ,trim(cte.apell_paterno),trim(cte.apell_materno),t1.monto_otorgado,t1.fecha_apertura
        ,t1.fecha_ultima_compra,t1.expiracion,t1.codstatustarjeta,t1.secuencia
        ,es.nombre,t1.fechaultmodif,t1.usuarioultmodif,t1.fechaasignacion
        ,t1.sdo_cap_insoluto,trim(corr.correo_elec),tel2.telefono as telefono2,bita.no_empleado_asigna as usuario_entr_tarjeta 
		into v_sucursal,v_numcredito,v_numcte, v_nombre
					,v_apell_paterno,v_apell_materno,v_monto,v_fechaapertura
					,v_fechaultcompra,v_expiracion,v_constatustar,v_secuencia
					,v_nombre_estado,v_fechamod,v_usuariomod,v_fechaasigna
					,v_sdocapital,v_correo,v_telefono,v_noempleado
		from credActivosFinal t1
		join bdinteg:si_cliente cte on (t1.numcte = cte.numcte)
		join bdinteg:si_direcciones_actual dir1 ON (cte.numcte = dir1.numcte AND dir1.tipo_dir = '1')
		join bdinteg:si_estados es on (es.estado=dir1.estado  ) 
				left outer join bdinteg:si_correos corr ON ( cte.numcte = corr.numcte and corr.status_correo = 'A'
								and corr.secuencia = (select max(secuencia) from bdinteg:si_correos where cte.numcte = numcte and status_correo = 'A'))
				left outer join bdinteg:si_telefonos_actual tel1  on (tel1.empresa = '001' and tel1.numcte= t1.numcte and tel1.tipo_tel = 1 and tel1.cofetel ='V'
								and tel1.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
													 where numcte = t1.numcte and tipo_tel = 1 and cofetel ='V') )
				left outer join bdinteg:si_telefonos_actual tel2  on (tel2.empresa = '001' and tel2.numcte= t1.numcte and tel2.tipo_tel = 2 and tel2.cofetel ='V'
								and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
													 where numcte = t1.numcte and tipo_tel = 2 and cofetel ='V'))
				left outer join bdinteg:si_telefonos_actual tel3  on (tel3.empresa = '001' and tel3.numcte= t1.numcte and tel3.tipo_tel = 3 and tel3.cofetel ='V'
								and tel3.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
													 where numcte = t1.numcte and tipo_tel = 3 and cofetel ='V'))
				left outer join bdinteg:si_telefonos_actual tel4  on (tel4.empresa = '001' and tel4.numcte= t1.numcte and tel4.tipo_tel = 4 and tel3.cofetel ='V'
								and tel4.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
													 where numcte = t1.numcte and tipo_tel = 4 and cofetel ='V'))
				left outer join bdicred:bitacora_activacion bita on (t1.num_tarjeta = bita.numtarjeta)			
				
		insert into "informix".sd_ctasactivas_sinplastico values (v_sucursal,v_numcredito,v_numcte, v_nombre,v_apell_paterno,v_apell_materno,v_monto,v_fechaapertura,v_fechaultcompra,v_expiracion
			,v_constatustar,v_secuencia,v_nombre_estado,v_fechamod,v_usuariomod,v_fechaasigna,v_sdocapital,v_correo,v_telefono,v_noempleado);
		
		LET v_sucursal		= '';	LET v_numcredito	= '';	LET v_numcte		= '';	LET v_nombre		= '';	LET v_monto			= 0;	LET v_fechaapertura	= DATE(0);
		LET v_fechaultcompra= DATE(0);	LET v_expiracion	= DATE(0); LET v_constatustar	= '';	LET v_secuencia		= 0; LET v_nombre_estado = '';	LET v_fechamod		= DATE(0);
		LET v_usuariomod	= '';	LET v_fechaasigna	= DATE(0);	LET v_sdocapital	= 0.0;	LET v_correo		= '';	LET v_telefono		= '';	LET v_noempleado	= ''; LET v_apell_paterno	= '';
		LET v_apell_materno = '';
		
	END FOREACH

--- Genera archivo para clientes con plastico vencido
	
    LET cNomArch1 =  'cuentas_activas_sin_plastico'|| TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
    LET cNomArch  =  'cuentas_activas_sin_plastico_'|| TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
    LET cNomArchEjecSql = 'Rep_ctasactivas_sinplastico.sql';

    LET cSQL = '';
	LET cSQL = ' echo "Sucursal'|| cdelimitador ||'NÃºmero_de_crÃ©dito'|| cdelimitador ||'NÃºmero_de_cliente'|| cdelimitador ||'Nombre(s)'|| cdelimitador 
	||'Apellido Paterno'|| cdelimitador ||
	'Apellido Materno'|| cdelimitador ||
	'LÃ­nea_de_crÃ©dito'|| cdelimitador ||
	'Fecha_de_activaciÃ³n'|| cdelimitador ||'Fecha_ultima_compra_o_disposiciÃ³n'|| cdelimitador ||'Fecha_de_vencimiento'|| cdelimitador ||
	'Estatus_del_plÃ¡stico'|| cdelimitador ||'Secuencia'|| cdelimitador ||
	--'Tel_const_tipo_1'|| cdelimitador ||'Tel_const_tipo_2'|| cdelimitador ||
	--'Tel_const_tipo_3'|| cdelimitador ||'Tel_const_tipo_4'|| cdelimitador ||'Correo_electronico'|| cdelimitador ||
	'Estado'|| cdelimitador ||'Fecha_ult_modificacion'|| cdelimitador ||
	'Usuario_ult_modif'|| cdelimitador ||'Fecha_asignacion'|| cdelimitador ||'Saldo'|| cdelimitador 
	||'Correo ElectrÃ³nico'|| cdelimitador 
	||'TelÃ©fono 2 (Celular)'|| cdelimitador
	||'Usuario_ent_tarjeta' || cdelimitador --Campo nuevo
	||'"> ' || TRIM(cRutaArch) || TRIM(cNomArch);
	SYSTEM cSQL;

	LET cSQL1 = '';
    LET cSQL1 = ' echo "UNLOAD TO ' || TRIM(cRutaArch) || TRIM(cNomArch1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';

    LET cSQL2 = ''; 
    LET cSQL2 = ' SELECT * FROM "informix".sd_ctasactivas_sinplastico';
             
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