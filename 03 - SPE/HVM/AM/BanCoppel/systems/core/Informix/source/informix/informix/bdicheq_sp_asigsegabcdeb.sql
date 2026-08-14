CREATE PROCEDURE "informix".sp_asigsegabcdeb(	P_ACCION SMALLINT,
													P_NUM_PROD CHAR(3),
													P_NUM_PROD_NEW CHAR(3),
													P_NUM_PROD_GAMA CHAR(3),
													P_TIPO_CTA CHAR(20),
													P_NOM_CTA CHAR(20),
													P_MTOMIN DECIMAL(18,2),
													P_MTOMAX DECIMAL(18,2),
													P_TXN_DIA CHAR(2),
													P_TXN_MES CHAR(2))														
                                                
RETURNING	CHAR(6) 		AS Cod_ret,		--cCod_ret
			CHAR(80) 		AS Mensaje,		--cMensaje
			CHAR(3) 		AS Num_prodcto,	--cNum_prodcto
			CHAR(3) 		AS prodcto_gama,--cNum_prodcto	
			CHAR(20) 		AS Tipo_cta,	--cTipo_cta
			CHAR(20) 		AS Nom_cta,		--cNom_cta
			DECIMAL(18,2) 	AS Mto_min,  	--mMto_min
			DECIMAL(18,2) 	AS Mto_max,  	--mMto_max
			CHAR(2) 		AS Txn_dia,		--cTxn_dia
			CHAR(2) 		AS Txn_mes;		--cTxn_mes
			
--DEFINICION DE VARIABLES
DEFINE cCod_ret         CHAR(6);
DEFINE sSql_err         SMALLINT;
DEFINE sIsam_err        SMALLINT;
DEFINE cError_info      CHAR(40);
DEFINE cMensaje         CHAR(80);
DEFINE cNum_prodcto     CHAR(3);
DEFINE cNum_prodcto_g   CHAR(3);
DEFINE cTipo_cta		CHAR(20);
DEFINE cNom_cta         CHAR(20);
DEFINE mMto_min      	MONEY(18, 2);
DEFINE mMto_max			MONEY(18, 2);	
DEFINE cTxn_dia         CHAR(2);
DEFINE cTxn_mes         CHAR(2);
DEFINE cEmpresa			CHAR(3);
DEFINE sContador		SMALLINT;	

--SET DEBUG FILE TO "/tmp/sp_asigsegabcdeb.out";
--TRACE ON;

-- INICIALIZACION DE VARIABLES
LET cCod_ret = '000000';
LET sSql_err = 0;
LET sIsam_err = 0;
LET cError_info = '';
LET cMensaje = 'Operacion Realizada Exitosamente';	
LET cNum_prodcto = '';
LET cNum_prodcto_g = '';
LET cTipo_cta = '';
LET cNom_cta = '';
LET mMto_min = 0.0;
LET mMto_max = 0.0;
LET cTxn_dia = '';
LET cTxn_mes = '';
LET cEmpresa = '001';
LET sContador = 0;
	
BEGIN
	ON EXCEPTION SET sSql_err, sIsam_err, cError_info		
		IF sSql_err <> 0 then		
			LET cCod_ret = sSql_err;
			LET cMensaje = cError_info;
			RETURN	NVL(TRIM(cCod_ret), ''),
					NVL(TRIM(cMensaje), ''),
					NVL(TRIM(cNum_prodcto), ''),
					NVL(TRIM(cNum_prodcto_g), ''),
					NVL(TRIM(cTipo_cta), ''),
					NVL(TRIM(cNom_cta), ''),
					NVL(mMto_min, 0.0),
					NVL(mMto_max, 0.0),
					NVL(TRIM(cTxn_dia), ''),
					NVL(TRIM(cTxn_mes), '');
		END IF	  
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF NVL(P_ACCION, 0) = 0 THEN
		LET cCod_ret = "000001";
		LET cMensaje = "Valor de la accion es nulo";
		RETURN	NVL(TRIM(cCod_ret), ''),
					NVL(TRIM(cMensaje), ''),
					NVL(TRIM(cNum_prodcto), ''),
					NVL(TRIM(cNum_prodcto_g), ''),
					NVL(TRIM(cTipo_cta), ''),
					NVL(TRIM(cNom_cta), ''),
					NVL(mMto_min, 0.0),
					NVL(mMto_max, 0.0),
					NVL(TRIM(cTxn_dia), ''),
					NVL(TRIM(cTxn_mes), '');		
	END IF;
	
	IF 	P_ACCION <= 5 THEN	
		IF 	P_ACCION = 1 THEN --es consulta
			FOREACH				
				SELECT num_prod, NVL(num_prod_gama, ''), tipo_cta, nombre, sdo_prom_min, sdo_prom_max, txn_dia, txn_mes
				  INTO cNum_prodcto, cNum_prodcto_g, cTipo_cta, cNom_cta, mMto_min, mMto_max, cTxn_dia, cTxn_mes
				  FROM "informix".sc_segmentos
				 WHERE empresa = cEmpresa
				 ORDER BY sdo_prom_min ASC
			  
				  RETURN	NVL(TRIM(cCod_ret), ''),
							NVL(TRIM(cMensaje), ''),
							NVL(TRIM(cNum_prodcto), ''),
							NVL(TRIM(cNum_prodcto_g), ''),
							NVL(TRIM(cTipo_cta), ''),
							NVL(TRIM(cNom_cta), ''),
							NVL(mMto_min, 0.0),
							NVL(mMto_max, 0.0),
							NVL(TRIM(cTxn_dia), ''),
							NVL(TRIM(cTxn_mes), '') WITH RESUME;
							
							LET sContador = sContador + 1;
			  
			END FOREACH;
			--SE VALIDA SI SE REGRESAN REGISTROS
			IF sContador = 0  THEN
				LET cCod_ret = '000002';
				LET cMensaje = "No hay datos para mostrar";
				RETURN	NVL(TRIM(cCod_ret), ''),
						NVL(TRIM(cMensaje), ''),
						NVL(TRIM(cNum_prodcto), ''),
						NVL(TRIM(cNum_prodcto_g), ''),
						NVL(TRIM(cTipo_cta), ''),
						NVL(TRIM(cNom_cta), ''),
						NVL(mMto_min, 0.0),
						NVL(mMto_max, 0.0),
						NVL(TRIM(cTxn_dia), ''),
						NVL(TRIM(cTxn_mes), '');
			END IF;			
			
		ELIF 	P_ACCION = 2 THEN --es modificacion
				LET sContador = 0;
				IF ( TRIM(NVL(P_NUM_PROD,'')) = "") OR ( TRIM(NVL(P_NUM_PROD_NEW,'')) = "") OR ( TRIM(NVL(P_TIPO_CTA,'')) = "") OR ( TRIM(NVL(P_NOM_CTA,'')) = "")
					OR ( TRIM(NVL(P_NUM_PROD_NEW,'')) = TRIM(NVL(P_NUM_PROD_GAMA,''))  ) THEN					
					LET cCod_ret = "000003";
					LET cMensaje = "Hay valores no permitidos";
				ELSE					
					SELECT	num_prod, num_prod_gama
					  INTO	cNum_prodcto, cNum_prodcto_g
					  FROM	"informix".sc_segmentos
					 WHERE	num_prod= P_NUM_PROD AND empresa = cEmpresa;
					 
						--VALIDAR SI EL REGISTRO EXISTE
					IF 	NVL(cNum_prodcto,'') = ''  THEN
						LET cCod_ret = '000004';
						LET cMensaje = "El número de producto no existe";
					ELSE
						--VALIDAR SI ES PADRE O HIJO
						IF 	NVL(cNum_prodcto_g,'') = ''  THEN
							--ES UN PRODUCTO GAMA HIJO
							IF 	P_NUM_PROD <> P_NUM_PROD_NEW  THEN
								--VALIDAR DISPONIBILIDAD PARA P_NUM_PROD_NEW
								SELECT COUNT(*)
								INTO   sContador
								FROM   "informix".sc_segmentos
								WHERE  (num_prod= P_NUM_PROD_NEW OR num_prod_gama= P_NUM_PROD_NEW )
								AND    empresa = cEmpresa;
								
								IF NVL(sContador,0) = 0  THEN
									--ESTA DISPONIBLE
									UPDATE	"informix".sc_segmentos
									   SET	num_prod= P_NUM_PROD_NEW,
											tipo_cta= P_TIPO_CTA,
											nombre= P_NOM_CTA,
											sdo_prom_min= P_MTOMIN,
											sdo_prom_max= P_MTOMAX,
											txn_dia= P_TXN_DIA,
											txn_mes= P_TXN_MES
									 WHERE	num_prod= P_NUM_PROD
									 AND	empresa = cEmpresa;									 
									 
									IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
										LET cCod_ret = '000005';
										LET cMensaje = "Problemas al actualizar segmento gama";
									ELSE
										--ACTUALIZAR SU PRODUCTO PADRE, EL CAMPO DEL SEGMENTO GAMA
										LET sContador = 0;
										SELECT  COUNT(*)
										  INTO  sContador
										  FROM  "informix".sc_segmentos
										 WHERE  num_prod_gama = P_NUM_PROD
										   AND  empresa = cEmpresa;
											   
											IF NVL(sContador,0) > 0  THEN
												--TIENE PADRE, LO PROCEDEMOS A ACTUALIAR CON SU NUEVO PRODUCTO GAMA
												UPDATE	"informix".sc_segmentos
												   SET	num_prod_gama = P_NUM_PROD_NEW															
												 WHERE	num_prod_gama = P_NUM_PROD
												   AND  empresa = cEmpresa;
												 
												IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
													LET cCod_ret = '000030';
													LET cMensaje = "Problemas al actualizar segmento gama";												
												END IF;												
											END IF;
									END IF;									
								ELSE
									--NO DISPONIBLE
									LET cCod_ret = '000006';
									LET cMensaje = "El nuevo Número de producto no esta disponible";
								END IF;								
							ELSE
								--EL VALOR DEL P_NUM_PROD NO CAMBIA, NO SE INCLUYE EN INSTRUCCION UPDATE
								 UPDATE	"informix".sc_segmentos
									SET	tipo_cta= P_TIPO_CTA,
										nombre= P_NOM_CTA,
										sdo_prom_min= P_MTOMIN,
										sdo_prom_max= P_MTOMAX,
										txn_dia= P_TXN_DIA,
										txn_mes= P_TXN_MES
								WHERE	num_prod= P_NUM_PROD AND empresa = cEmpresa;
								
								IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
									LET cCod_ret = '000007';
									LET cMensaje = "Problemas al actualizar segmento gama";											
								END IF;
							END IF;							
						ELSE
							--ES UN PRODUCTO PADRE							
							IF 	P_NUM_PROD <> P_NUM_PROD_NEW  THEN
								--VALIDAR SI EL NUM_PRODUCTO PROPUESTO ESTA DISPONIBLE
								SELECT COUNT(*)
								INTO   sContador
								FROM   "informix".sc_segmentos
								WHERE  (num_prod= P_NUM_PROD_NEW OR num_prod_gama= P_NUM_PROD_NEW )
								AND    empresa = cEmpresa;
								
								IF sContador = 0  THEN
									--NO SE ENCONTRO, P_NUM_PROD_NEW ESTA DISPONIBLE,
									--SE CONTINUA A VALIDAR DISPONIBILIDAD PARA EL NUM_PRODCTO GAMA
									IF 	cNum_prodcto_g <> P_NUM_PROD_GAMA  THEN
									
										SELECT COUNT(*)
										INTO   sContador
										FROM   "informix".sc_segmentos
										WHERE  (num_prod= P_NUM_PROD_GAMA OR num_prod_gama= P_NUM_PROD_GAMA )
										AND    empresa = cEmpresa;
										
										IF sContador = 0  THEN
											--P_NUM_PROD_GAMA SI ESTA DISPONIBLE,											
											--VALIDAR SI ESTE PRODUCTO PADRE TIENE HIJO
											LET sContador = 0;
											SELECT COUNT(*)
											  INTO  sContador
											  FROM  "informix".sc_segmentos
											 WHERE  num_prod= TRIM(cNum_prodcto_g) 
											   AND  empresa = cEmpresa;
											   
											IF NVL(sContador,0) > 0  THEN
												--TIENE HIJO, LO PROCEDEMOS A ACTUALIAR CON SU NUEVO PRODUCTO
												UPDATE	"informix".sc_segmentos
												   SET	num_prod= P_NUM_PROD_GAMA															
												 WHERE	num_prod= TRIM(cNum_prodcto_g)
												   AND  empresa = cEmpresa;
												 
												IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
													LET cCod_ret = '000008';
													LET cMensaje = "Problemas al actualizar segmento gama";
												ELSE
													UPDATE	"informix".sc_segmentos
													   SET	num_prod= P_NUM_PROD_NEW,
															num_prod_gama= P_NUM_PROD_GAMA,
															tipo_cta= P_TIPO_CTA,
															nombre= P_NOM_CTA,
															sdo_prom_min= P_MTOMIN,
															sdo_prom_max= P_MTOMAX,
															txn_dia= P_TXN_DIA,
															txn_mes= P_TXN_MES
													 WHERE	num_prod= P_NUM_PROD AND empresa = cEmpresa;
												END IF;												
											END IF;
										ELSE
											LET cCod_ret = '000009';
											LET cMensaje = "Producto gama no disponible";
										END IF;
									ELSE
										--EL PRODUCTO NO CAMBIO
										UPDATE	"informix".sc_segmentos
										   SET	num_prod= P_NUM_PROD_NEW,												
												tipo_cta= P_TIPO_CTA,
												nombre= P_NOM_CTA,
												sdo_prom_min= P_MTOMIN,
												sdo_prom_max= P_MTOMAX,
												txn_dia= P_TXN_DIA,
												txn_mes= P_TXN_MES
										 WHERE	num_prod= P_NUM_PROD AND empresa = cEmpresa;
										 --VALIDAR SI SE LOGRO ACTUALIZAR REGISTRO
										 IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
											LET cCod_ret = '000010';
											LET cMensaje = "Problemas al actualizar segmento";
										END IF;
									END IF;									
								ELSE
									--NO DISPONIBLE
									LET cCod_ret = '000011';
									LET cMensaje = "Número de producto NO disponible";									
								END IF;								
							ELSE
								--SE VALIDARA P_NUM_PROD_GAMA
								IF 	cNum_prodcto_g <> P_NUM_PROD_GAMA  THEN
									SELECT COUNT(*)
									INTO   sContador
									FROM   "informix".sc_segmentos
									WHERE  (num_prod= P_NUM_PROD_GAMA OR num_prod_gama= P_NUM_PROD_GAMA )
									AND    empresa = cEmpresa;
										
									IF sContador = 0  THEN
										--P_NUM_PROD_GAMA DISPONIBLE,
										--SE CONTINUA A ACTUALIZAR REGISTRO CON VALORES PROPUESTOS
										UPDATE	"informix".sc_segmentos
										   SET	num_prod_gama= P_NUM_PROD_GAMA,
												tipo_cta= P_TIPO_CTA,
												nombre= P_NOM_CTA,
												sdo_prom_min= P_MTOMIN,
												sdo_prom_max= P_MTOMAX,
												txn_dia= P_TXN_DIA,
												txn_mes= P_TXN_MES
										 WHERE	num_prod= P_NUM_PROD AND empresa = cEmpresa;
										 --VALIDAR SI SE LOGRO ACTUALIZAR REGISTRO
										 IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
											LET cCod_ret = '000012';
											LET cMensaje = "Problemas al actualizar segmento";
										ELSE
											--LIMPIAR CONTADOR PARA VERIFICAR SI EL SEGMENTO TIENE UN HIJO
											LET sContador = 0;
											 SELECT COUNT(*)
											  INTO  sContador
											  FROM  "informix".sc_segmentos
											 WHERE  num_prod= TRIM(cNum_prodcto_g) 
											   AND  empresa = cEmpresa;
											   
											IF NVL(sContador,0) > 0  THEN
												--TIENE HIJO, LO PROCEDEMOS A ACTUALIAR CON SU NUEVO PRODUCTO
												UPDATE	"informix".sc_segmentos
												   SET	num_prod= P_NUM_PROD_GAMA															
												 WHERE	num_prod= TRIM(cNum_prodcto_g)
												   AND  empresa = cEmpresa;
												 
												IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
													LET cCod_ret = '000031';
													LET cMensaje = "Problemas al actualizar segmento gama";												
												END IF;												
											END IF;
										END IF;
									ELSE
										LET cCod_ret = '000013';
										LET cMensaje = "El producto gama no esta disponible";									
									END IF;
								ELSE
									UPDATE	"informix".sc_segmentos
										SET	tipo_cta= P_TIPO_CTA,
											nombre= P_NOM_CTA,
											sdo_prom_min= P_MTOMIN,
											sdo_prom_max= P_MTOMAX,
											txn_dia= P_TXN_DIA,
											txn_mes= P_TXN_MES
									WHERE	num_prod= P_NUM_PROD AND empresa = cEmpresa;
								
									IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
										LET cCod_ret = '000014';
										LET cMensaje = "Problemas al actualizar segmento";							
									END IF;
								END IF;
							END IF;							
						END IF;						
					END IF;					
				END IF;		
		ELIF 	P_ACCION = 3 THEN --es insertion
				IF ( TRIM(NVL(P_NUM_PROD,'')) = "") OR ( TRIM(NVL(P_NUM_PROD_GAMA,'')) = "") OR ( TRIM(NVL(P_TIPO_CTA,'')) = "")
					OR ( TRIM(NVL(P_NOM_CTA,'')) = "") OR ( NVL(P_MTOMAX,0) = 0 ) THEN					
					LET cCod_ret = "000015";
					LET cMensaje = "Hay valores no permitidos en blanco";						
				ELSE
					IF 	P_MTOMAX > P_MTOMIN  THEN
						--LOS NUMEROS DE PRODUCTO NORMAL Y PRODUCTO GAMA DEBEN SER DIFERENTES
						IF 	P_NUM_PROD <> P_NUM_PROD_GAMA  THEN					
							SELECT	COUNT(*)
							  INTO	sContador
							  FROM	"informix".sc_segmentos
							 WHERE	(num_prod=P_NUM_PROD OR num_prod_gama= P_NUM_PROD)  AND	empresa = cEmpresa;
							 
							IF 	NVL(sContador,0) = 0  THEN
								--EL NUMERO DEL PRODUCTO NO ESTA ASIGNADO AUN							
								LET sContador = 0;
								SELECT	COUNT(*)
								  INTO	sContador
								  FROM	"informix".sc_segmentos
								 WHERE	(num_prod= P_NUM_PROD_GAMA OR num_prod_gama= P_NUM_PROD_GAMA) AND empresa = cEmpresa;
								 
								IF 	NVL(sContador,0) = 0  THEN
									--EL SEGMENTO GAMA NO EXISTE, SE HACE LA ALTA DEL REGISTRO
									INSERT INTO	"informix".sc_segmentos
												(empresa, num_prod, num_prod_gama, tipo_cta, nombre, sdo_prom_min,
												sdo_prom_max, txn_dia, txn_mes )
										 VALUES ( cEmpresa, P_NUM_PROD, P_NUM_PROD_GAMA, P_TIPO_CTA,
												P_NOM_CTA, P_MTOMIN, P_MTOMAX, P_TXN_DIA, P_TXN_MES);
											
										IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
											LET cCod_ret = '000016';											LET cMensaje = "Problemas al guardar los datos";											
										END IF;
								ELSE				
									LET cCod_ret = '000017';
									LET cMensaje = "El Número de producto gama ya existe";
								END IF;							
							ELSE				
								LET cCod_ret = '000018';
								LET cMensaje = "El Número de producto ya existe";							
							END IF;
						ELSE				
							LET cCod_ret = '000019';
							LET cMensaje = "Los productos deben ser diferentes";
						END IF;
					ELSE				
						LET cCod_ret = '000020';
						LET cMensaje = "El limite Máximo debe ser mayor que el limite Mínimo";
					END IF;						
				END IF;
		ELIF 	P_ACCION = 4 THEN --es insertion para el tipo gama
				IF ( TRIM(NVL(P_NUM_PROD,'')) = "") OR ( TRIM(NVL(P_TIPO_CTA,'')) = "") OR ( TRIM(NVL(P_NOM_CTA,'')) = "")
					OR ( TRIM(NVL(P_TXN_DIA,'')) = "") OR ( TRIM(NVL(P_TXN_MES,'')) = "") THEN					
					LET cCod_ret = "000021";
					LET cMensaje = "Hay valores no permitidos";						
				ELSE
				
					SELECT	COUNT(*)
					  INTO	sContador
					  FROM	"informix".sc_segmentos
					 WHERE	num_prod=P_NUM_PROD AND	empresa = cEmpresa;
					 
					IF 	NVL(sContador,0) = 0  THEN
						LET sContador = 0;
						--EL NUMERO DEL PRODUCTO NO ESTA REGISTRADO COMO ALTA
						SELECT	COUNT(*)
						  INTO	sContador
						  FROM	"informix".sc_segmentos
						 WHERE	num_prod_gama=P_NUM_PROD AND empresa = cEmpresa;
						 --EL PRODUCTO DEBERIA ESTAR ASIGNADO COMO GAMA
						IF 	NVL(sContador,0) = 0  THEN							
							LET cCod_ret = '000022';
							LET cMensaje = "Producto gama no esta asignado";								
						ELSE							
							INSERT INTO	"informix".sc_segmentos
											(empresa,	num_prod,	num_prod_gama,	tipo_cta,	nombre,	sdo_prom_min,	sdo_prom_max,	txn_dia,	txn_mes )
									 VALUES ( cEmpresa,	P_NUM_PROD,	'',	P_TIPO_CTA,	P_NOM_CTA, P_MTOMIN, P_MTOMAX,	P_TXN_DIA,	P_TXN_MES);
										
									IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
										LET cCod_ret = '000023';										LET cMensaje = "Problemas al guardar los datos";											
									END IF;
						END IF;
					ELSE				
						LET cCod_ret = '000024';
						LET cMensaje = "El Número de producto ya existe";							
					END IF;
				END IF;
		ELIF 	P_ACCION = 5 THEN --es borrado de segmento
				IF ( TRIM(NVL(P_NUM_PROD,'')) = "") THEN					
					LET cCod_ret = "000025";
					LET cMensaje = "El Número de producto esta en Blanco";						
				ELSE
					--VALIDAR SI ES PADRE O HIJO
					SELECT	num_prod, num_prod_gama
					  INTO	cNum_prodcto, cNum_prodcto_g
					  FROM	"informix".sc_segmentos
					 WHERE	num_prod= P_NUM_PROD AND empresa = cEmpresa;
					 
					IF 	NVL(cNum_prodcto,'') = ''  THEN
						LET cCod_ret = '000026';
						LET cMensaje = "El Número de producto no existe";
					ELSE
						IF 	NVL(cNum_prodcto_g,'') = ''  THEN
							--ES UN PRODUCTO GAMA(HIJO)
							DELETE FROM "informix".sc_segmentos
							WHERE num_prod= cNum_prodcto AND empresa = cEmpresa;
							
							IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
								LET cCod_ret = '000027';
								LET cMensaje = "Problemas al borrar Datos";											
							END IF;													
						ELSE
							--ES UN PRODUCTO PADRE
							DELETE FROM "informix".sc_segmentos
							WHERE num_prod = cNum_prodcto AND empresa = cEmpresa;
							
							IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
								LET cCod_ret = '000028';
								LET cMensaje = "Problemas al borrar Datos";
							ELSE
								DELETE FROM "informix".sc_segmentos
								WHERE num_prod = cNum_prodcto_g AND empresa = cEmpresa;
							END IF;
						END IF;						
					END IF;
				END IF;
		END IF;		
	ELSE	
		LET cCod_ret = "000029";
		LET cMensaje = "Parametro P_ACCION no es valido";
	END IF;
	IF 	P_ACCION > 1  THEN
		RETURN	NVL(TRIM(cCod_ret), ''),
				NVL(TRIM(cMensaje), ''),
				NVL(TRIM(cNum_prodcto), ''),
				NVL(TRIM(cNum_prodcto_g), ''),
				NVL(TRIM(cTipo_cta), ''),
				NVL(TRIM(cNom_cta), ''),
				NVL(mMto_min, 0.0),
				NVL(mMto_max, 0.0),
				NVL(TRIM(cTxn_dia), ''),
				NVL(TRIM(cTxn_mes), '');
	END IF;
END;  
END PROCEDURE
DOCUMENT
'DESCRIPCIÓN: PROCEDURE QUE DARA MANTENIMIENTO A LOS SEGMENTOS DE DEBITO',
'FECHA DE CREACION: 02-01-2013',
'BASE DE DATOS: BDICHEQ',
'AUTOR: RIGOBERTO GONZALEZ',
'VERSION: 20130102.1541';

CREATE PROCEDURE "informix".sp_asigsegctatrimestral( )
RETURNING	CHAR(6)		AS	CODIGO_ERROR, 
			CHAR(80)	AS	DESCRIPCION,
			CHAR(20)	AS	NUM_CUENTA;

DEFINE cCod_ret         	CHAR(6);
DEFINE sSql_err        		SMALLINT;
DEFINE sIsam_err       		SMALLINT;
DEFINE cError_info     		CHAR(40);
DEFINE cMensaje        		CHAR(80);
DEFINE cFechaHoy			DATE;
DEFINE iAnioMes				INTEGER;
DEFINE mSdoPromMens			MONEY(14,2);
DEFINE mSdoPromTrim			MONEY(14,2);
DEFINE sFlag				INTEGER;
DEFINE cCuenta_cte      	CHAR(20);
DEFINE vCuenta		      	CHAR(20);
DEFINE cNumProdIntercard	CHAR(3);
DEFINE cNumProdSegmto		CHAR(3);
DEFINE cNumTarjeta	    	CHAR(20);
DEFINE cNumTarjetaAdic    	CHAR(20);
DEFINE cNumProdGamSegmto	CHAR(3);
DEFINE cNum_cte		      	CHAR(20);
DEFINE vcapvigacum			MONEY(14,2);
DEFINE vdiacum       		SMALLINT;
DEFINE vAnioMes				CHAR(6);
DEFINE vExiste				CHAR(1);
  
-- INICIALIZAR VARIABLES
LET cCod_ret 			= '000000';
LET sSql_err			= 0;
LET sIsam_err			= 0;
LET cError_info			= '';
LET cMensaje 			= 'Proceso Exitoso';
LET cFechaHoy			= DATE(1);
LET iAnioMes			= 0;
LET mSdoPromMens		= 0;
LET mSdoPromTrim		= 0;
LET sFlag				= 0;
LET cCuenta_cte 		= '';
LET vCuenta		 		= '';
LET cNumProdIntercard	= '';
LET cNumProdSegmto		= 0;
LET cNumTarjeta			= '';
LET cNumTarjetaAdic		= '';
LET cNumProdGamSegmto 	= '';
LET cNum_cte			= '';
LET vcapvigacum			= 0;
LET vdiacum				= 0;
LET vAnioMes			= '';
LET vExiste				= '0';

BEGIN

ON EXCEPTION SET sSql_err, sIsam_err, cError_info		
	IF sSql_err <> 0 THEN
		LET cCod_ret = sSql_err;
		LET cMensaje = cError_info;
		RETURN	NVL(TRIM(cCod_ret), ''),
				NVL(TRIM(cMensaje), ''),				
				NVL(TRIM(cCuenta_cte), '');
	END IF;	  
END EXCEPTION;

	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/informix/c91691184/sp_asigsegctatrimestral.out";
	--TRACE ON;

	--OBTENER LA FECHA
	SELECT	pri_dia_mes, YEAR(pri_dia_mes) || lpad(month(pri_dia_mes),2,'0')
	INTO	cFechaHoy, vAnioMes
	FROM	"informix".sc_fechas
	WHERE 	empresa = '001';

	--OBTENER INDICADOR DEL MES PARA SABER SI SE EJECUTO ANTES EL SP
	SELECT valor
	INTO vExiste
	FROM "informix".sc_param
	WHERE empresa = '001'
	AND codparam = 'asigsegdc';
	
	if vExiste <> '0' then
		
		--LIMPIANDO TABLA DE TRABAJO DONDE SE ALMACENAN LAS CUENTAS EVALUADAS
		TRUNCATE TABLE "informix".sc_ctasegmentadas;
		
		--RESETEAR INDICADOR DEL MES PARA EL PROCESO MENSUAL
		UPDATE "informix".sc_param
		SET valor ='0'
		WHERE empresa = '001'
		AND codparam = 'asigsegdc';
	
	else
		
		--TOMA LA ULTIMA CUENTA CON LA QUE SE TRABAJO PARA EMPEZAR DE LA SIGUIENTE
		select {+INDEX("informix".sc_ctasegmentadas idx1_numtarjeta)}
		max(num_cta) 
		into vCuenta
		from "informix".sc_ctasegmentadas 
		where empresa = '001';
		
		if vCuenta is Null then
		
			let vcuenta = '00000000000';
			
		end if;
	
	END IF;
	
	FOREACH with hold
		
		SELECT	TRIM(A.cuenta), TRIM(C.num_tarjeta), TRIM(A.num_cte)
		INTO	cCuenta_cte, cNumTarjeta, cNum_cte
		FROM	"informix".sc_maechq AS A, 
				"informix".sc_maenoc AS B,
				"informix".sc_tarjeta AS C
		WHERE	A.empresa = '001'
		AND 	B.fecha_alta <= (DATE(cFechaHoy) - 3 UNITS MONTH)
		AND		A.cuenta = B.cuenta
		AND		B.cuenta = C.cuenta
		AND 	C.tipo_tarjeta = 'T'
		AND		C.status_tar = 'A'
		AND     A.producto NOT IN ('1400','1300','1700','1900')
		AND 	A.cuenta > TRIM(vCuenta)
		ORDER BY	A.cuenta		
	
		FOREACH with hold
		
			SELECT	FIRST 3 (aniomes::INT)
			INTO	iAnioMes	
			FROM	"informix".sc_sdodiarioc
			WHERE	cuenta = TRIM(cCuenta_cte)
			and 		aniomes <> vAnioMes
			ORDER BY	aniomes:: INT DESC		
			
			select capvigacum, diacum
			INTO vcapvigacum, vdiacum
			from sc_sdodiarioc 
			WHERE cuenta = TRIM(cCuenta_cte)
			AND	aniomes::INT = iAnioMes;
			
			if vcapvigacum <> 0 THEN
				
				LET mSdoPromMens = vcapvigacum / vdiacum;
				
			END IF;
			
			LET sFlag = sFlag + 1;			
			LET mSdoPromTrim = mSdoPromTrim + mSdoPromMens;			
			
		END FOREACH;		
		
		IF sFlag  <>  3 THEN		
			CONTINUE FOREACH;		
		ELSE		 
			-- INICIALIZAR VARIABLES
			LET cCod_ret = '000000';
			LET cMensaje = 'Proceso exitoso';
			LET sFlag = 0;
			
			LET mSdoPromTrim = mSdoPromTrim / 3;
			
			SELECT	LIMIT 1 TRIM(num_prod), TRIM(num_prod_gama)
			INTO	cNumProdSegmto, cNumProdGamSegmto
			FROM	"informix".sc_segmentos
			WHERE	empresa= '001'
			AND		sdo_prom_max >= mSdoPromTrim
			AND		sdo_prom_min <= mSdoPromTrim
			AND		num_prod_gama <> '';
			
			IF NVL(cNumProdSegmto,'') = '' THEN
				LET cCod_ret = '000001';
				LET cMensaje = 'El límite autorizado no se encuentra en ningun rango establecido.';
			ELSE
				--OBTENER EL NUMERO DE PRODUCTO ANTERIOR DE LA TARJETA DEL TITULAR
				SELECT	NVL(TRIM(codproductotarjeta),'0')
				INTO	cNumProdIntercard
				FROM	intercard:"informix".tarjeta
				WHERE	numtarjeta = TRIM(cNumTarjeta)
				AND		codstatustarjeta ='ACT'
				AND		titular ='T';
				
				IF NVL(cNumProdIntercard,'') = '' THEN
					LET cCod_ret = '000002';
					LET cMensaje = 'No se encontró la tarjeta del titular en la bd intercad.';
				ELSE
					--LAS TARJETAS SOLO PUEDEN ESCALAR A UN SEGMENTO MAS GRANDE
					IF CAST(cNumProdSegmto AS INTEGER) > CAST(cNumProdIntercard AS INTEGER) or (trim(cNumProdIntercard) = '501') THEN
						
						LET cNumProdIntercard	= '';
						
						BEGIN;
							UPDATE	intercard:"informix".tarjeta
							SET	codproductotarjeta = cNumProdSegmto
							WHERE	numtarjeta = TRIM(cNumTarjeta)
							AND	codstatustarjeta = 'ACT';
						COMMIT;	
						
						IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
							LET cCod_ret = '000003';
							LET cMensaje = 'No se actualizó la tarjeta del titular en la bd intercad.';
						ELSE
							--SI ENTRAMOS AQUI, ES POR QUE SE ACTUALIZARON LOS DATOS EN LA CUENTA TITULAR					
							--SE INSERTA LA CUENTA EN LA TABLA DE TRABAJO PARA EVALUARLA POSTERIORMENTE EN BASE A SUS TRANSACCIONES DIARIAS.
							
							BEGIN;							
								INSERT INTO "informix".sc_ctasegmentadas
									(empresa, num_cte, num_cta, num_tarjeta, num_prod, num_prod_gama)
								VALUES('001', TRIM(cNum_cte), TRIM(cCuenta_cte), TRIM(cNumTarjeta), TRIM(cNumProdSegmto), TRIM(cNumProdGamSegmto));
							COMMIT;

							LET cNumTarjetaAdic		= '';						
							FOREACH with hold
							
								--TARJETAS ADICIONALES DE LA CUENTA
								SELECT	TRIM(num_tarjeta)
								  INTO	cNumTarjetaAdic
								  FROM	"informix".sc_tarjeta					
								 WHERE	empresa = '001' and cuenta = TRIM(cCuenta_cte)
								   AND	tipo_tarjeta = 'A'
								   AND	status_tar = 'A'
								
								IF NVL(TRIM(cNumTarjetaAdic),'') = '' THEN
									LET cCod_ret = '000004';
									LET cMensaje = 'La cuenta no tiene tarjetas adicionales.';							
								ELSE
									--AHORA ES MOMENTO DE ACTUALIZAR LAS TARJETAS ADICIONALES DE LA CUENTA
									BEGIN;
										UPDATE	intercard:"informix".tarjeta
										SET	codproductotarjeta = TRIM(cNumProdSegmto)
										WHERE	numtarjeta = TRIM(cNumTarjetaAdic)
										AND 	codstatustarjeta ='ACT';
									COMMIT;
									   
									IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
										LET cCod_ret = '000005';
										LET cMensaje = 'No se actualizó la tarjeta adicional del titular en la bd intercad.';
									END IF;								
								END IF;
							END FOREACH;
						END IF;			
					ELSE
						LET cCod_ret = '000006';
						LET cMensaje = 'La tarjeta del titular cuenta con un producto mayor o igual.';
					END IF;
				END IF;
			END IF;
		END IF;
		
		LET mSdoPromTrim = 0;	
		LET vcapvigacum = 0;
		
	END FOREACH;
	
	RETURN	cCod_ret,
	TRIM(cMensaje),
	TRIM(cCuenta_cte) WITH RESUME;
	
END;
  
END PROCEDURE

DOCUMENT
'DESCRIPCIÓN: PROCEDURE QUE ASIGNARA UN SEGMENTO A UNA TARJETA EVALUANDO SU SALDO PROMEDIO TRIMESTRAL',
'FECHA DE MODIFICACION: 22-01-2013',
'BASE DE DATOS: BDICHEQ',
'AUTOR: RIGOBERTO GONZALEZ',
'VERSION: 20130122.1000';

CREATE PROCEDURE "informix".sp_asigseggamaalta( )
RETURNING	CHAR(6)		AS	CODIGO_RET, 
			CHAR(80)	AS	DESCRIPCION,
			CHAR(20)	AS	NUM_TARJETA,
			CHAR(3)		AS	NUM_PROD_GAMA,			
			INTEGER	AS  TXNMENSUALES;

DEFINE cCod_ret             CHAR(6);
DEFINE sSql_err             INTEGER;
DEFINE sIsam_err            INTEGER;
DEFINE cError_info          CHAR(40);
DEFINE cMensaje             CHAR(80);
DEFINE sExiste				INTEGER;
DEFINE sTxnDia				INTEGER;
DEFINE sTxnMes				INTEGER;
DEFINE sDiasCumplio			INTEGER;
DEFINE sTotalTrans			INTEGER;
DEFINE cFlag				CHAR(1);
DEFINE cNumTarjeta	    	CHAR(20);
DEFINE cNumProdGamSegmto	CHAR(3);
DEFINE cMesDia				DATE;
DEFINE sNumTrans			INTEGER;
DEFINE cCuenta_cte      	CHAR(20);
DEFINE dFecha_hoy           DATE;
DEFINE dtFecha_ini			DATE;
DEFINE dtFecha_fin		 	DATE;
DEFINE sMonth				INTEGER;
  
-- INICIALIZAR VARIABLES
LET cCod_ret            = '000000';
LET sSql_err			= 0;
LET sIsam_err			= 0;
LET cError_info         = '';
LET cMensaje            = 'Proceso exitoso';
LET sExiste				= 0;
LET sTxnDia				= 0;
LET sTxnMes				= 0;
LET sDiasCumplio		= 0;
LET sTotalTrans			= 0;
LET cFlag				= 'F';
LET cNumTarjeta			= '';
LET cNumProdGamSegmto 	= '';
LET sNumTrans			= 0;
LET cCuenta_cte		 	= '';
LET dFecha_hoy			= DATE(1);
LET dtFecha_ini			= DATE(1);
LET dtFecha_fin			= DATE(1);
LET cMesDia				= DATE(1);
LET sMonth				= 0;
	
SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ ;

BEGIN

ON EXCEPTION SET sSql_err, sIsam_err, cError_info		
	IF sSql_err <> 0 THEN			
		LET cCod_ret = sSql_err;
		LET cMensaje = cError_info;
		RETURN	NVL(TRIM(cCod_ret), ''),
				NVL(TRIM(cMensaje), ''),				
				NVL(TRIM(cNumTarjeta), ''),
				NVL(TRIM(cNumProdGamSegmto), ''),				
				NVL(sTotalTrans, 0);
	END IF;	  
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/informix/c91691184/sp_asigseggamaalta.out";
--TRACE ON;

SELECT	pri_dia_mes
INTO	dFecha_hoy
FROM 	"informix".sc_fechas
WHERE	empresa ='001';

LET dtFecha_ini = dFecha_hoy - 1 units MONTH;
LET dtFecha_fin = dFecha_hoy - 1 units DAY;

--INDICADOR DEL MES PARAMETRICO
SELECT NVL(TRIM(valor)::INTEGER,0)
INTO sMonth	
FROM "informix".sc_param
WHERE empresa = '001'
AND codparam = 'asigsegdc';
   
IF sMonth = 2 THEN			
		LET cCod_ret = '000006';
		LET cMensaje = 'El proceso de validacion a finalizado';
		RETURN	NVL(TRIM(cCod_ret), ''),
				NVL(TRIM(cMensaje), ''),				
				NVL(TRIM(cNumTarjeta), ''),
				NVL(TRIM(cNumProdGamSegmto), ''),				
				NVL(sTotalTrans, 0);
END IF;	
   
LET	sMonth = sMonth + 1;

-- ACTUALIZAMOS EL PARAMETRO PARA INDICAR EL CAMBIO DE MES
BEGIN;
	UPDATE "informix".sc_param
	SET valor = sMonth::CHAR(1)
	WHERE empresa = '001'
	AND codparam = 'asigsegdc';
COMMIT;
	
FOREACH	with hold
	
	SELECT	TRIM(NVL(A.num_tarjeta,'0')), TRIM(NVL(A.num_prod_gama,'0')), TRIM(NVL(A.num_cta,'0'))
	INTO	cNumTarjeta, cNumProdGamSegmto, cCuenta_cte
	FROM	"informix".sc_ctasegmentadas AS A,
			"informix".sc_tarjeta AS B
	WHERE	A.empresa = B.empresa
	AND 	A.num_cta = B.cuenta
	AND		A.num_tarjeta = B.num_tarjeta
	AND		B.status_tar = 'A'
	AND	    B.empresa = '001'
	ORDER BY	A.num_prod	   
	
	LET cFlag = 'V';
	
	SELECT	1
	INTO	sExiste
	FROM	"informix".sc_segmentos
	WHERE	num_prod = TRIM(cNumProdGamSegmto)
	AND		empresa = '001';

	IF NVL(sExiste, 0) = 0 THEN
		LET cCod_ret = '000001';
		LET cMensaje = 'El segmento gama que hace referencia no existe.';
	ELSE		
		--OBTENER EL NUMERO DE TRANSACCIONES DIARIAS Y MENSUALES REQUERIDAS PARA EL TIPO GAMA
		SELECT	TRIM(txn_dia)::INTEGER, TRIM(txn_mes)::INTEGER
		INTO	sTxnDia, sTxnMes
		FROM	"informix".sc_segmentos
		WHERE	empresa = '001' AND num_prod = TRIM(cNumProdGamSegmto);

		FOREACH with hold
		
			--BUSCANDO LAS TRANSACCIONES DE LA TARJETA
			SELECT	{+INDEX("informix".sc_movhis idx_movhis_serial)}
			COUNT (num_serial), fech_alt
			INTO		sNumTrans, cMesDia
			FROM		"informix".sc_movhis
			WHERE		fech_alt  BETWEEN  dtFecha_ini  AND dtFecha_fin
			AND			num_tarjeta = cNumTarjeta
			and 		usuario = 'intercar'
			GROUP BY   	num_serial, fech_alt
			
			LET cFlag = 'T';
			
			IF NVL(sNumTrans, 0) > NVL(sTxnDia, 0) THEN
				LET sDiasCumplio = sDiasCumplio + 1;
			END IF;
			
			LET sTotalTrans = sTotalTrans + NVL(sNumTrans,0);
			
			IF ( sDiasCumplio = 6) OR ( sTotalTrans > sTxnMes )THEN
				--LA TARJETA SI LOGRO CUMPLIR CON EL REQUISITO DE LAS TRANSACCIONES
				IF sMonth = 2 THEN
					--EL PROCESO YA SE ENCUENTRA EN EL SEGUNDO MES Y POR LO TANTO DEBEMOS ACTUALIZAR A SU TIPO GAMA EN LA INTERCARD
					BEGIN;
						UPDATE	intercard:"informix".tarjeta
						SET	codproductotarjeta = cNumProdGamSegmto
						WHERE	numtarjeta = TRIM(cNumTarjeta)
						AND	codstatustarjeta = 'ACT';
					COMMIT;
					   
					IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
						LET cCod_ret = '000002';
						LET cMensaje = 'Falló la actualización de la tarjeta del titular en la bd INTERCARD.';
					ELSE						
						
						--LAS TARJETAS ADICIONALES DE LA CUENTA HEREDAN EL MISMO PRODUCTO					
						FOREACH with hold
							--TARJETAS ADICIONALES DE LA CUENTA
							SELECT	TRIM(num_tarjeta)
							  INTO	cNumTarjeta
							  FROM	"informix".sc_tarjeta					
							 WHERE	empresa = '001'	
							   AND	cuenta = TRIM(cCuenta_cte)
							   AND	tipo_tarjeta = 'A'
							   AND	status_tar = 'A'

							--ACTUALIZAR LAS TARJETAS ADICIONALES DE LA CUENTA EN LA INTERCARD
							BEGIN;
								UPDATE	intercard:"informix".tarjeta
								SET	codproductotarjeta = TRIM(cNumProdSegmto)
								WHERE	numtarjeta = TRIM(NVL(cNumTarjeta,''))
								AND 	codstatustarjeta = 'ACT';
							COMMIT;
							
						END FOREACH;
					END IF;
				END IF;	
			ELSE
				--LA TARJETA NO LOGRO CUMPLIR CON EL REQUISITO DE LAS TRANSACCIONES
				LET cCod_ret = '000003';
				LET cMensaje = 'La tarjeta no calificó dentro del tipo gama.';
				
				--BORRAMOS EL REGISTRO DE LA TABLA DE TRABAJO PARA NO VOLVER A EVALUARLO
				BEGIN;
				DELETE	FROM	"informix".sc_ctasegmentadas
					   WHERE	num_tarjeta = TRIM(cNumTarjeta)
						 AND	empresa = '001';
				COMMIT;
			END IF;			
		END FOREACH;
		
		IF (cFlag <> 'T') THEN
			LET cCod_ret = '000004';
			LET cMensaje = 'Tarjeta sin transacciones en el mes anterior.';
			
			--BORRAMOS EL REGISTRO DE LA TABLA DE TRABAJO PARA NO VOLVER A EVALUARLO
			BEGIN;
				DELETE	FROM	"informix".sc_ctasegmentadas
				WHERE	num_tarjeta = TRIM(cNumTarjeta)
				AND	empresa = '001';
			COMMIT;
		END IF;						
	END IF;	
	
			LET cCod_ret            = '000000';
			LET cMensaje            = 'Proceso exitoso';
			LET cNumTarjeta			= '';
			LET sExiste				= 0;
			LET sTxnDia				= 0;
			LET sTxnMes				= 0;
			LET sTotalTrans			= 0;
			LET sNumTrans			= 0;
			LET cNumProdGamSegmto 	= '';
			
END FOREACH;

	RETURN	NVL(TRIM(cCod_ret), ''),
			NVL(TRIM(cMensaje), ''),
			NVL(TRIM(cNumTarjeta), ''),
			NVL(TRIM(cNumProdGamSegmto), 'F'),			
			NVL(sTotalTrans, 0) WITH RESUME;

IF NVL(cFlag, 'F') = 'F' THEN
	LET cCod_ret = '000005';
	LET cMensaje = 'No hay datos en bdicheq:sc_ctasegmentadas.';
	RETURN	NVL(TRIM(cCod_ret), ''),
			NVL(TRIM(cMensaje), ''),
			NVL(TRIM(cNumTarjeta), ''),
			NVL(TRIM(cNumProdGamSegmto), ''),			
			NVL(sTotalTrans, 0);
END IF;

END;  
END PROCEDURE
DOCUMENT
'DESCRIPCIÓN: PROCEDURE QUE ASIGNARA UN SEGMENTO GAMA ALTA A UNA TARJETA EVALUANDO SUS TRANSACCIONES EN EL MES ANTERIOR',
'FECHA DE MODIFICACION: 22-01-2012',
'BASE DE DATOS: BDICHEQ',
'AUTOR: RIGOBERTO GONZALEZ',
'VERSION: 20130122.1310';

CREATE PROCEDURE "informix".sp_valtraspasoarchivo( pNombreArchivo CHAR(30) )
RETURNING CHAR(5);
    
    DEFINE Sql_Err      INTEGER;
    DEFINE Isam_Err     INTEGER;
    DEFINE Desc_Err     CHAR(50);
    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(50);
    DEFINE vRuta        CHAR(50);
    DEFINE cSQL         CHAR(300);
    DEFINE vContador    INTEGER;
    
    LET Sql_Err	  = 0;
    LET Isam_Err  = 0;
    LET Desc_Err  = '';
    LET vCodRet1  = '';
    LET vCodRet2  = '';
    LET vCodRet3  = '';
    LET vRuta     = '';
    LET cSQL      = '';
    LET vContador = 0;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/riesgos/sp_valtraspasoarchivo.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    SET DEBUG FILE TO "/resplogifx/conciliachq/riesgos/sp_valtraspasoarchivo.trc";
    TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctesxanalizar') THEN
        DROP TABLE "informix".ctesxanalizar;
    END IF;  
    
    CREATE TABLE "informix".ctesxanalizar  
      ( 
        num_cte CHAR(20) NOT NULL
      )
    EXTENT SIZE 10000 NEXT SIZE 1000 LOCK MODE ROW;
    
    SELECT valor
      INTO vRuta
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'rutarchriesgos';
       
    LET cSQL = '';
    LET cSQL = 'echo "LOAD FROM '||TRIM(vRuta)||TRIM(pNombreArchivo)||' delimiter '','' INSERT INTO ctesxanalizar" > '||TRIM(vRuta)||'ctesanacap.sql';
    SYSTEM cSQL;

    LET cSQL = '';
    LET cSQL = '/ifxsif01/bin/dbaccess bdicheq '||TRIM(vRuta)||'ctesanacap.sql';
    SYSTEM cSQL;
    
    CREATE INDEX "informix".idx_ctexana ON "informix".ctesxanalizar(num_cte) USING BTREE; 
    UPDATE STATISTICS HIGH FOR TABLE ctesxanalizar;
    
    SELECT COUNT(*)
      INTO vContador
      FROM ctesxanalizar;
      
    IF vContador > 0 THEN
        LET vCodRet1 = '000';
    ELSE
        LET vCodRet1 = '111';
    END IF;
    
    /* ################################################################
    LET vComando = '';
    LET vComando = 'ls -l '||TRIM(vRuta)||TRIM(pNombreArchivo)||'';
    SYSTEM vComando;
    LET vComando = '';
    ################################################################ */
        
    END;
    
    RETURN vCodRet1;
    
END PROCEDURE;