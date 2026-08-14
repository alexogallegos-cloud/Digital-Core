CREATE PROCEDURE "informix".sp_obtieneinfocobranza_web( Pfecha Date,Psucursal Char (04),Pejecutivo Char (08), PtipoEjecutivo Char (01) , siRegistros SMALLINT)
RETURNING   Char (05) 		AS cod_ret        ,
		    Date 	  		AS Fecha          ,
		    Char (04) 		AS Sucursal       ,
		    integer   		AS tpo_reg        ,
		    Char (08) 		AS Cajero         ,
		    Char (104)		AS Nombre         ,
		    Integer 		AS num_ctes_cvdo  ,
		    Integer			AS Num_conv       ,
		    Money (18,2)	AS tot_mont_conv  ,
		    Money (18,2)	AS tot_mont_pag   ,
		    Money (18,2)	AS pag_min_a_recup,
		    Money (18,2)	AS pag_min_recup  ,
			INTEGER			AS num_pm		  ,
			INTEGER			AS num_sin_pm	  , 
		    Money (18,2)	AS venc_a_recup   ,
		    Money (18,2)	AS venc_recup	  ,
			INTEGER			AS num_vencidos	  ,
			INTEGER			AS num_sin_vencidos;
			
		  
--declaracion de variables de retorno
			DEFINE	cod_ret 			Char (05)   ;
			DEFINE	vFecha				Date        ;
			DEFINE	vSucursal 			Char (04)   ;
			DEFINE	vtpo_reg			integer     ;
			DEFINE	vCajero				Char (08)   ;
			DEFINE	vNombre				Char (104)  ;
			DEFINE	vnum_ctes_cvdo		Integer     ;
			DEFINE	vNum_conv			Integer     ;
			DEFINE	vtot_mont_conv		Money (18,2);
			DEFINE	vtot_mont_pag		Money (18,2);
			DEFINE	vpag_min_a_recup	Money (18,2);
			DEFINE	vpag_min_recup		Money (18,2);
			DEFINE	vnum_pm				INTEGER		;
			DEFINE	vnum_sin_pm			INTEGER		;
			DEFINE	vvenc_a_recup		Money (18,2);
			DEFINE	vvenc_recup			Money (18,2);
			DEFINE	vnum_vencidos		INTEGER		;
			DEFINE	vnum_sin_vencidos	INTEGER		;
			DEFINE  vestatus_rcda		CHAR(1);
--
			DEFINE 	vpaso			smallint	;
			DEFINE 	v_sEstatus 		CHAR(1)		;
			DEFINE 	dMaxFecha    	DATE		;
			
			DEFINE	vsqlerr      	INTEGER;
			DEFINE	contador 		INTEGER;
			
			--inicializacion de variables

			let	cod_ret 		  = '00000'	;
			let	vFecha			  = '01/01/1900';
			let	vSucursal 		  = '';	
			let	vtpo_reg		  =	0 ;
			let	vCajero			  = '';
			let	vNombre			  = 'Error en central sp_obtieneinfocobranza' ;
			let	vnum_ctes_cvdo	  = 0 ;
			let	vNum_conv		  = 0 ;
			let	vtot_mont_conv	  = 0 ;
			let	vtot_mont_pag	  = 0 ;
			let	vpag_min_a_recup  = 0 ;
			let	vpag_min_recup	  = 0 ;
			let	vvenc_a_recup	  = 0 ;
			let	vnum_pm			  = 0 ;
			let	vnum_sin_pm		  = 0 ;
			let	vvenc_recup		  = 0 ;
			let contador 		  = 0 ;
			let	vnum_vencidos	  = 0 ;
			let	vnum_sin_vencidos = 0 ;
			
	
BEGIN 
   ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            let cod_ret = vsqlerr;
            RETURN  cod_ret,vfecha, vsucursal,vtpo_reg , vcajero, vnombre, vnum_ctes_cvdo, vnum_conv, vtot_mont_conv, 
										vtot_mont_pag, vpag_min_a_recup, vpag_min_recup,vnum_pm, vnum_sin_pm, vvenc_a_recup, vvenc_recup,vnum_vencidos, vnum_sin_vencidos;
        END IF;
    END EXCEPTION;


SET ISOLATION TO DIRTY READ;
SELECT {+ INDEX(mi_param idx_descparam)} estatus INTO v_sEstatus FROM bdmis:mi_param WHERE descripcion = 'FLAG RPT CIERRE';
SELECT {+ INDEX(mi_activarsuc_rcda idx_mi_activarsuc_rcda)} estatus_rcda INTO vestatus_rcda	FROM bdmis:mi_activarsuc_rcda WHERE sucursal = Psucursal;

	if (v_sEstatus = 'V') OR (vestatus_rcda = 'V') then
	
			SELECT MAX(fecha_rptcierre) INTO dMaxFecha FROM bdmis:mi_rptcierresucestatus WHERE sucursal = Psucursal AND fecha_rptcierre IS NOT NULL;

		IF (PtipoEjecutivo = 'A'  AND dMaxFecha IS NOT NULL) or(PtipoEjecutivo = 'Z'  AND dMaxFecha IS NOT NULL) OR (PtipoEjecutivo = 'E'  AND dMaxFecha IS NOT NULL) OR (PtipoEjecutivo = 'U'  AND dMaxFecha IS NOT NULL) THEN	
		
			IF PtipoEjecutivo = 'E' or PtipoEjecutivo = 'U' THEN
			
				IF (SELECT TRIM(estatus) FROM mi_rptcierresucestatus WHERE sucursal = Psucursal) <> 'C' THEN
				
					LET cod_ret = '00008';
					LET Vnombre = 'EL GERENTE NO A CONSULTADO EL REPORTE';
							
								RETURN  cod_ret,vfecha, vsucursal,vtpo_reg , vcajero, vnombre, vnum_ctes_cvdo, vnum_conv, vtot_mont_conv, 
										vtot_mont_pag, vpag_min_a_recup, vpag_min_recup,vnum_pm, vnum_sin_pm, vvenc_a_recup, vvenc_recup,vnum_vencidos, vnum_sin_vencidos;								
							
				END IF
			
			END IF
			
			if pfecha = dMaxFecha THEN
						
					IF 	(SELECT COUNT(*) FROM  mi_cobranza where fecha = pfecha and sucursal = Psucursal ) > 0 THEN
						
						foreach
							select SKIP siRegistros  FIRST 21 fecha, sucursal,tpo_reg , cajero, nombre, nvl(num_ctes_cvdo,0), nvl(num_conv,0), nvl(tot_mont_conv,0), 
								   nvl(tot_mont_pag,0), nvl(pag_min_a_recup,0), nvl(pag_min_recup,0),NVL(num_pm,0), nvl(num_sin_pm,0), nvl(venc_a_recup,0),
								   nvl(venc_recup ,0), nvl(num_vencidos,0), nvl(num_sin_vencidos,0)
							INTO  vfecha, vsucursal,vtpo_reg , vcajero, vnombre, vnum_ctes_cvdo, vnum_conv, vtot_mont_conv, 
								  vtot_mont_pag, vpag_min_a_recup, vpag_min_recup,vnum_pm, vnum_sin_pm, vvenc_a_recup, vvenc_recup,vnum_vencidos, vnum_sin_vencidos
							from  mi_cobranza
							where fecha = pfecha and sucursal = Psucursal
							
								RETURN  cod_ret,vfecha, vsucursal,vtpo_reg , vcajero, vnombre, vnum_ctes_cvdo, vnum_conv, vtot_mont_conv, 
										vtot_mont_pag, vpag_min_a_recup, vpag_min_recup,vnum_pm, vnum_sin_pm, vvenc_a_recup, vvenc_recup,
										vnum_vencidos, vnum_sin_vencidos WITH RESUME;
										
								let contador = contador + 1;		
						
						end foreach
						
					ELSE
								
								LET cod_ret = '00007';
								LET Vnombre = 'NO EXISTE INFORMACION DE OPERACIONES EN VENTANILLA';
							
								RETURN  cod_ret,vfecha, vsucursal,vtpo_reg , vcajero, vnombre, vnum_ctes_cvdo, vnum_conv, vtot_mont_conv, 
										vtot_mont_pag, vpag_min_a_recup, vpag_min_recup,vnum_pm, vnum_sin_pm, vvenc_a_recup, vvenc_recup,vnum_vencidos, vnum_sin_vencidos;								
							
					END IF
					
				ELif pfecha < dMaxFecha THEN
			
					IF 	(SELECT COUNT(*) FROM  mi_his_cobranza where fecha = pfecha and sucursal = Psucursal ) > 0 THEN
			
						foreach
							select SKIP siRegistros  FIRST 21 fecha, sucursal,tpo_reg , cajero, nombre, nvl(num_ctes_cvdo,0), nvl(num_conv,0), nvl(tot_mont_conv,0), 
								   nvl(tot_mont_pag,0), nvl(pag_min_a_recup,0), nvl(pag_min_recup,0),NVL(num_pm,0), nvl(num_sin_pm,0), nvl(venc_a_recup,0),
								   nvl(venc_recup ,0), nvl(num_vencidos,0), nvl(num_sin_vencidos,0)
							INTO  vfecha, vsucursal,vtpo_reg , vcajero, vnombre, vnum_ctes_cvdo, vnum_conv, vtot_mont_conv, 
								  vtot_mont_pag, vpag_min_a_recup, vpag_min_recup,vnum_pm, vnum_sin_pm, vvenc_a_recup, vvenc_recup,vnum_vencidos, vnum_sin_vencidos
							from  mi_his_cobranza
							where fecha = pfecha and sucursal = Psucursal
							
								RETURN  cod_ret,vfecha, vsucursal,vtpo_reg , vcajero, vnombre, vnum_ctes_cvdo, vnum_conv, vtot_mont_conv, 
										vtot_mont_pag, vpag_min_a_recup, vpag_min_recup,vnum_pm, vnum_sin_pm, vvenc_a_recup, vvenc_recup,
										vnum_vencidos, vnum_sin_vencidos WITH RESUME;
										
								let contador = contador + 1;		
																		
						end foreach
						
					ELSE
								
								LET cod_ret = '00007';
								LET Vnombre = 'NO EXISTE INFORMACION DE OPERACIONES EN VENTANILLA';
							
								RETURN  cod_ret,vfecha, vsucursal,vtpo_reg , vcajero, vnombre, vnum_ctes_cvdo, vnum_conv, vtot_mont_conv, 
										vtot_mont_pag, vpag_min_a_recup, vpag_min_recup,vnum_pm, vnum_sin_pm, vvenc_a_recup, vvenc_recup,vnum_vencidos, vnum_sin_vencidos;								
							
					END if	
					
				ELSE 
				
						RETURN '00005',vFecha,vSucursal,vtpo_reg,vcajero,'No existe información del reporte del cierre diario de la sucursal',vnum_ctes_cvdo, vnum_conv,
								vtot_mont_conv, vtot_mont_pag, vpag_min_a_recup, vpag_min_recup,vnum_pm, vnum_sin_pm, vvenc_a_recup, vvenc_recup,vnum_vencidos, vnum_sin_vencidos;
					
					
			
			end if
			
			ELSE
			
				RETURN '00006',vFecha,vSucursal,vtpo_reg,vcajero,'tipo de usuario no valido',vnum_ctes_cvdo, vnum_conv,
								vtot_mont_conv, vtot_mont_pag, vpag_min_a_recup, vpag_min_recup,vnum_pm, vnum_sin_pm, vvenc_a_recup, vvenc_recup,vnum_vencidos, vnum_sin_vencidos;
				
							
				
		end if	

	ELIF (v_sEstatus = '') OR (v_sEstatus IS NULL) THEN
        LET cod_ret = '00002';
		LET vNombre = 'Parámetro de servicio no establecido';
    ELSE
		LET cod_ret = '00003';
		LET vNombre = 'Servicio no disponible';
	END IF;
	
	if cod_ret <> '00000' THEN
	
		RETURN  cod_ret,vfecha, vsucursal,vtpo_reg , vcajero, vnombre, vnum_ctes_cvdo, vnum_conv, vtot_mont_conv, 
										vtot_mont_pag, vpag_min_a_recup, vpag_min_recup,vnum_pm, vnum_sin_pm, vvenc_a_recup, vvenc_recup,vnum_vencidos, vnum_sin_vencidos; 
									
	END IF

END 
END PROCEDURE;