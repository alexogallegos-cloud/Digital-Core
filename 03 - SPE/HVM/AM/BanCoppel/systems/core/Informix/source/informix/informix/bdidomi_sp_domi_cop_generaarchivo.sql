CREATE PROCEDURE "informix".sp_domi_cop_generaarchivo(cNombreArchivo CHAR(20), cIdRuta CHAR(2))
RETURNING CHAR(5) AS codret;

	DEFINE viSqlErr 		INTEGER;
	DEFINE cRuta 			CHAR(100);
	DEFINE vsCodRet			CHAR(5);
	DEFINE vsSQL 			CHAR(2204);
	DEFINE vsSQL1 			CHAR(100);
	DEFINE vsSQL2 			CHAR(2004);
	DEFINE vsSQL3 			CHAR(100);
	DEFINE vsArchTemp 		CHAR(23);
	DEFINE vsArchTemp1 		CHAR(23);
	DEFINE vsUsoFutBanc 	CHAR(12);
	DEFINE cHora			CHAR(8);
	DEFINE cFechaArchivoOUT	CHAR(15);
	DEFINE iPaso			SMALLINT;
	DEFINE cRutaIfx 		CHAR(100);
	DEFINE cMensaje			VARCHAR(40);
	DEFINE cFechaCargo		CHAR(8);
	DEFINE iRechazadosImp	INTEGER;
	DEFINE iTotalMovtos		INTEGER;
	DEFINE iConsecutivo		INTEGER;
	DEFINE cConsecutivo		CHAR(6);
	DEFINE cTipoReg			CHAR(1); 
	--DEFINE cConsecuti       CHAR(6); 
	DEFINE cFechaCarg       CHAR(8); 
	DEFINE cFechaAbo        CHAR(8); 
	DEFINE cTpoCtaCar       CHAR(2); 
	DEFINE cCveBanCar       CHAR(3); 
	DEFINE cCtaCargo        CHAR(20);
	DEFINE cRfcCargo        CHAR(13);
	DEFINE cNomCargo        CHAR(50);
	DEFINE cCtaAbono        CHAR(20);
	DEFINE cImpOper         CHAR(15);
	DEFINE cImpIva          CHAR(15);
	DEFINE cRefNume         CHAR(7);
	DEFINE cRefLeyen        CHAR(40);
	DEFINE cRefServ         CHAR(40);
	DEFINE cRefTitServ		CHAR(40);
	DEFINE cRefTitSer       CHAR(40);
	DEFINE cAccion          CHAR(1);
	DEFINE cReintCta        CHAR(1); 
	DEFINE cEstatus         CHAR(2); 
	DEFINE cCausaRech       CHAR(50);
	DEFINE iContador		INTEGER;
	DEFINE numcte_tdc       CHAR(9);

	--INICIALIZACION DE VARIABLES
	LET viSqlErr 			= 0;
	LET cRuta 				= '';
	LET vsCodRet 			= '';
	LET vsSQL 				= '';
	LET vsSQL1 				= '';
	LET vsSQL2 				= '';
	LET vsSQL3 				= '';
	LET vsArchTemp 			= '';
	LET vsArchTemp1 		= '';
	LET vsUsoFutBanc 		= '';
	LET cHora				= TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H:%M:%S');
	LET cFechaArchivoOUT	= YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||SUBSTR(cHora,1,2)||SUBSTR(cHora,4,2)||SUBSTR(cHora,7,2)||'_';
	LET iPaso				= 0;
	LET cRutaIfx 			= '';
	LET cMensaje 			= 'ERROR EN PASO: ';
	LET cFechaCargo 		= '';
	LET iRechazadosImp		= 0;
	LET iTotalMovtos		= 0;
	LET iConsecutivo		= 0;
	LET cConsecutivo		= '';
	LET cTipoReg			= '';
	--LET cConsecuti          = '';
	LET cFechaCarg          = '';
	LET cFechaAbo           = '';
	LET cTpoCtaCar          = '';
	LET cCveBanCar          = '';
	LET cCtaCargo           = '';
	LET cRfcCargo           = '';
	LET cNomCargo           = '';
	LET cCtaAbono           = '';
	LET cImpOper            = '';
	LET cImpIva             = '';
	LET cRefNume            = '';
	LET cRefLeyen           = '';
	LET cRefServ            = '';
	LET cRefTitServ			= '';
	LET cRefTitSer          = '';
	LET cAccion             = '';
	LET cReintCta           = '';
	LET cEstatus            = '';
	LET cCausaRech          = '';
	LET iContador           = 0;
	LET numcte_tdc          = '';
	

	--SET DEBUG FILE TO "/home/sysdomi/sp_domi_cop_generaarchivo.out";
	--TRACE ON;
	
BEGIN


	ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado.
		IF viSqlErr <> 0 THEN
		
			INSERT INTO dom_errores(fecha_error,hora_error,cod_error,nombre_arch,sp_llamado,mensaje_error,user_insert,fecha_insert)
			VALUES (CURRENT,CURRENT HOUR TO FRACTION,viSqlErr,cNombreArchivo,'sp_domi_cop_generaarchivo',cMensaje||iPaso,USER,CURRENT);	
		
		RETURN viSqlErr;
	END IF;		
	END EXCEPTION;
	
	ON EXCEPTION IN(-668) SET viSqlErr	
	
		INSERT INTO dom_errores(fecha_error,hora_error,cod_error,nombre_arch,sp_llamado,mensaje_error,user_insert,fecha_insert)
		VALUES (CURRENT,CURRENT HOUR TO FRACTION,viSqlErr,cNombreArchivo,'sp_domi_cop_generaarchivo',cMensaje||iPaso,USER,CURRENT);
			
	IF iPaso NOT IN(7,8,9) THEN 
		LET vsCodRet = viSqlErr;
		RETURN vsCodRet;
	END IF;
	END EXCEPTION WITH RESUME;

	SET ISOLATION TO DIRTY READ; 
	SET LOCK MODE TO WAIT 3;

	SELECT valor 
	INTO cRutaIfx
	FROM dom_parametros WHERE cod_param = '44';

	SELECT valor
	INTO numcte_tdc 
	FROM dom_parametros WHERE cod_param = '36';
	
	IF (cRutaIfx IS NULL) OR (cRutaIfx = "")THEN
		--DESARROLLO
		--LET cRutaIfx = '/informix/bin/dbaccess';
		--PRODUCCION
		LET cRutaIfx = '/ifxsif01/bin/dbaccess';
		
		--EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("02400") INTO v_cod_ret, sDescMensajeError;
		--RETURN v_cod_ret, sDescMensajeError;
	END IF;

	
	--Se le quitan espacion en blanco a nombre de archivo
	LET cNombreArchivo = TRIM(cNombreArchivo);
	
	TRUNCATE TABLE tmp_archivo;
	SELECT COUNT (*) INTO iContador FROM bdidomi:dom_cte_encabezado WHERE nombre_arch = cNombreArchivo;
	
		IF iContador > 0 THEN
	
			SELECT valor INTO cRuta FROM bdidomi:dom_parametros WHERE cod_param = cIdRuta;

			IF cRuta IS NOT NULL THEN
			--Selecciona el repositorio del archivo a generar.
			
				--Genera archivo.
				LET vsArchTemp = cFechaArchivoOUT||'tmp1.txt';
				LET vsArchTemp1 = cFechaArchivoOUT||'tmp2.txt';
			
				--VALIDA SI ES ARCHIVO DE OTROS BANCOS
				IF SUBSTR(cNombreArchivo, 11, 1) = 'D' AND SUBSTR(cNombreArchivo,2,9) != numcte_tdc  THEN
						SELECT LIMIT 1 fecha_cargo
						INTO cFechaCargo FROM bdidomi:dom_cte_detalle WHERE nombre_arch = cNombreArchivo;
						
							--Conteo operaciones rechazadas
						SELECT COUNT(*) 
						INTO iTotalMovtos FROM bdidomi:dom_cte_detalle WHERE fecha_cargo = cFechaCargo
						AND	tipo_registro_cce = '02' AND estatus = '02' AND comision_cobrada IS NULL AND iva_cobrado IS NULL AND SUBSTR(nombre_arch,2,9) != numcte_tdc;
						 
							
						LET iPaso = 1;
						INSERT INTO tmp_archivo ( id, rec )
						SELECT 1 AS id, (tipo_registro || num_cte || cuenta_abono || LPAD(num_operaciones::INTEGER + iTotalMovtos, 8, '0') || fecha_inicial || fecha_final ||'|') AS rec FROM bdidomi:dom_cte_encabezado WHERE nombre_arch = cNombreArchivo;	
						--NORMAL
						LET iPaso = 2;
						INSERT INTO tmp_archivo ( id, rec )
					    SELECT 2 AS id,(tipo_registro||consecutivo||fecha_cargo ||fecha_abono ||tipo_cta_cargo ||cve_banco_cargo ||cuenta_cargo ||rfc_cargo ||
						nombre_cargo ||cuenta_abono||imp_operacion||imp_iva||ref_numerica||ref_leyenda||ref_servicio||ref_titular_serv||accion||
						reintentar_cuenta||estatus||causa_rechazo||'|') AS rec
						FROM bdidomi:dom_cte_detalle WHERE nombre_arch = cNombreArchivo;
	
						LET iTotalMovtos = 0;

						SELECT COUNT(*) INTO iConsecutivo FROM tmp_archivo WHERE id = 2;

							FOREACH
								SELECT tipo_registro, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, cuenta_cargo, rfc_cargo,
								nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv, accion,
								reintentar_cuenta, estatus, causa_rechazo
								INTO cTipoReg, cFechaCarg, cFechaAbo, cTpoCtaCar, cCveBanCar, cCtaCargo, cRfcCargo, cNomCargo, cCtaAbono,
								cImpOper, cImpIva, cRefNume, cRefLeyen, cRefServ, cRefTitServ, cAccion, cReintCta, cEstatus, cCausaRech
								FROM bdidomi:dom_cte_detalle WHERE fecha_cargo = cFechaCargo
								AND tipo_registro_cce = '02' AND estatus = '02' AND comision_cobrada IS NULL AND iva_cobrado IS NULL  AND SUBSTR(nombre_arch,2,9) != numcte_tdc
									
								LET iTotalMovtos = iTotalMovtos + 1;
								
								LET cConsecutivo = LPAD(iConsecutivo + iTotalMovtos, 6, '0');

								INSERT INTO tmp_archivo( id, rec ) 
								   VALUES( 2, cTipoReg || cConsecutivo ||cFechaCarg ||cFechaAbo ||cTpoCtaCar ||cCveBanCar ||cCtaCargo ||cRfcCargo ||
										cNomCargo ||cCtaAbono ||cImpOper ||cImpIva ||cRefNume ||cRefLeyen ||cRefServ ||cRefTitServ ||cAccion ||
										cReintCta ||cEstatus ||cCausaRech ||'|');


								LET iRechazadosImp = iRechazadosImp + cImpOper;
									
							END FOREACH;

						--NORMAL
						INSERT INTO tmp_archivo ( id, rec )
                        SELECT 3 AS id, (tipo_registro||LPAD(num_operaciones::INTEGER + iTotalMovtos, 8, '0')||LPAD(imp_operaciones::INTEGER + iRechazadosImp, 18, '0')||num_oper_pend||imp_oper_pend||
							   num_oper_apli||imp_oper_apli||LPAD(num_oper_rech::INTEGER + iTotalMovtos, 8 , '0')||LPAD(imp_oper_rech::INTEGER + iRechazadosImp, 18, '0') ||
							   --'                                                                                                                                                                                                                                             |' ) AS rec
							   '|' ) AS rec
						FROM bdidomi:dom_cte_sumario WHERE nombre_arch = cNombreArchivo;
						
				ELSE
				--ARCHIVO BANCOPPEL
					LET iPaso = 3;
					INSERT INTO tmp_archivo
					SELECT id, rec
					FROM 
                    TABLE(MULTISET(
					--SELECT 1 AS id, (tipo_registro || num_cte || cuenta_abono || num_operaciones || fecha_inicial || fecha_final ||'                                                                                                                                                                                                                                                                                     |') AS rec FROM bdidomi:dom_cte_encabezado WHERE nombre_arch = cNombreArchivo
					SELECT 1 AS id, (tipo_registro || num_cte || cuenta_abono || num_operaciones || fecha_inicial || fecha_final ||'|') AS rec FROM bdidomi:dom_cte_encabezado WHERE nombre_arch = cNombreArchivo
                    UNION 
					SELECT 2 AS id,(tipo_registro||consecutivo||fecha_cargo ||fecha_abono ||tipo_cta_cargo ||cve_banco_cargo ||cuenta_cargo ||rfc_cargo ||
						   nombre_cargo ||cuenta_abono||imp_operacion||imp_iva||ref_numerica||ref_leyenda||ref_servicio||ref_titular_serv||accion||
						   reintentar_cuenta||estatus||causa_rechazo||'|') AS rec
					FROM bdidomi:dom_cte_detalle WHERE nombre_arch = cNombreArchivo
					UNION 
					SELECT 3 AS id, (tipo_registro||num_operaciones||imp_operaciones||num_oper_pend||imp_oper_pend||
						   num_oper_apli||imp_oper_apli||num_oper_rech||imp_oper_rech||
						   --'                                                                                                                                                                                                                                             |' ) AS rec
						   '|' ) AS rec
					FROM bdidomi:dom_cte_sumario WHERE nombre_arch = cNombreArchivo));
					
				END IF;	
		
				LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM (vsArchTemp) || ' DELIMITER ' || ''']''';
				LET vsSQL2 = ' SELECT rec FROM tmp_archivo ORDER BY rowid';

				LET vsSQL3 = ' " > '|| TRIM(cRuta) || cFechaArchivoOUT||'.sql';
				LET vsSQL1 = TRIM(vsSQL1);
				LET vsSQL3 = TRIM(vsSQL3);
				LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;	
				--Verifica que no este vacia la consulta.
				IF ( vsSQL <> '' ) THEN
					SYSTEM TRIM(vsSQL);
					
					LET iPaso = 4;
					--Permiso para la creacion de archivo.					
					LET vsSQL = TRIM(cRutaIfx)||' bdidomi ' || TRIM(cRuta) || cFechaArchivoOUT||'.sql > '||TRIM(cRuta)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
					SYSTEM vsSQL;
					
					LET iPaso = 5;				
					--Elimina el caracter delimitador '?'.
					LET vsSQL =  "sed 's/]$//g' " || TRIM(cRuta) || TRIM (vsArchTemp) || " > " || TRIM(cRuta) || TRIM (vsArchTemp1);
					SYSTEM vsSQL;


					LET iPaso = 6;
					--Elimina el caracter delimitador 'x'.				
					LET vsSQL =  "sed 's/|$//g' " || TRIM(cRuta) || TRIM (vsArchTemp1) || " > " || TRIM(cRuta) || TRIM (cNombreArchivo);
					SYSTEM vsSQL;
					
					LET iPaso = 7;
					--Operacion exitosa "Archivo Generado".
					--se dan permiso a todos para el archivo 
					LET vsSQL = 'chmod 755 ' || TRIM(cRuta) || TRIM (cNombreArchivo);
					SYSTEM vsSQL ;
					
					LET iPaso = 8;
					--Borra el archivo temporal.
					LET vsSQL = 'rm ' || TRIM(cRuta) || TRIM(vsArchTemp);
					SYSTEM vsSQL;
					
					LET iPaso = 9;
					--Borra el archivo temporal1.				
					LET vsSQL = 'rm ' || TRIM(cRuta) || TRIM(vsArchTemp1);
					SYSTEM vsSQL;
					
					LET iPaso =10;	
					--Borra el archivo de control.
					LET vsSQL = 'rm ' || TRIM(cRuta) || cFechaArchivoOUT||'.sql';
					SYSTEM vsSQL;
					
					LET iPaso = 11;	
					--Borra el archivo .out
					LET vsSQL = 'rm ' ||TRIM(cRuta)||TRIM(cFechaArchivoOUT)||'.out';
					SYSTEM vsSQL;
					
					LET iPaso = 12;	
					--LET vsSQL = 'cp ' || TRIM(cRuta) || TRIM (cNombreArchivo)  ||' '|| TRIM(cRuta)|| TRIM (cNombreArchivo)  ||'.resp';
					--SYSTEM vsSQL;	
					
					--Borrar diagonales del archivo.
					--LET vsSQL = 'grep -lr -e "1" ' || TRIM(cRuta) || TRIM (cNombreArchivo)  ||'.resp | xargs sed ''s/\\\\/\\/g'' > '|| TRIM(cRuta) || 
					--TRIM (cNombreArchivo);
					--SYSTEM vsSQL;
					
					--LET vsSQL = '';
					--LET vsSQL = 'rm '|| TRIM(cRuta) || TRIM (cNombreArchivo)  ||'.resp';
					--SYSTEM vsSQL;
					
					LET vsCodRet = '00000';
				ELSE
					--No fue posible generar el archivo.
					LET vsCodRet = '01002';
				END IF;
			ELSE
			--El Id proporcionado no fue localizado.
			LET vsCodRet = '01001';
			END IF;
		ELSE
			--El nombre del archivo proporcionado no fue localizado.
			LET vsCodRet = '01000';
		END IF;

		RETURN vsCodRet;

END;
END PROCEDURE;