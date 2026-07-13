CREATE PROCEDURE "informix".sp_rcda_rellenaprod()
RETURNING CHAR (06) AS	cod_ret,
		  CHAR (80) AS	mensaje;
		  
	--variables de retorno
	DEFINE	cod_ret	CHAR (06);
	DEFINE	mensaje	CHAR (80);
	
	--control de errores
	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE	vpaso			 INTEGER;
	--
	--variables generales
	DEFINE	vejecutivo		CHAR (008);
	DEFINE	vnombre			CHAR (104);
	DEFINE	vsucursal		CHAR (004);
	DEFINE	vproducto		CHAR (004);
	DEFINE	vfecha			DATE;
	DEFINE	vmeta			money(15,3);
	DEFINE	vfecha2			DATE;
	
	BEGIN
	   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
			  LET cod_ret    = SQL_ERR;
			  LET mensaje  = ERROR_INFO || ' sp_rcda_rellenaprod en paso ' || vpaso;
			  insert into mi_rcda_cierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
			  select fecha_ant,'F',cod_ret, mensaje  from bdmis:mi_fechas;
			  RETURN cod_ret, mensaje;
		END EXCEPTION;
		
		let cod_ret = '000000';
		let mensaje = 'PROCESO EXITOSO';
	--SET debug file to "sp_rcda_rellenaprod.out";
	--TRACE ON;
	set ISOLATION TO dirty read;
		
	DELETE FROM mi_aperturas WHERE producto = '6111' and meta_comp_mismomes is null;	
		
	select fecha_ant into vfecha2 from bdmis:mi_fechas;	
		
		
		
		let vpaso = 0;
		
		SELECT	sf.num_sucursal, mp.producto, mp.metanum
		FROM	mi_metasprod mp, mi_sucursalesinfo sf
		where	mp.id_tiposuc = sf.tipo_suc and 
				aniomes = (YEAR(vfecha2) || LPAD( MONTH(vfecha2),2,'0')) and mp.metanum <> 0
		INTO temp mp_suc with no log;
	
	
		let vpaso = 1;
		SELECT eje.sucursal, eje.ejecutivo, mp.producto,mp.metanum FROM mi_aperturas eje , mp_suc mp
		 WHERE  mp.num_sucursal = eje.sucursal and eje.tpo_reg = 1 and eje.nombre <> 'PROMOTOR VIRTUAL' group by 1,2,3,4		
		into temp mp_eje_diario with no log;

		let vpaso = 2;
		SELECT eje.sucursal, eje.ejecutivo, mp.producto,mp.metanum FROM mi_aperturas eje , mp_suc mp
		 WHERE  mp.num_sucursal = eje.sucursal and eje.tpo_reg = 2 and eje.nombre <> 'PROMOTOR VIRTUAL' group by 1,2,3,4
		into temp mp_eje_acumulado with no log;

		let vpaso = 3;
		SELECT  eje.sucursal, eje.ejecutivo,(select nombre from bdinteg:si_ejecut s_e where s_e.ejecutivo = eje.ejecutivo ) as nombre,eje.producto,
				eje.metanum , ap.fecha FROM mp_eje_diario eje
			   left join mi_aperturas ap on ap.ejecutivo = eje.ejecutivo and ap.producto = eje.producto and ap.tpo_reg = 1
		 WHERE fecha is null 
		into temp mp_insert_diario with no log;

		let vpaso = 4;
		SELECT  eje.sucursal, eje.ejecutivo,(select nombre from bdinteg:si_ejecut s_e where s_e.ejecutivo = eje.ejecutivo ) as nombre,eje.producto,
					((nvl(eje.metanum ,0) * 24) / 30) * day (vfecha2) as metanum , ap.fecha FROM mp_eje_diario eje
			   left join mi_aperturas ap on ap.ejecutivo = eje.ejecutivo and ap.producto = eje.producto and ap.tpo_reg = 2
		 WHERE fecha is null 
		into temp mp_insert_acumulado with no log;
		
		--captacion
			--diario
		let vpaso = 5;
		BEGIN WORK;	
			insert into mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,capcuentas, capmeta)
			 select vfecha2,sucursal,1,ejecutivo,nombre,producto, 0,metanum from mp_insert_diario where producto in
			(SELECT num_producto FROM mi_producto where num_sistema in (1,3));
		COMMIT WORK;
		
		let vpaso = 6;
			--acumulado
		BEGIN WORK;
			insert into mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,capcuentas, capmeta)
			 select vfecha2,sucursal,2,ejecutivo,nombre,producto, 0,metanum from mp_insert_acumulado where producto in
			(SELECT num_producto FROM mi_producto where num_sistema in (1,3));
		COMMIT WORK;
		
		----llenado de tabla de aperturas, solicitudes de credito
			--diario
			let vpaso = 7;
		BEGIN WORK;
			insert into mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,colsolcred, colsolmeta)
			select vfecha2,sucursal,1,ejecutivo,nombre,producto, 0,metanum from mp_insert_diario where producto = '6001';
		COMMIT WORK;
		let vpaso = 8;
			--acumulado
		BEGIN WORK;
			insert into mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,colsolcred, colsolmeta)
			select vfecha2,sucursal,2,ejecutivo,nombre,producto, 0,metanum from mp_insert_acumulado where producto = '6001';
		COMMIT WORK;
		
		----llenado de tabla de tdc entregadas		
		let vpaso = 9;
			--diario
		BEGIN WORK;
			insert into mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,colentrcred, colentrmeta)
			select vfecha2,sucursal,1,ejecutivo,nombre,producto, 0,metanum from mp_insert_diario where producto = '6666';
		COMMIT WORK;
		let vpaso = 10;
			--acumulado
		BEGIN WORK;
			insert into mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,colentrcred, colentrmeta)
			select vfecha2,sucursal,2,ejecutivo,nombre,producto, 0,metanum from mp_insert_acumulado where producto = '6666';
		COMMIT WORK;
		
		--llenado de tabla de aperturas, solicitudes de tarjeta de credito coppel
			--diario
		let vpaso = 11;	
		BEGIN WORK;
			insert into mi_aperturas  (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,copsoltdc,copsolmeta)
			select vfecha2,sucursal,1,ejecutivo,nombre,producto, 0,metanum from mp_insert_diario where producto = '6500';
		COMMIT WORK;
		let vpaso = 12;
			--acumulado
		BEGIN WORK;
			insert into mi_aperturas  (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,copsoltdc,copsolmeta)
			select vfecha2,sucursal,2,ejecutivo,nombre,producto, 0,metanum from mp_insert_acumulado where producto = '6500';
		COMMIT WORK;
		
		--llenado de tabla de aperturas, tarjeta de credito coppel entregadas
			--diario
		let vpaso = 13;	
		BEGIN WORK;
			insert into mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,copentrtdc, copentrmeta)
			select vfecha2,sucursal,1,ejecutivo,nombre,producto, 0,metanum from mp_insert_diario where producto = '6566';
		COMMIT WORK;
		let vpaso = 14;
			--acumulado
		BEGIN WORK;
			insert into mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,copentrtdc, copentrmeta)
			select vfecha2,sucursal,2,ejecutivo,nombre,producto, 0,metanum from mp_insert_acumulado where producto = '6566';
		COMMIT WORK;
		
		--llenado de tabla de aperturas, contratos de banca electronica	
			--diario
		let vpaso = 15;	
		BEGIN WORK;
			insert into mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,be_totcontr, be_meta)
			select vfecha2,sucursal,1,ejecutivo,nombre,producto, 0,metanum from mp_insert_diario where producto = '5003';
		COMMIT WORK;
		let vpaso = 16;
			--acumulado
		BEGIN WORK;
			insert into mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,be_totcontr, be_meta)
			select vfecha2,sucursal,2,ejecutivo,nombre,producto, 0,metanum from mp_insert_acumulado where producto = '5003';
		COMMIT WORK;
		
		--clientes que compraron el mismo mes
			--diario
		let vpaso = 17;	
		BEGIN WORK;
			insert into mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,num_comp_mismomes, meta_comp_mismomes)
			select vfecha2,sucursal,1,ejecutivo,nombre,producto, 0,metanum from mp_insert_diario where producto = '6111';
		COMMIT WORK;
		let vpaso = 18;
			--acumulado
		BEGIN WORK;
			insert into mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,num_comp_mismomes, meta_comp_mismomes)
			select vfecha2,sucursal,2,ejecutivo,nombre,producto, 0,metanum from mp_insert_acumulado where producto = '6111';
		COMMIT WORK;
		
		
		BEGIN WORK;
			insert into mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,clubncandidatos,clubncompraron,clubncompraronmeta)
			select vfecha2,sucursal,1,ejecutivo,nombre,producto,0, 0,metanum from mp_insert_diario where producto = '7777';
		COMMIT WORK;
		let vpaso = 18;
			--acumulado
		BEGIN WORK;
			insert into mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,clubncandidatos,clubncompraron,clubncompraronmeta)
			select vfecha2,sucursal,2,ejecutivo,nombre,producto,0, 0,metanum from mp_insert_acumulado where producto = '7777';
		COMMIT WORK;
		
	RETURN cod_ret, mensaje;
	END
END PROCEDURE;