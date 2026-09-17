create procedure "informix".sp_contacto_vencimiento_debito()
RETURNING varchar(6), varchar(80);
---variables
DEFINE  error_info              varchar(80);
DEFINE  isam_err                integer;
DEFINE  vsqlerr                 integer;
DEFINE  vcodret                 varchar(6);
DEFINE  vcodret2                 varchar(6);
DEFINE  p_mensaje               varchar(80);
Define  vfeciniran              DATETIME YEAR TO FRACTION(5);
Define  vfecfinran              DATETIME YEAR TO FRACTION(5);
Define  vfecha_hoy              date;
Define  vfechaexp               char(4);
Define  vaniomesinicio          char(6);
Define  vaniomesfin             char(6);
Define  vsql                    char(3500);
Define  vaniomes                 char(6);
DEFINE  ultimo_dia_mes DATE;
DEFINE  primer_dia_mes DATE;
DEFINE  ultimo_dia_mes_hora DATETIME YEAR TO FRACTION(5);
DEFINE  primer_dia_mes_hora DATETIME YEAR TO FRACTION(5);
DEFINE spaso smallint;
DEFINE iTotalRegistros   integer; 
DEFINE vregistro1 smallint; DEFINE vregistro2 smallint; 
DEFINE cProceso CHAR(4);
define vvalor1  integer;
define vvalor2  integer;
define vcontador integer;
define vnumcte char(20);
define vnum_credito char(20);
define vapellido_pat char(10);
define vtarjeta char(4);
define vfechas char(6);
define vfecha date;
define viPrioridad INTEGER;
define VlDescripcion    char(50); 
define vlValorAlfabetico char(50);
define cdelimitador         CHAR(1);
define vlCDummy integer;
--SET DEBUG FILE TO "/informix/gpe/sp_contacto_vencimiento_debito.out";
--TRACE ON;
LET cProceso = '0103';
let vcodret = '0000';
let vcodret2 = '0000';
let vsqlerr = 0;
LET  p_mensaje  = '';
LET vvalor1  =0;
LET vvalor2  =0;
let vcontador = 0;
let vnumcte = '';
let vnum_credito = '';
let vapellido_pat = '';
let vtarjeta = '';
let vfechas = '';
let vfecha = date(1);
let iTotalRegistros = 0;
let viPrioridad = 0;
let VlDescripcion   = '';
let vlValorAlfabetico = '';
let cdelimitador            = "";
let vlCDummy = 0;
BEGIN
ON EXCEPTION SET vsqlerr,isam_err, error_info

   IF vsqlerr <> 0 and vsqlerr <> -958 and vsqlerr <> -206 then
                let vcodret = vsqlerr;
                let p_mensaje = error_info;
				CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, vcodret, p_mensaje, '02')
				RETURNING vcodret2;
                  RETURN vcodret, p_mensaje;
            END IF

			IF vsqlerr = -206  then			
			if error_info ='tarj_a_vencer_deb' or error_info ='informix.tarj_a_vencer_deb' then			
					select tj.numcliente, tj.numtarjeta, tc.numcuenta ,tj.titular
                    from intercard:tarjeta tj, intercard:tarjetacuenta tc 
					where (tj.numtarjeta like '400819%' or tj.numtarjeta like '416916%') and
                                        tj.fechaexp= vfechaexp AND tj.codstatustarjeta in('ACT','BTL') and
					tc.numtarjeta = tj.numtarjeta
					into temp tarj_a_vencer_deb WITH NO LOG;			
			end if
			
			if error_info ='tarj_con_transacc' or error_info ='informix.tarj_con_transacc' then			         
					select {+INDEX(intercard:movimiento idx_fechahorainauth)} distinct (numtarjeta) 
                    from intercard:movimiento 
					where (fechahorainauth BETWEEN vfecfinran  and vfeciniran) and numtarjeta in (select numtarjeta from tarj_a_vencer_deb)
					and ( (prodind='02' and formato='0200') or (prodind='01' and codtran='01')) and codigoiso='00'
					group by numtarjeta
						union all
					select {+INDEX(intercard:movimientohistorico idx_movimiento3)} distinct (numtarjeta) 
                    from intercard:movimientohistorico 
					where (fechahorainauth BETWEEN vfecfinran  and vfeciniran) and numtarjeta in (select numtarjeta from tarj_a_vencer_deb)
					and ( (prodind='02' and formato='0200') or (prodind='01' and codtran='01')) and codigoiso='00'
					group by numtarjeta
					into temp tarj_con_transacc WITH NO LOG;												
			end if
			
			if error_info ='vip_promedio_deb' or error_info ='informix.vip_promedio_deb' then				
					select cuenta from mi_may where promedio > 100000
					into temp vip_promedio_deb WITH NO LOG;				
			end if
			
			if error_info ='vip_prom_deb_tar_cu' or error_info ='informix.vip_prom_deb_tar_cu' then
					SELECT numcliente, numtarjeta,titular, numcuenta as cuenta, vfechaexp as fechaexp FROM tarj_a_vencer_deb 
					WHERE numcuenta in (SELECT * FROM vip_promedio_deb)
					into temp vip_prom_deb_tar_cu WITH NO LOG; 			
            end if	

			if error_info ='vip_promedio_debito1' or error_info ='informix.vip_promedio_debito1' then			
					  SELECT {+INDEX(bdinteg:si_direcciones_actual idx_diract_ctetpo)} 
                pdc.numcliente,vaniomes as periodo, cli.sucursal,pdc.cuenta,pdc.titular ,SUBSTR (pdc.numtarjeta,13) as n_tarjeta_ult4 ,cli.apell_paterno, cli.apell_materno, cli.nombre1,
				cli.nombre2, cpf.sexo,cpf.estado_civil,/*cpf.email,*/g.nombreciudad,h.nombre,	substr(pdc.fechaexp,3) ||'/' || substring(pdc.fechaexp FROM 1 FOR 2) as fechavenc
		   FROM bdinteg:si_cliente cli ,vip_prom_deb_tar_cu pdc, bdinteg:si_ctepf cpf, bdinteg:si_direcciones_actual da,bdinteg:si_catciudades g ,bdinteg:si_estados h
		   where cli.numcte = pdc.numcliente and   pdc.numcliente = cpf.numcte and  cpf.numcte = da.numcte and 
                da.tipo_dir ='1'and da.estado =  h.estado  and  da.ciudad =  g.numerociudad    into temp vip_promedio_debito1 WITH NO LOG;					
			end if
			
			if error_info ='vip_infinite_deb' or error_info ='informix.vip_infinite_deb' then			
					set isolation to dirty read;
					SELECT  numtarjeta, numcliente, fechaexp ,titular
                    FROM intercard:tarjeta 
					where codproductotarjeta ='502' and (numtarjeta like '400819%' or numtarjeta like '416916%') and
                                        fechaexp = vfechaexp and
					codstatustarjeta in ('ACT','BLT') and titular='T'
					into temp vip_infinite_deb  WITH NO LOG;			
			end if			

			if error_info ='cli_cue_tar' or error_info ='informix.cli_cue_tar' then			
					SELECT numcliente, numtarjeta, numcuenta,titular, vfechaexp as fechaexp 
                    FROM tarj_a_vencer_deb  WHERE numtarjeta in (SELECT * FROM tarj_con_transacc)
					into temp cli_cue_tar WITH NO LOG;		
			end if
			
			if error_info ='cli_alta_transac_deb1' or error_info ='informix.cli_alta_transac_deb1' then			
					select {+INDEX(bdinteg:si_direcciones_actual idx_diract_ctetpo)}
			cct.numcliente,vaniomes as periodo, cli.sucursal,cct.titular, cct.numcuenta, SUBSTR (cct.numtarjeta,13) as n_tarjeta_ult4, cli.apell_paterno, cli.apell_materno, cli.nombre1, cli.nombre2,
			pf.sexo,pf.estado_civil,/*pf.email,*/g.nombreciudad,h.nombre,
			substr(cct.fechaexp,3) || '/' || substring(cct.fechaexp FROM 1 FOR 2) as fechavenc
			from bdinteg:si_cliente cli, cli_cue_tar cct, bdinteg:si_ctepf pf, bdinteg:si_direcciones_actual da,
			bdinteg:si_catciudades g ,bdinteg:si_estados h
			where cli.numcte = cct.numcliente  and pf.numcte = cct.numcliente and da.numcte = cct.numcliente and da.estado =  h.estado  and 
			da.ciudad =  g.numerociudad  and da.tipo_dir ='1' into temp cli_alta_transac_deb1 WITH NO LOG;		
		end if
			
			if error_info ='vip_infinite_debito1' or error_info ='informix.vip_infinite_debito1' then			
					 select {+INDEX(bdinteg:si_direcciones_actual idx_diract_ctetpo)}
			    vid.numcliente,vaniomes as periodo, cli.sucursal,tc.numcuenta, vid.titular,SUBSTR (vid.numtarjeta,13) as n_tarjeta_ult4, cli.apell_paterno, cli.apell_materno, cli.nombre1, cli.nombre2, 
				pf.sexo, pf.estado_civil,/*pf.email,*/g.nombreciudad,h.nombre,
				substr(vid.fechaexp,3) || '/' || substring(vid.fechaexp FROM 1 FOR 2) as fechavenc
		   from bdinteg:si_cliente cli, bdinteg:si_ctepf pf, bdinteg:si_direcciones_actual da, vip_infinite_deb vid, intercard:tarjetacuenta tc,
		   bdinteg:si_catciudades g ,bdinteg:si_estados h
		   where cli.numcte = vid.numcliente and  cli.numcte = pf.numcte and cli.numcte = da.numcte and  da.tipo_dir ='1' and
			    tc.numtarjeta =vid.numtarjeta AND	da.estado =  h.estado  and 	da.ciudad =  g.numerociudad   into temp vip_infinite_debito1  WITH NO LOG;							
			end if
			END IF			
			
			IF vsqlerr = -958  then			
	            if error_info ='informix.tarj_a_vencer_deb' or error_info ='tarj_a_vencer_deb' then
					drop table tarj_a_vencer_deb;
				   end if			

	            if error_info ='informix.tarj_con_transacc' or error_info ='tarj_con_transacc' then
					drop table tarj_con_transacc;
				end if
			   
                if error_info ='informix.vip_promedio_deb' or error_info ='vip_promedio_deb' then
				    drop table vip_promedio_deb;					  
				end if

				if error_info ='informix.vip_prom_deb_tar_cu' or error_info ='vip_prom_deb_tar_cu' then
				    drop table vip_prom_deb_tar_cu;
				end if
				   
				if error_info ='informix.vip_promedio_debito1' or error_info ='vip_promedio_debito1' then
				    drop table vip_promedio_debito1;
				end if
				  
				if error_info ='informix.vip_infinite_deb' or error_info ='vip_infinite_deb' then
				   drop table vip_infinite_deb;
				end if

				if error_info ='informix.cli_cue_tar' or error_info ='cli_cue_tar' then
				   drop table cli_cue_tar;
				end if
				   
				if error_info ='informix.cli_alta_transac_deb1' or error_info ='cli_alta_transac_deb1' then
				   drop table cli_alta_transac_deb1;
				end if
                  
				if error_info ='informix.vip_infinite_debito1' or error_info ='vip_infinite_debito1' then
				   drop table vip_infinite_debito1;
				end if				  
			END IF
 END EXCEPTION WITH RESUME;	 
 
 CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, vcodret, p_mensaje, '01')
				RETURNING vcodret2;
 let vregistro1 = 0; let vregistro2 = 0; 
 let spaso = 0;
 
 SELECT TRIM(valor_alfabetico) 
	INTO cdelimitador 
	FROM bdicred:"informix".sd_param_campania 
	WHERE empresa = '001'
    AND tipo_campania = 61 
	AND grupo_parametro = 'ARCHIVOSEP' 
	AND num_parametro = 336;
	
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'sd_temp_vencimiento_debito';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE sd_temp_vencimiento_debito;
            END IF;
			
	CREATE TABLE sd_temp_vencimiento_debito
	( tipoprom      CHAR(3),    tipologica    	SMALLINT, 
	fecha         	DATE, 		cuenta	VARCHAR(20),
    sucursal      	CHAR(4),  	numcte        	CHAR(20),   
    n_tarjeta_ult4	VARCHAR(4), status        	SMALLINT,
    prioridad     	SMALLINT, 	apell_paterno 	CHAR(26),
    apell_materno 	CHAR(26),   nombre1       	CHAR(26),
    nombre2       	CHAR(26),   sexo          	CHAR(1),
	estado_civil  	CHAR(2),    correo        	CHAR(60),  
	estado        	CHAR(30),   municipio     	CHAR(30), 
	fechavenc     	VARCHAR(6), 
    tipo_tarjeta  	CHAR(5), 	tipo_telef1   	CHAR(1),
    tipo_telef2   	CHAR(1),    tipo_telef3   	CHAR(1), 
    tipored1      	CHAR(1),    tipored2      	CHAR(1) ,  
	telefono1     	CHAR(13),   telefono2     	CHAR(13), telefono3     CHAR(13),
    telefono4     	CHAR(13),   extension     	CHAR(5));
	
	--se crea tabla para guardar prioridad
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'temp_vip_alta_deb';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE temp_vip_alta_deb;
            END IF;
			
	CREATE TABLE temp_vip_alta_deb
	( tipoprom      CHAR(3),    tipologica    	SMALLINT, 
	  numero_credito VARCHAR(20), numcte        CHAR(20),   
    prioridad     	smallint,--serial, 	  
	nombre       	CHAR(150),
    sexo          	CHAR(1),      estado_civil  	CHAR(2),    
	correo        	CHAR(60),     estado        	CHAR(30),   
	fechavenc     	VARCHAR(6),   tipo_tarjeta  	CHAR(5), 	
	telefono1     	CHAR(13), telefono2     	CHAR(13),  
	telefono3     	CHAR(13),   telefono4     	CHAR(13),
	extension     	CHAR(5));
	
	select valor_numerico into vregistro1
		from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro= 55;
	select valor_numerico into vregistro2
		from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro= 56;
	
set isolation to dirty read;
select fecha_hoy into vfecha_hoy from bdinteg:si_fechas; --LET vfecha_hoy = '09012012';

--OBTIENE EL ULTIMO DIA DEL MES PARA 90 DIAS ANTERIORES	  
     LET ultimo_dia_mes = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
     LET ultimo_dia_mes_hora = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
     LET ultimo_dia_mes_hora = SUBSTRING(ultimo_dia_mes_hora FROM 1 FOR 10) || ' 23:59:59';
     --OBTIENE EL PRIMER DIA DEL MES PARA 90 DIAS ANTERIORES
     LET primer_dia_mes = extend(extend(vfecha_hoy - 3 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
     LET primer_dia_mes_hora = extend(extend(vfecha_hoy - 3 units MONTH ,YEAR TO MONTH)||"-01",YEAR TO DAY);
     LET primer_dia_mes_hora= SUBSTRING(primer_dia_mes_hora FROM 1 FOR 10) || ' 00:00:00';
   
     LET vfeciniran = ultimo_dia_mes_hora;	
     LET vfecfinran = primer_dia_mes_hora;	
     
     --OBTIENE FECHA DE EXPIRACION
     LET vfechaexp =   LPAD (substr(year(date(vfecha_hoy) + 60 ),3),2,"0") || LPAD (MONTH(date(vfecha_hoy) + 60 ),2,"0");   
     --OBTIENE EL AÑO Y MES DE LA FECHA	  
     LET vaniomes =  '20' || TRIM(vfechaexp);

 ----validamos si no se ha ejecutado con anterioridad.
 if ((not exists (select {+INDEX(intercard:vencimiento_debito_vip idx_debito_vip)} * 
                         from intercard:vencimiento_debito_vip where periodo = vaniomes)) and
     (not exists (select {+INDEX(intercard:vencimiento_debito_altransac idx_debito_altransac)} * 
                         from intercard:vencimiento_debito_altransac where periodo = vaniomes))) then
  
    let vaniomesinicio = year(ultimo_dia_mes) || LPAD (MONTH(ultimo_dia_mes),2,"0");
	let vaniomesfin    = year(primer_dia_mes) || LPAD (MONTH(primer_dia_mes),2,"0");
   
    if exists( select * from systables where tabname ='mi_may') then
       drop table mi_may;
    end if  

	CREATE TABLE mi_may ( 
	cuenta  	char(20) NOT NULL,
	promedio	decimal(30,2) 
	)EXTENT SIZE 111328 NEXT SIZE 11136 LOCK MODE ROW;

	
---tarjetas con peraciones de compra y retiros en el rango 

   --1)Obtiene tarjetas a expirar en la fecha indicada
        set isolation to dirty read;
		select tj.numcliente, tj.numtarjeta, tc.numcuenta ,tj.titular
        from intercard:tarjeta tj, intercard:tarjetacuenta tc 
		where (tj.numtarjeta like '400819%' or tj.numtarjeta like '416916%') and 
              tj.fechaexp=  vfechaexp and --'1201'
              tj.codstatustarjeta in('ACT','BLT') and
		      tc.numtarjeta = tj.numtarjeta
        into temp tarj_a_vencer_deb WITH NO LOG;
      
   --2)Obtiene tarjetas a expirar con movimientos de 90 días anteriores (Julio/Agosto/Septiembre)
   --tarjetas con movimiento
          set isolation to dirty read;
		  select {+INDEX(intercard:movimiento idx_fechahorainauth)} 
              distinct (numtarjeta) from intercard:movimiento 
	      where (fechahorainauth BETWEEN vfecfinran  and vfeciniran) and --'2011-07-01 00:00:00.0' and '2011-09-30 23:59:59.9'
                numtarjeta in (select numtarjeta from tarj_a_vencer_deb) and
	            ((prodind = '02' and formato = '0200') or (prodind = '01' and codtran = '01')) and 
                codigoiso='00'
		 group by numtarjeta         
			union all         
		  select {+INDEX(intercard:movimientohistorico idx_movimiento1)} 
              distinct (numtarjeta) from intercard:movimientohistorico 
		  where (fechahorainauth BETWEEN vfecfinran  and vfeciniran) and --'2011-07-01 00:00:00.0' and '2011-09-30 23:59:59.9'
                 numtarjeta in (select numtarjeta from tarj_a_vencer_deb) and 
		        ((prodind = '02' and formato = '0200') or (prodind = '01' and codtran = '01')) and 
               codigoiso='00'
	      group by numtarjeta
	      into temp tarj_con_transacc WITH NO LOG;	


   --3)Obtiene Clientes con Alta transaccionalidad
            set isolation to dirty read;
		    SELECT  numcliente, numtarjeta, numcuenta, titular, vfechaexp as fechaexp --'1201'
              FROM tarj_a_vencer_deb  
              WHERE numtarjeta in (SELECT * FROM tarj_con_transacc)
            into temp cli_cue_tar WITH NO LOG;
		   
            set isolation to dirty read;
		   	select {+INDEX(bdinteg:si_direcciones_actual idx_diract_ctetpo)}
			cct.numcliente,vaniomes as periodo, cli.sucursal,cct.titular, cct.numcuenta, SUBSTR (cct.numtarjeta,13) as n_tarjeta_ult4, cli.apell_paterno, cli.apell_materno, cli.nombre1, cli.nombre2,
			pf.sexo,pf.estado_civil,/*pf.email,*/g.nombreciudad,h.nombre,
			substr(cct.fechaexp,3) || '/' || substring(cct.fechaexp FROM 1 FOR 2) as fechavenc
			from bdinteg:si_cliente cli, cli_cue_tar cct, bdinteg:si_ctepf pf, bdinteg:si_direcciones_actual da,
			bdinteg:si_catciudades g ,bdinteg:si_estados h
			where cli.numcte = cct.numcliente  and 
                pf.numcte = cct.numcliente and 
                da.numcte = cct.numcliente and 
				da.estado =  h.estado  and 
				da.ciudad =  g.numerociudad  and
				da.tipo_dir ='1' 
			into temp cli_alta_transac_deb1 WITH NO LOG;
			
			select a.numcliente,a.periodo, a.sucursal,a.titular, a.numcuenta, a.n_tarjeta_ult4, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2,
			a.sexo,a.estado_civil,b.correo_elec email,a.nombreciudad,a.nombre,a.fechavenc
			from  cli_alta_transac_deb1 a  
			left join bdinteg:si_correos  b  on (a.numcliente = b.numcte and b.secuencia = (select max(secuencia) from bdinteg:si_correos 
																							   where numcte = a.numcliente and status_correo = 'A')
													and b.status_correo = 'A')
			into temp cli_alta_transac_deb WITH NO LOG;
 	
-------------------------------------------------------------------------				

   --4)Obtiene Clientes VIP
   --clientes con saldo promedio mayor a 100,000
             
            set isolation to dirty read;		        
            insert into mi_may (cuenta, promedio)
	    select {+INDEX(bdicheq:sc_sdodiarioc isdodiario)} 
                   cuenta as cuenta, round (sum((capvigacum / diacum))/3,2) as promedio 
			from bdicheq:sc_sdodiarioc 
            where cuenta in (SELECT numcuenta FROM tarj_a_vencer_deb) and
                 (aniomes between vaniomesfin and vaniomesinicio) and --'201107' and '201109'
				 cuenta not like '2300%' and cuenta not like '1100%' and
			     diacum <> '0'
			group by cuenta;
	    set isolation to dirty read;		        
            insert into mi_may (cuenta, promedio)
            select {+INDEX(bdicheq:sc_sdodiarioc_2011 isdodiario_2011)} 
                   cuenta as cuenta, round (sum((capvigacum / diacum))/3,2) as promedio 
			from bdicheq:sc_sdodiarioc_2011 
            where cuenta in (SELECT numcuenta FROM tarj_a_vencer_deb) and
                (aniomes between vaniomesfin and vaniomesinicio) and --'201107' and '201109'
				 cuenta not like '2300%' and cuenta not like '1100%' and
			     diacum <> '0'
	    group by cuenta;
            
            set isolation to dirty read;  
            select cuenta 
            from mi_may 
            where promedio > 100000
			into temp vip_promedio_deb WITH NO LOG;

           set isolation to dirty read;  
           SELECT numcliente, numtarjeta,titular, numcuenta as cuenta, vfechaexp as fechaexp --'1201'
           FROM tarj_a_vencer_deb 
		   WHERE numcuenta in (SELECT * FROM vip_promedio_deb)
		   into temp vip_prom_deb_tar_cu WITH NO LOG; 

           set isolation to dirty read;  
           SELECT {+INDEX(bdinteg:si_direcciones_actual idx_diract_ctetpo)} 
                pdc.numcliente,vaniomes as periodo, cli.sucursal,pdc.cuenta,pdc.titular ,SUBSTR (pdc.numtarjeta,13) as n_tarjeta_ult4 ,cli.apell_paterno, cli.apell_materno, cli.nombre1,
				cli.nombre2, cpf.sexo,cpf.estado_civil,/*cpf.email,*/g.nombreciudad,h.nombre,
				substr(pdc.fechaexp,3) ||'/' || substring(pdc.fechaexp FROM 1 FOR 2) as fechavenc
		   FROM bdinteg:si_cliente cli ,vip_prom_deb_tar_cu pdc, bdinteg:si_ctepf cpf, bdinteg:si_direcciones_actual da,
				bdinteg:si_catciudades g ,bdinteg:si_estados h
		   where cli.numcte = pdc.numcliente and 
                pdc.numcliente = cpf.numcte and 
                cpf.numcte = da.numcte and 
                da.tipo_dir ='1'and
				da.estado =  h.estado  and 
				da.ciudad =  g.numerociudad  
		   into temp vip_promedio_debito1 WITH NO LOG;
		   
		   	select  a.numcliente,a.periodo, a.sucursal,a.cuenta,a.titular ,a.n_tarjeta_ult4 ,a.apell_paterno, a.apell_materno, a.nombre1,
				a.nombre2, a.sexo,a.estado_civil, b.correo_elec email,a.nombreciudad,a.nombre,a.fechavenc
			from  vip_promedio_debito1 a  
			left join bdinteg:si_correos  b  on (a.numcliente = b.numcte and b.secuencia = (select max(secuencia) from bdinteg:si_correos 
																							   where numcte = a.numcliente and status_correo = 'A')
													and b.status_correo = 'A')
			into temp vip_promedio_debito WITH NO LOG;
	  				
          --clientes del segmento infinite
		   set isolation to dirty read;
		   SELECT  numtarjeta, numcliente, fechaexp , titular
           FROM intercard:tarjeta 
		   where codproductotarjeta ='502' and 
                 (numtarjeta like '400819%' or numtarjeta like '416916%')and 
                 fechaexp = vfechaexp and --'1201'
			     codstatustarjeta in ('ACT','BLT') and 
                 titular='T'
		   into temp vip_infinite_deb  WITH NO LOG;

           set isolation to dirty read;
           select {+INDEX(bdinteg:si_direcciones_actual idx_diract_ctetpo)}
			    vid.numcliente,vaniomes as periodo, cli.sucursal,tc.numcuenta, vid.titular,SUBSTR (vid.numtarjeta,13) as n_tarjeta_ult4, cli.apell_paterno, cli.apell_materno, cli.nombre1, cli.nombre2, 
				pf.sexo, pf.estado_civil,/*pf.email,*/g.nombreciudad,h.nombre,
				substr(vid.fechaexp,3) || '/' || substring(vid.fechaexp FROM 1 FOR 2) as fechavenc
		   from bdinteg:si_cliente cli, bdinteg:si_ctepf pf, bdinteg:si_direcciones_actual da, vip_infinite_deb vid, intercard:tarjetacuenta tc,
		   bdinteg:si_catciudades g ,bdinteg:si_estados h
		   where cli.numcte = vid.numcliente and
                cli.numcte = pf.numcte and 
                cli.numcte = da.numcte and 
                da.tipo_dir ='1' and
			    tc.numtarjeta =vid.numtarjeta AND
				da.estado =  h.estado  and 
				da.ciudad =  g.numerociudad 
		   into temp vip_infinite_debito1  WITH NO LOG;
		   
		   select   a.numcliente,a.periodo, a.sucursal,a.numcuenta, a.titular,a.n_tarjeta_ult4, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, 
				a.sexo, a.estado_civil,b.correo_elec email,a.nombreciudad,a.nombre,a.fechavenc
			from  vip_infinite_debito1 a  
			left join bdinteg:si_correos  b  on (a.numcliente = b.numcte and b.secuencia = (select max(secuencia) from bdinteg:si_correos 
																							   where numcte = a.numcliente and status_correo = 'A')
													and b.status_correo = 'A')
			into temp vip_infinite_debito WITH NO LOG;
		   
		   
--5)Unión de tablas temporales para generar archivo

			INSERT INTO vencimiento_debito_vip (periodo, sucursal, cuenta, n_tarjeta_ult4, apell_paterno, apell_materno, nombre1, nombre2, sexo,
			            telefono1 , telefono2 ,  telefono3 , telefono4 ,  extension , fechaexp,
						tipoprom,tipologica,fecha,numcte,status,prioridad,estado_civil,correo,estado,municipio,
						tipo_tarjeta,tipo_telef1,tipo_telef2,tipo_telef3,tipored1,tipored2 )
			select periodo,sucursal,cuenta,n_tarjeta_ult4,apell_paterno, apell_materno, nombre1,nombre2,sexo, 
						tel1.telefono , tel2.telefono , tel3.telefono , tel4.telefono , tel3.extension,fechavenc,
						'RVI',5,vfecha_hoy,numcliente,0,
					case when tel1.telefono <> '' and nvl(tel2.telefono,'') = '' and nvl(tel3.telefono,'') = '' then 1
					when tel3.telefono <> '' and nvl(tel2.telefono,'') = '' and nvl(tel1.telefono,'') = '' then 2
					when tel1.telefono <> '' and tel3.telefono <> '' and nvl(tel2.telefono,'') = '' then 3
					when tel1.telefono <> '' or tel2.telefono <> '' or tel3.telefono <> '' then 4 end prioridad,
					estado_civil,email,nombre,nombreciudad,
						titular,'1','2','3','F','M'
			from vip_promedio_debito cred
			left join bdinteg:si_telefonos_actual tel1 on (tel1.empresa = '001' and tel1.numcte= cred.numcliente and tel1.tipo_tel = 1 and tel1.cofetel ='V'
                            and tel1.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = cred.numcliente and tipo_tel = 1 and cofetel ='V'))
			left join bdinteg:si_telefonos_actual tel2 on (tel2.empresa = '001' and tel2.numcte= cred.numcliente and tel2.tipo_tel = 2 and tel2.cofetel ='V'
                            and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = cred.numcliente and tipo_tel = 2 and cofetel ='V'))
			left join bdinteg:si_telefonos_actual tel3 on (tel3.empresa = '001' and tel3.numcte= cred.numcliente and tel3.tipo_tel = 3 and tel3.cofetel ='V'
                            and tel3.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = cred.numcliente and tipo_tel = 3 and cofetel ='V'))
			left join bdinteg:si_telefonos_actual tel4 on (tel4.empresa = '001' and tel4.numcte= cred.numcliente and tel4.tipo_tel = 4 and tel4.cofetel ='V'
                            and tel4.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = cred.numcliente and tipo_tel = 4 and cofetel ='V'));
	  			
            set isolation to dirty read;
			INSERT INTO vencimiento_debito_vip (periodo, sucursal, cuenta, n_tarjeta_ult4, apell_paterno, apell_materno, nombre1, nombre2, sexo,
			            telefono1, telefono2, telefono3, telefono4, extension,fechaexp,
						tipoprom,tipologica,fecha,numcte,status,prioridad,estado_civil,correo,estado,municipio,
						tipo_tarjeta,tipo_telef1,tipo_telef2,tipo_telef3,tipored1,tipored2 )
			select periodo,sucursal,numcuenta,n_tarjeta_ult4,apell_paterno, apell_materno, nombre1,nombre2,sexo, 
						tel1.telefono , tel2.telefono , tel3.telefono , tel4.telefono , tel3.extension,fechavenc ,
					'RVI',5,vfecha_hoy,numcliente,0,
					case when tel1.telefono <> '' and nvl(tel2.telefono,'') = '' and nvl(tel3.telefono,'') = '' then 1
					when tel3.telefono <> '' and nvl(tel2.telefono,'') = '' and nvl(tel1.telefono,'') = '' then 2
					when tel1.telefono <> '' and tel3.telefono <> '' and nvl(tel2.telefono,'') = '' then 3
					when tel1.telefono <> '' or tel2.telefono <> '' or tel3.telefono <> '' then 4 end prioridad,
					estado_civil,email,nombre,nombreciudad,titular,'1','2','3','F','M'	
			from vip_infinite_debito cred
			left join bdinteg:si_telefonos_actual tel1  on (tel1.empresa = '001' and tel1.numcte= cred.numcliente and tel1.tipo_tel = 1 and tel1.cofetel ='V'
                            and tel1.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = cred.numcliente and tipo_tel = 1 and cofetel ='V'))
			left join bdinteg:si_telefonos_actual tel2  on (tel2.empresa = '001' and tel2.numcte= cred.numcliente and tel2.tipo_tel = 2 and tel2.cofetel ='V'
                            and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = cred.numcliente and tipo_tel = 2 and cofetel ='V'))
			left join bdinteg:si_telefonos_actual tel3  on (tel3.empresa = '001' and tel3.numcte= cred.numcliente and tel3.tipo_tel = 3 and tel3.cofetel ='V'
                            and tel3.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = cred.numcliente and tipo_tel = 3 and cofetel ='V'))
			left join bdinteg:si_telefonos_actual tel4 on (tel4.empresa = '001' and tel4.numcte= cred.numcliente and tel4.tipo_tel = 4 and tel4.cofetel ='V'
                            and tel4.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = cred.numcliente and tipo_tel = 4 and cofetel ='V'));

			
			set isolation to dirty read;
			INSERT INTO vencimiento_debito_altransac (periodo, sucursal, cuenta, n_tarjeta_ult4, apell_paterno, apell_materno, nombre1, nombre2, sexo,
			            telefono1, telefono2, telefono3, telefono4, extension, fechaexp,
						tipoprom,tipologica,fecha,numcte,status,prioridad,estado_civil,correo,estado,municipio,
						tipo_tarjeta,tipo_telef1,tipo_telef2,tipo_telef3,tipored1,tipored2 )
			select periodo,sucursal,numcuenta,n_tarjeta_ult4,apell_paterno, apell_materno, nombre1,nombre2,sexo, 
						tel1.telefono , tel2.telefono , tel3.telefono , tel4.telefono , tel3.extension,fechavenc ,
					'RTX',6,vfecha_hoy,numcliente,0, 
				case when tel1.telefono <> '' and nvl(tel2.telefono,'') = '' and nvl(tel3.telefono,'') = '' then 1
				when tel3.telefono <> '' and nvl(tel2.telefono,'') = '' and nvl(tel1.telefono,'') = '' then 2
				when tel1.telefono <> '' and tel3.telefono <> '' and nvl(tel2.telefono,'') = '' then 3
				when tel1.telefono <> '' or tel2.telefono <> '' or tel3.telefono <> '' then 4 end prioridad,
				estado_civil,email,nombre,nombreciudad,
						titular,'1','2','3','F','M'	
			from cli_alta_transac_deb cred
			left join bdinteg:si_telefonos_actual tel1 on (tel1.empresa = '001' and tel1.numcte= cred.numcliente and tel1.tipo_tel = 1 and tel1.cofetel ='V'
                            and tel1.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = cred.numcliente and tipo_tel = 1 and cofetel ='V'))
			left join bdinteg:si_telefonos_actual tel2 on (tel2.empresa = '001' and tel2.numcte= cred.numcliente and tel2.tipo_tel = 2 and tel2.cofetel ='V'
                            and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = cred.numcliente and tipo_tel = 2 and cofetel ='V'))
			left join bdinteg:si_telefonos_actual tel3 on (tel3.empresa = '001' and tel3.numcte= cred.numcliente and tel3.tipo_tel = 3 and tel3.cofetel ='V'
                            and tel3.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = cred.numcliente and tipo_tel = 3 and cofetel ='V'))
			left join bdinteg:si_telefonos_actual tel4 on (tel4.empresa = '001' and tel4.numcte= cred.numcliente and tel4.tipo_tel = 4 and tel4.cofetel ='V'
                            and tel4.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = cred.numcliente and tipo_tel = 4 and cofetel ='V'));
			
			--elimina duplicados
			delete  from intercard:vencimiento_debito_altransac where cuenta in (select cuenta
			from intercard:vencimiento_debito_vip
			where  periodo=vaniomes) and periodo = vaniomes and tipologica = 6;
----------------------------------------------------------------------------------------------------------------------------			 
			
			select a.tipoprom,a.tipologica,trim(a.cuenta) as cuenta,a.numcte,0 as prioridad,trim(a.apell_paterno)||' '||trim(a.apell_materno)||' '||trim(a.nombre1)||' '||trim(a.nombre2) as nombre, 
			a.sexo,a.estado_civil,a.correo,a.estado,a.fechaexp,a.tipo_tarjeta,
			a.telefono1,a.telefono2,a.telefono3,a.telefono4, a.extension
			from vencimiento_debito_vip a where a.tipologica = 5 and  a.periodo = vaniomes 
            union all
			select b.tipoprom,b.tipologica,trim(b.cuenta) as cuenta,b.numcte,0 as prioridad,trim(b.apell_paterno)||' '||trim(b.apell_materno)||' '||trim(b.nombre1)||' '||trim(b.nombre2) as nombre, 
			b.sexo,b.estado_civil,b.correo,b.estado,b.fechaexp,b.tipo_tarjeta,
			b.telefono1,b.telefono2,b.telefono3,b.telefono4, b.extension
			from vencimiento_debito_altransac b where tipologica = 6 and  periodo = vaniomes
			order by tipologica
			into temp ip_altatcdeb with no log;
			
-- Actualiza el orden de prioridad de acuerdo a la fecha de vigencia de la solicitud			
			INSERT INTO temp_vip_alta_deb
			SELECT * FROM ip_altatcdeb;
			
			update temp_vip_alta_deb 
		  set telefono4 = nvl(substr(telefono4,length(telefono4)-9,10),''),
			telefono1 = nvl(substr(telefono1,length(telefono1)-9,10),''), 
			telefono2 = nvl(substr(telefono2,length(telefono2)-9,10),''),
			telefono3 = nvl(substr(telefono3,length(telefono3)-9,10),'');
			   --Elimina
			delete from temp_vip_alta_deb where nvl(telefono1,'') ='' and nvl(telefono2,'')='' and nvl(telefono3,'')='' 
		  and nvl(telefono4,'')='';

			update temp_vip_alta_deb set telefono2 = ''
			where nvl(telefono1,'')= nvl(telefono2,'');

			update temp_vip_alta_deb set telefono3 = ''
			where nvl(telefono3,'')= nvl(telefono2,'') or nvl(telefono3,'')= nvl(telefono1,'');

			update temp_vip_alta_deb set telefono4 = ''
			where nvl(telefono1,'')= nvl(telefono4,'') or nvl(telefono2,'')= nvl(telefono4,'') or nvl(telefono3,'')= nvl(telefono4,''); 
			
update temp_vip_alta_deb 
		set telefono4 = nvl(telefono4,'') ,
			telefono1 = nvl(telefono1,''), 
			telefono2 = nvl(telefono2,''),
			telefono3 = nvl(telefono3,''); 
			
	update temp_vip_alta_deb 
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
			
		update temp_vip_alta_deb 
		set telefono4 = decode(telefono4,'',null, telefono4),
			telefono1 = decode(telefono1,'',null, telefono1), 
			telefono2 = decode(telefono2,'',null, telefono2),
			telefono3 = decode(telefono3,'',null, telefono3);					
			
			LET viPrioridad = 1;
		
		FOREACH
			SELECT numcte, numero_credito INTO vnumcte, vnum_credito 
			FROM intercard:"informix".temp_vip_alta_deb

			UPDATE intercard:"informix".temp_vip_alta_deb SET prioridad = viPrioridad 
            WHERE numcte = vnumcte AND numero_credito = vnum_credito;
			 
        LET viPrioridad = viPrioridad + 1;
		END FOREACH;
			
			SELECT count(*) INTO iTotalRegistros FROM temp_vip_alta_deb;
			
			INSERT INTO bdicred:sd_totalcte_campania(empresa, fecha_insert, tipocampania, total)
			VALUES('001', vfecha_hoy , 'VENC_DEBITO', iTotalRegistros);

			 -- vip debito
		    let vsql = ' echo "Tipo_Promocion'|| cdelimitador ||'Tipo_Logica'|| cdelimitador ||'Num_Credito'|| cdelimitador ||'Numcte'|| cdelimitador ||
			'Prioridad'|| cdelimitador ||'Nombre'|| cdelimitador ||'Sexo'|| cdelimitador ||'Estado_Civil'|| cdelimitador ||'Correo'|| cdelimitador ||
			'Estado'|| cdelimitador ||'Fecha_venc'|| cdelimitador ||'Tipo_tarjeta'|| cdelimitador ||'Tel_const_tipo_1'|| cdelimitador ||
			'Tel_const_tipo_2'|| cdelimitador ||'Tel_const_tipo_3'|| cdelimitador ||'Tel_const_tipo_4'|| cdelimitador ||
			'Extension'|| cdelimitador ||'">/resplogifx/VencDeb_VIP_ALTA_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.txt';
			system vsql; 							
            let vsql = '';
			--let vsql = '';
			LET vsql = 'echo "UNLOAD TO ' || '''/resplogifx/vip_debito.unl''' || ' DELIMITER ' || ''''|| cdelimitador || ''''||
              ' select tipoprom,tipologica,numero_credito,numcte,prioridad,nombre,sexo,estado_civil,correo,estado, '||
			 ' fechavenc,tipo_tarjeta,'||			 
			' telefono1,telefono2,telefono3,telefono4,extension  '||
			' from temp_vip_alta_deb '||
			' order by prioridad ;'||
			 '" > /resplogifx/vip_debito.sql'; 
			system vsql;
			let vsql = '';
			let vsql= 'dbaccess intercard  /resplogifx/vip_debito.sql';
			system vsql;
			let vsql ='';
			let vsql ='rm  /resplogifx/vip_debito.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/vip_debito.unl >>/resplogifx/VencDeb_VIP_ALTA_"||day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".txt";
			system vsql;
			let vsql ='rm  /resplogifx/vip_debito.unl';
			system vsql;             		
			/*--------------------------------------ARCHIVO TELEFONOS

	
	LET vsql = '';
	let vsql = ' echo "Numero Credito|Numero Cliente|Tipo Telefono|Tipo Red|Telefono Original|Telefono Construido|Carrier|Extension|">/resplogifx/VencDebVip_TEL_total_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.txt';
	system vsql;			
	let vsql = '';
	LET vsql = 'echo "UNLOAD TO ' || '''/resplogifx/vip_transacc_debito.unl''' || ' DELIMITER ' || '''|'''|| 
	     ' select  cuenta,numcte, tipo_telef1, tipored1 ,telefono1 ,telefono1 , 0 , '|| " '0' "  ||
			' from vencimiento_debito_vip	WHERE telefono1 <>  '||" '' " ||
				' and tipologica = 5 and  periodo = ' || vaniomes || 
		' UNION '|| 
			' select  cuenta,numcte, tipo_telef2, tipored2 ,telefono2 ,telefono2 , 0 , '||" '0' "  ||
			' from	vencimiento_debito_vip	WHERE telefono2 <> '||" '' "  ||
		 		' and tipologica = 5 and  periodo = ' || vaniomes || 
		' UNION ' || 
			' select  cuenta,numcte,tipo_telef3, tipored1 ,telefono3 ,telefono3 , 0 , extension '||
			' from vencimiento_debito_vip	WHERE telefono3 <>  '||" '' "  ||
				' and tipologica = 5 and  periodo = ' || vaniomes || 
	' " > /resplogifx/vip_transacc_debito.sql';
	system vsql;
	let vsql = '';
	let vsql= 'dbaccess intercard  /resplogifx/vip_transacc_debito.sql';
	system vsql;
	let vsql ='';
	let vsql ='rm  /resplogifx/vip_transacc_debito.sql';
	system vsql;
	let vsql ='';
	let vsql = "sed 's/|$//g' /resplogifx/vip_transacc_debito.unl >>/resplogifx/VencDebVip_TEL_total_"|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".txt";
	system vsql;
	let vsql ='rm  /resplogifx/vip_transacc_debito.unl';
	system vsql; */

	------------------------------------------------------		
		   /* --alta transaccionalidad debito
		    let vsql = ' echo "Tipo Promocion|Tipo Logica|Fecha|Num Credito|Sucursal|Numcte|Ult_4dig|Status |Prioridad|Apell_p|Apell_m|Nombre1|Nombre2|Sexo|Estado_Civil|Correo|Estado|Municipio|Num_credito|Numcte|Fecha_venc|Num_cuenta|Tipo_tarjeta|">/resplogifx/VencDebAlta_total_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.txt';
			system vsql; 							
            let vsql = '';
			let vsql = '';
			LET vsql = 'echo "UNLOAD TO ' || '''/resplogifx/Alta_transacc_debito.unl''' || ' DELIMITER ' || '''|'''|| 
             ' select tipoprom,tipologica,fecha,cuenta,sucursal,numcte,n_tarjeta_ult4,status,prioridad,apell_paterno, apell_materno, nombre1, nombre2, '|| 
			 ' sexo,estado_civil,correo,estado,municipio,cuenta,numcte,fechaexp,cuenta,tipo_tarjeta'||
			 ' from vencimiento_debito_altransac where tipologica = 6 and  periodo = ' || vaniomes || '; '||
             ' " > /resplogifx/Alta_transacc_debito.sql';
			system vsql;
			let vsql = '';
			let vsql= 'dbaccess intercard  /resplogifx/Alta_transacc_debito.sql';
			system vsql;
			let vsql ='';
			let vsql ='rm  /resplogifx/Alta_transacc_debito.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/Alta_transacc_debito.unl >>/resplogifx/VencDebAlta_total_"||day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".txt";
			system vsql;
			let vsql ='rm  /resplogifx/Alta_transacc_debito.unl';
			system vsql;     */

  		  
		/*--------------------------------------ARCHIVO TELEFONOS

	
	LET vsql = '';
	let vsql = ' echo "Numero Credito|Numero Cliente|Tipo Telefono|Tipo Red|Telefono Original|Telefono Construido|Carrier|Extension|">/resplogifx/VencDebAlta_TEL_total_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.txt';
	system vsql;			
	let vsql = '';
	LET vsql = 'echo "UNLOAD TO ' || '''/resplogifx/Alta_transacc_debito.unl''' || ' DELIMITER ' || '''|'''|| 
		    ' select  cuenta,numcte, tipo_telef1, tipored1 ,telefono1 ,telefono1 , 0 , '|| " '0' "  ||
			' from vencimiento_debito_altransac	WHERE telefono1 <>  '||" '' " ||
				' and tipologica = 6 and  periodo = ' || vaniomes || 
		' UNION '|| 
			' select  cuenta,numcte, tipo_telef2, tipored2 ,telefono2 ,telefono2 , 0 , '||" '0' "  ||
			' from	vencimiento_debito_altransac	WHERE telefono2 <> '||" '' "  ||
		 		' and tipologica = 6 and  periodo = ' || vaniomes || 
		' UNION ' || 
			' select  cuenta,numcte,tipo_telef3, tipored1 ,telefono3 ,telefono3 , 0 , extension '||
			' from vencimiento_debito_altransac	WHERE telefono3 <>  '||" '' "  ||
				' and tipologica = 6 and  periodo = ' || vaniomes || 
	' " > /resplogifx/Alta_transacc_debito.sql';
	system vsql;
	let vsql = '';
	let vsql= 'dbaccess intercard  /resplogifx/Alta_transacc_debito.sql';
	system vsql;
	let vsql ='';
	let vsql ='rm  /resplogifx/Alta_transacc_debito.sql';
	system vsql;
	let vsql ='';
	let vsql = "sed 's/|$//g' /resplogifx/Alta_transacc_debito.unl >>/resplogifx/VencDebAlta_TEL_total_"|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".txt";
	system vsql;
	let vsql ='rm  /resplogifx/Alta_transacc_debito.unl';
	system vsql; */
	drop table temp_vip_alta_deb;

------------------------------------------------------------------------------------------------------------
------------------------------------------ARCHIVOS CON LIMIT------------------------------------------------
  /*
	set isolation to dirty read;
    INSERT INTO sd_temp_vencimiento_debito 
	select limit vregistro1
	tipoprom,tipologica ,fecha,cuenta,sucursal,numcte,n_tarjeta_ult4,status,prioridad,apell_paterno,apell_materno,
	nombre1,nombre2,sexo,estado_civil,correo,estado,municipio ,fechaexp, tipo_tarjeta ,
	tipo_telef1,tipo_telef2, tipo_telef3,tipored1,tipored2,telefono1,telefono2,telefono3,telefono4,extension
    from vencimiento_debito_vip	where periodo = vaniomes;	
		
	set isolation to dirty read;
	INSERT INTO sd_temp_vencimiento_debito 
	select limit vregistro2
	tipoprom,tipologica ,fecha,cuenta,sucursal,numcte,n_tarjeta_ult4,status,prioridad,apell_paterno,apell_materno,
	nombre1,nombre2,sexo,estado_civil,correo,estado,municipio ,fechaexp, tipo_tarjeta ,
	tipo_telef1,tipo_telef2, tipo_telef3,tipored1,tipored2,telefono1,telefono2,telefono3,telefono4,extension
	from vencimiento_debito_altransac where periodo = vaniomes;
------------------------------------------------------------------------------------------------------------
				 -- vip debito
		    let vsql = ' echo "Tipo Promocion|Tipo Logica|Fecha|Num Credito|Sucursal|Numcte|Ult_4dig|Status |Prioridad|Apell_p|Apell_m|Nombre1|Nombre2|Sexo|Estado_Civil|Correo|Estado|Municipio|Num_credito|Numcte|Fecha_venc|Num_cuenta|Tipo_tarjeta|">/resplogifx/VencDebVIP_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.txt';
			
			system vsql; 							
            let vsql = '';
			let vsql = '';
			LET vsql = 'echo "UNLOAD TO ' || '''/resplogifx/vip_debito.unl''' || ' DELIMITER ' || '''|'''|| 
              ' select tipoprom,tipologica ,fecha,trim( cuenta),sucursal,numcte,n_tarjeta_ult4,status,prioridad,apell_paterno,apell_materno , '||
			 ' nombre1,nombre2,sexo,estado_civil,correo,estado,municipio ,trim( cuenta),numcte, fechavenc,trim( cuenta) ,tipo_tarjeta  ' ||
			 ' from sd_temp_vencimiento_debito where tipologica = 5 ;'|| 
             ' " > /resplogifx/vip_debito.sql';
			system vsql;
			let vsql = '';
			let vsql= 'dbaccess intercard  /resplogifx/vip_debito.sql';
			system vsql;
			let vsql ='';
			let vsql ='rm  /resplogifx/vip_debito.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/vip_debito.unl >>/resplogifx/VencDebVIP_"||day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".txt";
			system vsql;
			let vsql ='rm  /resplogifx/vip_debito.unl';
			system vsql;             		
			--------------------------------------ARCHIVO TELEFONOS
		

	
	LET vsql = '';
	let vsql = ' echo "Numero Credito|Numero Cliente|Tipo Telefono|Tipo Red|Telefono Original|Telefono Construido|Carrier|Extension|">/resplogifx/VencDebVip_TEL'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.txt';
	system vsql;			
	let vsql = '';
	LET vsql = 'echo "UNLOAD TO ' || '''/resplogifx/vip_transacc_debito.unl''' || ' DELIMITER ' || '''|'''|| 
		   ' select  trim( cuenta),numcte, tipo_telef1, tipored1 ,telefono1 ,telefono1 , 0 , ' ||" '0' "  ||
			' from sd_temp_vencimiento_debito	WHERE telefono1 <> '||" '' " ||
			' and tipologica = 5 '||
		' UNION '|| 
			' select  trim( cuenta),numcte, tipo_telef2, tipored2 ,telefono2 ,telefono2 , 0 , '||" '0' "  ||
			' from	sd_temp_vencimiento_debito	WHERE telefono2 <> '||" '' " ||
			' and tipologica = 5 '||
		' UNION ' || 
			' select  trim( cuenta),numcte,tipo_telef3, tipored1 ,telefono3 ,telefono3 , 0 ,extension '||
			' from sd_temp_vencimiento_debito	WHERE telefono3 <> '||" '' " ||	
			' and tipologica = 5 '||
	' " > /resplogifx/vip_transacc_debito.sql';
	system vsql;
	let vsql = '';
	let vsql= 'dbaccess intercard  /resplogifx/vip_transacc_debito.sql';
	system vsql;
	let vsql ='';
	let vsql ='rm  /resplogifx/vip_transacc_debito.sql';
	system vsql;
	let vsql ='';
	let vsql = "sed 's/|$//g' /resplogifx/vip_transacc_debito.unl >>/resplogifx/VencDebVip_TEL"|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".txt";
	system vsql;
	let vsql ='rm  /resplogifx/vip_transacc_debito.unl';
	system vsql; 
	

	------------------------------------------------------		
		    --alta transaccionalidad debito
		    let vsql = ' echo "Tipo Promocion|Tipo Logica|Fecha|Num Credito|Sucursal|Numcte|Ult_4dig|Status |Prioridad|Apell_p|Apell_m|Nombre1|Nombre2|Sexo|Estado_Civil|Correo|Estado|Municipio|Num_credito|Numcte|Fecha_venc|Num_cuenta|Tipo_tarjeta|">/resplogifx/VencDebAlta_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.txt';
			system vsql; 							
            let vsql = '';
			let vsql = '';
			LET vsql = 'echo "UNLOAD TO ' || '''/resplogifx/Alta_transacc_debito.unl''' || ' DELIMITER ' || '''|'''|| 
              ' select tipoprom,tipologica ,fecha,trim( cuenta),sucursal,numcte,n_tarjeta_ult4,status,prioridad,apell_paterno,apell_materno , '||
			 ' nombre1,nombre2,sexo,estado_civil,correo,estado,municipio ,trim( cuenta),numcte, fechavenc,trim( cuenta),tipo_tarjeta  ' ||
			 ' from sd_temp_vencimiento_debito where tipologica = 6 ;'|| 
             ' " > /resplogifx/Alta_transacc_debito.sql';
			system vsql;
			let vsql = '';
			let vsql= 'dbaccess intercard  /resplogifx/Alta_transacc_debito.sql';
			system vsql;
			let vsql ='';
			let vsql ='rm  /resplogifx/Alta_transacc_debito.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/Alta_transacc_debito.unl >>/resplogifx/VencDebAlta_"||day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".txt";
			system vsql;
			let vsql ='rm  /resplogifx/Alta_transacc_debito.unl';
			system vsql;     

		--------------------------------------ARCHIVO TELEFONOS
	
	LET vsql = '';
	let vsql = ' echo "Numero Credito|Numero Cliente|Tipo Telefono|Tipo Red|Telefono Original|Telefono Construido|Carrier|Extension|">/resplogifx/VencDebAlta_TEL'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.txt';
	system vsql;			
	let vsql = '';
	LET vsql = 'echo "UNLOAD TO ' || '''/resplogifx/Alta_transacc_debito.unl''' || ' DELIMITER ' || '''|'''|| 
		 ' select trim( cuenta),numcte, tipo_telef1, tipored1 ,telefono1 ,telefono1 , 0 , ' ||" '0' "  ||
			' from sd_temp_vencimiento_debito	WHERE telefono1 <> '||" '' " ||
			' and tipologica = 6 '||
		' UNION '|| 
			' select  trim( cuenta),numcte, tipo_telef2, tipored2 ,telefono2 ,telefono2 , 0 , '||" '0' "  ||
			' from	sd_temp_vencimiento_debito	WHERE telefono2 <> '||" '' " ||
			' and tipologica = 6 '||
		' UNION ' || 
			' select  trim( cuenta),numcte,tipo_telef3, tipored1 ,telefono3 ,telefono3 , 0 ,extension '||
			' from sd_temp_vencimiento_debito	WHERE telefono3 <> '||" '' " ||	
			' and tipologica = 6 '||
	' " > /resplogifx/Alta_transacc_debito.sql';
	system vsql;
	let vsql = '';
	let vsql= 'dbaccess intercard  /resplogifx/Alta_transacc_debito.sql';
	system vsql;
	let vsql ='';
	let vsql ='rm  /resplogifx/Alta_transacc_debito.sql';
	system vsql;
	let vsql ='';
	let vsql = "sed 's/|$//g' /resplogifx/Alta_transacc_debito.unl >>/resplogifx/VencDebAlta_TEL"|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".txt";
	system vsql;
	let vsql ='rm  /resplogifx/Alta_transacc_debito.unl';
	system vsql; 
	

	drop table sd_temp_vencimiento_debito;*/
	------------------------------------------------------
	-----------------------------------------GUARDAR DATOS LATINIA------------------------------------------
	select valor_numerico into vvalor1 from bdicobranza:cb_param_campania where tipo_campania = 50 and num_parametro = 62;
	select valor_numerico into vvalor2 from bdicobranza:cb_param_campania where tipo_campania = 50 and num_parametro = 63;
	
	--INSERT INTO bdicobranza:cb_administativa_latinia--(num_campania,numcte,telefono,tarjeta ,apellido_pat,fecha)
	select limit vvalor1 a.numcte,a.cuenta, SUBSTR(tel2.telefono,(LENGTH(tel2.telefono) + 1 - 10),10) telefono,
	a.n_tarjeta_ult4,
						CASE WHEN LENGTH(a.nombre1) <=  3 THEN TRIM(a.nombre1)||' '||TRIM(SUBSTR(a.nombre2,1,9 - LENGTH(a.nombre1))) 
						ELSE SUBSTR(a.nombre1,1,10) END nombre,t.expiracion
	from "informix".vencimiento_debito_vip a 
	join bdinteg:si_telefonos_actual tel2 on (tel2.empresa = '001' and tel2.numcte= a.numcte and tel2.tipo_tel = 2 and tel2.cofetel ='V' and tel2.status_tel = 'A'
                            and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = a.numcte and tipo_tel = 2 and cofetel ='V' and status_tel = 'A'))
	join bdicheq:sc_tarjeta t on (t.empresa = '001' and t.cuenta = a.cuenta  and t.secuencia = (select max(tar.secuencia) 
												from bdicheq:sc_tarjeta tar 
												where tar.empresa = '001' and tar.cuenta = a.cuenta 
												and tar.tipo_tarjeta ='T' and tar.status_tar = 'A'))
    where tel2.telefono is not null and tel2.telefono <> '' and t.tipo_tarjeta ='T'  and t.status_tar = 'A'
	and a.n_tarjeta_ult4 = SUBSTR (t.num_tarjeta,13)
	AND a.periodo =vaniomes into temp temp_debito;
	 
	--INSERT INTO bdicobranza:cb_administativa_latinia--(num_campania,numcte,telefono,tarjeta ,apellido_pat,fecha)
	insert into temp_debito
    select limit vvalor2 a.numcte,a.cuenta, SUBSTR(tel2.telefono,(LENGTH(tel2.telefono) + 1 - 10),10) telefono,
	a.n_tarjeta_ult4,
						CASE WHEN LENGTH(a.nombre1) <=  3 THEN TRIM(a.nombre1)||' '||TRIM(SUBSTR(a.nombre2,1,9 - LENGTH(a.nombre1))) 
						ELSE SUBSTR(a.nombre1,1,10) END nombre,t.expiracion
	from "informix".vencimiento_debito_altransac a 
	join bdinteg:si_telefonos_actual tel2 on (tel2.empresa = '001' and tel2.numcte= a.numcte and tel2.tipo_tel = 2 and tel2.cofetel ='V' and tel2.status_tel = 'A'
                            and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = a.numcte and tipo_tel = 2 and cofetel ='V' and status_tel = 'A'))
	join bdicheq:sc_tarjeta t on (t.empresa = '001' and t.cuenta = a.cuenta  and t.secuencia = (select max(tar.secuencia) 
												from bdicheq:sc_tarjeta tar 
												where tar.empresa = '001' and tar.cuenta = a.cuenta 
												and tar.tipo_tarjeta ='T' and tar.status_tar = 'A'))
    where tel2.telefono is not null and tel2.telefono <> '' and t.tipo_tarjeta ='T'  and t.status_tar = 'A'
	and a.n_tarjeta_ult4 = SUBSTR (t.num_tarjeta,13)
	AND a.periodo = vaniomes;
	--------------------------------------------------------------------------------------------------------
	select count(*) into vcontador from temp_debito;
	
	if (vcontador >= 1) then
	ForEach
		select numcte,cuenta,nombre, n_tarjeta_ult4,expiracion
		INTO vnumcte, vnum_credito,vapellido_pat,vtarjeta,vfecha
		FROM temp_debito
		
		let vfechas = lpad(day(vfecha),2,'0')||'-'|| decode (month(vfecha),01,'Ene',02,'Feb',03,'Mar',04,'Abr',05,'May',06,'Jun',
																   07,'Jul',08,'Ago',09,'Sep',10,'Oct',11,'Nov',12,'Dic');
		
		call bdimnsj:"informix".sp_registra_evento (2, 'VENC_TDD' , vnumcte, vnum_credito,'', 2,
							vapellido_pat,vtarjeta,vfechas,'','',0,0,0,0,0, '', '')RETURNING vcodret;
	--CALL bdicobranza:"informix".sp_sms_reporte(5,0,0,0) RETURNING 	vcodret;
	End ForEach;
	end if;
	
	if day(vfecha)<=8 then
		FOREACH
		select descripcion,  valor_alfabetico
		into VlDescripcion, vlValorAlfabetico
		from bdicred:sd_param_campania 
		where tipo_campania = 60  AND GRUPO_PARAMETRO = 'TELSMSFIJO'
		and num_parametro in (1,2,3)
		
		select numcte,num_credito
		  into vnumcte,vnum_credito
		  from bdicred:sd_maecred
		 where num_credito = vlValorAlfabetico;
		 select  count(*) into vlCDummy   
      from bdimnsj:"informix".mnsjr_trx_batch 
     where tipo_mensaje = 2  
      and to_char(fecha_hora_registro,'%m%Y') = to_char( vfecha_hoy,'%m%Y' )
      and id_mensaje  = 'VENC_TDD'
	  and cuenta = vlValorAlfabetico;
      
      if vlCDummy > 0 then continue foreach; end if;
		 
		select CASE WHEN LENGTH(a.nombre1) <=  3 THEN TRIM(a.nombre1)||' '||TRIM(SUBSTR(a.nombre2,1,9 - LENGTH(a.nombre1))) ELSE
																					SUBSTR(a.nombre1,1,10) END nombre into vapellido_pat
    from bdinteg:si_cliente a where numcte = vnumcte;
	
    call bdimnsj:"informix".sp_registra_evento (2, 'VENC_TDD' , vnumcte, '000000000000','', 2,
							vapellido_pat,'',vfechas,'','',0,0,0,0,0, '', '')RETURNING vcodret;
		--call bdimnsj:"informix".sp_registra_evento (2, 'VENC_TDD', vnumcte,'000000000000', '',2, VlDescripcion, '', '', '','', '', '', '', 
		--			'', '', '', '', 0, 0, 0, 0, 0, '', '') RETURNING vcodret;	

    END FOREACH;
	end if;
	
	  drop table mi_may;
		LET vcodret = '0000';
		LET  p_mensaje  = 'Proceso Exitoso';
			
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, vcodret, p_mensaje, '03')
				RETURNING vcodret2;
		return vcodret, p_mensaje;
else
    LET vcodret = '0001';
    LET  p_mensaje  = 'Mes ya Procesado, Favor de Verificar';
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, vcodret, p_mensaje, '03')
				RETURNING vcodret2;
     return vcodret, p_mensaje;
end if 
END;
end procedure;