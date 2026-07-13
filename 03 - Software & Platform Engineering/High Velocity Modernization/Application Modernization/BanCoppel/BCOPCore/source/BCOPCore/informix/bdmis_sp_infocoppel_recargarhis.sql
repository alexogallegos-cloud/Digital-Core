create procedure "informix".sp_infocoppel_recargarhis(pfecha_ini DATE , pfecha_fin DATE)
RETURNING	CHAR	(06) as cod_ret,
			CHAR 	(80) as mensaje;
	
--	variables de retorno 
	DEFINE	cod_ret			CHAR (06);
	DEFINE	mensaje			CHAR (80);
	
--DEFINICION DE VARIABLES DE CONTROL DE ERRORES 
	DEFINE  SQL_ERR          INTEGER;   
	DEFINE  ERROR_INFO       VARCHAR(180);	
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE	vpaso			 INTEGER;
	
--definicion de variables de proceso
	DEFINE	vruta			 	CHAR(150);
	DEFINE	vnombrearchivo		CHAR(185);
	DEFINE	vnombrearchivo2		CHAR(35);
	DEFINE	vsql				CHAR(1120);
	
--variables de proceso
	DEFINE	dfecha				DATE;
	DEFINE	vfecha				CHAR (08);	
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
      LET mensaje  = ERROR_INFO || ' sp_infocoppel_recargarhis en paso ' || vpaso;	  
      RETURN cod_ret, mensaje;
   END EXCEPTION;
   
   --set debug file to 'sp_infocoppel_recargarhis.OUT';
   --trace on;
   
   set ISOLATION to dirty read;
	let vpaso = 0;
   --obtenemos el parametro de la ruta 
   SELECT trim(descripcion) into vruta FROM mi_param WHERE parametro = 6111;  
   let vpaso = 1;
	--	carga la lista de archivos en una tabla 
	EXECUTE	PROCEDURE "informix".sp_carga_lista_archivos(vruta)	
	 INTO cod_ret , mensaje;
	IF cod_ret <> '000000' THEN
		RETURN cod_ret , mensaje;	
	END IF
	let vpaso = 2;
	WHILE pfecha_ini < pfecha_fin
		--armado de nombre de archivo BCPLRCD_06082014.txt
		let vnombrearchivo = TRIM(vruta) ||'BCPLRCD_' || LPAD(DAY(pfecha_ini),2,'0') || LPAD( MONTH(pfecha_ini),2,'0') || YEAR(pfecha_ini)|| '.txt';
		let vnombrearchivo2 = 'BCPLRCD_' || LPAD(DAY(pfecha_ini),2,'0') || LPAD( MONTH(pfecha_ini),2,'0') || YEAR(pfecha_ini);
	let vpaso = 3;	
		IF (SELECT COUNT(linea) FROM cop_tmp_busca_archivo WHERE linea = 'BCPLRCD_' || LPAD(DAY(pfecha_ini),2,'0') || LPAD( MONTH(pfecha_ini),2,'0') || YEAR(pfecha_ini)|| '.txt' ) = 1 THEN
			TRUNCATE TABLE mi_rcda_infocoppel_recargarhis;		
			let vpaso = 4;		
					LET vsql = 'echo "load FROM '||vnombrearchivo ||' INSERT INTO mi_rcda_infocoppel_recargarhis;">'||TRIM(vruta)||'query.sql';
				   let vsql = vsql;
				   let vpaso = 5;
		   SYSTEM vsql;  
		   
		   let vpaso = 6;
		   LET vsql = 'dbaccess bdmis ' || trim(vruta) || 'query.sql';
		   let vpaso = 7;
		   SYSTEM vsql;	
			--siclo para la carga de la info en tabla historica
			
					IF (select COUNT(*) FROM mi_rcda_infocoppel_his WHERE nombrearchivo =  vnombrearchivo2 ) <> 0 THEN	   
					   DELETE FROM mi_rcda_infocoppel_his WHERE nombrearchivo =  vnombrearchivo2;				
					END IF
			let vpaso = 8;
			    FOREACH cursor1 WITH HOLD for
					SELECT clave, num_solicitud,numcte ,suc_tienda, promotor, cliente_cand_club, compraClub, fechageneracion,fecha_apertura,	fecha_primercompra, nombre_cliente, ap_paterno, ap_materno, fecha_nacimiento, fecha_inser
				   INTO vclave,	vnum_solicitud,vnumcte ,vsuc_tienda, vpromotor, vcliente_cand_club, vCompraClub, vfechageneracion, vfecha_apertura,	vfecha_primercompra,vnombre_cliente, vap_paterno, vap_materno, vfecha_nacimiento, vfecha_inser
				   FROM mi_rcda_infocoppel_recargarhis WHERE clave <> ' '				   
					 let vpaso = 9;  

					
					IF vclave = 'M' THEN
						let vpaso = 10;
						let vintegridad = 'V';
						execute PROCEDURE "informix".sp_rcda_esnumerico(vnum_solicitud)
						into vnumero ;
						IF	vnumero = 'F' THEN				
							let vintegridad = 'F';
						END IF
						let vpaso = 11;
						execute PROCEDURE "informix".sp_rcda_esnumerico(vsuc_tienda)
						into vnumero ;
						IF	vnumero = 'F' THEN				
							let vintegridad = 'F';
						END IF
						let vpaso = 12;
						execute PROCEDURE "informix".sp_rcda_esnumerico(vpromotor)
						into vnumero ;
						IF	vnumero = 'F' THEN				
							let vintegridad = 'F';
						END IF
						let vpaso = 13;
						if vcliente_cand_club <> ' ' then 
							let vintegridad = 'F';
						END IF
						let vpaso = 14;
						if vCompraClub <> ' ' then 
							let vintegridad = 'F';
						END IF
						let vpaso = 15;
						EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfechageneracion)
						INTO vesfecha , vfecha_ret ;
						IF vesfecha = 'F' THEN
							let vintegridad = 'F';
						END IF
						--vfecha_inser
						let vpaso = 16;
						EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_inser)
						INTO vesfecha , vfecha_ret3 ;
						IF vesfecha = 'F' THEN
							let vintegridad = 'F';
						END IF
						
						let vpaso = 17;
						INSERT INTO mi_rcda_infocoppel_his (nombrearchivo,integridad,Clave,suc_tienda,Num_solicitud,promotor,cliente_cand_club,CompraClub,fechageneracion,fecha_inser) 
							VALUES (vnombrearchivo2,vintegridad,vClave,LPAD(trim(vsuc_tienda),4,'0'),vNum_solicitud,vpromotor,vcliente_cand_club,vCompraClub,vfecha_ret,vfecha_ret3);
			
			ELIF vclave = 'A' THEN
				let vpaso = 18;
				let vintegridad = 'V';
				execute PROCEDURE "informix".sp_rcda_esnumerico(vnum_solicitud)
				into vnumero ;
				IF	vnumero = 'F' THEN				
					let vintegridad = 'F';
				END IF
				let vpaso = 19;
				execute PROCEDURE "informix".sp_rcda_esnumerico(vsuc_tienda)
				into vnumero ;
				IF	vnumero = 'F' THEN				
					let vintegridad = 'F';
				END IF
				let vpaso = 20;
				execute PROCEDURE "informix".sp_rcda_esnumerico(vpromotor)
				into vnumero ;
				IF vnumero = 'F' THEN
					let vintegridad = 'F';
				END IF
				let vpaso = 21;
				if vcliente_cand_club not in ('S','N') then 
					let vintegridad = 'F';
				END IF
				let vpaso = 22;
				if vCompraClub not in ('S','N') then 
					let vintegridad = 'F';
				END IF
				let vpaso = 23;
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfechageneracion)
				INTO vesfecha , vfecha_ret ;
				IF vesfecha = 'F' THEN
					let vintegridad = 'F';				
				END IF	
				
				let vpaso = 24;
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_apertura)
				INTO vesfecha , vfecha_apertura ;
				IF vesfecha = 'F' THEN
					let vintegridad = 'F';				
				END IF					
			
				
				let vpaso = 25;
				let vnombrearchivo2 = vnombrearchivo2;
				let vClave = vClave;
				let vfecha_ret = vfecha_ret;
				INSERT INTO mi_rcda_infocoppel_his (nombrearchivo,integridad,Clave,suc_tienda,Num_solicitud,numcte,promotor,cliente_cand_club,CompraClub,fechageneracion,fecha_apertura) 
					VALUES (vnombrearchivo2,vintegridad,vClave,LPAD(trim(vsuc_tienda),4,'0'),vNum_solicitud,vnumcte,vpromotor,vcliente_cand_club,vCompraClub,vfecha_ret,vfecha_apertura);
					
			ELIF vclave = 'V' THEN
				let vpaso = 26;
				let vintegridad = 'V';
				IF	vnum_solicitud <> ' ' THEN				
					let vintegridad = 'F';
				END IF
				let vpaso = 27;
				execute PROCEDURE "informix".sp_rcda_esnumerico(vsuc_tienda)
				into vnumero ;
				IF	vnumero = 'F' THEN				
					let vintegridad = 'F';
				END IF				
				let vpaso = 28;
				IF	vpromotor <> ' ' THEN				
					let vintegridad = 'F';
				END IF
				let vpaso = 29;
				if vcliente_cand_club <> ' ' then 
					let vintegridad = 'F';
				END IF
				let vpaso = 30;
				if vCompraClub <> ' ' then 
					let vintegridad = 'F';
				END IF
				let vpaso = 31;
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfechageneracion)
				INTO vesfecha , vfecha_ret ;
				IF vesfecha = 'F' THEN
					let vintegridad = 'F';
				END IF	
				
				let vpaso = 32;
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_primercompra)
				INTO vesfecha , vfecha_primercompra ;
				IF vesfecha = 'F' THEN
					let vintegridad = 'F';
				END IF				
				
				let vpaso = 33;
				INSERT INTO mi_rcda_infocoppel_his (nombrearchivo,integridad,Clave,suc_tienda,Num_solicitud,numcte,promotor,cliente_cand_club,CompraClub,fechageneracion,fecha_primercompra) 
					VALUES (vnombrearchivo2,vintegridad,vClave,LPAD(trim(vsuc_tienda),4,'0'),vNum_solicitud,vnumcte,vpromotor,vcliente_cand_club,vCompraClub,vfecha_ret,vfecha_primercompra);
					
			ELIF vclave = 'G' THEN
				let vpaso = 34;
				let vintegridad = 'V';
				IF	vnum_solicitud <> ' ' THEN				
					let vintegridad = 'F';
				END IF
				let vpaso = 35;
				execute PROCEDURE "informix".sp_rcda_esnumerico(vsuc_tienda)
				into vnumero ;
				IF	vnumero = 'F' THEN				
					let vintegridad = 'F';
				END IF
				let vpaso = 36;
				execute PROCEDURE "informix".sp_rcda_esnumerico(vpromotor)
				into vnumero ;
				IF	vnumero = 'F' THEN				
					let vintegridad = 'F';
				END IF
				let vpaso = 37;
				if vcliente_cand_club not in ('S','N') then 
					let vintegridad = 'F';
				END IF
				let vpaso = 38;
				if vCompraClub not in ('S','N') then 
					let vintegridad = 'F';
				END IF
				let vpaso = 39;
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfechageneracion)
				INTO vesfecha , vfecha_ret ;
				IF vesfecha = 'F' THEN
					let vintegridad = 'F';
				END IF	
				let vpaso = 40;
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_primercompra)
				INTO vesfecha , vfecha_primercompra ;
				IF vesfecha = 'F' THEN
					let vintegridad = 'F';
				END IF
				
				let vpaso = 41;
				INSERT INTO mi_rcda_infocoppel_his (nombrearchivo,integridad,Clave,suc_tienda,Num_solicitud,numcte,promotor,cliente_cand_club,CompraClub,fechageneracion,fecha_primercompra) 
					VALUES (vnombrearchivo2,vintegridad,vClave,LPAD(trim(vsuc_tienda),4,'0'),vNum_solicitud,vnumcte,vpromotor,vcliente_cand_club,vCompraClub,vfecha_ret, vfecha_primercompra);
					
			END IF
   
	  END FOREACH
	  
	  
	FOREACH cursor1 WITH HOLD for
	   SELECT clave, num_solicitud,numcte ,suc_tienda, promotor, cliente_cand_club, compraClub, fechageneracion,fecha_apertura,	fecha_primercompra, nombre_cliente, ap_paterno, ap_materno, fecha_nacimiento, fecha_inser
	   INTO vclave,	vnum_solicitud,vnumcte ,vsuc_tienda, vpromotor, vcliente_cand_club, vCompraClub, vfechageneracion, vfecha_apertura,	vfecha_primercompra,vnombre_cliente, vap_paterno, vap_materno, vfecha_nacimiento, vfecha_inser
	   FROM mi_rcda_infocoppel_recargarhis WHERE clave = ' ' and tipo_solicitud = '0'
	   
	  	IF vclave = ' ' THEN
				let vintegridad = 'V';
				let vpaso = 42;
				execute PROCEDURE "informix".sp_rcda_esnumerico(vnum_solicitud)
				into vnumero ;
				IF	vnumero = 'F' THEN					
					let vintegridad = 'F';				
				END IF
				let vpaso = 43;
				execute PROCEDURE "informix".sp_rcda_esnumerico(vsuc_tienda)
				into vnumero ;
				IF	vnumero = 'F' THEN				
					let vintegridad = 'F';				
				END IF
				let vpaso = 44;
				execute PROCEDURE "informix".sp_rcda_esnumerico(vpromotor)
				into vnumero ;
				IF	vnumero = 'F' THEN				
					let vintegridad = 'F';				
				END IF
				let vpaso = 45;
				if vcliente_cand_club <> ' ' then 				
					let vintegridad = 'F';				
				END IF
				let vpaso = 46;
				if vCompraClub <> ' ' then 				
					let vintegridad = 'F';				
				END IF
				let vpaso = 47;
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfechageneracion)
				INTO vesfecha , vfecha_ret ;
				IF vesfecha = 'F' THEN				
					let vintegridad = 'F';				
				END IF	
				let vpaso = 48;
				
				/* *  ################ * */
				let vpaso = 49;
				IF vnombre_cliente IS NULL THEN				
					let vintegridad = 'F';						
				END IF	
					
				let vpaso = 50;	
				IF vap_paterno IS NULL THEN				
					let vintegridad = 'F';						
				END IF	
				
				let vpaso = 51;
				IF vap_materno IS NULL THEN				
					let vintegridad = 'F';						
				END IF
					
				let vpaso = 52;	
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_nacimiento)
				INTO vesfecha , vfecha_ret2 ;
				IF vesfecha = 'F' THEN				
					let vintegridad = 'F';					
				END IF
				
				--vfecha_inser
				let vpaso = 53;	
				EXECUTE PROCEDURE "informix".sp_rcda_validafecha(vfecha_inser)
				INTO vesfecha , vfecha_ret3 ;
				IF vesfecha = 'F' THEN				
					let vintegridad = 'F';					
				END IF
				
				/* *  ################ * */
				let vpaso = 54;
				INSERT INTO mi_rcda_infocoppel_his (nombrearchivo,integridad,Clave,suc_tienda,Num_solicitud,promotor,cliente_cand_club,CompraClub,fechageneracion,nombre_cliente,ap_paterno,ap_materno,fecha_nacimiento, fecha_inser) 
					VALUES (vnombrearchivo2,vintegridad,vClave,LPAD(trim(vsuc_tienda),4,'0'),vNum_solicitud,vpromotor,vcliente_cand_club,vCompraClub,vfecha_ret,vnombre_cliente,vap_paterno,vap_materno,vfecha_ret2,vfecha_ret3);
				
	  
		END if;
		
	END FOREACH	
					
					
					
				
		
		END IF
		
		let pfecha_ini = DATE(pfecha_ini) + 1; 
	END WHILE

	
	RETURN cod_ret , mensaje;		

END
END PROCEDURE;