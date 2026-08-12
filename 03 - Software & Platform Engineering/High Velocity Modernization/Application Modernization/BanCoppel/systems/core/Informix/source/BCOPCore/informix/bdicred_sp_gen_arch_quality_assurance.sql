CREATE PROCEDURE "informix".sp_gen_arch_quality_assurance(pEmpresa CHAR(3))

RETURNING 
          CHAR(6) AS resultado,
          CHAR(80) AS mensaje;

-- Creado: Guadalupe Espinoza. Marzo 2014.- 
--Genera el archivo quality_assurance para crédito.
--29/05/2014 Se comenta la parte de encriptación
--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_RetIB           CHAR(6);
DEFINE cMensaje				CHAR(80);
DEFINE vproceso				CHAR(4);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE dnum_producto 		CHAR(4);
DEFINE dnum_solicitud 		CHAR(12);
DEFINE dnumcte 				CHAR(9);
DEFINE dsucursal 			CHAR(4);
DEFINE dfecha_entrada 		DATE;
DEFINE dfecha_envio 			DATE;
DEFINE dgrupo 				CHAR(1);
DEFINE dnombre 				CHAR(110);
DEFINE dtel_casa 			CHAR(10);
DEFINE dtel_celular 			CHAR(10);
DEFINE dtel_trabajo 			CHAR(10);
DEFINE dextension 			CHAR(10);
DEFINE dnombre_ref 			CHAR(110);
DEFINE dtelefono_casa_ref1 	CHAR(10);
DEFINE dtelefono_celular_ref1 CHAR(10);
DEFINE dnombre_ref_2 		CHAR(110);
DEFINE dtelefono_casa_ref2 	CHAR(10);
DEFINE dtelefono_celular_ref2 CHAR(10);
DEFINE cruta                CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivo2			CHAR(100);
DEFINE cSQL                 CHAR(8204);
DEFINE cSQL1                CHAR(1000);
DEFINE cSQL2                CHAR(2500);
DEFINE cSQL3                CHAR(500);
DEFINE dFecha				DATE; 
DEFINE dFecha_ant			DATE;
DEFINE dFecharest			DATE;
DEFINE cencripta			CHAR(100);

--SET DEBUG FILE TO "/informix/gpe/sp_gen_arch_quality_assurance.out";
--TRACE ON;

--Inicialización de variables
LET sql_err             = 0;
LET isam_err            = 0;
LET error_info          = '';
LET cCod_ret            = '000000';
LET cCod_RetIB          = '';
LET cMensaje            = 'PROCESO EXITOSO';
LET vproceso			= '3000';
LET cempresa            = '';
LET cdelimitador        = '';
LET dnum_producto 		= '';
LET dnum_solicitud 		= '';
LET dnumcte 			= '';
LET dsucursal 			= '';
LET dfecha_entrada 		= DATE(0);
LET dfecha_envio 		= DATE(0);
LET dgrupo 				= '';
LET dnombre 			= '';
LET dtel_casa 			= '';
LET dtel_celular 		= '';
LET dtel_trabajo 		= '';
LET dextension 			= '';
LET dnombre_ref 		= '';
LET dtelefono_casa_ref1 = '';
LET dtelefono_celular_ref1 = '';
LET dnombre_ref_2 		= '';
LET dtelefono_casa_ref2 = '';
LET dtelefono_celular_ref2 = '';
LET cruta               = '';
LET cnomarchivo         = '';
LET cnomarchivo1		= '';
LET cnomarchivo2		= '';
LET cSQL                = '';
LET cSQL1               = '';
LET cSQL2               = '';
LET cSQL3               = '';
--LET dFecha				= ''; 
--LET dFecha_ant			= '';
--LET dFecharest			= '';
LET cencripta			= '';
                      
BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = 'ERROR EN EL PROCESO';
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        RETURN cCod_ret,cMensaje;
	END EXCEPTION;

	CALL "informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_Ret, cMensaje, '01')RETURNING cCod_RetIB;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	SELECT fecha_hoy, fecha_hoy - 1 units day,today - 6 units day
	INTO dFecha, dFecha_ant ,dFecharest
	FROM bdicred:sd_fechas;
	
	--Pruebas
	--let dFecha = mdy('05','27','2014');--today
	--let dFecha_ant = mdy('05','26','2014');
	--let dFecharest = mdy('05','27','2014')/*today*/ - 6 units day;
	
	SELECT TRIM(valor_alfabetico) 
	INTO cRuta 
	FROM bdicred:"informix".sd_param_campania 
	WHERE empresa = '001' AND tipo_campania = 50 
	AND num_parametro = 2;
	
	--let cruta = '/informix/gpe/'; --pruebas
	
	select trim(valor_alfabetico) 
	into cencripta 
	from bdicred:"informix".sd_param_campania 
	where empresa = pempresa
    and tipo_campania = 64 
	and grupo_parametro = 'CODENCRIPTA' 
	and num_parametro = 639;
	
	select trim(valor_alfabetico) 
	into cdelimitador 
	from bdicred:"informix".sd_param_campania 
	where empresa = pempresa
    and tipo_campania = 61 
	and grupo_parametro = 'ARCHIVOSEP' 
	and num_parametro = 336;
	
--Tarjeta de Crédito
	--insert into "informix".sd_quality_assurance
	foreach 
	select limit 600
	decode(a.num_producto,'6001','60'),a.num_solicitud,a.numcte,a.sucursal,
	c.fecha_entrada,today,
	case when  b.meses_historia >= 13 and b.situacion_pago >= 85 and nvl(b.Grupo,'') not in ('6','A') then '1'
		 when  b.meses_historia >= 6 and b.meses_historia < 13 and b.situacion_pago >= 85 and  nvl(b.Grupo,'') not in ('6','A') then '2'
		 when  ((b.meses_historia < 6 and b.situacion_pago >= 85) or b.situacion_pago < 0) and nvl(b.Grupo,'') not in ('6','A') then '3'
		 when  b.situacion_pago < 85 and b.situacion_pago > 0 and nvl(b.Grupo,'') not in ('6','A') then '4'
		 when  (b.fuente = 'B' or b.fuente = '') and nvl(b.situacion_pago,0) = 0 and nvl(b.meses_historia,0) = 0 and nvl(b.Grupo,'') not in ('6','A') then '5'
		 when nvl(b.Grupo,'')= '6' THEN '6'
		 when nvl(b.Grupo,'')= 'A'  THEN 'A' ELSE '0' END  grupo,
	trim(d.nombre1)||' '||trim(d.nombre2)||' '||trim(d.apell_paterno)||' '||trim(d.apell_materno) nombre,
	tel1.telefono tel_casa, tel2.telefono tel_celular,tel3.telefono tel_trabajo,tel1.extension, 
	trim(e.nombre1)||' '||trim(e.nombre2)||' '||trim(e.apell_paterno)||' '||trim(e.apell_materno) nombre_ref,
	g.telefono1 telefono_casa_ref1, g.telefono2 telefono_celular_ref1, 
	trim(f.nombre1)||' '||trim(f.nombre2)||' '||trim(f.apell_paterno)||' '||trim(f.apell_materno) nombre_ref_2,
	h.telefono1 telefono_casa_ref2, h.telefono2 telefono_celular_ref2
	into dnum_producto,dnum_solicitud,dnumcte,dsucursal,dfecha_entrada,dfecha_envio,dgrupo,dnombre,dtel_casa,dtel_celular,
	dtel_trabajo,dextension,dnombre_ref,dtelefono_casa_ref1,dtelefono_celular_ref1,dnombre_ref_2,dtelefono_casa_ref2,
	dtelefono_celular_ref2
	from bdisolic:ss_solicitudes a
	 inner join bdisolic:ss_solicitud_os os on (os.empresa = a.empresa and  os.num_solicitud =a.num_solicitud and os.status = 'A')
	 inner join bdisolic:ss_resum_scor_fin b on (b.empresa =a.empresa and  b.num_solicitud =a.num_solicitud)
	 inner join bdisolic:ss_autorizacion c on (  c.empresa =a.empresa and  c.num_solicitud = a.num_solicitud 
	and c.status_solicitud= a.status_solicitud and c.fecha_salida = dFecha_ant) --'12-01-2013')
     inner join bdinteg:si_cliente d on (d.numcte = a.numcte)
     inner join bdinteg:si_refclientes e on (e.numcte = d.numcte and e.num_solicitud = a.num_solicitud 
	and e.secuencia = (select max(secuencia) from bdinteg:si_refclientes where e.numcte = numcte and
	e.num_solicitud = num_solicitud)) 
	inner join bdinteg:si_refclientes f on(f.numcte = d.numcte and f.num_solicitud = a.num_solicitud 
	and f.secuencia =(select min(secuencia) from bdinteg:si_refclientes where f.numcte = numcte and f.num_solicitud = num_solicitud))
    inner join bdinteg:si_refdirecciones g on (g.numcte = d.numcte and
	g.secuencia = (select max(secuencia) from bdinteg:si_refclientes where g.numcte = numcte)) 
	inner join bdinteg:si_refdirecciones h on (h.numcte = d.numcte and 
	h.secuencia = (select min(secuencia) from bdinteg:si_refclientes where h.numcte = numcte)) 
	left join bdinteg:si_telefonos_actual tel1  on (tel1.empresa = '001' and tel1.numcte=
	a.numcte and tel1.tipo_tel = 1 and tel1.cofetel ='V')
    left join bdinteg:si_telefonos_actual tel2  on (tel2.empresa = '001'
	and tel2.numcte= a.numcte and tel2.tipo_tel = 2 and tel2.cofetel ='V')
    left join bdinteg:si_telefonos_actual tel3  on (tel3.empresa = '001'
	and tel3.numcte= a.numcte and tel3.tipo_tel = 3 and tel3.cofetel ='V')
    left join bdinteg:si_telefonos_actual tel4  on (tel4.empresa = '001'
	and tel4.numcte= a.numcte and tel4.tipo_tel = 4 and tel4.cofetel ='V')
     where --a.empresa = b.empresa
	       a.status_solicitud = 'AP'	   
       and a.num_producto = '6001'
	   
	--if not exists (select sucursal from bdicred:sd_quality_assurance where fecha_envio >= dFecharest and sucursal = dsucursal) 	then
		if not exists (select num_solicitud from bdicred:sd_quality_assurance where num_solicitud = dnum_solicitud and fecha_envio = today)
			then
	   
	   insert into sd_quality_assurance(num_producto,num_solicitud,numcte,sucursal,fecha_entrada,fecha_envio,grupo,nombre,tel_casa,
	   tel_celular,tel_trabajo,extension,nombre_ref,telefono_casa_ref1,telefono_celular_ref1,nombre_ref_2,telefono_casa_ref2,
	   telefono_celular_ref2)
	   values (dnum_producto,dnum_solicitud,dnumcte,dsucursal,dfecha_entrada,dfecha_envio,dgrupo,dnombre,dtel_casa,dtel_celular,
	   dtel_trabajo,dextension,dnombre_ref,dtelefono_casa_ref1,dtelefono_celular_ref1,dnombre_ref_2,dtelefono_casa_ref2,
	   dtelefono_celular_ref2);
	   
		end if
	--end if;
	
	end foreach;
	   
--Préstamo Personal
	foreach
	--insert into "informix". 
	select limit 200
	decode(a.num_producto,'6300','63'),a.num_solicitud,a.numcte,a.sucursal,
	c.fecha_entrada,today,
	case when  b.meses_historia >= 13 and b.situacion_pago >= 85 and nvl(b.Grupo,'') not in ('6','A') then '1'
		 when  b.meses_historia >= 6 and b.meses_historia < 13 and b.situacion_pago >= 85 and  nvl(b.Grupo,'') not in ('6','A') then '2'
		 when  ((b.meses_historia < 6 and b.situacion_pago >= 85) or b.situacion_pago < 0) and nvl(b.Grupo,'') not in ('6','A') then '3'
		 when  b.situacion_pago < 85 and b.situacion_pago > 0 and nvl(b.Grupo,'') not in ('6','A') then '4'
		 when  (b.fuente = 'B' or b.fuente = '') and nvl(b.situacion_pago,0) = 0 and nvl(b.meses_historia,0) = 0 and nvl(b.Grupo,'') not in ('6','A') then '5'
		 when nvl(b.Grupo,'')= '6' THEN '6'
		 when nvl(b.Grupo,'')= 'A'  THEN 'A' ELSE '0' END  grupo,
	trim(d.nombre1)||' '||trim(d.nombre2)||' '||trim(d.apell_paterno)||' '||trim(d.apell_materno) nombre,
	tel1.telefono tel_casa, tel2.telefono tel_celular,tel3.telefono tel_trabajo,tel1.extension, 
	trim(e.nombre1)||' '||trim(e.nombre2)||' '||trim(e.apell_paterno)||' '||trim(e.apell_materno) nombre_ref,
	g.telefono1 telefono_casa_ref1, g.telefono2 telefono_celular_ref1, 
	trim(f.nombre1)||' '||trim(f.nombre2)||' '||trim(f.apell_paterno)||' '||trim(f.apell_materno) nombre_ref_2,
	h.telefono1 telefono_casa_ref2, h.telefono2 telefono_celular_ref2
	into dnum_producto,dnum_solicitud,dnumcte,dsucursal,dfecha_entrada,dfecha_envio,dgrupo,dnombre,dtel_casa,dtel_celular,
	dtel_trabajo,dextension,dnombre_ref,dtelefono_casa_ref1,dtelefono_celular_ref1,dnombre_ref_2,dtelefono_casa_ref2,
	dtelefono_celular_ref2
	from bdisolic:ss_solicitudes a
	 inner join bdisolic:ss_solicitud_os os on (os.empresa = a.empresa and  os.num_solicitud =a.num_solicitud and os.status = 'A')
	 inner join bdisolic:ss_resum_scor_fin b on (b.empresa =a.empresa and  b.num_solicitud =a.num_solicitud)
	 inner join bdisolic:ss_autorizacion c on (  c.empresa =a.empresa and  c.num_solicitud = a.num_solicitud 
	and c.status_solicitud= a.status_solicitud and c.fecha_salida = dFecha_ant)--'12-01-2013')
     inner join bdinteg:si_cliente d on (d.numcte = a.numcte)
     inner join bdinteg:si_refclientes e on (e.numcte = d.numcte and e.num_solicitud = a.num_solicitud 
	and e.secuencia = (select max(secuencia) from bdinteg:si_refclientes where e.numcte = numcte and
	e.num_solicitud = num_solicitud)) 
	inner join bdinteg:si_refclientes f on(f.numcte = d.numcte and f.num_solicitud = a.num_solicitud 
	and f.secuencia =(select min(secuencia) from bdinteg:si_refclientes where f.numcte = numcte and f.num_solicitud = num_solicitud))
    inner join bdinteg:si_refdirecciones g on (g.numcte = d.numcte and
	g.secuencia = (select max(secuencia) from bdinteg:si_refclientes where g.numcte = numcte)) 
	inner join bdinteg:si_refdirecciones h on (h.numcte = d.numcte and 
	h.secuencia = (select min(secuencia) from bdinteg:si_refclientes where h.numcte = numcte)) 
	left join bdinteg:si_telefonos_actual tel1  on (tel1.empresa = '001' and tel1.numcte=
	a.numcte and tel1.tipo_tel = 1 and tel1.cofetel ='V')
    left join bdinteg:si_telefonos_actual tel2  on (tel2.empresa = '001'
	and tel2.numcte= a.numcte and tel2.tipo_tel = 2 and tel2.cofetel ='V')
    left join bdinteg:si_telefonos_actual tel3  on (tel3.empresa = '001'
	and tel3.numcte= a.numcte and tel3.tipo_tel = 3 and tel3.cofetel ='V')
    left join bdinteg:si_telefonos_actual tel4  on (tel4.empresa = '001'
	and tel4.numcte= a.numcte and tel4.tipo_tel = 4 and tel4.cofetel ='V')
     where --a.empresa = b.empresa
	       a.status_solicitud = 'AP'	   
       and a.num_producto = '6300'
	   
	--if not exists (select sucursal from bdicred:sd_quality_assurance where fecha_envio >= dFecharest and sucursal = dsucursal) 
	--	then
		if not exists (select num_solicitud from bdicred:sd_quality_assurance where num_solicitud = dnum_solicitud and fecha_envio = today)
			then
	   
	   insert into sd_quality_assurance(num_producto,num_solicitud,numcte,sucursal,fecha_entrada,fecha_envio,grupo,nombre,tel_casa,
	   tel_celular,tel_trabajo,extension,nombre_ref,telefono_casa_ref1,telefono_celular_ref1,nombre_ref_2,telefono_casa_ref2,
	   telefono_celular_ref2)
	   values (dnum_producto,dnum_solicitud,dnumcte,dsucursal,dfecha_entrada,dfecha_envio,dgrupo,dnombre,dtel_casa,dtel_celular,
	   dtel_trabajo,dextension,dnombre_ref,dtelefono_casa_ref1,dtelefono_celular_ref1,dnombre_ref_2,dtelefono_casa_ref2,
	   dtelefono_celular_ref2);
	  end if 
	--end if;
	
	end foreach;
	
	--Elimina
	update sd_quality_assurance 
		set	tel_casa = nvl(substr(tel_casa,length(tel_casa)-9,10),''), 
			tel_celular = nvl(substr(tel_celular,length(tel_celular)-9,10),''),
			tel_trabajo = nvl(substr(tel_trabajo,length(tel_trabajo)-9,10),''),
			telefono_casa_ref1 = nvl(substr(telefono_casa_ref1,length(telefono_casa_ref1)-9,10),''),
			telefono_celular_ref1 = nvl(substr(telefono_celular_ref1,length(telefono_celular_ref1)-9,10),''),
			telefono_casa_ref2 = nvl(substr(telefono_casa_ref2,length(telefono_casa_ref2)-9,10),''),
			telefono_celular_ref2 = nvl(substr(telefono_celular_ref2,length(telefono_celular_ref2)-9,10),'');
			
	 --delete from temp_disposiciones  where nvl(telefono1,'') ='' and nvl(telefono2,'')='' and nvl(telefono3,'')='' 
		--and nvl(telefono4,'')='';

	update sd_quality_assurance set tel_casa = '0000000000',tel_celular = '0000000000',tel_trabajo = '0000000000',
	telefono_casa_ref1 = '0000000000',telefono_celular_ref1 = '0000000000',telefono_casa_ref2 = '0000000000',
	telefono_celular_ref2 = '0000000000'
	where nvl(tel_casa,'') ='' and nvl(tel_celular,'')='' and nvl(tel_trabajo,'')='' and nvl(telefono_casa_ref1,'')=''
	and nvl(telefono_celular_ref1,'')='' and nvl(telefono_casa_ref2,'')='' and nvl(telefono_celular_ref2,'')='';
	
	update sd_quality_assurance set tel_celular = '0000000000'
	where nvl(tel_casa,'')= nvl(tel_celular,'');

	update sd_quality_assurance set tel_trabajo = '0000000000'
	where nvl(tel_trabajo,'')= nvl(tel_celular,'') or nvl(tel_trabajo,'')= nvl(tel_casa,'');

	update sd_quality_assurance set telefono_celular_ref1 = '0000000000'
	where nvl(telefono_casa_ref1,'')= nvl(telefono_celular_ref1,'');
	
	update sd_quality_assurance set telefono_celular_ref2 = '0000000000'
	where nvl(telefono_casa_ref2,'')= nvl(telefono_celular_ref2,'');
	
	update sd_quality_assurance 
		set tel_casa = nvl(tel_casa,''), 
			tel_celular = nvl(tel_celular,''),
			tel_trabajo = nvl(tel_trabajo,''),
			telefono_casa_ref1 = nvl(telefono_casa_ref1,''), 
			telefono_celular_ref1 = nvl(telefono_celular_ref1,''),
			telefono_casa_ref2 = nvl(telefono_casa_ref2,''),
			telefono_celular_ref2 = nvl(telefono_celular_ref2,''); 
			
	update sd_quality_assurance 
		set tel_casa = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(tel_casa,1,2) in ('55','33','81')  then 
									SUBSTR(tel_casa,1,2) else SUBSTR(tel_casa,1,3) end 
						   AND a.serie = case when SUBSTR(tel_casa,1,2) in ('55','33','81')  then SUBSTR(tel_casa,3,4) else SUBSTR(tel_casa,4,3) end 
						   AND (SUBSTR(tel_casa,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(tel_casa,7,4)*1)*1 <= a.numeracion_final ),'')||tel_casa ,		 
			tel_celular = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(tel_celular ,1,2) in ('55','33','81')  then 
									SUBSTR(tel_celular ,1,2) else SUBSTR(tel_celular ,1,3) end 
						   AND a.serie = case when SUBSTR(tel_celular ,1,2) in ('55','33','81')  then SUBSTR(tel_celular ,3,4) else SUBSTR(tel_celular,4,3) end 
						   AND (SUBSTR(tel_celular,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(tel_celular,7,4)*1)*1 <= a.numeracion_final ),'')||tel_celular ,
			tel_trabajo = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(tel_trabajo,1,2) in ('55','33','81')  then 
									SUBSTR(tel_trabajo,1,2) else SUBSTR(tel_trabajo,1,3) end 
						   AND a.serie = case when SUBSTR(tel_trabajo,1,2) in ('55','33','81')  then SUBSTR(tel_trabajo,3,4) else SUBSTR(tel_trabajo,4,3) end 
						   AND (SUBSTR(tel_trabajo,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(tel_trabajo,7,4)*1)*1 <= a.numeracion_final ),'')||tel_trabajo, 
			telefono_casa_ref1 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono_casa_ref1,1,2) in ('55','33','81')  then 
									SUBSTR(telefono_casa_ref1,1,2) else SUBSTR(telefono_casa_ref1,1,3) end 
						   AND a.serie = case when SUBSTR(telefono_casa_ref1,1,2) in ('55','33','81')  then SUBSTR(telefono_casa_ref1,3,4) else SUBSTR(telefono_casa_ref1,4,3) end 
						   AND (SUBSTR(telefono_casa_ref1,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono_casa_ref1,7,4)*1)*1 <= a.numeracion_final ),'')||telefono_casa_ref1 ,		 
			telefono_celular_ref1 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono_celular_ref1 ,1,2) in ('55','33','81')  then 
									SUBSTR(telefono_celular_ref1 ,1,2) else SUBSTR(telefono_celular_ref1 ,1,3) end 
						   AND a.serie = case when SUBSTR(telefono_celular_ref1 ,1,2) in ('55','33','81')  then SUBSTR(telefono_celular_ref1 ,3,4) else SUBSTR(telefono_celular_ref1,4,3) end 
						   AND (SUBSTR(telefono_celular_ref1,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono_celular_ref1,7,4)*1)*1 <= a.numeracion_final ),'')||telefono_celular_ref1 ,
			telefono_casa_ref2 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono_casa_ref2,1,2) in ('55','33','81')  then 
									SUBSTR(telefono_casa_ref2,1,2) else SUBSTR(telefono_casa_ref2,1,3) end 
						   AND a.serie = case when SUBSTR(telefono_casa_ref2,1,2) in ('55','33','81')  then SUBSTR(telefono_casa_ref2,3,4) else SUBSTR(telefono_casa_ref2,4,3) end 
						   AND (SUBSTR(telefono_casa_ref2,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono_casa_ref2,7,4)*1)*1 <= a.numeracion_final ),'')||telefono_casa_ref2 ,		 
			telefono_celular_ref2 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono_celular_ref2 ,1,2) in ('55','33','81')  then 
									SUBSTR(telefono_celular_ref2 ,1,2) else SUBSTR(telefono_celular_ref2 ,1,3) end 
						   AND a.serie = case when SUBSTR(telefono_celular_ref2 ,1,2) in ('55','33','81')  then SUBSTR(telefono_celular_ref2 ,3,4) else SUBSTR(telefono_celular_ref2,4,3) end 
						   AND (SUBSTR(telefono_celular_ref2,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono_celular_ref2,7,4)*1)*1 <= a.numeracion_final ),'')||telefono_celular_ref2 ;
			
			
			update sd_quality_assurance 
		set tel_casa = decode(tel_casa,'','0000000000', tel_casa),
			tel_celular = decode(tel_celular,'','0000000000', tel_celular), 
			tel_trabajo = decode(tel_trabajo,'','0000000000', tel_trabajo),
			telefono_casa_ref1 = decode(telefono_casa_ref1,'','0000000000', telefono_casa_ref1),
			telefono_celular_ref1 = decode(telefono_celular_ref1,'','0000000000', telefono_celular_ref1),
			telefono_casa_ref2 = decode(telefono_casa_ref2,'','0000000000', telefono_casa_ref2),
			telefono_celular_ref2 = decode(telefono_celular_ref2,'','0000000000', telefono_celular_ref2);			
	   
	-----Creación de archivo------
    LET cnomarchivo1 =  'BanCoppelQA'||LPAD (day(dFecha),2,"0")||LPAD (MONTH(dFecha),2,"0")||year(dFecha)||'.txt';
    LET cnomarchivo =  'BanCoppelQA_'||LPAD (day(dFecha),2,"0")||LPAD (MONTH(dFecha),2,"0")||year(dFecha)||'.txt';
	--LET cnomarchivo2 =  'BanCoppelQA_'||day(dFecha)||LPAD (MONTH(dFecha),2,"0")||year(dFecha)||'.pgp';
	--se ejecuta para ponerle el encabezado
	let cSql='';
	let csql = 'echo "PRODUCTO'|| cdelimitador ||'NO_CRÉDITO'|| cdelimitador ||'NO_CLIENTE'|| cdelimitador ||'SUCURSAL_DE_APERTURA'|| cdelimitador ||'FECHA_DE_APERTURA'|| cdelimitador ||
			'FECHA_DE_ENVIO'|| cdelimitador ||'GRUPO'|| cdelimitador ||'NOMBRE_COMPLETO'|| cdelimitador ||'TEL_CASA'|| cdelimitador ||
			'TEL_CELULAR'|| cdelimitador ||'TEL_TRABAJO'|| cdelimitador ||'EXT'|| cdelimitador ||'NOMBRE_REF_1'|| cdelimitador ||
			'TELEFONO_CASA_REF_1'|| cdelimitador ||'TELEFONO_CELULAR_REF_1'|| cdelimitador ||'NOMBRE_REF2'|| cdelimitador ||'TELEFONO_CASA_REF_2'|| cdelimitador ||'TELEFONO_CELULAR_REF_2'|| cdelimitador ||
			' " >' ||TRIM(cruta)|| cnomarchivo;
	system csql;

	LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
	LET cSQL2 = ' select * from bdicred:sd_quality_assurance where fecha_envio = '''|| dFecha || ''' order by num_producto';
	LET cSQL3 = '">'||TRIM(cRuta)||'ejec_sp_gen_arch_quality_assurance.sql';
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
	System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'ejec_sp_gen_arch_quality_assurance.sql';
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'ejec_sp_gen_arch_quality_assurance.sql';
    System cSQL;

    LET cSql = cSql; 
    LET cSql = "sed 's/;$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;

	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'ejec_sp_gen_arch_quality_assurance.sql';
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;
	
	--LET cSQL = '' ;
	--LET cSQL = "pgp --encrypt -i "|| TRIM(cRuta) || TRIM(cnomarchivo) ||  " -r 'aticasiceu' --armor --output " || TRIM(cRuta) || TRIM(cnomarchivo2) ;
	--LET cSQL = "pgp --encrypt -i "|| TRIM(cRuta) || TRIM(cnomarchivo) ||  " -r 'SysRsa' --armor --output " || TRIM(cRuta) || TRIM(cnomarchivo2) ;
	--SYSTEM cSQL;
	
	CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, cMensaje, '03')
		Returning cCod_RetIB;

	RETURN cCod_ret,cMensaje;

END;
END PROCEDURE;