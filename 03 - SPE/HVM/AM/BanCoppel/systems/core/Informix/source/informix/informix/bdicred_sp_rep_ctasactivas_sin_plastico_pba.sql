CREATE PROCEDURE "informix".sp_rep_ctasactivas_sin_plastico_pba(pEmpresa CHAR(3))

RETURNING 
          CHAR(06) AS resultado,    CHAR(80) AS mensaje;

--GEV Julio 2014.Reporte de cuentas activas con plastico vencido.
--1-Que cuentas no tienen plástico activo por que se les asigno uno pero nunca completaron el proceso de activación 
--2-Que cuentas solicitaron la reposición (por cualquier causa) pero nunca solicitaron el plástico nuevo 
--3-Que cuentas no tienen plástico activo por que ya paso la fecha de vencimiento y nunca fueron por el nuevo. 


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
DEFINE cdelimitador         CHAR(1);

--SET DEBUG FILE TO "/informix/gpe/sp_rep_ctasactivas_sin_plastico.out";
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

BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
	LET pCod_ret = sql_err;
	LET pMensaje = error_info;
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '02')
	Returning cCod_RetIB;
	
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= '"informix".sd_ctasactivas_sinplastico';
        IF NVL(sPaso,0) > 0 THEN
            DROP TABLE "informix".sd_ctasactivas_sinplastico;
        END IF;
		RETURN pCod_ret,pMensaje;
	
	END EXCEPTION;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '01')
	Returning cCod_RetIB;
	
	select fecha_hoy into dFechaHoy from bdicred:sd_fechas where empresa = '001';
	
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
	--let cRutaArch = "/informix/gpe/";
	
	
	create table "informix".sd_ctasactivas_sinplastico(
	sucursal char(4),num_credito char(12),    numcte char(9), 
	nombres varchar(55,1),
	apell_paterno varchar(26,1),
	apell_materno varchar(26,1),
    linea_credito decimal(18,2),
	fecha_activacion date,   fecha_ultima_compra date,   fecha_vencimiento date,   status_plastico char(3), secuencia smallint,
	--telefono1 char(13),    telefono2 char(13),   telefono3 char(13),   telefono4 char(13),
	estado  char(30), fechaultmodif date, usuarioultmodif char(9), fechaasignacion date, saldo decimal(18,2),
	correo  varchar(100,1),
	telefono2 char(13)
	);

	create index inx_ctas on sd_ctasactivas_sinplastico(num_credito);
	update statistics high for table sd_ctasactivas_sinplastico;

	
		select {+MULTI_INDEX(sd_maecred maesta idx_idx_maecredb)} cre.sucursal,cre.fecha_apertura, ind.fecha_ultima_compra,  tar.num_credito, tar.expiracion, tar.numcte, inter.codstatustarjeta,tar.secuencia,
		inter.fechaultmodif, inter.usuarioultmodif, inter.fechaasignacion, mae.sdo_cap_insoluto
	from bdicred:sd_maecred cre, bdicred:sd_tarjeta tar, bdicred:sd_indicador_cred ind, intercard:tarjeta inter,bdicred:sd_maesdos mae
	 where cre.empresa  = tar.empresa
	and cre.num_credito  = tar.num_credito
	and cre.empresa  = ind.empresa
	and cre.empresa  = mae.empresa
	and cre.num_credito  = ind.num_credito
	and cre.num_credito  = mae.num_credito
    and tar.num_tarjeta  = inter.numtarjeta
	and cre.status_cred  = 'AA'
	and tar.status_tar <>  'A'
	and tar.tipo_tarjeta ='T'
	--and inter.codstatustarjeta <> 'ACT'
	and tar.secuencia = (select max(tar2.secuencia) from bdicred:sd_tarjeta tar2 where tar2.num_credito = tar.num_credito
	and tar.status_tar <>  'A' and tar.tipo_tarjeta ='T')
	into temp activostarvencida with no log;
	
	select num_credito from bdicred:sd_tarjeta 
	where num_credito in ( select num_credito from activostarvencida  )
	and status_tar ='A' 
	into temp CreditosconTA with no log;
	
	delete from activostarvencida  
	where num_credito in ( select num_credito from CreditosconTA);

	 
	insert into "informix".sd_ctasactivas_sinplastico
	select t1.sucursal,t1.num_credito,t1.numcte,
		trim(trim(cte.nombre1) ||' '|| trim(cte.nombre2)),
		trim(cte.apell_paterno),
		trim(cte.apell_materno),
	 sdo.monto_otorgado,t1.fecha_apertura, t1.fecha_ultima_compra, --num_tarjeta,--sdo.sdo_cap_insoluto
	t1.expiracion,t1.codstatustarjeta, t1.secuencia, /*tel1.telefono as telefono1,tel3.telefono as telefono3,
	tel4.telefono as telefono4,*/ es.nombre, t1.fechaultmodif, t1.usuarioultmodif, t1.fechaasignacion, t1.sdo_cap_insoluto,
	trim(corr.correo_elec), tel2.telefono as telefono2	
	from activostarvencida t1
    join bdicred:sd_maesdos sdo on (t1.num_credito = sdo.num_credito)
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
                                                 where numcte = t1.numcte and tipo_tel = 4 and cofetel ='V'));

--Elimina
	/*update sd_ctasactivas_sinplastico 
		set telefono4 = nvl(substr(telefono4,length(telefono4)-9,10),''),
			telefono1 = nvl(substr(telefono1,length(telefono1)-9,10),''),
			telefono2 = nvl(substr(telefono2,length(telefono2)-9,10),''),
			telefono3 = nvl(substr(telefono3,length(telefono3)-9,10),'');
	
	delete from sd_ctasactivas_sinplastico  where nvl(telefono1,'') ='' and nvl(telefono2,'')='' and nvl(telefono3,'')='' 
		and nvl(telefono4,'')='';

	update sd_ctasactivas_sinplastico set telefono2 = ''
	where nvl(telefono1,'')= nvl(telefono2,'');

	update sd_ctasactivas_sinplastico set telefono3 = ''
	where nvl(telefono3,'')= nvl(telefono2,'') or nvl(telefono3,'')= nvl(telefono1,'');

	update sd_ctasactivas_sinplastico set telefono4 = ''
	where nvl(telefono1,'')= nvl(telefono4,'') or nvl(telefono2,'')= nvl(telefono4,'') or nvl(telefono3,'')= nvl(telefono4,''); 
	
	update sd_ctasactivas_sinplastico 
		set telefono4 = nvl(telefono4,'') ,
			telefono1 = nvl(telefono1,''), 
			telefono2 = nvl(telefono2,''),
			telefono3 = nvl(telefono3,''); 
			
update sd_ctasactivas_sinplastico 
		set telefono4 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono4,1,2) in ('55','33','81')  then 
									SUBSTR(telefono4,1,2) else SUBSTR(telefono4,1,3) end 
						   AND a.serie = case when SUBSTR(telefono4,1,2) in ('55','33','81')  then SUBSTR(telefono4,3,4) else SUBSTR(telefono4,4,3) end 
						   AND (SUBSTR(telefono4,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono4,7,4)*1)*1 <= a.numeracion_final ),'')||telefono4 ,
			telefono1 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono1,1,2) in ('55','33','81')  then 
									SUBSTR(telefono1,1,2) else SUBSTR(telefono1,1,3) end 
						   AND a.serie = case when SUBSTR(telefono1,1,2) in ('55','33','81')  then SUBSTR(telefono1,3,4) else SUBSTR(telefono1,4,3) end 
						   AND (SUBSTR(telefono1,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono1,7,4)*1)*1 <= a.numeracion_final ),'')||telefono1 ,		 
			telefono2 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono2 ,1,2) in ('55','33','81')  then 
									SUBSTR(telefono2 ,1,2) else SUBSTR(telefono2 ,1,3) end 
						   AND a.serie = case when SUBSTR(telefono2 ,1,2) in ('55','33','81')  then SUBSTR(telefono2 ,3,4) else SUBSTR(telefono2,4,3) end 
						   AND (SUBSTR(telefono2,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono2,7,4)*1)*1 <= a.numeracion_final ),'')||telefono2 ,
			telefono3 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono3,1,2) in ('55','33','81')  then 
									SUBSTR(telefono3,1,2) else SUBSTR(telefono3,1,3) end 
						   AND a.serie = case when SUBSTR(telefono3,1,2) in ('55','33','81')  then SUBSTR(telefono3,3,4) else SUBSTR(telefono3,4,3) end 
						   AND (SUBSTR(telefono3,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono3,7,4)*1)*1 <= a.numeracion_final ),'')||telefono3; 
			
		update sd_ctasactivas_sinplastico 
		set telefono4 = decode(telefono4,'',null, telefono4),
			telefono1 = decode(telefono1,'',null, telefono1), 
			telefono2 = decode(telefono2,'',null, telefono2),
			telefono3 = decode(telefono3,'',null, telefono3);*/

--- Genera archivo para clientes con plastico vencido
	
    LET cNomArch1 =  'cuentas_activas_sin_plastico'|| TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
    LET cNomArch  =  'cuentas_activas_sin_plastico_'|| TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
    LET cNomArchEjecSql = 'Rep_ctasactivas_sinplastico.sql';

    LET cSQL = '';
	LET cSQL = ' echo "Sucursal'|| cdelimitador ||'Número_de_crédito'|| cdelimitador ||'Número_de_cliente'|| cdelimitador ||'Nombre(s)'|| cdelimitador 
	||'Apellido Paterno'|| cdelimitador ||
	'Apellido Materno'|| cdelimitador ||
	'Línea_de_crédito'|| cdelimitador ||
	'Fecha_de_activación'|| cdelimitador ||'Fecha_ultima_compra_o_disposición'|| cdelimitador ||'Fecha_de_vencimiento'|| cdelimitador ||
	'Estatus_del_plástico'|| cdelimitador ||'Secuencia'|| cdelimitador ||
	--'Tel_const_tipo_1'|| cdelimitador ||'Tel_const_tipo_2'|| cdelimitador ||
	--'Tel_const_tipo_3'|| cdelimitador ||'Tel_const_tipo_4'|| cdelimitador ||'Correo_electronico'|| cdelimitador ||
	'Estado'|| cdelimitador ||'Fecha_ult_modificacion'|| cdelimitador ||
	'Usuario_ult_modif'|| cdelimitador ||'Fecha_asignacion'|| cdelimitador ||'Saldo'|| cdelimitador 
	||'Correo Electrónico'|| cdelimitador 
	||'Teléfono 2 (Celular)'|| cdelimitador 
	||'"> ' || TRIM(cRutaArch) || TRIM(cNomArch);
	SYSTEM cSQL;

	LET cSQL1 = '';
    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRutaArch) || TRIM(cNomArch1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';

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
	
	DROP TABLE "informix".sd_ctasactivas_sinplastico;
	
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '03')
		Returning cCod_RetIB;

	RETURN pCod_ret,pMensaje;

END
END PROCEDURE;