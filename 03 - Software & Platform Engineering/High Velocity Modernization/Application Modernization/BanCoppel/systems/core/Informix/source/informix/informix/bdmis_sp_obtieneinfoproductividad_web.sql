CREATE PROCEDURE "informix".sp_obtieneinfoproductividad_web( Pfecha Date,Psucursal Char (04),Pejecutivo Char (08), PtipoEjecutivo Char (01), siRegistros SMALLINT )
RETURNING Char (05) 	as cod_ret			 , 
		  Date			as Fecha			 ,
		  Char (04) 	as Sucursal			 ,
		  CHAR (1)   	as tpo_reg			 ,
		  Char (08) 	as Ejecutivo		 ,
		  Char (104)	as Nombre			 ,
		  Char (04) 	as Producto			 ,
		  Integer 		as capcuentas		 ,
		  Money (18,4)  as capMeta			 ,
		  Integer 		as Colsolcred		 ,
		  Money (18,4)	as Colsolmeta		 ,
		  Integer 		as Colentrcred		 ,
		  Money (18,4)	as Colentrmeta		 ,
		  Integer 		as Copsoltdc		 ,
		  Money (18,4) 	as Copsolmeta		 ,
		  Integer 		as Copentrtdc		 ,
		  Money (18,4) 	as copentrmeta		 ,
		  integer 		AS num_comp_mismomes ,
		  Money (18,4)	AS meta_comp_mismomes,
		  Integer 		as Clubncandidatos	 ,
		  Integer 		as Clubncompraron	 ,
		  money (18,4)	as clubncompraronmeta,
		  Integer 		as be_totcontr		 ,
		  Money (18,4) 	as be_meta			 ;
		  
--declaracion de variables de retorno

	DEFINE	cod_ret				Char (05)   ;
	DEFINE	vFecha				Date        ;
	DEFINE	vSucursal			Char (04)   ;
	DEFINE	vtpo_reg			Integer     ;
	DEFINE	vEjecutivo			Char (08)   ;
	DEFINE	vNombre				Char (104)  ;
	DEFINE	vProducto			Char (04)   ;
	DEFINE	vcapcuentas			Integer     ;
	DEFINE	vcapMeta			Money (18,4);
	DEFINE	vColsolcred			Integer     ;
	DEFINE	vColsolmeta			Money (18,4);
	DEFINE	vColentrcred		Integer     ;
	DEFINE	vColentrmeta		Money (18,4);
	DEFINE	vCopsoltdc			Integer     ;
	DEFINE	vCopsolmeta			Money (18,4);
	DEFINE	vCopentrtdc			Integer     ;
	DEFINE	vcopentrmeta		Money (18,4);
	DEFINE	vnum_comp_mismomes	Integer		;
	DEFINE	vmeta_comp_mismomes	Money (18,4);
	DEFINE	vClubncandidatos 	Integer     ;
	DEFINE	vClubncompraron  	Integer     ;
	DEFINE	vclubncompraronmeta money (18,4);
	DEFINE	vbe_totcontr	 	Integer     ;
	DEFINE	vbe_meta			Money (18,4);
	DEFINE  vestatus_rcda		CHAR(1);  
--
	DEFINE 	vpaso				smallint	;
	DEFINE 	v_sEstatus 			CHAR(1)		;
	DEFINE 	dMaxFecha    		DATE		;
		
	DEFINE	vsqlerr      		INTEGER		;
	DEFINE	contador 			INTEGER		;
	
	
--inicializacion de variables
	let cod_ret 			= '00000';
	let	vFecha			    = '01/01/1900' ;
	let	vSucursal		    = '';
	let	vtpo_reg		    = 0	;
	let	vEjecutivo		    = '';
	let	vNombre			    = 'ERROR EN CENTRAL sp_obtieneinfoproductividad';
	let	vProducto		    = '';
	let	vcapcuentas		    = 0 ;
	let	vcapMeta		    = 0 ;
	let	vColsolcred		    = 0 ;
	let	vColsolmeta		    = 0 ;
	let	vColentrcred	    = 0 ;
	let	vColentrmeta	    = 0 ;
	let	vCopsoltdc		    = 0 ;
	let	vCopsolmeta		    = 0 ;
	let	vCopentrtdc		    = 0 ;
	let	vcopentrmeta	    = 0 ;
	let	vnum_comp_mismomes	= 0 ;
	let	vmeta_comp_mismomes	= 0 ;	
	let	vClubncandidatos    = 0 ;
	let	vClubncompraron     = 0 ;
	let vclubncompraronmeta = 0 ;
	let	vbe_totcontr	    = 0 ;
	let	vbe_meta		    = 0 ;
	
	
	
BEGIN 
   ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            let cod_ret = vsqlerr;
            RETURN cod_ret,vFecha,vSucursal,vtpo_reg,vEjecutivo,vNombre,vProducto,vcapcuentas,vcapMeta,vColsolcred,vColsolmeta,vColentrcred,	
									   vColentrmeta,vCopsoltdc,vCopsolmeta,vCopentrtdc,vcopentrmeta,vnum_comp_mismomes,vmeta_comp_mismomes,vClubncandidatos,vClubncompraron,vclubncompraronmeta,vbe_totcontr,vbe_meta;
        END IF;
    END EXCEPTION;


SET ISOLATION TO DIRTY READ;
SELECT {+ INDEX(mi_param idx_descparam)} estatus INTO v_sEstatus FROM bdmis:mi_param WHERE descripcion = 'FLAG RPT CIERRE';
SELECT {+ INDEX(mi_activarsuc_rcda idx_mi_activarsuc_rcda)} estatus_rcda INTO vestatus_rcda FROM bdmis:mi_activarsuc_rcda WHERE sucursal = Psucursal;

	if (v_sEstatus = 'V') OR (vestatus_rcda = 'V') then
	
			SELECT MAX(fecha_rptcierre) INTO dMaxFecha FROM bdmis:mi_rptcierresucestatus WHERE sucursal = Psucursal AND fecha_rptcierre IS NOT NULL;

		IF (PtipoEjecutivo = 'A'  AND dMaxFecha IS NOT NULL) OR (PtipoEjecutivo = 'Z'  AND dMaxFecha IS NOT NULL) OR (PtipoEjecutivo = 'E'  AND dMaxFecha IS NOT NULL) OR (PtipoEjecutivo = 'U'  AND dMaxFecha IS NOT NULL) THEN	
		
			IF PtipoEjecutivo = 'E' or PtipoEjecutivo = 'U' THEN
			
				IF (SELECT TRIM(estatus) FROM mi_rptcierresucestatus WHERE sucursal = Psucursal) <> 'C' THEN
				
					let cod_ret = '00008' ;
						let vNombre = 'EL GERENTE NO A CONSULTADO EL REPORTE';
						
						RETURN cod_ret,vFecha,vSucursal,vtpo_reg,vEjecutivo,vNombre,vProducto,vcapcuentas,vcapMeta,vColsolcred,vColsolmeta,vColentrcred,	
									   vColentrmeta,vCopsoltdc,vCopsolmeta,vCopentrtdc,vcopentrmeta,vnum_comp_mismomes,vmeta_comp_mismomes,vClubncandidatos,vClubncompraron,vclubncompraronmeta,vbe_totcontr,vbe_meta ;
					
				END IF
			
			END IF
			IF pfecha = dMaxFecha THEN
			
				IF (select count(*)  from  mi_aperturas  where fecha = pfecha and sucursal = Psucursal) > 0 THEN
				
						foreach
							select SKIP siRegistros  FIRST 15 fecha,sucursal, tpo_reg,ejecutivo, nvl(nombre,''), producto, NVL(capcuentas,0), NVL(capmeta,0), NVL(colsolcred,0), NVL(colsolmeta,0), NVL(colentrcred,0),
								   NVL(colentrmeta,0), NVL(copsoltdc,0), NVL(copsolmeta,0), NVL(copentrtdc,0), NVL(copentrmeta,0),NVL(num_comp_mismomes,0),NVL(meta_comp_mismomes,0), NVL(clubncandidatos,0), NVL(clubncompraron,0),nvl(clubncompraronmeta,0) ,NVL(be_totcontr,0), NVL(be_meta,0)
							INTO   vFecha,vSucursal,vtpo_reg,vEjecutivo,vNombre,vProducto,vcapcuentas,vcapMeta,vColsolcred,vColsolmeta,vColentrcred,	
								   vColentrmeta,vCopsoltdc,vCopsolmeta,vCopentrtdc,vcopentrmeta,vnum_comp_mismomes,vmeta_comp_mismomes,vClubncandidatos,vClubncompraron,vclubncompraronmeta,vbe_totcontr,vbe_meta   
							from  mi_aperturas 
							where fecha = pfecha and sucursal = Psucursal
							
								RETURN cod_ret,vFecha,vSucursal,vtpo_reg,vEjecutivo,vNombre,vProducto,vcapcuentas,vcapMeta,vColsolcred,vColsolmeta,vColentrcred,	
									   vColentrmeta,vCopsoltdc,vCopsolmeta,vCopentrtdc,vcopentrmeta,vnum_comp_mismomes,vmeta_comp_mismomes, vClubncandidatos,vClubncompraron,vclubncompraronmeta,vbe_totcontr,vbe_meta WITH RESUME;
						END FOREACH
						
					ELSE
							
						let cod_ret = '00007' ;
						let vNombre = 'NO EXISTE INFORMACION DE APERTURAS PARA ESTA SUCURSAL';
						
						UPDATE bdmis:mi_rptcierresucestatus
						SET ejecutivo = Pejecutivo, estatus = 'C', hora = CURRENT HOUR TO MINUTE
						WHERE sucursal = Psucursal
						AND fecha_rptcierre = pfecha ;
						
						RETURN cod_ret,vFecha,vSucursal,vtpo_reg,vEjecutivo,vNombre,vProducto,vcapcuentas,vcapMeta,vColsolcred,vColsolmeta,vColentrcred,	
									   vColentrmeta,vCopsoltdc,vCopsolmeta,vCopentrtdc,vcopentrmeta,vnum_comp_mismomes,vmeta_comp_mismomes,vClubncandidatos,vClubncompraron,vclubncompraronmeta,vbe_totcontr,vbe_meta ;
				
				END IF 	

				ELIF pfecha < dMaxFecha THEN
				
					if (select count(*)  from  mi_his_productividad  where fecha = pfecha and sucursal = Psucursal) > 0 THEN
			
						foreach
							select SKIP siRegistros  FIRST 15 fecha,sucursal, tpo_reg,ejecutivo, NVL(nombre,''), producto, NVL(capcuentas,0), NVL(capmeta,0), NVL(colsolcred,0), NVL(colsolmeta,0), NVL(colentrcred,0),
								   NVL(colentrmeta,0), NVL(copsoltdc,0), NVL(copsolmeta,0), NVL(copentrtdc,0), NVL(copentrmeta,0),NVL(num_comp_mismomes,0),NVL(meta_comp_mismomes,0), NVL(clubncandidatos,0), NVL(clubncompraron,0),nvl(clubncompraronmeta,0), NVL(be_totcontr,0), NVL(be_meta,0)
							INTO   vFecha,vSucursal,vtpo_reg,vEjecutivo,vNombre,vProducto,vcapcuentas,vcapMeta,vColsolcred,vColsolmeta,vColentrcred,	
								   vColentrmeta,vCopsoltdc,vCopsolmeta,vCopentrtdc,vcopentrmeta,vnum_comp_mismomes,vmeta_comp_mismomes,vClubncandidatos,vClubncompraron,vclubncompraronmeta,vbe_totcontr,vbe_meta   
							from  mi_his_productividad 
							where fecha = pfecha and sucursal = Psucursal
							
								RETURN cod_ret,vFecha,vSucursal,vtpo_reg,vEjecutivo,vNombre,vProducto,vcapcuentas,vcapMeta,vColsolcred,vColsolmeta,vColentrcred,	
									   vColentrmeta,vCopsoltdc,vCopsolmeta,vCopentrtdc,vcopentrmeta,vnum_comp_mismomes,vmeta_comp_mismomes,vClubncandidatos,vClubncompraron,vclubncompraronmeta,vbe_totcontr,vbe_meta WITH RESUME;
	
						END FOREACH						
					ELSE
							
						let cod_ret = '00007' ;
						let vNombre = 'NO EXISTE INFORMACION DE APERTURAS PARA ESTA SUCURSAL';
						
						UPDATE bdmis:mi_rptcierresucestatus
						SET ejecutivo = Pejecutivo, estatus = 'C', hora = CURRENT HOUR TO MINUTE
						WHERE sucursal = Psucursal
						AND fecha_rptcierre = pfecha ;
						
						RETURN cod_ret,vFecha,vSucursal,vtpo_reg,vEjecutivo,vNombre,vProducto,vcapcuentas,vcapMeta,vColsolcred,vColsolmeta,vColentrcred,	
									   vColentrmeta,vCopsoltdc,vCopsolmeta,vCopentrtdc,vcopentrmeta,vnum_comp_mismomes,vmeta_comp_mismomes,vClubncandidatos,vClubncompraron,vclubncompraronmeta,vbe_totcontr,vbe_meta ;
				
					END IF	
						
				ELSE 
				
						RETURN '00005',vFecha,vSucursal,vtpo_reg,vEjecutivo,'No existe información del reporte del cierre diario de la sucursal',vProducto,vcapcuentas,vcapMeta,
							   vColsolcred,vColsolmeta,vColentrcred, vColentrmeta,vCopsoltdc,vCopsolmeta,vCopentrtdc,vcopentrmeta,vnum_comp_mismomes,vmeta_comp_mismomes,vClubncandidatos,vClubncompraron,vclubncompraronmeta,vbe_totcontr,vbe_meta;

			END IF
			
			ELSE
			
				RETURN '00006',vFecha,vSucursal,vtpo_reg,vEjecutivo,'tipo de usuario no valido',vProducto,vcapcuentas,vcapMeta,
				      vColsolcred,vColsolmeta,vColentrcred, vColentrmeta,vCopsoltdc,vCopsolmeta,vCopentrtdc,vcopentrmeta,vnum_comp_mismomes,vmeta_comp_mismomes,vClubncandidatos,vClubncompraron,vclubncompraronmeta,vbe_totcontr,vbe_meta;
			
		END IF	

	ELIF (v_sEstatus = '') OR (v_sEstatus IS NULL) THEN
        LET cod_ret = '00002';
		LET vNombre = 'Parámetro de servicio no establecido';
    ELSE
		LET cod_ret = '00003';
		LET vNombre = 'Servicio no disponible';
	END IF;
	
	IF  cod_ret <> '00000' THEN
	
		RETURN cod_ret,vFecha,vSucursal,vtpo_reg,vEjecutivo,vNombre,vProducto,vcapcuentas,vcapMeta,vColsolcred,vColsolmeta,vColentrcred,	
									   vColentrmeta,vCopsoltdc,vCopsolmeta,vCopentrtdc,vcopentrmeta,vnum_comp_mismomes,vmeta_comp_mismomes,vClubncandidatos,vClubncompraron,vclubncompraronmeta,vbe_totcontr,vbe_meta;
	
	END IF
END 
END PROCEDURE;