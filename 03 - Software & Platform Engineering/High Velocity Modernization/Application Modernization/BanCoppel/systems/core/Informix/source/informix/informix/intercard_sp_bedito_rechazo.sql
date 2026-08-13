CREATE PROCEDURE "informix".sp_bedito_rechazo(pindica VARCHAR (1), -----"R" reporte de tarjetas de debito rechazadas con código ISO 61 y 75; "D" reporte de transacciónes de TDD y TDC Coppel.
                                            primer_dia_mes_hora DATETIME YEAR TO FRACTION(5), ---parametro calculado el el SP sp_txrechazo
                                            ultimo_dia_mes_hora DATETIME YEAR TO FRACTION(5), ---parametro calculado el el SP sp_txrechazo
                                            vaniomes2 CHAR(6),---periodo al que pertenece la información aaaamm
											pbin VARCHAR(6)--Parametro si el BIN es de débito o crédito	
                                            )
RETURNING VARCHAR(6), VARCHAR(80);
-------------VARIABLES-------------------------
DEFINE 	vindica	 	VARCHAR(1);
DEFINE  vsql     	CHAR(8000);
DEFINE 	vcodret  	VARCHAR(6);
DEFINE  p_mensaje	VARCHAR(80);
DEFINE  vsqlerr     INTEGER;
DEFINE  error_info  VARCHAR(80);
DEFINE  isam_err    INTEGER;
DEFINE  vbin		VARCHAR(6);
DEFINE	vexitetabla INTEGER;

 --SET DEBUG FILE TO "/resplogifx/rtxcoppel.sql";
 --TRACE ON;
-------------------------------------CUERPO-----------------------------------------
	BEGIN
			ON EXCEPTION SET vsqlerr, isam_err, error_info
				IF vsqlerr <> 0   then
					let vcodret = vsqlerr;
					let p_mensaje = error_info;
					  RETURN vcodret, p_mensaje;
				END IF;
			END EXCEPTION;
		
			
		LET vindica	=	pindica;
		LET vbin	=	pbin;
				
		IF  ( vindica = 'R' OR vindica = 'D') THEN

				IF ( vindica = 'R') THEN 
						LET vsql = ''; 
						LET vsql = 'echo "Tarjeta|Producto|Fecha Transacción|Método Captura|Descripción Metodo|Código Giro Negocio|Descripción del Negocio|Monto de Compra|Código ISO|Motivo de Rechazo|">/resplogifx/RTX_BIN_DEBITO_RECHAZO_'|| vaniomes2 ||'.unl';
						SYSTEM vsql;
						LET vsql = ''; 
						LET vsql = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 4; UNLOAD TO /resplogifx/RTX_BIN_DEBITO_RECHAZO.unl'||
									'		SELECT  movh.numtarjeta AS numtarjeta,'||
									'			  tar.codproductotarjeta'||'||''"'||'-'||'"''||'||'pro.descproducto AS productotarjeta, '||
									'			  movh.fechahorainauth AS fechahorainauth, '||
									'			  movh.metodocaptura AS metodocaptura, '||
									'			  CASE 	'||
									'				 WHEN metodocaptura = ''"'||'05'||'"'' THEN ''"'||'CHIP'||'"'''||
									'				 WHEN metodocaptura = ''"'||'90'||'"'' THEN ''"'||'Deslizada'||'" '''||
									'				 WHEN metodocaptura = ''"'||'01'||'"''  AND   tipotransaccionposdigitada = ''"'||'AV'||'"''    THEN ''"'||'Telemarketing'||'"'''||
									'				 WHEN metodocaptura = ''"'||'01'||'"''  AND   tipotransaccionposdigitada = ''"'||'CE'||'"''    THEN ''"'||'Comercio_Elect'||'"'''||
									'				 WHEN metodocaptura = ''"'||'01'||'"''  AND   tipotransaccionposdigitada = ''"'||'CA'||'"''    THEN ''"'||'Cargo_Autómatico'||'"'''|| 
									'				 WHEN metodocaptura = ''"'||'01'||'"''  AND   tipotransaccionposdigitada = ''"'||'HO'||'"''    THEN ''"'||'Hotel'||'"'''||
--	2016.08.16 -I Se agrega <tipotransaccionposdigitada> tipo TAG:
									'				 WHEN metodocaptura = ''"'||'01'||'"''  AND   tipotransaccionposdigitada = ''"'||'TG'||'"''    THEN ''"'||'TAG'||'"'''||
--	2016.08.16 -F.
									'				 WHEN metodocaptura = ''"'||'01'||'"''  AND   tipotransaccionposdigitada = ''"'||'ND'||'"''    THEN ''"'||'No_Determinada'||'"'''|| 
									'				 WHEN metodocaptura = ''"'||'01'||'"''  AND   tipotransaccionposdigitada = ''"'||'  '||'"''    THEN ''"'||'No_clasificada'||'"'''||
									'				 ELSE ''"'||'NULL'||'"'''||
									'			  END AS descripcion_metodo, '||
									'			  movh.codgironeg AS codigo_giro_neg, '||
									'			  movh.infreceptor AS descripcion_neg, '||
									'			  movh.monto AS monto,  '||
									'			  movh.codigoiso AS codigoiso, '||
									'			  movh.motivo AS motivorechazo '||
									'		FROM intercard:movimiento AS movh, '||
									'			intercard:tarjeta AS tar, '||
									'			intercard:productotarjeta  AS pro, '||
									'			intercard:bines AS bines '||
									'		WHERE movh.fechahorainauth BETWEEN ''"'||primer_dia_mes_hora||'"'' AND ''"'||ultimo_dia_mes_hora||'"'' '||
									'			AND tar.numtarjeta                                         =    movh.numtarjeta  '||
									'			AND pro.codproductotarjeta                                 =    tar.codproductotarjeta  '||
									'			AND CAST(SUBSTRing(tar.numtarjeta from 1 for 6)AS CHAR(6)) =    bines.bin '||
									'			AND bines.creditodebito                                    =    ''"'||'D'||'"'''||
									'			AND movh.metodocaptura IN (''"'||'90'||'"'',''"'||'05'||'"'',''"'||'01'||'"'') '||
									'			AND movh.codigoiso IN (''"'||'61'||'"'',''"'||'65'||'"'') '||
									'       UNION ALL '||
									'		SELECT  movh.numtarjeta AS numtarjeta,'||
									'			  tar.codproductotarjeta'||'||''"'||'-'||'"''||'||'pro.descproducto AS productotarjeta, '||
									'			  movh.fechahorainauth AS fechahorainauth, '||
									'			  movh.metodocaptura AS metodocaptura, '||
									'			  CASE 	'||
									'				 WHEN metodocaptura = ''"'||'05'||'"'' THEN ''"'||'CHIP'||'"'''||
									'				 WHEN metodocaptura = ''"'||'90'||'"'' THEN ''"'||'Deslizada'||'" '''||
									'				 WHEN metodocaptura = ''"'||'01'||'"''  AND   tipotransaccionposdigitada = ''"'||'AV'||'"''    THEN ''"'||'Telemarketing'||'"'''||
									'				 WHEN metodocaptura = ''"'||'01'||'"''  AND   tipotransaccionposdigitada = ''"'||'CE'||'"''    THEN ''"'||'Comercio_Elect'||'"'''||
									'				 WHEN metodocaptura = ''"'||'01'||'"''  AND   tipotransaccionposdigitada = ''"'||'CA'||'"''    THEN ''"'||'Cargo_Autómatico'||'"'''|| 
									'				 WHEN metodocaptura = ''"'||'01'||'"''  AND   tipotransaccionposdigitada = ''"'||'HO'||'"''    THEN ''"'||'Hotel'||'"'''||
--	2016.08.16 -I Se agrega <tipotransaccionposdigitada> tipo TAG:
									'				 WHEN metodocaptura = ''"'||'01'||'"''  AND   tipotransaccionposdigitada = ''"'||'TG'||'"''    THEN ''"'||'TAG'||'"'''||
--	2016.08.16 -F
									'				 WHEN metodocaptura = ''"'||'01'||'"''  AND   tipotransaccionposdigitada = ''"'||'ND'||'"''    THEN ''"'||'No_Determinada'||'"'''|| 
									'				 WHEN metodocaptura = ''"'||'01'||'"''  AND   tipotransaccionposdigitada = ''"'||'  '||'"''    THEN ''"'||'No_clasificada'||'"'''||
									'				 ELSE ''"'||'NULL'||'"'''||
									'			  END AS descripcion_metodo, '||
									'			  movh.codgironeg AS codigo_giro_neg, '||
									'			  movh.infreceptor AS descripcion_neg, '||
									'			  movh.monto AS monto,  '||
									'			  movh.codigoiso AS codigoiso, '||
									'			  movh.motivo AS motivorechazo '||
									'		FROM intercard:movimientohistorico AS movh, '||
									'			intercard:tarjeta AS tar, '||
									'			intercard:productotarjeta  AS pro, '||
									'			intercard:bines AS bines '||
									'		WHERE movh.fechahorainauth BETWEEN ''"'||primer_dia_mes_hora||'"'' AND ''"'||ultimo_dia_mes_hora||'"'' '||
									'			AND tar.numtarjeta                                         =    movh.numtarjeta  '||
									'			AND pro.codproductotarjeta                                 =    tar.codproductotarjeta  '||
									'			AND CAST(SUBSTRing(tar.numtarjeta from 1 for 6)AS CHAR(6)) =    bines.bin '||
									'			AND bines.creditodebito                                    =    ''"'||'D'||'"'''||
									'			AND movh.metodocaptura IN (''"'||'90'||'"'',''"'||'05'||'"'',''"'||'01'||'"'') '||
									'			AND movh.codigoiso IN (''"'||'61'||'"'',''"'||'65'||'"''); " >/resplogifx/RechazoDebito.sql';					
						SYSTEM vsql;
						LET vsql = ''; 
						LET vsql= 'dbaccess intercard /resplogifx/RechazoDebito.sql';
						SYSTEM vsql;
						LET vsql = '';
						LET vsql = "sed 's/|$//g' /resplogifx/RTX_BIN_DEBITO_RECHAZO.unl >>/resplogifx/RTX_BIN_DEBITO_RECHAZO_"||vaniomes2||".unl";
						SYSTEM vsql;
					    LET vsql = '';
						LET vsql ='rm /resplogifx/RechazoDebito.sql';
						SYSTEM vsql;
						LET vsql = '';
						LET vsql ='rm /resplogifx/RTX_BIN_DEBITO_RECHAZO.unl';
						SYSTEM vsql;
						--LET vsql = '';
						--LET vsql ='gzip -9 /resplogifx/RTX_BIN_DEBITO_RECHAZO_'|| vaniomes2 ||'.unl';
						--SYSTEM vsql;																		  
						--LET vsql = '';
						--LET vsql ='rm /resplogifx/RTX_BIN_DEBITO_RECHAZO_'|| vaniomes2 ||'.unl';
						--SYSTEM vsql;	
						
						LET vcodret   = '00000';
						LET p_mensaje = 'Reporte de tarjetas de debito rechazadas con código ISO 61 y 75 generado.';
						return vcodret, p_mensaje;			
				ELSE
						IF (vbin IN (SELECT bin FROM intercard:bines WHERE creditodebito IN ('D','C'))) THEN 
								-------REPORTE DEBITO
								IF(vbin IN (SELECT bin FROM intercard:bines WHERE creditodebito = 'D')) THEN
										-----VALIDA QUE LA TABLA NO EXISTA
										LET vexitetabla = 0;
										
										SELECT COUNT(*) INTO vexitetabla
										FROM sysmaster:SysTabNames
										WHERE partnum IS NOT NULL AND tabname = 'rmv_detalle_debito' AND dbsname= 'intercard';
										
										IF (vexitetabla > 0 ) THEN
											DROP TABLE intercard:rmv_detalle_debito;
										END IF;
										
										
										CREATE TABLE "informix".rmv_detalle_debito
										(
											bin				VARCHAR(6),
											num_tarjeta		VARCHAR(16),
											num_cliente		VARCHAR(13),
											cod_iso			VARCHAR(2),
											descrp_iso		VARCHAR(70),
											descrp_comercio	VARCHAR(40),
											monto			DECIMAL(19,4),
											fecha_hora		DATETIME YEAR TO SECOND,
											metodo_captura  VARCHAR(2),
											txn_origen 		VARCHAR(4),
											saldo_promedio  DECIMAL(18,2)
										)EXTENT SIZE 120 NEXT SIZE 120 LOCK MODE ROW;
										/****************************************************************/
										-------------------------DETALLE DEBITO--------------------------
										/****************************************************************/
										---CONSULTA DEBITO MOVIMIENTO
										INSERT INTO "informix".rmv_detalle_debito(bin, num_tarjeta, num_cliente, cod_iso,
																	   descrp_iso, descrp_comercio, monto,  fecha_hora,
																	   metodo_captura, txn_origen, saldo_promedio)
										SELECT SUBSTR(mv.numtarjeta,1,6) AS BIN,
												mv.numtarjeta AS NUM_TARJETA,
												tar.numcliente AS NUM_CLIENTE,
												mv.codigoiso AS COD_ISO,
												CASE
													WHEN mv.codigoiso = '00' THEN 'Transacción Exitosa'
													ELSE mv.motivo
												END AS DESCRP_ISO,
												mv.infreceptor AS DES_COMERCIO,
												mv.monto	   AS MONTO,
												mv.fechahorainauth AS FECHA_HORA,
												mv.metodocaptura AS METODO_CAPTURA,
												mv.transaccionorigen AS TXN_ORIGEN,
												 (NVL(sd.capvigacum,0)/(CASE 
																		   WHEN sd.diacum = 0 THEN 1 
																		   ELSE NVL(sd.diacum,1)
																		END
																	   )
												) AS SALDO_PROMEDIO
										FROM intercard:movimiento mv
											LEFT JOIN intercard:tarjeta tar
											ON (mv.numtarjeta = tar.numtarjeta)
											LEFT JOIN intercard:tarjetacuenta tc
											ON (tar.numtarjeta  = tc.numtarjeta)
											LEFT JOIN bdicheq:sc_sdodiarioc sd
											ON (tc.numcuenta=sd.cuenta and
											    sd.aniomes = vaniomes2)
										WHERE
											mv.fechahorainauth BETWEEN primer_dia_mes_hora AND ultimo_dia_mes_hora---fecha
											AND mv.formato                 =       '0200'
											AND UPPER(mv.infreceptor)   LIKE       '%COPPEL%'
											AND mv.prodind                 =       '02'
											AND mv.movreversado 		   =	   'F' 
											AND mv.codreversa 			   = 	   '0' 
											AND SUBSTR(mv.numtarjeta,1,6)  =        vbin;
											
										
										---CONSULTA DEBITO MOVIMIENTOHISTORICO
										INSERT INTO "informix".rmv_detalle_debito(bin, num_tarjeta, num_cliente, cod_iso,
																	   descrp_iso, descrp_comercio, monto,  fecha_hora,
																	   metodo_captura, txn_origen, saldo_promedio)
										SELECT SUBSTR(mv.numtarjeta,1,6) AS BIN,
												mv.numtarjeta AS NUM_TARJETA,
												tar.numcliente AS NUM_CLIENTE,
												mv.codigoiso AS COD_ISO,
												CASE
													WHEN mv.codigoiso = '00' THEN 'Transacción Exitosa'
													ELSE mv.motivo
												END AS DESCRP_ISO,
												mv.infreceptor AS DES_COMERCIO,
												mv.monto	   AS MONTO,
												mv.fechahorainauth AS FECHA_HORA,
												mv.metodocaptura AS METODO_CAPTURA,
												mv.transaccionorigen AS TXN_ORIGEN,
												 (NVL(sd.capvigacum,0)/(CASE 
																		   WHEN sd.diacum = 0 THEN 1 
																		   ELSE NVL(sd.diacum,1)
																		END
																	   )
												) AS SALDO_PROMEDIO
										FROM intercard:movimientohistorico mv
											LEFT JOIN intercard:tarjeta tar
											ON (mv.numtarjeta = tar.numtarjeta)
											LEFT JOIN intercard:tarjetacuenta tc
											ON (tar.numtarjeta  = tc.numtarjeta)
											LEFT JOIN bdicheq:sc_sdodiarioc sd
											ON (tc.numcuenta=sd.cuenta and
											    sd.aniomes = vaniomes2)
										WHERE
											mv.fechahorainauth BETWEEN primer_dia_mes_hora AND ultimo_dia_mes_hora---fecha
											AND mv.formato                 =       '0200'
											AND UPPER(mv.infreceptor)   LIKE       '%COPPEL%'
											AND mv.prodind                 =       '02'
											AND mv.movreversado 		   =	   'F' 
											AND mv.codreversa 			   = 	   '0' 
											AND SUBSTR(mv.numtarjeta,1,6)  =        vbin;
										----Genera el Reporte Detalle TDD
										LET vsql = ''; 	   
										LET vsql = 'echo "BIN|Número Tarjeta|Número Cliente|Código ISO|Descripción ISO|Descripción Comercio|Monto|Fecha / Hora Transacción|Método Captura|Txn. Origen|Saldo Promedio|">/resplogifx/Txns_Detalle_TDD_Coppel_'||vbin||'_'|| vaniomes2 ||'.txt';
										SYSTEM vsql;
										LET vsql = '';
										LET vsql = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 4; UNLOAD TO /resplogifx/Txns_Detalle_TDD_Coppel.txt SELECT * FROM rmv_detalle_debito;">/resplogifx/Script_Detalle_TDD_Coppel.sql';
										SYSTEM vsql;
										LET vsql ='';
										LET vsql= 'dbaccess intercard /resplogifx/Script_Detalle_TDD_Coppel.sql';
										SYSTEM vsql;
										LET vsql = '';
										LET vsql ='rm /resplogifx/Script_Detalle_TDD_Coppel.sql';
										SYSTEM vsql;
										LET vsql ='';
										LET vsql = "sed 's/|$//g' /resplogifx/Txns_Detalle_TDD_Coppel.txt >>/resplogifx/Txns_Detalle_TDD_Coppel_"||vbin||"_"||vaniomes2||".txt";
										SYSTEM vsql;
										LET vsql ='rm /resplogifx/Txns_Detalle_TDD_Coppel.txt';
										SYSTEM vsql;
										LET vsql ='';
										
										/****************************************************************/
										----------------------------RESUMEN DEBITO-----------------------
										/****************************************************************/
										
										-----------GENERA EL REPORTE
										
										LET vsql = ''; 
										LET vsql = 'echo "BIN|Código ISO|Descripción ISO|Método Captura|Txn. Origen|No. Txn|Monto|">/resplogifx/Txns_Resumen_TDD_Coppel_'||vbin||'_'|| vaniomes2 ||'.txt';
										SYSTEM vsql;
										LET vsql = ''; 
										LET vsql = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 4; UNLOAD TO /resplogifx/Txns_Resumen_TDD_Coppel.txt '||
													'SELECT bin, '||
													'	cod_iso, '||
													'	descrp_iso, '||
													'	metodo_captura, '||
													'	txn_origen, '||
													'	COUNT(re.num_tarjeta) AS num_txn, '||
													'	SUM(re.monto) AS monto_total '||
													'FROM rmv_detalle_debito re '||
													'GROUP BY 1,2,3,4,5; " >/resplogifx/Script_Resumen_TDD_Coppel.sql';	
										SYSTEM vsql;
										LET vsql = ''; 
										LET vsql= 'dbaccess intercard /resplogifx/Script_Resumen_TDD_Coppel.sql';
										SYSTEM vsql;
										LET vsql = '';
										LET vsql ='rm /resplogifx/Script_Resumen_TDD_Coppel.sql';
										SYSTEM vsql;
										LET vsql = '';
										LET vsql = "sed 's/|$//g' /resplogifx/Txns_Resumen_TDD_Coppel.txt >>/resplogifx/Txns_Resumen_TDD_Coppel_"||vbin||"_"||vaniomes2||".txt";
										SYSTEM vsql;
										LET vsql = '';
										LET vsql ='rm /resplogifx/Txns_Resumen_TDD_Coppel.txt';
										SYSTEM vsql;
										
										DROP TABLE intercard:rmv_detalle_debito;
										
										LET vcodret   = '00000';
										LET p_mensaje = 'Reporte Resumen y Detalle de TDD con BIN '||vbin||' Generado';
										RETURN vcodret, p_mensaje;								
								-----REPORTE CREDITO
								ELSE
										-----VALIDA QUE LA TABLA NO EXISTA
										LET vexitetabla = 0;
										SELECT COUNT(*) INTO vexitetabla
										FROM sysmaster:SysTabNames
										WHERE partnum IS NOT NULL AND tabname = 'rmv_detalle_credito' AND dbsname= 'intercard';
										
										IF (vexitetabla > 0 ) THEN
											DROP TABLE intercard:rmv_detalle_credito;
										END IF;										
										CREATE TABLE "informix".rmv_detalle_credito
										(
											bin				VARCHAR(6),
											num_tarjeta		VARCHAR(16),
											num_cliente		VARCHAR(13),
											cod_iso			VARCHAR(2),
											descrp_iso		VARCHAR(70),
											descrp_comercio	VARCHAR(40),
											monto			DECIMAL(19,4),
											fecha_hora		DATETIME YEAR TO SECOND,
											metodo_captura  VARCHAR(2),
											txn_origen 		VARCHAR(4),
											linea_credito   DECIMAL(18,2)
										)EXTENT SIZE 120 NEXT SIZE 120 LOCK MODE ROW;
										/****************************************************************/
										-------------------------DETALLE CREDITO-------------------------
										/****************************************************************/
										---CONSULTA CREDITO MOVIMIENTO
										INSERT INTO "informix".rmv_detalle_credito(bin, num_tarjeta, num_cliente, cod_iso,
																	   descrp_iso, descrp_comercio, monto,  fecha_hora,
																	   metodo_captura, txn_origen, linea_credito)
										SELECT SUBSTR(mv.numtarjeta,1,6) AS BIN,
												mv.numtarjeta AS NUM_TARJETA,
												tar.numcliente AS NUM_CLIENTE,
												mv.codigoiso AS COD_ISO,
												CASE
													WHEN mv.codigoiso = '00' THEN 'Transacción Exitosa'
													ELSE mv.motivo
												END AS DESCRP_ISO,
												mv.infreceptor AS DES_COMERCIO,
												mv.monto	   AS MONTO,
												mv.fechahorainauth AS FECHA_HORA,
												mv.metodocaptura AS METODO_CAPTURA,
												mv.transaccionorigen AS TXN_ORIGEN,
												sd.monto_otorgado AS LINEA_CREDITO
										FROM intercard:movimiento mv
											LEFT JOIN intercard:tarjeta tar
											ON (mv.numtarjeta = tar.numtarjeta)
											LEFT JOIN intercard:tarjetacuenta tc
											ON (tar.numtarjeta  = tc.numtarjeta)
											LEFT JOIN bdicred:sd_maesdos sd
											ON (tc.numcuenta=sd.num_credito)
										WHERE
											mv.fechahorainauth BETWEEN primer_dia_mes_hora AND ultimo_dia_mes_hora---fecha
											AND mv.formato                 =       '0200'
											AND UPPER(mv.infreceptor)   LIKE       '%COPPEL%'
											AND mv.prodind                 =       '02'
											AND mv.movreversado 		   =	   'F' 
											AND mv.codreversa 			   = 	   '0'
											AND SUBSTR(mv.numtarjeta,1,6)  =       vbin;
										
																	
										---CONSULTA CREDITO MOVIMIENTOHISTORICO
										INSERT INTO "informix".rmv_detalle_credito(bin, num_tarjeta, num_cliente, cod_iso,
																	   descrp_iso, descrp_comercio, monto,  fecha_hora,
																	   metodo_captura, txn_origen, linea_credito)
										SELECT SUBSTR(mv.numtarjeta,1,6) AS BIN,
												mv.numtarjeta AS NUM_TARJETA,
												tar.numcliente AS NUM_CLIENTE,
												mv.codigoiso AS COD_ISO,
												CASE
													WHEN mv.codigoiso = '00' THEN 'Transacción Exitosa'
													ELSE mv.motivo
												END AS DESCRP_ISO,
												mv.infreceptor AS DES_COMERCIO,
												mv.monto	   AS MONTO,
												mv.fechahorainauth AS FECHA_HORA,
												mv.metodocaptura AS METODO_CAPTURA,
												mv.transaccionorigen AS TXN_ORIGEN,
												sd.monto_otorgado AS LINEA_CREDITO
										FROM intercard:movimientohistorico mv
											LEFT JOIN intercard:tarjeta tar
											ON (mv.numtarjeta = tar.numtarjeta)
											LEFT JOIN intercard:tarjetacuenta tc
											ON (tar.numtarjeta  = tc.numtarjeta)
											LEFT JOIN bdicred:sd_maesdos sd
											ON (tc.numcuenta=sd.num_credito)
										WHERE
											mv.fechahorainauth BETWEEN primer_dia_mes_hora AND ultimo_dia_mes_hora---fecha
											AND mv.formato                 =       '0200'
											AND UPPER(mv.infreceptor)   LIKE       '%COPPEL%'
											AND mv.prodind                 =       '02'
											AND mv.movreversado 		   =	   'F' 
											AND mv.codreversa 			   = 	   '0'
											AND SUBSTR(mv.numtarjeta,1,6)  =       vbin;
											
										----Genera el Reporte Detalle TDD
										LET vsql = ''; 	   
										LET vsql = 'echo "BIN|Número Tarjeta|Número Cliente|Código ISO|Descripción ISO|Descripción Comercio|Monto|Fecha / Hora Transacción|Método Captura|Txn. Origen|Línea de Crédito|">/resplogifx/Txns_Detalle_TDC_Coppel_'||vbin||'_'|| vaniomes2 ||'.txt';
										SYSTEM vsql;
										LET vsql = '';
										LET vsql = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 4; UNLOAD TO /resplogifx/Txns_Detalle_TDC_Coppel.txt SELECT * FROM rmv_detalle_credito;">/resplogifx/Script_Detalle_TDC_Coppel.sql';
										SYSTEM vsql;
										LET vsql ='';
										LET vsql= 'dbaccess intercard /resplogifx/Script_Detalle_TDC_Coppel.sql';
										SYSTEM vsql;
										LET vsql = '';
										LET vsql ='rm /resplogifx/Script_Detalle_TDC_Coppel.sql';
										SYSTEM vsql;
										LET vsql ='';
										LET vsql = "sed 's/|$//g' /resplogifx/Txns_Detalle_TDC_Coppel.txt >>/resplogifx/Txns_Detalle_TDC_Coppel_"||vbin||"_"||vaniomes2||".txt";
										SYSTEM vsql;
										LET vsql ='rm /resplogifx/Txns_Detalle_TDC_Coppel.txt';
										SYSTEM vsql;
										LET vsql ='';	
											
										/****************************************************************/
										--------------------------RESUMEN CREDITO------------------------
										/****************************************************************/
										-----------GENERA EL REPORTE
										LET vsql = ''; 
										LET vsql = 'echo "BIN|Código ISO|Descripción ISO|Método Captura|Txn. Origen|No. Txn|Monto|">/resplogifx/Txns_Resumen_TDC_Coppel_'||vbin||'_'|| vaniomes2 ||'.txt';
										SYSTEM vsql;
										LET vsql = ''; 
										LET vsql = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 4; UNLOAD TO /resplogifx/Txns_Resumen_TDC_Coppel.txt '||
													'SELECT bin, '||
													'	cod_iso, '||
													'	descrp_iso, '||
													'	metodo_captura, '||
													'	txn_origen, '||
													'	COUNT(num_tarjeta) AS num_txn, '||
													'	SUM(monto) AS monto_total '||
													'FROM rmv_detalle_credito '||
													'GROUP BY 1,2,3,4,5; " >/resplogifx/Script_Resumen_TDC_Coppel.sql';	
										SYSTEM vsql;
										LET vsql = ''; 
										LET vsql= 'dbaccess intercard /resplogifx/Script_Resumen_TDC_Coppel.sql';
										SYSTEM vsql;
										LET vsql = '';
										LET vsql ='rm /resplogifx/Script_Resumen_TDC_Coppel.sql';
										SYSTEM vsql;
										LET vsql = '';
										LET vsql = "sed 's/|$//g' /resplogifx/Txns_Resumen_TDC_Coppel.txt >>/resplogifx/Txns_Resumen_TDC_Coppel_"||vbin||"_"||vaniomes2||".txt";
										SYSTEM vsql;
										LET vsql = '';
										LET vsql ='rm /resplogifx/Txns_Resumen_TDC_Coppel.txt';
										SYSTEM vsql;
										
										DROP TABLE intercard:rmv_detalle_credito;									
										LET vcodret   = '00000';
										LET p_mensaje = 'Reporte Resumen y Detalle de TDC Generado ';
										RETURN vcodret, p_mensaje;
								END IF;
						ELSE 
								LET vcodret = '002';
								LET  p_mensaje  = 'BIN invalido';
								RETURN vcodret, p_mensaje;
						END IF;
				END IF;			
		ELSE 
				LET vcodret   = '001';
				LET p_mensaje = 'Parametro Invalido';
				RETURN vcodret, p_mensaje;	
		END IF;
	END;
END PROCEDURE;