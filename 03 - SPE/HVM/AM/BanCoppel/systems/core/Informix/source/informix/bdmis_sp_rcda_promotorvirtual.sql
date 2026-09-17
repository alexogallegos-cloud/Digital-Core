CREATE procedure "informix".sp_rcda_promotorvirtual()
    RETURNING char(5),
          char(120);



    define cCodret            char(5);
    define sql_err            integer;
    DEFINE cVarDataErr        char(120);
    DEFINE iSamErr            INTEGER;

    DEFINE iFechaHoy          INTEGER;
    DEFINE iCuantos           INTEGER;

    DEFINE paso_nombre        CHAR(45);

   
    DEFINE v_empresa          CHAR(3);
   
   
	DEFINE v_num_ctasmes	  INTEGER;
	
	DEFINE	v_fecha						DATE	 ;
	DEFINE	v_sucursal                  CHAR(04) ;
	DEFINE	v_tpo_reg                   INTEGER	 ;
	DEFINE	v_ejecutivo                 CHAR(008);	
	DEFINE	v_nombre                    CHAR(104);
	DEFINE	v_producto                  CHAR(004);
	DEFINE	v_capcuentas                INTEGER	 ;
	DEFINE	v_capmeta                   Money (18,4);
	DEFINE	v_colsolcred                INTEGER ;
	DEFINE	v_colsolmeta                Money (18,4);
	DEFINE	v_colentrcred               INTEGER ;
	DEFINE	v_colentrmeta               Money (18,4);
	DEFINE	v_copsoltdc                 INTEGER;
	DEFINE	v_copsolmeta                Money (18,4);
	DEFINE	v_copentrtdc                INTEGER;
	DEFINE	v_copentrmeta               Money (18,4);
	DEFINE	v_num_comp_mismomes         Integer;
	DEFINE	v_meta_comp_mismomes        Money (18,4);
	DEFINE	v_clubncandidatos           INTEGER;
	DEFINE	v_clubncompraron            INTEGER;
	DEFINE	v_be_totcontr               INTEGER;
	DEFINE	v_be_meta                   Money (18,4);
	
	
	DEFINE vsFlagEnTransaccion 		CHAR(1);
    DEFINE viContadorRegistros 		INTEGER;
    DEFINE viContadorRegistros2 	INTEGER;
    DEFINE vpaso                	smallint;
	DEFINE vaniomes					char(06);
	DEFINE dfecha					DATE;
	
	DEFINE	vFecha			DATE	 ;
	DEFINE	vSucursal		CHAR(04) ;
	DEFINE	vtpo_reg		INTEGER	 ;
	DEFINE	vEjecutivo		CHAR(008);	
	DEFINE	vNombre			CHAR(104);
	DEFINE	vProducto		CHAR(004);
		
    BEGIN
        on exception set sql_err
          if sql_err <> 0 then
                    let cCodret = sql_err;
                    return cCodret,vpaso;
          end if;
        end exception;
            LET cVarDataErr = "";


        let cCodret = "000";
        let paso_nombre = "PROMOTOR VIRTUAL";
		let v_num_ctasmes = 0;
        
		LET vpaso    = 0;
		
		select fecha, sucursal,tpo_reg, ejecutivo, case when nombre is null then 'PROMOTOR VIRTUAL' else nombre end as nombre,
				producto, sum(nvl(capcuentas,0)) as capcuentas,sum(nvl(capmeta,0)) as capmeta,sum(nvl(colsolcred,0)) as colsolcred,sum(nvl(colsolmeta,0)) as colsolmeta,
				sum(nvl(colentrcred,0)) as colentrcred,sum(nvl(colentrmeta,0)) as colentrmeta,sum(nvl(copsoltdc,0)) as copsoltdc,sum(nvl(copsolmeta,0)) as copsolmeta,sum(nvl(copentrtdc,0)) as copentrtdc,sum(nvl(copentrmeta,0)) as copentrmeta,sum(nvl(num_comp_mismomes,0)) as num_comp_mismomes,
				sum(nvl(meta_comp_mismomes,0)) as meta_comp_mismomes,sum(nvl(clubncandidatos,0))as clubncandidatos,sum(nvl(clubncompraron,0)) as clubncompraron,sum(nvl(be_totcontr,0)) as be_totcontr,sum(nvl(be_meta,0)) as be_meta
				from mi_aperturas where ejecutivo < '90000000'--nombre = 'PROMOTOR VIRTUAL'
		group by 1,2,3,4,5,6 
		into temp virtual_acum WITH NO LOG; 
		
		
		DELETE FROM mi_aperturas WHERE nombre = 'PROMOTOR VIRTUAL';
		
		    LET cCodret = '000';
            LET vpaso    = 1;

-- PASO 1) optiene aniomes
		set isolation to dirty read;
		SELECT max(fecha_cierre) into dfecha FROM mi_rptcierresucerror ;
		let vaniomes = year(dFecha)|| lpad(month(dFecha),2,'0');
		
--PASO 2) integracion a promotor virtual del reporte diario y acumulado de aperturas
		LET vpaso    = 2;
		
		insert into mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, capcuentas, capmeta, colsolcred, colsolmeta, colentrcred, colentrmeta,
                         copsoltdc, copsolmeta, copentrtdc, copentrmeta, clubncandidatos, clubncompraron, be_totcontr, be_meta)		
		SELECT ap.Fecha,ap.Sucursal,ap.tpo_reg,
			   nvl((select sc.promotor_virtual 
				from bdmis:mi_sucursalesinfo sc
				where sc.num_sucursal = ap.sucursal),'00000000') as ejecutivo,
			   'PROMOTOR VIRTUAL' as nombre,ap.Producto, 
				sum(ap.capcuentas),ap.capMeta, sum(ap.Colsolcred),ap.Colsolmeta,sum(ap.Colentrcred), 
				ap.Colentrmeta, sum(ap.Copsoltdc),ap.Copsolmeta,sum(ap.Copentrtdc),ap.copentrmeta,
				sum(ap.Clubncandidatos),sum(ap.Clubncompraron), sum(ap.be_totcontr),ap.be_meta
		FROM mi_aperturas ap, bdinteg:si_ejecut eje 
		WHERE   -- ejecutivo dado de baja 
				(ap.sucursal  = eje.sucursal and
				ap.ejecutivo = eje.ejecutivo and 
				eje.password  = 'BAJA') or 
				-- el ejecutivo se encuentra en otra sucursal
				(ap.ejecutivo = eje.ejecutivo and 
				 ap.sucursal <> eje.sucursal ) or
				-- que el ejecutivo contenga el nombre en blanco
				(ap.ejecutivo = eje.ejecutivo and
				(ap.nombre is null or ap.nombre = '') ) 
				
				
		group by 1,2,3,4,5,6,8,10,12,14,16,20;
		

--	PASO 3) eliminacion de los registros pasados al promotor virtual del reporte diario y acumulado de aperturas
		LET vpaso    = 3;
		FOREACH
			select ap.Fecha,ap.Sucursal,ap.tpo_reg,ap.Ejecutivo,ap.Nombre,ap.Producto		
			INTO vFecha,vSucursal,vtpo_reg,vEjecutivo,vNombre, vProducto
			FROM mi_aperturas ap, bdinteg:si_ejecut eje 
			WHERE   -- ejecutivo dado de baja 
					(ap.sucursal  = eje.sucursal and
					ap.ejecutivo = eje.ejecutivo and 
					eje.password  = 'BAJA') or 
					-- el ejecutivo se encuentra en otra sucursal
					(ap.ejecutivo = eje.ejecutivo and 
					 ap.sucursal <> eje.sucursal ) or
					-- que el ejecutivo contenga el nombre en blanco
					(ap.ejecutivo = eje.ejecutivo and
					(ap.nombre is null or ap.nombre = '') )

			
				DELETE FROM mi_aperturas 
				WHERE Fecha = vFecha AND Sucursal = vSucursal AND tpo_reg = vtpo_reg AND 
					  Ejecutivo = vEjecutivo AND Nombre = vNombre AND Producto = vProducto;
				
				
		END FOREACH;
		
--PASO 4) se agregan los promotores virtuales acumulados que se obtuvieron en el reporte anterior
		FOREACH
			SELECT fecha, sucursal,tpo_reg, ejecutivo, nombre,producto,capcuentas,capmeta,colsolcred,colsolmeta,colentrcred,
				colentrmeta,copsoltdc,copsolmeta,copentrtdc,copentrmeta,num_comp_mismomes,meta_comp_mismomes,clubncandidatos,
				clubncompraron,be_totcontr,be_meta
			INTO v_fecha ,v_sucursal,v_tpo_reg ,v_ejecutivo,v_nombre,v_producto,v_capcuentas,v_capmeta ,v_colsolcred        
				,v_colsolmeta,v_colentrcred ,v_colentrmeta ,v_copsoltdc ,v_copsolmeta ,v_copentrtdc,v_copentrmeta       
				,v_num_comp_mismomes ,v_meta_comp_mismomes,v_clubncandidatos ,v_clubncompraron,v_be_totcontr,v_be_meta 
			FROM	virtual_acum
			 
				
				IF  (SELECT COUNT(*) FROM mi_aperturas WHERE fecha = v_fecha AND ejecutivo = v_ejecutivo AND producto = v_producto ) = 0 THEN
				
					INSERT INTO mi_aperturas (fecha, sucursal,tpo_reg, ejecutivo, nombre,producto,capcuentas,capmeta,colsolcred,colsolmeta,colentrcred,
								colentrmeta,copsoltdc,copsolmeta,copentrtdc,copentrmeta,num_comp_mismomes,meta_comp_mismomes,clubncandidatos,
								clubncompraron,be_totcontr,be_meta) VALUES
						(v_fecha ,v_sucursal,v_tpo_reg ,v_ejecutivo,v_nombre,v_producto,v_capcuentas,v_capmeta ,v_colsolcred        
						,v_colsolmeta,v_colentrcred ,v_colentrmeta ,v_copsoltdc ,v_copsolmeta ,v_copentrtdc,v_copentrmeta       
						,v_num_comp_mismomes ,v_meta_comp_mismomes,v_clubncandidatos ,v_clubncompraron,v_be_totcontr,v_be_meta);
					
					ELSE
						LET vpaso    = 4;
						
						
						 --captacion
							IF v_producto in ('2000','1100','1200','1300','1400','1500','1600','1800','1700','9901','2300','2500','1900') THEN
							
								UPDATE mi_aperturas SET capcuentas = capcuentas + v_capcuentas WHERE ejecutivo = v_ejecutivo and producto = v_sucursal;
								
							END IF
							
						LET vpaso    = 5;	
						--solicitudes	
							IF v_producto = '6001' THEN
								
								UPDATE mi_aperturas SET colsolcred = colsolcred + v_colsolcred WHERE ejecutivo = v_ejecutivo and producto = v_sucursal;
							
							END IF	
						LET vpaso    = 6;
						--tarjetas entregadas
							IF v_producto = '6666' THEN
								
								UPDATE mi_aperturas SET colentrcred = colentrcred + v_colentrcred WHERE ejecutivo = v_ejecutivo and producto = v_sucursal;
							
							END IF
							
						LET vpaso    = 7;	
						--tdc coppel

							IF v_producto = '6500' THEN
								
								UPDATE mi_aperturas SET copsoltdc = copsoltdc + v_copsoltdc WHERE ejecutivo = v_ejecutivo and producto = v_sucursal;
							
							END IF
							
						LET vpaso    = 8;	
						--tdc coppel entregadas

							IF v_producto = '6566' THEN
								
								UPDATE mi_aperturas SET copentrtdc = copentrtdc + v_copentrtdc WHERE ejecutivo = v_ejecutivo and producto = v_sucursal;
							
							END IF	
						
						LET vpaso    = 9;			
						--	clientes que compraron el mismo mes 
							IF v_producto = '6111' THEN
								
								UPDATE mi_aperturas SET num_comp_mismomes = num_comp_mismomes + v_num_comp_mismomes WHERE ejecutivo = v_ejecutivo and producto = v_sucursal;
							
							END IF
						
							LET vpaso    = 10;
						--	club de proteccion ,v_clubncandidatos ,v_clubncompraron
						
							IF v_producto = '7777' THEN
								
								UPDATE mi_aperturas SET clubncandidatos = clubncandidatos + v_clubncandidatos, clubncompraron = clubncompraron + v_clubncompraron
								WHERE ejecutivo = v_ejecutivo and producto = v_sucursal;
							
							END IF
						
						LET vpaso    = 11;
						-- banca electronica 
						
							IF v_producto = '5003' THEN
								
								UPDATE mi_aperturas SET be_totcontr = be_totcontr + v_be_totcontr WHERE ejecutivo = v_ejecutivo and producto = v_sucursal;
							
							END IF	
				
				END IF
		END FOREACH	
		
--PASO 5) INTEGRACION AL PROMOTOR VIRTUAL LA COBRANZA DIARIA Y ACUMULADA
		LET  vpaso = 12;
		DELETE FROM mi_cobranza WHERE nombre = 'PROMOTOR VIRTUAL';
		
		INSERT into bdmis:mi_cobranza ( fecha, sucursal,tpo_reg , cajero, nombre, num_ctes_cvdo, num_conv, tot_mont_conv, 
										tot_mont_pag, pag_min_a_recup, pag_min_recup, venc_a_recup, venc_recup )
		select  cb.Fecha,cb.Sucursal,cb.tpo_reg,
						nvl((select sc.promotor_virtual 
						from bdmis:mi_sucursalesinfo sc
						where sc.num_sucursal = cb.sucursal),'00000000') as ejecutivo,
					   'PROMOTOR VIRTUAL' as nombre,
				nvl(sum(cb.num_ctes_cvdo),0),nvl(sum(cb.Num_conv),0),nvl(sum(cb.tot_mont_conv),0),
				nvl(sum(cb.tot_mont_pag),0),nvl(sum(cb.pag_min_a_recup),0),nvl(sum(cb.pag_min_recup),0),nvl(sum(cb.venc_a_recup),0),nvl(sum(cb.venc_recup),0)
		FROM mi_cobranza cb, bdinteg:si_ejecut eje 
				WHERE   -- ejecutivo dado de baja 
						(cb.sucursal  = eje.sucursal and
						cb.cajero = eje.ejecutivo and  
						eje.puesto in ('004', '002') and 
						eje.password  = 'BAJA') or 
						-- el ejecutivo se encuentra en otra sucursal
						(cb.cajero = eje.ejecutivo and 
						 cb.sucursal <> eje.sucursal 
						 and eje.puesto in ('004', '002')) or
						-- que el ejecutivo contenga el nombre en blanco
						(cb.cajero = eje.ejecutivo and
						(cb.nombre is null or cb.nombre = '') 
						and eje.puesto in ('004', '002'))
		group by 1,2,3,4,5;
		
--	PASO 6) eliminacion de los registros pasados al promotor virtual del reporte diario y acumulado de cobranza		
		LET  vpaso = 13;
		FOREACH
			select cb.Fecha,cb.Sucursal,cb.tpo_reg,cb.Cajero,cb.Nombre
			INTO vFecha,vSucursal,vtpo_reg,vEjecutivo,vNombre		
			FROM mi_cobranza cb, bdinteg:si_ejecut eje 
			WHERE   -- ejecutivo dado de baja 
					(cb.sucursal  = eje.sucursal and
					cb.cajero = eje.ejecutivo and  
					eje.puesto in ('004', '002') and 
					eje.password  = 'BAJA') or 
					-- el ejecutivo se encuentra en otra sucursal
					(cb.cajero = eje.ejecutivo and 
					 cb.sucursal <> eje.sucursal 
					 and eje.puesto in ('004', '002')) or
					-- que el ejecutivo contenga el nombre en blanco
					(cb.cajero = eje.ejecutivo and
					(cb.nombre is null or cb.nombre = '') 
					and eje.puesto in ('004', '002'))
		
				DELETE FROM mi_cobranza 
				WHERE Fecha = vFecha AND Sucursal = vSucursal AND tpo_reg = vtpo_reg AND Cajero = vEjecutivo AND Nombre	= vNombre;		
		
		END FOREACH;
		
--PASO 7) INTEGRACION AL PROMOTOR VIRTUAL LAS OPERACIONES EN VENTANILLA DIARIA Y ACUMULADA
		LET  vpaso = 4;
		
		DELETE FROM mi_opventanilla WHERE nombre = 'PROMOTOR VIRTUAL';
		
		 insert into mi_opventanilla (fecha, sucursal, tpo_reg ,cajero, nombre, num_depcap, mont_depcap, num_retcap, mont_retcap, 
									  num_pagcred, mont_pagcred, num_dispcred, mont_dispcred, num_pagserv, mont_pagserv)
		select ov.fecha, ov.sucursal, ov.tpo_reg,
			   NVL((select sc.promotor_virtual 
				from bdmis:mi_sucursalesinfo sc
				where sc.num_sucursal = ov.sucursal),'00000000') as ejecutivo,
			   'PROMOTOR VIRTUAL' as nombre, 
			   sum(ov.num_depcap), sum(ov.mont_depcap), sum(ov.num_retcap), sum(ov.mont_retcap), 
			   sum(ov.num_pagcred), sum(ov.mont_pagcred), sum(ov.num_dispcred), sum(ov.mont_dispcred),
			   sum(ov.num_pagserv), sum(ov.mont_pagserv)
		FROM mi_opventanilla ov, bdinteg:si_ejecut eje 
				WHERE   -- ejecutivo dado de baja 
						(ov.sucursal  = eje.sucursal and
						ov.cajero = eje.ejecutivo and  
						eje.puesto in ('004', '002') and 
						eje.password  = 'BAJA') or 
						-- el ejecutivo se encuentra en otra sucursal
						(ov.cajero = eje.ejecutivo and 
						 ov.sucursal <> eje.sucursal 
						 and eje.puesto in ('004', '002')) or
						-- que el ejecutivo contenga el nombre en blanco
						(ov.cajero = eje.ejecutivo and
						(ov.nombre is null or ov.nombre = '') 
						and eje.puesto in ('004', '002'))
		group by 1,2,3,4,5;

--PASO 8) eliminacion de los registros pasados al promotor virtual del reporte diario y acumulado de las operaciones en ventanilla	
		LET  vpaso = 15;
		FOREACH
			select ov.fecha, ov.sucursal, ov.tpo_reg ,ov.cajero, ov.nombre
			INTO vFecha,vSucursal,vtpo_reg,vEjecutivo,vNombre	
			FROM mi_opventanilla ov, bdinteg:si_ejecut eje 
					WHERE   -- ejecutivo dado de baja 
							(ov.sucursal  = eje.sucursal and
							ov.cajero = eje.ejecutivo and  
							eje.puesto in ('004', '002') and 
							eje.password  = 'BAJA') or 
							-- el ejecutivo se encuentra en otra sucursal
							(ov.cajero = eje.ejecutivo and 
							 ov.sucursal <> eje.sucursal 
							 and eje.puesto in ('004', '002')) or
							-- que el ejecutivo contenga el nombre en blanco
							(ov.cajero = eje.ejecutivo and
							(ov.nombre is null or ov.nombre = '') 
							and eje.puesto in ('004', '002'))	
		
		
				DELETE FROM mi_opventanilla 
				WHERE fecha = vFecha AND sucursal = vSucursal AND tpo_reg = vtpo_reg AND cajero = vEjecutivo AND nombre = vNombre;
		
		
		END FOREACH;
		
		
--PASO 9)integracion del usuario interac al promotor virtual
		LET  vpaso = 16;
		
		FOREACH
		SELECT ap.Fecha,ap.Sucursal,ap.tpo_reg,
			   NVL((select sc.promotor_virtual 
				from bdmis:mi_sucursalesinfo sc
				where sc.num_sucursal = ap.sucursal),'00000000') as ejecutivo,
			   'PROMOTOR VIRTUAL' as nombre,ap.Producto, 
				sum(ap.capcuentas),ap.capMeta, sum(ap.Colsolcred),ap.Colsolmeta,sum(ap.Colentrcred), 
				ap.Colentrmeta, sum(ap.Copsoltdc),ap.Copsolmeta,sum(ap.Copentrtdc),ap.copentrmeta,
				sum(ap.Clubncandidatos),sum(ap.Clubncompraron), sum(ap.be_totcontr),ap.be_meta
		INTO	v_fecha ,v_sucursal,v_tpo_reg ,v_ejecutivo,v_nombre,v_producto,v_capcuentas,v_capmeta ,v_colsolcred        
				,v_colsolmeta,v_colentrcred ,v_colentrmeta ,v_copsoltdc ,v_copsolmeta ,v_copentrtdc,v_copentrmeta       
				,v_clubncandidatos ,v_clubncompraron,v_be_totcontr,v_be_meta 	
		FROM mi_aperturas ap
		WHERE   ap.ejecutivo = 'interact'
		group by 1,2,3,4,5,6,8,10,12,14,16,20
		
		IF (select COUNT(*) FROM mi_aperturas WHERE fecha = v_fecha AND sucursal = v_sucursal AND tpo_reg = v_tpo_reg AND ejecutivo = v_ejecutivo AND  producto = v_producto  ) = 0 THEN
		
					INSERT INTO mi_aperturas (fecha,sucursal, tpo_reg,ejecutivo, nombre, producto, capcuentas, capmeta, colsolcred, colsolmeta, colentrcred, colentrmeta,
									 copsoltdc, copsolmeta, copentrtdc, copentrmeta, clubncandidatos, clubncompraron, be_totcontr, be_meta)	
									VALUES (v_fecha ,v_sucursal,v_tpo_reg ,v_ejecutivo,v_nombre,v_producto,v_capcuentas,v_capmeta ,v_colsolcred        
											,v_colsolmeta,v_colentrcred ,v_colentrmeta ,v_copsoltdc ,v_copsolmeta ,v_copentrtdc,v_copentrmeta       
											,v_clubncandidatos ,v_clubncompraron,v_be_totcontr,v_be_meta );	
		
			ELSE
			
					UPDATE 	mi_aperturas SET colsolcred = colsolcred + v_colsolcred WHERE 	fecha = v_fecha AND sucursal = v_sucursal AND tpo_reg = v_tpo_reg AND ejecutivo = v_ejecutivo AND  producto = v_producto;			
		
		END IF 	

		END FOREACH;	
								 
		
		LET  vpaso = 17;
		BEGIN WORK;
			DELETE FROM mi_aperturas WHERE ejecutivo = 'interact';
		COMMIT WORK;

		
		LET  vpaso = 18;
		select fecha, sucursal,tpo_reg, ejecutivo, case when nombre is null then 'PROMOTOR VIRTUAL' else nombre end as nombre,
		producto, sum(nvl(capcuentas,0)) as capcuentas,sum(nvl(capmeta,0)) as capmeta,sum(nvl(colsolcred,0)) as colsolcred,sum(nvl(colsolmeta,0)) as colsolmeta,
		sum(nvl(colentrcred,0)) as colentrcred,sum(nvl(colentrmeta,0)) as colentrmeta,sum(nvl(copsoltdc,0)) as copsoltdc,sum(nvl(copsolmeta,0)) as copsolmeta,sum(nvl(copentrtdc,0)) as copentrtdc,sum(nvl(copentrmeta,0)) as copentrmeta,sum(nvl(num_comp_mismomes,0)) as num_comp_mismomes,
		sum(nvl(meta_comp_mismomes,0)) as meta_comp_mismomes,sum(nvl(clubncandidatos,0))as clubncandidatos,sum(nvl(clubncompraron,0)) as clubncompraron,sum(nvl(be_totcontr,0)) as be_totcontr,sum(nvl(be_meta,0)) as be_meta
		from mi_aperturas where ejecutivo < '90000000'
		group by 1,2,3,4,5,6 
		into temp agrupa_promotor WITH NO LOG; 
	
		LET  vpaso = 19;
		DELETE FROM mi_aperturas WHERE ejecutivo < '90000000';

		LET  vpaso = 20;
		insert into mi_aperturas (fecha, sucursal,tpo_reg, ejecutivo, nombre, producto, capcuentas,capmeta,colsolcred,colsolmeta,colentrcred,colentrmeta,copsoltdc,copsolmeta,
		copentrtdc,copentrmeta,num_comp_mismomes,meta_comp_mismomes,clubncandidatos,clubncompraron,be_totcontr,be_meta)
		select fecha, sucursal,tpo_reg, ejecutivo, nombre, producto, capcuentas,capmeta,colsolcred,colsolmeta,colentrcred,colentrmeta,copsoltdc,copsolmeta,
		copentrtdc,copentrmeta,num_comp_mismomes,meta_comp_mismomes,clubncandidatos,clubncompraron,be_totcontr,be_meta from agrupa_promotor;
		
		
        RETURN '000','';
      END
    END PROCEDURE;