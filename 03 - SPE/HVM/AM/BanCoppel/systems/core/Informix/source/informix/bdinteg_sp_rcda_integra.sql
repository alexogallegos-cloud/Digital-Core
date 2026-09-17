create procedure "informix".sp_rcda_integra()
	RETURNING CHAR (005) as cod_ret,
			  char (180) as mensaje;

	--Declaracion de variables
				  
	--variables de control de errores			  
	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	DEFINE  dFecha           Date;
	DEFINE  dFechafto        char(10);
	DEFINE  dFechaCorte      Date;
	DEFINE  dFechaAnt        Date;
	DEFINE  dFechahoy        Date;
	DEFINE  dult_dia_mes     Date;
	DEFINE  dfechaantier     Date;
	DEFINE  iDiasMes         INTEGER;
	DEFINE  vpaso			 integer;
	DEFINE  vaniomes		 char(06);
	DEFINE  iVal             INTEGER;
	DEFINE  iVal2            INTEGER;
	DEFINE  iPorCap          decimal;
	DEFINE  iPorSdo          decimal;
	DEFINE  iPorCol          decimal;
	DEFINE  iPorTdc          decimal;
	
BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO || ' sp_rcda_integra en paso ' || vpaso;
	  insert into mi_rcda_cierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
	  select fecha_ant,'F',P_COD_RET, P_MENSAJE  from bdmis:mi_fechas;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;
   
   set isolation to dirty read;
   
   --inicializacion
	let P_COD_RET = '00000';
	let P_MENSAJE ='PROCESO EXITOSO';
   
     let vpaso = 0;
   --se obtienen las fechas de proceso   
	   set isolation to dirty read;
	   select fecha_ant,day(ult_dia_mes)::int, (fecha_ant-1), fecha_hoy, ult_dia_mes 
	   into dFecha,iDiasMes, dfechaantier, dFechahoy, dult_dia_mes 
	   from bdmis:mi_fechas;
	   
			if (SELECT count(codigo_error) FROM mi_rcda_cierresucerror where fecha_cierre = dfecha and codigo_error = 001) > 0 then
			   return '001','fecha ya procesada';
			end if	   
	   
	   let vaniomes = year(dFecha)|| lpad(month(dFecha),2,'0');
   
   	
		set isolation to dirty read;
		 let vpaso = 1;
		 truncate TABLE mi_aperturas;
		 		
			--extraccion de metas de productos
			select mp.aniomes,suc.num_sucursal as sucursal,suc.tipo_suc, mp.producto ,mp.metanum 
			from  mi_metasprod mp, mi_sucursalesinfo suc where mp.aniomes = vaniomes and mp.id_tiposuc = suc.tipo_suc
			into temp tmp_mp;

			--	llenado de tabla de aperturas, cuentas de captación
			insert into mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,capcuentas, capmeta)
			SELECT  dfecha,tmp.sucursal, 1,tmp.ejecutivo, eje.nombre, tmp.producto, tmp.num_ctasdia ,mp.metanum
			FROM    mi_rcda_suc tmp, tmp_mp mp, bdinteg:si_ejecut eje
			where   tmp.producto in ('2000','1100','1200','1300','1400','1500','1600','1800','1700','9901','2300','2500','1900')  and
					tmp.sucursal = mp.sucursal and tmp.producto = mp.producto and aniomes = vaniomes and 
					tmp.ejecutivo = eje.ejecutivo ;
		 
		 let vpaso = 2;
		 --llenado de tabla de aperturas, solicitudes de credito
		 	insert into mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,colsolcred, colsolmeta)
			SELECT  dfecha,tmp.sucursal, 1,tmp.ejecutivo, eje.nombre, tmp.producto, tmp.num_ctasdia ,mp.metanum
			FROM    mi_rcda_suc tmp, tmp_mp mp, bdinteg:si_ejecut eje
			where   tmp.producto in ('6001')  and
					tmp.sucursal = mp.sucursal and tmp.producto = mp.producto and aniomes = vaniomes and 
					tmp.ejecutivo = eje.ejecutivo ;
					
		 let vpaso = 3;
		 --llenado de tabla de aperturas, tarjeta de credito entregada
		 	insert into mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,colentrcred, colentrmeta)
			SELECT  dfecha,tmp.sucursal, 1,tmp.ejecutivo, eje.nombre, tmp.producto, tmp.num_ctasdia ,mp.metanum
			FROM    mi_rcda_suc tmp, tmp_mp mp, bdinteg:si_ejecut eje
			where   tmp.producto in ('6666')  and
					tmp.sucursal = mp.sucursal and tmp.producto = mp.producto and aniomes = vaniomes and 
					tmp.ejecutivo = eje.ejecutivo ;
					
		 let vpaso = 4;
		--llenado de tabla de aperturas, solicitudes de tarjeta de credito coppel
		 insert into mi_aperturas  (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,copsoltdc,copsolmeta)
			SELECT  dfecha,tmp.sucursal, 1,tmp.ejecutivo, eje.nombre, tmp.producto, tmp.num_ctasdia ,mp.metanum
			FROM    mi_rcda_suc tmp, tmp_mp mp, bdinteg:si_ejecut eje
			where   tmp.producto in ('6500')  and
					tmp.sucursal = mp.sucursal and tmp.producto = mp.producto and aniomes = vaniomes and 
					tmp.ejecutivo = eje.ejecutivo ;
					
		let vpaso = 5;			
		--llenado de tabla de aperturas, tarjeta de credito coppel entregadas
			insert into mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,copentrtdc, copentrmeta)
			SELECT  dfecha,tmp.sucursal, 1,tmp.ejecutivo, eje.nombre, tmp.producto, tmp.num_ctasdia ,mp.metanum
			FROM    mi_rcda_suc tmp, tmp_mp mp, bdinteg:si_ejecut eje
			where   tmp.producto in ('6566')  and
					tmp.sucursal = mp.sucursal and tmp.producto = mp.producto and aniomes = vaniomes and 
					tmp.ejecutivo = eje.ejecutivo ;
			
		let vpaso = 6;		
		--	--llenado de tabla de aperturas, contratos de banca electronica
			insert into mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo,nombre ,producto,be_totcontr, be_meta)
			SELECT  dfecha,tmp.sucursal, 1,tmp.ejecutivo, eje.nombre, tmp.producto, tmp.num_ctasdia ,mp.metanum
			FROM    mi_rcda_suc tmp, tmp_mp mp, bdinteg:si_ejecut eje
			where   tmp.producto in ('5003')  and
					tmp.sucursal = mp.sucursal and tmp.producto = mp.producto and aniomes = vaniomes and 
					tmp.ejecutivo = eje.ejecutivo ;		
		
		
		
		--paso a tablas de acumulado mensual
		set isolation to dirty read;		
		let vpaso = 7;
		-- paso de productividad de sucursales a acumulado mensual
			
			insert into mi_acumps_mes ( fecha, sucursal, ejecutivo, nombre,producto,capcuentas,capmeta,colsolcred,colsolmeta,colentrcred,
							colentrmeta,copsoltdc,copsolmeta,copentrtdc,copentrmeta,num_comp_mismomes,meta_comp_mismomes,clubncandidatos,
							clubncompraron,be_totcontr,be_meta)
			SELECT fecha, sucursal, ejecutivo, nombre,producto,capcuentas,capmeta,colsolcred,colsolmeta,colentrcred,
							colentrmeta,copsoltdc,copsolmeta,copentrtdc,copentrmeta,num_comp_mismomes,meta_comp_mismomes,clubncandidatos,
							clubncompraron,be_totcontr,be_meta FROM mi_aperturas;

		let vpaso = 8;
		--paso de cobranza a acumulado mensual
			INSERT INTO bdmis:mi_acumcb_mes ( fecha, sucursal, cajero, nombre, num_ctes_cvdo, num_conv, tot_mont_conv, 
			tot_mont_pag, pag_min_a_recup, pag_min_recup, num_pm, num_sin_pm, venc_a_recup, venc_recup, num_vencidos, num_sin_vencidos )
			SELECT fecha, sucursal, cajero, nombre, num_ctes_cvdo, num_conv, tot_mont_conv, 
			tot_mont_pag, pag_min_a_recup, pag_min_recup, num_pm, num_sin_pm, venc_a_recup, venc_recup, num_vencidos, num_sin_vencidos  FROM bdmis:mi_cobranza ;
		
		let vpaso = 9;
		 --paso de operaciones en ventanilla a acumulado mensual
			INSERT INTO bdmis:mi_acumopven_mes(fecha, sucursal, cajero, nombre, num_depcap, mont_depcap, num_retcap, mont_retcap, 
			num_pagcred, mont_pagcred, num_dispcred, mont_dispcred, num_pagserv, mont_pagserv)
			SELECT fecha, sucursal, cajero, nombre, num_depcap, mont_depcap, num_retcap, mont_retcap, 
			num_pagcred, mont_pagcred, num_dispcred, mont_dispcred, num_pagserv, mont_pagserv FROM  bdmis:mi_opventanilla;
		
		
		--integracion de de valores acumulados del mes
		let vpaso = 10;
		 --acumulado de Productividad en Sucursales
			--acumulado para productos de captacion
			insert into mi_aperturas 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, capcuentas, capmeta)
			select dfecha,sucursal,2,ejecutivo,nombre,producto,sum(nvl(capcuentas,0)),sum(nvl(capmeta,0))
			from  mi_acumps_mes 
			where producto in ('2000','1100','1200','1300','1400','1500','1600','1800','1700','9901','2300','2500','1900')
					and (year(fecha) = year (dfecha) )
			group by 2,4,5,6;
		
		let vpaso = 11;
		 --acumulado solicitudes de tdc bancoppel
			insert into mi_aperturas 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, colsolcred, colsolmeta)
			select fecha,sucursal,ejecutivo,nombre,producto, sum(nvl(colsolcred,0)),  ((nvl(colsolmeta,0) * 24) / 30) * day (dfecha) 
			from  mi_acumps_mes where producto = '6001' and (year(fecha) = year (dfecha) ) and  (month(fecha) = month (dfecha) )
			group by 1,2,3,4,5,7;
		
		let vpaso = 12;	
		 --acumulado de tarjetas de credito entregdas 
			insert into mi_aperturas 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, colentrcred, colentrmeta)
			select fecha,sucursal,ejecutivo,nombre,producto, sum(nvl(colentrcred,0)),  ((nvl(colentrmeta,0) * 24) / 30) * day (dfecha) 
			from  mi_acumps_mes where producto = '6666' and (year(fecha) = year (dfecha) ) and  (month(fecha) = month (dfecha) )
			group by 1,2,3,4,5,7;
		  
		let vpaso = 13;  
		 -- acumulado solicitud de tarjeta de credito coppel  
		 
			insert into mi_aperturas 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, copsoltdc, copsolmeta)
			select fecha,sucursal,ejecutivo,nombre,producto, sum(nvl(copsoltdc,0)),  ((nvl(copsolmeta,0) * 24) / 30) * day (dfecha) 
			from  mi_acumps_mes where producto = '6500' and (year(fecha) = year (dfecha) ) and  (month(fecha) = month (dfecha) )
			group by 1,2,3,4,5,7;
		
		let vpaso = 14;	
		 -- acumulado tarjetas coppel entregadas
			insert into mi_aperturas 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, copentrtdc, copentrmeta)
			select fecha,sucursal,ejecutivo,nombre,producto, sum(nvl(copentrtdc,0)),  ((nvl(copentrmeta,0) * 24) / 30) * day (dfecha) 
			from  mi_acumps_mes where producto = '6566' and (year(fecha) = year (dfecha) ) and  (month(fecha) = month (dfecha) )
			group by 1,2,3,4,5,7;
		 
		 let vpaso = 15;
		 -- acumulado  club de proteccion 
			insert into mi_aperturas 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto,clubncandidatos, clubncompraron )
			select fecha,sucursal,ejecutivo,nombre,producto, sum(nvl(clubncandidatos,0)), sum(nvl(clubncompraron,0))
			from  mi_acumps_mes where producto = '7777' and (year(fecha) = year (dfecha) ) and  (month(fecha) = month (dfecha) )
			group by 1,2,3,4,5;
			
		let vpaso = 16;	
		 --  acumulado club de proteccion  
			insert into mi_aperturas 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, be_totcontr, be_meta)
			select fecha,sucursal,ejecutivo,nombre,producto, sum(nvl(be_totcontr,0)),  ((nvl(be_meta,0) * 24) / 30) * day (dfecha) 
			from  mi_acumps_mes where producto = '5003' and (year(fecha) = year (dfecha) ) and  (month(fecha) = month (dfecha) )
			group by 1,2,3,4,5,7;
		 
		let vpaso = 17;
		 -- acumulado clientes que compraron el mismo mes 
			insert into mi_aperturas 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, num_comp_mismomes, meta_comp_mismomes)
			select fecha,sucursal,ejecutivo,nombre,producto, sum(nvl(num_comp_mismomes,0)),  ((nvl(meta_comp_mismomes,0) * 24) / 30) * day (dfecha) 
			from  mi_acumps_mes where producto = '6111' and (year(fecha) = year (dfecha) ) and  (month(fecha) = month (dfecha) )
			group by 1,2,3,4,5,7;
			
		  
		 /*
		  insert into mi_aperturas 	(fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, capcuentas, capmeta, colsolcred, colsolmeta, colentrcred, colentrmeta,
									 copsoltdc, copsolmeta, copentrtdc, copentrmeta, clubncandidatos, clubncompraron, be_totcontr, be_meta)		
		  SELECT dfecha,sucursal, 2 ,ejecutivo, nombre, producto, sum(nvl(capcuentas,0)), ((nvl(capmeta,0) * 24) / 30) * day (dfecha), sum(nvl(colsolcred,0)),
				((nvl(colsolmeta,0) * 24) / 30) * day (dfecha), sum(nvl(colentrcred,0)), ((nvl(colentrmeta,0) * 24) / 30) * day (dfecha), sum(nvl(copsoltdc,0)),
				((nvl(copsolmeta,0) * 24) / 30) * day (dfecha), sum(nvl(copentrtdc,0)), ((nvl(copentrmeta,0) * 24) / 30) * day (dfecha), sum(nvl(clubncandidatos,0)),
				sum(nvl(clubncompraron,0)), sum(nvl(be_totcontr,0)), ((nvl(be_meta,0) * 24) / 30) * day (dfecha)
			FROM bdmis:mi_acumps_mes where year(fecha) = year (dfecha) 
			group by 1,2,3,4,5,6,8,10,12,14,16,20 ;
			*/
		
		let vpaso = 18;
		 -- acumulado de cobranza 
			INSERT into bdmis:mi_cobranza ( fecha, sucursal,tpo_reg , cajero, nombre, num_ctes_cvdo, num_conv, tot_mont_conv, 
											tot_mont_pag, pag_min_a_recup, pag_min_recup,num_pm, num_sin_pm, venc_a_recup, venc_recup, num_vencidos, num_sin_vencidos  )
		 select   dfecha, sucursal,2 ,cajero, nombre, sum(nvl(num_ctes_cvdo,0)), sum(nvl(num_conv,0)),
         sum(nvl(tot_mont_conv,0)), sum(nvl(tot_mont_pag,0)), sum(nvl(pag_min_a_recup,0)),
         sum(nvl( pag_min_recup,0)), sum(nvl(num_pm,0)), sum(nvl(num_sin_pm,0)), 
		 sum(nvl(venc_a_recup,0)), sum(nvl(venc_recup,0)), 
		 sum(nvl(num_vencidos,0)), sum(nvl(num_sin_vencidos,0)) 
		 from bdmis:mi_acumcb_mes where year(fecha) = year (dfecha)and month(fecha) = month(dfecha)
		 group by 1,2,3,4,5;
		
		
		let vpaso = 19;
		 -- acumulado de opereaciones en ventanilla
		 insert into mi_opventanilla (fecha, sucursal, tpo_reg ,cajero, nombre, num_depcap, mont_depcap, num_retcap, mont_retcap, 
									  num_pagcred, mont_pagcred, num_dispcred, mont_dispcred, num_pagserv, mont_pagserv)
		 SELECT dfecha, sucursal, 2,cajero, nombre, sum(nvl(num_depcap,0)), sum(nvl(mont_depcap,0)), sum(nvl(num_retcap,0)),
			    sum(nvl(mont_retcap,0)), sum(nvl(num_pagcred,0)), sum(nvl(mont_pagcred,0)), sum(nvl(num_dispcred,0)),
				sum(nvl(mont_dispcred,0)), sum(nvl(num_pagserv,0)), sum(nvl(mont_pagserv,0)) 
		FROM bdmis:mi_acumopven_mes where year(fecha) = year (dfecha)and month(fecha) = month(dfecha)
		group by 1,2,3,4,5;
		 
		 
		 
		
		/* fecha,sucursal, tpo_reg,ejecutivo,nombre,producto,capcuentas,capmeta,colsolcred,colsolmeta,colentrcred,
		colentrmeta,copsoltdc,copsolmeta,copentrtdc,copentrmeta,clubncandidatos,clubncompraron,be_totcontr,be_meta */
			
		--
		

		let vpaso = 20;
		IF (SELECT COUNT(*) FROM mi_rptcierresucestatus WHERE fecha_rptcierre = dFecha ) = 0 THEN
		
			TRUNCATE table bdmis:mi_rptcierresucestatus;
			insert into mi_rptcierresucestatus(sucursal,fecha_rptcierre) select num_sucursal,dFecha  from bdmis:mi_sucursalesinfo where num_sucursal < 2000;
		
		END IF	
		
		let vpaso = 21;
		
	    insert into mi_rcda_cierresucerror values (dFecha,'V',P_COD_RET,P_MENSAJE );

			
		let vpaso = 22;
		
		
        EXECUTE PROCEDURE "informix".sp_rcda_promotorvirtual()
            INTO P_COD_RET, P_MENSAJE;
        IF P_COD_RET <> '000' THEN
            RETURN P_COD_RET, P_MENSAJE;
        END IF;
		
		let vpaso = 23;
		EXECUTE PROCEDURE "informix".sp_rcda_rellenaprod()
            INTO P_COD_RET, P_MENSAJE;
        IF P_COD_RET <> '000000' THEN
            RETURN P_COD_RET, P_MENSAJE;
        END IF;
		
		let vpaso = 24;
		UPDATE mi_aperturas SET capmeta = 0, colsolmeta = 0,colentrmeta = 0, copsolmeta = 0,copentrmeta = 0,be_meta = 0, meta_comp_mismomes = 0
		WHERE nombre = 'PROMOTOR VIRTUAL';
		
		
		let vpaso = 25;
		UPDATE mi_aperturas set capmeta = 0, colsolmeta = 0,colentrmeta = 0, copsolmeta = 0,copentrmeta = 0,be_meta = 0, meta_comp_mismomes = 0
		WHERE ejecutivo IN (SELECT ejecutivo FROM bdinteg:si_ejecut WHERE puesto = '001');
		
		let vpaso = 26;
		EXECUTE PROCEDURE "informix".sp_paso_his()
		            INTO P_COD_RET, P_MENSAJE;
        IF P_COD_RET <> '000' THEN
            RETURN P_COD_RET, P_MENSAJE;
        END IF;		
				
				
		let vpaso = 27;			
			begin work;
				UPDATE bdmis:mi_param SET estatus = 'V' WHERE descripcion = 'FLAG RPT CIERRE';	
			commit work;
			
	RETURN P_COD_RET, P_MENSAJE;
END;
end procedure;