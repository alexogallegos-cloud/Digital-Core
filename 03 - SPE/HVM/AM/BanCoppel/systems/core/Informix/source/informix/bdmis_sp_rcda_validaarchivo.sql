CREATE PROCEDURE "informix".sp_rcda_validaarchivo()
RETURNING CHAR (06) as cod_ret,
		  CHAR (80) as mensaje;
		  
--variables de retorno
	DEFINE	cod_ret				CHAR (06);
	DEFINE	mensaje				CHAR (80);
	
--variables de control de errores
	DEFINE  SQL_ERR				INTEGER;
	DEFINE  ISAM_ERR			INTEGER;
	DEFINE  ERROR_INFO			VARCHAR(80);
	DEFINE	vpaso				INTEGER;
	
--variables de proceso
	DEFINE	dfecha				DATE;
	DEFINE	vfecha				CHAR (08);
	DEFINE	vnombrearchivo		CHAR (35);
	DEFINE	vclave				CHAR (01);
	DEFINE	vnum_solicitud		CHAR (12);
	DEFINE	vsuc_tienda			CHAR (04);
	DEFINE	vpromotor			CHAR (08);
	DEFINE	vcliente_cand_club	CHAR (01);
	DEFINE	vCompraClub			CHAR (01);
	DEFINE	vfechageneracion	CHAR (10);
	DEFINE	vnumero				CHAR (01);
	DEFINE	vesfecha			CHAR (01);
	DEFINE	vfecha_ret			DATE ;
	
	DEFINE	vnombre_cliente		Char(20);	
	DEFINE	vap_paterno			Char(15);	
	DEFINE	vap_materno			Char(15);	
	DEFINE	vfecha_nacimiento	Char(10);
	DEFINE	Vfecha_inser		CHAR(10);
	DEFINE	Vfecha_apertura		CHAR(10);
	DEFINE	Vfecha_primercompra CHAR(10);
	
BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET cod_ret    = SQL_ERR;
      LET mensaje  = ERROR_INFO || ' sp_rcda_validaarchivo en paso ' || vpaso;
	  insert into mi_rcda_cierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
	  select fecha_ant,'F',cod_ret, mensaje  from bdmis:mi_fechas;
      RETURN cod_ret, mensaje;
   END EXCEPTION;
   
   --set debug file TO "gli_validaarchivo.out";
  -- trace on;
   
   let vpaso = 0;
   let cod_ret = '00000';
   let mensaje = 'PROCESO EXITOSO';
   
   SELECT fecha_ant into dfecha FROM bdmis:mi_fechas; --fecha del dia anterior 
   
   let vfecha = LPAD(DAY(dfecha),2,'0') || LPAD( MONTH(dfecha),2,'0') || YEAR(dfecha);
   
   let vnombrearchivo = 'BCPLRCD_' ||vfecha;
   
   DELETE FROM mi_rcda_cifrascontrol WHERE archivo = vnombrearchivo AND fecha = dfecha;
   FOREACH cursor1 WITH HOLD for
	   SELECT clave, num_solicitud, suc_tienda, promotor, cliente_cand_club, compraClub, fechageneracion, nombre_cliente, ap_paterno, ap_materno, fecha_nacimiento, fecha_inser,fecha_apertura, fecha_primercompra 
	   INTO vclave,	vnum_solicitud, vsuc_tienda, vpromotor, vcliente_cand_club, vCompraClub, vfechageneracion, vnombre_cliente, vap_paterno, vap_materno, vfecha_nacimiento, vfecha_inser,vfecha_apertura, vfecha_primercompra 
	   FROM mi_rcda_infocoppel_paso
	   
	   IF (SELECT COUNT(*) FROM mi_rcda_cifrascontrol WHERE archivo = vnombrearchivo AND fecha = dfecha ) = 0 THEN
		
			INSERT INTO mi_rcda_cifrascontrol (archivo, fecha, Total_registros) VALUES ( vnombrearchivo, dfecha,1);
			
			if vclave =' ' THEN
			
				UPDATE mi_rcda_cifrascontrol set Total_Solicitud = Total_Solicitud + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;				
				
				execute PROCEDURE "informix".sp_rcda_esnumerico(vnum_solicitud)
				into vnumero ;
				IF	vnumero = 'F' THEN				
				
					UPDATE mi_rcda_cifrascontrol set Total_Solicitud_err = Total_Solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
					CONTINUE FOREACH;
				
				END IF
				
				execute PROCEDURE "informix".sp_rcda_esnumerico(vsuc_tienda)
				into vnumero ;
				IF	vnumero = 'F' THEN				
				
					UPDATE mi_rcda_cifrascontrol set Total_Solicitud_err = Total_Solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
					CONTINUE FOREACH;
				
				END IF
				
				execute PROCEDURE "informix".sp_rcda_esnumerico(vpromotor)
				into vnumero ;
				IF	vnumero = 'F' THEN				
				
					UPDATE mi_rcda_cifrascontrol set Total_Solicitud_err = Total_Solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
					CONTINUE FOREACH;
				
				END IF
				
				if vcliente_cand_club <> ' ' then 
				
					UPDATE mi_rcda_cifrascontrol set Total_Solicitud_err = Total_Solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
					CONTINUE FOREACH;
				
				END IF
				
				if vCompraClub <> ' ' then 
				
					UPDATE mi_rcda_cifrascontrol set Total_Solicitud_err = Total_Solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
					CONTINUE FOREACH;
				
				END IF
				
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfechageneracion)
				INTO vesfecha , vfecha_ret ;
				IF vesfecha = 'F' THEN
				
					UPDATE mi_rcda_cifrascontrol set Total_Solicitud_err = Total_Solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
					CONTINUE FOREACH;
				
				END IF	
	--nombre_cliente, ap_paterno, ap_materno, fecha_nacimiento
				IF vnombre_cliente IS NULL THEN
				
					UPDATE mi_rcda_cifrascontrol set Total_Solicitud_err = Total_Solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
					CONTINUE FOREACH;
					
				END IF	
					
				IF vap_paterno IS NULL THEN
				
					UPDATE mi_rcda_cifrascontrol set Total_Solicitud_err = Total_Solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
					CONTINUE FOREACH;
					
				END IF	
				
				IF  vap_materno IS NULL THEN
				
					UPDATE mi_rcda_cifrascontrol set Total_Solicitud_err = Total_Solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
					CONTINUE FOREACH;
					
				END IF
					
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_nacimiento)
				INTO vesfecha , vfecha_ret ;
				IF vesfecha = 'F' THEN
				
					UPDATE mi_rcda_cifrascontrol set Total_Solicitud_err = Total_Solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
					CONTINUE FOREACH;
				
				END IF		
				--fecha_inser
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_inser)
				INTO vesfecha , vfecha_ret ;
				IF vesfecha = 'F' THEN
				
					UPDATE mi_rcda_cifrascontrol set Total_Solicitud_err = Total_Solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
					CONTINUE FOREACH;
				
				END IF		
				
				
				elif vclave = 'M' THEN
						
						UPDATE mi_rcda_cifrascontrol set total_cambio_solicitud = total_cambio_solicitud + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;				
						
						execute PROCEDURE "informix".sp_rcda_esnumerico(vnum_solicitud)
						into vnumero ;
						IF	vnumero = 'F' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_cambio_solicitud_err = total_cambio_solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						execute PROCEDURE "informix".sp_rcda_esnumerico(vsuc_tienda)
						into vnumero ;
						IF	vnumero = 'F' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_cambio_solicitud_err = total_cambio_solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						execute PROCEDURE "informix".sp_rcda_esnumerico(vpromotor)
						into vnumero ;
						IF	vnumero = 'F' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_cambio_solicitud_err = total_cambio_solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						if vcliente_cand_club <> ' ' then 
						
							UPDATE mi_rcda_cifrascontrol set total_cambio_solicitud_err = total_cambio_solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						if vCompraClub <> ' ' then 
						
							UPDATE mi_rcda_cifrascontrol set total_cambio_solicitud_err = total_cambio_solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfechageneracion)
						INTO vesfecha , vfecha_ret ;
						IF vesfecha = 'F' THEN
						
							UPDATE mi_rcda_cifrascontrol set total_cambio_solicitud_err = total_cambio_solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF	

						--fecha_inser
						EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_inser)
						INTO vesfecha , vfecha_ret ;
						IF vesfecha = 'F' THEN
						
							UPDATE mi_rcda_cifrascontrol set total_cambio_solicitud_err = total_cambio_solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
				
				
				elif vclave = 'A' THEN
				
						UPDATE mi_rcda_cifrascontrol set total_alta = total_alta + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;				
						
						execute PROCEDURE "informix".sp_rcda_esnumerico(vnum_solicitud)
						into vnumero ;
						IF	vnumero = 'F' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_alta_err = total_alta_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						execute PROCEDURE "informix".sp_rcda_esnumerico(vsuc_tienda)
						into vnumero ;
						IF	vnumero = 'F' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_alta_err = total_alta_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						execute PROCEDURE "informix".sp_rcda_esnumerico(vpromotor)
						into vnumero ;
						IF	vnumero = 'F' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_alta_err = total_alta_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						if vcliente_cand_club not in ('S','N') then 
						
							UPDATE mi_rcda_cifrascontrol set total_alta_err = total_alta_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						if vCompraClub not in ('S','N') then 
						
							UPDATE mi_rcda_cifrascontrol set total_alta_err = total_alta_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfechageneracion)
						INTO vesfecha , vfecha_ret ;
						IF vesfecha = 'F' THEN
						
							UPDATE mi_rcda_cifrascontrol set total_alta_err = total_alta_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF	
						
						--fecha_apertura
						EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_apertura)
						INTO vesfecha , vfecha_ret ;
						IF vesfecha = 'F' THEN
						
							UPDATE mi_rcda_cifrascontrol set total_alta_err = total_alta_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF							
						
				
				elif vclave = 'V' THEN
				
						UPDATE mi_rcda_cifrascontrol set total_compra = total_compra + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;				
						
						IF	vnum_solicitud <> ' ' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_compra_err = total_compra_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						execute PROCEDURE "informix".sp_rcda_esnumerico(vsuc_tienda)
						into vnumero ;
						IF	vnumero = 'F' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_compra_err = total_compra_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						
						/*IF	vpromotor <> ' ' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_compra_err = total_compra_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF*/
						
						if vcliente_cand_club <> ' ' then 
						
							UPDATE mi_rcda_cifrascontrol set total_compra_err = total_compra_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						if vCompraClub <> ' ' then 
						
							UPDATE mi_rcda_cifrascontrol set total_compra_err = total_compra_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfechageneracion)
						INTO vesfecha , vfecha_ret ;
						IF vesfecha = 'F' THEN
						
							UPDATE mi_rcda_cifrascontrol set total_compra_err = total_compra_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF	
						
						--vfecha_primercompra
						EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_primercompra)
						INTO vesfecha , vfecha_ret ;
						IF vesfecha = 'F' THEN
						
							UPDATE mi_rcda_cifrascontrol set total_compra_err = total_compra_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
				
				elif vclave = 'G' THEN	

						UPDATE mi_rcda_cifrascontrol set total_club = total_club + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;				
						
						IF	vnum_solicitud <> ' ' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_club_err = total_club_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						execute PROCEDURE "informix".sp_rcda_esnumerico(vsuc_tienda)
						into vnumero ;
						IF	vnumero = 'F' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_club_err = total_club_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						execute PROCEDURE "informix".sp_rcda_esnumerico(vpromotor)
						into vnumero ;
						IF	vnumero = 'F' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_club_err = total_club_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						if vcliente_cand_club not in ('S','N') then 
						
							UPDATE mi_rcda_cifrascontrol set total_club_err = total_club_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						if vCompraClub not in ('S','N') then 
						
							UPDATE mi_rcda_cifrascontrol set total_club_err = total_club_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfechageneracion)
						INTO vesfecha , vfecha_ret ;
						IF vesfecha = 'F' THEN
						
							UPDATE mi_rcda_cifrascontrol set total_club_err = total_club_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF	

						--vfecha_primercompra
						EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_primercompra)
						INTO vesfecha , vfecha_ret ;
						IF vesfecha = 'F' THEN
						
							UPDATE mi_rcda_cifrascontrol set total_club_err = total_club_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
							
			
			END IF
		
		ELSE
		
			UPDATE mi_rcda_cifrascontrol set Total_registros = Total_registros + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
			
			if vclave =' ' THEN
			
				UPDATE mi_rcda_cifrascontrol set Total_Solicitud = Total_Solicitud + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;				
				
				execute PROCEDURE "informix".sp_rcda_esnumerico(vnum_solicitud)
				into vnumero ;
				IF	vnumero = 'F' THEN				
				
					UPDATE mi_rcda_cifrascontrol set Total_Solicitud_err = Total_Solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
					CONTINUE FOREACH;
				
				END IF
				
				execute PROCEDURE "informix".sp_rcda_esnumerico(vsuc_tienda)
				into vnumero ;
				IF	vnumero = 'F' THEN				
				
					UPDATE mi_rcda_cifrascontrol set Total_Solicitud_err = Total_Solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
					CONTINUE FOREACH;
				
				END IF
				
				execute PROCEDURE "informix".sp_rcda_esnumerico(vpromotor)
				into vnumero ;
				IF	vnumero = 'F' THEN				
				
					UPDATE mi_rcda_cifrascontrol set Total_Solicitud_err = Total_Solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
					CONTINUE FOREACH;
				
				END IF
				
				if vcliente_cand_club <> ' ' then 
				
					UPDATE mi_rcda_cifrascontrol set Total_Solicitud_err = Total_Solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
					CONTINUE FOREACH;
				
				END IF
				
				if vCompraClub <> ' ' then 
				
					UPDATE mi_rcda_cifrascontrol set Total_Solicitud_err = Total_Solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
					CONTINUE FOREACH;
				
				END IF
				
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfechageneracion)
				INTO vesfecha , vfecha_ret ;
				IF vesfecha = 'F' THEN
				
					UPDATE mi_rcda_cifrascontrol set Total_Solicitud_err = Total_Solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
					CONTINUE FOREACH;
				
				END IF	
				--vfecha_inser	
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_inser)
				INTO vesfecha , vfecha_ret ;
				IF vesfecha = 'F' THEN
				
					UPDATE mi_rcda_cifrascontrol set Total_Solicitud_err = Total_Solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
					CONTINUE FOREACH;
				
				END IF	
					
				elif vclave = 'M' THEN
						
						UPDATE mi_rcda_cifrascontrol set total_cambio_solicitud = total_cambio_solicitud + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;				
						
						execute PROCEDURE "informix".sp_rcda_esnumerico(vnum_solicitud)
						into vnumero ;
						IF	vnumero = 'F' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_cambio_solicitud_err = total_cambio_solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						execute PROCEDURE "informix".sp_rcda_esnumerico(vsuc_tienda)
						into vnumero ;
						IF	vnumero = 'F' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_cambio_solicitud_err = total_cambio_solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						execute PROCEDURE "informix".sp_rcda_esnumerico(vpromotor)
						into vnumero ;
						IF	vnumero = 'F' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_cambio_solicitud_err = total_cambio_solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						if vcliente_cand_club <> ' ' then 
						
							UPDATE mi_rcda_cifrascontrol set total_cambio_solicitud_err = total_cambio_solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						if vCompraClub <> ' ' then 
						
							UPDATE mi_rcda_cifrascontrol set total_cambio_solicitud_err = total_cambio_solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfechageneracion)
						INTO vesfecha , vfecha_ret ;
						IF vesfecha = 'F' THEN
						
							UPDATE mi_rcda_cifrascontrol set total_cambio_solicitud_err = total_cambio_solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF		
						
						--vfecha_inser
						EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_inser)
						INTO vesfecha , vfecha_ret ;
						IF vesfecha = 'F' THEN
						
							UPDATE mi_rcda_cifrascontrol set total_cambio_solicitud_err = total_cambio_solicitud_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
				
				
				elif vclave = 'A' THEN
				
						UPDATE mi_rcda_cifrascontrol set total_alta = total_alta + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;				
						
						execute PROCEDURE "informix".sp_rcda_esnumerico(vnum_solicitud)
						into vnumero ;
						IF	vnumero = 'F' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_alta_err = total_alta_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						execute PROCEDURE "informix".sp_rcda_esnumerico(vsuc_tienda)
						into vnumero ;
						IF	vnumero = 'F' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_alta_err = total_alta_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						execute PROCEDURE "informix".sp_rcda_esnumerico(vpromotor)
						into vnumero ;
						IF	vnumero = 'F' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_alta_err = total_alta_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						if vcliente_cand_club not in ('S','N') then 
						
							UPDATE mi_rcda_cifrascontrol set total_alta_err = total_alta_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						if vCompraClub not in ('S','N') then 
						
							UPDATE mi_rcda_cifrascontrol set total_alta_err = total_alta_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfechageneracion)
						INTO vesfecha , vfecha_ret ;
						IF vesfecha = 'F' THEN
						
							UPDATE mi_rcda_cifrascontrol set total_alta_err = total_alta_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF	
						--vfecha_apertura
						EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_apertura)
						INTO vesfecha , vfecha_ret ;
						IF vesfecha = 'F' THEN
						
							UPDATE mi_rcda_cifrascontrol set total_alta_err = total_alta_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
				
				elif vclave = 'V' THEN
				
						UPDATE mi_rcda_cifrascontrol set total_compra = total_compra + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;				
						
						IF	vnum_solicitud <> ' ' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_compra_err = total_compra_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						execute PROCEDURE "informix".sp_rcda_esnumerico(vsuc_tienda)
						into vnumero ;
						IF	vnumero = 'F' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_compra_err = total_compra_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						
						IF	vpromotor <> ' ' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_compra_err = total_compra_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						if vcliente_cand_club <> ' ' then 
						
							UPDATE mi_rcda_cifrascontrol set total_compra_err = total_compra_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						if vCompraClub <> ' ' then 
						
							UPDATE mi_rcda_cifrascontrol set total_compra_err = total_compra_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfechageneracion)
						INTO vesfecha , vfecha_ret ;
						IF vesfecha = 'F' THEN
						
							UPDATE mi_rcda_cifrascontrol set total_compra_err = total_compra_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF	
						--vfecha_primercompra
						EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_primercompra)
						INTO vesfecha , vfecha_ret ;
						IF vesfecha = 'F' THEN
						
							UPDATE mi_rcda_cifrascontrol set total_compra_err = total_compra_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
				
				elif vclave = 'G' THEN	

						UPDATE mi_rcda_cifrascontrol set total_club = total_club + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;				
						
						IF	vnum_solicitud <> ' ' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_club_err = total_club_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						execute PROCEDURE "informix".sp_rcda_esnumerico(vsuc_tienda)
						into vnumero ;
						IF	vnumero = 'F' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_club_err = total_club_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						execute PROCEDURE "informix".sp_rcda_esnumerico(vpromotor)
						into vnumero ;
						IF	vnumero = 'F' THEN				
						
							UPDATE mi_rcda_cifrascontrol set total_club_err = total_club_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						if vcliente_cand_club not in ('S','N') then 
						
							UPDATE mi_rcda_cifrascontrol set total_club_err = total_club_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						if vCompraClub not in ('S','N') then 
						
							UPDATE mi_rcda_cifrascontrol set total_club_err = total_club_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
						
						EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfechageneracion)
						INTO vesfecha , vfecha_ret ;
						IF vesfecha = 'F' THEN
						
							UPDATE mi_rcda_cifrascontrol set total_club_err = total_club_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF		
						
						--vfecha_primercompra
						EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_primercompra)
						INTO vesfecha , vfecha_ret ;
						IF vesfecha = 'F' THEN
						
							UPDATE mi_rcda_cifrascontrol set total_club_err = total_club_err + 1 WHERE archivo = vnombrearchivo AND fecha = dfecha;
							CONTINUE FOREACH;
						
						END IF
			
			END IF		
	   
	   END IF
	END FOREACH
	
	 RETURN cod_ret, mensaje;
	
END
END PROCEDURE

	
;