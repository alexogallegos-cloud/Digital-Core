CREATE PROCEDURE "informix".sp_ctbcpl_gen_arcgeneracion_pred(pempresa CHAR(3), pfechacorte DATE, ptipocobranza CHAR(1))

-- EXECUTE PROCEDURE sp_ctbcpl_gen_arcgeneracion_pred('001', mdy('','',''), 'A');

	RETURNING CHAR(6);

	--DERINICION DE VARIABLES
	DEFINE sql_err				INTEGER;
	DEFINE isam_err				INTEGER;
	DEFINE error_info			CHAR(80);
	DEFINE cMensaje				CHAR(80);
	DEFINE cCod_ret				CHAR(6);
	DEFINE vempresa				CHAR(3);
	DEFINE vproceso				CHAR(06);
	DEFINE cruta                CHAR(100);
	DEFINE cnombre				CHAR(100);
	DEFINE cnomarchivo          CHAR(100);
	DEFINE cnomarchivo1			CHAR(100);
	DEFINE cnomarchivoEjecsq1	CHAR(100);
	DEFINE cSQL                 CHAR(30000);
	DEFINE cSQL1                CHAR(200);
	DEFINE cSQL2                CHAR(30000);
	DEFINE cSQL4                CHAR(30000);
	DEFINE cSQL3                CHAR(100);
	DEFINE cSQL5                 CHAR(30000);
	DEFINE cSqlaux				CHAR(200);
	DEFINE cempresa             CHAR(3);
	DEFINE cdelimitador         CHAR(1);
	DEFINE cCod_RetIB           CHAR(6);
	DEFINE vnumparametro        SMALLINT;
	--1728
	DEFINE vnumparametro2       SMALLINT;
	DEFINE cNumProd2			CHAR(4);
	DEFINE cNumProd				CHAR(4);
	DEFINE iPrimeraVez       	SMALLINT;
	DEFINE vday					INTEGER;
	DEFINE vnum_prod			CHAR(4);
	DEFINE vbandera				CHAR(1);
	DEFINE vContTrab			INTEGER;
    DEFINE c_tipo_producto      CHAR(2);
    DEFINE c_num_producto_2     CHAR(4);
    DEFINE c_canal              CHAR(4); 	
    DEFINE iDia_fechacorte      INTEGER;  
    DEFINE v_num_producto	    CHAR(4);
	DEFINE dt_FechaCorte        DATE;
	DEFINE ULT_PROD_PP          CHAR(4);
	DEFINE cUltProdPP           CHAR(4);
	DEFINE ContadorTDC      INTEGER;
	
	--INICIALIZACION DE VARIABLES
	LET sql_err                 = 0;
	LET isam_err                = 0;
	LET error_info              = '';
	LET cCod_Ret                = '000000';
	LET cMensaje                = 'PROCESO EXITOSO';
	LET vproceso				= '0311';
	LET vempresa				= '001';
	LET cruta                   = '';
	LET cnombre					= '';
	LET cnomarchivo             = '';
	LET cnomarchivo1			= '';
	LET cnomarchivoEjecsq1      = '';
	LET cSQL                    = '';
	LET cSQL1                   = '';
	LET cSQL2                   = '';
	LET cSQL3                   = '';
	LET cempresa                = '001';
	LET cdelimitador            = '';
	LET cCod_RetIB              = '000000';
	--1728
	LET vnumparametro2          = 0;
	LET vnumparametro          	= 0;
	LET cNumProd2           	= '';
	LET cNumProd           		= '';
	LET iPrimeraVez             = 0;
	LET cSQL4                  	= '';
	LET cSQL5                  	= '';
	let cSqlaux 				= '';
	LET vday 					= 0;
	LET vnum_prod 				= '';
	LET vbandera 				= '';
	LET vContTrab 				= 0;
    LET c_tipo_producto         = '';
	LET c_num_producto_2        = '';
	LET c_canal                 = '';
	LET iDia_fechacorte         = 0; 
	LET v_num_producto          = '';
	LET dt_FechaCorte           = pfechacorte;
	LET ULT_PROD_PP             = '7700';
	LET cUltProdPP              = '';
	LET ContadorTDC				= 0;
	
	--SET DEBUG FILE TO "/ifxsif01/macf/sp_ctbcpl_gen_arcgeneracion_pred.trc";
	--TRACE ON; 

-----------------------Descripcion de Errores controlados----------------------------
--104001	Es necesario proporcionar todos los parametros de ejecucion                     
--104002	La empresa proporcionada es invalida                                            
--104003	El tipo de campana indicado no existe                                           
--104004	No se encuentra el parametro con el caracter de separador de archivo            
--104005	No se encuentra la ruta para almacenar el archivo                               
--104006	No se encuentra el parametro para nombrar el archivo                            
--104007	Es necesario proporcionar la empresa                                            
--104008	Es necesario indicar la fecha a consultar                                       
--104009	No se encontraron clientes marcados como excluidos                              
-------------------------------------------------------------------------------------

	BEGIN
		ON EXCEPTION SET sql_err, isam_err, error_info

			LET cCod_ret = sql_err;
			LET cMensaje = error_info;
			--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa,vproceso,cCod_Ret,cMensaje,"02") INTO cCod_RetIB;
			RETURN cCod_ret;

		END EXCEPTION;

		--DIRECTIVA PARA LECTURA DE TABLAS BLOQUEADAS.
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa,vproceso,cCod_Ret,cMensaje,"01") INTO cCod_RetIB;

		LET vnumparametro = 53;

		--VALIDACION DE PARAMETROS DE ENTRADA  
		IF NVL(pempresa,'') = '' OR NVL(pfechacorte, '') = ''  OR ( NVL(pTipoCobranza,'') = '' OR  NVL(pTipoCobranza,'') NOT IN ('A','P','R','E','X','Y') ) THEN
			LET cCod_Ret = '104001';

			SELECT descripcion INTO cMensaje
			FROM "informix".cb_errores
			WHERE origen = 3
			AND codigo_error = cCod_Ret; 

			IF cMensaje IS NULL THEN 
				LET cMensaje = ''; 
			END IF;

			--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa,vproceso,cCod_Ret,cMensaje,"02") INTO cCod_RetIB;

			RETURN cCod_Ret;
		END IF;

		--VALIDACION DE LA EMPRESA
		SELECT empresa  INTO cempresa
		FROM bdinteg: "informix".si_empresas
		WHERE empresa = pempresa; 

		IF NVL (cempresa, '') = '' THEN
			LET cCod_Ret= '104002';

			SELECT descripcion INTO cMensaje
			FROM "informix".cb_errores
			WHERE origen = 3
			AND codigo_error = cCod_Ret;

			IF cMensaje IS NULL THEN 
				LET cMensaje = ''; 
			END IF;

			--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa,vproceso,cCod_Ret,cMensaje,"02") INTO cCod_RetIB;

			RETURN cCod_Ret;
		END IF;

		--OBTENER CARACTER DELIMITADOR
		SELECT valor_alfabetico INTO cdelimitador
		FROM "informix".cb_param_campania
		WHERE empresa = pempresa
		AND tipo_campania = 1
		AND grupo_parametro = 'ARCHIVOS'
		AND num_parametro = 2;

		--VALIDA QUE EXISTA EL CARACTER
		IF NVL(cDelimitador,'') = '' THEN
			LET cCod_Ret= '104004';

			SELECT descripcion INTO cMensaje
			FROM "informix".cb_errores
			WHERE origen = 3
			AND codigo_error = cCod_Ret;

			IF cMensaje IS NULL THEN 
				LET cMensaje = ""; 
			END IF;

			--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa,vproceso,cCod_Ret,cMensaje,"02") INTO cCod_RetIB;

			RETURN cCod_Ret;
		END IF;

		--OBTENER RUTA DEL ARCHIVO
		SELECT valor_alfabetico INTO cruta
		FROM "informix".cb_param_campania
		WHERE empresa = pempresa
		AND tipo_campania = 1
		AND grupo_parametro = 'ARCHIVOS'
		AND num_parametro = 3;


		--VALIDA QUE EXISTA LA CARPETA
		IF NVL (cruta,'') = '' THEN
			LET cCod_Ret= '104005';

			SELECT descripcion INTO cMensaje
			FROM "informix".cb_errores
			WHERE origen = 3
			AND codigo_error = cCod_Ret;

			IF cMensaje IS NULL THEN 
				LET cMensaje = ""; 
			END IF;

			--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa,vproceso,cCod_Ret,cMensaje,"02") INTO cCod_RetIB;

			RETURN cCod_Ret;
		END IF;

		LET  pfechacorte = DATE(1);
		

		IF ptipocobranza = 'A' THEN
			 

			--Cambio, obtener la fecha mÃÂ¡xima dependiendo del producto, con el dÃÂ­a se elige cual			   
			SELECT MAX(fecha_insert) INTO pfechacorte
			FROM "informix".cb_cat_directorio_cte
			WHERE empresa = pempresa
			AND tipo_cobranza = ptipocobranza;

			LET vday = DAY(pfechacorte);

			FOREACH WITH HOLD
				SELECT valor_alfabetico INTO vnum_prod
				FROM "informix".cb_param_campania 
				WHERE empresa = pempresa AND tipo_campania = 61
				AND grupo_parametro = ptipocobranza
				AND valor_numerico = vday
				

				IF vnum_prod IS NULL THEN LET vnum_prod = ''; END IF;

				SELECT descripcion INTO vbandera FROM bdicobranza:"informix".cb_param WHERE empresa = pempresa AND valor = vnum_prod;

				IF vbandera IS NULL THEN LET vbandera = ''; END IF;

				IF vbandera = 'S' THEN
					LET vContTrab = vContTrab + 1;
				END IF;
			END FOREACH;

			IF vContTrab = 0 THEN
				RETURN cCod_ret;
			END IF;
		END IF;

		IF ptipocobranza = 'X' OR ptipocobranza = 'Y' THEN
			IF ptipocobranza = 'X' THEN 
				LET ptipocobranza = 'A'; 
			ELSE 
				LET ptipocobranza = 'R'; 
			END IF;

			IF  ptipocobranza = 'A'  THEN
			 
				 
				SELECT MAX(fecha_insert) INTO pfechacorte
				FROM "informix".cb_cat_directorio_cte
				WHERE empresa = pempresa
					AND tipo_cobranza = ptipocobranza;				 
					--AND num_producto = v_num_producto   --MACF
				
				
				LET vday = DAY(pfechacorte);

				select count(*) into ContadorTDC
				from bdicobranza:cb_cat_directorio_cte 
				where empresa = pempresa
					and tipo_cobranza = ptipocobranza
					and (fecha_insert = pfechacorte or fecha_reasignacion = pfechacorte);

				IF ContadorTDC > 0 THEN					

					FOREACH WITH HOLD
				
						select num_producto into v_num_producto
						from bdicobranza:cb_cat_directorio_cte 
						where empresa = pempresa
							and tipo_cobranza = ptipocobranza
							and (fecha_insert = pfechacorte or fecha_reasignacion = pfechacorte) 
						group by 1
							
						/*IF vday = 18 THEN
							let v_num_producto = '8100';
							--let pfechacorte = pfechacorte - 1 units day;
						ELIF vday = 20 THEN
							let v_num_producto = '6001';
							--let pfechacorte = pfechacorte - 1 units day;
						END IF;*/
						
							
							IF NVL(pfechacorte,"") = "" THEN
								LET cCod_Ret     = "104008";
								SELECT descripcion
								INTO cMensaje
								FROM bdicobranza:"informix".cb_errores
								WHERE origen       = 3
								AND codigo_error = cCod_Ret; 

								IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
									--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa,vproceso,cCod_Ret,cMensaje,"02") INTO cCod_RetIB;

								RETURN cCod_Ret;
							ELSE 
								LET vday = DAY(pfechacorte);
							END IF;
							
						
						FOREACH WITH HOLD
						
							SELECT canal, tipo_producto, num_producto INTO c_canal, c_tipo_producto, cNumProd --c_num_producto_2 
							FROM bdicobranza:cb_gestion_cobranza_agex
							WHERE tipo_cobranza = ptipocobranza
							AND num_producto = v_num_producto
							AND activo = '1' 
							order by canal
							

							---COMENTAR SOLO PARA PRUEBAS MACF
							--IF (DAY(TODAY) <> 21) AND (ptipocobranza = "A") THEN
							/*IF ( (DAY(TODAY) <> 21) AND (DAY(TODAY) <> 19) ) AND (ptipocobranza = "A") THEN
								LET cCod_ret = '000000';
								RETURN cCod_ret;
							END IF;*/
							
							/* MACF
							--*--
							--GENERACION DE ARCHIVOS PARA TDC,PP AGENCIA EXTERNA
							FOREACH WITH HOLD
								--SE OBTIENE EL NUMERO DEL PRODUCTO
								SELECT DISTINCT num_producto 
								INTO cNumProd
								FROM "informix".cb_cat_directorio_cte 
								WHERE empresa = '001'
								AND tipo_cobranza = ptipocobranza
								AND fecha_insert = pfechacorte
								AND canal =  c_canal --"PENT"
								ORDER BY 1
							*/
								--IF ptipocobranza = "A" THEN
									IF cNumProd = "6001" THEN
										LET vnumparametro = 53; --TDC
									ELIF cNumProd = "8100" THEN
										LET vnumparametro = 72; --TDCO  MACF
									ELSE
										CONTINUE FOREACH;
									END IF;
								/*ELSE
									--IF cNumProd = "6300" OR cNumProd = "7600" OR cNumProd = "7700" THEN 
									IF cNumProd = "6300" OR cNumProd = "7600" OR cNumProd = "7700" OR cNumProd = "6800" THEN   -- MACF
										LET vnumparametro = 55; --PP
									ELIF cNumProd = '6011' THEN -- MACF
										LET vnumparametro = 54; --REE  MACF
									ELSE
										CONTINUE FOREACH;
									END IF;
								END IF;
								*/                    
								
								--OBTENER EL NOMBRE DEL ARCHIVO
								SELECT valor_alfabetico INTO cnombre
								FROM "informix".cb_param_campania
								WHERE empresa = pempresa
								AND tipo_campania = 1
								AND grupo_parametro = 'ARCHIVOS'
								AND num_parametro = vnumparametro;

								IF NVL(cNombre,"") = "" THEN
									LET cCod_Ret = "104006";
									SELECT descripcion
									INTO cMensaje
									FROM bdicobranza:"informix".cb_errores
									WHERE origen       = 3
									AND codigo_error = cCod_Ret; 

									IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

									--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa,vproceso,cCod_Ret,cMensaje,"02") INTO cCod_RetIB;

									RETURN cCod_Ret;
								END IF;

								--VALIDAR QUE EXISTE EL ARCHIVO
								IF c_canal = 'PENT' THEN
								LET cnomarchivo1 =  TRIM(cnombre)||'Aux_' ||  ptipocobranza || to_char(pfechacorte,'%d%m%Y')||'_AE.txt';
								LET cnomarchivo =  TRIM(cnombre)||to_char(pfechacorte,'%d%m%Y')||'_AE.txt';
								ELSE
								LET cnomarchivo1 =  TRIM(cnombre)||'Aux_' ||  ptipocobranza || to_char(pfechacorte,'%d%m%Y')||'_' || TRIM(c_canal) || '.txt';
								LET cnomarchivo =  TRIM(cnombre)||to_char(pfechacorte,'%d%m%Y')||'_' || TRIM(c_canal) || '.txt';
								END IF;	
								
								
								LET cSQL1 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1)|| " DELIMITER '" || cDelimitador || "'"||'';	
								LET cSQL2 = " SELECT TO_CHAR(a.fecha_insert,'%d/%m/%Y'),a.num_producto,a.numcte,a.num_credito,"
									|| " TRIM(DECODE(a.nombre1,'',' ',a.nombre1))||' '||TRIM(DECODE(a.nombre2,'',' ',a.nombre2))||' '||TRIM(a.apell_paterno)||' '||TRIM(DECODE(a.apell_materno,'',' ',a.apell_materno)) nombre,"
									|| " e.rfc,h.correo_elec,Trim(d2.nombrecalle)||','||Trim(d.numeroextcalle)||','|| Trim(d.numerointcalle) direccion,"
									|| " d3.nombrezona,d3.poblacionzona,d1.estado,d.cod_postal,a.sucursal,TO_CHAR(a.fecha_apertura,'%d/%m/%Y'),a.saldo_vencido_final,"
									|| " a.saldo_total_final,a.monto_ult_pago,TO_CHAR(a.fecha_ult_pago,'%d/%m/%Y'),a.dias_mora,a.pago_venc,'EXT1' canal,"
									|| " a.pago_vencido1_final,a.pago_vencido2_final,a.pago_vencido3_final,a.pago_vencido4_final,a.tipo_logica"
									|| " FROM bdicobranza: cb_cat_directorio_cte a"
									|| " INNER JOIN bdinteg: si_cliente e ON e.numcte=a.numcte"
									|| " INNER JOIN bdinteg: si_ctepf b ON b.numcte=a.numcte"
									|| " INNER JOIN bdinteg: si_direcciones_actual d ON d.numcte=a.numcte and d.tipo_dir='1'"
									|| " INNER JOIN bdisolic:ss_circulo_edos d1 ON d1.empresa = '001' AND d1.clave = d.estado "
									|| " INNER JOIN bdinteg:si_catcalles d2 ON d2.numerocalle = d.numerocalle"
									|| " INNER JOIN bdinteg:si_catzonas d3 ON d3.numerociudad = d.numerociudad and d3.numerocolonia = d.numerocolonia";
								LET cSQL4 = " LEFT OUTER JOIN bdinteg: si_ingresos c ON c.numcte=a.numcte and c.sec_ingreso = (select max(sec_ingreso) from bdinteg: si_ingresos where numcte=a.numcte )"
									|| " LEFT OUTER JOIN bdinteg: si_correos h ON a.numcte=h.numcte and tipo_correo = 1 and status_correo = 'A'"
									--/* and valido=1 */--RQM 09 598"
									|| " WHERE a.tipo_cobranza ='"|| TRIM(ptipocobranza)|| "' "
									|| " AND (a.fecha_insert = mdy('"|| month(pfechacorte) || "','"|| day(pfechacorte) || "','"|| year(pfechacorte) || "') OR a.fecha_reasignacion = mdy('"|| month(pfechacorte) || "','"|| day(pfechacorte) || "','"|| year(pfechacorte) || "')) "
									--|| " AND a.tipo_logica > 0"
									|| " AND (a.status_cliente not in ('NT','EX') OR a.fecha_reasignacion = mdy('"|| month(pfechacorte) || "','"|| day(pfechacorte) || "','"|| year(pfechacorte) || "')) "
									--|| " AND a.canal = 'PENT' "
									|| " AND a.canal = '" || TRIM(c_canal) || "'"
									|| " AND a.num_producto = '"|| cNumProd || "' "|| '">'||TRIM(cRuta)||'arcgene_pred_qry_'|| TRIM(c_canal) || '.sql';

								LET cSQL = TRIM(cSQL1) || cSQL2 ;
								LET cSQL5 = cSQL4;
								LET cSQL = TRIM(cSQL) || cSQL5 ;

								-- Verifica que no este vacia la consulta.
								IF ( cSQL <> '' ) THEN 
									SYSTEM cSQL ;

									--Permiso para la creacion de archivo.
									LET cSQL = '' ;
									LET cSQL = 'chmod 777 ' || TRIM(cRuta) || "arcgene_pred_qry_"|| TRIM(c_canal) || ".sql" ;
									LET cSQL = '' ;
									LET cSql = "dbaccess bdicobranza "|| TRIM(cRuta) || "arcgene_pred_qry_"|| TRIM(c_canal) || ".sql";
									SYSTEM TRIM(cSql);

									LET cSql = cSql;
									LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cNomArchivo);
									SYSTEM cSql;

								
									--BORRADO DE TEMPORALES QUE FUERON USADOS PARA LA CREACION DE ARCHIVO
									LET cSql = '';
									LET cSQL = "rm "||TRIM(cRuta)||'arcgene_pred_qry_'|| TRIM(c_canal) || '.sql';		
									SYSTEM TRIM(cSql); 

									LET cSQL = '' ;
									LET cSQL = 'rm ' || TRIM(cruta) || TRIM(cnomarchivo1);
									SYSTEM cSQL; 
									
									LET cSqlaux = '';
									LET cSqlaux = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
									SYSTEM cSqlaux;

									LET cSql = '';
									LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
									SYSTEM cSql;
									
								END IF;
						END FOREACH;

							/*LET cSql = '';
							LET cSql = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
							SYSTEM cSql;

							LET cSql = '';
							LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
							SYSTEM cSql;*/
		
			    	END FOREACH;	
					RETURN cCod_ret;  

				ELSE	
					LET cCod_Ret     = "000000";
					RETURN cCod_ret;
				END IF;
			 -------------------------------------------------
         	ELSE    -- TIPO COB R AGEX

			
			  SELECT MAX(fecha_insert) INTO pfechacorte
			    FROM "informix".cb_cat_directorio_cte
			   WHERE empresa = pempresa
			     AND tipo_cobranza = ptipocobranza;	
			 

			   LET vday = DAY(pfechacorte);
			
			 FOREACH WITH HOLD
			
				SELECT canal, tipo_producto, num_producto INTO c_canal, c_tipo_producto, cNumProd --c_num_producto_2 
				  FROM bdicobranza:cb_gestion_cobranza_agex
				 WHERE tipo_cobranza = ptipocobranza
				   AND num_producto <> ''
				   AND activo = '1' 
				   order by canal, num_producto
				 
													  
				--LET pfechacorte = mdy(04,18,2017);

				IF NVL(pfechacorte,"") = "" THEN
					LET cCod_Ret     = "104008";
					SELECT descripcion
					INTO cMensaje
					FROM bdicobranza:"informix".cb_errores
					WHERE origen       = 3
					AND codigo_error = cCod_Ret; 

					IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
						--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa,vproceso,cCod_Ret,cMensaje,"02") INTO cCod_RetIB;

					RETURN cCod_Ret;
				END IF;

				
				--IF cNumProd = "6300" OR cNumProd = "7600" OR cNumProd = "7700" THEN 
					IF cNumProd = "6300" OR cNumProd = "7600" OR cNumProd = "7700" OR cNumProd = "6800" THEN   -- MACF
						LET vnumparametro = 55; --PP
					ELIF cNumProd = '6011' THEN -- MACF
						IF vday = 3 OR vday = 18 THEN
						   LET vnumparametro = 54; --REE  MACF
						ELSE
						   CONTINUE FOREACH;
						END IF;
					ELSE
						CONTINUE FOREACH;
					END IF;
				--END IF;

					--OBTENER EL NOMBRE DEL ARCHIVO
					SELECT valor_alfabetico INTO cnombre
					FROM "informix".cb_param_campania
					WHERE empresa = pempresa
					AND tipo_campania = 1
					AND grupo_parametro = 'ARCHIVOS'
					AND num_parametro = vnumparametro;

					IF NVL(cNombre,"") = "" THEN
						LET cCod_Ret = "104006";
						SELECT descripcion
						INTO cMensaje
						FROM bdicobranza:"informix".cb_errores
						WHERE origen       = 3
						AND codigo_error = cCod_Ret; 

						IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

						--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa,vproceso,cCod_Ret,cMensaje,"02") INTO cCod_RetIB;

						RETURN cCod_Ret;
					END IF;

					--VALIDAR QUE EXISTE EL ARCHIVO
					IF c_canal = 'PENT' THEN
					  LET cnomarchivo1 =  TRIM(cnombre)||'Aux_' ||  ptipocobranza || to_char(pfechacorte,'%d%m%Y')||'_AE.txt';
					  LET cnomarchivo =  TRIM(cnombre)||to_char(pfechacorte,'%d%m%Y')||'_AE.txt';
					ELSE
					  LET cnomarchivo1 =  TRIM(cnombre)||'Aux_' ||  ptipocobranza || to_char(pfechacorte,'%d%m%Y')||'_' || TRIM(c_canal) || '.txt';
					  LET cnomarchivo =  TRIM(cnombre)||to_char(pfechacorte,'%d%m%Y')||'_' || TRIM(c_canal) || '.txt';
					END IF;	

					LET cSQL1 = 'echo "UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1)|| " DELIMITER '" || cDelimitador || "'"||'';	
					LET cSQL2 = " SELECT TO_CHAR(a.fecha_insert,'%d/%m/%Y'),a.num_producto,a.numcte,a.num_credito,"
						|| " TRIM(DECODE(a.nombre1,'',' ',a.nombre1))||' '||TRIM(DECODE(a.nombre2,'',' ',a.nombre2))||' '||TRIM(a.apell_paterno)||' '||TRIM(DECODE(a.apell_materno,'',' ',a.apell_materno)) nombre,"
						|| " e.rfc,h.correo_elec,Trim(d2.nombrecalle)||','||Trim(d.numeroextcalle)||','|| Trim(d.numerointcalle) direccion,"
						|| " d3.nombrezona,d3.poblacionzona,d1.estado,d.cod_postal,a.sucursal,TO_CHAR(a.fecha_apertura,'%d/%m/%Y'),a.saldo_vencido_final,"
						|| " a.saldo_total_final,a.monto_ult_pago,TO_CHAR(a.fecha_ult_pago,'%d/%m/%Y'),a.dias_mora,a.pago_venc,'EXT1' canal,"
						|| " a.pago_vencido1_final,a.pago_vencido2_final,a.pago_vencido3_final,a.pago_vencido4_final,a.tipo_logica"
						|| " FROM bdicobranza: cb_cat_directorio_cte a"
						|| " INNER JOIN bdinteg: si_cliente e ON e.numcte=a.numcte"
						|| " INNER JOIN bdinteg: si_ctepf b ON b.numcte=a.numcte"
						|| " INNER JOIN bdinteg: si_direcciones_actual d ON d.numcte=a.numcte and d.tipo_dir='1'"
						|| " INNER JOIN bdisolic:ss_circulo_edos d1 ON d1.empresa = '001' AND d1.clave = d.estado "
						|| " INNER JOIN bdinteg:si_catcalles d2 ON d2.numerocalle = d.numerocalle"
						|| " INNER JOIN bdinteg:si_catzonas d3 ON d3.numerociudad = d.numerociudad and d3.numerocolonia = d.numerocolonia";
					LET cSQL4 = " LEFT OUTER JOIN bdinteg: si_ingresos c ON c.numcte=a.numcte and c.sec_ingreso = (select max(sec_ingreso) from bdinteg: si_ingresos where numcte=a.numcte )"
						|| " LEFT OUTER JOIN bdinteg: si_correos h ON a.numcte=h.numcte and tipo_correo = 1 and status_correo = 'A'"
						--/* and valido=1 */--RQM 09 598"
						|| " WHERE a.tipo_cobranza ='"||TRIM(ptipocobranza)|| "'"
						|| " AND (a.fecha_insert = mdy('"|| month(pfechacorte) || "','"|| day(pfechacorte) || "','"|| year(pfechacorte) || "') OR a.fecha_reasignacion = mdy('"|| month(pfechacorte) || "','"|| day(pfechacorte) || "','"|| year(pfechacorte) || "')) "
						--|| " AND a.tipo_logica > 0"
						|| " AND (a.status_cliente not in ('NT','EX') OR a.fecha_reasignacion = mdy('"|| month(pfechacorte) || "','"|| day(pfechacorte) || "','"|| year(pfechacorte) || "')) "
						--|| " AND a.canal = 'PENT' "
						|| " AND a.canal = '" || TRIM(c_canal) || "'"
						|| " AND a.num_producto = '"|| cNumProd || "' "|| '">'||TRIM(cRuta)||'arcgene_pred_qry_'|| TRIM(c_canal) ||'.sql';

					LET cSQL = TRIM(cSQL1) || cSQL2 ;
					LET cSQL5 = cSQL4;
					LET cSQL = TRIM(cSQL) || cSQL5 ;

					-- Verifica que no este vacia la consulta.
					IF ( cSQL <> '' ) THEN 
						SYSTEM cSQL ;

						--Permiso para la creacion de archivo.
						LET cSQL = '' ;
						LET cSQL = 'chmod 777 ' || TRIM(cRuta) || "arcgene_pred_qry_"|| TRIM(c_canal) ||".sql" ;
						LET cSQL = '' ;
						LET cSql = "dbaccess bdicobranza "|| TRIM(cRuta) || "arcgene_pred_qry_"|| TRIM(c_canal) ||".sql";
						SYSTEM TRIM(cSql);

						LET cSql = cSql;
						LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cNomArchivo);
						SYSTEM cSql;

						IF cNumProd = '6011' THEN
							LET cSqlaux = '';
							LET cSqlaux = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
							SYSTEM cSqlaux;

							LET cSql = '';
							LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
							SYSTEM cSql;
						END IF;

						--BORRADO DE TEMPORALES QUE FUERON USADOS PARA LA CREACION DE ARCHIVO
						LET cSql = '';
						LET cSQL = "rm "||TRIM(cRuta)||'arcgene_pred_qry_'|| TRIM(c_canal) ||'.sql';		
						SYSTEM TRIM(cSql); 

						LET cSQL = '' ;
						LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
						SYSTEM cSQL; 
						
						--Validar si el ÃÂºltimo producto de PP es el 7700 (en el orden ascendente lo es), para que se comprima el archivo.
						let cUltProdPP = cNumProd;
						IF cUltProdPP = ULT_PROD_PP THEN
						   LET cSqlaux = '';
						   LET cSqlaux = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
				           SYSTEM cSqlaux;
						   
						   LET cSql = '';
				           LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
				           SYSTEM cSql;
						END IF;
						
					END IF;
				END FOREACH;

				/*LET cSql = '';
				LET cSql = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
				SYSTEM cSql;
				

				LET cSql = '';
				LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
				SYSTEM cSql;
				*/

				RETURN cCod_ret;
			         -- TIPO COB R
            END IF;             
			 
		
			
			
		ELSE
			SELECT MAX(fecha_insert) INTO pfechacorte
			FROM "informix".cb_cat_directorio_cte
			WHERE empresa = pempresa
			  --AND num_producto = v_num_producto
			AND tipo_cobranza = ptipocobranza;

			IF NVL(pfechacorte,"") = "" THEN
				LET cCod_Ret     = "104008";
				SELECT descripcion
				INTO cMensaje
				FROM bdicobranza:"informix".cb_errores
				WHERE origen       = 3
				AND codigo_error = cCod_Ret; 

				IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
					--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa,vproceso,cCod_Ret,cMensaje,"02") INTO cCod_RetIB;

				RETURN cCod_Ret;
			END IF;

			--*--
			--GENERACION DE ARCHIVOS PARA TDC,PP,REE PARA EL CAT
			FOREACH WITH HOLD
				--SE OBTIENE EL NUMERO DEL PRODUCTO
				SELECT DISTINCT num_producto 
				INTO cNumProd
				FROM "informix".cb_cat_directorio_cte 
				WHERE empresa = '001'
				AND tipo_cobranza = ptipocobranza
				AND fecha_insert = pfechacorte
				AND canal = ""
				ORDER BY 1
				--AND num_producto != '6400'
			/*			WHERE empresa = pempresa
				AND tipo_cobranza = ptipocobranza
				AND fecha_insert = fecha_insert 
				AND num_credito = num_credito*/

				IF ptipocobranza = "A" OR ptipocobranza = "P" THEN
					IF cNumProd = "8100" OR cNumProd = "8500" THEN
						LET vnumparametro = 72; --TCO
					ELIF cNumProd = "6001" THEN
						LET vnumparametro = 53; --TDC
					ELSE
						CONTINUE FOREACH;
					END IF;
				ELSE
					IF cNumProd = "6300" OR cNumProd = "6400" OR cNumProd = "7600" OR cNumProd = "7700" OR cNumProd = "6800" THEN
						LET vnumparametro = 55; --PP
					ELIF cNumProd = "6011" THEN
						LET vnumparametro = 54; --REE
					ELSE
						CONTINUE FOREACH;
					END IF;
				END IF;

				--OBTENER EL NOMBRE DEL ARCHIVO
				SELECT valor_alfabetico INTO cnombre
				FROM "informix".cb_param_campania
				WHERE empresa = pempresa
				AND tipo_campania = 1
				AND grupo_parametro = 'ARCHIVOS'
				AND num_parametro = vnumparametro;

				IF NVL(cNombre,"") = "" THEN
					LET cCod_Ret = "104006";
					SELECT descripcion
					INTO cMensaje
					FROM bdicobranza:"informix".cb_errores
					WHERE origen       = 3
					AND codigo_error = cCod_Ret; 

					IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

					--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa,vproceso,cCod_Ret,cMensaje,"02") INTO cCod_RetIB;

					RETURN cCod_Ret;
				END IF;

				--VALIDAR QUE EXISTE EL ARCHIVO
				LET cnomarchivo1 =  TRIM(cnombre)||'Aux_' ||  ptipocobranza || to_char(pfechacorte,'%d%m%Y')||'.txt';
				LET cnomarchivo =  TRIM(cnombre)||to_char(pfechacorte,'%d%m%Y')||'.txt';

				LET cSQL1 = 'echo "UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1)|| " DELIMITER '" || cDelimitador || "'"||'';	
				LET cSQL2 = " SELECT a.fecha_insert,a.numcte,a.num_credito,a.num_producto,a.nombre1,"
					|| " DECODE(a.nombre2,'',NULL,NULL,NULL,a.nombre2),a.apell_paterno,DECODE(a.apell_materno,'',NULL,NULL,NULL,a.apell_materno),b.sexo,"
					|| " YEAR(b.fecha_nac)||'-'||LPAD(MONTH(b.fecha_nac),2,'0')||'-'||LPAD(DAY(b.fecha_nac),2,'0'),b.estado_civil,"
					|| " Trim(d2.nombrecalle)||','||Trim(d.numeroextcalle)||','|| Trim(d.numerointcalle)||','||Trim(d3.nombrezona)||','||Trim(d3.municipiozona)||','||Trim(d1.estado) direccion,"
					|| " c.ingreso_mensual,"
					|| " (YEAR(e.fecha_alta)||'-'||LPAD(MONTH(e.fecha_alta),2,'0')||'-'||LPAD(DAY(e.fecha_alta),2,'0')),d.numerociudad,d.estado,"
					|| " CASE WHEN h.status_correo = 'A' AND h.correo_elec <> '' THEN '1' ELSE '0' END ,a.pago_venc,DECODE(e.numcte_ref,'',NULL,NULL,NULL,e.numcte_ref),a.tipo_logica, a.tipo_cobranza"
					|| " FROM bdicobranza: cb_cat_directorio_cte a"
					|| " INNER JOIN bdinteg: si_cliente e ON e.numcte=a.numcte"
					|| " INNER JOIN bdinteg: si_ctepf b ON b.numcte=a.numcte"
					|| " INNER JOIN bdinteg: si_direcciones_actual d ON d.numcte=a.numcte and d.tipo_dir='1'"
					|| " INNER  JOIN bdisolic:ss_circulo_edos d1 ON d1.empresa = '001' AND d1.clave = d.estado "
					|| " INNER  JOIN bdinteg:si_catcalles d2 ON d2.numerocalle = d.numerocalle"
					|| " INNER  JOIN bdinteg:si_catzonas d3 ON d3.numerociudad = d.numerociudad and d3.numerocolonia = d.numerocolonia";
				LET cSQL4 = " LEFT OUTER JOIN bdinteg: si_ingresos c ON c.numcte=a.numcte and c.sec_ingreso = (select max(sec_ingreso) from bdinteg: si_ingresos where numcte=a.numcte )"
					|| " LEFT OUTER JOIN bdinteg: si_correos h ON a.numcte=h.numcte and tipo_correo = 1 and status_correo = 'A'"
					--/* and valido=1 */--RQM 09 598"
					|| " WHERE a.tipo_cobranza ='"||ptipocobranza|| "'"
					|| " AND a.fecha_insert = '"|| pfechacorte || "'"
					--|| " AND a.tipo_logica > 0"
					|| " AND a.status_cliente not in ('NT','EX') "
					|| " AND a.canal = '' "
					|| " AND a.num_producto = '"|| cNumProd || "' "|| '">'||TRIM(cRuta)||'arcgene_pred_qry.sql';

				LET cSQL = TRIM(cSQL1) || cSQL2 ;
				LET cSQL5 = cSQL4;
				LET cSQL = TRIM(cSQL) || cSQL5 ;

				-- Verifica que no este vacia la consulta.
				IF ( cSQL <> '' ) THEN 
					SYSTEM cSQL ;

					--Permiso para la creacion de archivo.
					LET cSQL = '' ;
					LET cSQL = 'chmod 777 ' || TRIM(cRuta) || "arcgene_pred_qry.sql" ;
					LET cSQL = '' ;
					LET cSql = "dbaccess bdicobranza "|| TRIM(cRuta) || "arcgene_pred_qry.sql";
					SYSTEM TRIM(cSql);

					LET cSql = cSql;
					LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cNomArchivo);
					SYSTEM cSql;

					IF cNumProd = '6011' THEN
						LET cSql = '';
						LET cSql = "wc -l "|| TRIM(cRuta) || TRIM(cNomArchivo) || ' > '  || TRIM(cRuta) ||'CC_'||TRIM(cNomArchivo);
						SYSTEM cSql;

						LET cSqlaux = '';
						LET cSqlaux = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
						SYSTEM cSqlaux;

						LET cSql = '';
						LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
						SYSTEM cSql;
					END IF;

					--BORRADO DE TEMPORALES QUE FUERON USADOS PARA LA CREACION DE ARCHIVO
					LET cSql = '';
					LET cSQL = "rm "||TRIM(cRuta)||'arcgene_pred_qry.sql';		
					SYSTEM TRIM(cSql); 

					LET cSQL = '' ;
					LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
					SYSTEM cSQL; 
				END IF;
			END FOREACH;

			LET cSql = '';
			LET cSql = "wc -l "|| TRIM(cRuta) || TRIM(cNomArchivo) || ' > '  || TRIM(cRuta) ||'CC_'||TRIM(cNomArchivo);
			SYSTEM cSql;

			LET cSqlaux = '';
			LET cSqlaux = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
			SYSTEM cSqlaux;

			LET cSql = '';
			LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
			SYSTEM cSql;

			--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa,vproceso,cCod_Ret,cMensaje,"03") INTO cCod_RetIB;
			--*--
			RETURN cCod_ret;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'MODIFICACION: ISARAI BOJORQUEZ',
'FECHA: 2015/06/24',
'DESCRIPCION: SE CREA PROCEDIMIENTO PARA LA GENERACION DE ARCHIVOS CATGENERACION',
'BD: BDIcOBRANZA',
'VERSION:20150624.1500',
'Modif.: MACF 20191108',
'DescripciÃÂ³n: Modificar para generar los archivos de las N Agencias Externas que existan';

CREATE PROCEDURE "informix".sp_genera_campana_prev_pzo(pEmpresa CHAR(3))
returning VARCHAR(06),
          VARCHAR(80);
-----------------------------------------------------------------------
--  EXECUTE PROCEDURE "informix".sp_genera_campana_prev_pzo('001');

DEFINE SQL_ERR					INTEGER;
DEFINE ISAM_ERR					INTEGER;
DEFINE ERROR_INFO				VARCHAR(80);
DEFINE cProceso					CHAR(4);
DEFINE P_COD_RET				VARCHAR(6);
DEFINE P_MENSAJE				VARCHAR(80);
DEFINE cCodRet  				CHAR(6);

DEFINE cMensaje  				VARCHAR(200);
DEFINE dFecha					DATE;
DEFINE vDay						VARCHAR(2);
DEFINE vMonth					VARCHAR(2);
DEFINE vYear					VARCHAR(4);
DEFINE cNumCredito				CHAR(20);
DEFINE cNumcte					CHAR(20);
DEFINE cNumProducto				CHAR(04);
DEFINE v_prod_desc				VARCHAR(10);
DEFINE dFech_ini				DATE;
DEFINE dFechaApertura			DATE;
DEFINE vExcluir					CHAR(1);
DEFINE vBandera					CHAR(1);
DEFINE vBandera2				CHAR(1);
DEFINE pReinicio				CHAR(1);
DEFINE v_nombre1				VARCHAR(50);
DEFINE v_nombre2				VARCHAR(50);
DEFINE v_nombre					VARCHAR(50);
DEFINE v_apell_paterno			VARCHAR(50);
DEFINE v_apell_materno			VARCHAR(50);
DEFINE v_estado					VARCHAR(50);
DEFINE v_ciudad					VARCHAR(50);
DEFINE v_telcelular				VARCHAR(10);
DEFINE v_telcasa				VARCHAR(10);
DEFINE v_mto_fin_ven_trasp		DECIMAL(18,2);
DEFINE v_fecha_lim_pago			CHAR(10);
DEFINE v_numerociudad			SMALLINT;
DEFINE vTabla_ins				CHAR(1);
DEFINE dPagoMin					DECIMAL(18,2);
DEFINE v_pago_no_gen_int		DECIMAL(18,2);
DEFINE dTotalLiq				DECIMAL(18,2);
DEFINE cNombreArchivo  			VARCHAR(150);
DEFINE cConsulta				CHAR(2500);
DEFINE cEncabezado				CHAR(2500);
DEFINE cSql						CHAR(2500);
DEFINE cRuta 					VARCHAR(100);
DEFINE vSaldoCapIns				DECIMAL(18,2);
DEFINE vSaldoInt					DECIMAL(18,2);
DEFINE cSucursal				CHAR(4);
DEFINE cIva						DECIMAL(5,3);
DEFINE vProd_desc				VARCHAR(10);

DEFINE iTotalInsertadasApert	INTEGER;
DEFINE iTotalInsertadasMesVen1	INTEGER;
DEFINE iTotalInsertadasMesVen2	INTEGER;
DEFINE iTotalUpdtApert			INTEGER;
DEFINE iTotalUpdtMesVen1		INTEGER;
DEFINE iTotalUpdtMesVen2		INTEGER;
DEFINE iTotalExcluidas 			INTEGER;
DEFINE iTotalCuentas			INTEGER;
DEFINE dFechaProceso			DATE;
DEFINE dFechaProceso2			DATE;
DEFINE dFechaProcesoAuxIni		DATE;
DEFINE dFechaProcesoAuxFin		DATE;
DEFINE dFechaInicio				DATE;
DEFINE dFechaFin				DATE;
DEFINE dFechaCal				DATE;
DEFINE dDayCal					INTEGER;

BEGIN 
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET = SQL_ERR;
     LET P_MENSAJE = 'Erro en la ejecucion proceso. '||cNumCredito;
     CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, P_COD_RET, P_MENSAJE, '02')
     RETURNING P_COD_RET;
     LET P_COD_RET = SQL_ERR;
     DROP TABLE IF EXISTS cuentas_pp;
     RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

	--SET DEBUG FILE TO "/RESPALDOS/HectorF/sp_genera_campana_prev_pzo.out";
	--TRACE ON;

	LET cProceso            		= '2051';
	LET P_COD_RET           		= '000000';
	LET P_MENSAJE           		= 'El proceso de CAMPANA PREVPP se ejecuto correctamente.';
	LET cCodRet           			= '000000';

	LET cMensaje					= '';
	LET dFecha						= DATE(1);
	LET vDay						= '';
	LET vMonth						= '';
	LET vYear						= '';
	LET cNumCredito					= '';
	LET cNumcte						= '';
	LET cNumProducto				= '';
	LET v_prod_desc					= '';
	LET dFech_ini					= DATE(1);
	LET dFechaApertura				= DATE(1);
	LET vExcluir					= '';
	LET vBandera					= '';
	LET vBandera2					= '';
	LET pReinicio					= '';
	LET v_nombre1					= '';
	LET v_nombre2					= '';
	LET v_nombre					= '';
	LET v_apell_paterno				= '';
	LET v_apell_materno				= '';
	LET v_estado					= '';
	LET v_ciudad					= '';
	LET v_telcelular				= '';
	LET v_telcasa					= '';
	LET v_mto_fin_ven_trasp			= 0;
	LET v_fecha_lim_pago			= '';
	LET v_numerociudad				= 0;
	LET vTabla_ins					= '';
	LET dPagoMin					= 0;
	LET v_pago_no_gen_int			= 0;
	LET dTotalLiq					= 0;
	LET cNombreArchivo				= '';
	LET cConsulta					= '';
	LET cEncabezado					= '';
	LET cSql						= '';
	LET cRuta						= '';
	LET vSaldoCapIns				= 0;
	LET vSaldoInt					= 0;
	LET cSucursal					= '';
	LET cIva						= 0;
	LET vProd_desc					= '';

	LET iTotalInsertadasApert		= 0;
	LET iTotalInsertadasMesVen1		= 0;
	LET iTotalInsertadasMesVen2		= 0;
	LET iTotalUpdtApert				= 0;
	LET iTotalUpdtMesVen1			= 0;
	LET iTotalUpdtMesVen2			= 0;
	LET iTotalExcluidas				= 0;
	LET	iTotalCuentas				= 0;
	LET dFechaProceso				= DATE(1);
	LET dFechaProceso2				= DATE(1);
	LET dFechaProcesoAuxIni			= DATE(1);
	LET dFechaProcesoAuxFin			= DATE(1);
	LET dFechaInicio				= DATE(1);
	LET dFechaFin					= DATE(1);
	LET dFechaCal					= DATE(1);
	LET dDayCal						= 0;

	CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, P_MENSAJE, '01')
		RETURNING P_COD_RET;

	IF P_COD_RET != '000000' THEN
	   LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
	   RETURN P_COD_RET,P_MENSAJE;
	END IF;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	SELECT valor
	INTO cRuta
	FROM "informix".cb_param
	WHERE cod_param = 92;

	--LET cRuta='/RESPALDOS/HectorF/';

	SELECT fecha_hoy INTO dFecha FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;

	SELECT FIRST 1 '1' INTO pReinicio FROM "informix".cb_campana_prev WHERE fecha >= MDY(MONTH(dFecha),1,YEAR(dFecha));

	IF pReinicio IS NULL OR pReinicio = '' THEN
		TRUNCATE TABLE "informix".cb_campana_prev DROP STORAGE;
		TRUNCATE TABLE "informix".cb_resultados_prev DROP STORAGE;
		CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, 'NUEVOS REGISTROS FECHA '|| dFecha, '02') RETURNING P_COD_RET;
		IF P_COD_RET != '000000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
			RETURN P_COD_RET,P_MENSAJE;
		END IF;
	ELSE
		CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, 'REGISTROS ACTUALES FECHA '|| dFecha, '02') RETURNING P_COD_RET;
		IF P_COD_RET != '000000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
			RETURN P_COD_RET,P_MENSAJE;
		END IF;
	END IF;

---Pruebas---
	--LET dFecha = TODAY;
---Pruebas---

	LET vDay = LPAD(DAY(dFecha),2,'0'); LET vMonth = LPAD(MONTH(dFecha),2,'0'); LET vYear = YEAR(dFecha);

	LET cNombreArchivo = TRIM(cRuta)||'CampanaPrevPP'||vYear||vMonth||vDay||'.csv';

	IF(DAY(dFecha) >= 1 AND DAY(dFecha) <= 5) THEN
		LET dFechaInicio = mdy(vMonth,6,vYear);
		LET dFechaFin = mdy(vMonth,10,vYear);
	ELIF(DAY(dFecha) >= 6 AND DAY(dFecha) <= 10) THEN
		LET dFechaInicio = mdy(vMonth,11,vYear);
		LET dFechaFin = mdy(vMonth,15,vYear);
	ELIF(DAY(dFecha) >= 11 AND DAY(dFecha) <= 15) THEN
		LET dFechaInicio = mdy(vMonth,16,vYear);
		LET dFechaFin = mdy(vMonth,20,vYear);
	ELIF(DAY(dFecha) >= 16 AND DAY(dFecha) <= 20) THEN
		LET dFechaInicio = mdy(vMonth,21,vYear);
		LET dFechaFin = mdy(vMonth,25,vYear);
	ELIF(DAY(dFecha) >= 21 AND DAY(dFecha) <= 25) THEN
		LET dFechaInicio = mdy(vMonth,26,vYear);
		LET dFechaCal = mdy(vMonth,1,vYear) + 1 UNITS MONTH;
		LET dDayCal = DAY(dFechaCal - 1 UNITS DAY);
		IF(dDayCal = 31) THEN LET dDayCal = 30; END IF;
		LET dFechaFin = mdy(vMonth,dDayCal,vYear);
	ELIF(DAY(dFecha) >= 26 AND DAY(dFecha) <= 31) THEN
		LET dFechaCal = mdy(vMonth,1,vYear) + 1 UNITS MONTH;
		LET dDayCal = DAY(dFechaCal - 1 UNITS DAY);
		IF(dDayCal = 31) THEN 
			LET dFechaInicio = mdy(vMonth,dDayCal,vYear);
			LET dFechaFin = mdy(MONTH(dFechaCal),5,YEAR(dFechaCal));
		ELSE
			LET dFechaInicio = dFechaCal;
			LET dFechaFin = MDY(MONTH(dFechaInicio),5,YEAR(dFechaInicio));
		END IF;
	END IF;

	LET dFechaProcesoAuxIni = MDY(MONTH(dFecha),1,YEAR(dFecha)) - 2 UNITS MONTH;
	LET dFechaProcesoAuxFin = MDY(MONTH(dFecha),1,YEAR(dFecha)) - 1 UNITS DAY;

	LET dFechaProceso = MDY(MONTH(dFecha),1,YEAR(dFecha)) - 1 UNITS DAY;
	LET dFechaProceso2 = MDY(MONTH(dFechaProceso),1,YEAR(dFechaProceso)) - 1 UNITS DAY;

	SELECT a.empresa, a.num_credito, a.numcte, a.num_producto, a.fecha_apertura, d.mto_fin_ven_trasp, b2.capital_mto_cuota AS pago_minimo, a.sucursal
	FROM bdicred:"informix".sd_maecredcrd a
	INNER JOIN bdicred:"informix".sd_maecredanexocrd c ON (c.empresa = a.empresa AND c.num_credito = a.num_credito AND c.prox_fecha_pago >= dFechaInicio AND c.prox_fecha_pago <= dFechaFin)
	INNER JOIN bdicred:"informix".sd_maesdoscrd d ON (d.num_credito = a.num_credito AND d.mto_fin_ven_trasp = 0)
	INNER JOIN bdicred:"informix".sd_amortiza_creditocrd b2 ON (b2.empresa = a.empresa AND b2.num_credito = a.num_credito AND b2.capital_status = "3" AND NVL(b2.capital_mto_cuota,0) >= 100)
	WHERE a.num_credito NOT IN (SELECT num_credito FROM "informix".cb_resultados_prev WHERE num_credito > '')
	AND a.num_producto IN ('6300','7600','7700')
	AND a.status_cred IN ('AA','E1')
	AND (d.monto_vencido + d.mto_venc_trasp) = 0
	AND a.fecha_apertura > dFech_ini
	INTO TEMP cuentas_pp WITH NO LOG;

	CREATE INDEX inx_empresa_pp ON cuentas_pp(empresa); --in dbs_movhis_idx3;
	UPDATE STATISTICS MEDIUM FOR TABLE cuentas_pp;

	FOREACH WITH HOLD
		SELECT num_credito, numcte, num_producto, fecha_apertura, mto_fin_ven_trasp, pago_minimo, sucursal
		INTO cNumCredito, cNumcte, cNumProducto, dFechaApertura, v_mto_fin_ven_trasp, dPagoMin, cSucursal
		FROM cuentas_pp
		WHERE empresa = pEmpresa

		SELECT LIMIT 1 '1'
		INTO vExcluir
		FROM bdicred:"informix".sd_programa_apoyo
		WHERE num_credito = cNumCredito AND bandera = 'A';

		IF(vExcluir IS NULL) THEN LET vExcluir = ''; END IF;

		IF (vExcluir = '1') THEN CONTINUE FOREACH; END IF;

		LET iTotalCuentas = iTotalCuentas + 1;

		SELECT LIMIT 1 '1' INTO vBandera
		FROM bdicred:"informix".sd_maesdoscontcrd
		WHERE empresa = pEmpresa
		AND num_credito = cNumCredito
		AND mto_fin_ven_trasp > 0
		AND fecha = dFechaProceso;

		IF(vBandera IS NULL) THEN LET vBandera = ''; END IF;

		SELECT LIMIT 1 '1' INTO vBandera2
		FROM bdicred:"informix".sd_maesdoscontcrd
		WHERE empresa = pEmpresa
		AND num_credito = cNumCredito
		AND mto_fin_ven_trasp > 0
		AND fecha = dFechaProceso2;

		IF(vBandera2 IS NULL) THEN LET vBandera2 = ''; END IF;

		SELECT nombre1, nombre2, apell_paterno, apell_materno
			INTO v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno
		FROM bdinteg:"informix".si_cliente WHERE empresa = pEmpresa AND numcte = cNumcte;

		IF(v_nombre1 IS NULL) THEN LET v_nombre1 = ''; END IF;

		IF(v_nombre2 IS NULL) THEN LET v_nombre2 = ''; END IF;
		
		IF(v_nombre2 = '') THEN 
			LET v_nombre = TRIM(v_nombre1);
		ELSE
			LET v_nombre = TRIM(v_nombre1)||' '||TRIM(v_nombre2);
		END IF;	

		IF(v_nombre IS NULL) THEN LET v_nombre = ''; END IF;

		IF(v_apell_paterno IS NULL) THEN LET v_apell_paterno = ''; END IF;

		IF(v_apell_materno IS NULL) THEN LET v_apell_materno = ''; END IF;

		SELECT UPPER(d2.descripcion), d3.municipiozona, d1.numerociudad
		INTO v_estado, v_ciudad, v_numerociudad
		FROM bdinteg:"informix".si_direcciones_actual d1
		LEFT OUTER JOIN bdisolic:ss_circulo_edos d2 ON (d2.empresa = pEmpresa AND d2.clave = d1.estado)
		LEFT OUTER JOIN bdinteg:si_catzonas d3 ON (d3.numerociudad = d1.numerociudad and d3.numerocolonia = d1.numerocolonia)
		WHERE d1.numcte = cNumcte
		AND d1.tipo_dir='1';

		IF(v_estado IS NULL) THEN LET v_estado = ''; END IF;

		IF(v_ciudad IS NULL) THEN LET v_ciudad = ''; END IF;

		IF(v_numerociudad IS NULL) THEN LET v_numerociudad = 0; END IF;

		SELECT SUBSTR(telefono,LENGTH(telefono)-9,10)
		INTO v_telcasa
		FROM bdinteg:"informix".si_telefonos_actual
		WHERE numcte = cNumcte
		AND tipo_tel = 1 /* AND cofetel = 'V' */--RQM 09 598"
		AND length(nvl(telefono,'')) >= 10 AND NVL(telefono,'') <> '';

		SELECT SUBSTR(telefono,LENGTH(telefono)-9,10)
		INTO v_telcelular
		FROM bdinteg:"informix".si_telefonos_actual
		WHERE numcte = cNumcte
		AND tipo_tel = 2 /* AND cofetel = 'V' */--RQM 09 598"
		AND length(nvl(telefono,'')) >= 10 AND NVL(telefono,'') <> '';

		IF(v_telcasa IS NULL) THEN LET v_telcasa = ''; END IF;

		IF(v_telcelular IS NULL) THEN LET v_telcelular = ''; END IF;
		
		IF(v_telcasa = '') AND (v_telcelular = '') THEN
			LET	iTotalExcluidas = iTotalExcluidas + 1;
			CONTINUE FOREACH;
		END IF;

		SELECT TO_CHAR(prox_fecha_pago,'%d/%m/%Y')
		INTO v_fecha_lim_pago
		FROM bdicred:"informix".sd_maecredanexocrd
		WHERE num_credito = cNumCredito;

		IF(v_fecha_lim_pago IS NULL) THEN LET v_fecha_lim_pago = ''; END IF;

		SELECT iva
		INTO cIva
		FROM bdinteg:"informix".si_sucursales
		WHERE empresa = pEmpresa
		AND	sucursal = cSucursal;

		IF(cIva IS NULL) THEN LET cIva = 0; END IF;

		SELECT sdo_cap_insoluto, sdo_intereses
		INTO vSaldoCapIns, vSaldoInt
		FROM bdicred:"informix".sd_maesdoscrd
		WHERE empresa = pEmpresa 
		AND num_credito = cNumCredito;

		IF(vSaldoCapIns IS NULL) THEN LET vSaldoCapIns = 0; END IF;

		IF(vSaldoInt IS NULL) THEN LET vSaldoInt = 0; END IF;

		LET dTotalLiq = vSaldoCapIns + vSaldoInt + (vSaldoInt*cIva);

		IF(cNumProducto = '6300') THEN
			LET vProd_desc = 'PP12';
		ELIF(cNumProducto = '7600') THEN
			LET vProd_desc = 'PP18';
		ELIF(cNumProducto = '7700') THEN
			LET vProd_desc = 'PP24';
		END IF;

		SELECT LIMIT 1 '1'
		INTO vTabla_ins
		FROM "informix".cb_campana_prev
		WHERE num_credito = cNumCredito
		AND num_producto = cNumProducto;

		IF(vTabla_ins IS NULL) THEN LET vTabla_ins = ''; END IF;

		IF (dFechaApertura >= dFechaProcesoAuxIni) AND (dFechaApertura <= dFechaProcesoAuxFin) THEN
			IF vTabla_ins = '1' THEN
				BEGIN;
					UPDATE "informix".cb_campana_prev
					SET fecha = dFecha,
						nombre = TRIM(v_nombre),
						prod_desc = vProd_desc,
						no_vencidos = v_mto_fin_ven_trasp,
						fecha_lim_pago = v_fecha_lim_pago,
						pago_minimo = dPagoMin,
						pago_no_gen_int = dTotalLiq,
						saldo_tot_liquidar = dTotalLiq,
						procesar = '1'
					WHERE num_credito = cNumCredito
					AND num_producto = cNumProducto;
				COMMIT;
				
				LET iTotalUpdtApert = iTotalUpdtApert + 1;
			ELSE
				BEGIN;
					INSERT INTO "informix".cb_campana_prev(fecha, numcte, nombre, apell_paterno, apell_materno, estado, ciudad, telcasa, telcelular, num_producto, prod_desc, num_credito, no_vencidos, fecha_lim_pago, pago_minimo, pago_no_gen_int, saldo_tot_liquidar, num_ciudad, bandera_insert, campana, procesar)
					VALUES(dFecha, cNumcte, TRIM(v_nombre), TRIM(v_apell_paterno), TRIM(v_apell_materno), TRIM(v_estado), TRIM(v_ciudad), TRIM(v_telcasa), TRIM(v_telcelular), cNumProducto, vProd_desc, cNumCredito, v_mto_fin_ven_trasp,v_fecha_lim_pago, dPagoMin, dTotalLiq, dTotalLiq, v_numerociudad, 'AP', 'CAT', '1');
				COMMIT;

				LET iTotalInsertadasApert = iTotalInsertadasApert + 1;
			END IF;
		ELIF vBandera = '1' THEN
			IF vTabla_ins = '1' THEN
				BEGIN;
					UPDATE "informix".cb_campana_prev
					SET fecha = dFecha,
						nombre = TRIM(v_nombre),
						prod_desc = vProd_desc,
						no_vencidos = v_mto_fin_ven_trasp,
						fecha_lim_pago = v_fecha_lim_pago,
						pago_minimo = dPagoMin,
						pago_no_gen_int = dTotalLiq,
						saldo_tot_liquidar = dTotalLiq,
						procesar = '1'
					WHERE num_credito = cNumCredito
					AND num_producto = cNumProducto;
				COMMIT;

				LET iTotalUpdtMesVen1 = iTotalUpdtMesVen1 + 1;
			ELSE
				BEGIN;
					INSERT INTO "informix".cb_campana_prev(fecha, numcte, nombre, apell_paterno, apell_materno, estado, ciudad, telcasa, telcelular, num_producto, prod_desc, num_credito, no_vencidos, fecha_lim_pago, pago_minimo, pago_no_gen_int, saldo_tot_liquidar, num_ciudad, bandera_insert, campana, procesar)
					VALUES(dFecha, cNumcte, TRIM(v_nombre), TRIM(v_apell_paterno), TRIM(v_apell_materno), TRIM(v_estado), TRIM(v_ciudad), TRIM(v_telcasa), TRIM(v_telcelular), cNumProducto, vProd_desc, cNumCredito, v_mto_fin_ven_trasp,v_fecha_lim_pago, dPagoMin, dTotalLiq, dTotalLiq, v_numerociudad, 'M1', 'CAT', '1');
				COMMIT;

				LET iTotalInsertadasMesVen1 = iTotalInsertadasMesVen1 + 1;
			END IF;
		ELIF vBandera2 = '1' THEN
			IF vTabla_ins = '1' THEN
				BEGIN;
					UPDATE "informix".cb_campana_prev
					SET fecha = dFecha,
						nombre = TRIM(v_nombre),
						prod_desc = vProd_desc,
						no_vencidos = v_mto_fin_ven_trasp,
						fecha_lim_pago = v_fecha_lim_pago,
						pago_minimo = dPagoMin,
						pago_no_gen_int = dTotalLiq,
						saldo_tot_liquidar = dTotalLiq,
						procesar = '1'
					WHERE num_credito = cNumCredito
					AND num_producto = cNumProducto;
				COMMIT;

				LET iTotalUpdtMesVen2 = iTotalUpdtMesVen2 + 1;
			ELSE
				BEGIN;
					INSERT INTO "informix".cb_campana_prev(fecha, numcte, nombre, apell_paterno, apell_materno, estado, ciudad, telcasa, telcelular, num_producto, prod_desc, num_credito, no_vencidos, fecha_lim_pago, pago_minimo, pago_no_gen_int, saldo_tot_liquidar, num_ciudad, bandera_insert, campana, procesar)
					VALUES(dFecha, cNumcte, TRIM(v_nombre), TRIM(v_apell_paterno), TRIM(v_apell_materno), TRIM(v_estado), TRIM(v_ciudad), TRIM(v_telcasa), TRIM(v_telcelular), cNumProducto, vProd_desc, cNumCredito, v_mto_fin_ven_trasp,v_fecha_lim_pago, dPagoMin, dTotalLiq, dTotalLiq, v_numerociudad, 'M2', 'CAT', '1');
				COMMIT;

				LET iTotalInsertadasMesVen2 = iTotalInsertadasMesVen2 + 1;
			END IF;
		ELSE
			LET	iTotalExcluidas = iTotalExcluidas + 1;
		END IF;
	END FOREACH;

	UPDATE STATISTICS MEDIUM FOR TABLE "informix".cb_campana_prev;

	DROP TABLE cuentas_pp;

	LET cSql = 'if [ -f '||TRIM(cNombreArchivo)||' ]; then nice nice -n -30 rm -f '||TRIM(cNombreArchivo)||'; fi';
	System cSql;

	LET cSql = '';

	LET cEncabezado = 'echo "cliente'||'|'||'nombre'||'|'||'apellidopaterno'||'|'||'apellidomaterno'||'|'||'estado'||'|'||'ciudad'||'|'||'telcasa'||'|'||'telcelular'||'|'||'producto'||'|'||'prod_desc'||'|'||'credito'||'|'||'no_vencidos'||'|'||'fec_lim_pago'||'|'||'pago_minimo'||'|'||'pago_no_gen_int'||'|'||'saldo_tot_liquidar'||'|'||'num_ciudad" > '||TRIM(cNombreArchivo);

	SYSTEM cEncabezado;

	LET cEncabezado = '';

	FOREACH WITH HOLD
		SELECT numcte, nombre, apell_paterno, apell_materno, estado, ciudad, telcasa, telcelular, num_producto, prod_desc, num_credito, no_vencidos, fecha_lim_pago, pago_minimo, pago_no_gen_int, saldo_tot_liquidar, num_ciudad
		INTO cNumcte, v_nombre, v_apell_paterno, v_apell_materno, v_estado, v_ciudad, v_telcasa, v_telcelular, cNumProducto, v_prod_desc, cNumCredito, v_mto_fin_ven_trasp,v_fecha_lim_pago, dPagoMin, v_pago_no_gen_int, dTotalLiq, v_numerociudad
		FROM "informix".cb_campana_prev
		WHERE procesar = '1'
		AND campana = 'CAT'
		AND num_producto IN ('6300','7600','7700')

		LET cConsulta = TRIM(NVL(cNumcte,''))||'|'||TRIM(NVL(v_nombre,''))||'|'||TRIM(NVL(v_apell_paterno,''))||'|'||TRIM(NVL(v_apell_materno,''))||'|'||TRIM(NVL(v_estado,''))||'|'||TRIM(NVL(v_ciudad,''))||'|'||TRIM(NVL(v_telcasa,''))||'|'||TRIM(NVL(v_telcelular,''))||'|'||TRIM(NVL(cNumProducto,''))||'|'||TRIM(NVL(v_prod_desc,''))||'|'||TRIM(NVL(cNumCredito,''))||'|'||v_mto_fin_ven_trasp||'|'||v_fecha_lim_pago||'|'||dPagoMin||'|'||v_pago_no_gen_int||'|'||dTotalLiq||'|'||v_numerociudad;

		LET cSql = 'echo "'||TRIM(cConsulta)||'" >> '||TRIM(cNombreArchivo);  
		SYSTEM cSql;

		LET cSql = '';

		UPDATE "informix".cb_campana_prev
		SET procesar = '0'
		WHERE num_credito = cNumCredito
		AND num_producto IN ('6300','7600','7700');
	END FOREACH;

	LET cSql = '';
	LET cSql = "wc -l "||TRIM(cNombreArchivo)|| ' > '  ||TRIM(cRuta)||'CC_CampanaPrevPP'||vYear||vMonth||vDay||'.csv';
	SYSTEM cSql;	

	LET cSql = '';

	LET cSql = 'chmod 777 '||TRIM(cNombreArchivo);  
	SYSTEM cSql;

	LET cSql = '';

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas a procesadas PP: ' ||iTotalCuentas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas PP : ' ||iTotalExcluidas;
	CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = "";
	LET cMensaje = 'Cuentas insert Apertura PP : ' ||iTotalInsertadasApert;
	LET cMensaje = trim(cMensaje) ||'    Cuentas insert MesVen Mes 1 PP : ' ||iTotalInsertadasMesVen1;
	CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = "";
	LET cMensaje = 'Cuentas insert MesVen Mes 2 PP : ' ||iTotalInsertadasMesVen2;
	LET cMensaje = trim(cMensaje) ||'    Cuentas Actualizadas Apertura PP : ' ||iTotalUpdtApert;
	CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = "";
	LET cMensaje = 'Cuentas Actualizadas MesVen Mes 1 PP : ' ||iTotalUpdtMesVen1;
	LET cMensaje = trim(cMensaje) ||'    Cuentas Actualizadas MesVen Mes 2 PP : ' ||iTotalUpdtMesVen2;
	CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = "";
	CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, P_MENSAJE, '03') RETURNING P_COD_RET;

	IF P_COD_RET != '000000' THEN
		LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
		RETURN P_COD_RET,P_MENSAJE;
	END IF;

	RETURN cCodRet,P_MENSAJE;

END;
END PROCEDURE;