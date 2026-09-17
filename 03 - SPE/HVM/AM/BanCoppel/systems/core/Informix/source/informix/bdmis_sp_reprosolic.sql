CREATE PROCEDURE "informix".sp_reprosolic()
RETURNING	CHAR (06) AS cod_ret,
			CHAR (80) AS mensaje;
			
--variables de retorno 
	DEFINE	cod_ret					CHAR (06);
	DEFINE	mensaje					CHAR (80);
	
--variables de control de errores
	DEFINE  SQL_ERR					INTEGER;
	DEFINE  ISAM_ERR				INTEGER;
	DEFINE  ERROR_INFO				VARCHAR(80);			
	DEFINE	vpaso					INTEGER;	
	DEFINE	pfecha_ini				DATE;


BEGIN
	  ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET cod_ret    = SQL_ERR;
      LET mensaje  = ERROR_INFO || ' tmp_mi_rcda_solic en paso ' || vpaso;	  
      RETURN cod_ret, mensaje;
   END EXCEPTION;
   
   let cod_ret = '000000';
   let mensaje = 'PROCESO EXITOSO';
   
   let vpaso = 1;
   	IF  (SELECT COUNT(tabname) FROM systables WHERE tabname = 'tmp_mi_rcda_solic') >  0 THEN
		DROP TABLE tmp_mi_rcda_solic;
	END IF
   
   
   let vpaso = 2;
   CREATE TABLE informix.tmp_mi_rcda_solic ( 
		empresa       	CHAR(3),
		sucursal      	CHAR(4),
		ejecutivo     	CHAR(8),
		num_producto  	CHAR(4),
		numcte        	CHAR(20),
		num_referencia	CHAR(20),
		fecha_insert  	DATE 
    );
   
   LET pfecha_ini = '08/01/2014';
   
   let vpaso = 3;
   --extraccion de metas de productos
	select mp.aniomes,suc.num_sucursal as sucursal,suc.tipo_suc, mp.producto ,mp.metanum 
	from  mi_metasprod mp, mi_sucursalesinfo suc where mp.aniomes = '201408' and mp.id_tiposuc = suc.tipo_suc
	into temp tmp_mp;

   
   WHILE pfecha_ini < '08/27/2014'
   
   let vpaso = 4;
		BEGIN WORK;           
			 select empresa, sucursal, user_insert, num_solicitud, 
                    case when num_producto not in ('6500','6300') or user_insert = 'interact' then '6001'
                    else num_producto end
                     as num_producto , 
                    numcte, '' as num_referencia,fecha_insert
                from bdisolic:ss_solicitudes sol
                where fecha_insert = pfecha_ini  AND user_insert <> 'interact' and  --today /*dFecha o dFechafto */
                     numcte not in (SELECT rpt.numcte FROM tmp_mi_rcda_solic rpt
                                     WHERE rpt.numcte = sol.numcte and rpt.sucursal = sol.sucursal)
                                 and num_solicitud = ( Select min(num_solicitud) from bdisolic:ss_solicitudes soli2  
                                 where fecha_insert = pfecha_ini and soli2.numcte = sol.numcte 
                                 and soli2.num_producto = sol.num_producto and soli2.status_solicitud = sol.status_solicitud and soli2.sucursal = sol.sucursal )						
            into temp solicis with no log;
        COMMIT WORK;   
	let vpaso = 5;
		BEGIN WORK;
			select 'APERC' as tipo,empresa,sucursal,user_insert,num_producto, count(numcte) as num_ctasdia
				from bdmis:solicis
				where fecha_insert = pfecha_ini and (numcte is not null or numcte <> '') and numcte > "000000000"
				group by 1,2,3,4,5
			union all
			select 'APERC' as tipo,empresa,sucursal,user_insert,num_producto,count(num_referencia) as num_ctasdia
				from bdmis:solicis
				where fecha_insert = pfecha_ini and (num_referencia is not null or num_referencia <> '') and num_referencia > "0"
				group by 1,2,3,4,5
			into temp mi_rptsolic2 with no log;
		COMMIT WORK;

	let vpaso = 6;
		BEGIN WORK;
			select tipo,empresa,sucursal,user_insert,num_producto, sum(num_ctasdia) as num_ctasdia
            from mi_rptsolic2 group by tipo,empresa,sucursal,user_insert,num_producto
			into temp mi_rptsolic3 with no log;			
		COMMIT WORK ;
		
		BEGIN WORK;		
			delete from mi_rptsolic3  WHERE num_producto = '6500';
		COMMIT WORK;
		
		
		BEGIN WORK;		
			UPDATE mi_rptsolic3 SET num_producto = '6001' WHERE num_producto = '6300';
		COMMIT WORK;
		
	let vpaso = 7;	
		BEGIN WORK ;
		 	insert into mi_his_productividad (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,colsolcred, colsolmeta)
			SELECT  pfecha_ini,tmp.sucursal, 1,tmp.user_insert, eje.nombre, tmp.num_producto, tmp.num_ctasdia ,mp.metanum
			FROM    mi_rptsolic3 tmp, tmp_mp mp, bdinteg:si_ejecut eje
			where   tmp.num_producto in ('6001')  and
					tmp.sucursal = mp.sucursal and tmp.num_producto = mp.producto and aniomes = '201408' and 
					tmp.user_insert = eje.ejecutivo ;
		COMMIT WORK ;		
	
	let vpaso = 8;	
		BEGIN WORK ;
			insert into tmp_mi_rcda_solic(empresa, sucursal, ejecutivo, num_producto, numcte, num_referencia, fecha_insert )
			 select empresa, sucursal, user_insert, num_producto, numcte, 		 
			  case when num_solicitud = '' then num_referencia  
				   when num_referencia = '' then num_solicitud
				   else '' end	as  num_referencia,		   
			 fecha_insert FROM bdmis:solicis;
			-- WHERE fecha_insert = pfecha_ini;
		COMMIT WORK ;
	let vpaso = 9;
		DROP TABLE solicis;
		DROP TABLE mi_rptsolic2;
		DROP TABLE mi_rptsolic3;
		
			UPDATE STATISTICS HIGH FOR TABLE bdisolic:ss_solicitudes; 
		let	pfecha_ini = pfecha_ini + 1;
	END WHILE		
	
	
	RETURN cod_ret, mensaje;		
END			
END PROCEDURE;