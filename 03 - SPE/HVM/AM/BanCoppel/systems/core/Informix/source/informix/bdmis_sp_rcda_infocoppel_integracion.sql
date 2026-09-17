CREATE PROCEDURE "informix".sp_rcda_infocoppel_integracion ()
RETURNING CHAR (06) AS cod_ret,
		  CHAR (80) AS mensaje;
		  
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
	DEFINE	vnumcte				CHAR (20);
	DEFINE	vsuc_tienda			CHAR (04);
	DEFINE	vpromotor			CHAR (08);
	DEFINE	vcliente_cand_club	CHAR (01);
	DEFINE	vCompraClub			CHAR (01);
	DEFINE	vfechageneracion	CHAR (10);
	DEFINE	vintegridad			CHAR (01);
	DEFINE	vnumero				CHAR (01);
	DEFINE	vesfecha			CHAR (01);
	DEFINE	vfecha_ret			DATE ;
	DEFINE	vfecha_ret2			DATE ;
	DEFINE	vfecha_ret3			DATE ;
	DEFINE	vsql				CHAR (800);
	DEFINE	vruta				CHAR (0120);
	
	DEFINE	vnombre_cliente		Char(20);	
	DEFINE	vap_paterno			Char(15);	
	DEFINE	vap_materno			Char(15);	
	DEFINE	vfecha_nacimiento	Char(10);
	
	DEFINE	vfecha_inser		CHAR (10);
	DEFINE	vfecha_apertura		CHAR (10);
	DEFINE	vfecha_primercompra	CHAR (10);
	
	
	
BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET cod_ret    = SQL_ERR;
      LET mensaje  = ERROR_INFO || ' sp_rcda_infocoppel_integracion en paso ' || vpaso;
	  insert into mi_rcda_cierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
	  select fecha_ant,'F',cod_ret, mensaje  from bdmis:mi_fechas;
      RETURN cod_ret, mensaje;
   END EXCEPTION;

   let vpaso = 0;
   let cod_ret = '00000';
   let mensaje = 'PROCESO EXITOSO';
   let vintegridad = 'V';
   
   SET ISOLATION TO dirty READ;
   
   SELECT fecha_ant into dfecha FROM bdmis:mi_fechas; --fecha del dia anterior 
   
   let vfecha = LPAD(DAY(dfecha),2,'0') || LPAD( MONTH(dfecha),2,'0') || YEAR(dfecha);
   
   let vnombrearchivo = 'BCPLRCD_' ||vfecha;
   
   SELECT trim(descripcion) into vruta FROM mi_param WHERE parametro = 6111;
   
   truncate table "informix".mi_rcda_infocoppel;
   
   let vpaso = 1;
      FOREACH cursor1 WITH HOLD for
	   SELECT clave, num_solicitud,numcte ,suc_tienda, promotor, cliente_cand_club, compraClub, fechageneracion,fecha_apertura,	fecha_primercompra, nombre_cliente, ap_paterno, ap_materno, fecha_nacimiento, fecha_inser
	   INTO vclave,	vnum_solicitud,vnumcte ,vsuc_tienda, vpromotor, vcliente_cand_club, vCompraClub, vfechageneracion, vfecha_apertura,	vfecha_primercompra,vnombre_cliente, vap_paterno, vap_materno, vfecha_nacimiento, vfecha_inser
	   FROM mi_rcda_infocoppel_paso WHERE clave <> ' '
		
		
		IF vclave = 'M' THEN
				let vpaso = 2;
				let vintegridad = 'V';
				execute PROCEDURE "informix".sp_rcda_esnumerico(vnum_solicitud)
				into vnumero ;
				IF	vnumero = 'F' THEN				
					let vintegridad = 'F';
				END IF
				let vpaso = 3;
				execute PROCEDURE "informix".sp_rcda_esnumerico(vsuc_tienda)
				into vnumero ;
				IF	vnumero = 'F' THEN				
					let vintegridad = 'F';
				END IF
				let vpaso = 4;
				execute PROCEDURE "informix".sp_rcda_esnumerico(vpromotor)
				into vnumero ;
				IF	vnumero = 'F' THEN				
					let vintegridad = 'F';
				END IF
				let vpaso = 5;
				if vcliente_cand_club <> ' ' then 
					let vintegridad = 'F';
				END IF
				let vpaso = 6;
				if vCompraClub <> ' ' then 
					let vintegridad = 'F';
				END IF
				let vpaso = 7;
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfechageneracion)
				INTO vesfecha , vfecha_ret ;
				IF vesfecha = 'F' THEN
					let vintegridad = 'F';
				END IF
				--vfecha_inser
				let vpaso = 8;
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_inser)
				INTO vesfecha , vfecha_ret3 ;
				IF vesfecha = 'F' THEN
					let vintegridad = 'F';
				END IF
				
				let vpaso = 8;
				INSERT INTO mi_rcda_infocoppel (nombrearchivo,integridad,Clave,suc_tienda,Num_solicitud,promotor,cliente_cand_club,CompraClub,fechageneracion,fecha_inser) 
					VALUES (vnombrearchivo,vintegridad,vClave,LPAD(trim(vsuc_tienda),4,'0'),vNum_solicitud,vpromotor,vcliente_cand_club,vCompraClub,vfecha_ret,vfecha_ret3);
			
			ELIF vclave = 'A' THEN
				let vpaso = 9;
				let vintegridad = 'V';
				execute PROCEDURE "informix".sp_rcda_esnumerico(vnum_solicitud)
				into vnumero ;
				IF	vnumero = 'F' THEN				
					let vintegridad = 'F';
				END IF
				let vpaso = 10;
				execute PROCEDURE "informix".sp_rcda_esnumerico(vsuc_tienda)
				into vnumero ;
				IF	vnumero = 'F' THEN				
					let vintegridad = 'F';
				END IF
				let vpaso = 11;
				execute PROCEDURE "informix".sp_rcda_esnumerico(vpromotor)
				into vnumero ;
				IF vnumero = 'F' THEN
					let vintegridad = 'F';
				END IF
				let vpaso = 12;
				if vcliente_cand_club not in ('S','N') then 
					let vintegridad = 'F';
				END IF
				let vpaso = 13;
				if vCompraClub not in ('S','N') then 
					let vintegridad = 'F';
				END IF
				let vpaso = 14;
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfechageneracion)
				INTO vesfecha , vfecha_ret ;
				IF vesfecha = 'F' THEN
					let vintegridad = 'F';				
				END IF	
				
				let vpaso = 15;
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_apertura)
				INTO vesfecha , vfecha_apertura ;
				IF vesfecha = 'F' THEN
					let vintegridad = 'F';				
				END IF					
			
				
				let vpaso = 16;
				INSERT INTO mi_rcda_infocoppel (nombrearchivo,integridad,Clave,suc_tienda,Num_solicitud,numcte,promotor,cliente_cand_club,CompraClub,fechageneracion,fecha_apertura) 
					VALUES (vnombrearchivo,vintegridad,vClave,LPAD(trim(vsuc_tienda),4,'0'),vNum_solicitud,vnumcte,vpromotor,vcliente_cand_club,vCompraClub,vfecha_ret,vfecha_apertura);
					
			ELIF vclave = 'V' THEN
				let vpaso = 17;
				let vintegridad = 'V';
				IF	vnum_solicitud <> ' ' THEN				
					let vintegridad = 'F';
				END IF
				let vpaso = 18;
				execute PROCEDURE "informix".sp_rcda_esnumerico(vsuc_tienda)
				into vnumero ;
				IF	vnumero = 'F' THEN				
					let vintegridad = 'F';
				END IF				
				let vpaso = 19;
				IF	vpromotor <> ' ' THEN				
					let vintegridad = 'F';
				END IF
				let vpaso = 20;
				if vcliente_cand_club <> ' ' then 
					let vintegridad = 'F';
				END IF
				let vpaso = 21;
				if vCompraClub <> ' ' then 
					let vintegridad = 'F';
				END IF
				let vpaso = 22;
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfechageneracion)
				INTO vesfecha , vfecha_ret ;
				IF vesfecha = 'F' THEN
					let vintegridad = 'F';
				END IF	
				
				let vpaso = 23;
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_primercompra)
				INTO vesfecha , vfecha_primercompra ;
				IF vesfecha = 'F' THEN
					let vintegridad = 'F';
				END IF				
				
				let vpaso = 24;
				INSERT INTO mi_rcda_infocoppel (nombrearchivo,integridad,Clave,suc_tienda,Num_solicitud,numcte,promotor,cliente_cand_club,CompraClub,fechageneracion,fecha_primercompra) 
					VALUES (vnombrearchivo,vintegridad,vClave,LPAD(trim(vsuc_tienda),4,'0'),vNum_solicitud,vnumcte,vpromotor,vcliente_cand_club,vCompraClub,vfecha_ret,vfecha_primercompra);
					
			ELIF vclave = 'G' THEN
				let vpaso = 25;
				let vintegridad = 'V';
				IF	vnum_solicitud <> ' ' THEN				
					let vintegridad = 'F';
				END IF
				let vpaso = 26;
				execute PROCEDURE "informix".sp_rcda_esnumerico(vsuc_tienda)
				into vnumero ;
				IF	vnumero = 'F' THEN				
					let vintegridad = 'F';
				END IF
				let vpaso = 27;
				execute PROCEDURE "informix".sp_rcda_esnumerico(vpromotor)
				into vnumero ;
				IF	vnumero = 'F' THEN				
					let vintegridad = 'F';
				END IF
				let vpaso = 28;
				if vcliente_cand_club not in ('S','N') then 
					let vintegridad = 'F';
				END IF
				let vpaso = 29;
				if vCompraClub not in ('S','N') then 
					let vintegridad = 'F';
				END IF
				let vpaso = 30;
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfechageneracion)
				INTO vesfecha , vfecha_ret ;
				IF vesfecha = 'F' THEN
					let vintegridad = 'F';
				END IF	
				let vpaso = 31;
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_primercompra)
				INTO vesfecha , vfecha_primercompra ;
				IF vesfecha = 'F' THEN
					let vintegridad = 'F';
				END IF
				
				let vpaso = 32;
				INSERT INTO mi_rcda_infocoppel (nombrearchivo,integridad,Clave,suc_tienda,Num_solicitud,numcte,promotor,cliente_cand_club,CompraClub,fechageneracion,fecha_primercompra) 
					VALUES (vnombrearchivo,vintegridad,vClave,LPAD(trim(vsuc_tienda),4,'0'),vNum_solicitud,vnumcte,vpromotor,vcliente_cand_club,vCompraClub,vfecha_ret, vfecha_primercompra);
					
			END IF
   
	  END FOREACH
	  
	  
	FOREACH cursor1 WITH HOLD for
	   SELECT clave, num_solicitud,numcte ,suc_tienda, promotor, cliente_cand_club, compraClub, fechageneracion,fecha_apertura,	fecha_primercompra, nombre_cliente, ap_paterno, ap_materno, fecha_nacimiento, fecha_inser
	   INTO vclave,	vnum_solicitud,vnumcte ,vsuc_tienda, vpromotor, vcliente_cand_club, vCompraClub, vfechageneracion, vfecha_apertura,	vfecha_primercompra,vnombre_cliente, vap_paterno, vap_materno, vfecha_nacimiento, vfecha_inser
	   FROM mi_rcda_infocoppel_paso WHERE clave = ' ' and tipo_solicitud = '0'
	   
	  	IF vclave = ' ' THEN
				let vintegridad = 'V';
				let vpaso = 33;
				execute PROCEDURE "informix".sp_rcda_esnumerico(vnum_solicitud)
				into vnumero ;
				IF	vnumero = 'F' THEN					
					let vintegridad = 'F';				
				END IF
				let vpaso = 34;
				execute PROCEDURE "informix".sp_rcda_esnumerico(vsuc_tienda)
				into vnumero ;
				IF	vnumero = 'F' THEN				
					let vintegridad = 'F';				
				END IF
				let vpaso = 34;
				execute PROCEDURE "informix".sp_rcda_esnumerico(vpromotor)
				into vnumero ;
				IF	vnumero = 'F' THEN				
					let vintegridad = 'F';				
				END IF
				let vpaso = 35;
				if vcliente_cand_club <> ' ' then 				
					let vintegridad = 'F';				
				END IF
				let vpaso = 36;
				if vCompraClub <> ' ' then 				
					let vintegridad = 'F';				
				END IF
				let vpaso = 37;
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfechageneracion)
				INTO vesfecha , vfecha_ret ;
				IF vesfecha = 'F' THEN				
					let vintegridad = 'F';				
				END IF	
				let vpaso = 38;
				
				/* *  ################ * */
				let vpaso = 39;
				IF vnombre_cliente IS NULL THEN				
					let vintegridad = 'F';						
				END IF	
					
				let vpaso = 40;	
				IF vap_paterno IS NULL THEN				
					let vintegridad = 'F';						
				END IF	
				
				let vpaso = 41;
				IF vap_materno IS NULL THEN				
					let vintegridad = 'F';						
				END IF
					
				let vpaso = 42;	
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_nacimiento)
				INTO vesfecha , vfecha_ret2 ;
				IF vesfecha = 'F' THEN				
					let vintegridad = 'F';					
				END IF
				
				--vfecha_inser
				let vpaso = 43;	
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_inser)
				INTO vesfecha , vfecha_ret3 ;
				IF vesfecha = 'F' THEN				
					let vintegridad = 'F';					
				END IF
				
				/* *  ################ * */
				let vpaso = 44;
				INSERT INTO mi_rcda_infocoppel (nombrearchivo,integridad,Clave,suc_tienda,Num_solicitud,promotor,cliente_cand_club,CompraClub,fechageneracion,nombre_cliente,ap_paterno,ap_materno,fecha_nacimiento, fecha_inser) 
					VALUES (vnombrearchivo,vintegridad,vClave,LPAD(trim(vsuc_tienda),4,'0'),vNum_solicitud,vpromotor,vcliente_cand_club,vCompraClub,vfecha_ret,vnombre_cliente,vap_paterno,vap_materno,vfecha_ret2,vfecha_ret3);
				
	  
		END if;
		
	END FOREACH	
	let vpaso = 46;
	--UPDATE mi_rcda_bitacoraarchivo SET fecha_hora_carga_tabla =  (SELECT DBINFO('utc_to_datetime', sh_curtime) FROM sysmaster:"informix".sysshmvals), fecha_hora_fin_proceso = (SELECT DBINFO('utc_to_datetime', sh_curtime) FROM sysmaster:"informix".sysshmvals), proceso = 'C' WHERE nombrearchivo = 'BCPLRCD_'|| vfecha  AND fecha_archivo =  dfecha ;	
		
	
	  
	--  let vpaso = 48;
	  IF (select COUNT(*) FROM mi_rcda_infocoppel_his WHERE nombrearchivo =  vnombrearchivo ) = 0 THEN
		let vpaso = 47;
			insert into mi_rcda_infocoppel_his (consecutivo,nombrearchivo,integridad,Clave,suc_tienda,Num_solicitud,numcte,promotor,cliente_cand_club,CompraClub,fechageneracion, fecha_inser, fecha_apertura, fecha_primercompra,nombre_cliente,ap_paterno,ap_materno,fecha_nacimiento)
			SELECT consecutivo,nombrearchivo,integridad,Clave,suc_tienda,Num_solicitud,numcte,promotor,cliente_cand_club,CompraClub,fechageneracion, fecha_inser, fecha_apertura, fecha_primercompra,nombre_cliente,ap_paterno,ap_materno,fecha_nacimiento FROM mi_rcda_infocoppel;
	  ELSE
	  let vpaso = 48;
			DELETE FROM mi_rcda_infocoppel_his WHERE nombrearchivo =  vnombrearchivo;
			
			insert into mi_rcda_infocoppel_his (consecutivo,nombrearchivo,integridad,Clave,suc_tienda,Num_solicitud,numcte,promotor,cliente_cand_club,CompraClub,fechageneracion, fecha_inser, fecha_apertura, fecha_primercompra,nombre_cliente,ap_paterno,ap_materno,fecha_nacimiento)
			SELECT consecutivo,nombrearchivo,integridad,Clave,suc_tienda,Num_solicitud,numcte,promotor,cliente_cand_club,CompraClub,fechageneracion, fecha_inser, fecha_apertura, fecha_primercompra,nombre_cliente,ap_paterno,ap_materno,fecha_nacimiento FROM mi_rcda_infocoppel;
	  
	  END IF
	  
	RETURN cod_ret, mensaje;
END
END PROCEDURE;