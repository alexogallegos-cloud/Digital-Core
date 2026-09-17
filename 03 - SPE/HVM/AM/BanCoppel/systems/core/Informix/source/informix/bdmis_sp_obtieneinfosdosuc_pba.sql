CREATE PROCEDURE "informix".sp_obtieneinfosdosuc_pba(Pfecha Date,Psucursal Char (04),Pejecutivo Char (08), PtipoEjecutivo Char (01),  siRegistros SMALLINT )
RETURNING   Char (08)		AS cod_ret      		,
			DATE			AS fecha				,
			CHAR (04)		AS sucursal				,
			INTEGER			AS tpo_reg				,
			money (18,2)	AS Incre_SdoDia			,
			money (18,2)	AS Meta_Incre_SdoDia	,
			money (18,2)	AS por_CumpDia			,
			money (18,2)	AS Incr_SdoAcumulado	,
			money (18,2)	as Meta_IncrSdo_Acum	,
			money (18,2)	AS por_CumpAcum			,
			money (18,2)	AS Sdoafecha			,
			money (18,2)	AS Sdo_MetaFecha		,
			CHAR (80)		as mensaje				;
			
--declaracion de variables de retorno
			DEFINE	cod_ret				CHAR (08)	;	
			DEFINE	vfecha				DATE    	;
			DEFINE	vsucursal			CHAR(04)	;
			DEFINE	vtpo_reg			INTEGER 	;
			DEFINE	vIncre_SdoDia 		Money (18,2);
			DEFINE	vMeta_Incre_SdoDia	Money (18,2);
			DEFINE	vpor_CumpDia		money (18,2);
			DEFINE	vIncr_SdoAcumulado	Money (18,2);
			DEFINE	vMeta_IncrSdo_Acum	Money (18,2);
			DEFINE	vpor_CumpAcum		money (18,2);
			DEFINE	vSdoafecha			Money (18,2);
			DEFINE	vSdo_MetaFecha		Money (18,2);
			DEFINE	mensaje				CHAR (80)	;
			
			DEFINE 	vpaso				smallint	;
			DEFINE 	v_sEstatus 			CHAR(1)		;
			DEFINE 	dMaxFecha    		DATE		;
			DEFINE	vsqlerr      		INTEGER		;
			
			DEFINE	contador 			INTEGER;
			
			
			--inicializacion de variables

			let	cod_ret 		 	 = '00000000'	;
			let	vFecha			 	 = '01/01/1900';
			let	vSucursal 		 	 = '';	
			let	vtpo_reg		 	 = 0 ;
			let	vIncre_SdoDia 		 = 0 ;
			let	vMeta_Incre_SdoDia	 = 0 ;
			let	vpor_CumpDia		 = 0 ;
			let	vIncr_SdoAcumulado	 = 0 ;
			let	vMeta_IncrSdo_Acum	 = 0 ;
			let	vpor_CumpAcum		 = 0 ;
			let	vSdoafecha			 = 0 ;
			let	vSdo_MetaFecha		 = 0 ;
			let mensaje				 = 'Error en central sp_obtieneinfosdosuc' ;
			
			let contador			 = 0 ;
			
BEGIN 
   ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            let cod_ret = vsqlerr;
            RETURN cod_ret,vfecha, vsucursal, vtpo_reg, vIncre_SdoDia, vMeta_Incre_SdoDia, vpor_CumpDia, vIncr_SdoAcumulado, 
					vMeta_IncrSdo_Acum, vpor_CumpAcum, vSdoafecha, vSdo_MetaFecha, mensaje;
        END IF;
    END EXCEPTION;

			
SET ISOLATION TO DIRTY READ;
SELECT {+ INDEX(mi_param idx_descparam)} estatus INTO v_sEstatus FROM bdmis:mi_param WHERE descripcion = 'FLAG RPT CIERRE';

	if v_sEstatus = 'V' then
	
			SELECT MAX(fecha_rptcierre) INTO dMaxFecha FROM bdmis:mi_rptcierresucestatus WHERE sucursal = Psucursal AND fecha_rptcierre IS NOT NULL;

		IF (PtipoEjecutivo = 'A'  AND dMaxFecha IS NOT NULL) or(PtipoEjecutivo = 'Z'  AND dMaxFecha IS NOT NULL) OR (PtipoEjecutivo = 'E'  AND dMaxFecha IS NOT NULL) OR (PtipoEjecutivo = 'U'  AND dMaxFecha IS NOT NULL) THEN	
		
			IF PtipoEjecutivo = 'E' OR PtipoEjecutivo = 'U' THEN
			
				IF (SELECT TRIM(estatus) FROM mi_rptcierresucestatus WHERE sucursal = Psucursal) <> 'C' THEN
				
					let cod_ret = '00008' ;
						let mensaje = 'EL GERENTE NO A CONSULTADO EL REPORTE';
						
						RETURN  cod_ret,vfecha, vsucursal, vtpo_reg, vIncre_SdoDia, vMeta_Incre_SdoDia, vpor_CumpDia, vIncr_SdoAcumulado, 
												vMeta_IncrSdo_Acum, vpor_CumpAcum, vSdoafecha, vSdo_MetaFecha, mensaje;	
					
				END IF
			
			END IF
			
			if pfecha = dMaxFecha THEN
						
					
					IF (SELECT COUNT (*)  from  mi_sdosuc where fecha = pfecha and sucursal = Psucursal) > 0 THEN
						foreach
							select SKIP siRegistros  FIRST 2 fecha,sucursal,tpo_reg,NVL(Incre_SdoDia,0),NVL(Meta_Incre_SdoDia,0),NVL(por_CumpDia,0),nvl(Incr_SdoAcumulado,0),
									NVL(Meta_IncrSdo_Acum,0),NVL(por_CumpAcum,0),NVL(Sdoafecha,0),NVL(Sdo_MetaFecha,0)
							INTO  vfecha, vsucursal, vtpo_reg, vIncre_SdoDia, vMeta_Incre_SdoDia, vpor_CumpDia, vIncr_SdoAcumulado, 
								  vMeta_IncrSdo_Acum, vpor_CumpAcum, vSdoafecha, vSdo_MetaFecha
							from  mi_sdosuc
							where fecha = pfecha and sucursal = Psucursal
							
								RETURN  cod_ret,vfecha, vsucursal, vtpo_reg, vIncre_SdoDia, vMeta_Incre_SdoDia, vpor_CumpDia, vIncr_SdoAcumulado, 
								  vMeta_IncrSdo_Acum, vpor_CumpAcum, vSdoafecha, vSdo_MetaFecha, mensaje WITH RESUME;
						
							let contador = contador + 1;
						
						end foreach
						
					
					ELSE	
								
								LET cod_ret = '00007';
								LET mensaje = 'NO EXISTE INFORMACION DE SALDOS';
							
								RETURN  cod_ret,vfecha, vsucursal, vtpo_reg, vIncre_SdoDia, vMeta_Incre_SdoDia, vpor_CumpDia, vIncr_SdoAcumulado, 
												vMeta_IncrSdo_Acum, vpor_CumpAcum, vSdoafecha, vSdo_MetaFecha, mensaje;								
							
					END if
						
				ELif pfecha < dMaxFecha THEN
			
					IF (SELECT COUNT (*)  from  mi_his_sdo where fecha = pfecha and sucursal = Psucursal) > 0 THEN
					
						foreach
						select SKIP siRegistros  FIRST 2 fecha,sucursal,tpo_reg,NVL(Incre_SdoDia,0),NVL(Meta_Incre_SdoDia,0),NVL(por_CumpDia,0),nvl(Incr_SdoAcumulado,0),
								NVL(Meta_IncrSdo_Acum,0),NVL(por_CumpAcum,0),NVL(Sdoafecha,0),NVL(Sdo_MetaFecha,0)
						INTO  vfecha, vsucursal, vtpo_reg, vIncre_SdoDia, vMeta_Incre_SdoDia, vpor_CumpDia, vIncr_SdoAcumulado, 
							  vMeta_IncrSdo_Acum, vpor_CumpAcum, vSdoafecha, vSdo_MetaFecha
						from  mi_his_sdo
						where fecha = pfecha and sucursal = Psucursal
						
							RETURN  cod_ret,vfecha, vsucursal, vtpo_reg, vIncre_SdoDia, vMeta_Incre_SdoDia, vpor_CumpDia, vIncr_SdoAcumulado, 
							  vMeta_IncrSdo_Acum, vpor_CumpAcum, vSdoafecha, vSdo_MetaFecha, mensaje WITH RESUME;
							  
							let contador = contador + 1;  
																		
						end foreach
						
						
					ELSE
								
								LET cod_ret = '00007';
								LET mensaje = 'NO EXISTE INFORMACION DE SALDOS';
							
								RETURN  cod_ret,vfecha, vsucursal, vtpo_reg, vIncre_SdoDia, vMeta_Incre_SdoDia, vpor_CumpDia, vIncr_SdoAcumulado, 
												vMeta_IncrSdo_Acum, vpor_CumpAcum, vSdoafecha, vSdo_MetaFecha, mensaje;								
							
					END if
						
				ELSE 
				
						RETURN '00000005',vfecha, vsucursal, vtpo_reg, vIncre_SdoDia, vMeta_Incre_SdoDia, vpor_CumpDia, vIncr_SdoAcumulado, 
							  vMeta_IncrSdo_Acum, vpor_CumpAcum, vSdoafecha, vSdo_MetaFecha, 'No existe información del reporte del cierre diario de la sucursal';
					
					
			
			end if
			
			ELSE
			
				RETURN '00000006',vfecha, vsucursal, vtpo_reg, vIncre_SdoDia, vMeta_Incre_SdoDia, vpor_CumpDia, vIncr_SdoAcumulado, 
							  vMeta_IncrSdo_Acum, vpor_CumpAcum, vSdoafecha, vSdo_MetaFecha, 'tipo de usuario no valido';
				
							
				
		end if	

	ELIF (v_sEstatus = '') OR (v_sEstatus IS NULL) THEN
        LET cod_ret = '00002';
		LET mensaje = 'Parámetro de servicio no establecido';
    ELSE
		LET cod_ret = '00003';
		LET mensaje = 'Servicio no disponible';
	END IF;			

	 IF cod_ret <> '00000000' THEN
	 
		RETURN cod_ret,vfecha, vsucursal, vtpo_reg, vIncre_SdoDia, vMeta_Incre_SdoDia, vpor_CumpDia, vIncr_SdoAcumulado, 
							  vMeta_IncrSdo_Acum, vpor_CumpAcum, vSdoafecha, vSdo_MetaFecha, mensaje;
	 
	 end IF


END;
END	PROCEDURE;