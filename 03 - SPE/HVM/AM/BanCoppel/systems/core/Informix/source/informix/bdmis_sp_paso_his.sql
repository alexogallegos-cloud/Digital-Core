CREATE PROCEDURE "informix".sp_paso_his()
RETURNING Char (08) as cod_ret,
		  Char (180) as Mensaje;
		  


	--declaracion de variables de control de errores
		DEFINE  SQL_ERR          INTEGER;
		DEFINE  ISAM_ERR         INTEGER;
		DEFINE  ERROR_INFO       VARCHAR(80);
		DEFINE  P_COD_RET        VARCHAR(08);
		DEFINE  P_MENSAJE        VARCHAR(180);
		DEFINE vpaso             smallint;
		
	--
		DEFINE dfecha 			 date;
BEGIN		
--control de errores		
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO || ' sp_paso_his en paso ' || vpaso;
	  insert into mi_rcda_cierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
	  select fecha_ant,'F',P_COD_RET, P_MENSAJE  from bdmis:mi_fechas;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;		


   
   	let P_COD_RET = '000';
	let P_MENSAJE ='PROCESO EXITOSO';
   set isolation to dirty read;
   -- se obtiene la fecha que sera pasada a historico   
   let vpaso = 0;
   SELECT max(fecha) into dfecha FROM mi_aperturas ;
   
   
   /*
      -- validacion de paso a historico de productividad.
   let vpaso = 1;
   IF (select count(*) from mi_his_productividad where fecha = dfecha) > 0 THEN
			
		begin work;
			DELETE FROM mi_his_productividad WHERE fecha = dfecha;
		commit	work;
   
	END IF
	*/
	
	--validacion de paso historico de cobranza
	SELECT max(fecha) into dfecha FROM mi_cobranza ;
	let vpaso = 2;
	
	IF (select count(*) from mi_his_cobranza where fecha = dfecha) > 0 THEN
			
		begin work;	
			DELETE FROM mi_his_cobranza WHERE fecha = dfecha;
		commit	work;
   
	END IF
	
	--validacion de paso historico de operaciones en ventanilla
	SELECT max(fecha) into dfecha FROM mi_opventanilla ;
	let vpaso = 3;
	
	IF (select count(*) from mi_his_opventanilla where fecha = dfecha) > 0 THEN
			
		begin work;
			DELETE FROM mi_his_opventanilla WHERE fecha = dfecha;
		commit	work;
   
	END IF
	
	SELECT fecha_ant INTO dfecha FROM bdmis:mi_fechas;
	let vpaso = 5;
	
	BEGIN WORK;
		merge into {+INDEX(mi_his_productividad idx_his_productividad_paso_his)}	 mi_his_productividad a
		USING (select 	fecha,sucursal,tpo_reg,ejecutivo,nombre,producto,capcuentas,capmeta,colsolcred,colsolmeta,colentrcred,colentrmeta,copsoltdc,copsolmeta,
				copentrtdc,copentrmeta,num_comp_mismomes,meta_comp_mismomes,clubncandidatos,clubncompraron,clubncompraronmeta,be_totcontr,be_meta
		from mi_aperturas) b
		on a.fecha = b.fecha AND a.sucursal = b.sucursal AND a.tpo_reg = b.tpo_reg AND a.ejecutivo = b.ejecutivo AND a.producto = b.producto
		WHEN MATCHED THEN update
			SET a.copsoltdc = a.copsoltdc + b.copsoltdc	,
				a.copentrtdc = 	a.copentrtdc + b.copentrtdc,
				a.clubncompraron = a.clubncompraron + b.clubncompraron
		WHEN NOT MATCHED THEN
			INSERT  (a.fecha,a.sucursal,a.tpo_reg,a.ejecutivo,a.nombre,a.producto,a.capcuentas,a.capmeta,a.colsolcred,a.colsolmeta,
					 a.colentrcred,a.colentrmeta,a.copsoltdc,a.copsolmeta,a.copentrtdc,a.copentrmeta,a.num_comp_mismomes,
					 a.meta_comp_mismomes,a.clubncandidatos,a.clubncompraron,a.clubncompraronmeta,a.be_totcontr,a.be_meta)	
			VALUES	(b.fecha,b.sucursal,b.tpo_reg,b.ejecutivo,b.nombre,b.producto,b.capcuentas,b.capmeta,b.colsolcred,b.colsolmeta,
					 b.colentrcred,b.colentrmeta,b.copsoltdc,b.copsolmeta,b.copentrtdc,b.copentrmeta,b.num_comp_mismomes,
					 b.meta_comp_mismomes,b.clubncandidatos,b.clubncompraron,b.clubncompraronmeta,b.be_totcontr,b.be_meta)	;	 
		
		/*insert into mi_his_productividad (	fecha,sucursal,tpo_reg,ejecutivo,nombre,producto,capcuentas,capmeta,colsolcred,colsolmeta,colentrcred,colentrmeta,copsoltdc,copsolmeta,
											copentrtdc,copentrmeta,num_comp_mismomes,meta_comp_mismomes,clubncandidatos,clubncompraron,clubncompraronmeta,be_totcontr,be_meta)	
		select 	fecha,sucursal,tpo_reg,ejecutivo,nombre,producto,capcuentas,capmeta,colsolcred,colsolmeta,colentrcred,colentrmeta,copsoltdc,copsolmeta,
				copentrtdc,copentrmeta,num_comp_mismomes,meta_comp_mismomes,clubncandidatos,clubncompraron,clubncompraronmeta,be_totcontr,be_meta
		from mi_aperturas;*/
	COMMIT WORK;		
	
	
	let vpaso = 6;
	BEGIN WORK;
		INSERT into mi_his_cobranza ( fecha, sucursal,tpo_reg , cajero, nombre, num_ctes_cvdo, num_conv, tot_mont_conv, 
								tot_mont_pag, pag_min_a_recup, pag_min_recup,num_pm, num_sin_pm, venc_a_recup, venc_recup,  num_vencidos, num_sin_vencidos)
		select	{+INDEX(mi_cobranza idx_mi_his_opventanilla_paso_his)}	
				fecha, sucursal,tpo_reg , cajero, nombre, num_ctes_cvdo, num_conv, tot_mont_conv, 
				tot_mont_pag, pag_min_a_recup, pag_min_recup,num_pm, num_sin_pm, venc_a_recup, venc_recup,  num_vencidos, num_sin_vencidos
		from mi_cobranza WHERE fecha = dfecha;
	COMMIT WORK;	
  
	
	let vpaso = 7;
	 BEGIN WORK;
		 insert into mi_his_opventanilla (fecha, sucursal, tpo_reg ,cajero, nombre, num_depcap, mont_depcap, num_retcap, mont_retcap, 
									  num_pagcred, mont_pagcred, num_dispcred, mont_dispcred, num_pagserv, mont_pagserv)
		 select {+INDEX(mi_opventanilla idx_mi_opventanilla_paso_his)}	
				fecha, sucursal, tpo_reg ,cajero, nombre, num_depcap, mont_depcap, num_retcap, mont_retcap, 
				num_pagcred, mont_pagcred, num_dispcred, mont_dispcred, num_pagserv, mont_pagserv
		 from 	mi_opventanilla WHERE fecha = dfecha;
	 COMMIT WORK;
	 
	
	 RETURN P_COD_RET, P_MENSAJE;
END;
END PROCEDURE ;